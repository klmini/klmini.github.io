
local NeedInit = true;
local WorldTerrainType = 1;	--1Ä¬ÈÏ 0Æ½Ì¹ 4¿Õµº
local Landforms_Max_Num = 11; -- 新增雨林，扩充到10
local SpecialType = 0;	--特殊玩法地图(普通玩法0，家园为1)

local creatingWorldModInfo = nil;
local CreateWorldRule_TerrainParam;	--地形参数配置
local OnlyCreateUserDataIdx = 1

--是否在自定义中设置了地形
local CreateWorldRule_IsModifyTerrain = false

-- 新增创建世界开发者配置埋点
-- 场景ID
local CreateWorldSID = "402"

-- 栏目ID
local CreateWorldDevCID = "MINI_CREATEWORLD__DEVELOPERMODE_1"
-- 组件ID
local CreateWorldDevOID = {
    Default = "-",
    ModChos = "Modechoose",
    StartGame = "Startgame",
    SetDefault = "Default",
}

-- -- eventID   game_open 赋值给 全局变量standReportGameOpenParam 进入游戏会自动上报
local CreateWorldDevEID = {
    View = "view", 
    Click = "click",
}

----xyang20220526 --模式 0老模式  1新UGC模式
--local GlobalCreateUGCMode = nil
local CreateUGCMode = false
local fromCreatorTemplate = false

local function CreateWorldRuleGetComponentCount()
	local componentCount = creatingWorldModInfo and creatingWorldModInfo.componentCount
	componentCount = componentCount or 0
	return componentCount
end

local function CreateWorldRuleGetModCount()
	local modCount = creatingWorldModInfo and creatingWorldModInfo.modCount
	modCount = modCount or 0
	return modCount
end

--1. 打开开发者模式
function CreateWorldRuleFrameAdvancedSetBtn_OnClick()
    CurNewWorldType = 4;

	local nickName = ReplaceFilterString(AccountManager:getNickName());
    getglobal("WorldRuleBoxMapNameEdit"):SetDefaultText(nickName..GetS(674));
    UpdateMapModInfo()

	local CreateWorldData = GetCreateWorldData()
	if CreateWorldData then
		OpenCreateWorldRuleFrame(CreateWorldData.onlyCreate, CreateWorldData.onlyCreateEvt, false, true)
	end
end

--1. 打开高级开发者模式
function CreateWorldRuleFrameUGCAdvancedSetBtn_OnClick()
    CurNewWorldType = 4;

	local nickName = ReplaceFilterString(AccountManager:getNickName());
    getglobal("WorldRuleBoxMapNameEdit"):SetDefaultText(nickName..GetS(674));
    UpdateMapModInfo()

    GetInst("UGCCommon"):UGCStandReportEvent("402", "MINI_CREATEWORLD_EXPERTCREATE", "ExpertCreateTag", "click")

	local CreateWorldData = GetCreateWorldData()
	if CreateWorldData then
    	OpenCreateWorldRuleFrame(CreateWorldData.onlyCreate, CreateWorldData.onlyCreateEvt, true, true)
	end
end

--顶部tab按钮
local m_CreateWorldRuleTabBtnInfo = {
    normalColor = {186, 210, 210},
    checkedColor = {76, 76, 76},
	{nameID = 6303, uiName="CreateWorldRuleFrameAdvancedSet", OnClick = CreateWorldRuleFrameAdvancedSetBtn_OnClick},     --开发者模式
    {nameID = 300361, uiName="CreateWorldRuleFrameUGCAdvancedSet", OnClick = CreateWorldRuleFrameUGCAdvancedSetBtn_OnClick}, --高级开发者模式
};

--tab按钮点击
function CreateWorldRuleTabBtnTemplate_OnClick(id)
    if id then
        id = id;
    else
        id = this:GetClientID();
    end

    print("CreateWorldRuleTabBtnTemplate_OnClick, id = ", id);

    --切换选中状态
    TemplateTabBtn2_SetState(m_CreateWorldRuleTabBtnInfo, id);

    if id == 0 then return; end

    --点击事件
    if m_CreateWorldRuleTabBtnInfo[id] and m_CreateWorldRuleTabBtnInfo[id].OnClick then
        m_CreateWorldRuleTabBtnInfo[id].OnClick();
    end
end

function IsOneChooseLandforms()
	local num = 0;
	for i=1, Landforms_Max_Num do
		local tick = getglobal("WorldRuleBoxLandforms"..i.."Tick");
		if tick:IsShown() then
			num = num + 1;
		end
	end

	if num > 1 then
		return false;	
	else
		return true;
	end
end

function OpenCreateWorldRuleFrame(onlyCreate, onlyCreateEvt, isUGCMode, isFromCreatorTemplate)
    CloseCreateWorldRuleFrame()
	local createFrame = getglobal("CreateWorldRuleFrame")
    if onlyCreate then
        createFrame:SetClientUserData(OnlyCreateUserDataIdx, 1)
        if "string" == type(onlyCreateEvt) and onlyCreateEvt ~= "" then
            createFrame:SetClientString(onlyCreateEvt)
        end
    end
	CreateUGCMode = isUGCMode
	fromCreatorTemplate = isFromCreatorTemplate 
    createFrame:Show()

	-- 高级模式会改变状态, 这里重置一下
	ResetFromCreateWorldTemplete()
end

function CloseCreateWorldRuleFrame()
	local createFrame = getglobal("CreateWorldRuleFrame")
    createFrame:SetClientUserData(OnlyCreateUserDataIdx, 0)
    createFrame:SetClientString("")
    createFrame:Hide()
	if getglobal("CreateWorldRuleFrameBgMask") then
		getglobal("CreateWorldRuleFrameBgMask"):Hide();
	end
	if getglobal("CreateWorldRuleFrameClickIntercept") then
		getglobal("CreateWorldRuleFrameClickIntercept"):Hide();
	end

	GetInst("UIManager"):Close("createWorldTemplete")
	GetInst("UIManager"):Close("createWorldTempDetail")
end

function WorldRuleCheckBtnTemplate_OnClick()
	local btnName = this:GetName();
	local tick = getglobal(this:GetName().."Tick");
	if string.find(btnName, "Landforms") then
		local optional = this:GetClientUserData(0);
		if optional == 1 then
			ShowGameTips(GetS(698), 3);
			return;
		elseif IsOneChooseLandforms() and tick:IsShown() then
			ShowGameTips(GetS(740), 3);
			return;
		end
	elseif string.find(btnName, "FlatTerrain") then
		--LLDO:平坦地形设置:这里是单选
		local id = this:GetClientID();
		Log("FlatTerrain: id = " .. id);
		CreateWorldRule_FlatTerrainCheckBtnState(id);
		return;
	elseif string.find(btnName, "Monster") then
		local id = this:GetClientID();

		if tick:IsShown() then
			SetMonsterStatus(id, false)
		else
			SetMonsterStatus(id, true)
		end
	end

	if tick:IsShown() then
		tick:Hide();
	else
		tick:Show();
	end
	SetTempleteTerrainData()
end

function CreateWorldRuleFrameResetBtn_OnClick()
	-- 开发者模式栏目 恢复默认按钮点击埋点
	standReportEvent(CreateWorldSID, CreateWorldDevCID, CreateWorldDevOID.SetDefault, CreateWorldDevEID.Click)

	SetDefaultRule();
end

function WorldRuleBoxMapSizeLongEdit_OnFocusLost()
	local edit = getglobal("WorldRuleBoxMapSizeLongEdit");
	local text = edit:GetText();

	if text ~= "" then
		local num = tonumber(text);
		if not num then
			ShowGameTips(GetS(699), 3);
			edit:Clear();
		elseif num == 0 then
			edit:Clear();
		end
	end
	SetTempleteTerrainData()
