
Revive_Need_Star = 1;
StarConvertByRevive = false;
local deathClick = 5--1,重新游戏，2星星复活，3看广告，4退出游戏，5无任何操作
local deathId = 0
local deathStateTime = 60 -- 死亡状态倒计时长

--统一添加兼容判断 非空或者不在游戏中不需要处理这个界面的逻辑
local function isInValid()
	return ClientMgr == nil 
			or CurWorld == nil 
			or ClientCurGame == nil 
			or not ClientCurGame:isInGame()
	--return tolua.isnull(obj)
end

--通用界面重置只能调用全局方法和本文件的本地方法
local function ViewHideReset()
	--隐藏页面时初始化死亡原因的字符串，不然会显示上一次遗留的字符串
	local text = ""
	text = ReplaceFilterString(GetS(464))
	if CurWorld:isExtremityMode() then
		getglobal("ExtremityDeathFrameCause"):SetText(text);
	else
		getglobal("DeathFrameCause"):SetText(text);
	end
end


function UpdateDeath(id, otherName)
	if isInValid() then
		return
	end

	deathId = id
	local text = "";
	if id > 0 then
		text = GetS(id);	
		text = string.gsub(text, "@self", ReplaceFilterString(AccountManager:getNickName()));
		if otherName ~= nil and otherName ~= "" then
			text = string.gsub(text, "@other", "#c22FFDD"..otherName.."#n");
		else
			text = string.gsub(text, "@other", GetS(465));
		end
	elseif id == 0 then
		text = GetS(464);
		deathId = 464
	end
	text = ReplaceFilterString(text)
	if CurWorld:isExtremityMode() then
		-- getglobal("ExtremityDeathFrameCause"):SetText(text);
		if GetInst("ExtremityDeathFrameManager") then 
			GetInst("ExtremityDeathFrameManager"):InitUI({textCause = text})
		end
	else
		getglobal("DeathFrameCause"):SetText(text);
	end
end

local function DeathFrameConfirmRevive0()
	if not ClientCurGame.getMainPlayer or ClientCurGame:getMainPlayer():revive(0) then
		local deathFrame = getglobal("DeathFrame");
		deathFrame:Hide();
		--解决某些界面锁定了UI，重生时需要解开
		ClientCurGame:setOperateUI(false);
		ShowHomeMainUI()
		if not CurMainPlayer:isSightMode() then
			if IsUGCEditing() and UGCModeMgr:GetGameType() == UGCGAMETYPE_HIGH  then
				-- 高级编辑模式
			else
				CurMainPlayer:setSightMode(true);
			end
		end
	end
end

function DeathReviveBtn_OnClick()	
	if isInValid() then
		return
	end
	
	if hideOtherUI() then
		showOtherUI()
	end

	--新埋点
	local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()
	DeathFrame_StandReportEvent("RESURRECTION_POPUP", "RestartButton", "click", {cid = tostring(mapId), standby3 = reviveAdPositionId})
	standReportEvent("412", "GAME_DIE_CHOICE", "TryAgain", "click", G_GetGameStandReportDataA()) --hrl 2021.11.02

	deathClick = 1
	if not CurWorld:isGameMakerRunMode() then  --玩法模式不加二级提示框
		MessageBox(5, GetS(968) , function(btn)
			if btn == 'left' then
				DeathFrameConfirmRevive0()
			end
		end);
	else
		DeathFrameConfirmRevive0()
	end	
end

function DeathContinueRevice()
	if isInValid() then
		return
	end
	--新埋点
	local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()
	DeathFrame_StandReportEvent("RESURRECTION_POPUP", "StarResurrectionButton", "click", {cid = tostring(mapId), standby3 = reviveAdPositionId})
	standReportEvent("412", "GAME_DIE_CHOICE", "Continue", "click", G_GetGameStandReportDataA()) --hrl 2021.11.02

	deathClick = 2
	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
		if starNum < Revive_Need_Star then
			local needNum = Revive_Need_Star - starNum;
			local lackNum = math.ceil(needNum/MiniCoin_Star_Ratio)
			local text = GetS(466, needNum, lackNum);
			StoreMsgBox(5, text, GetS(469), -2, lackNum, Revive_Need_Star);
			getglobal("StoreMsgboxFrame"):SetClientString( "复活星星不足" );
			
			SetStatisticRechargeSrc(5003,"复活");
		else
			if ClientCurGame:getMainPlayer():revive(1) then
				local deathFrame = getglobal("DeathFrame");
				deathFrame:Hide();
				--ClientCurGame:setOperateUI(false);
			end
	end
	
	if hideOtherUI() then
		showOtherUI()
	end

end

