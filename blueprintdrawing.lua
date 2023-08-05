BLURPRINTBOX_GRID_MAX=600;
ISDrawingBtnClick = false;
IS_SHIFT_MOVE = false;

ISTest = false;

local BLUEPRINT_LELF_GRID_MAX = 38;

BF_Data ={

	allNeedStuffTable={},
	enoughNum = 0,
	allStuffNum=0,
	drawingName=nil,
	authorName="",
	fileName="",
	tileName="",
	dimX = 0,
	dimY = 0,
	dimZ = 0,
	homefree = {}, -- 家园免费的情况  1 = 免费，0
	init = function ()
		--获取蓝图图纸名字
		local uin, author, title, context, filename, dimX, dimY, dimZ = BlueprintStringParse(OpenContainer:getBPDataStr());
		if filename == "" then
			BF_Data.drawingName = OpenContainer:getBPDataStr();
		else
			BF_Data.drawingName = filename; 	
		end
		BF_Data.authorName = author;
		BF_Data.tileName = title;

		if dimX then
        	dimX = tonumber(dimX);
        	if dimX < 0 then
        		dimX = 0 - dimX;
        	end
        end

        if dimY then
        	dimY = tonumber(dimY);
        	if dimY < 0 then
        		dimY = 0 - dimY;
        	end
        end

        if dimZ then
        	dimZ = tonumber(dimZ);
        	if dimZ < 0 then
        		dimZ = 0 - dimZ;
        	end
        end
		BF_Data.dimX = dimX;
		BF_Data.dimY = dimY;
		BF_Data.dimZ = dimZ;
		
		if BF_Data.drawingName==nil then Log("the drawing name obtained is fail:BF_Data.init()"); end

		--获取蓝图图纸需要材料的总数
		if BF_Data.drawingName~=nil then 
			if BluePrintMgr  then
				BF_Data.allStuffNum = BluePrintMgr:getMaterialNumByBP(BF_Data.drawingName);
			else
				BF_Data.allStuffNum = WorldMgr:getMaterialNumByBP(BF_Data.drawingName);
			end
			if BF_Data.allStuffNum <= 0 then Log("get drawing stuff num is nil :BF_Data.init()"); end
		end

		--获取蓝图图纸每个材料的id和数量
		--[[
		if BF_Data.drawingName~=nil and BF_Data.allStuffNum >0 then
			for i = 0,BF_Data.allStuffNum - 1 do 
				local materialInfo = BluePrintMgr:getMaterialInfoByBP(BF_Data.drawingName,i);
				if materialInfo then
					BF_Data.allNeedStuffTable[i+1]={};
					BF_Data.allNeedStuffTable[i+1].itemId=materialInfo.itemid;
					BF_Data.allNeedStuffTable[i+1].itemNum=materialInfo.num;
					BF_Data.allNeedStuffTable[i+1].durable=materialInfo.durable;
					BF_Data.allNeedStuffTable[i+1].enchantnum=materialInfo.enchantnum;
					BF_Data.allNeedStuffTable[i+1].enchants = {};
					for j=1, materialInfo.enchantnum do
						table.insert(BF_Data.allNeedStuffTable[i+1].enchants, materialInfo:getIthEnchant(j-1));
					end
				else
					Log("get index is :"..i.." itemId or itemNum is nil : BF_Data:init()");
				end
			end
		end
		]]

		-- --TODO kekeke newlogic
		-- BF_Data.allStuffNum = 0;
		-- for i =1, BLURPRINTBOX_GRID_MAX do 
		-- 	local grid_index = BUILDBLUEPRINT_START_INDEX +i;
		-- 	local itemId = CurMainPlayer:getBackPack():getGridItem(grid_index-1);
		-- 	if itemId > 0 then
		-- 		BF_Data.allStuffNum = BF_Data.allStuffNum + 1;

		-- 		print("kekeke BF_Data.allStuffNum", BF_Data.allStuffNum);
		-- 	end
		-- end
		-- print("kekeke allNeedStuffTable", BF_Data.allNeedStuffTable);
	end,

	updateStuffEnoughNum = function ()
		-- 从蓝图容器中获取相关的数据，在初始化的时候获取，在event中刷新显示
		--[[
		if BF_Data.allStuffNum >=0 then
			local index =0;

			for i =1, BF_Data.allStuffNum do 

				local grid_index = BUILDBLUEPRINT_START_INDEX +i;
				local grid = CurMainPlayer:getBackPack():index2Grid(grid_index-1);
				local needStuff = BF_Data.getOriginalGridInfo(i);

				if needStuff~=nil and grid~=nil and needStuff.itemId==grid:getItemID() then
					if needStuff.itemNum <= grid:getNum() then
						index = index+1;
					end
				else
					Log("get item num that is enough is fail :BF_Data.updateStuffEnoughNum(),i: "..i);
				end
			end

			if index >=0 and index <=BF_Data.allStuffNum then
				BF_Data.enoughNum = index;
			end
		end
		]]

		--TODO kekeke newlogic
		BF_Data.enoughNum = 0;
		BF_Data.homefree = {}
		for i =1, BF_Data.allStuffNum do 
			local grid_index = BUILDBLUEPRINT_START_INDEX +i;
			local grid = CurMainPlayer:getBackPack():index2Grid(grid_index-1);
			
			if grid and grid:getItemID() > 0  then
				--TODOhome
				if IsInHomeLandMap and IsInHomeLandMap() then
					--跟家园背包里的材料相比
					local itemId = grid:getItemID();
					if GetInst("HomeLandConfig") then
						local functionIdCfg = GetInst("HomeLandConfig").define.functionIdCfg
						local isUnlimit = GetInst("HomeLandConfig"):findHomeItemFunctionInfo(itemId, functionIdCfg.UnLimitUse)
						BF_Data.homefree[itemId] = isUnlimit and 1 or 0 --免费不显示个数
					end
					if getStuffRealNumByHomeLandBackpack(itemId, grid:getUserDataInt()) >= grid:getUserDataInt() then
						BF_Data.enoughNum = BF_Data.enoughNum + 1;
					end
				elseif grid:getNum() >= grid:getUserDataInt() then
					BF_Data.enoughNum = BF_Data.enoughNum + 1;
				end
			end
		end

	end,

	getOriginalGridInfo = function (index) --获取蓝图图纸单个信息
		if BF_Data. allStuffNum > 0 and index <= BF_Data. allStuffNum then
			local GridInfo = BF_Data.allNeedStuffTable[index];
			if GridInfo~= nil then 
				return GridInfo;
			else
				Log("get original grid info is nil :BF_Data.getOriginalGridInfo()");
				return nil;
			end
		end

		return nil;
	end,

	getIndexBySrcIndex=function (src_index)
		--TODO kekeke newlogic
		for i =1, BF_Data.allStuffNum do 
			local grid_index = BUILDBLUEPRINT_START_INDEX + i -1;
			if BF_CanPutinGrid(grid_index, src_index) then
				return grid_index;
			end
		end

		return nil;

		--[[
		if itemId<=0 then return nil end

		for k,v in pairs(BF_Data.allNeedStuffTable) do
			if v~=nil and v.itemId == itemId then
				local grid_index = BUILDBLUEPRINT_START_INDEX+k;
				return grid_index;
			end
		end

		return nil;
		]]
	end,

	getAllNeedStuff = function ()
		if BF_Data.allNeedStuff ~= nil then
			return BF_Data.allNeedStuff;
		end
	end,

	getContainerGrid=function (grid_index)
		if not CurMainPlayer then
			return nil;
		end

		local grid = CurMainPlayer:getBackPack():index2Grid(grid_index);

		if grid ~= nil then 
			return grid;
		end
		return nil;
	end,

	getGridNeedNum = function (grid_index) --获取某一个格子需要的总共的数字
		local grid = CurMainPlayer:getBackPack():index2Grid(grid_index);

		if grid~=nil then
			local id = grid:getItemID();
			for k,v in pairs(BF_Data.allNeedStuffTable) do 
				if v.itemId == id then
					return v.itemNum;
				end
			end
		end

		return nil;
	end,

	getBlueprintName = function ()
		--TODOhome
		if IsInHomeLandMap and IsInHomeLandMap() then
			return GetS(9299);
		elseif BF_Data.tileName and BF_Data.tileName ~= "" then
			return BF_Data.tileName;
		elseif BF_Data.drawingName and BF_Data.drawingName ~= "" then
			return BF_Data.drawingName;
		else
			return "蓝图图纸";
		end
	end,

	getAuthorName= function ()
		if BF_Data.authorName ~= "" then
			return BF_Data.authorName;
		else
			return "作者名字";
		end
	end,

	getRange = function ()
		local range = BF_Data.dimX.."x"..BF_Data.dimY.."x"..BF_Data.dimZ;
		return range;
	end,

	getDescribe = function ()
		local describe = "具体的描述具体的描述"
		return describe;
	end,

	getEnoughNum = function ()
		if BF_Data.enoughNum~= nil and BF_Data.enoughNum >=0 then
			return BF_Data.enoughNum;
		end
	end,

	getAllStuffNum = function ()
		if BF_Data.allStuffNum ~= nil then
			return BF_Data.allStuffNum;
		end
	end,

	clear = function ()
		BF_Data.allNeedStuffTable = {};
		BF_Data.enoughNum = 0;
		BF_Data.allStuffNum = 0;
		BF_Data.drawingName=nil;
		BF_Data.homefree = {}
	end,
}
---------------------------------------------------------------------------------------------

