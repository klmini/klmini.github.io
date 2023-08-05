-----------------------------------------------------房间内聊天防刷屏-----------------------------------------------------
local math = _G.math
local getglobal = _G.getglobal
--local ShowGameTips = _G.ShowGameTips
local GetS = _G.GetS
local os = _G.os
local string = _G.string
-----------------------------------------------------SpamPreventionView start-----------------------------------------------------
local SpamPreventionView = {
    m_aMinuteOptionsUIName = {
        [1] = "NoneMute",
        [2] = "Mute5Minutes",
        [3] = "MuteInfinitely",
    }
}
function SpamPreventionView:init()
end

function SpamPreventionView:displaySpamPreventionSettings(bIsHost)    
    local getglobal = getglobal
	local ui_musicPlayer = getglobal("RoomUIFrameSetOptionMusicPlayer")

    getglobal("RoomUIFrameSetOptionChatBubble"):Show();
    if bIsHost then
        getglobal("RoomUIFrameSetOptionAllMute"):Show();
        getglobal("RoomUIFrameSetOptionSpamPrevention"):Show();
        -- ui_musicPlayer:SetPoint("top","RoomUIFrameSetOptionSpamPrevention","bottom",0,10)
    else
        getglobal("RoomUIFrameSetOptionAllMute"):Hide();
        getglobal("RoomUIFrameSetOptionSpamPrevention"):Hide();
        -- ui_musicPlayer:SetPoint("top","RoomUIFrameSetOptionBlacklist","bottom",0,10)
    end

    -- getglobal("RoomUIFrameSetOptionAllMuteTitleName"):SetText(GetS(30017), 61, 69, 70);
    -- getglobal("RoomUIFrameSetOptionSpamPreventionTitleName"):SetText(GetS(30018), 61, 69, 70);
    -- local rtAllMuteTitle = getglobal("RoomUIFrameSetOptionAllMuteTitle")
    -- local rtSpamPreventionTitle = getglobal("RoomUIFrameSetOptionSpamPreventionTitle")
    self:displayRoomSettingsTitleTemplateWidth("RoomUIFrameSetOptionAllMuteTitle", 30017)
    self:displayRoomSettingsTitleTemplateWidth("RoomUIFrameSetOptionSpamPreventionTitle", 30018)
    -- self:displayRoomSettingsTitleTemplateWidth("RoomUIFrameSetOptionChatBubbleTitle", 111600)

    if CurWorld then
        local owId = G_GetFromMapid()--CurWorld:getOWID()
        local isOpenB = GetInst("ShareArchiveInterface"):WDescChatBubbleValue(owId) or false;
        if not isOpenB then
            threadpool:work(function ()
                ReqMapInfo({owId},function (maps)
                    -- print('sundy----->>>', mapDesc);
                    if maps and #maps > 0 then
                        local mapDesc = CreateWorldDescFromMap(maps[1])
                        if mapDesc then
                            local sv = mapDesc.shareVersion or 0
                            local wt = mapDesc.worldtype or 0
                            local gl = mapDesc.gameLabel or 0
                            if gl == 0 then
                                gl = GetLabel2Owtype(wt);
                            end

                            if sv <= 1647360000 then -- 上传时间为2022.03.16 0点之前
                                if gl ~= 4 then -- 地图类型为非对战
                                    isOpenB = true
                                end
                            end
                        end
                    end

                    if not isOpenB then
                        getglobal("RoomUIFrameSetOptionChatBubble"):Hide();
                    end
                end)
            end)

        end

    end
    
    if getglobal("RoomUIFrameSetOptionChatBubble"):IsShown() then
        local roomType = 1
		if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then
			roomType = 2
		end
        local state = ClientMgr:getGameData("ChatBubble");
		local eventTb = {
			cid = tostring(G_GetFromMapid()),
			standby1 = roomType,
			button_state = state,
			standby2 = 1,
		}
        if IsRoomOwner() then
            standReportEvent("1003", "MINI_CHAT_BUBBLE_NEW_SWITCH", "-", "view", eventTb)
        else
            standReportEvent("1001", "MINI_CHAT_BUBBLE_NEW_SWITCH", "-", "view", eventTb)
        end
    end
end

--[[
    含外部调用
]]
function SpamPreventionView:displayRoomSettingsTitleTemplateWidth(szButtonName, iTitleId, isLine)
    if not iTitleId then iTitleId = 166 end
    local titleStr = ""
    if "string" == type(iTitleId) and nil == tonumber(iTitleId) then
        titleStr = iTitleId
    else
        titleStr = GetS(iTitleId)
    end
    local btn = getglobal(szButtonName)
    local rt = getglobal(szButtonName .. "Name")
    if not rt then return end
    -- 添加下划线
    local szTitle = "#L"..titleStr
    -- if bWithSwitchState then
    --     szTitle = szTitle .. "("
    --     if bOn then
    --         szTitle = szTitle .. GetS(21742)
    --     else
    --         szTitle = szTitle .. GetS(21743)
    --     end
    --     szTitle = szTitle .. "#n)"
    -- end
    szTitle = szTitle .. "#n"
    if isLine then
        szTitle = titleStr
    end
    rt:SetText(szTitle, 61, 69, 70);
    local w = rt:getLineRealWidth(0) * 1.2;
--    print("SpamPreventionView:displayRoomSettingsTitleTemplateWidth", szButtonName, rt:getLineRealWidth(0))
    if string.find(szTitle, "#c", 0, true) then
        w = w * 0.5
    end

    if w < 170 then
        w = 170
    end

    rt:SetWidth(w)
    if not btn then return end
    btn:SetWidth(w)
end

function SpamPreventionView:displayAllMuteState(bAllMute)
    local szUIName = "AllMuteSwitch";
    local btnAllMuteSwitch = getglobal(szUIName)
	-- print("postOnCheck(): szUIName = ", szUIName,bAllMute);
	local point = getglobal(szUIName.."Point");	
    if bAllMute then
		point:SetPoint("right", szUIName, "right", 0, 0);
		btnAllMuteSwitch:SetText(GetS(21742))
    else
		point:SetPoint("left", szUIName, "left", 0, 0);
		btnAllMuteSwitch:SetText(GetS(21743))
    end
end

