
function MultiplayerLobbyFrameHelpBtn_OnClick()
	SetGameHelpFrame(GetS(3748), GetS(3749));
end

function MultiplayerLobbyFrameCloseBtn_OnClick()
	getglobal("MultiplayerLobbyFrame"):Hide();
	-- getglobal("MiniLobbyFrame"):Show();
	ShowMiniLobby() --mark by hfb for new minilobby
end

function MultiplayerLobbyFrameLanRoom()
	if getglobal("LoadLoopFrame"):IsShown() then
		return;
	end
	if AccountManager:loginRoomServer(true) then
		ShowLoadLoopFrame(true, "file:multiplayerlobby -- func:MultiplayerLobbyFrameLanRoom");
		IsLanRoom = true;
	else
		ShowGameTips(GetS(506), 3);
	end
end

function MultiplayerLobbyFrameRoom()	
	if get_game_env() == 1 and PlatformUtility:isDevBuild() then
		ShowGameTipsWithoutFilter("env1提示:已废弃请使用 JumpToMultiplayer或RequestLoginRoomServer")
	end
	Log("MultiplayerLobbyFrameRoom:");

	--新增审核账号禁止联机功能，但审核开发者广告的仍可联机
	local checker_uin = AccountManager:getUin()
	if IsUserOuterChecker(checker_uin) and not DeveloperAdCheckerUser(checker_uin) then
		ShowGameTips(GetS(100300), 3);
		return;
	end

	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3);
		return;
	end
	if getglobal("LoadLoopFrame"):IsShown() then
		return;
	end

	if AccountManager:loginRoomServer(false) then
		ShowLoadLoopFrame(true, "file:multiplayerlobby -- func:MultiplayerLobbyFrameRoom");
		IsLanRoom = false;
	end
end

function MultiplayerLobbyFrame_OnLoad()
	this:RegisterEvent("GIE_RSCONNECT_RESULT");

	getglobal("MultiplayerLobbyFrameTips"):SetText(GetS(361)..ClientMgr:clientVersionStr());
end

function MultiplayerLobbyFrame_OnEvent()
	local prefix = GetInst("RoomService").EVT_GEN_PREFIX_JUMP_ROOM_WITH_PARAM
	if GetInst("UIEvtHook"):EventHook(arg1, GameEventQue:getCurEvent())
	and GetInst("UIEvtHook"):EventHook(arg1, GameEventQue:getCurEvent(), prefix) then
		return
	end
	if arg1 == "GIE_RSCONNECT_RESULT" then
		print("kekeke GIE_RSCONNECT_RESULT", t_autojump_service.play_together.anchorUin);
		if t_autojump_service.play_together.anchorUin > 0 then
			local ge = GameEventQue:getCurEvent();
			t_autojump_service.play_together.OnRespLoginRoomServer(ge.body.roomseverdata.result, ge.body.roomseverdata.detailreason);
		elseif getglobal("FriendFrame"):IsShown() then
			--好友界面的追踪功能的情况, 过滤, 这里不要触发.
		elseif IsUIFrameShown("ComeBackFrame") then
			--回流也不要显示
		-- elseif getglobal("MultiplayerLobbyFrame"):IsShown() or getglobal("MiniLobbyFrame"):IsShown() then
		elseif IsUIFrameShown("CreatorFestival") then

			-- 全民创造节不显示
		elseif IsUIFrameShown("CloudServerLobby") then
			--云服界面不要显示
		elseif getglobal("MultiplayerLobbyFrame"):IsShown() or IsMiniLobbyShown() then --mark by hfb for new minilobby
			Log("MultiplayerLobbyFrame_OnEvent: GIE_RSCONNECT_RESULT")
			if getglobal("LoadLoopFrame"):IsShown() then
				ShowLoadLoopFrame(false)
			end
			local ge = GameEventQue:getCurEvent();
			if ge.body.roomseverdata.result == 3 then
				Log("MultiplayerLobbyFrame_OnEvent: ");

				local callBack = function()
					getglobal("MultiplayerLobbyFrame"):Hide();
					-- getglobal("MiniLobbyFrame"):Hide();
					HideMiniLobby(); --mark by hfb for new minilobby
					--联机大厅曝光埋点
					local openmapBtnChecked = getglobal("RoomFrameOpenmapBtnChecked");
					local viewType = 0; --界面类型（0=主界面、1=热门地图、2=服务器房间）
					if openmapBtnChecked:IsShown() then
						viewType = 3
					elseif openmapBtnChecked:IsShown() then
						viewType = 1
					end
					local language = get_game_lang();
					-- statisticsGameEventNew(9500, 0, viewType, language);
				end


				local param = nil
				if not GetInst("UIEvtHook"):EventHook(arg1, GameEventQue:getCurEvent(), prefix) then
					local ge = GameEventQue:getCurEvent();
					local _, gid = GetInst("UIEvtHook"):ParsePrefixGenKey(ge.genid)
					param = GetInst("GameHallCacheManager"):GetData(prefix, gid)
				end
				OpenRoomFrame(callBack, false, false, param);
			elseif ge.body.roomseverdata.result == 5 then
				if ClientCurGame:isInGame() then
					if IsRoomOwner() then	--主机
						MessageBox(8, GetS(219));
						getglobal("MessageBoxFrame"):SetClientString( "主机断连" );
					end 
				else
					ShowGameTips(GetS(146), 3);
					isNoNetwork = false;
				end
			elseif ge.body.roomseverdata.result < 5 then
				ShowGameTips(GetS(146), 3);
				isNoNetwork = false;
			end
		end
	end
end

function MultiplayerLobbyFrame_OnShow()
	AccountManager:logoutRoomServer();
end