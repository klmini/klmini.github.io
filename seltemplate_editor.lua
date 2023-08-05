
local EdtiorTPLBtn_Max = 300
local SelTPLEditorType;
local IsSelOriginal;
local CurSelTPLBtnName = nil;
local t_EdtiorSelfTPL = {};
local CurSelTPLEditDef = nil;

--道具模板数据
local CurSelItemTemplateIndex = nil
local t_ItemTemplate = {
    {	--杂物
        ItemId = 10100,
        TipStringId = 4480,
        Icon = "icon_form_mess.png",
    },
    {	--工具
        ItemId = 10101,
        TipStringId = 4481,
        Icon = "icon_form_tool.png",
    },
    {	--弓
        ItemId = 10102,
        TipStringId = 4485,
        Icon = "icon_form_bow.png",
    },
    {	--弹药、投掷物
        ItemId = 10103,
        TipStringId = 4486,
        Icon = "icon_form_missile.png",
    },
    {	--枪械
        ItemId = 10104,
        TipStringId = 4488,
        Icon = "icon_form_gun.png",
    },
    {	--食物
        ItemId = 10110,
        TipStringId = 4489,
        Icon = "icon_form_food.png",
	},	--背包
	{
        ItemId = 10111,
        TipStringId = 21754,
        Icon = "icon_form_package.png",
    },

};

function EdtiorTPLBtnTemplate_OnClick()
	if CurSelTPLBtnName then
		getglobal(CurSelTPLBtnName.."Checked"):Hide();
	end

	CurSelTPLBtnName = this:GetName();
	getglobal(CurSelTPLBtnName.."Checked"):Show();
	CurSelTPLEditDef = nil;
	local index = this:GetClientID();
	
	if t_EdtiorSelfTPL[index] then
		CurSelTPLEditDef = t_EdtiorSelfTPL[index];
		
		-- 如果是Block，使用item的Name
		if SelTPLEditorType == 'block' then
			local itemDef
			
			if CurSelTPLEditDef.CopyID > 0 then
				itemDef = ModEditorMgr:getBlockItemDefById(CurSelTPLEditDef.ID);
			else
				itemDef = ModEditorMgr:getItemDefById(CurSelTPLEditDef.ID);
				if itemDef == nil then
					itemDef = ItemDefCsv:get(CurSelTPLEditDef.ID);
				end
			end
			UpdateTipsFrame(itemDef.Name,0);
		elseif SelTPLEditorType == 'craft' then
			local itemDef = ModEditorMgr:getBlockItemDefById(CurSelTPLEditDef.ResultID);
			if itemDef == nil then
				itemDef = ModEditorMgr:getItemDefById(CurSelTPLEditDef.ResultID);
				if itemDef == nil then
					itemDef = ItemDefCsv:get(CurSelTPLEditDef.ResultID);
				end
			end
			UpdateTipsFrame(itemDef.Name,0);
		elseif SelTPLEditorType == 'furnace' then
			local itemDef = ModEditorMgr:getBlockItemDefById(CurSelTPLEditDef.MaterialID);
			if itemDef == nil then
				itemDef = ModEditorMgr:getItemDefById(CurSelTPLEditDef.MaterialID);
				if itemDef == nil then
					itemDef = ItemDefCsv:get(CurSelTPLEditDef.MaterialID);
				end
			end
			UpdateTipsFrame(itemDef.Name,0);
		elseif SelTPLEditorType == 'plot' then
			--LLTODO:模板一个模板界面, 格子点击
			--local itemDef = ModEditorMgr:getBlockItemDefById(CurSelTPLEditDef.MaterialID);
			--if itemDef == nil then
				--itemDef = ModEditorMgr:getItemDefById(CurSelTPLEditDef.MaterialID);
				if itemDef == nil then
					itemDef = DefMgr:getNpcPlotDef(CurSelTPLEditDef.ID);
				end
			--end
			UpdateTipsFrame(ConvertDialogueStr(CurSelTPLEditDef.Name),0);
		else
			UpdateTipsFrame(CurSelTPLEditDef.Name,0);
		end
	end
end

