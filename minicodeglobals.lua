--刷新lobby界面
function RefreshLobbyFrameForEdu()
	if not isEducationalVersion then
		return;
	end

	VehicleMgr:loadPhysicsPartsConnectInfo()

	getglobal("GongNengFrameScreenshotBtn"):Hide()
	getglobal("GongNengFrameMenuArrow"):Hide()
	
	-- getglobal("GongNengFrameSettingBtn"):Hide()
	--getglobal("PlayShortcut"):Hide();
	--getglobal("PlayMainFrameBackpack"):Hide()
	getglobal("PcGuideKeySightMode"):Hide()
	GetInst("UIManager"):Close("ToolModeFrame");
	--getglobal("GongNengFrameTriggerRunTimeInfo"):Hide();
	--录屏按钮
	getglobal("GongNengFrameOpenCameraModeBtn"):Hide();
	getglobal("MultiChatBtn"):Hide();
	-- getglobal("GongNengFrameSwitchUGCModeBtn"):Hide();
	
	ClientMgr:setGameData("autojump",1);
	if not ClientMgr:isMobile() then
		ClientMgr:setGameData("view_distance", 4);
	end

	getglobal("AccRideCallBtn"):Hide();

	MiniCode = class.MiniCode.new();
	MiniCode:setVisible_noticeboard(false)

	local wdesc = AccountManager:getCurWorldDesc();
	local mapOwnerUin = wdesc and wdesc.realowneruin or nil;
	local uin = AccountManager:getUin()	

	if CurWorld and CurWorld:isGameMakerMode() and ClientMgr and not ClientMgr:isMobile() and mapOwnerUin and uin and uin == mapOwnerUin then
		getglobal("GongNengFrameRuleSetGNBtn"):Show()
		getglobal("GongNengFrameModelLibBtn"):Show()
		getglobal("GongNengFramePluginLibBtn"):Show();
		if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.SHOP) then--xyang自定义UI
			getglobal("GongNengFrameDeveloperStoreBtn"):Show()
		end
		GongNengFrameUILibBtn_Show()
		getglobal("GongNengFrameModelLibBtn"):SetPoint("right", "GongNengFrameRuleSetGNBtn", "left", -7, 0);
		getglobal("GongNengFramePluginLibBtn"):SetPoint("right", "GongNengFrameModelLibBtn", "left", -7, 0);
		getglobal("GongNengFrameDeveloperStoreBtn"):SetPoint("right", "GongNengFramePluginLibBtn", "left", -7, 0);
		getglobal("GongNengFrameUILibBtn"):SetPoint("right", "GongNengFrameDeveloperStoreBtn", "left", -7, 0);

		--校园版
		if IsEduToB() and not MCodeMgr:getRule(-5) then
			getglobal("GongNengFrameRuleSetGNBtn"):Hide()
			getglobal("GongNengFrameModelLibBtn"):Hide()
			getglobal("GongNengFramePluginLibBtn"):Hide();
			getglobal("GongNengFrameDeveloperStoreBtn"):Hide();
			getglobal("GongNengFrameUILibBtn"):Hide();

		end
	else
		getglobal("GongNengFrameRuleSetGNBtn"):Hide()
		getglobal("GongNengFrameModelLibBtn"):Hide()
		getglobal("GongNengFramePluginLibBtn"):Hide();
		getglobal("GongNengFrameDeveloperStoreBtn"):Hide();
		getglobal("GongNengFrameUILibBtn"):Hide();
	end

	getglobal("DevToolsTabTypeBoxDevEditTrigger"):Hide()
	getglobal("DevToolsTabTypeBoxScript"):Hide()
	getglobal("DevToolsRuleConverBtn"):Hide()

	-- 左上角游客模式计时屏蔽
	local gameLab = getglobal("MiniLobbyFrameGameMode");
	if gameLab then
		gameLab:Hide();
	end
	local gameModeUI =	getglobal("PlayMainFrameGameMode");
	if gameModeUI then
		gameModeUI:Hide();
	end

	local exGameLab = getglobal("MiniLobbyExGameMode");
	if exGameLab then
		exGameLab:Hide();
	end

	if AccountManager:getMultiPlayer() > 0 then
		getglobal("CoordSelectionFrameToolModeBtn"):Hide();	
	else
		getglobal("CoordSelectionFrameToolModeBtn"):Show();	
	end

	if getglobal("RSConnectLostFrame"):IsShown() then
		getglobal("RSConnectLostFrame"):Hide();
	end

	ClientMgr:setGameData("physxparam",0);--不显示地图稳定度

	-- 联机地图隐藏部分ui
	-- print("AccountManager:getMultiPlayer()="..tostring(AccountManager:getMultiPlayer()));
	if AccountManager:getMultiPlayer() > 0 then
		getglobal("GongNengFrameDeveloperStoreBtn"):Hide()
		getglobal("MultiChatBtn"):Hide()
		InteractiveBtn_ShowOrHide(false)
	end

	-- 隐藏附魔兑换金币按钮
	getglobal("StarConvertFrameConvertBtn"):Hide()

	if GetIWorldConfig():getGameData("minicodeCompassHide") == 0 then
		getglobal("Compass"):Hide();
	end

	if UGCModeMgr and UGCModeMgr:IsUGCMode() and not UGCModeMgr:IsRunning() then  -- ugc 高级模式
		getglobal("GongNengFrameSettingBtn"):Show()
	else
		getglobal("DevToolsTabTypeBoxDevEditTrigger"):Hide()
		getglobal("DevToolsTabTypeBoxScript"):Hide()
		getglobal("DevToolsRuleConverBtn"):Hide()	
		getglobal("GongNengFrameSettingBtn"):Hide()
	end

	
	GetInst("UIManager"):Close("ToolModeFrame");
	if (CurWorld and CurWorld:isGameMakerRunMode()) or (UGCModeMgr and UGCModeMgr:IsUGCMode()) then
		GetInst("UIManager"):Close("CoordSelectionFrame");
		getglobal("CoordSelectionFrameToolModeBtn"):Hide()
	else
		local param = {disableOperateUI = true};
		GetInst("UIManager"):Open("CoordSelectionFrame", param);
		getglobal("CoordSelectionFrameToolModeBtn"):Show()
	end

