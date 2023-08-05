NORMAL_PRODUCT_GRID_MAX = 100;			--3*3制作物列表栏
CRAFT_GRID_MAX = 10				--合成栏
local Cur_Product_Type = 0;				--1常用 2装备 3建筑 4机械 5配方	 	

function CraftingTableFrame_OnLoad()
	--标题栏
	getglobal("CraftingTableFrameTitleName"):SetText(GetS(3500));

	--原料格子布局
	for i = 1, 6 do
		local row = math.ceil(i / 2);
		local col = (i - 1) % 2;
		local createItem = getglobal("CraftingTableFrameCraftingFrameStuffGrid" .. i);
		createItem:SetPoint("topleft", "CraftingTableFrameCraftingFrameRightBkg", "topleft", col * 239 + 15, (row - 1) * 76 + 48);
	end
end

function CraftingTableFrame_OnShow()
	HideAllFrame("CraftingTableFrame", true);

	--[[
	if CurWorld:getOWID() == NewbieWorldId then
		local taskId = AccountManager:getCurNoviceGuideTask();
		if taskId == 14 then
			getglobal("GuideTipsFrame"):Hide();
			AccountManager:setNoviceGuideState("openCT", true);
			AccountManager:setCurNoviceGuideTask(15);
			ShowCurNoviceGuideTask();
			ClientCurGame:stopEffect();
		elseif taskId == 18 then
			HideGuideFingerFrame();
		end
	end
	]]

	--切到第一个标签页
	CraftingTabBtnTemplate_OnClick(0);
	press_btn("CraftingTableFrameCommonBtn");

	local craftingTableFrameCommonBtn 	= getglobal("CraftingTableFrameCommonBtn");
	craftingTableFrameCommonBtn:Checked();
	if not getglobal("CraftingTableFrame"):IsReshow() then
	   ClientCurGame:setOperateUI(true);
	end

	if ClientBackpack:showRecipeProduct() then
		getglobal("CraftingTableFrameRecipeBtn"):Show();
	else
		getglobal("CraftingTableFrameRecipeBtn"):Hide();
	end
end

