-- *battle.lua*

local Player_Max_Num = 40;
Team_Max_Num = 6;
local ShowPlayer_MaxNum = 6;


function BattleFrameCloseBtn_OnClick()
	getglobal("BattleFrame"):Hide();
end

function BattleFrame_OnLoad()
	this:RegisterEvent("GE_CUSTOMGAME_STAGE");
	for i=1, Player_Max_Num do
		local player = getglobal("BattleFrameInfoPlayer"..i);
		player:SetPoint("top", "BattleFrameInfoPlane", "top", 0, 7+(i-1)*69)
	end
	UITemplateBaseFuncMgr:registerFunc("BattleFrameCloseBtn", BattleFrameCloseBtn_OnClick, "计分板页面关闭按钮");
end

IsCustomGameEnd = false;

InvitedReopenRoomData = {
	AgreeInvite = false;
	HostLoadEnd = false;
}

function InitInvitedReopenRoomData()
	InvitedReopenRoomData.AgreeInvite = false;
	InvitedReopenRoomData.HostLoadEnd = false;
end

-- 是否当前房主判断
function IsCurRoomOwner()
	return IsRoomOwner() or IsCloudServerRoomOwner()
end

function BattleFrame_OnEvent()
	if arg1 == "GE_CUSTOMGAME_STAGE" then
		local ge = GameEventQue:getCurEvent();
		local stage = ge.body.cgstage.stage;
		local gametime = ge.body.cgstage.gametime
		if stage == 4 then
			UpdateBattleEndInfo(gametime);
			
			local gameEndCtrl = GetInst("MiniUIManager"):GetCtrl("GameSettlement")
			if gameEndCtrl then
				gameEndCtrl:SetSpectatorModeBtnDisplay(false)
			end
		end
		if stage == 4 then
			if gametime == 0 then
				UpdateBattleInfo(stage, gametime);
			end
			if OnYearMonsterGameEnd then
				OnYearMonsterGameEnd()
			end
		elseif getglobal("BattleFrame"):IsShown() then
			UpdateBattleInfo(stage, gametime);
		end
	end
end

