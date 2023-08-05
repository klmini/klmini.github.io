CurNewWorldType = -1;   -- 0：冒险 1：创造 4：玩法

local creatingWorldModInfo = nil;
local isLoadedDefaultMod = false;

local CreateWorldParamTable = {
    {StringId=6311, Value=0},  --经典模式的难度值
    {StringId=6312, Value=2},  --极限模式的难度值
    {StringId=6572, Value=6},  --自由模式的难度值
    {StringId=6313, Value=1},  --随机地形
    {StringId=6315, Value=0},  --平坦地形默认值
    {StringId=4544, Value=1},  --空岛地形(LLDO:改成自定义地形, 自定义的地形类型和随机一样都是1)
};
local FlatTerrainTypeList = {10, 11, 0, 12};			--平坦地形参数列表

local FlatTerrainTable = {
    1144,1145,1146,1154
};
local PromptTable = {
    6573,6574,6575,6576,6577,9095,
};

local CreateWorldData

local CreateWorld_IsModifyTerrain = false

local OnlyCreateUserDataIdx = 1

-- 新增创建世界埋点
-- 场景ID
local CreateWorldSID = "402"

-- 栏目ID
local CreateWorldCID = {
    ModSel = "MINI_CREATEWORLD__MODESELECTION_1",
    NorMod = "MINI_CREATEWORLD__NORMALMODE_1",
    AdvenModSet = "MINI_CREATEWORLD__MODESET_1",
    CreateModSet = "MINI_CREATEWORLD__MODESET_2"
}

-- 组件ID
local CreateWorldOID = {
    Default = "-",
    Close = "Close",
    Return = "Return",
    ModChos = "Modechoose",
    StartGame = "Startgame",
    SetDefault = "Default"
}

-- -- eventID   game_open 赋值给 全局变量standReportGameOpenParam 进入游戏会自动上报
local CreateWorldEID = {
    View = "view",
    Click = "click"
}

function OpenCreateWorldFrame(onlyCreate, onlyCreateEvt)
    CloseCreateWorldFrame()

    local createFrame = getglobal("CreateWorldFrame")
    if onlyCreate then
        createFrame:SetClientUserData(OnlyCreateUserDataIdx, 1)
        if "string" == type(onlyCreateEvt) and onlyCreateEvt ~= "" then
            createFrame:SetClientString(onlyCreateEvt)
        end
    end
    createFrame:Show()
end

function CloseCreateWorldFrame()
    local createFrame = getglobal("CreateWorldFrame")
    createFrame:SetClientUserData(OnlyCreateUserDataIdx, 0)
    createFrame:SetClientString("")
    createFrame:Hide()

    ClearTempleteterrainData()
end

function CreateWorldFrameReset(onlyCreate, onlyCreateEvt)
    if not onlyCreate then onlyCreate = false end
    if not onlyCreate or not onlyCreateEvt then
        onlyCreateEvt = nil
    end
   CreateWorldData  = {
        onlyCreate = onlyCreate,
        onlyCreateEvt = onlyCreateEvt,
        CurGameMode=1,      -- 1：冒险，2：创造
        ShowConfig=false,

        SurvivalMode = {
            DifficultyModeIndex=1,
            TerrainModeIndex=4,
            IsUseRandomTerrainSeed=false,
            FlatTerrainIndex=3,
            AdvancedPhysics=true,
        },

        CreateMode = {
            TerrainModeIndex=5,
            IsUseRandomTerrainSeed=false,
            FlatTerrainIndex=1,
            AdvancedPhysics=true,
        },
    };
end