function getStuffRealNumByHomeLandBackpack(itemId, needNum)
	if not GetInst("HomeLandDataManager") or not GetInst("HomeLandConfig") then
		return 0;
	end

	if itemId <= 0 then
		return 0;
	end

	local hasNum = GetInst("HomeLandDataManager"):GetBackpackItemCanUseNumById(itemId);
	local isUnlimit = GetInst("HomeLandConfig"):findHomeItemFunctionInfo(itemId, GetInst("HomeLandConfig").define.functionIdCfg.UnLimitUse)
	if isUnlimit and needNum then
		return needNum;
	else
		return hasNum;
	end

	return 0
end

function BlueprintDrawingFrameOnLoad()
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	BFHelpBtn_AddGameEvent()
	for i=1,7 do
		for j=1,6 do
			local index = (i-1)*6+j;
			if HasUIFrame("BluePrintLeftBoxItem"..index) then
				local itembtn = getglobal("BluePrintLeftBoxItem"..index);
				itembtn:SetPoint("topleft", "BluePrintLeftBoxPlane", "topleft", (j-1)*85, (i-1)*83);
			end
		end
	end
end

function BFHelpBtn_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local paramData = context:GetParamData()
		local grid_index = paramData.gridIndex
		if getglobal("BluePrintDrawingFrame"):IsShown() then
			if (grid_index and grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX + 1000) or (grid_index and grid_index >= ClientBackpack:getShortcutStartIndex() and grid_index < ClientBackpack:getShortcutStartIndex() + 1000) then
				local n = getBluePrintLeftUIIndex(grid_index);
				if n > 0 then
					BF_UpdateLeftBoxOneItem(grid_index, n,true);
				end
			end

			local n;
			if grid_index and grid_index >= BUILDBLUEPRINT_START_INDEX and grid_index < BUILDBLUEPRINT_START_INDEX + 1000 then
				n = grid_index - BUILDBLUEPRINT_START_INDEX + 1;
				if n > 0 and (not IsInHomeLandMap or not IsInHomeLandMap()) then
					BF_UpdateRightBoxOneItem(grid_index);
					BF_ShowStuffNum();
				end
			end
		end

		BF_Data.updateStuffEnoughNum();
	end)