function SpamPreventionView:displayCurrentSpamPrevention(iSpamMinutes)    
    local szText
    local iHighlight = 0
    if iSpamMinutes == 0 then
        szText = GetS(3536)
        iHighlight = 1
    elseif iSpamMinutes < 0 then
        szText = GetS(30019)
        iHighlight = 3
    elseif iSpamMinutes == 5 then
        szText = GetS(30020)
        iHighlight = 2
    else
        szText = iSpamMinutes .. GetS(4975)
        iHighlight = 2
    end
    local aMinuteOptionsUIName = self.m_aMinuteOptionsUIName;
    for i=1, #aMinuteOptionsUIName do 
        getglobal(aMinuteOptionsUIName[i] .. "Bg"):SetTextureTemplate("TemplateBkg8");
        getglobal(aMinuteOptionsUIName[i] .. "Name"):SetTextColor(185, 185, 185);
    end
    if iHighlight > 0 and iHighlight <= #aMinuteOptionsUIName then
        getglobal(aMinuteOptionsUIName[iHighlight] .. "Bg"):SetTextureTemplate("TemplateBkg80");
        getglobal(aMinuteOptionsUIName[iHighlight] .. "Name"):SetTextColor(255, 255, 255);
    end
    getglobal("RoomUIFrameSetOptionSpamPreventionSelectMinutesName"):SetText(szText)
end

function SpamPreventionView:displayPlayersSpeakingMaskState(bMasked)
    local iUin = getglobal("RoomUIFrameFuncOption"):GetClientID()
    local btnMaskSpeaking = getglobal("RoomUIFrameFuncOptionMaskSpeakingBtn")
    if iUin == AccountManager:getUin() then
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnIcon"):SetTexUV("icon_tidings");
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnName"):SetText(GetS(20613));
        btnMaskSpeaking:Disable()
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnName"):SetTextColor(55,54,50);
        return
    end
    btnMaskSpeaking:Enable()
    if bMasked then
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnNormal"):ChangeTextureTemplate("TemplateBkg23");
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnPushedBG"):ChangeTextureTemplate("TemplateBkg23");
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnIcon"):SetTexUV("icon_tidings_close");
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnName"):SetText(GetS(9724));
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnName"):SetTextColor(55,54,51);
    else
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnNormal"):ChangeTextureTemplate("TemplateBkg24");
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnPushedBG"):ChangeTextureTemplate("TemplateBkg24");
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnIcon"):SetTexUV("icon_tidings");
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnName"):SetText(GetS(20613));
        getglobal("RoomUIFrameFuncOptionMaskSpeakingBtnName"):SetTextColor(51,55,55);
    end
end

function SpamPreventionView:displayPlayerMuteState(bMute)
    local iUin = getglobal("RoomUIFrameFuncOption"):GetClientID()
    local btnMute = getglobal("RoomUIFrameFuncOptionMuteBtn")
    local btnMuteName = getglobal("RoomUIFrameFuncOptionMuteBtnName")

    getglobal("RoomUIFrameFuncOptionMuteBtnIcon"):SetTexUV("icon_chat");
    btnMute:SetText(GetS(20614));
    --租赁服禁言
    if RentPermitCtrl:SetPlayerMuteBtnState(iUin) then return end

    -- 房员无法禁言其它房员
    if ClientCurGame and AccountManager:getUin() ~= ClientCurGame:getHostUin() then
        btnMute:Disable()
        btnMuteName:SetTextColor(55,54,50)
        return
    end
    -- 无法禁言自己
    if iUin == AccountManager:getUin() then
        btnMute:Disable()
        btnMuteName:SetTextColor(55,54,50)
        return
    end
    -- 无法禁言房主
    if ClientCurGame and iUin == ClientCurGame:getHostUin() then
        btnMute:Disable()
        btnMuteName:SetTextColor(55,54,50)
        return
    end
    btnMute:Enable()
    if bMute then
        getglobal("RoomUIFrameFuncOptionMuteBtnNormal"):ChangeTextureTemplate("TemplateBkg23");
        getglobal("RoomUIFrameFuncOptionMuteBtnPushedBG"):ChangeTextureTemplate("TemplateBkg23");
        getglobal("RoomUIFrameFuncOptionMuteBtnIcon"):SetTexUV("icon_chat_close");
        btnMute:SetText(GetS(30029));
        btnMuteName:SetTextColor(55,54,51)
    else
        getglobal("RoomUIFrameFuncOptionMuteBtnNormal"):ChangeTextureTemplate("TemplateBkg24");
        getglobal("RoomUIFrameFuncOptionMuteBtnPushedBG"):ChangeTextureTemplate("TemplateBkg24");
        getglobal("RoomUIFrameFuncOptionMuteBtnIcon"):SetTexUV("icon_chat");
        btnMute:SetText(GetS(20614));
        btnMuteName:SetTextColor(51,55,55)
    end
end

function SpamPreventionView:onGameEvent(arg1)
    -- local print = Android:Localize(Android.SITUATION.SPAM_PREVENTION);
    local ge = GameEventQue:getCurEvent()
    -- print("onGameEvent(): arg1 = ", arg1);
    -- print("onGameEvent(): ge = ", ge);
    if arg1 == "GE_ON_CLICK" then 
        self:onClick(ge.body.onUIEvent.szUIName)
    elseif arg1 == "GE_ON_CHECK" then
        self:onCheck(ge.body.onCheckListener.szUIName, ge.body.onCheckListener.bChecked)
    -- elseif arg1 == "GE_ON_FOCUS_LOST" then 
    --     self:onFocusLost(ge.body.onUIEvent.szUIName)
    elseif arg1 == "GE_ON_ENTER_PRESSED" then 
        self:onEnterPressed(ge.body.onUIEvent.szUIName)
    elseif arg1 == "GE_ON_MOUSE_ENTER" then
        -- ShowGameTips(arg1 .. " " .. ge.body.onUIEvent.szUIName);
        -- print(arg1 .. " " .. ge.body.onUIEvent.szUIName);
        self:onMouseEnter(ge.body.onUIEvent.szUIName)
    elseif arg1 == "GE_ON_MOUSE_LEAVE" then
        -- ShowGameTips(arg1 .. " " .. ge.body.onUIEvent.szUIName);
        print(arg1 .. " " .. ge.body.onUIEvent.szUIName);
        self:onMouseLeave(ge.body.onUIEvent.szUIName)
    elseif arg1 == "GE_ON_MOUSE_DOWN_UPDATE" then
        self:onMouseDownUpdate(ge.body.onUIEvent.szUIName)
    elseif arg1 == "GE_ON_MOUSE_UP" then
        self:onMouseUp(ge.body.onUIEvent.szUIName)
    end
