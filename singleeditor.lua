
--[[ todo_delete
CurrentEditDef = nil;
CurEditorIsCopied = false;


local CurEditorClass = "";
local CurrentEditMatDef;
local ModelRelevantID = 0;  -- -1fullycustommodel
local ModelRelevantName = "";
local SingleEditDesc = '';
local l_NameDisplay = false;
local l_DescDisplay = false;

local CurTabIndex = 1;
local CurAttrTypeIndex = 1;	
local Max_EditorUI = 30;
local CurEditorUIName = nil;

local t_CurSelectedFeature = {};
local CurEditFeatureParamIndex;
local CurEditFeatureIndex;
local CurEditFeatureItemData = {};
local MaxFeatureAiNum = 50;
local MaxFeatureAiParamNum = 10;

local t_MatTemplate = {};
local TempActorInfoForNpcShop = {}
local ObjCloneFlag = false -- 复制标志
]]
NpcStore = {
	 iShopID = 0,                 --商店ID
	 iNpcID = 0,					 --NpcID
	 sShopName = "",       --商店名称
	 sShopDesc = "",        --商店描述
	 EnglishName = "",
	 sInnerKey = "", --对应地图内的monsterid的key
	 shopItemMap = {},
}

local NpcAttr ={
	iSkuID = 1,         --商品ID
	iItemID = 100,     --出售的物品ID
	iOnceBuyNum = 1,    --单次[Desc5]数量
	iMaxCanBuyCount = 301,--最大可[Desc5]次数
	iRefreshDuration = 1,   --商品恢复刷新时间间隔，0表示不可恢复
	iStarNum = 10,		  --星星数量
	iCostItemInfo1 = 100001,	--id*1000+num
	iCostItemInfo2 = 101001,	--id*1000+num
	--iLeftCount = 10,     --可[Desc5]数量
	--iEndTime = 10,       --补充时间
}

PackGiftDef = {
	iPackID = 0,
	iPackType = 0,
	iMaxOpenNum = 1,
	iRepeat = 0,
	iNeedCostItem = 0,
	iCostItemInfo = 0,
	packItemList = {},
}

PackItemDef ={
	iItemInfo = 100010,
	iRatio = 1,
}



function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function GetCurrentEditDef()
	return CurrentEditDef;
end

function Clamp(val, step, min, max)
	if val < min then
		if val+step > min then
			return min,true
		else
			return val, false;
		end
	elseif val > max then
		if val-step < max then
			return max,true
		else
			return val, false;
		end
	end

	return val, true;
end

function SetModelRelevantID(id)
	if CurEditorClass == 'block' then
		local editorIcon = getglobal("SingleEditorIcon");
		if not editorIcon:IsShown() then
			getglobal("NewSingleEditorFrameTab1FrameInfoSelModeBtn"):Hide();
			getglobal("NewSingleEditorFrameTab1FrameInfoReelectModeBtn"):Show();
			editorIcon:Show();
		end
		SetItemIcon(editorIcon, id);
	elseif CurEditorClass == 'actor' then
		DetachEditorView();
		local modelView = getglobal("EditorModelView");
		local body = UIActorBodyManager:getMonsterBody(id);
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			modelView:attachActorBody(body)
		else
			body:attachUIModelView(modelView)
		end
		if getglobal("NewSingleEditorFrameTab1FrameInfoSelModeBtn"):IsShown() then
			getglobal("NewSingleEditorFrameTab1FrameInfoSelModeBtn"):Hide();
			getglobal("NewSingleEditorFrameTab1FrameInfoReelectModeBtn"):Show();
		end
	elseif CurEditorClass == 'item' then
		local editorIcon = getglobal("SingleEditorIcon");
		if not editorIcon:IsShown() then
			getglobal("NewSingleEditorFrameTab1FrameInfoSelModeBtn"):Hide();
			getglobal("NewSingleEditorFrameTab1FrameInfoReelectModeBtn"):Show();
			editorIcon:Show();
		end
		SetItemIcon(editorIcon, id);
	end
	ModelRelevantID = id;
end

function NewSetModelRelevantID(id, extendData)
	print("NewSetModelRelevantID", id)

	local modelView = getglobal("NewEditorModelView");
	local editorIcon = getglobal("NewSingleEditorIcon");

    modelView:Hide()
    editorIcon:Hide()

    if not id or id == 0 then
        return
    end
    
    local body = modelView:getActorbody();
	if body then
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			modelView:detachActorBody(body)
		else
			body:detachUIModelView(modelView);
		end
	end

	if CurEditorClass == 'block' then
		--LLDO:block
		if extendData then 
			if extendData == "custommodel" then
				SetModelIcon(editorIcon, id, BLOCK_MODEL);
			elseif extendData == "fullycustommodel" then
				SetModelIcon(editorIcon, id, FULLY_BLOCK_MODEL);
			elseif extendData == "importcustommodel" then
				SetModelIcon(editorIcon, id, IMPORT_BLOCK_MODEL);
			end
		else
			SetItemIcon(editorIcon, id);
		end

        editorIcon:Show();
	elseif CurEditorClass == 'actor' and CurrentEditDef.Model ~= "" then
		local clear = not IsLobbyShown();
		local body = UIActorBodyManager:getMonsterBody(id, clear);
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			modelView:attachActorBody(body)
		else
			body:attachUIModelView(modelView);
		end

        modelView:Show()
	elseif CurEditorClass == 'item' or CurEditorClass == 'craft' then
		if extendData then 
			if extendData == "custommodel" then
				SetModelIcon(editorIcon, id, WEAPON_MODEL);
			elseif extendData == "fullycustommodel" then
				SetModelIcon(editorIcon, id, FULLY_ITEM_MODEL);
			elseif extendData == "importcustommodel" then
				SetModelIcon(editorIcon, id, IMPORT_ACTOR_MODEL);
			end
		else
			SetItemIcon(editorIcon, id);
		end

        editorIcon:Show()
	end

    print("NewSetModelRelevantID ModelRelevantID = ", ModelRelevantID)
end
---------------------------------------EditorSliderTemplate--------------------------------------------
function EditorSliderTemplateLeftBtn_OnClick()
	local value = getglobal(this:GetParent().."Bar"):GetValue();
	local index = this:GetParentFrame():GetClientID();
	local tabName = "tab"..CurTabIndex;
	local attrType = "attrtype"..CurAttrTypeIndex;
	local t = new_modeditor.config[CurEditorClass][tabName][attrType].Attr[index];

	value = value - t.Step;
	getglobal(this:GetParent().."Bar"):SetValue(value);
end

function EditorSliderTemplateBar_OnValueChanged()
	local value = this:GetValue();
	local ratio = (value-this:GetMinValue())/(this:GetMaxValue()-this:GetMinValue());

	if ratio > 1 then ratio = 1 end
	if ratio < 0 then ratio = 0 end
	local width   = math.floor(310*ratio)
	getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
	getglobal(this:GetName().."Pro"):SetWidth(width);

	local index = this:GetParentFrame():GetClientID();
	local tabName = "tab"..CurTabIndex;
	local attrType = "attrtype"..CurAttrTypeIndex;
	local t = new_modeditor.config[CurEditorClass][tabName][attrType].Attr[index];


	if t.ValShowType then
		if t.ValShowType == 'One_Decimal' then
			value = string.format("%.1f", value);
		elseif t.ValShowType == 'Percent' then
			value = string.format("%d", math.ceil(value));
		end
	end

	t.CurVal = value;
	local valFont = getglobal(this:GetParent().."Val");
	local desc = getglobal(this:GetParent().."Desc");
	
	if t.ValShowType == 'Percent' then
		valFont:SetText(value.."%");
	else
		valFont:SetText(value);
	end
	
	if t.GetDesc then
		desc:SetText(t.GetDesc(tonumber(value)));
	end

	UpdateEditorIntroduct();
end

function EditorSliderTemplateRightBtn_OnClick()
	local value = getglobal(this:GetParent().."Bar"):GetValue();
	local index = this:GetParentFrame():GetClientID();
	local tabName = "tab"..CurTabIndex;
	local attrType = "attrtype"..CurAttrTypeIndex;
	local t = new_modeditor.config[CurEditorClass][tabName][attrType].Attr[index];

	value = value + t.Step;
	getglobal(this:GetParent().."Bar"):SetValue(value);
end

-------------------------------------------EditorSwitch---------------------------------------------------
function EditorSwitchOnClick(switchName, state)
	local switch = getglobal(switchName);
	
	local index = switch:GetParentFrame():GetClientID();
	
	if CurEditorClass == 'actor' or CurEditorClass == 'item' or CurEditorClass == 'furnace' or CurEditorClass == 'block' or CurEditorClass == 'status' then	--LLDO:加上block
		t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
	else
		local tabName = "tab"..CurTabIndex;
		local attrType = "attrtype"..CurAttrTypeIndex;
		t = new_modeditor.config[CurEditorClass][tabName][attrType].Attr[index];
	end

	state = state == 1;

	t.CurVal = state;
	if t.ENName == 'UseGravity' then
		if state then
			t.CurVal = 1;
		else
			t.CurVal = 0;
		end
	end

	if t.Func then
		local type;
		if state then
			if t.ENName == 'EditType' then t.CurVal = 3 end;
			type = 'add';
		else
			if t.ENName == 'EditType' then t.CurVal = 2 end;
			type = 'remove';
		end
		
		t.Func(type);
	end

	if CurEditorClass == 'item' and t.Def == 'PackDef' and t.ENName == 'CanCondition' then
		switchPackCostItemStatus(state)
	end

	UpdateEditorIntroduct();
end

----------------------------------------EditorSelectionTemplate-------------------------------------------


function EditorSelBtnTemplateDel_OnClick()
	local index = this:GetParentFrame():GetParentFrame():GetClientID();
	local tabName = "tab"..CurTabIndex;
	local attrType = "attrtype"..CurAttrTypeIndex;
	local t = new_modeditor.config[CurEditorClass][tabName][attrType].Attr[index];

	local btnIdx = this:GetParentFrame():GetClientID();
	local icon = getglobal(this:GetParent().."Icon");
	icon:Hide();
	this:Hide();
	t.CurVal[btnIdx] = 0;
	UpdateEditorIntroduct();
end

----------------------------------------EditorOptionTemplate----------------------------------------------
function EditorOptionTemplateBtn_OnClick()
	local index = this:GetParentFrame():GetClientID();
	local tabName = "tab"..CurTabIndex;
	local attrType = "attrtype"..CurAttrTypeIndex;
	local t = new_modeditor.config[CurEditorClass][tabName][attrType].Attr[index];
	
	CurEditorUIName = this:GetName();
	SetEditorOptionFrame(t.Options, GetS(t.Name_StringID), GetS(t.Desc_StringID));
end

-----------------------------------------EditorOptionFrame---------------------------------------------
local Max_SingleOption = 20;
function SetEditorOptionFrame(options, title, desc, Type)
	Log("SetEditorOptionFrame:");
	getglobal("EditorOptionFrameTitle"):SetText(title);
	getglobal("EditorOptionFrameDesc"):SetText(desc);

	local num = #(options);
	for i=1, Max_SingleOption do
		local optionBtn = getglobal("EditorSingleOption"..i);
		if i <= num then
			optionBtn:Show();
			
			local nameTxt = "";
			if Type == "PlotConditionTask" then
				--LLTODO:前置条件->任务
				nameTxt = options[i].Name_String;
			else
				nameTxt = GetS(options[i].Name_StringID);
			end
			local name = getglobal("EditorSingleOption"..i.."Name");
			name:SetText(nameTxt);
			if options[i].Color then
				--name:SetTextColor(options[i].Color.r, options[i].Color.g, options[i].Color.b);
				name:SetTextColor(55, 54, 41);
			else
				name:SetTextColor(55, 54, 41);
			end
		else
			optionBtn:Hide();
		end
	end

	local height = num*69;
	if height < 274 then
		height = 274;
	end
	
	getglobal("EditorOptionBoxPlane"):SetHeight(height);

	getglobal("EditorOptionFrame"):Show();	
end

function SingleOptionBtnTemplate_OnClick()
	local id = this:GetClientID();

	if getglobal("NpcTalkTaskEditFrame"):IsShown() then
		--任务设置界面的选项条目选择
		NpcTask_SingleOptionItemClick(id);
	elseif getglobal("NpcTalkAnswerSetFrame"):IsShown() then
		--回答设置-触发功能
		NpcTalkSingleOptionItemClidk(id);
	elseif getglobal("MaterialTemplateBox"):IsShown() then
		--材质模板选择
		--CurrentEditMatDef = t_MatTemplate[id].Def;
		PhysxMatConfig.Init(t_MatTemplate[id].Def);
		UpdatePhysxMatAttr(2)
		getglobal("MatTemplateOptionFrame"):Hide()
	else
		OnCurEditorUICallBack('clickoption', id);
		if CurrentEditDef and CurrentEditDef.Type == ITEM_TYPE_PACK then
			selectPackType(id-1)
		end
	end

	--前置条件回调
	if getglobal("SingleEditorFrameBaseSetNPCPlot"):IsShown() then
		ConditionOptionCallbackUI();
	end

	getglobal("EditorOptionFrame"):Hide();
end

function EditorOptionFrame_OnLoad()
	for i=1, Max_SingleOption do
		local op = getglobal("EditorSingleOption"..i);
		op:SetPoint("top", "EditorOptionBoxPlane", "top", 0, (i-1)*69)
	end
end

function EditorOptionFrame_OnShow()
	SetSingleEditorDealMsg(false)
end

function EditorOptionFrame_OnHide()
	SetSingleEditorDealMsg(true)
end
-----------------------------------------NewSingleEditorFrame-----------------------------------------------------
--selecttion:点击确认按钮后, 刷新UI.
function OnCurEditorUICallBack(type, val, extendData)
	print('OnCurEditorUICallBack', type, val, CurEditorUIName);
	if not CurEditorUIName then return end
	
	local enableUI1 = getglobal(CurEditorUIName.."Forbidden");
	if enableUI1 then
		enableUI1:Hide();
	end
	--这里判断，如果选择的是当前地图的模型，则判断要不要移动到总库里面
	--[[ 跟开发人员黄福斌确认过，这里的逻辑是不需要加的 先注释
	if ResourceCenterNewVersionSwitch and ClientCurGame:isInGame() then
		if (type == "blockmodel" or type == "itemmodel" or type == "actormodel") and (extendData=="custommodel" or extendData=="fullycustommodel" or extendData == "importcustommodel") then
			if not ResourceCenter:checkUploadedResLocalStatus(RES_MODEL_CLASS, val, CUSTOM_MODEL_TYPE) then
				local folderIndex = -1
				local foldersNum = ResourceCenter:getResClassNum(MAP_MODEL_CLASS, CUSTOM_MODEL_TYPE)
				for i=1,foldersNum do
					local folderData = ResourceCenter:getClassInfo(MAP_LIB, i-1, CUSTOM_MODEL_TYPE)
					for j=1,folderData:getModelNum() do
						if val == folderData:getModelName(j-1) then
							folderIndex = i-1
							break
						end
					end
				end
				ResourceCenter:moveResToClass(MAP_MODEL_CLASS, RES_MODEL_CLASS, folderIndex, 0, val, CUSTOM_MODEL_TYPE)
				local curCustomItemNum = CustomModelMgr:getCustomItemNum();
				local curCostomActorNum = CustomModelMgr:getCustomActorModelNum(MAP_MODEL_CLASS);
				if IsRoomOwner() then
					CustomModelMgr:checkSyncCustomModelData(curCustomItemNum, curCostomActorNum);
					ResourceCenter:syncClassInfoToClient(0);
				end
			end
		end
	end
	]]
	
	if type == 'dropitem' then		--选择掉落物回调
		local index = getglobal(CurEditorUIName):GetParentFrame():GetClientID();
		local t;
		if CurEditorClass == 'actor' or CurEditorClass == 'item' or CurEditorClass == 'block' then	--LLDO:加上block
			t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
		else
			local tabName = "tab"..CurTabIndex;
			local attrType = "attrtype"..CurAttrTypeIndex;
			t = new_modeditor.config[CurEditorClass][tabName][attrType].Attr[index];
		end

		local btnIdx = getglobal(CurEditorUIName):GetClientID();
		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon = getglobal(CurEditorUIName.."AddIcon");
		local del = getglobal(CurEditorUIName.."Del");
		if not del:IsShown() then
			icon:Show();
			addIcon:Hide();
			del:Show();
		end

		if GetInst("ModsLibPkgManager"):CheckIsEditPluginInPkg() then
			local isEnable = GetInst('UIManager'):GetCtrl('ModsLibPkgPluginEdit'):isEnable(val);
			local enableUI = getglobal(CurEditorUIName.."Forbidden");
			if isEnable then
				enableUI:Hide()
			else
				enableUI:Show()
			end  
		end

		SetItemIcon(icon, val);

		t.CurVal[btnIdx] = val;
	elseif type == 'craftresult' then
		local index = getglobal(CurEditorUIName):GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];

		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon = getglobal(CurEditorUIName.."AddIcon");
		local del = getglobal(CurEditorUIName.."Del");
		local name = getglobal(CurEditorUIName.."Name");
		if not del:IsShown() then
			icon:Show();
			addIcon:Hide();
		end
		SetItemIcon(icon, val);
		local itemDef = ModEditorMgr:getItemDefById(val);
		if not itemDef then
			itemDef = ItemDefCsv:get(val);
		end
		if itemDef then
			name:SetText(itemDef.Name)
			getglobal("SingleEditorFrameBaseSetCraftResultDesc"):SetText(itemDef.Desc);
		end
		t.CurVal.id = val;

		getglobal("NewSingleEditorIcon"):Show();
		SetItemIcon(getglobal("NewSingleEditorIcon"), val);
	elseif type == 'craft_tool' then
		local index = getglobal(CurEditorUIName):GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
		t.CurVal.id = val;
		UpdateCraftToolButton(val);
	elseif type == 'craftmaterial' then
		local index = getglobal(CurEditorUIName):GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];

		local btnIdx 	= getglobal(CurEditorUIName):GetClientUserData(0);
		local icon 		= getglobal(CurEditorUIName.."Icon");
		local addIcon   = getglobal(CurEditorUIName.."AddIcon");
		local del 		= getglobal(CurEditorUIName.."Del");
		local name 		= getglobal(CurEditorUIName.."Name");
		local numUI 	= getglobal(CurEditorUIName.."Num");
		if not del:IsShown() then
			icon:Show();
			addIcon:Hide();
			del:Show();
			numUI:Show();
		end
		SetItemIcon(icon, val);

		local itemDef = ModEditorMgr:getItemDefById(val);
		if not itemDef then
			itemDef = ItemDefCsv:get(val);
		end
		if itemDef then
			name:SetText(itemDef.Name)
		end

		getglobal(numUI:GetName().."Val"):SetText(t.Min);
		if t.CurVal[btnIdx] then
			t.CurVal[btnIdx].id = val;
			t.CurVal[btnIdx].num = t.Min;
		else
			t.CurVal[btnIdx] = {id=val, num=t.Min}
		end
	elseif type == 'furnacematerial' then
		local index = getglobal(CurEditorUIName):GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];

		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon   = getglobal(CurEditorUIName.."AddIcon");
		local del = getglobal(CurEditorUIName.."Del");
		local name = getglobal(CurEditorUIName.."Name");
		if not del:IsShown() then
			icon:Show();
			addIcon:Hide();
		end
		SetItemIcon(icon, val);
		local itemDef = ModEditorMgr:getItemDefById(val);
		if not itemDef then
			itemDef = ItemDefCsv:get(val);
		end
		if itemDef then
			name:SetText(itemDef.Name)
			getglobal("SingleEditorFrameBaseSetFurnaceMaterialDesc"):SetText(itemDef.Desc);
		end
		t.CurVal.id = val;

		getglobal("NewSingleEditorIcon"):Show();
		SetItemIcon(getglobal("NewSingleEditorIcon"), val);
	elseif type == 'furnaceresult' then
		local index = getglobal(CurEditorUIName):GetClientID();
		local class = getglobal(CurEditorUIName):GetClientString();
		local btnIndex = getglobal(CurEditorUIName):GetClientUserData(0);
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];

		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon = getglobal(CurEditorUIName.."AddIcon");
		local del = getglobal(CurEditorUIName.."Del");
		local name = getglobal(CurEditorUIName.."Name");
		local num = getglobal(CurEditorUIName.."Num");
		local numVal = getglobal(CurEditorUIName.."NumVal");
		if not del:IsShown() then
			icon:Show();
			addIcon:Hide();
			del:Show();
		end
		SetItemIcon(icon, val);
		local itemDef = ModEditorMgr:getItemDefById(val);
		if not itemDef then
			itemDef = ItemDefCsv:get(val);
		end
		if itemDef then
			name:SetText(itemDef.Name)
			num:Show();
			--getglobal("SingleEditorFrameBaseSetFurnaceResultDesc"):SetText(itemDef.Desc);
		else
			name:SetText("");
			num:Hide();
		end
		numVal:SetText(t.Min);
		if t.CurVal[btnIndex] then
			t.CurVal[btnIndex].id = val;
			t.CurVal[btnIndex].num = t.Min;
		else
			t.CurVal[btnIndex] = {id=val, num=t.Min}
		end
	elseif type == 'projectilemodel' then
		local def = ProjectileDefCsv:get(val);
		if def then
			local index = getglobal(CurEditorUIName):GetParentFrame():GetClientID();
			local tabName = "tab"..CurTabIndex;
			local attrType = "attrtype"..CurAttrTypeIndex;
			local t = new_modeditor.config[CurEditorClass][tabName][attrType].Attr[index];
		
			local btnIdx = getglobal(CurEditorUIName):GetClientID();
			local icon = getglobal(CurEditorUIName.."Icon");
			local addIcon   = getglobal(CurEditorUIName.."AddIcon");
			if not icon:IsShown() then
				icon:Show();
				addIcon:Hide();
			end

			SetItemIcon(icon, val);
			t.CurVal[btnIdx] = val;
		end
	elseif type == 'projectile' or type == 'bullet' or type == 'atkbuff' then
		local index = getglobal(CurEditorUIName):GetParentFrame():GetClientID();

		local t;
		if CurEditorClass == 'actor' or CurEditorClass == 'item' or CurEditorClass == 'block'  then --LLDO:加上block
			t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
		else
			local tabName = "tab"..CurTabIndex;
			local attrType = "attrtype"..CurAttrTypeIndex;
			t = new_modeditor.config[CurEditorClass][tabName][attrType].Attr[index];
		end
	
		local btnIdx = getglobal(CurEditorUIName):GetClientID();
		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon   = getglobal(CurEditorUIName.."AddIcon");
		if not icon:IsShown() then
			icon:Show();
			addIcon:Hide();
		end

		if type == 'atkbuff' then
			if SingleEditorFrame_Switch_New then
				local path = GetInst("ModsLibDataManager"):GetStatusIconPath(val);
				if path ~= "" then
					icon:SetTexture(path, true)
				end
			else
				local buffDef = DefMgr:getBuffDef(val)
				if buffDef then
					icon:SetTexture("ui/bufficons/"..buffDef.IconName..".png", true);
				end
			end
		else
			SetItemIcon(icon, val);
		end
		t.CurVal[btnIdx] = val;
	elseif type == 'clickoption' then	--点击选项回调
		local index = getglobal(CurEditorUIName):GetParentFrame():GetClientID();
		local t;
	
		if CurEditorClass == 'actor' or CurEditorClass == 'item' or CurEditorClass == 'craft' or CurEditorClass == 'block' or CurEditorClass == 'plot' or CurEditorClass == 'status' then
			t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
		else
			local tabName = "tab"..CurTabIndex;
			local attrType = "attrtype"..CurAttrTypeIndex;
			t = new_modeditor.config[CurEditorClass][tabName][attrType].Attr[index];
		end

		local btnName = getglobal(CurEditorUIName.."Name");
		local desc = getglobal(getglobal(CurEditorUIName):GetParent().."Desc");

		btnName:SetText(GetS(t.Options[val].Name_StringID));
		--不需要选中之后颜色变化了
		-- if t.Options[val].Color then
		-- 	btnName:SetTextColor(t.Options[val].Color.r, t.Options[val].Color.g, t.Options[val].Color.b);
		-- else
		-- 	btnName:SetTextColor(54, 51, 41);
		-- end
		if t.Options[val].Desc_StringID then
			desc:SetText(GetS(t.Options[val].Desc_StringID), 185, 185, 185);
		else
			desc:SetText("", 185, 185, 185);
		end

		t.CurVal = t.Options[val].Val;
		if t.Func then
			t.Func(t.CurVal);
		end
		-- Log("clickoption:val = " .. val);
	elseif type == 'multioptionok' then		--多选界面确定回调
		local index = getglobal(CurEditorUIName):GetParentFrame():GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];

		for i=1, #(t.CurVal) do
			if val[i] ~= nil and t.CurVal[i] ~= val[i] then
				t.CurVal[i] = val[i];
			end
		end

		print("kekeke multioptionok", t.CurVal);
		if t.Func then
			t.Func(t.CurVal);
		end
	elseif type == "actormodel" then
		local modelView = getglobal("NewEditorModelView");
		local actorId = nil
		local body = modelView:getActorbody();
		if body then
			if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
				modelView:detachActorBody(body)
			else
				body:detachUIModelView(modelView);
			end
		end

		local clear = not IsLobbyShown();

		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon   = getglobal(CurEditorUIName.."AddIcon");

		if extendData and (extendData == "custommodel" or extendData == "fullycustommodel" or extendData == "importcustommodel") then
			
			if extendData == "fullycustommodel" then
				body = UIActorBodyManager:getCustomActorBody(val, FULLY_ACTOR_MODEL, clear);
				SetModelIcon(icon, val, FULLY_ACTOR_MODEL);
			elseif extendData == "importcustommodel" then
				body = UIActorBodyManager:getCustomActorBody(val, IMPORT_ACTOR_MODEL, clear);
				SetModelIcon(icon, val, IMPORT_ACTOR_MODEL);
				actorId = 100100
			else
				body = UIActorBodyManager:getCustomActorBody(val, ACTOR_MODEL, clear);
				SetModelIcon(icon, val, ACTOR_MODEL);
			end
		else
			local modVal = math.floor(val/10000);
			local modelVal = val - math.floor(val/10000) * 10000;
			local iconVal = modelVal;
			

			if modVal == 1 then --角色模型
				body = UIActorBodyManager:getPlayerBody(modelVal, 0, 0, clear, true, "");
				icon:SetTexture("ui/roleicons/"..iconVal..".png", true);
			elseif modVal == 2 then --皮肤模型
				body = UIActorBodyManager:getSkinBody(modelVal, clear);
				local skinDef = RoleSkinCsv:get(modelVal);
				if skinDef then
					iconVal = skinDef.Head;
				end
				icon:SetTexture("ui/roleicons/"..iconVal..".png", true);
			elseif modVal == 3 then  --Avatar模型
				body = AvatarGetBodyByIndex(modelVal)
				AvatarSetIconByIDEx(modelVal,icon)
			elseif modVal == MONSTER_HORSE_MODEL then  --坐骑模型 chenweiTODO 设置模型和头像
				body = UIActorBodyManager:getHorseBody(modelVal, clear);
				local storeHorseDef = DefMgr:getStoreHorseByID(modelVal);
				if storeHorseDef then
					icon:SetTexture("ui/rideicons/"..storeHorseDef.HeadID..".png");
					actorId = 100108
				end
			else
				local monsterDef = ModEditorMgr:getMonsterDefById(modelVal);
				if monsterDef == nil then
					monsterDef = MonsterCsv:get(modelVal);
				end

				if monsterDef and (monsterDef.ModelType == MONSTER_CUSTOM_MODEL or monsterDef.ModelType == MONSTER_FULLY_CUSTOM_MODEL or  monsterDef.ModelType == MONSTER_IMPORT_MODEL) then
					val = monsterDef.Model;
					if monsterDef.ModelType == MONSTER_FULLY_CUSTOM_MODEL then
						body = UIActorBodyManager:getCustomActorBody(monsterDef.Model, FULLY_ACTOR_MODEL, clear);
						SetModelIcon(icon, monsterDef.Model, FULLY_ACTOR_MODEL);
						extendData = "fullycustommodel";
					elseif monsterDef.ModelType == MONSTER_IMPORT_MODEL then
						body = UIActorBodyManager:getCustomActorBody(monsterDef.Model, IMPORT_ACTOR_MODEL, clear);
						SetModelIcon(icon, id, IMPORT_ACTOR_MODEL);
						extendData = "importcustommodel"
					else
						body = UIActorBodyManager:getCustomActorBody(monsterDef.Model, ACTOR_MODEL, clear);
						SetModelIcon(icon, monsterDef.Model, ACTOR_MODEL);
						extendData = "custommodel";
					end
				else
					body = UIActorBodyManager:getMonsterBodyForOriDef(modelVal, clear);
					icon:SetTexture("ui/roleicons/"..iconVal..".png", true);
				end
			end
			
		end

		if body then
			if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
				modelView:attachActorBody(body)
			else
				body:attachUIModelView(modelView)
			end                	
			modelView:Show()
			if actorId then
				modelView:playActorAnim(actorId,0)
			end            
			UpdateEditorModelScale();
		end

		local index = getglobal(CurEditorUIName):GetParentFrame():GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
		if not icon:IsShown() then
			icon:Show();
			addIcon:Hide();
		end

		local btnIdx = getglobal(CurEditorUIName):GetClientID();
		

		if extendData and (extendData == "custommodel" or extendData == "fullycustommodel" or extendData == "importcustommodel") then
			ModelRelevantName = val;
			if extendData == "custommodel" then
				ModelRelevantID = 0;
			elseif extendData == "fullycustommodel" then
				ModelRelevantID = -1;
			elseif extendData == "importcustommodel" then
				ModelRelevantID = -2;
			end		
			t.CurVal[btnIdx] = tostring(val);
		else
			ModelRelevantID = tonumber(val)
			ModelRelevantName = "";
			t.CurVal[btnIdx] = tonumber(val); -- chenweiTODO 记录CurVal赋值
		end
	elseif type == "itemmodel" then
		--物理道具形状参数
		local physicsActorDef = PhysicsActorCsv:get(CurrentEditDef.ID)
		if physicsActorDef and not extendData then
			local t = modeditor.config[CurEditorClass][CurTabIndex+1].Attr;
			for i=1,#(t) do
				if t[i].Type == 'PhysxShape' then
					if t[i].ENName == 'ShapeID' then t[i].CurVal = val.ShapeID end
					if t[i].ENName == 'ShapeVal1' then t[i].CurVal = val.ShapeVal1 end
					if t[i].ENName == 'ShapeVal2' then t[i].CurVal = val.ShapeVal2 end 
					if t[i].ENName == 'ShapeVal3' then t[i].CurVal = val.ShapeVal3 end
				end
			end
		end

		if not extendData or (extendData ~= "custommodel" and extendData ~= "fullycustommodel" and extendData ~= "importcustommodel") then
			val = val.RelevantID;
		end

		NewSetModelRelevantID(val, extendData);

		local index = getglobal(CurEditorUIName):GetParentFrame():GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon   = getglobal(CurEditorUIName.."AddIcon");
		Log("CurEditorUIName=" .. CurEditorUIName);
		if not icon:IsShown() then
			icon:Show();
			addIcon:Hide();
		end

		if extendData then
			local modelView = getglobal("NewEditorModelView");
			local body = nil;
			if extendData == "custommodel" then
				--body = UIActorBodyManager:getCustomActorBody(val, ACTOR_MODEL, clear);
				SetModelIcon(icon, val, WEAPON_MODEL);
			elseif extendData == "fullycustommodel" then
				--body = UIActorBodyManager:getCustomActorBody(val, FULLY_ACTOR_MODEL, clear);
				SetModelIcon(icon, val, FULLY_ITEM_MODEL);
			elseif extendData == "importcustommodel" then
				--body = UIActorBodyManager:getCustomActorBody(val, IMPORT_ACTOR_MODEL, clear);
				SetModelIcon(icon, val, IMPORT_ITEM_MODEL);
			end
			if body then
				if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
					modelView:attachActorBody(body)
				else
					body:attachUIModelView(modelView)
				end                	
				modelView:Show()
				modelView:playActorAnim(0,0)
				UpdateEditorModelScale();
				getglobal("NewSingleEditorIcon"):Hide();
			end
		else
			SetItemIcon(icon, val);
		end

		local btnIdx = getglobal(CurEditorUIName):GetClientID();
		if _G.type(t.CurVal) == "table" then
			t.CurVal[btnIdx] = tostring(val);
		end

		if extendData and (extendData == "custommodel" or extendData == "fullycustommodel" or extendData == "importcustommodel") then
			ModelRelevantName = val;
			if extendData == "custommodel" then
				ModelRelevantID = 0;
			elseif extendData == "fullycustommodel" then
				ModelRelevantID = -1;
			elseif extendData == "importcustommodel" then
				ModelRelevantID = -2;
			end	
		else
			ModelRelevantID = tonumber(val)
			ModelRelevantName = "";
		end

		--TODO:自定义装备:显示模型按钮状态
		if SingleEditorFrame_Switch_New then
			GetInst("ModsLibEditorItemPartMgr"):InitShowModelBtnState(isEditCustomEquip);
		end
      elseif type == "blockmodel" then
    		--LLDO:block, 修改模型外观.
    		NewSetModelRelevantID(val, extendData);

    		--这里是修改本条控件的icon, 并将值写到lua配置表.
		local index = getglobal(CurEditorUIName):GetParentFrame():GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon   = getglobal(CurEditorUIName.."AddIcon");
		Log("CurEditorUIName=" .. CurEditorUIName);
		if not icon:IsShown() then
			icon:Show();
			addIcon:Hide();
		end

		if extendData then
			if extendData == "custommodel" then
				SetModelIcon(icon, val, BLOCK_MODEL);
			elseif extendData == "fullycustommodel" then
				SetModelIcon(icon, val, FULLY_BLOCK_MODEL);
			elseif extendData == "importcustommodel" then
				SetModelIcon(icon, val, IMPORT_BLOCK_MODEL);
			end
		else
			SetItemIcon(icon, val);
		end


		local btnIdx = getglobal(CurEditorUIName):GetClientID();
		t.CurVal[btnIdx] = tostring(val);

		if extendData then
			ModelRelevantName = val;
			if extendData == "custommodel" then
				ModelRelevantID = 0;
			elseif extendData == "fullycustommodel" then
				ModelRelevantID = -1;
			elseif extendData == "importcustommodel" then
				ModelRelevantID = -2
			end	
		else
			ModelRelevantID = tonumber(val)
			ModelRelevantName = "";
		end

   	elseif type == "PlotIcon" then		--剧情图标
    		Log("OnCurEditorUICallBack: PlotIcon:");
		local index = getglobal(CurEditorUIName):GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon   = getglobal(CurEditorUIName.."AddIcon");
		local typeVal = math.floor(val/100000);
		local id = val - math.floor(val/100000) * 100000;
		local iconVal = modelVal;

		Log("val = " .. val .. ", id = " .. id .. ", typeVal = " .. typeVal);
		if typeVal == 1 then
			--生物
			t.CurVal.id = "mob_" .. id;
			icon:SetTexture("ui/roleicons/"..id..".png", true);
		elseif typeVal == 2 then
			--道具
			t.CurVal.id = "item_" .. id;
        	SetItemIcon(icon, id);
		end
	elseif type == "PlotInteractID" then	--剧情触发目标
		Log("OnCurEditorUICallBack: PlotInteractID: val = " .. val);
		local index = getglobal(CurEditorUIName):GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon   = getglobal(CurEditorUIName.."AddIcon");
		local del = getglobal(CurEditorUIName.."Del");
		local id = val;

		t.CurVal.id = id;
		local def = ModEditorMgr:getMonsterDefById(id) or MonsterCsv:get(id);
		if def then
			del:Show();
			icon:Show();
			addIcon:Hide();
			if def.ModelType == 3 then --avatar
				local model = string.sub(def.Model,2,string.len(def.Model))
				local args = FrameStack.cur()
				if args.isMapMod then
					AvatarSetIconByID(def,icon)
				else
					AvatarSetIconByIDEx(model,icon)
				end 
			elseif def.ModelType == MONSTER_CUSTOM_MODEL then
				SetModelIcon(icon, def.Model, ACTOR_MODEL);
			elseif def.ModelType == MONSTER_FULLY_CUSTOM_MODEL then
				SetModelIcon(icon, def.Model, FULLY_ACTOR_MODEL);
			elseif def.ModelType == MONSTER_IMPORT_MODEL then
				SetModelIcon(icon, def.Model, IMPORT_ACTOR_MODEL);
			else
				icon:SetTexture("ui/roleicons/".. def.Icon ..".png", true);
			end 
		end
	elseif type == "PlotItemID" then	--剧情触发目标
		Log("OnCurEditorUICallBack: PlotItemID: val = " .. val);
		local index = getglobal(CurEditorUIName):GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon   = getglobal(CurEditorUIName.."AddIcon");
		local id = val;

		t.CurVal.id = id;
		SetItemIcon(icon, id);
	elseif type == "StoreItem" then	--NPC商店选择商品货币
		local index = getglobal(CurEditorUIName):GetClientID();
		local t = NpcStoreTable.config.Attr[index];
		local icon = getglobal(CurEditorUIName.."Icon");
		local addIcon   = getglobal(CurEditorUIName.."AddIcon");
 		local del =getglobal(CurEditorUIName.."Del")
		local leftIcon = getglobal("NPCStoreEditorFeatureEditFrameLeftPanelItemIcon"..index);
		local leftDesc = getglobal("NPCStoreEditorFeatureEditFrameLeftPanelItemDesc"..index);
		if SingleEditorFrame_Switch_New then 
			leftIcon = getglobal("ModsLibActorShopItemDetailLeftPanelItemIcon"..index)
			leftDesc = getglobal("ModsLibActorShopItemDetailLeftPanelItemDesc"..index)
		end 
		if ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
				and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() then
					
		else
			if val >= USER_MOD_NEWID_BASE and CurrentEditDef then
				local paramDef = ModEditorMgr:getItemDefById(val)
				if paramDef then
					ModEditorMgr:setActorForeignId(CurrentEditDef, val, ModEditorMgr:getItemKey(paramDef))
				end
			end
		end

		t.CurVal = val;
		t.CurNum = 1
		
		local itemDef = ModEditorMgr:getItemDefById(t.CurVal) or ModEditorMgr:getBlockItemDefById(t.CurVal) or ItemDefCsv:get(t.CurVal);

		SetItemIcon(icon, t.CurVal);
		SetItemIcon(leftIcon, t.CurVal);
		if itemDef then
			leftDesc:SetText(itemDef.Name.."*"..t.CurNum)
			leftIcon:Show();
			leftDesc:Show();
		end
		icon:Show();
		addIcon:Hide();
		del:Show();
		local val = getglobal(CurEditorUIName.."NumVal");
		val:SetText(t.CurNum);

		

	elseif type == "StoreAddItem" then
		if ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
				and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() then
			
		else
			if val >= USER_MOD_NEWID_BASE and CurrentEditDef then
				local paramDef = ModEditorMgr:getItemDefById(val)
				if paramDef then
					ModEditorMgr:setActorForeignId(CurrentEditDef, val, ModEditorMgr:getItemKey(paramDef))
				end
			end
		end
		NpcStoreTable.config.ItemID = val;
		ResetNpcStoreAttrTable();
		table.insert(NpcStoreTable.itemList,deep_copy_table(NpcStoreTable.config));

		-- NpcStore.ShopID = os.time();
		SaveNpcStoreItemList();
		UpdateNpcStoreList();
	elseif type == "PackAddItem" then
		if SingleEditorFrame_Switch_New then
			if getglobal("SingleEditorPackage"):IsShown() then
				if ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
				and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() then
					
				else
					if val >= USER_MOD_NEWID_BASE and CurrentEditDef then
						local paramDef = ModEditorMgr:getItemDefById(val)
						if paramDef then
							ModEditorMgr:setItemForeignId(CurrentEditDef, val, ModEditorMgr:getItemKey(paramDef))
						end
					end
				end
				PackItemDef.iItemInfo = val*1000+1
				table.insert(PackGiftDef.packItemList,deep_copy_table(PackItemDef));
			else
				PackGiftDef.iCostItemInfo = val*1000+1
			end
			GetInst("UIManager"):GetCtrl("SingleEditorFrame"):ChangeSingleEditor2Tab_Ctrl(3)
		else
			if getglobal("SingleEditorPackage"):IsShown() then
				if ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
				and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() then
					
				else
					if val >= USER_MOD_NEWID_BASE and CurrentEditDef then
						local paramDef = ModEditorMgr:getItemDefById(val)
						if paramDef then
							ModEditorMgr:setItemForeignId(CurrentEditDef, val, ModEditorMgr:getItemKey(paramDef))
						end
					end
				end
				PackItemDef.iItemInfo = val*1000+1
				table.insert(PackGiftDef.packItemList,deep_copy_table(PackItemDef));
				UpdateSingleEditorPackageList()
			else
				PackGiftDef.iCostItemInfo = val*1000+1
				UpdateSingleEditorAttr()
			end
		end
	end

	UpdateEditorIntroduct();
	if GetInst("UIManager"):GetCtrl("ModsLibPkgPluginEdit","uiCtrlOpenList") then
		local ID = ModelRelevantID
		if ModelRelevantID < 0 then
			ID = val
		end
		GetInst("UIManager"):GetCtrl("SingleEditorFrame"):UpdateSighPoint(ID)
	end
