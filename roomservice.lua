--[[
### DOC:https://mini1.feishu.cn/docs/doccn8V1xxJQSarvMqB1NRRXJRd 接口说明
--]]
local RoomService = ClassEx("RoomService")

local instance = nil
function RoomService:GetInst()
    if instance == nil then
        instance = ClassList["RoomService"]:instance()
        instance:AfterInit()
    end
    return instance
end

--failed_code
RoomService.failed_code = {
    WRONG_PASSWD = 11,
    ROOM_FULL = 10,
    ROOM_NOT_EXISTS = 12,
    ROOM_LOCKED = 14,
    TOKEN_ERROR = 15,
    CHEAT_CLIENT = 16,
    IN_BLACK = 17,
    SENSITIVE_STRING = 18,
    CON_MODE_NOT_MATCH = 19,
    VERSION_NOT_MATCH = 20,
    CONNECT_FAILED = 21,
    NOT_PUBLIC = 98,
    NO_PORT = 99,
    OTHER = 13,
    REQ_OUT_TIME = 201,
}

--云服V2接口参数 场景id 大厅18 地图详情48 地图房间列表48/1004 活动50 联机失败后兜底51
-- 同步更新文档 https://mini1.feishu.cn/docx/AWhAddvsnoA1h0xniZ2cobIwnVc
enum_scene = {
    Hall = 18,
    MapDetail = 48,
    RoomList = 48,
    Activity = 50,
    RetryCloud = 51,
    CloudDebug = 52,   -- 云服调试
    MapTeleport = 53,  -- 传送门
    RoomListOld = 1004,
}

--云服V2接口参数 业务id 
--[[迷你世界1000
迷你基地1001
海外迷你世界1002
房间服1003
审核系统1004
客服系统1005
游戏服务器1006
信用分后台管理系统1007
中台服务1008
增长团队1009
内容生态团队1010
工具团队1011
品牌团队1012
OGC团队1013--]]
enum_appid = {
    Mini = 1000,
    ZhongTai = 1008,
    ZengZhang = 1009,
    gongju = 1011,
    OGC = 1013,
}

function RoomService:Init()
    self.define = {}
    self.define.errorCode = {
        [1] = 182001,
        [2] = 182002,
        [3] = 182003,
        [4] = 182004,
        [5] = 182005,
        [6] = 182006,
        [7] = 182007,
        [8] = 182008,
        [9] = 182009,
        [10] = 182010,
        [11] = 182011,
        [12] = 182012,
        [15] = 182013,
        [16] = 182014,
        [17] = 182015,
        [18] = 182016,
        [19] = 182017,
        [22] = 182022,
        [400] = 182018,
        [401] = 182019,
        [403] = 182020,
        [500] = 182021,
        [501] = 182021,
        [502] = 182021,
        [503] = 182021,
        [504] = 182021,
    }
end

function RoomService:ShowErrorCodeTip(failedCode)
    local code = math.floor((failedCode or 0) / 1000)
    if self.define.errorCode[code] then
        local strId = self.define.errorCode[code] or 35888
        ShowGameTipsWithoutFilter(GetS(strId) .."(" .. tostring(failedCode) .. ")", 3)
    else
        ShowGameTipsWithoutFilter(GetS(35888) .."(" .. tostring(failedCode) .. ")", 3)
    end 
end
 
function RoomService:GetErrorCodeTip(failedCode)
    local code = math.floor((tonumber(failedCode) or 0) / 1000)
    local strId = 35888
    if self.define.errorCode[code] then
        strId = self.define.errorCode[code] or 35888
    end

    if strId == 35888 and failedCode == RoomService.failed_code.REQ_OUT_TIME then
        strId = 3752
    end
    
    return GetS(strId)
end
 
function RoomService:AfterInit()
    -- 云服需要使用 ReqJoinQuickupCSRoomByMultiTeleport，不用加载其他
    if _G.IsServerBuild then
        return
    end

    self.EVT_GEN_PREFIX_LOGIN = "RoomService_Login"
    self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY = "RoomService_Sync_Thread_Notify"
    self.EVT_GEN_PREFIX_JOIN = "RoomService_Join"

    self.EVT_GEN_PREFIX_JUMP_ROOM_WITH_PARAM = "RoomService_Jump_Room_With_Param"

    GetInst("UIEvtHook"):RegisterEventPrefixHook("GIE_UPDATE_ROOM", self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY);
    GetInst("UIEvtHook"):RegisterEventPrefixHook("GIE_RSCONNECT_RESULT", self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY);
    GetInst("UIEvtHook"):RegisterEventPrefixHook("GIE_RSCONNECT_RENT_RESULT", self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY);

    GetInst("UIEvtHook"):RegisterEventPrefixHook("GIE_RSCONNECT_RESULT", self.EVT_GEN_PREFIX_LOGIN);
    GetInst("UIEvtHook"):RegisterEventPrefixHook("GIE_RSCONNECT_RESULT", self.EVT_GEN_PREFIX_JOIN);
    GetInst("UIEvtHook"):RegisterEventPrefixHook("GIE_RSCONNECT_RENT_RESULT", self.EVT_GEN_PREFIX_JOIN);

    GetInst("UIEvtHook"):RegisterEventPrefixHook("GIE_RSCONNECT_RESULT", self.EVT_GEN_PREFIX_JUMP_ROOM_WITH_PARAM);
    
    SandboxLua.eventDispatcher:CreateEvent(nil, "RoomClient_CustomNameFlag")
    SandboxLua.eventDispatcher:SubscribeEvent(nil, "RoomClient_CustomNameFlag", self:FuncHandler(self, RoomService.CustomRoomFlagUpdate))

    self.m_enterRoomCallBackLru = {}
    self.m_syncWaitingStatus = {}
    self.m_teamNorRoomDesc = RoomDesc:new()
    self:InitLruList(self.m_enterRoomCallBackLru)
    self:InitLruList(self.m_syncWaitingStatus)

    self.m_customRoomNameFlagCache = {}

    self.m_supportQuickupRentMapwids = {

    }

    self.m_RoomMapLabelCache = {

    }

    --k:tostring(mapowid) v:number
    self.m_quickupRentPlayerNum = {

    }
    setmetatable(self.m_quickupRentPlayerNum, {
        __index = function(t, k)
            local rv = nil
            if k then
                rv = tonumber(rawget(t, tostring(k))) or 0
            end
            if not rv or rv <= 0 then
                return math.random(1, 3)
            end
            return rv
        end,
        __newindex = function(t, k, v)
            if t and k and tonumber(v) then
                v = tonumber(v)
                if v > 0 then
                    rawset(t, k , v)
                end
            end
        end
    })

    self.m_mapPlayerNum = {

    }
    self.m_mapPlayerNumAndRoomCount = {

    }
    setmetatable(self.m_mapPlayerNum, {
        __index = function(t, k)
            local rv = nil
            if k then
                rv = tonumber(rawget(t, tostring(k))) or 0
            end
            if not rv or rv <= 0 then
                return math.random(1, 3)
            end
            return rv
        end,
        __newindex = function(t, k, v)
            if t and k and tonumber(v) then
                v = tonumber(v)
                if v > 0 then
                    rawset(t, k , v)
                end
            end
        end
    })

end

function RoomService:FuncHandler(obj, method)	
    return function(...)
        return method(obj, ...)
    end
end

function RoomService:InitLruList(lruTab, max)
    lruTab.lrulist = {
        fnode = {
            prekey = nil,
            nextkey = "enode",
        },

        enode = {
            prekey = "fnode",
            nextkey = nil,
        }
    }
    lruTab.lrumap = {}
    lruTab.len = 0
    lruTab.max = max or 10

    lruTab.InsertLru = function(obj, curkey, data)
        local prekey = "fnode"
        if curkey and obj.lrulist[prekey] then
            obj:RemoveLru(curkey)
            local lrunode = {
                prekey = prekey,
                nextkey = obj.lrulist[prekey].nextkey,
            }
        
            obj.lrulist[obj.lrulist[prekey].nextkey].prekey = curkey
            obj.lrulist[prekey].nextkey = curkey
            obj.lrulist[curkey] = lrunode

            obj.lrumap[curkey] = data
            obj.len = obj.len+1
            if obj.len > obj.max then
                obj:RemoveLru(obj.lrulist.enode.prekey)
            end
        end 
    end
    lruTab.RemoveLru = function(obj, curkey)
        if curkey and curkey ~= "fnode" and curkey ~= "enode" then
            if obj.lrulist[curkey] then
                local temp = obj.lrulist[curkey]
 
                obj.lrulist[temp.prekey].nextkey = temp.nextkey
                obj.lrulist[temp.nextkey].prekey = temp.prekey
 
                obj.lrulist[curkey] = nil
                obj.lrumap[curkey] = nil
                obj.len = obj.len-1
            end
        end
    end
end

function RoomService:RegisterEvents()
    this:RegisterEvent("GIE_UPDATE_ROOM");
    this:RegisterEvent("GIE_RSCONNECT_RESULT");
    this:RegisterEvent("GIE_RSCONNECT_RENT_RESULT");

    GetInst("UIEvtHook"):RegisterEventEqualHook('GIE_RSCONNECT_RESULT', 'LobbyFrameRoomBtn_OnClick_keepRoomFrameData')
end


function RoomService:CustomRoomFlagUpdate(context)
    local param = context:GetParamData();
    --毕竟房主只能同时建一个房间，只记一个
    if param and param.nameStr and param.flag then
        self.m_customRoomNameFlagCache = {}
        self.m_customRoomNameFlagCache[param.nameStr] = param.flag
    end
end

--房主调用
--[[
FOO.room_name_flag = {
    no_audit = 0, -- 未审核，不能使用
    audit = 1,    -- 此名称已审核，可使用
    limit = 2,    -- 审核量已到限制
    fail_audit = 3, -- 审核不通过
}
--]]
function RoomService:HostGetCustomRoomNameFlagPassed(str)
    return self.m_customRoomNameFlagCache[str] == 1
end
function RoomService:HostGetCustomRoomNameFlagFailed(str)
    return self.m_customRoomNameFlagCache[str] == 3
end

function RoomService:AppenAiRecommendSwitchArg(url)
    if url then
        if G_GetRecommendationsOpen() then --0/不传 使用推荐
            url = url .. "&big_data_switch=0"
        else
            url = url .. "&big_data_switch=1" --1 禁用推荐
        end
    end

    return url
end

--同步rpc调用
function RoomService:SyncRpc(url, timeout, showLoadLoop)
	local gid = gen_gid();
	local timeout = timeout or 6;
	local bNeedWaiting = true;
	local code = 0;
	local ret = nil
    if showLoadLoop == nil then showLoadLoop = true end

	local callback = function(_ret)
		print("RoomService:SyncRpc:callback:");
		bNeedWaiting = false;
		ret = _ret;
		threadpool:notify(gid, ErrorCode.OK, _ret);
	end

    local loopTag = "file:RoomService - func:SyncRpc " .. gid
    if showLoadLoop then
        ShowLoadLoopFrame(true, loopTag);
    end
	ns_http.func.rpc(url, callback, nil, nil, true);

	if bNeedWaiting then
		code, _ret = threadpool:wait(gid, timeout);
	end
	
    if showLoadLoop then
	    HideLoadLoopFrameByTag(loopTag)
    end

	return ret;
end

function RoomService:SyncRpcRaw(url, timeout, showLoadLoop)
	local gid = gen_gid();
	local timeout = timeout or 6;
	local bNeedWaiting = true;
	local code = 0;
	local ret = nil
    if showLoadLoop == nil then showLoadLoop = true end

	local callback = function(_ret)
		print("RoomService:SyncRpcRaw:callback:");
		bNeedWaiting = false;
		ret = _ret;
		threadpool:notify(gid, ErrorCode.OK, _ret);
	end

    local loopTag = "file:RoomService - func:SyncRpcRaw " .. gid
    if showLoadLoop then
        ShowLoadLoopFrame(true, loopTag);
    end
	ns_http.func.rpc_string_raw(url, callback);

	if bNeedWaiting then
		code, _ret = threadpool:wait(gid, timeout);
	end
	
    if showLoadLoop then
	    HideLoadLoopFrameByTag(loopTag)
    end

	return ret;
end

function RoomService:SyncRpcPostCheckLoadLoop(loadLoopInfo, show, loopTag)
    if "table" ~= type(loadLoopInfo) then loadLoopInfo = {} end
    local showLoadLoop = loadLoopInfo.showLoadLoop
    local loadLoopType = loadLoopInfo.loadLoopType
    local loopDesc = loadLoopInfo.loopDesc
    local bkgName = loadLoopInfo.bkgName

    if showLoadLoop == nil then showLoadLoop = true end
    
    if showLoadLoop then
        if show then --内部内容要与else对齐
            if loadLoopType == 2 then
                ShowLoadLoopFrame2(true, loopTag, timeout, loopDesc, bkgName);
            elseif loadLoopType == 3 then
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/activity_chinesenewyear_effect"})
                GetInst("MiniUIManager"):OpenUI("main_loading","miniui/miniworld/activity_chinesenewyear_effect","main_loadingAutoGen")
            elseif loadLoopType == 4 then
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/activity_speed_dating"})
                GetInst("MiniUIManager"):OpenUI("main_speed_dating_loading","miniui/miniworld/activity_speed_dating","main_speed_dating_loadingAutoGen")
            elseif loadLoopType == 5 then
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/main_loading"})
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/activity_anniversary_loading"})
                GetInst("MiniUIManager"):OpenUI("main_loading","miniui/miniworld/activity_anniversary_loading","main_anniversary_loadingAutoGen")
            elseif loadLoopType == 6 then
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/activity_juexingmovie_homepage"})
                GetInst("MiniUIManager"):OpenUI("juexingmovie_loading","miniui/miniworld/activity_juexingmovie_loading","juexingmovie_loadingAutoGen")
            elseif loadLoopType == 7 then
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/activity_miniWorker"})
                GetInst("MiniUIManager"):OpenUI("main_miniWorker_loading","miniui/miniworld/activity_miniWorker","main_miniWorker_loadingAutoGen")
            elseif loadLoopType == 8 then
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/boat_festival_main"})
                GetInst("MiniUIManager"):OpenUI("activity_base_loading","miniui/miniworld/boat_festival_main","activity_base_loadingAutoGen")
            elseif loadLoopType == 9 then
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/activity_douluo_video"})
                GetInst("MiniUIManager"):OpenUI("activity_douluo_loading","miniui/miniworld/activity_douluo_video","activity_douluo_loadingAutoGen")
            elseif loadLoopType == 10 then
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/act_36_sanliou"})
                GetInst("MiniUIManager"):OpenUI("sanrio_loading","miniui/miniworld/act_36_sanliou","sanrio_loadingAutoGen")
            elseif loadLoopType == 11 then
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/act_38_midautumn"})
                GetInst("MiniUIManager"):OpenUI("main_midautuloading","miniui/miniworld/act_38_midautumn","main_midautuloadingAutoGen")
            elseif loadLoopType == 12 then
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/act_41_nationalday"})
                GetInst("MiniUIManager"):OpenUI("NationdayLoading","miniui/miniworld/act_41_nationalday","NationdayLoadingAutoGen")
            elseif loadLoopType == 13 then 
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/act_43_AOTU"})
                GetInst("MiniUIManager"):OpenUI("main_AOTULoading","miniui/miniworld/act_43_AOTU","main_AOTULoadingAutoGen")
            elseif loadLoopType == 14 then 
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/act_50_7th_anniversary"})
                GetInst("MiniUIManager"):OpenUI("main_annLoading","miniui/miniworld/act_50_7th_anniversary","main_annLoadingAutoGen")
	        elseif loadLoopType == 15 then
	     	    GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/act_53_iceSheet"})
                GetInst("MiniUIManager"):OpenUI("main_iceSheetLoading","miniui/miniworld/act_53_iceSheet","main_iceSheetLoadingAutoGen")
            elseif loadLoopType == 16 then
                GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/act_57_Dragon_Boat_Festival"})
               GetInst("MiniUIManager"):OpenUI("DragonLoading","miniui/miniworld/act_57_Dragon_Boat_Festival","DragonLoadingAutoGen")
            else
                ShowLoadLoopFrame(true, loopTag);
            end
        else
            if loadLoopType == 2 then
                ShowLoadLoopFrame2(false, loopTag);
            else
                HideLoadLoopFrameByTag(loopTag)
            end
            
            if loadLoopType == 3 then
                GetInst("MiniUIManager"):CloseUI("main_loadingAutoGen")
            end
            if loadLoopType == 4 then
                GetInst("MiniUIManager"):CloseUI("main_speed_dating_loadingAutoGen")
            end   
            if loadLoopType == 5 then
                GetInst("MiniUIManager"):CloseUI("main_loadingAutoGen")
            end   
            if loadLoopType == 6 then
                GetInst("MiniUIManager"):CloseUI("juexingmovie_loadingAutoGen")
            end   
            if loadLoopType == 7 then
                GetInst("MiniUIManager"):CloseUI("main_miniWorker_loadingAutoGen")
            end   
            if loadLoopType == 8 then
                GetInst("MiniUIManager"):CloseUI("activity_base_loadingAutoGen")
            end   
            if loadLoopType == 9 then
                GetInst("MiniUIManager"):CloseUI("activity_douluo_loadingAutoGen")
            end
            if loadLoopType == 10 then
                GetInst("MiniUIManager"):CloseUI("sanrio_loadingAutoGen")
            end
            if loadLoopType == 11 then
                GetInst("MiniUIManager"):CloseUI("main_midautuloadingAutoGen")
            end
            if loadLoopType == 12 then
                GetInst("MiniUIManager"):CloseUI("NationdayLoadingAutoGen")
            end 
            if loadLoopType == 13 then
                GetInst("MiniUIManager"):CloseUI("main_AOTULoadingAutoGen")
            end 
            if loadLoopType == 14 then
                GetInst("MiniUIManager"):CloseUI("main_annLoadingAutoGen")
            end
            if loadLoopType == 15 then
                GetInst("MiniUIManager"):CloseUI("main_iceSheetLoadingAutoGen")
            end
            if loadLoopType == 16 then
                GetInst("MiniUIManager"):CloseUI("DragonLoadingAutoGen")
            end
            
        end
    end