end

function SpamPreventionView:onClick(szUIName)
    -- print("onClick(): szUIName = ", szUIName);
    if szUIName == "RoomUIFrameSetOptionSpamPreventionSelectMinutes" then
        local frameMinutes = getglobal("RoomUIFrameSetOptionSpamPreventionMinuteOptions")
        if frameMinutes:IsShown() then
            self:hideMinutesOptions();
        else
            self:showMinuteOptions();
        end
    elseif szUIName == "NoneMute" then
        if RentPermitCtrl:IsRentRoom() then
            PermitsCallModuleScript("sendCSHostAutoMuteMsg",0)
        else
            self.mCallback:requestSetSpamPrevention(false, 0);
        end
        self:hideMinutesOptions(szUIName);
    elseif szUIName == "Mute5Minutes" then
        if RentPermitCtrl:IsRentRoom() then
            PermitsCallModuleScript("sendCSHostAutoMuteMsg",5)
        else
            self.mCallback:requestSetSpamPrevention(true, 5);
        end
        self:hideMinutesOptions(szUIName);
    elseif szUIName == "MuteInfinitely" then
        if RentPermitCtrl:IsRentRoom() then
            PermitsCallModuleScript("sendCSHostAutoMuteMsg",-1)
        else
            self.mCallback:requestSetSpamPrevention(true, -1); 
        end
        self:hideMinutesOptions(szUIName);
    elseif szUIName == "RoomUIFrameFuncOptionMaskSpeakingBtn" then
        local frameFuncOption = getglobal("RoomUIFrameFuncOption")
        local iUin = frameFuncOption:GetClientID()
        frameFuncOption:Hide();
        self.mCallback:requestMaskPlayersSpeaking(iUin)
    elseif szUIName == "RoomUIFrameFuncOptionMuteBtn" then
        local frameFuncOption = getglobal("RoomUIFrameFuncOption")
        local iUin = frameFuncOption:GetClientID()
        RentPermitCtrl:MutePlayer(iUin)
        frameFuncOption:Hide();

        --[[if RentPermitCtrl:IsRentRoom() then

        else
            self.mCallback:requestSetPlayerMute(iUin)
            frameFuncOption:Hide();
        end--]]
    elseif szUIName == "RoomUIFrameSetOptionAllMuteTitleName" then
        self:onMouseEnter(szUIName)
    elseif szUIName == "RoomUIFrameSetOptionSpamPreventionTitleName" then
        self:onMouseEnter(szUIName)
    elseif szUIName == "RoomUIFrameSetOptionRoomPermitsTitleName" then
        self:onMouseEnter(szUIName)
    elseif szUIName == "RoomUIFrameSetOptionDisableItemTitleName" then
        self:onMouseEnter(szUIName)
    elseif szUIName == "RoomUIFrameSetOptionRandSpawnTitleName" then
        self:onMouseEnter(szUIName)
    elseif szUIName == "RoomUIFrameSetOptionInvitePermitTitleName" then
        self:onMouseEnter(szUIName)
    elseif szUIName == "RoomUIFrameSetOptionChatBubbleTitleName" then
        self:onMouseEnter(szUIName)
    elseif szUIName == "RoomUIFrameSetOptionTeamAllVoiceTitleName" then
        self:onMouseEnter(szUIName)
    end
end

function SpamPreventionView:showMinuteOptions()
    local getglobal = getglobal
    local frameMinutes = getglobal("RoomUIFrameSetOptionSpamPreventionMinuteOptions")
    local textureArrow = getglobal("RoomUIFrameSetOptionSpamPreventionSelectMinutesArrow")
    local planeOption = getglobal("RoomUIFrameSetOptionPlane");
    local heightPlane = planeOption:GetHeight()
    if not frameMinutes:IsShown() then
        frameMinutes:Show();
        textureArrow:MirrorVertically();
        heightPlane = heightPlane + frameMinutes:GetHeight();
    end
    -- planeOption:SetHeight(heightPlane);

    self.mCallback:requestCurrentSpamPrevention();
end

function SpamPreventionView:hideMinutesOptions(szBtnSelectMinutes)
    local getglobal = getglobal
    local frameMinutes = getglobal("RoomUIFrameSetOptionSpamPreventionMinuteOptions")
    local textureArrow = getglobal("RoomUIFrameSetOptionSpamPreventionSelectMinutesArrow")
    local planeOption = getglobal("RoomUIFrameSetOptionPlane");
    local heightPlane = planeOption:GetHeight()
    if frameMinutes:IsShown() then
        frameMinutes:Hide();
        textureArrow:MirrorVertically();
        heightPlane = heightPlane - frameMinutes:GetHeight();
    end
    -- planeOption:SetHeight(heightPlane);
    if szBtnSelectMinutes then
        local fsCurMinutes = getglobal("RoomUIFrameSetOptionSpamPreventionSelectMinutesName")
        local fsSelectMinutes = getglobal(szBtnSelectMinutes .. "Name");
        fsCurMinutes:SetText(fsSelectMinutes:GetText())
    end
end

function SpamPreventionView:onCheck(szUIName, bChecked)
    -- print("onCheck(): szUIName = ", szUIName);
    -- print("onCheck(): bChecked = ", bChecked);
    if szUIName == "AllMuteSwitch" then
        self.mCallback:requestSetAllMute(bChecked)
    end
end


function SpamPreventionView:onEnterPressed(szUIName)
    -- print("onEnterPressed(): szUIName = ", szUIName);
    if szUIName == "ChatInputBox" then
        self:sendChat(szUIName);
        getglobal("ChatInputFrame"):Hide();
    end
end

function SpamPreventionView:displayFullscreenSendChat()
    self:sendChat("ChatInputBox");
    getglobal("ChatInputFrame"):Hide();
    UIFrameMgr:setCurEditBox(nil);
end

function SpamPreventionView:displayRoomUIFrameSendChat()
    self:sendChat("RoomUIFrameCenterChatEdit");
    UIFrameMgr:setCurEditBox(nil);
end

function SpamPreventionView:displayRoomUIFrameSendChatMobile()
    if false == AccountSafetyCheck:FunCheck(AccountSafetyCheck.FunType.INMAP_CHAR, SpamPreventionView.displayRoomUIFrameSendChatMobile) then
        return
    end

    local print = Android:Localize(Android.SITUATION.SPAM_PREVENTION);
    print("displayRoomUIFrameSendChatMobile(): ");
    if ClientMgr:isMobile() then
        self:sendChat("RoomUIFrameCenterChatEdit");
    end