end

function WorldRuleBoxMapSizeWidthEdit_OnFocusLost()
	local edit = getglobal("WorldRuleBoxMapSizeWidthEdit");
	local text = edit:GetText();

	if text ~= "" then
		local num = tonumber(text);
		if not num then
			ShowGameTips(GetS(699), 3);
			edit:Clear();
		elseif num == 0 then
			edit:Clear();
		end
	end
	SetTempleteTerrainData()
end

--随机
function WorldRuleBoxTerrain1_OnClick()
	if WorldTerrainType ~= 1 then
		SetWorldTerrain(1, 1);
		
		-- 开发者栏选择游戏模式 点击埋点
		standReportEvent(CreateWorldSID, CreateWorldDevCID, CreateWorldDevOID.ModChos, CreateWorldDevEID.Click)
	end
end

--平坦
function WorldRuleBoxTerrain2_OnClick()
	--LLDO: 老的是打开一个选择窗口, 新的改为下拉框
	if false then
		getglobal("ChooseFlatTypeFrame"):Show();
	else
		--新的
		SetWorldTerrain(0, 2);

		-- 开发者栏选择游戏模式 点击埋点
		standReportEvent(CreateWorldSID, CreateWorldDevCID, CreateWorldDevOID.ModChos, CreateWorldDevEID.Click)
	end
end

--空岛
function WorldRuleBoxTerrain3_OnClick()
	if WorldTerrainType ~= 4 then
		SetWorldTerrain(4, 3);
		--SetWorldTerrain(0, 3);

		-- 开发者栏选择游戏模式 点击埋点
		standReportEvent(CreateWorldSID, CreateWorldDevCID, CreateWorldDevOID.ModChos, CreateWorldDevEID.Click)
	end
end

--"自定义"按钮点击
function WorldRuleBoxTerrain4_OnClick()
	if WorldTerrainType ~= 5 then
		SetWorldTerrain(5, 4);

		-- 开发者栏选择游戏模式 点击埋点
		standReportEvent(CreateWorldSID, CreateWorldDevCID, CreateWorldDevOID.ModChos, CreateWorldDevEID.Click)
	end
end

function CreateWorldRuleFrameNameEdit_OnFocusLost()
	local nameEdit = getglobal("WorldRuleBoxMapNameEdit");
	if nameEdit:GetText() ~= "" and nameEdit:GetText() ~= nameEdit:GetDefaultText() then
		StatisticsTools:gameEvent("ModifyWorldName");
	end
	SetTempleteTerrainData()
end

function CreateWorldRuleFrameNameEdit_OnEnterPressed()
	CreateWorldRuleFrameCreateBtn_OnClick();
end

--地图改名限制
function CreateWorldRuleFrameNameEdit_OnClick()
    -- 限制修改地图名:ShowGameTips('因您不符合政策要求，暂时无法使用此功能', 3);
    if FunctionLimitCtrl:IsNormalBtnClick(FunctionType.RSET_MAPNAME) then
    	--常规
    else
    	--限制
        this:enableEdit(false);
    	return;
    end
end

local t_LandformsBit = {BIOME_PLAINS, BIOME_DESERT, BIOME_FOREST, BIOME_SWAMPLAND, BIOME_OCEAN, BIOME_EXTREMEHILLS, BIOME_TAIGA, BIOME_JUNGLE, BIOME_BASIN, BIOME_RAINFOREST, BIOME_AIR_PLAINS}
function GetWorldRuleLandformsBit()
	local landformsBit = 0;
	for i=1, Landforms_Max_Num do
		local tick = getglobal("WorldRuleBoxLandforms"..i.."Tick");
		if not tick:IsShown() then
			landformsBit = landformsBit + 2^t_LandformsBit[i];
		end
	end

	return landformsBit;
end

-------家园定制地图制作--------
local isHomeGardonCustomize = false
function HomeLandTerrianBtn_Layout()
	if LuaInterface and LuaInterface:isdebug() and isHomeGardonCustomize then
		getglobal("WorldRuleBoxTerrain5"):Show()
		getglobal("WorldRuleBoxTerrain5Name"):SetText("家园定制地图")
	end
end

function createHomeGardenWorld()
	--LLDO:世界名字.
	local worldName = getglobal("WorldRuleBoxMapNameEdit"):GetText();
	if CheckFilterString(worldName) then return end

	if worldName == "" then
		if 2 == SpecialType then
			worldName = "家园定制地图";
		else
			worldName = "我的家园";
		end
	end

	local landformsBit = GetWorldRuleLandformsBit();
	--¹ÖÎï
	local monBit = 0;
	if not getglobal("WorldRuleBoxMonster1Tick"):IsShown() then
		monBit = monBit + 2^1;
	end
	if not getglobal("WorldRuleBoxMonster2Tick"):IsShown() then
		monBit = monBit + 2^0;
	end

	local modUUids = GetSelectedModTable();
	Log("CreateWorldRuleFrameCreateBtn_OnClick");
	Log("modUUids = ");

	for i=1, #modUUids do
		local uuid = modUUids[i];

		ModMgr:markForAddMod(uuid);
	end

	--LLDO:加上地图种子
	local seedEditUI = "WorldRuleBoxTerrainRandomTerrainParamFrameSeedEditFrameEdit"
	local seedEditObj = getglobal(seedEditUI);
	local mapSeed = "";
	WorldTerrainType = 13

	local m_WorldTerrainType = WorldTerrainType;

	if AccountManager:requestCreateWorld(4, worldName, m_WorldTerrainType, mapSeed, AccountManager:getRoleModel(), 9, 11, landformsBit, monBit, false, SpecialType) then
		if not AccountManager:getNoviceGuideState("createworld") then
			AccountManager:setNoviceGuideState("createworld", true);
		end

		CloseCreateWorldFrame()
		CloseCreateWorldRuleFrame()
		ShowLoadingFrame();

		local wdesc = AccountManager:getCurWorldDesc()
		if wdesc and (wdesc.worldtype == 4 or wdesc.worldtype == 5) then
			local code = AccountManager:dev_developer_info(AccountManager:getUin())--这个请求里面已经做了缓存
			if code == ErrorCode.OK then
				AccountManager:syncWorldDesc(wdesc.worldid, 2)
			end
		end
	end
end

function WorldRuleBoxTerrain5_OnClick()
	SpecialType = 6;
	createHomeGardenWorld();
end

function CreateWorldUGCSelectBtnTemplate_OnClick()
    --GlobalCreateUGCMode = this:GetClientID();
	--getglobal("CreateWorldRuleFrameUGCModeSelectFrame"):Hide()
	--CreateWorldRuleFrameCreateBtn_OnClick()
	--local event = GlobalCreateUGCMode == 0 and "Foundation" or "Senior"
	--local eventTab = {
	--	standby1 = "113",
	--}
	--standReportEvent(CreateWorldSID,"MINI_CREATEWORLD__DEVELOPERMODE_CHOSE",event,"click", eventTab)
end

