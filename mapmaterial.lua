	
local MapMaterialFrame_FirstShow = true;
local MaterialMods_Max = 20;

local allMatModDescs = {};
local defaultMatModDesc = nil;

local curWorldOwid = nil;
local originWorldMatModDesc = nil;
local curWorldMatModDesc = nil;

local MapMaterialInfo_ModDesc = nil;

function MapMaterialFrame_BeginEdit(owid)
	Log("MapMaterialFrame_BeginEdit "..owid);

	--LLDO:刷新一下材质包
	ModMgr:updateModList(false);

	curWorldOwid = owid;

	if not defaultMatModDesc then
		MapMaterialFrame_OnLoad()
	end
	--
	-- mods in library
	--
	allMatModDescs = {};
	table.insert(allMatModDescs, defaultMatModDesc);
	for i = 0, ModMgr:getAllModCount() - 1 do
		local moddesc = ModMgr:getModDesc(i);
		if moddesc.modtype == ModType_MaterialNonFree then
			table.insert(allMatModDescs, moddesc);
		end
	end
	print('allMatModDescs = ', allMatModDescs);

	--
	-- mods in cur world
	--
	local loadmodflags = LuaInterface:band(LMF_Default, LuaInterface:bnot(LMF_ParseComponents));
	ModMgr:loadWorldMods(curWorldOwid, loadmodflags);

	originWorldMatModDesc = nil;
	for i = 0, ModMgr:getMapModCount() - 1 do
		local mapmoddesc = ModMgr:getMapModDescByIndex(i);
		if mapmoddesc.modtype == ModType_MaterialNonFree then
			originWorldMatModDesc = mapmoddesc;
		end
	end
	if originWorldMatModDesc then
		print('originWorldMatModDesc = ', originWorldMatModDesc.uuid);
	else
		print('originWorldMatModDesc = ', nil);
	end

	curWorldMatModDesc = originWorldMatModDesc;

	getglobal("MapMaterialFrame"):Show();
end

function MapMaterialFrame_EndEdit()
	Log("MapMaterialFrame_EndEdit");

	getglobal("MapMaterialFrame"):Hide();
	getglobal("MapMaterialInfoFrame"):Hide();

	curWorldOwid = nil;
	curWorldMatModDesc = nil;
	originWorldMatModDesc = nil;
	ModMgr:unLoadCurMods(false);
end

function MapMaterialFrame_OnLoad()
	--注册函数
	-- UITemplateBaseFuncMgr:registerFunc("MapMaterialFrameHelpBtn", FriendFrameHelpBtn_OnClick,"材质设置帮助按钮");
	--去掉帮助按钮
	getglobal("MapMaterialFrameHelpBtn"):Hide();
	getglobal("MapMaterialFrameTitleBkgHelp"):Hide();
	getglobal("MapMaterialFrameTitleName"):SetAnchorOffset(30, 0);
	UITemplateBaseFuncMgr:registerFunc("MapMaterialFrameCloseBtn", MapMaterialFrameCloseBtn_OnClick,"材质设置关闭按钮");
	getglobal("MapMaterialFrameTitleName"):SetText(GetS(4776));

	defaultMatModDesc = GameModDesc();
	defaultMatModDesc.uuid = "(defaultMatMod)";
	defaultMatModDesc.name = GetS(4779);
	defaultMatModDesc.author = GetS(4780);
	
	if isAbroadEvn() then
		defaultMatModDesc.authorUin = 1000001000;
	else
		defaultMatModDesc.authorUin = 1000;
	end	
	
	defaultMatModDesc.modetype = 1;
end

function MapMaterialFrame_OnShow()
	if MapMaterialFrame_FirstShow then
		MapMaterialFrame_FirstShow = false;

		InitMaterialModsLayout();
	end

	MapMaterialUpdateMaterialMods();
end

function MapMaterialFrame_OnHide()
	--离开材质界面要重置编辑模式
	ModEditorMgr:onleaveEditCurrentMod();
end

function MapMaterialFrame_OnUpdate()

end

function MapMaterialFrameCloseBtn_OnClick()
	MapMaterialFrame_EndEdit();
end

function MapMaterialFrameTabsBtn_OnClick()
	
end