end

function RoomService:SyncRpcPost(url, postdata, timeout, loadLoopInfo, useAsync)
	local gid = gen_gid();
	local timeout = timeout or 6;
	local bNeedWaiting = true;
	local code = 0;
	local ret = nil
    local loopTag = "file:RoomService - func:SyncRpcPost " .. gid

	local callback = function(_ret)
		print("RoomService:SyncRpcPost:callback:");        
		bNeedWaiting = false;
		ret = _ret;
		threadpool:notify(gid, ErrorCode.OK, _ret);
	end

    self:SyncRpcPostCheckLoadLoop(loadLoopInfo, true, loopTag)

    -- ns_http.func.rpc_string_raw_https(url, callback, nil, nil, postdata)
    if useAsync then
        ns_http.func.rpc_do_async_http_post2(url, callback, nil, postdata)
    else
        ns_http.func.rpc_do_http_post(url, callback, nil, postdata)
    end

	if bNeedWaiting then
		code, _ret = threadpool:wait(gid, timeout);
	end
	
    self:SyncRpcPostCheckLoadLoop(loadLoopInfo, false, loopTag)

	return ret, code
end

function RoomService:GetMapPlayerNum(mapwid, localFix)
    if localFix then
        if self.m_mapPlayerNum[tostring(mapwid)] then
            return self.m_mapPlayerNum[tostring(mapwid)]
        else
            return 0
        end
       
    else
        return rawget(self.m_mapPlayerNum, tostring(mapwid)) or 0
    end
end

function RoomService:GetMapRoomNumAndPlayerNum(mapwid)
    if self.m_mapPlayerNumAndRoomCount[tostring(mapwid)] then
        return self.m_mapPlayerNumAndRoomCount[tostring(mapwid)]
    else
        return nil
    end
end

function RoomService:AsynReqMapPlayerCount(mapwids)
    if "table" ~= type(mapwids) or not next(mapwids) then
        return 
    end
    if #mapwids == 1 then
        local strmapid =tostring(mapwids[1])
        if self.m_mapPlayerNumAndRoomCount[strmapid] then
            if os.time() -  self.m_mapPlayerNumAndRoomCount[strmapid].updatetime < 20 then
                return 
            end
        end
    end
    local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
    self:InsertSyncWaitingStatus(true, genkey)
    if not AccountManager:loginRoomServer(false, 0, genkey) then
        return
    end
    local uin_ = AccountManager:getUin() or get_default_uin()    
    local url = AllRoomManager:CreateRoomServerRequest("/server/room")
                    :addparam("channel", ClientMgr:getApiId())
                    :addparam("cmd", "query_map_player_count")
                    :addparam("country", get_game_country() or "nil")
                    :addparam("language", get_game_lang() or "nil")
                    :addparam("map_ids", table.concat(mapwids, ','))
                    :addparam("time", os.time())
                    :finish();
    ns_http.func.rpc_string_raw(url, function (retStr)
        if not retStr then
            return
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table' and type(ret.data) == 'table') then
            return
        end    

        local data = ret.data
        if not (type(data.list) == 'table') then
            return
        end    

        for _, value in ipairs(data.list) do
            if "table" == type(value) then
                if value.aid then
                    local straid =tostring(value.aid);
                    local palycount = tonumber(value.online)
                    local roomcount = tonumber(value.roomcnt)
                    self.m_mapPlayerNum[straid] = palycount
                    self.m_mapPlayerNumAndRoomCount[straid] = {}
                    self.m_mapPlayerNumAndRoomCount[straid].playcount = palycount
                    self.m_mapPlayerNumAndRoomCount[straid].roomcount = roomcount
                    self.m_mapPlayerNumAndRoomCount[straid].updatetime = os.time()
                end
            end
        end
    end);
end

--请求地图游玩人数
function RoomService:ReqMapPlayerCount(mapwids, spData)
    spData = spData or {}
    
    local retTab = {}

    if "table" ~= type(mapwids) or not next(mapwids) then
        return retTab
    end

    --  对于一个地图请求做优化减少请求时间
    if #mapwids == 1 then
        local strmapid =tostring(mapwids[1])
        if self.m_mapPlayerNumAndRoomCount[strmapid] then
            if os.time() -  self.m_mapPlayerNumAndRoomCount[strmapid].updatetime < 20 then
                retTab[strmapid] = {};
                retTab[strmapid].playcount =  self.m_mapPlayerNumAndRoomCount[strmapid].playcount
                retTab[strmapid].roomcount =  self.m_mapPlayerNumAndRoomCount[strmapid].roomcount
                return retTab
            end
        end
    end
    
    local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
    self:InsertSyncWaitingStatus(true, genkey)
    if not AccountManager:loginRoomServer(false, 0, genkey) then
        return
    end

    if self:FindSyncWaitingStatus(genkey) then
        local code, _ret = threadpool:wait(gid, 2);
        if code ~= ErrorCode.OK or _ret ~= genkey then
            return retTab
        end
    end

    local uin_ = AccountManager:getUin() or get_default_uin()    
    local url = AllRoomManager:CreateRoomServerRequest("/server/room")
                    :addparam("channel", ClientMgr:getApiId())
                    :addparam("cmd", "query_map_player_count")
                    :addparam("country", get_game_country() or "nil")
                    :addparam("language", get_game_lang() or "nil")
                    :addparam("map_ids", table.concat(mapwids, ','))
                    :addparam("time", os.time())
                    :finish();

    print("RoomService:ReqMapPlayerCount")
    
    local retStr = self:SyncRpcRaw(url, spData.outtime or nil, false); 
    print("ReqMapPlayerCount retStr " .. tostring(retStr))
    repeat
        if not retStr then
            break
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table' and type(ret.data) == 'table') then
            break
        end    

        local data = ret.data
        if not (type(data.list) == 'table') then
            break
        end    

        for _, value in ipairs(data.list) do
            if "table" == type(value) then
                if value.aid then
                    local straid =tostring(value.aid);
                    local palycount = tonumber(value.online)
                    local roomcount = tonumber(value.roomcnt)
                    retTab[straid] = {};
                    self.m_mapPlayerNum[straid] = palycount
                    self.m_mapPlayerNumAndRoomCount[straid] = {}
                    retTab[straid].playcount = palycount
                    self.m_mapPlayerNumAndRoomCount[straid].playcount = palycount
                    retTab[straid].roomcount = roomcount
                    self.m_mapPlayerNumAndRoomCount[straid].roomcount = roomcount
                    self.m_mapPlayerNumAndRoomCount[straid].updatetime = os.time()
                end
            end
        end
        break
    until true

    return retTab
end

--请求展示用房间列表 20220816
function RoomService:GetSimpleRoomList(spData, addAuthorParam, addOtherParam)
    spData = spData or {}
    addAuthorParam = addAuthorParam or {}
    addOtherParam = addOtherParam or {}
    
    local retTab = {}
    
    local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
    self:InsertSyncWaitingStatus(true, genkey)
    if not AccountManager:loginRoomServer(false, 0, genkey) then
        return
    end

    if self:FindSyncWaitingStatus(genkey) then
        local code, _ret = threadpool:wait(gid, 2);
        if code ~= ErrorCode.OK or _ret ~= genkey then
            return retTab
        end
    end

    local uin_ = AccountManager:getUin() or get_default_uin()    
	local s2, s2t = get_login_sign();
	s2t = string.gsub(s2t, '&s2t=', '')

    local authorParams = {
        {"channel",     ClientMgr:getApiId() or "nil"},
        {"cmd",         "get_room_list"},
        {"country",     get_game_country() or "nil"},
        {"lang",        get_game_lang() or "nil"},
        {"s2t",         s2t},
        {"time",        os.time()},
        {"uin",         uin_},
    }

    for key, value in pairs(addAuthorParam) do
        authorParams[key] = tostring(value)
    end

    local otherParams = {
    }
    for key, value in pairs(addOtherParam) do
        otherParams[key] = tostring(value)
    end

    table.sort(
        authorParams, 
        function(a, b) 
            return a[1] < b[1] 
        end
    )

    local builder = AllRoomManager:CreateRoomServerRequest("/server/room")
    for index, value in ipairs(authorParams) do
        builder:addparam(value[1], tostring(value[2]))
    end
    builder:author()
    for index, value in ipairs(otherParams) do
        builder:addparam(value[1], tostring(value[2]))
    end
    local url = builder:finish()

    print("RoomService:GetSimpleRoomList")
    
    local retStr = self:SyncRpcRaw(url, spData.outtime or nil, false); 
    print("GetSimpleRoomList retStr " .. tostring(retStr))
    -- test code
    --retStr = [[{"code":0,"data":{"roomlist":[{"nick_name":"邓落雪","room_id":1000040522,"public_type":0,"connect_mode":0,"uicon_box":1,"uicon":2,"has_password":1,"room_ver":"1.16.0","thumbnail":"http:\/\/indevelop.mini1.cn:8080\/map\/1\/20210705\/d925f09977a196e6b29b755b74080ee4.png","room_name":"蜡笔小涛的创造","extra_data":"{\"audioconfigurl\":\"\",\"autoTag\":\"创造\",\"gender\":1,\"hostRoomTk\":1660981332,\"limit\":6,\"modUuids\":[],\"modurl\":\"\",\"platform\":1,\"translate_sourcelang\":0,\"uilibsurl\":\"\",\"uniqueCode\":\"001000040522001660636623c951764cc33fd13d366121a50fade556\",\"version\":\"1.16.0\",\"vipExp\":0,\"vipLevel\":0,\"vipType\":0}","player_num":1,"uin":1000040522,"map_name":"蜡笔小涛的创造","room_cap":6,"map_id":"0feabad0b08b56b76c469608fa25d18b","locked":0,"has_avatar":1},{"has_password":0,"room_ver":"1.16.0","thumbnail":"http:\/\/indevelop.mini1.cn:8080\/map\/1\/20211105\/ccbb5d0361c0e2e874b40c591ecf18df.png","room_id":"135334_0","room_name":"","player_num":0,"locked":0,"room_cap":10,"map_name":"shenhe_爱奇艺112","map_id":15491947037672,"uin":"135334"}]},"message":"OK"}]]
    repeat
        if not retStr then
            break
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table' and type(ret.data) == 'table') then
            break
        end    

        local data = ret.data
        if not (type(data.roomlist) == 'table') then
            break
        end

        retTab = data.roomlist
        break
    until true

    return retTab
end

function RoomService:OpenRoomDetail(roomInfo, reportSlot, reportTraceid)
    if roomInfo then
        GetInst("UIManager"):Close("NormalRoomDetail")
        GetInst("UIManager"):Close("CloudRoomDetail")
        if self:GetRoomType(roomInfo) == AllRoomManager.RoomType.CloudServer then
            local uin = getRoomUinAndRoomID(roomInfo._k_)
            if uin then
                local myuin = AccountManager:getUin();
                local url = g_http_root_map.."miniw/profile/?act=getProfile&op_uin="..uin.."&fast=10&"..http_getS1Map(myuin);
                local ret = self:SyncRpc(url)
                if not ClientCurGame:isInGame() and ret and ret.ret == 0 and ret.profile and ret.profile.RoleInfo then
                    local params = {
                        uin = uin,
                        skinId = ret.profile.RoleInfo.SkinID,
                        model = ret.profile.RoleInfo.Model,
                        nickname = ret.profile.RoleInfo.NickName
                    }
                    GetInst("UIManager"):Open("CloudRoomDetail", {roomDesc=roomInfo, roleProfile=params, reportSlot=reportSlot, trace_id = reportTraceid})
                end
            end
        elseif self:GetRoomType(roomInfo) == AllRoomManager.RoomType.Normal then
            GetInst("UIManager"):Open("NormalRoomDetail", {roomDesc = roomInfo, reportSlot = reportSlot, trace_id = reportTraceid})
        end
    end
end

function RoomService:InsertEnterRoomCallBack(callBack, genkey)
    if callBack and genkey then
        -- self.m_enterRoomCallBackLru:InsertLru(genkey, callBack)
    end
end

function RoomService:FindEnterRoomCallBack(genkey)
    local callBack = self:FuncHandler(self, RoomService.EnterRoomErrorTip)
    if genkey then
        local callBack = self.m_enterRoomCallBackLru.lrumap[genkey]
        self.m_enterRoomCallBackLru:RemoveLru(genkey)
    end
    return callBack
end

function RoomService:InsertSyncWaitingStatus(value, key)
    if value and key then
        self.m_syncWaitingStatus:InsertLru(key, value)
    end
end

function RoomService:FindSyncWaitingStatus(key)
    local status = true
    if key then
        status = self.m_syncWaitingStatus.lrumap[key]
        self.m_syncWaitingStatus:RemoveLru(key)
    end
    return status
end


function RoomService:OnEvent()
    local ge = GameEventQue:getCurEvent()
    local evt = arg1

    if evt == "GIE_UPDATE_ROOM" then
        if not GetInst("UIEvtHook"):EventHook(evt, ge, self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY) then
            local _, gid = GetInst("UIEvtHook"):ParsePrefixGenKey(ge.genid)
            self:InsertSyncWaitingStatus(false, ge.genid)
            local result0 = ge.body.room.result;
            local failreason = ge.body.room.failreason;
            threadpool:notify(gid, ErrorCode.OK, ge.genid, result0, failreason);
        end
    elseif evt == "GIE_RSCONNECT_RESULT" then
        local result = ge.body.roomseverdata.result;
        if not GetInst("UIEvtHook"):EventHook(evt, ge, self.EVT_GEN_PREFIX_LOGIN) then
            self:RespLoginRoomServer(result, ge.genid)

        elseif not GetInst("UIEvtHook"):EventHook(evt, ge, self.EVT_GEN_PREFIX_JOIN) then
            local detailreason = ge.body.roomseverdata.detailreason --发现以前变量名用错了，修复下
            self:LinkNormalRoomResult(result, detailreason, ge.genid)

        elseif not GetInst("UIEvtHook"):EventHook(evt, ge, self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY) then
            local detailreason = ge.body.roomseverdata.detailreason --发现以前变量名用错了，修复下
            local _, gid = GetInst("UIEvtHook"):ParsePrefixGenKey(ge.genid)
            self:InsertSyncWaitingStatus(false, ge.genid)
            threadpool:notify(gid, ErrorCode.OK, ge.genid, result, detailreason);

        elseif not GetInst("UIEvtHook"):EventHook(evt, ge, 'LobbyFrameRoomBtn_OnClick_keepRoomFrameData') then
            self:HandleCommonGieRSConnectEvt(true)
        elseif not GetInst("UIEvtHook"):EventHook(evt, ge, self.EVT_GEN_PREFIX_JUMP_ROOM_WITH_PARAM) then
            local _, gid = GetInst("UIEvtHook"):ParsePrefixGenKey(ge.genid)
            self:HandleCommonGieRSConnectEvt(false, GetInst("GameHallCacheManager"):GetData(self.EVT_GEN_PREFIX_JUMP_ROOM_WITH_PARAM, gid))
        elseif not GetInst("UIEvtHook"):EventHook(evt, ge) then --以前的lobbyframe里面的全局不带genkey的响应
            self:HandleCommonGieRSConnectEvt()
        end
    elseif evt == "GIE_RSCONNECT_RENT_RESULT" then
        local result = ge.body.rentroomdata.result
        local detailreason = ge.body.rentroomdata.detailreason
        if not GetInst("UIEvtHook"):EventHook(evt, ge, self.EVT_GEN_PREFIX_JOIN) then
            self:LinkCloudRoomResult(result, detailreason, ge.genid)
        elseif not GetInst("UIEvtHook"):EventHook(evt, ge, self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY) then
            local _, gid = GetInst("UIEvtHook"):ParsePrefixGenKey(ge.genid)
            self:InsertSyncWaitingStatus(false, ge.genid)
            threadpool:notify(gid, ErrorCode.OK, ge.genid, result, detailreason);
        end
    end
