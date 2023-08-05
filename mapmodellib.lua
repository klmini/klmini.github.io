
local MODEL_GRID_MAX = 440;
local MODEL_CLASS_MAX = 48;

local LongPressGridIndex  = -1;	--长按的格子;
local IsLongPressGrid;

local t_SelectModelList = {}; --选中的模型列表
local t_NewAddModel = {};

local t_MapModelClass = {};
local t_ResModelClass = {};

local CurLabType = MAP_MODEL_CLASS  --MAP_MODEL_CLASS 地图模型 RES_MODEL_CLASS资源库
local CurModelClass;  		--当前选中的文件夹
local CurModelClassIndex;   --当前选中的文件夹下标
local t_PreLabChooseClassIndex = {}; --记录之前选中的下标，跳转回来的时候自己跳转到这个下标的文件夹

function GetRealClassName(classname)
	if classname == "default" then
		return GetS(3462);
	end
	local filtered_classname = DefMgr:filterString(classname)
	return filtered_classname;
end

function GetModelClassNameByIndex(lab, index)
	if lab == MAP_MODEL_CLASS and t_MapModelClass[index] then
		return t_MapModelClass[index].classname;
	elseif lab == RES_MODEL_CLASS and t_ResModelClass[index] then
		return t_ResModelClass[index].classname;
	end

	return "";
end

function SetModelLibShortcutCheckGrid(gridName)
	for i=1, MAX_SHORTCUT do
		local check = getglobal("MapModelLibFrameShortcutGrid"..i.."Check");
		check:Hide();
	end

	if gridName ~= nil then
		local check = getglobal(gridName.."Check");
		check:Show();
	end
end

function clearMapNewAddModel()
	t_NewAddModel = {};
end

function IsNewModel(id)
	return t_NewAddModel[id]
end

function ModelGridTemplate_OnClick()
	if getglobal("MapModelLibFrameManage"):IsShown() then
		local filename = this:GetClientString();
		local checked = getglobal(this:GetName().."SelectChecked");
		local tick = getglobal(this:GetName().."SelectTick");
		if checked:IsShown() then
			checked:Hide();
			tick:Hide();
			UpdateSelectModelList("remove", filename);
		else
			checked:Show();
			tick:Show();
			UpdateSelectModelList("add", filename);
		end
	else
		if LongPressGridIndex >= 0 then return end
		if IsLongPressGrid then return end
		local btnName = this:GetName();

		local clientId = this:GetClientID();
		if clientId == 0 then return end
		local grid_index = clientId - 1;

		SetOnclikItemBoxTexture( this:GetName() );
		local itemDef = ItemDefCsv:get(clientId);
		selectCreateItemId = clientId;
		UpdateTipsFrame(itemDef.Name, 1, clientId, grid_index, btnName);
	end
end

function ModelGridTemplate_OnMouseDown()
	if getglobal("MapModelLibFrameManage"):IsShown() then
		return;
	end

	LongPressGridIndex = this:GetClientID() - 1;
	IsLongPressGrid = false;
end

function ModelGridTemplate_OnMouseUp()
	local tmp = this:GetClientID() - 1;
	if LongPressGridIndex >= 0 and LongPressGridIndex == tmp then
		LongPressGridIndex = -1;
	end
end

function ModelGridTemplate_OnMouseDownUpdate()
end

function ModelGridTemplate_OnClick_PC()
	if getglobal("MapModelLibFrameManage"):IsShown() then
		local filename = this:GetClientString();
		local checked = getglobal(this:GetName().."SelectChecked");
		local tick = getglobal(this:GetName().."SelectTick");
		if checked:IsShown() then
			checked:Hide();
			tick:Hide();
			UpdateSelectModelList("remove", filename);
		else
			checked:Show();
			tick:Show();
			UpdateSelectModelList("add", filename);
		end
	end
end

function ModelGridTemplate_OnMouseDown_PC()
	if getglobal("MapModelLibFrameManage"):IsShown() then
		return;
	end

	UIEndDrag("MousePickItem");

	local clientId = this:GetClientID();
	if clientId <= 0 then return end	

	local btnName = this:GetName();
	local shiftpressed = string.find(arg2, "S") ~= nil;
	local controlpressed = string.find(arg2, "C") ~= nil;

	PickGridItemCreate(clientId, arg1==VK_RBUTTON, shiftpressed);
	IsMapModelLibGrid = true;
end

function ModelGridTemplate_OnMouseUp_PC()

end

function ModelGridTemplate_OnMouseEnter_PC()
	if getglobal("MItemTipsFrame"):GetClientID() > 0 then return end	--按下了alt

	local clientId = this:GetClientID();
	local btnName = this:GetName();
	
	CurSelectGridIndex = clientId-1;

	local itemDef = ItemDefCsv:get(clientId);
	SetMTipsInfo(-1, btnName, true, clientId);
end

function ModelGridTemplate_OnMouseLeave_PC()
	if getglobal("MItemTipsFrame"):GetClientID() > 0 then return end	--按下了alt
	CurSelectGridIndex = -1;
	HideMTipsInfo();
end


function MapModelLibFrameCloseBtn_OnClick()
	getglobal("MapModelLibFrame"):Hide();
end

function ModelGridTemplateSelect_OnClick()
	local filename = this:GetParentFrame():GetClientString();

	local checked = getglobal(this:GetName().."Checked");
	if checked:IsShown() then
		checked:Hide();
		getglobal(this:GetName().."Tick"):Hide();
		UpdateSelectModelList("remove", filename);
	else
		checked:Show();
		getglobal(this:GetName().."Tick"):Show();
		UpdateSelectModelList("add", filename);
	end
end

function UpdateSelectModelList(type, filename)
	if type == "add" then
		table.insert(t_SelectModelList, filename);
		UpdateBtnByManager();
	elseif type == "remove" then
		for i=1, #(t_SelectModelList) do
			if t_SelectModelList[i] == filename then
				table.remove(t_SelectModelList, i);
				UpdateBtnByManager();
				return;
			end
		end
	end
end

function HideModelListBoxItemTexture(gridName)
	for i=1, MODEL_GRID_MAX do
		local boxTexture = getglobal("MapModelLibFrameModelListBoxItem"..i.."Check");
		boxTexture:Hide();
	end
	selectCreateItemId = -1;

	if gridName ~= nil then
		local check = getglobal(gridName.."Check");
		check:Show();
	end
end

