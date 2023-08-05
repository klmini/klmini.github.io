

local m_FURNACE_GRID_MAX = 30;

--刷新材料格子: 导入空白卷轴到格子
function Blueprint_UpdateMaterial()
	Log("Blueprint_UpdateMaterial:");
	local t_furnaceStuff = {};
	local t_furnaceFuel = {};
	local resBlockId = 11806--11805;

	for i=1, BACK_PACK_GRID_MAX do
		local grid_index = BACKPACK_START_INDEX + i - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		local itemdef = ItemDefCsv:get(itemId);
		if itemId == resBlockId and itemdef then
			table.insert(t_furnaceStuff, grid_index);
		end
	end

	local maxCount = ClientBackpack:getShortcutGridCount()
	for i=1, maxCount do
		local grid_index = ClientBackpack:getShortcutStartIndex() + i - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		local itemdef = ItemDefCsv:get(itemId);
		if itemId == resBlockId and itemdef then
			table.insert(t_furnaceStuff, grid_index);
		end
	end

	for i=1, FURNACE_GRID_MAX do
		local stuffItem 	= getglobal("BlueprintFrameTopBoxItem"..i);
		local stuffItemIcon 	= getglobal("BlueprintFrameTopBoxItem"..i.."Icon");
		local stuffItemNum 	= getglobal("BlueprintFrameTopBoxItem"..i.."Count");
		local stuffItemDurbkg 	= getglobal("BlueprintFrameTopBoxItem"..i.."DurBkg");
		local stuffItemDurbar 	= getglobal("BlueprintFrameTopBoxItem"..i.."Duration");
		if i <= #(t_furnaceStuff) then
			stuffItem:SetClientID(t_furnaceStuff[i]+1);
			UpdateGridContent(stuffItemIcon, stuffItemNum, stuffItemDurbkg, stuffItemDurbar, t_furnaceStuff[i]);
		else
			stuffItem:SetClientID(0);
			stuffItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
			stuffItemNum:SetText("");
			stuffItemDurbar:Hide();
			stuffItemDurbkg:Hide();
		end
	end
end

--刷新原料和生成物格子
function Blueprint_UpdateResult(grid_index)
	Log("Blueprint_UpdateResult:");
	for i=1, 2 do
		local furnaceItem = getglobal("BlueprintFrameBottomSheetItem"..i);
		local icon 	= getglobal(furnaceItem:GetName() .. "Icon");
		local num	= getglobal(furnaceItem:GetName() .. "Count");
		local durbkg	= getglobal(furnaceItem:GetName() .. "DurBkg");
		local durbar	= getglobal(furnaceItem:GetName() .. "Duration");
		local lack	= getglobal(furnaceItem:GetName() .. "Lack");


		if grid_index and furnaceItem:GetClientID()-1 == grid_index then			
			UpdateGridContent(icon, num, durbkg, durbar, grid_index);
		else
			UpdateGridContent(icon, num, durbkg, durbar, BLUEPRINT_START_INDEX+i-1);
		end
	end
end

function BlueprintFrame_OnLoad()
	this:RegisterEvent("GE_BACKPACK_ATTRIB_CHANGE");
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	this:RegisterEvent("GE_BACKPACK_CHANGE_EDIT");
	BlueprintFrame_AddGame()
	for i = 1,m_FURNACE_GRID_MAX / 6 do
		for j=1,6 do
			local itembtn = getglobal("BlueprintFrameTopBoxItem" .. ((i - 1) * 6 + j));
			itembtn:SetPoint("topleft", "BlueprintFrameTopBoxPlane", "topleft", (j - 1) * 85, (i - 1) * 83);
		end
	end
end

function BlueprintFrame_AddGame()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		if not getglobal("BlueprintFrame"):IsShown() then
			return
		end
		local paramData = context:GetParamData()
		local grid_index = paramData.gridIndex
		if grid_index and grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX + 1008 then
			Blueprint_UpdateMaterial();
		elseif grid_index and grid_index >= BLUEPRINT_START_INDEX and grid_index < BLUEPRINT_START_INDEX + 2 then
			Blueprint_UpdateResult(grid_index);
			Blueprint_EnableMakeBtn();
		end
	end)

	SubscribeGameEvent(nil,GameEventType.BackPackAttribChange,function(context)
		getglobal("BlueprintFrameBottomArrowProgressBar"):SetValue(OpenContainer:getAttrib(0));
	end)
