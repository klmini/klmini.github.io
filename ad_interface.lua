-- 广告逻辑处理
ad_data_new = {

	curADCallBack = nil, --播放成功的回调
	curAdCallData = nil, --播放成功的回调的参数
	curADFailedCallBack = nil, --播放失败的回调
	
	positionId = 0,       -- 广告位id
	browserPositionId = 0, -- 当前播放广告的广告位id
	onlineRoomFailNum = 0, -- 记录联机失败次数

	fruitInfo = {},  -- 广告位5-缩短果实成熟时间 数据缓存
	exchangeNpcTrade = {},  -- 旧版广告商人

	lostConnectPosId = 0; --只使用在断链时判断播放的广告为8号和6号

	-- 优先级广告配置数据：广告位有可替换的其他广告位时，根据广告位优先级对广告位进行排序
	PriorityAdConfig = {

		-- 26(14、16)福利广告通用，使用26号广告位播放的其他广告位：42、43、44、45、46、47、48
		[26] = {
			adList = {
				{pos=26, trigger_priority=999999999},
				{pos=16, trigger_priority=999999999},
				{pos=14, trigger_priority=999999999},
			}
		},

		-- 触发器广告 102, 106, 107, 108
		[102] = {
			adList = {
				{ pos = 102, trigger_priority = 999999999},
				{ pos = 106, trigger_priority = 999999999},
				{ pos = 107, trigger_priority = 999999999},
				{ pos = 108, trigger_priority = 999999999},
			}
		},

		-- 目前仅有26号、102广告位有可替代的其他广告位
		-- 为方便日后其他广告位也增加替补广告位，在这里统一处理，方便日后新增
	},

	-- 场景id：进入指定场景后拉取广告数据
	allSenceIdList = {
		minilobby    = 1,   -- 游戏主界面场景
		shop         = 2,   -- 商城场景
		h5           = 3,   -- 跳转到H5界面场景（h5广告在跳转H5时拉取广告在ios平台会出现第一次进入H5无法展示广告的问题，暂时先并入游戏主界面场景中）
		developerMap = 4,   -- 开发者地图场景
		map          = 5,   -- 非开发者地图场景
		activity     = 6,   -- 活动场景
	},

	-- 把所有需要提前获取广告数据的广告位统一起来(顺序无影响)，方便统一刷新广告数据
	allAdList = { 
		[1] = { 
			5, 19,       -- 家园果实-看广告缩短果实成熟时间：刷新过于频繁	
			--6,           -- 进入房间不成功 (已弃用)
			7,           -- 观看广告替代一次分享
			--21,          -- 开始游戏广告(已弃用)		
			29,          -- 悦享卡广告
			34,          -- 增长临时活动广告
			9, 27,       -- 活动-福利-广告商的赞助：刷新过于频繁
			20, 37,      -- H5广告
		},
		[2] = {
			26, 14, 16,  -- 26(14、16)福利广告通用：多个地方使用该广告位，需要做统一处理
			36,          -- 商城-福利商店-迷你点离线收益广告
		},
		[3] = {
			--20, 37       -- H5广告
		},
		[4] = {
			105, 17,     -- 开发者冒险复活
			30, 31,      -- 心愿商人广告
			101, 102, 103, 104, 106, 107, 108, 109, -- 开发者广告：只有在开发者地图中才需要获取广告数据 9个广告位
		},
		[5] = {
			2, 17,       -- 冒险复活
			30, 31,      -- 心愿商人广告
		},
		[6] = {
			32, 33,      -- 幸运方块
			10,          -- 活动-礼包界面
		},
	},

	-- 广告 canShow 失败的原因
	canShowFailResult = {
		developer_forbidden = 1,     -- 开发者被禁止播放广告
		ad_not_loaded       = 2,     -- 广告未加载成功
		ad_cooling          = 3,     -- 广告状态冷却中
		channel_limited     = 4,     -- 该渠道广告位播放次数今日已达上限
		position_limited    = 5,     -- 该广告位今日已达到最大播放次数
		npctrade_failed     = 6,     -- 旧版广告商人交易失败
		onlineroom_Failed   = 7,     -- 联机失败
		agrement_error      = 8,     -- 参数错误
		no_ad_info          = 9,     -- 无广告数据
		no_ad_config        = 10,    -- 无广告配置
		other               = 999,   -- 其他原因
	},


	--[[
		Author: fym
		EditTime: 2021-08-21
		Description: 根据广告位id获取广告的加载状态
	--]]
	getAdLoadStatus = function(position_id)
		local _, platform_id = GetInst("AdService"):GetAdTypeByAdId(position_id)
		if platform_id and position_id and tonumber(position_id) and tonumber(position_id) > 0 then
			return Advertisement:hasLoaded(platform_id, tonumber(position_id))
		end
		return false
	end,

	--[[
	Author: fym
	EditTime: 2021-08-21
	Description:
		position：广告位id
		ad_info: 广告位信息
		extraInfo：老版npc商人会用到
		bIgnoreAdLoad: 
			忽略广告是否加载成功
			true->忽略 
			false->不忽略
	--]]
	canShow = function(position_id, ad_info, extraInfo, bIgnoreAdLoad)
		--local print = Android:Localize(Android.SITUATION.ADVERTISEMENT_101)
		print("ad_data_new canShow position_id = ", position_id, ", ad_info = ", ad_info)
		if position_id and ad_info and ad_info.platform_id then
			ad_data_new.positionId = position_id

			-- 开发者广告作弊惩罚 codeby:fym
			if position_id > 100 and position_id < 200 then
				local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()
				if authorUin and mapId and not GetInst("AdService"):IsDeveloperAdCanShow(authorUin, mapId) then
					print("ad_data_new canShow position_id =", position_id, "developer ad has been forbidden")
					return false, ad_data_new.canShowFailResult.developer_forbidden
				end
			end

			-- 判断广告是否加载成功
			if not Advertisement:hasLoaded(ad_info.platform_id, tonumber(position_id)) and not bIgnoreAdLoad then
				print("ad_data_new canShow position_id = ", position_id, " not loaded")
				--ShowGameTipsWithoutFilter(GetS(4980))
				return false, ad_data_new.canShowFailResult.ad_not_loaded
			end
			
			-- 客户端判断是否广告位是否在冷却中
			if ad_info.finish and ad_info.finish.ts and ad_info.time_interval and
				(ad_info.finish.ts + ad_info.time_interval >= getServerTime()) then
				print("ad_data_new canShow position_id = ", position_id, " is cooling")
				--ShowGameTipsWithoutFilter(GetS(4973))
				return false
			end

			--是否已达每日该渠道广告位播放上限
			if ad_info.is_channel_max == 1 then
				print("ad_data_new canShow position_id = ", position_id, " is limited")
				--ShowGameTipsWithoutFilter(GetS(30120))
				return false, ad_data_new.canShowFailResult.channel_limited
			end

			--是否已达每日该广告位每人播放上限
			if ad_info.is_position_max == 1 then
				print("ad_data_new canShow position_id = ", position_id, " is limited")
				--ShowGameTipsWithoutFilter(GetS(30120))
				return false, ad_data_new.canShowFailResult.position_limited
			end
			if ad_info.finish and ad_info.finish.count and ad_info.num_total and
				(ad_info.finish.count >= ad_info.num_total) then
				print("ad_data_new canShow position_id = ", position_id, " is limited")
				--ShowGameTipsWithoutFilter(GetS(30120))
				return false, ad_data_new.canShowFailResult.position_limited
			end
			
			if extraInfo then
				if position_id == 4 then		--npc交易兑换物品
					if extraInfo.isLock then
						print("ad_data_new canShow position_id = ", position_id, " npc交易兑换物品 isLock")
						return false, ad_data_new.canShowFailResult.npctrade_failed
					else
						if extraInfo.tradeType == 1 then	--星星[Desc5]
							local rewardValue = 5	--默认奖励5个星星
							if ad_info.extra and ad_info.extra.type == 1 then
								rewardValue = ad_info.extra.value or 0
							end
							local getNum = math.floor(rewardValue/(extraInfo.price/extraInfo.num))
							if getNum > 0 then
								return true
							end
						else
							print("ad_data_new canShow position_id = ", position_id, " 星星购买 货币类型错误")
							return false, ad_data_new.canShowFailResult.npctrade_failed
						end
					end
				elseif position_id == 7 then	--分享获得迷你豆
					return true
				end
			else
				if position_id == 6 then 	--联机失败
					local condition = 2
					if ad_info.extra and ad_info.extra.type == 3 then
						condition = ad_info.extra.condition
					end
					print("kekeke position_id", position_id, ad_data_new.onlineRoomFailNum, condition)
					if ad_data_new.onlineRoomFailNum >= condition then	--只要计数满足条件，不管玩家选择看不看广告，都清掉计数
						ad_data_new.onlineRoomFailNum = 0
						return true
					else
						print("ad_data_new canShow position_id = ", position_id, " 联机失败，计数条件不满足")
						return false, ad_data_new.canShowFailResult.onlineroom_Failed
					end
				else
					return true
				end
			end

			print("ad_data_new canShow position_id = ", position_id, " 失败原因未知")
			return false, ad_data_new.canShowFailResult.other
		else
			print("ad_data_new canShow position_id = ", position_id, " 参数错误")
			if not ad_info then
				return false, ad_data_new.canShowFailResult.no_ad_info
			end
			return false, ad_data_new.canShowFailResult.agrement_error
		end
	end,

	-- 获取按优先级排序的广告位列表
	getSortAD = function(t_adPosList)
		print("ad_data_new getSortAD adPosList", t_adPosList);
		local priority = nil
		for index = 1, #t_adPosList do
			priority = GetInst("AdService"):GetAdTriggerPriority(t_adPosList[index].pos)
			print("ad_data_new getSortAD position_id = ", t_adPosList[index].pos, ", priority = ", priority);
			if priority then
				t_adPosList[index].trigger_priority = priority;
			else 
				t_adPosList[index].trigger_priority = 999999999;
			end 
		end
		if #t_adPosList > 0 then
			table.sort(t_adPosList , function (a,b)
				return  a.trigger_priority < b.trigger_priority
			end)
		end
		return t_adPosList;
	end,

	-- 获取广告位列表里最优先并且能播放的广告ID
	-- 参数说明：position_id 指的是广告位
	-- needSort 指是否需要根据优先级重新排序
	getCanShowAdPosByMainId = function (position_id, needSort)
		if not(position_id and position_id > 0) or not ad_data_new.PriorityAdConfig or not ad_data_new.PriorityAdConfig[position_id] then
			return nil
		end
		local adPosList = ad_data_new.PriorityAdConfig[position_id].adList
		local adPosInfo = GetInst("AdService"):GetAllAdInfo()
		if not adPosList or not adPosInfo then
			return nil
		end
		if needSort then
			adPosList = ad_data_new.getSortAD(adPosList);
		end
		local position_id
		for i = 1, #adPosList do
			position_id = adPosList[i].pos
			if adPosInfo[position_id] and ad_data_new.canShow(position_id, adPosInfo[position_id]) then
				print("ad_data_new getCanShowAdPosByMainId position_id = ", position_id, " can show")
				return position_id
			end
		end
		print("ad_data_new getCanShowAdPosByMainId none position_id can show")
		return nil
	end,

	-- 获取当前最优先的广告ID
	getCurrentTriggerID = function(position_id, needSort)
		if not(position_id and position_id > 0) or not ad_data_new.PriorityAdConfig or not ad_data_new.PriorityAdConfig[position_id] then
			return nil
		end

		local adPosList = ad_data_new.PriorityAdConfig[position_id].adList
		local adPosInfo = GetInst("AdService"):GetAllAdInfo()
		if not adPosList or not adPosInfo then
			return nil
		end

		if needSort then
			adPosList = ad_data_new.getSortAD(adPosList);
		end

		local finish = true
		local position_id, ad_info
		for i = 1, #adPosList do

			position_id = adPosList[i].pos
			ad_info = adPosInfo[position_id]

			-- 广告是否达到最大播放次数
			if ad_info and ad_info.finish and ad_info.finish.count and ad_info.num_total and
				(ad_info.finish.count < ad_info.num_total) then
				finish = false
			end
			
			if position_id == 107 then -- 107 H5广告不用加载
				return 107, finish
			end

			if ad_info and ad_data_new.canShow(position_id, ad_info) then
				return position_id, finish
			end
		end

		return nil, finish
	end,

	-- 获取某个场景下的广告位的广告数据
	getAdInfoBySence = function(senceId)
		print("ad_data_new getAdInfoBySence senceId = ", senceId)
		if not senceId or not ad_data_new.allAdList or not ad_data_new.allAdList[senceId] then 
			return 
		end
		print("ad_data_new getAdInfoBySence posList = ", ad_data_new.allAdList[senceId])
		GetInst("AdService"):GetAdInfo(ad_data_new.allAdList[senceId])
	end,
}

-- 判断指定广告上报结算数据上报到账号服还是广告服
function IsAdReportUseNewLogic(positionId)
	-- 新广告系统总开关判断
	if not positionId or not business_advert_config or not business_advert_config.NewAdReportSystem 
		or not business_advert_config.NewAdReportSystem.IsUseNewAdSystem then
		return false
	end
	-- 针对迷你号的开关判断
	if business_advert_config.NewAdReportSystem.IsUseUinList and business_advert_config.NewAdReportSystem.UinList then
		local uin =  AccountManager:getUin()
		return business_advert_config.NewAdReportSystem.UinList[uin] and business_advert_config.NewAdReportSystem.AdPositionId[positionId]
	end
	return business_advert_config.NewAdReportSystem.AdPositionId[positionId]
end

-- 判断指定广告位是新广告系统还是老广告系统
function IsAdUseNewLogic(positionId)
	-- 新广告系统总开关判断
	if not positionId or not business_advert_config or not business_advert_config.NewAdSystem 
		or not business_advert_config.NewAdSystem.IsUseNewAdSystem then
		return false
	end
	-- 针对迷你号的开关判断
	if business_advert_config.NewAdSystem.IsUseUinList and business_advert_config.NewAdSystem.UinList then
		local uin =  AccountManager:getUin()
		return business_advert_config.NewAdSystem.UinList[uin] and business_advert_config.NewAdSystem.AdPositionId[positionId]
	end
	return business_advert_config.NewAdSystem.AdPositionId[positionId]
end