function CraftingTableFrame_OnHide()
	ShowMainFrame();
	ClearCragtingFrameAllStuffGrid();
	local mItemTipsFrame 	= getglobal("MItemTipsFrame");
	if mItemTipsFrame:IsShown() then
		mItemTipsFrame:Hide();
	end

	if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 15 then
		local taskId = AccountManager:getCurNoviceGuideTask();
		if taskId == 15 then
			HideGuideFingerFrame();
			AccountManager:setCurNoviceGuideTask(14);
			AccountManager:setNoviceGuideState("openCT", false);
			ShowCurNoviceGuideTask();
		elseif taskId == 18 then
			ShowCurNoviceGuideTask();
		end
	end
	if not getglobal("CraftingTableFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end

	Cur_Product_Type = 0;
end

--tab按钮
local m_CraftingTabBtnInfo = {
	{nameID = 291, uiName="CraftingTableFrameCommonBtn", 	},	--常用
	{nameID = 3013, uiName="CraftingTableFrameEquipBtn", 	},		--装备
	{nameID = 292, uiName="CraftingTableFrameBuildBtn", 	},		--建筑
	{nameID = 293, uiName="CraftingTableFrameMachineBtn", 	},	--机械
	{nameID = 263, uiName="CraftingTableFrameRecipeBtn", 	},	--配方
};

function CraftingTabBtnTemplate_OnClick(id)
	print("CraftingTabBtnTemplate_OnClick:");

	if id then
		id = id;
	else
		id = this:GetClientID();
	end

	print("id = ", id);

	--切换按钮状态
	TemplateTabBtn2_SetState(m_CraftingTabBtnInfo, id);

	if id == 0 then
		--初始化tab状态
		return;
	end
	
	if true then
		ClearCragtingFrameAllStuffGrid();

		HideCraftingFrameAllItemBoxTexture();
		selectNormalProductId = 0;
		normalProductSortId = 0;
		CraftingTableSetClientID();
		getglobal("NormalProductBox"):resetOffsetPos();
		CraftingFrame_UpdateAllGrid();

		local mItemTipsFrame 	= getglobal("MItemTipsFrame");
		if mItemTipsFrame:IsShown() then
			mItemTipsFrame:Hide();
		end

		if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 15 then
			HideGuideFingerFrame();
			ShowCurNoviceGuideTask();
		end
	end
end

function CraftingTableSetClientID()
	local name = this:GetName();
	local base_index = COMMON_PRODUCT_LIST_INDEX;

	if string.find(name,"Common") then
		base_index = COMMON_PRODUCT_LIST_INDEX;
		Cur_Product_Type = 1;
		ClientBackpack:updateProductContainer(COMMON_PRODUCT_LIST_INDEX);
	elseif string.find(name,"Equip") then
		base_index = EQUIP_PRODUCT_LIST_INDEX;
		Cur_Product_Type = 2;
		ClientBackpack:updateProductContainer(EQUIP_PRODUCT_LIST_INDEX);
	elseif string.find(name,"Build") then
		base_index = BUILD_PRODUCT_LIST_INDEX;
		Cur_Product_Type = 3;
		ClientBackpack:updateProductContainer(BUILD_PRODUCT_LIST_INDEX);
	elseif string.find(name,"Machine") then
		base_index = MACHINE_PRODUCT_LIST_INDEX;
		Cur_Product_Type = 4;
		ClientBackpack:updateProductContainer(MACHINE_PRODUCT_LIST_INDEX);
	elseif string.find(name,"Recipe") then
		base_index = RECIPE_PRODUCT_LIST_INDEX;
		Cur_Product_Type = 5;
		ClientBackpack:updateProductContainer(RECIPE_PRODUCT_LIST_INDEX);
	elseif string.find(name,"CraftingTableFrame") then
		base_index = COMMON_PRODUCT_LIST_INDEX;
		Cur_Product_Type = 1;
		ClientBackpack:updateProductContainer(COMMON_PRODUCT_LIST_INDEX);
	end

	for i=1,NORMAL_PRODUCT_GRID_MAX do
		local itembtn = getglobal("NormalProductBoxItem"..i);
		itembtn:SetClientID(base_index+i);
	end
	CraftingFrame_UpdateAllGrid();
end
-------------------------------------------------CraftingFrame----------------------------------------------------------

local Making = false;
local BeginMake = false;

function CraftingFrame_OnLoad()
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	CraftingFrame_AddGameEvent()
	LayoutManagerFactory:newGridLayoutManager()
		:setRelativeTo("NormalProductBoxPlane")
		:setBoxItemNamePrefix("NormalProductBoxItem")
		:setBoxItemWidth(78)
		:setBoxItemHeight(78)
		:setMarginX(5)
		:setMarginY(5)
		:setOffsetX(9)
		:setMaxColumn(6)
		:layoutAll(102)
		:resetPlaneWithMinimalSize(512, 416)
		:recycle()
end

function CraftingFrame_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local paramData = context:GetParamData()
		local index = paramData.gridIndex
		local canMakeWP = false;
		if getglobal("CraftingTableFrame"):IsShown() then
			if Cur_Product_Type == 1 then
				ClientBackpack:updateProductContainer(COMMON_PRODUCT_LIST_INDEX);
			elseif Cur_Product_Type == 2 then
				ClientBackpack:updateProductContainer(EQUIP_PRODUCT_LIST_INDEX);
			elseif Cur_Product_Type == 3 then
				ClientBackpack:updateProductContainer(BUILD_PRODUCT_LIST_INDEX);
			elseif Cur_Product_Type == 4 then
				ClientBackpack:updateProductContainer(MACHINE_PRODUCT_LIST_INDEX);
			elseif Cur_Product_Type == 5 then
				ClientBackpack:updateProductContainer(RECIPE_PRODUCT_LIST_INDEX);
			end

			CraftingFrame_UpdateAllGrid(index);
		end
	end)
end

function HideCraftingFrameAllItemBoxTexture()
	for i=1,NORMAL_PRODUCT_GRID_MAX do
		local boxTexture = getglobal("NormalProductBoxItem"..i.."BoxTexture");
		boxTexture:Hide(); 
	end
end

