Room_Data = {
	password_record = {},
	cur_password = "";
}

t_Province = {
		"未知",
		"山西",
		"辽宁",
		"吉林",
		"黑龙江",
		"江苏",
		"浙江",
		"安徽",
		"福建",
		"江西",
		"山东",
		"河南",
		"湖北",
		"湖南",
		"广东",
		"海南",
		"四川",
		"贵州",
		"云南",
		"陕西",
		"甘肃",
		"青海",
		"台湾",
		"北京",
		"天津",
		"上海",
		"重庆",
		"广西",
		"内蒙古",
		"西藏",
		"宁夏",
		"新疆",
		"香港",
		"澳门",
		"河北",
		"中国",
		}
t_Isp = {
		"未知";
		"电信";
		"联通";
		"移动";
		"网通";
		"铁通";
		"有线";
		"长江";
		"广电";
		"长城";
	}



CurGetRoomNum		= 0;
--local RoomThumbnailDir = "data/http/thumbs_room/"; --下载后写入路径png
local RoomThumbnailDir = "data/http/thumbs/"; --下载后写入路径png

----------------------------------------RoomArchiveTypeFrame-----------------------------------------
local t_RoomCommonConfig = {
	flash_click = false				-- 刷新 是否点击
}


-----------------------------------RoomFrame------------------------------------------
CurChooseRoomIdx 			= 0;		--选中的房间的控件名 --这个变量使用需谨慎
EnterRoomType				= 0;		--进入的房间的世界类型

local CurRoomListType		= "RoomLobby";	--RoomLobby房间大厅 Search搜索结果 Collect收藏
-- 以下这些类型与当前通用类型已经不一样，停用，改通用类型 参考uicommon.lua function GetLabel2Owtype(type)
-- local GTSurviveGame			= 1;
-- local GTCreativeGame		= 2;
-- local GTExtremityGame		= 3;
-- local GTGameMakerGame		= 4;
-- local GTFreeSurviveGame		= 6;
-- 大厅搜索的云服列表
local t_SearchRoomCloudServerRoom = {}
-- 搜索普通房间是否为空
local bSearchRoomEmpty = false

LoginRoomClientIp		= 0;

function SetCurRoomListType(type)
	CurRoomListType = type;
end


--------------------------------------------CreateRoom------------------------------------------------------
local function GetWorldDesc(index)
	local myArchiveNum = AccountManager:getMyWorldList():getNumWorld();
	local worldInfo = nil;
	if index <= myArchiveNum then
		local worldInfo = AccountManager:getMyWorldList():getWorldDesc(index-1);
		if IsNewbieWorld(worldInfo.worldid) then
			if index < myArchiveNum then
				worldInfo = AccountManager:getMyWorldList():getWorldDesc(index);
				return worldInfo, 2;
			else
				return nil, 1;
			end
		elseif worldInfo.worldtype == 2 then	--极限模式过滤掉
			return nil, 1;
		elseif worldInfo.openpushtype >= 3 then	--正在下载或者空的地图过滤掉
			return nil, 1;
		else
			return worldInfo, 1;
		end
	else
		return nil, 1;
	end
end

------------------------------------CreateRoomFrameSet-----------------------------------------------
--暂时没用
function ReOpenRoom()
	print('kekeke ReOpenRoom');
	local info = EnterMainMenuInfo.ReopenRoomInfo;
	if RoomManager.createRoomEx then
		local createRoomParam = CreateRoomParam(info.WorldType,
			info.RoomName,
			info.CreateRoomNum,
			info.Passworld,
			info.RoomDescTex,
			info.Text,
			info.CreateType,
			info.CreateRoomLimit,
			info.IsLanRoom
		)
		createRoomParam.CanTrace = info.CanTrace and tonumber(info.CanTrace) or 0
		createRoomParam.ShareVersion = info.ShareVersion and tonumber(info.ShareVersion) or 0
		createRoomParam.CustomRoomName = info.CustomRoomName or ""
		createRoomParam.PreiNameIdx = info.PreiNameIdx or 0
		createRoomParam.editorSceneSwitch = info.editorSceneSwitch
		RoomManager:createRoomEx(createRoomParam);	
	else
		AccountManager:createRoom(info.WorldType,
				info.RoomName,
				info.CreateRoomNum,
				info.Passworld,
				info.RoomDescTex,
				info.Text,
				info.CreateType,
				info.CreateRoomLimit,
				info.IsLanRoom,
			0,
			info.ShareVersion and tonumber(info.ShareVersion) or 0,
			info.editorSceneSwitch);
	end

	if not AccountManager:requestEnterWorld(info.WorldId, true) then
		ShowGameTips(GetS(146), 3);
		-- getglobal("MiniLobbyFrame"):Show();
		ShowMiniLobby(); --mark by hfb for new minilobby
		RequestLoginRoomServer();
		return;
	end

	WWW_ma_multigame();
	ns_ma.ma_play_map_set_enter( { where="join_room3" } )

	SetAllDisableItemPermits(true);

	ShowLoadingFrame();
	
	if info.WorldType == 0 then
		StatisticsTools:gameEvent("EnterSurviveWNum");
	elseif info.WorldType == 1 or info.WorldType == 3 then
		StatisticsTools:gameEvent("EnterCreateWNum");
	end
	StatisticsTools:gameEvent("CreateRoomNum");
end

------------------------------------------LLDO:新联机大厅---------------------------------------------------------------------------
--全局变量
mIsLanRoom					= false;	--是否为局域网房间
mComeBackInlineState 		= 0			--回流联机房状态 记录这个是回流触发的联机

local mIsOpenMapFrame				= false;	--是否展开地图框
local Room_List_Max_Num				= 20;
local mRoomRoomBoxUI 				= "RoomRoomBox";	--房间滑动框
local mRoomMapBoxUI					= "RoomMapTypeRoomBox"		--地图式房间滑动框
local mFilterType 					= 1;				--房间筛选的分类 1综合 2生存 3创造 4对战 5电路 6解密 7酷跑 8其他
local mRootName 					= "RoomFrame"
function isOpenMapFrame()
	return mIsOpenMapFrame
end
--下拉框变量
local mAllRoomDropVar = {
	CurIndex = 1,
	Btns = {
		--type:0,全部; 1, 玩家; 2, 服务器
		{name=9068, type=0},
		{name=9069, type=1},
		{name=9070, type=2},
	},
};

--房间列表滚动
local t_RoomDownThumbnail = {
	beginIndex = 0,
	list = {},
}

--左侧导航按钮
local leftframebtnFirstName = "RoomFrameLeftFrameBox";
local mRoomFrameVar = {
	btnW = 128,
	btnH = 63,
	offsetY = 5,
	offsetTop = 0,
	CurLeftBtnIndex = 1,
	LastBtnIndex = 1,		--上一个按钮索引, 收藏按钮会用到, 没有房间, 则切换到之前的按钮.
	showLeftBtn = -1,       --room显示时显示左边哪一栏

	leftBtns = GetInst("MapKindMgr"):GetMapKinds(2,2)
};

--搜索框
local mRoomFrame_NetNameIDs = {9086, 9087};

--网络信号强弱图标
function UpdateNetDelayUi(room_ui, pingms)
	--Log("UpdateNetDelayUi: "..room_ui:GetName());
	local delay = getglobal(room_ui:GetName().."NetDelay");
	local netIcon = getglobal(room_ui:GetName().."NetIcon");
	if pingms > 1000 or pingms <= 0 then
		delay:SetText("N/A");
	end

	if pingms >= 300 or pingms <= 0 then
		--一般
		delay:SetText(GetS(148));
		delay:SetTextColor(195, 49, 2);
		netIcon:SetTexUV("icon_wifi_red");

	elseif pingms >= 100 then
		--良好
		delay:SetText(GetS(149));
		delay:SetTextColor(231, 141, 0);
		netIcon:SetTexUV("icon_wifi_orange");
	else
		--优秀
		delay:SetText(GetS(150));
		delay:SetTextColor(1, 194, 16);
		netIcon:SetTexUV("icon_wifi_green");
	end
end

function RoomFrame_OnLoad()
	this:setUpdateTime(0.5);

	this:RegisterEvent("GIE_UPDATE_ROOM");
	this:RegisterEvent("GIE_PING_RESULT");
	this:RegisterEvent("GIE_RSCONNECT_RESULT");
	this:RegisterEvent("GE_WORLD_CHANGE");
	this:RegisterEvent("GIE_RSCONNECT_RENT_RESULT");
	this:RegisterEvent("GE_LUA_CUSTOM_EVENT");

	RoomFrame_LeftBtnLayout();

	--注册关闭按钮事件
	UITemplateBaseFuncMgr:registerFunc("RoomFrameCloseBtn", RoomFrameBackBtn_OnClick, "联机大厅关闭按钮");
	getglobal("RoomFrameTitleName"):SetText(GetS(3443));
	getglobal("RoomFrameNoMapTipsTitleFrameName"):SetText(GetS(3769));
	--去掉帮助按钮
	getglobal("RoomFrameHelpBtn"):Hide();
	getglobal("RoomFrameTitleBkgHelp"):Hide();
	getglobal("RoomFrameTitleName"):SetAnchorOffset(30, 0);

	--创建房间面板
	-- UITemplateBaseFuncMgr:registerFunc("CreateRoomFrameBodyCloseBtn", CreateRoomFrameTopCloseBtn_OnClick, "创建房间关闭按钮");
	-- getglobal("CreateRoomFrameBodyTitleName"):SetText(GetS(9072));

	--'服务器房间'勾选按钮名
	getglobal("RoomFrameWaterMarkFrame"):SetFrameLevel(1510)

	--初始化MapTypeRoomCache	
end

function RoomFrame_OnEvent()
	if GetInst("UIEvtHook"):EventHook(arg1, GameEventQue:getCurEvent()) then
		return
	end
	local RoomFrame = getglobal("RoomFrame")
	if arg1 == "GIE_UPDATE_ROOM" then
		--1. 刷新房间列表
		if t_autojump_service.play_together.anchorUin > 0 and  t_autojump_service.play_together.csroomid <= 0 then
			if CurRoomListType == "Search" then
				RoomCloseCircleFlag()
				local ge = GameEventQue:getCurEvent();
				t_autojump_service.play_together.OnRespSeachRoom(ge.body.room.result)
			end
		else
			HandleEventRoomFrame_UpdateRoom()
		end
		-- if ReportMgr and ReportMgr.setExpInfo then
		-- 	if generateRequestID then
		-- 		local requestid = generateRequestID()
		-- 		ReportMgr:setExpInfo(nil,nil,requestid)
		-- 	end
		-- end
	elseif arg1 == "GIE_PING_RESULT" then
		--网络信号强弱
		if RoomFrame:IsShown() and CurRoomListType ~= "Search" then
			Log("GIE_PING_RESULT:");
			local ge = GameEventQue:getCurEvent();
			AllRoomManager:UpdateNetDelayByHostUin(ge.body.pingroom.uin, ge.body.pingroom.pingms, getglobal(mRoomRoomBoxUI));
		end
	elseif arg1 == "GIE_RSCONNECT_RESULT" then
		HandleEventRoomFrame_RsconnectResult()
	elseif arg1 == "GE_WORLD_CHANGE" then
		--更新下载按钮状态
		if IsRoomFrameShown() then
			Log("RoomFrame: GE_WORLD_CHANGE: update download state:");
		end
	elseif "GIE_RSCONNECT_RENT_RESULT" == arg1 then
		local ge = GameEventQue:getCurEvent();
		EnterWorld_ExtraSet(ge.body.rentroomdata.detailreason)
		local result = ge.body.rentroomdata.result
        local detailreason = ge.body.rentroomdata.detailreason
        if getglobal("FriendChatFrame"):IsShown()   then
            return HandleShareRoomRSRentConnect(result, detailreason)
        end
		HandleRoomRSRentConnect(result, detailreason)
	elseif arg1 == "GE_LUA_CUSTOM_EVENT" then
		local ge 	= GameEventQue:getCurEvent();
		local key, data = G_GameEvent_Lua_Custom_Event_Decode(ge.body.luaCustomEventData.data)
		if key == "Act_Concert_St_Sefresh" then
			-- RoomRefreshActivityConcertBtn()
		end
	end
end

function RoomRefreshActivityConcertBtn()
	local objName = "RoomFrameBottomActivityConcert"
	local obj = getglobal(objName)
	if obj then
		obj:Hide()
		
		-- if ActivityConcertMgr and ActivityConcertMgr:CheckIsInActivityPeroid() then
		if ActivityConcertMgr:IsSwitch() and 1 == GetInst("MiNiMusicFestivalDataMgr"):GetXmyOpenStatus() then
			obj:Show()
			local textUi = getglobal(objName.."Text");
			if textUi then
				textUi:SetText(ActivityConcertMgr:GetTitleName())
			end
		end
	end
end

function RoomGetLabelIndexByGameLabel(filterType)
	for i,v in ipairs(mRoomFrameVar.leftBtns) do
		if filterType == v.id then
			return i
		end
	end

	--找不到不能返回0，返回8（其他类型）
	return 8
end

local MapTypeRoomsReport = {
	locked = false,
	dirty = false,

	reportInfos = {},
	gamelabel = 0,
	tick = 0,

	SetReportInfos = function(self, infos, gamelabel, requestid)
		self.reportInfos = infos or {}
		self.gamelabel = gamelabel or 1
		self.requestid = requestid
	end,

	Mark = function(self, index, shown)
		shown = shown or false
		if index and self.reportInfos[index] then
			local tmp = self.reportInfos[index]
			tmp["_shown_"] = tmp["_shown_"] or false
			if tmp["_shown_"] ~= shown then
				tmp["_shown_"] = shown
				if not self.locked and shown then
					self.dirty = true
				end
			end
		end
	end,

	Reset = function(self)
		self.reportInfos = {}
		self.gamelabel = 0
		self.locked = false
		self.dirty = false
	end,

	ResetTick = function(self)
		self.tick = 0
	end,

	Update = function(self)
		if self.dirty then
			self.tick = self.tick + 1
			if self.tick >= 3 then
				self:ResetTick()
				self:Report()
			end 
		end
	end,

	Report = function(self, force)
		if force or (not self.locked and self.dirty) then
			local isOk = false
			local rp = {
				cid = {},
				slot = {},
				standby3 = {}
			} 
			for index, value in ipairs(self.reportInfos) do
				if value["_shown_"] then
					isOk = true
					table.insert(rp.cid, value.cid)
				table.insert(rp.slot, value.slot)
					table.insert(rp.standby3, value.standby3)
				end
			end
	
			if isOk then
				if self.requestid and ReportMgr and ReportMgr.setExpInfo then
					ReportMgr:setExpInfo(nil,nil,self.requestid)
				end
				rp.cid = table.concat(rp.cid, ",")
				rp.slot = table.concat(rp.slot, ",")
				rp.standby3 = table.concat(rp.standby3, ",")
				standReportEvent("10", ReportGetFilterMutCID(self.gamelabel), "SmallMapCard", "view",rp)
				self.dirty = false
			end
		end
	end,

	
	ReportOne = function(self, index, oID, event)
		if index and self.reportInfos[index] then
			local rp = {
				cid = self.reportInfos[index].cid,
				slot = self.reportInfos[index].slot,
				standby3 = self.reportInfos[index].standby3,
			}
			if self.requestid and ReportMgr and ReportMgr.setExpInfo then
				ReportMgr:setExpInfo(nil,nil,self.requestid)
			end
			standReportEvent("10", ReportGetFilterMutCID(self.gamelabel), oID or "-", event or "-", rp)
		end
	end
}

function RoomFrame_OnUpdate()
	UpdateUI_WaterMark("RoomFrameWaterMarkFrameFont")
	MapTypeRoomsReport:Update()
end



function RoomFrame_OnShow()
	if getglobal("RoomFrame") and getglobal("RoomFrame"):IsReshow() then
		return;
	end
	RoomRefreshActivityConcertBtn()
	Log("RoomFrame_OnShow: Enter!");

	--地图下载上报设置地图参数
	MapDownloadReportMgr:SetFrameName(ReportDefine.frameDefine.RoomFrame)

	--
	local mapTypeRoomCache = AllRoomManager:GetMapTypeRoomCache(mRootName)
	mapTypeRoomCache:InstallCallBack(
		{
			ResponseCallBack = RefreshMapTypeRoomsUI
		}
	)

	--初始化房间列表
	InitRoomList();
	RoomFrameNetModeBtn_Init();			--初始化为网络联机	
	mAllRoomDropVar.CurIndex = 1;
	AccountManager:setNearbySwitch(true)

	AccountManager:needGetRoomPic(true);
	standReportNormalComp()

	if ClientMgr:isPC() or ClientMgr:getVersionParamInt("JoinRoomQREnabled", 0) == 0 then
		getglobal("RoomFrameScanBtn"):Hide();
	else
		getglobal("RoomFrameScanBtn"):Show();
	end

	--联机大厅曝光打点
	-- statisticsGameEventNew(650,"RoomFrame");
	getglobal("RoomFrameLeftFrameMyServer"):Show()
	getglobal("RoomFrameRoomNoRoom"):Hide()
	--23号广告位
	AdvertCommonHandle:ShowAdvert(23, ADVERT_PLAYTYPE.AUTOSHOW_DIALOG);

	getglobal("RoomFrameBackBtn"):Hide();
	getglobal("RoomFrameCloseBtn"):Show();

	--tsetgjd
	--游戏大厅的落地数据埋点
	RoomFrame_BuriedDatapoints();
	--数据埋点 1 联机大厅框架 联机大厅框架栏目 view
	if MiniStandInData then
		local data = MiniStandInData()
		data.sceneInfo.scene_id = "10"
		data.eventinfo.comp_id = "-"
		data.eventinfo.event_code = "view"
		if mIsOpenMapFrame then
			data.sceneInfo.card_id = "MINI_MUTIPLAYERLOBBY_SPECCON_1"
		else
			data.sceneInfo.card_id = "MINI_MUTIPLAYERLOBBY_CONTAINER_1"
		end
		ReportMgr:standReport(data)
		Log("~!~!~!~!~!~!~! 联机大厅框架 联机大厅框架栏目 view")
	end

	-- 加载云服个人权限
	threadpool:work(function ()
		CloudServerRoomAuthorityMgr:LoadCache()
		CSRoomNoticeMgr:LoadCache()
	end)

	threadpool:work(function ()
		--资源中心总库初始化
		ResourceCenterInitResLib()
	end)


	-- if not mIsOpenMapFrame and not IsLan then
	-- 	UpdateMapOrRoomPage() --InitRoomList中已调用，再次调用会造成大数据部门统计曝光数据污染
	-- end

	-- 检测新手引导推荐地图
	if  NewbieGuideManager and NewbieGuideManager:IsSwitch() and GetInst("mainDataMgr"):GetSwitch() == false then
		threadpool:delay(0.5, function()
			NewbieGuideManager:StartOnlineHallMapGuide()
		end)
	end
	
	-- if GetInst("NSearchPlatformService"):ABTestSwitch() then
		RoomFrame_HideOrShowSomeThing(true, "RoomFrameNSearchBtn")
		RoomFrame_HideOrShowSomeThing(false, "RoomFrameSearchBtn")
		standReportEvent("54","SEARCH_ENTRY_NEW","SearchEntryNew","view",{standby1 = 10})
	-- else
	-- 	RoomFrame_HideOrShowSomeThing(false, "RoomFrameNSearchBtn")
	-- 	RoomFrame_HideOrShowSomeThing(true, "RoomFrameSearchBtn")
	-- end
    if  "MiniWork" == EnterMainMenuInfo.EnterMainMenuBy then
	
	else
		if not EnterMainMenuInfo.LobbyOnline then
			EnterMainMenuInfo.EnterMainMenuBy = 'multiplayer'
		end
	end
end

function InitRoomList()
	SetCurRoomListType("RoomLobby");

	--左侧按钮切换到第一个: 热门
	local shouldJump = mRoomFrameVar.showLeftBtn;
	if shouldJump and shouldJump > 0 and shouldJump <= #(mRoomFrameVar.leftBtns) then
		RoomFrame_LeftBtnState(shouldJump);
		mRoomFrameVar.showLeftBtn = -1;
	else
		RoomFrame_LeftBtnState(1);
	end
	if EnterMainMenuInfo.ReturnGameHotMapClick then
		EnterMainMenuInfo.ReturnGameHotMapClick = nil;
		RoomFrameRoomLeftBtn_OnClick(1);  --初始化为热门地图
	else 
		RoomFrameRoomLeftBtn_OnClick(2)   --初始化为房间框
	end
end

function RoomFrame_Hide()
	--清理地图上报参数
	MapDownloadReportMgr:ClearFrameName();

	AccountManager:needGetRoomPic(false);
	RoomCloseCircleFlag()
	CurGetRoomNum = 0;
	getglobal("RoomFrameInfo"):Hide()
	getglobal("RoomFrameRightFrame"):Show()
	-- GetInst("UIManager"):Close("MiniWorksFrameSearch")
	if mComeBackInlineState == 1 then -- 这里如果点了 我的按钮进入（最近，收藏，云服）证明还在回流的状态
		mComeBackInlineState = 0
	end
end

function InFunc_HideRoomFrame()
	if  ReportMgr and ReportMgr.setExpInfo then
		ReportMgr:setExpInfo(nil,nil,"")
	end
	CloseRoomFrame();
	if not ClientCurGame:isInGame() then
		-- getglobal("MiniLobbyFrame"):Show();
		if not IsLobbyShown() then
			if IsUIStageEnable then
				-- 沙盒 UIStage 处理
				UIStageDirector:popupStage(true)
				if not UIStageDirector:getTopStage() then
					ShowMiniLobby()
				end
			else
				ShowMiniLobby() --mark by hfb for new minilobby
			end
		end
	end
	--快手推荐页相关需求
	GetInst("ExternalRecommendMgr"):ClearJumpRoomFrameInfo()
end
--关闭
function RoomFrameBackBtn_OnClick()
	standReportEvent("10","MINI_MUTIPLAYERLOBBY_TOP_1","Close","click")

	InFunc_HideRoomFrame()
	if WorksArchiveMsgCheck.isWorksInto then
		WorksArchiveMsgCheck.isWorksInto = false;
		GoBackInfoFrame();

		if getglobal("ArchiveInfoFrameEx"):IsShown() then
			GetInst("UIManager"):Close("ArchiveInfoFrameEx")
		end
		return;
	end

	local frameName = PEC_GetJumpToFrameName();
	if frameName ~= nil and frameName =="RoomFrame" then
		PEC_ShowHistoricalFrame();
	end

	JsBridge:PopFunction();
	statistics_9500_handler.upData()
end

--工坊主页面上关闭按钮和返回按钮切换
function RoomFrameShowBackBtn(bShow)
	if bShow then
		--显示返回按钮
		getglobal("RoomFrameBackBtn"):Show();
		getglobal("RoomFrameCloseBtn"):Hide();
	else
		--显示关闭按钮
		getglobal("RoomFrameBackBtn"):Hide();
		getglobal("RoomFrameCloseBtn"):Show();
	end
