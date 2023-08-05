RentPermitCtrl = {
	subRoomPanelShow = false,
	rentRoomInfo = {},
 	t_btnConfig = {
		{bit=1, name=9608,mapPermitId=ENABLE_DESTROYBLOCK},
		{bit=2, name=9609,mapPermitId=ENABLE_PLACEBLOCK},
		{bit=4, name=9610,mapPermitId=ENABLE_PICKUP},
		{bit=3, name=9612,mapPermitId=ENABLE_USEITEM},
		{bit=5, name=9611,mapPermitId=ENABLE_ATTACK},
		{bit=13, name=9674,mapPermitId=ENABLE_ATTACK},
	},	
	noticeOnlyAShow = false,	--公告是否只提示一次

	--子权限stringID
	RentSubPermitsItemTitle = {
		{open = 9662, close = 9663},
		{open = 9664, close = 9665},
		{open = 9666, close = 9667},
		{open = 9668, close = 9669},
		{open = 9670, close = 9671},
		{open = 9672, close = 9673}
	},

	noticeInfo = {}, --记录公告信息 
} --租赁服权限逻辑类

--玩家权限按钮UI显示
function RentPermitCtrl:SetPlayerPermitUI(uin,pos,value)
	local btn_num = 5
	local ui_name = "RoomUIFrameFuncOptionCSAuthorityBtn"

	for i = 1,btn_num do
		local permit_btn = getglobal(ui_name..i)
		local tick_pic = getglobal(permit_btn:GetName().."Tick")
		local uin_orginal = permit_btn:GetParentFrame():GetClientUserData(0);
		local pos_orginal = permit_btn:GetClientUserData(0)

		if uin  == uin_orginal and pos == pos_orginal then
			if  value == true then
				tick_pic:Show()
			else
				tick_pic:Hide()
			end
		end
	end

	if pos == CS_PERMIT_OPERATE_CLEAR then
		if PermitsCallModuleScript("getCSPlayerPermits",uin,CS_PERMIT_OPERATE_CLEAR) == 0 then
			getglobal("RoomUIFrameFuncOptionPermitSwitchBtnNormal"):SetTextureTemplate("TemplateBkg24");
			getglobal("RoomUIFrameFuncOptionPermitSwitchBtnPushedBG"):SetTextureTemplate("TemplateBkg24");
		else
			getglobal("RoomUIFrameFuncOptionPermitSwitchBtnNormal"):SetTextureTemplate("TemplateBkg23");
			getglobal("RoomUIFrameFuncOptionPermitSwitchBtnPushedBG"):SetTextureTemplate("TemplateBkg23");
		end
	end
end

--判断是否是租赁服房间
function RentPermitCtrl:IsRentRoom()
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	else
		return true
	end
end

function RentPermitCtrl:IsQuickUpRentRoom()
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	else
		local room_info = RentPermitCtrl.rentRoomInfo			
		if room_info and room_info.isOneKeyRentRoom then
			return true
		else
			return false
		end
	end
end

function RentPermitCtrl:IsQuickUpRentDebugRoom()
	if self:IsQuickUpRentRoom() then
		local room_info = RentPermitCtrl.rentRoomInfo			
		if room_info and room_info.isOneKeyRentRoom then
			return room_info.isRentDebug
		end
	end
	return false
end

function RentPermitCtrl:IsPersonalQuickUpRentRoom()
	if self:IsQuickUpRentRoom() then
		local room_info = RentPermitCtrl.rentRoomInfo			
		if room_info and room_info.personal then
			return room_info.personal == 1
		end
	end
	return false
end

function RentPermitCtrl:IsSelfPersonalQuickUpRentRoom(checkTeam)
	if self:IsPersonalQuickUpRentRoom() then
		local room_info = RentPermitCtrl.rentRoomInfo			
		if room_info then
			if not checkTeam then
				return room_info.hostUin == AccountManager:getUin()
			else
				local teamid = tonumber(room_info.teamid) or 0
				return teamid > 0 and room_info.hostUin == AccountManager:getUin()
			end
		end
	end
	return false
end

function RentPermitCtrl:IsActivityRentRoom()
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	else
		local room_info = RentPermitCtrl.rentRoomInfo			
		if room_info and "string" == type(room_info.act_key) then
			return "" ~= room_info.act_key
		end
	end

	return false
end

function RentPermitCtrl:IsSocialRentRoom()
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	else
		local room_info = RentPermitCtrl.rentRoomInfo			
		if room_info and room_info.fromowid and GetInst("SocialHallDataMgr") then
			return GetInst("SocialHallDataMgr"):IsSocialMap(room_info.fromowid)
		end
	end

	return false
end

--租赁服房间权限UI显示
function RentPermitCtrl:RoomPermissionShow()
	local ui_name = "RoomUIFrameSetOption"
	local roomPermits_toggle = getglobal("RoomPermissionRentToggle")
	local slider_plane = getglobal(ui_name.."Plane")
	--判断是否是租赁服
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		slider_plane:SetHeight(884)
		getglobal("RoomUIFrameSetOptionNotice"):Hide()
	else
		RentPermitCtrl:ShowRentNotice()
	end
	roomPermits_toggle:Show()

    self.subRoomPanelShow = false
	self:SubPermitPanelState(self.subRoomPanelShow)
	self:RoomSubPermitShow()
	--显示其他选项的ui显示
	RentPermitCtrl:RoomOtherPermitShow()
	RentPermitCtrl:MusicSettingShow();
end

function RentPermitCtrl:MusicSettingShow()
	-- 音乐播放器
	local ui_musicPlayer = getglobal("RoomUIFrameSetOptionMusicPlayer")
	if GetInst("QQMusicPlayerManager") and GetInst("QQMusicPlayerManager"):IsMusicPlayerOpened() then
		ui_musicPlayer:Show()
	else
		ui_musicPlayer:Hide()
	end
	local spamPreventionView = getglobal("RoomUIFrameSetOptionSpamPrevention");
	if getglobal("RoomUIFrameSet"):IsShown() then
		if spamPreventionView:IsShown() then
			-- ui_musicPlayer:SetPoint("top","RoomUIFrameSetOptionSpamPrevention","bottom",0,10)
		else
			-- ui_musicPlayer:SetPoint("top","RoomUIFrameSetOptionBlacklist","bottom",0,10)
		end
	end

	-- 初始化值
	if GetInst("QQMusicPlayerManager") and GetInst("QQMusicPlayerManager"):IsMusicPlayerOpened() then
		local openstatus = GetInst("QQMusicPlayerManager"):GetOpenStatus()
		SetSwitchBtnState("MusicPlayerSwitch", openstatus)
		local uiEnable = GetInst("QQMusicPlayerManager"):IsShowInsertUI()
		local checkBoxUI = getglobal("RoomUIFrameSetOptionMusicPlayerAllowAdd")
		local checkBoxUIText = getglobal("RoomUIFrameSetOptionMusicPlayerAllowAllText")
		local switch = getglobal("MusicPlayerSwitch")
		
		if uiEnable then
			checkBoxUI:Show()
			checkBoxUIText:Show()
			switch:Show()
			if 1 == openstatus then
				checkBoxUI:SetGray(false)
				checkBoxUIText:SetTextColor(61, 69, 70)
			elseif 2 == openstatus then
				checkBoxUI:SetGray(true)
				checkBoxUIText:SetTextColor(180, 180, 180)
			end
			local isAllow = GetInst("QQMusicPlayerManager"):GetIsAllowAddMusic()
			RoomUIFrameSet_CheckBoxViewUpdate(checkBoxUI, isAllow)
		else
			checkBoxUI:Hide()
			checkBoxUIText:Hide()
			switch:Hide()
			ui_musicPlayer:Hide()
			if CheckIsNeeModify() then
				ui_musicPlayer:Show()
			end
		end
		SpamPreventionPresenter:displayRoomSettingsTitleTemplateWidth("RoomUIFrameSetOptionMusicPlayerTitle", openstatus==1 and 37039 or 37038);
	end
