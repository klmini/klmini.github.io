

-------------动态刷新一个xml或者lua文件--------------------
-------------此功能已经移到accelkeys.xml文件中-------------	



-----------------------------------------------------------------------
t_DefaultSetData = {configure=2, view=1, peacemodel=0, volume=80, musicopen=1, soundopen=1, voiceopen=1, sensitivity=50,
			reversalY=0, lefthanded=0, sight=0, autojump=1, radarSteering=0,camerashake=1,screenbright=0, view_distance=2, fog=2,treeshape=1, vibrate=1,
			classical=0, rocker=1, reflect=0, shadow=0,limiteFps=1,popups=1,fpsbuttom=1,physxparam=1,cantrace=1,damageswitch=0,bloodswitch=0,
			}	
t_HighterSetData 	= {view_distance=3,};
t_MediumSetData 	= {view_distance=2,};
t_LowSetData 		= {view_distance=1,};

--改名卡
g_ChangeNameCard 	= {
	callback = nil,
};

local limit_fps_config = {
	PC_LIMIT_ON = 80,
	PC_LIMIT_OFF = 760,
	MOBILE_LIMIT_ON = 30,
	MOBILE_LIMIT_OFF = 50,
}

function GetPCLimitOn()
	return limit_fps_config.PC_LIMIT_ON
end

function GetPCLimitOff()
	return limit_fps_config.PC_LIMIT_OFF
end

function GetMobileLimitOn()
	return limit_fps_config.MOBILE_LIMIT_ON
end

function GetMobileLimitOff()
	return limit_fps_config.MOBILE_LIMIT_OFF
end
---------------------------------------SetMenuFrame---------------------------------------------------------
function CanChangeGameMode()
	if not CurWorld:isCreativeMode() and not CurWorld:isCreateRunMode() 
	   and not CurWorld:isGameMakerMode() and not CurWorld:isGameMakerRunMode() then 			
		return false;
	end

	if AccountManager:getMultiPlayer() > 0 then	--房间
		return false;
	end

	local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
	if worldDesc ~= nil and worldDesc.realowneruin ~= 0 and worldDesc.owneruin ~= worldDesc.realowneruin then --下载的存档
		return false;
	end

	return true;
end

function CanShowScreenShot()
	return true;
end

function CanShowLeftSet()
	local gameType = AccountManager:getMultiPlayer();
	if gameType == 2 then
		return false;
	end

	return true;
end

local SetMenuFrame_LayoutButtons = {
	"SetMenuFrameContinueBtn",
	"SetMenuFrameContinueBtn2",
	"SetMenuFrameGameSetBtn",
	"SetMenuFrameGameSetBtn2",
	"SetMenuFrameGotoQQForum",
	"SetMenuFrameGotoQQForum2",
	"SetMenuFrameFeedBackBtn",
	"SetMenuFrameFeedBackBtn2",
	"SetMenuFrameMainMenuBtn",
	"SetMenuFrameGameEndBtn",
};

--换肤:勾选按钮
m_TickBtn_UISkinInfo = {
	preUIName = "GameSetFrameBaseLayersScrollUISkinTickBtn";
	--按钮名字
	-- {nameID = 21751, skinId = "1", texUV = "board_uistyle_g"},	--草绿(built2默认), 这个表的顺序决定按钮显示的顺序
	-- {nameID = 21752, skinId = "2", texUV = "board_uistyle_y"},	--嫩黄(built3)
	-- {nameID = 21753, skinId = "3", texUV = "board_uistyle_b"},	--天蓝(built4)
	{nameID = 21751, skinId = "1", texUV = "board_check_circle"},	--草绿(built2默认), 这个表的顺序决定按钮显示的顺序
	{nameID = 21752, skinId = "2", texUV = "board_check_circle"},	--嫩黄(built3)
	{nameID = 21753, skinId = "3", texUV = "board_check_circle"},	--天蓝(built4)
	{nameID = 32301, skinId = "4", texUV = "board_check_circle"},	--梦幻粉(built5)
};

function SetMenuFrame_OnClick()
	getglobal("SetMenuFrame"):Hide();
end

--地图内使用模板，要加一个多人判断，如果是多人不支持使用模板地图
function SetMenuFrame_CanAsTempCreate(pOwid)
	if AccountManager:getMultiPlayer() > 0 then	--房间
		return false;
	end

	return GetInst("TempMapInterface"):CanAsTempCreate(pOwid);
end

function SetMenuFrame_OnShow()
	standReportEvent("29", "SETTINGS_TOP", "-", "view")
	SetArchiveDealMsg(false);
	local result = GameSnapshot(true);

	local SetMenuFrameChenDi = getglobal("SetMenuFrameChenDi")
	local SetMenuFrameGameEndBtn = getglobal("SetMenuFrameGameEndBtn")
	--LLTODO:继续游戏按钮
	local SetMenuFrameGameContinueBtn = getglobal("SetMenuFrameGameContinueBtn")
	local SetMenuFrameMainMenuBtn = getglobal("SetMenuFrameMainMenuBtn")
	local leftSet = getglobal("SetMenuFrameLeftSetFrame");
	local buttonDesc = getglobal("SetMenuFrameButtonDesc");
	---MiniBase 返回主菜单改成退出游戏
	if MiniBaseManager and MiniBaseManager:isMiniBaseGame() then
		getglobal("SetMenuFrameMainMenuBtnName"):SetText(GetS(3053))
	end

	--新账号登录系统
	getglobal("SetMenuFrameAccountSetBtnName"):SetText(IsEnableNewAccountSystem() and GetS(35557) or GetS(3445))
	
	if ClientCurGame:isInGame() then
		SetMenuFrameGameEndBtn:Hide();
		SetMenuFrameGameContinueBtn:Hide();
		SetMenuFrameMainMenuBtn:Show();
		if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
			standReportEvent("1003", "MINI_QUIT_MANU", "-", "view")
		else
			standReportEvent("1001", "MINI_QUIT_MANU", "-", "view")
		end
		getglobal("SetMenuFrameAccountSetBtnNormal"):SetGray(true);

		local modeBtn = getglobal("SetMenuFrameLeftSetFrameChangeGameModeBtn");
		local showLeft = CanShowLeftSet()
		if showLeft then
			SetMenuFrameChenDi:SetPoint("left", "SetMenuFrame", "center", -100, 0);
			leftSet:Show();		 	

			if result == 'no_thumb' then	
				local huires = Snapshot:getSnapshotTexture(99);
				getglobal("ScreenShotFramePic"):SetTextureHuires(huires);
			else
				local huires = Snapshot:getSnapshotTexture(CurWorld:getOWID());
				getglobal("ScreenShotFramePic"):SetTextureHuires(huires);
			end
			--[[
			if AccountManager:isOWSnapLocked(CurWorld:getOWID()) then
				local huires = Snapshot:getSnapshotTexture(CurWorld:getOWID());
				getglobal("ScreenShotFramePic"):SetTextureHuires(huires);
				getglobal("ScreenShotFrameLockChecked"):Show();
			else
				local huires = Snapshot:getSnapshotTexture(99);
				getglobal("ScreenShotFramePic"):SetTextureHuires(huires);
				getglobal("ScreenShotFrameLockChecked"):Hide();
			end	
			]]

			local _isTempMap = SetMenuFrame_CanAsTempCreate(CurWorld:getOWID());

			local modeBtnNormal = getglobal("SetMenuFrameLeftSetFrameChangeGameModeBtnNormal");			
			local teamupSer = GetInst("TeamupService")
			local isInTeam = teamupSer and teamupSer:IsInTeam(AccountManager:getUin())

			modeBtn:Show()
			if (CanChangeGameMode() or _isTempMap) and not isInTeam then
				modeBtn:Enable();
				modeBtnNormal:SetGray(false);
			else
				modeBtn:Disable();
				modeBtnNormal:SetGray(true);
				modeBtn:SetClientUserData(0, 0);
			end

			local changeName = getglobal("SetMenuFrameLeftSetFrameChangeGameModeBtnName");
			modeBtn:SetClientString("")
			if _isTempMap then
				changeName:SetText(GetS(34418));
				modeBtn:SetClientString("")
			elseif CurWorld:isCreativeMode() then
				changeName:SetText(GetS(3193));
				modeBtn:SetClientString("AdventureMode")

			elseif CurWorld:isCreateRunMode() then
				changeName:SetText(GetS(3194));
				modeBtn:SetClientString("CreationMode")

			elseif CurWorld:isGameMakerMode() then
				changeName:SetText(GetS(719));
				modeBtn:SetClientString("PlayMode")

			elseif CurWorld:isGameMakerRunMode() then
				changeName:SetText(GetS(720));
				modeBtn:SetClientString("EditMode")
			end

			SetMenuFrame_RefreshChangePublicBtn()
			
			--if AccountManager:isExistMod(CurWorld:getOWID()) or CurWorld:isExtremityMode() or AccountManager:getMultiPlayer() > 0 then
			-- 除了极限冒险之外的模式，存档内都加上多人联机的那个按钮（含有插件的地图也可以在存档内开多人）
			if  CurWorld:isExtremityMode() or AccountManager:getMultiPlayer() > 0 then
				getglobal("SetMenuFrameLeftSetFrameCreateRoomBtn"):Hide();
			else
				---MiniBase 隐藏好友联机
				if MiniBaseManager and MiniBaseManager:isMiniBaseGame() then
					getglobal("SetMenuFrameLeftSetFrameCreateRoomBtn"):Hide();
				else
					getglobal("SetMenuFrameLeftSetFrameCreateRoomBtn"):Show();
				end				
			end
		else
			SetMenuFrameChenDi:SetPoint("center", "SetMenuFrame", "center", 0, 0);
			leftSet:Hide();
		end

		if ClientMgr:isPC() then
			buttonDesc:Show();
		end		

		if modeBtn.GetClientString and modeBtn:GetClientString() ~= "" then
			standReportEvent('1003', 'MINI_QUIT_MANU', modeBtn:GetClientString(), 'view', G_GetGameStandReportDataA())
		end
	else
		SetMenuFrameChenDi:SetPoint("center", "SetMenuFrame", "center", 0, 0);
		leftSet:Hide();
		buttonDesc:Hide();
		SetMenuFrameMainMenuBtn:Hide();
		getglobal("SetMenuFrameAccountSetBtnNormal"):SetGray(false);

		if IsIosPlatform() then	--苹果系统：隐藏“退出游戏”按钮
			SetMenuFrameGameEndBtn:Hide();
			SetMenuFrameGameContinueBtn:Hide();
		else
			SetMenuFrameGameEndBtn:Show();
		end
	end	

	--LLTODO:显示"继续游戏"按钮
	SetMenuFrameGameContinueBtn:Show();
	
	if IsIosPlatform() and (not ClientCurGame:isInGame()) then
		SetMenuFrameGameContinueBtn:Hide();
	end
	
	--反馈
	if ClientMgr:getVersionParamInt("FeedBack", 1) == 1 and not gIsSingleGame then
		if isQQGamePc() then	--QQ大厅PC 显示短的意见反馈按钮
			getglobal("SetMenuFrameFeedBackBtn"):Show();
			getglobal("SetMenuFrameFeedBackBtn2"):Hide();
		else
			--有客服配置显示建议反馈和联系客服按钮
			if ns_version.customerservice and check_apiid_ver_conditions(ns_version.customerservice) then
				getglobal("SetMenuFrameFeedBackBtn"):Show()
				getglobal("SetMenuFrameFeedBackBtn2"):Hide()
				getglobal("SetMenuFrameCustomerServiceBtn"):Show()
			else
				getglobal("SetMenuFrameFeedBackBtn"):Hide()
				getglobal("SetMenuFrameFeedBackBtn2"):Show()
			end
		end
	else
		getglobal("SetMenuFrameFeedBackBtn"):Hide();
		getglobal("SetMenuFrameFeedBackBtn2"):Hide();
	end
	--账号设置
	if NewAccountSwitchCfg:GetAccountSettingShowSwitch() 
		and not getglobal("LoginScreenFrame"):IsShown() 
		and not getglobal("SelectRoleFrame"):IsShown() 
		and not isAndroidShouQ() then  
			--显示账号按钮
		getglobal("SetMenuFrameGameSetBtn2"):Hide();
		getglobal("SetMenuFrameAccountSetBtn"):Show();
		getglobal("SetMenuFrameGameSetBtn"):Show();
		
		if IsStandAloneMode("") then
			getglobal("SetMenuFrameAccountSetBtnNormal"):SetGray(true)
			getglobal("SetMenuFrameAccountSetBtn"):Disable()
		else
			getglobal("SetMenuFrameAccountSetBtnNormal"):SetGray(false)
			getglobal("SetMenuFrameAccountSetBtn"):Enable()
		end
		
		if ClientCurGame:isInGame() then
			getglobal("SetMenuFrameAccountSetBtn"):Hide();
			getglobal("SetMenuFrameInformBtn"):Show();
		else
			getglobal("SetMenuFrameInformBtn"):Hide();
		end
	else
		getglobal("SetMenuFrameAccountSetBtn"):Hide();
		getglobal("SetMenuFrameGameSetBtn"):Hide();
		getglobal("SetMenuFrameGameSetBtn2"):Show();
		getglobal("SetMenuFrameInformBtn"):Hide();

		if ClientCurGame:isInGame() then
			getglobal("SetMenuFrameGameSetBtn"):Show();
			getglobal("SetMenuFrameGameSetBtn2"):Hide();
			getglobal("SetMenuFrameInformBtn"):Show();
		else
			getglobal("SetMenuFrameInformBtn"):Hide();
		end
	end
	-- 抖音云游戏渠道 写死 展示账号管理按钮
	if ClientMgr:getApiId() == 60  then 
		getglobal("SetMenuFrameGameSetBtn2"):Hide();
		getglobal("SetMenuFrameAccountSetBtn"):Show();
		getglobal("SetMenuFrameGameSetBtn"):Show();
	end	
	--PC大厅，跳转到论坛
	if isQQGamePc() then
		if ClientMgr:getVersionParamInt("FeedBack", 1) == 1 then
			getglobal("SetMenuFrameGotoQQForum2"):Hide();
			getglobal("SetMenuFrameGotoQQForum"):Show();
		else
			--getglobal("SetMenuFrameGotoQQForum"):Hide();
			--getglobal("SetMenuFrameGotoQQForum2"):Show();
			--LLTODO:论坛按钮缩小一半, 添加查询资料按钮
			getglobal("SetMenuFrameGotoQQForum2"):Hide();
			getglobal("SetMenuFrameGotoQQForum"):Show();
			getglobal("SetMenuFrameQueryData"):Show();
		end
	else
		getglobal("SetMenuFrameGotoQQForum"):Hide();

		--LLTODO:7k7k和4399没有论坛则显示长的"查询资料"
		if ClientMgr:getApiId() == 121 or ClientMgr:getApiId() == 122 then
			--有客服配置显示建议反馈和联系客服按钮
			if ns_version.customerservice and check_apiid_ver_conditions(ns_version.customerservice) then
				getglobal("SetMenuFrameQueryData"):Show()
				getglobal("SetMenuFrameQueryData2"):Hide()
				getglobal("SetMenuFrameCustomerServiceBtn"):Show()
				getglobal("SetMenuFrameCustomerServiceBtnNormal"):SetTextureTemplate("TemplateBkg57")
				getglobal("SetMenuFrameCustomerServiceBtnPushedBG"):SetTextureTemplate("TemplateBkg57")
				getglobal("SetMenuFrameCustomerServiceBtn"):SetPoint("topleft", "SetMenuFrameChenDi", "topleft", 42, 181)
			else
				getglobal("SetMenuFrameQueryData2"):Show()
			end
		end
	end

	--显示so 版本时间信息@lingbj
	getglobal("GameSetFrameVersionTimeName"):SetText(ClientMgr:getClientBuildTime())
	--海外版布局, 增加FAQ
	getglobal("SetMenuFrameFAQBtn"):Hide();
	if isAbroadEvn() then
		getglobal("SetMenuFrameFeedBackBtn2"):Hide();
		getglobal("SetMenuFrameFeedBackBtn"):Show();
		getglobal("SetMenuFrameFeedBackBtn"):SetPoint("topleft", "SetMenuFrameChenDi", "topleft", 42, 181);
		getglobal("SetMenuFrameFAQBtn"):Show();	
	end

	-- update layout
	local frameHeight;
	if not ClientCurGame:isInGame() and IsIosPlatform() then
		SetMenuFrameChenDi:SetSize(546, 310);
	else
		SetMenuFrameChenDi:SetSize(524, 428);
	end
	--[[
	if leftSet:IsShown() then
		leftSet:SetHeight(frameHeight);
	end
	]]
	--DoLayout_ListV(SetMenuFrame_LayoutButtons, btnSpacing);

	sendEventReports();

	if ClientCurGame:isInGame() and not getglobal("SetMenuFrame"):IsReshow() then
		Log("SetMenuFrame_OnShow: setOperateUI(true)");
		ClientCurGame:setOperateUI(true);
	end

	if CSOWorld:isGmCommandsEnabled() then
		getglobal("ScreenShotFrameScreenshotHighRes"):Show();
	else
		getglobal("ScreenShotFrameScreenshotHighRes"):Hide();
	end

	if IsInIosSpecialReview() then
		getglobal("SetMenuFrameLeftSetFrameCreateRoomBtn"):Hide();
	end

	getglobal("SetMenuFrameInformBtnNormal"):SetGray(false);
	getglobal("SetMenuFrameInformBtn"):Enable()

	if gIsSingleGame then
		getglobal("SetMenuFrameAccountSetBtn"):Hide()
		getglobal("SetMenuFrameLeftSetFrameCreateRoomBtn"):Hide()
		getglobal("SetMenuFrameInformBtn"):Hide()
	end

	--如果是未登录状态，游戏设置按钮置灰不可点击
	local uin = GetMyUin();
	print("----------why----uid"..uin)
	if uin == 0 then
		getglobal("SetMenuFrameGameSetBtn2"):Disable();
	else
		getglobal("SetMenuFrameGameSetBtn2"):Enable()
	end

	if AccountManager:getMultiPlayer() == 0 then
		--单机的都是 "举报地图"
		getglobal("SetMenuFrameInformBtnName"):SetText(GetS(10553))
	else
		--"举报房间"
		getglobal("SetMenuFrameInformBtnName"):SetText(GetS(9804))
	end

	-- MVP
	if GetInst("mainDataMgr"):GetSwitch() then
		-- TickBtnOnClick_UISkinSet(1);
		-- ShowGameTipsWithoutFilter('hide setting uiskin')
		getglobal("GameSetFrameBaseLayersScroll"):SetHeight(480);
		getglobal("GameSetFrameBaseLayersScrollUISkinTitle"):Hide();
		for i = 1, #m_TickBtn_UISkinInfo do
			getglobal("GameSetFrameBaseLayersScrollUISkinTickBtn" .. i):Hide();
		end		
	end

	local wdesc = AccountManager:getCurWorldDesc();
	if wdesc == nil then 
		return 
	end
	if wdesc.realowneruin == AccountManager:getUin() then
		getglobal("SetMenuFrameInformBtnNormal"):SetGray(true);
		getglobal("SetMenuFrameInformBtn"):Disable();
	else
		getglobal("SetMenuFrameInformBtnNormal"):SetGray(false);
		getglobal("SetMenuFrameInformBtn"):Enable()
	end
	
	print("InitUISkinTickBtnBkg:",ns_version,ns_version.skinlist)
	if ns_version ~= nil and ns_version.skinlist ~= nil then 
		for i = 2, #m_TickBtn_UISkinInfo do
			getglobal("GameSetFrameBaseLayersScrollUISkinTickBtn" .. i):Show();
		end		
	else		
		---ShowGameTips("get svr skinlist config empty",5);		
		for i = 2, #m_TickBtn_UISkinInfo do
			getglobal("GameSetFrameBaseLayersScrollUISkinTickBtn" .. i):Hide();
		end		
	end

	--教育版屏蔽部分按钮
	if isEducationalVersion then
		SettingFrameOnShow_Edu();
	end
	
end

function SetMenuFrame_RefreshChangePublicBtn()
	local modeBtn = getglobal("SetMenuFrameLeftSetFrameChangeGameModeBtn");

	local connectMode = RoomInteractiveData.RoomInfoMgr:GetRoomInfoParam('roomConnectMode')
	local changePublicBtn = getglobal("SetMenuFrameLeftSetFrameChangePublicBtn");
	local changePublicBtnNormal = getglobal("SetMenuFrameLeftSetFrameChangePublicBtnNormal");	
	local changePublicBtnPushedBG = getglobal("SetMenuFrameLeftSetFrameChangePublicBtnPushedBG");	
	local changePublicBtnname = getglobal("SetMenuFrameLeftSetFrameChangePublicBtnName");
	local createSecCloudBtn = getglobal("SetMenuFrameLeftSetFrameCreateSecCloudBtn");

	changePublicBtn:Hide()
	createSecCloudBtn:Hide()
	if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then
		if IsCloudServerRoomOwner() then
			createSecCloudBtn:Hide()
			modeBtn:Hide()
			changePublicBtn:Hide()
		else
			createSecCloudBtn:Show()
			modeBtn:Hide()
			changePublicBtn:Hide()
		end
	end
end

--录像开关按钮显示/隐藏
function LeftSetFrame_OnShow( ... )
	local ScreenShotBtn=getglobal("ScreenShotFrameLock");
	local RecordSwitchBtn=getglobal("SetMenuFrameLeftSetFrameRecordSwitchBtn");
	local roomType = AccountManager:getMultiPlayer();
	if not CanShowLeftSet() then
		ScreenShotBtn:Hide();
		RecordSwitchBtn:Hide();
		return
	end
	if 2 ~= roomType then
		ScreenShotBtn:SetPoint("center","ScreenShotFrame","bottom",-50,0);
		RecordSwitchBtn:SetPoint("center","ScreenShotFrame","bottom",50,2);
	else
		ScreenShotBtn:SetPoint("center","ScreenShotFrame","bottom",0,0);
		RecordSwitchBtn:Hide();
	end
end


--LLDO:跳转FAQ
function SetMenuFrameFAQBtn()
	Log("SetMenuFrameFAQBtn:");
	getglobal("SetMenuFrame"):Hide();
	InteractiveBtn_OnClick("faq");							--1. 打开好友界面
	MyFriendEntryTemplateChatBtn_OnClick(1);			--2. 打开迷你队长聊天框
	MiniCaptionTypeBtnTemplate_OnClick(2);				--3. 打开常见问题    --新手问题 btn1 --> btn2  问题
end

function SetArchiveDealMsg(isDeal)
	if HasUIFrame("ArchiveBox") then
		getglobal("ArchiveBox"):setDealMsg(isDeal);
	end 
end

function SetMenuFrame_OnHide()
	if ClientCurGame then
		SetArchiveDealMsg(true);
		if ClientCurGame:isInGame() and not getglobal("SetMenuFrame"):IsRehide() then
			Log("SetMenuFrame_OnHide: setOperateUI(false)");
			ClientCurGame:setOperateUI(false);
		end
		ClientCurGame:setInSetting(false);
	end

	if isEducationalVersion then
		ShowWebView_Edu()
	end
end

function SetContinueBtn_OnClick()
	standReportEvent("29", "SETTINGS_TOP", "Close", "click")
	getglobal("SetMenuFrame"):Hide();
end

function AccountSet_OnClick()
	standReportEvent("29", "SETTINGS_TOP", "Management", "click")
	-- statisticsGameEvent(56022)
	if not getkv("reset_password_red") then
		setkv("reset_password_red", true)
		UpdateResetPasswordRedTag()
	end
	
	if ClientCurGame:isInGame() then
		ShowGameTips(GetS(3446), 3);
	else
		getglobal("SetMenuFrame"):Hide();

		if NewAccountSwitchCfg and NewAccountSwitchCfg:IsOpen() then
			NewAccountManager:NotifyEvent(NewAccountManager.DLG_ACCOUNT_MANAGER, {})
		elseif IsEnableNewAccountSystem() then
			OpenAccountManagePanel("MinilobbyAccountManage")
		else
			getglobal("AccountLoginFrame"):Show();
		end
	end
end

function GameSet_OnClick()
	standReportEvent("29", "SETTINGS_TOP", "Gamesetting", "click")
	getglobal("SetMenuFrame"):Hide();
	if GotoGameSetFrame then
		GotoGameSetFrame()
	else
		getglobal("GameSetFrame"):Show();
	end
end

function GotoGameSetFrame(tabId)
	if not getglobal("GameSetFrame"):IsShown() then
		getglobal("GameSetFrame"):Show()
	end

	tabId = tabId or 0  -- 默认基础设置页面
	SetFrameTabBtnTemplate_OnClick(tabId)
end


function GotoQQForum_OnClick()
	--qq大厅版"论坛"跳转连接
	SdkManager:BrowserShowWebpage("http://qqgame.qq.com/gameinfo/10610.html");
	--SdkManager:BrowserShowWebpage("http://qqgame.gamebbs.qq.com/forum.php?mod=forumdisplay&fid=31049");
end

--LLTODO:查询资料按钮,跳转链接
function QueryData_OnClick()
	if isQQGamePc() then
		--qq大厅版跳转连接
		SdkManager:BrowserShowWebpage("http://mn.qq.com/index.shtml");
	elseif ClientMgr:getApiId() == 121 then
		--4399
		SdkManager:BrowserShowWebpage("http://news.4399.com/mnsj/");
	elseif ClientMgr:getApiId() == 122 then
		SdkManager:BrowserShowWebpage("http://news.7k7k.com/mnsj/?ss");
	end
end

t_BackMainMenuNeedHideFrame = {
					"MItemTipsFrame",
					"GameTipsFrame",
					"NickModifyFrame",
					"ChatInputFrame",
					"ChatContentFrame",
					"RoomUIFrame",
					"FriendUIFrame",
					"ActivityFrame",
					"GameRewardFrame",
					"TaskTrackFrame",
					"BattleDeathFrame",
					"HomeChestFrame",
					"OverLookArrowFrame",
                    "PaletteFrame",
                    "LettersFrame",
                    "CameraFrame",
					"SpectatorFrame",
					"SpectatorPlayerName",
					"EncryptFrame",
					"ReplayTheaterFrame",
					"VideoHandleFrame",
					"VideoRecordStringFrame",
					"AdventureNoteFrame",
					"NpcTaskFrame",
				}