function CraftingFrame_UpdateAllGrid(index)
	for i=1,NORMAL_PRODUCT_GRID_MAX do
		local btn 	= getglobal("NormalProductBoxItem"..i);	
		local icon 	= getglobal("NormalProductBoxItem"..i.."Icon");
		local num 	= getglobal("NormalProductBoxItem"..i.."Count");
		local durbar 	= getglobal("NormalProductBoxItem"..i.."Duration");
		local lack	= getglobal("NormalProductBoxItem"..i.."Lack");
		local grid_index = btn:GetClientID() - 1;
		local id = ClientBackpack:getGridItem(grid_index);
		UpdateCratingItemIconCount(icon, num, durbar, grid_index, lack);
		
		local unlock = getglobal("NormalProductBoxItem"..i.."Unlock");
		unlock:Hide();
		local itemDef = ItemDefCsv:get(id);
		if itemDef ~= nil and itemDef.UnlockFlag > 0 then
			if not isItemUnlockByItemId(itemDef.ID) then  --未解锁
				icon:SetGray(true);
				lack:Hide();
				unlock:Show();				

				local proBkg 	= getglobal(unlock:GetName().."ProBkg");
				local pro 	= getglobal(unlock:GetName().."Pro");
				local lock 	= getglobal(unlock:GetName().."Lock");
				local count 	= getglobal(unlock:GetName().."Count");
				local hasNum = AccountManager:getAccountData():getAccountItemNum(itemDef.InvolvedID);

				if hasNum > 0 then
					local needNum = itemDef.ChipNum;
					local radio = hasNum/needNum;
					if hasNum > needNum then
						radio = 1.0;
					end
					
					pro:ChangeTexUVWidth(75*radio);
					pro:SetSize(75*radio, 18);

					lock:Hide();
					proBkg:Show();
					pro:Show();

					local text = hasNum.."/"..needNum;
					count:SetText(text);
				else
					proBkg:Hide();
					pro:Hide();
					lock:Show();
					count:SetText("");
				end
			end
		end
	end

	if true then		-- index为-1的时候，表示制作要消耗的材料已经消耗了，这个时候更新面板
		local grid_index = CheckNormalProductId(selectNormalProductId, normalProductSortId)
		local enough = 0;
		if grid_index > 0 then		--制作物列表里还有这个物品
			local btnName = GetCurNormalProductIdGridName(grid_index);
			SetOnclikItemBoxTexture( btnName );
			enough = ClientBackpack:getGridEnough(grid_index);
		else				
			HideCraftingFrameAllItemBoxTexture();
			selectNormalProductId = 0;
			normalProductSortId = 0;
		end
		local num = ClientBackpack:updateCraftContainer(normalProductSortId, CRAFT_START_INDEX, enough);

		UpdateCraftingFrameRight(grid_index, num);
		Making = false;
	end
end

function GetCurNormalProductIdGridName(index)
	for i=1,NORMAL_PRODUCT_GRID_MAX do
		local btn = getglobal("NormalProductBoxItem"..i);
		local grid_index = btn:GetClientID() - 1;
		if index == grid_index then
			return btn:GetName();
		end	
	end
	return "";
end

function CheckNormalProductId(productId, sortId)
	for i=1,NORMAL_PRODUCT_GRID_MAX do
		local btn = getglobal("NormalProductBoxItem"..i);
		local grid_index = btn:GetClientID() - 1;
		if ClientBackpack:getGridItem(grid_index) ~= 0 and ClientBackpack:getGridItem(grid_index) == productId then
			if sortId <= 0 then 
				return grid_index;
			elseif sortId == ClientBackpack:getGridSortId(grid_index) then
				return grid_index;
			end
		end	
	end
	return -1;
end

function UpdateCraftingFrameRight(grid_index, stuffNum)
	UpdateCraftingFrameAllStuffGrid(stuffNum);
	UpdateCraftingFrameTips(grid_index);
end

function ClearCragtingFrameAllStuffGrid()
	ClientBackpack:updateCraftContainer(0, CRAFT_START_INDEX, -1);
	UpdateCraftingFrameRight(-1, 0);
end