-------家园测试代码--------
--´´½¨µØÍ¼
function CreateWorldRuleFrameCreateBtn_OnClick(noClick)
	--if ns_version and ns_version.showUGCSelector and check_apiid_ver_conditions(ns_version.showUGCSelector) then
	--	if GlobalCreateUGCMode == nil then--模式 0老模式  1新UGC模式
	--		getglobal("CreateWorldRuleFrameUGCModeSelectFrame"):Show()
	--		standReportEvent(CreateWorldSID,"MINI_CREATEWORLD__DEVELOPERMODE_CHOSE","-","view")
	--		return
	--	end
	--else
	--	GlobalCreateUGCMode = 0--默认老模式
	--end

	-- 创建新版编辑模式
	if CreateUGCMode then
		CreateWorldRuleFrameCreateNewUGCBtn_OnClick(noClick)
		return
	end

	local enterGameCb = function ()
	if not CreateWorldRule_TerrainParam.onlyCreate then
		local teamupSer = GetInst("TeamupService")
		if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
			ShowGameTips(GetS(26045))
			return
		end
	end

	if not noClick then
		-- 开发者模式 开始游戏点击埋点
		standReportEvent(CreateWorldSID, CreateWorldDevCID, CreateWorldDevOID.StartGame, CreateWorldDevEID.Click)

		if IsShowFguiStartMain() then
			standReportEvent("15", "XSELECT_GAME", "XCWOpengame", "click",{standby1 = "2"})
		end
	end
	
	-- 开发者模式 gameopen埋点
	standReportGameOpenParam = {
        sceneid     = CreateWorldSID,
        cardid		= CreateWorldDevCID,
        compid		= CreateWorldDevOID.StartGame,
        standby1    = "114"
    }
	
	GetInst("ReportGameDataManager"):NewGameLoadParam(CreateWorldSID,CreateWorldDevCID,CreateWorldDevOID.StartGame)
	GetInst("ReportGameDataManager"):SetGameMapOwn(GetInst("ReportGameDataManager"):GetGameMapOwnDefine().myMap)
    GetInst("ReportGameDataManager"):SetGameNetType(GetInst("ReportGameDataManager"):GetGameNetTypeDefine().singleMode)
	GetInst("ReportGameDataManager"):SetGameMapMode(GetInst("ReportGameDataManager"):GetDefineGameModeType().developEdit)

	--LLDO:世界名字.
	local worldName = getglobal("WorldRuleBoxMapNameEdit"):GetText();
	if CheckFilterString(worldName) then return end

	if worldName == "" then
		worldName = getglobal("WorldRuleBoxMapNameEdit"):GetDefaultText();
	end
	
	--大小
	local long = getglobal("WorldRuleBoxMapSizeLongEdit"):GetText();
	if long == "" then	--ÎÞÏÞ
		long = 0;
	end
	local width = getglobal("WorldRuleBoxMapSizeWidthEdit"):GetText();
	if width == "" then
		width = 0;
	end


	local landformsBit = GetWorldRuleLandformsBit();
	--¹ÖÎï
	local monBit = 0;
	if not getglobal("WorldRuleBoxMonster1Tick"):IsShown() then
		monBit = monBit + 2^1;
	end
	if not getglobal("WorldRuleBoxMonster2Tick"):IsShown() then
		monBit = monBit + 2^0;
	end

	local modUUids = GetSelectedModTable();
	Log("CreateWorldRuleFrameCreateBtn_OnClick");
	Log("modUUids = ");

	for i=1, #modUUids do
		local uuid = modUUids[i];

		ModMgr:markForAddMod(uuid);

		-- statisticsGameEvent(506, '%lls', modUUids[i], '%d', 3);
	end

	-- if #modUUids > 0 then
		-- statisticsGameEvent(508);
		--StatisticsTools:gameEvent("ModEvent", "创建地图时加载了mod");
	-- end

	--LLDO:加上地图种子
	local seedEditUI = "WorldRuleBoxTerrainRandomTerrainParamFrameSeedEditFrameEdit"
	local seedEditObj = getglobal(seedEditUI);
	local mapSeed = "";
	if WorldTerrainType == 1 then
		--随机地形
		if CreateWorldRule_TerrainParam.IsUseRandomTerrainSeed then
			mapSeed = seedEditObj:GetText() or "";
			seedEditObj:Clear();
		end
	else
		seedEditObj:Clear();
	end

	local m_WorldTerrainType = WorldTerrainType;
	if WorldTerrainType == 5 then
		--自定义地形, 跟随机地形一样.
		m_WorldTerrainType = 1;
	end

	GetInst("MiniUIManager"):CloseUI("GameTemplatePanelAutoGen");
	GetInst("MiniUIManager"):CloseUI("CreatorTemplateAutoGen");
	
	local cInterface = GetInst("CreationCenterInterface")
	if cInterface and cInterface.EnterGameCloseCreationCenterFrames then
		cInterface:EnterGameCloseCreationCenterFrames()
	end
	
	if CreateWorldRule_TerrainParam.onlyCreate then
		local worldid = AccountManager:requestCreateWorldNotEnter(4, worldName, m_WorldTerrainType, mapSeed, AccountManager:getRoleModel(), long, width, landformsBit, monBit, false, SpecialType, 0)
		if worldid and worldid > 0 then
			CloseCreateWorldFrame()
			CloseCreateWorldRuleFrame()

			local wdesc = AccountManager:findWorldDesc(worldid)
			if wdesc and (wdesc.worldtype == 4 or wdesc.worldtype == 5) then
				local code = AccountManager:dev_developer_info(AccountManager:getUin())--这个请求里面已经做了缓存
				if code == ErrorCode.OK then
					AccountManager:syncWorldDesc(wdesc.worldid, 2)
				end
			end

			if CreateWorldRule_TerrainParam.onlyCreateEvt then
                LuaGameEventTb.event(CreateWorldRule_TerrainParam.onlyCreateEvt,{worldid=worldid})
            end			
		end
	else
		--if AccountManager:requestCreateWorldWithMods(tmpMods, modCount, 4, worldName, WorldTerrainType, "", AccountManager:getRoleModel(), long, width, landformsBit, monBit) then
		if AccountManager:requestCreateWorld(4, worldName, m_WorldTerrainType, mapSeed, AccountManager:getRoleModel(), long, width, landformsBit, monBit, false, SpecialType, 0) then
			if not AccountManager:getNoviceGuideState("createworld") then
				AccountManager:setNoviceGuideState("createworld", true);
			end
			StatisticsWorldCreationEvent(4);
			-- statisticsGameEvent(8003,"%d",4);
			-- statisticsGameEvent(8006,"%d",4);
			CloseCreateWorldFrame()
	
			CloseCreateWorldRuleFrame()
			ShowLoadingFrame();
	
			local wdesc = AccountManager:getCurWorldDesc()
			if wdesc and (wdesc.worldtype == 4 or wdesc.worldtype == 5) then
				local code = AccountManager:dev_developer_info(AccountManager:getUin())--这个请求里面已经做了缓存
				if code == ErrorCode.OK then
					AccountManager:syncWorldDesc(wdesc.worldid, 2)
				end
			end
		end
	end
	
	--世界创建信息统计
	local param = {}
	if WorldTerrainType == 10 or WorldTerrainType == 11 or WorldTerrainType == 0 or WorldTerrainType == 12 then 
		param.terrainType = WorldTerrainType
		param.terrainModeType = 0
	else
		param.terrainType = 0
		param.terrainModeType = WorldTerrainType
	end 
	param.haveComponent = (CreateWorldRuleGetComponentCount() > 0) and 1 or 0
	param.haveMod = (CreateWorldRuleGetModCount() > 0) and 1 or 0
	param.haveSet = 0
	param.haveCode = CreateWorldRule_TerrainParam.IsUseRandomTerrainSeed and 1 or 0
	param.haveModify = CreateWorldRuleSetIsModifyTerrain and 1 or 0 
	CreateWorldStatistics(param)
	end
	
	MinieduRemind_OnStartClick(enterGameCb)