end

function RoomService:GetCacheRoomMapLabel(fromowid)
    local label = 0

    repeat
        if not fromowid then
            break
        end

        fromowid = tonumber(fromowid)
        if not fromowid then
            break
        end

        label = self.m_RoomMapLabelCache[fromowid] or 0
        break
    until true

    return label
end

function RoomService:RespLoginRoomServer(result, genkey)
end

function RoomService:EnterRoomErrorTip(errCode, tipType)
end

function RoomService:GetQuickupRentBaseUrl(rentDebug)
    if rentDebug then
        if get_game_env() == 1 then--测试环境
            return "http://121.36.191.216:8082/"
        elseif get_game_env() == 2 then--先遣服
            return "" --todo
        else
            return "http://developer-gsmgr.mini1.cn/"
        end 
    end
	if get_game_env() == 1 then--测试环境
        -- return "http://10.0.0.134:8082/"
        return "http://124.70.174.136:8082/"
    elseif get_game_env() == 2 then--先遣服
        return "http://pre-cs-basic-service.mini1.cn:8082/"
    else
        return "http://cs-gsmgr.mini1.cn/"
    end 
end

function RoomService:GetQuickupRentApiBaseUrl(sub)
    local baseUrl = ""
	if get_game_env() == 1 then--测试环境
        -- return "http://10.0.0.134:8002/"
        baseUrl = "http://124.70.174.136:8002/"
    elseif get_game_env() == 2 then--先遣服
        baseUrl = "http://pre-cs-basic-service.mini1.cn:8002/"
    else
        baseUrl = "http://cs-apiserver.mini1.cn/"
    end 

    local url = baseUrl .. (sub or "" ).. "?signType=client"
    local  s2, _, ps2t = get_login_sign() -- g_login_sign, g_login_s2t, g_login_pure_s2t
    local s2t = ps2t or "nil"
    local ts = os.time() or "nil"
    local auth = gFunc_getmd5(s2..ts)

    url = url .. "&uin=" .. (AccountManager:getUin() or 0)
    url = url .. "&s2t=" .. s2t
    url = url .. "&ts=" .. ts
    url = url .. "&auth=" .. auth
    return url
end

function RoomService:GetQuickupRentApiv2BaseUrl(sub,md5)
    local baseUrl = ""
	if get_game_env() == 1 then--测试环境
        -- return "http://10.0.0.134:8002/"
        baseUrl = "http://124.70.174.136:8002/"
    elseif get_game_env() == 2 then--先遣服
        baseUrl = "http://pre-cs-basic-service.mini1.cn:8002/"
    else
        baseUrl = "http://cs-apiserver.mini1.cn/"
    end 

    local url = baseUrl .. (sub or "" ).. "?signType=client"
    local s2, _, ps2t = get_login_sign() -- g_login_sign, g_login_s2t, g_login_pure_s2t
    local s2t = ps2t or "nil"
    local ts = os.time() or "nil"
    local auth = gFunc_getmd5(s2..ts)

    url = url .. "&appid=1000"
    url = url .. "&country=" .. get_game_country() or "nil"
    url = url .. "&language=" .. get_game_lang() or "nil"
    url = url .. "&channel=" .. ClientMgr:getApiId()
    url = url .. "&md5=" .. md5
    url = url .. "&ts=" .. ts
    url = url .. "&sign=" .. auth
    return url
end

function RoomService:CheckMapSupportQuickupRent(mapwid)
    return CheckSupportAllCloud_IsSupport(mapwid)
end

function RoomService:GetQuickupRentMapPlayerNum(mapwid, localFix)
    if localFix then
        return self.m_quickupRentPlayerNum[tostring(mapwid)]
    else
        return rawget(self.m_quickupRentPlayerNum, tostring(mapwid)) or 0
    end
end

--查询好友所在普通联机房间ID信息
function RoomService:ReqQueryFriendRoom(uin, spData)
    spData = spData or {}
	local url = CreateFriendRoomRequest("/server/room")
					:addparam("cmd", "query_friend_room")
					:addparam("des_uin", uin)
					:addparam("src_uin", AccountManager:getUin())
					:finish();

    local retStr = self:SyncRpcRaw(url, spData.outtime or nil, spData.showLoadLoop); 

    local ok, ret = pcall(JSON.decode, JSON, retStr);
    
    return ret
end

---------------------请求地图是否支持快速启动云服------------------------------
function RoomService:ReqMapSupportQuickupRent(mapwid)
    threadpool:work(function()
        self:SyncReqMapSupportQuickupRentMut({mapwid})
    end)
end

function RoomService:SyncReqMapSupportQuickupRentMut(mapwids, callback, timeout, showLoadLoop)
    if not ('table' == type(mapwids) and next(mapwids)) then
        return
    end

    callback = callback or function() end

    local gid = gen_gid();
	local timeout = timeout or 3;
	local bNeedWaiting = true;
	local code = 0;
	local ret = nil
    if showLoadLoop == nil then showLoadLoop = false end

    local rspCallback = function(_ret)
        print("RoomService:SyncReqMapSupportQuickupRentMut:rspCallback:");
        bNeedWaiting = false;
        ret = _ret;
        threadpool:notify(gid, ErrorCode.OK, _ret);
    end

    local loopTag = "file:RoomService - func:SyncReqMapSupportQuickupRentMut " .. gid
    if showLoadLoop then ShowLoadLoopFrame(true, loopTag) end

    ReqMapInfo(mapwids, rspCallback);    
    if not showLoadLoop then
        ShowLoadLoopFrame(false)
    end
    if bNeedWaiting then
        code, _ret = threadpool:wait(gid, timeout);
    end
    
    if ret and type(ret) == 'table' then
        callback(ret)
    end
    
    if showLoadLoop then HideLoadLoopFrameByTag(loopTag) end
end

---------------------请求房间数据部分-----------------------------------------

function RoomService:ReqRoomList()    
    local roomList = {}
    --todo
    return roomList
end

--rtype 小于0时 代表 只搜普通房间
function RoomService:ReqRoomListByUinSync(uin, rtype, showLoadLoop, spData)    
    local roomList = {}
    local errorTip = nil
    rtype = rtype or 0
    spData = spData or {}
    local loginSuc = false
    local returnCode
    local ignoreTimeout = 0
    if spData.ignoreTimeout then
        ignoreTimeout = spData.ignoreTimeout
    end
    
    if showLoadLoop == nil then showLoadLoop = true end
    local loopTag = "file:RoomService - func:ReqRoomListByUinSync " .. gen_gid()
    if showLoadLoop then ShowLoadLoopFrame(true, loopTag) end
    repeat
        --登录房间服务器
        local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if not AccountManager:loginRoomServer(false, 0, genkey) then
            returnCode = GetS(146)
            break
        end
        loginSuc = true
        
        if self:FindSyncWaitingStatus(genkey) then
            local code, _ret = threadpool:wait(gid, 2);
            if code ~= ErrorCode.OK then
                returnCode = "request room info failed,rtype:"..rtype.." code:"..code
                break
            end
            if  _ret ~= genkey then
                returnCode = "request room info failed,rtype:"..rtype.." _ret:".._ret.." genkey:"..genkey
                break
            end
        end

        local filterConnectMode = spData.connect_mode or 0
        --请求普通房间数据
        if rtype <= 0 then
            genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
            self:InsertSyncWaitingStatus(true, genkey)
            if AccountManager:requestRoomListByUin(uin, nil, genkey,ignoreTimeout) then
                if self:FindSyncWaitingStatus(genkey) then
                    local code, _ret, result,failreason = threadpool:wait(gid, spData.outtime or 5);
                    if code == ErrorCode.OK and _ret == genkey then
                        returnCode = "result："..result.." failreason:"..failreason
                        local num = AccountManager:getNumRoom()
                        for i = 1, num do
                            local roomDesc = AccountManager:getIthRoom(i-1)
                            if roomDesc and (filterConnectMode == "any" or roomDesc.connect_mode == filterConnectMode) then
                                table.insert(roomList, AllRoomManager:TransNormalRoomToLuaTb(roomDesc))
                            end
                        end
                        if returnCode == nil and #roomList == 0 then
                            returnCode = "get roomInfo failed getNumRoom:"..num
                        end
                    end
                    if code ~= ErrorCode.OK then
                        returnCode = "wait overtime 1 code:"..code
                        break
                    end
                    if _ret ~= genkey  then
                         returnCode = "wait overtime 2 _ret:".._ret.." genkey:"..genkey
                         break
                    end
                end
            else
                returnCode = GetS(146).."2"
            end
        end

        if rtype >= 0 then
            --请求云服房间数据
            uin = getLongUin(uin);  --海外加10亿
            if ns_version and ns_version.proxy_url then
                local url = ns_version.proxy_url .. '/miniw/rent_server?act=getUinRoomList&search=1&op_uin='..uin.."&" .. http_getS1Map();
                local ret = self:SyncRpc(url, spData.outtime or nil, false)
                if ret == nil then
                    returnCode = "get empty ret overtime"
                    break
                end
                if  ret.ret == nil then
                    if  ret.code then
                        returnCode = "get empty ret.ret,ret.code:"..ret.code
                    else
                        returnCode = "get empty ret.ret"
                    end
                    break
                end
                if ret.ret == 0  then
                    if ret.data == nil then
                        if  ret.code then
                            returnCode = "get empty ret.data,ret.code:"..ret.code
                        else
                            returnCode = "get empty ret.data"
                        end
                        break
                    else
                        for _, data in ipairs(ret.data) do
                            if rtype == 0 or uin .. "_" .. rtype == data._k_ then
                                table.insert(roomList, data)
                            end
                        end
                        if  #roomList == 0 and ret.code then
                            returnCode = "the length of ret.data:"..#ret.data.." ret.code:"..ret.code
                        else
                            returnCode = "the length of ret.data:"..#ret.data
                        end
                        break
                    end
                else
                    if  ret.code then
                        returnCode = "get wrong ret.ret:"..ret.ret.." ret.code:"..ret.code
                    else
                        returnCode = "get wrong ret.ret:"..ret.ret
                    end
                    break
                end
            end    
        end
    until true 
    
    if showLoadLoop then HideLoadLoopFrameByTag(loopTag) end

    return roomList, loginSuc, returnCode
end

--获取随机房间列表
function RoomService:ReqRoomListSync(gameLabel, hostType, mapwid, showLoadLoop, spData)    
    local roomList = {}
    local errorTip = nil
    spData = spData or {}
    
    if showLoadLoop == nil then showLoadLoop = true end
    local loopTag = "file:RoomService - func:ReqRoomListSync " .. gen_gid()
    if showLoadLoop then ShowLoadLoopFrame(true, loopTag) end
    repeat
        --登录房间服务器
        local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if not AccountManager:loginRoomServer(false, 0, genkey) then
            break
        end
        
        if self:FindSyncWaitingStatus(genkey) then
            local code, _ret = threadpool:wait(gid, 2);
            if code ~= ErrorCode.OK or _ret ~= genkey then
                break
            end
        end

        local filterConnectMode = spData.connect_mode or 0
        
        --请求普通房间数据
        genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if AccountManager:requestRoomList(gameLabel or 1, 0, mapwid or "", hostType or 0, "", genkey) then
            if self:FindSyncWaitingStatus(genkey) then
                local code, _ret = threadpool:wait(gid, spData.outtime or 5);
                if code == ErrorCode.OK and _ret == genkey then
                    local num = AccountManager:getNumRoom()
                    for i = 1, num do
                        local roomDesc = AccountManager:getIthRoom(i-1)
                        if roomDesc and roomDesc.connect_mode == filterConnectMode then
                            table.insert(roomList, AllRoomManager:TransNormalRoomToLuaTb(roomDesc))
                        end
                    end
                end
            end
        end

        --请求云服房间数据
        if ns_version and ns_version.proxy_url then
            local url = ns_version.proxy_url.."/miniw/rent_server?act=getRoomListOnline".."&rand=1"
            url = UrlAddAuth(url)
            local ret = self:SyncRpc(url, spData.outtime or nil, false)
            if ret then
                for _, data in ipairs(ret) do
                    table.insert(roomList, data)
                end
            end
        end    
    until true

    if showLoadLoop then HideLoadLoopFrameByTag(loopTag) end

    return roomList, 0
end

--本接口预计将来会弃用，请使用ReqRoomListByMapNew
function RoomService:ReqRoomListByMap(mapwid, showLoadLoop, spData)
    if not mapwid then return {}, 0 end
    
    local roomList = {}
    local errorTip = nil
    spData = spData or {}
    
    if showLoadLoop == nil then showLoadLoop = true end
    local loopTag = "file:RoomService - func:ReqRoomListByMap " .. gen_gid()
    if showLoadLoop then ShowLoadLoopFrame(true, loopTag) end
    repeat
        --登录房间服务器
        local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if not AccountManager:loginRoomServer(false, 0, genkey) then
            break
        end
        
        if self:FindSyncWaitingStatus(genkey) then
            local code, _ret = threadpool:wait(gid, 2);
            if code ~= ErrorCode.OK or _ret ~= genkey then
                break
            end
        end

        local filterConnectMode = spData.connect_mode or 0
        --请求普通房间数据
        genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if AccountManager:requestRoomList(1, 0, mapwid, 0, "", genkey) then
            if self:FindSyncWaitingStatus(genkey) then
                local code, _ret = threadpool:wait(gid, spData.outtime or 5);
                if code == ErrorCode.OK and _ret == genkey then
                    local num = AccountManager:getNumRoom()
                    for i = 1, num do
                        local roomDesc = AccountManager:getIthRoom(i-1)
                        if roomDesc and roomDesc.connect_mode == filterConnectMode then
                            table.insert(roomList, AllRoomManager:TransNormalRoomToLuaTb(roomDesc))
                        end
                    end
                end
            end
        end

        --请求云服房间数据
        if ns_version and ns_version.proxy_url then
            local url = ns_version.proxy_url .. '/miniw/rent_server?act=getMapRoomList&wid=' .. mapwid.. "&" .. http_getS1Map();
            local ret = self:SyncRpc(url, spData.outtime or nil, false)
            if ret and ret.ret == 0 and ret.list then
                for _, data in ipairs(ret.list) do
                    table.insert(roomList, data)
                end
            end
        end    
    until true

    if showLoadLoop then HideLoadLoopFrameByTag(loopTag) end

    return roomList, 0
end

--重要！！！这个接口会返回三类数据结构的房间，普通房间，云服，新云服 三种数据结构不一样！！
function RoomService:ReqRoomListByMapNew(mapwid, showLoadLoop, spData,requestID)
    if not mapwid then return {}, 0 end
    
    local roomList = {}
    local errorTip = nil
    local prinum = 0
    local requestid = requestID
    spData = spData or {}
    
    if showLoadLoop == nil then showLoadLoop = true end
    local loopTag = "file:RoomService - func:ReqRoomListByMap " .. gen_gid()
    if showLoadLoop then ShowLoadLoopFrame(true, loopTag) end
    repeat
        --登录房间服务器
        local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if not AccountManager:loginRoomServer(false, 0, genkey) then
            break
        end
        
        if self:FindSyncWaitingStatus(genkey) then
            local code, _ret = threadpool:wait(gid, 2);
            if code ~= ErrorCode.OK or _ret ~= genkey then
                break
            end
        end

        local filterConnectMode = spData.connect_mode or 0
        --新接口可以同时获取普通房间和云服 （据说）        
        local uin_ = AccountManager:getUin() or get_default_uin()    
        local url = AllRoomManager:CreateRoomServerRequest("/server/room")
                        :addparam("cmd", "get_map_room_list_show")
                        :addparam("map_type", mapwid)
                        :addparam("time", os.time())
                        :addparam("uin", uin_)
                        :finish();
        
        url = url .. "&apdqs=1"
        url = self:AppenAiRecommendSwitchArg(url)

        if requestid == nil and generateRequestID then
            requestid = generateRequestID()
        end
        url = url .."&".."requestid="..requestid
        print("RoomService:ReqRoomListByMapNew")
        
        local retStr = self:SyncRpcRaw(url, spData.outtime or nil, false); 
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if ok and type(ret) == 'table' and tostring(ret.map_type) == tostring(mapwid) then
            if ret.prinum then
                prinum = tonumber(ret.prinum) or 0
            end
            if 'table' == type(ret.roomlist) then
                for _, data in ipairs(ret.roomlist) do
                    local roomType = self:GetRoomType(data)
                    if roomType ~= AllRoomManager.RoomType.Normal then
                        local roomDesc = data
                        table.insert(roomList, roomDesc)
                    else
                        local roomDesc = AllRoomManager:TransHttpNormalRoomNotAdd(data)
                        if roomDesc and roomDesc.connect_mode == filterConnectMode and ((roomDesc.public_type or 0) == 0) then
                            table.insert(roomList, roomDesc)
                        end
                    end
                end
            end
        end
    until true

    if showLoadLoop then HideLoadLoopFrameByTag(loopTag) end

    return roomList, prinum, requestid