function MapMaterialFrame_StartGame(worldId)
	if worldId == 0 then
		--提示选择存档
		ShowGameTips(GetS(13), 3);
		return false;
	end

	if worldId == ShareingMapIndex and ClientMgr:isSharingOWorld() then
		--正在分享，提示分享完成才能进入
		ShowGameTips(GetS(14), 3);
		return false;
	end

	local worldInfo = AccountManager:findWorldDesc(worldId)--获取自己存档地图数据
	if not worldInfo then
		--提示选择存档
		ShowGameTips(GetS(13), 3);
		return false;
	end

	local checkwid = worldInfo.fromowid;
	if checkwid == 0 then
		checkwid = worldInfo.worldid;
	end
	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(checkwid);
	if mapIsBreakLaw == 1 then
		ShowGameTips(GetS(10561), 3);
		return false;
	elseif mapIsBreakLaw == 2 then
		ShowGameTips(GetS(3632), 3);
		return false;
	end

	if worldInfo.openpushtype == 1 or worldInfo.openpushtype == 2 then
		ShowGameTips(GetS(14), 3);
		return false;
	end

	if worldInfo.openpushtype >= 3 then
		ShowGameTips(GetS(15), 3);
		return false;
	end

	if AccountManager:getUin() ~= worldInfo.realowneruin and GetInst("mainDataMgr"):AB_singleP2P() then --不是自己的图 并且新框架				
		GetInst("lobbyInterface"):CreateP2PSingleRoom(worldInfo.worldid, nil, {})
	else
		RequestEnterWorld(worldInfo.worldid, false, function(succeed)
			if succeed then
				if worldInfo then
					--记录下进入地图的时间
					GetInst("lobbyDataManager"):AddLastEditTime(worldInfo.worldid, os.time())
				end

				EnterWorld_ExtraSet("", 1)
				HideLobby();
				ShowLoadingFrame();
				ns_ma.ma_play_map_set_enter( { where="single"} )
			end
		end);
	end

	return true
end

function MapMaterialFrameStartGameBtn_OnClick()
	local owid = curWorldOwid;

	if originWorldMatModDesc ~= curWorldMatModDesc then
		Log("applying material mod, owid="..curWorldOwid.." uuid="..tostring(uuid));

		if originWorldMatModDesc then
			ModMgr:deleteModByPath(originWorldMatModDesc.rootDir);
		end

		if curWorldMatModDesc then
			ModMgr:copyModFromLibraryToWorld(curWorldMatModDesc.uuid, curWorldOwid);
		end

		Log("applying succeed");
	end

	MapMaterialFrame_EndEdit();
	if isEnableNewLobby and isEnableNewLobby() then
		if GetInst("mainDataMgr"):AB_NewArchiveLobbyMain() then
			MapMaterialFrame_StartGame(owid)
		else
			if GetInst("UIManager"):GetCtrl("MapDetailInfo") then
				GetInst("UIManager"):GetCtrl("MapDetailInfo"):IntroduceStarGameBtn_OnClick("material");
			end
		end
	else
		ArchiveInfoFrameIntroduceStarGameBtn_OnClick();
	end

--	getglobal("MapMaterialFrame"):Hide();
--	HideLobby();
--	ShowLoadingFrame();
--
--	AccountManager:requestEnterWorld(owid);
	--if worldInfo.worldtype == 0 then
	--	StatisticsTools:gameEvent("EnterSurviveWNum");
	--elseif worldInfo.worldtype == 1 or worldInfo.worldtype == 3 then
	--	StatisticsTools:gameEvent("EnterCreateWNum");
	--elseif worldInfo.worldtype == 2 then
	--	StatisticsTools:gameEvent("EnterExtremityWNum");
	--elseif worldInfo.worldtype == 4 then
	--	StatisticsTools:gameEvent("EnterGameMakerWNum");
	--end
end

function MaterialModTemplateCheckBtn_OnClick()
	local index = this:GetParentFrame():GetClientID();
	local moddesc = allMatModDescs[index];

	local worldInfo = AccountManager:getMyWorldList():findWorldDesc(curWorldOwid);
	--[[
	if worldInfo and worldInfo.realowneruin ~= AccountManager:getUin() then
		ShowGameTips(GetS(4783), 3);
		return;
	end]]

	if moddesc == defaultMatModDesc then
		curWorldMatModDesc = nil;
		MapMaterialUpdateMaterialMods();
	else
		if moddesc.modtype == ModType_MaterialNonFree then  --收费材质包
			ReqGetMaterialModUnlocked(moddesc.uuid, function(isunlocked, moddesc)
				if isunlocked then
					curWorldMatModDesc = moddesc;
					MapMaterialUpdateMaterialMods();
				else
					--ShowGameTips(GetS(4781), 3);
					MessageBox(19, GetS(4781), function(btn)
						if btn == 'left' then
							HideLobby();
							getglobal("MapMaterialFrame"):Hide();
							g_jump_ui_switch[18]();
						end
					end);
				end
			end, moddesc)
		end
	end
end

function MaterialModTemplate_OnClick()
	local index = this:GetClientID();
	local moddesc = allMatModDescs[index];
	SetMapMaterialInfoFrame(moddesc);
end

function InitMaterialModsLayout()
	for i = 1, MaterialMods_Max do
		local x = 5 + ((i - 1) % 2) * 535;
		local y = 8 + math.floor((i - 1) / 2) * 161;
		getglobal("MaterialModsEntry"..i):SetPoint("topleft", "MaterialModsPlane", "topleft", x, y);
	end
end