function BattleFrame_OnShow() -- TODO
	Log("BattleFrame_onShow")

	local teamTitle = getglobal("BattleFrameColsTitleTeamTitle");
	local killTitle = getglobal("BattleFrameColsTitleKillTitle");
	local addTtitle = getglobal("BattleFrameColsTitleAddFriendTitle");
	if MiniUI_GameSettlement.IsShown() then --已结算
		Log("has end")
		addTtitle:SetPoint("right", "BattleFrameColsTitle", "right", 0, 0);
		killTitle:SetPoint("center", "BattleFrameColsTitleAddFriendTitle", "left", -51, 0);
		teamTitle:SetPoint("center", "BattleFrameColsTitleKillTitle", "center", -113, 0);
		addTtitle:Show();
		for i=1, Player_Max_Num do
			local team = getglobal("BattleFrameInfoPlayer" .. i .. "Team");
			local num = getglobal("BattleFrameInfoPlayer" .. i .. "KillNum");
			local addBtn = getglobal("BattleFrameInfoPlayer" .. i .. "AddFriend");
			team:SetPoint("center", "BattleFrameInfoPlayer"..i, "left", 326, 0);
			num:SetPoint("center", "BattleFrameInfoPlayer"..i, "right", -126, 0);
			--addBtn:SetPoint("right", "BattleFrameInfoPlayer"..i, "right", -13, 0);
			--addBtn:Show();
		end
	else --未结算
		killTitle:SetPoint("right", "BattleFrameColsTitle", "right", 0, 0);
		teamTitle:SetPoint("right", "BattleFrameColsTitleKillTitle", "left", 0, 0);
		addTtitle:Hide();
		for i=1, Player_Max_Num do
			local team = getglobal("BattleFrameInfoPlayer" .. i .. "Team");
			local num = getglobal("BattleFrameInfoPlayer" .. i .. "KillNum");
			local addBtn = getglobal("BattleFrameInfoPlayer" .. i .. "AddFriend");
			team:SetPoint("center", "BattleFrameInfoPlayer"..i, "left", 373, 0);
			num:SetPoint("right", "BattleFrameInfoPlayer"..i, "right", -3, 0);
			--addBtn:Hide();
		end
	end
	if not getglobal("BattleFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end
end

function BattleFrame_OnHide()
	if not getglobal("BattleFrame"):IsRehide() then
	   ClientCurGame:setOperateUI(false);
	end
end

local t_TeamInfo ={
		-- {name=748, r=255, g=249, b=235},--白
		-- {name=713, r=237, g=73, b=22},	--红
		-- {name=714,r=4, g=255, b=246},	--蓝
		-- {name=715,r=26, g=238, b=22},	--绿
		-- {name=717,r=237, g=223, b=22},	--黄
		-- {name=718,r=237, g=144, b=22},	--橙
		-- {name=716,r=194, g=22, b=237},	--紫
		{name=748, r = 255, 	g = 249, 	b = 235},	
		{name=713, r = 255, 	g = 87, 	b = 69 },	--红
		{name=714, r = 69, 		g = 139, 	b = 225 },	--蓝
		{name=715, r = 37, 		g = 198, 	b = 105 },	--绿
		{name=717, r = 255, 	g = 210, 	b = 0 },	--黄
		{name=718, r = 255, 	g = 128, 	b = 64 },   --橙
		{name=716, r = 163, 	g = 73, 	b = 164 },	--紫
}

function UpdateBattleInfo(stage, gametime)
	if not ClientCurGame.getNumPlayerBriefInfo then
		return;
	end

	local t_BriefInfo = {};
	local num = ClientCurGame:getNumPlayerBriefInfo();
	local myBriefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
	if myBriefInfo ~= nil and  myBriefInfo.teamid ~= 999 then
		table.insert(t_BriefInfo, myBriefInfo);
	end
	for i=1, num do
		local briefInfo = ClientCurGame:getPlayerBriefInfo(i-1);
		if briefInfo ~= nil and  briefInfo.teamid ~= 999 then
			table.insert(t_BriefInfo, briefInfo);
		end
	end

	if #(t_BriefInfo) > 1 then
		table.sort(t_BriefInfo,
			 function(a,b)
				return a.teamid > b.teamid;
			 end
			);
	end

	local baseSetterMgr
	if WorldMgr then --队伍信息获取
		baseSetterMgr = WorldMgr:getBaseSettingManager()
	end

	local myTeamId = 0;	--自己的队伍ID
	local playmates = {}
	for i=1, Player_Max_Num do
		local player = getglobal("BattleFrameInfoPlayer"..i);
		if i <= #(t_BriefInfo) then
			player:Show();
			
			local normal = getglobal(player:GetName().."Normal");
			local my = getglobal(player:GetName().."My");
			local head = getglobal(player:GetName().."Head");
			local headFrame = getglobal(player:GetName().."Frame");
			local name = getglobal(player:GetName().."Name");
			local richName = getglobal(player:GetName().."RichName");
			local team = getglobal(player:GetName().."Team");
			local killNum = getglobal(player:GetName().."KillNum");
			local addFriend = getglobal(player:GetName().."AddFriend");
			local headBtn = getglobal(player:GetName().."HeadBtn")
			name:Hide()

			addFriend:Hide();
			if t_BriefInfo[i].uin == AccountManager:getUin() then
				--normal:Hide();
				my:Show();
				my:SetBlendAlpha(0.5);
				myTeamId = t_BriefInfo[i].teamid;
				HeadCtrl:CurrentHeadIcon(head:GetName());
				HeadFrameCtrl:CurrentHeadFrame(headFrame:GetName());
			else
				my:Hide();
				normal:Show();
				if not IsMyFriend(t_BriefInfo[i].uin) and (stage == 4 or IsCustomGameEnd) and myBriefInfo.teamid ~= 999 then
					addFriend:Show();
					addFriend:SetClientID(t_BriefInfo[i].uin);
				else
					addFriend:Hide();
				end
				HeadCtrl:SetPlayerHeadByUin(head:GetName(),t_BriefInfo[i].uin,t_BriefInfo[i].model,t_BriefInfo[i].skinid)
				HeadFrameCtrl:SetPlayerheadFrameName(headFrame:GetName(),t_BriefInfo[i].frameid)
			end
			headBtn:SetClientID(t_BriefInfo[i].uin)
			local teamId = t_BriefInfo[i].teamid + 1;
			--名字
			-- name:SetText(t_BriefInfo[i].nickname);
			-- name:SetTextColor(t_TeamInfo[teamId].r, t_TeamInfo[teamId].g, t_TeamInfo[teamId].b);
			local filterName = ReplaceFilterString(t_BriefInfo[i].nickname or "")
			local str = G_VipNamePreFixEntrency(richName, t_BriefInfo[i].uin, filterName, t_TeamInfo[teamId], teamId > 1)
			local width = richName:GetTextExtentWidth(str)
			-- name:resizeRichWidth(width)
			richName:SetWidth(width)

			--队伍
			if baseSetterMgr and baseSetterMgr:getTeamName(t_BriefInfo[i].teamid) ~= "" then
				local oldText = baseSetterMgr:getTeamName(t_BriefInfo[i].teamid)
				oldText = GetEditorLangShowText(oldText, LangEnum.MapRuleTeamNamePrefix..teamId)
				team:SetText(oldText)
			else
				team:SetText(GetS(t_TeamInfo[teamId].name));
			end
			team:SetTextColor(t_TeamInfo[teamId].r, t_TeamInfo[teamId].g, t_TeamInfo[teamId].b);
			--得分
			if ClientMgr:clientVersion() < 23*256 then
				killNum:SetText(t_BriefInfo[i].cgamevar[0]);
			else
				killNum:SetText(LuaInterface:band(t_BriefInfo[i].cgamevar[0], 0xffffff));
			end
			killNum:SetTextColor(t_TeamInfo[teamId].r, t_TeamInfo[teamId].g, t_TeamInfo[teamId].b);

			-- 记录所有上局玩伴
			if not playmates[i] then
				playmates[i] = { uin = t_BriefInfo[i].uin, nickname = t_BriefInfo[i].nickname}
			end
		else
			player:Hide();
		end
	end
	
	local height = 418;
	if num > 6 then
		height = 418 + 68 * (num + 1 - 6);
	end
	getglobal("BattleFrameInfoPlane"):SetSize(580, height);
			
	if (stage == 4 or IsCustomGameEnd) and myBriefInfo.teamid ~= 999 then	--游戏结束
		if gametime == 0 then
			if CurWorld:isGameMakerRunMode() and IsCurRoomOwner() then
				getglobal("BattleFrameBackMenu"):SetPoint("bottom", "BattleFrameChenDi", "bottom",165, -9)
				getglobal("BattleFrameReopen"):SetPoint("bottom", "BattleFrameChenDi", "bottom",-165, -9);
			--	getglobal("BattleFrameReopen"):Show();
			else
				getglobal("BattleFrameBackMenu"):SetPoint("bottom", "BattleFrameChenDi", "bottom",0, -9)
				getglobal("BattleFrameReopen"):Hide();
			end
			--getglobal("BattleFrameBackMenu"):Show();
			--getglobal("BattleFrameCloseBtn"):Hide();
			getglobal("BattleFrameDecorate1"):Hide();
			getglobal("BattleFrameDecorate2"):Hide();

			local t_TeamScore = {}
			local teamNum = ClientCurGame:getNumTeam();
			local result = myBriefInfo.cgamevar[1];
			if result == 0 then
			elseif result == 1 then		--胜利
				getglobal("BattleFrameTitle"):SetText(GetS(270));
				getglobal("BattleFrameTitle"):SetTextColor(239, 93, 93);
			elseif result == 2 then		--失败
				getglobal("BattleFrameTitle"):SetText(GetS(271));
				getglobal("BattleFrameTitle"):SetTextColor(239, 93, 93)
				-- getglobal("BattleFrameDecorate1"):Show();
				-- getglobal("BattleFrameDecorate2"):Show();
			elseif result == 3 then		--平局
				getglobal("BattleFrameTitle"):SetText(GetS(272));
				getglobal("BattleFrameTitle"):SetTextColor(255, 255, 255);
			end
	
		elseif gametime == 300 and not InvitedReopenRoomData.AgreeInvite then	--300个tick后自动退出出房间
			--[[
			if IsRoomOwner() then	--主机
				AccountManager:sendToClientKickInfo(2);
			end
			LeaveRoomType = 1;	
			SendMsgWaitTime = 0.5;	
			]]	
		end
		---MiniBase 返回主菜单改成退出游戏
		if MiniBaseManager:isMiniBaseGame() then
			getglobal("BattleFrameBackMenuName"):SetText(GetS(3053))
		end
				
	else
		getglobal("BattleFrameBackMenu"):Hide();
		getglobal("BattleFrameReopen"):Hide();
		getglobal("BattleFrameTitle"):SetText(GetS(208));
		getglobal("BattleFrameTitle"):SetTextColor(77, 112, 117);
		getglobal("BattleFrameDecorate1"):Hide();
		getglobal("BattleFrameDecorate2"):Hide();		
	end

	getglobal("BattleFrameCloseBtn"):Show();

	GetInst("BattleEndFriendListGData"):CacheGamePlayMates()
end

function BattlePlayerInfoTemplateAddFriend_OnClick()
	local uin = this:GetClientID();
	AddUinAsFriend(uin);
end

function BattlePlayerInfoTemplateHead_OnClick()
	local uin = this:GetClientID();
	--获取房间的人员信息
	local userinfo = GetRoomUserInfo(uin)
	if next(userinfo) then
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common","miniui/miniworld/userInfoInteract"})
		GetInst("MiniUIManager"):OpenUI("main_userinfocard","miniui/miniworld/userInfoInteract","main_userinfocardAutoGen",userinfo)
	end
	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
		standReportEvent("1003", "SCORE_BOARD", "Profile", "click")
	else
		standReportEvent("1001", "SCORE_BOARD", "Profile", "click")
	end
end

function BattleFrameReopenAgainBySigle()
	--重新加载地图
	getglobal("BattleFrame"):Hide();
	HideUI2GoMainMenu();
	for i=1, #(t_UIName) do
		local frame = getglobal(t_UIName[i]);
		frame:Hide();
	end
	IsCustomGameEnd = false;

	ShowLoadingFrame();
	ClientMgr:gotoGame("MainMenuStage", SINGLE_RELOAD);
end

function BattleFrameReopen_OnClick()
	standReportEvent("415", "GAME_END", "Restart", "click", G_GetGameStandReportDataA()) --hrl 2021.11.02
	-- 如果有结算页直接关闭
	MiniUI_GameSettlement.CloseUI();

	--开发者模式的单机游戏 再来一次
	if AccountManager:getMultiPlayer() == 0 then
		BattleFrameReopenAgainBySigle();
		return
	end

	if not IsCurRoomOwner() then return end

	--邀请房员再来一局
	if EnterMainMenuInfo.ReopenRoomInfo then
		EnterSurviveGameInfo.NeedInvite = false;
		EnterSurviveGameInfo.ReopenRoomInvitePlayers = {};

		local num = ClientCurGame:getNumPlayerBriefInfo();
		for i=1, num do
			local briefInfo = ClientCurGame:getPlayerBriefInfo(i-1);
			if briefInfo ~= nil then
				table.insert(EnterSurviveGameInfo.ReopenRoomInvitePlayers, briefInfo.uin);
			end
		end
	end

	if EnterSurviveGameInfo.ReopenRoomInvitePlayers then
		print("kekeke ReopenRoomInvitePlayers", EnterSurviveGameInfo.ReopenRoomInvitePlayers);
		for i=1, #(EnterSurviveGameInfo.ReopenRoomInvitePlayers) do
			local uin = EnterSurviveGameInfo.ReopenRoomInvitePlayers[i];
			AccountManager:route('InviteJoinRoom', uin, {RoomState='load_begin',Msg=GetS(4888), PassWorld=EnterSurviveGameInfo.PassWorld});
		end
		EnterSurviveGameInfo.NeedInvite = true;
	end

	--重新加载地图
	getglobal("BattleFrame"):Hide();
	HideUI2GoMainMenu();
	for i=1, #(t_UIName) do
		local frame = getglobal(t_UIName[i]);
		frame:Hide();
	end
	IsCustomGameEnd = false;
	if not GetInst("TeamVocieManage"):isInTeamVocieRoom() then
		if GYouMeVoiceMgr and GYouMeVoiceMgr.quitRoom then
			GYouMeVoiceMgr:quitRoom();
		end
	end
	
	ShowLoadingFrame();
	if ClientMgr:clientVersion() < 23*256 then
		ClientMgr:gotoGame("MainMenuStage", true);
	else
		ClientMgr:gotoGame("MainMenuStage", MULTI_RELOAD);
	end
end

--客机收到邀请
function BeInviteJoinRoom(from_uin, t_info)
	Log( "hh BeInviteJoinRoom");
	local stage = ClientCurGame:getGameStage();
	if ClientCurGame:isInGame() and ClientCurGame:getGameStage() == 4 then
		if t_info.RoomState == 'load_begin' then
			if not MiniUI_GameSettlement.IsShown() then
				MessageBox(18, t_info.Msg, OnInviteJoinRoom, from_uin, false, {rightTime=15});
			else
				GetInst("GameSettlementGData"):SetBeInvite(true)
				SandboxLua.eventDispatcher:Emit(nil, "MAIN_SETTLEMENT_EVENT_BEINVITE",  SandboxContext())
			end
		elseif t_info.RoomState == 'load_end' then
			InvitedReopenRoomData.HostLoadEnd = true;
			if InvitedReopenRoomData.AgreeInvite then
				ClientBeginReLoadWorld();
			end
		end
	end
end

--客机收到服务器邀请
function ServerBeInviteJoinRoom(from_uin, RoomState, PassWorld, ConnectMode)
	Log( "hh ServerBeInviteJoinRoom");
	local stage = ClientCurGame:getGameStage();
	if ClientCurGame:isInGame() and ClientCurGame:getGameStage() == 4 then
		if RoomState == 'load_begin' then
			GetInst("GameSettlementGData"):SetBeInvite(true)
			SandboxLua.eventDispatcher:Emit(nil, "MAIN_SETTLEMENT_EVENT_BEINVITE",  SandboxContext())
			
			Log( "ServerBeInviteJoinRoom2");
		elseif RoomState == 'load_end' then
			InvitedReopenRoomData.HostLoadEnd = true;
			if InvitedReopenRoomData.AgreeInvite then
				ClientBeginReLoadWorld();
			end
		end
	end
end

--主机已经加载完地图，客机可以开始加载地图
function ClientBeginReLoadWorld()
	IsCustomGameEnd = false;
	ShowLoadingFrame();
	if ClientMgr:clientVersion() < 23*256 then
		ClientMgr:gotoGame("MainMenuStage", true);
	else
		ClientMgr:gotoGame("MainMenuStage", MULTI_RELOAD);
	end
end

function ClientAcceptInviteJoinRoom()
	Log("hh ClientAcceptInviteJoinRoom")
	if getglobal("LoadLoopFrame"):IsShown() then
		ShowLoadLoopFrame(false)
	end
	if ClientCurGame:isInGame() and ClientCurGame:getGameStage() == 4 then
		InvitedReopenRoomData.AgreeInvite = true;
		if InvitedReopenRoomData.HostLoadEnd then
			getglobal("BattleFrame"):Hide();
			HideUI2GoMainMenu();
			for i=1, #(t_UIName) do
				local frame = getglobal(t_UIName[i]);
				frame:Hide();
			end
			ClientBeginReLoadWorld();
		else
			getglobal("BattleFrame"):Hide();
			HideUI2GoMainMenu();
			for i=1, #(t_UIName) do
				local frame = getglobal(t_UIName[i]);
				frame:Hide();
			end
			ShowLoadingFrame(GetS(4889), 10);
		end
	else
		
	end
	
	GetInst("GameSettlementGData"):SetAutoGoToMainMenuTime(0)
	
end

function OnInviteJoinRoom(type, data)
	--Log("OnInviteJoinRoom", type, data)
	if type == 'left' then	--客机选择加入
		if not RentPermitCtrl:IsRentRoom() and ClientCurGame and ClientCurGame:getRuleOptionVal(38) == 0 and AccountManager.ReqReEnterRoom then --中途不允许加入
			ShowLoadLoopFrame(true, "file:battle -- func:OnInviteJoinRoom")
			if ClientCurGame.getHostUin then
				AccountManager:ReqReEnterRoom(ClientCurGame:getHostUin());
			end
		else
			if not GetInst("TeamVocieManage"):isInTeamVocieRoom() then
				if GYouMeVoiceMgr and GYouMeVoiceMgr.quitRoom then
					GYouMeVoiceMgr:quitRoom();
				end
			end
			ClientAcceptInviteJoinRoom();
		end
	elseif type == 'right' then	--客机选择离开
		if ClientCurGame and ClientCurGame:isInGame() and ClientCurGame:getGameStage() == 4 then
			BattleFrameBackMenu_OnClick();
		end
		
		GetInst("GameSettlementGData"):SetAutoGoToMainMenuTime(0)
	end
end

function BattleFrameBackMenu_OnClick(isGotoMain)	
	if IsRoomOwner() then	--主机
		MessageBox(5, GetS(220));
		getglobal("MessageBoxFrame"):SetClientString( "主机关闭房间" );
		return;
	end
	getglobal("BattleFrame"):Hide();
	
	MiniUI_GameSettlement.CloseUI();
	GetInst("MiniUIManager"):CloseUI("main_userinfocardAutoGen")	
	GetInst("PlayerInfoCardMgr"):CloseUI()

	if not isGotoMain then
		EnterMainMenuInfo.LoginRoomServer = true;
	end
	--MiniBase触发返回主菜单 返回到迷你基地           
	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_PreLeaveGame",  SandboxContext():SetData_Number("code", 0))
	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_LeaveGame",  SandboxContext():SetData_Number("code", 1))
	if CurWorld and CurWorld:getOWID() == NewbieWorldId2 then
		IsFirstEnterNoviceGuide =false;
		EnterMainMenuInfo.LoginRoomServer = false;
		-- 标识已经完成了走过了新手教学
		if NewbieGuideManager and NewbieGuideManager:IsSwitch() then
			NewbieGuideManager:SetGuideFinishFlag(NewbieGuideManager.GUIDE_FLAG_GO_ALONE, true)
			NewbieGuideManager:SetGuideFlagByPos(NewbieGuideManager.GUIDE_FLAG_GO_ALONE)
		end
		--需求修改，本来这里是第二步，现在第二步跳过了
		-- if GetGuideStep() ~= nil then 
			SetGuideStep(3)
		-- end 
		-- if NewbieGuideManager:GetPlayerTypeID() == NewbieGuideManager.NEW_PLAYER_TYPEID  then
		-- 	if not NewbieGuideManager:RequestSelectSkinPlay() then
		-- 		HideUI2GoMainMenu();
		-- 		ClientMgr:gotoGame("MainMenuStage");
		-- 	end
		-- else
			HideUI2GoMainMenu();
			ClientMgr:gotoGame("MainMenuStage");
		-- end
		local ctrl = GetInst("UIManager"):GetCtrl("RookieGuide")
		if ctrl then
			ctrl:Refresh()
		end
	else
		HideUI2GoMainMenu();
		ClientMgr:gotoGame("MainMenuStage");
	end
	
end

local t_WinPlayerInfo = {};
local t_DefeatPlayerInfo = {};
function UpdateBattleEndInfo(gametime)
	if gametime == 0 then
		IsCustomGameEnd = true;	
		getglobal("BattleFrame"):Hide();
		if not MiniUI_GameSettlement.IsShown() then
			print("kekeke UpdateBattleEndInfo BattleEndShadeFrame show")
			getglobal("BattleEndShadeFrame"):Show();
		else
			if G_Battle_UI then
				G_Battle_UI.reopen.isShow = true;
			end

			SandboxLua.eventDispatcher:Emit(nil, "MAIN_SETTLE_SHOW_REOPEN",  SandboxContext())
		end
	end
end

function OnBattleEnd()
	print("kekeke OnBattleEnd");
    if not ClientCurGame:isInGame() then return end

	if ClientMgr:clientVersion() < 24*256 then
		getglobal("BattleFrame"):Hide();
		getglobal("BattleEndShadeFrame"):Show();
	else
		if MiniUI_GameSettlement.IsShown() then return end

		local teamId = CurMainPlayer:getTeam();
		if (ClientCurGame.getTeamResults and ClientCurGame:getTeamResults(teamId) > 0) or (CurMainPlayer ~= nil and CurMainPlayer.getGameResults and CurMainPlayer:getGameResults() > 0) then --队伍有结果或者个人有结果 弹结算界面
			getglobal("BattleFrame"):Hide();
			getglobal("BattleEndShadeFrame"):Show();
		end
	end
end

function  GetPlayerGameResult(briefInfo)
	local result = ClientCurGame.getTeamResults and ClientCurGame:getTeamResults(briefInfo.teamid) or 0;
	return result > 0 and result or briefInfo.cgamevar[1];
end

-----------------------------------------------------------BattleEndShadeFrame---------------------------------------------
function BattleEndShadeFrame_OnLoad()
	this:setUpdateTime(0.05);
end

local BattleResultChangeNum = 0;
local BattleEndShadeFrameShowTime = 0;
local forceBattleEndShadeFrameUpdate = false;
local needResult = false --周末挑战，需要统计通关时间
function BattleEndShadeFrame_OnUpdate()
    if not ClientCurGame:isInGame() then
        getglobal("BattleEndShadeFrame"):Hide();
        return
    end
	local alpha = getglobal("BattleEndShadeFrameBkg"):GetBlendAlpha() + 0.03;

	if alpha >= 0.5 and BattleResultChangeNum == -1 then
		BattleResultChangeNum = 0;

		needResult = false --周末挑战，需要统计通关时间
		if ClientCurGame.getPlayerBriefInfo then
			local playmates = {}
			local myBriefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
			if myBriefInfo.teamid ~= 999 then
				if myBriefInfo ~= nil and myBriefInfo.cgamevar[1] == 1 then				--胜利需要统计
					needResult = true
					getglobal("BattleEndShadeFrameResult"):SetText(GetS(270));
					getglobal("BattleEndShadeFrameView"):addBackgroundEffect("particles/Ribbon_1.ent", 0, 80, 150);
				else
					getglobal("BattleEndShadeFrameResult"):SetText(GetS(749));
					getglobal("BattleEndShadeFrameView"):addBackgroundEffect("particles/Ribbon_2.ent", 0, 80, 150);
				end
			else
				local playernum = ClientCurGame:getNumPlayerBriefInfo();
				local team_win = {};
				local count = 0;
				for i = 1, playernum do
					local BriefInfo = ClientCurGame:getPlayerBriefInfo(i-1);	--自己
					if BriefInfo ~= nil and myBriefInfo.cgamevar[1] == 1 then	
						table.insert(team_win, BriefInfo);
					end	
				end
				
				count = #team_win;
				if count == playernum then
					getglobal("BattleEndShadeFrameResult"):SetText(GetS(270));
					getglobal("BattleEndShadeFrameView"):addBackgroundEffect("particles/Ribbon_1.ent", 0, 80, 150);
				elseif count > 0 then
					if  team_win[1].teamid > 0 then
						--队伍胜利				--胜利需要统计
						needResult = true
						getglobal("BattleEndShadeFrameResult"):SetText(KillInfoFrame_TeamInfo[team_win[1].teamid].name..GetS(270));
						getglobal("BattleEndShadeFrameView"):addBackgroundEffect("particles/Ribbon_1.ent", 0, 80, 150);
					elseif count == 1 then
					    --个人胜利			--胜利需要统计
						needResult = true
						getglobal("BattleEndShadeFrameResult"):SetText(team_win[1].nickname..GetS(270));
						getglobal("BattleEndShadeFrameView"):addBackgroundEffect("particles/Ribbon_1.ent", 0, 80, 150);
					end
				else
					getglobal("BattleEndShadeFrameResult"):SetText(GetS(749));
					getglobal("BattleEndShadeFrameView"):addBackgroundEffect("particles/Ribbon_2.ent", 0, 80, 150);
				end
			end

			
		end
	end

	if alpha >= 0.75 then
		getglobal("BattleEndShadeFrameBkg"):SetBlendAlpha(0.75);
		if not getglobal("BattleEndShadeFrameResult"):IsShown() and not getglobal("BattleEndFrame"):IsShown() then
			getglobal("BattleEndShadeFrameResult"):Show()			
		end

		if BattleResultChangeNum == 0 then
			getglobal("BattleEndShadeFrameResult"):SetScale(1);
			BattleResultChangeNum = 1;
		elseif BattleResultChangeNum == 1 then
			BattleResultChangeNum = 2;
			getglobal("BattleEndShadeFrameResult"):SetScale(0.9);
		elseif BattleResultChangeNum == 2 then
			BattleResultChangeNum = 3;
			getglobal("BattleEndShadeFrameResult"):SetScale(1);
		end
	else
		getglobal("BattleEndShadeFrameBkg"):SetBlendAlpha(alpha);
	end
  
	if BattleEndShadeFrameShowTime > 0 or forceBattleEndShadeFrameUpdate == true then
		BattleEndShadeFrameShowTime = BattleEndShadeFrameShowTime - arg1;
		if BattleEndShadeFrameShowTime <= 0 then
			if not MiniUI_GameSettlement.IsShown() then
				getglobal("BattleEndShadeFrameResult"):Hide();
				getglobal("BattleEndShadeFrameView"):Hide();
				
				GetInst("WeekendCarnivalMgr"):gameEnd(needResult)
				
                if not GetInst("ActivityAwakenManager").backUI_ID and not GetInst("ActivityDouluoManager").backUI_ID and
				   not GetInst("WeekendCarnivalMgr").backUI_ID then
					MiniUI_GameSettlement.ShowUI()
				else
					BattleFrameBackMenu_OnClick(true)
				end
			end
		end
	end
end

function BattleEndShadeFrame_OnShow()
	--MiniBase比赛地图结算处理
	if MiniBaseManager:isMiniBaseGame() then
		pcall(function()
			MiniBaseManager:groupRentAdventureTopRank()
		end)
	end

	getglobal("BattleEndShadeFrameBkg"):SetBlendAlpha(0);
	getglobal("BattleEndShadeFrameResult"):Hide();

	BattleResultChangeNum = -1;
	getglobal("BattleEndShadeFrameResult"):SetScale(1);

	BattleEndShadeFrameShowTime = 3;
	if isEducationalVersion and _G.MiniCodeGuanQiaFrame then
		BattleEndShadeFrameShowTime = 0.01;--教育版关卡胜利跳过前面的动画
	end

	getglobal("BattleEndShadeFrameView"):Show();
	getglobal("BattleEndShadeFrameView"):deleteBackgroundEffect("particles/Ribbon_1.ent");
	getglobal("BattleEndShadeFrameView"):deleteBackgroundEffect("particles/Ribbon_2.ent");

	local myBriefInfo = nil;

	if ClientCurGame and ClientCurGame.getPlayerBriefInfo then
		myBriefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
	end

	local obj = getglobal("BattleEndShadeFrame")
	if myBriefInfo ~= nil and myBriefInfo.cgamevar[1] == 1 then	
		ClientMgr:playSound2D("sounds/pvp/win.ogg", 1);
		if obj and not obj:IsReshow() then
			standReportEvent("413", "GAME_VICTORY", "Victory", "view", G_GetGameStandReportDataA()) --hrl 2021.11.02
		end
	else
		ClientMgr:playSound2D("sounds/pvp/defeat.ogg", 1);
		if obj and not obj:IsReshow() then
			standReportEvent("414", "GAME_FAIL", "Fail", "view", G_GetGameStandReportDataA()) --hrl 2021.11.02
		end
	end

	--[[
	--成就数据获取
	local uin_list ={}; --所有玩家的uin集合，用来初始化成就信息

	if ClientCurGame and ClientCurGame.getNumPlayerBriefInfo then  --不是联机，这个函数未重写，需要判空
		local num = ClientCurGame:getNumPlayerBriefInfo();
		for i=1, num do
			local briefInfo = ClientCurGame:getPlayerBriefInfo(i-1);
			if briefInfo ~= nil then
				table.insert(uin_list,briefInfo.uin);
			end
		end
	end

	if ClientCurGame and ClientCurGame.getPlayerBriefInfo then
		local myBriefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
		if myBriefInfo ~= nil then
			table.insert(uin_list,myBriefInfo.uin);
		end
	end 

	EndBattleAchievePanel:ReqUseAchieveByUinlist(uin_list);  --加载成就数据
	]]
end
------------------------------------------------------------BattleEndFrame-------------------------------------------------
local LogPos = false;
local t_PlayerCenterBindPos = {};
local t_PlayAnimIndex = { win={}, defeat={}};
local PlayWinAnimCoolDown = 5;
local PlayDefeatAnimCoolDown = 4;
local AutoReOpenTime = -1;
local HighestScore = 0;
function BattleEndFrameCloseBtn_OnClick()
	--[[
	local view = getglobal("BattleEndFrameView");
	view:playActorAnim(100155, 0);

	LogPos = true;
	]]
	standReportEvent("415", "GAME_END", "GameExit", "click", G_GetGameStandReportDataA()) --hrl 2021.11.02

	if isEducationalVersion then
		BattleEndFrameCloseBtn_OnClick_Edu()
		return
	end

	if not IsCommended and not IsRoomOwner() then
		MessageBox(23, GetS(3860), nil, nil, true);
		getglobal("MessageBoxFrame"):SetClientString( "离开结算界面时评分" );
	else
		BattleFrameBackMenu_OnClick();
		--PVP赛事活动结束退出重置发送pb到云服标志
		GetInst("PvpCompetitionManager"):resetSendActToCloudServer()
	end
	if CurWorld and CurWorld:getOWID() == NewbieWorldId2 then
		standReportEvent("3801", "NEWPLAYER_MAP_FINISH", "Quite", "click")
	end
end

function BattleInfoTemplateAddFriend_OnClick()
	local uin = this:GetParentFrame():GetClientID();
	AddUinAsFriend(uin);
end

function RespMiniWorksExist(ret)
	local fromowid = "";
	if not IsRoomClient() then
		local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
		if worldDesc.fromowid and worldDesc.fromowid ~= 0 then
			fromowid = worldDesc.fromowid
		else
			fromowid = worldDesc.worldid
		end
	else
		fromowid = tonumber(DeveloperFromOwid);
	end

	--地图加精后拿到的table为select，否则为normal
	if  ret[fromowid] and  (ret[fromowid].normal or ret[fromowid].select) then -- 工坊是否存在这张地图
		local t_mapInfo = {}
		if ret[fromowid].select then
			t_mapInfo = ret[fromowid].select
		elseif ret[fromowid].normal then
			t_mapInfo = ret[fromowid].normal
		end
		SetShareMiniWorksAuthorInfo(t_mapInfo)

		local shareUrl = GetDefaultShareUrl();
		local shareTitle = "";
		local shareContent = GetS(1506, t_mapInfo.name);
		SetShareData("", shareUrl, shareTitle, shareContent);

		local tShareParams = {};
		local tBriefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
		local nBattleResult = GetPlayerGameResult(tBriefInfo);
		if nBattleResult == 1 then 
			tShareParams.shareType = t_share_data.ShareType.BATTLE_VICTORY;
		elseif nBattleResult == 2 or nBattleResult == 3 then 
			tShareParams.shareType = t_share_data.ShareType.BATTLE_FAILURE;
		else
			tShareParams.shareType = t_share_data.ShareType.MAP;
		end
		tShareParams.fromowid = fromowid;
		t_share_data:SetMiniShareParameters(tShareParams);

		getglobal("GamesharingFrame"):Show();
		--if (ClientMgr.isPC and ClientMgr:isPC()) or (false and IsAndroidBlockark() and IsProtectMode()) then
		--	MiniwShare("","");
		--else
		--	getglobal("GamesharingFrame"):Show();
		--end
	else
		ShowGameTips(GetS(9327), 3)
	end
end

function BattleEndFrameShareBtn_OnClick()
	standReportEvent("415", "GAME_END", "Share", "click", G_GetGameStandReportDataA()) --hrl 2021.11.02
	local fromowid = "";
	if not IsRoomClient() then 		--判断是否是客机
		local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
		if worldDesc then
			if worldDesc.fromowid and worldDesc.fromowid ~= 0 then
				fromowid = worldDesc.fromowid
			else
				fromowid = worldDesc.worldid
			end
		end
	else
		fromowid = DeveloperFromOwid;
	end

	ShareToDynamic:SetActionParameter(25,fromowid); --设置游戏内动态分享的跳转参数
	GetInst("PlayerCenterDynamicsManager"):SetAction(25,fromowid)
	local url = mapservice.getserver().."/miniw/map/?act=get_map_list_info&fn_list="..fromowid;
    if ns_SRR and ns_SRR.cloud_mode == 1 then
        url = url .. '&cloud=1'
    end    
	url = AddPlayableArg(url)
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, RespMiniWorksExist, nil, nil, ns_http.SecurityTypeHigh)   --map
	
	local briefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
	local result = briefInfo.cgamevar[1];--1：胜利 2：失败 3：平局
	if result == 2 then
		SetShareScene("BattleFail")
	else
		SetShareScene("BattleWin")
	end