end

function BFHelpBtn_OnClick()
	getglobal("BluePrintDrawingHelpFrame"):Show();
	getglobal("BluePrintDrawingHelpFrameBoxContent"):SetText(GetS(9302), 61, 69, 70);
end

function BFHelpBtnClose_OnClick()
	getglobal("BluePrintDrawingHelpFrame"):Hide()
end

function BlueprintDrawingFrameOnShow()
	HideAllFrame("BluePrintDrawingFrame", true);

	if not getglobal("BluePrintDrawingFrame"):IsReshow() then
	    ClientCurGame:setOperateUI(true);
	end

	if ShortCut_SelectedIndex >= 0 then		--打开背包时，把选中的快捷栏工具隐藏
		local selbox = getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."Check");
		selbox:Hide()
	end

	-- 更新数据
	if ISTest ==true then
		BF_Data.drawingName = "测试图纸";
		BF_Data.allStuffNum = 11;
		BF_Data.allNeedStuffTable 
		= {
			{itemId=400,itemNum=1},
			{itemId=401,itemNum=2},
			{itemId=402,itemNum=3},
			{itemId=403,itemNum=4},
			{itemId=404,itemNum=5},
			{itemId=405,itemNum=6},
			{itemId=406,itemNum=7},
			{itemId=407,itemNum=8},
			{itemId=408,itemNum=9},
			{itemId=409,itemNum=10},
			{itemId=410,itemNum=11},
		}

	else 
		BF_Data.init();
	end

	--BF_InitItemToContainer();
	BF_Data.updateStuffEnoughNum();

	-- 显示UI
	-- BF_ShowRightGridState();
	--TODOhome
	if IsInHomeLandMap and IsInHomeLandMap() then
		getglobal("BluePrintLeftBox"):Hide();
		getglobal("BluePrintDrawingFrameVLine"):Hide();
		getglobal("BluePrintDrawingFrameLeftTitle"):Hide();
		getglobal("BluePrintDrawingFrameHelpBtn"):Hide();
		getglobal("BluePrintDrawingFrameTitle"):SetPoint("left", "BluePrintDrawingFrameTitleFrameBkgLeft", "left", 35, 7)
		getglobal("BluePrintDrawingFrameRightBkg"):SetPoint("top", "BluePrintDrawingFrameBkg", "top", 0, 120)
		getglobal("BluePrintDrawingFramePutInBtn"):Hide();
		getglobal("BluePrintDrawingFrameLeftBkg"):Hide();
		getglobal("BluePrintDrawingFrameBuildBtn"):Show();
		getglobal("BluePrintDrawingFrame"):SetSize(542, 603);
		getglobal("BluePrintDrawingFrameTitleFrame"):SetSize(542, 61);
	else
		getglobal("BluePrintDrawingFrame"):SetSize(1072, 603);
		getglobal("BluePrintDrawingFrameTitleFrame"):SetSize(1072, 61);
		getglobal("BluePrintLeftBox"):Show();
		getglobal("BluePrintDrawingFrameVLine"):Show();
		getglobal("BluePrintDrawingFrameLeftTitle"):Show();
		getglobal("BluePrintDrawingFrameHelpBtn"):Show();
		getglobal("BluePrintDrawingFramePutInBtn"):Show();
		getglobal("BluePrintDrawingFrameBuildBtn"):Hide();
		getglobal("BluePrintDrawingFrameLeftBkg"):Show();
		getglobal("BluePrintDrawingFrameTitle"):SetPoint("left", "BluePrintDrawingFrameTitleFrameBkgLeft", "left", 90, 7)
		getglobal("BluePrintDrawingFrameRightBkg"):SetPoint("topright", "BluePrintDrawingFrameBkg", "topright", -9, 120)
		BF_UpdateLeftBoxAllItem();
	end
	BF_UpdateRightBoxAllItem();
	BF_ShowInformaiton();
	BF_ShowStuffNum()
end

function BlueprintDrawingFrameOnHide()
	ShowMainFrame();

	if not getglobal("BluePrintDrawingFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end

	if ShortCut_SelectedIndex >= 0 then		--关闭背包时，把选中的快捷栏工具显示
		CurMainPlayer:setCurShortcut(ShortCut_SelectedIndex);		
		local selbox = getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."Check");
		selbox:Show()
	end

	CurMainPlayer:closeContainer();
	BF_Data.clear();
	BF_ClearAllGridContent();
end