end

function RoomFrameBackBackBtn_OnClick()
	-- if getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):DelBtn_OnClick()
	-- end	
	RoomFrameShowBackBtn(false)
end

--版本信息
function UpdateRoomVersionTips()
	Log("UpdateRoomVersionTips:");
	local versionTips = getglobal("RoomFrameBottomVersionTxt");

	--if not IsLanRoom then
		local latestVersion 	= ClientMgr:clientVersionToStr(AccountManager:getRSLatestVersion());
		local curVersion 	= ClientMgr:clientVersionToStr(ClientMgr:clientVersion());
		local text = GetS(361) .. curVersion .. "\t\t" .. GetS(571) .. latestVersion;
		versionTips:SetText(text);
	--else
	--	versionTips:Clear();
	--end
end


--搜索地图回调:被调函数:RespSearchMapsByUin()
function RespRoomSearchMapsByUin()
	Log("RespRoomSearchMapsByUin");

	--LLDO:new
end

--testgjd
--联机大厅
local checkdelayroom = true
function RoomFrame_BuriedDatapoints()
	if checkdelayroom == true then
		local playeractive = AccountManager:get_active_days();
		local playermod = nil
		if playeractive >= 2 then
			playermod = 1
		else
			playermod = 0
		end
		-- statisticsGameEventNew(56102, AccountManager:getUin(),playermod)
		checkdelayroom = false;
		threadpool:work(function()
			threadpool:wait(300);
			checkdelayroom = true;
		end)
	end
end
----------------------------------------------------网络模式按钮--------------------------------------------------
function RoomFrameNetModeBtn_Init()
	Log("RoomFrameNetModeBtn_Init: Enter!");

	-- for i = 1, 2 do
	-- 	local btnName = "RoomFrameTopNetBtn" .. i;
	-- 	getglobal(btnName .. "Name"):SetText(GetS(mRoomFrame_NetNameIDs[i]));
	-- end

	local netChangeBtnTxt = getglobal("RoomFrameTopNetChangeBtnName");	--LLTODO:new
	netChangeBtnTxt:Show()

	if mIsLanRoom then
		--开关状态:关
		TemplateSwitchBtn_SetState("RoomFrameTopNetChangeBtn", 2);
		netChangeBtnTxt:SetText(GetS(mRoomFrame_NetNameIDs[2]));
	else
		--开关状态:开
		TemplateSwitchBtn_SetState("RoomFrameTopNetChangeBtn", 1);
		netChangeBtnTxt:SetText(GetS(mRoomFrame_NetNameIDs[1]));
	end
end

function RoomFrameTopNetSwitchBtn_OnClick()
	-- TemplateSwitchBtn_OnClick(this:GetName());
	ShowNoRoomFrame(false)
	RoomFrameTopNetChangeBtn_OnClick();
end

--局域网模式隐藏"热门地图"按钮and"服务器勾选”按钮
function LanModeHideSomeFrame()
	Log("LanModeHideSomeFrame:");
	local hotMapBtn = getglobal("RoomFrameOpenmapBtn");

	if mIsLanRoom then
		hotMapBtn:Hide();
	else
		hotMapBtn:Show();
	end
end

--网络切换按钮
function RoomFrameTopNetChangeBtn_OnClick()
	Log("RoomFrameTopNetChangeBtn_OnClick:");
	local id = 1;

	if mIsLanRoom then
		--局域网 --切换到--> 外网
		id = 1;
	else
		id = 2;
	end
	standReportEvent("10","MINI_MUTIPLAYERLOBBY_TOP_1","WiFiSwift","click",{button_state= tostring(id-1)})
	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3);
		return;
	end

	if AccountManager:loginRoomServer(IsLan) then
		RoomshowCircleFlag(2)
		RoomFrame_RefreshNetSwitch(id);
	end
end

function RoomFrame_RefreshNetSwitch(id)
	id = id or 1
	--2. 登陆房间服务器
	if id == 1 then
		--网络联机
		IsLan = false;
	else
		--热点联机
		IsLan = true;

		--关闭地图框
		RoomFrameRoomLeftBtn_OnClick(2);

		--切换到热门.
		RoomFrame_LeftBtnState(1);
	end
	
	mIsLanRoom = IsLan;

	--按钮状态
	RoomFrameNetModeBtn_Init()

	--显示或隐藏服务器勾选按钮
	LanModeHideSomeFrame();

	--显示地图式房间列表还是之前的房间列表 AB开关
	if not IsLan then
		getglobal(mRoomRoomBoxUI):Hide()
		getglobal(mRoomMapBoxUI):Show()
	else
		getglobal(mRoomRoomBoxUI):Show()
		getglobal(mRoomMapBoxUI):Hide()
	end

end


--热点联机, 使筛选按钮不可用
function LanRoomDisableTypeBtn(IsLan)
	Log("LanRoomDisableTypeBtn:");

	local openMapFrameBtn = getglobal("RoomFrameRoomLeftBtn");
	local openMapFrameBtnBkg = getglobal("RoomFrameRoomLeftBtnBkg");
	local hotMapBtn = getglobal("RoomFrameOpenmapBtn");

	if IsLan then
		openMapFrameBtn:Disable();
		openMapFrameBtnBkg:SetGray(true);

		hotMapBtn:Disable();
	else
		openMapFrameBtn:Enable();
		openMapFrameBtnBkg:SetGray(false);

		hotMapBtn:Enable();
	end

	for i = 1, #(mRoomFrameVar.leftBtns) do
		local leftFrame = leftframebtnFirstName;
		local btnName = leftFrame .. "Btn" .. i;
		if not HasUIFrame(btnName) then
			break;
		end

		local btnObj = getglobal(btnName);
		local normal = getglobal(btnName .. "Normal");
		local checked = getglobal(btnName .. "Checked");

		if IsLan then
			btnObj:Disable();
			normal:SetGray(true);
			checked:SetGray(true);
		else
			btnObj:Enable();
			normal:SetGray(false);
			checked:SetGray(false);
		end
	end
end

-----------------------------------------------------------------------------------------------------------

--被调函数: RequestLoginRoomServer();
function RoomFrameRequestLoginRoomServer(params)
	Log("RoomFrameRequestLoginRoomServer:");
	local id = 1;

	-- if mIsLanRoom then
	-- 	id = 2;
	-- else
	-- 	id = 1;
	-- end
	--初始化始终是网络联机
	RoomFrame_RefreshNetSwitch(id);
	
	local genkey = nil
	if params then
		local prefix = GetInst("RoomService").EVT_GEN_PREFIX_JUMP_ROOM_WITH_PARAM
		local gid = ""
        genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix(prefix)
		GetInst("GameHallCacheManager"):SetData(prefix, gid, params)
	end

	if AccountManager:loginRoomServer(false, 0, genkey) then
		RoomshowCircleFlag(1)
	end
end

--底部刷新按钮
function RoomFrameBottomFlashBtn_OnClick()
	Log("RoomFrameBottomFlashBtn_OnClick:");
	--数据埋点 1 联机综合内容 刷新 click
	if mRoomFrameVar.CurLeftBtnIndex and mRoomFrameVar.CurLeftBtnIndex > 0 and mRoomFrameVar.CurLeftBtnIndex < 9 then
		standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+mRoomFrameVar.CurLeftBtnIndex], "Refresh", "click")
	else
		standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+1], "Refresh", "click")
	end
	statistics_9500_handler.upData()
	if t_RoomCommonConfig.flash_click then
		ShowGameTips(GetS(31028))
		return
	end

	UpdateMapOrRoomPage();
	t_RoomCommonConfig.flash_click = true


	threadpool:work(function()
		threadpool:wait(1)
		t_RoomCommonConfig.flash_click = false
	end)
end

--2. 左侧按钮布局.------------------------------------------------------------------------------------------------
function RoomFrame_LeftBtnLayout()
	Log("NewStoreFrame_LeftBtnLayout: Enter!");
	
	RoomLeftBtnSliderListItems = RoomLeftBtnSliderListItems or {}
	if next(RoomLeftBtnSliderListItems) == nil then 
		for index, _ in ipairs(mRoomFrameVar.leftBtns) do
			local item = RoomLeftBtnSliderListItems[index]
			if not item then 
				item = CreateNewSliderListItems(index)
				RoomLeftBtnSliderListItems[index]=item
			end 
			
			if item then 
				item:SetClientID(index)
			end 
		end
	end 

	local leftFrame = leftframebtnFirstName;
	local planeUI = leftFrame .. "Plane";
	local y = mRoomFrameVar.offsetTop;
	TemplateTabBtn_Init("RoomFrameLeftFrameBoxBtn", mRoomFrameVar.leftBtns, planeUI, "topleft", 0);	
	--首次打开, 切换到第一个按钮
	RoomFrame_LeftBtnState(1,true);
end

--创建新的item并置入记录下来
function CreateNewSliderListItems(index)
	local templateName = "RoomFrameLeftBtnTemplate"
	local parentName = "RoomFrameLeftFrameBoxPlane"
	local itemname = "RoomFrameLeftFrameBoxBtn" .. index
	local item = UIFrameMgr:CreateFrameByTemplate("Button", itemname, templateName, parentName);
	
	return item
end

--3. 左侧按钮状态
function RoomFrame_LeftBtnState(id,firstLoad)
	Log("RoomFrame_LeftBtnState: id = " .. id);

	--1. 切换按钮状态
	for i = 1, #(mRoomFrameVar.leftBtns) do
		local btnName = leftframebtnFirstName .. "Btn" .. i;
		if not HasUIFrame(btnName) then
			break;
		end

		local name = getglobal(btnName .. "Name");
		local normal = getglobal(btnName .. "Normal");
		local checked = getglobal(btnName .. "Checked");
		local icon = getglobal(btnName .. "Icon");

		if id == i then
			--1. 记录前一次的索引
			mRoomFrameVar.LastBtnIndex = mRoomFrameVar.CurLeftBtnIndex

			--1. 记录当前索引
			mRoomFrameVar.CurLeftBtnIndex = id;
			AllRoomManager.CurLeftBtnIndex = id
			--2. 按钮状态
			normal:Hide();
			checked:Show();
			name:SetTextColor(255, 153, 63);
			-- name:SetBaseColorByState(true);
			icon:SetTexUV(mRoomFrameVar.leftBtns[i].iconName);

			--3. 房间筛选类型
			mFilterType = mRoomFrameVar.leftBtns[i].id;

			--数据埋点 1 联机综合内容 综合内容栏目 view
			
			if MiniStandInData and not firstLoad then
				if mRoomFrameVar.CurLeftBtnIndex and mRoomFrameVar.CurLeftBtnIndex > 0 and mRoomFrameVar.CurLeftBtnIndex < 9 then
					standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+mRoomFrameVar.CurLeftBtnIndex], "-", "view")
				else
					standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+1], "-", "view")
				end
				Log("~!~!~!~!~!~!~! 联机综合内容 综合内容栏目 view")
			end
		else
			normal:Show();
			checked:Hide();
			name:SetTextColor(158, 225, 231);
			-- name:SetBaseColorByState(false);
			icon:SetTexUV(mRoomFrameVar.leftBtns[i].iconPushedName);
		end
		name:SetText(GetS(mRoomFrameVar.leftBtns[i].nameId))
	end

	getglobal("RoomFrameRightFrame"):Show()
	-- GetInst("UIManager"):Close("MiniWorksFrameSearch")
end

--左侧筛选按钮点击
function RoomFrameLeftBtn_OnClick(id)
	Log("RoomFrameLeftBtn_OnClick: Enter!");
	local comName = 
	{
		"AllContent",
		"AdventureContent",
		"CreativeContent",
		"BattleContent",
		"ParkourContent",
		"PuzzleContent",
		"ElectronicCoentent",
		"OtherContent",
	}
	
	if id then
		id = id;
	else
		id = this:GetClientID();
	end
	if id >= 1 and id <=8 then
		standReportEvent("10", "MINI_MUTIPLAYERLOBBY_CONTAINER_1", comName[id], "click")
	end
	statistics_9500_handler.upData()
	
	if id == mRoomFrameVar.CurLeftBtnIndex then
		--已经在这个页面.
		return;
	end

	SetCurRoomListType("RoomLobby");

	--切换
	RoomFrame_LeftBtnState(id);

	UpdateMapOrRoomPage();

	--这里埋点的保存的索引减掉1个
	EnterSurviveGameInfo.StatisticsData.MultiGameLabel = id-1 -- 标签（0=综合、1=冒险、2=创造、3=对战、4=跑酷、5=解密、6=电路、7=其他、8=最近、9=收藏、10=迷你云服）
	--各个页面曝光打点
	local openmapBtnChecked = getglobal("RoomFrameOpenmapBtnChecked");
	local viewType = 0; --界面类型（0=主界面、1=热门地图、2=服务器房间）
	if openmapBtnChecked:IsShown() then
		viewType = 3
	elseif openmapBtnChecked:IsShown() then
		viewType = 1
	end
	local language = get_game_lang();
	-- statisticsGameEventNew(9500, id - 1, viewType, language);

end

--拉取地图或房间---------------------------------------------------------------------------------
function UpdateMapOrRoomPage(sType)
	Log("UpdateMapOrRoomPage:");

	if mIsOpenMapFrame then
		--地图页面, 拉取地图和房间
		ReqRoomFilter(0);

		MapDownloadReportMgr:SetRoomDownloadType(ReportDefine.roomDefine.Popular)
	else
		--拉取房间
		if not IsLan then
			RoomshowCircleFlag(3)
			threadpool:work(function()
				AllRoomManager:GetMapTypeRoomCache(mRootName):RequestMapRooms(false, mFilterType)
			end)
		else
			ReqRoomByOwId();
		end

		MapDownloadReportMgr:SetRoomDownloadSubType(mFilterType)
	end
end

--4. 展开/关闭地图框
function RoomFrameRoomLeftBtn_OnClick(id)
	Log("RoomFrameRoomLeftBtn_OnClick: Enter!");
	statistics_9500_handler.upData()
	local isClick = false
	if id then
		mIsOpenMapFrame = id == 1
	else
		mIsOpenMapFrame = not mIsOpenMapFrame
		isClick = true
	end

	--数据埋点 1 联机大厅框架 热门地图 view click
	if MiniStandInData then
		local state = 0
		if mIsOpenMapFrame then 
			state = 0
		else
			state = 1
		end
		local eventCode = "view"
		if isClick then
			eventCode = "click"
		end
		
		local data = MiniStandInData()
		data.sceneInfo.scene_id = "10"
		data.sceneInfo.card_id = "MINI_MUTIPLAYERLOBBY_CONTAINER_1"
		data.eventinfo.comp_id = "HotMap"
		data.eventinfo.event_code = eventCode
		data.eventinfo.button_state = tostring(state)
		ReportMgr:standReport(data)
		Log("~!~!~!~!~!~!~! 联机大厅框架 热门地图 view click state:"..data.eventinfo.button_state)
	end
	
	if mIsOpenMapFrame then
		--从房间框-->(打开) --> 地图框
		-- getglobal("RoomFrameRoom"):Hide();
		getglobal("RoomFrameOpenmapBtnChecked"):Hide();
		-- getglobal("RoomFrameOpenmapBtnText"):SetTextColor(76, 76, 76);

		MapDownloadReportMgr:SetRoomDownloadType(ReportDefine.roomDefine.Popular);

		--拉取地图列表
		UpdateMapOrRoomPage();
		EnterMainMenuInfo.HotMapClick = true;
	else
		-- getglobal("RoomFrameRoom"):Show();
		getglobal("RoomFrameOpenmapBtnChecked"):Show();
		-- getglobal("RoomFrameOpenmapBtnText"):SetTextColor(76, 76, 76);

		--地图下载上报设置
		if CurRoomListType == "Collect" then
			MapDownloadReportMgr:SetRoomDownloadType(ReportDefine.roomDefine.Collection);

		elseif CurRoomListType == "RoomLobby" then
			MapDownloadReportMgr:SetRoomDownloadType(ReportDefine.roomDefine.DownLoad);
			MapDownloadReportMgr:SetRoomDownloadSubType(mFilterType);
		end

		UpdateMapOrRoomPage();
		EnterMainMenuInfo.HotMapClick = nil;
	end
end

--5. 房间列表
function RoomBox_Layout()
	Log("RoomBox_Layout:");
	local maxRoomNum = 20;
	local roomBoxUI = mRoomRoomBoxUI;
	local planeUI = roomBoxUI .. "Plane";
	local height = 140;
	local topOffset = 0;
	local y = topOffset;
	local bIsShowNoRoomFrame = true;

	for i = 1, maxRoomNum do
		local itemName = roomBoxUI .. "Btn" .. i;

		if not HasUIFrame(itemName) then
			break;
		end

		local item = getglobal(itemName);

		if item:IsShown() then
			local row = math.floor((i + 1) / 2);
			y = (row - 1) * height;

			if (i % 2) == 1 then
				--左边
				item:SetPoint("topright", planeUI, "top", -5, y);
			else
				--右边
				item:SetPoint("topleft", planeUI, "top", 5, y);
			end

			--有房间
			bIsShowNoRoomFrame = false;
		else
			break;
		end
	end

	--无房间提示框
	ShowNoRoomFrame(bIsShowNoRoomFrame);

	--调整滑动框
	local bottomOffset = 60;
	local plane = getglobal(planeUI);
	local planeWidth = plane:GetWidth();
	local boxHeight = getglobal(roomBoxUI):GetRealHeight();
	local scaleY = UIFrameMgr:GetScreenScaleY();
	boxHeight = boxHeight / scaleY;
	y = y + height;
	if y < boxHeight then
		y = boxHeight;
	else
		--加上刷新按钮的高度
		y = y + bottomOffset;
	end
	print("room:boxHeight = ", boxHeight);
	plane:SetSize(planeWidth, y);
end

--地租组内条目列表
--显示或隐藏控件
function RoomFrame_HideOrShowSomeThing(bIsShow, UIName)
	local uiobj = getglobal(UIName)
	if uiobj then
		if bIsShow then
			uiobj:Show();
		else
			uiobj:Hide();
		end
	end
end


--刷新房间
function RoomFrameListFreshBtn_OnClick()
	Log("RoomFrameListFreshBtn_OnClick:");
	ReqRoomByOwId();
end

--拉取房间列表
function ReqRoomByOwId(owid,bFromHotMap, circleFlag)
	Log("ReqRoomByOwId:");
	--print(debug.traceback())
	AccountManager:clearRoomList();
	AccountManager:clearNearbyRoomList();
	if not owid then
		CancelAllDownloadingThumbnails();
	end

	--1. 地图owid
	if owid then
		owid = owid;
	else
		owid = ""
	end
	
	--点击快速进入
	if  bFromHotMap  then
		-- 快手等外部引流到联机大厅导致的进入地图的消费需要特殊处理
		local external_state,external_t_scheme,external_map = GetInst("ExternalRecommendMgr"):GetJumpRoomFrameInfo()
		if external_state and owid then--此时的联机大厅页面是从跳转页跳过来的
			--当前打算进入的地图和推荐的地图是同一个地图，且是从推荐页进入的联机大厅
			if external_t_scheme and tostring(external_t_scheme.zb_wid) == tostring(owid) then
				--进游戏之前的环境设置，表明这是从快手推荐页进入的游戏
				GetInst("ExternalRecommendMgr"):SetCurZBInfo(external_map.owid, external_t_scheme, external_map.share_version)
			end
		end
		-- 快速进入目前取不到房间类型，房间id
		local connectmode = 2

		local addTb = {
			standby1 = "1"..tostring(connectmode),
			cid = tostring(owid)
		}
		local cardid = reportCardName[(mIsOpenMapFrame and 8 or 0)+mRoomFrameVar.CurLeftBtnIndex]
		InsertStandReportGameJoinParamArg({sceneid="10",cardid=cardid,compid="QuickJoin",standby1 = addTb.standby1})
		GetInst("ReportGameDataManager"):NewGameJoinParam("10",cardid,"QuickJoin")
		standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+mRoomFrameVar.CurLeftBtnIndex], "QuickJoin", "click",addTb)
	end

	--Log("ReqRoomByOwId_owid = " .. owid);
	--2. 服务器还是玩家
	local host_type = mAllRoomDropVar.Btns[mAllRoomDropVar.CurIndex].type or 0;	--LLDO:加上host_type参数.

	-- statisticsGameEvent(605, "%d", mFilterType);

	if not AccountManager:requestRoomList(mFilterType, 0, owid, host_type) then
		ShowGameTips(GetS(146), 3);
		return false;
	else
		AccountManager:clearRoomList();
		AccountManager:clearNearbyRoomList();
		CurGetRoomNum = 0;
		if circleFlag ~= false then
			RoomshowCircleFlag(circleFlag)
		end
		return true;
	end
end

function GetRoomCurChooseOwId()
	return "";
end

--是否显示"无房间框"
function ShowNoRoomFrame(bIsShow, NoRoomFrameUI, FlashBtnUI)
	--Log("ShowNoRoomFrame:");
	NoRoomFrameUI = NoRoomFrameUI and NoRoomFrameUI or "RoomFrameRoomNoRoom"
	FlashBtnUI = FlashBtnUI and FlashBtnUI or "RoomRoomBoxFreshBtn"
	local frame = getglobal(NoRoomFrameUI);

	if getglobal(mRoomRoomBoxUI):IsShown() then
		if bIsShow then
			if not frame:IsShown() then
				frame:Show();
			end
	
			--刷新按钮
			if FlashBtnUI then
				local flashBtn = getglobal(FlashBtnUI);
	
				if flashBtn:IsShown() then
					flashBtn:Hide();
				end
			end
		else
			if frame:IsShown() then
				frame:Hide();
			end
	
			if FlashBtnUI then
				local flashBtn = getglobal(FlashBtnUI);
	
				if not flashBtn:IsShown() then
					--flashBtn:Show();
				end
			end
		end
		Log("~!~!~!~!~!~!~! 联机综合内容 刷新 view")
		if mRoomFrameVar.CurLeftBtnIndex and mRoomFrameVar.CurLeftBtnIndex > 0 and mRoomFrameVar.CurLeftBtnIndex < 9 then
			standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+mRoomFrameVar.CurLeftBtnIndex], "Refresh", "view")
		else
			standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+1], "Refresh", "view")
		end
	end		
end

--是否显示"无房间框"
function ShowNoMapTypeRoomFrame(bIsShow, NoRoomFrameUI, FlashBtnUI)
	--Log("ShowNoRoomFrame:");
	NoRoomFrameUI = NoRoomFrameUI and NoRoomFrameUI or "RoomFrameRoomNoRoom"
	FlashBtnUI = FlashBtnUI and FlashBtnUI or "RoomRoomBoxFreshBtn"
	local frame = getglobal(NoRoomFrameUI);

	if getglobal(mRoomMapBoxUI):IsShown() then
		bIsShow = bIsShow 
	
		if bIsShow then
			if not frame:IsShown() then
				frame:Show();
			end
	
			--刷新按钮
			if FlashBtnUI then
				local flashBtn = getglobal(FlashBtnUI);
	
				if flashBtn:IsShown() then
					flashBtn:Hide();
				end
			end
		else
			if frame:IsShown() then
				frame:Hide();
			end
	
			if FlashBtnUI then
				local flashBtn = getglobal(FlashBtnUI);
	
				if not flashBtn:IsShown() then
					flashBtn:Hide();
				end
			end
		end
		Log("~!~!~!~!~!~!~! 联机综合内容 刷新 view")
		if mRoomFrameVar.CurLeftBtnIndex and mRoomFrameVar.CurLeftBtnIndex > 0 and mRoomFrameVar.CurLeftBtnIndex < 9 then
			standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+mRoomFrameVar.CurLeftBtnIndex], "Refresh", "view")
		else
			standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+1], "Refresh", "view")
		end		
	end
