
function showmodel()
	local modelName = "TestmodelFrameModelViewRole";
	local skinView1 = getglobal(modelName);
	skinView1:setCameraWidthFov(30);
	skinView1:setCameraLookAt(0, 220, -1200, 0, 128, 0);
	skinView1:setActorPosition(0, 20, -320);

	UIActorBodyManager:releaseAvatarBody(100)
	local player1 = UIActorBodyManager:getAvatarBody(100, false);
	player1:addAnimModel(3);
	player1:playAnimBySeqId(100100);
	player1:setBodyType(3);
	--SetDefaultAvatarModel(player1);
	if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
		skinView1:attachActorBody(player1, 0, false)
	else
		player1:attachUIModelView(skinView1, 0, false);
	end
	player1:setScale(1.4);

end

function TestmodelFrame_OnShow()
	showmodel()
	local frameName = "TestmodelFramePartClassification";
	getglobal(frameName):SetClientID(1);
	ClientCurGame:setOperateUI(true);
	if ClientCurGame:isInGame() then
		local uin = AccountManager:getUin()
		if CurMainPlayer ~= nil and CurMainPlayer:getUin() == uin then
			player = CurMainPlayer;
		else
			if ClientCurGame:isInGame() == false then
				return
			end

			player = ClientCurGame:getPlayerByUin(uin);
			if player == nil then
				return;
			end
		end

		if player:getBody() ~= nil then
			player:getBody():setBodyType(3);	
			for i=1, 9 do
				player:getBody():hideAvatarPartModel(i)
			end
		end
	end
end

function TestmodelFrame_OnHide()
	ClientCurGame:setOperateUI(false);
end

function TestmodelFrameModelNumEdit_OnTabPressed()
	SetCurEditBox("TestmodelFrameModelNumEdit");
end

function TestmodelFramePartNumEdit_OnTabPressed()
	SetCurEditBox("TestmodelFramePartNumEdit");
end

function TestmodelFrameCloseBtn_OnClick()
	getglobal("TestmodelFrame"):Hide()
end

function TestmodelFrameConfirmBtn_OnClick()
	local modelText = getglobal("TestmodelFrameModelNumEdit"):GetText();
	local modelID = tonumber(modelText)
	local partID = getglobal("TestmodelFramePartClassification"):GetClientID();
	print("TestmodelFrameConfirmBtn_OnClick",partID,modelID)

	local player1 = UIActorBodyManager:getAvatarBody(100, false);
	player1:setBodyType(3);
	--SetDefaultAvatarModel(player1);
	player1:addTestPartModel(modelID, partID);

	if ClientCurGame:isInGame() then
		if player:getBody() ~= nil then
			player:getBody():addTestPartModel(modelID,partID);
		end
	end
end



function TestmodelFramePartClassification_OnClick()
	TestmodelFramePartClassificationDropFrameBtnsLayout();
	TestmodelFramePartClassification_IsShowDropFrame();
end

function TestmodelFramePartClassificationDropFrameBtnsLayout()
	local btnTextList = {9235,9236,9237,9238,9278,9239,9240,9241,9279};
	for i = 1, #btnTextList do
		local btnName = "TestmodelFramePartClassificationDropFrameBtn" .. i;
		getglobal(btnName .. "Name"):SetText(GetS(btnTextList[i]));
	end
end


TestmodelFramePartClassification_IsDropFrameShown = false;
function TestmodelFramePartClassification_IsShowDropFrame()
	local dropFrame = getglobal("TestmodelFramePartClassificationDropFrame");
	local downIcon = getglobal("TestmodelFramePartClassificationDownIcon");
	local upIcon = getglobal("TestmodelFramePartClassificationUpIcon");
	--HideStashChipRecycleAllFrame();
	if TestmodelFramePartClassification_IsDropFrameShown then
		--已经打开, 则关闭
		dropFrame:Hide();
		downIcon:Show();
		upIcon:Hide();
		TestmodelFramePartClassification_IsDropFrameShown = false;
	else
		--关闭的, 则打开
		dropFrame:Show();
		downIcon:Hide();
		upIcon:Show();
		TestmodelFramePartClassification_IsDropFrameShown = true;
	end
end

function TestmodelFramePartClassificationDropFrame_OnShow()
end

function TestmodelFramePartClassificationDropFrame_OnHide()
end


function TMFP_XLKBtnTemplate(id)
	local btnID = id;
	local frameName = "TestmodelFramePartClassification";
	local btnTextList = {9235,9236,9237,9238,9278,9239,9240,9241,9279};

	getglobal(frameName):SetClientID(id);

	--1. 显示顶部描述
	for i=1,#btnTextList do
		if i == id then
			getglobal(frameName .. "Name"):SetText(GetS(btnTextList[i]));
			break;
		end
	end
	--2. 处理下拉框
	TestmodelFramePartClassification_IsShowDropFrame();
end

InitModelViewAngle = 0;
function TestmodelFrameRotateView_OnMouseDown()
	InitModelViewAngle = getglobal("TestmodelFrameModelViewRole"):getRotateAngle();
end

function TestmodelFrameRotateView_OnMouseMove()
	local posX = getglobal("TestmodelFrameModelViewRole"):getActorPosX();
	local posY = getglobal("TestmodelFrameModelViewRole"):getActorPosY();

	if arg1 > posX-170 and arg1 < posX+170 and arg2 > posY-410 and arg2 < posY+30 then
		local angle = (arg1 - arg3)*1;

		if angle > 360 then
			angle = angle - 360;
		end
		if angle < -360 then
			angle = angle + 360;
		end

		angle = angle + InitModelViewAngle;	
		getglobal("TestmodelFrameModelViewRole"):setRotateAngle(angle);
	end
end