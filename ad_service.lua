--声明
--[[
    此类替代luascript/client.lua广告平台相关逻辑代码
    从 广告服 获取客户端所需的数据，进行广告的展示、播放、以及回调逻辑的处理
]]
local AdService = Class("AdService")

--实例
local instance = nil

--获取实例
function AdService:GetInst()
	if instance == nil then 
		instance = ClassList["AdService"].instance()
	end 
	return instance
end

-- 初始化
--[[
    config = {
		{
			advert_platform_id = 1001, -- 广告平台id
			advert_status = 0, -- 平台开关(1代表关,0或不填代表开)
			channel_id = 3, -- 渠道ID
			close_advert_version = 0, -- 关闭广告版本(0不关闭)
			show_members_total = 0, -- 分配用户量(0或不填不限制)
			channel_status = 0, -- 渠道开关(1代表关,0或不填代表开)
			ad_shield = 0, -- 屏蔽广告（1当天新增,2[Desc3]用户,4[Desc2]总量,8屏蔽创号2天以上用户,16屏蔽登陆小于n天用户,0或不填代表不屏蔽)
			recharge_num = 0, -- [Desc2]总量(0不屏蔽)
			show_num_percent = 100, -- 单渠道广告平台流量占比(整数1至100代表相应百分比,0代表0%)
			adsense_id = 2, -- 广告位id
			ad_type = 1, -- 广告类型（1视频,2插屏,3原生,4H5）
			ad_developer = 0, -- 是否为开发者广告(0或不填为官方广告，1为开发者广告)
			give_prizes = 0, -- 是否发奖励(0发奖，1不发）
			adsense_status = 0, -- 广告位开关(1代表关,0或不填代表开)
			time_interval = 0, -- 时间间隔（单位秒,0或不填代表无限制）
			adshow_finish_num_total = 10, -- 每人每天在此广告位观看广告完成的次数上限(0或不填代表无限制)
			ad_total_finish_count = 250, -- 每人每天在该渠道观看广告完成的总次数上限(0或不填代表无限制)
			request_frequency_cycling_range = 0, -- 请求频率的最小循环区间，时间单位秒,0为不限区间
			request_members = 0, -- 最小时间区间内没有广告时重复请求的次数,0为不限次数，即请求不到广告时不停的进行请求
			ID = 1, -- nil
		},
    }
]]
function AdService:Init()
    self.ad_info_list = {} -- 保存所有广告位数据
    self.IsCheckAdRequest = true  -- 是否开启广告请求频率检测
end

-- 从 广告服 拉取广告配置（登陆之后 & 切换账号 后拉取配置）
function AdService:InitAllAdConfig()
    local callback = function(ret)
        if ret and ret.ret == 0 then
            if ret.data and ret.data.config and ret.data.bouns and ret.data.web_update_config then
                if not self.web_update_config or (self.web_update_config < ret.data.web_update_config) then
                    --print("InitAllAdConfig callback web_update_config = " .. ret.data.web_update_config .. ", config = ", ret.data.config)
                    self.config = ret.data.config
                    self.bouns = ret.data.bouns
                    self.web_update_config = ret.data.web_update_config
                else
                    print("InitAllAdConfig callback config time error = ", ret.data.web_update_config, self.web_update_config)
                end
            end
        else
            print("InitAllAdConfig callback config = ", ret)
        end
    end

    local url = g_http_root .. "miniw/business_advert?"
    local params = { act = "ad_config_business" } 
    local paramsStr, md5 = http_getParamMD5(params)
    url = url .. paramsStr .. "&md5=" .. md5
    --print("AdService InitAllAdConfig url = ", url)
    ns_http.func.rpc(url, callback, nil, nil, true, true)
end

-- 获取广告配置
function AdService:GetAllAdConfig()
    return self.config
end

-- 根据广告位id获取广告配置
function AdService:GetAdConfig(position_id)    
    if position_id and self.config and self.config[position_id] then
        --print("AdService:GetAdConfig position_id = ", position_id, ", config = ", self.config[position_id])
        return self.config[position_id]
    end
    print("AdService:GetAdConfig position_id = ", position_id, ", config = nil")
    return nil
end

