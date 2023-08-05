CurNewWorldTerrType = 1;

local t_WorldTypeName = {
				{name="AdvancedSetFrameSurvivalBtn", sId=3005, type=0},
				{name="AdvancedSetFrameCreateBtn", sId=3006, type=1},
				{name="AdvancedSetFrameExtremityBtn", sId=3173, type=2},
			}

local t_WorldTerrTypeName = {
				{
					name="AdvancedSetFrameHugeMapBtn", sId=3022,
				 	IsType=function(type)
						return type == 1;
					end
				 },
				{
					name="AdvancedSetFrameFlatMapBtn", sId=3023,
					IsType=function(type)
						return type == 0 or type == 10 or type == 11; 
					end},
			}

function AdvancedSetFrame_OnLoad()
	for i=1, #(t_WorldTypeName) do
		local name = getglobal(t_WorldTypeName[i].name.."Name");
		name:SetText(GetS(t_WorldTypeName[i].sId));
		name:SetTextColor(104, 94, 88);
	end

	for i=1, #(t_WorldTerrTypeName) do
		local name = getglobal(t_WorldTerrTypeName[i].name.."Name");
		name:SetText(GetS(t_WorldTerrTypeName[i].sId));
		name:SetTextColor(104, 94, 88);
	end
	--[[
	local survivalName= getglobal("AdvancedSetFrameSurvivalBtnName");
	local createName= getglobal("AdvancedSetFrameCreateBtnName");
	local extremityName= getglobal("AdvancedSetFrameExtremityBtnName");
	survivalName:SetText(StringDefCsv:get(3005));	--StringDef生存模式
	createName:SetText(StringDefCsv:get(3006));		--StringDef创造模式
	extremityName:SetText(StringDefCsv:get(3173));	--StringDef极限生存模式
	]]
end

function AdvancedSetFrame_OnShow()
	getglobal("AdvancedSetFrameSeedEdit"):Clear();
	getglobal("AdvancedSetFrameNameEdit"):Clear();

	CurNewWorldTerrType = 1;
	getglobal("AdvancedSetFrameFlatMapBtnTips"):Hide();
	SelectMapModel();
	
	local nickName = AccountManager:getNickName();
	local advancedSetFrameNameEdit = getglobal("AdvancedSetFrameNameEdit");

	----------StringBuilder-----
	if CurNewWorldType == 0 or CurNewWorldType == 4 then		
		AdvancedSetFrameSurvivalBtn_OnClick();
		advancedSetFrameNameEdit:SetDefaultText(nickName..GetS(59));
	elseif CurNewWorldType == 1 then
		AdvancedSetFrameCreateBtn_OnClick();
		advancedSetFrameNameEdit:SetDefaultText(nickName..GetS(60));
	elseif CurNewWorldType == 2 then
		AdvancedSetFrameExtremityBtn_OnClick();
		advancedSetFrameNameEdit:SetDefaultText(nickName..GetS(3174));
	end
end

function AdvancedSetFrameBackBtn_OnClick()
	getglobal("AdvancedSetFrame"):Hide();
	ShowLobby();
	getglobal("LobbyFrameArchiveFrame"):Show();
end

function AdvancedSetFrameSetBtn_OnClick()
	getglobal("AdvancedSetFrame"):Hide();
	OpenCreateWorldFrame()
end

function AdvancedSetFrameLimitedMapBtn_OnClick()
	CurNewWorldTerrType = 2;
	local advancedSetFrameMapDesc = getglobal("AdvancedSetFrameMapDesc");
	advancedSetFrameMapDesc:SetText(GetS(32));
	SelectMapModel();
	getglobal("AdvancedSetFrameFlatMapBtnTips"):Hide();
end

function AdvancedSetFrameHugeMapBtn_OnClick()
	CurNewWorldTerrType = 1;
	local advancedSetFrameMapDesc= getglobal("AdvancedSetFrameMapDesc");
	advancedSetFrameMapDesc:SetText(GetS(33));
	SelectMapModel();
	getglobal("AdvancedSetFrameFlatMapBtnTips"):Hide();
end

function AdvancedSetFrameFlatMapBtn_OnClick()
	local advancedSetFrameSeedEdit= getglobal("AdvancedSetFrameSeedEdit");
	if advancedSetFrameSeedEdit:GetText() ~= "" then return; end

	getglobal("ChooseFlatTypeFrame"):Show();
end

function SelectMapModel()
	for i=1, #(t_WorldTerrTypeName) do
		local check 	= getglobal(t_WorldTerrTypeName[i].name.."Check");
		local name 	= getglobal(t_WorldTerrTypeName[i].name.."Name");

		if t_WorldTerrTypeName[i].IsType(CurNewWorldTerrType) then
			check:Show();
			name:SetTextColor(104, 73, 55);
		else
			check:Hide();
			name:SetTextColor(104, 94, 88);
		end
	end
end

function AdvancedSetFrameSurvivalBtn_OnClick()	
	CurNewWorldType = 0;
	SelectGameModel("AdvancedSetFrameSurvivalBtn");
	
	local nickName = AccountManager:getNickName();
	local advancedSetFrameNameEdit= getglobal("AdvancedSetFrameNameEdit");
	----------StringBuilder-----
	advancedSetFrameNameEdit:SetDefaultText(nickName..GetS(59));

	SetCurEditBox("AdvancedSetFrameNameEdit");
end

