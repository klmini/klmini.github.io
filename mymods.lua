
local Mods_Count_Max = 30;
local CurMod = nil; -- 当前选中的Mod	
local CurSelectModIndex =-1;

function MyModsFrameCloseBtn_OnClick()
	FrameStack.goBack();
end

function MyModsFrameHelpBtn_OnClick()
	--打开插件包帮助页面
	getglobal("MyModsHelpFrameTitleName"):SetText(GetS(3918));
	getglobal("MyModsHelpFrameBoxContent"):SetText(GetS(3980), 61, 69, 70);
	getglobal("MyModsHelpFrame"):Show();
	StatisticsTools:gameEvent("OpenMyModsHelpFrame");

	--插件库帮助引导
	if not AccountManager:getNoviceGuideState("guidemodshelp") then
		AccountManager:setNoviceGuideState("guidemodshelp", true);
		getglobal("MyModsFrameHelpBtnGuide"):Hide();
	end

	SetArchiveBoxDeals(false);
end

function MyModsFrameHelpBtnGuide_OnClick()
	AccountManager:setNoviceGuideState("guidemodshelp", true);
	getglobal("MyModsFrameHelpBtnGuide"):Hide();
end

function MyModHelpFrameClose_OnClick()
	getglobal("MyModsHelpFrame"):Hide();
	SetArchiveBoxDeals(true);
end

function SetArchiveBoxDeals(isDeal)
	getglobal("ModChosenArchiveBox"):setDealMsg(isDeal);
end


function MyModsHelpFrame_OnLoad()
	--关闭按钮
	UITemplateBaseFuncMgr:registerFunc("MyModsHelpFrameCloseBtn", MyModHelpFrameClose_OnClick, "插件报帮助页面关闭按钮");
end

function ModsArchive_OnClick()
	local archindex = this:GetClientID();
	CurSelectModIndex = archindex;
	getglobal("ModArchiveInfoFrame"):Show();
	local modDesc = ModMgr:getModDesc(archindex-1);

	if modDesc then

		Log("mod uuid="..modDesc.uuid);

		CurMod = modDesc;
		getglobal("ModArchiveInfoFrame"):Show();
		SetInfoFrame(modDesc);
	end

end

function SetInfoFrame(modDesc)
	local frameName = "ModArchiveInfoFrameIntroduce";
	getglobal(frameName.."ModName"):SetText(modDesc.name);
	getglobal(frameName.."Author"):SetText(modDesc.author);
	getglobal(frameName.."ModVer"):SetText(ModEditorMgr:modVersionToStr(modDesc.packVersion));
	getglobal(frameName.."APIVer"):SetText(ClientMgr:clientVersionToStr(modDesc.apiVersion));

	if ModEditorMgr:checkFileExist(modDesc.rootDir.."/icon.png") then
		getglobal(frameName.."ModThumb"):SetTexture(modDesc.rootDir.."/icon.png", true);
	elseif ModEditorMgr:checkFileExist(modDesc.rootDir.."/icon.png_") then
		getglobal(frameName.."ModThumb"):SetTexture(modDesc.rootDir.."/icon.png_", true);
	else
		getglobal("ModArchiveInfoFrameIntroduceModThumb"):SetTexture("ui/mobile/texture2/bigtex/cjk_tydt02.png", true);
	end

	getglobal(frameName.."HeadBtnIcon"):SetTexture("ui/roleicons/"..modDesc.headicon..".png");
	
	local description = modDesc.description;
	local len = string.len(description);
	if len > 290 then
		description = string.sub(description, 1, 190).."...";
	end

	getglobal(frameName.."Desc"):SetText(description);

	local detailFrame = getglobal("ModArchiveInfoFrame");

		Log("modDesc.authorUin ".. modDesc.authorUin);
	--官方插件不允许删除
		if modDesc.authorUin == 1000 then
			getglobal("ModArchiveInfoFrameIntroduceDeleteBtn"):Hide();
		else
			getglobal("ModArchiveInfoFrameIntroduceDeleteBtn"):Show();
		end

	--如果是在插件库界面
 	if getglobal("MyModsFrame"):IsShown() then
 		if CurSelectModIndex % 2 == 1 then
			detailFrame:SetPoint("center", "MyModsFrame", "center", 227, 5);
		else
			detailFrame:SetPoint("center", "MyModsFrame", "center", -227, 5);
		end
		--如果是在创建地图选择插件界面
 	else
		detailFrame:SetPoint("center", "MyModsFrame", "center", 227, 5);
		--隐藏上传和删除按钮
		 getglobal("ModArchiveInfoFrameIntroduceDeleteBtn"):Hide();
		 getglobal("ModArchiveInfoFrameIntroduceUploadBtn"):Hide();

	end
end

function ModInfoFrame_OnShow()
end

function ModInfoFrameCloseBtn_OnClick()
	getglobal("ModArchiveInfoFrame"):Hide();
end

function MyModsArchiveInfoDeleteBtn_OnClick()
	ModMgr:requestDeleteModByPath(CurMod.rootDir);
	CurMod = nil;
	Log("MyModsArchiveInfoDeleteBtn_OnClick");
	getglobal("ModArchiveInfoFrame"):Hide();
	ModMgr:updateModList(true);
	--UpdateMyModsArchives();

end

function MyModsFrame_OnHide()
	getglobal("ModArchiveInfoFrame"):Hide();
end

function CreateModBtn_OnClick()
	--getglobal("ModArchiveInfoFrame"):Hide();
	--getglobal("MyModsFrame"):Hide();
	--getglobal("MyModsEditorFrame"):Show();
	----td统计
	--StatisticsTools:gameEvent("ModEvent", "点击创建插件");
	--OpenEditorToCreateNewMod();
end

