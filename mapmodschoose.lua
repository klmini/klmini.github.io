
--长期存储的变量
local Mods_Count_Max = 30;
local MapMods_Count_Max = 10;
MapLoadedMods = {};

--用来临时存储的变量
local CurrentChooseMods = {};

local CurrentMode = 0;  --the same value as Current_Edit_Mode

function ChooseModsFrame_OnEnter()

	local args = FrameStack.cur();

	local mode = args.mode;

	Log("ChooseModFromMyLib "..mode);
	CurrentMode = mode;
	getglobal("ChooseModsFrame"):Show();
end

function ChooseModsFrameCloseBtn_OnClick()
	FrameStack.goBack();
end

function ChooseModsFrameConfirmBtn_OnClick()
	MapLoadedMods = CurrentChooseMods;

	FrameStack.goBack();

	Log("MapLoadedMods = ");
end

function ChooseModsFrameHelpBtn_OnClick()
	-- getglobal("ChooseModsHelpFrame"):Show();
	getglobal("CommonHelpFrame1"):Show();
	getglobal("CommonHelpFrame1TitleName"):SetText(GetS(3918));
	getglobal("CommonHelpFrame1BoxContent"):SetText(GetS(3982));

	StatisticsTools:gameEvent("OpenMyModsHelpFrame");
end

function ChooseModsHelpFrameClose_OnClick()
	getglobal("ChooseModsHelpFrame"):Hide();
end

function MyModsChooseHelpFrame_OnLoad()
	getglobal("ChooseModsHelpBoxContent"):SetText(GetS(3982), 140, 103, 84);
end


function MapModsChooseFrame_OnLoad()
	--标题名
	getglobal("ChooseModsFrameTitleFrameName"):SetText(GetS(3920));

	for i=1, Mods_Count_Max do
			local archive = getglobal("StorageMod"..i);
			archive:SetPoint("topleft", "ModsStorageBoxPlane", "topleft", 0, (i-1)*164);
	end

	for i=1, MapMods_Count_Max do
			local archive = getglobal("SelectedMod"..i);
			archive:SetPoint("topleft", "SelectedModsBoxPlane", "topleft", 0, (i-1)*164);
	end
end

--点击显示详情
function ChooseModArchive_OnClick()
	local archindex = this:GetClientID();
	CurSelectModIndex = archindex;
	getglobal("ModArchiveInfoFrame"):Show();
	local modDesc = ModMgr:getModDesc(archindex-1);

	if modDesc then
		getglobal("ModArchiveInfoFrame"):Show();
		SetInfoFrame(modDesc);
	end
end


--选择添加mod
function ChooseModArchiveAddBtn_OnClick()
	local arch = this:GetParentFrame();

	if arch then
		--local index = arch:GetClientID();
		----不能重复加载
		--for i=1, CurrentChooseModsCount do
		--	if CurrentChooseMods[i] == index - 1 then
		--		return;
		--	end
		--end

		local uuid = arch:GetClientString();
		Log("ChooseModArchiveAddBtn_OnClick "..uuid);

		for i=1, #CurrentChooseMods do
			if CurrentChooseMods[i] == uuid then
				return;
			end
		end

		--将按钮灰掉
		--local btnName = "StorageMod"..index.."AddBtn";
		--local textureName = "StorageMod"..index.."AddBtnNormal";
		--getglobal(btnName):Disable();
		--getglobal(textureName):SetGray(true);

		table.insert(CurrentChooseMods, uuid);

		UpdateStorageModsArchives();
		UpdateSelectedModsArchives();
	end
end

--选择删除mod
function ChooseModArchiveDeleteBtn_OnClick()
	local arch = this:GetParentFrame();
	if arch then

		local uuid = arch:GetClientString();
		
		--Log("ChooseModArchiveDeleteBtn_OnClick "..uuid);

		for i = 1, #CurrentChooseMods do
			if uuid and  CurrentChooseMods[i] == uuid then
				table.remove(CurrentChooseMods, i);
				break;
			end
		end

		UpdateSelectedModsArchives();
		UpdateStorageModsArchives();
	end
end

