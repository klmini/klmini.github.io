local getglobal = _G.getglobal;

local Android = _G.Android

local ChannelRewardState = {
	UNKNOWN = -1, --未领取
	NOT_REWARDED = 0, --未领取
	AVAILABLE = 1, --可领取
	REWARDED = 2, --已领取
}

------------------------------------------------------------------------------ChannelRewardView------------------------------------------------------------------------------
--[[
	只处理ChannelRewardFrame下的UI显示
]]
local ChannelRewardView = {
    MAX_REWARD_COUNT = 5,
	mCallback = nil,
	
}

function ChannelRewardView:init()
	
end

function ChannelRewardView:displayFunctionalButtonState(channelRewardState)
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	local apiId = ClientMgr:getApiId();
	-- body
	-- local list = ns_ma.reward_list[ChannelRewardData.taskId];
	-- print("displayFunctionalButtonState(): list = ", list);
	print("displayFunctionalButtonState(): channelRewardState = ", channelRewardState);
	if channelRewardState then
		if channelRewardState == ChannelRewardState.AVAILABLE then --可领取
			getglobal("ChannelRewardFrameReceiveBtnNormal"):SetGray(false); --TODO
			getglobal("ChannelRewardFrameReceiveBtnPushedBG"):SetGray(false);
			getglobal("ChannelRewardFrameReceiveBtnName"):SetText(GetS(3028));
			getglobal("ChannelRewardFrameReceiveBtn"):Show();
			if apiId == 21 or apiId == 13 or apiId == 54 then 
				getglobal("ChannelRewardFrameGameCenterBtn"):Hide();
			else
				getglobal("ChannelRewardFrameGameCenterBtn"):Show();
			end
		elseif channelRewardState == ChannelRewardState.REWARDED then --已领取
			getglobal("ChannelRewardFrameReceiveBtnNormal"):SetGray(true);
			getglobal("ChannelRewardFrameReceiveBtnPushedBG"):SetGray(true);
			getglobal("ChannelRewardFrameReceiveBtnName"):SetText(GetS(3029));
			getglobal("ChannelRewardFrameReceiveBtn"):Show();
			if apiId == 21 or apiId == 13 or apiId == 54 then 
				getglobal("ChannelRewardFrameGameCenterBtn"):Hide();
			else
				getglobal("ChannelRewardFrameGameCenterBtn"):Show();
			end
		else -- 未领取
			print("displayFunctionalButtonState(): channelRewardState == X else");
			getglobal("ChannelRewardFrameReceiveBtnNormal"):SetGray(true);
			getglobal("ChannelRewardFrameReceiveBtnPushedBG"):SetGray(true);
			getglobal("ChannelRewardFrameReceiveBtnName"):SetText(GetS(3158));
			--应用宝和OPPO按钮合并
			if apiId == 21 or apiId == 13 or apiId == 54 then 
				self.mCallback:requestGetGameCenterJumpState();
			else
				getglobal("ChannelRewardFrameGameCenterBtn"):Show();
				getglobal("ChannelRewardFrameReceiveBtn"):Show();
			end
		end
	else
		print("displayFunctionalButtonState(): channelRewardState else");
		getglobal("ChannelRewardFrameReceiveBtnNormal"):SetGray(true);
		getglobal("ChannelRewardFrameReceiveBtnPushedBG"):SetGray(true);
		getglobal("ChannelRewardFrameReceiveBtnName"):SetText(GetS(3158));
		--应用宝和OPPO按钮合并
		if apiId == 21 or apiId == 13 or apiId == 54 then 
			self.mCallback:requestGetGameCenterJumpState();
		else
			getglobal("ChannelRewardFrameGameCenterBtn"):Show();
			getglobal("ChannelRewardFrameReceiveBtn"):Show();
		end
	end

	if channelRewardState and channelRewardState == ChannelRewardState.AVAILABLE then --可领取
		-- getglobal("MiniLobbyFrameTopChannelRewardBtnRedTag"):Show();
		ShowMiniLobbyChannelRewardRedTag(); --mark by hfb for new minilobby
	else
		-- getglobal("MiniLobbyFrameTopChannelRewardBtnRedTag"):Hide();
		HideMiniLobbyChannelRewardRedTag(); --mark by hfb for new minilobby
	end
end

function ChannelRewardView:hideRewardGiftList()
	local szUINamePrefix = "ChannelRewardFrameReward";
	for i=1, 5 do
		getglobal(szUINamePrefix .. i):Hide();
	end
end

function ChannelRewardView:displayRewardGiftList(rewardGiftList)
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	local apiId = ClientMgr:getApiId();
--	print("displayRewardGiftList(): rewardGiftList = ", rewardGiftList);
	if not rewardGiftList or type(rewardGiftList) ~= "table" then 
		self:hideRewardGiftList();
		return 
	end
	local length = #rewardGiftList;
	print("displayRewardGiftList(): length = ", length);
	if length <= 0 then
		return 
	end
	local szUINamePrefix = "ChannelRewardFrameReward";
	local marginX = 34
	if length == 2 then
		marginX = 180
	elseif length == 5 then
		marginX = 7
	end
	local offsetY = 2
	if apiId == 13 or apiId == 54 then 
		offsetY = 26
	end
	LayoutManagerFactory:newHorizontalSplitLayoutManager()
		:setPoint("top")
		:setRelativeTo("ChannelRewardFrameChenDi")
		:setRelativePoint("bottom")
		:setBoxItemNamePrefix(szUINamePrefix)
		:setOffsetY(offsetY)
		:setMarginX(marginX)
		:layoutAll(length, 5)
		:recycle()
	local apiId = ClientMgr:getApiId();
	for i=1, length do 
		local gift = rewardGiftList[i]
        local texIcon = getglobal(szUINamePrefix .. i .. "Icon");
		SetItemIcon(texIcon, gift.id);
        local szNameCount = gift.name.."×"..gift.num;
        getglobal(szUINamePrefix .. i .. "Name"):SetText(szNameCount);
		if apiId == 13 or apiId == 54 then 
			getglobal(szUINamePrefix .. i .. "Tips"):Show();
            getglobal(szUINamePrefix .. i .. "Tips"):SetText(gift.tips);
		else
			getglobal(szUINamePrefix .. i .. "Tips"):Hide();
		end
	end