end

function RoomService:GetRoomType(roomInfo)
    if roomInfo then
        if roomInfo.is_cloud then
            return AllRoomManager.RoomType.QuickupCloudServer
        elseif roomInfo._k_ then
            return AllRoomManager.RoomType.CloudServer
        else
            return AllRoomManager.RoomType.Normal
        end
    end
end

function RoomService:GetRoomTypeByID(roomID)
    roomID = tostring(roomID)
    if tonumber(roomID) then
        return AllRoomManager.RoomType.Normal
    elseif string.match(roomID, '^%d+_%d+$') then
        return AllRoomManager.RoomType.CloudServer
    elseif string.match(roomID, '^%d+_.+$') then
        return AllRoomManager.RoomType.QuickupCloudServer
    end
end

--联机大厅 获取地图分发式的房间
function RoomService:GetRoomMaps(gameLabel, showLoadLoop, spData)
    local roomMaps = {}
    local errorTip = nil
    local label = gameLabel
    local requestid = nil
    
    spData = spData or {}

    if showLoadLoop == nil then showLoadLoop = true end
    local loopTag = "file:RoomService - func:GetRoomMaps " .. gen_gid()
    if showLoadLoop then ShowLoadLoopFrame(true, loopTag) end
    repeat
        --登录房间服务器
        local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if not AccountManager:loginRoomServer(false, 0, genkey) then
            break
        end
        
        if self:FindSyncWaitingStatus(genkey) then
            local code, _ret = threadpool:wait(gid, 2);
            if code ~= ErrorCode.OK or _ret ~= genkey then
                break
            end
        end

        local uin_ = AccountManager:getUin() or get_default_uin()    
        local url = AllRoomManager:CreateRoomServerRequest("/server/room")
                        :addparam("cmd", "get_map_list")
                        :addparam("game_label", gameLabel)
                        :addparam("time", os.time())
                        :addparam("uin", uin_)
                        :finish();

        if generateRequestID then
            requestid = generateRequestID()
            url = url .."&".."requestid="..requestid
        end
        url = self:AppenAiRecommendSwitchArg(url)

        local retStr = self:SyncRpcRaw(url, spData.outtime or nil, false); 

        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if ok and type(ret) == 'table' then
            if ret.result == 0 then
                roomMaps = ret.list or {}
                label = ret.game_label or gameLabel
            end
        end        
    until true

    for index, value in ipairs(roomMaps) do
        if "table" == type(value) and value.map_type then
            self.m_RoomMapLabelCache[value.map_type] = value.label
        end
    end

    if showLoadLoop then HideLoadLoopFrameByTag(loopTag) end

    return roomMaps, label, requestid

end

function RoomService:GetHotSimpleMaps(gameLabel, flushpos, host_type, showLoadLoop, spData)
    local simpleMaps = {}
    local errorTip = nil
    local requestid = nil
    
    spData = spData or {}

    if showLoadLoop == nil then showLoadLoop = true end
    local loopTag = "file:RoomService - func:GetHotSimpleMaps " .. gen_gid()
    if showLoadLoop then ShowLoadLoopFrame(true, loopTag) end
    repeat
        --登录房间服务器
        local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if not AccountManager:loginRoomServer(false, 0, genkey) then
            break
        end
        
        if self:FindSyncWaitingStatus(genkey) then
            local code, _ret = threadpool:wait(gid, 2);
            if code ~= ErrorCode.OK or _ret ~= genkey then
                break
            end
        end

        local uin_ = AccountManager:getUin() or get_default_uin()    
        local url = AllRoomManager:CreateRoomServerRequest("/server/room")
                        :addparam("cmd", "query_hot_map")
                        :addparam("flush_pos", flushpos)
                        :addparam("game_label", gameLabel)
                        :addparam("host_type", host_type)
                        :finish();


        local retStr = self:SyncRpcRaw(url, spData.outtime or nil, false); 

        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if ok and type(ret) == 'table' then
            if ret.result == 0 then
                simpleMaps = ret.hot_map or {}
            end
        end        
    until true

    if showLoadLoop then HideLoadLoopFrameByTag(loopTag) end

    return simpleMaps
end

function RoomService:GetCollectRooms(spData)
    local normalRooms = {}
    local cloudRooms = {}
    local errorTip = nil
    local requestid = nil
    
    spData = spData or {}

    if showLoadLoop == nil then showLoadLoop = true end
    local loopTag = "file:RoomService - func:GetCollectRooms " .. gen_gid()
    if showLoadLoop then ShowLoadLoopFrame(true, loopTag) end
    repeat
        --登录房间服务器
        local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if not AccountManager:loginRoomServer(false, 0, genkey) then
            break
        end
        
        if self:FindSyncWaitingStatus(genkey) then
            local code, _ret = threadpool:wait(gid, 2);
            if code ~= ErrorCode.OK or _ret ~= genkey then
                break
            end
        end

        repeat
            local filterConnectMode = spData.connect_mode or 0
            if AccountManager:getAccountData():getCollectUinNum() == 0 then
                break
            end

            self:InsertSyncWaitingStatus(true, genkey)
            if not AccountManager:requestRoomListByCollect(genkey) then
                self:InsertSyncWaitingStatus(false, genkey)
                break
            end
            
            if self:FindSyncWaitingStatus(genkey) then
                local code, _ret = threadpool:wait(gid, spData.outtime or 4);
                if code ~= ErrorCode.OK or _ret ~= genkey then
                    break
                end
            end

            local num = AccountManager:getNumRoom();
            for index = 1, num, 1 do
                local roomDesc  = AccountManager:getIthRoom(index-1);
                if roomDesc and roomDesc.connect_mode == filterConnectMode then
                    table.insert(normalRooms, AllRoomManager:TransNormalRoomToLuaTb(roomDesc))
                end
            end
            
            break
        until true
        
        break
    until true

    if showLoadLoop then HideLoadLoopFrameByTag(loopTag) end

    return normalRooms
end

function RoomService:GetRoomMapsByWids(wids, showLoadLoop, spData)
    local roomMaps = {}
    local errorTip = nil
    
    spData = spData or {}

    if showLoadLoop == nil then showLoadLoop = true end
    local loopTag = "file:RoomService - func:GetRoomMapsByWids " .. gen_gid()
    if showLoadLoop then ShowLoadLoopFrame(true, loopTag) end
    repeat
        if not (wids and next(wids)) then
            break
        end
        --登录房间服务器
        local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if not AccountManager:loginRoomServer(false, 0, genkey) then
            break
        end
        
        if self:FindSyncWaitingStatus(genkey) then
            local code, _ret = threadpool:wait(gid, 2);
            if code ~= ErrorCode.OK or _ret ~= genkey then
                break
            end
        end

        local uin_ = AccountManager:getUin() or get_default_uin()    
        local url = AllRoomManager:CreateRoomServerRequest("/server/room")
                        :addparam("cmd", "get_map_list_by_ids")
                        :addparam("map_ids", table.concat(wids, ','))
                        :addparam("time", os.time())
                        :addparam("uin", uin_)
                        :finish();


        local retStr = self:SyncRpcRaw(url, spData.outtime or nil, false); 

        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if ok and type(ret) == 'table' then
            if ret.result == 0 then
                roomMaps = ret.list or {}
            end
        end
        
        for index, value in ipairs(roomMaps) do
            if "table" == type(value) and value.map_type then
                self.m_RoomMapLabelCache[value.map_type] = value.label
            end
        end
    until true

    if showLoadLoop then HideLoadLoopFrameByTag(loopTag) end

    return roomMaps

end

function RoomService:GetAIUrlByMatchingType(mapwid, type, requestid)
    type = type or {};
    local uin_ = AccountManager:getUin() or get_default_uin() 
    local url;
    if type.onlyCloud then  
        url = AllRoomManager:CreateRoomServerRequest("/server/room")
                        :addparam("apdqs", 1)
                        :addparam("cmd", "get_map_room_list_by_section")
                        :addparam("map_id", mapwid)
                        :addparam("requestid", requestid or 0)
                        :addparam("time", os.time())
                        :addparam("uin", uin_)
                        :finish();
    else
        url = AllRoomManager:CreateRoomServerRequest("/server/room")
                        :addparam("cmd", "get_map_room_list")
                        :addparam("map_type", mapwid)
                        :addparam("time", os.time())
                        :addparam("uin", uin_)
                        :finish();
        url = url .. "&apdqs=1"
        if requestid then
            url = url .."&".."requestid="..requestid
        end
    end
    
    return self:AppenAiRecommendSwitchArg(url);
end

--获取自动匹配的房间，AI大数据接口，只有快速匹配的时候才能调用，别的地方不要调用
--重要！！！这个接口会返回三类数据结构的房间，普通房间，云服，新云服 三种数据结构不一样！！
function RoomService:ReqAutoMatchRoomsAi(mapwid, showLoadLoop, spData)
    if not mapwid then return {}, 0 end
    
    local roomList = {}
    local errorTip = nil
    local prinum = 0
    spData = spData or {}
    local requestid = nil
    if generateRequestID then
        requestid = generateRequestID()
    end
    if showLoadLoop == nil then showLoadLoop = true end
    local loopTag = "file:RoomService - func:ReqAutoMatchRoomsAi " .. gen_gid()
    if showLoadLoop then ShowLoadLoopFrame(true, loopTag) end
    repeat
        --登录房间服务器
        local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if not AccountManager:loginRoomServer(false, 0, genkey) then
            break
        end
        
        if self:FindSyncWaitingStatus(genkey) then
            local code, _ret = threadpool:wait(gid, 2);
            if code ~= ErrorCode.OK or _ret ~= genkey then
                break
            end
        end

        local filterConnectMode = spData.connect_mode or 0
        --新接口可以同时获取普通房间和云服 （据说）        
        local url = self:GetAIUrlByMatchingType(mapwid, spData.matchingType, requestid)
        
        print("RoomService:ReqAutoMatchRoomsAi")
        
        local retStr = self:SyncRpcRaw(url, spData.outtime or nil, false); 
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if ok and type(ret) == 'table' then
            prinum = ret.prinum or 0
            if ret.roomlist then
                -- local test = {
                --     aid = "1108306069284",
                --     code = 0,
                --     czb_uuid = "",
                --     ip = "124.70.174.244",
                --     is_cloud = true,
                --     mod_url = "",
                --     msg = "found",
                --     nick_name = "迷你小队长",
                --     player_num = 0,
                --     port = 11849,
                --     room_cap = 6,
                --     room_mods = "",
                --     room_name = "石430的玩法",
                --     room_ui_libs = "",
                --     room_ver = "1.3.0",
                --     roomid = "64520_41947282-d64b-4d57-8e91-cd7fb18bedc4",
                --     uin = 1000
                -- }
                -- table.insert(ret.roomlist, test)
                for index, data in ipairs(ret.roomlist) do
                    local roomType = self:GetRoomType(data)
                    if roomType ~= AllRoomManager.RoomType.Normal then
                        local roomDesc = data
                        table.insert(roomList, roomDesc)
                    else
                        local roomDesc = AllRoomManager:TransHttpNormalRoomNotAdd(data)
                        if roomDesc and roomDesc.connect_mode == filterConnectMode and ((roomDesc.public_type or 0) == 0) then
                            table.insert(roomList, roomDesc)
                        end
                    end
                end
            end
        end
        
    until true

    if showLoadLoop then HideLoadLoopFrameByTag(loopTag) end

    return roomList, prinum, requestid
end

--一键拉起云服功能 doc https://mini1.feishu.cn/docs/doccnPJTJVLyA9JBeaOlVjWWktN
function RoomService:GetAppendQuickupPostData(appendTb, formatType)
    local tb = { }
    if "table" == type(appendTb) then
        for key, value in pairs(appendTb) do
            tb[key] = value
        end
    end
    
    tb.uin = AccountManager:getUin() or 0
    tb.version = ClientMgr:clientVersionToStr(ClientMgr:clientVersion()) or "nil"
    tb.apiid = ClientMgr:getApiId() or "nil"
    tb.cltapiid = tb.apiid
    tb.cltversion = ClientMgr:clientVersion() or 0
    tb.country = get_game_country() or "nil"
    tb.language = get_game_lang() or "nil"
    tb.log_id = get_log_id() or "nil"
    tb.session_id = get_session_id() or "nil"
    tb.env = get_game_env()
    if not tb.game_session_id then
        tb.game_session_id = get_game_session_id() or "nil"
    end

    local  s2, _, ps2t = get_login_sign() -- g_login_sign, g_login_s2t, g_login_pure_s2t
    tb.s2t = ps2t or "nil"
    tb.ts = os.time() or "nil"
    tb.auth = gFunc_getmd5(s2..tb.ts)

    local postStr = ""
    if formatType == "json" then
        local ok, jsonStr = pcall(JSON.encode, JSON, tb)
        postStr = jsonStr or ""
    else        
        local isFirst = #postStr == 0
        for key, value in pairs(tb) do
            postStr = postStr .. (isFirst and "" or "&") .. key .. "=" .. value
            isFirst = false
        end
    end

    print("GetAppendQuickupPostData  " .. postStr)
    return postStr
end

--请求一键云服地图游玩人数
function RoomService:ReqQuickUpMapPlayerCount(mapwids, spData)
    spData = spData or {}
    
    local retTab = {}

    if "table" ~= type(mapwids) or not next(mapwids) then
        return retTab
    end
    
    local url = self:GetQuickupRentApiBaseUrl("api/v1/map/queryMapPlayerCount")
    spData.outtime = spData.outtime or 15
    
    local postStr = "area=inland"
    for index, value in ipairs(mapwids) do
        postStr = postStr .. "&aid=" .. value
    end

    local loadLoopInfo = {
        showLoadLoop = spData.showLoadLoop, 
        loadLoopType = 2, 
    }
    local retStr = self:SyncRpcPost(url, postStr, spData.outtime, loadLoopInfo)
    print("ReqQuickUpMapPlayerCount retStr " .. tostring(retStr))
    repeat
        if not retStr then
            break
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table' and type(ret.data) == 'table') then
            break
        end    

        local data = ret.data
        if not (type(data.list) == 'table') then
            break
        end    

        for _, value in ipairs(data.list) do
            if "table" == type(value) then
                if value.aid then
                    retTab[tostring(value.aid)] = tonumber(value.online)
                    self.m_quickupRentPlayerNum[tostring(value.aid)] = tonumber(value.online)
                end
            end
        end
        break
    until true

    return retTab
end

--请求玩家所在的一键云服信息
function RoomService:ReqQuickUpPlayerRoomInfo(uin, spData)
    spData = spData or {}
    
    if not uin then
        return nil
    end
    
    local url = self:GetQuickupRentApiBaseUrl("api/v1/player/queryPlayerRoomInfo")
    spData.outtime = spData.outtime or 15
    
    local postStr = "desUin=" ..  uin

    local loadLoopInfo = {
        showLoadLoop = spData.showLoadLoop, 
        loadLoopType = spData.loadLoopType or 2, 
    }
    local retStr = self:SyncRpcPost(url, postStr, spData.outtime, loadLoopInfo)
    print("ReqQuickUpPlayerRoomInfo retStr " .. tostring(retStr))
    repeat
        if not retStr then
            break
        end
        
        local ok, temp = pcall(JSON.decode, JSON, retStr);
        if not (ok and temp.code == 0 and type(temp) == 'table' and type(temp.data) == 'table') then
            break
        end

        local retData = self:ReqQueryQuickupCSRoom(temp.data.roomId, spData)
        local roomDesc = retData.roomDesc
        if not roomDesc or "table" ~= type(roomDesc)  then
            break
        end

        if "table" == type(temp.data.Extra) and next(temp.data.Extra) then
            roomDesc.Extra = temp.data.Extra
        end
    
        return roomDesc
    until true

    return nil
end

--获取所有云服房间列表
function RoomService:ReqListAllRoomInfo(aid, spData)
    spData = spData or {}

    if not aid then
        return nil
    end

    local postStr = {
        aid = aid,
    }

    local md5 = gFunc_getmd5(JSON:encode(postStr))

    local url = self:GetQuickupRentApiv2BaseUrl("api/v2/room/listAllRoom",md5)

    postStr = self:GetAppendQuickupPostData(postStr)

    local loadLoopInfo = {
        showLoadLoop = spData.showLoadLoop, 
        loadLoopType = spData.loadLoopType or 2, 
    }
    local retStr = self:SyncRpcPost(url, postStr, spData.outtime, loadLoopInfo)
    print("ReqListAllRoomInfo retStr " .. tostring(retStr))
    repeat
        if not retStr then
            break
        end
        
        local ok, temp = pcall(JSON.decode, JSON, retStr);
        if not (ok and temp.code == 0 and type(temp) == 'table' and type(temp.data) == 'table') then
            break
        end
    
        return temp.data
    until true

    return nil