function MainMenuBtn_OnClick()
	GetInst("BattleEndFriendListGData"):CacheGamePlayMates()
	
	local isInTeam = false
	if ClientCurGame and  ClientCurGame:isInGame() then
		local teamupSer = GetInst("TeamupService")
		if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
			isInTeam = true
		end
	end

	local worldDesc = AccountManager:getCurWorldDesc();
	local ownMap = 0
	if worldDesc and worldDesc.realowneruin == AccountManager:getUin() then
		ownMap = 1;
	end
	local cid = 0;
	if worldDesc then
		if worldDesc.fromowid and worldDesc.fromowid > 0 then
			cid = tostring(worldDesc.fromowid)
		elseif worldDesc.owid and worldDesc.owid > 0 then
			cid = tostring(worldDesc.owid)
		elseif worldDesc.wid and worldDesc.wid > 0 then
			cid = tostring(worldDesc.wid)
		elseif worldDesc.map_type then
			cid = worldDesc.map_type
		end
	end

	if isEducationalVersion then
		if not ClientMgr:isPC() then
			if MCodeMgr then
				local tParam = {0, "go_home"}
				MCodeMgr:miniCodeCallBack(-1001, JSON:encode(tParam));
				getglobal("SetMenuFrame"):Hide();
			end
			return;
		end
	end
	local firstMapId = getkv("firstMapId","statisticsDataFile")
	if CurWorld and CurWorld:getOWID() == NewbieWorldId then	--从新手地图返回
		GuideSkipConfirm();
		--埋点，返回存档界面 设备码,返回存档来源,是否首次进入教学地地图,用户类型,语言	
		-- statisticsGameEventNew(963,ClientMgr:getDeviceID(),2,(IsFirstEnterNoviceGuide and not enterGuideAgain) and 1 or 2,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
		StatisticsTools:send(true, true)
		IsSkipFromGuideOrFirstMap = true
	else
		if firstMapId and firstMapId == CurWorld:getOWID() then
			if not getkv("alreadyUp963","statisticsDataFile") then
				--埋点，返回存档界面 设备码,返回存档来源,是否首次进入教学地地图,用户类型,语言	
				-- statisticsGameEventNew(963,ClientMgr:getDeviceID(),1,(IsFirstEnterNoviceGuide and not enterGuideAgain) and 1 or 2,
				-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
				StatisticsTools:send(true, true)
				setkv( "alreadyUp963", true, "statisticsDataFile")--只上报一次
			end
			IsSkipFromGuideOrFirstMap = true
		else
			IsSkipFromGuideOrFirstMap = false
		end
		g_IsFirstOpenDeveloperStore = true;
        g_IsFirstOpenDeveloperstash = true;
		if RecordPkgMgr:isRecordPlaying() then
			GoToMainMenu();
			return;
		end
		print("MainMenuBtn_OnClick", IsRoomOwner())
		if IsRoomOwner() then	--主机
			getglobal("SetMenuFrame"):Hide();
			-- 离开游戏二次确认框：关闭房间将踢出所有玩家
			if isInTeam then
				MessageBox(31, GetS(26074));
				getglobal("MessageBoxFrame"):SetClientString( "主机关闭房间Right" );
			else
				MessageBox(31, GetS(220));
				getglobal("MessageBoxFrame"):SetClientString( "主机关闭房间Right" );
			end
			-- 主机关闭房间：退出地图时上报 by fym
			ExistGameReport("view")
		else
			if not isInTeam and not IsCommended then
				getglobal("SetMenuFrame"):Hide();
				-- -- 离开地图时评分：如果你喜欢这张地图就认真写个测评吧！
				-- MessageBox(23, GetS(3860), nil, nil, true, nil, true);
				-- getglobal("MessageBoxFrame"):SetClientString( "离开地图时评分" );
				-- 离开地图时评分：退出地图时上报 by fym
				ExistGameReport("view")
				
				GoToMainMenu()
			elseif not isInTeam and MapRewardClass:GetAuthorUin() ~= AccountManager:getUin() and MapRewardClass:IsOpen() and MapRewardClass:GetRewardState() == 0 then
				getglobal("SetMenuFrame"):Hide();

				-- 打赏作者功能：觉得这张地图好玩就去给它投个块吧！
				MessageBox(33, GetS(21786), nil, nil, true, nil, true);
				getglobal("MessageBoxFrame"):SetClientString( "支持一下" );
				-- 打赏作者功能(支持一下)：退出地图时上报 by fym
				ExistGameReport("view")
			else
				if not isInTeam then
					ExistGameReport("click")
					GoToMainMenu();
				else
					MessageBox(31, GetS(26075) ,function(btn)
						if btn == 'right' then
							GetInst("TeamVocieManage"):GameExitReport()
							GoToMainMenu()
						end
					end)
				end
				local guideStep = GetGuideStep()
				if guideStep and guideStep == 3 then 
					--新手引导流程优化，第一张玩家创建的地图，返回时直接返回到主页面
					EnterMainMenuInfo.DelNoviceMap = true
					EnterMainMenuInfo.EnterMainMenuBy = 'NewbieWorld'
					SetGuideStep(3)
				end 
			end
		end
	end
end

function GoToMainMenu()
	--社交大厅退出上报	
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		SafeCallFunc(function()
			local evtTb = {
				cid = G_GetFromMapid(),
				standby1 = EnterSurviveGameInfo.StatisticsData.EnterTime,
				standby2 = ClientCurGame:getNumPlayerBriefInfo()+1,
				standby3 = SurviveGame_GetCacheData("SocialWorldPlayerNum") or 0,
			}
			local allCount, channles = GetInst("SocialHallDataMgr"):GetSendChatData()
			evtTb.standby4 = allCount
			evtTb.standby5 = table.concat(channles, "|")
			standReportEvent(1003, "SOCIA_HALL_TOP", "GameExit", "view", evtTb)
		end)
	end
	
	OnTransferSendData()

	if CurMainPlayer and CurMainPlayer.avatarSummon then
		if CurWorld and CurWorld:isRemoteMode() then
			local params = {objid = CurMainPlayer:getObjId(),summonid = 0}
			SandboxLuaMsg.sendToHost(_G.SANDBOX_LUAMSG_NAME.BUZZ.AVATAR_SUMMON_TOHOST, params)
		else
			CurMainPlayer:avatarSummon(0)
		end
	end

	if not PlatformUtility:isPureServer() then
		SafeCallFunc(GetInst("ArchiveLobbyRecordManager").CacheAddRecord, GetInst("ArchiveLobbyRecordManager"))
	end
	
	SpamPreventionPresenter:requestClearSettings();
	if not AccountManager:isOWSnapLocked(CurWorld:getOWID()) then
		Snapshot:saveCurSnapshot(99);
	end

	ns_LongTimeShareMap.set_play_time( CurWorld:getOWID() )	 	--记录地图玩过多久
	
	if ClientMgr:getGameData("hideui") ~= 0 then
		UnhideAllUI();
	end
	if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
		GetInst("MiniUIManager"):GetCtrl("ExitGameMenu"):CloseClick()
	end
	--PVP赛事活动主动离开重置发送pb到云服标志
	GetInst("PvpCompetitionManager"):resetSendActToCloudServer()
	HideUI2GoMainMenu();
    ClearInstanceData();
    ClearMultiLangEdit();
    HideVehicleTips();
	
	if AccountManager:getMultiPlayer() == 0 then
		-- if isMiniWorkEnterWorld then
		-- 	EnterMainMenuInfo.EnterMainMenuBy = 'MiniWork';
		-- else
		-- 	EnterMainMenuInfo.EnterMainMenuBy = 'standalone';
		-- end
		if IsInHomeLandMap and IsInHomeLandMap() then
			--回到首页
			if EnterMainMenuInfo.EnterMainMenuBy ~= "HomeLand" then
				EnterMainMenuInfo.EnterMainMenuBy = ""
			end
		end
	else
		if IsInHomeLandMap and IsInHomeLandMap() then
			--回到首页
			if EnterMainMenuInfo.EnterMainMenuBy ~= "HomeLand" then
				EnterMainMenuInfo.EnterMainMenuBy = ""
			end
		elseif EnterMainMenuInfo.EnterMainMenuBy == "ShopSkinDisplay" and EnterMainMenuInfo.ReOpenShopSkinDisplay ~= nil then
			-- 联机房退出后提示次数清0
			if RoomFrameSetOpenRoomShowPingNum then RoomFrameSetOpenRoomShowPingNum(0) end
			if CreateRoomSetStartGameNum then CreateRoomSetStartGameNum(0) end
		elseif EnterMainMenuInfo.EnterMainMenuBy ~= "recentlyOpenedWorldRoomEnter" and 
		   EnterMainMenuInfo.EnterMainMenuBy ~= "FromMiniWorksStartMulitRoom" then
			-- EnterMainMenuInfo.EnterMainMenuBy = 'multiplayer';
			-- 联机房退出后提示次数清0
			if RoomFrameSetOpenRoomShowPingNum then RoomFrameSetOpenRoomShowPingNum(0) end
			if CreateRoomSetStartGameNum then CreateRoomSetStartGameNum(0) end
		end
	end
	
	--MiniBase触发返回主菜单 返回到迷你基地           
	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_PreLeaveGame",  SandboxContext():SetData_Number("code", 0))
	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_LeaveGame",  SandboxContext():SetData_Number("code", 1))
		
	ClientMgr:gotoGame("MainMenuStage");	
	ReportChatCon:ResetUinBlacklist();
	
	getglobal("SetMenuFrame"):Hide();
	MiniUI_GameSettlement.CloseUI();

	Lite:InterceptFunctionsOutsideOnlineRoom();

	if GetInst("UIManager"):GetCtrl("AccountGameMode","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("AccountGameMode"):Refresh()
	end

	if GetInst("UIManager"):GetCtrl("MapEdit", "uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("MapEdit"):CloseBtnClicked()
	else
		MapEditExitAllState()
		-- 离开地图后需要清理复制选区数据
		if MapEditManager and MapEditManager.ClearCopyBlocks then
			MapEditManager:ClearCopyBlocks()
		end
	end

	-- 编辑工具进入触发器中选择世界中的对象时 直接返回到大厅 需要关闭的界面和重置数据（避免闪退）
	if FrameStack and FrameStack.findLastFrame("ModsLib") then
		GetInst("UIManager"):GetCtrl("ModsLib"):Close()
		ModEditorMgr:onleaveEditCurrentMod()
		FrameStack.remove(FrameStack.findLastFrame("ModsLib"))
	end
	if getglobal("MyModsEditorFrame") then
		MyModsEditorFrame_OnLeave()
	end

	if GetInst("UIManager"):GetCtrl("CloudServerReportingSys", "uiCtrlCloseList") then
		--如果曾经打开过举报 回到主菜单的时候 清理一下举报面板
		GetInst("UIManager"):GetCtrl("CloudServerReportingSys"):CleanData()
	end

	if not DeepLinkQueue:empty() then
		GetInst("ShopConfig"):InitServerCfg()
		GetInst("ShopConfig"):InitLocalCfg()
		DeepLinkQueue:dequeue();
	end

	threadpool:wait(gen_gid(),0.1,{tick=function()
		threadpool:notify("teamup.checkMinBtn")
	end})

	-- 场景触发活动上报: event_id = 1003  游戏玩法-地图-单位时间内地图内游戏时长累计达x （以个为单位）
	local interal = getkv("activitytrigger_entermap_time")
	if interal then
		interal = os.time() - interal
		setkv("activitytrigger_entermap_time", nil)
		-- 从地图中退出后上报
		ActivityTriggerReportEvent(1003, interal)
	end
	
	--竞技匹配不弹添加好友
	local isMatchTeamMap = (GetInst("MatchTeamupService") and (GetInst("MatchTeamupService"):IsMatchTeamupSonId(G_GetFromMapid())
	or GetInst("MatchTeamupService"):IsMatchTeamupMatherId(G_GetFromMapid())))
	
	if not isMatchTeamMap and check_apiid_ver_conditions(ns_data.business_def.uiscene_playmate_list) then
		threadpool:delay(1, function()
			GetInst("MiniUIManager"):OpenUI("BattleEndFriendList", "miniui/miniworld/UIBattleEndFriendList", "BattleEndFriendListAutoGen", {reportStandby1 = "离开游戏", fullScreen={Type="IgnoreEdge"}})
		end)
	end
end

-- 退出地图（打赏作者功能/离开地图时评分/主机关闭房间） by fym
-- eventType：
-- view : “直接关闭”按钮显示时上报
-- click: 点击"直接关闭"按钮时上报
function ExistGameReport(eventType,isreport)
	local cid = "0"
	if DeveloperFromOwid then
		cid = DeveloperFromOwid
	elseif standReportGameExitParam and standReportGameExitParam.cid then
		cid = standReportGameExitParam.cid
	end
	-- 房主或者单机模式
	local sceneid= "1003"
	local cardid= "MINI_GAMEOPEN_GAME_1"
	local compid= "Exit"
	local standby1 = tostring(GetInst("TeamVocieManage") :GetJoinTeamVocieTime())
	local standby2 = tostring(GetInst("TeamVocieManage") :GetVoiceAllTime())
	local standby3 = tostring(GetInst("TeamVocieManage") :GetSperkAllTime())

	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
		if eventType == "click" then
			standReportEvent(sceneid, cardid, compid, eventType, {cid = tostring(cid),standby1 = standby1,standby2 = standby2,standby3 = standby3})
		else
			standReportEvent(sceneid, cardid, compid, eventType, {cid = tostring(cid)})
		end
	-- 客机
	else
		if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then  -- 云服
			-- standReportEvent("1002", "MINI_CLOUDROOM_GAME_1", "Exit", eventType, {cid = tostring(cid)})
			standReportEvent("1001", "MINI_GAMEROOM_GAME_1", "Exit", eventType, {cid = tostring(cid)})
		elseif not IsStandAloneMode() then  -- 普通房间
			standReportEvent("1001", "MINI_GAMEROOM_GAME_1", "Exit", eventType, {cid = tostring(cid)})
		end
	end
	if eventType == "click" then
		standReportGameExitParam = standReportGameExitParam or {}
		standReportGameExitParam.sceneid = sceneid
		standReportGameExitParam.cardid = cardid
		standReportGameExitParam.compid = compid
	end

	if DeathFrameChangeDeathClick then
		DeathFrameChangeDeathClick(4)
	end
end

function HideNoviceGuideUI()
	getglobal("TaskFrame"):Hide();
	getglobal("GuideOperateFrame"):Hide();
	getglobal("NoviceStoryFrame"):Hide();
	getglobal("TaskGetEffectFrame"):Hide();
	getglobal("BlackBorderFrame"):Hide();
	getglobal("GuideHollowShade"):Hide();
	getglobal("GuideTargetFrame"):Hide();
	getglobal("PCGuideOperateFrame"):Hide();
	getglobal("PCInstructionsFrame"):Hide();
	getglobal("NoviceGuideEndFrame"):Hide();
end

function HideUI2GoMainMenu()
	if CurWorld and CurWorld:getOWID() == NewbieWorldId then
		HideNoviceGuideUI();
	end
	for i=1, #(t_BackMainMenuNeedHideFrame) do
		local frame = getglobal(t_BackMainMenuNeedHideFrame[i]);
		if frame:IsShown() then
			frame:Hide();
		end
	end
	HideAllFrame(nil, false);
end

function GameEndBtn_OnShow()
	standReportEvent("29", "SETTINGS_TOP", "Exitgame", "view")
end

function GameEndBtn_OnClick()
	standReportEvent("29", "SETTINGS_TOP", "Exitgame", "click")
	if ClientCurGame:isInGame() then
		if IsRoomOwner() then	--主机
			getglobal("SetMenuFrame"):Hide();
			MessageBox(5, GetS(221));
			getglobal("MessageBoxFrame"):SetClientString( "主机退出游戏" );
		else
			SetOutGameConfirm(2);
			--GameExit();
		end
	else
		SetOutGameConfirm(2);
	--	GameExit();
	end

end

function GameContinueBtn_OnShow()
	standReportEvent("29", "SETTINGS_TOP", "Countinuegame", "view")
end

--LLTODO:继续游戏按钮
function GameContinueBtn_OnClick()
	standReportEvent("29", "SETTINGS_TOP", "Countinuegame", "click")
	getglobal("SetMenuFrame"):Hide();
	-- Garry_Test()
end

function Garry_Test()
	local is_debug = LuaInterface and LuaInterface:isdebug() or false
	if not is_debug then
		return	
	end
	-- GetInst("ActivityDouluoManager"):OpenShop();
end

--反馈
function FeedBackBtn_OnClick()
	standReportEvent("29", "SETTINGS_TOP", "Feedback", "click")
	getglobal("SetMenuFrame"):Hide();
	GetInst("UIManager"):Open("Feedback");
end

function GameExit() 
	GetInst("TriggerMapInteractiveInterFace"):LeveGameGame()
	GetInst("NewDeveloperStoreInterface"):LeveaGame()
	GetInst("GameTimeLenthReport"):LeaveGame()
	GetInst("TeamVocieManage"):ExitGame()
	GetInst("MatchTeamupService"):ExitGame()
	check_global_timed_event()  --在线任务
	--房主直接退出客户端时通知玩家
	if ClientCurGame and ClientCurGame.isInGame and ClientCurGame:isInGame() and AccountManager then
		if AccountManager.isOWSnapLocked and not AccountManager:isOWSnapLocked(CurWorld:getOWID()) and
			Snapshot and Snapshot.saveCurSnapshot then
			Snapshot:saveCurSnapshot(99);
		end
	end

	-- 保存聊天记录中的avatar装扮信息
	-- ReleaseAvatarShareSeatInfo();

	--保存工坊搜索历史记录
	setkv("works_search",mapservice.searchRecordMap)
	getglobal("SetMenuFrame"):Hide();
	if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
		GetInst("MiniUIManager"):GetCtrl("ExitGameMenu"):CloseClick()
	end
	if DeleteResourceCenterDownLoadTmpDir then
		DeleteResourceCenterDownLoadTmpDir();
	end

	--退回大厅的时候 将截图 删掉
	if DeleteSnapshotTmpDir then
		DeleteSnapshotTmpDir()
	end

	-- 玩家下线
	if AccountGameModeClass and AccountGameModeClass.ReportOffLine then
		AccountGameModeClass:ReportOffLine(true) 
	end

	if LobbyMusicPlayer then
		LobbyMusicPlayer:StopPlay()
	end

	if UIEditorDef then 
		UIEditorDef:GameExit()
	end
	GetInst("UGCCommon"):GameExit()
	ClientMgr:gameExit();
		
end

--锁定截图
function ScreenShotFrame_OnClick()
	if sa_ImagePackerManager:HasCover(CurWorld:getOWID()) then
		--Xyang20210304 如果存在自定义封面，需要替换掉并且修改配置文件
		MessageBox(28, GetS(25769), function(btn)--二次确认
			if btn == 'left' then 	--确认
				GameSnapshot();
				ClientMgr:playSound2D("sounds/ui/button/camera.ogg", 1);
				sa_ImagePackerManager:ScreenShot(CurWorld:getOWID());
			elseif btn == 'right' then 	--取消
				
			end
		end)
	else
		GameSnapshot();
		ClientMgr:playSound2D("sounds/ui/button/camera.ogg", 1);
	end

	--[[
	if AccountManager:isOWSnapLocked(CurWorld:getOWID()) then
		AccountManager:setOWSnapLock(CurWorld:getOWID(), false);
		getglobal("ScreenShotFrameLockChecked"):Hide();
	else
		AccountManager:setOWSnapLock(CurWorld:getOWID(), true);
		getglobal("ScreenShotFrameLockChecked"):Show();
		Snapshot:saveCurSnapshot(99);
	end
	]]
end

--录像按钮显示/隐藏开关
function RecordSwitchBtn_OnClick( ... )
	Log("RecordSwitchBtn_OnClick:");
	local stopTexture = getglobal("GongNengFrameStartRecordBtnStop");
	local startTexture = getglobal("GongNengFrameStartRecordBtnStart");
	local bkgTexture=getglobal("GongNengFrameStartRecordBtnBk");
	local timeRecord=getglobal("GongNengFrameStartRecordBtnRecordTime");

	local state=AccountManager:getCurWorldRecordButton();
	local index=0;
	local btn=getglobal("GongNengFrameStartRecordBtn");
	if state==true then

		if stopTexture:IsShown() then
			VideoRecordStop()
		end
		AccountManager:setCurWorldRecordButton(false)
		index=0
		ShowGameTips(GetS(7537))

	else
		AccountManager:setCurWorldRecordButton(true)
		index=1
		ShowGameTips(GetS(7538));
	end

	--ClientMgr:setGameData("recordingInterface", state);

	-- if index==0 then
	-- 	statisticsGameEvent(40004, '%d', 0);  --录像关闭埋点
	-- end

	ShowVideoRecordBtn()
	-- 迷你基地-引流
	RefreshLobbyMiniBaseDrainageBt()
end

--触发器调试开关按钮点击事件埋点上报
g_TriggerDebugBtnEventManager = {
	--数据定义
	define = {
		roomMode = 1,
		roomModeEnum = {'single', 'multi',},
	},

	--点击'转化玩法地图'按钮, 转化为玩法运行模式
	converBtn_OnClick = function(self)
		--上报
		print("g_TriggerDebugBtnEventManager:");

		--开关状态
		local debugOnOff = ScriptSupportDebug:getDebugOnOff();

		--单机还是联机
		self.define.roomMode = 1;

		--缓存
		--[[
		cache = {
			timestamp = 11111111,	--时间戳
			count = 0,				--计数
		},
		]]

		local bNeedReport = false;
		local key = 'TriggerDebugBtnClick';
		local cache = getkv(key) or {timestamp = os.time(), count = 0};
		print("old cache:");
		print(cache);

		if debugOnOff then
			cache.count = cache.count or 0;
			cache.count = cache.count + 1;

			if cache.count <= 0 then
				cache.count = 1;
			end

			if cache.count % 5 == 1 then
				bNeedReport = true;
			end
		end

		if debugOnOff and bNeedReport then
			-- local roomModeDesc = self.define.roomModeEnum[self.define.roomMode];
			print("report:52017:");
			-- statisticsGameEvent(52017);

			cache.timestamp = os.time();
		end

		print("new cache:");
		print(cache);
		setkv(key, cache);
	end
};

--转换游戏模式
function ChangeGameModeBtn_OnClick()
	local preGameMode = WorldMgr:getGameMode()
	local _isTempMap = SetMenuFrame_CanAsTempCreate(CurWorld:getOWID());

	if this and this.GetName and this:GetName() == "SetMenuFrameLeftSetFrameChangeGameModeBtn" then
		if this.GetClientString and this:GetClientString() ~= "" then
			standReportEvent('1003', 'MINI_QUIT_MANU', this:GetClientString(), 'click', G_GetGameStandReportDataA())			 
		end
	end

	if _isTempMap then
		local _owid = CurWorld:getOWID()

		local worlddesc = AccountManager:getMyWorldList():findWorldDesc(_owid);
		if worlddesc then
			GetInst("TempMapInterface"):statisticsUseTempBegin(1,worlddesc.gwid,worlddesc.pwid,worlddesc.fromowid);
		end

		local callback = function(wid, wid2, ts, sign)
			EnterMainMenuInfo.CreateTempMapInGameOwid = _owid;
			EnterMainMenuInfo.CreateTempMapInGameNewWid = wid2;
			EnterMainMenuInfo.ts = ts;
			EnterMainMenuInfo.sign = sign;
			GoToMainMenu();
		end
		GetInst("TempMapInterface"):CheckCreateTempCondition(_owid,callback);

		return;
	end

	if CurWorld:isCreateRunMode() and CurMainPlayer:getSneaking() then
		CurMainPlayer:setSneaking(false);
		getglobal("PlayMainFrameSneak"):DisChecked();
		BPReportSneaking(false)
	end

	if CurWorld:isCreativeMode() and CurMainPlayer:isFlying() then	--创造模式
		CurMainPlayer:setFlying(false);
		getglobal("PlayMainFrameFly"):DisChecked();
	end

	CurMainPlayer:closeContainer();
	CurMainPlayer:changeGameMode(if_open_scene_fallback());
	if CurWorld:isGodMode() then
		LoadCreateBackpackDef();
	end
    if CurWorld:isGameMakerRunMode() then
        if CurMainPlayer:getCurToolID() == ITEM_COLORED_GUN or CurMainPlayer:getCurToolID() == ITEM_COLORED_EGG or CurMainPlayer:getCurToolID() == ITEM_COLORED_EGG_SMALL then
		    local curOpId=0;
		    local val=0;
		    curOpId, val = CurWorld:getRuleOptionID(33, curOpId, val);
            if val ~= 0 and CurMainPlayer:getTeam() ~= 0 then
                --切换当前手上tool的颜色为队伍颜色
                CurMainPlayer:setSelectedColor(GetTeamColor(CurMainPlayer:getTeam()))
                SetGunMagazine(0,0)
            end
        end

        --数据上报
        g_TriggerDebugBtnEventManager:converBtn_OnClick();
    end

	local hp = MainPlayerAttrib:getHP();
	if CurWorld:isGodMode() and MainPlayerAttrib:getHP() < 0 then	
		print("kekeke ChangeGameMode revive");
		ClientCurGame:getMainPlayer():revive(0);
	else
		print("kekeke ChangeGameMode revive hp:"..hp);
	end
	getglobal("SetMenuFrame"):Hide();
	if getglobal("BattleCountDownFrame"):IsShown() then
        getglobal("BattleCountDownFrame"):Hide();
    end

    --25号广告
  	UpdateAdvert25Btn();

	--重新加载地图
	--[[
	if CurWorld:isGameMakerRunMode() or CurWorld:isGameMakerMode() then --玩法模式或者玩法编辑模式 重新加载地图
		HideUI2GoMainMenu();
		for i=1, #(t_UIName) do
			local frame = getglobal(t_UIName[i]);
			frame:Hide();
		end
		IsCustomGameEnd = false;
		ClientMgr:gotoGame("MainMenuStage", SINGLE_RELOAD);
		ShowLoadingFrame();
	end	
	]]	
	
	--停止qq音乐触发器
	if GetInst("QQMusicTriggerManager") then
		GetInst("QQMusicTriggerManager"):StopQQMusic();
	end

	if CurWorld:isGameMakerRunMode() then -- 玩法模式转编辑模式
		if GetInst("MiniClubPlayerManager") then
			GetInst("MiniClubPlayerManager"):QuitUI();
		end
	end
	if WorldMgr:getGameMode() ~= preGameMode then
		if not HomelandCallModuleScript("HomelandCommonModule","IsHomeLandWorldById",G_GetFromMapid()) then
			ReportGamSwitchCall()
		end
	end
	
	if IsUGCEditMode() then
		local oid = "Turnedit"
		if CurWorld:isGameMakerRunMode() then
			oid = "Turnplay"
		end
		
		GetInst("UGCCommon"):StandReportEventUGCMain("MAIN_EDITING_SCENE", oid, "click")
	end
end

function ChangePublicBtn_OnClick()
	local publicType = RoomInteractiveData.RoomInfoMgr:GetRoomInfoParam('publicType')
	if publicType == 0 then
		RoomUIFrames_HostSetPublicType(1)
	else
		RoomUIFrames_HostSetPublicType(0)
	end
	SetMenuFrame_RefreshChangePublicBtn()
end

function CreateSecCloudBtn_OnClick()
	local fromowid = G_GetFromMapid()
	if GetInst("RoomService"):CheckMapSupportQuickupRent(fromowid) then		
		GetInst("ExitGameMenuInterface"):SetMapInfo(fromowid)
		GetInst("ExitGameMenuInterface"):StartCreateCloud()
		getglobal("SetMenuFrame"):Hide();
	end
end

function InGameCreateRoomBtn_Show()
	if IsArchiveMapCollaborationMode() then
		getglobal("SetMenuFrameLeftSetFrameCreateRoomBtnName"):SetText(GetS(25825))
	else
		getglobal("SetMenuFrameLeftSetFrameCreateRoomBtnName"):SetText(GetS(3795))
	end
end

function InGameCreateRoomBtn_OnClick()
	if IsStandAloneMode() then return end

	if IsArchiveMapCollaborationMode() then
		if CollaborationModeIllegalReportTime and AccountManager:getSvrTime() < CollaborationModeIllegalReportTime then
			ShowGameTipsWithoutFilter(GetS(25824, os.date("%Y-%m-%d %H:%M", CollaborationModeIllegalReportTime)), 3)
			return
		end

		if ns_data.IsGameFunctionProhibited("cr", 25824, 25824) then
			return
		end

		local worldid = CurWorld:getOWID()
		--GetInst("RoomService"):ReqMapPlayerCount({worldid}, {outtime=2})
		
		local rptTb = {
			cid 		= worldid,
			sceneid     = "1003",
			cardid		= "MINI_QUIT_MANU",
			compid		= "Friendplay"
		}
		local mapOwn
		local worldDesc = AccountManager:findWorldDesc(worldid)
		if not worldDesc then return end
		pcall(function()
			local standby1 = ""
			if worldDesc ~= nil then
				-- 是自己图
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
				standby1 = standby1..tostring(worldDesc.worldtype or worldDesc.gameLabel or 0)
			end
			rptTb.standby1 = standby1
		end)
		-- game_open上报
		standReportGameExitParam = table.clone(rptTb)
		standReportGameOpenParam = rptTb
		standReportEvent("1003", "MINI_QUIT_MANU", "Friendplay", "click", {cid = worldid})
		
		local gameMapMode = worldDesc.worldtype or worldDesc.gameLabel or 0
		
		GetInst("ReportGameDataManager"):NewGameLoadParam("1003","MINI_QUIT_MANU","Friendplay")
		GetInst("ReportGameDataManager"):SetGameMapOwn(mapOwn)
		GetInst("ReportGameDataManager"):SetGameNetType(GetInst("ReportGameDataManager"):GetGameNetTypeDefine().friendOnlineMode)
		GetInst("ReportGameDataManager"):SetGameMapMode(gameMapMode)
		
		local callback = function(flag, data)
			if flag == "right" then--确认
				if getglobal("LoadLoopFrame"):IsShown() then
					return
				end

				if AccountManager:loginRoomServer(false) then
					threadpool:wait(0.1)
					ShowLoadLoopFrame(true, "file:setting -- func:InGameCreateRoomBtn_OnClick")
					IsLanRoom = false
					IsCreatingColloborationModeRoom = true
					OpenRoom(worldDesc.worldid)
					--隐藏动作栏
					getglobal("ActionLibraryFrame"):Hide()
					getglobal("CharacterActionFrame"):Hide()
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

		local worldid = CurWorld:getOWID()
		local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(worldid)
		if mapIsBreakLaw == 1 then
			ShowGameTips(GetS(10562), 3)
			return;
		elseif mapIsBreakLaw == 2 then
			ShowGameTips(GetS(3633), 3)
			return
		end

		FastOpenOnLine(worldid)

		--隐藏动作栏
		getglobal("ActionLibraryFrame"):Hide()
		getglobal("CharacterActionFrame"):Hide()
	end
end
-----------------------------------------------------FeedBackFrame----------------------------------------
local FeedBackTex = ""
function FeedBackFrameCloseBtn_OnClick()
	getglobal("FeedBackFrame"):Hide();
end

function FeedBackFrameSubmitBtn_OnClick()
	local text = getglobal("FeedBackFrameTextEdit"):GetText();
	if text == "" then
		ShowGameTips(GetS(663), 3);
		return;
	end 
	
	local qq = getglobal("FeedBackFrameQQEdit"):GetText();
	local phoneNum = getglobal("FeedBackFramePhoneNumEdit"):GetText();

	AccountManager:initHistoryData();
	if AccountManager:getFeedBack() >= 3 then
		ShowGameTips(GetS(662), 3);
	else
		if AccountManager:requestFeedBackReq(text, qq, phoneNum) then
			ShowGameTips(GetS(664), 3);
			ClearFeedBack();
			AccountManager:addFeedBack();
			getglobal("FeedBackFrame"):Hide();
		else
			ShowGameTips(GetS(665), 3);
		end
	end
end

function ClearFeedBack()
	getglobal("FeedBackFrameQQEdit"):Clear();
	getglobal("FeedBackFramePhoneNumEdit"):Clear();
	getglobal("FeedBackFrameTextEdit"):Clear();
	FeedBackTex = "";
end

function FeedBackFrame_OnLoad()
	getglobal("FeedBackFrameContent"):SetText(GetS(656), 150,161,157);
end

function FeedBackFrame_OnShow()
	local text = getglobal("FeedBackFrameTextEdit"):GetText();	
	if text == "" then
		getglobal("FeedBackFrameContent"):Show();
	else
		getglobal("FeedBackFrameContent"):Hide();
	end
	if ClientCurGame:isInGame() then
		Log("FeedBackFrame_OnShow setOperateUI(true)");
		if not getglobal("FeedBackFrame"):IsReshow() then
		   ClientCurGame:setOperateUI(true);
		end
	end

	--LLTODO:海外版显示邮箱
	if isAbroadEvn() then
		FeedBackFrameShowEmail();
	end

	 ClientCurGame:setInSetting(true);
end

--LLTODO:海外版显示邮箱, 不显示QQ和手机
function FeedBackFrameShowEmail()
	local QQIcon = getglobal("FeedBackFrameQQIcon");
	local QQBkg = getglobal("FeedBackFrameQQBkg");
	local QQEdit = getglobal("FeedBackFrameQQEdit");

	local PhoneIcon = getglobal("FeedBackFramePhoneIcon");
	local PhoneBkg = getglobal("FeedBackFramePhoneNumBkg");
	local PhoneEdit = getglobal("FeedBackFramePhoneNumEdit");

	local EmailIcon = getglobal("FeedBackFrameEmailIcon");
	local EmailBkg = getglobal("FeedBackFrameEmailBkg");
	local EmailEdit = getglobal("FeedBackFrameEmailEdit");

	QQIcon:Hide();
	QQBkg:Hide();
	QQEdit:Hide();
	PhoneIcon:Hide();
	PhoneBkg:Hide();
	PhoneEdit:Hide();

	EmailIcon:Show();
	EmailBkg:Show();
	EmailEdit:Show();
end

function FeedBackFrame_OnHide()
	if ClientCurGame:isInGame() then
		Log("FeedBackFrame_OnHide setOperateUI(false)");
		if not getglobal("FeedBackFrame"):IsRehide() then
			ClientCurGame:setOperateUI(false);
		end
	end

	 ClientCurGame:setInSetting(false);

end

function FeedBackTextEdit_OnFocusLost()
	local text = ReplaceFilterString(this:GetText());
	this:SetText(text);
	if text == "" then
		getglobal("FeedBackFrameContent"):Show();
	else
		getglobal("FeedBackFrameContent"):Hide();
	end
end

function FeedBackTextEdit_OnFocusGained()
	getglobal("FeedBackFrameContent"):Hide();
end

function FeedBackTextEdit_OnTabPressed()
	if isAbroadEvn() then
		--LLTODO:海外版跳到邮箱
		SetCurEditBox("FeedBackFrameEmailEdit");
	else
		SetCurEditBox("FeedBackFrameQQEdit");
	end
end

function FeedBackFrameQQEdit_OnTabPressed()
	SetCurEditBox("FeedBackFramePhoneNumEdit");
end

function FeedBackFramePhoneNumEdit_OnTabPressed()
	SetCurEditBox("FeedBackFrameTextEdit");
end

--LLTODO:邮箱
function FeedBackFrameEmailEdit_OnTabPressed()
	SetCurEditBox("FeedBackFrameTextEdit");
end
----------------------------------------------------GameSetFrame---------------------------------------------------

function CalculateRotateOffset(offsetX,offsetY,angle)
	local rotateOffsetX = offsetX*math.cos(math.rad(angle))-offsetY*math.sin(math.rad(angle));
	local rotateOffsetY = offsetX*math.sin(math.rad(angle)) - offsetY*math.cos(math.rad(angle));
	return keepTwoDecimalPlaces(rotateOffsetX),keepTwoDecimalPlaces(rotateOffsetY);
end

function keepTwoDecimalPlaces(decimal)
        decimal = decimal * 10
        if decimal % 10 >= 5 then 
                decimal=math.ceil(decimal)
        else
                decimal=math.floor(decimal)
        end
		local temp1,temp2;
		temp1,temp2 =math.modf(decimal/10);
		if decimal > 0 and temp2 >= 0.5 then
			temp1 = temp1+1;
		elseif temp2 <= -0.5 then
			temp1 = temp1-1;
		end
		return temp1;
end

--设置switch ui的显示状态
local function SetGameModeRuleSwitchState(ruleId, state)
	local switchName
	if ruleId == GMRULE_SHOW_DAMAGE then
		switchName = "GameSetFrameBaseLayersScrollDamageSwitch"
	elseif ruleId == GMRULE_SHOW_BLOOD_BAR then
		switchName = "GameSetFrameBaseLayersScrollBloodSwitch"
	end
	if CurWorld ~= nil and CurWorld:isGameMakerRunMode() then
		local optionId, val = 0, 0
		optionId, val = CurWorld:getRuleOptionID(ruleId, optionId, val);
		if ruleId == GMRULE_SHOW_DAMAGE then
			--val == 0不显示伤害
			if val == 0 then
				if state then
					ShowGameTips(GetS(34255), 3);
				end
				SetSwitchBtnState(switchName, 0)
				return
			end
		else
			--optionId 是否显示伤害飘字  1显示  2不显示
			if val == 2 then
				if state then
					ShowGameTips(GetS(34257), 3);
				end
				SetSwitchBtnState(switchName, 0)
				return
			end
		end		
	end
	if state then
		if ruleId == GMRULE_SHOW_DAMAGE then
			ClientMgr:setGameData("damageswitch", state)
		else
			ClientMgr:setGameData("bloodswitch", state)
		end
	else
		if ruleId == GMRULE_SHOW_DAMAGE then
			SetSwitchBtnState(switchName, ClientMgr:getGameData("damageswitch"))
		else
			SetSwitchBtnState(switchName, ClientMgr:getGameData("bloodswitch"))
		end
	end
end

local SwitchBtn_OnMouseDown_Listeners = {}

function SwitchBtn_RegMouseDownListen(switchName, cb)
	if switchName and "function" == type(cb) then
		SwitchBtn_OnMouseDown_Listeners[switchName] = cb
	end
end

function SwitchBtn_UnRegMouseDownListen(switchName)
	if switchName then
		SwitchBtn_OnMouseDown_Listeners[switchName] = nil
	end
end

-- classical="1" rocker="0"
local Player_Max_Num = 40;
function SwitchBtn_OnMouseDown()
	local switchName 	= this:GetName();
	local state		= 0;
	local bkg 		= getglobal(this:GetName().."Bkg");
	local point 		= getglobal(switchName.."Point");	
	local treetitle = getglobal("GameSetFrameAdvancedTreeTitle");
	local radarSteeringWarning = getglobal("GameSetFrameControlRadarSteeringWarning");

	if SwitchBtn_OnMouseDown_Listeners[switchName] then
		SwitchBtn_OnMouseDown_Listeners[switchName](GetSwitchBtnState(switchName))
		return
	end

	if point:GetRealLeft() - bkg:GetRealLeft() > 20  then			--先前状态：开
		state = 0;
	else								--先前状态：关
		state = 1;
	end


	--允许群成员邀请好友加入群聊
	if string.find(switchName, "AuthoritySwitch") then
		local stiem = AccountManager:getSvrTime()

		if GetChatModel():GetGroupManageFrameType() == 1 or stiem - GetChatModel():GetClickAllowedInviteTime() > 5 then
			local groupdata
			local gFrameType = GetChatModel():GetGroupManageFrameType()
			if gFrameType == 1 then
				groupdata = FriendGroupClient.NewCreateInfo
			elseif gFrameType == 2 then
				groupdata = friendservice.group[CurrentGroupIndex]
			end
			GetChatModel():SetClickAllowedInviteTime(stiem)
			local isAllow
			if groupdata.isAllowMemberInvite == 1 then
				isAllow = 0
			else
				isAllow = 1
			end

			if gFrameType == 2 and groupdata and groupdata.groupid then
				ReqAllowGroupMemberInvite(groupdata.groupid,isAllow)
			elseif gFrameType == 1 then
				FriendGroupClient.NewCreateInfo.isAllowMemberInvite = isAllow
			end
			
			SetSwitchBtnState(switchName, state);
		else
			ShowGameTips(GetS(31028))
		end

		return
	end

	--登陆安全校验开关
	if string.find(switchName, "SafetyCheckSwitch") then
		local time = os.time()
		if time - AccountSafetyUIManage.SwitchLastClickTime > AccountSafetyUIManage.SwitchClickInterval then
			AccountSafetyUIManage.SwitchLastClickTime = time
			if IsEnableNewAccountSystem() then
				if NewLoginSystem_SetLoginSafetyCheckSwitchState(switchName, state) then
					SetSwitchBtnState(switchName, state)
				end
			else
				if SetLoginSafetyCheckSwitchState() then
					SetSwitchBtnState(switchName, state)
				end
			end
		else
			ShowGameTips(GetS(31028))
		end

		return
	end

	if string.find(switchName, "RoomVoiceSwitch") then			--加入语音房间开关
		-- 限制修改地图名:ShowGameTips('因您不符合政策要求，暂时无法使用此功能', 3);
        if FunctionLimitCtrl:IsNormalBtnClick(FunctionType.VOICE_ROOM) then
        	--常规
        	UpdateRoomVoiceState(state);
        else
        	--限制
        	return;
        end
		
		return;
	end

	if string.find(switchName, "QQPlayerSwitch") then	--qq音乐个人设置
		if GetInst("QQMusicPlayerManager") then
			if not GetInst("QQMusicPlayerManager"):CheckSelfSwitchCanOp(state==1) then
				ShowGameTips(GetS(37040))
				return
			else
				if state == 0 then--关闭时弹确认框
					MessageBox(5,"关闭音乐播放器将会清空已点音乐，\n确认关闭?",function(btn)
						if btn == "right" then
							GetInst("QQMusicPlayerManager"):ChangeMusicPlayerSwitchPersonal(false)
							SetSwitchBtnState(switchName, 0);
						else
							
						end
					end)
					local MessageBoxFrameLeftBtn = getglobal("MessageBoxFrameLeftBtn")
					local MessageBoxFrameRightBtn = getglobal("MessageBoxFrameRightBtn")
					local MessageBoxFrameLeftBtnName = getglobal("MessageBoxFrameLeftBtnName")
					local MessageBoxFrameRightBtnName = getglobal("MessageBoxFrameRightBtnName")
					if MessageBoxFrameLeftBtnName then
						MessageBoxFrameLeftBtnName:SetText("取消")	
					end
					if MessageBoxFrameRightBtnName then
						MessageBoxFrameRightBtnName:SetText("关闭")	
					end
					return 
				else
					if not IsMusicPlayerBlackList() then
						GetInst("QQMusicPlayerManager"):ChangeMusicPlayerSwitchPersonal(true)
					else
						-- 黑名单弹出提示窗
						ShowGameTipsWithoutFilter(GetS(37041), 3)
						return
					end
				end
			end
		end
	end

	if string.find(switchName, "MusicPlayerSwitch") then	--房间内qq音乐设置
		if GetInst("QQMusicPlayerManager") then
			local checkBoxUI = getglobal("RoomUIFrameSetOptionMusicPlayerAllowAdd")
			local checkBoxUIText = getglobal("RoomUIFrameSetOptionMusicPlayerAllowAllText")
			if state == 0 then--关闭时弹确认框
				MessageBox(5,"关闭音乐播放器将会清空已点音乐，\n确认关闭?",function(btn)
					if btn == "right" then
						GetInst("QQMusicPlayerManager"):ChangeMusicPlayerSwitch(false)
						SetSwitchBtnState(switchName, 0);
						checkBoxUI:SetGray(true)
						checkBoxUIText:SetTextColor(180, 180, 180)
					else
						
					end
				end)
				local MessageBoxFrameLeftBtn = getglobal("MessageBoxFrameLeftBtn")
				local MessageBoxFrameRightBtn = getglobal("MessageBoxFrameRightBtn")
				local MessageBoxFrameLeftBtnName = getglobal("MessageBoxFrameLeftBtnName")
				local MessageBoxFrameRightBtnName = getglobal("MessageBoxFrameRightBtnName")
				if MessageBoxFrameLeftBtnName then
					MessageBoxFrameLeftBtnName:SetText("取消")	
				end
				if MessageBoxFrameRightBtnName then
					MessageBoxFrameRightBtnName:SetText("关闭")	
				end
				return 
			else
				if GetInst("MiniClubPlayerManager") and GetInst("MiniClubPlayerManager"):IsOpen() then
					GetInst("QQMusicPlayerManager"):SetMusicVolume(0, true)
					
					return
				end
				
				if not IsMusicPlayerBlackList() then
					GetInst("QQMusicPlayerManager"):ChangeMusicPlayerSwitch(true)
					checkBoxUI:SetGray(false)
					checkBoxUIText:SetTextColor(61, 69, 70)
				else
					-- 黑名单弹出提示窗
					ShowGameTipsWithoutFilter(GetS(37041), 3)
					return
				end
			end
		end
	end
	--设置开关状态
	SetSwitchBtnState(switchName, state);


	if string.find(switchName, "ChatBubble") then				--聊天气泡窗口开关
		if string.find(switchName, "LocalChatBubbleSwitch") then --本地设置聊天气泡
			SetGameSetData_LocalChatBubble(state)
			standReportEvent("2901", "SETTING_OTHERS", "ChatPopUp", "click", {button_state = tostring(state)})
		else
			if CurWorld then
				local owId = CurWorld:getOWID()
				local data = getkv("map_chatBubble_switchState");
				if not data then
					data = {}
				end
				local mapIdStr = tostring(owId)
				data[mapIdStr] = state
				setkv("map_chatBubble_switchState", data)
			end
			RentPermitCtrl:SetChatBubbleSwitchState(state)
	
			local roomType = 1
			if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then
				roomType = 2
			end
			local eventTb = {
				cid = tostring(G_GetFromMapid()),
				standby1 = roomType,
				button_state = state,
				standby2 = 1,
			}
			if IsRoomOwner() then
				standReportEvent("1003", "MINI_CHAT_BUBBLE_NEW_SWITCH", "Switch", "click", eventTb)
			else
				standReportEvent("1001", "MINI_CHAT_BUBBLE_NEW_SWITCH", "Switch", "click", eventTb)
			end
		end
	elseif string.find(switchName, "PeaceSwitch") then			--和平模式
		ClientMgr:setGameData("peacemodel", state);
	elseif string.find(switchName, "MusicSwitch") then		--音乐开关
		ClientMgr:setGameData("musicopen", state);
	elseif string.find(switchName, "SoundSwitch") then		--音效开关
		ClientMgr:setGameData("soundopen", state);
	elseif string.find(switchName, "BaseVoiceSwitch") then		--音效开关
		ClientMgr:setGameData("voiceopen", state);	
	elseif string.find(switchName, "ReversalYSwitch") then		--反转Y轴
		ClientMgr:setGameData("reversalY", state);
	elseif string.find(switchName, "LeftHandedSwitch") then		--左撇子模式
		ClientMgr:setGameData("lefthanded", state);
	elseif string.find(switchName, "QHeartSwitch") then		--准心模式
		ClientMgr:setGameData("sight", state);
	elseif string.find(switchName, "AutoJumpSwitch") then		--自动跳跃
		ClientMgr:setGameData("autojump", state);
	elseif string.find(switchName, "CameraShakeSwitch") then	--镜头摇晃
		ClientMgr:setGameData("camerashake", state);
	elseif string.find(switchName,"RadarSteeringSwitch") then	--雷达转向
		if state == 0	then
			radarSteeringWarning:SetText(GetS(3908));
			getglobal("CompassPointer"):SetAngle(0);
		else
			radarSteeringWarning:SetText(GetS(3909));
			getglobal("CompassBkg"):SetAngle(90);
		end
		ClientMgr:setGameData("radarSteering",state);
	elseif string.find(switchName, "HideUISwitch") then		--隐藏界面
		ClientMgr:setGameData("hideui", state);
		if state == 1 then
			getglobal("GameSetFrame"):Hide();
			HideAllUI();
			if SceneEditorUIInterface then
				SceneEditorUIInterface:HideRootNode()
			end
		elseif state == 0 then
			for i=1, #(t_UIName) do
				local frame = getglobal(t_UIName[i]);
				frame:Show();
			end
			if SceneEditorUIInterface then
				SceneEditorUIInterface:ShowRootNode()
			end
			if IsUGCEditingHighMode() then
				getglobal("GongNengFrame"):Hide();
			end
			getglobal("GameSetFrame"):Hide();
			getglobal("UIHideFrame"):Hide();
			CurMainPlayer:setUIHide(false);
			if CUR_WORLD_MAPID == 1 then
				if not getglobal("InstanceTaskFrame"):IsShown() then
					getglobal("InstanceTaskFrame"):Show();
				end
			end
		end
	elseif string.find(switchName,"TreeShapeSwitch")	then		--树（方形）树（圆形)
		if state == 0	then
			treetitle:SetText(GetS(6011));
		else
			treetitle:SetText(GetS(6012));
		end
		ClientMgr:setGameData("treeshape",state);
		if ClientCurGame:isInGame() then
			local messageboxframe = getglobal("MessageBoxFrame");
			messageboxframe:SetFrameLevel(6500);
			MessageBox(5,GetS(3899));
			messageboxframe:SetClientString( "ReloadMap" );
		end
	elseif string.find(switchName, "VibrateSwitch") then		--震动开关
		ClientMgr:setGameData("vibrate", state);
	elseif string.find(switchName, "RoomDisableItemSwitch") then		--房间危险物品使用开关
		UpdateDisableItemSwitchState(state);
		local content = GetS(1228);
		if state == 0 then
			content = GetS(1229);
		end
		ClientCurGame:sendChat(content, 1);
		return;
	elseif string.find(switchName, "RandSpawnModeSwitch") then			--生存地图随机出生点开关
		UpdateOwnerRandSpawnModeState(state);
		local content = GetS(6123);
		if state == 0 then
			content = GetS(6122);
		end
		ClientCurGame:sendChat(content, 1);
		return;
	elseif string.find(switchName, "MicSwitch") then				--语音麦克风开关
		UpdateRoomMicState(state);
		return;
	elseif string.find(switchName, "SpeakerSwitch") then			--语音扬声器开关
		UpdateRoomSpeakerState(state);
		return;
	--elseif string.find(switchName, "ChipShowSwitch") then		--仓库显示碎片开关
		--ClientMgr:setGameData("showchip", state);
		--LoadStashPropList();
		--UpdateStashProp();	
	elseif string.find(switchName, "ShadowSwitch") then		--LLTODO:实时光影
		ClientMgr:setGameData("shadow", state);
	elseif string.find(switchName, "ReflectSwitch") then		--LLTODO:水面反射
		ClientMgr:setGameData("reflect", state);
		if ClientCurGame:isInGame() and not (IsInHomeLandMap and IsInHomeLandMap() ) then  --家园地图不弹重进提示框
			local messageboxframe = getglobal("MessageBoxFrame");
			messageboxframe:SetFrameLevel(6500);
			MessageBox(5,GetS(3899));
			messageboxframe:SetClientString( "ReloadMap" );
		end
	elseif string.find(switchName,"LimiteFpsSwitchBtn") then
		local bbkg 	= getglobal(this:GetName().."BBkg");
		if state == 1 then
			bkg:Show()
			--bbkg:Hide()
		else
			bkg:Hide()
			bbkg:Show()
		end
		ClientMgr:setGameData("limiteFps", state);
	elseif string.find(switchName, "PopUpsSwitch") then		--邀请弹窗
		ClientMgr:setGameData("popups", state);
		if state == 0 then
			CliearGamePopUps();
		end

		standReportEvent("2901", "SETTING_OTHERS", "InvitePopUp", "click", {button_state = tostring(state)})
	elseif string.find(switchName, "SwitchFPS") then        --FPS
		ClientMgr:setGameData("fpsbuttom", state);
		standReportEvent("2901", "SETTING_OTHERS", "FPS", "click", {button_state = tostring(state)})
	elseif string.find(switchName, "PhysxParamSwitch") then 	--物理指数
		ClientMgr:setGameData("physxparam",state);
		DebugMgr:setRenderInfoPhysx((state==1) and true or false);
		standReportEvent("2901", "SETTING_OTHERS", "MapStability", "click", {button_state = tostring(state)})
		--[[
	elseif string.find(switchName, "RecordingInterfaceSwitch") then        --录像
		ClientMgr:setGameData("recordingInterface", state);
		if state == 0 then
			-- statisticsGameEvent(40004, '%d', 0);  --录像关闭埋点
		end]]
		
		--ShowVideoRecordBtn();
	elseif string.find(switchName, "CanTraceSwitch") then 	--允许好友追踪
		ClientMgr:setGameData("cantrace", state);
		if ClientCurGame:isInGame() then
			ShowGameTips(GetS(5240), 3);
		end
		standReportEvent("2901", "SETTING_OTHERS", "FriendFollow", "click", {button_state = tostring(state)})
	elseif string.find(switchName, "DeveloperFloatSwitch") then	--开发者工具悬浮窗
		ClientMgr:setGameData("developerfloat", state);
	elseif string.find(switchName, "BloodSwitch") then --血条开关
		SetGameModeRuleSwitchState(GMRULE_SHOW_BLOOD_BAR, state)
	elseif string.find(switchName, "DamageSwitch") then --伤害数值开关
		SetGameModeRuleSwitchState(GMRULE_SHOW_DAMAGE, state)
	elseif string.find(switchName, "InviteSwitch") then --组队弹窗邀请
		--组队邀请弹窗开关，0-表示之前没这个字段，1-表示开，2-表示关
		local val = state == 0 and 2 or 1
		ClientMgr:setGameData("InviteSwitch", val);
		standReportEvent("2901", "SETTING_OTHERS", "TeamInvite", "click", {button_state = tostring(state)})
	elseif string.find(switchName, "RemindFriendAddSwitch") then --好友申请提醒
		SetGameSetData_RemindFriendAdd(state)
		GameSetFrame_RemindFriendAddSwitchShow()
		standReportEvent("2901", "SETTING_OTHERS", "FriendRequestNotice", "click", {button_state = tostring(state)})
	elseif string.find(switchName, "RecordSwitch") then --存档录像
		RecordSwitchOnClick()
	elseif string.find(switchName, "MicTeamSwitch") then --组队语音麦克风
		GetInst("TeamVocieManage"):UpdateTeamMicState(state)
		return
	elseif string.find(switchName, "SpeakerTeamSwitch") then --组队语音扬声器
		GetInst("TeamVocieManage"):UpdateTeamSpeakerState(state)
		return
	elseif string.find(switchName, "TeamAllVoiceSwitch") then --组队全部关闭开关
		GetInst("TeamVocieManage"):TeamAllVoiceSwitch(state)
		return
	end

	--传送点方块相关开关
	if string.find(switchName, "TransferFrame") or string.find(switchName, "TransferRuleSetFrame") then
		TransferBlockSwitch_OnClick(switchName, state)
	end

	--插件编辑界面开关
	if string.find(switchName, "SingleEditor") then
		EditorSwitchOnClick(switchName, state);
	elseif string.find(switchName, "MultiOption") then
		EditorMultiSwitchOnClick(switchName, state);
	elseif string.find(switchName, "ModsLibFeatureEdit") then
		GetInst("UIManager"):GetCtrl("ModsLibFeatureEdit"):SwitchBtnClicked(switchName, state)
	elseif string.find(switchName, "ModsLibActorShopItemDetail") then
		GetInst("UIManager"):GetCtrl("ModsLibActorShopItemDetail"):SwitchBtnClicked(switchName, state)
	elseif string.find(switchName, "PlayerCenterDataEditPage3RecommendStatus") then --个人中心-设置-个性化推荐
		G_SetRecommendationsOpen(state == 1)
	elseif string.find(switchName, "PlayerCenterDataEditPage3BestPartnerStatus") then --个人中心-设置-个性化推荐
		GetInst("BestPartnerPlayerCenter"):BestPartnerSwitch_OnClick(state)
	else
		ClientMgrAppalyGameSetData()
	end

	--刷怪方块界面开关
	if string.find(switchName, "CreateSwitch") then
		CreateSwitchTemplateBtn_OnClick(switchName, state)
	end

	--插件库NPC商店刷新时间开关
	if string.find(switchName, "NPCStoreEditor") then
		NPCStoreEditorRefreshBtn_OnClick(switchName, state)
	end	
end

function G_GetRecommendationsOpen()
	local value = ClientMgr:getGameData("PersonalizedRecommendations")
	return value ~= 2
end

function G_SetRecommendationsOpen(bv)
	--个性化开关，0-表示之前没这个字段，1-表示开，2-表示关
	ClientMgr:setGameData("PersonalizedRecommendations", bv and 1 or 2)
	-- 通知原生层个性化推荐开关状态变化
	NoticeNativeUserPersonalize()
end

function SetSwitchBtnState(switchName, state)
	local point = getglobal(switchName.."Point");
	local uiName = switchName .. "Name";
	if point then
		if state == 1 then
			point:SetPoint("right", switchName, "right", 0, 0);
	
			if HasUIFrame(uiName) then
				if string.find(switchName, "CanBurn") then
					getglobal(uiName):SetText(GetS(1558))
				else
					getglobal(uiName):SetText(GetS(21742));	--开:21742
				end
			end
		else
			point:SetPoint("left", switchName, "left", 0, 0);
	
			if HasUIFrame(uiName) then
				if string.find(switchName, "CanBurn") then
					getglobal(uiName):SetText(GetS(1559))
				else
					getglobal(uiName):SetText(GetS(21743));	--关:21743
				end
			end
		end
	
		getglobal(uiName):SetPoint("center", switchName.."Point", "center", 0, 0);
	end
	
end

function GetSwitchBtnState(switchName)
	local state		= 0;
	local bkg 		= getglobal(switchName.."Bkg");
	local point 		= getglobal(switchName.."Point");	
	if point and bkg then
		if point:GetRealLeft() - bkg:GetRealLeft() > 20  then
			state = 1;
		else
			state = 0;
		end
	end
	return state
end

--声音
function VolumeBar_OnValueChanged()
	local value = getglobal("GameSetFrameBaseLayersScrollVolumeBar"):GetValue();
	local ratio = value/100;
	local width   = math.floor(292*ratio)

	getglobal("GameSetFrameBaseLayersScrollVolumeBkg1"):ChangeTexUVWidth(width);
	getglobal("GameSetFrameBaseLayersScrollVolumeBkg1"):SetWidth(width);

	ClientMgr:setGameData("volume", value);
	ClientMgrAppalyGameSetData()

	SetSoundVolume(value)
end

--敏感度
function SensitivityBar_OnValueChanged()
	local value = getglobal("GameSetFrameControlSensitivityBar"):GetValue();
	local ratio = value/100
	local width = math.floor(292*ratio);

	getglobal("GameSetFrameControlSensitivityBarVolumeBkg1"):ChangeTexUVWidth(width);
	getglobal("GameSetFrameControlSensitivityBarVolumeBkg1"):SetWidth(width);

	ClientMgr:setGameData("sensitivity", value);
	ClientMgrAppalyGameSetData()
end

--亮度
function BrightnessBar_OnValueChanged()
	local value = getglobal("GameSetFrameBaseLayersScrollBrightnessBar"):GetValue();
	local ratio = value/100;
	local width   = math.floor(292*ratio);

	getglobal("GameSetFrameBaseLayersScrollBrightnessBkg1"):ChangeTexUVWidth(width)
	getglobal("GameSetFrameBaseLayersScrollBrightnessBkg1"):SetWidth(width);

	ClientMgr:setGameData("screenbright", value);
	ClientMgrAppalyGameSetData()
end

--配置
--[[
function ConfigureBar_OnValueChanged()
	local value = getglobal("GameSetFrameBaseConfigureBar"):GetValue();
	local uvWidth = math.floor(195*value/100)
	local width   = math.floor(316*value/100);

	local GameSetFrameBaseConfigureBkg1 = getglobal("GameSetFrameBaseConfigureBkg1")
	GameSetFrameBaseConfigureBkg1:SetTexUV(391, 892, uvWidth, 21);
	GameSetFrameBaseConfigureBkg1:SetWidth(width);

end

function ConfigureBar_OnMouseUp()
	local GameSetFrameBaseConfigureBar = getglobal("GameSetFrameBaseConfigureBar")
	local GameSetFrameBaseConfigureTitle = getglobal("GameSetFrameBaseConfigureTitle")
	local GameSetFrameAdvanced = getglobal("GameSetFrameAdvanced")

	local value = GameSetFrameBaseConfigureBar:GetValue();
	if value > 75 then
		GameSetFrameBaseConfigureBar:SetValue(100);
		ClientMgr:setGameData("configure", 3);
		ClientMgr:setGameData("view_distance", t_HighterSetData["view_distance"]);
		GameSetFrameBaseConfigureTitle:SetText(GetS(47));
		if GameSetFrameAdvanced:IsShown() then
			UpdateAdvancedSet();
		end
	elseif value > 25 then
		GameSetFrameBaseConfigureBar:SetValue(50);
		ClientMgr:setGameData("configure", 2);
		ClientMgr:setGameData("view_distance", t_MediumSetData["view_distance"]);
		GameSetFrameBaseConfigureTitle:SetText(GetS(48));
		if GameSetFrameAdvanced:IsShown() then
			UpdateAdvancedSet();
		end
	else
		GameSetFrameBaseConfigureBar:SetValue(0);
		ClientMgr:setGameData("configure", 1);
		ClientMgr:setGameData("view_distance", t_LowSetData["view_distance"]);
		GameSetFrameBaseConfigureTitle:SetText(GetS(49));
		if GameSetFrameAdvanced:IsShown() then
			UpdateAdvancedSet();
		end
	end
	ClientMgr:appalyGameSetData();
end
]]

--勾选按钮:视角配置
local m_TickBtn_ViewInfo = {
	preUIName = "GameSetFrameBaseLayersScrollViewTickBtn";
	{nameID = 52,},	--主视角
	{nameID = 51,},	--正视角
	{nameID = 50,},	--背视角
	{nameID = 80302,},	--动作视角
};

--勾选按钮点击
function SetFrameTickBtnTemplate_OnClick()
	local btnName = this:GetName();
	local id = this:GetClientID() or 1;
	print("btnName = ", btnName, ", id = ", id);

	if string.find(btnName, "BaseLayersScrollView") then					--视角
		TickBtnOnClick_ViewSet(id);
	elseif string.find(btnName, "AdvancedVDistance") then		--视野远近
		TickBtnOnClick_VDistanceSet(id);
	elseif string.find(btnName, "AdvancedFog") then				--雾效
		TickBtnOnClick_FogSet(id);
	elseif string.find(btnName, "AdvancedTreeShape") then		--树形状
		TickBtnOnClick_TreeShapeSet(id);
	elseif string.find(btnName, "AdvancedBlockShape") then				--方块形状
		TickBtnOnClick_BlockShapeSet(id);
	elseif string.find(btnName, "UISkin") then		--换肤
		print("换肤:");
		TickBtnOnClick_UISkinSet(id);
	elseif string.find(btnName, "ArchiveCap") then		--换肤
		print("容量:");
		TickBtnOnClick_ArchiveCap(id);
	end
end

--视角:勾选按钮点击
function TickBtnOnClick_ViewSet(id)
	print("TickBtnOnClick_ViewSet:", id);

	if ClientCurGame:isInGame() and CurMainPlayer and CurMainPlayer:isShapeShift() then
		--变形状态下锁定了视角不能切换
		ShowGameTips(GetS(4897), 3);
		return;
	end

	if ClientCurGame:isInGame() and CurWorld ~= nil and CurWorld:isGameMakerRunMode() and
	 ((ClientCurGame:getRuleOptionVal(9) >= 3 and ClientCurGame:getRuleOptionVal(9) ~= 8 and ClientCurGame:getRuleOptionVal(9) ~= 10 and ClientCurGame:getRuleOptionVal(9) ~= 11) or ClientCurGame:isLockViewMode()) then
		--锁定了视角不能切换?
		ShowGameTips(GetS(4897), 3);
		return;
	end
	if MainPlayerAttrib and MainPlayerAttrib:getAttrShapeShift() and id == 1 then -- 属性变身不能切主视角
		id = 2
	end
	TemplateTickBtn_SingleSelect(m_TickBtn_ViewInfo, id);

	local old_view = ClientMgr:getGameData("view");

	if id == 1 then
		--主视角
		ClientMgr:setGameData("view", 1);
	elseif id == 2 then
		--正视角
		ClientMgr:setGameData("view", 3);
	elseif id == 4 then
		--动作视角
		ClientMgr:setGameData("view", 4);
	else
		--背视角
		ClientMgr:setGameData("view", 2);
	end

	local viewChange = (old_view ~= ClientMgr:getGameData("view"));
	ClientMgr:appalyGameSetData(viewChange);
end

--视角
--[[
function ViewBar_OnValueChanged()
	local value = getglobal("GameSetFrameBaseViewBar"):GetValue();

	local ratio = value/100;
	local width   = math.floor(339*ratio);

	getglobal("GameSetFrameBaseViewBkg1"):ChangeTexUVWidth(width);	
	getglobal("GameSetFrameBaseViewBkg1"):SetWidth(width);
end

function ViewBar_OnMouseUp()
	local bar = getglobal("GameSetFrameBaseViewBar")
	local title = getglobal("GameSetFrameBaseViewTitle")

	local view = ClientMgr:getGameData("view");
	if ClientCurGame:isInGame() and CurWorld ~= nil and CurWorld:isGameMakerRunMode() and ClientCurGame:getRuleOptionVal(9) >= 3 then
		if view == 1 then
			bar:SetValue(0);
		elseif view == 2 then
			bar:SetValue(100);
		elseif view == 3 then
			bar:SetValue(50);
		end
		ShowGameTips(GetS(4897), 3);
		return;
	end
	

	local value = bar:GetValue();
	if value > 75 then
		bar:SetValue(100);
		ClientMgr:setGameData("view", 2);
		title:SetText(GetS(50));
	elseif value > 25 then
		bar:SetValue(50);
		ClientMgr:setGameData("view", 3);
		title:SetText(GetS(51));
	else
		bar:SetValue(0);
		ClientMgr:setGameData("view", 1);
		title:SetText(GetS(52));
	end

	local viewChange = view ~= ClientMgr:getGameData("view");
	ClientMgr:appalyGameSetData(viewChange);
end
]]

--视野远近:勾选按钮
local m_TickBtn_VDistanceInfo = {
	preUIName = "GameSetFrameAdvancedVDistanceTickBtn";
	--按钮名字		pc描述			手机描述
	{nameID = 21745, descID = 3554, descID_mobile = 858, },	--近
	{nameID = 21746, descID = 3553, descID_mobile = 859, },	--中
	{nameID = 21747, descID = 3552, descID_mobile = 860, },	--远
	{nameID = 21748, descID = 3551, descID_mobile = 856, },	--更远
	{nameID = 21749, descID = 3550, descID_mobile = 857, },	--最远
};

--视野:勾选按钮点击
function TickBtnOnClick_VDistanceSet(id)
	print("TickBtnOnClick_VDistanceSet:", id);

	TemplateTickBtn_SingleSelect(m_TickBtn_VDistanceInfo, id);

	local old_view = ClientMgr:getGameData("view_distance");
	local desc  = getglobal("GameSetFrameAdvancedVDistanceDesc")
	if id == 1 then
		ClientMgr:setGameData("view_distance", 1);
		desc:SetText(GetS(858));
	elseif id == 2 then
		ClientMgr:setGameData("view_distance", 2);
		desc:SetText(GetS(859));
	elseif id == 3 then
		ClientMgr:setGameData("view_distance", 3);
		desc:SetText(GetS(860));
	elseif id == 4 then
		ClientMgr:setGameData("view_distance", 5);
		desc:SetText(GetS(856));
	elseif id == 5 then
		ClientMgr:setGameData("view_distance", 8);
		desc:SetText(GetS(857));
	end

	local viewChange = old_view ~= ClientMgr:getGameData("view_distance");
	ClientMgr:appalyGameSetData(viewChange);
end

--雾效:勾选按钮
local m_TickBtn_FogInfo = {
	preUIName = "GameSetFrameAdvancedFogTickBtn";
	--按钮名字
	{nameID = 875, },	--关闭
	{nameID = 876, },	--淡雾
	{nameID = 877, },	--浓雾
};

function TickBtnOnClick_FogSet(id)
	print("TickBtnOnClick_FogSet:", id);

	TemplateTickBtn_SingleSelect(m_TickBtn_FogInfo, id);

	local old_view = ClientMgr:getGameData("fog");

	if id == 1 then
		ClientMgr:setGameData("fog", 0);
	elseif id == 2 then
		ClientMgr:setGameData("fog", 1);
	elseif id == 3 then
		ClientMgr:setGameData("fog", 2);
	end

	local viewChange = old_view ~= ClientMgr:getGameData("fog");
	ClientMgr:appalyGameSetData(viewChange);
end

--树形状:勾选按钮
local m_TickBtn_TreeShapeInfo = {
	preUIName = "GameSetFrameAdvancedTreeShapeTickBtn";
	--按钮名字
	{nameID = 6011, },	--方形
	{nameID = 6012, },	--圆形
};

--方块形状:勾选按钮
local m_TickBtn_BlockInfo = {
	preUIName = "GameSetFrameAdvancedBlockShapeTickBtn";
	--按钮名字
	{nameID = 86025, },	--圆形
	{nameID = 86026, },	--方形
};

function TickBtnOnClick_TreeShapeSet(id)
	print("TickBtnOnClick_TreeShapeSet:", id);

	TemplateTickBtn_SingleSelect(m_TickBtn_TreeShapeInfo, id);

	local old_view = ClientMgr:getGameData("treeshape");

	if id == 1 then
		ClientMgr:setGameData("treeshape", 0);
	elseif id == 2 then
		ClientMgr:setGameData("treeshape", 1);
	end

	local viewChange = old_view ~= ClientMgr:getGameData("treeshape");
	ClientMgr:appalyGameSetData(viewChange);

	if viewChange and ClientCurGame:isInGame() and not (IsInHomeLandMap and IsInHomeLandMap())  then  --家园地图不弹重进提示框
		--提示重进游戏生效
		local messageboxframe = getglobal("MessageBoxFrame");
		--messageboxframe:SetFrameLevel(6500);
		MessageBox(5,GetS(3899));
		messageboxframe:SetClientString( "ReloadMap" );
	end
end
function TickBtnOnClick_BlockShapeSet(id)

	TemplateTickBtn_SingleSelect(m_TickBtn_BlockInfo, id);

	local old_view = ClientMgr:getGameData("blockshape");

	if id == 1 then
		ClientMgr:setGameData("blockshape", 0);
	elseif id == 2 then
		ClientMgr:setGameData("blockshape", 1);
	end

	local viewChange = old_view ~= ClientMgr:getGameData("blockshape");
	ClientMgr:appalyGameSetData(viewChange);

	if viewChange and ClientCurGame:isInGame() and not (IsInHomeLandMap and IsInHomeLandMap())  then  --家园地图不弹重进提示框
		--提示重进游戏生效
		local messageboxframe = getglobal("MessageBoxFrame");
		--messageboxframe:SetFrameLevel(6500);
		MessageBox(5,GetS(3899));
		messageboxframe:SetClientString( "ReloadMap" );
	end
end

--初始化换肤勾选按钮背景
function InitUISkinTickBtnBkg()
	for i = 1, #m_TickBtn_UISkinInfo do
		getglobal("GameSetFrameBaseLayersScrollUISkinTickBtn" .. i .. "Bkg"):SetTexUV(m_TickBtn_UISkinInfo[i].texUV);
	end
end

--更新换肤提示
function UpdateUISkinTickBtnTitle()
	local strUpdate = ""
	local pUpdateTip = getglobal("GameSetFrameBaseLayersScrollUISkinUpdateTip")
	pUpdateTip:Hide()
	for i=1,#m_TickBtn_UISkinInfo do
		local skininfo = m_TickBtn_UISkinInfo[i]
		local strTip = ""
		if true == SkinConfigCtrl.isSkinNeedUpdate(skininfo.skinId + 1) then
			strTip = GetS(30041)
			if strUpdate ~= "" then
				strUpdate = strUpdate .. "、" .. GetS(skininfo.nameID)
			else
				strUpdate = strUpdate .. GetS(skininfo.nameID)
			end
		end
		-- 主题带（有更新）字样
		getglobal("GameSetFrameBaseLayersScrollUISkinTickBtn" .. i .. "Name"):SetText(GetS(skininfo.nameID) .. strTip)
	end
	-- 更新提示
	if strUpdate ~= "" then
		strUpdate = string.format((GetS(30038)),strUpdate)
		pUpdateTip:Show()
	end
	pUpdateTip:SetText(strUpdate)
end

--根据skinid获取UI皮肤名字描述
function GetUISkinNameDescBySkinId( skinId )
	for i=1,#m_TickBtn_UISkinInfo do
		local skininfo = m_TickBtn_UISkinInfo[i]
		if skinId == (skininfo.skinId + 1) then
			return GetS(skininfo.nameID)
		end
	end

	return ""
end

local skinId = 1;
local skinSetId = 1;
function TickBtnOnClick_UISkinSet(id)
	print("TickBtnOnClick_UISkinSet:", id);
	skinSetId = id
	--暂时只开放开发服
	local env = get_game_env();
	-- if env == 1 then

	-- else
	-- 	ShowGameTips(GetS(4038), 3);
	-- 	return;
	-- end

	local skininfo = m_TickBtn_UISkinInfo[id];
	skinId = tonumber(skininfo.skinId) or 1;	
	skinId = skinId + 1;
	SkinConfigCtrl.refreshCfgList();   ---- load skincfglist
	print("SkinConfigCtrl.data.skinlist1:",SkinConfigCtrl.data.skinlist)
	local skininfo = SkinConfigCtrl.getSkinInfoById(skinId)
	local needdownsize = skininfo["size"]
	local skinname = GetS(skininfo["desc"])
	local skinnamestr = skininfo["skinname"]
	local updateSkinName = skinnamestr .. "_update"
	local tips = GetS(30007)
		
	if string.find(skinnamestr,"bulitin") == nil and needdownsize > 0 then 
		-- 这里优先判断更新包
		local savePath = "data/http/skins/"..tostring(updateSkinName)..".zip"
		if not gFunc_isStdioFileExist(savePath) then
	    	savePath = "data/http/skins/"..tostring(skinnamestr)..".zip"
		end	       
		local md5 =  SkinConfigCtrl.getSkinMd5(skininfo) 
		print("exist md5:", gFunc_getSmallFileMd5(savePath),md5);
		if IsLocalUISkin() == true then
			-- 本地皮肤不需要下载		
		elseif gFunc_isStdioFileExist(savePath) and  gFunc_getSmallFileMd5(savePath) == md5 then 
			----exists 
			----SkinConfigCtrl.useSkin(skinnamestr)
			-----return;
		else
			gFunc_deleteStdioFile(savePath) --这里直接删掉吗？删掉,点取消的话，下次就不会提示更新了喔
			tips =   GetS(30012)..string.format(' %s(%.1fM)',skinname,needdownsize)
		end 	
	else
	
    end 	
		
	--确认切换UI风格吗
	getglobal("SkinDownloadMessageBox"):Show();
	getglobal("SkinDownloadMessageBoxRightBtnName"):SetText(GetS(3018));
	getglobal("SkinDownloadMessageBoxLeftBtnName"):SetText(GetS(3010));
	getglobal("SkinDownloadMessageBoxCenterBtnName"):SetText(GetS(3010));
	getglobal("SkinDownloadMessageBoxDesc"):SetText(tips, 55, 54, 49)
	getglobal("SkinDownloadMessageBoxRightBtn"):Show();
	getglobal("SkinDownloadMessageBoxLeftBtn"):Show();
	getglobal("SkinDownloadMessageBoxCenterBtn"):Hide();
	getglobal("SkinDownloadMessageBoxProgressText"):Hide()
	getglobal("SkinDownloadMessageBoxProgressBarBkg"):Hide()
	getglobal("SkinDownloadMessageBoxProgressTex"):Hide()		
				
end

function SkinTickUseSingleSelect(obj)
	if obj == 'default' then 
		TemplateTickBtn_SingleSelect(m_TickBtn_UISkinInfo, 1);	
	else
		TemplateTickBtn_SingleSelect(m_TickBtn_UISkinInfo, skinSetId);
	end
end 

function SkinDownloadMessageBoxLeftBtn_OnClick()
		local skininfo = SkinConfigCtrl.getSkinInfoById(skinId)	
		local skinnamestr = skininfo["skinname"]
		local updateSkinName = skinnamestr .. "_update"
		if string.find(skinnamestr,"bulitin") == nil  then
			-- 这里优先判断更新文件是否存在
			local savePath = "data/http/skins/"..tostring(updateSkinName)..".zip"
			if not gFunc_isStdioFileExist(savePath) then
				savePath = "data/http/skins/"..tostring(skinnamestr)..".zip"
			end
			local md5 =  SkinConfigCtrl.getSkinMd5(skininfo) 
			-- 本地皮肤不走下载
			if IsLocalUISkin() == true or (gFunc_isStdioFileExist(savePath) and  gFunc_getSmallFileMd5(savePath) == md5) then 
				
				-- 切换UI风格：参数：语言，当前皮肤风格Id，切换后的皮肤风格Id by fym
				local old = SkinConfigCtrl.getCurUseSkinId() - 1				
				-- statisticsGameEventNew(731, get_game_lang(), old, skinSetId)

	             print("exist skin:",savePath,skinId);
				 SkinConfigCtrl.useSkinId(skinId)
				 local tips = GetS(30007)
			     getglobal("SkinDownloadMessageBoxDesc"):SetText(tips, 55, 54, 49)	
				 getglobal("SkinDownloadMessageBox"):Hide();
				 SkinTickUseSingleSelect();
				 print("skin111111")
				 
			else	
				--下载的时候把“点击确定。。。”的提示隐藏
				getglobal("SkinDownloadMessageBoxDesc"):SetText("")	

				getglobal("SkinDownloadMessageBoxProgressBarBkg"):Show()
				getglobal("SkinDownloadMessageBoxProgressTex"):Show()
				getglobal("SkinDownloadMessageBoxProgressTex"):SetWidth(1)
			
				getglobal("SkinDownloadMessageBoxProgressText"):Show()
				local ssdowntips =  GetS(30014)..string.format(':%s%%','0')
			    getglobal("SkinDownloadMessageBoxProgressText"):SetText(ssdowntips)
				
				getglobal("SkinDownloadMessageBoxRightBtn"):Hide();
				getglobal("SkinDownloadMessageBoxLeftBtn"):Hide();
				getglobal("SkinDownloadMessageBoxCenterBtn"):Show();
				SkinConfigCtrl.useSkinId(skinId);

				--增加基础设置界面的下载提示
				getglobal("GameSetFrameBaseLayersScrollProgressBarBkg"):Show()
				getglobal("GameSetFrameBaseLayersScrollProgressTex"):Show()
				getglobal("GameSetFrameBaseLayersScrollProgressTex"):SetWidth(1)
				getglobal("GameSetFrameBaseLayersScrollProgressText"):Show()
				local sskinname = GetUISkinNameDescBySkinId(skininfo.id)
				ssdowntips =  GetS(30039)..string.format(':%s%%','0')
			    getglobal("GameSetFrameBaseLayersScrollProgressText"):SetText(sskinname .. ssdowntips)
				--下载的时候隐藏基础设置界面的更新提示，显示下载进度
				getglobal("GameSetFrameBaseLayersScrollUISkinUpdateTip"):Hide()
			end 		
		else
			print("skin22222222")
			-- 切换UI风格：参数：语言，当前皮肤风格Id，切换后的皮肤风格Id by fym
			local old = SkinConfigCtrl.getCurUseSkinId() - 1				
			-- statisticsGameEventNew(731, get_game_lang(), old, skinSetId)
			print("skinId = ", skinId);	
			SkinConfigCtrl.useSkinId(skinId)
			getglobal("SkinDownloadMessageBox"):Hide();
			SkinTickUseSingleSelect()
		end	
end 

function SkinDownloadMessageBoxRightBtn_OnClick()
    getglobal("SkinDownloadMessageBox"):Hide();
end 

function SkinDownloadMessageBoxCenterBtn_OnClick()
	getglobal("SkinDownloadMessageBox"):Hide();
end 

-- 检查已下载的主题是否需要更新
function checkSkinUpdate()
	local length = 0
	local skinrecordstr = gFunc_readBinaryFile("data/skinupdaterecord.data",length);
    if skinrecordstr then
    	skinrecordstr = JSON:decode(skinrecordstr);
    end
    local needUpdate = false
	for _,v in ipairs(m_TickBtn_UISkinInfo) do
		local skinId = v.skinId + 1
		if true == SkinConfigCtrl.isSkinNeedUpdate(skinId) then
			if skinrecordstr then
				-- 检查上次记录的提醒是否包含这个皮肤，包含就不再提示了
				local hasRecord = false
				for _,v in ipairs(skinrecordstr) do
					if v == SkinConfigCtrl.getSkinMd5(SkinConfigCtrl.getSkinInfoById(skinId)) then
						hasRecord = true
						break
					end
				end
				if not hasRecord then
					needUpdate = true --跟上次记录的提醒不一样，需要更新
					break
				end
			else
				needUpdate = true --需要更新
				break
			end
		end
	end

	return needUpdate
end

function SeedCopyBtn_OnClick()
	local text = getglobal("GameSetFrameAdvancedSeed"):GetText();
	if text == "" or text == nil then return end

	ClientMgr:clickCopy(text);
	ShowGameTips(GetS(739), 3);
end

--恢复默认
function GameSetFrameResetBtn_OnClick()
	if getglobal("GameSetFrameHotkey"):IsShown() then
		RecoveryDefaultHotKey();
	else
		if getglobal("GameSetFrameBase"):IsShown() then
			ClientMgr:setGameData("configure", t_DefaultSetData["configure"]);
			ClientMgr:setGameData("view", t_DefaultSetData["view"]);
			ClientMgr:setGameData("peacemodel", t_DefaultSetData["peacemodel"]);
			ClientMgr:setGameData("volume", t_DefaultSetData["volume"]);
			ClientMgr:setGameData("musicopen", t_DefaultSetData["musicopen"]);
			ClientMgr:setGameData("soundopen", t_DefaultSetData["soundopen"]);
			ClientMgr:setGameData("voiceopen", t_DefaultSetData["voiceopen"]);
			ClientMgr:setGameData("damageswitch", t_DefaultSetData["damageswitch"]);
			ClientMgr:setGameData("bloodswitch", t_DefaultSetData["bloodswitch"]);
			UpdateBaseSet();

			SetSoundVolume(t_DefaultSetData["volume"])
		elseif getglobal("GameSetFrameControl"):IsShown() then		
			ClientMgr:setGameData("sensitivity", t_DefaultSetData["sensitivity"]);
			ClientMgr:setGameData("reversalY", t_DefaultSetData["reversalY"]);
			ClientMgr:setGameData("lefthanded", t_DefaultSetData["lefthanded"]);
			ClientMgr:setGameData("sight", t_DefaultSetData["sight"]);
			ClientMgr:setGameData("autojump", t_DefaultSetData["autojump"]);
			ClientMgr:setGameData("camerashake", t_DefaultSetData["camerashake"]);
			ClientMgr:setGameData("vibrate", t_DefaultSetData["vibrate"]);
			ClientMgr:setGameData("classical", t_DefaultSetData["classical"]);
			ClientMgr:setGameData("rocker", t_DefaultSetData["rocker"]);
			ClientMgr:setGameData("radarSteering",t_DefaultSetData["radarSteering"]);
			getglobal("CompassPointer"):SetAngle(0);
			UpdateControlSet();
		elseif getglobal("GameSetFrameAdvanced"):IsShown() then
			ClientMgr:setGameData("screenbright", t_DefaultSetData["screenbright"]);
			ClientMgr:setGameData("view_distance", t_DefaultSetData["view_distance"]);
			ClientMgr:setGameData("shadow",t_DefaultSetData["shadow"]);
			ClientMgr:setGameData("reflect",t_DefaultSetData["reflect"]);
			ClientMgr:setGameData("limiteFps",t_DefaultSetData["limiteFps"]);
			ClientMgr:setGameData("fog", t_DefaultSetData["fog"]);
			ClientMgr:setGameData("treeshape",t_DefaultSetData["treeshape"]);
			UpdateAdvancedSet();
		elseif getglobal("GameSetFrameOther"):IsShown() then
			print("#@#GameSetFrameOther show")
			ClientMgr:setGameData("popups",t_DefaultSetData["popups"]);
			ClientMgr:setGameData("fpsbuttom",t_DefaultSetData["fpsbuttom"]);
			ClientMgr:setGameData("physxparam",t_DefaultSetData["physxparam"]);
			ClientMgr:setGameData("cantrace",t_DefaultSetData["cantrace"]);
			--ClientMgr:setGameData("developerfloat",t_DefaultSetData["developerfloat"]);
			UpdateOtherSet();
		end
		ClientMgrAppalyGameSetData()
	end	
end

--系统公告
function GameSetFrameNoticeBtn_OnClick()

	if  ns_start_notice.txt and #ns_start_notice.txt > 0 then
		getglobal("GameSetFrame"):Hide();
		SetNoticeInfoLua()
	else
		ShowGameTips(GetS(242), 3);
	end

	--local content = NoticeManager:getGameContent();
	--if content == "" then
		--ShowGameTips(GetS(242), 3);
	--else
		--getglobal("GameSetFrame"):Hide();
		--SetNoticeInfo();
	--end
end


function GameSetOfficialWebBtn_OnClick()
	if  ns_advert and ns_advert.server_config and ns_advert.server_config.official_web then
		g_openBrowserUrlAuth( ns_advert.server_config.official_web );
	end
end


--官方网站按钮是否可见
function setOfficialWeb()
	local apiid = ClientMgr:getApiId();	
	
	if  ns_advert and ns_advert.server_config and ns_advert.server_config.official_web then
		--Log( "" );
	else
		local web_jump_url = "";	
		if ns_advert and ns_advert.server_config and ns_advert.server_config.web then
			if  ns_advert.server_config.web[ apiid ] then
				web_jump_url = ns_advert.server_config.web[ apiid ];
			else
				web_jump_url = ns_advert.server_config.web.all or "";
			end
		end	

		if  type(web_jump_url)=='string' and #web_jump_url > 5 then  --http://mini1
			ns_advert.server_config.official_web = web_jump_url;
			getglobal("GameSetFrameOfficialWebBtn"):Show();
		else
			getglobal("GameSetFrameOfficialWebBtn"):Hide();
		end
	end

end

g_OtherSetItems = {
	{
		title = "PopUpsTitle",
		switch = "PopUpsSwitch",
	},
	{
		title = "CanTrace",
		switch = "CanTraceSwitch",
	},
	{
		title = "PhysxParam",
		switch = "PhysxParamSwitch",
	},
	{
		title = "TitleFPS",
		switch = "SwitchFPS",
	},
	{
		title = "DeveloperFloat",
		switch = "DeveloperFloatSwitch",
	},
	{
		title = "QQPlayer",
		switch = "QQPlayerSwitch",
	},
	{
		title = "InviteTitle",
		switch = "InviteSwitch",
	},
	{
		title = "LocalChatBubbleTitle",
		switch = "LocalChatBubbleSwitch",
	},
	{
		-- 改为好友申请提醒  2022.7.30
		title = "RemindFriendAddTitle",
		switch = "RemindFriendAddSwitch",
	},
	{
		title = "RecordTitle",
		switch = "RecordSwitch",
	},
	{
		title = "ArchiveCapTitle",
		switch = nil,
		wholeLine = true,
	}
}

function GameSetFrame_DeveloperFloatSwitchShow()
	--只有开发者模式下且单机模式的地图内才显示悬浮窗开关
	if ClientCurGame:isInGame() and CurWorld and CurWorld:isGameMakerMode() and AccountManager:getMultiPlayer() == 0 then
		getglobal("GameSetFrameOtherDeveloperFloat"):Show()
		getglobal("GameSetFrameOtherDeveloperFloatSwitch"):Show()
		getglobal("GameSetFrameOtherLine3"):Show()
	else
		getglobal("GameSetFrameOtherDeveloperFloat"):Hide()
		getglobal("GameSetFrameOtherDeveloperFloatSwitch"):Hide()
		getglobal("GameSetFrameOtherLine3"):Hide()
	end
end

function GameSetFrame_QQPlayerShow()
	-- 单机，游戏内，且配置开启，则显示
	if ClientCurGame:isInGame() 
	-- and GetInst("QQMusicPlayerManager"):GetGameMode() == 1  --联机和云服也有开关，但是只影响自己
	and GetInst("QQMusicPlayerManager"):IsMusicPlayerOpened() then
		getglobal("GameSetFrameOtherQQPlayer"):Show()
		getglobal("GameSetFrameOtherQQPlayerSwitch"):Show()
		getglobal("GameSetFrameOtherLine3"):Show()

		if ClientCurGame:isInGame() and CurWorld and CurWorld:isGameMakerMode() and AccountManager:getMultiPlayer() == 0 then
			getglobal("GameSetFrameOtherQQPlayer"):SetPoint("topleft", "GameSetFrameOther", "topleft", 551, 203)
			getglobal("GameSetFrameOtherQQPlayerSwitch"):SetPoint("left", "GameSetFrameOtherQQPlayer", "left", 124, 0)
		else
			getglobal("GameSetFrameOtherQQPlayer"):SetPoint("topleft", "GameSetFrameOther", "topleft", 31, 203)
			getglobal("GameSetFrameOtherQQPlayerSwitch"):SetPoint("left", "GameSetFrameOtherQQPlayer", "left", 124, 0)
		end
	else
		getglobal("GameSetFrameOtherQQPlayer"):Hide()
		getglobal("GameSetFrameOtherQQPlayerSwitch"):Hide()
		getglobal("GameSetFrameOtherLine3"):Hide()
	end
	
	-- 音乐方块隐藏设置按钮
	if GetInst("MiniClubPlayerManager") and GetInst("MiniClubPlayerManager"):IsOpen() then
		getglobal("GameSetFrameOtherQQPlayer"):Hide()
		getglobal("GameSetFrameOtherQQPlayerSwitch"):Hide()
		getglobal("GameSetFrameOtherLine3"):Hide()
	end
end

function GameSetFrame_InviteSwitchShow()
	local inviteTitle = getglobal("GameSetFrameOtherInviteTitle")
	if ClientCurGame:isInGame() then
		if CurWorld and CurWorld:isGameMakerMode() and AccountManager:getMultiPlayer() == 0 then
			inviteTitle:SetPoint("topleft", "GameSetFrameOther", "topleft", 31, 285)
		else
			if GetInst("QQMusicPlayerManager"):IsMusicPlayerOpened() then
				inviteTitle:SetPoint("topleft", "GameSetFrameOther", "topleft", 31, 285)
			else
				inviteTitle:SetPoint("topleft", "GameSetFrameOther", "topleft", 31, 203)
			end
		end
	else
		inviteTitle:SetPoint("topleft", "GameSetFrameOther", "topleft", 31, 203)
	end
	--组队邀请弹窗开关，0-表示之前没这个字段，1-表示开，2-表示关
	SetSwitchBtnState("GameSetFrameOtherInviteSwitch", ClientMgr:getGameData("InviteSwitch"));
end

function GameSetFrame_LocalChatBubbleSwitchShow()
	local title = getglobal("GameSetFrameOtherLocalChatBubbleTitle")
	local switch = getglobal("GameSetFrameOtherLocalChatBubbleSwitch")
	local isSingleGame = false -- 游戏中且单机模式下
	if CurWorld and AccountManager:getMultiPlayer() == 0 then
		isSingleGame = true
	end

	if if_cfg_switch_open_chat_bubble() and (not isSingleGame) then
		title:Show()
		switch:Show()
	else
		title:Hide()
		switch:Hide()
	end
end

function GameSetFrame_RemindFriendAddSwitchShow()
	local setFrameOther = "GameSetFrameOther"
	local ignoreSwitch = getglobal(setFrameOther .. "IgnoreFriendAddSwitch")
	local ignoreSwitchName = getglobal(setFrameOther .. "IgnoreFriendAddSwitchName")
	ignoreSwitchName:SetText(GetS(1112930))
	
	-- 显示
	local remindSwith = FriendMgr:GetFriendRemindSwitch()
	if remindSwith then
		ignoreSwitch:Show()
		standReportEvent("2901", "SETTING_OTHERS", "GameFriendRequestNotice", "view")
	else
		ignoreSwitch:Hide()
	end
	
	-- 选中态
	local tick = getglobal(ignoreSwitch:GetName() .. "Tick")
	local state = GetGameSetData_IgnoreFriendAdd()
	if state == 2 then
		tick:Hide()
	else
		tick:Show()
	end
end
		

function GameSetFrame_RecordSwitchShow()
	local title = getglobal("GameSetFrameOtherRecordTitle")
	local switch = getglobal("GameSetFrameOtherRecordSwitch")

	--不在游戏中 该设置直接隐藏 返回
	if not (ClientCurGame and ClientCurGame:isInGame()) then
		title:Hide()
		switch:Hide()
		return
	end

	local maptype
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then -- 单机或房主
		local wdesc = AccountManager:getCurWorldDesc()
		if wdesc then
			if wdesc.realowneruin == wdesc.owneruin then --自己地图
				if AccountManager:getMultiPlayer() == 0 then --单机
				--	自己地图  单机 编辑 创造 冒险 5 6 7
					if CurWorld:isCreativeMode() then--创造模式
						maptype = 6
					elseif CurWorld:isCreateRunMode() then--模拟冒险模式
						maptype = 7
					elseif CurWorld:isGameMakerMode() then-- 编辑模式
						maptype = 5
					elseif CurWorld:isGameMakerRunMode() then --玩法模式
						maptype = 11
					else
						maptype = 14
					end
				else --房主
					if IsArchiveMapCollaborationMode() then
						maptype = 8
					else
						maptype = 9
					end
				end
			else --他人地图
				if AccountManager:getMultiPlayer() == 0 then --单机
					local _isTempMap = SetMenuFrame_CanAsTempCreate(CurWorld:getOWID())
					if _isTempMap then
						maptype = 3 --模板地图
					else
						maptype = 0
					end
				else --房主
					maptype = 1
				end
			end
		end
	else -- 客机或云服
		-- 家园不要处理
		if not (IsInHomeLandMap and IsInHomeLandMap()) then
			local owid = G_GetFromMapid()
			local authorUin = getFromOwid(owid)
			if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then--云服
				if authorUin == AccountManager:getUin() then
				  -- 本人地图
				    maptype = 10
				else
					-- 他人地图
					maptype = 2
				end
			else --客机
				--好友联机
				if IsArchiveMapCollaborationMode() then
					maptype = 4
				else --非好友联机
					if authorUin == AccountManager:getUin() then
						-- 本人地图
						maptype = 13
					else
						--非本人地图
						maptype = 12
					end
				end
			end
		end
	end

	local isShow = true
	if maptype and (maptype == 2 -- 云服他人地图
		or maptype == 4 		 -- 好友联机
		or maptype == 10 	 	 -- 云服自己地图
		or maptype == 12 		 -- 客机非本人地图
		or maptype == 13) then	 -- 客机本人地图
		
		isShow = false
	end

	if IsOpenGameMapUploadFunc() and isShow then
		title:Show()
		switch:Show()
		RecordSwitchReport("view")
	else
		title:Hide()
		switch:Hide()
	end
end

function GameSetFrameOther_ReLayoutItems()
	GameSetFrame_DeveloperFloatSwitchShow()
	GameSetFrame_QQPlayerShow()
	GameSetFrame_InviteSwitchShow()
	GameSetFrame_LocalChatBubbleSwitchShow()
	GameSetFrame_RemindFriendAddSwitchShow()
	GameSetFrame_RecordSwitchShow()
	local cnt = 0
	local offsetX = 520
	local offsetY = 74
	for index, value in ipairs(g_OtherSetItems) do
		local obj = getglobal("GameSetFrameOther" .. value.title)
		if obj and obj:IsShown() then
			if value.wholeLine and cnt%2 ~= 0 then
				cnt = cnt + 1
			end
			local h = (obj:GetHeight()-20)/2
			obj:SetPoint("topleft", "GameSetFrameOther", "topleft", 31 + (cnt%2)*offsetX, 35 - h + math.floor(cnt/2)*offsetY)
			cnt = cnt + 1
		end
	end

	for index = 1, 4 do
		local line = getglobal("GameSetFrameOtherLine" .. index)
		if line then
			if cnt/2 > index then
				line:Show()
				if index > 1 then
					line:SetPoint("topleft", "GameSetFrameOtherLine" .. index-1, "topleft", 0, offsetY)
				end
			else
				line:Hide()
			end
		end
	end
end

function GameSetFrame_OnShow()
	standReportEvent("2901", "SETTING_POP_UP", "-", "view")
	print("GameSetFrame_OnShow:");
	press_btn("GameSetFrameBaseBtn");
	Friend_SetBoxDealMsg(false)

	if ClientCurGame:isInGame() and not getglobal("GameSetFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end
	setOfficialWeb();

	ClientCurGame:setInSetting(true);


	--改为读取配置文件 或者999渠道
	local apiid = ClientMgr:getApiId()
	if  ( ns_version and ns_version.btn and ns_version.btn.langbtn == 1) or (apiid == 999) then
		getglobal('GameSetFrameChangeLangBtn'):Show();
	end
	--UISkin换肤更新提示
	UpdateUISkinTickBtnTitle();

	GameSetFrame_DeveloperFloatSwitchShow()
	GameSetFrame_QQPlayerShow()
	GameSetFrame_InviteSwitchShow()
end

function GameSetFrame_OnLoad()
	print("GameSetFrame_OnLoad:");
	--关闭按钮
	UITemplateBaseFuncMgr:registerFunc("GameSetFrameBodyCloseBtn", GameSetFrameCloseBtn_OnClick, "设置页面关闭按钮");

	--视角勾选按钮初始化
	TemplateTickBtn_Init(m_TickBtn_ViewInfo);

	--视野远近勾选按钮初始化
	TemplateTickBtn_Init(m_TickBtn_VDistanceInfo);

	--雾效远近勾选按钮初始化
	TemplateTickBtn_Init(m_TickBtn_FogInfo);

	--树形状勾选按钮初始化
	TemplateTickBtn_Init(m_TickBtn_TreeShapeInfo);

	--方块形状勾选按钮初始化
	TemplateTickBtn_Init(m_TickBtn_BlockInfo);

	--UISkin换肤勾选按钮初始化
	TemplateTickBtn_Init(m_TickBtn_UISkinInfo);
	InitUISkinTickBtnBkg();
end

function InitUIBlockInfo()
	getglobal("GameSetFrameAdvancedBlockTitle"):Hide()
	getglobal("GameSetFrameAdvancedBlockShapeTickBtn1"):Hide()
	getglobal("GameSetFrameAdvancedBlockShapeTickBtn2"):Hide()
	local block_switch = ns_version.block_switch or {}
	if block_switch.showBlock and block_switch.showBlock == 0 then
		getglobal("GameSetFrameAdvancedBlockTitle"):Show()
		getglobal("GameSetFrameAdvancedBlockShapeTickBtn1"):Show()
		getglobal("GameSetFrameAdvancedBlockShapeTickBtn2"):Show()
	end
end

function GameSetFrameCloseBtn_OnClick()
	getglobal("GameSetFrame"):Hide();
end

function GameSetFrame_OnHide()
	Friend_SetBoxDealMsg(true)
	if ClientCurGame:isInGame() and not getglobal("GameSetFrame"):IsRehide()  then
		Log("GameSetFrame_OnShow setOperateUI(false)");
		ClientCurGame:setOperateUI(false);
	end

	ClientCurGame:setInSetting(false);
	ClearHotkey();
end

--tab按钮
local m_SetFrameTabBtnInfo = {
	{nameID = 587, uiName="GameSetFrameBaseBtn", pageUI = "GameSetFrameBase", reportName = "BasicTab"},				--基础
	{nameID = 588, uiName="GameSetFrameControlBtn", pageUI = "GameSetFrameControl", reportName = "ControlTab"},		--控制
	{nameID = 589, uiName="GameSetFrameAdvancedBtn", pageUI = "GameSetFrameAdvanced", reportName = "SeniorTab"},	--高级
	{nameID = 3963, uiName="GameSetFrameOtherBtn", pageUI = "GameSetFrameOther", reportName = "OthersTab"},			--其它
	{nameID = 3584, uiName="GameSetFrameHotkeyBtn", pageUI = "GameSetFrameHotkey", reportName = "HotkeyTab"},		--热键
};

function SetFrameTabBtnTemplate_OnClick(id)	
	if id then
		id = id;
	else
		id = this:GetClientID();
	end

	print("id = ", id);

	--切换按钮状态
	TemplateTabBtn2_SetState(m_SetFrameTabBtnInfo, id);

	if m_SetFrameTabBtnInfo[id] then
		standReportEvent("2901", "SETTING_POP_UP", m_SetFrameTabBtnInfo[id].reportName, "click")
	end

	if id == 0 then
		--初始化tab状态
		return;
	end
	
	-- 其他设置滚动组件显示设置
	if m_SetFrameTabBtnInfo[id] and  m_SetFrameTabBtnInfo[id].pageUI == "GameSetFrameOther" then 
		getglobal("OtherScrollPanel"):Show()
	else 
		getglobal("OtherScrollPanel"):Hide()
	end 

	--已经在当前页面, 直接返回
	if m_SetFrameTabBtnInfo[id] then
		local pageUI = m_SetFrameTabBtnInfo[id].pageUI;
		if getglobal(pageUI):IsShown() then
			print("is in current page, return:");
			-- return;
		end

		--切换页面
		for i = 1, #m_SetFrameTabBtnInfo do
			if i == id then
				getglobal(m_SetFrameTabBtnInfo[i].pageUI):Show();
			else
				getglobal(m_SetFrameTabBtnInfo[i].pageUI):Hide();
			end
		end
	end
end


--“基础”设置
function GameSetFrameBase_OnShow()
	print("GameSetFrameBase_OnShow:");
	getglobal("GameSetFrameBodyTitleName"):SetText(GetS(584));
	UpdateBaseSet();
	if ClientCurGame:isInGame() and not getglobal("GameSetFrameBase"):IsReshow() then
		Log("GameSetFrameBase_OnShow setOperateUI(true)");
		ClientCurGame:setOperateUI(true);
	end
	-- getglobal("MiniLobbyFrameBottomSkinUpdateTip"):Hide() --主动隐藏主页的更新提示
	HideMiniLobbySkinUpdateTip() --mark by hfb for new minilobby

	if gIsSingleGame then
		getglobal("GameSetFrameBaseLayersScrollMotifyName"):Hide()
	end
end

function GameSetFrameBase_OnHide()
	if ClientCurGame:isInGame() and not getglobal("GameSetFrameBase"):IsRehide() then
		Log("GameSetFrameBase_OnHide setOperateUI(false)");
		ClientCurGame:setOperateUI(false);
	end
end

--修改名字
function BaseMotifyName_OnClick()
	if AccountManager:getUin() == 0 then return end

	if ClientCurGame:isInGame() then
		ShowGameTips(GetS(125), 3);
	else
		if isAbroadEvn() or  IsOverseasVer() then --海外版本
			getglobal("NickModifyFrame"):Show()
		else
			local renameState = AccountManager.get_rename_review and AccountManager.get_rename_review() or 0 -- 昵称审核状态
			if renameState == 3 then
				ShowGameTips(GetS(20670), 3)
			else
				if checkModifyHeadNameSignatureOpened() then
					getglobal("NickModifyFrame"):Show()
				end
			end
		end
	end
end

--校验改名功能是否可用
function CheckCanAlterName()
	if not if_open_alter_name() then
		ShowGameTips(GetS(3995))
		return false
	end

	return true
end

function UpdateBaseSet()
	print("UpdateBaseSet");
	local uin = GetMyUin();
	if uin ~= 0 then
		getglobal("GameSetFrameBaseLayersScrollMini"):SetText(uin);
	else
		getglobal("GameSetFrameBaseLayersScrollMini"):SetText("");
	end

	uin = tonumber(uin);

	if uin and uin > 0 then
		getglobal("GameSetFrameBaseLayersScrollName"):SetText(ReplaceFilterString(AccountManager:getNickName()));	
	else
		getglobal("GameSetFrameBaseLayersScrollName"):SetText("");
	end

	local GameSetFrameBaseViewTitle = getglobal("GameSetFrameBaseLayersScrollViewTitle")
	local viewVal = ClientMgr:getGameData("view");	--视角
	local GameSetFrameBaseHideUITitle = getglobal("GameSetFrameBaseLayersScrollHideUITitle")
	local GameSetFrameBaseHideUISwitch = getglobal("GameSetFrameBaseLayersScrollHideUISwitch");

	if CurWorld ~= nil and CurWorld:isGameMakerRunMode() and CurMainPlayer and CurMainPlayer.getViewMode ~= nil then
		-- 开发者玩法模式下，视角显示纠正
		local vmode = CurMainPlayer:getViewMode()
		local vi = 0
		if vmode == 0 then
			vi = 1 --主视角
		elseif vmode == 2 then
			vi = 2 --正视角
		elseif vmode == 1 then
			vi = 3 --背视角
		elseif vmode == 3 then
			vi = 4 --动作视角
		end
		TemplateTickBtn_SingleSelect(m_TickBtn_ViewInfo, vi)
	else
		--视角
		if viewVal == 1 then
			--主视角
			TemplateTickBtn_SingleSelect(m_TickBtn_ViewInfo, 1);
		elseif viewVal == 2 then
			--背视角
			TemplateTickBtn_SingleSelect(m_TickBtn_ViewInfo, 3);
		elseif viewVal == 4 then
			--动作视角
			TemplateTickBtn_SingleSelect(m_TickBtn_ViewInfo, 4);
		else
			--正视角
			TemplateTickBtn_SingleSelect(m_TickBtn_ViewInfo, 2);
		end
	end
	SetGameModeRuleSwitchState(GMRULE_SHOW_DAMAGE)
	SetGameModeRuleSwitchState(GMRULE_SHOW_BLOOD_BAR)
	--UISkin换肤'm_TickBtn_UISkinInfo'
	--local uiskin = ClientMgr:getGameData("uiskin");
	local uiskin = SkinConfigCtrl.getCurUseSkinId() - 1;
	print("load_uiskin = ", uiskin);
	if uiskin == 2 then
		TemplateTickBtn_SingleSelect(m_TickBtn_UISkinInfo, 2);
	elseif uiskin == 3 then
		TemplateTickBtn_SingleSelect(m_TickBtn_UISkinInfo, 3);
	elseif uiskin == 4 then
		TemplateTickBtn_SingleSelect(m_TickBtn_UISkinInfo, 4);
	else
		--默认是1
		TemplateTickBtn_SingleSelect(m_TickBtn_UISkinInfo, 1);
	end

	if ClientCurGame:isInGame() then
		GameSetFrameBaseHideUISwitch:Show();
		GameSetFrameBaseHideUITitle:Show();
		SetSwitchBtnState("GameSetFrameBaseLayersScrollHideUISwitch", ClientMgr:getGameData("hideui"));
	else
		GameSetFrameBaseHideUISwitch:Hide();
		GameSetFrameBaseHideUITitle:Hide();
	end

	getglobal("GameSetFrameBaseLayersScrollBrightnessBar"):SetValue(ClientMgr:getGameData("screenbright"));			--画面亮度
	
	getglobal("GameSetFrameBaseLayersScrollVolumeBar"):SetValue(ClientMgr:getGameData("volume"));				--音量
	SetSwitchBtnState("GameSetFrameBaseLayersScrollMusicSwitch", ClientMgr:getGameData("musicopen"));		--音乐开关
	SetSwitchBtnState("GameSetFrameBaseLayersScrollSoundSwitch", ClientMgr:getGameData("soundopen"));		--音效开关
	SetSwitchBtnState("GameSetFrameBaseLayersScrollVoiceSwitch", ClientMgr:getGameData("voiceopen"));		--语音开关
	SetSwitchBtnState("GameSetFrameBaseLayersScrollHideUISwitch", ClientMgr:getGameData("hideui"));		    --隐藏UI开关(ClientMgr:getGameData("hideui"));

	SetSoundVolume(ClientMgr:getGameData("volume"))

	-- LLDO:是否显示环境切换按钮
	SettingFrameIsShowSwitchEnvBtn();
end

--“控制”设置
function GameSetFrameControl_OnLoad()
	if ClientMgr:isPC() then
		getglobal("GameSetFrameControlClassicalTitle"):Hide();
		getglobal("GameSetFrameControlClassicalSwitch"):Hide();
		getglobal("GameSetFrameControlRockerTitle"):Hide();
		getglobal("GameSetFrameControlRockerSwitch"):Hide();

		getglobal("GameSetFrameControlSensitivityTitle"):SetPoint("topleft", "GameSetFrameControl", "topleft", 31, 35);	
	else
		getglobal("GameSetFrameControlClassicalTitle"):Show();
		getglobal("GameSetFrameControlClassicalSwitch"):Show();
		getglobal("GameSetFrameControlRockerTitle"):Show();
		getglobal("GameSetFrameControlRockerSwitch"):Show();

		getglobal("GameSetFrameControlSensitivityTitle"):SetPoint("topleft", "GameSetFrameControl", "topleft", 31, 35);
	end
end

function GameSetFrameControl_OnShow()
	getglobal("GameSetFrameBodyTitleName"):SetText(GetS(585));
	UpdateControlSet();
	if ClientCurGame:isInGame() and not getglobal("GameSetFrameControl"):IsReshow() then
		Log("GameSetFrameControl_OnShow setOperateUI(true)");
		ClientCurGame:setOperateUI(true);
	end

	if ClientMgr:isMobile() then
		getglobal("GameSetFrameControlQHeartTitle"):Show()
		getglobal("GameSetFrameControlQHeartSwitch"):Show()
	else
		getglobal("GameSetFrameControlQHeartTitle"):Hide()
		getglobal("GameSetFrameControlQHeartSwitch"):Hide()
	end

	if ClientMgr:isMobile() then
		if UGCModeMgr and UGCModeMgr.IsUGCMode and UGCModeMgr:IsUGCMode() then
			getglobal("GameSetFrameControlClassicalTitle"):Hide();
			getglobal("GameSetFrameControlClassicalSwitch"):Hide();
			getglobal("GameSetFrameControlRockerTitle"):Hide();
			getglobal("GameSetFrameControlRockerSwitch"):Hide();

			getglobal("GameSetFrameControlSensitivityTitle"):SetPoint("topleft", "GameSetFrameControl", "topleft", 31, 35);	
		end
	end
end

function GameSetFrameControl_OnHide()
	if ClientCurGame:isInGame() and not getglobal("GameSetFrameControl"):IsRehide() then
		Log("GameSetFrameControl_OnHide setOperateUI(false)");
		ClientCurGame:setOperateUI(false);
	end
end

function UpdateControlSet()
	getglobal("GameSetFrameControlSensitivityBar"):SetValue(ClientMgr:getGameData("sensitivity"));		--灵敏度
	SetSwitchBtnState("GameSetFrameControlReversalYSwitch", ClientMgr:getGameData("reversalY"));	--反转Y轴
	SetSwitchBtnState("GameSetFrameControlLeftHandedSwitch", ClientMgr:getGameData("lefthanded"));	--左撇子模式
	SetSwitchBtnState("GameSetFrameControlQHeartSwitch", ClientMgr:getGameData("sight"));		--准心模式
	SetSwitchBtnState("GameSetFrameControlAutoJumpSwitch", ClientMgr:getGameData("autojump"));	--自动跳跃
	SetSwitchBtnState("GameSetFrameControlCameraShakeSwitch", ClientMgr:getGameData("camerashake"));	--镜头摇晃
	SetSwitchBtnState("GameSetFrameControlRadarSteeringSwitch",ClientMgr:getGameData("radarSteering"));	--雷达转向
--	SetSwitchBtnState("GameSetFrameControlClassicalSwitch", ClientMgr:getGameData("classical"));
--	SetSwitchBtnState("GameSetFrameControlRockerSwitch", ClientMgr:getGameData("rocker"));

	SetControlMoveSwithState();
end

function ControlMoveSwitch_OnClick()
	if ClientMgr:getGameData("classical") > 0 then	--经典模式
		ClientMgr:setGameData("classical", 0);
		ClientMgr:setGameData("rocker", 1);
	else
		ClientMgr:setGameData("classical", 1);
		ClientMgr:setGameData("rocker", 0);
	end

	SetControlMoveSwithState();
	ClientMgrAppalyGameSetData()
end

function SetControlMoveSwithState()
	local classicalCheck 	= getglobal("GameSetFrameControlClassicalSwitchCheck");
	local rockerCheck	 = getglobal("GameSetFrameControlRockerSwitchCheck");
	if ClientMgr:getGameData("classical") > 0 then	--经典模式
		rockerCheck:Hide();
		classicalCheck:Show();
	else
		classicalCheck:Hide();
		rockerCheck:Show();
	end

	local radarSteeringVal = ClientMgr:getGameData("radarSteering");	
	local radarSteeringWarning = getglobal("GameSetFrameControlRadarSteeringWarning");
	if radarSteeringVal == 0 then
		radarSteeringWarning:SetText("(" .. GetS(3908) .. ")");
	else
		radarSteeringWarning:SetText('(' .. GetS(3909) .. ')');
	end
end

--“高级”设置
function GameSetFrameAdvanced_OnShow()
	getglobal("GameSetFrameBodyTitleName"):SetText(GetS(586));
	InitUIBlockInfo()
	UpdateAdvancedSet();

	if ClientCurGame:isInGame() and not getglobal("GameSetFrameAdvanced"):IsReshow() then
		Log("GameSetFrameAdvanced_OnShow setOperateUI(true)");
		ClientCurGame:setOperateUI(true);
	end
end

function GameSetFrameAdvanced_OnHide()
	if ClientCurGame:isInGame() and not getglobal("GameSetFrameAdvanced"):IsRehide() then
		Log("GameSetFrameAdvanced_OnHide setOperateUI(false)");
		ClientCurGame:setOperateUI(false);
	end
end

function UpdateAdvancedSet()
	print("UpdateAdvancedSet:");
	--视野远近
	local viewDval = ClientMgr:getGameData("view_distance");					--视野距离
	if viewDval == 1 then
		TemplateTickBtn_SingleSelect(m_TickBtn_VDistanceInfo, 1);
	elseif viewDval == 2 then
		TemplateTickBtn_SingleSelect(m_TickBtn_VDistanceInfo, 2);
	elseif viewDval == 3 then
		TemplateTickBtn_SingleSelect(m_TickBtn_VDistanceInfo, 3);
	elseif viewDval == 5 then
		TemplateTickBtn_SingleSelect(m_TickBtn_VDistanceInfo, 4);
	elseif viewDval == 8 then
		TemplateTickBtn_SingleSelect(m_TickBtn_VDistanceInfo, 5);
	end

	--雾效
	local fogVal = ClientMgr:getGameData("fog");				
	if fogVal == 0 then
		TemplateTickBtn_SingleSelect(m_TickBtn_FogInfo, 1);
	elseif fogVal == 1 then
		TemplateTickBtn_SingleSelect(m_TickBtn_FogInfo, 2);
	elseif fogVal == 2 then
		TemplateTickBtn_SingleSelect(m_TickBtn_FogInfo, 3);
	end
	
	--树形状
	local treeShapeVal = ClientMgr:getGameData("treeshape");
	if treeShapeVal == 0 then
		TemplateTickBtn_SingleSelect(m_TickBtn_TreeShapeInfo, 1);
	else
		TemplateTickBtn_SingleSelect(m_TickBtn_TreeShapeInfo, 2);
	end

	--方块形状
	local treeShapeVal = ClientMgr:getGameData("blockshape");
	if treeShapeVal == 0 then
		TemplateTickBtn_SingleSelect(m_TickBtn_BlockInfo, 1);
	else
		TemplateTickBtn_SingleSelect(m_TickBtn_BlockInfo, 2);
	end

	if ClientMgr:isMobile() then
		getglobal("GameSetFrameAdvancedVibrateTitle"):Show();
		getglobal("GameSetFrameAdvancedVibrateSwitch"):Show();
		SetSwitchBtnState("GameSetFrameAdvancedVibrateSwitch", ClientMgr:getGameData("vibrate"));		--震动开关

		--实时光影/水面特效
		--[[
		if ClientMgr:isApple() then
			getglobal("GameSetFrameAdvancedShadowTitle"):Hide();
			getglobal("GameSetFrameAdvancedReflectTitle"):Hide();
			getglobal("GameSetFrameAdvancedShadowReflectTip"):Hide();
			getglobal("GameSetFrameAdvancedShadowSwitch"):Hide();
			getglobal("GameSetFrameAdvancedReflectSwitch"):Hide();
		else
			getglobal("GameSetFrameAdvancedShadowTitle"):Show();
			getglobal("GameSetFrameAdvancedReflectTitle"):Show();
			getglobal("GameSetFrameAdvancedShadowReflectTip"):Show();
			getglobal("GameSetFrameAdvancedShadowSwitch"):Show();
			getglobal("GameSetFrameAdvancedReflectSwitch"):Show();
		end
		]]
		getglobal("GameSetFrameAdvancedShadowTitle"):Show();
		getglobal("GameSetFrameAdvancedReflectTitle"):Show();
		getglobal("GameSetFrameAdvancedShadowReflectTip"):Show();
		getglobal("GameSetFrameAdvancedShadowSwitch"):Show();
		getglobal("GameSetFrameAdvancedReflectSwitch"):Show();
	else
		getglobal("GameSetFrameAdvancedVibrateTitle"):Hide();
		getglobal("GameSetFrameAdvancedVibrateSwitch"):Hide();

		--实时光影/水面特效
		if true then
			getglobal("GameSetFrameAdvancedShadowTitle"):Show();
			getglobal("GameSetFrameAdvancedReflectTitle"):Show();
			getglobal("GameSetFrameAdvancedShadowReflectTip"):Show();
			getglobal("GameSetFrameAdvancedShadowSwitch"):Show();
			getglobal("GameSetFrameAdvancedReflectSwitch"):Show();
		else
			--暂时屏蔽
			getglobal("GameSetFrameAdvancedShadowTitle"):Hide();
			getglobal("GameSetFrameAdvancedReflectTitle"):Hide();
			getglobal("GameSetFrameAdvancedShadowReflectTip"):Hide();
			getglobal("GameSetFrameAdvancedShadowSwitch"):Hide();
			getglobal("GameSetFrameAdvancedReflectSwitch"):Hide();
		end
	end
	
	--读取配置文件, 设置按钮状态
	SetSwitchBtnState("GameSetFrameAdvancedShadowSwitch", ClientMgr:getGameData("shadow"));		--实时光影
	SetSwitchBtnState("GameSetFrameAdvancedReflectSwitch", ClientMgr:getGameData("reflect"));	--水面特效
	if ClientMgr:hasGameData("limiteFps") == true then
		SetSwitchBtnState("GameSetFrameAdvancedLimiteFpsSwitchBtn", ClientMgr:getGameData("limiteFps")); --限制FPS
	else
		SetSwitchBtnState("GameSetFrameAdvancedLimiteFpsSwitchBtn", 1); --限制FPS
		ClientMgr:setGameData("limiteFps",1)
	end

	--[[
	local GameSetFrameAdvancedVibrateTitle = getglobal("GameSetFrameAdvancedVibrateTitle")
	local GameSetFrameAdvancedVibrateSwitch = getglobal("GameSetFrameAdvancedVibrateSwitch")
	if ClientCurGame:isInGame() then
		GameSetFrameAdvancedVibrateTitle:Show();
		GameSetFrameAdvancedVibrateSwitch:Show();
		SetSwitchBtnState("GameSetFrameAdvancedVibrateSwitch", ClientMgr:getGameData("vibrate"));	--震动开关
	else

		GameSetFrameAdvancedVibrateTitle:Hide();
		GameSetFrameAdvancedVibrateSwitch:Hide();
	end
	]]

	--种子	
	local seedFont 	= getglobal("GameSetFrameAdvancedSeed");
	local seedBkg	= getglobal("GameSetFrameAdvancedSeedBkg");
	local seedTitle	= getglobal("GameSetFrameAdvancedSeedTitle");
	local seedCopyBtn = getglobal("GameSetFrameAdvancedCopyBtn");

	seedFont:Show();
	seedBkg:Show();
	seedTitle:Show();
	if ClientCurGame:isInGame() then
		local gameType = AccountManager:getMultiPlayer();
		if gameType == 2 then --客机
			seedFont:Hide();
			seedBkg:Hide();
			seedTitle:Hide();
			seedCopyBtn:Hide();
		end
		local seed = AccountManager:getCurWorldSeed()
		if seed ~= "" then
			seedFont:SetText(seed);
			seedCopyBtn:Show();
		else		
			seedFont:SetText(GetS(58));
		end
	else
		seedFont:SetText(GetS(3592))
	end
end

function SeedNetworkDiagnose_OnClick()
	if Android:IsBlockArt() then
		JavaMethodInvokerFactory:obtain()
			:setClassName("org/appplay/lib/AppPlayNetwork")
			:setMethodName("networkDiagnose")
			:setSignature("()V")
			:call()
	end
end

function FPS_OnClick()
	DebugMgr:renderInfoSwitchFPS();
end

function Physx_OnClick( ... )
	DebugMgr:renderInfoSwitchPhysx();
end

--其它设置
function  GameSetFrameOther_OnLoad()
	-- 重置协议UI
	local resetAgreementUI = function(config, fisrtPosX)
		local relativeTo = "GameSetFrameOther"
		for i = 1, 5 do
			local name = "GameSetFrameOtherAgreement" .. i
			local ui = getglobal(name)
			if ui then
				if config[i] and config[i].text and config[i].jumpTo then
					local str = GetS(config[i].text) or ""
					if i == 1 then
						ui:SetPoint("bottomleft", relativeTo, "bottomleft", fisrtPosX or 90, -36)
					else
						ui:SetPoint("left", relativeTo, "right", 50, 0)
					end
					relativeTo = name
					local width = ui:GetTextExtentWidth(str)
					ui:SetWidth(width)
					ui:SetText(str, 77, 112, 117);
					ui:Show()
					ui:SetClientID(config[i].jumpTo)
				else
					ui:Hide()
				end				
			end
		end
	end

	local appid = ClientMgr:getApiId();
	if appid < 300 or appid == 999 then
		-- 国内
		local config = {
			[1] = { text = 3866, jumpTo = 1 },     -- 《游戏许可及服务协议》
			[2] = { text = 3868, jumpTo = 3 },     -- 《隐私政策》
			[3] = { text = 1000640, jumpTo = 5 },  -- 《隐私政策摘要》
			[4] = { text = 1000635, jumpTo = 4},   -- 《儿童隐私协议》
		}
		resetAgreementUI(config, 100)
	elseif appid > 300 then
		-- 海外
		local config = {
			[1] = { text = 9225, jumpTo = 1 },     -- 《游戏许可及服务协议》
			[2] = { text = 9226, jumpTo = 3 },     -- 《隐私政策》
		}
		resetAgreementUI(config, 400)
	end

	if ClientMgr:getGameData("fpsbuttom") == 1 then
		DebugMgr:setRenderInfoFPS(false);
	else
		DebugMgr:setRenderInfoFPS(true);
	end

	if ClientMgr:getGameData("physxparam")==1 then
		DebugMgr:setRenderInfoPhysx(true);
	else
		DebugMgr:setRenderInfoPhysx(false);
	end
end

function LoginScreenFrameAgreementCommon_OnClick()
	local id = this:GetClientID()
	if id == 1 then
		-- 《游戏许可及服务协议》
		LoginScreenFrameAgreement_OnClick()
	elseif id == 2 then
		-- 欧盟隐私条款链接1
		LoginScreenFrameAgreement2_OnClick()
	elseif id == 3 then
		-- 《隐私政策》
		LoginScreenFrameAgreement3_OnClick()
	elseif id == 4 then
		-- 《儿童隐私协议》
		LoginScreenFrameAgreement4_OnClick()
	elseif id == 5 then
		-- 《隐私政策摘要》
		OpenPage_PrivacyPolicySummary()
	end
end

function GameSetFrameOther_OnShow()
	standReportEvent("2901", "SETTING_OTHERS", "-", "view")
	getglobal("GameSetFrameBodyTitleName"):SetText(GetS(6212));
	UpdateOtherSet();

	if ClientMgr:getApiId() == 6 then	--电信
		getglobal("GameSetFrameOtherAbout"):Show();

		local version = ClientMgr:clientVersionToStr(ClientMgr:clientVersion())
		getglobal("GameSetFrameOtherAboutTitle"):SetText("迷你世界("..version..")");
		local text = "超好玩沙盒创造手游，随时随地联机大战\n联系客服：官方QQ群  238888083\n本游戏版权归深圳市迷你玩科技有限公司所有，游戏中的文字、图片等内容均为游戏版权所有者的个人态度或立场，炫彩互动（中国电信）对此不承担任何法律责任。"
		getglobal("GameSetFrameOtherAboutContent"):SetText(text, 255, 255, 255);
	else
		getglobal("GameSetFrameOtherAbout"):Hide();
	end

	if ClientCurGame:isInGame() and not getglobal("GameSetFrameOther"):IsReshow() then
		Log("GameSetFrameOther setOperateUI(true)");
		ClientCurGame:setOperateUI(true);
	end

	if Android:IsBlockArt() or ClientMgr:getApiId() == 999 or ClientMgr:getGameData("game_env") == 1 then 
		getglobal("GameSetFrameOtherNetworkDiagnose"):Show()
	else
		getglobal("GameSetFrameOtherNetworkDiagnose"):Hide()
	end 

	-- FPS按钮
	if(if_open_show_fps()) then
		getglobal("GameSetFrameOtherSwitchFPS"):Show();
		getglobal("GameSetFrameOtherTitleFPS"):Show();
	else
		getglobal("GameSetFrameOtherSwitchFPS"):Hide();
		getglobal("GameSetFrameOtherTitleFPS"):Hide();
	end
	--LLDO:注销账户按钮
	ShowCloseAccountBtn();

	--欧盟隐私条款
	ShowOverseaPolisyFrameFont();

	GameSetFrameOther_ReLayoutItems()
	
	GameSetFrameOtherAppPush_Show()
end

function GameSetFrameOther_OnHide()
	if ClientCurGame:isInGame() and not getglobal("GameSetFrameOther"):IsRehide() then
		Log("GameSetFrameOther_OnHide setOperateUI(false)");
		ClientCurGame:setOperateUI(false);
	end
end

function GameSetFrameOtherAboutMoreGameBtn_OnClick()
	SdkManager:moreGameEgame();
end

function GetGameSetData_LocalChatBubble()
	local state = ClientMgr:getGameData("LocalChatBubble")
	return (state == 0 or state == 1) and 1 or 2
end

function SetGameSetData_LocalChatBubble(state)
	if state == 0 then
		state = 2
	end
	ClientMgr:setGameData("LocalChatBubble", state)
end

function IgnoreFriendAddSwitch_OnClick()
	local tick = getglobal(this:GetName() .. "Tick")
	local state = 0
	if tick:IsShown() then
		tick:Hide()
		SetGameSetData_IgnoreFriendAdd(2)
	else
		tick:Show()
		state = 1
		SetGameSetData_IgnoreFriendAdd(1)
	end
	standReportEvent("2901", "SETTING_OTHERS", "GameFriendRequestNotice", "click", {button_state = tostring(state)})
end

-- 好友申请提醒
-- 0-表示之前没这个字段，1-表示开，2-表示关
function GetGameSetData_RemindFriendAdd()
	local state = ClientMgr:getGameData("RemindFriendAdd")
	return (state == 0 or state == 1) and 1 or 2
end

function SetGameSetData_RemindFriendAdd(state)
	if state == 0 then
		state = 2
	end
	ClientMgr:setGameData("RemindFriendAdd", state)
end

-- 好友申请弹窗
function GetGameSetData_IgnoreFriendAdd()
	if not FriendMgr:GetFriendRemindSwitch() then
		return 2
	end

	local state = ClientMgr:getGameData("IgnoreFriendAdd")
	return (state == 0 or state == 1) and 1 or 2
end

function SetGameSetData_IgnoreFriendAdd(state)
	if state == 0 then
		state = 2
	end
	ClientMgr:setGameData("IgnoreFriendAdd", state)
end

-- 存档录像
function GetRecordSwitchState()
	local state = AccountManager:getCurWorldRecordButton()
	if state then 
		state = 1 -- 开
	else		  
		state = 2 -- 关
	end
	return state
end

-- 点击存档录像按钮
function RecordSwitchOnClick()
	local stopTexture = getglobal("GongNengFrameStartRecordBtnStop")
	local state = AccountManager:getCurWorldRecordButton()
	if state == true then
		if stopTexture:IsShown() then
			VideoRecordStop()
		end
		AccountManager:setCurWorldRecordButton(false)
		ShowGameTips(GetS(7537))
		
		RecordSwitchReport("click", 0) -- 切换成关闭
	else
		AccountManager:setCurWorldRecordButton(true)
		ShowGameTips(GetS(7538))

		RecordSwitchReport("click", 1) -- 切换成打开
	end

	ShowVideoRecordBtn()
end

--第三个元素是默认选项，会被用到，修改的时候注意
--顺序必须从小到大
local m_TickBtn_ArchiveCapInfo = {
	preUIName = "GameSetFrameOtherArchiveCapTickBtn";
	--按钮名字	
	{nameID = 29007, __cap = 500},	--500MB
	{nameID = 29008, __cap = 1024},	--1GB
	{nameID = 29009, __cap = 3072},	--3GB
	{nameID = 29010, __cap = 5120},	--5GB
	{nameID = 29011, __cap = 8192},	--8GB
	{nameID = 29012, __cap = 10240},	--10GB
};

function GameSetArchiveCap_Init()
	--存档容量设置初始化
	TemplateTickBtn_Init(m_TickBtn_ArchiveCapInfo);

	local cap = GameSetArchiveCap_GetValue()

	local matched = false
	for index, value in ipairs(m_TickBtn_ArchiveCapInfo) do
		if cap == value.__cap then
			TemplateTickBtn_SingleSelect(m_TickBtn_ArchiveCapInfo, index);
			matched = true
			break
		end
	end

	if not matched then
		TemplateTickBtn_SingleSelect(m_TickBtn_ArchiveCapInfo, 3);
	end

	if GetInst("mainDataMgr"):AB_NewArchiveLobbyMain() then
		getglobal("GameSetFrameOtherArchiveCapTitle"):Show();
		for i = 1, #m_TickBtn_ArchiveCapInfo do
			getglobal("GameSetFrameOtherArchiveCapTickBtn" .. i):Show();
		end		
	else
		getglobal("GameSetFrameOtherArchiveCapTitle"):Hide();
		for i = 1, #m_TickBtn_ArchiveCapInfo do
			getglobal("GameSetFrameOtherArchiveCapTickBtn" .. i):Hide();
		end		
	end
end

function GameSetArchiveCap_SetValueById(id)
	local old_view = ClientMgr:getGameData("archive_cap_MBbyte");
	if m_TickBtn_ArchiveCapInfo[id] then
		ClientMgr:setGameData("archive_cap_MBbyte", m_TickBtn_ArchiveCapInfo[id].__cap);
	else
		ClientMgr:setGameData("archive_cap_MBbyte", m_TickBtn_ArchiveCapInfo[3].__cap);
		id = 3
	end
	local viewChange = old_view ~= ClientMgr:getGameData("archive_cap_MBbyte");
	ClientMgr:appalyGameSetData(viewChange);
	return id
end

--单位 MB
function GameSetArchiveCap_GetValue()
	if ClientMgr:hasGameData("archive_cap_MBbyte") then
		local value = ClientMgr:getGameData("archive_cap_MBbyte")
		if not (get_game_env() == 1 and value > 0) then --测试环境允许测试手动改配置文件设置，内网毕竟没那么多大地图
			value = math.max(value, m_TickBtn_ArchiveCapInfo[1].__cap)
		end
		return value
	else
		return m_TickBtn_ArchiveCapInfo[3].__cap
	end
end

--容量:勾选按钮点击
function TickBtnOnClick_ArchiveCap(id)
	print("TickBtnOnClick_ArchiveCap:", id);

	id = GameSetArchiveCap_SetValueById(id)
	TemplateTickBtn_SingleSelect(m_TickBtn_ArchiveCapInfo, id);
end

function UpdateOtherSet()
	SetSwitchBtnState("GameSetFrameOtherPopUpsSwitch",ClientMgr:getGameData("popups"));
	SetSwitchBtnState("GameSetFrameOtherSwitchFPS",ClientMgr:getGameData("fpsbuttom"));

	--物理指数开关
	SetSwitchBtnState("GameSetFrameOtherPhysxParamSwitch", ClientMgr:getGameData("physxparam"));

	--允许好友追踪
	SetSwitchBtnState("GameSetFrameOtherCanTraceSwitch", ClientMgr:getGameData("cantrace"));

	--开发者工具悬浮窗
	SetSwitchBtnState("GameSetFrameOtherDeveloperFloatSwitch",ClientMgr:getGameData("developerfloat"));

	-- qq音乐播放器
	local openstatus = GetInst("QQMusicPlayerManager"):GetOpenStatus()
	SetSwitchBtnState("GameSetFrameOtherQQPlayerSwitch", openstatus);

	--组队邀请窗口开关
	SetSwitchBtnState("GameSetFrameOtherInviteSwitch",ClientMgr:getGameData("InviteSwitch"));

	--聊天气泡
	SetSwitchBtnState("GameSetFrameOtherLocalChatBubbleSwitch", GetGameSetData_LocalChatBubble());	

	-- 好友申请提醒
	SetSwitchBtnState("GameSetFrameOtherRemindFriendAddSwitch", FriendMgr:GetFriendRemindSwitch() and 1 or 2)

	-- 存档录像
	SetSwitchBtnState("GameSetFrameOtherRecordSwitch", GetRecordSwitchState())

	--存档容量设置初始化
	GameSetArchiveCap_Init()
end

------------------------------------GameSetFrameHotkey----------------------
local Hotkey_Type_Max_Num = 5;
local Hotkey_Item_Max_Num = 15
local t_HotKeyType = {};
local t_HotKey = {};
local CurSetHotKey = nil;	--当前要设置的热键控件名
function ModifyKey(keycode)
--	ShowGameTips(keycode, 3);
	if keycode == 27 and ClientCurGame:isInModifyKey() then	--按esc键 退出改键状态
		ClearHotkey();
		return;
	end

	local keyName = DefMgr:getKeyName(keycode);
	if keyName == "" then
		ShowGameTips(GetS(3586), 3);
	else
		local keyName = getglobal(CurSetHotKey):GetClientString();

		local conflictKeyName = ClientMgr:getHotkeyName(keycode);
		if conflictKeyName ~= "" and keyName ~= conflictKeyName then	--有冲突的热键
			local hotkeyDef = DefMgr:getHotkeyDefByKey(conflictKeyName);
			if hotkeyDef ~= nil then
				ShowGameTips(GetS(3587)..hotkeyDef.Name);
				ClientMgr:setOneKeyBindCode(conflictKeyName, 0);
			end
		end

		ClientMgr:setOneKeyBindCode(keyName, keycode);
		UpdateHotkeyBox();
		ClearHotkey();
	end
end

function HotkeyItemTemplateChooseBtn_OnClick()
	local checkBkg = getglobal(this:GetName().."CheckBkg");
	local name = getglobal(this:GetName().."Name");
	if ClientCurGame:isInModifyKey() then
		print("111:");
		local frameName = CurSetHotKey;
		ClearHotkey();
		if frameName == nil or this:GetParent() ~= frameName then			
			checkBkg:Show();
			name:SetTextColor(55, 54, 49);
			ShowGameTips(GetS(3591), 3);
			ClientCurGame:setInModifyKey(true);
			CurSetHotKey = this:GetParent();
		end
	else
		print("222:");
		checkBkg:Show();
		name:SetTextColor(55, 54, 49);
		ShowGameTips(GetS(3591), 3);
		ClientCurGame:setInModifyKey(true);
		CurSetHotKey = this:GetParent();
	end
end

function RecoveryDefaultHotKey()
	local num = DefMgr:getHotkeyNum();
	for i=1, num do
		local hotkeyDef = DefMgr:getHotkeyDef(i);
		if hotkeyDef ~= nil then
			ClientMgr:setOneKeyBindCode(hotkeyDef.FuncName, hotkeyDef.DefaultCode);
		end
	end

	UpdateHotkeyBox();
end

function UpdateHotkeyBox()
	print("UpdateHotkeyBox:");
	local height = 10;

	local typeNum = #(t_HotKeyType);
	for i=1, Hotkey_Type_Max_Num do
		local type = getglobal("HotkeyBoxType"..i);
		if i <= typeNum then
			type:Show();
			local title = getglobal(type:GetName().."Title");
			title:SetText(t_HotKeyType[i].Name);

			height = height + UpdateHotkey2Type(t_HotKeyType[i].Type, i);
			print("i = ", i, ", height = ", height);
		else
			type:Hide();
		end
	end

	if height < 441 then
		getglobal("HotkeyBoxPlane"):SetHeight(441);
	else
		getglobal("HotkeyBoxPlane"):SetHeight(height);
	end
end

function GetHotkey2Type(type)
	local t_hotkey = {};
	for i=1, #(t_HotKey) do
		if t_HotKey[i].Type == type then
			table.insert(t_hotkey, t_HotKey[i]);
		end
	end

	return t_hotkey;
end 

function UpdateHotkey2Type(type, index)
	local typeName = getglobal("HotkeyBoxType"..index);
	local t_hotkey = GetHotkey2Type(type);
	local num = #(t_hotkey);

	for i=1, Hotkey_Item_Max_Num do
		local hotkeyItem = getglobal(typeName:GetName().."Item"..i);
		if i <= num then
			hotkeyItem:Show();
			hotkeyItem:SetClientString(t_hotkey[i].FuncName);

			local desc 		= getglobal(hotkeyItem:GetName().."Desc");
			local chooseName	= getglobal(hotkeyItem:GetName().."ChooseBtnName");
				
			desc:SetText(t_hotkey[i].Name);	
			local code = ClientMgr:getGameHotkey(t_hotkey[i].FuncName);
			if code < 0 then
				code = t_hotkey[i].DefaultCode;
			end

			local keyName = DefMgr:getKeyName(code);
			if keyName == "" then
				chooseName:SetText(GetS(3585));
			else
				chooseName:SetText(keyName);
			end
		else
			hotkeyItem:SetClientString("");
			hotkeyItem:Hide();
		end
	end

	local height = 0;
	local row = math.ceil(num / 3);
	height = row * 62 + 73;

	--调整组高度
	typeName:SetHeight(height);

	return height;
end

function GameSetFrameHotkey_OnLoad()
	for i=1, Hotkey_Type_Max_Num do
		local type = getglobal("HotkeyBoxType"..i);
		if i == 1 then
			type:SetPoint("top", "HotkeyBoxPlane", "top", 0, 0);
		else
			local index = i-1;
			local preType = getglobal("HotkeyBoxType"..index);
			type:SetPoint("top", preType:GetName(), "bottom", 0, 0);
		end
	end

	LoadHotkeyTable();
end

function GameSetFrameHotkey_OnShow()
	standReportEvent("2901", "SETTING_POP_UP", "HotkeyTab", "view")
	getglobal("GameSetFrameBodyTitleName"):SetText(GetS(1338));
	if ClientCurGame:isInGame() and not getglobal("GameSetFrameHotkey"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end
	SetArchiveDealMsg(false);
	ClearHotkey();
	if #t_HotKey == 0 then
		GameSetFrameHotkey_OnLoad()
	end
	getglobal("HotkeyBox"):resetOffsetPos();
	UpdateHotkeyBox();
end

function ClearHotkey()
	if CurSetHotKey ~= nil then
		local bkg = getglobal(CurSetHotKey.."ChooseBtnCheckBkg");
		local name = getglobal(CurSetHotKey.."ChooseBtnName");
		bkg:Hide();
		name:SetTextColor(255, 216, 0);
	end

	ClientCurGame:setInModifyKey(false);
	CurSetHotKey = nil;
end

function GameSetFrameHotkey_OnHide()
	if ClientCurGame:isInGame() and not getglobal("GameSetFrameHotkey"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
	SetArchiveDealMsg(true);
	ClearHotkey();
end

function GetHotkeyType(type)
	for i=1, #(t_HotKeyType) do
		if t_HotKeyType[i].Type == type then
			return i, true;
		end
	end

	return 0, false;
end

function HasHotkey(index, id)
	for i=1, #(t_HotKeyType[index].KeyIDs) do
		if id == t_HotKeyType[index].KeyIDs[i] then
			return true;
		end
	end

	return false;
end

function LoadHotkeyType(hotkeyDef)
	local index, hasType = GetHotkeyType(hotkeyDef.Type);
	if not hasType then
		table.insert(t_HotKeyType, {Type=hotkeyDef.Type, Name=hotkeyDef.TypeName, KeyIDs={hotkeyDef.ID}});
	else
		if not HasHotkey(index, hotkeyDef.ID) then
			table.insert(t_HotKeyType[index].KeyIDs, hotkeyDef.ID);
		end
	end
end

function LoadHotkeyTable()
	t_HotKeyType = {};
	t_HotKey = {};
	local num = DefMgr:getHotkeyNum();
	for i=1, num do
		local hotkeyDef = DefMgr:getHotkeyDef(i);
		if hotkeyDef ~= nil then
			LoadHotkeyType(hotkeyDef);
			table.insert(t_HotKey, hotkeyDef);
		end
	end
end
---------------------------------NickModifyFrame-------------------------------
local Free_Modify_Num 	= 1;
--local ModifyCost	= 300;
function NickModifyFrame_OnShow()
	local edit 	= getglobal("NickModifyFrameContentNameEdit");
	local costFont 	= getglobal("NickModifyFrameContentNeedCost");
	local modifyNum = AccountManager:getAccountData():getNickModify();
	edit:Clear();
	local enablealternick = if_open_alter_name();
	edit:enableEdit(enablealternick); 

	local env = get_game_env()
	local is_debug = LuaInterface and LuaInterface:isdebug() or false
	local is_UseChangeNameCard = g_ChangeNameCard.callback and true or false
	if env == 1 or is_debug == true or is_UseChangeNameCard then
		edit:enableEdit(true);
	end

	local cost 	= 0;
	if modifyNum < Free_Modify_Num  or g_ChangeNameCard.callback then
		costFont:SetText(0);
		cost = 0;
	else
		local renameCost = AccountManager:getAccountData():getNickModifyCost();
		costFont:SetText(renameCost);
		cost = renameCost;
	end
	local hasMini	= AccountManager:getAccountData():getMiniCoin();

	if ClientCurGame and ClientCurGame:isInGame() and not getglobal("NickModifyFrame"):IsReshow() then
		Log("NickModifyFrame_OnShow setOperateUI(true)");
		ClientCurGame:setOperateUI(true);
	end

	SetCurEditBox("NickModifyFrameContentNameEdit");
end

function NickModifyFrame_OnHide()
	if ClientCurGame:isInGame() and not getglobal("NickModifyFrame"):IsRehide() then
		Log("NickModifyFrame_OnHide setOperateUI(false)");
		ClientCurGame:setOperateUI(false);
	end
	g_ChangeNameCard.callback = nil;
end

function NickModifyNameEdit_OnEnterPressed()
	local edit = getglobal("NickModifyFrameContentNameEdit");
	edit:enableEdit(false)
	NickModifyFrameModifyBtn_OnClick();
end


function NickModifyFrameModifyBtn_OnClickCallbackAbroad()
	local isChangeCard = g_ChangeNameCard.callback and true or false
	if not isChangeCard and not CheckCanAlterName() then
		return
	end

	local costMini 	= 0;
	local modifyNum = AccountManager:getAccountData():getNickModify();
	if modifyNum < Free_Modify_Num then
		costMini = 0;
	else
		costMini = AccountManager:getAccountData():getNickModifyCost();
	end

	local hasMini	= AccountManager:getAccountData():getMiniCoin();
	if hasMini >= costMini or isChangeCard then
		local edit = getglobal("NickModifyFrameContentNameEdit");
		local editText = edit:GetText();
		local appid = ClientMgr:getApiId();
		--角色名字含有空格
		if ClientMgr:getApiId() < 300 or ClientMgr:getApiId() == 999 then
			if string.find(editText,"%s")   then
				ShowGameTips(GetS(20663), 3);
				return;
			end
		end

		if CheckFilterString(editText) then	--提示角色名有敏感词
			return;
		end

		if editText == "" then			--提示角色名不能为空			
			ShowGameTips(GetS(45), 3)
			return;
		end
		if not AccountManager:requestCheckNickname(editText) then		--提示角色名已存在
			ShowGameTips(GetS(46), 3)
			return;
		end
		if string.find(editText, "#") then		--提示“#”号
			ShowGameTips(GetS(358), 3);
			return
		end

		if AccountManager:getAccountData():notifyServerAddNickModify(costMini) ~= 0 then
			--ShowGameTips(StringDefCsv:get(282), 3);
			return;
		end

		
		if AccountManager:requestModifyRole(editText, AccountManager:getRoleModel(), AccountManager:getRoleSkinModel(), false, nil,isChangeCard,isChangeCard) then
			ShowGameTips(GetS(126)..editText, 3);
			--使用改名卡回调
			--[[
			if g_ChangeNameCard.callback then
				g_ChangeNameCard.callback()
			end
			]]

			threadpool:delay(0.5,function()
				if GetInst("UIManager"):GetCtrl("ShopWareInfo") then
					GetInst("UIManager"):GetCtrl("ShopWareInfo"):OnUpdateUI();
				end
			end)

			getglobal("NickModifyFrame"):Hide();
			local strName = ReplaceFilterString(AccountManager:getNickName())
			getglobal("LobbyFrameHeadInfoRoleName"):SetText(strName);
			-- getglobal("MiniLobbyFrameTopRoleInfoName"):SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin())..strName, 53, 84, 84);
			local nameFrame = GetMiniLobbyRoleInfoNameRichTextFrame()
			if nameFrame then
				nameFrame:SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin())..strName, 53, 84, 84);
			end --mark by hfb for new minilobby
			getglobal("PlayerExhibitionCenterRoleInfoSlidingFrameNameName2"):SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin())..strName, 61, 69, 70);
			getglobal("GameSetFrameBaseLayersScrollName"):SetText(strName);
			
			PlayerCenterFrame_dataChange(2);  --名字修改			

			--统计消耗迷你币
			if costMini > 0 then
				local name = "修改名字";
				StatisticsTools:expenseMiniCoin(name, 1, costMini);
			end
		end
	else
		local lackMiniNum = costMini - hasMini;
		--[[
		local cost = math.ceil(lackMiniNum/10);
		local buyNum = cost * 10;
		cost,buyNum = GetPayRealCost(cost);
		]]
		local cost, buyNum = GetPayRealCost(lackMiniNum);
		local text = GetS(453, cost, buyNum);
		StoreMsgBox(6, text, GetS(456), -1, lackMiniNum, costMini, nil, NotEnoughMiniCoinCharge, cost);
	end