-- 根据广告位id获取广告类型（1视频,2插屏,3原生,4H5）和 平台id
function AdService:GetAdTypeByAdId(position_id)
    if position_id and self.config then        
        if self.config[position_id] then
            --print("AdService:GetAdTypeByAdId, position_id = "..position_id..", ad_type = "..self.config[position_id].ad_type..", advert_platform_id = "..self.config[position_id].advert_platform_id)
            -- 通知原生层加载广告
            if tonumber(position_id) and tonumber(position_id) > 0 then
                Advertisement:hasLoaded(self.config[position_id].advert_platform_id, tonumber(position_id))                
            end
            return self.config[position_id].ad_type, self.config[position_id].advert_platform_id
        else
            print("AdService:GetAdTypeByAdId, position_id = " .. position_id .. ", config[" .. position_id .. "] is nil")
        end
    end
    print("AdService:GetAdTypeByAdId position_id = ", position_id, " failed, config is nil")
    return nil, nil
end

-- 获取广告优先级
function AdService:GetAdTriggerPriority(position_id)
    if position_id and self.config and self.config[position_id] then
        --print("AdService:GetAdTriggerPriority position_id = ", position_id, ", trigger_priority = ", self.config[position_id].trigger_priority)
        return self.config[position_id].trigger_priority
    end
    print("AdService:GetAdTriggerPriority position_id = ", position_id, " failed")
    return nil, nil
end

-- 根据广告位id获取广告信息(position_id 支持 单个广告位请求，支持 多个广告位（table 表）请求)
-- 主要是获取玩家当前广告的播放数据，如 曝光、完成、冷却数据
--[[
    [position_id] = {
        platform_id = 0,
        position_id = 1,
        type = 1, -- 广告类型
        show = { count = 0, ts = 0 },   -- 曝光次数和时间
        finish = { count = 0, ts = 0 }, -- 播放完成次数和时间
        player_ad_interval = 0, -- 间隔天数
        cycling_range = 0, 
        cycling_range_count = 0,
        day_total_finish = 0, -- 日完成天数
        num_total = 0, -- 总次数
        iscoding = false,  -- 冷却状态
        extra = {
            type = 1,
            value = 2,
            condition = 5
        }
    },
]]
function AdService:GetAdInfo(position_id, cb)
    if not position_id then return end

    -- 如果已经缓存过广告数据则直接取本地的缓存使用
    if type(position_id) == "number" and self.ad_info_list and self.ad_info_list[position_id]
        and cb and type(cb) == "function" then
        cb(self.ad_info_list[position_id])
        return
    end

    local ad_string = ""
    local _ , platform_id = nil, nil
    if type(position_id) == "table" then
        local filterList = {}
		local count = #position_id
        for i = 1, count do
            -- 没有配置的广告位不获取其广告数据，已经缓存过的广告不再重复请求，短时间内请求过的不再重复请求
            if self:GetAdTypeByAdId(position_id[i]) and not self.ad_info_list[position_id[i]] and 
                self:IsAdCanRequest(position_id[i], "ad_position_info_business") then
                table.insert(filterList, position_id[i])
                ad_string = ad_string .. position_id[i] .. "_"
                self:SetAdRequestInfo(position_id[i], "ad_position_info_business")
            end
        end
        if ad_string and string.len(ad_string) > 1 then
            ad_string = string.sub(ad_string, 1, string.len(ad_string) - 1)
            _ , platform_id = self:GetAdTypeByAdId(filterList[1])
        end
    elseif not self:GetAdInfoByPosId(position_id) and self:IsAdCanRequest(position_id, "ad_position_info_business") then
        _ , platform_id = self:GetAdTypeByAdId(position_id)
        ad_string = position_id
        self:SetAdRequestInfo(position_id, "ad_position_info_business")
    end

    local callback = function(ret)
        if ret and ret.ret == 0 and ret.data then
            --print("AdService GetAdInfo callback ad_info = ", ret.data)

            if cb and type(cb) == "function" and type(position_id) == "number" then
                cb(ret.data and (ret.data[position_id] or ret.data) or nil)
            end

            -- 缓存 position_id 广告位数据 
            GetInst("AdService"):SetAdInfo(ret.data)
        else
            print("AdService GetAdInfo callback failed, ret = ", ret)

            -- 有些情况在获取广告信息失败时也需要处理
            if cb and type(cb) == "function" then
                cb()
            end
        end
    end

    if ad_string and ad_string ~= "" and platform_id then
        local url = g_http_root .. "miniw/business_advert?"
        local params = { act = "ad_position_info_business", position_id = ad_string, platform_id = platform_id} 
        local paramsStr, md5 = http_getParamMD5(params)
        url = url .. paramsStr .. "&md5=" .. md5
        --print("AdService GetAdInfo position_id = ", ad_string, " url = ", url)
        ns_http.func.rpc(url, callback, nil, nil, true, true, true)
    end