end

--根据地图请求一键调起云服，该接口一定会创建新云服房间（返回的云服信息，不是常规完整的云服信息）
function RoomService:ReqCreateQuickupCSRoomByMap(mapwid, spData)
    spData = spData or {}
    if not mapwid then
        return false, nil, -1
    end
    
    local failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
    local baseUrl = self:GetQuickupRentBaseUrl(spData.rentDebug)
    spData.outtime = spData.outtime or 15

    local url = baseUrl .. "v2/room/create"
    local lua_game_session_id = standReportGenerateGameSessionId()
    local append = {
        aid = mapwid,
        max_player = spData.maxPeople or 6,
        mode = spData.authority or 6,
        style = spData.style or 0,
        password = tostring(spData.password or ""),
        game_session_id = lua_game_session_id,

        scene = spData.scene or enum_scene.Activity, --场景id 大厅18 地图详情48 地图房间列表48/1004 活动50 联机失败后兜底51
        appid = spData.appid or enum_appid.Mini, --业务id  迷你世界1000 
    }

    local postStr = self:GetAppendQuickupPostData(append)

    local loadLoopInfo = {
        showLoadLoop = spData.showLoadLoop, 
        loadLoopType = 2, 
    }
    local retStr, errorCode = self:SyncRpcPost(url, postStr, spData.outtime, loadLoopInfo, spData.rentDebug)
    print("ReqCreateQuickupCSRoomByMap retStr " .. tostring(retStr))
    local tips = GetS(35888)
    if ErrorCode.TIMEOUT == errorCode then
        failedCode = RoomService.failed_code.REQ_OUT_TIME
    end
    repeat
        if not retStr then
            break
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table') then
            break
        end

        if ret.code ~= 0 then
            failedCode = ret.code*1000 + RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end    
    
        local _, port = pcall(tonumber, ret.port)
        if not (port and port > 0) then
            failedCode = RoomService.failed_code.NO_PORT
            break
        end
        ret.port = port

        return self:inFunc_ReqStartJoinQuickupRent(ret, spData, {standby3 = 2, lua_game_session_id = lua_game_session_id}, spData.password)
    until true

    tips = self:GetErrorCodeTip(failedCode)
    return false, string.format("%s(%s)", tostring(tips) or "", tostring(failedCode or 0)), failedCode
end

--根据地图请求一键调起云服，该接口一定会创建新云服房间（返回的云服信息，不是常规完整的云服信息）
function RoomService:ReqCreateCloudRoomByMap(mapwid, spData)
    spData = spData or {}
    if not mapwid then
        return false, nil, -1
    end
    
    local failedCode = 13
    local baseUrl = self:GetQuickupRentBaseUrl(spData.rentDebug)
    spData.outtime = spData.outtime or 15

    local url = baseUrl .. "v2/room/create"
    local lua_game_session_id = standReportGenerateGameSessionId()
    local append = {
        appid = 1000,
        aid = mapwid,
        max_player = spData.maxPeople or 6,
        mode = spData.authority or 6,
        style = spData.style or 0,
        password = tostring(spData.password or ""),
        game_session_id = lua_game_session_id,

        scene = spData.scene or enum_scene.Activity, --场景id 大厅18 地图详情48 地图房间列表48/1004 活动50 联机失败后兜底51
        appid = spData.appid or enum_appid.Mini, --业务id  迷你世界1000 
    }

    local postStr = self:GetAppendQuickupPostData(append)
    local loadLoopInfo = {
        showLoadLoop = spData.showLoadLoop, 
        loadLoopType = 2, 
    }
    local retStr = self:SyncRpcPost(url, postStr, spData.outtime, loadLoopInfo)
    print("ReqCreateQuickupCSRoomByMap retStr " .. tostring(retStr))
    local tips = GetS(35888)
    repeat
        if not retStr then
            break
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table' and ret.code == 0) then
            break
        end
    
        local _, port = pcall(tonumber, ret.port)
        if not (port and port > 0) then
            break
        end
        ret.port = port

        return self:inFunc_ReqStartJoinQuickupRent(ret, spData, {standby3 = 2, lua_game_session_id = lua_game_session_id}, spData.password)
    until true

    tips = self:GetErrorCodeTip(failedCode)
    return false, tips, failedCode
end

--该接口跳过地图支持检查进入一键云服
--请仅在做活动类功能中需要通过地图ID进入云服地图时使用
--spData可为nil
function RoomService:ReqForceJoinQuickupCSRoomByMap(mapwid, spData, ...)
    spData = spData or {}
    spData.forceQuickUpCSRoom = true
    return self:ReqJoinQuickupCSRoomByMap(mapwid, spData, ...)
end


--根据地图请求一键调起云服，该接口可能会创建云服房间（返回的云服信息，不是常规完整的云服信息）
function RoomService:ReqJoinQuickupCSRoomByMap(mapwid, spData, desc, bkg, looptype)
    spData = spData or {}
    --desc = desc or GetS(101402)
    --bkg = bkg or "LoadLoopFrame2Bkg"
    looptype = looptype or 2

    if not (mapwid and (spData.forceQuickUpCSRoom or self:CheckMapSupportQuickupRent(mapwid))) then
        return false, nil, -1
    end
    
    local failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
    local baseUrl = self:GetQuickupRentBaseUrl(spData.rentDebug)
    spData.outtime = spData.outtime or 15

    local url = baseUrl .. "v2/room/get"
    local lua_game_session_id = standReportGenerateGameSessionId()
    local append = {
        aid = mapwid,
        game_session_id = lua_game_session_id,

        scene = spData.scene or enum_scene.Activity, --场景id 大厅18 地图详情48 地图房间列表48/1004 活动50 联机失败后兜底51
        appid = spData.appid or enum_appid.Mini, --业务id  迷你世界1000 
    }
    if spData.last_room_id then
        append.last_room_id = spData.last_room_id
    end
    local postStr = self:GetAppendQuickupPostData(append)

    local loadLoopInfo = {
        showLoadLoop = spData.showLoadLoop, 
        loadLoopType = looptype, 
        loopDesc = desc, 
        bkgName = bkg,
    }
    local retStr = self:SyncRpcPost(url, postStr, spData.outtime, loadLoopInfo)
    print("ReqJoinQuickupCSRoomByMap retStr " .. tostring(retStr))
    local tips = GetS(35888)
    repeat
        if not retStr then
            break
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table') then
            failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end

        if ret.code ~= 0 then
            failedCode = ret.code*1000 + RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end    
    
        local _, port = pcall(tonumber, ret.port)
        if not (port and port > 0) then
            failedCode = RoomService.failed_code.NO_PORT
            break
        end
        ret.port = port
        if ClientCurGame:isInGame() then
            EnterMainMenuInfo.JoinQuickupRent = {}
            EnterMainMenuInfo.JoinQuickupRent.func = function ()
                return self:inFunc_ReqStartJoinQuickupRent(ret, spData, {standby3 = 1, lua_game_session_id = lua_game_session_id})
            end
            HideUI2GoMainMenu();
            ClientMgr:gotoGame("MainMenuStage");
            return true
        end
        return self:inFunc_ReqStartJoinQuickupRent(ret, spData, {standby3 = 1, lua_game_session_id = lua_game_session_id})
    until true

    tips = self:GetErrorCodeTip(failedCode)
    return false, string.format("%s(%s)", tostring(tips) or "", tostring(failedCode or 0)), failedCode
end

--根据地图房间信息进入云服
function RoomService:ReqJoinQuickupCSRoomByActRoomInfo(session_id, ret, spData)
    spData = spData or {}
    
    local failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
    local tips = GetS(35888)
    repeat
        if ret.code ~= 0 then
            failedCode = ret.code*1000 + RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end    
    
        local _, port = pcall(tonumber, ret.port)
        if not (port and port > 0) then
            failedCode = RoomService.failed_code.NO_PORT
            break
        end
        ret.port = port
        if ClientCurGame:isInGame() then
            EnterMainMenuInfo.JoinQuickupRent = {}
            EnterMainMenuInfo.JoinQuickupRent.func = function ()
                return self:inFunc_ReqStartJoinQuickupRent(ret, spData, {standby3 = 1, lua_game_session_id = session_id}, nil, nil, {ver=true})
            end
            HideUI2GoMainMenu();
            ClientMgr:gotoGame("MainMenuStage");
            return true
        end
        return self:inFunc_ReqStartJoinQuickupRent(ret, spData, {standby3 = 1, lua_game_session_id = session_id}, nil, nil, {ver=true})
    until true

    tips = self:GetErrorCodeTip(failedCode)
    return false, string.format("%s(%s)", tostring(tips) or "", tostring(failedCode or 0)), failedCode
end

-- 多人跨地图传送  云服中需要客户端上报reqBody
function RoomService:ReqJoinQuickupCSRoomByMultiTeleport(mapwid, members, position, reqBody, callBack)
    print("ReqJoinQuickupCSRoomByMultiTeleport req ", mapwid, members, position, reqBody)
    local baseUrl = self:GetQuickupRentBaseUrl()
    local url = baseUrl .. "v2/room/get"
    -- 透传参数
    local params = {
        msgtype = 2,
        members = members,
        pos = position
    }
    -- teammate 中不要发起者，发起者目前是members中最后一个
    local teammate = deep_copy_table(members)
    teammate[#teammate] = nil
    local memberStr = table.concat(teammate, ",")
    
    local postStr = reqBody .. "&aid=" .. mapwid .. "&teammate=".. memberStr.. "&trans_msg=" .. table2json(params)

    -- 服务器传送门增加业务id与场景id
    local appid = nil
    if _G.IsServerBuild and zmqMgr_ then
        appid = zmqMgr_:GetBussinessid()
    end
    if not appid or appid == 0 then
        appid = enum_appid.Mini
    end
    postStr = postStr .. "&scene=" .. tostring(enum_scene.MapTeleport) .. "&appid=" .. tostring(appid)

    print("ReqJoinQuickupCSRoomByMultiTeleport postStr ", postStr)
    local loadLoopInfo = {
        showLoadLoop = false, 
        loadLoopType = 2, 
    }
    local retStr = self:SyncRpcPost(url, postStr, 15, loadLoopInfo)
    print("ReqJoinQuickupCSRoomByMultiTeleport retStr ", retStr)
    
    local errCode = 0;
    local ret = nil
    repeat
        if not retStr then
            errCode = 1; break
        end
        
        local ok = nil
        ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table' and ret.code == 0) then
            errCode = 2; break
        end
    
        local _, port = pcall(tonumber, ret.port)
        if not (port and port > 0) then
            errCode = 3; break
        end
        ret.port = port
    until true
    
    if callBack then callBack(errCode, ret) end
end

--根据房间ID请求一键调起云服的信息，该接口不会新创建房间（返回的云服信息，不是常规完整的云服信息）
--spData.mustNopwd 必须无密码
function RoomService:ReqJoinDesQuickupCSRoom(roomid, spData, password)
    if not roomid then
        SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinOneKeyCloudRoom",  SandboxContext():SetData_Number("code", 235))
        return false, nil, -1
    end
    
    spData = spData or {}
    local failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
    local baseUrl = self:GetQuickupRentBaseUrl(spData.rentDebug)
    spData.outtime = spData.outtime or 6

    local url = baseUrl .. "v2/room/query"
    local lua_game_session_id = standReportGenerateGameSessionId()
    local append = {
        roomid = roomid,
        game_session_id = lua_game_session_id,

        scene = spData.scene or enum_scene.Activity, --场景id 大厅18 地图详情48 地图房间列表48/1004 活动50 联机失败后兜底51
        appid = spData.appid or enum_appid.Mini, --业务id  迷你世界1000 
    }
    local postStr = self:GetAppendQuickupPostData(append)

    --MiniBase查询要加特殊处理
    if MiniBaseManager:isMiniBaseGame() then
        postStr = postStr..MiniBaseManager:getQueryExtraParam()
    end

    local loadLoopInfo = {
        showLoadLoop = spData.showLoadLoop, 
        loadLoopType = 2, 
    }
    local retStr = self:SyncRpcPost(url, postStr, spData.outtime, loadLoopInfo)

    print("ReqJoinDesQuickupCSRoom retStr " .. tostring(retStr))
    
    local tips = GetS(35888)
    repeat
        if not retStr then
            break
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table') then
            tips = GetS(26014)
            failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end

        if ret.code ~= 0 then
            tips = GetS(26014)
            failedCode = ret.code*1000 + RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end

        local _, port = pcall(tonumber, ret.port)
        if not (port and port > 0) then
            failedCode = RoomService.failed_code.NO_PORT
            break
        end
        ret.port = port

        --test
        -- ret.passwd_md5 =  gFunc_getmd5("1234" .. ret.roomid)
        --endtest
        if ret.passwd then
            password = ret.passwd
        end
        if ret.passwd_md5 and ret.passwd_md5 ~= "" then
            if spData.mustNopwd or ret.passwd_md5 ~= gFunc_getmd5(tostring(password) .. tostring(ret.roomid)) then
                tips = GetS(567)
                failedCode = RoomService.failed_code.WRONG_PASSWD
                break
            end
        end

        return self:inFunc_ReqStartJoinQuickupRent(ret, spData, {standby3 = 0, lua_game_session_id = lua_game_session_id}, password)
    until true

    tips = self:GetErrorCodeTip(failedCode)
    return false, string.format("%s(%s)", tostring(tips) or "", tostring(failedCode or 0)), failedCode
end

--根据房间ID请求查询一键调起云服的信息 （返回的云服信息，不是常规完整的云服信息）
function RoomService:ReqQueryQuickupCSRoom(roomid, spData)
    local returnRet = {
        roomDesc = nil,
        tipsStrId = nil,
    }
    if not roomid then
        returnRet.tipsStrId = "roomid is null"
        return returnRet
    end
    
    spData = spData or {}
    local failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
    local baseUrl = self:GetQuickupRentBaseUrl(spData.rentDebug)
    spData.outtime = spData.outtime or 6

    local url = baseUrl .. "v2/room/query"
    local append = {
        roomid = roomid,
        game_session_id = 'nil',

        scene = spData.scene or enum_scene.Activity, --场景id 大厅18 地图详情48 地图房间列表48/1004 活动50 联机失败后兜底51
        appid = spData.appid or enum_appid.Mini, --业务id  迷你世界1000 
    }
    local postStr = self:GetAppendQuickupPostData(append)

    local loadLoopInfo = {
        showLoadLoop = spData.showLoadLoop, 
        loadLoopType = 2, 
    }
    local retStr = self:SyncRpcPost(url, postStr, spData.outtime, loadLoopInfo)

    print("ReqQueryQuickupCSRoom retStr " .. tostring(retStr))
    
    repeat
        if not retStr then
            returnRet.tipsStrId = "retStr is null"
            break
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table') then
            failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
            returnRet.tipsStrId = self:GetErrorCodeTip(failedCode)
            break
        end
    
        if ret.code ~= 0 then
            -- failedCode = ret.code*1000 + RoomService.failed_code.ROOM_NOT_EXISTS
            local code = tonumber(ret.code)
            local codeStringID = 35888
            if self.define.errorCode[code] then
                codeStringID = self.define.errorCode[code]
            end
            returnRet.tipsStrId = codeStringID
            
            -- 活动组队
            if code == 22 then 
                if g_jump_ui_switch[90] then 
                    g_jump_ui_switch[90]()
                end 
            end 
            
            break
        end
    
        local _, port = pcall(tonumber, ret.port)
        if not (port and port > 0) then
            failedCode = RoomService.failed_code.NO_PORT
            returnRet.tipsStrId = "lack port"
            break
        end
        ret.port = port

        --test
        -- ret.passwd_md5 =  gFunc_getmd5("1234" .. ret.roomid)
        --endtest
        returnRet.roomDesc = ret
    until true

    return returnRet
end

function RoomService:ReqCreatePersonalQuickupCSRoom(mapwid, spData)
    spData = spData or {}
    if not mapwid then
        return false, nil, -1
    end
    
    local failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
    local baseUrl = self:GetQuickupRentBaseUrl(spData.rentDebug)
    spData.outtime = spData.outtime or 15

    local url = baseUrl .. "v2/personal_room/create"
    local lua_game_session_id = standReportGenerateGameSessionId()
    local append = {
        --appid = 1000,
        aid = mapwid,
        -- max_player = spData.maxPeople or 6,
        mode = spData.authority or 6,
        style = spData.style or 0,
        password = tostring(spData.password or ""),
        game_session_id = lua_game_session_id,

        scene = spData.scene or enum_scene.MapDetail, --默认地图详情 场景id 大厅18 地图详情48 地图房间列表48/1004 活动50 联机失败后兜底51
        appid = spData.appid or enum_appid.Mini, --业务id  迷你世界1000 
    }

    local postStr = self:GetAppendQuickupPostData(append)

    local loadLoopInfo = {
        showLoadLoop = spData.showLoadLoop, 
        loadLoopType = 2, 
    }
    local retStr = self:SyncRpcPost(url, postStr, spData.outtime, loadLoopInfo)
    print("ReqCreatePersonalQuickupCSRoom retStr " .. tostring(retStr))
    local tips = GetS(35888)
    repeat
        if not retStr then
            break
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table') then
            failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end
    
        if ret.code ~= 0 then
            failedCode = ret.code*1000 + RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end
    
        local _, port = pcall(tonumber, ret.port)
        if not (port and port > 0) then
            failedCode = RoomService.failed_code.NO_PORT
            break
        end
        ret.port = port

        local password = ret.passwd or ""
        
        return self:inFunc_ReqStartJoinQuickupRent(ret, spData, {standby3 = 2, lua_game_session_id = lua_game_session_id}, password, 1)
    until true

    tips = self:GetErrorCodeTip(failedCode)
    return false, string.format("%s(%s)", tostring(tips) or "", tostring(failedCode or 0)), failedCode
end

function RoomService:ReqCreatePersonalQuickupCSRoomNotEnter(mapwid, spData)
    spData = spData or {}
    if not mapwid then
        return false, nil, -1
    end
    
    local failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
    local baseUrl = self:GetQuickupRentBaseUrl(spData.rentDebug)
    spData.outtime = spData.outtime or 15

    local url = baseUrl .. "v2/personal_room/create"
    local lua_game_session_id = standReportGenerateGameSessionId()
    local append = {
        --appid = 1000,
        aid = mapwid,
        -- max_player = spData.maxPeople or 6,
        mode = spData.authority or 6,
        style = spData.style or 0,
        password = tostring(spData.password or ""),
        game_session_id = lua_game_session_id,

        scene = spData.scene or enum_scene.MapDetail, --默认地图详情 场景id 大厅18 地图详情48 地图房间列表48/1004 活动50 联机失败后兜底51
        appid = spData.appid or enum_appid.Mini, --业务id  迷你世界1000 
    }

    local postStr = self:GetAppendQuickupPostData(append)

    local loadLoopInfo = {
        showLoadLoop = spData.showLoadLoop, 
        loadLoopType = 2, 
    }
    local retStr = self:SyncRpcPost(url, postStr, spData.outtime, loadLoopInfo)
    print("ReqCreatePersonalQuickupCSRoom retStr " .. tostring(retStr))
    local tips = GetS(35888)
    repeat
        if not retStr then
            break
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);
        if not (ok and type(ret) == 'table') then
            failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end
    
        if ret.code ~= 0 then
            failedCode = ret.code*1000 + RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end
    
        local _, port = pcall(tonumber, ret.port)
        if not (port and port > 0) then
            failedCode = RoomService.failed_code.NO_PORT
            break
        end
        ret.port = port

        local password = ret.passwd or ""
        
        return true, "", failedCode, ret
    until true

    tips = self:GetErrorCodeTip(failedCode)
    return false, string.format("%s(%s)", tostring(tips) or "", tostring(failedCode or 0)), failedCode