-- 广告埋点上报 重构方式：覆盖
-- 注：只有 finish' or 'againfinish 上报需要 ad_info 奖励相关的数据，其他上报不需要传入 ad_info
function StatisticsADNew(type, position_id, ad_info, reward, authorUin, mapId, itemId)
	print("StatisticsADNew type = " .. type..", position_id = "..(position_id or ''))

	local callback = function(ad_info)
		if ad_info == nil then
			print("StatisticsADNew callback ad_info is nil")
			return
		end
	
		print("StatisticsADNew callback ad_info = " .. (table.tostring and table.tostring(ad_info) or ''))
		-- if authorUin and mapId and itemId then
		-- 	print("==============authorUin,mapId,itemId=========",authorUin,mapId,itemId)
		-- end
	
		-- 再次观看广告，替换广告位
		local replace_AdIdList = {
			[27] = 40,
			[9] = 41,
			[26] = 42
		}

		if (type == 'show' or type == 'againshow') and ad_info.platform_id then -- 按钮显示
			local static_id = 1300
			local replace_AdId = ad_info.position_id
			if type == 'againshow' then -- 再次观看按钮出现
				replace_AdId = replace_AdIdList[position_id]
			end
			if authorUin and mapId and itemId then
				statisticsGameEventNew(static_id,ad_info.platform_id,replace_AdId,authorUin,mapId,itemId,GetCurrentCSRoomId())
			else
				-- 105广告位埋点特殊处理，增加上报作者uin和地图id
				if position_id == 105 then
					statisticsGameEventNew(static_id,ad_info.platform_id,replace_AdId,authorUin,mapId,"",GetCurrentCSRoomId())
				else
					statisticsGameEventNew(static_id,ad_info.platform_id,replace_AdId,"","","",GetCurrentCSRoomId())
				end
			end
			if isSuportNativeAdChannel() and (ad_info.position_id == 15 or ad_info.position_id == "15") then
				SdkAdShow()
			end
		elseif (type == 'onclick' or type == 'againonclick') and ad_info.platform_id then
			local static_id = 1301
			local replace_AdId = ad_info.position_id
			if type == 'againonclick' then -- 再次观看按钮点击
				replace_AdId = replace_AdIdList[position_id]
			end
			if authorUin and mapId and itemId then
				statisticsGameEventNew(static_id, ad_info.platform_id, replace_AdId,authorUin,mapId,itemId,GetCurrentCSRoomId())
			else
				-- 105广告位埋点特殊处理，增加上报作者uin和地图id
				if position_id == 105 then
					statisticsGameEventNew(static_id,ad_info.platform_id,replace_AdId,authorUin,mapId,"",GetCurrentCSRoomId())
				else
					statisticsGameEventNew(static_id,ad_info.platform_id,replace_AdId,"","","",GetCurrentCSRoomId())
				end
			end
		elseif (type == 'finish' or  type == 'againfinish') and ad_info.platform_id then
			local rewardName = nil
			local rewardNum = nil
			if ad_info.extra then
				if ad_info.extra.type == 1 or ad_info.extra.type == '1' then
					rewardName = 'npc_trade'
					if reward then
						rewardName = rewardName..reward.Name
						rewardNum = reward.Num
					end
				elseif ad_info.extra.type == 2 or ad_info.extra.type == '2' then
					rewardName = 'Shortening_fruit_growth_time'
					rewardNum = ad_info.extra.value
				elseif ad_info.extra.type == 3 or ad_info.extra.type == '3' then
					rewardName = 'Online_Failure_Reward'
					rewardNum = ad_info.extra.value
				elseif ad_info.extra.type == 4 or ad_info.extra.type == '4' then
					rewardName = 'Situ_Revive'
				elseif ad_info.extra.type == 5 or ad_info.extra.type == '5' then
					rewardName = 'NPC_Refresh_Goods'
				elseif ad_info.extra.type == 6 or ad_info.extra.type == '6' then
					rewardName = 'Share_Reward_MiniBean'
				end
			end
			local static_id = 1302
			local replace_AdId = ad_info.position_id
			if type == 'againfinish' then -- 再次观看回调
				replace_AdId = replace_AdIdList[position_id]
			end
			if rewardName and rewardNum then
				if authorUin and mapId and itemId then
					statisticsGameEventNew(static_id,ad_info.platform_id, replace_AdId, rewardName, rewardNum,authorUin,mapId,itemId,GetCurrentCSRoomId())
				else
					statisticsGameEventNew(static_id,ad_info.platform_id,replace_AdId,rewardName,rewardNum,"","","",GetCurrentCSRoomId())
				end
			elseif rewardName then
				if authorUin and mapId and itemId then
					statisticsGameEventNew(static_id,ad_info.platform_id,replace_AdId,rewardName,"",authorUin,mapId,itemId,GetCurrentCSRoomId())
				else
					statisticsGameEventNew(static_id,ad_info.platform_id,replace_AdId,rewardName,"","","","",GetCurrentCSRoomId())
				end
			else
				if authorUin and mapId and itemId then
					statisticsGameEventNew(static_id, ad_info.platform_id,replace_AdId,"","",authorUin,mapId,itemId,GetCurrentCSRoomId())
				else
					-- 105广告位埋点特殊处理，增加上报作者uin和地图id
					if position_id == 105 then
						statisticsGameEventNew(static_id, ad_info.platform_id, replace_AdId, "","", authorUin, mapId, "", GetCurrentCSRoomId())
					else
						statisticsGameEventNew(static_id, ad_info.platform_id, replace_AdId,"","","","","",GetCurrentCSRoomId())
					end
				end
			end
		elseif type == 'load' and ad_info.platform_id then
			--print("================real 1 101 1303,authorUin,mapId,itemId================",authorUin,mapId,itemId)
			if authorUin and mapId and itemId then
				-- 20200205：业务数据量过大，关闭上报
				-- statisticsGameEventNew(1303, ad_info.platform_id,ad_info.position_id,authorUin,mapId,itemId)
			else
				-- 20200205：业务数据量过大，关闭上报
				-- statisticsGameEventNew(1303,ad_info.platform_id,ad_info.position_id,"","","")
			end
		elseif type == 'ready' and ad_info.platform_id then
			if authorUin and mapId and itemId then
				-- 20200205：业务数据量过大，关闭上报
				-- statisticsGameEventNew(1304,ad_info.platform_id,ad_info.position_id,authorUin,mapId,itemId)
			else
				-- 20200205：业务数据量过大，关闭上报
				-- statisticsGameEventNew(1304,ad_info.platform_id,ad_info.position_id,"","","")
			end
			threadpool:notify('ad.info.loadresult')  -- 广播广告加载状态有变动
		elseif type == 'loadfail' and ad_info.platform_id then -- 预加载失败通知
			threadpool:notify('ad.info.loadresult')  -- 广播广告加载状态有变动
		end
	end

	-- 只有finish才需要用到ad_info的数据
	if (type == 'finish' or type == 'againfinish') then
		if ad_info then
			callback(ad_info)
		else
			GetInst("AdService"):GetAdInfo(position_id, callback)
		end
	else
		local _, platform_id = GetInst("AdService"):GetAdTypeByAdId(position_id)
		if platform_id then
			callback({ position_id = position_id, platform_id = platform_id})
		end
	end
end

-- C++ 层调用广告埋点上报(函数名保持不变) lua 代码 重构方式：覆盖
function OnStatisticsAdEvent(type, positionId)
	-- 重构后需兼容新老逻辑
	-- 解决方法：根据 positionId 来区别是走新逻辑还是老逻辑
	if IsAdUseNewLogic(positionId) then		
		print("OnStatisticsAdEvent positionId = ", positionId, " use StatisticsADNew")
		StatisticsADNew(type, positionId)
	else
		print("OnStatisticsAdEvent positionId = ", positionId, " use StatisticsAD")
		StatisticsAD(type, positionId)
	end
end