end

--房间权限子权限是否显示
function RentPermitCtrl:SubPermitPanelState(state)
	local ui_name = "RoomUIFrameSetOption"
	local roomPermits_toggle = getglobal("RoomPermissionRentToggle")
	local close_pic = getglobal(roomPermits_toggle:GetName().."Close")
	local open_pic = getglobal(roomPermits_toggle:GetName().."Open")
	local subPermits_panel = getglobal(ui_name.."RentSubPermits")
    local disableItem_panel = getglobal(ui_name.."DisableItem")
    local voiceItem_panel = getglobal(ui_name.."RoomVoice")
    local slider_plane = getglobal(ui_name.."Plane")

    local createMode = false;
	if ClientCurGame:isInGame() and CurWorld and CurWorld:isGodMode() then    --LLTODO:如果在游戏中, 且是创造模式
		createMode = true;
	end

	if state == true then
		slider_plane:SetHeight(1200)
        subPermits_panel:SetPoint("top", ui_name.."RoomPermits", "bottom", 0, 0);
        if CurWorld and CurWorld:ignoreSave() and not createMode then
            voiceItem_panel:SetPoint("top", subPermits_panel:GetName(), "bottom", 0, 10);
        else
            disableItem_panel:SetPoint("top", subPermits_panel:GetName(), "bottom", 0, 0);
        end

		open_pic:Hide()
		close_pic:Show()
		subPermits_panel:Show()

		if CheckIsNeeModify() then
			disableItem_panel:SetPoint("top", subPermits_panel:GetName(), "bottom", 0, 10)
			getglobal("RoomUIFrameSetOptionRandSpawn"):SetPoint("top", disableItem_panel:GetName(), "bottom", 0, 10)
			-- voiceItem_panel:SetPoint("top", "RoomUIFrameSetOptionRandSpawn", "bottom", 0, 10)
		end

	else
        slider_plane:SetHeight(914)
        if CurWorld and CurWorld:ignoreSave() and not createMode then
            voiceItem_panel:SetPoint("top", ui_name.."RoomPermits", "bottom", 0, 10);
        else
            disableItem_panel:SetPoint("top", ui_name.."RoomPermits", "bottom", 0, 0);
        end

		open_pic:Show()
		close_pic:Hide()
		subPermits_panel:Hide()

		if CheckIsNeeModify() then
			slider_plane:SetHeight(998)
			disableItem_panel:SetPoint("top", ui_name.."RoomPermits", "bottom", 0, 10)
			getglobal("RoomUIFrameSetOptionRandSpawn"):SetPoint("top", disableItem_panel:GetName(), "bottom", 0, 10)
			-- voiceItem_panel:SetPoint("top", "RoomUIFrameSetOptionRandSpawn", "bottom", 0, 10)
		end
	end
end

local getWolrdPermit = function(bit)
	if CurWorld and CurWorld.isGameMakerRunMode and CurWorld:isGameMakerRunMode() then
		if WorldMgr and WorldMgr.getBaseSettingManager then
			local manager = WorldMgr:getBaseSettingManager()
			if manager and manager:getPlayerPermit(bit) then
				return true
			end
		end
		return false
	end
	return true
end

--显示租赁服房间权限子权限UI显示
function RentPermitCtrl:RoomSubPermitShow()
	local ui_name = "RoomUIFrameSetOptionRentSubPermitsItem"

	SpamPreventionPresenter:displayRoomSettingsTitleTemplateWidth("RoomUIFrameSetOptionRoomPermitsTitle", 9660);

	for i = 1,#self.t_btnConfig do
		local permit_switch = getglobal(ui_name..i.."Switch")
		local permit_name = getglobal(ui_name..i.."TitleName")

		permit_switch:SetClientUserData(0, self.t_btnConfig[i].bit);
		permit_switch:SetClientID(i)
		permit_name:SetText(GetS(self.t_btnConfig[i].name),61,69,70)
		local permit_value = RentPermitsMgr:GetPermitValue(0,self.t_btnConfig[i].bit)
		local permit_can_operate = RentPermitsMgr:GetPermitCanShow(AccountManager:getUin(),self.t_btnConfig[i].bit)
		if getWolrdPermit(self.t_btnConfig[i].mapPermitId) then
			permit_switch:Enable()
			SetSwitchBtnState(permit_switch:GetName(),permit_value)
		else
			SetSwitchBtnState(permit_switch:GetName(),0)
			permit_switch:Disable()
		end
		permit_value = permit_value == 0 and true or false

		local permit_title = getglobal(ui_name..i.."Title")
		if permit_value or not getWolrdPermit(self.t_btnConfig[i].mapPermitId) then
			SpamPreventionPresenter:displayRoomSettingsTitleTemplateWidth(permit_title:GetName(),RentPermitCtrl.RentSubPermitsItemTitle[i].close,true)
		else
			SpamPreventionPresenter:displayRoomSettingsTitleTemplateWidth(permit_title:GetName(),RentPermitCtrl.RentSubPermitsItemTitle[i].open,true)
		end

		if permit_can_operate then
			permit_switch:Show()
		else
			permit_switch:Hide()
		end
	end

end