end

function BattleEndFrameJoinBtn_OnClick()
	OnInviteJoinRoom('left');
end

function SpectatorModeChange()
	if CurMainPlayer == nil then
		return;
	end	
	if CurMainPlayer:getSpectatorMode() == 1 then
		--界面上显示观战按钮面板
		getglobal("PlayShortcut"):Hide();
		-- getglobal("PlayerExpBar"):Hide();				--经验条
		LevelExpBar_ShowOrHide(false);
		local starbkg1 = getglobal("PlayerExpBarStarBkg1");		
		starbkg1:Hide();
		getglobal("PlayMainFrameBackpack"):Hide();
		getglobal("SpectatorFrame"):Show();
		getglobal("SpectatorPlayerName"):Show();
		if ClientMgr:clientVersion() >= 24*256 then
			if ClientCurGame:isInGame() and ClientCurGame:getRuleOptionVal(41) == 2 then
				getglobal("SpectatorSwitchPlayer"):Show();
				if ClientMgr:isMobile() then
					getglobal("PlayMainFrameFly"):Show();	
				end
			else
				getglobal("SpectatorSwitchPlayer"):Hide();
			end
		end
		
		if ClientMgr:clientVersion() >= 24*256 then
			if ClientCurGame:getRuleOptionVal(41) == 1 then
				SpectatorLastPlayerBtn_OnClick();
			else
				if ClientMgr:isMobile() then
					getglobal("PlayMainFrameFly"):Show();	
				end
			end
		end
		
		if ClientMgr:isMobile() then
			getglobal("PlayMainFrameSneak"):Hide();			
			getglobal("PlayMainFrameRide"):Hide();		
		end		
		
		if CurMainPlayer:getSpectatorType() == 0 then
			getglobal("SpectatorPlayerNameContent"):SetText(GetS(6109));
		end
	elseif CurMainPlayer:getSpectatorMode() == 2 then
		--界面上显示观战按钮面板
		getglobal("PlayShortcut"):Hide();
		getglobal("PlayerExpBar"):Hide();				--经验条
		local starbkg1 = getglobal("PlayerExpBarStarBkg1");		
		starbkg1:Hide();
		LevelExpBar_ShowOrHide(false);
		getglobal("PlayMainFrameBackpack"):Hide();
		getglobal("SpectatorFrame"):Show();
		getglobal("SpectatorPlayerName"):Show();
		getglobal("SpectatorSwitchPlayer"):Show();

		if ClientMgr:isMobile() then
			getglobal("PlayMainFrameSneak"):Hide();			
			getglobal("PlayMainFrameRide"):Hide();		
		end		
		
		if CurMainPlayer:getSpectatorType() == 0 then
			getglobal("SpectatorPlayerNameContent"):SetText(GetS(6109));
		end
	else
		if (CurWorld:isCreativeMode() or CurWorld:isGameMakerMode()) == false and not (IsInHomeLandMap and IsInHomeLandMap()) then
			if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.OBJECT) then --xyang自定义UI
				getglobal("PlayerExpBar"):Show();				--经验条
				local starbkg1 = getglobal("PlayerExpBarStarBkg1");		
				starbkg1:Show();
				LevelExpBar_ShowOrHide(true);
			end
		else
			getglobal("PlayerExpBar"):Hide();				--经验条
			local starbkg1 = getglobal("PlayerExpBarStarBkg1");		
			starbkg1:Hide();
			LevelExpBar_ShowOrHide(false);
		end
		if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.OBJECT) then --xyang自定义UI
			if not IsUGCEditing() then
				getglobal("PlayShortcut"):Show();		--快捷栏
				getglobal("PlayMainFrameBackpack"):Show();	--背包
			end
		end
		getglobal("SpectatorFrame"):Hide();
		getglobal("SpectatorPlayerName"):Hide();
		getglobal("SpectatorSwitchPlayer"):Hide();

		if CurWorld:isCreativeMode() or CurWorld:isGameMakerMode() then
			loadUserClientNewItemPro();
			loadNewItemInfo();
			if #t_CreateBackPackNewItemVersionTag > 1 then
				getglobal("PlayMainFrameBackpackRedTag"):Show();
			else
				getglobal("PlayMainFrameBackpackRedTag"):Hide();
			end
		else
			getglobal("PlayMainFrameBackpackRedTag"):Hide();
		end

	end