end

function InitNewSingleEditorTab()
	CurTabIndex = 1;
	local t = new_modeditor.config[CurEditorClass];
	for i=1, 3 do
		local key = "tab"..i;
		local btn = getglobal("NewSingleEditorFrameTabBtn"..i);
		if t[key] then
			btn:Show();
			getglobal(btn:GetName().."Name"):SetText(GetS(t[key].Name_StringID));
		else
			btn:Hide();
		end
	end
	UpdateNewSingleEditorTabState(1);
end

function UpdateNewSingleEditorTabState(index)
	for i=1, 3 do
		local bkg = getglobal("NewSingleEditorFrameTabBtn"..i.."Bkg");
		local name = getglobal("NewSingleEditorFrameTabBtn"..i.."Name");

		if i == index then
			bkg:Show();
			name:SetTextColor(102, 76, 43);
		else
			bkg:Hide();
			name:SetTextColor(156, 126, 89);
		end
	end

	CurTabIndex = index;
	if CurTabIndex == 1 then
		getglobal("NewSingleEditorFrameTab1Frame"):Show();
	else
		getglobal("NewSingleEditorFrameTab1Frame"):Hide();
	end
end

function InitNewSingleEditorAttrType()
	CurAttrTypeIndex = 1;
	if CurEditorClass == 'actor' then
		getglobal("NewSingleEditorFrameTab1Frame"):Show();
	end
	local t = new_modeditor.config[CurEditorClass].tab1;
	for i=1, 2 do
		local key = "attrtype"..i;
		local btn = getglobal("NewSingleEditorFrameTab1FrameSetAttrType"..i);
		if t[key] then
			btn:Show();
			getglobal(btn:GetName().."Name"):SetText(GetS(t[key].Name_StringID));
		else
			btn:Hide();
		end
	end
	UpdateNewSingleEditorAttrTypeState();
end

function UpdateNewSingleEditorAttrTypeState()
	for i=1, 2 do
		local bkg = getglobal("NewSingleEditorFrameTab1FrameSetAttrType"..i.."Bkg");
		local check = getglobal("NewSingleEditorFrameTab1FrameSetAttrType"..i.."Checked");
		local name = getglobal("NewSingleEditorFrameTab1FrameSetAttrType"..i.."Name");

		if i == CurAttrTypeIndex then
			bkg:Hide();
			check:Show();
			name:SetTextColor(108, 75, 59);
		else
			bkg:Show();
			check:Hide();
			name:SetTextColor(179, 147, 105);
		end
	end
end

function NewSingleEditInfotNameEdit_OnTabPressed()
	SetCurEditBox("NewSingleEditorFrameTab1FrameInfoDescEdit");
end

function NewSingleEditInfoDescEdit_OnFocusLost()
	local text = this:GetText();
	this:SetText("");
	SingleEditDesc = text;
	getglobal("NewSingleEditorFrameTab1FrameInfoDescTip"):Show();
	if text == "" then
		getglobal("NewSingleEditorFrameTab1FrameInfoDescTip"):SetText(GetS(3959), 185, 185, 185);
	else
		getglobal("NewSingleEditorFrameTab1FrameInfoDescTip"):SetText(text, 185, 185, 185);
	end
end

function NewSingleEditInfoDescEdit_OnFocusGained()
	this:Show();
	this:SetText(SingleEditDesc);
	getglobal("NewSingleEditorFrameTab1FrameInfoDescTip"):Hide();
end

function NewSingleEditInfoDescEdit_OnTabPressed()
	SetCurEditBox("NewSingleEditorFrameTab1FrameInfoNameEdit");
end

function InitNewSingleEditorBaseInfo()
	if CurrentEditDef == nil then return end
	SingleEditDesc = CurrentEditDef.Desc;
	if SingleEditDesc == "" then
		getglobal("NewSingleEditorFrameTab1FrameInfoDescTip"):SetText(GetS(3959), 185, 185, 185);
	else
		getglobal("NewSingleEditorFrameTab1FrameInfoDescTip"):SetText(SingleEditDesc, 185, 185, 185);
	end	
	getglobal("NewSingleEditorFrameTab1FrameInfoNameEdit"):SetText(CurrentEditDef.Name);
	
	local modelView = getglobal("EditorModelView");
	local editorIcon = getglobal("SingleEditorIcon");
	
	if CurEditorClass == 'block' then		
		getglobal("NewSingleEditorFrameTab1FrameInfoSelModeBtn"):Hide();
		getglobal("NewSingleEditorFrameTab1FrameInfoReelectModeBtn"):Show()
			
		modelView:Hide();
		editorIcon:Show();
		
		SetItemIcon(editorIcon, CurrentEditDef.ID);

		local itemDef = ModEditorMgr:getBlockItemDefById(CurrentEditDef.ID)
		if itemDef == nil then
			itemDef = ModEditorMgr:getItemDefById(CurrentEditDef.ID)
		end
		if itemDef == nil then
			itemDef = ItemDefCsv:get(CurrentEditDef.ID)
		end
		
		getglobal("NewSingleEditorFrameTab1FrameInfoNameEdit"):SetText(itemDef.Name);
		if itemDef.Desc == "" then
			getglobal("NewSingleEditorFrameTab1FrameInfoDescTip"):SetText(GetS(3959), 185, 185, 185);
		else
			getglobal("NewSingleEditorFrameTab1FrameInfoDescTip"):SetText(itemDef.Desc, 185, 185, 185);
			SingleEditDesc = itemDef.Desc
		end
	elseif CurEditorClass == 'actor' then
		editorIcon:Hide();
		modelView:Show();
		if CurrentEditDef.ID == 4000 then		--默认
			getglobal("NewSingleEditorFrameTab1FrameInfoSelModeBtn"):Show();
			getglobal("NewSingleEditorFrameTab1FrameInfoReelectModeBtn"):Hide();
		else
			getglobal("NewSingleEditorFrameTab1FrameInfoSelModeBtn"):Hide();
			getglobal("NewSingleEditorFrameTab1FrameInfoReelectModeBtn"):Show();
	
			local body = UIActorBodyManager:getMonsterBody(CurrentEditDef.ID);
			if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
				modelView:attachActorBody(body)
			else
				body:attachUIModelView(modelView);
			end
		 	if string.len(CurrentEditDef.Texture) > 1 and string.find(CurrentEditDef.Texture, "%$") ~= nil then
		    	local path = ModEditorMgr:getCurrentEditModPath().."/resource/textures/entity/" ..string.sub( CurrentEditDef.Texture,2, -1)..".png";
			 	body:setCustomDiffuseTexture(path);
		    end 
		end
	elseif CurEditorClass == 'item' then
		modelView:Hide();
		if CurrentEditDef.ID == 10100 then		--默认
			getglobal("NewSingleEditorFrameTab1FrameInfoSelModeBtn"):Show();
			getglobal("NewSingleEditorFrameTab1FrameInfoReelectModeBtn"):Hide();
			editorIcon:Hide();
		else
			getglobal("NewSingleEditorFrameTab1FrameInfoSelModeBtn"):Hide();
			getglobal("NewSingleEditorFrameTab1FrameInfoReelectModeBtn"):Show()

			editorIcon:Show();
			SetItemIcon(editorIcon, CurrentEditDef.ID);
		end
	end
end

function InitItemTypeConfig()
	print('InitItemTypeConfig', CurEditorIsCopied, CurrentEditDef.CopyID)
	--[[
	local t_Key = {"IsDefTool", "IsDefProjectile", "IsDefFood", "IsDefGun"}
	for i=1, #(t_Key) do
		local key = t_Key[i];
		local lineKey = key.."Line";

		local t = new_modeditor.GetTableToENName(new_modeditor.config.item.tab1.attrtype1.Attr, key);
		local tLine = new_modeditor.GetTableToENName(new_modeditor.config.item.tab1.attrtype1.Attr, lineKey);
		if t then
			t.NotShow = (not CurEditorIsCopied and CurrentEditDef.CopyID <= 0);	--非新增的
			if tLine then
				tLine.NotShow = t.NotShow;
			end
		end
	end
	
	--工具
	local t = new_modeditor.GetTableToENName(new_modeditor.config.item.tab1.attrtype1.Attr, "IsDefTool");
	local tLine = new_modeditor.GetTableToENName(new_modeditor.config.item.tab1.attrtype1.Attr, "IsDefToolLine");
	if t then
		t.NotShow = (not CurEditorIsCopied and CurrentEditDef.CopyID <= 0);	--非新增的道具
		if tLine then
			tLine.NotShow = t.NotShow;
		end
	end
	--投射物
	t = new_modeditor.GetTableToENName(new_modeditor.config.item.tab1.attrtype1.Attr, "IsDefProjectile");
	tLine = new_modeditor.GetTableToENName(new_modeditor.config.item.tab1.attrtype1.Attr, "IsDefProjectileLine");
	if t then
		t.NotShow = (not CurEditorIsCopied and CurrentEditDef.CopyID <= 0);
		if tLine then
			tLine.NotShow = t.NotShow;
		end
	end
	--食物
	t = new_modeditor.GetTableToENName(new_modeditor.config.item.tab1.attrtype1.Attr, "IsDefFood");
	if t then
		t.NotShow = (not CurEditorIsCopied and CurrentEditDef.CopyID <= 0);
	end
	--枪
	t = new_modeditor.GetTableToENName(new_modeditor.config.item.tab1.attrtype1.Attr, "IsDefGun");
	if t then
		t.NotShow = (not CurEditorIsCopied and CurrentEditDef.CopyID <= 0);
	end
	]]
end

--class 1 -block 2 -actor 3 -item
function SetNewSingleEditorFrame(class, def, isCopy)
    print("kekeke SetNewSingleEditorFrame", isCopy)
	ModelRelevantID = 0;
	ModelRelevantName = "";
	CurrentEditDef = def;
	CurEditorIsCopied = isCopy;
	CurEditorClass = class;
    GetFeatureTable().TempForeignIds = {}

	if CurEditorIsCopied then
		CurrentEditDef.EnglishName = os.time();
		getglobal("NewSingleEditorFrameTips"):Show();
		if class == 'block' then
		elseif class == 'actor' then
			getglobal("NewSingleEditorFrameTips"):SetText( GetS(3679) );
		elseif class == 'item' then
			getglobal("NewSingleEditorFrameTips"):SetText( GetS(4548) );
		end
	else
		getglobal("NewSingleEditorFrameTips"):Hide();
	end
	if class == 'block' then
	elseif class == 'actor' then
	elseif class == 'item' then
		InitItemTypeConfig();
	end

	InitNewSingleEditorTab();
	InitNewSingleEditorAttrType();
	InitNewSingleEditorBaseInfo();
	if class == 'block' then
		getglobal("NewSingleEditorFrameTitle"):SetText(GetS(3973, GetS(3931)), 255, 245, 245);
		getglobal("NewSingleEditorFrameTab1FrameInfoIntroductBtn"):Hide();		
	elseif class == 'actor' then
		getglobal("NewSingleEditorFrameTitle"):SetText(GetS(3973, GetS(3932)), 255, 245, 245);
		getglobal("NewSingleEditorFrameTab1FrameInfoIntroductBtn"):Show();
	elseif class == 'item' then
		getglobal("NewSingleEditorFrameTitle"):SetText(GetS(3973, GetS(3933)), 255, 245, 245);
		getglobal("NewSingleEditorFrameTab1FrameInfoIntroductBtn"):Hide();
	end

	new_modeditor.Init(class, CurrentEditDef);
	SetModBoxsDeals(false);
	UpdateNewSingleEditorAttr();
	getglobal("NewSingleEditBox"):resetOffsetPos();
	getglobal("NewSingleEditorFrame"):Show();
end

function SetSingleEditorDealMsg(state)
	getglobal("NewSingleEditBox"):setDealMsg(state);
	getglobal("SingleEditorAttrBox"):setDealMsg(state);
end

function SingleEditorSave(editDef)
	local t_info = { mod_desc={}, property={}, foreign_ids={}};
	local name = getglobal("NewSingleEditorFrameTab1FrameInfoNameEdit"):GetText();
	t_info.property["name"] = name;
	editDef.Name = name;

	if CurEditorClass == 'item' then
		t_info.property["describe"] = SingleEditDesc;
	else
		t_info.property["desc"] = SingleEditDesc;
	end
	editDef.Desc = SingleEditDesc;

    t_info.property["id"] = editDef.ID;
	if CurEditorIsCopied or editDef.CopyID > 0 then
		t_info.property["copyid"] = editDef.CopyID;
	end

    -- 插件描述信息
    if string.len(editDef.ModDescInfo.version) == 0 then
        t_info.mod_desc["version"] = ModMgr:getCurUserModVersion()
    else
        t_info.mod_desc["version"] = editDef.ModDescInfo.version
    end
    if string.len(editDef.ModDescInfo.author) == 0 then
        t_info.mod_desc["author"] = AccountManager:getUin()
    else
        t_info.mod_desc["author"] = editDef.ModDescInfo.author
    end
    if string.len(editDef.ModDescInfo.uuid) == 0 then
        t_info.mod_desc["uuid"] = ModEditorMgr:getCurrentEditModDesc().uuid
    else
        t_info.mod_desc["uuid"] = editDef.ModDescInfo.uuid
    end
    if string.len(editDef.ModDescInfo.filename) == 0 then
        t_info.mod_desc["filename"] = CurrentEditDef.EnglishName
    else
        t_info.mod_desc["filename"] = editDef.ModDescInfo.filename
    end
	if CurEditorClass == 'actor' then
		--icon
		if ModelRelevantID > 0 then
			editDef.Icon = tostring(ModelRelevantID);
			t_info.property["icon"] = tostring(ModelRelevantID);
		elseif CurrentEditDef.Icon and CurrentEditDef.Icon ~= "" then
			editDef.Icon = CurrentEditDef.Icon;
			t_info.property["icon"] = CurrentEditDef.Icon;
		elseif CurEditorIsCopied then
			editDef.Icon = tostring(CurrentEditDef.ID);
			t_info.property["icon"] = tostring(CurrentEditDef.ID);
		end
		--model
		if ModelRelevantID > 0 then
			local monsterDef = MonsterCsv:get(ModelRelevantID);
			if monsterDef then
				editDef.Model = monsterDef.Model;
				t_info.property["model"] = monsterDef.Model;
			end
		elseif CurrentEditDef.CopyID > 0 then
			editDef.Model = CurrentEditDef.Model;
			t_info.property["model"] = CurrentEditDef.Model;
		end
		--AI	
		local t_AI = GetEditAIInfo();
		if #(t_AI) > 0 then
			t_info.set_ai = t_AI;
		end

	elseif CurEditorClass == 'item' then
		--icon
		if ModelRelevantID > 0 then
			editDef.Icon = "*"..ModelRelevantID;
			t_info.property["icon"] = "*"..ModelRelevantID;
		elseif CurrentEditDef.Icon and CurrentEditDef.Icon ~= "" and string.find(CurrentEditDef.Icon, "%*") then
			editDef.Icon = CurrentEditDef.Icon;
			t_info.property["icon"] = CurrentEditDef.Icon;
		elseif CurEditorIsCopied then
			editDef.Icon = "*"..CurrentEditDef.ID;
			t_info.property["icon"] = "*"..CurrentEditDef.ID;
		end
		--model
		if ModelRelevantID > 0 then
			editDef.Model = "*"..ModelRelevantID;
			t_info.property["model"] = "*"..ModelRelevantID;
		elseif CurrentEditDef.Model and CurrentEditDef.Model ~= "" and string.find(CurrentEditDef.Model, "%*") then
			editDef.Model = CurrentEditDef.Model;
			t_info.property["model"] = CurrentEditDef.Model;
		elseif CurEditorIsCopied then
			editDef.Model = "*"..CurrentEditDef.ID;
			t_info.property["model"] = "*"..CurrentEditDef.ID;
		end
	end

	for i=1, 2 do
		local attrTypeKey = "attrtype"..i;
		local t = new_modeditor.config[CurEditorClass].tab1[attrTypeKey];
		if t then
			t = t.Attr;
			for j=1, #(t) do
				if t[j].AddDef and t[j].CurVal then
					t[j].AddDef(t[j].CurVal, editDef.ID, editDef.CopyID);
				end

				if t[j].Save then
					t[j].Save(t[j], editDef, t_info.property);
				elseif t[j].ENName and t[j].JsonName then
					editDef[t[j].ENName] = t[j].CurVal;
					t_info.property[t[j].JsonName] = tonumber(t[j].CurVal) or t[j].CurVal;
				end
			end
		end
	end

    -- 保存外部ID
	if CurEditorClass == 'actor' then
        --保存特性AI的外部ID
        for i=1,#(GetFeatureTable().TempForeignIds) do
            ModEditorMgr:setActorForeignId(editDef, TempForeignIds[i].id, TempForeignIds[i].key)
        end
        t_info.foreign_ids = loadstring("return "..ModEditorMgr:getActorForeignIds(editDef))()
    elseif CurEditorClass == 'item' then
        t_info.foreign_ids = loadstring("return "..ModEditorMgr:getItemForeignIds(editDef))()
    end

	local dataStr = JSON:encode(t_info);

	print("kekeke NewGetEditorInfo dataStr", dataStr);
	return dataStr;