-- 上报广告埋点至广告服
function AdReport(ad_info, extra_info)
	if not ad_info or not ad_info.position_id then
		return
	end
	
	local ip, accountDelay = "", 0
	if AccountManager.get_outer_ip_and_delay then
		ip, accountDelay= AccountManager:get_outer_ip_and_delay()
	end
	local device_system = ''
    local devinfo =  (type(AdGetDeviceInfo) == 'function' and AdGetDeviceInfo()) or nil
    if devinfo and devinfo.SystemVersion and devinfo.Platform then
        device_system = string.format('%s%s', devinfo.SystemVersion, devinfo.Platform)
    end

	local content = JSON:encode({
		-- 1 Uin：玩家迷你号(必填）
		Uin = AccountManager:getUin() or 0,
		-- 2 ts :广告完成时间(必填）
		ts = ad_info.finish.ts,

		-- 3 Version:玩家客户端版本号(必填）
		Version = ClientMgr:clientVersionFromStr(ClientMgr:clientVersionStr()) or "nil",
		-- 4 ApiID:玩家渠道号(必填）
		ApiID = ClientMgr:getApiId() or 999,
		-- 5 Country:玩家国家码(必填）
		Country = get_game_country() or nil,
		
		-- 8 BuyerIP:玩家的ip地址(必填）
		BuyerIP = ip,

		-- 20. DeviceID:玩家设备ID（必填）
		DeviceID = ClientMgr:getDeviceID() or "",
		-- 21. DeviceSystem:设备系统（必填）
		DeviceSystem = device_system,
		
		-- 23. AD_Position:广告位ID（必填）
		AD_Position = ad_info.position_id,
		-- 24. AD_Platform_ID：广告平台ID（必填）
		AD_Platform_ID = ad_info.platform_id,
		-- 25. AD_Type:广告类型（必填）
		AD_Type = ad_info.type,

		-- 26. OS_Type: 用户终端操作系统类型（必填）
		OS_Type = ClientMgr:getPlatformStr() or "",
		-- 27. log_id:SDK那边定义的日志ID（必填）
		log_id = get_log_id() or "nil",
		-- 28. scene_id:SDK那边定义的场景ID（必填）
		scene_id = get_scene_id() or "nil",
		-- 29. game_session_id:SDK那边定义的游戏会话ID（必填）
		game_session_id = get_game_session_id() or "nil",
		-- 30. session_id:SDK那边定义的会话ID（必填）
		session_id = get_session_id() or "nil",

		-- 互动剧上报染色id
		H5GameID = extra_info and extra_info.H5GameID or nil,
	})
	local base64_encode_content = ns_http.func.base64_encode(content)
	--print("base64_encode_content", base64_encode_content)
	local params = { act = "ad_data_report", content = base64_encode_content, is_base64 = 1} 
	--print("params", params)
	local paramsStr, md5 = http_getParamMD5(params)
	local url = g_http_root .. "miniw/business_advert?"
	url = url .. paramsStr .. "&md5=" .. md5
	print("AdReport positionId = ", ad_info.position_id, " url = ", url)
	ns_http.func.rpc(url, nil, nil, nil, true, true, true)
end

-- 观看广告结果回调
-- result 1001：成功 1002：失败 2000：配置错误 3000：SDK后台没有配广告
function OnWatchADResult(result)
	print("OnWatchADResult result = ", result);
	if result == PLAYAD_SUCCESS then
		NewBattlePassEventOnTrigger("adwatch");
		if t_ad_data.curADCallBack then
			-- 广告旧逻辑 
			t_ad_data.curADCallBack(t_ad_data.curAdCallData);
		elseif ad_data_new.curADCallBack then
			print("OnWatchADResult curAdCallData = ", ad_data_new.curAdCallData);
			-- 广告新逻辑
			ad_data_new.curADCallBack(ad_data_new.curAdCallData)
		end
	else
		if t_ad_data.curADFailedCallBack then
			-- 广告旧逻辑 
			t_ad_data.curADFailedCallBack(result, t_ad_data.curAdCallData);
		elseif ad_data_new.curADFailedCallBack then
			-- 广告新逻辑 
			ad_data_new.curADFailedCallBack(result, ad_data_new.curAdCallData);
		elseif result == PLAYAD_FAILED then
			ShowGameTips(GetS(4972), 3);
		elseif result == PLAYAD_UNPREPARED then
			ShowGameTips(GetS(4980));
		elseif result == REQAD_CONFIG_FAILED then
			ShowGameTips(GetS(4973), 3);
		elseif result == REQAD_SDK_FAILED then
			ShowGameTips(GetS(4977), 3);
		else
			ShowGameTips(GetS(4980), 3);
		end
	end

	-- 广告旧逻辑 
	t_ad_data.curADCallBack = nil;
	t_ad_data.curAdCallData = nil;
	t_ad_data.curADFailedCallBack = nil;

	-- 广告新逻辑 
	ad_data_new.curADCallBack = nil;
	ad_data_new.curAdCallData = nil;
	ad_data_new.curADFailedCallBack = nil;
end

-- 是否是原生广告
function IsNativeAd(position_id)
	if position_id == 17 or position_id == 19 or position_id == 60 or position_id == 61 then
		return true
	end
	return false
end
-------------------------------------[[ 以下是接入广告服（新广告系统）的广告位的观看结果回调 ]]----------------------------------

-- 冒险地图-看广告复活：
-- 广告位2：冒险模式复活 视频 生存模式或生存联机死亡时弹出，观看广告复活
-- 广告位105：开发者复活 视频 认证开发者的地图，重生设定为手动重生的均出现开发者复活
function OnReqWatchADRevive(data, btnName)
	print("OnReqWatchADRevive");

    if btnName == nil or btnName == 'right' then
        local positionId = 	data and data.position or 2
		if IsAdUseNewLogic(positionId) then
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(positionId)
			if curWatchADType then
				ad_data_new.curADCallBack = OnRespWatchADReviveNew;
				ad_data_new.curAdCallData = data or {};

				GetInst("AdService"):Ad_StartPlay(positionId, function()				
					print("广告位"..positionId.." Advertisement:request 看广告复活请求")
					Advertisement:request(curWatchADType, id, positionId)
					local extra = { cid = tostring(GetFromMapid()), standby3 = positionId}
					AD_StandReportEvent("RESURRECTION_POPUP", "AdPlayResurrectionButton", "ad_play", extra)--新埋点
				end)
			end
		else
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(positionId)
			if curWatchADType then
				t_ad_data.curADCallBack = OnRespWatchADRevive;
				t_ad_data.reviveAdPositionData = data or {};
	
				Advertisement:request(curWatchADType, id, positionId)
				local extra = {cid=tostring(GetFromMapid()), standby3 = positionId}
				AD_StandReportEvent("RESURRECTION_POPUP", "AdPlayResurrectionButton", "ad_play", extra)--新埋点
			end	
		end
    end
end
-- 冒险地图-看广告复活：2号广告位发奖逻辑重构
function OnRespWatchADReviveNew_RewardLogicHandle(adPosition, data, ad_reward_switch, rewards)
	if ad_reward_switch == 1 then
		
		local callback = function(ret)
			print("OnRespWatchADReviveNew_RewardLogicHandle ret", ret)
			ShowLoadLoopFrame(false)
			if ret and ret.ret == 0 and ClientCurGame and ClientCurGame.getMainPlayer and ClientCurGame:getMainPlayer() then
				local itemData = ret.data
				local prop = {
					ItemId =  itemData.itemid,
					ItemNum = itemData.itemnum,
					IsWareHouse = itemData.iswarehouse
				}
				standReportEvent(409, "RESURRECTION_NEW_INTERFACE", "-", "view")
				ReceiveItemLogic(prop, nil, 409, "RESURRECTION_NEW_GETREWARD") -- 显示获得的道具
			else
				if ret and ret.ret and tonumber(ret.ret) == -47 then 
					ShowGameTips(GetS(756)) -- 本日领取达到上限
				elseif not (ret and ret.ret) or not TipsByHttpTimeCheckError(ret.ret) then
					ShowGameTipsWithoutFilter(GetS(3718))
				end
			end
		end

		if IsAdReportUseNewLogic(adPosition) and rewards then
			callback(rewards)
		else
			local url = g_http_root.."miniw/business?"
			local reqParams = { act = 'revive_ad_reward', ad_id = adPosition, survival = CurMainPlayer:getSurviveDay() }
			local paramStr,md5 = http_getParamMD5(reqParams)
			url =  table.concat({ url, paramStr, '&md5=', md5 })
	
			ShowLoadLoopFrame(true, "ad_logic:miniw/business?act=revive_ad_reward")
			ns_http.func.rpc(url, callback, nil, nil, true,true)
		end
	elseif data and data.resid and data.resid > 0 then
		--看完广告后直接发奖励
		ClientCurGame:getMainPlayer():gainItems(data.resid, data.resnum, 1)
	end
end
-- 冒险地图-看广告复活：观看广告成功回调 新广告系统使用
function OnRespWatchADReviveNew(data)
	local adPosition = data and data.position or 2
	local authorUin = data and data.authorUin or 0
	local mapId = data and data.mapId or 0

	print("OnRespWatchADReviveNew positionData = ", data);

	local adConfig = ns_version.revive
	local ad_reward_switch = 0   -- 屏蔽开发者模式
	if adConfig and adConfig.ad_reward_switch and adConfig.ad_reward_switch == 1 and adPosition ~= 105 then
		ad_reward_switch = 1
	end
	local extraInfo = nil
	if adPosition == 2 then
		extraInfo = { 
			survival = CurMainPlayer:getSurviveDay(),
			ad_reward_switch = ad_reward_switch
		} 
	end

	GetInst("AdService"):Ad_Finish(adPosition, function(ad_info)
		print("广告位"..adPosition.." Ad_Finish 看广告复活回调")
		
		-- 105号广告位增加上报作者uin和地图id
		if adPosition == 105 then
			-- 开发者观看广告的数据详情仍然需要上报到账号服
			local finish_info = {
				MapID           = tostring(mapId),
				AuthorUin       = authorUin,
				BuyerApiID      = ClientMgr:getApiId(),
				BuyerUin        = AccountManager:getUin(),
				BuyerCltVersion = ClientMgr:clientVersion(),
				country         = get_game_country(),
				eventTime       = os.time(),
				cs_roomid       = GetCurrentCSRoomId()
			}
			local _extend_data = GetInst("ExternalRecommendMgr") and GetInst("ExternalRecommendMgr"):OrginazeDeveloperParam() or nil;
			finish_info.extend_data = _extend_data;
			AccountManager:ad_finish(adPosition, finish_info)
		end

		local extra = {cid=tostring(GetFromMapid()), standby3 = adPosition}
		AD_StandReportEvent("RESURRECTION_POPUP", "AdPlayResurrectionButton", "ad_complete", extra)--新埋点

		if ClientCurGame.getMainPlayer then
			-- 冒险复活接口
			if ClientCurGame:getMainPlayer():revive(adPosition) then
				local deathFrame = getglobal("DeathFrame");
				deathFrame:Hide();
			end

			-- 冒险复活发奖逻辑
			OnRespWatchADReviveNew_RewardLogicHandle(adPosition, data, ad_reward_switch, ad_info and ad_info.rewards or nil)
		end
	end, extraInfo)
end
-- 冒险地图-看广告复活：观看广告成功回调 旧广告系统使用
function OnRespWatchADRevive()
	local positionData = t_ad_data.reviveAdPositionData
	local adPosition = positionData and positionData.position or 2
	local authorUin = positionData and positionData.authorUin
	local mapId = positionData and positionData.mapId

	print("OnRespWatchADRevive positionData = ", positionData);

	-- 105号广告位增加上报作者uin和地图id
	if adPosition == 105 then
		local finish_info = {
			MapID           = tostring(mapId),
			AuthorUin       = authorUin,
			BuyerApiID      = ClientMgr:getApiId(),
			BuyerUin        = AccountManager:getUin(),
			BuyerCltVersion = ClientMgr:clientVersion(),
			country         = get_game_country(),
			eventTime       = os.time(),
			cs_roomid       = GetCurrentCSRoomId()
		}
		
		local _extend_data = GetInst("ExternalRecommendMgr") and GetInst("ExternalRecommendMgr"):OrginazeDeveloperParam() or nil;
		finish_info.extend_data = _extend_data;
		AccountManager:ad_finish(adPosition, finish_info)
	else
		AccountManager:ad_finish(adPosition)
	end

	-- 105广告位埋点增加作者uin和地图id
	if adPosition == 105 then
		StatisticsAD('finish', adPosition, nil, authorUin, mapId)
	else
		StatisticsAD('finish', adPosition)
	end
	local extra = {cid=tostring(GetFromMapid()), standby3 = adPosition}
	AD_StandReportEvent("RESURRECTION_POPUP", "AdPlayResurrectionButton", "ad_complete", extra)--新埋点

	if ClientCurGame.getMainPlayer then
		if ClientCurGame:getMainPlayer():revive(adPosition) then
			local deathFrame = getglobal("DeathFrame");
			deathFrame:Hide();
		end

		local adConfig = ns_version.revive
		if adConfig and adConfig.ad_reward_switch and adConfig.ad_reward_switch == 1 and adPosition ~= 105 then -- 屏蔽开发者模式
			-- local url = g_http_root.."miniw/business?act=revive_ad_reward&"..http_getS1(true)
			-- url = url.."&ad_id="..adPosition.."&survival="..CurMainPlayer:getSurviveDay()
			local url = g_http_root.."miniw/business?"
			local reqParams = { act = 'revive_ad_reward', ad_id = adPosition, survival = CurMainPlayer:getSurviveDay(),}
			local paramStr,md5 = http_getParamMD5(reqParams)
			url =  table.concat({url,paramStr,'&md5=',md5})

			local callback = function(ret)
				print("kgq revive_ad_reward ret", ret)
				ShowLoadLoopFrame(false)
				if ret and ret.ret == 0 and ClientCurGame and ClientCurGame.getMainPlayer and ClientCurGame:getMainPlayer() then
					local itemData = ret.data
					local prop = {
						ItemId =  itemData.itemid,
						ItemNum = itemData.itemnum,
						IsWareHouse = itemData.iswarehouse
					}
					-- if prop.IsWareHouse == 0 then -- 0游戏道具
						-- 在ReceiveItemLogic函数已经添加了gainItems，防止重复发放道具，这里屏蔽
					-- 	ClientCurGame:getMainPlayer():gainItems(prop.ItemId, prop.ItemNum, 1)
					-- end
					standReportEvent(409, "RESURRECTION_NEW_INTERFACE", "-", "view")
					ReceiveItemLogic(prop, nil, 409, "RESURRECTION_NEW_GETREWARD") -- 显示获得的道具
				else
					if ret and ret.ret and tonumber(ret.ret) == -47 then 
						ShowGameTips(GetS(756)) -- 本日领取达到上限
					elseif not (ret and ret.ret) or not TipsByHttpTimeCheckError(ret.ret) then
						ShowGameTipsWithoutFilter(GetS(3718))
					end
				end
			end
			ShowLoadLoopFrame(true, "ad_logic:miniw/business?act=revive_ad_reward")
			ns_http.func.rpc(url, callback, nil, nil, true,true)
		else
			--看完广告后直接发奖励
			if t_ad_data.reviveAdPositionData and t_ad_data.reviveAdPositionData.resid and t_ad_data.reviveAdPositionData.resid > 0 then
				ClientCurGame:getMainPlayer():gainItems(t_ad_data.reviveAdPositionData.resid, t_ad_data.reviveAdPositionData.resnum, 1)
			end
		end
	end

	t_ad_data.reviveAdPositionData = nil
end

-- 旧版广告商人功能-看广告刷新交易货品 广告位3 (已弃用)
function OnReqWatchADRefreshNpcTrade(data, btnName)
	print("OnReqWatchADRefreshNpcTrade");

	if btnName == nil or btnName == 'right' then
		local position_id = 3
		if IsAdUseNewLogic(position_id) then
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id);
			if curWatchADType then
				ad_data_new.curADCallBack = OnRespWatchADRefreshNpcTrade;
				GetInst("AdService"):Ad_StartPlay(position_id, function()
					Advertisement:request(curWatchADType, id, position_id)
				end)
			end
		else
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(3);
			if curWatchADType then
				t_ad_data.curADCallBack = OnRespWatchADRefreshNpcTrade;
				Advertisement:request(curWatchADType, id,3)
			end
		end
	end
end
-- 旧版广告商人功能-看广告刷新交易货品：观看广告成功回调
function OnRespWatchADRefreshNpcTrade()
	print("OnRespWatchADRefreshNpcTrade");
	local position_id = 3
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			CurMainPlayer:npcTrade(0, 0, true);
		end)
	else
		AccountManager:ad_finish(3);
		StatisticsAD('finish', 3);
		CurMainPlayer:npcTrade(0, 0, true);
	end
end

-- 旧版广告商人功能-看广告交换货品 广告位4 (已弃用)
function OnReqWatchADExchangeNpcTrade(data, btnName)
	print("OnReqWatchADExchangeNpcTrade");

	if btnName == nil or btnName == 'right' then
		local position_id = 4
		if IsAdUseNewLogic(position_id) then
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id);
			if curWatchADType then
				ad_data_new.exchangeNpcTrade.index = data.index;
				ad_data_new.exchangeNpcTrade.num = data.num;
				ad_data_new.curADCallBack = OnRespWatchADExchangeNpcTrade;
				GetInst("AdService"):Ad_StartPlay(position_id, function()
					Advertisement:request(curWatchADType, id, position_id)
				end)
			end			
		else
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(4);
			if curWatchADType then
				t_ad_data.exchangeNpcTrade.index = data.index;
				t_ad_data.exchangeNpcTrade.num = data.num;
				t_ad_data.curADCallBack = OnRespWatchADExchangeNpcTrade;

				Advertisement:request(curWatchADType, id,4)
			end
		end
	end
end
-- 旧版广告商人功能-看广告交换货品：观看广告成功回调
function OnRespWatchADExchangeNpcTrade()
	print("OnRespWatchADExchangeNpcTrade");
	if ad_data_new.exchangeNpcTrade and next(ad_data_new.exchangeNpcTrade) ~= nil then
		print(ad_data_new.exchangeNpcTrade);

		local position_id = 4
		if IsAdUseNewLogic(position_id) then
			GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
				CurMainPlayer:npcTrade(1, ad_data_new.exchangeNpcTrade.index, true, ad_data_new.exchangeNpcTrade.num);
	
				local IitemId = ClientBackpack:getGridItem(ad_data_new.exchangeNpcTrade.index);
				local def = ItemDefCsv:get(IitemId);
				local text = GetS(3595, def.Name, ad_data_new.exchangeNpcTrade.num);
				ShowGameTips(text, 1);
	
				ad_data_new.exchangeNpcTrade = {};
			end)					
		else
			AccountManager:ad_finish(4);
			CurMainPlayer:npcTrade(1, t_ad_data.exchangeNpcTrade.index, true, t_ad_data.exchangeNpcTrade.num);
			local IitemId = ClientBackpack:getGridItem(t_ad_data.exchangeNpcTrade.index);

			local def = ItemDefCsv:get(IitemId);
			text = GetS(3595, def.Name, t_ad_data.exchangeNpcTrade.num);

			StatisticsAD('finish', 4, {Name=def.Name, Num=t_ad_data.exchangeNpcTrade.num});
			ShowGameTips(text, 1);
			t_ad_data.exchangeNpcTrade = {};
		end
	end
end

-- 家园果实-看广告缩短果实成熟时间 广告位5
function OnReqWatchADShortenFruitTime(data, btnName)
	print("OnReqWatchADShortenFruitTime", data);
	if btnName == nil or btnName == 'right' then
		local position_id = 5
		if IsAdUseNewLogic(position_id) then
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
			if curWatchADType then
				ad_data_new.curAdCallData = { fruitIndex = data.fruitIndex }
				ad_data_new.curADCallBack = OnRespWatchADShortenFruitTime;
				
				GetInst("AdService"):Ad_StartPlay(position_id, function()
					Advertisement:request(curWatchADType, id, position_id)
				end)
			end					
		else
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(5);
			if curWatchADType then
				t_ad_data.curAdCallData = { fruitIndex = data.fruitIndex };
				t_ad_data.curADCallBack = OnRespWatchADShortenFruitTime;

				Advertisement:request(curWatchADType, id, 5)
			end
		end
	end
end
-- 家园果实-看广告缩短果实成熟时间：观看广告成功回调
function OnRespWatchADShortenFruitTime(data)
	print("OnRespWatchADShortenFruitTime data = ", data);
	local position_id = 5
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			print("AdService Ad_Finish callback", ad_info)
			if data and next(data) ~= nil then	
				if IsAdReportUseNewLogic(position_id) then
					if ad_info and ad_info.rewards and ad_info.rewards.ret == ErrorCode.OK then	
						-- 客户端主动更新数据	
						if AccountManager.data_update then
							AccountManager:data_update();
						end

						-- 使用广告服数据显示果实缩短时长			
						if ad_info.rewards.reduce_time then
							-- 提示果实缩短了多长时间
							ShowGameTips(GetS(4974, SecondTransforDesc(ad_info.rewards.reduce_time)));
						end

						-- 刷新UI					
						UpdateOneFruit(data.fruitIndex + 1);
						FruitInfoRequestChestReqResult();
						local chestInfosNum = HomeChestMgr:getChestInfosNum();
						UpdateAllFruit(chestInfosNum);
					end						
				else
					-- 使用账号服数据显示果实缩短时长
					local ad_info_old = AccountManager:ad_position_info(5);
					if ad_info_old and ad_info_old.extra then
						ShowGameTips( GetS(4974, SecondTransforDesc(ad_info_old.extra.value or 0)) );
					end
					AccountManager:ad_finish(position_id, data);

					UpdateOneFruit(data.fruitIndex + 1);

					FruitInfoRequestChestReqResult();
					local chestInfosNum = HomeChestMgr:getChestInfosNum();
					UpdateAllFruit(chestInfosNum);				
				end				
			end
		end, { fruitIndex = data and data.fruitIndex or 0 })
	elseif data and next(data.fruitInfo) ~= nil then
		print(data);
		local ad_info = AccountManager:ad_position_info(5);
		AccountManager:ad_finish(5, data);
		StatisticsAD('finish', 5);
		UpdateOneFruit(data.fruitIndex+1);
		
		FruitInfoRequestChestReqResult();
		local chestInfosNum = HomeChestMgr:getChestInfosNum();
		UpdateAllFruit(chestInfosNum);

		if ad_info and ad_info.extra then
			ShowGameTips( GetS(4974, SecondTransforDesc(ad_info.extra.value or 0)) );
		end
	end
end

-- 断连房间服务器看广告领取补偿奖励，分两种情况：
-- 被房主踢出房间-广告位6(已弃用)
-- 网络问题-广告位8(已弃用)
function OnReqWatchADRSConnectLost(data, btnName)
	print("OnReqWatchADRSConnectLost");
	if btnName == nil or btnName == 'right' then
		local position_id = data
		if IsAdUseNewLogic(position_id) then	
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id);
			if curWatchADType then
				getglobal("RSConnectLostFrame"):Hide();
				ad_data_new.curADCallBack = OnRespWatchADRSConnectLost;
	
				GetInst("AdService"):Ad_StartPlay(position_id, function()
					Advertisement:request(curWatchADType, id, position_id)
				end)
	
				if (position_id == 8) then
					RSConnectLostFrameConfirmBtn_OnClick();
				end
			end
		else
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(data);
			if curWatchADType then
				getglobal("RSConnectLostFrame"):Hide();	
				t_ad_data.curADCallBack = OnRespWatchADRSConnectLost;
	
				Advertisement:request(curWatchADType, id, data);
				
				if (data == 8) then
					RSConnectLostFrameConfirmBtn_OnClick();
				end
			end
		end
	end