--selectTemplate:选择现有XX模板按钮
function EditorSelfTPLBtn_OnClick()
	--[[
	local type = getglobal("SelTemplateEditorFrame"):GetClientString();	--编辑类型
	local args = {
			editType = type,
			isOriginal = true,
		};
	FrameStack.enterNewFrame("SelTemplateEditorFrame", args);
	]]
	SetSelTemplateEditorInfo(SelTPLEditorType, true);
end

function EditorSelNewBtn_OnClick()
	--默认
	if SelTPLEditorType == 'block' then
		CurSelTPLEditDef = BlockDefCsv:get(4094, false);
	elseif SelTPLEditorType == 'actor' then
		CurSelTPLEditDef = MonsterCsv:get(4000);
	elseif SelTPLEditorType == 'craft' then
		CurSelTPLEditDef = DefMgr:getCraftingDef(1000);
	elseif SelTPLEditorType == 'furnace' then
		CurSelTPLEditDef = DefMgr:getFurnaceDef(100);
	elseif SelTPLEditorType == 'plot' then
		CurSelTPLEditDef = DefMgr:getNpcPlotDef(4000);
	else
		--CurSelTPLEditDef = ItemDefCsv:get(10100);
        getglobal("SelItemTemplateEdit"):Show()
        CurSelTPLEditDef = nil
		if CurSelTPLBtnName then
			getglobal(CurSelTPLBtnName.."Checked"):Hide();
			CurSelTPLBtnName = nil;
		end
	end 

	if CurSelTPLEditDef then
		if SelTPLEditorType == 'actor' or SelTPLEditorType == 'craft' or SelTPLEditorType == 'furnace' or SelTPLEditorType == 'plot' then
			SetSingleEditorFrame(SelTPLEditorType, CurSelTPLEditDef, true);
		else
			SetNewSingleEditorFrame(SelTPLEditorType, CurSelTPLEditDef, true);
		end
		getglobal("SelTemplateEditorFrame"):Hide();
		getglobal("ChooseModifyAndNewFrame"):Hide();
	else
	end
end

function SelTemplateEditorFrameCloseBtn_OnClick()
	if IsSelOriginal then
		SetSelTemplateEditorInfo(SelTPLEditorType, false);
	else
		if CurSelTPLBtnName then
			getglobal(CurSelTPLBtnName.."Checked"):Hide();
			CurSelTPLBtnName = nil;
		end
		getglobal("SelTemplateEditorFrame"):Hide();
	end
end

--selectTemplate:选择一个模板:确定按钮
function SelTemplateEditorFrameOkBtn_OnClick()
	--[[
	FrameStack.remove(FrameStack.cur());
	FrameStack.remove(FrameStack.findLastFrame("SelTemplateEditorFrame"));
	]]
	
	if CurSelTPLEditDef then
		if SelTPLEditorType == 'actor' or SelTPLEditorType == 'item' or SelTPLEditorType == "craft" or SelTPLEditorType == 'furnace' or SelTPLEditorType == 'block' or SelTPLEditorType == 'plot' then
			SetSingleEditorFrame(SelTPLEditorType, CurSelTPLEditDef, true);
		else
			SetNewSingleEditorFrame(SelTPLEditorType, CurSelTPLEditDef, true);
		end
		getglobal("SelTemplateEditorFrame"):Hide();
		getglobal("ChooseModifyAndNewFrame"):Hide();
	end
end

function SelTemplateEditorFrame_OnLoad()
	--[[
	for i=1, EdtiorTPLBtn_Max/10 do
		for j=1, 10 do
			local index = (i-1)*10+j;
			local templateBtn = getglobal("EditorSelfTPL"..index);

			local rI = i;
			local rJ = j+1;
			if j == 10 then
				rI = i+1;
				rJ = 1;
			end
			templateBtn:SetPoint("topleft", "SelTemplateBoxPlane", "topleft", (rJ-1)*91, (rI-1)*93);
		end
	end
	]]
end

