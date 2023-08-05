REPAIR_GRID_MAX = 30;
REPAIR_ITEM_GRID_INDEX = 15000;		--要修理的物品的grid_index;
local destRepairIndex = nil;
local stuffRepairIndex = nil;
local placeStuffNum = 0;

--通过itemid获取gridindex
local function getGridIndex(itemId)
	for i=1, BACK_PACK_GRID_MAX do 			
		local grid_index = BACKPACK_START_INDEX + i - 1;
		local gridId = ClientBackpack:getGridItem(grid_index);
		if gridId > 0 and gridId == itemId then
			return grid_index
		end
	end
	for i=1, MAX_SHORTCUT do
		local grid_index = ClientBackpack:getShortcutStartIndex() + i - 1;
		local gridId = ClientBackpack:getGridItem(grid_index);
		if gridId > 0 and gridId == itemId then
			return grid_index
		end
	end
	return -1
end

function RepairFrame_OnLoad()
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	this:RegisterEvent("GE_REPAIR_RESULT");
	RepairFrame_AddGameEvent()
	for i=1, 3 do
		local bkg = getglobal("RepairFrameRepairItem"..i.."Bkg");
		bkg:SetTextureHuiresXml("ui/mobile/texture2/common.xml");
		bkg:SetTexUV("img_icon_lignt.png");
	end

	for i=1,REPAIR_GRID_MAX/6 do
		for j=1,6 do
			local itembtn = getglobal("WaitRepairBoxItem"..((i-1)*6+j));
			itembtn:SetPoint("topleft", "WaitRepairBoxPlane", "topleft", (j-1)*85, (i-1)*83);
		end
	end

	for i=1,REPAIR_GRID_MAX/6 do
		for j=1,6 do
			local itembtn = getglobal("RepairStuffBoxItem"..((i-1)*6+j));
			itembtn:SetPoint("topleft", "RepairStuffBoxPlane", "topleft", (j-1)*85, (i-1)*83);
		end
	end
end

function RepairFrame_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local RepairFrame = getglobal("RepairFrame")
		if RepairFrame:IsShown() then
			local paramData = context:GetParamData()
			local grid_index = paramData.gridIndex
			if grid_index and grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX+1008 then
				UpdateWaitRepairItem();
			end
		end
	end)
end

function RepairFrame_OnEvent()
	local RepairFrame = getglobal("RepairFrame")
	if arg1 == "GE_BACKPACK_CHANGE" then		
		if RepairFrame:IsShown() then
			local ge = GameEventQue:getCurEvent();
			local grid_index = ge.body.backpack.grid_index;
			if grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX+1008 then
				UpdateWaitRepairItem();
			end		
		end
	elseif arg1 == "GE_REPAIR_RESULT" then
		if RepairFrame:IsShown() then
			local ge = GameEventQue:getCurEvent();
			local grid_index = ge.body.backpack.grid_index;
			local itemDef = ItemDefCsv:get(ClientBackpack:getGridItem(grid_index));
			if itemDef ~= nil then
				ShowGameTips(GetS(552, itemDef.Name), 3);
			end

			destRepairIndex = nil;
			stuffRepairIndex  = nil;
			placeStuffNum = 0;

			UpdateRepairItem();
			UpdateWaitRepairItem();
		end
	end
end

function RepairFrame_OnShow()
	--HideAllFrame("RepairFrame", true);
	getglobal("WaitRepairBox"):resetOffsetPos();
	getglobal("RepairStuffBox"):resetOffsetPos();
	UpdateWaitRepairItem();
	UpdateRepairItem();
	if not getglobal("RepairFrame"):IsReshow() then	
	ClientCurGame:setOperateUI(true);
	end
end

function RepairFrame_OnHide()
	ShowMainFrame();
	ClearRepairFrame();
	destRepairIndex = nil;
	stuffRepairIndex  = nil;
	placeStuffNum = 0;
	if not getglobal("RepairFrame"):IsReshow() then	
	ClientCurGame:setOperateUI(false);
	end
end