--显示其他的整个房间权限信息显示
function RentPermitCtrl:RoomOtherPermitShow(clickedBtn)
	--禁用危险品
	self:RoomPermitCommonCallback("RoomDisableItemSwitch",WorldAuthorityConfig.AuthorityType.UseDangerousGoods)

	local permit_value = RentPermitsMgr:GetPermitValue(0,WorldAuthorityConfig.AuthorityType.UseDangerousGoods)
	permit_value = permit_value == 0 and true or false

	if  permit_value then	--不禁用
		SpamPreventionPresenter:displayRoomSettingsTitleTemplateWidth("RoomUIFrameSetOptionDisableItemTitle", 873);
	else				--禁用危险物品
		SpamPreventionPresenter:displayRoomSettingsTitleTemplateWidth("RoomUIFrameSetOptionDisableItemTitle", 874);
	end

	--聊天气泡窗
	UpdateRoomChatBubbleTitle()
	UpdateNewFrameObjs()
	
	--黑名单
	local permit_can_operate = RentPermitsMgr:GetPermitCanShow(AccountManager:getUin(),WorldAuthorityConfig.AuthorityType.BlackList)
	if permit_can_operate then
		getglobal("RoomBlacklistView"):Show()
	else
		getglobal("RoomBlacklistView"):Hide()
	end

	--禁言
	SpamPreventionPresenter:requestSpamPreventionSettings();
	self:RoomPermitCommonCallback("AllMuteSwitch",WorldAuthorityConfig.AuthorityType.Banned)

	--聊天气泡窗口
	self:RoomPermitCommonCallback("RoomUIFrameSetOptionChatBubbleSwitch",WorldAuthorityConfig.AuthorityType.ChatBubble)

    -- 按钮点击的回调中不需要重新设置界面布局
    if clickedBtn then return end

	--创造模式的随机出生点 -关闭
	local randSpawnFrame 		= getglobal("RoomUIFrameSetOptionRandSpawn");
    local roomVoiceFrame		= getglobal("RoomUIFrameSetOptionRoomVoice");
    local disableItmeFrame      = getglobal("RoomUIFrameSetOptionDisableItem");
    if GYouMeVoiceMgr:isInit() and YouMeVocieCanEnable() then
		roomVoiceFrame:Show();
	else
		roomVoiceFrame:Hide();
	end

    -- 开发者工具页面开启玩法模式退出后重置按钮时，隐藏禁用危险物品和随机出生点按钮
    if CurWorld:ignoreSave() then
        randSpawnFrame:Hide()
        disableItmeFrame:Hide()
        -- roomVoiceFrame:SetPoint("top", "RoomUIFrameSetOptionRoomPermits", "bottom", 0, 10)
    else
        randSpawnFrame:Show()
        disableItmeFrame:Show()
        -- roomVoiceFrame:SetPoint("top", "RoomUIFrameSetOptionRandSpawn", "bottom", 0, 10)
    end

    if ClientCurGame:isInGame() and CurWorld:isGodMode() then
        print("kekeke randSpawnFrame Hide");
        randSpawnFrame:Hide();
        disableItmeFrame:Show()
        -- roomVoiceFrame:SetPoint("top", "RoomUIFrameSetOptionDisableItem", "bottom", 0, 10);
    elseif not CurWorld:ignoreSave() then
        print("kekeke randSpawnFrame Show");
        randSpawnFrame:Show();
        -- roomVoiceFrame:SetPoint("top", "RoomUIFrameSetOptionRandSpawn", "bottom", 0, 10);
    end

	if CheckIsNeeModify() then
		local showState = disableItmeFrame:IsShown()
		if not showState then
			disableItmeFrame:Show()
			if not showState then
				getglobal("RoomDisableItemSwitch"):Hide()
			end
			-- disableItmeFrame:SetPoint("top", "RoomUIFrameSetOptionRoomPermits", "bottom", 0, 10)
		end

		local showState1 = randSpawnFrame:IsShown()
		if not showState1 then
			randSpawnFrame:Show()
			if not showState1 then
				getglobal("RandSpawnModeSwitch"):Hide()
			end
			if not PermitsCallModuleScript("getRandSpawnMode") then	--不随机
				SpamPreventionPresenter:displayRoomSettingsTitleTemplateWidth("RoomUIFrameSetOptionRandSpawnTitle", 6125);
			else										--随机
				SpamPreventionPresenter:displayRoomSettingsTitleTemplateWidth("RoomUIFrameSetOptionRandSpawnTitle", 6124);
			end
			-- randSpawnFrame:SetPoint("top", "RoomUIFrameSetOptionDisableItem", "bottom", 0, 10)
		end

		-- roomVoiceFrame:SetPoint("top", "RoomUIFrameSetOptionRandSpawn", "bottom", 0, 10)
	end

	UpdateRoomSetVoiceInfo()
end

--租赁服房间权限下拉按钮点击
function RentPermitCtrl:RoomPermitsToggleClicked()
	if RentPermitCtrl.subRoomPanelShow then
		RentPermitCtrl.subRoomPanelShow = false
	else
		RentPermitCtrl.subRoomPanelShow = true
	end

	RentPermitCtrl:SubPermitPanelState(RentPermitCtrl.subRoomPanelShow)
	--todo refresh RoomUIFrameSet layout
	RoomUIFrameSetLayout()
end

--房间权限子权限按钮点击
function RentPermitCtrl:SubPermitBtnClicked()
	local permit_pos = this:GetClientUserData(0)
	local id = this:GetClientID()
	if permit_pos == nil or permit_pos < 0 then
		return
	end

	local permit_value = RentPermitsMgr:GetPermitValue(0,permit_pos)
	permit_value = permit_value == 0 and true or false
	local callback = function(uin,pos,value)
		local ui_name = "RoomUIFrameSetOptionRentSubPermitsItem"..id
		RentPermitCtrl:RoomPermitCommonCallback(ui_name.."Switch",pos)
		local title = "("..GetS(9613)..")" .. GetS(RentPermitCtrl.t_btnConfig[id].name)
		if value then
			ClientCurGame:sendChat(title..": 开", 1);
		else
			ClientCurGame:sendChat(title..": 关", 1);
		end
	end

	RentPermitsMgr:SetPermitValue(0,permit_pos,permit_value,callback)
	RentPermitsMgr:SetPermitValue(AccountManager:getUin(),permit_pos,permit_value,callback)
end

--租赁服房间权限回调公共函数
function RentPermitCtrl:RoomPermitCommonCallback(ui_switch,pos)
	local permit_switch = getglobal(ui_switch)
	local permit_value = RentPermitsMgr:GetPermitValue(0,pos)
	-- 14号位 聊天气泡的 ver0316 气泡开关使用个人的设置
	if pos == 14 then
		permit_value = RentPermitsMgr:GetPermitValue(AccountManager:getUin(),pos)
	end
	local permit_can_operate = RentPermitsMgr:GetPermitCanShow(AccountManager:getUin(),pos)

	if permit_can_operate then
		permit_switch:Show()
		SetSwitchBtnState(permit_switch:GetName(),permit_value)
	else
		permit_switch:Hide()
	end
end

--租赁服房间权限禁止使用危险品
function RentPermitCtrl:SetDisableItemSwitchState(state)
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	end

	local permit_pos = WorldAuthorityConfig.AuthorityType.UseDangerousGoods
	local permit_value = RentPermitsMgr:GetPermitValue(0,permit_pos)
	permit_value = permit_value == 0 and true or false

	RentPermitsMgr:SetPermitValue(0,permit_pos,permit_value,function (uin,pos,value)
		RentPermitCtrl:RoomPermitCommonCallback("RoomDisableItemSwitch",pos)

		if not value then	--不禁用
			SpamPreventionPresenter:displayRoomSettingsTitleTemplateWidth("RoomUIFrameSetOptionDisableItemTitle", 873);
		else				--禁用危险物品
			SpamPreventionPresenter:displayRoomSettingsTitleTemplateWidth("RoomUIFrameSetOptionDisableItemTitle", 874);
		end

	--	SetAllDisableItemPermits(value);
		ShortCutFrame_UpdateAllGrids();
		--if CurWorld:ignoreSave() then
		--	ShowGameTips(GetS(4969));
		--end

	end)

	return true
end

--租赁服房间权限禁言
function RentPermitCtrl:SetAllMute(state)
	local permit_pos = CS_PERMIT_MUTE
	local permit_value = RentPermitsMgr:GetPermitValue(0,permit_pos)
	permit_value = permit_value == 0 and true or false

	local callback = function (uin,pos,value)
		RentPermitCtrl:RoomPermitCommonCallback("AllMuteSwitch",pos)
		local szSystemMsg
		if value then
			szSystemMsg = GetS(30021)
		else
			szSystemMsg = GetS(30022)
		end
		ClientCurGame:sendChat(szSystemMsg, 1);
	end

	RentPermitsMgr:SetPermitValue(0,permit_pos,permit_value,callback)