end

-- 加个回调函数, 把创建出来的地图id传进去
function CreateWorldRuleFrameCreateNewUGCBtn_OnClick(noClick, CreateCallback)
	local enterGameCb = function ()
		if not CreateWorldRule_TerrainParam.onlyCreate then
			local teamupSer = GetInst("TeamupService")
			if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
				ShowGameTips(GetS(26045))
				return
			end
		end

		if not noClick then
			-- 开发者模式 开始游戏点击埋点
			standReportEvent(CreateWorldSID, CreateWorldDevCID, CreateWorldDevOID.StartGame, CreateWorldDevEID.Click)

			if IsShowFguiStartMain() then
				standReportEvent("15", "XSELECT_GAME", "XCWOpengame", "click",{standby1 = "2"})
			end
		end
		
		-- 开发者模式 gameopen埋点
		standReportGameOpenParam = {
			sceneid     = CreateWorldSID,
			cardid		= CreateWorldDevCID,
			compid		= CreateWorldDevOID.StartGame,
			standby1    = "114"
		}

		--LLDO:世界名字.
		local worldName = getglobal("WorldRuleBoxMapNameEdit"):GetText();
		if CheckFilterString(worldName) then return end

		if worldName == "" then
			worldName = getglobal("WorldRuleBoxMapNameEdit"):GetDefaultText();
		end
		
		--大小
		local long = getglobal("WorldRuleBoxMapSizeLongEdit"):GetText();
		if long == "" then	--ÎÞÏÞ
			long = 0;
		end
		local width = getglobal("WorldRuleBoxMapSizeWidthEdit"):GetText();
		if width == "" then
			width = 0;
		end


		local landformsBit = GetWorldRuleLandformsBit();
		-- 有回调则认为是从高级模式纯随机调用进来的.
		if CreateCallback then
			landformsBit = 0
		end
		-- 这个地方改成开关判定, 有可能界面是隐藏的时候调用过来
		-- local monBit = 0;
		-- if not getglobal("WorldRuleBoxMonster1Tick"):IsShown() then
		-- 	monBit = monBit + 2^1;
		-- end
		-- if not getglobal("WorldRuleBoxMonster2Tick"):IsShown() then
		-- 	monBit = monBit + 2^0;
		-- end
		local monBit = 0;
		if not GetMonsterStatus(1) then
			monBit = monBit + 2^1;
		end
		if not GetMonsterStatus(2) then
			monBit = monBit + 2^0;
		end

		local modUUids = GetSelectedModTable();

		for i=1, #modUUids do
			local uuid = modUUids[i];

			ModMgr:markForAddMod(uuid);

			-- statisticsGameEvent(506, '%lls', modUUids[i], '%d', 3);
		end

		-- if #modUUids > 0 then
			-- statisticsGameEvent(508);
			--StatisticsTools:gameEvent("ModEvent", "创建地图时加载了mod");
		-- end

		--LLDO:加上地图种子
		local seedEditUI = "WorldRuleBoxTerrainRandomTerrainParamFrameSeedEditFrameEdit"
		local seedEditObj = getglobal(seedEditUI);
		local mapSeed = "";
		if WorldTerrainType == 1 then
			--随机地形
			if CreateWorldRule_TerrainParam.IsUseRandomTerrainSeed then
				mapSeed = seedEditObj:GetText() or "";
				seedEditObj:Clear();
			end
		else
			seedEditObj:Clear();
		end

		local m_WorldTerrainType = WorldTerrainType;
		if WorldTerrainType == 5 then
			--自定义地形, 跟随机地形一样.
			m_WorldTerrainType = 1;
		end

		GetInst("MiniUIManager"):CloseUI("GameTemplatePanelAutoGen");
		GetInst("MiniUIManager"):CloseUI("CreatorTemplateAutoGen");
		
		local cInterface = GetInst("CreationCenterInterface")
		if cInterface and cInterface.EnterGameCloseCreationCenterFrames then
			cInterface:EnterGameCloseCreationCenterFrames()
		end
		
		if CreateWorldRule_TerrainParam.onlyCreate then
			local worldid = AccountManager:requestCreateWorldNotEnter(4, worldName, m_WorldTerrainType, mapSeed, AccountManager:getRoleModel(), long, width, landformsBit, monBit, false, SpecialType, 1)
			if worldid and worldid > 0 then
				CloseCreateWorldFrame()
				CloseCreateWorldRuleFrame()

				local wdesc = AccountManager:findWorldDesc(worldid)
				if wdesc and (wdesc.worldtype == 4 or wdesc.worldtype == 5) then
					local code = AccountManager:dev_developer_info(AccountManager:getUin())--这个请求里面已经做了缓存
					if code == ErrorCode.OK then
						AccountManager:syncWorldDesc(wdesc.worldid, 2)
					end
				end

				if CreateWorldRule_TerrainParam.onlyCreateEvt then
					LuaGameEventTb.event(CreateWorldRule_TerrainParam.onlyCreateEvt,{worldid=worldid})
				end
				if CreateCallback then
					CreateCallback(worldid)
				end
			end
		else
			if AccountManager:requestCreateWorld(4, worldName, m_WorldTerrainType, mapSeed, AccountManager:getRoleModel(), long, width, landformsBit, monBit, false, SpecialType, 1) then
				if not AccountManager:getNoviceGuideState("createworld") then
					AccountManager:setNoviceGuideState("createworld", true);
				end
				StatisticsWorldCreationEvent(4);
				-- statisticsGameEvent(8003,"%d",4);
				-- statisticsGameEvent(8006,"%d",4);
				CloseCreateWorldFrame()
		
				CloseCreateWorldRuleFrame()
				ShowLoadingFrame();

				local wdesc = AccountManager:getCurWorldDesc()
				if wdesc then
					-- 高级编辑模式，换Loading图
					if type(UGCToolModeUpdateLoadingTexture) == "function" then
						UGCToolModeUpdateLoadingTexture(wdesc);
					end

					if (wdesc.worldtype == 4 or wdesc.worldtype == 5) then
						local code = AccountManager:dev_developer_info(AccountManager:getUin())--这个请求里面已经做了缓存
						if code == ErrorCode.OK then
							AccountManager:syncWorldDesc(wdesc.worldid, 2)
						end
					end
					
					if CreateCallback then
						CreateCallback(wdesc.worldid)
					end
				end
			end
		end
		
		--世界创建信息统计
		local param = {}
		if WorldTerrainType == 10 or WorldTerrainType == 11 or WorldTerrainType == 0 or WorldTerrainType == 12 then 
			param.terrainType = WorldTerrainType
			param.terrainModeType = 0
		else
			param.terrainType = 0
			param.terrainModeType = WorldTerrainType
		end 
		param.haveComponent = (CreateWorldRuleGetComponentCount() > 0) and 1 or 0
		param.haveMod = (CreateWorldRuleGetModCount() > 0) and 1 or 0
		param.haveSet = 0
		param.haveCode = CreateWorldRule_TerrainParam.IsUseRandomTerrainSeed and 1 or 0
		param.haveModify = CreateWorldRuleSetIsModifyTerrain and 1 or 0 
		CreateWorldStatistics(param)
	end
	
	MinieduRemind_OnStartClick(enterGameCb)
	if not CreateCallback then
		GetInst("UGCCommon"):UGCStandReportEvent("402", "MINI_CREATEWORLD_EXPERTCREATE", "ExpertCreate", "click")
	end
end

function CreateWorldRuleSetIsModifyTerrain(isModifyTerrain)
	CreateWorldRule_IsModifyTerrain = isModifyTerrain
