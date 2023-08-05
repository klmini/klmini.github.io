
IsOpenTrack 	= true;

FastOnlineWID = 0;	--快速联机的存档ID

--保存当前选择地图存档的多语言json信息
curShareMapInfo = {
	--worldid = "";
	--multilangname = "";
	--multilangdesc = "";
};

MiniWorksMapShare_CurrentWid = 0;		--当前要分享的地图ID
local MiniWorksMapShare_CurrentUserUin = 0;	--:当前地图详情页的作者uin, 访问个人中心的时候用
local MiniWorksMapShare_CurrentMap = {};	--当前地图
local MiniWorksMap_CommentNumForOnce = 15;  --一次加载评论的条数
local gAchiveDataList = {}
local FristScreenshotRedTagTips = true;
local getglobal = _G.getglobal;


ArchiveAppealSwitch = true --存档解封申诉开关
IsCreatingColloborationModeRoom = false --正在创建好友联机房间


--地图详情页面使用mvc模式重构，为方便获取和赋local变量
function GetMiniWorksInfo(k)
	if k=="MiniWorksMapShare_CurrentWid" then
		return MiniWorksMapShare_CurrentWid
	elseif k=="MiniWorksMapShare_CurrentUserUin" then
		return MiniWorksMapShare_CurrentUserUin
	elseif k=="MiniWorksMapShare_CurrentMap" then
		return MiniWorksMapShare_CurrentMap
	elseif k=="MiniWorksMap_CommentNumForOnce" then
		return MiniWorksMap_CommentNumForOnce
	end
end
function SetMiniWorksInfo(k,v)
	if k=="MiniWorksMapShare_CurrentWid" then
		MiniWorksMapShare_CurrentWid=v
	elseif k=="MiniWorksMapShare_CurrentUserUin" then
		MiniWorksMapShare_CurrentUserUin=v
	elseif k=="MiniWorksMapShare_CurrentMap" then
		MiniWorksMapShare_CurrentMap=v
	elseif k=="MiniWorksMap_CommentNumForOnce" then
		MiniWorksMap_CommentNumForOnce=v
	end
end

-- function DownMapMaxNum() --下载存档的最大数量
-- 	if IsNoArchiveLimitUser() then
-- 		return 999
-- 	end
-- 	if IsNoArchiveLimitApiId() then
-- 		return 999;
-- 	end
-- 	return 20 + GetDeveloperDeltaArchiveNum() + GetBoughtArchiveNum()
-- end

-- function DownRecordMapMaxNum() --下载录像存档的最大数量
-- 	if IsNoArchiveLimitUser() then
-- 		return 999
-- 	end
-- 	if IsNoArchiveLimitApiId() then
-- 		return 999;
-- 	end
-- 	return 20 + GetDeveloperDeltaArchiveNum() + GetBoughtArchiveNum()
-- end

--下载存档的最大限制
function DownArchiveMaxNum( ... )
	if IsNoArchiveLimitUser() then
		return 999
	end
	if IsNoArchiveLimitApiId() then
		return 999
	end
	-- 新增审核账号扩充存档
	if IsUserOuterChecker(AccountManager:getUin()) then
		return 999
	end

	--从网页配置读取
	if ns_version and ns_version.downArchiveMaxNum then
		return tonumber(ns_version.downArchiveMaxNum)
	end
	return 50
end
--已下载的存档总数
function GetDownArchiveNum( ... )
	return AccountManager:getMyWorldList():getDownWorldNum() + AccountManager:getMyWorldList():getDownRecordNum()
end

function IsNoArchiveLimitUser( uId ) --迷你号2000以下的玩家不限制存档位
	--22.12.5开始游戏改版，存档位需求不设上限（实际999），关闭购买存档位功能
	if GetInst("mainDataMgr"):AB_NewArchiveLobbyMain() then
		return true
	end
	local uin = uId or AccountManager:getUin()
	return uin <= 2000
end

--22.12.5开始游戏改版，存档位需求不设上限（实际999），但是上传的限制还是要通过购买进行扩充
function IsNoArchiveLimitUserExt( uId ) --迷你号2000以下的玩家不限制存档位
	local uin = uId or AccountManager:getUin()
	return uin <= 2000
end

function IsNoArchiveLimitApiId( api ) --指定apiId不做存档位限制
	do return false end --PC测试的时候可以打开这里注释，走限制存档位流程
	-- local apiId = api or ClientMgr:getApiId()
	-- return (apiId == 999)
end

-------------------------------------------------GongNengFrame--------------------------------------------------------------
local isQQBlueVipBtnLongPressing = false;

function GongNengFrameQQBlueVipBtn_OnMouseEnter()
	if ClientMgr:isPC() then
		getglobal("VipQQBtnTipsPC"):Show();
	end
end

function GongNengFrameQQBlueVipBtn_OnMouseLeave()
	if ClientMgr:isPC() then
		getglobal("VipQQBtnTipsPC"):Hide();
	end
end

function GongNengFrameQQBlueVipBtn_OnMouseDown()
	isQQBlueVipBtnLongPressing = false;
end

function GongNengFrameQQBlueVipBtn_MouseDownUpdate()
	if arg1 > 0.7 and (not isQQBlueVipBtnLongPressing) then
		isQQBlueVipBtnLongPressing = true;
		getglobal("VipQQHelpTipsMobile"):Show();
	end
end

function GongNengFrameQQBlueVipBtn_OnClick()
	if ClientMgr:isPC() then
		ShowVipQQFrame();
	else
		if isQQBlueVipBtnLongPressing then
			isQQBlueVipBtnLongPressing = false;
		else
			ShowVipQQFrame();
		end
	end
end

function GongNengFrameExitBtn_OnClick()
	if RoomInteractiveData:IsSocialHallRoom() then
		standReportEvent("1003", "SOCIA_HALL_TOP", "Close", "click",{cid=G_GetFromMapid(), standby1=EnterSurviveGameInfo.StatisticsData.EnterTime});
	end
	GetInst("ExitGameMenuInterface"):ShowExit()
end

function GongNengFrameTeamBtn_OnClick()
	if RoomInteractiveData:IsSocialHallRoom() then
		local standby2 = nil
		local ctrl = GetInst("MiniUIManager"):GetCtrl("SocialRoomSimple")
		if ctrl then
			standby2 = ctrl:GetBubbleType()
		end
		local eventTb = {
			cid=G_GetFromMapid(),
			standby1=ClientCurGame:getNumPlayerBriefInfo()+1,
			standby2 = standby2,
		}
		standReportEvent("1003", "SOCIA_HALL_CONTAINER", "TeamButton", "click", eventTb);
	end
	RoomFrameBottomEnterTeam_OnClick(true)
end

function GongNengFrameVipBtnRefresh()
	if isQQGame() then  --qq大厅渠道
		getglobal("GongNengFrameQQBlueVipBtn"):Show();
		-- getglobal("MiniLobbyFrameTopQQBlueVipBtn"):Show();
		ShowMiniLobbyQQBlueVipBtn() --mark by hfb for new minilobby
		if VipQQ_CanTakeAnyReward() then
			getglobal("GongNengFrameQQBlueVipBtnNormal"):SetTexUV("gztq_icon02");
			getglobal("GongNengFrameQQBlueVipBtnPushedBG"):SetTexUV("gztq_icon02");
			getglobal("GongNengFrameQQBlueVipBtnUVAnimationTex"):Show();

			-- getglobal("MiniLobbyFrameTopQQBlueVipBtnNormal"):SetTexUV("gztq_icon02");
			-- getglobal("MiniLobbyFrameTopQQBlueVipBtnPushedBG"):SetTexUV("gztq_icon02");
			SetMiniLobbyQQBlueVipBtnBg("gztq_icon02","gztq_icon02") --mark by hfb for new minilobby
		else
			getglobal("GongNengFrameQQBlueVipBtnNormal"):SetTexUV("gztq_icon04");
			getglobal("GongNengFrameQQBlueVipBtnPushedBG"):SetTexUV("gztq_icon04");
			getglobal("GongNengFrameQQBlueVipBtnUVAnimationTex"):Hide();

			-- getglobal("MiniLobbyFrameTopQQBlueVipBtnNormal"):SetTexUV("gztq_icon04");
			-- getglobal("MiniLobbyFrameTopQQBlueVipBtnPushedBG"):SetTexUV("gztq_icon04");
			SetMiniLobbyQQBlueVipBtnBg("gztq_icon04","gztq_icon04") --mark by hfb for new minilobby
		end
	elseif ClientMgr:getApiId() == 109 then  --qq空间渠道
		getglobal("GongNengFrameQQBlueVipBtn"):Show();
		-- getglobal("MiniLobbyFrameTopQQBlueVipBtn"):Show();
		ShowMiniLobbyQQBlueVipBtn() --mark by hfb for new minilobby
		if VipQQ_CanTakeNewComerReward() then
			getglobal("GongNengFrameQQBlueVipBtnNormal"):SetTexUV("gztq_icon02_yellow");
			getglobal("GongNengFrameQQBlueVipBtnPushedBG"):SetTexUV("gztq_icon02_yellow");
			getglobal("GongNengFrameQQBlueVipBtnUVAnimationTex"):Show();

			-- getglobal("MiniLobbyFrameTopQQBlueVipBtnNormal"):SetTexUV("gztq_icon02_yellow");
			-- getglobal("MiniLobbyFrameTopQQBlueVipBtnPushedBG"):SetTexUV("gztq_icon02_yellow");
			SetMiniLobbyQQBlueVipBtnBg("gztq_icon02_yellow","gztq_icon02_yellow") --mark by hfb for new minilobby
		elseif VipQQ_CanTakeAnyReward() then
			getglobal("GongNengFrameQQBlueVipBtnNormal"):SetTexUV("gztq_icon06");
			getglobal("GongNengFrameQQBlueVipBtnPushedBG"):SetTexUV("gztq_icon06");
			getglobal("GongNengFrameQQBlueVipBtnUVAnimationTex"):Show();

			-- getglobal("MiniLobbyFrameTopQQBlueVipBtnNormal"):SetTexUV("gztq_icon06");
			-- getglobal("MiniLobbyFrameTopQQBlueVipBtnPushedBG"):SetTexUV("gztq_icon06");
			SetMiniLobbyQQBlueVipBtnBg("gztq_icon06","gztq_icon06") --mark by hfb for new minilobby
		else
			getglobal("GongNengFrameQQBlueVipBtnNormal"):SetTexUV("gztq_icon05");
			getglobal("GongNengFrameQQBlueVipBtnPushedBG"):SetTexUV("gztq_icon05");
			getglobal("GongNengFrameQQBlueVipBtnUVAnimationTex"):Hide();

			-- getglobal("MiniLobbyFrameTopQQBlueVipBtnNormal"):SetTexUV("gztq_icon05");
			-- getglobal("MiniLobbyFrameTopQQBlueVipBtnPushedBG"):SetTexUV("gztq_icon05");
			SetMiniLobbyQQBlueVipBtnBg("gztq_icon05","gztq_icon05") --mark by hfb for new minilobby
		end
	elseif IsShouQChannel(apiId) then
		
	else
		getglobal("GongNengFrameQQBlueVipBtn"):Hide();
		-- getglobal("MiniLobbyFrameTopQQBlueVipBtn"):Hide();
		HideMiniLobbyQQBlueVipBtn() --mark by hfb for new minilobby
	end
end

function GongNengFrameStoreGNBtn_OnClick()
	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3);
		return;
	end

	-- local newStoreFrame = getglobal("NewStoreFrame")
	-- if newStoreFrame:IsShown() then return end

	-- GongNengFrameMenuArrow_OnClick();

	-- newStoreFrame:Show();
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "GongNengStoreBtn");
	if GetInst("UIManager"):GetCtrl("Shop", "uiCtrlOpenList") then return end
	GongNengFrameMenuArrow_OnClick();
	ShopJumpTabView(1)

	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "GongNengStoreBtn");
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
		standReportEvent("1003", "MORE_TELESCOPIC_BAR", "Shop", "click")
	else
		standReportEvent("1001", "MORE_TELESCOPIC_BAR", "Shop", "click")
	end
end

function GongNengFrameFriendBtn_OnClick()
	GongNengFrameMenuArrow_OnClick();

	local friendFrame = getglobal("FriendFrame");
	if friendFrame:IsShown() then return end

	friendFrame:Show();
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "GongNengFriendBtn");
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
		standReportEvent("1003", "MORE_TELESCOPIC_BAR", "Friend", "click")
	else
		standReportEvent("1001", "MORE_TELESCOPIC_BAR", "Friend", "click")
	end
end

function GongNengFrameActivityGNBtn_OnClick()
	-- local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	-- print(debug.traceback());
	GongNengFrameMenuArrow_OnClick();
	--默认打开公告
	local SiftFrame = getglobal("SiftFrame")
	if SiftFrame:IsShown() then
		--opened
	else
		ActivityMainCtrl:Active(ActivityMainCtrl.def.type.sift,false)
	end

	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "GongNengActivityBtn");
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
		standReportEvent("1003", "MORE_TELESCOPIC_BAR", "Activity", "click")
	else
		standReportEvent("1001", "MORE_TELESCOPIC_BAR", "Activity", "click")
	end
end

--点击游戏资料图标, 打开连接
function GongNengFrameGamedataGNBtn_OnClick()
	--qq大厅版
	if isQQGamePc() then
		SdkManager:BrowserShowWebpage("http://mn.qq.com/app/gamedetail_inner.shtml?appid=10610");
	end

	--4399
	if ClientMgr:getApiId() == 121 then
		SdkManager:BrowserShowWebpage("http://news.4399.com/mnsj/");
	end

	--7k7k
	if ClientMgr:getApiId() == 122 then
		SdkManager:BrowserShowWebpage("http://news.7k7k.com/mnsj/?ss");
	end
end

function InteractiveGuideMarkFinish()
	print("InteractiveGuideMarkFinish")
	NewbieGuideManager:SetGuideFinishFlag(NewbieGuideManager.GUIDE_SINGLE_P2P, true)
	NewbieGuideManager:SetGuideFlagByPos(NewbieGuideManager.GUIDE_SINGLE_P2P)
end

function InteractiveBtn_obj_OnClick(...)
	InteractiveBtn_OnClick(...)

	if getglobal("InteractiveGuideFrame") then
		getglobal("InteractiveGuideFrame"):Hide()
		getglobal("InteractiveGuideFrame"):SetClientString("")
	end
	InteractiveGuideMarkFinish()
end

function Guide_InteractiveBtn_obj_OnClick(...)
	SetUndisturbedObjInGuide(true)
	InteractiveBtn_obj_OnClick(...)
	RoomUIBtnFunc2BtnName("SetBtn")
end

--打开交互界面
function InteractiveBtn_OnClick(type)
	if IsStandAloneMode() then return end
	-- statisticsGameEvent(1800)
	if getglobal("MapFrame"):IsShown() then
		getglobal("MapFrame"):Hide();
	end
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		return
	end
	if ClientCurGame:isInGame() then
		if AccountManager:getMultiPlayer() > 0 then	--房间
			if type and "faq" == type then
				--联机房间跳转faq
				if friendservice.enabled then
					getglobal("FriendFrame"):Show();
				else
					getglobal("FriendUIFrame"):Show();
				end
				getglobal("FriendUIFrameLeftAttention"):Show();
			else
				getglobal("RoomUIFrame"):Show();
			end
		else
			if friendservice.enabled then
				getglobal("FriendFrame"):Show();
			else
				getglobal("FriendUIFrame"):Show();
			end
			getglobal("FriendUIFrameLeftAttention"):Show();
		end
	else
		if friendservice.enabled then
			getglobal("FriendFrame"):Show();
		else
			getglobal("FriendUIFrame"):Show();
		end
		getglobal("FriendUIFrameLeftAttention"):Show();
	end
	if type == 'mobpush_friend_interface' then
		standReportEvent("9923", "BACKFLOW", "Friend", "view",{standby1 = 1,standby2=0});
	end
end

function InteractiveBtn_OnShow()
	if getglobal("InteractiveGuideFrame") then
		if getglobal("InteractiveGuideFrame"):GetClientString() == "InGuide" then
			getglobal("InteractiveGuideFrame"):Show()
			return
		end
		getglobal("InteractiveGuideFrame"):Hide()
		getglobal("InteractiveGuideFrame"):SetClientString("")
	end
	SetUndisturbedObjInGuide(false)
	if not NewbieGuideManager:GetGuideFinishFlag(NewbieGuideManager.GUIDE_SINGLE_P2P) and ClientMgr and ClientCurGame then
		if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() or not ClientCurGame:isHost(AccountManager:getUin()) then
			return
		end
		if 0 == AccountManager:getMultiPlayer() or not RoomInteractiveData:IsP2pSingleRoom() then
			return
		end
		if not getglobal("InteractiveGuideFrame") then
			return
		end
		standReportEvent("1003", "SINGLE_PLAYER_INTRODUCTION","-", "view")
		standReportEvent("1003", "SINGLE_PLAYER_INTRODUCTION","DoNotDisturb", "view")
		standReportEvent("1003", "SINGLE_PLAYER_INTRODUCTION","FollowAllowed", "view")
		GetInst("MessageBoxInterface"):dualBtnBox(
			GetS(28823),
			GetS(28824),
			GetS(28825),
			function(userData, btnType)
				if 0 == btnType then
					standReportEvent("1003", "SINGLE_PLAYER_INTRODUCTION","DoNotDisturb", "click")
				else
					standReportEvent("1003", "SINGLE_PLAYER_INTRODUCTION","FollowAllowed", "click")
				end
				
				getglobal("InteractiveGuideFrame"):Show()
				getglobal("InteractiveGuideFrame"):SetClientString("InGuide")
				RoomUIFrames_SetUndisturbed(btnType==0 and true or false)
				if RoomUIFrames_GetUndisturbed() then
					getglobal("InteractiveGuideFrameTipObjTip"):SetText(GetS(28827) , 67, 80, 82)
				else
					getglobal("InteractiveGuideFrameTipObjTip"):SetText(GetS(28826) , 67, 80, 82)
				end
			end
		)
		SurviveGame_AddQuitFunc(InteractiveGuideMarkFinish)
	end
end

function InteractiveBtn_OnHide()
	if getglobal("InteractiveGuideFrame") then
		getglobal("InteractiveGuideFrame"):Hide()
	end
end

function GongNengFrameSetGNBtn_OnClick()
	--placeBloclList(-220, 7, 50, -60, 47, 200);
	--GameSnapshot();
	--getglobal("SetMenuFrame"):Show();
	GetInst("ExitGameMenuInterface"):ShowExit()
end

function GongNengFrameRuleSetGNBtn_OnClick()
	local param = nil;
	if UGCModeMgr and UGCModeMgr:IsUGCMode() then
		param = {disableOperateUI = true}
	end
	GetInst("UIManager"):Open("DevTools", param)

	if IsUGCEditMode() then
		GetInst("UGCCommon"):StandReportEventUGCMain("MAIN_EDITING_SCENE", "DeveloperTool", "click")
	end
	-- GetInst("GuideMgr"):PushEvent(GuideCfg.Event.OpenMapSet)--引导屏蔽
	--if false then
	--	if getglobal("RuleSetFrame"):IsShown() then
	--		getglobal("RuleSetFrame"):Hide();
	--	else
	--		getglobal("RuleSetFrame"):Show();
	--	end
	--else
	--	--新页面.
	--	getglobal("NewRuleSetFrame"):Show();
	--end
end

function GongNengFramePluginLibBtn_OnClick()
	--打开插件库
	if EnableDeveloper then 
		if CurWorld and CurWorld.getOWID then 
			ArchiveInfoFrameEditModBtn_OnClick(CurWorld:getOWID())
		end 
	end 
end

function GongNengFrameModelLibBtn_OnClick()
	if not ResourceCenterNewVersionSwitch then
		getglobal("MapModelLibFrame"):Show();
	else
		-- statisticsGameEventNew(1112, 3);
		GetInst("ResourceDataManager"):SetIsFromLobby(ResourceCenterOpenFrom.FromMap)
		GetInst("UIManager"):Open("ResourceCenter",{UpdateView=true});
	end
	getglobal("GongNengFrameModelLibBtnRedTag"):Hide();

	statisticsUIInGame(30017, EnterRoomType);
end

function GongNengFrameScreenshotBtn_OnShow()
	if ClientCurGame:isInGame() and CheckCurMapIsOpen() then
		local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
		local id
		if worldDesc and worldDesc.realowneruin ~= nil and  worldDesc.realowneruin ~= AccountManager:getUin()  then
			id = worldDesc.fromowid
		else
			id = CurWorld:getOWID();
		end

		if ClientCurGame and ClientCurGame:isInGame() and G_GetFromMapid then
			id = G_GetFromMapid() -- 地图内以这个id为准
		end
		threadpool:work(function ()
			ReqMapInfo({id},function (maps)
				if not maps or #maps == 0 then
					getglobal("GongNengFrameScreenshotBtn"):Hide();
				end
			end)
		end)

	end
end

function GongNengFrameScreenshotBtn_OnClick()
	--新埋点
	local sceneID = "";
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
		sceneID = "1003";
	else--客机
		sceneID = "1001";
	end
	standReportEvent(sceneID, "MINI_GAMEOPEN_GAME_1", "ShareButton", "click")
	standReportEvent("9701", "SHAREBOX_MAP", "Mapshare", "click",{GetReportMapType()})

	-- if GetInst("CreditScoreService"):CheckLimitAction(GetInst("CreditScoreService"):GetTypeTbl().dynamic, GetInst("CreditScoreService"):GetSubTypeTbl().share_dynamic) then
	-- 	return
	-- end

	if IsStandAloneMode() then return end

	SetShareScene("GameScreenshot")
	
	--植树活动
	local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
	if worldDesc and (worldDesc.fromowid == 1752346657768 or CurWorld:getOWID()== 1752346657768) then
		Zhishu201803_out_share_OnClick();       --公益分享
		return
	end
	--血条地图等UI界面的显示与否成为了自定义ui功能的一部分，避免截图时HideAllFrame中的操作写死其显隐性所以这里注释掉
	-- HideAllUI();
	-- if GetInst("QQMusicPlayerManager") then
	-- 	GetInst("QQMusicPlayerManager"):HideUI();--隐藏音乐播放器浮窗
	-- end
	local id
	if worldDesc and worldDesc.realowneruin ~= nil and  worldDesc.realowneruin ~= AccountManager:getUin()  then
		id = worldDesc.fromowid
	else
		id = CurWorld:getOWID();
	end

	if ClientCurGame and ClientCurGame:isInGame() and G_GetFromMapid then
		id = G_GetFromMapid() -- 地图内以这个id为准
	end

	-- local shareUrl = GetDefaultShareUrl();
	-- local shareTitle = "";
	-- local shareContent = GetS(1505);
	--StartShareOnScreenshot('map', id, 2, shareUrl, shareTitle, shareContent);

	--游戏中调出界面时，显示鼠标
	-- if ClientCurGame:isInGame() then
	-- 	ClientCurGame:setOperateUI(true);
	-- end

	if FristScreenshotRedTagTips then
		getglobal("GongNengFrameScreenshotBtnRedTag"):Hide();
		FristScreenshotRedTagTips = false;
	end
    --if Android:IsAndroidChannel() or IsIosPlatform() then
	--else
	--非移动平台则调用这个函数
	local imgPath = ""
	local url = "http://www.miniworldgame.com/openMiniWorld.html?type=m&i=" .. tostring(id);
	local title = "";
	local content = GetS(1505);
	local name 
	if WorldMgr and WorldMgr.getCurWorldName then
		content = GetS(1506, WorldMgr:getCurWorldName());
		name = WorldMgr:getCurWorldName()
	end
	SetShareData(imgPath, url, title, content);

	local tShareParams = {};
	tShareParams.shareType = t_share_data.ShareType.MAP;
	tShareParams.fromowid = id;
	t_share_data:SetMiniShareParameters(tShareParams);
	
	ShareToDynamic:SetActionParameter(25,id); --设置游戏内动态分享的跳转参数
	GetInst("PlayerCenterDynamicsManager"):SetAction(25,id,name)
	local param={}
	param.from = 'map';
	param.author = AccountManager:getNickName()
	param.authorid = AccountManager:getUin()
	param.mapid = id;
	param.bInGame = true

	local bOpen = CheckCurMapIsOpen()
	if not bOpen then
		if GetInst("MapShareInterface"):isOpen() and AccountManager:getMultiPlayer() > 0 then
			if IsInHomeLandMap and IsInHomeLandMap() then
				GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/c_miniwork", "miniui/miniworld/c_minilobby"})
				GetInst("MiniUIManager"):OpenUI("MapDescShare", "miniui/miniworld/share", "MapDescShareAutoGen",param)
			else
				param.mission_type = 0
				GetInst("MapShareInterface"):OpenMapShare(param)
			end
		else
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/c_miniwork", "miniui/miniworld/c_minilobby"})
			GetInst("MiniUIManager"):OpenUI("MapDescShare", "miniui/miniworld/share", "MapDescShareAutoGen",param)
		end
	else
		threadpool:work(function ()
			ReqMapInfo({id},function (maps)
				if maps and #maps > 0 then
					local map = maps[1];
					param.mapid = map.name
					param.author = map.author_name
					param.authorid = getShortUin(map.author_uin)
					param.map = map;
					param.roomid = GetCurrentCSRoomId();
				end
				if GetInst("MapShareInterface"):isOpen() and AccountManager:getMultiPlayer() > 0 then
					if IsInHomeLandMap and IsInHomeLandMap() then
						GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/c_miniwork", "miniui/miniworld/c_minilobby"})
						GetInst("MiniUIManager"):OpenUI("MapDescShare", "miniui/miniworld/share", "MapDescShareAutoGen",param)
					else
						param.mission_type = 0
						GetInst("MapShareInterface"):OpenMapShare(param)
					end
				else
					GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/c_miniwork", "miniui/miniworld/c_minilobby"})
					GetInst("MiniUIManager"):OpenUI("MapDescShare", "miniui/miniworld/share", "MapDescShareAutoGen",param)
				end
			end)
		end)
	end
	-- StartNewMapScreenshotShare(id,shareUrl,shareTitle,shareContent)
	--end
end

function IsShowTakePhotoMode()
	return GetInst("MiniUIManager"):IsShown("main_cameraAutoGen")
end

function GongNengFrameOpenCameraModeBtn_OnClick()
	if PixelMapInterface:IsShowMiniMap() then return end
	GetInst("UIManager"):Close("TeamupMinFrame")
	GongNengFrame_ReportEventCameraButton("click")
	-- if GetInst("CreditScoreService"):CheckLimitAction(GetInst("CreditScoreService"):GetTypeTbl().dynamic, GetInst("CreditScoreService"):GetSubTypeTbl().photo_dynamic) then
	-- 	return	
	-- end
	GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/c_share_upgrade"})
	GetInst("MiniUIManager"):OpenUI("main_camera", "miniui/miniworld/share_upgrade", "main_cameraAutoGen")

	if RoomInteractiveData:IsSocialHallRoom() then
		local eventTb = {
			cid=G_GetFromMapid(),
		}
		standReportEvent("1003", "SOCIA_HALL_CONTAINER", "CameraButton", "click", eventTb);
	end
end

function GongNengFrameCameraModeTakePicBtn_OnClick()
	--新埋点
	local sceneID = "";
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
		sceneID = "1003";
	else--客机
		sceneID = "1001";
	end
	-- standReportEvent(sceneID, "MINI_GAMEOPEN_GAME_1", "ShareButton", "click")
	-- standReportEvent("9701", "SHAREBOX_MAP", "Mapshare", "click",{GetReportMapType()})

	if IsStandAloneMode() then return end

	SetShareScene("GameScreenshot")
	
	--植树活动
	local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
	if worldDesc and (worldDesc.fromowid == 1752346657768 or CurWorld:getOWID()== 1752346657768) then
		Zhishu201803_out_share_OnClick();       --公益分享
		return
	end
	--血条地图等UI界面的显示与否成为了自定义ui功能的一部分，避免截图时HideAllFrame中的操作写死其显隐性所以这里注释掉
	HideAllUI();

	local cameraNode = GetInst("MiniUIManager").uilist["main_cameraAutoGen"]
	if cameraNode and cameraNode.node then -- 隐藏拍照界面不重置视角,重置视角会导致截图出来视角错误
		cameraNode.node:setVisible(false)
	end

	if GetInst("QQMusicPlayerManager") then
		GetInst("QQMusicPlayerManager"):HideUI();--隐藏音乐播放器浮窗
	end
	local id
	if worldDesc and worldDesc.realowneruin ~= nil and  worldDesc.realowneruin ~= AccountManager:getUin()  then
		id = worldDesc.fromowid
	else
		id = CurWorld:getOWID();
	end

	local shareUrl = GetDefaultShareUrl();
	local shareTitle = "";
	local shareContent = GetS(1505);
	--StartShareOnScreenshot('map', id, 2, shareUrl, shareTitle, shareContent);

	--游戏中调出界面时，显示鼠标
	if ClientCurGame:isInGame() then
		ClientCurGame:setOperateUI(true);
	end

	-- if FristScreenshotRedTagTips then
	-- 	getglobal("GongNengFrameScreenshotBtnRedTag"):Hide();
	-- 	FristScreenshotRedTagTips = false;
	-- end
    --if Android:IsAndroidChannel() or IsIosPlatform() then
	--else
	--非移动平台则调用这个函数
	StartCameraModeScreenshotShare(id,shareUrl,shareTitle,shareContent)
	--end
	ShareToDynamic:SetActionParameter(25,id); --设置游戏内动态分享的跳转参数
	GetInst("PlayerCenterDynamicsManager"):SetAction(25,id)
end

-- 红包按钮展示逻辑判断-单机模式不显示红包按钮
function ShowGongNengFrameOpenRedPocket()
	-- 顶部红包按钮展示逻辑判断-非常驻红包按钮
	local result = GetInst("RedPocketService"):IsCurMapHaveRedPocketFunc()
	local isShowSecBtn = GetInst("RedPocketService"):IsCurMapShowSecEnterance()

	print("ShowGongNengFrameOpenRedPocket result = ", result, ", isShowSecBtn = ", isShowSecBtn)
	
	-- if AccountManager:getMultiPlayer() ~= 0 and result and isShowSecBtn then
	-- 	getglobal("GongNengFrameOpenRedPocket"):Show()
	-- 	standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "RedEnvelopeGet", "view")
	-- else
	-- 	getglobal("GongNengFrameOpenRedPocket"):Hide()
	-- end

	--UI编辑器开关控制
	local config = GetInst("RedPocketService"):GetLuaConfig();
	local redpaperBtn = getglobal("GongNengFrameOpenRedPocket");
	if 	AccountManager:getMultiPlayer() ~= 0 and config and config.switch == 1 and 
		check_apiid_ver_conditions(config) and 
		UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.REDPAPER)
	then
		redpaperBtn:Show();
		standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "RedEnvelopeGet", "view")
	else
		redpaperBtn:Hide();
	end

	-- 更多面版中的红包按钮展示逻辑判断-常驻红包按钮
	if AccountManager:getMultiPlayer() ~= 0 and result then
		getglobal("GongNengFrameRedPacketGNBtn"):Show()
	else
		getglobal("GongNengFrameRedPacketGNBtn"):Hide()
	end

	WolrdGameTopBtnLayout()
end

-- 发红包按钮- isNotCheckMapList 不校验白名单
function GongNengFrameOpenRedPocket_OnClick()
	standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "RedEnvelopeGet", "click")
	local result = GetInst("RedPocketService"):IsCurMapHaveRedPocketFunc()
	if result then
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/common_comp", "miniui/miniworld/moneyTips"})
		GetInst("MiniUIManager"):OpenUI("Main", "miniui/miniworld/RedPocket", "RedPocketAutoGen")
	end
end

--打开开发者认证外链
function OpenDeveloperLink(client, referer)
	-- if ClientMgr.isPC and ClientMgr:isPC() then
	-- 	open_http_link( "https://test-developer.mini1.cn/register/", "posting" );
	-- elseif IsIosPlatform()  then
	-- 	gFunc_openIOSOrAndroidBoxUrl("");
	-- else
	-- 	--安卓
	-- 	local s2_, s2t_, pure_s2t_ = get_login_sign()
	-- 	local url = "minibox://thirdlaunch.action?type=developer&uin="..AccountManager:getUin().."&sign="..s2_.."_"..pure_s2t_;
	-- 	gFunc_openIOSOrAndroidBoxUrl(url);
	-- end
	local  from_client = client or 0
	local web = ClientUrl:GetUrlString("HttpDeveloperCenter2")
	local url = "s4_https://"..web.."/register/?&portrait=1&from_client="..from_client
	if env==10 then
		local tmpUrl = ns_version.creator_indentify_overside and ns_version.creator_indentify_overside.webUrl
		web = (type(tmpUrl) == "string" and #tmpUrl > 0) and tmpUrl or web
	end
	-- if env == 1 then
	-- 	url = "s4_http://"..web.."/register/?&portrait=1&from_client="..from_client
	-- end
	
	if referer then 
		url = url .. "&referer=" .. referer
	end 
	
	local conn = _G.container.conn
	if conn and conn.token and conn.token ~= "" then
		url = url .. "&tk=" ..conn.token
	end
	if client == 2 then
		url = "s4_https://kfz.mini1.cn/create-center/#/official-news-details/17?openBrowser=3&portrait=2"
	end
	open_http_link( url);
end

-- 通过触发器打开开发者商城--需检验开发者认证
function ShowDeveloperStore(showByTrigger)
	openDeveloperStore(2) --此处打开的是玩法模式下的商店
	--[[
	local devshop_frame = getglobal("DeveloperStoreSkuFrame")
	if devshop_frame and not devshop_frame:IsShown() then 
		getglobal("DeveloperStoreSkuFrame"):Show()
	end
	--]]
end

-- 通过触发器打开开发者商城分类--需检验开发者认证
function ShowDeveloperStoreTab(page,name)
	-- openDeveloperStore(2) --此处打开的是玩法模式下的商店
	--xyang此处加入新接口，再删除上条老接口
	local pageList = {}
	local m = string.split(page, "#")
	if m[2] then
		local l = string.split(m[2], ",")
		for i = 1, #l do
			local str = l[i]
			local ll = string.split(str, "|")
			if #ll == 2 then
				local item = {}
				item.GroupID = tonumber(ll[1])
				item.Pos = tonumber(ll[2])
				table.insert(pageList, item)
			else
				print("format error!")
			end
		end
		if #pageList == 0 then
			print("format error!")
		end
		--print("result:"..pageList..name)
		--openDeveloperStoreNew(pageList,name)
		openDeveloperStore(2, pageList, name)
	end
end

-- xyang20220216 通过触发器打开商城接口
function TriggerShowDeveloperStore(bOpen)
	if ns_version.triggerStoreSwitch and check_apiid_ver_conditions(ns_version.triggerStoreSwitch) then--xyang20211227开关打开，屏蔽触发器打开开发者商城 
		if not bOpen then--xyang20220215特殊需求UI编辑器按钮按下松开消息可以打开开发者商城
			ShowGameTips(GetS(100801))
			--埋点
			local uin = AccountManager:getUin() or 0;
			local gameType = ClientCurGame:isHost(uin) and "1003" or "1001"--1001普通房间游戏是作为客机进入游戏  1003打开地图游戏是作为主机进入游戏（单机和作为房主开联机房间）
			local exData = {cid=tostring(GetFromMapid())}
			standReportEvent(gameType, "PROP_SHIELD_DETAILS", "-", "view", exData)
			return
		end
	end
	openDeveloperStore(2) --此处打开的是玩法模式下的商店
end

--CurWorld:isGameMakerMode()编辑模式
--CurWorld:isGameMakerRunMode()玩法模式
--openID 同于大数据上报区分来源 默认是游戏顶部商店按钮
function GongNengFrameDeveloperStoreBtn_OnClick(openID)
	--新埋点
	local sceneID = "";
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
		sceneID = "1003";
	else--客机
		sceneID = "1001";
	end
	standReportEvent(sceneID, "MINI_GAMEOPEN_GAME_1", "ShopEntranceButton", "click")

	if IsStandAloneMode() then return end
	if not CurWorld:isGameMakerMode() and not CurWorld:isGameMakerRunMode() then return end
	--数据埋点
	local openID = openID or 3
	-- statisticsGameEventNew(31027,openID)

	local mapId, uin = 0, AccountManager:getUin()
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then  --单机或房主
		local wdesc = AccountManager:getCurWorldDesc()
		if not wdesc then return end
		-- -- 以仅供学习模板的新地图屏蔽广告播放
		-- if wdesc and wdesc.TempType and wdesc.TempType == 1 and (wdesc.gwid > 0 and wdesc.pwid > 0) then
		-- 	if isEducationalVersion then
		-- 		ShowWebView_Edu()
		-- 	end
		-- 	ShowGameTips(GetS(34420),3)
		-- 	return
		-- end

		mapId = wdesc.fromowid
		if wdesc.fromowid == 0 then
			mapId = wdesc.worldid
		end

		ChangeRedPointRecords(uin, mapId)
		-- if getglobal("GongNengFrameDeveloperStoreBtnRedTag"):IsShown() then
		-- 	getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Hide()
		-- end
		
		local authorUin = getFromOwid(mapId)
		local isSelfDeveloper = false

		if authorUin == uin then
			--不做开发者判断，开发者和非开发者都可以进
			local ddiRet = AccountManager:dev_developer_info(uin);
			isSelfDeveloper = (ddiRet == ErrorCode.OK)
			
			--正式开发者才可以进
			local ret = GetInst("CreationCenterHomeService"):GetMyCreatorInfo()
			if not (ret and ret.idType==2) then--如果自己不是正式开发者
				if isEducationalVersion then
					ShowIdentificationDialog_Edu(ddiRet);
					return
				end
				
				if if_open_creator_creator_remind() then
					-- statisticsGameEventNew(31030,openID)
					MessageBox(32,GetS(21681),function(btn)
							if btn == 'right' then
								OpenDeveloperLink(2)

							end
						end
					)
				
				else
					MessageBox(4,GetS(21681))
				end
				return
			end
		elseif wdesc.passportflag ~= nil then
			if wdesc.passportflag == 0 then --有可能是老的开发者存档数据没有初始化，也有可能该作者不是开发者
				local ret = AccountManager:dev_developer_info(authorUin)--判断这个会缓存
				if ret == ErrorCode.OK then--是开发者
					AccountManager:syncWorldDesc(mapId, 2)
				elseif ret == ErrorCode.TIMEOUT then
					ShowGameTips(GetS(37))
					return
				else
					ShowGameTips(GetS(23023))
					return
				end
			end
		end

		if CurWorld:isGameMakerMode() then --编辑模式
			if authorUin == uin and isSelfDeveloper and not IsRoomOwner() then --是自己的地图并且是开发者并且是单机
				openDeveloperStore(1)
			else --不是自己的地图
				openDeveloperStore(2)
			end
		else --玩法模式
			openDeveloperStore(2)
		end
	else --客机
		mapId = DeveloperFromOwid

		local tmptype = WorldMgr and WorldMgr:getTempType() or 0
		local pwid = WorldMgr and WorldMgr:getWoldPwid() or 0
		if tmptype == 1 and pwid > 0 then
			if isEducationalVersion then
				ShowWebView_Edu()
			end			
			ShowGameTips(GetS(34420),3)
			return
		end

		ChangeRedPointRecords(uin, mapId)
		-- if getglobal("GongNengFrameDeveloperStoreBtnRedTag"):IsShown() then
		-- 	getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Hide()
		-- end

		local developerflag = CurWorld:getDeveloperFlag()
		if developerflag == 0 then
			local authorUin = getFromOwid(mapId)
			local ret = AccountManager:dev_developer_info(authorUin)--判断这个会缓存
			if ret == ErrorCode.TIMEOUT then
				ShowGameTips(GetS(37))
				return
			elseif ret ~= ErrorCode.OK then--不是开发者
				ShowGameTips(GetS(23023))
				return
			end
		end
		openDeveloperStore(2)
	end
end

-- 是否显示游戏内评论按钮
function IsShowCommentBtn(callback)
	CmtWorldDesc = nil
	
	if isEnableNewCommonSystem and isEnableNewCommonSystem() then
		if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) then--xyang自定义UI
			local owid = G_GetFromMapid()
			local worldDesc = AccountManager:findWorldDesc(owid)
			if worldDesc then 
				CmtWorldDesc = worldDesc
				
				if callback then 
					callback(CmtWorldDesc)
					
					return 
				end 
		
				if IsCanShowComment(CmtWorldDesc) then 
					WolrdGameTopBtnLayout()
				end
			else 
				if owid > 0 then
					ReqMapInfo({owid}, function(maps)
						if maps and #maps > 0 then
							CmtWorldDesc = CreateWorldDescFromMap(maps[1])
							
							if callback then 
								callback(CmtWorldDesc)
								
								return 
							end 
							
							if IsCanShowComment(CmtWorldDesc) then 
								WolrdGameTopBtnLayout()
							end
						end
					end)
				end
				
			end 
		end
	end
end

function IsCanShowComment(worldDesc)
	if worldDesc then
		local mapowneruin = worldDesc.owneruin
		local maprealowneruin = worldDesc.realowneruin
		local opensvr	= worldDesc.OpenSvr
		local worldopen = worldDesc.open
		local env_ = get_game_env()
		local isDownLoadMap = maprealowneruin ~= 0 and maprealowneruin ~= 1 and	mapowneruin ~= maprealowneruin

		local tagStatusIdx = nil
		
		--已上传和已保存状态
		if worldopen == 1 then
			tagStatusIdx = 0
		elseif worldopen == 2 then
			tagStatusIdx = 1
		end
		
		--待修改状态
		if env_ < 10 and worldopen == 1 and (not isDownLoadMap) and opensvr == 2 then
			tagStatusIdx = 4
		end
			
		--审核中状态
		if env_ < 10 and worldopen == 1 and (not isDownLoadMap) and opensvr == 0 then
			tagStatusIdx = 6
		end
		
		-- 已上传和已保存可以显示
		if tagStatusIdx == 0 or tagStatusIdx == 1 then 
			return true
		end 
		
		if isDownLoadMap then 
			return true
		end 
		
		return false
	end
	
	return false
end

function SaveRecordingVideo()
	local text=""
	if true then	--存档未达到上限
		text="录像保存成功";
		ShowGameTips(text,3);
	else
		text="录像存储位置已满，保存失败"
		ShowGameTips(text,3);
	end
end
function GongNengFrameModBtn_OnClick()

end

function GongNengFrameActivity4399Btn_OnClick()
	if  getglobal("Activity4399Frame"):IsShown() then
		getglobal("Activity4399Frame"):Hide();
	else
		getglobal("Activity4399Frame"):Show();
	end	
end


function GongNengFrame_OnLoad()
	this:setUpdateTime(0.1);
	-- 红包事件注册
	RegisterRedPocketServiceListeners()
	getglobal("GongNengFrameTriggerRunTimeInfoBtnBkgRed"):SetModAlpha(true);
	getglobal("GongNengFrameTriggerRunTimeInfoBtnBkgRed"):SetColor(255, 74, 55);
	getglobal("GongNengFrameTriggerRunTimeInfoBtnIcon"):SetModAlpha(true);
	getglobal("GongNengFrameTriggerRunTimeInfoBtnIcon"):SetColor(237, 237, 237);
end


local getOfflineChatTime = 60;	--没打开聊天面板时60s拉取一次聊天信息
local getVipRewardInfoCountdown = 3;	--每3s本地查询一次vip领奖信息，持续1min
local getVipRewardInfoTotalTime = 60;	--每3s本地查询一次vip领奖信息，持续1min
local updateRedTagFrames = 5;  --每5帧更新一下菜单按钮上的红点
function GongNengFrame_OnUpdate()
	if not getglobal("FriendUIFrameRightChat"):IsShown() then
		getOfflineChatTime = getOfflineChatTime - arg1;
		if getOfflineChatTime <= 0 then
			BuddyManager:getOfflineChat()
			getOfflineChatTime = 60;
		end
	end
	
	if getVipRewardInfoTotalTime >= 0 then
		getVipRewardInfoTotalTime = getVipRewardInfoTotalTime - arg1;
		getVipRewardInfoCountdown = getVipRewardInfoCountdown - arg1;
		if getVipRewardInfoCountdown <=0 then
			GongNengFrameVipBtnRefresh();
			getVipRewardInfoCountdown = 3;
		end
	end

	updateRedTagFrames = updateRedTagFrames - 1;
	if updateRedTagFrames <= 0 then
		updateRedTagFrames = 5;

		local showRedTag = false;
		if getglobal("GongNengFrameActivityGNBtnRedTag"):IsShownSelf()
			or getglobal("GongNengFrameFriendBtnRedTag"):IsShownSelf() then
			showRedTag = true;
		end
		if showRedTag then
			getglobal("GongNengFrameMenuArrowRedTag"):Show();
		else
			getglobal("GongNengFrameMenuArrowRedTag"):Hide();
		end
	end

	--更新录像时间
	if IsVideoRecording() then
		UpdateVideoRecordTime();
	end
end


local GNFrame_VipBtnForceHide = false;

function GongNengFrame_SetVipBtnForceHide(forcehide)
	GNFrame_VipBtnForceHide = forcehide;
end

function GongNengFrame_OnBtnVisibleChange()
	if ShowQQVipBtn() then
		if getglobal("GongNengFrame"):IsShown() then
			getglobal("GongNengFrameQQBlueVipBtn"):Show();
		else
			getglobal("GongNengFrameQQBlueVipBtn"):Hide();
		end
	else
		getglobal("GongNengFrameQQBlueVipBtn"):Hide();
	end

	GongNengFrame_DoLayout();

	if GNFrame_VipBtnForceHide then
		getglobal("GongNengFrameQQBlueVipBtn"):Hide();
	end
end

local GongNengFrameMenu_Buttons = {
	"GongNengFrameFriendBtn",
	"GongNengFrameActivityGNBtn",
	"GongNengFrameStoreGNBtn",
	"GongNengFrameGameDataBtn",
	"GongNengFrameQQBlueVipBtn",
	"GongNengFrame7k7kBlueVipBtn",
	"GongNengFrameModBtn",
	"GongNengFrameRedPacketGNBtn"
};

function GongNengFrame_DoLayout()
	local count = CountShownObjs(GongNengFrameMenu_Buttons);

	local spacing = 0;

	getglobal("GongNengFrameMenu"):SetSize(73, (count + 1) * (80 + spacing) - 10);

	DoLayout_ListV_InContainer("GongNengFrameMenu", GongNengFrameMenu_Buttons, 70, spacing);

end

function SwitchGongNengFrameMenu(show)
	if show then
		getglobal("GongNengFrameMenuArrowNormal"):SetTexUV("img_icon_board");
		getglobal("GongNengFrameMenuArrowPushedBG"):SetTexUV("img_icon_board");

		getglobal("GongNengFrameMenu"):Show();
		GongNengFrame_DoLayout();
	else
		getglobal("GongNengFrameMenuArrowNormal"):SetTexUV("img_icon_board");
		getglobal("GongNengFrameMenuArrowPushedBG"):SetTexUV("img_icon_board");

		getglobal("GongNengFrameMenu"):Hide();
	end
end

function GongNengFrameMenuArrow_OnClick()
	if IsStandAloneMode() then return end
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
		standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "MoreTelescopicBar", "click")
	else
		standReportEvent("1001", "MINI_GAMEOPEN_GAME_1", "MoreTelescopicBar", "click")
	end
	
	if getglobal("GongNengFrameMenu"):IsShown() then
		SwitchGongNengFrameMenu(false);
	else
		SwitchGongNengFrameMenu(true);
		local tb = {
			"-",
			"Friend",
			"Activity",
			"Shop",
		}
		if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
			for index, value in ipairs(tb) do
				standReportEvent("1003", "MORE_TELESCOPIC_BAR", value, "view")
			end
		else
			for index, value in ipairs(tb) do
				standReportEvent("1001", "MORE_TELESCOPIC_BAR", value, "view")
			end
		end
	
		if GetInst("SpringFestivalManager") then
			GetInst("SpringFestivalManager"):SendInfo()
		end
	end
end

--触发器运行信息按钮:点击
function GongNengFrameTriggerRunTimeInfoBtn_OnClick()
	if  ClientCurGame:isInGame() and CurWorld then
		local owid = CurWorld:getOWID();
		local param = {};
		param.owid = owid;
		GetInst("UIManager"):Open("DeveloperRuntimeInfo", param);
	end
end

--print日志按钮点击
function GongNengFrameTriggerPrintLogBtn_OnClick()
	local param = {};
	param.disableOperateUI = true;
	GetInst("UIManager"):Open("scriptprint", param);
end

--触发器运行信息按钮:执行出错回调
function GongNengFrameTriggerRunTimeInfoBtn_ErrorCallback(logidx, logdata)
	if logidx and logdata then
		--出错
		GongNengFrameTriggerRunTimeInfoBtn_UpdateState(true);
	end
end

function GongNengFrameTriggerRunTimeInfoBtn_UpdateState(isError)
	local bkgred = getglobal("GongNengFrameTriggerRunTimeInfoBtnBkgRed");

	if isError then
		bkgred:Show();
	else
		bkgred:Hide();
	end	
end

function WolrdGameTopBtnLayout()
	--顶部按钮排版:以后有新增也直接放在这里------------------
	local topBtnList = {
		"GongNengFrameExitBtn",
		"GongNengFrameTeamBtn",
		"GongNengFrameRuleSetGNBtn",
		"GongNengFrameModelLibBtn",
		"GongNengFrameScreenshotBtn",
		"GongNengFramePluginLibBtn",
		"GongNengFrameDeveloperStoreBtn",
		"GongNengFrameTriggerRunTimeInfoBtn",
		"GongNengFrameTriggerPrintLogBtn",
		"GongNengFrameDeveloperCodeBtn",
		"GongNengFrameUILibBtn",
		"GongNengFrameOpenCameraModeBtn",
		"GongNengFrameOpenRedPocket",
	};

	local soiaBtns = 
	{
		--1根据是否soia进行展示； 2保持原有显示设置； 不存在的: soia下隐藏 否则保持原有显示设置
		["GongNengFrameExitBtn"] = 1,
		["GongNengFrameTeamBtn"] = 1,
		["GongNengFrameDeveloperStoreBtn"] = 2,
		["GongNengFrameOpenCameraModeBtn"] = 2,
	}

	local offsetY = 12;
	local offsetX = -240;
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		offsetX = -18;
		for index = 1, #topBtnList do
			local ui = topBtnList[index];
			local obj = getglobal(ui);
			if soiaBtns[ui] == 1 then
				obj:Show()
			elseif not soiaBtns[ui] then
				obj:Hide()
			end
		end
	else
		for index = 1, #topBtnList do
			local ui = topBtnList[index];
			local obj = getglobal(ui);
			if soiaBtns[ui] == 1 then
				obj:Hide()
			end
		end
	end

	for i = 1, #topBtnList do
		local ui = topBtnList[i];
		local obj = getglobal(ui);
		if obj:IsShown() then
			obj:SetPoint('topright', 'GongNengFrame', 'topright', offsetX, offsetY);
			offsetX = offsetX - 61;
		end
	end
	----------------------------------------------------
end

function GongNengFrame_ReportEventCameraButton(event_code)
	-- 新编辑模式 不上报拍照
	if IsUGCEditMode() and CurWorld and CurWorld:isGameMakerMode() then
		return
	end

	local sceneID = ""
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
		sceneID = "1003"
	else--客机
		sceneID = "1001"
	end
	standReportEvent(sceneID, "MINI_GAMEOPEN_GAME_1", "CameraButton", event_code)
end

function GongNengFrame_OnShow()
	print( "call GongNengFrame_OnShow" );
	if isEducationalVersion and not ClientCurGame then
		return;
	end

	if  ClientCurGame:isInGame() and CurWorld and (CurWorld:getOWID() == NewbieWorldId or CurWorld:getOWID() == NewbieWorldId2) then
		getglobal("GongNengFrame"):Hide();
		return;
	end
	
	if ClientMgr:getGameData("hideui") == 1 and ClientCurGame:isInGame() then
		getglobal("GongNengFrame"):Hide();
		return
	end

	-- if getglobal("MiniLobbyFrame"):IsShown() then
	if IsMiniLobbyShown() then --mark by hfb for new minilobby
		getglobal("GongNengFrame"):Hide();
		return
	end

	if IsUGCEditing() and UGCModeMgr:GetGameType() == UGCGAMETYPE_BUILD  then
		local resMainFrame = GetInst("MiniUIManager"):GetCtrl("ResourceBagMain")
		if resMainFrame and resMainFrame:IsBagShown() then
			getglobal("GongNengFrame"):Hide();
		end
	end
	
	IsShowCommentBtn()

	getglobal("GongNengFrameStoreGNBtnUVAnimationTex"):SetUVAnimation(200, true);
	getglobal("GongNengFrameStoreGNBtnUVAnimationTex"):Show();

	--游戏资料按钮, 101, 121, 122(PC版) 才显示
	if ClientMgr:getApiId() == 121 or ClientMgr:getApiId() == 122 or isQQGamePc() then
		getglobal("GongNengFrameGameDataBtn"):Show();
	end

	--开发者商城
	if  ClientCurGame:isInGame() then
		ShowDeveloperStoreBtn();
	end
   
	GongNengFrameDeveloperCodeBtn_Show()
	--:7k7k vip按钮
	IsShowVip7k7kBtn(getglobal("GongNengFrame7k7kBlueVipBtn"));

	-- ugc高级模式会切换 gongnengFrame 的显示状态，包一层切换的时候不去请求数据
	if not GetInst("UGCCommon"):GetGongnengShowOnlyUIFlg() then
		refreshAdMarket();
	else
		GetInst("UGCCommon"):SetGongnengShowOnlyUI(false)
	end

	GongNengFrame_OnBtnVisibleChange();

	getglobal("GongNengFrameQQBlueVipBtnUVAnimationTex"):SetUVAnimation(200, true);
	GongNengFrameVipBtnRefresh();

	local canShowRuleSetGNBtn = false;
	local wdesc = AccountManager:getCurWorldDesc();
	if ClientCurGame:isInGame() and CurWorld and CurWorld:isGameMakerMode() and AccountManager:getMultiPlayer() == 0 
		and (wdesc and wdesc.realowneruin == AccountManager:getUin() and wdesc.worldtype ~= 9) then --录像播放和编辑时不显示工具模式按钮
		canShowRuleSetGNBtn = true;
	end

    --家园屏蔽工具模式
    if IsInHomeLandMap() then
        canShowRuleSetGNBtn = false
    end
    
	--地图模型库
	if CurWorld and CurWorld:isGodMode() then
		getglobal("GongNengFrameModelLibBtn"):Show();

		if canShowRuleSetGNBtn then
			getglobal("GongNengFrameModelLibBtn"):SetPoint("right", "GongNengFrameRuleSetGNBtn", "left", -7, 0);
		else
			getglobal("GongNengFrameModelLibBtn"):SetPoint("right", "GongNengFrameRuleSetGNBtn", "right", -7, 0);
		end
	else
		getglobal("GongNengFrameModelLibBtn"):Hide();
	end

	if CurWorld and CurWorld:isGameMakerMode() then
		GongNengFrameUILibBtn_Show()
	else
		getglobal("GongNengFrameUILibBtn"):Hide();
	end

	--截图分享按钮
	-- if  SdkManager:isShareEnabled() then
	if getglobal("GongNengFrameModelLibBtn"):IsShown() then
		getglobal("GongNengFrameScreenshotBtn"):SetPoint("right", "GongNengFrameModelLibBtn", "left", -7, 0);
	elseif canShowRuleSetGNBtn then
		getglobal("GongNengFrameScreenshotBtn"):SetPoint("right", "GongNengFrameRuleSetGNBtn", "right", -7, 0);
	else
		getglobal("GongNengFrameScreenshotBtn"):SetPoint("right", "GongNengFrameRuleSetGNBtn", "right", -7, 0);
	end

	--getglobal("GongNengFrameScreenshotBtn"):Show();
	if FristScreenshotRedTagTips then
		getglobal("GongNengFrameScreenshotBtnRedTag"):Show();
	else
		getglobal("GongNengFrameScreenshotBtnRedTag"):Hide();
	end
	-- else
	-- 	--getglobal("GongNengFrameScreenshotBtn"):Hide();
	-- end

	if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) then--xyang自定义UI
		getglobal("GongNengFrameScreenshotBtn"):Show();
	end
	if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.CAMERA) then--xyang自定义UI
		getglobal("GongNengFrameOpenCameraModeBtn"):Show()
		GongNengFrame_ReportEventCameraButton("view")
	end
	--新埋点
	local sceneID = "";
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
		sceneID = "1003";
	else--客机
		sceneID = "1001";
	end
	
	if not( IsUGCEditMode() and CurWorld and CurWorld:isGameMakerMode()) then
		standReportEvent(sceneID, "MINI_GAMEOPEN_GAME_1", "ShareButton", "view")
	end
	
	--录像按钮显示
	ShowVideoRecordBtn();
	-- 迷你基地-引流
	RefreshLobbyMiniBaseDrainageBt()

	--触发器运行信息按钮显示
	getglobal("GongNengFrameTriggerRunTimeInfoBtn"):Hide();
	if CurWorld and CurWorld:isGameMakerRunMode() then
		if  ScriptSupportDebug and ScriptSupportDebug:getDebugOnOff() then
			getglobal("GongNengFrameTriggerRunTimeInfoBtn"):Show();
			GongNengFrameTriggerRunTimeInfoBtn_UpdateState(false);
			ScriptSupportDebug:setCallback_errorlog(GongNengFrameTriggerRunTimeInfoBtn_ErrorCallback);
		end
	elseif ClientMgr:isPC() and ClientMgr:getApiId() == 999 and WorldMgr and WorldMgr.isAdventureMode and WorldMgr:isAdventureMode() then -- 方便冒险模式测试
		getglobal("GongNengFrameTriggerRunTimeInfoBtn"):Show();
		GongNengFrameTriggerRunTimeInfoBtn_UpdateState(false);
		ScriptSupportDebug:setCallback_errorlog(GongNengFrameTriggerRunTimeInfoBtn_ErrorCallback);
	end

	--'print'日志按钮显示:在玩法运行模式, 且是主机才显示
	local printBtn = getglobal('GongNengFrameTriggerPrintLogBtn');
	printBtn:Hide();
	if CurWorld and CurWorld:isGameMakerRunMode() then
		if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
			--房主或单机, 暂时屏蔽
			local apiId = ClientMgr:getApiId();
			if false and apiId == 999 then
				printBtn:Show();
			end
		end
	end

	-- 红包按钮
	ShowGongNengFrameOpenRedPocket()

	--工具模式界面
	if not IsUGCEditMode() then -- 老的编辑模式
		if IsUIFrameShown("ToolModeFrame") then
			GetInst("UIManager"):Close("ToolModeFrame");
		end
		if canShowRuleSetGNBtn then
			print("显示工具模式界面:");
			local param = {disableOperateUI = true};
			GetInst("UIManager"):Open("ToolModeFrame", param);
		end

		if gIsSingleGame then
			getglobal("GongNengFrameScreenshotBtn"):Hide()
			getglobal("GongNengFrameOpenCameraModeBtn"):Hide()
			getglobal("GongNengFrameMenuArrow"):Hide()
		end
	end
	
	GongNengFramePluginPkgTipsShow()
	
	--教育版不显示
	if isEducationalVersion then
		RefreshLobbyFrameForEdu()		
	end

	--MiniBase 隐藏部分按钮
	if MiniBaseManager:isMiniBaseGame() then
		getglobal("GongNengFrameScreenshotBtn"):Hide()
		getglobal("GongNengFrameOpenCameraModeBtn"):Hide()
		getglobal("GongNengFrameMenuArrow"):Hide()		
	end

	GetInst("UGCCommon"):UIEnterWorldShow()

	ShowUILibCheckFrame();

	getglobal("GongNengFrameMenuArrow"):Show()		
	getglobal("GongNengFrameSettingBtn"):Show()
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		getglobal("GongNengFrameDeveloperStoreBtn"):Hide()
		getglobal("GongNengFrameSettingBtn"):Hide()
		getglobal("GongNengFrameMenuArrow"):Hide()
		if not GetInst("MiniUIManager"):IsShown("SocialRoomSimple") then
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/c_miniwork"})
			GetInst("MiniUIManager"):OpenUI("SocialRoomSimple", "miniui/miniworld/SocialRoomDetail", "SocialRoomSimpleAutoGen", {disableOperateUI = true, keep = true})
		end

		GetInst("SocialHallDataMgr"):FastEnterFriendChat()
		if not NewbieGuideManager:GetGuideFinishFlag(NewbieGuideManager.GUIDE_IN_SOCIAL_ROOM) then
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/c_miniwork", "miniui/miniworld/common"})
			GetInst("MiniUIManager"):OpenUI(
				"FullGuideTmmTip", "miniui/miniworld/Guide", "FullGuideTmmTipAutoGen", 
				{
					keep = true, 
					content = GetS(28618), 
					clickHideCb = function()
						local ctrl = GetInst("MiniUIManager"):GetCtrl("SocialRoomSimple")
						if ctrl then
							ctrl:ShowTeamBtnBubble(GetS(28620), ctrl.define.bubbleType.guide)
						end
						NewbieGuideManager:SetGuideFinishFlag(NewbieGuideManager.GUIDE_IN_SOCIAL_ROOM, true)
						NewbieGuideManager:SetGuideFlagByPos(NewbieGuideManager.GUIDE_IN_SOCIAL_ROOM)
					end})
		end
		-- 管理功能面版顶部按钮位置
		WolrdGameTopBtnLayout()
	else
		threadpool:work(function()
			DealDeveloperStoreBtn();
			WolrdGameTopBtnLayout()
		end)
	end	
	
	--xyang进入时即拉去数据
	if CurWorld and CurWorld:isGameMakerRunMode() then-- 玩法模式
		LoadDeveloperPropList();	
	end
	WolrdGameTopBtnLayout()

end

function GongNengFrame_OnHide()
 -- 倒计时小于0 点击小地图隐藏计时器
	if GetSSTimer() <= 0 and ClientCurGame:isInGame() then
		SetSSTimerUI()
	elseif not ClientCurGame:isInGame() then
		SetSSTimerUI()
	end
	getglobal("GongNengFrameDeveloperStoreBtn"):Hide()
	if getglobal("InteractiveGuideFrame") then
		getglobal("InteractiveGuideFrame"):Hide()
	end
	GetInst("MiniUIManager"):CloseUI("SocialRoomDetailAutoGen")
	GetInst("MiniUIManager"):CloseUI("SocialRoomSimpleAutoGen")
	GetInst("SocialHallDataMgr"):QuitFriendChat()
end

function refreshAdMarket()
	--如果在游戏中，不显示 
	Log( "stage=" .. ClientCurGame:getName() );
	if  ClientCurGame:getName() == "MainMenuStage" then
		WWW_get_cf_info();  --拉取config文件列表，只拉取一次
	end
	--初始化新版登录系统的配置
	if IsEnableNewAccountSystem() then
		LoginMainUIInit()
	end

	ActivityMainCtrl:CheckRedTag()
	--刷新手机绑定红点提示
	if PhtoneBindingAwardClass then
		PhtoneBindingAwardClass:UpdatePhtoneBindingRedTag()
	end
end

--游戏中查看代码按钮
function GongNengFrameDeveloperCodeBtn_Show()
	local wedsc = AccountManager:getCurWorldDesc()
	if wedsc then
		if wedsc.OpenCode and wedsc.OpenCode == 1  and not (AccountManager:getMultiPlayer()> 0 )then
			getglobal("GongNengFrameDeveloperCodeBtn"):Show()
		else
			getglobal("GongNengFrameDeveloperCodeBtn"):Hide()
		end
	end
end


--查看教育侧代码按钮
function GongNengFrameDeveloperCodeBtn_OnClick()
	local param = {}	  
	param.owid=CurWorld:getOWID()
	
	GetInst("UIManager"):Open("DeveloperEditScriptItem",param)

end

-- --UI编辑器按钮
function GongNengFrameUILibBtn_Show()
	if UIEditorDef and UIEditorDef:gongNengBtnSwitch() then
		getglobal("GongNengFrameUILibBtn"):Show()
	end
end

--查看UI编辑器按钮
function GongNengFrameUILibBtn_OnClick()
	GetInst("ResourceDataManager"):SetIsFromLobby(ResourceCenterOpenFrom.FromMap)
	GetInst("UIManager"):Open("ResourceCenter",{UpdateView=true, SelectUILib = true});
end
---------------------------------------------------下载相关------------------------------------------------------------------
FirstOpenLobbyFrame = true;		--登录游戏后第一次打开lobbyframe标记

--worldId 	根据下载的世界创建的新世界的id
--state 	1正在下载 2等待下载 3暂停下载 4下载完成
--name 捆绑的存档条名字 
t_LoadWorldList = {}; 

--------------------------------------------------------LobbyFrame-------------------------------------------------------------
ARCHIVE_MAX 		= 999 --96;--开启存档位[Desc3][Desc5]以后扩展到325 //22.12.5 开始游戏改版需求不限制上限，只能改成999  
SelectArchiveIndex 	= -1;
DeleteMapIndex		= -1;
DeleteMapFormWid 	= 0;
ShareingMapIndex 	= -1;			--当前正在上传分享的地图
IsDownWorld		= false;		--标识一下如果刚下载地图，打开存档的时候用默认选择刚下载的地图		
IsNeedReset 		= true;		--更新存档的时候滑动条是否要重置;
Translate_ArchiveIndex = 0;

ArchiveWorldDesc = nil;			--存档的信息
ArchiveWorldDescWorldId = 0
CurArchiveMap = nil;			--存档的信息
CurArchiveMapWorldId = 0
CurArchiveMapOptions = {};
gCurrentSelectWorldId = 0 --当前选中的地图ID

--
function GetCurArchiveMapInfo(k)
	if k=="ArchiveWorldDesc" then
		--return ArchiveWorldDesc	
		if ArchiveWorldDescWorldId ~= 0 then 		
			return AccountManager:findWorldDesc(ArchiveWorldDescWorldId)
		else
			return ArchiveWorldDesc
		end 
	elseif k=="CurArchiveMap" then
		return CurArchiveMap
	elseif k=="CurArchiveMapOptions" then
		return CurArchiveMapOptions
	elseif k=="" then

	end
end
function SetCurArchiveMapInfo(k,v)
	if k=="ArchiveWorldDesc" then
		ArchiveWorldDesc=v
		ArchiveWorldDescWorldId = ArchiveWorldDesc.worldid
	elseif k=="CurArchiveMap" then
		CurArchiveMap=v
		CurArchiveMapWorldId = CurArchiveMap.worldid
	elseif k=="CurArchiveMapOptions" then
		CurArchiveMapOptions=v
	elseif k=="" then

	end
end

local CurArchiveConnoisseurUin = nil;
local ArchiveForBtnName = nil;			--存档条名字
local ChooseArchiveBtnName = nil;		--选中的存档条名字

local WatchUinType = 0;		--0 没有查看的uin 1 搜索uin的存档 2 我的分享
local FilterState = 1;

t_LobbyFrameData = {
	switchown = true,	--自己的存档显示开关
	switchother = true,	--下载别人的存档显示开关
	switchownVideo = true, --自己的录像显示开关
	switchotherVideo = true,	--下载别人的录像显示开关
}

function updateLobbyFrameData()
	if FilterState == 1 then 
		t_LobbyFrameData.switchown = true;
		t_LobbyFrameData.switchother = true;
		t_LobbyFrameData.switchownVideo = true;
		t_LobbyFrameData.switchotherVideo = true;
	elseif FilterState == 2 then
		t_LobbyFrameData.switchown = true;
		t_LobbyFrameData.switchother = false;
		t_LobbyFrameData.switchownVideo = false;
		t_LobbyFrameData.switchotherVideo = false;
	elseif FilterState == 3 then
		t_LobbyFrameData.switchown = false;
		t_LobbyFrameData.switchother = true;
		t_LobbyFrameData.switchownVideo = false;
		t_LobbyFrameData.switchotherVideo = false;
	elseif FilterState == 4 then
		t_LobbyFrameData.switchown = false;
		t_LobbyFrameData.switchother = false;
		t_LobbyFrameData.switchownVideo = true;
		t_LobbyFrameData.switchotherVideo = false;
	elseif FilterState == 5 then
		t_LobbyFrameData.switchown = false;
		t_LobbyFrameData.switchother = false;
		t_LobbyFrameData.switchownVideo = false;
		t_LobbyFrameData.switchotherVideo = true;
	end
end

function Record_Filter_OnClick( ... )
	local name=this:GetName()
	local parent=this:GetParentFrame():GetName()
	local filter = getglobal(name.."Name"):GetText()
	local filter_right = getglobal(name.."NameRight"):GetText() 
	if parent == "LobbyFrameArchiveFrameRecordList" then
		getglobal("LobbyFrameArchiveFrameRecordTitleName"):SetText((string.gsub(filter,"      ","")))
		getglobal("LobbyFrameArchiveFrameRecordTitleNameRight"):SetText(filter_right)
		-- getglobal(parent):Hide()
		-- getglobal(parent.."Bkg"):Hide()
		-- getglobal("LobbyFrameArchiveFrameRecordTitleDown"):Show()
		-- getglobal("LobbyFrameArchiveFrameRecordTitleUp"):Hide()
		ShowRecordList(false)
		FilterState = this:GetClientID();
		--不做默认选中
		SelectArchiveIndex = -1
		--隐藏存档信息窗口
		HideMapDetailInfo()
		--搜索
		updateLobbyFrameData();
		UpdateArchive();
		SetDefaultArchiveBtn(); --不做默认选中
	end
end

function RecordBar_OnValueChanged(...)
	local value=this:GetValue()
	local bar=getglobal("LobbyFrameArchiveFrameRecordBar")
	if value>=299 then
		value=303
		bar:SetValue(value)
	elseif value<=4 then
		value=0
		bar:SetValue(value)
	end
	local sliderFrame=getglobal("LobbyFrameArchiveFrameRecordList")
	sliderFrame:setCurOffsetY(-value)
end

function RecordSlide_OnMouseWheel( ... )
	local sliderFrame=getglobal("LobbyFrameArchiveFrameRecordList")
	local bar=getglobal("LobbyFrameArchiveFrameRecordBar")
	local offsetY = sliderFrame:getCurOffsetY()
	bar:SetValue(-offsetY)
end

function RecordSelect_OnClick( ... )
	local name=this:GetName()
	local parent_name=this:GetParentFrame():GetName()
	if getglobal(name.."Down"):IsShown() then
		-- getglobal(name.."Down"):Hide()
		-- getglobal(name.."Up"):Show()
		-- getglobal(parent_name.."List"):Show()
		-- getglobal(parent_name.."ListBkg"):Show()
		ShowRecordList(true)
	else
		-- getglobal(name.."Up"):Hide()
		-- getglobal(name.."Down"):Show()
		-- getglobal(parent_name.."List"):Hide()
		-- getglobal(parent_name.."ListBkg"):Hide()
		ShowRecordList(false)
	end
	--关闭使用动作窗口
	if IsUIFrameShown("ArchiveUseAction") then
		GetInst("UIManager"):Close("ArchiveUseAction");
	end
end

--点击隐藏存档分类列表
function HideRecordList_onClick()
	ShowRecordList(false)
end

--封装一下显示分类列表的接口，多处调用
--bshow true显示列表，false隐藏列表
function ShowRecordList( bshow )
	if bshow then
		getglobal("LobbyFrameArchiveFrameRecordTitleDown"):Hide()
		getglobal("LobbyFrameArchiveFrameRecordTitleUp"):Show()
		getglobal("LobbyFrameArchiveFrameRecordList"):Show()
		getglobal("LobbyFrameArchiveFrameRecordListBkg"):Show()
		getglobal("LobbyFrameArchiveFrameHideRecordList"):Show()
	else
		getglobal("LobbyFrameArchiveFrameRecordTitleUp"):Hide()
		getglobal("LobbyFrameArchiveFrameRecordTitleDown"):Show()
		getglobal("LobbyFrameArchiveFrameRecordList"):Hide()
		getglobal("LobbyFrameArchiveFrameRecordListBkg"):Hide()
		getglobal("LobbyFrameArchiveFrameHideRecordList"):Hide()
	end
end
--------------------------------------ArchiveInfoFilterFrame---------------------------------
local ArchiveInfoFilterFrameSwitch=
{
	"MyArchiveSwitch",
	"DownArchiveSwitch",
	"MyVideotapeSwitch",
	"DownVideoSwitch",
}

--筛选
function ArchiveFrameFilterBtn_OnClick()
	getglobal("ArchiveInfoFilterFrame"):Show();
end


function ArchiveInfoFilterFrame_OnLoad()
	-- body
end


function ArchiveInfoFilterFrameOKBtn_OnClick()
	--[[
	for i=1,4 do	
		local switchName 	= "ArchiveInfoFilterFrame" .. ArchiveInfoFilterFrameSwitch[i];
		local state			= 0;
		local bkg 			= getglobal(switchName.."Bkg");
		local point 		= getglobal(switchName.."Point");
		if point:GetRealLeft() - bkg:GetRealLeft() > 35  then			--先前状态：开
			point:SetPoint("left", this:GetName(), "left", 4, -3);
			state = false;
		else									--先前状态：关
			point:SetPoint("right", this:GetName(), "right", -6, -3);
			state = true;
		end
		if i == 1 then
			t_LobbyFrameData.switchown = state;
		elseif i == 2 then
			t_LobbyFrameData.switchother = state;
		elseif i == 3 then
			t_LobbyFrameData.switchownVideo = state;
		else
			t_LobbyFrameData.switchotherVideo = state;
		end
	end

	]]
	HideMapDetailInfo();
	UpdateArchive();
	SetDefaultArchiveBtn();
	getglobal("ArchiveInfoFilterFrame"):Hide();
end
function ArchiveInfoFilterFrame_OnShow()
	
end

function ArchiveInfoFilterFrame_OnHide()
	-- body
end

function CanShowArchive(worldInfo)
	if t_LobbyFrameData.switchown then
		if (worldInfo.realowneruin == 0 or worldInfo.realowneruin == 1 or worldInfo.owneruin == worldInfo.realowneruin) and worldInfo.worldtype ~= 9 then
			return true;
		end
	end
	if t_LobbyFrameData.switchother then
		if worldInfo.realowneruin ~= 0 and worldInfo.realowneruin ~= 1 and worldInfo.owneruin ~= worldInfo.realowneruin and worldInfo.worldtype ~= 9 then
			return true;
		end
	end
	if t_LobbyFrameData.switchownVideo then
		if (worldInfo.realowneruin == 0 or worldInfo.realowneruin == 1 or worldInfo.owneruin == worldInfo.realowneruin) and worldInfo.worldtype == 9 then
			return true;
		end
	end
	if t_LobbyFrameData.switchotherVideo then
		if worldInfo.realowneruin ~= 0 and worldInfo.realowneruin ~= 1 and worldInfo.owneruin ~= worldInfo.realowneruin and worldInfo.worldtype == 9 then
			return true;
		end
	end
	return false;
end

function GetArchiveData()
	local t_ArvhiveData = {};

	local num = AccountManager:getMyWorldList():getNumWorld();
	for i=1, ARCHIVE_MAX do
		if i <= num then
			local worldInfo = AccountManager:getMyWorldList():getWorldDesc(i-1);
			if worldInfo and CanShowArchive(worldInfo) then
				table.insert(t_ArvhiveData, {index = i, info=worldInfo});
			end
		else
			break
		end
	end

	return t_ArvhiveData;
end

function GetOneArchiveData(index)
	if not index then
		return nil;
	end
	local idx = index+1
	local t_ArchiveData = GetArchiveData();
	if t_ArchiveData and next(t_ArchiveData) ~= nil then
		if idx <= #(t_ArchiveData) then
			return t_ArchiveData[idx];
		end
	end

	return nil;
end

--clientId 为getWorldDesc的index+1;
function GetIndexForClientId(clientId)
	for i=1, ARCHIVE_MAX do
		local archiveBtn = getglobal("ArchiveBtn"..i);
		local curId = archiveBtn:GetClientID();
		if curId == clientId then
			return i;
		end
	end

	return -1;
end

function GetIndexForWorldId(worldId)
	local t_ArchiveData = GetArchiveData();
	local num = #(t_ArchiveData);
	for i=1, ARCHIVE_MAX do
		if i <= num then
			local worldInfo = t_ArchiveData[i].info;
			if worldInfo and worldId == worldInfo.worldid then
				return i
			end
		end
	end

	return -1;
end

function ArchiveLeftArrowBtn_OnClick()
	local archive = this:GetParentFrame():GetParent();
	local index = getglobal(archive):GetClientID();
	local listview = getglobal("ArchiveBox")
	local cell = listview:cellAtIndex(index+1)
	local nextArchive =  cell and cell:GetName() or nil--"ArchiveBtn" .. index+1;
	--适配界面
	if not nextArchive and index >= 3 then
		local tipsBkg		= getglobal(archive.."FunctionTipsBkg")			--tips背景框
		if tipsBkg:GetHeight() == 180 then
			getglobal(archive .. "FunctionTipsLeftArrow"):SetPoint("left", archive .. "FunctionTips", "right", -56, 73);
			getglobal(archive .. "FunctionTips"):SetPoint("topright", archive, "topright", -56, -73);
		else
			getglobal(archive .. "FunctionTipsLeftArrow"):SetPoint("left", archive .. "FunctionTips", "right",-56, 133);
			getglobal(archive .. "FunctionTips"):SetPoint("topright", archive, "topright", -56, -133);
		end
	elseif index >= 3 and not getglobal(nextArchive):IsShown() then
		local tipsBkg		= getglobal(archive.."FunctionTipsBkg")			--tips背景框
		if tipsBkg:GetHeight() == 180 then
			getglobal(archive .. "FunctionTipsLeftArrow"):SetPoint("left", archive .. "FunctionTips", "right",-56, 73);
			getglobal(archive .. "FunctionTips"):SetPoint("topright", archive, "topright", -56, -73);
		else
			getglobal(archive .. "FunctionTipsLeftArrow"):SetPoint("left", archive .. "FunctionTips", "right",-56, 133);
			getglobal(archive .. "FunctionTips"):SetPoint("topright", archive, "topright", -56, -133);
		end
	else
		getglobal(archive .. "FunctionTipsLeftArrow"):SetPoint("left", archive .. "FunctionTips", "right",-56, 0);
		getglobal(archive .. "FunctionTips"):SetPoint("topright", archive, "topright", -56, 0);
	end
	getglobal(archive .. "FunctionTips"):Show();
	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(index)
	if worldInfo and IsNewbieWorld(worldInfo.worldid) then
		getglobal(archive.."FunctionTipsUpdate"):Hide()
	end
	--这里将详情隐藏，为了避免上传的操作改变了存档的状态，但是详情界面取得数据还是老的
	if IsMapDetailInfoShown() then
		HideMapDetailInfo();
	end

	if ns_version.upload_limit and ns_version.upload_limit.tree_level and ns_version.upload_limit.tree_level == -1 then
		getglobal(archive .. "FunctionTipsShareName"):SetTextColor(195,195,195)
		getglobal(archive .. "FunctionTipsUpdateName"):SetTextColor(195,195,195)
	else
		getglobal(archive .. "FunctionTipsShareName"):SetTextColor(255,255,255)
		getglobal(archive .. "FunctionTipsUpdateName"):SetTextColor(255,255,255)
	end

	if SelectArchiveIndex < 0 or SelectArchiveIndex ~= index then
		ArchiveContent_OnClick();
	end
end

function ArchiveContent_OnClick(obj)
	local parent = nil
	if obj then
		parent = obj:GetParentFrame()
	else
		parent = this:GetParentFrame()
	end

	print("ArchiveContent_OnClick", parent:GetName(), parent:GetParent())
	if parent ~= nil and parent:GetParent() ~= nil then
		local archive = parent:GetParentFrame();
		if archive ~= nil then
			--新手引导流程优化
			if archive:GetClientID() == 0 and CreateMapGuideStep == 3 then 
				CreateMapGuideStep = CreateMapGuideStep + 1 
				CreateMapGuide()
			end 
			---------
			SetHightLightArchiveBtn(parent:GetParent());
			local archiveData = GetOneArchiveData(archive:GetClientID());
			if not archiveData then return end
			if archiveData then
				ArchiveWorldDesc = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
				ArchiveWorldDescWorldId = ArchiveWorldDesc.worldid
				if not ArchiveWorldDesc then return end
				gCurrentSelectWorldId = ArchiveWorldDesc.worldid
				gCreateRoomWorldID = gCurrentSelectWorldId
				local offsetY = archive:GetRealTop();			
				local ArchiveInfoFrame = getglobal("ArchiveInfoFrame")
				ArchiveInfoFrame:SetClientUserData(0, offsetY);
				ArchiveForBtnName = archive:GetName();
				ArchiveInfoFrame:Show();

				PEC_SetJumpToFrameName("LobbyFrame");
				--材质包
				local materialBtnName = getglobal("ArchiveInfoFrameEditMaterialBtnName");
				local materialType = 0;
				local materialPackUUID = "";
				materialPackUUID,materialType=AccountManager:GetNotDefaultModMaterialUUID(ArchiveWorldDesc.worldid,materialPackUUID,materialType);
				if materialPackUUID == "" then
					materialBtnName:Hide();
				else
					local modDesc = AccountManager:getModDescByUUID(materialPackUUID);
					if modDesc and materialType == 1 then
						getglobal("ArchiveInfoFrameEditMaterialBtnNameTitle"):SetText(modDesc.name);
						materialBtnName:Show();
					else
						materialBtnName:Hide();
					end
				end	
			end	
			local materialBtn = getglobal("ArchiveInfoFrameEditMaterialBtnGuide");
			if materialBtn:IsShown() then
				materialBtn:Hide();
			end

			getglobal("ArchiveInfoFrameMultiLangBtn"):Hide()
			getglobal("ArchiveInfoFrameLangSelectBtn"):Hide()
			--ShowGameTips(tostring(if_open_google_translate_author_self()))
			if ArchiveWorldDesc.realowneruin ~= 0 and ArchiveWorldDesc.worldtype ~= 9 then
				if ArchiveWorldDesc.owneruin ~= ArchiveWorldDesc.realowneruin then
					--ShowGameTips(tostring(141))
					getglobal("ArchiveInfoFrameMultiLangBtn"):Hide()
					local otherlang = ArchiveWorldDesc.translate_supportlang - math.pow(2, ArchiveWorldDesc.translate_sourcelang)
					--支持超过一种语言
					if otherlang > 0 then
						getglobal("ArchiveInfoFrameLangSelectBtn"):Show()
					else
						getglobal("ArchiveInfoFrameLangSelectBtn"):Hide()
					end
					--在白名单内
				else
					if if_open_google_translate_author_self() then
						getglobal("ArchiveInfoFrameMultiLangBtn"):Show()
						if getglobal("ArchiveInfoFrameEditModBtn"):IsShown() then
							getglobal("ArchiveInfoFrameMultiLangBtn"):SetPoint("topright","ArchiveInfoFrame","topleft",-10,324)
						else
							getglobal("ArchiveInfoFrameMultiLangBtn"):SetPoint("topright","ArchiveInfoFrame","topleft",-10,227)
						end
					else
						getglobal("ArchiveInfoFrameMultiLangBtn"):Hide()
					end
				end	
			end
		end
	end
	if IsUIFrameShown("ArchiveUseAction") then
		GetInst("UIManager"):Close("ArchiveUseAction");
		return
	end
	--print("translate_currentlang:",ArchiveWorldDesc.translate_currentlang)
end

--云服id标签点击
function ArchiveCSIDBtn_OnClick()
	local parent = this:GetParentFrame()
	if parent ~= nil and parent:GetParent() ~= nil then
		local parent2 = parent:GetParentFrame()
		if parent2 ~= nil then
			local archive = parent2:GetParentFrame();
			if archive ~= nil then
				local archiveData = GetOneArchiveData(archive:GetClientID());
				if archiveData then
					local archiveWorldDesc = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
					local csuin = archiveWorldDesc.owneruin
					if archiveWorldDesc.realowneruin ~= 0 then
						csuin = archiveWorldDesc.realowneruin
					end
					ShowGameTipsWithoutFilter(GetS(9713, csuin .. "-" .. archiveWorldDesc.cloudServerID))
				end
			end
		end
	end
end

function AccountBtnUpdate()
	local active = AccountManager:getActive();
	local icon = getglobal("LobbyFrameAccountBtnIcon");
	if active >= Very_Active_Value then
		icon:SetTexUV("icon_lock_open.png");
	else
		icon:SetTexUV("icon_lock.png");
	end
end

function LobbyFrame_OnLoad()
	this:setUpdateTime(0.05);
	if isEnableNewLobby and not isEnableNewLobby() then
		this:RegisterEvent("GE_WORLDLIST_CHANGE");
		this:RegisterEvent("GIE_NET_CHANGE");
		this:RegisterEvent("GIE_APPBACK_PRESSED");
		this:RegisterEvent("GIE_RSCONNECT_RESULT");
		this:RegisterEvent("GE_WORLD_CHANGE");
		this:RegisterEvent("GIE_NET_ANOMALY");
		this:RegisterEvent("GE_MAP_LOADED_RESULT");
		this:RegisterEvent("GE_GAME_RESUME_FRONT");
	end

	-- for i=1, ARCHIVE_MAX do
	-- 	local archive = getglobal("ArchiveBtn"..i);
	-- 	archive:SetPoint("top", "ArchiveBoxPlane", "top", 0, (i-1)*112+4);
	-- end	

	FirstOpenLobbyFrame = true;
	IsNeedReset = true;

	local roleview = getglobal("LobbyFrameRoleView")
	roleview:setCameraWidthFov(30);
	roleview:setCameraLookAt(0, 220, -1200, 0, 128, 0);
	roleview:setActorPosition(0, 0, -320);

	local apiId = ClientMgr:getApiId();
	if apiId == 3 or gIsSingleGame then	--uc
		getglobal("LobbyFrameAccountBtn"):Hide();
	else
		getglobal("LobbyFrameAccountBtn"):Show();
	end

	--PC版存档条不能横着滑动
	local canSlide = true;
	if ClientMgr:isPC() or true then
		canSlide = false;	
	end

	ClientMgr:setGameData("hideui", 0);
	-- local namefliter = "LobbyFrameArchiveFrameRecordListF";
	-- for i=1,5 do
	-- 	getglobal(namefliter..i):SetPoint("top","LobbyFrameArchiveFrameRecordList","top", 8, 41*(i-1))
	-- end
	getglobal("LobbyFrameArchiveFrameRecordListF1"):SetPoint("top","LobbyFrameArchiveFrameRecordList","top", 0, 0)
	getglobal("LobbyFrameArchiveFrameRecordListT1"):SetPoint("top","LobbyFrameArchiveFrameRecordList","top", 0, 51)
	getglobal("LobbyFrameArchiveFrameRecordListF2"):SetPoint("top","LobbyFrameArchiveFrameRecordList","top", 0, 32+51)
	getglobal("LobbyFrameArchiveFrameRecordListF3"):SetPoint("top","LobbyFrameArchiveFrameRecordList","top", 0, 32+51*2)
	getglobal("LobbyFrameArchiveFrameRecordListT2"):SetPoint("top","LobbyFrameArchiveFrameRecordList","top", 0, 32+51*3)
	getglobal("LobbyFrameArchiveFrameRecordListF4"):SetPoint("top","LobbyFrameArchiveFrameRecordList","top", 0, 32*2 + 51*3)
	getglobal("LobbyFrameArchiveFrameRecordListF5"):SetPoint("top","LobbyFrameArchiveFrameRecordList","top", 0, 32*2 + 51*4)

	--组队邀请弹窗开关，0-表示之前没这个字段，1-表示开，2-表示关
	local value = ClientMgr:getGameData("InviteSwitch");
	if value == 0 then
		ClientMgr:setGameData("InviteSwitch", 1);
	end
end

--刷新存档数据显示
function UpdateLobbyFrameArchiveFrameRecordList()
	--存档数
	local listConfig = {
		{textid = 7516, num = AccountManager:getMyWorldList():getNumWorld()},
		{textid = 289, num = AccountManager:getMyWorldList():getMyCreateWorldNum()},
		{textid = 7514, num = AccountManager:getMyWorldList():getMyCreateRecordNum()},
		{textid = 888, num = AccountManager:getMyWorldList():getDownWorldNum()},
		{textid = 7515, num = AccountManager:getMyWorldList():getDownRecordNum()}
	}
	for i,v in ipairs(listConfig) do
		if 1==i then
			getglobal("LobbyFrameArchiveFrameRecordListF"..i.."Name"):SetText(GetS(v.textid))
			getglobal("LobbyFrameArchiveFrameRecordListF"..i.."NameRight"):SetText(tostring(v.num))
			getglobal("LobbyFrameArchiveFrameRecordListF"..i.."Name"):SetTextColor(255,255,255)
			getglobal("LobbyFrameArchiveFrameRecordListF"..i.."NameRight"):SetTextColor(255,255,255)
		else
			getglobal("LobbyFrameArchiveFrameRecordListF"..i.."Name"):SetText("      "..GetS(v.textid))
			getglobal("LobbyFrameArchiveFrameRecordListF"..i.."NameRight"):SetText(tostring(v.num))
		end
	end
	--刷新
	getglobal("LobbyFrameArchiveFrameRecordTitleName"):SetText(GetS(listConfig[FilterState].textid))
	getglobal("LobbyFrameArchiveFrameRecordTitleNameRight"):SetText(tostring(listConfig[FilterState].num))

	--分类汇总
	listConfig = {
		{textid = 32016, num = GetCreateArchiveNum(), max = CreateArchiveMaxNum()},
		{textid = 32017, num = GetDownArchiveNum(), max = DownArchiveMaxNum()}
	}
	for i,v in ipairs(listConfig) do
		local text =GetS(v.textid) 
		if v.num > v.max then
			text = text .. "  #ce91514(" .. v.num .. "/" .. v.max .. ")"
		else
			text = text .. "  (" .. v.num .. "/" .. v.max .. ")"
		end
		getglobal("LobbyFrameArchiveFrameRecordListT"..i.."Name"):SetText(text, 142, 135, 119)
	end

	listConfig = nil
end

function LobbyFrame_OnEvent()
	if GetInst("UIEvtHook"):EventHook(arg1, GameEventQue:getCurEvent()) then
		return
	end
	local lobbyframe = getglobal("LobbyFrame")
	if arg1 == "GE_WORLDLIST_CHANGE" then
		if ArchiveWorldDesc ~= nil then
			ArchiveWorldDesc = GetCurArchiveMapInfo("ArchiveWorldDesc")
		end
		if lobbyframe:IsShown() then
			if not IsNeedReset then
				gAchiveDataList = GetArchiveData();
				return
			end

			local ge = GameEventQue:getCurEvent();
			UpdateArchive();
			--设置高亮
			if SelectArchiveIndex < 0 or DeleteMapIndex == SelectArchiveIndex then
				-- SelectArchiveIndex = -1;
				SetHightLightArchiveBtn(nil);
			else
				if DeleteMapIndex ~= -1 and DeleteMapIndex < SelectArchiveIndex then
					SelectArchiveIndex = SelectArchiveIndex - 1;
				end
				-- local btnName = "ArchiveBtn"..SelectArchiveIndex;
				local listview = getglobal("ArchiveBox")
				local cell = listview:cellAtIndex(SelectArchiveIndex)
				SetHightLightArchiveBtn(cell and cell:GetName() or nil);
			end

			if DeleteMapIndex >= 0 then
				SetDefaultArchiveBtn()--add

				RemoveRecordMapList(DeleteMapFormWid);
				DeleteMapIndex = -1;
				DeleteMapFormWid = 0;
				StatisticsTools:gameEvent("DelMap");
			end
			UpdateLobbyFrameArchiveFrameRecordList()
		else
			gAchiveDataList = GetArchiveData();
		end
	elseif arg1 == "GE_WORLD_CHANGE" then
		local ge = GameEventQue:getCurEvent();
		local owid = ge.body.worldchange.owid;
		UpdateWorld(owid);
	elseif arg1 == "GIE_NET_ANOMALY" then
	--	WatchUinType = 0;
		if getglobal("LoadLoopFrame"):IsShown() then
			ShowLoadLoopFrame(false)
			--ShowGameTips(StringDefCsv:get(37), 3);
		end
	elseif arg1 == "GIE_NET_CHANGE" then
		if CanUseNet() then
			local netState = ClientMgr:getNetworkState();
			if netState ==  0 then
				ShowGameTips(GetS(161), 3)
			end
		end
	elseif arg1 == "GIE_APPBACK_PRESSED" then
		if getglobal("GameSetFrame"):IsShown() then
			getglobal("GameSetFrame"):Hide();
		elseif getglobal("FeedBackFrame"):IsShown() then
			getglobal("FeedBackFrame"):Hide();
		else
			if getglobal("SetMenuFrame"):IsShown() then
				getglobal("SetMenuFrame"):Hide();
			--	GameSnapshot();
			elseif CurWorld and (CurWorld:getOWID() == NewbieWorldId2) then
				PlayMainFrameGuideSkip_OnClick();
			else
				getglobal("SetMenuFrame"):Show();
			end
		end
	elseif arg1 == "GIE_RSCONNECT_RESULT" then
		--移动到RoomService
	elseif arg1 == "GE_MAP_LOADED_RESULT" then
		local ge = GameEventQue:getCurEvent();
		local ret = ge.body.maploadedresult.result;
		local fromowid = ge.body.maploadedresult.fromowid;
		print("kekeke GE_MAP_LOADED_RESULT", ret, fromowid);
		local recorded, t = CheckRecordedFromWidByUin(AccountManager:getUin());
		if ret == 1 and fromowid and tonumber(fromowid) > 1 and type(t) == 'table' then
			local id = tostring( EncodeFromWid(fromowid) );
			if id ~= nil then 
				table.insert(t.map_time, id);
				print("kekeke GE_MAP_LOADED_RESULT2:", t.map_time,id);
				print("kekeke GE_MAP_LOADED_RESULT3:", mapservice.mapFromWidList);
				SaveMapFromWidFile();
			end 
		end
	elseif arg1 == "GE_GAME_RESUME_FRONT" then
		AccountManager:performResumeUpdateMyWorldList();

		--识别组队邀请码
		GetInst("TeamupService"):DecodeTeamInviteInfo()
		if GetInst("MusicNumShareManager") then
			GetInst("MusicNumShareManager"):OnResume()
		end
		if GetInst("ActivityMoneyGodManager") then
			GetInst("ActivityMoneyGodManager"):OnResume()
		end
		if GetInst("ActivityAwakenManager") then
			GetInst("ActivityAwakenManager"):OnResume()
		end
		
		if GetInst("SanrioActInterface") then
			GetInst("SanrioActInterface"):OnResume()
		end
		
		if GetInst("NationdayInterface") then
			GetInst("NationdayInterface"):OnResume()
		end
		
		if GetInst("AotuActInterface") then
			GetInst("AotuActInterface"):OnResume()
		end
	end
end

function UpdateWorld(owid)
	if getglobal("LobbyFrameArchiveFrame"):IsShown() then
		gAchiveDataList = GetArchiveData();

		local cell = nil
		local listview = getglobal("ArchiveBox")
		for i=1,#gAchiveDataList do
			local worldInfo = gAchiveDataList[i].info
			cell = listview:cellAtIndex(i-1)
			if cell and worldInfo then
				local wid = cell:GetClientUserDataLL(0)
				local cellname = cell:GetName()
				if owid == wid then
					if owid == worldInfo.worldid then
						UpdateArchiveBtnInfo({index=i-1, name=cell:GetName(), data=gAchiveDataList[i]}, false)
					else
						UpdateArchive()
					end
					break
				end
			end
		end
		-- for i=1,#(gAchiveDataList) do
		-- 	local worldInfo = gAchiveDataList[i].info;
		-- 	if worldInfo.worldid == owid then
		-- 		-- UpdateArchiveBtnInfo({index=i, data=t_ArchiveData[i]}, false);			
		-- 		cell = listview:cellAtIndex(i-1)
		-- 		if cell then
		-- 			UpdateArchiveBtnInfo({index=i-1, name=cell:GetName(), data=gAchiveDataList[i]}, false);			
		-- 		end
		-- 	end
		-- end
	end
end

function OnlineBackupUpdateWorld(owid)
	-- local t_ArchiveData = GetArchiveData();

	pcall(function()
		local cell = nil
		local listview = getglobal("ArchiveBox")
		for i=1,#(gAchiveDataList) do
			local worldInfo = gAchiveDataList[i].info;
			if worldInfo.worldid == owid then
				-- UpdateArchiveBtnInfo({index=i, data=t_ArchiveData[i]}, false);		
				cell = listview:cellAtIndex(i-1)
				if cell then
					UpdateArchiveBtnInfo({index=i-1, name=cell:GetName(), data=gAchiveDataList[i]}, false);			
				end	
			end
		end
	end)
end

--获取最新的存档条index
function GetNewestIndex()
	for i=1, ARCHIVE_MAX do
		if i == AccountManager:getMyWorldList():getNumWorld() then
			return i;
		end
	end

	return nil;
end

local ArchiveBackupGuideIndex = nil;

function UpdateArchiveBackupGuideDisp()
	if AccountManager:getNoviceGuideState("guidebackup") or ArchiveBackupGuideIndex == nil then
		getglobal("ArchiveBackupGuide1"):Hide();
		getglobal("ArchiveBackupGuide2"):Hide();
		return;
	end
	local offsetY = getglobal("ArchiveBox"):getCurOffsetY();
	if math.abs(offsetY) < 108 * UIFrameMgr:GetScreenScaleY() then

	else
		getglobal("ArchiveBackupGuide1"):Hide();
		getglobal("ArchiveBackupGuide2"):Hide();
	end
end

function UpdateArchiveBackupGuideAll()
	ArchiveBackupGuideIndex = nil;
	if not AccountManager:getNoviceGuideState("guidebackup") then
		
		for i = 1, AccountManager:getMyWorldList():getNumWorld() do
			local worldInfo = AccountManager:getMyWorldList():getWorldDesc(i-1);

			if not IsNewbieWorld(worldInfo.worldid) then
				if CSOWorld:checkWorldHasBackup(worldInfo.worldid) then
					AccountManager:setNoviceGuideState("guidebackup", true);
					break;
				else
					ArchiveBackupGuideIndex = i;
					break;
				end
			end
		end
	end
	UpdateArchiveBackupGuideDisp();
end


--检查实名认证
function checkRealNameAuth()
	if gIsSingleGame then return end
	--local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	print("checkRealNameAuth(): ns_data.hasCheckRealNameAuth = ", ns_data.hasCheckRealNameAuth);
	if  not ns_data.hasCheckRealNameAuth then
		ns_data.hasCheckRealNameAuth = 1   --只提示一次
		if AccountManager.get_antiaddiction_def then
			local def = AccountManager:get_antiaddiction_def();
			print("checkRealNameAuth(): def = ", def);
			if def and type(def) == "table" then
				print("checkRealNameAuth(): def.ForceAuth = ", def.ForceAuth);
				print("checkRealNameAuth(): def.AntiAddiction = ", def.AntiAddiction);
				print("checkRealNameAuth(): def.Auth = ", def.Auth);
				if def.AntiAddiction then
					FcmSwitch = def.AntiAddiction == 1;
				else
					FcmSwitch = true
				end

				if def.Auth then
					RealNameAuthSwitch = def.Auth > 0
				else
					RealNameAuthSwitch = true
				end

				if def.ForceAuth then
					ForceRealNameAuthSwitch = def.ForceAuth == 2
				else
					ForceRealNameAuthSwitch = true
				end

				UpdateRealNameAuthFrameState("LobbyFrame_OnShow");
			end
		end
	end
end

--获取自己成就的基本信息
function ReqSelfAchieveInfo()
    local uin = AccountManager:getUin()
    local url_ =  g_http_common..'/miniw/achieve?act=query_all_achieve_task&op_uin='..uin..'&' .. http_getS1();   
    ns_http.func.rpc( url_, RespSelfAchieveInfo, { callback=ext_callback }, nil, true )
end

function RespSelfAchieveInfo(ret)
	if ret then
		if ret.ret == 0 then
			ns_data.self_total_achieve = ret.total_achieve or 0 -- 总的成就值
		end
	end
end
local LobbyFrame_FirstShow = true
function LobbyFrame_OnShow()
	gCurrentSelectWorldId = 0--初始是0
	IsCreatingColloborationModeRoom = false

	UpdateLobbyFrameArchiveFrameRecordList()

	checkRealNameAuth()

	SetLobbyFrameModelView();
	SetLobbyFrameHeadInfo();

	--隐藏分类列表
	ShowRecordList(false)
	--隐藏存档信息
	HideMapDetailInfo()
	--[[
	if not AccountManager:getNoviceGuideState("guidechestbtn") then
		getglobal("LobbyFrameHomeChestBtnUVAnimationTex"):SetUVAnimation(120, true);
		getglobal("LobbyFrameHomeChestBtnUVAnimationTex"):Show();
	end
	
	插件引导
	if not AccountManager:getNoviceGuideState("guidemods") then
		getglobal("LobbyFrameArchiveFrameMyModsBtnGuide"):Show();
		getglobal("ArchiveBackupGuide1"):Hide();
		getglobal("ArchiveBackupGuide2"):Hide();
	else
		getglobal("LobbyFrameArchiveFrameMyModsBtnGuide"):Hide();
		存档备份引导
		UpdateArchiveBackupGuideAll();
	end

	创建地图选择插件引导
	if not AccountManager:getNoviceGuideState("guidechoosemod") then
		getglobal("CreateArchiveCreateRedTag"):Show();
	else
		getglobal("CreateArchiveCreateRedTag"):Hide();
	end
	]]


	--创建地图红点.
	if not AccountManager:getNoviceGuideState("createmap") then
		getglobal("CreateArchiveCreateRedTag"):Show();
	else
		getglobal("CreateArchiveCreateRedTag"):Hide();
	end

	updateLobbyFrameData();
	UpdateArchive();
	SetDefaultArchiveBtn();
	
	--显示账号按钮
	if NewAccountSwitchCfg:GetAccountSettingShowSwitch() and not gIsSingleGame then  
		getglobal("LobbyFrameAccountBtn"):Show();
	else
		getglobal("LobbyFrameAccountBtn"):Hide();
	end

	--创建地图引导
	if NewbieGuideManager and NewbieGuideManager:IsSwitch() then
		-- 新手创建地图引导
		threadpool:delay(0.5, function()
			NewbieGuideManager:StartShowMapCreateHelp()
		end)
	else
		CreateMapGuide();
	end

	UpdateLobbyForIosReview();

	--资源中心总库初始化
	ResourceCenterInitResLib()

	--TODO:用户插件文件夹检测
	ModMgr:checkUserModDir();
	
	-- if SingleEditorFrame_Switch_New then
	-- 	CustomModelMgr:copyEquipCustomModel2StudioPath();
	-- 	CustomModelMgr:loadEquipCustomModel();			--TODO:加载预设装备模型
	-- 	FullyCustomModelMgr:loadEquipFullyCustomModel();--TODO:加载预设装备模型
	-- end

	--商城初始化
	ShopInit()

	--是否显示21号广告位
	LobbyFrame21ADBtnCanShow()
	--22号广告
	AdvertCommonHandle:ShowAdvert(22, ADVERT_PLAYTYPE.AUTOSHOW_DIALOG);

	if GetInst("UIManager"):GetCtrl("AccountGameMode","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("AccountGameMode"):Refresh()
	end 

	--testgjd
	--游戏主界面落地数据埋点
    LobbyFrame_BuriedDatapoints();

	--拉取自己的成就信息
	local achieveValue = UIAchievementMgr:GetAchievementPanelData().achieveValue
	if achieveValue.Num and achieveValue.Num > 0 then
		ns_data.self_total_achieve = achieveValue.Num
	else
		--拉取自己的成就信息
		ReqSelfAchieveInfo()
	end

	-- 新增审核人员一键清空存档按钮
	if IsUserOuterChecker(AccountManager:getUin()) then
		getglobal("LobbyFrameArchiveFrameMyModsBtn"):Hide();
		getglobal("LobbyFrameArchiveFrameClearAllBtn"):Show();
	else
		getglobal("LobbyFrameArchiveFrameMyModsBtn"):Show();
		getglobal("LobbyFrameArchiveFrameClearAllBtn"):Hide();
	end

	if ARMotionCapture:GetSeatOpenState() then
		getglobal("LobbyFrameUseActionBtn"):Show()
		--动作坑位黄点
		local yellowDot = getglobal("LobbyFrameUseActionBtnPermitPoint")
		if CanCurUseRoleSupportARAction() then
			yellowDot:Hide()
		else
			yellowDot:Show()
		end
	else
		getglobal("LobbyFrameUseActionBtn"):Hide()
	end

	--print("WWW_get_building_bag_unlock_info LobbyFrame_OnShow = "..os.time())
	WWW_get_building_bag_unlock_info() --获取解锁信息

	if LobbyFrame_FirstShow then
		LobbyFrame_FirstShow = false;
		WWW_GetMuteData();              --拉取自己的禁言数据
	end

	CheckNeedShowExternalRecommend();

	standReportEvent("32", "MINI_OLDGAMEOPEN_GAME_1", "-", "view")

	-- print("============================ClientMgr:InitYouMe==================")
	-- if LobbyFrame_FirstShow then
	-- 	local isDeveloper = IsEnableYouMeVoice()
	-- 	if isDeveloper then
	-- 		print("============================isDeveloper==================",isDeveloper)
	-- 		local rtc_region = RTC_CN_SERVER
	-- 		if ClientMgr:getGameData("game_env") >= 10 then
	-- 			rtc_region = RTC_SG_SERVER;
	-- 		end
	-- 		if GYouMeVoiceMgr then
	-- 			GYouMeVoiceMgr:init(rtc_region, "");
	-- 		end
	-- 	end
	-- end
	EnterMainMenuInfo.EnterMainMenuBy = 'standalone'
end

--ios分包审核用
function UpdateLobbyForIosReview()
	if IsInIosSpecialReview() then
		getglobal("LobbyFrameCloseBtn"):Hide();
		getglobal("LobbyFrameRoleView"):Hide();
		getglobal("LobbyFrameAccountBtn"):Hide();
		getglobal("LobbyFrameBkg"):SetTexture("ui/login_bg2.png");
		getglobal("LobbyFrameArchiveFrameMyModsBtn"):Hide();
		InteractiveBtn_ShowOrHide(false);
			getglobal("GongNengFrame"):Show();
		getglobal("GongNengFrameStoreGNBtn"):Show();
		getglobal("GongNengFrameStoreGNBtn"):SetPoint("topright", "GongNengFrame", "topright", -10, 9);
		getglobal("GongNengFrameActivityGNBtn"):Hide();
		--getglobal("GongNengFrameSetGNBtn"):Hide();
		getglobal("LobbyFrameArchiveFrameDownArchive"):Hide();
	end
	CheckIosOverseaForGuangDongGamers()
end


function LobbyFrameRotateView_OnMouseDown()
	InitModelViewAngle =  getglobal("LobbyFrameRoleView"):getRotateAngle();

	getglobal("LobbyFrameViewJumpStore"):Hide();
end

function LobbyFrameRotateView_OnMouseUp()
	getglobal("LobbyFrameViewJumpStore"):Show();
end

function LobbyFrameRotateView_OnMouseMove()
	local posX = getglobal("LobbyFrameRoleView"):getActorPosX();
	local posY = getglobal("LobbyFrameRoleView"):getActorPosY();

	if arg1 > posX-170 and arg1 < posX+170 and arg2 > posY-410 and arg2 < posY+30 then	--按下的位置是角色范围内
		local angle = (arg1 - arg3)*1;

		if angle > 360 then
			angle = angle - 360;
		end
		if angle < -360 then
			angle = angle + 360;
		end

		angle = angle + InitModelViewAngle;	
		ActorAnimCtrl.IsAngle = false;
		getglobal("LobbyFrameRoleView"):setRotateAngle(angle);
	end
end

function SetLobbyFrameModelView()

    --[[if AccountManager.get_antiaddiction_def then
        local def = AccountManager:get_antiaddiction_def();
        if def then
            ForceRealNameAuthSwitch = def.ForceAuth == 2;
            UpdateRealNameAuthFrameState();
        end
    end--]]

    local player = GetPlayer2Model();
    if player == nil then return end
    Log("Lobby1")
    local fbkg = getglobal("LobbyFrameBkg")
    local roleview = getglobal("LobbyFrameRoleView")
    fbkg:SetTexture("ui/mobile/texture2/bigtex/dtxx_beijingtu.png")
    if lobbyIsAvtModel then
        player = UIActorBodyManager:getAvatarBody(97, false);
    end
	if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
		roleview:attachActorBody(player, 0, false)
	else
    	player:attachUIModelView(roleview, 0, false);
	end
    player:setScale(1.2); --roleview:setActorScale(1.2, 1.2, 1.2);
	--roleview:playActorAnim(100100,0);
	--roleview:playEffect(1038, 0);
	--ZoneStopPlayAnim(player, t_exhibition.mood_icon);
	
	if player and  t_exhibition.mood_icon and  t_exhibition.mood_icon ~= "" then
		print("mood_icon = " ..  t_exhibition.mood_icon);
		local id, effect = ZoneGetModeViewAnimId( t_exhibition.mood_icon);
		if lobbyIsAvtModel then
			player = UIActorBodyManager:getAvatarBody(97, false);
		else
			player = GetPlayer2Model();
		end

		if player == nil then return end

		player:stopAnimBySeqId(id);

		if effect and "" ~= effect then
			print("ZoneStopPlayAnim:222:" .. ", effect = " .. effect);
			local exhibitionCenterRoleView = getglobal(t_exhibition:getModelViewUiName());
			if exhibitionCenterRoleView:IsShown() then
				exhibitionCenterRoleView:stopEffect(effect, 0);
			end
		end
	end

    roleview:setRotateAngle(0)
    roleview:playActorAnim(100108, 0);
    getglobal("LobbyFrameRotateView"):Hide()
    player:setAnimSwitchIsCall(true);
    roleview:playEffect(1038, 0);
    local skinModel = AccountManager:getRoleSkinModel();
    if skinModel > 0 then
        local skinDef = RoleSkinCsv:get(skinModel);
        if skinDef ~= nil then
            --ClientMgr:playStoreSound2D("sounds/skin/"..skinDef.Sound..".ogg");
            if skinDef.ShowTimeEffect ~= nil then
                roleview:playEffect(skinDef.ShowTimeEffect, 0);
            end

            local bgPath = ""
            if skinDef.BackgroundPic ~= "" then
				bgPath = string.format("ui/mobile/texture2/bigtex/%s.png", skinDef.BackgroundPic)
				fbkg:SetTexture(bgPath)
			end

			if skinDef.BackgroundAnim ~= "" then
				bgPath = string.format("ui/models/%s.omod", skinDef.BackgroundAnim)
				roleview:setBackground(bgPath)
			else
				roleview:setBackground('')
			end
        end
    end
end

function SetLobbyFrameHeadInfo()
	getglobal("LobbyFrameHeadInfoRoleName"):SetText(ReplaceFilterString(AccountManager:getNickName()));

	getglobal("LobbyFrameHeadInfoUin"):SetText(GetS(359)..GetMyUin())

	local uiVipIcon1 = getglobal("LobbyFrameHeadInfoVipIcon1");
	local uiVipIcon2 = getglobal("LobbyFrameHeadInfoVipIcon2");
	local vipDispInfo = UpdateAccountVipIcons(uiVipIcon1, uiVipIcon2);

	getglobal("LobbyFrameHeadInfoRoleName"):SetPoint("topleft", "LobbyFrameHeadInfo", "topleft", 80+vipDispInfo.nextUiOffsetX, 16);

	--:7k7kvip图标
	if ClientMgr:getApiId() == 122 or ClientMgr:getApiId() == 999 then
		if ClientMgr.is7k7kVip and ClientMgr:is7k7kVip() then
			getglobal("LobbyFrameHeadInfo7k7kVipIcon"):SetTexUV("vip_7k7k_1");
			getglobal("LobbyFrameHeadInfo7k7kVipIcon"):Show();
			getglobal("LobbyFrameHeadInfoRoleName"):SetPoint("topleft", "LobbyFrameHeadInfo", "topleft", 104, 16);
		elseif ClientMgr.is7k7kYearVip and ClientMgr:is7k7kYearVip() then
			getglobal("LobbyFrameHeadInfo7k7kVipIcon"):SetTexUV("vip_7k7k_2");
			getglobal("LobbyFrameHeadInfo7k7kVipIcon"):Show();
			getglobal("LobbyFrameHeadInfoRoleName"):SetPoint("topleft", "LobbyFrameHeadInfo", "topleft", 104, 16);
		else
			
		end
	end

	--设置头像
	HeadCtrl:CurrentHeadIcon("LobbyFrameHeadBtnIcon");
	HeadFrameCtrl:CurrentHeadFrame("LobbyFrameHeadBtnIconFrame");
end

gHeadInfoClickCount = 0
function LobbyFrameHeadInfo_OnClick()
	-- just for convert map tools
	gHeadInfoClickCount = gHeadInfoClickCount + 1
	-- 老存档已经不用了, 改成5次点击就出搬运工具，原来是30次
	if gHeadInfoClickCount == 2 and MapConvertManager and MapConvertManager.ToolIsOpen and MapConvertManager:ToolIsOpen() then
		local uin = getShortUin(AccountManager:getUin())
		if ClientMgr:getApiId() == 999 then
			getglobal("ArchiveInfoFrameConvertBtn"):Show()
			getglobal("LobbyFrameArchiveFrameCheckAll"):Show()
			getglobal("LobbyFrameArchiveFrameOneKeyBtn"):Show()
			getglobal("LobbyFrameArchiveFrameOneKeyDelBtn"):Show()
			getglobal("LobbyFrameArchiveFrameProgress"):Show()
			UpdateArchive()
		end
	end
end

function LobbyFrame_OnHide()
	if not IsCreatingColloborationModeRoom then
		gCreateRoomWorldID = nil
	end

	sendEventReports();
	if getglobal("LoadLoopFrame"):IsShown() then
		ShowLoadLoopFrame(false)
	end

	local player = GetPlayer2Model();
	local roleview = getglobal("LobbyFrameRoleView");

	roleview:stopEffect(1038, 0);
	if player == nil then return end
	Android:LogFabric("LobbyFrame_OnHide")
	if lobbyIsAvtModel then
		player = UIActorBodyManager:getAvatarBody(97, false);
	end
	if  player.getPlayerIndex and player:getPlayerIndex() > 0  then
		local skinModel = player:getSkinID();
		if skinModel == 74 or skinModel == 75 or skinModel == 76 then
			local body = roleview:getActorBody();
			if body then
				if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
					getglobal("LobbyFrameRoleView"):detachActorBody(body)
				else
					body:detachUIModelView(getglobal("LobbyFrameRoleView"));
				end
			end
		else
			if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
				getglobal("LobbyFrameRoleView"):detachActorBody(player)
			else
				player:detachUIModelView(getglobal("LobbyFrameRoleView"));
			end
		end
	else
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			getglobal("LobbyFrameRoleView"):detachActorBody(player)
		else
			player:detachUIModelView(getglobal("LobbyFrameRoleView"));
		end
	end
	if roleview:IsShown() then
		roleview:Hide();
	end

	if isEducationalVersion == false then
		local seatID = AccountManager:avatar_seat_current();
		if seatID and seatID > 0 and seatID <= 20 then
			-- UIActorBodyManager:releaseAvatarBody(seatID);
		end
	end
--	getglobal("LobbyFrameRoleView"):stopEffect(1038, 0);
	if IsMapDetailInfoShown() then
		HideMapDetailInfo();
	end
	--关闭使用动作窗口
	if IsUIFrameShown("ArchiveUseAction") then
		GetInst("UIManager"):Close("ArchiveUseAction");
		return
	end
end

function LobbyFrameUseActionBtn_OnClick()
	GetInst("UIManager"):Open("ArchiveUseAction");
	if IsMapDetailInfoShown() then
		HideMapDetailInfo();
	end
	if not CanCurUseRoleSupportARAction() then
		ShowGameTipsWithoutFilter(GetS(20454))
	end
end

function SetDefaultArchiveBtn(toind)
	local archiveNum = 23;
	local recentlyTime = 0;
	local index = 0;

	local t_ArchiveData =  GetArchiveData();
	local isFromRecently = 0
	if IsDownWorld then		--选择刚下载的地图为默认
		for i=1, ARCHIVE_MAX do
			if i == #(t_ArchiveData) then
				index = i;
			end
		end
	else				--选择最近登录的地图为默认
		for i=1, ARCHIVE_MAX do
			if i <= #(t_ArchiveData) then
				local worldInfo = t_ArchiveData[i].info;
				if worldInfo.logintime > recentlyTime then
					recentlyTime = worldInfo.logintime;
					index = i;
					isFromRecently = 1
				end
			end
		end
	end

	if toind then
		index = toind
	end

	if index > 0 then
		local listview = getglobal("ArchiveBox")
		local cell = listview:cellAtIndex(index-1)
		SetHightLightArchiveBtn(cell and cell:GetName() or nil);

		SelectArchiveIndex = index-1
		if DeleteMapIndex and DeleteMapIndex >= 0 then
			if #t_ArchiveData > DeleteMapIndex then
				SelectArchiveIndex = DeleteMapIndex
				idx = DeleteMapIndex + 2
			elseif #t_ArchiveData == DeleteMapIndex then
				SelectArchiveIndex = DeleteMapIndex - 1
				idx = DeleteMapIndex + 2
			end

			if cell and index ~= SelectArchiveIndex+1 then
				local heightlightBkg = getglobal(cell:GetName().."SlidingFrameHeightlight")
				local recentlyLableBkg =  getglobal(cell:GetName().."SlidingFrameContentTagBkg");
				local recentlyLableName =  getglobal(cell:GetName().."SlidingFrameContentTagName");
				if heightlightBkg then
					heightlightBkg:Hide();
				end
				if recentlyLableBkg then
					recentlyLableBkg:Hide()
				end
				if recentlyLableName then
					recentlyLableName:Hide()
				end
			end
		end

		if isFromRecently == 1 then
			local idx = SelectArchiveIndex + 2
			if idx <= 4 then
				listview:scrollToTop()
			elseif index == #t_ArchiveData then
				listview:scrollToBottom()
			else
				local i = SelectArchiveIndex + 1
				listview:scrollTo((4-i)*114+57)
			end
		end
	else
		SetHightLightArchiveBtn(nil);
		SelectArchiveIndex = -1
	end
end

-- function UpdateArchive()
-- 	--设置滚动层大小
-- 	-- local t_ArchiveData = GetArchiveData();
-- 	gAchiveDataList = GetArchiveData()

-- 	local archiveNum = #(t_ArchiveData)+1;
-- 	local height = getglobal("ArchiveBox"):GetRealHeight() / UIFrameMgr:GetScreenScaleY();
-- 	local planeheight = archiveNum*112-106
-- 	if planeheight < height then planeheight = height end

-- 	getglobal("ArchiveBoxPlane"):SetSize(646,planeheight);

-- 	--更新存档信息
-- 	local myArchiveNum = #(t_ArchiveData);

-- 	local t_mapFromWid = {};
-- 	local recordedFromWid = CheckRecordedFromWidByUin(AccountManager:getUin());

-- 	--没有存档时，显示提示
-- 	if myArchiveNum == 0 then
-- 		getglobal("LobbyFrameArchiveFrameNoneIcon"):Show();
-- 		getglobal("LobbyFrameArchiveFrameNoneTitle"):Show();
-- 		getglobal("LobbyFrameArchiveFrameArchiveChenDi"):Show();
-- 	else
-- 		getglobal("LobbyFrameArchiveFrameNoneIcon"):Hide();
-- 		getglobal("LobbyFrameArchiveFrameNoneTitle"):Hide();
-- 		getglobal("LobbyFrameArchiveFrameArchiveChenDi"):Hide();
-- 	end

-- 	for i=1, ARCHIVE_MAX do 
-- 		local archiveBtn 	= getglobal("ArchiveBtn"..i);

-- 		if i <= myArchiveNum then
-- 			archiveBtn:Show();

-- 			if i <= myArchiveNum then
-- 				archiveBtn:Show();
-- 				UpdateArchiveBtnInfo({index=i, data=t_ArchiveData[i]}, true);

-- 				if not recordedFromWid then
-- 					local worldInfo = t_ArchiveData[i].info;
-- 					if worldInfo.fromowid > 1 then
-- 						local sWid = tostring( EncodeFromWid(worldInfo.fromowid) );
-- 						if sWid ~= nil then
-- 							table.insert(t_mapFromWid, sWid);
-- 						end
-- 					end
-- 				end
-- 			else
-- 				archiveBtn:Hide();
-- 			end
			
-- 		else
-- 			archiveBtn:Hide();
-- 		end
-- 	end

-- 	if not recordedFromWid then
-- 		print("kekeke table.insert mapservice.mapFromWidList:", AccountManager:getUin(),t_mapFromWid);
-- 		table.insert(mapservice.mapFromWidList, {uin=tostring(AccountManager:getUin()), map_time=t_mapFromWid})
-- 		SaveMapFromWidFile();
-- 	end

-- 	--getglobal("CreateArchive"):SetPoint("top", "ArchiveBoxPlane", "top", "0", myArchiveNum*(112)+8);
-- 	if AccountManager:isLogin() and (AccountManager:getUin() or 0)>=1000 then	--账号登录成功
-- 		getglobal("CreateArchiveCreate"):SetWidth(358);
-- 		getglobal("CreateArchiveJumpWorks"):Show();
-- 	else
-- 		getglobal("CreateArchiveCreate"):SetWidth(628);
-- 		getglobal("CreateArchiveJumpWorks"):Hide();
-- 	end
-- end

gLoadOtherUserWorlds = false
function ResetOtherUserFlag()
	gLoadOtherUserWorlds = false
end

function LoadOtherUserWorlds()
	gAchiveDataList = GetArchiveData()

	--更新存档信息
	local myArchiveNum = #(gAchiveDataList);
	if not gLoadOtherUserWorlds and myArchiveNum > 0 then
		local owids = {}
		for i=1,myArchiveNum do
			local worldinfo = gAchiveDataList[i].info
			--这里最多50条(下载存档) 和 16条(我的存档)
			if IsDownloadMap(worldinfo) then
				table.insert(owids, {fromowid=worldinfo.fromowid, owid=worldinfo.worldid, ver=worldinfo.shareVersion})
			else
				table.insert(owids, {fromowid=worldinfo.worldid, owid=worldinfo.worldid, ver=worldinfo.shareVersion})
			end
		end

		if #owids > 0 then
			local function resp()
				gLoadOtherUserWorlds = true
			end
			ReqOtherUserWorldStatus(owids, resp)
		else
			gLoadOtherUserWorlds = true
		end
	end
end

function UpdateArchive()

	gAchiveDataList = GetArchiveData()

	--更新存档信息
	local myArchiveNum = #(gAchiveDataList);
	if not gLoadOtherUserWorlds and myArchiveNum > 0 then
		LoadOtherUserWorlds()
	end

	local t_mapFromWid = {};
	local recordedFromWid = CheckRecordedFromWidByUin(AccountManager:getUin());

	--没有存档时，显示提示
	if myArchiveNum == 0 then
		getglobal("LobbyFrameArchiveFrameNoneIcon"):Show();
		getglobal("LobbyFrameArchiveFrameNoneTitle"):Show();
		getglobal("LobbyFrameArchiveFrameArchiveChenDi"):Show();
	else
		getglobal("LobbyFrameArchiveFrameNoneIcon"):Hide();
		getglobal("LobbyFrameArchiveFrameNoneTitle"):Hide();
		getglobal("LobbyFrameArchiveFrameArchiveChenDi"):Hide();
	end

	local list = getglobal("ArchiveBox")
	local listWidth = list:GetRealWidth2()
	local listHeight = list:GetRealHeight2()
	list:initData(listWidth, listHeight, 5, 1)

	if not recordedFromWid then
		table.insert(mapservice.mapFromWidList, {uin=tostring(AccountManager:getUin()), map_time=t_mapFromWid})
		SaveMapFromWidFile();
	end

	-- 优化需求，不在区别显示（改成按钮点击提示）
	getglobal("CreateArchiveCreate"):SetWidth(358);
	getglobal("CreateArchiveJumpWorks"):Show();
end

function ArchiveBox_tableCellAtIndex(tableview, idx)
	local cell, uiidx = tableview:dequeueCell(0)
	--gAchiveDataList = GetArchiveData()
	local info = gAchiveDataList[idx+1]
	if not cell then
		cell = UIFrameMgr:CreateFrameByTemplate("Frame", "ArchiveBtn" .. uiidx, "ArchiveTemplate", "ArchiveBox")
	else
		cell:Show()
	end

	UpdateArchiveBtnInfo({index=idx, name=cell:GetName(), data=info}, true);			

	return cell
end

function ArchiveBox_numberOfCellsInTableView(tableview)
	gAchiveDataList = GetArchiveData()
	local num = 0 
	if type(gAchiveDataList) == "table" then
		num = tonumber(#gAchiveDataList) or 0
	end
	return num
end

function ArchiveBox_tableCellSizeForIndex(tableview, idx)
	return 8, 5, 620, 109
end

function ArchiveBox_tableCellWillRecycle(tableview, cell)
	if cell then cell:Hide() end
end

--把选中的设置高亮
function SetHightLightArchiveBtn(btnName)
	local listview = getglobal("ArchiveBox")
	local cell = listview:cellAtIndex(SelectArchiveIndex)
	if cell then
		local heightlightBkg = getglobal(cell:GetName().."SlidingFrameHeightlight");
		if heightlightBkg then
			heightlightBkg:Hide();
		end
	end

	if btnName ~= nil then
		local archive = getglobal(btnName);
		SelectArchiveIndex = archive:GetClientID();
	else 
		SelectArchiveIndex = -1;
	end

	if SelectArchiveIndex == -1 or btnName == nil then return; end
	getglobal(btnName.."SlidingFrameHeightlight"):Show();
end

function UpdateArchiveBtnInfo(worldData, isSetName)
	local getglobal = getglobal;
	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(worldData.data.index-1)
	if not worldInfo then return end
	local worldname = worldInfo.worldname
	local multilangname = worldInfo.multilangname

	--这里每次更新时都重新取一次WorldDesc
	if gCurrentSelectWorldId == worldInfo.worldid then
		ArchiveWorldDesc = worldInfo
		ArchiveWorldDescWorldId = worldInfo.worldid
	end
	
	local recently_openworldid = 0
	if AccountManager:getMyWorldList().getRecentlyOpenedWorldId then
		recently_openworldid = AccountManager:getMyWorldList():getRecentlyOpenedWorldId()
	end
	local name = worldData.name;
	getglobal(name):SetClientUserDataLL(0, worldInfo.worldid)
	
	local shareTag		= getglobal(name.."ShareTag");
	local downTag		= getglobal(name.."DownTag");
	local restrict		= getglobal(name.."RestrictTag");
	local inReview		= getglobal(name.."InReviewTag");
	local savedTag		= getglobal(name.."SavedTag");
	local modelPic 	= getglobal(name.."SlidingFrameContentModelPic");
	local nameRich 		= getglobal(name.."SlidingFrameContentName");
	local fail		= getglobal(name.."SlidingFrameContentFail");
	local shotPic 		= getglobal(name.."SlidingFrameContentShotPic");
	local timeFont		= getglobal(name.."SlidingFrameContentTime");
	local loadDesc		= getglobal(name.."SlidingFrameContentLoadDesc");
	local delBtn		= getglobal(name.."FunctionTipsDelete");			--删除存档
	local shareBtn		= getglobal(name.."FunctionTipsShare");			--分享存档
	local authorBtn		= getglobal(name.."FunctionTipsAuthor");			--查看作者
	local calUpload		= getglobal(name.."FunctionTipsCancelUpload");		--取消上传
	local uploadBtn 	= getglobal(name.."FunctionTipsUpload");			--上传
	local pauseBtn		= getglobal(name.."FunctionTipsUploadPause");		--暂停上传
	local cancelBtn 	= getglobal(name.."FunctionTipsCancel");			--取消分享
	local updateBtn 	= getglobal(name.."FunctionTipsUpdate");			--更新上传
	local autonymCheckBtn = getglobal(name.."FunctionTipsAutonymCheck");			--实名认证
	local backupBtn     = getglobal(name.."FunctionTipsBackup");         --备份存档
	local backupBtnName = getglobal(name.."FunctionTipsBackupName")
	local backupBtnIcon = getglobal(name.."FunctionTipsBackupIcon")
	local loadBtn 		= getglobal(name.."FunctionTipsLoad");			--下载
	local pauseLoad 	= getglobal(name.."FunctionTipsLoadPause");			--暂停下载
	local tipsBkg		= getglobal(name.."FunctionTipsBkg")			--tips背景框
	local proBkg		= getglobal(name.."SlidingFramebg112ProgressBarBkg");		--上传进度条背景
	local bar		= getglobal(name.."SlidingFramebg112UploadProgressTex");		--上传进度条
	local loadBkg		= getglobal(name.."LoadProgressBarBkg");		--下载进度条背景
	local loadBar		= getglobal(name.."LoadProgressTex");		--下载进度条
	local opDesc		= getglobal(name.."SlidingFrameContentOpDesc")	--操作提示
	local tag 		= getglobal(name.."SlidingFrameContentTag");	
	local tagIcon 		= getglobal(name.."SlidingFrameContentTagIcon");
	local modIcon 		= getglobal(name.."SlidingFrameContentModIcon");
	local bakupStat		= getglobal(name.."SlidingFrameContentBackupState");
	local materialIcon = getglobal(name .. "SlidingFrameContentMaterialIcon");
	local csidBtn = getglobal(name .. "SlidingFrameContentCSIDBtn");
	local csidBtnName = getglobal(name .. "SlidingFrameContentCSIDBtnName");
	local highlight = getglobal(name.."SlidingFrameHeightlight");
	local editopenbtn     = getglobal(name.."FunctionTipsEditorOpen");         --编辑模式打开
	local codeIcon 		= getglobal(name.."SlidingFrameContentCodeIcon");--迷你学代码icon
	local TempIcon 		= getglobal(name.."SlidingFrameContentTempIcon");
	local TempIconText 		= getglobal(name.."SlidingFrameContentTempIconText");
	local TempMapTagBkg 	= getglobal(name.."SlidingFrameContentTempMapTagBkg");
	local TempMapTagName 		= getglobal(name.."SlidingFrameContentTempMapTagName");

	getglobal(name.."FunctionTips"):Hide()
	if worldData.index ~= nil and SelectArchiveIndex == worldData.index then
		highlight:Show()
	else
		highlight:Hide()
	end
	tipsBkg:SetHeight(180)
	getglobal(updateBtn:GetName().."Name"):SetText(GetS(30005))
	local recentlyLableBkg =  getglobal(name.."SlidingFrameContentTagBkg");
	local recentlyLableName =  getglobal(name.."SlidingFrameContentTagName");

	if worldData.index ~= nil and recently_openworldid == worldInfo.worldid then
		recentlyLableBkg:Show()
		recentlyLableName:Show()
	else
		recentlyLableBkg:Hide()
		recentlyLableName:Hide()
	end

	if worldInfo.OpenCode == 1 then
		codeIcon:Show()
	else
		codeIcon:Hide()
	end

	local csid = worldInfo.cloudServerID
	csidBtn:Hide()
	if csid and csid > 0 then
		csidBtn:Show()
		local csuin = worldInfo.owneruin
		if worldInfo.realowneruin ~= 0 then
			csuin = worldInfo.realowneruin
		end
		csidBtnName:SetText(csuin .. "-" .. csid)
	end
	local checkwid = worldInfo.fromowid;
	if checkwid == 0 then
		checkwid = worldInfo.worldid;
	end
	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(checkwid);
	local mapAppealStatus = MapAppealStatus(checkwid)

	restrict:Hide();
	inReview:Hide();
	if worldInfo.open > 0 then
		shareTag:Show();
	else
		shareTag:Hide();
	end

	loadBar:SetWidth(0);
	bar:SetWidth(0);
	fail:Hide();
	downTag:Hide();
	savedTag:Hide();

	delBtn:SetPoint("top", name.."FunctionTipsBkg", "top", 0, 120);
	if IsNewbieWorld(worldInfo.worldid) then
		delBtn:SetPoint("top", name.."FunctionTipsBkg", "top", 0, 0);
		delBtn:Show();
		opDesc:Show();
		if ClientMgr:isPC() then
			opDesc:SetText(GetS(3898));
		else
			opDesc:SetText(GetS(507));
		end
		timeFont:Hide();
		shareBtn:Hide();
		authorBtn:Hide();
		calUpload:Hide();
		uploadBtn:Hide();
		backupBtn:Hide();
		editopenbtn:Hide();
		pauseBtn:Hide();
		cancelBtn:Hide();
		loadBtn:Hide();
		pauseLoad:Hide();
		proBkg:Hide();
		bar:Hide();
		loadBkg:Hide();
		loadBar:Hide();
		shotPic:Show();
		loadDesc:Hide();
	elseif worldInfo.realowneruin ~= 0 and worldInfo.realowneruin ~= 1 and worldInfo.owneruin ~= worldInfo.realowneruin then   		--下载别人的地图
		--realowneruin存在，且realowneruin和owneruin不一样的情况
		downTag:Show();
		if worldInfo.openpushtype < 4 then --没在下载任务中
			authorBtn:Show();
			timeFont:Show();
			loadBtn:Hide();
			pauseLoad:Hide();
			loadBkg:Hide();
			loadBar:Hide();
			loadDesc:Hide();
		else
			authorBtn:Hide();
			timeFont:Hide();
			loadDesc:Show();
			loadBkg:Show();
			loadBar:Show();
			local process = worldInfo.openpushprocess;
			loadBar:SetWidth(0.68*process);
			if worldInfo.openpushtype == 4 or worldInfo.openpushtype == 5 then
				pauseLoad:Show();
				loadBtn:Hide();
				shareTag:Hide();
				if worldInfo.openpushtype == 4 then			--下载中
					local text = GetS(508)..process.."%";
					loadDesc:SetText(text);
				else							--等待下载
					loadDesc:SetText(GetS(509));
				end
			elseif worldInfo.openpushtype == 6 then 			--暂停下载
				loadBtn:Show();
				pauseLoad:Hide();
				shareTag:Hide();
				local process = AccountManager:checkLoadWorld(worldInfo.worldid);
				local text = GetS(510)..process.."%";
				loadDesc:SetText(text);
			end
		end

		delBtn:Show();
		--loadBtn:Show();
		shotPic:Show();
		proBkg:Hide();
		bar:Hide();
		shareBtn:Hide();
		cancelBtn:Hide();
		updateBtn:Hide();
		autonymCheckBtn:Hide();
		calUpload:Hide();
		uploadBtn:Hide();
		backupBtn:Show();
		pauseBtn:Hide();
		opDesc:Hide();
		editopenbtn:Hide();
	else						--自己的地图
		if worldInfo.openpushtype == 1 then --正在上传分享
			shareBtn:Hide();
			authorBtn:Hide();
			uploadBtn:Hide();
			cancelBtn:Hide();
			updateBtn:Hide();
			autonymCheckBtn:Hide();
			loadBtn:Hide();
			pauseLoad:Hide();
			loadBkg:Hide();
			loadBar:Hide();
			loadDesc:Hide();
			delBtn:Hide();
			timeFont:Show();
			calUpload:Show();
			pauseBtn:Show();
			proBkg:Show();
			bar:Show();
			bar:SetWidth(1.0*worldInfo.openpushprocess);
		elseif worldInfo.openpushtype == 2 then --暂停分享
			shareBtn:Hide();
			authorBtn:Hide();
			pauseBtn:Hide();
			cancelBtn:Hide();
			updateBtn:Hide();
			autonymCheckBtn:Hide();
			loadBtn:Hide();
			pauseLoad:Hide();
			loadBkg:Hide();
			loadBar:Hide();
			loadDesc:Hide();
			delBtn:Hide();
			uploadBtn:Show();
			timeFont:Show();
			calUpload:Show();
			proBkg:Show();
			bar:Show();
			bar:SetWidth(0.68*worldInfo.openpushprocess);
		elseif worldInfo.open > 0 then
			if worldInfo.openpushtype >= 4 then --下载
				shareBtn:Hide();
				authorBtn:Hide();
				calUpload:Hide();
				uploadBtn:Hide();
				pauseBtn:Hide();
				cancelBtn:Hide();
				updateBtn:Hide();
				autonymCheckBtn:Hide();
				proBkg:Hide();
				bar:Hide();
				timeFont:Hide();
				loadDesc:Show();
				delBtn:Show();
				loadBkg:Show();
				loadBar:Show();


				local process = AccountManager:checkLoadWorld(worldInfo.worldid);
				loadBar:SetWidth(0.68*process);
				if worldInfo.openpushtype == 4 or worldInfo.openpushtype == 5 then
					pauseLoad:Show();
					loadBtn:Hide();
					if worldInfo.openpushtype == 4 then			--下载中
						local text = GetS(508)..process.."%";
						loadDesc:SetText(text);
					else							--等待下载
						loadDesc:SetText(GetS(509));
					end
				elseif worldInfo.openpushtype == 6 then 			--暂停下载
					loadBtn:Show();
					pauseLoad:Hide();

					local process = AccountManager:checkLoadWorld(worldInfo.worldid);
					local text = GetS(510)..process.."%";
					loadDesc:SetText(text);
				end
			elseif worldInfo.open == 2 then
				delBtn:Hide();
				shareBtn:Hide();
				authorBtn:Hide();
				calUpload:Hide();
				uploadBtn:Hide();
				pauseBtn:Hide();
				loadBtn:Hide();
				pauseLoad:Hide();
				proBkg:Hide();
				bar:Hide();
				loadBkg:Hide();
				loadBar:Hide();
				loadDesc:Hide();
				cancelBtn:Show();
				savedTag:Show();
				timeFont:Show();
				shareTag:Hide();

				if not if_open_mapupload_autonymcheck() or AccountSafetyCheck:MiniAutonymCheckState() then
					updateBtn:Show();
					autonymCheckBtn:Hide();
				else
					updateBtn:Hide();
					autonymCheckBtn:Show();
				end
				if worldInfo.openpushtype == 3 then --云保存了没数据
					loadBtn:Show()
					updateBtn:Hide()
					autonymCheckBtn:Hide()
					cancelBtn:Hide();
					delBtn:Show()
				end
			elseif worldInfo.openpushtype == 0 then --已分享
				delBtn:Hide();
				shareBtn:Hide();
				authorBtn:Hide();
				calUpload:Hide();
				uploadBtn:Hide();
				pauseBtn:Hide();
				loadBtn:Hide();
				pauseLoad:Hide();
				proBkg:Hide();
				bar:Hide();
				loadBkg:Hide();
				loadBar:Hide();
				loadDesc:Hide();
				cancelBtn:Show();
				updateBtn:Show();
				autonymCheckBtn:Hide();
				autonymCheckBtn:Hide();
				timeFont:Show();
			elseif worldInfo.openpushtype == 3 then --分享了没数据
				shareBtn:Hide();
				authorBtn:Hide();
				calUpload:Hide();
				uploadBtn:Hide();
				pauseBtn:Hide();
				cancelBtn:Hide();
				updateBtn:Hide();
				autonymCheckBtn:Hide();
				loadBtn:Show();
				pauseLoad:Hide();
				proBkg:Hide();
				bar:Hide();
				loadBkg:Hide();
				loadBar:Hide();
				loadDesc:Hide();
				delBtn:Show();
				timeFont:Show();
			end
		elseif worldInfo.open == 0 then
			if worldInfo.openpushtype == 0 then	--什么都不干
				authorBtn:Hide();
				uploadBtn:Hide();
				cancelBtn:Hide();
				updateBtn:Hide();
				autonymCheckBtn:Hide();
				loadBtn:Hide();
				pauseLoad:Hide();
				loadBkg:Hide();
				loadBar:Hide();
				loadDesc:Hide();
				calUpload:Hide();
				pauseBtn:Hide();
				proBkg:Hide();
				bar:Hide();
				delBtn:Show();
				shareBtn:Show();
				timeFont:Show();
			elseif worldInfo.openpushtype == 3 then --未分享且没数据
				shareBtn:Hide();
				authorBtn:Hide();
				pauseBtn:Hide();
				cancelBtn:Hide();
				updateBtn:Hide();
				autonymCheckBtn:Hide();
				loadBtn:Hide();
				pauseLoad:Hide();
				loadBkg:Hide();
				loadBar:Hide();
				loadDesc:Hide();
				uploadBtn:Hide();
				calUpload:Hide();
				proBkg:Hide();
				bar:Hide();
				delBtn:Show();
				timeFont:Show();
			elseif worldInfo.openpushtype >= 4 then --下载
				shareBtn:Hide();
				authorBtn:Hide();
				calUpload:Hide();
				uploadBtn:Hide();
				pauseBtn:Hide();
				cancelBtn:Hide();
				updateBtn:Hide();
				autonymCheckBtn:Hide();
				proBkg:Hide();
				bar:Hide();
				timeFont:Hide();
				loadDesc:Show();
				delBtn:Show();
				loadBkg:Show();
				loadBar:Show();

				local process = AccountManager:checkLoadWorld(worldInfo.worldid);
				loadBar:SetWidth(0.68*process);
				if worldInfo.openpushtype == 4 or worldInfo.openpushtype == 5 then
					pauseLoad:Show();
					loadBtn:Hide();
					if worldInfo.openpushtype == 4 then			--下载中
						local text = GetS(508)..process.."%";
						loadDesc:SetText(text);
					else							--等待下载
						loadDesc:SetText(GetS(509));
					end
				elseif worldInfo.openpushtype == 6 then 			--暂停下载
					loadBtn:Show();
					pauseLoad:Hide();

					local process = AccountManager:checkLoadWorld(worldInfo.worldid);
					local text = GetS(510)..process.."%";
					loadDesc:SetText(text);
				end
			end
		end
		opDesc:Hide();
		backupBtn:Show();
		if worldInfo.openpushtype ~= 3 and (worldInfo.worldtype == 5 or worldInfo.worldtype == 4 ) then
			tipsBkg:SetHeight(240)
			editopenbtn:SetPoint("top", name.."FunctionTipsBkg", "top", 0, 180);
			editopenbtn:Show()
		else
			editopenbtn:Hide()
		end
	end

	local env_ = get_game_env()
	getglobal(restrict:GetName().."Name"):SetText(GetS(16266)) --违规
	getglobal(inReview:GetName().."Name"):SetText(GetS(20309)) --审核中
	if worldInfo.open ~= 0 then
		if mapIsBreakLaw == 1 or mapAppealStatus == 0 then
			getglobal(inReview:GetName().."Name"):SetText(GetS(10656)) --复审中
			savedTag:Hide();
			shareTag:Hide();
			inReview:Show();
			restrict:Hide();
			if worldInfo.openpushtype ~= 3 then
				cancelBtn:Hide();
				updateBtn:Show();
				getglobal(updateBtn:GetName().."Name"):SetText(GetS(10651))
				tipsBkg:SetHeight(130)
			end
		elseif mapIsBreakLaw == 2 or mapAppealStatus == 2 or worldInfo.OpenSvr == 4 or worldInfo.OpenSvr == 14 then
			savedTag:Hide();
			shareTag:Hide();
			inReview:Hide();
			restrict:Show();
		elseif env_ < 10 and worldInfo.open == 1 and not IsDownloadMap(worldInfo) then
	  --------------------------------OpenSvr字段值与含义-------------------------------------
	  -- 	   CHECKING        = 0,    ---未定 审核中    (等待大数据系统审核)(仅自己可见)
	  --       OK              = 1,    ---审核A成功      (公开)
	  --       HIDE            = 2,    ---隐藏           (仅自己可见)(服务器自动审核失败+0.43.5之前历史存量+人工审核待修改)
	  --       SEARCH_ONLY     = 3,    ---仅搜索可见     (半公开，不推荐)
	  --   	   FAIL            = 4,    ---审核失败-封禁  (仅自己可见)(人工审核不通过)
	  --       REAL_NAME_HIDE  = 7,    ---未实名隐藏     (仅自己可见)
	  --       HIDE_THUMB      = 8,    ---隐藏截图       (地图可见)
	  --       WAIT_GM         = 9,    ---等待GM人工审核 (仅自己可见) (地图)
	  --       GM_CHECK_OK     = 10,   ---GM人工审核成功
	  --       OK_LIMIT        = 13,   ---限流灰度测试
	  --   	   FAIL2           = 14,   ---违规 （不能申诉）

			if worldInfo.OpenSvr == 0 or worldInfo.OpenSvr == 9 then
				if worldInfo.OpenSvr == 9 then
					getglobal(inReview:GetName().."Name"):SetText(GetS(10656)) --复审中
				end
				savedTag:Hide();
				shareTag:Hide();
				inReview:Show();
				restrict:Hide();
				if worldInfo.openpushtype == 0 then
					cancelBtn:Hide();
					updateBtn:Show();
					editopenbtn:SetPoint("top", name.."FunctionTipsBkg", "top", 0, 120);
					getglobal(updateBtn:GetName().."Name"):SetText(GetS(10651))
					tipsBkg:SetHeight(180)
				end
			elseif worldInfo.OpenSvr == 2 then
				savedTag:Hide();
				shareTag:Hide();
				inReview:Hide();
				restrict:Show()
				getglobal(restrict:GetName().."Name"):SetText(GetS(25811)) -- 待修改
			end
		end
	end

	--Label
	if IsNewbieWorld(worldInfo.worldid) then
		tagIcon:Hide();
		tag:Hide();
	else
		tagIcon:Show();
		tag:Show();
		if worldInfo == nil then return end
		local gameLabel = 0;
		if worldInfo ~= nil then
			gameLabel = worldInfo.gameLabel;
		end
		if gameLabel == 0 or worldInfo.worldtype == 9 then
			gameLabel = GetLabel2Owtype(worldInfo.worldtype);
		end
		SetRoomTag(tagIcon, tag, gameLabel);

		if worldInfo.owneruin == worldInfo.realowneruin then
			if worldInfo.worldtype == 4 then
				tag:SetText(GetS(3807));
			elseif worldInfo.worldtype == 5 then
				tag:SetText(GetS(3806));
			end
		end
	end
	local huires = Snapshot:getSnapshotTexture(worldInfo.worldid);
	shotPic:SetTextureHuires(huires);
	--图标
	SetGameModelIcon(modelPic, worldInfo.worldtype);
	--录像模式图标
	SetVideoModeIcon(backupBtnIcon,backupBtnName,worldInfo.worldtype)

	--极限模式
	if worldInfo.worldtype == 2 then
		shareBtn:Hide();
		if worldInfo.flag == 32 then	--已经失败
			fail:Show();
		end
	end

	if gIsSingleGame then
		shareBtn:Hide()

		if not IsNewbieWorld(worldInfo.worldid) then
			delBtn:SetPoint("top", name.."FunctionTipsBkg", "top", 0, 60);
		end
	end

	--存档名
	--多语言显示, 只有下载的地图才需要处理.
	--print("存档名字多语言显示:");
	--print("multilangname = ", worldInfo.multilangname);
	--worldInfo.worldname;
	local nameText = worldname
	if worldInfo.owneruin ~= worldInfo.realowneruin and not isEducationalVersion then
		if multilangname and get_game_env() >= 10 then --规避国内版本地图有多语言配置导致下载的地图在存档界面显示奇怪的名称的问题
			-- local lang_now  = worldInfo.translate_currentlang;	--get_userset_lang();
			local lang_now  = get_game_lang();
			print("lang_now = ", lang_now);
			print("nameText = ", nameText);
			nameText = SignManagerGetInstance():parseTextFromLanguageJson(multilangname, lang_now);

			if not(nameText and #nameText > 0) then
				--worldInfo.worldname;
				nameText = worldname
			end
		end
	end
	--如果昵称是迷你号不需要屏蔽
	if not IsIgnoreReplace(nameText, {CheckMiniAccountNick = true}) then
		nameText = DefMgr:filterString(nameText, false)
	end
	nameRich:SetText(nameText, 73, 70, 63);

	--备份状态
	--local nameWidth = nameRich:getLineWidth(0);
	--local scaleX = UIFrameMgr:GetScreenScaleX();
	--bakupStat:SetPoint("left", nameRich:GetName(), "left", (nameWidth + 4)/scaleX+31, 0);
	if (not IsNewbieWorld(worldInfo.worldid)) and CSOWorld:checkWorldHasBackup(worldInfo.worldid) then
		bakupStat:Show();
		bakupStat:SetText(GetS(4030));
	else
		bakupStat:Hide();
	end

	-- local time = GetS(511).."   ";
	--登录时间
	if worldInfo.logintime == 0 then
		timeFont:SetText(GetS(512));
	else
		local curTime 	= os.time();
		local times	= math.floor(worldInfo.logintime/86400) * 86400
		if curTime - times >= 86400 then		--大于一天，显示日期天数。
			if GetApartDay(curTime, times) == 1 then
				timeFont:SetText(GetS(513)..GetS(516));
			else
				timeFont:SetText(GetApartDay(curTime, times)..GetS(514)..GetS(516));
			end
		else
			timeFont:SetText(os.date("%H", worldInfo.logintime)..":"..os.date("%M", worldInfo.logintime)..GetS(516));
		end
	end

	--插件
	if ModMgr:isExistMod(worldInfo.worldid, true) and not IsNewbieWorld(worldInfo.worldid) then
		modIcon:Show();
		--editModBtn:Show();
	else
		modIcon:Hide();
		--editModBtn:Hide();
	end


	--材质包
	local materialType = 0;
	local materialUUID = "";
	materialUUID,materialType=AccountManager:GetNotDefaultModMaterialUUID(worldInfo.worldid,materialUUID,materialType);
	if materialUUID == "" then
		materialIcon:Hide();
	else
		if IsNewbieWorld(worldInfo.worldid) or worldInfo.owneruin ~= AccountManager:getUin() or materialType == 0 then
			materialIcon:Hide();
		else
			materialIcon:Show();
		end
	end

	if worldInfo.OpenCode and worldInfo.OpenCode == 1 then
		codeIcon:Show()
	else
		codeIcon:Hide()
	end

	if (worldInfo.TempType > 0) and (worldInfo.worldtype ~= 9 ) then
		local _tempTypeDescStrIDs = {34407, 34406};
		local _tempTypeDescID = _tempTypeDescStrIDs[worldInfo.TempType];
		local _tempTypeStr = _tempTypeDescID and GetS(_tempTypeDescID) or "";
	 	TempIconText:SetText(_tempTypeStr);
	 	TempIcon:Show();
	 	TempIconText:Show();
	else
		TempIcon:Hide();
	 	TempIconText:Hide();
	end


	-- if (worldInfo.pwid > 0 and worldInfo.gwid > 0) and (worldInfo.worldtype ~= 9 ) then
	-- 	TempMapTagBkg:Show();
	--  	TempMapTagName:Show();
	-- else
		TempMapTagBkg:Hide();
	 	TempMapTagName:Hide();
	-- end

	-- 搬运工具 相关
	if getglobal("ArchiveInfoFrameConvertBtn") and getglobal("ArchiveInfoFrameConvertBtn"):IsShownSelf() then
		local cellCheckBox = getglobal(name.."SlidingFrameCheckBox")
		if cellCheckBox then
			local isCheck = ArchiveCarry_DataGet("check", worldInfo.worldid)
			cellCheckBox:Show()
			ArchiveCarry_ViewSetCheckBox(cellCheckBox, isCheck)
			local code = ArchiveCarry_DataGet("code", worldInfo.worldid)
			ArchiveCarry_ViewSetResultText(getglobal(name), code, code == nil)
		end
	end
end

function GetApartDay(time1, time2)
	local day = math.floor( (time1-time2)/86400 );
	if day > 7 then day = 7 end;
	return day;
end

--选中箭头
local CAchangeSpeed = 2;
local CAchangeOffset = CAchangeSpeed;
local CAcurOffset = 0;

local FingerScale = 1;
local ScaleSpeed = 0.1;

function LobbyFrame_OnUpdate()
	UpdateArchiveBackupGuideDisp();

	sendEventReports();

	-- UpdateVerifyCodeCoolDown(arg1);

	--CreateMapGuide
	-- local finger = getglobal("CreateArchiveCreateFinger");
	-- if finger:IsShown() then
	-- 	FingerScale = FingerScale + ScaleSpeed;
	-- 	if FingerScale > 1.3 then
	-- 		FingerScale = 1.3;
	-- 		ScaleSpeed = -0.05;
	-- 	elseif FingerScale < 1.0 then
	-- 		FingerScale = 1.0;
	-- 		ScaleSpeed = 0.05;
	-- 	end
	-- 	local width = 100 * FingerScale;
	-- 	local height = 100 * FingerScale;
	-- 	finger:SetSize(width, height);
	-- end

	--新手引导流程优化，加入点击地图的手指和点击单人游戏的手指
	local listview = getglobal("ArchiveBox")
	local cell = listview:cellAtIndex(0)
	local fingerGuide = cell and getglobal(cell:GetName().."SlidingFrameFingerGuide") or nil
	local finger1 = fingerGuide and getglobal(fingerGuide:GetName().."Finger") or nil
	local finger2 = getglobal("ArchiveInfoFrameIntroduceStarGameBtnFinger")
	if fingerGuide and finger1 and fingerGuide:IsShown() then
		FingerScale = FingerScale + ScaleSpeed;
		if FingerScale > 1.3 then
			FingerScale = 1.3;
			ScaleSpeed = -0.05;
		elseif FingerScale < 1.0 then
			FingerScale = 1.0;
			ScaleSpeed = 0.05;
		end
		local width = 100 * FingerScale;
		local height = 100 * FingerScale;
		finger1:SetSize(width, height);
	end
	if finger2:IsShown() then
		FingerScale = FingerScale + ScaleSpeed;
		if FingerScale > 1.3 then
			FingerScale = 1.3;
			ScaleSpeed = -0.05;
		elseif FingerScale < 1.0 then
			FingerScale = 1.0;
			ScaleSpeed = 0.05;
		end
		local width = 100 * FingerScale;
		local height = 100 * FingerScale;
		finger2:SetSize(width, height);
	end

	UpdateUI_WaterMark("LobbyFrameWaterMarkFrameFont")
end

--获取开发者的存档位奖励
function GetDeveloperDeltaArchiveNum()
	if g_DeveloperInfo then
		return g_DeveloperInfo.DeltaArchiveNum or 0
	end
	return 0
end
--获取家园的存档位奖励
function GetHomeChestAwardArchiveNum()
	local level = HomeChestMgr:getSelfChestTreeLevel()
	if level > 0 then
		return level-1
	end
	return 0
end

--主动同步已[Desc5]的存档位信息
function RequestBoughtArchiveNum()
	if not g_BoughtArchiveNum then
		ReqSyncWorldListFromServer(AccountManager:getUin())
	end
end
--设置已[Desc5]的存档位
function SetBoughtArchiveNum( nArchive )
	g_BoughtArchiveNum = nArchive or 0
end
--获取已[Desc5]的存档位
function GetBoughtArchiveNum()
	return g_BoughtArchiveNum or 0
end
--获取存档位的[Desc5]上限
function GetBuyArchiveNumLimit()
	return 200
end
--[Desc5]存档位的单价
function GetBuyArchivePrice()
	return 10
end
-- --最大可创建存档数
-- function GetCreateMapMax()
-- 	if IsNoArchiveLimitUser() then
-- 		return 999
-- 	end
-- 	if IsNoArchiveLimitApiId() or isEducationalVersion then
-- 		return 999;
-- 	end
-- 	return 5 + GetDeveloperDeltaArchiveNum() + GetHomeChestAwardArchiveNum() + GetBoughtArchiveNum()
-- end
-- --最大可录像存档数
-- function GetCreateRecordMapMax()
-- 	if IsNoArchiveLimitUser() then
-- 		return 999
-- 	end
-- 	if IsNoArchiveLimitApiId() or isEducationalVersion then
-- 		return 999;
-- 	end
-- 	return 5 + GetDeveloperDeltaArchiveNum() + GetHomeChestAwardArchiveNum() + GetBoughtArchiveNum()
-- end

--创建存档最大限制
function CreateArchiveMaxNum( ... )
	if IsNoArchiveLimitUser() then
		return 999
	end
	if IsNoArchiveLimitApiId() or isEducationalVersion then
		return 999;
	end
	-- 新增审核账号扩充存档
	if IsUserOuterChecker(AccountManager:getUin()) then
		return 999
	end
	return 10 + GetDeveloperDeltaArchiveNum() + GetHomeChestAwardArchiveNum() + GetBoughtArchiveNum()
end

--	创建存档最大限制--22.12.5开始游戏改版，存档位需求不设上限（实际999），但是上传的限制还是要通过购买进行扩充
function CreateArchiveMaxNumExt( ... )
	--22.12.5开始游戏改版，存档位需求不设上限（实际999），但是上传的限制还是要通过购买进行扩充
	if IsNoArchiveLimitUserExt() then
		return 999
	end
	if IsNoArchiveLimitApiId() or isEducationalVersion then
		return 999;
	end
	-- 新增审核账号扩充存档
	if IsUserOuterChecker(AccountManager:getUin()) then
		return 999
	end
	return 10 + GetDeveloperDeltaArchiveNum() + GetHomeChestAwardArchiveNum() + GetBoughtArchiveNum()
end

--已创建存档的数量
function GetCreateArchiveNum( ... )
	return AccountManager:getMyWorldList():getMyCreateWorldNum() + AccountManager:getMyWorldList():getMyCreateRecordNum()
end

--自己创建且已上传到服务器的地图，包括审核中、异常、私有，不包括家园地图
function GetCreateUploadArchiveNum()
	local retCnt = 0
	local num = AccountManager:getMyWorldList():getNumWorld()
	for i=1, NEW_LOBBY_ARCHIVE_MAX do
		if i <= num then
			local worldInfo = AccountManager:getMyWorldList():getWorldDesc(i-1);
			if worldInfo and worldInfo._specialType ~= 1 and GetInst("lobbyDataManager"):IsMyOwnMapArchive(worldInfo) then
				if (worldInfo.open == 1 or  worldInfo.open == 2) then
					retCnt = retCnt + 1
				end
			end
		else
			break
		end
	end

	return retCnt
end

--创建存档
function LobbyFrameCreateNewWorldBtn_OnClick()
	-- local num = GetCreateMapMax();				--玩家可创建地图的最大数目
	-- if AccountManager:getMyWorldList():getMyCreateWorldNum() >= num then
	if GetCreateArchiveNum() >= CreateArchiveMaxNum() then
		--可以[Desc5]则先弹[Desc5]的窗口
		if  CanShowNotEnoughArchiveWithOperate(function () LobbyFrameCreateNewWorldBtn_OnClick() end) then
			return
		end

		local text = GetS(10);
		MessageBox(4, text);
		getglobal("MessageBoxFrame"):SetClientString( "创建地图上限" );

		return;
	end

	ResetCreateWorldMods();
	OpenCreateWorldFrame()
	HideLobby();

	--红点
	if not AccountManager:getNoviceGuideState("createmap") then
		Log("createmap: Set True !!!");
		AccountManager:setNoviceGuideState("createmap", true);
	end
end
----------------------------------------Regulations tips control--------------------------------
IsShowRegulationsTips = true;
------------------------------------------------------------------------------------------------
function CreateArchive_OnClick()
	-- if CreateMapGuideStep > 0 then
	-- 	statisticsGameEvent(901, '%s', 'UIGuideCreateMapFrame',"%d",GuideLobby,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()))
	-- end
	if CreateMapGuideStep==2 then
		CreateMapGuideStep = 3;
	end
	standReportEvent("32", "MINI_OLDGAMEOPEN_GAME_1", "CreateWorld", "click")
	LobbyFrameCreateNewWorldBtn_OnClick();
	IsShowRegulationsTips = true;
	getglobal("RegulationsTipsFrame"):Show();
end

function CreateArchiveJumpWorks_OnClick()
	if IsStandAloneMode() then return end
	standReportEvent("32", "MINI_OLDGAMEOPEN_GAME_1", "MoreMap", "click")
	if AccountManager:isLogin() and (AccountManager:getUin() or 0)>=1000 then
	else
		ShowGameTips(GetS(25832))
		return
	end

	MessageBox(31, GetS(4971), function(btn)
		if btn == 'right' then
			HideLobby();
			getglobal("MiniWorksFrame"):Show();
			-- statisticsGameEventNew(970,ClientMgr:getDeviceID(),1,tostring(get_game_lang()))
		else
			-- statisticsGameEventNew(970,ClientMgr:getDeviceID(),2,tostring(get_game_lang()))
		end
	end);
end

function LobbyFrameStartBtn_OnClick()

end

--从服务器下载自己分享过的存档
function DownMyWorld2Net(index, worldDesc)
	local netState = ClientMgr:getNetworkState();
	if netState == 0 then
		ShowGameTips(GetS(19), 3);
		return;
	end

	if worldDesc == nil then
		local archiveData = GetOneArchiveData(index);
		if archiveData == nil then
			return
		end

		worldDesc = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)
	end

	if worldDesc == nil then
		return
	end

	if ClientMgr:clientVersion() < ClientMgr:clientVersionFromStr(worldDesc.ownerCltVer) then
		ShowGameTips(GetS(426), 3);
		return;
	end

	IsNeedReset = false;

	StatisticsTools:gameEvent("LoadWorld");

	--加入下载列表中
	AccountManager:requestDownWorld(worldDesc.worldid, 4);
end

--商城
function LobbyFrameCollectBtn_OnClick()
	HideLobby();

	ShopJumpTabView(1)
end

--房间
function LobbyFrameRoomBtn_OnClick(keepRoomFrameData)
	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3);
		return;
	end
	if getglobal("LoadLoopFrame"):IsShown() then
		return;
	end
	local gen = nil
	if keepRoomFrameData then
		gen = "LobbyFrameRoomBtn_OnClick_keepRoomFrameData" 
	end
	if AccountManager:loginRoomServer(false, 0, gen) then
		ShowLoadLoopFrame(true, "file:lobby -- func:LobbyFrameRoomBtn_OnClick")
		IsLanRoom = false;
	else
		--ShowGameTips(GetS(506), 3);
	end
end

--局域网房间
function LobbyFrameLanRoomBtn_OnClick()
	if getglobal("LoadLoopFrame"):IsShown() then
		return;
	end
	if AccountManager:loginRoomServer(true) then
		ShowLoadLoopFrame(true, "file:lobby -- func:LobbyFrameLanRoomBtn_OnClick")
		IsLanRoom = true;
	else
		ShowGameTips(GetS(506), 3);
	end
end

function LobbyFrameCloseBtn_OnClick()
	-- 玩家关闭返回大厅，旧引导结束
	CreateMapGuideStep = 0

	if gIsSingleGame then
		getglobal("SetMenuFrame"):Show()
		return
	end
	standReportEvent("32", "MINI_OLDGAMEOPEN_GAME_1", "Close", "click")
	if IsUIStageEnable then
		UIStageDirector:popupStage(true)
		if not UIStageDirector:getTopStage() then
			ShowMiniLobby()
		end
	else
		HideLobby();
		-- getglobal("MiniLobbyFrame"):Show();
		ShowMiniLobby() --mark by hfb for new minilobby
	end

	--统计 新手引导 -继续冒险-返回首页
	if StatisticsNewWorldType == 1 then
		-- statisticsGameEvent(901, "%s", "GameHomepage","save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()))
		StatisticsNewWorldType = 0;
	end
end

--激活或者切换帐号
function LobbyFrameAccountBtn_OnClick()
	if IsStandAloneMode() then return end
	
	if NewAccountSwitchCfg and NewAccountSwitchCfg:IsOpen() then
		NewAccountManager:NotifyEvent(NewAccountManager.DLG_ACCOUNT_MANAGER, {})
	elseif IsEnableNewAccountSystem() then
		OpenAccountManagePanel("MinilobbyAccountManage")
	else
		getglobal("AccountLoginFrame"):Show();
	end
end

--存档界面星工场入口
function LobbyFrameARFactoryBtn_OnClick()
	if not if_open_ar_factory() then
		ShowGameTips(GetS(100264))
		return
	end

	ShopJumpTabView(3, 3)
	GetInst("UIManager"):GetCtrl("ShopCustomSkinLib"):ARFactoryBtnClicked()
	-- statisticsGameEventNew(50010, 3)
end

--21号广告位
function LobbyFrame21ADBtn_OnClick()
	if t_ad_data.canShow(21) then
		OnReqWatchAD21ReceiveAwards()
	else
		ShowGameTips(GetS(4980), 3)
	end
end

function LobbyFrame21ADBtnCanShow()
	local ADBtn = getglobal("LobbyFrame21ADBtn")
	if t_ad_data.canShow(21) then
		if not ADBtn:IsShown() then
			ADBtn:Show()
			StatisticsAD('show',21);
			if AccountManager.ad_show then AccountManager:ad_show(21); end
		end
	else
		ADBtn:Hide()
	end
end

--删除存档
function ArchiveDelete_OnClick()
	this:GetParentFrame():Hide();
	if not CanUseNet() then
		return;
	end
	local MessageBoxFrame = getglobal("MessageBoxFrame");

	local clientId = this:GetParentFrame():GetParentFrame():GetClientID();
	if clientId >= 0 then
		local archiveData = GetOneArchiveData(clientId);
		if archiveData == nil then return end

		local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
		local process = AccountManager:checkLoadWorld(worldInfo.worldid);

		local MessageBoxFrame = getglobal("MessageBoxFrame")
		if worldInfo.openpushtype >= 4 then
			IsNeedReset = true;
			MessageBox(1, GetS(16));
			MessageBoxFrame:SetClientUserData(0, clientId);
			MessageBoxFrame:SetClientString( "删除未下载完成地图" );
		else
			IsNeedReset = true;
			MessageBox(1, GetS(17));
			MessageBoxFrame:SetClientUserData(0,clientId);
			MessageBoxFrame:SetClientString( "删除地图" );
		end

		local mapflage="ExtremityTipsFrame_Space".."_"..worldInfo.worldid;--之前setkv里的东西删除
		setkv( mapflage, nil );
	end
end

-- 编辑模式打开
function ArchiveEditOpen_OnClick()

	local archiveData = GetOneArchiveData(SelectArchiveIndex);
	if archiveData == nil then return end
	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)
	if worldInfo.openpushtype >= 4 then
		ShowGameTips(GetS(15), 3);
		return;
	end
	if AccountManager.setForceOpenWorldType then
		AccountManager:setForceOpenWorldType(worldInfo.worldid,4)
	end
	local standby1 = ""
	local mapOwn
	-- 是自己图
	if worldInfo.realowneruin == AccountManager:getUin() then
		standby1 = "1"
		mapOwn = GetInst("ReportGameDataManager"):GetGameMapOwnDefine().myMap
	else
		standby1 = "2"
		mapOwn = GetInst("ReportGameDataManager"):GetGameMapOwnDefine().otherMap
	end
	standby1 = standby1.."1"
	-- local gameLabel = GetLabel2Owtype(worldInfo.worldtype);
	-- -- 冒险模式
	-- if gameLabel == 2 then
	-- 	standby1 = standby1.."1"
	-- -- 创造模式
	-- elseif gameLabel == 3 then
	-- 	standby1 = standby1.."2"
	-- -- 开发者模式
	-- else
	-- 	standby1 = standby1.."3"
	-- end
	standby1 = standby1 .. tostring(worldInfo.worldtype)
	-- game_open上报
	standReportGameOpenParam = {
		standby1    = standby1,
		sceneid     = "32",
		cardid		= "MINI_OLDGAMEOPEN_GAME_1",
		compid		= "SinglePlayer"
	}
    
	GetInst("ReportGameDataManager"):NewGameLoadParam("32","MINI_OLDGAMEOPEN_GAME_1","SinglePlayer")
	GetInst("ReportGameDataManager"):SetGameMapOwn(mapOwn)
	GetInst("ReportGameDataManager"):SetGameNetType(GetInst("ReportGameDataManager"):GetGameNetTypeDefine().singleMode)
    GetInst("ReportGameDataManager"):SetGameMapMode(worldInfo.worldtype)

	RequestEnterWorld(worldInfo.worldid, false, function(succeed)
		if succeed then
			EnterWorld_ExtraSet("", 1)
			HideLobby();
			ShowLoadingFrame();
			ns_ma.ma_play_map_set_enter( { where="single"} )
			-- statisticsGameEvent(8006,"%d",worldInfo.worldType);
		end
	end);
end

--放弃上传
function ArchiveCancelUpload_OnClick()
	this:GetParentFrame():Hide();
	local archiveData = GetOneArchiveData(this:GetParentFrame():GetParentFrame():GetClientID());
	if archiveData == nil then return end

	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
	IsNeedReset = false;
	ShareingMapIndex = -1;
	AccountManager:requestAbortOpenWorld(worldInfo.worldid);
end

--分享存档
function ArchiveShare_OnClick()
	if IsStandAloneMode() then return end

	if ns_version.upload_limit and ns_version.upload_limit.tree_level and ns_version.upload_limit.tree_level == -1 then
		ShowGameTips(GetS(339))
		return
	end

	this:GetParentFrame():Hide();
	if ns_data.IsGameFunctionProhibited("m", 10577, 10578) then
		return
	end

	if ClientMgr:isMobile() and CheckHasCrackTools() then  --安装了破解软件
		return;
	end

	local archiveIndex = this:GetParentFrame():GetParentFrame():GetClientID();
	local archiveData = GetOneArchiveData(archiveIndex);
	if archiveData == nil then return end

	--[[地图上传 账号校验]]
	if not ArchiveShareAccountCheck(AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)) then
		return
	end

	Translate_ArchiveIndex = archiveIndex;
	local worldDesc = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
	curShareMapInfo.worldid = 0;
	curShareMapInfo.multilangname = "";
	curShareMapInfo.multilangdesc = "";
	if worldDesc then
		curShareMapInfo.worldid = worldDesc.worldid;
		curShareMapInfo.multilangname = worldDesc.multilangname;
		curShareMapInfo.multilangdesc = worldDesc.multilangdesc;
		print("ArchiveUpdate:multilangname = ", curShareMapInfo.multilangname);
		print("ArchiveUpdate:multilangdesc = ", curShareMapInfo.multilangdesc);
	end

	print("ArchiveShare_OnClick4")
	if ClientMgr:getVersionParamInt("ShareExsitMod", 1) ~= 1 and worldDesc ~= nil and AccountManager:isExistMod(worldDesc.worldid) then
		ShowGameTips(GetS(3809), 3);
		return;
	end

	if NewShareArchiveFrame then
		local worldId = 0;
		local archiveData = GetOneArchiveData(archiveIndex);
		if archiveData then
			worldDesc = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
			worldId = worldDesc and worldDesc.worldid or 0;
		end
		
		local param = {};
		param.archiveIndex = archiveIndex;
		param.shareType = 1;	--1:分享地图 2:更新分享
		param.worldId = worldId;
		GetInst("UIManager"):Open("ShareArchive", param);
	else
		getglobal("ShareArchiveInfoFrame"):Show();
		getglobal("ShareArchiveInfoFrame"):SetClientUserData(0, archiveIndex);
		getglobal("ShareArchiveInfoFrame"):SetClientUserData(1, 1);
	end
end

--上传地图
function ArchiveUpload_OnClick()
	this:GetParentFrame():Hide();
	if not CanUseNet() then
		return;
	end

	if ClientMgr:isMobile() and CheckHasCrackTools() then  --安装了破解软件
		return;
	end

	local MessageBoxFrame = getglobal("MessageBoxFrame");

	local clientId = this:GetParentFrame():GetParentFrame():GetClientID();
	if clientId >= AccountManager:getMyWorldList():getNumWorld() then return end


	local netState = ClientMgr:getNetworkState();
	if netState == 0 then
		ShowGameTips(GetS(18), 3);
	elseif netState == 2 then
		if clientId >= 0 then
			MessageBox(2, GetS(21));
			MessageBoxFrame:SetClientUserData(0, clientId);
			MessageBoxFrame:SetClientString( "继续分享" );
		end
	else
		ContunueShare(clientId);
	end
end

--继续上传
function ContunueShare(clientId)
	local worldInfo = nil
	if isEnableNewLobby() then
		local worldid = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
		local worldInfo = AccountManager:findWorldDesc(worldid)
	else
		local archiveData = GetOneArchiveData(clientId);
		if archiveData == nil then return end
		worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
	end
	ContinueUploadMap(worldInfo.worldid);
	ShareingMapIndex = clientId;
end

--暂停上传地图
function ArchiveUploadPause_OnClick()
	this:GetParentFrame():Hide();
	local clientId = this:GetParentFrame():GetParentFrame():GetClientID();
	if clientId >= AccountManager:getMyWorldList():getNumWorld() then return end

	PauseShare(clientId);
end


VideoWorldDesc =nil;

--备份地图
function ArchiveBackup_OnClick()
	this:GetParentFrame():Hide();
	local clientId = this:GetParentFrame():GetParentFrame():GetClientID();
	if clientId >= 0 then
		local archiveData = GetOneArchiveData(clientId);
		if archiveData == nil then return end

		local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
		if worldInfo.worldtype == 9 and RecordPkgMgr:canRecordVideo() then    --如果是录像存档
			VideoWorldDesc = worldInfo;
			getglobal("VideoConversionFrame"):Show();
		else
			if worldInfo.openpushtype == 1 or worldInfo.openpushtype == 2 then --正在分享的地图 不能备份
				ShowGameTips(GetS(3697), 3);
				return;
			end

			if worldInfo.openpushtype == 3 then --分享了没数据
				DownLoadWorld(worldInfo, clientId) --走下载提示
				return
			end

			local owid = worldInfo.worldid;
			ShowWorldBackupFrame(owid);
		end
	end
end

function  FunctionTipsFrameCloseBtn_OnClick()
	this:GetParentFrame():Hide();
end

function VideoConversionFrameRefuseBtn_OnClick()
	getglobal("VideoConversionFrame"):Hide();
end


function VideoConversionFrameAgreeBtn_OnClick()
	local time = RecordPkgMgr:getRecordLen(VideoWorldDesc.worldid)/1000

	if RecordPkgMgr:getLeftSize() > 0 and RecordPkgMgr:getLeftSize()<200 + time then
		MessageBox(4, GetS(7505) , function(btn)
		end);
	elseif not RecordPkgMgr:isNewRecordVedioExist(VideoWorldDesc.worldid) then    --如果本地文件不存在，导出录像
		--录制
		RequestEnterWorld(VideoWorldDesc.worldid, false, function(succeed)
			if succeed then
				RecordPkgMgr:setEdit(false)
				ShowLoadingFrame();
				HideLobby();
				RecordPkgMgr:startRecordVedio(VideoWorldDesc.worldid)
				getglobal("LoadingFrame"):SetFrameStrataInt(5);
				getglobal("LoadingFrame"):Show();
			end
		end);
	else
		ShowGameTips(GetS(7589),3)
	end
	getglobal("VideoConversionFrame"):Hide();

end

function VideoConversionFrame_OnShow()
	local time = RecordPkgMgr:getRecordLen(VideoWorldDesc.worldid)/1000
	getglobal("VideoConversionFrameContentText"):SetText(GetS(7584,VideoWorldDesc.worldname,string.format("%d",time).."M",formatTime(time),RecordPkgMgr:getVedioPath()))
	getglobal("ArchiveBox"):setDealMsg(false);
end

function VideoConversionFrame_OnHide()
	getglobal("ArchiveBox"):setDealMsg(true);

end

--编辑地图材质包
function ArchiveInfoFrameEditMaterialBtn_OnClick()
	if IsStandAloneMode() then return end
	AccountManager:setNoviceGuideState("guidematmod", true);
	getglobal("ArchiveInfoFrameEditMaterialBtnGuide"):Hide();
    
	ArchiveWorldDesc  = AccountManager:findWorldDesc(ArchiveWorldDescWorldId)
	if ArchiveWorldDesc then
		MapMaterialFrame_BeginEdit(ArchiveWorldDesc.worldid);
		HideMapDetailInfo();
	end
end

--编辑地图Mod
function ArchiveInfoFrameEditModBtn_OnClick(curOwid)
	local owid = nil
	ArchiveWorldDesc  = AccountManager:findWorldDesc(ArchiveWorldDescWorldId)
	if ArchiveWorldDesc then
		local worldInfo = ArchiveWorldDesc;
		owid = curOwid or worldInfo.worldid;
	else
		if CurWorld and CurWorld.getOWID then
			owid = CurWorld:getOWID()
		end
	end
	if owid then
		Log("EditMod "..owid);

		if ModEditorMgr:ensureMapHasDefualtMod(owid) then
			if ClientCurGame:isInGame() or ModMgr:loadWorldMods(owid) then
				Log("loadWorldMods ok");

				ClearSelectedMods();

				for i = 1, ModMgr:getMapModCount() do
					local moddesc = ModMgr:getMapModDescByIndex(i-1);
					table.insert(MapLoadedMods, moddesc.uuid);
				end

				local uuid = ModMgr:getMapDefaultModUUID();
				Log("uuid = "..uuid);

				--:去掉
				--FrameStack.reset("LobbyFrame");

				HideMapDetailInfo();
				local args = {
					editmode = 4,
					uuid = uuid,
					isMapMod = true,
					owid=owid,
				};
				if UseNewModsLib then
			        args.isnew = true
			        args.enterType = 2
			        FrameStack.enterNewFrame("ModsLib", args, OnEditModFinish, owid)
			    else
					FrameStack.enterNewFrame("MyModsEditorFrame", args, OnEditModFinish, owid);
			    end
			end
		end
	end
end

--存档多语言选择
function ArchiveInfoFrameMultiLangBtn_OnClick( ... )
	--ShowGameTips(tostring(ArchiveWorldDesc.worldid))
	--ShowGameTips(tostring(AccountManager:getCurWorldId()))
	--分享/更新存档后，worlddesc被释放掉？重新拉取一下...
	if SelectArchiveIndex ~= -1 then
		local archiveData = GetOneArchiveData(SelectArchiveIndex);
		if archiveData then
			ArchiveWorldDesc = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
			ArchiveWorldDescWorldId  = ArchiveWorldDesc.worldid
			--ShowGameTips(tostring(ArchiveWorldDesc.worldid))
		end
	end
	if ArchiveWorldDesc then
		for i=0,15 do
			local bit = LuaInterface:band(AccountManager:getWorldSupportLang(ArchiveWorldDesc.worldid), math.pow(2,i))
			if i ~= get_game_lang() then
				if bit == math.pow(2,i) then
					getglobal("MultiLangSelectFrameL"..(i+1).."TickIcon"):Show()
				else
					getglobal("MultiLangSelectFrameL"..(i+1).."TickIcon"):Hide()
				end
			end
		end
	end

	local word = 0
	for i=0, 15 do
		word = word + math.pow(2,i)
	end
	word = word - math.pow(2, 8)
	if ArchiveWorldDesc.translate_supportlang == word then
		getglobal("MultiLangSelectFrameAllBtnTickIcon"):Show()
	else
		getglobal("MultiLangSelectFrameAllBtnTickIcon"):Hide()
	end


	getglobal("MultiLangSelectFrame"):Show()
end

--已下载地图语言选择
function ArchiveInfoFrameLangSelectBtn_OnClick( ... )
	getglobal("SelectMapLangFrame"):Show()
end

function OnEditModFinish(leavingframe, owid)
	Log("OnEditModFinish");
	if not ClientCurGame:isInGame() then
		ModMgr:unLoadCurMods(owid);
	end
end

function PauseShare(clientId)
	local archiveData = GetOneArchiveData(clientId);
	if archiveData == nil then return end

	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)
	PauseUploadMap(worldInfo.worldid);

	ShareingMapIndex = -1;
end

--取消分享
function ArchiveCancel_OnClick()
	if IsStandAloneMode() then return end

	this:GetParentFrame():Hide();
	local clientId = this:GetParentFrame():GetParentFrame():GetClientID();
	if clientId >= AccountManager:getMyWorldList():getNumWorld() then return end

	MessageBox(5, GetS(776));
	getglobal("MessageBoxFrame"):SetClientUserData(0,clientId);
	getglobal("MessageBoxFrame"):SetClientString( "取消分享" );
end

--分享更新
function ArchiveUpdate_OnClick()
	if IsStandAloneMode() then return end

	this:GetParentFrame():Hide();
	local archiveIndex = this:GetParentFrame():GetParentFrame():GetClientID();
	local archiveData = GetOneArchiveData(archiveIndex);
	if archiveData == nil then return end
	local worldDesc = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)
	if not worldDesc then return end

	local env_ = get_game_env()
	if env_ < 10 and worldDesc.open == 1 and worldDesc.OpenSvr == 9 then
		ShowGameTips(GetS(10655), 3)
		return
	end

	local isChecking = delegate(function ()
		local owid =  worldDesc.fromowid
		if owid == 0 then
			owid = worldDesc.worldid
		end
		local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(owid)
		if mapIsBreakLaw == 1 then
			return true
		end

		local mapAppealStatus = MapAppealStatus(owid)
		if mapAppealStatus == 0 then
			return true
		end

		local env_ = get_game_env()
    	if env_ < 10 then
			if worldDesc.open == 1 and worldDesc.OpenSvr == 0 then
				return true
			end
		end

		return false
	end)

	--执行撤销审核操作
	if isChecking then
		print("=====do uncheck operator=======")
		if archiveIndex >= AccountManager:getMyWorldList():getNumWorld() then return end
		MessageBox(5, GetS(10654));
		getglobal("MessageBoxFrame"):SetClientUserData(0,archiveIndex);
		getglobal("MessageBoxFrame"):SetClientString("撤销审核");
		return;
	end


	if ns_data.IsGameFunctionProhibited("m", 10577, 10578) then
		return
	end
	--[[地图上传 账号校验]]
	if not ArchiveShareAccountCheck(worldDesc) then
		return
	end
	Translate_ArchiveIndex = archiveIndex
	print("worlddesclang",worldDesc.worldid)
	if ClientMgr:getVersionParamInt("ShareExsitMod", 1) ~= 1 and worldDesc ~= nil and AccountManager:isExistMod(worldDesc.worldid) then
		ShowGameTips(GetS(3809), 3);
		return;
	end

	local owid = worldDesc.fromowid
	if owid == 0 then owid = worldDesc.worldid end
	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(owid)
	if mapIsBreakLaw == 1 then
		ShowGameTips(GetS(25810), 3)
		return
	elseif mapIsBreakLaw == 2 then
		ShowGameTips(GetS(3634), 3)
		return
	end

	local mapAppealStatus = MapAppealStatus(owid)
	if mapAppealStatus == 2 then
		ShowGameTips(GetS(25814), 3)
		return
	end

	--审核中以后不会再让更新了，所以这个执行不到了
    -- if isChecking() then
	-- 	ShowGameTips(GetS(25810), 3)
	-- 	return
	-- end

	--保存原始多语言json信息
	curShareMapInfo.worldid = 0;
	curShareMapInfo.multilangname = "";
	curShareMapInfo.multilangdesc = "";
	if worldDesc then
		curShareMapInfo.worldid = worldDesc.worldid;
		curShareMapInfo.multilangname = worldDesc.multilangname;
		curShareMapInfo.multilangdesc = worldDesc.multilangdesc;
		print("ArchiveUpdate:multilangname = ", curShareMapInfo.multilangname);
		print("ArchiveUpdate:multilangdesc = ", curShareMapInfo.multilangdesc);
	end

	if NewShareArchiveFrame then
		local worldId = 0;
		local archiveData = GetOneArchiveData(archiveIndex);
		if archiveData then
			worldDesc = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
			worldId = worldDesc and worldDesc.worldid or 0;
		end
		
		local param = {};
		param.archiveIndex = archiveIndex;
		param.shareType = 2;	--1:分享地图 2:更新分享
		param.worldId = worldId;
		GetInst("UIManager"):Open("ShareArchive", param);
	else
		getglobal("ShareArchiveInfoFrame"):SetClientUserData(0, archiveIndex);
		getglobal("ShareArchiveInfoFrame"):SetClientUserData(1, 2);
		getglobal("ShareArchiveInfoFrame"):Show();
	end
end

--打开实名认证弹窗
function ArchiveAutonymCheck_OnClick()
	local adsType = RealNameFunc and RealNameFunc.isShowIdentityNameAuth and RealNameFunc:isShowIdentityNameAuth(8)
	if adsType then
		ShowIdentityNameAuthFrame(nil,nil,nil,nil,nil,adsType)
	else
		ShowIdentityNameAuthFrame()
	end
	this:GetParentFrame():Hide();
end

--查看作者
function ArchiveAuthor_OnClick()
	this:GetParentFrame():Hide();
	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3);
		return;
	end

	local clientId = this:GetParentFrame():GetParentFrame():GetClientID();
	local archiveData = GetOneArchiveData(clientId);
	if archiveData == nil then return end

	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
	if BuddyManager:requestBuddyWatch(worldInfo.realowneruin) then
		SearchWatchUin = worldInfo.realowneruin;
	end
end

--下载
function ArchiveLoad_OnClick()
	this:GetParentFrame():Hide();
	local MessageBoxFrame = getglobal("MessageBoxFrame");

	local clientId = this:GetParentFrame():GetParentFrame():GetClientID();
	local archiveData = GetOneArchiveData(clientId);
	if archiveData == nil then return end
	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
	DownLoadWorld(worldInfo, clientId) --这里封装一下，备份的时候，如果是已经分享且本地文件被删除的情况下，走下载流程
end

function DownLoadWorld( worldInfo, clientId )
	if math.floor(ClientMgr:clientVersion() / 256.0) < math.floor(ClientMgr:clientVersionFromStr(worldInfo.ownerCltVer) / 256.0) then
		ShowGameTips(GetS(426), 3);
		return;
	end
	local MessageBoxFrame = getglobal("MessageBoxFrame");
	if isEnableNewLobby and isEnableNewLobby() then
		local netState = ClientMgr:getNetworkState();
		if netState == 0 then
			ShowGameTips(GetS(19), 3);
		elseif netState == 2 then
			MessageBox(11, GetS(21));
			MessageBoxFrame:SetClientUserDataLL(0, worldInfo.worldid);
			MessageBoxFrame:SetClientString( "恢复下载地图网络提示" );
		elseif worldInfo.openpushtype == 3 then
			local text = GetS(160);
			MessageBox(5, text);
			MessageBoxFrame:SetClientUserDataLL(0, worldInfo.worldid);
			MessageBoxFrame:SetClientString( "切换帐号分享下载地图" );
		else
			AccountManager:continueDownloadWorld(worldInfo.worldid);
			IsNeedReset = false;
		end
	else
		local netState = ClientMgr:getNetworkState();
		if netState == 0 then
			ShowGameTips(GetS(19), 3);
		elseif netState == 2 then
			if clientId >= 0 then
				MessageBox(11, GetS(21));
				MessageBoxFrame:SetClientUserDataLL(0, worldInfo.worldid);
				MessageBoxFrame:SetClientString( "恢复下载地图网络提示" );
			end
		elseif worldInfo.openpushtype == 3 then
			local text = GetS(160);
			MessageBox(5, text);
			MessageBoxFrame:SetClientUserData(0, clientId);
			MessageBoxFrame:SetClientUserDataLL(0, worldInfo.worldid);
			MessageBoxFrame:SetClientString( "切换帐号分享下载地图" );
		else
			AccountManager:continueDownloadWorld(worldInfo.worldid);
			IsNeedReset = false;
		end
	end
end

--暂停下载
function ArchiveLoadPause_OnClick()
	this:GetParentFrame():Hide();
	local clientId = this:GetParentFrame():GetParentFrame():GetClientID();
	local archiveData = GetOneArchiveData(clientId);
	if archiveData == nil then return end

	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)

	AccountManager:pauseDownloadWorld(worldInfo.worldid);
	IsNeedReset = false
end

--帮助按钮
function LobbyFrameArchiveFrameHelpBtn_OnClick()
	if IsStandAloneMode() then return end
	GetInst("UIManager"):Open("ArchiveHelp")
end

function LobbyFrameArchiveFrame_OnShow()
	UpdateArchive();
	SetDefaultArchiveBtn();
end

function LobbyFrameArchiveFrame_OnHide()
	if IsMapDetailInfoShown() then
		HideMapDetailInfo();
	end
end


EnterMainMenuInfo = {
	DelNoviceMap = false;
	GoToGame = false;
	GoToNoviceTheme = false;
	GoToGameWorldName = "";
	t_RestarExtremity = {};
	OpenRoom = false;
	OpenRoomEx = {};
	LoginRoomServer	= false;
	LoginRoomServerEx = {};

	EnterMainMenuBy = 'standalone';  -- 默认进入存档列表

	ReopenRoomInfo = nil;

	ReLoadGame = nil;

	CreateTempMapInGameOwid = nil;
	
	ReOpenShopSkinDisplay = nil;

	OpenCloudRoomID = 0; --云服跨房间传送OWID

	openAllCloudRoom = false; -- 全面云服情况下，公开地图 单机转云服
	openAllCloudRoomCall = function() end;
}

local FirstEnterMainMenuStage = true;

function SetFirstEnterMainMenuStage(value)
	FirstEnterMainMenuStage = value
end

function GetFirstEnterMainMenuStage()
	return FirstEnterMainMenuStage
end

function MainMenuGame_Enter()
	MainMenuStage_Enter()
end
function MainMenuStage_Enter()
	Log( "call MainMenuStage_Enter" );
	print("EnterMainMenuInfo info", EnterMainMenuInfo)

	IsCustomGameEnd = false;
	FLAG_FOR_BATTLE_PASS_BATTLE_REPORT = true --解决重复上报的问题
	getglobal("GongNengFrame"):Hide();
	getglobal("LoadingFrame"):Hide();
	GetInst("UIManager"):Close("ToolModeFrame");	--关闭工具模式界面
	--getglobal("SpectatorFrame"):Hide();
	--getglobal("SpectatorPlayerNameContent"):Hide();

	if GetInst("ExternalRecommendMgr") then
		GetInst("ExternalRecommendMgr"):ClearCurZBInfo();
	end

	if EnterMainMenuInfo.DelNoviceMap then
		EnterMainMenuInfo.DelNoviceMap = false;
		DeleteMapIndex = GetIndexForWorldId(NewbieWorldId)-1;
		DeleteMapFormWid = 0;
		if DeleteMapIndex >= 0 and AccountManager:requestDeleteWorld(NewbieWorldId) then
		end
	end

	local isEnterGame = false;
	if EnterMainMenuInfo.GoToGame then
		if AccountManager:requestCreateWorld(0, EnterMainMenuInfo.GoToGameWorldName, 1, "", AccountManager:getRoleModel()) then
			StatisticsWorldCreationEvent(0);
			--新手引导后首次创建地图
			local id = 0
			for i = AccountManager:getMyWorldList():getNumWorld(),1,-1 do
				local worldInfo = AccountManager:getMyWorldList():getWorldDesc(i-1);
				if not IsNewbieWorld(worldInfo.worldid) then
					setkv( "firstMapId", worldInfo.worldid, "statisticsDataFile")
					id = worldInfo.worldid
					break
				end
			end
			--埋点，进入冒险进入（从新手教学落地冒险地图） 设备码,是否首次进入教学地地图,用户类型,语言
			-- statisticsGameEventNew(962,ClientMgr:getDeviceID(),(IsFirstEnterNoviceGuide and not enterGuideAgain) and 1 or 2,id,
			-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))	
			StatisticsTools:send(true, true)
		end
		ShowLoadingFrame();
		EnterMainMenuInfo.GoToGame = false;
		EnterMainMenuInfo.GoToGameWorldName = "";
	elseif #(EnterMainMenuInfo.t_RestarExtremity) > 0 then
		local info = EnterMainMenuInfo.t_RestarExtremity[1];
		if AccountManager:requestCreateWorld(info.worldType, info.name, info.terrType, info.seed, info.roleModel) then
			StatisticsWorldCreationEvent(info.worldType);
			isEnterGame = true;
		end
		ShowLoadingFrame();
		EnterMainMenuInfo.t_RestarExtremity = {};
	elseif EnterMainMenuInfo.OpenRoom then
		local worldid = EnterMainMenuInfo.OpenRoomEx.worldid
		local createExInfo = EnterMainMenuInfo.OpenRoomEx.createExInfo
		EnterMainMenuInfo.OpenRoom = false;
		EnterMainMenuInfo.OpenRoomEx = {}
		Log("OpenRoom5");
		OpenRoom(worldid, createExInfo);
		isEnterGame = true;
	elseif EnterMainMenuInfo.openAllCloudRoom then
		local func = function() end
		local owid = nil
		if EnterMainMenuInfo.openAllCloudRoomEx then
			func = EnterMainMenuInfo.openAllCloudRoomEx.call or function() end
			owid = EnterMainMenuInfo.openAllCloudRoomEx.owid
		end
		EnterMainMenuInfo.openAllCloudRoomEx = {}
		EnterMainMenuInfo.openAllCloudRoom = false
		
		ShowLobby({formEndGame = true, selectOwid = owid});

		pcall(func)
		isEnterGame = true;
	elseif EnterMainMenuInfo.LoginRoomServer then	--回到房间列表
		-- getglobal("MiniLobbyFrame"):Show();
		-- ShowMiniLobby(); --mark by hfb for new minilobby
		OpenRoomFrame(nil, true) --不显示主页，直接显示联机大厅
        RequestLoginRoomServer();
		if next(EnterMainMenuInfo.LoginRoomServerEx) then
			if EnterMainMenuInfo.LoginRoomServerEx.ToCreateRoom then
				FastOpenOnLine(0)
			else
				GetInst("UIManager"):Open("RoomMatch", EnterMainMenuInfo.LoginRoomServerEx)
			end
		end
		EnterMainMenuInfo.LoginRoomServer = false;
		EnterMainMenuInfo.LoginRoomServerEx = {};
	elseif EnterMainMenuInfo.ReopenRoomInfo and EnterMainMenuInfo.ReopenRoomInfo.ReOpen then	--再来一局,暂时没用
		-- ShowLoadLoopFrame3(true,"auto");
        ShowLoadLoopFrame3(true, "file:lobby -- func:MainMenuStage_Enter")
	elseif EnterMainMenuInfo.ReLoadGame then
		--从世界插件库中重新进入游戏
		local owid = EnterMainMenuInfo.ReLoadGame.owid
		if EnterMainMenuInfo.ReLoadGame.reportData then
			InsertStandReportGameJoinParamArg(EnterMainMenuInfo.ReLoadGame.reportData)
			GetInst("ReportGameDataManager"):NewGameLoadParam(
				EnterMainMenuInfo.ReLoadGame.reportData.sceneid,
				EnterMainMenuInfo.ReLoadGame.reportData.cardid,
				EnterMainMenuInfo.ReLoadGame.reportData.compid
			)
		end
		local userdata = EnterMainMenuInfo.ReLoadGame.userdata
		RequestEnterWorld(owid, false, function(succeed)
			if succeed then
				HideLobby();
				ShowLoadingFrame();
				-- 如果是教育版本，重新进入游戏通知js addRole
				if isEducationalVersion then
					MCodeMgr:miniCodeCallBack(-26, JSON:encode({0}));
				end
			else
				GetInst("ExternalRecommendMgr"):ClearCurZBInfo()
			end
		end, userdata);
		EnterMainMenuInfo.ReLoadGame = nil
	elseif EnterMainMenuInfo.CreateTempMapInGameOwid then
		-- ShowNoTransparentLoadLoop()
		-- AccountManager:requestCreateWorldByTempAsync(EnterMainMenuInfo.CreateTempMapInGameOwid, GetInst("TempMapInterface"):CreateTempMapName(EnterMainMenuInfo.CreateTempMapInGameOwid))
		-- EnterMainMenuInfo.CreateTempMapInGameOwid = nil

		-- local _result, newwid = AccountManager:requestCreateWorldByTemp(EnterMainMenuInfo.CreateTempMapInGameOwid, GetInst("TempMapInterface"):CreateTempMapName(EnterMainMenuInfo.CreateTempMapInGameOwid), 0);
		local newwid = EnterMainMenuInfo.CreateTempMapInGameNewWid;
		local ts = EnterMainMenuInfo.ts;
		local sign = EnterMainMenuInfo.sign;

		local _result = AccountManager:requestCreateWorldByTemp(EnterMainMenuInfo.CreateTempMapInGameOwid, newwid, GetInst("TempMapInterface"):CreateTempMapName(EnterMainMenuInfo.CreateTempMapInGameOwid), ts, sign);
		if _result == 0 and AccountManager:requestEnterWorld(newwid or 0) then
			GetInst("UIManager"):HideAll();
			UIFrameMgr:hideAllFrame();
			ShowLoadingFrame();
			GetInst("SimpleLocalData"):SetTempNameIndexByOwidAdd(EnterMainMenuInfo.CreateTempMapInGameOwid);
			GetInst("TempMapInterface"):statisticsUseTempResult(newwid);
		else

			ShowGameTips(GetS(34441), 3);

			--下面这个代码是抄的  else elseif EnterMainMenuInfo.EnterMainMenuBy == 'standalone' then 分支的
			-- 后续也可以对比着改
			ShowLobby();
			--退出地图时，跳转显示所有存档
			t_LobbyFrameData.switchown = true;
			t_LobbyFrameData.switchother = true;
			t_LobbyFrameData.switchownVideo = true;
			t_LobbyFrameData.switchotherVideo = true;
			getglobal("LobbyFrameArchiveFrameRecordTitleName"):SetText(getglobal("LobbyFrameArchiveFrameRecordListF1Name"):GetText());
			getglobal("LobbyFrameArchiveFrameRecordTitleNameRight"):SetText(getglobal("LobbyFrameArchiveFrameRecordListF1NameRight"):GetText());
			UpdateArchive();
			SetDefaultArchiveBtn();

			EnterMainMenuInfo.EnterMainMenuBy = "standalone";				--重置
			ClientMgr:playMusic("sounds/music/theme1.ogg");

		end

		EnterMainMenuInfo.CreateTempMapInGameOwid = nil;

	elseif EnterMainMenuInfo.JoinQuickupRent then
		if EnterMainMenuInfo.JoinQuickupRent.func then
			threadpool:work(function ()
				EnterMainMenuInfo.JoinQuickupRent.func()
				EnterMainMenuInfo.JoinQuickupRent = nil
			end)

			return
		end
	elseif EnterMainMenuInfo.RoomInvite then --房间邀请
		threadpool:work(function ()
			local msg = EnterMainMenuInfo.RoomInvite.msg
			CommonInviteFrame_RoomInvite(msg)
			EnterMainMenuInfo.RoomInvite.func()
			EnterMainMenuInfo.RoomInvite = nil
		end)	
		return
	elseif EnterMainMenuInfo.HomelandInvite then --家园邀请
		threadpool:work(function ()
			local uin = EnterMainMenuInfo.HomelandInvite.uin
			local pw = EnterMainMenuInfo.HomelandInvite.pw
			EnterFriendHomeMap(uin, pw)
			EnterMainMenuInfo.HomelandInvite.func()
			EnterMainMenuInfo.HomelandInvite = nil
		end)	
		return
	elseif EnterMainMenuInfo.TeamupInvite then --组队邀请
		threadpool:work(function ()
			local msg = EnterMainMenuInfo.TeamupInvite.msg
			EnterMainMenuInfo.TeamupInvite = nil
			if msg then
				local data = msg.data
				if data and data.uin then
					local function callback(ok)
						if not ok then
							--加入队伍失败
							ShowMiniLobby()
						end
					end

					GetInst("TeamupService"):reqTeamInviteResp(data.uin, true, callback)
				end
			end
		end)

		return
	else
		if EnterMainMenuInfo.TeamupMemberJoinRoom then --进入组队房间
			local roomDesc = EnterMainMenuInfo.TeamupMemberJoinRoom.roomDesc
			EnterMainMenuInfo.TeamupMemberJoinRoom = nil
			threadpool:work(function()
				if GetInst("TeamupService"):IsTeamPlaying() then
					ShowLoadingFrame(nil, 5)
					threadpool:wait(1)
					GetInst("TeamupService"):ManualLinkTeamRoom()
				end
			end)
			--不return，保证哪来回哪
		elseif EnterMainMenuInfo.GotoTraceFrid then
			local traceInfo = EnterMainMenuInfo.GotoTraceFrid
			EnterMainMenuInfo.GotoTraceFrid = nil
			threadpool:work(function()
				ShowLoadingFrame(GetS(4889), 5);
				threadpool:wait(2)
				FriendTraceMgr:ReqTrace(traceInfo.uin, traceInfo.rptInfo)
			end)
			--不return，保证哪来回哪
		elseif EnterMainMenuInfo.SwitchRoom and EnterMainMenuInfo.SwitchRoom.roomDesc then
			local roomDesc = EnterMainMenuInfo.SwitchRoom.roomDesc
			local rptInfo = EnterMainMenuInfo.SwitchRoom.rptInfo
			local spData = EnterMainMenuInfo.SwitchRoom.spData
			EnterMainMenuInfo.SwitchRoom = nil
			threadpool:work(function()
				ShowLoadingFrame(GetS(4889), 5);
				AccountManager:logoutRoomServer()
				AccountManager:loginRoomServer(false, 0, "EnterMainMenuInfo.SwitchRoom")
				threadpool:wait(1)
				
				if rptInfo then
					GetInst("ReportGameDataManager"):NewGameJoinParam(rptInfo.sceneid, rptInfo.cardid, rptInfo.compid)
				end
				GetInst("RoomService"):EnterRoomByDesc(0, false, roomDesc, {notQuery=true, spData = spData})
			end)
			--不return，保证哪来回哪
		end
		if not FirstEnterMainMenuStage then		--不是第一次进主界面

			if EnterMainMenuInfo.GoToNoviceTheme then						--新手引导结束选择继续教程
				EnterMainMenuInfo.GoToNoviceTheme = false;
				SetMiniWorksCurLabel(4);	--打开专题区
				getglobal("MiniWorksFrame"):Show();
				StatisticsTools:gameEvent("GoToMiniWorksNoviceTheme");
			elseif EnterMainMenuInfo.EnterMainMenuBy == 'standalone' then	--回到存档列表
				ShowLobby({formEndGame = true, selectOwid = EnterMainMenuInfo.EnterWorldId, 
						   mainType = EnterMainMenuInfo.MainFilter, subType = EnterMainMenuInfo.SubFilter,
						   mapDetailOpen = EnterMainMenuInfo.MapDetailOpen,
						   settingNotRefresh = EnterMainMenuInfo.NotRefreshSetting, materialOpen = EnterMainMenuInfo.MaterialOpen});
				--退出地图时，跳转显示所有存档
				t_LobbyFrameData.switchown = true;
				t_LobbyFrameData.switchother = true;
				t_LobbyFrameData.switchownVideo = true;
				t_LobbyFrameData.switchotherVideo = true;
				EnterMainMenuInfo.EnterWorldId = nil;
				EnterMainMenuInfo.MainFilter = nil;
				EnterMainMenuInfo.SubFilter = nil;
				EnterMainMenuInfo.NotRefreshSetting = nil;
				EnterMainMenuInfo.MaterialOpen = nil;
				EnterMainMenuInfo.MapDetailOpen = nil;
				EnterMainMenuInfo.LobbyOnline = false;
				getglobal("LobbyFrameArchiveFrameRecordTitleName"):SetText(getglobal("LobbyFrameArchiveFrameRecordListF1Name"):GetText());
				getglobal("LobbyFrameArchiveFrameRecordTitleNameRight"):SetText(getglobal("LobbyFrameArchiveFrameRecordListF1NameRight"):GetText());
				UpdateArchive();
				SetDefaultArchiveBtn();

				--统计
				-- if StatisticsNewWorldType == 1 then
				-- 	statisticsGameEvent(901, '%s', 'G000031',"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()))
				-- end
			elseif EnterMainMenuInfo.EnterMainMenuBy == 'NewbieWorld' then
				-- getglobal("MiniLobbyFrame"):Show();
				ShowMiniLobby() --mark by hfb for new minilobby
			elseif EnterMainMenuInfo.EnterMainMenuBy == 'MiniWork' then     --回到迷你工坊
				ExitGoToMiniworks(EnterMainMenuInfo)
				EndGameBackOrignOpenMapDetail()		
			elseif EnterMainMenuInfo.EnterMainMenuBy == 'PlayerCenter' or 
			(EnterMainMenuInfo.EnterMainMenuBy=='' and EnterMainMenuInfo.PlayerCenterBackInfo and EnterMainMenuInfo.MapDetailInfoParam) then --回到个人中心
				--从好友跳个人中心再进地图详情再进游戏会关闭好友打开首页将EnterMainMenuInfo.EnterMainMenuBy清理，故此处特殊兼容
				ShowMiniLobby() --mark by hfb for new minilobby
				if EnterMainMenuInfo.PlayerCenterBackInfo then
					local backInfo = EnterMainMenuInfo.PlayerCenterBackInfo
					--数据先临时存起来，否则下面函数执行后会把数据覆盖
					local clickID = backInfo.clickID
					local selectTab = backInfo.selectTab
					if clickID == 6 then	--装扮图鉴
						OpenNewPlayerCenter(backInfo.uin,"mobpush_personal_dress_gallery",backInfo.ThemeNum or 0)
						-- OpenNewPlayerCenter(backInfo.uin,backInfo.from,backInfo.ThemeNum);
					else
						OpenNewPlayerCenter(backInfo.uin,backInfo.from,backInfo.ThemeNum);
					end
					if clickID then
						ExhibitionLeftTabBtnTemplate_OnClick(clickID)
						if selectTab then
							if clickID == 2 then		--地图
								PEC_MapTabBtn_OnClick(selectTab)
							elseif clickID == 3 then	--动态
								DynamicHandleTabBtnTemplate_OnClick(selectTab)
							end
						end
					end
					EnterMainMenuInfo.PlayerCenterBackInfo = nil
				else
					JumpToPlayerCenter();--mark by hfb for new minilobby 不要埋点
					ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabMap)
				end
				EndGameBackOrignOpenMapDetail()
			elseif EnterMainMenuInfo.EnterMainMenuBy == "recentlyOpenedWorldRoomEnter" then
				EnterMainMenuInfo.EnterMainMenuBy = ""
				local param = {}
				GetInst("UIManager"):Open("CloudServerLobby",param)
				GetInst("UIManager"):GetCtrl("CloudServerLobby"):CloudServerLobbyTabTemplate_OnClick(3)
			elseif EnterMainMenuInfo.EnterMainMenuBy == "FromMiniWorksStartMulitRoom" then
				-- getglobal("MiniLobbyFrame"):Show();
				-- ShowMiniLobby() --mark by hfb for new minilobby
				-- ArchiveInfoFrameTopFilterRoomOWBtn_OnClick()

				getglobal("MiniWorksFrame"):Show();
				if EnterMainMenuInfo.CommendType then
					GetInst("UIManager"):Close("MiniWorksCommendDetail")
					GetInst("UIManager"):Open("MiniWorksCommendDetail", {commendtype = EnterMainMenuInfo.CommendType})
					ShowMiniWorksMainDetail(true)
					EnterMainMenuInfo.CommendType = nil
				end
			elseif EnterMainMenuInfo.EnterMainMenuBy == "HomeLand" then --回到家园
				--分不同的状态处理
				OnEnterHomeLandProcess()
			elseif EnterMainMenuInfo.EnterMainMenuBy == "ShopSkinDisplay" then --返回至装扮详情界面 fym
				ShowMiniLobby()
				EnterMainMenuInfo.EnterMainMenuBy = ""
				local param = EnterMainMenuInfo.ReOpenShopSkinDisplay
				if param and param.skinId and param.tabType then
					EnterMainMenuInfo.ReOpenShopSkinDisplay = nil
					GetInst("UIManager"):Open("ShopSkinDisplay", {skinId = param.skinId, tabType = param.tabType })
				end
			elseif EnterMainMenuInfo.EnterMainMenuBy == "TravelRoom" then --从云服跨房间过来
				if type(EnterMainMenuInfo.OpenCloudRoomID) ~= 'number' then
					EnterMainMenuInfo.OpenCloudRoomID = 0; --重置数据
					GetInst("CloudPortalInterface"):ReqTransferNow(function(success, tips)
						EnterMainMenuInfo.EnterMainMenuBy = "";
						if not success then 
							ShowMiniLobby() --失败后返回主界面
							if tips then ShowGameTips(tips) end
						end
					end)
				end
			elseif EnterMainMenuInfo.EnterMainMenuBy == "CreatePersonalCloud" then --创建私人云服房间
				ShowLoadingFrame(GetS(4889), 7);
				GetInst("ExitGameMenuInterface"):CreatePersonalCloud(function(success, tips, preEnterMainMenuBy)
					EnterMainMenuInfo.EnterMainMenuBy = "";
					if not success then 
						if preEnterMainMenuBy == "multiplayer" then
							if not ClientCurGame:isInGame() then
								getglobal("LoadingFrame"):Hide();
							end
							if EnterMainMenuInfo.RoomCurLabel then
								RoomFrame_SetShowOpenLeftBtn(EnterMainMenuInfo.RoomCurLabel);
								EnterMainMenuInfo.RoomCurLabel = nil;
							end
							if EnterMainMenuInfo.HotMapClick then
								EnterMainMenuInfo.ReturnGameHotMapClick = true;
							end
							OpenRoomFrame(nil, true) --不显示主页，直接显示联机大厅
							-- getglobal("MultiplayerLobbyFrame"):Show()
							RequestLoginRoomServer();
							if EnterMainMenuInfo.MiWorkCurLabel == 6 then
								GetInst('NSearchPlatformService'):ShowSearchPlatform();
							end
						else
							ShowMiniLobby() --失败后返回主界面
						end
						if tips then ShowGameTips(tips) end
						ClearEnterGameBackInfo()
					else
						EnterMainMenuInfo.EnterMainMenuBy = preEnterMainMenuBy;
					end
				end)
			elseif EnterMainMenuInfo.EnterMainMenuBy == "CreationCenter" then --返回创作中心
				-- ShowMiniLobby()
				local cInterface = GetInst("CreationCenterInterface")
				if cInterface then
					cInterface:ExitGameJumpToCreationCenter()
				end
			elseif EnterMainMenuInfo.EnterMainMenuBy == "MatchRoom" then --返回匹配界面
				if not IsMiniLobbyShown() then
					ShowMiniLobby()
				end
				GetInst("MatchTeamupService"):BackToMatchTeam()
			elseif EnterMainMenuInfo.EnterMainMenuBy == "" then --只想返回主页
				ShowMiniLobby()
				ExitGoToLobbyOtherUI()
			elseif EnterMainMenuInfo.EnterMainMenuBy == "RoomFrame" then --只想返回到联机大厅
				OpenRoomFrame(nil, true)
				RequestLoginRoomServer();
			else														--回到房间列表
				-- getglobal("MiniLobbyFrame"):Show();
				-- ShowMiniLobby() --mark by hfb for new minilobby
				if EnterMainMenuInfo.RoomCurLabel then
					RoomFrame_SetShowOpenLeftBtn(EnterMainMenuInfo.RoomCurLabel);
					EnterMainMenuInfo.RoomCurLabel = nil;
				end
				if EnterMainMenuInfo.HotMapClick then
					EnterMainMenuInfo.ReturnGameHotMapClick = true;
				end
                OpenRoomFrame(nil, true) --不显示主页，直接显示联机大厅
                -- getglobal("MultiplayerLobbyFrame"):Show()
                RequestLoginRoomServer();
				if EnterMainMenuInfo.MiWorkCurLabel == 6 then
					GetInst('NSearchPlatformService'):ShowSearchPlatform();
				end
				EndGameBackOrignOpenTopicMaps()
				EndGameBackOrignOpenMapDetail()
			end
			-- EnterMainMenuInfo.EnterMainMenuBy = "standalone";				--重置
			ClientMgr:playMusic("sounds/music/theme1.ogg");
			JsBridge:PopFunction();
			----TApmMarkLevelLoad();
			ClearEnterGameBackInfo()
		else
			FirstEnterMainMenuStage = false;
			-- OpenNewBPPersistentTask();
		end
	end

	if HasUIFrame("GongNengFrameRuleSetGNBtn") then
		getglobal("GongNengFrameRuleSetGNBtn"):Hide();
		refreshAdMarket();
		GongNengFrame_OnBtnVisibleChange();
	end

	--引导评分
	if TamedAnimal_RequestReview == 0 then
		ClientMgr:RequestReview();
		TamedAnimal_RequestReview = -1;
		-- statisticsGameEvent(8002,"%d",0);
	elseif TamedAnimal_RequestReview == 1 then
		ClientMgr:RequestReview();
		TamedAnimal_RequestReview = -1;
		-- statisticsGameEvent(8002,"%d",1);
	elseif TamedAnimal_RequestReview == 2 then
		ClientMgr:RequestReview();
		TamedAnimal_RequestReview = -1;
		-- statisticsGameEvent(8002,"%d",2);
	elseif TamedAnimal_RequestReview == 3	then
		ClientMgr:RequestReview();
		TamedAnimal_RequestReview = -1;
		-- statisticsGameEvent(8002,"%d",3);
	end
	--采用新的通用弹窗
	--弹窗
	-- threadpool:work(function()
	-- 	if not FirstEnterMainMenuStage and not isEnterGame and g_PopUpsData.curIndex < #(g_PopUpsData.msg) then
	-- 		g_PopUpsData.curIndex = g_PopUpsData.curIndex + 1;
	-- 		UpdateGamePopUpsFrame();
	-- 	end
	-- end);

	if getglobal("CSNoticeFrame"):IsShown() then
		getglobal("CSNoticeFrame"):Hide()
	end

	GetInst("UIManager"):Close("WaterMark")
	GetInst("TriggerMapInteractiveInterFace"):LeveGameGame()
	GetInst("NewDeveloperStoreInterface"):LeveaGame()
	GetInst("TitleSystemInterface"):LeaveGame()
	GetInst("GameTimeLenthReport"):LeaveGame()
	GetInst("TeamVocieManage"):LeveGameGame()
	UIEditorDef:closeRootNode()
	
	if GetInst("QQMusicPlayerManager") then
		GetInst("QQMusicPlayerManager"):QuitUI();--退出音乐播放器
	end

	--停止qq音乐触发器
	if GetInst("QQMusicTriggerManager") then
		GetInst("QQMusicTriggerManager"):StopQQMusic();
	end
	
	if GetInst("MiniClubPlayerManager") then
		GetInst("MiniClubPlayerManager"):QuitUI();
	end

	if GetInst('BroadcastMgr') then -- 退出游戏 移除ui
		GetInst('BroadcastMgr'):OnQuitGameSuccess()
	end
	
	if cInterface then 
		cInterface:SubmibTaskFinish(TaskTypeEnum.Type1)
	end 
	
	local sanrioInterface = GetInst("SanrioActInterface")
	if sanrioInterface then 
		sanrioInterface:SubmibSanrioTaskFinish()
	end 
	
	local qingluanInterface = GetInst("QingLuanInterface")
	if qingluanInterface then 
		qingluanInterface:SubmitPlayTaskFinish()
	end 
	
	local midautuInterface = GetInst("MidautuInterface")
	if midautuInterface then 
		midautuInterface:SubmitPlayTaskFinish()
	end 

	local createFestivalMgr = GetInst("NationalCreateFestivalMgr")
	if createFestivalMgr then 
		createFestivalMgr:SubmibEditTaskFinish()
	end

	--退出时检测是否标签聚合页进入，是则返回标签聚合页
	checkJumpTagMaps()

	--退出时关闭聊天框
	GetInst("MiniUIManager"):CloseUI("chat_viewAutoGen")	
	GetInst("MiniUIManager"):ShowUI("ChatHoverBallAutoGen")
	--退出移除最佳拍档上报
	--GetInst("BestPartnerManager"):LeaveGame()

	-- --检测是否异常退出，是的话需要重连，进房间
	-- threadpool:work(function()
	-- 	GetInst("MatchTeamupService"):CheckIsInMatchTeamGame()
	-- end)
end

function ExitGoToMiniworks(info)
	local curlabel = GetCurLabel()
	getglobal("MiniWorksFrame"):Show();
	if info.CommendType then
		GetInst("UIManager"):Close("MiniWorksCommendDetail")
		GetInst("UIManager"):Open("MiniWorksCommendDetail", {commendtype = EnterMainMenuInfo.CommendType})
		ShowMiniWorksMainDetail(true)
		info.CommendType = nil
	elseif info.MiWorkCurLabel then
		if info.MiWorkCurLabel == 6 then
			info.MiWorkCurLabel = nil;
			GetInst('NSearchPlatformService'):ShowSearchPlatform()
		else
			MiniworksGotoLabel(info.MiWorkCurLabel);
			if info.MiWorkCurrentIndex then
				JumpToTopicByIndex(info.MiWorkCurrentIndex)
				info.MiWorkCurrentIndex = nil
			end
			
			JumpToNewMiniWorksUI(info)
			
			if EnterMainMenuInfo.MiniWorkCurrentItem then
				GetInst("UIManager"):Open("MiniWorksTopicDetail", EnterMainMenuInfo.MiniWorkCurrentItem);
				EnterMainMenuInfo.MiniWorkCurrentItem = nil
			end
			info.MiWorkCurLabel = nil;
		end
	else
		if curlabel == -1 and EnterMainMenuInfo.WorksManageOpen  then 
			WorksManageBtn_OnClick()
			EnterMainMenuInfo.WorksManageOpen = nil
			
			return
		end 
		
		if curlabel == 6 then curlabel = 7 end --如果是搜索 就回主页 跳搜索可能出问题
		MiniworksGotoLabel(curlabel)
		if info.MiWorkCurrentIndex then
			JumpToTopicByIndex(info.MiWorkCurrentIndex)
			info.MiWorkCurrentIndex = nil
		end
		
		JumpToNewMiniWorksUI(info)
		
		if EnterMainMenuInfo.MiniWorkCurrentItem then
			GetInst("UIManager"):Open("MiniWorksTopicDetail", EnterMainMenuInfo.MiniWorkCurrentItem);
			EnterMainMenuInfo.MiniWorkCurrentItem = nil
		end
	end
end

-- 退出游戏时，跳转到对应的打开UI-更多地图和主题 
function JumpToNewMiniWorksUI(info) 
	local jumCtrl = GetInst("MiniUIManager"):GetCtrl("NewMiniWorksMain")
	if jumCtrl then 
		if info.MiWorkTopicIndex1 and info.MiWorkTopicIndex2  then 
			jumCtrl:OpenTopicDetail(nil, nil, info.MiWorkTopicIndex1, info.MiWorkTopicIndex2)
			
			info.MiWorkTopicIndex1 = nil
			info.MiWorkTopicIndex2 = nil
		elseif info.MiWorkMoreMapDetailIndex1 and info.MiWorkMoreMapDetailIndex2 then
			jumCtrl:OpenMoreMapDetail(nil, nil, info.MiWorkMoreMapDetailIndex1, info.MiWorkMoreMapDetailIndex2)
			
			info.MiWorkMoreMapDetailIndex1 = nil
			info.MiWorkMoreMapDetailIndex2 = nil
		end
	end
end

-- 退出游戏时，跳转到首页其他界面（好友聊天）
function ExitGoToLobbyOtherUI()
	if EnterMainMenuInfo.BackFriendInfo then
		local topTab = EnterMainMenuInfo.BackFriendInfo.topTab
		local tabIndex = EnterMainMenuInfo.BackFriendInfo.tabIndex
		local isShowNearby = EnterMainMenuInfo.BackFriendInfo.isShowNearbyFriend
		JumpToChat()
		InteractiveBtn_OnClick()
		--好友或群组
		if topTab==FriendMgr.ChatFrame_Tab_Friend then
			MyFriendEntryTemplateChatBtn_OnClick(tabIndex)
		elseif topTab==FriendMgr.ChatFrame_Tab_Group then
			MyGroupEntryTemplateChatBtn_OnClick(tabIndex)
		end
		if isShowNearby then
			FriendSwitchTabs(4);
		end
		EnterMainMenuInfo.BackFriendInfo = nil
	end
end

--退出游戏清理相关数据
function ClearEnterGameBackInfo()
	if EnterMainMenuInfo.EnterMainMenuBy ~= "CreatePersonalCloud" then
		EnterMainMenuInfo.RecentlyPlayBackInfo = nil
		EnterMainMenuInfo.TopicMapsBackInfo = nil
		EnterMainMenuInfo.MapDetailInfoParam = nil
		EnterMainMenuInfo.BackFriendInfo = nil
		EnterMainMenuInfo.PlayerCenterBackInfo = nil
	end
end

function MainMenuStage_Quit()
	if RecordPkgMgr:isRecordVideo() == false then
		getglobal("LoadingFrame"):Hide();
	end
	getglobal("BackgroundFrame"):Hide();

	local id = ClientMgr:getApiId();
	if id == 38 or id == 39 or id == 41 or id == 42 then
		SdkManager:setSdkFloatMenu(2);  									-- 1 退出游戏地图; 2 进入游戏地图
	end
end

function MainMenuStage_Reload()

end


local t_BGMusic = {
		"sounds/music/bgm1.ogg",
		"sounds/music/bgm2.ogg",
		"sounds/music/bgm3.ogg",
		"sounds/music/bgm4.ogg",
		"sounds/music/bgm5.ogg",
		"sounds/music/bgm6.ogg",
		"sounds/music/bgm7.ogg",
		"sounds/music/bgm8.ogg",
	}

EnterSurviveGameInfo = {
	ReopenRoomInvitePlayers = nil;
	StatisticsData = {
		InGame = false,
		MultiGameLabel = 0,
		GameLabel_9002 = 1
	};
}

function PlayBGMusicByMainWorld()
	if not isPlayingAtlmanMusic then
		ClientMgr:stopMusic()
	end
	LastBiomeType = -1;
	local musicMode = 0;
	local id = 0;
	musicMode,id = CurWorld:getBGMusicMode(id);
	if musicMode == 2 then
		if not isPlayingAtlmanMusic then
			ClientMgr:playMusic(t_BGMusic[id], true)
		end
		lastMusicName = t_BGMusic[id]
	else
		if CurWorld:getOWID() == NewbieWorldId then
			ClientMgr:playMusic("sounds/music/bgm5.ogg", true);
		else
			MusicFrequency = 10;
		end
	end
end

--单人冒险地图进出埋点
--@enterparam 1进入 0退出
function standReportSurviveGameEvent( enterparam )
	--if AccountManager:getMultiPlayer() > 0 then return end
	if not CurWorld then return end
	if not CurWorld:isSurviveMode() or CurWorld:isFreeMode() then
		return --不是冒险模式，不上报
	end
	local mapid = EnterSurviveGameInfo.StatisticsData.OWID
	local totaltime = EnterSurviveGameInfo.StatisticsData.EnterTime
	local isnew = 0 
	if get_account_register_day() < 1 then
		isnew = 1
	end
	local standby3 = 1
	if AccountManager:getMultiPlayer() > 0 then
		standby3 = 2
	end
end

G_SurviveGame_InfoCache = {}

function SurviveGame_Enter_InitInfoCache()
	G_SurviveGame_InfoCache = {}
	G_SurviveGame_InfoCache.fromowid = G_GetFromMapid()
	G_SurviveGame_InfoCache.quit_funcs = {
		ary = {},
		map = {}
	}
end

function SurviveGame_Quit_ClearInfoCache()
	G_SurviveGame_InfoCache = {}
end

function SurviveGame_AddQuitFunc(func)
	if type(func) == "function" and G_SurviveGame_InfoCache.quit_funcs then
		if not G_SurviveGame_InfoCache.quit_funcs.map[tostring(func)] then
			G_SurviveGame_InfoCache.quit_funcs.map[tostring(func)] = true
			table.insert(G_SurviveGame_InfoCache.quit_funcs.ary, func)			
		end
	end
end

function SurviveGame_AddCacheData(key, value)
	G_SurviveGame_InfoCache[tostring(key)] = value
end

function SurviveGame_GetCacheData(key)
	return G_SurviveGame_InfoCache[tostring(key)]
end

--检查退出地图
function CheckAndGoToLoginFrame()
	if not returnLoginFrameRecord.backForce then
		return false
	end

	g_returnToLoginFrame(returnLoginFrameRecord.callback)

	return true
end

function SurviveGame_Enter()
	--检查一下 是否要退出地图 规避进入地图loading中 被拉回到登录界面 然后ui残留问题
	if CheckAndGoToLoginFrame() then
		return
	end

	Log( "call SurviveGame_Enter=============" );
	ReportGameStartCall()
	pcall(function ()
		-- 游戏加载成功埋点
		local s1 = os.difftime(os.time(), gStartLoadingTime) 
		local s2 = 2 
		if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
			if g_ScreenshotShareRoomDesc then 
				if g_ScreenshotShareRoomDesc.extraData then
					local t_extra = JSON:decode(g_ScreenshotShareRoomDesc.extraData)
					if t_extra then
						uniqueCode = t_extra.uniqueCode
						if t_extra.platform then
							-- PC服务器
							if t_extra.platform == 1 then
								s2 = 2
							-- 手机服务器
							else
								s2 = 1
							end
						end
					end
				end
			end 
		else
			s2 = 3
		end
		
		local param = {standby1 = s1, standby2 = s2}
		
		local mapid = G_GetFromMapid()
		if mapid then 
			param.cid = tostring(mapid)
		end 
		
		if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
			standReportEvent("1003", "LOADING_SUCCESS", "-", "success", param)
		else
			standReportEvent("1001", "LOADING_SUCCESS", "-", "success", param)
		end
	end)

	pcall(SurviveGame_Enter_InitInfoCache)

	threadpool:work(function()
		if getglobal("LoadingFrame"):IsShown() then
			getglobal("LoadingFrame"):Hide();
		end
		if GetInst('SocialHallDataMgr') then
			GetInst('SocialHallDataMgr'):InitSystem()
		end

		-- 场景触发活动上报: event_id = 1004  游戏玩法-地图-单位时间内体验游戏地图张数达x （以个为单位）
		setkv("activitytrigger_entermap_time", os.time())
		-- 成功进入地图后上报
		ActivityTriggerReportEvent(1004, 1)

		IsCustomGameEnd = false;

		--邀请再来一局初始化
		InitInvitedReopenRoomData();

		--设置公益活动祝福语
		LoadPlantTreeData();

		--存档评论
		IsCommended = true;
		getglobal("ArchiveGradeBtn"):Hide();
		getglobal("ArchiveGradeFinishBtn"):Hide();

		--成就
		if (CurWorld and CurWorld:getOWID() ~= NewbieWorldId) and PlayAchievementBtnCanShow() then
			AchievementFrameType = 1;
			IsOpenTrack = true;
			AchievementMgr:setCurTrackID(0)
			getglobal("PlayAchievementBtnRewardTag"):Hide();
		else
			IsOpenTrack = false;
		end

		--存档主界面
		for i=1, MAX_SHORTCUT do
			local icon 	= getglobal("ToolShortcut"..i.."Icon");
			icon:SetTextureHuires(ClientMgr:getNullItemIcon());
		end
		getglobal("PlayMainFrame"):Show()


		if CurWorld and CurWorld:getOWID() == NewbieWorldId then
			NewbieWorldId_Enter();
		else
			if CurWorld and CurWorld:isExtremityMode() then
				getglobal("ExtremityTipsFrame"):Show();
			else
				if not (CurWorld and CurWorld:getCurMapID() == 2) then --判断是否是太空世界
					getglobal("ExtremityTipsFrame"):Hide();
				end
			end

			--pc按键引导
			if ClientMgr:isPC() and not AccountManager:getNoviceGuideState("guidekey") then
				GuideKeyountdown = 60;
			end
		end


		if CurMainPlayer:getCurShortcut() < 0 then
			CurMainPlayer:setCurShortcut(0);
		end

		--聊天面板清空
		local systips = getglobal( "ChatContentText" );
		systips:Clear();
		systips:clearHistory();
		RoomInteractiveData:Init();

		--背景音乐
		PlayBGMusicByMainWorld();

		--可以评论的存档，查询一下是否评论过了
		if AccountManager:getMultiPlayer() == 0 and not isEducationalVersion then
			local owid = CurWorld and CurWorld:getOWID() or 0;
			local worldDesc = AccountManager:findWorldDesc(owid);
			if worldDesc then 
				if worldDesc.realowneruin > 1 and worldDesc.owneruin ~= worldDesc.realowneruin then
					RequestCheckMapsComment(worldDesc.fromowid);
					local ret, wid = check_wid2(worldDesc.fromowid)
					MapRewardClass:SetPlayWid(wid);
					MapRewardClass:UpWidIntoCache(2);
					MapRewardClass:SetAuthorUin(worldDesc.realowneruin);
					MapRewardClass:SetNickName(worldDesc.realNickName);
				end
				--[[设置打赏状态]]
				MapRewardClass:SetMapsReward(worldDesc.fromowid, worldDesc.realowneruin, worldDesc.realNickName,worldDesc.ownerIconFrame);
			end
		else
			if not IsRoomOwner() then
				StatisticsTools:joinRoomSucceed();
				--Pvp赛事升级发送活动id
				GetInst("PvpCompetitionManager"):sendPvpActIdToCloudServer()
			end
		end

		--新手引导的相关统计
		if StatisticsNewWorldType == 1 and not IsStatisticsEnterGame then
			-- statisticsGameEvent(901, "%s", "G000029","save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
			IsStatisticsEnterGame = true;
		elseif StatisticsNewWorldType == 2 then
			StatisticsTools:gameEvent("G000033");
			StatisticsNewWorldType = 0;
		end

		refreshAdMarket();

		--新创建的插件标记初始化
		if CurWorld and CurWorld:isGameMakerMode() then
			t_CreateNewItemTag = {};
		end

		ClearExtractPropTag();

		InitGodModeItemIconLoadState();
		if CurWorld and CurWorld:isGodMode() then
			LoadCreateBackpackDef();
		end

		--通知客机，主机加载好了 客机可以进来了
		if (CurWorld and CurWorld:isGameMakerRunMode()) and EnterSurviveGameInfo.NeedInvite and EnterSurviveGameInfo.ReopenRoomInvitePlayers then
			for i=1, #(EnterSurviveGameInfo.ReopenRoomInvitePlayers) do
				local uin = EnterSurviveGameInfo.ReopenRoomInvitePlayers[i];
				AccountManager:route('InviteJoinRoom', uin, {RoomState='load_end',Msg=GetS(4888), PassWorld=EnterSurviveGameInfo.PassWorld});
			end
			EnterSurviveGameInfo.ReopenRoomInvitePlayers = nil;
			EnterSurviveGameInfo.NeedInvite = false;
		end

		if AccountManager:getMultiPlayer() == 2 then	--客机联进房间成功，清0联机失败次数
			t_ad_data.onlineRoomFailNum = 0;
		end

		local teamupSer = GetInst("TeamupService")
		if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
			--connect_mode 2 组队 1 好友 0 公开
			if IsRoomOwner() and 2 == RoomInteractiveData.connect_mode then
				--普通地图开的组队
				teamupSer:NotifyMemberDoJoinGame(RoomInteractiveData.curRoomName, RoomInteractiveData.curRoomPW)
			else
				if RentPermitCtrl:IsSelfPersonalQuickUpRentRoom(true) and teamupSer:IsLeader(AccountManager:getUin()) then
					--组装一下房间信息 -- 过滤下不是组队房间的情况
					local roomInfo = RentPermitCtrl:GetRentRoomOriDesc() or {}

					teamupSer:NotifyMemberDoJoinCloudGame(RoomInteractiveData.curRoomName, RoomInteractiveData.curRoomPW, roomInfo)
				end
			end
			SurviveGame_AddQuitFunc(function()
				if GetInst("TeamupService") then
					GetInst("TeamupService"):GameQuit()
				end
			end)
		end

		--联机初始化
		if AccountManager:getMultiPlayer() > 0 then
			InitMultiPlayerInfoFrame();
			if not GetInst("TeamVocieManage"):isInTeamVocieRoom() then
				if GYouMeVoiceMgr and GYouMeVoiceMgr.setReportBufferTime then
					GYouMeVoiceMgr:setReportBufferTime(30);
				end
			end
		end

		if t_autojump_service and t_autojump_service.play_together.anchorUin > 0 then
			t_autojump_service.play_together.OnRespPlayTogether('success');
		end


		----TApmMarkLevelLoad();

		--统计信息的记录
		EnterSurviveGameInfo.StatisticsData.GameType = AccountManager:getMultiPlayer() > 0 and "multi" or "single"; --游戏类型（单机、联机）
		EnterSurviveGameInfo.StatisticsData.GameMode = GetGameMapDesc();
		EnterSurviveGameInfo.StatisticsData.Host = IsRoomOwner() and 1 or 0;

		local ownMap = 0;
		local worldDesc = AccountManager:getCurWorldDesc();
		if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
			if worldDesc and worldDesc.realowneruin == AccountManager:getUin() then
				ownMap = 1;
			end
		end
		EnterSurviveGameInfo.StatisticsData.OwnMap = ownMap;
		EnterSurviveGameInfo.StatisticsData.GameLabel = nil;
		if AccountManager:getMultiPlayer() == 0 then
			if worldDesc then
				EnterSurviveGameInfo.StatisticsData.GameLabel = worldDesc.gameLabel;
			end
		end

		EnterSurviveGameInfo.StatisticsData.GameLabel_9002 = 0;
		if AccountManager:getMultiPlayer() > 0 then
			EnterSurviveGameInfo.StatisticsData.GameLabel_9002 = RoomInteractiveData.cur_gameLabel;
		end

		EnterSurviveGameInfo.StatisticsData.OWID = 0;
		if worldDesc then
			EnterSurviveGameInfo.StatisticsData.OWID = worldDesc.fromowid;
		end

		EnterSurviveGameInfo.StatisticsData.EnterTime = 0;--AccountManager:getSvrTime();
		CalcEnterGameTime();

		ns_ma.play_map_report()   --触发福利活动和上报

		--打开新版聊天框
		GetInst("ChatHelper"):OpenChatView()

		--迷你队长提示
		ChatContentFrameEvent(nil, 2, "", GetS(3637));

		--13号插屏广告:仅海外
		CheckShowAdvert13();

	  	--25号广告
		UpdateAdvert25Btn();

		--租赁服公告
		RentPermitCtrl:ShowRentNoticePopup()

		-- 进入房间之后 更新添加一个 最新 房间
		RecentlyCSRoom.AddCSRoomToRecently()

		--增加一个首次进行飞行操作的提示标志
		ShowFlyTipsFlag = false

		GetInst("UIManager"):Open("WaterMark",{disableOperateUI = true})

		if SingleEditorFrame_Switch_New then
			--自定义装备:使用、禁用avator按钮
			GetInst("ModsLibEditorItemPartMgr"):InitAvatorBtnInfo(true);
		end

		--通过浏览器展示官方服房间列表界面，进入房间之后要关闭浏览器
		JsBridge:OnBrowserClose();

		--地图内自定义动作信息导入
		ARMotionCapture:LoadLocalMapMotionData();

		-- 地图设置对设置背包初始道具列表标记更新
		if GetInst("UIManager"):GetCtrl("BasicSettingItemSetting") then
			GetInst("UIManager"):GetCtrl("BasicSettingItemSetting"):SetUpdateItemDef(true);
		end

		local rolemodelID = AccountManager:getRoleModel();
		local genuisLv = AccountManager:getAccountData():getGenuisLv(rolemodelID);
		local skinModel = AccountManager:getRoleSkinModel();
		local roleDef = DefMgr:getRoleDef(rolemodelID, genuisLv);

		-- 春节活动数据导入
		if SFActivityMgr and CurWorld then
			local mode = 0
			if CurWorld:isSurviveMode() and not CurWorld:isFreeMode() then
				mode = 1
			elseif CurWorld:isExtremityMode() then
				mode = 2
			end
			if mode ~= 0 then
				if SFActivityMgr.enterWorld then
					SFActivityMgr:enterWorld(AccountManager:getUin(),mode)
				end
			end
		end
		if not GetInst("TeamVocieManage"):isInTeamVocieRoom() then
			if InformFrameClearVoiceInformPlayerList then
				InformFrameClearVoiceInformPlayerList()
			end
		end

		--如果是家园地图的话
		if IsInHomeLandMap and IsInHomeLandMap() then
			--ClientBackpack:clearPack();	--进家园清理快捷栏		
			GetInst("HomeLandDataManager"):SetFirstEntryGiftToShortcut();	--设置第一次进家园给的奖励道具到快捷栏上
		end

		--进入单人冒险地图埋点
		standReportSurviveGameEvent(1)

		RefreshAchievement()

		--内部接口有处理重复拉取
        WWW_get_building_bag_unlock_info() --获取解锁信息

		ResetTaskTrackFrame()

		OpenNewBPPersistentTaskInGame(); --开启bp持续性任务的统计

		-- 设置喷漆道具显示默认值
		GetInst("ShopPaintDataManager"):CheckOwnedData()
		local curPaintItem
		local pGameSprayPaintCtrl = ClassList["GameSprayPaintCtrl"]
		local historyData = pGameSprayPaintCtrl:GetHistroyData()
		if historyData and #historyData > 0 then
			curPaintItem = historyData[1]
		else
			local OwnedData = GetInst("ShopPaintDataManager"):GetOwnedShopSprayPaintTbl()
			if OwnedData and #OwnedData > 0 then
				curPaintItem = OwnedData[1]
			end
		end
		if curPaintItem then
			getglobal("PaintChangeFrame"):SetClientUserData(0, curPaintItem.spray_id)
			if UpdatePaintChangeBtn then
				UpdatePaintChangeBtn()
			end
		else
			getglobal("PaintChangeFrame"):SetClientUserData(0, 0)
		end

		GetInst("ShopPaintDataManager"):RequestOwnedInfo()

		if CurWorld then
			GetInst("AnniActInterface"):RefreshMatchingMapUI(CurWorld:getOWID())
			GetInst("IceSheetActInterface"):OpenActMatchView(CurWorld:getOWID())
		end

		local num = ClientCurGame and ClientCurGame.getNumPlayerBriefInfo and ClientCurGame:getNumPlayerBriefInfo() or 0;
		local beforeJoinFridUins = {}
		for i=1, num do
			local briefInfo = ClientCurGame:getPlayerBriefInfo(i-1);
			if briefInfo ~= nil and IsMyFriend( briefInfo.uin) then
				table.insert(beforeJoinFridUins, briefInfo.uin)
				GetInst('OnlineFriendDataMgr'):UpdateFriendTimes(GetInst('OnlineFriendDataMgr'):GetTypes().togetherPlay,briefInfo.uin)
			end
		end
		if #beforeJoinFridUins > 0 then
			GetInst('SocialHallDataMgr'):ReqSyncInteractiveData(beforeJoinFridUins, GetInst('SocialHallDataMgr').InteractiveType.togetherPlay)
		end
	end);

	threadpool:work(function()
		if PlatformUtility:isDevBuild() then
			if nil == ClientCurGame then
				ShowGameTipsWithoutFilter(string.format("开发环境:SurviveGame_Enter中ClientCurGame为nil，将影响任务上报"))
			end
			if nil == WorldMgr then
				ShowGameTipsWithoutFilter(string.format("开发环境:SurviveGame_Enter中WorldMgr为nil，将影响任务上报"))
			end
		end
		local fromOwid = G_GetFromMapid()
		if "number" == type(fromOwid) then
			GetInst('UserTaskInterface'):PlayerEnterGame(fromOwid)
			GetInst('UserTaskInterface'):PlayerEnterMap(fromOwid)
		else
			GetInst('UserTaskInterface'):PlayerEnterGame()
			GetInst('UserTaskInterface'):PlayerEnterMap()
		end
		-- GetInst('UserTaskInterface'):UserTaskEventReport("MapEnter",1)
	end)

	RequestHomeLandInfoAfterEnter()

	FesivialActivity:OnEnterGame()
	
	-- 武器皮肤模块
	if WeaponSkin_HelperModule then
		WeaponSkin_HelperModule:OnEnterWorld()
	end

	-- 特长
	if Genius_Helper then
		Genius_Helper:OnEnterWorld()
	end

	threadpool:work(function() 
		if GetInst('BroadcastMgr') then -- 进入游戏 初始化播报界面
			GetInst('BroadcastMgr'):OnEnterGameSuccess()
		end

		-- 关闭掉商店
		local shopctrl = GetInst("UIManager"):GetCtrl("Shop")
		if shopctrl then
			shopctrl:CloseBtnClicked(true)
		end
		if GetInst("SkinCollectManager") then
			GetInst("SkinCollectManager"):HideAllWindows()
		end

		GetInst("MiniUIManager"):CloseUI("ActivePlayerBenefits_EggAutoGen", true) -- 关闭高活彩蛋
		GetInst("MiniUIManager"):CloseUI("ActivePlayerBenefits_MainAutoGen", true) -- 关闭高活弹窗
		
		-- 关闭消息中心界面
		GetInst("MiniUIManager"):CloseUI("MessageCenterAutoGen", true) -- 关闭消息中心
	end)

	VoiceOnEnterGame()

	--地图皮肤语音
	SandboxLua.eventDispatcher:Emit(nil, "SkinVoice_System_PlayerOnEnter", SandboxContext())

	GetInst("UGCCommon"):EnterWorld()

	GetInst("ArchiveLobbyRecordManager"):CacheNewRecord()


	local isSoical, mapid, roomid = RoomInteractiveData:IsSocialHallRoom()
	if isSoical then
		GetInst("SocialHallDataMgr"):AddJoinHistory(mapid, roomid)
		SurviveGame_AddQuitFunc(function()
			GetInst("SocialHallDataMgr"):ClearGameData()
		end)
	else
		if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
			local owid = G_GetFromMapid()
			if owid and owid > 0 then
				local sceneInfo = InGameGetStartRptSceneInfo()
				GetInst("ArchiveLobbyDataManager"):AddOrUpNativeStoreRecord(owid, false, sceneInfo)
			end
		else
			local owid = G_GetFromMapid()
			if owid and owid > 0 then
				local sceneInfo = InGameGetStartRptSceneInfo()
				threadpool:work(function()
					CheckSupportAllCloud_SyncReqWeakCheck({owid}, nil, false)
					
					if GetInst("RoomService"):CheckMapSupportQuickupRent(owid) then
						GetInst("ArchiveLobbyDataManager"):AddOrUpCloudStoreRecord(owid, false, sceneInfo)
					else
						GetInst("ArchiveLobbyDataManager"):AddOrUpNativeStoreRecord(owid, false, sceneInfo)
					end
				end)
			end
		end
	end

	NewBattlePassEventOnTrigger("entersurvivegame");
end

function InGameGetStartRptSceneInfo()
	local switchParam = GetInst("ReportGameDataManager"):GetGameRecordSwitchParam() or {}
	local sceneInfo = {
		scene_id = switchParam.sceneid,
		card_id = switchParam.cardid,
		comp_id =  switchParam.compid,
		trace_id = ReportTraceidMgr:PackWholeTraceid(switchParam.trace_id),
	} 
	return sceneInfo
end

function RefreshAchievement()
	--冒险成就的一些初始化
	do
		--if AccountManager:getMultiPlayer() > 0 then return end
		if not CurWorld then return end
		if not CurWorld:isSurviveMode() or CurWorld:isFreeMode() then
			return --不是冒险模式
		end
		--为了启动成就监听事件 code_by:huangfubin
		getglobal("AchievementFrame")
		--刷新冒险地图的奖励记录 code_by:huangfubin
		UpdateAchievementRewardNum()
		UpdateAdvantureRewardTag()
	end
end

--显示首次飞行tips
function ShowFlyTips()
	if not ShowFlyTipsFlag then
		ShowFlyTipsFlag = true
		ShowGameTips(GetS(21053), 3)
	end
end

--13号插屏广告
function CheckShowAdvert13()
	print("CheckShowAdvert13:");
	-- if CurWorld:isGodMode() then return end
	if CurWorld:getOWID() == NewbieWorldId or CurWorld:getOWID() == NewbieWorldId2 then return end

	--单机或联机时的客机
	if IsRoomClient() or AccountManager:getMultiPlayer() == 0 then
		print("ok");
		threadpool:delay(0.2, function()
			AdvertCommonHandle:ShowAdvert(13, ADVERT_PLAYTYPE.AUTOSHOW);
	  	end);
	end
end

--显示/隐藏25号广告位按钮:仅海外
function UpdateAdvert25Btn()
	print("ShowAdvert25Btn:");
	local advert25btnUI = "PlayMainFrameAdvert25Btn";
  	local advert25btn = getglobal(advert25btnUI);
  	local advert25btnDesc = getglobal(advert25btnUI .. "Desc");
  	advert25btn:Hide();

  	if AccountManager:getMultiPlayer() ~= 0 then  return end
	if CurWorld:isGodMode() then return end
	if CurWorld:getOWID() == NewbieWorldId or CurWorld:getOWID() == NewbieWorldId2 then return end
	--if CUR_WORLD_MAPID > 0 and CUR_WORLD_MAPID ~= 2 then return end

  	if CurWorld and (CurWorld:isSurviveMode() or CurWorld:isExtremityMode() or CurWorld:isCreateRunMode()) then
  		--三种模式:冒险、极限、创造转的模拟冒险
  		local advertID = 25;
	  	if t_ad_data.canShow(advertID) and AdvertCommonHandle:ProbabilityShow(advertID) then
			print("UpdateAdvert25Btn:probability ok");
	  		local ad_info = AccountManager:ad_position_info(advertID);
			if ad_info and ad_info.extra and ad_info.extra.reward_id and ad_info.num_total then
				print("UpdateAdvert25Btn:ad_info ok");
	  			local finish_count = ad_info.finish and ad_info.finish.count or 0;
	  			local num_total = ad_info.num_total or 0;
	  			local text = GetS(100598) .. "(" .. finish_count .. "/" .. num_total .. ")";

	  			print("UpdateAdvert25Btn:text = ", text);
				local reward_id = AdvertCommonHandle:GetRewardID(advertID)
	  			SetItemIcon(getglobal(advert25btnUI .. "Icon"), reward_id);
		  		advert25btn:Show();
		  		advert25btnDesc:SetText(text);

		  		if finish_count >= num_total then
	  				advert25btn:Disable(false);
	  			else
		  			advert25btn:Enable(false);
	  			end
	  		end
		end
	end
end

--25号广告播放按钮
function PlayMainFrameAdvert25Btn_OnClick()
	local advertID = 25;
	AdvertCommonHandle:ShowAdvert(advertID, ADVERT_PLAYTYPE.CLICK2SHOW);
end

function TApmMarkLevelLoad()
	if ClientMgr:isMobile() then
		local sceneName = GetSceneName()
		local viewDval = 0;
		if ClientCurGame:isInGame() then
			viewDval = ClientMgr:getGameData("view_distance");					--视野距离
		end

		--[[if TApmMgr then
			TApmMgr:markLevelLoad(sceneName, viewDval);
		end]]---
	end
end

function GetSceneName()
	if ClientCurGame:isInGame() then
		if CurWorld:getOWID() == NewbieWorldId then
			return "NewbieWorld";
		else
			local sceneName = ""
			if CurWorld:isSurviveMode() or CurWorld:isExtremityMode() then
				sceneName = sceneName.."SurviveMode";
			elseif CurWorld:isCreativeMode() then
				sceneName = sceneName.."CreateMode";
			elseif CurWorld:isCreateRunMode() then
				sceneName = sceneName.."CreateRunMode";
			elseif CurWorld:isGameMakerMode() then
				sceneName = sceneName.."GameMakerMode";
			elseif CurWorld:isGameMakerRunMode() then
				sceneName = sceneName.."GameMakerRunMode";
			end

			local gameType = AccountManager:getMultiPlayer();
			if gameType == 0 then
				sceneName = sceneName.."_StandAlone";
			elseif gameType == 2 then
				sceneName = sceneName.."_Client";
			else
				sceneName = sceneName.."_Host";
			end

			local days = 0;
			if CurMainPlayer then
				days = CurMainPlayer:getSurviveDay();
				if days <= 2 then
					sceneName = sceneName.."_2Days";
				elseif days <= 5 then
					sceneName = sceneName.."_5Days";
				elseif days <= 10 then
					sceneName = sceneName.."_10Days";
				elseif days <=30 then
					sceneName = sceneName.."_30Days";
				else
					sceneName = sceneName.."_MoreThan30Days";
				end
			end

			return sceneName;
		end
	else
		return "MainMenuStage";
	end
end

function CalcEnterGameTime()
	threadpool:work(function()
		while true do
			local code = threadpool:wait('InGame', 1);
			if code == ErrorCode.TIMEOUT then
				EnterSurviveGameInfo.StatisticsData.EnterTime = EnterSurviveGameInfo.StatisticsData.EnterTime + 1; --30秒太久了，改成1秒一次 code_by:huangfubin
			else
				break;
			end
		end
	end);
end

g_tStatictisSurviveGameTime = {

}

--worldId 存档id
--mapId 副本id
function AddStatictisSurviveGameTime(worldId, mapId, ownMap, activeDays, worldtype, gameType)
	for i=1, #g_tStatictisSurviveGameTime do
		if g_tStatictisSurviveGameTime[i].WorldId == worldId and g_tStatictisSurviveGameTime[i].MapId == mapId then
			g_tStatictisSurviveGameTime[i].Time = g_tStatictisSurviveGameTime[i].Time + 1;
			return;
		end
	end

	table.insert(g_tStatictisSurviveGameTime, {WorldId=worldId, MapId=mapId, OwnMap=ownMap, ActiveDays=activeDays, WorldType=worldtype, GameType=gameType, Time=1});
end

function SurviveGame_Quit()
	Log( "call SurviveGame_Quit=============" );

	local ComposeMain = GetInst("MiniUIManager"):GetUI("MiniUIComposeMain")
	if not ComposeMain then 
		threadpool:work(function ()
			GetInst("MiniUIManager"):CloseUI("MiniUIComposeMain") --地图内先缓存，退出地图再关闭
		end)
	end
	getglobal("PlayMainFrame"):Hide()
	getglobal("DeathFrame"):Hide()
	getglobal("PcGuideKeySightMode"):Hide()

	pcall(function()
		RoomInteractiveData.RoomInfoMgr:Clean()
		if not PlatformUtility:isPureServer() then
			SafeCallFunc(GetInst("ArchiveLobbyRecordManager").CacheAddRecord, GetInst("ArchiveLobbyRecordManager"))
		end
	end)

	AutoOpenPlayerInfo = true;
	if not GetInst("TeamVocieManage"):isInTeamVocieRoom() then
		if GYouMeVoiceMgr then
			GYouMeVoiceMgr:quitRoom();
		
			if GYouMeVoiceMgr.clearVoiceInformData then
				GYouMeVoiceMgr:clearVoiceInformData();
			end
		end
		if InformFrameClearVoiceInformPlayerList then
			InformFrameClearVoiceInformPlayerList()
		end
	end

	-- 春节活动，退出地图发送一次数据到服务端
	if GetInst("SpringFestivalManager") then
		GetInst("SpringFestivalManager"):SendInfo()
	end
	if SFActivityMgr and SFActivityMgr.leaveWorld then
		SFActivityMgr:leaveWorld()
	end


	

	local id = ClientMgr:getApiId();
	if id == 38 or id == 39 or id == 41 or id == 42 then
		SdkManager:setSdkFloatMenu(1);  									-- 1 退出游戏地图; 2 进入游戏地图
	end

	--30009
	for i=1, #g_tStatictisSurviveGameTime do
		local t = g_tStatictisSurviveGameTime[i];
		statisticsGameEvent(30009, "%lld", t.WorldId, "%d", t.MapId, "%d", t.OwnMap, "%d", t.ActiveDays, "%d", t.WorldType, "%d", t.Time, "%s", t.GameType);
	end

	g_tStatictisSurviveGameTime = {};

	--统计存档数据
	if EnterSurviveGameInfo.StatisticsData then
		local totalTime = EnterSurviveGameInfo.StatisticsData.EnterTime; --AccountManager:getSvrTime() - EnterSurviveGameInfo.StatisticsData.EnterTime;

		if threadpool:waitting('InGame') then
			threadpool:notify('InGame', ErrorCode.FAILED);
		end
		print("kekeke SurviveGame_Quit totalTime:", totalTime);

		do
			--借用此处统计的单局时长在本地记录地图游玩时长
			local statusType = "mutClient"
			if EnterSurviveGameInfo.StatisticsData.GameType == 'single' then
				statusType = "single"
			elseif EnterSurviveGameInfo.StatisticsData.Host == 1 then
				statusType = "mutHost"
			end
			pcall(function() GetInst("MapPlayTimeMgr"):AddTime(G_SurviveGame_InfoCache.fromowid, statusType, totalTime) end)
		end

		--2021-12-27 by hrl:更改旧版客户端埋点30s内数据不上报的逻辑为：发生进入地图游戏行为即上报数据
		if totalTime and totalTime >= 0 and totalTime <= 86400 then
			local activeDays = 0;
			if AccountManager.get_active_days then
				activeDays = AccountManager:get_active_days();
				if activeDays >= 15 then
					activeDays = 3;
				elseif activeDays >= 8 then
					activeDays = 2;
				elseif activeDays >= 2 then
					activeDays = 1;
				else
					activeDays = 0;
				end
			end

			--9000 单机自己的地图  游戏模式 活跃天    时长  地图ID                    3|CN|1|7|232287600|6411|3|survive|4440
			--9001 单机下载地图    label    活跃天    时长   mapid                2|CN|1|36|230571984|6411|2|2272078562324|3|330
			--9002 联机地图        label    是否主机  是否自己的图 活跃天  时长 OWID  2|CN|1|13|383660732|6411|2|0|0|0|1260|??????????????
			if EnterSurviveGameInfo.StatisticsData.GameType == 'single' then
				if EnterSurviveGameInfo.StatisticsData.OwnMap == 1 then
					local worldid = 0
					local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
					if worldDesc then
						worldid = worldDesc.worldid
					end
					statisticsGameEvent(9000, '%s', EnterSurviveGameInfo.StatisticsData.GameMode, '%d', activeDays,  '%d', totalTime, '%d', worldid);
				elseif EnterSurviveGameInfo.StatisticsData.GameLabel then
					if EnterSurviveGameInfo.StatisticsData.OWID > 0 then
						statisticsGameEvent(9001, '%d', EnterSurviveGameInfo.StatisticsData.GameLabel, '%d', activeDays,  '%d', totalTime, "%lld", EnterSurviveGameInfo.StatisticsData.OWID);
					else
						statisticsGameEvent(9001, '%d', EnterSurviveGameInfo.StatisticsData.GameLabel, '%d', activeDays,  '%d', totalTime);
					end
				end
			else
				local GameLabel_9002 = EnterSurviveGameInfo.StatisticsData.GameLabel_9002 or 0
				--if GameLabel_9002 == 0 or EnterSurviveGameInfo.StatisticsData.GameLabel_9002 == 0 then
				--	print("bad label equal zero"..4, "糟心的label==0的情况出现了")
				--end
				print("GameLabel_9002: ",GameLabel_9002)
				local fromowid = 0;
				local mapOpen = 0
				if not IsRoomClient() then 		--判断是否是客机
					local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
					if worldDesc then
						if worldDesc.fromowid and worldDesc.fromowid ~= 0 then
							fromowid = worldDesc.fromowid
						else
							fromowid = worldDesc.worldid
						end

						if worldDesc.open == 0 then
							mapOpen = 2
						elseif worldDesc.open == 1 and worldDesc.OpenSvr == 0 or worldDesc.OpenSvr == 9 then
							mapOpen = 3
						elseif worldDesc.open == 2 then
							mapOpen = 1
						end
					end
				else
					fromowid = DeveloperFromOwid;
				end

				if not fromowid or 0 == fromowid then
					fromowid = G_SurviveGame_InfoCache.fromowid or 0
				end
				local roomtype = mIsLanRoom and 2 or 1
				local csroomid = GetCurrentCSRoomId(true);
				if csroomid ~= "" then
					roomtype = 3
					if "string" == type(csroomid) and not string.match(csroomid, '^%d+_%d+$') then
						roomtype = 4
					end 
				end
				print("SurviveGame_Quit(): fromowid" .. tostring(fromowid))
				--print(roomtype, "  ", GetCurrentCSRoomId())
				statisticsGameEventNew(9002,
						GameLabel_9002,
						EnterSurviveGameInfo.StatisticsData.Host,
						EnterSurviveGameInfo.StatisticsData.OwnMap,
						activeDays,
						totalTime,
						fromowid,
						roomtype,		--1：外网（WiFi）2：局域网（热点） 3：云服 4:一键云服
						csroomid,
						IsArchiveMapCollaborationMode() and 1 or 0,
						mapOpen,
						EnterSurviveGameInfo.StatisticsData.GameMode);
			end
		end
	end

	RoomInteractiveData.curRoomPW = "";
	if ResourceCenterNewVersionSwitch then
		if GetInst("UIManager"):GetCtrl("ResourceCenter") then
			GetInst("UIManager"):GetCtrl("ResourceCenter"):clearMapNewAddModel();
		end
	else
		clearMapNewAddModel();
	end
	RoomInteractiveData.curRoomName = ""
	setCurInRoomName("")
	RoomInteractiveData.curMapwid = 0
	RoomInteractiveData.connect_mode = nil

	--清除动作数据
	ARMotionCapture:ClearMapMotionData();

	--设置数据更新为false
	HomelandCallModuleScript("HomelandRanchModule","setIsUpdatedByServer",false)

	--退出单人冒险埋点
	standReportSurviveGameEvent(0)

	CloseNewBPPersistentTaskInGame(); --关闭bp持续性任务的统计

	ClearCurGamePlaymateCache()
	

	FesivialActivity:OnLeaveGame()
	if YearMonsterGameStop then
		YearMonsterGameStop()
	end

	if G_SurviveGame_InfoCache.quit_funcs and G_SurviveGame_InfoCache.quit_funcs.ary then
		for index, func in ipairs(G_SurviveGame_InfoCache.quit_funcs.ary) do
			pcall(func)
		end
	end
	

	if GetInst("NewbieSocialDataMgr") then
		GetInst("NewbieSocialDataMgr"):OnGameEnd()
	end

	pcall(SurviveGame_Quit_ClearInfoCache)
	UIEditorDef:closeRootNode()
	GetInst("UGCCommon"):QuitWorld()
	-- GetInst("GuideMgr"):GameExit()--引导屏蔽
	GetInst("ShareArchiveInterface"):EndTryPlayTime()
end

function NewbieWorldId_Enter()
	standReportEvent("38", "NEWPLAYER_TEACHINGMAP_GUIDE", "-", "view");
	standReportEvent("38", "NEWPLAYER_TEACHINGMAP_GUIDE", "Video", "view");
	RunCutscene(0);
end

function ShowCurNoviceGuideTask()
	--[[
	local NoviceAwardFrame = getglobal("NoviceAwardFrame")
	if not AccountManager:getNoviceGuideState("welcome") then		--欢迎进入游戏
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(304), 1);
		getglobal("SurvivalGameNovice"):Show();
	elseif not AccountManager:getNoviceGuideState("rotationview") then	--转动视角
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(305), 2);
		SetGuideFingerInfo(600, 250, 100, 1, false, 0);
	elseif not AccountManager:getNoviceGuideState("move") then		--人物移动
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(306), 3);
		SetGuideFingerInfo(215, 530, 100, 4, false, 0);
	elseif not AccountManager:getNoviceGuideState("destroy") then		--破坏方块
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(307), 4);
	--	ClientCurGame:playEffect(-150, 950, -150, "1033.ent");
		ClientCurGame:playEffect(-150, 850, -170, "1035.ent");
	elseif not AccountManager:getNoviceGuideState("finishone") then		--完成了第一次任务
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(308), 5);
		NoviceAwardFrame:Show();
	elseif not AccountManager:getNoviceGuideState("lumber") then		--伐木
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(309), 6);
		ShortCutNoviceShow = true;
		getglobal("PlayShortcut"):SetPoint("bottom", "PlayMainFrame", "bottom", 0, 100);
		getglobal("PlayShortcut"):Show();
		ClientCurGame:playEffect(-150, 850, 780, "1035.ent");
	elseif not AccountManager:getNoviceGuideState("finishtwo") then		--完成第二个任务
		ClientCurGame:stopEffect();
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(310));
		NoviceAwardFrame:Show();
	elseif not AccountManager:getNoviceGuideState("openBP") then		--打开背包
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(311), 7);
		getglobal("PlayMainFrameBackpack"):Show();
		SetGuideFingerInfo(882, 660, 0, 5, true, 120);
	elseif not AccountManager:getNoviceGuideState("chooseBPmake") then	--选择制作面板
		SetGuideTipsInfo(-260, 130, 1, StringDefCsv:get(312), 8);
		SetGuideFingerInfo(78, 403, 0, 5, true, 100);
	elseif not AccountManager:getNoviceGuideState("makeCT") then		--制作制作台
		local grid_index = CheckProductId(800, 0);
		if grid_index > 0 then
			if ClientBackpack:getGridEnough(grid_index) == 0 then
				SetGuideTipsInfo(-260, 130, 1, StringDefCsv:get(300));
			else
				SetGuideTipsInfo(-260, 30, 1, StringDefCsv:get(301), 9);
				local index = grid_index+1-PRODUCT_LIST_TWO_INDEX;
				local indexX = index - math.floor((index-1)/5)*5;
				local indexY = math.floor((index-1)/5);
				x = 200 + (indexX-1)*106;
				y = 150 + indexY*106;
				SetGuideFingerInfo(x, y, 0, 5, true, 100);
			end
		else
			SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(300));
		end
	elseif not AccountManager:getNoviceGuideState("finishthree") then	--完成第三个任务
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(313), 10);
		NoviceAwardFrame:Show();
	elseif not AccountManager:getNoviceGuideState("chooseCT") then		--选择合成台
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(314), 11);
	elseif not AccountManager:getNoviceGuideState("placeCT") then		--放置合成台
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(315), 12);
	elseif not AccountManager:getNoviceGuideState("openCT") then		--打开合成台
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(316), 13);
		HideGridEffectForNoviceGuide();
	elseif not AccountManager:getNoviceGuideState("makeWP") then		--合成台制作
		local grid_index = CheckNormalProductId(11011, 0);
		if grid_index > 0 then
			if ClientBackpack:getGridEnough(grid_index) == 0 then
				SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(302));
			else
				SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(303), 14);
				local index = grid_index+1-COMMON_PRODUCT_LIST_INDEX;
				local indexX = index - math.floor((index-1)/5)*5;
				local indexY = math.floor((index-1)/5);
				x = 240 + (indexX-1)*92;
				y = 115 + indexY*94;
				SetGuideFingerInfo(x, y, 0, 5, true, 100);
			end
		else
			SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(300));
		end
	elseif not AccountManager:getNoviceGuideState("finishfour") then	--完成第四个任务
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(317));
		NoviceAwardFrame:Show();
	elseif not AccountManager:getNoviceGuideState("chooseBread") then	--选中面包
		MainPlayerAttrib:addHP(-4);
		PlayerHPBar_ShowOrHide(true);
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(318), 15);
	elseif not AccountManager:getNoviceGuideState("eatBread") then		--吃面包
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(319), 16);
		SetGuideFingerInfo(1182, 457, 0, 7, true, 140, true);
	elseif not AccountManager:getNoviceGuideState("finishfive") then	--完成第五个任务
		HideGridEffectForNoviceGuide();
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(320), 17);
		NoviceAwardFrame:Show();
	elseif not AccountManager:getNoviceGuideState("wearEP1") then		--穿装备1-打开背包
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(321), 18);
		SetGuideFingerInfo(882, 660, 0, 5, true, 120);
	elseif not AccountManager:getNoviceGuideState("wearEP2") then		--穿装备2-打开角色面板
		SetGuideTipsInfo(-260, 130, 1, StringDefCsv:get(322), 19);
		SetGuideFingerInfo(80, 530, 0, 5, true, 120);
	elseif not AccountManager:getNoviceGuideState("wearEP3") then		--穿装备3-点击装备
		SetGuideTipsInfo(-260, 130, 1, StringDefCsv:get(323), 20);
		SetGuideFingerInfo(222, 315, 0, 5, true, 120);
	elseif not AccountManager:getNoviceGuideState("wearEP4") then		--穿装备4-放置装备
		SetGuideTipsInfo(-260, 130, 1, StringDefCsv:get(324), 21);
		SetGuideFingerInfo(997, 290, 0, 5, true, 120);
	elseif not AccountManager:getNoviceGuideState("wearEP5") then		--穿装备5-装备完成
		SetGuideTipsInfo(-260, 130, 1, StringDefCsv:get(325), 22);
		SetGuideFingerInfo(65, 85, 0, 5, true, 120);
	elseif not AccountManager:getNoviceGuideState("killzombie") then	--击杀僵尸
		SetGuideTipsInfo(-260, 65, 1, StringDefCsv:get(326), 23);
		MainPlayerAttrib:addBuff(61, 1);
		MainPlayerAttrib:addBuff(62, 1);
		ClientCurGame:addmob(3102, "1035");
	elseif not AccountManager:getNoviceGuideState("end") then	--击杀僵尸
		getglobal("NoviceGuideEndFrame"):Show();
		ClientMgr:playSound2D("sounds/ui/guide/guide_24.ogg", 1);
	end

	UpdateGuideTaskFrame();
	]]
end
-----------------------------------------筛选相关----------------------------------------------------
RankFlag = 1;			--1默认 2推荐 3赞 4下载量 5最新
local DownArchiveType  = 1;	--筛选下载存档的类型 ......
function ShowArchiveFilterFrame(label, order, orderNames, type) --type: 0兼容旧逻辑 1类别 2排序
	for i = 1, 5 do
		local filter = getglobal("ArchiveFilterFrameType"..i);
		local filterText = getglobal("ArchiveFilterFrameType"..i.."Font");

		if orderNames and i <= #orderNames and (type == 2 or type == 0) then
			filter:Show();
			filterText:SetText(orderNames[i]);
		elseif i == 1 and (type == 2 or type == 0) then
			filter:Show();
		else
			filter:Hide();
		end
	end

	local showFilters = {}
	for i = 1, 12 do
		local filter = getglobal("ArchiveFilterFrameFilter"..i);

		if type == 1 or type == 0 then
			filter:Show();
			table.insert(showFilters, i)
		elseif type == 3 then
			--录像标签隐藏
			if i == 7 then
				filter:Hide()
			else
				filter:Show()
				table.insert(showFilters, i)
			end
		else
			filter:Hide();
		end
	end


	DownArchiveType = label;
	RankFlag = order;
	getglobal("ArchiveFilterFrame"):Show();

	--工坊搜索页面单独处理
	if getglobal("SearchArchiveBox"):IsShown() then
		getglobal("ArchiveFilterFrameFilter1"):SetPoint("topleft","MiniWorksFrameConnoisseurFilter","bottomleft",164,-5)
		for i=1, 9 do
			local filter = getglobal("ArchiveFilterFrameFilter"..i);
			local check = getglobal("ArchiveFilterFrameFilter"..i.."Checked");

			if i == mapservice.searchMapType then
				check:Show();
			else
				check:Hide();
			end
		end
	elseif MiniWorksFilterOpen then
		getglobal("ArchiveFilterFrameFilter1"):SetPoint("topleft","MiniWorksCommendDetailTopFrameFilterBtn","bottomleft",0,-5)
		getglobal("ArchiveFilterFrameType1"):SetPoint("top", "MiniWorksCommendDetailTopFrameSortBtn", "bottom", 0, -5)
	elseif getglobal("MiniWorksTemplate"):IsShown() then
		getglobal("ArchiveFilterFrameFilter1"):SetPoint("topleft","MiniWorksTemplateTopFrameFilterBtn","bottomleft",0,-5)
		getglobal("ArchiveFilterFrameType1"):SetPoint("top", "MiniWorksTemplateTopFrameSortBtn", "bottom", 0, -5)
	-- elseif getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 	getglobal("ArchiveFilterFrameFilter1"):SetPoint("topleft","MiniWorksFrameSearchFilter","bottomleft",0,-5)
	-- 	for i=1, 9 do
	-- 		local filter = getglobal("ArchiveFilterFrameFilter"..i);
	-- 		local check = getglobal("ArchiveFilterFrameFilter"..i.."Checked");

	-- 		if i == mapservice.searchMapType then
	-- 			check:Show();
	-- 		else
	-- 			check:Hide();
	-- 		end
	-- 	end
	elseif getglobal("MiniWorksMapTemplate"):IsShown() then
		getglobal("ArchiveFilterFrameFilter1"):SetPoint("topleft","MiniWorksMapTemplateTopFrameFilterBtn","bottomleft",0,-5)
		getglobal("ArchiveFilterFrameType1"):SetPoint("top", "MiniWorksMapTemplateTopFrameSortBtn", "bottom", 0, -5)
	else
		--xml中配置的对齐可能由于加载顺序问题，对齐异常
		getglobal("ArchiveFilterFrameFilter1"):SetPoint("topleft","MiniWorksFrameConnoisseurFilter","bottomleft",0,-5)
		getglobal("ArchiveFilterFrameType1"):SetPoint("top", "MiniWorksFrameConnoisseurFilter2", "bottom", 0, -5)
	end

	--重新对齐
	for i, v in ipairs(showFilters) do
		if i > 1 then
			local lastFilterName = "ArchiveFilterFrameFilter"..showFilters[i-1]
			getglobal("ArchiveFilterFrameFilter"..v):SetPoint("top",lastFilterName,"bottom",0,-5)
		end
	end
end

--点击筛选按钮
function DownArchiveFilterBtn_OnClick()
	if not CanUseNet() then
		return;
	end

	local clientId = this:GetClientID();
	--工坊搜索页面单独处理
	if getglobal("SearchArchiveBox"):IsShown() --[[or getglobal("MiniWorksFrameSearch"):IsShown()]] then
		local id =tonumber(string.sub(this:GetName(),-1,-1))
		for i=1, 9 do
			local filter = getglobal("ArchiveFilterFrameFilter"..i);
			local check = getglobal("ArchiveFilterFrameFilter"..i.."Checked");
			local name = getglobal("ArchiveFilterFrameFilter"..i.."Font");

			if i == id then
				check:Show();
				name:SetTextColor(255, 255, 255);
			else
				check:Hide();
				name:SetTextColor(185, 185, 185);
			end
		end
		mapservice.searchMapType = id;
		mapservice.searchMapId = clientId;
		-- getglobal("MiniWorksFrameSearchFilterType"):SetText(GetS(t_LabelId[id]));
		getglobal("ArchiveFilterFrame"):Hide();
		getglobal("SearchArchiveBoxRoleInfo"):Hide();

		local input = getglobal("MiniWorksFrameSearch1InputEdit"):GetText();
		-- if getglobal("MiniWorksFrameSearch"):IsShown() then
		-- 	input = getglobal("MiniWorksFrameSearchInputEdit"):GetText();
		-- 	getglobal("MiniWorksFrameSearchFilterType"):SetText(GetS(t_LabelId[id]));
		-- 	getglobal("ArchiveFilterFrame"):Hide();
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxRoleInfo"):Hide();
		-- end
		if input and input ~= "" and mapservice.searchType == 1 then
			ReqSearchMapsByType(input,true);
		end
		return;
	end

	if clientId >= 1 and clientId <= 12 then
		if DownArchiveType ~= clientId then
			DownArchiveType = clientId;
			SetDownArchiveFilterBtnCheck(1, clientId);
		end
	end
	local btn = getglobal("ArchiveFilterFrame")
	if btn and btn:IsShown() then
		standReportEvent("3", "MINI_WORKSHOP_COLLECT_1","ContentComboBox", "click",{standby1=tostring(clientId)})
	end

	ArchiveFilterFrameConfirmRefresh(1);
	ArchiveFilterFrameCloseBtn_OnClick();
end

function DownArchiveFilterBtn2_OnClick()
	if not CanUseNet() then
		return;
	end

	local clientId = this:GetClientID();

	if clientId >= 1 and clientId <= 5 then
		if RankFlag ~= clientId then
			RankFlag = clientId;
			SetDownArchiveFilterBtnCheck(2, clientId);
		end
	end

	ArchiveFilterFrameConfirmRefresh(2);
	ArchiveFilterFrameCloseBtn_OnClick();
end

function SetDownArchiveFilterBtnCheck(type, id)
	if type == 1 then 	--存档类型筛选
		for i=1, 9 do
			local filter = getglobal("ArchiveFilterFrameFilter"..i);
			local check = getglobal("ArchiveFilterFrameFilter"..i.."Checked");

			local clientId = filter:GetClientID();
			if id == clientId then
				check:Show();
			else
				check:Hide();
			end
		end
	else			--存档排行筛选
		for i=1, 5 do
			local filter = getglobal("ArchiveFilterFrameType"..i);
			local check = getglobal("ArchiveFilterFrameType"..i.."Checked");

			local clientId = filter:GetClientID();
			if id == clientId then
				check:Show();
			else
				check:Hide();
			end
		end
	end
end

function ArchiveFilterFrame_OnLoad()
	for i=1, 12 do
		local icon = getglobal("ArchiveFilterFrameFilter"..i.."Icon");
		local name = getglobal("ArchiveFilterFrameFilter"..i.."Font");
		local gameLabel = getglobal("ArchiveFilterFrameFilter"..i):GetClientID();
		SetRoomTag(icon, name, gameLabel);
	end

	t_TypeNameId = {524, 194, 3844, 193, 192};
	for i=1, 4 do
		local name = getglobal("ArchiveFilterFrameType"..i.."Font");
		name:SetText(GetS(t_TypeNameId[i]));
	end
end

function ArchiveFilterFrame_OnShow()
	SetDownArchiveFilterBtnCheck(1, DownArchiveType);
	SetDownArchiveFilterBtnCheck(2, RankFlag);

	--getglobal("ArchiveFilterFrame"):SetClientUserData(0, DownArchiveType);
	--getglobal("ArchiveFilterFrame"):SetClientUserData(1, RankFlag);

	SetMiniWorksBoxsDealMsg(false);
end

function ArchiveFilterFrame_OnHide()
	SetMiniWorksBoxsDealMsg(true);
	getglobal("ConnoisseurArchiveBox"):setDealMsg(true);
	if UseNewMiniWorksMain then
		if HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
			GetInst("UIManager"):GetCtrl("MiniWorksCommendDetail"):FilterHideNotify()
		end
	end
end

function ArchiveFilterFrameCloseBtn_OnClick()
	--getglobal("ConnoisseurArchiveBox"):setDealMsg(true);
	getglobal("ArchiveFilterFrame"):Hide();
end

function ArchiveFilterFrameConfirmRefresh(from)
	local bMiniWorksFilterOpen = MiniWorksFilterOpen
	getglobal("ArchiveFilterFrame"):Hide();
	--local type = getglobal("ArchiveFilterFrame"):GetClientUserData(0);
	--local rank = getglobal("ArchiveFilterFrame"):GetClientUserData(1);
	if bMiniWorksFilterOpen then
		if HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
			GetInst("UIManager"):GetCtrl("MiniWorksCommendDetail"):loadInfo(DownArchiveType, RankFlag, true,from)
		end
	elseif getglobal("PlayerCenterFrame"):IsShown() then
		PlayerCenterFrame_SetFilter(DownArchiveType, RankFlag);
	elseif getglobal("MiniWorksTemplate"):IsShown() then
		GetInst("UIManager"):GetCtrl("MiniWorksTemplate"):UpdateFilter(DownArchiveType,RankFlag)
	elseif HasUIFrame("MapTemplateCommend") and getglobal("MapTemplateCommend"):IsShown() then
		GetInst("UIManager"):GetCtrl("MapTemplateCommend"):RefreshFilterAndSort(DownArchiveType,RankFlag)
	elseif getglobal("MiniWorksMapTemplate"):IsShown() then
		GetInst("UIManager"):GetCtrl("MiniWorksMapTemplate"):UpdateFilterAndSort(DownArchiveType,RankFlag)
	else
		MiniWorksFrame_SetFilter(DownArchiveType, RankFlag);

		--筛选埋点
		Miniworks_UselessReport(5, DownArchiveType);
	end
	--if type ~= DownArchiveType or rank ~= RankFlag then
	--	MoreGameWatchOWLis();
	--end
end
---------------------------------------------------ArchiveInfoFrame---------------------------------------------------
Comment_Max_Num = 150;
DelCommentIdx = -1;
t_CommentList = {};	--评论列表
CurCommentTime = 0;	--评论列表里最后一条评论的时间
t_GoodCommentList = {};		--:精彩评论列表
t_ConnoisseurCommentList = {}; --鉴赏家评论列表
t_DeleteCommentHistory = {};	--删除的评论记录

--parent UserData0 uin
function CommentTemplateName_OnClick()
	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3);
		return;
	end

	local uin = this:GetParentFrame():GetClientUserData(0);
	if uin == AccountManager:getUin() then
		ShowGameTips(GetS(775), 3);
		return;
	end
	if BuddyManager:requestBuddyWatch(uin) then
		SearchWatchUin = uin;
		HideMapDetailInfo();
	end
end

--UserData0 uin;
--UserData1 commentIdx;
function CommentTemplateDel_OnClick()
	if DelCommentIdx < 0 then
		local uin = this:GetClientUserData(0);
		DelCommentIdx = this:GetClientUserData(1);
		AccountManager:requestOwCommentDel(ArchiveWorldDesc.worldid, uin);
		getglobal("LoadLoopFrame"):IsShown();
	end
end

function ArchiveInfoFrame_OnLoad()
	for i=1, Comment_Max_Num do
		local comment = getglobal("Comment"..i);
		if i == 1 then
			comment:SetPoint("top", "OwCommentBoxPlane", "top", 0, 0);
		else
			local foreIndex = i-1;
			local foreComment = getglobal("Comment"..foreIndex);
			comment:SetPoint("top", foreComment:GetName(), "bottom", 0, 0);
		end

		--local bkg1 = getglobal("Comment"..i.."Bkg1");
		--local bkg2 = getglobal("Comment"..i.."Bkg2");
		--if i % 2 == 1 then
		--	bkg1:Show();
		--	bkg2:Hide();
		--else
		--	bkg2:Show();
		--	bkg1:Hide();
		--end
	end

	this:RegisterEvent("GIE_OWCOMMENTLIST");
	this:RegisterEvent("GIE_OWCOMMENTDEL");
end

function ArchiveInfoFrame_OnEvent()
	if arg1 == "GIE_OWCOMMENTLIST" then
		if IsMapDetailInfoShown() then
			if getglobal("LoadLoopFrame"):IsShown() then
				ShowLoadLoopFrame(false)
			end

			local ge = GameEventQue:getCurEvent();
			if ge.body.gameevent.result == -2 then
				if AccountManager:getNumOwCommentList() == 0 then	--没有评论
					ShowGameTips(GetS(769), 3);
				else							--没有更多评论
					ShowGameTips(GetS(770), 3);
				end
			elseif ge.body.gameevent.result == 0 then			--拉取评论成功
				UpdateShareArchiveInfoComment(true);
			else								--失败
			--	ShowGameTips(GetS(771), 3);
			end
		end
	elseif arg1 == "GIE_OWCOMMENTDEL" then
		if IsMapDetailInfoShown() then
			if getglobal("LoadLoopFrame"):IsShown() then
				ShowLoadLoopFrame(false)
			end

			local ge 	= GameEventQue:getCurEvent();
			local result 	= ge.body.gameevent.result;
			if result == 0 then			--删除评论成功
				ShowGameTips(GetS(772), 3);
				AccountManager:delOwComment(DelCommentIdx);
				UpdateShareArchiveInfoComment(false);
			elseif result == -1 then		--网络原因
				ShowGameTips(GetS(771), 3);
			else					--删除失败
				ShowGameTips(GetS(773), 3);
			end
		end
		DelCommentIdx = -1;
	end
end

function ArchiveInfoFrame_IsTempMapAndHideNotNeed()

	local _isTempMap = false;
	if ArchiveWorldDesc and  GetInst("TempMapInterface"):CanAsTempCreate(ArchiveWorldDesc.worldid) then
		getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn"):Hide();
		getglobal("ArchiveInfoFrameIntroduceStarGameBtn"):Hide();
		_isTempMap = true;
	else
		getglobal("ArchiveInfoFrameIntroduceStarGameBtn_temp"):Hide();
		getglobal("ArchiveInfoFrameIntroduceUseTempMapBtn_temp"):Hide();
		getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_temp"):Hide();
		_isTempMap = false;
	end

	return _isTempMap;

end

function ArchiveInfoFrameIntroduceUseTempMapBtn_temp_OnClick()
	print("ArchiveInfoFrameIntroduceUseTempMapBtn_temp_OnClick");

	if ArchiveWorldDesc and ArchiveWorldDesc.worldid then
		GetInst("TempMapInterface"):statisticsUseTempBegin(2,ArchiveWorldDesc.gwid,ArchiveWorldDesc.pwid,ArchiveWorldDesc.fromowid);
	end
	
  	GetInst("TempMapInterface"):CheckAndCreateLogic(ArchiveWorldDesc.worldid);
end

function ArchiveInfoFrame_OnShow()

	if getglobal("MiniWorksFrame"):IsShown() then
		getglobal("ArchiveInfoFrame"):SetPoint("center", "MiniWorksFrame", "center", 0, 0);
		getglobal("ArchiveInfoFrameMask"):Show();
	else
		getglobal("ArchiveInfoFrame"):SetPoint("right", "LobbyFrameArchiveFrame", "left", -6, 42);
		getglobal("ArchiveInfoFrameMask"):Hide();
	end

	if ArchiveWorldDesc ~= nil then
		UpdateShareArchiveInfoIntroduce();
	else
		HideMapDetailInfo();
		return
	end

	if getglobal("MiniWorksFrame"):IsShown() then
		SetMiniWorksBoxsDealMsg(false);
	end

	if IsInIosSpecialReview() or gIsSingleGame then
		getglobal("ArchiveInfoFrameIntroduceStarGameBtn"):SetPoint("bottom", "ArchiveInfoFrame", "bottom", 0, -20);
		getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn"):Hide();

		if ArchiveInfoFrame_IsTempMapAndHideNotNeed() then
			getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_temp"):Hide();
		end
	end

	if not getglobal("MiniWorksFrame"):IsShown() then
		--材质包
		if  getglobal("PlayerCenterFrame"):IsShown() then
			getglobal("ArchiveInfoFrameEditMaterialBtn"):Hide();
			getglobal("ArchiveInfoFrameIntroduceStarGameBtn"):Hide();
			getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn"):Hide();

			getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_temp"):Hide();
			getglobal("ArchiveInfoFrameIntroduceUseTempMapBtn_temp"):Hide();
			getglobal("ArchiveInfoFrameIntroduceStarGameBtn_temp"):Hide();
		
		else
			getglobal("ArchiveInfoFrameEditMaterialBtn"):Show();
		end

		if not AccountManager:getNoviceGuideState("guidematmod") then
			getglobal("ArchiveInfoFrameEditMaterialBtnGuide"):Show();
		else
			getglobal("ArchiveInfoFrameEditMaterialBtnGuide"):Hide();
		end

		--插件
		if AccountManager:canEditMod(ArchiveWorldDesc.worldid) and getglobal("ExhibitionMapFrame"):IsShown()==false and if_map_plugin_entrance() then
			getglobal("ArchiveInfoFrameEditModBtn"):Show();
		else
			getglobal("ArchiveInfoFrameEditModBtn"):Hide();
		end
	else
		getglobal("ArchiveInfoFrameEditMaterialBtn"):Hide();
		getglobal("ArchiveInfoFrameEditModBtn"):Hide();
	end

	if IsInIosSpecialReview() then
		getglobal("ArchiveInfoFrameEditMaterialBtn"):Hide();
		getglobal("ArchiveInfoFrameEditMaterialBtnGuide"):Hide();
		getglobal("ArchiveInfoFrameEditModBtn"):Hide();
	end

	if ArchiveWorldDesc.worldtype == 9 then
		getglobal("ArchiveInfoFrameEditMaterialBtn"):Hide();
		getglobal("ArchiveInfoFrameEditModBtn"):Hide();
	end

	if gIsSingleGame then
		getglobal("ArchiveInfoFrameCommentBtn"):Hide()
		getglobal("ArchiveInfoFrameEditMaterialBtn"):Hide()
		ClientMgr:setPause(false)
	end
end

function ArchiveInfoFrameEditMaterialBtnGuide_OnShow()
	getglobal("ArchiveInfoFrameEditMaterialBtnGuideEffect"):SetUVAnimation(100, true);
end

function ArchiveInfoFrameEditMaterialBtnGuide_OnClick()
	AccountManager:setNoviceGuideState("guidematmod", true);
	getglobal("ArchiveInfoFrameEditMaterialBtnGuide"):Hide();
end

function ArchiveInfoFrame_OnHide()
	getglobal("ArchiveInfoFrameMask"):Hide();

	CurArchiveMap = nil;
	CurArchiveMapOptions = {};

	if getglobal("MiniWorksFrame"):IsShown() then
		SetMiniWorksBoxsDealMsg(true);
	end
end

-- 新增一键清空存档功能
function ClearAllBtn_OnClick()
	local callback = function(flag, data)
		if flag == "left" then--确认
			local worldList = AccountManager:getMyWorldList()

			while true do
				local worldNum = worldList:getNumWorld()
				if worldNum < 0 then return end

				local worldInfo = worldList:getWorldDesc(worldNum-1);
				if not worldInfo then return end

				local worldId = worldInfo.worldid;
				AccountManager:requestDeleteWorld(worldId);
			end
		end
	end
	titles = "确认要清空全部存档数据？\n(若存档数据比较大，可能需花费较长的时间，请耐心等待。。)"
	MessageBox(5, titles, callback, nil)
end

function MyModsBtn_OnClick()
	--CustomModelMgr:loadResCustomModel();

	FrameStack.reset("LobbyFrame");
	local args = {
		editmode = 2,
		uuid = ModMgr:getUserDefaultModUUID(),
		isMapMod = false,
	};
	if UseNewModsLib then
        args.isnew = true
        args.enterType = 1
        FrameStack.enterNewFrame("ModsLib", args)
    else
		FrameStack.enterNewFrame("MyModsEditorFrame", args);
    end

	--td统计
	-- statisticsGameEvent(501);

	StatisticsTools:gameEvent("ModEvent", "点击插件库按钮");

	if not AccountManager:getNoviceGuideState("guidemods") then
		AccountManager:setNoviceGuideState("guidemods", true);
	end
end

function MyModsBtnGuide_OnClick()
	AccountManager:setNoviceGuideState("guidemods", true);
	getglobal("LobbyFrameArchiveFrameMyModsBtnGuide"):Hide();
end

function ArchiveInfoFrameMask_OnClick()
	HideMapDetailInfo();
end

function ArchiveInfoFrameCloseBtn_OnClick()
	HideMapDetailInfo();
end

function ArchiveInfoFrameIntroduceBtn_OnClick()
	if getglobal("ArchiveInfoFrameIntroduce"):IsShown() then return end

	if getglobal("ExhibitionMapFrame"):IsShown() then
		PEC_MapFrameCell_OnClick(t_exhibitionMap.curSelectMapIndex); --个人中心显示，需要走个人中心的判断逻辑
	else
		UpdateShareArchiveInfoIntroduce();
	end

end

local StartGameMatModUuid = nil;

--开始编辑录像
function ArchiveInfoFrameIntroduceRecordEditBtn_OnClick()
	if SelectArchiveIndex < 0 then
		--提示选择存档
		ShowGameTips(GetS(13), 3);
		return;
	end

	local archiveData = GetOneArchiveData(SelectArchiveIndex);
	if archiveData == nil then return end
	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)
	if worldInfo.openpushtype >= 4 then
		ShowGameTips(GetS(15), 3);
		return;
	end

	if worldInfo.openpushtype == 3 and IsNewbieWorld(worldInfo.worldid) == false then	--没有数据
		if worldInfo.open == 0 then	--提示删除存档
			local text = GetS(159);
			MessageBox(4, text);
			getglobal("MessageBoxFrame"):SetClientString( "切换帐号未分享地图" );
			return;
		elseif worldInfo.open > 0 then
			local text = GetS(160);
			MessageBox(5, text);
			getglobal("MessageBoxFrame"):SetClientUserData(0, SelectArchiveIndex);
			getglobal("MessageBoxFrame"):SetClientString( "切换帐号分享下载地图" );
			return;
		end
	end

	if worldInfo.realowneruin == AccountManager:getUin() then
		RequestEnterWorld(worldInfo.worldid, false, function(succeed)
			if succeed then
				RecordPkgMgr:setEdit(true)
				ShowLoadingFrame();
				--数据埋点 进入录像编辑
				HideLobby();
			end
		end);
	else
		ReqSearchMapsByUin(worldInfo.downloaduin);
		-- getglobal("MiniLobbyFrame"):Hide();
		HideMiniLobby() --mark by hfb for new minilobby
		HideLobby();
		getglobal("MiniWorksFrame"):Show();
		MiniworksGotoLabel(6);
	end
	-- statisticsGameEvent(40002, "%lld", worldInfo.worldid);  --编辑录像埋点
end

--开始播放录像
function ArchiveInfoFrameIntroduceRecordPlayBtn_OnClick()
	if SelectArchiveIndex < 0 then
		--提示选择存档
		ShowGameTips(GetS(13), 3);
		return;
	end

	local archiveData = GetOneArchiveData(SelectArchiveIndex);
	if archiveData == nil then return end
	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)
	if worldInfo.openpushtype >= 4 then
		ShowGameTips(GetS(15), 3);
		return;
	end

	if worldInfo.openpushtype == 3 and IsNewbieWorld(worldInfo.worldid) == false then	--没有数据
		if worldInfo.open == 0 then	--提示删除存档
			local text = GetS(159);
			MessageBox(4, text);
			getglobal("MessageBoxFrame"):SetClientString( "切换帐号未分享地图" );
			return;
		elseif worldInfo.open > 0 then
			local text = GetS(160);
			MessageBox(5, text);
			getglobal("MessageBoxFrame"):SetClientUserData(0, SelectArchiveIndex);
			getglobal("MessageBoxFrame"):SetClientString( "切换帐号分享下载地图" );
			return;
		end
	end

	RequestEnterWorld(worldInfo.worldid, false, function(succeed)
		if succeed then
			RecordPkgMgr:setEdit(false)
			ShowLoadingFrame();
			HideLobby();
		end
	end);
end

--开始单机游戏
function ArchiveInfoFrameIntroduceStarGameBtn_OnClick()
	print("ArchiveInfoFrameIntroduceStarGameBtn_OnClick")
	if CreateMapGuideStep == 4 then
		CreateMapGuideStep = CreateMapGuideStep + 1
	end
	--清理一下avatar头像信息
	UIActorBodyManager:releaseAvatarIcon()
	-- 新个人中心地图频道单机游戏按钮点击逻辑
	if getglobal("ExhibitionMapFrame"):IsShown() then
		local map = t_exhibitionMap.getCurSelectMap();
		local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(map.owid);
		if mapIsBreakLaw == 1 then
			ShowGameTips(GetS(10561), 3);
			return;
		elseif mapIsBreakLaw == 2 then
			ShowGameTips(GetS(3632), 3);
			return;
		end

		if map then
			if HandleGmMapCommands(map) then  --处理gm命令
				return;
			end

			if EnterDownloadedMap(map) then
				UIFrameMgr:hideAllFrame();
				ShowLoadingFrame();
			end
		end
		return;
	end

	TamedAnimal_RequestReview = -1;
	if AccountManager:getMyWorldList():getNumWorld() == 0 then
		--没有存档，去创建存档
		LobbyFrameCreateNewWorldBtn_OnClick();
		return;
	end
	local worldInfo = nil
	if isEnableNewLobby and isEnableNewLobby() then
		local worldid = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
		worldInfo = AccountManager:findWorldDesc(worldid)
	else
		if SelectArchiveIndex == -1 then
			--提示选择存档
			ShowGameTips(GetS(13), 3);
			return;
		end

		if SelectArchiveIndex == ShareingMapIndex and ClientMgr:isSharingOWorld() then
			--正在分享，提示分享完成才能进入
			ShowGameTips(GetS(14), 3);
			return;
		end

		local archiveData = GetOneArchiveData(SelectArchiveIndex);--获得选择的自己的存档idx
		if archiveData == nil then return end
		worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)--获取自己存档地图数据
	end
	if not worldInfo then
		--提示选择存档
		ShowGameTips(GetS(13), 3);
		return;
	end

	if worldInfo.openpushtype >= 4 then
		ShowGameTips(GetS(15), 3);
		return;
	end

	local checkwid = worldInfo.fromowid;
	if checkwid == 0 then
		checkwid = worldInfo.worldid;
	end
	standReportEvent("32", "MINI_OLDGAMEOPEN_GAME_1", "SinglePlayer", "click",{cid=tostring(checkwid)})
	local standby1 = ""
	local mapOwn
	-- 是自己图
	if worldInfo.realowneruin == AccountManager:getUin() then
		standby1 = "1"
		mapOwn = GetInst("ReportGameDataManager"):GetGameMapOwnDefine().myMap
	else
		standby1 = "2"
		mapOwn = GetInst("ReportGameDataManager"):GetGameMapOwnDefine().otherMap
	end
	standby1 = standby1.."1"
	-- local gameLabel = worldInfo.gameLabel
	-- if gameLabel == 0 then
	-- 	gameLabel = GetLabel2Owtype(worldInfo.worldtype)
	-- end
	-- -- 冒险模式
	-- if gameLabel == 2 then
	-- 	standby1 = standby1.."1"
	-- -- 创造模式
	-- elseif gameLabel == 3 then
	-- 	standby1 = standby1.."2"
	-- -- 开发者模式
	-- else
	-- 	standby1 = standby1.."3"
	-- end
	standby1 = standby1 .. tostring(worldInfo.worldtype)
	-- game_open上报
	standReportGameOpenParam = {
		standby1    = standby1,
		sceneid     = "32",
		cardid		= "MINI_OLDGAMEOPEN_GAME_1",
		compid		= "SinglePlayer"
	}

	
	GetInst("ReportGameDataManager"):NewGameLoadParam("32","MINI_OLDGAMEOPEN_GAME_1","SinglePlayer")
	GetInst("ReportGameDataManager"):SetGameMapOwn(mapOwn)
	GetInst("ReportGameDataManager"):SetGameNetType(GetInst("ReportGameDataManager"):GetGameNetTypeDefine().singleMode)
	GetInst("ReportGameDataManager"):SetGameMapMode(worldInfo.worldtype)


	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(checkwid);
	if mapIsBreakLaw == 1 then
		ShowGameTips(GetS(10561), 3);
		return;
	elseif mapIsBreakLaw == 2 then
		ShowGameTips(GetS(3632), 3);
		return;
	end

	if worldInfo.OpenSvr == 4 or worldInfo.OpenSvr == 14 then
		ShowGameTips(GetS(3632), 3);
		return;
	end

	if worldInfo.openpushtype == 3 and IsNewbieWorld(worldInfo.worldid) == false then	--没有数据
		if worldInfo.open == 0 then	--提示删除存档
			local text = GetS(159);
			if IsStandAloneMode("") then
				text = GetS(15)
			end
			MessageBox(4, text);
			getglobal("MessageBoxFrame"):SetClientString( "切换帐号未分享地图" );
			return;
		elseif worldInfo.open > 0 then
			local text = GetS(160);
			MessageBox(5, text);
			getglobal("MessageBoxFrame"):SetClientUserData(0, SelectArchiveIndex);
			getglobal("MessageBoxFrame"):SetClientString( "切换帐号分享下载地图" );
			return;
		end
	end

	if CheckPassPortInfo(worldInfo) ~= 0 then return end

	local function RequestEnterWorld_callback()
		RequestEnterWorld(worldInfo.worldid, false, function(succeed)
			if succeed then
				EnterWorld_ExtraSet("", 1)
				HideLobby();
				ShowLoadingFrame();
				ns_ma.ma_play_map_set_enter( { where="single"} )

				if worldInfo.realowneruin > 1 and worldInfo.owneruin ~= worldInfo.realowneruin then --下载的地图
					-- statisticsGameEvent(8007,"%d",worldInfo.worldType);
					-- statisticsGameEvent(8008,"%d",worldInfo.gameLabel);	
					if AccountManager:findWorldDesc(worldInfo.worldid) then
						if worldInfo.translate_supportlang > math.pow(2,worldInfo.translate_sourcelang) then
							-- statisticsGameEvent(62002,"%s",tostring(worldInfo.translate_currentlang),"%s",tostring(worldInfo.worldid),"%s",tostring(worldInfo.fromowid))
						end
					end
				else                                                                           --自己创建的地图
					-- statisticsGameEvent(8006,"%d",worldInfo.worldType);
				end
			end
		end);
	end


	--判断是否提醒玩家分享地图
	if  ns_LongTimeShareMap.warning( worldInfo.worldid ) then
		Log("self map LongTimeShareMap need warning ")
		MessageBox( 21, GetS(9139), function(btn)
			if btn == 'left' then
				Log("press left")  --直接开始
				RequestEnterWorld_callback();
			else
				Log("press right")   --前往分享

				local archiveData = GetOneArchiveData(SelectArchiveIndex);
				if archiveData == nil then return end
				local worldDesc = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
				if ClientMgr:getVersionParamInt("ShareExsitMod", 1) ~= 1 and worldDesc ~= nil and AccountManager:isExistMod(worldDesc.worldid) then
					ShowGameTips(GetS(3809), 3);
					return;
				end
				getglobal("ShareArchiveInfoFrame"):SetClientUserData(0, SelectArchiveIndex);
				getglobal("ShareArchiveInfoFrame"):SetClientUserData(1, 2);
				getglobal("ShareArchiveInfoFrame"):Show();

			end
		end );
	else
		RequestEnterWorld_callback();
	end

end

--提醒曾经备份的玩家 上传该地图
ns_LongTimeShareMap = {}


--设置有备份操作
ns_LongTimeShareMap.set_backup_time = function( worldInfo )
	--通过备份操作触发行为
	if  worldInfo.realowneruin >= 1000 and worldInfo.owneruin == worldInfo.realowneruin then
		local history_ =  getkv("play_history", "self_map_play") or {}
		history_[ worldInfo.worldid ] = history_[ worldInfo.worldid ] or {};
		history_[ worldInfo.worldid ].backup_time = getServerNow()
		setkv("play_history", history_, "self_map_play" )
	end
end


-- 判断是否需要提醒文件share地图
ns_LongTimeShareMap.warning = function( worldid_id )
	local history_ = getkv("play_history", "self_map_play") or {}

	-- 玩家如果备份过地图，且地图时间玩的时间超过10天
	if  history_[ worldid_id ] and history_[ worldid_id ].backup_time and history_[ worldid_id ].play_time and  history_[ worldid_id ].play_time >= 30*60 then
		if  history_[ worldid_id ].backup_time then
			history_[ worldid_id ] = nil   --已经提醒，取消备份时间
			setkv("play_history", history_, "self_map_play" )
			return true
		end
	end
	return false
end


--设置游戏总玩的时间
ns_LongTimeShareMap.set_play_time = function( worldid_id )
	local history_ =  getkv("play_history", "self_map_play") or {}
	if  history_[ worldid_id ] and history_[ worldid_id ].backup_time then
		local play_time_ = 0
		if  WorldMgr and WorldMgr.getWorldTime then
			play_time_ = WorldMgr:getWorldTime() + 30*60*20  --增加30分钟预留时间
		else
			play_time_ = 30*60*20   --30分钟预留时间
		end

		if  play_time_ >= 30*60*20 then
			history_[ worldid_id ].play_time = math.floor(play_time_ * 0.05)  --1秒=20tick
			setkv("play_history", history_, "self_map_play" )
		end
	end
end



function RequestEnterWorld(worldid, isMultiplayer, callback, userdata)
	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(worldid);
	if mapIsBreakLaw == 1 then
		ShowGameTips(GetS(10561), 3);
		return;
	elseif mapIsBreakLaw == 2 then
		ShowGameTips(GetS(3632), 3);
		return;
	end
	local teamupSer = GetInst("TeamupService")
	if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
        ShowGameTips(GetS(26045))
        return
    end

	isMultiplayer = isMultiplayer or false;
	Log('RequestEnterWorld worldid='..worldid..' isMultiplayer='..tostring(isMultiplayer));

	local matmodUuid = nil;

	--是否有材质包
	local loadmodflags = LuaInterface:band(LMF_Default, LuaInterface:bnot(LMF_ParseComponents));
	--print("jjjjj",loadmodflags)
	ModMgr:loadWorldMods(worldid, loadmodflags);
	for i = 0, ModMgr:getMapModCount() - 1 do
		local moddesc = ModMgr:getMapModDescByIndex(i);
		if moddesc.modtype == 1 then
			matmodUuid = moddesc.uuid;
		end
	end
	ModMgr:unLoadCurMods(worldid, false);

	local tmpdata = {
		worldid = worldid,
		isMultiplayer = isMultiplayer,
		matmodUuid = matmodUuid,
		callback = callback,
		userdata = userdata,
	};

	if matmodUuid then
		--检查材质包是否解锁
		if isEducationalVersion then
			if not ifNetworkStateOK() then
				OnRespGetMatModState(true, tmpdata);
			else
				ReqGetMaterialModUnlocked(matmodUuid, OnRespGetMatModState, tmpdata);
			end
			return;
		end

		if IsStandAloneMode("") then
			-- 如果单机模式，不能使用材质包
			OnRespGetMatModState(false, tmpdata);
		else
			ReqGetMaterialModUnlocked(matmodUuid, OnRespGetMatModState, tmpdata);
		end
	else
		OnRespGetMatModState(true, tmpdata);
	end
end

function OnRespGetMatModState(unlocked, tmpdata)
	Log("OnRespGetMatModState unlocked="..tostring(unlocked));

	local worldid = tmpdata.worldid;
	local isMultiplayer = tmpdata.isMultiplayer;
	print("OnRespGetMatModState==1", worldid)
	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(worldid);
	if mapIsBreakLaw == 1 then
		ShowGameTips(GetS(10561), 3);
		return;
	elseif mapIsBreakLaw == 2 then
		ShowGameTips(GetS(3632), 3);
		return;
	end

	ModMgr:clearDisableWorldMods();

	--if not unlocked then  --材质包未解锁
	--	ShowGameTips(GetS(4782), 3);
	--	ModMgr:setDisableWorldMod(tmpdata.matmodUuid, true);
	--end
		
	if AccountManager:requestEnterWorld(worldid, isMultiplayer) then
		if tmpdata.callback then
			tmpdata.callback(true, tmpdata.userdata);
		end
		local worldtype = CSMgr:getWorldType(worldid);
		if worldtype == 0 then
			StatisticsTools:gameEvent("EnterSurviveWNum");
		elseif worldtype == 1 or worldtype == 3 then
			StatisticsTools:gameEvent("EnterCreateWNum");
		elseif worldtype == 2 then
			StatisticsTools:gameEvent("EnterExtremityWNum");
		elseif worldtype == 4 then
			StatisticsTools:gameEvent("EnterGameMakerWNum");
		end
	else
		if tmpdata.callback then
			tmpdata.callback(false, tmpdata.userdata);
		end
	end
end

function ArchiveInfoFrameIntroduceStarOnlineBtn_OnShow()
	if IsArchiveMapCollaborationMode() then
		getglobal("ArchiveInfoFrameIntroduceStarOnlineBtnName"):SetText(GetS(25825))
	else
		getglobal("ArchiveInfoFrameIntroduceStarOnlineBtnName"):SetText(GetS(3768))
	end
end

function ArchiveInfoFrameIntroduceStarOnlineBtn_temp_OnShow()
	if IsArchiveMapCollaborationMode() then
		getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_tempName"):SetText(GetS(25825))
	else
		getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_tempName"):SetText(GetS(3768))
	end
end

--快速联机
function ArchiveInfoFrameIntroduceStarOnlineBtn_OnClick()
	if IsStandAloneMode() then return end

	if IsArchiveMapCollaborationMode() then
		if CollaborationModeIllegalReportTime and AccountManager:getSvrTime() < CollaborationModeIllegalReportTime then
			ShowGameTipsWithoutFilter(GetS(25824, os.date("%Y-%m-%d %H:%M", CollaborationModeIllegalReportTime)), 3)
			return
		end

		if ns_data.IsGameFunctionProhibited("cr", 25824, 25824) then
			return
		end

		local worldDesc = AccountManager:findWorldDesc(gCreateRoomWorldID)
		if worldDesc == nil then
			return
		end
		local checkwid = worldDesc.fromowid;
		if checkwid == 0 then
			checkwid = worldDesc.worldid;
		end
		standReportEvent("32", "MINI_OLDGAMEOPEN_GAME_1", "FriendsPlay", "click",{cid=tostring(checkwid)})
		local standby1 = ""
		-- 是自己图
		local mapOwn
		if worldDesc.realowneruin == AccountManager:getUin() then
			standby1 = "1"
			mapOwn = GetInst("ReportGameDataManager"):GetGameMapOwnDefine().myMap
		else
			standby1 = "2"
			mapOwn = GetInst("ReportGameDataManager"):GetGameMapOwnDefine().otherMap
		end
		standby1 = standby1.."3"
		-- local gameLabel = worldDesc.gameLabel
		-- if gameLabel == 0 then
		-- 	gameLabel = GetLabel2Owtype(worldDesc.worldtype)
		-- end
		-- -- 冒险模式
		-- if gameLabel == 2 then
		-- 	standby1 = standby1.."1"
		-- -- 创造模式
		-- elseif gameLabel == 3 then
		-- 	standby1 = standby1.."2"
		-- -- 开发者模式
		-- else
		-- 	standby1 = standby1.."3"
		-- end
		standby1 = standby1 .. tostring(worldDesc.worldtype)
		-- game_open上报
		standReportGameOpenParam = {
			standby1    = standby1,
			sceneid     = "32",
			cardid		= "MINI_OLDGAMEOPEN_GAME_1",
			compid		= "FriendsPlay"
		}
		GetInst("ReportGameDataManager"):NewGameLoadParam("32","MINI_OLDGAMEOPEN_GAME_1","FriendsPlay")
		GetInst("ReportGameDataManager"):SetGameNetType(GetInst("ReportGameDataManager"):GetGameNetTypeDefine().friendOnlineMode)
		GetInst("ReportGameDataManager"):SetGameMapOwn(mapOwn)
		GetInst("ReportGameDataManager"):SetGameMapMode(worldDesc.worldtype)

		if worldDesc.openpushtype == 3 and IsNewbieWorld(gCreateRoomWorldID) == false then	--协作模式如果发现地图已上传但是本地没有，需要从服务器下载
			if worldDesc.open == 0 then
				local text = GetS(159)
				MessageBox(4, text)
				getglobal("MessageBoxFrame"):SetClientString( "切换帐号未分享地图" )
				return
			end

			local text = GetS(160)
			MessageBox(5, text)
			getglobal("MessageBoxFrame"):SetClientUserData(0, SelectArchiveIndex)
			getglobal("MessageBoxFrame"):SetClientString( "切换帐号分享下载地图" )
			return
		end

		if worldDesc.openpushtype >= 4 then
			ShowGameTips(GetS(15), 3)
			return
		end

		if getglobal("PlayerExhibitionCenter"):IsShown() then
			PEC_SetJumpToFrameName("RoomFrame")
		end

		-- FastOnlineWID = gCreateRoomWorldID;

		local callback = function(flag, data)
			if flag == "right" then--确认
				if getglobal("LoadLoopFrame"):IsShown() then
					return;
				end
				if AccountManager:loginRoomServer(false) then
					ShowLoadLoopFrame(true, "file:lobby -- func:ArchiveInfoFrameIntroduceStarOnlineBtn_OnClick")
					IsLanRoom = false
					IsCreatingColloborationModeRoom = true
					OpenRoom(worldDesc.worldid)
				else
					--ShowGameTips(GetS(506), 3)
				end
			end
		end

		MessageBox(31, GetS(25821), callback, nil)
	else
		if ns_data.IsGameFunctionProhibited("r", 10572, 10592) then
			return
		end
		local checkwid = ArchiveWorldDesc.fromowid;
		if checkwid == 0 then
			checkwid = ArchiveWorldDesc.worldid;
		end
		standReportEvent("32", "MINI_OLDGAMEOPEN_GAME_1", "MultiplePlayer", "click",{cid=tostring(checkwid)})
		ArchiveInfoFrameTopFasterEnterOWBtn_OnClick(false, checkwid)
	end
end

--收藏/取消收藏
function ArchiveInfoFrameIntroduceCollectBtn_OnClick()
	local cid = CurArchiveMap and CurArchiveMap.owid and tostring(CurArchiveMap.owid) or 0
	MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "MapCollect", "click", {cid = cid}) --mark by liya 新埋点
	
	if ( getglobal("MiniWorksFrame"):IsShown() or getglobal("MiniWorksArchiveInfoFrame"):IsShown() ) and CurArchiveMap then
		if IsMapCollected(CurArchiveMap.owid) then
			ReqRemoveCollectMap(CurArchiveMap);
		else
			ReqAddCollectMap(CurArchiveMap);
		end
	end

	if getglobal("ExhibitionMapFrame"):IsShown()  and CurArchiveMap then  --个人中心显示的逻辑
		if IsMapCollected(CurArchiveMap.owid) then
			if t_exhibition.isHost then
				t_exhibitionMap.cancelCollect();
			end
			ReqRemoveCollectMap(CurArchiveMap);
			HideMapDetailInfo();
		else
			ReqAddCollectMap(CurArchiveMap);
			HideMapDetailInfo();
		end
    end
end

--查看代码  
function ArchiveInfoFrameIntroduceCodeBtn_OnClick()
	 
	 local state = GetMapDownloadBtnState(CurArchiveMap);	 
		if state.buttontype == DOWNBTN_DOWNLOAD then --未下载
			MiniWorksArchiveInfoFrameTopFuncBtn_OnClick();
			ShowGameTips("需要先下载地图", 3);
		elseif state.buttontype == DOWNBTN_ENTERWORLD then --下载完
			local param = {}	  
			local indsa = AccountManager:getMyWorldList():getNumWorld()
			for i = 0, AccountManager:getMyWorldList():getNumWorld() - 1 do
                local wdesc = AccountManager:getMyWorldList():getWorldDesc(i);
                if wdesc == nil then return end
					if (wdesc.worldid == CurArchiveMap.owid or wdesc.fromowid == CurArchiveMap.owid) then
                             param.owid = wdesc.worldid
			        end
		     end			
			GetInst("UIManager"):Open("DeveloperEditScriptItem",param)
		else                                        --下载中断或下载中
			ShowGameTips("需要先下载地图", 3);
    	end
  
end

--查看模板信息 
function ArchiveInfoFrameIntroduceTraceBtn_OnClick()
	 
	print("ArchiveInfoFrameIntroduceTraceBtn_OnClick");
  	GetInst("UIManager"):Open("TempMapTrace",{map = CurArchiveMap});

end

-- g_IsMiniWorksOneKeyEnterRoom = false;
g_MiniWorksOneKeyEnterRoomState = 0;	--0:无 1:请求房间 2:进入房间

function SetMiniWorksOneKeyEnterRoomState(nState)
	g_MiniWorksOneKeyEnterRoomState = nState;
end

function GetMiniWorksOneKeyEnterRoomState()
	return g_MiniWorksOneKeyEnterRoomState;
end

--不显示联机大厅但等同于先进入联机大厅再点击快速进入,参照ArchiveInfoFrameTopFilterRoomOWBtn_OnClick
function ArchiveInfoFrameTopFasterEnterOWBtn_OnClick(isClick, owid, failedCallBack, succeedCallBack)
    local checker_uin = AccountManager:getUin()
	if IsUserOuterChecker(checker_uin) and not DeveloperAdCheckerUser(checker_uin) then
		ShowGameTips(GetS(100300), 3)
        return nil;
	end
	-- if not IsRoomFrameShown() then
	if getglobal("MiniWorksFrame"):IsShown() then
		WorksArchiveMsgCheck.isWorksInto = true;
		if HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
			WorksArchiveMsgCheck.isdetail = true
			WorksArchiveMsgCheck.CommendType = GetInst("UIManager"):GetCtrl("MiniWorksCommendDetail"):GetCommendType()
		else
			WorksArchiveMsgCheck.isdetail = false
		end
	end
	
	local playerArchive = getglobal("PlayerArchiveSlots");
 	if playerArchive and playerArchive:IsShown() then
		GetInst("UIManager"):Close("PlayerArchiveSlots");
	end

	if ClientCurGame:isInGame() then
		ShowGameTips(GetS(1330), 3);
		return;
	end

	if owid then
		WorksArchiveMsgCheck.isWorksInto = false;			
		local rptTemp = RoomFrame_GetQuickMatchReportInfo() or {}
		local ex = {
			mapwid = owid,
			filterMapwid = 0,
			filterHostId = 0,
			reportGameJoinParam = rptTemp,
			useAiAPI = true,
			loadingType = 1,
			callback = function(success, failedCode)
				if not success then
					if "function" == type(failedCallBack) then
						failedCallBack(owid)
					else
						local tips = GetS(26000)
						if failedCode then
							--tips = string.format("%s(%s)", GetS(26000) or "", tostring(failedCode))
							local str_tips = GetInst("RoomService"):GetErrorCodeTip(failedCode)
							tips = string.format("%s(%s)", str_tips or "", tostring(failedCode))
						end
						ShowOneKeyFailedByMapID(owid, tips, failedCode)
					end
				else
					if succeedCallBack then
						succeedCallBack()
					end
				end
			end
		}
		
		threadpool:work(function ()
			GetInst("RoomService"):AsynReqMapPlayerCount({owid})
			GetInst("UIManager"):Open("RoomMatch", ex)
		end)
		
		-- if G_CheckABTestSwitchOfAllCloud() then
		-- 	ex.forceQuickUpCSRoom = true
		-- end
		
	end	

	--if getglobal("PlayerCenterFrame"):IsShown() then
	--	getglobal("PlayerCenterFrame"):Hide();
	--end

	--if getglobal("PlayerExhibitionCenter"):IsShown() then
	--	getglobal("PlayerExhibitionCenter"):Hide();
	--end

	if getglobal("ComeBackEntrance"):IsShown() then --记录这个是回流触发的联机
		mComeBackInlineState = 1
	end
	
	if getglobal("MiniWorksTopicDetail"):IsShown() then
		GetInst("UIManager"):Close("MiniWorksTopicDetail")
	end
	-- if getglobal("ArchiveInfoFrameEx"):IsShown() then
	-- 	GetInst("UIManager"):Close("ArchiveInfoFrameEx")
	-- end

	--HideLobby()
end
--筛选出此地图的房间
function ArchiveInfoFrameTopFilterRoomOWBtn_OnClick(isClick, appendReportInfo)
	-- if not IsRoomFrameShown() then
	if getglobal("MiniWorksFrame"):IsShown() then
		WorksArchiveMsgCheck.isWorksInto = true;
		if HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
			WorksArchiveMsgCheck.isdetail = true
			WorksArchiveMsgCheck.CommendType = GetInst("UIManager"):GetCtrl("MiniWorksCommendDetail"):GetCommendType()
		else
			WorksArchiveMsgCheck.isdetail = false
		end
	end
	
	local playerArchive = getglobal("PlayerArchiveSlots");
	if playerArchive and playerArchive:IsShown() then
		GetInst("UIManager"):Close("PlayerArchiveSlots");
	end

	if ClientCurGame:isInGame() then
		ShowGameTips(GetS(1330), 3);
		return;
	end

	if CurArchiveMap then
		WorksArchiveMsgCheck.isWorksInto = false;
		GetInst("UIManager"):Open("MapRoom", {mapInfo = CurArchiveMap, AppendReportInfo = appendReportInfo})
		if getglobal("ArchiveInfoFrameEx"):IsShown() then
			GetInst("UIManager"):Close("ArchiveInfoFrameEx")
		end
	end

	--if getglobal("PlayerCenterFrame"):IsShown() then
	--	getglobal("PlayerCenterFrame"):Hide();
	--end

	--if getglobal("PlayerExhibitionCenter"):IsShown() then
	--	getglobal("PlayerExhibitionCenter"):Hide();
	--end

	if getglobal("ComeBackEntrance"):IsShown() then --记录这个是回流触发的联机
		mComeBackInlineState = 1
	end


	--HideLobby()

    -- EnterMainMenuInfo.EnterMainMenuBy = "FromMiniWorksStartMulitRoom"
end

--地图功能按钮：下载/暂停/进入
function ArchiveInfoFrameIntroduceMiniworksFuncBtn_OnClick()
	if (getglobal("MiniWorksFrame"):IsShown() or  getglobal("ExhibitionMapFrame"):IsShown() ) and CurArchiveMap then
		local funcBtnUi = getglobal("ArchiveInfoFrameIntroduceMiniworksFuncBtn");
		MapFuncBtn_OnClick(funcBtnUi, CurArchiveMap, CurArchiveMapOptions);
	end
end

function ArchiveInfoFrameCommentBtn_OnClick()
	if IsStandAloneMode() then return end

	if (ArchiveWorldDesc.open ~= 1 and ArchiveWorldDesc.open ~= 2) and ArchiveWorldDesc.realowneruin == ArchiveWorldDesc.owneruin then
		ShowGameTips(GetS(766), 3);
		return;
	end

	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(ArchiveWorldDesc.fromowid);
	if mapIsBreakLaw == 1 then
		ShowGameTips(GetS(10565), 3);
		return;
	elseif mapIsBreakLaw == 2 then
		ShowGameTips(GetS(3636), 3);
		return;
	end

	if getglobal("ArchiveInfoFrameComment"):IsShown() then return end

	local owid = 0;
	if ArchiveWorldDesc.realowneruin == ArchiveWorldDesc.owneruin then
		owid = ArchiveWorldDesc.worldid;
	else
		owid = ArchiveWorldDesc.fromowid;
	end

	t_CommentList = {};
	CurCommentTime = 0;

	local rank = 0;
	local uin = 0;

	if getglobal("MiniWorksArchiveInfoFrame"):IsShown() and CurArchiveMap then
		rank = CurArchiveMap.rank;
		uin = CurArchiveConnoisseurUin;
	end

	RequestOwCommentList(owid, rank, uin);
end

--申诉
function ArchiveInfoFrameAppealBtn_OnClick()
	-- 不能申诉
	if gIsSingleGame then return end

	local worldid = 0
	if isEnableNewLobby and isEnableNewLobby() then
		worldid = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
	else
		worldid = ArchiveWorldDesc.worldid
	end

	local uin = AccountManager:getUin()
	if mapservice.mapAppealList[worldid] and mapservice.mapAppealList[worldid].appeal and mapservice.mapAppealList[worldid].appeal.stat then
		if mapservice.mapAppealList[worldid].appeal.stat == 0 then
			ReqMapAppealQuery(uin, worldid, function ( stat )
				if stat then
					if stat ~= mapservice.mapAppealList[worldid].appeal.stat then
						mapservice.mapAppealList[worldid].appeal.stat = stat
						UpdateShareArchiveInfoIntroduce()
					end
					local strTips = ""
					if stat == 0 then
						strTips = GetS(10622)
						if IsOverseasVer() or isAbroadEvn() then
							strTips = GetS(10634)
						end
						ShowGameTips(strTips, 3)
					elseif stat == 1 then
					elseif stat == 2 then
						strTips = GetS(10623)
						if IsOverseasVer() or isAbroadEvn() then
							strTips = GetS(10635)
						end
						MessageBox(4, strTips)
					end
				end
			end)
		end
		return
	end
	-- 海外版本，直接填理由申诉
	if IsOverseasVer() or isAbroadEvn() then
		ReqArchiveAppeal(false,worldid)
		return
	end

	-- local sconfig = nil
	-- if AccountManager.get_antiaddiction_def then
	-- 	sconfig = AccountManager:get_antiaddiction_def()
	-- end
	-- --Auth:实名认证(开1,关0,默认0)
	-- if sconfig and type(sconfig)=="table" and sconfig.Auth > 0 then
		--需要实名认证的渠道
		-- 先忽略开关配置，申诉这里，只有没有通过迷你世界的实名认证，都要先实名认证，然后再填申诉理由
		local idcard_info = AccountManager:idcard_info()
		if idcard_info then
			-- 认证通过了
			if AccountManager:realname_state() == 1 then
		    	ReqArchiveAppeal(false,worldid)
		    	return
		    end
		end
		-- ReqArchiveAppeal(true,worldid)
		ShowGameTips(GetS(100265), 3)
		local adsType = RealNameFunc and RealNameFunc.isShowIdentityNameAuth and RealNameFunc:isShowIdentityNameAuth(8)
        if adsType then
            ShowIdentityNameAuthFrame(nil,nil,nil,nil,nil,adsType,true)
        else
            ShowIdentityNameAuthFrame()
        end
		return
	-- else
	-- 	ReqArchiveAppeal(false,worldid)
	-- 	return
	-- end
end

--发起申诉请求
function ReqArchiveAppeal( needIdentity, worldid)
	print("ReqArchiveAppeal( needIdentity, worldid)", needIdentity, worldid)
	if not needIdentity then
		GetInst("UIManager"):Open("ArchiveAppeal",{
			callback = function ( strReason )
				print(strReason)
				ReqMapAppeal( worldid, strReason, "", "", "" )
			end
			})
	else
		GetInst("UIManager"):Open("ArchiveAppealWithIdentity",{
			callback = function ( data )
				print(data)
				ReqMapAppeal( worldid, data.reason, data.name, data.identity, data.phone )
			end
			})
	end
end

function UpdateShareArchiveInfoIntroduce()
	local getglobal = getglobal;
	getglobal("ArchiveInfoFrameComment"):Hide();
	getglobal("ArchiveInfoFrameCommentBtnName"):SetTextColor(142, 135, 120);
	getglobal("ArchiveInfoFrameCommentBtnNormal"):SetTexUV("tab_sink_up_n");

	getglobal("ArchiveInfoFrameIntroduce"):Show();
	getglobal("ArchiveInfoFrameIntroduceBtnName"):SetTextColor(255, 135, 26);
	getglobal("ArchiveInfoFrameIntroduceBtnNormal"):SetTexUV("tab_sink_up_h");

	Log("UpdateShareArchiveInfoIntroduce");
	Log("   worldid = "..tostring(ArchiveWorldDesc.worldid));
	Log("   fromowid = "..tostring(ArchiveWorldDesc.fromowid));
	Log("   owneruin = "..tostring(ArchiveWorldDesc.owneruin));
	Log("   realowneruin = "..tostring(ArchiveWorldDesc.realowneruin));

	ArchiveWorldDesc = GetCurArchiveMapInfo("ArchiveWorldDesc")
	if ArchiveWorldDesc == nil then return end
	--头像
	local rolemodel = ArchiveWorldDesc.realModel;
	HeadCtrl:SetPlayerHead("ArchiveInfoFrameIntroduceHeadBtnIcon",2,rolemodel);

	--申诉按钮
	local appealBtn = getglobal("ArchiveInfoFrameIntroduceAppealBtn")
	if appealBtn then
		if IsOverseasVer() or isAbroadEvn() then
			getglobal("ArchiveInfoFrameIntroduceAppealBtnName"):SetText(GetS(10630))
		else
			getglobal("ArchiveInfoFrameIntroduceAppealBtnName"):SetText(GetS(10615))
		end
		local appealInfo = mapservice.mapAppealList[ArchiveWorldDesc.worldid]
		if ArchiveAppealSwitch and appealInfo then
			if appealInfo.appeal and appealInfo.appeal.stat then
				appealBtn:Hide()
				if appealInfo.appeal.stat == 0 then
					appealBtn:Show()
				elseif appealInfo.appeal.stat == 2 then
					local strTips = GetS(10623)
					if IsOverseasVer() or isAbroadEvn() then
						strTips = GetS(10635)
					end
					MessageBox(4, strTips)
				end
			else
				appealBtn:Show()
			end
		else
			appealBtn:Hide()
		end
	end

	if rolemodel then
		MapRewardClass:SetHeadIcon("ui/roleicons/"..rolemodel..".png")
	end
	--玩家名称
	-- print("UpdateShareArchiveInfoIntroduce(): ArchiveWorldDesc.realowneruin = ", ArchiveWorldDesc.realowneruin);
	if AccountManager:getUin() == ArchiveWorldDesc.realowneruin then
		getglobal("ArchiveInfoFrameIntroduceLinkName"):Hide();
		getglobal("ArchiveInfoFrameIntroduceName"):Show();
		getglobal("ArchiveInfoFrameIntroduceName"):SetText(ReplaceFilterString(ArchiveWorldDesc.realNickName));
		HeadFrameCtrl:CurrentHeadFrame("ArchiveInfoFrameIntroduceHeadBtnNormal");
		HeadFrameCtrl:CurrentHeadFrame("ArchiveInfoFrameIntroduceHeadBtnPushedBG");
		HeadCtrl:CurrentHeadIcon("ArchiveInfoFrameIntroduceHeadBtnIcon");
	else
		if ArchiveWorldDesc.realAVT ~= nil and ArchiveWorldDesc.realAVT ~= "" then
			local avt = JSON:decode(ArchiveWorldDesc.realAVT);
			HeadCtrl:SetPlayerHead("ArchiveInfoFrameIntroduceHeadBtnIcon",3,avt);
		end
		HeadFrameCtrl:SetPlayerheadFrame("ArchiveInfoFrameIntroduceHeadBtn",ArchiveWorldDesc.ownerIconFrame);
		--HeadFrameCtrl:SetPlayerheadFrameByNin(ArchiveWorldDesc.realowneruin,"ArchiveInfoFrameIntroduceHeadBtnNormal");
		--HeadFrameCtrl:SetPlayerheadFrameByNin(ArchiveWorldDesc.realowneruin,"ArchiveInfoFrameIntroduceHeadBtnPushedBG");

		getglobal("ArchiveInfoFrameIntroduceName"):Hide();
		getglobal("ArchiveInfoFrameIntroduceLinkName"):Show();
		getglobal("ArchiveInfoFrameIntroduceLinkName"):SetText("#L#c71c531"..ArchiveWorldDesc.realNickName.."#n", 247, 214, 166);
	end


	--mini号
	changeAbroadRealowneruin(ArchiveWorldDesc)  	--转换海外版本
	if gIsSingleGame then
		getglobal("ArchiveInfoFrameIntroduceMiniTitle"):Hide()
		getglobal("ArchiveInfoFrameIntroduceMini"):Hide()
	else
		getglobal("ArchiveInfoFrameIntroduceMini"):SetText( getShortUin(ArchiveWorldDesc.realowneruin) );
	end

	local vipinfo = VipInfo();
	vipinfo:LoadFromBriefInfo(ArchiveWorldDesc.credit);

	--版本号
	if hasUpdate2ShareVersion(ArchiveWorldDesc.worldid, ArchiveWorldDesc.shareVersion) then
		getglobal("ArchiveInfoFrameIntroduceShareVersion"):SetText(GetS(503));
	else
		getglobal("ArchiveInfoFrameIntroduceShareVersion"):SetText("");
	end

	--地图描述, 多语言显示
	local memoText = ArchiveWorldDesc.memo;
	if ArchiveWorldDesc and ArchiveWorldDesc.owneruin ~= ArchiveWorldDesc.realowneruin then
		if ArchiveWorldDesc.multilangdesc and get_game_env() >= 10 then --规避国内版本地图有多语言配置导致下载的地图在存档详情界面显示奇怪的地图描述的问题
			local lang_now  = ArchiveWorldDesc.translate_currentlang--get_userset_lang();
			print("UpdateShareArchiveInfoIntroduce:multilangdesc = ", ArchiveWorldDesc.multilangdesc);
			memoText = SignManagerGetInstance():parseTextFromLanguageJson(ArchiveWorldDesc.multilangdesc, lang_now);

			if not(memoText and #memoText > 0) then
				memoText = ArchiveWorldDesc.memo;
			end
		end
	end
	if memoText == "" then
		getglobal("ArchiveInfoFrameIntroduceDesc"):SetText(GetS(178), 224, 220, 202);
	else
		getglobal("ArchiveInfoFrameIntroduceDesc"):SetText(memoText, 224, 220, 202);
	end

	--需求最低的游戏版本号
	local needCltVer = getglobal("ArchiveInfoFrameIntroduceNeedCltVer");
	local needCltVerBkg = getglobal("ArchiveInfoFrameIntroduceNeedCltVerBkg");
	needCltVerBkg:Hide();
	needCltVer:SetText("");

	--标签
	local labelIcon = getglobal("ArchiveInfoFrameIntroduceLabelIcon")
	local label = getglobal("ArchiveInfoFrameIntroduceLabel")
	--Label
	local gameLabel = ArchiveWorldDesc.gameLabel;
	if gameLabel == 0 then
		gameLabel = GetLabel2Owtype(ArchiveWorldDesc.worldtype);
	end
	SetRoomTag(labelIcon, label, gameLabel);
	if ArchiveWorldDesc.owneruin == ArchiveWorldDesc.realowneruin then
		if ArchiveWorldDesc.worldtype == 4 then
			label:SetText(GetS(3807));
		elseif ArchiveWorldDesc.worldtype == 5 then
			label:SetText(GetS(3806));
		end
	end

	--评分
	local grade = getglobal("ArchiveInfoFrameIntroduceGrade");
	local gradeBkg = getglobal("ArchiveInfoFrameIntroduceGradeBkg");
	local gradeIcon = getglobal("ArchiveInfoFrameIntroduceGradeIcon");
	if getglobal("LobbyFrameArchiveFrame"):IsShown() and ArchiveWorldDesc.realowneruin == ArchiveWorldDesc.owneruin then
		grade:Hide();
		gradeBkg:Hide();
		gradeIcon:Hide();
	else
		grade:Show();
		gradeBkg:Show();
		gradeIcon:Show();
		SetArchiveGradeUI(grade, ArchiveWorldDesc.creditfloat);
	end
	--Tag
	local tagBkg = getglobal("ArchiveInfoFrameIntroduceTagBkg");
	local tagName = getglobal("ArchiveInfoFrameIntroduceTagName");
	SetRankTag(tagBkg, tagName, ArchiveWorldDesc.ownerIconParts);

	--截图
	local checkwid = ArchiveWorldDesc.fromowid;

	if checkwid == 0 then
		checkwid = ArchiveWorldDesc.worldid;
	end

	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(checkwid)
	local mapAppealStatus = MapAppealStatus(checkwid)
	if not BreakLawMapControl:IsMapBreakLaw(checkwid) and not IsMapNeadAppeal(checkwid) and ArchiveWorldDesc.OpenSvr ~= 2 then
		if getglobal("MiniWorksFrame"):IsShown() and CurArchiveMap then
			GetMapThumbnail(CurArchiveMap, "ArchiveInfoFrameIntroducePic");
		else
			local huires = Snapshot:getSnapshotTexture(ArchiveWorldDesc.worldid);
			getglobal("ArchiveInfoFrameIntroducePic"):SetTextureHuires(huires);
		end
		getglobal("ArchiveInfoFrameIntroducePicExplain"):Hide();
	elseif IsMapNeadAppeal(checkwid) then
		getglobal("ArchiveInfoFrameIntroducePic"):SetTexture("ui/snap_jubao.png");
		getglobal("ArchiveInfoFrameIntroducePicExplain"):SetText((mapAppealStatus == 0 and GetS(10656)) or (mapAppealStatus == 2 and GetS(20310)) or "");
		getglobal("ArchiveInfoFrameIntroducePicExplain"):Show();
		if not mapservice.mapAppealList[checkwid].appeal or not mapservice.mapAppealList[checkwid].appeal.stat then
			getglobal("ArchiveInfoFrameIntroducePicExplain"):SetText(GetS(10638))
		end
		if mapAppealStatus == 0 then
			getglobal("ArchiveInfoFrameIntroducePic"):SetTexture("ui/snap_empty.png");
		end
	else
		getglobal("ArchiveInfoFrameIntroducePic"):SetTexture("ui/snap_jubao.png");
		if ArchiveWorldDesc.OpenSvr == 2 then
			getglobal("ArchiveInfoFrameIntroducePicExplain"):SetText(GetS(25813))
		else
			getglobal("ArchiveInfoFrameIntroducePicExplain"):SetText((mapIsBreakLaw == 1 and GetS(10656)) or (mapIsBreakLaw == 2 and GetS(20310)) or "");
		end
		getglobal("ArchiveInfoFrameIntroducePicExplain"):Show();
	end

	--单人游戏、快速联机
	local starBtn = getglobal("ArchiveInfoFrameIntroduceStarGameBtn");
	local onlineBtn = getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn");
	--编辑录像、播放录像
	local editBtn = getglobal("ArchiveInfoFrameIntroduceRecordEditBtn");
	local playBtn = getglobal("ArchiveInfoFrameIntroduceRecordPlayBtn");

	local editBtnName = getglobal("ArchiveInfoFrameIntroduceRecordEditBtnName");
	if ArchiveWorldDesc.worldtype == 9 then
		starBtn:Hide();
		onlineBtn:Hide();

		if ArchiveInfoFrame_IsTempMapAndHideNotNeed() then
			getglobal("ArchiveInfoFrameIntroduceStarGameBtn_temp"):Hide();
			getglobal("ArchiveInfoFrameIntroduceUseTempMapBtn_temp"):Hide();
			getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_temp"):Hide();
		end

		if ArchiveWorldDesc.realowneruin == AccountManager:getUin() then
			editBtnName:SetText(GetS(7517));
			if CSMgr:isWorldRecordHaveCamera(ArchiveWorldDesc.worldid) then
				editBtn:Show();
				playBtn:Show();
				editBtn:SetPoint("bottom", "ArchiveInfoFrameIntroduce", "bottom", -115, -20);
				playBtn:SetPoint("bottom", "ArchiveInfoFrameIntroduce", "bottom", 115, -20);
			else
				editBtn:SetPoint("bottom", "ArchiveInfoFrameIntroduce", "bottom", 0, -20);
				editBtn:Show()
				playBtn:Hide();
			end
		else
			editBtn:Show();
			playBtn:Show();
			editBtnName:SetText(GetS(7562));
			editBtn:SetPoint("bottom", "ArchiveInfoFrameIntroduce", "bottom", -115, -20);
			playBtn:SetPoint("bottom", "ArchiveInfoFrameIntroduce", "bottom", 115, -20);
		end
	else
		editBtn:Hide();
		playBtn:Hide();
		if getglobal("LobbyFrameArchiveFrame"):IsShown() then
			starBtn:Show();

			if ArchiveInfoFrame_IsTempMapAndHideNotNeed() then
				getglobal("ArchiveInfoFrameIntroduceStarGameBtn_temp"):Show();
				getglobal("ArchiveInfoFrameIntroduceUseTempMapBtn_temp"):Show();
			end

			if IsNewbieWorld(ArchiveWorldDesc.worldid) or ArchiveWorldDesc.worldtype == 2 then
				starBtn:SetPoint("bottom", "ArchiveInfoFrameIntroduce", "bottom", 0, -20);
				onlineBtn:Hide();
			else
				starBtn:SetPoint("bottom", "ArchiveInfoFrameIntroduce", "bottom", -115, -20);
				onlineBtn:SetPoint("bottom", "ArchiveInfoFrameIntroduce", "bottom", 115, -20);
				onlineBtn:Show();
				if ClientMgr:getNetworkState() == 0 then	--无网络时
					onlineBtn:Disable();
					getglobal("ArchiveInfoFrameIntroduceStarOnlineBtnNormal"):SetGray(true);
				else
					onlineBtn:Enable();
					getglobal("ArchiveInfoFrameIntroduceStarOnlineBtnNormal"):SetGray(false);
				end

				if ArchiveInfoFrame_IsTempMapAndHideNotNeed() then
					getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_temp"):Show();
					if ClientMgr:getNetworkState() == 0 then	--无网络时
						getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_temp"):Disable();
						getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_tempNormal"):SetGray(true);
					else
						getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_temp"):Enable();
						getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_tempNormal"):SetGray(false);
					end
				end
			end
		else
			starBtn:Hide();
			onlineBtn:Hide();
			if ArchiveInfoFrame_IsTempMapAndHideNotNeed() then
				getglobal("ArchiveInfoFrameIntroduceStarGameBtn_temp"):Hide();
				getglobal("ArchiveInfoFrameIntroduceUseTempMapBtn_temp"):Hide();
				getglobal("ArchiveInfoFrameIntroduceStarOnlineBtn_temp"):Hide();
			end
		end
	end

	--收藏按钮
	if(getglobal("MiniWorksFrame"):IsShown()  or getglobal("PlayerExhibitionCenter"):IsShown() ) and CurArchiveMap then
		if not CurArchiveMap.fromHttp then
			getglobal("ArchiveInfoFrameIntroduceCollectBtn"):Show();

			if IsMapCollected(CurArchiveMap.owid) then  --已收藏
				getglobal("ArchiveInfoFrameIntroduceCollectBtnCancel"):Show();
				getglobal("ArchiveInfoFrameIntroduceCollectBtnCollect"):Hide();
				getglobal("ArchiveInfoFrameIntroduceCollectBtnNormal"):SetTexUV("mngf_btn04");
				getglobal("ArchiveInfoFrameIntroduceCollectBtnPushedBG"):SetTexUV("mngf_btn04");
			else  --未收藏
				getglobal("ArchiveInfoFrameIntroduceCollectBtnCancel"):Hide();
				getglobal("ArchiveInfoFrameIntroduceCollectBtnCollect"):Show();
				getglobal("ArchiveInfoFrameIntroduceCollectBtnNormal"):SetTexUV("icon_intomap");
				getglobal("ArchiveInfoFrameIntroduceCollectBtnPushedBG"):SetTexUV("icon_intomap");
			end
		else
			getglobal("ArchiveInfoFrameIntroduceCollectBtn"):Hide();
		end

		local funcBtnUi = getglobal("ArchiveInfoFrameIntroduceMiniworksFuncBtn");
		funcBtnUi:Show();
		UpdateFuncBtnDownloadState(funcBtnUi, CurArchiveMap);

	else
		getglobal("ArchiveInfoFrameIntroduceCollectBtn"):Hide();
		getglobal("ArchiveInfoFrameIntroduceMiniworksFuncBtn"):Hide();
	end

	--Vip
	local uiVipIcon1 = getglobal("ArchiveInfoFrameIntroduceVipIcon1");
	local uiVipIcon2 = getglobal("ArchiveInfoFrameIntroduceVipIcon2");
	local vipDispInfo = UpdateVipIcons(vipinfo, uiVipIcon1, uiVipIcon2);
	getglobal("ArchiveInfoFrameIntroduceName"):SetPoint("left", "ArchiveInfoFrameIntroduceNameTitle", "left", 78+vipDispInfo.nextUiOffsetX, 0);
end

function SetRankTag(bkg, name, rank)
	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(ArchiveWorldDesc.fromowid);
	if mapIsBreakLaw then
		if rank > 0 then
			bkg:Show();
			name:Show();
			if rank == 1 then
				bkg:SetTexUV("label_map_hot");		--蓝色
				name:SetText(GetS(3842));
				name:SetTextColor(3, 74, 123);
				name:SetShadowColor(1, 255, 228);
			elseif rank == 2 then
				bkg:SetTexUV("label_map_selection");  --黄色
				name:SetText(GetS(3843));
				name:SetTextColor(55, 54, 49);
				name:SetShadowColor(255, 230, 1);
			elseif rank == 3 then
				--[[
				name:SetText(GetS(191));  --推荐
				name:SetTextColor(38, 89, 54);	 --设置颜色
				name:SetShadowColor(255, 230, 1);
				]]
				bkg:Hide();
				name:Hide();
			end
		else
			bkg:Hide();
			name:Hide();
		end
	else
		bkg:Show();
		name:Show();

		bkg:SetTexUV("label_map_selection");  --黄色
		if mapIsBreakLaw == 1 then
			name:SetText(GetS(20309));
		elseif mapIsBreakLaw == 2 then
			name:SetText(GetS(20310));
		end
		name:SetTextColor(255, 233, 85);
		name:SetShadowColor(79, 58, 35);
	end
end

function UpdateShareArchiveInfoComment(reset, hasMore)
	getglobal("ArchiveInfoFrameIntroduce"):Hide();
	getglobal("ArchiveInfoFrameIntroduceBtnName"):SetTextColor(142, 135, 120);
	getglobal("ArchiveInfoFrameIntroduceBtnNormal"):SetTexUV("tab_sink_up_n");

	getglobal("ArchiveInfoFrameComment"):Show();
	getglobal("ArchiveInfoFrameCommentBtnName"):SetTextColor(255, 135, 26);
	getglobal("ArchiveInfoFrameCommentBtnNormal"):SetTexUV("tab_sink_up_h");

	local num = #(t_CommentList);
	if reset then
		getglobal("OwCommentBox"):resetOffsetPos();
	end
	local height = 0;
	for i=1, Comment_Max_Num do
		local index = i+1;
		local comment = getglobal("Comment"..i);
		if i <= num then
			comment:Show();
			local name 			= getglobal("Comment"..i.."Name");
			local content		= getglobal("Comment"..i.."Content");
			local del			= getglobal("Comment"..i.."Del");
			local time 			= getglobal("Comment"..i.."Time");
			local bar 			= getglobal("Comment"..i.."Bar");
			local head 			= getglobal("Comment"..i.."Head");
			local headFrame 	= getglobal("Comment"..i.."HeadFrame");
			local connoisseur 	= getglobal("Comment"..i.."Connoisseur");
			local checkLogo     = getglobal("Comment"..i.."CheckLogo");
			local checkText     = getglobal("Comment"..i.."CheckText");
			local auditTag 		= getglobal("Comment"..i.."AuditTag")
			local commentInfo = t_CommentList[i];--AccountManager:getOwCommentInfo(i);

			content:clearHistory();
			content:Clear();

			comment:SetClientUserData(0, commentInfo.uin);
			local text = "#L#cfba940" .. ReplaceFilterString(commentInfo.nickName) .."#n" ;
			name:SetText(text, 101, 116, 118);
			content:SetText(commentInfo.msg, 224, 220, 202);
			local lines = content:GetTextLines();
			content:SetSize(315, (lines-1)*26+19);
			local h = 92 +(lines-1) * 26;
			comment:SetSize(440, h);

			height = height + h;
			--[[ 不允许删除了
			if ArchiveWorldDesc.realowneruin == AccountManager:getUin() then
				del:Show();
				del:SetClientUserData(0, commentInfo.uin);
				del:SetClientUserData(1, i);
			else
				del:Hide();
			end
			]]
			del:Hide();
			local text = os.date("%Y", commentInfo.time).."/"..os.date("%m", commentInfo.time).."/"..os.date("%d", commentInfo.time);
			time:SetText(text);

			bar:SetCurValue(commentInfo.star/5, false);

			--head:SetTexture("ui/roleicons/"..commentInfo.headIndex..".png");
			if  commentInfo.HasAvatar and commentInfo.HasAvatar >= 1 then
				HeadCtrl:SetPlayerHeadByUin(head:GetName(),commentInfo.uin,commentInfo.headIndex,commentInfo.HasAvatar);
			else
				HeadCtrl:SetPlayerHead(head:GetName(),2,commentInfo.headIndex);
			end
			HeadFrameCtrl:SetPlayerheadFrameName(headFrame:GetName(),commentInfo.headFrameId);

			--鉴赏家
			if commentInfo.expert then
				connoisseur:Show();
			else
				connoisseur:Hide();
			end

			if commentInfo.black_stat == 1 then
				checkLogo:Show();
				checkText:Show();
				content:Hide();
			else
				checkLogo:Hide();
				checkText:Hide();
				content:Show();
			end

			if commentInfo.audit_tag and tonumber(commentInfo.audit_tag) == 0 then
				auditTag:Show()
			else
				auditTag:Hide()
			end
		else
			comment:Hide();
		end
	end

	if hasMore ~= nil then
		if hasMore then
			getglobal("OwCommentBoxMore"):Show();
		else
			getglobal("OwCommentBoxMore"):Hide();
		end
	end

	if getglobal("OwCommentBoxMore"):IsShown() then
		height = height + 30;
	else
		height = height + 8;
	end
	height = math.max(height, 520);
	getglobal("OwCommentBoxPlane"):SetSize(440, height);
end

function OwCommentBoxMore_OnClick()
	RequestMoreComment();
end

function OwCommentBox_OnMovieFinished()
	RequestMoreComment();
end

function RequestOwCommentList(owid, rank, uin)
	local  wid_ = "w" .. owid  	--地图ID容错1104011102600
	if  #wid_ >= 10 then

		local url = mapservice.getserver().."/miniw/map/?act=get_map_comment";
		--owid
		url = url.."&fn=w"..owid;
		--ctime
		if CurCommentTime > 0 then
			url = url.."&co_time="..CurCommentTime;
		else
			url = url.."&top=1";   --首次请求加3条神评
			if rank and (rank == 3 or rank == 2) then	--评测图(rank=2)和精选图(rank=3)都拉鉴赏家评测
				url = url.."&expert=1";
				if uin and uin > 0 then
					url = url.."&op_uin="..uin;
				end
			end
		end
		--auth
		url = UrlAddAuth(url);

		local _ReqCallback = function ( t_list )
			if IsMapDetailInfoShown() then 
				RespMapCommentList(t_list)
			end 

			if getglobal("MiniWorksArchiveInfoFrame"):IsShown() then 
				RespNewMapInfoCommentList(t_list)
			end 
		end

		--:新地图详情页另外处理:
		if IsMapDetailInfoShown() or getglobal("MiniWorksArchiveInfoFrame"):IsShown() then
			ns_http.func.rpc(url, _ReqCallback, nil, nil, true);
		end
	end

	ShowLoadLoopFrame(true, "file:lobby -- func:RequestOwCommentList")
end

function RespMapCommentList(t_list)
	if getglobal("LoadLoopFrame"):IsShown() then
		ShowLoadLoopFrame(false)
	end

	if type(t_list) ~= 'table' then
		ShowGameTips(GetS(771), 3);
		return;
	end

	local hasMore = false;
	local reset = false;
	if #(t_list) <= 0 and (not t_list.expert or #t_list.expert <= 0) then
		if #(t_CommentList) > 0 then	--没有更多评论
			ShowGameTips(GetS(770), 3);
		else				--没有评论
			ShowGameTips(GetS(769), 3);
		end
		return;
	else
		if #(t_list) >= MiniWorksMap_CommentNumForOnce then
			hasMore = true;
		end

		if #(t_CommentList) == 0 then
			reset = true;
		end
	end


	--鉴赏家评论列表：t_ConnoisseurCommentList
	if t_list.expert and #t_list.expert > 0 then
		local ExpertList = t_list.expert;
		for i=1, #ExpertList do
			if ExpertList[i].nickname ~= nil then
				table.insert(t_CommentList, {
													uin=ExpertList[i].uin,
													star=ExpertList[i].star,
													msg=unescape(ExpertList[i].msg),
													nickName=unescape(ExpertList[i].nickname),
													headIndex=ExpertList[i].uin_icon,
													headFrameId=ExpertList[i].head_frame_id,
													time=ExpertList[i].create_time,
													expert=true,
													black_stat = ExpertList[i].black_stat,
													audit_tag = (t_list[i] and t_list[i].open_svr) or 1,
												}
							);
			end
		end
	end

	for i=1, #(t_list) do
		if t_list[i].nickname ~= nil then
			table.insert(t_CommentList, {
					uin=t_list[i].uin,
					star=t_list[i].star,
					msg=unescape(t_list[i].msg),
					nickName=unescape(t_list[i].nickname),
					headIndex=t_list[i].uin_icon,
					headFrameId=t_list[i].head_frame_id,
					HasAvatar=t_list[i].HasAvatar,
					time=t_list[i].create_time,
					black_stat = t_list[i].black_stat,
					audit_tag = t_list[i].open_svr or 1,
				}
			);

			if CurCommentTime == 0 or CurCommentTime > t_list[i].create_time then
				CurCommentTime = t_list[i].create_time;
			end
		end
	end

	UpdateShareArchiveInfoComment(reset, hasMore);
end

-- :加载更多评论
function RequestMoreComment()
	if  not getglobal("MiniWorksMapCommentBoxMore"):IsShown() and
			not getglobal("OwCommentBoxMore"):IsShown() then
		Log("RequestMoreComment: XXX! #t_CommentList " .. #t_CommentList);
		return;
	end

	if  getglobal("LoadLoopFrame"):IsShown() then
		Log("LoadLoopFrame IsShown");
		return;
	end

	local owid = 0;
	if ArchiveWorldDesc.realowneruin == ArchiveWorldDesc.owneruin then
		owid = ArchiveWorldDesc.worldid;
	else
		owid = ArchiveWorldDesc.fromowid;
	end

	Log("LoadLoopFrame1");

	RequestOwCommentList(owid);
end

function ArchiveInfoFrameComment_OnHide()
	if getglobal("LoadLoopFrame"):IsShown() then
		ShowLoadLoopFrame(false)
	end
end

function ArchiveInfoFrame_OnClick()
	HideMapDetailInfo();
end

--分享存档信息的头像
function ArchiveInfoFrameHeadBtn_OnClick()
	if IsStandAloneMode() then return end
	if AccountManager:getUin() ~= 1 and AccountManager:getUin() == ArchiveWorldDesc.realowneruin then
		return;
	end
	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3);
		return;
	end

	--跳到工坊作者页面
	--:以前是调到工坊的搜索页面, 现在调到个人中心, 即改为和点击链接名一样.
	--MiniWorksFrame_ShowSearchUinUI(ArchiveWorldDesc.realowneruin);
	ArchiveInfoFrameIntroduceLinkName_OnClick();

--[[--不在工坊中，查看玩家信息
	if not BuddyManager:requestBuddyWatch(ArchiveWorldDesc.realowneruin) then
		--观察失败
	else
		HideMapDetailInfo();
		SearchWatchUin = ArchiveWorldDesc.realowneruin;
		local LoadLoopFrame = getglobal("LoadLoopFrame")
		if getglobal("LobbyFrameArchiveFrame"):IsShown() then
			LoadLoopFrame:Show();
		end
	end
]]--
end

--查看玩家
function ArchiveInfoFrameIntroduceLinkName_OnClick()
	if IsStandAloneMode() then return end
	if arg1 ~= 'LeftButton' then
		if BuddyManager:requestBuddyWatch(ArchiveWorldDesc.realowneruin) then
			SearchWatchUin = ArchiveWorldDesc.realowneruin;
			HideMapDetailInfo();
		end

	end
end

--:新地图详情页查看玩家
function NewArchiveInfoFrameIntroduceLinkName_OnClick(inputArchiveWorldDesc, needCloseBack)
	if arg1 ~= 'LeftButton' then
		--:ArchiveWorldDesc.realowneruin这个新界面和旧界面都用, 会导致交错的问题.MiniWorksMapShare_CurrentUserUin
		-- if BuddyManager:requestBuddyWatch(MiniWorksMapShare_CurrentUserUin) then
		-- 	SearchWatchUin = ArchiveWorldDesc.realowneruin;
		-- end

		--从个人中心退回来的时候会重新加载地图详情页，所以这里不用使用全局变量
		-- if BuddyManager:requestBuddyWatch(ArchiveWorldDesc.realowneruin) then
		-- 	SearchWatchUin = ArchiveWorldDesc.realowneruin;
		-- end
		-- if ArchiveWorldDesc.realowneruin ~= t_exhibition.uin then
		MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "PersonInformation", "click") --mark by liya 新埋点
		--迷你工坊进入地图详情页点击头像进入个人中心不关闭工坊，否则关闭个人中心，关闭地图详情就直接回首页了，回不了工坊
		-- if getglobal("MiniWorksFrame"):IsShown() then
		-- 	MiniWorksFrameCloseBtn_OnClick()
		-- 	-- if HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
		-- 		GetInst("UIManager"):Close("ArchiveInfoFrameEx")
		-- 		needCloseBack = false
		-- 	-- end
		-- end

		local desArchiveWorldDesc = inputArchiveWorldDesc or ArchiveWorldDesc
		if desArchiveWorldDesc then
			OpenNewPlayerCenter(desArchiveWorldDesc.realowneruin);
			SearchWatchUin = desArchiveWorldDesc.realowneruin;

			if needCloseBack and inputArchiveWorldDesc then
				local owid = 0
				if inputArchiveWorldDesc.realowneruin == inputArchiveWorldDesc.owneruin then
					owid = inputArchiveWorldDesc.worldid;
				else
					owid = inputArchiveWorldDesc.fromowid;
				end
				PEC_SetCloseCallBack(function()
					ShowMiniWorksMapDetailByMapID(owid);
				end)
				GetInst("UIManager"):Close("ArchiveInfoFrameEx")
				GetInst("MiniUIManager"):CloseUI("ArchiveInfoDetailAutoGen")
			end
	
			local playerCenterLevel = getglobal("PlayerExhibitionCenter"):GetFrameLevel()
			-- SetRoomFrameLevel(playerCenterLevel - 1)
			GetInst("CommentSystemInterface"):SetArchiveInfoFrameLevel(playerCenterLevel - 10)
			MiniWorksTopicDetailSetLevel()
		end
		
		-- end
		----getglobal("MiniWorksArchiveInfoFrame"):Hide();
	end
end

--复制迷你号
function NewArchiveInfoFrameCopyUin_OnClick()
	MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "MiniDuplicate", "click") --mark by liya 新埋点
	local txt_ = "" .. getShortUin(ArchiveWorldDesc.realowneruin);
	ClientMgr:clickCopy(txt_);
    ShowGameTipsWithoutFilter( txt_ .. " " .. GetS(739), 3);
end

--------------------------------------ShareArchiveInfoFrame---------------------------------
local ShareArchiveDescTex = ""
local ShareArchiveType = 0;

--UserData0 存档的Index
--UserData1 1分享存档 2更新分享

function ShareArchiveInfoFrame_OnLoad()
	for i=1, 8 do
		local icon = getglobal("ShareArchiveInfoFrameTypeFrameBtn"..i.."Icon");
		local iconcheck = getglobal("ShareArchiveInfoFrameTypeFrameBtn"..i.."IconCheck");
		local name = getglobal("ShareArchiveInfoFrameTypeFrameBtn"..i.."Name");
		local gameLabel = getglobal("ShareArchiveInfoFrameTypeFrameBtn"..i):GetClientID();
		SetRoomTag(icon, name, gameLabel, iconcheck);
	end
	getglobal("ShareArchiveInfoFrameForbiddenContext"):SetText(GetS(341))
end

function ShareArchiveInfoFrame_OnShow()
	print("ShareArchiveInfoFrame_OnShow:");
	SetArchiveDealMsg(false);
	local worldDesc = nil
	if isEnableNewLobby() then
		--local worldId = getglobal("ShareArchiveInfoFrame"):GetClientUserDataLL(0);
		local worldId = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
		worldDesc = AccountManager:findWorldDesc(worldId)
	else
		local archiveIndex = getglobal("ShareArchiveInfoFrame"):GetClientUserData(0);
		local archiveData = GetOneArchiveData(archiveIndex);
		worldDesc = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)
	end
	if worldDesc == nil then
		getglobal("ShareArchiveInfoFrame"):Hide();
		return;
	end

	--翻译按钮显示/隐藏
	if ShowTranslateBtn("mapshare_name", worldDesc.worldid) then
		ShowTranslateTextState("mapshare_name",worldDesc.worldid)
	end
	if ShowTranslateBtn("mapshare_desc", worldDesc.worldid) then
		ShowTranslateTextState("mapshare_desc",worldDesc.worldid)
	end

	--LLTEST:
--	print("multilangname=", worldDesc.multilangname);
--	print("multilangdesc=", worldDesc.multilangdesc);

	getglobal("ShareArchiveInfoFrameMapNameEdit"):SetText(worldDesc.worldname);

	ShareArchiveType = GetLabel2Owtype(worldDesc.worldtype);
	SetShareArchiveTypeState(ShareArchiveType);
	ShareArchiveLabelInit(worldDesc.worldtype)

	ShareArchiveDescTex = "";

	local shareBtnName = GetS(3042);
	if getglobal("ShareArchiveInfoFrame"):GetClientUserData(1) == 2 then
		shareBtnName = GetS(173);
	end
	if isEnableNewLobby() then
		local mapDetailInfo = GetInst("UIManager"):GetCtrl("MapDetailInfo", "uiCtrlOpenList")
		if mapDetailInfo and mapDetailInfo.reFreshUploadBtnStatus then
			mapDetailInfo:reFreshUploadBtnStatus(shareBtnName)
		end
	else
		getglobal("ShareArchiveInfoFrameShareBtnName"):SetText(shareBtnName);
	end

	getglobal("ShareArchiveInfoFrameMapDescEdit"):Clear();
	if string_trim(worldDesc.memo)=="" then
		getglobal("ShareArchiveInfoFrameMapDescGuide"):Show();
	else
		getglobal("ShareArchiveInfoFrameMapDescGuide"):Hide();
		getglobal("ShareArchiveInfoFrameMapDescEdit"):SetText(worldDesc.memo);
	end

	--此地图之前分享时选择的选项
	local k = tostring(worldDesc.worldid);
	local data = getkv(k, "sharemap_option");
	local t_data = nil;
	if data then
		t_data = JSON:decode(data);
	end

	--默认不投稿
	getglobal("ShareArchiveInfoFrameNoContributeBtnChecked"):Show();
	getglobal("ShareArchiveInfoFrameContributeActivityBtnChecked"):Hide();

	FetchActivityInfo();
	if mapservice.curActivityId~=nil then
		getglobal("ShareArchiveInfoFrameContributeActivityBtn"):Show();
		getglobal("ShareArchiveInfoFrameContributeActivityBtnName"):SetText(mapservice.curActivityName);
		if t_data and t_data.activityid > 0 then	--投稿
			getglobal("ShareArchiveInfoFrameNoContributeBtnChecked"):Hide();
			getglobal("ShareArchiveInfoFrameContributeActivityBtnChecked"):Show();
		end
	else
		getglobal("ShareArchiveInfoFrameContributeActivityBtn"):Hide();
	end

	getglobal("ShareArchiveInfoFrameNoContributeBtn"):Hide()
	getglobal("ShareArchiveInfoFrameContributeActivityBtn"):Hide()
	getglobal("ShareArchiveInfoFrameAgreementContent"):SetText(GetS(4075), 83, 95, 97);

	--分享类型
	--加分享限制
	local canShare = ShareArchiveInfoFrameCanShare()
	if canShare then
		local open = 3;
		if t_data and t_data.open then
			open = t_data.open;
		end

		if open == 1 then
			SetShareArchivePrivacy("ShareArchiveInfoFrameContributeBtn");
		elseif open == 2 then
			SetShareArchivePrivacy("ShareArchiveInfoFrameOnlyUploadBtn");
			getglobal("ShareArchiveInfoFrameSelfTickIcon"):Show();
		elseif open == 3 then
			SetShareArchivePrivacy("ShareArchiveInfoFrameOnlyUploadBtn");
			getglobal("ShareArchiveInfoFrameSelfTickIcon"):Hide();
		end
	else
		SetShareArchivePrivacy("ShareArchiveInfoFrameOnlyUploadBtn");
		getglobal("ShareArchiveInfoFrameSelfTickIcon"):Show();
	end

	if worldDesc.worldtype ~= 9 then
		getglobal("ShareArchiveInfoFrameAllowRecord"):Show();
		getglobal("ShareArchiveInfoFrameAllowRecordTickIcon"):Hide();
		getglobal("ShareArchiveInfoFrameTypeFrameBtn8"):Hide();
		for i=1, 7 do
			getglobal("ShareArchiveInfoFrameTypeFrameBtn"..i):Show();
		end
	else
		getglobal("ShareArchiveInfoFrameTypeFrameBtn8"):Show();
		getglobal("ShareArchiveInfoFrameAllowRecord"):Hide();
		for i=1, 7 do
			getglobal("ShareArchiveInfoFrameTypeFrameBtn"..i):Hide();
		end
	end
end

function ShareArchiveInfoFrameCanShare(isShowTips,tips)
	local canShare = false
	--满足渠道条件
	if check_apiid_ver_conditions(ns_version.upload_limit) then
		local sharePass = 0
		--创建账号时间
		local createAccountDayLimit = ns_version.upload_limit.acc_create_day
		local createAccountTimeLimit = tonumber(createAccountDayLimit) * 60 * 60 * 24
		local createAccountTime = CSMgr:getAccountCreateTime()
		local passTime = AccountManager:getSvrTime() - createAccountTime
		if passTime >= createAccountTimeLimit then
			sharePass = sharePass + 1
		else
			if isShowTips then
				if not tips then
					ShowGameTips(GetS(343),3)
				else
					ShowGameTips(tips,3)
				end
				return canShare
			end
		end
		--家园等级
		local treeLevelLimit = ns_version.upload_limit.tree_level
		local treeLevel = HomeChestMgr.getSelfChestTreeLevel()
		if tonumber(treeLevel) >= tonumber(treeLevelLimit) then
			sharePass = sharePass + 1
		else
			if isShowTips then
				if not tips then
					ShowGameTips(GetS(342),3)
				else
					ShowGameTips(tips,3)
				end
			end
		end

		if sharePass == 2 then
			canShare = true
		end
	end
	return canShare
end

function ShareArchiveInfoFrameNoContributeBtn_OnClick()
	getglobal("ShareArchiveInfoFrameNoContributeBtnChecked"):Show();
	getglobal("ShareArchiveInfoFrameContributeActivityBtnChecked"):Hide();
end

function ShareArchiveInfoFrameContributeActivityBtn_OnClick()
	getglobal("ShareArchiveInfoFrameNoContributeBtnChecked"):Hide();
	getglobal("ShareArchiveInfoFrameContributeActivityBtnChecked"):Show();
end

function ShareArchiveInfoFrameAgreementContent_OnClick()
	getglobal("AgreementFrame"):Show();
end

function ShareArchiveInfoFrameAgreementTick_OnClick()
	if getglobal("ShareArchiveInfoFrameAgreementTickIcon"):IsShown() then
		getglobal("ShareArchiveInfoFrameAgreementTickIcon"):Hide();
	else
		getglobal("ShareArchiveInfoFrameAgreementTickIcon"):Show();
	end
end

function ShareArchiveInfoFrameAllowRecordTick_OnClick()
	if getglobal("ShareArchiveInfoFrameAllowRecordTickIcon"):IsShown() then
		getglobal("ShareArchiveInfoFrameAllowRecordTickIcon"):Hide();
	else
		getglobal("ShareArchiveInfoFrameAllowRecordTickIcon"):Show();
	end
end

function ShareArchiveInfoFrameAllowShareDynamicTick_OnClick()
	if false == AccountSafetyCheck:FunCheck(AccountSafetyCheck.FunType.DYNAMIC_PUBLISH) then
		return
	end

	if getglobal("ShareArchiveInfoFrameAllowShareDynamicTickIcon"):IsShown() then
		getglobal("ShareArchiveInfoFrameAllowShareDynamicTickIcon"):Hide();
	else
		getglobal("ShareArchiveInfoFrameAllowShareDynamicTickIcon"):Show();
	end
end

function ShareArchiveInfoFrame_OnHide()
	SetArchiveDealMsg(true);
	getglobal("ShareArchiveInfoFrame"):SetClientUserData(0, 0);
	getglobal("ShareArchiveInfoFrameMapDesc"):Clear();
end

function SetShareArchivePrivacy(btnName)
	local t_ShareArchivePrivacy= {"ShareArchiveInfoFrameContributeBtn", "ShareArchiveInfoFrameOnlyUploadBtn"}

	for i=1, #(t_ShareArchivePrivacy) do
		local checked = getglobal(t_ShareArchivePrivacy[i].."Checked");
		local name = getglobal(t_ShareArchivePrivacy[i].."Name");
		name:SetTextColor(55, 54, 49);
		checked:Hide();
	end
	local checked = getglobal(btnName.."Checked");
	local name = getglobal(btnName.."Name");
	checked:Show();
	name:SetTextColor(55, 54, 49);

	if btnName == "ShareArchiveInfoFrameOnlyUploadBtn" then
		getglobal("ShareArchiveInfoFrameSelfTick"):Hide();
		getglobal("ShareArchiveInfoFrameShareBtnName"):SetText(GetS(25803))
		getglobal("ShareArchiveInfoFrameOnlyUploadDesc"):SetText(GetS(25809))
		-- if getglobal("ShareArchiveInfoFrameSelfTickIcon"):IsShown() then
		-- 	getglobal("ShareArchiveInfoFrameOnlyUploadDesc"):SetText(GetS(1284));
		-- else
		-- 	getglobal("ShareArchiveInfoFrameOnlyUploadDesc"):SetText(GetS(1283));
		-- end
	else
		getglobal("ShareArchiveInfoFrameSelfTick"):Hide();
		getglobal("ShareArchiveInfoFrameShareBtnName"):SetText(GetS(25802))
		getglobal("ShareArchiveInfoFrameOnlyUploadDesc"):SetText(GetS(25808));
	end
end

function ShareArchiveInfoFrameMapNameEdit_OnFocusLost()
	local text = ReplaceFilterString(getglobal("ShareArchiveInfoFrameMapNameEdit"):GetText());
	getglobal("ShareArchiveInfoFrameMapNameEdit"):SetText(text);


end

function ShareArchiveInfoFrameMapNameEdit_OnEnterPressed()
	UIFrameMgr:setCurEditBox(nil);
end

function ShareArchiveInfoFrameMapNameEdit_OnTabPressed()
	SetCurEditBox("ShareArchiveInfoFrameMapDescEdit");
end

function ShareArchiveInfoFrameMapNameEdit_OnClick()
    -- 限制修改地图名:ShowGameTips('因您不符合政策要求，暂时无法使用此功能', 3);
    if FunctionLimitCtrl:IsNormalBtnClick(FunctionType.RSET_MAPNAME) then
    	--常规
    	this:enableEdit(true);
    else
    	--限制
        this:enableEdit(false);
    	return;
    end
end

function ShareArchiveInfoFrameMapDescEdit_OnFocusLost()
	-- local print = Android:Localize(Android.SITUATION.MULTIEDITBOX);
	print("ShareArchiveInfoFrameMapDescEdit_OnFocusLost(): ");
	local text = ReplaceFilterString(this:GetText());
	print("ShareArchiveInfoFrameMapDescEdit_OnFocusLost(): text = ", text);
	this:SetText(text);
	if text == "" then
	else
		getglobal("ShareArchiveInfoFrameMapDescEdit"):SetText(text);
	end
end

function ShareArchiveInfoFrameMapDescEdit_OnEnterPressed()
	UIFrameMgr:setCurEditBox(nil);
end

function ShareArchiveInfoFrameMapDescEdit_OnTabPressed()
	SetCurEditBox("ShareArchiveInfoFrameMapNameEdit");
end

function ShareArchiveInfoFrameMapDescEdit_OnFocusGained()
    -- 限制修改地图名:ShowGameTips('因您不符合政策要求，暂时无法使用此功能', 3);
    if FunctionLimitCtrl:IsNormalBtnClick(FunctionType.RSET_MAPNAME) then
    	--常规
    	this:enableEdit(true);
    	getglobal("ShareArchiveInfoFrameMapDescGuide"):Hide();
    else
    	--限制
        this:enableEdit(false);
    	return;
    end
	-- local print = Android:Localize(Android.SITUATION.MULTIEDITBOX);
--	getglobal("ShareArchiveInfoFrameMapDescEdit"):SetText(ShareArchiveDescTex);

--	getglobal("ShareArchiveInfoFrameMapDesc"):Clear();
end

--存档投稿
function ShareArchiveInfoFrameContributeBtn_OnClick()
	if ShareArchiveInfoFrameCanShare(true) then
		SetShareArchivePrivacy(this:GetName());
	end
end

--存档仅上传
function ShareArchiveInfoFrameOnlyUploadBtn_OnClick()
	SetShareArchivePrivacy(this:GetName());
end

--存档仅自己可见
function ShareArchiveInfoFrameSelfTick_OnClick()
	if ShareArchiveInfoFrameCanShare(true) then
		if getglobal("ShareArchiveInfoFrameSelfTickIcon"):IsShown() then
			getglobal("ShareArchiveInfoFrameSelfTickIcon"):Hide();
			getglobal("ShareArchiveInfoFrameOnlyUploadDesc"):SetText(GetS(1283));
		else
			getglobal("ShareArchiveInfoFrameSelfTickIcon"):Show();
			getglobal("ShareArchiveInfoFrameOnlyUploadDesc"):SetText(GetS(1284));
		end
	end
end

function SetShareArchiveTypeState(gameLabel)
	ShareArchiveType = gameLabel;
	if ShareArchiveType == 9 then
		getglobal("ShareArchiveInfoFrameTypeFrameBtn8"):Show();
		getglobal("ShareArchiveInfoFrameTypeFrameBtn8Check"):Show();
		getglobal("ShareArchiveInfoFrameTypeFrameBtn8Icon"):Hide();
		getglobal("ShareArchiveInfoFrameTypeFrameBtn8IconCheck"):Show();
	else
		getglobal("ShareArchiveInfoFrameTypeFrameBtn8"):Hide();
		for i=1, 7 do
			local check 	= getglobal("ShareArchiveInfoFrameTypeFrameBtn"..i.."Check");
			local icon 		= getglobal("ShareArchiveInfoFrameTypeFrameBtn"..i.."Icon");
			local checkIcon = getglobal("ShareArchiveInfoFrameTypeFrameBtn"..i.."IconCheck");
			local clientId 	= getglobal("ShareArchiveInfoFrameTypeFrameBtn"..i):GetClientID();
			if gameLabel == clientId then
				check:Show();
				checkIcon:Show();
				icon:Hide()
			else
				check:Hide();
				checkIcon:Hide();
				icon:Show()
			end
		end
	end
end

--默认可以选择的分类标签
function ShareArchiveLabelInit(gameType)
	local labels = GetOptionalLabels2Owtype(gameType)
	for i=1, 7 do
		getglobal("ShareArchiveInfoFrameTypeFrameBtn"..i):Disable(true)
	end
	for i,v in ipairs(labels) do
		getglobal("ShareArchiveInfoFrameTypeFrameBtn"..(v-1)):Enable(true)
	end
end

--分享地图
function ShareArchiveInfoFrameShareBtn_OnClick()
	if not CanUseNet() then
		return;
	end

	local hasAgreed = getglobal("ShareArchiveInfoFrameAgreementTickIcon"):IsShown();
	if not hasAgreed then
		ShowGameTips(GetS(4523),3);
		return;
	end

	if getglobal("ShareArchiveInfoFrameMapNameEdit"):GetText() == "" then
		ShowGameTips(GetS(181),3);
		return;
	end
	local MessageBoxFrame = getglobal("MessageBoxFrame");

	local archiveIndex = getglobal("ShareArchiveInfoFrame"):GetClientUserData(0);
	if archiveIndex > AccountManager:getMyWorldList():getNumWorld() then return end

	local netState = ClientMgr:getNetworkState();
	if netState == 0 then
		ShowGameTips(GetS(18), 3);
	elseif netState == 2 then
		if archiveIndex >= 0 then
			MessageBox(2, GetS(21));
			if isEnableNewLobby() then
				MessageBoxFrame:SetClientUserData(0, archiveIndex);
			end
			MessageBoxFrame:SetClientString( "网络提示" );
		end
	else
		IsNeedReset = false;
		local open = 1;
		if getglobal("ShareArchiveInfoFrameOnlyUploadBtnChecked"):IsShown() then
			open = 2;
		end

		local callback = function()
			if getglobal("ShareArchiveInfoFrame"):IsShown() then
				ShareArchiveInfoFrameShareBtn_OnClick()
			end
		end

		if open ~= 2 and false == AccountSafetyCheck:FunCheck(AccountSafetyCheck.FunType.MAP_SHARE, callback) then
			-- 这里加个提示，方便定位问题
			if IsOverseasVer() or isAbroadEvn() then
				ShowGameTips("Share Map error at account safe check",3)
			end
			return
		end

		--分享二次确认
		MessageBox(28, GetS(3639), function(btn)
			if btn == 'left' then 	--确认
				if isEnableNewLobby() then
					local worldId = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
					ShareMap(worldId, getglobal("ShareArchiveInfoFrame"):GetClientUserData(0));
				else
					ShareMap(archiveIndex, getglobal("ShareArchiveInfoFrame"):GetClientUserData(0));
				end
			elseif btn == 'right' then 	--取消

			end
		end)
	end
end


--分享 type 1分享 2更新分享
function ShareMap(clientId, type)
	local worldInfo = nil
	if isEnableNewLobby() then
		worldInfo = AccountManager:findWorldDesc(clientId)
	else
		local archiveData = GetOneArchiveData(clientId);
		worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)
	end

	
	local worldName = getglobal("ShareArchiveInfoFrameMapNameEdit"):GetText();
	local text = getglobal("ShareArchiveInfoFrameMapDescEdit"):GetText();

	local verifyId = worldInfo.fromowid;

	if not verifyId or verifyId == 0 then
		verifyId = worldInfo.worldid;
	end

	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(verifyId)
	if mapIsBreakLaw == 1 then
		ShowGameTips(GetS(10564), 3);
		return;
	elseif mapIsBreakLaw == 2 then
		ShowGameTips(GetS(3634), 3);
		return;
	end

	--敏感词过滤
	if CheckFilterString(worldName.." "..text, false)
			or FilterMgr.GetFilterScore(worldName) or FilterMgr.GetFilterScore(text) then
		ShowGameTips(GetS(10546), 3) --分享TODO
		return;
	end

	if ModMgr and (ShareArchiveType ~= 9) then
		ModMgr:GetTxtDescInModsOfMapAndSave(verifyId, true, worldInfo._specialType)
	end

	--open  1=公开投稿 2=不可见 3=仅搜索可见
	local open = 1;
	if getglobal("ShareArchiveInfoFrameOnlyUploadBtnChecked"):IsShown() then
		open = 2;
		-- if not getglobal("ShareArchiveInfoFrameSelfTickIcon"):IsShown() then
		-- 	open = 3;
		-- end
	end

	local activity = -1;
	if mapservice.curActivityId~=nil and getglobal("ShareArchiveInfoFrameContributeActivityBtnChecked"):IsShown() then
		activity = mapservice.curActivityId;
	end

	local canrecord = 0;
	if getglobal("ShareArchiveInfoFrameAllowRecordTickIcon"):IsShown() then
		canrecord = 1;
	end

	--对语言支持, 地图名和描述
	local MultiLangName = curShareMapInfo.multilangname;
	local MultiLangDesc = curShareMapInfo.multilangdesc;
	print("ShareMap:clientId=", clientId);
	print("ShareMap:multilangname=", MultiLangName);
	print("ShareMap:multilangdesc=", MultiLangDesc);

	if UploadMap(worldInfo.worldid, open, ShareArchiveType, worldName, text, activity, canrecord, MultiLangName, MultiLangDesc) then
		IsNeedReset = false;
		ShareingMapIndex = clientId;

		-- if ShareArchiveType == 9 then
		-- 	statisticsGameEvent(40003, "%lld", worldInfo.worldid);  --录像上传埋点
		-- end
		local supportlang = -1;
		if worldInfo.translate_supportlang > math.pow(2,get_game_lang()) then
			supportlang = worldInfo.translate_supportlang
		end
		--ShowGameTips("oioi"..tostring(type))
		-- if AccountManager:findWorldDesc(worldInfo.worldid) then
		-- 	if getglobal("ShareArchiveInfoFrame"):GetClientUserData(1) == 1 then
		-- 		-- statisticsGameEvent(61500,"%s",tostring(supportlang),"%s",tostring(worldInfo.worldid))
		-- 	elseif getglobal("ShareArchiveInfoFrame"):GetClientUserData(1) == 2 then
		-- 		-- statisticsGameEvent(61501,"%s",tostring(supportlang),"%s",tostring(worldInfo.worldid))
		-- 	end
		-- end

		--把分享选择的选项记录下来
		local k = tostring(worldInfo.worldid);
		local v = JSON:encode {open=open, activityid=activity};
		setkv(k, v, "sharemap_option");

		--[[
		--增加分享动态
		if getglobal("ShareArchiveInfoFrameAllowShareDynamicTickIcon"):IsShown() then
			ShareToDynamic:Init();

			local path = "data/w"..verifyId.."/thumb.png_"
			if not gFunc_isFileExist(path) then
				path = "data/w"..verifyId.."/thumb.png"
			end
			if gFunc_isFileExist(path) then
				Log("开始发送动态")
				ShareToDynamic:SetPicName(path)
				getglobal("DynamicPublishFrame"):Show();
				--GetZoneDynamicMgrParam():InitPublishFrame();
				ShareToDynamic:SetActionParameter(25,verifyId);
				GetInst("PlayerCenterDynamicsManager"):SetAction(25,verifyId)

				getglobal("DynamicPublishFrameTextEdit"):SetText(GetS(9339,worldName));
				--DynamicPublishFrameCommitBtn_OnClick();
			else
				ShowGameTips("发送失败")
			end


		end
		]]
	end
	--ShowGameTips(tostring(AccountManager:getWorldSupportLang(ArchiveWorldDesc.worldid)))
	getglobal("ShareArchiveInfoFrame"):Hide();
end

function ShareArchiveInfoFrameCloseBtn_OnClick()
	getglobal("ShareArchiveInfoFrame"):Hide();
end

--------------------------------------------- 存档备份 begin ---------------------------------------------

local WorldBackupFrame_CurOwid = nil;
local WorldBackupFrame_MaxSlots = 7;

function ShowWorldBackupFrame(owid)
	WorldBackupFrame_CurOwid = owid;
	getglobal("WorldBackupFrame"):Show();
	AccountManager:setNoviceGuideState("guidebackup", true);
	UpdateArchiveBackupGuideAll();
end

function OnlineWorldBackup(owid, callback)
	WorldBackupFrame_CurOwid = owid;
	CSOWorld:loadWorldBackupInfos(WorldBackupFrame_CurOwid);
	for i=1,CSOWorld:getWorldBackupInfoNum() do
		local info = CSOWorld:getWorldBackupInfo(i-1);
		if info.isOnlineBackup then
			CSOWorld:deleteWorldBackup(info);
		end
	end

	WorldBackupMsgBox_Mode = 3;
	WorldBackupMsgBox_CurBackupPath = nil;
	WorldBackupMsgBox_CurOwid = owid;

	if CSOWorld:createWorldBackup(WorldBackupMsgBox_CurOwid, GetS(3732),true) then
		ShowGameTips(GetS(4016), 3);
	else
		ShowGameTips(GetS(4017), 3);
	end
	SingleUpdateOnlineBackup();
	OnlineBackupUpdateWorld(WorldBackupMsgBox_CurOwid);
	AccountManager:setNoviceGuideState("guidebackup", true);
	UpdateArchiveBackupGuideAll();

	if callback then callback() end
end

function WorldBackupFrame_OnLoad()

end

function WorldBackupFrame_OnHide()
	--[[

	if getglobal("CreateRoomFrame"):IsShown() then
		Log("OpenRoom4");
		OpenRoom();
	end

	--]]

end

--存档备份tab按钮
local m_WorldBackupTabBtnInfo = {
	{uiName = "WorldBackupFrameOrdinaryBackupBtn", nameID = 3731}, 	--普通备份
	{uiName = "WorldBackupFrameOnlineBackupBtn", nameID = 3732}, 	--联机备份
	{uiName = "WorldBackupFrameCloudServerBackupBtn", nameID = 9615}, 	--云服备份
};
function WorldBackupFrame_OnShow()
	Log("WorldBackupFrame_OnShow");
	--初始化tab状态
	TemplateTabBtn2_SetState(m_WorldBackupTabBtnInfo, 1);

	getglobal("WorldBackupFrameBackupBtn"):Show();
	getglobal("WorldBackupFrameOrdinaryBackupBtn"):Checked();

	getglobal("WorldBackupFrameOnlineBackupBtn"):DisChecked();
	getglobal("WorldBackupFrameOnlineBackupBtn"):Enable();
	
	--HideMapDetailInfo();
	UpdateBackupSlots();

	--租赁服备份按钮显示
	if if_open_rent_server() then
		getglobal("WorldBackupFrameCloudServerBackupBtn"):Show()
	else
		getglobal("WorldBackupFrameCloudServerBackupBtn"):Hide()
	end

	if gIsSingleGame then
		getglobal("WorldBackupFrameOnlineBackupBtn"):Hide()
	end
end

function WorldBackupFrameCloseBtn_OnClick()
	getglobal("WorldBackupFrame"):Hide();
end

function WorldBackupFrameOrdinaryBackupBtn_OnClick()
	if getglobal("LobbyFrameArchiveFrame"):IsShown() or IsUIFrameShown("lobbyMapArchiveList") then
		getglobal("WorldBackupFrameBackupBtn"):Show();
	end
	--刷新下按钮状态
	TemplateTabBtn2_SetState(m_WorldBackupTabBtnInfo, 1);
	getglobal("WorldBackupFrameNoticeBody"):SetText(GetS(4005));

	UpdateBackupSlots();
end

function WorldBackupFrameOnlineBackupBtn_OnClick()
	if getglobal("LobbyFrameArchiveFrame"):IsShown() or IsUIFrameShown("lobbyMapArchiveList") then
		getglobal("WorldBackupFrameBackupBtn"):Hide();
	end
	
	local cInterface = GetInst("CreationCenterInterface")
	if cInterface and cInterface:GetNewCreationCenterIsOpen() then 
		getglobal("WorldBackupFrameBackupBtn"):Hide()
	end 
	
	if cInterface and cInterface:GetCreationCenter2IsOpen() then 
		getglobal("WorldBackupFrameBackupBtn"):Hide()
	end 
	
	--刷新下按钮状态
	TemplateTabBtn2_SetState(m_WorldBackupTabBtnInfo, 2);
	getglobal("WorldBackupFrameNoticeBody"):SetText(GetS(4036));

	UpdateOnlineBackupSlots();
end

function WorldBackupFrameCloudServerBackupBtn_OnClick()
	if getglobal("LobbyFrameArchiveFrame"):IsShown() or IsUIFrameShown("lobbyMapArchiveList") then
		getglobal("WorldBackupFrameBackupBtn"):Hide();
	end
	
	local cInterface = GetInst("CreationCenterInterface")
	if cInterface and cInterface:GetNewCreationCenterIsOpen() then 
		getglobal("WorldBackupFrameBackupBtn"):Hide();
	end 
	
	if cInterface and cInterface:GetCreationCenter2IsOpen() then 
		getglobal("WorldBackupFrameBackupBtn"):Hide()
	end

	TemplateTabBtn2_SetState(m_WorldBackupTabBtnInfo, 3);
	getglobal("WorldBackupFrameNoticeBody"):SetText(GetS(4036));

	UpdateCloudServerBackupSlots()
end


function WorldBackupFrameBackupBtn_OnClick()
	if CSOWorld:getWorldOrdinaryBackupInfoNum() >= 3 then
			ShowGameTips(GetS(9768), 5);
			return;
	end
	Log("ShowBackupConfirm")
	ShowBackupConfirm(WorldBackupFrame_CurOwid);
end

function BackupSlotCSIDBtn_OnClick()
	local zippath = this:GetParentFrame():GetClientString();
	print("BackupSlotCSIDBtn_OnClick ", zippath)
	for i=1,CSOWorld:getWorldBackupInfoNum() do
		local info = CSOWorld:getWorldBackupInfo(i-1);
		if info.isCloudServerBackup and zippath == info.zip_path then
			ShowGameTips(GetS(9700, info.uin .. "-" .. info.cloudServerID))
			break;
		end
	end
end

function BackupSlotTemplateDeleteBtn_OnClick()
	local zippath = this:GetParentFrame():GetClientString();

	for i=1,CSOWorld:getWorldBackupInfoNum() do
		local info = CSOWorld:getWorldBackupInfo(i-1);
		if info.zip_path == zippath then
			ShowBackupDeleteConfirm(info)
			break
		end
	end
end


function BackupSlotTemplateRestoreBtn_OnClick()
	local zippath = this:GetParentFrame():GetClientString();
	for i=1,CSOWorld:getWorldBackupInfoNum() do
		local info = CSOWorld:getWorldBackupInfo(i-1);
		if info.zip_path == zippath then
			if info.isOnlineBackup then --联机备份
				ShowBackupRestoreConfirm(info);
			elseif info.isCloudServerBackup then --云服备份
				ShowBackupRestoreConfirm(info, 4, nil, 9694);
			else --普通备份
				ShowBackupRestoreConfirm(info);
			end
			break
		end
	end
end

--------------------------------------------------------------------------------------------------------------
--备份动态列表
function WorldBackupFrameBackList_tableCellAtIndex(tableView, index)
    --LUA的索引跟C++相差1
    local luaIdx = index + 1
	local listFrame = getglobal("WorldBackupFrameBackList")
	local clientStr = listFrame:GetClientString()
	local cidx = tonumber((string.split(clientStr, ",") or {})[luaIdx])

    local templateName = "BackupSlotTemplate"
    local cell, uiIndex = listFrame:dequeueCell(0)
    --没有可复用的，创建cell
    if not cell then
        local itemName = "WorldBackupFrameBackListSlot" .. uiIndex
        local tableViewName = "WorldBackupFrameBackList"
        cell = UIFrameMgr:CreateFrameByTemplate("Frame", itemName, templateName, tableViewName)
    end
	
    cell:Hide()
	if cidx and cidx < CSOWorld:getWorldBackupInfoNum() then
		local info = CSOWorld:getWorldBackupInfo(cidx)
		UpdateSingleBackupSlot(cell, info)
		cell:Show()
	end

	return cell
end

function WorldBackupFrameBackList_numberOfCellsInTableView(tableView)
	local listFrame = getglobal("WorldBackupFrameBackList")
	local clientStr = listFrame:GetClientString()
	return #(string.split(clientStr, ",") or {})
end

function WorldBackupFrameBackList_tableCellSizeForIndex(tableView, index)
	local colidx = math.mod(index, 2)
	return 0, 0, 534, 129+4
end

function WorldBackupFrameBackList_tableCellWillRecycle(tableView, cell)
	if cell then 
		cell:Hide() 
	end
end
------------------------------------------------------------------------------------
--[[
	WorldBackupFrameSlotXX
	已改为动态列表 不再用序号去区分
--]]

--普通备份列表刷新
function UpdateBackupSlots()
	CSOWorld:loadWorldBackupInfos(WorldBackupFrame_CurOwid)

	--刷新已有的普通备份
	local cidxs = {}
	for i=1,CSOWorld:getWorldBackupInfoNum() do
		local info = CSOWorld:getWorldBackupInfo(i-1)
		if info.isOnlineBackup or info.isCloudServerBackup then
			--只处理普通备份
		else
			table.insert(cidxs, i-1)
		end
	end

	local listFrame = getglobal("WorldBackupFrameBackList")
	listFrame:SetClientString(table.concat(cidxs, ","))
	
    local listWidth = listFrame:GetRealWidth2()
    local listHeight = listFrame:GetRealHeight2()
    listFrame:initData(listWidth, listHeight, #cidxs, 1, false)

	--判断是否显示无备份提示
	if #cidxs == 0 then
		getglobal("WorldBackupFrameDecorate"):Show();
	else
		getglobal("WorldBackupFrameDecorate"):Hide();
	end
end

--云服备份列表刷新
function UpdateCloudServerBackupSlots()
	CSOWorld:loadWorldBackupInfos(WorldBackupFrame_CurOwid);

	--刷新已有的云服备份
	local cidxs = {}
	for i=1,CSOWorld:getWorldBackupInfoNum() do
		local info = CSOWorld:getWorldBackupInfo(i-1)
		if info.isCloudServerBackup then
			table.insert(cidxs, i-1)
		end
	end
	
	local listFrame = getglobal("WorldBackupFrameBackList")
	listFrame:SetClientString(table.concat(cidxs, ","))
	
    local listWidth = listFrame:GetRealWidth2()
    local listHeight = listFrame:GetRealHeight2()
    listFrame:initData(listWidth, listHeight, #cidxs, 1, false)

	--判断是否显示无备份提示
	if #cidxs == 0 then
		getglobal("WorldBackupFrameDecorate"):Show();
	else
		getglobal("WorldBackupFrameDecorate"):Hide();
	end
end

--联机备份列表刷新
function UpdateOnlineBackupSlots()
	CSOWorld:loadWorldBackupInfos(WorldBackupFrame_CurOwid);

	--刷新已有的联机备份
	local cidxs = {}
	for i=1,CSOWorld:getWorldBackupInfoNum() do
		local info = CSOWorld:getWorldBackupInfo(i-1)
		if info.isOnlineBackup then
			table.insert(cidxs, i-1)
		end
	end

	local listFrame = getglobal("WorldBackupFrameBackList")
	listFrame:SetClientString(table.concat(cidxs, ","))
	
    local listWidth = listFrame:GetRealWidth2()
    local listHeight = listFrame:GetRealHeight2()
    listFrame:initData(listWidth, listHeight, #cidxs, 1, false)

	--判断是否显示无备份提示
	if #cidxs == 0 then
		getglobal("WorldBackupFrameDecorate"):Show();
	else
		getglobal("WorldBackupFrameDecorate"):Hide();
	end
end

function SingleUpdateOnlineBackup()
	UpdateOnlineBackupSlots()
end


function UpdateSingleBackupSlot(slotui, info)
	local slotuiname = slotui:GetName();
	Log("SlotuiName=" .. slotui:GetName());

	local csidBtn = getglobal(slotuiname .. "CSIDBtn")
	csidBtn:Hide()
	if info then
		getglobal(slotuiname.."Name"):SetText(info.name);

		local time = os.date("*t", info.time);
		local timestr = string.format("%d-%d-%d %02d:%02d:%02d", time.year, time.month, time.day, time.hour, time.min, time.sec);
		getglobal(slotuiname.."Time"):SetText(timestr);

		local sizestr = string.format("%0.2f", info.size/1048576).."M"; --X.XXM
		getglobal(slotuiname.."Size"):SetText(sizestr);

		getglobal(slotuiname.."CltVer"):SetText(ClientMgr:clientVersionToStr(info.clientVer));

		getglobal(slotuiname.."Pic"):SetTexture(info.thumb_path);

		if info.cloudServerID and info.cloudServerID > 0  then
			csidBtn:Show()
			getglobal(slotuiname .. "CSIDBtnName"):SetText(info.uin .. "-" .. info.cloudServerID)
		end
		getglobal(slotuiname):SetClientString(info.zip_path)
	else
		getglobal(slotuiname.."Pic"):SetTexture("");
		getglobal(slotuiname .. "CSIDBtnName"):SetText("")
		getglobal(slotuiname):SetClientString("")
	end
end

local WorldBackupMsgBox_Mode = nil;
local WorldBackupMsgBox_CurBackupPath = nil;
local WorldBackupMsgBox_CurOwid = nil;
local WorldBackupMsgBox_CallBack = nil;
--mode 标识备份类型 4云备份
function ShowBackupRestoreConfirm(info, mode, callback, notid)
	WorldBackupMsgBox_Mode = 1;
	WorldBackupMsgBox_CurBackupPath = info.zip_path;
	WorldBackupMsgBox_CurOwid = info.owid;
	getglobal("WorldBackupMsgBoxNotice1"):Show();

	if mode and mode == 4 then
		if notid then
			getglobal("WorldBackupMsgBoxNotice1"):SetText(GetS(notid, info.name));
		else
			getglobal("WorldBackupMsgBoxNotice1"):SetText(GetS(4009, info.name));
		end
		getglobal("WorldBackupMsgBoxNotice2"):Hide();
	else
		getglobal("WorldBackupMsgBoxNotice1"):SetText(GetS(4009, info.name));
		getglobal("WorldBackupMsgBoxNotice2"):Show();
	end

	getglobal("WorldBackupMsgBoxNotice3"):Show();
	getglobal("WorldBackupMsgBoxNotice2"):SetText(GetS(4010));
	getglobal("WorldBackupMsgBoxNotice3"):SetText(GetS(4011));
	getglobal("WorldBackupMsgBoxTitle"):SetText(GetS(4008));
	getglobal("WorldBackupMsgBoxEdit1"):Hide();
	getglobal("WorldBackupMsgBoxEditBkg"):Hide();
	getglobal("WorldBackupMsgBoxThumb"):Hide();
	getglobal("WorldBackupMsgBoxOkBtnLeft"):Show();
	getglobal("WorldBackupMsgBoxCancelBtnRight"):Show();
	getglobal("WorldBackupMsgBoxOkBtnRight"):Hide();
	getglobal("WorldBackupMsgBoxCancelBtnLeft"):Hide();
	getglobal("WorldBackupMsgBox"):Show();

	WorldBackupMsgBox_CallBack = nil
	if callback then
		WorldBackupMsgBox_CallBack = callback
	end
end

function ShowBackupDeleteConfirm(info, mode)
	WorldBackupMsgBox_Mode = 2;
	WorldBackupMsgBox_CurBackupPath = info.zip_path;
	WorldBackupMsgBox_CurOwid = info.owid;
	getglobal("WorldBackupMsgBoxNotice1"):Show();
	getglobal("WorldBackupMsgBoxNotice1"):SetText(GetS(4014));
	getglobal("WorldBackupMsgBoxNotice2"):Hide();
	getglobal("WorldBackupMsgBoxNotice3"):Show();
	getglobal("WorldBackupMsgBoxNotice3"):SetText(GetS(4015));
	getglobal("WorldBackupMsgBoxTitle"):SetText(GetS(4022));
	getglobal("WorldBackupMsgBoxEdit1"):Hide();
	getglobal("WorldBackupMsgBoxEditBkg"):Hide();
	getglobal("WorldBackupMsgBoxThumb"):Hide();
	getglobal("WorldBackupMsgBoxOkBtnLeft"):Show();
	getglobal("WorldBackupMsgBoxCancelBtnRight"):Show();
	getglobal("WorldBackupMsgBoxOkBtnRight"):Hide();
	getglobal("WorldBackupMsgBoxCancelBtnLeft"):Hide();
	getglobal("WorldBackupMsgBox"):Show();
end

function ShowBackupConfirm(owid, mode, title, edit, callback)
	WorldBackupMsgBox_Mode = 3;
	WorldBackupMsgBox_CurBackupPath = nil;
	WorldBackupMsgBox_CurOwid = owid;
	getglobal("WorldBackupMsgBoxNotice1"):Hide();
	getglobal("WorldBackupMsgBoxNotice2"):Hide();
	getglobal("WorldBackupMsgBoxNotice3"):Hide();
	getglobal("WorldBackupMsgBoxEdit1"):Show();
	getglobal("WorldBackupMsgBoxEditBkg"):Show();
	getglobal("WorldBackupMsgBoxThumb"):Show();
	getglobal("WorldBackupMsgBoxOkBtnLeft"):Hide();
	getglobal("WorldBackupMsgBoxCancelBtnRight"):Hide();
	getglobal("WorldBackupMsgBoxOkBtnRight"):Show();
	getglobal("WorldBackupMsgBoxCancelBtnLeft"):Show();
	getglobal("WorldBackupMsgBoxTitle"):SetText(title or GetS(4023));

	if edit then
		getglobal("WorldBackupMsgBoxEdit1"):SetText(edit);
	else
		if getglobal("WorldBackupFrameOrdinaryBackupBtn"):IsChecked() then
			getglobal("WorldBackupMsgBoxEdit1"):SetText(GetS(3731));
		else
			getglobal("WorldBackupMsgBoxEdit1"):SetText(GetS(3732));
		end
	end

	getglobal("WorldBackupMsgBox"):Show();

	local huires = Snapshot:getSnapshotTexture(owid);
	getglobal("WorldBackupMsgBoxThumb"):SetTextureHuires(huires);

	WorldBackupMsgBox_CallBack = nil
	if callback then
		WorldBackupMsgBox_CallBack = callback
	end
end

local WorldBackupMsgBoxEdit1OnFocusGainedCb = nil
function WorldBackupFrameMsgBox_OnShow()
	WorldBackupMsgBoxEdit1OnFocusGainedCb = nil
end

function WorldBackupFrameMsgBox_OnHide()
	WorldBackupMsgBox_Mode = nil;
	WorldBackupMsgBox_CurBackupPath = nil;
	WorldBackupMsgBox_CallBack = nil;

	WorldBackupMsgBoxEdit1OnFocusGainedCb = nil
end

function WorldBackupMsgBox_SetNameEditFocusGainedCb(cb)
	WorldBackupMsgBoxEdit1OnFocusGainedCb = nil
	if "function" == type(cb) then
		WorldBackupMsgBoxEdit1OnFocusGainedCb = cb
	end
end

function WorldBackupMsgBoxOkBtn_OnClick()
	local name = getglobal("WorldBackupMsgBoxEdit1"):GetText()
	--敏感词检测
	if DefMgr:checkFilterString(name) then
		ShowGameTipsWithoutFilter(GetS(9200100), 3)
		getglobal("WorldBackupMsgBoxEdit1"):Clear()
		return
	end

	if name == "" and getglobal("WorldBackupMsgBoxEdit1"):IsShown() then
		ShowGameTipsWithoutFilter(GetS(3642), 3)
		return
	end

	if WorldBackupMsgBox_CallBack then
		local name = getglobal("WorldBackupMsgBoxEdit1"):GetText();
		WorldBackupMsgBox_CallBack("left", name)
		getglobal("WorldBackupMsgBox"):Hide();
		return
	end

	if WorldBackupMsgBox_Mode == 1 then
		if WorldBackupMsgBox_CurBackupPath and CSOWorld:restoreWorldBackupByFilePath(WorldBackupMsgBox_CurBackupPath) then
			ShowGameTips(GetS(4018), 3);
		else
			ShowGameTips(GetS(4019), 3);
		end

	elseif WorldBackupMsgBox_Mode == 2 then
		if WorldBackupMsgBox_CurBackupPath then
			CSOWorld:deleteWorldBackupByFilePath(WorldBackupMsgBox_CurBackupPath);
		end
		if isEnableNewLobby and isEnableNewLobby() then
			local mapDetailInfo = GetInst("UIManager"):GetCtrl("MapDetailInfo", "uiCtrlOpenList")
			if mapDetailInfo then
				mapDetailInfo:Refresh()
			end
			if getglobal("WorldBackupFrameOrdinaryBackupBtnCheckedBG"):IsShown() then
				UpdateBackupSlots()
			elseif getglobal("WorldBackupFrameCloudServerBackupBtnCheckedBG"):IsShown() then
				UpdateCloudServerBackupSlots()
			else
				UpdateOnlineBackupSlots()
				getglobal("WorldBackupFrameSlot4"):Hide();
			end
		else
			if getglobal("WorldBackupFrameOrdinaryBackupBtnCheckedBG"):IsShown() then
				UpdateBackupSlots();
				UpdateWorld(WorldBackupMsgBox_CurOwid);
			elseif getglobal("WorldBackupFrameCloudServerBackupBtnCheckedBG"):IsShown() then
				UpdateCloudServerBackupSlots()
				UpdateWorld(WorldBackupMsgBox_CurOwid);
			else
				UpdateOnlineBackupSlots();
				getglobal("WorldBackupFrameSlot4"):Hide();
				OnlineBackupUpdateWorld(WorldBackupMsgBox_CurOwid);
			end
		end

	elseif WorldBackupMsgBox_Mode == 3 then
		local name = getglobal("WorldBackupMsgBoxEdit1"):GetText();
		if CheckFilterString(name) then return end

		if getglobal("WorldBackupFrameOrdinaryBackupBtn"):IsChecked() then
			if CSOWorld:createWorldBackup(WorldBackupMsgBox_CurOwid, name) then
				ShowGameTips(GetS(4016), 3);
			else
				ShowGameTips(GetS(4017), 3);
			end
			if isEnableNewLobby and isEnableNewLobby() then
				local mapDetailInfo = GetInst("UIManager"):GetCtrl("MapDetailInfo", "uiCtrlOpenList")
				if mapDetailInfo then
					mapDetailInfo:Refresh()
				end
				UpdateBackupSlots();
			else
				UpdateBackupSlots();
				UpdateWorld(WorldBackupMsgBox_CurOwid);
			end
		elseif getglobal("WorldBackupFrameCloudServerBackupBtnCheckedBG"):IsShown() then
			if isEnableNewLobby and isEnableNewLobby() then
				local mapDetailInfo = GetInst("UIManager"):GetCtrl("MapDetailInfo", "uiCtrlOpenList")
				if mapDetailInfo then
					mapDetailInfo:Refresh()
				end
				UpdateCloudServerBackupSlots()
			else
				UpdateCloudServerBackupSlots()
				UpdateWorld(WorldBackupMsgBox_CurOwid);
			end
		else
			if CSOWorld:createWorldBackup(WorldBackupMsgBox_CurOwid, name,true) then
				ShowGameTips(GetS(4016), 3);
			else
				ShowGameTips(GetS(4017), 3);
			end
			if isEnableNewLobby and isEnableNewLobby() then
				local mapDetailInfo = GetInst("UIManager"):GetCtrl("MapDetailInfo", "uiCtrlOpenList")
				if mapDetailInfo then
					mapDetailInfo:Refresh()
				end
				UpdateOnlineBackupSlots();
			else
				UpdateOnlineBackupSlots();
				OnlineBackupUpdateWorld(WorldBackupMsgBox_CurOwid);
			end
		end

		--备份统计
		Log("---------Backup Statistics-----------------");
		local t_ArchiveData = GetArchiveData();

		for i=1,#(t_ArchiveData) do
			local worldInfo = t_ArchiveData[i].info;
			if  worldInfo.worldid == WorldBackupMsgBox_CurOwid then

				ns_LongTimeShareMap.set_backup_time( worldInfo )  		--是否备份了自己的地图 设置分享提醒

				Log("worldInfo.worldid:" .. worldInfo.worldid .. "   " .. "WorldBackupMsgBox_CurOwid:" .. WorldBackupMsgBox_CurOwid .. "  worldInfo.worldtype:" .. worldInfo.worldtype);
				-- statisticsGameEvent(8005,"%d",worldInfo.worldtype);
			end
		end
	end

	getglobal("WorldBackupMsgBox"):Hide();
end

function WorldBackupMsgBoxEdit1_OnEnterPressed()
	WorldBackupMsgBoxOkBtn_OnClick();
end

function WorldBackupMsgBoxEdit1_OnFocusGained()
	if "function" == type(WorldBackupMsgBoxEdit1OnFocusGainedCb) then
		WorldBackupMsgBoxEdit1OnFocusGainedCb()
	end
end

function WorldBackupMsgBoxCancelBtn_OnClick()
	if WorldBackupMsgBox_CallBack then
		WorldBackupMsgBox_CallBack("right")
	end

	getglobal("WorldBackupMsgBox"):Hide();
end

--------------------------------------------- 存档备份 end ---------------------------------------------

---------------------------------------------:新地图详情页begin----------------------------------------
local t_CommentFuncData = {
	authUin = 0;
	commentObj = nil;
	nickName = "";
	black_stat = 0;
}
--地图详情页面使用mvc模式重构，为方便获取和赋local变量
function Gett_CommentFuncData()
	return t_CommentFuncData
end

--:显示工坊地图详情, 被调函数:WorksArchive_OnClick()
function ShowMiniWorksMapDetail(map, options, connoisseur_uin, userdata)
	Log("ShowMiniWorksMapDetail:");
	if map then
		Log("Detail: 111");
		options = options or {};
		-- 添加在地图内标识
		local bInGame = ClientCurGame and ClientCurGame:isInGame()
		options.showOptions = options.showOptions or {
			bHideRoomBtn = bInGame,
			bHideSingleGame = bInGame,
			bHideMultiGame = bInGame,
		}

		local wdesc = CreateWorldDescFromMap(map);
		PrintMapInfo(map);
		ArchiveWorldDesc = wdesc;
		CurArchiveMap = map;
		CurArchiveMapOptions = options;
		CurArchiveConnoisseurUin = connoisseur_uin;

	  --getglobal("MiniWorksArchiveInfoFrame"):Show();

		local param = {}
		param.ArchiveWorldDesc=ArchiveWorldDesc
		param.CurArchiveMap=CurArchiveMap
		param.CurArchiveConnoisseurUin=CurArchiveConnoisseurUin
		param.CurArchiveMapOptions=CurArchiveMapOptions
		param.msgParam = userdata and userdata.msgParam or nil -- 消息中心传递的评论id参数
		--之前userdata被写死用来作AppendReportInfo, 做个拓展
		if isEnableNewCommonSystem and isEnableNewCommonSystem() then
			if userdata then
				if userdata.from == "comment" then
					param.CommentParam = userdata.commentParam;
				else
					param.AppendReportInfo= userdata
				end
			end
		else
			param.AppendReportInfo= userdata
		end

		if GetInst("mainDataMgr"):AB_newFrameOfPlatform() then
			if GetInst("MiniUIManager") then
				if GetInst("MiniUIManager"):GetCtrl("ArchiveInfoDetail") then
					GetInst("MiniUIManager"):CloseUI("ArchiveInfoDetailAutoGen")
				end
			end
			param.fullScreen = {Type = 'IgnoreEdge'}
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", 'miniui/miniworld/c_hpm_common'})
			GetInst("MiniUIManager"):OpenUI("ArchiveInfoDetail","miniui/miniworld/ArchiveInfoDetail","ArchiveInfoDetailAutoGen",param)
		else
			GetInst("UIManager"):Open("ArchiveInfoFrameEx",param)
		end

		--保存当前地图
		MiniWorksMapShare_CurrentMap = map;
	end
end

function EndGameBackOrignOpenMapDetail()
	if EnterMainMenuInfo.MapDetailInfoParam then
		threadpool:work(function()
			local param = EnterMainMenuInfo.MapDetailInfoParam
			if GetInst("mainDataMgr"):AB_newFrameOfPlatform() then
				GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", 'miniui/miniworld/c_hpm_common'})
				GetInst("MiniUIManager"):OpenUI("ArchiveInfoDetail","miniui/miniworld/ArchiveInfoDetail","ArchiveInfoDetailAutoGen",param)
			else
				GetInst("UIManager"):Open("ArchiveInfoFrameEx",param)
			end
			EnterMainMenuInfo.MapDetailInfoParam = nil
		end)
	end
end

--:退出个人中心时重新加载地图详情页
function ReLoadMiniWorksMapDetail()
	if MiniWorksMapShare_CurrentMap then
		ShowMiniWorksMapDetail(MiniWorksMapShare_CurrentMap);
	end
end

function EndGameBackOrignOpenTopicMaps()
	if EnterMainMenuInfo.TopicMapsBackInfo then
		threadpool:work(function()
			local param = EnterMainMenuInfo.TopicMapsBackInfo
			GetInst("MiniUIManager"):OpenUI("TopicMaps", "miniui/miniworld/GameHall", "TopicMapsAutoGen", param)
			EnterMainMenuInfo.TopicMapsBackInfo = nil
		end)
	end
end

--[[===========================================新埋点=============================================]]
--mark by liya for MiniWorksArchiveInfoFrame
--新版埋点, view 统一处理
local MiniWorksArchiveInfoFrame_StandReportEventTable = {
	MINI_MAP_DETAIL_1       = {
        Close               = "MiniWorksArchiveInfoFrameCloseBtn",
        PersonInformation   = "MiniWorksArchiveInfoFrameTopHeadBtn",
        MiniDuplicate       = "MiniWorksArchiveInfoFrameTopCopyUin",
        Subscribe           = "MiniWorksArchiveInfoFrameTopTakeBtn01",
        MapReport           = "MiniWorksArchiveInfoFrameTopReportBtn",
        MapCollect          = "MiniWorksMapCommentBoxIntroduceCollectBtn",
        MapShare            = "MiniWorksMapCommentBoxIntroduceShareBtn",
        MapLike             = "MiniWorksMapCommentBoxIntroduceRewardBtn",
        ConnectButton       = "MiniWorksArchiveInfoFrameTopFilterRoomOWBtn"
    },
}
--统一埋点view
function MiniWorksArchiveInfoFrame_StandReportViewEvent()
	local event = "view"
    MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "-", event)
    MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_Comment_1", "-", event)
    
	for cID, oTable in pairs(MiniWorksArchiveInfoFrame_StandReportEventTable) do
		for oID, frameName in pairs(oTable) do
			if IsUIFrameShown(frameName) then
				MiniWorksArchiveInfoFrame_StandReportSingleEvent(cID, oID, event)
			end
		end
	end
end

--上报单个地图详情界面埋点
function MiniWorksArchiveInfoFrame_StandReportSingleEvent(cID, oID, event, eventTb)
	local sID = "12"
    standReportEvent(sID, cID, oID, event, eventTb)
end
--[[===========================================新埋点=============================================]]

function MiniWorksArchiveInfoFrame_OnHide()
	--工坊窗口返回按钮改为关闭
	--getglobal("MiniWorksFrameBackBtn"):Hide();
	--getglobal("MiniWorksFrameCloseBtn"):Show();

	--0. 使迷你工坊的滑动窗口都生效
	MiniWorksArchiveInfoFrameCommentMask_OnClick();
	SetMiniWorksBoxsDealMsg(true);
end

function MiniWorksArchiveInfoFrame_OnLoad()
	--getglobal("MiniWorksMapCommentBoxCommentFuncReportBtnNormal"):SetGray(true);
	--getglobal("MiniWorksMapCommentBoxCommentFuncReportBtn"):Disable();
end

--:工坊地图详情页
function MiniWorksArchiveInfoFrame_OnShow()
	--ui层级
	if getglobal("PlayerCenterFrame"):IsShown() then
		getglobal("MiniWorksArchiveInfoFrame"):SetFrameLevel(3000);
	else
		getglobal("MiniWorksArchiveInfoFrame"):SetFrameLevel(2600);
	end

	--评论列表相关
	t_CommentList = {};
	CurCommentTime = 0;
	t_GoodCommentList = {};
	t_ConnoisseurCommentList = {};

	--工坊窗口关闭按钮改为返回
	--getglobal("MiniWorksFrameBackBtn"):Show();
	--getglobal("MiniWorksFrameCloseBtn"):Hide();

	--当前查看的地图wid
	MiniWorksMapShare_CurrentWid = 0;
	if (not ArchiveWorldDesc) and isEnableNewLobby and isEnableNewLobby() then
		local worldid = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
		MiniWorksMapShare_CurrentWid = worldid or 0;
		local worldDesc = AccountManager:findWorldDesc(MiniWorksMapShare_CurrentWid)
		MiniWorksMapShare_CurrentUserUin = worldDesc.realowneruin or 0;
	else
		MiniWorksMapShare_CurrentWid = ArchiveWorldDesc.worldid or 0;
		--当前作者uin
		MiniWorksMapShare_CurrentUserUin = 0;
		MiniWorksMapShare_CurrentUserUin = ArchiveWorldDesc.realowneruin or 0;
	end



	--0. 则将"我的"隐藏掉
	if getglobal("MiniWorksArchiveInfoFrame"):IsShown() then
		getglobal("MiniWorksSelfCenterProductionPage"):Hide();
	end

	--0. 使迷你工坊的滑动窗口都无效, 且使自己有效
	SetMiniWorksBoxsDealMsg(false);
	getglobal("MiniWorksMapCommentBox"):setDealMsg(true);

	--1. 个人信息:
	MiniWorksMapInfoIntroduce();

	--2. 评论:
	MiniWorksCommentInfoLayoutComment();

	--加载详情
	MiniWorksLoadCommentList();

	--3. 分享、解锁按钮使不可用
	--getglobal("MiniWorksMapCommentBoxIntroduceShareBtn"):Disable();
	--getglobal("MiniWorksMapCommentBoxIntroduceShareBtnNormal"):SetGray(true);
	--getglobal("MiniWorksMapCommentBoxIntroduceShareBtnPushedBG"):SetGray(true);

	UpdateUI_WaterMark("MiniWorksArchiveInfoFrameWaterMarkFrameFont")
    getglobal("MiniWorksArchiveInfoFrame"):setUpdateTime(1.0)
    
    MiniWorksArchiveInfoFrame_StandReportViewEvent()
end

function MiniWorksArchiveInfoFrame_OnUpdate()
	UpdateUI_WaterMark("MiniWorksArchiveInfoFrameWaterMarkFrameFont")
end

--加载地图描述详情, 参考:UpdateShareArchiveInfoIntroduce().
function MiniWorksMapInfoIntroduce()
	ArchiveWorldDesc = GetCurArchiveMapInfo("ArchiveWorldDesc")
	if ArchiveWorldDesc == nil then return end
	--头像
	local rolemodel = ArchiveWorldDesc.realModel;

	if t_exhibition:CheckOtherProfileBlackStat(ArchiveWorldDesc.realowneruin) then
		getglobal("MiniWorksArchiveInfoFrameTopHeadBtnIcon"):SetTextureCentrally("ui/snap_jubao.png");
	else
        if AccountManager:getUin() == ArchiveWorldDesc.realowneruin then
            HeadCtrl:CurrentHeadIcon("MiniWorksArchiveInfoFrameTopHeadBtnIcon");
			HeadFrameCtrl:CurrentHeadFrame("MiniWorksArchiveInfoFrameTopHeadBtnIconFrame");
        else
			if ArchiveWorldDesc.realAVT ~= nil and ArchiveWorldDesc.realAVT ~= "" then
				local avt = JSON:decode(ArchiveWorldDesc.realAVT);
				HeadCtrl:SetPlayerHead("MiniWorksArchiveInfoFrameTopHeadBtnIcon",3,avt);
			else
				HeadCtrl:SetPlayerHead("MiniWorksArchiveInfoFrameTopHeadBtnIcon",2,rolemodel);
			end
			HeadFrameCtrl:SetPlayerheadFrameName("MiniWorksArchiveInfoFrameTopHeadBtnIconFrame",ArchiveWorldDesc.ownerIconFrame);
        end

	end



	if rolemodel then
		MapRewardClass:SetHeadIcon("ui/roleicons/"..rolemodel..".png");
	end

	--玩家名称
	if AccountManager:getUin() == ArchiveWorldDesc.realowneruin then
		--自己
		getglobal("MiniWorksArchiveInfoFrameTopLinkName"):Hide();
		getglobal("MiniWorksArchiveInfoFrameTopName"):Show();
		getglobal("MiniWorksArchiveInfoFrameTopName"):SetText(ReplaceFilterString(ArchiveWorldDesc.realNickName));
		getglobal("MiniWorksArchiveInfoFrameTopReportBtn"):Hide();
		getglobal("MiniWorksMapCommentBoxIntroduceCollectBtn"):Hide();
	else
		--别人
		getglobal("MiniWorksArchiveInfoFrameTopName"):Hide();
		getglobal("MiniWorksArchiveInfoFrameTopLinkName"):Show();
		getglobal("MiniWorksArchiveInfoFrameTopLinkName"):SetText(ReplaceFilterString(ArchiveWorldDesc.realNickName), 61, 69, 70);
		getglobal("MiniWorksArchiveInfoFrameTopReportBtn"):Show();
		getglobal("MiniWorksMapCommentBoxIntroduceCollectBtn"):Show();
	end

	--mini号
	local ShortUin = getShortUin(ArchiveWorldDesc.realowneruin);
	local textUin = ""..ShortUin;
	if ShortUin == 1002 then
		textUin = textUin..GetS(6065);
	end
	getglobal("MiniWorksArchiveInfoFrameTopMini"):SetText("(" .. textUin .. ")");

	if CurArchiveMap then
		getglobal("MiniWorksMapCommentBoxIntroduceMapName"):SetText(ReplaceFilterString(CurArchiveMap.name))
	else
		getglobal("MiniWorksMapCommentBoxIntroduceMapName"):SetText("");
	end

	--地图描述
	if ArchiveWorldDesc.memo == "" then
		getglobal("MiniWorksMapCommentBoxIntroduceInfo"):SetText(GetS(178));
	else
		getglobal("MiniWorksMapCommentBoxIntroduceInfo"):SetText(ReplaceFilterString(ArchiveWorldDesc.memo));
	end

	--下载人数
	if CurArchiveMap then
		getglobal("MiniWorksMapCommentBoxIntroduceDownIcon"):Show();
		getglobal("MiniWorksMapCommentBoxIntroduceDown"):Show();

		local download_num = CurArchiveMap.download_count or 0;
		if  lang_show_as_K() and download_num > 1000 then
			getglobal("MiniWorksMapCommentBoxIntroduceDown"):SetText(string.format("%0.1f", download_num/1000).. 'K');
		elseif download_num > 10000 then
			getglobal("MiniWorksMapCommentBoxIntroduceDown"):SetText(string.format("%0.1f", download_num/10000)..GetS(3841)); --X.X万
		else
			getglobal("MiniWorksMapCommentBoxIntroduceDown"):SetText(tostring(download_num));
		end
	else
		getglobal("MiniWorksMapCommentBoxIntroduceDownIcon"):Hide();
		getglobal("MiniWorksMapCommentBoxIntroduceDown"):Hide();
	end

	local play_cc = CurArchiveMap and CurArchiveMap.play_cc or 0
	getglobal("MiniWorksMapCommentBoxIntroducePlayCount"):SetText(play_cc or 0)

	--鉴赏家推荐人数
	if CurArchiveMap and CurArchiveMap.push_up3 and CurArchiveMap.push_up3 > 0 then

		getglobal("MiniWorksMapCommentBoxIntroduceLikeIcon"):Show();
		getglobal("MiniWorksMapCommentBoxIntroduceLike"):Show();

		getglobal("MiniWorksMapCommentBoxIntroduceLike"):SetText(GetS(1336, CurArchiveMap.push_up3));
	else
		getglobal("MiniWorksMapCommentBoxIntroduceLikeIcon"):Hide();
		getglobal("MiniWorksMapCommentBoxIntroduceLike"):Hide();
	end

	--标签
	local labelIcon = getglobal("MiniWorksMapCommentBoxIntroduceLabelIcon");
	local label = getglobal("MiniWorksMapCommentBoxIntroduceLabelName");
	--label类型
	local gameLabel = ArchiveWorldDesc.gameLabel;
	if gameLabel == 0 then
		gameLabel = GetLabel2Owtype(ArchiveWorldDesc.worldtype);
	end
	--设置label
	SetRoomTag(labelIcon, label, gameLabel);

	--[[
	--Tag:精选/人气
	local tagBkg = getglobal("ArchiveInfoFrameIntroduceTagBkg");
	local tagName = getglobal("ArchiveInfoFrameIntroduceTagName");
	SetRankTag(tagBkg, tagName, ArchiveWorldDesc.ownerIconParts);
	]]

	--缩略图
	if (getglobal("MiniWorksFrame"):IsShown() or getglobal("MiniWorksArchiveInfoFrame"):IsShown()) and CurArchiveMap then
		GetMapThumbnail(CurArchiveMap, "MiniWorksMapCommentBoxIntroducePic");
	else
		local huires = Snapshot:getSnapshotTexture(ArchiveWorldDesc.worldid);
		getglobal("MiniWorksMapCommentBoxIntroducePic"):SetTextureHuires(huires);
	end

	--点赞评分
	local gradeObj = getglobal("MiniWorksMapCommentBoxIntroduceGrade");
	SetArchiveGradeUI(gradeObj, ArchiveWorldDesc.creditfloat or 3);

	--更新时间
	local shareVersion = tostring(ArchiveWorldDesc.shareVersion);
	shareVersion = os.date("%Y-%m-%d    %H:%M:%S",shareVersion);
	getglobal("MiniWorksMapCommentBoxIntroduceTime"):SetText(shareVersion);

	--收藏按钮
	if (getglobal("MiniWorksFrame"):IsShown() or getglobal("MiniWorksArchiveInfoFrame"):IsShown() ) and CurArchiveMap then
		if not CurArchiveMap.fromHttp then
			getglobal("MiniWorksMapCommentBoxIntroduceCollectBtn"):Show();

			if IsMapCollected(CurArchiveMap.owid) then  --已收藏
--				getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnNormal"):SetTexUV("mngfg_btn05");
--				getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnPushedBG"):SetTexUV("mngfg_btn05");
				getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnIcon"):SetTexUV("icon_like_h")
			else  --未收藏
--				getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnNormal"):SetTexUV("mngfg_btn06");
--				getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnPushedBG"):SetTexUV("mngfg_btn06");
				getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnIcon"):SetTexUV("icon_like_n")
			end
		else
			getglobal("MiniWorksMapCommentBoxIntroduceCollectBtn"):Hide();
		end
	else
		getglobal("MiniWorksMapCommentBoxIntroduceCollectBtn"):Hide();
	end

	--筛选此图的房间
	getglobal("MiniWorksArchiveInfoFrameTopFilterRoomOWBtn"):Show();
	if CurArchiveMap.display_rank == 2 then
		getglobal("MiniWorksArchiveInfoFrameTopFilterRoomOWBtn"):Show();
--		getglobal("MiniWorksArchiveInfoFrameTopFilterRoomOWBtnSuoIcon"):Hide();
		getglobal("MiniWorksArchiveInfoFrameTopFilterRoomOWBtnNormal"):SetGray(false);
		getglobal("MiniWorksArchiveInfoFrameTopFilterRoomOWBtnPushedBG"):SetGray(false);
	else
		getglobal("MiniWorksArchiveInfoFrameTopFilterRoomOWBtn"):Show();
--		getglobal("MiniWorksArchiveInfoFrameTopFilterRoomOWBtnSuoIcon"):Hide();
		getglobal("MiniWorksArchiveInfoFrameTopFilterRoomOWBtnNormal"):SetGray(false);
		getglobal("MiniWorksArchiveInfoFrameTopFilterRoomOWBtnPushedBG"):SetGray(false);
	end

	if CurArchiveMap.worldtype == 9 then	--录像存档不能快速联机
		getglobal("MiniWorksArchiveInfoFrameTopFilterRoomOWBtn"):Hide();
	end

	--订阅按钮
	local takeBtn01 = getglobal("MiniWorksArchiveInfoFrameTopTakeBtn01");	--订阅
	local takeBtn02 = getglobal("MiniWorksArchiveInfoFrameTopTakeBtn02");	--取消订阅
	takeBtn01:Hide();
	takeBtn02:Hide();
	if ShortUin == GetMyUin() then
		--自己的地图
	else
		--别人的地图
		if ArchiveWorldDesc.ownerIconParts == 2 then
			--是精选地图.
			local fansNum = 0;
			local SubscribeNum = 0;
			local tResult = false;
			tResult, fansNum, SubscribeNum = MiniworksGetSubscribeStateByUin(ShortUin);

--			if tResult then
--				--已订阅
--				Log("MiniWorksMapInfoIntroduce: Have Subscribed");
--				takeBtn01:Hide();
--				takeBtn02:Show();
--			else
--				Log("MiniWorksMapInfoIntroduce: Dow`t Have Subscribed");
--				takeBtn01:Show();
--				takeBtn02:Hide();
--			end

			local uin = tonumber(string.sub(getglobal("MiniWorksArchiveInfoFrameTopMini"):GetText(), 2, -2)) or 0;
			if CanFollowPlayer(uin) then
				takeBtn01:Show();
				takeBtn02:Hide();
			else
				takeBtn01:Hide();
				takeBtn02:Show();
			end
		end
	end

	--funcbtn
	local funcBtnUi = getglobal("MiniWorksArchiveInfoFrameTopFuncBtn");
	if CurArchiveMap then
		funcBtnUi:Show();
		UpdateFuncBtnDownloadState(funcBtnUi, CurArchiveMap, "MiniWorksArchiveInfoFrame");
	else
		funcBtnUi();
	end

	--地图介绍翻译按钮
	MapIntroduceDeleteOldTranslation();
	if if_open_google_translate_worker_shop() then
		getglobal("MiniWorksMapCommentBoxIntroduceTranslateBtn"):Show();
		-- getglobal("MiniWorksMapCommentBoxIntroduceMapName"):SetPoint("bottom", "MiniWorksMapCommentBoxIntroducePic", "top", 0, -52);
	else
		getglobal("MiniWorksMapCommentBoxIntroduceTranslateBtn"):Hide();
		-- getglobal("MiniWorksMapCommentBoxIntroduceMapName"):SetPoint("bottom", "MiniWorksMapCommentBoxIntroducePic", "top", 0, -52);
	end

	--getglobal("MiniWorksMapCommentBoxIntroduceRewardBtn"):Hide();
	getglobal("MiniWorksMapCommentBoxIntroduceRewardBtn"):Disable();
	getglobal("MiniWorksMapCommentBoxIntroduceRewardBtn"):SetGray(false);
	getglobal("MiniWorksMapCommentBoxIntroduceRewardIcon"):Hide();
	getglobal("MiniWorksMapCommentBoxIntroduceRewardNum"):Hide();


	MapRewardClass.RequestRewardCallBack = UpdateWorksArchiveInfoReward;
	local owid = ArchiveWorldDesc.fromowid or ArchiveWorldDesc.worldid

	if CurArchiveMap and CurArchiveMap.total then
		MapRewardClass:SetMapTotlaScore(CurArchiveMap.total, CurArchiveMap.owid);
	end

	--[[设置打赏状态]]
	MapRewardClass:SetMapsReward(owid, ArchiveWorldDesc.realowneruin, ArchiveWorldDesc.realNickName,ArchiveWorldDesc.ownerIconFrame);
		
	if   gameLabel >= 100 and ArchiveWorldDesc.OpenCode and ArchiveWorldDesc.OpenCode == 1 then
		getglobal("MiniWorksMapCommentBoxIntroduceCodeBtn"):Show()
	else
		getglobal("MiniWorksMapCommentBoxIntroduceCodeBtn"):Hide()
	end

	getglobal("MiniWorksMapCommentBoxIntroduceTraceBtn"):Hide()
	-- if CurArchiveMap and CurArchiveMap.pwid and CurArchiveMap.pwid > 0 and CurArchiveMap.gwid and CurArchiveMap.gwid > 0 then
	-- 	getglobal("MiniWorksMapCommentBoxIntroduceTraceBtn"):Show()
	-- else
	-- 	getglobal("MiniWorksMapCommentBoxIntroduceTraceBtn"):Hide()
	-- end

	local _tempTypeDescStrIDs = {34407, 34406};
	local _tempTypeDescID = _tempTypeDescStrIDs[CurArchiveMap.temptype];
	local _tempTypeStr = _tempTypeDescID and GetS(_tempTypeDescID) or "";
	getglobal("MiniWorksMapCommentBoxIntroduceTempTypeTagText"):SetText(_tempTypeStr);
	getglobal("MiniWorksMapCommentBoxIntroduceTempTypeTagText"):Show();

	if CurArchiveMap and CurArchiveMap.temptype and CurArchiveMap.temptype > 0 and ArchiveWorldDesc.worldtype ~= 9 then
		getglobal("MiniWorksMapCommentBoxIntroduceTempTypeTag"):Show();
	else
		getglobal("MiniWorksMapCommentBoxIntroduceTempTypeTag"):Hide();
	end

	
end

function UpdateWorksArchiveInfoReward()
	--[[
	local state = MapRewardClass:GetRewardState(ArchiveWorldDesc.worldid);
	local rewardBtn = getglobal("MiniWorksMapCommentBoxIntroduceRewardBtn");
	local rewardBtnIcon = getglobal("MiniWorksMapCommentBoxIntroduceRewardBtnIcon");

	if ArchiveWorldDesc.realowneruin ~= AccountManager:getUin() then
		--rewardBtn:Show();
		getglobal("MiniWorksMapCommentBoxIntroduceRewardBtn"):Enable();
		if state == 0 then
			rewardBtnIcon:SetTexUV("icon_reward_n.png");
		elseif state == 1 then
			rewardBtnIcon:SetTexUV("icon_reward_h.png");
		elseif state == 2 then
			--rewardBtn:Hide();
			getglobal("MiniWorksMapCommentBoxIntroduceRewardBtn"):Disable();
			getglobal("MiniWorksMapCommentBoxIntroduceRewardBtn"):SetGray(false);
		end
	else
		--rewardBtn:Hide();
	end

	--打赏值
	if MapRewardClass:GetMapTotlaScore() then
		getglobal("MiniWorksMapCommentBoxIntroduceRewardNum"):SetText(MapRewardClass:GetMapTotlaScore());
		getglobal("MiniWorksMapCommentBoxIntroduceRewardIcon"):Show();
		getglobal("MiniWorksMapCommentBoxIntroduceRewardNum"):Show();
	end

	if not MapRewardClass:IsOpen() then
		--rewardBtn:Hide();
		getglobal("MiniWorksMapCommentBoxIntroduceRewardBtn"):Disable();
		getglobal("MiniWorksMapCommentBoxIntroduceRewardBtn"):SetGray(false);
		getglobal("MiniWorksMapCommentBoxIntroduceRewardIcon"):Hide();
		getglobal("MiniWorksMapCommentBoxIntroduceRewardNum"):Hide();
	end
	--]]
	if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx") then
		GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):UpdateWorksArchiveInfoReward();
	end
	-- if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
	-- 	GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") :UpdateWorksArchiveInfoReward();
	-- end
	SandboxLua.eventDispatcher:Emit(nil, "UPDATE_REWARD", SandboxContext())
end
 
function UpdateArchiveInfoCollectBtnState(isCollect,count)
	--[[
	if isCollect then  --已收藏
--		getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnNormal"):SetTexUV("mngfg_btn05");
--		getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnPushedBG"):SetTexUV("mngfg_btn05");
		getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnIcon"):SetTexUV("icon_like_h")
	else  --未收藏
--		getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnNormal"):SetTexUV("mngfg_btn06");
--		getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnPushedBG"):SetTexUV("mngfg_btn06");
		getglobal("MiniWorksMapCommentBoxIntroduceCollectBtnIcon"):SetTexUV("icon_like")
	end
	--]]
	if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx") then
		GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):UpdateArchiveInfoCollectBtnState(isCollect,count);
	end
	--if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
	--	GetInst("MiniUIManager"):GetCtrl("ExitGameMenu"):UpdateArchiveInfoCollectBtnState(isCollect,count);
	--end
	SandboxLua.eventDispatcher:Emit(nil, "UPDATE_COLLECT", SandboxContext()
															:SetData_Number("count", tonumber(count) or 0)
															:SetData_Bool("isCollect",isCollect))
end


function InitArchiveInfoLikeBtnIconState(like,dislike)
	if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):InitArchiveInfoLikeBtnIconState(like,dislike);
	elseif GetInst("UIManager"):GetCtrl("MapDetailInfo","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("MapDetailInfo"):InitArchiveInfoLikeBtnIconState(like,dislike);
	end
	--if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
	--	GetInst("MiniUIManager"):GetCtrl("ExitGameMenu"):InitArchiveInfoLikeBtnIconState(like,dislike);
	--end
	if like ~= nil and dislike ~= nil then
		SandboxLua.eventDispatcher:Emit(nil, "INIT_LIKESTATE", SandboxContext()
		:SetData_Bool("like", like)
		:SetData_Bool("dislike",dislike))
	else
		SandboxLua.eventDispatcher:Emit(nil, "INIT_LIKESTATE", SandboxContext())
	end
	
end

--添加点赞
function ArchiveInfoAddLikeMap(like_count,dislike_count)
	if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):AddLikeMap(like_count,dislike_count);
	elseif GetInst("UIManager"):GetCtrl("MapDetailInfo","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("MapDetailInfo"):AddLikeMap(like_count,dislike_count);
	end
--	if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
--		GetInst("MiniUIManager"):GetCtrl("ExitGameMenu"):AddLikeMap(like_count,dislike_count);
--	end

	--local context = SandboxContext():SetData_Number("like_count", like_count):SetData_Number("like_count",dislike_count)
	SandboxLua.eventDispatcher:Emit(nil, "ADD_LIKE",  SandboxContext()
													:SetData_Number("like_count", like_count)
													:SetData_Number("dislike_count",dislike_count))
end

--取消点赞
function ArchiveInfoCancelLikeMap(like_count,dislike_count)
	if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):CancelLikeMap(like_count,dislike_count);
	elseif GetInst("UIManager"):GetCtrl("MapDetailInfo","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("MapDetailInfo"):CancelLikeMap(like_count,dislike_count);
	end
--	if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
--		GetInst("MiniUIManager"):GetCtrl("ExitGameMenu"):CancelLikeMap(like_count,dislike_count);
--	end
	--local context = SandboxContext():SetData_Number("like_count", like_count):SetData_Number("like_count",dislike_count)
	SandboxLua.eventDispatcher:Emit(nil, "CANCEL_LIKE", SandboxContext()
														:SetData_Number("like_count", like_count)
														:SetData_Number("dislike_count",dislike_count))
end

--添加不喜欢
function ArchiveInfoAddDislikeMap(like_count,dislike_count)
	if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):AddDislikeMap(like_count,dislike_count);
	elseif GetInst("UIManager"):GetCtrl("MapDetailInfo","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("MapDetailInfo"):AddDislikeMap(like_count,dislike_count);
	end
	--if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
	--	GetInst("MiniUIManager"):GetCtrl("ExitGameMenu"):AddDislikeMap(like_count,dislike_count);
	--end
	SandboxLua.eventDispatcher:Emit(nil, "ADD_DISLIKE", SandboxContext()
														:SetData_Number("like_count", like_count)
														:SetData_Number("dislike_count",dislike_count))
end

--取消不喜欢
function ArchiveInfoCancelDislikeMap(like_count,dislike_count)
	if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):CancelDislikeMap(like_count,dislike_count);
	elseif GetInst("UIManager"):GetCtrl("MapDetailInfo","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("MapDetailInfo"):CancelDislikeMap(like_count,dislike_count);
	end
	--if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
	--	GetInst("MiniUIManager"):GetCtrl("ExitGameMenu"):CancelDislikeMap(like_count,dislike_count);
	--end
	SandboxLua.eventDispatcher:Emit(nil, "CANCEL_DISLIKE", SandboxContext()
															:SetData_Number("like_count", like_count)
															:SetData_Number("dislike_count",dislike_count))
end

--更新分享数量
function ArchiveInfoUpdataShareCountMap(share_count, mapid)
	mapid = tonumber(mapid)
	if not mapid then
		return
	end
	if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx") then
		GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):UpdataShareCountMap(share_count, mapid);
	end
	--if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
	--	GetInst("MiniUIManager"):GetCtrl("ExitGameMenu"):UpdataShareCountMap(share_count);
	--end
	SandboxLua.eventDispatcher:Emit(
		nil, 
		"UPDATE_SHARECOUNT", 
		SandboxContext():SetData_Number("share_count", share_count):SetData_Number("map_id", mapid)
	)
end

--关闭按钮
function MiniWorksArchiveInfoFrameCloseBtn_OnClick()
	MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "Close", "click") --mark by liya 新埋点
	JsBridge:PopFunction();

	--SetMiniWorksBoxsDealMsg(true);
	if getglobal("MiniWorksFrame"):IsShown() and HasUIFrame("MiniWorksCommendDetail") and not getglobal("MiniWorksCommendDetail"):IsShown() then
		if (not HasUIFrame("MapTemplateCommend")) or (not getglobal("MapTemplateCommend"):IsShown()) then
			ShowCurWorksFrame(true);--关闭详情页时刷新
		end
	end
	GetInst("UIManager"):Close("ArchiveInfoFrameEx")
	if PEC_DynamicJumpOut ==true then  --从个人中心跳转过来 关闭还需要跳转回去
		PEC_DynamicJumpOut = false
		PEC_BackFormOtherFrame();
    end
end

--查看个人信息
function MiniWorksArchiveInfoFrameSelfInfoBtn_OnClick()
	--暂时跟点击头像功能一样
	--NewArchiveInfoFrameIntroduceLinkName_OnClick();

	--进入"我的作品"页面
	OpenProductionPage(ArchiveWorldDesc.realowneruin, false);
end

--举报存档
function MiniWorksArchiveInfoFrameTopReportBtn_OnClick()
    local cid = ArchiveWorldDesc and ArchiveWorldDesc.fromowid and tostring(ArchiveWorldDesc.fromowid) or "0"
    MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "MapReport", "click", {cid = cid}) --mark by liya 新埋点

    if ArchiveWorldDesc == nil then return end
	local uin = ArchiveWorldDesc.realowneruin;
	local nickname = ArchiveWorldDesc.realNickName;
	local wid = ArchiveWorldDesc.fromowid;

	-- InformControl:AddInformInfo(101,
	-- 	uin,
	-- 	nickname,
	-- 	wid,
	-- 	GetS(10517) .. "#c1ec832" .. GetS(10556))
	-- 	:Enqueue();

	GetInst("ReportManager"):OpenReportView({
		tid = GetInst("ReportManager"):GetTidTypeTbl().map,
		op_uin = uin,
		wid = wid,
	})
	-- body
	--SetReportOptionFrame("map", ArchiveWorldDesc.realowneruin, ArchiveWorldDesc.realNickName, ArchiveWorldDesc.fromowid );
end

function MiniWorksArchiveInfoFrameTopFuncBtn_OnClick()
	--[[
	if getglobal("MiniWorksArchiveInfoFrame"):IsShown() and CurArchiveMap then
		local funcBtnUi = getglobal("MiniWorksArchiveInfoFrameTopFuncBtn");
        MapFuncBtn_OnClick(funcBtnUi, CurArchiveMap, CurArchiveMapOptions, "MiniWorksArchiveInfoFrame");
    end
	--]]
	if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx") then
		GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):FuncBtnClicked();
	end
end

local g_CommentGroupInfo = {
		{name = "MiniWorksMapCommentBoxConnoisseurComment", top_offset = 26, title = 1304, height=0, commentY = 106, comment_num = 0},	--精彩评论
		{name = "MiniWorksMapCommentBoxWonderfulComment", top_offset = 26, title = 6061, height=0, commentY = 106, comment_num = 0},	--精彩评论
		{name = "MiniWorksMapCommentBoxNewComment", top_offset = 26, title = 6062, height=0, commentY = 106, comment_num = 0}, -- 最新评论
	};

--评论布局
function MiniWorksCommentInfoLayoutComment()
	local offsetY = 0;			--每条间的间隔
	local offsetX = 0;			--X偏移

	for j = 1, 3 do
		local parent_ui_name = g_CommentGroupInfo[j].name;
		local top_offset = g_CommentGroupInfo[j].top_offset;		--标题高度
		local title = g_CommentGroupInfo[j].title;				--标题, 表中的文字ID
		local CommentHeight = g_CommentGroupInfo[j].commentY;	--每条的高

		--标题
		if title then
			local text = GetS(title);
			getglobal(parent_ui_name.."Title"):SetText(text);
		end

		for i = 1, 999 do
			local CommentUIName = parent_ui_name.."Comment"..i;	--评论条目的名字

			if not HasUIFrame(CommentUIName) then
				break;
			end

			local Comment = getglobal(CommentUIName);
			Comment:SetPoint("topleft", parent_ui_name, "topleft", offsetX, top_offset + offsetY + (i-1) * CommentHeight);
		end

		--先把评论框隐藏掉, 加载完再显示
		getglobal(parent_ui_name):Hide();
	end
end

--加载评论列表
function MiniWorksLoadCommentList()
	--拉取评论列表:直接用老的接口
	t_GoodCommentList = {};
	t_ConnoisseurCommentList = {};
	t_CommentList = {};
	CurCommentTime = 0;
	ArchiveInfoFrameCommentBtn_OnClick();
end

--请求地图评论列表回调,参考:RespMapCommentList();
function RespNewMapInfoCommentList(t_list)
	if getglobal("LoadLoopFrame"):IsShown() then
		ShowLoadLoopFrame(false)
	end

	if type(t_list) ~= 'table' then
		--"请检查网络链接"
		ShowGameTips(GetS(771), 3);
		return;
	end

	local hasMore = false;
	local reset = false;

	if #(t_list) <= 0 then
		if #(t_CommentList) > 0 then	--没有更多评论
			--ShowGameTips(GetS(770), 3);
		else				--没有评论
			--ShowGameTips(GetS(769), 3);
			getglobal("MiniWorksMapCommentBoxNoComment"):Show();
		end
	else
		if #(t_list) >= MiniWorksMap_CommentNumForOnce then
			hasMore = true;
		end

		if #(t_CommentList) == 0 then
			reset = true;
		end
	end

	--鉴赏家评论列表：t_ConnoisseurCommentList
	if t_list.expert and #t_list.expert > 0 then
		local ExpertList = t_list.expert;
		for i=1, #ExpertList do
			if ExpertList[i].nickname ~= nil then
				table.insert(t_ConnoisseurCommentList, {
													uin=ExpertList[i].uin,
													star=ExpertList[i].star,
													msg=unescape(ExpertList[i].msg),
													nickName=unescape(ExpertList[i].nickname),
													headIndex=ExpertList[i].uin_icon,
													headFrameId=ExpertList[i].head_frame_id,
													HasAvatar=ExpertList[i].HasAvatar,
													time=ExpertList[i].create_time,
													prize_count=ExpertList[i].prize_count,
													tread_count = ExpertList[i].tread_count,
													black_stat = ExpertList[i].black_stat,
													tip = ExpertList[i].tip,
													audit_tag = (t_list[i] and t_list[i].open_svr) or 1,
												}
							);
			end
		end
	end

	--精彩评论列表:t_GoodCommentList
	if t_list.top and #t_list.top > 0 then
		local TopList = t_list.top;
		for i=1, #TopList do
			if TopList[i].nickname ~= nil then
				table.insert(t_GoodCommentList, {
													uin=TopList[i].uin,
													star=TopList[i].star,
													msg=unescape(TopList[i].msg),
													nickName=unescape(TopList[i].nickname),
													headIndex=TopList[i].uin_icon,
													headFrameId=TopList[i].head_frame_id,
													HasAvatar=TopList[i].HasAvatar,
													time=TopList[i].create_time,
													prize_count=TopList[i].prize_count,
													tread_count = TopList[i].tread_count,
													black_stat = TopList[i].black_stat,
													tip = TopList[i].tip,
													audit_tag = (t_list[i] and t_list[i].open_svr) or 1,
												}
							);
			end
		end
	end

	for i=1, #(t_list) do
		if t_list[i].nickname ~= nil then
			table.insert(t_CommentList, {
											uin=t_list[i].uin,
											star=t_list[i].star,
											msg=unescape(t_list[i].msg),
											nickName=unescape(t_list[i].nickname),
											headIndex=t_list[i].uin_icon,
											headFrameId=t_list[i].head_frame_id,
											HasAvatar=t_list[i].HasAvatar,
											time=t_list[i].create_time,
											prize_count=t_list[i].prize_count,
											tread_count = t_list[i].tread_count,
											black_stat = t_list[i].black_stat,
											tip = t_list[i].tip,
											audit_tag = t_list[i].open_svr or 1,
										}
						);

			if CurCommentTime == 0 or CurCommentTime > t_list[i].create_time then
				CurCommentTime = t_list[i].create_time;
			end
		end
	end

	--清理已经被删除的评论
	MiniWorksDeleteCommentInHistory(t_ConnoisseurCommentList);
	MiniWorksDeleteCommentInHistory(t_GoodCommentList);
	MiniWorksDeleteCommentInHistory(t_CommentList);

	--更新评论UI,
	--MiniWorksUpdateCommentInfoUI(t_list);
	MiniWorksUpdateCommentInfoUI(t_CommentList, hasMore, reset);
end

-- 更新评论UI
--t_list:评论列表,参考:UpdateShareArchiveInfoComment();
function MiniWorksUpdateCommentInfoUI(t_list, hasMore, reset)
	local num = #t_list;		--评论总数
	local name = "Comment";
	local offsetY = 10;

	--"更多评论"按钮
	if hasMore then
		getglobal("MiniWorksMapCommentBoxMore"):Show();

		--评论大于150条, 多余的不要再显示了.
		if num >= Comment_Max_Num then
			getglobal("MiniWorksMapCommentBoxMore"):Hide();
		end
	else
		getglobal("MiniWorksMapCommentBoxMore"):Hide();
	end

	--各类评论条数统计
	g_CommentGroupInfo[1].comment_num = #t_ConnoisseurCommentList;
	g_CommentGroupInfo[2].comment_num = #t_GoodCommentList;
	g_CommentGroupInfo[3].comment_num = num;

	for i = 1, 3 do
		local parent_ui_name = g_CommentGroupInfo[i].name;
		local parentUI = getglobal(parent_ui_name);
		local comment_num = g_CommentGroupInfo[i].comment_num;

		Log("comment_num"..i.."="..comment_num);

		--有评论才显示评论外框
		if comment_num <= 0 or comment_num == nil then
			parentUI:Hide();
		else
			parentUI:Show();

			--没有评论框隐藏
			getglobal("MiniWorksMapCommentBoxNoComment"):Hide();
		end

		--设置大小
		g_CommentGroupInfo[i].height = g_CommentGroupInfo[i].top_offset + comment_num * g_CommentGroupInfo[i].commentY;
		-- local section_width = parentUI:GetWidth();
		--Log("(:)width="..section_width..", height = "..g_CommentGroupInfo[i].height);
		--parentUI:SetSize(section_width, g_CommentGroupInfo[i].height);
		local section_height = g_CommentGroupInfo[i].top_offset;

		for j = 1, 200 do
			--评论条目的名字
			local CommentUIName = parent_ui_name..name..j;

			if not HasUIFrame(CommentUIName) then
				break;
			end

			local UIObj = getglobal(CommentUIName);

			if j <= comment_num then
				--显示评论条目
				UIObj:Show();

				if i == 1 then
					--鉴赏家评论
					MiniWorksUpdateGroupComment(CommentUIName, t_ConnoisseurCommentList[j], 1);
					print("MiniWorksUpdateGroupComment1", t_ConnoisseurCommentList[j])
				elseif i == 2 then
					--精彩评论
					--Log("LLTEST:good comment"..j);
					MiniWorksUpdateGroupComment(CommentUIName, t_GoodCommentList[j], 2);
					print("MiniWorksUpdateGroupComment2", t_GoodCommentList[j])
				elseif i == 3 then
					--最新评论
					MiniWorksUpdateGroupComment(CommentUIName, t_list[j], 3);
					print("MiniWorksUpdateGroupComment3", t_list[j])
				end

				UIObj:SetPoint("top", parent_ui_name, "top", 0, section_height);
				section_height = section_height + UIObj:GetHeight();
			else
				UIObj:Hide();
			end
		end

		parentUI:SetHeight(section_height);
	end

	--更新滑动窗口高.
	local AllFrames = {
		"MiniWorksMapCommentBoxConnoisseurComment",
		"MiniWorksMapCommentBoxWonderfulComment",
		"MiniWorksMapCommentBoxNewComment",
		"MiniWorksMapCommentBoxMore",
	};

	--重置滑动框
	if reset then
		getglobal("MiniWorksMapCommentBox"):resetOffsetPos();
	end

	local plane_name = "MiniWorksMapCommentBoxPlane";
	local plane_obj = getglobal(plane_name);

	local y = 10;
	local totalHeight = 0;

	for k = 1, #AllFrames do
		local ui_name = AllFrames[k];
		local ui_obj = getglobal(ui_name);
		local ui_height = ui_obj:GetHeight();

		ui_obj:SetPoint("top", plane_name, "top", 0,  totalHeight);
		if ui_obj:IsShown() then
			--Log("(:height)"..k.."="..ui_height);
			totalHeight = totalHeight + y + ui_height;
		end
	end

	local plane_width = plane_obj:GetWidth();
	local containerHeight = getglobal("MiniWorksMapCommentBox"):GetRealHeight();
	totalHeight = clamp(totalHeight, containerHeight, nil);
	plane_obj:SetSize(plane_width, totalHeight);
end

--更新一条评论
function MiniWorksUpdateGroupComment(frame_name, info, commentTyp)
	if "" ~= frame_name and nil ~= frame_name and nil ~= info then
		local name 	= getglobal(frame_name.."Name");
		local head = getglobal(frame_name.."HeadBtnIcon");
		local headFrame = getglobal(frame_name.."HeadBtnIconFrame");
		local time = getglobal(frame_name.."Time");
		local content = getglobal(frame_name.."Content");
		local zan = getglobal(frame_name.."Zan");
		local tread = getglobal(frame_name .. "Tread");
		local delete = getglobal(frame_name .. "DeleteBtn");
		local checklogo = getglobal(frame_name .. "CheckLogo");
		local checkText = getglobal(frame_name .. "CheckText");
		local auditTag = getglobal(frame_name .. "AuditTag")
		--[[:参考这一段
		for i=1, #(t_list) do
			if t_list[i].nickname ~= nil then
				table.insert(t_CommentList, {uin=t_list[i].uin, star=t_list[i].star,msg=unescape(t_list[i].msg),
					nickName=unescape(t_list[i].nickname), headIndex=t_list[i].uin_icon,time=t_list[i].create_time});

				if CurCommentTime == 0 or CurCommentTime > t_list[i].create_time then
					CurCommentTime = t_list[i].create_time;
				end
			end
		end
		]]

		--uin
		local CommentObj = getglobal(frame_name);
		CommentObj:SetClientUserData(0, info.uin);
        CommentObj:SetClientString(info.nickName);
        -- 埋点需求增加判断当前是那种评论（1鉴赏家评论，2精彩评论，3普通评论）
        CommentObj:SetClientUserData(1, commentTyp);

		--名字
		local NameText = ReplaceFilterString(info.nickName);
		if info.tip == 3 or info.tip == 4 then
			-- name:SetText(NameText, 255, 109, 37);
			G_VipNamePreFixEntrency(name, info.uin, NameText, {r = 255, g = 109, b = 37})
		else
			-- name:SetText(NameText, 101, 116, 118);
			G_VipNamePreFixEntrency(name, info.uin, NameText, {r = 101, g = 116, b = 118})
		end

		--头像
		if info.HasAvatar and info.HasAvatar >= 1 then
			HeadCtrl:SetPlayerHeadByUin(head:GetName(),info.uin,info.headIndex,nil,info.HasAvatar);
		else
			HeadCtrl:SetPlayerHead(head:GetName(),2,info.headIndex);
		end

        HeadFrameCtrl:SetPlayerheadFrameName(headFrame:GetName(),info.headFrameId);
		-- 内容
		local ContentText =string.gsub(info.msg, "\n", " ");
		ContentText = MiniWorksComment_CleanContent(ContentText);
		-- local height = content:GetTextExtentWidth(ContentText);
		-- if height/900 > 2 then
		-- 	CommentObj:SetSize(1244, 100);
		-- 	content:SetSize(900, 60);
		-- else
		-- 	CommentObj:SetSize(1244, 80);
		-- 	content:SetSize(900, 40);
		-- end

		if info and info.black_stat == 1 then
			content:Hide();
			checklogo:Show();
			checkText:Show();
		else
			if info.isShowTranslated ~= nil and info.isShowTranslated and info.translateText ~= "" then
				local text = DefMgr:filterString(info.translateText);
				content:SetText(text, 61, 69, 70);
			else
				ContentText = DefMgr:filterString(ContentText);
				content:SetText(ContentText, 61, 69, 70);
			end
			checklogo:Hide();
			checkText:Hide();
		end

		local lineCount = content:GetTextLines();
		print("lineCount = ", lineCount);
		local frameHeight = 110;
		if lineCount > 2 then
			frameHeight = 110 + 20 * (lineCount - 2);
		end
		CommentObj:SetHeight(frameHeight);

		--时间
		local nTime = info.time;
		local TimeText = os.date("%Y", nTime).."-"..os.date("%m", nTime).."-"..os.date("%d", nTime);
		time:SetText(TimeText);

		--点赞数
		local nZan = info.prize_count or 0;
		local ZanText = "("..nZan..")";
		zan:SetText(ZanText);

		--"踩"数量
		local nTread = info.tread_count or 0;
		local TreadText = "(" .. nTread .. ")";
		tread:SetText(TreadText);

		--是否点赞过赞
		local zanBtnNormal = getglobal(frame_name.."PrizeBtnNormal");
		local zanBtnPushed = getglobal(frame_name.."PrizeBtnPushedBG");
		if get_prize_comment_history(MiniWorksMapShare_CurrentWid, info.uin) then
			--点过赞
			zan:SetTextColor(1, 194, 16)
			zanBtnNormal:SetTexUV("icon_thumb_h");
			zanBtnPushed:SetTexUV("icon_thumb_h");
		else
			--没点过赞
			zan:SetTextColor(101, 116, 118)
			zanBtnNormal:SetTexUV("icon_thumb_n");
			zanBtnPushed:SetTexUV("icon_thumb_n");
		end

		--是否"踩"过
		local treadBtnNormal = getglobal(frame_name .. "TreadBtnNormal");
		local treadBtnPushed = getglobal(frame_name .. "TreadBtnPushedBG");
		if get_prize_comment_history(MiniWorksMapShare_CurrentWid, info.uin, 1) then
			tread:SetTextColor(1, 194, 16)
			treadBtnNormal:SetTexUV("icon_thumb_h");
			treadBtnPushed:SetTexUV("icon_thumb_h");
		else
			tread:SetTextColor(101, 116, 118)
			treadBtnNormal:SetTexUV("icon_thumb_n");
			treadBtnPushed:SetTexUV("icon_thumb_n");
		end

		--删除按钮, gm账号、或地图作者, 才显示
		--[[
		if CSOWorld:isGmCommandsEnabled() or (ArchiveWorldDesc.realowneruin == GetMyUin()) then
			delete:Show();
		else
			delete:Hide();
		end
		]]

		--Log("()");

		if info.audit_tag and tonumber(info.audit_tag) == 0 then
			auditTag:Show()
		else
			auditTag:Hide()
		end
	end
end

-- 去掉评论内容中的闪烁和颜色.
function MiniWorksComment_CleanContent(content)
	--Log("LLcontent1 = " .. content);

	if false then
		--1. 方法一: 直接去掉所有#
		content = string.gsub(content, "#", "");
	else
		--2. 方法二: 去掉所有#和后面的参数
		local formatString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
		local cChar = "";
		local cRep = "";

		for i = 1, #formatString do
			cChar = string.sub(formatString, i, i);
			cRep = "#" .. cChar;

			if string.find(content, cRep) then
				--替换成"".
				content = string.gsub(content, cRep, "");
			end
		end
	end

	--Log("LLcontent2 = " .. content);

	return content;
end

-- 点击评论条目的名字, 进入个人中心
function MiniWorksCommentName_OnClick()
    local commentType = this:GetParentFrame():GetClientUserData(1)
    local clientID = this:GetParentFrame():GetClientID()
    local slot = commentType * 10 + clientID
    MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_Comment_1", "PersonInformation", "click", {slot = slot}) --mark by liya 新埋点

	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3);
		return;
	end

	local uin = this:GetParentFrame():GetClientUserData(0);
	if uin == AccountManager:getUin() then
		ShowGameTips(GetS(775), 3);
		return;
	end
	--Log("(:uin = "..uin);
	-- if BuddyManager:requestBuddyWatch(uin) then
	-- 	--getglobal("MiniWorksArchiveInfoFrame"):Hide();
	-- 	SearchWatchUin = uin;
	-- end
	GetInst("UIManager"):Close("ArchiveInfoFrameEx")
	OpenNewPlayerCenter(uin);
	SearchWatchUin = uin;

	if getglobal("MiniWorksFrame"):IsShown() then
		MiniWorksFrameCloseBtn_OnClick()
		if HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
			getglobal("MiniWorksFrame"):Hide()
		end
	end
end

--设置点赞数
function MiniWorksSetPrizeNum(frame_name, bIsAdd, bTread)
	--bIsAdd == true: 点赞+1;
	--bIsAdd == false: 点赞-1;
	--bTread = true: 踩; else, 赞
	Log("MiniWorksSetPrizeNum:");

	local zanObj = nil;
	if bTread then
		--踩
		zanObj = getglobal(frame_name .. "Tread");
	else
		--赞
		zanObj = getglobal(frame_name .. "Zan");
	end

	local strNumText = zanObj:GetText();
	local strNum = string.sub(strNumText, 2, -2);	--去掉括号, 只取数字.
	local nNum = tonumber(strNum) or 0;

	print("old num = " .. nNum);

	if bIsAdd then
		nNum = nNum + 1;
	else

	end

	local ZanText = "("..nNum..")";
	zanObj:SetText(ZanText);
end

--点赞回调
function MiniWorksRespPrizeMap(ret, userdata)
	Log("(:MiniWorksRespPrizeMap):");
    if ret == nil then return end
	if nil ~= ret.ret then
		if 0 == ret.ret then
			--点赞成功
			Log("OK, ret = 0");

			if userdata and userdata.wid and userdata.comment_uin and userdata._CommentObj then
				local frame_obj = userdata._CommentObj;
				local frame_name = frame_obj:GetName();
				local zan = getglobal(frame_name .. "Zan")
				local zanBtnNormal = getglobal(frame_name.."PrizeBtnNormal");
				local zanBtnPushed = getglobal(frame_name.."PrizeBtnPushedBG");
				local tread = getglobal(frame_name .. "Tread")
				local treadBtnNormal = getglobal(frame_name .. "TreadBtnNormal");
				local treadBtnPushed = getglobal(frame_name .. "TreadBtnPushedBG");

				if userdata._dc == 1 then
					--赞
					add_prize_comment_history( userdata.wid, userdata.comment_uin )
					zan:SetTextColor(1, 194, 16)
					zanBtnNormal:SetTexUV("icon_thumb_h");
					zanBtnPushed:SetTexUV("icon_thumb_h");

					--点赞数+1.
					MiniWorksSetPrizeNum(frame_name, true);
				elseif userdata._dc == 2 then
					--踩
					add_prize_comment_history( userdata.wid, userdata.comment_uin, 1)
					tread:SetTextColor(1, 194, 16)
					treadBtnNormal:SetTexUV("icon_thumb_h");
					treadBtnPushed:SetTexUV("icon_thumb_h");

					--"踩"数量+1.
					MiniWorksSetPrizeNum(frame_name, true, true);
				else

				end


			end
		elseif 1 == ret.ret then
			--已经点过赞
			Log("OK, ret = 1");
		else
			Log("Error, ret = ");
		end
	end
end

--点赞评论/踩评论
--dc == 1: 点赞; dc == 2: 踩
function MiniWorksReqPrizeMap(uin, fn_wid, comment_uin, CommentObj, dc)
	if  uin and fn_wid and comment_uin then
		local url =  mapservice.getserver() .. "/miniw/map/?act=prize_map_comment";
		url = url.."&fn="..fn_wid;
		url = url.."&comment_uin="..comment_uin;
		url = url.."&dc="..dc;

		if string.find(CommentObj:GetName(), "ConnoisseurComment") then
			url = url.."&expert=1";
		end


		url = UrlAddAuth(url);
		Log("(:MiniWorksReqPrizeMap, url = )"..url);

		if dc and dc == 1 then
			if get_prize_comment_history(fn_wid, comment_uin) then
				--已经点过赞.
				Log("Have Prized! Can`t Prize Again!");
				return;
			end
		elseif dc and dc == 2 then
			if get_prize_comment_history(fn_wid, comment_uin, 1) then
				--已经"踩"过.
				Log("Have Tread! Can`t Tread Again!");
				return;
			end
		else

		end

		local userdata = {wid = fn_wid, comment_uin = comment_uin, _CommentObj = CommentObj, _dc = dc};
		ns_http.func.rpc(url, MiniWorksRespPrizeMap, userdata, nil, true);
	end
end

--点赞评论/踩评论
--dc == 1: 点赞; dc == 2: 踩X
function MiniWorksReqPrizeMapX(uin, fn_wid, comment_uin, CommentObj, dc)
	if  uin and fn_wid and comment_uin then
		local url =  mapservice.getserver() .. "/miniw/map/?act=prize_map_comment";
		url = url.."&fn="..fn_wid;
		url = url.."&comment_uin="..comment_uin;
		url = url.."&dc="..dc;

		if string.find(CommentObj:GetName(), "ConnoisseurComment") then
			url = url.."&expert=1";
		end


		url = UrlAddAuth(url);
		Log("(:MiniWorksReqPrizeMapX, url = )"..url);

		if dc and dc == 1 then
			if get_prize_comment_history(fn_wid, comment_uin) then
				--已经点过赞.
				Log("Have Prized! Can`t Prize Again!");
				return;
			end
		elseif dc and dc == 2 then
			if get_prize_comment_history(fn_wid, comment_uin, 1) then
				--已经"踩"过.
				Log("Have Tread! Can`t Tread Again!");
				return;
			end
		else

		end

		local userdata = {wid = fn_wid, comment_uin = comment_uin, _CommentObj = CommentObj, _dc = dc};
		ns_http.func.rpc(url, MiniWorksRespPrizeMap, userdata, nil, true);
	end
end

--点赞按钮
function MiniWorksCommentPrizeBtn_OnClick()
	if ns_data.IsGameFunctionProhibited("mc", 10583, 10584) then
		return;
	end

	local map = MiniWorksMapShare_CurrentMap;
	if map and map.black_stat then
		if map.black_stat == 1 or map.black_stat == 2 then
			ShowGameTipsWithoutFilter(GetS(10570));
			return;
		end
	end
	local uin = AccountManager:getUin();
	local fn_wid = MiniWorksMapShare_CurrentWid;
	local comment_uin = this:GetParentFrame():GetClientUserData(0);	--此条评论的作者uin
	local CommentObj = this:GetParentFrame();

	if CheckMiniWorksArchiveInfoCommentState(comment_uin) ~= 0 then
		ShowGameTipsWithoutFilter(GetS(10573));
		return;
	end

    MiniWorksReqPrizeMapX(uin, fn_wid, comment_uin, CommentObj, 1);
    
        
    local commentType = this:GetParentFrame():GetClientUserData(1)
    local clientID = this:GetParentFrame():GetClientID()
    local slot = commentType * 10 + clientID
    --MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_Comment_1", "CommentLike", "click", {slot = slot}) --mark by liya 新埋点
	--需求方要求修改成新的上报(其它地方相同)，已在MapDetailInfoCtrl里上报
end

--"踩"按钮
function MiniWorksCommentTreadBtn_OnClick()
	if ns_data.IsGameFunctionProhibited("mc", 10583, 10584) then
		return;
	end

	local map = MiniWorksMapShare_CurrentMap;
	if map and map.black_stat then
		if map.black_stat == 1 or map.black_stat == 2 then
			ShowGameTipsWithoutFilter(GetS(10570));
			return;
		end
	end
	local uin = AccountManager:getUin();
	local fn_wid = MiniWorksMapShare_CurrentWid;
	local comment_uin = this:GetParentFrame():GetClientUserData(0);	--此条评论的作者uin
	local CommentObj = this:GetParentFrame();

	if CheckMiniWorksArchiveInfoCommentState(comment_uin) ~= 0 then
		ShowGameTipsWithoutFilter(GetS(10573));
		return;
	end

    MiniWorksReqPrizeMapX(uin, fn_wid, comment_uin, CommentObj, 2);
    
    local commentType = this:GetParentFrame():GetClientUserData(1)
    local clientID = this:GetParentFrame():GetClientID()
    local slot = commentType * 10 + clientID
    --MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_Comment_1", "CommentDislike", "click", {slot = slot}) --mark by liya 新埋点
end

--删除评论按钮
function MiniWorksCommentDeleteBtn_OnClick()
	local uin = AccountManager:getUin() or get_default_uin();
	local fn_wid = MiniWorksMapShare_CurrentWid;
	local comment_uin = this:GetParentFrame():GetClientUserData(0);	--此条评论的作者uin
	local CommentObj = this:GetParentFrame();

	local url =  mapservice.getserver() .. "/miniw/map/?act=rm_map_comment";
	url = url.."&fn="..fn_wid;
	url = url.."&comment_uin="..comment_uin;
	url = UrlAddAuth(url);

	local auth2 = "";
	if CSOWorld:isGmCommandsEnabled() then
		--gm账号要额外加上auth2.
		--sprintf(auth2buf, "w%lld#miniw_op_907#%u#%u", owid, curtimestamp, uin);
		auth2 = auth2 .. fn_wid .. "#miniw_op_907#" .. os.time() .. "#" .. uin;
		Log("before md5 auth2 = " .. auth2);
		auth2 = gFunc_getmd5(auth2);
		url = url .. "&auth2=" .. auth2;
	end

	Log("(MiniWorksCommentDeleteBtn_OnClick: url = )"..url);

	--local userdata = {wid = fn_wid, comment_uin = comment_uin, _CommentObj = CommentObj};
	ns_http.func.rpc(url, MiniWorksRespDeleteComment, nil, nil, true);

	--删除的评论的信息记录起来, 因为服务器有缓存, 不是立即删除.
	table.insert(t_DeleteCommentHistory, {owid = fn_wid, uin = comment_uin});
end

--删除评论回调
function MiniWorksRespDeleteComment(ret, userdata)
	Log("MiniWorksRespDeleteComment:");
	Log("ret:");

	if ret and ret.ret and ret.ret == 0 then
		--清理已经被删除的评论
		MiniWorksDeleteCommentInHistory(t_ConnoisseurCommentList);
		MiniWorksDeleteCommentInHistory(t_GoodCommentList);
		MiniWorksDeleteCommentInHistory(t_CommentList);

		--冲洗拉取评论列表
		MiniWorksUpdateCommentInfoUI(t_CommentList, nil, false);
		--MiniWorksLoadCommentList();
	end
end

--删选出评论列表中被删除的评论
function MiniWorksDeleteCommentInHistory(commentList)
	if commentList and #commentList > 0 and t_DeleteCommentHistory and #t_DeleteCommentHistory > 0 then
		Log("t_DeleteCommentHistory = ");

		--Log("commentList = ");

		--需要对table做删除的时候, 注意从后往前遍历.
		for i = #commentList, 1, -1 do
			local uin = commentList[i].uin;
			local owid = MiniWorksMapShare_CurrentWid;
			Log("i = " .. i .. ", uin = " .. uin);

			for j = 1, #t_DeleteCommentHistory do
				if (uin == t_DeleteCommentHistory[j].uin) and (owid == t_DeleteCommentHistory[j].owid) then
					--该评论已被删除
					Log("Delete Comment Is: owid = " .. owid .. ", uin = " .. uin);
					table.remove(commentList, i);

					break;
				end
			end
		end
	end
end

function MNGF_CommentTemplate_OnClick()
    local commentType = this:GetClientUserData(1)
    local clientID = this:GetClientID()
    local slot = commentType * 10 + clientID
    MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_Comment_1", "CommentCard", "click", {slot = slot}) --mark by liya 新埋点

	local authUin = this:GetClientUserData(0);
	local reportBtn = getglobal("MiniWorksMapCommentBoxCommentFuncReportBtn");
	local deleteBtn = getglobal("MiniWorksMapCommentBoxCommentFuncDelBtn");
	local copyBtn = getglobal("MiniWorksMapCommentBoxCommentFuncCopyBtn")
	local translateBtn = getglobal("MiniWorksMapCommentBoxCommentFuncTranslateBtn");

	t_CommentFuncData.authUin = authUin;
	t_CommentFuncData.commentObj = this;

	if t_CommentFuncData.authUin == AccountManager:getUin() then
		getglobal("MiniWorksMapCommentBoxCommentFuncReportBtnNormal"):SetGray(true);
		getglobal("MiniWorksMapCommentBoxCommentFuncReportBtn"):Disable();
	else
		getglobal("MiniWorksMapCommentBoxCommentFuncReportBtnNormal"):SetGray(false);
		getglobal("MiniWorksMapCommentBoxCommentFuncReportBtn"):Enable();
	end

	if CheckMiniWorksArchiveInfoCommentState(authUin) == 1 then
		ShowGameTipsWithoutFilter(GetS(10573));
		return;
	end

	if (not ArchiveWorldDesc) and isEnableNewLobby and isEnableNewLobby() then
		local worldid = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
		local worldInfo = AccountManager:findWorldDesc(worldid)
		ArchiveWorldDesc = worldInfo
		ArchiveWorldDescWorldId  = ArchiveWorldDesc.worldid
	end

	if CSOWorld:isGmCommandsEnabled() or (ArchiveWorldDesc.realowneruin == GetMyUin() and not string.find(this:GetName(), "ConnoisseurComment") ) or ( getExpert().stat == 2 and authUin == GetMyUin() ) then
		getglobal("MiniWorksMapCommentBoxMask"):Show();
		local uiName = this:GetName();
		getglobal("MiniWorksMapCommentBoxCommentFunc"):SetPoint("bottomright", uiName, "top", 130, 20);

		if if_open_google_translate_worker_shop() then

			t_CommentFuncData.authUin = authUin;
			t_CommentFuncData.commentObj = this;

			if string.find(this:GetName(), "ConnoisseurComment") then
				getglobal("MiniWorksMapCommentBoxCommentFunc"):SetClientUserData(0, 1);
			else
				getglobal("MiniWorksMapCommentBoxCommentFunc"):SetClientUserData(0, 0);
			end
			--getglobal("MiniWorksMapCommentBoxCommentFunc"):SetSize(360,114);

			reportBtn:Show();
			deleteBtn:Show();
			copyBtn:SetAnchorOffset(25,2);
			copyBtn:Show();
			translateBtn:Show();

		else
			t_CommentFuncData.authUin = authUin;
			t_CommentFuncData.commentObj = this;

			if string.find(this:GetName(), "ConnoisseurComment") then
				getglobal("MiniWorksMapCommentBoxCommentFunc"):SetClientUserData(0, 1);
			else
				getglobal("MiniWorksMapCommentBoxCommentFunc"):SetClientUserData(0, 0);
			end
			--getglobal("MiniWorksMapCommentBoxCommentFunc"):SetSize(180,114);
			reportBtn:Show();
			deleteBtn:Show();
			copyBtn:Show();
			translateBtn:Hide();
		end
		getglobal("MiniWorksMapCommentBoxCommentFunc"):Show();
	else
		local uiName = this:GetName();
		getglobal("MiniWorksMapCommentBoxCommentFunc"):SetPoint("bottomright", uiName, "top", 130, 20);
		getglobal("MiniWorksMapCommentBoxMask"):Show();
		getglobal("MiniWorksMapCommentBoxCommentFunc"):Show();
		--getglobal("MiniWorksMapCommentBoxCommentFunc"):SetSize(90,114);
		reportBtn:Show();

		if if_open_google_translate_worker_shop() then
			t_CommentFuncData.authUin = authUin;
			t_CommentFuncData.commentObj = this;

			--getglobal("MiniWorksMapCommentBoxCommentFunc"):SetSize(270,114);
			deleteBtn:Hide();
			copyBtn:SetAnchorOffset(-150,2);
			copyBtn:Show();
			translateBtn:Show();
		else
			reportBtn:Show();
			deleteBtn:Hide();
			copyBtn:Show();
			translateBtn:Hide();
		end
	end

	--根据实际情况调整四个按钮的位置--------------------------------------
	local childBtnList = {	"MiniWorksMapCommentBoxCommentFuncReportBtn",
							"MiniWorksMapCommentBoxCommentFuncDelBtn",
							"MiniWorksMapCommentBoxCommentFuncCopyBtn",
							"MiniWorksMapCommentBoxCommentFuncTranslateBtn",
						};

	local index = 0;
	local offsetX = 26
	for i = 1, #childBtnList do
		local btn = getglobal(childBtnList[i]);
		if btn:IsShown() then
			btn:SetPoint("left", "MiniWorksMapCommentBoxCommentFunc", "left", offsetX, -16);
			index = index + 1;
			offsetX = offsetX + btn:GetWidth() + 26;
		end
	end

	--新存档兼容
	if isEnableNewLobby and isEnableNewLobby() then 
		getglobal("MiniWorksMapCommentBoxCommentFunc"):SetSize(offsetX, 114);
	end 
	----------------------------------------------------------------------------
end

function MiniWorksArchiveInfoFrameCommentMask_OnClick()
	getglobal("MiniWorksMapCommentBoxCommentFunc"):Hide();
end

----------------------------------------------------MiniWorksArchiveInfoFrameCommentFunc----------------------
function MiniWorksArchiveInfoFrameCommentFunc_OnHide()
	getglobal("MiniWorksMapCommentBoxMask"):Hide();
end

--举报评论
function MiniWorksArchiveInfoFrameCommentFuncReportBtn_OnClick()
	if isEnableNewLobby() and ArchiveWorldDesc and ArchiveWorldDesc.worldid ~= AccountManager:getUin() then
		standReportEvent("4", "MINI_MAPINFO_NODOWMLOAD_REVIEW", "Report", "click", {cid=tostring(ArchiveWorldDesc.worldid)})
	end
	getglobal("MiniWorksMapCommentBoxCommentFunc"):Hide();
	local comment_uin = t_CommentFuncData.authUin;	--此条评论的作者uin
	local CommentObj = t_CommentFuncData.commentObj;

	Log("comment_uin = " .. comment_uin);

	if CommentObj then
		-- InformControl:AddInformInfo(104,
		-- 	comment_uin,
		-- 	CommentObj:GetClientString(),
		-- 	ArchiveWorldDesc.fromowid,
		-- 	GetS(10517) .. "#c1ec832" .. GetS(10558))
		-- 	:Enqueue();

		GetInst("ReportManager"):OpenReportView({
			tid = GetInst("ReportManager"):GetTidTypeTbl().map_comment,
			op_uin = comment_uin,
			nickname = CommentObj:GetClientString(),
			wid = ArchiveWorldDesc.fromowid,
		})
		-- Log("1111")
		-- local nickName = CommentObj:GetClientString();
		-- Log("comment_uin = " .. comment_uin);
		-- Log("nickName = " .. nickName);
		-- SetReportOptionFrame("comment", comment_uin, nickName);
    end
    
    local commentType = CommentObj and CommentObj:GetClientUserData(1) or 0
    local clientID = CommentObj and CommentObj:GetClientID() or 0
    local slot = commentType * 10 + clientID
    --MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_Comment_1", "CommentReport", "click", {slot = slot}) --mark by liya 新埋点
	
	--新存档兼容
	if isEnableNewLobby and isEnableNewLobby() and IsUIFrameShown("MapDetailInfo") then 
		GetInst("UIManager"):GetCtrl("MapDetailInfo"):ReportWithMapId("MINI_MAPINFO_UPLOAD_REVIEW", "Report","Click")
	end 
end

function MiniWorksArchiveInfoFrameCommentFuncDelBtn_OnClick()
	MessageBox(5, GetS(1333), function(btn)
		if btn == 'left' then
			getglobal("MiniWorksMapCommentBoxCommentFunc"):Hide();
			local expert = nil;
			if getglobal("MiniWorksMapCommentBoxCommentFunc"):GetClientUserData(0) == 1 then
				expert = 1;
			end

			local uin = AccountManager:getUin() or get_default_uin();
			local fn_wid = MiniWorksMapShare_CurrentWid;
			local comment_uin = t_CommentFuncData.authUin;	--此条评论的作者uin
			local CommentObj = t_CommentFuncData.commentObj;

			local url =  mapservice.getserver() .. "/miniw/map/?act=rm_map_comment";
			url = url.."&fn="..fn_wid;
			url = url.."&comment_uin="..comment_uin;
			if expert then
				url = url.."&expert=1";
			end
			url = UrlAddAuth(url);

			local auth2 = "";
			if CSOWorld:isGmCommandsEnabled() then
				--gm账号要额外加上auth2.
				--sprintf(auth2buf, "w%lld#miniw_op_907#%u#%u", owid, curtimestamp, uin);
				auth2 = auth2 .. fn_wid .. "#miniw_op_907#" .. os.time() .. "#" .. uin;
				Log("before md5 auth2 = " .. auth2);
				auth2 = gFunc_getmd5(auth2);
				url = url .. "&auth2=" .. auth2;
			end

			Log("(MiniWorksCommentDeleteBtn_OnClick: url = )"..url);

			--local userdata = {wid = fn_wid, comment_uin = comment_uin, _CommentObj = CommentObj};
			ns_http.func.rpc(url, MiniWorksRespDeleteComment, nil, nil, true);

			--删除的评论的信息记录起来, 因为服务器有缓存, 不是立即删除.
			table.insert(t_DeleteCommentHistory, {owid = fn_wid, uin = comment_uin});
		end
	end);
end

--校验迷你工坊评论状态  0正常 1审核中 2 违规
function CheckMiniWorksArchiveInfoCommentState(comment_uin)
	if t_CommentList and #t_CommentList > 0 then
		for i=1,#t_CommentList do
			if t_CommentList[i].uin == comment_uin then
				if t_CommentList[i].black_stat == 1 then
					return 1;
				end
			end
		end
	end

	if t_GoodCommentList and #t_GoodCommentList > 0 then
		for i=1,#t_GoodCommentList do
			if t_GoodCommentList[i].uin == comment_uin then
				if t_GoodCommentList[i].black_stat == 1 then
					return 1;
				end
			end
		end
	end

	if t_ConnoisseurCommentList and #t_ConnoisseurCommentList > 0 then
		for i=1,#t_ConnoisseurCommentList do
			if t_ConnoisseurCommentList[i].uin == comment_uin then
				if t_ConnoisseurCommentList[i].black_stat == 1 then
					return 1;
				end
			end
		end
	end

	return 0;
end

--copy
function MiniWorksArchiveInfoFrameCommentFuncCopyBtn_OnClick()
	if isEnableNewLobby() and ArchiveWorldDesc and ArchiveWorldDesc.worldid ~= AccountManager:getUin() then
		standReportEvent("4", "MINI_MAPINFO_NODOWMLOAD_REVIEW", "Copy", "click", {cid=tostring(ArchiveWorldDesc.worldid)})
	end

	local comment_uin = t_CommentFuncData.authUin;	--此条评论的作者uin
	local CommentObj = t_CommentFuncData.commentObj;

	if t_CommentList and #t_CommentList > 0 then
		for i=1,#t_CommentList do
			if t_CommentList[i].uin == comment_uin then
				local ContentText =string.gsub(t_CommentList[i].msg, "\n", " ");
				ClientMgr:clickCopy(ContentText);
				ShowGameTips(GetS(739), 3);
				getglobal("MiniWorksMapCommentBoxCommentFunc"):Hide();
				return;
			end
		end
	end

	if t_GoodCommentList and #t_GoodCommentList > 0 then
		for i=1,#t_GoodCommentList do
			if t_GoodCommentList[i].uin == comment_uin then
				local ContentText =string.gsub(t_GoodCommentList[i].msg, "\n", " ");
				ClientMgr:clickCopy(ContentText);
				ShowGameTips(GetS(739), 3);
				getglobal("MiniWorksMapCommentBoxCommentFunc"):Hide();
				return;
			end
		end
	end

	if t_ConnoisseurCommentList and #t_ConnoisseurCommentList > 0 then
		for i=1,#t_ConnoisseurCommentList do
			if t_ConnoisseurCommentList[i].uin == comment_uin then
				local ContentText =string.gsub(t_ConnoisseurCommentList[i].msg, "\n", " ");
				ClientMgr:clickCopy(ContentText);
				ShowGameTips(GetS(739), 3);
				getglobal("MiniWorksMapCommentBoxCommentFunc"):Hide();
				return;
			end
		end
	end
    getglobal("MiniWorksMapCommentBoxCommentFunc"):Hide();
    
    local commentType = CommentObj and CommentObj:GetClientUserData(1) or 0
    local clientID = CommentObj and CommentObj:GetClientID() or 0
    local slot = commentType * 10 + clientID
    --MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_Comment_1", "CommentDuplicate", "click", {slot = slot}) --mark by liya 新埋点
	--新存档兼容
	if isEnableNewLobby and isEnableNewLobby() and IsUIFrameShown("MapDetailInfo") then 
		GetInst("UIManager"):GetCtrl("MapDetailInfo"):ReportWithMapId("MINI_MAPINFO_UPLOAD_REVIEW", "Copy","Click")
	end 

end

--translate
function MiniWorksArchiveInfoFrameCommentFuncTranslateBtn_OnClick()
	local comment_uin = t_CommentFuncData.authUin;	--此条评论的作者uin
	local CommentObj = t_CommentFuncData.commentObj;

	if t_CommentList and #t_CommentList > 0 then
		for i =1, #t_CommentList do
			if t_CommentList[i].uin == comment_uin then
				if t_CommentList[i].translateText ~= nil and t_CommentList[i].translateText ~= "" then --已翻译
					if t_CommentList[i].isShowTranslated then
						t_CommentList[i].isShowTranslated = false;
					else
						t_CommentList[i].isShowTranslated = true;
					end
				else
					local context = string.gsub(t_CommentList[i].msg, "\n", " ");
					local translateText = Google_Language_Translate(context,get_game_lang_str());
					if translateText ~= "" then
						t_CommentList[i].translateText = translateText;
						t_CommentList[i].isShowTranslated = true;
					else
						ShowGameTips(GetS(2037),3);
					end
				end

				break;
			end
		end
	end


	if t_GoodCommentList and #t_GoodCommentList > 0 then
		for i =1, #t_GoodCommentList do
			if (t_GoodCommentList[i].uin == comment_uin) then
				if t_GoodCommentList[i].translateText ~= nil and t_GoodCommentList[i].translateText ~= "" then --已翻译
					if t_GoodCommentList[i].isShowTranslated then
						t_GoodCommentList[i].isShowTranslated = false;
					else
						t_GoodCommentList[i].isShowTranslated = true;
					end
				else
					local context = string.gsub(t_GoodCommentList[i].msg, "\n", " ");
					local translateText = Google_Language_Translate(context,get_game_lang_str());
					if translateText ~= "" then
						t_GoodCommentList[i].translateText = translateText;
						t_GoodCommentList[i].isShowTranslated = true;

					else
						ShowGameTips(GetS(2037),3);
					end
				end
				break;
			end
		end
	end

	if t_ConnoisseurCommentList and #t_ConnoisseurCommentList > 0 then
		for i =1, #t_ConnoisseurCommentList do
			if (t_ConnoisseurCommentList[i].uin == comment_uin) then
				if t_ConnoisseurCommentList[i].translateText ~= nil and t_ConnoisseurCommentList[i].translateText ~= "" then --已翻译
					if t_ConnoisseurCommentList[i].isShowTranslated then
						t_ConnoisseurCommentList[i].isShowTranslated = false;
					else
						t_ConnoisseurCommentList[i].isShowTranslated = true;
					end
				else
					local context = string.gsub(t_ConnoisseurCommentList[i].msg, "\n", " ");
					local translateText = Google_Language_Translate(context,get_game_lang_str());
					if translateText ~= "" then
						t_ConnoisseurCommentList[i].translateText = translateText;
						t_ConnoisseurCommentList[i].isShowTranslated = true;
					else
						ShowGameTips(GetS(2037),3);
					end

				end

				break;
			end
		end
	end
	MiniWorksUpdateCommentInfoUI(t_CommentList, nil, false);--翻译过后刷新评论
	getglobal("MiniWorksMapCommentBoxCommentFunc"):Hide();

end

-- 分享地图
function ArchiveInfoFrameIntroduceShareBtn_OnClick()
	local function share()
		Log("MiniWorksMapShare_CurrentUserUin：" .. MiniWorksMapShare_CurrentUserUin);
		if AccountManager:getUin() == MiniWorksMapShare_CurrentUserUin then
			SetShareScene("map|1");
		else
			SetShareScene("map|2");
		end

		local worldDesc = AccountManager:findWorldDesc(MiniWorksMapShare_CurrentWid);
		local map = MiniWorksMapShare_CurrentMap;

		local pic_name = map.download_thumb_md5 .. ".png_"
		if type(map.download_thumb_url) == 'string' and #map.download_thumb_url>=10 then
			pic_name = ns_advert.func.trimUrlFile(map.download_thumb_url) .. "_"
		end
		local imgPath = ClientMgr:getDataDir() .. "data/http/thumbs/" .. pic_name
		local url = "http://www.miniworldgame.com/openMiniWorld.html?type=m&i=" .. tostring(map.owid);
		local title = "";
		local connoisseurCount = tonumber(map.push_up3);
		local content = "";
		if  connoisseurCount > 0 then
			content = GetS(1501, map.name, map.download_count, map.push_up3);
		else
			content = GetS(1500, map.name, map.download_count);
		end
		connoisseurCount = nil;
		SetShareData(imgPath, url, title, content);

		local tShareParams = {};
		tShareParams.shareType = t_share_data.ShareType.MAP;
		tShareParams.fromowid = MiniWorksMapShare_CurrentWid;
		t_share_data:SetMiniShareParameters(tShareParams);

		SetMiniWorkShareFrame(map);
		ShareToDynamic:SetActionParameter(25,map.owid); --设置游戏内动态分享的跳转参数
		GetInst("PlayerCenterDynamicsManager"):SetAction(25,map.owid,map.name)
		--if ClientMgr.isPC and  ClientMgr:isPC() then
		--	MiniwShare("", "");
		--else
		--	SetMiniWorkShareFrame(map);
		--end
	end
	local worldDesc = AccountManager:findWorldDesc(MiniWorksMapShare_CurrentWid)
	if worldDesc then
		local mapOwnerUin = AccountManager:findWorldDesc(MiniWorksMapShare_CurrentWid).owneruin
		local selfUin = AccountManager:getUin()
		if mapOwnerUin == selfUin then
			if ShareArchiveInfoFrameCanShare(true,GetS(344)) then
				share()
			end
		else
			share()
		end
	else
		share()
    end
    
    local cid = MiniWorksMapShare_CurrentWid and tostring(MiniWorksMapShare_CurrentWid) or "0"
    MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "MapShare", "click", {cid = cid}) --mark by liya 新埋点
	GetInst("UserTaskInterface"):UserTaskEventReport("ShareMaps", 1)
end

--[[地图打赏]]
function ArchiveInfoFrameIntroduceRewardBtn_OnClick()
	local state = MapRewardClass:GetRewardState(ArchiveWorldDesc.worldid);
	if state == 0 then
		--[[设置打赏状态]]
		MapRewardClass:SetMapsReward(MiniWorksMapShare_CurrentWid, MiniWorksMapShare_CurrentUserUin, ArchiveWorldDesc.realNickName,ArchiveWorldDesc.ownerIconFrame);
		ArchiveGradeFrameRewardBtnClicked();
	elseif state == 1 then
		ShowGameTips(GetS(21784));
    end
    
    local cid = ArchiveWorldDesc and ArchiveWorldDesc.worldid and tostring(ArchiveWorldDesc.worldid) or "0"
    MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "MapLike", "click", {cid = cid}) --mark by liya 新埋点
end

function MiniWorksShareMapFrameBackBtn_OnClick()
	getglobal("MiniWorksShareMapFrame"):Hide();
	t_share_data:ShowNextRewardDisplay();
end

--旧版：地图分享好友框
--新版：兼容皮肤、角色、坐骑分享
function MiniWorksShareMapFrame_OnShow()
	local szTitle = MiniWorksShareMapFrame_GetTitle()

	getglobal("MiniWorksShareMapFrameTitle"):SetText(szTitle);
	--好友信息
	MiniWorksShareMapLoadFriendInfo();

	--滑动窗口重叠, 使地图信息面板的滑动窗口无效
	getglobal("MiniWorksMapCommentBox"):setDealMsg(false);
end

function MiniWorksShareMapFrame_GetTitle()
	local ShareType = t_share_data.ShareType;
	local tShareParams = t_share_data:GetMiniShareParameters();
	tShareParams.shareType = tShareParams.shareType or ShareType.TEXT;
	local szTitle = GetS(1070);
	if tShareParams.shareType == ShareType.MAP then
		szTitle = GetS(6057);

	elseif tShareParams.shareType == ShareType.SKIN or tShareParams.shareType == ShareType.CHAMELEON then
		szTitle = GetS(6074) .. szTitle;

	elseif tShareParams.shareType == ShareType.RIDE then
		szTitle = GetS(3621) .. szTitle;

	elseif tShareParams.shareType == ShareType.ROLE then
		szTitle = GetS(3127) .. szTitle;

	elseif tShareParams.shareType == ShareType.AVATAR then
		szTitle = GetS(3126) .. szTitle;

	elseif tShareParams.shareType == ShareType.SCREENSHOT then


	elseif tShareParams.shareType == ShareType.BATTLE_VICTORY then
		szTitle = GetS(6057);

	elseif tShareParams.shareType == ShareType.BATTLE_FAILURE then
		szTitle = GetS(6057);

	elseif tShareParams.shareType == ShareType.ACHIEVE then
		szTitle = GetS(20608);

	else
		szTitle = GetS(1070);

	end
	return szTitle
end

function MiniWorksShareMapFrame_OnHide()
	getglobal("MiniWorksMapCommentBox"):setDealMsg(true);
	t_share_data:ShowNextRewardDisplay();
end

function MiniWorksShareMapLoadFriendInfo()
	local getglobal = _G.getglobal;
	local FriendNum = 0;
	if friendservice.enabled then
		FriendNum = #friendservice.myfriends - 1;
	else
		FriendNum = BuddyManager:getBuddyNum();
	end

	--好友数据排序
	table.sort(friendservice.myfriends, MyFriendListSorter)
	--置顶
    FriendTopSort(friendservice.myfriends)

	--没有好友, 显示空白页
	local nothingBkgObj = getglobal("MiniWorksShareMapFrameNoThingBkg");
	local nothingTxtObj = getglobal("MiniWorksShareMapFrameNoThingTxt");
	if FriendNum <= 0 then
		nothingBkgObj:Show();
		nothingTxtObj:Show();
	else
		nothingBkgObj:Hide();
		nothingTxtObj:Hide();
	end

	local topOffset = 0;
	local offsetY = 10;
	local ArchiveHeight = 109;
	local totalHeight = topOffset + offsetY;
	local planeName = "MiniWorksShareMapFrameBoxPlane";

	local inc = 0;
	for i = 1, 200 do
		local ArchiveName = nil;
		local ArchiveObj = nil;

		ArchiveName = "MiniWorksShareMapFrame".."Archive"..i;

		if not HasUIFrame(ArchiveName) then
			break;
		end

		--好友信息
		local buddyDetail = nil;
		if not friendservice.enabled then
			buddyDetail = BuddyManager:getBuddyDetail(i-1);
		else
			
			buddyDetail = friendservice.myfriends[i + inc];
			if buddyDetail and buddyDetail.uin == GetMiniCaptainUin() then 
				inc = inc + 1;
				buddyDetail = friendservice.myfriends[i + inc]; 
			end

			if buddyDetail and buddyDetail.needpull and buddyDetail.needpull == 1 then
				buddyDetail.needpull = 2
				local code, ret = QueryGriendInfo(buddyDetail.uin)
				if code == ErrorCode.OK then
					OnFriendInfo(ret)
				end
			end
		end

		ArchiveObj = getglobal(ArchiveName);

		if i <= FriendNum then
			ArchiveObj:Show();

			ArchiveObj:SetPoint("top", "MiniWorksShareMapFrameBoxPlane", "top", 0,  totalHeight);
			totalHeight = totalHeight + offsetY + ArchiveHeight;
			--加载好友信息
			--1. 头像
			local headIcon = getglobal(ArchiveName.."HeadBtn".."Icon");
			local btnHeadFrame = getglobal(ArchiveName.."HeadBtn".."IconFrame");

			if not friendservice.enabled then
				local headIndex = RoleSkin_Helper:GetPlayerHeadID(buddyDetail.model, buddyDetail.skinid)
				headIcon:SetTexture("ui/roleicons/"..headIndex..".png");
			else
				UpdateFriendHead(headIcon:GetName(), btnHeadFrame:GetName(), buddyDetail);
			end

			-- if not friendservice.enabled then
			-- 	local headIndex = buddyDetail.model;
			-- 	local skinModel = buddyDetail.skinid;
			-- 	if skinModel > 0 then
			-- 		local skinDef = RoleSkinCsv:get(skinModel);
			-- 		if skinDef ~= nil then
			-- 			headIndex = skinDef.Head;
			-- 		end
			-- 	end
			-- 	headIcon:SetTexture("ui/roleicons/"..headIndex..".png");
			-- else
			-- 	local head = GetFriendHeadIconIndex(buddyDetail);
			-- 	headIcon:SetTexture("ui/roleicons/"..head..".png");

			-- 	if buddyDetail.headurl and buddyDetail.headurl ~= "" then
			-- 		local cacheFilePath = friendservice.downloadThumbnailRoot..GetCacheFileNameFromUrl(buddyDetail.headurl);
			-- 		DownloadThumbnail({buddyDetail.headurl}, cacheFilePath, headIcon:GetName());
			-- 	end
			-- end

			-- 名字
			local nameObj = getglobal(ArchiveName.."Name");
			G_VipNamePreFixEntrency(nameObj, buddyDetail.uin, ReplaceFilterString(buddyDetail.name or ""), {r = 61, g = 69, b = 70})

			--迷你号
			local uiUin = getglobal(ArchiveName.."Mini");
			uiUin:SetText("(" .. buddyDetail.uin .. ")");

			--性别
			local gender = buddyDetail.gender or 0;
			local myfriends = friendservice.myfriends;
			for i = 1, #myfriends do
				if myfriends[i].uin and myfriends[i].uin == buddyDetail.uin then
					print("MiniWorksShareMapLoadFriendInfo(): myfriends[i] = ", myfriends[i]);
					gender = myfriends[i].gender or 2;
				end
			end
			local genderIcon = getglobal(ArchiveName .. "GenderIcon");
			if gender == 0 then --男
				genderIcon:SetTexUV("icon_male")
			elseif gender == 1 then --女
				genderIcon:SetTexUV("icon_female")
			else --默认
				genderIcon:SetTexUV("icon_sex")
			end

			--增加性别开关
			if not if_show_gender() then
				genderIcon:Hide()
			end

			--分享按钮:使可点击
			local shareBtnName = ArchiveName.."ShareBtn";
			local shareBtnObj = getglobal(shareBtnName);
			local shareBtnNarmal = getglobal(shareBtnName.."Normal");
			local shareBtnPushed = getglobal(shareBtnName.."PushedBG");
			shareBtnObj:Show()
			shareBtnObj:Enable();
			shareBtnNarmal:SetGray(false);
			shareBtnPushed:SetGray(false);
			--置顶
			if buddyDetail.uin and IsFriendTop(buddyDetail.uin) then
				getglobal(ArchiveName.."Bkg"):SetTextureHuiresXml("ui/mobile/texture0/common.xml")
				getglobal(ArchiveName.."Bkg"):SetTextureTemplate("TemplateFriendBkg")
				getglobal(ArchiveName.."BkgMask"):SetTextureHuiresXml("ui/mobile/texture0/common.xml")
                getglobal(ArchiveName.."BkgMask"):SetTexUV("img_borad_map_ray01")
			else
				getglobal(ArchiveName.."Bkg"):SetTextureHuiresXml("ui/mobile/texture2/common.xml")
				getglobal(ArchiveName.."Bkg"):SetTextureTemplate("TemplateBigBkg6")
				getglobal(ArchiveName.."BkgMask"):SetTextureHuiresXml("ui/mobile/texture2/room.xml")
                getglobal(ArchiveName.."BkgMask"):SetTexUV("img_borad_map_ray")
			end
		else
			ArchiveObj:Hide();
		end

		--滑动窗口高
		if totalHeight > 440 then
			local plane = getglobal(planeName);
			plane:SetSize(plane:GetWidth(), totalHeight);
		end
	end
end

--新版api：分享界面
function ShowShareFrame()
	if (ClientMgr.isPC and ClientMgr:isPC()) or (false and IsAndroidBlockark() and IsProtectMode())then
		--13岁保护模式：直接拉起
		getglobal("MiniWorksShareMapFrame"):Show();
	else
		getglobal("ShareOnOptionMenuFrame"):Show();
	end
end

--新版api：分享总按钮
function ShareToBuddiesTemplateShareBtn_OnClick()
	MiniWorksShareMapArchiveTemplateShareBtn_OnClick();
end

--新版api：请求发送消息给好友
function ReqSendShareMessage(src_uin, des_uin, text, callback, userdata)
	ReqSendShareMapMessage(src_uin, des_uin, text, callback, userdata);
end

--新版api：回调发送消息，参考函数:RespSendChatMessage()
function RespSendShareMessage(tResult, data)
	RespSendShareMapMessage(tResult, data);
end

--新版api：发送成功回调处理，处理UI.
function RespSendShareMessage_UIHandle(data)
	RespSendShareMapMessage_UIHandle(data);
end

--旧版：分享地图
--新版：兼容皮肤、角色、坐骑分享
--分享地图按钮
function MiniWorksShareMapArchiveTemplateShareBtn_OnClick()
	-- statisticsGameEvent(1901, "%s", "fx_game", "%s", GetShareScene(), "%s", GetShareModelId())

	--好友uin
	local uiParentFrame = this:GetParentFrame();
	local szParentFrameName = uiParentFrame:GetName();
	local uiUin = getglobal(szParentFrameName.."Mini");
	local frientUin = uiUin:GetText();
	if string.find(frientUin, "%p") then
		frientUin = string.sub(frientUin, 2, -2)
	end
	frientUin = tonumber(frientUin)
	if not frientUin then
		return
	end
	local msg;
	local tShareParams = t_share_data:GetMiniShareParameters();

	-- if tShareParams.shareType == t_share_data.ShareType.MAP then
	-- 	msg = "ShareMap,wid="..tShareParams.fromowid;
	-- 	-- funcRequestSendMessage = ReqSendShareMapMessage;
	-- 	ReqSendShareMapMessage(AccountManager:getUin(), frientUin, msg, RespSendShareMapMessage_UIHandle, uiParentFrame)
	-- 	return;
	-- end


	msg = JSON:encode(tShareParams);

	local text = nil
	if tShareParams.shareType == t_share_data.ShareType.TEXT then
		text = tShareParams.content
	end

	Log("ReqSendShareExtendDataMessage(): tostring(tShareParams) = " .. table.tostring(tShareParams))
	
	ReqSendShareExtendDataMessage(AccountManager:getUin(), frientUin, msg, RespSendShareMessage_UIHandle, uiParentFrame, text);
	--	地图分享上报
	if tShareParams.shareType == t_share_data.ShareType.MAP then
		GetInst("BestPartnerManager"):ShareReport(tShareParams.fromowid,AccountManager:getUin(),frientUin)
	end
end

function ReqSendShareExtendDataMessage(nSrcUin, nDesUin, jsonExtendData, funcCallback, userdata, text)
	print("ReqSendShareExtendDataMessage");

	print("ReqSendShareExtendDataMessage(): jsonExtendData = " .. jsonExtendData);
	local base64_encode_jsonStr = ns_http.func.base64_encode(jsonExtendData);
	local encode_jsonStr = ns_http.func.url_encode(base64_encode_jsonStr);
	local src_uin = AccountManager:getUin()
	local pure_s2t,cur_time,token = GetCommonReqParams()
	print("ReqSendShareExtendDataMessage(): encode_jsonStr = " .. encode_jsonStr);
	local url = CreateFriendRequest("/server/friend")
					:addparam("apiid", ClientMgr:getApiId())
					:addparam("cmd", "send_chat_msg")
					:addparam("country", get_game_country())
					:addparam("des_uin", nDesUin)
					:addparam("lang", get_game_lang())
					:addparam("msg", text or "", true)
					:addparam("s2t", pure_s2t)
					:addparam("extend_data", encode_jsonStr)
					:addparam("src_uin", nSrcUin)
					:addparam("time", cur_time)
					:addparam("token", token)
					:addparam("ver", ClientMgr:clientVersionStr())
					:addparam("msgtype", 2)
					:addparam("pushchannel", get_push_chat_push_channel())
					:finish();

	local data = {
		src_uin = nSrcUin,
		des_uin = nDesUin,
		text = text,
		t_extendData = encode_jsonStr,

		--新增回调函数和用户参数
		_callback = funcCallback;
		_userdata = userdata;
	};

	ShowLoadLoopFrame(true, "file:lobby -- func:ReqSendShareExtendDataMessage")

	print("lslsls url = ", url)

	ns_http.func.rpc_string_raw_ex(url, RespSendShareExtendDataMessage, data,nil,true);
end

function RespSendShareExtendDataMessage(jsonResult, tData)
	ShowLoadLoopFrame(false)

	Log("RespSendShareExtendDataMessage");

	local tResult = JSON:decode(jsonResult);

	if tResult and tResult.result == 0 then
		local msg = {
			uin = tData.src_uin,
			text = tData.text,
			extend_data = tData.t_extendData,
			time = tonumber(tResult.send_time),
		};

		friendservice.myfriendsLastReadTimes[tData.des_uin] = msg.time;  -- 自己发出去的消息是已读的
		AddChatMessage(tData.des_uin, msg);
		NeedUpdateChatMessages = true
		UpdateChatMessages(true)
		friendservice.save();
		local salog= Android:Localize(Android.SITUATION.QRCODE_SCANNER);
	     salog("share RespSendShareExtendDataMessage")
		ShowGameTips(GetS(1524),3)

		--成功回调处理
		if tData and tData._callback and tData._userdata then
			tData._callback(tData._userdata);
		end

		--更新分享数量
		if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx") then
			GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):ShareSuccess()
		end
		if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
			GetInst("MiniUIManager"):GetCtrl("ExitGameMenu"):ShareSuccess()
		end
		if GetInst("MiniUIManager"):GetCtrl("ArchiveInfoDetail") then
			GetInst("MiniUIManager"):GetCtrl("ArchiveInfoDetail"):ShareSuccess()
		end
		if GetInst("MiniUIManager"):GetCtrl("GameSettlement") then
			GetInst("MiniUIManager"):GetCtrl("GameSettlement"):ShareSuccess()
		end
	else
		if tResult then
			if tResult.result == 29 then
				ShowGameTips(GetS(100264), 3);
			else
				ShowGameTips(GetS(4736).."("..tResult.result..")", 3);
			end
		else
			ShowGameTips(GetS(4736), 3);
		end
	end
end

--旧版：分享地图
--新版：兼容皮肤、角色、坐骑分享
--发分享地图消息给好友,参考函数:ReqSendChatMessage().
function ReqSendShareMapMessage(src_uin, des_uin, text, callback, userdata)
	print("ReqSendShareMapMessage");
	local src_uin = AccountManager:getUin()
	local pure_s2t,cur_time,token = GetCommonReqParams()
	local url = CreateFriendRequest("/server/friend")
					:addparam("apiid", ClientMgr:getApiId())
					:addparam("cmd", "send_chat_msg")
					:addparam("country", get_game_country())
					:addparam("des_uin", des_uin)
					:addparam("lang", get_game_lang())
					:addparam("msg", text, true)
					:addparam("s2t", pure_s2t)
					:addparam("src_uin", src_uin)
					:addparam("time", cur_time)
					:addparam("token", token)
					:addparam("ver", ClientMgr:clientVersionStr())
					:addparam("pushchannel", get_push_chat_push_channel())
					:finish();

	local data = {
		src_uin = src_uin,
		des_uin = des_uin,
		text = text,

		--新增回调函数和用户参数
		_callback = callback;
		_userdata = userdata;
	};

	ShowLoadLoopFrame(true, "file:lobby -- func:ReqSendShareMapMessage")

	ns_http.func.rpc_string_raw_ex(url, RespSendShareMapMessage, data,nil,true);
end

--旧版：分享地图
--新版：兼容皮肤、角色、坐骑分享
--发送地图消息完成的回调,参考函数:RespSendChatMessage();
function RespSendShareMapMessage(tResult, data)
	ShowLoadLoopFrame(false)

	print("RespSendShareMapMessage");
	Log("RespSendShareMapMessage");

	local tResult = JSON:decode(tResult);

	if tResult and tResult.result == 0 then
		Log("Successful!!!");
		local msg = {
			uin = data.src_uin,
			text = data.text,
			time = tonumber(tResult.send_time),
		};

		friendservice.myfriendsLastReadTimes[data.des_uin] = msg.time;  --自己发出去的消息是已读的
		AddChatMessage(data.des_uin, msg);
		NeedUpdateChatMessages = true
		UpdateChatMessages(true)
		friendservice.save();

		--成功回调处理
		Log("11111");
		if data and data._callback and data._userdata then
			Log("Callback!!!");
			data._callback(data._userdata);
		end
	else
		Log("Error!!!");
		if tResult then
			if tResult.result == 29 then
				ShowGameTips(GetS(100264), 3);
			else
				ShowGameTips(GetS(4736).."("..tResult.result..")", 3);
			end
		else
			ShowGameTips(GetS(4736), 3);
		end
	end
end

--旧版：分享地图
--新版：兼容皮肤、角色、坐骑分享
--发送成功回调处理, 处理UI.
function RespSendShareMapMessage_UIHandle(data)
	--data:条目的对象
	if data then
		local shareBtnName = data:GetName().."ShareBtn";
		local shareBtnObj = getglobal(shareBtnName);
		local shareBtnNarmal = getglobal(shareBtnName.."Normal");
		local shareBtnPushed = getglobal(shareBtnName.."PushedBG");

		--使不能重复点击
		shareBtnObj:Disable();
		shareBtnNarmal:SetGray(true);
		shareBtnPushed:SetGray(true);
	end
end

--订阅/取消订阅按钮
function MiniWorksArchiveInfoFrameTopTakeBtn_OnClick(index)
	local uin = getShortUin(ArchiveWorldDesc.realowneruin);
    TakeOrCancleSubscribeCommonHandle(index, uin);
    
    MiniWorksArchiveInfoFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "Subscribe", "click") --mark by liya 新埋点
end

--点击模型中间小块区域, 跳转商城
function LobbyFrameViewJumpStore_OnClick()
	if gIsSingleGame then return end

	Log("LobbyFrameViewJumpStore_OnClick:");
	if not lobbyIsAvtModel then
		ShopJumpTabView(2,3)
		GetInst("UIManager"):GetCtrl("ShopSkinLib"):ChangeTab(2)
	else
		ShopJumpTabView(3,3)
		GetInst("UIManager"):GetCtrl("ShopCustomSkinLib"):ChangeTab(2)
	end
end

--全局变量保存翻译的信息
local m_MapIntroduceTranslateParam = {
	-- 结构示例
	-- [204507528] = {
	-- 	originalName = "";
	-- 	originalInfo = "";
	-- 	translatedName = "";
	-- 	translateInfo = "";
	-- 	bIsShowOriginal = true;	--当前显示的是原文.
	-- },
};

local TranslateOngoing = FastOpenOnLine		--已经在翻译中不在请求翻译
--翻译地图介绍和地图名
function MapIntroduceTranslateBtn()
	print("MapIntroduceTranslateBtn0")
	local nameObj = getglobal("MiniWorksMapCommentBoxIntroduceMapName");

	local infoObj = getglobal("MiniWorksMapCommentBoxIntroduceInfo");
	local miniTxt = getglobal("MiniWorksArchiveInfoFrameTopMini"):GetText()
	local _, _, suin = string.find(miniTxt, "%((%d+).");
	local uin = tonumber(suin) or 0

	if 0 ~= uin then
		local param = m_MapIntroduceTranslateParam[uin];
		local mapName = nameObj:GetText();		--地图名
		local mapinfo = infoObj:GetText();		--地图描述

		if param and ((param.bIsShowOriginal and param.originalName and param.originalName == mapName and param.originalInfo and param.originalInfo == mapinfo)
			or (not param.bIsShowOriginal and param.translatedName and param.translatedName == mapName and param.translatedInfo and param.translatedInfo == mapinfo))
			 then
			--已存在, 直接用
			print("MapIntroduceTranslateBtn3");
		else
			if TranslateOngoing then
				return
			end

			TranslateOngoing = true
			--TODO这里有隐患 网络请求 如果返回慢 同时又多次点击
			local name, srcLang = Google_Language_Translate(mapName, get_game_lang_str());
			local info, srcLang = Google_Language_Translate(mapinfo, get_game_lang_str());
			print("MapIntroduceTranslateBtn5 name = " .. name .. ", info=" .. info);
			m_MapIntroduceTranslateParam[uin] = {
				originalName = mapName,
				originalInfo = mapinfo,
				translatedName = name,
				translatedInfo = info,
				bIsShowOriginal = true,
			};

			TranslateOngoing = false
		end

		if m_MapIntroduceTranslateParam[uin] then
			local param = m_MapIntroduceTranslateParam[uin];

			if param.bIsShowOriginal == true then
				--当前是原文, 需要显示译文
				param.bIsShowOriginal = false;
				nameObj:SetText(param.translatedName);
				infoObj:SetText(param.translatedInfo);
			else
				param.bIsShowOriginal = true;
				nameObj:SetText(ReplaceFilterString(param.originalName));
				infoObj:SetText(ReplaceFilterString(param.originalInfo));
			end
		end
	end
end

--删除旧的翻译信息
function MapIntroduceDeleteOldTranslation(uin)
	if m_MapIntroduceTranslateParam[uin] then
		m_MapIntroduceTranslateParam[uin] = nil;
		m_MapIntroduceTranslateParam[uin] = {};
	end
end

--根据地图的'owid'进入地图详情页
function ShowMiniWorksMapDetailByMapID(owid,data)
	Log("ShowMiniWorksMapDetailByMapID");
	if owid then
		local func = function()
			Log("ShowMiniWorksMapDetailByMapID: owid = " .. owid);
			if not CheckSupportAllCloud_HasData(owid) then
				CheckSupportAllCloud_SyncReqCheck({owid}, 3, true)
			end
			ReqMapInfo({owid}, RespShowMiniWorksMapDetailByMapID,data);
		end
		if threadpool.running then
			func()
		else
			threadpool:work(func)
		end
	end
end

function RespShowMiniWorksMapDetailByMapID(maps,data)
	Log("RespShowMiniWorksMapDetailByMapID:");
	if data and data._reqcallback and type(data._reqcallback) == "function" then
		data._reqcallback((maps and #maps > 0) and maps[1] or nil)
	end

	if maps and #maps > 0 then
		Log("ByMapID: 111");
		local map = maps[1];

		if IsRoomFrameShown and IsRoomFrameShown() then
			--联机大厅, 需要判断地图是否设置了仅自己可见
			if map.open == 2 then
				--仅自己可见
				if not (data and data._bHideTips) then
					ShowGameTips(GetS(9170));	--该地图未上传或不开放下载
				end
			else
				ShowMiniWorksMapDetail(map,nil,nil,data);
			end
		else
			ShowMiniWorksMapDetail(map,nil,nil,data);
		end
	else
		--没有上传地图
		if not (data and data._bHideTips) then
			ShowGameTips(GetS(9170));	--该地图未上传或不开放下载
		end
	end
end

--根据地图的'owid'进入地图详情页
function ShowMapRoomByMapID(owid)
	Log("ShowMapRoomByMapID");
	if owid then
		local func = function()
			Log("ShowMapRoomByMapID: owid = " .. owid);
			if not CheckSupportAllCloud_HasData(owid) then
				CheckSupportAllCloud_SyncReqCheck({owid}, 3, true)
			end
			ReqMapInfo({owid}, RespShowMapRoomByMapID);
		end
		if threadpool.running then
			func()
		else
			threadpool:work(func)
		end
	end
end

function RespShowMapRoomByMapID(maps)
	Log("RespShowMapRoomByMapID:");
	if maps and #maps > 0 then
		Log("ByMapID: 111");
		local map = maps[1];

		if IsRoomFrameShown() then
			--联机大厅, 需要判断地图是否设置了仅自己可见
			if map.open == 2 then
				--仅自己可见
				ShowGameTips(GetS(9170));	--该地图未上传或不开放下载
			else
				GetInst("UIManager"):Open("MapRoom", {mapInfo = map})
			end
		else
			GetInst("UIManager"):Open("MapRoom", {mapInfo = map})
		end
	else
		--没有上传地图
		ShowGameTips(GetS(9170));	--该地图未上传或不开放下载
	end
end

--room快速联机时获取地图信息来显示进入失败的弹窗用于下载
function ShowOneKeyFailedByMapID(owid, tips, tipsFailedCode)
	Log("ShowMapRoomByMapID");

	if owid and GetInst("CreatorFestivalService") and GetInst("CreatorFestivalService"):IsFindOnlineRoomByOwid(owid) then
		GetInst("CreatorFestivalService"):FindOnlineRoomByOwidFailCallBack(owid, tips)
		return
	end

	if owid then
		Log("ShowMapRoomByMapID: owid = " .. owid);
		if not getglobal("LoadingFrame"):IsShown() and not ClientCurGame:isInGame() then
			ShowGameTips(tostring(tips))
		end
	else
		ShowGameTips(tostring(tips))
	end
end

function RespShowOneKeyFailedByMapID(maps, userData)
	if getglobal("LoadingFrame"):IsShown() or ClientCurGame:isInGame() then
		return
	end
	Log("RespShowOneKeyFailedByMapID:");
	userData = userData or {}
	local tips = userData.tips
	local tipsFailedCode = userData.tipsFailedCode
	if maps and #maps > 0 then
		local map = maps[1];

		if IsRoomFrameShown() then
			--联机大厅, 需要判断地图是否设置了仅自己可见
			if map.open == 2 then
				--仅自己可见
				ShowGameTips(tips);	--该地图未上传或不开放下载
			else
				GetInst("UIManager"):Open("SimpleMapDown", {mapInfo = map, tipsApdCode = tipsFailedCode})
			end
		else
			GetInst("UIManager"):Open("SimpleMapDown", {mapInfo = map, tipsApdCode = tipsFailedCode})
		end
	else
		--没有上传地图
		ShowGameTips(tips);	--该地图未上传或不开放下载
	end
end
---------------------------------------------:新地图详情页end----------------------------------------

function MultiLangSelectFrame_OnLoad( ... )
	local lang 		= "MultiLangSelectFrameL"
	local chendi 	= "MultiLangSelectFrameChenDi"
	for i=1, 16 do
		while true do
			if i == 9 then
				break;
			end
			if i-1 == get_game_lang() then
				getglobal(lang..i.."Tick"):Disable()
				getglobal(lang..i.."TickIcon"):Show()
				getglobal(lang..i.."TickIcon"):SetGray(true)
			end
			local offsetY,_ = math.modf((i-1)/4)
			local offsetX 	= math.fmod(i-1,4)
			if i > 9 then
				offsetY,_ = math.modf((i-2)/4)
				offsetX 	= math.fmod(i-2,4)
			end
			--getglobal(lang..i.."Tick"):Disable()
			getglobal(lang..i):Show()
			getglobal(lang..i):SetPoint("topleft",chendi,"topleft", 30+250 * offsetX,80+80 * offsetY)
			--local t = (i>=8) and 1 or 0
			getglobal(lang..i.."Name"):SetText(GetS(2040+i))

			break
		end
	end
	getglobal("MultiLangSelectFrameAllBtn"):Show()
	getglobal("MultiLangSelectFrameAllBtnName"):SetText(GetS(3798))

	--自适应排版
	local t_text = {
		"MultiLangSelectFrameAllTitle",
		"MultiLangSelectFrameTitleFrameTitle",
		"SelectMapLangFrameTitle",
	}
	for i=1,#(t_text) do
		local title = getglobal(t_text[i])
		local width = title:GetTextExtentWidth(title:GetText())
		title:SetWidth(width)
		if i==2 then
			getglobal("MultiLangSelectFrameTitleFrameBkgLeft"):SetWidth(width+105);
		end
	end

	for i=1,16 do
		local name = getglobal("MultiLangSelectFrameL"..i.."Name")
		if name:GetTextExtentWidth(name:GetText()) > 190 then
			name:SetAutoWrap(true)
			--name:SetHeight(60)
		end
	end

end

function MultiLangSelectFrame_OnHide( ... )
	local word = 0
	for i=0, 15 do
		word = word + math.pow(2,i)
	end
	word = word - math.pow(2, 8)
	if ArchiveWorldDesc and ArchiveWorldDesc.translate_supportlang ~= word then
		getglobal("MultiLangSelectFrameAllBtnTickIcon"):Hide()
	end
end

function MultiLangSelectFrame_OnShow( ... )

end

--ara id=8,i=9
function ArchiveLangSelectTemplateTick_OnClick( ... )
	local icon = getglobal(this:GetName().."Icon")
	local idx  = this:GetParentFrame():GetClientID()
	--local lang_bit = 0;

	if icon:IsShown() then
		icon:Hide()
	else
		icon:Show()
	end

	if idx == 999 then
		for i=1, 16 do
			while true do
				--local langId = getglobal("MultiLangSelectFrameL"..i):GetClientID()
				if i-1 == get_game_lang() or i-1 == 8 then
					break;
				end
				if icon:IsShown() then
					getglobal("MultiLangSelectFrameL"..i.."TickIcon"):Show()
				else
					getglobal("MultiLangSelectFrameL"..i.."TickIcon"):Hide()
					--lang_bit = lang_bit - math.pow(2,i)
				end
				break;
			end
		end
	end
	--print("lang_bit")

end

function MultiLangSelectFrameCloseBtn_OnClick( ... )
	--if getglobal("MultiLangSelectFrameAllBtnTickIcon"):IsShown() then
	--	getglobal("MultiLangSelectFrameAllBtnTickIcon"):Hide()
	--end
	getglobal("MultiLangSelectFrame"):Hide()
end

function MultiLangSelectFrameHelpBtn_OnClick( ... )
	getglobal("MultiLangSelectHelpFrame"):Show()
	getglobal("MultiLangSelectHelpFrameBoxContent"):SetText(GetS(21648),61, 69, 70)
end

function HelpFrameTemplateClose_OnClick( ... )
	local frame = this:GetParentFrame()
	frame:Hide()
end

function MultiLangSelectFrameSaveBtn_OnClick( ... )
	local supportlang = 0
	if ArchiveWorldDesc then
		for i=1, 16 do
			if i~= 9 then
				if getglobal("MultiLangSelectFrameL"..i.."TickIcon"):IsShown() then
					supportlang = supportlang + math.pow(2,i-1)
				end
			end
		end
		ArchiveWorldDesc.translate_supportlang = supportlang;
		AccountManager:setSupportLang(ArchiveWorldDesc.worldid, supportlang)
		ShowGameTips(GetS(3940))
	else
		ShowGameTips(GetS(3941))
	end

	getglobal("MultiLangSelectFrame"):Hide()
	--ShowGameTips(tostring(ArchiveWorldDesc.translate_supportlang))

end




--已下载地图语言选择
function SelectMapLangFrame_OnLoad( ... )
	local column_ = 0
	local row_    = 0
	local show_cc = 0

	for i=0, 15 do
		if  i==8 then
			local btn_ = getglobal( 'SelectMapLangFrameLang' .. i )
			if  btn_ then
				btn_:Hide()
			end
		else
			row_    = math.floor(show_cc / 3)

			column_ = show_cc % 3
			show_cc = show_cc + 1

			local btn_ = getglobal( 'SelectMapLangFrameLang' .. i )
			local txt_ = getglobal( 'SelectMapLangFrameLang' .. i .. "Tips" )
			if  btn_ then
				btn_:SetPoint("left", "SelectMapLangFrameChenDi", "left",  100 + column_*300 , row_ * 100 - 180);
				if i < 3 then
					txt_:SetText( GetS(3495+i) )
				else
					txt_:SetText( GetS(975-3+i) )
				end
			end
		end
	end
end

function SelectMapLangFrame_OnShow( ... )
	--ShowGameTips(tostring(ArchiveWorldDesc.translate_supportlang))
	--ShowGameTips(tostring(AccountManager:getWorldSupportLang(ArchiveWorldDesc.worldid)))
	local supportlang = ArchiveWorldDesc.translate_supportlang;
	local ownerlang = ArchiveWorldDesc.translate_sourcelang;
	local maplang = ArchiveWorldDesc.translate_currentlang;
	local btn_ = "SelectMapLangFrameLang"
	for i=0,15 do
		--当前语言
		if i == maplang then
			getglobal(btn_..i.."Normal"):Hide()
			getglobal(btn_..i.."Checked"):Show()
		else
			getglobal(btn_..i.."Normal"):Show()
			getglobal(btn_..i.."Checked"):Hide()
		end
		--不支持的语言
		if LuaInterface:band(supportlang,math.pow(2,i)) == 0 then
			getglobal(btn_..i.."Normal"):SetGray(true)
			getglobal(btn_..i):Disable()
		else
		--支持的语言
			getglobal(btn_..i.."Normal"):SetGray(false)
			getglobal(btn_..i):Enable()
		end
	end
end

function SelectMapLangFrameCloseBtn_OnClick( ... )
	getglobal("SelectMapLangFrame"):Hide()
end

function SetMapLangTemplate_OnClick( ... )
	local index = this:GetClientID()
	local pre_index = ArchiveWorldDesc.translate_currentlang;
	if index ~= pre_index then
		getglobal("SelectMapLangFrameLang"..pre_index.."Normal"):Show()
		getglobal("SelectMapLangFrameLang"..pre_index.."Checked"):Hide()
		getglobal("SelectMapLangFrameLang"..index.."Normal"):Hide()
		getglobal("SelectMapLangFrameLang"..index.."Checked"):Show()
	end
	ShowGameTips(GetS(21644,GetS(2041+index)))
	ArchiveWorldDesc.translate_currentlang = index
	AccountManager:setArchiveLang(ArchiveWorldDesc.worldid, index)
	getglobal("SelectMapLangFrame"):Hide()
	UpdateShareArchiveInfoIntroduce()

	--刷新一下存档描述
	-- UpdateShareArchiveInfoIntroduce();
end

function  getCurArchiveDesc( ... )
	if ArchiveWorldDesc ~= nil then
		return ArchiveWorldDesc;
	end
	return nil;
end

--新手引导流程优化，指引进入世界
function NoviceEnterWorldFrame_OnShow()
	if CreateMapGuideStep == 2 then
		getglobal("LobbyFrameNoviceEnterWorldFrameStep1"):Show()
		getglobal("LobbyFrameNoviceEnterWorldFrameStep1Bkg"):SetPoint("center", "CreateArchiveCreate", "center", 0, -136)
		if ClientMgr:isPC() then
			getglobal("LobbyFrameNoviceEnterWorldFrameStep1ContinueIcon"):Hide()
			getglobal("LobbyFrameNoviceEnterWorldFrameStep1ContinueFont"):Hide()
			getglobal("LobbyFrameNoviceEnterWorldFrameStep1ContinueIconPc"):Show()
			getglobal("LobbyFrameNoviceEnterWorldFrameStep1ContinueFontPc"):Show()
		else
			getglobal("LobbyFrameNoviceEnterWorldFrameStep1ContinueIcon"):Show()
			getglobal("LobbyFrameNoviceEnterWorldFrameStep1ContinueFont"):Show()
			getglobal("LobbyFrameNoviceEnterWorldFrameStep1ContinueIconPc"):Hide()
			getglobal("LobbyFrameNoviceEnterWorldFrameStep1ContinueFontPc"):Hide()
		end
		getglobal("LobbyFrameNoviceEnterWorldFrameStep1Content"):SetText(GetS(974),55,54,49)
	end
end

function NoviceEnterWorldFrame_OnClick()
	CreateMapGuideStep = CreateMapGuideStep + 1
	CreateMapGuide()
end


-------------------------------------------------------------------------
--[[地图上传 账号校验]]
function ArchiveShareAccountCheck(mapInfo)
	--[[实名认证]]
	if if_open_mapupload_autonymcheck() then
		local state = AccountSafetyCheck:MiniAutonymCheckState()
        -- 认证通过了, 暂时无限制
        if state then
        	return true
        else
        	MessageBoxFrame2:Open(1, GetS(100251), GetS(100252),
        		function(btn)
	        		if btn == "left" then
	        			ArchiveSaveToServers(mapInfo)
	        		else
						local adsType = RealNameFunc and RealNameFunc.isShowIdentityNameAuth and RealNameFunc:isShowIdentityNameAuth(8)
						if adsType then
							ShowIdentityNameAuthFrame(true,nil,nil,nil,nil,adsType,true)
						else
							ShowIdentityNameAuthFrame(true)
						end
	        		end

					--询问实名认证打点
					IdentityNameAuthClass:IdentityNameAuthStatistics(3, {playSelect = (btn == 'left') and 2 or 1})
        		end)

			--实名弹框埋点记录场景
			IdentityNameAuthClass:SPSceneByASCFunType(AccountSafetyCheck.FunType.MAP_SHARE)
       		return false
        end
	end

	return true
end

function ArchiveSaveToServers(worldInfo)
	if not worldInfo then
		return
	end

	local worldName = worldInfo.worldname
	local text = worldInfo.memo;
	local verifyId = worldInfo.fromowid
	if not verifyId or verifyId == 0 then
		verifyId = worldInfo.worldid
	end

	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(verifyId)
	if mapIsBreakLaw == 1 then
		ShowGameTips(GetS(10564), 3)
		return
	elseif mapIsBreakLaw == 2 then
		ShowGameTips(GetS(3634), 3)
		return
	end

	--敏感词过滤
	if CheckFilterString(worldName.." "..text, false) or FilterMgr.GetFilterScore(worldName) or FilterMgr.GetFilterScore(text) then
		ShowGameTips(GetS(10546), 3) --分享TODO
		return
	end

	local activity = -1
	if mapservice.curActivityId~=nil then
		activity = mapservice.curActivityId
	end

	local MultiLangName = worldInfo.multilangname
	local MultiLangDesc = worldInfo.multilangdesc
	local canrecord = 0
	local open = 2

	if UploadMap(worldInfo.worldid, open, GetLabel2Owtype(worldInfo.worldtype), worldName, text, activity, canrecord, MultiLangName, MultiLangDesc) then
		IsNeedReset = false;
		if not isEnableNewLobby() then
			ShareingMapIndex = clientId
		end

		-- if ShareArchiveType == 9 then
		-- 	statisticsGameEvent(40003, "%lld", worldInfo.worldid);  --录像上传埋点
		-- end

		local supportlang = -1;
		if worldInfo.translate_supportlang > math.pow(2,get_game_lang()) then
			supportlang = worldInfo.translate_supportlang
		end

		-- if AccountManager:findWorldDesc(worldInfo.worldid) then
		-- 	if getglobal("ShareArchiveInfoFrame"):GetClientUserData(1) == 1 then
		-- 		statisticsGameEvent(61500,"%s",tostring(supportlang),"%s",tostring(worldInfo.worldid))
		-- 	elseif getglobal("ShareArchiveInfoFrame"):GetClientUserData(1) == 2 then
		-- 		statisticsGameEvent(61501,"%s",tostring(supportlang),"%s",tostring(worldInfo.worldid))
		-- 	end
		-- end
	end
end

-----------------------------显示计时器------------------------------
-- 运行模式
_G.SSTIMER_RUNMODE = {
	IDLE = 0, -- 计时不变
	INC = 1, -- 计时累加
	DEC = 2, -- 计时递减
}
local ssTimerTime = -1 -- 开发者计时器时间
local ssTimerTitle = "_" -- 开发者计时器标题
local ssTimerRunMode = SSTIMER_RUNMODE.IDLE -- 开发者计时器运行模式
local ssTimerSecodePerTick = 0.05 -- 每tick为0.05s

-- 显示计时器UI
local function ShowSSTimerUI()
	local time = math.ceil(ssTimerTime)
	time = (time > 0) and time or 0
	local content = ssTimerTitle .. tostring(time)

	local timerObj = getglobal("GongNengFrameTimer")
	local timerObjTips = getglobal("GongNengFrameTimerTips")
	assert(timerObj and timerObjTips)
	if timerObj and timerObjTips then
		timerObj:Show()
		timerObjTips:SetText(content)
	end
end

-- 隐藏计时器UI
local function HideSSTimerUI()
	local timerObj = getglobal("GongNengFrameTimer")
	local timerObjTips = getglobal("GongNengFrameTimerTips")
	if timerObj and timerObjTips then
		timerObj:Hide()
		timerObjTips:SetText("")
	end
end

-- 更新计时器界面显示
local function UpdateSSTimerUIShow()
	if math.ceil(ssTimerTime) >= 0 then -- 倒计时结束，不自动隐藏窗口
		ShowSSTimerUI()
	else
		HideSSTimerUI()
	end
end

-- 设置(全部填nil表示清空)
-- param : time : number : 计时器计时时间
-- param : title : string : 计时器标题
-- param : runmode : number : 计时器运行模式
function SetSSTimerUI(time, title, runmode)
	ssTimerTime = tonumber(time) or -1
	ssTimerTitle = title and tostring(title) or ""
	ssTimerRunMode = runmode or SSTIMER_RUNMODE.IDLE

	UpdateSSTimerUIShow()
end

-- 更新计时器UI
function TickSSTimerUI()
	if ssTimerTime < 0 then
		return
	end

	local delta = 0
	if ssTimerRunMode == SSTIMER_RUNMODE.INC then
		delta = ssTimerSecodePerTick -- 正向计时，累加
	elseif ssTimerRunMode == SSTIMER_RUNMODE.DEC then
		delta = -ssTimerSecodePerTick -- 倒计时，递减
	else
		return -- 值不变
	end
	local prevtime = ssTimerTime
	ssTimerTime = ssTimerTime + delta

	if math.ceil(prevtime) ~= math.ceil(ssTimerTime) then
		UpdateSSTimerUIShow()
	end
end

function GetSSTimer()
	return math.ceil(ssTimerTime)
end
-----------------------------/显示计时器------------------------------

--记录[Desc5]存档位前的操作，[Desc5]存档位后继续原来的 创建/下载/录像 等操作
g_RememberOperateBeforeBuyArchive = nil
function ShowNotEnoughArchiveWithOperate( g_func )
	GetInst("UIManager"):Open("ArchiveNotEnough")
	g_RememberOperateBeforeBuyArchive = g_func
end
--是否需要显示[Desc5]存档位
function CanShowNotEnoughArchiveWithOperate( g_func )	
	--22.12.5开始游戏改版，存档位需求不设上限（实际999），关闭购买存档位功能
	if not GetInst("mainDataMgr"):AB_NewArchiveLobbyMain() then
		return false
	end
	if GetBoughtArchiveNum() < GetBuyArchiveNumLimit() then
		ShowNotEnoughArchiveWithOperate(g_func)
		return true
	end
	return false
end

-- testgjd
--游戏开始界面落地数据埋点（开始界面）
local checkdelaycd = true
function LobbyFrame_BuriedDatapoints()
	if checkdelaycd == true then
		local playeractive = AccountManager:get_active_days();
		local playermod = nil
		if playeractive >= 2 then
			playermod = 1
		else
			playermod = 0
		end
		-- statisticsGameEventNew(56101, AccountManager:getUin(),playermod)
		checkdelaycd = false;
		threadpool:work(function()
			threadpool:wait(300);
			checkdelaycd = true;
		end)
	end
end


--------------------------------------------------------------------------------------------------------
ActorAnimCtrl = {
	IsAngle = false;
	MaxAngle = -30;	--旋转最大角度
	Interval = 0.01;	--旋转间隔 单位s
	OnceAngle = 0.5;	--每次转动角度
}

function ActorAnimCtrl:ActorAngle(viewName)
	if not viewName then
		return
	end
	print("ActorAnimCtrl:ActorAngle1")
	threadpool:work(function()
		local nowAngle = 0
		local view = nil

		while(nowAngle > self.MaxAngle and self.IsAngle)
		do
			view = getglobal(viewName)
			if view and view:IsShown() then
				view:setRotateAngle(nowAngle)
				nowAngle = nowAngle - self.OnceAngle
			else
				return
			end

			threadpool:wait(self.Interval)
		end
		end)
end

--[[动作播放完后回调]]
function ActorAnimSwitch(animID)
	print("ActorAnimSwitch", animID)
	local roleview = getglobal("LobbyFrameRoleView")
	if roleview:IsShown() then
		getglobal("LobbyFrameRotateView"):Show()
		local body = roleview:getActorBody();
		if body and animID == 100108 and body.getPlayerIndex and body:getPlayerIndex() > 0 then
			ActorAnimCtrl.IsAngle = true
			body:setAnimSwitchIsCall(false)
			local skinModel = body:getSkinID()

			if skinModel == 74 or skinModel == 75 or skinModel == 76 then
				local skinDef = RoleSkinCsv:get(skinModel);
				if skinDef and skinDef.ChangeContact and skinDef["ChangeContact"][0] then
					local horse = UIActorBodyManager:getHorseBody(skinDef["ChangeContact"][0] + 0,false);
					if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
						roleview:detachActorBody(body)
						roleview:attachActorBody(horse)
					else
						body:detachUIModelView(roleview)
						horse:attachUIModelView(roleview)
					end
					horse:setScale(1.2);
				end
			end
			ActorAnimCtrl:ActorAngle("LobbyFrameRoleView")
		end
	end
	if getShedulerTransfer() ~= nil then
		if animID == 100155 or animID == 100170 then
			CharacteractionChangeSkin(true);
		end
	end
	--皮肤召唤功能
	if animID == 100928 then
		AvatarSummonEvent()
	end
end

function MapDownLoadSuccessful(owid, isRentDebugUpload, rentDebugShareVersion)
	local env_ = get_game_env()
    if env_ < 10 and not isRentDebugUpload then
		ReqSyncWorldListFromServer(AccountManager:getUin(), {owid})
	end
	ShareArchive_MapUploadEnd(owid, isRentDebugUpload, rentDebugShareVersion)

	local uiManager = GetInst("UIManager");
	if uiManager then
		local shareArchive = GetInst("UIManager"):GetCtrl("ShareArchive");
		if shareArchive and shareArchive.model and shareArchive.model.SetUploadOfficialTemplate then
			shareArchive.model:SetUploadOfficialTemplate(false);
		end
	end

	if not isRentDebugUpload then
		--开发者模版地图上传完成之后移动存档到开发者模版地图存档里面去
		local worldDesc = WorldArchiveMgr:findWorldDesc(owid)
		if worldDesc and worldDesc.TempType == 3 and GetInst("ShareArchiveInterface"):CanUploadOfficialTemplate() then
			WorldArchiveMgr:uploadDevTempWorldOK(owid);
		end
	end
end

--当前使用的角色是否支持星舞动动作
function CanCurUseRoleSupportARAction()
	local skinModel = AccountManager:getRoleSkinModel();
	local seatID = AccountManager:avatar_seat_current();
	if skinModel > 0 then
		local skinDef = RoleSkinCsv:get(skinModel);
		if skinDef and skinDef.Arbody == 1 then
			return true
		end
	elseif seatID and seatID > 0 then
		return true
	else
		local rolemodelID = AccountManager:getRoleModel();
		local genuisLv = AccountManager:getAccountData():getGenuisLv(rolemodelID);
		local roleDef = DefMgr:getRoleDef(rolemodelID, genuisLv);
		if roleDef and roleDef.Arbody == 1 then
			return true
		end
	end
	return false
end

function LobbyFrameArchiveSlotBtn_OnClick()
	GetInst("UIManager"):Open("PlayerArchiveSlots");
	local frame = getglobal("PlayerArchiveSlots");
	if frame and not frame:IsShown() then
		frame:Show();
	end
	-- statisticsGameEventNew(752, get_game_lang());
end

function GongNengFramePluginPkgTipsBtn_OnClick()
	local tipsFrame = getglobal("GongNengFramePluginPkgTipsFrame")
	--数据埋点
	-- statisticsGameEventNew(31023)
	if tipsFrame:IsShown() then
		tipsFrame:Hide()
	else
		tipsFrame:Show()
	end
end

--重进地图
function GongNengFramePluginPkgTipsReEnterGame_OnClick()
	if ClientCurGame:isInGame() then
		local sceneid="1003"
		local cardid="MINI_GAMEOPEN_GAME_1"
		local compid='Plugbug_Restartmap'
		standReportGameExitParam = standReportGameExitParam or {}
		standReportGameExitParam.sceneid = sceneid
		standReportGameExitParam.cardid = cardid
		standReportGameExitParam.compid = compid

		standReportGameOpenParam = {
			sceneid=sceneid, 
			cardid=	cardid, 
			compid=compid,
		}
		GetInst("ReportGameDataManager"):NewGameLoadParam(sceneid,cardid,compid)
		
		EnterMainMenuInfo.ReLoadGame = {}
		EnterMainMenuInfo.ReLoadGame.owid = CurWorld:getOWID()
		EnterMainMenuInfo.ReLoadGame.reportData = {
			sceneid=sceneid, 
			cardid=	cardid, 
			compid=compid,
		}
		HideUI2GoMainMenu();
		ClientMgr:gotoGame("MainMenuStage");
		-- statisticsGameEventNew(31025)
	end
end

function GongNengFramePluginPkgTipsShow()
	if CurWorld and CurWorld:isGameMakerMode() then
		if GetInst("UIManager"):GetCtrl("ModsLib") then
			local modsAddNum = GetInst("UIManager"):GetCtrl("ModsLib"):GetAddModsCount()
			if modsAddNum>0 then
				getglobal("GongNengFramePluginPkgTipsBtn"):Show()
			else
				getglobal("GongNengFramePluginPkgTipsBtn"):Hide()
			end
		else
			getglobal("GongNengFramePluginPkgTipsBtn"):Hide()
		end
		getglobal("GongNengFramePluginPkgTipsFrame"):Hide()
	else
		getglobal("GongNengFramePluginPkgTipsFrame"):Hide()
		getglobal("GongNengFramePluginPkgTipsBtn"):Hide()
	end	

end

function ArchiveInfoFrameResourceCenterBtn_OnClick()
	local archiveData = GetOneArchiveData(SelectArchiveIndex);
	if not archiveData then return end;
	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
	if not worldInfo or not worldInfo.worldid then return end;
	if worldInfo.openpushtype == 3 and IsNewbieWorld(worldInfo.worldid) == false then	--没有数据
		if worldInfo.open == 0 then	--提示删除存档
			local text = GetS(159);
			if IsStandAloneMode("") then
				text = GetS(15)
			end
			MessageBox(4, text);
			getglobal("MessageBoxFrame"):SetClientString( "切换帐号未分享地图" );
			return;
		elseif worldInfo.open > 0 then
			local text = GetS(160);
			MessageBox(5, text);
			getglobal("MessageBoxFrame"):SetClientUserData(0, SelectArchiveIndex);
			getglobal("MessageBoxFrame"):SetClientString( "切换帐号分享下载地图" );
			return;
		end
	else
		local owid = worldInfo.fromowid
		if owid == 0 then owid = worldInfo.worldid end
		local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(owid)
		if mapIsBreakLaw == 2 then
			ShowGameTips(GetS(16158), 3)
			return
		end
		-- statisticsGameEventNew(1112, 2);
		GetInst("ResourceDataManager"):SetIsFromLobby(ResourceCenterOpenFrom.FromArchive)
		GetInst("ResourceDataManager"):SetSelectMapInfo( worldInfo.worldid, worldInfo.realowneruin);
		GetInst("UIManager"):Open("ResourceCenter", { UpdateView=true });
		getglobal("ArchiveInfoFrame"):Hide();
		getglobal("LobbyFrame"):Hide();
	end
end

-------------------用于地图迁移 start-------------------
ToolsMapIdHash = nil
function SetToolsMapId(new_wid, old_wid)
	-- 临时功能 -- 触发器转换积木块
	GetInst("Triggers2BlocksMgr"):Convert(new_wid)
	if not ToolsMapIdHash then
		ToolsMapIdHash = getkv("tools_mapid_hash", "tools_mapid_hash", 1003) or {}
	end

	if ToolsMapIdHash[new_wid] then return end
	ToolsMapIdHash[new_wid] = old_wid

	setkv("tools_mapid_hash", ToolsMapIdHash, "tools_mapid_hash", 1003)
end

function GetToolsMapId(new_wid)
	if not ToolsMapIdHash then
		ToolsMapIdHash = getkv("tools_mapid_hash", "tools_mapid_hash", 1003) or {}
	end

	local old_wid = ToolsMapIdHash[new_wid]
	if old_wid then
		return old_wid
	end

	return ""
end

function DelToolsMapId(new_wid)
	if not ToolsMapIdHash then
		ToolsMapIdHash = getkv("tools_mapid_hash", "tools_mapid_hash", 1003) or {}
	end

	local old_wid = ToolsMapIdHash[new_wid]
	if not old_wid then return end
	ToolsMapIdHash[new_wid] = nil

	setkv("tools_mapid_hash", ToolsMapIdHash, "tools_mapid_hash", 1003)
end


local archiveItemList = {}

-- index 是worldid
function ArchiveCarry_DataGet(name, index)
	if archiveItemList[index] == nil then
		archiveItemList[index] = {}
	end
	return archiveItemList[index][name]
end

function ArchiveCarry_DataSet(name, index, value)
	if archiveItemList[index] == nil then
		archiveItemList[index] = {}
	end
	archiveItemList[index][name] = value
end

function ArchiveCarry_ViewSetCheckBox(view, isCheck, isReversed)
	if view == nil then return end
	local selfName = view:GetName()
	local childFullName = selfName .. "Tick"
	local tick = getglobal(childFullName)
	if isReversed == true then
		isCheck = not tick:IsShown()
	end
	if tick then
		if isCheck then
			tick:Show()
		else
			tick:Hide()
		end
	end
	return isCheck
end

-- 设置搬运结果
function ArchiveCarry_ViewSetResultText(view, code, is_clear)
	if view == nil then return end
	local selfName = view:GetName()
	local childFullName = selfName .. "SlidingFrameContentResult"
	local result = getglobal(childFullName)
	if result then
		result:Show()
		if is_clear then
			result:SetText("", 0, 0, 0)
		else
			if code == 0 then
				result:SetText("搬运成功！", 0, 255, 0)
			else
				result:SetText("搬运失败("..code..")", 255, 0, 0)
			end
		end
	end
end

function ArchiveCarry_ViewSetProgress(finishNum, totalNum)
	local p = getglobal("LobbyFrameArchiveFrameProgress")
	if p then
		p:SetText("搬运进度:已搬运" .. finishNum .. "/" .. totalNum .. "张地图")
	end
end

-- 单个地图的checkbox点击事件
function ArchiveCarry_SelectMapAllowOnClick()

	local archive = this:GetParentFrame():GetParent()
	local index = getglobal(archive):GetClientID()
	
	local worldInfo = AccountManager:getMyWorldList():getWorldDesc(index)
	if worldInfo then
		if worldInfo.realowneruin ~= 0 and worldInfo.realowneruin ~= 1 and worldInfo.owneruin ~= worldInfo.realowneruin then
			local worldid = worldInfo.worldid
			ArchiveCarry_DataSet("check", worldid, not ArchiveCarry_DataGet("check", worldid))
			ArchiveCarry_ViewSetCheckBox(this, ArchiveCarry_DataGet("check", worldid))
		else
			-- 自己的，或新手地图
			ShowGameTips("不能选自己的", 3)
		end
	end
end

-- 全选按钮点击
function ArchiveCarry_CheckAllOnClick()
	local isCheck = ArchiveCarry_ViewSetCheckBox(this, false, true)
	local list = GetArchiveData()
	for k, v in ipairs(list) do
		local worldid = v.info.worldid
		local worldInfo = v.info
		if worldInfo.realowneruin ~= 0 and worldInfo.realowneruin ~= 1 and worldInfo.owneruin ~= worldInfo.realowneruin then
			ArchiveCarry_DataSet("check", worldid, isCheck)
		end
	end
	
	UpdateArchive()
end

-- 搬运前先清理
function ArchiveCarry_DoCarryBefore(totalNum)
	local list = GetArchiveData()
	local listview = getglobal("ArchiveBox")
	local cell
	local wid
	for i=1,#list do
		cell = listview:cellAtIndex(i-1)
		if cell then
			wid = cell:GetClientUserDataLL(0)
			ArchiveCarry_ViewSetResultText(cell, 0, true)
		end
	end
	ArchiveCarry_ViewSetProgress(0, totalNum)
	-- 结果清除
	for k, v in pairs(archiveItemList) do
		ArchiveCarry_DataSet("code", k, nil)
		ArchiveCarry_DataSet("check", k, false)
	end
end

function ArchiveCarry_OneKeyOnClick()
	local owidlist = {}
	local list = GetArchiveData()
	for i = 1, #list do
		local worldInfo = list[i].info
		if ArchiveCarry_DataGet("check", worldInfo.worldid) then
			owidlist[#owidlist + 1] = worldInfo.worldid
		end
	end
	if #owidlist == 0 then
		ShowGameTips("请先选择要搬运的地图", 3)
		return
	end
	ArchiveCarry_DoCarryBefore(#owidlist)
	threadpool:wait(0.2)
	ArchiveCarry_OneKeyDoCarry(owidlist)
end

-- 一键搬运
function ArchiveCarry_OneKeyDoCarry(owidList)
	local resultList = {}
	local nameid = math.random(1, 1000)
	local mapName
	local code
	local totalNum = #owidList
	for k, owid in ipairs(owidList) do
		mapName = "TT"..nameid
		code = AccountManager:createWorldTools(owid, mapName)
		resultList[owid] = code
		ArchiveCarry_DataSet("code", owid, code)
		nameid = nameid + 1
		ArchiveCarry_ViewSetProgress(k, totalNum)
		threadpool:wait(0.8)
	end
	ArchiveCarry_DoCarryAfter(resultList)
end

function ArchiveCarry_DoCarryAfter(resultList)
	local failCount, successCount = 0, 0
	local failList = {}
	-- 结果显示
	local list = GetArchiveData()
	local listview = getglobal("ArchiveBox")
	local cell
	local wid
	for i=1,#list do
		cell = listview:cellAtIndex(i-1)
		if cell then
			wid = cell:GetClientUserDataLL(0)
			if wid and resultList[wid] then
				ArchiveCarry_ViewSetResultText(cell, resultList[wid])
			end
		end
	end

	-- 成功，失败统计
	for k, c in pairs(resultList) do
		if c == 0 then
			successCount = successCount + 1
		else
			failList[#failList + 1] = k
			failCount = failCount + 1
		end
	end
	if failCount == 0 then
		MessageBox(4, successCount.."张全部搬运成功！", function()
		end)
	else
		MessageBox(5, successCount.."张搬运成功，" .. failCount .. "张搬运失败\r\n是否尝试搬运失败地图？", function(btn)
			if btn == 'left' then
				ArchiveCarry_OneKeyDoCarry(failList)
			else
			end
		end)
	end
end

-- 一键删除
function ArchiveCarry_OneKeyDelMap()
	local owidlist = {}
	local list = GetArchiveData()
	for i = 1, #list do
		local worldInfo = list[i].info
		if ArchiveCarry_DataGet("check", worldInfo.worldid) then
			owidlist[#owidlist + 1] = {
				owid = worldInfo.worldid, 
				fromwid = worldInfo.fromowid,
				openpushtype = worldInfo.openpushtype,
			}
		end
	end
	if #owidlist == 0 then
		ShowGameTips("请先选择要搬运的地图", 3)
		return
	end

	for k, v in ipairs(owidlist) do
		if ArchiveWorldDesc ~= nil and ArchiveWorldDesc.worldid == v.owid then
			if IsMapDetailInfoShown() then
				HideMapDetailInfo();
			end
		end	
		if v.openpushtype == 4 then
			AccountManager:pauseDownloadWorld(v.owid);
		end
		AccountManager:requestDeleteWorld(v.owid);
		RemoveRecordMapList(v.fromwid);
	end
	SetDefaultArchiveBtn()--add
	UpdateLobbyFrameArchiveFrameRecordList()
	ShowGameTips("删除成功", 3)

	-- 结果清除
	for k, v in pairs(archiveItemList) do
		ArchiveCarry_DataSet("code", k, nil)
		ArchiveCarry_DataSet("check", k, false)
	end
end

-------------------用于地图迁移 end-------------------

--新地图界面刷新旧地图局部数据
function NewArchiveRefreshLobbyData()
	gAchiveDataList = GetArchiveData();
end


-------------------UI库审核-------------------
local UILibCheckFrame = {
	nCurIndex = 0,
	nSumCount = 0,
};

function ShowUILibCheckFrame(bHide)
	if bHide then
		getglobal("GongNengFrameUILibCheckFrame"):Hide();
	else
		getglobal("GongNengFrameUILibCheckFrame"):Hide();

		local apiId = ClientMgr:getApiId();

		if ClientCurGame and ClientCurGame:isInGame() and (apiId == 1101 or apiid == 1102) then
			if UIProjectLibMgr then
				local count = UIProjectLibMgr:GetProjectCount(UILIBTYPE_MAP);

				if count <= 0 then
					getglobal("GongNengFrameUILibCheckFrame"):Hide();
					return;
				else
					UILibCheckFrame.nSumCount = count;
					UILibCheckFrame.nCurIndex = 0;
					getglobal("GongNengFrameUILibCheckFrame"):Show();
					getglobal("GongNengFrameUILibCheckFrameText"):SetText(UILibCheckFrame.nCurIndex .. "/" .. UILibCheckFrame.nSumCount);
				end
			end
		end 
	end
end

function UILibCheckFramePageTureBtnOnClick(nType)
	--nType:1 上一个 2:下一个
	if nType == 1 then
		if UILibCheckFrame.nCurIndex <= 1 then
			UILibCheckFrame.nCurIndex = 0;
			UILibCheckFrameOpenUI(false);
		else
			UILibCheckFrame.nCurIndex = UILibCheckFrame.nCurIndex - 1;
			UILibCheckFrameOpenUI(true, UILibCheckFrame.nCurIndex);
		end
	else
		if UILibCheckFrame.nCurIndex == UILibCheckFrame.nSumCount then
			UILibCheckFrameOpenUI(false);
			UILibCheckFrame.nCurIndex = 0;
		else
			UILibCheckFrame.nCurIndex = UILibCheckFrame.nCurIndex + 1;
			UILibCheckFrameOpenUI(true, UILibCheckFrame.nCurIndex);
		end
	end

	getglobal("GongNengFrameUILibCheckFrameText"):SetText(UILibCheckFrame.nCurIndex .. "/" .. UILibCheckFrame.nSumCount);
end

function UILibCheckFrameOpenUI(bShow, pageIndex)
	if bShow then
		UIEditorDef:checkUI(pageIndex);
	else
		UIEditorDef:checkUI(0);
	end
end


function WorldMgr_OnLoadData(jsonData)
	local data = JSON:decode(jsonData)
	FesivialActivity:LoadTianGouData(data)
end

function WorldMgr_OnSaveData()
	local saveData = {}
	saveData.tiangouData = FesivialActivity:GetTiangouData()
	return JSON:encode(saveData)
end

function RefreshLobbyMiniBaseDrainageBt()
	local miniBaseBtName = "GongNengFrameMiniBaseDrainageBtn"
	local miniBaseBt = getglobal(miniBaseBtName)
	if not miniBaseBt then return end
	--MiniBase隐藏迷你基地下载
	if MiniBaseManager:isMiniBaseGame() then 
		miniBaseBt:Hide()
		return
	end

	--模式下不显示
	if CurWorld and CurWorld:isGameMakerMode() then
		miniBaseBt:Hide()
		return
	end

	local bShow = GetActivityRoomMiniBaseDrainageBtSwitch("game")
	if bShow then
		miniBaseBt:Show()
		--1001普通房间游戏是作为客机进入游戏  1003打开地图游戏是作为主机进入游戏（单机和作为房主开联机房间）
		local sceneID = "";
		if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
			sceneID = "1003";
		else--客机
			sceneID = "1001";
		end		
		local cId = (sceneID == "1001") and "MINI_GAMEROOM_GAME_1" or "MINI_GAMEOPEN_GAME_1"
		standReportEvent(sceneID, cId, "SkinReward", "view")

		if getglobal("GongNengFrameStartRecordBtn"):IsShown() then
			miniBaseBt:SetPoint("left", "GongNengFrameStartRecordBtn", "right", 15, 0);
		else
			miniBaseBt:SetPoint("center", "GongNengFrameStartRecordBtn", "center", 0, 0);
		end

	else
		miniBaseBt:Hide()
	end

	local Icon = getglobal(miniBaseBtName.."Icon")
	local textureRes = GetActivityRoomMiniBaseDrainageBtIcon()
	if Icon and textureRes then
		Icon:SetTexUV(textureRes);
	end
end

function GetDownArchiveType()
	return DownArchiveType
end

function SetDownArchiveType(value)
	DownArchiveType = value
end

--hx 新增418埋点 type 1 击杀npc 2击杀玩家，3存档
function Report418Event(type)
	local mtype=""
	local id=""
	if 1==type then
		mtype="NPC_KILL"
		id ="Npc"
	elseif 2==type then
		mtype="PLAYER_KILL"
		id ="Player"
	elseif 3==type then
		mtype="SAVE_HOUSE"
		id ="Save"
	end
	local code ="view" 
	local mapid = G_GetFromMapid();
	local mstandby1 = GetReport418Eventstandby1(mapid);
	local extra = {cid=tostring(mapid),standby1=mstandby1}
	standReportEvent("418", mtype, id, code,extra)  
end

function GetReport418Eventstandby1(id)
	local stanby1_1, stanby1_2, stanby1_3 = "", "", ""
	if AccountManager:getMultiPlayer() == 0 then
		-- 单机
		stanby1_2 = 1
	else				
		if IsArchiveMapCollaborationMode() then					
			-- 好友协作模式
			stanby1_2 = 3
		else
			-- 普通联机
			stanby1_2 = 2
		end
	end
	local worldInfo = AccountManager:findWorldDesc(id)
	if worldInfo then
		if worldInfo.realowneruin > 1 and worldInfo.owneruin ~= worldInfo.realowneruin then
			stanby1_1 = 2 -- 2：别人地图 
		elseif worldInfo.worldid then
			stanby1_1 = 1 -- 1:自己地图
		end
		if worldInfo.worldtype then
			stanby1_3 = worldInfo.worldtype
		end
	end
	return stanby1_1..stanby1_2..stanby1_3
end

--[[
	活动页H5跳转客户端内部分位置需求，后台配置位置ID
   位置ID	对应的页面
	"1"     :开始游戏 - 我的
	"2"     :开始游戏 - 创建新地图 - 开发者模式
	"3_1"   :迷你工坊 - 首页
	"3_2"   :迷你工坊 - 地图
	"3_3"   :迷你工坊 - 专题
	"3_4"   :迷你工坊 - 模板
	"3_5"   :迷你工坊 - 材质
	"3_6"   :迷你工坊 - 话题
	"4"     :迷你工坊 - 开始创作
	"5"     :地图详情
	"6"		:资源工坊 - 专题（打开某一指定id专题）
	"7"     :开始游戏 - 我的 - 上传 - 未上传
	"8"     :地图详情 - 排行榜
]]
function GoToPageByPosId(posId, id)
	print("GoToPageByPosId: ", posId, id);
	if posId then
		if ClientCurGame and ClientCurGame:isInGame() then
			return
		end
		EnterMainMenuInfo.EnterMainMenuBy = ""
		GetInst("MiniUIManager"):HideAllUI();
		GetInst("UIManager"):HideAll();
		UIFrameMgr:hideAllFrame();
		ShowMiniLobby()

		local func = function()
			if posId == "1" then
				JumpToLocalMap()
			elseif posId == "2" then
				newlobby_LobbyFrameCreateNewWorldBtn_OnClick();
				CreateWorldTabBtnTemplate_OnClick(2)
			elseif posId == "3_1" or posId == "3_2" or posId == "3_3" or posId == "3_4" or posId == "3_5" or posId == "3_6" then
				local LabelBtn = {
					["3_1"] = 7, --首页
					["3_2"] = 1, --地图
					["3_3"] = 4, --专题
					["3_4"] = 10,--地图模板
					["3_5"] = 8, --材质
					["3_6"] = 11, --话题
				};
				JumpToMiniWorks()
				MiniworksGotoLabel(LabelBtn[posId]);
			elseif posId == "4" then
				JumpToMiniWorks()
				getOfficialRankTemplateList();
			elseif posId == "6" and id then
				local themeId = tonumber(id)
				if not themeId then
					ShowGameTips("please check the theme id: "..id);
					return
				end
				MiniLobbyFrameCenterMiniWorksResourceShopBt_OnClick()
				GetInst("UIManager"):GetCtrl("ResourceShop"):TabBtnClicked(4);
				local topicCtrl = GetInst("UIManager"):GetCtrl("ResourceShopTopic")
				if topicCtrl then
					local index = topicCtrl:GetIndexByThemeID(themeId);
					if index > 0 then
						topicCtrl:ShowTopicByThemeID(themeId);
					else
						ShowGameTips("Failed to open theme, please check the theme id: "..id);
					end
				end
			elseif posId == "7" then
				GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common_comp",
					"miniui/miniworld/c_miniwork",
					"miniui/miniworld/common"
				})
				GetInst("MiniUIManager"):OpenUI(
					"MapUploadDetails", 
					"miniui/miniworld/newMapUpload", 
					"MapUploadDetailsAutoGen", 
					{
						filterType = "NOT_UPLOAD"
					}
				)
			end
		end
		if threadpool.running then
			func()
		else
			threadpool:work(func)
		end
	end
end
function ArchDataSaved()
	ShowGameTipsWithoutFilter(GetS(34625), 3)
end

-- 地图内弹幕
-- param = { 
-- 	"弹幕1:玩家【方式发生发射点就是】在【发生的覅】的红包中获得了10个【教授副教授多少】", 
-- 	"弹幕2:玩家【方式发生发射点就是】在【发生的覅】的红包中获得了10个【教授副教授多少】", 
-- 	"弹幕3:玩家【方式发生发射点就是】在【发生的覅】的红包中获得了10个【教授副教授多少】", 
-- 	"弹幕4:玩家【方式发生发射点就是】在【发生的覅】的红包中获得了10个【教授副教授多少】"
-- }
function ShowScrollingPopText(param)
	if GetInst("MiniUIManager"):IsShown("ScrollingPopTextAutoGen") then
		GetInst("MiniUIManager"):GetCtrl("ScrollingPopText"):UpdatePopTextInfo(param)
	else
		GetInst("MiniUIManager"):OpenUI("Main", "miniui/miniworld/ScrollingPopText", "ScrollingPopTextAutoGen", param)		
	end
end

function HasTodayBackupInfo(worldid)
	if worldid == nil then
		return false
	end
	local duration = 3600 --1小时
	local now = os.time()
	CSOWorld:loadWorldBackupInfos(worldid);
	local ordinaryBackupIndex = 0;
	for i=1,CSOWorld:getWorldBackupInfoNum() do
		local info = CSOWorld:getWorldBackupInfo(i-1);
		if not info.isOnlineBackup and not info.isCloudServerBackup then
			local time = info.time
			if now - time <= duration then
				return true
			end
		end
	end
	return false
end