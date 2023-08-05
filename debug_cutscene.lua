
function CloseCutScene_OnClick()	
	getglobal("DebugCutSceneFrame"):Hide();
end

function RunCutScene_OnClick()	
	RunCutscene(0);
	DebugMgr:switchCameraControlType(0);
end

function Reset_OnClick()	
	DebugMgr:switchCameraControlType(1);
end

function Reload_OnClick()
	RunCutscene(0);
end