function BlueprintDrawingFrameOnEvent()
	local ge = GameEventQue:getCurEvent();
	local grid_index = ge.body.backpack.grid_index;

	if arg1 == "GE_BACKPACK_CHANGE" then
		if getglobal("BluePrintDrawingFrame"):IsShown() then
			if (grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX + 1000) or (grid_index >= ClientBackpack:getShortcutStartIndex() and grid_index < ClientBackpack:getShortcutStartIndex() + 1000) then
				local n = getBluePrintLeftUIIndex(grid_index);
				if n > 0 then
					BF_UpdateLeftBoxOneItem(grid_index, n,true);
				end
			end
			
			local n;
			if grid_index >= BUILDBLUEPRINT_START_INDEX and grid_index < BUILDBLUEPRINT_START_INDEX + 1000 then
				n = grid_index - BUILDBLUEPRINT_START_INDEX + 1;
				if n > 0 and (not IsInHomeLandMap or not IsInHomeLandMap()) then
					BF_UpdateRightBoxOneItem(grid_index);
					BF_ShowStuffNum();
				end
			end		
		end

		BF_Data.updateStuffEnoughNum();
	end
end

function BlueprintDrawingFrameClose_OnClick()
	getglobal("BluePrintDrawingFrame"):Hide();
end

function BF_PutInAll_OnClick()
	BF_PutAllStuff();
end

function BF_BuildBtn_OnClick()
	if not GetInst("HomeLandDataManager") then
		return;
	end
	
	if not IsInHomeLandMap or not IsInHomeLandMap() then
		return;
	end

	if OpenContainer and OpenContainer.outsideWorkArea then
		if OpenContainer:outsideWorkArea() then
			ShowGameTips(GetS(41336));
			return;
		end
	end

	if BF_Data.getEnoughNum() < BF_Data.getAllStuffNum() then
		ShowGameTips(GetS(41335));
		return;
	end

	if OpenContainer and OpenContainer.setRateByPower then
		--TODOhome 扣除材料
		--检查材料是否足够
		local t_Stuff = {};
		for i=1, BF_Data.allStuffNum do 
			local grid_index = BUILDBLUEPRINT_START_INDEX +i;
			local grid = CurMainPlayer:getBackPack():index2Grid(grid_index-1);		
			if grid and grid:getItemID() > 0  then
				local itemId = grid:getItemID();	
				local num = grid:getUserDataInt();
				if getStuffRealNumByHomeLandBackpack(itemId, num) >= num then
					table.insert(t_Stuff, {id=itemId, num=num})
				else
					ShowGameTips(GetS(41335));
					return;
				end
			end
		end
		--消耗材料
		for i=1, #(t_Stuff) do
			local t_data = {id = t_Stuff[i].id, num = t_Stuff[i].num};
			GetInst("HomeLandDataManager"):DeleteBackpackItemData(t_data);
		end

		OpenContainer:setRateByPower(15);
		BlueprintDrawingFrameClose_OnClick();
	end
end
-----------------------------------------------------------------------------------------------------
function getBluePrintLeftUIIndex(grid_index)
	for i=1, BLUEPRINT_LELF_GRID_MAX do
		local item = getglobal("BluePrintLeftBoxItem"..i);
		if item:GetClientID() == grid_index+1 then
			return i;
		end
	end

	return -1;
end

function BF_UpdateLeftBoxAllItem()
	for i=1, BLUEPRINT_LELF_GRID_MAX do
		local item = getglobal("BluePrintLeftBoxItem"..i);
		item:SetClientID(0);
	end

	local n = 1;
	for i=1,BACK_PACK_GRID_MAX do
		local grid_index = i + BACKPACK_START_INDEX - 1;
		local itemid = ClientBackpack:getGridItem(grid_index);
		print("kekeke BF_UpdateLeftBoxAllItem", itemid);
		if itemid > 0 then
			BF_UpdateLeftBoxOneItem(grid_index, n,true);
			n = n+1;
		end
	end

	for i=1,MAX_SHORTCUT do
		local grid_index = i + ClientBackpack:getShortcutStartIndex() - 1;
		local itemid = ClientBackpack:getGridItem(grid_index);
		if itemid > 0 then
			BF_UpdateLeftBoxOneItem(grid_index, n,true);
			n = n+1;
		end
	end

	for i=1,BACK_PACK_GRID_MAX do --设置空的背包格子索引
		local grid_index = i + BACKPACK_START_INDEX - 1;
		local itemid = ClientBackpack:getGridItem(grid_index);
		print("kekeke BF_UpdateLeftBoxAllItem", itemid);
		if itemid == 0 then
			BF_UpdateLeftBoxOneItem(grid_index, n,false);
			n = n+1;
		end
	end

	for i=1,MAX_SHORTCUT do  -- 设置空的快捷栏格子索引
		local grid_index = i + ClientBackpack:getShortcutStartIndex() - 1;
		local itemid = ClientBackpack:getGridItem(grid_index);
		if itemid == 0 then
			BF_UpdateLeftBoxOneItem(grid_index, n,false);
			n = n+1;
		end
	end


	for i=n, BLUEPRINT_LELF_GRID_MAX do
		BF_UpdateLeftBoxOneItem(-1, i);
	end
end

function BF_UpdateLeftBoxOneItem(grid_index, n,isHas)
	local icon =	 getglobal("BluePrintLeftBoxItem"..n.."Icon");
	local num =		 getglobal("BluePrintLeftBoxItem"..n.."Count");
	local durbkg =	 getglobal("BluePrintLeftBoxItem"..n.."DurBkg");
	local durbar =	 getglobal("BluePrintLeftBoxItem"..n.."Duration");
	local fumo =	 getglobal("BluePrintLeftBoxItem"..n.."IconFumoEffect1");

	local item = getglobal("BluePrintLeftBoxItem"..n);
	item:SetClientID(grid_index+1);

	if grid_index >= 0 and isHas then
		UpdateGridContent(icon, num, durbkg, durbar, grid_index);
	else
		icon:SetTextureHuires(ClientMgr:getNullItemIcon());
		num:SetText("");
		durbar:Hide();
		durbkg:Hide();
		fumo:Hide();
	end