end

--不允许直接调
-- @param isCreate 是否是自己创建的私人云服 1:是 0 or nil：不是
function RoomService:inFunc_ReqStartJoinQuickupRent(roomDesc, spData, appendRptTb, password, isCreate, condition)
    local checker_uin = AccountManager:getUin()
	if IsUserOuterChecker(checker_uin) and not DeveloperAdCheckerUser(checker_uin) then
		ShowGameTips(GetS(100300), 3)
        return nil;
	end
    local failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
    local callRet = false
    local loopTag = "RoomService:inFunc_ReqStartJoinQuickupRent"
    spData = spData or {}
    spData.outtime = spData.outtime or 6
    
    if nil == spData.showLoadLoop then
        spData.showLoadLoop = true
    end
    local tips = spData.baseTip or GetS(35888)
    if isCreate and isCreate == 1 then
        GetInst("ReportGameDataManager"):SetRoomType(5)
    end
    repeat
        if not roomDesc then
            break
        end

        if spData.showLoadLoop then
            ShowLoadLoopFrame2(true, loopTag, spData.outtime);
        end

        local check, checkCode = AllRoomManager:CheckRoomDescCondition(roomDesc, AllRoomManager.RoomType.QuickupCloudServer, condition)
        if not check then
            failedCode = checkCode
            if 20 == checkCode then
                tips = GetS(572)
            elseif 10 == checkCode then
                tips = GetS(566)
            end
            break
        end
        
        --登录房间服务器
        local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)
        if not AccountManager:loginRoomServer(false, 0, genkey) then
            break
        end
        
        if self:FindSyncWaitingStatus(genkey) then
            local code, _ret = threadpool:wait(gid, 2);
            if code ~= ErrorCode.OK or _ret ~= genkey then
                break
            end
        end

        local serverid = roomDesc.roomid
        local ip = roomDesc.ip
        local fromowid = tonumber(roomDesc.aid)
        local curPlayerNum = roomDesc.player_num or 0
        local maxPlayerNum = roomDesc.room_cap or 6
        local port = roomDesc.port
        local room_name = roomDesc.room_name or ""
        
        if get_game_env() == 1 then--测试环境
            room_name = "一键"..room_name
        end

        if curPlayerNum >= maxPlayerNum then
            tips = GetS(566)
            failedCode = RoomService.failed_code.ROOM_FULL
            break
        end

        local ok, czb_uuid = pcall(tonumber, roomDesc.czb_uuid)
        
        local cloudRoomModInfo = {
            modurl = roomDesc.mod_url,
            roomMods = roomDesc.room_mods,
            roomUILibs = roomDesc.room_ui_libs,
            czb_uuid = czb_uuid,
            fromowid = fromowid,
            roomAudioConfig = roomDesc.room_audio_config,
        }

        AccountManager:addRentHostAddress(serverid, ip, port)
        SetCloudRoomModInfo(cloudRoomModInfo)
        
        local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_SYNC_THREAD_NOTIFY)
        self:InsertSyncWaitingStatus(true, genkey)

        local hostUin = 1000
        if roomDesc.personal == 1 then
            hostUin = tonumber(string.match(roomDesc.roomid or "", "^%d+")) or 1000
        end

        if not AccountManager:requestConnectRentWorld(hostUin, password or "", 0, maxPlayerNum, 0, serverid, genkey) then
            failedCode = RoomService.failed_code.CONNECT_FAILED
            break
        end
        
        local result = -10
        if self:FindSyncWaitingStatus(genkey) then
            local code, _ret, _result = threadpool:wait(gid, spData.outtime or 2);
            if code ~= ErrorCode.OK or _ret ~= genkey then
                break
            end
            result = _result
        end

        failedCode = result
        if result == 9 then
            --进入房间
            --一键调起的云服 房间信息不全，因此需要特殊处理
            local roomInfo = {
                isOneKeyRentRoom = true,
                isRentDebug = spData.rentDebug,
                room_id = serverid,
                room_uin = roomDesc.uin or 1000,
                room_name = room_name,
                player_count = curPlayerNum,
                player_max = maxPlayerNum,
                ver = ClientMgr:clientVersion(),
                fromowid = fromowid,
                act_key = spData.act_key,
                password = password,
                personal = roomDesc.personal,
                teamid = spData.teamid,
                oriDesc = roomDesc,
            }
            if roomDesc.personal and roomDesc.personal == 1 then
                GetInst("ReportGameDataManager"):SetRoomType(5)
            end
            local ruin, rid = nil, nil
            if self:GetRoomTypeByID(serverid) == AllRoomManager.RoomType.CloudServer then
                ruin, rid = getRoomUinAndRoomID(serverid)
                ruin = tonumber(ruin)
                rid = tonumber(rid)
                if ruin and rid then
                    roomInfo.room_uin = ruin
                end
            end
            EnterWorld_ExtraSet(serverid)
            if AccountManager:requestJoinRentWorld(0, serverid) then
                -- local uin, roomid = getRoomUinAndRoomID(detailreason)
                if ruin and rid then
                    ClientMgr:setCurrentRentRoomId(rid)
                    ClientMgr:setCurrentRentRoomUin(ruin)
                else
                    ClientMgr:setCurrentRentRoomId(1)
                    ClientMgr:setCurrentRentRoomUin(1000)
                end

                setCurInRoomName(room_name)
                setCurInRoomNameByDesc(roomDesc)
				RoomInteractiveData.curMapwid = fromowid
				RoomInteractiveData.connect_mode = 0
				RoomInteractiveData.curRoomName = room_name;
				RoomInteractiveData.cur_gameLabel = 1;

                if spData.teamid then
                    --组队
                    local teamupSer = GetInst("TeamupService")
                    if teamupSer and teamupSer:IsLeader(AccountManager:getUin()) then
                        teamupSer:NotifyMemberTips(GetS(26081), {AccountManager:getUin()})
                    end
                end

                DeveloperFromOwid = fromowid
                g_ScreenshotShareRoomDesc = nil
                               
                if spData.requestid and ReportMgr and ReportMgr.setExpInfo then
                    ReportMgr:setExpInfo(nil, nil, spData.requestid)
                end

                if "table" ~= type(appendRptTb) then
                    appendRptTb = {}
                end
                ns_ma.ma_play_map_set_enter( { where="join_cloudroom", fromowid=DeveloperFromOwid} )
                reportGameJoinCall(2, roomDesc, appendRptTb)
                MapRewardClass:SetMapsReward(fromowid)

            end
            RecentlyCSRoom:UpdateRoomInfo(roomInfo.fromowid, "", roomInfo.room_name, 0,1)
            RentPermitCtrl:SetRentRoomInfo(roomInfo)
            newlobby_SaveMapHistory(roomInfo.fromowid)

            if spData and "function" == type(spData.successCall) then
                spData.successCall(fromowid, serverid)
            end
            local cInterface = GetInst("CreationCenterInterface")
			if cInterface and cInterface.EnterGameCloseCreationCenterFrames then
				cInterface:EnterGameCloseCreationCenterFrames()
			end
            HideLobby() --为了处理存档界面模型残影的问题 --code_by:huangfubin 2021.11.18
            CloseRoomFrame()
            GetInst("UIManager"):HideAll();
            UIFrameMgr:hideAllFrame();
            ShowLoadingFrame();
            callRet = true
        else
            reportGameJoinCallFailed1(result)
        end
        NewBattlePassEventOnTrigger("mulgame");

    until true

    if spData.showLoadLoop then
        ShowLoadLoopFrame2(false, loopTag)
    end

    --MiniBase加入云服房间失败回调统一处理
    if not callRet then SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinOneKeyCloudRoom",  SandboxContext():SetData_Number("code", (250 + failedCode))) end    

    return callRet, string.format("%s(%s)", tostring(tips) or "", tostring(failedCode or 0)), failedCode
end

--根据活动id进入云服（返回的云服信息，不是常规完整的云服信息）
function RoomService:ReqJoinQuickupCSRoomByActivityKey(actkey, spData, desc, bkg)
    spData = spData or {}
    local failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
    local baseUrl = self:GetQuickupRentBaseUrl(spData.rentDebug)
    spData.outtime = spData.outtime or 15

    local url = baseUrl .. "v2/room/get"
    local lua_game_session_id = standReportGenerateGameSessionId()
    local append = {
        act_id = actkey,
        game_session_id = lua_game_session_id,

        scene = spData.scene or enum_scene.Activity, --场景id 大厅18 地图详情48 地图房间列表48/1004 活动50 联机失败后兜底51
        appid = spData.appid or enum_appid.Mini, --业务id  迷你世界1000 
    }
    local postStr = self:GetAppendQuickupPostData(append)

    local loadLoopInfo = {
        showLoadLoop = spData.showLoadLoop, 
        loadLoopType = 2, 
        loopDesc = desc, 
        bkgName = bkg,
    }
    local retStr = self:SyncRpcPost(url, postStr, spData.outtime, loadLoopInfo)
    print("ReqJoinQuickupCSRoomByActivityKey retStr " .. tostring(retStr))
    local tips = GetS(26102)
    spData.baseTip = tips
    repeat
        if not retStr then
            break
        end
        
        local ok, ret = pcall(JSON.decode, JSON, retStr);        
        if not (ok and type(ret) == 'table') then
            failedCode = RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end
    
        if ret.code ~= 0 then
            failedCode = ret.code*1000 + RoomService.failed_code.ROOM_NOT_EXISTS
            break
        end
    
        local _, port = pcall(tonumber, ret.port)
        if not (port and port > 0) then
            failedCode = RoomService.failed_code.NO_PORT
            break
        end
        ret.port = port

        return self:inFunc_ReqStartJoinQuickupRent(ret, spData, {standby3 = 3, lua_game_session_id = lua_game_session_id})
    until true

    tips = self:GetErrorCodeTip(failedCode)
    return false, string.format("%s(%s)", tostring(tips) or "", tostring(failedCode or 0)), failedCode
end

function RoomService:SyncQueryRoomDescByRoomID(roomID)
    if not roomID then
        return nil, GetS(9679)
    end

    local roomType = GetInst("RoomService"):GetRoomTypeByID(roomID)
    local roomDesc = nil
    local errorTips = GetS(9679)
    if roomType == AllRoomManager.RoomType.Normal then
        local roomlist, loginSuc = GetInst("RoomService"):ReqRoomListByUinSync(tonumber(roomID), -1, true, {connect_mode = "any"})
        roomlist = roomlist or {}
        if not loginSuc then
            errorTips = GetS(146)
        else
            roomDesc = roomlist[1];
        end
    elseif roomType == AllRoomManager.RoomType.CloudServer then
        local roomUin, rid = getRoomUinAndRoomID(tostring(roomID))
        if roomUin and rid then
            local roomlist, loginSuc = GetInst("RoomService"):ReqRoomListByUinSync(roomUin, rid, true, {connect_mode = "any"})
            roomlist = roomlist or {}
            if not loginSuc then
                errorTips = GetS(146)
            else
                roomDesc = roomlist[1];
            end
        end
    elseif roomType == AllRoomManager.RoomType.QuickupCloudServer then
        local retData = GetInst("RoomService"):ReqQueryQuickupCSRoom(roomID)
        local csroomdesc = retData.roomDesc
        if csroomdesc and "table" == type(csroomdesc) and next(csroomdesc)  then
            csroomdesc.lcl_outTime = os.time() + 1
            roomDesc = csroomdesc
        end
    end

    return roomDesc, errorTips
end

---------------------加入房间部分---------------------------------------------
--callBack暂时传了也没用。。
function RoomService:EnterRoomByDesc(reportSlot, ignoreNetState, roomDesc, exData, callBack)
    if roomDesc == nil then
        --MiniBase加入房间失败回调                          
		SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCommonEvent",  SandboxContext():SetData_Number("code", 204))
        return
    end
    exData = exData or {}
    if (not ignoreNetState and ClientMgr:getNetworkState() == 2) then
        --流量进房间提醒
        local msgCall = function()
            self:EnterRoomByDesc(reportSlot, true, roomDesc, exData, callBack)
        end
        --MiniBase迷你基地用流量不拦截，APP拦截
        if not MiniBaseManager:isMiniBaseGame() then 
            MessageBox(7, GetS(21), msgCall);
            return
        end
    end
    GetInst("RoomService"):AsynReqMapPlayerCount({roomDesc.map_type})

    GetInst("UIManager"):Close("NormalRoomDetail")
    GetInst("ReportGameDataManager"):SetBefJoinFailedParamStandby1(GetInst("ReportGameDataManager"):GetGameJoinBeforeStageDefine().requestJoinRoomFail)
    --设置房间名
    local roomName = (roomDesc.roomname or roomDesc.room_name) or ""
    setCurInRoomName(roomName)
    setCurInRoomNameByDesc(roomDesc)

    local genkey = GetInst("UIEvtHook"):GenKeyWithPrefix(self.EVT_GEN_PREFIX_JOIN)

    local roomType = self:GetRoomType(roomDesc)
    if AllRoomManager.RoomType.Normal == roomType then
        roomDesc = AllRoomManager:TransHttpNormalRoomNotAdd(roomDesc)
        if roomDesc.password and roomDesc.password ~= "" then
            --MiniBase迷你基地密码在参数中
            if not MiniBaseManager:isMiniBaseGame() then
                self:ShowNormalPassInput(reportSlot, roomDesc, exData, genkey, callBack)
            else
                --从参数中取密码
                self:LinkNormalRoomByDesc(roomDesc.password, reportSlot, roomDesc, exData, genkey, callBack);
            end
        else
            --房间没有设置密码
            self:LinkNormalRoomByDesc("", reportSlot, roomDesc, exData, genkey, callBack);
        end
    elseif AllRoomManager.RoomType.CloudServer == roomType then
        self:EnterCloudRoomByDesc(roomDesc, reportSlot, genkey, callBack)
    elseif AllRoomManager.RoomType.QuickupCloudServer == roomType then        
        if not roomDesc.passwd and roomDesc.passwd_md5 and roomDesc.passwd_md5 ~= "" then
            local passInputCallBack = function() end
            passInputCallBack = function(password)                
                local ret, tips, failedCode = self:ReqJoinDesQuickupCSRoom(roomDesc.roomid, exData.spData, password)
                if not ret and failedCode == 11 then
                    ShowGameTips(tips or GetS(567))
                    GetInst("UIManager"):Open("RoomPassWordInput", {callBack = passInputCallBack})
                    ReportBeforeJoinFailedCall(GetS(567))
                end
            end
            if "string" == type(roomDesc.tryPwd) and roomDesc.tryPwd ~= "" then
                passInputCallBack(roomDesc.tryPwd)
            else
                GetInst("UIManager"):Open("RoomPassWordInput", {callBack = passInputCallBack})
            end
        else
            local ret, tips, failedCode = nil, nil, nil
            if exData.notQuery or 'number' == type(roomDesc.lcl_outTime) and roomDesc.lcl_outTime >= os.time() then
                ret, tips, failedCode = self:inFunc_ReqStartJoinQuickupRent(roomDesc, exData.spData, {standby3 = 0}, roomDesc.passwd or "")
            else
                ret, tips, failedCode = self:ReqJoinDesQuickupCSRoom(roomDesc.roomid, exData.spData, roomDesc.passwd or "")
            end
            if not ret then
                ShowGameTips(tips or GetS(35888))
            	--MiniBase加入一键云服失败回调
            	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinOneKeyCloudRoom",  SandboxContext():SetData_Number("code", 234):SetData_String("msg", tips))
                ReportBeforeJoinFailedCall(tips or GetS(35888))
            end
        end
    end