end

-- 针对block的特殊性函数（一部分属性保存在block结构体中，一部分属性保存在item中）
function SingleEditorSaveBlockExtend(blockDef, itemDef)
	local t_info_block = { property={} };
	local t_info_item = { property={} };
	local name = getglobal("NewSingleEditorFrameTab1FrameInfoNameEdit"):GetText();
	
	t_info_item.property["name"] = name;
	t_info_item.property["describe"] = SingleEditDesc;
	t_info_item.property["desc"] = SingleEditDesc;
	itemDef.Name = name;
	itemDef.Desc = SingleEditDesc;

	if CurEditorIsCopied then
		local id = CurrentEditDef.CopyID > 0 and CurrentEditDef.CopyID or CurrentEditDef.ID
		local itemDefSrc = ModEditorMgr:getItemDefById(CurrentEditDef.ID)
		blockDef.CopyID = id
		blockDef.ItemID = itemDef.ID
		itemDef.CopyID = id
	end
	t_info_block.property["english_name"] = CurrentEditDef.EnglishName

	if blockDef.CopyID > 0 then
		t_info_block.property["copyid"] = blockDef.CopyID
		t_info_item.property["copyid"] =  blockDef.CopyID
	else
		t_info_block.property["id"] = blockDef.ID
		t_info_item.property["id"] = itemDef.ID
	end
	
	--icon
	if ModelRelevantName ~= "" then
		blockDef.Texture2 = ModelRelevantName;
		t_info_item.property["custommodel"] = ModelRelevantName;
	elseif ModelRelevantID > 0 then
		itemDef.Icon = "*"..ModelRelevantID;
		t_info_item.property["icon"] = "*"..ModelRelevantID;
	elseif CurrentEditDef.Icon and CurrentEditDef.Icon ~= "" and string.find(CurrentEditDef.Icon, "%*") then
		itemDef.Icon = CurrentEditDef.Icon;
		t_info_item.property["icon"] = CurrentEditDef.Icon;
	elseif CurEditorIsCopied then
		local id = CurrentEditDef.CopyID > 0 and CurrentEditDef.CopyID or CurrentEditDef.ID
		local itemDefSrc = ModEditorMgr:getBlockItemDefById(CurrentEditDef.ID)
		if itemDefSrc == nil then
			itemDefSrc = ModEditorMgr:getItemDefById(CurrentEditDef.ID)
		end
		if itemDefSrc == nil then
			itemDefSrc = ItemDefCsv:get(CurrentEditDef.ID)
		end
		if itemDefSrc and itemDefSrc.Icon ~= "" then
			itemDef.Icon = itemDefSrc.Icon;
			t_info_item.property["icon"] = itemDefSrc.Icon;
		else
			itemDef.Icon = "*"..id;
			t_info_item.property["icon"] = "*"..id;
		end
	else
		t_info_item.property["icon"] = itemDef.Icon;
	end
	--model
	if ModelRelevantID > 0 then
		itemDef.Model = "*"..ModelRelevantID;
		t_info_item.property["model"] = "*"..ModelRelevantID;
	elseif CurrentEditDef.Model and CurrentEditDef.Model ~= "" and string.find(CurrentEditDef.Model, "%*") then
		itemDef.Model = CurrentEditDef.Model;
		t_info_item.property["model"] = CurrentEditDef.Model;
	elseif CurEditorIsCopied then
		local id = CurrentEditDef.CopyID > 0 and CurrentEditDef.CopyID or CurrentEditDef.ID
		local itemDefSrc = ModEditorMgr:getBlockItemDefById(CurrentEditDef.ID)
		if itemDefSrc == nil then
			itemDefSrc = ModEditorMgr:getItemDefById(CurrentEditDef.ID)
		end
		if itemDefSrc == nil then
			itemDefSrc = ItemDefCsv:get(CurrentEditDef.ID)
		end
		if itemDefSrc and itemDefSrc.Icon ~= "" then
			itemDef.Model = itemDefSrc.Model;
			t_info_item.property["model"] = itemDefSrc.Model;
		else
			itemDef.Model = "*"..id;
			t_info_item.property["model"] = "*"..id;
		end
	else
		t_info_item.property["model"] = itemDef.Model;
	end
		

	for i=1, 2 do
		local attrTypeKey = "attrtype"..i;
		local t = new_modeditor.config[CurEditorClass].tab1[attrTypeKey];
		if t then
			t = t.Attr;
			for j=1, #(t) do
				if t[j].AddDef and t[j].CurVal then
					t[j].AddDef(t[j].CurVal, blockDef.ID, blockDef.CopyID);
				end

				if t[j].Save then
					t[j].Save(t[j], blockDef, t_info_block.property);
				elseif t[j].ENName and t[j].JsonName then
					blockDef[t[j].ENName] = t[j].CurVal;
					t_info_block.property[t[j].JsonName] = tonumber(t[j].CurVal) or t[j].CurVal;
				end
			end
		end
	end

	return JSON:encode(t_info_block), JSON:encode(t_info_item);
end

--修改地图插件库时使用了微雕，点保存的时候要把使用的微雕文件拷贝到相对应的地图目录下
function CheckCopyCustomFileToMap(modelfilename, modelType, fileName)
	--[[
	local mod = ModEditorMgr:getCurrentEditMod();
	if not mod then return end

	local dir = mod:getModDirTolua();
	local startPos = string.find(dir, "data/w");
	if not startPos then return end

	local endPos = string.find(dir, "/mods");
	if not endPos then return end

	local owid = tonumber(string.sub(dir, startPos+6, endPos-1));
	if not owid then return end

	if modelType and modelType >= FULLY_BLOCK_MODEL then
		FullyCustomModelMgr:copyModelFileByMod(owid, modelfilename);
	elseif modelType and modelType >= IMPORT_BLOCK_MODEL and modelType <= IMPORT_MODEL_MAX then
		ImportCustomModelMgr:copyModelFileByMod(owid, modelfilename)
	else
		CustomModelMgr:copyModelFileByMod(owid, modelfilename, modelType==ACTOR_MODEL);
	end
	]]

	local mod = ModEditorMgr:getCurrentEditMod();
	if not mod then return end

	local saveRef = false;
	local dir = mod:getModDirTolua();
	local startPos = string.find(dir, "modpkg");
	if not startPos then
		startPos = string.find(dir, "data/w");
		if not startPos then
			return
		end

		local endPos = string.find(dir, "/mods");
		if not endPos then
			return
		end

		dir = string.sub(dir, startPos, endPos);
		mod = nil;
	else
		dir = dir.."/resource/";
		--savedownload = false;
		saveRef = true;
		if mod then
			mod:addCustomModelByMod(modelType, modelfilename, fileName)
		end
	end

	local _owid = -1;
    if CurWorld then _owid = CurWorld:getOWID() end;

	if modelType and modelType >= FULLY_BLOCK_MODEL then
		FullyCustomModelMgr:copyModelFileByModDir(dir, modelfilename, mod,_owid);
	elseif modelType and modelType >= IMPORT_BLOCK_MODEL and modelType <= IMPORT_MODEL_MAX then
		ImportCustomModelMgr:copyModelFileByModDir(dir, modelfilename, mod,_owid)
	else
		CustomModelMgr:copyModelFileByModDir(dir, modelfilename, modelType==ACTOR_MODEL, CUSTOM_MODEL_TYPE, mod,_owid);
	end

	if mod and saveRef then
		mod:saveCusomModelRef()
	end
end

function SingleEditorSaveBlockExtend2(blockDef, itemDef, fileName)
	local t_info_block = { mod_desc={}, property={}, item_property={}, foreign_ids={}};
	local name = getglobal("SingleEditorFrameBaseSetCommonNameEdit"):GetText();		--LLDO:新的

	--多语言支持, 保存多语言格式json.
	local dataStructName = SignManagerGetInstance():GetDataStructForSave("mod_base_name");
	local MultiLangName = JSON:encode(dataStructName);
	local dataStructDesc = SignManagerGetInstance():GetDataStructForSave("mod_base_desc");
	local MultiLangDesc = JSON:encode(dataStructDesc);
	t_info_block.item_property["multilangname"] = MultiLangName;
	t_info_block.item_property["multilangdesc"] = MultiLangDesc;
	CurrentEditDef.MultiLangName = MultiLangName;
	CurrentEditDef.MultiLangDesc = MultiLangDesc;

	t_info_block.item_property["name"] = name;
	t_info_block.item_property["describe"] = SingleEditDesc;
	t_info_block.item_property["desc"] = SingleEditDesc;
	itemDef.Name = name;
	itemDef.Desc = SingleEditDesc;

	if CurEditorIsCopied then
		local id = CurrentEditDef.CopyID > 0 and CurrentEditDef.CopyID or CurrentEditDef.ID
		local itemDefSrc = ModEditorMgr:getItemDefById(CurrentEditDef.ID)
		blockDef.CopyID = id
		blockDef.ItemID = itemDef.ID
		itemDef.CopyID = id
	end
	t_info_block.property["english_name"] = fileName; --CurrentEditDef.EnglishName

    -- 插件描述信息
    if string.len(itemDef.ModDescInfo.version) == 0 then
        t_info_block.mod_desc["version"] = ModMgr:getCurUserModVersion()
    else
        t_info_block.mod_desc["version"] = itemDef.ModDescInfo.version
    end
    if string.len(itemDef.ModDescInfo.author) == 0 then
        t_info_block.mod_desc["author"] = AccountManager:getUin()
    else
        t_info_block.mod_desc["author"] = itemDef.ModDescInfo.author
    end
    if string.len(itemDef.ModDescInfo.uuid) == 0 then
        t_info_block.mod_desc["uuid"] = ModEditorMgr:getCurrentEditModDesc().uuid
    else
        t_info_block.mod_desc["uuid"] = itemDef.ModDescInfo.uuid
    end
    if string.len(itemDef.ModDescInfo.filename) == 0 then
        t_info_block.mod_desc["filename"] = CurrentEditDef.EnglishName
    else
        t_info_block.mod_desc["filename"] = itemDef.ModDescInfo.filename
    end

    t_info_block.property["id"] = itemDef.ID
    t_info_block.item_property["id"] = itemDef.ID
	if blockDef.CopyID > 0 then
		t_info_block.property["copyid"] = blockDef.CopyID
		t_info_block.item_property["copyid"] =  blockDef.CopyID
	end
	--原来选择了微缩，现在新选了模型,移除引用和资源
	if (itemDef.Icon == "customblock" or itemDef.Icon == "fullycustomblock" or itemDef.Icon == "importcustomblock" ) and 
		(ModelRelevantName ~= "" or ModelRelevantID > 0)  then
		local mod = ModEditorMgr:getCurrentEditMod();
		if mod then
			mod:removeCustomModelByMod(fileName);
		end
	end
	
	if ModelRelevantName == "" and ModelRelevantID > 0 then
		local originBlockDef = BlockDefCsv:getOrigin(ModelRelevantID)
		if originBlockDef then
			blockDef.Texture2 = originBlockDef.Texture2
		else
			print("Error  sss originBlockDef is nil " )
		end
	end
	--icon
	if ModelRelevantName ~= "" then
		blockDef.Texture2 = ModelRelevantName;
		if ModelRelevantID == -1 then
			t_info_block.property["fullycustommodel"] = ModelRelevantName;
			t_info_block.item_property["icon"] = "fullycustomblock";
			t_info_block.item_property["model_type"] = FULLY_CUSTOM_GEN_MESH;
			t_info_block.item_property["fullycustommodel"] = ModelRelevantName;

			itemDef.Icon = "fullycustomblock";
			itemDef.MeshType = FULLY_CUSTOM_GEN_MESH;
			itemDef.Model = ModelRelevantName
			blockDef.Type = "fullycustomblock";
			CheckCopyCustomFileToMap(ModelRelevantName, FULLY_BLOCK_MODEL, fileName);
		elseif ModelRelevantID == -2 then -- 导入模型
			t_info_block.property["importcustommodel"] = ModelRelevantName;
			t_info_block.item_property["icon"] = "importcustomblock";
			t_info_block.item_property["model_type"] = IMPORT_MODEL_GEN_MESH;
			t_info_block.item_property["importcustommodel"] = ModelRelevantName;

			itemDef.Icon = "importcustomblock";
			itemDef.MeshType = IMPORT_MODEL_GEN_MESH;
			itemDef.Model = ModelRelevantName
			blockDef.Type = "importmodel";
			CheckCopyCustomFileToMap(ModelRelevantName, IMPORT_BLOCK_MODEL, fileName);
		else
			t_info_block.property["custommodel"] = ModelRelevantName;
			itemDef.Icon = "customblock";
			t_info_block.item_property["icon"] = "customblock";
			blockDef.Type = "custombasic";
			CheckCopyCustomFileToMap(ModelRelevantName, BLOCK_MODEL, fileName);
		end
		
	elseif ModelRelevantID > 0 then
		itemDef.Icon = "*"..ModelRelevantID;
		if ModelRelevantID ~= itemDef.ID then
			t_info_block.item_property["icon"] = "*"..ModelRelevantID;
		end
	elseif itemDef.Icon == "customblock" then
		t_info_block.item_property["icon"] = itemDef.Icon ;
		t_info_block.property["custommodel"] = blockDef.Texture2;
	elseif itemDef.Icon == "fullycustomblock" then
		t_info_block.item_property["icon"] = itemDef.Icon ;
		t_info_block.item_property["model_type"] = FULLY_CUSTOM_GEN_MESH;
		t_info_block.property["fullycustommodel"] = blockDef.Texture2;
		t_info_block.item_property["fullycustommodel"] = itemDef.Model;
	elseif itemDef.Icon == "importcustomblock" then
		t_info_block.item_property["icon"] = itemDef.Icon ;
		t_info_block.item_property["model_type"] = IMPORT_MODEL_GEN_MESH;
		t_info_block.property["importcustommodel"] = blockDef.Texture2;
		t_info_block.item_property["importcustommodel"] = itemDef.Model;
	elseif CurrentEditDef.Icon and CurrentEditDef.Icon ~= "" and string.find(CurrentEditDef.Icon, "%*") then
		itemDef.Icon = CurrentEditDef.Icon;
		t_info_block.item_property["icon"] = CurrentEditDef.Icon;
	elseif CurEditorIsCopied then
		local id = CurrentEditDef.CopyID > 0 and CurrentEditDef.CopyID or CurrentEditDef.ID
		local itemDefSrc = ModEditorMgr:getBlockItemDefById(CurrentEditDef.ID)
		if itemDefSrc == nil then
			itemDefSrc = ModEditorMgr:getItemDefById(CurrentEditDef.ID)
		end
		if itemDefSrc == nil then
			itemDefSrc = ItemDefCsv:get(CurrentEditDef.ID)
		end
		if itemDefSrc and itemDefSrc.Icon ~= "" then
			itemDef.Icon = itemDefSrc.Icon;
			t_info_block.item_property["icon"] = itemDefSrc.Icon;
		else
			itemDef.Icon = "*"..id;
			t_info_block.item_property["icon"] = "*"..id;
		end
	else
		t_info_block.item_property["icon"] = itemDef.Icon;
	end
	--model
	if ModelRelevantID > 0 then
		itemDef.Model = "*"..ModelRelevantID;
		t_info_block.item_property["model"] = "*"..ModelRelevantID;

		--TODO:
		local icondef = BlockDefCsv:get(ModelRelevantID)
		if icondef then
			-- itemDef.Height = icondef.Height
			-- itemDef.Texture1 = icondef.Texture1
			-- itemDef.Texture2 = icondef.Texture2
			-- itemDef.SrcID = ModelRelevantID
			-- itemDef.Type = icondef.Type

			blockDef.Height = icondef.Height
			blockDef.Texture1 = icondef.Texture1
			blockDef.Texture2 = icondef.Texture2
			blockDef.Type = icondef.Type
			blockDef.SrcID = ModelRelevantID
		end
	elseif CurrentEditDef.Model and CurrentEditDef.Model ~= "" and string.find(CurrentEditDef.Model, "%*") then
		itemDef.Model = CurrentEditDef.Model;
		t_info_block.item_property["model"] = CurrentEditDef.Model;
	elseif CurEditorIsCopied then
		local id = CurrentEditDef.CopyID > 0 and CurrentEditDef.CopyID or CurrentEditDef.ID
		local itemDefSrc = ModEditorMgr:getBlockItemDefById(CurrentEditDef.ID)
		if itemDefSrc == nil then
			itemDefSrc = ModEditorMgr:getItemDefById(CurrentEditDef.ID)
		end
		if itemDefSrc == nil then
			itemDefSrc = ItemDefCsv:get(CurrentEditDef.ID)
		end
		if itemDefSrc and itemDefSrc.Icon ~= "" then
			itemDef.Model = itemDefSrc.Model;
			t_info_block.item_property["model"] = itemDefSrc.Model;
		else
			itemDef.Model = "*"..id;
			t_info_block.item_property["model"] = "*"..id;
		end
	else
		t_info_block.item_property["model"] = itemDef.Model;
	end

	--[[:LLDO:old
	for i=1, 2 do
		local attrTypeKey = "attrtype"..i;
		local t = new_modeditor.config[CurEditorClass].tab1[attrTypeKey];
		if t then
			t = t.Attr;
			for j=1, #(t) do
				if t[j].AddDef and t[j].CurVal then
					t[j].AddDef(t[j].CurVal, blockDef.ID, blockDef.CopyID);
				end

				if t[j].Save then
					t[j].Save(t[j], blockDef, t_info_block.property);
				elseif t[j].ENName and t[j].JsonName then
					blockDef[t[j].ENName] = t[j].CurVal;
					t_info_block.property[t[j].JsonName] = tonumber(t[j].CurVal) or t[j].CurVal;
					Log("SingleEditorSaveBlockExtend2: ENName = " .. t[j].ENName .. ", CurVal = " .. t[j].CurVal);
				end
			end
		end
	end
	]]

	---[[LLDO:new
	for i=1, 5 do
		local t = modeditor.config[CurEditorClass][i];
		if t and t.Attr then
			t = t.Attr;
			for j=1, #(t) do
                --AddDef
                if CurEditorClass ~= 'actor' and t[j].Type == 'NoUI' and t[j].AddDef then
				    t[j].AddDef(t[j].CurVal, blockDef.ID, blockDef.CopyID);
				end

                --Save
				if t[j].Save then
					Log("SingleEditorSaveBlockExtend2:1111");
					if t[j].SaveType == 'AI' then
						t[j].Save(t[j], t_info_block.set_ai);
					elseif t[j].SaveType == 'DefAndAI' then
						t[j].Save(t[j], blockDef, t_info_block.property, t_info_block.set_ai);
					else
                        t[j].Save(t[j], blockDef, t_info_block.property);
					end
				elseif t[j].ENName and t[j].JsonName then
					blockDef[t[j].ENName] = t[j].CurVal;
					t_info_block.property[t[j].JsonName] = tonumber(t[j].CurVal) or t[j].CurVal;
					Log("SingleEditorSaveBlockExtend2: ENName = " .. t[j].ENName .. ", CurVal = " .. t[j].CurVal);
				end
			end
		end
	end
	---]]

    -- 保存外部ID
    t_info_block.foreign_ids = loadstring("return "..ModEditorMgr:getBlockForeignIds(blockDef))()
    t_info_block.item_property["orignid"] = itemDef.iOrignID
	return JSON:encode(t_info_block);
end

function NewGetEditorInfo()
	local t_info = { property={} };
	
	local name = getglobal("NewSingleEditorFrameTab1FrameInfoNameEdit"):GetText();
	t_info.property["name"] = name;
	t_info.property["desc"] = SingleEditDesc;

	local CurID = CurrentEditDef.ID;
	if CurrentEditDef.CopyID > 0 then
		t_info.property["copyid"] = CurrentEditDef.CopyID;
		CurID = CurrentEditDef.CopyID;
	elseif CurEditorIsCopied then
		t_info.property["copyid"] = CurrentEditDef.ID;
	else
		t_info.property["id"] = CurrentEditDef.ID;
	end

	for i=1, 2 do
		local attrTypeKey = "attrtype"..i;
		local t = new_modeditor.config[CurEditorClass].tab1[attrTypeKey];
		if t then
			t = t.Attr;
			for j=1, #(t) do
				if t[j].Save then
					local t_SaveInfo = t[j].Save(t[j].CurVal, CurID);
					if t_SaveInfo then
						for k,v in pairs(t_SaveInfo) do
							if v.JsonName then
								t_info.property[v.JsonName] = tonumber(v.Val) or v.Val;
							end
						end
					end
				elseif t[j].JsonName then
					t_info.property[t[j].JsonName] = tonumber(t[j].CurVal) or t[j].CurVal;
				elseif t[j].Boxes then
					for k=1, #(t[j].Boxes) do
						local val = tonumber(t[j].CurVal[k]) or t[j].CurVal[k];
						if t[j].ENName == 'Model' and t[j].Def == 'ProjectileDef' then
							local projectileDef = ProjectileDefCsv:get(tonumber(t[j].CurVal[k]));
							if projectileDef then
								t_info.property[t[j].Boxes[k].JsonName] = projectileDef.Model;
							elseif new_modeditor.MeetPremise(t[j].ShowPremise) then
								MessageBox(4, GetS(3682));
								return nil;
							end
						else
							t_info.property[t[j].Boxes[k].JsonName] = tonumber(t[j].CurVal[k]) or t[j].CurVal[k];
						end
					end				
				end
			end
		end
	end
	
	if CurEditorClass == 'actor' then
		--icon
		if ModelRelevantID > 0 then
			t_info.property["icon"] = tostring(ModelRelevantID);
		elseif CurrentEditDef.Icon and CurrentEditDef.Icon ~= "" then
			t_info.property["icon"] = tostring(CurrentEditDef.Icon);
		elseif CurrentEditDef.CopyID > 0 then
			t_info.property["icon"] = tostring(CurrentEditDef.CopyID);
		elseif CurEditorIsCopied then
			t_info.property["icon"] = tostring(CurrentEditDef.ID);
		end
		--model
		if ModelRelevantID > 0 then
			local monsterDef = MonsterCsv:get(ModelRelevantID);
			if monsterDef then
				t_info.property["model"] = monsterDef.Model;
			end
		elseif CurrentEditDef.CopyID > 0 then
			t_info.property["model"] = CurrentEditDef.Model;
		end

		local t_AI = GetEditAIInfo();
		
		if #(t_AI) > 0 then
			t_info.set_ai = t_AI;
		end
	elseif CurEditorClass == 'item' then
		--icon
		if ModelRelevantID > 0 then
			t_info.property["icon"] = "*"..ModelRelevantID;
		elseif CurrentEditDef.Icon and CurrentEditDef.Icon ~= "" and string.find(CurrentEditDef.Icon, "%*") then
			t_info.property["icon"] = CurrentEditDef.Icon;
		elseif CurrentEditDef.CopyID > 0 or CurEditorIsCopied then
			t_info.property["icon"] = "*"..CurrentEditDef.ID;
		end
		--model
		if ModelRelevantID > 0 then
			t_info.property["model"] = "*"..ModelRelevantID;
		elseif CurrentEditDef.Model and CurrentEditDef.Model ~= "" and string.find(CurrentEditDef.Model, "%*") then
			t_info.property["model"] = CurrentEditDef.Model;
		elseif CurrentEditDef.CopyID > 0 or CurEditorIsCopied then
			t_info.property["model"] = "*"..CurrentEditDef.ID;
		end
	end

	local dataStr = JSON:encode(t_info);

	print("kekeke NewGetEditorInfo dataStr", dataStr);
	return dataStr;
end

function GetEditAIInfo()
	local t_Ai ={};

	--DefaultAI
	local t_defaultAI = nil;
	if CurrentEditDef.CopyID > 0 then
		t_defaultAI = AIConfig[CurrentEditDef.CopyID];
	else
		t_defaultAI = AIConfig[CurrentEditDef.ID];
	end
	if t_defaultAI then
		for i=1, #(t_defaultAI) do
			local aiName = t_defaultAI[i].AI.name;
			if OpenAiTable[aiName] == nil then	--不可编辑的AI,直接保存
				table.insert(t_Ai, t_defaultAI[i].AI);
			end
		end
	end

	return t_Ai;
end

function NewSetEditorExtendDef(id, defName, attrName, val, index)
	local def = nil;
	
	if defName == 'ToolDef' then
		def = ModEditorMgr:getToolDefById(id);
	elseif defName == 'FoodDef' then
		def = ModEditorMgr:getFoodDefById(id);
	elseif defName == 'ProjectileDef' then
		def = ModEditorMgr:getProjectileDefById(id);
	elseif defName == 'GunDef' then
		def = ModEditorMgr:getGunDefById(id);
	end

	if def then
		if index then
			def[attrName][index] = val;
		else
			def[attrName] = val;
		end
	end
end

function NewSetEditorDef(editDef)
	TestNewGetEditorInfo(editDef);
	--[[
	local name = getglobal("NewSingleEditorFrameTab1FrameInfoNameEdit"):GetText();
	editDef.Name = name;
	editDef.Desc = SingleEditDesc;
	if CurEditorClass == 'actor' then
		--icon
		if ModelRelevantID > 0 then
			editDef.Icon = tostring(ModelRelevantID);
		elseif CurrentEditDef.Icon and CurrentEditDef.Icon ~= "" then
			editDef.Icon = CurrentEditDef.Icon;
		elseif CurEditorIsCopied then
			editDef.Icon = tostring(CurrentEditDef.ID);
		end
		--model
		local monsterId = 0;
		if ModelRelevantID > 0 then
			monsterId = tonumber(ModelRelevantID);
		elseif CurEditorIsCopied then
			if CurrentEditDef.CopyID > 0 then
				editDef.Model = CurrentEditDef.Model;
				monsterId = 0;
			else
				monsterId = CurrentEditDef.ID;
			end
		end
		if monsterId > 0 then
			local monsterDef = MonsterCsv:get(monsterId);
			if monsterDef then
				editDef.Model = monsterDef.Model;
			end
		end
	elseif CurEditorClass == 'item' then
		--icon
		if ModelRelevantID > 0 then
			editDef.Icon = "*"..ModelRelevantID;
		elseif CurrentEditDef.Icon and CurrentEditDef.Icon ~= "" and string.find(CurrentEditDef.Icon, "%*") then
			editDef.Icon = CurrentEditDef.Icon;
		elseif CurEditorIsCopied then
			editDef.Icon = "*"..CurrentEditDef.ID;
		end
		--model
		if ModelRelevantID > 0 then
			editDef.Model = "*"..ModelRelevantID;
		elseif CurrentEditDef.Model and CurrentEditDef.Model ~= "" and string.find(CurrentEditDef.Model, "%*") then
			editDef.Model = CurrentEditDef.Model;
		elseif CurEditorIsCopied then
			editDef.Model = "*"..CurrentEditDef.ID;
		end
	end

	for i=1, 2 do
		local attrTypeKey = "attrtype"..i;
		local t = new_modeditor.config[CurEditorClass].tab1[attrTypeKey];
		if t then
			t = t.Attr;
			for j=1, #(t) do
				if t[j].AddDef then
					t[j].AddDef(t[j].CurVal, editDef.ID);
				end

				if t[j].Save then
					local t_SaveInfo = t[j].Save(t[j].CurVal, editDef.ID);
					if t_SaveInfo then
						for k,v in pairs(t_SaveInfo) do
							if v.ENName then
								if t[j].Def and CurEditorClass == 'item' and t[j].Def ~= 'itemDef' then
									NewSetEditorExtendDef(editDef.ID, t[j].Def, v.ENName, v.Val)
								else
									editDef[v.ENName] = v.Val;
								end
							end
						end
					end
				elseif t[j].JsonName then
					if t[j].Def and CurEditorClass == 'item' and t[j].Def ~= 'itemDef' then
						print('JsonName', t[j].ENName, t[j].CurVal);
						NewSetEditorExtendDef(editDef.ID, t[j].Def, t[j].ENName, t[j].CurVal)
					else
						editDef[t[j].ENName] = t[j].CurVal;
					end
				elseif t[j].Boxes then
					for k=1, #(t[j].Boxes) do
						if t[j].ENName == 'Model' and t[j].Def == 'ProjectileDef' then
							local projectileDef = ProjectileDefCsv:get(t[j].CurVal[k]);
							if projectileDef then
								NewSetEditorExtendDef(editDef.ID, t[j].Def, t[j].ENName, projectileDef.Model)
							end
						elseif t[j].Boxes[k].ENName then
							if t[j].Def and CurEditorClass == 'item' and t[j].Def ~= 'itemDef' then
								NewSetEditorExtendDef(editDef.ID, t[j].Def, t[j].ENName, t[j].CurVal[k])
							else
								editDef[t[j].ENName] = t[j].CurVal[k];
							end
						else
							if t[j].Def and CurEditorClass == 'item' and t[j].Def ~= 'itemDef' then
								NewSetEditorExtendDef(editDef.ID, t[j].Def, t[j].ENName, t[j].CurVal[k], k-1)
							else
								editDef[t[j].ENName][k-1] = t[j].CurVal[k];
							end
						end
					end				
				end
			end
		end
	end
	]]