function ClearRepairFrame()
	getglobal("RepairFrameDurTitle"):Hide();
	getglobal("RepairFrameDuration"):SetText("");
	getglobal("RepairFrameRepairBtnStarNum"):SetText("");

	for i=1, REPAIR_GRID_MAX do
		ResetRepariStuffBoxItem(i)
	end
end

function RepairFrameCloseBtn_OnClick()
	getglobal("RepairFrame"):Hide();
	GetInst("UIManager"):Close("CraftSelectMenu")
end

function RepairFrameRepairBtn_OnClick()
	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	local cost = tonumber(getglobal("RepairFrameRepairBtnStarNum"):GetText());
	if destRepairIndex == nil then
		ShowGameTips(GetS(553), 3);
	elseif stuffRepairIndex == nil then
		ShowGameTips(GetS(554), 3);
	elseif starNum < cost then--星星不足
		ShowGameTips(GetS(555), 3);
	else
		--改
		local stuffId = ClientBackpack:getGridItem(stuffRepairIndex);
		CurMainPlayer:repair(destRepairIndex, stuffId, placeStuffNum);
	end
end

--点击左边面板待修理物品的格子
function WaitRepairItemOnclick(grid_index)
	destRepairIndex = grid_index;
	stuffRepairIndex = nil;
	UpdateRepairItem();
	UpdateWaitRepairItem();
end

--点击左边面板修理材料格子
function RepairStuffItemOnclick(grid_index)
	stuffRepairIndex = grid_index;
	UpdateRepairItem();
	UpdateWaitRepairItem();
end

function UpdateWaitRepairItem()
	local t_waitRepairItem = {};
	for i=1, BACK_PACK_GRID_MAX do 
		local grid_index = BACKPACK_START_INDEX + i - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		local durable = ClientBackpack:getGridDuration(grid_index);
		local toolDef = ToolDefCsv:get(itemId);

		if toolDef ~= nil and itemId ~= 1000 and durable < ClientBackpack:getGridMaxDuration(grid_index) and itemId ~= 12580 then
			table.insert(t_waitRepairItem, grid_index);
		end
	end
	for i=1, MAX_SHORTCUT do
		local grid_index = ClientBackpack:getShortcutStartIndex() + i - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		local durable = ClientBackpack:getGridDuration(grid_index);
		local toolDef = ToolDefCsv:get(itemId);

		if toolDef ~= nil and durable < ClientBackpack:getGridMaxDuration(grid_index) and itemId ~= 12580 then
			table.insert(t_waitRepairItem, grid_index);
		end
	end
	
	--改
	local index = 0;
	local showNum = 0;
	for i=1, #(t_waitRepairItem) do
		local num = ClientBackpack:getGridNum(t_waitRepairItem[i] );
		
		if destRepairIndex ~= nil and t_waitRepairItem[i] == destRepairIndex then
			num = num - 1;
		end
		if num > 0 and i <= REPAIR_GRID_MAX then
			index = index + 1;
			showNum = showNum + 1;

			local waitRepair	= getglobal("WaitRepairBoxItem"..index);
			local waitRepairIcon 	= getglobal("WaitRepairBoxItem"..index.."Icon");
			local waitRepairNum 	= getglobal("WaitRepairBoxItem"..index.."Count");
			local waitRepairDurbkg 	= getglobal("WaitRepairBoxItem"..index.."DurBkg");
			local waitRepairDurbar 	= getglobal("WaitRepairBoxItem"..index.."Duration");
		
			waitRepair:SetClientID(t_waitRepairItem[i]+1);
			UpdateVirtualItemIcon(waitRepairIcon, waitRepairNum, waitRepairDurbar, t_waitRepairItem[i], num, waitRepairDurbkg);
		end
	end

	for i=showNum+1, REPAIR_GRID_MAX do
		local waitRepair	= getglobal("WaitRepairBoxItem"..i);
		local waitRepairIcon 	= getglobal("WaitRepairBoxItem"..i.."Icon");
		local waitRepairNum 	= getglobal("WaitRepairBoxItem"..i.."Count");
		local waitRepairDurbkg 	= getglobal("WaitRepairBoxItem"..i.."DurBkg");
		local waitRepairDurbar 	= getglobal("WaitRepairBoxItem"..i.."Duration");
		
		local enChantTexture1 = getglobal("WaitRepairBoxItem"..i.."IconFumoEffect1");
		local enChantTexture2 = getglobal("WaitRepairBoxItem"..i.."IconFumoEffect2");
		enChantTexture1:Hide();	
		enChantTexture2:Hide();	
	
		waitRepair:SetClientID(0);
		waitRepairIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
		waitRepairNum:SetText("");
		waitRepairDurbar:Hide();
		waitRepairDurbkg:Hide();
	end