end

--是否是B端
function IsEduToB()
	if not isEducationalVersion then
		return false;
	end

	return MCodeMgr:getChannel() == 1000 or (MCodeMgr:getChannel() >=800 and MCodeMgr:getChannel() <= 899) 	
end

--战斗结束界面关闭按钮
function BattleEndFrameCloseBtn_OnClick_Edu()
	if isEducationalVersion then
		getglobal("BattleFrame"):Hide();
		MiniUI_GameSettlement.CloseUI(); -- 关闭结算
		getglobal("BattleEndFrameSpectatorModeBtn"):Hide();
		HideUI2GoMainMenu();

		local result = {0};
		MCodeMgr:miniCodeCallBack(-22, JSON:encode(result));
	end
end

--战斗结束界面OnShow
function BattleEndFrameOnShow_Edu()
	if not isEducationalVersion then
		return;
	end

	getglobal("BattleEndFrameShareBtn"):Hide();
	getglobal("BattleEndFrameReopen"):Hide();
	getglobal("BattleEndFrameScoreboardBtn"):Hide();
	getglobal("BattleEndFrameJoinBtn"):Hide();
	getglobal("BattleEndFrameCloseBtn"):Hide();--教育版任何情况都不显示 “离开”按钮。
	if _G.MiniCodeGuanQiaFrame then
		_G.MiniCodeGuanQiaFrame = false;
		--不显示皇冠动画
		getglobal("BattleEndFrameView"):deleteBackgroundEffect("particles/Ribbon.ent");
		getglobal("BattleEndFrameView"):deleteBackgroundEffect("particles/Ribbon_h.ent");
	else
		getglobal("BattleEndFrameView"):setActorPosition(0, -15, 500, 0)
	end

	getglobal("BattleEndFrameMapDesc"):Hide()
end

--死亡界面,只在B端生效
function BattleDeathFrameOnShow_Edu()
	if not isEducationalVersion then
		return;
	end

	if not IsEduToB() then
		return;
	end

	getglobal("DeathFrameTombstone"):Hide();
	getglobal("DeathFrameCause"):Hide();
	getglobal("DeathFrameWarningTips"):Hide();
	getglobal("DeathFrameContinueBtn"):Hide();
	getglobal("DeathFrameRBtnMessage"):Hide();

	getglobal("DeathFrameReviveBtn"):SetPoint("center", "DeathFrame", "center", 0, 0);
	getglobal("DeathFrameReviveBtnText"):SetText("再试一次");