end
-- 断连房间服务器看广告领取补偿奖励：观看广告成功回调
function OnRespWatchADRSConnectLost()
	print("OnRespWatchADRSConnectLost");
	local position_id = ad_data_new.lostConnectPosId;
	if IsAdUseNewLogic(position_id) then	
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id);
			if curWatchADType and id then
				if position_id == 6 then
					AccountManager:ad_finish(position_id, { platform_id = id });
				else
					AccountManager:ad_finish(position_id);
				end
	
				getglobal("RSConnectLostFrame"):Hide();
				ad_data_new.lostConnectPosId = 0;
			end
		end)
	else
		local position = t_ad_data.lostConnectPosId;
		if position == 6 then
			local _, id = t_ad_data.getWatchADIDAndType(6);
			local adPlatform = {platform_id = id}
			AccountManager:ad_finish(position,adPlatform);
		else
			AccountManager:ad_finish(position);
		end
	
		StatisticsAD('finish', position);
		getglobal("RSConnectLostFrame"):Hide();	
		t_ad_data.lostConnectPosId = 0;
	end
end

-- 活动-获得迷你豆-观看广告代替一次分享 广告位7
function OnReqWatchADGetMiniBean(data, btnName)
	print("OnReqWatchADGetMiniBean");
	if btnName == nil or btnName == 'right' then
		local position_id = 7
		if IsAdUseNewLogic(position_id) then	
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id);
			if curWatchADType then
				ad_data_new.curADCallBack = OnRespWatchADGetMiniBean;
				GetInst("AdService"):Ad_StartPlay(position_id, function()
					Advertisement:request(curWatchADType, id, position_id)
				end)
			end
		else
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(7);
			if curWatchADType then
				t_ad_data.curADCallBack = OnRespWatchADGetMiniBean;
	
				Advertisement:request(curWatchADType, id,7)
			end
		end
	end
end
-- 活动-获得迷你豆-观看广告代替一次分享：观看广告成功回调
function OnRespWatchADGetMiniBean()
	print("OnRespWatchADGetMiniBean");
	local position_id = 7
	if IsAdUseNewLogic(position_id) then	
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			if IsAdReportUseNewLogic(position_id) then
				if ad_info and ad_info.rewards then
					NotifyShareOrWatchAD_CallBack(ad_info.rewards)
				end
			else
				NotifyShareOrWatchAD(2);				
			end
			--StatisticsADNew('finish', position_id, ad_info);
		end)
	else
		AccountManager:ad_finish(7);
		StatisticsAD('finish', 7);
		print("NotifyShareOrWatchAD WatchAD");
		NotifyShareOrWatchAD(2);
	end
end

-- 活动-福利-广告商的赞助 9/27号通用领奖逻辑
function RequestWelfareAwardCallback(isSetChecked, task_id, pageId, cellId, btnUI, reward_list)
	-- 红点显示次数的限制累计
	local red_record = getkv(tostring(task_id),"red_repeat")
	if red_record then
		red_record.current_count = red_record.current_count or 0
		red_record.current_count = red_record.current_count + 1
		setkv(tostring(task_id), red_record, "red_repeat")
	end

	local bUse = false
	local MafBtnExtend = GameRewardFrameGetMafBtnExtend()
	if MafBtnExtend and MafBtnExtend.task_id then
		if MafBtnExtend.task_id == 'showad27' or MafBtnExtend.task_id == 'showad9' then
			bUse = true
		end
	end
	
	if reward_list and next(reward_list) then
		SetGameRewardFrameInfo( GetS(3403), reward_list, "", nil, nil, bUse);
	else
		ns_ma.func.requestAward( task_id, ns_ma.open_cell_id, cellId, bUse);
	end

	--将这个任务设置为已经领取
	local server_config_ = ns_ma.server_config[pageId][cellId]
	if ns_ma.reward_list[task_id] and ns_ma.reward_list[task_id].stat and server_config_ and
		(not server_config_.task_conditions or not server_config_.task_conditions.ad_press_cb) then
		ns_ma.reward_list[task_id].stat = 2;  --已经领取
	end
	if btnUI and btnUI.SetChecked then
		btnUI:SetChecked(isSetChecked); -- 设置按钮显示状态	
	end	
	ActivityMainCtrl:CheckRedTagForWelfare(true);

	--如果是continued任务 再次拉取福利
	if ns_ma.reward_list[task_id].static and ns_ma.reward_list[task_id].static.continued then
		ActivityMainCtrl:RequestWelfareRewardData("continued=1")
	end
end
-- 活动-福利-广告商的赞助 广告位9 
function OnReqWatchADWelfare9(task_id, pageId, cellId, ad_show, btnUI)
	print("OnReqWatchADWelfare9")
	local position_id = 9
	if IsAdUseNewLogic(position_id) then
		local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id);
		if curWatchADType then
			--运营数据后台上报
			StatisticsADNew(ad_show == "showad9" and 'againonclick' or 'onclick', position_id);
			--福利服上报
			local uin_ = AccountManager:getUin();
			if uin_ and uin_ >= 1000  then
				local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=ad_press_cb&ad_event=begin'
				reward_list_url_ = reward_list_url_ .. '&task_id=' .. task_id .. '&' .. http_getS1();
				print( reward_list_url_ );
				ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
			else
				print( "requestAward can not get uin_=",uin_);
			end
			ad_data_new.curAdCallData = {
				task_id = task_id or 0, 
				pageId = pageId or 0, 
				cellId = cellId or 0, 
				ad_show = ad_show or nil,
				btnUI = btnUI or nil
			}
			ad_data_new.curADCallBack = OnRespWatchADWelfare9;
			GetInst("AdService"):Ad_StartPlay(position_id, function()
				Advertisement:request(curWatchADType, id, position_id)
			end)
		end
	else
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
		if curWatchADType then
			--运营数据后台上报
			if ad_show == "showad9" then
				StatisticsAD('againonclick', position_id);
			else
				StatisticsAD('onclick', position_id);
			end
			--福利服上报
			local uin_ = AccountManager:getUin();
			if uin_ and uin_ >= 1000  then
				local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=ad_press_cb&ad_event=begin'
				reward_list_url_ = reward_list_url_ '&task_id=' .. task_id .. '&' .. http_getS1();
				print( reward_list_url_ );
				ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
			else
				print( "requestAward can not get uin_=",uin_);
			end

			t_ad_data.curAdCallData = {
				task_id = task_id or 0, 
				pageId = pageId or 0, 
				cellId = cellId or 0, 
				ad_show = ad_show or nil,				
				btnUI = btnUI or nil
			}
			t_ad_data.curADCallBack = OnRespWatchADWelfare9;
			Advertisement:request(curWatchADType, id, position_id)
		end
	end
end
function OnRespWatchADWelfare9(data)
	print("OnRespWatchADWelfare9 data = ", data)
	local position_id = 9
	local task_id = data and data.task_id or 0
	local randomidx = ns_ma.reward_random[task_id] or -1
	local pageId = data and data.pageId or 0
	local cellId = data and data.cellId or 0
	local ad_show = data and data.ad_show or ""
	local report_type = ad_show == "showad9" and 'againfinish' or 'finish'
	local btnUI = data and data.btnUI or nil

	--福利服上报
	local uin_ = AccountManager:getUin();
	if uin_ and uin_ >= 1000  then
		local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=ad_press_cb&ad_event=end'
		reward_list_url_ = reward_list_url_ .. '&task_id=' .. task_id ..  '&'  .. http_getS1();
		print( reward_list_url_ );
		ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
	else
		print( "OnRespWatchADWelfare9 can not get uin_=" ,uin_);
	end
	
	-- 刷新广告
	GameRewardFrameSetMafBtnExtendTaskId("showad9")
	GameRewardFrameSetMafBtnExtendADTaskId(task_id)

	if IsAdUseNewLogic(position_id) then
		--账号服控制广告次数用
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			local list = nil
			if IsAdReportUseNewLogic(position_id) and ad_info and ad_info.rewards and ad_info.rewards.reward_list then
				local reward_list = ad_info.rewards.reward_list
				list = GetRequestAwardList(task_id, ad_info.rewards.ret, reward_list.avatar_skin_to_minibean, reward_list.itemmap)
			end
			RequestWelfareAwardCallback(ad_data_new.canShow(position_id, ad_info, nil, true), task_id, pageId, cellId, btnUI, list)

			--看完广告拉下数据，刷新下状态
			ActivityMainCtrl:RequestWelfareRewardData("continued=1")
		end, {task_id = task_id, randomidx = randomidx}, {report_type = report_type})	
	else
		--运营数据后台上报
		if ad_show == "showad9" then
			StatisticsAD('againfinish', 9);
		else
			StatisticsAD('finish', 9);
		end

		--账号服控制广告次数用
		local _, id = t_ad_data.getWatchADIDAndType(9);
		AccountManager:ad_finish(9, {platform_id = id});
				
		-- 刷新广告
		RequestWelfareAwardCallback(t_ad_data.canShow(9, nil, true), task_id, pageId, cellId, btnUI)

		--看完广告拉下数据，刷新下状态
		ActivityMainCtrl:RequestWelfareRewardData("continued=1")
	end
end

-- 活动-福利-广告商的赞助-2 广告位27
function OnReqWatchADWelfare27(task_id, pageId, cellId, ad_show, btnUI)
	print("OnReqWatchADWelfare27")
	local position_id = 27
	if IsAdUseNewLogic(position_id) then
		local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id);
		if curWatchADType then
			--运营数据后台上报
			StatisticsADNew(ad_show == "showad27" and 'againonclick' or 'onclick', position_id);

			--福利服上报
			local uin_ = AccountManager:getUin();
			if uin_ and uin_ >= 1000  then
				local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=ad_press_cb&ad_event=begin';
				reward_list_url_ = reward_list_url_  .. "&task_id=" .. task_id .. '&' .. http_getS1()
				print( reward_list_url_ );
				ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
			else
				print( "requestAward27 can not get uin_=",uin_);
			end

			ad_data_new.curAdCallData = {
				task_id = task_id or 0, 
				pageId = pageId or 0, 
				cellId = cellId or 0, 
				ad_show = ad_show or nil,
				btnUI = btnUI or nil
			}
			ad_data_new.curADCallBack = OnRespWatchADWelfare27;
			GetInst("AdService"):Ad_StartPlay(position_id, function()
				Advertisement:request(curWatchADType, id, position_id)
			end)
		end
	else
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(27);
		if curWatchADType then
			--运营数据后台上报
			if ad_show == "showad27" then
				StatisticsAD('againonclick', position_id);
			else
				StatisticsAD('onclick', position_id);
			end

			--福利服上报
			local uin_ = AccountManager:getUin();
			if uin_ and uin_ >= 1000  then
				local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=ad_press_cb&ad_event=begin';
				reward_list_url_ = reward_list_url_  .. "&task_id=" .. task_id .. '&' .. http_getS1()
				print( reward_list_url_ );
				ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
			else
				print( "requestAward27 can not get uin_=",uin_);
			end
			
			t_ad_data.curAdCallData = {
				task_id = task_id or 0, 
				pageId = pageId or 0, 
				cellId = cellId or 0, 
				ad_show = ad_show or nil,
				btnUI = btnUI or nil
			}
			t_ad_data.curADCallBack = OnRespWatchADWelfare27;
			Advertisement:request(curWatchADType, id, position_id)
		end
	end
end
function OnRespWatchADWelfare27(data)
	print("OnRespWatchADWelfare27 data = ", data)
	local position_id = 27	
	local task_id = data and data.task_id or 0
	local randomidx = ns_ma.reward_random[task_id] or -1
	local pageId = data and data.pageId or 0
	local cellId = data and data.cellId or 0
	local ad_show = data and data.ad_show or ""	
	local report_type = ad_show == "showad9" and 'againfinish' or 'finish'
	local btnUI = data and data.btnUI or nil
	
	--福利服上报
	local uin_ = AccountManager:getUin();
	if uin_ and uin_ >= 1000  then
		local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=ad_press_cb&ad_event=end';
		reward_list_url_ = reward_list_url_ .. '&task_id=' .. task_id ..  '&'  .. http_getS1();		
		print( reward_list_url_ );
		ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
	else
		print( "OnRespWatchADWelfare9 can not get uin_=" ,uin_);
	end
	
	-- 刷新广告
	GameRewardFrameSetMafBtnExtendTaskId("showad27")
	GameRewardFrameSetMafBtnExtendADTaskId(task_id)
	
	if IsAdUseNewLogic(position_id) then
		--账号服控制广告次数用
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			-- 上报结算数据的接口
			local list = {}
			if IsAdReportUseNewLogic(position_id) then
				if ad_info and ad_info.rewards and ad_info.rewards.ret == 0 then
					list = ad_info.rewards.reward_list or nil
				end
			else
				--账号服控制广告次数用
				local _, id = GetInst("AdService"):GetAdTypeByAdId(position_id);
				local code, result = AccountManager:ad_finish(position_id, {platform_id = id});
				if result and next(result) then
					for i , v in ipairs(result) do
						list[i] = {id = v[1],num = v[2]}
					end
				end
			end
			ns_ma.reward_map[task_id] = list
			
			RequestWelfareAwardCallback(ad_data_new.canShow(position_id, ad_info, nil, true), task_id, pageId, cellId, btnUI, list)

			--看完广告拉下数据，刷新下状态
			ActivityMainCtrl:RequestWelfareRewardData("continued=1")
		end, {task_id = task_id, randomidx = randomidx}, {report_type = report_type})
	else
		--运营数据后台上报
		if ad_show == "showad27" then
			StatisticsAD('againfinish', 27);
		else
			StatisticsAD('finish', 27);
		end
		
		--账号服控制广告次数用		
		local _, id = t_ad_data.getWatchADIDAndType(27);
		local adPlatform = {platform_id = id}
		local code,result = AccountManager:ad_finish(27,adPlatform);
		local list = {}
		local index = 1
		if result then
			for i , v in ipairs(result) do
				list[index] = {id = v[1],num = v[2]}
				index = index + 1
			end
		end
		ns_ma.reward_map[task_id] = list
		
		RequestWelfareAwardCallback(t_ad_data.canShow(27, nil, true), task_id, pageId, cellId, btnUI)

		--看完广告拉下数据，刷新下状态
		ActivityMainCtrl:RequestWelfareRewardData("continued=1")
	end
end

-- 活动-插屏广告 广告位10
function OnReqWatchADActivityFrame()
	print("OnReqWatchADActivityFrame");
	local position_id = 10
	if IsAdUseNewLogic(position_id) then	
		local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id);
		if curWatchADType then
			--插屏广告，调用接口算一次曝光
			StatisticsADNew('show', position_id);
			if IsAdReportUseNewLogic(position_id) then
				GetInst("AdService"):Ad_Show(position_id)
			elseif AccountManager.ad_show then
				AccountManager:ad_show(position_id)
			end			
			GetInst("AdService"):Ad_StartPlay(position_id, function()
				ad_data_new.curADCallBack = OnRespWatchADActivityFrame;
				local ret = Advertisement:request(curWatchADType, id, position_id)
				print("Advertisement:request，ret = ", ret)
			end)
		end
	else
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(10);
		if curWatchADType then
			--插屏广告，调用接口算一次曝光
			StatisticsAD('show', 10);
			if AccountManager.ad_show then
				AccountManager:ad_show(10);
			end

			local rewardValue = AccountManager:ad_position_info(10).extra.value
			t_ad_data.curADCallBack = OnRespWatchADActivityFrame;
			Advertisement:request(curWatchADType, id, 10, rewardValue)
		end
	end