end

--
local changeSpeed = 4;
local changeOffset = changeSpeed
local curOffset = 0;
function CreateWorldRuleFrameGuideArrow_OnUpdate()	
	local arrow = getglobal("CreateWorldRuleFrameGuideArrow");
	curOffset = curOffset + changeOffset;
	if curOffset > 20 then
		curOffset = 15;
		changeOffset = -changeSpeed;
	elseif curOffset <= 0 then
		curOffset = 0;
		changeOffset = changeSpeed*0.5;
	end
	arrow:SetPoint("bottomright", "WorldRuleBox", "bottomright", 0, -(curOffset+2));

	if getglobal("WorldRuleBox"):getCurOffsetY() < -190 then
		getglobal("CreateWorldRuleFrameGuideArrow"):Hide();
		AccountManager:setNoviceGuideState("guidechoosemod", true);
	end
end

--关闭按钮
function CreateWorldRuleFrameCloseBtn_OnClick()
	local CreateWorldData = GetCreateWorldData()
	if CreateWorldData.UgcEnterRule then
		GetInst("UIManager"):GetCtrl("createWorldTemplete"):leaveWorldRule()
		return
	elseif CreateWorldData.UgcEnterOldRule then
		CreateWorldData.UgcEnterRule = false
		CreateWorldFrameUGCAdvancedSetBtn_OnClick()
		return
    end

	CloseCreateWorldRuleFrame()
	CloseCreateWorldFrame()
	JsBridge:PopFunction()
	--MiniBase触发退出游戏回到APP
	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_LeaveGame",  SandboxContext():SetData_Number("code", 0))

	--如果官方模板存在不退回存档界面
	if GetInst("MiniUIManager"):GetUI("GameTemplatePanelAutoGen") then
		return
	end

	--LLDO:参考函数:CreateWorldFrameBackBtn_OnClick().

	if not CreateWorldRule_TerrainParam.onlyCreate then
		if g_lobbyShowParam then
			EnterMainMenuInfo.EnterWorldId = nil;
			EnterMainMenuInfo.MainFilter = nil;
			EnterMainMenuInfo.SubFilter = nil;
			EnterMainMenuInfo.NotRefreshSetting = nil;
			EnterMainMenuInfo.MaterialOpen = nil;
			EnterMainMenuInfo.MapDetailOpen = nil;
			ShowLobby({notRefresh = true, selectOwid = g_lobbyShowParam.EnterWorldId, mapDetailOpen = g_lobbyShowParam.MapDetailOpen});
		end
	end
end

function CreateWorldRuleFrameUGCCloseBtn_OnClick()
	getglobal("CreateWorldRuleFrameUGCModeSelectFrame"):Hide()
end

local t_LandformsSetSid = {687, 688, 689, 730, 691, 692, 693, 694, 1243, 2075, 86005}
local t_MosterSetSid = {696, 697}
local t_TerrainStringSid = {682, 683, 684, 4544}
function CreateWorldRuleFrame_OnLoad()
	local rows = math.ceil(Landforms_Max_Num/4);
	for i=1, rows do
		for j=1, 4 do
			local index = (i-1)*4 + j;
			if index <= Landforms_Max_Num then
				local landforms = getglobal("WorldRuleBoxLandforms" .. index);
				local name = getglobal("WorldRuleBoxLandforms" .. index .. "Name");

				landforms:SetPoint("topleft", "WorldRuleBoxLandforms", "topleft", (j - 1) * 200 + 125, (i - 1) * 41 + 13);
				name:SetText(GetS(t_LandformsSetSid[index]));
			end
		end
	end


	for i=1, 2 do
		local moster = getglobal("WorldRuleBoxMonster"..i);
		local name = getglobal("WorldRuleBoxMonster"..i.."Name");

		moster:SetPoint("topleft", "WorldRuleBoxMonster", "topleft", (i - 1) * 200 + 125, 13);
		name:SetText(GetS(t_MosterSetSid[i]));
	end



	for i=1, #(t_TerrainStringSid) do
		if true then
			local name = getglobal("WorldRuleBoxTerrain"..i.."Name");
			name:SetText(GetS(t_TerrainStringSid[i]));
		end
	end

	getglobal("CreateWorldRuleFrameGuideArrow"):setUpdateTime(0.05);
	--getglobal("WorldRuleBoxTerrain3Tips"):Show();

	---暂时只在999渠道显示高级物理开关
	if ClientMgr:getApiId() ~= 999 then
		getglobal("WorldRuleBoxAdvancedPhysics"):Hide()
		getglobal("WorldRuleBoxPlane"):SetHeight(852)
	end


	--高级物理开关默认关闭
	--_G.physx_config.enable=false
	--local point = getglobal("WorldRuleBoxAdvancedPhysicsSwitchPoint")
	--point:SetPoint("left", "WorldRuleBoxAdvancedPhysicsSwitch", "left", 4, -3);

end

function CreateWorldRuleFrame_OnShow()
	CreateWorldRule_IsModifyTerrain = false 
	getglobal("WorldRuleBox"):resetOffsetPos();

	--地形参数
    local createFrame = getglobal("CreateWorldRuleFrame")
    CreateWorldRuleFrameTerrainReset(createFrame:GetClientUserData(OnlyCreateUserDataIdx) == 1, createFrame:GetClientString());
    createFrame:SetClientUserData(OnlyCreateUserDataIdx, 0)
    createFrame:SetClientString("")

    local createBtnTxt = getglobal("CreateWorldRuleFrameCreateBtnText")
    if createBtnTxt then
		if CreateUGCMode then
			createBtnTxt:SetText(GetS(300361))
		else
			createBtnTxt:SetText(GetS(1000708))
		end	
    end
	
	local CreateWorldFrameAdvancedSetBtn = getglobal("CreateWorldRuleFrameAdvancedSet")
	local CreateWorldFrameUGCAdvancedSetBtn = getglobal("CreateWorldRuleFrameUGCAdvancedSet")
	-- 从创作中心来的，显示切换页签,显示遮罩背景
	if fromCreatorTemplate then
		getglobal("CreateWorldRuleFrameBgMask"):Show();
		getglobal("CreateWorldRuleFrameClickIntercept"):Show();

		if CreateWorldFrameAdvancedSetBtn and CreateWorldFrameUGCAdvancedSetBtn then
			CreateWorldFrameAdvancedSetBtn:Show()
			CreateWorldFrameUGCAdvancedSetBtn:Show()
			--初始化tab按钮状态
			local id = CreateUGCMode and 2 or 1
			TemplateTabBtn2_SetState(m_CreateWorldRuleTabBtnInfo, id);

			-- 创建高级模式开关
			if ns_version and ns_version.showUGCSelector and check_apiid_ver_conditions(ns_version.showUGCSelector, false) then
				getglobal("CreateWorldFrameUGCAdvancedSet"):Show()
			else
				getglobal("CreateWorldFrameUGCAdvancedSet"):Hide()
			end
		end
	else
		getglobal("CreateWorldRuleFrameBgMask"):Hide();
		getglobal("CreateWorldRuleFrameClickIntercept"):Hide();

		if CreateWorldFrameAdvancedSetBtn and CreateWorldFrameUGCAdvancedSetBtn then
			CreateWorldFrameAdvancedSetBtn:Hide()
			CreateWorldFrameUGCAdvancedSetBtn:Hide()
		end
	end

    -- local CreateNewUGCBtnTxt = getglobal("CreateWorldRuleFrameCreateNewUGCBtnText")
    -- if CreateNewUGCBtnTxt then
	-- 	CreateNewUGCBtnTxt:SetText(GetS(300203))
    -- end
	
	getglobal("CreateWorldRuleFrameTitleName"):SetText(GetS(1000708))

	--策划要求每次进入不需要有上次操作记录
	if --[[NeedInit or]] true then
		--NeedInit = false;
		SetDefaultRule();
		getglobal("WorldRuleBoxTerrain2Tips"):Hide();
	end
	local nickName = ReplaceFilterString(AccountManager:getNickName());
	----------StringBuilder-----
	--getglobal("WorldRuleBoxMapNameEdit"):SetDefaultText(nickName..GetS(755));

	--LLDO:名字编辑框
	getglobal("WorldRuleBoxMapNameEdit"):SetDefaultText(nickName..GetS(755));

	UpdateMapModInfo();

	--[[
	if not AccountManager:getNoviceGuideState("guidechoosemod") then
	--	getglobal("CreateWorldRuleFrameGuideArrow"):Show();
		getglobal("CreateWorldRuleFrameChooseModBtnGuide"):Show();
	else
	--	getglobal("CreateWorldRuleFrameGuideArrow"):Hide();
		getglobal("CreateWorldRuleFrameChooseModBtnGuide"):Hide();
	end
	]]
	if IsShowRegulationsTips then
		getglobal("RegulationsTipsFrame"):Show();
		IsShowRegulationsTips = false;
	end
	--家园定制地图按钮 显示隐藏
	HomeLandTerrianBtn_Layout()

	-- 开发者模式栏目 显示埋点
	standReportEvent(CreateWorldSID, CreateWorldDevCID, CreateWorldDevOID.Default, CreateWorldDevEID.View)
	-- 开发者模式栏目 开始按钮显示埋点
	standReportEvent(CreateWorldSID, CreateWorldDevCID, CreateWorldDevOID.StartGame, CreateWorldDevEID.View)
	-- 开发者模式栏目 恢复默认按钮显示埋点
	standReportEvent(CreateWorldSID, CreateWorldDevCID, CreateWorldDevOID.SetDefault, CreateWorldDevEID.View)
	---MiniBase 拉起开发者编辑页面回调
	if MiniBaseManager and MiniBaseManager:isMiniBaseGame() then
		--开发者模式标题
        getglobal("CreateWorldRuleFrameTitleName"):SetText(GetS(6303));		
	end
	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_NewDeveloperGame",  SandboxContext():SetData_Number("code", 0))