function LoadEditorTPLTable(editType, isOriginal)
	Log("LoadEditorTPLTable:");
	t_EdtiorSelfTPL = {};
	if isOriginal then
		Log("isOriginal:");
		if editType == 'block' then
			local num = BlockDefCsv:getNum();
			for i=1, num do
				local def = BlockDefCsv:get(i-1, false);
				if def and def.IsTemplate then
					table.insert(t_EdtiorSelfTPL, def);
				end
			end
		elseif editType == 'actor' then
			local num = MonsterCsv:getNum();
			for i=1, num do
				local def = MonsterCsv:getByIndex(i-1);
				if def and def.IsTemplate then
					table.insert(t_EdtiorSelfTPL, def);
				end
			end
		elseif editType == 'item' then
			local num = ItemDefCsv:getNum();
			for i=1, num do
				local def = ItemDefCsv:get(i-1);
				if def and def.Type ~= ITEM_TYPE_BLOCK and def.IsTemplate then
					table.insert(t_EdtiorSelfTPL, def);
				end
			end
		elseif editType == 'craft' then
			local num = DefMgr:getCraftingDefNum();
			for i=1, num do
				local def = DefMgr:getCraftingDefByIndex(i-1);
				if def and def.IsTemplate then
					table.insert(t_EdtiorSelfTPL, def);
				end
			end
		elseif editType == 'furnace' then
			local num = DefMgr:getFurnaceDefNum();
			for i=1, num do
				local def = DefMgr:getFurnaceDefByIndex(i-1);
				if def and def.IsTemplate then
					table.insert(t_EdtiorSelfTPL, def);
				end
			end
		elseif editType == 'plot' then
			--LLTODO:加载原始的剧情去编辑
			local num = DefMgr:getNpcPlotDefNum();
			Log("load_plot_Def: old: num = " .. num);
			for i=1, num do
				local def = DefMgr:getNpcPlotDefByIndex(i-1);
				Log("load_plot_Def: def: 111");
				if def and def.IsTemplate then
					Log("load_plot_Def: def: true");
					if def.CopyID <= 0 then
						table.insert(t_EdtiorSelfTPL, def);
					end
				end
			end
		end
	else
		Log("not Original:");
		if editType == 'block' then
			local num = ModEditorMgr:getCustomBlockCount();
			for i=1, num do
				local def = ModEditorMgr:getBlockDef(i-1);
				if def then
					table.insert(t_EdtiorSelfTPL, def);
				end
			end
		elseif editType == 'actor' then
			local num = ModEditorMgr:getCustomMonsterCount();
			for i=1, num do
				local def = ModEditorMgr:getMonsterDef(i-1);
				if def then
					table.insert(t_EdtiorSelfTPL, def);
				end
			end
		elseif editType == 'item' then
			local num = ModEditorMgr:getCustomItemCount();
			for i=1, num do
				local def = ModEditorMgr:getItemDef(i-1);
				if def and def.Type ~= ITEM_TYPE_BLOCK then
					table.insert(t_EdtiorSelfTPL, def);
				end
			end
		elseif editType == 'craft' then
			local num = ModEditorMgr:getCustomCraftingCount();
			for i=1, num do
				local def = ModEditorMgr:getCraftingDef(i-1);
				if def then
					table.insert(t_EdtiorSelfTPL, def);
				end
			end
		elseif editType == 'furnace' then
			local num = ModEditorMgr:getCustomFurnaceCount();
			for i=1, num do
				local def = ModEditorMgr:getFurnaceDef(i-1);
				if def then
					table.insert(t_EdtiorSelfTPL, def);
				end
			end
		elseif editType == 'plot' then
			--LLTODO:加载自定义的剧情去编辑
			Log("load_plot_Def: not original:");
			local num = ModEditorMgr:getCustomNpcPlotCount();
			for i=1, num do
				local def = ModEditorMgr:getNpcPlotDef(i-1);
				if def then
					table.insert(t_EdtiorSelfTPL, def);
				end
			end
		end
	end
end