end
-- 活动-插屏广告：观看广告成功回调
function OnRespWatchADActivityFrame()
	print("OnRespWatchADActivityFrame");
	local position_id = 10
	if IsAdUseNewLogic(position_id) then	
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			if IsAdReportUseNewLogic(position_id) then
				if ad_info and ad_info.rewards and ad_info.rewards.ret == ErrorCode.OK and
					ad_info.rewards.reward_list and next(ad_info.rewards.reward_list) then
					SetGameRewardFrameInfo(GetS(3403), ad_info.rewards.reward_list)
				end
			else
				AccountManager:ad_finish(position_id);				
			end
		end)
	else
		AccountManager:ad_finish(10);
	end
end

-- 增长活动通用广告 : 判断广告能否展示，如果能则播放广告
-- position_id : 播放广告使用的广告位id（必须有）
-- report_id : 上报埋点使用的广告位（可选）
-- success_callback : 观看广告成功回调
-- fail_callback : 观看广告失败回调
function OnReqWatchADGrouthActivity(position_id, report_id, success_callback, fail_callback)
    if not position_id or position_id <= 0 then return end
	--增长活动通用广告观看广告成功回调
	local OnRespWatchADGrouthActivity = function()
		if IsAdUseNewLogic(position_id) then
			GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
				if success_callback and type(success_callback) == "function" then
					success_callback()
				end
			end)
		else
			AccountManager:ad_finish(position_id)
			StatisticsAD('finish', report_id or position_id)
			if success_callback and type(success_callback) == "function" then
				success_callback()
			end
		end
	end

	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):IsAdCanShow(position_id, function(result, ad_info)
			if result then
				ad_data_new.curADCallBack = OnRespWatchADGrouthActivity
				ad_data_new.curADFailedCallBack = fail_callback
				StatisticsADNew('onclick', report_id or position_id);
				GetInst("AdService"):Ad_StartPlay(position_id, function()
					local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
					if curWatchADType then
						Advertisement:request(curWatchADType, id, position_id)
					end
				end)
			else
				ShowGameTipsWithoutFilter(GetS(4977))
			end
		end)
	else
		if not t_ad_data.canShow(position_id) then
			ShowGameTipsWithoutFilter(GetS(4977))
			return
		end
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
		if curWatchADType then
			t_ad_data.curADCallBack = OnRespWatchADGrouthActivity
			t_ad_data.curADFailedCallBack = fail_callback
			StatisticsAD('onclick', report_id or position_id);
			Advertisement:request(curWatchADType, id, position_id)
		end
	end
end

-- 商城-福利商城-迷你点广告 广告位14/16/26
function OnReqWatchADMiniPoint(adBtnId, adInfo, isAgain, changePosId, isNotClick, report_id, isLottery)
	print("OnReqWatchADMiniPoint");
	
	local curAdPos = adInfo.adPosition
	if IsAdUseNewLogic(adInfo.adPosition) then	
		curAdPos = ad_data_new.getCanShowAdPosByMainId(26) or adInfo.adPosition;
	else
		curAdPos = t_ad_data.getCanShowAdPosByList(adInfo.newAdPos) or adInfo.adPosition;
	end

	local report_id = report_id or curAdPos
	if isAgain then
		report_id = 42
	elseif changePosId then
		report_id = changePosId
	end
	StatisticsADNew('onclick', report_id)

	if IsAdUseNewLogic(curAdPos) then	
		ad_data_new.curADCallBack = OnRespWatchADMiniPointNew;
		ad_data_new.curAdCallData = {
			adPos = curAdPos,
			isNotClick = isNotClick, 
			report_id = report_id, 
			isLottery = isLottery,
			userCb = adInfo.callBack
		};
		GetInst("AdService"):Ad_StartPlay(curAdPos, function()
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(curAdPos)
			local isSuccess = Advertisement:request(curWatchADType, id, curAdPos)
			if isSuccess == 1 then
				-- statisticsGameEventNew(42092, get_game_lang(),1,adBtnId);
			else
				-- statisticsGameEventNew(42092, get_game_lang(),2,adBtnId);
				GameRewardFrameSetMafBtnExtend(nil)
			end
		end)
	else
		t_ad_data.curADCallBack = OnRespWatchADMiniPoint;
		t_ad_data.curAdCallData =  {
			adPos = curAdPos,
			isNotClick = isNotClick, 
			report_id = report_id, 
			isLottery = isLottery,
			userCb = adInfo.callBack
		};
	
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(curAdPos);
		local isSuccess = Advertisement:request(curWatchADType, id, curAdPos)
		if isSuccess == 1 then
			-- statisticsGameEventNew(42092, get_game_lang(),1,adBtnId);
		else
			-- statisticsGameEventNew(42092, get_game_lang(),2,adBtnId);
			GameRewardFrameSetMafBtnExtend(nil)
		end
	end
end
function OnRespWatchADMiniPoint(data)
	print("OnRespWatchADMiniPoint data = ", data)
	local isLottery = data.isLottery or nil
	local isNotClick = data.isNotClick or nil
	local report_id = data.report_id or nil

	local curWatchADType, id = t_ad_data.getWatchADIDAndType(data.adPos);
	if curWatchADType then
		AccountManager:ad_finish(data.adPos, {platform_id = id});
	end
	
	local ctrl = GetInst("UIManager"):GetCtrl("ShopAdvert")
	if data.userCb then
		 data.userCb(isLottery, report_id)
	elseif ctrl then 
		ctrl:WatchAdRefreshUI(isLottery, report_id)
	end

	if not isNotClick then
		StatisticsAD('finish', report_id)		
	end
end
function OnRespWatchADMiniPointNew(data)
	print("OnRespWatchADMiniPointNew data = ", data)
	GetInst("AdService"):Ad_Finish(data.adPos, function(ad_info)
		local isLottery = data and data.isLottery or nil
		local report_id = data and data.report_id or nil
		if IsAdReportUseNewLogic(data.adPos) then
			if ad_info and ad_info.rewards and ad_info.rewards.ret == ErrorCode.OK then
				UpdateMiniPointWithTip(ad_info.rewards.reward_list)				
			end
		end

		local ctrl = GetInst("UIManager"):GetCtrl("ShopAdvert")
		if data.userCb then
			 data.userCb(isLottery, report_id)
		elseif ctrl then 
			ctrl:WatchAdRefreshUI(isLottery, report_id)
		end

	end, nil, { report_id = data and data.report_id or nil})
end

-- 悦享卡-观看广告领取额外奖励 广告位29 
-- report_id：用于埋点的广告位，默认位29号
function OnReqWatchADBPMission(report_id, curBtn, isDailyMission)
    local position_id = 29
    if not report_id then report_id = position_id end -- 用于埋点上报的广告位
    print("OnReqWatchADBPMission report_id = ", report_id)
    
    if IsAdUseNewLogic(position_id) then
		StatisticsADNew('onclick', report_id)
        ad_data_new.curADCallBack = OnRespWatchADBPMission;
        ad_data_new.curADFailedCallBack = OnRespWatchADBPMission_Failed
        ad_data_new.curAdCallData = {
			adPos = position_id,
			curBtn = curBtn,
			report_id = report_id,
			isDailyMission = isDailyMission
		};

        GetInst("AdService"):Ad_StartPlay(position_id, function()
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
            local isSuccess = Advertisement:request(curWatchADType, id, position_id)
            standReportEvent("55", "NEW_BP_TASK_ADVERTISE", "Watch", "ad_play")
            print("Advertisement:request result = ", isSuccess)
        end)
    else
        StatisticsAD('onclick', report_id)
        t_ad_data.curADCallBack = OnRespWatchADBPMission;
        t_ad_data.curADFailedCallBack = OnRespWatchADBPMission_Failed
        t_ad_data.curAdCallData = {
			adPos = position_id,
			curBtn = curBtn,
			report_id = report_id,
			isDailyMission = isDailyMission
		};

        local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
        local isSuccess = Advertisement:request(curWatchADType, id, position_id)
        standReportEvent("55", "NEW_BP_TASK_ADVERTISE", "Watch", "ad_play")
        print("Advertisement:request result = ", isSuccess)
    end
end
-- 悦享卡广告 观看广告成功回调
function OnRespWatchADBPMission(data)
	local position_id = 29
	local curBtn = data and data.curBtn or nil
	local report_id = data and data.report_id or position_id
	local isDailyMission = data and data.isDailyMission or nil
	local extra_info = {
		taskid     = curBtn and curBtn:GetClientUserData(0) or 0,
		groupid    = curBtn and curBtn:GetClientUserData(1) or 0,
		grouptype  = curBtn and curBtn:GetClientUserData(2) or 0,
		value      = curBtn and curBtn:GetClientUserData(3) or 0,
		adid       = 1
	}
	print("OnRespWatchADBPMission data =", data)
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			-- 上报结算数据的接口
			if IsAdReportUseNewLogic(data.adPos) then
				if curBtn and ad_info and ad_info.rewards and ad_info.rewards.ret == ErrorCode.OK then
					GetInst("UIManager"):GetCtrl("NewBattlePassMission"):MissionToGetAward(true, curBtn, ad_info.rewards, isDailyMission)
				end
			elseif curBtn then
				GetInst("UIManager"):GetCtrl("NewBattlePassMission"):MissionToGetAward(true, curBtn, nil, isDailyMission)
			end
			standReportEvent("55", "NEW_BP_TASK_ADVERTISE", "Watch", "ad_complete")
		end, extra_info, { report_id = report_id })
	else
		if curBtn then
			GetInst("UIManager"):GetCtrl("NewBattlePassMission"):MissionToGetAward(true, curBtn, nil, isDailyMission)
		end
		standReportEvent("55", "NEW_BP_TASK_ADVERTISE", "Watch", "ad_complete")
		StatisticsAD('finish', report_id)	
		threadpool:work(function()
			AccountManager:ad_finish(position_id)
		end)	
	end
end
-- 悦享卡广告 观看广告失败回调
function OnRespWatchADBPMission_Failed(data)
	local position_id = 29
	local curBtn = data and data.curBtn or nil
	local isDailyMission = data and data.isDailyMission or nil
	if curBtn then
		-- 播放失败直接领任务奖励
		GetInst("UIManager"):GetCtrl("NewBattlePassMission"):MissionToGetAward(nil, curBtn, nil, isDailyMission)
	end
end

-- 冒险地图心愿商人-观看广告领取商品 广告位30
function OnReqWatchADNPCPurchaseGoods(data)
	if not ClientCurGame:isInGame() then return end
	local position_id = 30
	local ItemId = data and data.item_id or 0
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):IsAdCanShow(position_id, function(result, ad_info)
			if result then
				GetInst("AdService"):Ad_StartPlay(position_id, function()
					ad_data_new.curAdCallData = data
					ad_data_new.curADCallBack = OnRespWatchADNPCPurchaseGoods
					local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
					-- 广告埋点上报说明：1301是按钮点击的上报
					StatisticsADNew('onclick', position_id);
					standReportEvent(407, "ADVERTISERS_NEW_ITEMDETAILS", "AdPlay", "ad_play", { standby1 = ItemId })
					if curWatchADType then					
						Advertisement:request(curWatchADType, id, position_id)		
					end
				end)
			else
				ShowGameTips(GetS(4980), 3)
			end
		end)
	else
		if t_ad_data.canShow(position_id) then
			t_ad_data.curAdCallData = { ItemId = ItemId }
			t_ad_data.curADCallBack = OnRespWatchADNPCPurchaseGoods
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id)
			Advertisement:request(curWatchADType, id, position_id)
			-- 广告埋点上报说明：1301是按钮点击的上报
			statisticsGameEventNew(1301, id or "", position_id, "", "", "", GetCurrentCSRoomId());
			standReportEvent(407, "ADVERTISERS_NEW_ITEMDETAILS", "AdPlay", "ad_play", { standby1 = ItemId })
		else
			ShowGameTips(GetS(4980), 3)
		end
	end	
end
-- 冒险地图心愿商人-观看广告领取商品 观看广告成功回调
function OnRespWatchADNPCPurchaseGoods(data)
	if not ClientCurGame:isInGame() then return end
	local position_id = 30
	local ItemId = data and data.item_id or 0
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			-- 埋点上报
			standReportEvent(407, "ADVERTISERS_NEW_ITEMDETAILS", "AdPlay", "ad_complete", { standby1 = ItemId })

			-- 上报结算数据的接口
			if IsAdReportUseNewLogic(position_id) then
				if ad_info and ad_info.rewards and ad_info.rewards.ret == ErrorCode.OK then
					GetInst("UIManager"):GetCtrl("ShopAdNpc"):WatchAdPurchaseGoodCB(ad_info.rewards)
				end
			else
				GetInst("UIManager"):GetCtrl("ShopAdNpc"):WatchAdPurchaseGood()				
			end
		end, data)
	else
		AccountManager:ad_finish(position_id)
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id)
		statisticsGameEventNew(1302, id or "", 30, "", "", "", GetCurrentCSRoomId());
		standReportEvent(407, "ADVERTISERS_NEW_ITEMDETAILS", "AdPlay", "ad_complete", { standby1 = ItemId })

		-- 领取奖励逻辑处理
		GetInst("UIManager"):GetCtrl("ShopAdNpc"):WatchAdPurchaseGood()	
	end
end

-- 冒险地图心愿商人-观看广告免费刷新商品列表 广告位31
function OnReqWatchADNPCRefreshGoods()
	if not ClientCurGame:isInGame() then return end
	local position_id = 31
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):IsAdCanShow(position_id, function(result, ad_info)
			if result then
				GetInst("AdService"):Ad_StartPlay(position_id, function()
					ad_data_new.curADCallBack = OnRespWatchADNPCRefreshGoods
					local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
					standReportEvent(407, "ADVERTISERS_NEW_ITEMDETAILS", "AdPlay", "ad_play")
					StatisticsADNew('onclick', position_id);
					if curWatchADType then
						Advertisement:request(curWatchADType, id, position_id)
					end
				end)
			else
				ShowGameTips(GetS(4980), 3)
			end
		end)
	else
		if t_ad_data.canShow(position_id) then
			t_ad_data.curADCallBack = OnRespWatchADNPCRefreshGoods
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
			standReportEvent(407, "ADVERTISERS_NEW_REFRESHTIME", "Advert", "ad_play")
			statisticsGameEventNew(1301, id or "", position_id, "", "", "", GetCurrentCSRoomId());
			Advertisement:request(curWatchADType, id, position_id)
		else
			ShowGameTips(GetS(4980), 3)
		end		
	end	
end
-- 冒险地图心愿商人-观看广告免费刷新商品列表 观看广告成功回调
function OnRespWatchADNPCRefreshGoods()
	if not ClientCurGame:isInGame() then return end
	local position_id = 31
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			standReportEvent(407, "ADVERTISERS_NEW_REFRESHTIME", "Advert", "ad_complete")
			-- 刷新商品列表
			GetInst("UIManager"):GetCtrl("ShopAdNpc"):WatchADNPCRefreshGoodsList()
		end)
	else
		AccountManager:ad_finish(position_id)
		standReportEvent(407, "ADVERTISERS_NEW_REFRESHTIME", "Advert", "ad_complete")

		local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id)
		statisticsGameEventNew(1302, id or "", position_id, "", "", "", GetCurrentCSRoomId());

		-- 刷新商品列表
		GetInst("UIManager"):GetCtrl("ShopAdNpc"):WatchADNPCRefreshGoodsList()
	end
end