end

function UpdateRepairStuff(itemId)
	local toolDef = ToolDefCsv:get(itemId);	
	local t_repairStuff = {};

	if toolDef ~= nil then
		local list1, list2 = {}, {}
		for j=1, 6 do
			local repairId = toolDef.RepairId[j-1]
			if repairId and repairId > 0 then
				local grid_index = getGridIndex(repairId)
				if grid_index and grid_index >= 0 then
					table.insert(list1, repairId)
				else
					table.insert(list2, repairId)
				end
			end 
		end
		for _, value in ipairs(list1) do
			table.insert(t_repairStuff, value)
		end
		for _, value in ipairs(list2) do
			table.insert(t_repairStuff, value)
		end
	end

	for index = 1, REPAIR_GRID_MAX do
		ResetRepariStuffBoxItem(index)
		local repairId = t_repairStuff[index]
		if repairId and repairId > 0 then
			UpdatePropRepairSelectMaterials(index, repairId)
		end
	end
end

--更新道具修理选择材料item
function UpdatePropRepairSelectMaterials(index, itemId)
	local stuffItem		= getglobal("RepairStuffBoxItem"..index)
	local stuffItemIcon 	= getglobal("RepairStuffBoxItem"..index.."Icon")
	local stuffItemNum 	= getglobal("RepairStuffBoxItem"..index.."Count")
	local stuffItemDurbkg 	= getglobal("RepairStuffBoxItem"..index.."DurBkg")
	local stuffItemDurbar 	= getglobal("RepairStuffBoxItem"..index.."Duration")
	local stuffItemLack = getglobal("RepairStuffBoxItem"..index.."Lack")

	if not stuffItem  then
		return
	end
	local ownNum = ClientBackpack:getItemCountInNormalPack(itemId)
	if ownNum > 0 then
		local grid_index = getGridIndex(itemId)
		if grid_index >= 0 then
			stuffItem:SetClientID(grid_index+1)
			local num =  ownNum 
			if grid_index == stuffRepairIndex then
				num =  ownNum - (placeStuffNum or 0)
			end
			UpdateVirtualItemIcon(stuffItemIcon, stuffItemNum, stuffItemDurbar, grid_index, num, stuffItemDurbkg)
		end
	else
		stuffItem:SetGray(true)
		stuffItem:SetClientUserData(4, itemId)
		SetItemIcon(stuffItemIcon, itemId)
		stuffItemLack:Show()
	end
end

function ResetRepariStuffBoxItem(index)
	local stuffItem		= getglobal("RepairStuffBoxItem"..index)
	if not stuffItem or not ClientMgr then
		return
	end
	local stuffItemIcon 	= getglobal("RepairStuffBoxItem"..index.."Icon")
	local stuffItemNum 	= getglobal("RepairStuffBoxItem"..index.."Count")
	local stuffItemDurbkg 	= getglobal("RepairStuffBoxItem"..index.."DurBkg")
	local stuffItemDurbar 	= getglobal("RepairStuffBoxItem"..index.."Duration")
	local stuffItemLack = getglobal("RepairStuffBoxItem"..index.."Lack")

	local enChantTexture1 = getglobal("RepairStuffBoxItem"..index.."IconFumoEffect1")
	local enChantTexture2 = getglobal("RepairStuffBoxItem"..index.."IconFumoEffect2")
	enChantTexture1:Hide();	
	enChantTexture2:Hide();	

	stuffItem:SetGray(false)
	stuffItem:SetClientID(0);
	stuffItem:SetClientUserData(4, 0)
	stuffItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
	stuffItemNum:SetText("");
	stuffItemDurbar:Hide();
	stuffItemDurbkg:Hide();
	if stuffItemLack then
		stuffItemLack:Hide()
	end
