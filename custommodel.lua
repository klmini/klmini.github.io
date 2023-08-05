_G.CurOpenCustomModelBlockId = 0;
local MODEL_STUFF_GRID_MAX = 30;
local CurCustomType = 0;

local function UpdateCustomModelTypeBtnState(index)
	CurCustomType = index;
	local t = {"CustomModelFrameWeaponBtn", "CustomModelFrameGunBtn", "CustomModelFrameProjectileBtn", "CustomModelFrameBowBtn"}
	for i=1, #(t) do
		local btnName = t[i];
		local btn = getglobal(btnName);
		if index == 0 then
			btn:Hide();
		else
			btn:Show();
			btn:SetChecked(false);
			local nameFont = getglobal(btnName.."Name");
			if i == index then
				btn:Disable();
				nameFont:SetTextColor(255, 135, 27);
				nameFont:SetPoint("center", btnName .. "CheckedBG", "center", 0, 0);
				nameFont:SetFontSize(28);
			else
				btn:Enable();
				nameFont:SetTextColor(142, 135, 119);
				nameFont:SetPoint("center", btnName .. "Normal", "center", 0, 0);
				nameFont:SetFontType("BlackFont24");
			end
		end
	end
end

function CustomModelFrameTypeBtn_OnClick()
	local index = this:GetClientID();
	UpdateCustomModelTypeBtnState(index);
end

function CustomModelFrameCloseBtn_OnClick()
	getglobal("CustomModelFrame"):Hide();
end

function CustomModelFrame_OnLoad()
	this:RegisterEvent("GE_BACKPACK_ATTRIB_CHANGE");
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	this:RegisterEvent("GE_BACKPACK_CHANGE_EDIT");
	CustomModel_AddGameEvent()
	for i = 1,30 / 6 do
		for j=1,6 do
			local itembtn = getglobal("CustomModelFrameTopBoxItem" .. ((i - 1) * 6 + j));
			itembtn:SetPoint("topleft", "CustomModelFrameTopBoxPlane", "topleft", (j - 1) * 85, (i - 1) * 83);
		end
	end
end

function CustomModel_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local paramData = context:GetParamData()
		local grid_index = paramData.gridIndex
		if grid_index and grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX + 1008 then
			CustomModel_UpdateMaterial();
		elseif grid_index >= CUSTOMMODEL_START_INDEX and grid_index < CUSTOMMODEL_START_INDEX + 2 then
			CustomModel_UpdateResult(grid_index);
			CustomModel_EnableMakeBtn();
		end
	end)

	SubscribeGameEvent(nil,GameEventType.BackPackAttribChange,function(context)
		getglobal("CustomModelFrameBottomArrowProgressBar"):SetValue(OpenContainer:getAttrib(0));
	end)
end
--刷新原料和生成物格子
function CustomModel_UpdateResult(grid_index)
	Log("CustomModel_UpdateResult:");
	if grid_index == nil then
		for i=1, 2 do
			local furnaceItem = getglobal("CustomModelFrameBottomSheetItem"..i);
			local icon 	= getglobal(furnaceItem:GetName() .. "Icon");
			local num	= getglobal(furnaceItem:GetName() .. "Count");
			local durbkg	= getglobal(furnaceItem:GetName() .. "DurBkg");
			local durbar	= getglobal(furnaceItem:GetName() .. "Duration");
			UpdateGridContent(icon, num, durbkg, durbar, CUSTOMMODEL_START_INDEX + i- 1);
		end
	else

		for i=1, 2 do
			local furnaceItem = getglobal("CustomModelFrameBottomSheetItem"..i);
			if furnaceItem:GetClientID()-1 == grid_index then
				local icon 	= getglobal(furnaceItem:GetName() .. "Icon");
				local num	= getglobal(furnaceItem:GetName() .. "Count");
				local durbkg	= getglobal(furnaceItem:GetName() .. "DurBkg");
				local durbar	= getglobal(furnaceItem:GetName() .. "Duration");		
				UpdateGridContent(icon, num, durbkg, durbar, grid_index);
				break
			end
		end
	end