--星星代替迷你币
function DeathMiniCoinConvertStar()
	if isInValid() then
		return
	end
	
	StarConvertByRevive = false;

	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	if starNum < Revive_Need_Star then
		local needNum = math.ceil((Revive_Need_Star-starNum)/MiniCoin_Star_Ratio);
		local hasNum = AccountManager:getAccountData():getMiniCoin();
		if needNum <= hasNum then
			if AccountManager:getAccountData():notifyServerConsumeMiniCoin(needNum) ~= 0 then
				--ShowGameTips(StringDefCsv:get(282), 3);
				return;
			end

			ClientCurGame:getMainPlayer():starConvert(needNum*MiniCoin_Star_Ratio);

			if AccountManager:getMultiPlayer() == 2 then
				StarConvertByRevive = true;
			else
				if ClientCurGame:getMainPlayer():revive(1) then
					local deathFrame = getglobal("DeathFrame");
					deathFrame:Hide();
				end
			end
		else
			local lackNum = needNum - hasNum;
			local cost, buyNum = GetPayRealCost(lackNum);
			local text = GetS(453, cost, buyNum);
     			StoreMsgBox(6, text, GetS(456), -1, lackNum, needNum, nil, NotEnoughMiniCoinCharge, cost);
		end
	else
		if ClientCurGame:getMainPlayer():revive(1) then
			local deathFrame = getglobal("DeathFrame");
			deathFrame:Hide();
			--ClientCurGame:setOperateUI(false);
		end
	end
end

--星星代替迷你币设置复活点
function RevivePointMiniCoinConvertStar()
	if isInValid() then
		return
    end
    
	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	if starNum < Revive_Need_Star then
		local needNum = math.ceil((Revive_Need_Star-starNum)/MiniCoin_Star_Ratio);
		local hasNum = AccountManager:getAccountData():getMiniCoin();
		if needNum <= hasNum then
			if AccountManager:getAccountData():notifyServerConsumeMiniCoin(needNum) ~= 0 then
				return;
			end

			ClientCurGame:getMainPlayer():starConvert(needNum*MiniCoin_Star_Ratio);
            ClientCurGame:getMainPlayer():ResetRevivePoint() 

            local  answerDef = {FuncType = ANSWER_CONTINUE}
            NpcInteractAnswerOnClick(answerDef)
		else
			local lackNum = needNum - hasNum;
			local cost, buyNum = GetPayRealCost(lackNum);
			local text = GetS(453, cost, buyNum);
			StoreMsgBox(6, text, GetS(456), -1, lackNum, needNum, nil, NotEnoughMiniCoinCharge, cost);
		end
	else
        ClientCurGame:getMainPlayer():ResetRevivePoint() 

        local  answerDef = {FuncType = ANSWER_CONTINUE}
        NpcInteractAnswerOnClick(answerDef)
	end
end

function DeathMainMenuBtn_OnClick()
	if isInValid() then
		return
	end
	
	local deathFrame = getglobal("DeathFrame");
	deathFrame:Hide();
	ClientMgr:gotoGame("MainMenuStage");
end

function DeathBackMainMenuBtn_OnClick()
	if isInValid() then
		return
	end
	
	local deathFrame = getglobal("DeathFrame");
	deathFrame:Hide();
	--MiniBase触发返回主菜单 返回到迷你基地           
	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_PreLeaveGame",  SandboxContext():SetData_Number("code", 0))
	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_LeaveGame",  SandboxContext():SetData_Number("code", 1))
	ClientMgr:gotoGame("MainMenuStage");
end

function DeathFrame_OnLoad()
	this:RegisterEvent("GE_MAINPLAYER_DIE")
	this:RegisterEvent("GE_PLAYERATTR_CHANGE")
	this:RegisterEvent("GE_CUSTOMGAME_STAGE")
	DeathFrame_AddGameEvent()
end

local DeathTime = 0;

function DeathFrame_AddGameEvent()
	local deathFrame = getglobal("DeathFrame");
	SubscribeGameEvent(nil,GameEventType.PlayerAttrChange,function(context)
		if isInValid() then
			return
		end
		local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
		local continueBtnStarNum = getglobal("DeathFrameContinueBtnStarNum");
		if starNum < Revive_Need_Star then
			continueBtnStarNum:SetTextColor(255, 0, 0);
		else
			continueBtnStarNum:SetTextColor(51, 55, 55);
		end

		if MainPlayerAttrib:getHP() > 0 then
			if deathFrame:IsShown() then
				deathFrame:Hide();
			end
			if getglobal("BattleDeathFrame"):IsShown() then
				getglobal("BattleDeathFrame"):Hide();
			end
			--ClientCurGame:setOperateUI(false);
		end
	end)
end