end

--聊天气泡窗口状态设置
function RentPermitCtrl:SetChatBubbleSwitchState(state, isFirstCome)
	local permit_pos = CS_PERMIT_ChatBubble
	--local permit_value = RentPermitsMgr:GetPermitValue(0,permit_pos)
	local permit_value = state == 1 and true or false

	local callback = function (uin,pos,value)
		--RentPermitCtrl:RoomPermitCommonCallback("RoomUIFrameSetOptionChatBubbleSwitch",pos)
		-- local szSystemMsg
		-- if value then
		-- 	szSystemMsg = GetS(111603)
		-- else
		-- 	szSystemMsg = GetS(111602)
		-- end
		
		-- if not isFirstCome then
		-- 	-- ClientCurGame:sendChat(szSystemMsg, 1);
		-- 	GameEventQue:postChatEvent(1, nil, szSystemMsg)
		-- end
	end
	RentPermitsMgr:SetPermitValue(0, permit_pos, permit_value, callback, true) -- 设置房间的
	RentPermitsMgr:SetPermitValue(AccountManager:getUin(), permit_pos, permit_value, callback, false) -- 设置个人的
end

--租赁服个人权限：加入黑名单那
function RentPermitCtrl:AddPlayerToBlacklist()
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	end

	local callback = function(ret,data)
		print("data=",data)
		self:RespAddPlayerToBlacklist(ret,data)
	end

	local briefInfo = RoomInteractiveData.curOptionFuncBriefInfo;
	print("briefInfo",briefInfo)
	if briefInfo.uin == nil  then return end
	local permit_type = RentPermitsMgr:GetPermitType(briefInfo.uin)
	local permit_type_self = RentPermitsMgr:GetPermitType(AccountManager:getUin())

	--加入黑名单的条件：自己又权限，被操作人是普通玩家
	if permit_type == WorldAuthorityConfig.PlayerType.Normal and
			permit_type_self < WorldAuthorityConfig.PlayerType.Normal  then

	else
		print("没有权限去操作")
		MessageBox(5, GetS(9627), function(btn, uin)
			if btn == 'left' then
				if briefInfo then
					--TODO 接入uin 和 room_id
					local roomId = ClientMgr:getCurrentRentRoomId();
					local room_uin = ClientMgr:getCurrentRentRoomUin();
					CloudServerNetMgr:ServerAddBlackPlayer(roomId,briefInfo.uin,false,callback,briefInfo.uin,room_uin)
				end
			end
		end, briefInfo.uin);
		return true
	end


	MessageBox(5, GetS(9323), function(btn, uin)
		if btn == 'left' then
			if briefInfo then
				--TODO 接入uin 和 room_id
				local roomId = ClientMgr:getCurrentRentRoomId();
				local room_uin = ClientMgr:getCurrentRentRoomUin();
				CloudServerNetMgr:ServerAddBlackPlayer(roomId,briefInfo.uin,false,callback,briefInfo.uin,room_uin)
			end
		end
	end, briefInfo.uin);

	return true
end

--租赁服个人权限加入黑名单回调
function RentPermitCtrl:RespAddPlayerToBlacklist(ret,data)
	if ret and ret.ret ==0 then
		--成功将成员加入到黑名单中
		--踢掉该成员
		if data == nil then return end
		local permit_type_self = RentPermitsMgr:GetPermitType(AccountManager:getUin())
		RentPermitCtrl:KickPlayer(data,2,"", "", permit_type_self)
	else

	end

end

--租赁服个人权限提出黑名单  tpye =1：直接踢人，2：黑名单踢人
function RentPermitCtrl:KickPlayer(uin,type, kickname, kickername, kickertype)
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	end
	if uin  == nil then return false end
	local kick_type = type == nil and 1 or type
	if kickname ~= nil and kickname ~= "" and kickertype > CS_AUTHORITY_NULL and kickername ~= nil then
		local text = GetS(500, kickname);
		ShowGameTips(text, 3);
		text = GetS(9676, GetS(WorldAuthorityConfig.PlayerString[kickertype]),kickername, kickname);
		ClientCurGame:sendChat(text, 1);
	end
	kickertype = kickertype == nil and CS_AUTHORITY_ROOM_OWNER or kickertype
	if kick_type == 1 then
		local permit_type = RentPermitsMgr:GetPermitType(uin)
		local permit_type_self = RentPermitsMgr:GetPermitType(AccountManager:getUin())
		if (permit_type == WorldAuthorityConfig.PlayerType.Normal and
				permit_type_self < WorldAuthorityConfig.PlayerType.Normal) or
				permit_type_self == WorldAuthorityConfig.PlayerType.Owner  then
			WorldMgr:LeaveRentRoom(uin,kickertype)
		end
	elseif kick_type == 2 then
		WorldMgr:LeaveRentRoom(uin,kickertype)
	end
	return true
end

--租赁服个人权限禁言玩家
function RentPermitCtrl:MutePlayer(uin)
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		 if IsRoomOwner() then
            local bMute = PermitsCallModuleScript("getPlayerPermits",uin,CS_PERMIT_MUTE) == 1 and true or false
            local szToast = bMute and GetS(30030) or GetS(30029)
            local content = bMute and GetS(9689) or GetS(9688)
            ClientCurGame:sendChat(content, 1, uin);
            ShowGameTips(szToast)
			PermitsCallModuleScript("setPlayerMute",uin)
        end
		return false
	end

	local permit_type = RentPermitsMgr:GetPermitType(uin)
	local permit_type_self = RentPermitsMgr:GetPermitType(AccountManager:getUin())

	if (permit_type == WorldAuthorityConfig.PlayerType.Normal and
			permit_type_self < WorldAuthorityConfig.PlayerType.Normal) or
			permit_type_self == WorldAuthorityConfig.PlayerType.Owner  then

		--local permit_pos = WorldAuthorityConfig.AuthorityType.Banned
		local permit_value = RentPermitsMgr:GetPermitValue(uin,CS_PERMIT_MUTE)
		permit_value = permit_value == 0 and true or false

		RentPermitsMgr:SetPermitValue(uin,CS_PERMIT_MUTE,permit_value,function(uin,pos,value)
			local option_btn = getglobal("RoomUIFrameFuncOption")
			local mute_btn = getglobal(option_btn:GetName().."MuteBtn")
			local mute_text = getglobal(mute_btn:GetName().."Name")
			local iUin = option_btn:GetClientID()
			if iUin ~= uin then return end

			if value == true then
				ShowGameTips(GetS(30029))
				getglobal("RoomUIFrameFuncOptionMuteBtnNormal"):ChangeTextureTemplate("TemplateBkg23");
		        getglobal("RoomUIFrameFuncOptionMuteBtnPushedBG"):ChangeTextureTemplate("TemplateBkg23");
		        getglobal("RoomUIFrameFuncOptionMuteBtnIcon"):SetTexUV("icon_chat_close");
		        mute_text:SetText(GetS(30029));
				ClientCurGame:sendChat(GetS(9688), 1, uin);
			else
				ShowGameTips(GetS(30030))
				getglobal("RoomUIFrameFuncOptionMuteBtnNormal"):ChangeTextureTemplate("TemplateBkg24");
		        getglobal("RoomUIFrameFuncOptionMuteBtnPushedBG"):ChangeTextureTemplate("TemplateBkg24");
		        getglobal("RoomUIFrameFuncOptionMuteBtnIcon"):SetTexUV("icon_chat");
		        mute_text:SetText(GetS(20614));
				ClientCurGame:sendChat(GetS(9689), 1, uin);
			end
		end)
	end
	return true