end

function SaveEditorSelAI(def, t_AI)
	ModEditorMgr:clearMonsterAIID(def.ID);
	for i=1, #(t_AI) do
		ModEditorMgr:saveMonsterAIID(def.ID, JSON:encode(t_AI[i]));
	end
end

function SaveEditorSelItemSkill(def, t_Item_Skill)
	ModEditorMgr:clearItemSkillID(def.ID);
	for i=1, #(t_Item_Skill) do
		--保存的时候要转换下格式
		ModEditorMgr:saveItemSkillID(def.ID, JSON:encode(t_Item_Skill[i]));
	end
end

function NewSingleEditorFrameSaveBtn_OnClick(isBack)
print("------------------------is me.")

	local defName = getglobal("NewSingleEditorFrameTab1FrameInfoNameEdit"):GetText();
	if CheckFilterString(defName) then return end
	if defName == "" then
		MessageBox(4, GetS(3936));
		return;
	end

	if CheckFilterString(SingleEditDesc) then return end

	local isCreate = false;  --is create or modify
	local success = false;

	if CurEditorClass == 'block' then
		isCreate = (ModEditorMgr:getBlockDefById(CurrentEditDef.ID) == nil);
		
		local def = nil
		local itemDef = nil
		local is_new = false
		if isCreate or CurEditorIsCopied then        
		    --local id = CurrentEditDef.CopyID > 0 and CurrentEditDef.CopyID or CurrentEditDef.ID;
			def = ModEditorMgr:addBlockDef(CurrentEditDef.ID, CurEditorIsCopied);
		else
			def = CurrentEditDef;
		end
		if def == nil then return; end
		
		--id = def.ItemID > 0 and def.ItemID or id;
		itemDef = ModEditorMgr:getBlockItemDefById(def.ID)
		if itemDef == nil then
			itemDef = ModEditorMgr:addBlockItemDef(CurrentEditDef.ID, def.ID);
            itemDef.ModDescInfo.filename = CurrentEditDef.EnglishName
			is_new = true
		end
		
        -- 新版方块item部分的数据和Block一起保存
		--local dataStr1, dataStr2 = SingleEditorSaveBlockExtend(def, itemDef);
        local dataStr = SingleEditorSaveBlockExtend2(def, itemDef);
		local result = ModEditorMgr:requestCreateBlock(dataStr, CurrentEditDef.EnglishName);
		if is_new and not (def.Name and string.len(def.Name) > 0) then
			--MessageBox(4, "dd00:"..CurrentEditDef.EnglishName)	
			def.Name = CurrentEditDef.EnglishName
		end
		--ModEditorMgr:requestCreateItem(dataStr2, CurrentEditDef.EnglishName);

		if result then
			ShowGameTips(GetS(3940), 3);
			success = true;

			if CurEditorIsCopied then
				def.EnglishName = CurrentEditDef.EnglishName;
				CurrentEditDef = def;
				CurEditorIsCopied = false;
			end

			UpdateEditorSlot();
		else
			ShowGameTips(GetS(3941), 3);
		end
	elseif CurEditorClass == 'actor' then
		if CurrentEditDef.ID == 4000 and ModelRelevantID == 0 then
			MessageBox(4, GetS(3643));
			return;
		end

		isCreate = (ModEditorMgr:getMonsterDefById(CurrentEditDef.ID) == nil);
		local def = nil;
		if isCreate or CurEditorIsCopied then
			--local id = CurrentEditDef.CopyID > 0 and CurrentEditDef.CopyID or CurrentEditDef.ID;
			def = ModEditorMgr:addMonsterDef(CurrentEditDef.ID, CurEditorIsCopied);
            def.ModDescInfo.filename = CurrentEditDef.EnglishName
		else
			def = CurrentEditDef;
		end
		if def == nil then return; end

		local dataStr = SingleEditorSave(def);
		local result = ModEditorMgr:requestCreateActor(dataStr, CurrentEditDef.EnglishName);
		if result then
			ShowGameTips(GetS(3940), 3);
			success = true;

			if CurEditorIsCopied then
				def.EnglishName = CurrentEditDef.EnglishName;
				CurrentEditDef = def;
				CurEditorIsCopied = false;
			end

			SaveEditorSelAI(def);
			UpdateEditorSlot();
		else
			ShowGameTips(GetS(3941), 3);
		end
	elseif CurEditorClass == 'item' then
		if CurrentEditDef.ID == 10100 and ModelRelevantID == 0 then
			MessageBox(4, GetS(3643));
			return;
		end
		
		isCreate = (ModEditorMgr:getItemDefById(CurrentEditDef.ID) == nil);
		local def = nil;
		if isCreate or CurEditorIsCopied then
			--local id = CurrentEditDef.CopyID > 0 and CurrentEditDef.CopyID or CurrentEditDef.ID;
			def = ModEditorMgr:addItemDef(CurrentEditDef.ID, CurEditorIsCopied);                  
            def.ModDescInfo.filename = CurrentEditDef.EnglishName
		else
			def = CurrentEditDef;
		end
		if def == nil then return end

		local dataStr = SingleEditorSave(def);
		local result = ModEditorMgr:requestCreateItem(dataStr, CurrentEditDef.EnglishName);
		if result then
			ShowGameTips(GetS(3940), 3);
			success = true;

			if CurEditorIsCopied then
				def.EnglishName = CurrentEditDef.EnglishName;
				CurrentEditDef = def;
				CurEditorIsCopied = false;
			end

			UpdateEditorSlot();
		else
			ShowGameTips(GetS(3941), 3);
		end
	end

	if isCreate then  --创建组件
		local componentType = CurEditorClass;

		local editmode = 0;
		local f1 = FrameStack.findLastFrame('MyModsEditorFrame');
		if f1 then
			editmode = f1.editmode;
		end

		local preveditmode = 0;
		local f0 = FrameStack.findLastFrameBefore('MyModsEditorFrame', f1);
		if f0 then
			preveditmode = f0.editmode;
		end

		-- statisticsGameEvent(503, '%s', componentType, '%d', editmode, '%d', preveditmode);

		if editmode == 1 then
			f1.haveModified = true;
		end
        
        -- 保存插件ID
        ModEditorMgr:requestSaveUserModAllocatedId()
	else  --修改组件

		local editmode = 0;
		local f1 = FrameStack.findLastFrame('MyModsEditorFrame');
		if f1 then
			editmode = f1.editmode;
		end
		if editmode == 1 then
			f1.haveModified = true;
		end
	end
	
	if success then
		local editorFrame = FrameStack.findLastFrame('MyModsEditorFrame');
		if editorFrame then
			editorFrame.blinkOnShow = {
				blockFileNames = iif(CurEditorClass=='block', {[CurrentEditDef.EnglishName]=true}, {}),
				actorFileNames = iif(CurEditorClass=='actor', {[CurrentEditDef.EnglishName]=true}, {}),
				itemFileNames = iif(CurEditorClass=='item', {[CurrentEditDef.EnglishName]=true}, {}),
			};
		end

		if isBack and editorFrame then
			getglobal("NewSingleEditorFrame"):Hide();
			getglobal("MyModsEditorFrame"):Show();
		end
	end
end

function NewSingleEditorFrameBackBtn_OnClick()
	getglobal("NewSingleEditorFrame"):Hide();
	getglobal("MyModsEditorFrame"):Show();
	SetModBoxsDeals(true);
end

function NewSingleEditorFrameTabBtn_OnClick()
	local id = this:GetClientID();
	if CurTabIndex ~= id then
		UpdateNewSingleEditorTabState(id);
	end
end

function NewSingleEditorFrameTab1SetAttrType_OnClick()
	local id = this:GetClientID();
	if id ~= CurAttrTypeIndex then
		CurAttrTypeIndex = id;
		UpdateNewSingleEditorAttrTypeState();
		UpdateNewSingleEditorAttr();
	end
end

function NewSingleEditorFrameIntroductBtnBtn_OnClick()
	if getglobal("NewSingleEditorFrameTab1FrameInfoIntroduct"):IsShown() then
		getglobal("NewSingleEditorFrameTab1FrameInfoIntroduct"):Hide();
	else
		getglobal("NewSingleEditorFrameTab1FrameInfoIntroduct"):Show();
		UpdateEditorIntroduct();
	end
end

function NewSingleEditorFrameSelModeBtn_OnClick()
	if CurEditorClass == 'block' then
		SetChooseOriginalFrame('blockmodel');
	elseif CurEditorClass == 'actor' then
		SetChooseOriginalFrame('actormodel');
	elseif CurEditorClass == 'item' then
		SetChooseOriginalFrame('itemmodel');
	end
end

function NewSingleEditorFrameReelectModeBtn_OnClick()
	if CurEditorClass == 'block' then
		SetChooseOriginalFrame('blockmodel');
	elseif CurEditorClass == 'actor' then
		SetChooseOriginalFrame('actormodel');
	elseif CurEditorClass == 'item' then
		SetChooseOriginalFrame('itemmodel');
	end
end

function UpdateNewSingleEditorAttr()
	local attrType = "attrtype"..CurAttrTypeIndex;
	local t = new_modeditor.config[CurEditorClass].tab1[attrType].Attr;
	Log("---------------------------------")

	local t_Index = {
			sliderIndex = 0,
			lineIndex = 0,
			switchIndex = 0,
			selectionIndex = 0,
			optionIndex = 0,
		}
	local height = 0;
	local pointY = 0;

	for i=1, #(t) do
		if not t[i].CanShow or t[i].CanShow(CurrentEditDef) then
			local uiFrame = nil;
			if t[i].Type == 'Slider' then			--滑动条
				t_Index.sliderIndex = t_Index.sliderIndex+1;
				uiFrame = getglobal("EditorSlider"..t_Index.sliderIndex);
				height = height + 72;
				
				
				local name = getglobal("EditorSlider"..t_Index.sliderIndex.."Name");
				local valFont = getglobal("EditorSlider"..t_Index.sliderIndex.."Val");
				local desc = getglobal("EditorSlider"..t_Index.sliderIndex.."Desc");
				local bar = getglobal("EditorSlider"..t_Index.sliderIndex.."Bar");

				bar:SetMinValue(t[i].Min);
				bar:SetMaxValue(t[i].Max);
				bar:SetValueStep(t[i].Step);
				local curVal = t[i].CurVal;
				print('Slider SetCurVal', t_Index.sliderIndex, curVal);
				bar:SetValue(curVal);
				name:SetText(GetS(t[i].Name_StringID));
				valFont:SetText(curVal);
				if t[i].GetDesc then
					desc:SetText(t[i].GetDesc(tonumber(curVal)));
				else
					desc:SetText("");
				end	
			elseif t[i].Type == 'Line' then			--分隔线
				t_Index.lineIndex = t_Index.lineIndex+1;
				uiFrame = getglobal("EditorLine"..t_Index.lineIndex);
				height = height + 23;
			elseif t[i].Type == 'Switch' then		--开关
				t_Index.switchIndex = t_Index.switchIndex+1;
				uiFrame = getglobal("EditorSwitch"..t_Index.switchIndex);
				height = height + 70;

				local name = getglobal("EditorSwitch"..t_Index.switchIndex.."Name");
				local switchBtn = getglobal("EditorSwitch"..t_Index.switchIndex.."Btn");
				name:SetText(GetS(t[i].Name_StringID));
				local state = t[i].CurVal and 1 or 0;
				SetSwitchBtnState(switchBtn:GetName(), state);
			elseif t[i].Type == 'Selection' then		--可选择的
				t_Index.selectionIndex = t_Index.selectionIndex+1;
				uiFrame = getglobal("EditorSelection"..t_Index.selectionIndex);
				height = height + 101;

				local name = getglobal("EditorSelection"..t_Index.selectionIndex.."Name");
				name:SetText(GetS(t[i].Name_StringID));
				local t_curVal = t[i].CurVal;
				if t[i].Def == 'PackDef' and t[i].ENName == 'iCostItem' then
					t_curVal = t[i].GetInitVal()
				end

				for j=1, 3 do
					local btn = getglobal("EditorSelection"..t_Index.selectionIndex.."Btn"..j);
					if j <= #(t[i].Boxes) then
						btn:Show();
						local del = getglobal(btn:GetName().."Del");
						local icon = getglobal(btn:GetName().."Icon");
						local enableUI11 = getglobal(btn:GetName().."Forbidden");
						enableUI11:Hide();
						if t_curVal[j] and ((type(t_curVal[j]) == 'number' and t_curVal[j] > 0) or (type(t_curVal[j]) == 'string' and t_curVal[j] ~= ""))then
							del:Show();
							icon:Show();
							local dropId = -1; 
							if (t[i].Def == 'ToolDef' and t[i].ENName == 'ConsumeID') or
						 		(t[i].Def == 'GunDef' and t[i].ENName == 'BulletID') then
								local def = ModEditorMgr:getProjectileDefById(t_curVal[j]);
								if def == nil then
									def = ProjectileDefCsv:get(t_curVal[j], true);
								end
								dropId =  def.ID;
								SetItemIcon(icon, def.ID);
							else
								dropId = t_curVal[j];
								SetItemIcon(icon, t_curVal[j]);
							end

							if GetInst("ModsLibPkgManager"):CheckIsEditPluginInPkg() and (dropId~=-1) then
								local isEnable = GetInst('UIManager'):GetCtrl('ModsLibPkgPluginEdit'):isEnable(dropId);
								local enableUI = getglobal(btn:GetName().."Forbidden");
								if isEnable then
									enableUI:Hide()
								else
									enableUI:Show()
								end  
							end
							
							--[[
							if t[i].Def == 'ItemDef' then
								SetItemIcon(icon, t_curVal[j]);
							elseif t[i].Def == 'ProjectileDef' and t[i].ENName== 'Model' then
								SetItemIcon(icon, t_curVal[j]);
							else
								SetItemIcon(icon, t_curVal[j]);
							end
							]]
						else
							del:Hide();
							icon:Hide();
						end

						if t[i].Boxes[j].NotShowDel then
							del:Hide();
						end
					else
						btn:Hide();
					end
				end 
			elseif t[i].Type == 'Option' then		--选项
				t_Index.optionIndex = t_Index.optionIndex+1;
				uiFrame = getglobal("EditorOption"..t_Index.optionIndex);
				height = height + 75;

				local name = getglobal("EditorOption"..t_Index.optionIndex.."Name");
				name:SetText(GetS(t[i].Name_StringID));
			
				local option = t[i].GetOption(t[i].CurVal, t[i].Options);
				if option then
					local btnName = getglobal("EditorOption"..t_Index.optionIndex.."BtnName");
					local desc = getglobal("EditorOption"..t_Index.optionIndex.."Desc");
					btnName:SetText(GetS(option.Name_StringID));
					if option.Color then
						btnName:SetTextColor(option.Color.r, option.Color.g, option.Color.b);
					else
						btnName:SetTextColor(54, 51, 49);
					end
					if option.Desc_StringID then
						desc:SetText(GetS(option.Desc_StringID), 185, 185, 185);
					else
						desc:SetText("", 185, 185, 185);
					end
				end
			end

			if uiFrame then
				uiFrame:SetClientID(i);		--记录Index

				--设置位置
				uiFrame:SetPoint("top", "NewSingleEditBoxPlane", "top", 0, pointY);
				pointY = height;
			end
		end
	end

	if height < 457 then
		height = 457;
	end
	getglobal("NewSingleEditBoxPlane"):SetHeight(height);

	for i=1, Max_EditorUI do
		for k,v in pairs(t_Index) do
			local uiFrame = nil;
			if k == 'sliderIndex' then
				uiFrame = getglobal("EditorSlider"..i);
			elseif k == 'lineIndex' then
				uiFrame = getglobal("EditorLine"..i);
			elseif k == 'switchIndex' then
				uiFrame = getglobal("EditorSwitch"..i);
			elseif k == 'selectionIndex' then
				uiFrame = getglobal("EditorSelection"..i);
			elseif k == 'optionIndex' then
				uiFrame = getglobal("EditorOption"..i);
			end

			if i <= v then
				uiFrame:Show();
			else
				uiFrame:Hide();
			end
		end
	end
end

function NewSingleEditorFrame_OnLoad()

end

function NewSingleEditorFrame_OnShow()
end

function NewSingleEditorFrame_OnHide()
	if CurEditorClass == 'actor' then
		DetachEditorView()
	end
    CurTabIndex = 1;
end

function DetachEditorView()
	local id = nil;
	if CurrentEditDef.ID ~= 4000 then
		id = CurrentEditDef.ID;
	end
	if ModelRelevantID > 0 then
		id = ModelRelevantID;
	end
	print('DetachEditorView', id);
	if id then
		local view = getglobal("EditorModelView");
		local body = UIActorBodyManager:getMonsterBody(id);
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			view:detachActorBody(body)
		else
			body:detachUIModelView(view);
		end
	end
end
-----------------------------------------------新版SingleEditorFrame----------------------------------------------------

-------------------------------- NewEditorSliderTemplate -----------------------------


-------------------------------- NewEditorSliderTemplate End -------------------------


------------------------------------EditorSelBtnTemplate-----------------------------------
function NewEditorSelBtnTemplate_OnClick()
	if CurEditorClass == "item" and CurrentEditDef and CurrentEditDef.Type == ITEM_TYPE_EQUIP and CurrentEditDef.CopyID == 0 then
		if not GetInst("ModsLibEditorItemPartMgr"):IsCustomEquip(CurrentEditDef.ID) then
			--常规装备(头盔、胸甲等), 不让改模型
			ShowGameTips(GetS(33059));
			return;
		end
	end

	CurEditorUIName = this:GetName();

	local index = this:GetParentFrame():GetClientID();
	local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
	if t.ENName then
		if t.ENName == 'DropItem' or t.ENName == 'RepairId' or t.ENName == "iCostItemInfo" then
			SetChooseOriginalFrame('dropitem');
		elseif t.ENName == 'Model' and t.Def == 'ProjectileDef' then
			SetChooseOriginalFrame('projectilemodel');
		elseif t.ENName == 'ConsumeID' or t.ENName == 'ProjectileID' then
			SetChooseOriginalFrame('projectile');
		elseif t.ENName == 'BulletID' then
			SetChooseOriginalFrame('bullet');
		elseif t.ENName == 'Icon' and t.Def == 'MonsterDef' then
			UpdateEditorTypeByPkg(3)
			SetChooseOriginalFrame('actormodel');
		elseif t.ENName == 'Icon' and t.Def == 'ItemDef' then
			UpdateEditorTypeByPkg(4)
			SetChooseOriginalFrame('itemmodel');
		elseif t.ENName == 'BuffId' then
			SetChooseOriginalFrame('atkbuff');
		elseif t.ENName == 'Icon' and t.Def == 'BlockDef' then
			--LLDO:添加block
			UpdateEditorTypeByPkg(2)
			SetChooseOriginalFrame('blockmodel');
		elseif t.ENName == 'iCostItem' and t.Def == 'PackDef' then
			SetChooseOriginalFrame('PackAddItem');
		end
	end

end

function NewEditorSelBtnTemplateDel_OnClick()
	local index = this:GetParentFrame():GetParentFrame():GetClientID();
	local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];

	local btnIdx = this:GetParentFrame():GetClientID();
	local icon = getglobal(this:GetParent().."Icon");
	local addIcon = getglobal(this:GetParent().."AddIcon");
	local enableUI = getglobal(this:GetParent().."Forbidden");

	addIcon:Show();
	icon:Hide();
	this:Hide();
	enableUI:Hide();
	if t.Def == 'PackDef' and t.ENName == 'iCostItem' then
		PackGiftDef.iCostItemInfo = PackGiftDef.iCostItemInfo%1000
	end
	t.CurVal[btnIdx] = 0;
	UpdateEditorIntroduct();
end
----------------------------------	EditorSelBtnTemplate End	---------------------------------

----------------------------------- SingleSelBtnTemplate   --------------------------------------

----------------------------------- SingleSelBtnTemplate End -------------------------------------


----------------------------------	EditorOptionTemplate 	--------------------------------------

----------------------------------	EditorOptionTemplate End	---------------------------------


----------------------------------	EditorMultiOptionFrame	--------------------------------------
local t_EditormultiOptionIds = {};
function SetEditorMultiOptionFrame(options, title, desc, vals)
	print("kekeke SetEditorMultiOptionFrame", vals)
	getglobal("EditorMultiOptionFrameTitle"):SetText(title);
	getglobal("EditorMultiOptionFrameDesc"):SetText(desc);

	local num = #(options);
	for i=1, Max_SingleOption do
		local optionBtn = getglobal("EditorMultiOption"..i);
		if i <= #(options) then
			optionBtn:Show();

			local name 		= getglobal("EditorMultiOption"..i.."Name");
			name:SetText(GetS(options[i].NameStringId));

			local state = vals[i] and 1 or 0;
			print("kekeke NameStringId", options[i].NameStringId, state);
			SetSwitchBtnState("EditorMultiOption"..i.."Btn", state);
		else
			optionBtn:Hide();
		end
	end

	local height = #(options)*65;
	if height < 290 then
		height = 290;
	end
	
	getglobal("EditorMultiOptionBoxPlane"):SetHeight(height);

	t_EditormultiOptionIds = {};
	getglobal("EditorMultiOptionBox"):resetOffsetPos();
	getglobal("EditorMultiOptionFrame"):Show();	
end

function EditorMultiSwitchOnClick(switchName, state)
	local switch = getglobal(switchName);
	
	local index = switch:GetParentFrame():GetClientID();
	
	if state == 1 then
		t_EditormultiOptionIds[index] = true;
	else
		t_EditormultiOptionIds[index] = false;
	end
end

function EditorMultiOptionFrameOkBtn_OnClick()
	OnCurEditorUICallBack("multioptionok", t_EditormultiOptionIds);
	getglobal("EditorMultiOptionFrame"):Hide();	
	local t_Ai = {{name='look_idle', priority=6},{name='setImmuneToFire', type=1}}

	modeditor.config.actor[2].Attr[8].Save(modeditor.config.actor[2].Attr[8], t_Ai);

	print("kekeke EditorMultiOptionFrameOkBtn_OnClick", t_Ai);
end

function EditorMultiOptionFrameCloseBtn_OnClick()
	getglobal("EditorMultiOptionFrame"):Hide();
end

function EditorMultiOptionFrame_OnLoad()
	for i=1, Max_SingleOption do
		local op = getglobal("EditorMultiOption"..i);
		op:SetPoint("top", "EditorMultiOptionBoxPlane", "top", 0, (i-1)*65)
	end
end

function EditorMultiOptionFrame_OnShow()
	SetSingleEditorDealMsg(false);
end

function EditorMultiOptionFrame_OnHide()
	SetSingleEditorDealMsg(true);
end
----------------------------------	EditorMultiOptionFrame End	----------------------------------


----------------------------------SingleEditorTabFrame---------------------------------

function UpdateSingleEditorPackageList()
	if SingleEditorFrame_Switch_New then
		GetInst("UIManager"):GetCtrl("SingleEditorFrame").view:UpdateSingleEditorPackageList();
	else
	    --
	    local height = 0
	    local ui_frame
	    local addBtn = getglobal("NewEditorFeaturePackageAddNewBtn");

	    -- height = height 
	    local PackTips = getglobal("SingleEditorFramePackTip")
		local num = #PackGiftDef.packItemList
		for i=1,50 do
			local item = getglobal("SingleEditorPackageItem"..i);
			local icon = getglobal("SingleEditorPackageItem"..i.."Icon")
			local bar = getglobal("SingleEditorPackageItem"..i.."SetSliderBar")
			local slider = getglobal("SingleEditorPackageItem"..i.."SetSlider")
			local itemName = getglobal("SingleEditorPackageItem"..i.."Desc")
			local frameNum = getglobal("SingleEditorPackageItem"..i.."Num")

			local barTexture = getglobal("SingleEditorPackageItem"..i.."SetSliderBarThumbRegion")
			local barBkg = getglobal("SingleEditorPackageItem"..i.."SetSliderBarBkg")
			local pro = getglobal("SingleEditorPackageItem"..i.."SetSliderBarPro")
			local leftNorMal = getglobal("SingleEditorPackageItem"..i.."SetSliderLeftBtnNormal")
			local leftBG = getglobal("SingleEditorPackageItem"..i.."SetSliderLeftBtnPushedBG")
			local rightNorMal = getglobal("SingleEditorPackageItem"..i.."SetSliderRightBtnNormal")
			local rightBG = getglobal("SingleEditorPackageItem"..i.."SetSliderRightBtnPushedBG")
			local BG = getglobal("SingleEditorPackageItem"..i.."BG")
			if i <= num then
				local packData = PackGiftDef.packItemList[i];
				-- if id > CUSTOM_MOD_QUOTE then
				-- 	id = id - CUSTOM_MOD_QUOTE
				-- end
				local id = math.modf(packData.iItemInfo/1000);
				local itemNum = packData.iItemInfo%1000;
				local itemDef = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:getAutoUseForeignID(id);
				-- local itemDef =ItemDefCsv:getAutoUseForeignID(id);
				if not itemDef then
					itemDef = ItemDefCsv:get(101)
				end

				if itemDef then
					SetItemIcon(icon,itemDef.ID);
					bar:SetValue(packData.iRatio);
					itemName:SetText(itemDef.Name);
					item:SetClientID(i);
					slider:SetClientID(i);

					if PackGiftDef.iPackType == 0 then
						barTexture:SetGray(true)
						barBkg:SetGray(true)
						pro:SetGray(true)
						leftNorMal:SetGray(true)
						leftBG:SetGray(true)
						rightNorMal:SetGray(true)
						rightBG:SetGray(true)
						BG:Show();
						PackTips:Hide();
						bar:SetValue(100)
					else
						barTexture:SetGray(false)
						barBkg:SetGray(false)
						pro:SetGray(false)
						leftNorMal:SetGray(false)
						leftBG:SetGray(false)
						rightNorMal:SetGray(false)
						rightBG:SetGray(false)
						BG:Hide();
						PackTips:Show();
					end

					frameNum:SetText(itemNum)
				end

				item:Show();
				
				item:SetPoint("top", "SingleEditorPackagePlane", "top", 0, height)
				height = height + item:GetHeight() + 16
			else
				item:Hide();
			end
			
		end



	    --添加特性按钮
	    ui_frame = getglobal("NewEditorFeaturePackageAdd")
	    ui_frame:SetPoint("top", "SingleEditorPackagePlane", "top", 0, height)
	    ui_frame:Show();
	    height = height + ui_frame:GetHeight() + 16
	    
		
	    if num == 0 then
			getglobal("SingleEditorFramePackTip"):SetText(GetS(21769,0).."%")
		elseif num >= 20 then
			ui_frame:Hide();
		end


	    if height < 480 then
			height = 480;
		end
	    
		getglobal("SingleEditorPackagePlane"):SetHeight(height);
	end
end

function NewEditorFeaturePackageAddNewBtn_OnClick( )
	CurEditorUIName = this:GetName();
	SetChooseOriginalFrame('PackAddItem');
end


function SingleEditorInteractionEditBtn_OnFocusLost()
	SetCurEditBox("SingleEditorInteractionDialogueEdit");
	local t= getglobal("SingleEditorInteractionDialogueEdit"):GetText();
	if t ~= GetS(9255) then 
		CurrentEditDef.Dialogue = t;
	end
end

----------------------------------SingleEditorTabFrame End---------------------------------

			
----------------------------------	SingleEditorBaseSet	---------------------------------