function DeathFrame_OnEvent()
	if isInValid() then
		return
	end
	local deathFrame = getglobal("DeathFrame");
	if arg1 == "GE_MAINPLAYER_DIE" then
		if ClientCurGame:isInGame() and (ClientCurGame:getGameStage() == 4 or (CurMainPlayer ~= nil and  CurMainPlayer:getGameResults() > 0)) then return end

		local s=0;
		local reviveMode=0;
		reviveMode, s = CurWorld:getReviveMode(s);
		if not CurWorld:isExtremityMode() and reviveMode == 0 then
			DeathTime = s;
			if not deathFrame:IsShown() then
				deathFrame:Show()
			end
			if (DeathTime <= 0) then
				DeathFrame_CanClick();
			else
				DeathFrame_StartTime();
			end
		end
	elseif arg1 == "GE_PLAYERATTR_CHANGE" then
		local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
		local continueBtnStarNum = getglobal("DeathFrameContinueBtnStarNum");
		if starNum < Revive_Need_Star then
			continueBtnStarNum:SetTextColor(255, 0, 0);
		else
			continueBtnStarNum:SetTextColor(51, 55, 55);
		end

		if MainPlayerAttrib:getHP() > 0 then
			if deathFrame:IsShown() then
				deathFrame:Hide();
			end
			if getglobal("BattleDeathFrame"):IsShown() then
				getglobal("BattleDeathFrame"):Hide();
			end
			--ClientCurGame:setOperateUI(false);
		end
	elseif arg1 == "GE_CUSTOMGAME_STAGE" then
		if getglobal("DeathFrame"):IsShown() then
			local s = DeathTime;
			getglobal("DeathFrameRBtnMessageTime"):SetText(s.."s");
			if DeathTime <= 0 then
				DeathFrame_CanClick();
			end
			DeathTime = DeathTime - 1;
		end
	end
end

t_DeathNeedHideFrame = {
					"MItemTipsFrame",
					"GameTipsFrame",
					"NickModifyFrame",
					"ChatInputFrame",
					"ChatContentFrame",
					"RoomUIFrame",
					"FriendUIFrame",
					"ActivityFrame",
					"GameRewardFrame",
					"SetMenuFrame",
					"GameSetFrame",
					"FeedBackFrame",
					"AchievementFinishTipsFrame",
					"CreateRoomFrame",
				}


function DeathFrame_StartTime()
	if isInValid() then
		return
	end
	
	getglobal("DeathFrameReviveBtn"):Disable(true);
	getglobal("DeathFrameContinueBtn"):Disable(true);
	getglobal("DeathFrameADContinueBtn"):Disable(true);
	getglobal("DeathFrameReviveBtnText"):SetPoint("center", "DeathFrameReviveBtn", "center", 0, -12);
	getglobal("DeathFrameRBtnMessageTime"):Show();
	getglobal("DeathFrameRBtnMessageTime"):SetText(DeathTime.."s");
end

function DeathFrame_CanClick()
	if isInValid() then
		return
	end
	
	getglobal("DeathFrameReviveBtn"):Enable(false);
	getglobal("DeathFrameContinueBtn"):Enable(false);
	getglobal("DeathFrameADContinueBtn"):Enable(false);
	getglobal("DeathFrameReviveBtnText"):SetPoint("center", "DeathFrameReviveBtn", "center", 0, 0);
	getglobal("DeathFrameRBtnMessageTime"):Hide();
end

function onFirstDayDie()
	
	--新注册玩家的时间
	local now = AccountManager:getSvrTime()
	local createTime = AccountManager.get_account_create_time and AccountManager:get_account_create_time() or 0
	local isSameDay = 0
	if IsSameDay( now, createTime ) then
		isSameDay = 1
	end
	local IsPc = 2
	if ClientMgr:isPC() then
		IsPc = 1
	end
	local gameType = AccountManager:getMultiPlayer() > 0 and "multi" or "single"
	local ownMap = "0";
	local worldDesc = AccountManager:getCurWorldDesc();
	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
		if worldDesc and worldDesc.realowneruin == AccountManager:getUin() then
			ownMap = "1";
		end
	end
	local worldtype = worldDesc and worldDesc.worldtype or 0

	local mapId = 0
	-- 房主或者单机模式
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
		if worldDesc then
			mapId = worldDesc.fromowid
			if worldDesc.fromowid == 0 then
				mapId = worldDesc.worldid
			end
		end
	-- 客机
	else
		mapId = DeveloperFromOwid
	end

	deathStateTime = 60
	threadpool:work(function()
		local frameDeath = getglobal("DeathFrame")
		while frameDeath:IsShown() and deathStateTime >= 0 do
			if deathStateTime == 0 then
				deathClick = 5
			end
			deathStateTime = deathStateTime - 1
			threadpool:wait(1)
		end
		-- statisticsGameEventNew(969,ClientMgr:getDeviceID(),ownMap,worldtype,gameType,mapId,tostring(get_game_lang()),isSameDay,deathId,IsPc,deathClick)
		deathId = 464
	end)
end

function DeathFrameChangeDeathClick(num)
	if deathClick then
		deathClick = num
	end
end