-- selectTemplate:
function UpdateSelTemplateEditorFrame(editType, isOriginal)
	-- local closeNormal = getglobal("SelTemplateEditorFrameCloseBtnNormal");
	-- local closePushedBG = getglobal("SelTemplateEditorFrameCloseBtnPushedBG");
	if isOriginal then
		-- closeNormal:SetTextureHuiresXml("ui/mobile/texture/uitex4.xml");
		-- closeNormal:SetTexUV("cjk_anniu06");
		-- closePushedBG:SetTextureHuiresXml("ui/mobile/texture/uitex4.xml");
		-- closePushedBG:SetTexUV("cjk_anniu06");

		getglobal("EditorSelfTPLBtn"):Hide();
		getglobal("EditorSelNewBtn"):Hide();
		
		for i=1, EdtiorTPLBtn_Max/10 do
			for j=1, 10 do
				local index = (i-1)*10+j;
				local templateBtn = getglobal("EditorSelfTPL"..index);
				
				templateBtn:SetPoint("topleft", "SelTemplateBoxPlane", "topleft", (j-1)*91, (i-1)*93);
			end
		end
	else
		-- closeNormal:SetTextureHuiresXml("ui/mobile/texture/uitcomm1.xml");
		-- closeNormal:SetTexUV("juese_guanbi01");
		-- closePushedBG:SetTextureHuiresXml("ui/mobile/texture/uitcomm1.xml");
		-- closePushedBG:SetTexUV("juese_guanbi01");
	
		getglobal("EditorSelfTPLBtn"):Show();
		getglobal("EditorSelNewBtn"):Hide();
		if editType == 'actor' or editType == 'item' or editType == 'craft' or editType == 'furnace' or editType == 'plot' then
			getglobal("EditorSelNewBtn"):Show();
		end

		for i=1, EdtiorTPLBtn_Max/10 do
			for j=1, 10 do
				local index = (i-1)*10+j;
				local templateBtn = getglobal("EditorSelfTPL"..index);

				local rI = i;
				local rJ = j+1;
				if j == 10 then
					rI = i+1;
					rJ = 1;
				end
				templateBtn:SetPoint("topleft", "SelTemplateBoxPlane", "topleft", (rJ-1)*91, (rI-1)*93);
			end
		end
	end

	getglobal("SelTemplateBox"):resetOffsetPos();
	UpdateSelTemplateEditor(editType, isOriginal);
end

--selectTemplate:选择一个模板
function SetSelTemplateEditorInfo(editType, isOriginal)
	Log("SetSelTemplateEditorInfo:");
	if CurSelTPLBtnName then
		getglobal(CurSelTPLBtnName.."Checked"):Hide();
		CurSelTPLBtnName = nil;
	end
	CurSelTPLEditDef = nil;

	SelTPLEditorType = editType;
	IsSelOriginal = isOriginal;
	LoadEditorTPLTable(editType, isOriginal);				--加载模板定义
	UpdateSelTemplateEditorFrame(editType, isOriginal);		--更新模板选择窗口
	if editType == 'actor' then
		getglobal("EditorSelfTPLBtnName"):SetText( GetS(3644, GetS(3932)) );
	elseif editType == 'item' then
		getglobal("EditorSelfTPLBtnName"):SetText( GetS(3644, GetS(3933)) );
	elseif editType == 'block' then
		getglobal("EditorSelfTPLBtnName"):SetText( GetS(3644, GetS(3931)) );
	elseif editType == 'craft' then
		getglobal("EditorSelfTPLBtnName"):SetText( GetS(3644, GetS(1231)) );
	elseif editType == 'furnace' then
		getglobal("EditorSelfTPLBtnName"):SetText( GetS(3644, GetS(1230)) );
	elseif editType == 'plot' then
		getglobal("EditorSelfTPLBtnName"):SetText( GetS(3644, GetS(11006)) );
	end

	if not getglobal("SelTemplateEditorFrame"):IsShown() then
		getglobal("SelTemplateEditorFrame"):Show();
	end
end

function SelTemplateEditorFrame_OnShow()
	--标题栏
	getglobal("SelTemplateEditorFrameTitleFrameName"):SetText(GetS(3640));
end