end

--刷新材料格子: 导入一袋砂土到格子
function CustomModel_UpdateMaterial()
	Log("CustomModel_UpdateMaterial:");
	local t_customModelStuff = {};
	local t_customModelFuel = {};
	local resBlockId = 11823;

	for i=1, BACK_PACK_GRID_MAX do
		local grid_index = BACKPACK_START_INDEX + i - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		local itemdef = ItemDefCsv:get(itemId);
		if itemId == resBlockId and itemdef then
			table.insert(t_customModelStuff, grid_index);
		end
	end

	local maxCount = ClientBackpack:getShortcutGridCount()
	for i=1, maxCount do
		local grid_index = ClientBackpack:getShortcutStartIndex() + i - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		local itemdef = ItemDefCsv:get(itemId);
		if itemId == resBlockId and itemdef then
			table.insert(t_customModelStuff, grid_index);
		end
	end

	print("kekeke t_customModelStuff:", t_customModelStuff);

	for i=1, MODEL_STUFF_GRID_MAX do
		local stuffItem 	= getglobal("CustomModelFrameTopBoxItem"..i);
		local stuffItemIcon 	= getglobal("CustomModelFrameTopBoxItem"..i.."Icon");
		local stuffItemNum 	= getglobal("CustomModelFrameTopBoxItem"..i.."Count");
		local stuffItemDurbkg 	= getglobal("CustomModelFrameTopBoxItem"..i.."DurBkg");
		local stuffItemDurbar 	= getglobal("CustomModelFrameTopBoxItem"..i.."Duration");
		if i <= #(t_customModelStuff) then
			stuffItem:SetClientID(t_customModelStuff[i]+1);
			UpdateGridContent(stuffItemIcon, stuffItemNum, stuffItemDurbkg, stuffItemDurbar, t_customModelStuff[i]);
		else
			stuffItem:SetClientID(0);
			stuffItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
			stuffItemNum:SetText("");
			stuffItemDurbar:Hide();
			stuffItemDurbkg:Hide();
		end
	end
end

function CustomModelFrame_OnShow()
	HideAllFrame("CustomModelFrame", true);

	if not getglobal("CustomModelFrame"):IsReshow() then
	    ClientCurGame:setOperateUI(true);
	end

	Blueprint_UpdateMaterial();
	CustomModel_UpdateResult();
	CustomModel_EnableMakeBtn();

	if CurOpenCustomModelBlockId == ITEM_ITEMMODELCRAFT then
		UpdateCustomModelTypeBtnState(1);
		getglobal("CustomModelFrameWeaponBtn"):Checked();
	else
		UpdateCustomModelTypeBtnState(0)
	end
end