--刷新详细设置参数
function CreateWorldFrameUpdate()
    local curParamFrame

    --模式按钮
    for i=1, 2 do
        local modeBtn = getglobal("CreateWorldFrameModeBtn"..i)
        local checkBtn = getglobal(modeBtn:GetName().."CheckBkg")
        local name = getglobal(modeBtn:GetName().."Name");
        local desc = getglobal(modeBtn:GetName().."Desc");
        local setbtn = getglobal(modeBtn:GetName().."SetBtn");
        local paramFrame = getglobal("CreateWorldFrameParamFrame"..i)

        if i == CreateWorldData.CurGameMode then
            checkBtn:Show()
            name:SetTextColor(255, 109, 37);
            desc:SetTextColor(255, 109, 37);
            setbtn:Show();

            if CreateWorldData.ShowConfig then
                paramFrame:Show()
                curParamFrame = paramFrame

                -- 普通模式 模式设置界面显示、返回显示、开始游戏显示打开
                local CreateWorldTempCID = (i == 1) and CreateWorldCID.AdvenModSet or CreateWorldCID.CreateModSet
                standReportEvent(CreateWorldSID, CreateWorldTempCID, CreateWorldOID.Default, CreateWorldEID.View)
                standReportEvent(CreateWorldSID, CreateWorldTempCID, CreateWorldOID.Return, CreateWorldEID.View)
                standReportEvent(CreateWorldSID, CreateWorldTempCID, CreateWorldOID.StartGame, CreateWorldEID.View)

                ---MiniBase 隐藏冒险和创造模式的设置按钮
                if MiniBaseManager:isMiniBaseGame() then
                    getglobal(paramFrame:GetName().."BigPicSetBtn"):Hide();
                end
            else
                paramFrame:Hide()
            end
        else
            name:SetTextColor(61, 69, 70);
            desc:SetTextColor(61, 69, 70);
            setbtn:Hide();
            checkBtn:Hide()
            paramFrame:Hide()
        end

        Log("CreateWorldFrameUpdate"..i)
    end

    --右边区域
    if CreateWorldData.ShowConfig then
        --初始化参数窗口
        local curDifficultyIndex=-1
        local curTerrainIndex=-1
        local minBtnNum=1
        local maxBtnNum=6
        local docName
        local flatTerrainIndex
        local IsUseSeed, IsRandomTerrain, IsFlatTerrain, IsTerrainEdit, IsFreeDifficultyMode, IsUsePhysx

        if CreateWorldData.CurGameMode == 2 then minBtnNum=4;maxBtnNum=5; end

        --UI数据初始化
        if CreateWorldData.CurGameMode == 1 then
            curDifficultyIndex = CreateWorldData.SurvivalMode.DifficultyModeIndex
            curTerrainIndex = CreateWorldData.SurvivalMode.TerrainModeIndex
            docName = AccountManager:getNickName()..GetS(59)
            IsUseSeed = CreateWorldData.SurvivalMode.IsUseRandomTerrainSeed
            IsUsePhysx = CreateWorldData.SurvivalMode.AdvancedPhysics
            if CreateWorldData.SurvivalMode.DifficultyModeIndex == 3 then
                IsFreeDifficultyMode = true
                getglobal("CreateWorldFrameParamFrame1Btn6"):Show();
            else
                IsFreeDifficultyMode = false
                getglobal("CreateWorldFrameParamFrame1Btn6"):Hide();
            end
            if CreateWorldData.SurvivalMode.TerrainModeIndex == 4 then
                IsRandomTerrain = true
                IsFlatTerrain = false
                IsTerrainEdit = false;
            elseif CreateWorldData.SurvivalMode.TerrainModeIndex == 5 then
                IsRandomTerrain = false;
                IsFlatTerrain = true
                IsTerrainEdit = false;
            elseif CreateWorldData.SurvivalMode.TerrainModeIndex == 6 then
                --LLDO:自定义地形
                IsRandomTerrain = false;
                IsFlatTerrain = false
                IsTerrainEdit = true;
            end
            flatTerrainIndex = CreateWorldData.SurvivalMode.FlatTerrainIndex
        else
            curTerrainIndex = CreateWorldData.CreateMode.TerrainModeIndex
            docName = AccountManager:getNickName()..GetS(60)
            IsUseSeed = CreateWorldData.CreateMode.IsUseRandomTerrainSeed
            IsUsePhysx = CreateWorldData.CreateMode.AdvancedPhysics
            IsFreeDifficultyMode = false
            if CreateWorldData.CreateMode.TerrainModeIndex == 4 then
                IsRandomTerrain = true
                IsFlatTerrain = false
                IsTerrainEdit = false;
            elseif CreateWorldData.CreateMode.TerrainModeIndex == 5 then
                IsRandomTerrain = false
                IsFlatTerrain = true
                IsTerrainEdit = false;
            end
            flatTerrainIndex = CreateWorldData.CreateMode.FlatTerrainIndex
        end

        --按钮
        for i=minBtnNum, maxBtnNum do
            local btn = getglobal(curParamFrame:GetName().."Btn"..i)
            local btnPushedTexture = getglobal(btn:GetName().."Pushed")
            local btnNormalTexture = getglobal(btn:GetName().."Normal")
            local name = getglobal(btn:GetName().."Name")
            
            name:SetText(GetS(CreateWorldParamTable[i].StringId))

            if curDifficultyIndex ~= -1 and i >= 1 and i <= 3 then
                if curDifficultyIndex == i then
                    local desc = getglobal(curParamFrame:GetName().."DifficultyDesc")
                    desc:SetText(GetS(PromptTable[curDifficultyIndex]))

                    btnPushedTexture:Show()
                    btnNormalTexture:Hide()
                else
                    btnPushedTexture:Hide()
                    btnNormalTexture:Show()
                end
            elseif curTerrainIndex ~= -1 and i >=4 and i<=6 then
                if curTerrainIndex == i then
                    local desc = getglobal(curParamFrame:GetName().."TerrainDesc")
                    desc:SetText(GetS(PromptTable[curTerrainIndex]))

                    btnPushedTexture:Show()
                    btnNormalTexture:Hide()
                else
                    btnPushedTexture:Hide()
                    btnNormalTexture:Show()
                end
            end

            if i == 3 then
                --LLDO:高级模式红点显示
                local retTag = getglobal(btn:GetName() .. "RedTag");
                if not AccountManager:getNoviceGuideState("createmapHighMode") then
                    retTag:Show();
                else
                    retTag:Hide();
                end
            end
        end

        --存档名称
        getglobal(curParamFrame:GetName().."NameEdit"):SetDefaultText(docName);

        --随机地形参数
        local randomFrame = getglobal(curParamFrame:GetName().."RandomTerrainParamFrame")
        if IsRandomTerrain  then
            local seedFrame = getglobal(curParamFrame:GetName().."RandomTerrainParamFrameSeedEditFrame")
	        local switchName = getglobal(curParamFrame:GetName().."RandomTerrainParamFrameSeedSwitch")
	
	        if not IsUseSeed  then
		        TemplateSwitchBtn_SetState(switchName:GetName(), 0, true);
                seedFrame:Hide()
	        else
		        TemplateSwitchBtn_SetState(switchName:GetName(), 1, true);
                seedFrame:Show()
	        end
            randomFrame:Show()
        else
            randomFrame:Hide()
        end

        --平坦地形参数        
        local flatFrame = getglobal(curParamFrame:GetName().."FlatTerrainParamFrame")
        if IsFlatTerrain  then
            for i=1,4 do
                local check = getglobal(curParamFrame:GetName().."FlatTerrainParamFrameCheckbox"..i.."Tick")
                local name = getglobal(curParamFrame:GetName().."FlatTerrainParamFrameCheckbox"..i.."Name")
                if i == 4 then 
                    if CreateWorldData.CurGameMode == 2 then 
                        --只有创造模式才有空白地形
                        getglobal(curParamFrame:GetName().."FlatTerrainParamFrameCheckbox"..i):Show()
                    else
                        getglobal(curParamFrame:GetName().."FlatTerrainParamFrameCheckbox"..i):Hide()
                    end 
                else
                    getglobal(curParamFrame:GetName().."FlatTerrainParamFrameCheckbox"..i):Show()
                end 
                name:SetText(GetS(FlatTerrainTable[i]))
                if flatTerrainIndex == i then
                    check:Show()
                else
                    check:Hide()
                end
            end

            flatFrame:Show()
        else
            flatFrame:Hide()
        end

        --LLDO:自定义地形参数(创造模式没有这个)
        local terraineditFrame = getglobal(curParamFrame:GetName().."TerrainEditTerrainParamFrame");
        if IsTerrainEdit then
            terraineditFrame:Show();
        else
            terraineditFrame:Hide();
        end

        --插件（自由模式）
        local freeModeFrame = getglobal(curParamFrame:GetName().."FreeModeParamFrame")
        if IsFreeDifficultyMode  then
            freeModeFrame:Show()
	        if creatingWorldModInfo then
		        getglobal(freeModeFrame:GetName().."Desc1"):SetText(GetS(4099, creatingWorldModInfo.componentCount));
		        getglobal(freeModeFrame:GetName().."Desc2"):SetText(GetS(4100, creatingWorldModInfo.modCount));
	        else
		        getglobal(freeModeFrame:GetName().."Desc1"):SetText(GetS(4099, 0));
		        getglobal(freeModeFrame:GetName().."Desc2"):SetText(GetS(4100, 0));
	        end
        else
            freeModeFrame:Hide()
        end

        --高级物理开关
        local switchName1 = getglobal(curParamFrame:GetName().."AdvancedPhysicsFrameSwitch")
        local switchBkg1 = getglobal(switchName1:GetName().."Bkg")
        local switchPoint1 = getglobal(switchName1:GetName().."Point")
        --[[
        if WorldMgr and WorldMgr.getSurviveGameConfig then
            local config = WorldMgr:getSurviveGameConfig();
            if config then
                if config.physxconfig then
                    config.physxconfig.enable=IsUsePhysx
                end
            end
            Log("pyhsx.config.enable:"..config.physxconfig.enable)
        else
            Log("config not kkkk")
        end]]--
        
        if not IsUsePhysx  then
            switchPoint1:SetPoint("left", switchName1:GetName(), "left", 4, -3);
        else
            switchPoint1:SetPoint("right", switchName1:GetName(), "right", -6, -3);
        end
        _G.physx_config.enable = IsUsePhysx;
        Log("physxconfig.enable:"..tostring(_G.physx_config.enable));

        --关闭/返回按钮--返回
        getglobal("CreateWorldFrameCloseBtn"):SetSize(48, 44);
        getglobal("CreateWorldFrameCloseBtnNormal"):SetTexUV("btn_return");
        getglobal("CreateWorldFrameCloseBtnPushedBG"):SetTexUV("btn_return");
        ---MiniBase 拉起冒险和创造模式返回改成关闭
	    if MiniBaseManager:isMiniBaseGame() then
            getglobal("CreateWorldFrameCloseBtn"):SetSize(36, 46);
            getglobal("CreateWorldFrameCloseBtnNormal"):SetTexUV("btn_close");
            getglobal("CreateWorldFrameCloseBtnPushedBG"):SetTexUV("btn_close");
        end
    else
        --关闭/返回按钮--关闭
        getglobal("CreateWorldFrameCloseBtn"):SetSize(36, 46);
        getglobal("CreateWorldFrameCloseBtnNormal"):SetTexUV("btn_close");
        getglobal("CreateWorldFrameCloseBtnPushedBG"):SetTexUV("btn_close");

        -- 模式选择栏目 关闭按钮显示埋点
        standReportEvent(CreateWorldSID, CreateWorldCID.ModSel, CreateWorldOID.Close, CreateWorldEID.View)

    end