end

-- 不要直接调- -！
function RoomService:ShowNormalPassInput(reportSlot, roomDesc, exData, genkey)
    if roomDesc and genkey then
        local passInputCallBack = function(password)
            self:LinkNormalRoomByDesc(password, reportSlot or 0, roomDesc, exData, genkey, callBack)
        end
        GetInst("UIManager"):Open("RoomPassWordInput", {callBack = passInputCallBack})
    end
end

-- 不要直接调- -！
function RoomService:ShowCloudPassInput(roomInfo, genkey)
    if roomInfo and genkey then
        local passInputCallBack = function(password)
            self:ReqRoomCloudServerEnterRoom(roomInfo, password, genkey)
        end
        GetInst("UIManager"):Open("RoomPassWordInput", {callBack = passInputCallBack})
    end
end

-- 不要直接调- -！
function RoomService:LinkNormalRoomByDesc(password, reportSlot, roomDesc, exData, genkey, callBack)
    Log("AllRoomManager:LinkNormalRoomByDesc:");
    
    local checker_uin = AccountManager:getUin()
	if IsUserOuterChecker(checker_uin) and not DeveloperAdCheckerUser(checker_uin) then
		ShowGameTips(GetS(100300), 3)
        ReportBeforeJoinFailedCall(GetS(100300))
        return nil;
	end

    if not roomDesc then
        --MiniBase加入普通房间失败回调                          
		SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinNormalRoom",  SandboxContext():SetData_Number("code", 204))
        ReportBeforeJoinFailedCall("rommDesc is null")
        return
    end

    self:InsertEnterRoomCallBack(callBack, genkey)
    Log("111:");
    local curVersion = ClientMgr:clientVersion();

    local roomType = roomDesc.isServer and 2 or 3
    statistics_9502_handler.OnEnterRoomStatistics(roomDesc.owneruin, reportSlot, roomType, roomDesc.map_type, roomDesc.gamelabel, getShortUin(roomDesc.owneruin))

    if roomDesc.isnearby > 100  and roomDesc.password ~= "" and roomDesc.password ~= password then
        ShowGameTips(GetS(567), 3);
        statistics_9502_handler.OnEnterRoomResultStatistics(false, 567)
        --MiniBase加入普通房间失败回调                          
		SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinNormalRoom",  SandboxContext():SetData_Number("code", 214))
        ReportBeforeJoinFailedCall(GetS(567))
        return
    end

    --为客机截图分享保存数据
    g_ScreenshotShareRoomDesc = roomDesc;

    local t_extra = JSON:decode(roomDesc.extraData);
    if t_extra then
        local myVer = math.floor(curVersion/256);
        local roomVer = math.floor(ClientMgr:clientVersionFromStr(t_extra.version)/256);
        if myVer ~= roomVer then
            ShowGameTips(GetS(572), 3);
            statistics_9502_handler.OnEnterRoomResultStatistics(false, 572)
            --MiniBase加入普通房间失败回调                          
		    SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinNormalRoom",  SandboxContext():SetData_Number("code", 210))
            ReportBeforeJoinFailedCall(GetS(572))
            return;
        end
    end

    StatisticsTools:joinRoom(mIsLanRoom, roomDesc.gamelabel);

    --可否被追踪
    local teamMode = false
    local connect_mode = roomDesc.connect_mode or 0
    if exData.teamMode then teamMode = true end
    local cantrace = ClientMgr:getGameData("cantrace")
    if teamMode then
        cantrace = 0
        connect_mode = 2
    elseif 2 == roomDesc.connect_mode then --加组队房间 必须传teamMode=true
        connect_mode = 0
    end

    AllRoomManager:CpRoomDesc(roomDesc, self.m_teamNorRoomDesc)
    if AccountManager:requestConnectWorldByDesc(self.m_teamNorRoomDesc, password, cantrace, connect_mode, genkey) then
        AllRoomManager:AddReqConnectRSRoom(roomDesc, roomDesc.owneruin)
        --[[设置打赏状态]]
        MapRewardClass:SetMapsReward(roomDesc.map_type)

        EnterRoomType = roomDesc.gametype;
        LoginRoomClientIp = roomDesc.regionIp;

        WWW_ma_multigame();
        ns_ma.ma_play_map_set_enter( { where="join_room1", fromowid=roomDesc.map_type, gamelabel=roomDesc.gamelabel } )
        statistics_9502_handler.OnEnterRoomResultStatistics(true)
        NewBattlePassEventOnTrigger("mulgame");
    else
        ShowGameTips(GetS(573), 3);
        statistics_9502_handler.OnEnterRoomResultStatistics(false, 573)
        --MiniBase加入普通房间失败回调                          
		SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinNormalRoom",  SandboxContext():SetData_Number("code", 218))
        ReportBeforeJoinFailedCall(GetS(573))
    end
    --客机记录地图fromowid
    DeveloperFromOwid = roomDesc.map_type;

    if roomDesc.connect_mode == 0 then
        local worldListRecentlyOpened = AccountManager:getMyRecentlyOpenedWorldList()
        worldListRecentlyOpened:saveRecentlyPlayedMap(roomDesc.map_type, 0, roomDesc.thumbnail_url, roomDesc.thumbnail_md5, roomDesc.roomname, JOIN_ROOM);
        worldListRecentlyOpened:saveLastJoinRoomInfo(roomDesc.owneruin, roomDesc.map_type, 0);
    end

    --联机来源埋点
    OnlineSourceStatistics(roomDesc.map_type, false)

    local rpt = copy_table(standReportGameJoinParam or {})
    local temp = AllRoomManager:CalculateRoomDescReportTb(roomDesc) or {}
    -- 联机埋点上报。
    for key, value in pairs(temp) do
        rpt[key] = value
    end
    rpt.slot = reportSlot

    InsertStandReportGameJoinParamArg(rpt)

	GetInst("ReportGameDataManager"):SetCId(rpt.cid)
	GetInst("ReportGameDataManager"):SetJoinSlot(reportSlot)
end

-- 不要直接调- -！
function RoomService:LinkNormalRoomResult(result, detailreason, genkey)
    EnterWorld_ExtraSet("")

    local roomKey = AccountManager:getCurConnectWorldHostUin()
    local roomDesc = AllRoomManager:FindReqConnectRoom(roomKey)

    if result == 9 then
        --进入房间
        Log("lldo: result = 9");

        if not AccountManager:requestJoinWorld() then
            ShowGameTips(GetS(146), 3);
            --MiniBase加入普通房间失败回调                          
		    SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinNormalRoom",  SandboxContext():SetData_Number("code", 212))
            return;
        end
        HideLobby() --为了处理存档界面模型残影的问题 --code_by:huangfubin 2021.11.18
		CloseRoomFrame()
        GetInst("UIManager"):HideAll();
        UIFrameMgr:hideAllFrame();
        ShowLoadingFrame(); --ShowLoadingFrame 会清AllRoomManager.ReqConnectRSRoom
        if EnterRoomType == GTSurviveGame then
            StatisticsTools:gameEvent("EnterSurviveWNum");
        elseif EnterRoomType == GTCreativeGame then
            StatisticsTools:gameEvent("EnterCreateWNum");
        elseif EnterRoomType == GTGameMakerGame then
            StatisticsTools:gameEvent("EnterGameMakerWNum");
        end
        StatisticsTools:gameEvent("EnterRoomNum");

        reportGameJoinCall(1, roomDesc)

        local tb = {}
        if roomDesc and roomDesc.map_type then
            tb.cid = tostring(roomDesc.map_type)
        end
        newlobby_SaveMapHistory(tb.cid)

        if roomDesc then
            -- 记录加入房间
            local gamelabel = AllRoomManager:GetRoomLabel(roomDesc.gamelabel, roomDesc.worldtype)
            local statisticsParam = GetRoomParamByRoomDesc(roomDesc)
            StatisticsTools:joinRoom(mIsLanRoom, gamelabel, SAID_JoinRoomEx, statisticsParam.roomID, statisticsParam.roomType, statisticsParam.roomOwnner);
            --保存密码
            if Room_Data.cur_password ~= "" then
                Room_Data.password_record[roomDesc.owneruin] =Room_Data.cur_password;
                Room_Data.cur_password = "";
            end

            RoomInteractiveData.curMapwid = tonumber(roomDesc.map_type) or 0
            RoomInteractiveData.connect_mode = roomDesc.connect_mode
            RoomInteractiveData.curRoomName = roomDesc.roomname;
            RoomInteractiveData.curRoomPW = Room_Data.password_record[roomDesc.owneruin] or "";
            RoomInteractiveData.cur_gameLabel = gamelabel;
        end

        --加入房间后，网络环境统计上报
        local networkState = GetNetworkState()
        local delay = AccountManager and AccountManager.get_network_delay and AccountManager:get_network_delay() or 250
        -- statisticsGameEvent(633, "%d", networkState)
        -- statisticsGameEvent(634, "%d", delay / 1000)
    else
        if result == 10 then
            ShowGameTips(GetS(566), 3);
        elseif result == 11 then
            ShowGameTips(GetS(567), 3);
            --MiniBase 不可再次输入密码
            if roomDesc and not MiniBaseManager:isMiniBaseGame() then
                self:ShowNormalPassInput(0, roomDesc, genkey)
            end
            local roomPassWordInputCtrl = GetInst("UIManager"):GetCtrl("RoomPassWordInput")
			if roomPassWordInputCtrl and roomPassWordInputCtrl:GetReportPassword() == true then
                roomPassWordInputCtrl:SetReportPassword(false);
                ReportBeforeJoinFailedCall(GetS(567));
            end
        elseif result == 12 then
            ShowGameTips(GetS(568), 3);
        elseif result == 13 then
            if detailreason == -3 then
                ShowGameTips(GetS(282), 3);
            else
                ShowGameTips(GetS(4034, detailreason), 3);
            end
        elseif result == 14 then
            ShowGameTips(GetS(8033), 3);
        elseif result == 15 then
            ShowGameTips(GetS(573), 3);
        elseif result == 16 then
            ShowGameTips(GetS(573), 3);
        elseif result == 17 then
            ShowGameTips(GetS(3630), 3);
        elseif result == 18 then
            ShowGameTips(GetS(10549), 3); --敏感词
        else
            local strTip = "@error room result:" .. result .. ", detailreason:" .. detailreason
            ShowGameTips(strTip, 3)
            Log(strTip)
        end
        --MiniBase加入普通房间失败回调                          
		SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinNormalRoom",  SandboxContext():SetData_Number("code", ( 203 + result)))

        --加入房间失败上报
        -- statisticsGameEvent(632, "%d", result)
        reportGameJoinCallFailed1(result, roomDesc)
    end
end

-- 不要直接调- -！
function RoomService:EnterCloudRoomByDesc(roomInfo, reportSlot, genkey, callBack)
    if roomInfo then
        self:InsertEnterRoomCallBack(callBack, genkey)
        local roomuin, roomid = getRoomUinAndRoomID(roomInfo["_k_"])
        -- 房间类型：1=玩家云服、2=官服、3=普通房间
        local reportRoomType = roomInfo.isServer and 2 or 1
        statistics_9502_handler.OnEnterRoomStatistics(roomuin, reportSlot, reportRoomType, roomInfo.wid, roomInfo.label, roomid)

        -- 通行证判断已过期
        if roomInfo.map_passcard_et and roomInfo.map_passcard_et > 0 and roomInfo.map_passcard_et < getServerTime() then
            MessageBox(4, GetS(9800))
            --MiniBase加入云服房间失败回调                          
		    SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 211))
            ReportBeforeJoinFailedCall(GetS(9800))
            return
        end

        roomInfo.reportSlot = reportSlot
        if roomInfo.wid and roomInfo.wid > 0 then
            --加多点限制 如果是违规云服 超管 直接进入
            if IsCSRoomViolation(roomInfo.open_svr) and ns_playercenter.func.IsPlayerRentSup() then
                local lefttime = roomInfo["expire_time"] - getServerTime()
                if lefttime < 0 then
                    ShowGameTips(GetS(9590))
                    --MiniBase加入云服房间失败回调                          
		            SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 211))
                    ReportBeforeJoinFailedCall(GetS(9590))
                    return
                end
                if roomInfo["password"] and roomInfo["password"] == 1 then
                    self:ReqRoomCloudServerAuthority(roomuin, roomid, roomInfo, genkey)
                else
                    local pwd = roomInfo["password"]
                    if type(pwd) ~= "string" then
                        pwd = ""
                    end
                    self:ReqRoomCloudServerEnterRoom(roomInfo, pwd, genkey)
                end
                return
            end

            if roomuin == AccountManager:getUin() then
                if IsCSRoomViolation(roomInfo.open_svr) then
                    if roomInfo.appeal then
                        ShowGameTipsWithoutFilter(GetS(9786))
                        --MiniBase加入云服房间失败回调                          
		                SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 225))
                        ReportBeforeJoinFailedCall(GetS(9786))
                        return
                    end

                    local key = roomInfo._k_
                    local haveChecked = getkv("cshaveChecked_"..key)
                    if not haveChecked then
                        if not MiniBaseManager:isMiniBaseGame() then
                            MessageBox(31, GetS(9780), function(btn)
                                if btn == 'right' then
                                    --记录一下
                                    setkv("cshaveChecked_"..key, true)
                                end
                            end)
                        else
                            --MiniBase加入云服房间失败回调                          
		                    SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 226))
                            ReportBeforeJoinFailedCall("join cloud room failed")
                        end
                        return
                    end
                end
            end

            local lefttime = roomInfo["expire_time"] - getServerTime()
            -- 是否开启，是否维护
            if roomInfo.stat == 0 then
                if lefttime <= 0 then
                    if roomuin ~= AccountManager:getUin() then
                        statistics_9502_handler.OnEnterRoomResultStatistics(false, 9590)
                        ShowGameTips(GetS(9590), 3)
                        --MiniBase加入云服房间失败回调                          
		                SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 222))
                        ReportBeforeJoinFailedCall(GetS(9590))
                        return
                    else
                        statistics_9502_handler.OnEnterRoomResultStatistics(false, 9591)
                        ShowGameTips(GetS(9591), 3)
                        --MiniBase加入云服房间失败回调                          
		                SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 223))
                        ReportBeforeJoinFailedCall(GetS(9591))
                        return
                    end
                else
                    statistics_9502_handler.OnEnterRoomResultStatistics(false, 9546)
                    ShowGameTips(GetS(9546), 3)
                    --MiniBase加入云服房间失败回调                          
		            SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 224))
                    ReportBeforeJoinFailedCall(GetS(9546))
                    return
                end
            elseif roomInfo.maintain == 1 and roomuin ~= AccountManager:getUin() then
                --暂时不要在这里判断（超管需要在后面继续获取密码进入）
                --return ShowGameTips(GetS(9547), 3)
            end

            -- 版本号判断
            if roomuin ~= AccountManager:getUin() then
                local myVer = math.floor(ClientMgr:clientVersion()/256);
                local roomVer = math.floor(ClientMgr:clientVersionFromStr(roomInfo["ver"])/256);
                if myVer ~= roomVer then
                    statistics_9502_handler.OnEnterRoomResultStatistics(false, 572)
                    ShowGameTips(GetS(572), 3);
                    --MiniBase加入云服房间失败回调                          
		            SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 210))
                    ReportBeforeJoinFailedCall(GetS(572))
                    return
                end
            end
            -- 设置
            RentPermitCtrl:SetRentRoomInfo(roomInfo)
            -- 密码相关处理
            if roomInfo["password"] and roomInfo["password"] == 1 then
                self:ReqRoomCloudServerAuthority(roomuin, roomid, roomInfo, genkey)
            else
                local pwd = roomInfo["password"]
                if type(pwd) ~= "string" then
                    pwd = ""
                end
                self:ReqRoomCloudServerEnterRoom(roomInfo, pwd, genkey)
            end
        end
    end
