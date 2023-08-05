
function EnableDebugDraw_OnClick()	
	DebugMgr:toggleRenderDraw();
end

function ScreenShot_OnClick()	
	DebugMgr:screenshot(0);
	Log("ScreenShot_OnClick");
end

function Camera_OnClick()	
	getglobal("DebugMenuFrame"):Hide();
	getglobal("DebugCameraFrame"):Show();
	Log("Camera_OnClick");
end

function SpeedDown_OnClick()	
	DebugMgr:speedDown();
	Log("Pause_OnClick");
end

function SpeedUp_OnClick()	
	DebugMgr:speedUp();
	Log("Pause_OnClick");
end

function Pause_OnClick()	
	DebugMgr:pause();
	Log("Pause_OnClick");
end

function Close_OnClick()	
	getglobal("DebugMenuFrame"):Hide();
end

function Step_OnClick()	
	DebugMgr:step();
	Log("Step_OnClick");
end

function Play_OnClick()	
	DebugMgr:play();
	Log("Play_OnClick");
end

function CutScene_OnClick()	
	getglobal("DebugCutSceneFrame"):Show();
end

function Rendering_OnClick()	
	--DebugMgr:play();
	Log("Rendering_OnClick");
end

function DebugMenu_OnLoad()
	Log("DebugMenu_OnLoad");
end

function DebugMenu_OnEvent()
	Log("DebugMenu_OnEvent");
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

function DebugMenu_OnShow()

	Log("DebugMenu_OnShow");

	--[[
	HideAllFrame("DeathFrame", false);
	getglobal("GongNengFrame"):Hide();

	for i=1, #(t_DeathNeedHideFrame) do
		local frame = getglobal(t_DeathNeedHideFrame[i]);
		if frame:IsShown() then
			frame:Hide();
		end
	end

	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	local deathFrameContinueBtn = getglobal("DeathFrameContinueBtn");
	local deathFrameContinueBtnNormal = getglobal("DeathFrameContinueBtnNormal");
	local continueBtnStarNum = getglobal("DeathFrameContinueBtnStarNum");
	
	if starNum < Revive_Need_Star then
		continueBtnStarNum:SetTextColor(255, 0, 0);
	else
		continueBtnStarNum:SetTextColor(255, 246, 0);
	end	
	ClientCurGame:setOperateUI(true);
	ClientMgr:playSound2D("sounds/ui/info/death.ogg", 1);
	]]
end

function DebugMenu_OnHide()
	Log("DebugMenu_OnHide");
end