function MapModsChooseFrame_OnShow()
	Log("MapModsChooseFrame_OnShow");
	Log("MapLoadedMods = ");

	getglobal("SelectedModsBox"):resetOffsetPos();
	getglobal("ModsStorageBox"):resetOffsetPos();
	CurrentChooseMods = MapLoadedMods;

	UpdateStorageModsArchives();
	UpdateSelectedModsArchives();
	
	SetModBoxsDeals(false);
	if getglobal("WorldRuleBox"):IsShown() then
		getglobal("WorldRuleBox"):setDealMsg(false);
	end
end

function MapModsChooseFrame_OnHide()
 	getglobal("ModArchiveInfoFrame"):Hide();

	SetModBoxsDeals(true);
	if getglobal("WorldRuleBox"):IsShown() then
		getglobal("WorldRuleBox"):setDealMsg(true);
	end
end

function ChooseModsFrame_OnLeave()

	local uuids = {};

	for i = 1, #MapLoadedMods do
		local uuid = MapLoadedMods[i];
		table.insert(uuids, uuid);
	end

	FrameStack.cur().selectedModUuids = uuids;

	getglobal("ChooseModsFrame"):Hide();
end

function GetSelectedModTable()	
	Log("GetSelectedModTable:");
 	return MapLoadedMods;
end

function ClearSelectedMods()
	Log("ClearSelectedMods");

	MapLoadedMods = {};

	for i =1,Mods_Count_Max do
		local btnName = "StorageMod"..i.."AddBtn";
		local textureName = "StorageMod"..i.."AddBtnNormal";
		getglobal(btnName):Enable();
		getglobal(textureName):SetGray(false);
	end
end

function UpdateStorageModsArchives()
	local currentModCount = ModMgr:getAllModCount();
	--local currentModCount = 10;
	if currentModCount > Mods_Count_Max then
		currentModCount = Mods_Count_Max;
	end

	for i = 1, Mods_Count_Max do
		local archui = getglobal("StorageMod"..i);
		if i <= currentModCount then 
			
			local moddesc = ModMgr:getModDesc(i-1);

			local isSelected = false;
			for j = 1, #CurrentChooseMods do
				if CurrentChooseMods[j] == moddesc.uuid then
					isSelected = true;
				end
			end

			local canshow = moddesc.uuid ~= ModMgr:getUserDefaultModUUID()
							and moddesc.uuid ~= ModMgr:getMapDefaultModUUID()
                            and moddesc.uuid ~= ModMgr:getSurvivalMapDefaultModUUID()
							and moddesc.modtype == 0;

			if canshow then
				archui:Show();
				UpdateSingleStorageModArchive(archui, moddesc, isSelected);
				getglobal("StorageMod"..i.."DeleteBtn"):Hide(); 
			else
				archui:Hide();
			end
		else
			archui:Hide();
		end
	end

	local shownNum = 0;
	for i=1, Mods_Count_Max do
		local archive = getglobal("StorageMod"..i);
		if archive:IsShown() then
			archive:SetPoint("topleft", "ModsStorageBoxPlane", "topleft", 0, shownNum*164);
			shownNum = shownNum + 1;
		end
	end

	--DoLayout_ListV_Auto("StorageMod", Mods_Count_Max, 0);

	local plane = getglobal("ModsStorageBoxPlane");
	local totalHeight = shownNum * 164;
	if totalHeight < getglobal("ModsStorageBox"):GetRealHeight() then
		totalHeight = getglobal("ModsStorageBox"):GetRealHeight();
	end
	plane:SetSize(620, totalHeight);
end