end

function OnCreateWorldChooseModFinished(leavingframe, userdata)
	Log("OnCreateWorldChooseModFinished");
	if creatingWorldModInfo then

		if creatingWorldModInfo.componentCount ~= leavingframe.componentCount then

			creatingWorldModInfo.componentCount = leavingframe.componentCount;
		end

		if creatingWorldModInfo.modCount ~= leavingframe.modCount then
			
			creatingWorldModInfo.modCount = leavingframe.modCount;

		end
	end
    CreateWorldFrameUpdate()
    getglobal("ModsLib"):SetFrameLevel(2200)
    getglobal("MyModsEditorFrame"):SetFrameLevel(2200)
end

--MiniBase创建冒险模式
function CJSJ_CreateSurvival()
	Log("CJSJ_CreateSurvival:");
    if ClientCurGame and ClientCurGame:getName() == "MainMenuStage" then
        UIFrameMgr:hideAllFrame();
        CreateWorldFrameReset()
        OpenCreateWorldFrame()        
        --拉起界面
        if not CreateWorldData then CreateWorldData = {} end
        CreateWorldData.CurGameMode = 1; -- 1. 冒险 2.创造
        CurNewWorldType = 0;
        CreateWorldData.ShowConfig = true;
        CreateWorldFrameUpdate();
        ---MiniPlus 拉起冒险或面回调
        if MiniBaseManager:isMiniBaseGame() then
            if CreateWorldData.CurGameMode == 1 then
                SandboxLua.eventDispatcher:Emit(nil, "MiniBase_NewAdventureGame",  SandboxContext():SetData_Number("code", 0))
                getglobal("CreateWorldFrameTitleName"):SetText(GetS(3005));
            else
                SandboxLua.eventDispatcher:Emit(nil, "MiniBase_NewCreatorGame",  SandboxContext():SetData_Number("code", 0))
                getglobal("CreateWorldFrameTitleName"):SetText(GetS(3006));
            end
        end
    end
end

--MiniBase创建创造者模式
function CJSJ_CreateCreator()
	Log("CJSJ_CreateSurvival:");
    if ClientCurGame and ClientCurGame:getName() == "MainMenuStage" then
        UIFrameMgr:hideAllFrame();
        CreateWorldFrameReset()
        OpenCreateWorldFrame()        
        --拉起界面
        if not CreateWorldData then CreateWorldData = {} end
        CreateWorldData.CurGameMode = 2; -- 1. 冒险 2.创造
        CurNewWorldType = 0;
        CreateWorldData.ShowConfig = true;
        CreateWorldFrameUpdate();
        ---MiniPlus 拉起冒险或面回调
        if MiniBaseManager:isMiniBaseGame() then
            if CreateWorldData.CurGameMode == 1 then
                SandboxLua.eventDispatcher:Emit(nil, "MiniBase_NewAdventureGame",  SandboxContext():SetData_Number("code", 0))
                getglobal("CreateWorldFrameTitleName"):SetText(GetS(3005));
            else
                SandboxLua.eventDispatcher:Emit(nil, "MiniBase_NewCreatorGame",  SandboxContext():SetData_Number("code", 0))
                getglobal("CreateWorldFrameTitleName"):SetText(GetS(3006));
            end
        end
    end
end

--MiniBase创建开发者模式
function CJSJ_CreateDeveloper()
    if ClientCurGame and ClientCurGame:getName() == "MainMenuStage" then
        UIFrameMgr:hideAllFrame();
        ResetCreateWorldMods();
        if not CreateWorldData then CreateWorldData = {} end
        CreateWorldData.onlyCreate = false
        CreateWorldData.onlyCreateEvt = false
        CreateWorldData.ShowConfig=false
        CreateWorldFrameAdvancedSetBtn_OnClick()
    end
end

function CJSJ_AB_singleP2P()
    --创建新世界还原进单机的路径
    return false--GetInst("mainDataMgr"):AB_singleP2P()
end