end

function CreateWorldRuleFrame_OnHide()
	local tips = getglobal("RegulationsTipsFrame");
    if tips:IsShown() then
        tips:Hide();
    end
end

--设置地形按钮状态
function SetWorldTerrain(type, index)
	--type: 地形类型
	--index: 按钮索引
	getglobal("WorldRuleBoxTerrain2Tips"):Hide();
	WorldTerrainType = type;

	for i=1, 4 do
		local name = getglobal("WorldRuleBoxTerrain"..i.."Name");
		local check = getglobal("WorldRuleBoxTerrain"..i.."Check");
		if i == index then
			check:Show();
		else
			check:Hide();
		end
	end

	SetLandformsOptional(type);

	CreateWorldRule_UpdateTerrainSet(index);
	
	--LLDO:特殊处理
	-- if true then
	-- 	--1. 平坦地形
	-- 	if index == 2 then
	-- 		CJSJRule_TerrainBtnLayout();

	-- 		local tipText = "(" .. GetS(1144) .. ")";	--纯白画布
	-- 		getglobal("WorldRuleBoxTerrain2Tips"):SetText(tipText);

	-- 		CJSJRule_IsShowTerrainDropFrame(true);
	-- 	else
	-- 		CJSJRule_IsShowTerrainDropFrame(false);
	-- 	end

	-- 	--2. 种子编辑框打开和关闭.
	-- 	if index == 1 then
	-- 		CJSJRule_IsShowSeedBtn(true);
	-- 	else
	-- 		CJSJRule_IsShowSeedBtn(false);
	-- 	end
	-- end
end

function ResetCreateWorldMods()
	Log("ResetCreateWorldMods");
	creatingWorldModInfo = nil;
	if creatingWorldModInfo == nil then

		Log("requestCreateMod...");
		if ModEditorMgr:requestCreateTempMapMod() == true then
			creatingWorldModInfo = {};

			local uuid = ModEditorMgr:getCurrentEditModUuid();  --the mod just created
			creatingWorldModInfo.defaultMapModUuid = uuid;

			creatingWorldModInfo.componentCount = 0;
			creatingWorldModInfo.modCount = 0;

			Log("uuid = "..uuid);

			ClearSelectedMods();

			--add to map mods list
			table.insert(MapLoadedMods, uuid);
		end
	end
end

function CreateWorldChooseModBtn_OnClick()

	FrameStack.reset();
	local args = {
		editmode = 3,
		uuid = creatingWorldModInfo and creatingWorldModInfo.defaultMapModUuid,
	};
    getglobal("ModsLib"):SetFrameLevel(2260)
    getglobal("MyModsEditorFrame"):SetFrameLevel(2260)
	if UseNewModsLib then
        args.isnew = true
        args.enterType = 3 
        FrameStack.enterNewFrame("ModsLib", args, OnEditNewMapModFinished)
    else
		FrameStack.enterNewFrame("MyModsEditorFrame", args, OnEditNewMapModFinished);
    end

	--td统计
	-- statisticsGameEvent(507);
	--StatisticsTools:gameEvent("ModEvent", "创建地图时选择点击选择插件按钮");
	
	--[[
	if not AccountManager:getNoviceGuideState("guidechoosemod") then
		AccountManager:setNoviceGuideState("guidechoosemod", true);
		getglobal("CreateWorldRuleFrameChooseModBtnGuide"):Hide();
	end
	]]
	-- getglobal("ChooseModsFrame"):Show();
	-- getglobal("CreateWorldRuleFrame"):Hide();
end

function OnEditNewMapModFinished(leavingframe, userdata)
	Log("OnEditNewMapModFinished");
	if creatingWorldModInfo then

		local duration = 0.3;
		local interval = 0.15;

		if creatingWorldModInfo.componentCount ~= leavingframe.componentCount then

			creatingWorldModInfo.componentCount = leavingframe.componentCount;

			AnimMgr:playBlink("WorldRuleBoxModDesc1", duration, interval);
		end

		if creatingWorldModInfo.modCount ~= leavingframe.modCount then
			
			creatingWorldModInfo.modCount = leavingframe.modCount;

			AnimMgr:playBlink("WorldRuleBoxModDesc2", duration, interval);
		end
	end
	UpdateMapModInfo();
    getglobal("ModsLib"):SetFrameLevel(2200)
    getglobal("MyModsEditorFrame"):SetFrameLevel(2200)
end

function UpdateMapModInfo()
	if creatingWorldModInfo then
		getglobal("WorldRuleBoxModDesc1"):SetText(GetS(4099, creatingWorldModInfo.componentCount));
		getglobal("WorldRuleBoxModDesc2"):SetText(GetS(4100, creatingWorldModInfo.modCount));
	else
		getglobal("WorldRuleBoxModDesc1"):SetText(GetS(4099, 0));
		getglobal("WorldRuleBoxModDesc2"):SetText(GetS(4100, 0));
	end
end

function IsLandformsOptional(type, index)
	if type == 1 then
		return true;
	elseif type == 0 then
		return false;
	elseif type == 4 then
		if index == 3 then		
			return true;
		else
			return false;
		end
	elseif type == 5 then
		--自定义地形, 拥有和"随机"地形一样的地貌选择.
		Log("LLDO: Custom!");
		return true;
	end