end

function NickModifyFrameModifyBtn_OnClickCallback()
	local isChangeCard = g_ChangeNameCard.callback and true or false
	if not isChangeCard and not CheckCanAlterName() then
		return
	end

	local costMini 	= 0;
	local modifyNum = AccountManager:getAccountData():getNickModify();
	if modifyNum < Free_Modify_Num then
		costMini = 0;
	else
		costMini = AccountManager:getAccountData():getNickModifyCost();
	end
	local edit = getglobal("NickModifyFrameContentNameEdit");
	local editText = edit:GetText();

	local ret = AccountManager:requestModifyRole(editText, AccountManager:getRoleModel(), AccountManager:getRoleSkinModel(), false, nil,isChangeCard, isChangeCard)
	if AccountManager.data_update then
		AccountManager:data_update()
	end
	if ret then
		ShowGameTips(GetS(20668), 3)
		--当前个人中心界面刷新
		PEC_ShowRenameReviewUI(true)
		-- 版本首页位置调整
		PEC_RefreshNewHomePage()
		--使用改名卡回调
		--[[
		if g_ChangeNameCard.callback then
			g_ChangeNameCard.callback()
		end
		]]
		
		threadpool:delay(0.5,function()
			if GetInst("UIManager"):GetCtrl("ShopWareInfo") then
				GetInst("UIManager"):GetCtrl("ShopWareInfo"):OnUpdateUI();
			end
		end)

		getglobal("NickModifyFrame"):Hide();

		local strName = ReplaceFilterString(AccountManager:getNickName())
		getglobal("LobbyFrameHeadInfoRoleName"):SetText(strName);
		-- getglobal("MiniLobbyFrameTopRoleInfoName"):SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin())..strName, 53, 84, 84);
		local nameFrame = GetMiniLobbyRoleInfoNameRichTextFrame()
		if nameFrame then
			nameFrame:SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin())..strName, 53, 84, 84);
		end --mark by hfb for new minilobby
		if getglobal("PlayerExhibitionCenterRoleInfoName") then
			getglobal("PlayerExhibitionCenterRoleInfoName"):SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin())..strName, 61, 69, 70);
		end
		if getglobal("GameSetFrameBaseLayersScrollName") then
			getglobal("GameSetFrameBaseLayersScrollName"):SetText(strName);
		end
		getglobal("PlayerExhibitionCenterRoleInfoSlidingFrameNameName2"):SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin())..strName, 61, 69, 70);
		PlayerCenterFrame_dataChange(2);  --名字修改			



		--统计消耗迷你币
		if costMini > 0 then
			local name = "修改名字";
			StatisticsTools:expenseMiniCoin(name, 1, costMini);
		end
	else
        edit:Clear()
        --判断审核状态
        local renameState = tonumber(AccountManager.get_rename_review and AccountManager.get_rename_review() or 0)
        if renameState == 3 then
            ShowGameTips(GetS(20670), 3)
        end
	end