end

-- 判断指定广告位是否能够展示（曝光）
function AdService:IsAdCanShow(position_id, cb, extraInfo, bIgnoreAdLoad)
    --print("AdService IsAdCanShow position_id = ", position_id)
   
    -- codeby fym：解决部分渠道未配置广告位时UI显示错误的问题
    local _ , platform_id = self:GetAdTypeByAdId(position_id)
    if not platform_id and cb and type(cb) == "function" then
        cb(false)
        return
    end

    local callback = function(ad_info)
        local result = ad_data_new.canShow(position_id, ad_info, extraInfo, bIgnoreAdLoad) or false
        print("AdService IsAdCanShow position_id = ", position_id, ", result = ", result)
        -- 执行广告位能否展示的回调
        if cb and type(cb) == "function" then
            cb(result, ad_info)
        end
    end

    -- 如果已经缓存过广告数据则直接取本地的缓存使用
    local ad_info = self:GetAdInfoByPosId(position_id)
    if ad_info then
        callback(ad_info)
    else
        self:GetAdInfo(position_id, callback)
    end
end

-- 通知服务器广告曝光
function AdService:Ad_Show(position_id, cb)
    if not position_id or position_id <= 0 then return end
    local callback = function(ret)
        if ret and ret.ret == 0 then
            --print("AdService Ad_Show position_id = ", position_id, "result = success")
            if cb and type(cb) == "function" then
               cb()
            end
        else
            print("AdService Ad_Show position_id = ", position_id, "result = failed, ret = ", ret)
        end
    end

    local _ , platform_id = self:GetAdTypeByAdId(position_id)
    if platform_id and self:IsAdCanRequest(position_id, "ad_show_business") then
        local url = g_http_root .. "miniw/business_advert?"
        local params = { act = "ad_show_business", position_id = position_id, platform_id = platform_id} 
        local paramsStr, md5 = http_getParamMD5(params)
        url = url .. paramsStr .. "&md5=" .. md5
        --print("AdService Ad_Show position_id = ", position_id, " url = ", url)
        self:SetAdRequestInfo(position_id, "ad_show_business")
        ns_http.func.rpc(url, callback, nil, nil, true, true)
    end
end

-- 通知服务器开始播放广告 注意：原生广告不需要调用 Ad_StartPlay 接口
function AdService:Ad_StartPlay(position_id, cb)
    if not position_id or position_id <= 0 then return end
    local callback = function(ret)
        if ret and ret.ret == 0 then
            --print("AdService:Ad_StartPlay position_id = ", position_id, " success")
            if ret.data and ret.data.web_update_config ~= self.web_update_config then
                GetInst("AdService"):InitAllAdConfig()
            end
            if cb and type(cb) == "function" then
                cb()
            end
        else
            print("AdService:Ad_StartPlay position_id = ", position_id, " failed, ret = ", ret)
        end
    end

    local _ , platform_id = self:GetAdTypeByAdId(position_id)
    if platform_id and self:IsAdCanRequest(position_id, "ad_start", true) then
        local url = g_http_root .. "miniw/business_advert?"
        local params = { act = "ad_start", position_id = position_id, platform_id = platform_id} 
        local paramsStr, md5 = http_getParamMD5(params)
        url = url .. paramsStr .. "&md5=" .. md5
        --print("AdService Ad_StartPlay position_id = ", position_id, " url = ", url)
        self:SetAdRequestInfo(position_id, "ad_start")
        ns_http.func.rpc(url, callback, nil, nil, true, true)
    end
end