end

function SetLandformsOptional(type)
	for i=1, Landforms_Max_Num do
		local landforms = getglobal("WorldRuleBoxLandforms"..i);
		local tick = getglobal("WorldRuleBoxLandforms"..i.."Tick");
		
		if IsLandformsOptional(type, i) then
			-- name:SetTextColor(126, 103, 71);
			landforms:SetClientUserData(0, 0);
			tick:Show();
		else
			-- name:SetTextColor(96, 96, 96);
			landforms:SetClientUserData(0, 1);
			tick:Hide();
		end
	end
end

function SetDefaultRule()
	--µØÍ¼´óÐ¡
	getglobal("WorldRuleBoxMapSizeLongEdit"):Clear();
	getglobal("WorldRuleBoxMapSizeWidthEdit"):Clear();

	--µØÐÎ
	SetWorldTerrain(0, 2);

	--µØÃ² 改成默认平坦地形不需要勾选
	-- for i=1, Landforms_Max_Num do
	-- 	local tick = getglobal("WorldRuleBoxLandforms"..i.."Tick");	
	-- 	if not tick:IsShown() then
	-- 		tick:Show();
	-- 	end
	-- end


	--ÉúÎïÉú³É
	for i=1, 2 do
		local tick = getglobal("WorldRuleBoxMonster"..i.."Tick");	
		if not tick:IsShown() then
			tick:Show();
		end

		SetMonsterStatus(i, true)
	end
end

-----------------------------------------------------------------------LLDO:界面改版新增------------------------------------------------------------------

--1. 地形按钮布局
function CJSJRule_TerrainBtnLayout()
	getglobal("WorldRuleBoxTerrain2DownIcon"):Show();
end

--1. 是否打开平坦地形下拉框
m_bCJSJRuleTerrain2_IsDropFrameShown = false;
function CJSJRule_IsShowTerrainDropFrame(bIsSelectFlat)
	--bIsSelectFlat:是否点击"平坦"按钮
	Log("CJSJRule_IsShowTerrainDropFrame:");

	local dropFrame = getglobal("WorldRuleBoxTerrain2DropFrame");
	local downIcon = getglobal("WorldRuleBoxTerrain2DownIcon");
	local upIcon = getglobal("WorldRuleBoxTerrain2UpIcon");

	if bIsSelectFlat then
		if m_bCJSJRuleTerrain2_IsDropFrameShown then
			--已经打开, 则关闭
			dropFrame:Hide();
			downIcon:Show();
			upIcon:Hide();
			m_bCJSJRuleTerrain2_IsDropFrameShown = false;
		else
			--关闭的, 则打开
			dropFrame:Show();
			downIcon:Hide();
			upIcon:Show();
			m_bCJSJRuleTerrain2_IsDropFrameShown = true;
		end
	else
		--1. 关闭下拉框
		if dropFrame:IsShown() then
			dropFrame:Hide();
			downIcon:Show();
			upIcon:Hide();
			m_bCJSJRuleTerrain2_IsDropFrameShown = false;
		end
	end
end

--3. 下拉框
function WorldRuleBoxTerrain2DropFrame_OnShow()
	Log("WorldRuleBoxTerrain2DropFrame_OnShow:");
	--1. 按钮布局
	WorldRuleBoxTerrain2DropFrameBtnsLayout();

	--2. 隐藏底部文字
	local descObj = getglobal("WorldRuleBoxTerrain2Tips");
	descObj:Hide();
end

function WorldRuleBoxTerrain2DropFrame_OnHide()
	Log("WorldRuleBoxTerrain2DropFrame_OnHide:");
	CJSJRule_IsShowFlatTerrainDesc();
end

--4. 下拉按钮布局
function WorldRuleBoxTerrain2DropFrameBtnsLayout()
	Log("WorldRuleBoxTerrain2DropFrameBtnsLayout:");
	local offsetTop = 40;
	local offsetY = 2;
	local height = 31;
	local y = offsetTop;
	local frameName = "WorldRuleBoxTerrain2DropFrame";
	local btnTextList = {1144, 1145, 1146};

	for i = 1, #btnTextList do
		local btnName = frameName .. "Btn" .. i;
		local btnObj = getglobal(btnName);
		local btnText = GetS(btnTextList[i]);

		getglobal(btnName .. "Name"):SetText(btnText);
		btnObj:SetPoint("top", frameName, "top", 0, y);

		y = y + height + offsetY;
	end
end

--5.. 是否显示底部文字
function CJSJRule_IsShowFlatTerrainDesc()
	Log("CJSJRule_IsShowFlatTerrainDesc:");
	--1. 显示/隐藏底部文字
	local descObj = getglobal("WorldRuleBoxTerrain2Tips");
	local terrainTypeList = {10, 11, 0};
	local terrainType = WorldTerrainType;

	Log("terrainType = " .. terrainType);
	
	descObj:Hide();

	for i = 1, #terrainTypeList do
		if terrainType == terrainTypeList[i] then
			descObj:Show();
		end
	end
end

--6. 下拉框子按钮点击
function CJSJRule_XLKBtnTemplate(id)
	Log("CJSJRule_XLKBtnTemplate: id = " .. id);

	local btnID = id;
	local frameName = "WorldRuleBoxTerrain2DropFrame";
	local frameDescObj = getglobal("WorldRuleBoxTerrain2Tips");
	local terrainTypeList = {10, 11, 0};
	local btnTextList = {1144, 1145, 1146};

	--2. 设置地形类型
	WorldTerrainType = terrainTypeList[btnID];

	--3. 显示底部描述
	local descText = "(" .. GetS(btnTextList[btnID]) .. ")";
	frameDescObj:SetText(descText);
	frameDescObj:Show();

	--4. 处理下拉框
	CJSJRule_IsShowTerrainDropFrame(true);
end

--7. 设置种子按钮状态
local m_CJSJRule_IsSeedBtnSelected = false;
function CJSJRule_SetSeedBtnState(bPushed)
	--bPushed: true/false
	Log("CJSJ_SetSeedBtnState:");
	--CJSJ_SetBtnState("CJSJModelSetBtn4Seed", bPushed);
	m_CJSJRule_IsSeedBtnSelected = bPushed;

	local seedFrame = getglobal("WorldRuleBoxTerrainSeedFrame");
	local name = getglobal("WorldRuleBoxTerrain4Name");
	local check = getglobal("WorldRuleBoxTerrain4Check");

	if bPushed then
		seedFrame:Show();
		name:SetTextColor(254, 249, 209);
		check:Show();
	else
		seedFrame:Hide();
		name:SetTextColor(137, 93, 58);
		check:Hide();
	end
end

--7. 隐藏/显示种子按钮
function CJSJRule_IsShowSeedBtn(bIsShow)
	Log("CJSJRule_IsShowSeedBtn:");

	local allControl = {
		"WorldRuleBoxTerrain4",
		"WorldRuleBoxTerrainSeedFrame",
	};

	for i = 1, #allControl do
		obj = getglobal(allControl[i]);

		if bIsShow then
			if i == 1 then
				obj:Show();
				CJSJRule_SetSeedBtnState(false);
			else
				obj:Hide();
			end
		else
			obj:Hide();
		end
	end
end