end

function UpdateRepairItem()
	--改
	for i=1, 2 do
		local repairItem = getglobal("RepairFrameRepairItem"..i);

		local grid_index = destRepairIndex;
		if i == 2 then
			grid_index = stuffRepairIndex;
		end

		repairItem:SetClientUserData(4, 0)
		local btn 	= getglobal(repairItem:GetName());
		local icon 	= getglobal(repairItem:GetName() .. "Icon");
		local num	= getglobal(repairItem:GetName() .. "Count");
		local durbkg	= getglobal(repairItem:GetName() .. "DurBkg");
		local durbar	= getglobal(repairItem:GetName() .. "Duration");
		local enChantTexture1 = getglobal(repairItem:GetName() .. "IconFumoEffect1");
		local enChantTexture2 = getglobal(repairItem:GetName() .. "IconFumoEffect2");

		if grid_index ~= nil then
			local grid_num = 1;
			if destRepairIndex ~= nil and grid_index == stuffRepairIndex then
				grid_num = GetPlaceRepairStuffNum(stuffRepairIndex);
				if grid_num == 0 then
					ShowGameTips(GetS(556), 3);	
				end
				placeStuffNum = grid_num;
			else
				SetRepairResultGrid(-1);
				placeStuffNum = 0;
			end
			repairItem:SetClientUserData(4, grid_index)
			UpdateVirtualItemIcon(icon, num, durbar, grid_index, grid_num, durbkg, btn, i == 2)
		else
			placeStuffNum = 0;
			SetRepairResultGrid(-1);
			icon:SetTextureHuires(ClientMgr:getNullItemIcon());
			enChantTexture1:Hide();	
			enChantTexture2:Hide();	
			num:SetText("");
			durbar:Hide();
			durbkg:Hide();
			btn:SetClientID(0);
		end
	end

	if destRepairIndex ~= nil then
		local itemId = ClientBackpack:getGridItem(destRepairIndex);
		UpdateRepairStuff(itemId);			
	else
		UpdateRepairStuff(-1);
	end
	UpdateRepairShow();
end

function RepairItemOnclick(btnName)
	--改
	if string.find(btnName, "RepairItem3") then
		return;					 --修理后的格子上的东西不能拿下来;
	elseif string.find(btnName, "RepairItem1") and destRepairIndex ~= nil then
		destRepairIndex = nil;
		stuffRepairIndex = nil;
	elseif string.find(btnName, "RepairItem2") and stuffRepairIndex ~= nil then
		stuffRepairIndex = nil;
	end

	UpdateRepairItem();
	UpdateWaitRepairItem();	
end

function UpdateRepairShow()
	local repiarDur = GetRepairDuration();

	local toolDef = nil;
	if destRepairIndex ~= nil then
		toolDef = ToolDefCsv:get(ClientBackpack:getGridItem(destRepairIndex));
	end

	if toolDef ~= nil then
		local curDur = ClientBackpack:getGridDuration(destRepairIndex);
		local totalDur = ClientBackpack:getGridMaxDuration(destRepairIndex);
		local cost = 0;
		if repiarDur ~= 0 then
			cost = math.ceil( toolDef.RepairExp + repiarDur*0.01 );
		end
		getglobal("RepairFrameRepairBtnStarNum"):SetText(cost);
		getglobal("RepairFrameDurTitle"):Show();
		getglobal("RepairFrameDuration"):SetText(curDur.."/"..totalDur);
	else
		getglobal("RepairFrameDurTitle"):Hide();
		getglobal("RepairFrameDuration"):SetText("");
		getglobal("RepairFrameRepairBtnStarNum"):SetText("");
	end
end