function DeathFrame_OnShow()
	if isInValid() then
		return
	end

	if IsInHomeLandMap and IsInHomeLandMap() then
		--家园直接重生
		DeathFrameConfirmRevive0()
		return 
	end
	
	--新埋点
	local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()

	DeathFrame_StandReportEvent("RESURRECTION_POPUP", "-", "view", {cid = tostring(mapId), standby3 = reviveAdPositionId})
	DeathFrame_StandReportEvent("RESURRECTION_POPUP", "RestartButton", "view", {cid = tostring(mapId), standby3 = reviveAdPositionId})
	DeathFrame_StandReportEvent("RESURRECTION_POPUP", "StarResurrectionButton", "view", {cid = tostring(mapId), standby3 = reviveAdPositionId})

	if reviveAdPositionId ~= 105 then
		ShowNativeAd(
			17,
			getglobal("DeathFrameNativeAd"):GetRealWidth(),
			getglobal("DeathFrameNativeAd"):GetRealHeight(),
			22,
			0
		)
	end

	HideAllFrame("DeathFrame", false);
	getglobal("GongNengFrame"):Hide();
	--Xyang 恢复显示音乐播放器
	if GetInst("QQMusicPlayerManager") then
		GetInst("QQMusicPlayerManager"):OpenUI();
	end
	
	for i=1, #(t_DeathNeedHideFrame) do
		local frame = getglobal(t_DeathNeedHideFrame[i]);
		if frame:IsShown() then
			frame:Hide();
		end
	end

	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	local continueBtnStarNum = getglobal("DeathFrameContinueBtnStarNum");
	if starNum < Revive_Need_Star then
		continueBtnStarNum:SetTextColor(255, 0, 0);
	else
		continueBtnStarNum:SetTextColor(51, 55, 55);
	end

	if not getglobal("DeathFrame"):IsReshow() then
		if ClientCurGame.setOperateUI ~= nil then
		   ClientCurGame:setOperateUI(true);
		end
		standReportEvent("412", "GAME_DIE_CHOICE", "-", "view", G_GetGameStandReportDataA()) --hrl 2021.11.02
		standReportEvent("412", "GAME_DIE_CHOICE", "TryAgain", "view", G_GetGameStandReportDataA()) --hrl 2021.11.02
		standReportEvent("412", "GAME_DIE_CHOICE", "Continue", "view", G_GetGameStandReportDataA()) --hrl 2021.11.02
	end
	ClientMgr:playSound2D("sounds/ui/info/death.ogg", 1);

	if IsAdUseNewLogic(reviveAdPositionId) then
		-- 是否显示复活广告按钮 codeby:fym
		HandleShowADBtnView(false)
		if not ClientMgr:isPC() then
			GetInst("AdService"):IsAdCanShow(reviveAdPositionId, function(result, ad_info)
				if result then
					HandleShowADBtnView(result)
				else
					-- codeby:fym 复活广告位曝光：多执行几次canshow判断，提高广告加载成功几率
					local ad_info = ad_info
					threadpool:work(function()
						for i = 1, 3 do
							if ad_data_new.canShow(reviveAdPositionId, ad_info) then
								HandleShowADBtnView(true) break
							end
							threadpool:wait(1)
						end
					end)
				end
			end)
		end
	else
		--LLDO:是否显示广告按钮
		threadpool:work(function()
			for i = 1, 3 do
				-- ns_version.revive.ad_reward_switch = 1 -- test
				-- if true then HandleShowADBtnView(true) break end -- test
				if ClientMgr:isPC() then
				 	HandleShowADBtnView(false) break
				elseif t_ad_data.canShow(reviveAdPositionId) then
					HandleShowADBtnView(true) break
				else
					HandleShowADBtnView(false)
				end
				threadpool:wait(1)
			end
		end)
	end
	onFirstDayDie()

	if isEducationalVersion then
		BattleDeathFrameOnShow_Edu();
	end
	---MiniBase 返回主菜单改成退出游戏
	if MiniBaseManager:isMiniBaseGame() then
		local deathMenuBtn = getglobal("DeathBackMainMenuBtnName")
		if deathMenuBtn then deathMenuBtn:SetText(GetS(3053)) end
	end

	GetInst("WeekendCarnivalMgr"):roleDie()
end

function DeathFrame_OnHide()
	if isInValid() then
		return
	end
	
	RemoveNativeAd(17)

	ViewHideReset()

	if not getglobal("DeathFrame"):IsRehide() then
	  	ClientCurGame:setOperateUI(false);
	end

	local worldDesc = AccountManager:getCurWorldDesc();

	if worldDesc and worldDesc.worldtype == 9 then
		--录像存档, 不要显示"GongNengFrame"
	else
        if IsInHomeLandMap and IsInHomeLandMap() then
			getglobal("GongNengFrame"):Hide();
		else
			getglobal("GongNengFrame"):Show();
		end

		-- UGC内容重新显示
		GetInst("UGCCommon"):AfterHideAllUI()
    end
	GetInst("WeekendCarnivalMgr"):roleRevival()
end