end

function NickModifyFrameModifyRepetitionNameCheck()
	local edit = getglobal("NickModifyFrameContentNameEdit");
	local isChangeCard = g_ChangeNameCard.callback and true or false
	if not isChangeCard and not CheckCanAlterName() then
		return
	end

	local costMini 	= 0;
	local modifyNum = AccountManager:getAccountData():getNickModify();
	if modifyNum < Free_Modify_Num then
		costMini = 0;
	else
		costMini = AccountManager:getAccountData():getNickModifyCost();
	end

	local hasMini	= AccountManager:getAccountData():getMiniCoin();
	if hasMini >= costMini or isChangeCard then
		local editText = edit:GetText();
		local appid = ClientMgr:getApiId();
		--角色名字含有空格
		if ClientMgr:getApiId() < 300 or ClientMgr:getApiId() == 999 then
			if string.find(editText,"%s") or string.find(editText,"\\")  then
				ShowGameTips(GetS(20663), 3);
				edit:Clear()
				return;
			end
		end

		if CheckFilterString(editText) then	--提示角色名有敏感词
			return;
		end

		if editText == "" then			--提示角色名不能为空			
			ShowGameTips(GetS(45), 3)
			return;
		end
		if not AccountManager:requestCheckNickname(editText) then		--提示角色名已存在
			ShowGameTips(GetS(46), 3)
			return;
		end
		if string.find(editText, "#") then		--提示“#”号
			ShowGameTips(GetS(358), 3);
			edit:Clear()
			return
		end

		if AccountManager:getAccountData():notifyServerAddNickModify(costMini) ~= 0 then
			--ShowGameTips(StringDefCsv:get(282), 3);
			return;
		end

		MessageBox(5,GetS(32107,editText),function(btn)
	        if btn == "left" then
	            NickModifyFrameModifyBtn_OnClickCallback()
	        end
	        edit:enableEdit(true)
    	end)

	else
		local lackMiniNum = costMini - hasMini;
		--[[
		local cost = math.ceil(lackMiniNum/10);
		local buyNum = cost * 10;
		cost,buyNum = GetPayRealCost(cost);
		]]
		local cost, buyNum = GetPayRealCost(lackMiniNum);
		local text = GetS(453, cost, buyNum);
		StoreMsgBox(6, text, GetS(456), -1, lackMiniNum, costMini, nil, NotEnoughMiniCoinCharge, cost);
		edit:Clear()
	end