end

function SpamPreventionView:onMouseEnter(szUIName)
    getglobal("RoomUIFrameSetTips"):SetSize(222,101)
    getglobal("RoomUIFrameSetTipsBkg2"):SetSize(202,81)
    getglobal("RoomUIFrameSetTipsText"):SetSize(185,65)
    getglobal("RoomUIFrameSetTipsBkg"):SetAnchorOffset(0,0)
    if szUIName == "RoomUIFrameSetOptionAllMuteTitleName" then
        self:showRoomSettingTips(szUIName, 30027)
    elseif szUIName == "RoomUIFrameSetOptionSpamPreventionTitleName" then
        self:showRoomSettingTips(szUIName, 30028)
    elseif szUIName == "RoomUIFrameSetOptionRoomPermitsTitleName" then
        getglobal("RoomUIFrameSetTips"):SetSize(302,181)
        getglobal("RoomUIFrameSetTipsBkg2"):SetSize(282,161)
        getglobal("RoomUIFrameSetTipsText"):SetSize(265,145)
        getglobal("RoomUIFrameSetTipsBkg"):SetAnchorOffset(0,40)
        self:showRoomSettingTips(szUIName, 9661)
    elseif szUIName == "RoomUIFrameSetOptionDisableItemTitleName" then
        self:showRoomSettingTips(szUIName, 1192)
    elseif szUIName == "RoomUIFrameSetOptionRandSpawnTitleName" then
        self:showRoomSettingTips(szUIName, 1194)
    elseif szUIName == "RoomUIFrameSetOptionChatBubbleTitleName" then
        self:showRoomSettingTips(szUIName, 111601)
    elseif szUIName == "RoomUIFrameSetOptionInvitePermitTitleName" then
        getglobal("RoomUIFrameSetTips"):SetSize(302,181)
        getglobal("RoomUIFrameSetTipsBkg2"):SetSize(282,161)
        getglobal("RoomUIFrameSetTipsText"):SetSize(265,145)
        getglobal("RoomUIFrameSetTipsBkg"):SetAnchorOffset(0,40)
        self:showRoomSettingTips(szUIName, 28964)
    elseif szUIName == "RoomUIFrameSetOptionTeamAllVoiceTitleName" then
        self:showRoomSettingTips(szUIName, 111272)
    end
end

function SpamPreventionView:onMouseLeave(szUIName)
    if szUIName == "RoomUIFrameSetOptionAllMuteTitleName" then
        self:hideRoomSettingTips()
    elseif szUIName == "RoomUIFrameSetOptionSpamPreventionTitleName" then
        self:hideRoomSettingTips()
    elseif szUIName == "RoomUIFrameSetOptionRoomPermitsTitleName" then
        self:hideRoomSettingTips()
    elseif szUIName == "RoomUIFrameSetOptionDisableItemTitleName" then
        self:hideRoomSettingTips()
    elseif szUIName == "RoomUIFrameSetOptionRandSpawnTitleName" then
        self:hideRoomSettingTips()
    elseif szUIName == "RoomUIFrameSetOptionInvitePermitTitleName" then
        self:hideRoomSettingTips()
    elseif szUIName == "RoomUIFrameSetOptionChatBubbleTitleName" then
        self:hideRoomSettingTips()
    elseif szUIName == "RoomUIFrameSetOptionTeamAllVoiceTitleName" then
        self:hideRoomSettingTips()
    end
end

function SpamPreventionView:onMouseDownUpdate(szUIName)
    self:onMouseEnter(szUIName)
end

function SpamPreventionView:onMouseUp(szUIName)
    self:onMouseLeave(szUIName)
end

function SpamPreventionView:sendChat(szUIName)
    threadpool:work(function ()
        -- action_id:1 限制语音   action_id:2限制聊天
        if GetInst("CreditScoreService"):CheckLimitAction(GetInst("CreditScoreService"):GetTypeTbl().chat) then
            return	
        end

        -- local print = Android:Localize(Android.SITUATION.SPAM_PREVENTION);
        -- print("SpamPreventionView:sendChat(): szUIName = ", szUIName);
        local ebChat = getglobal(szUIName);
        local szPlayerMsg = ebChat:GetText();
        if szPlayerMsg == nil or type(szPlayerMsg) ~= "string" or #szPlayerMsg <= 0 then return end
        if CheckFilterString(szPlayerMsg) then return end
        --print("SpamPreventionView:sendChat(): szPlayerMsg = ", szPlayerMsg);
        
        --检测NewInputContent事件
        if CurMainPlayer and CurMainPlayer.onInputContent then 
            CurMainPlayer:onInputContent(szPlayerMsg)
        end

        ebChat:AddStringToHistory(szPlayerMsg);
        self.mCallback:requestSendChat(szPlayerMsg);
        ebChat:Clear();
        if szUIName == "RoomUIFrameCenterChatEdit" then
            local mapId = ""
            if ClientCurGame:isInGame() then
                local desc = AccountManager:getCurWorldDesc();
                if desc and desc.fromowid and desc.fromowid > 0 then
                    mapId = desc.fromowid 
                elseif desc and desc.worldid and desc.worldid > 0 then
                    mapId = desc.worldid 
                else
                    mapId = G_GetFromMapid();
                end
            end
            standReportEvent("1003", "CHAT_INPUT_BOX", "SendMSG", "click", {cid = tostring(mapId),standby2 = szPlayerMsg})
        end
    end)
end

function SpamPreventionView:showRoomSettingTips(szRelativeToUIName, iTipsId)
	getglobal("RoomUIFrameSetTipsText"):SetText(GetS(iTipsId))
	-- local height = getglobal("RoomUIFrameSetTipsText"):GetTotalHeight() / UIFrameMgr:GetScreenScaleY();

	getglobal("RoomUIFrameSetTips"):SetPoint("left", szRelativeToUIName, "right", 8, 19)
	getglobal("RoomUIFrameSetTips"):Show();
end

function SpamPreventionView:hideRoomSettingTips()
	getglobal("RoomUIFrameSetTips"):Hide();
end