-- 获取复活所使用广告位id（认证过的开发者创建的开发者地图看广告复活弹出105广告位，其他情况仍用原官方2号广告位）
function GetReviveAdPositionId()
	if isInValid() then
		return
	end
	
    local reviveAdPositionId = 2

    local mapId, uin, authorUin = 0, AccountManager:getUin(), 0
    --if CurWorld and CurWorld:isGameMakerRunMode() then
        -- 单机或房主
        if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
            local wdesc = AccountManager:getCurWorldDesc()
            if wdesc then
                mapId = wdesc.fromowid
                if wdesc.fromowid == 0 then
                    mapId = wdesc.worldid
                end

                authorUin = getFromOwid(mapId)
                local isSelfDeveloper = false

                if authorUin == uin then
                    local ddiRet = AccountManager:dev_developer_info(uin);
                    isSelfDeveloper = (ddiRet == ErrorCode.OK)
                    if isSelfDeveloper then
                        reviveAdPositionId = 105
                    end
                elseif wdesc.passportflag ~= nil then
                    -- 有可能是老的开发者存档数据没有初始化，也有可能该作者不是开发者
                    -- 判断这个会缓存
                    local ret = AccountManager:dev_developer_info(authorUin)
                    if ret == ErrorCode.OK then
                        reviveAdPositionId = 105
                    end
                end
            end
        -- 客机``
        else
            mapId = DeveloperFromOwid
            local developerflag = CurWorld:getDeveloperFlag()
            -- 0表示初始值（有可能是老的存档，也有可能是没赋值到的），1表示是开发者地图，2表示不是开发者地图 3表示通行证过期
            if developerflag == 1 or developerflag == 0 then
                authorUin = getFromOwid(mapId)
                -- 判断这个会缓存
                local ret = AccountManager:dev_developer_info(authorUin)
                if ret == ErrorCode.OK then
                    reviveAdPositionId = 105
                end
            end
        end
    --end

    return reviveAdPositionId, authorUin, mapId
end

function ShowDeathFrameADContinueBtn(isShow)
	if isInValid() then
		return
	end

	local DeathFrameReviveBtn     = getglobal("DeathFrameReviveBtn")
	local DeathFrameContinueBtn   = getglobal("DeathFrameContinueBtn")
	local DeathFrameADContinueBtn = getglobal("DeathFrameADContinueBtn")

	if isShow then
		if not DeathFrameADContinueBtn:IsShown() then
			DeathFrameADContinueBtn:Show()
			DeathFrameReviveBtn:SetPoint("bottomright", "DeathFrame","bottom",-114,-140)
			DeathFrameContinueBtn:SetPoint("left", "DeathFrameReviveBtn","right",30,0)
        end
        
        local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()

		if IsAdUseNewLogic(reviveAdPositionId) then		
			-- 105广告位埋点增加作者uin和地图id
			if reviveAdPositionId == 105 then
				StatisticsADNew('show', reviveAdPositionId, nil, nil, authorUin, mapId);
			else
				StatisticsADNew('show', reviveAdPositionId);
			end
			if IsAdReportUseNewLogic(reviveAdPositionId) then
				GetInst("AdService"):Ad_Show(reviveAdPositionId)
			elseif AccountManager.ad_show then
				AccountManager:ad_show(reviveAdPositionId);				
			end
		else
			-- 105广告位埋点增加作者uin和地图id
			if reviveAdPositionId == 105 then
				StatisticsAD('show', reviveAdPositionId, nil, authorUin, mapId);
			else
				StatisticsAD('show', reviveAdPositionId);
			end
			if AccountManager.ad_show then
				AccountManager:ad_show(reviveAdPositionId);
			end
		end
		
		--新埋点
		DeathFrame_StandReportEvent("RESURRECTION_POPUP", "AdPlayResurrectionButton", "view", {cid = tostring(mapId), standby3 = reviveAdPositionId})

	else
		DeathFrameADContinueBtn:Hide()
		DeathFrameReviveBtn:SetPoint("bottomright", "DeathFrame","bottom",-60,-140)
		DeathFrameContinueBtn:SetPoint("left", "DeathFrameReviveBtn","right",125,0)
	end
end


function DeathChooseFrameADContinueBtn_OnClick()
	if isInValid() then
		return
	end
	deathClick = 3
	
    local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()

	if IsAdUseNewLogic(reviveAdPositionId) then	
		-- 105广告位埋点增加作者uin和地图id
		if reviveAdPositionId == 105 then
			StatisticsADNew('onclick', reviveAdPositionId, nil, nil, authorUin, mapId)
		else
			StatisticsADNew('onclick', reviveAdPositionId)
		end
	else
		-- 105广告位埋点增加作者uin和地图id
		if reviveAdPositionId == 105 then
			StatisticsAD('onclick', reviveAdPositionId, nil, authorUin, mapId)
		else
			StatisticsAD('onclick', reviveAdPositionId)
		end
	end

    local reviveAdPositionData =
    {
        position = reviveAdPositionId,
        authorUin = authorUin,
        mapId = mapId
    }
	if WatchADNetworkTips(OnReqWatchADRevive, reviveAdPositionData) then
		OnReqWatchADRevive(reviveAdPositionData);
	end
end
-----------------------------------ExtremityDeathFrame-------------------------------------
-- function ExtremityDeathFrame_OnLoad()
-- 	this:RegisterEvent("GE_MAINPLAYER_DIE");
-- end

-- function ExtremityDeathFrame_OnEvent()
-- 	if isInValid() then
-- 		return
-- 	end
	