function MyModsFrame_OnLoad()
	this:RegisterEvent("GE_MODLIST_CHANGE");
	for i=1, Mods_Count_Max/2 do
		for j=1, 2 do
			local archive = getglobal("ModArchive"..((i-1)*2+j));
			archive:SetPoint("topleft", "ModChosenArchiveBoxPlane", "topleft", (j-1)*626, (i-1)*164);
		end
	end

	--标题栏
	getglobal("MyModsFrameTitleFrameName"):SetText(GetS(3917));
end

function MyModsFrame_OnEvent()
	if arg1 == "GE_MODLIST_CHANGE" then
		UpdateMyModsArchives();
	end
end

function MyModsFrame_OnShow()
	UpdateMyModsArchives();
	--插件库帮助引导
	if not AccountManager:getNoviceGuideState("guidemodshelp") then
		getglobal("MyModsFrameHelpBtnGuide"):Show();
	else
		getglobal("MyModsFrameHelpBtnGuide"):Hide();
	end
end

--编辑按钮
function ModArchiveTemplateFuncBtn_OnClick()
	getglobal("ModArchiveInfoFrame"):Hide();

	local arch = this:GetParentFrame();
	if arch then
		local archindex = arch:GetClientID();
		Log("ModArchiveTemplateFuncBtn_OnClick"..archindex);
		local moddesc = ModMgr:getModDesc(archindex-1);

		local args = {
			editmode = 1,
			uuid = moddesc.uuid,
		};

		if UseNewModsLib then
	        args.isnew = true
	        args.enterType = 4
	        FrameStack.fromFrame = "ModArchiveInfoFrame"
	        FrameStack.enterNewFrame("ModsLib", args)
	    else
			FrameStack.fromFrame = "ModArchiveInfoFrame";
			FrameStack.enterNewFrame("MyModsEditorFrame", args);
	    end

		-- statisticsGameEvent(509, '%lls', moddesc.uuid);
	end

end

function UpdateSingleModArchive(archui, modInfo)

	local archname = archui:GetName();
	if modInfo then
		local mapname = modInfo.name;
		getglobal(archname.."Name"):SetText(mapname);
		local author_name = modInfo.author or "";
		getglobal(archname.."AuthorName"):SetText(author_name);

--插件描述
		local description = modInfo.description;
		local len = string.len(description);
		if len > 60 then
			description = string.sub(description, 1, 60).."...";
			getglobal(archname.."Detail"):SetSize(200, 42);
			getglobal(archname.."DetailBkg"):Show();
		else
			if getglobal(archname.."DetailBkg"):IsShown() then
				getglobal(archname.."DetailBkg"):Hide();
			end
		end

		getglobal(archname.."Detail"):SetText(description); 

		if ModEditorMgr:checkFileExist(modInfo.rootDir.."/icon.png") then
			getglobal(archname.."Pic"):SetTexture(modInfo.rootDir.."/icon.png", true);
		elseif ModEditorMgr:checkFileExist(modInfo.rootDir.."/icon.png_") then
			getglobal(archname.."Pic"):SetTexture(modInfo.rootDir.."/icon.png_", true);
		else
			getglobal(archname.."Pic"):SetTexture("ui/mobile/texture2/bigtex/cjk_tydt02.png", true);
		end
			Log("modInfo.authorUin " ..modInfo.authorUin .."  /".. AccountManager:getUin())
		--if author_name ~= AccountManager:getNickName() and not modInfo.openedit then
		if  not modInfo.openedit and modInfo.authorUin ~= AccountManager:getUin()then
				getglobal(archname.."FuncBtn"):Hide(); 
		else
				getglobal(archname.."FuncBtn"):Show(); 
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

function UpdateMyModsArchives()
	local currentModCount = ModMgr:getAllModCount();
	--local currentModCount = 10;
	if currentModCount > Mods_Count_Max then
		currentModCount = Mods_Count_Max;
	end

	local shownArchiveNum = 0;

	for i = 1, Mods_Count_Max do
		local archui = getglobal("ModArchive"..i);
		if i <= currentModCount then
			local moddesc = ModMgr:getModDesc(i-1);

			local canshow = moddesc.uuid ~= ModMgr:getUserDefaultModUUID()
							 and moddesc.uuid ~= ModMgr:getMapDefaultModUUID()
                             and moddesc.uuid ~= ModMgr:getSurvivalMapDefaultModUUID()
							 and moddesc.modtype == 0;

			if canshow then  --内部插件不显示
				UpdateSingleModArchive(archui, moddesc);
				archui:Show();
				shownArchiveNum = shownArchiveNum + 1;
			else
				archui:Hide();
			end
		else
			archui:Hide();
		end
	end

--[[
		if i <= #(mapservice.chosenMaps) then
			local map = mapservice.chosenMaps[i];
			archui:Show();
			UpdateSingleArchive(archui, map, {hideRankTag=true});
		else
			archui:Hide();
			UpdateSingleArchive(archui, nil);
		end
		]]

	local column = 0;
	local row = 0;
	for i=1, Mods_Count_Max do
		local archive = getglobal("ModArchive"..i);
		if archive:IsShown() then
			archive:SetPoint("topleft", "ModChosenArchiveBoxPlane", "topleft", column*626, row*164);
			if column == 0 then
				column = 1;
			else
				column = 0;
				row = row + 1;
			end
		end
	end

	local plane = getglobal("ModChosenArchiveBoxPlane");
	local totalHeight = math.ceil(shownArchiveNum / 2) * 164;
	if totalHeight < getglobal("ModChosenArchiveBox"):GetRealHeight() then
		totalHeight = getglobal("ModChosenArchiveBox"):GetRealHeight();
	end
	plane:SetSize(1248, totalHeight);
end

function ModInfoFrame_OnHide()

end