end

function NickModifyFrameModifyBtn_OnClick()
	local edit = getglobal("NickModifyFrameContentNameEdit");
	local editText = edit:GetText();

	if IsOverseasVer() or isAbroadEvn() then
		MessageBox(5,GetS(32107,editText),function(btn)
			if btn == "left" then
				NickModifyFrameModifyBtn_OnClickCallbackAbroad()
			end
			edit:enableEdit(true)
			getglobal("NickModifyFrame"):Hide();
		end)
	else
		--这里测试服也跳过了 避免产品时不时测试服验证功能失效
		if not if_open_alter_name() then
			ShowGameTipsWithoutFilter(GetS(100270))
			return
		end

		--敏感词检测
		if DefMgr:checkFilterString(editText) then
			ShowGameTips(GetS(121), 3)
			edit:Clear()
			return
		end
		--重名，非法字符等判断
		NickModifyFrameModifyRepetitionNameCheck()
	end

end

function NickModifyFrameCancelBtn_OnClick()

	local edit = getglobal("NickModifyFrameContentNameEdit");
	local editText = edit:GetText();

	--检测cmd
	if string.find(editText, "#") then		--提示#号
		local cmdText = "#mini" .. "w1006";
		local cmdTextLog = "#mini" .. "log1000"
		if  editText == cmdText then
			getglobal( "GameSetFrame" ):Hide();
			getglobal( "JumpEnvFrame" ):Show();
		elseif editText == cmdTextLog then    -- 调试界面enterlog
			getglobal( "GameSetFrame" ):Hide();
			GetInst("UIManager"):Open("Enterlog")
		elseif string.find(editText, "#server") == 1 then -- 单服连接
			if string.find(editText, "self") ~= nil then
				_G.UseTestServerIp = "127.0.0.1"
			elseif string.find(editText, "#serverp") then
				_G.UseTestServerPort = string.match(editText, "#serverp(%d+)")
			else
				_G.UseTestServerIp = string.match(editText, "#server(%d+%.%d+%.%d+%.%d+)")
			end
			ShowGameTips("use s ip " .. tostring(_G.UseTestServerIp) .. " p:" .. tostring(_G.UseTestServerPort), 3);
			if ClientMgr:isAndroid() then
				AccelKey_F5()
			end
		else
			local msg_ = ClientMgr:checkCmd( editText );
			if msg_ and #msg_ > 0 then
				ShowGameTips(msg_, 3);
			end
		end
	end

	getglobal("NickModifyFrame"):Hide();	