-- 活动-幸运方块- 32 幸运方块观看广告免费闯关 33幸运方块观看广告复活
function OnReqWatchADLuckSquarePlayAd(position_id, callBack, reportEventCallBackTbl)
	print("OnRespWatchADLuckSquarePlayAd position_id = ", position_id)
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_StartPlay(position_id, function()
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
			ad_data_new.curADCallBack = OnRespWatchADLuckSquarePlayAd;
			ad_data_new.curAdCallData = {
				position_id = position_id,
				callBack = callBack,
				reportEventCallBackTbl = reportEventCallBackTbl
			}
			--statisticsGameEventNew(1301, id, position_id,"","","",GetCurrentCSRoomId())
			StatisticsADNew('onclick', position_id)
			if reportEventCallBackTbl and reportEventCallBackTbl.click then
				reportEventCallBackTbl.click()
			end
			local isSuccess = Advertisement:request(curWatchADType, id, position_id)
			if reportEventCallBackTbl and reportEventCallBackTbl.ad_play then
				reportEventCallBackTbl.ad_play()
			end
		end)
	else
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
		t_ad_data.curADCallBack = OnRespWatchADLuckSquarePlayAd;
		t_ad_data.curAdCallData = {
			position_id = position_id,
			callBack = callBack,
			reportEventCallBackTbl = reportEventCallBackTbl
		}
		statisticsGameEventNew(1301, id, position_id,"","","",GetCurrentCSRoomId())
		if reportEventCallBackTbl and reportEventCallBackTbl.click then
			reportEventCallBackTbl.click()
		end

		local isSuccess = Advertisement:request(curWatchADType, id, position_id)
		if reportEventCallBackTbl and reportEventCallBackTbl.ad_play then
			reportEventCallBackTbl.ad_play()
		end
	end
end
-- 活动-幸运方块 观看广告成功回调
function OnRespWatchADLuckSquarePlayAd(data)
	print("OnRespWatchADLuckSquarePlayAd data = ", data)
	local position_id = data.position_id or 0
	local callBack = data.callBack or nil
	local reportEventCallBackTbl = data.reportEventCallBackTbl or nil
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			if reportEventCallBackTbl and reportEventCallBackTbl.ad_complete then
				reportEventCallBackTbl.ad_complete()
			end

			-- 上报结算数据的接口
			if IsAdReportUseNewLogic(position_id) then
				if ad_info and ad_info.rewards and ad_info.rewards.ret == ErrorCode.OK then
					if position_id == 32 then
						-- 幸运方块观看广告免费闯关
						LuckSquare_RequestEnterGameCB(ad_info.rewards)
					elseif position_id == 33 then
						-- 幸运方块观看广告复活
						GetInst("UIManager"):GetCtrl("LuckSquareRevive"):RequestWatchAdReviveCB(ad_info.rewards, 1)						
					end
				end
			else
				if position_id == 32 then
					-- 幸运方块观看广告免费闯关
					LuckSquare_RequestEnterGame(true, 1)
				elseif position_id == 33 then
					-- 幸运方块观看广告复活
					GetInst("UIManager"):GetCtrl("LuckSquareRevive"):RequestWatchAdRevive(1)					
				end	
			end

			if callBack then
				callBack()
			end
		end, {type = 1})
	else
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
		statisticsGameEventNew(1302, id, position_id,"","","","","",GetCurrentCSRoomId())	
		AccountManager:ad_finish(position_id, {platform_id = id})
		if reportEventCallBackTbl and reportEventCallBackTbl.ad_complete then
			reportEventCallBackTbl.ad_complete()
		end
		
		if position_id == 32 then
			-- 幸运方块观看广告免费闯关
			LuckSquare_RequestEnterGame(true, 1)
		elseif position_id == 33 then
			-- 幸运方块观看广告复活
			GetInst("UIManager"):GetCtrl("LuckSquareRevive"):RequestWatchAdRevive(1)					
		end	

		if callBack then
			callBack()
		end
	end	
end

-- 商城-福利商店-迷你点离线收益广告 广告位36
function OnReqWatchADRevenue(ad_id)
	print("OnReqWatchADRevenue position_id = 36, ad_id = ", ad_id)
	local position_id = 36
	StatisticsADNew('onclick', ad_id or position_id)
	local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
	if curWatchADType then
        ad_data_new.curADCallBack = OnRespWatchADRevenue;
        ad_data_new.curAdCallData = { position = position_id, report_id = ad_id or position_id };
        GetInst("AdService"):Ad_StartPlay(position_id, function()				
            local issuccess = Advertisement:request(curWatchADType, id, position_id)
            print("广告位"..position_id.." Advertisement:request 迷你点离线收益广告", issuccess)
			
        end)
    end
end
-- 商城-福利商店-迷你点离线收益：观看广告成功回调
function OnRespWatchADRevenue(data)
	print("OnReqWatchADRevenue data = ", data)
	local position_id = 36
	local report_id = (data and data.report_id) and data.report_id or position_id
	local reward_type = nil
	local shopAdvertCtrl = GetInst("UIManager"):GetCtrl("ShopAdvert")
	if shopAdvertCtrl and shopAdvertCtrl.model then
		local info = shopAdvertCtrl.model:GetAccumulateInfo()
		reward_type = (info and info.normal_reward) and 3 or 2 --领取奖励类型
	end
	-- 客户端请求福利服发奖
	GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
		if IsAdReportUseNewLogic(position_id) then
			local ret = ad_info and ad_info.rewards or nil
			if ret and ret.ret == ErrorCode.OK then
				if GetInst("UIManager"):GetCtrl("ShopAdvert") then
					GetInst("UIManager"):GetCtrl("ShopAdvert").model:SetAccumulateInfo(nil)						
				end
				-- 展示UI并监听迷你点变化
				UpdateMiniPointWithTip(ad_info.rewards.reward_list)	
			end
		else
			GetInst("UIManager"):GetCtrl("ShopAdvert"):AccumulateBtn_WatchAdCB()			
		end
	end, {tag = 1, reward_type = reward_type}, { report_id = report_id})
end

--存档界面看广告领取奖励 广告位21(已弃用)
function OnReqWatchAD21ReceiveAwards()
	print("OnReqWatchAD21ReceiveAwards")
	local position_id = 21
	if IsAdUseNewLogic(position_id) then
		local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
		if  curWatchADType then
			print( "curWatchADType=" .. curWatchADType .. ", id=" .. id )
			ad_data_new.curADCallBack = OnRespWatchAD21ReceiveAwards;
			StatisticsADNew('onclick', position_id);
			GetInst("AdService"):Ad_StartPlay(position_id, function()
				Advertisement:request(curWatchADType, id, position_id)
			end)
		else
			print("no curWatchADType") --无广告
		end
	else
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(21);
		if curWatchADType then
			print( "curWatchADType=" .. curWatchADType .. ", id=" .. id )
			t_ad_data.curADCallBack = OnRespWatchAD21ReceiveAwards;
			StatisticsAD('onclick', 21);
			Advertisement:request(curWatchADType, id, 21)
		else
			print("no curWatchADType") --无广告
		end
	end	
end
-- 存档界面看广告领取奖励 观看广告成功回调
function OnRespWatchAD21ReceiveAwards()
	print("OnRespWatchAD21ReceiveAwards")
	local position_id = 21
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			LobbyFrame21ADBtnCanShow();
		end)
	else
		StatisticsAD('finish', position_id);
		AccountManager:ad_finish(position_id);
		LobbyFrame21ADBtnCanShow();
	end
end

-----------------------------------------开发者广告逻辑----------------------------------------------
-- 开发者商城广告 广告位101
function OnReqWatchADDeveloperShop(data, btnName, entryType)
	print("OnReqWatchADDeveloperShop entryType = ", entryType)
	if btnName == nil or btnName == 'right' then	
		local position_id = 101
		if IsAdUseNewLogic(position_id) then
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
			if curWatchADType then
				ad_data_new.curADCallBack = OnResWatchADDeveloperShop;
				ad_data_new.entryType = entryType;

				GetInst("AdService"):Ad_StartPlay(position_id, function()
						
					local authUin,mapId,itemId = getCurItemSimpleInfos()
					StatisticsADNew('load', position_id, nil, authUin, mapId, itemId)

					local ret = Advertisement:request(curWatchADType,id,position_id)

					if entryType == "Pass" then
						Advertisement:onRespWatchAdForAudit(1001);
						return;
					end

					if ClientMgr:getApiId() == 999 then
						-- SVN端看广告直接下发奖励
						local uin = AccountManager:getUin() or 0;
						if DeveloperAdCheckerUser(uin) then
							Advertisement:onRespWatchAdForAudit(1001);
							print("999 developer ad store success")
						end
						return;
					end

					if ret ~= 0 and ret ~= 2 then
						StatisticsADNew('ready', position_id, nil, authUin, mapId, itemId)
						--新埋点，根据不同来源做不同上报
						if mapId == nil or mapId == 0 then
							mapId = G_GetFromMapid()
						end
						local extra = {cid = tostring(mapId), standby3 = position_id}
						if "DeveloperStore" == ad_data_new.entryType then
							standReportEvent("6001", "PROP_DETAILS", "AdPurchaseButton", "ad_play", extra)
						end
						if "TopPurchaseInMap" == ad_data_new.entryType then
							standReportEvent("1003", "FAST_PURCHASE_POPUP", "AdPurchaseButton", "ad_play", extra)
						end
						if "TopPurchaseInMapOnline" == ad_data_new.entryType then
							standReportEvent("1001", "FAST_PURCHASE_POPUP", "AdPurchaseButton", "ad_play", extra)
						end
					end
				end)
			end
		else
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
			if curWatchADType then
				t_ad_data.curADCallBack = OnResWatchADDeveloperShop;
				t_ad_data.entryType = entryType;
				local authUin,mapId,itemId = getCurItemSimpleInfos()
				StatisticsAD('load',position_id,nil,authUin,mapId,itemId)
				local ret = Advertisement:request(curWatchADType,id,position_id)

				if entryType == "Pass" then
					Advertisement:onRespWatchAdForAudit(1001);
					return;
				end
				if ClientMgr:getApiId() == 999 then
					-- SVN端看广告直接下发奖励
					local uin = AccountManager:getUin() or 0;
					if DeveloperAdCheckerUser(uin) then
						Advertisement:onRespWatchAdForAudit(1001);
						print("999 developer ad store success")
					end
					return;
				end

				if ret ~= 0 and ret ~= 2 then
					StatisticsAD('ready',position_id,nil,authUin,mapId,itemId)
					--新埋点，根据不同来源做不同上报
					if mapId == nil or mapId == 0 then
						mapId = G_GetFromMapid()
					end
					local extra = {cid = tostring(mapId), standby3 = position_id}
					if "DeveloperStore" == t_ad_data.entryType then
						standReportEvent("6001", "PROP_DETAILS", "AdPurchaseButton", "ad_play", extra)
					end
					if "TopPurchaseInMap" == t_ad_data.entryType then
						standReportEvent("1003", "FAST_PURCHASE_POPUP", "AdPurchaseButton", "ad_play", extra)
					end
					if "TopPurchaseInMapOnline" == t_ad_data.entryType then
						standReportEvent("1001", "FAST_PURCHASE_POPUP", "AdPurchaseButton", "ad_play", extra)
					end
				end
			end
		end
	end
end
-- 开发者商城广告 观看广告成功回调
function OnResWatchADDeveloperShop()
	print("OnResWatchADDeveloperShop")

	--开发者商城广告看完广告触发触发器
	local propDef = GetInst("DevelopStoreDataManager"):GetCurClickPropDef()

	local position_id = 101
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			--开发者商城广告走推送 --test老广告
			-- DeveloperStoreAdGetItem(false, ad_data_new.entryType)
		end)
	else
		DeveloperStoreAdGetItem(false, t_ad_data.entryType)
	end
	getglobal("DeveloperStoreBuyItemFrame"):Hide();
end

--开发者通行证看广告 广告位：103
function OnReqWatchADGetPassPort(data, btnName)
	print("OnReqWatchADGetPassPort")
	if btnName == nil or btnName == 'right' then
		-- 鸿蒙渠道
		if ClientMgr and ClientMgr:getApiId() == 5 then
			ShowGameTips(GetS(100512), 3)
			return
		end

		local position_id = 103
		if IsAdUseNewLogic(position_id) then
			GetInst("AdService"):Ad_StartPlay(position_id, function()
				local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
				if curWatchADType then
					ad_data_new.curADCallBack = OnRespWatchADGetPassPort
	
					local authUin,mapId,itemId = getCurItemSimpleInfos()
					StatisticsADNew('load', position_id, nil, authUin, mapId, itemId)
	
					local ret = Advertisement:request(curWatchADType, id, position_id)
	
					if ClientMgr:getApiId() == 999 then
						-- SVN端看广告直接下发奖励
						local uin = AccountManager:getUin() or 0;
						if DeveloperAdCheckerUser(uin) then
							Advertisement:onRespWatchAdForAudit(1001);
							print("999 developer ad passport success")
						end
						return;
					end
	
					if ret ~= 0 and ret ~= 2 then
						StatisticsADNew('ready', position_id, nil, authUin, mapId, itemId)
						AD_StandReportEvent("MAP_PASS_POPUP", "AdPlayPurchase", "ad_play", {cid=tostring(mapId), standby3 = position_id})--新埋点
					end
				end
			end)		
		else
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
			if curWatchADType then
				t_ad_data.curADCallBack = OnRespWatchADGetPassPort
				local authUin,mapId,itemId = getCurItemSimpleInfos()
				StatisticsAD('load', position_id, nil, authUin, mapId, itemId)
				local ret = Advertisement:request(curWatchADType, id, position_id)

				if ClientMgr:getApiId() == 999 then
					-- SVN端看广告直接下发奖励
					local uin = AccountManager:getUin() or 0;
					if DeveloperAdCheckerUser(uin) then
						Advertisement:onRespWatchAdForAudit(1001);
						print("999 developer ad passport success")
					end
					return;
				end

				if ret ~= 0 and ret ~= 2 then
					StatisticsAD('ready', position_id, nil, authUin, mapId, itemId)
					AD_StandReportEvent("MAP_PASS_POPUP", "AdPlayPurchase", "ad_play", {cid=tostring(mapId), standby3 = position_id})--新埋点
				end
			end
		end
	end
end
--开发者通行证看广告 观看广告成功回调
function OnRespWatchADGetPassPort()
	print("OnRespWatchADGetPassPort")
	local position_id = 103
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			DeveloperStoreAdGetItem(true, DeveloperStoreAdGetItem)
			local authUin,mapId,itemId = getCurItemSimpleInfos()
			AD_StandReportEvent("MAP_PASS_POPUP", "AdPlayPurchase", "ad_complete", {cid=tostring(mapId), standby3 = position_id})--新埋点	
		end)
	else
		DeveloperStoreAdGetItem(true, DeveloperStoreAdGetItem)
		local authUin,mapId,itemId = getCurItemSimpleInfos()
		StatisticsAD('finish', position_id, nil, authUin, mapId, itemId)
		AD_StandReportEvent("MAP_PASS_POPUP", "AdPlayPurchase", "ad_complete", {cid=tostring(mapId), standby3 = position_id})--新埋点	
	end
end

