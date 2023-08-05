function SpectatorLastPlayerBtn_OnClick()
	local playernum = ClientCurGame:getNumPlayerBriefInfo();
	local SpectatorUin = 0;
	local teamid = 0;
	if CurMainPlayer ~= nil then
		SpectatorUin = CurMainPlayer:getToSpectatorPlayerUin();
		teamid	= CurMainPlayer:getTeam();
	end
	
	if (teamid > 0 and ClientCurGame:getTeamResults(teamid) == 0) and teamid ~= 999 then
		Log('playernum='..playernum);
		for i = 1, playernum do
			local player = ClientCurGame:getPlayerBriefInfo(i - 1);
			if SpectatorUin == player.uin then
				if i - 1 >= 1 then
					 local playerlast = ClientCurGame:getPlayerBriefInfo(i - 2);
					 if playerlast.inSpectator == 0 and playerlast.teamid == teamid then
						CurMainPlayer:setToSpectatorPlayerUin(playerlast.uin);
						return;
					 end
				end
			end
		end
		
		for i = playernum, 1, -1 do
			local player = ClientCurGame:getPlayerBriefInfo(i - 1);
			if player.inSpectator == 0 and player.teamid == teamid then
				CurMainPlayer:setToSpectatorPlayerUin(player.uin);
				return;
			end
		end
	else
		Log('playernum='..playernum);
		for i = 1, playernum do
			local player = ClientCurGame:getPlayerBriefInfo(i - 1);
			if SpectatorUin == player.uin then
				if i - 1 >= 1 then
					 local playerlast = ClientCurGame:getPlayerBriefInfo(i - 2);
					Log('playerlast.inSpectator='..playerlast.inSpectator);
					 if playerlast.inSpectator == 0 then
						CurMainPlayer:setToSpectatorPlayerUin(playerlast.uin);
						return;
					 end
				end
			end
		end
		Log('112321313213');
		for i = playernum, 1, -1 do
			local player = ClientCurGame:getPlayerBriefInfo(i - 1);
			Log('player.inSpectator='..player.inSpectator);
			if player.inSpectator == 0 then
				CurMainPlayer:setToSpectatorPlayerUin(player.uin);
				return;
			end
		end
	end
end

function SpectatorNextPlayerBtn_OnClick()
	local playernum = ClientCurGame:getNumPlayerBriefInfo();
	local SpectatorUin = 0;
	local teamid = 0;
	if CurMainPlayer ~= nil then
		SpectatorUin = CurMainPlayer:getToSpectatorPlayerUin();
		teamid	= CurMainPlayer:getTeam();
	end
	
	if (teamid > 0 and ClientCurGame:getTeamResults(teamid) == 0) and teamid~= 999 then
		for i = 1, playernum do
			local player = ClientCurGame:getPlayerBriefInfo(i - 1);
			if SpectatorUin == player.uin then
				if i + 1 <= playernum then
					 local playerlast = ClientCurGame:getPlayerBriefInfo(i);
					 if playerlast.inSpectator == 0 and playerlast.teamid == teamid then
						CurMainPlayer:setToSpectatorPlayerUin(playerlast.uin);
						return;
					 end
				end
			end
		end
		
		for i = 1, playernum, 1 do
			local player = ClientCurGame:getPlayerBriefInfo(i - 1);
			if player.inSpectator == 0 and player.teamid == teamid then
				CurMainPlayer:setToSpectatorPlayerUin(player.uin);
				return;
			end
		end
	else
		for i = 1, playernum do
			local player = ClientCurGame:getPlayerBriefInfo(i - 1);
			if SpectatorUin == player.uin then
				if i + 1 <= playernum then
					 local playerlast = ClientCurGame:getPlayerBriefInfo(i);
					 if playerlast.inSpectator == 0 then
						CurMainPlayer:setToSpectatorPlayerUin(playerlast.uin);
						return;
					 end
				end
			end
		end
		
		for i = 1, playernum, 1 do
			local player = ClientCurGame:getPlayerBriefInfo(i - 1);
			if player.inSpectator == 0 then
				CurMainPlayer:setToSpectatorPlayerUin(player.uin);
				return;
			end
		end
	end
end
local spectatorPlayerUin = 0;
function SpectatorSwitchTypeBtn_OnClick()
	if CurMainPlayer == nil then
		return;
	end
    if CurMainPlayer:getSpectatorType() == 0 then
		CurMainPlayer:setSpectatorType(1); 
		local spectoruin = CurMainPlayer:getToSpectatorUin(); 
		local spectorplayer = ClientCurGame:findPlayerInfoByUin(spectoruin);
		if spectorplayer ~= nil then
			getglobal("SpectatorPlayerNameContent"):SetText(GetS(9078)..spectorplayer.nickname); 
		end
		if ClientMgr:isMobile() then
			getglobal("PlayMainFrameFly"):Hide();	
			CurMainPlayer:setFlying(false);
		end
	else
		CurMainPlayer:setSpectatorType(0); 
		getglobal("SpectatorPlayerNameContent"):SetText(GetS(6109));
		if ClientMgr:isMobile() then
			getglobal("PlayMainFrameFly"):Show();	
		end
	end
	if spectatorPlayerUin == 0 then
		SpectatorNextPlayerBtn_OnClick();
	end
end

function SpectatorFrame_OnUpdate()
	if ClientCurGame:isInGame() == false then
		return;
	end
	if CurMainPlayer:isInSpectatorMode() == false then
		return;
	end
	
	local spectoruin = CurMainPlayer:getToSpectatorPlayerUin(); 
	local spectorplayer = ClientCurGame:findPlayerInfoByUin(spectoruin);
	if 	spectorplayer ~= nil and spectorplayer.inSpectator == 1 then
			SpectatorNextPlayerBtn_OnClick();
	elseif spectorplayer ~= nil and spectatorPlayerUin ~= spectorplayer.uin then
		if CurMainPlayer:getSpectatorType() == 1 then
			getglobal("SpectatorPlayerNameContent"):SetText(GetS(9078)..spectorplayer.nickname); 
		end
		spectatorPlayerUin = spectorplayer.uin;
	elseif spectorplayer == nil and spectatorPlayerUin ~= 0 then
			SpectatorNextPlayerBtn_OnClick();
	end
end