-- 	if arg1 == "GE_MAINPLAYER_DIE" then
-- 		local s=0;
-- 		local reviveMode=0;
-- 		reviveMode, s = CurWorld:getReviveMode(s);
-- 		if CurWorld:isExtremityMode() and reviveMode == 0 then
-- 			getglobal("ExtremityDeathFrame"):Show();
-- 		end
-- 	end
-- end

-- function ExtremityDeathFrame_OnShow()
-- 	if isInValid() then
-- 		return
-- 	end
	
-- 	HideAllFrame("ExtremityDeathFrame", false);
-- 	getglobal("GongNengFrame"):Hide();

-- 	for i=1, #(t_DeathNeedHideFrame) do
-- 		local frame = getglobal(t_DeathNeedHideFrame[i]);
-- 		if frame:IsShown() then
-- 			frame:Hide();
-- 		end
-- 	end
	
-- 	local score = AccountManager:getAccountData():getOWScore(CurWorld:getOWID());
-- 	local highestScore = AccountManager:getAccountData():getOWHighestScore();
-- 	getglobal("ExtremityDeathFrameTheScore"):SetText(GetS(3176).."：".."#cffffff"..score.."#n", 235, 182, 68);
-- 	getglobal("ExtremityDeathFrameHighestScore"):SetText(GetS(3177).."：".."#cffffff"..highestScore.."#n", 235, 182, 68);

-- 	if score == highestScore then
-- 		getglobal("ExtremityDeathFrameDescTitle"):Show();
-- 	else
-- 		getglobal("ExtremityDeathFrameDescTitle"):Hide();
-- 	end

-- 	ClientMgr:playSound2D("sounds/ui/info/death.ogg", 1);

-- 	EnterMainMenuInfo.t_RestarExtremity = {};
-- 	if AccountManager:getMultiPlayer() == 0 then	--单机
-- 		local worldDesc = AccountManager:getCurWorldDesc();
-- 		if worldDesc ~= nil then
-- 			table.insert(EnterMainMenuInfo.t_RestarExtremity, {worldType=worldDesc.worldtype, name=worldDesc.worldname,
-- 							 terrType=worldDesc.createdata.terrtype, seed=worldDesc.createdata.seedstr,
-- 							 roleModel=AccountManager:getRoleModel()}
-- 					)
-- 		end
-- 		AccountManager:requestLockOWorld(CurWorld:getOWID());
-- 	else 						--联机
-- 	end
	
-- 	if not getglobal("ExtremityDeathFrame"):IsReshow() then
-- 		ClientCurGame:setOperateUI(true);
-- 	end
-- 	onFirstDayDie()
-- 	---MiniBase 返回主菜单改成退出游戏
-- 	if MiniBaseManager:isMiniBaseGame() then
-- 		getglobal("ExtremityDeathFrameBackMainMenuBtnName"):SetText(GetS(3053))
-- 	end
-- end

-- function ExtremityDeathFrame_OnHide()
-- 	if isInValid() then
-- 		return
-- 	end
	
-- 	ViewHideReset()

-- 	if not getglobal("GongNengFrame"):IsShown() then
-- 		if IsInHomeLandMap and IsInHomeLandMap() then
-- 			getglobal("GongNengFrame"):Hide();
-- 			ShowHomeMainUI()
-- 		else
-- 			getglobal("GongNengFrame"):Show();
-- 		end
-- 	end
	
-- 	if not getglobal("ExtremityDeathFrame"):IsRehide() then
-- 		ClientCurGame:setOperateUI(false);
-- 	end
-- end

-- function ExtremityDeathFrameBackMainMenuBtn_OnClick()
-- 	if isInValid() then
-- 		return
-- 	end
	
-- 	EnterMainMenuInfo.t_RestarExtremity = {};
-- 	getglobal("ExtremityDeathFrame"):Hide();
-- 	--MiniBase触发返回主菜单 返回到迷你基地           
-- 	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_PreLeaveGame",  SandboxContext():SetData_Number("code", 0))
-- 	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_LeaveGame",  SandboxContext():SetData_Number("code", 1))
-- 	ClientMgr:gotoGame("MainMenuStage");
-- end

-- function ExtremityDeathFrameRestartBtn_OnClick()
-- 	if isInValid() then
-- 		return
-- 	end
	
-- 	-- if AccountManager:getMyWorldList():getMyCreateWorldNum() >= GetCreateMapMax() then
-- 	if GetCreateArchiveNum() >= CreateArchiveMaxNum() then
-- 		--可以[Desc5]则先弹[Desc5]的窗口
-- 		if CanShowNotEnoughArchiveWithOperate(function () ExtremityDeathFrameRestartBtn_OnClick() end) then
-- 			return
-- 		end
-- 		MessageBox(4, GetS(10));
-- 		getglobal("MessageBoxFrame"):SetClientString( "创建地图上限" );
-- 		return;
-- 	end
-- 	getglobal("ExtremityDeathFrame"):Hide();
-- 	ClientMgr:gotoGame("MainMenuStage");
-- end

