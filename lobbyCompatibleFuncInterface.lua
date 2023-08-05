--新版玩家地图存档列表功能总开关
function isEnableNewLobby()
	-- if SetAndGetABTest then
	-- 	return SetAndGetABTest("exp_gf_home_cundang");
	-- end
	-- 搬运工具启用使用老界面
	if MapConvertManager and MapConvertManager.ToolIsOpen and MapConvertManager:ToolIsOpen() then
		return false;
	end

	return true;
end

-- 显示存档界面
function ShowLobby(param)
	ReportTraceidMgr:setTraceid("startgame")
	if IsUIStageEnable then
		if isEnableNewLobby and isEnableNewLobby() then
			param = param or {}
			param.UpdateView = true
			UIStageDirector:openStage("lobbyMapArchiveList",
				param,
				UIStageOpenWay.UI_STAGE_OPEN_WAY_PUSH,
				{ui_type = UIFrameType.UI_FRAME_MVC},
				true,
				nil)
		else
			UIStageDirector:openStage("LobbyFrame",
				nil,
				UIStageOpenWay.UI_STAGE_OPEN_WAY_PUSH,
				{ui_type = UIFrameType.UI_FRAME_NORMAL},
				true,
				nil)
		end
		return -- 沙盒 UIStage 方式管理
	end

	if isEnableNewLobby and isEnableNewLobby() then
		param = param or {};
		param.UpdateView = true
		GetInst("UIManager"):Open("lobbyMapArchiveList", param)
	else
		getglobal("LobbyFrame"):Show()
	end
end

-- 隐藏存档界面
function HideLobby()
	if IsUIStageEnable then
		if isEnableNewLobby and isEnableNewLobby() then
			UIStageDirector:closeStage("lobbyMapArchiveList")
		else
			UIStageDirector:closeStage("LobbyFrame")
		end
		return -- 沙盒 UIStage 方式管理
	end

	local ctrl = GetInst("UIManager"):GetCtrl("lobbyMapArchiveList", "uiCtrlOpenList")
	if ctrl then
		GetInst("UIManager"):Close("lobbyMapArchiveList")
	end

	if GetInst("UIManager"):GetCtrl("MapDetailInfo", "uiCtrlOpenList") then
		GetInst("UIManager"):Close("MapDetailInfo")
	end
	
	if IsUIFrameShown("LobbyFrame") then
		getglobal("LobbyFrame"):Hide()
	end

	-- if isEnableNewMiniLobby and isEnableNewMiniLobby() then
	-- 	HideMiniLobby()
	-- end --不需要在这里做这个事情 code_by:huangfubin
	
end

-- 存档界面是否显示中
function IsLobbyShown()
	if isEnableNewLobby and isEnableNewLobby() then
		return IsUIFrameShown("lobbyMapArchiveList")
	else
		return IsUIFrameShown("LobbyFrame")
	end
end

-- 显示存档详情界面
function ShowMapDetailInfo()
	if isEnableNewLobby and isEnableNewLobby() then
		if GetInst("UIManager"):GetCtrl("MapDetailInfo","uiCtrlOpenList") then
			GetInst("UIManager"):GetCtrl("MapDetailInfo"):Refresh()
		else
			GetInst("UIManager"):Open("MapDetailInfo")
		end
	else
		getglobal("ArchiveInfoFrame"):Show()
	end
end

-- 隐藏存档详情界面
function HideMapDetailInfo()
	if GetInst("UIManager"):GetCtrl("MapDetailInfo", "uiCtrlOpenList") then
		GetInst("UIManager"):Close("MapDetailInfo")
	end
	
	if IsUIFrameShown("ArchiveInfoFrame") then
		getglobal("ArchiveInfoFrame"):Hide()
	end
end

-- 存档详情界面是否显示中
function IsMapDetailInfoShown()
	if isEnableNewLobby and isEnableNewLobby() then
		return IsUIFrameShown("MapDetailInfo")
	else
		return IsUIFrameShown("ArchiveInfoFrame")
	end
end