end

--设置界面OnShow
function SettingFrameOnShow_Edu()
	if not isEducationalVersion then
		return;
	end

	getglobal("SetMenuFrameLeftSetFrameRecordSwitchBtn"):Hide();
	getglobal("ScreenShotFrameLock"):Hide();
	getglobal("SetMenuFrameFeedBackBtn"):Hide();

	getglobal("SetMenuFrameLeftSetFrameCreateRoomBtnNormal"):SetGray(true);
	getglobal("SetMenuFrameLeftSetFrameCreateRoomBtn"):Disable();

	getglobal("SetMenuFrameLeftSetFrameChangeGameModeBtnNormal"):SetGray(true);
	getglobal("SetMenuFrameLeftSetFrameChangeGameModeBtn"):Disable();

	getglobal("SetMenuFrameFeedBackBtn2"):Show();
	getglobal("SetMenuFrameFeedBackBtn2Normal"):SetGray(true);
	getglobal("SetMenuFrameFeedBackBtn2"):Disable();

	getglobal("SetMenuFrameGameSetBtnNormal"):SetGray(true);
	getglobal("SetMenuFrameGameSetBtn"):Disable();

	getglobal("SetMenuFrameInformBtnNormal"):SetGray(true);
	getglobal("SetMenuFrameInformBtn"):Disable();
	
	HideWebView_Edu();
	minicodeFullScreenUIEvent(1);
end

--教育版不显示的tip
function IsTipTextForbiddenByEdu(text)
	if not isEducationalVersion then
		return false;
	end

	if text == GetS(3752) or text == GetS(771) or text == GetS(100235) or text == GetS(3690) 
		or text == GetS(3691) or text == GetS(3692) or text == GetS(3693)  or text == GetS(21595) then 
		return true;
	else
		return false;
	end
end

function HideWebView_Edu(bNeed)
	if not bNeed then
		return;
	end
	if isEducationalVersion then
		if not ClientMgr:isPC() and MCodeMgr then
			local tParam = {0, "hide_webview"}
			MCodeMgr:miniCodeCallBack(-1001, JSON:encode(tParam));
			-- fgui 攻略按钮
	                local jsonStr = JSON:encode({event="hideOrShowStrategy", content=false});
	                MCodeMgr:doAction(-1, JSON:encode({"edu_miniui_jsbNativeCall", -1, jsonStr}), 1);
		end
	end	
end

function ShowWebView_Edu(bNeed)
	if not bNeed then
		return;
	end
	if isEducationalVersion then
		if not ClientMgr:isPC() and MCodeMgr then
			local tParam = {0, "show_webview"}
			MCodeMgr:miniCodeCallBack(-1001, JSON:encode(tParam));
			-- fgui 攻略按钮
			local jsonStr = JSON:encode({event="hideOrShowStrategy", content=true});
            		MCodeMgr:doAction(-1, JSON:encode({"edu_miniui_jsbNativeCall", -1, jsonStr}), 1);
		end
	end	
end

--是否是游客模式
function IsEduTouristMode()
	if isEducationalVersion and CurMainPlayer:getUin() == 1 then
		return true;
	else
		return false
	end
end

function ShowIdentificationDialog_Edu(ddiRet)
	if not isEducationalVersion then
		return
	end
	local stringId = 21681;
	if ddiRet == ErrorCode.NETWORK_ERROR then
		stringId = 21678;
	end
	MessageBox(4, GetS(stringId), function()
		ShowWebView_Edu()
		minicodeFullScreenUIEvent(0);
	end)
end

function InitShortcuts_Edu()
	--local itemlist = {104,505,101,206,207,106,100,123};--迷你世界默认，只在创造模式生效
	local itemlist = {104,100,206,1001,11100,1138,1142,10500};--教育版默认，只在创造模式生效
    MCodeMgr:log("zuoyou, InitShortcuts_Edu*********************")
	for i = 1,8 do 
		CurMainPlayer:getBackPack():addItem(itemlist[i],1)
	end
end