end
function BattleEndFrameSpectatorModeBtn_OnClick()
	CurMainPlayer:setSpectatorMode(1);
	getglobal("BattleFrame"):Hide();
	MiniUI_GameSettlement.CloseUI();
	GetInst("MiniUIManager"):CloseUI("main_userinfocardAutoGen")
	SpectatorModeChange();
	
	GetInst("PlayerInfoCardMgr"):CloseUI()
end

function BattleEndFrame_OnLoad()
	if isEducationalVersion and not ClientCurGame then
		return;
	end

    if not ClientCurGame:isInGame() then return end
	this:setUpdateTime(0.05);

	getglobal("BattleEndFrameJoinBtnTips"):SetText("("..GetS(4888)..")");

	local t_pos = {
		{x=0, y=-15, z=500},
		{x=-130, y=-15, z=500},
		{x=130, y=-15, z=500},
		{x=-245, y=30, z=560},
		{x=245, y=30, z=560},
		{x=370, y=30, z=550},
	}

	for i=1, ShowPlayer_MaxNum do
		getglobal("BattleEndFrameView"):setActorPosition(t_pos[i].x, t_pos[i].y, t_pos[i].z, i-1);
	end
end

local SetBattleEndUIDelayTime = 0;
local BattleScoreRollTime = 0.5;
local t_CupIconEffectInfo = {curScale=1, scaleRange=0.015};
local WaitWinPlayerEffectTime = 0;	
local WaitDefeatPlayerShow = 0;