-- 通知服务器广告播放完成（此接口中自动更新了广告数据） 注意：在播放完成之后一定要记得上报埋点数据
function AdService:Ad_Finish(position_id, cb, extraInfo, reportInfo)
    if not position_id or position_id <= 0 then return end
    local report_type = reportInfo and reportInfo.report_type or 'finish'
    local report_id = reportInfo and reportInfo.report_id or position_id
    local callback = function(ret)
        if ret and ret.ret == 0 then
            print("AdService Ad_Finish position_id = ", position_id, " result = success, ad_info = ", ret.data)
            local ad_info = ret.data and (ret.data[position_id] or ret.data) or nil

            -- 结算埋点数据迁移至广告服
            -- 1、原生广告直接上报到广告服
            -- 2、新增的36号、37号广告直接上报到广告服
            -- 3、其他广告按配置上报
            if IsNativeAd(position_id) or position_id == 36 or position_id == 37 or IsAdReportUseNewLogic(position_id) then
                AdReport(ad_info, reportInfo)
            end

            -- H5广告20号广告位需要上报finish到账号服
            if position_id == 20 then
                AccountManager:ad_finish(position_id);                
            end

            -- 1、非开发者广告位中没有迁移至广告服的广告仍然上报给账号服
            -- 2、原生广告无须上报给旧广告服
            -- 3、5号、27号广告暂时在观看广告完成的回调中处理
            -- 4、其他的广告根据配置
            if position_id < 100 and not IsAdReportUseNewLogic(position_id) and position_id ~= 5 and position_id ~= 27 and not IsNativeAd(position_id) then
                AccountManager:ad_finish(position_id, {platform_id = ad_info.platform_id})
            end

            -- 客户端上报finish埋点给大数据
            StatisticsADNew(report_type, report_id, ad_info)
            
            -- 更新缓存数据            
            GetInst("AdService"):SetAdInfo(ret.data)
            
            -- 更新广告配置信息
            if ret.data and ret.data.web_update_config and ret.data.web_update_config ~= self.web_update_config then
                GetInst("AdService"):InitAllAdConfig()
            end

            if cb and type(cb) == "function" then
                cb(ad_info)
            end
        else
            print("AdService Ad_Finish position_id = ", position_id, " result = failed, ret = ", ret)
        end
    end

    local _ , platform_id = self:GetAdTypeByAdId(position_id)
    if platform_id and self:IsAdCanRequest(position_id, "ad_finish_business") then
        local url = g_http_root .. "miniw/business_advert?"
        local params = {}
        if extraInfo then
            local function getKV(t)
                local p = {}
                for k, v in pairs(t) do
                    p[k] = v
                end
                return p
            end
            params = getKV(extraInfo) or {}
        end
        params.act = "ad_finish_business"
        params.position_id = position_id
        params.platform_id = platform_id
        params.CltVersion = ClientMgr:clientVersion()
        params.order_id = DeveloperStoreGetOrderId()
        local ip, accountDelay = "", 0
        if AccountManager.get_outer_ip_and_delay then
            ip, accountDelay= AccountManager:get_outer_ip_and_delay()
        end
        params.client_ip = ip
        local paramsStr, md5 = http_getParamMD5(params)
        url = url .. paramsStr .. "&md5=" .. md5
        --print("AdService Ad_Finish position_id = ", position_id, " url = ", url)
        self:SetAdRequestInfo(position_id, "ad_finish_business")
        ns_http.func.rpc(url, callback, nil, nil, true, true)
    end
end

-- 重置所有广告数据
function AdService:ResetAllAdInfo()
    self.ad_info_list = {} 
end

-- 保存所有广告位的广告数据
function AdService:SetAdInfo(ad_info)
    if not self.ad_info_list then
        self.ad_info_list = {} 
    end
    if not ad_info or not next(ad_info) then
        return
    end

    -- 缓存广告位数据
    local ad_id = nil
    for k, v in pairs(ad_info) do
        if v then
            self.ad_info_list[k] = v
            ad_id = k 
        end      
    end
end

-- 获取已缓存的广告数据，没有缓存则返回nil
function AdService:GetAdInfoByPosId(position_id)
    if self.ad_info_list then
        return self.ad_info_list[position_id]
    end
    return nil
end

-- 获取所有已缓存的广告数据
function AdService:GetAllAdInfo()
    return self.ad_info_list
end