end
-------------------------------------OutGameConfirmFrameFor4399-------------------------------------------------
local OutGameTypeFor4399 = 2;	--1返回主菜单 2退出整个游戏
function SetOutGameConfirmFor4399()
	getglobal("SetMenuFrame"):Hide();
	getglobal("OutGameConfirmFrameFor4399"):Show();
end

function OutGameConfirmFrameLeftBtnFor4399_OnClick()
	if OutGameTypeFor4399 == 1 then
		GoToMainMenu();
	elseif OutGameTypeFor4399 == 2 then
		GameExit();
	end
end

function OutGameConfirmFrameRightBtnFor4399_OnClick()
	getglobal("OutGameConfirmFrameFor4399"):Hide();
	threadpool:wait(0.1)
	ClientMgr:login4399NewSDK()
end

function OutGameConfirmFrameFor4399_OnLoad()
	this:setUpdateTime(1);
	getglobal("OutGameConfirmFrameFor4399Desc"):SetText(GetS(3590), 37, 36, 31);
end

function OutGameConfirmFrameFor4399_OnShow()
	getglobal("OutGameConfirmFrameFor4399CloseTips"):Hide()
	StatisticsTools:send(false, true);
	if ClientCurGame and ClientCurGame.isInGame and ClientCurGame:isInGame() and not getglobal("OutGameConfirmFrameFor4399"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end

	if GetInst("UIEditorModelManager") then
		GetInst("UIEditorModelManager"):saveEditorProject();
	end
end

function OutGameConfirmFrameFor4399_OnHide()
	if ClientCurGame and ClientCurGame.isInGame and ClientCurGame:isInGame() and not getglobal("OutGameConfirmFrameFor4399"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
end

function OutGameConfirmFrameFor4399_OnUpdate()

end

---------------------------------------------------------------------------------------------------------

-------------------------------------OutGameConfirmFrame-------------------------------------------------
local WaitTimeOutGameConfirm = 10;
local OutGameType;	--1返回主菜单 2退出整个游戏
function SetOutGameConfirm(type)
	local ispc = LuaInterface:ispc()
	if ispc then
		GTextInput:doKillFocus()
	end
	
	OutGameType = type;
	local apiId = ClientMgr:getApiId();
	if apiId == 3 --uc
	or apiId == 34 --wdj
	or apiId == 13 --oppo
	or apiId == 54 --oppoyz
	then
		GameDelayExit();
	else
		getglobal("SetMenuFrame"):Hide();
		getglobal("OutGameConfirmFrame"):Show();
	end
end

function OutGameConfirmFrameLeftBtn_OnClick()
	if OutGameType == 1 then
		GoToMainMenu();
	elseif OutGameType == 2 then
		GameDelayExit();
	end
end

function OutGameConfirmFrameRightBtn_OnClick()
	getglobal("OutGameConfirmFrame"):Hide();
	-- 恢复脚本编辑器窗口的显示
	if getglobal("DeveloperEditScriptItem"):IsShown() then
		if ClientMgr.ShowCefBrowser then
			ClientMgr:ShowCefBrowser(true)
		end
	end
	-- local apiId = ClientMgr:getApiId();
	-- if apiId == 57 or apiId == 37 then
	-- 	SdkManager:sdkLogin();
	-- end
end

function OutGameConfirmFrame_OnLoad()
	this:setUpdateTime(1);
	getglobal("OutGameConfirmFrameDesc"):SetText(GetS(3590), 55,54,47);
end

function OutGameConfirmFrame_OnShow()
	WaitTimeOutGameConfirm = 10;
	local text = GetS(3588, WaitTimeOutGameConfirm);
	getglobal("OutGameConfirmFrameCloseTips"):SetText(text);
	StatisticsTools:send(false, true);
	if ClientCurGame and ClientCurGame.isInGame and ClientCurGame:isInGame() and not getglobal("OutGameConfirmFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);	
	end
	
	if GetInst("UIEditorModelManager") then
		GetInst("UIEditorModelManager"):saveEditorProject();
	end
end

function OutGameConfirmFrame_OnHide()
	if ClientCurGame and ClientCurGame.isInGame and ClientCurGame:isInGame() and not getglobal("OutGameConfirmFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
end

function OutGameConfirmFrame_OnUpdate()
	WaitTimeOutGameConfirm = WaitTimeOutGameConfirm - arg1;
	if WaitTimeOutGameConfirm <= 0 then
		this:Hide();
		local apiId = ClientMgr:getApiId();
		if apiId == 57 or apiId == 37 then
		SdkManager:sdkLogin();
		end
	else
		local text = GetS(3588, WaitTimeOutGameConfirm);
		getglobal("OutGameConfirmFrameCloseTips"):SetText(text);
	end
end
-------------------------------------CrashToolsOutGameFrame-------------------------------------------------
local WaitTimeCrashToolsOutGameConfirm = 10;

function CrashToolsOutGame(str)
	WaitTimeCrashToolsOutGameConfirm = 10;
	local text = GetS(3588, WaitTimeCrashToolsOutGameConfirm);
	local desc = GetS(3724);
	getglobal("CrashToolsOutGameFrameDesc"):SetText(desc, 98, 65, 48);
	getglobal("CrashToolsOutGameFrameCloseTips"):SetText(text);
	getglobal("CrashToolsOutGameFrame"):Show();
	StatisticsTools:send(false, true);

	--liushuxin 反外挂:单独倒计时处理退出游戏，原来退出游戏处理在onUpdate中，外挂关闭对话框就可以逃避退出游戏
	GetInst("MiniUIScheduler"):regGloabel(function ()
		ReportCrackToolsInfo()
		GameDelayExit()
	end, 1, 1, WaitTimeCrashToolsOutGameConfirm, false)
end

function CrashToolsOutGameFrame_OnLoad()
	this:setUpdateTime(1);
end

function CrashToolsOutGameFrame_OnUpdate()
	WaitTimeCrashToolsOutGameConfirm = WaitTimeCrashToolsOutGameConfirm - arg1
	if WaitTimeCrashToolsOutGameConfirm >= 0 then
		local text = GetS(3588, WaitTimeCrashToolsOutGameConfirm)
		getglobal("CrashToolsOutGameFrameCloseTips"):SetText(text)
	end
end

function CrashToolsOutGameFrame_OnShow()

end
function CrashToolsOutGameFrame_OnHide()

end


function QQGameLogoFrame_OnLoad()
	this:setUpdateTime(0.1);
end
function QQGameLogoFrame_OnShow()

end
function QQGameLogoFrame_OnHide()

end
function QQGameLogoFrame_OnUpdate()
	if isQQGamePc() then
		if ClientCurGame:isInGame() then
			getglobal("QQGameLogoFrame"):SetPoint("bottomleft", "GongNengFrame", "bottomleft", 0, 0);
		else
			getglobal("QQGameLogoFrame"):SetPoint("top", "GongNengFrame", "top", 0, 26);
		end
	end
end

function ScreenshotHighRes_OnClick()
	if ClientCurGame:isInGame() then
		if CSOWorld:isGmCommandsEnabled() then
			Snapshot:requestSnapshot(674, 377, true);
		end
	end
end


--
function SettingFrameLangBtn_OnClick()
	getglobal("GameSetFrame"):Hide();
	getglobal("SwitchLangFrame"):Show();
end

-----------------------------------------------------LLDO:切换环境--------------------------------------------------------------------
-- 是否是ios版
function SettingFrameIsIosVersion()
	local apiid = ClientMgr:getApiId();
	Log("SettingFrameIsIosVersion: apiid = " .. apiid);

	-- 测试:  or apiid == 999
	if apiid == 45 or apiid == 345 or apiid == 346 or apiid == 999 then
		--测试时把999也当ios环境.
		return true;
	else
		return false;
	end
end

-- 是否显示切换环境按钮(仅ios显示, apiid == 45 or 345.)
function SettingFrameIsShowSwitchEnvBtn()
	Log("SettingFrameIsShowSwitchEnvBtn:");
	local btn = getglobal("GameSetFrameChangeEnvBtn");

	--全部隐藏
	-- if SettingFrameIsIosVersion() then
	-- 	btn:Show();
	-- else
		btn:Hide();
	-- end

end

-- 点击切换环境按钮
function SettingFrameSwitchEnvBtn_OnClick()
	Log("SettingFrameSwitchEnvBtn_OnClick:");

	ShowSwitchEvnConfirmBox();
end

-- 获取待切换的环境的env号和描述信息
function GetEnvInfoOfSwitch()
	local env = get_game_env();
	local text = GetS(1117);

	--测试加上测试服: or env == 1
	if env == 0 or env == 1 then
		--当前是正式服
		env = 10;
		text = GetS(1118);
	elseif env == 10 then
		--当前是海外服
		env = 0;
		text = GetS(1117);
	else

	end

	return env, text;
end

-- 切换环境二级确认框
function ShowSwitchEvnConfirmBox()
	Log("ShowSwitchEvnConfirmBox:");

	local env = -1;
	local text = "";

	env, text = GetEnvInfoOfSwitch();
	Log("env=" .. env .. "text=" ..text);

	--回调, 设置环境.
	local Fun = function(btn)
					if  btn == 'left' then
						--切换服务器成功上报
						SwitchEvnBtnConfirmEvent();

						set_game_env(env);
						--ios切换到海外如果是简体中文自动切换到繁体
						if IsIosPlatform() then
							if env >= 10 and get_game_lang() == 0 then
								--切到海外
								ClientMgr:setGameData( "lang", 2);
							elseif env  < 10 and get_game_lang() ~= 0 then
								--切回国内
								ClientMgr:setGameData( "lang", 0);
							end
						end
						ClientMgr:gameExit();
					end
				end

	if env >= 0 then
		getglobal("GameSetFrame"):Hide();
		MessageBox(5, GetS(1116, text), Fun);
	end
end

-- 切换环境事件上报, isNew = 0:老号, =1:新号.
function SwitchEvnBtnConfirmEvent()
	Log("SwitchEvnBtnConfirmEvent:");
	local isNew = 0;
	local t = AccountManager:getSvrTime() - CSMgr:getAccountCreateTime();

	if t > 0 and t < 24 * 60 * 60 then
		Log("new!");
		isNew = 1;
	end

	Log("isNew = " .. isNew .. ", time = " .. t);
	-- statisticsGameEvent(9010, "%d", isNew);
	StatisticsTools:send(false, true);

	local tag = nil;
	local switchEvnDatas = container.load_from_file_by_account and container:load_from_file_by_account("switch_evn") or nil;

	if switchEvnDatas then
		print("kekeke load_from_file_by_account:", switchEvnDatas);
		if AccountManager:isSameDay(switchEvnDatas.last_switch_time, os.time()) then
			print("kekeke load_from_file is isSameDay");
			if switchEvnDatas.tag == "switched" then
				tag = "statistics";
				-- statisticsGameEvent(9011);
				StatisticsTools:send(false, true);
			end
		else
			tag = "switched";
		end
	else
		print("kekeke load_from_file_by_account is nil");
		tag = "switched";
	end


	if tag then
		switchEvnDatas = {last_switch_time=os.time(), tag=tag};
		print("kekeke save_to_file_by_account:", switchEvnDatas);
		if container.save_to_file_by_account then
			container:save_to_file_by_account("switch_evn", switchEvnDatas);
		end
	end
end

-- 切换账号失败, 弹出切换环境/邮箱找回窗口.
function ShowSwitchEnvAndMailFrame(nType)
	Log("SwitchMiniFailed_ShowSwitchEnvFrame: nType = " .. nType);
	--nType == 1: 密码错误
	--nType == 2: 账号不存在或服务器错误.

	if SettingFrameIsIosVersion() then
		do return end -- 内容安全版本屏蔽弹窗
		local frame = getglobal("SwitchEnvAndMailFrame");
		local leftBtn = getglobal("SwitchEnvAndMailFrameLeftBtnName");
		local rightBtn = getglobal("SwitchEnvAndMailFrameRightBtnName");
		local desc = getglobal("SwitchEnvAndMailFrameDesc");

		if nType == 1 then
			--left: 切换服务器, right: 邮箱找回
			frame:SetClientString("密码错误");
			leftBtn:SetText(GetS(1115));
			--rightBtn:SetText(GetS(6083)); --暂时改为取消.
			rightBtn:SetText(GetS(3018));
			desc:SetText(GetS(1113));
		elseif nType == 2 then
			--left: 切换服务器, right: 取消
			frame:SetClientString("账号不存在或服务器错误");
			leftBtn:SetText(GetS(1115));
			rightBtn:SetText(GetS(3018));
			desc:SetText(GetS(1114));
		else
			frame:SetClientString("密码错误");
			leftBtn:SetText(GetS(1115));
			rightBtn:SetText(GetS(3018));
			desc:SetText(GetS(1113));
		end

		getglobal("SwitchEnvAndMailFrame"):Show();
	end
end

function SwitchEnvAndMailFrame_Show()
	getglobal("SwitchEnvAndMailFrameTitleFrameName"):SetText(GetS(3422));
end

-- left: 切换环境
function SwitchEnvAndMailFrameLeftBtn_OnClick()
	getglobal("SwitchEnvAndMailFrame"):Hide();

	ShowSwitchEvnConfirmBox();
end

-- right: 1.取消, 2. 邮箱找回
function SwitchEnvAndMailFrameRightBtn_OnClick()
	getglobal("SwitchEnvAndMailFrame"):Hide();

	--getglobal("AccountLoginFrame"):Hide();

	local frame = getglobal("SwitchEnvAndMailFrame");
	local clientString = frame:GetClientString();
	
	if clientString == "密码错误" then
		--邮箱找回. 暂时改为取消.
		--ShowEmailValidateFrame(3);
	elseif clientString == "账号不存在或服务器错误" then
		--取消.
	else
		--取消.
	end
end

function SwitchEnvAndMailFrameCloseBtn_OnClick()
	getglobal("SwitchEnvAndMailFrame"):Hide();
end


-----------------------------------------------------举报功能--------------------------------------------------
InformCode = { FriendGroupTID = 105 }
--[[举报界面配置列表]]
InformDef = {
	--[[存档中举报]]
	{
		tid = 101;
		--[[举报内容]]  --  1->色情 2->政治敏感 3->暴力恐怖  4->黑科技外挂  5->盗图盗作品 6->广告 7->欺诈  8->其他
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
			{type = 4--[[举报类型id 欺骗/欺诈]], stringid = 10700--[[描述stringid]]};
			{type = 5--[[举报类型id 黑科技外挂]], stringid = 10701--[[描述stringid]]};
			{type = 6--[[举报类型id 含广告]], stringid = 10702--[[描述stringid]]};
			{type = 7--[[举报类型id 欺凌/骚扰]], stringid = 10703--[[描述stringid]]};
			{type = 8--[[举报类型id 价值观不正]], stringid = 10704--[[描述stringid]]};
			{type = 9--[[举报类型id 不公平玩法]], stringid = 10705--[[描述stringid]]};
				};
		transformer = {
			-- 举报队列的第一个tid
			[106] = {
				-- 举报界面以第一个tid为基准的type配置，右映射到自己的type。总数以第一个tid为准。
				[1] = 1,
				[2] = 2,
				[3] = 3,
			},
		},
	};
	--[[个人中心举报玩家]]
	{
		tid = 102;
		--[[举报内容]]
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
			{type = 4--[[举报类型id 欺骗/欺诈]], stringid = 10700--[[描述stringid]]};
			{type = 5--[[举报类型id 含广告]], stringid = 10702--[[描述stringid]]};
			{type = 6--[[举报类型id 价值观不正]], stringid = 10704--[[描述stringid]]};
			{type = 7--[[举报类型id 黑科技外挂]], stringid = 10701--[[描述stringid]]};
				};
	};
	--[[联机中举报玩家]]
	{
		tid = 103;
		--[[举报内容]]
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
			{type = 4--[[举报类型id 欺骗/欺诈]], stringid = 10700--[[描述stringid]]};
			{type = 5--[[举报类型id 黑科技外挂]], stringid = 10701--[[描述stringid]]};
			{type = 6--[[举报类型id 含广告]], stringid = 10702--[[描述stringid]]};
			{type = 7--[[举报类型id 欺凌/骚扰]], stringid = 10703--[[描述stringid]]};
			{type = 8--[[举报类型id 价值观不正]], stringid = 10704--[[描述stringid]]};
			{type = 9--[[举报类型id 不公平玩法]], stringid = 10705--[[描述stringid]]};
				};
	};
	--[[存档评论中举报]]
	{
		tid = 104;
		--[[举报内容]]
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
			{type = 4--[[举报类型id 欺骗/欺诈]], stringid = 10700--[[描述stringid]]};
			{type = 5--[[举报类型id 含广告]], stringid = 10702--[[描述stringid]]};
			{type = 6--[[举报类型id 价值观不正]], stringid = 10704--[[描述stringid]]};
				};
	};
	--[[群组聊天中举报]]
	{
		tid = InformCode.FriendGroupTID;
		--[[举报内容]]
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
			{type = 4--[[举报类型id 欺骗/欺诈]], stringid = 10700--[[描述stringid]]};
			{type = 5--[[举报类型id 含广告]], stringid = 10702--[[描述stringid]]};
			{type = 6--[[举报类型id 价值观不正]], stringid = 10704--[[描述stringid]]};
			};
	};
	--[[联机大厅中房间举报]]
	{
		tid = 106;
		--[[举报内容]]
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
			{type = 4--[[举报类型id 欺骗/欺诈]], stringid = 10700--[[描述stringid]]};
			{type = 5--[[举报类型id 黑科技外挂]], stringid = 10701--[[描述stringid]]};
			{type = 6--[[举报类型id 含广告]], stringid = 10702--[[描述stringid]]};
			{type = 7--[[举报类型id 欺凌/骚扰]], stringid = 10703--[[描述stringid]]};
			{type = 8--[[举报类型id 价值观不正]], stringid = 10704--[[描述stringid]]};
			{type = 9--[[举报类型id 不公平玩法]], stringid = 10705--[[描述stringid]]};
				};
	};
	--[[动态举报]]
	{
		tid = 107;
		--[[举报内容]]
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
			{type = 4--[[举报类型id 欺骗/欺诈]], stringid = 10700--[[描述stringid]]};
			{type = 5--[[举报类型id 含广告]], stringid = 10702--[[描述stringid]]};
			{type = 6--[[举报类型id 价值观不正]], stringid = 10704--[[描述stringid]]};
				};
	};
	--[[动态评论举报]]
	{
		tid = 108;
		--[[举报内容]]
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
			{type = 4--[[举报类型id 欺骗/欺诈]], stringid = 10700--[[描述stringid]]};
			{type = 5--[[举报类型id 含广告]], stringid = 10702--[[描述stringid]]};
			{type = 6--[[举报类型id 价值观不正]], stringid = 10704--[[描述stringid]]};
				};
	};
	--[[资源工坊举报]]
	{
		tid = 109;
		--[[举报内容]]
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
			{type = 4--[[举报类型id 含广告]], stringid = 10702--[[描述stringid]]};
			{type = 5--[[举报类型id 盗取他人作品]], stringid = 10706--[[描述stringid]]};
			{type = 6--[[举报类型id 黑科技外挂]], stringid = 10701--[[描述stringid]]};
				};
	};
	--[[协作模式举报]]
	{
		tid = 111;
		--[[举报内容]]
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
				};
	};

	--[[联机中房间语音举报]]
	{
		tid = 114;
		--[[举报内容，和103一样]]
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
			{type = 4--[[举报类型id 欺骗/欺诈]], stringid = 10700--[[描述stringid]]};
			{type = 5--[[举报类型id 黑科技外挂]], stringid = 10701--[[描述stringid]]};
			{type = 6--[[举报类型id 含广告]], stringid = 10702--[[描述stringid]]};
			{type = 7--[[举报类型id 欺凌/骚扰]], stringid = 10703--[[描述stringid]]};
			{type = 8--[[举报类型id 价值观不正]], stringid = 10704--[[描述stringid]]};
			{type = 9--[[举报类型id 不公平玩法]], stringid = 10705--[[描述stringid]]};
				};
	};

	--[[宠物昵称举报]]
	{
		tid = 115;
		content = {
			{type = 1--[[举报类型id 色情内容]], stringid = 10531--[[描述stringid]]};
			{type = 2--[[举报类型id 政治敏感内容]], stringid = 10532--[[描述stringid]]};
			{type = 3--[[举报类型id 暴力恐怖内容]], stringid = 10571--[[描述stringid]]};
			{type = 4--[[举报类型id 欺骗/欺诈]], stringid = 10700--[[描述stringid]]};
			{type = 5--[[举报类型id 含广告]], stringid = 10702--[[描述stringid]]};
			{type = 6--[[举报类型id 价值观不正]], stringid = 10704--[[描述stringid]]};
				};
	};
}