end


--拉取地图列表
function ReqRoomFilter(flushPos)
	Log("ReqRoomFilter: FilterType = " .. mFilterType);
	local label = mFilterType;
	local host_type = mAllRoomDropVar.Btns[mAllRoomDropVar.CurIndex].type or 0;

	CancelAllDownloadingThumbnails();

	AllRoomManager:GetMapTypeRoomCache(mRootName):RequestHotMaps(false, label, flushPos, host_type)
end

--拉取地图回调
function RespHotRoomList(ret, flushPos)
	--废弃 相关请求使用lua，不再调用c++
end

--收藏房间
function RoomBtnCollect_OnClick(id)
	local cid = 0 -- by fym
	-- 更新普通联机房的 收藏状态
	if id then
		id = id;
	else
		id = this:GetParentFrame():GetClientID();
	end

	if id > 0 then
		local roomDesc = AccountManager:getIthRoom(id-1);
		local AccountData = AccountManager:getAccountData();

		if AccountData ~= nil and roomDesc ~= nil then

			-- by fym
			if roomDesc then 		
				if roomDesc.fromowid and roomDesc.fromowid > 0 then 			
					cid = tostring(roomDesc.fromowid) 		
				elseif roomDesc.owid and roomDesc.owid > 0 then 			
					cid = tostring(roomDesc.owid) 		
				elseif roomDesc.wid and roomDesc.wid > 0 then 			
					cid = tostring(roomDesc.wid) 		
				elseif roomDesc.map_type then 			
					cid = roomDesc.map_type 		
				end 	
			end

			local uiFrame = getglobal(mRoomRoomBoxUI)
			local cell = nil
			local collocBtn = nil
			local collectIcon = nil
			local len = #(AllRoomManager.RoomsCache or {})
			for i=1, len do
				local roomCache = AllRoomManager.RoomsCache[i]
				if roomCache and roomCache.type == AllRoomManager.RoomType.Normal and roomCache.roomid == id then
					if uiFrame then
						cell = uiFrame:cellAtIndex(i-1)                
						break
					end
				end
			end

			if cell then
				local cellname = cell:GetName()
				collocBtn = getglobal(cellname.."Collect")
				collectIcon = getglobal(cellname.."CollectIcon")
			end

			if not SwitchNormalRoomCollectStatus(roomDesc.owneruin) then
				--已经收藏->取消收藏
				-- AccountData:delCollectUin(roomDesc.owneruin);

				if collocBtn and collectIcon then
					collocBtn:Hide()
					collectIcon:SetGray(true)
				end

				ShowGameTips(GetS(498), 3);
			else
				-- AccountData:addCollectUin(roomDesc.owneruin);
				-- statisticsGameEvent(604, '%d', roomDesc.gamelabel);

				if collocBtn and collectIcon then
					collocBtn:Show()
					collectIcon:SetGray(false)
				end

				ShowGameTips(GetS(499), 3);
			end
		end
	end

	-- 普通联机房间简介-点击收藏按钮上报 by fym
	standReportEvent("11", "MINI_MLMAP_INTRO_1", "MapCollect", "click", {cid = tostring(cid)})

end

function SwitchNormalRoomCollectStatus(roomOwid, handSwitch)
	local AccountData = AccountManager:getAccountData();

	if AccountData then
		if handSwitch == nil then
			handSwitch = AccountData:isCollectUin(roomOwid)
		else
			handSwitch = not handSwitch
		end
		if handSwitch then
			AccountData:delCollectUin(roomOwid);
		else
			AccountData:addCollectUin(roomOwid);
		end
		return AccountData:isCollectUin(roomOwid)
	end

	return false
end

--进入房间按钮:
function RoomFrameEnterRoomBtn_OnClick()
	Log("RoomFrameEnterRoomBtn_OnClick:");
	local teamupSer = GetInst("TeamupService")
	if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
		ShowGameTips(GetS(26045))
		return
	end
	local roomDesc
	local roomCache = AllRoomManager.RoomsCache[this:GetParentFrame():GetClientUserData(0)]
	local cid = "0"
	if roomCache and next(roomCache) ~= nil then
		if roomCache.type == AllRoomManager.RoomType.Normal then
			roomDesc = AccountManager:getIthRoom(roomCache.roomid-1);
		elseif roomCache.type == AllRoomManager.RoomType.CloudServer then
			roomDesc = AllRoomManager.CSRoomsList[roomCache.roomid]
		end
		if mComeBackInlineState ~= 0 and roomDesc then -- 回流
			StatisticComeBackFastIn(roomCache.type,roomDesc,9)
		end
		if MiniStandInData and roomDesc then			
			if roomDesc and roomDesc.fromowid and roomDesc.fromowid > 0 then
				cid = tostring(roomDesc.fromowid)
			elseif roomDesc and roomDesc.map_type then
				cid = roomDesc.map_type
			elseif roomDesc and roomDesc.owid and roomDesc.owid > 0 then
				cid = tostring(roomDesc.owid)
			elseif roomDesc and roomDesc.wid and roomDesc.wid > 0 then
				cid = tostring(roomDesc.wid)
			end
			
			local roomType = "1"
			local uniqueCode = nil
			if roomDesc.isServer then
				roomType = "1"
			elseif roomDesc.maxplayers and roomDesc.maxplayers > 6 then
				roomType = "4"
			elseif roomDesc.extraData then
				local t_extra = JSON:decode(roomDesc.extraData)
				if t_extra then
					uniqueCode = t_extra.uniqueCode
					if t_extra.platform then
						-- PC服务器
						if t_extra.platform == 1 then
							roomType = "3"
						-- 手机服务器
						else
							roomType = "2"
						end
					end
				end
			end
			local roomName = ""
			if roomDesc.owneruin then
				roomName =  uniqueCode or getShortUin(roomDesc.owneruin);
			elseif roomDesc._k_ then
				roomName = roomDesc._k_
			end
			local cardid = reportCardName[(mIsOpenMapFrame and 8 or 0)+mRoomFrameVar.CurLeftBtnIndex]
			local addTb = {
				sceneid="10",
				cardid=cardid,
				compid="JoinButton",
				cid = cid,
				standby1 = "1"..roomType,
				standby2 = roomName
			}
			if this:GetParentFrame():GetClientUserData(0) then
				addTb.slot = tostring(this:GetParentFrame():GetClientUserData(0))
			else
				addTb.slot = "1"
			end
			InsertStandReportGameJoinParamArg(addTb)
			GetInst("ReportGameDataManager"):NewGameJoinParam("10",cardid,"JoinButton")
			GetInst("ReportGameDataManager"):SetCId(cid)
			GetInst("ReportGameDataManager"):SetGameJoinParamStandby3(roomName)
			GetInst("ReportGameDataManager"):SetJoinSlot(addTb.slot)

			if mIsOpenMapFrame then
				standReportEvent("10","MINI_MUTIPLAYERLOBBY_SPECCON_1", "JoinButton", "click",addTb)
			else
				if mRoomFrameVar.CurLeftBtnIndex and mRoomFrameVar.CurLeftBtnIndex > 0 and mRoomFrameVar.CurLeftBtnIndex < 9 then
					standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+mRoomFrameVar.CurLeftBtnIndex], "JoinButton", "click",addTb)
				else
					standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+1], "JoinButton", "click",addTb)
				end
			end
		end
	end
	-- 快手等外部引流到联机大厅导致的进入地图的消费需要特殊处理
	local external_state,external_t_scheme,external_map = GetInst("ExternalRecommendMgr"):GetJumpRoomFrameInfo()
	if external_state then--此时的联机大厅页面是从跳转页跳过来的
		--当前打算进入的地图和推荐的地图是同一个地图，且是从推荐页进入的联机大厅
		if external_t_scheme and tostring(external_t_scheme.zb_wid) == tostring(cid) then
			--进游戏之前的环境设置，表明这是从快手推荐页进入的游戏
			GetInst("ExternalRecommendMgr"):SetCurZBInfo(external_map.owid, external_t_scheme, external_map.share_version)
		end
	end
	EnterMainMenuInfo.EnterMainMenuBy = 'multiplayer'
	EnterMainMenuInfo.RoomCurLabel = mRoomFrameVar.CurLeftBtnIndex;
	AllRoomManager:EnterRoom(this:GetParentFrame():GetClientUserData(0), false)
end

function RoomFrameViolationBtn_OnClick()
	pcall(function()
		AllRoomManager:ViolationBtn_OnClick(this:GetParentFrame():GetClientUserData(0), this:GetParentFrame():GetParentFrame())
	end)
end

function RoomFrameMapViolationBtn_OnClick()
	-- todo
end

function JoinRoom()
	Log("JoinRoom:");
	if CurChooseRoomIdx ~= 0 then
		if not mIsLanRoom then
			if CheckUinLogin() == false then
				return;
			end
		end

		local roomDesc = AccountManager:getIthRoom(CurChooseRoomIdx-1);
		if roomDesc ~= nil and roomDesc.password and roomDesc.password ~= "" then
			Log("111:");
			--要密码
			local record = ""
			if Room_Data.password_record[roomDesc.owneruin] then
				record = Room_Data.password_record[roomDesc.owneruin]
			end
			local password = roomDesc.password
			if record == password then
				--已经进入过的房间, 不用再次输出密码, 密码保存在：Room_Data.password_record,中.
				Log("222:");

				LinkRoomStartGame(Room_Data.password_record[roomDesc.owneruin]);
			else
				--首次进入需要输入密码, 然后保存下来了.
				Log("333:");
				getglobal("LinkRoomPassWordFrame"):Show();
			end
		else
			--房间没有设置密码
			LinkRoomStartGame("");
		end
	end

	Lite:RestoreFunctionsInOnlineRoom();
end

--LLTODO: 房间使用数据流量提示   type 1开房间 2进房间
function RoomUseDataTips(type)
	MessageBox(7, GetS(21));
	if type == 1 then
		getglobal("MessageBoxFrame"):SetClientString( "开房间使用流量" );
	elseif type == 2 then
		getglobal("MessageBoxFrame"):SetClientString( "进房间使用流量" );
	end
end

--快速联机时AllRoomManager:EnterRoom有分支判断，可能进入云服或非云服,非云服的埋点在LinkRoomStartGame，云服RespRoomCloudServerEnterRoom
--不好直接在AllRoomManager:EnterRoom埋点，故分分别埋点
function standReportLinkRoom(roomDesc)
	-- stanby1：由两位数组成  --新增快速联机的埋点
	-- stanby1_1：十分位-1：公开房间；2-好友协作
	-- stanby1_2：个位-1：迷你云服；2：手机服务器（手机端）；3：PC服务器（PC端） 4：PC大房间（房间人数大于6）
	local stanby1_1, stanby1_2 = "", ""
	local cid = 0
	if roomDesc then--用来计算埋点需要的数据信息		
		if roomDesc.fromowid and roomDesc.fromowid > 0 then 			
			cid = tostring(roomDesc.fromowid) 		
		elseif roomDesc.owid and roomDesc.owid > 0 then 			
			cid = tostring(roomDesc.owid) 		
		elseif roomDesc.wid and roomDesc.wid > 0 then 			
			cid = tostring(roomDesc.wid) 		
		elseif roomDesc.map_type then 			
			cid = roomDesc.map_type 		
		end

		-- 房间模式 connect_mode = 0:公开房间 , 1:协作模式
		if roomDesc.connect_mode then			
			stanby1_1 = roomDesc.connect_mode + 1
		end

		--人数>6: PC大房间
		if roomDesc.maxplayers and roomDesc.maxplayers > 6 then
			stanby1_2 = 4
		elseif roomDesc.extraData then
			local t_extra = JSON:decode(roomDesc.extraData)
			if t_extra then
				if t_extra.platform then
					-- PC服务器
					if t_extra.platform == 1 then
						stanby1_2 = 3
					-- 手机服务器
					else
						stanby1_2 = 2
					end
				end
			end
		end
	end
	-- 快速联机埋点上报。参考RoomFrameInfoStartGameBtn_OnClick
	EnterMapReport = {		
		cid = tostring(cid),
		standby1 = tostring(stanby1_1)..stanby1_2,
		slot = CurChooseRoomIdx,
	}
	
	local map_type=roomDesc.map_type
	InsertStandReportGameJoinParamArg({
		standby1 = EnterMapReport.standby1,slot = CurChooseRoomIdx})
	
	GetInst("ReportGameDataManager"):SetCId(cid)
	GetInst("ReportGameDataManager"):SetJoinSlot(CurChooseRoomIdx)
end
function LinkRoomStartGame(password)
	Log("LinkRoomStartGame:");
	if EnterHomeLandInfo and EnterHomeLandInfo.step == HomeLandInterativeStep.GET_ROOM_DESC then
		LinkHomeLandRoomStartGame(password)
		return --家园联机
	end

	local fastenterBtn = getglobal("RoomFrameBottomFastEnterBtn")
	if CurChooseRoomIdx ~= 0 then
		Log("111:");
		local curVersion = ClientMgr:clientVersion();
		local roomDesc = AccountManager:getIthRoom(CurChooseRoomIdx-1);
		if roomDesc == nil then return end
		
		local roomType = roomDesc.isServer and 2 or 3
		statistics_9502_handler.OnEnterRoomStatistics(roomDesc.owneruin,AllRoomManager.CurrentChooseRoomIdx,roomType,roomDesc.map_type,roomDesc.gamelabel,getShortUin(roomDesc.owneruin))

		if roomDesc.isnearby > 100  and roomDesc.password ~= "" and roomDesc.password ~= password then
			ShowGameTips(GetS(567), 3);
			statistics_9502_handler.OnEnterRoomResultStatistics(false,567)
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
				statistics_9502_handler.OnEnterRoomResultStatistics(false,572)
				return;
			end
		end

		StatisticsTools:joinRoom(mIsLanRoom, roomDesc.gamelabel);

		--保存密码
		Room_Data.cur_password = password;

		--可否被追踪
		local cantrace = ClientMgr:getGameData("cantrace")

		RoomshowCircleFlag(2)
		if AccountManager:requestConnectWorld(roomDesc.owneruin, password, roomDesc.regionIp, roomDesc.maxplayers, cantrace) then
			AllRoomManager:AddReqConnectRSRoom(roomDesc, roomDesc.owneruin)
			RoomshowCircleFlag()
			--[[设置打赏状态]]
			MapRewardClass:SetMapsReward(roomDesc.map_type)

			EnterRoomType = roomDesc.gametype;
			LoginRoomClientIp = roomDesc.regionIp;

			WWW_ma_multigame();
			--Log( "gamelabel=" .. roomDesc.gamelabel )
			ns_ma.ma_play_map_set_enter( { where="join_room1", fromowid=roomDesc.map_type, gamelabel=roomDesc.gamelabel } )
			statistics_9502_handler.OnEnterRoomResultStatistics(true)
			NewBattlePassEventOnTrigger("mulgame");
		else
			ShowGameTips(GetS(573), 3);
			statistics_9502_handler.OnEnterRoomResultStatistics(false,573)
		end
		--客机记录地图fromowid
		DeveloperFromOwid = roomDesc.map_type;

		--local worldInfo = AccountManager:getCurWorldDesc();
		if roomDesc.connect_mode == 0 then
			local worldListRecentlyOpened = AccountManager:getMyRecentlyOpenedWorldList()
			--worldListRecentlyOpened:saveRecentlyPlayedMap(roomDesc.map_type,worldInfo.worldid,roomDesc.thumbnail_url,roomDesc.thumbnail_md5,worldInfo.worldname,JOIN_ROOM);
			worldListRecentlyOpened:saveRecentlyPlayedMap(roomDesc.map_type,0,roomDesc.thumbnail_url,roomDesc.thumbnail_md5,roomDesc.roomname,JOIN_ROOM);
			worldListRecentlyOpened:saveLastJoinRoomInfo(roomDesc.owneruin,roomDesc.map_type, 0);
		end

		--联机来源埋点
		OnlineSourceStatistics(roomDesc.map_type, false)
		standReportLinkRoom(roomDesc)
	end
end

function LinkRoomStartGameByDesc(password, reportSlot, roomDesc, ignoreErrorTip, failCallBack)
	Log("LinkRoomStartGame:");
	failCallBack = failCallBack or function() end
	if EnterHomeLandInfo and EnterHomeLandInfo.step == HomeLandInterativeStep.GET_ROOM_DESC then
		LinkHomeLandRoomStartGame(password)
		failCallBack("", true, true)
		return --家园联机 
	end

	local stanby1_1, stanby1_2 = "", ""
	local cid = 0

	local ShowGameTips = _G.ShowGameTips
	if ignoreErrorTip then
		ShowGameTips = function() end
	end

	if roomDesc then
		Log("111:");
		local curVersion = ClientMgr:clientVersion();

		if roomDesc then--用来计算埋点需要的数据信息		
			if roomDesc.fromowid and roomDesc.fromowid > 0 then 			
				cid = tostring(roomDesc.fromowid) 		
			elseif roomDesc.owid and roomDesc.owid > 0 then 			
				cid = tostring(roomDesc.owid) 		
			elseif roomDesc.wid and roomDesc.wid > 0 then 			
				cid = tostring(roomDesc.wid) 		
			elseif roomDesc.map_type then 			
				cid = roomDesc.map_type 		
			end

			-- 房间模式 connect_mode = 0:公开房间 , 1:协作模式
			if roomDesc.connect_mode then			
				stanby1_1 = roomDesc.connect_mode + 1
			end

			--人数>6: PC大房间
			if roomDesc.maxplayers and roomDesc.maxplayers > 6 then
				stanby1_2 = 4
			elseif roomDesc.extraData then
				local t_extra = JSON:decode(roomDesc.extraData)
				if t_extra then
					if t_extra.platform then
						-- PC服务器
						if t_extra.platform == 1 then
							stanby1_2 = 3
						-- 手机服务器
						else
							stanby1_2 = 2
						end
					end
				end
			end
		end
		
		local roomType = roomDesc.isServer and 2 or 3
		statistics_9502_handler.OnEnterRoomStatistics(roomDesc.owneruin,reportSlot,roomType,roomDesc.map_type,roomDesc.gamelabel,getShortUin(roomDesc.owneruin))

		if roomDesc.isnearby > 100  and roomDesc.password ~= "" and roomDesc.password ~= password then
			ShowGameTips(GetS(567), 3);
			statistics_9502_handler.OnEnterRoomResultStatistics(false,567)
			failCallBack(roomDesc.owneruin)
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
				statistics_9502_handler.OnEnterRoomResultStatistics(false,572)
				failCallBack(roomDesc.owneruin)
				return;
			end
		end

		StatisticsTools:joinRoom(mIsLanRoom, roomDesc.gamelabel);

		--保存密码
		Room_Data.cur_password = password;

		--可否被追踪
		local cantrace = ClientMgr:getGameData("cantrace")

		if AccountManager:requestConnectWorld(roomDesc.owneruin, password, roomDesc.regionIp, roomDesc.maxplayers, cantrace) then			
			AllRoomManager:AddReqConnectRSRoom(roomDesc, roomDesc.owneruin)
			RoomshowCircleFlag()
			--[[设置打赏状态]]
			MapRewardClass:SetMapsReward(roomDesc.map_type)

			EnterRoomType = roomDesc.gametype;
			LoginRoomClientIp = roomDesc.regionIp;

			WWW_ma_multigame();
			--Log( "gamelabel=" .. roomDesc.gamelabel )
			ns_ma.ma_play_map_set_enter( { where="join_room1", fromowid=roomDesc.map_type, gamelabel=roomDesc.gamelabel } )
			statistics_9502_handler.OnEnterRoomResultStatistics(true)
			NewBattlePassEventOnTrigger("mulgame");
		else
			ShowGameTips(GetS(573), 3);
			statistics_9502_handler.OnEnterRoomResultStatistics(false,573)
			failCallBack(roomDesc.owneruin)
		end
		--客机记录地图fromowid
		DeveloperFromOwid = roomDesc.map_type;

		--local worldInfo = AccountManager:getCurWorldDesc();
		if roomDesc.connect_mode == 0 then
			local worldListRecentlyOpened = AccountManager:getMyRecentlyOpenedWorldList()
			--worldListRecentlyOpened:saveRecentlyPlayedMap(roomDesc.map_type,worldInfo.worldid,roomDesc.thumbnail_url,roomDesc.thumbnail_md5,worldInfo.worldname,JOIN_ROOM);
			worldListRecentlyOpened:saveRecentlyPlayedMap(roomDesc.map_type,0,roomDesc.thumbnail_url,roomDesc.thumbnail_md5,roomDesc.roomname,JOIN_ROOM);
			worldListRecentlyOpened:saveLastJoinRoomInfo(roomDesc.owneruin,roomDesc.map_type, 0);
		end

		--联机来源埋点
		OnlineSourceStatistics(roomDesc.map_type, false)

		-- 快速联机埋点上报。参考RoomFrameInfoStartGameBtn_OnClick
		EnterMapReport = {		
			cid = tostring(cid),
			standby1 = tostring(stanby1_1)..stanby1_2,
			slot = reportSlot,
			-- slot = CurChooseRoomIdx,
		}
		InsertStandReportGameJoinParamArg({standby1 = EnterMapReport.standby1,slot = chooseRoomIdx})

		GetInst("ReportGameDataManager"):SetCId(cid)
		GetInst("ReportGameDataManager"):SetJoinSlot(CurChooseRoomIdx)
	end
end

---------------------------------------------LinkRoomPassWordFrame：密码输入框--------------------------------------------------
function LinkRoomPassWordCloseBtn_OnClick()
	getglobal("LinkRoomPassWordFrame"):Hide()
	if IsInHomeLandMap and IsInHomeLandMap() then
		EnterOwnHomeLand()
	else
		if EnterHomeLandInfo and EnterHomeLandInfo.step == HomeLandInterativeStep.GET_ROOM_DESC then
			EnterHomeLandInfo.step = HomeLandInterativeStep.DONE 
			if not IsMiniLobbyShown() then
				EnterOwnHomeLand()
			end
		end
	end
end

function LinkRoomPassWordFramePasswordEdit_OnEnterPressed()
	SetCurEditBox(nil);
	LinkRoomPassWordEnterBtn_OnClick();
end

function LinkRoomPassWordEnterBtn_OnClick()
	local password = getglobal("LinkRoomPassWordFramePasswordEdit"):GetText();
	LinkRoomStartGame(password);
	getglobal("LinkRoomPassWordFrame"):Hide();