function GetPlaceRepairStuffNum(grid_index)
	local itemId = ClientBackpack:getGridItem(grid_index);
	local toolDef = ToolDefCsv:get(ClientBackpack:getGridItem(destRepairIndex));
	
	if itemId > 0 and toolDef ~= nil then
		local num = ClientBackpack:getGridNum(grid_index);
		local RepairAmount = 0;
		for i=1,6 do
			if itemId == toolDef.RepairId[i-1] then
				RepairAmount = toolDef.RepairAmount[i-1];
				break;
			end
		end
		local needNum = math.ceil( GetRepairDuration() / RepairAmount );
		
		if num < needNum then
			needNum = num;
		end

		SetRepairResultGrid( needNum*RepairAmount );
		return needNum;	
	end
end

function GetRepairDuration()
	if destRepairIndex ~= nil then
		local toolDef = ToolDefCsv:get(ClientBackpack:getGridItem(destRepairIndex));
		if toolDef ~= nil then
			local curDur 	= ClientBackpack:getGridDuration(destRepairIndex);
			local totalDur 	= ClientBackpack:getGridMaxDuration(destRepairIndex);
			return totalDur - curDur;
		end
	end
	return 0;
end

function SetRepairResultGrid(durable)
	if GetRepairDuration() < durable then
		durable = GetRepairDuration();
	end

	local btn 	= getglobal("RepairFrameRepairItem3");
	local icon 	= getglobal("RepairFrameRepairItem3Icon");
	local num	= getglobal("RepairFrameRepairItem3Count");
	local durbkg	= getglobal("RepairFrameRepairItem3DurBkg");
	local durbar	= getglobal("RepairFrameRepairItem3Duration");
	local enChantTexture1 = getglobal("RepairFrameRepairItem3IconFumoEffect1");
	local enChantTexture2 = getglobal("RepairFrameRepairItem3IconFumoEffect2");

	local RepairFrameDurTitle1 = getglobal("RepairFrameDurTitle1")
	local RepairFrameDuration1 = getglobal("RepairFrameDuration1")

	btn:SetClientUserData(4, 0)

	if destRepairIndex ~= nil and stuffRepairIndex ~= nil then	
		btn:SetClientUserData(4, destRepairIndex)	
		UpdateVirtualItemIcon(icon, num, durbar, destRepairIndex, 1, durbkg, btn, false);
		--最新需求不变灰了
		-- icon:SetGray(true);
		
		local itemId = ClientBackpack:getGridItem(destRepairIndex);
		local toolDef = ToolDefCsv:get(itemId);
		if itemId > 0 and toolDef ~= nil then
			local dur = ClientBackpack:getGridDuration(destRepairIndex) + durable;	
			SetDurationVirtualItem(durbar, destRepairIndex, dur, durbkg);

			RepairFrameDurTitle1:Show();
			RepairFrameDuration1:SetText(dur.."/"..ClientBackpack:getGridMaxDuration(destRepairIndex));
		else
			RepairFrameDurTitle1:Hide();
			RepairFrameDuration1:SetText("");
		end
	else
		icon:SetTextureHuires(ClientMgr:getNullItemIcon());
		num:SetText("");
		enChantTexture1:Hide();	
		enChantTexture2:Hide();	
		durbar:Hide();
		durbkg:Hide();
		RepairFrameDurTitle1:Hide();
		RepairFrameDuration1:SetText("");
		btn:SetClientID(0);
	end
end

function SetDurationVirtualItem(durbar, grid_index, dur, durbkg)
	maxdur = ClientBackpack:getGridMaxDuration(grid_index);
	if maxdur > 0 then
		if dur < 0 then dur = 0 end
		dur = dur/maxdur

		durbar:SetWidth(73*dur);

		if dur > 0.8 then durbar:SetColor(0, 255, 0) --绿色
		elseif dur > 0.6 then durbar:SetColor(0, 128, 0) --深绿色
		elseif dur > 0.4 then durbar:SetColor(128, 128, 0) --棕色
		elseif dur > 0.2 then durbar:SetColor(255, 255, 0) --橙色
		else durbar:SetColor(255, 0, 0) end --红色

		if dur == 1.0 then
			durbar:Hide();
			durbkg:Hide();
		else
			durbar:Show();
			durbkg:Show();
		end
	else
		durbar:Hide();
		durbkg:Hide();
	end
end