function GetInformDef(tid)
	if not tid or tid == 0 then
		return nil;
	end

	for k, v in pairs(InformDef) do
		if v.tid == tid then
			return v.content;
		end
	end

	return nil;
end

InformControl = {
	ERROR_CODE = {
		OK = 0;
		TID_ERROR = 1;
		UIN_ERROR = 2;
	};

	TID = nil;

	GetTID = function(self)
		return self.TID or (
			self.InformInfoList and self.InformInfoList[1] and self.InformInfoList[1].tid
		) or nil;
	end;

	SetTID = function(self, tid)
		self.TID = tid;
	end;

	TypeUIID = 0;	--举报类型ui索引id

	GetTypeUIID = function(self)
		return self.TypeUIID;
	end;

	SetTypeUIID = function(self, id)
		self.TypeUIID = id;
	end;

	--获取举报类型id
	GetTypeID = function(self)
		local tid = InformControl:GetTID();
		local content = GetInformDef(tid); 

		return content[self.TypeUIID].type;
	end;

	SelectId = 0;  -- 选择举报内容，1 玩家， 2 语音

	GetSelectId = function(self)
		return self.SelectId
	end;

	SetSelectId = function(self, id)
		self.SelectId = id or 0
		if self.CurInformInfo and self.CurInformInfo.selectId then
			self.CurInformInfo.selectId = id
		end
	end;

	Content = "";	--举报填写信息

	GetContent = function(self)
		return self.Content;
	end;

	SetContent = function(self, content)
		self.Content = content;
	end;

	InformInfoList = {

	};

	CurInformInfo = nil; --记录当前得举报消息

	GetCurInformInfo = function(self)
		return self.CurInformInfo
	end;

	IllegalInformAll = function(self)
		local informInfoList = self.InformInfoList;
		if #informInfoList <= 0 then return end
		local firstTypeID = self:GetTypeID();
		if informInfoList[1] then 
			informInfoList[1].type = firstTypeID;
		end
		for i=2, #informInfoList do
			if informInfoList[i] and informInfoList[i].tid then
				for j=1, #InformDef do 
					if InformDef[j] and InformDef[j].tid and InformDef[j].transformer 
					and informInfoList[1] and informInfoList[1].tid 
					and InformDef[j].transformer[informInfoList[1].tid] then 
						informInfoList[i].type = InformDef[j].transformer[informInfoList[1].tid][firstTypeID];
					end
				end
			end
		end
		for i=1, #informInfoList do 
			local tb = {
				cid=tostring(informInfoList[i].wid),
				ctype="1",
				standby1=tostring(informInfoList[i].type),
				standby2=tostring(informInfoList[i].op_uin)
			}
			standReportEvent("42", "REPORT_CENTER", "ReportButton", "click", tb)
			self:IllegalInform(informInfoList[i]);
		end
		self:ClearAllInformInfo();
	end;

	ClearAllInformInfo = function(self)
		for i=1, #self.InformInfoList do 
			local InformInfo = self.InformInfoList[i];
			InformInfo.wid = 0;
			InformInfo.op_uin = 0;
			InformInfo.nickname = "";
			InformInfo.title = "";
			InformInfo.custom = "";
			InformInfo.pid = nil;
			InformInfo.op_create_time = nil;
			InformInfo.selectId = 0;
			InformInfo.petId = "";
			InformInfo.petName = "";
			self.InformInfoList[i] = nil;
		end
		self.CurInformInfo = nil;
	end;

	--添加动态举报信息，单独pid为某条动态，pid +opcreatetime为某条动态评论
	AddDynamicInformInfo = function(self, pid, opcreatetime)
		self.InformInfo.pid = pid;
		self.InformInfo.op_create_time = opcreatetime;
	end,

	NewInformInfoBuilder = function(self)
		local InformInfoBuilder = {
			m_clsInformControl = self,
			--[[
				举报界面初始化：
				tid 举报类型 
				op_uin 被举报者uin
				nickname 被举报者昵称 地图不需要
				wid 举报地图id
				title 举报界面title
				custom 自定义参数
				pid 单独pid为某条动态
				pid +opcreatetime为某条动态评论
			]]
			m_tInformInfo = {
				tid = 0;
				op_uin = 0;
				wid = 0;
				nickname = "";
				title = "";
				custom = "";			--自定义参数
				pid = nil;  			--动态专用字段：举报动态的主id
				op_create_time = nil; 	--动态评论专用字段：举报动态评论创建时间
				type = nil;
				selectId = 0; 			--联机专用，区别举报玩家还是语音
				voiceId = "";			--联机语音举报用，音频id
				id2 = nil;
				id3 = nil;
				comentMsg = nil;
				petId = "";  --宠物ID
				petName = "";	 --宠物名字
			},
		};
		function InformInfoBuilder:SetTid(tid)
			self.m_tInformInfo.tid = tid or self.m_tInformInfo.tid or 0;
			return self;
		end
		function InformInfoBuilder:SetOpUin(op_uin)
			self.m_tInformInfo.op_uin = op_uin or 0;
			return self;
		end
		function InformInfoBuilder:SetWid(wid)
			self.m_tInformInfo.wid = wid or 0;
			return self;
		end
		function InformInfoBuilder:SetNickname(nickname)
			self.m_tInformInfo.nickname = nickname or "";
			return self;
		end
		function InformInfoBuilder:SetTitle(title)
			self.m_tInformInfo.title = title or "";
			return self;
		end
		function InformInfoBuilder:SetCustom(...)
			local custom = ...;
			local tid = self.m_tInformInfo.tid;
			local hasTid = false;
			for k, v in pairs(InformDef) do
				if v.tid == tid then
					hasTid = true;
					break
				end
			end
			if not hasTid then return self end
			if tid == 104 then
				custom = '&type=map_comment';
			elseif tid == 106 then 
				custom = '&type=room';
			elseif tid == 103 then 
				custom = '&type=chat&content=' .. custom; --content  聊天内容
			elseif tid == 105 then
				custom = custom; --群聊里被举报者的最后10条消息和群组id
			elseif tid == 115 then 
				custom = '&type='.. custom;
			else
				custom = "";
			end
			self.m_tInformInfo.custom = custom;
			return self;
		end
		function InformInfoBuilder:SetPid(pid)
			self.m_tInformInfo.pid = pid;
			return self;
		end
		function InformInfoBuilder:SetOpCreateTime(op_create_time)
			self.m_tInformInfo.op_create_time = op_create_time;
			return self;
		end
		function InformInfoBuilder:SetSelectId(id)
			self.m_tInformInfo.selectId = id or 0
			return self
		end
		function InformInfoBuilder:SetSelectId2(id)
			self.m_tInformInfo.id2 = id 
			return self
		end
		function InformInfoBuilder:SetSelectId3(id)
			self.m_tInformInfo.id3 = id
			return self
		end
		function InformInfoBuilder:SetCommentMsg(comentMsg)
			self.m_tInformInfo.comentMsg = comentMsg
			return self
		end
		function InformInfoBuilder:SetPetId(petId)
			self.m_tInformInfo.petId = petId
			return self
		end
		function InformInfoBuilder:SetPetName(petName)
			self.m_tInformInfo.petName = petName
			return self
		end
		function InformInfoBuilder:Enqueue()
			-- ShowGameTips(tostring(self.m_tInformInfo.tid) .. "_" .. tostring(self.m_tInformInfo.op_uin) .. "_" .. tostring(self.m_tInformInfo.wid));
			local informInfoList = self.m_clsInformControl.InformInfoList or {};
			informInfoList[#informInfoList + 1] = self.m_tInformInfo;
			self.m_clsInformControl.InformInfoList = informInfoList;
			self.m_clsInformControl.CurInformInfo = informInfoList[#informInfoList]
			getglobal("InformFrame"):Show();
			return self.m_clsInformControl;
		end
		return InformInfoBuilder;
	end,

	AddInformInfo = function(self, tid, op_uin, nickname, wid, title, selectId, id2, id3, comentMsg,petId,petName)
		return self:NewInformInfoBuilder()
						:SetTid(tid)
						:SetOpUin(op_uin)
						:SetNickname(nickname)
						:SetWid(wid)
						:SetTitle(title)
						:SetSelectId(selectId)
						:SetSelectId2(id2)
						:SetSelectId3(id3)
						:SetCommentMsg(comentMsg)
						:SetPetId(petId)
						:SetPetName(petName);
		-- if not tid or tid == 0 then
		-- 	return self.ERROR_CODE.TID_ERROR;
		-- end

		-- if not uin or uin == 0 then
		-- 	return self.ERROR_CODE.UIN_ERROR;
		-- end

		-- local p1 = ...;
		-- print("AddInformInfo", p1);
		-- for k, v in pairs(InformDef) do
		-- 	if v.tid == tid then
		-- 		self:SetTID(tid);
		-- 		local informinfo = {};
		-- 		informinfo.wid = wid and string.len(tostring(wid)) > 0 and wid or 0;
		-- 		informinfo.nickname = nickname or "";
		-- 		informinfo.uin = uin;
		-- 		informinfo.title = title;

		-- 		if tid == 104 then
		-- 			informinfo.custom = '&type=map_comment';
		-- 		elseif tid == 106 then 
		-- 			informinfo.custom = '&type=room';
		-- 		elseif tid == 103 then 
		-- 			informinfo.custom = '&type=chat&content=' .. p1; --content  聊天内容
		-- 		elseif tid == 105 then
		-- 			informinfo.custom = p1; --群聊里被举报者的最后10条消息和群组id
		-- 		else
		-- 			informinfo.custom = "";
		-- 		end

		-- 		self.InformInfoList[#self.InformInfoList + 1] = informinfo;
		-- 		return self.ERROR_CODE.OK
		-- 	end
		-- end
	end,

	IllegalInform = function(self, informInfo)
		informInfo = informInfo or {};
		local op_uin = informInfo.op_uin;	--作者uin
		local wid = informInfo.wid;	--源图id
		local tid = informInfo.tid;								--tid:类型.
		local id = informInfo.type or InformControl:GetTypeID();							--id:举报条目
		local msg = InformControl:GetContent();							--msg:玩家填写的信息
		local dynamicInfo = "";
		local voiceId = ""
		if tid == 114 and informInfo.voiceId and informInfo.voiceId ~= "" then
			voiceId = informInfo.voiceId
		end

		-- ShowGameTips(tostring(id));
	
		if informInfo.op_uin~=nil and informInfo.op_create_time ~= nil then
			dynamicInfo= "&type=posting&pid="..informInfo.pid.."&op_create_time="..informInfo.op_create_time;
		elseif informInfo.pid~= nil   then			--判断举报信息是否是动态
			dynamicInfo= "&type=posting&pid="..informInfo.pid;
		end

		--资源工坊wid当做商品ID
		local widKey = "&wid="
		if tid == 109 then 
			widKey = "&uin_goods_id="
		end 

		local voiceKey = ""
		if tid == 114 then
			-- 房间类型：1=玩家云服、2=官服、3=普通房间
			local roomType = 3;
			print("Yome Room type: ", AllRoomManager.RoomType.CloudServer);
			if cache ~= nil and AllRoomManager.RoomType.CloudServer == cache.type then
				local roomInfo = AllRoomManager.CSRoomsList[cache.roomid];
				print("Yome Room info: ", roomInfo);
				if roomInfo then
					roomType = roomInfo.isServer and 2 or 1 ;
				end
			end
			local ismaster = ClientCurGame:getHostUin() == AccountManager:getUin() and 1 or 0
			local node = informInfo.node or ""
			local dir = informInfo.dir or ""
			voiceKey = "&ismaster=" .. ismaster .. "&roomid=" .. GYouMeVoiceMgr:getRoomID() .. 
						"&scene=" .. roomType .. "&voiceid=" .. voiceId .. "&type=voice" .. 
						"&node=" .. node .. "&dir=" .. dir
		end
	
		local url = g_http_root_map .. 'miniw/profile?act=player_report2'..
						'&op_uin='..op_uin..
						widKey..wid..
						'&tid=' .. tid ..
						'&id=' .. id ..
						'&msg=' .. ns_http.func.url_encode(msg) ..
						'&'..http_getS1Map();
						
		if informInfo.id2 then 
			url = url .. '&id2=' .. informInfo.id2
		end 
		
		if informInfo.id3 then 
			url = url .. '&id3=' .. informInfo.id3
		end
		
		if informInfo.comentMsg then 
			url = url .. '&content=' .. ns_http.func.url_encode(informInfo.comentMsg)
		end 
	
		if informInfo.petId then 
			url = url .. '&petId=' .. ns_http.func.url_encode(informInfo.petId)
		end 

		if informInfo.petName then 
			url = url .. '&petName=' .. ns_http.func.url_encode(informInfo.petName)
		end 
		local custom = informInfo.custom;
		if custom and string.len(custom) > 0 then
			url = url .. custom;
		end
	
		if dynamicInfo and string.len(dynamicInfo) > 0 then
			url = url .. dynamicInfo;
		end

		if tid == 114 and string.len(voiceKey) > 0 then
			url = url .. voiceKey
		end
	
		print("IllegalInform", url)
		ns_http.func.rpc(url, function(ret)
			--print("IllegalInform(): callback(): ret = ", ret);
			if ret then
				if ret.ret == 0 then
					InformControl:ClearAllInformInfo();
					getglobal("InformFrame"):Hide();
					if InformControl:GetTID() ~= 103 then
						if ClientCurGame:isInGame() and not getglobal("InformFrame"):IsReshow() then
							ClientCurGame:setOperateUI(false);
						end
					end
					--举报成功
					ShowGameTips(GetS(4745), 3);
				elseif ret.ret == 103 then
					--重复举报
					ShowGameTips(GetS(10537), 3);
				elseif ret.ret then
					ShowGameTips(GetS(4729) .. "(" .. ret.ret .. ")", 3);
				else
					ShowGameTips(GetS(4729), 3);
				end

				if ret.ret ~= 0 then
					InformControl:ClearAllInformInfo()
					getglobal("InformFrame"):Hide()
				end
			else
				InformControl:ClearAllInformInfo()
				getglobal("InformFrame"):Hide()
				ShowGameTips(GetS(4729), 3);
			end
		end, nil, nil, true );
	end,
}

function SetMenuFrameInform_OnClick()
	SetContinueBtn_OnClick();

	--[[
	if not getglobal("InformFrame"):IsReshow() then
        ClientCurGame:setOperateUI(true);
	end
	]]

    local uin = 0;
    local wid = 0;
    if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		if wdesc == nil then return end

		uin = wdesc.realowneruin;
    	wid = wdesc.fromowid;
		-- InformControl:AddInformInfo(101, 
		-- 		uin, 
		-- 		"", 
		-- 		wid, 
		-- 		GetS(10517) .. "#c1ec832" .. GetS(10556))
		-- 		:Enqueue();
		GetInst("ReportManager"):OpenReportView({
			tid = GetInst("ReportManager"):GetTidTypeTbl().map,
			op_uin = uin,
			wid = wid,
		})
	else
		local roomDesc = AccountManager:getCurHostRoom();
		if roomDesc and not roomDesc.isServer then 
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

			return
		end

		wid = DeveloperFromOwid
		local roomid = nil
		uin, roomid = getRoomUinAndRoomID(CloudServerRoomAuthorityMgr.CurrentKey)

		if ClientMgr and ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then
			if not( uin and roomid ) then
				uin = uin or 0
				roomid = RentPermitCtrl:GetRentRoomID()
			end
		end
		
		if uin then
			-- GetInst("UIManager"):Open("CloudServerReportingSys", 
			-- {
			-- 	tid=110, 
			-- 	opUin = uin, 
			-- 	nickname="", 
			-- 	wid = wid, 
			-- 	roomId = roomid,
			-- 	title = GetS(10517) .. "#c1ec832" .. GetS(10569), 
			-- 	showScreenShot = true,
			-- })
			GetInst("ReportManager"):OpenReportView({
				tid = GetInst("ReportManager"):GetTidTypeTbl().cloud_server_room,
				op_uin = uin,
				wid = wid,
				roomId = roomid
			})
		else
			uin = getFromOwid(wid)
			-- InformControl:AddInformInfo(101, 
			-- 	uin, 
			-- 	"", 
			-- 	wid, 
			-- 	GetS(10517) .. "#c1ec832" .. GetS(10569))
			-- 	:Enqueue();

			GetInst("ReportManager"):OpenReportView({
				tid = GetInst("ReportManager"):GetTidTypeTbl().map,
				op_uin = uin,
				wid = wid,
			})
		end
	end
end

function InformFrame_OnShow()
	local TID = InformControl:GetTID();

	local tb = {
		"-",
		"Input",
		"ReportButton",
		"CloseButton"
	}
	for _, value in ipairs(tb) do
		standReportEvent("42", "REPORT_CENTER", value, "view")
	end
	
	if TID and TID > 0 then
		if InformControl:GetTypeUIID() > 0 then
			getglobal("InformFrameTickedBtn" .. InformControl:GetTypeUIID() .. "Tick"):Hide();
			InformControl:SetTypeUIID(0);
		end

		local def = GetInformDef(TID);
		local cnum = #def;
		local lHeight = 60;
		local tickeName = "InformFrameTickedBtn";
		getglobal("InformFrameContextEdit"):SetText("");
		getglobal("InformFrameContextEditHint"):Show();

		local infomantInfo = {};

		if infomantInfo.title and string.len(infomantInfo.title) > 0 then
			getglobal("InformFrameTitle2"):SetText(infomantInfo.title);
		else
			getglobal("InformFrameTitle2"):SetText(GetS(10517));
		end
		
		for i=1, 9 do
			local tobj = getglobal(tickeName .. i);
			getglobal(tickeName .. i .."Name"):Hide();
			if i <= cnum then
				getglobal(tickeName .. i .. "Content"):SetText(GetS(def[i].stringid));
				getglobal(tickeName .. i):Show();
			else
				tobj:Hide();
			end
		end


		if TID == 103 and GYouMeVoiceMgr and GYouMeVoiceMgr:isJoinRoom() and YouMeVocieCanEnable() then --联机中举报新增语音举报处理
			getglobal("InformFrameChenDi"):SetHeight(433 + (cnum/3 + cnum % 3)*60)
			getglobal("InformFrameTickedBtn1"):SetPoint("topleft", "InformFrameLine", "topleft", 93, 137)
			getglobal("InformFrameTitle2"):SetPoint("left", "InformFrameIcon", "right", 60, 115)
			getglobal("InformFrameLine"):Hide()

			getglobal("InformFrameSelectFrame"):Show()

			getglobal("InformFrameSelectFrameTickedBtn1Name"):Hide()
			getglobal("InformFrameSelectFrameTickedBtn2Name"):Hide()

			InformFrameSelectFrameTicked_OnClick(1) -- 打开默认选中玩家
		else
			getglobal("InformFrameSelectFrame"):Hide()
			getglobal("InformFrameChenDi"):SetHeight(333 + (cnum/3 + cnum % 3)*60)
			getglobal("InformFrameTickedBtn1"):SetPoint("topleft", "InformFrameLine", "topleft", 93, 25)
			getglobal("InformFrameTitle2"):SetPoint("left", "InformFrameIcon", "right", 60, 2)
			getglobal("InformFrameLine"):Hide()
		end
	end;

	if TID ~= 103 then
		if ClientCurGame:isInGame() and not getglobal("InformFrame"):IsReshow() then
	        ClientCurGame:setOperateUI(true);
	    end
	end
end

function InformFrameClose_OnClick()
	standReportEvent("42", "REPORT_CENTER", "CloseButton", "click")
	if InformControl:GetTID() ~= 103 then
		if ClientCurGame:isInGame() and not getglobal("InformFrame"):IsRehide() then
	        ClientCurGame:setOperateUI(false);
	    end
	end

	InformControl:ClearAllInformInfo();
	getglobal("InformFrame"):Hide();
end

function InformFrameTicked_OnClick()
	local btnName = "InformFrameTickedBtn";
	local id = this:GetClientID();
	local oldId = InformControl:GetTypeUIID();

	if id == oldId then
		return;
	else
		InformControl:SetTypeUIID(id);
		getglobal(btnName .. id .. "Tick"):Show();
		if oldId > 0 then
			getglobal(btnName .. oldId .. "Tick"):Hide();
		end
	end
end

function InformFrameSubmitBtn_OnClick()
	local typeID = InformControl:GetTypeUIID()
	if typeID and typeID > 0 then
		local tid = InformControl:GetTID();
		local text = getglobal("InformFrameContextEdit"):GetText();
		--取消描述字数限制
		--[[if nil == text or #text < 18 then
			ShowGameTips(GetS(20212));
			return;
		end--]]

		InformControl:SetContent(text);

		if tid == InformCode.FriendGroupTID then
			ReqGroupChatReport(GetChatModel():GetNowInformInfo())
		end

		if InformControl:GetSelectId() == 2 then
			local info = InformControl:GetCurInformInfo()
			if info and info.selectId and info.selectId == 2 then
				-- InformFrameRecordPlayerUin(info.op_uin)
				if not IsRoomOwner() then
					if GYouMeVoiceMgr and GYouMeVoiceMgr.notifyVoiceInformToHost then
						GYouMeVoiceMgr:notifyVoiceInformToHost(info.op_uin);
					end
				else
					if GYouMeVoiceMgr and GYouMeVoiceMgr.notifyVoiceInformToClient then
						GYouMeVoiceMgr:notifyVoiceInformToClient(info.op_uin);
					end
				end
				getglobal("InformFrame"):Hide()
			end
		else
			InformControl:IllegalInformAll();
		end
	else
		ShowGameTips(GetS(10554));
	end
end

function InformFrameContext_OnFocusGained()
	standReportEvent("42", "REPORT_CENTER","Input", "click")
	getglobal("InformFrameContextEditHint"):Hide();
end

function InformFrameContext_OnTabPressed()
	getglobal("InformFrameContextEditHint"):Hide();
end

function InformFrameSelectFrameTicked_OnClick(id)
	local btnName = "InformFrameSelectFrameTickedBtn";
	local id = id or this:GetClientID();
	local oldId = InformControl:GetSelectId();

	if id == oldId then
		return;
	else
		local info = InformControl:GetCurInformInfo()
		if info == nil then return end
		if id == 2 then
			if InformFrameCheckViceInformPlayer(info.op_uin) then
				ShowGameTips(GetS(10537),3)
			else
				InformControl:SetSelectId(id);
				info.tid = 114
				getglobal(btnName .. id .. "Tick"):Show();
				if oldId > 0 then
					getglobal(btnName .. oldId .. "Tick"):Hide();
				end
			end
		else
			InformControl:SetSelectId(id);
			info.tid = 103
			getglobal(btnName .. id .. "Tick"):Show();
			if oldId > 0 then
				getglobal(btnName .. oldId .. "Tick"):Hide();
			end
		end
	end
end

-- local VoiceInformPlayerList = {}
-- function InformFrameClearVoiceInformPlayerList()
-- 	VoiceInformPlayerList = {}
-- end

-- function InformFrameRecordPlayerUin(uin)
-- 	table.insert(VoiceInformPlayerList, uin)
-- end

-- -- 检查是否举报过该玩家
-- function InformFrameCheckViceInformPlayer(uin)
-- 	for k ,v in pairs(VoiceInformPlayerList) do
-- 		if v and v == uin then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- -- 回调收到音频id后上传举报信息
-- function InformFrameReportVoice(uin, voiceId,node,dir)
-- 	if uin and voiceId and node and dir then
-- 		print("InformFrameReportVoice:voiceid=" .. voiceId .. "--uin=" .. uin .. "--node=" ..node .. "--dir=" .. dir)
-- 		if voiceId ~= "" then
-- 			local info = InformControl:GetCurInformInfo()
-- 			if info and info.op_uin == uin then
-- 				info.voiceId = voiceId
-- 				info.node = node
-- 				info.dir = dir
-- 				InformControl:IllegalInformAll();
-- 				InformFrameRecordPlayerUin(uin)
-- 			end
-- 		else
-- 			InformControl:ClearAllInformInfo();
-- 			getglobal("InformFrame"):Hide();
-- 			ShowGameTips(GetS(10726))
-- 		end
-- 	else
-- 		InformControl:ClearAllInformInfo();
-- 		getglobal("InformFrame"):Hide();
-- 		ShowGameTips(GetS(10726))
-- 	end
-- end

-- -- 上传音频文件
-- function InformFrameUpLoadReportVoiceFile(path,voiceId)
-- 	if path and path ~= "" then
-- 		print("path-----------" .. path)
	

-- 		local callback_pos = function(ret_)
-- 			--请求位置成功
-- 			print("callback_pos:", ret_);
-- 			if ret_ and string.sub( ret_, 1, 3 ) == "ok:" then
-- 				local upload_url_ =  string.sub( ret_, 4 );
-- 				upload_url_ = string_trim( upload_url_ );
-- 				upload_url_ = upload_url_ 
-- 				print( "[" .. upload_url_  .. "]" );
-- 				local callback_up = function(ret, token_)
-- 					--上传成功
-- 					print("callback_up: 300");
-- 					print(ret);
-- 					print(token_);
-- 					-- ShowLoadLoopFrame(false)
-- 					if  ret == 200 then
-- 						print("successful:200:");
-- 						--ShowGameTips("上传成功");
-- 					elseif ret == nil or ret < 0 then
-- 						--ShowGameTips("上传失败");
-- 					end
-- 				end

-- 				--2. 请求上传音频
-- 				local filename = path
-- 				print("filename = " .. filename);
-- 				-- ShowLoadLoopFrame(true);
-- 				upload_url_ = upload_url_ .. "&voiceid=" .. voiceId
-- 				ns_http.func.upload_md5_absolute_file(filename,  upload_url_, callback_up);

-- 				local urlList = parseUrl(upload_url_)
-- 				print(urlList)
-- 				print(urlList["node"])
-- 				-- print(urlList["dir"])
-- 				GYouMeVoiceMgr:setUploadVoiceParam(urlList["node"],urlList["dir"])
-- 			else
-- 				Log( "InformFrameUpLoadReportVoiceFile = false" );
-- 				if ret_ == nil or ret_ < 0 then
-- 					-- ShowGameTips(GetS(146));
-- 					-- ShowLoadLoopFrame(false)
-- 				end
-- 			end
-- 		end

-- 		--1. 请求上传位置
-- 		UploadVoicePre(callback_pos);
-- 	end
-- end

-----------------------------------------举报功能 end-----------------------------------------------------

-- 与C++宏 IWORLD_UI_SKIN_FOLDER_SWITCH 对应，皮肤是否读取本地文件夹的开关
function IsLocalUISkin()
	-- body
	-- if DebugMgr:IsDevBuild() then
	-- 	return true
	-- end

	--开始使用公共皮肤文件夹之后，皮肤下载zip包只包含部分差异性图片，其他在公共文件夹搜索
	--这里改成根据版本号判断要不要读文件夹
	if ClientMgr:clientVersion() >= ClientMgr:clientVersionFromStr("0.39.2") then
		return true 
	end
	return false
end

function OnCollaborationModeProfileReport(msgData)
	print("OnCollaborationModeProfileReport 111", msgData)
	CollaborationModeIllegalReportTime = tonumber(msgData.end_time)
	if ClientCurGame:isInGame() and IsRoomOwner() then
		print("OnCollaborationModeProfileReport 222")
		local callback = function(flag, data)
			AccountManager:sendToClientKickInfo(2)
			if not PlatformUtility:isPureServer() then
				SafeCallFunc(GetInst("ArchiveLobbyRecordManager").CacheAddRecord, GetInst("ArchiveLobbyRecordManager"))
			end
			LeaveRoomType = 1
			SendMsgWaitTime = 0.5
		end

		MessageBox(4, GetS(25824, os.date("%Y-%m-%d %H:%M", CollaborationModeIllegalReportTime)), callback, nil)
	end
end

function GameDelayExit()
	if ClientCurGame and ClientCurGame.isInGame and ClientCurGame:isInGame() and AccountManager:getMultiPlayer() ~= 0 and IsRoomOwner() then
		AccountManager:sendToClientKickInfo(2)
		if not PlatformUtility:isPureServer() then
			SafeCallFunc(GetInst("ArchiveLobbyRecordManager").CacheAddRecord, GetInst("ArchiveLobbyRecordManager"))
		end
		LeaveRoomType = 2
		SendMsgWaitTime = 0.5
	else
		GameExit()
	end
end

function SetSoundVolume(value)
	--qq钢琴乐器
	if FmodSoundSystemEX and FmodSoundSystemEX:GetSingletonPtr() then
		FmodSoundSystemEX:GetSingletonPtr():setSoundVolume(value)
	end
end

-- 设置-其他-录像-埋点
function RecordSwitchReport(eventId, button_state)
	if not IsOpenGameMapUploadFunc() then
		return
	end
	
	local reportParam = {}
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc()
		if wdesc then
			local owid  = wdesc.fromowid
			local worldid = wdesc.worldid
			if wdesc.fromowid == 0 then
				owid = wdesc.worldid
			end
			reportParam.cid = owid 
			reportParam.standby13 = wdesc.worldtype
			if wdesc.realowneruin == wdesc.owneruin then --自己地图
				reportParam.standby11 = 1
				if AccountManager:getMultiPlayer() == 0 then --单机
					reportParam.standby12 = 1
				else --房主
					if IsArchiveMapCollaborationMode() then
						reportParam.standby12 = 3
					else
						reportParam.standby12 = 2
					end
					
				end
			else --他人地图
				reportParam.standby11 = 2
				if AccountManager:getMultiPlayer() == 0 then --单机
					reportParam.standby12 = 1
				else --房主
					reportParam.standby12 = 2
				end			
			end
		end
		
	else -- 客机或云服
		--家园不要处理
		if IsInHomeLandMap and IsInHomeLandMap() then

		else
			local owid = G_GetFromMapid();
			local authorUin = getFromOwid(owid)
			reportParam.cid = owid 
			if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then--云服
				reportParam.standby12 = 4
				reportParam.standby11 = 2
				if authorUin == AccountManager:getUin() then
					reportParam.standby11 = 1
				else
					reportParam.standby11 = 2
				end
			else --客机
				--好友联机
				if IsArchiveMapCollaborationMode() then
					reportParam.standby12 = 3
					if authorUin == AccountManager:getUin() then
						reportParam.standby11 = 1
					else
						reportParam.standby11 = 2
					end
				else --非好友联机
					reportParam.standby11 = 2
					reportParam.standby12 = 2
					if authorUin == AccountManager:getUin() then
						reportParam.standby11 = 1
					else
						reportParam.standby11 = 2
					end
				end
			end
		end
	end

	local standby13 =  reportParam.standby13 or 0
	local standby12 =  reportParam.standby12 or 1
	local standby11 =  reportParam.standby11 or 1
	reportParam.standby1 =	standby11..standby12..standby13
	reportParam.ctype = 1

	reportParam.standby11 = nil
	reportParam.standby12 = nil
	reportParam.standby13 = nil

	if button_state then -- click增加 0关,1开
		reportParam.button_state = button_state
	end
	standReportEvent(2901, "SETTING_OTHERS", "Record", eventId, reportParam)

end

--点击联系客服
function CustomerServiceBtn_OnClick()
	local uin = AccountManager:getUin()
	if ClientMgr:isAndroid() then
		JavaMethodInvokerFactory:obtain()
		:setSignature("(Ljava/lang/String;)V")
		:setClassName("com/minitech/miniworld/customeservicelib/CustomServiceBridge")
		:setMethodName("openCustomService")
		:addString(tostring(uin))
		:call()
	elseif ClientMgr:isApple() then
		luaoc.callStaticMethod("MNSobotManager", "openCustomService", {
			uin = tostring(uin),              
		})
	else
		local url = "https://miniwankf.sobot.com/chat/pc/v2/index.html?sysnum=01d3d42bc0a24b4c99583e2c9527a0b6&channelid=8&partnerid=%d"
		url = string.format(url, uin)
		SdkManager:BrowserShowWebpage(url)
	end
end

---------------------------------------------------------------------------------------

function GameSetFrameOtherAppPush_Show()
	if not ClientMgr:isMobile() then
		GameSetFrameOtherAppPush_HideAll()
		
		return 
	end	
	
	-- 权限检测
	local hasPerMission = false
	if ClientMgr:isAndroid() then
		if MINIW__CheckHasPermission and MINIW__CheckHasPermission(7) then
			hasPerMission = true
		end
	elseif ClientMgr:isApple() then
		if SdkManager.CheckHasPermission and SdkManager:CheckHasPermission(DevicePermission_Notification) then
			hasPerMission = true
		end
	end
	
	local param = {}
	
	local setText = getglobal("GameSetFrameOtherAppPushSetText")
	if not hasPerMission then 
		GameSetFrameOtherAppPush_SetCheckGray(true)
		
		setText:SetText("未开启")
		setText:SetTextColor(200, 0, 0)
		getglobal("GameSetFrameOtherAppPushSetBtn"):Show()
		
		standReportEvent("2901", "SETTING_OTHERS", "Gosetting", "view")
		param.standby1 = 0
	else 
		GameSetFrameOtherAppPush_SetCheckGray(false)
		
		setText:SetText("已开启")
		setText:SetTextColor(0, 200, 0)
		getglobal("GameSetFrameOtherAppPushSetBtn"):Hide()
		
		param.standby1 = 1
	end 
	
	local setFunc = function ()
		-- 首次显示
		if not getkv("AppPushNoticeFirstSet") then
			GameSetFrameOtherAppPush_GetCfgBySvr(function (svrData)
				print("---wzlog---AppPush_Init:", svrData)
				
				if svrData and svrData.ret == 0 then 
					if svrData.data == nil or next(svrData.data) == nil then 
						GameSetFrameOtherAppPush_SetCfgBySvr(true, nil, function (sdata)
							setparam = sdata.data or {}
							
							GameSetFrameOtherAppPush_SetCheckBySvr(setparam)
							setkv("AppPushNoticeFirstSet", true)
						end)
					else 
						setparam = svrData.data or {}
						GameSetFrameOtherAppPush_SetCheckBySvr(setparam)
					end 
				end 
			end)
			
			return 
		end 
		
		-- 拉取服务端配置
		if setparam then 
			GameSetFrameOtherAppPush_SetCheckBySvr(setparam)
		else 
			GameSetFrameOtherAppPush_GetCfgBySvr(function (svrData)
				if svrData and svrData.ret == 0 and svrData.data then 
					setparam = svrData.data or {}
					
					GameSetFrameOtherAppPush_SetCheckBySvr(setparam)
					
					if setparam then 
						param.standby2 = ""
						for i = 1, 4 do 
							local index = switchType[i]
							if not setparam[index] or setparam[index] == 0 then 
								param.standby2 = param.standby2 .. 0
							else 
								param.standby2 = param.standby2 .. 1
							end 
						end 
						
						standReportEvent("2901", "SETTING_OTHERS", "Apppush", "view", param)
					end 
				end 
			end)
		end 
	end
	
	-- 拉取可视化配置
	local cfg = GetInst("VisualCfgMgr"):GetCfg("AppPushNoticeSetCfg")
	if cfg then 
		GameSetFrameOtherAppPush_SetByCfg(cfg)
		
		if cfg and cfg.main_cfg and cfg.main_cfg.isOpen and check_apiid_ver_conditions(cfg.main_cfg) then 
			setFunc()
		end
	else 
		GetInst("VisualCfgMgr"):ReqCfg("AppPushNoticeSetCfg", function (code, ret)
			if code == 0 then
				GameSetFrameOtherAppPush_SetByCfg(ret)		
				
				if ret and ret.main_cfg and ret.main_cfg.isOpen and check_apiid_ver_conditions(ret.main_cfg) then 
					setFunc()
				end
			end
		end)
	end 
end

-- 外显设置
function GameSetFrameOtherAppPush_SetByCfg(cfg)
	if not cfg then 
		return 
	end 
	
	if cfg.main_cfg then 
		if not cfg.main_cfg.isOpen or not check_apiid_ver_conditions(cfg.main_cfg) then 
			GameSetFrameOtherAppPush_HideAll()
			
			return 
		end 
	end 
	
	local showCmp = {}
	if cfg.cfg1 then 
		if cfg.cfg1.isOpen and check_apiid_ver_conditions(cfg.cfg1) then 
			showCmp[1] = true
		end
	end 
	
	if cfg.cfg2 then 
		if cfg.cfg2.isOpen and check_apiid_ver_conditions(cfg.cfg2) then 
			showCmp[2] = true
		end
	end
	
	if cfg.cfg3 then 
		if cfg.cfg3.isOpen and check_apiid_ver_conditions(cfg.cfg3) then 
			showCmp[3] = true
		end
	end
	
	if cfg.cfg4 then 
		if cfg.cfg4.isOpen and check_apiid_ver_conditions(cfg.cfg4) then 
			showCmp[4] = true
		end
	end
	
	local parent = "GameSetFrameOther"
	local posIdx = 0
	for i = 1, 4 do
		local chekNameCmp = getglobal(parent .. "AppPushCheckName" .. i)
		local checkCmp = getglobal(parent .. "AppPushCheck" .. i)
		
		if showCmp[i] then 
			if chekNameCmp then 
				local pos = {60, 300, 500, 700}
				if not showCmp[1] then 
					pos = {60, 260, 460, 660}
				end 
				chekNameCmp:SetPoint("topleft", parent, "topleft", pos[posIdx+1], 446)
			end
			
			if checkCmp then 
				local pos = {30, 270, 470, 670}
				if not showCmp[1] then 
					pos = {30, 230, 430, 630}
				end 
				checkCmp:SetPoint("topleft", parent, "topleft", pos[posIdx+1], 429)
			end 
			
			posIdx = posIdx + 1
		else 
			if chekNameCmp then 
				chekNameCmp:Hide()
			end
			
			if checkCmp then 
				checkCmp:Hide()
			end 
		end 
	end
end

switchType = {
	1,    --好友上线
	2,    --加好友消息
	3,    --好友消息
	10,   --消息中心
}

-- 同步服务器配置
function GameSetFrameOtherAppPush_SetCheckBySvr(setparam)
	if setparam then 
		for i = 1, 4 do 
			local checkbtn = getglobal("GameSetFrameOtherAppPushCheck"..i.."Tick")
			if checkbtn then
				local index = switchType[i]
				if not setparam[index] or setparam[index] == 0 then 
					checkbtn:Hide()
				else 
					checkbtn:Show()
				end 
			end
		end 
	end 
end 

-- App推送通知 - 隐藏整个功能
function GameSetFrameOtherAppPush_HideAll()
	local parent = "GameSetFrameOther"
	local appPuseSetCmp = {
		"Line5",
		"AppPushSetTitle",
		"AppPushSetText",
		"AppPushSetBtn"
	}
	
	for _, value in ipairs(appPuseSetCmp) do
		local cmp = getglobal(parent .. value)
		if cmp then 
			cmp:Hide()
		end 
	end
	
	for i = 1, 4 do
		local chekNameCmp = getglobal(parent .. "AppPushCheckName" .. i)
		local checkCmp = getglobal(parent .. "AppPushCheck" .. i)
		
		if chekNameCmp then 
			chekNameCmp:Hide()
		end
		
		if checkCmp then 
			checkCmp:Hide()
		end 
	end
	
	getglobal("OtherScrollPanel"):setSlidingY(false)
	getglobal(parent):SetHeight(441)
end

-- App推送通知 - 灰度check按钮
function GameSetFrameOtherAppPush_SetCheckGray(isGray)
	local parent = "GameSetFrameOther"
	for i = 1, 4 do
		local chekNameCmp = getglobal(parent .. "AppPushCheckName" .. i)
		local checkCmp = getglobal(parent .. "AppPushCheck" .. i)
		
		if chekNameCmp then 
			if isGray then 
				chekNameCmp:SetTextColor(128, 128, 128)
			else 
				chekNameCmp:SetTextColor(61, 69, 70)
			end 
		end
		
		if checkCmp then 
			if isGray then 
				checkCmp:Disable(true)
			else 
				checkCmp:Enable()
			end 
		end 
	end
end

-- App推送通知 - 设置按钮
function GameSetFrameOtherAppPushSetBtn_OnClick()
	if ClientMgr:isAndroid() or ClientMgr:isApple() then
		GetInst("MessageBoxInterface"):dualBtnBoxWithTitle(nil,GetS(1363), GetS(102912), GetS(970), function(_, type)
			if 0 == type then --前往手机设置界面
				if ClientMgr:isAndroid() then
					if MINIW__OpenSystemSetting then
						MINIW__OpenSystemSetting()
					end
				elseif ClientMgr:isApple() then
					if SdkManager.OpenSystemSetting then
						SdkManager:OpenSystemSetting();
					end
				end
			elseif 1 == type then --取消
			end
		end, nil, false)
	else
		-- ShowGameTips(GetS(1364))
	end
	
	standReportEvent("2901", "SETTING_OTHERS", "Gosetting", "click")
end

-- App推送通知 - 勾选按钮
function GameSetFrameOtherAppPushCheckClick_OnClick()
	local idx = this:GetClientID()
	if not idx then 
		return 
	end 
	
	local checkbtn = getglobal("GameSetFrameOtherAppPushCheck"..idx.."Tick")
	if checkbtn then
		local param = {}
		param.standby1 = idx
		
		local index = switchType[idx]
		if checkbtn:IsShown() then 
			checkbtn:Hide()
			
			if setparam then 
				setparam[index] = 0
			end 
			
			param.standby2 = 0
		else 
			checkbtn:Show()
			
			if setparam then 
				setparam[index] = 1
			end
			
			param.standby2 = 1
		end 
		
		standReportEvent("2901", "SETTING_OTHERS", "Pushonoff", "click", param)
	end
	
	-- 同步消息到服务端
	GameSetFrameOtherAppPush_SetCfgBySvr(false, setparam)
end

-- 设置消息到服务端
function GameSetFrameOtherAppPush_SetCfgBySvr(isdefault, tparam, callback)
	local RespCb = function(retstr)
        if callback then
            local ret = safe_string2table(retstr)
            callback(ret)
        end
    end
	
	local params = nil
	
	if isdefault then 
		params = {}
		params["1"] = 1
		params["2"] = 1
		params["3"] = 1
		params["10"] = 1
	else 
		if tparam then 
			params = {}
			for key, value in pairs(tparam) do
				params[tostring(key)] = value
			end
		end
	end 
	
	if params then 
		local url = GameSetFrameOtherAppPush_GetUrl("set_setting",	{setting=JSON:encode(params)})
		print("---wzlog---set_setting url:", url)
		ns_http.func.rpc_string_raw_ex(url, RespCb)
	end 
end 

-- 拉取消息到服务端
function GameSetFrameOtherAppPush_GetCfgBySvr(callback)
	local RespCb = function(retstr)
        if callback then
            local ret = safe_string2table(retstr)
            callback(ret)
        end
    end
	
	local url = GameSetFrameOtherAppPush_GetUrl("get_setting")
	print("---wzlog---get_setting url:", url)
    ns_http.func.rpc_string_raw_ex(url, RespCb)
end 

function GameSetFrameOtherAppPush_GetUrl(act, param)
    local url = CSMgr:getHttpMapServer() .. "/miniw/mobpush_proxy?"
    
    local reqParams = {
        act = act
    }
	
	local function urlEncode(s)
		s = string.gsub(s, "([^%w%.%- _])", function(c) return string.format("%%%02X", string.byte(c)) end)
	   return string.gsub(s, " ", "+")
	end
    
    if param then
        for key, value in pairs(param) do
            reqParams[key] = urlEncode(value)
        end
    end
    
    local paramStr, md5 = http_getParamMD5(reqParams)
	url = url .. paramStr .. '&md5=' .. md5 

    return url
end