function CustomModelFrame_OnHide()
	ShowMainFrame();

	if not getglobal("CustomModelFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end

	UIFrameMgr:setCurEditBox(nil);
	CurMainPlayer:closeContainer();
end

function CustomModelFrame_OnEvent()
	if arg1 == "GE_BACKPACK_ATTRIB_CHANGE" then
		getglobal("CustomModelFrameBottomArrowProgressBar"):SetValue(OpenContainer:getAttrib(0));
	end

	if arg1 == "GE_BACKPACK_CHANGE" then
		local ge = GameEventQue:getCurEvent();
		local grid_index = ge.body.backpack.grid_index;

		Log("CustomModelFrame_OnEvent: grid_index = " .. grid_index);
		if grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX + 1008 then
			CustomModel_UpdateMaterial();
		elseif grid_index >= CUSTOMMODEL_START_INDEX and grid_index < CUSTOMMODEL_START_INDEX + 2 then
			CustomModel_UpdateResult(grid_index);
			CustomModel_EnableMakeBtn();
		end	
	elseif arg1 == "GE_BACKPACK_CHANGE_EDIT" then
		local ge = GameEventQue:getCurEvent();
		local grid_index = ge.body.backpack.grid_index;

		CustomModel_UpdateMaterial();
	end
end

function CustomModelFrameMakeBtn_OnClick()
	statisticsUIInGame(30021, EnterRoomType);

	Log("CustomModelFrameMakeBtn_OnClick:");

	local name = getglobal("CustomModelFrameBottomSheetNameEdit"):GetText();

	Log("name = " .. name);

	if CheckFilterString(name) then	--敏感词
		ShowGameTips(GetS(121), 3);
		return;
	end

	if string.len(name) <= 0 then
		name = "";
	end

	local desc = getglobal("CustomModelFrameBottomDescEdit"):GetText();

	if CheckFilterString(desc) then	--敏感词
		ShowGameTips(GetS(121), 3);
		return;
	end

	if string.len(desc) <= 0 then
		desc = "";
	end

	if OpenContainer and CurMainPlayer then
		OpenContainer:MakeCustoModel(CurMainPlayer:getUin(), name, desc, CurCustomType);
		reLoadBackPackDevDef=true;
	else
		Log("Error: OpenContainer or CurMainPlayer is nil");
	end

	OnChangeResourceData()
end

--制作按钮置灰
function CustomModel_EnableMakeBtn()
	Log("CustomModel_EnableMakeBtn:");

	local itemid1 = ClientBackpack:getGridItem(CUSTOMMODEL_START_INDEX);
	local itemid2 = ClientBackpack:getGridItem(CUSTOMMODEL_START_INDEX + 1);

	local normal = getglobal("CustomModelFrameMakeBtnNormal");
	local pushed = getglobal("CustomModelFrameMakeBtnPushedBG");
	local btn = getglobal("CustomModelFrameMakeBtn");

	Log("itemid1 = " .. itemid1);
	Log("itemid2 = " .. itemid2);

	if 0 ~= itemid1 and 0 == itemid2 then
		Log("111:");
		normal:SetGray(false);
		pushed:SetGray(false);
		btn:Enable();
	else
		Log("222:");
		normal:SetGray(true);
		pushed:SetGray(true);
		btn:Disable();
	end
end

function CustomModelItemOnClick(grid_index)
	Log("CustomModelItemOnClick:");
	if CurWorld:isGodMode() and grid_index == 29000 then
		return;
	end
	
	local itemId 	= ClientBackpack:getGridItem(grid_index);
	local num 	= ClientBackpack:getGridNum(grid_index);

	if itemId < 1 then return; end

	if CurWorld:isGodMode()  then --是否是创造模式
		local index = ClientBackpack:getEmptyShortcutIndex()
		if index ~= -1 then
			CurMainPlayer:moveItem(grid_index,index,1);
			SandboxLua.eventDispatcher:Emit(CurMainPlayer, "AddItem_SceneEditor", 
			SandboxContext():SetData_Number("itemId", itemId))
			return;
		end
		-- for i=1,8 do
		-- 	if ClientBackpack:getGridItem(999+i)==0 then
		-- 		CurMainPlayer:moveItem(grid_index,999+i,1);
		-- 		return;
		-- 	end
		-- end
		ShowGameTips(GetS(3245), 3);
	else
		BackPackAddItem(grid_index, num, 1);
	end 
end

function CustomModelFrameBottomSheetNameEdit_OnFinishChar()
end

function CustomModelFrameBottomSheetNameEdit_OnFocusGained()
end

function CustomModelFrameBottomSheetNameEdit_OnFocusLost()
end

function CustomModelFrameBottomDescEdit_OnFocusLost()
	local text = getglobal("CustomModelFrameBottomDescEdit"):GetText();
	if text == "" then
		getglobal("CustomModelFrameBottomDescDefaultTxt"):Show();
	else
		getglobal("CustomModelFrameBottomDescDefaultTxt"):Hide();
	end
end

function CustomModelFrameBottomDescEdit_OnFocusGained()
	getglobal("CustomModelFrameBottomDescDefaultTxt"):Hide();
end