end

--显示个人禁言按钮状态
function RentPermitCtrl:SetPlayerMuteBtnState(uin)
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	end

	local option_btn = getglobal("RoomUIFrameFuncOption")
	local mute_btn = getglobal(option_btn:GetName().."MuteBtn")
	local mute_text = getglobal(mute_btn:GetName().."Name")
	local mute_pic = getglobal(mute_btn:GetName().."Normal")

	if uin == nil or uin == AccountManager:getUin() then
		mute_btn:Disable()
		mute_pic:SetGray(true)
		return
	end

	local permit_type = RentPermitsMgr:GetPermitType(uin)
	local permit_type_self = RentPermitsMgr:GetPermitType(AccountManager:getUin())

	local permit_pos = WorldAuthorityConfig.AuthorityType.Banned
	local permit_value = RentPermitsMgr:GetPermitValue(uin,permit_pos)



	if permit_value == 1 then
		getglobal("RoomUIFrameFuncOptionMuteBtnNormal"):ChangeTextureTemplate("TemplateBkg23");
        getglobal("RoomUIFrameFuncOptionMuteBtnPushedBG"):ChangeTextureTemplate("TemplateBkg23");
        getglobal("RoomUIFrameFuncOptionMuteBtnIcon"):SetTexUV("icon_chat_close");
		mute_text:SetText(GetS(30029))
	else

		if (permit_type == WorldAuthorityConfig.PlayerType.Normal and
				permit_type_self < WorldAuthorityConfig.PlayerType.Normal) or
				permit_type_self == WorldAuthorityConfig.PlayerType.Owner  then
			getglobal("RoomUIFrameFuncOptionMuteBtnNormal"):ChangeTextureTemplate("TemplateBkg24");
	        getglobal("RoomUIFrameFuncOptionMuteBtnPushedBG"):ChangeTextureTemplate("TemplateBkg24");
	        getglobal("RoomUIFrameFuncOptionMuteBtnIcon"):SetTexUV("icon_chat");
			mute_text:SetText(GetS(20614))
		else
			getglobal("RoomUIFrameFuncOptionMuteBtnNormal"):ChangeTextureTemplate("TemplateBkg24");
	        getglobal("RoomUIFrameFuncOptionMuteBtnPushedBG"):ChangeTextureTemplate("TemplateBkg24");
	        getglobal("RoomUIFrameFuncOptionMuteBtnIcon"):SetTexUV("icon_chat");
			mute_text:SetText(GetS(20614))
		end
	end

	if (permit_type == WorldAuthorityConfig.PlayerType.Normal and
			permit_type_self < WorldAuthorityConfig.PlayerType.Normal) or
			permit_type_self == WorldAuthorityConfig.PlayerType.Owner  then

		mute_btn:Enable()
		mute_pic:SetGray(false)
	else
		mute_btn:Disable()
		mute_pic:SetGray(true)
	end

	return true
end

--租赁服黑名单界面
function RentPermitCtrl:ShowRentBlacklistPanel()
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	end

	local roomId = ClientMgr:getCurrentRentRoomId();
	local room_uin = ClientMgr:getCurrentRentRoomUin();
	local data = {
		room_id = roomId,
		room_uin = room_uin,
	}
	GetInst("UIManager"):Open("CloudServerBlackList",data);
	return true
end

--租赁服公告
function RentPermitCtrl:ShowRentNotice()
	local ui_notice = getglobal("RoomUIFrameSetOptionNotice")
	local ui_title = getglobal(ui_notice:GetName().."Title")
	local ui_notice_text = getglobal(ui_notice:GetName().."EditDefaultTxt")
	local ui_notice_edit = getglobal(ui_notice:GetName().."Edit")
	
	--设置界面 举报公告按钮
	local ui_report = getglobal(ui_notice:GetName().."Report")
	ui_report:Hide()

	-- ui_notice:SetPoint("top","RoomUIFrameSetOptionSpamPrevention","bottom",0,10)
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		ui_notice:Hide()
		return
	else
		ui_notice:Show()
		if CheckIsNeeModify() then
			local room_info = RentPermitCtrl.rentRoomInfo			
			if room_info and room_info.isOneKeyRentRoom then
				ui_notice:Hide()
				return
			end
		end
	end

	ui_notice_edit:Show()

	--TODO 加权限判断去显示公告修改界面 超管和房主可以显示公告修改界面
	local permit_type = RentPermitsMgr:GetPermitType(AccountManager:getUin())
	-- 音乐播放器
	local ui_musicPlayer = getglobal("RoomUIFrameSetOptionMusicPlayer")

	if  permit_type >= CS_AUTHORITY_MANAGER then
		-- ui_notice:SetPoint("top","RoomUIFrameSetOptionBlacklist","bottom",0,0)
		ui_title:SetText(GetS(9577), 61, 69, 70);
		ui_notice:Show()
		ui_notice_edit:Hide()
		
		if permit_type == CS_AUTHORITY_MANAGER then
			-- ui_notice:SetPoint("top","RoomUIFrameSetOptionSpamPrevention","bottom",0,10)
		end
		
		-- 这里return的话 就显示不了公告了 公告都不请求了
		-- return
	end
	if GetInst("QQMusicPlayerManager") and GetInst("QQMusicPlayerManager"):IsMusicPlayerOpened() then
		-- ui_notice:SetPoint("top","RoomUIFrameSetOptionMusicPlayer","bottom",0,10)
	end

	local myAuthority = PermitsCallModuleScript("getCSAuthority",AccountManager:getUin())
	if myAuthority and (myAuthority.Type <= CS_AUTHORITY_MANAGER ) then
		-- ui_notice:SetPoint("top","RoomUIFrameSetOptionChatBubble","bottom",0,10)
	end

	local roomId = ClientMgr:getCurrentRentRoomId()
	local room_uin = ClientMgr:getCurrentRentRoomUin()

	local callback = function(ret)
		print(ret)
		if ret and ret.ret == 0 then
			self.noticeInfo = ret

			if ret.notice ~= nil and ret.notice ~= "" then
				local noticestring = ns_http.func.url_decode(ret.notice)
				ui_notice_text:SetText(noticestring)

				if IsCSNoticeInLock(ret.notice_lock_time) then
					--被封禁了 就不要显示公告了 
					ui_notice_text:Hide()
					ui_report:Hide()
					return
				end

				ui_notice_text:Show()
			else
				ui_notice_text:SetText("")
			end
		else
			ns_error_msg.show( ret )
		end
	end
	CloudServerNetMgr:GetNotice(roomId,callback,nil,room_uin)

	ui_title:SetText(GetS(9577), 61, 69, 70);
end