--退出地图时调用，移动端和pc端都需要
function OnLeaveMap()
	if not isEducationalVersion then
		return;
	end

	--战斗结束界面begin
	local view = getglobal("BattleEndFrameView");
	if view then
		for i=1, 6 do
			local body = view:getActorBody(i-1)
			if body then
				if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
					view:detachActorBody(body, i-1)
				else
					body:detachUIModelView(view, i-1);
				end
			end
		end
	end
	if getglobal("BattleFrame") and getglobal("BattleFrame"):IsShown() then
		getglobal("BattleFrame"):Hide();
	end
	
	MiniUI_GameSettlement.CloseUI();
	--战斗结束界面end

	HideUI2GoMainMenu();

	ModsLib_OnLeave();
	if getglobal("CreateBackpackFrame")  and getglobal("CreateBackpackFrame"):IsShown() then getglobal("CreateBackpackFrame"):Hide(); end
	if getglobal("ResourceCenter") and getglobal("ResourceCenter"):IsShown() then getglobal("ResourceCenter"):Hide(); end

	--退出地形编辑器界面
	if getglobal("MapEditExitBtn")  and getglobal("MapEditExitBtn"):IsShown() then GetInst("UIManager"):GetCtrl("MapEditBlockLib"):CloseBtnClicked() end

	--TODO，退出载具？
end

--生成新版配角的MonsterDef
function CreateMonsterDef_Edu()
	--迷斯拉 兔妹妹 妮妮 卡卡 鸡 猪 羊 狼 狗 企鹅 熊猫 蜜蜂 萤火虫 劳尔
	--TODO,后期参数过多的话改为字符串 x_x_x的形式
	--local copyList = {3837,3837,3837,3837,3400,3402,3403,3407,3408,3409,3417,3418,3419,3837}
	--local hasAvatar = {true,true,true,true,false,false,false,false,false,false,false,false,false,true}
	--local modelList = {"140004","140001","p8","p2","110003","110002","110029","110010","110010","110022","110017","110056","110057","140065"}
	--local ModelTypeList = {20004,20003,10008,10002,0,0,0,0,0,0,0,0,0,0}--暂时不清楚做啥用的

	--for i = 1,14 do
		--MCodeMgr:createOneMonsterDef(i,copyList[i],modelList[i],ModelTypeList[i],hasAvatar[i]);
	--end
end

local offestForEduGuideArrow = -28;
function Edu_OnUpdate()
	if not isEducationalVersion then
		return;
	end

	local frame = getglobal("ToolShortcut2PointArrowForEdu");
	if frame and frame:IsShown() then
		if offestForEduGuideArrow >= 0 then
			offestForEduGuideArrow = -25
		else
			offestForEduGuideArrow = offestForEduGuideArrow + 3;
		end

		frame:SetPoint("bottom", "ToolShortcut2", "top", 0, offestForEduGuideArrow);
	end
end

--屏蔽输入法
function OnGainFocus_MiniCode( ... )
	UIFrameMgr:setCurEditBox(getglobal("ChatInputBox"));
	UIFrameMgr:setCurEditBox(nil);	
end