--创建世界
function CJSJ_CheateWorld()
	Log("CJSJ_CheateWorld:");

    if not CreateWorldData.onlyCreate then
        local teamupSer = GetInst("TeamupService")
        if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
            ShowGameTips(GetS(26045))
            return
        end
    end

    local worldType, worldName, terraitType, seedName
    local needCopyMod = false

	if 1 == CreateWorldData.CurGameMode then    --冒险模式
        worldType = CreateWorldParamTable[CreateWorldData.SurvivalMode.DifficultyModeIndex].Value
        terraitType = CreateWorldParamTable[CreateWorldData.SurvivalMode.TerrainModeIndex].Value
        
        -- 自由模式
        if CreateWorldData.SurvivalMode.DifficultyModeIndex == 3 then
	        local modUUids = GetSelectedModTable();
	        Log("modUUids = ");

	        for i=1, #modUUids do
		        local uuid = modUUids[i];

		        ModMgr:markForAddMod(uuid);

		        -- statisticsGameEvent(506, '%lls', modUUids[i], '%d', 3);
	        end

	        -- if #modUUids > 0 then
		        -- statisticsGameEvent(508);
	        -- end
        end

        --平坦地形，且选择了平坦地的具体类型
        if terraitType == 0 and CreateWorldData.SurvivalMode.FlatTerrainIndex ~= -1 then
            terraitType = FlatTerrainTypeList[CreateWorldData.SurvivalMode.FlatTerrainIndex]
        end

        --地图名字
        local edit = getglobal("CreateWorldFrameParamFrame1NameEdit");
        worldName = edit:GetText()
	    if CheckFilterString(worldName) then return end
	    if string.len(worldName) == 0 then
            worldName = AccountManager:getNickName()..GetS(59)
	    end

        --种子名字
        if CreateWorldData.SurvivalMode.IsUseRandomTerrainSeed then
            seedName = getglobal("CreateWorldFrameParamFrame1RandomTerrainParamFrameSeedEditFrameEdit"):GetText()
        else
            seedName = ""
        end

    elseif 2 == CreateWorldData.CurGameMode then    --创造模式
        worldType = 1
        terraitType = CreateWorldParamTable[CreateWorldData.CreateMode.TerrainModeIndex].Value

        --平坦地形，且选择了平坦地的具体类型
        if terraitType == 0 and CreateWorldData.CreateMode.FlatTerrainIndex ~= -1 then
            terraitType = FlatTerrainTypeList[CreateWorldData.CreateMode.FlatTerrainIndex]
        end

        --地图名字
        local edit = getglobal("CreateWorldFrameParamFrame2NameEdit");
        worldName = edit:GetText();
	    if CheckFilterString(worldName) then return end
	    if string.len(worldName) == 0 then
            worldName = AccountManager:getNickName()..GetS(60)
	    end

        --种子名字
        if CreateWorldData.CreateMode.IsUseRandomTerrainSeed then
            seedName = getglobal("CreateWorldFrameParamFrame2RandomTerrainParamFrameSeedEditFrameEdit"):GetText()
        else
            seedName = ""
        end
    end

    
    -- 自由模式，复制系统默认mod
    if worldType == 6 and getglobal("CreateWorldFrameParamFrame1FreeModeParamFrameCheckboxAddDefaultModTick"):IsShown() then
        needCopyMod = true
    end
    
    print("requestCreateWorld param: ", worldType, worldName, terraitType, seedName, AccountManager:getRoleModel())

	--创造新世界
    if CreateWorldData.onlyCreate then
        local worldid = AccountManager:requestCreateWorldNotEnter(worldType, worldName, terraitType, seedName, AccountManager:getRoleModel(), 0,0,0,0, needCopyMod)
        if worldid and worldid > 0 then
            CloseCreateWorldFrame()
            if CreateMapGuideStep == 4 then
                -- statisticsGameEvent(901, '%s', "NoviceCreateMap","%d",GuideLobby,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
                CreateMapGuideStep = 0;
            end

            if needCopyMod then
                ModMgr:copyMods2Map(ModMgr:getSurvivalMapDefaultModUUID(), worldid, 0);
            end
            
            if CreateWorldData.onlyCreateEvt then
                LuaGameEventTb.event(CreateWorldData.onlyCreateEvt,{worldid=worldid})
            end
        end
    else
        local success = false
        if CJSJ_AB_singleP2P() and 1 == CreateWorldData.CurGameMode then    --冒险模式
            local worldid = AccountManager:requestCreateWorldNotEnter(worldType, worldName, terraitType, seedName, AccountManager:getRoleModel(), 0,0,0,0, needCopyMod)
            if worldid and worldid > 0 then
                GetInst("lobbyInterface"):CreateP2PSingleRoom(worldid)
                success = true
            end
        else
            success = AccountManager:requestCreateWorld(worldType, worldName, terraitType, seedName, AccountManager:getRoleModel(), 0,0,0,0, needCopyMod)
        end
            
        if success then
            CloseCreateWorldFrame()
            ShowLoadingFrame();
            if not AccountManager:getNoviceGuideState("createworld") then
                AccountManager:setNoviceGuideState("createworld", true);
            end
            StatisticsWorldCreationEvent(worldType);
            -- statisticsGameEvent(8003,"%d",worldType);
            -- statisticsGameEvent(8006,"%d",worldType);
            if CreateMapGuideStep == 4 then
                -- statisticsGameEvent(901, '%s', "NoviceCreateMap","%d",GuideLobby,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
                CreateMapGuideStep = 0;
            end
            GetInst("NoviceTaskInterface"):SubmitTaskFinish(4006,1)
        end
    end
end

--1. 打开开发者模式
function CreateWorldFrameAdvancedSetBtn_OnClick()
    local switch = UGCGetInst("UGCRemoteConfig"):GetCreateWolrdNewModelSwitch()
    if not switch then
        CurNewWorldType = 4;
        
        GetInst("UIManager"):Close("createWorldTemplete")
        local nickName = ReplaceFilterString(AccountManager:getNickName());
        getglobal("WorldRuleBoxMapNameEdit"):SetDefaultText(nickName..GetS(674));
        UpdateMapModInfo()
        
        OpenCreateWorldRuleFrame(CreateWorldData.onlyCreate, CreateWorldData.onlyCreateEvt, false)
    else
        CreateWorldTabBtnTemplate_OnClick(2)
    end
end

-- 打开原开发者模式
function CreateWorldFrameAdvancedSetBtn_OnClick_New()
    CurNewWorldType = 4;
    
    GetInst("UIManager"):Close("createWorldTemplete")
	local nickName = ReplaceFilterString(AccountManager:getNickName());
    getglobal("WorldRuleBoxMapNameEdit"):SetDefaultText(nickName..GetS(674));
    UpdateMapModInfo()
    
    OpenCreateWorldRuleFrame(CreateWorldData.onlyCreate, CreateWorldData.onlyCreateEvt, false)
    
    GetCreateWorldData().UgcEnterOldRule = true
    getglobal("CreateWorldRuleFrameTitleName"):SetText(GetS(300402));
    getglobal("CreateWorldRuleFrameCloseBtn"):SetSize(48, 44);
    getglobal("CreateWorldRuleFrameCloseBtnNormal"):SetTexUV("btn_return");
    getglobal("CreateWorldRuleFrameCloseBtnPushedBG"):SetTexUV("btn_return");
end

--1. 打开高级开发者模式
function CreateWorldFrameUGCAdvancedSetBtn_OnClick()
    CurNewWorldType = 4;

	local nickName = ReplaceFilterString(AccountManager:getNickName());
    getglobal("WorldRuleBoxMapNameEdit"):SetDefaultText(nickName..GetS(674));
    UpdateMapModInfo()

    GetInst("UGCCommon"):UGCStandReportEvent("402", "MINI_CREATEWORLD_EXPERTCREATE", "ExpertCreateTag", "click")

    OpenCreateWorldRuleFrame(CreateWorldData.onlyCreate, CreateWorldData.onlyCreateEvt, true)

    getglobal("CreateWorldRuleFrameTitleName"):SetText(GetS(3014));

    -- 添加模版选择界面逻辑
    GetInst("UIManager"):Open("createWorldTemplete")
end

--1. 打开普通模式
function CreateWorldRuleFrameNormalSetBtn_OnClick()
    CurNewWorldType = 0;
    CloseCreateWorldRuleFrame()

    -- 普通模式栏目 显示埋点
    standReportEvent(CreateWorldSID, CreateWorldCID.NorMod, CreateWorldOID.Default, CreateWorldEID.View)

    -- 普通模式栏目 开始游戏按钮显示埋点
    standReportEvent(CreateWorldSID, CreateWorldCID.NorMod, CreateWorldOID.StartGame, CreateWorldEID.View)
end

function CreateWorld_OnLoad()
    if ClientMgr:getApiId() ~= 999 then
        getglobal("CreateWorldFrameParamFrame1AdvancedPhysicsFrame"):Hide()
        getglobal("CreateWorldFrameParamFrame2AdvancedPhysicsFrame"):Hide()
    end

    CreateWorldFrameReset();
    CreateWorldFrameUpdate();

    --模式切换大按钮
    local modBtnInfo = {
        {nameID = 3005, descID = 461, icon = "ui/mobile/texture2/bigtex/img_play_adv.png", }, --冒险按钮
        {nameID = 3006, descID = 462, icon = "ui/mobile/texture2/bigtex/img_play_create.png"}, --创造按钮
    };

    for i = 1, 2 do
        local priBtnName = "CreateWorldFrameModeBtn";
        
        getglobal(priBtnName .. i .. "Name"):SetText(GetS(modBtnInfo[i].nameID));
        getglobal(priBtnName .. i .. "Desc"):SetText(GetS(modBtnInfo[i].descID));
        getglobal(priBtnName .. i .. "Icon"):SetTexture(modBtnInfo[i].icon);
    end

    --大图片
    for i = 1, 2 do
        local btnUI = "CreateWorldFrameParamFrame" .. i .. "BigPic";
        getglobal(btnUI .. "Name"):SetText(GetS(modBtnInfo[i].nameID));
        getglobal(btnUI .. "Desc"):SetText(GetS(modBtnInfo[i].descID));
        getglobal(btnUI .. "Icon"):SetTexture(modBtnInfo[i].icon);
        -- getglobal(btnUI .. "SetBtn"):Hide();
    end

    --关闭按钮事件
    UITemplateBaseFuncMgr:registerFunc("CreateWorldFrameCloseBtn", CreateWorldFrameBackBtn_OnClick, "创建地图关闭按钮");
    --标题
    getglobal("CreateWorldFrameTitleName"):SetText(GetS(3014));
    getglobal("CreateWorldFrameParamFrame1FreeModeParamFrameTipDesc"):SetText(GetS(9010), 61,69,70)
end

--顶部tab按钮
local m_CreateWorldTabBtnInfo = {
    normalColor = {186, 210, 210},
    checkedColor = {76, 76, 76},
	{nameID = 6308, uiName="CreateWorldFrameNormalSetBtn", 	OnClick = CreateWorldRuleFrameNormalSetBtn_OnClick},  --普通模式
	{nameID = 6303, uiName="CreateWorldFrameAdvancedSet", 	OnClick = CreateWorldFrameAdvancedSetBtn_OnClick},     --开发者模式
    {nameID = 300361, uiName="CreateWorldFrameUGCAdvancedSet", 	OnClick = CreateWorldFrameUGCAdvancedSetBtn_OnClick}, --高级开发者模式
};

--tab按钮点击
function CreateWorldTabBtnTemplate_OnClick(id)
    if id then
        id = id;
    else
        id = this:GetClientID();
    end

    local inputId = id
    local switch = UGCGetInst("UGCRemoteConfig"):GetCreateWolrdNewModelSwitch()
    if switch then
        if id == 2 then
            id = 3
        end
    end

    print("CreateWorldTabBtnTemplate_OnClick, id = ", id);

    --切换选中状态
    TemplateTabBtn2_SetState(m_CreateWorldTabBtnInfo, id);

    if id == 0 then return; end

    --点击事件
    if m_CreateWorldTabBtnInfo[id] and m_CreateWorldTabBtnInfo[id].OnClick then
        m_CreateWorldTabBtnInfo[id].OnClick();
    end
end

--模式按钮点击, 切换'冒险'/‘创造
function CreateWorldModeSelectBtnTemplate_OnClick()
    local id = this:GetClientID();

    if id > 0 then
        print("id = ", id);

        -- 普通栏选择游戏模式 点击埋点
        standReportEvent(CreateWorldSID, CreateWorldCID.NorMod, CreateWorldOID.ModChos, CreateWorldEID.Click)

        CreateWorldData.CurGameMode = id; -- 1. 冒险 2.创造
        CurNewWorldType = 0;
        CreateWorldData.ShowConfig = false;
        CreateWorldFrameUpdate();
    end
end

--打开/关闭设置页面
function CreateWorldModeSelectBtnTemplateSetBtn_OnClick()
    local btnname = this:GetName();

    if btnname then
        if string.find(btnname, "CreateWorldFrameModeBtn") then
            --打开
            CreateWorldFrameShowConfig(true);
        else
            --关闭
            CreateWorldFrameShowConfig(false);
        end
    end
end

function CreateWorldFrameShowConfig(shown)
    CreateWorldData.ShowConfig = shown
    CreateWorldFrameUpdate()
end

function CreateWorld_OnShow()
    --MiniBase隐藏创建界面选项卡
    if MiniBaseManager:isMiniBaseGame() then
        getglobal("CreateWorldFrameNormalSetBtn"):Hide();
        getglobal("CreateWorldFrameAdvancedSet"):Hide();
        getglobal("CreateWorldFrameUGCAdvancedSet"):Hide();
    end
    getglobal("CreateWorldRuleFrameTitleName"):SetText(GetS(3014));
    CreateWorld_IsModifyTerrain = false 
    isLoadedDefaultMod = false;

    local createFrame = getglobal("CreateWorldFrame")
    CreateWorldFrameReset(createFrame:GetClientUserData(OnlyCreateUserDataIdx) == 1, createFrame:GetClientString());
    createFrame:SetClientUserData(OnlyCreateUserDataIdx, 0)
    createFrame:SetClientString("")

    local startBtnTxt = getglobal("CreateWorldFrameStartBtnText")
    if startBtnTxt then
        startBtnTxt:SetText(CreateWorldData.onlyCreate and GetS(381) or GetS(4900))
    end

    local tick = getglobal("CreateWorldFrameParamFrame1FreeModeParamFrameCheckboxAddDefaultModTick");
	if not tick:IsShown() then
		tick:Show();
	end

    --初始化tab按钮状态
    CreateWorldTabBtnTemplate_OnClick(0);
	press_btn("CreateWorldFrameNormalSetBtn");

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
    else
        creatingWorldModInfo.componentCount = 0;
		creatingWorldModInfo.modCount = 0;
	end
    
    CreateWorldFrameUpdate()

    -- 创建高级模式开关
    if ns_version and ns_version.showUGCSelector and check_apiid_ver_conditions(ns_version.showUGCSelector, false) then
    	getglobal("CreateWorldFrameUGCAdvancedSet"):Show()
    else
        getglobal("CreateWorldFrameUGCAdvancedSet"):Hide()
    end

    local switch = UGCGetInst("UGCRemoteConfig"):GetCreateWolrdNewModelSwitch()
    if switch then
        getglobal("CreateWorldFrameAdvancedSet"):Hide()
        getglobal("CreateWorldFrameUGCAdvancedSet"):SetAnchorOffset(0, 20)
    else
        getglobal("CreateWorldFrameAdvancedSet"):Show()
        getglobal("CreateWorldFrameUGCAdvancedSet"):SetAnchorOffset(0, 100)
    end

    -- 模式选择栏目 显示埋点
    standReportEvent(CreateWorldSID, CreateWorldCID.ModSel, CreateWorldOID.Default, CreateWorldEID.View)
end

function CreateWorld_OnHide()
    local tips = getglobal("RegulationsTipsFrame");
    if tips:IsShown() then
        tips:Hide();
    end
end

function CreateWorldFrameTipFrame_OnClick()
    CreateWorldFrameTipBtn_OnClick()
end

function CreateWorldFrameTipBtn_OnClick()
    local tip = getglobal("CreateWorldFrameParamFrame1FreeModeParamFrameTipFrame");
    if tip:IsShown() then
        tip:Hide()
    else
        tip:Show()
    end
end

function CreateWorldFrameTipDesc_OnMouseEnter()
    local tip = getglobal("CreateWorldFrameParamFrame1FreeModeParamFrameTipFrame")
    tip:Show()
end

function CreateWorldFrameTipDesc_OnMouseLeave()
    local tip = getglobal("CreateWorldFrameParamFrame1FreeModeParamFrameTipFrame")
    tip:Hide()
end

function CreateWorldFrameTipDesc_MouseDownUpdate()
    local tip = getglobal("CreateWorldFrameParamFrame1FreeModeParamFrameTipFrame")
    tip:Show()
end

function CreateWorldFrameTipDesc_OnMouseUp()
    local tip = getglobal("CreateWorldFrameParamFrame1FreeModeParamFrameTipFrame")
    tip:Hide()
end

function CJSJ_BtnTemplate_OnClick()
    local btnID = this:GetClientID()

    if btnID == 3 then
        --LLDO:高级模式, 红点
        if not AccountManager:getNoviceGuideState("createmapHighMode") then
            AccountManager:setNoviceGuideState("createmapHighMode", true);
        end
    end

    if CreateWorldData.CurGameMode == 1 then
        if btnID >= 1 and btnID <= 3 then
            --自定义地形
            if CreateWorldData.SurvivalMode.DifficultyModeIndex == 3 and btnID ~= 3 then
                --从高级模式, 切换到别的模式, 地形初始化为随机
                CreateWorldData.SurvivalMode.TerrainModeIndex = 4;
            end

            CreateWorldData.SurvivalMode.DifficultyModeIndex = btnID

            -- 加载系统默认插件
            if btnID == 3 and isLoadedDefaultMod == false then
                
                isLoadedDefaultMod = true
            end
        end
        if btnID >= 4 and btnID <= 6 then
            CreateWorldData.SurvivalMode.TerrainModeIndex = btnID
        end
    else
        if btnID >= 4 and btnID <= 6 then
            CreateWorldData.CreateMode.TerrainModeIndex = btnID
        end
    end
    CreateWorldFrameUpdate()
end

function CreateWorldFrameSwitchBtn_OnClick()
	local switchName = this:GetName();
	local state = false;
    
    --切换开关状态
    local retState = TemplateSwitchBtn_OnClick(switchName, true);
    if retState == 0 then
        state = false;
    else
        state = true;
    end

    if CreateWorldData.CurGameMode == 1 then
        CreateWorldData.SurvivalMode.IsUseRandomTerrainSeed = state
    else
        CreateWorldData.CreateMode.IsUseRandomTerrainSeed = state
    end
    CreateWorldFrameUpdate()
end

function CreateWorldFrameCheckBox_OnClick()
    local btnID = this:GetClientID()
	local btnName = this:GetName();
	local tick = getglobal(this:GetName().."Tick");
    local value

    if CreateWorldData.CurGameMode == 1 then
        if btnID == CreateWorldData.SurvivalMode.FlatTerrainIndex then
            return
        end
    else
        if btnID == CreateWorldData.CreateMode.FlatTerrainIndex then
            return
        end
    end

	if tick:IsShown() then
		tick:Hide();
        value = false
	else
		tick:Show();
        value = true
	end

    if CreateWorldData.CurGameMode == 1 then
        CreateWorldData.SurvivalMode.FlatTerrainIndex = btnID
    else
        CreateWorldData.CreateMode.FlatTerrainIndex = btnID
    end
    CreateWorldFrameUpdate()
end

function CreateWorldFrameBackBtn_OnClick()
	--MiniBase触发退出游戏回到APP
	SandboxLua.eventDispatcher:Emit(nil, "MiniBase_LeaveGame",  SandboxContext():SetData_Number("code", 0))
    if CreateWorldData.ShowConfig then
        -- 返回
        CreateWorldFrameShowConfig(false);

        -- 普通模式设置 返回按钮点击埋点
        local CreateWorldTempCID = (CreateWorldData.CurGameMode == 1) and CreateWorldCID.AdvenModSet or CreateWorldCID.CreateModSet
        standReportEvent(CreateWorldSID, CreateWorldTempCID, CreateWorldOID.Return, CreateWorldEID.Click)
    else
        if CreateWorldData.onlyCreate then
            CloseCreateWorldFrame()
        else
            -- 关闭
            getglobal("BackgroundFrame"):Hide();
            CloseCreateWorldFrame()
            if g_lobbyShowParam then
                EnterMainMenuInfo.EnterWorldId = nil;
				EnterMainMenuInfo.MainFilter = nil;
				EnterMainMenuInfo.SubFilter = nil;
				EnterMainMenuInfo.NotRefreshSetting = nil;
				EnterMainMenuInfo.MaterialOpen = nil;
				EnterMainMenuInfo.MapDetailOpen = nil;
                ShowLobby({notRefresh = true, selectOwid = g_lobbyShowParam.EnterWorldId, mapDetailOpen = g_lobbyShowParam.MapDetailOpen});
            end
            -- 模式选择栏目 关闭按钮点击埋点
            standReportEvent(CreateWorldSID, CreateWorldCID.ModSel, CreateWorldOID.Close, CreateWorldEID.Click)
        end
    end
end

function CreateWorldChooseModBtn2_OnClick()
	FrameStack.reset();
	local args = {
		editmode = 3,
		uuid = creatingWorldModInfo.defaultMapModUuid,
	};
    getglobal("ModsLib"):SetFrameLevel(2260)
    getglobal("MyModsEditorFrame"):SetFrameLevel(2260)
    --MiniBase隐藏创建界面选项卡
    if MiniBaseManager:isMiniBaseGame() then
        getglobal("CreateWorldFrameNormalSetBtn"):Hide();
        getglobal("CreateWorldFrameAdvancedSet"):Hide();
    end
    if UseNewModsLib then
        args.isnew = true
        args.enterType = 3 
        FrameStack.enterNewFrame("ModsLib", args, OnCreateWorldChooseModFinished)
    else
        FrameStack.enterNewFrame("MyModsEditorFrame", args, OnCreateWorldChooseModFinished);
    end

	--td统计
	-- statisticsGameEvent(507);
end

----------------------------------------------------------------------------------------------
-- 迷你世界创作用户引流需求 by wuyuwang

function MinieduRemind_IsIgnoreChanel(list)
    if not list or type(list) ~="table" then 
        return true
    end 
    
	local apiId = ClientMgr:getApiId()
	for k,v in pairs(list) do
		if v == apiId then
			return false
		end
	end
	return true
end

function MinieduRemind_IsOfftime(rtime)
    if not rtime or type(rtime) ~= "number" then 
        return false
    end 
    
    local code, login_check_form, off_time = MinieduRemind_GetOfftime()
    if code == ErrorCode.OK then
        if off_time and off_time > 0 then
            local curTime = AccountManager:getSvrTime() or os.time()
            local tb = os.date("*t", curTime)
            local curT = tonumber(tb.hour) * 3600 + tonumber(tb.min) * 60 + tonumber(tb.sec)
            
            local last_on_time = off_time - curT
            if last_on_time < rtime * 60 then
                return true
            end
        end
    end
    
    return false
end


function MinieduRemind_GetOfftime ()
    local off_time = nil
    local allow_login_flag = true  -- 默认允许登录
    local allow_login_time_flag = true -- 默认时段允许登录
    local ApiID = LuaInterface:getApiId()
    local login_check_form = {
        is_channel_realname_pass = 0,
        channel_isrealname = 0,
        channel_age = 0,
        is_realname_conf = 1,
        is_realname_pass = 0,
        tips = (ns_version and ns_version.limit_rule_login and ns_version.limit_rule_login.tips_msg) or '亲爱的冒险家，根据国家游戏防沉迷规定，18岁以下的未成年人仅能在法定节假日和每周五、周六、周日20:00 ~ 21:00玩游戏。',
        is_channel_pass = 1,
    }
    
    local get_week_day = function (wday)
        if wday then
            if 7 == wday then
                return 6
            elseif 6 == wday then
                return 5
            elseif 5 == wday then
                return 4
            elseif 4 == wday then
                return 3
            elseif 3 == wday then
                return 2
            elseif 2 == wday then
                return 1
            elseif 1 == wday then
                return 7
            end
        end
        
        return 0
    end
    
    local code, info = AccountManager:realname_get_age()
	--拿不到年龄 就返回不能使用
	if code ~= ErrorCode.OK then
		return false
	end

	local age = 0
	if info.status == 'authed' then
		age = info.age or 1
	elseif info.status == 'not_auth_yet' then
		--没实名
		return false
	end

    if ns_version and ns_version.limit_rule_login_open and 1 == ns_version.limit_rule_login_open then
        if ns_version.limit_rule_login and ns_version.limit_rule_login.limit_rule then
            local curTime = AccountManager:getSvrTime() or os.time()
            local tb = os.date("*t", curTime)
            local wday = get_week_day(tonumber(tb.wday)) -- 今天周几
            local cdate = os.date("%Y-%m-%d",curTime) -- 今天几号
            local curT = tonumber(tb.hour) * 3600 + tonumber(tb.min) * 60 + tonumber(tb.sec)

            local limit_rule_list = ns_version.limit_rule_login.limit_rule
            for irule = 1,#limit_rule_list do
                local login_min_age = limit_rule_list[irule]['login_min_age_'..ApiID]
                if login_min_age then
                    if age <= login_min_age then
                        login_check_form.tips = limit_rule_list[irule]['login_min_age_'..ApiID..'_tips'] or '亲爱的冒险家，根据国家法律规定，14岁以下未成年人玩游戏需经家长同意，祝开心生活，健康成长。'
                        return ErrorCode.FAILED, login_check_form
                    end
                end

                if age >= limit_rule_list[irule].age.min and age <= limit_rule_list[irule].age.max then 
                    allow_login_flag = false
                    allow_login_time_flag = false
                    -- 命中防沉迷年龄，先判断日期，再判断每日时间点
                    for iallow_week_day = 1, #limit_rule_list[irule].allow_week_day do
                        if wday == limit_rule_list[irule].allow_week_day[iallow_week_day] then
                            allow_login_flag = true -- 本周的今天允许登录
                            break
                        end
                    end
                    for iallow_day = 1, #limit_rule_list[irule].allow_day do
                        if limit_rule_list[irule].allow_day[iallow_day] == cdate then
                            -- 指定日期允许登录
                            allow_login_flag = true
                            break
                        end
                    end

                    for inot_allow_day = 1, #limit_rule_list[irule].not_allow_day do
                        if limit_rule_list[irule].not_allow_day[inot_allow_day] == cdate then
                            -- 指定日期不允许登录
                            allow_login_flag = false
                            break
                        end
                    end

                    if true == allow_login_flag then
                        for iallow_time = 1, #limit_rule_list[irule].allow_time do
                            local allow_time_list = limit_rule_list[irule].allow_time[iallow_time]
                            local minT = string.sub(allow_time_list.min,1,2)*3600 + string.sub(allow_time_list.min,4,5)*60
                            local maxT = string.sub(allow_time_list.max,1,2)*3600 + string.sub(allow_time_list.max,4,5)*60
                            if (curT >= minT)  and (curT <= maxT) then
                                allow_login_time_flag = true
                                off_time = maxT
                            end
                        end
                    end

                    break -- 命中第一个年龄段的就跳出循环判断
                else
                    allow_login_flag = true
                    allow_login_time_flag = true
                end
            end
        end
        
        if allow_login_flag == true and allow_login_time_flag == true then
            login_check_form.is_realname_pass = 0
            login_check_form.is_channel_realname_pass = 1
            return ErrorCode.OK,login_check_form,off_time
        else
            return ErrorCode.FAILED, login_check_form
        end
    else
        login_check_form.is_realname_pass = 1
        return ErrorCode.OK, login_check_form, off_time
    end
end

function MinieduRemind_OnStartClick(enterGameCb)
    local goMinieduCb = function (linksData)
        local url = linksData.link_phone
        
        --是否PC端
        if ClientMgr.isPC and ClientMgr:isPC() then
            url = linksData.link_windows
        end
        
        open_http_link(url)
    end
    
    local isRemindTime = false
    local rtime = 0
    local msg = ""
    local linksData = nil
    if ns_version and ns_version.miniedu_remindcfg then
        local isOpenWindow = ns_version.miniedu_remindcfg.openwindow == 1
        rtime = ns_version.miniedu_remindcfg.remain_time
		msg = ns_version.miniedu_remindcfg.msg_content
        linksData = ns_version.miniedu_remindcfg.links_data
        
        if isOpenWindow then 
            local isIgnoreChannel = MinieduRemind_IsIgnoreChanel(ns_version.miniedu_remindcfg.ignore_channel)
            if isIgnoreChannel then 
                isRemindTime = MinieduRemind_IsOfftime(rtime)
            end
        end
	end
    
    local gameMode = 0
    if CreateWorldData.CurGameMode == 2 then 
        gameMode = 1
    elseif CurNewWorldType == 4 then 
        gameMode = 2
    end 
    
    local isRemindgameMode = gameMode == 1 or gameMode == 2
    if isRemindgameMode and isRemindTime then 
        MessageBox(66, msg, 
            function (btn)
                if btn == 'left' then
                    if enterGameCb then 
                        enterGameCb()
                    end
                    
                    standReportEvent("402", "MINI_CREATEWORLD_CREATIVEUSERPOP_1", " Stay", "click", {standby1=tostring(gameMode)})
                else 
                    goMinieduCb(linksData)
                    
                    standReportEvent("402", "MINI_CREATEWORLD_CREATIVEUSERPOP_1", "Ok", "click", {standby1=tostring(gameMode)})
                end 
            end
        )
        
        standReportEvent("402", "MINI_CREATEWORLD_CREATIVEUSERPOP_1", "Pop", "view", {standby1=tostring(gameMode)})
        standReportEvent("402", "MINI_CREATEWORLD_CREATIVEUSERPOP_1", "Ok", "view", {standby1=tostring(gameMode)})
        standReportEvent("402", "MINI_CREATEWORLD_CREATIVEUSERPOP_1", " Stay", "view", {standby1=tostring(gameMode)})
    else 
        if enterGameCb then 
            enterGameCb()
        end
    end
end
---------------------------------------------------------------------------------------------

function CreateWorldFrameStartBtn_OnClick()   
    local enterGameCb = function ()
    if CreateMapGuideStep == 3 then
        CreateMapGuideStep = 4;
        CreateMapGuide();
    end

    local worldType = CreateWorldData.CurGameMode
    local cardid = CreateWorldCID.NorMod
    if 1 == CreateWorldData.CurGameMode then    --冒险模式
        worldType = CreateWorldParamTable[CreateWorldData.SurvivalMode.DifficultyModeIndex].Value
        if IsShowFguiStartMain() then
            standReportEvent("15", "XSELECT_GAME", "XCWOpengame", "click",{standby1 = "1"})
        end
        cardid = "MINI_CREATEWORLD__ADVENTURE_1"
    elseif 2 == CreateWorldData.CurGameMode then    --创造模式
        worldType = 1
        if IsShowFguiStartMain() then
            standReportEvent("15", "XSELECT_GAME", "XCWOpengame", "click",{standby1 = "0"})
        end
        cardid = "MINI_CREATEWORLD__CREATE_1"
    end
    standReportGameOpenParam = {
        sceneid     = CreateWorldSID,
        cardid		= cardid,
        compid		= CreateWorldOID.StartGame,
        standby1    = "11" .. worldType
    }

    -- 普通模式 开始游戏点击埋点
    if CreateWorldData.ShowConfig then
        -- 普通模式设置 返回按钮点击埋点
        local CreateWorldTempCID = (CreateWorldData.CurGameMode == 1) and CreateWorldCID.AdvenModSet or CreateWorldCID.CreateModSet
        standReportEvent(CreateWorldSID, CreateWorldTempCID, CreateWorldOID.StartGame, CreateWorldEID.Click)
        
        -- 从设置中开始游戏区别
        standReportGameOpenParam.cardid = CreateWorldTempCID
        GetInst("ReportGameDataManager"):NewGameLoadParam(CreateWorldSID,CreateWorldTempCID,CreateWorldOID.StartGame)
    else
        -- 直接开始游戏， 无配置  
        standReportEvent(CreateWorldSID, cardid, CreateWorldOID.StartGame, CreateWorldEID.Click)
        GetInst("ReportGameDataManager"):NewGameLoadParam(CreateWorldSID,cardid,CreateWorldOID.StartGame)
    end

    GetInst("ReportGameDataManager"):SetGameMapOwn(GetInst("ReportGameDataManager"):GetGameMapOwnDefine().myMap)
    GetInst("ReportGameDataManager"):SetGameNetType(GetInst("ReportGameDataManager"):GetGameNetTypeDefine().singleMode)
    GetInst("ReportGameDataManager"):SetGameMapMode(worldType)

    CJSJ_CheateWorld()

    CreateWorldStatistics()
    end
        
    MinieduRemind_OnStartClick(enterGameCb)
end

--统计玩家选择的玩法
function CreateWorldStatistics(param)
    --玩法模式分类
    local worldType = CurNewWorldType 
    if worldType == -1 then 
        worldType = 0
    end  
    --房间分类
    local roomType = 0 

    --地形模式分类
    local terrainModeType = 0
    --地形分类
    local terrainType = 0 
    --是否有插件
    local haveComponent = 0
    --是否有插件包
    local haveMod = 0
    --是否有地形码
    local haveCode = 0 
    --是否手动修改过地形
    local haveModify = 0
    --是否手动设置过
    local haveSet = 0

    if worldType == 0 then 
        roomType = CreateWorldData.SurvivalMode.DifficultyModeIndex
        terrainModeType = CreateWorldData.SurvivalMode.TerrainModeIndex
        terrainType = FlatTerrainTypeList[CreateWorldData.SurvivalMode.FlatTerrainIndex]
        haveComponent = (creatingWorldModInfo.componentCount > 0) and 1 or 0
        haveMod = (creatingWorldModInfo.modCount > 0) and 1 or 0
        haveSet = CreateWorldHaveSet()
        haveCode = CreateWorldData.SurvivalMode.IsUseRandomTerrainSeed and 1 or 0
        haveModify = CreateWorld_IsModifyTerrain and 1 or 0
    elseif worldType == 1 then 
        roomType = 0
        terrainModeType = CreateWorldData.CreateMode.TerrainModeIndex
        terrainType = FlatTerrainTypeList[CreateWorldData.CreateMode.FlatTerrainIndex]
        haveComponent = 0
        haveMod = 0
        haveSet = CreateWorldHaveSet()
        haveCode = CreateWorldData.CreateMode.IsUseRandomTerrainSeed and 1 or 0
        haveModify = 0
    elseif worldType == 4 then 
        roomType = 0
        if param then 
            terrainModeType = param.terrainModeType
            terrainType = param.terrainType
            haveComponent = param.haveComponent
            haveMod = param.haveMod
            haveSet = CreateWorldHaveSet(param.haveSet)
            haveCode = param.haveCode
            haveModify = param.haveModify
        end 
    end

    print("打印创建世界统计信息")
    print("worldType: " .. worldType)
    print("roomType: " .. roomType)
    print("terrainModeType: " .. terrainModeType)
    print("terrainType: " .. terrainType)
    print("haveComponent: " .. haveComponent)
    print("haveMod: " .. haveMod)
    print("haveCode: " .. haveCode)
    print("haveModify: " .. haveModify)
    print("haveSet: " .. haveSet)

    -- statisticsGameEvent(8010,"%d",worldType,"%d",roomType,"%d",terrainModeType,"%d",terrainType,
    -- "%d",haveComponent,"%d",haveMod,"%d",haveCode,"%d",haveModify,"%d",haveSet)
end

--地图是否被手动修改过
function CreateWorldSetIsModifyTerrain(isModifyTerrain)
    CreateWorld_IsModifyTerrain = isModifyTerrain
end

--地图是否被手动设置过
function CreateWorldHaveSet(paramHaveSet)
    local haveSet = 0 
    local worldType = CurNewWorldType 
    if worldType == -1 then 
        worldType = 0
    end
    if worldType == 0 then
        local defaultName = AccountManager:getNickName()..GetS(59)
        local defaultRoomType = 1
        local defaultTerrainModeType = 4
        local defaultHaveCode = 0

        local curName = getglobal("CreateWorldFrameParamFrame1NameEdit"):GetText()
        if string.len(curName) == 0 then
            curName = AccountManager:getNickName()..GetS(59)
        end
        local curRoomType = CreateWorldData.SurvivalMode.DifficultyModeIndex
        local curTerrainModeType = CreateWorldData.SurvivalMode.TerrainModeIndex
        local curHaveCode = CreateWorldData.SurvivalMode.IsUseRandomTerrainSeed and 1 or 0

        if defaultName ~= curName or defaultRoomType ~= curRoomType or defaultTerrainModeType ~= curTerrainModeType 
        or defaultHaveCode ~= curHaveCode then 
            haveSet = 1
        end 
    elseif worldType == 1 then 
        local defaultName = AccountManager:getNickName()..GetS(60)
        local defaultTerrainModeType = 4
        local defaultHaveCode = 0

        local curName = getglobal("CreateWorldFrameParamFrame2NameEdit"):GetText()
        if string.len(curName) == 0 then
            curName = AccountManager:getNickName()..GetS(60)
        end
        local curTerrainModeType = CreateWorldData.CreateMode.TerrainModeIndex
        local curHaveCode = CreateWorldData.CreateMode.IsUseRandomTerrainSeed and 1 or 0

        if defaultName ~= curName or defaultTerrainModeType ~= curTerrainModeType or defaultHaveCode ~= curHaveCode then 
            haveSet = 1
        end
    elseif worldType == 4 then 
        haveSet = paramHaveSet
    end   
    return haveSet
end

function CreateWorldFrameParamFrame1NameEdit_OnFocusLost()

end

function CreateWorldFrameParamFrame2NameEdit_OnFocusLost()

end

function CreateWorldFrame_OnEnterPressed()
    CJSJ_CheateWorld()
end

function CreateWorldFrameCheckBoxAddDefaultMod_OnClick()
	local tick = getglobal("CreateWorldFrameParamFrame1FreeModeParamFrameCheckboxAddDefaultModTick");

	if tick:IsShown() then
		tick:Hide();
	else
		tick:Show();
	end
end

-----------------------------------------------------RegulationsTips---------------------------------------------------
RegulationsTipsFrameAlpha = 0;
function RegulationsTipsFrame_OnLoad()
     this:setUpdateTime(0.1);
end

function RegulationsTipsFrame_OnUpdate()
    RegulationsTipsFrameAlpha = RegulationsTipsFrameAlpha - 0.02;
    if RegulationsTipsFrameAlpha > 1 or RegulationsTipsFrameAlpha < 0 then RegulationsTipsFrameAlpha = 1; end

    if RegulationsTipsFrameAlpha < 0.4 then
        getglobal("RegulationsTipsFrameBkg"):SetBlendAlpha(RegulationsTipsFrameAlpha);
        getglobal("RegulationsTipsFrameTitle"):SetBlendAlpha(RegulationsTipsFrameAlpha);
    end
    
    if RegulationsTipsFrameAlpha < 0.03 then
        getglobal("RegulationsTipsFrame"):Hide();
    end
end

function RegulationsTipsFrame_OnShow()
    RegulationsTipsFrameAlpha = 1;
    getglobal("RegulationsTipsFrameBkg"):SetBlendAlpha(RegulationsTipsFrameAlpha);
    getglobal("RegulationsTipsFrameTitle"):SetBlendAlpha(RegulationsTipsFrameAlpha);
    ClientMgr:playSound2D("sounds/ui/info/guide_get.ogg", 1);
end

function RegulationsTipsFrame_OnHide()
    RegulationsTipsFrameAlpha = 0;
end

------------------------------------------------------------高级物理AdvancedPhysics---------------------------------------------------------------
function AdvancedPhysicsSwitchBtn_OnClick( ... )
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

    if CreateWorldData.CurGameMode == 1 then
        CreateWorldData.SurvivalMode.AdvancedPhysics =true
    else
        CreateWorldData.CreateMode.AdvancedPhysics=true
    end

    CreateWorldFrameUpdate()
    
end

function GetCreateWorldData()
    return CreateWorldData
end

function SetCreateWorldData(value)
    CreateWorldData = value
end