end

function ChannelRewardView:displayGameCenterJumpState(bHasJumped)
	-- local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	-- print(debug.traceback());
	print("displayGameCenterJumpState(): bHasJumped = ", bHasJumped);
	local apiId = ClientMgr:getApiId();
	if apiId == 21 or apiId == 13 or apiId == 54 then 
		if bHasJumped then 
			getglobal("ChannelRewardFrameGameCenterBtn"):Hide();
			getglobal("ChannelRewardFrameReceiveBtn"):Show();
		else
			getglobal("ChannelRewardFrameGameCenterBtn"):Show();
			getglobal("ChannelRewardFrameReceiveBtn"):Hide();
		end
	else
		getglobal("ChannelRewardFrameGameCenterBtn"):Show();
		getglobal("ChannelRewardFrameReceiveBtn"):Show();
	end
end

function ChannelRewardView:displayShowChannelRewardFrame()
	-- local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	print("displayShowChannelRewardFrame(): ");
	-- print(debug.traceback());
	local apiId = ClientMgr:getApiId()
	if apiId == 13 or apiId == 54 then -- oppo
		getglobal("ChannelRewardFrameHeadTitle"):SetText(GetS(1326, "Oppo"));
		getglobal("ChannelRewardFrameContent"):SetText(GetS(1327, GetS(1328)));
		getglobal("ChannelRewardFrameGameCenterBtn"):SetPoint("center", "ChannelRewardFrameReceiveBtn", "center", 0, 0);
		getglobal("ChannelRewardFrameGameCenterBtnName"):SetText(GetS(1328));
	elseif apiId == 36 then -- vivo
		getglobal("ChannelRewardFrameHeadTitle"):SetText(GetS(24003));
		getglobal("ChannelRewardFrameContent"):SetText(GetS(1327, GetS(1329)));
		-- getglobal("ChannelRewardFrameGameCenterBtn"):Hide();
		getglobal("ChannelRewardFrameGameCenterBtn"):Show();
		getglobal("ChannelRewardFrameGameCenterBtnName"):SetText(GetS(1329));
	elseif apiId == 21 then -- yyb
		getglobal("ChannelRewardFrameHeadTitle"):SetText(GetS(1326, GetS(5021)));
		getglobal("ChannelRewardFrameContent"):SetText(GetS(1327, GetS(5021)));
		getglobal("ChannelRewardFrameGameCenterBtnName"):SetText(GetS(1017));
		getglobal("ChannelRewardFrameGameCenterBtn"):SetPoint("center", "ChannelRewardFrameReceiveBtn", "center", 0, 0);
		getglobal("ChannelRewardFrameGameCenterBtnName"):SetText(GetS(5021));
	elseif apiId == 12 then --mi
		getglobal("ChannelRewardFrameHeadTitle"):SetText(GetS(1326, GetS(1158)));
		getglobal("ChannelRewardFrameContent"):SetText(GetS(1327, GetS(1159)));
		-- getglobal("ChannelRewardFrameGameCenterBtn"):Hide();
		getglobal("ChannelRewardFrameGameCenterBtn"):Show();
		getglobal("ChannelRewardFrameGameCenterBtnName"):SetText(GetS(1159));
	end

	if apiId == 13 or apiId == 54 then
		getglobal("ChannelRewardFrameContent"):SetPoint("center", "ChannelRewardFrameChenDi", "center", 0, -24)
		getglobal("ChannelRewardFrameTips"):SetPoint("center", "ChannelRewardFrameChenDi", "center", 0, 24)
		getglobal("ChannelRewardFrameTips"):Show();
	else
		getglobal("ChannelRewardFrameContent"):SetPoint("center", "ChannelRewardFrameChenDi", "center", 0, 0)
		getglobal("ChannelRewardFrameTips"):Hide();
	end
	self.mCallback:requestFunctionalButtonState();
	self.mCallback:requestRewardGiftList();
end

function ChannelRewardView:displayHideChannelRewardFrame()
	getglobal("ChannelRewardFrame"):Hide();
end

function ChannelRewardView:displayJumpToGameCenter(bHasJumpURL, url, bHasInstalledGameCenter)
	if bHasJumpURL and url then
		http_openBrowserUrl(url, 1)
	else
		if bHasInstalledGameCenter then
			JavaMethodInvokerFactory:obtain()
			:setSignature("()V")
			:setClassName("org/appplay/lib/GameBaseActivity")
			:setMethodName("jumpToGameCenter")
			:call()
		else
			local szGameCenterName = getglobal("ChannelRewardFrameGameCenterBtnName"):GetText();
			ShowGameTips("未安装" .. szGameCenterName);
		end
	end