function BattleEndFrame_OnUpdate()
	if LogPos then
		local ScreenX = 0;
		local ScreenY = 0;
		local ScreenZ = 0;
		local body = getglobal("BattleEndFrameView"):getActorbody(0);
		if body then
			ScreenX, ScreenY, ScreenZ = body:getBindPointPos(109, ScreenX, ScreenY, ScreenZ);
		end

		local posX = getglobal("BattleEndFrameShadow1"):GetLeft();
		local posY = getglobal("BattleEndFrameShadow1"):GetTop();
	end

	if BattleEndAutoGoToMainMenuTime > 0 then		--客机收到房主再来一局邀请后，30s没应答 自动返回主界面
		BattleEndAutoGoToMainMenuTime = BattleEndAutoGoToMainMenuTime - arg1;
		if BattleEndAutoGoToMainMenuTime <= 0 then
			BattleFrameBackMenu_OnClick();
		end
	end

	--0.5s后播放胜利者特效，设置玩家信息界面
	if WaitWinPlayerEffectTime > 0 then
		WaitWinPlayerEffectTime = WaitWinPlayerEffectTime - arg1;
		if WaitWinPlayerEffectTime <= 0 then
			WaitWinPlayerEffectTime = 0;
			for i=1, #(t_WinPlayerInfo) do
				if i <= ShowPlayer_MaxNum then

					local briefInfo = t_WinPlayerInfo[i];
					getglobal("BattleEndFrameView"):playEffect("scene_halo", i-1);

					local teamId = briefInfo.teamid + 1;
					local playerInfo = getglobal("BattleEndFramePlayerInfo"..i);

					--成就
					local data = {};
					data.uiName = playerInfo:GetName();
					data.uin = briefInfo.uin;
					EndBattleAchievePanel:ShowAchieveOnBattleEnd(data);--显示ui数据

					--名字
					local nickName = getglobal("BattleEndFramePlayerInfo"..i.."NickName");
					local offsetX = nickName:GetTextExtentWidth(briefInfo.nickname)/2;
					nickName:SetPoint("topleft", playerInfo:GetName(), "top", -offsetX, 11);
					if t_TeamInfo[teamId] ~= nil then 
						nickName:SetText(AccountManager:getBlueVipIconStr(briefInfo.uin)..briefInfo.nickname, t_TeamInfo[teamId].r, t_TeamInfo[teamId].g, t_TeamInfo[teamId].b);
					end 	
					--房主标志
					local hostIcon = getglobal("BattleEndFramePlayerInfo"..i.."HostIcon")
					if ClientCurGame:isHost(briefInfo.uin) then
						hostIcon:Show();
					else
						hostIcon:Hide();
					end

					if isEducationalVersion then
						hostIcon:Hide();
						getglobal("BattleEndFramePlayerInfo1Frame"):Hide();
						getglobal("BattleEndFramePlayerInfo1Mask"):Hide();
						getglobal("BattleEndFramePlayerInfo1Icon"):Hide();						
					end
				end
			end
		end
	end

	--3s后展示失败者，设置玩家信息界面
	if WaitDefeatPlayerShow > 0 then
		WaitDefeatPlayerShow = WaitDefeatPlayerShow - arg1;
		if WaitDefeatPlayerShow <= 0 then
			WaitDefeatPlayerShow = 0;
			SetBattleEndUIDelayTime = 0.5;
			local view = getglobal("BattleEndFrameView");
			local t_angle = {0, 0, 0, -25, 25, 20};
			PlayDefeatAnimCoolDown = 4;
			for i=1, #(t_DefeatPlayerInfo) do
				local index = i+#(t_WinPlayerInfo);
				if index <= ShowPlayer_MaxNum then

					local briefInfo = t_DefeatPlayerInfo[i];
	 
					table.insert(t_PlayAnimIndex.defeat, index-1);
					local seatSkinDef = nil;
					if briefInfo.customjson and string.len(briefInfo.customjson) > 0 then
						 if g_MpActorAvatarInfo_Table[briefInfo.uin] then
		                    seatSkinDef = g_MpActorAvatarInfo_Table[briefInfo.uin];
		                end
					end

					local body = nil;

					if isEducationalVersion then
						body = UIActorBodyManager:getPlayerBody(1, 1, 0, false, false, "");
					elseif seatSkinDef and seatSkinDef.skin then
						local bodyId = briefInfo.skinid + i;
						body = UIActorBodyManager:getBattleEndBody(briefInfo.uin, 2, bodyId);
						if body then SeatInfoSetAvatarBody(body, seatSkinDef, briefInfo.uin); end
		            else
						local playerIndex = ComposePlayerIndex(briefInfo.model, briefInfo.geniuslv, briefInfo.skinid);
						body = UIActorBodyManager:getBattleEndBody(briefInfo.uin, 1, playerIndex);
		            end

					if body then
						if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
							view:attachActorBody(body, index-1)
						else
							body:attachUIModelView(view, index-1);
						end
						view:playActorAnim(100130, index-1);
						view:setRotateAngle(t_angle[index], index-1);

						local teamId = briefInfo.teamid + 1;
						local playerInfo = getglobal("BattleEndFramePlayerInfo"..index);

						--成就
						local data = {};
						data.uiName = playerInfo:GetName();
						data.uin = briefInfo.uin;
						EndBattleAchievePanel:ShowAchieveOnBattleEnd(data);--显示ui数据

						--名字
						local nickName = getglobal("BattleEndFramePlayerInfo"..index.."NickName");
						local offsetX = nickName:GetTextExtentWidth(briefInfo.nickname)/2;
						nickName:SetPoint("topleft", playerInfo:GetName(), "top", -offsetX, 11);
						nickName:SetText(AccountManager:getBlueVipIconStr(briefInfo.uin)..briefInfo.nickname, t_TeamInfo[teamId].r, t_TeamInfo[teamId].g, t_TeamInfo[teamId].b);

						--房主标志
						local hostIcon = getglobal("BattleEndFramePlayerInfo"..index.."HostIcon")
						if ClientCurGame:isHost(briefInfo.uin) then
							hostIcon:Show();
						else
							hostIcon:Hide();
						end

						if isEducationalVersion then
							hostIcon:Hide();
							getglobal("BattleEndFramePlayerInfo1Frame"):Hide();
							getglobal("BattleEndFramePlayerInfo1Mask"):Hide();
							getglobal("BattleEndFramePlayerInfo1Icon"):Hide();							
						end
					end
				end
			end
		end
	end
	
	--自动再来一局
	if AutoReOpenTime > 0 and arg1 and tonumber(arg1) then
		AutoReOpenTime = AutoReOpenTime - tonumber(arg1);
		if AutoReOpenTime < 0 then
			BattleFrameReopen_OnClick();
		else
			local time = math.ceil(AutoReOpenTime);
			local text = GetS("4886").."("..time..")";
			getglobal("BattleEndFrameReopenName"):SetText(text);
		end
	end

	--设置位置
	if SetBattleEndUIDelayTime > 0 and arg1 and tonumber(arg1) then
		SetBattleEndUIDelayTime = SetBattleEndUIDelayTime - tonumber(arg1);
		if SetBattleEndUIDelayTime < 0 then
			SetBattleEndUIPosition();
		end
	end

	t_CupIconEffectInfo.curScale = t_CupIconEffectInfo.curScale - t_CupIconEffectInfo.scaleRange;

	for i=1, ShowPlayer_MaxNum do
		local playerInfo = getglobal("BattleEndFramePlayerInfo"..i);

		--分数随机
		local len = playerInfo:GetClientUserData(1);
		if playerInfo:IsShown() and len > 0 then
			local score = playerInfo:GetClientUserData(0);

			BattleScoreRollTime = BattleScoreRollTime - tonumber(arg1);
			if BattleScoreRollTime < 0 then
				BattleScoreRollTime = 0.5;
				playerInfo:SetClientUserData(1, len-1);
				if len == 1 then
					getglobal("BattleEndFramePlayerInfo"..i.."Score"):SetText(score);
					return;
				else
					len = len - 1;
				end
			end

			local fixedScore = score - math.mod(score, math.pow(10,len));
			local randomStart = math.pow(10,len-1);
			local randomEnd = math.pow(10,len)-1;
			score = fixedScore + math.random(randomStart, randomEnd);
			
			getglobal("BattleEndFramePlayerInfo"..i.."Score"):SetText(score);
		end

		--影子跟随
		local view = getglobal("BattleEndFrameView");
		local body = view:getActorbody(i-1)
		
		if getglobal("BattleEndFrameShadow"..i):IsShown() and body and t_PlayerCenterBindPos[i] then
			local x = 0;
			local y = 0;
			local z = 0;
			x, y, z =body:getBindPointPos(105, x,y,z);

			shadowScale = t_PlayerCenterBindPos[i].y/ ((y-t_PlayerCenterBindPos[i].y)*0.2+t_PlayerCenterBindPos[i].y);
			getglobal("BattleEndFrameShadow"..i):SetSize(125*shadowScale, 24*shadowScale);

			local ScreenX = 0;
			local ScreenY = 0;
		
			ScreenX, ScreenY =view:getPointToScreen(ScreenX,ScreenY,body,109, i-1);
			local scale = UIFrameMgr:GetScreenScale();
			ScreenX = math.ceil(ScreenX/scale);
			ScreenY = math.ceil( (ScreenY-0)/scale );

		--	print("kekeke getPlayerBody33333 ScreenX ScreenY", ScreenX, ScreenY);
			getglobal("BattleEndFrameShadow"..i):SetPoint("center", "BattleEndFrame", "topleft", ScreenX, ScreenY)
		end
	end

	if t_CupIconEffectInfo.curScale < 0.9 then
		t_CupIconEffectInfo.scaleRange = -0.03;
	elseif t_CupIconEffectInfo.curScale > 1 then
		t_CupIconEffectInfo.scaleRange = 0.015;
	end

	--每隔一段时间播放胜利动作
	if arg1 and tonumber(arg1) then
		PlayWinAnimCoolDown = PlayWinAnimCoolDown - tonumber(arg1)
		if PlayWinAnimCoolDown < 0 then
			PlayWinAnimCoolDown = 5;
			for i=1, #(t_PlayAnimIndex.win) do
				if i <= ShowPlayer_MaxNum then
					getglobal("BattleEndFrameView"):playActorAnim(100100, t_PlayAnimIndex.win[i]);
					getglobal("BattleEndFrameView"):playActorAnim(100155, t_PlayAnimIndex.win[i]);
				end
			end
		end

		--每隔一段时间播放失败动作
		PlayDefeatAnimCoolDown = PlayDefeatAnimCoolDown - tonumber(arg1);
		if PlayDefeatAnimCoolDown < 0 then
			PlayDefeatAnimCoolDown = 4;
			for i=1, #(t_PlayAnimIndex.defeat) do
				if i <= ShowPlayer_MaxNum then
					getglobal("BattleEndFrameView"):playActorAnim(100130, t_PlayAnimIndex.defeat[i]);
				end
			end
		end
	end
	

	--背景渐变
	local alpha = getglobal("BattleEndFrameBkg"):GetBlendAlpha();
	if alpha < 1 then
		alpha = alpha + 0.12;
		if alpha > 1 then
			alpha = 1;
			getglobal("BattleEndFrameBkg"):SetBlendAlpha(alpha);
			BattleEndFrameInit();
		else
			getglobal("BattleEndFrameBkg"):SetBlendAlpha(alpha);
		end
	end