end

function LinkRoomPassWord_OnShow()
	--标题栏
	getglobal("LinkRoomPassWordFrameTitleFrameName"):SetText(GetS(581));

	SetCurEditBox("LinkRoomPassWordFramePasswordEdit");
end

function LinkRoomPassWord_OnHide()
	getglobal("LinkRoomPassWordFramePasswordEdit"):Clear();
end

------------------------------------------------创建房间------------------------------------------------------------------------
function RoomFrameBottomEnterTeam_OnClick(hideReport)
	if not hideReport then
		standReportEvent("10", "MINI_MUTIPLAYERLOBBY_CONTAINER_1", "TeamPlay", "click")
	end
	
	GetInst("TeamupPreSetService"):openTeamupPreSet()
end

function RoomFrameBottomCreateRoomClickReqHistory(ret_data)
	if #ret_data > 0 then
		return true;
	else
		MessageBox(61, GetS(26093), function(click)
			if click == "left" then
				RoomFrameNoMapTipsDownloadBtn_OnClick();
			else
				RoomFrameNoMapTipsOkBtn_OnClick();
			end
		end, nil,nil,nil , true)
	end
	return false;
end

--创建房间
function RoomFrameBottomCreateRoom_OnClick(hideReport, from)
	Log("RoomFrameBottomCreateRoom_OnClick:");
	if not hideReport then
		standReportEvent("10", "MINI_MUTIPLAYERLOBBY_CONTAINER_1", "CreatRoom", "click")
	end
	if ns_data.IsGameFunctionProhibited("r", 10572, 10592) then
		return
	end

	local data = GetInst("lobbyDataManager"):GetArchiveListData();
	if #data > 0 then
		RoomFrameBottomCreateRoomClickHandler(from);
	else
		GetInst("lobbyDataManager"):GetHistoryArchiveMapListData(function(ret_data)
			if RoomFrameBottomCreateRoomClickReqHistory(ret_data) then
				RoomFrameBottomCreateRoomClickHandler(from)
			end
		end, true);
	end	
end

function RoomFrameBottomActivityConcert_OnClick()
    if ActivityConcertMgr:ShowActivityPaper() then
		InFunc_HideRoomFrame()
	end
end

function RoomFrameBottomCreateRoomClickHandler(from)
	--todo 旧创建UI已经不可用 待定这块怎么弄到新UI
	--[[
	if Android:IsBlockArt() and if_open_live_omlet() and if_enable_deep_link() then
		getglobal("CreatRoomSetFrameDeepLinkBtn"):Show();
	else
		getglobal("CreatRoomSetFrameDeepLinkBtn"):Hide();
	end]]

	if ClientCurGame and ClientCurGame:isInGame() then
		local standReportGameParam = GetInst("ReportGameDataManager"):GetGameJoinParam() or {}
		if not standReportGameParam.trace_id then
			standReportGameParam = GetInst("ReportGameDataManager"):GetGameLoadParam() or {}
		end
		local worldInfo = AccountManager:getCurWorldDesc()
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common_comp", "miniui/miniworld/common"})
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/c_hpm_common", "miniui/miniworld/c_hpm_common_big0"})
		GetInst("MiniUIManager"):OpenUI("NewCreateRoom", 
		"miniui/miniworld/createRoom", "NewCreateRoomAutoGen", {owid = worldInfo.worldid, appendReportInfo=standReportGameParam,
		creditReportId = GetInst("CreditScoreService"):GetSubTypeTbl().connect_room_name})
	else
		from = from or "";
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common_comp", "miniui/miniworld/common"})
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/c_hpm_common", "miniui/miniworld/c_hpm_common_big0"})
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/c_miniwork"})
		GetInst("MiniUIManager"):OpenUI("RoomArchive", 
		"miniui/miniworld/createRoom", "RoomArchiveAutoGen", {from = from, creditReportId = GetInst("CreditScoreService"):GetSubTypeTbl().connect_room_name})
	end
	return;	
end

function CreateRoomFrameTopCloseBtn_OnClick()

	standReportEvent("13","MINI_MAP_CREATE_1","Close","click")

	getglobal("CreateRoomFrame"):Hide();

	local frameName = PEC_GetJumpToFrameName()
	if frameName  == "RoomFrame" then
		RoomFrameBackBtn_OnClick()
	end

	if ClientCurGame and not ClientCurGame:isInGame() and (not IsLobbyShown()) and (frameName == "LobbyFrame" or frameName == "lobbyMapArchiveList") then
		if IsRoomFrameShown() then
			CloseRoomFrame();
		end
		ShowLobby();
	end
end

--快捷创建房间
function RoomFrameShortcutCreateBtn_OnClick()
	RoomFrameListCreateRoomBtn_OnClick();
end

--使滑动框有效/无效
function CreateRoomSetDealMsg(bFlag)
	Log("CreateRoomSetDealMsg:");

	local boxUIs = {mRoomRoomBoxUI};

	for i = 1, #boxUIs do
		if HasUIFrame(boxUIs[i]) then
			getglobal(boxUIs[i]):setDealMsg(bFlag);
		end
	end
end

--快速创建房间
function FastOpenOnLine(worldid, isRecommend, showChoose, hideReport, from)
	--打开创建房间窗口
	RoomFrameBottomCreateRoom_OnClick(hideReport, from);
end

--根据地图ID反推当前的存档条，这里返回的是全部存档中的索引位置
function GetCreateRoomUI2WorldId(worldid)

	local myArchiveNum = AccountManager:getMyWorldList():getNumWorld()
	for i=1,myArchiveNum do
		local worldInfo = AccountManager:getMyWorldList():getWorldDesc(i - 1)
		if (worldInfo and (tonumber(worldInfo.worldid) == tonumber(worldid) or worldInfo.fromowid == tonumber(worldid)) ) then
			return i
		end
	end
	return nil;
end

-- 无房间提示关闭跳转
function RoomFrameNoMapTipsCloseJump()
	if HasUIFrame("CloudServerLobby") and getglobal("CloudServerLobby"):IsShown() then
		GetInst("UIManager"):Close("CloudServerLobby");
	end
	if IsRoomFrameShown() then
		CloseRoomFrame();
	end
end

--无房间提示
function RoomFrameNoMapTipsCloseBtn_OnClick()
	getglobal("RoomFrameNoMapTips"):Hide();
end

--下载地图
function RoomFrameNoMapTipsDownloadBtn_OnClick()
	MessageBox(31, GetS(4971), function(btn)
		if btn == 'right' then
			getglobal("RoomFrameNoMapTips"):Hide();
			--RoomFrameNoMapTipsCloseJump();
			getglobal("MiniWorksFrame"):Show();
			
			local MiniWorksFrameLevel = getglobal("MiniWorksFrame"):GetFrameLevel()
			SetRoomFrameLevel(MiniWorksFrameLevel - 1)
		end
	end);
end

function RoomFrameNoMapTipsOkBtn_OnClick()
	getglobal("RoomFrameNoMapTips"):Hide();
	RoomFrameNoMapTipsCloseJump();
	if isEnableNewLobby and isEnableNewLobby() then
		newlobby_LobbyFrameCreateNewWorldBtn_OnClick();
	else
		LobbyFrameCreateNewWorldBtn_OnClick();
	end
end

------------------------------------------------房间设置----------------------------------------
local CreateRoomLimit = 6;  --6自由模式禁用危险品不允许互相攻击 7游客模式禁用危险品不允许互相攻击
local RoomDescTex = ""


--PC测速--
local speed = 0;
local speedloadtime = 0;
function RespDownloadTestSpeedFile(obj, errcode)
	local timediff = ClientMgr:getCurTick() - speedloadtime;
	speed = 391852 / timediff;
	local maxplayers = math.ceil(speed * 10 / 1000.0 + 0.5);
	if maxplayers < 6 then
		maxplayers = 6;
	elseif maxplayers > 40 then
		maxplayers = 40;
	end
	local fpsMaxplayers = math.ceil((ClientMgr:getFps() * 40) / 950.0);
	if fpsMaxplayers < 6 then
		fpsMaxplayers = 6;
	end
	if fpsMaxplayers < maxplayers then
		maxplayers = fpsMaxplayers;
	end

	if maxplayers >= 10 then
		maxplayers = math.floor(maxplayers/10) * 10;
	elseif maxplayers > 6 and maxplayers < 10 then
		maxplayers = 6;
	end

	local s = StringDefCsv:get(6092)
	s = string.gsub(s, "@num", maxplayers);
	MessageBox(4, s);
	speedloadtime = 0;
	speed = 0;
end

function CreateRoomTestPCSpeedBtn_OnClick()
	if speedloadtime > 0 then
		MessageBox(4, GetS(6093));
	else
		MessageBox(4, GetS(6093));
		speedloadtime =  ClientMgr:getCurTick();
		gFunc_deleteStdioFile('testspeed');
		ns_http.func.downloadFile('http://mdownload.mini1.cn/testspeed/testspeedfile', 'testspeed', nil, RespDownloadTestSpeedFile, nil);
	end
end

--房间密码--
function CreateRoomFrameSetRoomPasswordEdit_OnEnterPressed()
	UIFrameMgr:setCurEditBox(nil);
end

function CreateRoomFrameSetRoomPasswordEdit_OnTabPressed()
	SetCurEditBox("CreatRoomSetFrameCommentEdit");
end


--房间筛选类型不是有序排列，加一个中间转换函数
function RoomGetCreateLabelIndexByGameLabel( label )
	if type(label) == 'number' and label > 100 then
		label = label - 100
	end

	local mapTags = GetInst("MapKindMgr"):GetMapKinds(1,1)
	for i,v in ipairs(mapTags) do
		if label == v.id then
			return i
		end
	end

	--找不到不能返回0，返回7（其他类型）
	return 7
end

function CreateRoomFrameSetDescEdit_OnFocusLost()

end

function CreateRoomFrameSetDescEdit_OnTabPressed()
	SetCurEditBox("CreatRoomSetFrameNameEdit");
end

------------------------------------------------开始游戏----------------------------------------
local IsOpeningRoom = false;
local IsUploadingRooms = {
	Thumb = false,
	Mods = false,
	Intros = false,
	UILibs = false,
	AudioConfig = false,
	createArgs = {},
}
local OpeningRoomModUrl = nil;
local OpeningRoomMatModUuid = nil;
local OpeningRoomUILibsUrl = nil;
local OpeningRoomAudioConfigUrl = nil;

local EnableDeepLink = false;

CreateRoomBackupTips = true;


local CurUploadingIntroUrl = ""
function GetCurUploadingIntroUrl()
	return CurUploadingIntroUrl
end

local createRoomFrameStartGameNum = 0
function CreateRoomSetStartGameNum(num)
	createRoomFrameStartGameNum = num
end

function CreateRoomFrame_Fix_GameOpenStandby1(worldid)
	if worldid then
		local worldInfo = AccountManager:findWorldDesc(worldid)
		if worldInfo then
			local worldtype = tostring(worldInfo.worldtype)
			local roomType = "2"
			local isOwn = "2"
			-- 是自己图
			if worldInfo.realowneruin == AccountManager:getUin() then
				isOwn = "1"
			end	
			if not GetInst("lobbyDataManager"):CanStartOnlineGame(worldInfo) then
				roomType = "3"
			end
			local standby1 = isOwn .. roomType .. worldtype
			standReportGameOpenParam = standReportGameOpenParam or {}
			standReportGameOpenParam.standby1 = standby1
		end
	end
end
-- --房间创建 开始游戏
function CreateRoomFrameSetStartGameBtn_OnClick(worldid, createExInfo, noReport)
	pcall(CreateRoomFrame_Fix_GameOpenStandby1, worldid)
	if not noReport then
		standReportEvent("13", "MINI_MAP_CREATE_1", "GameStart"	, "click")
	end
	-- 网络状态提示
	local worldInfo = nil
	if worldid then
		worldInfo = AccountManager:findWorldDesc(worldid)
	else
		SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		return
	end
	
	if not worldInfo then
		SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		return
	end
	worldid = worldInfo.worldid
	GetInst("RoomService"):AsynReqMapPlayerCount({worldid})
	
	local networkState = GetNetworkState()
	if networkState == 1 or networkState == 2 then
		local net_work_power = ClientMgr and ClientMgr.getNetworkSignal and ClientMgr:getNetworkSignal() or 0;
		if net_work_power <= 1 and IsRoomFrameShown() and createRoomFrameStartGameNum < 2 then
			MessageBox(5,GetS(25841),function(str)
				if str == "left" then
					CreateRoomFrameSetStartGameBtn_OnClick2(worldid, createExInfo)
				else
					createRoomFrameStartGameNum = createRoomFrameStartGameNum + 1
					SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
				end
			end)
		else
			CreateRoomFrameSetStartGameBtn_OnClick2(worldid, createExInfo)
		end
	else
		MessageBox(5,GetS(25841),function(str)
			if str == "left" then
				CreateRoomFrameSetStartGameBtn_OnClick2(worldid, createExInfo)
			else
				createRoomFrameStartGameNum = createRoomFrameStartGameNum + 1
				SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			end
		end)
	end
	if not noReport then
		-- game_open上报
		local hundredNum, tenNum, singleNum = 0, 2, 0

		local isnotowner = (worldInfo.realowneruin ~= 0 and worldInfo.realowneruin ~= 1 and worldInfo.owneruin ~= worldInfo.realowneruin) or false
		if isnotowner then
			hundredNum = 2
		else
			hundredNum = 1
		end
		-- local gameLabel = worldInfo.gameLabel
		
		-- if gameLabel == 0 then
		-- 	gameLabel = GetLabel2Owtype(worldInfo.worldtype)
		-- end
		-- -- 冒险模式
		-- if gameLabel == 2 then
		-- 	singleNum = 1
		-- -- 创造模式
		-- elseif gameLabel == 3 then
		-- 	singleNum = 2
		-- -- 开发者模式
		-- else
		-- 	singleNum = 3
		-- end
		singleNum = worldInfo.worldtype or worldInfo.gameLabel or 0
		local cid = worldInfo.worldid
		if cid == 0 or cid ~= worldInfo.fromowid then
			cid = worldInfo.fromowid
		end
		local standby1 = hundredNum*100+tenNum*10+singleNum
		standReportGameOpenParam = {
			cid         = cid,
			standby1    = standby1,
			sceneid     = "13",
			cardid		= "MINI_MAP_CREATE_1",
			compid		= "GameStart"
		}

		GetInst("ReportGameDataManager"):NewGameLoadParam("13","MINI_MAP_CREATE_1","GameStart")
		GetInst("ReportGameDataManager"):SetGameMapOwn(hundredNum)
		GetInst("ReportGameDataManager"):SetGameNetType(GetInst("ReportGameDataManager"):GetGameNetTypeDefine().onlineMode)
		GetInst("ReportGameDataManager"):SetGameMapMode(singleNum)
	end
end

--房间创建 开始游戏
function CreateRoomFrameSetStartGameBtn_OnClick2(worldid, createExInfo)
	local worldInfo = nil
	if worldid then
		worldInfo = AccountManager:findWorldDesc(worldid)
	end
	if not worldInfo then
		SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		return false
	end
	
	worldid = worldInfo.worldid
	if not IsArchiveMapCollaborationMode(worldid) then
		if ns_data.IsGameFunctionProhibited("r", 10572, 10592) then
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			return false
		end

		local isDown = IsDownloadMap(worldInfo)
		if not CheckMapOpenOnline(worldInfo.worldid, worldInfo.open, isDown, worldInfo.worldid) then
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			return false
		end

		if worldInfo.openpushtype == 3 and IsNewbieWorld(worldInfo.worldid) == false then	--联机模式如果发现地图已上传但是本地没有，需要从服务器下载
			if worldInfo.open == 0 then
				local text = GetS(159)
				MessageBox(4, text)
				getglobal("MessageBoxFrame"):SetClientString( "切换帐号未分享地图" )
				SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
				return false
			end
				
			local text = GetS(160)
			local callback = function(flag, data)
				if flag == "left" then
					DownMyWorld2Net(nil, worldInfo)
				end
			end

			MessageBox(5, text, callback, nil)
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			return false
		end

		if worldInfo.openpushtype >= 4 then
			ShowGameTips(GetS(15), 3)
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			return false
		end

		if IsOpeningRoom or getglobal("LoadLoopFrame"):IsShown() then
			--1. 正在转圈的时候不让重复点击开始按钮. 2. 正在创建房间时不让重复点击
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		else
			if worldInfo then
				if ClientMgr:getNetworkState() == 2 then
					-- RoomUseDataTips(1);
					MessageBox(7, GetS(21), function(str)
						if str == "left" then
							Log("OpenRoom3") 
							OpenRoom(worldid, createExInfo)
						else
							SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
						end
					end)
				else
					if createExInfo and createExInfo.backUp ~= nil then
						if not createExInfo.backUp then
							OpenRoom(worldid, createExInfo);
						else
							OnCreateRoomBackupTips("right", worldid, createExInfo);
						end
					else
						if not CheckCreateRoomBackupTips(worldid, createExInfo) then
							Log("OpenRoom1");
							OpenRoom(worldid, createExInfo);
						end
					end
				end
			end
		end
	else
		if CollaborationModeIllegalReportTime and AccountManager:getSvrTime() < CollaborationModeIllegalReportTime then
			ShowGameTipsWithoutFilter(GetS(25824, os.date("%Y-%m-%d %H:%M", CollaborationModeIllegalReportTime)), 3)
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			return false
		end
		
		if ns_data.IsGameFunctionProhibited("cr", 25824, 25824) then
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			return false
		end

		if worldInfo.openpushtype == 3 and IsNewbieWorld(worldInfo.worldid) == false then	--协作模式如果发现地图已上传但是本地没有，需要从服务器下载
			if worldInfo.open == 0 then
				local text = GetS(159)
				MessageBox(4, text)
				getglobal("MessageBoxFrame"):SetClientString( "切换帐号未分享地图" )
				SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
				return false
			end
				
			local text = GetS(160)
			local callback = function(flag, data)
				if flag == "left" then
					DownMyWorld2Net(nil, worldInfo)
				end
			end

			MessageBox(5, text, callback, nil)
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			return false
		end

		if worldInfo.openpushtype >= 4 then
			ShowGameTips(GetS(15), 3)
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			return false
		end

		local callback = function(flag, data)
			if flag == "right" then--确认
				if IsOpeningRoom or getglobal("LoadLoopFrame"):IsShown() then
					--1. 正在转圈的时候不让重复点击开始按钮. 2. 正在创建房间时不让重复点击
					SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
				else
					if ClientMgr:getNetworkState() == 2 then
						-- RoomUseDataTips(1)
						MessageBox(7, GetS(21), function(str)
							if str == "left" then
								Log("OpenRoom3") 
								IsCreatingColloborationModeRoom = true
								OpenRoom(worldid, createExInfo)
							else
								SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
							end
						end)
					else
						IsCreatingColloborationModeRoom = true
						OpenRoom(worldid, createExInfo)
					end
				end
			else
				SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			end
		end

		-- fix by wuyuwang：创建新世界里创建的存档弹框和推荐地图、我的游戏库的不一样
		if createExInfo and createExInfo.teamid then
			callback("right")
		else
			MessageBox(31, GetS(25821), callback, nil)
		end
	end

	return true
end

local FirstTimeOmletDeeplink = true;
function CreateRoomFrameSetDeepLinkBtn_OnClick()
	if Android:IsBlockArt() then
		EnableDeepLink = true
	else
		EnableDeepLink = false
	end
	if ClientMgr then
		if FirstTimeOmletDeeplink then
			MessageBox(5, GetS(1120), OnFirstTimeOmletDeeplinkTips);
		end
		if FirstTimeOmletDeeplink ~= true and EnableDeepLink then			
			--todo 旧创建UI已经不可用 待定这块怎么弄到新UI
			--[[
			local uin = AccountManager:getUin();
			local passwordEdit = getglobal("CreatRoomSetFramePasswordEdit")
			local password = passwordEdit:GetText();
			if passwordEdit.IsCoderEditMethod and passwordEdit:IsCoderEditMethod() then
				password = passwordEdit:GetPassWord()
			end
			SdkManager:omletDeepLink(uin, password)
			EnableDeepLink = false
			CreateRoomFrameSetStartGameBtn_OnClick()]]
		end
	end
end

function OnFirstTimeOmletDeeplinkTips(btn)
	if btn == "left" then
		if EnableDeepLink then
			--todo 旧创建UI已经不可用 待定这块怎么弄到新UI
			--[[
			FirstTimeOmletDeeplink = false
			local uin = AccountManager:getUin();
			local passwordEdit = getglobal("CreatRoomSetFramePasswordEdit")
			local password = passwordEdit:GetText();
			if passwordEdit.IsCoderEditMethod and passwordEdit:IsCoderEditMethod() then
				password = passwordEdit:GetPassWord()
			end
			SdkManager:omletDeepLink(uin, password)
			EnableDeepLink = false
			]]
		end
	end
end


--备份存档提示
function CheckCreateRoomBackupTips(worldid, createExInfo)
	if createExInfo ~= nil and createExInfo.directOpenRoom ~= nil and createExInfo.directOpenRoom == true then
		return false
	end
	if CreateRoomLimit == 6 and CreateRoomBackupTips then
		--CreateRoomBackupTips = false;
		MessageBox(31, GetS(4978), function(str) OnCreateRoomBackupTips(str, worldid, createExInfo) end);
		return true;
	end

	return false;
end

function OnCreateRoomBackupTips(btn, worldid, createExInfo)
	if btn == "right" then
		local worldInfo = nil
		if worldid then
			worldInfo = AccountManager:findWorldDesc(worldid)
		end
		if not worldInfo then 
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			return
		end
		local id = worldInfo.worldid
		local function backupCallBack()
			threadpool:delay(3, function()
			HideNoTransparentLoadLoop()
			end)
			OpenRoom(id, createExInfo)
		end
		--记录id,不用worldInfo,防止变成野指针
		ShowNoTransparentLoadLoop()
		threadpool:work(function()
			OnlineWorldBackup(id, backupCallBack)
		end)
		return
	end

	ShowNoTransparentLoadLoop()
	OpenRoom(worldid, createExInfo);
	threadpool:delay(2, function()
		HideNoTransparentLoadLoop()
	end)
end