function RentPermitCtrl:OpenNoticeEditBtnClick()
	local room_info = RentPermitCtrl.rentRoomInfo
	if room_info and room_info.notice_enter_report == 1 then
		--入池了 就不能修改公告了
		ShowGameTips(GetS(9806))
		return
	end

	if room_info and room_info.isOneKeyRentRoom then
		return
	end

	if self.noticeInfo and next(self.noticeInfo) then
		if IsCSNoticeInLock(self.noticeInfo.notice_lock_time) then
			--被封禁了 就不要显示公告了 
			-- local leftTime = self.noticeInfo.notice_lock_time - getServerTime()
			-- local day = math.ceil(leftTime / (3600*24))
			ShowGameTips(GetS(9788, os.date("%Y-%m-%d %H:%M", self.noticeInfo.notice_lock_time)))
			return
		end
	end
	getglobal("CloudServerNotice"):Show()
end

function RentPermitCtrl:CloseNoticeEditBtnClick()
	getglobal("CloudServerNotice"):Hide()
end

--公告详情界面显示
function RentPermitCtrl:CloudServerNotice_OnShow()
	getglobal("CloudServerNoticeOnlyAStartName"):SetText(GetS(9588))
	local text = getglobal("CloudServerManagementRightPage4NoticeEditDefaultTxt"):GetText()
	if text == "" then
		getglobal("CloudServerNoticeTextEdit"):SetText(GetS(9648))
	else
		getglobal("CloudServerNoticeTextEdit"):SetText(text)
	end
end

function RentPermitCtrl:CloudServerNotice_OnFocusGained()
	print("CloudServerNotice_OnFocusGained")
	local text = this:GetText();
	print("text = ", text);
	if text == GetS(9648) then
		getglobal("CloudServerNoticeTextEdit"):SetText("")
	end
end

function RentPermitCtrl:CloudServerNotice_OnFocusLost()
	print("RentPermitCtrl:CloudServerNotice_OnFocusLost(): ");
	local text = this:GetText();
	if text == "" then
		this:SetText(GetS(9648))
	else
		this:SetText(text);
	end
end

function RentPermitCtrl:SureChangeNoticeBtnClick()
	if false == AccountSafetyCheck:FunCheck(AccountSafetyCheck.FunType.RENTSEV_NOTICE, RentPermitCtrl.SureChangeNoticeBtnClick) then
		return
	end

	local ui_notice_input = getglobal("CloudServerNoticeTextEdit")
	local ui_notice = getglobal("RoomUIFrameSetOptionNotice")
	local ui_notice_text = getglobal(ui_notice:GetName().."EditDefaultTxt")
	local ui_report = getglobal(ui_notice:GetName().."Report")

	local text = ui_notice_input:GetText();

	--敏感词检测
	if DefMgr:checkFilterString(text) then
		ShowGameTipsWithoutFilter(GetS(9200100), 3)
		ui_notice_input:Clear()
		return
	end

	
	if ui_notice:IsShown() == false then
		GetInst("UIManager"):GetCtrl("CloudServerManagement"):ChangeNoticeSureBtnClicked()
		return
	end

	if text == GetS(9648) then
		text = ""
	end

	text = escape(text)

	local paramStr = "notice"
	local param = "&"..paramStr.."="..text.. "&pub_name="..gFunc_urlEscape(AccountManager:getNickName());
	local roomId = ClientMgr:getCurrentRentRoomId()
	local room_uin = ClientMgr:getCurrentRentRoomUin()

	--取出存档数据	修改公告
	local key = "CSChangeNotice_"..room_uin.."_"..roomId
	local curDate = os.date("%Y-%m-%d", getServerTime())
	local keyValue = getkv(key) or (curDate.."_0")
	local valueTab = split(keyValue, "_") or {curDate, "0"}
	if curDate == valueTab[1] then
		--日期相等 就判断次数
		if tonumber(valueTab[2]) >= 5 then
			-- 次数已达上限
			ShowGameTips(GetS(9791))
			return
		end
	end

	print(url)
	local callback = function(ret)
		if ret then
			if ret.ret == 0 then

				--更新一下次数 存档
				if curDate == valueTab[1] then
					local num = tonumber(valueTab[2]) + 1
					setkv(key, curDate.."_"..num)
				else
					setkv(key, curDate.."_1") --之前没存档 就存1
				end

				if text ~= nil and text ~= "" then
					local noticestring = ns_http.func.url_decode(text)
					ui_notice_text:SetText(noticestring)
					ui_notice_input:SetText("");

					--不是自己的服 才显示举报
					--if room_uin ~= AccountManager:getUin() then
					--超管和房主不显示
					local permit_type = RentPermitsMgr:GetPermitType(AccountManager:getUin())
					if  permit_type >= CS_AUTHORITY_MANAGER then
						ui_report:Show()
					else
						ui_report:Hide()
					end
					
				else
					ui_notice_text:SetText("")
					ui_notice_input:SetText("");
					
					ui_report:Hide()
				end
				RentPermitCtrl:ShowRentNoticePopup()
			elseif ret.ret == 11 then
				ShowGameTipsWithoutFilter(GetS(100218), 3)	--手机号 验证码 校验失败
			elseif ret.ret == 12 then			
				ShowGameTips(GetS(121), 3) 	--内容违规
			end
		end
	end
	CloudServerNetMgr:SetRoomInfoInWorld(roomId,room_uin,param,callback)

	getglobal("CloudServerNotice"):Hide()
end

--公告仅提示一次勾选框点击
function RentPermitCtrl:CloudServerNoticeOnlyATickedClicked()
	if self.noticeOnlyAShow then
		self.noticeOnlyAShow = false
		getglobal("CloudServerNoticeOnlyAStartTick"):Hide()
	else
		self.noticeOnlyAShow = true
		getglobal("CloudServerNoticeOnlyAStartTick"):Show()
	end
end

--租赁服玩家切换队伍
function RentPermitCtrl:RentChangePlayerTeam(op_uin,team_id)
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	end
	if ClientCurGame:RentChangePlayerTeam(op_uin,team_id) then
		print("change rent player team success")
	end

	return true
end

--黑名单玩家更新
function RentPermitCtrl:UpdateRentBlacklist()
	local roomId = ClientMgr:getCurrentRentRoomId()
	local room_uin = ClientMgr:getCurrentRentRoomUin()

	local callback = function(ret)
		self:RespUpdateBlacklist(ret)
	end
	CloudServerNetMgr:GetAllPlayerList(roomId,callback,nil,true,room_uin)

end

function RentPermitCtrl:RespUpdateBlacklist(ret)
	print(ret)
	if ret and ret.ret == 0 then

		local blacklist = {}
		if blacklist == nil then return end

		local num = ClientCurGame:getNumPlayerBriefInfo();
		for i=1, num do
			local briefInfo = ClientCurGame:getPlayerBriefInfo(i-1);
			if briefInfo  then
				for k,v in pairs(blacklist) do
					if tonumber(v) == tonumber(briefInfo.uin) then
						RentPermitCtrl:KickPlayer(v,2)
						blacklist[k] = nil
						break
					end
				end
			end
		end
	else
		ns_error_msg.show(ret, 3)
	end
end