end

function SetBattleEndUIPosition()
	local view = getglobal("BattleEndFrameView");
	
	for i=1, ShowPlayer_MaxNum do
		local body = view:getActorbody(i-1)
		if body then
			local ScreenX = 0;
			local ScreenY = 0;
		
			ScreenX, ScreenY =view:getPointToScreen(ScreenX,ScreenY,body,0, i-1);
			local scale = UIFrameMgr:GetScreenScale();
			ScreenX = math.ceil(ScreenX/scale);
			ScreenY = math.ceil( (ScreenY-105)/scale );

			getglobal("BattleEndFramePlayerInfo"..i):SetPoint("center", "BattleEndFrame", "topleft", ScreenX, ScreenY);
			getglobal("BattleEndFramePlayerInfo"..i):Show();
		
			ScreenX, ScreenY =view:getPointToScreen(ScreenX,ScreenY,body,109, i-1);
			ScreenX = math.ceil(ScreenX/scale);
			ScreenY = math.ceil( (ScreenY-0)/scale );

			getglobal("BattleEndFrameShadow"..i):SetPoint("center", "BattleEndFrame", "topleft", ScreenX, ScreenY);
			getglobal("BattleEndFrameShadow"..i):Show();


			local x = 0;
			local y = 0;
			local z = 0;
			x, y, z =body:getBindPointPos(105, x,y,z);
			t_PlayerCenterBindPos[i] = {y=y};
		end
	end
end