function UpdateSelectedModsArchives()
   
	if CurrentMode then
		Log("UpdateSelectedModsArchives "..CurrentMode);
	end 

	for i = 1, MapMods_Count_Max do
		local archui = getglobal("SelectedMod"..i);
		getglobal("SelectedMod"..i.."AddBtn"):Hide(); 
		if i <= #CurrentChooseMods then

			local moddesc = ModMgr:getModDescByUUID(CurrentChooseMods[i]);
			local canshow = false;
			if moddesc ~= nil then 				
				canshow = moddesc.uuid ~= ModMgr:getUserDefaultModUUID()
							and moddesc.uuid ~= ModMgr:getMapDefaultModUUID()
							and moddesc.modtype == 0;
			end 
			
			if canshow then
				UpdateSingleSelectedModArchive(archui, moddesc);
				--Log("UpdateSingleSelectedModArchive" .. i);
				archui:Show();
				if CurrentMode == 4 and false then
					getglobal(archui:GetName().."DeleteBtn"):Hide();
				else
					getglobal(archui:GetName().."DeleteBtn"):Show();
				end
			else
				archui:Hide();
			end
		else
			archui:Hide();
		end
	end

	local shownNum = 0;
	for i=1, MapMods_Count_Max do
		local archive = getglobal("SelectedMod"..i);
		if archive:IsShown() then
			archive:SetPoint("topleft", "SelectedModsBoxPlane", "topleft", 0, shownNum*164);
			shownNum = shownNum + 1;
		end
	end

	local plane = getglobal("SelectedModsBoxPlane");
	local totalHeight = shownNum * 164;
	if totalHeight < getglobal("SelectedModsBox"):GetRealHeight() then
		totalHeight = getglobal("SelectedModsBox"):GetRealHeight();
	end
	plane:SetSize(620, totalHeight);

end

function UpdateSingleStorageModArchive(archui, modInfo, isSelected)

	local archname = archui:GetName();
	if modInfo then

		archui:SetClientString(modInfo.uuid);

		local mapname = modInfo.name;
		getglobal(archname.."Name"):SetText(mapname);
		local author_name = modInfo.author or "";
		getglobal(archname.."AuthorName"):SetText(author_name);

		--插件描述
		local description = modInfo.description;
		local len = string.len(description);
		if len > 40 then
			description = string.sub(description, 1, 40).."...";
		end

		getglobal(archname.."Detail"):SetText(description); 

	if ModEditorMgr:checkFileExist(modInfo.rootDir.."/icon.png_") then
		getglobal(archname.."Pic"):SetTexture(modInfo.rootDir.."/icon.png_", true);
	elseif ModEditorMgr:checkFileExist(modInfo.rootDir.."/icon.png") then
		getglobal(archname.."Pic"):SetTexture(modInfo.rootDir.."/icon.png", true);
	end

	local btnName = archname.."AddBtn";
	local textureName = archname.."AddBtnNormal";

	if isSelected then
			getglobal(btnName):Disable();
		getglobal(textureName):SetGray(true);
	else
			getglobal(btnName):Enable();
		getglobal(textureName):SetGray(false);
	end
		
		--Mod大小
		local size = string.format("%.2f", modInfo.size/1000000)
		if modInfo.size < 999 then
			size = "0.1";
		end

		getglobal(archname.."Size"):SetText(size.."M"); 


		--版本号
		getglobal(archname.."ModVersion"):SetText(ModEditorMgr:modVersionToStr(modInfo.packVersion)); 
		getglobal(archname.."APIVersion"):SetText(ClientMgr:clientVersionToStr(modInfo.apiVersion)); 

	end
end



function UpdateSingleSelectedModArchive(archui, modInfo)

	local archname = archui:GetName();
	if modInfo then

		archui:SetClientString(modInfo.uuid);

		local mapname = modInfo.name;
		getglobal(archname.."Name"):SetText(mapname);
		local author_name = modInfo.author or "";
		getglobal(archname.."AuthorName"):SetText(author_name);

		--插件描述
		local description = modInfo.description;
		local len = string.len(description);
		if len > 40 then
			description = string.sub(description, 1, 40).."...";
		end

		getglobal(archname.."Detail"):SetText(description); 

	if ModEditorMgr:checkFileExist(modInfo.rootDir.."/icon.png") then
		getglobal(archname.."Pic"):SetTexture(modInfo.rootDir.."/icon.png", true);
	elseif ModEditorMgr:checkFileExist(modInfo.rootDir.."/icon.png_") then
		getglobal(archname.."Pic"):SetTexture(modInfo.rootDir.."/icon.png_", true);
	else
		getglobal(archname.."Pic"):SetTexture("ui/mobile/texture2/bigtex/cjk_tydt02.png", true);
	end

		--Mod大小
		local size = string.format("%.3f", modInfo.size/1000000)
		getglobal(archname.."Size"):SetText(size.."m"); 


		--版本号
		getglobal(archname.."ModVersion"):SetText(ModEditorMgr:modVersionToStr(modInfo.packVersion)); 
		getglobal(archname.."APIVersion"):SetText(ClientMgr:clientVersionToStr(modInfo.apiVersion)); 
	end
end