function EditorModelTurnRight_OnMouseDown()
	getglobal("NewEditorModelView"):setRotateSpeed(-80);
end

function EditorModelTurnRight_OnMouseUp()
	getglobal("NewEditorModelView"):setRotateSpeed(0);
end

function EditorModelTurnLeft_OnMouseDown()
	getglobal("NewEditorModelView"):setRotateSpeed(80);
end

function EditorModelTurnLeft_OnMouseUp()
	getglobal("NewEditorModelView"):setRotateSpeed(0);
end
--------------------------------------------------------------------------------------------------------------------------
--singleedit:剧情基础设置页
function NpcPlotBaseParamSet(tBase)
	Log("NpcPlotBaseParamSet:");
	getglobal("SingleEditorFrameBaseSetNPCPlotIconBtn1Del"):Hide();
	getglobal("SingleEditorFrameBaseSetNPCPlotIconBtn1Num"):Hide();
	getglobal("SingleEditorFrameBaseSetNPCPlotIconBtn1Name"):Hide();
	getglobal("SingleEditorFrameBaseSetNPCPlotTargetBtn1Del"):Hide();
	getglobal("SingleEditorFrameBaseSetNPCPlotTargetBtn1Num"):Hide();
	getglobal("SingleEditorFrameBaseSetNPCPlotTargetBtn1Name"):Hide();
	getglobal("SingleEditorFrameBaseSetNPCPlot"):Show();

	--1. 名字编辑框
	local editName = getglobal("SingleEditorFrameBaseSetNPCPlotNameEditEdit");
	editName:SetText(tBase.Attr[1].CurVal);

	--2. 图标
	local icon = getglobal("SingleEditorFrameBaseSetNPCPlotIconBtn1Icon");
	local strType = tBase.Attr[2].CurVal.id;
	local index = string.find(strType, "_");
	local id = string.sub(strType, index + 1, -1);
	Log("strType = " .. strType .. ", index = " .. index .. ", id = " .. id);

	if id and tonumber(id) > 0 then
		if string.find(strType, "mob") then
			--生物
			icon:SetTexture("ui/roleicons/"..id..".png", true);
		else
			--道具
	    	SetItemIcon(icon, id);
		end
	end

	--2.2 任务id
	if CurrentEditDef then
		Log("Load CreateTaskIDs:");
		local num = CurrentEditDef:getCreateTaskIDNum();
		local TaskIDs = {};
		if num > 0 then
			for i = 1, num do
				local taskid = CurrentEditDef:getCreateTaskID(i - 1);
				table.insert(TaskIDs, taskid);
			end
		end
		tBase.Attr[13].CurVal = TaskIDs;

		--2.3 触发目标
		local InteractID = CurrentEditDef.InteractID;
		tBase.Attr[5].CurVal = {id = InteractID};
		Log("plotID = " .. CurrentEditDef.ID);
		Log("InteractID = " .. InteractID);
		if InteractID > 0 then
			Log("InteractID:111:");
			local def = ModEditorMgr:getMonsterDefById(InteractID) or MonsterCsv:get(InteractID);
			if def then
				Log("InteractID:222:");
				getglobal("SingleEditorFrameBaseSetNPCPlotTargetBtn1Del"):Show();
				local icon = getglobal("SingleEditorFrameBaseSetNPCPlotTargetBtn1Icon");
				icon:Show();
				if def.ModelType == 3 then --avatar
					local model = string.sub(def.Model,2,string.len(def.Model))
					local args = FrameStack.cur()
					if args.isMapMod then
						AvatarSetIconByID(def,icon)
					else
						AvatarSetIconByIDEx(model,icon)
					end 
				elseif def.ModelType == MONSTER_CUSTOM_MODEL then
					SetModelIcon(icon, def.Model, ACTOR_MODEL);
				elseif CurrentEditDef.ModelType == MONSTER_FULLY_CUSTOM_MODEL then --微雕
					SetModelIcon(icon, CurrentEditDef.Model, FULLY_ACTOR_MODEL);
				elseif CurrentEditDef.ModelType == MONSTER_IMPORT_MODEL then --导入模型
					SetModelIcon(icon, CurrentEditDef.Model, IMPORT_ACTOR_MODEL);
				else
					icon:SetTexture("ui/roleicons/".. def.Icon ..".png", true);
				end 
			end
		else
			Log("InteractID:333:");
			getglobal("SingleEditorFrameBaseSetNPCPlotTargetBtn1Del"):Hide();
			getglobal("SingleEditorFrameBaseSetNPCPlotTargetBtn1Icon"):Hide();
		end
	end

	--3. 前置条件
	if CurrentEditDef then
		Log("LoadCondition:");
		local condition = tBase.Attr[3];
		local num = CurrentEditDef:getConditionNum();
		if num > 0 then
			local def = CurrentEditDef:getConditionDef(0);	--只会保存一个
			condition.CurVal = def.Type;
			Log("condition.CurVal = " .. condition.CurVal);
			if def.Type == 1 then
				--1. 前置任务
				local idNum = def:GetTaskIDsNum();
				for i = 0, idNum - 1 do
					tBase.Attr[6 + i].CurVal = def:GetTaskIDByIndex(i);
					Condition_LoadTaskList(tBase.Attr[6 + i]);
				end
			elseif def.Type == 2 then
				--2. 前置时间
				tBase.Attr[9].CurVal = def.StartTime;
				tBase.Attr[10].CurVal = def.EndTime;
			elseif def.Type == 3 then
				--3. 拥有道具
				tBase.Attr[11].CurVal = {id = def.ItemID, num = 1};
				tBase.Attr[12].CurVal = def.ItemNum;
			else

			end
		end
		Log("num = " .. num);
	end

	local condition = getglobal("SingleEditorFrameBaseSetNPCPlotConditionBtnName");
	local CurVal = tBase.Attr[3].CurVal;
	local Options = tBase.Attr[3].Options;
	local option = tBase.Attr[3].GetOption(CurVal, Options);
	if option then
		local Name_StringID = option.Name_StringID;
		condition:SetText(GetS(Name_StringID));
	end
	ConditionOptionCallbackUI();

	--4. 剧情对话
	--加载剧情对话
	getglobal("SingleEditorFrameBaseSetNPCPlotTalkBtnName"):SetText(GetS(11027));
	if CurrentEditDef then
		Log("111OK:");
		tBase.Attr[4].Dialogues = {};
		local Dialogues = tBase.Attr[4].Dialogues;
		local num = CurrentEditDef:getDialogueNum();
		Log("222num = " .. num);
		for i = 1, num do
			local dialoguesDef = CurrentEditDef:getDialogueDef(i - 1);

			if dialoguesDef then
				--回答列表
				local AnswersList = {};
				local numAnswers = dialoguesDef:getAnswerNum();
				Log("333numAnswers = " .. numAnswers);
				for j = 1, 4 do
					local answerDef = dialoguesDef:getAnswerDef(j - 1);
					if answerDef then
						Log("444answerDef, OK:");
						table.insert(AnswersList, {
							Text = ConvertDialogueStr(answerDef.Text),
							MultiLangText = answerDef.MultiLangText,			--多语言翻译(回答内容)
							FuncType = answerDef.FuncType,
							Val = answerDef.Val,
						});

						--把任务id加到createid, 因为新创剧情的时候, 有可能已经自带任务.
						if answerDef.FuncType == 3 and answerDef.Val > 0 then
							Log("AddCreateId:");
							NpcTask_SaveCreateTaskId2Plot(answerDef.Val);
						end
					else
						table.insert(AnswersList, {
							Text = "",
							FuncType = 0,
							Val = 0,
						})
					end
				end

				--对话列表
				Log("555dialoguesDef, OK:");
				print("MultiLangText = ", dialoguesDef.MultiLangText);
				table.insert(Dialogues, {
					ID = dialoguesDef.ID,
					Text = ConvertDialogueStr(dialoguesDef.Text),
					MultiLangText = dialoguesDef.MultiLangText,			--多语言翻译(剧情内容)
					Action = dialoguesDef.Action,
					Sound = dialoguesDef.Sound,
					Effect = dialoguesDef.Effect,
					Answers = AnswersList,
				});
			end
		end

	end

	--5. 剧情任务
	--加载任务
	NpcTask_ReflashTask();
end


function SingleEditorFrameBaseSetNPCPlotNameEdit_OnEnterPressed()

end

--------------------------------------------------------------------------------------------------------------------------

-----------------------------------SingleEditorBaseSetCraft-----------------------
function SingleEditorBaseSetCraft_OnLoad()
	local resultUIName = "SingleEditorFrameBaseSetCraftResult";
	getglobal(resultUIName.."Del"):Hide();
	getglobal(resultUIName.."Num"):Hide();

	-- getglobal("SingleEditorFrameBaseSetCraftProdNumLeftBtn"):SetPoint("topleft", "SingleEditorFrameBaseSetCraftProdNum", "topleft", 300, 0)
	getglobal("SingleEditorFrameBaseSetCraftProdNumBar"):SetWidth(272);
	getglobal("SingleEditorFrameBaseSetCraftProdNumBarBkg"):SetWidth(272);
	getglobal("SingleEditorFrameBaseSetCraftProdNumDesc"):Hide();

	for i=1, 2 do
		for j=1, 3 do
			local index = (i-1)*3 + j;
			local materialUI = getglobal("SingleEditorFrameBaseSetCraftMaterial"..index);
			materialUI:SetPoint("topleft", "SingleEditorFrameBaseSetCraftMaterialBkg", "topleft", 111+(j-1)*155, 48+(i-1)*118);
		end
	end
end

-----------------------------------SingleEditorBaseSetCraft-----------------------
function SingleEditorBaseSetFurnace_OnLoad()
	local resultUIName = "SingleEditorFrameBaseSetFurnaceMaterial";
	getglobal(resultUIName.."Del"):Hide();
	getglobal(resultUIName.."Num"):Hide();

	-- getglobal("SingleEditorFrameBaseSetFurnaceCanBurnBtn"):SetPoint("left", "SingleEditorFrameBaseSetFurnaceCanBurn", "left", 310, 0);

	-- getglobal("SingleEditorFrameBaseSetFurnaceHeatLeftBtn"):SetPoint("topleft", "SingleEditorFrameBaseSetFurnaceHeat", "topleft", 315, 0)
	getglobal("SingleEditorFrameBaseSetFurnaceHeatBar"):SetWidth(272);
	getglobal("SingleEditorFrameBaseSetFurnaceBurnTimeBar"):SetWidth(272);
	getglobal("SingleEditorFrameBaseSetFurnaceProvideHeatBar"):SetWidth(272);
	getglobal("SingleEditorFrameBaseSetFurnaceHeatBarBkg"):SetWidth(272);
	getglobal("SingleEditorFrameBaseSetFurnaceHeatDesc"):SetPoint("left", "SingleEditorFrameBaseSetFurnaceHeatVal", "right", -25, 0)
	getglobal("SingleEditorFrameBaseSetFurnaceResultNum"):Hide();
end
-----------------------------------SingleEditorBaseSetCommon-----------------------

function SingleEditorBaseSetNameEdit_OnFocusLost()
	SetTopName();
end


function SingleEditorBaseSetNameEdit_OnTabPressed()
	SetCurEditBox("SingleEditorFrameBaseSetCommonDescEdit");
end

function SingleEditorBaseSetDescEdit_OnFocusLost()
	local text = this:GetText();
	local parentName = this:GetParent();
	this:SetText("");
	SingleEditDesc = text;

	local desc
	if CurEditorClass == 'status' then
		desc = getglobal(parentName .. "DescTip")
	else
		desc = getglobal("SingleEditorFrameBaseSetCommonDescTip")
	end

	if desc then
		desc:Show();
		if text == "" then
			desc:SetText(GetS(10646), 185, 185, 185);
		else
			desc:SetText(text, 255, 255, 255);
		end
	end
	SetTopName();
end

function SingleEditorBaseSetDescEdit_OnFocusGained()
	local parentName = this:GetParent();
	this:Show();
	this:SetText(SingleEditDesc);

	local desc
	if CurEditorClass == 'status' then
		desc = getglobal(parentName .. "DescTip")
	else
		desc = getglobal("SingleEditorFrameBaseSetCommonDescTip")
	end

	if desc then
		desc:Hide();
	end
	SingleEditorBaseSet_CalculateDescHeight();
end

function SingleEditorBaseSetDescEdit_OnTextSet()
	SingleEditorBaseSet_CalculateDescHeight();
end

function SingleEditorBaseSet_CalculateDescHeight()
	local desc  = getglobal("SingleEditorFrameBaseSetCommonDescEdit")
	local plane = getglobal("SingleEditorFrameBaseSetCommonDescPlane");
	local box   = getglobal("SingleEditorFrameBaseSetCommonDesc");
	local defaultHeight = 135;
	local descHeight = desc:getSumHeight();
	descHeight = descHeight > defaultHeight and descHeight or defaultHeight;
	desc:SetHeight(descHeight);
	plane:SetHeight(descHeight);
	--box:setCurOffsetY(-descHeight);
end

function SingleEditorBaseSetDescEdit_GetUIEditContent()
	return SingleEditDesc;
end

function SingleEditorBaseSetDescEdit_OnTabPressed()
	SetCurEditBox("SingleEditorBaseSetNameEdit");
end

function SingleEditorBaseSetTopNameDisplay()
	if getglobal(this:GetName().."ShowIcon"):IsShown() then
		getglobal(this:GetName().."ShowIcon"):Hide();
		getglobal(this:GetName().."HideIcon"):Show();
	else
		getglobal(this:GetName().."HideIcon"):Hide();
		getglobal(this:GetName().."ShowIcon"):Show();
	end

	SetTopName();
end
----------------------------------	SingleEditorBaseSet	End	---------------------------------	

function SingleEditorInteractionHelpBtn_OnClick()
	if CurTabIndex == 5 then

		getglobal("MyModsEditorHelpFrame"):Show();
		--标题
		getglobal("MyModsEditorHelpFrameTitleName"):SetText(GetS(11202));

		--内容
		getglobal("MyModsEditorHelpFrameBoxContent"):SetText(GetS(11203), 61, 69, 70);
	end
end

function SingleEditorFrameHelpBtnGuide_OnClick()
	AccountManager:setNoviceGuideState("ploteditguidhelp", true);
	getglobal("SingleEditorFrameHelpBtnGuide"):Hide();
end

function NewSingleEditorSave(editDef, bIsSaveNpcTask)
	print("-------------------------------------------- NewSingleEditorSave", CurEditorClass, CurrentEditDef, CurEditorIsCopied)
	local t_info = {mod_desc={}, property={}, PhysicsActor={}, foreign_ids={} ,avatarInfo = {}};
	
	if CurEditorClass == 'craft' then
		t_info.property["CraftingItemID"] = modeditor.config[CurEditorClass][1].CraftingItemID;
		editDef.CraftingItemID = modeditor.config[CurEditorClass][1].CraftingItemID;
	elseif CurEditorClass == 'status' then
		--多语言支持, 保存多语言格式json.
		local dataStructName = SignManagerGetInstance():GetDataStructForSave("mod_status_name");
		local MultiLangName = JSON:encode(dataStructName);
		local dataStructDesc = SignManagerGetInstance():GetDataStructForSave("mod_status_desc");
		local MultiLangDesc = JSON:encode(dataStructDesc);
		t_info.property["multilangname"] = MultiLangName;
		t_info.property["multilangdesc"] = MultiLangDesc;
		CurrentEditDef.MultiLangName = MultiLangName;
		CurrentEditDef.MultiLangDesc = MultiLangDesc;

		local defName = getglobal("SingleEditorFrameBaseSetStatusNameEdit"):GetText()
		t_info.property["name"] = defName
		t_info.property["describe"] = SingleEditDesc
	elseif CurEditorClass ~= 'furnace' then
		local name = getglobal("SingleEditorFrameBaseSetCommonNameEdit"):GetText();
		--CurEditorClass是plot时，不是SingleEditorFrameBaseSetCommonNameEdit组件,是 SingleEditorFrameBaseSetNPCPlotNameEdit 
		--点击save按钮是已经把text的值储存在 modeditor.config["plot"][1]的配置中了,可以再下面Save函数中处理
		t_info.property["name"] = name;
		editDef.Name = name;

		if CurEditorClass == 'item' then
			t_info.property["describe"] = SingleEditDesc;
		else
			t_info.property["desc"] = SingleEditDesc;
		end
		editDef.Desc = SingleEditDesc;

		--多语言支持, 保存多语言格式json(actor和item)
		if CurEditorClass == 'actor' or CurEditorClass == 'item' then
			local dataStructName = SignManagerGetInstance():GetDataStructForSave("mod_base_name");
			local MultiLangName = JSON:encode(dataStructName);
			local dataStructDesc = SignManagerGetInstance():GetDataStructForSave("mod_base_desc");
			local MultiLangDesc = JSON:encode(dataStructDesc);
			t_info.property["multilangname"] = MultiLangName;
			t_info.property["multilangdesc"] = MultiLangDesc;
			editDef.MultiLangName = MultiLangName;
			editDef.MultiLangDesc = MultiLangDesc;
		end

		if CurEditorClass == 'actor' then
			t_info.property["name_display"] = l_NameDisplay
			t_info.property["desc_display"] = l_DescDisplay;

			editDef.NameDisPlay = l_NameDisplay; 
			editDef.DescDisplay = l_DescDisplay;
		end
	end

	t_info.property["id"] = editDef.ID;
	if CurEditorIsCopied or editDef.CopyID > 0 then
		t_info.property["copyid"] = editDef.CopyID;
	end
 
    -- 插件描述信息
    if string.len(editDef.ModDescInfo.version) == 0 then
        t_info.mod_desc["version"] = ModMgr:getCurUserModVersion()
    else
        t_info.mod_desc["version"] = editDef.ModDescInfo.version
    end
    if string.len(editDef.ModDescInfo.author) == 0 then
        t_info.mod_desc["author"] = AccountManager:getUin()
    else
        t_info.mod_desc["author"] = editDef.ModDescInfo.author
    end
    if string.len(editDef.ModDescInfo.uuid) == 0 then
        t_info.mod_desc["uuid"] = ModEditorMgr:getCurrentEditModDesc().uuid
    else
        t_info.mod_desc["uuid"] = editDef.ModDescInfo.uuid
    end
    if string.len(editDef.ModDescInfo.filename) == 0 then
        t_info.mod_desc["filename"] = CurrentEditDef.EnglishName
    else
        t_info.mod_desc["filename"] = editDef.ModDescInfo.filename
	end

    local t_extendData = {};
	if CurEditorClass == 'actor' then
		--是否显示开发者商店入口
		t_info.property["dshop_display"] = CurrentEditDef.DevShopDisPlay;
		editDef.DevShopDisPlay = CurrentEditDef.DevShopDisPlay;

		t_info.property["openstore_config"] = CurrentEditDef.OpenStoreConfig;
		editDef.OpenStoreConfig = CurrentEditDef.OpenStoreConfig

		--插入dialogue内容
		t_info.property["dialogue"] = CurrentEditDef.Dialogue;

		--AI	
		local t_AI = GetEditAIInfo();
		print("kekeke GetEditAIInfo", t_AI);
		t_info.set_ai = t_AI;


		--原来选择了微缩，现在新选了模型,移除引用和资源
		if (editDef.ModelType == MONSTER_CUSTOM_MODEL or editDef.ModelType == MONSTER_FULLY_CUSTOM_MODEL or editDef.ModelType == MONSTER_IMPORT_MODEL ) and 
			(ModelRelevantName ~= "" or ModelRelevantID > 0)  then
			local mod = ModEditorMgr:getCurrentEditMod();
			if mod then
				mod:removeCustomModelByMod(fileName);
			end
		end

		--微雕
		if ModelRelevantName ~= "" then
			local modelType = ACTOR_MODEL
			if ModelRelevantID == -1 and FULLY_ACTOR_MODEL then
				modelType = FULLY_ACTOR_MODEL
			elseif ModelRelevantID == -2 and IMPORT_ACTOR_MODEL then
				modelType = IMPORT_ACTOR_MODEL
			end
			t_extendData.modeltype = modelType;
			CheckCopyCustomFileToMap(ModelRelevantName, modelType, t_info.mod_desc["filename"]);
		elseif editDef.ModelType == MONSTER_CUSTOM_MODEL then
			t_extendData.modeltype = MONSTER_CUSTOM_MODEL;
		elseif editDef.ModelType == MONSTER_FULLY_CUSTOM_MODEL then
			t_extendData.modeltype = FULLY_ACTOR_MODEL;
		elseif editDef.ModelType == MONSTER_IMPORT_MODEL then
			t_extendData.modeltype = IMPORT_ACTOR_MODEL;
		end
    elseif CurEditorClass == 'item' then
		--icon
		print("kekeke ModelRelevantName",ModelRelevantName, ModelRelevantID);
		if ModelRelevantName ~= "" then
			if ModelRelevantID == -1 then
				editDef.Icon = "fullycustomitem";
			elseif ModelRelevantID == -2 then
				editDef.Icon = "importcustommodel"	
			else
				editDef.Icon = "customitem";
			end
		elseif ModelRelevantID > 0 then
			editDef.Icon = "*"..ModelRelevantID;
			if ModelRelevantID ~= editDef.ID then
				t_info.property["icon"] = "*"..ModelRelevantID;
			end
		elseif editDef.Icon == "customitem" or editDef.Icon == "fullycustomitem" or  editDef.Icon == "importcustommodel" then

		elseif CurrentEditDef.Icon and CurrentEditDef.Icon ~= "" and string.find(CurrentEditDef.Icon, "%*") then
			editDef.Icon = CurrentEditDef.Icon;
			t_info.property["icon"] = CurrentEditDef.Icon;
		elseif CurEditorIsCopied then
			editDef.Icon = "*"..CurrentEditDef.ID;
			t_info.property["icon"] = "*"..CurrentEditDef.ID;
		end

		--model

		--原来选择了微缩，现在新选了模型,移除引用和资源
		if (editDef.Icon == "customitem" or editDef.Icon == "fullycustomitem" or editDef.Icon == "importcustommodel" ) and 
			(ModelRelevantName ~= "" or ModelRelevantID > 0)  then
			local mod = ModEditorMgr:getCurrentEditMod();
			if mod then
				mod:removeCustomModelByMod(fileName);
			end
		end

		if ModelRelevantName ~= "" then
			editDef.Model = ModelRelevantName;
			local modelType = ModelRelevantID < 0 and FULLY_ITEM_MODEL or WEAPON_MODEL;
			if ModelRelevantID == -1 then
				editDef.MeshType = FULLY_CUSTOM_GEN_MESH;
				t_info.property["fullycustommodel"] = ModelRelevantName;
			elseif ModelRelevantID == -2 then
				editDef.MeshType = IMPORT_MODEL_GEN_MESH;
				t_info.property["importcustommodel"] = ModelRelevantName;
			else
				editDef.MeshType = CUSTOM_GEN_MESH;
				t_info.property["custommodel"] = ModelRelevantName;
			end
			
			CheckCopyCustomFileToMap(ModelRelevantName, modelType, t_info.mod_desc["filename"]);
		elseif ModelRelevantID > 0 then
			editDef.Model = "*"..ModelRelevantID;
			if ModelRelevantID ~= editDef.ID then
				t_info.property["model"] = "*"..ModelRelevantID;
			end
		elseif editDef.Icon == "customitem" then
			t_info.property["custommodel"] = editDef.Model;
		elseif  editDef.Icon == "fullycustomitem" then
			t_info.property["fullycustommodel"] = editDef.Model;
		elseif editDef.Icon == "importcustommodel" then
			t_info.property["importcustommodel"] = editDef.Model;
		elseif CurrentEditDef.Model and CurrentEditDef.Model ~= "" and string.find(CurrentEditDef.Model, "%*") then
			editDef.Model = CurrentEditDef.Model;
			t_info.property["model"] = CurrentEditDef.Model;
		elseif CurEditorIsCopied then
			editDef.Model = "*"..CurrentEditDef.ID;
			t_info.property["model"] = "*"..CurrentEditDef.ID;
		end

		t_info.property["orignid"] = editDef.iOrignID
	elseif CurEditorClass == 'status' then
		local curCfg = modeditor.config[CurEditorClass];
		--每一个tab页签
		for i = 1, #curCfg do
			local t = curCfg[i];
			if t.Attr and #t.Attr > 0 then
				t = t.Attr;
				--每一个控件
				for j = 1, #t do
					if t[j].Status_Save and type(t[j].Status_Save)  == 'function' then
						t[j]:Status_Save(editDef or {});
					end
				end
			end
		end

		for i=1,5 do
			local curSelectedFeature = t_CurSelectedFeature[i]
			if not editDef.Status.EffInfo[i-1] then break end
			if curSelectedFeature then
				editDef.Status.EffInfo[i-1].CopyID = curSelectedFeature.CopyID
				for j=1,#curSelectedFeature.Value do
					editDef.Status.EffInfo[i-1].Value[j-1] = curSelectedFeature.Value[j]
				end
			else
				editDef.Status.EffInfo[i-1].CopyID = 0
				for j=1,5 do
					editDef.Status.EffInfo[i-1].Value[j-1] = -1000000
				end
			end
		end

		t_info.property["type"] = editDef.Type
		t_info.property["sound_type"] = editDef.SoundType
		t_info.property["english_name"] = t_info.mod_desc["filename"]
		t_info.property["status_info"] = statusToJsonData(editDef)

		t_info.PhysicsActor = nil
		t_info.avatarInfo = nil
	end

	if bIsSaveNpcTask then
		--LLTODO:剧情编辑任务保存
		for i=1, 5 do
			local t = modeditor.config[CurEditorClass][i];
			if t and t.Attr then
				Log("SaveTask:CurEditorClass = " .. CurEditorClass .. ", i = " .. i);
				local attrList = t.Attr;
				for j = 1, #attrList do
					--任务的保存函数叫"TaskSave".
					if attrList[j].TaskSave then
						attrList[j].TaskSave(attrList[j], editDef, t_info.property);
					end
				end
			end
		end
	elseif editDef.Type == ITEM_TYPE_PACK then
		t_info.property["packid"] = PackGiftDef.iPackID
		t_info.property["iPackID"] = PackGiftDef.iPackID
		t_info.property["iPackType"] = PackGiftDef.iPackType
		t_info.property["iMaxOpenNum"] = PackGiftDef.iMaxOpenNum
		t_info.property["iRepeat"] = PackGiftDef.iRepeat
		t_info.property["iNeedCostItem"] = PackGiftDef.iNeedCostItem
		t_info.property["iCostItemInfo"] = PackGiftDef.iCostItemInfo

		t_info.property["packItemList"] = PackGiftDef.packItemList
	elseif CurEditorClass ~= 'status' then
		for i=1, 5 do
			local t = modeditor.config[CurEditorClass][i];
			if t and t.Attr then
				t = t.Attr;

				for j=1, #(t) do
	                --AddDef
	                if CurEditorClass ~= 'actor' and t[j].Type == 'NoUI'  and t[j].AddDef then
					    t[j].AddDef(t[j].CurVal, editDef.ID, editDef.CopyID);
					end
					if CurEditorClass == 'item' and t[j].ENName and t[j].ENName == 'ModelScale' and t[j].AddDef then
						t[j].AddDef(t[j].CurVal, editDef.ID, editDef.CopyID);
					end


					--Save
					--这里保存了信息 def里面没有更新，后面会把信息持久化到本地，导致创建完后刷新列表用的def中的数据，立即更新的视图是拷贝对象的值（名字。icon），
					if t[j].Save then
						if t[j].SaveType == 'AI' then
							t[j].Save(t[j], t_info.set_ai);
						elseif t[j].SaveType == 'DefAndAI' then
							t[j].Save(t[j], editDef, t_info.property, t_info.set_ai);
						else
	                        if (CurEditorClass == 'item' and ( not t[j].CanShow or t[j].CanShow(CurrentEditDef))) or CurEditorClass == 'actor' or CurEditorClass == 'craft' or CurEditorClass == 'furnace' or CurEditorClass == 'plot' then
							    if t[j].Def == 'PhysicsActorDef' then
							    	t[j].Save(t[j],editDef,t_info.PhysicsActor);
							    else
							    	t[j].Save(t[j], editDef, t_info.property, t_extendData);
							    	if t[j].SaveAvatar then 
							    		--保存avatar模型信息
							    		local saveTemplate = t[j].SaveAvatar(t[j],t_info.avatarInfo);
							    		if saveTemplate then 
							    			t_info.avatarInfo = deep_copy_table(saveTemplate)
							    			local tempSkin = deep_copy_table(t_info.avatarInfo.skin)
							    			t_info.avatarInfo.skin = {}
							    			if tempSkin then 
							    				for k,v in pairs(tempSkin) do 
							    					table.insert(t_info.avatarInfo.skin,v)
							    				end 
							    			end 
							    		end 
							    	end 
							    end

							    if t[j].Type == "EditBox" and t[j].ENName == "Name" then
							    	Log("XXXXEditBoxName:");
							    end

	                        end

						end
					end
				end
			end
		end
	end