--显示租赁服公告弹框
-- type“：0表示进入地图   1表示修改公告
function RentPermitCtrl:ShowRentNoticePopup()
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	end
	if AccountManager:getMultiPlayer() == 0 then
		return false
	end

	local roomId = ClientMgr:getCurrentRentRoomId()
	local room_uin = ClientMgr:getCurrentRentRoomUin()

	local callback = function(ret)
		print(ret)
		if ret and ret.ret == 0 then
			self.noticeInfo = ret  

			--TODO 弹框界面相关的处理
			if ret.notice then
				RentPermitCtrl:ShowNoticeDetail(ret)
			end
		else
			ns_error_msg.show( ret, 3 )
		end
	end
	CloudServerNetMgr:GetNotice(roomId,callback,nil,room_uin)
end

function RentPermitCtrl:ShowNoticeDetail(ret)
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	end

	local notice = ret.notice
	local notice_sender = ret.notice_sender

	-- print("RentPermitCtrl:ShowNoticeDetail",notice,notice_sender)
	if notice and notice == "" then
		return false
	end

	if IsCSNoticeInLock(ret.notice_lock_time) then
		return
	end


	local publish_time = (notice_sender ~= nil) and notice_sender.pub_time or 1
	-- 只提示一次

	if notice_sender and notice_sender.notice_once and notice_sender.notice_once == 1 and not CSRoomNoticeMgr:NeedNotice(CloudServerRoomAuthorityMgr.CurrentKey,publish_time) then
		return false
	end
	local ui_parent = getglobal("CSNoticeFrame")
	local ui_notice = getglobal(ui_parent:GetName().."Notice")
	local ui_title = getglobal(ui_parent:GetName().."Title")
	local ui_pubname = getglobal(ui_parent:GetName().."NoticePubName")
	local ui_pubtime = getglobal(ui_parent:GetName().."NoticePubTime")

	local ui_report = getglobal(ui_parent:GetName().."Report")
	ui_report:Hide()

	if notice_sender == nil then
		ui_notice:SetText(notice)
		ui_title:SetText(GetS(848))
		ui_pubname:SetText("")
		ui_pubtime:SetText("")
	else
		ui_notice:SetText(notice)
		--notice_sender.room_name
		local room_name = ""
		if notice_sender.room_name then
			room_name = notice_sender.room_name
		end
		local titlestr = "#cFF723A【"..GetS(848).."】#n"..room_name
		ui_title:SetText(titlestr)

		local AuthorityType = CS_AUTHORITY_ROOM_OWNER
		if notice_sender.pub_uin then
			local authority = PermitsCallModuleScript("getCSAuthority",notice_sender.pub_uin)
			if authority and authority.Type ~= CS_AUTHORITY_ROOM_OWNER then
				AuthorityType = CS_AUTHORITY_SUPER_MANAGER
			end
		end

		local stringtmp = ""
		if notice_sender.pub_name then
			stringtmp = "#cFF723A【"..GetS(WorldAuthorityConfig.PlayerString[AuthorityType]).."】#n"..notice_sender.pub_name
		else
			stringtmp = "#cFF723A【"..GetS(WorldAuthorityConfig.PlayerString[AuthorityType]).."】#n"
		end
		ui_pubname:SetText(stringtmp)

		stringtmp = ""
		if notice_sender.pub_time then
			local time = os.date("*t", notice_sender.pub_time);
			stringtmp = string.format("%d/%d/%d", time.year, time.month, time.day);
		end
		ui_pubtime:SetText(stringtmp)
	end
	ui_parent:Show()

	local onedata ={
		key = CloudServerRoomAuthorityMgr.CurrentKey,
		notice_once = ( notice_sender and notice_sender.notice_once and notice_sender.notice_once == 1 ) and true or false,
		pub_time = publish_time,
	}
	CSRoomNoticeMgr:UpdateCSNoticeOnceRoomList(onedata)
	return true
end

--设置租赁服邀请玩家逻辑
function RentPermitCtrl:GetInviteExtendData()
    if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
        return nil
    end

	local room_info = RentPermitCtrl.rentRoomInfo
	local t_extendData = {};

	if not room_info.isOneKeyRentRoom then
		local uin, roomid
		if room_info._k_ then
			uin, roomid = getRoomUinAndRoomID(room_info._k_)
		end
	
		t_extendData.RoomType       = "Rent_Room"
		t_extendData.InviterName	= AccountManager:getNickName();
		t_extendData.RoomName 		= room_info.room_name or "";
		t_extendData.RoomUin 		= uin or 0;
		t_extendData.RoomId         = roomid or 1;
		t_extendData.PlayerNum 		= room_info.player_count or 0;
		t_extendData.PlayerMaxNum 	= room_info.player_max or 10;
		t_extendData.RoomVer		= ClientMgr:clientVersionFromStr(room_info.ver) or ClientMgr:clientVersion();
		t_extendData.Password		= room_info.password or "";
		t_extendData.Type			= 'InviteJoinRoom';
		t_extendData.WorldID        = room_info.fromowid or 0
	else
		t_extendData.RoomType       = "Onekey_Rent_Room"
		t_extendData.InviterName	= AccountManager:getNickName();
		t_extendData.RoomName 		= room_info.room_name or "";
		t_extendData.RoomUin 		= room_info.room_uin or 0;
		t_extendData.RoomId     	= -2;
		t_extendData.PlayerNum 		= room_info.player_count or 0;
		t_extendData.PlayerMaxNum 	= room_info.player_max or 10;
		t_extendData.RoomVer		= ClientMgr:clientVersionFromStr(room_info.ver) or ClientMgr:clientVersion();
		t_extendData.Password			= table_tostring({pw=room_info.password or "", rid=room_info.room_id, rtdbg=room_info.isRentDebug}) --id+pw
		-- t_extendData.Password		= room_info.password or "";
		t_extendData.Type			= 'InviteJoinRoomA';
		t_extendData.WorldID        = room_info.fromowid or 0
	end

    return t_extendData
end

function RentPermitCtrl:CheckIsRentRoomInvite(room_uin,room_id)
	if room_id == nil or room_id == -1 then
		return nil
	end
	if room_id == -2 then --此处判断逻辑需与EnterInviteRoom保持一致
		return 2
	else
		return 1
	end
end

--邀请好友加入房间
function RentPermitCtrl:EnterInviteRoom(room_uin,room_id,password,version,rtb)
	if room_id == nil or room_id == -1 then
		return false
	end

	if room_id == -2 then
		local idpw = safe_string2table(password)
		if not idpw then
			ShowGameTips(GetS(26014))
		else
			rtb.standby1 = 15
			rtb.standby2 = idpw.rid
			rtb.standby3 = 1
			local retData = GetInst("RoomService"):ReqQueryQuickupCSRoom(idpw.rid, {rentDebug = idpw.rtdbg})
			local csroomdesc = retData.roomDesc
			local tipStrId = retData.tipsStrId
			if csroomdesc then
				csroomdesc.tryPwd = idpw.pw
				csroomdesc.lcl_outTime = os.time() + 1
				GetInst("RoomService"):EnterRoomByDesc(0, false, csroomdesc, {spData = {rtb=rtb, act_key = idpw.actk, rentDebug = idpw.rtdbg}})
			elseif tonumber(tipStrId) then
				ShowGameTips(GetS(tipStrId), 3) 
			else
				ShowGameTips(GetS(26014))
			end
			-- local ret, tips = GetInst("RoomService"):ReqJoinDesQuickupCSRoom(idpw.rid, {rtb=rtb, act_key = idpw.actk})
			-- if not ret then
			-- 	ShowGameTips(tips or GetS(26014))
			-- end
		end
		return true
	end

	EnterShareCloudRoom(room_uin,room_id,password,version)
	return true