function notifyJsUnlockItem_MiniCode(uin)
	-- 处理获得的道具解锁信息
	local tNeedCheckItemIdS = {
		419, 420, 424, 427, 428, 429, 539, 551, 552, 553,
		554, 854, 855, 856, 857, 858, 859, 860, 861, 862,
		863, 864, 865, 866, 867, 868, 869, 870, 871, 872, 873
		, 874, 875, 876, 877, 881, 883, 884, 885, 886, 888
		, 890, 892, 893, 894, 895, 896, 897, 898, 899, 900
		, 926, 927, 928, 929, 931, 933, 934, 935, 936, 940
		, 941, 942, 943, 945, 946, 947, 948, 949, 960, 961
		, 962, 963, 964, 965, 966, 967, 968, 969, 970, 971
		, 972, 973, 974, 975, 976, 977, 978, 979,1060,1101,
		1102,1103,1104,1105,1106,1107,1108,1109,1110,1111,
		1112,1113,1114,1115,1116,1117,1118,1119,1120,1136,
		1137,1145,1158,1159,1160,1161,1164,1165,1747,1748,
		1749,1750,1751,1752,12253,12280,12281,12283,12284,
		12291,12589,12830,13609,13610,13611,13612,13613,13614,
		13615,13616,13617,13618,13619,13808,15506,15507,15508,15519,15520
	};
		
		local tUnlocked = {}		-- 0表示成功，uin, 后面接上已经解锁的itemid							
		for i = 1, #tNeedCheckItemIdS do
			if isItemUnlockByItemId(tNeedCheckItemIdS[i]) then
				local unlockedId = tNeedCheckItemIdS[i];
				if unlockedId > 10000 then
					unlockedId = unlockedId - 10000;
				end
				tUnlocked[#tUnlocked + 1] = unlockedId;
			end
		end
		if MCodeMgr then
			print('>>>>>>>>>>>>>>>>>>>>>>>>>>>')
			print(JSON:encode(tUnlocked))
			MCodeMgr:onUnlockItem(tostring(uin), JSON:encode(tUnlocked));
		end
end

function setMainFrameUI(name, visible)
	print(">>>>", name, visible);

	if name == "Backpack" or name == "Rocket" then
		return 
	end

	if not getglobal(name) then
		return 
	end

	if (type(visible) == "boolean" and visible == true) or (type(visible) == "number" and visible > 0) then
		getglobal(name):Show();
	else
		getglobal(name):Hide();
	end
	
end

-- 屏蔽背包
function checkCanOpenBackpack_MiniCode()
	local status = MCodeMgr:getMainPlayUIStatus("Backpack")
	if not status then
		ShowGameTips("当前关卡暂时无法使用背包");
	end
	
	return status;
end

-- 屏蔽玩家血量
function checkCanOpenPlayerHPBar_Minicode()
	if not MCodeMgr:getMainPlayUIStatus("PlayerHPBar") then
		PlayerHPBar_ShowOrHide(false);
	end
end

-- 屏蔽玩家饥饿度
function checkCanOpenPlayerHunger_Minicode()
	if not MCodeMgr:getMainPlayUIStatus("PlayerHungerBar") then
		PlayerHungerBar_ShowOrHide(false);
	end
end

-- 屏蔽飞行按钮
function checkCanOpenFlyBtn_Minicode()
	if not MCodeMgr:getMainPlayUIStatus("PlayMainFrameFly") then
		getglobal("PlayMainFrameFly"):Hide();
	end
end

-- 屏蔽潜行按钮
function checkCanOpenSneakBtn_MiniCode()
	if not MCodeMgr:getMainPlayUIStatus("PlayMainFrameSneak") then
		getglobal("PlayMainFrameSneak"):Hide();
	end
end

-- 屏蔽摇杆按钮
function checkCanOpenRocket_MiniCode()
	-- if ClientCurGame and ClientCurGame.showOperateUI then
	-- 	if not MCodeMgr:getMainPlayUIStatus("Rocket") then
	-- 		ClientCurGame:showOperateUI(false);
	-- 	end
	-- end
end

-- 经验条
function checkCanOpenPlayerExp_MiniCode()
	if not MCodeMgr:getMainPlayUIStatus("PlayerExpBar") then
		LevelExpBar_ShowOrHide(false)
	end
end

function resetLevelRules_MiniCode()
	print(">>>> resetLevelRules_MiniCode start");
	MCodeMgr:setMouseFilter(false) 
	MCodeMgr:setMouseFilter(false,0) 
	MCodeMgr:allowFlying(true)
	getglobal("ChatContentFrame"):Show();
	getglobal("PlayShortcut"):Show();
	getglobal("PlayMainFrameBackpack"):Show()
	MCodeMgr:setRule(-3,true)
	MiniCode_backPackVisible = true
	print(">>>> resetLevelRules_MiniCode end");
end

function showUISwitch_MiniCode()
	MiniCode_ShowOrHideUI = true;

	for i=1, #(t_UIName) do
		local frame = getglobal(t_UIName[i]);
		frame:Show();
	end
	getglobal("GameSetFrame"):Hide();
	getglobal("UIHideFrame"):Hide();
	if CurMainPlayer then
		CurMainPlayer:setUIHide(false);
		if CUR_WORLD_MAPID == 1 then
			if not getglobal("InstanceTaskFrame"):IsShown() then
				getglobal("InstanceTaskFrame"):Show();
			end
		end
	
		UnhideAllUI();
	end

	MiniCode_isShowNoticeBoard = true;
	MiniCode:setVisible_noticeboard(true)
end

function hideUISwitch_Minicode()
	MiniCode_ShowOrHideUI = false;
	ClientMgr:setGameData("hideui", 1);
	getglobal("GameSetFrame"):Hide();
	HideAllUI();

	MiniCode_isShowNoticeBoard = false;
	MiniCode:setVisible_noticeboard(false)
end

-- lite的全屏ui的显示/隐藏事件触发，覆盖了大部分的全屏UI或者占屏大的UI
-- status 0表隐藏事件 1表显示事件
function minicodeFullScreenUIEvent(status)
	if not isEducationalVersion then
		return;
	end

	print("minicodeFullScreenUIEvent, status=", status);
	if status == 1 then
		HideWebView_Edu(true);
	else
		ShowWebView_Edu(true);
	end

	local tParam = {0, "lite_fullscreenUI_event", status}
	MCodeMgr:miniCodeCallBack(-1001, JSON:encode(tParam));

	local jsonStr = JSON:encode({event="ShowOrHideEme", content=JSON:encode({visible=status})});
	MCodeMgr:doAction(-1, JSON:encode({"edu_miniui_jsbNativeCall", -1, jsonStr}), 1);
	-- local jsonStr = JSON:encode({event="ShowOrHideEme", content=JSON:encode({visible=status})});
	-- MCodeMgr:doAction(-1, JSON:encode({"edu_miniui_jsbNativeCall", -1, ""}), 1);
end

-- 切换显示/隐藏飞行按钮
function ShowOrHideFly(visible)
	if not ClientMgr:isMobile() then
		return;
	end
	local flyBtn = getglobal("PlayMainFrameFly");
	local sneakBtn = getglobal("PlayMainFrameSneak")
	if true == visible then
		flyBtn:Show(); -- 飞行按钮
		sneakBtn:Hide(); -- 潜行
	else
		if(flyBtn:IsShown()) then
			flyBtn:Hide();
			sneakBtn:Show();
		end
	end
end


--- avatar  --
g_AvatarRes = {}
g_AvatarQueue = {}
function downloadOnceAvatarRes_MiniCode(url, avatarId, checkMD5, callback)

	local function removeItem(code)
		-- 1、先向后遍历保存回调顺序与请求顺序一致
		for i = 1, #g_AvatarQueue do
			if g_AvatarQueue[i].url == url and g_AvatarQueue[i].avatarId == avatarId then
				if g_AvatarQueue[i].callback then
					g_AvatarQueue[i].callback(code, {
						url = url,
						avatarId = avatarId,
						checkMD5 = checkMD5,
					})
				end
			end
		end

		-- 2、再向前遍历删除，保障迭代器有效
		for i = #g_AvatarQueue, 1, -1 do
			if g_AvatarQueue[i].url == url and g_AvatarQueue[i].avatarId == avatarId then
				table.remove(g_AvatarQueue, i);
			end
		end
	end

	local function nextItem()
		if #g_AvatarQueue > 0 then
			local item = g_AvatarQueue[1];
			downloadOnceAvatarRes_MiniCode(item.url, item.avatarId, item.checkMD5, item.callback);
		end
	end

	local function addCache(code, url, avatarId, checkMD5)
		if code ~= ErrorCode.OK then
			return ;
		end

		if not g_AvatarRes[url] then
			local cache = {}
			cache.url = url;
			cache.avatarId = avatarId;
			cache.checkMD5 = checkMD5;
			g_AvatarRes[url] = cache;
		end
	end

	local function downloadFinish(code)
		addCache(code, url, avatarId, checkMD5);
		removeItem(code);
		nextItem();
	end


	local errorCode = ErrorCode.OK
	if avatarId < 5 then
		downloadFinish(ErrorCode.OK)
		return ;
	end

	-- 查找缓存(从内存中)
	if g_AvatarRes[url] then
		downloadFinish(ErrorCode.OK);
		return ;
	end

	-- 查找缓存(从磁盘文件中)
	local filePath = string.format("data/http/productions/1000_%d.zip", avatarId);
	if gFunc_isStdioFileExist(filePath) then
		local localMd5 = gFunc_getSmallFileMd5(filePath)
		local serverMd5 = checkMD5
		if serverMd5 == '' then
			serverMd5 = localMd5;
		end

		if localMd5 ~= serverMd5 then 
			--服务器与本地的MD5值不一致，说明资源内容有变动，下载服务器资源
			ns_http.func.downloadFile(url, filePath, checkMD5, function(userdata, code)
				downloadFinish(ErrorCode.OK);
			end)
		else
			--资源内容无变动
			downloadFinish(ErrorCode.OK);
		end 

		return ;
	else
		-- 本地不存在资源，第一次下载
		ns_http.func.downloadFile(url, filePath, checkMD5, function(userdata, code)
			downloadFinish(code);
		end)
	end 

end

-- 提供给lua使用，callback目标为lua 函数
function downloadAvatarResLua_MiniCode(url, avatarId, checkMD5, callback)
	table.insert(g_AvatarQueue, {
		url = url,
		avatarId = avatarId,
		checkMD5 = checkMD5,
		callback = callback,
	})

	-- 当前没有是第一个任务，不需要排队；
	if #g_AvatarQueue == 1 then
		downloadOnceAvatarRes_MiniCode(url, avatarId, checkMD5, callback)
	end
end

-- 提供给c++ 使用
function downloadAvatarResCpp_MiniCode(seq, avatarId, url, checkMD5)
	local function callback(code, item)
		MCodeMgr:downloadAvatarFinish(code, seq, avatarId, url, checkMD5);
	end

	table.insert(g_AvatarQueue, {
		url = url,
		avatarId = avatarId,
		checkMD5 = checkMD5,
		callback = callback,
		seq = seq,
	})

	-- 当前没有是第一个任务，不需要排队；
	if #g_AvatarQueue == 1 then
		downloadOnceAvatarRes_MiniCode(url, avatarId, checkMD5, callback)
	end
end

-- c++ 触发lua 准备加载avatar
function ClientGetRoleAvatarInfo_MiniCode(uin)
	print(">>>> ClientGetRoleAvatarInfo_MiniCode", uin)
	threadpool:work(function()
		--地图可能还在加载中 状态还没全部刷新到  wait一下刷新了再处理
		if not ClientCurGame then
			return;
		end
		local count = 0
		while(not ClientCurGame:isInGame())
		do
			count = count + 1
			threadpool:wait(1)
			if count >= 10 then
				return
			end
		end

		player = ClientCurGame:getPlayerByUin(uin);
		if player == nil then
			return ;
		end
		player:changePlayerModel(257, 0, "");

		-- local uins = {}
		-- table.insert(uins, uin);
		-- local ok, json = pcall(JSON.encode, JSON, uins);
		-- if not ok then
		-- 	return 
		-- end
		-- MCodeMgr:getUserAvatarUsing(json);
	end)
end

function ClientGetRoleAvatarInfoCallback_MiniCode(param)

	local ok, json_data = pcall(JSON.decode, JSON, param)
	print('>>>> ClientGetRoleAvatarInfoCallback_MiniCode',  json_data)

	if ok and type(json_data) == 'table' then
		if json_data.code ~= 0 then
			return ;
		end

		if not json_data.data then
			return ;
		end

		if not json_data.data.list then
			return ;
		end

		local players = json_data.data.list

		for _, player in ipairs(players) do
			setPlayerAvatar_MiniCode(player.uin, player)
		end
	end

end

function setPlayerAvatar_MiniCode(uin, avatarData)
	if avatarData.list and #avatarData.list > 0 then
		player = ClientCurGame:getPlayerByUin(uin);
		if player == nil then
			return ;
		end

		-- 第一个就是正在使用的avatar信息
		local usingAvatar = avatarData.list[1]
		local avatars = usingAvatar.list

		player:changePlayerModel(2, 0, "1");
		for _, avatar in ipairs(avatars) do
			downloadAvatarResLua_MiniCode(avatar.resUrl, avatar.modelId, avatar.resMd5, function ()
				AddAvatarPart_MiniCode(uin, avatar.modelId, avatar.positionId)
			end)
		end
	end
end

-- 装备玩家一个avatar
function AddAvatarPart_MiniCode(uin, modelID, partID)
	print(">>>> AddAvatarPart_MiniCode", uin, modelID)
	if uin and modelID then
		local palyer = nil
		if CurMainPlayer ~= nil and CurMainPlayer:getUin() == uin then
			player = CurMainPlayer;
		else	
			if ClientCurGame:isInGame() == false then
				return
			end

			player = ClientCurGame:getPlayerByUin(uin);
			if player == nil then
				return;
			end
		end

		
		if partID then
			if partID == 2 then
				if player:getBody() ~= nil then
					player:getBody():setBodyType(3);
				    player:getBody():exchangePartFace(modelID, partID, true);
				end

				if player:getUIViewBody() ~= nil then
					player:getUIViewBody():setBodyType(3);
				    player:getUIViewBody():exchangePartFace(modelID, partID, true);
				end
			else
				if player:getBody() ~= nil then
					player:getBody():setBodyType(3);
				    player:getBody():addAvatarPartModel(modelID,partID);

				--    if seatSkinDef.skin[partID].skin.Data and seatSkinDef.skin[partID].skin.Data.DyeInfo and next(seatSkinDef.skin[partID].skin.Data.DyeInfo) then
				-- 		local dyeInfo = seatSkinDef.skin[partID].skin.Data.DyeInfo;
				-- 		for k, v in pairs(dyeInfo) do
				-- 			if #v == 4 then
				-- 				player:getBody():alterAvatarPartColor(v[2], v[3], v[4], partID, modelID, v[1]);
				-- 			end
				-- 		end
				-- 	end

				-- 	if seatSkinDef.skin[partID].cfg.ShieldID and #seatSkinDef.skin[partID].cfg.ShieldID > 0 then
				-- 		local shieldID = loadstring("return " .. seatSkinDef.skin[partID].cfg.ShieldID)();
				-- 		for i = 1, #shieldID do
				-- 			if shieldID[i] and type(shieldID[i]) == "number" and shieldID[i] > 0 and shieldID[i] <= 10 then
				-- 				player:getBody():hideAvatarPartModel(shieldID[i]);
				-- 			end
				-- 		end
				-- 	end
				end

				if player:getUIViewBody() ~= nil then
					player:getUIViewBody():setBodyType(3);
					player:getUIViewBody():addAvatarPartModel(modelID,partID);

				-- 	if seatSkinDef.skin[partID].skin.Data and seatSkinDef.skin[partID].skin.Data.DyeInfo and next(seatSkinDef.skin[partID].skin.Data.DyeInfo) then
				-- 		local dyeInfo = seatSkinDef.skin[partID].skin.Data.DyeInfo;
				-- 		for k, v in pairs(dyeInfo) do
				-- 			if #v == 4 then
				-- 				player:getUIViewBody():alterAvatarPartColor(v[2], v[3], v[4], partID, modelID, v[1]);
				-- 			end
				-- 		end
				-- 	end

				-- 	if seatSkinDef.skin[partID].cfg.ShieldID and #seatSkinDef.skin[partID].cfg.ShieldID > 0 then
				-- 		local shieldID = loadstring("return " .. seatSkinDef.skin[partID].cfg.ShieldID)();
				-- 		for i = 1, #shieldID do
				-- 			if shieldID[i] and type(shieldID[i]) == "number" and shieldID[i] > 0 and shieldID[i] <= 10 then
				-- 				player:getUIViewBody():hideAvatarPartModel(shieldID[i]);
				-- 			end
				-- 		end
				-- 	end
				end
			end
		end
	end
end

function loadFinish_MiniCode()
	local root = GetInst("MiniUISceneMgr"):getCurrentSceneRootNode()
    if not root then
        GetInst("MiniUISceneMgr"):loadScene("MiniUICommonScene")
    end
end

-- 获取坐标选择器选择地块后需要eme显示的方块名字（和迷你世界的定义不太相同）
function getCppPosSelectedBlockName(id)
	local tDefTab = {
		{
			minId = 600,
			maxId = 615,
			name = "彩色棉花"
		},
		{
			minId = 616,
			maxId = 631,
			name = "彩色地毡"
		},
		{
			minId = 632,
			maxId = 665,
			name = "彩色玻璃"
		},
		{
			minId = 666,
			maxId = 682,
			name = "彩色硬砂块"
		},
		{
			minId = 1120,
			maxId = 1135,
			name = "彩色旧铁块"
		},
	};

	for i = 1, #tDefTab do
		local tSubTab = tDefTab[i];
		if id >= tSubTab.minId and id <= tSubTab.maxId then
			return tSubTab.name;
		end
	end

	return "";
end