end

function ChannelRewardView:displayObtainRewardGift()
	-- getglobal("MiniLobbyFrameTopChannelRewardBtnRedTag"):Hide();
	HideMiniLobbyChannelRewardRedTag(); --mark by hfb for new minilobby
end

------------------------------------------------------------------------------ChannelRewardModel------------------------------------------------------------------------------
--[[
	处理外部有Presenter调用的requestXXX函数的事件，以及在View中调用的函数
]]
local ChannelRewardModel = {
	mCallback = nil,
	m_tRewardTask = nil,
	m_tExtraRewardTask = nil,
	m_bHasJumped = false,
	--[[
		仅做ChannelRewardFrame显示使用
		关联函数：
		requestRewardGiftList
		requestSaveRewardTask
		requestSaveExtraRewardTask
	]]
	m_aShowingGifts = {},
	--[[
		给领取提示框使用
		关联函数：
		award
	]]
	m_aAwardedGifts = {},
}

function ChannelRewardModel:init()
	
end

function ChannelRewardModel:requestShowChannelRewardFrame()
	-- statisticsGameEvent(51000);
	self.mCallback:displayShowChannelRewardFrame();
end

function ChannelRewardModel:requestHideChannelRewardFrame()
	self.mCallback:displayHideChannelRewardFrame();
end
--[[
	
	Created on 2019-09-03 at 17:04:13
]]
function ChannelRewardModel:onShowingGiftRecycle()

end

function ChannelRewardModel:newShowingGift()
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	local ShowingGift, isCache = ClassesCache:obtain("ShowingGift")
	print("newShowingGift(): ShowingGift = ", ShowingGift);
	if isCache then 
		return ShowingGift
	end
	ShowingGift.onRecycle = self.onShowingGiftRecycle
	ShowingGift:onRecycle()
	return ShowingGift
end