-- 开发者资源工坊解锁商品广告 广告位：104
function OnReqWatchADByResourceShopUnlockGoods(callBack)
	print("OnReqWatchADByResourceShopUnlockGoods")

	local position_id = 104

	-- 开发者资源工坊解锁商品广告观看广告成功回调
	local ad_finishCallBack = function()
		print("OnRespWatchADByResourceShopUnlockGoodsNew")
		if IsAdUseNewLogic(position_id) then
			GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
				AccountManager:ad_finish(position_id);
				if callBack then
					callBack()
				end
			end)
		else
			StatisticsAD('finish', position_id);
			AccountManager:ad_finish(position_id);
			if callBack then
				callBack()
			end
		end		
	end

	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_StartPlay(position_id, function()
			ad_data_new.curADCallBack = ad_finishCallBack
			StatisticsADNew('onclick', position_id);
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
			if curWatchADType then
				local ret = Advertisement:request(curWatchADType, id, position_id)
				if ret ~= 0 and ret ~= 2 then
					StatisticsADNew('ready', position_id)
				end
			end
		end)
	else
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
		if curWatchADType then
			t_ad_data.curADCallBack = ad_finishCallBack;
			StatisticsAD('onclick', position_id);
			local ret = Advertisement:request(curWatchADType, id, position_id)
			if ret ~= 0 and ret ~= 2 then
				StatisticsAD('ready', position_id)
			end
		end
	end
end

-- NPC商城商品看广告 广告位：109
function OnReqWatchADNpcShop(data, btnName)
	print("OnReqWatchADNpcShop")
	if btnName == nil or btnName == 'right' then
		local position_id = 109
		if IsAdUseNewLogic(position_id) then
			GetInst("AdService"):IsAdCanShow(position_id, function(result, ad_info)
				if result then
					GetInst("AdService"):Ad_StartPlay(position_id, function()
						local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
						if curWatchADType then
		
							ad_data_new.curADCallBack = OnResWatchADNpcShop
		
							local authUin,mapId,itemId = getCurItemSimpleInfos()
							StatisticsADNew('load',position_id,nil,authUin,mapId,itemId)
				
							local ret = Advertisement:request(curWatchADType,id,position_id)
							if ClientMgr:getApiId() == 999 then
								-- SVN端看广告直接下发奖励
								NpcShopAdGetItem()
								getglobal("NpcShopBuyFrame"):Hide()
								return;
							end
				
							if ret ~= 0 and ret ~= 2 then
								StatisticsADNew('ready', position_id, nil, authUin, mapId, itemId)
								--新埋点
								if mapId == nil or mapId == 0 then
									mapId = G_GetFromMapid()
								end
								local extra = {cid = tostring(mapId), standby1 = position_id}
								standReportEvent("1011", "PROP_DETAILS", "AdPurchaseButton", "ad_play", extra)
							end
						end
					end)
				else
					ShowGameTipsWithoutFilter(GetS(4977))
				end
			end)			
		else
			if not t_ad_data.canShow(position_id) then
				ShowGameTips(GetS(4980));
				return
			end

			local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
			if curWatchADType then
				t_ad_data.curADCallBack = OnResWatchADNpcShop;
				local authUin,mapId,itemId = getCurItemSimpleInfos()
				StatisticsAD('load',position_id,nil,authUin,mapId,itemId)
				local ret = Advertisement:request(curWatchADType,id,position_id)

				if ClientMgr:getApiId() == 999 then
					-- SVN端看广告直接下发奖励
					NpcShopAdGetItem()
					getglobal("NpcShopBuyFrame"):Hide()
					return;
				end

				if ret ~= 0 and ret ~= 2 then
					StatisticsAD('ready',position_id,nil,authUin,mapId,itemId)
					--新埋点
					if mapId == nil or mapId == 0 then
						mapId = G_GetFromMapid()
					end
					local extra = {cid = tostring(mapId), standby1 = position_id}
					standReportEvent("1011", "PROP_DETAILS", "AdPurchaseButton", "ad_play", extra)
				end
			end		
		end
	end
end
-- NPC商城商品看广告观看完成回调
function OnResWatchADNpcShop()
	print("OnResWatchADNpcShop")
	local position_id = 109
	local mapId = GetFromMapid()
	if IsAdUseNewLogic(position_id) then    
		GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
			NpcShopAdGetItem()
			getglobal("NpcShopBuyFrame"):Hide();
			--新埋点
			local extra = {cid = tostring(mapId), standby1 = position_id}
			standReportEvent("1011", "PROP_DETAILS", "AdPurchaseButton", "ad_complete", extra)
		end)
	else
		NpcShopAdGetItem()
		getglobal("NpcShopBuyFrame"):Hide();
		--新埋点
		local extra = {cid = tostring(mapId), standby1 = position_id}
		standReportEvent("1011", "PROP_DETAILS", "AdPurchaseButton", "ad_complete", extra)
	end
end

-- 开发者商城-福利广告 广告位待定
--[[
	OnReqWatchAdDeveloperWelfare(广告位, {
		ad_play = function()
			-- 播放广告埋点
		end,
		ad_complete = function()
			-- 播放广告完成埋点
		end
	})
]]
function OnReqWatchAdDeveloperWelfare(position_id, callbackList)
	local callbackList = callbackList or {}
	print("OnReqWatchAdDeveloperWelfare position_id = ", position_id)
	GetInst("AdService"):Ad_StartPlay(position_id, function()
		local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
		if curWatchADType then
			ad_data_new.curAdCallData = { 
				position_id = position_id,
				ad_complete = callbackList.ad_complete or nil
			 }
			ad_data_new.curADCallBack = OnRespWatchAdDeveloperWelfare
			ad_data_new.curADFailedCallBack = OnRespWatchAdDeveloperWelfare_Failed
			Advertisement:request(curWatchADType, id, position_id)
			if callbackList.ad_play and type(callbackList.ad_play) == 'function' then
				callbackList.ad_play()
			end
		end
	end)
end
-- 开发者商城-福利广告 播放广告成功回调
function OnRespWatchAdDeveloperWelfare(data)
	print("OnReqWatchAdDeveloperWelfare data = ", data)
	local position_id = data and data.position_id or 0
	local ad_complete = data and data.ad_complete or nil
	GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
		if ad_complete and type(ad_complete) == 'function' then
			ad_complete()
		end
	end)
end
-- 开发者商城-福利广告 播放广告失败回调
function OnRespWatchAdDeveloperWelfare_Failed()
	
end

-----------------------------------------开发者触发器广告逻辑----------------------------------------------
-- 开发者触发器广告 广告位102 ：激励视频, 广告位106：插屏视频, 广告位107：H5广告  广告位108：插屏图片

-- 触发器广告播放成功回调
function TriggerToPlayADNew_SuccessCallback(position_id, reportInfo, success, failed)
	print("TriggerToPlayADNew_SuccessCallback position_id = ", position_id);
	ad_data_new.curADCallBack = nil;
	ad_data_new.curADFailedCallBack = nil;

	GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
		local mapid = GetFromMapid()
		SetPlayerPurchaseFlag(true, 4, 1);

		if reportInfo then
			reportInfo.mapid = tostring(mapid)
		end

		-- 上报给老的账号服
		local ret = AccountManager:ad_finish(position_id, reportInfo or {})
		print("AccountManager:ad_finish: ret: ", ret);
		print("AccountManager:ad_finish: ErrorCode.OK:", ErrorCode.OK);
		if ret == ErrorCode.OK then
			if success then
				success();
			end
		else
			if failed then
				failed(ret);
			end
		end
	end)
end

-- 触发器广告播放失败回调
function TriggerToPlayADNew_FailedCallback(position_id, failed)
	print("TriggerToPlayADNew_FailedCallback position_id = ", position_id);
	ad_data_new.curADCallBack = nil;
	ad_data_new.curADFailedCallBack = nil;

	if ad_trigger_tip_switch() then
		ShowGameTips(GetS(32002))
		if failed then
			failed();
		end
	else
		MessageBox(4, GetS(32002), function()
			if failed then
				failed();
			end
		end)
	end
end

--触发器播放广告, 102/107号广告
function TriggerToPlayADNew(position_id, reportInfo, success, failed, gameType, exData)
	
	ad_data_new.curADCallBack = function()
		TriggerToPlayADNew_SuccessCallback(position_id, reportInfo, success, failed)
	end
	ad_data_new.curADFailedCallBack = function()
		TriggerToPlayADNew_FailedCallback(position_id, failed)
	end

	local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
	if curWatchADType then
		local mapid = GetFromMapid()
		StatisticsADNew('onclick', position_id, nil, '', mapid, '')
	
		-- 107 H5广告直接打开链接
		if position_id == 107 then
			local url = nil
			local ad_info = GetInst("AdService"):GetAdInfoByPosId(position_id)
			if ad_info and ad_info.AD_URL and #ad_info.AD_URL > 0 then
				local ok, json = pcall(JSON.decode, JSON, ad_info.AD_URL)
				if ok then
					local tab = {}
					for key, value in pairs(json) do
						table.insert(tab, value)
					end
					local len = #json
					if #tab == 1 then
						url = tab[1]
					else
						url = tab[math.random(1,#tab)]
					end
				end 
			end
			if url then
				g_openBrowserUrlAuth(url)
				ad_data_new.curADCallBack()
				return true
			else
				if ad_trigger_tip_switch() then
					ShowGameTips(GetS(32002))
					failed()  -- 获取广告失败 无可打开的H5广告页
				else
					MessageBox(4, GetS(32002), function() failed() end)
				end

				-- 失败回调
				ad_data_new.curADFailedCallBack()
				return false
			end
		else
			GetInst("AdService"):Ad_StartPlay(position_id)
			Advertisement:request(curWatchADType, id, position_id)
			return true
		end
	else
		-- 无广告配置
		if curWatchADType == nil then
			if ad_trigger_tip_switch() then
				ShowGameTips(GetS(32003))
				if failed then
					failed();
				end
			else
				MessageBox(4, GetS(32003), function()
					if failed then
						failed();
					end
				end)
			end
		else
			-- 失败回调
			ad_data_new.curADFailedCallBack()
		end		
		return false
	end
end

-- 触发器播放广告, 102/107号广告(带确认框)
function TriggerToPlayADWithMsgboxNew(adname, _successCallback, _failedCallBack, msg, triggerID)
	local mapid = GetFromMapid()
	-- 1001普通房间游戏是作为客机进入游戏  1003打开地图游戏是作为主机进入游戏（单机和作为房主开联机房间）
	local gameType = ClientCurGame:isHost(AccountManager:getUin() or 0) and "1003" or "1001"
	print("TriggerToPlayADWithMsgbox", msg, gameType)

	-- xyang20211227开关打开，屏蔽所有触发器广告，直接发放物品
	if ns_version.triggerADSwitch and check_apiid_ver_conditions(ns_version.triggerADSwitch) and triggerID == 3160001 then
		ShowGameTips(GetS(100802, adname), 3)
		if _successCallback then
			_successCallback()
		end
		standReportEvent(gameType, "AD_FREE_TIP", "-", "view", {cid = mapid})
		return
	end
	local bOpen = false
	if msg == '1120004' or msg == '1120001' or msg == '1120006' or msg == '1120007' then--'UI.Button.TouchBegin' or 'UI.Button.Click'--xyang20220310 UI按钮按下和松开时单独处理
		bOpen = true
	end
	if triggerID == 3160005 and not bOpen then--xyang20221214播放广告（新）时，只有UI按钮按下和松开时会播放广告
		return
	end

	if IsStandAloneMode("") then return end

	-- 失败回调
	local failedCallBack = _failedCallBack or function() end
	
	-- 鸿蒙渠道
	if ClientMgr and ClientMgr:getApiId() == 5 then
		ShowGameTips(GetS(100512), 3)
		failedCallBack()
		return
	end

	if type(adname) ~= 'string' then
		ShowGameTips("ADError:adname is not string")
		failedCallBack()
		return
	end

	--PC
	if ClientMgr:isPC() then
		--if ClientMgr:getApiId() == 999 then
		--	-- SVN端直接下发奖励
		--	MessageBoxFrame2:Open(2,GetS(4022),GetS(32001, adname), function(btn)
		--		if btn == 'right' then
		--			-- 不播放广告，立即成功
		--			ShowGameTips(GetS(100802, adname), 3)
		--			_successCallback()
		--		else
		--			failedCallBack()
		--		end
		--	end)
		--	return;
		--end
		-- 飘窗显示提示文字
		if CurMainPlayer and CurMainPlayer.notifyGameInfo2Self then
			CurMainPlayer:notifyGameInfo2Self(1, 0, 0, GetS(32004))
		end
		failedCallBack()
		return
	end

	-- 从备选广告中查找可播放的广告
	local position_id, finish = ad_data_new.getCurrentTriggerID(102, true)
	-- 触发器广告提示开关
	local is_ad_trigger_tip_on = ad_trigger_tip_switch()
	-- 埋点上报数据
	local exData = {
		standby1 = msg or "", 
		standby2 = is_ad_trigger_tip_on and 2 or 1, 
		standby3 = position_id or 999, 
		cid = tostring(mapid)
	}
	-- 成功回调
	local successCallback = function ()
		print("TriggerToPlayADWithMsgbox successCallback")
		if _successCallback then
			_successCallback()
		end
		standReportEvent(gameType, "AD_POPUP", "AdPlayButton", "ad_complete", exData)
	end

	-- 达到最大播放次数
	if finish then
		-- 改成飘窗提示
		if is_ad_trigger_tip_on then
			ShowGameTips(GetS(32003))
			failedCallBack()
			standReportEvent(gameType, "AD_LIMIT_POPUP"	, "-", "view", exData)
		else
			MessageBox(4, GetS(32003), function() 
				standReportEvent("1001", "MINI_GAMEROOM_GAME_1"	, "AdLimitButton", "click")
				standReportEvent(gameType, "AD_LIMIT_POPUP", "ConfirmButton", "click", exData)
				failedCallBack() 
			end)
			standReportEvent("1001", "MINI_GAMEROOM_GAME_1"	, "AdLimitButton", "view")
			standReportEvent(gameType, "AD_LIMIT_POPUP"	, "-", "view", exData)
			standReportEvent(gameType, "AD_LIMIT_POPUP", "ConfirmButton", "view", exData)
		end		
		return
	end
	
	-- 广告数据获取失败：执行失败提示
	local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
	if not position_id or not curWatchADType then
		if is_ad_trigger_tip_on then
			ShowGameTips(GetS(32002))
			failedCallBack()
			standReportEvent(gameType, "AD_GET_FAIL", "-", "view", exData)
		else
			MessageBox(4, GetS(32002), function() 
				failedCallBack()
				standReportEvent(gameType, "AD_GET_FAIL", "ConfirmButton", "click", exData)
			end)
			standReportEvent(gameType, "AD_GET_FAIL", "-", "view", exData)
			standReportEvent(gameType, "AD_GET_FAIL", "ConfirmButton", "view", exData)
		end
		return
	end

	-- 上报信息
	if mapid == 0 then
		ShowGameTips("ADError:mapid get failed")
		failedCallBack()
		return
	end

	-- 运营数据埋点
	StatisticsADNew('show', position_id, nil, '', mapid, '');

	local adinfo = {
		mapid = mapid,
		triggername = adname,
		cs_roomid = GetCurrentCSRoomId(),
		extend_data = GetInst("ExternalRecommendMgr") and GetInst("ExternalRecommendMgr"):OrginazeDeveloperParam() or nil
	}

	-- 广告奖励名设置颜色，默认是黄色
	local colorAdName = adname or ""
	if not string.find(colorAdName, "#c", 1, true) then
		colorAdName = "#cFFDA0A" .. colorAdName
	end
	-- 只处理广告名变色
	colorAdName = colorAdName .. "#n"

	if is_ad_trigger_tip_on then
		-- TriggerAdInMap 和 TopPurchaseInMap 不同时显示
		-- GetInst("UIManager"):Close("TopPurchaseInMap")
		if GetInst("MiniUIManager"):IsShown("TopPurchaseInMapAutoGen") then
			GetInst("MiniUIManager"):CloseUI("TopPurchaseInMapAutoGen")
		end
		-- if IsUIFrameShown("TriggerAdInMap") then
		-- 	GetInst("UIManager"):GetCtrl("TriggerAdInMap"):CloseBtnClicked()
		-- end
		if GetInst("MiniUIManager"):IsShown("TriggerAdInMapAutoGen") then
			GetInst("MiniUIManager"):CloseUI("TriggerAdInMapAutoGen")
		end

		local paramAdInMap = {
			disableOperateUI = true,
			adname = colorAdName,
			okCall = function() 
				-- 播放广告
				local ret = TriggerToPlayADNew(position_id, adinfo, successCallback, failedCallBack)
				if ret then
					standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "ad_play", exData)
				end
				standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "click", exData)
			end,
			cancelCall = function ()
				failedCallBack()
				standReportEvent(gameType, "AD_POPUP"	, "CancleButton", "click", exData)
			end,
		}
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/ugc_triggerAdInMap"})
		GetInst("MiniUIManager"):OpenUI("TriggerAdInMapMainFrame", "miniui/miniworld/ugc_triggerAdInMap", "TriggerAdInMapAutoGen", paramAdInMap)

		-- GetInst("UIManager"):FadeIn("TriggerAdInMap", {
		-- 	disableOperateUI = true,
		-- 	adname = colorAdName,
		-- 	okCall = function() 
		-- 		-- 播放广告
		-- 		local ret = TriggerToPlayADNew(position_id, adinfo, successCallback, failedCallBack)
		-- 		if ret then
		-- 			standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "ad_play", exData)
		-- 		end
		-- 		standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "click", exData)
		-- 	end,
		-- 	cancelCall = function ()
		-- 		failedCallBack()
		-- 		standReportEvent(gameType, "AD_POPUP"	, "CancleButton", "click", exData)
		-- 	end,
		-- }, 0.3, 12)
	else
		MessageBoxFrame2:Open(2, GetS(4022), GetS(32001, colorAdName), function(btn)
			if btn == 'right' then
				-- 播放广告
				local ret = TriggerToPlayADNew(position_id, adinfo, successCallback, failedCallBack)
				if ret then
					standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "ad_play", exData)
				end
				standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "click", exData)
			else
				failedCallBack()
				standReportEvent(gameType, "AD_POPUP"	, "CancleButton", "click", exData)
			end
		end)
	end
	
	standReportEvent(gameType, "AD_POPUP"	, "-", "view", exData)
	standReportEvent(gameType, "AD_POPUP"	, "AdPlayButton", "view", exData)
	standReportEvent(gameType, "AD_POPUP"	, "CancleButton", "view", exData)