function HandleShowADBtnView(visible)
	local adConfig = ns_version.revive
	local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()
	if not adConfig and reviveAdPositionId ~= 105 then
		return
	end

	local hideNewADFrameFunc = function()
		getglobal("DeathFrameNewADFrame"):Hide()
		local light2 = getglobal("DeathFrameNewADFrameBoxBtnLight2")
		if light2 then
			light2:StopUVAnim()
		end
		local light3 = getglobal("DeathFrameNewADFrameGetRewardBtnLight3")
		if light3 then
			light3:StopUVAnim()
		end
	end

	local adFrame = getglobal("DeathFrameADFrame")
	if adFrame then
		local btnRevive = getglobal("DeathFrameReviveBtn")
		local btnContinue = getglobal("DeathFrameContinueBtn")
		local mTombstone = getglobal("DeathFrameTombstone")
		if visible and (check_apiid_ver_conditions(adConfig) or reviveAdPositionId == 105) then
			adFrame:Show()

			local light = getglobal("DeathFrameADFrameLight")
			if light then
				light:SetUVAnimation(100, true)
			end

			local num = math.random()
			local btn = getglobal("DeathFrameADFrameADContinueBtn")
			local item = getglobal("DeathFrameADFrameRewardItemBkg")
			local title = getglobal("DeathFrameADFrameRewardTitle")
			local icon = getglobal("DeathFrameADFrameRewardItemIcon")
			local text  = getglobal("DeathFrameADFrameRewardText")

			local liveDay = CurMainPlayer:getSurviveDay(CurWorld:getCurMapID())
			local index = 1
			local idx = 1
			while adConfig["reward" .. index] do
				local min = adConfig["reward" .. index].day_min or 0
				local max = adConfig["reward" .. index].day_max or math.huge
				if liveDay >= min and liveDay <= max then					
					while adConfig["reward" .. index]["item" .. idx] do
						idx = idx + 1
					end
					break
				end
				index = index + 1
			end
			--新埋点
			DeathFrame_StandReportEvent("RESURRECTION_POPUP", "AdPlayResurrectionButton", "view")
			if adConfig["reward" .. index] or reviveAdPositionId == 105 then

				if IsAdUseNewLogic(reviveAdPositionId) then
					-- 105广告位埋点增加作者uin和地图id
					if reviveAdPositionId == 105 then
						StatisticsADNew('show', reviveAdPositionId, nil, nil, authorUin, mapId);
					else
						StatisticsADNew('show', reviveAdPositionId);
					end	
					if IsAdReportUseNewLogic(reviveAdPositionId) then
						GetInst("AdService"):Ad_Show(reviveAdPositionId)
					elseif AccountManager.ad_show then
						AccountManager:ad_show(reviveAdPositionId);				
					end
				else
					-- 105广告位埋点增加作者uin和地图id
					if reviveAdPositionId == 105 then
						StatisticsAD('show', reviveAdPositionId, nil, authorUin, mapId);
					else
						StatisticsAD('show', reviveAdPositionId);
					end
					if AccountManager.ad_show then
						AccountManager:ad_show(reviveAdPositionId);
					end
				end

				local isShowItem = math.random()
				isShowItem = isShowItem < (adConfig.revive_probability or 0)

				if isShowItem and reviveAdPositionId ~= 105 then --开发者广告位不触发奖励
					item:Show();
					icon:Show();
					text:Show();
					title:SetPoint("topleft", "DeathFrameADFrameRewardItemBkg", "topright", 10, 8)
					btnRevive:SetPoint("bottomright", "DeathFrame", "bottom", -30, -61)
					mTombstone:SetPoint("top", "DeathFrameCause", "bottom", 0, 37)
					text:SetText(GetS(71033))

					local totalNum = 0
					local itemID = -1
					local itemNum = 0
					for i = 1, idx - 1 do
						if num > totalNum and num <= totalNum + (adConfig["reward" .. index]["item" .. i][3] or 0) then
							itemID = adConfig["reward" .. index]["item" .. i][1] or -1
							itemNum = adConfig["reward" .. index]["item" .. i][2] or 0
							break
						end
						totalNum = totalNum + (adConfig["reward" .. index]["item" .. i][3] or 0)
					end

					if itemID > 0 then
						local detailsIcon = getglobal("DeathFrameADFrameDetailsIcon")
						local detailsName = getglobal("DeathFrameADFrameDetailsName")
						local detailsType = getglobal("DeathFrameADFrameDetailsType")
						local detailsDesc = getglobal("DeathFrameADFrameDetailsDesc")
						local itemDef = ItemDefCsv:get(itemID)
						if itemDef then
							detailsName:SetText(itemDef.Name)
							detailsType:SetText(itemDef.TypeDesc)
							detailsDesc:SetText(itemDef.Desc)
						end
						SetItemIcon(detailsIcon, itemID)
						SetItemIcon(icon, itemID)
						adFrame:SetClientUserData(0, itemID)
						adFrame:SetClientUserData(1, itemNum)
						adFrame:SetClientUserData(2, reviveAdPositionId or 2)
					else
						SetItemIcon(icon, 0)
						adFrame:SetClientUserData(0, -1)
						adFrame:SetClientUserData(1, 0)
						adFrame:SetClientUserData(2, reviveAdPositionId or 2)
					end
				else
					item:Hide();
					icon:Hide();
					text:Show();
					adFrame:SetClientUserData(0, -1)
					adFrame:SetClientUserData(1, 0)
					adFrame:SetClientUserData(2, reviveAdPositionId)
					title:SetPoint("topleft", "DeathFrameADFrameRewardItemBkg", "topleft", 5, 8)
					text:SetText(GetS(71034))

					if reviveAdPositionId == 105 then
						text:Hide()
						title:SetPoint("left", "DeathFrameADFrameRewardItemBkg", "left", 5, 5)

						hideNewADFrameFunc()
					end
				end

				if adConfig and adConfig.ad_reward_switch and adConfig.ad_reward_switch == 1 and reviveAdPositionId ~= 105 then -- 广告位105开发者模式不显示
					adFrame:Hide()
					getglobal("DeathFrameNewADFrame"):Show()
					local light2 = getglobal("DeathFrameNewADFrameBoxBtnLight2")
					if light2 then
						light2:SetUVAnimation(100, true)
					end
					local light3 = getglobal("DeathFrameNewADFrameGetRewardBtnLight3")
					if light3 then
						light3:SetUVAnimation(100, true)
					end
				else
					hideNewADFrameFunc()
				end
			else
				adFrame:Hide()
				local light = getglobal("DeathFrameADFrameLight")
				if light then
					light:StopUVAnim()
				end
				btnRevive:SetPoint("bottomright", "DeathFrame", "bottom", -30, -133)
				mTombstone:SetPoint("top", "DeathFrameCause", "bottom", 0, 53)

				hideNewADFrameFunc()
			end
		else
			adFrame:Hide()
			local light = getglobal("DeathFrameADFrameLight")
			if light then
				light:StopUVAnim()
			end
			btnRevive:SetPoint("bottomright", "DeathFrame", "bottom", -30, -133)
			mTombstone:SetPoint("top", "DeathFrameCause", "bottom", 0, 53)

			hideNewADFrameFunc()
		end
	end