--创建房间
function OpenRoom(worldid, createExInfo)
	local checker_uin = AccountManager:getUin()
	if IsUserOuterChecker(checker_uin) and not DeveloperAdCheckerUser(checker_uin) then
		ShowGameTips(GetS(100300), 3)
        return nil;
	end
	Log("OpenRoom");
	local teamupSer = GetInst("TeamupService")
	if not (createExInfo ~= nil and createExInfo.teamid) then
		if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
			ShowGameTips(GetS(26045))
        	return
		end
	end

	if not mIsLanRoom then
		-- Log("OpenRoom CheckUinLogin");
		local havelogin = false;

		if _G.check_use_new_server() then
			-- Log("OpenRoom check_use_new_server");
			if AccountManager:isLogin() then
				-- Log("OpenRoom isLogin");
				havelogin = true;
			else
				Log("OpenRoom try login...");
				if AccountManager:data_update() == 0 then
					-- Log("OpenRoom data_update");
					havelogin = true;

					local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix("PHost_Create_Room")
					AccountManager:checkRoomServerLogin(genkey);
					-- Log("OpenRoom checkRoomServerLogin");
					ShowGameTips(GetS(3272), 3);
					SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
					return;
				else
					havelogin = false;
				end
			end

			if (AccountManager:getUin() or 0) < 1000 then
				-- Log("OpenRoom getUin() or 0 < 1000");
				havelogin = false;
			end
		else
			havelogin = (AccountManager:getUin() or 0)>=1000;
		end

		if not havelogin then
			-- Log("OpenRoom not havelogin");
			ShowGameTips(GetS(3272), 3);
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			return;
		end

		-- Log("OpenRoom CheckUinLogin B");
	end

	local isCollaborationMode = IsArchiveMapCollaborationMode()
	if not isCollaborationMode and worldid == nil then
		Log("OpenRoom not isCollaborationMode and worldid == nil <= 0");
		SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		return ;
	end

	local worldInfo
	if worldid then
		worldInfo = AccountManager:findWorldDesc(worldid)
	else
		if ClientCurGame:isInGame() then
			worldInfo = AccountManager:getCurWorldDesc()
		else
			worldInfo = AccountManager:findWorldDesc(gCreateRoomWorldID)
		end
	end

	if worldInfo == nil then
		SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		return
	end

	-- Log("OpenRoom worldInfo", table.tostring(worldInfo));
	--加载了插件的地图暂时不允许开房间
	--if ModMgr:isExistMod(worldInfo.worldid) then
	--	ShowGameTips(GetS(3810), 3);
	--	return ;
	--end

	worldid = worldInfo.worldid
	local verifyId = worldInfo.fromowid;
	if not verifyId or verifyId == 0 then
		Log("OpenRoom not verifyId or verifyId == 0");
		verifyId = worldInfo.worldid;
	end

	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(verifyId);
	if mapIsBreakLaw == 1 then
		-- Log("OpenRoom mapIsBreakLaw == 1");
		ShowGameTips(GetS(10562), 3);
		SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		return ;
	elseif mapIsBreakLaw == 2 then
		-- Log("OpenRoom mapIsBreakLaw == 2");
		ShowGameTips(GetS(3633), 3);
		SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		return ;
	end

	local opensvr = worldInfo.OpenSvr
	if (opensvr == 4 or opensvr == 14) then -- 封禁
		-- Log("OpenRoom mapIsBreakLaw == 2");
		ShowGameTips(GetS(3633), 3);
		SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		return ;
	end

	--黑词库与本地敏感词库过滤
	if CheckFilterString(worldInfo.worldname..", "..worldInfo.memo, false)
			or FilterMgr.GetFilterScore(worldInfo.worldname) or FilterMgr.GetFilterScore(worldInfo.memo) then
		ShowGameTips(GetS(10548), 3)
		SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		return ;
	end

	local checkPassPortCallBack = function(ret)
		if ret == 0 then
			if ClientCurGame:isInGame() then
				-- Log("OpenRoom isInGame");
				if worldid then
					ArchiveWorldDesc = AccountManager:findWorldDesc(worldid)
					ArchiveWorldDescWorldId  = ArchiveWorldDesc.worldid
					EnterMainMenuInfo.OpenRoom = true;
					EnterMainMenuInfo.OpenRoomEx = {
						worldid = ArchiveWorldDesc.worldid,
						createExInfo = createExInfo,
					}
				else
					ArchiveWorldDesc = AccountManager:getCurWorldDesc()
					ArchiveWorldDescWorldId  = ArchiveWorldDesc.worldid
					EnterMainMenuInfo.OpenRoom = true;
					EnterMainMenuInfo.OpenRoomEx = {
						worldid = ArchiveWorldDesc.worldid,
						createExInfo = createExInfo,
					}
				end
				HideUI2GoMainMenu();
				-- Log("OpenRoom HideUI2GoMainMenu");
				ClientMgr:gotoGame("MainMenuStage");
				-- Log("OpenRoom gotoGame MainMenuStage");
				-- SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
				return ;
			end

			local genkey, gid = GetInst("UIEvtHook"):GenKeyWithPrefix("PHost_Create_Room")
			AccountManager:checkRoomServerLogin(genkey);
			-- Log("OpenRoom checkRoomServerLogin");

			OpeningRoomMatModUuid = nil;

			local loadmodflags = LuaInterface:band(LMF_Default, LuaInterface:bnot(LMF_ParseComponents));
			-- Log("OpenRoom LuaInterface:band");
			ModMgr:loadWorldMods(worldInfo.worldid, loadmodflags);
			-- Log("OpenRoom loadWorldMods");
			for i = 0, ModMgr:getMapModCount() - 1 do
				local moddesc = ModMgr:getMapModDescByIndex(i);
				-- Log("OpenRoom getMapModDescByIndex");
				if moddesc.modtype == 1 then
					OpeningRoomMatModUuid = moddesc.uuid;
				end
			end
			ModMgr:unLoadCurMods(worldInfo.worldid, false);
			-- Log("OpenRoom unLoadCurMods");

			ModMgr:clearDisableWorldMods();
			-- Log("OpenRoom clearDisableWorldMods");

			-- Log('OpeningRoomMatModUuid = '..tostring(OpeningRoomMatModUuid));

			if OpeningRoomMatModUuid then
				-- Log("OpenRoom OpeningRoomMatModUuid");
				ReqGetMaterialModUnlocked(OpeningRoomMatModUuid, function(unlocked)
					--if not unlocked then
					--	ShowGameTips(GetS(4782), 3);
					--	ModMgr:setDisableWorldMod(OpeningRoomMatModUuid, true);
					--	OpeningRoomMatModUuid = nil;
					--end
					OpenRoomOnPermissionChecked(worldid, createExInfo);
				end)
			else
				OpenRoomOnPermissionChecked(worldid, createExInfo);
				-- Log("OpenRoom OpenRoomOnPermissionChecked");
			end

			Lite:RestoreFunctionsInOnlineRoom();

			--联机来源埋点
			OnlineSourceStatistics(worldInfo.worldid, true)

			-- 新增冒险回归活动“联机模式”任务上报
			if GetInst("ComeBackSysConfig"):IsNeedReportEvent(4) then
				GetInst("ComeBackSysConfig"):RequestEvent(4)
			end

			-- fym 装扮换装改版需求：判断是否是从装扮详情页跳转至地图内，如果是则需要关闭装扮详情页和商城界面
			if ret == 0 then			
				EnterGameFromShopSkinDisplay()
			end

		elseif ret == 1 then
			ShowGameTips(GetS(21604), 3)
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		else
			ShowGameTips(GetS(3893), 3)
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		end
		--回流联机
		if mComeBackInlineState ~= 0 then
			if ret == 0 then 
				StatisticComeBackCreateGame(worldInfo,9) -- 成功
			else
				StatisticComeBackCreateGame(worldInfo,10) -- 失败
			end
		end
	end

	CheckPassPortInfo(worldInfo, checkPassPortCallBack)
end

function OpenRoomOnPermissionChecked(worldid, createExInfo)
	Log("OpenRoomOnPermissionChecked");

	local worldInfo
	if worldid then
		worldInfo = AccountManager:findWorldDesc(worldid)
	else
		if not IsArchiveMapCollaborationMode() then
			SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
			--MiniBase创建房间失败回调                          
			SandboxLua.eventDispatcher:Emit(nil, "MiniBase_CreateRoom",  SandboxContext():SetData_Number("code", 204))
			return
		else
			worldInfo = AccountManager:findWorldDesc(gCreateRoomWorldID)
			if worldInfo == nil then
				SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
				--MiniBase创建房间失败回调                          
				SandboxLua.eventDispatcher:Emit(nil, "MiniBase_CreateRoom",  SandboxContext():SetData_Number("code", 204))
				return
			end
		end
	end

	if worldInfo == nil then
		SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
		--MiniBase创建房间失败回调                          
		SandboxLua.eventDispatcher:Emit(nil, "MiniBase_CreateRoom",  SandboxContext():SetData_Number("code", 204))
		return
	end

	IsOpeningRoom = true;
	IsUploadingRooms.createArgs = {}
	IsUploadingRooms.createArgs.worldid = worldid
	IsUploadingRooms.createArgs.createExInfo = createExInfo
	for k, v in pairs(IsUploadingRooms) do
		if "table" ~= type(v) then
			IsUploadingRooms[k] = true
		end
	end
	RoomshowCircleFlag()
	AccountManager:uploadRoomThumbnail(worldInfo.worldid);
	AccountManager:uploadRoomMods(worldInfo.worldid);
	AccountManager:uploadRoomIntros(worldInfo.worldid);
	AccountManager:uploadRoomUILibs(worldInfo.worldid);
	threadpool:work(function()
		_G.SSMgrAssets:UploadRoomAssetsConfig(worldInfo.worldid);
	end)

	--统计进入自己地图或下载地图
	Log("--------gamelabel----" .. worldInfo.gameLabel .. "  worldType:".. worldInfo.worldtype);
	if worldInfo.realowneruin > 1 and worldInfo.owneruin ~= worldInfo.realowneruin then --下载的地图
		-- statisticsGameEvent(8007,"%d",worldInfo.worldtype);
		-- statisticsGameEvent(8008,"%d",worldInfo.gameLabel);
	else                                                                           --自己创建的地图
		-- statisticsGameEvent(8006,"%d",worldInfo.worldtype);
	end
end


function CheckOpenRoomFinish()
	local finish = true
	for _, v in pairs(IsUploadingRooms) do
		if v and "table" ~= type(v) then
			finish = false
		end
	end
	return finish
end

function onRoomThumbnailUploaded(worldid, downloadurl)
	Log("onRoomThumbnailUploaded");
	IsUploadingRooms.Thumb = false

	if CheckOpenRoomFinish() then
		
		threadpool:work(function ()
			local worldInfo =AccountManager:findWorldDesc(IsUploadingRooms.createArgs.worldid)
			if worldInfo and  worldInfo.fromowid and  worldInfo.fromowid > 0 then
				GetInst("RoomService"):AsynReqMapPlayerCount({worldInfo.fromowid})
			end
			OnOpenRoomFinish(IsUploadingRooms.createArgs.worldid, IsUploadingRooms.createArgs.createExInfo);
		end)
		
	end
end

function onRoomModsUploaded(result, downloadurl)
	Log("onRoomModsUploaded: "..result.. ", '"..downloadurl.."'");
	IsUploadingRooms.Mods = false;

	OpeningRoomModUrl = downloadurl;

	if result ~= 0 then
		ShowGameTips(GetS(4785).."("..result..")", 3);
		OnOpenRoomFailed(IsUploadingRooms.createArgs.createExInfo);
		return
	end
	
	if CheckOpenRoomFinish() then
		threadpool:work(function ()
			local worldInfo =AccountManager:findWorldDesc(IsUploadingRooms.createArgs.worldid)
			if worldInfo and worldInfo.fromowid and worldInfo.fromowid > 0 then
				GetInst("RoomService"):AsynReqMapPlayerCount({worldInfo.fromowid})
			end
			OnOpenRoomFinish(IsUploadingRooms.createArgs.worldid, IsUploadingRooms.createArgs.createExInfo);
		end)
		
	end
end

function onRoomIntrosUploaded(result, downloadurl)
	Log("onRoomIntrosUploaded");
	IsUploadingRooms.Intros = false;
	CurUploadingIntroUrl = downloadurl

	if CheckOpenRoomFinish() then
		OnOpenRoomFinish(IsUploadingRooms.createArgs.worldid, IsUploadingRooms.createArgs.createExInfo);
	end
end


function onRoomUILibsUploaded(result, downloadurl)
	Log("onRoomUILibsUploaded: "..result.. ", '"..downloadurl.."'");
	IsUploadingRooms.UILibs = false;

	OpeningRoomUILibsUrl = downloadurl;

	if result ~= 0 then
		ShowGameTips(GetS(4785).."("..result..")", 3);
		OnOpenRoomFailed(IsUploadingRooms.createArgs.createExInfo);
		return
	end
	
	if CheckOpenRoomFinish() then
		OnOpenRoomFinish(IsUploadingRooms.createArgs.worldid, IsUploadingRooms.createArgs.createExInfo);
	end
end

function onRoomAudioConfigUploaded(result, downloadurl)
	Log("onRoomAudioConfigUploaded: "..result.. ", '"..downloadurl.."'");
	IsUploadingRooms.AudioConfig = false;

	OpeningRoomAudioConfigUrl = downloadurl;

	if result ~= 0 then
		ShowGameTips(GetS(16165).."("..result..")", 3);
		OnOpenRoomFailed(IsUploadingRooms.createArgs.createExInfo);
		return
	end

	if CheckOpenRoomFinish() then
		OnOpenRoomFinish(IsUploadingRooms.createArgs.worldid, IsUploadingRooms.createArgs.createExInfo);
	end
end

--准备工作就绪, 正式创建房间
function OnOpenRoomFinish(worldid, createExInfo)
	Log("OnOpenRoomFinish()");
	if getglobal("LoadLoopFrame") then
		RoomCloseCircleFlag()
	end
	createExInfo = createExInfo or {}
	createExInfo.password = createExInfo.password or ""
	HideLobby()
	local isCollaborationMode = IsArchiveMapCollaborationMode(worldid)
	if (ClientMgr:isAppFront())  or isCollaborationMode or worldid then
		if IsOpeningRoom then
			IsOpeningRoom = false
			local CreateRoomNum
			local CreateType
			local worldInfo
			local roomName
			local teamMode = false
			if createExInfo.teamid then
				teamMode = true
			end
			if not isCollaborationMode then
				if worldid then
					worldInfo = AccountManager:findWorldDesc(worldid)
				end
				
				if worldInfo == nil then
					SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
					--MiniBase创建房间失败回调                          
					SandboxLua.eventDispatcher:Emit(nil, "MiniBase_CreateRoom",  SandboxContext():SetData_Number("code", 204))
					return
				end
				
				--地图类型:
				CreateType = worldInfo.gameLabel
				if CreateType == 0 then
					CreateType = GetLabel2Owtype(worldInfo.worldtype)
				end
				--人数
				CreateRoomNum = createExInfo.maxPeople or 6
				roomName = worldInfo.worldname
			else
				if worldid then
					worldInfo = AccountManager:findWorldDesc(worldid)
				else
					worldInfo = AccountManager:findWorldDesc(gCreateRoomWorldID)
				end
				if worldInfo == nil then
					SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
					--MiniBase创建房间失败回调                          
					SandboxLua.eventDispatcher:Emit(nil, "MiniBase_CreateRoom",  SandboxContext():SetData_Number("code", 204))
					return
				end

				-- worldInfo = ArchiveWorldDesc
				CreateType = GetLabel2Owtype(worldInfo.worldtype)
				CreateRoomNum = createExInfo.maxPeople or 6
				roomName = worldInfo.worldname
				--好友联机的地图 connect_mode 不存在或者为0的情况下要强制设置为1
				if not createExInfo.connect_mode or createExInfo.connect_mode == 0 then
					createExInfo.connect_mode = 1
				end
				if not createExInfo.publicType then
					createExInfo.publicType = 0
				end
			end

			--本地敏感词和配置黑词过滤
			if CheckFilterString(roomName, false) or FilterMgr.GetFilterScore(roomName) then
				ShowGameTips(GetS(10548), 3)
				SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
				--MiniBase创建房间失败回调                          
				SandboxLua.eventDispatcher:Emit(nil, "MiniBase_CreateRoom",  SandboxContext():SetData_Number("code", 205))
				return
			end

			local password = ""
			if teamMode then
				roomName = createExInfo.roomName or worldInfo.worldname
				CreateRoomNum = createExInfo.maxPeople or 6
				CreateType = GetLabel2Owtype(worldInfo.worldtype)
			else
				password = createExInfo.password
			end


			local curVersion = ClientMgr:clientVersion()
			--是否局域网
			local IsLanRoom = mIsLanRoom;

			local style = nil;
			if not isCollaborationMode and not teamMode then
				CreateRoomLimit = createExInfo.authority or 6;
				CreateRoomNum = createExInfo.maxPeople;
				password = createExInfo.password;
				style = createExInfo.style;
				roomName = createExInfo.name;
				CreateType = worldInfo.gameLabel 
				if not CreateType or CreateType <= 0 then
					CreateType = GetLabel2Owtype(worldInfo.worldtype)
				end
			end
			
			--MiniBase创建房间透传参数
			if MiniBaseManager:isMiniBaseGame() then  
				CreateRoomLimit = createExInfo.authority or 6;
				CreateRoomNum = createExInfo.maxPeople;
				password = createExInfo.password;
				roomName = createExInfo.name;
				CreateType = GetLabel2Owtype(worldInfo.worldtype);
				RoomDescTex = createExInfo.RoomDescTex;
			end

			local t_extra = {};
			--改为调用地图分类管理体系的接口
        	t_extra.autoTag = GetInst("MapKindMgr"):GetKindName(worldInfo.gameLabel,worldInfo.worldtype)

			t_extra.version = ClientMgr:clientVersionToStr(curVersion);
			t_extra.gender = ns_playercenter.gender or 0
			t_extra.teamid = createExInfo and createExInfo.id
			t_extra.style  = style;
			t_extra.preinstallRnId = createExInfo and createExInfo.preinstallRnId
			if t_extra.preinstallRnId and t_extra.preinstallRnId < 0 and createExInfo.preinstallShowName then
				t_extra.preinstallRnTk = string.sub(gFunc_getmd5(createExInfo.preinstallShowName), 1, 8)--简单校验 保留8个字符够了
			end
			

			local vipinfo = AccountManager:getAccountData():getVipInfo();
			if vipinfo then
				t_extra.vipType = vipinfo.vipType;
				t_extra.vipLevel = vipinfo.vipLevel;
				t_extra.vipExp = vipinfo.vipExp;
			end

			--load mod info
			if OpeningRoomMatModUuid then
				t_extra.modUuids = {OpeningRoomMatModUuid};
			else
				t_extra.modUuids = {};
			end

			t_extra.modurl = OpeningRoomModUrl;
			t_extra.limit = CreateRoomLimit;
			t_extra.uilibsurl = OpeningRoomUILibsUrl;
			t_extra.platform = ClientMgr:isPC() and 1 or 2;
			t_extra.hostRoomTk = gen_gid()

			if worldInfo.translate_supportlang - math.pow(2,get_game_lang()) > 0 then
				t_extra.translate_supportlang = worldInfo.translate_supportlang
			end
			t_extra.translate_sourcelang = worldInfo.translate_sourcelang

			--自定义音频
			t_extra.audioconfigurl = OpeningRoomAudioConfigUrl
			t_extra.uniqueCode = CalculateUniqueCode()
			local editorSceneSwitch = worldInfo.editorSceneSwitch or 0
			t_extra.editorSceneSwitch = editorSceneSwitch
			Log("t_extra = ");
			standReportGameOpenParam = standReportGameOpenParam or {}
			standReportGameOpenParam.standby2 = t_extra.uniqueCode
			GetInst("ReportGameDataManager"):SetGameLoadParamStandby3(t_extra.uniqueCode)

			--房间介绍
			-- local roomdesctex = getglobal("CreatRoomSetFrameCommentEdit"):GetText();
			-- if CheckFilterString(roomdesctex) then return end
			-- if roomdesctex ~= nil and roomdesctex ~= "" then
			-- RoomDescTex = roomdesctex;
			-- end

			--可否被追踪
			CreateRoomNum = CreateRoomNum or createExInfo.maxPeople or 6
			local cantrace = ClientMgr:getGameData("cantrace")
			if createExInfo.cantrace or createExInfo.canTrace then
				cantrace = createExInfo.cantrace or createExInfo.canTrace
			else				
				cantrace = setbit(cantrace, bit(2))
			end
			-- cantrace = setbit(cantrace, bit(1))
			-- cantrace = setbit(cantrace, bit(2))
			-- cantrace = setbit(cantrace, bit(3))
			-- cantrace = setbit(cantrace, bit(5))
			-- createExInfo.publicType = 1
			
			local connect_mode = createExInfo.connect_mode or 0
			local maxSetPlayerLimit = ClientMgr:isPC() and 40 or 6
			maxSetPlayerLimit = math.max(CreateRoomNum, maxSetPlayerLimit)
			local publicType = createExInfo.publicType or 0
			if teamMode then
				cantrace = 0
				connect_mode = 2 --2 组队 1 好友 0 公开
				publicType = 1
			end

			if not roomName then
				roomName = worldInfo.worldname or ""
			end
			local preiRoomNameIdx = tonumber(t_extra.preinstallRnId) or 0
			local customRoomName = ""
			if preiRoomNameIdx < 0 then
				customRoomName = createExInfo.preinstallShowName
			end
			local jsonExtra = JSON:encode(t_extra);
			if RoomManager.createRoomEx then
				local createRoomParam = CreateRoomParam(
					worldInfo.worldtype,
					worldInfo.worldname,
					maxSetPlayerLimit,
					password,
					RoomDescTex,
					jsonExtra,
					CreateType,
					CreateRoomLimit,
					IsLanRoom
				)
				createRoomParam.CanTrace = cantrace or 0
				createRoomParam.ShareVersion = worldInfo.shareVersion
				createRoomParam.CustomRoomName = customRoomName
				createRoomParam.PreiNameIdx = preiRoomNameIdx
				createRoomParam.editorSceneSwitch = worldInfo.editorSceneSwitch
				RoomManager:createRoomEx(createRoomParam);	
			else
				AccountManager:createRoom(worldInfo.worldtype,
						worldInfo.worldname,
						maxSetPlayerLimit,
						password,
						RoomDescTex,
						jsonExtra,
						CreateType,
						CreateRoomLimit,
						IsLanRoom,
						cantrace,
					worldInfo.shareVersion,
					editorSceneSwitch
				);
			end

			if not AccountManager:requestEnterWorld(worldInfo.worldid, true, 0, connect_mode, CreateRoomNum, publicType) then
				ShowGameTips(GetS(146), 3);
				SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
				--MiniBase创建房间失败回调                          
				SandboxLua.eventDispatcher:Emit(nil, "MiniBase_CreateRoom",  SandboxContext():SetData_Number("code", 207))
				return;
			end
		
			NewBattlePassEventOnTrigger("mulgame");

			if worldInfo.worldtype == 5 then		--玩法运行模式,暂时没用
				EnterMainMenuInfo.ReopenRoomInfo = {};
				EnterMainMenuInfo.ReopenRoomInfo.WorldType = worldInfo.worldtype;
				EnterMainMenuInfo.ReopenRoomInfo.RoomName = worldInfo.worldname;
				EnterMainMenuInfo.ReopenRoomInfo.CustomRoomName = customRoomName;
				EnterMainMenuInfo.ReopenRoomInfo.PreiNameIdx = preiRoomNameIdx;
				EnterMainMenuInfo.ReopenRoomInfo.CreateRoomNum = CreateRoomNum;
				EnterMainMenuInfo.ReopenRoomInfo.Passworld = password;
				EnterMainMenuInfo.ReopenRoomInfo.RoomDescTex = RoomDescTex;
				EnterMainMenuInfo.ReopenRoomInfo.Text = jsonExtra;
				EnterMainMenuInfo.ReopenRoomInfo.CreateType = CreateType;
				EnterMainMenuInfo.ReopenRoomInfo.CreateRoomLimit = CreateRoomLimit;
				EnterMainMenuInfo.ReopenRoomInfo.IsLanRoom = IsLanRoom;
				EnterMainMenuInfo.ReopenRoomInfo.WorldId = worldInfo.worldid;
				EnterMainMenuInfo.ReopenRoomInfo.CanTrace = cantrace
				EnterMainMenuInfo.ReopenRoomInfo.ShareVersion = worldInfo.shareVersion
				EnterMainMenuInfo.ReopenRoomInfo.editorSceneSwitch = worldInfo.editorSceneSwitch

				EnterSurviveGameInfo.PassWorld = password

			end
			if not EnterMainMenuInfo.LobbyOnline then
				EnterMainMenuInfo.RoomCurLabel = mRoomFrameVar.CurLeftBtnIndex;
			end

			WWW_ma_multigame();
			ns_ma.ma_play_map_set_enter( { where="create_room" } )

			if worldInfo.worldtype == 4 then
				PermitsCallModuleScript("setIgnorePermit",false)
			end
			
			SetAllDisableItemPermits(true);

			if worldInfo.worldtype == 0 then
				StatisticsTools:gameEvent("EnterSurviveWNum");
			elseif worldInfo.worldtype == 1 or worldInfo.worldtype == 3 then
				StatisticsTools:gameEvent("EnterCreateWNum");
			end
			StatisticsTools:gameEvent("CreateRoomNum");
			local isPassword = true;
			if password == nil	or password== "" then
				isPassword = false;
			else
				isPassword = true;
			end
			
			-- 房间类型（1.个人手机联机房间、2.个人电脑联机房间、3.云服房间、4.官服、5.家园房间）"
			local staticsRoomType = 1
			if t_extra.platform == 1 then
				staticsRoomType = 2
			end
			StatisticsTools:createRoom(IsLanRoom,CreateType,isPassword,CreateRoomLimit,SAID_CreateRoomEx, "", tostring(staticsRoomType));

			-- statisticsGameEvent(SAID_CreateRecommendRoom, "%lld", worldInfo.worldid);

			RoomInteractiveData.curMapwid = 0
			RoomInteractiveData.connect_mode = nil
			RoomInteractiveData.curInRoomName = createExInfo.preinstallShowName or roomName;
			RoomInteractiveData.isCustomRoomName = preiRoomNameIdx < 0
			RoomInteractiveData.curRoomName = roomName;
			RoomInteractiveData.curRoomPW = password;
			RoomInteractiveData.cur_gameLabel = CreateType;
			RoomInteractiveData.cur_hostRoomTk = t_extra.hostRoomTk
			if teamMode then
				RoomInteractiveData.connect_mode = 2
			end
			RoomInteractiveData.curStyle = style -- 记录房主风格


			GetInst("MiniUIManager"):CloseUI("RoomArchiveAutoGen");
			getglobal("CreateRoomFrame"):Hide();
			
			GetInst("UIManager"):Close("MapRoom")
			CloseRoomFrame();
			GetInst("UIManager"):Close("CloudServerLobby")
			if IsUIFrameShown("ArchiveInfoFrameEx") then
				local pCtrl = GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx")
				if pCtrl and pCtrl.SetEnterGameBackInfo then
					pCtrl:SetEnterGameBackInfo()
				end
				GetInst("UIManager"):Close("ArchiveInfoFrameEx");
			end
			if getglobal("MiniWorksTopicDetail"):IsShown() then
				GetInst("UIManager"):Close("MiniWorksTopicDetail")
			end
			GetInst("UIManager"):Close("TeamupMain")
			UIFrameMgr:hideAllFrame();
			ShowLoadingFrame();
			local mapid = 0
			if worldInfo.fromowid == 0 then
				mapid =  worldInfo.worldid
			else
				mapid = worldInfo.fromowid
			end
			local worldListRecentlyOpened = AccountManager:getMyRecentlyOpenedWorldList()
			worldListRecentlyOpened:saveRecentlyPlayedMap(tostring(mapid),worldInfo.worldid,"","",worldInfo.worldname,CREAT_ROOM);

			if teamMode then
				local teamupSer = GetInst("TeamupService")
				if teamupSer then
					teamupSer:NotifyMemberTips(GetS(26081), {AccountManager:getUin()})
				end
			end

			--这个return 千万别去掉
			return true
		end
	end
	
	SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