end

-----------------------------------------H5广告逻辑----------------------------------------------
-- 判断H5广告能否播放
function getServerCanshowAdvertisement(position_id)
	return IsAdCanShowLogicHandle(position_id, true)
end
function getDeveloperShopGoodCanshowAdvertisement(position_id)
	return IsAdCanShowLogicHandle(position_id, true);
end

-- 安卓层检查互动剧广告是否可以展示(20号、37号广告)
function getBrowserAdCanShow_Android(position_id)
	print("getBrowserAdCanShow_Android position_id = ", position_id)
	if ClientMgr:isAndroid() then
		local result = IsAdCanShowLogicHandle(position_id, true) or false
		threadpool:work(function()
			print("Call checkAdReadyCallback position_id = ", position_id, ", result = ", result)
			JavaMethodInvokerFactory:obtain()
				:setClassName("org/appplay/lib/GameBaseActivity")
				:setMethodName("checkAdReadyCallback")
				:setSignature("(IZ)V")
				:addInt(position_id or 0)       -- 广告位id
				:addBoolean(result or false)    -- 是否能展示
				:call()
		end)
	end
end

-- 通知原生层H5广告播放失败，并告知原因
function noticeNativePlayAdFailed(position_id, fail_code)
	print("noticeNativePlayAdFailed position_id = ", position_id, ", fail_code = ", fail_code)
	local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
	if not id then
		fail_code = ad_data_new.canShowFailResult.no_ad_config
	end
	if ClientMgr:isAndroid() then
		-- 通知安卓
		JavaMethodInvokerFactory:obtain()
			:setClassName("com/minitech/miniworld/ad/internal/AdNativeBridge")
			:setMethodName("showAdUnusualEvent")
			:setSignature("(III)V")
			:addInt(id or 0)     -- 广告平台id
			:addInt(position_id) -- 广告位id
			:addInt(fail_code)   -- 失败原因
			:call()
	elseif ClientMgr:isApple() then
		-- 通知ios
		luaoc.callStaticMethod("AdvertisementsManager", "showAdUnusualEvent", {
			id = tonumber(id or 0),              -- 广告平台id
			position_id = tonumber(position_id), -- 广告位id
			fail_code = tonumber(fail_code)      -- 失败原因
		})
	end
end

-- 判断广告是否能展示通用逻辑处理
function IsAdCanShowLogicHandle(position_id, isClick)
	print("IsAdCanShowLogicHandle position_id = ", position_id)
	if not position_id or position_id <= 0 then
		return false
	end
	if IsAdUseNewLogic(position_id) then
		local ad_info = GetInst("AdService"):GetAdInfoByPosId(position_id)
		local result, fail_code = ad_data_new.canShow(position_id, ad_info)
		if result then
			if isClick then
				StatisticsADNew('show', position_id)
			end
			return true
		else
			noticeNativePlayAdFailed(position_id, fail_code)
			return false
		end
	elseif t_ad_data.canShow(position_id) then
		if isClick then
			StatisticsAD('show', position_id)
		end
		return true
	end
end

-- 请求播放H5广告 广告位：20号、37号
-- H5GameID 互动剧染色id
function OnReqWatchAdBrowser(position_id, H5GameID)
	print("OnReqWatchAdBrowser position_id = ", position_id, ", H5GameID = ", H5GameID)
	local ret = -1
	if IsAdCanShowLogicHandle(position_id) then
		if IsAdUseNewLogic(position_id) then
			StatisticsADNew('onclick', position_id)
			ad_data_new.curAdCallData = {
				position_id = position_id,
				H5GameID = H5GameID or nil
			}
			ad_data_new.curADCallBack = OnRespWatchAdBrowserNew; 
			ad_data_new.curADFailedCallBack = OnRespWatchAdBrowserFailed
			GetInst("AdService"):Ad_StartPlay(position_id, function()
				local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
				if curWatchADType then
					ret = Advertisement:request(curWatchADType, id, position_id);
				end
			end)
		else
			StatisticsAD('onclick', position_id)
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
			if curWatchADType then
				t_ad_data.browserPositionId = position_id;
				t_ad_data.curADCallBack = OnRespWatchAdBrowser; 
				t_ad_data.curADFailedCallBack = OnRespWatchAdBrowserFailed
				ret = Advertisement:request(curWatchADType, id, position_id);
			end			
		end
	end
	return ret;
end

-- 好友送礼广告
function OnReqWatchAdFriendSendGift(position_id, data)
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):IsAdCanShow(position_id, function(result, ad_info)
			if result then
				GetInst("AdService"):Ad_StartPlay(position_id, function()
					ad_data_new.curAdCallData = data
					ad_data_new.curADCallBack = OnResWatchAdFriendSendGift
					local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
					-- 广告埋点上报说明：1301是按钮点击的上报
					StatisticsADNew('onclick', position_id);
					if curWatchADType then					
						Advertisement:request(curWatchADType, id, position_id)		
					end
				end)
			else
				ShowGameTips(GetS(4980), 3)
			end
		end)
	else
		if t_ad_data.canShow(position_id) then
			t_ad_data.curAdCallData = data
			t_ad_data.curADCallBack = OnResWatchAdFriendSendGift
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id)
			Advertisement:request(curWatchADType, id, position_id)
			-- 广告埋点上报说明：1301是按钮点击的上报
			statisticsGameEventNew(1301, id or "", position_id, "", "", "", GetCurrentCSRoomId());
		else
			ShowGameTips(GetS(4980), 3)
		end
	end	
end

function OnResWatchAdFriendSendGift(data)
	local succeed = function ()
		threadpool:work(function ()
			local inst = GetInst("FriendGiftDataMgr")
			local ret = inst:SendFriendGift(data.uin, data.id, data.num, data.paytype, data.from, data.addTac)

		end)
	end
	if IsAdUseNewLogic(data.position_id) then
		GetInst("AdService"):Ad_Finish(data.position_id, function(ad_info)
			succeed()
		end)
	else
		AccountManager:ad_finish(data.position_id);
		StatisticsAD('finish', data.position_id);
		succeed()
	end
end

-- 网页广告需要回到游戏界面才会走这个逻辑，不符合实际情况。网页改为窗口模式，解决此问题
function OnRespWatchAdBrowser()
	print("OnRespWatchAdBrowser")
	local position_id = t_ad_data.browserPositionId
	if position_id == 20 then
		-- H5广告除了20号广告位需要上报finish到账号服，其他新增的H5广告都不需要上报
		AccountManager:ad_finish(position_id);		
	end	
	StatisticsAD('finish', position_id);	
	Advertisement:onPlaySuccess(position_id);
	t_ad_data.browserPositionId = nil
end
function OnRespWatchAdBrowserNew(data)
	print("OnRespWatchAdBrowserNew data = ", data)
	if not data or not data.position_id then return end
	local position_id = data.position_id
	local H5GameID = data and data.H5GameID or nil
	GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
		Advertisement:onPlaySuccess(position_id);
	end, nil, { H5GameID = H5GameID })
end

-- 网页广告播放失败回调
function OnRespWatchAdBrowserFailed(code, data)
	print("OnRespWatchAdBrowserFailed ", code, data)
	if ClientMgr:isApple() and data then
		local position_id = 0
		if type(data) == "number" then
			position_id = data
		elseif type(data) == "table" and data.position_id and type(data.position_id) == "number" then
			position_id = data.position_id			
		end
		noticeNativePlayAdFailed(position_id, code)
	end
end

-----------------------------------------原生广告逻辑----------------------------------------------
-- 原生广告调用lua埋点 
-- * 1.platformId:渠道id
-- * 2.positionId:播放广告位置
-- * 3.adType：广告类型，2。插屏图片；6.插屏视频；3.原生广告；1.激励视频；
-- * 4.state: 1.播放开始；2.点击广告；3.播放完成
function reportAdEvent(platformId, positionId, adType, state)
	local extra = {}
	extra.channel = tostring(ClientMgr:getApiId()) or ""
	extra.uin = tostring(AccountManager:getUin()) or ""
	extra.cid = WorldMgr and WorldMgr.getFromWorldID and tostring(WorldMgr:getFromWorldID()) or "0"
	extra.device_id = tostring(ClientMgr:getDeviceID()) or ""
	if AccountManager.get_outer_ip_and_delay then
		extra.ip_adress = tostring(AccountManager:get_outer_ip_and_delay()) or ""
	else
		extra.ip_adress = ""
	end
	extra.standby1 = tostring(platformId) or ""
	extra.standby2 = tostring(positionId) or ""
	extra.standby3 = tostring(adType) or ""
	if state == 1 then
		standReportEvent(0, "MINI_AD_PLAY", "-", "ad_play", extra)--新埋点
	elseif state == 2 then
		standReportEvent(0, "MINI_AD_PLAY", "-", "click", extra)--新埋点
	elseif state == 3 then
		standReportEvent(0, "MINI_AD_PLAY", "-", "ad_complete", extra)--新埋点
	end
end

-- 原生广告展示结果回调
function DeliverAdEvent(platformId, positionId, code)
	print("DeliverAdEvent positionId = ", positionId, ", code = ", code)
	if code == 1001 then
		GetInst("AdService"):Ad_Finish(positionId)
	end
end

-- 显示原生广告
function ShowNativeAd(positionId, width, height, marginLeft, topMargin)
	if ClientMgr:isPC() then return end

	print("ShowNativeAd positionId = ", positionId, ", width = ", 
	width, ", height = ", height, ", marginLeft = ", marginLeft, ", topMargin = ", topMargin)

	local callback = function(result, ad_info)
		if result then
			if ClientMgr:isAndroid() then
				JavaMethodInvokerFactory:obtain()
				:setClassName("com/minitech/miniworld/ad/internal/AdNativeBridge")
				:setMethodName("showNativeAd")
				:setSignature("(IIIIII)V")
				:addInt(ad_info and ad_info.platform_id or 0) -- 渠道id
				:addInt(positionId) -- 广告位id
				:addInt(width) -- 宽
				:addInt(height) -- 高
				:addInt(marginLeft) -- 左边距
				:addInt(topMargin) -- 上边距
				:call()

				-- java 调用成功回调DeliverAdEvent
			elseif ClientMgr:isApple() then
				if SdkManager.showNativeAd then
					-- ios 传 platform_id, 不同于渠道ID
					SdkManager:showNativeAd(ad_info.platform_id, positionId, width, height, marginLeft, topMargin)
					SdkManager:showLuaLog("showNativeAd success")
				else
					SdkManager:showLuaLog("showNativeAd fail")
				end

				-- ios 调用成功回调DeliverAdEvent
			end
		end
	end
	GetInst("AdService"):IsAdCanShow(positionId, callback, nil, true)
end

-- 关闭原生广告
function RemoveNativeAd(positionId)
	print("ShowNativeAd positionId = ", positionId)
	if ClientMgr:isAndroid() then
		threadpool:work(function()
			local _, platform_id = GetInst("AdService"):GetAdTypeByAdId(positionId)
			JavaMethodInvokerFactory:obtain()
				:setClassName("com/minitech/miniworld/ad/internal/AdNativeBridge")
				:setMethodName("removeNativeAd")
				:setSignature("(II)V")
				:addInt(platform_id or 0) -- 渠道id
				:addInt(positionId) -- 广告位id
				:call()
		end)
	elseif ClientMgr:isApple() then
		if SdkManager.removeNativeAd then
			local _, platform_id = GetInst("AdService"):GetAdTypeByAdId(positionId)
			SdkManager:removeNativeAd(platform_id, positionId)
			SdkManager:showLuaLog("platformId success")
		else
			SdkManager:showLuaLog("platformId fail")
		end
	end
end

----------------------------------------------------------------------------------------------------

-- 广告合规-个性化广告开关需求，通知原生层开关状态变更
function NoticeNativeUserPersonalize()
	print("NoticeNativeUserPersonalize")
	if ClientMgr.isPC and ClientMgr:isPC() then return end
	local userSet = NativeGetUserPersonalize()
	if ClientMgr.isAndroid and ClientMgr:isAndroid() then
		JavaMethodInvokerFactory:obtain()
			:setClassName("com/minitech/miniworld/ad/internal/AdNativeBridge")
			:setMethodName("updateUserPersonalize")
			:setSignature("(Z)V")
			:addBoolean(userSet) -- 玩家个性推荐开关
			:call()
	end
end
-- 提供给原生层的接口：获取玩家个性推荐开关状态
function NativeGetUserPersonalize()
	local serverSet, userSet = nil, true
	local config = business_advert_config.UserPersonalizeSwitch
	if config then		
		-- 配置开启时根据个性化推荐状态设置个性化广告开关，关闭时默认开启个性化广告
		serverSet = check_apiid_ver_conditions(config)
		if serverSet then
			userSet = G_GetRecommendationsOpen()
		end
	end
	print("NativeGetUserPersonalize serverSet = ", serverSet, ", userSet = ", userSet)
	return userSet
end