function MapMaterialUpdateMaterialMods()
	Log("MapMaterialUpdateMaterialMods");

	for i = 1, MaterialMods_Max do
		local modui = getglobal("MaterialModsEntry"..i);
		if i <= #allMatModDescs then
			local moddesc = allMatModDescs[i];
			modui:Show();
			UpdateSingleMatMod(modui, moddesc);
		else
			modui:Hide();
		end
	end

	local plane = getglobal("MaterialModsPlane");
	local minheight = plane:GetRealHeight();
	plane:SetSize(1, math.max(math.ceil(#allMatModDescs / 2) * 161, 530));
end

function UpdateSingleMatMod(modui, moddesc)
	local uiname = modui:GetName();
	if moddesc then
		getglobal(uiname.."Name"):SetText(moddesc.name or "");

		if ModEditorMgr:checkFileExist(moddesc.rootDir.."/icon.png") then
			getglobal(uiname.."Pic"):SetTexture(moddesc.rootDir.."/icon.png", true);
		elseif ModEditorMgr:checkFileExist(moddesc.rootDir.."/icon.png_") then
			getglobal(uiname.."Pic"):SetTexture(moddesc.rootDir.."/icon.png_", true);
		else
			getglobal(uiname.."Pic"):SetTexture("ui/mobile/texture2/bigtex/materialmodthumb.png");
		end

		getglobal(uiname.."AuthorName"):SetText(moddesc.author or "");

		getglobal(uiname.."Desc"):SetText(moddesc.description or "");

		--TODO download_count
		local download_num = moddesc.download_count or 0;
		if  lang_show_as_K() and download_num > 1000 then
			getglobal(uiname.."Down"):SetText(string.format("%0.1f", download_num/1000).. 'K');
		elseif  download_num > 10000 then
			getglobal(uiname.."Down"):SetText(string.format("%0.1f", download_num/10000)..GetS(3841)); --X.X万
		else
			getglobal(uiname.."Down"):SetText(tostring(download_num));
		end

		if curWorldMatModDesc and curWorldMatModDesc.uuid == moddesc.uuid then
			getglobal(uiname.."CheckBtnChecked"):Show();
		elseif curWorldMatModDesc == nil and moddesc == defaultMatModDesc then
			getglobal(uiname.."CheckBtnChecked"):Show();
		else
			getglobal(uiname.."CheckBtnChecked"):Hide();
		end

		if originWorldMatModDesc and originWorldMatModDesc.uuid == moddesc.uuid then
			getglobal(uiname.."UseTag"):Show();
		elseif originWorldMatModDesc == nil and moddesc == defaultMatModDesc then
			getglobal(uiname.."UseTag"):Show();
		else
			getglobal(uiname.."UseTag"):Hide();
		end
	else
		getglobal(uiname.."Pic"):SetTexture("");
	end
end

function SetMapMaterialFrameDealMsg(isDeal)
	getglobal("MaterialMods"):setDealMsg(isDeal);
end

--------------------------------------------------------------------------------------

function SetMapMaterialInfoFrame(moddesc)
	MapMaterialInfo_ModDesc = moddesc;

	getglobal("MapMaterialInfoFrameIntroduceName"):SetText(moddesc.name or "");

	getglobal("MapMaterialInfoFrameIntroduceAuthor"):SetText(moddesc.author or "");

	if ModEditorMgr:checkFileExist(moddesc.rootDir.."/icon.png") then
		getglobal("MapMaterialInfoFrameIntroduceThumb"):SetTexture(moddesc.rootDir.."/icon.png", true);
	elseif ModEditorMgr:checkFileExist(moddesc.rootDir.."/icon.png_") then
		getglobal("MapMaterialInfoFrameIntroduceThumb"):SetTexture(moddesc.rootDir.."/icon.png_", true);
	else
		getglobal("MapMaterialInfoFrameIntroduceThumb"):SetTexture("ui/mobile/texture2/bigtex/materialmodthumb.png");
	end

	getglobal("MapMaterialInfoFrameIntroduceDesc"):SetText(moddesc.description or "");

	if not getglobal("MapMaterialInfoFrame"):IsShown() then
		getglobal("MapMaterialInfoFrame"):Show();
		SetMapMaterialFrameDealMsg(false);
	end
end

function MapMaterialInfoFrame_OnShow()
	getglobal("MapMaterialInfoFrameMask"):Show();
	getglobal("MapMaterialInfoFrameIntroduceNameTitle"):SetText(GetS(351) .. ":");
	getglobal("MapMaterialInfoFrameIntroduceAuthorTitle"):SetText(GetS(352) .. ":");
end

function MapMaterialInfoFrame_OnHide()
	getglobal("MapMaterialInfoFrameMask"):Hide();
	SetMapMaterialFrameDealMsg(true);
end

function MapMaterialInfoFrameCloseBtn_OnClick()
	getglobal("MapMaterialInfoFrame"):Hide();
end

function MapMaterialInfoFrame_OnClick()

end

function MapMaterialInfoFrameMask_OnClick()
	MapMaterialInfoFrameCloseBtn_OnClick();
end