end

function OnOpenRoomFailed(createExInfo)
	Log("OnOpenRoomFailed()");
	--MiniBase创建房间失败回调                          
	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_CreateRoom",  SandboxContext():SetData_Number("code", 206))
	if getglobal("LoadLoopFrame") then
		RoomCloseCircleFlag()
	end

	IsOpeningRoom = false;
	IsUploadingRooms.createArgs = {}
	for k, v in pairs(IsUploadingRooms) do
		if "table" ~= type(v) then
			IsUploadingRooms[k] = false;
		end
	end
	OpeningRoomMatModUuid = nil;
	SafeCallTabMebFuncByKey(createExInfo, "abortCallBack")
	if not getglobal("Roomframe") or not IsRoomFrameShown() then
		ShowLobby();
	end
	EnterMainMenuInfo.LobbyOnline = false;
end

-----------------------------------------------------------------------其它补充--------------------------------------------
--工坊里面点击联机按钮
function SearchSelectRoomOWByUin(uin, _owid, _map)
	-- hrl todo
	if _map then
		GetInst("UIManager"):Open("MapRoom", {mapInfo = _map})
	else
		ShowMapRoomByMapID(_owid)
	end
end

-----------------------------------------------------------------------从赛事网页打开联机大厅--------------------------------------------
--
local isWebReqOpenRoomsFuncOpen = true
--C++调用入口
function WebReqOpenRooms(owid,uins)
	if not isWebReqOpenRoomsFuncOpen then
		if not ClientMgr:isPC() then
			JsBridge:PopFunction();
		end
		return
	end
	if ClientCurGame:isInGame() then
		ShowGameTips(GetS(1330), 3);
		if not ClientMgr:isPC() then
			JsBridge:PopFunction();
		end
		return;
	end
	if (type(owid) == "string" and owid == "") or (not owid) or (type(uins) == "string" and uins == "") or (not uins) then
		--直接打开联机大厅界面
		RequestLoginRoomServer();
		return;
	end
	WebReqOneMapInfo(owid,uins)
end

function WebReqOneMapInfo(owid,uins)
	Log( "WebReqOneMapInfo " .. (owid or 'nil') )
	local userdata = {uin = uins}
	ReqMapInfo({owid}, WebRespMapInfoByServer,userdata);
end

function WebRespMapInfoByServer(maps,userdata)
	if maps == nil or table.getn(maps) == 0 then
		ClientMgr:setStartingRoom(false);
		if not ClientMgr:isPC() then
			JsBridge:PopFunction();
		end
		return;
	end
	local _map = maps[1]
	SearchSelectRoomsByUins(userdata.uin,_map.owid,_map)
end

function SearchSelectRoomsByUins(uins,_owid,_map)
	if _owid and uins then
		-- hrl todo
		if _map then
			GetInst("UIManager"):Open("MapRoom", {mapInfo = _map})
		else
			ShowMapRoomByMapID(_owid)
		end
		
		if IsUIFrameShown("ActivityMainFrame") then
			ActivityMainCtrl:AntiActive()
		end

		-- 邮件已经收纳进消息中心
		if MiniUI_MessageCneter and MiniUI_MessageCneter.IsShown() then
			MiniUI_MessageCneter.CloseUI()
		end
	end
end

-----------------------------------------------------------------------房间信息弹出框--------------------------------------
--点击房间条目:old:RoomBtn_OnClick()
function RoomFrameBtn_OnClick()
	Log("RoomFrameBtn_OnClick:");
	local roomDesc
	local roomCache = AllRoomManager.RoomsCache[this:GetClientUserData(0)]
	if roomCache and next(roomCache) ~= nil then
		if roomCache.type == AllRoomManager.RoomType.Normal then
			roomDesc = AccountManager:getIthRoom(roomCache.roomid-1);
		elseif roomCache.type == AllRoomManager.RoomType.CloudServer then
			roomDesc = AllRoomManager.CSRoomsList[roomCache.roomid]
		end
		if MiniStandInData and roomDesc ~= nil then	
			local cid = "0"
			if roomDesc.fromwid then
				cid = tostring(roomDesc.fromwid)
			elseif roomDesc.map_type then
				cid = roomDesc.map_type
			elseif roomDesc.owid then
				cid = tostring(roomDesc.owid)
			elseif roomDesc.wid then
				cid = tostring(roomDesc.wid)
			end
			--人数>6: PC大房间
			local roomType = "1"
			local uniqueCode = nil
			if roomDesc.isServer then
				roomType = "1"
			elseif roomDesc.maxplayers and roomDesc.maxplayers > 6 then
				roomType = "4"
			elseif roomDesc.extraData then
				local t_extra = JSON:decode(roomDesc.extraData)
				if t_extra then
					uniqueCode = t_extra.uniqueCode
					if t_extra.platform then
						-- PC服务器
						if t_extra.platform == 1 then
							roomType = "3"
						-- 手机服务器
						else
							roomType = "2"
						end
					end
				end
			end
			local roomName = ""
			if roomDesc.owneruin then
				roomName =  uniqueCode or getShortUin(roomDesc.owneruin);
			elseif roomDesc._k_ then
				roomName = roomDesc._k_
			end
			local tempTb = {
				cid = cid,
				standby1 = "1"..roomType,
				standby2 = roomName
			}
			if this:GetClientUserData(0) then
				tempTb.slot = tostring(this:GetClientUserData(0))
			else
				tempTb.slot = "1"
			end
			--数据埋点 1 联机综合内容 地图内容卡 click
			if mIsOpenMapFrame then
				standReportEvent("10", "MINI_MUTIPLAYERLOBBY_SPECCON_1", "SmallMapCard", "click",tempTb)
			else
				if mRoomFrameVar.CurLeftBtnIndex and mRoomFrameVar.CurLeftBtnIndex > 0 and mRoomFrameVar.CurLeftBtnIndex < 9 then
					standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+mRoomFrameVar.CurLeftBtnIndex], "SmallMapCard", "click",tempTb)
				else
					standReportEvent("10", reportCardName[(mIsOpenMapFrame and 8 or 0)+1], "SmallMapCard", "click",tempTb)
				end
			end   
		end
	end
	   
	AllRoomManager:ShowRoomDetail(this:GetClientUserData(0),mIsOpenMapFrame,mRoomFrameVar.CurLeftBtnIndex)
end

function RoomFrameInfoCloseBtn_OnClick()
	local id = this:GetClientID()
	if id and id == 1 then
		-- 普通联机房间简介-关闭（房间简介）按钮上报 by fym
		standReportEvent("11", "MINI_MLMAP_INTRO_1", "Close", "click")
	else
		-- 普通联机房间简介-点击空白处关闭房间简介上报 by fym
		standReportEvent("11", "MINI_MLMAP_INTRO_1", "MarginClick", "click")
	end	
	getglobal("RoomFrameInfo"):Hide();
end

--举报
function RoomFrameInfoIntroduceReportBtn_OnClick()
	
	local roomDesc = AccountManager:getIthRoom(CurChooseRoomIdx - 1)
	ReportNormalRoom(roomDesc)
end

function ReportNormalRoom(roomDesc)
	-- by fym
	local cid = 0
	if roomDesc then 		
		if roomDesc.fromowid and roomDesc.fromowid > 0 then 			
			cid = tostring(roomDesc.fromowid) 		
		elseif roomDesc.owid and roomDesc.owid > 0 then 			
			cid = tostring(roomDesc.owid) 		
		elseif roomDesc.wid and roomDesc.wid > 0 then 			
			cid = tostring(roomDesc.wid) 		
		elseif roomDesc.map_type then 			
			cid = roomDesc.map_type 		
		end 	
	end
	-- 普通联机房间简介-点击举报按钮上报 by fym
	standReportEvent("11", "MINI_MLMAP_INTRO_1", "MapReport", "click", {cid = tostring(cid)})

	if not roomDesc then return end
	if not roomDesc.isServer then
		--不是服务器房间才可以举报
		local title1 = GetS(10517)
		local title2 = "#c1ec832" .. GetS(10569)
		local title = title1 .. title2
		-- InformControl:AddInformInfo(106, roomDesc.owneruin, nil, roomDesc.map_type, title):Enqueue();

		GetInst("ReportManager"):OpenReportView({
			tid = GetInst("ReportManager"):GetTidTypeTbl().room,
			op_uin = roomDesc.owneruin,
			wid = roomDesc.map_type,
		})
	else
		-- InformControl:NewInformInfoBuilder()
		-- :SetTid(101)
		-- :SetOpUin(roomDesc.map_type % (2^32))
		-- :SetWid(roomDesc.map_type)
		-- :Enqueue();
		GetInst("ReportManager"):OpenReportView({
			tid = GetInst("ReportManager"):GetTidTypeTbl().map,
			op_uin = roomDesc.map_type % (2^32),
			wid = roomDesc.map_type,
		})
	end

	
end

-- 普通联机房间简介显示时上报 by fym
function RoomFrameInfo_ReportShowEvent()
	local cid = 0
	if CurChooseRoomIdx ~= 0 then
		local roomDesc = AccountManager:getIthRoom(CurChooseRoomIdx-1);
		if roomDesc then 		
			if roomDesc.fromowid and roomDesc.fromowid > 0 then 			
				cid = tostring(roomDesc.fromowid) 		
			elseif roomDesc.owid and roomDesc.owid > 0 then 			
				cid = tostring(roomDesc.owid) 		
			elseif roomDesc.wid and roomDesc.wid > 0 then 			
				cid = tostring(roomDesc.wid) 		
			elseif roomDesc.map_type then 			
				cid = roomDesc.map_type 		
			end 	
		end
	end
	-- 显示时需上报的控件（联机房间简介界面以及关闭、举报、收藏、查看地图详情、加入地图按钮）
	local ReportGroup = {
		["RoomFrameInfo"] = {oID = "-"},
		["RoomFrameInfoCloseBtn"] = {oID = "Close", cid = false},
		-- ["ReportBtn"] = {oID = "MapReport"}, -- 举报按钮在OnShow时上报
		["CollocBtn"] = {oID = "MapCollect"},
		["GotoMapBtn"] = {oID = "Maplookup"},
		["StartGameBtn"] = {oID = "JoinButton"},
	}

	local uiname = ""
	local parent = "RoomFrameInfoIntroduce"
	local getglobal = getglobal;
	for key, value in pairs(ReportGroup) do
		uiname = (value.oID == "-" or value.oID == "Close") and key or parent..key
		if getglobal(uiname):IsShown() then
			-- 普通联机房间简介-显示房间详情界面上报 by fym
			if value.cid ~= nil and not value.cid then
				standReportEvent("11", "MINI_MLMAP_INTRO_1", value.oID, "view")
			else
				standReportEvent("11", "MINI_MLMAP_INTRO_1", value.oID, "view", {cid = tostring(cid)})
			end			
		end
	end
end

function RoomFrameInfo_OnShow()
	-- 普通联机房间简介显示时需上报 by fym
	RoomFrameInfo_ReportShowEvent()
	
	UpdateRoomFrameInfo();
	this:AddLevelRecursive()
end

function RoomFrameInfo_OnHide()

end


-- 展示提示次数，超过两次不用提示，退出房间或重新登陆重置。
local openRoomShowPingNum = 0
function RoomFrameSetOpenRoomShowPingNum(num)
	openRoomShowPingNum = 0
end
function local_SetCurZBInfo(cid)
	-- 快手等外部引流到联机大厅导致的进入地图的消费需要特殊处理
	local external_state,external_t_scheme,external_map = GetInst("ExternalRecommendMgr"):GetJumpRoomFrameInfo()
	if external_state then--此时的联机大厅页面是从跳转页跳过来的
		--当前打算进入的地图和推荐的地图是同一个地图，且是从推荐页进入的联机大厅
		if external_t_scheme and tostring(external_t_scheme.zb_wid) == tostring(cid) then
			--进游戏之前的环境设置，表明这是从快手推荐页进入的游戏
			GetInst("ExternalRecommendMgr"):SetCurZBInfo(external_map.owid, external_t_scheme, external_map.share_version)
		end
	end
end
--加入房间
function RoomFrameInfoStartGameBtn_OnClick()
	local teamupSer = GetInst("TeamupService")
	if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
		ShowGameTips(GetS(26045))
		return
	end
	EnterMainMenuInfo.EnterMainMenuBy = 'multiplayer'
	EnterMainMenuInfo.RoomCurLabel = mRoomFrameVar.CurLeftBtnIndex;
	--[[
	if CurChooseRoomIdx ~= 0 then
		if ClientMgr:getNetworkState() == 2 then
			RoomUseDataTips(2);
		else
			getglobal("RoomFrameInfo"):Hide();
			JoinRoom();
		end
	end
	]]

	-- stanby1：由两位数组成 by fym
	-- stanby1_1：十分位-1：公开房间；2-好友协作
	-- stanby1_2：个位-1：迷你云服；2：手机服务器（手机端）；3：PC服务器（PC端） 4：PC大房间（房间人数大于6）
	local stanby1_1, stanby1_2 = "", ""
	-- 加入网络延迟判断
	local cid = 0
	if CurChooseRoomIdx ~= 0 then
		local roomDesc = AccountManager:getIthRoom(CurChooseRoomIdx-1);
		if roomDesc == nil then return end
		-- by fym
		local roomCache
		if roomDesc then 		
			if roomDesc.fromowid and roomDesc.fromowid > 0 then 			
				cid = tostring(roomDesc.fromowid) 		
			elseif roomDesc.owid and roomDesc.owid > 0 then 			
				cid = tostring(roomDesc.owid) 		
			elseif roomDesc.wid and roomDesc.wid > 0 then 			
				cid = tostring(roomDesc.wid) 		
			elseif roomDesc.map_type then 			
				cid = roomDesc.map_type 		
			end

			-- 房间模式 connect_mode = 0:公开房间 , 1:协作模式
			if roomDesc.connect_mode then			
				stanby1_1 = roomDesc.connect_mode + 1
			end

			--人数>6: PC大房间
			if roomDesc.maxplayers and roomDesc.maxplayers > 6 then
				stanby1_2 = 4
			elseif roomDesc.extraData then
				local t_extra = JSON:decode(roomDesc.extraData)
				if t_extra then
					if t_extra.platform then
						-- PC服务器
						if t_extra.platform == 1 then
							stanby1_2 = 3
						-- 手机服务器
						else
							stanby1_2 = 2
						end
					end
				end
			end
		end

		if roomDesc.lastPing then
			local pingms = roomDesc.lastPing
			if pingms then 
				Log("RoomFrameInfoStartGameBtn_OnClick:" .. tostring(pingms)..",openRoomShowPingNum:"..tostring(openRoomShowPingNum))
			else
				Log("RoomFrameInfoStartGameBtn_OnClick:nil,openRoomShowPingNum:"..tostring(openRoomShowPingNum))
			end 
			if pingms >= 400 or pingms <= 0 and openRoomShowPingNum < 2 then -- 网路差
				MessageBox(5,GetS(25839),function(str)
					if str == "left" then
						local_SetCurZBInfo(cid)
						AllRoomManager:EnterRoom(nil, false)
						ShowGameTips(GetS(25840))
					else
						openRoomShowPingNum = openRoomShowPingNum + 1
					end
				end)
			else
				local_SetCurZBInfo(cid)
				AllRoomManager:EnterRoom(nil, false)
			end
		end
	end
		
	-- 普通联机房间简介-点击进入地图按钮在Loing界面显示时上报 by fym
	EnterMapReport = {
		sceneid="11",
		cardid="MINI_MLMAP_INTRO_1",
		compid="JoinButton",		
		slot = CurChooseRoomIdx,
		cid = tostring(cid),
		standby1 = tostring(stanby1_1)..stanby1_2
	}
	InsertStandReportGameJoinParamArg({
		sceneid="11",
		cardid="MINI_MLMAP_INTRO_1",
		compid="JoinButton",
		standby1 = EnterMapReport.standby1,slot = CurChooseRoomIdx})
	-- 普通联机房间简介-点击加入房间按钮上报 by fym
	standReportEvent("11", "MINI_MLMAP_INTRO_1", "JoinButton", "click", {cid = tostring(cid)})
	
	GetInst("ReportGameDataManager"):NewGameJoinParam("11","MINI_MLMAP_INTRO_1","JoinButton")
	GetInst("ReportGameDataManager"):SetCId(cid)
	GetInst("ReportGameDataManager"):SetJoinSlot(CurChooseRoomIdx)

end

--收藏按钮:
function RoomFrameInfoIntroduceCollocBtn_OnClick()
	Log("RoomFrameInfoIntroduceCollocBtn_OnClick:");

	if CurChooseRoomIdx ~= 0 then
		RoomBtnCollect_OnClick(CurChooseRoomIdx);
		RoomFrameInfo_CollocBtnState(CurChooseRoomIdx);
	end
end

--收藏按钮状态设置
function RoomFrameInfo_CollocBtnState(id)
	Log("RoomFrameInfo_CollocBtnState:");
	if id > 0 then
		Log("id = " .. id);
		local roomDesc = AccountManager:getIthRoom(id-1);
		local AccountData = AccountManager:getAccountData();
		local btnUI = "RoomFrameInfoIntroduceCollocBtn";
		local btnName = getglobal(btnUI .. "Name");
		local icon = getglobal(btnUI .. "Icon");

		if AccountData ~= nil and roomDesc then
			if AccountData:isCollectUin(roomDesc.owneruin) then
				--已经收藏
				icon:SetTexUV("icon_like_h");
			else
				icon:SetTexUV("icon_like_n");
			end
		end
	end
end