function MapModelLibFrame_OnLoad()
	this:RegisterEvent("GE_ADD_CUSTOMMODEL");

	local gridLayoutManager = LayoutManagerFactory:newGridLayoutManager()
		:setPoint("topleft")
		:setRelativeTo("MapModelLibFrameClassFrameBoxPlane")
		:setRelativePoint("topleft")
		:setBoxItemNamePrefix("MapModelLibFrameClassFrameBoxClass")
		:setOffsetX(0)
		:setOffsetY(0)
		:setMarginX(20)
		:setMarginY(20)
		:setBoxItemWidth(180)
		:setBoxItemHeight(220)
		:setMaxColumn(5)
		:resetPlaneWithMinimalSize(978, 588)
		:setHorizontal(true)
		:layoutAll(MODEL_CLASS_MAX)

	gridLayoutManager
		:onRecycle()
		:setPoint("left")
		:setRelativeTo("MapModelLibFrameShortcut")
		:setRelativePoint("left")
		:setBoxItemNamePrefix("MapModelLibFrameShortcutGrid")
		:setOffsetX(16)
		:setOffsetY(-3)
		:setMarginX(12)
		:setMarginY(0)
		:setBoxItemWidth(92)
		:setBoxItemHeight(92)
		:setMaxColumn(8)
		:setHorizontal(true)
		:layoutAll(MAX_SHORTCUT)

	gridLayoutManager
		:onRecycle()
		:setPoint("topleft")
		:setRelativeTo("MapModelLibFrameModelListBoxPlane")
		:setRelativePoint("topleft")
		:setBoxItemNamePrefix("MapModelLibFrameModelListBoxItem")
		:setOffsetX(0)
		:setOffsetY(12)
		:setMarginX(13)
		:setMarginY(11)
		:setMaxColumn(10)
		:setHorizontal(true)
		:resetPlaneWithMinimalSize(978, 600)
		:layoutAll(MODEL_GRID_MAX)
		:recycle()

	for i=1, 8 do
		getglobal("MapModelLibFrameShortcutGrid" .. i .. "Num"):SetText(tostring(i));
	end
end

function MapModelLibFrame_OnEvent()
	if arg1 == "GE_ADD_CUSTOMMODEL" then
		local ge = GameEventQue:getCurEvent();
		t_NewAddModel[ge.body.addCustomModel.id] = true;
		--table.insert(t_NewAddModel, ge.body.addCustomModel.id);
		if not getglobal("GongNengFrameModelLibBtnRedTag"):IsShown() then
			getglobal("GongNengFrameModelLibBtnRedTag"):Show();
		end
	end
end

function SetCurPitchLab(labtype)
	local t_lab = {[MAP_MODEL_CLASS] = "MapModelLibFrameLabMap", [RES_MODEL_CLASS] = "MapModelLibFrameLabRes"};

	CurLabType = labtype;
	for k, v in pairs(t_lab) do
		local normal = getglobal(v.."Normal");
		local checked = getglobal(v.."Checked")
		local name = getglobal(v.."Name");
		if k == labtype then
			normal:Hide();
			checked:Show();
			name:SetTextColor(255, 153, 63);
			name:SetFontSize(28);
			name:SetPoint("center", v, "center", 4, 0);
		else
			normal:Show();
			checked:Hide();
			name:SetTextColor(158, 225, 231);
			name:SetFontSize(24);
			name:SetPoint("center", v, "center", 0, 0);
		end
	end


	getglobal("MapModelLibFrameShortcut"):Hide();
	getglobal("MapModelLibFrameManage"):Hide();

	if t_PreLabChooseClassIndex[CurLabType] then
		ModelClassTemplate_OnClick(t_PreLabChooseClassIndex[CurLabType]);
	else
		UpdateModelClassFrame();
		getglobal("MapModelLibFrameModelList"):Hide();
		getglobal("MapModelLibFrameClassFrame"):Show();
	end
end

function MapModelLibFrameLab_OnClick()
	if string.find(this:GetName(), "LabMap") then
		SetCurPitchLab(MAP_MODEL_CLASS);
	elseif string.find(this:GetName(), "LabRes") then
		if IsRoomClient() then --客机不能用资源库
			ShowGameTips(GetS(3945, 3));
			return;
		end

		SetCurPitchLab(RES_MODEL_CLASS);
	end
end

---------------------------------------ModelClass_BEGIN----------------------------------------------

function ModelClassAddBtn_OnClick()
	if AccountManager:getMultiPlayer() > 0 then --联机不能增加文件夹
		ShowGameTips(GetS(3945, 3));
		return;
	end
	getglobal("ModelClassModifyFrame"):SetClientString("add");
	getglobal("ModelClassModifyFrame"):Show();
end

function SetModelIcon(icon, modelfilename, modeltype)
	print("SetModelIcon", modelfilename, modeltype)
	modeltype = modeltype and modeltype or BLOCK_MODEL;
	local u = 0;
	local v = 0;
	local width = 0;
	local height = 0;
	local r = 255;
	local g = 255;
	local b = 255;
	
	if modeltype >= IMPORT_BLOCK_MODEL and modeltype <= IMPORT_MODEL_MAX then
		h, u, v, width, height, r, g, b = ImportCustomModelMgr:getModelIcon(modelfilename, u, v, width, height, r, g, b);
		
		print("kekeke SetModelIcon ImportCustomModelMgr", u, v, width, height, r, g, b);
	elseif modeltype >= FULLY_BLOCK_MODEL or modeltype == -1 then
		h, u, v, width, height, r, g, b = FullyCustomModelMgr:getModelIcon(modelfilename, modeltype, u, v, width, height, r, g, b);
		
		print("kekeke SetModelIcon FullyCustomModelMgr", u, v, width, height, r, g, b);
	end

	if modeltype < FULLY_BLOCK_MODEL and width == 0 then
		h, u, v, width, height, r, g, b = CustomModelMgr:getModelIcon(modelfilename, modeltype, u, v, width, height, r, g, b);
		
		print("kekeke SetModelIcon CustomModelMgr", u, v, width, height, r, g, b);
	end

	if width == 0 then
		icon:SetTexture("items/hand.png", true);
	else
		icon:SetTextureHuires(h);
		icon:SetTexUV(u, v, width, height);
		icon:SetColor(r, g, b);
	end
end

function SetVehicleModelIcon(icon, itemid, modelfilename, userdatastr, modeltype)
--	print("SetVehicleModelIcon",itemid, modelfilename, userdatastr, modeltype)
	modeltype = modeltype and modeltype or BLOCK_MODEL;
	local u = 0;
	local v = 0;
	local width = 0;
	local height = 0;
	local r = 255;
	local g = 255;
	local b = 255;
	h, u, v, width, height, r, g, b = VehicleMgr:getModelIcon(itemid, modelfilename, userdatastr, modeltype, u, v, width, height, r, g, b);
	icon:SetTextureHuires(h);
	icon:SetTexUV(u, v, width, height);
	icon:SetColor(r, g, b);
end