function BattleEndFrame_OnShow()
	local getglobal = _G.getglobal;

	if not getglobal("BattleEndFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
		standReportEvent("415", "GAME_END", "-", "view", G_GetGameStandReportDataA()) --hrl 2021.11.02
	end

	for i=1, ShowPlayer_MaxNum do
		getglobal("BattleEndFramePlayerInfo"..i):Hide();
		getglobal("BattleEndFrameShadow"..i):Hide();
		getglobal("BattleEndFramePlayerInfo"..i.."CupIcon"):Hide();
		
		getglobal("BattleEndFrameView"):stopEffect("scene_halo", i-1);
	end

	--比赛结果清空
	getglobal("BattleEndFrameResultBkg"):Hide();
	getglobal("BattleEndFrameResult"):SetText("");

	--播放动作清空
	t_PlayAnimIndex = { win={}, defeat={}};

	--最高分
	HighestScore = 0;

	--胜利的人清空
	t_WinPlayerInfo = {};
	--失败的人清空
	t_DefeatPlayerInfo = {};

	--再来一局清空
	AutoReOpenTime = -1;
	getglobal("BattleEndFrameReopen"):Hide();

	--加入清空
	if IsCurRoomOwner() or BattleEndAutoGoToMainMenuTime <= 0 then
		getglobal("BattleEndFrameJoinBtn"):Hide()
	end

	--分享按钮清空
	-- getglobal("BattleEndFrameShareBtn"):Hide();

	--关闭按钮清空
	getglobal("BattleEndFrameCloseBtn"):Hide();

	--计分板按钮清空
	getglobal("BattleEndFrameScoreboardBtn"):Hide();

	--背景特效清空
	getglobal("BattleEndFrameView"):deleteBackgroundEffect("particles/Ribbon.ent");
	getglobal("BattleEndFrameView"):deleteBackgroundEffect("particles/Ribbon_h.ent");

	--主界面隐藏
	PlayMainFrameUIHide();

	--屏幕特效
	getglobal("ScreenEffectFrame"):Hide();

	getglobal("BattleEndFrameBkg"):SetBlendAlpha(0.1);

	if CurWorld and CurWorld:getOWID() == NewbieWorldId2 then
		getglobal("BattleEndFrameScoreboardBtn"):Hide()
		-- getglobal("BattleEndFrameReopen"):Hide()
		getglobal("BattleEndFrameShareBtn"):Hide()
		getglobal("BattleEndFrameCloseBtn"):SetPoint("bottom", "BattleEndFrame", "bottom", 5, -45)
		standReportEvent("3801", "NEWPLAYER_MAP_FINISH", "Quite", "view")
	else
		getglobal("BattleEndFrameScoreboardBtn"):Show()
		-- getglobal("BattleEndFrameReopen"):Show()
		getglobal("BattleEndFrameShareBtn"):Show()
		getglobal("BattleEndFrameCloseBtn"):SetPoint("bottom", "BattleEndFrame", "bottom", -160, -45)

		standReportEvent("415", "GAME_END", "Share", "view", G_GetGameStandReportDataA()) --hrl 2021.11.02
		standReportEvent("415", "GAME_END", "Restart", "view", G_GetGameStandReportDataA()) --hrl 2021.11.02
	end
	--迷你基地隐藏游戏结算后的分享按钮
	if MiniBaseManager:isMiniBaseGame() then
		getglobal("BattleEndFrameShareBtn"):Hide()
	end

	--增加原生广告
	local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()
	-- ShowGameTips("reviveAdPositionId=" .. reviveAdPositionId)
	if reviveAdPositionId ~= 105 then --非开发者模式
		-- ShowGameTips("增加原生广告1") -- test
		ShowNativeAd(
			61,
			getglobal("BattleEndFrameNativeAd"):GetRealWidth(),
			getglobal("BattleEndFrameNativeAd"):GetRealHeight(),
			22,
			GetScreenHeight() - getglobal("BattleEndFrameNativeAd"):GetRealHeight()
		)
	end
end

function BattleEndFrameInit()
	ClientMgr:playSound2D("sounds/pvp/end.ogg", 1);
	ScaleRange = 0.015;
	t_CupIconEffectInfo = {curScale=1, scaleRange=0.015};
	PlayDefeatAnimCoolDown = 10;

	----new----
	WaitWinPlayerEffectTime = 0;
	SetBattleEndUIDelayTime = 0.5;

	local teamNum = ClientCurGame:getNumTeam();
	local num = ClientCurGame:getNumPlayerBriefInfo();

	local t = {};	--所有的玩家的信息
	local uin_list ={}; --所有玩家的uin集合，用来初始化成就信息
	for i=1, num do
		local briefInfo = ClientCurGame:getPlayerBriefInfo(i-1);
		if briefInfo ~= nil then
			table.insert(t, briefInfo);
			table.insert(uin_list,briefInfo.uin);
		end
	end



	local myBriefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
	if myBriefInfo ~= nil then
		table.insert(t, myBriefInfo);
		table.insert(uin_list,myBriefInfo.uin);
	end

	--UIAchievementMgr:NotifyEvent(AchievementDefine.InitAchieveListOnBattleEnd, uin_list);

	--按分数排序
	table.sort(t,
		function(a, b)
			if ClientMgr:clientVersion() < 23*256 then
				return a.cgamevar[0] > b.cgamevar[0];
			else
				return LuaInterface:band(a.cgamevar[0], 0xffffff) > LuaInterface:band(b.cgamevar[0], 0xffffff);
			end
		end		
	);

	print("kekeke AllPlayerInfo", t);
	if teamNum <= 1 then
		if ClientMgr:clientVersion() < 23*256 then
			HighestScore = t[1].cgamevar[0];
		else
			HighestScore = LuaInterface:band(t[1].cgamevar[0], 0xffffff);
		end
		print("kekeke HighestScore", HighestScore);
		local totalNum = 0;
		local t_Defeat = {};

		for i=1, #(t) do
			local result = GetPlayerGameResult(t[i]);
			if totalNum < 6 and result == 1 then		--胜利的人
				table.insert(t_WinPlayerInfo, t[i]);
				totalNum = totalNum + 1;
			end

			if result == 2 or result == 3 then		--失败
				table.insert(t_Defeat, t[i]);
			end
		end
		
		local showDefeatNum = 6 - totalNum;
		for i=1, showDefeatNum do
			table.insert(t_DefeatPlayerInfo, t_Defeat[i]);
		end	

		if #(t_WinPlayerInfo) == 0 and #(t_DefeatPlayerInfo) == 0 then		--没有胜利和失败的人
			for i=1, 6 do						--取分数最高的6人为胜利组
				if i <= #(t) then
					table.insert(t_WinPlayerInfo, t[i]);
				end
			end
		end
	else
		local t_Defeat = {};
		for i=1, #(t) do
			local result = GetPlayerGameResult(t[i]);
			print("kekeke t_Defeat ", i, result);
			if result == 1 then		--取胜利队伍为胜利组
				table.insert(t_WinPlayerInfo, t[i]);
				if not getglobal("BattleEndFrameResultBkg"):IsShown() then
					getglobal("BattleEndFrameResultBkg"):Show();
					local teamId = t[i].teamid + 1;
					local text = GetS(t_TeamInfo[teamId].name)..GetS(270);
					getglobal("BattleEndFrameResult"):SetText(text);
					getglobal("BattleEndFrameResult"):SetTextColor(t_TeamInfo[teamId].r, t_TeamInfo[teamId].g, t_TeamInfo[teamId].b);
				end
			elseif result == 2 or result == 3 then 	--失败
				table.insert(t_Defeat, t[i]);
			end
		end

		print("kekeke t_Defeat", t_Defeat);
		
		if #t_WinPlayerInfo > 0 then
			if ClientMgr:clientVersion() < 23*256 then
				HighestScore = t_WinPlayerInfo[1].cgamevar[0];
			else
				HighestScore = LuaInterface:band(t_WinPlayerInfo[1].cgamevar[0], 0xffffff);
			end
		end

		if num <= 6 then										--小于等于6人
			local showDefeatNum = 6 - #t_WinPlayerInfo;	
			for i=1, showDefeatNum do						--取失败组最高分的依次填满6人
				table.insert(t_DefeatPlayerInfo, t_Defeat[i]);
			end
		
			--按队伍排序
			table.sort(t_DefeatPlayerInfo,
				function(a, b)
					return a.teamid < b.teamid;
				end		
			);
		end
	end

	local view = getglobal("BattleEndFrameView");
	local t_angle = {0, 0, 0, -25, 25, 20};
	if #(t_WinPlayerInfo) > 0 then
		WaitWinPlayerEffectTime = 0.5;
		WaitDefeatPlayerShow = 1.5;
	else
		WaitDefeatPlayerShow = 0.05;
	end

	print("kekeke t_WinPlayerInfo-------------------------")
	for i=1, #t_WinPlayerInfo do
		print("kekeke t_WinPlayerInfo uin", i, t_WinPlayerInfo[i].uin)
	end
	print("kekeke t_DefeatPlayerInfo1-------------------------")
	for i=1, #t_DefeatPlayerInfo do
		print("kekeke t_DefeatPlayerInfo uin", i, t_DefeatPlayerInfo[i].uin)
	end

	--胜利的人
	for i=1, #(t_WinPlayerInfo) do
		if i <= ShowPlayer_MaxNum then
			local seatSkinDef = nil;
			local briefInfo = t_WinPlayerInfo[i];
			if string.len(briefInfo.customjson) > 0 then
				if g_MpActorAvatarInfo_Table[briefInfo.uin] then
					seatSkinDef = g_MpActorAvatarInfo_Table[briefInfo.uin];
				end
			end
			
			local body = nil
			if isEducationalVersion then
				body = UIActorBodyManager:getPlayerBody(1, 1, 0, false, false, "");
			elseif seatSkinDef and seatSkinDef.skin then
				local bodyId = briefInfo.skinid + i;
				body = UIActorBodyManager:getBattleEndBody(briefInfo.uin, 2, bodyId);
				if body then SeatInfoSetAvatarBody(body, seatSkinDef, briefInfo.uin); end
			else
				local playerIndex = ComposePlayerIndex(briefInfo.model, briefInfo.geniuslv, briefInfo.skinid);
				body = UIActorBodyManager:getBattleEndBody(briefInfo.uin, 1, playerIndex);
			end

			if body then
				if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
					view:attachActorBody(body, i-1)
				else
					body:attachUIModelView(view, i-1);
				end
				PlayWinAnimCoolDown = 0;
				view:setRotateAngle(t_angle[i], i-1);
				table.insert(t_PlayAnimIndex.win, i-1);
			end
		end
	end

	--再来一局按钮
	if CurWorld:isGameMakerRunMode() and IsCurRoomOwner() and ClientCurGame:getGameStage() == 4 then
		if CurWorld and CurWorld:getOWID() ~= NewbieWorldId2 then
			getglobal("BattleEndFrameReopen"):Show();
		end
		AutoReOpenTime = 15;
		local text = GetS("4886").."("..AutoReOpenTime..")";
		getglobal("BattleEndFrameReopenName"):SetText(text);
	end

	--再来一次按钮（开发者模式的单机）
	if CurWorld:isGameMakerRunMode() and AccountManager:getMultiPlayer() == 0 and ClientCurGame:getGameStage() == 4 then
		if CurWorld and CurWorld:getOWID() ~= NewbieWorldId2 then
			getglobal("BattleEndFrameReopen"):Show();
		end
		getglobal("BattleEndFrameReopenName"):SetText(GetS("4886"));
	end

	--分享按钮
	-- if SdkManager:isShareEnabled() then
	-- 	getglobal("BattleEndFrameShareBtn"):Show();
	-- end

	--关闭按钮
	getglobal("BattleEndFrameCloseBtn"):Show();
	standReportEvent("415", "GAME_END", "GameExit", "view", G_GetGameStandReportDataA()) --hrl 2021.11.02

	--计分板按钮
	if CurWorld and CurWorld:getOWID() ~= NewbieWorldId2 then
		getglobal("BattleEndFrameScoreboardBtn"):Show();
	end
	if HasUIFrame("BattleEndFrameScoreboardBtnUvA") then
		getglobal("BattleEndFrameScoreboardBtnUvA"):Hide();
		if not AccountManager:getNoviceGuideState("scoreboardbtnuva") then
			getglobal("BattleEndFrameScoreboardBtnUvA"):SetUVAnimation(50, true);
			getglobal("BattleEndFrameScoreboardBtnUvA"):Show();
			AccountManager:setNoviceGuideState("scoreboardbtnuva", true) ;
		end
	end

	--背景特效
	if CurMainPlayer ~= nil and CurMainPlayer.getGameResults and CurMainPlayer:getGameResults() ~= 2 then
		getglobal("BattleEndFrameView"):addBackgroundEffect("particles/Ribbon.ent", 0, 80, 150);
	end

	--皇冠
	if #(t_WinPlayerInfo) > 0 then
		getglobal("BattleEndFrameView"):addBackgroundEffect("particles/Ribbon_h.ent", 0, 140, 600);
	end

	--主界面显示
	PlayMainFrameUIShow();
	
	--比分栏画面层级
	getglobal("BattleBtn"):SetFrameStrataInt(4);
	getglobal("BattleBtn"):SetFrameLevel(6100);
	getglobal("BattleBtnTime"):Hide();

	getglobal("BattleEndShadeFrame"):Hide();

	--地图描述
	local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
	local briefInfo = nil;
	if IsRoomOwner() or AccountManager:getMultiPlayer() <= 0 then
		briefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
	elseif ClientCurGame and ClientCurGame.getHostUin then
		briefInfo = ClientCurGame:findPlayerInfoByUin(ClientCurGame:getHostUin());
	end

	print("kekeke battle MapDesc", worldDesc, briefInfo)
	if worldDesc and briefInfo then
		local text = GetS(1223, worldDesc.worldname, worldDesc.realNickName.."("..worldDesc.realowneruin..")", briefInfo.nickname.."("..briefInfo.uin..")");

		if HasUIFrame("BattleEndFrameMapDesc") then
			getglobal("BattleEndFrameMapDesc"):SetText(text);
		end
	end

	--扩展UI
	if G_Battle_UI then
		for k, v in pairs(G_Battle_UI) do
			if v.text then
				if v.text ~= "" and HasUIFrame(v.uiName) then
					getglobal(v.uiName):Show();
					getglobal(v.uiName):SetText(v.text);
				else
					getglobal(v.uiName):Hide();
				end
			end

			if v.isShow ~= nil then
				print("kekeke AutoReOpenTime v.uiName", v.uiName, v.isShow);
			end
			if v.isShow ~= nil and v.isShow == false then
				if getglobal(v.uiName):IsShown() and v.uiName == 'BattleEndFrameReopen' then
					print("kekeke AutoReOpenTime");
					AutoReOpenTime = 0;
				end

				getglobal(v.uiName):Hide();
			end
		end
	end

	if isEducationalVersion then
		BattleEndFrameOnShow_Edu()
	end	

	--上报地图结果（暑期奥特曼活动）
	if WorldMgr and WorldMgr.getFromWorldID and ns_version.outman and type(ns_version.outman.time == "table") and type(ns_version.outman.mapId == "table") then
		local startTime = ns_version.outman.time[1]
		local endTime = ns_version.outman.time[2]
		if startTime and endTime and os.time() >= tonumber(startTime) and os.time() <= tonumber(endTime) then
			local id = WorldMgr:getFromWorldID()
			for _, _id in ipairs(ns_version.outman.mapId) do
				if id == tonumber(_id) then
					for _, info in ipairs(t_WinPlayerInfo) do
						if info.uin == AccountManager:getUin() then
							GetInst('UserTaskService'):ReqOutmanUpload({id = id},function (result, user_data)
								print("ReqOutmanUpload ret", result)
								-- ShowGameTips("ReqOutmanUpload ret:" .. table2json(result))
							end,{})
							break
						end
					end
					break
				end
			end
		end
	end
end

function canShowPlayerByIndex(index, num)
	local t_index = {3, 4, 2, 5, 1, 6};
	for i=1, num do
		if i <= #t_index then
			if t_index[i] == index then
				return true;
			end
		end
	end

	return false;
end

function BattleEndFrame_OnHide()
	if isEducationalVersion and not ClientCurGame then
		return;
	end

	if not getglobal("BattleEndFrame"):IsRehide() then
	   ClientCurGame:setOperateUI(false);
	end

	local view = getglobal("BattleEndFrameView");
	
	for i=1, 6 do
		local body = view:getActorbody(i-1)
		if body then
			if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
				view:detachActorBody(body, i-1)
			else
				body:detachUIModelView(view, i-1);
			end
		end
	end

	getglobal("BattleBtnTime"):Show();

	if G_Battle_UI then
		for k, v in pairs(G_Battle_UI) do 		
			if v.text then
				v.text = "";
			end

			if v.isShow ~= nil then
				v.isShow = true;
			end
		end
	end

	GetInst("GameSettlementGData"):SetAutoGoToMainMenuTime(0)

	RemoveNativeAd(61)
end
-------------------------------------------------------------BattleDeathFrame-----------------------------------------------
local DeathTime = 3;
function BattleDeathFrame_OnLoad()
	this:RegisterEvent("GE_MAINPLAYER_DIE");
	this:RegisterEvent("GE_CUSTOMGAME_STAGE");
	this:RegisterEvent("GE_PLAYERATTR_CHANGE");
end

function BattleDeathFrame_OnEvent()
	if arg1 == "GE_MAINPLAYER_DIE" then
		if ClientCurGame:isInGame() and (ClientCurGame:getGameStage() == 4 or (CurMainPlayer ~= nil and CurMainPlayer.getGameResults and CurMainPlayer:getGameResults()> 0) ) then return end

		if not CurWorld then return end

		local s=0;
		local reviveMode=0;
		reviveMode, s = CurWorld:getReviveMode(s);
		if reviveMode == 1 and ClientCurGame:isInGame() then
			DeathTime = s;
			getglobal("BattleDeathFrame"):Show();
		end
	elseif arg1 == "GE_CUSTOMGAME_STAGE" then
		if getglobal("BattleDeathFrame"):IsShown() then
			local s = DeathTime;
			getglobal("BattleDeathFrameTime"):SetText(GetS(449, s));
			if DeathTime == 0 then
				DeathTime = 3;
				if ClientCurGame:getMainPlayer():revive(0) then
					getglobal("BattleDeathFrame"):Hide();
				end
				return;
			end
			DeathTime = DeathTime - 1;
		end
	elseif arg1 == "GE_PLAYERATTR_CHANGE" then
		--现在death.lua是动态加载，death.lua中的界面没有show事件没监听，里面处理的BattleDeathFrame逻辑不生效
		if not MainPlayerAttrib then return end
		if MainPlayerAttrib:getHP() > 0 then
			if getglobal("BattleDeathFrame"):IsShown() then
				getglobal("BattleDeathFrame"):Hide();
			end
		end
	end
end

function BattleDeathFrame_OnShow()
	HideAllFrame("BattleDeathFrame", false);
	getglobal("GongNengFrame"):Hide();

	for i=1, #(t_DeathNeedHideFrame) do
		local frame = getglobal(t_DeathNeedHideFrame[i]);
		if frame:IsShown() then
			frame:Hide();
		end
	end
	if not getglobal("BattleDeathFrame"):IsReshow() then	
		ClientCurGame:setOperateUI(true);
		standReportEvent("412", "GAME_DIE_RE", "DieRe", "view", G_GetGameStandReportDataA()) --hrl 2021.11.02
	end

	--增加原生广告
	local reviveAdPositionId, authorUin, mapId = GetReviveAdPositionId()
	-- ShowGameTips("reviveAdPositionId=" .. reviveAdPositionId)
	if reviveAdPositionId ~= 105 then --非开发者模式
		-- ShowGameTips("增加原生广告2") -- test
		ShowNativeAd(
			60,
			getglobal("BattleDeathFrameNativeAd"):GetRealWidth(),
			getglobal("BattleDeathFrameNativeAd"):GetRealHeight(),
			22,
			0
		)
	end
	GetInst("WeekendCarnivalMgr"):roleDie()
end

function BattleDeathFrame_OnHide()
	if IsInHomeLandMap and IsInHomeLandMap() then
		getglobal("GongNengFrame"):Hide();
		ShowHomeMainUI()
	else
		getglobal("GongNengFrame"):Show();
	end
	if not getglobal("BattleDeathFrame"):IsRehide() then	
		ClientCurGame:setOperateUI(false);
	end

	-- UGC内容重新显示
	GetInst("UGCCommon"):AfterHideAllUI()
	
	RemoveNativeAd(60)

	GetInst("WeekendCarnivalMgr"):roleRevival()
end

function BattleDeathFrame_OnUpdate()
	if not ClientCurGame:isInGame() then
		getglobal("BattleDeathFrame"):Hide();
	end
end


--------------------------------------------结算界面成就UI显示------------------------------------------------------
EndBattleAchievePanel = {

	AchieveDataList = {};

	---------------------------------------------------------------------------------------------
	--请求获取多个uin的使用勋章情况
	ReqUseAchieveByUinlist = function(self,uinList)
		local achieveCanShow = UIAchievementMgr:AchieveModuleCanShow();
		if achieveCanShow ==false then return end;

		print("PEC_EndBattleAchievePanel:ReqUseAchieveByUinlist()")
		if uinList == nil or next(uinList) == nil then return 	end

		local uinStr = "";
		local num = #uinList;
		for  i =1, num do
			if i ==num then
				uinStr = uinStr ..uinList[i];
			else
				uinStr = uinStr ..uinList[i]..",";
			end
		end

		local url_ =  g_http_common..'/miniw/achieve?act=query_others_achieve_task&op_uin='..uinStr..'&' .. http_getS1();
		Log( url_ );
		ns_http.func.rpc( url_, self.RespUseAchieveByUinlist , nil, nil, ns_http.SecurityTypeHigh);   --achieve

	end,

	RespUseAchieveByUinlist = function(ret)
		print("PEC_EndBattleAchievePanel:RespUseAchieveByUinlist()",ret)
		if ret and ret.ret == 0 then
			for k,v in pairs(ret.data) do
				EndBattleAchievePanel.AchieveDataList[v.uin] = v.used_achieve;
			end
		end
	end,

	ShowAchieveOnBattleEnd = function(self,data) -- data.uiName ,data.uin
		print("PEC_EndBattleAchievePanel:ShowAchieveOnBattleEnd()")

		local ui_icon = getglobal(data.uiName.."Icon");
		local ui_frame = getglobal(data.uiName.."Frame");
		local ui_effect = getglobal(data.uiName.."Mask");

		ui_icon:Hide();
		ui_frame:Hide();

		local uin_str = tostring(data.uin);
		local achieveData = self.AchieveDataList[uin_str] or {};

		if achieveData == nil or next(achieveData) == nil then return end

		UIAchievementMgr.t_data:InitAchieveResources();
		local icon_Res = UIAchievementMgr:GetIconResources(achieveData.id);
		local frame_Res = UIAchievementMgr:GetFrameResources(achieveData.level);

		ui_effect:Hide();
		if achieveData.level ==4 then
			ui_effect:Show();
			ui_effect:SetTexture("ui/mobile/effect/ico_medalf_4.png");
			ui_effect:SetUVAnimation(100, true);
		elseif achieveData.level ==5 then
			ui_effect:Show();
			ui_effect:SetTexture("ui/mobile/effect/ico_medalf_5.png");
			ui_effect:SetUVAnimation(100, true);
		end

		if icon_Res ~= nil then
			ui_icon:SetTextureHuiresXml("ui/mobile/texture2/achievement.xml");
			ui_icon:SetTexUV(icon_Res.icon_name);
			ui_icon:Show();
		end

		if frame_Res ~= nil then
			ui_frame:SetTextureHuiresXml("ui/mobile/texture2/achievement.xml");
			ui_frame:SetTexUV(frame_Res);
			ui_frame:Show();
		end
	end,
}