function ChannelRewardModel:insertShowingGift(id, num, name, tips)
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	print("insertShowingGift(): id = ", id);
	print("insertShowingGift(): name = ", name);
	if not id then return false end
	local showingGifts = self.m_aShowingGifts;
	if not showingGifts then
		showingGifts = {}
		self.m_aShowingGifts = showingGifts
	end
	for i=1, #showingGifts do 
		if showingGifts[i].id == id then 
			print("insertShowingGift(): exist");
			showingGifts[i].num = num
			showingGifts[i].name = name
			showingGifts[i].tips = tips
			return true 
		end
	end
	local ShowingGift = self:newShowingGift()
	print("insertShowingGift(): new");
	ShowingGift.id = id 
	ShowingGift.num = num
	ShowingGift.name = name
	ShowingGift.tips = tips
	showingGifts[#showingGifts + 1] = ShowingGift
	return true
end

function ChannelRewardModel:requestRewardGiftList()
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	print("requestRewardGiftList(): self.m_aShowingGifts = ", self.m_aShowingGifts);
	self.mCallback:displayRewardGiftList(self.m_aShowingGifts);
end

function ChannelRewardModel:getRewardState(rewardTask)
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	local channelRewardState = ChannelRewardState.UNKNOWN
	if not rewardTask then return channelRewardState end
	local reward_list = ns_ma.reward_list;
--	print("getRewardState(): rewardTask = ", rewardTask);
	if rewardTask then 
		local taskId = rewardTask.id
		--[[
			例：
			reward_task =  {
				get_cd_time = 1566302252, 
				stat = 0, 
				finish_time = 1566302252, 
				complete_time = 1566302123, 
				static = {
					cd_finish_count = 1, 
					all_finish_count = 1, 
					start_time_stamp = 1514736000, 
					cd_begin_time = 1566302123, 
					cd_day = 1
				}
			} 
		]]
		local reward_task
		if taskId then 
			reward_task = reward_list[taskId]
		end
		-- print("getRewardState(): reward_task = ", reward_task);
		-- if not reward_task.stat then 
		-- 	reward_task = rewardTask
		-- end
		if reward_task then 
			channelRewardState = reward_task.stat
		end
	end
	-- print("getRewardState(): channelRewardState = ", channelRewardState);
	return channelRewardState;
end

--[[
	根据self.m_tRewardTask中的id去取ns_ma.reward_list的领取状态
]]
function ChannelRewardModel:requestFunctionalButtonState()
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	-- local list = ns_ma.reward_list[ChannelRewardData.taskId];
	local ChannelRewardState = ChannelRewardState
	local channelRewardState = self:getRewardState(self.m_tRewardTask);
	local channelExtraRewardState = self:getRewardState(self.m_tExtraRewardTask);
	print("requestFunctionalButtonState(): channelRewardState = ", channelRewardState);
	print("requestFunctionalButtonState(): channelExtraRewardState = ", channelExtraRewardState);
    if channelExtraRewardState == ChannelRewardState.UNKNOWN then
        self.mCallback:displayFunctionalButtonState(channelRewardState)
    else
        if channelRewardState == ChannelRewardState.AVAILABLE or channelExtraRewardState == ChannelRewardState.AVAILABLE then
            self.mCallback:displayFunctionalButtonState(ChannelRewardState.AVAILABLE)
        elseif channelRewardState == ChannelRewardState.NOT_REWARDED or channelExtraRewardState == ChannelRewardState.NOT_REWARDED then
            self.mCallback:displayFunctionalButtonState(ChannelRewardState.NOT_REWARDED)
        else
            self.mCallback:displayFunctionalButtonState(channelRewardState)
        end
    end
end

--[[
	获取跳转并标记为已跳转
]]
function ChannelRewardModel:requestSwitchOnGameCenterJumpState()
	self:requestGetGameCenterJumpState();
	self.m_bHasJumped = self.bHasJumped or true;
end

function ChannelRewardModel:requestGetGameCenterJumpState()
	-- local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	local bHasJumped = self.m_bHasJumped;
	print("requestGetGameCenterJumpState(): bHasJumped = ", bHasJumped);
	self.mCallback:displayGameCenterJumpState(bHasJumped)
end

--[[
	拉取福利配置后保存
	例：
	rewardTask = {
		id = 18012901,
		title = "OPPO游戏中心启动每日福利",
		start_time = '2018-01-01 00:00:00',
		end_time = '2019-12-30 23:59:59',
		close_time = '2019-12-30 23:59:59',
		conditions = {
			version_min = "0.23.0",
			apiids = '13,54',

		},
		task_conditions = {
			start_game_out = 13,
		},
		repeat_task = {
			cd = 1, --每天一个周期
			times = 1, --周期内可完成1次
			max = 1000, --最多领100次
		},

		gift = {
			{ id = 12962, num = 1 },
		},
	}
]]
function ChannelRewardModel:requestSaveRewardTask(rewardTask)
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	print("requestSaveRewardTask(): tostring(rewardTask) = ", tostring(rewardTask));
	if not rewardTask then return end
	print("requestSaveRewardTask(): rewardTask.id = ", rewardTask.id);
	if not self.m_tRewardTask then 
		self.m_tRewardTask = rewardTask
	elseif rewardTask.id and self.m_tRewardTask.id and rewardTask.id == self.m_tRewardTask.id then 
		print("requestSaveRewardTask(): self.m_tRewardTask.id = ", self.m_tRewardTask.id);
		self.m_tRewardTask = rewardTask
	end

	local giftList = rewardTask.gift
	print("requestSaveRewardTask(): giftList = ", giftList);
	if giftList then for j=1, #giftList do
        local itemDef = ItemDefCsv:get(giftList[j].id);
        if itemDef then
			self:insertShowingGift(giftList[j].id, giftList[j].num, itemDef.Name, GetS(1156))
        end
	end end
end

function ChannelRewardModel:requestSaveExtraRewardTask(extraRewardTask)
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	print("requestSaveExtraRewardTask(): tostring(extraRewardTask) = ", tostring(extraRewardTask));
	if not extraRewardTask then return end
	print("requestSaveExtraRewardTask(): extraRewardTask.id = ", extraRewardTask.id);
	if not self.m_tExtraRewardTask then 
		self.m_tExtraRewardTask = extraRewardTask
	elseif extraRewardTask.id and self.m_tExtraRewardTask.id and extraRewardTask.id == self.m_tExtraRewardTask.id then 
		print("requestSaveExtraRewardTask(): self.m_tExtraRewardTask.id = ", self.m_tExtraRewardTask.id);
		self.m_tExtraRewardTask = extraRewardTask
	end

	local giftList = extraRewardTask.gift
	print("requestSaveExtraRewardTask(): giftList = ", giftList);
	if giftList then for j=1, #giftList do
        local itemDef = ItemDefCsv:get(giftList[j].id);
        if itemDef then
			self:insertShowingGift(giftList[j].id, giftList[j].num, itemDef.Name, GetS(1155))
        end
	end end
end

function ChannelRewardModel:requestJumpToGameCenter()
	local print, Log = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	-- statisticsGameEvent(51004);
	local apiId = ClientMgr:getApiId();
	local priority_jump = ns_version.priority_jump;
	self.m_bHasJumped = true
	-- print("requestJumpToGameCenter(): priority_jump = ", priority_jump);
	if priority_jump and check_apiid_ver_conditions(priority_jump) and priority_jump[apiId] then 
		local url = priority_jump[apiId];
		print("requestJumpToGameCenter(): url = ", url);
		self.mCallback:displayJumpToGameCenter(true, url, false);
	else
		local installed = JavaMethodInvokerFactory:obtain()
			:setSignature("()Z")
			:setClassName("org/appplay/lib/GameBaseActivity")
			:setMethodName("checkGameCenterInstalled")
			:call()
			:getBoolean();
		self.mCallback:displayJumpToGameCenter(false, nil, installed);
		if installed == false then
			return
		end
	end

	local uin = AccountManager:getUin();
	local function onResponseExtraRewardTask(ret)
		local print, Log = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
		print("onResponseExtraRewardTask(): ret = ", ret);
	end

	local function onResponseRewardTask(ret)
		local print, Log = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
		print("onResponseRewardTask(): ret = ", ret);
	end

	if apiId == 13 or apiId == 54 --Oppo 
	then
		if  uin and uin >= 1000 then
			local week_day_url = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=week_day&out=' .. apiId .. '&' .. http_getS1();
			print("requestJumpToGameCenter(): week_day_url = ", week_day_url);
			-- ns_http.func.rpc_string( week_day_url, onResponseExtraRewardTask, nil, nil );
			threadpool:work(ns_http.func.rpc_string, week_day_url, onResponseExtraRewardTask);
		end
	end

	threadpool:wait(2);
	if apiId == 21 --应用宝
	or apiId == 13 or apiId == 54 --Oppo
	or apiId == 36 --vivo
	or apiId == 12 --小米
	then 
		self:requestFunctionalButtonState();
		self:requestSwitchOnGameCenterJumpState();
		if  uin and uin >= 1000  then
			local reward_task_url = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=start_game_out&out=' .. apiId .. '&' .. http_getS1();
			print("requestJumpToGameCenter(): reward_task_url = ", reward_task_url);
			ns_http.func.rpc_string( reward_task_url, onResponseRewardTask, nil, nil, true );
		end
		local ActivityMainCtrl = _G.ActivityMainCtrl
		ActivityMainCtrl.last_call_get_reward_list = 0;
		-- ActivityMainCtrl:RequestWelfareRewardData();
		threadpool:work(ActivityMainCtrl.RequestWelfareRewardData, ActivityMainCtrl);
	end
	if apiId == 21 then
		threadpool:wait(2);
	end
end

--[[
	逻辑处理接近ns_ma.func.requestAward
	区别：将所有任务的奖励放置到m_aAwardedGifts，统一在请求完奖励后，提供UI提示
]]
function ChannelRewardModel:award(taskId)
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	local ns_ma = _G.ns_ma;
	print("award(): taskId = ", taskId);
	local reward_random = ns_ma.reward_random
	local reward_map = ns_ma.reward_map
	if not taskId or taskId <= 0 then
		return
	end
	-- local result, avatorList = AccountManager:getAccountData():notifyServerReceiveAward( taskId , (reward_random[taskId] or -1));
	-- print("award(): reward_random[taskId] = ", reward_random[taskId]);
	-- if reward_random[taskId] then
	-- 	--随机奖励已经被领取
	-- 	reward_random[taskId] = -1
	-- end
	-- if result ~= 0 then 
	-- 	ShowGameTips(GetS(3402), 5);
	-- 	print("award(): cannot award");
	-- 	return
	-- end
	-- print("award(): award unlocked!");
	-- ClientMgr:playSound2D("sounds/ui/info/book_seriesunlock.ogg", 1);

	-- if reward_map[taskId] and #reward_map[taskId] == 0 and reward_map[taskId .. "temp"] and #reward_map[taskId .. "temp"] > 0 then
	-- 	reward_map[taskId] = copy_table(reward_map[taskId .. "temp"])
	-- end

	-- print("award(): reward_map[taskId] = ", reward_map[taskId]);
	-- local reward_list = reward_map[taskId] or {};
	-- --LLDO:已拥有的avator装扮转化为迷你豆
	-- if avatorList then
	-- 	Log("award, avatorList:");
	-- 	for i = 1, #avatorList do
	-- 		for j = 1, #reward_list do
	-- 			if reward_list[j].id == avatorList[i][1] then
	-- 				--需要转化为迷你豆
	-- 				reward_list[j].id = 10000;
	-- 				reward_list[j].num = avatorList[i][2];
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- --增加积分 10003 or 10004
	-- for j = 1, #reward_list do
	-- 	if reward_list[j].id == 10003 or  reward_list[j].id == 10004 then
	-- 		--转化为迷你盒子积分
	-- 		print("award(): reward_list[j].id = ", reward_list[j].id);
	-- 		add_miniTreasures_score( reward_list[j] )
	-- 	end
	-- end

	-- -- 原ns_ma.func.requestAward有的处理逻辑
	-- -- SetGameRewardFrameInfo( GetS(3403), reward_list, "");
	-- local awardedGifts = self.m_aAwardedGifts
	-- for j = 1, #reward_list do
	-- 	--将所有任务的奖励集中到这个table中显示
	-- 	awardedGifts[#awardedGifts + 1] = reward_list[j]
	-- end

	-- --成就任务检测:神秘礼物
	-- ArchievementGetInstance().func:checkReward(taskId);
	-- print("award(): checkReward");

	local gid = gen_gid()
	local timeout = 15
	local function callback(ret)
		print("award(): reward_random[taskId] = ", reward_random[taskId]);
		if reward_random[taskId] then
			--随机奖励已经被领取
			reward_random[taskId] = -1
		end
		local result = -1
		if ret and ret.ret == 0 then
			result = 0
		end

		if result ~= 0 then 
			ShowGameTips(GetS(3402), 5);
			print("award(): cannot award");
			threadpool:notify(gid, result)
			return
		end
		print("award(): award unlocked!");
		ClientMgr:playSound2D("sounds/ui/info/book_seriesunlock.ogg", 1);

		local reward_list = {}
		if type(ret.data) == "table" and type(ret.data.itemmap) == "table" and next(ret.data.itemmap) then
			reward_list = ret.data.itemmap
		end

		--增加积分 10003 or 10004
		local awardedGifts = self.m_aAwardedGifts
		for j = 1, #reward_list do
			if reward_list[j].id == 10003 or  reward_list[j].id == 10004 then
				--转化为迷你盒子积分
				print("award(): reward_list[j].id = ", reward_list[j].id);
				add_miniTreasures_score( reward_list[j] )
			end

			--将所有任务的奖励集中到这个table中显示
			awardedGifts[#awardedGifts + 1] = reward_list[j]
		end

		-- 原ns_ma.func.requestAward有的处理逻辑
		-- SetGameRewardFrameInfo( GetS(3403), reward_list, "");

		--成就任务检测:神秘礼物
		ArchievementGetInstance().func:checkReward(taskId);
		print("award(): checkReward");
		threadpool:notify(gid, result)
	end

	ReqServerReceiveAward(taskId, (reward_random[taskId] or -1), callback)
	threadpool:wait(gid, timeout)
end

function ChannelRewardModel:beRewardedWith(rewardTask)
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	local ns_ma = _G.ns_ma
	local reward_list = ns_ma.reward_list
	if not rewardTask then
		print("beRewardedWith(): rewardTask nil");
		return ChannelRewardState.UNKNOWN;
	end
	local taskId = rewardTask.id;
	local giftList = rewardTask.gift;
	-- print("beRewardedWith(): rewardTask = ", rewardTask);
	print("beRewardedWith(): taskId = ", taskId);
	print("beRewardedWith(): reward_list[taskId] = ", reward_list[taskId]);
	if not reward_list[taskId] then 
		print("beRewardedWith(): no such task: taskId = ", taskId);
		return ChannelRewardState.UNKNOWN;
	end
	if not reward_list[taskId].stat then 
		print("beRewardedWith(): does not receive the reward_list[taskId].stat from server: taskId = ", taskId);
		return ChannelRewardState.UNKNOWN;
	end
	if  reward_list[taskId].stat == ChannelRewardState.AVAILABLE then
		rewardTask.stat = reward_list[taskId].stat
		--可以领取
		--如果服务发来奖励
		if reward_list[taskId] and reward_list[taskId].gift then
			giftList = reward_list[taskId].gift;
		end
	
		--检查仓库是否已满
		local rewardGiftIdList = {};
		for i=1,#(giftList) do
			table.insert(rewardGiftIdList, giftList[i].id);
		end
		local true_or_false = AccountManager.itemlist_can_add and AccountManager:itemlist_can_add(rewardGiftIdList) or true;
		if true_or_false == false then
			StashIsFullTips();
			return false;
		end

		self:award(taskId)

		--将这个任务设置为已经领取
		if reward_list[taskId] and reward_list[taskId].stat then
			reward_list[taskId].stat = ChannelRewardState.REWARDED;  --已经领取
			rewardTask.stat = reward_list[taskId].stat
		end
		print("beRewardedWith(): tostring(reward_list[taskId]) = ", tostring(reward_list[taskId]));
		print("beRewardedWith(): tostring(rewardTask) = ", tostring(rewardTask));
	
		return reward_list[taskId].stat
	elseif reward_list[taskId].stat == ChannelRewardState.REWARDED then
		print("beRewardedWith(): has been rewarded");
		return reward_list[taskId].stat
	elseif reward_list[taskId].stat == ChannelRewardState.NOT_REWARDED then
		print("beRewardedWith(): has not been rewarded");
		return reward_list[taskId].stat
	end
end

function ChannelRewardModel:requestBeingRewarded()
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	local ChannelRewardState = ChannelRewardState;
	print("requestBeingRewarded(): ");
	statisticsGameEvent(51005);
	-- 移除先前已获得的奖励
	local awardedGifts = self.m_aAwardedGifts;
	for i=1, #awardedGifts do 
		awardedGifts[i] = nil;
	end
	local hasBeenRewarded = self:beRewardedWith(self.m_tRewardTask);
	print("requestBeingRewarded(): hasBeenRewarded = ", hasBeenRewarded);
	local hasBeenRewardedWithExtra = self:beRewardedWith(self.m_tExtraRewardTask);
	print("requestBeingRewarded(): hasBeenRewardedWithExtra = ", hasBeenRewardedWithExtra);
	if hasBeenRewarded ~= ChannelRewardState.AVAILABLE and hasBeenRewardedWithExtra ~= ChannelRewardState.AVAILABLE then
		self.mCallback:displayObtainRewardGift()
	end

    if hasBeenRewardedWithExtra == ChannelRewardState.UNKNOWN then
        self.mCallback:displayFunctionalButtonState(hasBeenRewarded)
    else
        if hasBeenRewarded == ChannelRewardState.AVAILABLE or hasBeenRewardedWithExtra == ChannelRewardState.AVAILABLE then
            self.mCallback:displayFunctionalButtonState(ChannelRewardState.AVAILABLE)
        elseif hasBeenRewarded == ChannelRewardState.NOT_REWARDED or hasBeenRewardedWithExtra == ChannelRewardState.NOT_REWARDED then
            self.mCallback:displayFunctionalButtonState(ChannelRewardState.NOT_REWARDED)
        else
            self.mCallback:displayFunctionalButtonState(hasBeenRewarded)
        end
	end

	print("requestBeingRewarded(): awardedGifts = ", awardedGifts);
	--SetGameRewardFrameInfo(GetS(3403), awardedGifts, "");
	local rewardMgr = GetInst("RewardMgr")
	if rewardMgr then
		local rewardList = {}
		rewardList.title = GetS(3403)
		rewardList.desc = ""
		rewardList.data = awardedGifts
		rewardMgr:PushReward(rewardList, rewardMgr:GetDataTypeEnum().task_reward)
	end
	print("requestBeingRewarded(): SetGameRewardFrameInfo");
end


------------------------------------------------------------------------------ChannelRewardPresenter------------------------------------------------------------------------------
_G.ChannelRewardPresenter = {

}

function ChannelRewardPresenter:init()
    MVPUtils:registerSelfViewModel(self, ChannelRewardView, ChannelRewardModel);
end

function ChannelRewardPresenter:onRegisterEvent()
	-- this:RegisterEvent("GE_MVP_ON_CLICK_LISTENER");
end

function ChannelRewardPresenter:onGameEvent(args)
    self.m_clsView:onGameEvent(args)
    self.m_clsModel:onGameEvent(args)
end

ChannelRewardPresenter:init();


-------------------------------------------------------旧版ChannelRewardFrame逻辑--------------------------------------------
_G.ChannelRewardData = {
	gift = {},
	taskId = 0,
	hasJumpped = {

	},
}

-- function UpdateChannelRewardFrame(gift, taskId)
-- 	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
-- 	-- print(debug.traceback());
-- 	statisticsGameEvent(51000);
-- 	ChannelRewardData.gift = gift;
-- 	ChannelRewardData.taskId = taskId;
-- 	local reward_list = ns_ma.reward_list
-- 	local apiId = ClientMgr:getApiId()
-- 	--print("UpdateChannelRewardFrame(): gift = ", gift);
-- 	-- print("UpdateChannelRewardFrame(): taskId = ", taskId);
-- 	-- print("UpdateChannelRewardFrame(): ChannelRewardData.taskId = ", ChannelRewardData.taskId);
-- 	if apiId == 13 then -- oppo
-- 		getglobal("ChannelRewardFrameHeadTitle"):SetText(GetS(1326, "OPPO"));
-- 		getglobal("ChannelRewardFrameContent"):SetText(GetS(1327, GetS(1328)));
-- 		getglobal("ChannelRewardFrameGameCenterBtn"):Show();
-- 	elseif apiId == 36 then -- vivo
-- 		getglobal("ChannelRewardFrameHeadTitle"):SetText(GetS(1326, "VIVO"));
-- 		getglobal("ChannelRewardFrameContent"):SetText(GetS(1327, GetS(1329)));
-- 		getglobal("ChannelRewardFrameGameCenterBtn"):Hide();
-- 	elseif apiId == 21 then -- yyb
-- 		getglobal("ChannelRewardFrameHeadTitle"):SetText(GetS(1326, GetS(5021)));
-- 		getglobal("ChannelRewardFrameContent"):SetText(GetS(1327, GetS(5021)));
-- 		getglobal("ChannelRewardFrameGameCenterBtnName"):SetText(GetS(1017));
-- 		getglobal("ChannelRewardFrameGameCenterBtn"):SetPoint("center", "ChannelRewardFrameReceiveBtn", "center", 0, 0);
-- 		local list = reward_list[taskId];
-- 		print("UpdateChannelRewardFrame(): list = ", list);
-- 		if list then
-- 			print("UpdateChannelRewardFrame(): list.stat = ", list.stat);
-- 			if list.stat == 1 then --可领取
-- 				getglobal("ChannelRewardFrameGameCenterBtn"):Hide();
-- 				getglobal("ChannelRewardFrameReceiveBtn"):Show();
-- 			elseif list.stat == 2 then --已领取
-- 				getglobal("ChannelRewardFrameGameCenterBtn"):Hide();
-- 				getglobal("ChannelRewardFrameReceiveBtn"):Show();
-- 			else
-- 				getglobal("ChannelRewardFrameGameCenterBtn"):Show();
-- 				getglobal("ChannelRewardFrameReceiveBtn"):Hide();
-- 			end
-- 		else
-- 			-- for k, v in pairs(reward_list) do 
-- 			-- 	print("WWW_file_version_callback(): ns_ma.reward_list[" .. k .. "] = ", v);
-- 			-- end
-- 			getglobal("ChannelRewardFrameGameCenterBtn"):Hide();
-- 			getglobal("ChannelRewardFrameReceiveBtn"):Show();
-- 		end
-- 	elseif apiId == 12 then --mi
-- 		getglobal("ChannelRewardFrameHeadTitle"):SetText(GetS(1326, GetS(1158)));
-- 		getglobal("ChannelRewardFrameContent"):SetText(GetS(1327, GetS(1159)));
-- 		getglobal("ChannelRewardFrameGameCenterBtn"):Hide();
-- 	end
-- 	CenteredDisplayGift(gift, "ChannelRewardFrameReward");
-- end

-- function CenteredDisplayGift(gift, frame)
--     local spaceBetween = 50
--     if gift and #gift > 0 then
--         getglobal(frame .. "1"):SetPoint("top", "ChannelRewardFrameChenDi", "bottom", -(130 + spaceBetween)/2 * (#gift - 1), 22)
--     end

-- 	for i=1, 5 do
-- 		if not gift or i > #gift then
-- 			getglobal(frame .. i):Hide();
-- 		else
-- 			SetItemIcon(getglobal(frame .. i .. "Icon"), gift[i].id);
-- 			local itemDef = ItemDefCsv:get(gift[i].id);
-- 			if itemDef then
-- 				local text = itemDef.Name.."×"..gift[i].num;
-- 				getglobal(frame .. i .. "Name"):SetText(text);
-- 			end

-- 			if i >1 then
-- 				getglobal(frame .. i):SetPoint("left", frame .. (i - 1), "right", spaceBetween, 0);
-- 			end
-- 		end
-- 	end
-- end

-- function UpdateChannelRewardReceiveBtnState()
-- 	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
-- 	local apiId = ClientMgr:getApiId();
-- 	-- body
-- 	local list = ns_ma.reward_list[ChannelRewardData.taskId];
-- 	-- print("UpdateChannelRewardReceiveBtnState(): list = ", list);
-- 	print("UpdateChannelRewardReceiveBtnState(): list.stat = ", list and list.stat or "nil");
	
-- 	if list then
-- 		print("UpdateChannelRewardReceiveBtnState(): list");
-- 		if list.stat == 1 then --可领取
-- 			getglobal("ChannelRewardFrameReceiveBtnNormal"):SetGray(false); --TODO
-- 			getglobal("ChannelRewardFrameReceiveBtnPushedBG"):SetGray(false);
-- 			getglobal("ChannelRewardFrameReceiveBtnName"):SetText(GetS(3028));
-- 		elseif list.stat == 2 then --已领取
-- 			getglobal("ChannelRewardFrameReceiveBtnNormal"):SetGray(true);
-- 			getglobal("ChannelRewardFrameReceiveBtnPushedBG"):SetGray(true);
-- 			getglobal("ChannelRewardFrameReceiveBtnName"):SetText(GetS(3029));
-- 		else -- 未领取
-- 			print("UpdateChannelRewardReceiveBtnState(): list.stat else");
-- 			getglobal("ChannelRewardFrameReceiveBtnNormal"):SetGray(true);
-- 			getglobal("ChannelRewardFrameReceiveBtnPushedBG"):SetGray(true);
-- 			getglobal("ChannelRewardFrameReceiveBtnName"):SetText(GetS(3158));
-- 			ChannelRewardData.hasJumpped[apiId] = false
-- 		end
-- 	else
-- 		print("UpdateChannelRewardReceiveBtnState(): list else");
-- 		getglobal("ChannelRewardFrameReceiveBtnNormal"):SetGray(true);
-- 		getglobal("ChannelRewardFrameReceiveBtnPushedBG"):SetGray(true);
-- 		getglobal("ChannelRewardFrameReceiveBtnName"):SetText(GetS(3158));
-- 		if apiId == 21 then 
-- 			if not ChannelRewardData.hasJumpped[apiId] then
-- 				getglobal("ChannelRewardFrameGameCenterBtn"):Show();
-- 				getglobal("ChannelRewardFrameReceiveBtn"):Hide();
-- 			end
-- 		end
-- 	end
-- end

-- function ChannelRewardFrame_OnShow()
-- 	UpdateChannelRewardReceiveBtnState();
-- end

-- function ChannelRewardFrameCloseBtn_OnClick()
-- 	getglobal("ChannelRewardFrame"):Hide();
-- end

-- function ChannelRewardFrameReceiveBtn_OnClick()

-- 	Log( "call ChannelRewardFrameReceiveBtn_OnClick" )
-- 	statisticsGameEvent(51005);

-- 	local taskId = ChannelRewardData.taskId;
-- 	local gift_   = ChannelRewardData.gift;
-- 	print("ChannelRewardFrameReceiveBtn_OnClick ChannelRewardData = ", ChannelRewardData)

-- 	--是否可以领取
-- 	if  ns_ma.reward_list[taskId] and ns_ma.reward_list[taskId].stat and ns_ma.reward_list[taskId].stat == 1 then
-- 		--可以领取
-- 	else
-- 		Log("stat not 1")
-- 		return
-- 	end

-- 	--如果服务发来奖励
-- 	if  ns_ma.reward_list[taskId] and ns_ma.reward_list[taskId].gift then
-- 		gift_ = ns_ma.reward_list[taskId].gift;
-- 	end

-- 	--检查仓库是否已满
-- 	local t_reward_id = {};
-- 	for i=1,#(gift_) do
-- 		table.insert(t_reward_id,gift_[i].id);
-- 	end
-- 	local true_or_false = AccountManager.itemlist_can_add and AccountManager:itemlist_can_add(t_reward_id) or true;
-- 	if true_or_false == false then
-- 		StashIsFullTips();
-- 		return;
-- 	end

-- 	ns_ma.func.award(taskId);

-- 	--将这个任务设置为已经领取
-- 	if  ns_ma.reward_list[taskId] and ns_ma.reward_list[taskId].stat then
-- 		ns_ma.reward_list[taskId].stat = 2;  --已经领取
-- 	end

-- 	UpdateChannelRewardReceiveBtnState();
-- 	getglobal("MiniLobbyFrameTopChannelRewardBtnRedTag"):Hide();
-- end

-- function ChannelRewardFrameGameCenterBtn_OnClick()
-- 	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
-- 	statisticsGameEvent(51004);
-- 	local apiId = ClientMgr:getApiId();
-- 	local priority_jump = ns_version.priority_jump;
-- 	ChannelRewardData.hasJumpped[apiId] = true
-- 	print("ChannelRewardFrameGameCenterBtn_OnClick(): priority_jump = ", priority_jump);
-- 	if priority_jump and check_apiid_ver_conditions(priority_jump) and priority_jump[apiId] then 
-- 		local url = priority_jump[apiId];
-- 		print("ChannelRewardFrameGameCenterBtn_OnClick(): url = ", url);
-- 		http_openBrowserUrl(url, 1)
-- 		if apiId == 21 then
-- 			threadpool:wait(1);
-- 			getglobal("ChannelRewardFrameGameCenterBtn"):Hide();
-- 			getglobal("ChannelRewardFrameReceiveBtn"):Show();
-- 			threadpool:wait(3);
-- 			openYybUrlToGetgift = true
-- 			ns_ma.start_game_out = false;
-- 			ActivityMainCtrl.last_call_get_reward_list = 0;
-- 			WWW_ma_start_game_out(apiId)
-- 		end
-- 	else
-- 		SdkManager:sdkGameCenter();
-- 	end
-- end