end

local l_stuffNum = 0; --记录上次打开蓝图图纸需要的材料个数，用来判断有物品栏是否有未清空，同时也避免遍历1000个格子消耗性能

function BF_UpdateRightBoxAllItem()
	-- local num  = BF_Data.getAllStuffNum();

	-- if l_stuffNum > num then 
	-- 	for i =1 ,l_stuffNum do 
	-- 		BF_UpdateRightBoxOneItem(BUILDBLUEPRINT_START_INDEX+i-1);
	-- 	end
	-- else
	-- 	for i =1 ,num do 
	-- 		BF_UpdateRightBoxOneItem(BUILDBLUEPRINT_START_INDEX+i-1);
	-- 	end
	-- end

	-- l_stuffNum = num;

	local min_create_num = 18
	local lastloadnum = math.max(l_stuffNum, min_create_num)
    l_stuffNum = BF_Data.getAllStuffNum()
    if l_stuffNum == 0 then
    	getglobal("BluePrintRightBoxPlane"):SetHeight(getglobal("BluePrintRightBox"):GetHeight())
    end
    
    local listviewCallBack = function(idx, name)
        local listitem = getglobal(name)
        if idx > l_stuffNum and idx > min_create_num then
            listitem:Hide()
            return
        end

        local w, h, offsetx, offsety = 5, 5, 0, 0
        local loadnum = idx-1
        local itemwidth, itemheight = listitem:GetWidth(), listitem:GetHeight()

        listitem:SetPoint("topleft", "BluePrintRightBoxPlane", "topleft", offsetx+(loadnum%6)*(itemwidth+w), offsety+math.floor(loadnum/6)*(itemheight+h))
		listitem:Show()
		local check 	= getglobal(name.."Check");
		check:SetTextureHuiresXml("ui/mobile/texture2/ingame2.xml");
		check:SetTexUV("tz_all_h");
		check:SetDrawType(0);

        BF_UpdateRightBoxOneItem(BUILDBLUEPRINT_START_INDEX+loadnum)

        if idx == l_stuffNum then
            local listFrame = getglobal("BluePrintRightBox")
            local listPanel = getglobal("BluePrintRightBoxPlane")
            local height = offsety+math.ceil(l_stuffNum/6)*(itemheight+h)
            if height < listFrame:GetHeight() then height = listFrame:GetHeight() end
            listPanel:SetHeight(height)
        end
    end

    lastloadnum = math.max(l_stuffNum, lastloadnum)
    local onceload, functab = 3, {}
    if lastloadnum >= 50 then
        onceload = 12
    elseif lastloadnum >= 20 then
        onceload = 6
    end

    local tmp = "GridButtonTemplate2"
    if ClientMgr and ClientMgr:isMobile() then
    	tmp = "CraftingTableGridBtnTemplate"
	end
	for i=1,lastloadnum do
        table.insert(functab, {name="BluePrintRightBoxStuffItem" .. i, tmpname=tmp, 
                parentname="BluePrintRightBox", clientid=27000+i, idx=i, func=listviewCallBack})
        if i%onceload == 0 or i == lastloadnum then
            listviewMgr:createListItemsAsync(functab)
            functab = {}
        end
    end
end

function BF_InitItemToContainer()
	local num = BF_Data.getAllStuffNum();
	if num<1 then return end

	local grid_index;
	for i =1, num do 
		grid_index = BUILDBLUEPRINT_START_INDEX+i -1;
		local gridInfo = BF_Data.getOriginalGridInfo(i);
		if gridInfo ~= nil then
			local grid = CurMainPlayer:getBackPack():index2Grid(grid_index);
			if grid~= nil and grid:getNum()<1 then
				CurMainPlayer:setItem(gridInfo.itemId,0, gridInfo.durable);
				for i=1, gridInfo.enchantnum do
					CurMainPlayer:getBackPack():enchant(grid_index, gridInfo.enchants[i]);
				end
			end
		end
	end
end

