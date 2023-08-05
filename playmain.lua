
MAX_SHORTCUT = 8
ShortCut_SelectedIndex = -1
CurPlayerExpVal = 0;
ShowBallOperateTipsTime = 0;
local math = _G.math
local PlayMain = {
};
_G.PlayMain = PlayMain;

--[==[
	切换渲染
	Created on 2021-05-10 at 17:17:58
]==]
function PlayMain:onToggleRenderInfo(enable)
	-- if not self.HP then
	-- 	return
	-- end
	-- if not self.HP.ui then
	-- 	return
	-- end
	-- if enable then
	-- 	self.HP.ui:SetPoint("topleft", "PlayMainFrame", "topleft", 20, 150);
	-- else
	-- 	self.HP.ui:SetPoint("topleft", "PlayMainFrame", "topleft", 20, 4);
	-- end
end

local BattleCoundBlinkingTime = 0;
local BossHpShown = 0;
local GVoiceSpeechUsageBeginTime = 0;--计算GVoice语音使用时长，53001打点上报使用
local GetMuteFlag = 0;    --获取禁言数据标识
-- 组合变形cd
local lastTimeCombineTransform = 0
local checkingSleepingPlayers = true  --是否需要检查正在睡觉的玩家

local GVoiceJoinRoomBtnShown = false --是否已经显示了加入语音房按钮

local MobileTipsShowed = false	--当次地图是否已经检查过流量包状态
--装扮召唤召唤物序号
local AvatarSummonIndex = 0

local coloredGunAndEgeSelectedColor = -1

----------------------------------------------------UIHideFrame---------------------------------------------------
t_UIName = { "PlayMainFrame", "GongNengFrame"}

function Playmain_ShowFlyBtn()
	print("Playmain_ShowFlyBtn:");
	local flybtn = getglobal("PlayMainFrameFly");
	-- local upbtn = getglobal("PlayMainFrameFlyUp");

	flybtn:Show();
	flybtn:SetPoint("top", "PlayMainFrameFlyUp", "bottom", 0, 0);
end

function UIHideFrame_OnLoad()
	-- this:setUpdateTime(0.05);
end

function UIHideFrame_OnShow()
	-- getglobal("UIHideFrameTex"):SetBlendAlpha(1);
	if SdkManager:isShareEnabled() then  														-- and not IsOverseasVer()
		getglobal("UIHideFrameScreenshotBtn"):Show();
	else
		getglobal("UIHideFrameScreenshotBtn"):Hide();
	end
	if ClientMgr:isPC() then
		local state = ClientMgr:getGameData("hideui");
		if state == 0 then
			getglobal("UIHideFrameScreenshotBtn"):Hide();
			getglobal("UIHideFrameExitBtn"):Hide();
		elseif state == 1 then
			getglobal("UIHideFrameExitBtn"):Show()
		end
	end
end

function UIHideFrame_OnClick()
	-- if getglobal("UIHideFrameTex"):GetBlendAlpha() <= 0.1 then
	-- 	getglobal("UIHideFrameTex"):SetBlendAlpha(1);
	-- else
		-- for i=1, #(t_UIName) do
		-- 	local frame = getglobal(t_UIName[i]);
		-- 	frame:Show();
		-- end
		-- getglobal("UIHideFrame"):Hide();
		-- CurMainPlayer:setUIHide(false);
		-- if CUR_WORLD_MAPID > 0 then
		-- 	if not getglobal("InstanceTaskFrame"):IsShown() then
		-- 		getglobal("InstanceTaskFrame"):Show();
		-- 	end
		-- end
		-- ClientMgr:setGameData("hideui", 0);
		-- ClientMgr:appalyGameSetData();
	-- end
end

function UIHideFrame_OnUpdate()
	-- local UIHideFrameTex = getglobal("UIHideFrameTex")
	-- if UIHideFrameTex:GetBlendAlpha() > 0.1 then
	-- 	local alpha = UIHideFrameTex:GetBlendAlpha() - 0.05;
	-- 	if alpha < 0.1 then
	-- 		alpha = 0.1;
	-- 	end
	-- --	UIHideFrameTex:SetBlendAlpha(alpha);
	-- 	local cVal = alpha*255;
	-- 	UIHideFrameTex:SetColor(cVal, cVal, cVal, cVal);
	-- end
end

function UnhideAllUI()
	ClientMgr:setGameData("hideui", 0);
	ClientMgrAppalyGameSetData()


	for i=1, #(t_UIName) do
		local frame = getglobal(t_UIName[i]);
		frame:Show();
		
	end
	getglobal("UIHideFrame"):Hide();
	CurMainPlayer:setUIHide(false);

	if CUR_WORLD_MAPID == 1 then
		if not getglobal("InstanceTaskFrame"):IsShown() then
			getglobal("InstanceTaskFrame"):Show();
		end
	end

	if CUR_WORLD_MAPID > 0 then
		if BossHpShown == 1 and (not getglobal("BossHpFrame"):IsShown()) then
			getglobal("BossHpFrame"):Show();
			BossHpShown = 0;
		end
	end

	if IsInHomeLandMap and IsInHomeLandMap() then
		ShowHomeMainUI()
		getglobal("GongNengFrame"):Hide()
		HomeLandGuideTaskCall("ShowUi", true)
	end

	GetInst("MiniUIManager"):ShowUI("OnlineFriendAutoGen")
end

function UIHideFrameExitBtn_OnClick()
	if IsUGCEditingHighMode() then
		--截图中，先不响应
		if GetInst("MiniUIManager"):IsShown("SceneShotFrameAutoGen") then
			return;
		end
		AccelKey_HideUIToggle()
		return
	end
	
	UnhideAllUI();
	
	if UIEditorDef then
		UIEditorDef:UIHideModelQuite()
	end
end

local function checkUpdateWaterCannonGunModelTexture(currentCount)
	local maxNum = LuaConstants:get().oxygen_pack_full_bullet_num
	local percent = math.ceil(currentCount/maxNum*100)
	local texureid = 1
	if percent <= 0 then
		texureid = 1
	elseif percent <= 25 then
		texureid = 2
	elseif percent <= 60 then
		texureid = 3
	else
		texureid = 4
	end
	CurMainPlayer:updateToolModelTexture(texureid)
end

function SetGunMagazine(currentCount, maxCount, isColorGunInhale)
	-- if UGCModeMgr and UGCModeMgr:IsEditing() then
	-- 	GetInst("SceneEditorMsgHandler"):dispatcher(SceneEditorUIDef.common.set_gun_magazine, {currentCount = currentCount, maxCount = maxCount})
	-- 	return
	-- end

	if currentCount == -1 then
		getglobal("GunMagazine"):Hide()
        getglobal("ColoreSelectedFrame"):Hide()
		getglobal("SetSightingTelescopeBtn"):Hide()
	else
        local tips = getglobal("GunMagazineTips")
        local background = getglobal("GunMagazineBackground")

		local toolId = CurMainPlayer:getCurToolID()
		local coloredGunOrEgg = (toolId == ITEM_COLORED_GUN or toolId == ITEM_COLORED_EGG or toolId == ITEM_COLORED_EGG_SMALL)
        if coloredGunOrEgg or IsDyeableBlockLua(toolId) then
			local selection = getglobal("ColoreSelected")

            if CurMainPlayer:getSelectedColor() == -1 then
                tips:SetTextColor(255,255,255)
                selection:SetColor(255,255,255)
                selection:SetTexUV("icon_colour_c.png")
            else
				local curSelectedColor = CurMainPlayer:getSelectedColor()
				-- 编辑、创造模式下，散弹枪独立颜色设置逻辑才生效
				local isValidMode = CurWorld and (CurWorld:isGameMakerMode() or CurWorld:isCreativeMode())

				-- 吸色功能，需要更新彩弹枪，彩蛋缓存颜色
				if isColorGunInhale then
					coloredGunAndEgeSelectedColor = curSelectedColor
				end

				if not isColorGunInhale and coloredGunOrEgg and isValidMode then
					-- 彩弹枪，彩蛋没设置过颜色，初始状态
					if coloredGunAndEgeSelectedColor == -1  then
						tips:SetTextColor(255,255,255)
						selection:SetColor(255,255,255)
						selection:SetTexUV("icon_colour_c.png")
						CurMainPlayer:setSelectedColor(-1)
					-- 设置过颜色，直接设置颜色
					else
						-- 更新玩家颜色
						CurMainPlayer:setSelectedColor(coloredGunAndEgeSelectedColor)
						curSelectedColor = coloredGunAndEgeSelectedColor

						local r,g,b
						b =  curSelectedColor% 256
						g = ((curSelectedColor)/256) % 256
						r = ((curSelectedColor)/(256*256)) % 256
		
						tips:SetTextColor(r,g,b)
						selection:SetColor(r,g,b)
						selection:SetTexUV("icon_colour.png")
					end
				-- 不是彩弹枪、彩蛋或者不是编辑、创造模式 直接设置颜色
				else
					local r,g,b
					b =  curSelectedColor% 256
					g = ((curSelectedColor)/256) % 256
					r = ((curSelectedColor)/(256*256)) % 256
	
					tips:SetTextColor(r,g,b)
					selection:SetColor(r,g,b)
					selection:SetTexUV("icon_colour.png")
				end
            end

            getglobal("ColoreSelectedFrame"):Show()
		    background:SetTexUV("icon_colour.png")
            tips:SetText(GetS(6034))
        else
            getglobal("ColoreSelectedFrame"):Hide()
		    background:SetTexUV("icon_bullet.png")
            tips:SetTextColor(255,255,255)
		    tips:SetText(currentCount.."/"..maxCount)
        end

        if CurMainPlayer:getCurToolID() == ITEM_WATER_CANNON then
        	checkUpdateWaterCannonGunModelTexture(currentCount)
        end
		getglobal("GunMagazine"):Show()
	end

end

function SetColoredGunOrEggSelectedColor(color)
	-- 只在编辑和创造模式有效果
	if CurWorld and not CurWorld:isGameMakerMode() and not CurWorld:isCreativeMode() then
		return
	end

	if not CurMainPlayer then
		coloredGunAndEgeSelectedColor = -1
		return
	end

	local toolId = CurMainPlayer:getCurToolID()
	if toolId == ITEM_COLORED_GUN or toolId == ITEM_COLORED_EGG or toolId == ITEM_COLORED_EGG_SMALL then
		coloredGunAndEgeSelectedColor = color
	end
end

function GetColoredGunOrEggSelectedColor()
	-- 只在编辑和创造模式有效果
	if CurWorld and not CurWorld:isGameMakerMode() and not CurWorld:isCreativeMode() then
		return -1
	end

	local toolId = CurMainPlayer:getCurToolID()
	if toolId == ITEM_COLORED_GUN or toolId == ITEM_COLORED_EGG or toolId == ITEM_COLORED_EGG_SMALL then
		return coloredGunAndEgeSelectedColor
	else
		return -1
	end
end

--PC模式下鼠标滑轮滚动
function SprayPaintChange(isNext)
	--打开喷漆选择界面，道具栏不变动
	if not GetInst('MiniUIManager'):IsShown("GameSprayPaintAutoGen") then
		local index = ShortCut_SelectedIndex
		local step = isNext and -1 or 1
		index = index + step
		if index < 0 then
			index = MAX_SHORTCUT - 1
		end
		if index > MAX_SHORTCUT then
			index = 1
		end
		if CurMainPlayer ~= nil then
			CurMainPlayer:onSetCurShortcut(index)
			ShortCutFrame_Selected(index);
		end
	end
end

-- 更新喷漆道具
function UpdatePaintChangeBtn()
	if CurMainPlayer:getCurToolID() == ITEM_PAINTTANK then
        local tips = getglobal("PaintChangeFrameTips")
        local background = getglobal("PaintChangeFrameBackground")
		local icon = getglobal("PaintChangeFrameIcon")

        tips:SetTextColor(255,255,255)

		tips:SetText(GetS(30612))
    
		background:SetTexUV("icon_colour.png")

		local spray_id = getglobal("PaintChangeFrame"):GetClientUserData(0)
		if spray_id and spray_id > 0 then
			local curPaintItem
			local data = GetInst("ShopPaintDataManager"):GetOwnedShopSprayPaintTbl()
			for k,v in pairs(data) do
				if v.spray_id == spray_id then
					curPaintItem = v
					break
				end
			end
			if SprayPaintMgr and CurMainPlayer and curPaintItem then
				SprayPaintMgr:setSprayPaintId(CurMainPlayer:getUin(), curPaintItem.spray_id)
				SetItemIcon(icon, curPaintItem.item_id)
				icon:Show()
			else
				icon:Hide()
			end
		else
			icon:Hide()
		end

		getglobal("PaintChangeFrame"):Show()
	else
		getglobal("PaintChangeFrame"):Hide()
	end
end

function UIHideFrameScreenshotBtn_OnClick()
	local id = CurWorld:getOWID();
	--StartShareOnScreenshot('map', id);
	--getglobal("UIHideFrame"):Hide();
	--StartNewMapScreenshotShare(id)
end

----------------------------------------------------SurvivalGameNovice------------------------------------------------
--新手引导游戏内遮罩层点击事件处理
function SurvivalGameNovice_OnClick()
	if not NoviceClickSwitch then return end

	if not AccountManager:getNoviceGuideState("welcome") then
		getglobal("GuideTipsFrame"):Hide();
		AccountManager:setNoviceGuideState("welcome", true);
		AccountManager:setCurNoviceGuideTask(2);
		ShowCurNoviceGuideTask();
		this:Hide();
	end

end
-------------------------------------------------ExtremityTipsFrame------------------------------
function ExtremityTipsFrame_OnShow()
	HideAllFrame("ExtremityTipsFrame", false);
	local descRich = getglobal("ExtremityTipsFrameDesc");
	if (CurWorld:getCurMapID() == 2)  then  --太空世界系统弹框设置
		descRich:SetText(GetS(20207), 216, 187, 142);
		getglobal("ExtremityTipsFrameTitle"):SetText(GetS(20206));
		getglobal("ExtremityTipsFrameFightIcon"):SetTexUV("xtc_icon06");
		getglobal("ExtremityTipsFrameNotice"):Hide()
	else
		getglobal("ExtremityTipsFrameFightIcon"):SetTexUV("xtc_icon01");
		getglobal("ExtremityTipsFrameTitle"):SetText(GetS(3180));
		getglobal("ExtremityTipsFrameNotice"):Hide()
	--	descRich:SetPoint("TOPLEFT", "ExtremityTipsFrameBkg", "TOPLEFT", 174, 58);
		descRich:SetText(GetS(3182), 216, 187, 142);
	end

	if not getglobal("ExtremityTipsFrame"):IsReshow() and ClientCurGame.setOperateUI then
		ClientCurGame:setOperateUI(true);
	end
	if IsUGCEditing() then
		GetInst("MiniUIManager"):ShowUI("SceneEditorMainframeAutoGen");
	end
end

function ExtremityTipsFrame_OnHide()
--	HideAllFrame("ExtremityTipsFrame", false);

	if not getglobal("ExtremityTipsFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
end

function ExtremityTipsFrame_OnClick()
	getglobal("ExtremityTipsFrame"):Hide();
end

function newTotemMsgbox(x, y, z, mapid)
	local totempos = {x = x, y= y, z =z, mapid=mapid};
	MessageBox(5, GetS(9002), function(btn, totempos)
		if btn == 'left' then
			WorldMgr:addTotemPoint(totempos.x, totempos.y, totempos.z, totempos.mapid);
		end
	end, totempos);
end
----------------------------------------------------PlayMainFrame-----------------------------------------------------
t_allFrame =  {
		"CreateBackpackFrame",
		"AdventureNoteFrame",
		"StorageBoxFrame",
		"FurnaceOxyFrame",
		"RepairFrame",
		"CraftingTableFrame",
		"AchievementFrame",
		"DeathFrame",
		"BuffFrame",
		"EnchantFrame",
		"IntroduceFrame",
		"MonumentFrame",
		"MapFrame",
		"NpcTradeFrame",
		"StarConvertFrame",
		"ExtremityTipsFrame",
		"ArchiveGradeFrame",
		"RideFrame",
		"BattleDeathFrame",
		"BattleFrame",
		"BattleEndShadeFrame",
		"BattleEndFrame",
		"AccRideCallFrame",
		"FeedBackFrame",
		"DevTools",
		"RoleAttrFrame",
		"RoomUIFrame",
		"FriendUIFrame",
		"GameSetFrame",
		"ActivityFrame",
		"AdvertFrame",
		"MarketActivityFrame",
		"FeedBackFrame",
		"MessageBoxFrame",
		"KeyDescriptionFrame",
		"StarConvertFrame",
		"OutGameConfirmFrame",
		"ScreenEffectFrame",
		"InstructionParserFrame",
		"SignalParserFrame",
		"NpcDialogueFrame",
		"BlueprintFrame",
		"ActionLibraryFrame",
		"CharacterActionFrame",
		"MeasureDistanceFrame",
		"NpcTaskFrame",
		"DeveloperStoreSkuFrame",
		"DeveloperStoreBuyItemFrame",
		"DeveloperStoreMapPurchaseFrame",
		"BluePrintDrawingFrame",
		"CustomModelFrame",
		"MapModelLibFrame", --ResourceCenterNewVersionSwitch
		"CreateMonsterFrame",
		"ChooseOrganismFrame",
		"TransferFrame",
		"ChooseTransferDestinationFrame",
		"GameSignEditFrame",
		"NpcShopFrame",
		"VehicleEditFrame",
		"ActorEditSelectModelFrame",
		"ActorEditFrame",
		"GiftPackFrame",
		"VehicleActioner",
		"FullyCustomModelSelect",
		"FullyCustomModelEditor",
		"scriptprint",
		"ToolModeFrame",
		"MapEdit",
		"DeveloperRuntimeInfo",
		"PackingCM",
		"PackingCMAjust",
		"PackingCMCreate",
		"ResourceCenter",
		"ResourceCenterMoveFile",
		"ResourceCenterSelectFolder",
		"ResourceCenterAddFolder",
		"ResourceShopPluginSelect",
		"ResourceShopKindSelect",
		"ResourceShop",
		"HomeMain",
		"AltarAwardsEdit",
		--"TopPurchaseInMap",
		-- "TriggerAdInMap",
		"Pot",
		"Craft",
		"Furnace",
		"CraftSelectMenu",
		"Inlay",
		"Merge",
		"Ldentify",
		"HolographicMainmenu",
		"HolographicCartoon",
        "HolographicFullScreen",
        "SleepNoticeFrame",
		"MItemTipsFrame",
		"ShopAdNpc",
		"NewSleepNoticeFrame",
	}

local t_DeathFrames = {
			"DeathFrame", "BattleDeathFrame",
			}

local t_DeathFrames_miniui = {
			"ExtremityDeathFrameAutoGen",
	}


--检查一下 是否可以隐藏该Frame
function checkCanHideFrame(frameName)
	if frameName ~= "MessageBoxFrame" then
		return true
	end

	--返回true 就是允许登录，false 就是不允许登录
	if AccountManager.is_policy_limit_login then
		return AccountManager:is_policy_limit_login()
	end

	return true
end

function HideAllFrame(frameName, isHideMain, isIgnoreMiniUI)
	local isDead = false;
	local isDeadFrame = false;
	for i=1, #(t_DeathFrames) do
		local deathFrame = getglobal(t_DeathFrames[i], true); --在这个接口里，没加载的UI不需要去加载
		if not isDead and deathFrame and deathFrame:IsShown() then
			isDead = true;
		end

		if not isDeadFrame and frameName == t_DeathFrames[i] then
			isDeadFrame = true;
		end
	end

	-- 判断 miniui 中新做的死亡界面
	if not isDead then
		for i=1, #(t_DeathFrames_miniui) do
			local autogen = GetInst('MiniUIManager'):GetUI(t_DeathFrames_miniui[i]);
			if autogen then
				isDead = true;
			end

			if not isDeadFrame and frameName == t_DeathFrames_miniui[i] then
				isDeadFrame = true;
			end
		end
	end

	if isDead then
		if not isDeadFrame and frameName ~= nil then
			getglobal(frameName):Hide();
			return;
		end
		--[[
		if getglobal("SetMenuFrame"):IsShown() then
			getglobal("SetMenuFrame"):Hide();
			ClientCurGame:setInSetting(false);
		else

			getglobal("SetMenuFrame"):Show();
			ClientCurGame:setInSetting(true);
		end
		]]
	end

	local needHide = function(hideFrameName)
		local ignoreCfg = {
			["AccRideCallFrame"] = {"ToolModeFrame",};	--打开坐骑页面的时候不用隐藏'工具模式'页面
		};

		local list = ignoreCfg[frameName];
		if list then
			for i = 1, #list do
				if hideFrameName == list[i] then
					--忽略, 不用隐藏
					return false;
				end
			end
		end

		return true;
	end

	for i=1, #(t_allFrame) do
		if t_allFrame[i] ~= frameName then
			if needHide(t_allFrame[i]) and checkCanHideFrame(t_allFrame[i]) then
				local frame = getglobal(t_allFrame[i], true);	--在这个接口里，没加载的UI不需要去加载
				if frame and frame:IsShown() then
					local mvcFrame = GetInst("UIManager"):GetCtrl(t_allFrame[i]);
					if mvcFrame then
						if mvcFrame.CloseBtnClicked then
							print("kekeke mvc CloseBtnClicked");
							mvcFrame:CloseBtnClicked();
						else
							GetInst("UIManager"):Close(t_allFrame[i]); --更一般的关闭
						end
					else
						frame:Hide();
					end
				end
			end
		end
	end

	if isHideMain then
		getglobal("GongNengFrame"):Hide();
		PlayMainFrameUIHide();
		--ClientCurGame:showOperateUI(false);
	end
	HomeLandGuideTaskCall("ShowUi", false)
	
	if not isIgnoreMiniUI then
		GetInst("UGCCommon"):OnHideAllUI()
		-- 新UI code_by: huangfubin
		if gFunc_IsNewMiniUIEnable and gFunc_IsNewMiniUIEnable() then
			GetInst("MiniUIManager"):HideAllUI()
		end
	end

	if ClientCurGame and ClientCurGame:isInGame() and GetInst("QQMusicPlayerManager") then
		-- 重新显示出来
		if GetInst("QQMusicPlayerManager"):IsMusicPlayerOpened() then
			GetInst("QQMusicPlayerManager"):OpenUI()
		end
	end 
	
	if ClientCurGame and ClientCurGame:isInGame() and GetInst("MiniClubPlayerManager") then
		-- 重新显示出来
		if GetInst("MiniClubPlayerManager"):IsOpen() then
			GetInst("MiniClubPlayerManager"):OpenUI()
		end
	end

	if not isHideMain and ClientCurGame and ClientCurGame:isInGame() then
		-- 重新显示出来
		if IsInHomeLandMap and IsInHomeLandMap() then
		else
			PixelMapInterface:ShowCompass();
		end
	end

	if ClientCurGame and ClientCurGame:isInGame() and CurWorld then
		-- 重新显示出来
		if GetInst("AnniActInterface") then
			GetInst("AnniActInterface"):RefreshMatchingMapUI(CurWorld:getOWID())
		end
		if GetInst("IceSheetActInterface") then
			GetInst("IceSheetActInterface"):OpenActMatchView(CurWorld:getOWID())
		end
	end
end

function ShowMainFrame()
	if ClientMgr:getGameData("hideui") == 1 then return end

	if IsInHomeLandMap and IsInHomeLandMap() then
		ShowHomeMainUI()
		getglobal("GongNengFrame"):Hide();
	else
		getglobal("GongNengFrame"):Show();
	end

	-- UGC内容重新显示
	GetInst("UGCCommon"):AfterHideAllUI();
	PlayMainFrameUIShow();
	GetInst("UGCCommon"):RefreshEditUI()
end

function HideAllUI(isHideHideFrame)
	for i=1, #(t_UIName) do
		local frame = getglobal(t_UIName[i]);
		if frame and frame:IsShown() then
			frame:Hide();
		end
	end
	
	local mvcFrame = GetInst("UIManager"):GetCtrl("StarStationInfo");
	if mvcFrame then
		GetInst("UIManager"):Close("StarStationInfo")
	end
	for i=1, #(t_allFrame) do
		local frame = getglobal(t_allFrame[i]);
		if frame and frame:IsShown() and checkCanHideFrame(t_allFrame[i]) then
			local mvcFrame = GetInst("UIManager"):GetCtrl(t_allFrame[i]);
			if mvcFrame then
				if mvcFrame.CloseBtnClicked then
					print("kekeke mvc CloseBtnClicked");
					mvcFrame:CloseBtnClicked();
				else
					GetInst("UIManager"):Close(t_allFrame[i]); --更一般的关闭
				end
			else
				frame:Hide();
			end
			
			-- frame:Hide();
		end
	end

	if CUR_WORLD_MAPID > 0 then
		if IsUIFrameShown("InstanceTaskFrame") then
			getglobal("InstanceTaskFrame"):Hide();
		end

		if IsUIFrameShown("BossHpFrame") then
			getglobal("BossHpFrame"):Hide();
			BossHpShown = 1;
		end

		if IsUIFrameShown("PlotFrame") then
			getglobal("PlotFrame"):Hide();
		end
	end
	--ios 里面调用这个函数会崩溃
	--if not IsIosPlatform() then
	CurMainPlayer:setUIHide(true);
	--end
	if getglobal("UIHideFrame") then 
		if not isHideHideFrame then
			getglobal("UIHideFrame"):Show();
		else
			getglobal("UIHideFrame"):Hide();
		end
	end 

	HomeLandGuideTaskCall("ShowUi", false)
	GetInst("MiniUIManager"):HideUI("OnlineFriendAutoGen")
end
-----------------------------------------------------OpenGame----------------------------------------------------------
local NeedOpenMakerRunGame = false;
function OpenGameCloseBtn_OnClick()
	getglobal("OpenGame"):Hide();
	NeedOpenMakerRunGame = false;
end

function OpenGameOkBtnBtn_OnClick()
	ClientCurGame:hostStartGame();
	getglobal("OpenGame"):Hide();
	NeedOpenMakerRunGame = false;
end

function OpenGame_OnLoad()
	this:RegisterEvent("GIE_WAITHOST_STARTGAME")
	this:RegisterEvent("GIE_CLOSE_HOST_STARTGAME")
	this:RegisterEvent("GIE_UPDATE_ACTORINVITE");
end

-- 定时器停止装扮邀请动画
local actorInviteTimer = nil
-- 是否继续显示装扮邀请动画
isPlayingactorInviteAni = false
--装扮互动按钮冷却时间
isActorInviteBtnCoolingTime = false
--互动装扮操作时间
MAX_ACTION_INVITE_TIME = 15

function OpenGame_OnEvent()
	if arg1 == "GIE_WAITHOST_STARTGAME" and IsRoomOwner() then
		NeedOpenMakerRunGame = true;
		getglobal("OpenGame"):Show();
	elseif arg1 == "GIE_CLOSE_HOST_STARTGAME" and IsRoomOwner() then
		NeedOpenMakerRunGame = false;
		getglobal("OpenGame"):Hide();
	elseif arg1 == "GIE_UPDATE_ACTORINVITE" then
		local ge = GameEventQue:getCurEvent();
		local info = {
			targetUin = ge.body.actorInvite.targetuin;
			actId = ge.body.actorInvite.actId;
			inviteType = ge.body.actorInvite.inviteType;
			lastTime = MAX_ACTION_INVITE_TIME + os.time()
		}
		--0:收到邀请 1：邀请接受 2：邀请拒绝 3：邀请超时
		if info.inviteType == 0 then
			local refuseTime = getkv("ActorInviteRefuseTime"..info.targetUin) or nil
			local timeSpace = 3*60 -- 3小时
			local time = getServerTime() - timeSpace*60
			if refuseTime and tonumber(refuseTime) > tonumber(time)then
				return;
			end
			--收到邀请提示
			ShowGameTips(GetS(15292))
			--播放动画
			getglobal("ActorInviteTipBtn"):Show()
			local Ani = getglobal("ActorInviteTipBtnAni")
			if Ani then
				local actInviteDef = getActInviteDefById(info.actId)
				if actInviteDef then
					local imgUrl = "ui/mobile/effect/ui_zbhz_"..actInviteDef.ActID..".png"
					Ani:SetTexture(imgUrl,true)
					Ani:SetUVAnimation(120, true)
				end
			end
			isPlayingactorInviteAni = true
			if actorInviteTimer then
				threadpool:kick(actorInviteTimer)
			end
			-- 一定时间后隐藏
			actorInviteTimer = threadpool:delay(MAX_ACTION_INVITE_TIME, function()
				isPlayingactorInviteAni = false
				getglobal("ActorInviteTipBtn"):Hide()
			end)
			setActorInviteInfo(info)
		elseif info.inviteType == 1 then
			--接受操作
		 	local uin = CurMainPlayer:getUin()
			local targetUin = info.targetUin;
			CurMainPlayer:playSkinAct(info.actId,uin, targetUin)
		elseif info.inviteType == 2 then
			ShowGameTips(GetS(15289))
		elseif info.inviteType == 3 then
			ShowGameTips(GetS(15290))
		end
	elseif arg1 == "GE_WORLD_CHANGE" then
		--存档埋点
		Report418Event(3)
	end
end

function OpenGame_OnHide()
	if not getglobal("OpenGame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
end

function OpenGame_OnShow()
	if not getglobal("OpenGame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end
end

-------------------------------------------------RocketUIFrame---------------------------------------------
local RocketInSpace = false;
function RocketUIFrameChange(isshow, posy)
	if isshow then
		if not getglobal("RocketUIFrame"):IsShown() then
			getglobal("RocketUIFrame"):Show();
		end

		if getglobal("MapFrame"):IsShown() then
			getglobal("RocketUIFrameLeft"):Hide();
		else
			getglobal("RocketUIFrameLeft"):Show();
		end

		if posy >= 25600 then
			posy = 25600;
			if not RocketInSpace then
				RocketInSpace = true;
				getglobal("RocketUIFrameMask"):Show();
				getglobal("RocketUIFrameMask"):SetBlendAlpha(0);
			end
		else
			if RocketInSpace then
				RocketInSpace = false;
			end
			getglobal("RocketUIFrameMask"):Hide();
		end

		local offsetY = math.ceil(posy/25600*190);
		getglobal("RocketUIFrameLeftIcon"):SetPoint("bottom", "RocketUIFrameLeftBkg", "bottom", 0, -3-offsetY);
	else
		getglobal("RocketUIFrame"):Hide();
		--getglobal("CompassBirthplace"):Hide();
		RocketInSpace = false;
	end
end

function RocketUIFrame_OnUpdate()
	if RocketInSpace then
		local alpha = getglobal("RocketUIFrameMask"):GetBlendAlpha() + 1/60;
		--print("kekeke RocketUIFrame_OnUpdate alpha", alpha);
		if alpha >= 1 then
			alpha = 1;
			RocketInSpace = false;
			getglobal("RocketUIFrameMask"):Hide();
			if CurMainPlayer then
				local rocket = CurMainPlayer:getRidingRocket();
				if rocket then
					local targetMapId = CurMainPlayer:getCurWorldMapId() == 0 and 2 or 0;
					if CurMainPlayer:getCurWorldMapId() >= 0 and CurMainPlayer:getCurWorldMapId() <= 2 then
						getglobal("CompassBirthplace"):Show();
					else
						getglobal("CompassBirthplace"):Hide();
                    end
					rocket:teleportMap(targetMapId);
				end
			end
		end

		ClientMgr:setMusicVolume(1-alpha);
		getglobal("RocketUIFrameMask"):SetBlendAlpha(alpha);
	end
end

--------------------------------------------------PlayShortcut-----------------------------------------

function PlayShortcut_OnLoad()
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	this:RegisterEvent("GE_SHORTCUT_SELECTED");
	this:RegisterEvent("GE_SPRAY_PAINT");
	this:setUpdateTime(0.1);

	PlayShortcut_AddGameEvent()

    for i=1,MAX_SHORTCUT do
		local ShortcutBtn = getglobal("ToolShortcut"..i);
		local ShortcutIcon = getglobal("ToolShortcut"..i.."Icon")
		if ClientMgr:isMobile() then
			ShortcutBtn:SetPoint("left", "PlayShortcut", "left", (i-1)*80+85, -2);
			ShortcutBtn:SetSize(80,80);
			ShortcutIcon:SetSize(68,68);
		else
			ShortcutBtn:SetPoint("left", "PlayShortcut", "left", (i-1)*57+63, -2);
			ShortcutBtn:SetSize(57,57)
		end

		-- ShortcutIcon:SetSize(0.935,0.935)
		local numFont = getglobal("ToolShortcut"..i.."Num");
		local numFontBG = getglobal("ToolShortcut"..i.."TagBkg");
		if ClientMgr:isPC() then
			numFont:Show();
			numFontBG:Show();
		else
			numFont:Hide();
			numFontBG:Hide();
		end
	end
end

function PlayShortcut_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local paramData = context:GetParamData()
		local grid_index = paramData.gridIndex
		if grid_index and grid_index>=ClientBackpack:getShortcutStartIndex() and grid_index<ClientBackpack:getShortcutStartIndex()+1000 then
			ShortCutFrame_UpdateOneGrid(grid_index);
			if getglobal("RoleFrame"):IsShown() then
				UpdateRoleFrameShortcutOneGrid(grid_index);
			elseif getglobal("CreateBackpackFrame"):IsShown() then
				UpdateCreateBackpackFrameShortcutOneGrid(grid_index);
			elseif not ResourceCenterNewVersionSwitch and getglobal("MapModelLibFrame"):IsShown() then
				MapModelShortCutFrame_UpdateOneGrid(grid_index);
			elseif ResourceCenterNewVersionSwitch and HasUIFrame("ResourceCenter") and getglobal("ResourceCenter"):IsShown() then
				GetInst("UIManager"):GetCtrl("ResourceCenter"):UpdateShortCut(grid_index);
			elseif HasUIFrame("HomelandBackpack") and getglobal("HomelandBackpack"):IsShown() then
				GetInst("UIManager"):GetCtrl("HomelandBackpack"):UpdateOneShortcut(grid_index)
			end
		elseif grid_index < 0 then
			ShortCutFrame_UpdateAllGrids();
			if getglobal("RoleFrame"):IsShown() then
				UpdateRoleFrameShortcutAllGrid()
			elseif getglobal("CreateBackpackFrame"):IsShown() then
				UpdateCreateBackpackFrameShortcutAllGrid();
			elseif HasUIFrame("HomelandBackpack") and getglobal("HomelandBackpack"):IsShown() then
				GetInst("UIManager"):GetCtrl("HomelandBackpack"):UpdateShortcuts()
			end
		end
		SetGridEffectForNoviceGuide();
		-- 音乐系统处理
		MusicItem_Selected()
	end )

	SubscribeGameEvent(nil,GameEventType.ShortcoutSelected,function(context)
		local paramData = context:GetParamData()
		local selectgrid = paramData.selectgrid
		ShortCutFrame_Selected(selectgrid);
	end)

	SubscribeGameEvent(nil,GameEventType.SprayPaintChange,function(context)
		local paramData = context:GetParamData()
		local isNext = paramData.isNext
		SprayPaintChange(isNext)
	end)
end

ShortCutNoviceShow 	= false;
ShortCutOffset 		= 0;
function PlayShortcut_OnUpdate()
	if getglobal("PlayShortcut"):IsShown() and ShortCutNoviceShow then
		ShortCutOffset = ShortCutOffset + 25;
		if ShortCutOffset > 100 then
			ShortCutOffset = 100;
			ShortCutNoviceShow = false;
		end
		getglobal("PlayShortcut"):SetPoint("bottom", "PlayMainFrame", "bottom", 0, 100-ShortCutOffset);
	end

	--skill cd
	for i=1, MAX_SHORTCUT do
		local cdBkg = getglobal("ToolShortcut"..i.."CoolingBkg");
		local cdPrecent = getglobal("ToolShortcut"..i.."CoolingPercent");

		local grid_index = ClientBackpack:getShortcutStartIndex() + i - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		local cd = 0;
		if CurMainPlayer ~= nil then 
			 cd = CurMainPlayer:getSkillCD(itemId);
		end 
		if cd > 0 then
			cdBkg:Show();
			local totaltime = CurMainPlayer:getTotalSkillCD(itemId);
			if totaltime > 0 then
				local pro = cd/totaltime;

				local size = 85;
				if ClientMgr:isPC() then
					size = 60;
				end

				if pro > 1.0 then
					pro = 1.0;
				end
				cdBkg:SetSize(size*0.82, size*pro*0.82);
				cdPrecent:SetText(string.format("%.1f",cd));
			end
		else
			cdBkg:Hide();
			cdPrecent:SetText("");
		end
	end

	--actionInvite cd
	UpdateCountDown(1)
end

function ShortCutFrame_UpdateOneGrid(grid_index)
	local n = grid_index+1;
	if grid_index >= ClientBackpack:getShortcutStartIndex() then
		n = n - ClientBackpack:getShortcutStartIndex()
	end

	local ShortcutBtn = getglobal("ToolShortcut"..n);
	local ShortcutIcon = getglobal("ToolShortcut"..n.."Icon");
	local ShortcutNum = getglobal("ToolShortcut"..n.."Count");
	local ShortDurBkg = getglobal("ToolShortcut"..n.."DurBkg");
	local ShortDur = getglobal("ToolShortcut"..n.."Duration");

	--家园特殊处理
	local maxDuration = 0
	if IsInHomeLandMap and IsInHomeLandMap() then
		local itemId = ClientBackpack:getGridItem(grid_index)
		local itemSid = ClientBackpack:getGridSidStr(grid_index)
		if itemId > 0 then
			local itemData = GetInst("HomeLandDataManager"):GetBackpackItemByItemIdAndSid(itemId, itemSid) or {}
			local extData = itemData.goods_extend
			if extData and extData.max_durability_value and extData.now_durability_value then
				maxDuration = extData.max_durability_value --最大耐久

				--设置当前的耐久
				if CurMainPlayer and ClientBackpack then
					local grid = CurMainPlayer:getBackPack():index2Grid(grid_index)
					if grid then
						grid:setDuration(extData.now_durability_value)
					end
				end
			end
		end
	end

	UpdateGridContent(ShortcutIcon, ShortcutNum, ShortDurBkg, ShortDur, grid_index, maxDuration)

	local ban = getglobal("ToolShortcut"..n.."Ban");
	CheckItemIsBan(grid_index, ban, ShortcutIcon);
end

function ShortCutFrame_UpdateAllGrids()
	if not ClientBackpack then
		return
	end
	local maxIndex = MAX_SHORTCUT-1;
	for i=0, maxIndex, 1 do
		ShortCutFrame_UpdateOneGrid(ClientBackpack:getShortcutStartIndex()+i)
	end
end

-- 音乐系统处理
function MusicItem_Selected()
	if IsUGCEditing() and UGCModeMgr:GetGameType() == UGCGAMETYPE_BUILD  then
		GetInst("SceneEditorMsgHandler"):dispatcher(SceneEditorUIDef.common.music_item_selected)
		return
	end

	getglobal("MusicPlayModeBtn"):Hide();
	getglobal("MusicPreinstallBtn"):Hide();
	
	local itemId = ClientBackpack:getGridItem(ClientBackpack:getShortcutStartIndex()+ShortCut_SelectedIndex)
	local main_player_free = GetInst("MiniUIManager"):GetUI("main_player_freeAutoGen")
	if main_player_free then
		GetInst("MiniUIManager"):CloseUI("main_player_freeAutoGen")
	end

	if itemId > 0 then
		local itemDef = ItemDefCsv:get(itemId)
		if itemDef.Type == ITEM_TYPE_MUSIC then

			if GetInst("songBookDataManager") then
				--联机状态
				if ClientCurGame:isInGame() and AccountManager:getMultiPlayer() > 0 then
					if GetInst("songBookDataManager"):checkSystemIsOpen() then
						getglobal("MusicPlayModeBtn"):Show()
					end
				else
					getglobal("MusicPlayModeBtn"):Show()
				end
				getglobal("MusicPreinstallBtn"):Show()
				local data = GetInst("songBookDataManager"):getCurData()

				if data then
					local nameStr = DefMgr:filterString(data.name)
					getglobal("MusicPreinstallBtnTips"):SetText(nameStr)
				end
			end

		end
	end
end

function ShortCutFrame_Selected(index)
	--编辑模式扩展快捷栏以后 index可能大于7
	index = index % MAX_SHORTCUT
	
	-- if true then
	-- 	index = index % MAX_SHORTCUT
	-- 	--让UI选中相应的格子， 其他逻辑不处理
	-- 	if ShortCut_SelectedIndex >= 0 then
	-- 		local selbox = getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."Check");
	-- 		selbox:Hide()
	-- 	end
	-- 	ShortCut_SelectedIndex = index;
	-- 	local selbox = getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."Check");
	-- 	selbox:Show();
	-- 	return
	-- end

	if getglobal("BackpackFramePackFrame"):IsShown() or getglobal("StorageBoxFrame"):IsShown() then
		return;
	end

	if ShortCut_SelectedIndex >= 0 then
		local selbox = getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."Check");
		selbox:Hide()
	end

	ShortCut_SelectedIndex = index;
	if getglobal("PlayMainFrame"):IsShown() and CurWorld ~= nil and CurWorld:getOWID() == NewbieWorldId then
		local taskId = AccountManager:getCurNoviceGuideTask();
		if taskId == 12 or taskId == 13 or taskId == 17 or taskId == 18 then
			SetGridEffectForNoviceGuide();
		end
	end

	local selbox = getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."Check");
	selbox:Show();

	-- 音乐系统处理
	MusicItem_Selected()

	UpdatePaintChangeBtn() -- 喷漆道具显示更新
	if CurMainPlayer:getCurToolID() == ITEM_PAINTTANK then
		local spray_id = getglobal("PaintChangeFrame"):GetClientUserData(0)
		if spray_id and spray_id > 0 then
			Paint_ReportEvent("MINI_TOOL_BAR", "GraffitiChooseButton", "view")
		end
	end
end

function HideShortCutAllItemBoxTexture()
	for i=1, MAX_SHORTCUT do
		local boxTexture = getglobal("ToolShortcut"..i.."Check");
		boxTexture:Hide();
	end
end

function PlayShortcut_OnEvent()
	local ge = GameEventQue:getCurEvent();
	if arg1 == "GE_BACKPACK_CHANGE" then
		local grid_index = ge.body.backpack.grid_index;
		if grid_index>=ClientBackpack:getShortcutStartIndex() and grid_index<ClientBackpack:getShortcutStartIndex()+1000 then
			
			ShortCutFrame_UpdateOneGrid(grid_index);
			if getglobal("RoleFrame"):IsShown() then
				UpdateRoleFrameShortcutOneGrid(grid_index);
			elseif getglobal("CreateBackpackFrame"):IsShown() then
				UpdateCreateBackpackFrameShortcutOneGrid(grid_index);
			elseif not ResourceCenterNewVersionSwitch and getglobal("MapModelLibFrame"):IsShown() then
				MapModelShortCutFrame_UpdateOneGrid(grid_index);
			elseif ResourceCenterNewVersionSwitch and HasUIFrame("ResourceCenter") and getglobal("ResourceCenter"):IsShown() then
				GetInst("UIManager"):GetCtrl("ResourceCenter"):UpdateShortCut(grid_index);
			elseif HasUIFrame("HomelandBackpack") and getglobal("HomelandBackpack"):IsShown() then
				GetInst("UIManager"):GetCtrl("HomelandBackpack"):UpdateOneShortcut(grid_index)
			end
		elseif grid_index < 0 then
			ShortCutFrame_UpdateAllGrids();
			if getglobal("RoleFrame"):IsShown() then
				UpdateRoleFrameShortcutAllGrid()
			elseif getglobal("CreateBackpackFrame"):IsShown() then
				UpdateCreateBackpackFrameShortcutAllGrid();
			elseif HasUIFrame("HomelandBackpack") and getglobal("HomelandBackpack"):IsShown() then
				GetInst("UIManager"):GetCtrl("HomelandBackpack"):UpdateShortcuts()
			end
		end

		--快捷栏 or --背包栏
		if (grid_index>=ClientBackpack:getShortcutStartIndex() and grid_index<ClientBackpack:getShortcutStartIndex()+1000) 
		or (grid_index >= BACKPACK_START_INDEX and grid_index <= BACK_PACK_GRID_MAX) then
			if grid_index and grid_index >=0 then
				local itemId = ClientBackpack:getGridItem(grid_index)
				local itemNum = ClientBackpack:getItemCountInNormalPack(itemId)
				if itemId and itemId ~= 0 then
					local context = SandboxContext():SetData_Number("itemId", itemId):SetData_Number("itemNum", itemNum)
					SandboxLua.eventDispatcher:Emit(nil, "ITEM_ADD",  context)
				end
			end
		end

		SetGridEffectForNoviceGuide();
			-- 音乐系统处理
		MusicItem_Selected()
	elseif arg1 == "GE_SHORTCUT_SELECTED" then
		ShortCutFrame_Selected(ge.body.shortcut.selectgrid);
	elseif arg1 == "GE_SPRAY_PAINT" then
		local index = ge.body.spraypaint.isNext
		SprayPaintChange(index)
	end
end

function PlayShortcut_OnShow()
	--加载一个模型用来生成avatar头像
	local model = UIActorBodyManager:getAvatarBody(2003, false)
	model:setBodyType(3)
	model:addAvatarPartModel(2, 1)
	model:addAvatarPartModel(3, 4)
	model:addAvatarPartModel(4, 6)
	--临时方案
	updateLetters = MAX_SHORTCUT;
	SetGridEffectForNoviceGuide();
	ShortCutFrame_UpdateAllGrids();

	if not IsUGCEditMode() then
		--工具模式界面刷新
		if CurWorld and CurWorld:isGameMakerToolMode() then
			print("PlayShortcut_OnShow:XXX:");
			GetInst("UIManager"):GetCtrl("ToolModeFrame"):Refresh();
		end
	end
    
	local startIndex = SHORTCUT_START_INDEX;
	if ClientBackpack then --偶现ClientBackpack为nil的情况
		startIndex = ClientBackpack:getShortcutStartIndex();
	end
    for i=1,MAX_SHORTCUT do
        local ShortcutBtn = getglobal("ToolShortcut"..i)
        ShortcutBtn:SetClientID(startIndex + i)
    end
end

function HideGridEffectForNoviceGuide()
	for i=1, 6 do
		--[[
		local btnEffect = getglobal("ToolShortcut"..i.."Effect");
		local finger	= getglobal("ToolShortcut"..i.."Finger");
		if btnEffect:IsShown() then
			btnEffect:Hide();
		end
		if finger:IsShown() then
			finger:Hide();
		end
		]]
	end

	for i=1, BACK_PACK_GRID_MAX do
		if i <= 30 then
			--[[
			local btnEffect = getglobal("BackpackFramePackFrameItem"..i.."Effect");
			local finger	= getglobal("BackpackFramePackFrameItem"..i.."Finger");
			if btnEffect:IsShown() then
				btnEffect:Hide();
			end
			if finger:IsShown() then
				finger:Hide();
			end
			]]
		end
	end
end

function SetGridEffectForNoviceGuide()
	--[[
	if CurWorld:getOWID() == NewbieWorldId then
		local taskId = AccountManager:getCurNoviceGuideTask()
		local goalId = 0;
		if taskId > 11 and taskId < 14 then
			goalId = 800;
		elseif taskId > 16 and taskId < 19 then
			goalId = 12502;
		end

		if goalId > 0 then
			local hasGoalIdItem = false;
			for i=1, 6 do
				local grid_index = i + ClientBackpack:getShortcutStartIndex() - 1;
				local itemId = ClientBackpack:getGridItem(grid_index);
				local btnEffect = getglobal("ToolShortcut"..i.."Effect");
				local finger	= getglobal("ToolShortcut"..i.."Finger");
				if itemId == goalId then
					btnEffect:Show();
					btnEffect:SetUVAnimation(100, true);
					if ShortCut_SelectedIndex >= 0 then
						local shortcutId = ClientBackpack:getGridItem(ShortCut_SelectedIndex+ClientBackpack:getShortcutStartIndex());
						if shortcutId == goalId then
							finger:Hide();
						else
							finger:Show();
							finger:SetUVAnimation(100, true);
						end
					end
				elseif btnEffect:IsShown() then
					btnEffect:Hide();
					finger:Hide();
				end
			end
			for i=1, BACK_PACK_GRID_MAX do
				if i <= 30 then
					local grid_index = i + BACKPACK_START_INDEX - 1;
					local itemId = ClientBackpack:getGridItem(grid_index);
					local btnEffect = getglobal("BackpackFramePackFrameItem"..i.."Effect");
					local finger	= getglobal("BackpackFramePackFrameItem"..i.."Finger");
					if itemId == goalId then
						btnEffect:Show();
						btnEffect:SetUVAnimation(100, true);
						if ShortCut_SelectedIndex >= 0 then
							local shortcutId = ClientBackpack:getGridItem(ShortCut_SelectedIndex+ClientBackpack:getShortcutStartIndex());
							if shortcutId == goalId then
								finger:Hide();
							else
								finger:Show();
								finger:SetUVAnimation(100, true);
							end
						end
					elseif btnEffect:IsShown() then
						btnEffect:Hide();
						finger:Hide();
					end
				end
			end
		end
	end
	]]
end

function ToolShortcutPlace(grid_index)
	if getglobal("StorageBoxFrame"):IsShown() then
		local itemId = ClientBackpack:getGridItem(grid_index);
		if itemId > 0 then
			CurMainPlayer:storeItem(grid_index, 1);
		end
	end
end

function SetToolShortcutTexture(btnName)
	HideShortCutAllItemBoxTexture()

	if btnName ~= nil then
		local texture = getglobal(btnName.."Check");
		texture:Show();
	end
end

--存档评分界面打开按钮
function ArchiveGradeBtn_OnClick()
	if not getglobal("ArchiveGradeFrame"):IsShown() then
		getglobal("ArchiveGradeFrame"):Show();
	else
		getglobal("ArchiveGradeFrame"):Hide();
	end
end

--成就界面打开按钮
function PlayAchievementBtn_OnClick()
	local AchievementFrame = getglobal("AchievementFrame")
	local riddlesUI = GetInst("MiniUIManager"):GetUI("MiniUIRiddlesMain");
	if not AchievementFrame:IsShown() and not riddlesUI then
		AchievementFrameType = 1;
		AchievementFrame:Show();
		AchievementFrame:SetPoint("center", "$parent", "center", 0, 0);
	else
		AchievementFrame:Hide();
	end
end
--坐骑信息界面打开按钮
function AccRideCallBtn_OnClick()
	if ClassList["UnitTestManager"]:GetInst():GetIsTest() then
		ClassList["UnitTestManager"]:GetInst():Start()
		return
	end
	-- 当前玩家是否可召唤坐骑
	if not CheckPlayerActionState(ENABLE_CALLRINDER) then
		ShowGameTipsWithoutFilter(GetS(34212), 3);
		return;
	end
	local riddlesUI = GetInst("MiniUIManager"):GetUI("MiniUIRiddlesMain");
	if getglobal("AccRideCallFrame"):IsShown() then
		getglobal("AccRideCallFrame"):Hide();
	else
		if not riddlesUI then
			getglobal("AccRideCallFrame"):Show();
		end
	end
	if IsMyHomeMap() then 
		if CurWorld:isGameMakerMode() then	-- 编辑模式
			standReportEvent("601", "MINI_MY_HOMELAND_EDIT_MAP", "Mount", "click")
		elseif CurWorld:isGameMakerRunMode() then	--玩法模式
			standReportEvent("6", "MINI_MY_HOMELAND_CONTAINER", "Mount", "click")
		end
	end
end

--过滤不需要显示使用按钮的变身装扮
local function needShowRideAttackBtn( skinId )
	local filterIds = { 64, 75, 103 ,196, 197, 278, 306, 307}
	for _,id in ipairs(filterIds) do
		if id == skinId then 
			return false
		end 
	end
	return true
end

--点击坐骑变形按钮
function AccRideChangeBtn_OnClick()

	if DisabledExecute() then
		return
	end

	if CurMainPlayer then
		if CurMainPlayer:isSleeping() or CurMainPlayer:isRestInBed() then
			CurMainPlayer:dismountActor();
			if CurMainPlayer:isShapeShift() then
				getglobal("AccRideAttackBtn"):Hide()
				getglobal("AccRideAttackLeftBtn"):Hide()
			end
		end

		if CurMainPlayer:InTransform() then
			CurMainPlayer:resetActorBody()
			return
		end
		local nowTime = AccountManager:getSvrTime()
		local skinId = CurMainPlayer:getSkinID()
		local skinDef = RoleSkinCsv:get(skinId)
		if skinDef["ChangeType"] == 2 then

			local diff = nowTime - lastTimeCombineTransform
			if diff >= 30 then
				if not CurMainPlayer:tryShapeShift(skinId) then
					return
				end
				lastTimeCombineTransform = nowTime
			else
				local rest = 30 - diff
				ShowGameTips(GetS(30356, rest))
			end
			return
		end
		
		if skinDef["ChangeType"] > 0 then
			local changeRideId = skinDef.ChangeContact and skinDef["ChangeContact"][0] or 0;
			if CurMainPlayer:isShapeShift() then
				CurMainPlayer:dismountActor();
				getglobal("AccRideAttackBtn"):Hide()
				getglobal("AccRideAttackLeftBtn"):Hide()
				--路障皮肤变身为人型
				if changeRideId == 4652 then
					CurMainPlayer:playBodyEffect(skinDef.Effect)
				end
			else
				local time =  CurMainPlayer:getAccountHorseLiveAge(changeRideId)/20;
				if time < 0 then
					time = math.ceil(0-time);
					ShowGameTips(GetS(100260, time));
					return;
				end
				CurMainPlayer:tryShapeShift(skinId)
				if ClientMgr:isMobile() and needShowRideAttackBtn(skinId) then --64-红蜘蛛 坐骑飞行 加速按钮无效不显示
					getglobal("AccRideAttackBtn"):Show()
					getglobal("AccRideAttackLeftBtn"):Show()
				end

				--路障皮肤变身为车型
				if changeRideId == 4652 and CurMainPlayer.getBody then
					local body = CurMainPlayer:getBody();
					if body and body.setSkinEffect3Playing then
						body:setSkinEffect3Playing(true)
					end
					CurMainPlayer:stopBodyEffect(skinDef.Effect)
				end
			end
		end

		if getglobal("AccRideChangeBtnEffect"):IsShown() then
			getglobal("AccRideChangeBtnEffect"):Hide()
		end
	end
end

--点击坐骑攻击按钮
function AccRideAttackBtn_OnClick()
	if DisabledExecute() then
		return
	end
	if CurMainPlayer then
		CurMainPlayer:doSpecialSkill();
	end
end

--换弹夹按钮
function AccChangeMagazineCallBtn_OnClick()
	-- if ClientMgr:isMobile() then
        local itemid = CurMainPlayer:getCurToolID()
        if itemid == ITEM_COLORED_GUN or itemid == ITEM_COLORED_EGG or itemid == ITEM_COLORED_EGG_SMALL or IsDyeableBlockLua(itemid) then
            local curOpId=0;
		    local val, val2=0,0;
		    curOpId, val = CurWorld:getRuleOptionID(33, curOpId, val);
		    curOpId, val2 = CurWorld:getRuleOptionID(12, curOpId, val2);
            if false == (CurWorld:isGameMakerRunMode() == true and val ~= 0 and val2 ~= 0) then
                ShowPaletteFrame()
            end
        else
		    CurMainPlayer:setReloadMagazine();
        end
	-- end
end

--切换喷漆图案
function PaintChangeBtn_OnClick()
	-- if ClientMgr:isMobile() then
        local itemid = CurMainPlayer:getCurToolID()
        if itemid == ITEM_PAINTTANK then
            GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/common_comp"})
			UIPackage:addPackage("miniui/miniworld/GameSprayPaint") -- 资源大小写问题，提前加载，后续要注意miniui/miniworld/xxx文件的大小写是否对得上
    		GetInst("MiniUIManager"):OpenUI("GameSprayPaint","miniui/miniworld/gameSprayPaint","GameSprayPaintAutoGen", {})
        end
		Paint_ReportEvent("MINI_TOOL_BAR", "GraffitiChooseButton", "click")
	-- end
end

--指针罗盘
function Compass_OnLoad()
	this:RegisterEvent("GIE_COMPASS_CHANGE");
end

function Compass_OnShow()
	local getglobal = _G.getglobal;
	getglobal("CompassCircle1"):Hide()
	getglobal("CompassCircle2"):Hide()
	getglobal("CompassHintLine"):Hide()
	if CurWorld and CurWorld:getCurMapID() >= 0 and CurWorld:getCurMapID() <= 2 then 
		getglobal("CompassBirthplace"):Show();
	else
		getglobal("CompassBirthplace"):Hide();
	end
end

function Compass_OnEvent()
	if arg1 == "GIE_COMPASS_CHANGE" then
		local ge = GameEventQue:getCurEvent();
		local compassData = ge.body.compass;
		UpdateCompass(compassData);
	end
end
--  -1000表示没有这个点;
local Player_Max_Num = 40;
function UpdateCompass(compassData)
	if ClientCurGame == nil then
		return;
	end
	local angle = 90 - compassData.angle;

	if compassData.rotmode == 0 then
		getglobal("CompassBkg"):SetAngle(angle);
		getglobal("CompassPointer"):SetAngle(0);
	else
		getglobal("CompassPointer"):SetAngle(90-angle);
		getglobal("CompassBkg"):SetAngle(90);
	end

	local CompassBoss = getglobal("CompassBoss")
	if compassData.guidex == -1000 then
		CompassBoss:Hide();
	else
		CompassBoss:Show();
		CompassBoss:SetPoint("center", "CompassBkg", "center", compassData.guidex, compassData.guidey);
		if compassData.hasboss then
			CompassBoss:SetTexUV("lzy_09")
		else
			CompassBoss:SetTexUV("lzy_altar")
		end

		
		if CurMainPlayer:getCurWorldMapId() == 0 then -- 虚空boss
			if not getglobal("InstanceTaskFrame"):IsShown() then
				getglobal("InstanceTaskFrame"):Show();
			end
		end
	end

	getglobal("CompassBirthplace"):SetPoint("center", "CompassBkg", "center", compassData.spawnx, compassData.spawny);

	local CompassDeathplace = getglobal("CompassDeathplace")
	if compassData.deadx == -1000 then
		CompassDeathplace:Hide();
	else
		CompassDeathplace:Show();
		CompassDeathplace:SetPoint("center", "CompassBkg", "center", compassData.deadx, compassData.deady);
	end

	local totemnum = WorldMgr and WorldMgr:getTotemPointNum() or 0;
	for i=1, MAX_TOTEM_NUM do
		local totem = getglobal("CompassTotem"..i);
		local totempos = compassData.totempos[i-1];
		if totempos.px == -1000 then
			totem:Hide();
		else
			totem:Show();
			totem:SetPoint("center", "CompassBkg", "center", totempos.px, totempos.py);
			local size = 22;
			size = size - math.ceil((totemnum - 1) * 1.7);
			if size < 8 then
			   size = 8;
			end
			totem:SetSize(size, size);
		end
	end
	local transfernum = 0;
	for i=1, MAX_TRANSFER_NUM do
		local transfer = getglobal("CompassTransfer"..i);
		local transferpos = compassData.transferpos[i-1];
		if transferpos.px == -1000 then
			transfer:Hide();
		else
			transfer:Show();
			transfer:SetPoint("center", "CompassBkg", "center", transferpos.px, transferpos.py);
			transfernum = transfernum + 1;
		end
	end
	--for i=1,transfernum do
	--	local transfer = getglobal("CompassTransfer"..i);
	--	local size = 22;
	--	size = size - math.ceil((transfernum - 1) * 1.7);
	--	if size < 8 then
	--	   size = 8;
	--	end
	--	transfer:SetSize(size, size);
	--end


	if ClientCurGame:isInGame() then
		local hour = ClientCurGame:getGameTimeHour();
		local surviveDay = CurMainPlayer:getSurviveDay();
		local CompassDay = getglobal("CompassDay")
		local CompassNight = getglobal("CompassNight")

		if surviveDay % 4 == 0 and (hour >=18 or  hour < 6) then
			getglobal("CompassSpecialNight"):Show();
			CompassNight:Hide();
			CompassDay:Hide();
		else
			getglobal("CompassSpecialNight"):Hide();

			if hour >= 6 and hour < 20 then
				CompassDay:Show();
				CompassNight:Hide();
			else
				CompassDay:Hide();
				CompassNight:Show();
			end
		end
	end

	if ClientCurGame:isInGame() then
		local playerNum = ClientCurGame:getNumPlayerBriefInfo();
		for i=1, Player_Max_Num do
			local player = getglobal("CompassPlayer"..i);
			player:Hide();
			if i <= playerNum then
				local playerInfo = compassData.playerpos[i-1];
				if playerInfo.px ~= -1000 then
					player:Show();
					player:SetPoint("center", "CompassBkg", "center", playerInfo.px, playerInfo.py);
					local size = 16;
					if playerNum > 5 then
						size = size - math.ceil((playerNum - 5) * 0.3);
					end
					player:SetSize(size, size);
				end
			end

		end
	end

	if ClientCurGame:isInGame() and MAX_STARTSTATION_MAEKPOINT_NUM then
		for i=1, MAX_STARTSTATION_MAEKPOINT_NUM do
			local starStation = getglobal("CompassStarStation"..i);
			local pos = compassData.starstationpos[i-1];
			if pos.px == -1000 then
				starStation:Hide();
			else
				starStation:Show();
				starStation:SetPoint("center", "CompassBkg", "center",pos.px, pos.py);
			end
		end
	end
end

--打开小地图
function CompassOpenMap_OnClick()
	if isEducationalVersion then
		return;
	end
	
	for i=1, #(t_UIName) do
		local frame = getglobal(t_UIName[i]);
		if t_UIName[i] == 'PlayMainFrame' then
			PlayMainFrameUIHide();
		else
			frame:Hide();
		end
	end
	local mvcFrame = GetInst("UIManager"):GetCtrl("StarStationInfo");
	if mvcFrame then
		GetInst("UIManager"):Close("StarStationInfo")
	end
	HideAllFrame("MapFrame", true);
	getglobal("MItemTipsFrame"):Hide();

	ClientCurGame:enableMinimap(true);
	getglobal("MapFrame"):Show();
	--3d地图显示埋点上报
	if getglobal("MapFrame"):IsShown() then
		if GetInst("MiniUIManager"):GetCtrl("main_map") then
			local mapctrl = GetInst("MiniUIManager"):GetCtrl("main_map")
			mapctrl:StandbyReport('SCREEN_MAP_3D','-','view',nil)
		end
	end
    CurMainPlayer:setUIHide(true, true);

    if getglobal("SleepNoticeFrame"):IsShown() then
        setkv("Sleep_Notice_Frame_Show", true)
        getglobal("SleepNoticeFrame"):Hide()
    end
end

------------------------------------------------------PlayerInfo-------------------------------------------------------
AutoOpenPlayerInfo = true;
local ApplyPermitsCD = -1;
function InitMultiPlayerInfoFrame()
	ApplyPermitsCD = -1;
	RoomInteractiveData.t_KickInfo = {};
end
--踢人
function PlayerInfoKickPlayerBtn_OnClick()
	local index = this:GetClientUserData(0);
	if IsRoomOwner() and index > 0 then 	--主机才能踢人
		local briefInfo = ClientCurGame:getPlayerBriefInfo(index-1);
		if briefInfo ~= nil then
			MessageBox(5, GetS(446, briefInfo.nickname));
			getglobal("MessageBoxFrame"):SetClientUserData(0, briefInfo.uin);
			getglobal("MessageBoxFrame"):SetClientUserData(1, 1);
			getglobal("MessageBoxFrame"):SetClientString( "房间踢人" );
			local extra = {cid=tostring(G_GetFromMapid())}
			standReportEvent("1003", "KICK_OUT_WARNNING", "-", "view", extra)
			standReportEvent("1003", "KICK_OUT_WARNNING", "ConfirmButton", "view", extra)
			standReportEvent("1003", "KICK_OUT_WARNNING", "CancleButton", "view", extra)
		end
	else
		ShowGameTips(GetS(448), 3);
	end
end

function AddTodayKickPlayerCount()
	local keyC = "KickPlayerCount"
	local keyD = "KickPlayerCountDate"

	local curDate = os.date("%m-%d")

	local saveC = getkv(keyC)
	local saveD = getkv(keyD)
	if saveD == curDate then
		setkv(keyC, (saveC or 0) + 1)
	else
		setkv(keyC, 1)
		setkv(keyD, curDate)
	end
end

function GetTodayKickPlayerCount()
	local keyC = "KickPlayerCount"
	local keyD = "KickPlayerCountDate"

	local curDate = os.date("%m-%d")

	local saveC = getkv(keyC)
	local saveD = getkv(keyD)
	if saveD == curDate then
		return saveC or 0
	else
		return 0
	end
end

--确认踢人
function ConfirmKickPlayer(uin, kickertype)
	print("kekeke ConfirmKickPlayer", uin);
	local briefInfo = ClientCurGame:findPlayerInfoByUin(uin);
	if briefInfo then
		if RentPermitCtrl:IsRentRoom() == false then
			AccountManager:sendToClientKickInfo(0, briefInfo.uin); --通知被踢者他被踢了
		end
		kickertype = kickertype == nil and 1 or kickertype
		local kickername = AccountManager:getNickName()
		table.insert(RoomInteractiveData.t_KickInfo, {uin=briefInfo.uin, name=briefInfo.nickname, time=0.5, kickername=kickername, kickertype = kickertype});
		AddTodayKickPlayerCount()
	end
end

--收到申请权限
function OnReceiveApplyPermits(uin)
	if PermitsCallModuleScript("getPlayerRoomCommonPermitsType") ~= ROOM_GAME_COMMON_SET_GUEST then
		local briefInfo = ClientCurGame:findPlayerInfoByUin(uin);
		if briefInfo then
			ChatDisplayTime = 10.0;
			local sp = AccountManager:getBlueVipIconStr(briefInfo.uin)..briefInfo.nickname;
			RoomInteractiveData:AddRoomChat({type="permits_msg", speaker=sp, uin=briefInfo.uin, id=RoomInteractiveData.msgId});
			RoomInteractiveData:UpdateRoomChat();
		end
	end
end

--拒绝
function MultiPlayerInfoReceiveApplyRefuseBtn_OnClick()

end

--同意
function MultiPlayerInfoReceiveApplyAgreeBtn_OnClick()

end

--申请权限
function MultiPlayerInfoApplyPermitsBtn_OnClick()
	if AccountManager:getMultiPlayer() == 2 and ClientCurGame:isInGame() then --客机才能申请
		if ApplyPermitsCD > 0 then
			ShowGameTips(GetS(4982), 3);
		else
			ApplyPermitsCD = 10;
			local uin = AccountManager:getUin();
			ClientCurGame:applyPermits(uin);
			ShowGameTips(GetS(1187), 3);
			getglobal("RoomUIFrameCenterFuncFrame"):Hide();
		end
	end
end

function OnRespApplyPermits(ret)
	if ret == 0 then
		ShowGameTips(GetS(4984), 3);
	elseif ret == 1 then
		ShowGameTips(GetS(4983), 3);
	end
	ApplyPermitsCD = -1;
end

function MultiPlayerInfoInfo_OnShow()

end

function MultiPlayerInfoSwitch_OnClick()

end


function MultiPlayerInfo_OnLoad()
	this:setUpdateTime(0.1);
end

function MultiPlayerInfo_OnEvent()

end

function MultiPlayerInfo_OnUpdate()
	if not ClientCurGame:isInGame() then return end

	local num = ClientCurGame:getNumPlayerBriefInfo()

	local MultiPlayerInfoInfo = getglobal("MultiPlayerInfoInfo")
	if AutoOpenPlayerInfo and num > 0 then
		AutoOpenPlayerInfo = false;
		if not MultiPlayerInfoInfo:IsShown() then
			getglobal("MultiPlayerInfoSwitchOn"):Hide();
			getglobal("MultiPlayerInfoSwitchOff"):Show();
			SetPlayerInfoState();
		end
	end
	if MultiPlayerInfoInfo:IsShown() and ClientCurGame:isInGame() then
		local num = ClientCurGame:getNumPlayerBriefInfo();
		for i=1, 40 do
			local player = getglobal("MultiPlayerInfoInfoInfoPlayer"..i);
			if i <= num then
				player:Show();
				local briefInfo = ClientCurGame:getPlayerBriefInfo(i-1);
				if briefInfo ~= nil then
					local name 			= getglobal(player:GetName().."PlayerName");
					local hp 			= getglobal(player:GetName().."Hp");
					local hpBkg 		= getglobal(player:GetName().."HpBkg");
					local kick			= getglobal(player:GetName().."KickPlayerBtn");
					local speakerIcon	= getglobal(player:GetName().."SpeakerIcon");

					name:SetText(briefInfo.nickname);

					local ratio = briefInfo.hp/MainPlayerAttrib:getMaxHP();
					if ratio > 1 then ratio = 1 end
					if CurWorld:isGodMode() then
						hp:Hide();
						hpBkg:Hide();
					else
						hpBkg:Show();
						hp:SetSize(ratio*196, 3);
						if briefInfo.hp >= 15 then
							hp:SetColor(0, 255, 0);
						elseif briefInfo.hp >= 8 then
							hp:SetColor(255, 255, 0);
						else
							hp:SetColor(255, 0, 0);
						end

						if briefInfo.hp <= 0 then
							hp:Hide();
						else
							hp:Show();
						end
					end

					if IsRoomOwner() then 	--主机才显示踢人按钮
						kick:Show();
						kick:SetClientUserData(0, i);
					else
						kick:Hide();
						kick:SetClientUserData(0, 0);
					end

					local uiVipIcon1 = getglobal(player:GetName().."VipIcon1");
					local uiVipIcon2 = getglobal(player:GetName().."VipIcon2");
					local vipDisp = UpdateVipIcons(briefInfo.vipinfo, uiVipIcon1, uiVipIcon2);
					name:SetPoint("left", player:GetName(), "left", 27+vipDisp.nextUiOffsetX, 0);

					if briefInfo.YMspeakerswitch == 0 then
						speakerIcon:Hide()
					else
						speakerIcon:Show();
					end
				end
			else
				player:Hide();
			end
		end
	end

	local height = 255;
	if num > 5 then
		height = 255 + 51 * (num - 5);
	end
	getglobal("MultiPlayerInfoInfoInfoPlane"):SetSize(198, height);

	--踢人
	local t_RemoveIdx = {};
	for i=#RoomInteractiveData.t_KickInfo, 1, -1 do
		if RoomInteractiveData.t_KickInfo[i].time < 0 then
			if RentPermitCtrl:IsRentRoom() then
				RentPermitCtrl:KickPlayer(RoomInteractiveData.t_KickInfo[i].uin,1,RoomInteractiveData.t_KickInfo[i].name,RoomInteractiveData.t_KickInfo[i].kickertype)
			else
				AccountManager:requestRoomKickPlayer(RoomInteractiveData.t_KickInfo[i].uin);
				local text = GetS(500, RoomInteractiveData.t_KickInfo[i].name);
				ShowGameTips(text, 3);
				text = GetS(700, RoomInteractiveData.t_KickInfo[i].name);
				ClientCurGame:sendChat(text, 1);
			end
			table.remove(RoomInteractiveData.t_KickInfo, i);
		else
			RoomInteractiveData.t_KickInfo[i].time = RoomInteractiveData.t_KickInfo[i].time - arg1;
		end
	end
end

function MultiPlayerInfo_OnShow()

end

--为语音房 获得特殊标记
function GVoiceGenRoomToken()
    if ClientCurGame then
        local key = nil
        if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then
            key = RentPermitCtrl:GetRentRoomID()
        end

        if "string" ~= type(key) or "" == key then
			if ClientCurGame.getHostUin then
				key = tostring(ClientCurGame:getHostUin())
			else
				key = ""
			end
            
        else
            if not string.match(key, '^%d+_%d+$') then
                key = gFunc_getmd5(key)
            end 
        end
        return key
    end

    return ''
end

local GVoiceGuideTime = 10;	--10s
function GVoiceGuide_OnUpdate()
	GVoiceGuideTime = GVoiceGuideTime - arg1;
	if GVoiceGuideTime < 0 then
		getglobal("GVoiceGuide"):Hide();
		AccountManager:setNoviceGuideState("gvoiceguide", true);
	end
end

function MultiChatBtn_OnClick()
	-- AccelKey_Chat();
	GetInst("ChatHelper"):OpenChatView()
	local chatViewCtrl =  GetInst("MiniUIManager"):GetCtrl("chat_view")
	if chatViewCtrl then
		chatViewCtrl:SetChatViewType(1)
		if not chatViewCtrl:CheckMobile() then
			chatViewCtrl:UpdateEditBoxStatus(true)
		else
			chatViewCtrl:ResetTween()
			chatViewCtrl:SetViewDelayClose()
		end
	end
	getglobal("ChatViewGuide"):Hide()
	setkv("chatViewGuideStepTwo",1)
	local sid = "1001"
    if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
        sid = "1003"
    end
	standReportEvent(sid, "CHAT_NEWS_BOX", "ChatNewsBox", "click")
end

function GVoiceJoinRoomBtn_OnShow()
	if not CheckAutoOpenVoice() then
		return
	end
	if GYouMeVoiceMgr:isJoinRoom() then
		if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) and not GetInst("TeamVocieManage"):isInTeamVocieRoom() then--xyang自定义UI
			getglobal("GVoiceJoinRoomBtn"):Hide();
			getglobal("MicSwitchBtn"):Show();
			getglobal("SpeakerSwitchBtn"):Show();
		end
	end
end

function RefreshVoiceRoomBtns()
	if GYouMeVoiceMgr:isJoinRoom() then
		if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) then--xyang自定义UI
			getglobal("GVoiceJoinRoomBtn"):Hide();
			GetInst("TeamVocieManage"):TeamButtonInit()
		end
	end
end

function GVoiceJoinRoomBtn_OnClick()
	threadpool:work(function ()
		-- action_id:1 限制语音   action_id:2限制聊天
		if GetInst("CreditScoreService"):CheckLimitAction(GetInst("CreditScoreService"):GetTypeTbl().voice) then
			-- print("FriendChatSendBtn_OnClick 信用分过低，限制语音")
			return	
		end

		--处于禁言状态不能加入语音房间
		if CheckVoiceMuteStatus() then
			--判断现在是否可用 
			if checkCanOpenMicAndSpeaker() then
				if GYouMeVoiceMgr:isInit() then
					local ret = GYouMeVoiceMgr:joinVoiceRoom();
					if ret ~= YOUME_SUCCESS then
						if ClientMgr:isAndroid() and ret == YOUME_ERROR_REC_NO_PERMISSION_SHOW_RECORD_ALERT then
							--拉起授权弹框 不要做任何提示
						else
							ShowGameTips( GetS(3675, ret) )
						end
					end

				else
					ShowGameTips( GetS(3675, -1) );
				end
			end
		end
		
		local sid = "1001"
		if IsRoomOwner() then
			sid = "1003"
		end
		standReportEvent(sid, "MINI_VOICE_CHAT", "VoicechatButton", "click")

		-- statisticsGameEvent(801);

	end)
end

function MicSwitchBtn_OnHide()
	if not CheckAutoOpenVoice() then
		return
	end
	if GYouMeVoiceMgr:isJoinRoom() then
		if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) and getglobal("PlayShortcut"):IsShown() and not GetInst("TeamVocieManage"):isInTeamVocieRoom()  then--xyang自定义UI
			getglobal("MicSwitchBtn"):Show();
			getglobal("SpeakerSwitchBtn"):Show();
		end
	end
end

function MicSwitchBtn_OnClick()
	--LLDO:13岁保护模式特殊处理: 不让点击, 点击飘字
	if IsProtectMode() then
		ShowGameTips(GetS(20211), 3);
		local sid = "1001"
		if IsRoomOwner() then
			sid = "1003"
		end
		standReportEvent(sid, "MINI_VOICE_CHAT", "MicButton", "click", {standby1 = "2", standby2 = "1"}) --低于13岁 开启麦克风失败
		return;
	end

	GVoiceMicSwitch();
end

function UpdateMicSwitchBtnTexture()
	local icon = getglobal("MicSwitchBtnIcon");


	if ClientMgr:getGameData("micswitch") == 0 then
		icon:SetTexUV("icon_voice_no");
		icon:SetSize(38, 37);
	else
		icon:SetTexUV("icon_voice");
		icon:SetSize(22, 32);
	end
end

function SpeakerSwitchBtn_OnHide()
	if not CheckAutoOpenVoice() then
		return
	end
	if GYouMeVoiceMgr:isJoinRoom() then
		if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) and getglobal("PlayShortcut"):IsShown() and not GetInst("TeamVocieManage"):isInTeamVocieRoom() then--xyang自定义UI
			getglobal("MicSwitchBtn"):Show();
			getglobal("SpeakerSwitchBtn"):Show();
		end
	end
end

function SpeakerSwitchBtn_OnClick()
	GVoiceSpeakerSwitch();
end

function TeamMicSwitchBtn_OnClick()
	GetInst("TeamVocieManage"):TeamupMainBottomLeftMenuMicSwitchBtClick(false)
end

function TeamSpeakerSwitchBtn_OnClick()
	GetInst("TeamVocieManage"):TeamupMainBottomLeftMenuSpeakerSwitchBtn(false)
end

function UpdateSpeakerSwitchBtnTexture()
	local icon = getglobal("SpeakerSwitchBtnIcon");

	if ClientMgr:getGameData("speakerswitch") == 0 then
		icon:SetTexUV("icon_horn_no");
	else
		icon:SetTexUV("icon_horn");
	end
end

function GVoiceMicSwitch(isOpen)
	local standby1 = 0
	local stabdby2 = 0 --standby2：standby1=2时记录开启麦克风失败原因： standby2：standby1=0时记录本次游戏麦克风开启持续时长（单位：秒）,只记录超过1min的"
	if not checkCanOpenMicAndSpeaker() then
		if GYouMeVoiceMgr and ClientMgr:getGameData("micswitch") ~= 0 then
			--打开状态 就直接关闭
			--关闭麦克风
			GYouMeVoiceMgr:setMicrophoneMute(true)
		end

		return
	end


	if ClientMgr:getGameData("micswitch") == 0 then	--如果前状态是关，点击打开
		--打开麦克风
		local rst = GYouMeVoiceMgr:setMicrophoneMute(false);
		standby1 = 1
		RoomInteractiveData.VoiceOpenMicTimeStamp = getServerTime()
		if rst == -2 then		--国战语音 没有麦克风权限不能打开麦克风
			ShowGameTips(GetS(1207), 3);
			standby1 = 2
			standby2 = 2 --未获取手机麦克风权限=2
			RoomInteractiveData.VoiceOpenMicTimeStamp = 0
		end
	else
		--关闭麦克风
		GYouMeVoiceMgr:setMicrophoneMute(true);
		standby1 = 0
		RoomInteractiveData.VoiceOpenMicTotalTime = RoomInteractiveData.VoiceOpenMicTotalTime or 0
		if RoomInteractiveData.VoiceOpenMicTimeStamp and RoomInteractiveData.VoiceOpenMicTimeStamp ~= 0 then
			RoomInteractiveData.VoiceOpenMicTotalTime = RoomInteractiveData.VoiceOpenMicTotalTime + getServerTime() - RoomInteractiveData.VoiceOpenMicTimeStamp --时长
			RoomInteractiveData.VoiceOpenMicTimeStamp = 0
		end
	end

	local sid = "1001"
	if IsRoomOwner() then
		sid = "1003"
	end
	standReportEvent(sid, "MINI_VOICE_CHAT", "MicButton", "click", {standby1 = tostring(standby1), standby2 = tostring(standby2)})

	voiceManager.IsLocalOperateMacAndSpeaker = true
end

function GVoiceSpeakerSwitch(isOpen)
	local standby1 = 0 
	if ClientMgr:getGameData("speakerswitch") == 0 then	--如果前状态是关，点击打开
		--打开扬声器
		print("GVoiceSpeakerSwitch 打开扬声器")
		GYouMeVoiceMgr:setSpeakerMute(false);
		standby1 = 1
	else
			--关闭扬声器
		print("GVoiceSpeakerSwitch 关闭扬声器")
		GYouMeVoiceMgr:setSpeakerMute(true);
		standby1 = 0
	end

	local sid = "1001"
	if IsRoomOwner() then
		sid = "1003"
	end
	standReportEvent(sid, "MINI_VOICE_CHAT", "SpeakerButton", "click", {standby1 = tostring(standby1)})

	voiceManager.IsLocalOperateMacAndSpeaker = true
end

function SetVoiceTipsInfo(uvName)
	getglobal("VoiceTipsFrameIcon"):SetTexUV(uvName);

	if string.find(uvName,"icon_voice_no") ~= nil then
		getglobal("VoiceTipsFrame"):SetSize(82,80)
	elseif string.find(uvName,"icon_voice") ~= nil then
		getglobal("VoiceTipsFrame"):SetSize(60,82)
	else
		getglobal("VoiceTipsFrame"):SetSize(82,82)
	end

	getglobal("VoiceTipsFrameIcon"):SetBlendAlpha(1.0);
	if not getglobal("VoiceTipsFrame"):IsShown() then
		getglobal("VoiceTipsFrame"):Show();
	end
end

function VoiceTipsFrame_OnLoad()
	this:setUpdateTime(0.05);
end

function VoiceTipsFrame_OnUpdate()
	local alpha = getglobal("VoiceTipsFrameIcon"):GetBlendAlpha() - 0.1;
	if alpha < 0 then
		alpha = 0;
		getglobal("VoiceTipsFrame"):Hide();
	end

	getglobal("VoiceTipsFrameIcon"):SetBlendAlpha(alpha);
end

function ReceiveVoiceBtn_OnClick()
end

function ReceiveVoiceBtn_OnMouseDown()
	YvMgr:recordStart("", "");
end

function ReceiveVoiceBtn_OnMouseUp()
	YvMgr:stopRecord();
end

------------------------------------------队伍设置------------------------------------------
TeamSetterCtrl = {
	ColorDefine = {
		{ r = 255, 	g = 249, 	b = 235},	--0:无队伍
		{ r = 255, 	g = 87, 	b = 69 },	--1.红
		{ r = 69, 	g = 139, 	b = 225 },	--2.蓝
		{ r = 37, 	g = 198, 	b = 105 },	--3.绿
		{ r = 255, 	g = 210, 	b = 0 },	--5.黄
		{ r = 255, 	g = 128, 	b = 64 }, 	--6.橙
		{ r = 163, 	g = 73, 	b = 164 },	--4.紫
	},

	getBaseSettingMgr = function(self)
		if WorldMgr then
			local BaseSettingMgr = WorldMgr:getBaseSettingManager();
			return BaseSettingMgr;
		end

		return nil;
	end,

	getTeamsNum = function(self)
		local BaseSettingMgr = self:getBaseSettingMgr();
		local num = 0;
		if BaseSettingMgr then
			for i = 1, 6 do
				if BaseSettingMgr:getTeamEnable(i) then
					num = num + 1
				end
			end
			-- num = BaseSettingMgr:getEnabledTeamsNum(); -- 这个接口获取的数据不准确
		end

		return num;
	end,

	getEnabledTeamIdByIndex = function(self, index)
		local BaseSettingMgr = self:getBaseSettingMgr();
		local TeamId = 0;
		if BaseSettingMgr then
			TeamId = BaseSettingMgr:getEnabledTeamIdByIndex(index);
		end

		return TeamId;
	end,

	getIndexByTeamId = function(self, teamId)
		local BaseSettingMgr = self:getBaseSettingMgr();
		local index = 0;
		if BaseSettingMgr then
			index = BaseSettingMgr:getIndexByTeamId(teamId);
		end

		return index;
	end,

	getColorCfgByIndex = function(self, index)
		local TeamId = self:getEnabledTeamIdByIndex(index);
		local colorCfg = self.ColorDefine[TeamId + 1];
		return colorCfg;
	end
};

--战场信息面板
function BattleBtn_OnLoad()
	this:RegisterEvent("GE_CUSTOMGAME_STAGE");
end

function BattleBtn_OnEvent()
	if arg1 == "GE_CUSTOMGAME_STAGE" then
		if getglobal("BattleBtn"):IsShown() then
			local ge = GameEventQue:getCurEvent();
			local stage = ge.body.cgstage.stage;
			local gametime = ge.body.cgstage.gametime;

			if stage == 3 or stage == 4 then
				if stage == 4 then
					getglobal("BattleBtnTime"):SetText(GetS(3191));
				end

				--击杀数量
				-- local teamNum = ClientCurGame:getNumTeam();
				local teamNum = TeamSetterCtrl:getTeamsNum();
				if teamNum == 0 or CurMainPlayer:getTeam() == 0 then	--无队伍
					local score = ClientCurGame:getTeamScore(0);
					getglobal("BattleBtnScore1"):SetText(score);
					getglobal("BattleBtnScore1"):SetTextColor(255, 249, 235);
				else
					for i = 1, teamNum do
						local scoreFont = getglobal("BattleBtnScore"..i);
						local teamId = TeamSetterCtrl:getEnabledTeamIdByIndex(i);
						-- local score = ClientCurGame:getTeamScore(i);
						local score = ClientCurGame:getTeamScore(teamId);
						local colorCfg = TeamSetterCtrl:getColorCfgByIndex(i);

						scoreFont:SetText(score);
						scoreFont:SetTextColor(colorCfg.r, colorCfg.g, colorCfg.b);
					end
				end

				if stage == 4 and gametime ~= 0 then return end
				if stage ~= 4 then
					local s = CurWorld:getCustonGameTime();
					local timeText = "";
					if s == 0 then
						timeText = GetS(680);
					else
						s = s - math.floor(ge.body.cgstage.gametime/20);
						local min = math.floor(s/60);
						s = s - min*60;
						timeText = min.."m"..s.."s";
					end

					getglobal("BattleBtnTime"):SetText(timeText);
				end
			else
				getglobal("BattleBtnTime"):SetText(GetS(741));
				-- local teamNum = ClientCurGame:getNumTeam();
				local teamNum = TeamSetterCtrl:getTeamsNum();
				if teamNum == 0 or CurMainPlayer:getTeam() == 0 then	--无队伍
					local score = ClientCurGame:getTeamScore(0);
					getglobal("BattleBtnScore1"):SetText(score);
					getglobal("BattleBtnScore1"):SetTextColor(255, 249, 235);
				else
					for i=1, teamNum do
						local scoreFont = getglobal("BattleBtnScore"..i);
						local score = ClientCurGame:getTeamScore(i);
						local colorCfg = TeamSetterCtrl:getColorCfgByIndex(i);

						scoreFont:SetText(score);
						scoreFont:SetTextColor(colorCfg.r, colorCfg.g, colorCfg.b);
					end
				end
			end

			-- local teamNum = TeamSetterCtrl:getTeamsNum();
			-- local teamId = CurMainPlayer:getTeam();
			-- if teamId <= 0 then teamId = 0 end
			-- if teamId >= teamNum then teamId = teamNum end
			-- local score = ClientCurGame:getTeamScore(teamId);
			-- GetInst("WeekendCarnivalMgr"):updateTeamScore(score)
			
			local myBriefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
			if myBriefInfo ~= nil and  myBriefInfo.teamid ~= 999 then
				local score = myBriefInfo.cgamevar and  myBriefInfo.cgamevar[0] or 0
				GetInst("WeekendCarnivalMgr"):updateTeamScore(score)
			end
		end
	end
end

function BattleBtn_OnShow()
	getglobal("BattleBtn"):SetFrameStrataInt(2);
	getglobal("BattleBtn"):SetFrameLevel(3000);
	getglobal("BattleBtnTime"):Show();

	for i=1, Team_Max_Num do
		local scoreFont = getglobal("BattleBtnScore"..i);
		scoreFont:SetText("0");
	end
	local type = ClientCurGame and ClientCurGame.getRuleOptionVal and ClientCurGame:getRuleOptionVal(22);	--时间结束的胜负
	if type == 0 then
		getglobal("BattleBtnTime"):SetTextColor(255, 255, 255);
	elseif type == 1 then
		getglobal("BattleBtnTime"):SetTextColor(0, 255, 0);
	elseif type == 2 then
		getglobal("BattleBtnTime"):SetTextColor(255, 0, 0);
	end
	getglobal("BattleBtnTime"):SetText("0");
end

function BattleBtn_OnClick()
	if getglobal("BattleFrame"):IsShown() then
		getglobal("BattleFrame"):Hide();
	else
		getglobal("BattleFrame"):Show();
		if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
			standReportEvent("1003", "SCORE_BOARD", "-", "view")
		else
			standReportEvent("1001", "SCORE_BOARD", "-", "view")
		end
	end

	if getglobal("BattleEndFrameScoreboardBtnUvA"):IsShown() then
		getglobal("BattleEndFrameScoreboardBtnUvA"):Hide();
	end
end

------------------------------------BattlePrepareFrame----------------------------------------------------------------
function BattlePrepareFrameStartGame_OnClick()
	ClientCurGame:hostStartGame();
end

function BattlePrepareFrame_OnLoad()
	this:setUpdateTime(0.1);
end

function BattlePrepareFrame_OnUpdate()
	if BattleCoundBlinkingTime > 0 then
		 if getglobal("BattlePrepareFrameTips"):IsShown() then
		 	getglobal("BattlePrepareFrameTips"):Hide();
		 else
		 	getglobal("BattlePrepareFrameTips"):Show();
		 end

		 BattleCoundBlinkingTime = BattleCoundBlinkingTime-1;
	end
end

function BattlePrepareFrame_OnShow()
	InitBattlePrepareFrame();
end

function InitBattlePrepareFrame()
	local num = ClientCurGame:getRuleOptionVal(11); -- 开启人数
	getglobal("BattlePrepareFrameStartMinimum"):SetText(GetS(1339, num));
	getglobal("BattlePrepareFrameTips"):SetText(GetS(1343));
	getglobal("BattlePrepareFrameStartGame"):Hide();
	OnChangeNumOfPlayers();
end

function GetCurRoomPlayerNum()
	local myBriefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
	local num = myBriefInfo.teamid == 999 and 0 or 1; --裁判不算玩家人数

	local playernum = ClientCurGame:getNumPlayerBriefInfo();
	for i = 1, playernum do
		local BriefInfo = ClientCurGame:getPlayerBriefInfo(i-1);
		if BriefInfo ~= nil and BriefInfo.teamid ~= 999 then
			num = num + 1;
		end
	end

	return num;
end

function OnChangeNumOfPlayers(playerNum)
	if getglobal("BattlePrepareFrame"):IsShown() then
		local num = GetCurRoomPlayerNum();	--房间现有人数
		num = playerNum or num
		getglobal("BattlePrepareFramePlayersNum"):SetText(GetS(1340, num, ClientCurGame:getMaxPlayerNum()));

		if ClientCurGame:getGameStage() > 1 or ClientCurGame:getRuleOptionVal(10) ~= 0 then return end 	--非准备阶段或不是房主开启房间

		if num >= ClientCurGame:getRuleOptionVal(11) then	--人满了
			if IsRoomOwner() or IsCloudServerRoomOwner() then
				if not getglobal("BattlePrepareFrameStartGame"):IsShown() then
					getglobal("BattlePrepareFrameTips"):SetText("");
					getglobal("BattlePrepareFrameStartGame"):Show();

					NeedOpenMakerRunGame = true;
					getglobal("OpenGame"):Show();
				end
			else
				getglobal("BattlePrepareFrameTips"):SetText(GetS(1341));
			end
		elseif num < ClientCurGame:getRuleOptionVal(11) then 	--人数不足
			if IsRoomOwner() or IsCloudServerRoomOwner() then
				if getglobal("BattlePrepareFrameStartGame"):IsShown() then
					getglobal("BattlePrepareFrameTips"):SetText(GetS(1343));
					getglobal("BattlePrepareFrameStartGame"):Hide();

					NeedOpenMakerRunGame = false;
					getglobal("OpenGame"):Hide();
				end
			else
				getglobal("BattlePrepareFrameTips"):SetText(GetS(1343));
			end
		end
	end
end

function OnChangeGameStage(stage)
	print("kekeke OnChangeGameStage", stage);
	if stage == 3 then --游戏开启阶段
		getglobal("BattlePrepareFrame"):Hide();

		threadpool:work(function ()
			local tryTime = 10;
			while not ClientCurGame.getRuleOptionVal and tryTime > 0 do
				threadpool:wait(1);
				tryTime = tryTime - 1;
			end

			if IsShowBattleBtn() and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.SCORE) then--xyang自定义UI
				getglobal("BattleBtn"):Show();
				SetBattleBtn();
			end
		end)

	end

	if stage > 1 and NeedOpenMakerRunGame and getglobal("OpenGame"):IsShown() then
		NeedOpenMakerRunGame = false;
		getglobal("OpenGame"):Hide();
	end
end
-----------------------------------------------------------------------------------------------------------------------

function PlayerBuff_OnLoad()
	this:setUpdateTime(0.05);
	for i=1, 5 do
		local buffBtn = getglobal("PlayerBuff"..i);
		buffBtn:SetPoint("topleft", "PlayerBuff", "PlayerBuff", (i-1)*50, 0);
	end
end

function PlayerBuff_OnUpdate()
	ride = CurMainPlayer:getRidingHorse();
	local buffnum = 0;
	local attrib = nil;
	local ridebuffnum = 0;
	local rideAttrib = nil;
	if MainPlayerAttrib and MainPlayerAttrib:getBuffNum() > 0 then
		buffnum = MainPlayerAttrib:getBuffNum();
		attrib = MainPlayerAttrib;
	end

	if ride and ride:getLivingAttrib() and ride:getLivingAttrib():getBuffNum()>0 then
		ridebuffnum = ride:getLivingAttrib():getBuffNum();
		rideAttrib = ride:getLivingAttrib();
	end
	if (buffnum+ridebuffnum) < 1 then
		for i=1, 5 do
			local buffBtn = getglobal("PlayerBuff"..i);
			if buffBtn:IsShown() then
				buffBtn:Hide();
			end
		end
		if getglobal("PlayerBuffMore"):IsShown() then
			getglobal("PlayerBuffMore"):Hide();
		end

		if getglobal("BuffFrame"):IsShown() then
			getglobal("BuffFrame"):Hide();
		end

	--	getglobal("PlayerHungerBar"):ShowSpecialIcon(false);
		StarveBuffChange(false);
	 	return;
	end

	local t_buff = {};
	local t_buffScript = {};
	for i=1, buffnum do
		if attrib then
			local info = attrib:getBuffInfo(i-1);
			--装备的buff不显示
			if info and info.def and info.def.BuffType == 1 then
				local time = math.ceil( info.ticks*0.05 );
				table.insert(t_buff, {iconName=info.def.IconName, remaintime=time, buffid = info.def.ID})

				if info.def.ScriptName ~= nil and info.def.ScriptName ~= "" then
					table.insert(t_buffScript, info.def.ScriptName);
				end
			end
		end
	end

	for i=1, ridebuffnum do
		if rideAttrib then
			local info = rideAttrib:getBuffInfo(i-1);
			--装备的buff不显示
			if info and info.def and info.def.BuffType == 1 then
				local time = math.ceil( info.ticks*0.05 );
				table.insert(t_buff, {iconName=info.def.IconName, remaintime=time, buffid = info.def.ID})

				if info.def.ScriptName ~= nil and info.def.ScriptName ~= "" then
					table.insert(t_buffScript, info.def.ScriptName);
				end
			end
		end
	end

	for i=1, 5 do
		local buffBtn = getglobal("PlayerBuff"..i);
		if i<=#(t_buff) then
			if t_buff[i].iconName ~= '' or SingleEditorFrame_Switch_New then
				if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.BLOOD) then--xyang自定义UI
					buffBtn:Show();
				end
				local icon = getglobal("PlayerBuff"..i.."Icon");
				local time  = getglobal("PlayerBuff"..i.."RemainTime");

				local timetext = t_buff[i].remaintime.."s";
				if t_buff[i].remaintime > 60 then
					if t_buff[i].remaintime >= 9999 then
						timetext = GetS(1350);
					else
						timetext = math.floor(t_buff[i].remaintime/60).."m";
					end
				end
				time:SetText(timetext);

				if SingleEditorFrame_Switch_New then
					local path = GetInst("ModsLibDataManager"):GetStatusIconPath(t_buff[i].buffid);
					icon:SetTexture(path, true)
				else
					icon:SetTexture("ui/bufficons/"..t_buff[i].iconName..".png");
				end
			else
				buffBtn:Hide();
			end
		else
			buffBtn:Hide();
		end
	end

	--创造模式下隐藏buff按钮
	if CurWorld:isCreativeMode() then
		for i=1, 5 do
			local buffBtn = getglobal("PlayerBuff"..i);
			buffBtn:Hide();
		end
	end

	if #(t_buff) > 5 then
		getglobal("PlayerBuffMore"):Show();
	else
		getglobal("PlayerBuffMore"):Hide();
	end

	local hasStarveBuff = false;
	for i=1, #(t_buffScript) do
		if string.find(t_buffScript[i], "StarveBuff") then
			hasStarveBuff = true;
		end
	end
	--[[
	if hasStarveBuff then
		getglobal("PlayerHungerBar"):ShowSpecialIcon(true);
	else
		getglobal("PlayerHungerBar"):ShowSpecialIcon(false);
	end
	]]
	if UseNewModsLib then return end
	StarveBuffChange(hasStarveBuff);
end

function StarveBuffChange(hasStarveBuff)
	local hpWidth = getglobal("PlayerHPBarCur"):GetWidth();
	local foodWidth = getglobal("PlayerHungerBarCur"):GetWidth();

	if hasStarveBuff then
		getglobal("PlayerHPBarIcon"):SetTexUV("icon_heart");
		getglobal("PlayerHPBarCur"):SetTexUV("img_blood_strip_red");

		getglobal("PlayerHungerBarIcon"):SetTexUV("icon_chicken_leg");
		getglobal("PlayerHungerBarCur"):SetTexUV("img_blood_strip_yellow");
	else
		getglobal("PlayerHPBarIcon"):SetTexUV("icon_heart");
		getglobal("PlayerHPBarCur"):SetTexUV("img_blood_strip_red");

		getglobal("PlayerHungerBarIcon"):SetTexUV("icon_chicken_leg");
		getglobal("PlayerHungerBarCur"):SetTexUV("img_blood_strip_yellow");
	end
	getglobal("PlayerHPBarCur"):ChangeTexUVWidth(hpWidth);
	getglobal("PlayerHungerBarCur"):ChangeTexUVWidth(foodWidth);
end

function PlayerBuff_OnClick()
	local BuffFrame = getglobal("BuffFrame")
	if BuffFrame:IsShown() then
		BuffFrame:Hide();
	else
		BuffFrame:Show();
	end
end

-------------------------------------------------------------------------
local HP = ComplexAnimatorFactory:newOverflowBarAnimator();
PlayMain.HP = HP;

function HP:onLoad()
	this:RegisterEvent("GE_PLAYERATTR_CHANGE");
	this:RegisterEvent("GE_PLAYERATTR_RESET");
	self:AddGameEvent()

	this:setUpdateTime(0.05);

	self:setBarUI("PlayerHPBarBkg");
	self:setCurValueUI("PlayerHPBarCur");
	self:setLossValueUI("PlayerHPBarLoss");
	self:setOverflowValueUI("PlayerHPBarOverflow");
	self:setCurOverflowValueUI("PlayerHPBarCurOverflow");
	self:setCursorUI("PlayerHPBarCursor");

	self:setMin(0);
	self:setValueChangeCount(10);

	-- self:debug(true);

	self.ui = getglobal("PlayerHPBar")
	self.fsLifeNum = getglobal("PlayerHPBarLifeNum")
	self.fsRatio = getglobal("PlayerHPBarRatio")
end

function HP:AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.PlayerAttrChange,function(context)
		self:change();
	end)
end

function HP:onEvent()
	if arg1 == "GE_PLAYERATTR_CHANGE" then
		self:change();
	elseif arg1 == "GE_PLAYERATTR_RESET" then
		self:reset();
	end
end

function HP:change()
	if not MainPlayerAttrib then return end

	local ceil = math.ceil
	local floor = math.floor
	local cur = MainPlayerAttrib:getHP();
	local max = MainPlayerAttrib:getMaxHP();
	local overflow = MainPlayerAttrib:getOverflowHP();

	self:setMax(ceil(max));
	self:set(floor(cur));
	self:setOverflow(ceil(overflow));

	-- print("HP:change(): " + self.m_iOld + " -> " + self.m_iCur + " | " + cur + " | " + self.m_bIsAnimating);

	local szFormat = "%d/%d"
	local szRatio
	if cur <= 0.001 then
		cur = 0;
	end
	if cur < 1 then
		cur = ceil(cur);
	else
		cur = floor(cur);
	end

	if LuaInterface and LuaInterface:shouldUseNewHpRule() then
		local curArmor = CurMainPlayer:getArmor();
		local armor = 0;
		local armorUi = getglobal("PlayerArmorBarRatio");
		if curArmor < 1 then
			armor = ceil(curArmor);
		else
			armor = floor(curArmor);
		end
		armorUi:Hide();
		-- if armor > 0 and armorUi then
		-- 	armorUi:Show();
		-- 	armorUi:SetText(string.format("%d(+%d)", cur, armor));
		-- 	self.fsRatio:SetText("");
		-- else
		-- 	armorUi:Hide();
		-- 	self.fsRatio:SetText(cur);
		-- end
		if armor > 0 then
			self.fsRatio:SetText(string.format("%d(+%d)", cur, armor));
		else
			self.fsRatio:SetText(floor(cur));
		end
	else
		szRatio = szFormat:format(cur, ceil(max));
		self.fsRatio:SetText(szRatio);
	end


	local lifeNum = CurMainPlayer:getLeftLifeNum();
	if lifeNum >= 0 then
		self.fsLifeNum:SetText(CurMainPlayer:getLeftLifeNum());
	else
		self.fsLifeNum:SetText("");
	end

	self:notifyChange();
end

-------------------------------------------------------------------------

local Strength = ComplexAnimatorFactory:newOverflowBarAnimator();
PlayMain.Strength = Strength;

function Strength:onLoad()
	this:RegisterEvent("GE_PLAYERATTR_CHANGE");
	this:RegisterEvent("GE_PLAYERATTR_RESET");
	this:RegisterEvent("GE_FLASH_EXHAUSTION_WARNING");
	self:AddGameEvent()
	this:setUpdateTime(0.05);

	self:setBarUI("PlayerStrengthBarBkg");
	self:setCurValueUI("PlayerStrengthBarCur");
	self:setLossValueUI("PlayerStrengthBarLoss");
	self:setOverflowValueUI("PlayerStrengthBarOverflow");
	self:setCurOverflowValueUI("PlayerStrengthBarCurOverflow");
	self:setCursorUI("PlayerStrengthBarCursor");

	self:setMin(0);
	self:setValueChangeCount(10);

	-- self:debug(true);

	self.fsRatio = getglobal("PlayerStrengthBarRatio")
	self.texExhaustionWarning = getglobal("PlayerStrengthBarExhaustionWarning")
	self.texCur = getglobal("PlayerStrengthBarCur")

	self.CurColorAnimator = AnimatorFactory:newColorAnimator(self)
		:setRepeatCount(99999)
		:setReverseMode(true)
		:setDuration(1)
		:setOldRGB(255, 255, 255)
		:setNewRGB(255, 100, 100)
		-- :debug(true)
		:setUI(self.texCur)

	self.ExhaustionWarningAnimator = AnimatorFactory:newAlphaAnimator(self)
		:setRepeatCount(4)
		:setReverseMode(true)
		:setDuration(0.5)
		:setAlphaFrom(0)
		:setAlphaTo(1)
		-- :debug(true)
		:setUI(self.texExhaustionWarning)

end

function Strength:onUpdate()
	self.super.onTick(self);
	self.CurColorAnimator:onUpdate(arg1)
	self.ExhaustionWarningAnimator:onUpdate(arg1);
end

function Strength:AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.PlayerAttrChange,function(context)
		self:change();
	end)
end

function Strength:onEvent()
	if arg1 == "GE_PLAYERATTR_CHANGE" then
		self:change();
	elseif arg1 == "GE_PLAYERATTR_RESET" then
		self:reset();
	elseif arg1 == "GE_FLASH_EXHAUSTION_WARNING" then
		self:flashExhaustionWarning();
	end
end

function Strength:onAnimationEnd(Animator)
	if Animator == self.ExhaustionWarningAnimator then
		self.texExhaustionWarning:Hide();
	end
end

function Strength:onAnimationCancel(Animator)
	if Animator == self.CurColorAnimator then
		self.texCur:SetColor(255, 255, 255);
	end
end

function Strength:change()
	if not MainPlayerAttrib then return end
	-- print("Strength:change(): m_iOld = " + self.m_iOld + " | m_iCur = " + self.m_iCur);

	local ceil = math.ceil
	local floor = math.floor
	local cur = MainPlayerAttrib:getStrength();
	local max = MainPlayerAttrib:getMaxStrength();
	local overflow = MainPlayerAttrib:getOverflowStrength();

	self:set(floor(cur));
	self:setMax(ceil(max));
	self:setOverflow(ceil(overflow));

	local szRatio
	if cur <= 0.001 then
		cur = 0;
	end
	if LuaInterface and LuaInterface:shouldUseNewHpRule() then
		local curPerseverance = CurMainPlayer:getPerseverance();
		local Perseverance = 0;
		local PerseveranceUi = getglobal("PlayerPerseveranceBarRatio");
		if curPerseverance < 1 then
			Perseverance = ceil(curPerseverance);
		else
			Perseverance = floor(curPerseverance);
		end
		PerseveranceUi:Hide();
		-- if Perseverance > 0 and PerseveranceUi then
		-- 	PerseveranceUi:Show();
		-- 	PerseveranceUi:SetText(string.format("%d(+%d)", floor(cur), Perseverance));
		-- 	self.fsRatio:SetText("");
		-- else
		-- 	PerseveranceUi:Hide();
		-- 	self.fsRatio:SetText(floor(cur));
		-- end
		if Perseverance > 0 then
			self.fsRatio:SetText(string.format("%d(+%d)", floor(cur), Perseverance));
		else
			self.fsRatio:SetText(floor(cur));
		end
	else
		szRatio = string.format("%d/%d", floor(cur), ceil(max + overflow));
		self.fsRatio:SetText(szRatio);
	end

	if MainPlayerAttrib:isExhausted() then
		self.texCur:SetTexUV("img_blood_strip_yellow_h.png");
		if not self.CurColorAnimator:isAnimating() then
			self.CurColorAnimator:start();
		end
	else
		self.texCur:SetTexUV("img_blood_strip_yellow.png");
		self.CurColorAnimator:cancel();
	end

	self:notifyChange();
end

function Strength:flashExhaustionWarning()
	if not MainPlayerAttrib:isExhausted() then
		self.texExhaustionWarning:Hide();
		if self.ExhaustionWarningAnimator:isAnimating() then
			self.ExhaustionWarningAnimator:cancel();
		end
		return
	end

	if self.ExhaustionWarningAnimator:isAnimating() then
		return
	end
	
	-- ShowGameTips(GetS(1571));
	self.texExhaustionWarning:Show();
	self.ExhaustionWarningAnimator:start();
end
-------------------------------------------------------------------------
local ArmorAnim = ComplexAnimatorFactory:newOverflowBarAnimator();
PlayMain.ArmorAnim = ArmorAnim;

function ArmorAnim:onLoad()
	this:RegisterEvent("GE_PLAYERATTR_CHANGE");
	this:RegisterEvent("GE_PLAYERATTR_RESET");
	this:setUpdateTime(0.05);

	self:setBarUI("PlayerArmorBarBkg");
	self:setCurValueUI("PlayerArmorBarCur");
	self:setLossValueUI("PlayerArmorBarLoss");
	self:setOverflowValueUI("PlayerArmorBarOverflow");
	self:setCurOverflowValueUI("PlayerArmorBarCurOverflow");
	self:setCursorUI("PlayerArmorBarCursor");

	self:setMin(0);
	self:setValueChangeCount(10);

	--self:debug(true);

	self.ui = getglobal("PlayerArmorBar")
	self.fsRatio = getglobal("PlayerArmorBarRatio")
	
	this:RegisterEvent("GE_PLAYERATTR_CHANGE");
	getglobal("PlayerArmorBarBkg"):Hide();
	getglobal("PlayerArmorBarIcon"):Hide();
	getglobal("PlayerArmorBarRatio"):Hide();
end

function ArmorAnim:onEvent()
	if arg1 == "GE_PLAYERATTR_CHANGE" then
		self:change();
	elseif arg1 == "GE_PLAYERATTR_RESET" then
		self:reset();
	end
end

function ArmorAnim:change()
	if not CurMainPlayer then return end
	local ceil = math.ceil
	local floor = math.floor
	local cur = CurMainPlayer:getArmor();
	local max = 100;
	local overflow = 0;

	self:set(floor(cur));
	self:setMax(ceil(max));
	self:setOverflow(ceil(overflow));

	-- print("RideHP:change(): " + self.m_iOld + " -> " + self.m_iCur + " | " + cur + " | " + self.m_bIsAnimating);

	local szFormat = "%d/%d"
	local szRatio
	if cur <= 0.001 then
		cur = 0;
	end
	-- if cur < 1 then
	-- 	szRatio = szFormat:format(ceil(cur), ceil(max));
	-- else
	-- 	szRatio = szFormat:format(floor(cur), ceil(max));
	-- end
	-- if cur < 1 then
	-- 	szRatio = ceil(cur);
	-- else
	-- 	szRatio = floor(cur);
	-- end
	-- self.fsRatio:SetText(szRatio);

	self:notifyChange();
end

-------------------------------------------------------------------------
local PerseveranceAnim = ComplexAnimatorFactory:newOverflowBarAnimator();
PlayMain.PerseveranceAnim = PerseveranceAnim;

function PerseveranceAnim:onLoad()
	this:RegisterEvent("GE_PLAYERATTR_CHANGE");
	this:RegisterEvent("GE_PLAYERATTR_RESET");
	this:setUpdateTime(0.05);

	self:setBarUI("PlayerPerseveranceBarBkg");
	self:setCurValueUI("PlayerPerseveranceBarCur");
	self:setLossValueUI("PlayerPerseveranceBarLoss");
	self:setOverflowValueUI("PlayerPerseveranceBarOverflow");
	self:setCurOverflowValueUI("PlayerPerseveranceBarCurOverflow");
	self:setCursorUI("PlayerPerseveranceBarCursor");

	self:setMin(0);
	self:setValueChangeCount(10);

	--self:debug(true);

	self.ui = getglobal("PlayerPerseveranceBar")
	self.fsRatio = getglobal("PlayerPerseveranceBarRatio")
	
	this:RegisterEvent("GE_PLAYERATTR_CHANGE");
	getglobal("PlayerPerseveranceBarBkg"):Hide();
	getglobal("PlayerPerseveranceBarIcon"):Hide();
	getglobal("PlayerPerseveranceBarRatio"):Hide();
end

function PerseveranceAnim:onEvent()
	if arg1 == "GE_PLAYERATTR_CHANGE" then
		self:change();
	elseif arg1 == "GE_PLAYERATTR_RESET" then
		self:reset();
	end
end

function PerseveranceAnim:change()
	if not CurMainPlayer then return end
	local ceil = math.ceil
	local floor = math.floor
	local cur = CurMainPlayer:getPerseverance();
	local max = 100;
	local overflow = 0;

	self:set(floor(cur));
	self:setMax(ceil(max));
	self:setOverflow(ceil(overflow));

	-- print("RideHP:change(): " + self.m_iOld + " -> " + self.m_iCur + " | " + cur + " | " + self.m_bIsAnimating);

	local szFormat = "%d/%d"
	local szRatio
	if cur <= 0.001 then
		cur = 0;
	end
	-- if cur < 1 then
	-- 	szRatio = szFormat:format(ceil(cur), ceil(max));
	-- else
	-- 	szRatio = szFormat:format(floor(cur), ceil(max));
	-- end
	-- if cur < 1 then
	-- 	szRatio = ceil(cur);
	-- else
	-- 	szRatio = floor(cur);
	-- end
	-- self.fsRatio:SetText(szRatio);

	self:notifyChange();
end
-------------------------------------------------------------------------
local RideHP = ComplexAnimatorFactory:newOverflowBarAnimator();
PlayMain.RideHP = RideHP;

function RideHP:onLoad()
	this:RegisterEvent("GE_PLAYERATTR_CHANGE");
	this:RegisterEvent("GE_PLAYERATTR_RESET");
	self:AddGameEvent()
	this:setUpdateTime(0.05);

	self:setBarUI("RideHPBarBkg");
	self:setCurValueUI("RideHPBarCur");
	self:setLossValueUI("RideHPBarLoss");
	self:setOverflowValueUI("RideHPBarOverflow");
	self:setCurOverflowValueUI("RideHPBarCurOverflow");
	self:setCursorUI("RideHPBarCursor");

	self:setMin(0);
	self:setValueChangeCount(10);

	self:debug(true);

	self.ui = getglobal("RideHPBar")
	self.fsRatio = getglobal("RideHPBarRatio")

end

function RideHP:AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.PlayerAttrChange,function(context)
		self:change();
	end)
end

function RideHP:onEvent()
	if arg1 == "GE_PLAYERATTR_CHANGE" then
		self:change();
	elseif arg1 == "GE_PLAYERATTR_RESET" then
		self:reset();
	end
end

function RideHP:change()
	if not CurMainPlayer then return end
	local ride = CurMainPlayer:getRidingHorse();
	if ride == nil then 
		return 
	end

	local ceil = math.ceil
	local floor = math.floor
	local cur = ride:getMobAttrib():getHP();
	local max = ride:getMobAttrib():getMaxHP();
	local overflow = 0;

	self:set(floor(cur));
	self:setMax(ceil(max));
	self:setOverflow(ceil(overflow));

	-- print("RideHP:change(): " + self.m_iOld + " -> " + self.m_iCur + " | " + cur + " | " + self.m_bIsAnimating);

	local szFormat = "%d/%d"
	local szRatio
	if cur <= 0.001 then
		cur = 0;
	end
	if cur < 1 then
		szRatio = szFormat:format(ceil(cur), ceil(max));
	else
		szRatio = szFormat:format(floor(cur), ceil(max));
	end
	self.fsRatio:SetText(szRatio);

	self:notifyChange();
end


-------------------------------------------------------------------------
function RideChargeFrame_OnLoad()
	this:RegisterEvent("GE_PLAYERATTR_CHANGE");
	RideChargeFrame_AddGameEvent()
	for i=1, 5 do
		local line = getglobal("RideChargeFrameLine"..i);
		if ClientMgr:isPC() then
			line:SetSize(4, 14);
			line:SetPoint("lefe", "RideChargeFrameBkg", "left", 37+(i-1)*27, -9);
		else
			line:SetSize(4, 19);
			line:SetPoint("lefe", "RideChargeFrameBkg", "left", 48+(i-1)*43, -10);
		end

		local line = getglobal("BallChargeFrameLine"..i);
		if ClientMgr:isPC() then
			line:SetSize(4, 14);
			line:SetPoint("lefe", "BallChargeFrameBkg", "left", 37+(i-1)*27, -8);
		else
			line:SetSize(4, 19);
			line:SetPoint("lefe", "BallChargeFrameBkg", "left", 48+(i-1)*43, -10);
		end
	end

end

function RideChargeFrame_AddGameEvent()

	SubscribeGameEvent(nil,GameEventType.PlayerAttrChange,function(context)
		local width = 163;
		local height = 14;
		if ClientMgr:isMobile() then
			width = 257;
			height = 17;
		end
		ride = CurMainPlayer:getRidingHorse();
		if ride ~= nil then
			local curCharge = ride:getCurCharge();
			local maxCharge = ride:getMaxCharge();
			local ratio = curCharge/maxCharge;
			if curCharge > 0 and not getglobal("CharacterActionFrame"):IsShown() then
				getglobal("RideChargeFrame"):Show();
			else
				getglobal("RideChargeFrame"):Hide();
			end

			local chargeUI = getglobal("RideChargeFrameCharge");
			local  isShowLine = true;
			--local triggerSkillChargeRatio = 0.67;
			--if ratio >= triggerSkillChargeRatio then

			-- 竹蜻蜓
			local bambo = false
			if ride:getHorseDef().ID == 4509 or ride:getHorseDef().ID == 4510 then
				if ride:getBamboDragonFlyState() == 1 or ratio == 1 then
					bambo = true
				end
				if ride:getBamboDragonFlyState() == 0 and ratio == 1 then
					getglobal("RideChargeFrame"):Hide()
				elseif not getglobal("CharacterActionFrame"):IsShown() then
					getglobal("RideChargeFrame"):Show()
				end
			end

			if ride:isTriggerSkillCharge() or bambo then
				chargeUI:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
				chargeUI:SetTexUV("sjb_jindu.png");
				isShowLine = false or bambo;
			else
				chargeUI:SetTextureHuiresXml("ui/mobile/texture2/old_operateframe.xml");
				chargeUI:SetTexUV("04.png");
			end


			for i=1, 5 do
				local line = getglobal("RideChargeFrameLine"..i);
				if isShowLine then
					line:Show();
				else
					line:Hide();
				end
			end

			getglobal("RideChargeFrameCharge"):ChangeTexUVWidth(ratio*257);
			getglobal("RideChargeFrameCharge"):SetSize(ratio*width, height);
			getglobal("RideChargeFrameChargeShield"):ChangeTexUVWidth(ratio*257);
			if ride:getShieldCoolingTicks() <= 0 then
				local shieldSize = ratio*width > 60 and 60 or ratio*width;
				getglobal("RideChargeFrameChargeShield"):SetSize(shieldSize, height);
			else
				getglobal("RideChargeFrameChargeShield"):SetSize(0, height);
			end

		else
			if getglobal("RideChargeFrame"):IsShown() then
				getglobal("RideChargeFrame"):Hide();
			end
		end
	end)

end

function RideChargeFrame_OnEvent()
	if not CurMainPlayer then return end
	local width = 163;
	local height = 14;
	if ClientMgr:isMobile() then
		width = 257;
		height = 17;
	end


	if arg1 == "GE_PLAYERATTR_CHANGE" then
		ride = CurMainPlayer:getRidingHorse();
		if ride ~= nil then
			local curCharge = ride:getCurCharge();
			local maxCharge = ride:getMaxCharge();
			local ratio = curCharge/maxCharge;
			if curCharge > 0 and not getglobal("CharacterActionFrame"):IsShown() then
				getglobal("RideChargeFrame"):Show();
			else
				getglobal("RideChargeFrame"):Hide();
			end

			local chargeUI = getglobal("RideChargeFrameCharge");
			local  isShowLine = true;
			--local triggerSkillChargeRatio = 0.67;
			--if ratio >= triggerSkillChargeRatio then

			-- 竹蜻蜓
			local bambo = false
			if ride:getHorseDef().ID == 4509 or ride:getHorseDef().ID == 4510 then
				if ride:getBamboDragonFlyState() == 1 or ratio == 1 then
					bambo = true
				end
				if ride:getBamboDragonFlyState() == 0 and ratio == 1 then
					getglobal("RideChargeFrame"):Hide()
				elseif not getglobal("CharacterActionFrame"):IsShown() then
					getglobal("RideChargeFrame"):Show()
				end
			end

			if ride:isTriggerSkillCharge() or bambo then
				chargeUI:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
				chargeUI:SetTexUV("sjb_jindu.png");
				isShowLine = false or bambo;
			else
				chargeUI:SetTextureHuiresXml("ui/mobile/texture2/old_operateframe.xml");
				chargeUI:SetTexUV("04.png");
			end


			for i=1, 5 do
				local line = getglobal("RideChargeFrameLine"..i);
				if isShowLine then
					line:Show();
				else
					line:Hide();
				end
			end

			getglobal("RideChargeFrameCharge"):ChangeTexUVWidth(ratio*257);
			getglobal("RideChargeFrameCharge"):SetSize(ratio*width, height);
			getglobal("RideChargeFrameChargeShield"):ChangeTexUVWidth(ratio*257);
			if ride:getShieldCoolingTicks() <= 0 then
				local shieldSize = ratio*width > 60 and 60 or ratio*width;
				getglobal("RideChargeFrameChargeShield"):SetSize(shieldSize, height);
			else
				getglobal("RideChargeFrameChargeShield"):SetSize(0, height);
			end

		else
			if getglobal("RideChargeFrame"):IsShown() then
				getglobal("RideChargeFrame"):Hide();
			end
		end
	end
end
-------------------------------------------------------------------------
function OnBallChargeChange(charge)
	local width = 168;
	local height = 14;
	if ClientMgr:isMobile() then
		width = 257;
		height = 17;
	end

	local ratio = charge/100;
	charge = charge == 0 and 1 or charge;
	if charge > 0 and not getglobal("CharacterActionFrame"):IsShown() then
		getglobal("BallChargeFrame"):Show();
		getglobal("BallChargeFrameAimRegion"):Hide();
		getglobal("BallChargeFrameAimRegionBg"):Hide();
		getglobal("BallChargeFrameCharge"):ChangeTexUVWidth(ratio*257);
		getglobal("BallChargeFrameCharge"):SetSize(ratio*width, height);
	else
		getglobal("BallChargeFrame"):Hide();
	end


end

--LLDO:是否在毒气区
function IsInsideStarDuqi()
	if MainPlayerAttrib == nil then return end
	local bRet = true;
	local num = MainPlayerAttrib:getBuffNum();
	Log("IsInsideStarDuqi, num = " .. num);

	for i = 1, num do
		local info = MainPlayerAttrib:getBuffInfo(i-1);
		Log("IsInsideStarDuqi, id = " .. info.buffid);

		if info and info.buffid and (info.buffid == 65 or info.buffid == 66) then
			--氧气区buff
			Log("IsInsideStarDuqi: 1111");
			bRet = false;
			break;
		end
	end

	if true == bRet then
		if CurMainPlayer:isInsideNoOxygenBlock() then
			--在毒气区
			Log("IsInsideStarDuqi: 2222");
			bRet = true;
		else
			bRet = false;
		end
	end

	return bRet;
end

-------------------------------------------------------------------------
function PlayerOxygenPackage_OnLoad()
	local Anim = getglobal("PlayerOxygenPackageBarAnim");
	local AnimRed = getglobal("PlayerOxygenPackageBarAnimRed");
	AnimRed:SetUVAnimation(33, true)
	Anim:SetUVAnimation(83, true)
end

local function isShowOxygenPackage()
	return MainPlayerAttrib:isEquipOxygenpack()
end

local function UpdateOxygenPackageValue()
	if not isShowOxygenPackage() then return false end

	local PlayerOxygenPackageBar = getglobal("PlayerOxygenPackageBar");
	local redProcess = getglobal("PlayerOxygenPackageBarRed");
	local blueProcess = getglobal("PlayerOxygenPackageBarBlue");
	local ratio = getglobal("PlayerOxygenPackageBarRatio");
	local AnimRed = getglobal("PlayerOxygenPackageBarAnimRed");
	local curvalue = MainPlayerAttrib:getEquipItemDuration(EQUIP_SLOT_TYPE.EQUIP_PIFENG)
	local maxValue = MainPlayerAttrib:getEquipItemMaxDuration(EQUIP_SLOT_TYPE.EQUIP_PIFENG)
	local percent = curvalue/maxValue

	local value = math.floor(percent*100)
	if value <= 30 then
		redProcess:Show()
		AnimRed:Show()
		blueProcess:Hide()
	else
		AnimRed:Hide()
		blueProcess:Show()
		redProcess:Hide()
	end

	local width = 268
	local height = 16

	blueProcess:SetSize(width*percent, height)
	redProcess:SetSize(width*percent, height)
	ratio:SetText(string.format("%d/%d", value, 100))
	
	return true
end



function PlayOxygenBar_OnLoad()
	this:RegisterEvent("GE_PLAYERATTR_CHANGE")
	this:RegisterEvent("GE_SHOW_OXYGEN")
	PlayOxygenBar_AddGameEvent()
end

local isShowOxygen = false;
local forceInWater = false;
local showDuqiIcon = false;

local function updateOxygenValue()
	if not isShowOxygen then return end
	local PlayerOxygenBar = getglobal("PlayerOxygenBar");
	local PlayerDuqiBar = getglobal("PlayerDuqiBar");
	local PlayerOxygenPackageBar = getglobal("PlayerOxygenPackageBar");

	-- Log("MainPlayerAttrib:getOxygen = " .. MainPlayerAttrib:getOxygen());
	PlayerOxygenBar:SetCurValue(MainPlayerAttrib:getOxygen()/10, false);

	--毒气泡
	local value = 10 - MainPlayerAttrib:getOxygen();
	if showDuqiIcon then
		showDuqiIcon = false;
		value = 0;
	end
	PlayerDuqiBar:SetCurValue(value / 10, false);
end

local function checkShowOxygenBarShow()
	local PlayerOxygenBar = getglobal("PlayerOxygenBar");
	local PlayerDuqiBar = getglobal("PlayerDuqiBar");
	local PlayerOxygenPackageBar = getglobal("PlayerOxygenPackageBar");
	local duqizhao = getglobal("StarDuqiZhao");

	local isInLiqiud = false
	if 	CurMainPlayer and 
		(CurMainPlayer:isInWater() or CurMainPlayer:getCurMapID() == BlockUtil.G.MAPID_MENGYANSTAR) 
	then
		isInLiqiud = true
	end

	if isInLiqiud or isShowOxygen then
		if isShowOxygenPackage() then
			PlayerOxygenPackageBar:Show()
			PlayerOxygenBar:Hide()
			PlayerDuqiBar:Hide()
			UpdateOxygenPackageValue();
		else
			PlayerOxygenPackageBar:Hide()
			PlayerOxygenBar:Show();
			PlayerOxygenBar:SetClientUserData(0, 1);

			--LLDO:毒气泡
			if IsInsideStarDuqi() then
				showDuqiIcon = true;
				PlayerDuqiBar:Show();
				PlayerDuqiBar:SetClientUserData(0, 1);
				duqizhao:Show();
			else
				if duqizhao:IsShown() then
					duqizhao:Hide();
				end
			end
			updateOxygenValue()
		end
	else	
		PlayerOxygenPackageBar:Hide()
		PlayerOxygenBar:Hide();
		PlayerOxygenBar:SetClientUserData(0, 0);
		--毒气泡
		PlayerDuqiBar:Hide();
		PlayerDuqiBar:SetClientUserData(0, 0);
		duqizhao:Hide();
	end
end

function PlayOxygenBar_AddGameEvent()
	local PlayerOxygenBar = getglobal("PlayerOxygenBar");
	local PlayerDuqiBar = getglobal("PlayerDuqiBar");
	local duqizhao = getglobal("StarDuqiZhao");
	

	SubscribeGameEvent(nil,GameEventType.PlayerAttrChange,function(context)
		updateOxygenValue()
	end)

	SubscribeGameEvent(nil,GameEventType.ShowOxygen,function(context)
		local paramData = context:GetParamData()
		local isShow = paramData.isShow
		if isShow and not CurWorld:isGodMode()then
			isShowOxygen = true
		else
			isShowOxygen = false
		end
		checkShowOxygenBarShow()
		UpdateGuideSwim(ge.body.oxygen.show);
	end)
end

function PlayerOxygenPackage_OnUpdate()
	checkShowOxygenBarShow()
end

function PlayOxygenBar_OnUpdate()
	checkShowOxygenBarShow()
end

function PlayOxygenBar_OnEvent()
	local PlayerOxygenBar = getglobal("PlayerOxygenBar");
	local PlayerDuqiBar = getglobal("PlayerDuqiBar");
	local duqizhao = getglobal("StarDuqiZhao");

	if arg1 == "GE_PLAYERATTR_CHANGE" then
		updateOxygenValue()
	elseif arg1 == "GE_SHOW_OXYGEN" then
		local ge = GameEventQue:getCurEvent()
		if ge.body.oxygen.show and not CurWorld:isGodMode()then
			isShowOxygen = true
		else
			isShowOxygen = false;
		end
		checkShowOxygenBarShow()
		UpdateGuideSwim(ge.body.oxygen.show);
	end
end

function UpdateGuideSwim(inWater)
	local num = ClientMgr:getGameData("guideswim");
	if num < 3 then
		if ClientMgr:isPC() then
			getglobal("PlayerOxygenBarTips"):SetText(GetS(3560));
		else
			getglobal("PlayerOxygenBarTips"):SetText(GetS(3559));
		end
		getglobal("PlayerOxygenBarTipsBkg"):Show();
		getglobal("PlayerOxygenBarTips"):Show();
	else
		getglobal("PlayerOxygenBarTipsBkg"):Hide();
		getglobal("PlayerOxygenBarTips"):Hide();
	end

	if not inWater then
		if forceInWater and num < 3 then
			num = num + 1;
			ClientMgr:setGameData("guideswim", num);
		end
	else
		forceInWater = true;
	end
end

-------------------------------------------------------------------------
local Hunger = ComplexAnimatorFactory:newOverflowBarAnimator();
PlayMain.Hunger = Hunger;

function Hunger:onLoad()
	this:RegisterEvent("GE_PLAYERATTR_CHANGE");
	this:RegisterEvent("GE_PLAYERATTR_RESET");
	this:RegisterEvent("GE_FLASH_EXHAUSTION_WARNING");
	self:AddGameEvent()
	this:setUpdateTime(0.05);

	self:setBarUI("PlayerHungerBarBkg");
	self:setCurValueUI("PlayerHungerBarCur");
	self:setLossValueUI("PlayerHungerBarLoss");
	self:setOverflowValueUI("PlayerHungerBarOverflow");
	self:setCurOverflowValueUI("PlayerHungerBarCurOverflow");
	self:setCursorUI("PlayerHungerBarCursor");

	self:setMin(0);
	self:setValueChangeCount(10);

	-- self:debug(true);

	self.fsRatio = getglobal("PlayerHungerBarRatio")
end

function Hunger:AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.PlayerAttrChange,function(context)
		self:change();
	end)
end

function Hunger:onEvent()
	if arg1 == "GE_PLAYERATTR_CHANGE" then
		self:change();
	elseif arg1 == "GE_PLAYERATTR_RESET" then
		self:reset();
	end
end

function Hunger:change()
	-- print("Hunger:change(): m_iOld = " + self.m_iOld + " | m_iCur = " + self.m_iCur);
	if not MainPlayerAttrib then return end
	local ceil = math.ceil
	local floor = math.floor
	local cur = MainPlayerAttrib:getFoodLevel();
	local max = MainPlayerAttrib:getFoodMaxLevel();

	self:setMax(ceil(max));
	self:set(floor(cur));

	local szRatio
	if cur <= 0.001 then
		cur = 0;
	end
	szRatio = string.format("%d/%d", floor(cur), ceil(max));
	self.fsRatio:SetText(szRatio);

	self:notifyChange();
end
-------------------------------------------------------------------------

function PlayerExpBarStar_OnClick()
	if IsStandAloneMode() then return end
	if gIsSingleGame then return end
	local StarConvertFrame = getglobal("StarConvertFrame");
	if not StarConvertFrame:IsShown() then
		StarConvertFrame:Show();
	end
end

function PlayerExpBar_OnLoad()
	this:RegisterEvent("GE_PLAYERATTR_CHANGE");
	PlayerExpBar_AddGameEvent()
end

function PlayerExpBar_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.PlayerAttrChange,function(context)
		local exp = MainPlayerAttrib:getExp();

		if exp ~= CurPlayerExpVal then
			SetExpBar();
			CurPlayerExpVal = exp;
		end
	end)
end

function PlayerExpBar_OnEvent()
	if arg1 == "GE_PLAYERATTR_CHANGE" then
		if not MainPlayerAttrib then return end
		local exp = MainPlayerAttrib:getExp();

		if exp ~= CurPlayerExpVal then
			SetExpBar();
			CurPlayerExpVal = exp;
		end
	end
end

function PlayerExpBar_OnShow()
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		getglobal("PlayerExpBar"):Hide();
	end
end

function SetExpBar()
	local exp = MainPlayerAttrib:getExp();
	local starNum = math.floor(exp/EXP_STAR_RATIO);

	getglobal("PlayerExpBarStarText"):SetText(starNum);
	if starNum >= 1000 and not getglobal("StarConvertFrame"):IsShown() then
		getglobal("PlayerExpBarStarText"):SetText("999+");
	end

	local expBarVal = (exp - starNum * EXP_STAR_RATIO) / EXP_STAR_RATIO ;
	getglobal("PlayerExpBarExp"):SetWidth(500*expBarVal);

	local uv = getglobal("PlayerExpBarUVAnimationTex");
	uv:SetPoint("right", "PlayerExpBarExp", "right", 20, 0);
	uv:SetUVAnimation(80, false);
	uv:Show();

	local curStarNum = math.floor(CurPlayerExpVal/EXP_STAR_RATIO);
	if starNum > curStarNum then
		--星星特效
		local starUV = getglobal("PlayerExpBarStarUV");
		starUV:SetUVAnimation(100, false);
		starUV:Show();
		ClientMgr:playSound2D("sounds/ui/info/experience_star.ogg", 1);
	end

	--角色界面星星进度
	SetRoleFrameStarNum(expBarVal, starNum);
end

function SetRoleFrameStarNum(expBarVal, starNum)
	local RoleFrameStarNum = getglobal("RoleFrameStarNum");
	local RoleFrameStarPro = getglobal("RoleFrameStarNumPro");
	RoleFrameStarPro:SetWidth(120 * expBarVal);
	RoleFrameStarNum:SetText(starNum);
end

-----------------------------------等级经验条-----------------------------------
local m_PlayerLevelExpSwitch = true;	--开关
function PlayerLevelExp_OnLoad()
	if m_PlayerLevelExpSwitch then
		this:RegisterEvent("GE_PLAYER_GAIN_LEVEL_EXP");
	end
end

--事件响应: 玩家获得等级经验
function PlayerGainLevelExp_OnEvent()
	if m_PlayerLevelExpSwitch then
		if arg1 == "GE_PLAYER_GAIN_LEVEL_EXP" then
			local ge 	= GameEventQue:getCurEvent();
			local state = ge.body.playerLevelExp.state;
			local uin = ge.body.playerLevelExp.uin

			SetLevelBar(true);

			if state == 1 then
				--1.升级
				PlayerGainLevelExp_UpgradeEffect(uin);
			elseif state == 2 then
				--2.获得经验
			end
		end
	end
end

--升级特效
function PlayerGainLevelExp_UpgradeEffect(uin)
	local curLevel = MainPlayerAttrib:getCurLevel();
	local mainUin = CurMainPlayer and CurMainPlayer:getUin() or uin
	if mainUin == uin then
		ShowGameTips(GetS(34248,tostring(curLevel)));
	end
	
	if uin and uin > 0 and ClientCurGame and ClientCurGame.getPlayerByUin then
		player = ClientCurGame:getPlayerByUin(uin);
		if player then
			player:playBodyEffectByName("Lvup");
			player:setBodyEffectScale("Lvup", 2.0);
			player:playSound("npc.lvup", 1.0, 1.0)
		end
	end
end

function SetLevelBar(bPlayEffect)
	if m_PlayerLevelExpSwitch then
		local pro = getglobal("PlayerLevelBarPro");
		local effect = getglobal("PlayerLevelBarEffect");
		local rate = getglobal("PlayerLevelBarRate");
		local level = getglobal("PlayerLevelBarLevel");

		local curExp = MainPlayerAttrib:getCurLevelExp();
		local curLevel = MainPlayerAttrib:getCurLevel();
		local maxLevel = MainPlayerAttrib:getMaxLevel();
		local upLevelExp = 0;
		local width = 0;
		local maxWidth = 500;

		if curLevel >= maxLevel then
			--已经是最高级
			upLevelExp = MainPlayerAttrib:getLevelExp(maxLevel);
			curExp = upLevelExp;
			width = maxWidth;
		else
			upLevelExp = MainPlayerAttrib:getLevelExp(curLevel + 1);
			width = maxWidth * curExp / upLevelExp;
		end

		width = width > maxWidth and maxWidth or width;
		width = width > 0 and width or 0;

		level:SetText("Lv" .. curLevel);
		rate:SetText(curExp .. "/" .. upLevelExp);
		pro:SetWidth(width);

		if bPlayEffect then
			effect:SetPoint("right", "PlayerLevelBarPro", "right", 20, 0);
			effect:SetUVAnimation(80, false);
			effect:Show();
		end

		--角色界面等级经验条
		local RoleFrameLevelBar = getglobal("RoleFrameLevelBar");
		local RoleFrameLevelPro = getglobal("RoleFrameLevelBarPro");
		local RoleFrameLevelLvl = getglobal("RoleFrameLevelBarLevel");
		local RoleFrameLevelRate = getglobal("RoleFrameLevelBarRate");
		
		local isOpenLevelMode = false;
		if WorldMgr then
			local BaseSettingMgr = WorldMgr:getBaseSettingManager();
			if BaseSettingMgr and BaseSettingMgr:isOpenLevelModel() then
				isOpenLevelMode = true;
			end
		end

		if isOpenLevelMode and CurWorld and CurWorld:isGameMakerRunMode() then
			RoleFrameLevelBar:Show();
			RoleFrameLevelBarWidth = 322 * curExp / upLevelExp;
			RoleFrameLevelBarWidth = RoleFrameLevelBarWidth > 322 and 322 or RoleFrameLevelBarWidth;
			RoleFrameLevelPro:SetWidth(RoleFrameLevelBarWidth);
			RoleFrameLevelLvl:SetText("Lv" .. curLevel);			
			RoleFrameLevelRate:SetText(curExp .. "/" .. upLevelExp);
		else
			RoleFrameLevelBar:Hide();
		end
	end
end

function PlayerHPBar_ShowOrHide(bShow)
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		bShow = false
	end
	if bShow then
		getglobal("PlayerHPBar"):Show()
	else
		getglobal("PlayerHPBar"):Hide()
	end
end

function RideHPBar_ShowOrHide(bShow)
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		bShow = false
	end
	if bShow then
		getglobal("RideHPBar"):Show()
	else
		getglobal("RideHPBar"):Hide()
	end
end

function PlayerHungerBar_ShowOrHide(bShow)
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		bShow = false
	end
	if bShow then
		getglobal("PlayerHungerBar"):Show()
	else
		getglobal("PlayerHungerBar"):Hide()
	end
end

function InteractiveBtn_ShowOrHide(bShow)
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		bShow = false
	end
	if bShow then
		getglobal("InteractiveBtn"):Show()
	else
		getglobal("InteractiveBtn"):Hide()
	end
end

--显示或隐藏
function LevelExpBar_ShowOrHide(bShow)
	local levelBar = getglobal("PlayerLevelBar");
	local expBar = getglobal("PlayerExpBar");

	if bShow then
		local isOpenLevelMode = false;
		if WorldMgr then
			local BaseSettingMgr = WorldMgr:getBaseSettingManager();
			if BaseSettingMgr and BaseSettingMgr:isOpenLevelModel() then
				isOpenLevelMode = true;
			end
		end
		
		if isOpenLevelMode and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.OBJECT) then--xyang自定义UI
			levelBar:Show();
			expBar:Hide();
		else
			levelBar:Hide();
			expBar:Show();
		end
	else
		levelBar:Hide();
		expBar:Hide();
	end
end


--潜行
function PlayMainFrameSneakBtn_OnClick()
	if getglobal("PlayMainFrameSneak"):IsChecked() then
		CurMainPlayer:setSneaking(false);
		ShowGameTips(GetS(104), 3);
		BPReportSneaking(false)
	else
		CurMainPlayer:setSneaking(true);
		ShowGameTips(GetS(105), 3);
		BPReportSneaking(true)
	end
end

function PlayMainFrameSneakBtn_OnMouseDown()
	if CurMainPlayer.triggerInputEvent then
		CurMainPlayer:triggerInputEvent(16,"Down")		
	end
end

function PlayMainFrameSneakBtn_OnMouseUp()
	if CurMainPlayer.triggerInputEvent then
		CurMainPlayer:triggerInputEvent(16,"Up")
	end
end

function PlayMainFrameSneakBtn_OnMouseDownUpdate()
	if CurMainPlayer.triggerInputEvent then
		CurMainPlayer:triggerInputEvent(16,"OnPress")
	end
end

--坐骑
function PlayMainFrameRideBtn_OnClick()
	CurMainPlayer:dismountActor();
    if CurMainPlayer:isShapeShift() then
        getglobal("AccRideAttackBtn"):Hide()
        getglobal("AccRideAttackLeftBtn"):Hide()
    end
end

--获取联机房内睡觉总人数
function TotalSleepingNums()
	local num = 1
	if ClientCurGame and ClientCurGame.getNumPlayerBriefInfo then
		num = ClientCurGame:getNumPlayerBriefInfo() + 1
	end
	return num
end

--获取当前睡觉人数
function CurrentSleepingNums()
	local num = 0
	if CurWorld and CurWorld:getActorMgr() then
		num = CurWorld:getActorMgr():sleepingMembers()
	end
	return num
end

--主动触发睡觉按钮
function PlayMainFrameSleepBtn_OnClick()
    if CurMainPlayer and CurMainPlayer.trySleep then
		CurMainPlayer:trySleep()
	end
	local frame = getglobal("SleepNoticeFrame")
	if frame and frame:IsShown() then
		local title = getglobal("SleepNoticeFrameTitle")
		local sleepBtn = getglobal("SleepNoticeFrameLeftBtn")
		local leaveBtn = getglobal("SleepNoticeFrameRightBtn")
		local middleBtn = getglobal("SleepNoticeFrameMiddleBtn")
		local waitingBtn = getglobal("SleepNoticeFrameLeftBtnWaiting")
		if title and sleepBtn and leaveBtn and middleBtn and waitingBtn then
			if ClientCurGame:isInGame() and AccountManager:getMultiPlayer() > 0 then
				--联机
				if sleepBtn:IsShown() then
					sleepBtn:Hide()
				end
				waitingBtn:Show()
			else
				--单机
				title:SetText("睡觉中...")
				sleepBtn:Hide()
				leaveBtn:Hide()
				middleBtn:Show()
			end
		end
	end
end

function PlayMainFrameFlyBtn_OnClick()
	--[[
	local PlayMainFrameFlyDown = getglobal("PlayMainFrameFlyDown")
	if PlayMainFrameFlyDown:IsShown() then
		PlayMainFrameFlyDown:Hide();
		CurMainPlayer:setFlying(false);
	else
		PlayMainFrameFlyDown:Show();
		CurMainPlayer:setFlying(true);
	end
	]]

	if DisabledExecute() then
		return
	end

	CurMainPlayer:setFlying(not CurMainPlayer:getFlying());
	-- 首次切换飞行模式提示
	if ShowFlyTips then
		ShowFlyTips()
	end
	--切换飞行模式打断互动动作
	local body = CurMainPlayer:getBody();
	--联机模式下且正在播放互动动作
	if AccountManager and AccountManager:getMultiPlayer() > 0 and body.clearAction 
		and body.isPlayingSkinAct and body:isPlayingSkinAct() then
		body:clearAction();
	end
	--[[
	local PlayMainFrameFlyUp = getglobal("PlayMainFrameFlyUp")
	if PlayMainFrameFlyUp:IsShown() then
		PlayMainFrameFlyUp:Hide()
	else
		PlayMainFrameFlyUp:Show()
	end
	]]
end

function PlayMainFrameFlyDown_OnMouseUp()
	CurMainPlayer:cancelMoveUp(-1)
end
function PlayMainFrameFlyDown_OnMouseDown()
	CurMainPlayer:setMoveUp(-1)
end
function PlayMainFrameFlyDown_OnClick()
end

local FrontFlyUpPosX = -1;
local FrontFlyUpPosY = -1;
function PlayMainFrameFlyUp_OnMouseUp()
	CurMainPlayer:cancelMoveUp(1);
	FrontFlyUpPosX = -1;
	FrontFlyUpPosY = -1;
end

function PlayMainFrameFlyUp_OnMouseDown()
	CurMainPlayer:setMoveUp(1)
end

function PlayMainFrameFlyUp_OnClick()
end

function CanOpenBackpack()
	if CurWorld and CurWorld:getOWID() ~= NewbieWorldId then return true end

	local lv = AccountManager:getCurGuideLevel();
	local step = AccountManager:getCurGuideStep();
	if lv == 1 then
		if step ~= 19 then
			return false;
		end
	end

	return true;
end


function PlayMainFrameBackpackBtn_OnClick()
	if not CanOpenBackpack() then return end

	local StorageBoxFrame = getglobal("StorageBoxFrame");
	if StorageBoxFrame:IsShown() then
		StorageBoxFrame:Hide()
	end

	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
		standReportEvent("1003", "MINI_TOOL_BAR", "BagButton", "click")
	else
		standReportEvent("1001", "MINI_TOOL_BAR", "BagButton", "click")
	end
	
	if IsInHomeLandMap and IsInHomeLandMap() then
		-- 家园背包按钮click埋点上报
		Homeland_StandReport_MainUIView("HomelandBackpack", "click")
		--家园 就打开家园背包
		GetInst("UIManager"):Open("HomelandBackpack")
	else
		if CurWorld:isGodMode() then
			local CreateBackpackFrame = getglobal("CreateBackpackFrame")
			if CreateBackpackFrame:IsShown() then
				CreateBackpackFrame:Hide();
			else
				CreateBackpackFrame:Show();
				--ClientCurGame:setOperateUI(true);
				if ClientCurGame.showOperateUI then
					ClientCurGame:showOperateUI(false);
				end
			end
		else
			if getglobal("RoleAttrFrame"):IsShown() then
				getglobal("RoleAttrFrame"):Hide();
			else
				--开发者:限制玩家打开背包
				if not checkCanOpenBackpack() then
					return;
				end
	
				getglobal("RoleAttrFrame"):Show();
				if ClientCurGame.showOperateUI then
					ClientCurGame:showOperateUI(false);
				end
			end
		end
	end
end

--开发者接口:检查玩家是否可以打开背包
function checkCanOpenBackpack()
	if CurWorld:isGameMakerRunMode() then
		if nil == CurMainPlayer.checkCanOpenBackpack then
			return true;
		end
		
		if not CurMainPlayer:checkCanOpenBackpack() then
			ShowGameTips('你被限制无法打开背包');
			return false;
		end
	end

	return true;
end

function PlayMainFrameGuideSkip_OnClick()
	if getglobal("MessageBoxFrame"):IsShown() then
		--统计
		-- statisticsGameEvent(901, "%s", "HideNoviceGuideExitTips","save",true);
		getglobal("MessageBoxFrame"):Hide();
	else
		--统计
		-- statisticsGameEvent(901, "%s", "ShowNoviceGuideExitTips","save",true);
		if CurWorld and CurWorld:getOWID() == NewbieWorldId2 and 
			getglobal("NewbieSkinTryPlay") and getglobal("NewbieSkinTryPlay"):IsShown()then
			return
		end
		standReportEvent("3801", "NEWPLAYER_MAP_SKIP", "Skip", "view")
		standReportEvent("3801", "NEWPLAYER_MAP_SKIP", "OK", "view")
		standReportEvent("3801", "NEWPLAYER_MAP_SKIP", "Quite", "view")
		MessageBox(16, GetS(3763));
		getglobal("MessageBoxFrame"):SetClientString( "新手引导退出" );
	end
end

function isAdventureBox(blockid) --code by renjie 属于冒险的无内部逻辑箱子
	local adventureBox={730,734,735,757,758,759,801,969,974,979,1231,1180,1181,371}
	-- 遍历数组
	for k,v in ipairs(adventureBox) do
	  if blockid == v then
	  	return true;
	  end
	end
	return false;

end

function GuideSkip()
	--统计
	-- local step = AccountManager:getCurGuideStep();
	-- if IsFirstEnterNoviceGuide then
		-- if step ~= nil then
		-- 	statisticsGameEvent(901, "%s", "ExitNoiceGuide", "%d", step,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));

		-- else
		-- 	statisticsGameEvent(901, "%s", "ExitNoiceGuide", "%d", 99,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
		-- end

		-- if step == 7 then
		-- 	statisticsGameEvent(901, "%s", "ExitNoiceGuidePlot", "%d", NewGuideInfo.statisticsPlotDialogIdx,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));

		-- elseif step == 16 then
		-- 	statisticsGameEvent(901, "%s", "ExitNoiceGuidePlot", "%d", NewGuideInfo.statisticsPlotDialogIdx,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));

		-- elseif step == 24 then
		-- 	statisticsGameEvent(901, "%s", "ExitNoiceGuidePlot", "%d", NewGuideInfo.statisticsPlotDialogIdx,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
		-- end
		-- --总的统计
		-- statisticsGameEvent(901, "%s", "ExitNoiceGuideSum","save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
	-- end
	--埋点，中途退出 设备码,是否首次进入教学地地图,用户类型,语言
	-- statisticsGameEventNew(961,ClientMgr:getDeviceID(),(IsFirstEnterNoviceGuide and not enterGuideAgain) and 1 or 2,
	-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
	--埋点，返回存档界面 设备码,返回存档来源,是否首次进入教学地地图,用户类型,语言		
	-- statisticsGameEventNew(963,ClientMgr:getDeviceID(),2,(IsFirstEnterNoviceGuide and not enterGuideAgain) and 1 or 2,
	-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
	StatisticsTools:send(true, true)
	IsSkipFromGuideOrFirstMap = true
	IsFirstEnterNoviceGuide = false;

	if CurWorld and CurWorld:getOWID() == NewbieWorldId then
		GoToMainMenu()
	elseif CurWorld and CurWorld:getOWID() == NewbieWorldId2 then
		local ctrl = GetInst("UIManager"):GetCtrl("RookieGuide")
		if ctrl then
			ctrl:Refresh()
		end
		if GetInst("mainDataMgr"):GetSwitch() == false and  NewbieGuideManager:GetPlayerTypeID() == NewbieGuideManager.NEW_PLAYER_TYPEID  then
			if not NewbieGuideManager:RequestSelectSkinPlay() then
				GoToMainMenu()
			end
		else
			GoToMainMenu()
		end
	end

	GongNengFrame_SetVipBtnForceHide(false);
	getglobal("GongNengFrameQQBlueVipBtn"):Show();
	getglobal("GongNengFrameStoreGNBtn"):Show();
	getglobal("GongNengFrameActivityGNBtn"):Show();
	--getglobal("GongNengFrameSetGNBtn"):Show();
	if friendservice.enabled then
		getglobal("GongNengFrameFriendBtn"):Show();
	else
		if IsInHomeLandMap and IsInHomeLandMap() then
			InteractiveBtn_ShowOrHide(false);
		elseif not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.INVITE) then--xyang自定义UI
			InteractiveBtn_ShowOrHide(false);
		else
			InteractiveBtn_ShowOrHide(true);
		end
	end
	AccountManager:setCurGuideStep(1);
	KillAllCutScene();
	ClearNoviceActor();
	SetGuideStep(nil)

	if IsStandAloneMode("") then
		MessageBox(4, GetS(25835))
	end

	DeepLinkQueue:dequeue();
end

function GuideSkip_Edu(skipType)--0为跳过新手引导，1为正常结束新手引导
	if MessageBoxFrame then
		MessageBoxFrame:Hide();
	end

	HideUI2GoMainMenu();
    ClearInstanceData();
    ClearMultiLangEdit();
    HideVehicleTips();

	AccountManager:setCurGuideStep(1);
	KillAllCutScene();
	ClearNoviceActor();
	SetGuideStep(nil)	

	CurMainPlayer:setMoveInputActive(false);

	--ClientMgr:gotoGame("none");

	if not ClientMgr:isPC() then
        if MCodeMgr then
            local tParam = {0, "MiniWorldGuideFinished",skipType}
            MCodeMgr:miniCodeCallBack(-1001, JSON:encode(tParam));
        end
    end
end

function PlayMainFrame_OnLoad()
	this:RegisterEvent("GIE_FLYMODE_CHANGE");
	this:RegisterEvent("GIE_INFO_TIPS");
	this:RegisterEvent("GIE_ENTER_WORLD");
	this:RegisterEvent("GIE_UPDATE_BOSS_STATE");
	this:RegisterEvent("GIE_UPDATE_CALLED_BOSS_STATE");
	this:RegisterEvent("GIE_LEAVE_WORLD");
	this:RegisterEvent("GE_OPEN_CONTAINER");
	this:RegisterEvent("GE_CLOSE_CONTAINER");
	this:RegisterEvent("GE_NEED_CONTAINER_PASSSWORD");
	this:RegisterEvent("GE_TOGGLE_GAMEMODE");
	this:RegisterEvent("GIE_RIDING_CHANGE");
	this:RegisterEvent("GE_STATISTIC");
	this:RegisterEvent("GIE_RIDING_ENTERWATERORLAND");
	this:RegisterEvent("GE_PLAYER_SHAPE_SHIFT");
	
	this:RegisterEvent("GE_PRE_OPEN_EDIT_FCM_UI")
	this:RegisterEvent("GE_OPEN_EDIT_FULLYCUSTOMMODEL")
	this:RegisterEvent("GE_CLOSE_EDIT_FULLYCUSTOMMODEL")

	this:RegisterEvent("GIE_OPEN_DIALOGUE");
	this:RegisterEvent("GE_NPCSHOP_OPEN")
	this:RegisterEvent("GE_OPEN_EDIT_ACTORMODEL")
	this:RegisterEvent("GE_MAINPLAYER_DIE");

    this:RegisterEvent("GIE_PLAY_ALTMANMUSIC")
    this:RegisterEvent("GIE_BUFF_CHANGE")
	this:RegisterEvent("GIE_QQMUSIC_PLAYER")
	this:RegisterEvent("GIE_MINICLUB_PLAYER")
	this:RegisterEvent("GE_CUSTOMGAME_STAGE");
	this:setUpdateTime(0.05);
	getglobal("BattleCountDownFrame"):setUpdateTime(0.05);
	getglobal("ScreenEffectFrame"):setUpdateTime(0.05);
	getglobal("OverLookArrowFrame"):setUpdateTime(0.05);

	--PC和Mobile,MultiPlayerInfo的区别处理

	if ClientMgr:isPC() then
		getglobal("MultiPlayerInfoInfo"):SetHeight(285);
		getglobal("MultiPlayerInfoInfoTips"):Show();
	else
		getglobal("MultiPlayerInfoInfo"):SetHeight(269);
		getglobal("MultiPlayerInfoInfoTips"):Hide();
	end

	getglobal("RocketUIFrame"):setUpdateTime(0.05);
end

-- 神秘方砖id和奥特曼背景音乐对应表
local altmanMusicCfg = {
    [471] = "sounds/music/bgm_urutoramanDiga.ogg",
    [472] = "sounds/music/bgm_urutoramanDaina.ogg",
    [473] = "sounds/music/bgm_urutoramanGaia.ogg",
    [474] = "sounds/music/bgm_urutoramanZero.ogg",
    [475] = "sounds/music/bgm_urutoramanGinga.ogg",
}

-- 记录下当前播放的背景音乐
lastMusicName = ""
-- 定时器停止奥特曼背景音乐
local altmanMusicTimer = nil
-- 是否正在播放奥特曼背景音乐
isPlayingAtlmanMusic = false

CUR_WORLD_MAPID = 0;		-- 0主世界 大于0为副本
local netHandle = {
	-- traceHandle;
	-- playerCloseUIHandle;
	-- actorShowExchangeItemHandle;
	-- desertBussinessManDealHandle;
	-- actorShowHeadIconByPathHandle;
	-- playerHandle
	-- surviveReport
}

-- tips显示计时key
local tipsOnShowSchedulerKeys = {}

function UnRegisterTipsSchedulerEvent(text)
	if text and tipsOnShowSchedulerKeys[text] then 
        GetInst("MiniUIScheduler"):unreg(tipsOnShowSchedulerKeys[text])
        tipsOnShowSchedulerKeys[text] = nil
    end
end

function UnRegisterAllTipsSchedulerEvents()
	for key, value in pairs(tipsOnShowSchedulerKeys) do
		if value then
			GetInst("MiniUIScheduler"):unreg(value)
        	tipsOnShowSchedulerKeys[key] = nil
		end
	end
end

function RegisterTipsSchedulerEvent(text)
	if text then
		UnRegisterTipsSchedulerEvent(text)
		tipsOnShowSchedulerKeys[text] = GetInst("MiniUIScheduler"):regGloabel(function ()
			UnRegisterTipsSchedulerEvent(text)
		end, tipsDisplayTime, 0, 0, false)
	end
end

function PlayMainFrame_OnEvent()
	if arg1 == "GIE_FLYMODE_CHANGE" then
		if CurWorld and CurWorld:isGodMode() or CurMainPlayer:isInSpectatorMode() then
			if not CurMainPlayer:getFlying() then
				CurMainPlayer:setMoveUp(0);

				local PlayMainFrameFlyDown = getglobal("PlayMainFrameFlyDown");
				local PlayMainFrameFlyUp = getglobal("PlayMainFrameFlyUp");

				if PlayMainFrameFlyDown:IsShown() then
					PlayMainFrameFlyDown:ClearPushState();
					UIFrameMgr:frameHide(PlayMainFrameFlyDown);
				end
				if PlayMainFrameFlyUp:IsShown() then
					PlayMainFrameFlyDown:ClearPushState();
					UIFrameMgr:frameHide(PlayMainFrameFlyUp);
				end

				local PlayMainFrameFly = getglobal("PlayMainFrameFly")
				if PlayMainFrameFly:IsChecked() then
					PlayMainFrameFly:SetChecked(false);
				end
			end
		end

		if CurWorld and CurWorld:getOWID() ~= NewbieWorldId and CurWorld:getOWID() ~= NewbieWorldId2 and ClientMgr:isMobile() then
			if CurMainPlayer:isFlying() then
				if getglobal("AccRideCallBtn"):IsShown() then
					getglobal("AccRideCallBtn"):Hide();
				end
				--变形按钮
				if getglobal("AccRideChangeBtn"):IsShown() then
					getglobal("AccRideChangeBtn"):Hide();
				end
				--召唤按钮
				if getglobal("AccSummonBtn"):IsShown() then
					getglobal("AccSummonBtn"):Hide();
				end
			else
				if not getglobal("AccRideCallBtn"):IsShown() and CurMainPlayer:getMountType()~=MOUNT_DRIVE and  not MapEditManager:GetIsStartEdit() then
					if not isEducationalVersion and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then--xyang自定义UI
						getglobal("AccRideCallBtn"):Show();
					end
				end
				--变形按钮
				local skinId = CurMainPlayer:getSkinID()
				local skinDef = RoleSkinCsv:get(skinId)
				if not getglobal("AccRideChangeBtn"):IsShown() and skinDef and skinDef["ChangeType"] > 0 and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then--xyang自定义UI
					getglobal("AccRideChangeBtn"):Show();
				end
				if skinDef and skinDef.SummonID and skinDef.SummonID ~= "" and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then
					getglobal("AccSummonBtn"):Show()
					standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "GameOpenSummon", "view", {standby1 = skinId})
				else
					getglobal("AccSummonBtn"):Hide()
				end
			end
		end

		--变形按钮
		if getglobal("AccRideChangeBtn"):IsShown() then
			if getglobal("AccRideCallBtn"):IsShown() then
				getglobal("AccRideChangeBtn"):SetPoint("right", "AccRideCallBtn", "left", -3, 0)
			else
				getglobal("AccRideChangeBtn"):SetPoint("center", "AccRideCallBtn", "center", 0, 0)
			end
		end

		if getglobal("AccRideChangeBtn"):IsShown() then--如果变形按钮显示，设置召唤按钮到变形按钮左边
			getglobal("AccSummonBtn"):SetPoint("right", "AccRideChangeBtn", "left", -3, 0)
		else
			if getglobal("AccRideCallBtn"):IsShown() then
				getglobal("AccSummonBtn"):SetPoint("right", "AccRideCallBtn", "left", -3, 0)
			else
				getglobal("AccSummonBtn"):SetPoint("center", "AccRideCallBtn", "center", 0, 0)
			end
		end

		-- 首次切换飞行模式提示
		if ShowFlyTips then
			ShowFlyTips()
		end
	elseif arg1 == "GIE_INFO_TIPS" then
		local ge 	= GameEventQue:getCurEvent();
		local text 	= ge.body.infotips.info;
		if not tipsOnShowSchedulerKeys[text] then
			ShowGameTips(text, 3);
			RegisterTipsSchedulerEvent(text)
		end
	elseif arg1 == "GIE_ENTER_WORLD" then
		local ge = GameEventQue:getCurEvent();
		local mapid = ge.body.enterworld.mapid;
		CUR_WORLD_MAPID = mapid;
		EnterWorld(mapid);
		Streaming.enterWorld();
		SetPlayerPurchaseFlag(false);
		ArchiveLoadGameEnvent();
		GetInst("ResourceDataManager"):SetIsFromLobby(ResourceCenterOpenFrom.FromMap)
		SaveCurWorldArchivePropSetting(true);
		gCreateRoomWorldID = nil
		threadpool:work(function ()
			CurMainPlayer:addAchievement(1, ACHIEVEMENT_ENTER_WORLD, mapid)
		end)
		SandboxLua.eventDispatcher:Emit(nil, "ENTER_WORLD",  SandboxContext():SetData_Number("code", 0))
		local function playerCloseUINet(content)
			local ui = content.uiName;
			if ui == "MobInteractBackpack" then
				GetInst("UIManager"):Close("MobInteractBackpack");
			end
		end
		netHandle.playerCloseUIHandle = SandboxLuaMsg:SubscibeMsgHandle(SANDBOX_LUAMSG_NAME.Survive.PLAYER_CLOSE_UI, playerCloseUINet)
		local function actorShowExchangeItem(content)
			local actorId = content.actorId
			if CurWorld and actorId then
				local mob = CurWorld:getActorMgr():findMobByWID(actorId);
				if mob then
					local exchangeItem = content.exchangeItem or 0;
					local exchangeNum = content.exchangeNum or 0;
					local saleItem = content.saleItem or 0;
					local saleNum = content.saleNum or 0;
					local tick = content.tick or -1;
					local isActor = content.isActor;
					if isActor == nil then
						isActor = false;
					end
					mob:getBody():setHeadExchangeDisplayIcon(exchangeItem, saleItem, isActor, exchangeNum, saleNum, tick);
				end
			end
		end
		netHandle.actorShowExchangeItemHandle = SandboxLuaMsg:SubscibeMsgHandle(SANDBOX_LUAMSG_NAME.Survive.SHOW_EXCHANGE_ITEM_ICON, actorShowExchangeItem)
		local function actorShowHeadIconByPath(content)
			local actorId = content.actorId
			if CurWorld and actorId then
				local mob = CurWorld:getActorMgr():findMobByWID(actorId);
				if mob then
					local imageResPath = content.imageResPath or 0;
					local imageResUVName = content.imageResUVName or 0;
					local imageWidth = content.imageWidth or 0;
					local imageHeight = content.imageHeight or 0;
					mob:getBody():setHeadIconByPath(imageResPath, imageResUVName, imageWidth, imageHeight);
				end
			end
		end
		netHandle.actorShowHeadIconByPathHandle = SandboxLuaMsg:SubscibeMsgHandle(SANDBOX_LUAMSG_NAME.Survive.SHOW_HEAD_ICON_BY_PATH, actorShowHeadIconByPath)
		local function actorRefreshSleepState(content)
			local actorId = content.actorId
			if CurWorld and actorId then
				local mob = CurWorld:getActorMgr():findMobByWID(actorId);
				if mob then
					local state = content.state;
					mob:setSleeping(state);				
				end
			end
		end
		netHandle.actorRefreshSleepStateHandle = SandboxLuaMsg:SubscibeMsgHandle(SANDBOX_LUAMSG_NAME.Survive.SYN_SLEEP_STATE, actorRefreshSleepState)
		local function actorbodyShow(content)
			local actorId = content.actorId
			if CurWorld and actorId then
				local mob = CurWorld:getActorMgr():findMobByWID(actorId);
				if mob then
					local body = mob:getBody()
					if body then
						body:show(content.b,content.ignorenamedispobj,content.ignoremotion);
					end				
				end
			end
		end
		netHandle.actoractorbodyShowHandle = SandboxLuaMsg:SubscibeMsgHandle(SANDBOX_LUAMSG_NAME.Survive.ACOTRBODY_SHOW, actorbodyShow)
		ShowEnterMapAnim();
		DriftBottlePullContent();
		netHandle.surviveReport = SandboxLuaMsg:SubscibeMsgHandle(SANDBOX_LUAMSG_NAME.Survive.SURVIVE_REPORT, SurviveTaskReportInGame)
		local function drfitBottleGet(content)
			local uin =  AccountManager:getUin();
			local _, str =  DriftBottleGetContent(nil,uin);
			local retContent = 
			{
				str = str,
				uin = uin,
				spawnType = content.spawnType;
				x = content.x;
				y = content.y;
				z = content.z;
			}
			SandboxLuaMsg.sendToHost(SANDBOX_LUAMSG_NAME.Survive.DRIFTBOTTLE_GETHOST, retContent);
		end
		netHandle.driftBottleGet = SandboxLuaMsg:SubscibeMsgHandle(SANDBOX_LUAMSG_NAME.Survive.DRIFTBOTTLE_GET, drfitBottleGet);
	elseif arg1 == "GIE_UPDATE_BOSS_STATE" then
		local ge = GameEventQue:getCurEvent();
		local hp = ge.body.bossstate.hp;
		local monsterId = ge.body.bossstate.id;
		UpdateBossHpFrame(hp, monsterId);
		PlayMusicByBoss(hp, monsterId);
	elseif arg1 == "GIE_UPDATE_CALLED_BOSS_STATE" then
		local ge = GameEventQue:getCurEvent();
		local hp = ge.body.bossscalledtate.hp;
		local monsterId = ge.body.bossscalledtate.id;
		local timestep = ge.body.bossscalledtate.timestep;
		UpdateBossHpFrame2(hp, timestep, monsterId);
	elseif arg1 == "GIE_LEAVE_WORLD" then
		Streaming.leaveWorld();
		local ge = GameEventQue:getCurEvent();
		local mapid = ge.body.enterworld.mapid;
		if getglobal("InstanceTaskFrame"):IsShown() then
			getglobal("InstanceTaskFrame"):Hide();
		end
		if getglobal("BossHpFrame"):IsShown() then
			getglobal("BossHpFrame"):Hide();
		end
		if getglobal("IntroduceFrame"):IsShown() then
			getglobal("IntroduceFrame"):Hide();
		end

		SandboxLua.eventDispatcher:Emit(nil, "LEAVE_WORLD",  SandboxContext():SetData_Number("code", 0))
		
		if netHandle.playerCloseUIHandle then
			SandboxLuaMsg:unSubscibeMsgHandle(netHandle.playerCloseUIHandle);
			netHandle.playerCloseUIHandle= nil;
		end
		if netHandle.actorShowExchangeItemHandle then
			SandboxLuaMsg:unSubscibeMsgHandle(netHandle.actorShowExchangeItemHandle);
			netHandle.actorShowExchangeItemHandle= nil;
		end
		if netHandle.actorShowHeadIconByPathHandle then
			SandboxLuaMsg:unSubscibeMsgHandle(netHandle.actorShowHeadIconByPathHandle);
			netHandle.actorShowHeadIconByPathHandle= nil;
		end
		if netHandle.actorRefreshSleepStateHandle then
			SandboxLuaMsg:unSubscibeMsgHandle(netHandle.actorRefreshSleepStateHandle);
			netHandle.actorRefreshSleepStateHandle= nil;
		end

		if netHandle.actoractorbodyShowHandle then
			SandboxLuaMsg:unSubscibeMsgHandle(netHandle.actoractorbodyShowHandle);
			netHandle.actoractorbodyShowHandle= nil;
		end

		if netHandle.surviveReport then
			SandboxLuaMsg:unSubscibeMsgHandle(netHandle.surviveReport);
			netHandle.surviveReport= nil
		end

		if netHandle.driftBottleGet then
			SandboxLuaMsg:unSubscibeMsgHandle(netHandle.driftBottleGet);
			netHandle.driftBottleGet= nil
		end
	elseif arg1 == "GE_OPEN_CONTAINER" then	--打开相应的容器
		local ge = GameEventQue:getCurEvent();
		local baseindex = ge.body.opencontainer.baseindex;
		local blockId = ge.body.opencontainer.blockid;
		local blockpos = {x = ge.body.opencontainer.posx or 0, y = ge.body.opencontainer.posy or 0, z = ge.body.opencontainer.posz or 0};	--箱子坐标位置
		---Log("GE_OPEN_CONTAINER"..baseindex..blockId);
		if baseindex == FURNACE_START_INDEX then
			--ClientCurGame:setOperateUI(true);
			--GetInst("UIManager"):Open("Furnace",{itemId = blockId})
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/compose"})
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/c_innerCommon"})
			GetInst("MiniUIManager"):OpenUI("main_furnace","miniui/miniworld/compose","MiniUIFurnaceMain", {itemId = blockId})
		elseif baseindex == DETECTIONPIPE_START_INDEX then --储物箱、柜、补给箱、检测管道fgui --codeby renjie 
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common","miniui/miniworld/c_ingame","miniui/miniworld/common_comp","miniui/miniworld/adventure","miniui/miniworld/ArchiveInfoDetail"})
			GetInst("MiniUIManager"):OpenUI("storageBoxFrame","miniui/miniworld/adventure","storageBoxFrameAutoGen",{ge})	
		elseif baseindex == STORAGE_START_INDEX or baseindex == FUNNEL_START_INDEX  or baseindex == EMITTER_START_INDEX or baseindex == SENSOR_START_INDEX or baseindex == COLLIDER_START_INDEX then
			SetBoxContainerInfo(baseindex, blockId, blockpos);
		elseif baseindex == NPCTRADE_START_INDEX then
			UIFrameMgr:frameShow(getglobal("NpcTradeFrame"));
			--ClientCurGame:setOperateUI(true);
		elseif baseindex == HORSE_EQUIP_INDEX then
			UIFrameMgr:frameShow(getglobal("RideFrame"));
			--ClientCurGame:setOperateUI(true);
		elseif baseindex == FURNACE_OXY_START_INDEX then
			--LLDO:打开氧气炉
			UIFrameMgr:frameShow(getglobal("FurnaceOxyFrame"));
		elseif baseindex == BLUEPRINT_START_INDEX then
			--打开"蓝图工作台"
			Log("OpenBlueprint:");
			UIFrameMgr:frameShow(getglobal("BlueprintFrame"));
		elseif baseindex == INTERPRETER_START_INDEX then
			--打开信号解析器
			UIFrameMgr:frameShow(getglobal("InstructionParserFrame"));
		elseif baseindex == BUILDBLUEPRINT_START_INDEX then
			--打开图纸建造方块
			UIFrameMgr:frameShow(getglobal("BluePrintDrawingFrame"));
		elseif baseindex == CUSTOMMODEL_START_INDEX then
			CurOpenCustomModelBlockId = blockId;
			UIFrameMgr:frameShow(getglobal("CustomModelFrame"));
		elseif baseindex == BRUSHMONSTER_START_INDEX then
			UIFrameMgr:frameShow(getglobal("CreateMonsterFrame"));
		elseif baseindex == SIGNS_START_INDEX then
			OpenGameSignEditFrame(blockId)
		elseif baseindex == ACTIONER_START_INDEX then
			local param = {};
 			param.disableOperateUI = false;
			--param.isVehicle = false
			--if OpenContainer then
			--	param.nodes = OpenContainer:getActionerNodeStr()
			--else
			--	param.nodes = ""
			--end
			GetInst("UIManager"):Open("VehicleActioner",param)
		--elseif baseindex == VEHICLE_START_INDEX then
		--	UIFrameMgr:frameShow(getglobal("VehicleEditFrame"));
		elseif baseindex == SENSOR_VALUE_START_INDEX then
			--UIFrameMgr:frameShow(getglobal("ContainerSensorValueFrame"));
			local param = {};
			param.blockid = blockId;
		   --param.isVehicle = false
		   --if OpenContainer then
		   --	param.nodes = OpenContainer:getActionerNodeStr()
		   --else
		   --	param.nodes = ""
		   --end
		   GetInst("UIManager"):Open("ContainerSensorValue",param)
		elseif baseindex == TOMBSTONE_STRAT_INDEX then
			--OpenGameSignEditFrame(blockId)
			if OpenContainer then
				local param = {container=OpenContainer,bid = blockId}
				OpenTombStoneUI(param)
			end
		elseif baseindex == ALTAR_STRAT_INDEX then
			local param = {};
			param.blockid = blockId;
			GetInst("UIManager"):Open("AltarAwardsEdit",param)
		end

		if blockId == 757 or blockId == 758 or blockId == 759 then--打开宝箱埋点
			OpenTreasureChestUseReport(blockId)
		end
	elseif arg1 == "GE_NEED_CONTAINER_PASSSWORD" then
		local ge = GameEventQue:getCurEvent();
		local x = ge.body.needContainerpassword.pos_x
		local y = ge.body.needContainerpassword.pos_y
		local z = ge.body.needContainerpassword.pos_z
		local state = ge.body.needContainerpassword.state --0房主没有初始化密码 1请输入密码 2密码输入失败
		AirlinerOpenPasswordBox(state)


	elseif arg1 == "GE_CLOSE_CONTAINER" then
		local ge = GameEventQue:getCurEvent();
		local baseindex = ge.body.opencontainer.baseindex;

		if baseindex == FURNACE_START_INDEX then
			-- UIFrameMgr:frameHide(getglobal("FurnaceFrame"));
			GetInst("UIManager"):Hide("Furnace")
		elseif baseindex == STORAGE_START_INDEX or baseindex == FUNNEL_START_INDEX  or baseindex == INTERPRETER_START_INDEX or baseindex == EMITTER_START_INDEX or baseindex == SENSOR_START_INDEX or baseindex == COLLIDER_START_INDEX then
			UIFrameMgr:frameHide(getglobal("StorageBoxFrame"));
		elseif baseindex == NPCTRADE_START_INDEX then
			UIFrameMgr:frameHide(getglobal("NpcTradeFrame"));
		elseif baseindex == HORSE_EQUIP_INDEX then
			UIFrameMgr:frameHide(getglobal("RideFrame"));
		elseif baseindex == INTERPRETER_START_INDEX then
			UIFrameMgr:frameHide(getglobal("InstructionParserFrame"));
		elseif baseindex == SENSOR_VALUE_START_INDEX then 
			UIFrameMgr:frameHide(getglobal("ContainerSensorValueFrame"));
		end
	elseif arg1 == "GE_TOGGLE_GAMEMODE" then
		HideAllFrame(nil, false);
		if CurWorld:isGodMode() and not ClientMgr:isPC() then
			ClientBackpack:setCreateModeShortCut();
		else
			if CurMainPlayer:getFlying() then
				CurMainPlayer:setFlying(false);
			end
		end
		PlayMainFrameUIShow();
		--切换模式需要重置一下
		GetInst("TriggerMapInteractiveInterFace"):LeveGameGame()
		GetInst("NewDeveloperStoreInterface"):LeveaGame()
		GetInst("TriggerMapInteractiveInterFace"):InGame()
		GetInst("NewDeveloperStoreInterface"):InGame()
		if CurWorld:isGameMakerMode() then
			LivingToolMgr:showAllPreviewLives(true)
			--召唤一下自己的宠物，因为在load那里被干掉了
			-- 不保存
			if ClientCurGame:getRuleOptionVal(GMRULE_SAVEMODE) == 1 then
				HomelandCallModuleScript("HomelandPetModule","setSummonPet")
			end
			--编辑模式下如果在音乐方块中则复原到原来模型
			if GetInst("MiniUIManager") then
				if GetInst("MiniUIManager"):GetCtrl("clubMain") then
					LeaveMusicClub()
				end
				if DealMusicClubIns then
					if DealMusicClubIns.setOnce then
						DealMusicClubIns:setOnce()
					end
				end
			end
		elseif CurWorld:isGameMakerRunMode() then
			LivingToolMgr:showAllPreviewLives(false)
			LivingToolMgr:createLivesInWorld();
			TriggerObjLibMgr:CreateDropItemInWorld(true);
			CurWorld:quitToolMode();
			if AccountManager then
				if AccountManager:getMultiPlayer() == 0 then
					if CurMainPlayer then
						if DealMusicClubIns then
							if DealMusicClubIns.updateAreaId then
								DealMusicClubIns:updateAreaId(CurMainPlayer:getCurWorldMapId());
							end
						end
					end
				end
			end

			--转变玩法模式的时候去除下选中的状态
			if TriggerObjLibMgr and TriggerObjLibMgr.getDisplayBoardMgr then
				local boardmgr = TriggerObjLibMgr:getDisplayBoardMgr()
				if boardmgr and boardmgr.ShowDisplayBoardSelectView then
					boardmgr:ShowDisplayBoardSelectView();
				end
			end
		end
		GetInst("UGCCommon"):ToggleGameMode()
		-- GetInst("GuideMgr"):PushEvent(GuideCfg.Event.ToggleGameMode)--引导屏蔽
		ShowToActivityFrame()
	--	getglobal("PlayMainFrame"):Show();
	elseif arg1 == "GIE_RIDING_CHANGE" then
		local ge = GameEventQue:getCurEvent();
		local rideType = ge.body.ridingchange.ridetype;
		if CurMainPlayer then
			UpdateMainFucBtn(rideType);
		end
	elseif arg1 == "GE_STATISTIC" then
		local ge = GameEventQue:getCurEvent();
		local id = ge.body.statisticinfo.id;
		local worldtype = ge.body.statisticinfo.worldtype;
		local p1 = ge.body.statisticinfo.param1;
		local p2 = ge.body.statisticinfo.param2;
		local p3 = ge.body.statisticinfo.param3;
		local p4 = ge.body.statisticinfo.param4;
		local p5 = ge.body.statisticinfo.param5;
		local p6 = ge.body.statisticinfo.param6;
		local p7 = ge.body.statisticinfo.param7;

		if p1 and p1 == "param_to_str" then
			statisticsInGameToStr(id, worldtype, p2, p3, p4, p5, p6, p7);
		else
			statisticsInGame(id, worldtype, p1, p2, p3, p4, p5, p6, p7);
		end 
	elseif arg1 == "GIE_RIDING_ENTERWATERORLAND" then
		local ge = GameEventQue:getCurEvent();
		local bInWater = (ge.body.gameevent.result == 1)
		if bInWater then
			local baricon = getglobal("ChickenEnergyFrameIcon")
			baricon:SetTextureHuiresXml("ui/mobile/texture2/outgame2/uitex3.xml");
			baricon:SetTexUV("sdjm_icon_shuxing02.png");
			getglobal("ChickenEnergyFrame"):Show();
		else
			getglobal("ChickenEnergyFrame"):Hide();
		end
	elseif arg1 == "GE_PLAYER_SHAPE_SHIFT" then
		local ge = GameEventQue:getCurEvent();
		local state = ge.body.shapeshiftinfo.state
		--变形TODO
		if state then
			--隐藏黄框
			if ShortCut_SelectedIndex >= 0 then
				getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."Check"):Hide()
			end
		else
			if ShortCut_SelectedIndex >= 0 then
				getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."Check"):Show()
			end
		end
	elseif arg1 == "GIE_OPEN_DIALOGUE" then 
		local ge = GameEventQue:getCurEvent();
		SetOpenDialogueByItemID(ge.body.opendialogueinfo.itemid);
		UpdateNpcDialogueFrame();
	elseif arg1 == "GE_NPCSHOP_OPEN" then 
		getglobal("NpcShopFrame"):Show();
	elseif arg1 == "GE_OPEN_EDIT_ACTORMODEL" then 
		getglobal("ActorSelectEditFrame"):Show();
	elseif arg1 == "GE_MAINPLAYER_DIE" then 
		if ClientCurGame:isInGame() and (ClientCurGame:getGameStage() == 4 or (CurMainPlayer ~= nil and CurMainPlayer.getGameResults and CurMainPlayer:getGameResults()> 0) ) then return end

		if not CurWorld then return end

		local s=0;
		local reviveMode=0;
		reviveMode, s = CurWorld:getReviveMode(s);
		if reviveMode == 1 and ClientCurGame:isInGame() then
			DeathTime = s;
			getglobal("BattleDeathFrame"):Show();
		end
		
		--重生界面
		if not CurWorld:isExtremityMode() and reviveMode == 0 and  not getglobal("DeathFrame"):IsShown() then
			getglobal("DeathFrame"):Show()
		end

		if AvatarSummonIndex > 0 then
			if CurWorld and CurWorld:isRemoteMode() then
				local params = {objid = CurMainPlayer:getObjId(),summonid = 0}
				SandboxLuaMsg.sendToHost(_G.SANDBOX_LUAMSG_NAME.BUZZ.AVATAR_SUMMON_TOHOST, params)
			else
				CurMainPlayer:avatarSummon(0)
			end
			AvatarSummonIndex = 0
		end

    -- 播放奥特曼背景音乐
    elseif arg1 == "GIE_PLAY_ALTMANMUSIC" then 
        local ge = GameEventQue:getCurEvent()
		local blockid = ge.body.playAltmanMusic.blockId
        if altmanMusicCfg[blockid] then
            ClientMgr:stopMusic()
			ClientMgr:playMusic(altmanMusicCfg[blockid], false)

			isPlayingAtlmanMusic = true

			if altmanMusicTimer then
				threadpool:kick(altmanMusicTimer)
			end
            -- 100秒后切回之前的bgm
            altmanMusicTimer = threadpool:delay(100, function()
                ClientMgr:stopMusic()
                ClientMgr:playMusic(lastMusicName, true)

				isPlayingAtlmanMusic = false
            end)
        end
    -- buff变化
    elseif arg1 == "GIE_BUFF_CHANGE" then 
        local ge = GameEventQue:getCurEvent()
		local buffId = ge.body.buffChange.buffId
        local changeType = ge.body.buffChange.changeType

        -- changeType : 0-添加 1-移除 2-移除所有
        -- 监测光之力buff消失
        if buffId == 96 and (changeType == 1 or changeType == 2) then
            ClientMgr:stopMusic()
			ClientMgr:playMusic(lastMusicName, true)

			isPlayingAtlmanMusic = false

            if altmanMusicTimer then
                threadpool:kick(altmanMusicTimer)
            end
        end
	elseif arg1 == "GIE_QQMUSIC_PLAYER" then
		local ge = GameEventQue:getCurEvent()
		if GetInst("QQMusicPlayerManager") then
			GetInst("QQMusicPlayerManager"):HandleEvent(ge)
		end
	elseif arg1 == "GIE_MINICLUB_PLAYER" then
		local ge = GameEventQue:getCurEvent()
		if GetInst("MiniClubPlayerManager") then
			GetInst("MiniClubPlayerManager"):HandleEvent(ge)
		end
	elseif arg1 == "GE_CUSTOMGAME_STAGE" then
		local ge = GameEventQue:getCurEvent();
		local stage = ge.body.cgstage.stage;
		local gametime = ge.body.cgstage.gametime;
		if YearMonsterGameOnStageChange then
			YearMonsterGameOnStageChange(stage)
		end
	end

	FullyCustomModelSelect_OnEvent(arg1);
end

--显示睡觉提示弹窗
function ShowSleepNoticeFrame()
	if FesivialActivity:TonightIsTiangou() then -- 天狗食月不能睡觉
		ShowGameTips(GetS(86019))
		return
	end
    if ClientCurGame and ClientCurGame.setOperateUI then
		ClientCurGame:setOperateUI(true)
	end
	local getOutOfBed = getglobal("PlayMainFrameBedName")
	if getOutOfBed then
		getOutOfBed:SetText(GetS(86021))
		getOutOfBed:Show()
	end
	local frame = getglobal("SleepNoticeFrame")
	if frame then
		frame:Show()
		local title = getglobal("SleepNoticeFrameTitle")
		local sleepBtn = getglobal("SleepNoticeFrameLeftBtn")
		local leaveBtn = getglobal("SleepNoticeFrameRightBtn")
		local middleBtn = getglobal("SleepNoticeFrameMiddleBtn")
		local waitingBtn = getglobal("SleepNoticeFrameLeftBtnWaiting")
		if title and sleepBtn and leaveBtn and middleBtn and waitingBtn then
			waitingBtn:Hide()
			middleBtn:Hide()
			sleepBtn:Show()
			leaveBtn:Show()
			--标题信息的处理逻辑
			if ClientCurGame:isInGame() and AccountManager:getMultiPlayer() > 0 then
				--联机
				threadpool:work(function ()
					local num = 0
					local totalNum = TotalSleepingNums()
					-- 打开循环开关，在Hide的时候再关闭
					checkingSleepingPlayers = true
					while checkingSleepingPlayers do
						num = CurrentSleepingNums()
						totalNum = TotalSleepingNums()
                        getglobal("SleepNoticeFrameTitle"):SetText(tostring(num).."/"..tostring(totalNum).."人准备睡觉")
                        if num == totalNum then
                            getglobal("SleepNoticeFrameTitle"):SetTextColor(90, 234, 10)
                        else
                            getglobal("SleepNoticeFrameTitle"):SetTextColor(250, 122, 15)
                        end
                        
						threadpool:wait(0.5)
					end
				end)
			else
				--单机
                getglobal("SleepNoticeFrameTitle"):SetText("准备睡觉啦~")
                getglobal("SleepNoticeFrameTitle"):SetTextColor(90, 234, 10)
			end
		end
	end
	-- --新冒险模式睡觉修改
	-- if LuaInterface:shouldUseNewHpRule() then--如果是冒险模式和创造转冒险就进行隐藏
	-- 	HideSleepNoticeFrame()
	-- 	PlayMainFrameSleepBtn_OnClick()
	-- 	NewShowSleepNoticeFrame()
	-- end
end

function NewShowSleepNoticeFrame() 
	local sleepnum = getglobal("NewSleepNoticeFrameNum")
	local icon = getglobal("NewSleepNoticeFrameTopBkg")
	local newsleepframe = getglobal("NewSleepNoticeFrame")
	if sleepnum and icon and newsleepframe then
		if ClientCurGame:isInGame() and AccountManager:getMultiPlayer() > 0 then
		--联机
			newsleepframe:Show()
			threadpool:work(function ()
				local num = 0
				local totalNum = TotalSleepingNums()
				-- 打开循环开关，在Hide的时候再关闭
				checkingSleepingPlayers = true
				while checkingSleepingPlayers do
					num = CurrentSleepingNums()
					totalNum = TotalSleepingNums()
					sleepnum:SetText(tostring(num).."/"..tostring(totalNum))
					threadpool:wait(0.5)
				end
			end)
		else
		--单机
		newsleepframe:Hide()
		end
	end
end

function HideSleepNoticeFrame()
    if ClientCurGame and ClientCurGame.setOperateUI then
		if not IsUGCEditing() then
			ClientCurGame:setOperateUI(false)
		end
	end
	local frame = getglobal("SleepNoticeFrame")
	if frame and frame:IsShown() then
        frame:Hide()
        checkingSleepingPlayers = false
	end
end

function HideNewSleepNoticeFrame()
	if ClientCurGame and ClientCurGame.setOperateUI then
		ClientCurGame:setOperateUI(false)
	end
	local newframe = getglobal("NewSleepNoticeFrame")
	if newframe and newframe:IsShown() then
        newframe:Hide()
        checkingSleepingPlayers = false
	end
end


function UpdateMainFucBtn(rideType)
	getglobal("PlayMainFrameFly"):Hide();
	getglobal("PlayMainFrameSneak"):Hide();
	RideHPBar_ShowOrHide(false);
	PlayerHPBar_ShowOrHide(false);
	getglobal("PlayMainFrameRide"):Hide();
	getglobal("PlayMainFrameBed"):Hide();
    getglobal("ChickenEnergyFrame"):Hide();
    -- if LuaInterface:shouldUseNewHpRule() then--如果是冒险模式和创造转冒险就进行隐藏
		HideNewSleepNoticeFrame()
	-- else
	-- 	HideSleepNoticeFrame()
	--end
	setVehicleUI(false)
	--if ClientMgr:isMobile() then
	--	getglobal("Mobile_Rect_VehicleControlFrame"):Hide()
	--end
	local type = CurMainPlayer:getMountType();

	if type > 0 then	--坐骑、椅子、床
        if CurMainPlayer:getOPWay() == 0 and not CurMainPlayer:isShapeShift() then
            if type == 2 then --如果是床就显示下床按钮
				getglobal("PlayMainFrameBed"):Show();
			else
				getglobal("PlayMainFrameRide"):Show();
			end
			if type == MOUNT_SLEEP and CurWorld and CurWorld.isDaytime and not CurWorld:isDaytime() then
				-- 只有不是白天且躺在床上时才可以显示睡觉提示弹窗
				if true --[[LuaInterface:shouldUseNewHpRule()--]] then--如果是冒险模式和创造转冒险就进行隐藏
					PlayMainFrameSleepBtn_OnClick()
					NewShowSleepNoticeFrame()
				else
					ShowSleepNoticeFrame()
				end
			end
		end
		if type == MOUNT_RIDE then		--坐骑、矿车、船
			local ride = CurMainPlayer:getRidingHorse()
			if ride ~= nil then
				if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
				else
					PlayMain.RideHP:reset();
					RideHPBar_ShowOrHide(true);
					if ride:hasHorseSkill(HORSE_SKILL_MUTATE_FLY) then    --飞鸡坐骑
						getglobal("ChickenEnergyFrame"):Show();
					end
				end
			else
				if not CurWorld:isCreativeMode() and not CurWorld:isGameMakerMode() then
					if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
						PlayerHPBar_ShowOrHide(false)
					elseif not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.BLOOD) then --xyang自定义UI
						PlayerHPBar_ShowOrHide(false)
					else
						PlayerHPBar_ShowOrHide(true)
					end
				end
			end
		elseif type == MOUNT_DRIVE then 	--物理机械
			--一期没有血量显示，先注释掉
			--local vehicle = CurMainPlayer:getDrivingVehicle()
			--if vehicle ~= nil then
			--	local hp = math.ceil(vehicle:getLifeCurrent());
			--	local maxHP = vehicle:getLifeLimit()
			--	getglobal("RideHPBarCur"):SetWidth(266*hp/maxHP);
			--	getglobal("RideHPBarRatio"):SetText(hp.."/"..maxHP);
			--	RideHPBar_ShowOrHide(true);
			--end
			getglobal("PlayMainFrameRide"):Hide()
			getglobal("PlayMainFrameBed"):Hide()
			setVehicleUI(true)
			if IsUIFrameShown("PackingCM") then --如果微缩工具在使用则关闭
				GetInst("UIManager"):GetCtrl("PackingCM"):CloseBtnClicked()
			end
			if IsUIFrameShown("MapEdit") then --如果地形编辑工具在使用则关闭
				GetInst("UIManager"):GetCtrl("MapEdit"):CloseBtnClicked()
			end
		end

		if CurWorld:isGodMode() then
			if CurMainPlayer:isFlying() then
				CurMainPlayer:setFlying(false);
			end
		else
			local rocket = CurMainPlayer:getRidingRocket();
			if type ~= MOUNT_RIDE or rocket then
				if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
					PlayerHPBar_ShowOrHide(false);
				elseif not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.BLOOD) then --xyang自定义UI
					PlayerHPBar_ShowOrHide(false);
				else
					PlayerHPBar_ShowOrHide(true);
				end
			end
		end
	else
		if CurWorld:isGodMode()  then
			if CurMainPlayer:getOPWay() == 0 and ClientMgr:isMobile() then
				getglobal("PlayMainFrameFly"):Show();
			end
		else
			if ClientMgr:isMobile() and CurMainPlayer:getOPWay() == 0 then
				if not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.OPERATION) then
					getglobal("PlayMainFrameSneak"):Hide();
				else
					getglobal("PlayMainFrameSneak"):Show();
				end
			end
			if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
				PlayerHPBar_ShowOrHide(false);
			elseif not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.BLOOD) then --xyang自定义UI
				PlayerHPBar_ShowOrHide(false);
			else
				PlayerHPBar_ShowOrHide(true);
			end
		end
	end
end

function UpdateUIBtnByOPWayChange()
	if CurMainPlayer:getOPWay() == 1 then --球模式
		getglobal("PlayMainFrameSneak"):Hide();
		getglobal("PlayMainFrameRide"):Hide();
		getglobal("PlayMainFrameBed"):Hide();
		getglobal("PlayMainFrameFly"):Hide();

		if ClientMgr:isPC() and not getkv("ball_operate_guide") then
			ShowBallOperateTipsTime = 10;
			getglobal("PcGuideKeySightModeTips"):SetText(GetS(1348));
			getglobal("PcGuideKeySightMode"):Show();
			setkv("ball_operate_guide", true);
		end

		if CurWorld and CurWorld:isGodMode() then
			if CurMainPlayer and CurMainPlayer:isFlying() then
				CurMainPlayer:setFlying(false);
			end
		end
	elseif CurMainPlayer:getOPWay() == 3 then
		getglobal("PlayMainFrameSneak"):Hide();
		getglobal("PlayMainFrameRide"):Hide();
		getglobal("PlayMainFrameBed"):Hide();
		getglobal("PlayMainFrameFly"):Hide();

		if ClientMgr:isPC() and not getkv("basketball_operate_guide") then
			ShowBallOperateTipsTime = 10;
			getglobal("PcGuideKeySightModeTips"):SetText(GetS(29999));
			local lWidth = getglobal("PcGuideKeySightModeTips"):GetTextExtentWidth(GetS(29999));
			getglobal("PcGuideKeySightMode"):SetWidth(lWidth+30);
			getglobal("PcGuideKeySightMode"):Show();
			setkv("basketball_operate_guide", true);
		end

		if CurWorld and CurWorld:isGodMode() then
			if CurMainPlayer and CurMainPlayer:isFlying() then
				CurMainPlayer:setFlying(false);
			end
		end
	else
		if CurMainPlayer:getMountType() > 0 then
			if CurMainPlayer:getMountType() ~= MOUNT_DRIVE then
				getglobal("PlayMainFrameRide"):Show();
			end
		else

			if CurWorld then
				if CurWorld:isGodMode() then
					if ClientMgr:isMobile() then
						getglobal("PlayMainFrameFly"):Show();
					end
				else
					if ClientMgr:isMobile() then
						if not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.OPERATION) then
							getglobal("PlayMainFrameSneak"):Hide();
						else
							getglobal("PlayMainFrameSneak"):Show();
						end
					end
				end
			end
		end
	end
end

TraceBlockIsShow = false;

local t_BGM = {
	[0] = {
		day = {
			"sounds/music/bgm_day_1.ogg",
			"sounds/music/bgm_day_2.ogg",
			"sounds/music/bgm_day_3.ogg",
			"sounds/music/bgm_day_4.ogg",
			"sounds/music/bgm_day_5.ogg",
		},
		night = {
			"sounds/music/bgm_night_1.ogg",
			"sounds/music/bgm_night_2.ogg",
			"sounds/music/bgm_night_3.ogg",
			"sounds/music/bgm_night_4.ogg",
			"sounds/music/bgm_night_5.ogg",
		},
	},
	[1] = {
		day = {
			"sounds/music/bgm_earthcore_day_1.ogg",
		},
		night = {
			"sounds/music/bgm_earthcore_night_1.ogg",
		}
	},
	[2] = {
		day = {
			"sounds/music/bgm_planet_day_1.ogg",
			"sounds/music/bgm_planet_day_2.ogg",
			"sounds/music/bgm_planet_day_3.ogg",
			"sounds/music/bgm_planet_day_4.ogg",
		},
		night = {
			"sounds/music/bgm_planet_night_1.ogg",
			"sounds/music/bgm_planet_night_2.ogg",
			"sounds/music/bgm_planet_night_3.ogg",
		},
	},
}


local t_BGMAmbient = {
	day = {
		[BIOME_RAINFOREST] = {"sounds/env/Jungleday.ogg"},
		[BIOME_VOLCANO] = {"sounds/env/volcano.ogg"},
		[BIOME_AIR_PLAINS] = {"sounds/env/skypiea.ogg"},
	},
	night = {
		[BIOME_RAINFOREST] = {"sounds/env/Junglenight.ogg"},
		[BIOME_VOLCANO] = {"sounds/env/volcano.ogg"},
		[BIOME_AIR_PLAINS] = {"sounds/env/skypiea.ogg"},
	}
}


PlayBossMusic = false;
MusicFrequency = 300;
LeaveRoomType = 0;		--1主机关闭房间 2主机退出游戏
SendMsgWaitTime = 0;
_G.LastBiomeType = -1;
local lastMapID = 0;

if ClientMgr and ClientMgr:isPC() and not AccountManager:getNoviceGuideState("guidekey") then
	GuideKeyountdown = 60; --1分钟
end

function PlayMusicByBoss(code, bossId)
	if code == -1 then
		if not isPlayingAtlmanMusic then
			ClientMgr:stopMusic()
		end
		PlayBossMusic = false;
		MusicFrequency = -1;
	elseif code == -2 then
		if not isPlayingAtlmanMusic then
			ClientMgr:stopMusic()
		end
		PlayBossMusic = true;
		if bossId >= 3502 and bossId <= 3504 then
			if not isPlayingAtlmanMusic then
				ClientMgr:playMusic("sounds/music/boss_earthcore_1.ogg", true)
			end
            lastMusicName = "sounds/music/boss_earthcore_1.ogg"
		elseif bossId == 3510 or bossId == 3514 then
			if not isPlayingAtlmanMusic then
				ClientMgr:playMusic("sounds/music/boss_golem_1.ogg", true)
			end
            lastMusicName = "sounds/music/boss_golem_1.ogg"
		elseif bossId == 3515 then
			if not isPlayingAtlmanMusic then
				ClientMgr:playMusic("sounds/music/boss_voidwalker_1.ogg", true)
			end
            lastMusicName = "sounds/music/boss_voidwalker_1.ogg"
		elseif bossId == 3516 then
			if not isPlayingAtlmanMusic then
				ClientMgr:playMusic("sounds/music/boss_voidwalker_2.ogg", true);
			end
            lastMusicName = "sounds/music/boss_voidwalker_2.ogg"
		elseif bossId == 3519 then
			if not isPlayingAtlmanMusic then
				ClientMgr:playMusic("sounds/music/boss_nianshou.ogg", true);
			end
            lastMusicName = "sounds/music/boss_nianshou.ogg"
		end
	end
end

local function getCurBiomeType()
	if CurMainPlayer then
		local x, y, z = CurMainPlayer:getPosition(0,0,0)
		x = math.floor(x / 100)
		z = math.floor(z / 100)
		if CurWorld.getBiomeType then
			local biometype = CurWorld:getBiomeType(x, z)
			if biometype >= BIOME_VOLCANO and biometype <= BIOME_VOLCANO_CORE then -- 都是火山地形
				return BIOME_VOLCANO
			end
			return biometype
		end
	end
	return 0
end

local begin_time=0;
local flag=1;
local BGMSound_ChangeVal = 0.01;
local BGMSound_CurVal = 0;
function PlayMainFrame_OnUpdate()
	local musicMode = 0;
	local id = 0;
	local curBiometype = getCurBiomeType()

	musicMode,id = CurWorld:getBGMusicMode(id);
	if musicMode == 0 and CurWorld:getOWID() ~= NewbieWorldId and CurWorld:getOWID() ~= NewbieWorldId2 then
		if not PlayBossMusic then
			MusicFrequency = MusicFrequency - arg1;
			if CurWorld and CurWorld:getCurMapID() ~= lastMapID then
				lastMapID = CurWorld:getCurMapID();
				if CurWorld:getCurMapID() ~= 2 then  --去萌眼星之后，会先播放bgm_planet_land
					MusicFrequency = -1
				end
			end

			if MusicFrequency < 0 and not FesivialActivity:TonightIsTiangou() then
				MusicFrequency =  math.random(250, 300);
				
				local curMapId = CurWorld and CurWorld:getCurMapID() or 0;
				local hour = ClientCurGame:getGameTimeHour();
				local timeType = (hour>=7 and hour<=18) and "day" or "night";
				local t = t_BGM[curMapId][timeType];

				if not isPlayingAtlmanMusic then
					ClientMgr:stopMusic()
				end
				local randomIndex = math.random(1, #(t));
				print("kekeke playMusic", t, randomIndex, t[randomIndex]);
				if not isPlayingAtlmanMusic then
					ClientMgr:playMusic(t[randomIndex], false)
				end
                lastMusicName = t[randomIndex]
			end
		end

		--print("kekeke curBiometype", curBiometype, LastBiomeType);
		if curBiometype ~= LastBiomeType then -- 部分地形音效特别(雨林、火山、空岛等)
			if BGMSound_CurVal < 0 then
				BGMSound_CurVal = 0;
			elseif BGMSound_CurVal > 1 then
				BGMSound_CurVal = 1;
			end

			local hour = ClientCurGame:getGameTimeHour();
			local timeType = (hour>=7 and hour<=18) and "day" or "night";
			local sound = t_BGMAmbient[timeType][curBiometype] or "";
			if sound ~= "" then
				local randomIndex = math.random(1, #(sound));
				sound = sound[randomIndex];
				BGMSound_ChangeVal = 0.025;
				
				ClientMgr:playBGMSound2D2DControl(sound, BGMSound_CurVal, true);
			else
				BGMSound_ChangeVal = -0.025;
			end
		end
	end

	BGMSound_CurVal = BGMSound_CurVal + BGMSound_ChangeVal;
	if BGMSound_CurVal < 0 then
		--print("kgq BGMSound_CurVal", BGMSound_CurVal)
		ClientMgr:playBGMSound2D2DControl("", BGMSound_CurVal, true);
	elseif BGMSound_CurVal <= 1 then
		--print("kgq BGMSound_CurVal", BGMSound_CurVal)
		ClientMgr:setBGMSoundVolume(BGMSound_CurVal);
	end

	-- 氛围罩
	UpdateBiomeAmbient(curBiometype)

	-- 黑名单踢人
	QueryAndKickPlayerInBlackList();

	--最近玩伴添加
	UpdatePlaymateInGame();

	--新手
	if CurWorld:getOWID() == NewbieWorldId then
		if AccountManager:getCurNoviceGuideTask() == 4 and not TraceBlockIsShow then
			TraceBlockIsShow = CurMainPlayer:beginTraceBlock(650);
		elseif AccountManager:getCurNoviceGuideTask() == 6 and not TraceBlockIsShow then
			TraceBlockIsShow = CurMainPlayer:beginTraceBlock(200);
		end
		--临时方案
		getglobal("CharacterActionBtn"):Hide()
	end

	if SwapBlinkBtnName ~= nil then
		local blinkTexture = getglobal(SwapBlinkBtnName.."Check");
		if SwapBlinkTime > 0 then
			SwapBlinkTime =  SwapBlinkTime - 1;
			if blinkTexture:IsShown() then
				blinkTexture:Hide();
			else
				blinkTexture:Show();
			end
		else
			if blinkTexture:IsShown() then
				blinkTexture:Hide();
			end
			SwapBlinkBtnName = nil;
			SwapBlinkTime = 4;
		end
	end

	if ClientMgr:isPC() and not AccountManager:getNoviceGuideState("guidekey") then
		GuideKeyountdown = GuideKeyountdown - arg1;
		if GuideKeyountdown < 0 then
			AccountManager:setNoviceGuideState("guidekey", true);
			GuideKey_Finish();
		end
	end

	if ApplyPermitsCD > 0 then
		ApplyPermitsCD = ApplyPermitsCD - arg1;
		if ApplyPermitsCD <= 0 then
			ApplyPermitsCD = -1;
		end
	end

	--房间退出信息
	if SendMsgWaitTime > 0 then
		SendMsgWaitTime = SendMsgWaitTime - arg1;
		if SendMsgWaitTime <= 0 then
			if LeaveRoomType == 1 then
				GoToMainMenu();
			elseif LeaveRoomType == 2 then
				GameExit();
			elseif LeaveRoomType == 3 then

			end
		end
	end



	if ShowBallOperateTipsTime > 0 then
		ShowBallOperateTipsTime = ShowBallOperateTipsTime - arg1;
		if ShowBallOperateTipsTime < 0 then
			getglobal("PcGuideKeySightMode"):Hide();
			getglobal("PcGuideKeySightModeTips"):SetText(GetS(3839));
			getglobal("PcGuideKeySightMode"):SetWidth(420);
		end
	end

	local tipsFrame=getglobal("PhysxTipsFrame")
	local bkg=getglobal("PhysxTipsFrameBkg");
	local name=getglobal("PhysxTipsFrameName")

	if CurWorld then
		if CurWorld:isGodMode() and ClientMgr:getGameData("physxparam")==1 and DebugMgr:getMapStability()<30 and begin_time==0 then
			begin_time=os.time();
		end
	end

	--local tipsFrame=getglobal("PhysxTipsFrame");
	local cur_lang=get_game_lang();
	local end_time=os.time();
	local staytime= end_time-begin_time;
	local mobile_offset = 0;		--手机版字体较小，提示框做适当偏移

	if ClientMgr:isMobile() then
		mobile_offset = -60;
	end
	if CurWorld then
		if CurWorld:isGodMode() then
			if ClientMgr:getGameData("physxparam")==0 then
				tipsFrame:Hide()
			else
				if DebugMgr:getMapStability()<30 then
					if cur_lang==0 or cur_lang==2 then
						if DebugMgr:IsDevBuild() == true and ClientMgr:getGameData("fpsbuttom")==1 then
							tipsFrame:SetPoint("topleft", "PlayMainFrame", "topleft", 285 + mobile_offset, 40)
						elseif DebugMgr:IsDevBuild() == true or ClientMgr:getGameData("fpsbuttom")==1 then
							tipsFrame:SetPoint("topleft", "PlayMainFrame", "topleft", 173 + mobile_offset, 40)
						elseif DebugMgr:IsDevBuild() == false and ClientMgr:getGameData("fpsbuttom")==0 then
							tipsFrame:SetPoint("topleft", "PlayMainFrame", "topleft", 5, 40)
						end

					else
						--其他语言字体较小，提示框位置需要调整
						if DebugMgr:IsDevBuild() == true and ClientMgr:getGameData("fpsbuttom")==1 then
							tipsFrame:SetPoint("TOPLEFT", "PlayMainFrame", "TOPLEFT", 205 + mobile_offset, 40)
						elseif DebugMgr:IsDevBuild() == true or ClientMgr:getGameData("fpsbuttom")==1 then
							tipsFrame:SetPoint("TOPLEFT", "PlayMainFrame", "TOPLEFT", 120 + mobile_offset, 40)
						elseif DebugMgr:IsDevBuild() == false and ClientMgr:getGameData("fpsbuttom")==0 then
							tipsFrame:SetPoint("TOPLEFT", "PlayMainFrame", "TOPLEFT", 5 , 40)
						end
					end
					bkg:SetPoint("topleft", "PhysxTipsFrame", "topleft", -2, -5)
					name:SetPoint("center", "PhysxTipsFrameBkg", "center", 0, 3)
					if staytime<=3 and flag==1 then
						tipsFrame:Show();
					else
						begin_time=0;
						flag=0;
						tipsFrame:Hide();
					end
				else
					begin_time=0;
					flag=1;
					tipsFrame:Hide()
				end
			end
		else
			tipsFrame:Hide()
		end
	else
		tipsFrame:Hide()
	end

	--if CurMainPlayer and CurMainPlayer:getMountType() == MOUNT_DRIVE then
	--	setVehicleUI(true)
	--end
	if CurWorld:isGameMakerRunMode()  then
		if ClientCurGame:getGameStage() ~= CGAME_STAGE_SHOWINTROS then
			managePassPortCountDown();
		end
	else
		managePassPortCountDown();
    end
    
    local daytime = CurWorld:getHours()
    local hour = math.floor(daytime)
    local min = math.floor((daytime-hour)*60)
    
    --游戏时间过渡到18点时，马上显示睡觉UI界面
    --躺床上或者睡觉
    local RestOrSleep = (CurMainPlayer.isRestInBed and CurMainPlayer:isRestInBed()) or (CurMainPlayer.isSleeping and CurMainPlayer:isSleeping())

    if CurWorld and hour == 18 and min == 0 and (CurMainPlayer.isRestInBed and CurMainPlayer:isRestInBed() and (not getglobal("SleepNoticeFrame"):IsShown())) then
        local BuffFrame = getglobal("BuffFrame")
		if BuffFrame:IsShown() then
            BuffFrame:Hide()
        end
            
		if true --[[LuaInterface:shouldUseNewHpRule()--]] then--如果是冒险模式和创造转冒险就进行隐藏
			PlayMainFrameSleepBtn_OnClick()
			NewShowSleepNoticeFrame()
		else
			ShowSleepNoticeFrame()
		end
        CurMainPlayer:getLivingAttrib():removeBuff(80);
	elseif CurWorld and hour == 6 and min == 0 and RestOrSleep and getglobal("SleepNoticeFrame"):IsShown() then
		if true --[[LuaInterface:shouldUseNewHpRule()--]] then--如果是冒险模式和创造转冒险就进行隐藏
			HideNewSleepNoticeFrame()
		else
			HideSleepNoticeFrame()
			CurMainPlayer:getLivingAttrib():addBuff(80, 1);
		end
    end

	--for education
	Edu_OnUpdate()

	LastBiomeType = curBiometype
	
	UpdateRiddleBird()

	CheckXumengYuanPopUp()
	-- CheckMoneyGodBtnPopUp()  --先注释了
	--检测到移动后停止互动动作
	stopActorInviteAct()
	-- Show_PlayMainAskAddFriend()
	-- CheckAwakenBtnPopUp()    --活动下架注释掉

	CheckShowWaterPressureGuage()
	checkShowOxygenBarShow()
end


-- 更新氛围罩
function UpdateBiomeAmbient(biometype)
	if biometype == LastBiomeType then
		return
	end

	-- 火山氛围罩   -- 策划说效果不好看，暂时去掉
	-- if biometype == BIOME_VOLCANO then
	-- 	getglobal("VolcanoAmbient"):Show()
	-- elseif lastBiomeType == BIOME_VOLCANO then
	-- 	getglobal("VolcanoAmbient"):Hide()
	-- end
end

function EnterWorld(mapid)
	local curWorldId = nil
	
	if mapid == 0 or mapid == 2 then	--进入了主世界或者太空
		-- if getglobal("MiniLobbyFrame"):IsShown() then
		-- 	getglobal("MiniLobbyFrame"):Hide();
		-- end
		HideMiniLobby(); --mark by hfb for new minilobby
		
		UpdateTaskTrackFrame();			--刷新成就追踪面板
		if getglobal("InstanceTaskFrame"):IsShown() then
			getglobal("InstanceTaskFrame"):Hide();
		end
		if getglobal("BossHpFrame"):IsShown() then
			getglobal("BossHpFrame"):Hide();
		end
		if getglobal("IntroduceFrame"):IsShown() then
			getglobal("IntroduceFrame"):Hide();
        end
        
        local worldid = 0
        local isRoomOwner = IsRoomOwner()
        if isRoomOwner or AccountManager:getMultiPlayer() == 0 then   -- 单机或房主
            local wdesc = AccountManager:getCurWorldDesc();
            if wdesc then
                worldid = wdesc.fromowid
                if wdesc.fromowid == 0 then
                    worldid = wdesc.worldid
                end
            end
			
			curWorldId = worldid
        else    -- 客机
            worldid = DeveloperFromOwid
			
			curWorldId = worldid

            -- 云服客机不能只用worldId当作标识，否则会导致同一张图开不同云服，只有第一个有弹窗
            local csroomid = GetCurrentCSRoomId()

            if csroomid and csroomid ~= "" then
                worldid = ""..worldid.."_"..csroomid
            end
        end

		if worldid and worldid ~= 0 then
			local mapflage="ExtremityTipsFrame_Space".."_"..worldid;
			if mapid==2 and not getkv(mapflage) then --进入太空世界显示系统弹框
				setkv(mapflage,true);
				if RecordPkgMgr:isRecordPlaying() == false then
					getglobal("ExtremityTipsFrame"):Show();
				end
			end
		end

		if mapid == 0 then
			PlayBGMusicByMainWorld();
		elseif mapid == 2 then
			MusicFrequency = 77;
			if not isPlayingAtlmanMusic then
				ClientMgr:playMusic("sounds/music/bgm_planet_land.ogg", false)
			end
            lastMusicName = "sounds/music/bgm_planet_land.ogg"
		end
	else			--进入了副本
		-- getglobal("TaskTrackFrame"):Hide();			--隐藏成就追踪面板 --改版后就不隐藏了 code_by:huangfubin
		-- SetCurIntanceGoal(mapid);
		getglobal("InstanceTaskFrame"):Show();
	end
	SetCurIntanceGoal(mapid)
	getglobal("CharacterActionBtn"):Show()
	--刷新表情数据
	UpdataActionDate()
	if showActorInviteReddot() then 
		getglobal("CharacterActionRedTag"):Show()
	else
		getglobal("CharacterActionRedTag"):Hide()
	end 
	lastTimeCombineTransform = 0
	--租赁服
	--RentPermitCtrl:ShowRentNoticePopup()
	AvatarSummonIndex = 0

	MobileTipsShowed = false	--首次进入地图，重置免流量显示状态
	
	--音乐方块进入地图切换地图等操作
	if AccountManager then
		local isRoomOwner = IsRoomOwner()
		if AccountManager:getMultiPlayer() == 0 or isRoomOwner  then --主机和单机
			if CurMainPlayer then
				if DealMusicClubIns then
					if DealMusicClubIns.updateAreaId then
						DealMusicClubIns:updateAreaId(mapid);
						--mapid
					end
				end
			end
		else --客机
			if MusicClubSyncIns then
				MusicClubSyncIns:ReqAreaPos(GetMyUin(),mapid);
			end
		end
	end

	local createFestivalMgr = GetInst("NationalCreateFestivalMgr")
	if createFestivalMgr then
		local wdesc = AccountManager:getCurWorldDesc()
		createFestivalMgr:EnterWorldRecordTime(wdesc)
	end
	
	-- 进入地图记录时间
	local cInterface = GetInst("CreationCenterInterface")
	if cInterface then 
		local wdesc = AccountManager:getCurWorldDesc()
		cInterface:EnterDvpModeTime(wdesc)
	end 
	GetInst("TriggerMapInteractiveInterFace"):InGame()
	GetInst("NewDeveloperStoreInterface"):InGame()
	GetInst("TitleSystemInterface"):InGame()
	GetInst("GameTimeLenthReport"):InGame()
	GetInst("HideUnmoderatedTextManger"):InGame()
	GetInst("BestPartnerManager"):InGame()
	--进入地图打开聊天框
	GetInst("MiniUIManager"):HideUI("ChatHoverBallAutoGen")
	
	-- 凹凸世界-勋章退出游戏上报
	pcall(function ()
		if GetInst("AotuActInterface") then 
			if curWorldId and curWorldId ~= 0 then
				GetInst("AotuActInterface"):ReportQuitMapAotuMedal(curWorldId)
			end
		end 
	end)
end

function SetMainUIState()
	local ride = CurMainPlayer:getRidingHorse();
	local vehicle = CurMainPlayer:getDrivingVehicle();
	local mountType = CurMainPlayer:getMountType()
	if CurWorld:isCreativeMode() then	--创造模式
		getglobal("PlayMainFrameSneak"):Hide();				--潜行
		PlayerHPBar_ShowOrHide(false);				--血条
		getglobal("PlayerStrengthBar"):Hide();				--体力
		PlayerHungerBar_ShowOrHide(false);				--饥饿度
		-- getglobal("PlayerExpBar"):Hide();				--经验条
		LevelExpBar_ShowOrHide(false);
		getglobal("GongNengFrameRuleSetGNBtn"):Hide();			--玩家编辑设置
		getglobal("GongNengFramePluginLibBtn"):Hide();			--插件库

		if mountType > 0 then			--坐骑、矿车、床
			getglobal("PlayMainFrameFly"):Hide();			--飞行按钮
			if mountType~=MOUNT_DRIVE then
				if mountType == 2 --[[and LuaInterface:shouldUseNewHpRule()--]] then
					getglobal("PlayMainFrameBed"):Show();
				else
				 	getglobal("PlayMainFrameRide"):Show();	--上下坐骑按钮
				end	
			end
		else
			--if LuaInterface:shouldUseNewHpRule() then
				getglobal("PlayMainFrameBed"):Hide()	
			--end
			getglobal("PlayMainFrameRide"):Hide();			--上下坐骑按钮
			if CurMainPlayer:getOPWay() == 0 then
				getglobal("PlayMainFrameFly"):Show();			--飞行按钮
			else
				getglobal("PlayMainFrameFly"):Hide();
			end
		end
		if ride ~= nil then						--骑着坐骑
			if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
			else
				RideHPBar_ShowOrHide(true);			--坐骑血条
				PlayMain.RideHP:reset();
				if ride:hasHorseSkill(HORSE_SKILL_MUTATE_FLY) then    --飞鸡坐骑
					getglobal("ChickenEnergyFrame"):Show();
				end
			end
		else
			RideHPBar_ShowOrHide(false);			--坐骑血条
			getglobal("ChickenEnergyFrame"):Hide();     --小鸡坐骑能量条
		end
	elseif CurWorld:isGameMakerMode() then	--玩家编辑模式
		getglobal("PlayMainFrameSneak"):Hide();				--潜行
		PlayerHPBar_ShowOrHide(false);				--血条
		getglobal("PlayerStrengthBar"):Hide();				--体力
		PlayerHungerBar_ShowOrHide(false);				--饥饿度
		-- getglobal("PlayerExpBar"):Hide();				--经验条
		LevelExpBar_ShowOrHide(false);
		local wdesc = AccountManager:getCurWorldDesc();
		if AccountManager:getMultiPlayer() ~= 0 or (wdesc and wdesc.realowneruin ~= AccountManager:getUin()) then --联机或者下载的地图
			getglobal("GongNengFrameRuleSetGNBtn"):Hide();		--玩家编辑设置
			getglobal("GongNengFramePluginLibBtn"):Hide();			--插件库
		else
			getglobal("GongNengFrameRuleSetGNBtn"):Show();
			if EnableDeveloper and not (UGCModeMgr and UGCModeMgr:IsUGCMode()) then
				getglobal("GongNengFramePluginLibBtn"):Show();			--插件库
			else
				getglobal("GongNengFramePluginLibBtn"):Hide();			--插件库
			end 

			--LLDO:红点,editmode
			local retTag = getglobal("GongNengFrameRuleSetGNBtnRedTag");
            if not AccountManager:getNoviceGuideState("editmode") then
                retTag:Show();
            else
                retTag:Hide();
            end
		end
		if ClientMgr:isMobile() then
			if mountType > 0 then       			--坐骑、矿车、床
				if mountType ~= MOUNT_DRIVE then
					getglobal("PlayMainFrameSneak"):Hide();--潜行按钮
					if mountType == 2 --[[and LuaInterface:shouldUseNewHpRule()--]] then--床并且是冒险模式
						getglobal("PlayMainFrameBed"):Show();
					else
					 	getglobal("PlayMainFrameRide"):Show();	--上下坐骑按钮
					end		
				end
			else
				getglobal("PlayMainFrameBed"):Hide();
				getglobal("PlayMainFrameRide"):Hide();			--上下坐骑按钮
				if CurMainPlayer:getOPWay() == 0 then
					getglobal("PlayMainFrameFly"):Show();			--飞行按钮
				else
					getglobal("PlayMainFrameFly"):Hide();
				end
			end
		end

		if ride ~= nil then						--骑着坐骑
			if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
			else
				PlayMain.RideHP:reset();
				RideHPBar_ShowOrHide(true);			--坐骑血条
				if ride:hasHorseSkill(HORSE_SKILL_MUTATE_FLY) then    --飞鸡坐骑
					getglobal("ChickenEnergyFrame"):Show();
				end
			end
		elseif vehicle ~= nil then
			--RideHPBar_ShowOrHide(true);			--坐骑血条
			--local hp = math.ceil(vehicle:getLifeCurrent());
			--local maxHP = vehicle:getLifeLimit()
			--getglobal("RideHPBarCur"):SetWidth(266*hp/maxHP);
			--getglobal("RideHPBarRatio"):SetText(hp.."/"..maxHP);
		else
			RideHPBar_ShowOrHide(false);			--坐骑血条
			getglobal("ChickenEnergyFrame"):Hide();     --小鸡坐骑能量条
		end
	else
		getglobal("PlayMainFrameFly"):Hide();				--飞行按钮
		getglobal("GongNengFrameRuleSetGNBtn"):Hide();			--玩家编辑设置
		getglobal("GongNengFramePluginLibBtn"):Hide();			--插件库
		if MainPlayerAttrib:useCompatibleStrength() then
			if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
				getglobal("PlayerStrengthBar"):Hide();				--体力值
			elseif not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.BLOOD) then --xyang自定义UI
				getglobal("PlayerStrengthBar"):Hide();
			else
				getglobal("PlayerStrengthBar"):Show();
			end
			PlayerHungerBar_ShowOrHide(false);
		else
			if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
				PlayerHungerBar_ShowOrHide(false);				--饥饿度
			elseif not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.BLOOD) then --xyang自定义UI
				PlayerHungerBar_ShowOrHide(false);
			else
				PlayerHungerBar_ShowOrHide(true);
			end
			getglobal("PlayerStrengthBar"):Hide();
		end
		if MainPlayerAttrib:getAttrShapeShift() then -- 属性变身要屏蔽内容
			getglobal("PlayerStrengthBar"):Hide();				--体力值
			PlayerHungerBar_ShowOrHide(false);				--饥饿度
		end
		if ClientMgr:isMobile() then
			if mountType > 0 then	--坐骑、矿车、床
				if mountType ~= MOUNT_DRIVE then
					getglobal("PlayMainFrameSneak"):Hide();			--潜行按钮
					getglobal("PlayMainFrameRide"):Show();			--上下坐骑按钮
				end
			else
				getglobal("PlayMainFrameRide"):Hide();			--上下坐骑按钮
				if not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.OPERATION) then
					getglobal("PlayMainFrameSneak"):Hide();		--潜行按钮
				else
					getglobal("PlayMainFrameSneak"):Show();
				end
			end
		end

		if ride ~= nil then						--骑着坐骑
			if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
			else
				RideHPBar_ShowOrHide(true);			--坐骑血条
				PlayMain.RideHP:reset();

				PlayerHPBar_ShowOrHide(false);			--人物血条
				if ride:hasHorseSkill(HORSE_SKILL_MUTATE_FLY) then    --飞鸡坐骑
					getglobal("ChickenEnergyFrame"):Show();
				end
			end
		else
			RideHPBar_ShowOrHide(false);			--坐骑血条
			if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
				PlayerHPBar_ShowOrHide(false);			--人物血条
			elseif not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.BLOOD) then --xyang自定义UI
				PlayerHPBar_ShowOrHide(false);
			else
				PlayerHPBar_ShowOrHide(true);			--人物血条
			end
			getglobal("ChickenEnergyFrame"):Hide();     --小鸡坐骑能量条
		end

		local starbkg1 = getglobal("PlayerExpBarStarBkg1");

		if CurMainPlayer ~= nil and CurMainPlayer:isInSpectatorMode() then
			starbkg1:Hide();
			-- getglobal("PlayerExpBar"):Hide();				--经验条
			LevelExpBar_ShowOrHide(false);
		else
			starbkg1:Show();
			-- getglobal("PlayerExpBar"):Show();				--经验条
			if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.OBJECT) then --xyang自定义UI
				LevelExpBar_ShowOrHide(true);
			end
		end

		if CurWorld:isCreateRunMode() then
			starbkg1:SetTexUV("juese_xingxing03.png");
		elseif CurWorld:isExtremityMode() then
			starbkg1:SetTexUV("juese_xingxing02.png");
		elseif CurWorld:isFreeMode() then
			starbkg1:SetTexUV("juese_xingxing06.png");
		elseif CurWorld:isGameMakerRunMode() then
			starbkg1:SetTexUV("juese_xingxing04.png");
		elseif CurWorld:isSurviveMode() then
			starbkg1:SetTexUV("juese_xingxing05.png");
		elseif CurWorld:isCreativeMode() or CurWorld:isGameMakerMode() then
			starbkg1:Hide();
		end
	end

	if CurMainPlayer:getOPWay() == 1 or CurMainPlayer:getOPWay() == 3 then      --球模式下，下坐骑、潜行按钮隐藏
		getglobal("PlayMainFrameRide"):Hide();
		getglobal("PlayMainFrameBed"):Hide();
		getglobal("PlayMainFrameSneak"):Hide();
	end

	GongNengFrame_OnBtnVisibleChange();
	

end

function SetAttriVal()
	--血量
	local lifeNum = CurMainPlayer:getLeftLifeNum();
	if lifeNum >= 0 then
		getglobal("PlayerHPBarLifeNum"):SetText(CurMainPlayer:getLeftLifeNum());
	else
		getglobal("PlayerHPBarLifeNum"):SetText("");
	end
	--getglobal("PlayerHPBar"):SetCurValue(math.ceil(MainPlayerAttrib:getHP())/MainPlayerAttrib:getMaxHP(), true)
	--CurPlayerHp = math.ceil(MainPlayerAttrib:getHP());
	--饥饿度
	--getglobal("PlayerHungerBar"):SetCurValue(MainPlayerAttrib:getFoodLevel()/20, true);
	--CurPlayerFoodLevel = MainPlayerAttrib:getFoodLevel();
	--CurPlayerFoodSatLevel = MainPlayerAttrib:getFoodSatLevel();
	--经验值
	CurPlayerExpVal = MainPlayerAttrib:getExp();
	local starNum = math.floor(CurPlayerExpVal/EXP_STAR_RATIO);
	if starNum < 1000 then
		getglobal("PlayerExpBarStarText"):SetText(starNum);
	else
		getglobal("PlayerExpBarStarText"):SetText("999+");
	end
	local expBarVal = (CurPlayerExpVal - starNum * EXP_STAR_RATIO) / EXP_STAR_RATIO ;
	getglobal("PlayerExpBarExp"):SetWidth(500*expBarVal);

	SetRoleFrameStarNum(expBarVal, starNum);
	--PlayMain.Exp:onSetAttribVal();
	SetLevelBar(false);
end

function SetGVoiceBtnState()
	if GYouMeVoiceMgr and GYouMeVoiceMgr:isJoinRoom() and YouMeVocieCanEnable() then
		if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) then--xyang自定义UI
			GetInst("TeamVocieManage"):TeamButtonInit()

			local sid = "1001"
			if IsRoomOwner() then
				sid = "1003"
			end
			standReportEvent(sid, "MINI_VOICE_CHAT", "MicButton", "view")
			standReportEvent(sid, "MINI_VOICE_CHAT", "SpeakerButton", "view")
		end

		--设置麦克风
		if ClientMgr:getGameData("micswitch") == 0 then
			--关闭麦克风
			local ret = GYouMeVoiceMgr and GYouMeVoiceMgr:setMicrophoneMute(true);
			if ret == -2 then		--国战语音 没有麦克风权限不能打开麦克风
				OnSetMicrophoneMute(YOUME_EVENT_LOCAL_MIC_OFF)
			end
		else
			--打开麦克风
			local ret = GYouMeVoiceMgr and GYouMeVoiceMgr:setMicrophoneMute(false);
			if ret == -2 then		--国战语音 没有麦克风权限不能打开麦克风
				OnSetMicrophoneMute(YOUME_EVENT_LOCAL_MIC_OFF)
			end
		end
		--设置扬声器
		if GYouMeVoiceMgr then
			if ClientMgr:getGameData("speakerswitch") == 0 then
				--关闭扬声器
				print("SetGVoiceBtnState 关闭扬声器")
				GYouMeVoiceMgr:setSpeakerMute(true);
			else
				--打开扬声器
				print("SetGVoiceBtnState 打开扬声器")
				GYouMeVoiceMgr:setSpeakerMute(false);
			end
		end
		--引导
		if not AccountManager:getNoviceGuideState("gvoiceguide") then
			GVoiceGuideTime = 10;
			if ClientMgr:isPC() then
				getglobal("GVoiceGuideText"):SetText(GetS(3793));
			else
				getglobal("GVoiceGuideText"):SetText(GetS(3794));
			end
			getglobal("GVoiceGuide"):Show();
		end
	else
		getglobal("MicSwitchBtn"):Hide();
		getglobal("SpeakerSwitchBtn"):Hide();
	end
end

function HideUI2NewbieWorld()
	local lv = AccountManager:getCurGuideLevel();
	local step = AccountManager:getCurGuideStep();

	if CurWorld and CurWorld:getOWID() == NewbieWorldId then
		if lv == 1 and step == 23 then
			getglobal("PlayShortcut"):Show();
			getglobal("PlayMainFrameBackpack"):Show();
		else
			getglobal("PlayShortcut"):Hide();
			getglobal("PlayMainFrameBackpack"):Hide();
		end
	else
		getglobal("PlayShortcut"):Show();
		getglobal("PlayMainFrameBackpack"):Show();
	end

	getglobal("PlayerBuff"):Hide();
	if AccountManager:getCurNoviceGuideTask() < 17 then
		PlayerHPBar_ShowOrHide(false);
	else
		if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
			PlayerHPBar_ShowOrHide(false);
		elseif not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.BLOOD) then --xyang自定义UI
			PlayerHPBar_ShowOrHide(false);
		else
			PlayerHPBar_ShowOrHide(true);
		end
	end
	-- getglobal("PlayerExpBar"):Hide();
	LevelExpBar_ShowOrHide(false);
	getglobal("PlayerStrengthBar"):Hide();
	PlayerHungerBar_ShowOrHide(false);
	getglobal("PlayerOxygenBar"):Hide();
	getglobal("TaskTrackFrame"):Hide();
	getglobal("PlayMainFrameSneak"):Hide();
	getglobal("PlayMainFrameFly"):Hide();
	getglobal("PlayMainFrameRide"):Hide();
	getglobal("PlayMainFrameBed"):Hide();
	RideHPBar_ShowOrHide(false);
	getglobal("Compass"):Hide();
	getglobal("ArchiveGradeBtn"):Hide();
	getglobal("PlayAchievementBtn"):Hide();
	getglobal("AdventureNoteBtn"):Hide();
	getglobal("EditorBackBtn"):Hide();
	GongNengFrame_SetVipBtnForceHide(true);

	getglobal("AccRideCallBtn"):Hide();
	getglobal("AccSummonBtn"):Hide();
	getglobal("MultiPlayerInfo"):Hide();
	getglobal("MultiChatBtn"):Hide();
	getglobal("MicSwitchBtn"):Hide();
	getglobal("SpeakerSwitchBtn"):Hide();
	getglobal("ReceiveVoiceBtn"):Hide();
	getglobal("GVoiceJoinRoomBtn"):Hide();

	-- if lv == 1 and step == 23 then
	-- 	getglobal("PlayMainFrameBackpack"):Show();
	-- else
	-- 	getglobal("PlayMainFrameBackpack"):Hide();
	-- end

	getglobal("BattleBtn"):Hide();

	if ClientMgr:isPC() then
		getglobal("PlayMainFrameGuideSkip"):Hide();
		getglobal("PlayMainFrameGuideSkipPc"):Show();
	else
		getglobal("PlayMainFrameGuideSkip"):Show();
		getglobal("PlayMainFrameGuideSkipPc"):Hide();
	end

	getglobal("PcGuideKeyTips"):Hide();
	getglobal("GongNengFrame"):Hide();
end

function PlayMainFrameUIShow()
	if isEducationalVersion and not ClientCurGame then
		return;
	end

	if ClientCurGame.showOperateUI then
		ClientCurGame:showOperateUI(true);
	end

	getglobal("VoiceTipsFrame"):Hide();
	getglobal("PlayMainFrameFlyDown"):Hide();
	getglobal("PlayMainFrameFlyUp"):Hide();

	if CurWorld and (CurWorld:getOWID() == NewbieWorldId or CurWorld:getOWID() == NewbieWorldId2) then
		HideUI2NewbieWorld();
		--埋点，进入教学地图 设备码,是否首次进入教学地地图,用户类型,语言
		-- statisticsGameEventNew(958,ClientMgr:getDeviceID(),(IsFirstEnterNoviceGuide and not enterGuideAgain) and 1 or 2,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))		
		StatisticsTools:send(true, true)
	else
		getglobal("PlayMainFrameGuideSkip"):Hide();
		getglobal("PlayMainFrameGuideSkipPc"):Hide();
		--getglobal("PlayShortcut"):Show();		--快捷栏

		if IsInHomeLandMap() then
			getglobal("PlayerBuff"):SetPoint("topleft", "PlayMainFrame", "topleft", 27, 103)
		else
			getglobal("PlayerBuff"):SetPoint("topleft", "PlayMainFrame", "topleft", 27, 72)
		end
	    if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.BLOOD) then--xyang自定义UI
		    getglobal("PlayerBuff"):Show();			--Buff
		end
		--getglobal("PlayMainFrameBackpack"):Show();	--背包

		if CurMainPlayer ~= nil and CurMainPlayer:isInSpectatorMode() then
			getglobal("PlayShortcut"):Hide();		--快捷栏
			getglobal("PlayMainFrameBackpack"):Hide();	--背包
		elseif not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.OBJECT) then--xyang自定义UI
			getglobal("PlayShortcut"):Hide();		--快捷栏
			getglobal("PlayMainFrameBackpack"):Hide();	--背包
		else
			if not IsUGCEditing() then
				getglobal("PlayShortcut"):Show();		--快捷栏
				getglobal("PlayMainFrameBackpack"):Show();	--背包
			end
		end

		getglobal("GongNengFrameStoreGNBtn"):Show();	--商店
		getglobal("GongNengFrameActivityGNBtn"):Show();	--活动

		getglobal("GongNengFrameFriendBtn"):Show();

		UpdatePaintChangeBtn()
		--开启追踪主线任务，显示追踪任务面板
		if IsOpenTrack then
			local curTrack = AchievementMgr:getCurTrackID();
			if curTrack > 0 then
				AchievementMgr:setCurTrackID(curTrack);
			else
				local curMainTaskId = GetCurMainTaskId();
				AchievementMgr:setCurTrackID(curMainTaskId);
			end
			UpdateTaskTrackFrame();
		else
			getglobal("TaskTrackFrame"):Hide();
		end

		SetMainUIState();
		getglobal("MicSwitchBtn"):Hide();
		getglobal("SpeakerSwitchBtn"):Hide()
		getglobal("GVoiceJoinRoomBtn"):Hide();
		getglobal("TeamMicSwitchBtn"):Hide();
		getglobal("TeamSpeakerSwitchBtn"):Hide();
		print(" GYouMeVoiceMgr:isJoinRoom() "..tostring(UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP)))
		--房间
		if AccountManager:getMultiPlayer() ~= 0 then
			--getglobal("MultiPlayerInfo"):Show();
			if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
				InteractiveBtn_ShowOrHide(false);
				getglobal("MultiChatBtn"):Hide();
				GetInst("MiniUIManager"):CloseUI("chat_viewAutoGen")
			elseif RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then  --社交大厅不显示
				InteractiveBtn_ShowOrHide(false);
				getglobal("MultiChatBtn"):Hide();
				GetInst("MiniUIManager"):CloseUI("chat_viewAutoGen")
			else
				if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.INVITE) then--xyang自定义UI
					InteractiveBtn_ShowOrHide(true);
				else
					InteractiveBtn_ShowOrHide(false);
				end
				if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.CHAT) then--xyang自定义UI
					getglobal("MultiChatBtn"):Show();
				else
					getglobal("MultiChatBtn"):Hide();
				end
			end
			if PlayAchievementBtnCanShow() then
				getglobal("PlayAchievementBtn"):Show();
			else
				getglobal("PlayAchievementBtn"):Hide();
			end
			getglobal("ArchiveGradeBtn"):Hide();
			getglobal("ArchiveGradeFinishBtn"):Hide();
			if PlayAdventureNoteBtnCanShow() and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) then--xyang自定义UI
				getglobal("AdventureNoteBtn"):Show();
			else
				getglobal("AdventureNoteBtn"):Hide();
			end
			if IsInHomeLandMap and IsInHomeLandMap() then
					--家园不做显示
			elseif RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then 
					--社交大厅不显示
			elseif GYouMeVoiceMgr:isInit() and not GYouMeVoiceMgr:isJoinRoom() and (YouMeVocieCanEnable() or CheckAutoOpenVoice() )then
				if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) then--xyang自定义UI
					getglobal("GVoiceJoinRoomBtn"):Show();

					if not GVoiceJoinRoomBtnShown then
						local sid = "1001"
						if IsRoomOwner() then
							sid = "1003"
						end
						standReportEvent(sid, "MINI_VOICE_CHAT", "VoicechatButton", "view")

						GVoiceJoinRoomBtnShown = true
					end
				end
			elseif GYouMeVoiceMgr:isJoinRoom() then
				if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) then--xyang自定义UI
					GetInst("TeamVocieManage"):TeamButtonInit()
				end
			end
		else
			InteractiveBtn_ShowOrHide(false);
			getglobal("MultiPlayerInfo"):Hide();
			if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
				getglobal("MultiChatBtn"):Hide();
			elseif RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then --社交大厅不显示
				InteractiveBtn_ShowOrHide(false);
				getglobal("MultiChatBtn"):Hide();
				GetInst("MiniUIManager"):CloseUI("chat_viewAutoGen")
			else
				if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.CHAT) then
					getglobal("MultiChatBtn"):Show();
				else
					getglobal("MultiChatBtn"):Hide();
				end
			end
			getglobal("ReceiveVoiceBtn"):Hide();
			if PlayAchievementBtnCanShow() then
				getglobal("PlayAchievementBtn"):Show();
			else
				getglobal("PlayAchievementBtn"):Hide();
			end
			if PlayAdventureNoteBtnCanShow() and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) then--xyang自定义UI
				getglobal("AdventureNoteBtn"):Show();
			else
				getglobal("AdventureNoteBtn"):Hide();
			end
			getglobal("GVoiceJoinRoomBtn"):Hide();
		end

		if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
			getglobal("AccRideCallBtn"):SetPoint("bottomright", "PlayMainFrame", "bottomright", -9, -246)
		end

		--坐骑召唤
		if HasAnyRideOrPet() and not isEducationalVersion and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then--xyang自定义UI
			getglobal("AccRideCallBtn"):Show();
		else
			getglobal("AccRideCallBtn"):Hide();
		end
		if ClientMgr:isMobile() then
			if CurMainPlayer:isFlying() then
				if getglobal("AccRideCallBtn"):IsShown() then
					getglobal("AccRideCallBtn"):Hide();
				end
			else
				if not getglobal("AccRideCallBtn"):IsShown() and not isEducationalVersion and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then--xyang自定义UI
					getglobal("AccRideCallBtn"):Show();
				end
			end
		end

		--变形按钮
		if getglobal("AccRideCallBtn"):IsShown() then
			getglobal("AccRideChangeBtn"):SetPoint("right", "AccRideCallBtn", "left", -3, 0)
		else
			getglobal("AccRideChangeBtn"):SetPoint("center", "AccRideCallBtn", "center", 0, 0)
		end

		local skinId = CurMainPlayer:getSkinID()
		local skinDef = RoleSkinCsv:get(skinId)
		if skinDef and skinDef["ChangeType"] > 0 and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then--xyang自定义UI
			getglobal("AccRideChangeBtn"):Show()
			local t = getkv("first_use_change_skin") or  {}
			local showEffect = true
			for i = 1, #t do
				if t[i] == skinId then
					showEffect = false
				end
			end
			if showEffect then
				getglobal("AccRideChangeBtnEffect"):SetUVAnimation(100, true)
				table.insert(t, skinId)
				setkv("first_use_change_skin", t)
			else
				getglobal("AccRideChangeBtnEffect"):Hide()
			end

		else
			getglobal("AccRideChangeBtn"):Hide()
		end

		if skinDef and skinDef.SummonID and skinDef.SummonID ~= "" and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then
			getglobal("AccSummonBtn"):Show()
			standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "GameOpenSummon", "view", {standby1 = skinId})
		else
			getglobal("AccSummonBtn"):Hide()
		end

		if getglobal("AccRideChangeBtn"):IsShown() then--如果变形按钮显示，设置召唤按钮到变形按钮左边
			getglobal("AccSummonBtn"):SetPoint("right", "AccRideChangeBtn", "left", -3, 0)
		else
			if getglobal("AccRideCallBtn"):IsShown() then
				getglobal("AccSummonBtn"):SetPoint("right", "AccRideCallBtn", "left", -3, 0)
			else
				getglobal("AccSummonBtn"):SetPoint("center", "AccRideCallBtn", "center", 0, 0)
			end
		end

		if CurMainPlayer:isShapeShift() and ClientMgr:isMobile() and needShowRideAttackBtn(skinId) then --64-红蜘蛛 坐骑飞行 加速按钮无效不显示
			getglobal("AccRideAttackBtn"):Show()
			getglobal("AccRideAttackLeftBtn"):Show()
		else
			getglobal("AccRideAttackBtn"):Hide()
			getglobal("AccRideAttackLeftBtn"):Hide()
		end

		SetAttriVal();
		if IsInHomeLandMap and IsInHomeLandMap() then
			ShowHomeMainUI()
			HomeLandGuideTaskCall("ShowUi", true)
			getglobal("GongNengFrame"):Hide();
		elseif GetInst("MiniUIManager"):IsShown("VisualCodeMainViewAutoGen") then
			getglobal("GongNengFrame"):Hide();
		else
			getglobal("GongNengFrame"):Show();
		end
		--[[--在玩法/编辑模式切换时Frame的状态一直是OnShow
		if not getglobal("GongNengFrame"):IsShown() then
			getglobal("GongNengFrame"):Show();
		end
		--]]

		UpdatePlaymainForIosReview();

		SwitchGongNengFrameMenu(false);

		--玩法模式队伍和比分
		getglobal("BattleBtn"):Hide();
		getglobal("BattlePrepareFrame"):Hide();

		if CurWorld:isGameMakerRunMode() then
			-- 开局介绍
			local showIntrosOrSelect = false
			if ClientCurGame:getGameStage() <= CGAME_STAGE_RUN then
				local newPlayerFlag = true
				if CurMainPlayer and CurMainPlayer.isNewPlayer then
					newPlayerFlag = CurMainPlayer:isNewPlayer()
				end
				local needShowIntro, needShowTeams = false, false;
				local makermgr = WorldMgr:getGameMakerManager();
				if newPlayerFlag and makermgr and makermgr.getNeedShowPrepareFrame then 
					needShowIntro = makermgr:getNeedShowPrepareFrame(1)
					needShowTeams = makermgr:getNeedShowPrepareFrame(2)
				end
				if needShowIntro then
					makermgr:setCustomGameStage(CGAME_STAGE_SHOWINTROS);
					showIntrosOrSelect = true
				elseif needShowTeams then
					makermgr:setCustomGameStage(CGAME_STAGE_SELECTTEAM);
					showIntrosOrSelect = true
				end
			end
			-- 原版内容
			if not showIntrosOrSelect then
				if ClientCurGame:getGameStage() < CGAME_STAGE_RUN and AccountManager:getMultiPlayer() ~= 0 then --开始游戏前
					getglobal("BattlePrepareFrame"):Show();	
				elseif IsShowBattleBtn() and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.SCORE) then--xyang自定义UI
					getglobal("BattleBtn"):Show();
					SetBattleBtn();
				end
			end
		end

		--pc键位引导
		if ClientMgr:isPC() and not AccountManager:getNoviceGuideState("guidekey") and not isEducationalVersion then
			getglobal("PcGuideKeyTips"):Show();
		else
			getglobal("PcGuideKeyTips"):Hide();
		end

		if NeedOpenMakerRunGame then
			getglobal("OpenGame"):Show();
		end

		SpectatorModeChange();
		--喷漆红点检测显示背包红点
		local uin = AccountManager:getUin()
		if getkv("BackPackPaint_Onlick"..uin) then
			getglobal("PlayMainFrameBackpackRedTag"):Hide()
		else
			getglobal("PlayMainFrameBackpackRedTag"):Show()
		end

		if IsInHomeLandMap and IsInHomeLandMap() then --家园地图不显示
			getglobal("Compass"):Hide();
		elseif not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) then--xyang自定义UI
			getglobal("Compass"):Hide();
		else
			PixelMapInterface:ShowCompass();
		end

	end

	if ClientMgr:isPC() then
        getglobal("PlayMainFrameFly"):Hide();
        getglobal("PlayMainFrameRide"):Hide();
		getglobal("PlayMainFrameBed"):Hide();
		--躺床上或者坐骑
		local ride = CurMainPlayer:getRidingHorse()
		if ride ~= nil then
			getglobal("PlayMainFrameRide"):Show();
		end
		if CurMainPlayer.isRestInBed and CurMainPlayer:isRestInBed() then
			getglobal("PlayMainFrameBed"):Show();
		end
	end

	if CurMainPlayer:getMountType() == MOUNT_DRIVE then
		setVehicleUI(true)
	else
		setVehicleUI(false)
	end

	--工具模式界面刷新
	if CurWorld:isGameMakerToolMode() and GetInst("UIManager"):GetCtrl("ToolModeFrame") then
		print("PlayMainFrameUIShow:XXX:");
		GetInst("UIManager"):GetCtrl("ToolModeFrame"):Refresh();
	end
	--教育版不显示坐骑
	if isEducationalVersion then
		getglobal("AccRideCallBtn"):Hide();
	end	
	--跳舞方块内不能显示坐骑按钮和血条
	if GetInst("MiniUIManager"):GetCtrl("clubMain") then
		getglobal("AccRideCallBtn"):Hide();
		getglobal("AccRideChangeBtn"):Hide();
		getglobal("AccSummonBtn"):Hide();
		PlayerHPBar_ShowOrHide(false);
		PlayerHungerBar_ShowOrHide(false);
		if not GetInst("MiniUIManager"):GetCtrl("clubMain").SwicthBack then
			getglobal("PlayShortcut"):Hide();
			getglobal("PlayMainFrameBackpack"):Hide();
			getglobal("PlayerExpBarStar"):Hide();
			getglobal("PlayerExpBar"):Hide();
			getglobal("PhraseLibraryFrameUnFold"):Hide();
		end
		LevelExpBar_ShowOrHide(false);
	end

	--运行模式下的编辑按钮
	if UGCModeMgr and UGCModeMgr:IsUGCMode() and getglobal("EditorBackBtn") then
		if (CanChangeGameMode() or _isTempMap) and not isInTeam then
			getglobal("EditorBackBtn"):Show();
			local edge = UIFrameMgr:GetScreenEdge()
			local scaleX = UIFrameMgr:GetScreenScaleX() 
			if scaleX == 0 then
				scaleX = 1
			end
			local x = 50 - edge / scaleX
			getglobal("EditorBackBtn"):SetPoint("bottomleft", "PlayMainFrame", "bottomleft", x, -35)
		else
			getglobal("EditorBackBtn"):Hide();
		end
	else
		getglobal("EditorBackBtn"):Hide();
	end
	
	--显示变色按钮
	ShowChangeColorBtn()

	-- 初始化下区域设置状态
	GetInst("MiniClubInterface"):SetIsMiniClub(false)

	GetInst("HideUnmoderatedTextManger"):initData()

	GetInst("ShareArchiveInterface"):StartTryPlayTime()
end

function UpdatePlaymainForIosReview()
	if IsInIosSpecialReview() then
		getglobal("GongNengFrameFriendBtn"):Hide();
		InteractiveBtn_ShowOrHide(false);
		--getglobal("GongNengFrameSetGNBtn"):Show();
		getglobal("GongNengFrameStoreGNBtn"):Hide();
		getglobal("GongNengFrameActivityGNBtn"):Hide();
		getglobal("SetMenuFrameLeftSetFrameCreateRoomBtn"):Hide();
	end
end


function GuideKey_Finish()
	getglobal("PcGuideKeyTips"):Hide();
end

function IsShowBattleBtn()
	local optionId=0;
	local val=0;
	optionId, val = CurWorld:getRuleOptionID(30, optionId, val);		--显示比分和时间的规则选项
	if val == 1 then
		return true;
	else
		return false;
	end
end

function  PlayMainFrameUIHide()
	getglobal("PlayShortcut"):Hide();
	getglobal("PlayerBuff"):Hide();
	PlayerHPBar_ShowOrHide(false);
	getglobal("PlayerStrengthBar"):Hide();
	-- getglobal("PlayerExpBar"):Hide();
	LevelExpBar_ShowOrHide(false);
	PlayerHungerBar_ShowOrHide(false);
--	getglobal("PlayerOxygenBar"):Hide();
	getglobal("TaskTrackFrame"):Hide();
	getglobal("PlayMainFrameSneak"):Hide();
	getglobal("PlayMainFrameFly"):Hide();
	getglobal("PlayMainFrameRide"):Hide();
	getglobal("PlayMainFrameBed"):Hide();
	RideHPBar_ShowOrHide(false);
	getglobal("Compass"):Hide();
	getglobal("ArchiveGradeFinishBtn"):Hide();
	getglobal("ArchiveGradeBtn"):Hide();
	getglobal("PlayAchievementBtn"):Hide();
	getglobal("AdventureNoteBtn"):Hide();
	getglobal("EditorBackBtn"):Hide();
	if friendservice.enabled then
		getglobal("GongNengFrameFriendBtn"):Hide();
	else
		InteractiveBtn_ShowOrHide(false);
	end
	getglobal("AccRideCallBtn"):Hide();
	getglobal("AccSummonBtn"):Hide();
	getglobal("MultiPlayerInfo"):Hide();
	getglobal("MultiChatBtn"):Hide();
	getglobal("MicSwitchBtn"):Hide();
	getglobal("SpeakerSwitchBtn"):Hide();
	getglobal("GVoiceJoinRoomBtn"):Hide();
	getglobal("ReceiveVoiceBtn"):Hide();
	getglobal("PlayMainFrameBackpack"):Hide();
	getglobal("BattleBtn"):Hide();
	getglobal("RocketUIFrame"):Hide();
	getglobal("EncryptFrame"):Hide();
	getglobal("AccRideChangeBtn"):Hide();
	getglobal("AccRideAttackBtn"):Hide()
	getglobal("AccRideAttackLeftBtn"):Hide()
    getglobal("GongNengFrameDeveloperStoreBtn"):Hide()
	getglobal("PaintChangeFrame"):Hide()
end

gPassPortEndTime = -2
gPassPortLastTime = 0
function PlayMainFrame_OnShow()
	print("PlayMainFrame_OnShow:");
	--添加联机状态水印
	local WMCtrl = GetInst("UIManager"):GetCtrl("WaterMark")
	if WMCtrl and WMCtrl.UpdateGameTypeStr then
		WMCtrl:UpdateGameTypeStr()
	end

	gPassPortEndTime = -2
	
	GVoiceJoinRoomBtnShown = false --每次show playmain的时候重置状态
	if CurWorld then
		if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
			local worldInfo = AccountManager:findWorldDesc(CurWorld:getOWID())
			if worldInfo and worldInfo.owneruin ~= worldInfo.realowneruin then
				local bPaymentMap = (worldInfo.passportflag ~= nil and worldInfo.passportflag == 1)
				if bPaymentMap then
					gPassPortEndTime = AccountManager:getCurWorldPassPortEndTime(worldInfo.fromowid)
					if gPassPortEndTime ~= -2 then
						local nowTime = AccountManager:getSvrTime()
						if gPassPortEndTime <= nowTime then
							local propDef = getPassPortDef()
							local passportInfo = propDef and propDef.PassPortInfo or {}
							local playTime = password_pop_time()
							if passportInfo and #passportInfo == 4 then
								playTime = passportInfo[2]
							end
							if playTime < 60 then
								playTime = 60
							end
							gPassPortEndTime = nowTime + playTime
						else
							if gPassPortEndTime - nowTime < 60 then
								gPassPortEndTime = nowTime + 60
							end
						end
					end
				end
			end
		else
			local developerflag = CurWorld:getDeveloperFlag()
			if developerflag == 3 then--这里表示客机，进入了通行证到期的联机房间
				MessageBox(4, GetS(23046), function(btn)
		            if btn and btn == 'center' then 
						GoToMainMenu()
		            end 
		        end)
			end
		end

		if NewbieWorldId2 == CurWorld:getOWID() then
			if ClientCurGame.showOperateUI then
				ClientCurGame:showOperateUI(true);
			end
			if not (getkv(AccountManager:getUin().."_finishNewGuide") == 1 or IsSkipFromGuideOrFirstMap) then
				GetInst("UIManager"):Open("RookieGuide")
				GetInst("UIManager"):GetCtrl("RookieGuide"):showType({type=4})
				if ClientCurGame and not ClientCurGame:isOperateUI() then
					ClientCurGame:setOperateUI(true)
				end
			end
			getglobal("BattlePrepareFrame"):Hide();
		end
	end

	-- 进入游戏事件上报 by fym
	EnterGameEventReport()
	--MiniBase进入游戏通知
    SandboxLua.eventDispatcher:Emit(nil, "MiniBase_GameLaunchFinish",  SandboxContext():SetData_Number("code", 0))
	
	
	local sceneID = "" 
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
		--主机
		sceneID = "1003"
	else
		--客机
		sceneID = "1001"
	end
	standReportEvent(sceneID, "MINI_SOUND_Illusion","-", "view")
	
	threadpool:work(function()
		-- 2022/03.30 codeby fym 获取地图场景使用到的广告数据
		local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()
		if reviveAdPositionId == 105 then
			ad_data_new.getAdInfoBySence(ad_data_new.allSenceIdList.developerMap)
		else
			ad_data_new.getAdInfoBySence(ad_data_new.allSenceIdList.map)
		end
	end)

	ShopInit()

	NeedOpenMakerRunGame = false;
	getglobal("OpenGame"):Hide();
	getglobal("RocketUIFrame"):Hide();

	PlayMainFrameUIShow();
	InitScreenEffect();
	if ClientMgr:isMobile() == false then
	   getglobal("PlayMainFrameSneak"):Hide();
	else
		local st = getglobal("SetSightingTelescopeBtn")
		if CurMainPlayer:hasSightingTelescope() then
			st:Show()
		else
			st:Hide()
		end
	end

	getglobal("BattleCountDownFrame"):Hide();
	getglobal("GasInfo"):Hide();

	--LLDO:初始化玩家profile
	KillInfoFrame_InitProfile();

	if AccountManager:getMultiPlayer() ~= 0 then
		SetAllForbidSpeakerBtnStatus();
	end

	--if CurMainPlayer:getMountType() == MOUNT_DRIVE then
	--	setVehicleUI(true)
	--end
	AccountGameModeClass:UpGameModeUI();
	getglobal("PlayMainFramePassPortCountDownFrame"):Hide()
    getglobal("CSStateNoticeFrame"):Hide()
    
    if IsUIFrameShown("MiniWorksFrame") then
        getglobal("MiniWorksFrame"):Hide()
    end
	if IsUIFrameShown("LobbyFrame") then
        getglobal("LobbyFrame"):Hide()
    end
	if GetInst("QQMusicPlayerManager") then
		GetInst("QQMusicPlayerManager"):InitUI();--Xyang 初始化音乐播放器
	end
	
	if GetInst("MiniClubPlayerManager") and GetInst("MiniClubPlayerManager"):IsOpen() then
		GetInst("MiniClubPlayerManager"):OpenUI()
	end
	if GetInst("QQMusicPlayerManager") then
		GetInst("QQMusicPlayerManager"):OnEnterGame()
	end

	--重置下传送弹窗显示数据
	if GetInst("CloudPortalInterface") then
		GetInst("CloudPortalInterface"):OnEnterGame();
	end

	if GetInst("MatchPartyInterface") then
		GetInst("MatchPartyInterface"):ShowReMatchBtn()
	end

	RoomUIFrame_SetChatBubbleSwitchState()
	
	--请求免流量包开通状态
	ReqMobileDataPackageState()

	ShowToActivityFrame()
	if GetInst("BestPartnerManager") then
		GetInst("BestPartnerManager"):InGameReport();
	end
end

function ReqMobileDataPackageState()
	if IsInHomeLandMap and IsInHomeLandMap() then
		--家园模式下不弹出
		return
	end

	--UI每次展示都会检查状态，这里检查是不是进入地图后第一次展示
	if MobileTipsShowed then
		return
	end

	--第一次检查状态后
	MobileTipsShowed = true

	--检查当前网络运营商
	if get_game_env() ~= 1 then
		--不是移动网络都不用弹
		if ClientMgr:getNetworkState() ~= 2 then return end
	end

	local uin_ = AccountManager:getUin() or get_default_uin()
	local sign_, s2t_, pure_s2t_ = get_login_sign()
	local time_ = os.time()
	local auth_ = gFunc_getmd5(time_ .. sign_ .. uin_)
	local default_param = {
		uin = uin_,
		auth = auth_,
		time = time_,
		s2t  = pure_s2t_
	}

	local url = ""
	if get_game_env() == 1 then
		url = "https://h5.miniworldplus.com/api/traffic/user/getStatus?"
	else
		url = "https://actapi.mini1.cn/api/flow/user/getStatus?"
	end
	for k, v in pairs(default_param) do
		if k ~= "uin" then
			url = url .. "&" .. k .. "=" .. v
		else
            url = url .. k .. "=" .. v
		end
    end
	url = url ..s2t_

	local _callback = function(retstr)
		local ret = JSON:decode(retstr)
		if ret and ret.code == 200 then
			if ret.data == 0 then
				CheckMobileDataPackageState()
			end
		end
	end

	ns_http.func.rpc_string_raw_ex(url, _callback);
end

function CheckMobileDataPackageState()
	local uid = AccountManager:getUin() or ""
	--检查配置开关是否打开
	if ns_version and ns_version.mobile_data_package.open == 1 and check_apiid_ver_conditions(ns_version.mobile_data_package) then
		if ns_version.mobile_data_package.clear_record == 1 then
			--配置清零开关打开，则清除本地持久化数据
			setkv("mobile_data_day_"..uid,nil)
			setkv("mobile_data_total_"..uid,0)
		end
		local total = getkv("mobile_data_total_"..uid) or 0
		--判断当前弹出次数是否小于配置总数
		if total < ns_version.mobile_data_package.total_show_limit then
			local lastTime,curTime,count
			local isNextDay = false
			if getkv("mobile_data_day_"..uid) then
				lastTime = os.date("%Y.%m.%d", getkv("mobile_data_day_"..uid).time):split('.')--getkv("mobile_data_day")
				count = getkv("mobile_data_day_"..uid).count
			else
				lastTime = {"0","0","0"}
				count = 0
			end
			local curTime = os.date("%Y.%m.%d", AccountManager:getSvrTime()):split('.')
			for i = #curTime, 1, -1 do
				if lastTime[i] ~= curTime[i] then
					isNextDay = true
					count = 0
					break
				end
			end
			--确定隔天
			if isNextDay then
				local param = {}
				param.time = AccountManager:getSvrTime()
				param.count = 1
				setkv("mobile_data_day_"..uid,param)
			else
				if count >= 2 and (count - 2) < ns_version.mobile_data_package.day_show_limit then
					MobileDataPackageShowTips()
					total = total + 1
					setkv("mobile_data_total_"..uid,total)
				end 
				local param = {}
				param.time = AccountManager:getSvrTime()
				param.count = count + 1
				setkv("mobile_data_day_"..uid,param)
			end
		end
	end
end

function MobileDataPackageShowTips()
	local sceneID = "" 
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
		--主机
		sceneID = "1003"
	else
		--客机
		sceneID = "1001"
	end
	local mapId = G_GetFromMapid()
	local uid = AccountManager:getUin()
	standReportEvent(sceneID, "MINI_DATAPACKAGE_TOP_1", "-", "view")
	standReportEvent(sceneID, "MINI_DATAPACKAGE_TOP_1", "ClickButton", "view")
	
	GetInst("MiniUIManager"):OpenUI(
		"CommonTips",
		"miniui/miniworld/CommonTips", 
		"CommonTipsAutoGen",
		{titleText = GetS(7000001),btnText = GetS(7000002),cb = function()
			standReportEvent(sceneID, "MINI_DATAPACKAGE_TOP_1", "ClickButton", "click",{cid = tostring(mapId),uid = tostring(uid)})
			g_jump_ui_switch[1004]() 
		end,time = 5})
end

-- 进入游戏事件上报 by fym
function EnterGameEventReport()
	local standby3 = GetInst("TeamVocieManage"):GetCurrentTeamHavePurviewID();
	if CurWorld then
		-- 房间类型，地图id
		local cid = "0"	
		local stanby1_1, stanby1_2, stanby1_3 = "", "", ""
		-- 房主或者单机模式进入地图显示游戏栏目显示上报 by fym
		if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
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
			local worldInfo = AccountManager:findWorldDesc(CurWorld:getOWID())
			if worldInfo then
				if worldInfo.realowneruin > 1 and worldInfo.owneruin ~= worldInfo.realowneruin then
					cid = worldInfo.fromowid
					stanby1_1 = 2 -- 2：别人地图 
				elseif worldInfo.worldid then
					cid = worldInfo.worldid
					stanby1_1 = 1 -- 1:自己地图
				end

				if worldInfo.worldtype then
					if worldInfo.worldtype == 0 then -- 冒险
						stanby1_3 = 1
					elseif worldInfo.worldtype == 1 then -- 创造
						stanby1_3 = 2
					else  -- 开发者
						stanby1_3 = 3  
					end
				end
			end
			-- 上报参数：cid standby1（百分位-1:自己地图；2：别人地图 、十分位-1:单机游戏；2：联机游戏；3：好友联机 、个位：-1.冒险模式；2：创造模式；3：开发者模式）
			standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "-", "view", {cid = tostring(cid), standby1 = stanby1_1..stanby1_2..stanby1_3,standby3 = standby3})	
			standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "MoreTelescopicBar", "view")
		-- 客机
		else
			if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then	
				-- 进入云服房间显示游戏栏目显示上报 by fym				
				if DeveloperFromOwid then
					cid = DeveloperFromOwid
				elseif standReportGameExitParam and DeveloperFromOwid.cid then
					cid = DeveloperFromOwid.cid
				end
				-- 上报参数：cid stanby1：由两位数组成（十分位-1：公开房间；、个位-1：迷你云服）
				-- standReportEvent("1002", "MINI_CLOUDROOM_GAME_1", "-", "view", {cid = tostring(cid), standby1 = "11"})
				standReportEvent("1001", "MINI_GAMEROOM_GAME_1", "-", "view", {cid = tostring(cid), standby1 = "11",standby3 = standby3})
				standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "-", "view", {cid = tostring(cid), standby1 = "11",standby3 = standby3})
			else
				-- 进入普通房间显示游戏栏目显示上报 by fym
				local roomDesc = AccountManager:getCurHostRoom()
				if roomDesc then
					-- 地图id
					if roomDesc.fromowid and roomDesc.fromowid > 0 then
						cid = tostring(roomDesc.fromowid)
					elseif roomDesc.owid and roomDesc.owid > 0 then
						cid = tostring(roomDesc.owid)
					elseif roomDesc.wid and roomDesc.wid > 0 then 			
						cid = tostring(roomDesc.wid)
					elseif roomDesc.map_type then
						cid = roomDesc.map_type
					end
					
					-- 房间模式connect_mode = 0:公开房间 , 1:协作模式
					if roomDesc.connect_mode then
						stanby1_1 = roomDesc.connect_mode + 1
					end
					-- PC大房间: 人数>6
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
				-- 上报参数：cid stanby1：由两位数组成（十分位-1：公开房间；2-好友协作、个位-1：迷你云服；2：手机服务器；3：PC服务器 4：PC大房间）
				standReportEvent("1001", "MINI_GAMEROOM_GAME_1", "-", "view", {cid = tostring(cid), standby1 = stanby1_1..stanby1_2,standby3 = standby3})
				standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "-", "view", {cid = tostring(cid), standby1 = stanby1_1..stanby1_2,standby3 = standby3})
			end
		end
	end
end

function PlayMainFrame_OnHide()
	if SwapBlinkBtnName ~= nil then
		local blinkTexture = getglobal(SwapBlinkBtnName.."Check");
		if blinkTexture:IsShown() then
			blinkTexture:Hide();
		end
		SwapBlinkBtnName = nil;
	end

	BattleCoundBlinkingTime = 0;

	--工具模式界面
	GetInst("UIManager"):Close("ToolModeFrame");	--工具模式
	GetInst("UIManager"):Close("ToolObjLib");		--对象库

	--载具控制界面
	GetInst("UIManager"):Close("VehicleDriveMode");

	getglobal("CSStateNoticeFrame"):Hide()

	--在加载地图的时候 网络断开了 弹出的选队界面关不掉 所以在关闭mainFrame的时候 再判断关闭一次 顺带将开局介绍也关掉了
	ClosePreStartGameFrame()
	PlayMain.HP:reset();
	PlayMain.Strength:reset();
	PlayMain.RideHP:reset();

	if altmanMusicTimer then
		threadpool:kick(altmanMusicTimer)
	end
	isPlayingAtlmanMusic = false

	if getglobal("RoomMatchBtn") then
		getglobal("RoomMatchBtn"):Hide()
	end

	GetInst("MiniUIManager"):HideUI("chat_viewAutoGen")	
	PixelMapInterface:HideCompass();

	--重置tips计时器keys
	UnRegisterAllTipsSchedulerEvents()
end

function SetBattleBtn()
	-- local teamNum = ClientCurGame:getNumTeam();
	local teamNum = TeamSetterCtrl:getTeamsNum();
	if teamNum == 0 then teamNum = 1 end

	local teamId = CurMainPlayer:getTeam();
	if teamId == 0 then teamNum = 1 end

	local teamIndex = TeamSetterCtrl:getIndexByTeamId(teamId);
	getglobal("BattleBtnMyTeamBkg"):Hide();
	local myTeamScoreName = nil;
	for i=1, Team_Max_Num do
		local score = getglobal("BattleBtnScore"..i);
		if i <= teamNum then
			score:Show();
			if i == teamIndex then
				myTeamScoreName = score:GetName();
			end
		else
			score:Hide();
		end

		local colon = nil;
		if i ~= 6 then
		 	colon = getglobal("BattleBtnColon"..i);
		end

		if colon ~= nil then
			if i <= teamNum-1 then
				colon:Show();
			else
				colon:Hide();
			end
		end
	end

	local width = 102 + (teamNum-1)*80;

	getglobal("BattleBtn"):SetWidth(width);

	if teamId == 0 then
		myTeamScoreName = getglobal("BattleBtnScore1"):GetName()
	end

	if myTeamScoreName then
		getglobal("BattleBtnMyTeamBkg"):SetPoint("Center", myTeamScoreName, "Center", 0, -22);
		getglobal("BattleBtnMyTeamBkg"):Show();
		getglobal("BattleBtnMyTeamBkg1"):SetPoint("Center", myTeamScoreName, "Center", 0, 20);
		getglobal("BattleBtnMyTeamBkg1"):Show();
	end
end

function OnChangeTeam()
	Log("OnChangeTeam");
	getglobal("BattleBtnMyTeamBkg"):Hide();
	local myTeamScoreName = nil;
	local teamId = CurMainPlayer:getTeam();
	local teamIndex = TeamSetterCtrl:getIndexByTeamId(teamId);
	for i=1, Team_Max_Num do
		local score = getglobal("BattleBtnScore"..i);

		if i == teamIndex then
			myTeamScoreName = score:GetName();
		end
	end

	if teamId == 0 then
		myTeamScoreName = getglobal("BattleBtnScore1"):GetName()
	end

	if myTeamScoreName then
		getglobal("BattleBtnMyTeamBkg"):SetPoint("Center", myTeamScoreName, "Center", 0, -22);
		getglobal("BattleBtnMyTeamBkg"):Show();
		getglobal("BattleBtnMyTeamBkg1"):SetPoint("Center", myTeamScoreName, "Center", 0, 20);
		getglobal("BattleBtnMyTeamBkg1"):Show();
	end
	if not GetInst("TeamVocieManage"):isInTeamVocieRoom() then
		if GYouMeVoiceMgr and GYouMeVoiceMgr:isJoinRoom() and not IsNationalVoice() and ClientCurGame:getMaxPlayerNum() > 20 then	--需要切换队伍语音房间
				local rst = GYouMeVoiceMgr:quitRoom()
				if rst == YOUME_SUCCESS then
					RoomInteractiveData.waitSwitchVoiceRoom = true;
				end
		end
	end
end


function BattleCountDownFrame_OnUpdate()
	if getglobal("BattleCountDownFrame"):IsShown() then
		local alpha = getglobal("BattleCountDownFrameIcon"):GetBlendAlpha() - 0.04;
		if alpha < 0 then
			getglobal("BattleCountDownFrame"):Hide();
		else
			getglobal("BattleCountDownFrameIcon"):SetBlendAlpha(alpha);
		end
	end
end

local t_BattleCoolDownIconInfo = {
	[10] = {iconName="wfms_shuzi010", width=238, height=176},
	[9] = {iconName="wfms_shuzi09", width=238, height=176},
	[8] = {iconName="wfms_shuzi08", width=238, height=176},
	[7] = {iconName="wfms_shuzi07", width=238, height=176},
	[6] = {iconName="wfms_shuzi06", width=238, height=176},
	[5] = {iconName="wfms_shuzi05", width=238, height=176},
	[4] = {iconName="wfms_shuzi04", width=238, height=176},
	[3] = {iconName="wfms_shuzi03", width=238, height=176},
	[2] = {iconName="wfms_shuzi02", width=238, height=176},
	[1] = {iconName="wfms_shuzi01", width=238, height=176},
	[0] = {iconName="wfms_go", width=294, height=131},
}

function BattleCountDown(code, isrocket)
	if getglobal("BattlePrepareFrame"):IsShown() then
		if getglobal("BattlePrepareFrameStartGame"):IsShown() then
			getglobal("BattlePrepareFrameStartGame"):Hide();
		end
		if code >= 0 then
			getglobal("BattlePrepareFrameTips"):SetText(GetS(1342, code));
		end
	end

	if code == 5 and not isrocket then
		BattleCoundBlinkingTime = 4;
	else
		BattleCoundBlinkingTime = 0;
	end

	if code <= 3 or isrocket then
		if t_BattleCoolDownIconInfo[code] then
			getglobal("BattleCountDownFrameIcon"):SetBlendAlpha(1);
		--	getglobal("BattleCountDownFrameIcon"):SetTexUV(t_BattleCoolDownIconInfo[code].iconName);
			getglobal("BattleCountDownFrameIcon"):SetTexture("ui/mobile/texture2/bigtex/"..t_BattleCoolDownIconInfo[code].iconName..".png", false, false)
			getglobal("BattleCountDownFrameIcon"):SetSize(t_BattleCoolDownIconInfo[code].width, t_BattleCoolDownIconInfo[code].height);

			if not getglobal("BattleCountDownFrame"):IsShown() then
				getglobal("BattleCountDownFrame"):Show();
			end
		else
			getglobal("BattleCountDownFrame"):Hide();
		end
	end
end

function AdventureNoteBtn_OnClick()
	if getglobal("AdventureNoteFrame"):IsShown() then
		getglobal("AdventureNoteFrame"):Hide();
	else
		getglobal("AdventureNoteFrame"):Show();
	end
end

function EditorBackBtn_OnClick()
	if GetInst("UGCCommon"):turnModel(2) then
		SceneEditorRemovePreviewTip()
		ChangeGameModeBtn_OnClick()
	end
end

function PlayAdventureNoteBtnCanShow()
	if IsInHomeLandMap and IsInHomeLandMap() then --家园中不显示
		return false
	end

	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then 
		--社交大厅不显示
		return false
	end
	
	if CurWorld:isGameMakerRunMode() or CurWorld:isFreeMode() then
		return true;
	else
		return false;
	end

end

function PlayAchievementBtnCanShow()
	if CurWorld:isCreativeMode() then
		return false;
	end

	if CurWorld:isExtremityMode() then
		return false;
	end

	if CurWorld:isCreateRunMode() then
		return false;
	end

	if CurWorld:isGameMakerMode() then
		return false;
	end

	if CurWorld:isGameMakerRunMode() then
		return false;
	end

	if CurWorld:isFreeMode() then
		return false;
	end

	--[[local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
	if worldDesc ~= nil and worldDesc.realowneruin ~= AccountManager:getUin() then
		return false;
	end]]

	return true;
end

local ScreenEffectFrameLoopShow = false;
local ScreenEffectFrameAlphaIncSpeed = 0.2;
function ScreenEffect_OnUpdate()
	if getglobal("ScreenEffectFrame"):IsShown() then
		local alpha = getglobal("ScreenEffectFrameBkg"):GetBlendAlpha() - ScreenEffectFrameAlphaIncSpeed;
		if ScreenEffectFrameLoopShow then
			if alpha < 0.05 then
				alpha = 0.05;
				ScreenEffectFrameAlphaIncSpeed = 0-ScreenEffectFrameAlphaIncSpeed;
			elseif alpha > 0.95 then
				alpha = 0.95;
				ScreenEffectFrameAlphaIncSpeed = 0-ScreenEffectFrameAlphaIncSpeed;
			end
		else
			if alpha < 0 then
				alpha = 0;
				getglobal("ScreenEffectFrame"):Hide();
			end
		end

		getglobal("ScreenEffectFrameBkg"):SetBlendAlpha(alpha);
	end
end

function ShowScreenEffect(type, isLoop, incSpeed)
	if not getglobal("ScreenEffectFrame"):IsShown() then
		if isLoop ~= nil then
			ScreenEffectFrameLoopShow = isLoop;
		else
			ScreenEffectFrameLoopShow = false;
		end

		if incSpeed then
			ScreenEffectFrameAlphaIncSpeed = incSpeed;
		else
			ScreenEffectFrameAlphaIncSpeed = 0.2;
		end

		if type == 1 then
			--getglobal("ScreenEffectFrameBkg"):SetTexture("ui/mobile/texture/bigtex_comm/speedline.png");
			getglobal("ScreenEffectFrameBkg"):SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
			getglobal("ScreenEffectFrameBkg"):SetTexUV("speedline.png");
		elseif type == 2 then
			--getglobal("ScreenEffectFrameBkg"):SetTexture("ui/mobile/texture/bigtex_comm/powerline.png");
			getglobal("ScreenEffectFrameBkg"):SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
			getglobal("ScreenEffectFrameBkg"):SetTexUV("powerline.png");
		elseif type == 3 then
			getglobal("ScreenEffectFrameBkg"):SetTexture("ui/mobile/texture2/bigtex/fog.png");
			--getglobal("ScreenEffectFrameBkg"):SetTextureHuiresXml("ui/mobile/texture/uitex.xml");
			--getglobal("ScreenEffectFrameBkg"):SetTexUV("fog.png");
		end

		getglobal("ScreenEffectFrameBkg"):SetBlendAlpha(1.0);
		getglobal("ScreenEffectFrame"):Show();
	end
end

function InitScreenEffect()
	getglobal("ScreenEffectFrame"):Hide();
end

function ViewModeChange()
	--锁定俯视角箭头
	if CurMainPlayer and CurMainPlayer:getViewMode() ~= 3 then
		getglobal("OverLookArrowFrame"):Hide();
	elseif not getglobal("OverLookArrowFrame"):IsShown() then
		getglobal("OverLookArrowFrame"):Show();
	end
end

function OverLookArrowFrame_OnUpdate()
	if CurMainPlayer then
		local angle = CurMainPlayer:getOverLookAngleToScreen();
		getglobal("OverLookArrowFrameBkg"):SetAngle(angle);
	end
end
-----------------------------------------------------TaskTrackFrame---------------------------------------------
function TaskTrackFrame_OnShow()

end
local mouseDown = false

function TaskTrackFrame_OnMouseDown()
	mouseDown = true
end

function TaskTrackFrame_OnClick()
	if not getglobal("AchievementFrame"):IsShown() then
		getglobal("AchievementFrame"):Show();
	end
	local achievementId = AchievementMgr:getCurTrackID();
	-- UpdateAchievementFrameById(achievementId);
	ShowAchievementById(achievementId);
end

g_TaskFrameStartPosX = -12
g_TaskFrameStartPosY = 204
g_TaskFrameStartCurX = -12
g_TaskFrameStartCurY = 204
function TaskTrackFrame_OnMouseMove()
	if not mouseDown then
		return
	end
	g_TaskFrameStartCurX = g_TaskFrameStartPosX - arg1 + arg3
	g_TaskFrameStartCurY = g_TaskFrameStartPosY - arg2 + arg4
	getglobal("TaskTrackFrame"):SetPoint("topright", "PlayMainFrame", "topright", g_TaskFrameStartCurX, g_TaskFrameStartCurY )
end

function TaskTrackFrame_OnMouseUp()
	mouseDown = false
	if g_TaskFrameStartCurX > - 3 then
		g_TaskFrameStartCurX = -3
	end
	local fScale = UIFrameMgr:GetScreenScale();
	local screenWidth = GetScreenWidth() / fScale
	local screenHeight = GetScreenHeight() / fScale
	if g_TaskFrameStartCurX < -(screenWidth - 253) then
		g_TaskFrameStartCurX = -(screenWidth - 253)
	end
	if g_TaskFrameStartCurY < 1 then
		g_TaskFrameStartCurY = 1
	end
	if g_TaskFrameStartCurY > (screenHeight - 106) then
		g_TaskFrameStartCurY = (screenHeight - 106)
	end
	getglobal("TaskTrackFrame"):SetPoint("topright", "PlayMainFrame", "topright", g_TaskFrameStartCurX, g_TaskFrameStartCurY )
	g_TaskFrameStartPosX = g_TaskFrameStartCurX
	g_TaskFrameStartPosY = g_TaskFrameStartCurY
end

function ResetTaskTrackFrame()
	g_TaskFrameStartPosX = -12
	g_TaskFrameStartPosY = 204
	g_TaskFrameStartCurX = -12
	g_TaskFrameStartCurY = 204
	getglobal("TaskTrackFrame"):SetPoint("topright", "PlayMainFrame", "topright", g_TaskFrameStartCurX, g_TaskFrameStartCurY )
end

--获取当前执行的主线任务ID
function GetCurMainTaskId()
	-- local t_MainTask = {1000,1001,1003,1006,1008,1009,1010,1012,1014,1015,1016,1017,1018,1022,1023,1024,1025,1138,1139,1040,1041,1042,1172,1173,1143};
	-- for i=1,#(t_MainTask) do
	-- 	local achievementId = t_MainTask[i];
	-- 	local achievementDef = AchievementMgr:getAchievementDef(achievementId);
	-- 	if achievementDef ~= nil and 2 == achievementDef.Group then	--主线任务
	-- 		if AchievementMgr:getAchievementState(achievementDef.ID) == ACTIVATE_UNCOMPLETE then
	-- 			local num = achievementDef.GoalNum;
	-- 			local arryNum = AchievementMgr:getAchievementArryNum(achievementDef.ID);
	-- 			if arryNum < num then
	-- 				return achievementDef.ID;
	-- 			end
	-- 		end
	-- 	end
	-- end

	if not AchievementMgr.getAchievementIDsByGroup then
		return 0 --C++没合并的时候做个容错
	end

	local strIDs = AchievementMgr:getAchievementIDsByGroup(2) --code_by:huangfubin
	local t_MainTask = StringSplit(strIDs, ',')
	if type(t_MainTask)~="table" then return 0 end

	table.sort(t_MainTask, function(a,b)
		local numa = tonumber(a) or 999999999
		local numb = tonumber(b) or 999999999
		return numa < numb --主要考虑移动端顺序不是从小到大
	end)

	local passTask = {}
	local function findNextTrack(achievementDef)
		if achievementDef ~= nil and 2 == achievementDef.Group then	--主线任务
			if passTask[achievementDef.ID] then
				return passTask[achievementDef.ID]
			end
			passTask[achievementDef.ID] = 0 --避免重复查找

			local achievementState = AchievementMgr:getAchievementState(CurMainPlayer:getObjId() ,achievementDef.ID)
			if achievementState == ACTIVATE_UNCOMPLETE then
				local num = achievementDef.GoalNum
				local arryNum = AchievementMgr:getAchievementArryNum(CurMainPlayer:getObjId(), achievementDef.ID)
				if arryNum < num then
					passTask[achievementDef.ID] = achievementDef.ID
					return achievementDef.ID --未完成
				else
					local nextAchievementDef = AchievementMgr:getAchievementDef(achievementDef.NextTrackID)
					if nextAchievementDef then
						local nextID = findNextTrack(nextAchievementDef) 
						passTask[achievementDef.ID] = nextID
						return nextID
					end --已完成，未领取奖励，追踪下一个任务
				end
			elseif achievementState > ACTIVATE_UNCOMPLETE then
				local nextAchievementDef = AchievementMgr:getAchievementDef(achievementDef.NextTrackID)
				if nextAchievementDef then
					local nextID = findNextTrack(nextAchievementDef) 
					passTask[achievementDef.ID] = nextID
					return nextID
				end --找下一个追踪任务
			-- else
			-- 	passTask[achievementDef.ID] = achievementDef.ID
			-- 	return achievementDef.ID --默认返回追踪任务 --不能这样
			end
		end
		return 0
	end
	
	for i=1,#(t_MainTask) do
		local achievementId = tonumber(t_MainTask[i]) or 0
		local achievementDef = AchievementMgr:getAchievementDef(achievementId);
		local id = findNextTrack(achievementDef)
		if id > 0 then
			return id
		end
	end

	return 0
end

function UpdateTaskTrackFrame()
	--if AccountManager:getMultiPlayer() ~= 0 then  return end
	if not CurWorld then return end
	if CurWorld:isGodMode() then return end
	-- if CUR_WORLD_MAPID > 0 and CUR_WORLD_MAPID ~= 2 then return end --都显示 code_by:huangfubin
	if CurWorld:getOWID() == NewbieWorldId or CurWorld:getOWID() == NewbieWorldId2 then return end
	local achievementId = AchievementMgr:getCurTrackID();
	local achievementDef = DefMgr:getAchievementDef(achievementId);
	local TaskTrackFrame = getglobal("TaskTrackFrame")
	if achievementId > 0 and achievementDef ~= nil then
		TaskTrackFrame:Show();
		local num = achievementDef.GoalNum;
		local arryNum = AchievementMgr:getAchievementArryNum(CurMainPlayer:getObjId(), achievementDef.ID);
		local szText = achievementDef.TrackDesc.."#n("..arryNum.."/"..num..")";
		if arryNum >= num then
		--	szText = achievementDef.TrackDesc.."#n(已完成)";
		--	getglobal("AchievementFinishTipsFrame"):Show();
		end
		getglobal("TaskTrackFrameTitle"):SetText(achievementDef.Name)
		getglobal("TaskTrackFrameDesc"):SetText(szText, 255, 255, 255);
		SetItemIcon(getglobal("TaskTrackFrameIcon"), achievementDef.IconID);
		UpdateTaskReward(achievementId)
	else
		TaskTrackFrame:Hide();
	end
end

function TaskTrackRewardItemBtn_Onclick()
	local itemId = this:GetClientUserData(0)
    local name = this:GetName()
    SetMTipsInfo(-1, name, false, itemId);
end

function UpdateTaskReward(achievementId)
	local achievementDef = AchievementMgr:getAchievementDef(achievementId)
    if achievementDef == nil then
        return
    end
    local hasReward = false --没有奖励的时候，领取奖励按钮
    for i = 1, 2 do
        local rewardIcon = getglobal("TaskTrackFrameReward" .. i)
        local numFont = getglobal("TaskTrackFrameRewardNum" .. i)
		local rewardItemBtn = getglobal("TaskTrackFrameRewardItemBtn" .. i)
        if achievementDef.RewardID[i - 1] > 0 then
            hasReward = true
            if achievementDef.RewardType[i - 1] == 0 then
                SetItemIcon(rewardIcon, achievementDef.RewardID[i - 1])
				rewardItemBtn:SetClientUserData(0, achievementDef.RewardID[i - 1]) --用来标记奖励物品的itemID;
            elseif achievementDef.RewardType[i - 1] == 1 then
                rewardIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml")
                rewardIcon:SetTexUV("icon_xingxing.png")
				rewardItemBtn:SetClientUserData(0, -1) --用来标记星星;
            elseif achievementDef.RewardType[i - 1] == 2 then
                rewardIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml")
                rewardIcon:SetTexUV("icon_coin")
				rewardItemBtn:SetClientUserData(0, -2) --用来标记迷你币;
            end
            numFont:SetText("×" .. achievementDef.RewardNum[i - 1])
        else
            rewardIcon:SetTextureHuires(ClientMgr:getNullItemIcon())
            numFont:SetText("")
			rewardItemBtn:SetClientUserData(0, 0) 
        end
    end
end

function SetSightingTelescopeFrame(visible)
    local set_btn = getglobal("SetSightingTelescopeBtn")

    if ClientMgr:isMobile() and CurMainPlayer:hasSightingTelescope() then
        set_btn:Show()
    else
        set_btn:Hide()
    end
end

function SetSightingTelescopeFrame_OnClick()
    CurMainPlayer:setSightingTelescope();
end

--LLDO:展示击杀信息--------------------------------------------------------------------------------------------
local KillInfoFrameDisplayTime = 0;
local KillInfoFrame_CWKills = 1;
local KillInfoFrame_DescStrID = {6365, 6366, 6367, 6368, 6369, 6370, 6371, 6372, 6373, 6374};
local KillInfoFrame_TeamInfo ={
		{name=748, r=255, g=249, b=235},--白
		{name=713, r=237, g=73, b=22},	--红
		{name=714,r=4, g=255, b=246},	--蓝
		{name=715,r=26, g=238, b=22},	--绿
		{name=717,r=237, g=223, b=22},	--黄
		{name=718,r=237, g=144, b=22},	--橙
		{name=716,r=194, g=22, b=237},	--紫
		};

function KillInfoFrame_OnShow()
	
end

function KillInfoFrame_OnHide()
	-- body
	GetInst("MiniUIManager"):CloseUI("zhongzhongyijiAutoGen")
end

function KillInfoFrame_OnUpdate()
	KillInfoFrameDisplayTime = KillInfoFrameDisplayTime - arg1
	local bkg = getglobal("KillInfoFrameTxBkg");

	if KillInfoFrameDisplayTime <= 3 then
		Log("KillInfoFrame_OnUpdate: KillInfoFrameDisplayTime = " .. KillInfoFrameDisplayTime);

		local alpha1 = bkg:GetBlendAlpha();
		alpha1 = alpha1 - 0.25*arg1/3;
		if alpha1 < 0 then
		 	alpha1 = 0;
		end

		bkg:SetBlendAlpha(alpha1);

		if KillInfoFrameDisplayTime <= 0 then
			this:Hide();
			bkg:SetBlendAlpha(0.25);
		end
	end
end

function ShowKillInfoFrame(beKillUin, CWKills)
	--beKillUin:被击杀者的uin, CWKills:连杀数量
	Log("ShowKillInfoFrame:");
	Log("beKillUin = " .. beKillUin);
	Log("CWKills = " .. CWKills);

	local myUin = GetMyUin();
	local otherUin = beKillUin;
	KillInfoFrame_CWKills = CWKills or 1;

	GetInst("WeekendCarnivalMgr"):killSomebody()

	--拉取自己个人信息。
	KillInfoFrame_GetProfile(myUin, Resp_ShowKillInfoFrame_GetMyProfile, otherUin);
	--埋点击杀玩家
	Report418Event(2);
end

--获取击杀用户信息
-- function KillInfoFrame_GetPlayerInfo(myUin, otherUin, CWKills)
-- 	if myUin and otherUin and CWKills then
-- 		Log("KillInfoFrame_GetPlayerInfo:");
-- 		Log("myUin = " .. myUin .. ", otherUin = " .. otherUin .. ", CWKills = " .. CWKills);

-- 		if AccountManager.other_baseinfo then
-- 			local errCode1, myBaseInfo = AccountManager:other_baseinfo(myUin);
-- 			var_dump(myBaseInfo);
-- 			local errCode2, otherBaseInfo = AccountManager:other_baseinfo(otherUin);

-- 			if errCode1 and errCode2 and errCode1 == 0 and errCode2 == 0 then
-- 				var_dump(myBaseInfo);
-- 				var_dump(otherBaseInfo);

-- 				--1. 设置头像
-- 				KillInfoFrame_SetHead(myUin, "KillInfoFrameOtherHead", myBaseInfo);
-- 				KillInfoFrame_SetHead(otherUin, "KillInfoFrameMyHead", otherBaseInfo);
-- 			end
-- 		end
-- 	end
-- end

--拉取个人信息
g_KillInfoFrame_AllProfile = {};

--开房间或加入房间的时候, 将g_KillInfoFrame_AllProfile清空
function KillInfoFrame_InitProfile()
	g_KillInfoFrame_AllProfile = nil;
	g_KillInfoFrame_AllProfile = {};
end

function KillInfoFrame_GetProfile(_op_uin, _callback, _userdata)
	local uin_ = getLongUin(_op_uin);
	local url_ = g_http_root_map .. 'miniw/profile?act=getProfile&op_uin=' .. uin_.. '&' .. 'fast=110' .. '&' .. http_getS1Map();
	Log( "url_ = "..url_ );

	if _callback then
		--如果个人信息已经有了, 则不用重复拉取?????????????????
		local data = {userdata = _userdata, bFlag = false, otherUin = _op_uin};
		if g_KillInfoFrame_AllProfile and #g_KillInfoFrame_AllProfile > 0 then
			for i = 1, #g_KillInfoFrame_AllProfile do
				if _op_uin == g_KillInfoFrame_AllProfile[i].profile.uin then
					data.bFlag = true;	--已经存在.
					Log("KillInfoFrame_GetProfile: Have Existed!!!uin = " .. _op_uin);
					_callback(g_KillInfoFrame_AllProfile[i], data);
					return;
				end
			end
		end

		ns_http.func.rpc( url_, _callback, data,nil,ns_http.SecurityTypeHigh);
	end
end

--拉取自己个人信息回调
function Resp_ShowKillInfoFrame_GetMyProfile(ret, data)
	Log("Resp_ShowKillInfoFrame_GetMyProfileInfo:");
	--data = {userdata = _userdata, bFlag = true};
	local bFlag = data.bFlag;
	local _otherUin = data.userdata;

	if ret and ret.ret == 0 and ret.profile then
		Log("_otherUin = " .. _otherUin);
		if bFlag == false then
			--不存在, 存入全局变量中.
			Log("LLLOG:Don`t Existed !!");
			table.insert(g_KillInfoFrame_AllProfile, ret);
		end

		--拉取自己的信息成功, 再拉取别人的.
		KillInfoFrame_GetProfile(_otherUin, Resp_ShowKillInfoFrame_GetOtherProfile, ret);
	end
end

--拉取被杀者的个人信息回调
function Resp_ShowKillInfoFrame_GetOtherProfile(ret, data)
	
	--加个判断，可能在网络情况差情况下退出游戏还会显示击杀
	if not  (ClientCurGame and ClientCurGame:isInGame()) then
		return
	end

	Log("Resp_ShowKillInfoFrame_GetOtherProfile:");
	--data = {userdata = _userdata, bFlag = true};
	local myRet = data.userdata;
	local bFlag = data.bFlag;
	local otherUin = data.otherUin;

	local killinfoFrame = getglobal("KillInfoFrame");
	local myName = getglobal("KillInfoFrameMyName");
	local otherName = getglobal("KillInfoFrameOtherName");
	 

	if ret and ret.ret == 0 and ret.profile then
		Log("myRet:");
		var_dump(myRet);
		Log("ret:");
		var_dump(ret.profile);

		if bFlag == false then
			--不存在, 存入全局变量中.
			Log("LLLOG:Don`t Existed !!");
			table.insert(g_KillInfoFrame_AllProfile, ret);
		end
		--var_dump(g_KillInfoFrame_AllProfile);

		if killinfoFrame:IsShown() then
			killinfoFrame:Hide()
		end
		killinfoFrame:Show();
		KillInfoFrameDisplayTime = 5.0;

		--拉取玩家信息, 参考函数:UpdateBattleInfo();
		local num = ClientCurGame:getNumPlayerBriefInfo();
		local myBriefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
		local otherBriefInfo = nil;
		for i=1, num do
			otherBriefInfo = ClientCurGame:getPlayerBriefInfo(i-1);
			if otherBriefInfo.uin == otherUin then
				break;
			end
		end

		--1. 名字
		if myRet.profile.RoleInfo and ret.profile.RoleInfo then
			print("AllOK:");
			local myNameStr = myRet.profile.RoleInfo.NickName or "";
			local otherNameStr = ret.profile.RoleInfo.NickName or "";
			KillInfoFrame_SetName("KillInfoFrameMyName", myNameStr, myBriefInfo.teamid + 1);
			KillInfoFrame_SetName("KillInfoFrameOtherName", otherNameStr, otherBriefInfo.teamid + 1);

			--2. 头像
			KillInfoFrame_SetHead(ret.profile.uin, "KillInfoFrameOtherHead", ret);
			KillInfoFrame_SetHead(GetMyUin(), "KillInfoFrameMyHead", myRet);


			local player = CurWorld:getActorMgr():findActorByWID(myBriefInfo.uin)
			if not player then
				return
			end
			local itemid = player:getCurToolID()
			local skinId = WeaponSkin_HelperModule:GetSkinID(myRet.profile.uin, itemid)
			--3. 击杀描述
			local config = ns_shop_all_skinid_weaponskin_config[skinId] and ns_shop_all_skinid_weaponskin_config[skinId][1] or nil

			if config and config.EffectName and  config.EffectName ~= "" then
				getglobal("KillInfoFrameDesc"):Hide()
				getglobal("KillInfoFrameBkg"):Hide()
				getglobal("KillInfoFrameTxBkg"):Hide()
				getglobal("KillInfoFrameDesc"):Hide()
				getglobal("KillInfoFrameMyHead"):SetPoint("topleft", "KillInfoFrame", "topleft", 61, 0)
				getglobal("KillInfoFrameOtherHead"):SetPoint("topright", "KillInfoFrame", "topright", -85, 0)
				
				GetInst("MiniUIManager"):CloseUI("zhongzhongyijiAutoGen")
				GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/zhongzhongyiji"})
				GetInst("MiniUIManager"):OpenUI(config.EffectName.."jisha","miniui/miniworld/zhongzhongyiji","zhongzhongyijiAutoGen", {
					killNum = KillInfoFrame_CWKills > 10 and 10 or KillInfoFrame_CWKills,
					disableOperateUI = true,
					keep = true})
			else
				getglobal("KillInfoFrameDesc"):Show()
				getglobal("KillInfoFrameBkg"):Show()
				getglobal("KillInfoFrameTxBkg"):Show()
				getglobal("KillInfoFrameDesc"):Show()
				getglobal("KillInfoFrameMyHead"):SetPoint("topleft", "KillInfoFrame", "topleft", 35, 0)
				getglobal("KillInfoFrameOtherHead"):SetPoint("topright", "KillInfoFrame", "topright", -35, 0)
				local descObj = getglobal("KillInfoFrameDesc");
				local strDesc = "";
				if KillInfoFrame_CWKills <= #KillInfoFrame_DescStrID then
					strDesc = GetS(KillInfoFrame_DescStrID[KillInfoFrame_CWKills]);
				else
					strDesc = GetS(KillInfoFrame_DescStrID[#KillInfoFrame_DescStrID]);
				end
				descObj:SetText(strDesc);
			end

		end
	end
end

--设置头像
function KillInfoFrame_SetHead(uin, strHeadBtn, ret)
	local uin = ret.profile.uin or uin or 1;
	local model = ret.profile.RoleInfo.Model or 0;
	local skinid = ret.profile.RoleInfo.SkinID or 0;
	local hasAvatar = ret.profile.RoleInfo.HasAvatar or 0;
	local strHeadIcon = strHeadBtn .. "Icon";
	local strHeadFrame = strHeadBtn .. "IconFrame"
	local headObj = getglobal(strHeadIcon);


	if ret.profile.header and ret.profile.header.url then
		SetUserHeadIconByUrl(ret.profile.header.url, ret.profile.header.checked, uin, headObj);
	else
		HeadCtrl:SetPlayerHeadByUin(strHeadIcon,uin,model,skinid,hasAvatar);
	end
	--头像框
	HeadFrameCtrl:SetPlayerheadFrameName(strHeadFrame,ret.profile.head_frame_id);
end

--设置名字
function KillInfoFrame_SetName(nameUi, nameStr, teamId)
	Log("KillInfoFrame_SetName: nameStr = " .. nameStr .. ", teamId = " .. teamId);
	local nameObj = getglobal(nameUi);
	nameObj:SetText(nameStr);
	nameObj:SetTextColor(KillInfoFrame_TeamInfo[teamId].r, KillInfoFrame_TeamInfo[teamId].g, KillInfoFrame_TeamInfo[teamId].b);
end

--LLDO:展示击杀信息:end--------------------------------------------------------------------------------------------

function GasInfo_OnLoad()
	this:RegisterEvent("GE_SYNC_GAS_TIME");
	this:RegisterEvent("GE_SYNC_PLAYER_NUM");
end

function GasInfo_OnEvent()
    local ge = GameEventQue:getCurEvent();
    local gasframe = getglobal("GasInfo")

    --检查是否显示
    if CurWorld ~= nil and CurWorld:isGameMakerRunMode() then
        local curOpId, val = 0, 0;
        curOpId, val = CurWorld:getRuleOptionID(35, curOpId, val);
        if not val then
            gasframe:Hide()
            return
        end
    else
        gasframe:Hide()
        return
    end

    gasframe:Show()

    if arg1 == "GE_SYNC_GAS_TIME" then
        local stage = ge.body.gastimeinfo.stage;
        local cur_t = ge.body.gastimeinfo.cur_time;
        local beg_t = ge.body.gastimeinfo.beg_time;
        local end_t = ge.body.gastimeinfo.end_time;

        --设置时间标题
        if stage == 1 then
            getglobal("GasInfoTimeTitle"):SetText(GetS(8011))
        elseif stage == 2 then
            getglobal("GasInfoTimeTitle"):SetText(GetS(8012))
        elseif stage == 3 then
            getglobal("GasInfoTimeTitle"):SetText(GetS(8015))
	elseif stage == 4 then
		getglobal("GasInfoTimeTitle"):SetText(GetS(8019))
	elseif stage == 5 then
		getglobal("GasInfoTimeTitle"):SetText(GetS(8020));
		getglobal("GasInfoTime"):SetText("");
        end

        --设置时间和进度条
	if stage ~= 5 then
		local s, m;
		local ratio;
		s = end_t - cur_t;
		ratio = s / (end_t - beg_t)
		if s >= 0 then
		    m = math.floor(s/60);
		    s = s - m*60;

		    getglobal("GasInfoTime"):SetText(m..":"..s)
		    --getglobal("GasInfoRemainTime"):SetWidth(getglobal("GasInfoFullTime"):GetWidth()*ratio);
		end
	end
    elseif arg1 == "GE_SYNC_PLAYER_NUM" then
        local alive = ge.body.playerinfo.alive;
        local all = ge.body.playerinfo.all;

        getglobal("GasInfoPlayerNumber"):SetText(alive.."/"..all)
    end
end

function GasInfo_OnUpdate()
    local gasframe = getglobal("GasInfo")

    --检查是否显示
    if CurWorld == nil or not CurWorld:isGameMakerRunMode() then
        gasframe:Hide()
    end

end



--LLDO:小鸡坐骑能量条--------------------------------------------------------------------------------------------
function ChickenEnergyFrame_OnUpdate()

	local ride = CurMainPlayer:getRidingHorse();
	if ride == nil then
	   return;
	end

	local isRush = ride:hasWaterSkill(4)
	local energyBar = getglobal("ChickenEnergyFrameBar");
	local energy = ride:getEnergy();
	local isFatigue = ride:isTired();
	if not isRush then
		local baricon = getglobal("ChickenEnergyFrameIcon")
		baricon:SetTextureHuiresXml("ui/mobile/texture2/old_operateframe.xml");
		baricon:SetTexUV("zq_fly.png");
	end

	if not isFatigue then
		energyBar:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
		energyBar:SetTexUV("zq_jindu.png");

		if ClientMgr:isMobile() then
			energyBar:SetSize(energy*2.46,13);
		else
			energyBar:SetSize(energy*1.66,13);
		end
	else
		energyBar:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
		energyBar:SetTexUV("sjb_jindu.png");

		if ClientMgr:isMobile() then
			energyBar:SetSize(energy*2.46,13);
		else
			energyBar:SetSize(energy*1.66,13);
		end
	end
end



--人物动作表情
function CharacterActionBtn_OnClick()
	print("CharacterActionBtn_OnClick")
	print(debug.traceback("message", 1))
	if isEducationalVersion then
		return;
	end

	if IsInHomeLandMap() then
		-- 家园快捷短语按钮click埋点上报
		Homeland_StandReport_MainUIView("ShortcutPhrase", "click")
	end

	if getglobal("CharacterActionFrame"):IsShown() then
		getglobal("ActionLibraryFrame"):Hide();
		getglobal("CharacterActionFrame"):Hide();
		--家园埋点
		Homeland_StandReportSingleEvent("PHRASE", "Close", "click", {})
	else
		getglobal("CharacterActionFrame"):Show();
	end

	setkv("IsShownCharacterActionRedTag",1)
	getglobal("CharacterActionRedTag"):Hide()
end

--装扮互动被邀请点击
function ActorBeInviteBtn_OnClick()
	getglobal("ActorInviteTipBtn"):Hide()
	getglobal("CharacterActionFrame"):Show();
	ShowActorInvite(true)
end

--自动演奏，自由演奏被点击
function MusicPlayModeBtn_OnClick()
	if CurMainPlayer:isDead() then
        return
    end

	if getglobal("DeathFrame"):IsShown() then
		return
	end

	if not getglobal("MusicPlayModeBtn") or not getglobal("MusicPlayModeBtn"):IsShown() then
		return
	end

	if g_MusicItemLogical:getIsMusicState() then
		return
	end
	
	local mvcFrame = GetInst("UIManager"):GetCtrl("StarStationInfo")

	if CurMainPlayer and CurMainPlayer:isShapeShift() then
		ShowGameTips(GetS(130026))
		return
	end

	local ride = CurMainPlayer:getRidingHorse();
	if ride or (mvcFrame and mvcFrame.view and mvcFrame.view.root and mvcFrame.view.root:IsShown()) then
		ShowGameTips(GetS(130025))
		return
	end

	local itemId = ClientBackpack:getGridItem(ClientBackpack:getShortcutStartIndex()+ShortCut_SelectedIndex)

	if GetInst("MiniUIManager"):IsShown("main_player_free") then
		GetInst("MiniUIManager"):CloseUI("main_player_freeAutoGen")
	end

	if itemId > 0 then
		local itemDef = ItemDefCsv:get(itemId)

		if itemDef.Type == ITEM_TYPE_MUSIC then
			-- CurMainPlayer:playAct(600108)
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common"})
			GetInst("MiniUIManager"):OpenUI(
				"main_player_free", 
				"miniui/miniworld/music_roleplay", 
				"main_player_freeAutoGen",{id=itemId}
				)

			CurMainPlayer:setViewMode(2)
			if CurWorld then
				if CurWorld:isRemoteMode() then -- 客机
					standReportEvent("1001", "MINI_TOOL_BAR", "EnterFreePlay", "click")
				else
					standReportEvent("1003", "MINI_TOOL_BAR", "EnterFreePlay", "click")
				end
			end
		end
	end
end

function MusicPreinstallBtn_OnClick()
	GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/music_roleplay", "miniui/miniworld/common_comp"})

	GetInst("MiniUIManager"):OpenUI(
		"main_songbook", 
		"miniui/miniworld/music_roleplay", 

		"main_songbookAutoGen",{callback = function()

			local data = GetInst("songBookDataManager"):getCurData()

			if data then
				local nameStr = DefMgr:filterString(data.name)
				getglobal("MusicPreinstallBtnTips"):SetText(nameStr)
			end
		end}
	)

	if CurWorld then
		if CurWorld:isRemoteMode() then -- 客机
			standReportEvent("1001", "MINI_TOOL_BAR", "EnterMusicLibrary", "click")
		else
			standReportEvent("1003", "MINI_TOOL_BAR", "EnterMusicLibrary", "click")
		end
	end
end

----------------------------------------------------------物理机械：键位控制-------------------------------------------------------
--PC端键位控制管理
local PC_VehicleKeyMgr = {

	MAX_KEY_PC = 21,
	MAX_KEY_FIRSTLINE_PC = 16,

	--存储可用键位信息的table：一期固定21键位，不可自定义增删编辑
	key = {
		--{id=xx, name="xx", value=xx}

	},

	t_del = {

	},

	--键位初始化：一期没有自定义编辑，Init一次就行了
	InitKey = function(self)
		print("PC VehicleKeyMgr key_Init:")
		self.key = {	--总键位
			{id=1,		name="W",			value=87,	uv="icon_speedup"},
			{id=2,		name="A",			value=65,	uv="icon_turnleft"},
			{id=3,		name="S",			value=83,	uv="icon_speeddown"},
			{id=4,		name="D",			value=68,	uv="icon_turnright"},
			--{id=5,		name="1",			value=49,	},
			--{id=6,		name="2",			value=50,	},
			--{id=7,		name="3",			value=51,	},
			--{id=8,		name="4",			value=52,	},
			--{id=9,		name="5",			value=53,	},
			--{id=10,		name="6",			value=54,	},
			--{id=11,		name="7",			value=55,	},
			--{id=12,		name="8",			value=56,	},
			--{id=13,		name="Q",			value=81,	},
			--{id=14,		name="E",			value=69,	},
			{id=5,		name="R",			value=82,	uv="icon_turnover"},
			--{id=16,		name="Z",			value=90,	},
			--{id=17,		name=GetS(12010),	value=150,	},
			--{id=18,		name=GetS(12011),	value=151,	},
			--{id=19,		name="Space",		value=32,	},
			--{id=20,		name="Ctrl",		value=17,	},
			{id=6,		name="Shift",		value=16,	uv="icon_getout"},
		}

		

	end,


	GetKeyTable = function(self)
		return self.key
	end,

	--键位数量变化后，自适应排版：一期先只对不同数量的按键做居中处理
	UpdateKeyCtrl = function(self)
		print("PC VehicleKeyMgr UpdateKeyCtrl:")
		local key = self.key
		self.t_del = {}
		local vehicle = CurMainPlayer and CurMainPlayer:getDrivingVehicle() or nil
		if vehicle then	
			if vehicle:getEngineNum() <= 0 then
				for i=1,#(key) do
					if key[i].name == "W" or key[i].name == "S" then
						table.insert(self.t_del, i)
					end
				end
			end

			if vehicle:getSteeringSwitch() == false then
				for i=1,#(key) do
					if key[i].name == "A" or key[i].name == "D" then
						table.insert(self.t_del,i)
					end
				end
			end
		end

		if #(self.t_del) > 0 then
			table.sort(self.t_del,function(a,b) return a > b end)
			self:DeleteKey()
		end
		self:UpdateKeyUI()

		
	end,

	--刷新键位UI
	UpdateKeyUI = function(self)
		local btn_name = "PC_VehicleShortCut"
		print("Current Key:",self.key)
		for i=1,self.MAX_KEY_PC do
			if i <= #(self.key) then
				getglobal(btn_name..i.."Name"):SetText(self.key[i].name)
				getglobal(btn_name..i.."Icon"):SetTexUV(self.key[i].uv)
			end
		end

		local key_num = #(self.key)
		print("PC VehicleKeyMgr key_UpdatePos:",key_num)
		local btn_name = "PC_VehicleShortCut"
		for i=1,self.MAX_KEY_PC do
			if i<=key_num then
				getglobal(btn_name..i):Show()
			else
				getglobal(btn_name..i):Hide()
			end
		end

		local firstline_key = key_num
		local line = 1
		if key_num > self.MAX_KEY_FIRSTLINE_PC then
			firstline_key = self.MAX_KEY_FIRSTLINE_PC
			line = 2
		end
		
		--自适应排版 居中
		local btn_width = 61
		local interval  = 12
		local width = ((btn_width + interval) * firstline_key - interval);
		getglobal("PC_VehicleControlFrame"):SetWidth(width)
		getglobal("PC_VehicleControlFrame"):SetHeight(btn_width+(btn_width+10)*(line-1))
		for i=1,firstline_key do
			getglobal(btn_name..i):SetPoint("bottomleft","PC_VehicleControlFrame","bottomleft",(i-1)*(btn_width+interval),0)
		end
		for i= self.MAX_KEY_FIRSTLINE_PC + 1, key_num do
			if i < 19 then
				getglobal(btn_name..i):SetPoint("bottom",btn_name..tostring(i-14),"top",0,-10)
			else
				getglobal(btn_name..i):SetPoint("bottom",btn_name..tostring(i-6),"top",0,-10)
			end
		end
	end,

	DeleteKey = function(self)
		if #(self.t_del) == 0 then return end
		print("DeleteKey:",self.t_del)
		for i=1, #(self.t_del) do
			table.remove(self.key, self.t_del[i])
		end
		self.t_del = {}
	end,

	--按下键位，触发设置效果.input: key表索引
	TiggerKeyPressed = function(self, idx, ispressed)
		
		if self.key[idx] and self.key[idx].value then
			local value = self.key[idx].value
			----print("PC VehicleKeyMgr TriggerKeyPressed:",idx,ispressed,value)
			if value == _G.vehicle_config.left_key then					--左转
				VehicleControlInput:setSteerLeftKeyPressed(ispressed)
			elseif value == _G.vehicle_config.right_key then 			--右转
				VehicleControlInput:setSteerRightKeyPressed(ispressed)
			elseif value == _G.vehicle_config.forward_key then			--前进
				VehicleControlInput:setAccelKeyPressed(ispressed)
			elseif value == _G.vehicle_config.backward_key then			--后退
				VehicleControlInput:setBrakeKeyPressed(ispressed)
			elseif value == _G.vehicle_config.leave_key then 			--下车
				CurMainPlayer:dismountActor();
			elseif value == _G.vehicle_config.reset_key then 			--重置
				local vehicle = CurMainPlayer:getDrivingVehicle()
				if vehicle then
					vehicle:reset()
				end
			end
		end
	end,
	

}

--mobile端键位控制管理
local Mobile_VehicleKeyMgr = {
	MAX_KEY_MOBILE = 21,		--键位数量上限
	MAX_KEY_MOBILE_RECT = 8,	--方形按钮数量上限
	MAX_KEY_MOBILE_CIRCLE = 8,	--圆形按钮数量上限

	--存储可用键位信息的table：一期固定21键位，不可自定义增删编辑
	key = {
		
	},

	Init = function(self)
		print("Mobile VehicleKey Mgr: Init")
		self.key = {	--总键位
			--{id=1,		name="W",			value=87,	},
			--{id=2,		name="A",			value=65,	},
			--{id=3,		name="S",			value=83,	},
			--{id=4,		name="D",			value=68,	},
			--{id=5,		name="1",			value=49,	},
			--{id=6,		name="2",			value=50,	},
			--{id=7,		name="3",			value=51,	},
			--{id=8,		name="4",			value=52,	},
			--{id=9,		name="5",			value=53,	},
			--{id=10,		name="6",			value=54,	},
			--{id=11,		name="7",			value=55,	},
			--{id=12,		name="8",			value=56,	},
			--{id=13,		name="Q",			value=81,	},
			--{id=14,		name="E",			value=69,	},
			{id=1,		name="R",			value=82,	},
			--{id=16,		name="Z",			value=90,	},
			--{id=17,		name=GetS(12010),	value=150,	},
			--{id=18,		name=GetS(12011),	value=151,	},
			--{id=19,		name="Space",		value=32,	},
			--{id=20,		name="Ctrl",		value=17,	},
			{id=2,		name="Shift",		value=16,	},
		}
	end,

	UpdateKeyPos = function(self)
		--local key_num = #(self.key)
		print("Mobile Vehicle Mgr: UpdateKeyPos")
		getglobal("Mobile_Circle_VehicleControlFrameBtn3"):Show()
		getglobal("Mobile_Circle_VehicleControlFrameBtn5"):Show()
		local icon3 = getglobal("Mobile_Circle_VehicleControlFrameBtn3Icon")
		local icon5 = getglobal("Mobile_Circle_VehicleControlFrameBtn5Icon")
		icon3:SetTexUV("icon_turnover")
		icon5:SetTexUV("icon_getout")
		--local rect_btn_name = "Mobile_VehicleShortCut"
		--local btn_width = 61
		--local interval  = 12
		--local width = (btn_width + interval) * 2 - interval
		--getglobal("Mobile_Rect_VehicleControlFrame"):SetWidth(width)
		--getglobal("Mobile_Rect_VehicleControlFrame"):SetHeight(btn_width + interval)
		--for i=1,8 do
		--	getglobal(rect_btn_name..i.."Name"):Hide()
		--	if i < 3 then
		--		getglobal(rect_btn_name..i):SetPoint("bottomleft","Mobile_Rect_VehicleControlFrame","bottomleft",(i-1)*(btn_width+interval),0)
		--		getglobal(rect_btn_name..i):Show()
		--	else
		--		getglobal(rect_btn_name..i):Hide()
		--	end
		--end

	end,

	TiggerKeyPressed = function(self, idx, ispressed)
		if idx == 3 then idx = 1 end
		if idx == 5 then idx = 2 end
		print("Mobile VehicleKeyMgr TriggerKeyPressed:",idx,ispressed)
		if self.key[idx] and self.key[idx].value then
			local value = self.key[idx].value

			if value == _G.vehicle_config.leave_key then 			--下车
				CurMainPlayer:dismountActor();
			elseif value == _G.vehicle_config.reset_key then 			--重置
				local vehicle = CurMainPlayer:getDrivingVehicle()
				if vehicle then
					vehicle:reset()
				end
			end
		end
	end,



}

function VehicleKeyMgrGetInstance(platform)
	print("VehicleKeyMgrGetInstance:",platform);
	if platform == "PC" then
		return PC_VehicleKeyMgr;
	elseif platform == "Mobile" then
		return Mobile_VehicleKeyMgr;
	end
end

function PC_VehicleControlFrame_OnShow( ... )
	if not getglobal("PC_VehicleControlFrame"):IsReshow() then
		local keyMgr = VehicleKeyMgrGetInstance("PC")
		if keyMgr then
			keyMgr:InitKey();
			keyMgr:UpdateKeyCtrl();
		end
	end

end

function VehicleControlBtnTemplate_OnMouseDown( ... )
	local idx = this:GetClientID()
	local keyMgr = nil;
	if ClientMgr:isPC() then
		keyMgr = VehicleKeyMgrGetInstance("PC")
	elseif ClientMgr:isMobile() then
		keyMgr = VehicleKeyMgrGetInstance("Mobile")
	end
	if not keyMgr then return end
	keyMgr:TiggerKeyPressed(idx,true)
	
end

function VehicleControlBtnTemplate_OnMouseUp( ... )
	local idx = this:GetClientID()
	local keyMgr = nil;
	if ClientMgr:isPC() then
		keyMgr = VehicleKeyMgrGetInstance("PC")
	elseif ClientMgr:isMobile() then
		keyMgr = VehicleKeyMgrGetInstance("Mobile")
	end
	if not keyMgr then return end
	keyMgr:TiggerKeyPressed(idx,false)
end

function MobileVehicleCircleBtnTemplate_OnClick( ... )
	local idx = this:GetClientID()
	local keyMgr = VehicleKeyMgrGetInstance("Mobile")
	if keyMgr then
		keyMgr:TiggerKeyPressed(idx,true)
	end
end

------------------------------------------------移动端键位-----------------------------------------------------------------------------
local MAX_KEY_MOBILE_RECT = 8;

function Mobile_Circle_VehicleControlFrame_OnShow( ... )
	if not getglobal("Mobile_Rect_VehicleControlFrame"):IsReshow() then
		local keyMgr =  VehicleKeyMgrGetInstance("Mobile")
		if not keyMgr then return end
		keyMgr:Init()
		keyMgr:UpdateKeyPos()
	end

end


--------------------------------------------------物理机械：血量/速度/油耗/键位等显示隐藏---------------------------------------
local t_NeedHide = {}
function setVehicleUI(isshown)

	--if ClientMgr:isPC() then
	--	vehicleUI = getglobal("PC_VehicleControlFrame")
	--elseif ClientMgr:isMobile() then
	--	vehicleUI = getglobal("Mobile_Circle_VehicleControlFrame")
	--end
	if not CurMainPlayer then
		return
	end

    local vehicle = CurMainPlayer:getDrivingVehicle()
	local t_vehiclestate = {
		getglobal("VehicleState"),
	}
	local t_vehiclespeedstate = {
		getglobal("VehicleSpeedState"),
	}
	for i = 1, #(t_vehiclestate) do
		t_vehiclestate[i]:Hide()
	end
	for i = 1,#(t_vehiclespeedstate) do 
		t_vehiclespeedstate[i]:Hide()
	end
	local t_HideFrame = {
		--getglobal("AccRideCallBtn"),
		--getglobal("PlayShortcut"),
		getglobal("GunMagazine"),
		getglobal("CharacterActionFrame"),
		--getglobal("PlayMainFrameRide"),
		--getglobal("PlayMainFrameBackpack"),
		getglobal("ColoreSelectedFrame"),
		getglobal("ToolModeFrame"),
	}

	if not CurMainPlayer then return end
	if CurMainPlayer:isVehicleController() then
		table.insert(t_HideFrame,getglobal("PlayShortcut"))
		table.insert(t_HideFrame,getglobal("PlayMainFrameBackpack"))
		if UGCModeMgr and UGCModeMgr:IsEditing() then  -- 编辑地图
			GetInst("MiniUIManager"):HideMiniUI()
		end
	end
	

	if isshown == true then
		if #(t_NeedHide) == 0 then
			for i=1,#(t_HideFrame) do
				if t_HideFrame[i]:IsShown() then
					print("t_HideFrame",i)
					table.insert(t_NeedHide,t_HideFrame[i])
				end
			end
		end

		for i = 1, #(t_NeedHide) do
			local mvcFrame = GetInst("UIManager"):GetCtrl(t_HideFrame[i]:GetName());
			if mvcFrame then
				GetInst("UIManager"):Close(t_HideFrame[i]:GetName());
			else
				t_NeedHide[i]:Hide()
			end
		end
		
		getglobal("PlayMainFrameDismountVehicle"):Hide();
		if CurMainPlayer:isVehicleController() then
			local param = {disableOperateUI = true}
			GetInst("UIManager"):Open("VehicleDriveMode",param)
		else
			GetInst("UIManager"):Close("VehicleDriveMode")
			if CurMainPlayer:getMountType() == MOUNT_DRIVE and ClientMgr:isMobile() then
				getglobal("PlayMainFrameDismountVehicle"):Show();
			end

		end
		if CurMainPlayer:isVehicleDriver() and vehicle:hasFuel()then
			for i = 1, #(t_vehiclestate) do
				t_vehiclestate[i]:Show()
			end
		end
		
		if CurMainPlayer:isVehicleDriver() then
			for i = 1,#(t_vehiclespeedstate) do 
				t_vehiclespeedstate[i]:Show()
			end
		end 

		if vehicle:getEngineType() then
			for i = 1, #(t_vehiclestate) do
				t_vehiclestate[i]:Hide()
			end
		end
		
		getglobal("AccRideCallBtn"):Hide();

	else
		if #(t_NeedHide) > 0 then
			for i=1,#(t_NeedHide) do
				if not t_NeedHide[i]:IsShown() then
					local mvcFrame = GetInst("UIManager"):GetCtrl(t_HideFrame[i]:GetName());
					if mvcFrame then
						GetInst("UIManager"):Open(t_HideFrame[i]:GetName());
					else
						t_NeedHide[i]:Show()
					end
				end
			end
			t_NeedHide = {}
		end

		if UGCModeMgr and UGCModeMgr:IsEditing() then  -- 编辑地图
			GetInst("MiniUIManager"):ShowMiniUI()
		end

		GetInst("UIManager"):Close("VehicleDriveMode")

		for i = 1, #(t_vehiclestate) do
			t_vehiclestate[i]:Hide()
		end

		if not isEducationalVersion then
			--新手地图中隐藏 坐骑按钮
			if CurWorld and CurWorld:getOWID() ~= NewbieWorldId and CurWorld:getOWID() ~= NewbieWorldId2 and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then--xyang自定义UI
				getglobal("AccRideCallBtn"):Show();
			else
				getglobal("AccRideCallBtn"):Hide();
			end
		end

		--变形按钮
		if getglobal("AccRideCallBtn"):IsShown() then
			getglobal("AccRideChangeBtn"):SetPoint("right", "AccRideCallBtn", "left", -3, 0)
		else
			getglobal("AccRideChangeBtn"):SetPoint("center", "AccRideCallBtn", "center", 0, 0)
		end

		if getglobal("PlayMainFrameDismountVehicle"):IsShown() then
			getglobal("PlayMainFrameDismountVehicle"):Hide();
		end


	end

	local vehicle = CurMainPlayer:getDrivingVehicle()
	if vehicle==nil or vehicle:getMinPartsCost() == 999 or not CurMainPlayer:isVehicleDriver() then
		getglobal("VehicleStateFuelScale"):Hide()
		getglobal("VehicleStateFuelCursor"):Hide()
		getglobal("VehicleStateFuelIcon"):Hide()
	else
		getglobal("VehicleStateFuelScale"):Show()
		getglobal("VehicleStateFuelCursor"):Show()
		getglobal("VehicleStateFuelIcon"):Show()
	end

	--教育版不显示坐骑
	if isEducationalVersion then
		getglobal("AccRideCallBtn"):Hide();
	end
end

--------------------------------------------------------车辆状态：速度、油耗...------------------------------------------------------
function VehicleState_OnLoad( ... )
	this:setUpdateTime(0.25)
end

function VehicleState_OnUpdate( ... )
	getglobal("VehicleStateFuelCursor"):SetPoint("bottom","VehicleStateFuelScale","bottomleft",200,-11)
	local vehicle = CurMainPlayer:getDrivingVehicle()
	print("_curspeed","987")
	if CurMainPlayer:getMountType() == MOUNT_DRIVE and vehicle ~= nil then
		print("_curspeed","213")
		local curSpeed = vehicle:getCurSpeedShow()
		getglobal("VehicleCurSpeed"):SetText(curSpeed)
		
		local fuelrate = vehicle:getMinPartsCost()
		if fuelrate then
			local scale = getglobal("VehicleStateFuelScale"):GetWidth()
			--print("fuelrate:",fuelrate)
			local width = (scale-6)*fuelrate;
			getglobal("VehicleStateFuelCursor"):SetPoint("bottom","VehicleStateFuelScale","bottomleft",width+3,-11)
		end
	end
end

function OnBasketBallChargeChange(charge,adjust_region_min,adjust_region_max)
	local width = 168;
	local height = 14;
	if ClientMgr:isMobile() then
		width = 257;
		height = 17;
	end

	local ratio = charge/100;

	charge = charge == 0 and 1 or charge;
	if charge > 0 and not getglobal("CharacterActionFrame"):IsShown() then
		getglobal("BallChargeFrame"):Show();
		local charge_width = ratio*width
		if adjust_region_min ~= -1 and adjust_region_max ~= -1 then
			local aim_minx_ration = adjust_region_min/100
			local aim_maxx_ration = adjust_region_max/100
			local aim_width = (aim_maxx_ration - aim_minx_ration)*width
			local pc_aim_width = (aim_maxx_ration - aim_minx_ration)*257
			if charge >= adjust_region_min and
			   charge <= adjust_region_max then
				getglobal("BallChargeFrameAimRegion"):SetPoint("left","BallChargeFrameBkg","left",aim_minx_ration*width,0);
				getglobal("BallChargeFrameAimRegion"):ChangeTexUVWidth(pc_aim_width);
				getglobal("BallChargeFrameAimRegion"):SetSize(charge_width - aim_minx_ration*width , height);
				getglobal("BallChargeFrameAimRegion"):Show();
			end
			if charge < adjust_region_min then
				getglobal("BallChargeFrameAimRegion"):Hide();
			end
			getglobal("BallChargeFrameAimRegionBg"):SetPoint("left","BallChargeFrameBkg","left",aim_minx_ration*width,0);
			getglobal("BallChargeFrameAimRegionBg"):ChangeTexUVWidth(pc_aim_width);
			getglobal("BallChargeFrameAimRegionBg"):SetSize(aim_width, height);
			getglobal("BallChargeFrameAimRegionBg"):Show();
		else
			getglobal("BallChargeFrameAimRegion"):Hide();
			getglobal("BallChargeFrameAimRegionBg"):Hide();
		end
		
		getglobal("BallChargeFrameCharge"):ChangeTexUVWidth(ratio*257);
		--getglobal("BallChargeFrameCharge"):ChangeTexUVWidth(charge_width);
		getglobal("BallChargeFrameCharge"):SetSize(charge_width, height);
	else
		getglobal("BallChargeFrame"):Hide();
	end

end


function ChangePlayerCallBack()
	if not CurMainPlayer then
		return
	end

	local skinId = CurMainPlayer:getSkinID()
	local skinDef = RoleSkinCsv:get(skinId)
	if skinDef and skinDef["ChangeType"] > 0 and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then--xyang自定义UI
		getglobal("AccRideChangeBtn"):Show()
		if CurMainPlayer:isShapeShift() then
			if ClientMgr:isMobile() and needShowRideAttackBtn(skinId)  then --64-红蜘蛛 坐骑飞行 加速按钮无效不显示
				getglobal("AccRideAttackBtn"):Show()
				getglobal("AccRideAttackLeftBtn"):Show()
			end
		else
			getglobal("AccRideAttackBtn"):Hide()
			getglobal("AccRideAttackLeftBtn"):Hide()
		end
	else
		getglobal("AccRideChangeBtn"):Hide()
	end
	if skinDef and skinDef.SummonID and skinDef.SummonID ~= "" and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then
		getglobal("AccSummonBtn"):Show()
		standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "GameOpenSummon", "view", {standby1 = skinId})
	else
		if AvatarSummonIndex > 0 then
			if CurWorld and CurWorld:isRemoteMode() then
				local params = {objid = CurMainPlayer:getObjId(),summonid = 0}
				SandboxLuaMsg.sendToHost(_G.SANDBOX_LUAMSG_NAME.BUZZ.AVATAR_SUMMON_TOHOST, params)
			else
				CurMainPlayer:avatarSummon(0)
			end
			AvatarSummonIndex = 0
		end
		getglobal("AccSummonBtn"):Hide()
	end
	if getglobal("AccRideChangeBtn"):IsShown() then--如果变形按钮显示，设置召唤按钮到变形按钮左边
		getglobal("AccSummonBtn"):SetPoint("right", "AccRideChangeBtn", "left", -3, 0)
	else
		if getglobal("AccRideCallBtn"):IsShown() then
			getglobal("AccSummonBtn"):SetPoint("right", "AccRideCallBtn", "left", -3, 0)
		else
			getglobal("AccSummonBtn"):SetPoint("center", "AccRideCallBtn", "center", 0, 0)
		end
	end

	--显示变色按钮
	ShowChangeColorBtn()

end

function UpdateAvatarCameraModel()
	local seatInfo = GetInst("ShopDataManager"):GetPlayerUsingSeatInfo()
	if not seatInfo then
		return
	end

	if seatInfo.skin and seatInfo.skin[10] then
		if CurMainPlayer and CurMainPlayer.GetCameraModel then
			CurMainPlayer:GetCameraModel():updateHandModelTexture(seatInfo.skin[10].skin.ModelID)
		end
	end


end
--function OpenVehicleActioner()
--	print("OpenVehicleActioner")
--	local param = {};
-- 	param.disableOperateUI = false;
-- 	param.isVehicle = true;
--	GetInst("UIManager"):Open("VehicleActioner",param)
--end

--------------------------------------------
------------CSNoticeFrame  begin------------
--------------------------------------------
function CSNoticeFrame_OnShow()
	HideAllFrame("CSNoticeFrame", false);

	if not getglobal("CSNoticeFrame"):IsReshow() and ClientCurGame.setOperateUI then
		ClientCurGame:setOperateUI(true);
	end
end

function CSNoticeFrame_OnHide()
	if not getglobal("CSNoticeFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
end

---------------通行证倒计时---------------
function managePassPortCountDown()

	if gPassPortEndTime < 0 then return end

	local nowTime = AccountManager:getSvrTime()
	if nowTime == gPassPortLastTime then return end
	gPassPortLastTime = nowTime
	local timelab = getglobal("PlayMainFramePassPortCountDownFrameTime")
	timelab:SetText(getCountDownTime(gPassPortEndTime))

	local countdown = getglobal("PlayMainFramePassPortCountDownFrame")
	if gPassPortEndTime <= nowTime then
		gPassPortEndTime = -2
		if ClientCurGame and ClientCurGame:isInGame() then
			getglobal("PassPortConfirmBuyFrame"):Show()
		end
		countdown:Hide()
	elseif not countdown:IsShown() then
		countdown:Show()
	end
end

function getCountDownTime(endTime)
	local nowTime = AccountManager:getSvrTime()
	local leftSecond = endTime - nowTime
	if leftSecond <= 0 then return GetS(23041, 0, "00:00:00") end
	
	local day, countdown = 0, ""
	if leftSecond > 86400 then
		day = math.floor(leftSecond / 86400)
		leftSecond = leftSecond%86400
	end

	countdown = countdown .. string.format("%02d:", math.floor(leftSecond/3600))
	leftSecond = leftSecond%3600

	countdown = countdown .. string.format("%02d:", math.floor(leftSecond/60))
	leftSecond = leftSecond%60

	countdown = countdown .. string.format("%02d", leftSecond)

	return GetS(23041, day, countdown)
end


function OnActorHorseMounted(isMounted)
	if ClientMgr:isMobile() then
		local itemid = CurMainPlayer:getCurToolID()
		local itemDef = ItemDefCsv:get(itemid);
		--小地图显示的时候 或使用点射式的枪时 不显示使用技能按钮 
		if isMounted and not getglobal("MapFrame"):IsShown() and
			(not itemDef or (itemDef ~= nil and itemDef.UseTarget ~= ITEM_USE_GUN)) then
			getglobal("AccRideAttackBtn"):Show()
			getglobal("AccRideAttackLeftBtn"):Show()
		else
			getglobal("AccRideAttackBtn"):Hide()
			getglobal("AccRideAttackLeftBtn"):Hide()
		end
	end
end

-- 显示开局介绍界面
function BattleIntroShow()
	if CurWorld and CurWorld:isGameMakerRunMode() then
		if not IsUIFrameShown("GameStartShow") then
			GetInst("UIManager"):Open("GameStartShow");
		end
	end
end

-- 显示队伍选择界面
function TeamSelectedShow(sec)
	if not CurWorld or not CurWorld:isGameMakerRunMode() then
		return;
	end
	if sec > 0 and not IsUIFrameShown("SelectTeam") then
		GetInst("UIManager"):Open("SelectTeam");
	end
	local teamCtrl = GetInst("UIManager"):GetCtrl("SelectTeam");
	if not teamCtrl then return end

	if sec > 0 then --刷新时间
		teamCtrl:TimeUpdate(sec)
	else --关闭界面
		teamCtrl:RandomBtnClick()
	end
end

-- 更新队伍选择界面
function TeamSelectedUpdate(sec)
	if not CurWorld or not CurWorld:isGameMakerRunMode() then
		return;
	end
	local teamCtrl = GetInst("UIManager"):GetCtrl("SelectTeam");
	if not teamCtrl or not IsUIFrameShown("SelectTeam") then return end

	if sec > 0 then --刷新时间
		teamCtrl:TimeUpdate(sec)
	else --关闭界面
		teamCtrl:RandomBtnClick()
	end
end

-- 关闭开局介绍队伍选择界面
function ClosePreStartGameFrame()
	if IsUIFrameShown("GameStartShow") then
		GetInst("UIManager"):Close("GameStartShow");
	end
	if IsUIFrameShown("SelectTeam") then
		GetInst("UIManager"):Close("SelectTeam");
	end
end

--被语音警告
function VoiceWarnningCallback(warnData)
	print("voice warnning", warnData);
	local isshow =false;
	if  MessageBox ~= nil and GetInst("TeamVocieManage"):isInTeamVocieRoom() then
		isshow = true
	elseif MessageBox ~= nil and ClientCurGame:isInGame() and GYouMeVoiceMgr:isInChannel(warnData.roomId or 0) ~= 0 then
		isshow = true
	end

	if isshow then
		MessageBox(4, GetS(10721))
	else
		print("警告: 玩家不在对应的语音房间中！")
	end
end

--被禁言语音功能后的回调
function VoiceMuteCallback(muteInfo)
	print("mute call back", muteInfo);
	--存储禁言数据
	ns_data.muteData[1] = 1;
	ns_data.muteData[2] = muteInfo.mute_time;
	if GetInst("TeamVocieManage"):isInTeamVocieRoom() then
		local delayTime = (ns_data.muteData[2] and {ns_data.muteData[2] - getServerNow()} or {0})[1];
			print("delay time: ", delayTime);
			if delayTime <= 0 then --禁言时效过期
				return;
			end
		 --关闭麦克风
		 --if ClientMgr:getGameData("micswitch")  == self.define.open then
            GYouMeVoiceMgr:setMicrophoneMute(true);
        --end
		
		if MessageBox ~= nil then
			MessageBox(4, GetS(10724, string.format("%02d:%02d:%02d", math.floor(delayTime / 3600), math.floor(delayTime % 3600 / 60), delayTime % 3600 % 60)))
		end		
	else
		if ClientCurGame:isInGame() then
			print("server time: ", getServerNow());
			local delayTime = (ns_data.muteData[2] and {ns_data.muteData[2] - getServerNow()} or {0})[1];
			print("delay time: ", delayTime);
			if delayTime <= 0 then --禁言时效过期
				return;
			end
			local isInRoom = (GYouMeVoiceMgr:isInChannel(muteInfo.roomId or 0) ~= 0);
			--强制退出语音房间
			--退出房间并重新设置相关按钮状态
			GYouMeVoiceMgr:quitRoom();
			if IsInHomeLandMap and IsInHomeLandMap() then
				getglobal("GVoiceJoinRoomBtn"):Hide();
			elseif not UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.INVITE) then--xyang自定义UI
				getglobal("GVoiceJoinRoomBtn"):Hide();
			else
				getglobal("GVoiceJoinRoomBtn"):Show(); --加入房间按钮显示
			end
			getglobal("MicSwitchBtn"):Hide(); --麦克风按钮隐藏
			getglobal("SpeakerSwitchBtn"):Hide(); --扬声器按钮隐藏
	
			--是同一个房间则显示提示消息
			if isInRoom and MessageBox ~= nil then
				MessageBox(4, GetS(10724, string.format("%02d:%02d:%02d", math.floor(delayTime / 3600), math.floor(delayTime % 3600 / 60), delayTime % 3600 % 60)))
			end						   
		else
			print("禁言: 玩家不在对应的语音房间中！")
		end
	end
	
end

--被禁言后点击语音按钮需要弹出弹窗提示，这里不使用原有的IsGameFunctionProhibited，重新写一个
function CheckVoiceMuteStatus()
	if get_game_env() >= 10 then --海外版不检测禁言
		return true
	end
	if ns_data.muteData then
		if ns_data.muteData[1] == nil then
			if GetMuteFlag == 0 then
				SetGetMuteFlag();
				WWW_GetMuteData(true, function(succ)
					SetGetMuteFlag();
					if succ then
						if GetInst("TeamVocieManage"):isInTeamVocieRoom() then
						
						else
							GVoiceJoinRoomBtn_OnClick();
						end
					end
				end);
			end
			return false;
		elseif ns_data.muteData[1] == -1 then
			return true;
		else
			local delayTime = (ns_data.muteData[2] and {ns_data.muteData[2] - getServerNow()} or {0})[1];
			if delayTime <= 0 then --禁言时效过期
				return true;
			end
			MessageBox(4, GetS(10724, string.format("%02d:%02d:%02d", math.floor(delayTime / 3600), math.floor(delayTime % 3600 / 60), delayTime % 3600 % 60)))
			return false;
		end
	end
	return false;
end

function VoiceAccountFreeze(callback, data)
	if IsRoomOwner() then
		threadpool:work(function ()
			AccountManager:sendToClientKickInfo(2);
			if not PlatformUtility:isPureServer() then
				SafeCallFunc(GetInst("ArchiveLobbyRecordManager").CacheAddRecord, GetInst("ArchiveLobbyRecordManager"))
			end
			threadpool:wait(0.5);
			callback(data);
		end)
	else
		callback(data);
	end
end

function SetGetMuteFlag()
	GetMuteFlag = (GetMuteFlag + 1) % 2;
end

--是否可显示坐骑宠物按钮
function HasAnyRideOrPet()
	local allpet = GetInst("HomeLandDataManager"):GetAllPetData()
	local hasAnyIdlePet = false;
	for _, v in ipairs(allpet) do
		local state = GetStateByServerId(v.pet_server_id, v)
		if state == 0 then
			hasAnyIdlePet = true;
			break;
		end
	end

	print("i have pet state: ", tostring(hasAnyIdlePet), #allpet)
	return AccountManager:getAccountData():getHorseNum() > 0 or hasAnyIdlePet;
end

--更新坐骑按钮显示(家园获取宠物信息会有延迟，导致首次进家园没获取到宠物信息，没有显示按钮)
function UpdateAccRideCallBtnShow()
	if not isEducationalVersion and CurWorld and CurWorld:getOWID() ~= NewbieWorldId2 and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then--xyang自定义UI
		getglobal("AccRideCallBtn"):Show();
	else
		getglobal("AccRideCallBtn"):Hide();
	end
	if CurWorld and CurWorld:getOWID() ~= NewbieWorldId and CurWorld:getOWID() ~= NewbieWorldId2 and ClientMgr:isMobile() then
		if CurMainPlayer:isFlying() then
			if getglobal("AccRideCallBtn"):IsShown() then
				getglobal("AccRideCallBtn"):Hide();
			end
			--变形按钮
			if getglobal("AccRideChangeBtn"):IsShown() then
				getglobal("AccRideChangeBtn"):Hide();
			end
			--召唤按钮
			if getglobal("AccSummonBtn"):IsShown() then
				getglobal("AccSummonBtn"):Hide();
			end
		else
			if not getglobal("AccRideCallBtn"):IsShown() and CurMainPlayer:getMountType()~=MOUNT_DRIVE and  not MapEditManager:GetIsStartEdit() and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then--xyang自定义UI
				if not isEducationalVersion then
					getglobal("AccRideCallBtn"):Show();
				end
			end
			--变形按钮
			local skinId = CurMainPlayer:getSkinID()
			local skinDef = RoleSkinCsv:get(skinId)
			if not getglobal("AccRideChangeBtn"):IsShown() and skinDef and skinDef["ChangeType"] > 0 and UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MOUNT) then--xyang自定义UI
				getglobal("AccRideChangeBtn"):Show();
			end
			if skinDef and skinDef.SummonID and skinDef.SummonID ~= "" then
				getglobal("AccSummonBtn"):Show()
				standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "GameOpenSummon", "view", {standby1 = skinId})
			else
				getglobal("AccSummonBtn"):Hide()
			end
		end
	end

	--变形按钮
	if getglobal("AccRideChangeBtn"):IsShown() then
		if getglobal("AccRideCallBtn"):IsShown() then
			getglobal("AccRideChangeBtn"):SetPoint("right", "AccRideCallBtn", "left", -3, 0)
		else
			getglobal("AccRideChangeBtn"):SetPoint("center", "AccRideCallBtn", "center", 0, 0)
		end
	end

	if getglobal("AccRideChangeBtn"):IsShown() then--如果变形按钮显示，设置召唤按钮到变形按钮左边
		getglobal("AccSummonBtn"):SetPoint("right", "AccRideChangeBtn", "left", -3, 0)
	else
		if getglobal("AccRideCallBtn"):IsShown() then
			getglobal("AccSummonBtn"):SetPoint("right", "AccRideCallBtn", "left", -3, 0)
		else
			getglobal("AccSummonBtn"):SetPoint("center", "AccRideCallBtn", "center", 0, 0)
		end
	end
end

-- 游戏内通用增加/消耗星星币接口：联机模式客机请求由主机回调
--[[
	op : 可拓展
	1：新版广告商人-消耗星星币刷新商品列表
	2：新版广告商人-消耗星星币购买商品

	result：1表示操作成功 0表示操作失败
]]
function AddExpResult(op, result)
	ShowLoadLoopFrame(false)
	if result and result == 1 then
		if op == 1 then
			-- 消耗星星币刷新商品列表
			GetInst("UIManager"):GetCtrl("ShopAdNpc"):RefreshGoodListLogicHandle()
		elseif op == 2 then
			-- 消耗星星币[Desc5]商品
			GetInst("UIManager"):GetCtrl("ShopAdNpc"):BuyGoodLogicHandle()
		end
	else
		ShowGameTipsWithoutFilter(GetS(555))
		if op == 1 then
			local info = GetInst("UIManager"):GetCtrl("ShopAdNpc").model:GetManualRefreshGoodInfo()
			standReportEvent(407, "ADVERTISERS_NEW_REFRESHTIME", "Refresh", "purchase_failed", {standby1 = info.Price, standby2 = info.PriceType})
		elseif op == 2 then
			-- 消耗星星币[Desc5]商品失败埋点上报
			local propDef = GetInst("UIManager"):GetCtrl("ShopAdNpc").model:GetCurSelectGoodInfo()
			local eventTb =  { standby1 = propDef.ItemId, standby2 = propDef.ItemNum, standby3 = propDef.PriceType }
			standReportEvent(407, "ADVERTISERS_NEW_ITEMDETAILS", "Buy", "purchase_failed", eventTb)
		end
	end
end

-- 通知服务器devgoods获取
function DoSSTaskDevGoodsGet(uin)
	SandboxLuaMsg.sendToHost("get_dev_goods", {uin = uin});
end

-- 通知服务器npcshopgoods获取
function DoSSTaskNpcShopGoodsGet(_uin,_itemid)
	SandboxLuaMsg.sendToHost("get_npcshop_goods", {uin = _uin, itemid = _itemid});
end

-- 进入联机游戏，加载完成，收到服务器角色数据之后
function OnMpClientEnterGame()
	uploadSkinInfo()
end

-- 检测skin是否可以使用
function CheckSkinCanUse(skinId)
	if skinId == 0 then
		return true
	end
	if skinId == 311 then
		skinId = 310
	end
	local skinTime = AccountManager:getAccountData():getSkinTime(skinId)
	local id_costDefs = AccountManager:get_skincostdef()[skinId]
	local bVipSkin = false
	if id_costDefs then 
		local key, costDef = next(id_costDefs)
		if costDef.VipType == 1 then
			bVipSkin = true
		end
	end
	local bVip = GetInst('MembersSysMgr'):IsMember()
	if bVipSkin then 
		skinTime = bVip and -1 or 0
	end
	return skinTime ~= 0
end

-- 上报皮肤信息
function uploadSkinInfo()
	print("call uploadSkinInfo")
	local accountData = AccountManager:getAccountData()
	local Account = accountData.Account
	local leveldb = accountData.leveldb
	local BillDataSvr = Account.BillDataSvr
    local RoleSkinNum = BillDataSvr.RoleSkinNum
    local RoleSkinInfo = BillDataSvr.RoleSkinInfo

    local tbSkin = {}
    local now = getServerTime()
    local skinCostDef = AccountManager:get_skincostdef()

    local isVipSkin = function(skinId)
    	local id_costDefs = skinCostDef[skinId]
    	if id_costDefs then 
			local key, costDef = next(id_costDefs)
			if costDef.VipType == 1 then
				return 1
			end
		end
		return 0
    end

    print("call uploadSkinInfo 1 now:", now)
	if RoleSkinInfo then --新号没皮肤 需做判空处理
		for key, tbInfo in pairs(RoleSkinInfo) do
			local ExpireTime = tbInfo.ExpireTime
			print("uploadSkinInfo skininfo1:", tbInfo)
			if ExpireTime < 0 or ExpireTime > now then
				table.insert(tbSkin, {id = tbInfo.SkinID, vip = isVipSkin(tbInfo.SkinID)})
			end
		end
	end

    local exRoleSkinInfo = leveldb.RoleSkinInfo -- leveldb里面的东西
    if exRoleSkinInfo then
        for key, tbInfo in pairs(exRoleSkinInfo) do
        	print("uploadSkinInfo skininfo2:", tbInfo)
            local ExpireTime = tbInfo.ExpireTime
            if ExpireTime < 0 or ExpireTime > now then
                table.insert(tbSkin, {id = tbInfo.SkinID, vip = isVipSkin(tbInfo.SkinID)})
            end 
        end
    end

    print("uploadSkinInfo:", tbSkin)
    local tbInfo = {skins = tbSkin, vip = GetInst('MembersSysMgr'):IsMember()}
    if CurMainPlayer then
		CurMainPlayer:UploadCheckInfo2Host(4, table2json(tbInfo))
    end
end

-- 游戏内通用交换接口：联机模式客机请求由主机回调
--[[
	type : 可拓展
	1：广告商人-消耗活动道具获得背包道具

	result：1表示操作成功 0表示操作失败
]]
function doExchangeItemResult(type, result)
	ShowLoadLoopFrame(false)
	-- 消耗道具[Desc5]商品
	if result == 1 then
		if type == 1 then
			GetInst("UIManager"):GetCtrl("ShopAdNpc"):ShowBuyGood()
		end
	else
		ShowGameTips(GetS(9286), 3)
	end
end

function OnBuyAdShopResult(tabId, goodId, result)
	ShowLoadLoopFrame(false)
	if result and result == 1 then
		GetInst("UIManager"):GetCtrl("ShopAdNpc"):ProcessBuyLogicSuccess(tabId, goodId)
	else
		ShowGameTipsWithoutFilter(GetS(555))
		-- 消耗星星币[Desc5]商品失败埋点上报
		local propDef = GetInst("UIManager"):GetCtrl("ShopAdNpc").model:GetCurSelectGoodInfo()
		local eventTb =  { standby1 = propDef.ItemId, standby2 = propDef.ItemNum, standby3 = propDef.PriceType }
		standReportEvent(407, "ADVERTISERS_NEW_ITEMDETAILS", "Buy", "purchase_failed", eventTb)
	end
end

-- local telContent = {
--	ret = retCode,
--	mapinfo = mapInfo
--}
-- 客户端发起实际的传送
function startMapTeleport(telContent)
	-- TODO 客户端发起实际的传送
	-- 注意此处传送最好做个延迟，否则房主立刻切换地图其他人可能收不到消息了
	print("call startMapTeleport", telContent)

	-- 普通联机模式下且当前玩家为房主 需延迟传送
	local playerUin = AccountManager:getUin();
	if AccountManager:getMultiPlayer() > 0 and ClientCurGame:isHost(playerUin) then
		ShowLoadLoopFrame2(true, "startMapTeleport", 3, GetS(111717));
		threadpool:delay(2, function()
			ShowLoadLoopFrame2(false, "startMapTeleport");
			GetInst("CloudPortalInterface"):StartTransfer(telContent);
		end)
	else --其他情况下直接传送
		GetInst("CloudPortalInterface"):StartTransfer(telContent);
	end
end

function PlayMainActivityRoomConcertBtn_OnClick()
	GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/MusicFestival", "miniui/miniworld/c_musicfestival"})
	GetInst("MiniUIManager"):OpenUI("xumengyuan_popups","miniui/miniworld/MusicFestival","xumengyuan_popupsAutoGen")
	standReportEvent("1001", "CONCERT_TOP", "Concertbutton", "click");

end

function PlayMainActivityRoomMoneyGodBtn_OnClick()
	GetInst("ActivityMoneyGodManager"):OpenQuickActView()

	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
		standReportEvent("1003", "WEALTH_CAME_TOP", "WealthButton", "click")
	else
		standReportEvent("1001", "WEALTH_CAME_TOP", "WealthButton", "click")
	end
end

function CheckXumengYuanPopUp()
	if not WorldMgr or not WorldMgr:isSurviveMode() then
		return
	end
	local dataMgr = GetInst("MiNiMusicFestivalDataMgr")
	
	if dataMgr:IsInXuMengYuanConcertTime() then
		if not getglobal("PlayerConcertBtn"):IsShown() then
			getglobal("PlayerConcertBtn"):Show()
			standReportEvent("1001", "CONCERT_TOP", "Concertbutton", "view");
			getglobal("PlayerConcertBtnUVAnimationTex"):Show()
			getglobal("PlayerConcertBtnUVAnimationTex"):SetUVAnimation(40, true)
		end
	else
		getglobal("PlayerConcertBtn"):Hide()
	end
end

function CheckMoneyGodBtnPopUp()
	if WorldMgr and (WorldMgr:getGameMode() == 0 or WorldMgr:getGameMode() == 3 or WorldMgr:getGameMode() == 5 or WorldMgr:getGameMode() == 6) then
		local dataMgr = GetInst("ActivityMoneyGodManager")
		
		if dataMgr and dataMgr:IsMoneyGodOpenTime() and CurWorld and CurWorld:getOWID() ~= NewbieWorldId and getglobal("MoneyGodBtn") then
			local mapId = dataMgr:getMapId()

			if not getglobal("MoneyGodBtn"):IsShown() and tostring(CurWorld:getOWID()) ~= tostring(mapId) then
				getglobal("MoneyGodBtn"):Show()
				getglobal("MoneyGodBtnUVAnimationTex"):Show()
				getglobal("MoneyGodBtnUVAnimationTex"):SetUVAnimation(60, true)
			end

			if tostring(CurWorld:getOWID()) == tostring(mapId) then
				getglobal("MoneyGodBtn"):Hide()
			end
		else
			getglobal("MoneyGodBtn"):Hide()
		end
	else
		getglobal("MoneyGodBtn"):Hide()
	end
end

--觉醒发布会弹窗按钮
function PlayMainActivityAwakenBtn_OnClick()
	GetInst("ActivityAwakenManager"):OpenAwarkenMapPublishView()

	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
		standReportEvent("1003", "AWAKEN_RELEASE_MOVIE", "ReleaseButton", "click")
	else
		standReportEvent("1001", "AWAKEN_RELEASE_MOVIE", "ReleaseButton", "click")
	end
end

function PlayMainActivityAwakenBtn_OnShow()
	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
		standReportEvent("1003", "AWAKEN_RELEASE_MOVIE", "ReleaseButton", "view")
	else
		standReportEvent("1001", "AWAKEN_RELEASE_MOVIE", "ReleaseButton", "view")
	end
end

local AwakenBtn
function PlayMainActivityAwakenBtn_OnLoad()
	AwakenBtn = getglobal("AwakenBtn")
end

function CheckAwakenBtnPopUp()
	if AwakenBtn and not tolua.isnull(AwakenBtn) then
		if GetInst("ActivityAwakenManager"):CheckAwakenBtnPopUp()  then
			if  not AwakenBtn:IsShown() then
				AwakenBtn:Show()
			end
		else
			AwakenBtn:Hide()
		end
	end
end

local tick = 0
--定时检测位置移动信息
function stopActorInviteAct()
	tick = tick + 1
	if tick < 9 or not CurMainPlayer or not CurMainPlayer.getLocoMotion or not CurMainPlayer.getBody then
		return;
	end
 	tick = 0
	local loc = CurMainPlayer:getLocoMotion();
	local body = CurMainPlayer:getBody();
	local x,y,z = loc.m_Position.x, loc.m_Position.y, loc.m_Position.z;
	local lastPos = {x = 0, y = 0, z = 0};
	lastPos.x = loc.m_TickPosition.m_LastTickPos.x;
	lastPos.y = loc.m_TickPosition.m_LastTickPos.y;
	lastPos.z = loc.m_TickPosition.m_LastTickPos.z;
	--联机模式下 位置移动 且正在播放互动动作
	if AccountManager and AccountManager:getMultiPlayer() > 0 and
		(x ~= lastPos.x or y ~= lastPos.y or z ~= lastPos.z) and body.clearAction 
			and body.isPlayingSkinAct and body:isPlayingSkinAct() then
		body:clearAction();
	end
end


function PlayMainRoomMatchBtn_OnClick()
	standReportEvent("1003", "QUICK_REPLACE_ROOM", "ReplaceIcon", "click");
	GetInst("MatchPartyInterface"):OpenReMatchUI()
end


--显示收到的好友请求
function Show_PlayMainAskAddFriend()
	if ClientCurGame and ClientCurGame:isInGame() and (not friendservice.showAskAddFriend) and friendservice.popMsg[1] then
		-- ShowGameTips("GetGameSetData_IgnoreFriendAdd()=" .. GetGameSetData_IgnoreFriendAdd())
		if GetGameSetData_IgnoreFriendAdd() == 2 or CurWorld:isGameMakerMode() then -- 关闭好友申请开关
			RemoveAskAddFriendPop()
			return
		end
		if getkv("noShowAddFriendFrameDate") == nil or CanShowAskAddFriendFrame() then
			friendservice.showAskAddFriend = true
			if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
				standReportEvent("1003", "ADD_FRIENDS", "-", "view")
			else
				standReportEvent("1001", "ADD_FRIENDS", "-", "view")
			end
			
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/userInfoInteract","miniui/miniworld/common","miniui/miniworld/common_comp"})
			local data = friendservice.popMsg[1]
			data.disableOperateUI = true
			GetInst("MiniUIManager"):OpenUI("main_addfriend","miniui/miniworld/userInfoInteract","main_addfriendAutoGen",data)
		end
	end
end

--多重换装-获取变色皮肤ID
function GetChangeColorSkinID()
	local changeColorSkinID = {}
	if CurMainPlayer then
		local baseSkinId = CurMainPlayer:getSkinID()--进入地图内当前显示的皮肤ID
		local skinDef = RoleSkinCsv:get(baseSkinId)
		--需要是变色皮肤，并且需要解锁
		if skinDef and skinDef.ChangeSkinID and skinDef.ChangeSkinID ~= "" then--有变色的皮肤ID
			local changeSkinTab = split(skinDef.ChangeSkinID,',')
			for _, value in ipairs(changeSkinTab) do
				local splitData = split(value,'_')
				if next(splitData) and splitData[2] then
					table.insert(changeColorSkinID, tonumber(splitData[2]) or 0)
				end
			end	 
		end
	end
	return changeColorSkinID
end

function CanShowChangeColorBtn(skinid)
	if skinid == 323 or skinid == 324 then
		return false
	end
	return true
end

--多重换装-显示变色按钮
--根据ChangeSkinID字段判断是否是变色皮肤
function ShowChangeColorBtn()
	if ClientCurGame:isInGame() then

		local ishad = false --是否拥有
		local changeColorSkinID = GetChangeColorSkinID()
		for _, value in ipairs(changeColorSkinID) do
			local skinTime = AccountManager:getAccountData():getSkinTime(value)--变色皮肤
			if skinTime == -1 then--变色皮肤已解锁
				ishad = true
				break
			end
		end

		local IllusionEffect = ""
		if CurMainPlayer then
			local baseSkinId = CurMainPlayer:getSkinID()--进入地图内当前显示的皮肤ID
			local skinDef = RoleSkinCsv:get(baseSkinId)
			if skinDef then
				IllusionEffect = skinDef.IllusionEffect  --幻化皮肤
			end
			if ishad then
				ishad = CanShowChangeColorBtn(baseSkinId)
			end
		end

		if ishad and IllusionEffect == ""  then  
			getglobal("AccChangeColorBtn"):Show()
			if getglobal("AccRideChangeBtn"):IsShown() then--如果变形按钮显示，设置变色按钮到变形按钮左边
				getglobal("AccChangeColorBtn"):SetPoint("right", "AccRideChangeBtn", "left", -3, 0)
			else
				if getglobal("AccRideCallBtn"):IsShown() then
					getglobal("AccChangeColorBtn"):SetPoint("right", "AccRideCallBtn", "left", -3, 0)
				else
					getglobal("AccChangeColorBtn"):SetPoint("center", "AccRideCallBtn", "center", 0, 0)
				end
			end
		
			local showEffect = true
			local noshowDate = getkv("first_change_color_skin_day")
			if noshowDate then
				local secondOfToday = os.time({day=noshowDate.day, month=noshowDate.month,year=noshowDate.year, hour=23, min=59, sec=59})--当天24点
				if AccountManager:getSvrTime() < secondOfToday then
					showEffect = false
				else
					showEffect = true
				end
			end
			if showEffect then
				getglobal("AccChangeColorBtnEffect"):SetUVAnimation(100, true)
				setkv("first_change_color_skin_day", os.date('*t',getServerTime()))
			else
				getglobal("AccChangeColorBtnEffect"):Hide()
			end
			if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
				standReportEvent("1003", "MINI_GAMEROOM_GAME_1", "GameOpenSkinChange", "view")
			else
				standReportEvent("1001", "MINI_GAMEROOM_GAME_1", "GameRoomSkinChange", "view")
			end	
		else
			getglobal("AccChangeColorBtn"):Hide()	
		end
	end
end

--多重换装-点击变色按钮
function AccChangeColorBtn_OnClick()
	if CurMainPlayer and ClientCurGame:isInGame() then
		local skinId = CurMainPlayer:getSkinID()--当前的皮肤
		local skinDef = RoleSkinCsv:get(skinId)
		if skinDef then		
			local changeColorSkinID = 0
			--先判断变色皮肤是否已拥有
			changeColorSkinID = skinDef.ChangeOrder or 0 --变色的皮肤ID
			if changeColorSkinID > 0 then
				local skinTime = AccountManager:getAccountData():getSkinTime(changeColorSkinID)
				if skinTime ~= -1 then--没有解锁再查找关联的所有变色皮肤
					local allChangeColorSkin = GetChangeColorSkinID() 
					for _, value in ipairs(allChangeColorSkin) do
						local skinTime = AccountManager:getAccountData():getSkinTime(value)--变色皮肤
						if skinTime == -1 then--变色皮肤已解锁
							changeColorSkinID = value
							break
						end
					end
				end
				
				RoleSkin_Helper:Chg2SkinModel(changeColorSkinID)
				--重置快捷动作显示
				UpdataActionShow()	
				if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
					standReportEvent("1003", "MINI_GAMEROOM_GAME_1", "GameOpenSkinChange", "click")
				else
					standReportEvent("1001", "MINI_GAMEROOM_GAME_1", "GameRoomSkinChange", "click")
				end			
				if getglobal("AccChangeColorBtnEffect"):IsShown() then
					getglobal("AccChangeColorBtnEffect"):Hide()
				end
			end
		end
	end
end

function PlayMainHP_OnHide()
	getglobal("PlayerArmorBar"):Hide();
end

function PlayMainHP_OnShow()
	if LuaInterface and LuaInterface:shouldUseNewHpRule() then
		getglobal("PlayerArmorBar"):Show();
	else
		getglobal("PlayerArmorBar"):Hide();
	end
end

function PlayMainStrength_OnHide()
	getglobal("PlayerPerseveranceBar"):Hide();
end

function PlayMainStrength_OnShow()
	if LuaInterface and LuaInterface:shouldUseNewHpRule() then
		getglobal("PlayerPerseveranceBar"):Show();
	else
		getglobal("PlayerPerseveranceBar"):Hide();
	end
end

-----全民创造节引流-----
local activityVisualCfgMgrConfigBtnLink = nil
function ShowToActivityFrame()
	getglobal("ToActivityFrame"):Hide()
	local showTime = getkv("__EntryToActivityShow__")
	local isCanShow = (not showTime) or (getServerTime() > showTime)
	if isCanShow then
		local worldDesc = AccountManager:getCurWorldDesc();
		if worldDesc then
			--冒险模式：不展示
			--创造模式：进入创造模式时展示，冒险切换至创造模式时展示（切换回则不展示）
			--开发者模式：进入开发者编辑模式时展示，玩法模式切换至编辑模式时展示（切换回则不展示） （Worldtype =1 4）
			if worldDesc.worldtype==1 or worldDesc.worldtype==4 then
				GetEntryToActivityConfig()
			else
				getglobal("ToActivityFrame"):Hide()
			end
		end
	end
end
function GetEntryToActivityConfig()
	local callfun = function(config)
		if not config then
			return
		end
		if not (ClientCurGame and ClientCurGame:isInGame()) then
			return
		end

		if config.EntryToActivity then
			local isInTime = CheckActivityTime(config.EntryToActivity.rangeTime)
			local isInSetVer = CheckActivityVersion(config.EntryToActivity.minVersion, config.EntryToActivity.maxVersion)
			
			local toActivityFrame = getglobal("ToActivityFrame")
			if isInTime and isInSetVer then
				standReportEvent("1012", "MINI_INMAP_POP", "-", "view", {cid=tostring(G_GetFromMapid())})
				toActivityFrame:Show()
				local content = config.EntryToActivity.content or ""
				content = "#ccccccc"..content.."#n"
				local decTex = getglobal("ToActivityFrameDec")
				decTex:SetText(content)
				local btnTitle = config.EntryToActivity.btnTitle or ""
				getglobal("ToActivityFrameJumpBtnTitle"):SetText(btnTitle)
				local btnLink = config.EntryToActivity.btnLink or ""
				activityVisualCfgMgrConfigBtnLink = btnLink

				--重设宽高
				local h = decTex:GetTotalHeight()
				decTex:SetHeight(h)
				local frameH = toActivityFrame:GetHeight()
				if h > frameH + 10 then
					toActivityFrame:SetHeight(h+10)
				end
			else
				toActivityFrame:Hide()
			end
		end
	end
	local key = "EntryToActivity"
	local tb = GetInst("VisualCfgMgr"):GetCfg(key) or {}
	if not tb[key] then
		GetInst("VisualCfgMgr"):ReqCfg(key, function (code, ret)
			if code == 0 then
				tb = GetInst("VisualCfgMgr"):GetCfg(key) or {}

				if tb[key] and callfun then
					callfun(tb[key])
				end
			end
		end)
	else
		callfun(tb[key])
	end
end

function JumpToActivityBtn_OnClick()
	if activityVisualCfgMgrConfigBtnLink then
		local num = tonumber(activityVisualCfgMgrConfigBtnLink)
		if num and g_jump_ui_switch[num] then
			local param = {}
			if num == 76 then	--全民创造节
				param.comeFrom = 2
			end
			g_jump_ui_switch[num](param)
		else
			open_http_link(activityVisualCfgMgrConfigBtnLink)
		end
		standReportEvent("1012", "MINI_INMAP_POP", "Button", "click", {cid=tostring(G_GetFromMapid())})
	end
end
function ToActivityClose_OnClick()
	getglobal("ToActivityFrame"):Hide()

	local nowNum = getServerTime()
	local t = os.date("*t", nowNum + 86400)
	local nextShow = os.time({year=t.year,month=t.month,day=t.day,hour=0,min=0,sec=0})
	setkv("__EntryToActivityShow__", nextShow)

	standReportEvent("1012", "MINI_INMAP_POP", "Close", "click", {cid=tostring(G_GetFromMapid())})
end

function CheckActivityTime(configRangeTime)
	--判断时间
	if not configRangeTime or type(configRangeTime)~="table" or #configRangeTime~=2 then
		return
	end
	local startTime = tonumber(configRangeTime[1]/1000)
	local endTime = tonumber(configRangeTime[2]/1000)
	if startTime and endTime then
		local now =  getServerTime()
		---配置的数据时间戳是毫秒
		local isInTime = now >= startTime and now <= endTime
		return isInTime
	end
	return nil
end

function CheckActivityVersion(_minVersion, _maxVersion)
	--检测版本
	local curVersion = ClientMgr:clientVersion();
	local _min = _minVersion
	local _max = _maxVersion
	local minVer = (_min and _min~="" and ClientMgr:clientVersionFromStr(_min)) or nil
	local maxVer = (_max and _max~="" and ClientMgr:clientVersionFromStr(_max)) or nil

	minVer = tonumber(minVer)
	maxVer = tonumber(maxVer)
	
	local isInSetVer = false
	if minVer and maxVer then
		isInSetVer = curVersion>=minVer and curVersion<=maxVer
	elseif minVer and (not maxVer) then
		isInSetVer = curVersion>=minVer
	elseif (not minVer) and maxVer then
		isInSetVer = curVersion<=maxVer
	elseif (not minVer) and (not maxVer) then
		isInSetVer = true
	end
	return isInSetVer
end
--------------------------------------------------------------------------------
function ShowEnterMapAnim()
	threadpool:work(function ()
		while true do
			if not getglobal("PlayMainFrame"):IsShown() or not CurMainPlayer or getglobal("LoadingFrame"):IsShown() or not CurMainPlayer:getBody():checkEntityRes() then
				threadpool:wait(0.01)
			else
				CurMainPlayer:playAnim(SEQ_ENTERWORLD)
				return
			end
		end
	end)
end

-- 专门用于隐藏老UI Tips的鼠标离开事件
function OldUITipsHackItem_MouseLeave()
	--编辑模式
	if UGCModeMgr and UGCModeMgr:IsEditing() then
		-- 隐藏用于处理MouseLeave事件的老UI面板
		-- 尝试关闭Tips
		if getglobal("MItemTipsFrame"):GetClientID() > 0 then return end	--按下了alt
		CurSelectGridIndex = -1
		HideMTipsInfo();
		--新资源tips弹框
		GetInst('SceneEditorMsgHandler'):dispatcher(SceneEditorResourceDef.event.resource_item_tips_close)
	end
end

-----------------皮肤召唤---------------------
function AccSummonBtn_OnClick()
	if CurMainPlayer then
		if CurMainPlayer:isSleeping() or CurMainPlayer:isRestInBed() then
			CurMainPlayer:dismountActor();
			if CurMainPlayer:isShapeShift() then
				getglobal("AccRideAttackBtn"):Hide()
				getglobal("AccRideAttackLeftBtn"):Hide()
			end
		end

		local skinId = CurMainPlayer:getSkinID()
		local skinDef = RoleSkinCsv:get(skinId)
		standReportEvent("1003", "MINI_GAMEOPEN_GAME_1", "GameOpenSummon", "click", {standby1 = skinId})
		if skinDef and skinDef.SummonID and skinDef.SummonID ~= "" then
			local summonList = split(skinDef.SummonID, ",")
			AvatarSummonIndex = AvatarSummonIndex + 1
			AvatarSummonIndex = AvatarSummonIndex > #summonList and 0 or AvatarSummonIndex
			if AvatarSummonIndex > 0 then
				--展示召唤装扮
				local summonID = summonList[AvatarSummonIndex]
				local def = SummonDefCsv:get(summonID);
				if def then
					local summonTip = def.SummonTip
					local summonAct = def.SummonAction
					local summoneffect = def.SummonEffect
					local summonSound = def.SummonSound
					CurMainPlayer:getBody():setAnimSwitchIsCall(true)
					CurMainPlayer:playBodyEffect(summoneffect)
					CurMainPlayer:playAnim(SEQ_AVATAT_SUMMON)
				end
			else
				--隐藏召唤装扮
				ShowGameTips(GetS(30515))
				if CurWorld and CurWorld:isRemoteMode() then
					local params = {objid = CurMainPlayer:getObjId(),summonid = 0}
					SandboxLuaMsg.sendToHost(_G.SANDBOX_LUAMSG_NAME.BUZZ.AVATAR_SUMMON_TOHOST, params)
				else
					CurMainPlayer:avatarSummon(0)
				end
			end
		end
	end
end

function AvatarSummonEvent()
	local skinId = CurMainPlayer:getSkinID()
	local skinDef = RoleSkinCsv:get(skinId)
	if skinDef and skinDef.SummonID and skinDef.SummonID ~= "" then
		local summonList = split(skinDef.SummonID, ",")
		if AvatarSummonIndex > 0 then
			CurMainPlayer:getBody():setAnimSwitchIsCall(false)
			local summonID = summonList[AvatarSummonIndex]
			local def = SummonDefCsv:get(summonID);
			if def then
				local summonTip = def.SummonTip
				local summoneffect = def.SummonEffect
				local summonSound = def.SummonSound
				CurMainPlayer:playSound("summon."..summonSound, 1.0, 1.0)
				CurMainPlayer:stopBodyEffect(summoneffect)
				if CurWorld and CurWorld:isRemoteMode() then
					local params = {objid = CurMainPlayer:getObjId(),summonid = summonID}
					SandboxLuaMsg.sendToHost(_G.SANDBOX_LUAMSG_NAME.BUZZ.AVATAR_SUMMON_TOHOST, params)
				else
					CurMainPlayer:avatarSummon(summonID)
				end
				ShowGameTips(summonTip)
			end
		end
	end
end
---------------------------------------------
-----------------------------------------------------
local PtrRotation = {
	[1] = { angle = -90; };
	[2] = { angle = 0; };
	[3] = { angle = 90; };
	[4] = { angle = 150; };
}

local function isShowWaterPressureGuage()
	if MainPlayerAttrib == nil then return false end

	local itemid = MainPlayerAttrib:getEquipItem(EQUIP_SLOT_TYPE.EQUIP_HEAD)

	-- 潜水面罩，和高级潜水面罩显示水压仪表
	if itemid == 11642 or itemid == 11645 then
		return true
	end

	return false;
end

function CheckShowWaterPressureGuage()
	local showWaterPressureGauges = isShowWaterPressureGuage()
	if showWaterPressureGauges then
		getglobal("WaterPressureGauges"):Show()
	else
		getglobal("WaterPressureGauges"):Hide()
	end
end

function WaterPressureGauges_onTick()
	if MainPlayerAttrib == nil then return end
	
	local waterpressure = MainPlayerAttrib:getWaterPressure()
	if waterpressure > 4 then waterpressure = 4 end
	if waterpressure < 1 then waterpressure = 1 end

	local config = PtrRotation[waterpressure]
	local waterpressureptr = getglobal("WaterPressPtr")
	waterpressureptr:SetAngle(config.angle)
end


function AutoRoleEquip(worldid, uin)
	local cloud = "NotCloud"
	if ClientMgr and ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then
		cloud = "Cloud"
	end
	local ret = getkv("FristEnterWorldAutoRoleEquip"..worldid..uin..cloud) or false	
	if ret then
		return
	end		
	local success = false
	for i = 1, MAX_SHORTCUT do
		local grid_index = i + ClientBackpack:getShortcutStartIndex() - 1
		local itemid = ClientBackpack:getGridItem(grid_index)
		
		--装备类型(8->头, 9->胸甲, 10->腿, 11->鞋子, 16->背部)，对应格子(8000->头, 8001->胸甲, 8002->腿, 8003->鞋子, 16->背部)
		if itemid > 0 then
			local itemDef = ToolDefCsv:get(itemid)
			if itemDef then
				local itemType = itemDef.Type
				if itemType == 16 then
					itemType = 12
				end
				local index = -1
				if itemType >= 8 and itemType <= 12 then
					if itemType == 8 then
						index = 0
					elseif itemType == 9 then
						index = 1
					elseif itemType == 10 then
						index = 2
					elseif itemType == 11 then
						index = 3
					end
					if index >= 0 then
						CurMainPlayer:moveItem(grid_index, 7000, 1)
						CurMainPlayer:moveItem(7000, 8000+index, 1)
						success = true
					end							
				end			
			end	
		end			
	end

	if success then
		setkv("FristEnterWorldAutoRoleEquip"..worldid..uin..cloud, true)
	end	
end


function OpenTreasureChestUseReport(id)
	local param = {}
	local ret, standby1, standby2, standby3 = userTaskReportGetWorldParam2(nil, param)
	local tb = {}
	tb.standby1 = standby1
	tb.standby2 = standby2
	tb.standby3 = standby3
	tb.game_session_id = get_game_session_id()
	tb.cid = param.tureWorldId
	tb.ctype = param.ctype
	tb.extra_id = id
	tb.extra_type = "item"

	standReportEvent("1003", "TREASURE_CHEST", "Open", "success", tb)
end

function DisabledExecute()
	if CurMainPlayer and CurMainPlayer:getLivingAttrib()then
		return CurMainPlayer:getLivingAttrib():hasBuff(1021)
	end

	return false
end