--print('kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk')
--print(t_info)
	if CurEditorClass == 'actor' then
        --插入特性AI
        for i=1,#(t_CurSelectedFeature) do
            table.insert(t_info.set_ai, t_CurSelectedFeature[i])
        end
		SaveEditorSelAI(editDef, t_info.set_ai);
        
        --保存特性AI的外部ID
        for i=1,#(OpenAiTable.TempForeignIds) do
            ModEditorMgr:setActorForeignId(editDef, OpenAiTable.TempForeignIds[i].id, OpenAiTable.TempForeignIds[i].key)
        end
        t_info.foreign_ids = loadstring("return "..ModEditorMgr:getActorForeignIds(editDef))()
    elseif CurEditorClass == 'item' then
    	if editDef.Type == ITEM_TYPE_EQUIP then
    		--TODO:装备
    		--1. 自定义装备, 部件
			if GetInst("ModsLibEditorItemPartMgr"):IsCustomEquip(editDef.CopyID) then
				t_info.equipdef = GetInst("ModsLibEditorItemPartMgr"):OnSave(editDef);
				t_info.property["tool_type"] = t_info.equipdef.slottype;
				GetInst("ModsLibEditorItemPartMgr"):CopyModelFile2Map(nil, editDef.ID, t_info.mod_desc["filename"]);
			end

			--2. 效果列表
    		local SingleEditorCtrl = GetInst("UIManager"):GetCtrl("SingleEditorFrame");
			t_info.equipdef = t_info.equipdef or {};
			t_info.equipdef.effinfo = {};
			--[[
			结构示例:
			equipdef = {
				slottype = 9,
				partdefs = {},	--部件列表
				effinfo  = {	--效果列表
					{
						copy_id = 10000,
						values = {10, 30, },
					},	--效果1
					{},	--效果2
				},
			},
			]]
			local itemequipDef = ModEditorMgr:getItemEquipDefById(editDef.ID);
			if itemequipDef then
				for i = 1, MAX_EQUIP_EFFECT_COUNT do
					itemequipDef.EffInfo[i - 1].CopyID = 0;
				end
			end

			for i = 1,#t_CurSelectedFeature do
				if t_CurSelectedFeature[i].CopyID == 0 then break end

				t_info.equipdef.effinfo[i] = {};
				t_info.equipdef.effinfo[i].copy_id = t_CurSelectedFeature[i].CopyID
				t_info.equipdef.effinfo[i].values = {};

				if itemequipDef then
					itemequipDef.EffInfo[i - 1].CopyID = t_CurSelectedFeature[i].CopyID;
				end

				for j = 1,#t_CurSelectedFeature[i].Value do
					t_info.equipdef.effinfo[i].values[j] = t_CurSelectedFeature[i].Value[j];

					if itemequipDef then
						itemequipDef.EffInfo[i - 1].Value[j - 1] = t_CurSelectedFeature[i].Value[j];
					end
				end
			end
    	else
    		--转换下t_info.itemskills成游戏用的格式
			local newItemSkillTable = {};
			local newItemSkillTableChange = {};
			for i=1,#(t_CurSelectedFeature) do
	            table.insert(newItemSkillTable, t_CurSelectedFeature[i])
	        end
			for i=1, #(newItemSkillTable) do
				table.insert(newItemSkillTableChange, ItemSkillTable.saveToGameTable(newItemSkillTable[i]));
			end
			if #(newItemSkillTableChange) > 0 then
				t_info.itemskills = newItemSkillTableChange;
				SaveEditorSelItemSkill(editDef, t_info.itemskills);
			else
				ModEditorMgr:clearItemSkillID(editDef.ID);
			end
			
	        --保存特性AI的外部ID
	        for i=1,#(ItemSkillTable.TempForeignIds) do
	            ModEditorMgr:setItemForeignId(editDef, ItemSkillTable.TempForeignIds[i].id, ItemSkillTable.TempForeignIds[i].key)
	        end
	        t_info.foreign_ids = loadstring("return "..ModEditorMgr:getItemForeignIds(editDef))()
    	end
    elseif CurEditorClass == 'craft' then        
        t_info.foreign_ids = loadstring("return "..ModEditorMgr:getCraftingForeignIds(editDef))()
    elseif CurEditorClass == 'furnace' then        
        t_info.foreign_ids = loadstring("return "..ModEditorMgr:getFurnaceForeignIds(editDef))()
    elseif CurEditorClass == 'plot' then
    	if not bIsSaveNpcTask then
    		t_info.foreign_ids = loadstring("return "..ModEditorMgr:getNpcPlotForeignIds(editDef))()
    	else
    		t_info.foreign_ids = loadstring("return "..ModEditorMgr:getNpcTaskForeignIds(editDef))()
    	end
    elseif CurEditorClass == 'status' then        
        t_info.foreign_ids = loadstring("return "..ModEditorMgr:getStatusForeignIds(CurrentEditDef))()
	end

	local dataStr = JSON:encode(t_info);
	local dataStrAvatar = JSON:encode(t_info.avatarInfo)
	Log("t_info:");
	print("kekeke dataStr", dataStr);
	return dataStr,dataStrAvatar;
end

function SavePackItemDate()
	local id = 0;
	local num = 0;
	for i=1, 5 do
		local t = modeditor.config[CurEditorClass][i];
		if t and t.Attr then
			t = t.Attr;
			
			for j=1, #(t) do
				if CurEditorClass == 'item' then
					if t[j].Def and t[j].Def == 'PackDef' then
						if t[j].Type == 'Selection' and t[j].ENName and t[j].ENName == 'iCostItem'then
							-- id = t[j].CurVal[1];
							id = t[j].GetInitVal()[1]
						end

						if t[j].Type == 'PackSlider' or t[j].Type == 'Slider' then
							if t[j].ENName and t[j].ENName == 'iCostItemNum' then
								num = t[j].CurVal;
								
							elseif  t[j].ENName and t[j].ENName == 'iMaxOpenNum' then
								PackGiftDef.iMaxOpenNum = t[j].CurVal;
							end
						end

						-- if t[j].Type == 'Switch' then
						-- 	if t[j].ENName and t[j].ENName == 'iRepeat' then
						-- 		if not t[j].CurVal then
						-- 			PackGiftDef.iRepeat = 0;
						-- 		else
						-- 			PackGiftDef.iRepeat = 1;
						-- 		end
						-- 	elseif t[j].ENName and t[j].ENName == 'CanCondition' then
						-- 		if not t[j].CurVal then
						-- 			PackGiftDef.iCostItemInfo = 0;
						-- 		end
						-- 	end
						-- end
					end
				end
			end
		end
		
	end

	if id > 0 then
		PackGiftDef.iCostItemInfo = id*1000+num;
	else
		PackGiftDef.iCostItemInfo = 0;
	end

	if PackGiftDef.iPackType == 1 and PackGiftDef.iRepeat == 0 then
		if PackGiftDef.iMaxOpenNum > #PackGiftDef.packItemList then
			PackGiftDef.iMaxOpenNum = #PackGiftDef.packItemList
		end
	end
end

-- PackGiftDef = {
-- 	iPackID = 10111,
-- 	iPackType = 0,
-- 	iMaxOpenNum = 10,
-- 	iCostItemInfo = 0,
-- 	packItemList = {},
-- }

-- PackItemDef ={
-- 	iItemInfo = 0,
-- 	iRate = 0,
-- }


function SingleEditorInteraction_OnHide()
	interactData.Reset();--还原数据
	ResetSingleEditorInteractionFrame() -- 还原页面
end

function ResetSingleEditorInteractionFrame()
	 -- getglobal("SingleEditorFrameExplainTitle"):Hide();
end

function SingleEditorFrameFeatureItemAddBtn_OnClick()
    --检查特性条数，最多10条
    if #(t_CurSelectedFeature) >= 20 then
        UpdateTipsFrame(GetS(6299), 0)
        return
    end
	if CurEditorClass == 'actor' then
		SetChooseOriginalFrame('featureai');
	elseif  CurEditorClass == 'item' and CurrentEditDef.Type ~= ITEM_TYPE_EQUIP then
		SetChooseOriginalFrame('featureitemskill');
	elseif CurEditorClass == 'status' or CurrentEditDef.Type == ITEM_TYPE_EQUIP then
		local strType, id = GetInst("ModsLibSelectorMgr"):OpenSelector(8, false);
		local SingleEditorCtrl = GetInst("UIManager"):GetCtrl("SingleEditorFrame");
		if strType == 'ok' and SingleEditorCtrl then
			local params = GetInst("ModsLibDataManager"):GetStatusEffectInitParams({CopyID = id, Value={}});
			if params then
				table.insert(t_CurSelectedFeature, params);
				SingleEditorCtrl.view:UpdateSingleEditor_Effect();

				--追加效果描述
				if CurrentEditDef.Type == ITEM_TYPE_EQUIP then
					AddEffectDescToEquip(params);
				end
			end
		end
	end
end

--追加效果描述到装备描述
function AddEffectDescToEquip(params)
	local effectDef = GetInst("ModsLibDataManager"):GetStatusEffectConf(params.CopyID);
	if effectDef then
		local descStr = GetInst("ModsLibDataManager"):GetFeatureUiDescStr(effectDef, params.uilist, true);
		descStr = descStr or effectDef.Desc;
		SingleEditDesc = SingleEditDesc or "";
		descStr = SingleEditDesc .. "\n" .. descStr;
		SingleEditDesc = descStr;
		
		local desc = getglobal("SingleEditorFrameBaseSetCommonDescEdit");
		local tip = getglobal("SingleEditorFrameBaseSetCommonDescTip");
		tip:SetText(descStr);
	end
end

function GetActorAI(monsterId, aiName)
	if ModEditorMgr:getMonsterAINum(monsterId) > 0 then
		local jsonStr = ModEditorMgr:getMonsterAIString(monsterId, aiName);
		if jsonStr == "" then
			return "";
		else
			return JSON:decode(jsonStr);
		end
	else
	 	return	AIConfig.GetAI(monsterId, aiName)
	end
end



function UpdateNewSingleEditorActorFeature()
    --从开放的特性AI条目表遍历当前怪物的特性AI
    local height = 0
    local ui_frame

    --标题
    ui_frame = getglobal("SingleEditorFeatureLine")
    -- getglobal("SingleEditorFeatureLineLineZheZhao"):Show()
    -- getglobal("SingleEditorFeatureLineTitle"):Show()
    -- getglobal("SingleEditorFeatureLineTitle"):SetWidth(400)
    
    ui_frame:Show()
    ui_frame:SetPoint("top", "SingleEditorFeaturePlane", "top", 0, height)   
    height = height + ui_frame:GetHeight() + 50

--print("filter after--------------t_CurSelectedFeature")
--print(t_CurSelectedFeature)
	if CurEditorClass == 'actor' then
		getglobal("SingleEditorFeatureLineTitle"):SetText(GetS(6247))
		getglobal("NewEditorFeatureItemAddDesc"):SetText(GetS(6324))
	else
		getglobal("SingleEditorFeatureLineTitle"):SetText(GetS(8512))
		getglobal("NewEditorFeatureItemAddDesc"):SetText(GetS(8505))
	end
	if getglobal("SingleEditorFrameRightTopTitle"):IsShown() then 
		getglobal("SingleEditorFrameRightTopTitle"):Hide(); 
	end
    --AI特性条目
    local num = #(t_CurSelectedFeature)
    for i=1, MaxFeatureAiNum do
        ui_frame = getglobal("SingleEditorFeatureItem"..i)
        if i <= num then
            local feature_item_name = t_CurSelectedFeature[i].name
            local feature_item_uidata = GetFeatureTable()[feature_item_name]
            local ui_frame_icon = getglobal("SingleEditorFeatureItem"..i.."Icon")
			local ui_frame_desc = getglobal("SingleEditorFeatureItem"..i.."Desc")
			if CurEditorClass == 'actor' then
				ui_frame_icon:SetTexture("ui/aiicons/"..feature_item_uidata.Icon..".png", true)
			else
				ui_frame_icon:SetTexture("ui/itemskillicons/"..feature_item_uidata.Icon..".png", true)
			end
            ui_frame_desc:SetText(GetS(feature_item_uidata.NameStringId).." : "..feature_item_uidata.GetFormatDesc(feature_item_uidata.DescStringId, t_CurSelectedFeature[i]))
			ui_frame:SetClientID(i)
            ui_frame:SetPoint("top", "SingleEditorFeaturePlane", "top", 0, height)
            ui_frame:Show()

            height = height + ui_frame:GetHeight() + 9
            ui_frame:Show()
        else
            ui_frame:Hide()
        end
    end

    --添加特性按钮
    ui_frame = getglobal("NewEditorFeatureItemAdd")
    ui_frame:SetPoint("top", "SingleEditorFeaturePlane", "top", 0, height)
	if CurEditorClass == 'item' then
		if GetCurrentEditDef().Type == 8 or GetCurrentEditDef().Type == 12 then
			if num == 10 then
				ui_frame:Hide()
			else
				ui_frame:Show()
			end
		else
			if num == 1 then
				ui_frame:Hide()
			else 
				ui_frame:Show()
			end
		end
	else
		ui_frame:Show()
	end
    
	height = height + ui_frame:GetHeight() + 5

    if height < 548 then
		height = 548;
	end
    
	getglobal("SingleEditorFeaturePlane"):SetHeight(height);
end

function OnCurEditorUICallBack_Feature_Add(val, editclass)
	local OpenTable;
	if  editclass == 'actor' then
		OpenTable = OpenAiTable;
	elseif editclass == 'item' then
		OpenTable = ItemSkillTable;
	end
	
	local t = OpenTable.MakeDefaultFeatureItem(val);
	if next(t) ~= nil then
   		table.insert(t_CurSelectedFeature, t)
		if SingleEditorFrame_Switch_New then
			GetInst("UIManager"):GetCtrl("SingleEditorFrame"):UpdateNewSingleEditorActorFeatureCtrl()
		else
			UpdateNewSingleEditorActorFeature()
		end
	end
end

function OnCurEditorUICallBack_Feature_Del(index)
    table.remove(t_CurSelectedFeature, index)
	if SingleEditorFrame_Switch_New then
		GetInst("UIManager"):GetCtrl("SingleEditorFrame"):UpdateNewSingleEditorActorFeatureCtrl()
	else
		UpdateNewSingleEditorActorFeature()
	end
end

function OnCurEditorUICallBack_Feature_Update(src)
    local dst = t_CurSelectedFeature[CurEditFeatureIndex]
    
    for k,v in pairs(dst) do
        dst[k] = src[k]
    end

	if SingleEditorFrame_Switch_New then
		GetInst("UIManager"):GetCtrl("SingleEditorFrame"):UpdateNewSingleEditorActorFeatureCtrl()
	else
		UpdateNewSingleEditorActorFeature()
	end
end

function OnCurEditorUICallBack_Feature_SelectIcon(id)
    local feature_item_data = CurEditFeatureItemData  
    local feature_item_uidata = GetFeatureTableItem(feature_item_data.name)
    local param_uidata = feature_item_uidata.Parameters[CurEditFeatureParamIndex]

    param_uidata.Save(feature_item_data, param_uidata.Name, id)
    if SingleEditorFrame_Switch_New then 
    	GetInst("UIManager"):GetCtrl("ModsLibFeatureEdit"):RefreshByParam()
    else
    	UpdateNewEditorFeatureParamEditFrame();
    end 
end

function NewEditorFeatureEditFrame_OnLoad()
end

function NewEditorFeatureEditFrame_OnShow()
	--标题栏
	getglobal("NewEditorFeatureEditFrameTitleFrameName"):SetText(GetS(6302));

    local feature_item_data = t_CurSelectedFeature[CurEditFeatureIndex]

    CurEditFeatureItemData = {}
    for k,v in pairs(feature_item_data) do
        CurEditFeatureItemData[k] = v;
    end

	UpdateNewEditorFeatureParamEditFrame()
	getglobal("NewEditorFeatureEditParamFrame"):setCurOffsetY(0);
end



--------------------------------------NewEditorFeatureEditHelpFrame Begin---------------------------------------

function NewEditorFeatureEditHelpFrame_OnLoad()
	--标题栏
	getglobal("NewEditorFeatureEditHelpFrameTitleName"):SetText(GetS(8612));
	getglobal("NewEditorFeatureEditHelpFrameBoxContent"):SetText(GetS(8626),  61, 69, 70);
end

function NewEditorFeatureEditHelpFrame_OnShow()
	local lines = getglobal("NewEditorFeatureEditHelpFrameBoxContent"):GetTextLines();
	if lines <= 14 then
		getglobal("NewEditorFeatureEditHelpFrameBoxPlane"):SetSize(890, 370);
		getglobal("NewEditorFeatureEditHelpFrameBoxContent"):SetSize(890, 370);
	else
		getglobal("NewEditorFeatureEditHelpFrameBoxPlane"):SetSize(890, 370+(lines-14)*30);
		getglobal("NewEditorFeatureEditHelpFrameBoxContent"):SetSize(890, 370+(lines-14)*30);
	end
end

function NewEditorFeatureEditHelpFrameClose_OnClick()
	getglobal("NewEditorFeatureEditHelpFrame"):Hide();
end

--------------------------------------NewEditorFeatureEditHelpFrame End---------------------------------------