function UpdateRoomFrameInfo()
	local getglobal = getglobal;
	if CurChooseRoomIdx ~= 0 then
		local roomDesc = AccountManager:getIthRoom(CurChooseRoomIdx-1);
		if roomDesc == nil then return end

		local uin	= getglobal("RoomFrameInfoIntroduceUin");
		local icon 	= getglobal("RoomFrameInfoIntroduceIcon");
		local roleName	= getglobal("RoomFrameInfoIntroduceRoleName");
		local roleIcon  = getglobal("RoomFrameInfoIntroduceIcon")
		local roleIconFrame  = getglobal("RoomFrameInfoIntroduceIconFrame")
		local tagIcon	= getglobal("RoomFrameInfoIntroduceTagIcon");
		local tag	= getglobal("RoomFrameInfoIntroduceTag");
		local desc 	= getglobal("RoomFrameInfoIntroduceDesc");
		local pic 	= getglobal("RoomFrameInfoIntroducePic");
		local uiVipIcon1 = getglobal("RoomFrameInfoIntroduceVipIcon1");
		local uiVipIcon2 = getglobal("RoomFrameInfoIntroduceVipIcon2");
		local quanxian = getglobal("RoomFrameInfoIntroducequanxian");
		local reportBtn = getglobal("RoomFrameInfoIntroduceReportBtn")

		uin:SetText( getShortUin(roomDesc.owneruin) );
		roleName:SetText(roomDesc.ownername);

		Update_RoomTagInfo(roomDesc.gamelabel,roomDesc.gametype,tagIcon,tag)
		--头像
		HeadCtrl:SetPlayerHeadByUin(roleIcon:GetName(),roomDesc.owneruin,roomDesc.ownericon,nil,roomDesc.hasAvatar);
		HeadFrameCtrl:SetPlayerheadFrameName(roleIconFrame:GetName(),roomDesc.ownericonframe);
		local filteredDesc = DefMgr:filterString(roomDesc.desc)
		desc:SetText(filteredDesc, 224, 220, 202);

		pic:SetTexture(mapservice.thumbnailDefaultTexture);
		if roomDesc.thumbnail_url~="" and roomDesc.thumbnail_md5~="" then
			local url_list = {roomDesc.thumbnail_url};
			local cache_file_path = RoomThumbnailDir..roomDesc.thumbnail_md5..roomDesc.thumbnail_ext;
			DownloadThumbnail(url_list, cache_file_path, pic:GetName(), roomDesc.thumbnail_md5);
		end

		local t_extra = JSON:decode(roomDesc.extraData);

		quanxian:Show();
		getglobal("RoomFrameInfoIntroducequanxiantitle"):Show();

		if t_extra and t_extra.limit ~= nil then
			quanxian:Show();
			getglobal("RoomFrameInfoIntroducequanxian"):Show();
			if t_extra.limit == 6 then
				quanxian:SetText(GetS(413));
				-- quanxian:SetTextColor(0,255,127);

			elseif t_extra.limit == 7 then
				quanxian:SetText(GetS(414));
				-- quanxian:SetTextColor(0,0,0);
			else
				quanxian:SetText(GetS(413));
			end
		end

		local vipinfo = nil;
		if t_extra and t_extra.vipType~=nil then
			vipinfo = {
				vipType = t_extra.vipType,
				vipLevel = t_extra.vipLevel,
				vipExp = t_extra.vipExp,
			};
		end

		local vipDispInfo = UpdateVipIcons(vipinfo, uiVipIcon1, uiVipIcon2);
		getglobal("RoomFrameInfoIntroduceRoleName"):SetPoint("left", "RoomFrameInfoIntroduceNameTitle", "left", 78+vipDispInfo.nextUiOffsetX, 0);

		--LLDO:新增
		--收藏按钮状态
		RoomFrameInfo_CollocBtnState(CurChooseRoomIdx);

		--举报按钮
		if roomDesc.isServer then
			reportBtn:Hide()
		else
			reportBtn:Show()
			-- by fym
			local cid = 0
			if roomDesc then 		
				if roomDesc.fromowid and roomDesc.fromowid > 0 then 			
					cid = tostring(roomDesc.fromowid) 		
				elseif roomDesc.owid and roomDesc.owid > 0 then 			
					cid = tostring(roomDesc.owid) 		
				elseif roomDesc.wid and roomDesc.wid > 0 then 			
					cid = tostring(roomDesc.wid) 		
				elseif roomDesc.map_type then 			
					cid = roomDesc.map_type 		
				end 	
			end
			-- 普通联机房间简介-显示举报按钮上报 by fym
			standReportEvent("11", "MINI_MLMAP_INTRO_1", "MapReport", "view", {cid = cid})
		end
	end
end

--查看地图, 从房间进入地图详情页
function RoomFrameInfoIntroduceGotoMapBtn_OnClick()
	Log("RoomFrameInfoIntroduceGotoMapBtn_OnClick:");

	getglobal("RoomFrameInfo"):Hide();

	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "RFIIGMB");

	local cid = 0
	if CurChooseRoomIdx ~= 0 then
		Log("CurChooseRoomIdx = " .. CurChooseRoomIdx);
		local roomDesc = AccountManager:getIthRoom(CurChooseRoomIdx-1);

		if roomDesc then
			-- by fym		
			if roomDesc.fromowid and roomDesc.fromowid > 0 then 			
				cid = tostring(roomDesc.fromowid) 		
			elseif roomDesc.owid and roomDesc.owid > 0 then 			
				cid = tostring(roomDesc.owid) 		
			elseif roomDesc.wid and roomDesc.wid > 0 then 			
				cid = tostring(roomDesc.wid) 		
			elseif roomDesc.map_type then 			
				cid = roomDesc.map_type 		
			end 

			Log("111:");
			local map_type = roomDesc.map_type;

			if map_type then
				--map_type就是owid, 拉取地图信息
				Log("map_type = " .. map_type);
				ShowMiniWorksMapDetailByMapID(map_type);
			end
		end
	end
	-- 普通联机房间简介-点击查看地图详情按钮上报 by fym
	standReportEvent("11", "MINI_MLMAP_INTRO_1", "Maplookup", "click", {cid = tostring(cid)})
end

--扫描二维码
function RoomFrameRoomLeftScanBtn_OnClick(hideReport)
	if not SdkManager:ShowCameraQRScanner() then
		ShowGameTips(GetS(4751), 3);
	end
	if not hideReport then
		standReportEvent("10", "MINI_MUTIPLAYERLOBBY_CONTAINER_1", "Scan_1", "click")
	end
	--[[TODOTest
	local t = {Type="joinroom", Time=AccountManager:getSvrTime(), RoomUin=2222, IsRoomOwner=0, PW=""};
	local jsonStr = JSON:encode(t);
	OnCameraQRScaned(0, jsonStr);
	--]]
end

function NewRoomBtn_OnClick(fromPlayerCenter)
	standReportEvent("10", "MINI_MUTIPLAYERLOBBY_CONTAINER_1", "MyContent", "click")
	local param = {}
	
	if fromPlayerCenter then
		param.spec = true
	end
	if HasUIFrame("CloudServerLobby") then
		GetInst("UIManager"):Close("CloudServerLobby")
	end
	GetInst("UIManager"):Open("CloudServerLobby",param)
	
	SetRoomFrameLevel(getglobal("CloudServerLobby"):GetFrameLevel() - 1)
	statistics_9500_handler.upData()
	mComeBackInlineState = 2 --进入云服
end

function NewSearchBtn_OnClick()
	-- standReportEvent("10", "MINI_MUTIPLAYERLOBBY_CONTAINER_1", "MyContent", "click")
	-- local param = {}
	-- if GetInst("NSearchPlatformService"):ABTestSwitch() then
		standReportEvent("54","SEARCH_ENTRY_NEW","SearchEntryNew","click",{standby1 = 10})
		GetInst('NSearchPlatformService'):ShowSearchPlatform()
		return
	-- end

	-- if HasUIFrame("MiniWorksFrameSearch") then
	-- 	GetInst("UIManager"):Close("MiniWorksFrameSearch")
	-- end

	-- RoomFrame_LeftBtnState(0)
	-- mRoomFrameVar.CurLeftBtnIndex = 0;
	
	-- getglobal("RoomFrameRightFrame"):Hide()
	-- GetInst("UIManager"):Open("MiniWorksFrameSearch", {isRoomCtrl = true})
	-- getglobal("MiniWorksFrameSearch"):SetFrameLevel(getglobal("MiniWorksFrameSearch"):GetFrameLevel()+1)
	-- statistics_9500_handler.upData()
	-- mComeBackInlineState = 2 --进入云服
end

function CloudServerPassWordFramePasswordEditOnEnterPressed()
	if HasUIFrame("CloudServerLobby") and getglobal("CloudServerLobby"):IsShown() then
		GetInst("UIManager"):GetCtrl("CloudServerLobby"):CloudServerPasswordEdit_OnEnterPressed();
	elseif IsRoomFrameShown() then

	end
end

function CloudServerPassWordFrameEnterBtn_OnClick()
	if HasUIFrame("CloudServerLobby") and getglobal("CloudServerLobby"):IsShown() then
		GetInst("UIManager"):GetCtrl("CloudServerLobby"):CloudServerPassWordFrameEnterBtn_OnClick();
	elseif IsRoomFrameShown() then
		local passwordframe = getglobal("CloudServerPassWordFrame")
		local key = passwordframe:GetClientString()

		local password = getglobal("CloudServerPassWordFramePasswordEdit"):GetText();
		local roomDesc = AllRoomManager:GetCSRoomDescByKey(key)
		print("CloudServerPassWordFrameEnterBtn_OnClick", roomDesc,password)
		ReqRoomCloudServerEnterRoom(roomDesc, password)
		passwordframe:Hide()
	end
end

------------------------------------------租赁服联机大厅筛选显示------------------------------------------

--租赁服房间入口控制类

function SetThumbnailBeginIndex(value)
	t_RoomDownThumbnail.beginIndex = value
end
function AddThumbnaillist(value)
	table.insert(t_RoomDownThumbnail.list,value)
end

function ClearRoomDownThumbnailInfo()
	t_RoomDownThumbnail = {
		beginIndex = 0,
		list = {},
	};
end

function ClearThumbnaillist()
	t_RoomDownThumbnail.list = {}
end


function HandleEventRoomFrame_UpdateRoom()
	if GetMiniWorksOneKeyEnterRoomState() == 1 then
		return;
	else
		SetMiniWorksOneKeyEnterRoomState(0);
	end

	local RoomFrame = getglobal("RoomFrame")
	local ComebackFrame = getglobal("ComeBackFrame") -- 新增回流处理流程
	if RoomFrame:IsShown() or (ComebackFrame and ComebackFrame:IsShown()) then
		Log("RoomFrame_OnEvent: GIE_UPDATE_ROOM");
		RoomCloseCircleFlag(1)

		if CurRoomListType == "Collect" then
			local ge = GameEventQue:getCurEvent();
			if ge.body.room.result == 1 then
				CurGetRoomNum = 0;
			elseif ge.body.room.result == 2 then
				--关注的房间暂时没有开
				Log("RoomFrame_OnEvent: Room_owners you follow are all on vacation now...")
				SetCurRoomListType("RoomLobby");
				ShowGameTips(GetS(151), 3);
				--左侧按钮选中状态切换到上一个按钮
				RoomFrame_LeftBtnState(mRoomFrameVar.LastBtnIndex);
			end
		elseif CurRoomListType == "Search" then
			return
		else
			local ge = GameEventQue:getCurEvent();
			if ge.body.room.result == 2 then
				local reason = ge.body.room.failreason;
				if reason == -3 then
					ShowGameTips(GetS(282), 3);
				else
					print("my_debug: 11111111111112")
					ShowGameTips(GetS(146).."("..reason..")", 3);
				end
			end
		end
		AllRoomManager:ClearAllRooms()
		AllRoomManager:UpdateNormalRooms()
		if mIsOpenMapFrame then
			--热门地图对应房间页面
			-- local owid
			-- 	if SearchSelectMapOwid ~= "" then
			-- 	owid = GetRoomCurChooseOwId();
			-- end
			-- if SearchSelectMapOwid == "" then
			-- 	AllRoomManager:ReqCSRoomlistByOwId(owid);
			-- else
			-- 	if not AllRoomManager:getReqFlag() then
			-- 		AllRoomManager:ReqCSRoomlistByOwIdAndUins(owid,SearchSelectMapOwid)
			-- 	end
			-- end
			ReqRoomFilter(0);
		else
			AllRoomManager:ReqCSRoomList(AccountManager:getCurGameType(), getglobal(mRoomRoomBoxUI), ShowNoRoomFrame)
		end
	end
end

function SomeRoomResultErrorTips(result, detailreason)
	local strTip = nil
	if result == 2 or result == 5 then
		strTip = GetS(146)
	elseif result == 10 then
		strTip = GetS(566)
	elseif result == 12 then
		strTip = GetS(568)
	elseif result == 13 then
		if detailreason == -3 then
			strTip = GetS(282)
		else
			strTip = GetS(4034, detailreason)
		end
	elseif result == 14 then
		strTip = GetS(8033)
	elseif result == 15 then
		strTip = GetS(573)
	elseif result == 16 then
		strTip = GetS(573)
	elseif result == 17 then
		strTip = GetS(3630)
	elseif result == 18 then
		strTip = GetS(10549) --敏感词
	end
	return strTip
end
local test = 2
function HandleEventRoomFrame_RsconnectResult()
	--test
	EnterWorld_ExtraSet("")
	local RoomFrame = getglobal("RoomFrame")
	local ComeBackFrame = getglobal("ComeBackFrame")
	-- local MiniworkSearchFrame = getglobal("MiniWorksFrameSearch")
	Log("room.lua:GIE_RSCONNECT_RESULT " .. t_autojump_service.play_together.anchorUin..GameEventQue:getCurEvent().body.roomseverdata.result );
	if t_autojump_service.play_together.anchorUin > 0 then return end

	if IsArchiveMapCollaborationMode() 
		or RoomFrame:IsShown() 
		or (HasUIFrame("CloudServerLobby") and getglobal("CloudServerLobby"):IsShown())
		or (ComeBackFrame and ComeBackFrame:IsShown())
		-- or (MiniworkSearchFrame and MiniworkSearchFrame:IsShown())
		or (getglobal("MapRoom") and getglobal("MapRoom"):IsShown())
		or (EnterHomeLandInfo and HomeLandInterativeStep and EnterHomeLandInfo.step == HomeLandInterativeStep.GET_ROOM_SERVER_CONFIG) 
		or (EnterHomeLandInfo and HomeLandInterativeStep and EnterHomeLandInfo.step == HomeLandInterativeStep.CONNECT_WORLD)
		or (EnterHomeLandInfo and HomeLandInterativeStep and EnterHomeLandInfo.step == HomeLandInterativeStep.CHECK_FOR_ROOM_CLIENT)
		or (GetMiniWorksOneKeyEnterRoomState() == 2) then
		if mIsLanRoom and getglobal("LoadLoopFrame"):IsShown() then
			Log("RoomFrame_OnEvent GIE_RSCONNECT_RESULT");
			RoomCloseCircleFlag()
		end

		local isMiniworksOneKeyEnterRoom = false;
		if GetMiniWorksOneKeyEnterRoomState() == 2 then
			SetMiniWorksOneKeyEnterRoomState(0);
			isMiniworksOneKeyEnterRoom = true;
		end

		local ge = GameEventQue:getCurEvent();
		local result = ge.body.roomseverdata.result;
		local detailreason = ge.body.roomseverdata.detailreason
		

		local roomDesc
		local roomCache = AllRoomManager.RoomsCache[AllRoomManager.CurrentChooseRoomIdx]
		if roomCache and next(roomCache) ~= nil then
			if roomCache.type == AllRoomManager.RoomType.Normal then
				roomDesc = AccountManager:getIthRoom(roomCache.roomid-1);
			elseif roomCache.type == AllRoomManager.RoomType.CloudServer then
				roomDesc = AllRoomManager.CSRoomsList[roomCache.roomid]
			end
			if mComeBackInlineState ~= 0 and result >= 9 then -- 回流联机
				StatisticComeBackFastIn(roomCache.type,roomDesc,result)
			end
		end

		if result ~= 3 and (EnterHomeLandInfo and HomeLandInterativeStep and EnterHomeLandInfo.step == HomeLandInterativeStep.GET_ROOM_SERVER_CONFIG) then
			EnterHomeLandInfo = {}
			HideHomeLandLoading(true)
			HomeLandTestLog("hfg test -- 家园获取房间服信息出错")
		end

		if result ~= 9 and EnterHomeLandInfo and HomeLandInterativeStep and EnterHomeLandInfo.step == HomeLandInterativeStep.CONNECT_WORLD then
			if 11 == result then
				ShowGameTips(GetS(567), 3);
				HomeLandTestLog("hfb test -- 联机需要密码")
				EnterHomeLandInfo.step = HomeLandInterativeStep.GET_ROOM_DESC
				getglobal("LinkRoomPassWordFrame"):Show();
				HideHomeLandLoading()
				return --重新输入密码
			else
				local strTip = SomeRoomResultErrorTips(result, detailreason)
				if strTip then
					ShowGameTips(strTip, 3)
				else
					ShowGameTips("@error at connect garden result:" .. result .. ", detailreason:" .. detailreason, 3)
				end
			end
			HomeLandTestLog("hfg test -- 家园联主机失败, 尝试单机查看")
			threadpool:delay(0.5, function()
				RequestEnterOthersHomeLandSingleMode(EnterHomeLandInfo.uin)
			end)
			return 
		end

		if result ~= 3 and (EnterHomeLandInfo and HomeLandInterativeStep and EnterHomeLandInfo.step == HomeLandInterativeStep.CHECK_FOR_ROOM_CLIENT) then
			EnterHomeLandInfo = {}
			HideHomeLandLoading(true)
			HomeLandTestLog("hfg test -- 家园获取房间服信息出错")
		end

		if result == 3 then
			if (EnterHomeLandInfo and HomeLandInterativeStep and EnterHomeLandInfo.step == HomeLandInterativeStep.GET_ROOM_SERVER_CONFIG) then
				EnterHomeLandInfo.step = HomeLandInterativeStep.CREATE_ROOM
				if IsInHomeLandMap() then
					ExitHomeLandAndTurnToNextOperate()
				else
					HomeLandCreateRoom()
				end
			elseif (EnterHomeLandInfo and HomeLandInterativeStep and EnterHomeLandInfo.step == HomeLandInterativeStep.CHECK_FOR_ROOM_CLIENT) then
				EnterHomeLandInfo.step = HomeLandInterativeStep.GET_ROOM_DESC
            	AccountManager:requestManorRoomInfoByUin(EnterHomeLandInfo.uin)
			end
			
			--切换房间服务器
			Log("lldo: result = 3");
			RoomCloseCircleFlag()
			--ReqRoomByOwId();
		elseif result == 2 or result == 5 then
			ShowGameTips(GetS(146), 3);
			GetInst("RoomMatchingManager"):RoomEnterFailed(nil, true, true, result) --网络不稳定 停掉自动匹配
		else
			local isAutoMatchingRoomHookTip = false
			local needShowLoadLoop = false

			local roomKey = nil
			if result >= 9 then
				if AccountManager.getCurConnectWorldHostUin then
					roomKey = AccountManager:getCurConnectWorldHostUin()
					if not roomKey and roomKey <= 0 then
						roomKey = nil
					end
				end 
			end
			
			if isMiniworksOneKeyEnterRoom and result > 9 and result <=18 then --没有加入房间成功的情况
				isAutoMatchingRoomHookTip, needShowLoadLoop = GetInst("RoomMatchingManager"):RoomEnterFailed(roomKey, nil, nil, result)
			elseif (not isMiniworksOneKeyEnterRoom) and result > 9 and result <=18 then
				local roomDesc = nil
				if roomKey then
					roomDesc = AllRoomManager:FindReqConnectRoom(roomKey)
				else
					roomDesc = AccountManager:getIthRoom(CurChooseRoomIdx-1);
				end
				reportGameJoinCallFailed1(result, roomDesc)
			end
			
			local ShowGameTips = _G.ShowGameTips
			if isAutoMatchingRoomHookTip then
				ShowGameTips = function() end
			end

			if result == 9 then
				--进入房间
				Log("lldo: result = 9");
				if EnterHomeLandInfo and HomeLandInterativeStep and EnterHomeLandInfo.step == HomeLandInterativeStep.CONNECT_WORLD then
					if IsInHomeLandMap() then
						ExitHomeLandAndTurnToNextOperate()
					else
						HomeLandJoinWorld()
					end
					return --家园特殊处理
				end

				if not AccountManager:requestJoinWorld() then
					ShowGameTips(GetS(146), 3);
					GetInst("RoomMatchingManager"):RoomEnterFailed(nil, true, true, result) --网络不稳定 停掉自动匹配					
					return;
				end

				-- fym 装扮换装改版需求：判断是否是从装扮详情页跳转至地图内，如果是则需要关闭装扮详情页和商城界面
				EnterGameFromShopSkinDisplay()

				-- if isMiniworksOneKeyEnterRoom then
					getglobal("MiniWorksFrame"):Hide();
					--详情页一键进入联机大厅，失败不做什么，成功则隐藏详情页面
					if HasUIFrame("ArchiveInfoFrameEx") and getglobal("ArchiveInfoFrameEx"):IsShown() then
						GetInst("UIManager"):Close("ArchiveInfoFrameEx")
					end
				-- end
				if IsUIFrameShown("CreatorFestival") then
					GetInst("UIManager"):Close("CreatorFestival")
				end

				local roomDesc = nil
				if roomKey then
					roomDesc = AllRoomManager:FindReqConnectRoom(roomKey)
				else
					roomDesc = AccountManager:getIthRoom(CurChooseRoomIdx-1);
				end

				RoomFrame:Hide();
				GetInst("UIManager"):Close("CloudServerLobby")
				ShowLoadingFrame(); --ShowLoadingFrame 会清AllRoomManager.ReqConnectRSRoom
				if EnterRoomType == GTSurviveGame then
					StatisticsTools:gameEvent("EnterSurviveWNum");
				elseif EnterRoomType == GTCreativeGame then
					StatisticsTools:gameEvent("EnterCreateWNum");
				elseif EnterRoomType == GTGameMakerGame then
					StatisticsTools:gameEvent("EnterGameMakerWNum");
				end
				StatisticsTools:gameEvent("EnterRoomNum");

				
				reportGameJoinCall(1,roomDesc)
				
				local tb = {}
				if roomDesc and roomDesc.map_type then
					tb.cid = tostring(roomDesc.map_type)
				end
				newlobby_SaveMapHistory(tb.cid)

				if roomDesc then
					-- 记录加入房间
					local gamelabel = AllRoomManager:GetRoomLabel(roomDesc.gamelabel,roomDesc.worldtype)
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
				-- statisticsGameEvent(633,"%d",networkState)
				-- statisticsGameEvent(634,"%d",delay / 1000)
			elseif result == 10 then
				RoomCloseCircleFlag()
				ShowGameTips(GetS(566), 3);
			elseif result == 11 then
				RoomCloseCircleFlag()

				local roomDesc = AccountManager:getIthRoom(CurChooseRoomIdx-1);
				if not roomDesc or not Room_Data.password_record[roomDesc.owneruin] then
					ShowGameTips(GetS(567), 3);
				end
				if not isAutoMatchingRoomHookTip then
					getglobal("LinkRoomPassWordFrame"):Show();
				end
			elseif result == 12 then
				RoomCloseCircleFlag()
				ShowGameTips(GetS(568), 3);
			elseif result == 13 then
				RoomCloseCircleFlag()
				-- local detailreason = ge.body.roomseverdata.detailreason;
				if detailreason == -3 then
					ShowGameTips(GetS(282), 3);
				else
					ShowGameTips(GetS(4034, detailreason), 3);
				end
			elseif result == 14 then
				RoomCloseCircleFlag()
				ShowGameTips(GetS(8033), 3);
			elseif result == 15 then
				RoomCloseCircleFlag()
				ShowGameTips(GetS(573), 3);
			elseif result == 16 then
				RoomCloseCircleFlag()
				ShowGameTips(GetS(573), 3);
			elseif result == 17 then
				RoomCloseCircleFlag()
				ShowGameTips(GetS(3630), 3);
			elseif result == 18 then
				RoomCloseCircleFlag()
				ShowGameTips(GetS(10549), 3); --敏感词
			else 
				local strTip = "@error room result:" .. result .. ", detailreason:" .. detailreason
				ShowGameTips(strTip, 3)
				Log(strTip)
			end
		end
		
		if needShowLoadLoop and result ~= 9 then
			ShowLoadLoopFrame(true, "RoomMatchingManager:needShowLoadLoop")
		end
		
		if result == 9 then
			--加入房间成功上报
			-- statisticsGameEvent(631)

			-- 新增冒险回归活动“联机模式”任务上报
			if GetInst("ComeBackSysConfig"):IsNeedReportEvent(4) then
				GetInst("ComeBackSysConfig"):RequestEvent(4)
			end

			local ComebackFrame = getglobal("ComeBackFrame") -- 新增回流进入房间成功处理流程
			if (ComebackFrame and ComebackFrame:IsShown()) then
				local cid = "0"
				if roomDesc then
					if roomDesc.owid and roomDesc.owid > 0 then
						cid = tostring(roomDesc.owid)
					elseif roomDesc.map_type then
						cid = roomDesc.map_type
					end
				end
				GetInst("UIManager"):GetCtrl("ComeBackFrame"):EnterRoomSuccess(result, cid)
			end	
			local MapRoomFrame = getglobal("MapRoom")
			if (MapRoomFrame and MapRoomFrame:IsShown()) then
				local cid = "0"
				if roomDesc then
					cid = roomDesc.map_type
				end
				GetInst("UIManager"):GetCtrl("MapRoom"):EnterRoomSuccess(result, cid)
			end		
		elseif result > 9 then
			--加入房间失败上报
			-- statisticsGameEvent(632,"%d",result)

			local ComebackFrame = getglobal("ComeBackFrame") -- 新增回流进入房间失败处理流程
			   if (ComebackFrame and ComebackFrame:IsShown()) then
				local cid = "0"
				if roomDesc then
					if roomDesc.owid and roomDesc.owid > 0 then
						cid = tostring(roomDesc.owid)
					elseif roomDesc.map_type then
						cid = roomDesc.map_type
					end
				end
				GetInst("UIManager"):GetCtrl("ComeBackFrame"):EnterRoomFail(result, cid)
			end
			
			local MapRoomFrame = getglobal("MapRoom")
			if (MapRoomFrame and MapRoomFrame:IsShown()) then	
				local cid = "0"
				if roomDesc then
					cid = roomDesc.map_type
				end
				GetInst("UIManager"):GetCtrl("MapRoom"):EnterRoomFail(result, cid)
			end		
		end
	else
		local ge = GameEventQue:getCurEvent()
		if ge.body.roomseverdata.result == 23 then
			--房主被举报，无法创建房间（暂时只是提示，依旧可以创建）
			RoomCloseCircleFlag()
			local ext_info = ge.body.roomseverdata.detailreason
			if ext_info then
				if ext_info == 0 or ext_info == 1 then
					ShowGameTips(GetS(10567), 3)
				else
					--时间戳
					local utimetable = os.date("!*t",ext_info)
					ShowGameTips(GetS(10572,utimetable.year,utimetable.month,utimetable.day + 1))
				end
			else
				ShowGameTips(GetS(10567), 3)
			end
		elseif ge.body.roomseverdata.result == 29 then
			RoomCloseCircleFlag()
			ShowGameTips(GetS(10641), 3)
		elseif ge.body.roomseverdata.result == 30 then
			RoomCloseCircleFlag()
			ShowGameTips(GetS(10639), 3)
		elseif ge.body.roomseverdata.result == 31 then
			RoomCloseCircleFlag()
			ShowGameTips(GetS(10638), 3)
		elseif ge.body.roomseverdata.result == 32 then
			RoomCloseCircleFlag()
			ShowGameTips(GetS(3633), 3)
		elseif ge.body.roomseverdata.result == 33 then
			RoomCloseCircleFlag()
			ShowGameTips(GetS(10640), 3)
		elseif ge.body.roomseverdata.result == 34 then
			RoomCloseCircleFlag()
			ShowGameTips(GetS(10642), 3)
		elseif ge.body.roomseverdata.result == 35 then
			RoomCloseCircleFlag()
			ShowGameTips(GetS(4028), 3)
		elseif ge.body.roomseverdata.result == 36 then
			RoomCloseCircleFlag()
			ShowGameTips(GetS(10649), 3)
		elseif ge.body.roomseverdata.result == 37 then
			RoomCloseCircleFlag()
			ShowGameTips(GetS(3641), 3)
		end
	end