--selectTemplate:
function UpdateSelTemplateEditor(editType, isOriginal)
	for i=1, EdtiorTPLBtn_Max do
		local templateBtn = getglobal("EditorSelfTPL"..i);
		if i <= #(t_EdtiorSelfTPL) then
			templateBtn:Show();
			local icon = getglobal("EditorSelfTPL"..i.."Icon");

			local def = t_EdtiorSelfTPL[i];
			templateBtn:SetClientID(i);	
			if editType == 'block' then
				SetItemIcon(icon, def.ID);
			elseif editType == 'actor' then
				local textureId = "109";	--默认的icon
				if tonumber(def.ModelType) == 3 then
					local model = string.sub(def.Model,2,string.len(def.Model))
					local args = FrameStack.cur()
					if args.isMapMod then
						AvatarSetIconByID(def,icon)
					else
						AvatarSetIconByIDEx(model,icon)
					end 
				else
					if isOriginal then	
						textureId = def.ID;			
					elseif def.Icon and def.Icon ~= "" then
						textureId = def.Icon;
					end 
				end 
				if tonumber(def.ModelType) ~= 3 then 
					icon:SetTexture("ui/roleicons/"..textureId..".png", true);
				end 
			elseif editType == 'item' then
				SetItemIcon(icon, def.ID);
			elseif editType == 'craft' then
				SetItemIcon(icon, def.ResultID);
			elseif editType == 'furnace' then
				SetItemIcon(icon, def.MaterialID);
			elseif editType == 'plot' then
				--LLTODO:选择原始模板界面, 格子图标, 暂时用200代替
				NpcPlot_SetPlotIcon(icon, def.Icon);
			end
		else	
			templateBtn:Hide();
		end
	end

	local index;
	if isOriginal then
		index = #(t_EdtiorSelfTPL);
	else
		index = #(t_EdtiorSelfTPL)+2;
		local i = math.ceil(index/10);
		local j = index - (i-1)*10;
		getglobal("EditorSelNewBtn"):SetPoint("topleft", "SelTemplateBoxPlane", "topleft", (j-1)*91, (i-1)*93);
	end

	local lines = math.ceil(index/10);
	local height = 360 + (lines-3)*93;
	if height < 360 then
		height = 360;
	end

	getglobal("SelTemplateBoxPlane"):SetSize(895, height);
end

function SelItemTemplateEditorFrameCloseBtn_OnClick()
    getglobal("SelItemTemplateEdit"):Hide()
end

function SelItemTemplateEditorFrameOkBtn_OnClick()

    if not CurSelItemTemplateIndex then
        UpdateTipsFrame(GetS(4592), 0)
        return
    end

    CurSelTPLEditDef = ItemDefCsv:get(t_ItemTemplate[CurSelItemTemplateIndex].ItemId);
    if not CurSelTPLEditDef then
        print("invalid item id", CurSelTPLEditDef)
        return
    end

    SetSingleEditorFrame(SelTPLEditorType, CurSelTPLEditDef, true);

	getglobal("SelTemplateEditorFrame"):Hide();
	getglobal("ChooseModifyAndNewFrame"):Hide();
    getglobal("SelItemTemplateEdit"):Hide()
end

function EdtiorItemTPLBtnTemplate_OnClick()
    local index = this:GetClientID()
    local tmp = getglobal("EdtiorItemTPLBtn"..index)
    local tmp_checked = getglobal("EdtiorItemTPLBtn"..index.."Checked")

    if index == CurSelItemTemplateIndex then
        return
    end

    tmp_checked:Show()
    if CurSelItemTemplateIndex then
        getglobal("EdtiorItemTPLBtn"..CurSelItemTemplateIndex.."Checked"):Hide()
    end
    CurSelItemTemplateIndex = index
    print(GetS(t_ItemTemplate[CurSelItemTemplateIndex].TipStringId))
    UpdateTipsFrame(GetS(t_ItemTemplate[CurSelItemTemplateIndex].TipStringId), 0)
end

function SelItemTemplateEditorFrame_OnLoad()
    for i=1, #(t_ItemTemplate) do
        local tmp = getglobal("EdtiorItemTPLBtn"..i)
        local tmp_icon = getglobal("EdtiorItemTPLBtn"..i.."Icon")
        
        tmp:SetClientID(i)
        tmp_icon:SetTexUV(t_ItemTemplate[i].Icon)
	end
	
	--标题栏:'创建自定义道具'
	getglobal("SelItemTemplateEditTitleFrameName"):SetText(GetS(4590));
end

function SelItemTemplateEditorFrame_OnShow()
end

function SelItemTemplateEditorFrame_OnHide()
    if CurSelItemTemplateIndex then
        getglobal("EdtiorItemTPLBtn"..CurSelItemTemplateIndex.."Checked"):Hide()
    end
    CurSelItemTemplateIndex = nil
end