function UpdateNewEditorFeatureParamEditFrame()
	
    local feature_item_data = CurEditFeatureItemData
	local feature_item_uidata = GetFeatureTable()[feature_item_data.name]
	local ui_frame_icon = getglobal("NewEditorFeatureEditFrameLeftPanelIcon")
    local ui_frame_title = getglobal("NewEditorFeatureEditFrameLeftPanelFeatureTitle")
	local ui_frame_desc = getglobal("NewEditorFeatureEditFrameLeftPanelFeatureDesc")
	
    --local ui_frame_icon = getglobal("NewEditorFeatureEditFrameIcon")
    --local ui_frame_title = getglobal("NewEditorFeatureEditFrameFeatureTitle")
	--local ui_frame_desc = getglobal("NewEditorFeatureEditFrameFeatureDesc")
	
	local ui_title = getglobal("NewEditorFeatureEditFrameTitleFrameName")
	
	if CurEditorClass == 'actor' then
		ui_frame_icon:SetTexture("ui/aiicons/"..feature_item_uidata.Icon..".png", true)
		ui_title:SetText(GetS(6302))

		--LLDO:初始化
		if OpenAiTable.Init then
			OpenAiTable:Init();
		end
	elseif CurEditorClass == 'item' then
		ui_frame_icon:SetTexture("ui/itemskillicons/"..feature_item_uidata.Icon..".png", true)
		ui_title:SetText(GetS(8501))
	end
    ui_frame_title:SetText(GetS(feature_item_uidata.NameStringId))
    ui_frame_desc:SetText(feature_item_uidata.GetFormatDesc(feature_item_uidata.DescStringId, feature_item_data))
    
    --初始化Ai参数的界面元素
    local height = 0
    local t_Index = {
			lineIndex = 0,
			sliderIndex = 0,
			selectionIndex = 0,
			optionIndex = 0,
		}
    for i=1, #(feature_item_uidata.Parameters) do
        local ui_frame = nil
        local param_uidata = feature_item_uidata.Parameters[i]
        local param_val = feature_item_data[param_uidata.Name]
        
        if param_val == nil then
            param_val = param_uidata.Default
        end

        --print("Param(",param_uidata.Name,") = ", param_val)

        if param_uidata.Type == 'selector' then
			if param_uidata.CanShow == nil or param_uidata.CanShow(feature_item_data) then
				t_Index.selectionIndex = t_Index.selectionIndex + 1
				ui_frame = getglobal("NewEditorFeatureSelection"..t_Index.selectionIndex);

				local name = getglobal("NewEditorFeatureSelection"..t_Index.selectionIndex.."Name");
				name:SetText(GetS(param_uidata.NameStringId));
				
				local btn = getglobal("NewEditorFeatureSelection"..t_Index.selectionIndex.."Btn");
				btn:Show();
				--print("icon = ", param_val)

				local icon = getglobal(btn:GetName().."Icon");
				--根据选择类型设置图标
				if param_uidata.SelectClass == "monster" then
					local monDef = ModEditorMgr:getMonsterDefById(param_val) or MonsterCsv:get(param_val);
					if monDef and monDef.Icon and monDef.Icon ~= "" and string.sub(monDef.Icon, 1, 1) == "a" then 
						--Avatar头像，以"a"开头
						local id = string.sub(monDef.Icon, 2, #monDef.Icon)
						if id then 
							local avatarDef = ModMgr:tryGetMonsterDef(tonumber(id))
							local args = FrameStack.cur()
							if args.isMapMod then 
								AvatarSetIconByID(avatarDef,icon)
							else
								AvatarSetIconByIDEx(monDef.Icon,icon)
							end
						end  
					else
						icon:SetTexture("ui/roleicons/"..monDef.Icon..".png", true);
					end 
				elseif param_uidata.SelectClass == "block" or param_uidata.SelectClass == "ai_targetblock" or param_uidata.SelectClass == "ai_useitem" then
					SetItemIcon(icon, param_val)
				elseif param_uidata.SelectClass == "food" then
					SetItemIcon(icon, param_val)
				elseif param_uidata.SelectClass == "projectile" then
					SetItemIcon(icon, param_val)		
				elseif param_uidata.SelectClass == "buff" then
					if SingleEditorFrame_Switch_New then
						local path = GetInst("ModsLibDataManager"):GetStatusIconPath(param_val);
						if path ~= "" then
							icon:SetTexture(path, true)
						end
					else
						local buffDef = DefMgr:getBuffDef(param_val)
						if buffDef then
						   icon:SetTexture("ui/bufficons/"..buffDef.IconName..".png", true);
						end
					end
				elseif param_uidata.SelectClass == "container" or param_uidata.SelectClass == "ai_dropitem" then
					--LLDO:new add: 箱子, 刷新选择器
					SetItemIcon(icon, param_val);
				elseif param_uidata.SelectClass == "craft" then
					local craftDef = ModEditorMgr:getCraftingDefById(param_val);
					if not craftDef then
						craftDef = DefMgr:getCraftingDef(param_val);
					end

					if craftDef then
						SetItemIcon(icon, craftDef.ResultID);
					end
				end
			end
		elseif param_uidata.Type =='Line' then
			if param_uidata.CanShow == nil or param_uidata.CanShow(feature_item_data) then
				t_Index.lineIndex = t_Index.lineIndex + 1;
				ui_frame = getglobal("NewEditorFeatureLine"..t_Index.lineIndex);
				if param_uidata.Title_StringID then
					Log("title_string id=" .. param_uidata.Title_StringID)
					-- getglobal("NewEditorFeatureLine"..t_Index.lineIndex.."LineZheZhao"):Show();
					-- getglobal("NewEditorFeatureLine"..t_Index.lineIndex.."Title"):Show();
					getglobal("NewEditorFeatureLine"..t_Index.lineIndex.."Title"):SetText(GetS(param_uidata.Title_StringID));
				else
					Log("title_stirng id= nil")
					getglobal("NewEditorFeatureLine"..t_Index.lineIndex.."LineZheZhao"):Hide();
					getglobal("NewEditorFeatureLine"..t_Index.lineIndex.."Title"):Hide();
				end
			end
        elseif param_uidata.Type == 'option' then
			if param_uidata.CanShow == nil or param_uidata.CanShow(feature_item_data) then
				t_Index.optionIndex = t_Index.optionIndex + 1
				ui_frame = getglobal("NewEditorFeatureOption"..t_Index.optionIndex);

				local name = getglobal("NewEditorFeatureOption"..t_Index.optionIndex.."Name");
				name:SetText(GetS(param_uidata.NameStringId));
				
				local option = param_uidata.GetOption(param_val, param_uidata.Options);
				if option then
					local btnName = getglobal("NewEditorFeatureOption"..t_Index.optionIndex.."BtnName");
					btnName:SetText(GetS(option.Name_StringID));
					if option.Color then
						--btnName:SetTextColor(option.Color.r, option.Color.g, option.Color.b);
						btnName:SetTextColor(55, 54, 41);
					else
						btnName:SetTextColor(55, 54, 41);
					end
				end

				--LLDO:处理显示隐藏
			    if param_uidata.Func then
			    	local type;
			    	if option.Val then
			    		type = "add";
			    	else
			    		type = "remove";
			    	end
			    	param_uidata.Func(type);
			    end
			end
        elseif param_uidata.Type == 'slider' then
			if param_uidata.CanShow == nil or param_uidata.CanShow(feature_item_data) then
				t_Index.sliderIndex = t_Index.sliderIndex + 1
				ui_frame = getglobal("NewEditorFeatureSlider"..t_Index.sliderIndex);

				local name = getglobal("NewEditorFeatureSlider"..t_Index.sliderIndex.."Name");
				local desc = getglobal("NewEditorFeatureSlider"..t_Index.sliderIndex.."Desc");
				local bar = getglobal("NewEditorFeatureSlider"..t_Index.sliderIndex.."Bar");
				local ui_val = param_uidata.GetUiData(param_val)

				--print("slider value = ", ui_val, "desc = ", param_uidata.GetDesc(ui_val))

				bar:SetMinValue(param_uidata.Min);
				bar:SetMaxValue(param_uidata.Max);
				bar:SetValueStep(param_uidata.Step);
				bar:SetValue(ui_val);
				name:SetText(GetS(param_uidata.NameStringId));
				desc:SetText(param_uidata.GetDesc(ui_val));
			end
        end

        if ui_frame then
            ui_frame:SetClientID(i)
            ui_frame:SetPoint("top", "NewEditorFeatureEditParamFramePlane", "top", 0, height)
            height = height + ui_frame:GetHeight() + 20
        end
    end

	for i=1, MaxFeatureAiParamNum do
		for k,v in pairs(t_Index) do
			local uiFrame = nil;
			if k == 'sliderIndex' then
				uiFrame = getglobal("NewEditorFeatureSlider"..i);
			elseif k == 'selectionIndex' then
				uiFrame = getglobal("NewEditorFeatureSelection"..i);
			elseif k== 'lineIndex' then
				uiFrame = getglobal("NewEditorFeatureLine"..i);
			elseif k == 'optionIndex' then
				uiFrame = getglobal("NewEditorFeatureOption"..i);
			end

			if i <= v then
				uiFrame:Show();
			else
				uiFrame:Hide();
			end
		end
	end

    if height < 250 then
		height = 250;
	end
    
	getglobal("NewEditorFeatureEditParamFramePlane"):SetHeight(height);

	getglobal("SingleEditorFeature"):setDealMsg(false);

end

function NewEditorFeatureEditFrame_OnHide()
	getglobal("SingleEditorFeature"):setDealMsg(true);
end

function NewEditorFeatureEditFrameCloseBtn_OnClick()
    getglobal("NewEditorFeatureEditFrame"):Hide()
end

function NewEditorFeatureEditFrameDelBtn_OnClick()
    OnCurEditorUICallBack_Feature_Del(CurEditFeatureIndex)
    getglobal("NewEditorFeatureEditFrame"):Hide()
end

function NewEditorFeatureEditFrameOkBtn_OnClick()
--print("CurEditFeatureItemData:")
--print(CurEditFeatureItemData)
    OnCurEditorUICallBack_Feature_Update(CurEditFeatureItemData)
    getglobal("NewEditorFeatureEditFrame"):Hide()

    -- if CurEditFeatureItemData then
    -- 	local t = AccountManager:getSvrTime() - CSMgr:getAccountCreateTime();
    -- 	statisticsGameEvent(30100, "%s", CurEditFeatureItemData.name, "%d", t / 60 / 60 / 24);
    -- end
end

function GetFeatureTable()
	if CurEditorClass == 'actor' then
		return OpenAiTable;
	elseif CurEditorClass == 'item' and CurrentEditDef.Type ~= ITEM_TYPE_EQUIP then
		return ItemSkillTable;
	end
	return {};
end

function GetFeatureTableItem(key)
	if CurEditorClass == 'actor' then
		return OpenAiTable[key]
	elseif CurEditorClass == 'item' then
		return ItemSkillTable[key]
	end
	return {};
end


function NewEditorFeatureSliderTemplateLeftBtn_OnClick()
	local value = getglobal(this:GetParent().."Bar"):GetValue();
	local index = this:GetParentFrame():GetClientID();

    local feature_item_data = CurEditFeatureItemData
    local feature_item_uidata = GetFeatureTableItem(feature_item_data.name)
	
    local param_uidata = feature_item_uidata.Parameters[index]

	value = value - param_uidata.Step;
    if value < param_uidata.Min then value = param_uidata.Min end

	getglobal(this:GetParent().."Bar"):SetValue(value);

--print("--------------------------------------dodo------1")
--print(value)

    param_uidata.Save(feature_item_data, param_uidata.Name, value)
    UpdateNewEditorFeatureParamEditFrame();
end

function NewEditorFeatureSliderTemplateRightBtn_OnClick()
	local value = getglobal(this:GetParent().."Bar"):GetValue();
	local index = this:GetParentFrame():GetClientID();

    local feature_item_data = CurEditFeatureItemData
    local feature_item_uidata = GetFeatureTable()[feature_item_data.name]
    local param_uidata = feature_item_uidata.Parameters[index]

	value = value + param_uidata.Step;
    if value > param_uidata.Max then value = param_uidata.Max end

--print("--------------------------------------dodo------1")
--print(value)

	getglobal(this:GetParent().."Bar"):SetValue(value);
    
    param_uidata.Save(feature_item_data, param_uidata.Name, value)
    UpdateNewEditorFeatureParamEditFrame();
end

function NewEditorFeatureSliderTemplateBar_OnValueChanged()
	local index = this:GetParentFrame():GetClientID();
    
    local feature_item_data = CurEditFeatureItemData
    local feature_item_uidata = GetFeatureTable()[feature_item_data.name]
    local param_uidata = feature_item_uidata.Parameters[index]

	local value = this:GetValue();
	local ratio = (value-this:GetMinValue())/(this:GetMaxValue()-this:GetMinValue());
--print("--------------------------------------dodo------")
--print(value)

	if ratio > 1 then ratio = 1 end
	if ratio < 0 then ratio = 0 end
	local width   = math.floor(305*ratio)
	getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
	getglobal(this:GetName().."Pro"):SetWidth(width);

    param_uidata.Save(feature_item_data, param_uidata.Name, value)
    UpdateNewEditorFeatureParamEditFrame();
end

function NewEditorFeatureSelBtnTemplate_OnClick()
	local index = this:GetParentFrame():GetClientID();
    local feature_item_data = CurEditFeatureItemData
    local feature_item_uidata = GetFeatureTable()[feature_item_data.name]
    local param_uidata = feature_item_uidata.Parameters[index]

    CurEditFeatureParamIndex = index

    if param_uidata.SelectClass == "monster" then
        SetChooseOriginalFrame('ai_actor');
    elseif param_uidata.SelectClass == "block" then
        SetChooseOriginalFrame('ai_block');
    elseif param_uidata.SelectClass == "food" then
        SetChooseOriginalFrame('ai_food');
	elseif param_uidata.SelectClass == "buff" then
		SetChooseOriginalFrame('ai_buff');
	elseif param_uidata.SelectClass == "projectile" then   
		SetChooseOriginalFrame('ai_projectile');
	elseif param_uidata.SelectClass == "container" then
		--LLDO:new add:箱子
		SetChooseOriginalFrame('ai_container');
	elseif param_uidata.SelectClass == "craft" then
		--配方选择
		Log("NewEditorFeatureSelBtnTemplate_OnClick: craft");
		SetChooseOriginalFrame('ai_craft');
	elseif param_uidata.SelectClass then
		--新增:ai_targetblock, ai_useitem, ai_dropitem...
		SetChooseOriginalFrame(param_uidata.SelectClass);
    end
end

function NewEditorFeatureOptionTemplateBtn_OnClick()
	local index = this:GetParentFrame():GetClientID();
    local feature_item_data = CurEditFeatureItemData
    local feature_item_uidata = GetFeatureTable()[feature_item_data.name]
    local param_uidata = feature_item_uidata.Parameters[index]
    local param_val = feature_item_data[param_uidata.Name]

	local descString = "";
	CurEditFeatureParamIndex = index
	if param_uidata.DescStringId ~= nil then
		descString = GetS(param_uidata.DescStringId);
	end
	SetNewEditorFeatureOptionFrame(param_uidata.Options, GetS(param_uidata.NameStringId),descString);
end

function NewSingleFeatureOptionBtn_OnClick()
	local id = this:GetClientID();
    local feature_item_data = CurEditFeatureItemData
    local feature_item_uidata = GetFeatureTable()[feature_item_data.name]
    local param_uidata = feature_item_uidata.Parameters[CurEditFeatureParamIndex]
        
    param_uidata.Save(feature_item_data, param_uidata.Name, param_uidata.Options[id].Val)

    --LLDO:处理显示隐藏
    if param_uidata.Func then
    	local type;
    	if param_uidata.Options[id].Val then
    		type = "add";
    	else
    		type = "remove";
    	end
    	param_uidata.Func(type);
    end
 
	getglobal("NewEditorFeatureOptionFrame"):Hide();
    UpdateNewEditorFeatureParamEditFrame();
end

function NewEditorFeatureOptionFrame_OnLoad()
	for i=1, Max_SingleOption do
		local op = getglobal("NewSingleFeatureOptionBtn"..i);
		op:SetPoint("top", "NewEditorFeatureOptionBoxPlane", "top", 0, (i-1)*69)
	end
end

function NewEditorFeatureOptionFrame_OnShow()
	getglobal("NewEditorFeatureOptionBox"):resetOffsetPos();
    SetNewSingleEditorFeatureDealMsg(false)
end

function NewEditorFeatureOptionFrame_OnHide()
    SetNewSingleEditorFeatureDealMsg(true)
end

function NewEditorFeatureOptionFrameCloseBtn_OnClick()    
	getglobal("NewEditorFeatureOptionFrame"):Hide();
end

function SetNewEditorFeatureOptionFrame(options, title, desc)
	getglobal("NewEditorFeatureOptionFrameTitle"):SetText(title);
	if desc == "" then
		getglobal("NewEditorFeatureOptionFrameDesc"):Hide();
	else
		getglobal("NewEditorFeatureOptionFrameDesc"):SetText(desc, 101, 116, 118);
		getglobal("NewEditorFeatureOptionFrameDesc"):Show();
	end
	local num = #(options);
	for i=1, Max_SingleOption do
		local optionBtn = getglobal("NewSingleFeatureOptionBtn"..i);
		if i <= num then
			optionBtn:Show();
			
			local name = getglobal("NewSingleFeatureOptionBtn"..i.."Name");
			name:SetText(GetS(options[i].Name_StringID));
			if options[i].Color then
				--name:SetTextColor(options[i].Color.r, options[i].Color.g, options[i].Color.b);
				name:SetTextColor(55, 54, 41);
			else
				name:SetTextColor(55, 54, 41);
			end
		else
			optionBtn:Hide();
		end
	end

	local height = num*69;
	if height < 350 then
		height = 350;
	end
	
	getglobal("NewEditorFeatureOptionBoxPlane"):SetHeight(height);
	getglobal("NewEditorFeatureOptionFrame"):Show();                            
end

function SetNewSingleEditorFeatureDealMsg(state)
	--getglobal("NewEditorFeatureEditFrame"):setDealMsg(state);
end


--------------------------------------物理设置部分新增-----------------------------------------------------------------

--物理材质列表
local Max_PhysxOption = 100;
local t_physxMatsTemplate = {};
local t_physxMatCustom = {}
local t_physxMatOptions = {}

--刷新物理材质选项列表
function UpdatePhysxMaterialOptions( ... )
	
	t_physxMatsTemplate = {};
	t_physxMatCustom = {}
	t_physxMatOptions = {}
	local num = DefMgr:getPhysicsMaterialDefNum();

	for i=1, num do
		local def = DefMgr:getPhysicsMaterialDefByIndex(i-1);
		if def then
			if ModEditorMgr:getPhysicsMaterialDefById(def.MaterialID) then
                def = ModEditorMgr:getPhysicsMaterialDefById(def.MaterialID)
                
            end
            if def.Selectable and def.Selectable == 1 then
            	table.insert(t_physxMatsTemplate, {Def=def,Name=GetS(def.NameStringID),ID=def.MaterialID});
            end
           
        end
    end
    --加载自定义物理材质
    local iNum = ModEditorMgr:getCustomPhysicsMaterialCount();
    for i=0, iNum-1 do
    	local def = ModEditorMgr:getPhysicsMaterialDef(i);
  
    	if def and def.CopyID > 0 then
            table.insert(t_physxMatCustom, {Def=def,Name=def.Name,ID=def.MaterialID});
        end
    end

    local defaultCount = #(t_physxMatsTemplate);
    local customCount = #(t_physxMatCustom);
    local totalCount = defaultCount+customCount;
    local height = 0;
    if totalCount>Max_PhysxOption then
    	Log("totalCount out of limit")
    end
    for i=1, Max_PhysxOption do
    	local btn =  getglobal("MaterialSingleOption"..i)
    	local editbtn = getglobal("MaterialSingleOption"..i.."EditBtn")
    	local option = getglobal("MaterialSingleOption"..i.."OptionBtn");
    	local MatName = getglobal("MaterialSingleOption"..i.."OptionBtnName");
    	if i<=totalCount then
    		if i<= defaultCount then
    			MatName:SetText((t_physxMatsTemplate[i].Name));
    			editbtn:Hide()
    		else
    			MatName:SetText(t_physxMatCustom[i-defaultCount].Name);
    			editbtn:Show();
    		end
    		btn:Show()
    		btn:SetPoint("Top","MaterialOptionBoxPlane","Top", 0,height)
    		height = height + 69;
  
    	else
    		getglobal("MaterialSingleOption"..i):Hide();
    	end
    end
    getglobal("PhysxMatOptionFrameDesc"):SetText(GetS(11517),61,69,70)
    getglobal("MaterialSingleOptionAddOptionBtnName"):SetText(GetS(11540));
    getglobal("MaterialSingleOptionAdd"):SetPoint("Top","MaterialOptionBoxPlane","Top",0,height);
    if height>360 then
    	getglobal("MaterialOptionBoxPlane"):SetHeight(height+100);
    else
    	getglobal("MaterialOptionBoxPlane"):SetHeight(460);
    end
end
function PhysxMatOptionFrame_OnShow( ... )
	SetSingleEditorDealMsg(false)
end
function PhysxMatOptionFrame_OnHide( ... )
	SetSingleEditorDealMsg(true)
end

function PhysxMaterialEditFrameDelBtn_OnClick( ... )
	--删除材质，如果删除了当前物品所用的材质，则物品的材质自动选择列表上一个;
	--如果删除的材质被其他道具所使用，则无法删除，提示删除失败
	
	MessageBox(5, GetS(11544), function(btn)
		if btn == 'left' then 	--确认
			local optionindex = getglobal(CurEditorUIName):GetParentFrame():GetClientID();
			local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[optionindex];
			local delid = CurrentEditMatDef.MaterialID
			local physxActorCount = ModEditorMgr:getPhysicsActorCount()
			if physxActorCount>0 then
				for i=0,physxActorCount-1 do
					local def = ModEditorMgr:getPhysicsActorDef(i);
					if def and def.ActorID ~= CurrentEditDef.ID then
						if def.MaterialID == delid then
							ShowGameTips(GetS(6599))
							return;
						end
					end
				end
			end


			local newid = 0;
			local success = ModEditorMgr:delModSlotFileById(PHYSICS_MATERIAL_MOD, CurrentEditMatDef.MaterialID);
			if success then
				if t.CurVal == delid then
					if #(t_physxMatCustom) > 1 then
						for i=1,#(t_physxMatCustom) do
							if delid == t_physxMatCustom[i].ID then
								if i > 1 then
									newid = t_physxMatCustom[i-1].ID
								else
									newid = t_physxMatCustom[i+1].ID
								end
								break;
							end
						end
					else
						local index = #(t_physxMatsTemplate)
						newid = t_physxMatsTemplate[index].ID
					end
					t.CurVal = newid
				end
				ShowGameTips(GetS(3992))
				UpdatePhysxMaterialOptions()
				UpdateSingleEditorAttr()
			else
				ShowGameTips(GetS(773))
				return;
			end
			getglobal("PhysxMaterialEditFrame"):Hide()
			getglobal("PhysxMaterialNameEditInput"):Clear()
		else

		end
	end)

end
function PhysxMaterialEditFrameConfirmBtn_OnClick( ... )
	local text = getglobal("PhysxMaterialNameEditInput"):GetText()
	if text =="" then
		ShowGameTips(GetS(3642));
		return;
	end
	if CheckFilterString(text) then return end

	--local isCreate = (ModEditorMgr:getPhysicsMaterialDefById(CurrentEditMatDef.MaterialID) == nil);
	local isCopy;
	if (getglobal("PhysxMaterialEditFrameDelBtn"):IsShown() == false) or (CurrentEditMatDef.CopyID<=0 and CurrentEditMatDef.IsTemplate == 1) then
		isCopy = true;
	else
		isCopy = false
	end

	local dataStr;
	local id;
	
	dataStr, id = PhysxMatSave(CurrentEditMatDef.MaterialID, isCopy)
	
	if dataStr == nil then return end

	local success = ModEditorMgr:requestCreatePhysicsMaterial(dataStr,id)
	
	if success then
		ShowGameTips(GetS(3940))
		UpdatePhysxMaterialOptions()
	else
		ShowGameTips(GetS(3941))
		return
	end
	local optionindex = getglobal(CurEditorUIName):GetParentFrame():GetClientID()
	local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[optionindex];
	if CurrentEditMatDef.MaterialID == t.CurVal then
		t.CurVal = id;
		UpdateSingleEditorAttr();
	end
	getglobal("PhysxMaterialNameEditInput"):Clear()
	getglobal("PhysxMaterialEditFrame"):Hide();
	
	print("Mat dataStr:",dataStr);
	

end

function PhysxMatSave(id,isCopy)
	local preDef = DefMgr:getPhysicsMaterialDef(id);
	local copyid = 0
	if preDef.CopyID > 0 then
		copyid = preDef.CopyID
	end

	local t_matinfo= { property={}};
	local def = nil
	if PhysxMatConfig.AddDef then
		def = PhysxMatConfig.AddDef(id,isCopy);
	end
	if def == nil then 
		Log("add fail");
		return 
	else
		if isCopy then
			def.CopyID = id;
			t_matinfo.property["CopyID"] = id;
		elseif copyid > 0 then
			def.CopyID = copyid;
			t_matinfo.property["CopyID"] = copyid;
		end
		t_matinfo.property["MaterialID"] = def.MaterialID
		t_matinfo.property["filename"] = tostring(def.MaterialID)
	end
	local t = PhysxMatConfig.Attr
	for i=1,#(t) do
		if t[i].Save then
			t[i].Save(def,t[i],t_matinfo.property)
		end
	end
	local dataStr = JSON:encode(t_matinfo);
	Log("t_matinfo:");
	return dataStr,def.MaterialID;
end

function PhysxMaterialSliderTemplateBar_OnValueChanged( ... )
	local value = this:GetValue();
	local ratio = (value-this:GetMinValue())/(this:GetMaxValue()-this:GetMinValue());

	if ratio > 1 then ratio = 1 end
	if ratio < 0 then ratio = 0 end
	local width   = math.floor(328*ratio)
	
	getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
	getglobal(this:GetName().."Pro"):SetWidth(width);

	local index = this:GetParentFrame():GetClientID();
	value = string.format("%.1f", value);
	--local t = PhysxMatConfig.Attr[index+2]
	--t.CurVal = value;
	
	local valFont = getglobal(this:GetParent().."Val");
	local desc = getglobal(this:GetParent().."Desc");
	
	valFont:SetText(value);
	value = tonumber(value)
	if value>0 and value<=0.3 then desc:SetText(GetS(11541))	--小
	elseif value>0.3 and value<=0.7 then desc:SetText(GetS(11542))  --中
	elseif value>0.7 and value<=1.0 then desc:SetText(GetS(11543))  --大
	end	
	PhysxMatConfig.Attr[index+2].CurVal = value;
end
--材质滑动条左
function PhysxMaterialSliderTemplateLeftBtn_OnClick( ... )
	local value = getglobal(this:GetParent().."Bar"):GetValue();
	local index = this:GetParentFrame():GetClientID();
	local t = PhysxMatConfig.Attr[index+2];

	value = value - 0.1;
	getglobal(this:GetParent().."Bar"):SetValue(value);
end
function PhysxMaterialSliderTemplateRightBtn_OnClick( ... )
	local value = getglobal(this:GetParent().."Bar"):GetValue();
	local index = this:GetParentFrame():GetClientID();
	local t = PhysxMatConfig.Attr[index+2];

	value = value + 0.1;
	getglobal(this:GetParent().."Bar"):SetValue(value);
end
--刷新材质编辑面板UI:1. 创建新材质；2.编辑材质/切换模板
function UpdatePhysxMatAttr(state)
	local template_name = getglobal("PhysxMaterialOptionSelectBtnName");
	local defaultName	= getglobal("PhysxMaterialNameEditInput");
	local bar1			= getglobal("PhysxMatSlider1Bar");
	local bar2			= getglobal("PhysxMatSlider2Bar");
	local bar3			= getglobal("PhysxMatSlider3Bar");

	template_name:SetText(GetS(PhysxMatConfig.Attr[1].CurVal));
	template_name:SetTextColor(55,54,41);
	if state == 1 then
		PhysxMatConfig.Attr[2].CurVal = GetS(11522)
	end
	defaultName:SetText(PhysxMatConfig.Attr[2].CurVal)
	
	bar1:SetValue(PhysxMatConfig.Attr[3].CurVal);
	bar2:SetValue(PhysxMatConfig.Attr[4].CurVal)
	bar3:SetValue(PhysxMatConfig.Attr[5].CurVal)

end


--新增物理材质
function AddNewPhysxMaterial( ... )
	getglobal("PhysxMaterialEditFrame"):Show();
	--默认模版：金属
	CurrentEditMatDef = DefMgr:getPhysicsMaterialDef(13);
	PhysxMatConfig.Init(CurrentEditMatDef);
	UpdatePhysxMatAttr(1);
end

function PhysxMaterialEditFrameCloseBtn_OnClick( ... )
	getglobal("PhysxMaterialEditFrame"):Hide()
	getglobal("PhysxMaterialNameEditInput"):Clear()
end


--物理材质列表按钮点击事件
function SingleOptionFrameTemplateOptionBtn_OnClick( ... )
	local index = this:GetParentFrame():GetClientID()
	--新增材质
	if index == 99999 then
		AddNewPhysxMaterial()
		getglobal("PhysxMaterialEditFrameDelBtn"):Hide();
	else
		--选择其他材质
		local MatID =0;
		local MatDef;
		if index <= #(t_physxMatsTemplate) then
			MatDef = t_physxMatsTemplate[index].Def;
		else
			MatDef = t_physxMatCustom[index-#(t_physxMatsTemplate)].Def;
		end
		MatID = MatDef.MaterialID
		local optionindex = getglobal(CurEditorUIName):GetParentFrame():GetClientID();
		local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[optionindex];
		Log("asd"..tostring(CurEditorUIName)..tostring(optionindex))
		t.CurVal = MatID;
		getglobal("PhysxMatOptionFrame"):Hide()
		UpdateSingleEditorAttr();
	end
end

function PhysxMatOptionFrameCloseBtn_OnClick( ... )
	getglobal("PhysxMatOptionFrame"):Hide()
end

--物理材质编辑界面相关
function PhysxMaterialEditFrame_OnLoad( ... )
	--标题栏
	getglobal("PhysxMaterialEditFrameTitleFrameName"):SetText(GetS(4776));

	getglobal("PhysxMaterialOptionSelectNameTitle"):SetText(GetS(11520),61,69,70)
	local nametitle_width = getglobal("PhysxMaterialOptionSelectNameTitle"):GetLineWidth(1)
	if nametitle_width > 0 then
		getglobal("PhysxMaterialOptionSelectNameTitle"):SetWidth(nametitle_width)
	end

	local height = 113
	for i=1,3 do
		height = height + 70
		local slider= getglobal("PhysxMatSlider"..i)
		local title = getglobal("PhysxMatSlider"..i.."NameTitle");
		slider:SetPoint("top","PhysxMatEditBox","top",0,height)
		title:SetText(GetS(11525+(i-1)*2), 61, 69, 70)
		local width = title:GetLineWidth(1)
		if width > 0 then
			title:SetWidth(width)
		end
	end
end

function PhysxMaterialEditFrame_OnShow( ... )
	SetSingleEditorDealMsg(false)
end
function PhysxMaterialEditFrame_OnHide( ... )
	if not getglobal("PhysxMatOptionFrame"):IsShown() then
		SetSingleEditorDealMsg(true)
	end
end


--物理材质模板选择列表相关
function MatTemplateOptionFrame_OnLoad( ... )
	
	local num = DefMgr:getPhysicsMaterialDefNum();
	--local max = DefMgr:getPhysicsMaterialDefByIndex(num-1);
	for i=0,14 do
		local MatDef = DefMgr:getPhysicsMaterialDef(i)
		if MatDef and MatDef.IsTemplate == 1 then
			table.insert(t_MatTemplate,{Def=MatDef,Name=MatDef.Name})
		end
	end
	local plane = getglobal("MaterialTemplateBoxPlane")
	local height = 0
	getglobal("MatTemplateOptionFrameDesc"):SetText(GetS(11519),101,116,118)
	for i=1,80 do
		local option 	 = getglobal("MaterialTemplateOption"..i)
		local optionName = getglobal("MaterialTemplateOption"..i.."Name");
		if i <= #(t_MatTemplate) then	
			option:SetPoint("top","MaterialTemplateBoxPlane","top",0,height)
			if i~=#(t_MatTemplate) then
				height = height + 69
			end
			optionName:SetText(t_MatTemplate[i].Name);
			option:Show()
		else
			option:Hide()
		end
	end
	if height<=350 then
		plane:SetHeight(350)
	else
		plane:SetHeight(height)
	end
end

function MatTemplateOptionFrameCloseBtn_OnClick( ... )
	getglobal("MatTemplateOptionFrame"):Hide();
end

--物理材质模版选择
function PhysxMaterialOptionTemplateBtn_OnClick( ... )
	getglobal("MatTemplateOptionFrame"):Show();
end

--物理材质名称编辑
function PhysxMaterialNameEdit_OnFocusLost( ... )
	PhysxMatConfig.Attr[2].CurVal = getglobal("PhysxMaterialNameEditInput"):GetText();
end




--------------------------------------------------------NPC商店-----------------------------------------------------------


function ResetNpcStoreTable()
	NpcStore.iShopID = 0;                 --商店ID
	NpcStore.iNpcID = 0;					 --NpcID
	NpcStore.sShopName = "";       --商店名称
	NpcStore.sShopDesc = "";        --商店描述
	getglobal("SingleEditorFrameBaseSetStoreNameEditEdit"):SetText("");
	getglobal("SingleEditorFrameBaseSetStoreDescEditEdit"):SetText("");

	NpcStore.sInnerKey = "";
	NpcStore.EnglishName = "";
	NpcStore.shopItemMap = {};
	-- NpcStore = { shopItemMap = {} };
end

function ResetNpcStoreAttrTable()
	local attr = NpcStoreTable.config.Attr;
	attr[1].CurVal = 100;
	attr[1].CurNum = 1;
	attr[2].CurVal = 101;
	attr[2].CurNum = 1;
	attr[3].CurVal = 0;
	attr[4].CurVal = 1;
	attr[5].CurVal = 301;
	attr[6].CurVal = 0;
	attr[7].CurVal = 0;
	attr[8].CurVal = 0;
end

function SaveNpcStoreItemList(EnglishName)
	NpcStore.shopItemMap = {}
	for i=1,#NpcStoreTable.itemList do
		local t = NpcStoreTable.itemList[i];

		NpcAttr.iSkuID = i;
		NpcAttr.iItemID = t.ItemID;
		NpcAttr.iOnceBuyNum = t.Attr[4].CurVal;
		NpcAttr.iMaxCanBuyCount = t.Attr[5].CurVal;
		NpcAttr.iRefreshDuration = t.Attr[6].CurVal;
		NpcAttr.iStarNum = t.Attr[3].CurVal;
		if t.Attr[1].CurNum > 0 and  t.Attr[1].CurVal == 0 then -- Npc商店[Desc5]道具默认值判断
			t.Attr[1].CurVal = 100
		end
		if t.Attr[2].CurNum > 0 and  t.Attr[2].CurVal == 0 then  -- Npc商店[Desc5]道具默认值判断
			t.Attr[2].CurVal = 100
		end
		NpcAttr.iCostItemInfo1 = (t.Attr[1].CurVal*1000)+t.Attr[1].CurNum;
		NpcAttr.iCostItemInfo2 = (t.Attr[2].CurVal*1000)+t.Attr[2].CurNum;
		NpcAttr.iShowAD = t.Attr[8] and t.Attr[8].CurVal or 0;
		-- print("SaveNpcStoreItemList|"..t.Attr[1].CurVal.."|"..t.Attr[1].CurNum.."|"..t.Attr[2].CurVal.."|"..t.Attr[2].CurNum.."|"..NpcAttr.iItemID)
		

		table.insert(NpcStore.shopItemMap,deep_copy_table(NpcAttr))
	end
	NpcStore.sShopName =  NpcStoreTable.config.Name;
	NpcStore.sShopDesc =  NpcStoreTable.config.Desc;
	if EnglishName then
		NpcStore.EnglishName = EnglishName;
	end

end

function CreateNewNPCStoreFrameCloseBtn_OnClick()
	getglobal("CreateNewNPCStoreFrame"):Hide();
end


function NPCStoreEditorFeatureEditFrameCloseBtn_OnClick()
	getglobal("NPCStoreEditorFeatureEditFrame"):Hide();
end

function NPCStoreEditorFeatureEditFrame_OnShow()
	--标题栏
	getglobal("NPCStoreEditorFeatureEditFrameTitleFrameName"):SetText(GetS(21711));
end

--刷新NPC商店列表
function UpdateNpcStoreList()
	local num = #NpcStore.shopItemMap;
	local height = (num+1)*125+75;
	local addBtn = getglobal("NewEditorNPCStoreItemAdd");
	for i=1,num do
		local uiName = "SingleEditorNPCStoreItemSetItem"..i
		local ui_frame
		if not HasUIFrame(uiName) then
			ui_frame = UIFrameMgr:CreateFrameByTemplate("Frame", uiName, "NewEditorNPCStoreItemTemplate11111", "SingleEditorNPCStoreItemSet")
		else
			ui_frame = getglobal(uiName)
		end

		local icon = getglobal(uiName.."Icon")
		local desc = getglobal(uiName.."Desc")
		local starIcon = getglobal(uiName.."StarIcon")
		local starDesc = getglobal(uiName.."StarDesc")
		local itemIcon1 = getglobal(uiName.."ItemIcon1")
		local itemDesc1 = getglobal(uiName.."ItemDesc1")
		local itemIcon2 = getglobal(uiName.."ItemIcon2")
		local itemDesc2 = getglobal(uiName.."ItemDesc2")
		local buyDesc = getglobal(uiName.."BuyDesc");
		local bkg = getglobal(uiName.."TransparentBkg");
		local swapBtn = getglobal(uiName.."SwapMoveBtn")
		local editBtn = getglobal(uiName.."EditBtn");
		local switchBtn = getglobal(uiName.."MoveSwitchBtn")
		local t = NpcStore.shopItemMap[i]

		local iItemID1 = math.modf(t.iCostItemInfo1/1000)
		local iItemID2 = math.modf(t.iCostItemInfo2/1000)

		-- local itemDef = ModEditorMgr:getItemDefById(t.iItemID) or ModEditorMgr:getBlockItemDefById(t.iItemID) or ItemDefCsv:get(t.iItemID) or {};

		-- local itemDef1 = ModEditorMgr:getItemDefById(iItemID1) or ModEditorMgr:getBlockItemDefById(iItemID1) or ItemDefCsv:get(iItemID1);
		-- local itemDef2 = ModEditorMgr:getItemDefById(iItemID2) or ModEditorMgr:getBlockItemDefById(iItemID2) or ItemDefCsv:get(iItemID2);


		local itemDef = ItemDefCsv:getAutoUseForeignID(t.iItemID) or ModEditorMgr:getItemDefById(t.iItemID) or ModEditorMgr:getBlockItemDefById(t.iItemID) or ItemDefCsv:get(101)

		local itemDef1 = ItemDefCsv:getAutoUseForeignID(iItemID1) or ModEditorMgr:getItemDefById(iItemID1) or ModEditorMgr:getBlockItemDefById(iItemID1) or ItemDefCsv:get(101)
		local itemDef2 = ItemDefCsv:getAutoUseForeignID(iItemID2) or ModEditorMgr:getItemDefById(iItemID2) or ModEditorMgr:getBlockItemDefById(iItemID2) or ItemDefCsv:get(101)

		SetItemIcon(icon,itemDef.ID);
		if t.iRefreshDuration == 0 then
			if t.iMaxCanBuyCount > 300 then
				desc:SetText(GetS(21706)..itemDef.Name.."*"..t.iOnceBuyNum .."       "..GetS(21707)..GetS(680));
			else
				desc:SetText(GetS(21706)..itemDef.Name.."*"..t.iOnceBuyNum .."       "..GetS(21707)..t.iMaxCanBuyCount);
			end

		else
			if t.iMaxCanBuyCount > 300 then
				desc:SetText(GetS(21706)..itemDef.Name.."*"..t.iOnceBuyNum .."       "..GetS(21707)..GetS(680) .."       "..GetS(21708)..t.iRefreshDuration.."s");
			else
				desc:SetText(GetS(21706)..itemDef.Name.."*"..t.iOnceBuyNum .."       "..GetS(21707)..t.iMaxCanBuyCount .."       "..GetS(21708)..t.iRefreshDuration.."s");
			end

		end

		-- SetItemIcon(starIcon,101);

		starDesc:SetText(GetS(73).."*"..t.iStarNum);

		if itemDef1 and t.iCostItemInfo1 > 0 then
			SetItemIcon(itemIcon1,itemDef1.ID);
			itemDesc1:SetText(itemDef1.Name.."*"..t.iCostItemInfo1%1000);
			itemIcon1:Show();
			itemDesc1:Show();
		else
			itemIcon1:Hide();
			itemDesc1:Hide();
		end
		if itemDef2 and t.iCostItemInfo2 > 0 then
			SetItemIcon(itemIcon2,itemDef2.ID);
			itemDesc2:SetText(itemDef2.Name.."*"..t.iCostItemInfo2%1000);
			itemIcon2:Show();
			itemDesc2:Show();
		else
			itemIcon2:Hide();
			itemDesc2:Hide();
		end
		if itemDef2 or itemDef1 or t.iStarNum ~= 0 then
			-- buyDesc:Show();
			buyDesc:SetText(GetS(21709));
		else
			-- buyDesc:Hide();
			buyDesc:SetText(GetS(21709)..GetS(4553));
		end

		if t.iStarNum == 0 and itemDef1 and itemDef2 then
			itemIcon1:SetPoint("top","SingleEditorNPCStoreItemSetItem"..i.."StarIcon","bottom",0,-32)
			itemIcon2:SetPoint("top","SingleEditorNPCStoreItemSetItem"..i.."ItemIcon1","bottom",156,-32)
		elseif t.iStarNum == 0 and not itemDef1 and itemDef2 then
			itemIcon1:SetPoint("top","SingleEditorNPCStoreItemSetItem"..i.."StarIcon","bottom",0,-32)
			itemIcon2:SetPoint("top","SingleEditorNPCStoreItemSetItem"..i.."ItemIcon1","bottom",0,-32)
		elseif t.iStarNum ~= 0 and not itemDef1 and itemDef2 then
			itemIcon1:SetPoint("top","SingleEditorNPCStoreItemSetItem"..i.."StarIcon","bottom",156,-32)
			itemIcon2:SetPoint("top","SingleEditorNPCStoreItemSetItem"..i.."ItemIcon1","bottom",0,-32)
		elseif t.iStarNum == 0 and  itemDef1 and not itemDef2 then
			itemIcon1:SetPoint("top","SingleEditorNPCStoreItemSetItem"..i.."StarIcon","bottom",0,-32)
		else
			itemIcon1:SetPoint("top","SingleEditorNPCStoreItemSetItem"..i.."StarIcon","bottom",156,-32)
			itemIcon2:SetPoint("top","SingleEditorNPCStoreItemSetItem"..i.."ItemIcon1","bottom",137,-32)
		end


		if t.iStarNum == 0 then
			starIcon:Hide();
			starDesc:Hide();
		else
			starIcon:Show();
			starDesc:Show();
		end


		bkg:Hide();
		swapBtn:Hide();
		editBtn:Show();
		switchBtn:Hide();
		ui_frame:Show();
		ui_frame:SetPoint("top","SingleEditorNPCStoreItemSetPlane","top",0,125*(i-1)+75)
		ui_frame:SetClientID(i);
	end
	for i = num+1, 99 do
		local uiName = "SingleEditorNPCStoreItemSetItem" .. i;
		if not HasUIFrame(uiName) then
			break
		else
			getglobal(uiName):Hide()
		end
	end
	
	addBtn:Show();
  	if num == 0 then
    	addBtn:SetPoint("top", "SingleEditorNPCStoreItemSetPlane", "top", 0, 50)
    elseif num >= 30 then
    	addBtn:Hide();
    else
    	addBtn:SetPoint("top", "SingleEditorNPCStoreItemSetPlane", "top", 0, (num)*125+75)
    end

	if height < 568 then
		height = 568;

	end
    
	getglobal("SingleEditorNPCStoreItemSetPlane"):SetHeight(height);
end


function SingleEditorFrameItemEditSwapMoveBtn_OnClick()
	local num = #NpcStore.shopItemMap;
	local index = this:GetParentFrame():GetClientID();
	for i=1,num do	
		local bkg = getglobal("SingleEditorNPCStoreItemSetItem"..i.."TransparentBkg");
		local swapBtn = getglobal("SingleEditorNPCStoreItemSetItem"..i.."SwapMoveBtn")
		local editBtn = getglobal("SingleEditorNPCStoreItemSetItem"..i.."EditBtn");
		local switchBtn = getglobal("SingleEditorNPCStoreItemSetItem"..i.."MoveSwitchBtn")

		if not swapBtn:IsShown() then
			local tempTable = deep_copy_table(NpcStore.shopItemMap[i]);
			NpcStore.shopItemMap[i] = deep_copy_table(NpcStore.shopItemMap[index])
			NpcStore.shopItemMap[index] = deep_copy_table(tempTable);

			local t = NpcStoreTable.itemList[i];
			NpcStoreTable.itemList[i] = deep_copy_table(NpcStoreTable.itemList[index])
			NpcStoreTable.itemList[index] = deep_copy_table(t)

			
			getglobal("SingleEditorFrameSortBtnBkg"):Hide();
		end

	end

	UpdateNpcStoreList();
end

function SingleEditorFrameItemEditMoveSwitchBtn_OnClick()

	local num = #NpcStore.shopItemMap;
	local index = this:GetParentFrame():GetClientID();
	for i=1,num do	
		local bkg = getglobal("SingleEditorNPCStoreItemSetItem"..i.."TransparentBkg");
		local swapBtn = getglobal("SingleEditorNPCStoreItemSetItem"..i.."SwapMoveBtn")
		if i ~= index then
			bkg:Show();
			swapBtn:Show();
		else
			bkg:Hide();
			swapBtn:Hide();
		end
	end
end

function NPCStoreEditorFeatureEditFrameOkBtn_OnClick()
	local index = NpcStoreTable.CurEditorIndex;
	NpcStoreTable.itemList[index] = deep_copy_table(NpcStoreTable.config);


	-- if NpcStore.ItemList[index] then
	-- 	NpcStore.ItemList[index] = deep_copy_table(NpcStore.Attr);
	-- else
	-- 	table.insert(NpcStore.ItemList,NpcStore.Attr);
	-- end

	SaveNpcStoreItemList();
	UpdateNpcStoreList();
	getglobal("NPCStoreEditorFeatureEditFrame"):Hide();
end





function NPCStoreEditorFeatureEditFrameDelBtn_OnClick()
	local index = NpcStoreTable.CurEditorIndex;
	table.remove(NpcStoreTable.itemList,index);
	table.remove(NpcStore.shopItemMap,index);
	UpdateNpcStoreList();
	getglobal("NPCStoreEditorFeatureEditFrame"):Hide();
end


function NPCStoreEditorRefreshBtn_OnClick(swithcName, state)
	local switch = getglobal(switchName);
	
	
	if state == 1 then
		getglobal("NPCStoreEditorFeatureEditParamFrameSlider4"):Show();
		NpcStoreTable.config.Attr[6].CurVal = 5;
		NpcStoreTable.config.Attr[7].CurVal = 1;
		NpcStoreTable.config.Attr[6].CanShow = true;
		getglobal("NPCStoreEditorFeatureEditParamFrameSlider4Bar"):SetValue(1);
	else
		getglobal("NPCStoreEditorFeatureEditParamFrameSlider4"):Hide();
		NpcStoreTable.config.Attr[6].CurVal = 0;
		NpcStoreTable.config.Attr[7].CurVal = 0;
		NpcStoreTable.config.Attr[6].CanShow = false;
	end
end

------------------------------------------------- 控件模板 -------------------------------------------------------------------
function NpcStoreSingleSelBtnTemplateNumLeftBtn_OnClick(isAdd, index)
	Log("NpcTaskSingleSelBtnTemplateNumLeftBtn_OnClick:");
	if index then
		index = index;
	else
		index = this:GetParentFrame():GetParentFrame():GetClientID();
	end

	
	local t = NpcStoreTable.config.Attr;
	local btnIndex = this:GetParentFrame():GetParentFrame():GetClientID();
	local num = t[btnIndex].CurNum;
	local id = t[btnIndex].CurVal;
	-- local leftIcon = getglobal("NPCStoreEditorFeatureEditFrameLeftPanelItemIcon"..btnIndex);
	local leftDesc = getglobal("NPCStoreEditorFeatureEditFrameLeftPanelItemDesc"..btnIndex);

	local itemDef = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);


	if isAdd then
		--加
		Log("Add:");
		if num >= 64 or not itemDef then 
			return; 
		end
		num = num + 1;
	else
		--减
		Log("Sub:");
		if num <= 1 or not itemDef then 
			return; 
		end
		num = num - 1;
	end

	t[btnIndex].CurNum = num;
	getglobal("NPCStoreEditorFeatureEditParamFrameBuyItemSet"..btnIndex.."NumVal"):SetText(t[btnIndex].CurNum);

	if itemDef then
		leftDesc:SetText(itemDef.Name.."*"..t[btnIndex].CurNum)
	end
end

function NpcStoreSingleSelBtnTemplateDel_OnClick()
	Log("NpcStoreSingleSelBtnTemplateDel_OnClick:");
	-- local index = this:GetParentFrame():GetParentFrame():GetClientID();
	local btnIndex = this:GetParentFrame():GetClientID();
	local t = NpcStoreTable.config.Attr[btnIndex];

	t.CurVal = 0;
	t.CurNum = 0;
	local icon = getglobal("NPCStoreEditorFeatureEditParamFrameBuyItemSet"..btnIndex.."Icon");
	local addIcon = getglobal("NPCStoreEditorFeatureEditParamFrameBuyItemSet"..btnIndex.."AddIcon");
	local val = getglobal("NPCStoreEditorFeatureEditParamFrameBuyItemSet"..btnIndex.."NumVal");
	local delBtn = getglobal("NPCStoreEditorFeatureEditParamFrameBuyItemSet"..btnIndex.."Del");
	local leftIcon = getglobal("NPCStoreEditorFeatureEditFrameLeftPanelItemIcon"..btnIndex);
	local leftDesc = getglobal("NPCStoreEditorFeatureEditFrameLeftPanelItemDesc"..btnIndex);
	

	delBtn:Hide();
	icon:Hide();
	addIcon:Show();
	leftIcon:Hide();
	leftDesc:Hide();
	val:SetText(t.CurNum)
end

function NpcStoreSingleSelBtnTemplateNumRightBtn_OnClick()
	local index = this:GetParentFrame():GetParentFrame():GetParentFrame():GetClientID();
	NpcStoreSingleSelBtnTemplateNumLeftBtn_OnClick(true, index);
end


function SingleEditorFrameBaseSetStoreDescEdit_OnFocusLost()
	local name = this:GetName();
	local t = NpcStoreTable.config;
	if string.find(name,"NameEditEdit") then
		t.Name = this:GetText();
		NpcStore.sShopName = this:GetText();
	elseif string.find(name,"DescEditEdit") then
		t.Desc = this:GetText();
		NpcStore.sShopDesc = this:GetText();
		getglobal("SingleEditorFrameBaseSetCommonDescTip"):Show();
		if this:GetText() == "" then
			getglobal("SingleEditorFrameBaseSetCommonDescTip"):SetText(GetS(10646), 185, 185, 185);
		end
	end
end

function SingleEditorFrameBaseSetStoreDescEdit_OnFocusGained()

	getglobal("SingleEditorFrameBaseSetStoreDescEditDescTip"):Hide();
end

--滑动条模板
function NPCStoreItemSetSliderTemplateLeftBtn_OnClick()
    local value = getglobal(this:GetParent() .. "Bar"):GetValue()
    local index = this:GetParentFrame():GetClientID()

    if index == 4 then
    	value = value - 5
    else
    	value = value - 1
    end
    if value < 0 then
        value = 0;
    elseif index == 2 or index == 3 and value < 1 then
    	value = 1;
    elseif index == 4 and value < 5 then
    	value = 5;
    end
    getglobal(this:GetParent() .. "Bar"):SetValue(value)

    NpcStoreTable.config.Attr[index+2].CurVal = tonumber(value);
end

function NPCStoreItemSetSliderTempBar_OnValueChanged()
    local value = this:GetValue()
    local ratio = (value - this:GetMinValue()) / (this:GetMaxValue() - this:GetMinValue());

    if ratio > 1 then
        ratio = 1
    end
    if ratio < 0 then
        ratio = 0
    end
    local width = math.floor(328 * ratio)
    getglobal(this:GetName() .. "Pro"):ChangeTexUVWidth(width);
    getglobal(this:GetName() .. "Pro"):SetWidth(width);

    local index = this:GetParentFrame():GetClientID()
    local valFont = getglobal(this:GetParent() .. "Desc")
    local id = NpcStoreTable.config.ItemID;
    local itemDef = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);
    if index+2 == 3 then
    	local starDesc = getglobal("NPCStoreEditorFeatureEditFrameLeftPanelStarDesc")
    	local starIcon = getglobal("NPCStoreEditorFeatureEditFrameLeftPanelStarIcon")
    	starDesc:SetText(GetS(73).."*"..value)
    	if value == 0 then
    		starDesc:Hide();
    		starIcon:Hide();
    	else
    		starDesc:Show();
    		starIcon:Show();
    	end
    elseif index+2 == 4 and itemDef then
    	getglobal("NPCStoreEditorFeatureEditFrameLeftPanelFeatureTitle"):SetText(itemDef.Name.."*"..value);
    elseif index+2 == 5 and value > 300 then
    	getglobal("NPCStoreEditorFeatureEditParamFrameSlider3Desc"):SetText(GetS(680))
    	NpcStoreTable.config.Attr[index+2].CurVal = tonumber(value);
    	return;
	elseif index+2 == 6 then
		getglobal("NPCStoreEditorFeatureEditParamFrameSlider4Desc"):SetText(value..GetS(6283))
		NpcStoreTable.config.Attr[index+2].CurVal = tonumber(value);
		return;
    end
    

    valFont:SetText(value)

    NpcStoreTable.config.Attr[index+2].CurVal = tonumber(value);
    