function BF_UpdateRightBoxOneItem(grid_index)
	local n = grid_index - BUILDBLUEPRINT_START_INDEX + 1;

	if n > 0 then 
		local icon 		= getglobal("BluePrintRightBoxStuffItem"..n.."Icon");
		local num 		= getglobal("BluePrintRightBoxStuffItem"..n.."Count");
		local durbkg 	= getglobal("BluePrintRightBoxStuffItem"..n.."DurBkg");
		local durbar 	= getglobal("BluePrintRightBoxStuffItem"..n.."Duration");
		local check 	= getglobal("BluePrintRightBoxStuffItem"..n.."Check");
		check:Hide();
		num:Show()
		local allNum = ClientBackpack:getGridUserdata(grid_index)
		local itemId = ClientBackpack:getGridItem(grid_index)
		local hasNum = 0;
		--TODO
		if IsInHomeLandMap and IsInHomeLandMap() then
			--家园模式下hasNum为家园编辑背包拥有的道具数量
			hasNum = getStuffRealNumByHomeLandBackpack(itemId, allNum);
		else
			hasNum = ClientBackpack:getGridNum(grid_index);
		end
		if hasNum==nil or hasNum<1 then
			hasNum = 0;
		end
		UpdateGridContent(icon, num, durbkg, durbar, grid_index);
		if itemId > 0 then
			--TODO 家园蓝图显示
			if IsInHomeLandMap and IsInHomeLandMap() then
				if BF_Data.homefree[itemId] == 1 then
					num:Hide() ---家园蓝图不免费显示个数
				else
					if hasNum >= allNum then
						num:SetText("#cFFFFFF" .. tostring(hasNum) .. "#n/#cFFFFFF" .. tostring(allNum))
					else
						num:SetText("#cff3d2b" .. tostring(hasNum) .. "#n/#cFFFFFF" .. tostring(allNum))
					end
				end
				check:Hide() --家园蓝图不显示
			else
				local gridContent = hasNum.."/"..allNum;
				if allNum and hasNum >= allNum then 
					--check:SetTextureHuiresXml("ui/mobile/texture2/ingame2.xml");
					--check:SetTexUV("tz_all_h");
					check:Show();
				end
				num:SetText("#cFFFFFF"..gridContent);
			end
		end
	end
end

function BF_ShowInformaiton()

	local BF_Name = 	getglobal("BluePrintDrawingFrameTitle");
	local BF_Author =	getglobal("BluePrintDrawingFrameAuthor");
	local BF_Range = 	getglobal("BluePrintDrawingFrameRange");
	local BF_Describe = getglobal("BluePrintDrawingFrameDescribe");
	local BF_DescribeTitle = getglobal("BluePrintDrawingFrameDescribeTitle");

	BF_Name:SetText(BF_Data.getBlueprintName());
	BF_Author:SetText(GetS(352).."："..BF_Data.getAuthorName());
	BF_Describe:Hide();
	BF_DescribeTitle:Hide();
	BF_Describe:SetText(BF_Data.getDescribe());
	BF_Range:SetText(GetS(9306).."："..BF_Data.getRange());
end

function BF_ShowStuffNum()
	local BF_AllNum = getglobal("BluePrintDrawingFrameNum");
	local content;

	if BF_Data.getAllStuffNum()> 0 then
		content = BF_Data.getEnoughNum().."/"..BF_Data.getAllStuffNum();
	else	
		content = "";
	end
	BF_AllNum:SetText(content);
end

function BF_ShowRightGridState()
	local num  = BF_Data.getAllStuffNum();
	local height=0;

	if num <= 18 or num ==0 or num ==nil then
		for i=1, BLURPRINTBOX_GRID_MAX do
			local itembtn = getglobal("BluePrintRightBoxStuffItem"..i);
			if i<=18 then
				itembtn:Show();
				itembtn:Enable();
				if i>num then 
					--itembtn:Disable();
				end
			else	
				itembtn:Hide();
			end
		end
		height = 3*(81 +2);
	else	
		local rows = math.ceil(num/6);
		local showNum = 6 *rows;

		for i=1, BLURPRINTBOX_GRID_MAX do
			local itembtn = getglobal("BluePrintRightBoxStuffItem"..i);
			if i<=showNum then
				itembtn:Show();
				itembtn:Enable();
				if i>num then 
					itembtn:Disable();
				end
			else	
				itembtn:Hide();
			end
		end
		height = rows*(81 +2);
	end

	getglobal("BluePrintRightBoxPlane"):SetHeight(height);
end

function BF_ShowGridContent( iconbtn, numtext, durbkg, dur, itemid )
	local enChantTexture1 = nil;
	local enChantTexture2 = nil;

	if HasUIFrame(iconbtn:GetName().."FumoEffect1") then
		enChantTexture1 = getglobal(iconbtn:GetName().."FumoEffect1");
	end
	if HasUIFrame(iconbtn:GetName().."FumoEffect2") then
		enChantTexture2 = getglobal(iconbtn:GetName().."FumoEffect2");
	end

	if itemid == 0 then
		iconbtn:SetTextureHuires(ClientMgr:getNullItemIcon());
		numtext:SetText("");
		durbkg:Hide();
		dur:Hide();
		if enChantTexture1 then
			enChantTexture1:Hide();	
		end
		if enChantTexture2 then
			enChantTexture2:Hide();	
		end
		return;
	end

    SetItemIcon(iconbtn, itemid);

end

function BF_LimitPutinNum(grid_index,num)
	if  grid_index<BUILDBLUEPRINT_START_INDEX+1000 and grid_index>=BUILDBLUEPRINT_START_INDEX then

		if ClientMgr:isPC() and IS_SHIFT_MOVE~=true then
			local canPut = BF_CanPutinGrid(grid_index);
			if  not canPut then return -1 end;
		end

		--[[
		local n = grid_index - BUILDBLUEPRINT_START_INDEX + 1;
		local gridInfo = BF_Data.getOriginalGridInfo(n);
		local allNum = gridInfo.itemNum;

		local grid = BF_Data.getContainerGrid(grid_index);
		local holdNum = grid:getNum();

		if allNum ==nil or allNum<=0 then return -1 end

		local needNum = allNum - holdNum;
		if needNum < 0 then return -1 end

		if needNum<num then
			return needNum;

		elseif needNum >=num then
			return num;
		end
		]]

		--TODO kekeke new logic
		local allNum = ClientBackpack:getGridUserdata(grid_index);
		if allNum < 0 then return -1 end

		local hasNum = ClientBackpack:getGridNum(grid_index);
		local needNum = allNum - hasNum;
		if needNum < 0 then return -1 end

		if needNum<num then
			return needNum;

		elseif needNum >=num then
			return num;
		end
	else 
		return num;
	end