function UpdateCraftingFrameAllStuffGrid(stuffNum)
	local icon 	= getglobal("CraftingTableFrameCraftingFrameMakeResultIcon");
	local num 	= getglobal("CraftingTableFrameCraftingFrameMakeResultCount");
	local durbar 	= getglobal("CraftingTableFrameCraftingFrameMakeResultDuration");
	local lack	= getglobal("CraftingTableFrameCraftingFrameMakeResultLack");
	local name 	= getglobal("CraftingTableFrameCraftingFrameMakeResultName");
	local desc 	= getglobal("CraftingTableFrameCraftingFrameMakeResultDesc");
	local grid_index = CRAFT_START_INDEX + CRAFT_GRID_MAX - 1;
	local id = ClientBackpack:getGridItem(grid_index);
	UpdateCratingItemIconCount(icon, num, durbar, grid_index, lack, name, desc);

	if id ~= 0 then
		local craftingTableFrameCraftingFrameMakeBtnNormal = getglobal("CraftingTableFrameCraftingFrameMakeBtnNormal");
		local craftingTableFrameCraftingFrameMakeBtnName = getglobal("CraftingTableFrameCraftingFrameMakeBtnName")
		if ClientBackpack:getGridEnough(grid_index) == 0 then
			craftingTableFrameCraftingFrameMakeBtnNormal:SetGray(true);
			craftingTableFrameCraftingFrameMakeBtnName:SetTextColor( 55, 54, 50)
		else
			craftingTableFrameCraftingFrameMakeBtnNormal:SetGray(false);
			craftingTableFrameCraftingFrameMakeBtnName:SetTextColor(55, 54, 51)
		end
	end

	if stuffNum > 0 then
		getglobal("CraftingTableFrameCraftingFrameRightTips"):SetText(GetS(3972, stuffNum), 77, 112, 117);
	else
		getglobal("CraftingTableFrameCraftingFrameRightTips"):SetText("", 77, 112, 117);
	end

	for i=1,CRAFT_GRID_MAX - 4 do
		icon 	= getglobal("CraftingTableFrameCraftingFrameStuffGrid"..i.."Icon");
		num 	= getglobal("CraftingTableFrameCraftingFrameStuffGrid"..i.."Count1");
		durbar 	= getglobal("CraftingTableFrameCraftingFrameStuffGrid"..i.."Duration");
		lack	= getglobal("CraftingTableFrameCraftingFrameStuffGrid"..i.."Lack");
		name	= getglobal("CraftingTableFrameCraftingFrameStuffGrid"..i.."Name");
		desc	= getglobal("CraftingTableFrameCraftingFrameStuffGrid"..i.."Desc");
		grid_index = CRAFT_START_INDEX + i - 1;
		id = ClientBackpack:getGridItem(grid_index);
			
		UpdateCratingItemIconCount(icon, num, durbar, grid_index, lack, name, desc);
	end
end

function UpdateCraftingFrameTips(grid_index)
	local craftingTableFrameCraftingFrameName = getglobal("CraftingTableFrameCraftingFrameName");
	local craftingTableFrameCraftingFrameItemDesc = getglobal("CraftingTableFrameCraftingFrameItemDesc");
	if grid_index < 0 or ClientBackpack:getGridItem(grid_index) <= 0 then
		craftingTableFrameCraftingFrameName:SetText("");
		craftingTableFrameCraftingFrameItemDesc:Clear();
	else
		local name = ClientBackpack:getGridItemName(grid_index);
		local itemId 	= ClientBackpack:getGridItem(grid_index);
		local itemDef 	= ItemDefCsv:get(itemId)
		if itemDef ~= nil then
			craftingTableFrameCraftingFrameName:SetText(name);
			local pos = string.find(itemDef.Desc, "#");
			local text = itemDef.Desc;
			if pos ~= nil then		--把颜色替换掉
				local colorString = string.sub(itemDef.Desc, pos, pos+7);
				text = string.gsub(itemDef.Desc, colorString, "");
			end
			craftingTableFrameCraftingFrameItemDesc:SetText(text, 118, 67, 0);
		end
	end
end

function CraftingFrame_OnEvent()
	local ge = GameEventQue:getCurEvent();
	local index = ge.body.backpack.grid_index;

	if arg1 == "GE_BACKPACK_CHANGE" then
		local canMakeWP = false;
		--[[
		if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 15 then
			local indexWP = CheckNormalProductId(11011, 0);
			if indexWP > 0 then
				if ClientBackpack:getGridEnough(indexWP) == 0 then
					canMakeWP = false;
				else
					canMakeWP = true;
				end
			else
				canMakeWP = false;
			end
		end
		]]

		if getglobal("CraftingTableFrame"):IsShown() then
			if Cur_Product_Type == 1 then
				ClientBackpack:updateProductContainer(COMMON_PRODUCT_LIST_INDEX);
			elseif Cur_Product_Type == 2 then
				ClientBackpack:updateProductContainer(EQUIP_PRODUCT_LIST_INDEX);
			elseif Cur_Product_Type == 3 then
				ClientBackpack:updateProductContainer(BUILD_PRODUCT_LIST_INDEX);
			elseif Cur_Product_Type == 4 then
				ClientBackpack:updateProductContainer(MACHINE_PRODUCT_LIST_INDEX);
			elseif Cur_Product_Type == 5 then
				ClientBackpack:updateProductContainer(RECIPE_PRODUCT_LIST_INDEX);
			end

			CraftingFrame_UpdateAllGrid(index);
		end
	
		--[[
		local craftingTableFrameCraftingFrame = getglobal("CraftingTableFrameCraftingFrame");
		if not craftingTableFrameCraftingFrame:IsShown() then return; end

		CraftingFrame_UpdateAllGrid(index);
		]]

		--更新合成木镐的新手引导
		--[[
		local base_index = getglobal("NormalProductBoxItem1"):GetClientID() - 1;
		if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 15
		   and base_index >= COMMON_PRODUCT_LIST_INDEX and base_index < EQUIP_PRODUCT_LIST_INDEX then
			UpdateNoviceForMakeWP(canMakeWP);
		end
		]]		
	end