end

-- 不要直接调- -！
function RoomService:ReqRoomCloudServerAuthority(roomuin, roomid, roomInfo, genkey)
    if  ns_version and ns_version.proxy_url then
        local url = ns_version.proxy_url .. '/miniw/rent_server?act=checkPW&room_uin='..roomuin.."&room_id="..roomid.."&" .. http_getS1Map();
        print("ReqRoomCloudServerAuthority", roomuin, url)
        local userdata = {
            roomuin = roomuin,
            roomid = roomid,
            roomInfo = roomInfo
        }
        local loopTag = "file:RoomService - func:ReqRoomCloudServerAuthority"
        ShowLoadLoopFrame2(true, loopTag, 3)

        local callBack = function(ret, userdata)
            ShowLoadLoopFrame2(false, loopTag)
            self:RespRoomCloudServerAuthority(ret, userdata, genkey)
        end
        ns_http.func.rpc( url, callBack, userdata, nil, true );
    else
        --MiniBase加入云服房间失败回调                          
        SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 227))
    end
end

-- 不要直接调- -！
function RoomService:RespRoomCloudServerAuthority(ret, userdata, genkey)
    if ret and ret.ret then
        if ret.ret == 0 then
            local password = ret.pw == nil and "" or ret.pw
            self:ReqRoomCloudServerEnterRoom(userdata.roomInfo, password, genkey)
        elseif ret.ret == 2 then
            --如果当前房间是维护状态，那就连密码都省了 不用进了
            if userdata.roomInfo and userdata.roomInfo.maintain == 1 then
                statistics_9502_handler.OnEnterRoomResultStatistics(false, 9547)
                --MiniBase加入云服房间失败回调                          
                SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 229))
                ReportBeforeJoinFailedCall(GetS(9547))
                return ShowGameTips(GetS(9547), 3)
            end
            --MiniBase迷你基地密码在参数中
            if not MiniBaseManager:isMiniBaseGame() then
                self:ShowCloudPassInput(userdata.roomInfo, genkey)
            else
                --MiniBase从参数中取密码
                local password = ret.pw == nil and "" or ret.pw
                self:ReqRoomCloudServerEnterRoom(userdata.roomInfo, password, genkey)
            end            
        end
    else
        --MiniBase加入云服房间失败回调                          
        SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 228))
    end
end

-- 不要直接调- -！
function RoomService:ReqRoomCloudServerEnterRoom(roomInfo, password, genkey)
    local serverid = roomInfo["_k_"]
    --print("ReqRoomCloudServerEnterRoom", roomInfo)
    local uin, roomid = getRoomUinAndRoomID(serverid)
    threadpool:work(function()
        if ns_version and ns_version.proxy_url then
            local url = ns_version.proxy_url .. '/miniw/rent_server?act=enter_room&room_uin='..uin.."&room_id="..roomid.."&password="..password.."&" .. http_getS1Map();
            local userdata = {
                key = serverid,
                roomDesc = roomInfo,
                password = password
            }
            local loopTag = "file:RoomService - func:ReqRoomCloudServerEnterRoom"
            ShowLoadLoopFrame2(true, loopTag, 5)

            local callBack = function(ret, userdata)
                ShowLoadLoopFrame2(false, loopTag)
                if not getglobal("LoadingFrame"):IsShown() and not ClientCurGame:isInGame() then
                    self:RespRoomCloudServerEnterRoom(ret, userdata, genkey)
                end
            end

            ns_http.func.rpc( url, callBack, userdata, nil, true );
        else
            --MiniBase加入云服房间失败回调                          
            SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 227))
            ReportBeforeJoinFailedCall("join cloud room failed")
        end
     end)
end

-- 不要直接调- -！
function RoomService:RespRoomCloudServerEnterRoom(result, userdata, genkey)
    local roomDesc = userdata["roomDesc"]
    print("HRL .. RespRoomCloudServerEnterRoom " .. TableToStr(result))
    if result and result.ret and result.ret == 0 and result.runtime then
        local auth = result.room_auth == nil and "" or result.room_auth
        AccountManager:setCloudServerAuth(auth)
        if roomDesc then
            roomDesc["ip"] = result.room_info.ip
            roomDesc["port"] = result.runtime.port or 0
            roomDesc["player_count"] = result.runtime.player_count
            if roomDesc["port"] == 0 then
                statistics_9502_handler.OnEnterRoomResultStatistics(false, 12312)
                --MiniBase加入云服房间失败回调                          
                SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 230))
                return ShowGameTips(GetS(12312))
            end

            --玩家刚上传完房间后，房间信息里没有这个值，这个时候用enter_room里面的这个字段
            if (roomDesc["roomMods"] == nil or roomDesc["roomMods"] == "") and result.room_info.roomMods then
                roomDesc["roomMods"] = result.room_info.roomMods
                print("RespCloudServerEnterRoom roomMods:", roomDesc["roomMods"])
            end

            if (roomDesc["roomUILibs"] == nil or roomDesc["roomUILibs"] == "") and result.room_info.roomUILibs then
                roomDesc["roomUILibs"] = result.room_info.roomUILibs
            end

            if (roomDesc["roomAudioConfig"] == nil or roomDesc["roomAudioConfig"] == "") and result.room_info.roomAudioConfig then
                roomDesc["roomAudioConfig"] = result.room_info.roomAudioConfig
            end

            AccountManager:addRentHostAddress(userdata["key"], roomDesc["ip"], roomDesc["port"])
            SetCloudRoomModInfo(roomDesc)

            local player_max = (result.runtime and result.runtime.player_max) and result.runtime.player_max or 40
            if AccountManager:requestConnectRentWorld(result.room_info.room_uin, userdata["password"], 0, player_max, 0, userdata["key"], genkey) then
                AllRoomManager:AddReqConnectRSRentRoom(roomDesc, roomDesc._k_)
                statistics_9502_handler.OnEnterRoomResultStatistics(true)
                ShowLoadLoopFrame(true, "file:CloudServerInterface -- func:RespRoomCloudServerEnterRoom")
                -- --[[设置打赏状态]]
                -- MapRewardClass:SetMapsReward(roomDesc.fromowid)

                -- 新增冒险回归活动“联机模式”任务上报
                if GetInst("ComeBackSysConfig"):IsNeedReportEvent(4) then
                    GetInst("ComeBackSysConfig"):RequestEvent(4)
                end
                standReportCloudServerEnterRoom(roomDesc)

                NewBattlePassEventOnTrigger("mulgame");

                -- 新增新手引导推荐地图关闭并且进入记录
                if NewbieGuideManager and NewbieGuideManager:IsSwitch() then
                    NewbieGuideManager:CloseRecommendMapAndMark()
                end
            else
                statistics_9502_handler.OnEnterRoomResultStatistics(false, 573)                                          
                SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 218))
                return ShowGameTips(GetS(573), 3);
            end
        end
    elseif result and result.msg == "error_expire_time" then
        statistics_9502_handler.OnEnterRoomResultStatistics(false, 9590)
        ShowGameTips(GetS(9590) .. ":0" , 3)
        SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 222))
        ReportBeforeJoinFailedCall(GetS(9590))
    elseif result and result.msg == "passcard_expire_time"  then
        -- 通行证判断已过期
        MessageBox(4, GetS(9800))
        SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 211))
        ReportBeforeJoinFailedCall(GetS(9800))
    elseif result and result.ret and result.ret == 10 then
        statistics_9502_handler.OnEnterRoomResultStatistics(false, 9807)
        ShowGameTips(GetS(9807), 3)
        SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 231))
        ReportBeforeJoinFailedCall(GetS(9807))
    elseif result and result.ret and result.ret == 11 then
        statistics_9502_handler.OnEnterRoomResultStatistics(false, 9844)
        ShowGameTips(GetS(9844), 3)
        SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 232))
        ReportBeforeJoinFailedCall(GetS(9844))
    elseif result and result.ret and result.ret == 7 then
        if roomDesc and roomDesc.password ~= "" and not MiniBaseManager:isMiniBaseGame() then
            ShowGameTips(GetS(567), 3);
            self:ShowCloudPassInput(roomDesc, genkey)
            ReportBeforeJoinFailedCall(GetS(567))
        else
            ShowGameTips(GetS(500218)) --"当前网络错误进入失败，请稍微重试"
            ReportBeforeJoinFailedCall(GetS(500218))
        end
        SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 214))
    elseif result and result.msg == "map forbidden"  then
        ShowGameTips(GetS(500219)) --"地图违规无法进入，请重置"
        statistics_9502_handler.OnEnterRoomResultStatistics(false, 123456789)
        SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 233))
        ReportBeforeJoinFailedCall(GetS(500219))
    else
        local str = ns_error_msg.show(result, 3)
        statistics_9502_handler.OnEnterRoomResultStatistics(false, str)
        SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 233))
        ReportBeforeJoinFailedCall(str)
    end
end

function RoomService:LinkCloudRoomResult(result, detailreason, genkey) 
    local roomDesc = AllRoomManager:FindReqConnectRoom(detailreason)
	if result == 9 then
		--进入房间
		EnterWorld_ExtraSet(detailreason)
		if AccountManager:requestJoinRentWorld(0, detailreason) then
			local uin, roomid = getRoomUinAndRoomID(detailreason)
			ClientMgr:setCurrentRentRoomId(roomid)
			ClientMgr:setCurrentRentRoomUin(uin)

			if roomDesc then
				-- 针对"最近"需要保存的房间信息
				RecentlyCSRoom:UpdateRoomInfo(roomDesc.fromowid, roomDesc.thumbnail,roomDesc.room_name, uin,roomid)
				--[[设置打赏状态]]
				MapRewardClass:SetMapsReward(roomDesc.fromowid)

				if roomDesc.fromowid then
					DeveloperFromOwid = roomDesc.fromowid
					g_ScreenshotShareRoomDesc = roomDesc
				end

				local gamelabel = AllRoomManager:GetRoomLabel(roomDesc.label,roomDesc.worldtype)
				RoomInteractiveData.curMapwid = roomDesc.fromowid
				RoomInteractiveData.connect_mode = roomDesc.connect_mode
				RoomInteractiveData.curRoomName = roomDesc.room_name;
				RoomInteractiveData.cur_gameLabel = gamelabel;
				--print("HandleShareRoomRSRentConnect",gamelabel,roomDesc.label,roomDesc.worldtype)
				local statisticsParam = GetRoomParamByRoomDesc(roomDesc)
				StatisticsTools:joinRoom(false, gamelabel, SAID_JoinRoomEx, statisticsParam.roomID, statisticsParam.roomType, statisticsParam.roomOwnner);
                ns_ma.ma_play_map_set_enter( { where="join_cloudroom", fromowid=roomDesc.fromowid} )
				reportGameJoinCall(2,roomDesc)
				local cid = "0"
				if roomDesc and roomDesc.fromowid > 0 then
					cid = tostring(roomDesc.fromowid)
				elseif roomDesc.owid and roomDesc.owid > 0 then
					cid = tostring(roomDesc.owid)
				elseif roomDesc.wid and roomDesc.wid > 0 then
					cid = tostring(roomDesc.wid)
				elseif roomDesc.map_type then
					cid = roomDesc.map_type
				end
				newlobby_SaveMapHistory(cid)
				
			else
				-- 记录加入房间
				StatisticsTools:joinRoom(false, 0, SAID_JoinRoomEx, "0", "3", "");
				reportGameJoinCall(2,roomDesc)
			end
        else
            SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 207))
		end
        HideLobby() --为了处理存档界面模型残影的问题 --code_by:huangfubin 2021.11.18
		CloseRoomFrame()
        GetInst("UIManager"):HideAll();
        UIFrameMgr:hideAllFrame();
		ShowLoadingFrame();
	else
        SandboxLua.eventDispatcher:Emit(nil, "MiniBase_JoinCloudRoom",  SandboxContext():SetData_Number("code", 212))
        reportGameJoinCallFailed1(result, roomDesc)
	end
end

----------以前lobbyframe里面的GIE_RSCONNECT_RESULT响应
function RoomService:HandleCommonGieRSConnectEvt(keeplast, jumpParam)
    Log("lobby: GIE_RSCONNECT_RESULT:");
    if t_autojump_service.play_together.anchorUin > 0 then return end

    if IsLobbyShown()
            or ClientCurGame:isInGame() 
            or getglobal("ArchiveInfoFrameEx"):IsShown() 
            or getglobal("MiniWorksFrame"):IsShown() 
            or getglobal("ExhibitionMapFrame"):IsShown()
            or IsUIFrameShown("CreatorFestival") 
            or getglobal("MapRoom"):IsShown()
            or IsRoomFrameShown() then --0.50.0以前版本正常，时间关系来不及追溯问题发生原因，暂时这样解决0.50.0版本从房间列表点击查看地图再点联机无法打开地图选房界面的问题，待后续再追溯

        if getglobal("LoadLoopFrame"):IsShown() then
            ShowLoadLoopFrame(false)
        end
        local ge = GameEventQue:getCurEvent()
        if ge.body.roomseverdata.result == 3 then
            if not ClientCurGame:isInGame() then
                --游戏外
                --从工坊进入
                if GetMiniWorksOneKeyEnterRoomState() >= 0 then
                    if GetMiniWorksOneKeyEnterRoomState() == 1 then
                        -- EnterMainMenuInfo.EnterMainMenuBy = "MiniWork";
                        ReqRoomByOwId()
                    else    
                        Log("lobby:GIE_RSCONNECT_RESULT: 1111")
    
                        if not IsArchiveMapCollaborationMode() then
                            if not getglobal("MapRoom"):IsShown() then
                                HideLobby()
                                OpenRoomFrame(nil, keeplast, false, jumpParam)
                                SetRoomFrameLevel(1500)
                                ReqRoomByOwId(nil, nil, false)
                            end
                        end 
                    end
                end
            else
                getglobal("SetMenuFrame"):Hide();
                --游戏中
            end

            if FastOnlineWID > 0 then
                --快速联机
                Log("1. GIE_RSCONNECT_RESULT:CreateRoom: FastOnlineWID = " .. FastOnlineWID);
                if getglobal("PlayerExhibitionCenter"):IsShown() then 
                    getglobal("PlayerExhibitionCenter"):Hide();
                    getglobal("ExhibitionMapFrameEditFrame"):Hide();
                end

                if getglobal("MiniWorksFrame"):IsShown() then 
                    getglobal("MiniWorksFrame"):Hide();
                end
                FastOpenOnLine(FastOnlineWID);
            end
        elseif ge.body.roomseverdata.result == 5 then
            if ClientCurGame:isInGame() then
                if IsRoomOwner() then	--主机
                    MessageBox(8, GetS(219));
                    getglobal("MessageBoxFrame"):SetClientString( "主机断连" );
                end 
            else
                ShowGameTips(GetS(146), 3);
            end
        elseif ge.body.roomseverdata.result == 14 and ClientCurGame:isInGame() then
            ShowLoadLoopFrame(false)
            ShowGameTips(GetS(8033), 3);
        elseif ge.body.roomseverdata.result == 99 and ClientCurGame:isInGame() then
            ClientAcceptInviteJoinRoom();
        elseif ge.body.roomseverdata.result < 5 then
            ShowGameTips(GetS(506), 3);
        end

        if not (ge.body.roomseverdata.result == 3 or ge.body.roomseverdata.result == 9) then
            SetMiniWorksOneKeyEnterRoomState(0);
        end

        if GetMiniWorksOneKeyEnterRoomState() < 0 then
            SetMiniWorksOneKeyEnterRoomState(0);
        end
        -- if HasUIFrame("MapRoom") and GetInst("UIManager"):GetCtrl("MapRoom") then
        --     GetInst("UIManager"):GetCtrl("MapRoom"):RoomServerConnected(ge.body.roomseverdata.result == 3)
        -- end
    end
    FastOnlineWID = 0;
end

function RoomService:IsOfficialRoomByRoomID(roomID)
    roomID = tostring(roomID)
    if tonumber(roomID) then
        return false
    elseif string.match(roomID, '^%d+_%d+$') then
        local _, rid = string.match(roomID, '^(%d+)_(%d+)$')
        return rid == '0'
    elseif string.match(roomID, '^%d+_.+$') then
        return true
    end
end