end

function BF_CanPutinGrid(grid_index, src_index)
	--[[
	if grid_index >=BUILDBLUEPRINT_START_INDEX+1000 and grid_index<BUILDBLUEPRINT_START_INDEX then
		return false;
	end

	if not src_index then
		src_index = MOUSE_PICKITEM_INDEX;
	end

	local fromGrid = BF_Data.getContainerGrid(src_index);
	if fromGrid == nil then
		return false;
	end

	if not CurMainPlayer then
		return false;
	end

	local n = grid_index - BUILDBLUEPRINT_START_INDEX + 1;
	local gridInfo = BF_Data.getOriginalGridInfo(n);
	if gridInfo == nil then
		return false;
	end

	print("kekeke BF_CanPutinGrid from id ", grid_index, gridInfo.itemId, src_index, fromGrid:getItemID());
	if fromGrid:getItemID() ~= gridInfo.itemId then
		return false;
	end

	print("kekeke BF_CanPutinGrid durable ", gridInfo.durable, CurMainPlayer:getBackPack():getGridDuration(src_index));
	if gridInfo.durable >= 0 and gridInfo.durable ~= CurMainPlayer:getBackPack():getGridDuration(src_index) then  --有耐久度且耐久度不一致
		return false;
	end

	print("kekeke BF_CanPutinGrid enchantnum ", gridInfo.enchantnum);
	if gridInfo.enchantnum > 0 then    --材料需求有附魔
		local isSameEnchants = true;
		for i=1, #(gridInfo.enchants) do
			local id = gridInfo.enchants[i];
			local hasEnchant = false;
			for j=1, CurMainPlayer:getBackPack():getGridEnchantNum(src_index) do
				if id == CurMainPlayer:getBackPack():getGridEnchantId(src_index, j-1) then  --有这条附魔
					hasEnchant = true;
					break;
				end
			end

			if not hasEnchant then
				isSameEnchants = false;
				break;
			end
		end

		if not isSameEnchants then  --没有一摸一样的附魔
			return false;
		end
	elseif CurMainPlayer:getBackPack():getGridEnchantNum(src_index) > 0 then --材料需求无附魔 鼠标格子的道具有附魔 也放不进去
		return false;
	end

	return true;
	]]

	--TODO kekeke new logic
	if grid_index >=BUILDBLUEPRINT_START_INDEX+1000 and grid_index<BUILDBLUEPRINT_START_INDEX then
		return false;
	end

	if not src_index then
		src_index = MOUSE_PICKITEM_INDEX;
	end

	local fromGrid = BF_Data.getContainerGrid(src_index);
	if fromGrid == nil then
		return false;
	end

	if not CurMainPlayer then
		return false;
	end

	local destGrid = ClientBackpack:index2Grid(grid_index);
	if not destGrid or destGrid:getItemID() <= 0 then
		return false;
	end

	if fromGrid:getItemID() ~= destGrid:getItemID() then
		return false;
	end

	--[[
	print("kekeke BF_CanPutinGrid durable ", ClientBackpack:getGridDuration(grid_index), ClientBackpack:getGridDuration(src_index));
	if ClientBackpack:getGridDuration(grid_index) >= 0 and ClientBackpack:getGridDuration(grid_index) ~= ClientBackpack:getGridDuration(src_index) then  --有耐久度且耐久度不一致
		return false;
	end

	print("kekeke BF_CanPutinGrid enchantnum ", ClientBackpack:getGridDuration(grid_index));

	local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
	if enchantNum > 0 then    --材料需求有附魔
		local isSameEnchants = true;
		for i=1, enchantNum do
			local id = ClientBackpack:getGridEnchantId(grid_index, i-1);
			local hasEnchant = false;
			for j=1, CurMainPlayer:getBackPack():getGridEnchantNum(src_index) do
				if id == CurMainPlayer:getBackPack():getGridEnchantId(src_index, j-1) then  --有这条附魔
					hasEnchant = true;
					break;
				end
			end

			if not hasEnchant then
				isSameEnchants = false;
				break;
			end
		end

		if not isSameEnchants then  --没有一摸一样的附魔
			return false;
		end
	elseif CurMainPlayer:getBackPack():getGridEnchantNum(src_index) > 0 then --材料需求无附魔 鼠标格子的道具有附魔 也放不进去
		print("kekeke BF_CanPutinGrid enchantnum false");
		return false;
	end
	]]

	return true;
end

function BF_PutinGridMobile(grid_index, num)
	local grid =BF_Data.getContainerGrid(grid_index);
	if grid== nil then return end

	local itemId = grid:getItemID();
	if itemId<=0 then return end

	local index = BF_Data.getIndexBySrcIndex(grid_index); -- 获取蓝图容器中的索引
	if index==nil or index <=0 then
		Log("the buleprint grid_index obtained is fail :BF_PutinGridMobile()");
		return
	end
	
	local permitNum = BF_LimitPutinNum(index,num);
	CurMainPlayer:moveItem(grid_index, index, permitNum);

end