end

function DeathChooseFrameNewADContinueBtn_OnClick()
	local adFrame = getglobal("DeathFrameADFrame")
	if isInValid() or not adFrame then
		return
	end
	deathClick = 3
	
    local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()

	reviveAdPositionId = adFrame:GetClientUserData(2) or 2

	if IsAdUseNewLogic(reviveAdPositionId) then
		-- 105广告位埋点增加作者uin和地图id
		if reviveAdPositionId == 105 then
			StatisticsADNew('onclick', reviveAdPositionId, nil, nil, authorUin, mapId)
		else
			StatisticsADNew('onclick', reviveAdPositionId)
		end	
	else
		-- 105广告位埋点增加作者uin和地图id
		if reviveAdPositionId == 105 then
			StatisticsAD('onclick', reviveAdPositionId, nil, authorUin, mapId)
		else
			StatisticsAD('onclick', reviveAdPositionId)
		end
	end
	--新埋点
	DeathFrame_StandReportEvent("RESURRECTION_POPUP", "AdPlayResurrectionButton", "click", {cid = tostring(mapId), standby3 = reviveAdPositionId})


    local reviveAdPositionData =
    {
        position = reviveAdPositionId,
        authorUin = authorUin,
        mapId = mapId,
		resid = adFrame:GetClientUserData(0) or -1,
		resnum = adFrame:GetClientUserData(1) or 0
    }
	if WatchADNetworkTips(OnReqWatchADRevive, reviveAdPositionData) then
		OnReqWatchADRevive(reviveAdPositionData);
	end
end

function DeathChooseFrameADContinueBtn_OnEnter()
	local details = getglobal("DeathFrameADFrameDetails")
	if details then
		details:Show()
	end
end

function DeathChooseFrameADContinueBtn_OnLeave()
	local details = getglobal("DeathFrameADFrameDetails")
	if details then
		details:Hide()
	end
end

function DeathChooseFrameADContinueBtn_OnMouseDown()
	local details = getglobal("DeathFrameADFrameDetails")
	if details then
		details:Show()
	end
end

function DeathChooseFrameADContinueBtn_OnMouseUp()
	local details = getglobal("DeathFrameADFrameDetails")
	if details then
		details:Hide()
	end
end

--事件上报代理，推荐页的上报都走这,方便统一管理(埋点)
function DeathFrame_StandReportEvent(cID,oID,event,eventTb)
	local sceneID = "";--统一ID
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
		sceneID = "1003";
	else--客机
		sceneID = "1001";
	end
	eventTb = eventTb or {}
	if not eventTb.cid then
		eventTb.cid = tostring(G_GetFromMapid())
	end
	standReportEvent(sceneID,cID,oID,event,eventTb)
end