end
--回流联机房快速联机埋点
function StatisticComeBackFastIn(roomtype, RoomDesc,Result)
	if RoomDesc then
		local multiGameLabel = EnterSurviveGameInfo.StatisticsData.MultiGameLabel or 0;
		local uin, tag, maptype, owid, gamelabel, roomid
		--_k_存在即云服
		if AllRoomManager.RoomType.CloudServer == roomtype then
				maptype = 1
				uin, roomid = getRoomUinAndRoomID(RoomDesc._k_)
				owid = RoomDesc.wid
				tag = multiGameLabel
				gamelabel = RoomDesc.worldtype --AllRoomManager:GetRoomLabel(RoomDesc.label, RoomDesc.worldtype)
		elseif AllRoomManager.RoomType.Normal == roomtype then
				if RoomDesc.isserver then
					maptype = 2
				else
					maptype = 3
				end
				uin = RoomDesc.owneruin
				owid = RoomDesc.owid  
				tag = multiGameLabel 	-- AllRoomManager:GetRoomLabel(RoomDesc.gamelabel, RoomDesc.gametype)
				roomid = RoomDesc.owneruin
				gamelabel = RoomDesc.gametype 
		else
				--数据错误
		end
		if uin then
			statisticsGameEventNew(1037,tostring(get_game_lang()),tag,uin,maptype,owid,gamelabel,roomid,Result)
		end
	end
end
--回流联机房快速联机埋点
function StatisticComeBackCreateGame( worldInfo,result)
	if worldInfo then
		local multiGameLabel = EnterSurviveGameInfo.StatisticsData.MultiGameLabel or 0;
		local uin, tag, maptype, owid, gamelabel, roomid
		maptype = 3
		uin = worldInfo.owneruin
		owid = worldInfo.worldid
		tag = multiGameLabel		--GetLabel2Owtype(worldInfo.worldtype)
		roomid = worldInfo.owneruin
		gamelabel = worldInfo.worldtype
		if uin then
			statisticsGameEventNew(1037,tostring(get_game_lang()),tag,uin,maptype,owid,gamelabel,roomid,result)
		end
	end
end

-- 未拉去服务器信息，2s进入大厅，列表则刷新空白页
-- 显示转圈标记
-- type:1 表示进入大厅  其他表示刷新标签页
local RoomOpenWaitType = 1;
function RoomshowCircleFlag(type)
	ShowLoadLoopFrame(true, "file:room -- func:RoomshowCircleFlag")
	RoomOpenWaitType = type
	RoomOpenWaitTime = ns_data.open_room_wait_time or 2
	getglobal("RoomFrameTimer"):Show()
end

local RoomOpenWaitTime = 2;
-- 倒计时？秒数后弹出单机模式选择
function RoomFrameTimer_OnLoad()
	this:setUpdateTime(1);
end

function RoomFrameTimer_OnShow()
	if ns_data.alone_tips_show == false then
		RoomOpenWaitTime = 5
	else
		RoomOpenWaitTime = ns_data.open_room_wait_time or 2
	end
end

-- 倒计时2s后还没有拉取到服务器信息则进入大厅
function RoomFrameTimer_OnUpdate()
	RoomOpenWaitTime = RoomOpenWaitTime - arg1;
	if RoomOpenWaitTime <= 0 then
		if getglobal("RoomFrameTimer"):IsShown() then
			if RoomOpenWaitType == 1 then
				RoomCloseCircleFlag(1)

				if ns_data.alone_tips_show == false then
					if not GetInst("GameHallDataManager"):CheckSupport() then
						ShowStandAloneTips()
					end
				else
					OpenRoomFrame()
					ShowNoRoomFrame(true)
				end
			elseif RoomOpenWaitType == 2 then
			elseif RoomOpenWaitType == 3 then
				RoomCloseCircleFlag()
				AllRoomManager:GetMapTypeRoomCache(mRootName):CleanCache()
				RefreshMapTypeRoomsUI()
			else
				--清空显示 
				AllRoomManager:ClearAllRooms()
				local row = math.ceil(AllRoomManager.listViewMaxNum / 2)
				AllRoomManager:InitAllRoomUIListViewFrame(row, getglobal(mRoomRoomBoxUI))

				ShowNoRoomFrame(true)
				RoomCloseCircleFlag()
			end
		end
	end
end

function RoomFrameTimer_OnHide()
end

-- 取消转圈标记，同时停止定时器
function RoomCloseCircleFlag()
	ShowLoadLoopFrame(false)
	getglobal("RoomFrameTimer"):Hide()
end

--------------------------------------------------------------------------------------------------------------
--联机动态列表
function RoomRoomBox_tableCellAtIndex(tableView, index)
	return AllRoomManager:UpdateAllRoomUIPartCell(index, getglobal(mRoomRoomBoxUI))
end

function RoomRoomBox_numberOfCellsInTableView(tableView)
	--新版地图式联机大厅需要AB开关的地方
	if not IsLan then
		return getglobal(mRoomRoomBoxUI):IsShown() and #(AllRoomManager.RoomsCache or {}) or 0
	else
		return #(AllRoomManager.RoomsCache or {})
	end
end

function RoomRoomBox_tableCellSizeForIndex(tableView, index)
	local colidx = math.mod(index, 2)
	return 10 + colidx * 533, 10, 523, 125
end

function RoomRoomBox_tableCellWillRecycle(tableView, cell)
	if cell then 
		cell:Hide() 
	end
end

---------------------MapTypeRooms func------------------------
function RoomFrameMapTypeRoomEnterBtn_OnClick()
	local teamupSer = GetInst("TeamupService")
	if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
        ShowGameTips(GetS(26045))
        return
    end

	local cidx = this:GetParentFrame():GetClientUserData(0)
	if cidx and MapTypeRoomsReport.reportInfos[cidx] then
		RoomFrame_SetQuickMatchReportInfo("10", ReportGetFilterMutCID(MapTypeRoomsReport.gamelabel), "JoinButton", MapTypeRoomsReport.reportInfos[cidx].slot)
	else
		RoomFrame_SetQuickMatchReportInfo("10", ReportGetFilterMutCID(MapTypeRoomsReport.gamelabel), "JoinButton")
	end
	local cardid = ReportGetFilterMutCID(MapTypeRoomsReport.gamelabel)
	InsertStandReportGameJoinParamArg({sceneid="10",cardid=cardid,compid="JoinButton", standby1 ="12"})
	MapTypeRoomsReport:ReportOne(cidx, cardid, "JoinButton")
	GetInst("ReportGameDataManager"):NewGameJoinParam("10",cardid,"JoinButton")

	local mapwid = this:GetParentFrame():GetClientString()
	if mapwid and mapwid ~= "" then
		EnterMainMenuInfo.RoomCurLabel = mRoomFrameVar.CurLeftBtnIndex;
		ArchiveInfoFrameTopFasterEnterOWBtn_OnClick(true, mapwid)
	end	
end

function RoomFrameMapTypeRoomBtn_OnClick()
	local mapwid = this:GetClientString()
	local cidx = this:GetClientUserData(0)
	MapTypeRoomsReport:ReportOne(cidx, "SmallMapCard", "click")
	if mapwid and mapwid ~= "" then
		ShowMapRoomByMapID(mapwid)
	end
end

function RefreshMapTypeRoomsUI() --本来想把cache当参数传进来的，但是为了保持list的回调里面数据来源写法一致，还是用get拿
    ClearThumbnaillist()
    RoomCloseCircleFlag()

    local uiFrame = getglobal(mRoomMapBoxUI)
    if not uiFrame then
        return
    end

	local rooms = AllRoomManager:GetMapTypeRoomCache(mRootName).cache
	local cacheLabel = AllRoomManager:GetMapTypeRoomCache(mRootName).cacheLabel
	local requestid = AllRoomManager:GetMapTypeRoomCache(mRootName).requestid
	if requestid and ReportMgr and ReportMgr.setExpInfo then
		ReportMgr:setExpInfo(nil,nil,requestid)
	end

	--计算cache的上报数据
	local reportInfos = {}
	for i, value in ipairs(rooms) do
		local reportInfo = {
			cid = value.map_type or "",
			slot = i,
			standby3 = value.room_count or 0,
		}
		table.insert(reportInfos, reportInfo)
	end

	MapTypeRoomsReport:Report()
	MapTypeRoomsReport:Reset()
	MapTypeRoomsReport:SetReportInfos(reportInfos, cacheLabel, requestid)

    local listWidth = uiFrame:GetRealWidth2()
    local listHeight = uiFrame:GetRealHeight2()

	MapTypeRoomsReport.locked = true
    uiFrame:initData(listWidth, listHeight, math.ceil(#rooms/2), 2, false)
	ShowNoMapTypeRoomFrame(#rooms == 0)
	MapTypeRoomsReport:Report(true)
	MapTypeRoomsReport.locked = false
end


function RoomMapTypeRoomBox_tableCellAtIndex(tableView, index)
    local i = index + 1
    --从缓存中取cell复用
    local templateName = "MapTypeRoomTemplate"
    local uiFrame = getglobal(mRoomMapBoxUI)
    local cell, uiIndex = uiFrame:dequeueCell(0)
    --没有可复用的，创建cell
    if not cell then
        local itemName = uiFrame:GetName() .. "Btn" .. uiIndex
        local tableViewName = uiFrame:GetName()
        cell = UIFrameMgr:CreateFrameByTemplate("Frame", itemName, templateName, tableViewName)
    end
    cell:Show()
    
    --根据数据刷新cell
	if not cell then
        return
    end

    local buttonname = cell:GetName()
    local roomDesc = AllRoomManager:GetMapTypeRoomCache(mRootName).cache[i]

	if roomDesc == nil then
		cell:Hide()
		cell:SetClientUserData(0,0)
	else
		MapTypeRoomsReport:ResetTick()
		MapTypeRoomsReport:Mark(i, true)
		cell:SetClientString(tostring(roomDesc.map_type))
		cell:SetClientUserData(0,i)
		local pic	= getglobal(buttonname.."Pic");

		local roomName 	= getglobal(buttonname.."RoomName");
		local tag 	= getglobal(buttonname.."Tag");
		local tagIcon   = getglobal(buttonname.."TagIcon");
		local count = getglobal(buttonname.."Count")

		local filteredRoomName = DefMgr:filterString(roomDesc.map_name)
		roomName:SetText(filteredRoomName)
		
		pic:SetTexture(mapservice.thumbnailDefaultTexture, true);
		if roomDesc.thumbnail_url and roomDesc.thumbnail_md5 and roomDesc.thumbnail_url ~= "" and roomDesc.thumbnail_md5 ~= "" then
			local url_list = {roomDesc.thumbnail_url};
			local cache_file_path = AllRoomManager.RoomThumbnailDir..roomDesc.thumbnail_md5..roomDesc.thumbnail_ext;

			DownloadThumbnail(url_list, cache_file_path, pic:GetName(), roomDesc.thumbnail_md5, 0.3);
		elseif roomDesc.thumbnail and roomDesc.thumbnail ~= "" then
			local thumbnail_ = g_download_root .. ns_advert.func.trimUrlFile(roomDesc.thumbnail)
			if  getFileExt( thumbnail_ ) == 'png' then
				thumbnail_ = thumbnail_ .. '_'    --png会进入玩家相册
			end
			ns_http.func.downloadPng( roomDesc.thumbnail, thumbnail_, nil, pic:GetName())
		end
		
		count:SetText("当前有".. roomDesc.room_count .. "个在线房间")

		if roomDesc.gamelabel then
			Update_RoomTagInfo(roomDesc.gamelabel, roomDesc.gametype, tagIcon, tag)
		elseif roomDesc.label then
			Update_RoomTagInfo(roomDesc.label, roomDesc.worldtype, tagIcon, tag)
		end
	end

    --返回cell
    return cell
end

function RoomMapTypeRoomBox_numberOfCellsInTableView(tableView)
	--新版地图式联机大厅需要AB开关的地方
	local rooms = AllRoomManager:GetMapTypeRoomCache(mRootName).cache
	return getglobal(mRoomMapBoxUI):IsShown() and #rooms or 0
end

function RoomMapTypeRoomBox_tableCellSizeForIndex(tableView, index)
	local colidx = math.mod(index, 2)
	return 10 + colidx * 533, 10, 523, 125
end

function RoomMapTypeRoomBox_tableCellWillRecycle(tableView, cell)
	if cell then 
		cell:Hide() 
		local cidx = cell:GetClientUserData(0)
		if cidx > 0 then
			MapTypeRoomsReport:Mark(cidx, false)
		end
	end
end



function standReportNormalComp()
	local tb1 = 
	{
		"-",
		"Close",
		"WiFiSwift"
	}
	for _, value in ipairs(tb1) do
		local tb = {}
		if value == "WiFiSwift" then
			local id = 2
			if mIsLanRoom then
				--局域网 --切换到--> 外网
				id = 1;
			end
			tb.button_state = tostring(id-1)
		end
		standReportEvent("10", "MINI_MUTIPLAYERLOBBY_TOP_1", value, "view",tb)
	end
	local tb2 = 
	{
		"Scan_1",
		"SearchBox",
		"KeyUpSearch",
		"SearchButton",
		"AllContent",
		"AdventureContent",
		"CreativeContent",
		"BattleContent",
		"ParkourContent",
		"PuzzleContent",
		"ElectronicContent",
		"OtherContent",
		"MyContent",
		"CreatRoom",
		"TeamPlay"
	}
	for _, value in ipairs(tb2) do
		standReportEvent("10", "MINI_MUTIPLAYERLOBBY_CONTAINER_1", value, "view")
	end
end



function RoomListView_OnMouseScrollPosition()
end

function RoomListView_OnMovieFinished()
	
end


function RoomMapListView_OnMouseScrollPosition()
	MapTypeRoomsReport:ResetTick()
end

function RoomMapListView_OnMovieFinished()	
	-- MapTypeRoomsReport:Report()
end

local mRoomFrameQuickMatchReportInfo = nil

function RoomFrame_SetQuickMatchReportInfo(sID, cID, oID, reportSlot, trace_id, alg_inter,request_id)
	mRoomFrameQuickMatchReportInfo = nil
	if sID and cID and oID then
		mRoomFrameQuickMatchReportInfo = {			
			sceneid = sID,
			cardid = cID,
			compid = oID,
			slot = reportSlot,
			trace_id = trace_id or "",
			alg_inter = alg_inter or "",
			requestid = request_id or "",
		}
	end
end

function RoomFrame_GetQuickMatchReportInfo()
	return mRoomFrameQuickMatchReportInfo
end

function RoomFrame_SetShowOpenLeftBtn(index)
	mRoomFrameVar.showLeftBtn = index;
end

function GetMapTypeRoomsReport()
	return MapTypeRoomsReport
end

function GetFilterType()
	return mFilterType
end

function SetFilterType(value)
	mFilterType = value
end

function CloseRoomFrame()
	getglobal("RoomFrame"):Hide()
	GetInst("MiniUIManager"):CloseUI("GameHallMainAutoGen")
	GetInst("MiniUIManager"):CloseUI("RecentlyPlayedAutoGen")
	GetInst("MiniUIManager"):CloseUI("TopicMapsAutoGen")
end

function OpenRoomFrame(callback, keepLastShow, inRoom, jumpParam)
	-- getglobal("RoomFrame"):Show()
	callback = callback or function() end
	if not IsRoomFrameShown() then
		local cb = function()
			CloseRoomFrame()
			RoomCloseCircleFlag()

			if not inRoom then
				if (ClientCurGame and ClientCurGame:isInGame()) or getglobal("LoadingFrame"):IsShown() then
					return
				end
			end
			callback()
			if not keepLastShow then
				pcall(function() GetInst("NSearchPlatformService"):HideSearchPlatform() end);	
			end
			if GetInst("GameHallDataManager"):CheckSupport() then
				if getglobal("MiniWorksFrame"):IsShown() then
					MiniWorksFrameCloseBtn_OnClick()
				end
				EnterMainMenuInfo.EnterMainMenuBy = 'multiplayer'
				ReportTraceidMgr:setTraceid("lobby")
				GetInst("GameHallDataManager"):OpenUI(keepLastShow, jumpParam)
				if NewbieGuideManager and NewbieGuideManager:IsSwitch() and GetInst("mainDataMgr"):GetSwitch() == false then
					if not NewbieGuideManager:GetGuideFinishFlag(NewbieGuideManager.GUIDE_FLAG_GO_HALL)  then
						NewbieGuideManager:SetGuideFinishFlag(NewbieGuideManager.GUIDE_FLAG_GO_HALL, true)
						NewbieGuideManager:SetGuideFlagByPos(NewbieGuideManager.GUIDE_FLAG_GO_HALL)
					end
				end
			else
				ReportTraceidMgr:setTraceid("lobby")
				getglobal("RoomFrame"):Show()
			end
		end
		
		if not GetInst("GameHallDataManager"):CheckBaseABKeySupport() or GetInst("GameHallDataManager"):IsCfgPulled() then
			cb()
		else
			GetInst("GameHallDataManager"):ReqCfg(3, cb)
		end
	else
		--pcall(function() GetInst("NSearchPlatformService"):HideSearchPlatform() end);	
		if jumpParam then
			if GetInst("MiniUIManager"):IsShown("GameHallMainAutoGen") then
				local ctrl = GetInst("MiniUIManager"):GetCtrl("GameHallMain")
				if ctrl and ctrl.JumpToSubPage then
					ctrl:JumpToSubPage(jumpParam)
				end
			end
		end
	end
end

function IsRoomFrameShown()
	-- getglobal("RoomFrame"):IsShown()
	return GetInst("MiniUIManager"):IsShown("GameHallMainAutoGen") or getglobal("RoomFrame"):IsShown()
end

function SetRoomFrameLevel(level)
	if getglobal("RoomFrame") then
		getglobal("RoomFrame"):SetFrameLevel(level)
	end

	--游戏大厅调整层级导致的问题太太太多了。。因此新版本不再支持外部设置FrameLevel。
	--如果有相关需求需要调整 可以联系 黄汝林
	-- local ctrl = GetInst("MiniUIManager"):GetCtrl("GameHallMain")
	-- if ctrl then
	-- 	ctrl:SetFrameLevel(level)
	-- end
end