end

--保存当前租赁服房间的信息
--新增的快速启动云服功能造成的影响 room_info 不一定是完整的云服描述结构体
function RentPermitCtrl:SetRentRoomInfo(room_info)
	if room_info == nil then return end

	RentPermitCtrl.rentRoomInfo = room_info;

	if self:IsPersonalQuickUpRentRoom() then
		local room_id = self:GetRentRoomID()
		if room_id then
			RentPermitCtrl.rentRoomInfo.hostUin = tonumber(string.match(room_id or "", "^%d+")) or 1000
		end
	end 
end

function RentPermitCtrl:GetRentRoomID()
	if "table" ~= type(RentPermitCtrl.rentRoomInfo) then
		return nil
	end

	local room_info = RentPermitCtrl.rentRoomInfo
	if not room_info.isOneKeyRentRoom then
		return room_info._k_
	else
		return room_info.room_id
	end
end

function RentPermitCtrl:GetRentRoomOriDesc()
	if not self:IsQuickUpRentRoom() then
		return nil
	end

	if "table" ~= type(RentPermitCtrl.rentRoomInfo) then
		return nil
	end

	return RentPermitCtrl.rentRoomInfo.oriDesc
end

function RentPermitCtrl:GetRoomName()
	if not self:IsRentRoom() then
		return ""
	end

	if "table" ~= type(RentPermitCtrl.rentRoomInfo) then
		return ""
	end

	local room_info = RentPermitCtrl.rentRoomInfo
	return room_info.room_name or ""
end

--设置租赁服群组邀请数据
function RentPermitCtrl:GetGroupInviteExtendData(groupid, text , extendType)
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return nil
	end

	local room_info = RentPermitCtrl.rentRoomInfo
	local t_extendData = {};

	if not room_info.isOneKeyRentRoom then
		local uin, roomid
		if room_info._k_ then
			uin, roomid = getRoomUinAndRoomID(room_info._k_)
		end
		
		local shareData = {};
		shareData.RoomType       = "Rent_Room"
		shareData.InviterName	= AccountManager:getNickName();
		shareData.RoomName 		= room_info.room_name or "";
		shareData.RoomUin 		= uin or 0
		shareData.RoomId     	= roomid or 1;
		shareData.PlayerNum 	= room_info.player_count or 0;
		shareData.PlayerMaxNum 	= room_info.player_max or 10;
		shareData.RoomVer		= ClientMgr:clientVersionFromStr(room_info.ver) or ClientMgr:clientVersion();
		shareData.Password		= room_info.password or "";
		shareData.Type			= 'InviteJoinRoom';
	
		t_extendData.Type		= extendType or 'SendMsg';
		t_extendData.uin 	= AccountManager:getUin()
		t_extendData.text 	= text;
		t_extendData.groupid 	= groupid;
		t_extendData.shareData = shareData
	else
		local shareData = {};
		shareData.RoomType       = "Onekey_Rent_Room"
		shareData.InviterName	= AccountManager:getNickName();
		shareData.RoomName 		= room_info.room_name or "";
		shareData.RoomUin 		= room_info.room_uin or 0
		shareData.RoomId     	= -2;
		shareData.PlayerNum 	= room_info.player_count or 0;
		shareData.PlayerMaxNum 	= room_info.player_max or 10;
		shareData.RoomVer		= ClientMgr:clientVersionFromStr(room_info.ver) or ClientMgr:clientVersion();
		shareData.Password			= table_tostring({pw=room_info.password or "", rid=room_info.room_id, actk = room_info.act_key, rtdbg=room_info.isRentDebug}) --id+pw
		-- shareData.Password		= room_info.password or "";
		shareData.Type			= 'InviteJoinRoomA';
	
		t_extendData.Type		= extendType or 'SendMsg';
		t_extendData.uin 	= AccountManager:getUin()
		t_extendData.text 	= text;
		t_extendData.groupid 	= groupid;
		t_extendData.shareData = shareData
	end


	return t_extendData
end

--云服公告举报
function RentPermitCtrl:ReportCSNotice()
	local room_info = RentPermitCtrl.rentRoomInfo
	local uin = 0
	local roomid = 1
	local wid = 0
	if room_info and room_info._k_ then
		if room_info._k_ then
			uin, roomid = getRoomUinAndRoomID(room_info._k_)
		end

		wid = room_info.fromowid or 0
	elseif room_info and room_info.isOneKeyRentRoom then
		uin = getRoomUinAndRoomID(RentPermitCtrl:GetRentRoomID()) or 0
		roomid = RentPermitCtrl:GetRentRoomID()
	end
	
	-- GetInst("UIManager"):Open("CloudServerReportingSys", {tid=112, opUin = uin, nickname="", wid = wid, title = GetS(10517) .. "#c1ec832" .. GetS(848), roomId = roomid})
	GetInst("ReportManager"):OpenReportView({
		tid = GetInst("ReportManager"):GetTidTypeTbl().cloud_server_notice,
		op_uin = uin,
		wid = wid,
		roomId = roomid,
	})
end

--云服公告 弹窗 举报按钮
function RentPermitCtrl:CSNoticeFrameReportBtnOnClicked()
	self:ReportCSNotice()
end

--云服公告 弹窗 点击事件
function RentPermitCtrl:CSNoticeFrameOnClicked()
	local room_info = RentPermitCtrl.rentRoomInfo
	local uin = 0
	if room_info and room_info._k_ then
		uin, _ = getRoomUinAndRoomID(room_info._k_)
	end

	-- local myUin = AccountManager:getUin()
	-- if myUin ~= uin then
	--不是超管和房主才搞
	local permit_type = RentPermitsMgr:GetPermitType(AccountManager:getUin())
	if  permit_type >= CS_AUTHORITY_MANAGER and self.noticeInfo and self.noticeInfo.notice and self.noticeInfo.notice ~= "" then
		local ui_parent = getglobal("CSNoticeFrame")
		local ui_report = getglobal(ui_parent:GetName().."Report")
		if ui_report:IsShown() then
			ui_report:Hide()
		else
			ui_report:Show()
		end
		
	end
end

--云服公告 编辑界面 举报按钮
function RentPermitCtrl:NoticeReportBtnOnClicked()
	self:ReportCSNotice()
end

--点击公告 显示/隐藏  举报按钮
function RentPermitCtrl:Notice_OnClick()
	-- local room_uin = ClientMgr:getCurrentRentRoomUin()
	-- if room_uin ~= AccountManager:getUin() then
	--不是超管和房主才搞
	local permit_type = RentPermitsMgr:GetPermitType(AccountManager:getUin())
	if  permit_type >= CS_AUTHORITY_MANAGER and self.noticeInfo and self.noticeInfo.notice and self.noticeInfo.notice ~= "" then
		local ui_notice = getglobal("RoomUIFrameSetOptionNotice")
		--设置界面 举报公告按钮
		local ui_report = getglobal(ui_notice:GetName().."Report")
		if ui_report:IsShown() then
			ui_report:Hide()
		else
			ui_report:Show()
		end
	end
end