-----------------------------------------------------SpamPreventionView end-----------------------------------------------------
-----------------------------------------------------SpamPreventionModel start-----------------------------------------------------
local SpamPreventionModel = {
    --[[
        最大可刷屏的记录
    ]]
    MAX_SAME_MESSAGE_COUNT = 4,
    --[[
        记录刷屏的消息
    ]]
    m_aMessages = {

    },
    --[[
        上一次发送消息的事件
    ]]
    m_iLastSendChatTime = 0,
    --[[
        是否被屏蔽的uin映射表：[uin]->[boolean]
    ]]
    m_mSpeakingMasked = {

    },
    
    m_SpamPunishTimer = nil,
}

function SpamPreventionModel:init()
    self.m_SpamPunishTimer = TimerFactory:newLazyTimer();
end

function SpamPreventionModel:addMessage(szMessage)
    if not PermitsCallModuleScript("getSpamPreventionMode") then
        return
    end
    if not szMessage then
        return
    end
    self.m_aMessages[#self.m_aMessages + 1] = szMessage
end

--[[
    被房主禁言  
    Created on 2019-09-09 at 15:31:51
]]
function SpamPreventionModel:hasBeenMuteByOwner()
    return PermitsCallModuleScript("isPlayerMute",AccountManager:getUin())
end

--[[
    全禁言 
]]
function SpamPreventionModel:areAllMute()
    return ClientCurGame and AccountManager:getUin() ~= ClientCurGame:getHostUin() and PermitsCallModuleScript("getAllMuteMode")
end

--[[
    二、刷屏行为限制：
    1.频率限制
    消息发送冷却时间限制为1秒（1000毫秒），
    发送消息后的1秒内发送的第二次及以上次数的消息将被记录为刷屏行为，
    冷却时间内的消息不予发送并弹出“说话过快”的提示。  
    Created on 2019-09-03 at 11:55:07
]]
function SpamPreventionModel:isSpeakingTooFast()
    return AccountManager:getSvrTime() - self.m_iLastSendChatTime <= 0 
end

--[[
    二、刷屏行为限制：
    2.重复次数限制
    相同消息连续发送4次及以上记录为一次刷屏，
    且第四次及以上消息在5秒内发送无效，弹出“请勿重复刷屏”的提示。
    触发重复刷屏的5秒后可再次发送该条消息。
    Created on 2019-09-03 at 11:38:40
]]
function SpamPreventionModel:hasSpammed()
    if not PermitsCallModuleScript("getSpamPreventionMode") then
        return false
    end
    local aMessages = self.m_aMessages;
    local length = #aMessages
    if length < self.MAX_SAME_MESSAGE_COUNT then 
        return false
    end
    for i=length-self.MAX_SAME_MESSAGE_COUNT+2, length do 
        if aMessages[i-1] ~= aMessages[i] then
            return false
        end
    end
    return true
end

--[[
    自动禁言后，是否超过计时可以说话  
    Created on 2019-09-09 at 22:11:15
]]
function SpamPreventionModel:canSpeakAfterSpamming()
    -- print("canSpeakAfterSpamming(): ");
    if not PermitsCallModuleScript("getSpamPreventionMode") then
        return true
    end
    local iSpamMinutes = PermitsCallModuleScript("getSpamPreventionMinutes")
    -- print("canSpeakAfterSpamming(): iSpamMinutes = ", iSpamMinutes);
    if iSpamMinutes < 0 then --infinitely
        return false
    elseif iSpamMinutes > 0 then
        local LazyTimer = self.m_SpamPunishTimer
        local hasStarted = LazyTimer:hasStarted()
        -- print("canSpeakAfterSpamming(): hasStarted = ", hasStarted);
        -- print("canSpeakAfterSpamming(): LazyTimer:getResidualSeconds() = ", LazyTimer:getResidualSeconds());
        if LazyTimer:hasStarted() and LazyTimer:getResidualSeconds() > 0 then -- still in punishment
            return false
        elseif not LazyTimer:hasStarted() then
            return false
        else
            LazyTimer:stop();
        end
    end

    self:requestClearSpamHistoryMessages();
    return true
end

function SpamPreventionModel:sendChat(szPlayerMsg)
    self:addMessage(szPlayerMsg)
    self.m_iLastSendChatTime = AccountManager:getSvrTime();
    local isRoomOw = IsRoomOwner() and 1 or 2;
    if ClientCurGame then 
        ReqCheckSendChat(szPlayerMsg, isRoomOw);
        -- if if_open_google_translate_room(ClientCurGame:getHostUin()) then
        --     ClientCurGame:sendChat(szPlayerMsg, 0, 0, get_game_lang());
        -- else
        --     ClientCurGame:sendChat(szPlayerMsg);
        -- end
    end 
   -- statisticsGameEvent(53002, "%s", "sendChatText", "%d", isRoomOw);

end

--[[
    修改设置的处理方法：
    修改设置后，此前所有被自动禁言的玩家按照修改后的倒计时重新计算。
    1.玩家A被自动禁言5min，房主修改设置为“无期限”，此时A玩家重新计时为“无期限”
    2.玩家B被自动禁言无期限，房主修改设置为“5min”，此时B重新从5min开始倒计时
    Created on 2019-09-16 at 19:40:58
]]
function SpamPreventionModel:onNotifySpamPrevetionOptionChange()
    -- print("onNotifySpamPrevetionOptionChange(): ");
    local iLastSpamPreventionMinutes = self.m_iLastSpamPreventionMinutes
    local iCurSpamPreventionMinutes = PermitsCallModuleScript("getSpamPreventionMinutes")
    -- print("onNotifySpamPrevetionOptionChange(): iLastSpamPreventionMinutes = ", iLastSpamPreventionMinutes);
    -- print("onNotifySpamPrevetionOptionChange(): iCurSpamPreventionMinutes = ", iCurSpamPreventionMinutes);
    if iLastSpamPreventionMinutes == iCurSpamPreventionMinutes then
        return
    end
	if not iLastSpamPreventionMinutes then
		iLastSpamPreventionMinutes = 0
	end 
	if not iCurSpamPreventionMinutes then
		iCurSpamPreventionMinutes = 0
	end 
    local LazyTimer = self.m_SpamPunishTimer;
    -- print("onNotifySpamPrevetionOptionChange(): LazyTimer:hasStarted() = ", LazyTimer:hasStarted());
    -- print("onNotifySpamPrevetionOptionChange(): LazyTimer:getResidualSeconds() = ", LazyTimer:getResidualSeconds());
    --print("onNotifySpamPrevetionOptionChange(): LazyTimer = " + LazyTimer);
    --print("onNotifySpamPrevetionOptionChange(): os.time() = ", os.time());
    self.m_iLastSpamPreventionMinutes = iCurSpamPreventionMinutes;
    if iLastSpamPreventionMinutes == 0 then

    elseif iCurSpamPreventionMinutes == 0 then -- 从5min或无限期切换到无，停止计时，清除计时记录
        self:requestClearSpamHistoryMessages();
        LazyTimer:stop();
    elseif iLastSpamPreventionMinutes > 0 and iCurSpamPreventionMinutes < 0 then -- 从5min切换到无限期，暂停计时
        LazyTimer:pause();
    elseif iLastSpamPreventionMinutes < 0 and iCurSpamPreventionMinutes > 0 then -- 从无限期切换到5min，继续计时
        if LazyTimer:hasStarted() then
            LazyTimer:resume();
        else
            LazyTimer:start(iCurSpamPreventionMinutes * 60);
        end
        -- print("onNotifySpamPrevetionOptionChange(): after resume LazyTimer = " + LazyTimer);
    end
end

--[[
    发送消息加判断
    Created on 2019-09-03 at 17:36:04
]]
function SpamPreventionModel:requestSendChat(szPlayerMsg)
    threadpool:work(function ()
        -- local print = Android:Localize(Android.SITUATION.SPAM_PREVENTION);
        if ns_data.IsGameFunctionProhibitedByActTime("ct2", 10581, 10582) then 
            return 
        end

        -- action_id:1 限制语音   action_id:2限制聊天
        if GetInst("CreditScoreService") and GetInst("CreditScoreService"):CheckLimitAction(GetInst("CreditScoreService"):GetTypeTbl().chat) then  --信用分限制
            return	
        end

        if AccountManager:getMultiPlayer() == 0 then
            ReqCheckSendChat(szPlayerMsg);
            --ClientCurGame:sendChat(szPlayerMsg);
            return
        end

        local szToast
        if self:isRoomPlayerMute() then
            return
        end
        --[[ todo_delete
        if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() and self:hasBeenMuteByOwner() then
            szToast = GetS(20622)
            ShowGameTips(szToast)
            return
        end

        if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() and self:areAllMute() then
            szToast = GetS(30026)
            ShowGameTips(szToast)
            return
        end
        ]]
        if self:isSpeakingTooFast() then
            szToast = GetS(1129)
            ShowGameTips(szToast)
            return
        end

        --CHAT_INPUT_BOX 埋点
--[[        local sid = "1001"
        if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
            sid = "1003"
        end
        standReportEvent(sid, "CHAT_INPUT_BOX", "SendMSG", "click" ,{standby1 = 1})--]]

        if self:hasSpammed() and not self:canSpeakAfterSpamming() then
            local LazyTimer = self.m_SpamPunishTimer
            local iSpamMinutes = PermitsCallModuleScript("getSpamPreventionMinutes")
            -- print("requestSendChat(): iSpamMinutes = ", iSpamMinutes);
            if iSpamMinutes > 0 then
                -- print("requestSendChat(): LazyTimer = ", LazyTimer);
                -- print("requestSendChat(): LazyTimer:toString() = ", LazyTimer:toString());
                -- print("requestSendChat(): os.time() = ", os.time());
                if not LazyTimer:hasStarted() then
                    LazyTimer:stop()
                    LazyTimer:start(iSpamMinutes * 60)
                end
                -- print("requestSendChat(): after start LazyTimer = " + LazyTimer);
                local format;
                local iResidualSeconds = LazyTimer:getResidualSeconds();
                local iResidualMinutesFloor = math.floor(iResidualSeconds / 60);
                if iResidualSeconds >= 60 then
                    local seconds = iResidualSeconds % 60
                    if seconds == 0 then
                        seconds = "00"
                    end
                    format = iResidualMinutesFloor .. ":" .. seconds;
                elseif iResidualSeconds >= 10 then
                    format = "0:" .. iResidualSeconds;
                else
                    format = "0:0" .. iResidualSeconds;
                end

                if iResidualSeconds == iSpamMinutes * 60 then
                    local nickname = AccountManager:getNickName()
                    if nickname and nickname ~= "" then
                        -- ClientCurGame:sendChat(GetS(9742,nickname), 1)
                        --不用广播出去，只在自己的聊天界面上显示
                        GameEventQue:postChatEvent(1, nil, GetS(9742,nickname))
                    end
                end

                szToast = GetS(30025, format);
            elseif iSpamMinutes < 0 then
                szToast = GetS(30025, GetS(30019));
            else
                self:sendChat(szPlayerMsg)
                return
            end
            ShowGameTips(szToast);
            return
        end

        -- print("requestSendChat(): self.m_SpamPunishTimer:toString() = ", self.m_SpamPunishTimer:toString());
        -- print("requestSendChat(): os.time() = ", os.time());
        self:sendChat(szPlayerMsg)
    end)
end

--[[
    全房间禁言
    Created on 2019-09-04 at 21:20:28
]]
function SpamPreventionModel:requestSetAllMute(bAllMute)
    -- print("requestSetAllMute(): bAllMute = ", bAllMute);

    RentPermitCtrl:SetAllMute(bAllMute)
    --[[
    PermitsCallModuleScript("setAllMuteMode",bAllMute)
    local szSystemMsg
    if bAllMute then
        szSystemMsg = GetS(30021)
    else
        szSystemMsg = GetS(30022)
    end
    ClientCurGame:sendChat(szSystemMsg, 1);
    ]]
end

--[[
    自动禁言  
    Created on 2019-09-05 at 15:23:14
    params: csAuthType[云服设置禁言的玩家类型]
]]
function SpamPreventionModel:requestSetSpamPrevention(bSpamPrevention, iMinutes,csAuthType)
--    print("requestSetSpamPrevention(): bSpamPrevention = ", bSpamPrevention);
--    print("requestSetSpamPrevention(): iMinutes = ", iMinutes);
    PermitsCallModuleScript("setSpamPreventionMinutes",iMinutes ~= 0 and iMinutes or 0)
    local szSystemMsg
    local operator = csAuthType == nil and GetS(9745) or GetS(WorldAuthorityConfig.PlayerString[csAuthType])
    if bSpamPrevention then
        if iMinutes == 5 then
            szSystemMsg = GetS(9744, operator,"#cff0000", GetS(30020))
        elseif iMinutes > 0 then
            szSystemMsg = GetS(9744, operator,"#cff0000", tostring(iMinutes) .. GetS(4975))
        else --无限期
            szSystemMsg = GetS(9744, operator,"#cff0000",  GetS(30019))
        end
    else
        szSystemMsg = GetS(9744, operator,"#c30C22C", GetS(3536))
    end
    ClientCurGame:sendChat(szSystemMsg, 1);
end

--[[
    TODO
]]
function SpamPreventionModel:requestSetPlayerMuteWhitelist(iUin)

end
--[[
    屏蔽玩家聊天消息  
    Created on 2019-09-09 at 22:12:18
]]
function SpamPreventionModel:requestMaskPlayersSpeaking(iUin, bMask)
    if not iUin then 
        ShowGameTips("Invalid uin.")
        return 
    end
    local bOldMask = self.m_mSpeakingMasked[iUin]
    local szToast
    if bMask then
        self.m_mSpeakingMasked[iUin] = bMask
        szToast = GetS(9313) -- 已屏蔽
    elseif bOldMask == true then
        self.m_mSpeakingMasked[iUin] = false
        szToast = GetS(9314) -- 已取消屏蔽
    else
        self.m_mSpeakingMasked[iUin] = true
        szToast = GetS(9313)
    end
    self:requestFilterMaskedChatMsgs()
    RoomInteractiveData:UpdateRoomChat();
    ShowGameTips(szToast)
end

function SpamPreventionModel:IsMaskPlayersSpeaking(uin) 
    local bMask = SpamPreventionModel.m_mSpeakingMasked[uin]
    if bMask then
        return true
    else
        return false
    end
end

function IsMaskPlayersSpeaking(uin)
    return SpamPreventionModel:IsMaskPlayersSpeaking(uin) 
end

--[[
    普通房间 对玩家禁言
    Created on 2019-09-09 at 22:13:16
]]
function SpamPreventionModel:requestSetPlayerMute(iUin)
    if not iUin then
        ShowGameTips("Invalid uin.")
        return
    end

    if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
        if IsRoomOwner() then
            local bMute = PermitsCallModuleScript("getPlayerPermits",iUin,CS_PERMIT_MUTE) == 1 and true or false
            local szToast = bMute and GetS(30030) or GetS(30029)
            local content = bMute and GetS(9689) or GetS(9688)
            ClientCurGame:sendChat(content, 1, iUin);
            ShowGameTips(szToast)
            PermitsCallModuleScript("setPlayerMute",iUin)
        end
    else
        local value = PermitsCallModuleScript("getCSPlayerPermits",iUin, CS_PERMIT_MUTE)
        value = value==0 and true or false
        PermitsCallModuleScript("sendCSHostPermitMsg",iUin,CS_PERMIT_MUTE,value)
    end
end

--[[
    获取当前自动禁言的选择
]]
function SpamPreventionModel:requestCurrentSpamPrevention()
    local iSpamMinutes = PermitsCallModuleScript("getSpamPreventionMinutes")
    self.mCallback:displayCurrentSpamPrevention(iSpamMinutes)
end

----------------------------含外部调用----------------------------
--[[
    处理不同设置的回调
    Created on 2019-09-16 at 20:01:57
]]
function SpamPreventionModel:requestNotifySettingsChange()
    self:onNotifySpamPrevetionOptionChange();
end

--[[
    对玩家点击“屏蔽消息”  时，过滤一次聊天信息
    Created on 2019-09-09 at 22:11:48
]]
function SpamPreventionModel:requestFilterMaskedChatMsgs()
    RoomInteractiveData:filterMaskedChatMsgs(self.m_mSpeakingMasked)
end

--[[
    设置防刷屏的UI数据  
    Created on 2019-09-09 at 22:13:28
]]
function SpamPreventionModel:requestSpamPreventionSettings()
    --仅有自动禁言设置的UI更新
    if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() and ClientCurGame then
        self.mCallback:displaySpamPreventionSettings( ClientCurGame.isHost and ClientCurGame:isHost(AccountManager:getUin()) or false );
    else
        local myAuthority = PermitsCallModuleScript("getCSAuthority",AccountManager:getUin())
        if myAuthority and (myAuthority.Type <= CS_AUTHORITY_MANAGER ) then
            self.mCallback:displaySpamPreventionSettings(true);
        else
            self.mCallback:displaySpamPreventionSettings(false);
        end
    end

    self:requestCurrentSpamPrevention()
    self:requestAllMuteState();
end

function SpamPreventionModel:requestAllMuteState()
    local state = (ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType()) and PermitsCallModuleScript("getPlayerPermits",0,CS_PERMIT_MUTE) or PermitsCallModuleScript("getCSPlayerPermits",0,CS_PERMIT_MUTE)
    state = state == 1 and true or false
    self.mCallback:displayAllMuteState(state);
end

--[[
    显示该玩家的屏蔽按钮状态  
    Created on 2019-09-09 at 22:12:38
]]
function SpamPreventionModel:requestPlayersSpeakingMaskState(iUin)
    if not iUin then 
        self.mCallback:displayPlayersSpeakingMaskState(false)
        return
    end
    local bMask = self.m_mSpeakingMasked[iUin]
    if not bMask then
        self.m_mSpeakingMasked[iUin] = false
        bMask = false
    end
    self.mCallback:displayPlayersSpeakingMaskState(bMask)
end

--[[
    显示该玩家的禁言按钮状态  
    Created on 2019-09-09 at 22:12:59
]]
function SpamPreventionModel:requestPlayerMuteState(iUin)
    if not iUin then 
        self.mCallback:displayPlayerMuteState(false)
        return
    end
    self.mCallback:displayPlayerMuteState(PermitsCallModuleScript("getPlayerPermits",iUin,CS_PERMIT_MUTE) == 1 and true or false)
end

function SpamPreventionModel:requestClearSpamHistoryMessages()
    local aMessages = self.m_aMessages
    local iLength = #aMessages
    for i=iLength, 1, -1 do 
        aMessages[i] = nil
    end
    self.m_iLastSendChatTime = 0
end

--[[
    限房主退出房间后调用。清除全禁、自动禁和单独禁的设置。
    Created on 2019-09-19 at 14:54:09
]]
function SpamPreventionModel:requestClearSettings()
    if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
        PermitsCallModuleScript("setPlayerGamePermits",0, 2, CS_PERMIT_MUTE, false)
        PermitsCallModuleScript("clearMutePlayers")
        PermitsCallModuleScript("setSpamPreventionMinutes",0)
    else
        PermitsCallModuleScript("clearMutePlayers")
        PermitsCallModuleScript("setSpamPreventionMinutes",5)
    end
end

function SpamPreventionModel:onGameEvent(arg1)
    -- local ge = GameEventQue:getCurEvent()
end

function SpamPreventionModel:isRoomPlayerMute()
    local szToast
    --房主不禁言
    if IsRoomOwner() then
        return false
    end
    -- 先判断全体禁言功能
    local allmute = (ROOM_SERVER_RENT == ClientMgr:getRoomHostType()) and PermitsCallModuleScript("getCSPlayerPermits",0, CS_PERMIT_MUTE) or PermitsCallModuleScript("getPlayerPermits",0, CS_PERMIT_MUTE)
    if allmute == 1 then
        szToast = GetS(9684)
        ShowGameTips(szToast)
        return true
    end
    -- 在判断个人禁言设置
    local value = (ROOM_SERVER_RENT == ClientMgr:getRoomHostType()) and PermitsCallModuleScript("getCSPlayerPermits",AccountManager:getUin(), CS_PERMIT_MUTE) or PermitsCallModuleScript("getPlayerPermits",AccountManager:getUin(), CS_PERMIT_MUTE)
    if value == 1 then
        szToast = GetS(20622)
        ShowGameTips(szToast)
        return true;
    end
    return false;
end
-- 次函数是给c++调用的
function requestCloudServerSetSpamPrevention(minutes, csAuthType)
	if minutes == 0 then
		SpamPreventionModel:requestSetSpamPrevention(false, minutes, csAuthType )
	else
		SpamPreventionModel:requestSetSpamPrevention(true, minutes, csAuthType)
	end
end
-----------------------------------------------------SpamPreventionModel end-----------------------------------------------------
-----------------------------------------------------SpamPreventionPresenter start-----------------------------------------------------
_G.SpamPreventionPresenter = {

}

--[[
    
    Created on 2019-09-03 at 11:40:23
]]
function SpamPreventionPresenter:init()
    MVPUtils:registerSelfViewModel(self, SpamPreventionView, SpamPreventionModel);
end

SpamPreventionPresenter:init()
-----------------------------------------------------SpamPreventionPresenter end-----------------------------------------------------



-----------------------------------------------------云服检测 start-----------------------------------------------------
--此函数在MpGameSurvive::handleChat2Host 中调用，用于检测客户端刷屏，主要治理脚本直接调用sendChat，非手动输入
--云服禁言规则：
--1.1秒钟只能发一条消息，1秒内收到其他的消息不再转发给房间内其他玩家
--2.检测n秒内，云服收到该玩家的消息m条，超过m条禁言5分钟。 n，m可以设置
--3.连续发送的内容相同1次可发送， 2次不能发送，4次禁言5分钟
function CS_Chat2HostCheck(uin, targetuin, chattype, content)
    print("CS_Chat2HostCheck", uin, targetuin, chattype)
    if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
        return true
    end
    local myAuthority = PermitsCallModuleScript("getCSAuthority",uin)
    --服主 ，管理员
    if myAuthority.Type <= CS_AUTHORITY_MANAGER and myAuthority.Type >= CS_AUTHORITY_ROOM_OWNER then
        print("CS_Chat2HostCheck myAuthority.Type", myAuthority.Type)
        return true
    end

    --普通消息
    if chattype == 0 then
        --该玩家被禁言
        if PermitsCallModuleScript("getCSPlayerPermits",uin, CS_PERMIT_MUTE) == 1 or PermitsCallModuleScript("getCSPlayerPermits",0, CS_PERMIT_MUTE) == 1 then
            return false
        end
    elseif chattype == 1 then --系统消息
        --非管理员 不能发送系统消息
        return false
    end

    --短时间内发送过多消息
    if not g_CS_Chat then
        g_CS_Chat = {}
    end

    if not g_CS_Chat[uin] then
        g_CS_Chat[uin] = {
            chatList = {}, --发送出去的聊天
            receiveList = {}, --host收到的聊天
            waigua = nil, --是否是外挂
            lastContent = "",
            sameContTimes = 0;
        }
    end

    local now = os.time()
    table.insert(g_CS_Chat[uin].receiveList, now)
    if #g_CS_Chat[uin].receiveList > 100 then
        --只保留100条
        table.remove(g_CS_Chat[uin].receiveList, 1)
    end

    if g_CS_Chat[uin].waigua then
        if now - g_CS_Chat[uin].waigua < 5*60 then
            --禁言5分钟
            return false
        end
        g_CS_Chat[uin].waigua = nil
    end

    --2秒内收到消息超过5条以上，判断为外挂
    local last = g_CS_Chat[uin].chatList[#g_CS_Chat[uin].chatList]
    if last then
        local num = #g_CS_Chat[uin].receiveList
        local second = 2
        local max = 5
        if num >= max and now - g_CS_Chat[uin].receiveList[num-max+1] <= second then
            g_CS_Chat[uin].waigua = now
            print("CS_Chat2HostCheck waigua", now)
            --通知玩家
            ClientCurGame:sendChat(GetS(20622), 1, uin);
            return false
        end

        --1秒只能发一次言
        if now - last < 1 then
            return false
        end
    end

    --连续发送的内容相同1次可发送， 2次不能发送，4次判断为外挂
    if g_CS_Chat[uin].lastContent == content then
        g_CS_Chat[uin].sameContTimes = g_CS_Chat[uin].sameContTimes + 1

        if g_CS_Chat[uin].sameContTimes >= 2 then
            if g_CS_Chat[uin].sameContTimes >= 4 then
                g_CS_Chat[uin].waigua = now
                print("CS_Chat2HostCheck waigua", now)
                --通知玩家
                ClientCurGame:sendChat(GetS(20622), 1, uin);
            end
            return false
        end
    else
        g_CS_Chat[uin].sameContTimes = 0
    end
    

    g_CS_Chat[uin].lastContent = content
    table.insert(g_CS_Chat[uin].chatList, now)
    if #g_CS_Chat[uin].chatList > 100 then
        --只保留100条
        table.remove(g_CS_Chat[uin].chatList, 1)
    end
    return true
end
-----------------------------------------------------云服检测 end-----------------------------------------------------