function CJSJ_SetBtnState(btnName, bPushed)
	local btn = getglobal(btnName);
	local text = getglobal(btnName .. "Name");
	local normal = getglobal(btnName .. "Normal");
	local pushed = getglobal(btnName .. "Pushed");

	Log("CJSJ_SetBtnState: btnName = " .. btnName);

	if bPushed then
		text:SetTextColor(254, 249, 209);
		normal:Hide();
		pushed:Show();
	else
		text:SetTextColor(137, 93, 58);
		normal:Show();
		pushed:Hide();
	end
end

--地形配置参数--------------------------------------------------------------------------
--初始化
function CreateWorldRuleFrameTerrainReset(onlyCreate, onlyCreateEvt)
	Log("CreateWorldRuleFrameTerrainReset:");
    if not onlyCreate then onlyCreate = false end
    if not onlyCreate or not onlyCreateEvt then
        onlyCreateEvt = nil
    end
  	CreateWorldRule_TerrainParam = {
        onlyCreate = onlyCreate,
        onlyCreateEvt = onlyCreateEvt,
  		curTerrainIndex = 1,
		-- IsUseRandomTerrainSeed = false,
    	FlatTerrainIndex = 1,

    	paramFrames = {
    		"WorldRuleBoxTerrainRandomTerrainParamFrame",		--随机地形
    		"WorldRuleBoxTerrainFlatTerrainParamFrame",			--平坦地形
    		"",													--空岛
    		"WorldRuleBoxTerrainTerrainEditTerrainParamFrame",	--自定义地形
    	},
	};
end

function CreateWorldRule_UpdateTerrainSet(curTerrainIndex)
	Log("CreateWorldRule_UpdateTerrainSet: curTerrainIndex = " .. curTerrainIndex);
	local parentUI = "WorldRuleBoxTerrain";

	CreateWorldRule_TerrainParam.curTerrainIndex = curTerrainIndex;

	--按钮选中状态
    for i = 1, 4 do
    	local btnUI = parentUI .. i;
        local btn = getglobal(btnUI);
        local btnPushedTexture = getglobal(btnUI .. "Check");
        local paramFrameUI = CreateWorldRule_TerrainParam.paramFrames[i];	--参数页面
        
        if curTerrainIndex == i then
            --local desc = getglobal(parentUI .. "TerrainDesc")
            --desc:SetText(GetS(PromptTable[curTerrainIndex]))

            btnPushedTexture:Show()

            if 3 ~= i then
            	getglobal(paramFrameUI):Show();
            end
        else
            btnPushedTexture:Hide()
            if 3 ~= i then
            	getglobal(paramFrameUI):Hide();
            end
        end
    end

    if curTerrainIndex == 1 then
    	--随机地形
    	--种子
	    -- local IsUseSeed = CreateWorldRule_TerrainParam.IsUseRandomTerrainSeed;
	    -- CreateWorldRuleFrameSeedSwitchBtnState(IsUseSeed);
    elseif curTerrainIndex == 2 then
    	--平坦地形
    	local FlatTerrainIndex = CreateWorldRule_TerrainParam.FlatTerrainIndex;
    	CreateWorldRule_FlatTerrainCheckBtnState(FlatTerrainIndex);
    end

    --种子
    local IsUseSeed = CreateWorldRule_TerrainParam.IsUseRandomTerrainSeed;
    print("111:IsUseSeed = ", IsUseSeed);
    CreateWorldRuleFrameSeedSwitchBtnState(IsUseSeed);
end

--种子编辑开关
function CreateWorldRuleFrameSeedSwitchBtn_OnClick()
	local switchName = this:GetName();
	local state = false;
	
	local retState = TemplateSwitchBtn_OnClick(switchName, true);
    if retState == 0 then
        state = false;
    else
        state = true;
    end
	
	CreateWorldRuleFrameSeedSwitchBtnState(state);
end

function CreateWorldRuleFrameSeedSwitchBtnState(bIsOpen)
	Log("CreateWorldRuleFrameSeedSwitchBtnState:");
	local seedFrame = getglobal("WorldRuleBoxTerrainRandomTerrainParamFrameSeedEditFrame");
	local switchName = "CreateWorldFrameParamFrame1RandomTerrainParamFrameSeedSwitch";

	if bIsOpen then
		--使打开
		seedFrame:Show();
		TemplateSwitchBtn_SetState(switchName, 1, true);
	else
		seedFrame:Hide();
		TemplateSwitchBtn_SetState(switchName, 0, true);
	end

	CreateWorldRule_TerrainParam.IsUseRandomTerrainSeed = bIsOpen;
end

--平坦地形勾选按钮状态
function CreateWorldRule_FlatTerrainCheckBtnState(id)
	Log("CreateWorldRule_FlatTerrainCheckBtnState: id = " .. id);

	local FlatTerrainTable = {1144, 1145, 1146,1154};
	local terrainTypeList = {10, 11, 0, 12};

	for i = 1, 4 do
		local btnUI = "WorldRuleBoxTerrainFlatTerrainParamFrameCheckbox" .. i;
		local tick = getglobal(btnUI .. "Tick");
		local name = getglobal(btnUI .. "Name");

		name:SetText(GetS(FlatTerrainTable[i]));

		if i == id then
			tick:Show();
			CreateWorldRule_TerrainParam.FlatTerrainIndex = id;
			WorldTerrainType = terrainTypeList[id];
		else
			tick:Hide();
		end
	end
end

--高级物理开关
function CreateWorldruleAdvancedPhysicsSwitchBtn_OnClick( ... )
	local switchName = this:GetName();
    local state = false;
    local bkg = getglobal(this:GetName().."Bkg");
    local point = getglobal(switchName.."Point");
    
    if point:GetRealLeft() - bkg:GetRealLeft() > 20  then           --先前状态：开
        point:SetPoint("left", this:GetName(), "left", 4, -3);
        state = false;
    else                                --先前状态：关
        point:SetPoint("right", this:GetName(), "right", -6, -3);
        state = true;
    end
    Log("_G.physx_config.enable"..tostring(_G.physx_config.enable))
    _G.physx_config.enable = true
    Log("_G.physx_config.enable111"..tostring(_G.physx_config.enable))
end

--选择雨林玩法
function SetRainForestRule()
	getglobal("WorldRuleBoxMapSizeLongEdit"):Clear();
	getglobal("WorldRuleBoxMapSizeWidthEdit"):Clear();

	SetWorldTerrain(1, 1);

	-- 开发者栏选择游戏模式 点击埋点
	standReportEvent(CreateWorldSID, CreateWorldDevCID, CreateWorldDevOID.ModChos, CreateWorldDevEID.Click)

	for i=1, Landforms_Max_Num do
		local tick = getglobal("WorldRuleBoxLandforms"..i.."Tick");	
		if i < Landforms_Max_Num then
			tick:Hide()
		else
			tick:Show()		
		end
	end

	for i=1, 2 do
		local tick = getglobal("WorldRuleBoxMonster"..i.."Tick");
		if not tick:IsShown() then
			tick:Show();
		end

		SetMonsterStatus(i, true)
	end
end

-----------------------------------------------local变量set，get接口------------------------------------------

function GetCreateWorldRule_TerrainParam()
	return CreateWorldRule_TerrainParam
end

function SetCreateWorldRule_TerrainParam(value)
	CreateWorldRule_TerrainParam = value
end

function GetcreatingWorldModInfo()
	return creatingWorldModInfo
end

function SetcreatingWorldModInfo(value)
	creatingWorldModInfo = value
end

function GetWorldTerrainType()
	return WorldTerrainType
end

function SetWorldTerrainType(value)
	WorldTerrainType = value
end

local monsertChecked = {}
function SetMonsterStatus(id, flg)
	monsertChecked[id] = flg
end

function GetMonsterStatus(id)
	return monsertChecked[id]
end