end

function BlueprintFrame_OnShow()
	HideAllFrame("BlueprintFrame", true);

	if not getglobal("BlueprintFrame"):IsReshow() then
	    ClientCurGame:setOperateUI(true);
	end

	Blueprint_UpdateMaterial();
	Blueprint_UpdateResult();
	Blueprint_EnableMakeBtn();
end

function BlueprintFrame_OnHide()
	ShowMainFrame();

	if not getglobal("BlueprintFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
		CurMainPlayer:closeContainer();
	end

	UIFrameMgr:setCurEditBox(nil);
end

function BlueprintFrame_OnEvent()
	if arg1 == "GE_BACKPACK_ATTRIB_CHANGE" then
		getglobal("BlueprintFrameBottomArrowProgressBar"):SetValue(OpenContainer:getAttrib(0));
	end

	if arg1 == "GE_BACKPACK_CHANGE" then
		local ge = GameEventQue:getCurEvent();
		local grid_index = ge.body.backpack.grid_index;

		Log("BlueprintFrame_OnEvent: grid_index = " .. grid_index);
		if not getglobal("BlueprintFrame"):IsShown() then
			return
		end
		
		if grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX + 1008 then
			Blueprint_UpdateMaterial();
		elseif grid_index >= BLUEPRINT_START_INDEX and grid_index < BLUEPRINT_START_INDEX + 2 then
			Blueprint_UpdateResult(grid_index);
			Blueprint_EnableMakeBtn();
		end
	elseif arg1 == "GE_BACKPACK_CHANGE_EDIT" then
		local ge = GameEventQue:getCurEvent();
		local grid_index = ge.body.backpack.grid_index;

		Log("BlueprintFrame_OnEvent: grid_index = " .. grid_index);
		if not getglobal("BlueprintFrame"):IsShown() then
			return
		end
		
		Blueprint_UpdateMaterial();
	end
end

function BlueprintFrameCloseBtn_OnClick()
	getglobal("BlueprintFrame"):Hide();
end

--名字编辑框
function BlueprintFrameBottomSheetNameEdit_OnFocusGained()

end

function BlueprintFrameBottomSheetNameEdit_OnFocusLost()
	Log("BlueprintFrameBottomSheetNameEdit_OnFocusLost:");
	Blueprint_EnableMakeBtn();
end

function BlueprintFrameBottomSheetNameEdit_OnFinishChar()
	Log("BlueprintFrameBottomSheetNameEdit_OnFinishChar:");
	Blueprint_EnableMakeBtn();
end

--制作按钮
function BlueprintFrameMakeBtn_OnClick()
	Log("BlueprintFrameMakeBtn_OnClick:");

	local sheetName = getglobal("BlueprintFrameBottomSheetNameEdit"):GetText();

	Log("sheetName = " .. sheetName);

	if CheckFilterString(sheetName) then	--敏感词
		ShowGameTips(GetS(121), 3);
		return;
	end

	if sheetName and string.len(sheetName) > 0 then
		Log("111:");
		if OpenContainer then
			Log("OK:");
			OpenContainer:StartWorking(sheetName, AccountManager:getNickName());
		else
			Log("Error:");
		end
	else
		ShowGameTips(GetS(9233), 3);
	end
end

--制作按钮置灰
function Blueprint_EnableMakeBtn()
	Log("Blueprint_EnableMakeBtn:");

	local itemid1 = ClientBackpack:getGridItem(BLUEPRINT_START_INDEX);
	local itemid2 = ClientBackpack:getGridItem(BLUEPRINT_START_INDEX + 1);
	local sheetName = getglobal("BlueprintFrameBottomSheetNameEdit"):GetText();

	local normal = getglobal("BlueprintFrameMakeBtnNormal");
	local pushed = getglobal("BlueprintFrameMakeBtnPushedBG");
	local btn = getglobal("BlueprintFrameMakeBtn");
    local title = getglobal("BlueprintFrameMakeBtnTitle");

	Log("itemid1 = " .. itemid1);
	Log("itemid2 = " .. itemid2);
	Log("sheetName = " .. sheetName);

	if 0 ~= itemid1 and 0 == itemid2 and sheetName and string.len(sheetName) > 0 then
		Log("111:");
		normal:SetGray(false);
		pushed:SetGray(false);
        btn:Enable();
        title:SetTextColor(55,54,51)
	else
		Log("222:");
		normal:SetGray(true);
		pushed:SetGray(true);
        btn:Disable();
        title:SetTextColor(55, 54, 50)
	end
end

--取出原料和生成物
function BlueprintItemOnClick(grid_index)
	Log("BlueprintItemOnClick:");
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

--解析字符串
function BlueprintStringParse(str)
	Log("BlueprintStringParse:");
	Log("str = " .. str);
    local LettersUin = 0
    local LettersAuthor = ""
    local LettersTitle = ""
    local LettersContext = ""
    local filename = "";
    local dimX = 0;
   	local dimY = 0;
   	local dimZ = 0;

   	local t = JSON:decode(str);
   	if t and type(t) == "table" then
   		print("kekeke BlueprintStringParse:", t);
   		if t.uin and tonumber(t.uin) then
   			LettersUin = tonumber(t.uin);
   		end

   		if t.authorname then
   			LettersAuthor = t.authorname;
   		end

   		if t.sheetname then
   			LettersTitle = t.sheetname;
   		end

   		if t.nickname then
   			LettersContext = t.nickname;
   		end

   		if t.filename then
   			filename = t.filename;
   		end

   		if t.dimx and tonumber(t.dimx) then
   			dimX = tonumber(t.dimx);
   		end

   		if t.dimy and tonumber(t.dimy) then
   			dimY = tonumber(t.dimy);
   		end

   		if t.dimz and tonumber(t.dimz) then
   			dimZ = tonumber(t.dimz);
   		end
    else
	    while (str ~= nil and string.len(str) > 0) do
	    	--1. uin
	        local pos_beg = 1
	        local pos_end = string.find(str, "|")
	        if pos_end == nil then
	            break
	        end
	        LettersUin = tonumber(string.sub(str, pos_beg, pos_end-1), 10)

	        --2. 作者
	        pos_beg = pos_end+1
	        pos_end = string.find(str, "|", pos_beg)
	        if pos_end == nil then
	            break
	        end
	        LettersAuthor = string.sub(str, pos_beg, pos_end-1)

	        --3. 名字
	        pos_beg = pos_end+1
	        pos_end = string.find(str, "|", pos_beg)
	        if pos_end == nil then
	            break
	        end
	        LettersTitle = string.sub(str, pos_beg, pos_end-1)
	        
	        --4. 作者
	        pos_beg = pos_end+1
	        pos_end = string.find(str, "|", pos_beg)
	        if pos_end == nil then
	            break
	        end
	        LettersContext = string.sub(str, pos_beg, pos_end - 1);

	        --5. 文件名
	        pos_beg = pos_end+1
	        pos_end = string.find(str, "|", pos_beg)
	        if pos_end == nil then
	            break
	        end
	        filename = string.sub(str, pos_beg, pos_end - 1);

	        --6. 范围
	        pos_beg = pos_end+1
	        pos_end = string.find(str, "|", pos_beg)
	        if pos_end == nil then
	            break
	        end
	        dimX = string.sub(str, pos_beg, pos_end - 1);

	        --7. 范围
	        pos_beg = pos_end+1
	        pos_end = string.find(str, "|", pos_beg)
	        if pos_end == nil then
	            break
	        end
	        dimY = string.sub(str, pos_beg, pos_end - 1);

	        --8. 范围
	        pos_beg = pos_end+1
	        dimZ = string.sub(str, pos_beg);
	        break;
	    end
	end

    return LettersUin, LettersAuthor, LettersTitle, LettersContext, filename, dimX, dimY, dimZ;
end
