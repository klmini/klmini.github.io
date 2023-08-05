
function Back_OnClick()	
	getglobal("DebugMenuFrame"):Show();
	getglobal("DebugCameraFrame"):Hide();
	Log("Back_OnClick");
end

function FreeFlyCamera_OnClick()	
	DebugMgr:switchCameraControlType(3);
end

function TPSCameraBack_OnClick()	
	DebugMgr:switchCameraControlType(0);
end

function DebugCamera_OnUpdate()
	--local i = DebugMgr.getNum();
	--local str = ebugMgr.getStr();
	getglobal("DebugCameraFrameCameraInfo"):SetText(DebugMgr:getCameraInfo(),255,255,255);
end