end

function NPCStoreItemSetSliderTemplateRightBtn_OnClick()
    local value = getglobal(this:GetParent() .. "Bar"):GetValue()
    local index = this:GetParentFrame():GetClientID()

    if index == 4 then
    	value = value + 5
    else
    	value = value + 1
    end
    
    if value > 3600 then
    	value = 3600;
    elseif index == 1 and value > 999 then
    	value = 999;
    elseif index == 2 and value > 64 then
    	value = 64;
    end
    getglobal(this:GetParent() .. "Bar"):SetValue(value)

    NpcStoreTable.config.Attr[index+2].CurVal = tonumber(value);
end

function toJsonData(def)
	-- body
	local t_info = {property={}}

	t_info.property["iShopID"] = def.iShopID
	t_info.property["sShopName"] = def.sShopName
	t_info.property["sShopDesc"] = def.sShopDesc
	t_info.property["EnglishName"] = def.EnglishName
	t_info.property["sInnerKey"] = def.sInnerKey

	-- if CurrentEditDef and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
	-- 	and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() then
	-- 	local table = def.shopItemMap
	-- 	for index, value in ipairs(table) do
	-- 		if value.iItemID and value.iItemID <= CUSTOM_MOD_QUOTE then
	-- 			value.iItemID = value.iItemID + CUSTOM_MOD_QUOTE
	-- 		end
	-- 		if value.iCostItemInfo1 and value.iCostItemInfo1 <= CUSTOM_MOD_QUOTE and value.iCostItemInfo1 > 0 then
	-- 			value.iCostItemInfo1 = value.iCostItemInfo1 + CUSTOM_MOD_QUOTE
	-- 		end
	-- 		if value.iCostItemInfo2 and value.iCostItemInfo2 <= CUSTOM_MOD_QUOTE and value.iCostItemInfo1 > 0 then
	-- 			value.iCostItemInfo2 = value.iCostItemInfo2 + CUSTOM_MOD_QUOTE
	-- 		end
	-- 	end
	-- end
	t_info.property["shopItemMap"] = def.shopItemMap

	local dataStr = JSON:encode(t_info);
	Log("t_info:");

	return dataStr;
end

function statusToJsonData(def)
	local t_info = {}

	t_info["priority"] = def.Status.Priority
	t_info["death_clear"] = def.Status.DeathClear
	t_info["attack_clear"] = def.Status.AttackClear
	t_info["damage_clear"] = def.Status.DamageClear
	t_info["icon_id"] = def.Status.IconID
	t_info["particle_id"] = def.Status.ParticleID
	t_info["sound_id"] = def.Status.SoundID
	t_info["limit_time"] = def.Status.LimitTime

	for i=1,5 do
		if def.Status.EffInfo[i-1].CopyID == 0 then break end
		local effect_info = {}
		effect_info.copy_id = def.Status.EffInfo[i-1].CopyID
		for j=1,5 do
			effect_info["value"..j] = def.Status.EffInfo[i-1].Value[j-1]
		end
		t_info["effect_info"..i] = effect_info
	end

	local dataStr = JSON:encode(t_info)
	Log("t_info:")

	return dataStr
end

function SingleEditorFrameBaseSetStore_OnShow()
	SetSingleEditorDealMsg(false)
end

function SingleEditorFrameBaseSetStore_OnHide()
	SetSingleEditorDealMsg(true)
end

function deleteTmpNpcShop()
	-- body
	if CurrentEditDef.ID == 4000 then
		CurrentEditDef.Name = ''
		CurrentEditDef.Desc = ''
	end
	local mapid = 0
	if PluginDeveloperGetMapID() then
		mapid = PluginDeveloperGetMapID()
	end
	local keys = ModEditorMgr:getNpcShopKeys(4000)
	local keylist = split(keys, "|")
	if string.len(keys) > 0 then
		for i=1,10 do
			for k,v in ipairs(keylist) do
				local def = ModEditorMgr:getNpcShopDefById(tonumber(v))
				if def then
					table.remove(keylist, k)
					ModEditorMgr:delModSlotFileById(SHOP_MOD, def.iShopID,mapid)
					break
				end
			end
		end
	end
end

function renameNpcShopInfo(npcid, innerkey)
	-- body
	local keys = ModEditorMgr:getNpcShopKeys(4000)
	local keylist = split(keys, "|")
	local mapid = 0
	if PluginDeveloperGetMapID() then
		mapid = PluginDeveloperGetMapID()
	end
	if string.len(keys) > 0 then
		for i=1,10 do
			for k,v in ipairs(keylist) do
				local def = ModEditorMgr:getNpcShopDefById(tonumber(v))
				if def then
					if npcid < 1000 then
						npcid = DefMgr:getNpcShopNpcRealId(innerkey, npcid)
					end

					NpcStore.iNpcID = npcid
					NpcStore.sShopName = def.sShopName
					NpcStore.sShopDesc = def.sShopDesc
					NpcStore.EnglishName = def.EnglishName
					NpcStore.sInnerKey = innerkey
					NpcStore.shopItemMap = {}
					local iSkuSize = def:getSkuSize()
					local skudef = nil
					for i=1,iSkuSize do
						local skuinfo = {}
						skudef = def:getNpcShopSkuDefByIdx(i-1)

						skuinfo.iSkuID = skudef.iSkuID
						skuinfo.iItemID = skudef.iItemID
						skuinfo.iOnceBuyNum = skudef.iOnceBuyNum
						skuinfo.iMaxCanBuyCount = skudef.iMaxCanBuyCount
						skuinfo.iRefreshDuration = skudef.iRefreshDuration
						skuinfo.iStarNum = skudef.iStarNum
						skuinfo.iCostItemInfo1 = skudef.iCostItemInfo1
						skuinfo.iCostItemInfo2 = skudef.iCostItemInfo2
						skuinfo.iShowAD = skudef.iShowAD or 0
						table.insert(NpcStore.shopItemMap, skuinfo)
					end

					table.remove(keylist, k)
					ModEditorMgr:delModSlotFileById(SHOP_MOD, def.iShopID,mapid)

					NpcStore.iShopID = ModEditorMgr:createNpcShop(npcid, NpcStore.sShopName, NpcStore.sShopDesc, NpcStore.EnglishName, NpcStore.sInnerKey)
					local dataStr = toJsonData(NpcStore);
					if #NpcStore.shopItemMap > 0 then
						ModEditorMgr:setNpcShopInfo(NpcStore.iShopID, dataStr);
					end

					ModEditorMgr:requestCreateShop(dataStr, NpcStore.EnglishName);
					break
				end
			end
		end
	end
end
----------------------------------------道具包裹-----------------------------------------------------------

function PackageEditorFeatureEditFrameCloseBtn_OnClick()
	getglobal("PackageEditorFeatureEditFrame"):Hide();
end

function PackageEditorFeatureEditFrameDelBtn_OnClick()
	local frame = getglobal("PackageEditorFeatureEditParamFrameSlider1");
	local index = frame:GetClientID();
	if PackGiftDef.packItemList[index] then
		table.remove(PackGiftDef.packItemList,index);
	end

	getglobal("PackageEditorFeatureEditFrame"):Hide();
	UpdateSingleEditorPackageList();

	local probability = 0;
	for i=1,#PackGiftDef.packItemList do
		probability = probability+PackGiftDef.packItemList[i].iRatio;
	end

	local color = "#cec1616";
	if probability <= 100 then
		color = "#ce48100";
	end
	getglobal("SingleEditorFramePackTip"):SetText(GetS(21769,color..probability).."%")

end

function PackageEditorFeatureEditFrameOkBtn_OnClick()
	local frame = getglobal("PackageEditorFeatureEditParamFrameSlider1");
	local bar = getglobal("PackageEditorFeatureEditParamFrameSlider1Bar");
	local index = frame:GetClientID();
	if PackGiftDef.packItemList[index].iItemInfo then
		local val = bar:GetValue();
		local itemID = math.modf(PackGiftDef.packItemList[index].iItemInfo/1000);
		PackGiftDef.packItemList[index].iItemInfo = itemID*1000+val
	end
	UpdateSingleEditorPackageList();
	getglobal("PackageEditorFeatureEditFrame"):Hide();
end

function switchPackCostItemStatus(bUseCost)
	-- body
	if bUseCost then
		PackGiftDef.iNeedCostItem = 1
	else
		PackGiftDef.iNeedCostItem = 0
	end
	print("switchPackCostItemStatus PackGiftDef.iNeedCostItem = "..PackGiftDef.iNeedCostItem)
	UpdateSingleEditorAttr()
end

function switchPackRepeatStatus(bRepeat)
	-- body
	if bRepeat then
		PackGiftDef.iRepeat = 1
	else
		PackGiftDef.iRepeat = 0
	end
end

function selectPackType(packtype)
	-- body
	PackGiftDef.iPackType = packtype
	UpdateSingleEditorAttr()
end


function CheckedPackItemProbability()
	local num = #PackGiftDef.packItemList;
	local probability = 0;
	-- local itemNum = 0;
	for i=1,num do
		probability = probability+PackGiftDef.packItemList[i].iRatio;
		-- itemNum = itemNum+(PackGiftDef.packItemList[i].iItemInfo%1000);
	end

	if (probability > 100 or probability <100) and PackGiftDef.iPackType == 1 then
		local value = 0;

    		
		for i=1,#PackGiftDef.packItemList do
			value = value+PackGiftDef.packItemList[i].iRatio;
		end

		MessageBox(4, GetS(21769,value).."%");
		return false;

	end

	if PackGiftDef.iPackType == 1 and PackGiftDef.iRepeat == 0 and PackGiftDef.iMaxOpenNum > num then
		MessageBox(4, "保存失败，请检查产出物品数");
		return false;
	end


	return true;
end



function toPackJsonData(def)
	-- body
	local t_info = {property={}}

	t_info.property["iPackID"] = def.iPackID
	t_info.property["iPackType"] = def.iPackType
	t_info.property["iMaxOpenNum"] = def.iMaxOpenNum
	t_info.property["iRepeat"] = def.iRepeat
	t_info.property["iNeedCostItem"] = def.iNeedCostItem
	t_info.property["iCostItemInfo"] = def.iCostItemInfo

	-- if CurrentEditDef and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
	-- 	and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() then
	-- 	local table = def.packItemList
	-- 	for index, value in ipairs(table) do
	-- 		if value.iItemInfo <= CUSTOM_MOD_QUOTE and value.iItemInfo > 0 then
	-- 			value.iItemInfo = value.iItemInfo + CUSTOM_MOD_QUOTE
	-- 		end
	-- 	end
	-- end

	t_info.property["packItemList"] = def.packItemList

	local dataStr = JSON:encode(t_info);
	Log("t_info:");

	return dataStr;
end

function getCurrentPackDef()
	-- body
	return PackGiftDef
end


--开发者相关

--获取操作类型
local plugin_type = {
    block = {
		[3] = 2, -- [number(显示位置)] = number(1脚本，2触发器)
		[4] = 1,
	},
    actor = {
		[6] = 2,
		[7] = 1,
	},
    item = {
		[4] = 2,
		[5] = 1,
	},
    craft = {
		[2] = 2,
		[3] = 1,
	},
    furnace = {
		[2] = 2,
		[3] = 1,
	},
    plot = {
		[3] = 2,
		[4] = 1,
	},
    status = {
		[4] = 2,
		[5] = 1,
	},
}
function PluginDeveloperGetHandleType(id,curScriptType,modpaketID)
	local name = CurEditorClass or ""
	local pluginid = id or CurrentEditDef.ID

	local scriptType = 0
	if curScriptType then 
		scriptType = curScriptType
	else
		scriptType = plugin_type[name] and plugin_type[name][CurTabIndex] or 0
	end

	if type(modpaketID) ~= "string" or modpaketID == "" then
		modpaketID = nil
	end

	return ScriptSupportCtrl:makeSSType(name, pluginid, scriptType, modpaketID) or {
		name = name,
		scripttype = scriptType,
		modpacketid = modpaketID,
	}
end 

--获取地图ID
function PluginDeveloperGetMapID()
	-- local args = FrameStack.cur()
	-- return args.owid
	if  WorldMgr then
		return  WorldMgr:getWorldId()
	end
	return nil
end

--判断地图插件库是否已经存在该插件
function IsPluginExistInMapPluginLib(defId,objType)
	local isExist = false
	local args = FrameStack.cur()
	if args and args.isMapMod then
		local totalCount =  0
		if objType == -1 then 
			totalCount =  ModEditorMgr:getCustomBlockCount()
			for i = 1,totalCount do
				local blockDef = ModEditorMgr:getBlockDef(i - 1)
				if blockDef.ID == defId then 
					isExist = true 
					break 
				end 
			end
		else
			totalCount =  ModEditorMgr:getCustomMonsterCount()
			for i = 1,totalCount do
				local actorDef = ModEditorMgr:getMonsterDef(i - 1)
				if actorDef.ID == defId then 
					isExist = true 
					break 
				end 
			end
		end  
	end 
	return isExist
end

--COPY触发器及脚本
function CopyPluginDeveloperForPlugin(orginId,targetId)
	if not ObjCloneFlag then
		return
	end

	--如果不在游戏中则不拷贝
	if ClientCurGame and ClientCurGame:isInGame() and CurWorld then

		local name = CurEditorClass
		local orginHandleType =	ScriptSupportCtrl:makeSSType(name, orginId, 1,nil,true)
		local targetHandleType = ScriptSupportCtrl:makeSSType(name, targetId, 1,nil,true)
		-- 都会被复制
		orginHandleType.scripttype = 1
		targetHandleType.scripttype = 1
		--拷贝之前先获取一次(获取时会加载)
		local data = ScriptSupportCtrl:getScriptList(CurWorld:getOWID(), orginHandleType)
		ScriptSupportCtrl:cloneScript(orginHandleType,targetHandleType)
		orginHandleType.scripttype = 2
		targetHandleType.scripttype = 2
		--拷贝之前先获取一次(获取时会加载)
		data = ScriptSupportCtrl:getScriptList(CurWorld:getOWID(), orginHandleType)
		ScriptSupportCtrl:cloneScript(orginHandleType,targetHandleType)
	end
end