function UpdateOneModelClassList(t, listui, lab, modelType)
	print("kekeke UpdateOneModelClassList t:", t, #(t));

	for i=1, 9 do
		local icon = getglobal(listui:GetName().."Icon"..i);
		local iconBkg = getglobal(listui:GetName().."IconBkg"..i);
		if i <= #(t) then
			icon:Show();
			iconBkg:Show();
			modelType = t[i].modeltype and t[i].modeltype or modelType;
			SetModelIcon(icon, t[i].filename, modelType);
			if t[i].canchoose then
				icon:SetGray(false);
			else
				icon:SetGray(true);
			end
		else
			icon:Hide();
			iconBkg:Hide();
		end
	end
end


--t_modelType 所需的模型类型
function GetOneClassAllModel(lab, classInfo, t_modelType)
	local t = {};
	local num = classInfo:getModelNum();
	for i=1, num do
		local modelfilename = classInfo:getModelName(i-1);
		local modelStatus = classInfo:getResourceLocalStatus(i-1);
		local resId = classInfo:getNetIdentifier(i-1)
		local isInBanResList = IsResourceInBanResList(i-1)
		if lab == MAP_MODEL_CLASS then
			local customItem = CustomModelMgr:getCustomItem(modelfilename);
			local customModel = nil;
			if customItem then  -- modelType -2除生物模型之外
				if customItem.type >= FULLY_BLOCK_MODEL then
					local canChoose = t_modelType.fcm;
					if isInBanResList then
						-- 违禁资源
						canChoose = nil
					end
					if customItem.type == FULLY_ACTOR_MODEL then
						local modelName = GetS(16020);
						local itemDef = ItemDefCsv:get(customItem.involvedid);
						if itemDef then
							modelName = itemDef.Name;
						end
						table.insert(t, {id=customItem.involvedid, filename=modelfilename, modeltype=customItem.type, canchoose=canChoose, status=modelStatus, resId=resId});
					else
						local modelName = GetS(16020);
						if customItem.type == FULLY_PACKING_CUSTOM_MODEL then
							modelName = GetS(16021);
						end

						local itemDef = ItemDefCsv:get(customItem.itemid);
						if itemDef then
							modelName = itemDef.Name;
						end
						
						table.insert(t, {id=customItem.itemid, filename=modelfilename, modelname=modelName, modeltype=customItem.type, canchoose=canChoose, status=modelStatus, resId=resId});
					end
					local fullyCustomModel = FullyCustomModelMgr:findFullyCustomModel(MAP_MODEL_CLASS, modelfilename, true);
					if not fullyCustomModel and IsRoomClient() then
						FullyCustomModelMgr:addDownload(modelfilename)
					end
				elseif customItem.type >= IMPORT_BLOCK_MODEL and customItem.type <= IMPORT_MODEL_MAX then -- 导入模型
					if t_modelType.icm ~= nil then --如果不设置icm，则认为不需要显示在列表里，如果不操作，设置false即可
						local canChoose = t_modelType.icm;
						if isInBanResList then
							-- 违禁资源
							canChoose = nil
						end
						if customItem.type == IMPORT_ACTOR_MODEL then
							local modelName = GetS(16020);
							local itemDef = ItemDefCsv:get(customItem.involvedid);
							if itemDef then
								modelName = itemDef.Name;
							end
							table.insert(t, {id=customItem.involvedid, filename=modelfilename, modeltype=customItem.type, canchoose=canChoose, status=modelStatus, resId=resId});
						else
							local modelName = GetS(16020);
							local itemDef = ItemDefCsv:get(customItem.itemid);
							if itemDef then
								modelName = itemDef.Name;
							end
							table.insert(t, {id=customItem.itemid, filename=modelfilename, modelname=modelName, modeltype=customItem.type, canchoose=canChoose, status=modelStatus, resId=resId});
						end
						local importCustomModel = ImportCustomModelMgr:findImportCustomModel(MAP_MODEL_CLASS, modelfilename)
						if not importCustomModel and IsRoomClient() then
							WorldMgr:addWaitDownloadRes(modelfilename,2) -- 下载类型IMPORT_MODEL=2
						end
					end
				else --if t_modelType[customItem.type] then
					local canChoose =  t_modelType[customItem.type];
					if isInBanResList then
						-- 违禁资源
						canChoose = nil
					end
					if customItem.type == ACTOR_MODEL then
						local actorModelData = CustomModelMgr:findCustomActorModelData(MAP_MODEL_CLASS, modelfilename);

						local modelName = GetS(16019);
						if actorModelData then
							modelName = actorModelData.modelname;
						end

						if IsRoomClient() or actorModelData then
							table.insert(t, {id=customItem.involvedid, filename=modelfilename, modelname=modelName, modeltype=ACTOR_MODEL, canchoose=canChoose, status=modelStatus, resId=resId});
						end
					--elseif customItem.type >= FULLY_BLOCK_MODEL then
					--	table.insert(t, {id=customItem.itemid, filename=modelfilename});
					else
						local modelName = GetS(16018);
						if customItem.type == BLOCK_MODEL then 
							modelName = GetS(16017);
						end
						local itemDef = ItemDefCsv:get(customItem.itemid);
						if itemDef then
							modelName = itemDef.Name;
						end

						customModel = CustomModelMgr:getCustomModel(MAP_MODEL_CLASS, modelfilename);
						if IsRoomClient() then
							table.insert(t, {id=customItem.itemid, filename=modelfilename, modelname=modelName, modeltype=customItem.type, canchoose=canChoose, status=modelStatus, resId=resId});
						elseif customModel and customModel:getItemID() > 0 then
							table.insert(t, {id=customItem.itemid, filename=modelfilename, modelname=modelName, modeltype=customItem.type, canchoose=canChoose, status=modelStatus, resId=resId});
						end
					end
				end
			end
		else

			local customModel = CustomModelMgr:getCustomModel(RES_MODEL_CLASS, modelfilename);
			
			if customModel then 
				--if t_modelType[customModel:getModelType() then
					local canChoose = t_modelType[customModel:getModelType()];
					if isInBanResList then
						-- 违禁资源
						canChoose = nil
					end
					local modelName = GetS(16018);
					if customModel:getModelType() == BLOCK_MODEL then 
						modelName = GetS(16017);
					end

					if customModel:getModelName() ~= "" then
						modelName=customModel:getModelName()
					end
					table.insert(t, {filename=modelfilename, modeltype=customModel:getModelType(), modelname=modelName, canchoose=canChoose, status=modelStatus, resId=resId});
				--end
			else
				local actorModelData = CustomModelMgr:findCustomActorModelData(RES_MODEL_CLASS, modelfilename)
				if actorModelData then
					--if t_modelType[ACTOR_MODEL] then
						local canChoose = t_modelType[ACTOR_MODEL];
						if isInBanResList then
							-- 违禁资源
							canChoose = nil
						end
						local modelName = GetS(16019);
						if actorModelData.modelname ~= "" then
							modelName=actorModelData.modelname;
						end
						table.insert(t, {filename=modelfilename, modeltype=ACTOR_MODEL, modelname=modelName, canchoose=canChoose, status=modelStatus, resId=resId});
					--end
				else
					local fullyCustomModel = FullyCustomModelMgr:findFullyCustomModel(RES_MODEL_CLASS, modelfilename, true);
					local importCustomModel = ImportCustomModelMgr:findImportCustomModel(RES_MODEL_CLASS, modelfilename)

					if fullyCustomModel then
						--if t_modelType.fcm then
							local canChoose = t_modelType.fcm;
							if isInBanResList then
								-- 违禁资源
								canChoose = nil
							end
							local fcmtype = fullyCustomModel:getModelType();
							local modelName = GetS(16020);
							if fcmtype == FULLY_PACKING_CUSTOM_MODEL then
								modelName = GetS(16021);
							end
							if fullyCustomModel:getName() ~= "" then
								modelName=fullyCustomModel:getName();
							end
							table.insert(t, {filename=modelfilename, modeltype=fcmtype, modelname=modelName, canchoose=canChoose, status=modelStatus, resId=resId});
						--end
					-- elseif IsRoomClient() then --资源总库客机无需操作
						-- FullyCustomModelMgr:addDownload(modelfilename);
					end

					if t_modelType.icm ~= nil then -- 如果不设置icm，则认为不需要显示在列表里，如果不操作，设置false即可
						-- 高比例模型，官方模型
						if importCustomModel then
							local canChoose = t_modelType.icm
							if isInBanResList then
								-- 违禁资源
								canChoose = nil
							end
							local icmType = importCustomModel:getModelType()
							local modelName = GetS(16020) -- str:自定义模型
							if importCustomModel:getName() ~= "" then
								modelName = importCustomModel:getName()
							end
							table.insert(t, {filename=modelfilename, modeltype=icmType, modelname=modelName, canchoose=canChoose, status=modelStatus, resId=resId});
						end
					end
				end
			end
		end
	end

	return t;
end

function LoadModelClassInfo()
	t_MapModelClass = {};
	t_ResModelClass = {};

	local num = ResourceCenter:getResClassNum(MAP_LIB);
	for i=1, num do
		local classInfo = ResourceCenter:getClassInfo(MAP_LIB, i-1);
		if classInfo then
			local t = GetOneClassAllModel(MAP_MODEL_CLASS, classInfo, {[BLOCK_MODEL]=true, [WEAPON_MODEL]=true, 
				[GUN_MODEL]=true, [PROJECTILE_MODEL]=true, [BOW_MODEL]=true, [ACTOR_MODEL]=true, fcm=true});
			table.insert(t_MapModelClass, {classname=classInfo.classname, info=t});
		end
	end

	num = ResourceCenter:getResClassNum(PUBLIC_LIB);
	for i=1, num do
		local classInfo = ResourceCenter:getClassInfo(PUBLIC_LIB, i-1);
		if classInfo then
			local t = GetOneClassAllModel(RES_MODEL_CLASS, classInfo, {[BLOCK_MODEL]=true, [WEAPON_MODEL]=true,
			 [GUN_MODEL]=true, [PROJECTILE_MODEL]=true, [BOW_MODEL]=true, [ACTOR_MODEL]=true, fcm=true});
			table.insert(t_ResModelClass, {classname=classInfo.classname, info=t});
		end
	end

	print("kekeke LoadModelClassInfo t_MapModelClass", t_MapModelClass)
	print("kekeke LoadModelClassInfo----------------------------------------------------------")
	print("kekeke LoadModelClassInfo t_ResModelClass", t_ResModelClass)
end

function UpdateModelClassFrame(forceLoad)
	local getglobal = getglobal;
	local t_ModelClass = t_MapModelClass;
	if CurLabType == RES_MODEL_CLASS then
		t_ModelClass = t_ResModelClass;
	end

	print("kekeke------------t_ModelClass:", t_ModelClass);

	local index = 1;
	for i=1, #(t_ModelClass) do
		local class = getglobal("MapModelLibFrameClassFrameBoxClass"..index);
		class:Show();
		class:SetClientString(t_ModelClass[i].classname);

		local list = getglobal("MapModelLibFrameClassFrameBoxClass"..index.."List");
		local emptyIcon = getglobal("MapModelLibFrameClassFrameBoxClass"..index.."EmptyIcon");
		local classNameUI = getglobal("MapModelLibFrameClassFrameBoxClass"..index.."Name");

		classNameUI:SetText(GetRealClassName(t_ModelClass[i].classname));

		local num = #(t_ModelClass[i].info);
		if num > 0 then
			list:Show();
			emptyIcon:Hide();
			UpdateOneModelClassList(t_ModelClass[i].info, list, CurLabType);
		else
			list:Hide();
			emptyIcon:Show();
		end

		index = index + 1;
	end

	local num = index - 1;
	local btn = getglobal("MapModelLibFrameClassFrameBoxAddBtn");
	if num >= MODEL_CLASS_MAX then
		btn:Hide();
	else
		num = num+1;
		local i = math.ceil(num/5);
		local j = (num - 1) %5 + 1;
		btn:SetPoint("topleft", "MapModelLibFrameClassFrameBoxPlane", "topleft", (j-1)*200, (i-1)*240);
		btn:Show();
	end

	print("kekeke------------t_ModelClass index:", index);
	for i=index, MODEL_CLASS_MAX do
		local class = getglobal("MapModelLibFrameClassFrameBoxClass"..i);
		class:Hide();
	end

	if num < 11 then
		getglobal("MapModelLibFrameClassFrameBoxPlane"):SetHeight(588)
	else
		local column = math.ceil(num / 5);
		getglobal("MapModelLibFrameClassFrameBoxPlane"):SetHeight(240*column - 20);
	end
end

function ModelClassTemplate_OnClick(putIndex)
	local index = 0;
	if putIndex then
		index = putIndex;
	else
		index = this:GetClientID();
		print("kekeke ModelClassTemplate_OnClick index", index);
	end

	if index <= 0 then
		return;
	end

	local btnName = this:GetName();
	if string.find(btnName, "ModCustomModelClassBoxClass") then
		ModCustomModelClassClick(index);
	elseif string.find(btnName, "ActorEditSelectModelClass") then
		ActorEditMgr:ActorEditSelectModelClassClick(index);
	elseif string.find(btnName, "FullyCustomModelEditorSelectModelClass") then
		GetInst("UIManager"):GetCtrl("FullyCustomModelEditor"):SelectModelFrameModelClassClicked(index);
	elseif string.find(btnName, "FullyCustomModelImportClass") then
		GetInst("UIManager"):GetCtrl("FullyCustomModelImport"):ModelClassClicked(index);
	else
		if not putIndex and string.find(this:GetName(), "Move") then
			SetMoveClassIndex(index);
			return;
		end

		local t_ModelClass = t_MapModelClass;
		if CurLabType == RES_MODEL_CLASS then
			t_ModelClass = t_ResModelClass;
		end

		if t_ModelClass[index] then
			--CurModelClass = className;
			CurModelClassIndex = index;
			t_PreLabChooseClassIndex[CurLabType] = index;
			if CurLabType == MAP_MODEL_CLASS then
				getglobal("MapModelLibFrameShortcut"):Show();
                for i=1, MAX_SHORTCUT do
					MapModelShortCutFrame_UpdateOneGrid(((ClientBackpack and ClientBackpack:getShortcutStartIndex()) or SHORTCUT_START_INDEX)+i-1)
				end
			else
				getglobal("MapModelLibFrameManage"):Show();
			end

			local className = GetModelClassNameByIndex(CurLabType, index);
			getglobal("MapModelLibFrameModelListName"):SetText(GetRealClassName(className));
			--if className == "default" or AccountManager:getMultiPlayer() == 2 then
			if className == "default" or AccountManager:getMultiPlayer() > 0 then
				getglobal("MapModelLibFrameModelListModifyBtnNormal"):SetGray(true);
				getglobal("MapModelLibFrameModelListModifyBtnPushedBG"):SetGray(true);
				getglobal("MapModelLibFrameModelListDelBtnNormal"):SetGray(true);
				getglobal("MapModelLibFrameModelListDelBtnPushedBG"):SetGray(true);
			else
				getglobal("MapModelLibFrameModelListModifyBtnNormal"):SetGray(false);
				getglobal("MapModelLibFrameModelListModifyBtnPushedBG"):SetGray(false);
				getglobal("MapModelLibFrameModelListDelBtnNormal"):SetGray(false);
				getglobal("MapModelLibFrameModelListDelBtnPushedBG"):SetGray(false);
			end

			UpdateModelList();
			getglobal("MapModelLibFrameClassFrame"):Hide();
			getglobal("MapModelLibFrameModelList"):Show();
		end
	end
end

---------------------------------------ModelClass_END----------------------------------------------
local function getStatisticsClassNumType()
	local num = #(t_ResModelClass);
	if num > 40 then
		return 6;
	elseif num > 20 then
		return 5;
	elseif num > 10 then
		return 4;
	elseif num > 5 then
		return 3;
	elseif num > 1 then
		return 2;
	elseif num == 1 then
		return 1;
	end

	return 0;
end

function MapModelLibFrame_OnShow()
	HideAllFrame("MapModelLibFrame", true);

	if not getglobal("MapModelLibFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end

	for i=1, MAX_SHORTCUT do
		local check = getglobal("MapModelLibFrameShortcutGrid"..i.."Check");
		check:Hide();
	end

	t_MapModelClass = {};
	t_ResModelClass = {};
	LoadModelClassInfo();
	SetCurPitchLab(MAP_MODEL_CLASS);

	local wdesc = AccountManager:getCurWorldDesc();
	if AccountManager:getMultiPlayer() ~= 0 or (wdesc and wdesc.realowneruin ~= AccountManager:getUin()) then --联机或者下载的地图
		getglobal("MapModelLibFrameShortcutManageBtnNormal"):SetGray(true);
		getglobal("MapModelLibFrameShortcutManageBtnPushedBG"):SetGray(true);
	else
		getglobal("MapModelLibFrameShortcutManageBtnNormal"):SetGray(false);
		getglobal("MapModelLibFrameShortcutManageBtnPushedBG"):SetGray(false);
	end

	local lastTime = getkv("statistics_modelclass_time");
	local curTime = AccountManager:getSvrTime();
	if not lastTime or (curTime > lastTime and not AccountManager:isSameDay(lastTime, curTime)) then
		setkv("statistics_modelclass_time", curTime);
		local type = getStatisticsClassNumType();
		if type > 0 then
			statisticsGameEvent(30020, "%d", type);
		end
	end
end

function MapModelLibFrame_OnHide()
	t_SelectModelList = {};
	t_NewAddModel = {};
	t_PreLabChooseClassIndex = {};

	ShowMainFrame();

	if not getglobal("MapModelLibFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end

	UIEndDrag("MousePickItem");
end

function MapModelLibFrame_OnClick()
	UIEndDrag("MousePickItem");
end

function MapModelShortCutFrame_UpdateOneGrid(grid_index)
    local n = grid_index+1;
    local startIndex = ((ClientBackpack and ClientBackpack:getShortcutStartIndex()) or SHORTCUT_START_INDEX)
	if grid_index >= startIndex then
		n = n - startIndex
	end

	local ShortcutBtn = getglobal("MapModelLibFrameShortcutGrid"..n);
	local ShortcutIcon = getglobal("MapModelLibFrameShortcutGrid"..n.."Icon");
	local ShortcutNum = getglobal("MapModelLibFrameShortcutGrid"..n.."Count");
	local ShortDurBkg = getglobal("MapModelLibFrameShortcutGrid"..n.."DurBkg");
	local ShortDur = getglobal("MapModelLibFrameShortcutGrid"..n.."Duration");

	UpdateGridContent(ShortcutIcon, ShortcutNum, ShortDurBkg, ShortDur, grid_index);
	
	local ban = getglobal("MapModelLibFrameShortcutGrid"..n.."Ban");
	CheckItemIsBan(grid_index, ban, ShortcutIcon);
end

--文件夹修改名字
function ModelClassNameModifyBtn_OnClick()
	if AccountManager:getMultiPlayer() > 0 then --联机不能修改文件夹
		ShowGameTips(GetS(3945), 3);
		return;
	end

	local t_ModelClass = t_MapModelClass;
	if CurLabType == RES_MODEL_CLASS then
		t_ModelClass = t_ResModelClass;
	end

	if t_ModelClass[CurModelClassIndex] then
		local classname = t_ModelClass[CurModelClassIndex].classname;
		if classname == "default" then
			ShowGameTips(GetS(3913), 3);
			return;
		end

		getglobal("ModelClassModifyFrame"):SetClientString("modify");
		getglobal("ModelClassModifyFrameContentNameEdit"):SetText(classname);
		getglobal("ModelClassModifyFrame"):Show();
	end
end

--删除文件夹
function ModelClassNameDelBtn_OnClick()
	if AccountManager:getMultiPlayer() > 0 then --联机不能删除文件夹
		ShowGameTips(GetS(3945), 3);
		return;
	end

	local t_ModelClass = t_MapModelClass;
	if CurLabType == RES_MODEL_CLASS then
		t_ModelClass = t_ResModelClass;
	end

	if t_ModelClass[CurModelClassIndex] then
		local classname = t_ModelClass[CurModelClassIndex].classname;
		if classname == "default" then
			ShowGameTips(GetS(3913), 3);
			return;
		end

		local stringId = 3916
		if #(t_ModelClass[CurModelClassIndex].info) > 0 then
			stringId = 3943
		end

		MessageBox(5, GetS(stringId), function(btn)
			if btn == "left" then
				if ResourceCenter:delClass(CurLabType, CurModelClassIndex-1) then
					LoadModelClassInfo();
					t_PreLabChooseClassIndex[CurLabType] = nil;
					UpdateModelClassFrame();
					getglobal("MapModelLibFrameModelList"):Hide();
					getglobal("MapModelLibFrameClassFrame"):Show();
				end
			end
		end)
	end
end

function ModelListBackBtn_OnClick()
	t_PreLabChooseClassIndex[CurLabType] = nil;
	UpdateModelClassFrame();
	getglobal("MapModelLibFrameClassFrame"):Show();
	getglobal("MapModelLibFrameModelList"):Hide();
end

function MapModelLibFrameModelList_OnShow()
	local t_ModelClass = t_MapModelClass;
	if CurLabType == RES_MODEL_CLASS then
		t_ModelClass = t_ResModelClass;
	end

	if not t_ModelClass[CurModelClassIndex] or #(t_ModelClass[CurModelClassIndex].info ) <= 0 then
		getglobal("MapModelLibFrameModelListEmptyIcon"):Show();
		getglobal("MapModelLibFrameModelListEmptyTips"):Show();
	else
		getglobal("MapModelLibFrameModelListEmptyIcon"):Hide();
		getglobal("MapModelLibFrameModelListEmptyTips"):Hide();
	end
end

function MapModelLibFrameModelList_OnHide()
	getglobal("MapModelLibFrameShortcut"):Hide();
	getglobal("MapModelLibFrameManage"):Hide();
end

--[[
	更新打开文件夹的小格子界面
 ]]
function UpdateModelList()
	local t_ModelClass = t_MapModelClass;
	if CurLabType == RES_MODEL_CLASS then
		t_ModelClass = t_ResModelClass;
	end

	if not t_ModelClass[CurModelClassIndex] then
		return;
	end

	local t_OneClassModelList = t_ModelClass[CurModelClassIndex];
	for i=1, MODEL_GRID_MAX do
		local item = getglobal("MapModelLibFrameModelListBoxItem"..i);
		if i <= #(t_OneClassModelList.info) then
			item:Show();

			local icon = getglobal(item:GetName().."Icon");

			if CurLabType == MAP_MODEL_CLASS then
				SetItemIcon(icon, t_OneClassModelList.info[i].id);
				item:SetClientString(t_OneClassModelList.info[i].filename);
				item:SetClientID(t_OneClassModelList.info[i].id);
			elseif CurLabType == RES_MODEL_CLASS then
				SetModelIcon(icon, t_OneClassModelList.info[i].filename, t_OneClassModelList.info[i].modeltype);
				item:SetClientID(0);
				item:SetClientString(t_OneClassModelList.info[i].filename);
			end

			local select = getglobal(item:GetName().."Select");
			if not getglobal("MapModelLibFrameManage"):IsShown() then
				select:Hide();
			end

			local redTag = getglobal(item:GetName().."RedTag");
			if CurLabType == MAP_MODEL_CLASS and IsNewModel(t_OneClassModelList.info[i].id) then
				redTag:Show();
			else
				redTag:Hide();
			end
		else
			item:Hide();
		end
	end

	if #(t_OneClassModelList.info) <= 40 then
		getglobal("MapModelLibFrameModelListBoxPlane"):SetHeight(378);
	else
		local addline = math.ceil((#(t_OneClassModelList.info)-40) /10);
		local height = addline*92 + 378;
		getglobal("MapModelLibFrameModelListBoxPlane"):SetHeight(height);
	end

	if #t_OneClassModelList.info > 0 then
		getglobal("MapModelLibFrameModelListEmptyIcon"):Hide();
		getglobal("MapModelLibFrameModelListEmptyTips"):Hide();
	else
		getglobal("MapModelLibFrameModelListEmptyIcon"):Show();
		getglobal("MapModelLibFrameModelListEmptyTips"):Show();
	end

	if CurLabType == RES_MODEL_CLASS then
		getglobal("MapModelLibFrameShortcut"):Hide();
		if #t_OneClassModelList.info > 0 then
			getglobal("MapModelLibFrameManage"):Show();
			getglobal("MapModelLibFrameManageCancelBtn"):Hide();
		else
			getglobal("MapModelLibFrameManage"):Hide();
			getglobal("MapModelLibFrameShortcut"):Hide();
		end
	else
		getglobal("MapModelLibFrameManage"):Hide();
		if #t_OneClassModelList.info > 0 then
			getglobal("MapModelLibFrameShortcut"):Show();
		else
			getglobal("MapModelLibFrameShortcut"):Hide();
		end
	end
end

function MapModelLibFrameManageBtn_OnClick()
	local wdesc = AccountManager:getCurWorldDesc();
	if AccountManager:getMultiPlayer() ~= 0 or (wdesc and wdesc.realowneruin ~= AccountManager:getUin()) then --联机或者下载的地图
		ShowGameTips(GetS(3738), 3);
		return;
	end

	getglobal("MapModelLibFrameShortcut"):Hide();
	getglobal("MapModelLibFrameManage"):Show();
	getglobal("MapModelLibFrameManageAllBtn"):Show();
end

function MapModelLibFrameMoveBtn_OnClick()
	if #(t_SelectModelList) == 0 then
		ShowGameTips(GetS(3914), 3);
		return;
	end
	getglobal("CustomModelMoveFrame"):Show();
end

function RemoveCustomModel(filename)
	local t = t_MapModelClass[CurModelClassIndex];
	for i=1, #(t.info) do
		if t.info[i].filename == filename then
			table.remove(t.info, i);
			return;
		end
	end
end

function MapModelLibFrameDelBtn_OnClick()
	if #(t_SelectModelList) == 0 then
		ShowGameTips(GetS(3915), 3);
		return;
	end

	MessageBox(5, GetS(3247), function(btn)
		if btn == "left" then
			--确定删除
			if #(t_SelectModelList) > 0 then
				for i=1, #(t_SelectModelList) do
					if CustomModelMgr then
						ResourceCenter:removeResource(CurLabType, CurModelClassIndex-1, t_SelectModelList[i]);
						--RemoveCustomModel(t_SelectModelList[i]);
					end
				end
				t_SelectModelList = {};
				UpdateBtnByManager();
				LoadModelClassInfo();
				UpdateModelList();
				UpdateModelClassFrame();

				for i=1, MODEL_GRID_MAX do
					local item = getglobal("MapModelLibFrameModelListBoxItem"..i);
					if item:IsShown() then
						getglobal(item:GetName().."SelectChecked"):Hide();
						getglobal(item:GetName().."SelectTick"):Hide();
					end
				end

				ShowGameTips(GetS(3730), 3);

				if CurLabType == MAP_MODEL_CLASS then
					MapModelLibFrameCancelBtn_OnClick();
				end
			end
		end
	end
	);
end

function MapModelLibFrameSTLBtn_OnClick()
	--[[
	if #(t_SelectModelList) > 0 then
		local path = ClientMgr:getChooseFilePath();
		if path == "" then
			return;
		end
		
		for i=1, #(t_SelectModelList) do
			if CustomModelMgr then
				CustomModelMgr:exportSTL(t_SelectModelList[i], path);
			end
		end

		t_SelectModelList = {};
		UpdateBtnByManager();
		LoadModelClassInfo();
		UpdateModelList();
		UpdateModelClassFrame();

		for i=1, MODEL_GRID_MAX do
			local item = getglobal("MapModelLibFrameModelListBoxItem"..i);
			if item:IsShown() then
				getglobal(item:GetName().."SelectChecked"):Hide();
				getglobal(item:GetName().."SelectTick"):Hide();
			end
		end

		ShowGameTips(GetS(12539));
	end
	]]
end

function MapModelLibFrameCancelBtn_OnClick()
	t_SelectModelList = {};
	UpdateBtnByManager();

	if CurLabType == MAP_MODEL_CLASS then
		getglobal("MapModelLibFrameManage"):Hide();
		getglobal("MapModelLibFrameShortcut"):Show();
	else
		getglobal("MapModelLibFrameManageCancelBtn"):Hide();
	end

	for i=1, MODEL_GRID_MAX do
		local item = getglobal("MapModelLibFrameModelListBoxItem"..i);
		if item:IsShown() then
			if CurLabType == MAP_MODEL_CLASS then
				getglobal(item:GetName().."Select"):Hide();
			else
				getglobal("MapModelLibFrameModelListBoxItem"..i.."SelectChecked"):Hide();
				getglobal("MapModelLibFrameModelListBoxItem"..i.."SelectTick"):Hide();
			end
		end
	end
end

function MapModelLibFrameAllBtn_OnClick()
	t_SelectModelList = {};
	local t_ModelClass = t_MapModelClass;
	if CurLabType == RES_MODEL_CLASS then
		t_ModelClass = t_ResModelClass;
	end

	for i=1, #(t_ModelClass[CurModelClassIndex].info) do
		table.insert(t_SelectModelList, t_ModelClass[CurModelClassIndex].info[i].filename);
	end

	UpdateBtnByManager();
	getglobal("MapModelLibFrameManageCancelBtn"):Show();

	for i=1, MODEL_GRID_MAX do
		local item = getglobal("MapModelLibFrameModelListBoxItem"..i);

		if item:IsShown() then
			getglobal("MapModelLibFrameModelListBoxItem"..i.."SelectChecked"):Show();
			getglobal("MapModelLibFrameModelListBoxItem"..i.."SelectTick"):Show();
		end
	end
end

function MapModelLibFrameManage_OnShow()
	UpdateBtnByManager();

	for i=1, MODEL_GRID_MAX do
		getglobal("MapModelLibFrameModelListBoxItem"..i.."Select"):Show();
		getglobal("MapModelLibFrameModelListBoxItem"..i.."SelectChecked"):Hide();
		getglobal("MapModelLibFrameModelListBoxItem"..i.."SelectTick"):Hide();
	end
end

function UpdateBtnByManager()
	if #(t_SelectModelList) > 0 then
		getglobal("MapModelLibFrameManageMoveBtn"):Show();
		getglobal("MapModelLibFrameManageDelBtn"):Show();
		--if (ClientMgr and  ClientMgr:getApiId() ~= 110) or CurLabType == RES_MODEL_CLASS then  --pc官包才能导出stl文件
			getglobal("MapModelLibFrameManageSTLBtn"):Hide();
		--else
		--	getglobal("MapModelLibFrameManageSTLBtn"):Show();
		--end
	else
		getglobal("MapModelLibFrameManageSTLBtn"):Hide();
		getglobal("MapModelLibFrameManageMoveBtn"):Hide();
		getglobal("MapModelLibFrameManageDelBtn"):Hide();
	end
end
------------------------------------CustomModelMoveFrame_BEGIN------------------------------------------------
local CurMoveLabType;	--选择要移动文件的库
local CurMoveClassIndex; --当前选中要移动到的文件夹

function SetCurMoveLab(labtype)
	local t_lab = {[MAP_MODEL_CLASS] = "CustomModelMoveFrameLabMap", [RES_MODEL_CLASS] = "CustomModelMoveFrameLabRes"};

	CurMoveLabType = labtype;
	for k, v in pairs(t_lab) do
		local normal = getglobal(v.."Normal");
		local checked = getglobal(v.."Checked")
		if k == labtype then
			normal:Hide();
			checked:Show();
		else
			normal:Show();
			checked:Hide();
		end
	end

	SetMoveClassIndex(0);
	UpdateModelMoveClassFrame();
end

function SetMoveClassIndex(index)
	CurMoveClassIndex = index;

	local t_ModelClass = t_MapModelClass;
	if CurMoveLabType == RES_MODEL_CLASS then
		t_ModelClass = t_ResModelClass;
	end

	for i=1, MODEL_CLASS_MAX do
		local classUI = getglobal("CustomModelMoveFrameClassFrameBoxClass"..i);
		if HasUIFrame("CustomModelMoveFrameClassFrameBoxClass"..i) then
			local checked = getglobal("CustomModelMoveFrameClassFrameBoxClass"..i.."Checked");
			if classUI:GetClientID() == index then
				checked:Show();
			else
				checked:Hide();
			end
		else
			return;
		end
	end
end

function UpdateModelMoveClassFrame()
	local t_ModelClass = t_MapModelClass;
	if CurMoveLabType == RES_MODEL_CLASS then
		t_ModelClass = t_ResModelClass;
	end

	print("kekeke------------t_ModelClass", t_ModelClass);
	local index = 1;
	for i=1, #(t_ModelClass) do
		if CurMoveLabType ~= CurLabType or i ~= CurModelClassIndex then
			local class = getglobal("CustomModelMoveFrameClassFrameBoxClass"..index);
			class:Show();
			class:SetClientID(i);
			class:SetClientString(t_ModelClass[i].classname);

			local list = getglobal("CustomModelMoveFrameClassFrameBoxClass"..index.."List");
			local emptyIcon = getglobal("CustomModelMoveFrameClassFrameBoxClass"..index.."EmptyIcon");

			local classNameUI = getglobal("CustomModelMoveFrameClassFrameBoxClass"..index.."Name");

			classNameUI:SetText(GetRealClassName(t_ModelClass[i].classname));

			local num = #(t_ModelClass[i].info);
			if num > 0 then
				list:Show();
				emptyIcon:Hide();
				UpdateOneModelClassList(t_ModelClass[i].info, list, CurMoveLabType);
			else
				list:Hide();
				emptyIcon:Show();
			end

			index = index + 1;
		end
	end

	local num = index - 1;
	local btn = getglobal("CustomModelMoveFrameClassFrameBoxAddBtn");
	if num >= MODEL_CLASS_MAX then
		btn:Hide();
	else
		num = num+1;
		local i = math.ceil(num/4);
		local j = num - 4*(i-1);
		btn:SetPoint("topleft", "CustomModelMoveFrameClassFrameBoxPlane", "topleft", (j-1)*190, (i-1)*229);
		btn:Show();
	end

	print("kekeke------------t_ModelClass index:", index);
	for i=index, MODEL_CLASS_MAX do
		local class = getglobal("CustomModelMoveFrameClassFrameBoxClass"..i);
		class:Hide();
	end

	if num < 5 then
		getglobal("CustomModelMoveFrameClassFrameBoxPlane"):SetHeight(368)
	else
		local column = math.ceil(num / 4);
		getglobal("CustomModelMoveFrameClassFrameBoxPlane"):SetHeight(229*column);
	end
end

function CustomModelMoveFrameLab_OnClick()
	if string.find(this:GetName(), "Map") then
		SetCurMoveLab(MAP_MODEL_CLASS);
	elseif string.find(this:GetName(), "Res") then
		SetCurMoveLab(RES_MODEL_CLASS);
	end
end

function CustomModelMoveFrame_OnLoad()
	LayoutManagerFactory:newGridLayoutManager()
		:setRelativeTo("CustomModelMoveFrameClassFrameBoxPlane")
		:setBoxItemNamePrefix("CustomModelMoveFrameClassFrameBoxClass")
		:setMarginX(10)
		:setMarginY(9)
		:setMaxColumn(4)
		:resetPlaneWithMinimalSize(752, 368)
		:layoutAll(MODEL_CLASS_MAX)
		:recycle()
end

function CustomModelMoveFrame_OnShow()
	--CurMoveClassIndex = 0;
	--SetMoveClassIndex(CurMoveClassIndex);
	getglobal("CustomModelMoveFrameTips"):Hide();
	if CurLabType == MAP_MODEL_CLASS then
		SetCurMoveLab(RES_MODEL_CLASS);
	else
		SetCurMoveLab(MAP_MODEL_CLASS);
	end

end

function CustomModelMoveFrameCloseBtn_OnClick()
	getglobal("CustomModelMoveFrame"):Hide();
end

function GetSameMoveModelInfo(t, filename)
	for i=1, #(t) do
		for j=1, #(t[i].info) do
			if t[i].info[j].filename == filename then
				return {index = i, filename=filename, classname=t[i].classname}
			end
		end
	end

	return nil;
end

function CheckMoveModelSame()
	local canMove = true;
	if CurLabType == CurMoveLabType then
		return canMove;
	end

	local t_ModelClass  = t_MapModelClass
	if CurMoveLabType == RES_MODEL_CLASS then
		t_ModelClass  = t_ResModelClass;
	end

	for i=1, #(t_SelectModelList) do
		local info = GetSameMoveModelInfo(t_ModelClass, t_SelectModelList[i]);
		if info then
			t_SelectModelList[i] = info;
			canMove = false;
		end
	end

	return canMove;
end

function MoveModelClass()
	local needSyncToClient = false;

	local moveNum = #(t_SelectModelList);
	if moveNum > 0 then
		local moveType = nil;
		if CurMoveLabType == RES_MODEL_CLASS and CurLabType == MAP_MODEL_CLASS   then
			moveType = 1;
		elseif CurMoveLabType == MAP_MODEL_CLASS and CurLabType == RES_MODEL_CLASS   then
			moveType = 2;
		end
		statisticsGameEvent(30019, "%d", moveType);
	end

	local curCustomItemNum = CustomModelMgr:getCustomItemNum();
	local curCostomActorNum = CustomModelMgr:getCustomActorModelNum(MAP_MODEL_CLASS);

	for i=1, moveNum do
		--[[
		if CurLabType == RES_MODEL_CLASS and CurMoveLabType == MAP_MODEL_CLASS  and CustomModelMgr:getFreeId(BLOCK_MOD) < 0 then
			ShowGameTips(GetS(3729));
			return;
		end
		]]

		if t_SelectModelList[i].index then
			ResourceCenter:moveResToClass(CurMoveLabType, CurMoveLabType, t_SelectModelList[i].index-1, CurMoveClassIndex-1, t_SelectModelList[i].filename);
			--存档模型库文件夹模型移动，主机需要同步给客机
			if CurMoveLabType == MAP_MODEL_CLASS and IsRoomOwner() then
				needSyncToClient = true;
			end
		else
			ResourceCenter:moveResToClass(CurLabType, CurMoveLabType, CurModelClassIndex-1, CurMoveClassIndex-1, t_SelectModelList[i]);
		end
	end

	if IsRoomOwner() then
		CustomModelMgr:checkSyncCustomModelData(curCustomItemNum, curCostomActorNum);
		ResourceCenter:syncClassInfoToClient(0);
	end

	t_SelectModelList = {};
	LoadModelClassInfo();
	UpdateModelList()
	UpdateModelClassFrame();

	getglobal("CustomModelMoveFrame"):Hide();

	if CurLabType == RES_MODEL_CLASS then
		for i=1, MODEL_GRID_MAX do
			getglobal("MapModelLibFrameModelListBoxItem".. i .."Select"):Show();
			getglobal("MapModelLibFrameModelListBoxItem".. i .."SelectTick"):Hide();
			getglobal("MapModelLibFrameModelListBoxItem".. i .."SelectChecked"):Hide();
		end
	else
		for i=1, MODEL_GRID_MAX do
			getglobal("MapModelLibFrameModelListBoxItem".. i .."Select"):Hide();
		end
	end

	ShowGameTips(GetS(3889), 3);
end

function CustomModelMoveFrameOKBtn_OnClick()
	local t_ModelClass = t_MapModelClass;
	if CurMoveLabType == RES_MODEL_CLASS then
		t_ModelClass = t_ResModelClass;
	end

	if t_ModelClass[CurMoveClassIndex] then
		if CheckMoveModelSame() then
			MoveModelClass();
		else
			getglobal("CustomModelMoveFrameTips"):Show();
		end
	end
end

-------------------------------CustomModelMoveFrameTips----------------------------------
function CustomModelMoveFrameTipsCloseBtn_OnClick()
	getglobal("CustomModelMoveFrameTips"):Hide();
end

function CustomModelMoveFrameTipsOK_OnClick()
	MoveModelClass();
end

function CustomModelMoveFrameTips_OnLoad()
	for i=1, MODEL_GRID_MAX do
		local tipsUI = getglobal("MoveModelTips"..i);
		tipsUI:SetPoint("topleft","CustomModelMoveFrameTipsSliderPagePlane","topleft",0,(i-1)*50);
	end
end

function CustomModelMoveFrameTips_OnShow()
	local t_ModelClass  = t_MapModelClass
	if type == RES_MODEL_CLASS then
		t_ModelClass  = t_ResModelClass;
	end

	if t_ModelClass[CurMoveClassIndex] then
		getglobal("CustomModelMoveFrameTipsDesc"):SetText(GetS(3911, GetRealClassName(t_ModelClass[CurMoveClassIndex].classname)));
	end

	local t_NeedTipsModelInfo = {};

	local index = 1;
	for i=1, #(t_SelectModelList) do
		if t_SelectModelList[i].index then
			local modelUI = getglobal("MoveModelTips"..index);
			local iconUI = getglobal("MoveModelTips"..index.."Icon");
			local nameUI = getglobal("MoveModelTips"..index.."Desc");
			modelUI:Show();

			local modelType = BLOCK_MODEL;
			local custoModel = CustomModelMgr:getCustomModel(CurLabType, t_SelectModelList[i].filename);
			if custoModel then
				local modelName = custoModel:getModelName();
				if modelName == "" then
					modelName = GetS(3978);
				end
				nameUI:SetText(GetS(3912, modelName, GetRealClassName(t_SelectModelList[i].classname)));
				modelType = custoModel:getModelType();
			else
				fullyCustomModel = FullyCustomModelMgr:findFullyCustomModel(CurLabType, t_SelectModelList[i].filename, true);
				if fullyCustomModel then
					nameUI:SetText(GetS(3912, fullyCustomModel:getName(), GetRealClassName(t_SelectModelList[i].classname))) 
					modelType = fullyCustomModel:getModelType();
				else
					nameUI:SetText("");
				end
			end

			SetModelIcon(iconUI, t_SelectModelList[i].filename, modelType);

			index = index + 1;
		end
	end

	for i=index, MODEL_GRID_MAX do
		local modelUI = getglobal("MoveModelTips"..i);
		modelUI:Hide();
	end

	local num = index - 1;
	if num < 6 then
		getglobal("CustomModelMoveFrameTipsSliderPagePlane"):SetHeight(275);
	else
		getglobal("CustomModelMoveFrameTipsSliderPagePlane"):SetHeight(num*50);
	end

	getglobal("CustomModelMoveFrameClassFrameBox"):setDealMsg(false);
end

function CustomModelMoveFrameTips_OnHide()
	getglobal("CustomModelMoveFrameClassFrameBox"):setDealMsg(true);
end

-------------------------------ModelClassModifyFrame--------------------------------------
function ModelClassModifyFrameNameEdit_OnEnterPressed()
	ModelClassModifyFrameOkBtn_OnClick();
end

function ModelClassModifyFrameOkBtn_OnClick()
	local className = getglobal("ModelClassModifyFrameContentNameEdit"):GetText();
	if className == "" then
		ShowGameTips(GetS(3949), 3);
		return;
	end

	if CheckFilterString(className) then return end

	local type;
	if getglobal("CustomModelMoveFrame"):IsShown() then
		type = CurMoveLabType;
	else
		type = CurLabType;
	end

	local opType = getglobal("ModelClassModifyFrame"):GetClientString();
	if opType == "add" then
		if ResourceCenter:addClass(type, className) then
			if type == MAP_MODEL_CLASS then
				table.insert(t_MapModelClass, {classname=className, info={}});
			elseif type == RES_MODEL_CLASS then
				table.insert(t_ResModelClass, {classname=className, info={}});
			end
		else
			ShowGameTips(GetS(3946), 3);
			return;
		end
	elseif opType == "modify" then
		local curClassName = GetModelClassNameByIndex(type, CurModelClassIndex);

		if ResourceCenter:modifyClassName(type, curClassName, className) then
			local t_ModelClass  = t_MapModelClass
			if type == RES_MODEL_CLASS then
				t_ModelClass  = t_ResModelClass;
			end

			t_ModelClass[CurModelClassIndex].classname = className;

			getglobal("MapModelLibFrameModelListName"):SetText(className);
		else
			ShowGameTips(GetS(3946), 3);
			return;
		end
	end

	if getglobal("CustomModelMoveFrame"):IsShown() then
		UpdateModelMoveClassFrame();
	end

	UpdateModelClassFrame();

	getglobal("ModelClassModifyFrame"):Hide();
	getglobal("ModelClassModifyFrameContentNameEdit"):Clear();
end

function ModelClassModifyFrameCancelBtn_OnClick()
	getglobal("ModelClassModifyFrame"):Hide();
	getglobal("ModelClassModifyFrameContentNameEdit"):Clear();
end