-- 用于记录广告服相关的请求的发起时间
-- request_tag: 请求接口名称
function AdService:SetAdRequestInfo(position_id, request_tag)
    if not self.AdRequestInfo then
        self.AdRequestInfo = {}
    end
    if not self.AdRequestInfo[position_id] then
        self.AdRequestInfo[position_id] = {}
    end
    self.AdRequestInfo[position_id][request_tag] = getServerTime()
end

-- 是否能再次请求广告服：避免发生同一时间内多次发起同一请求的情况
function AdService:IsAdCanRequest(position_id, request_tag, isShowTip)
    --print("AdService IsAdCanRequest position_id = ", position_id, " request_tag = ", request_tag)
    if not self.IsCheckAdRequest then
        --print("result = true, cause check ad request is not open.")
        return true
    end
    if not self.AdRequestInfo or not self.AdRequestInfo[position_id] then
        --print("result = true, cause this is the first request.")
        return true
    end

    local lastTime, curTime = self.AdRequestInfo[position_id][request_tag], getServerTime()
    if lastTime == nil or curTime - lastTime > 1 then
        --print("result = true, cause lastTime = ", lastTime)
        return true
    else
        --print("result = false, cause interal is too shortly")
        if isShowTip then
            -- 提示：点击过于频繁，请稍后再试
            ShowGameTipsWithoutFilter(GetS(1000213))
        end
        return false
    end
end

----------------------------------开发者广告防作弊需求 start-------------------------------
-- 请求开发者广告屏蔽配置
function AdService:InitAntiDeveloperAdConfig()
    local url = g_http_root .. "miniw/business_advert?"
    local params = { act = "ad_zuobi_config"} 
    local paramsStr, md5 = http_getParamMD5(params)
    url = url .. paramsStr .. "&md5=" .. md5
    --print("AdService InitAntiDeveloperAdConfig, url = ", url)
    local callback = function(ret)
        --print("AdService InitAntiDeveloperAdConfig callback, ret = ", ret) 
        if ret and ret.ret == 0 then
            self.antiDeveloperAdConfig = ret.data
        end
    end
    ns_http.func.rpc(url, callback, nil, nil, true, true)
end

-- 获取开发者广告屏蔽配置
function AdService:GetAntiDeveloperAdConfig()
    return self.antiDeveloperAdConfig
end

-- 根据开发者id和地图id判断当前地图中是否能展示开发者广告
function AdService:IsDeveloperAdCanShow(developerId, mapId)
    if not self.antiDeveloperAdConfig or not next(self.antiDeveloperAdConfig) then 
        --print("AdService IsDeveloperAdCanShow not antiDeveloperAdConfig")
        return true
    end
    if not developerId or developerId == 0 or not mapId or mapId == 0 then 
        --print("AdService IsDeveloperAdCanShow developerId = ", developerId, ", mapId = ", mapId)
        return true
    end
    
    -- 当前渠道
    local curTime = getServerTime()
    local config_apiid = self.antiDeveloperAdConfig[ClientMgr:getApiId()]
    if config_apiid and next(config_apiid) then
        for i = 1, #config_apiid do
            local value = config_apiid[i]
            if value.dev_id == developerId and curTime >= value.ban_start_ts and curTime <= value.ban_end_ts and value.map_id then  
                for j = 1, #value.map_id do
                    if mapId == value.map_id[j] or value.map_id[j] == 0 then
                        print("AdService IsDeveloperAdCanShow developerId = ", developerId, ", mapId = ", mapId, ", result = false")
                        return false
                    end
                end
            end
        end
    end

    -- 0表示全渠道
    local config_apiid_0 = self.antiDeveloperAdConfig[0]
    if config_apiid_0 and next(config_apiid_0)  then
        for i = 1, #config_apiid_0 do
            local value = config_apiid_0[i]
            if value.dev_id == developerId and curTime >= value.ban_start_ts and curTime <= value.ban_end_ts and value.map_id then  
                for j = 1, #value.map_id do
                    if mapId == value.map_id[j] or value.map_id[j] == 0 then
                        print("AdService IsDeveloperAdCanShow developerId = ", developerId, ", mapId = ", mapId, ", result = false")
                        return false
                    end
                end
            end
        end
    end

    --print("AdService IsDeveloperAdCanShow developerId = ", developerId, ", mapId = ", mapId, ", result = true")
    return true
end
----------------------------------开发者广告防作弊需求  end--------------------------------