function AdvancedSetFrameCreateBtn_OnClick()
	CurNewWorldType = 1;
	SelectGameModel("AdvancedSetFrameCreateBtn");

	local nickName = AccountManager:getNickName();
	local advancedSetFrameNameEdit= getglobal("AdvancedSetFrameNameEdit");
	----------StringBuilder-----
	advancedSetFrameNameEdit:SetDefaultText(nickName..GetS(60));

	SetCurEditBox("AdvancedSetFrameNameEdit");
end

--极限生存
function AdvancedSetFrameExtremityBtn_OnClick()
	CurNewWorldType = 2;
	SelectGameModel("AdvancedSetFrameExtremityBtn");

	local nickName = AccountManager:getNickName();
	local advancedSetFrameNameEdit= getglobal("AdvancedSetFrameNameEdit");
	----------StringBuilder-----
	advancedSetFrameNameEdit:SetDefaultText(nickName..GetS(3174));

	SetCurEditBox("AdvancedSetFrameNameEdit");
end

function SelectGameModel(btnName)
	for i=1, #(t_WorldTypeName) do
		local check 	= getglobal(t_WorldTypeName[i].name.."Check");
		local name 	= getglobal(t_WorldTypeName[i].name.."Name");

		if CurNewWorldType == t_WorldTypeName[i].type then
			check:Show();
			name:SetTextColor(104, 73, 55);
		else
			check:Hide();
			name:SetTextColor(104, 94, 88);
		end
	end
end

function AdvancedSetFrameNameEdit_OnFocusLost()
	local nameEdit = getglobal("AdvancedSetFrameNameEdit");
	if nameEdit:GetText() ~= "" and nameEdit:GetText() ~= nameEdit:GetDefaultText() then
		StatisticsTools:gameEvent("ModifyWorldName");
	end
end

function AdvancedSetFrameNameEdit_OnEnterPressed()
	AdvancedSetFrameStartBtn_OnClick();
end

function AdvancedSetFrameNameEdit_OnTabPressed()
	SetCurEditBox("AdvancedSetFrameSeedEdit");
end

function AdvancedSetFrameSeedEdit_OnEnterPressed()
	SetCurEditBox("AdvancedSetFrameNameEdit");
end

function AdvancedSetFrameSeedEdit_OnTabPressed()
	SetCurEditBox("AdvancedSetFrameNameEdit");
end

function AdvancedSetFrameStartBtn_OnClick()
	local advancedSetFrame= getglobal("AdvancedSetFrame");
	advancedSetFrame:Hide();
	
	local advancedSetFrameNameEdit= getglobal("AdvancedSetFrameNameEdit");
	local worldName = advancedSetFrameNameEdit:GetText();
	if CheckFilterString(worldName) then	--敏感词
		return;
	end
	if worldName == "" then
		worldName = advancedSetFrameNameEdit:GetDefaultText();
	end
	if AccountManager:requestCreateWorld(CurNewWorldType, worldName, CurNewWorldTerrType, getglobal("AdvancedSetFrameSeedEdit"):GetText(), AccountManager:getRoleModel()) then
		if not AccountManager:getNoviceGuideState("createworld") then
			AccountManager:setNoviceGuideState("createworld", true);
		end
		StatisticsWorldCreationEvent(CurNewWorldType);
		-- statisticsGameEvent(8003,"%d",CurNewWorldType);
		-- statisticsGameEvent(8006,"%d",CurNewWorldType);
	end	
	ShowLoadingFrame();
end

--------------------------------ChooseFlatTypeFrame-------------------------------
function FlatTypeBtnTemplate_OnClick()
	local id = this:GetClientID();
	if getglobal("AdvancedSetFrame"):IsShown() then
		if id == 1 then
			CurNewWorldTerrType = 10;
			getglobal("AdvancedSetFrameFlatMapBtnTips"):SetText(GetS(1144));
		elseif id == 2 then
			CurNewWorldTerrType = 11;
			getglobal("AdvancedSetFrameFlatMapBtnTips"):SetText(GetS(1145));
		elseif id == 3 then
			CurNewWorldTerrType = 0;
			getglobal("AdvancedSetFrameFlatMapBtnTips"):SetText(GetS(1146));
		end

		getglobal("AdvancedSetFrameFlatMapBtnTips"):Show();
		local advancedSetFrameMapDesc= getglobal("AdvancedSetFrameMapDesc");
		advancedSetFrameMapDesc:SetText(GetS(34));
		SelectMapModel();
	else
		if id == 1 then
			SetWorldTerrain(10, 2);
			getglobal("WorldRuleBoxTerrain2Tips"):SetText(GetS(1144));
		elseif id == 2 then
			SetWorldTerrain(11, 2);
			getglobal("WorldRuleBoxTerrain2Tips"):SetText(GetS(1145));
		elseif id == 3 then
			SetWorldTerrain(0, 2);
			getglobal("WorldRuleBoxTerrain2Tips"):SetText(GetS(1146));
		end

		getglobal("WorldRuleBoxTerrain2Tips"):Show();
	end

	ChooseFlatTypeFrameCloseBtn_OnClick();
end

function ChooseFlatTypeFrameCloseBtn_OnClick()
	getglobal("ChooseFlatTypeFrame"):Hide();
end

function ChooseFlatTypeFrame_OnLoad()
	local t={1144, 1145, 1146}

	for i=1, #(t) do
		local type = getglobal("ChooseFlatTypeFrameType"..i);
		local name = getglobal("ChooseFlatTypeFrameType"..i.."Name");
		type:SetPoint("top", "ChooseFlatTypeFrameChenDi", "top", 0, (i-1)*60+30);
		name:SetText(GetS(t[i]));
	end
end