function  BF_ShiftMoveItem(grid_index)
	local grid = BF_Data.getContainerGrid(grid_index);
	if grid== nil then return end


	local itemid = grid:getItemID();
	local num = grid:getNum();

	if itemid <1 then 
		Log("Then itemId obtained is fail : BF_ShiftMoveItem()"); 
		return 
	end

	local index = BF_Data.getIndexBySrcIndex(grid_index);
	if index ==nil then return end;


	IS_SHIFT_MOVE = true;
	num = BF_LimitPutinNum(index , num);
	IS_SHIFT_MOVE = false;

	if num == -1 then
		Log("the num calculated is fail:BF_ShiftMoveItem() ");
		return;
	end

	CurMainPlayer:moveItem(grid_index, index , num);
end

function  BF_SetDrawingBtnClickSign(isClick)
	if ISDrawingBtnClick == isClick then return end
	ISDrawingBtnClick = isClick;
end

function BF_GetDrawingBtnClickSign()
	return ISDrawingBtnClick;
end

function BF_ClearAllGridContent()
	-- body
end
----------------------------------------------------------------------------------------------------
function BF_PutAllStuff()
	local allNum=0;
	local holdNum =0;
	local needNum = 0;

	if BF_Data.getAllStuffNum() <=0 then 
		Log("There is no stuff to be put in :BF_PutAllStuff()");
		return 
	end

	if not CurMainPlayer then
		print("BF_PutAllStuff111")
		return
	end

	-- 获取需要的总数
	for i =1 ,BF_Data.getAllStuffNum() do 
		local grid_index = BUILDBLUEPRINT_START_INDEX +i ;
		--allNum= BF_Data.getGridNeedNum(grid_index -1);
		--allNum = BF_Data.allNeedStuffTable[i].itemNum;

		---if allNum ==nil or allNum<=0 then
			--Log("The num of this stuff is abnormal :BF_PutAllStuff(),grid_index:"..grid_index);

		--else	
			-- 容器中已经有的数字
			local grid = BF_Data.getContainerGrid(grid_index-1);
			if grid~= nil then
				holdNum = grid:getNum();
				if holdNum ==nil then 
					Log("the hold num of stuff abtained is abnormal :BF_PutAllStuff(),grid_index:"..grid_index );
				end
				allNum = ClientBackpack:getGridUserdata(grid_index-1);
				if allNum < 0 then
					print("BF_PutAllStuff allNum", allNum)
					return
				end
			end

			print("BF_PutAllStuff 11111", allNum, holdNum)
			-- 计算还剩的数字
			needNum = allNum - holdNum;
			if needNum> 0 then -- 从背包中获取该物品
				for i =1 ,BACK_PACK_GRID_MAX do 
					local srcIndex = BACKPACK_START_INDEX+i-1;
					if needNum > 0 and BF_CanPutinGrid(grid_index-1, srcIndex) then
						print("BF_PutAllStuff2",  i)
						local hasNum = CurMainPlayer:getBackPack():getGridNum(srcIndex);
						local putNum = hasNum < needNum and hasNum or needNum;

						CurMainPlayer:moveItem(srcIndex, grid_index-1, putNum);
						needNum = needNum - putNum;
					end 
				end
			end

			if needNum > 0 then
				for i = 1,MAX_SHORTCUT do 
					local srcIndex = ClientBackpack:getShortcutStartIndex()+i-1;
					if needNum > 0 and BF_CanPutinGrid(grid_index-1, srcIndex) then
						print("BF_PutAllStuff3",  i)
						local hasNum = CurMainPlayer:getBackPack():getGridNum(srcIndex);
						local putNum = hasNum < needNum and hasNum or needNum;

						CurMainPlayer:moveItem(srcIndex, grid_index-1, putNum);
						needNum = needNum - putNum;
					end 
				end
			end
				--[[
				--查找需要的物品格子，并获取grid_index
				local bp_index=0;
				local sc_index=0;
				local bp_num = 0;
				local sc_num = 0;
				local tmp_grid=nil;
				local tmp_index = 0;

				for i =1 ,BACK_PACK_GRID_MAX do 
					tmp_index= BACKPACK_START_INDEX+i-1;
					tmp_grid=BF_Data.getContainerGrid(tmp_index);

					if tmp_grid ~= nil then 
						if BF_CanPutinGrid(grid_index-1, tmp_index) then
							bp_num= tmp_grid:getNum();
							bp_index=tmp_index;
						end
					end
				end

				for i = 1,MAX_SHORTCUT do 
					tmp_index= ClientBackpack:getShortcutStartIndex() +i -1;
					tmp_grid=BF_Data.getContainerGrid(tmp_index);

					if tmp_grid~=nil then
						if BF_CanPutinGrid(grid_index-1, tmp_index) then
							sc_num = tmp_grid:getNum();
							sc_index = tmp_index;
							local id = CurMainPlayer:getBackPack():getGridItem(grid_index-1);
							print("kekeke BF_PutAllStuff", grid_index, sc_index, id);
						end
					end
				end

				--获取交换的数量
				if bp_num>0 and needNum>0 then
					if needNum<=bp_num then
						bp_num = needNum;
						sc_num = 0;
					else
						needNum = needNum - bp_num;
					end
				elseif sc_num>0 then
					if needNum<=sc_num then
						sc_num=needNum;
					end
				end

				--执行交换逻辑
				if bp_num>0 and bp_index>=BACKPACK_START_INDEX then
					CurMainPlayer:moveItem(bp_index,grid_index-1,bp_num);
				end

				if sc_num>0 and sc_index>=ClientBackpack:getShortcutStartIndex() then
					CurMainPlayer:moveItem(sc_index,grid_index-1 ,sc_num);
				end
				]]
		--end
	end
end