end

function CheckNormalProducIsLackItem()
	for i=1,CRAFT_GRID_MAX - 4 do
		local grid_index = CRAFT_START_INDEX + i - 1;
		if ClientBackpack:getGridEnough(grid_index) == -1 then
			local name = ClientBackpack:getGridItemName(grid_index)
			return true,name;
		end	
	end
	return false,"";
end

local CraftingTime = 0
local IsMakeLongPress = false;	--标记制作按钮为长按按钮状态
function CraftingFrameMakeBtn_MouseDownUpdate()
	if arg1-CraftingTime > 0.2 then
		CraftingTime = arg1;
		IsMakeLongPress = true;
		CraftingFrameMakeFunc();		
	end
end

function CraftingFrameMakeBtn_OnClick()
	CraftingTime = 0;
	if IsMakeLongPress then
		IsMakeLongPress = false;
		return;
	end
	CraftingFrameMakeFunc();
end

function CraftingFrameMakeFunc()
	if Making then return; end

	--Making = true;
	local grid_index = CheckNormalProductId(selectNormalProductId, normalProductSortId);
	if grid_index < 0 then
		ShowGameTips(GetS(35), 3);
		Making = false;
		return;
	end

	local result_index = getglobal("CraftingTableFrameCraftingFrameMakeResult"):GetClientID() - 1;
	local resultId = ClientBackpack:getGridItem(result_index);
	
	if ClientBackpack:getGridItem(grid_index) > 0 then
		local resultDef = ItemDefCsv:get(resultId);
		if resultDef.UnlockFlag > 0 then
			local unlock, hasUnlockInfo = isItemUnlockByItemId(resultDef.ID)
			if not unlock then
				ShowItemUnLockTips(hasUnlockInfo)
				return
			end
		end

		local isLack,itemName = CheckNormalProducIsLackItem();
		if isLack then
			local text = GetS(61, itemName);
			ShowGameTips(text, 2);
			Making = false
			ClientMgr:playSound2D("sounds/ui/info/crafting_error.ogg", 1);
		else
			local num = ClientBackpack:getCurCraftIdsNum()
			for i=1, num do
				local id = ClientBackpack:getCurCraftId(i-1);
				local def = DefMgr:getCraftingDef(id)
				local itemDef = ItemDefCsv:get(def.ResultID);
				if def and itemDef then
					CurMainPlayer:craftItem(id);
					local text = GetS(62, itemDef.Name, def.ResultCount);
					ShowGameTips(text, 1);
				end
			end
	
			CurMainPlayer:craftItem(normalProductSortId)				
			itemName = ClientBackpack:getGridItemName(result_index);
			itemNum = ClientBackpack:getGridNum(result_index);
			local text = GetS(62, itemName, itemNum);
			ShowGameTips(text, 1);

			local effect = getglobal("CraftingTableFrameCraftingFrameEffect");
			effect:SetUVAnimation(100, false);
			ClientMgr:playSound2D("sounds/ui/info/crafting_success.ogg", 1);

			--新手引导合成木镐
			if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 15 then
				if ClientBackpack:getGridItem(grid_index) == 11011 then
					AddGuideTaskCurNum(12, 1);
					HideGuideFingerFrame();
					AccountManager:setNoviceGuideState("makeWP", true);
					AccountManager:setCurNoviceGuideTask(16);
					ShowCurNoviceGuideTask();
				end			
			end
		end
	end
end

function UpdateNoviceForMakeWP(canMakeWP)
	local grid_index = CheckNormalProductId(11011, 0);
	if grid_index > 0 then
		if ClientBackpack:getGridEnough(grid_index) == 0 then
			if canMakeWP then
				HideGuideFingerFrame();
				SetGuideTipsInfo(-260, 65, 1, GetS(302));
			end
		else
			if not canMakeWP then
				HideGuideFingerFrame();
				SetGuideTipsInfo(-260, 65, 1, GetS(303), 14);
				local index = grid_index+1-COMMON_PRODUCT_LIST_INDEX;
				local indexX = index - math.floor((index-1)/5)*5;
				local indexY = math.floor((index-1)/5);
				x = 240 + (indexX-1)*92;
				y = 115 + indexY*94;	
				SetGuideFingerInfo(x, y, 0, 5, true, 100);
			end
		end
	else
		if canMakeWP then
			HideGuideFingerFrame();
			SetGuideTipsInfo(-260, 65, 1, GetS(302));
		end
	end	
end
