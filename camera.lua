local foldAll = false
local foldAdvance = true
local isEditMode = true
local lastViewMode
local isShowUi = false
local isSightMode = false;
local maxOptionIndex = 7    --最大选项索引号

--当前设置值
local curCameraConfig = {}

--自定义视角选项
local tblCameraOptions = {
    --快速预设选项
    [0] = {
        title=0,
        options={
            {option=6096, value=CCG_BACKVIEW},
            {option=6097, value=CCG_FLATVIEW},
            {option=6098, value=CCG_TOPVIEW}}
     },
    --准心选项
    [1] = {
        title=6099,
        options={
            {option=6100, value=CCT_SCREEN_CENTER},
            {option=6101, value=CCT_BODY_EYES}}
    },
    --移动限制
    [2] = {
        title=6102,
        options={
            {option=6106, value=CML_NO_LIMIT},
            {option=6103, value=CML_ONLY_X},
            {option=6104, value=CML_ONLY_Y},
            {option=6105, value=CML_ONLY_XY}}
     },
    --摄像机跟随类型
    [3] = {
        title=6107,
        options={
            {option=6108, value=CAR_FOLLOWED_CAMERA},
            {option=6109, value=CAR_FIXED_CAMERA}}
    },
    --视角转动类型
    [4] = {
        title=6110,
        options={
            {option=6111, value=CRT_CAMERA_AND_BODY},
            {option=6112, value=CRT_NOTHING},
            {option=6113, value=CRT_ONLY_BODY},
            {option=6114, value=CRT_ONLY_CAMERA}}
    },
    --转动限制
    [5] = {
        title=6115,
        options={
            {option=6106, value=CRL_NO_LIMIT},
            {option=6103, value=CRL_ONLY_X},
            {option=6104, value=CRL_ONLY_Y}}
    },
    --人物朝向类型
    [6] = {
        title=6116,
        options={
            {option=6117, value=CFBD_NO_TURN_FACE},
            {option=6118, value=CFBD_YES_TURN_FACE}}
    },
    --镜头缩进
    [7] = {
        title=6218,
        options={
            {option=6220, value=CAZ_AUTO_ZOOM_NO},
            {option=6219, value=CAZ_AUTO_ZOOM_YES}}
    }
}

--默认设置
local tblDefaultSet = {
    [0] = {
        [0]    = 0,
        [1]    = 1,
        [2]    = 1,
        [3]    = 1,
        [4]    = 1,
        [5]    = 1,
        [6]    = 1,
        [7]    = 2,

        ["fov"] = 75
    },
    [1] = {
        [0]    = 1,
        [1]    = 1,
        [2]    = 1,
        [3]    = 1,
        [4]    = 1,
        [5]    = 1,
        [6]    = 1,
        [7]    = 2,

        ["fov"] = 75
    },
    [2] = {
        [0]    = 2,
        [1]    = 2,
        [2]    = 3,
        [3]    = 1,
        [4]    = 3,
        [5]    = 3,
        [6]    = 2,
        [7]    = 1,

        ["fov"] = 75
    },
    [3] = {
        [0]    = 3,
        [1]    = 2,
        [2]    = 1,
        [3]    = 1,
        [4]    = 3,
        [5]    = 2,
        [6]    = 1,
        [7]    = 1,
        
        ["fov"] = 75
    }
}


local function TableDeepCopy( obj )      
    local InTable = {};  
    local function Func(obj)  
        if type(obj) ~= "table" then   --判断表中是否有表  
            return obj;  
        end  
        local NewTable = {};  --定义一个新表  
        InTable[obj] = NewTable;  --若表中有表，则先把表给InTable，再用NewTable去接收内嵌的表  
        for k,v in pairs(obj) do  --把旧表的key和Value赋给新表  
            NewTable[Func(k)] = Func(v);  
        end  
        return setmetatable(NewTable, getmetatable(obj))--赋值元表  
    end  
    return Func(obj) --若表中有表，则把内嵌的表也复制了  
end

local function FindIndexByValue(tbl, value)
    if type(tbl) ~= "table" then
        return -1;
    end  

    for k, option in pairs(tbl) do
        if option.value == value then
            return k
        end
    end
    return -1;
end

local function SetCurCameraConfig(config)
	curCameraConfig[CAMERA_OPTION_INDEX_CONFIG_SET]        = config:getOption(CAMERA_OPTION_INDEX_CONFIG_SET)

    curCameraConfig[CAMERA_OPTION_INDEX_CROSSHAIR]         = FindIndexByValue(tblCameraOptions[CAMERA_OPTION_INDEX_CROSSHAIR].options,      config:getOption(CAMERA_OPTION_INDEX_CROSSHAIR))
    curCameraConfig[CAMERA_OPTION_INDEX_MOVEMENT_LIMIT]    = FindIndexByValue(tblCameraOptions[CAMERA_OPTION_INDEX_MOVEMENT_LIMIT].options, config:getOption(CAMERA_OPTION_INDEX_MOVEMENT_LIMIT))
    curCameraConfig[CAMERA_OPTION_INDEX_CAMERA_MOTION]     = FindIndexByValue(tblCameraOptions[CAMERA_OPTION_INDEX_CAMERA_MOTION].options,  config:getOption(CAMERA_OPTION_INDEX_CAMERA_MOTION))
    curCameraConfig[CAMERA_OPTION_INDEX_ROTATING]          = FindIndexByValue(tblCameraOptions[CAMERA_OPTION_INDEX_ROTATING].options,       config:getOption(CAMERA_OPTION_INDEX_ROTATING))
    curCameraConfig[CAMERA_OPTION_INDEX_ROTATING_LIMIT]    = FindIndexByValue(tblCameraOptions[CAMERA_OPTION_INDEX_ROTATING_LIMIT].options, config:getOption(CAMERA_OPTION_INDEX_ROTATING_LIMIT))
    curCameraConfig[CAMERA_OPTION_INDEX_FACE]              = FindIndexByValue(tblCameraOptions[CAMERA_OPTION_INDEX_FACE].options,           config:getOption(CAMERA_OPTION_INDEX_FACE))
    curCameraConfig[CAMERA_OPTION_INDEX_AUTO_ZOOM]         = FindIndexByValue(tblCameraOptions[CAMERA_OPTION_INDEX_AUTO_ZOOM].options,      config:getOption(CAMERA_OPTION_INDEX_AUTO_ZOOM))
    
    curCameraConfig.fov = config:getFov()
end

local function CanShow()
    --检查游戏模式
	if not CurWorld:isGameMakerMode() then 			
		return false;
	end
    
    --检查作者
	local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
	if worldDesc ~= nil and worldDesc.realowneruin ~= 0 and worldDesc.owneruin ~= worldDesc.realowneruin then --下载的存档
		return false;
	end

    return true;
end


function CameraFrame_OnLoad()
    --设置选项编号
    for i=0, maxOptionIndex do
        local option = getglobal("CameraOption"..i)
        option:SetClientID(i)
    end
    --设置滑动项编号
    for i=0, 0 do
        local slider = getglobal("CameraValue"..i)
        slider:SetClientID(i)
    end
    --设置滑动项的选择范围
    local bar = getglobal("CameraValue0Bar")
    bar:SetMinValue(10);
    bar:SetMaxValue(100);
	bar:SetValueStep(0.1);
end

function CameraFrame_OnEvent()

end

function CameraFrame_OnShow()
    --if ClientMgr:isPC() then
    --    HideAllFrame("CameraFrame", true);
    --end

    --进入自定义视角编辑模式
    lastViewMode = CurMainPlayer:getViewMode()
    CurWorld:setCameraEditState(CAMERA_EDIT_STATE_EDIT)

    --获取当前自定义视角设置
    local config_saved = CurWorld:getCustomCameraConfig()
    local config_cur = CurMainPlayer:getCurCameraConfig()
    config_cur:copyFrom(config_saved)

    if CCG_SYSTEM_DEFAULT == config_cur:getOption(CAMERA_OPTION_INDEX_CONFIG_SET) then
        --第一次自定义视角，将第三人称过肩视角作为默认自定义视角
        curCameraConfig = TableDeepCopy(tblDefaultSet[CCG_BACKVIEW])
        
        CurMainPlayer:resetCameraPos()
        GetDefaultCameraConfig(config_cur, curCameraConfig[CAMERA_OPTION_INDEX_CONFIG_SET])
        config_saved:copyFrom(config_cur) --保存当前设置
    else
        SetCurCameraConfig(config_cur)
    end
    
    isShowUi = false;
    isSightMode = CurMainPlayer:isSightMode();

    CurMainPlayer:setViewMode(5)    --自定义视角
    CameraFrameRefreshUi()
    UpdateTipsFrame(GetS(6213), 0)
end

function CameraFrame_OnHide()
    --Log("CameraFrame_OnHide() lastViewMode = "..lastViewMode)
    --CurMainPlayer:resetCameraPos()
    
    local curConfig = CurMainPlayer:getCurCameraConfig()
    local savedConfig = CurWorld:getCustomCameraConfig()

    --在测试状态下关闭，要先切换为编辑状态，再关闭编辑状态
    if CurWorld:getCameraEditState() == CAMERA_EDIT_STATE_TEST then
        CurWorld:setCameraEditState(CAMERA_EDIT_STATE_EDIT)
        -- 恢复测试前的设置    
        CurMainPlayer:applyCurCameraConfig()
    end
    CurWorld:setCameraEditState(CAMERA_EDIT_STATE_NULL)
    
    CurMainPlayer:setCameraConfigPosition()
    CurMainPlayer:setCameraConfigLookDir()
    curConfig:setFov(curCameraConfig.fov or 75)

    --比较自定义视角的设置是否改变
    if not curConfig:isEqual(savedConfig) then
        if IsUGCEditing() then
            --保存自定义视角的二次确认
            MessageBox(69, GetS(3629), function(btn)
                --xyang 在新引擎和老引擎中，left和right对应确定和取消是相反的。所以挪到另一个版本时候，要重复检查确认一遍
                if btn == 'left' then		--保存(确定)
                    CurWorld:getCustomCameraConfig():copyFrom(CurMainPlayer:getCurCameraConfig())
                    -- 自动把玩法规则中的视角类型设置为“锁定自定义视角”
                    CurWorld:setGameRule(9, 88, 0);
                    CurMainPlayer:setViewMode(0)                --退出时停留在自定义视角
                    getglobal("CameraFrameConfig"):Hide();
                    if isFromUGCCamerSetting then
                        isFromUGCCamerSetting = false
                        local mainFrame = GetInst("MiniUIManager"):GetCtrl("SceneEditorMainframe")
                        if mainFrame then
                            mainFrame:ChangeGameType(SceneEditorUIDef.GAME_TYPE.BUILD)
                        end
                    end
                elseif btn == 'right' then	--退出不保存（取消）
                    CurMainPlayer:setViewMode(0)     --退出时切换到上次视角
                    getglobal("CameraFrameConfig"):Hide();
                    if isFromUGCCamerSetting then
                        isFromUGCCamerSetting = false
                        local mainFrame = GetInst("MiniUIManager"):GetCtrl("SceneEditorMainframe")
                        if mainFrame then
                            mainFrame:ChangeGameType(SceneEditorUIDef.GAME_TYPE.BUILD)
                        end
                    end
                end
            end)
        else
            --比较自定义视角的设置是否改变
            --保存自定义视角的二次确认
            MessageBox(69, GetS(3629), function(btn)
                if btn == 'left' then		--保存(确定)
                    CurWorld:getCustomCameraConfig():copyFrom(CurMainPlayer:getCurCameraConfig())
                    -- 自动把玩法规则中的视角类型设置为“锁定自定义视角”
                    CurWorld:setGameRule(9, 88, 0);
                    CurMainPlayer:setViewMode(5)                --退出时停留在自定义视角
                    getglobal("CameraFrameConfig"):Hide();
                elseif btn == 'right' then	--退出不保存（取消）
                    CurMainPlayer:setViewMode(lastViewMode or 0)     --退出时切换到上次视角
                    getglobal("CameraFrameConfig"):Hide();
                end
            end)
        end
    else
        isShowUi = false
        getglobal("CameraFrameConfig"):Hide();
        CurMainPlayer:setViewMode(0)
    end
end

function CameraFrameConfig_OnShow()
    --if ClientMgr:isPC() then
    if CurWorld:getCameraEditState() == CAMERA_EDIT_STATE_EDIT then
        HideAllFrame("CameraFrame", true);
        if ClientMgr:isMobile() then
            getglobal("PlayMainFrameFly"):Show();
        end
    end
    --end

    --Log("CameraFrameConfig_OnShow111111")
    if not getglobal("CameraFrameConfig"):IsReshow() then
        --Log("CameraFrameConfig_OnShow")
        --CurMainPlayer:setActionInputActive(false)
        --CurMainPlayer:setMoveInputActive(false)
        --CurMainPlayer:clearAllInputState()

        if isSightMode then
            CurMainPlayer:showUI(true)
        end
        ClientCurGame:setOperateUI(true);
    end
end

function CameraFrameConfig_OnHide()
    --Log("CameraFrameConfig_OnShow22222")
    --if ClientMgr:isPC() then
    ClientCurGame:setOperateUI(false);
    if CurWorld:getCameraEditState() ~= CAMERA_EDIT_STATE_EDIT then
        ShowMainFrame();
    end
    --end

    if isSightMode then
        CurMainPlayer:showUI(false)
    end

    if not getglobal("CameraFrameConfig"):IsRehide() then
        --Log("CameraFrameConfig_OnHide")
        --ClientCurGame:setOperateUI(false);        
        --CurMainPlayer:setActionInputActive(true)
        --CurMainPlayer:setMoveInputActive(true)
        if isSightMode then
            CurMainPlayer:showUI(false)
        end
    end
end

function CameraFrame_OnUpdate()

end

function CameraFrameTestBtn_OnClick()
    --转到自定义视角的测试模式    
    isShowUi = false
    CurMainPlayer:setCameraConfigPosition()
    CurMainPlayer:setCameraConfigLookDir()
    CurMainPlayer:applyCurCameraConfig()
    CurWorld:setCameraEditState(CAMERA_EDIT_STATE_TEST)
    getglobal("CameraFrameConfig"):Hide()
    getglobal("CameraFrameBackBtn"):Show()
    
    UpdateTipsFrame(GetS(6214), 0)
end

function CameraFrameResetBtn_OnClick()
    curCameraConfig = TableDeepCopy(tblDefaultSet[curCameraConfig[CAMERA_OPTION_INDEX_CONFIG_SET]])
    GetDefaultCameraConfig(CurMainPlayer:getCurCameraConfig(), curCameraConfig[CAMERA_OPTION_INDEX_CONFIG_SET])
    CurMainPlayer:resetCameraPos()
    CameraFrameRefreshUi()
end

function CameraFrameTabBackBtn_OnClick()
    --返回到自定义视角的编辑模式
    isShowUi = true
    CurWorld:setCameraEditState(CAMERA_EDIT_STATE_EDIT)
    getglobal("CameraFrameBackBtn"):Hide()
    getglobal("CameraFrameConfig"):Show()
end

function CameraFrameShowConfigBtn_OnClick()
    foldAll = false
    getglobal("CameraFrameShowConfigBtn"):Hide()
    CameraFrameRefreshUi()
end

function CameraFrameFoldingBtn_OnClick()
    foldAll = true
    CameraFrameRefreshUi()
end

function CameraFrameAdvanceFoldingBtn_OnClick()
    foldAdvance = not foldAdvance    
    CameraFrameRefreshUi()
end

function CameraFrameCloseBtn_OnClick()
    getglobal("CameraFrame"):Hide()
end

function CameraFrameBuildinModeLeftBtn_OnClick()
    local options = tblCameraOptions[CAMERA_OPTION_INDEX_CONFIG_SET].options
    local cur_option_index = curCameraConfig[CAMERA_OPTION_INDEX_CONFIG_SET]

    for i=1, #(options) do
        cur_option_index = cur_option_index - 1
        if cur_option_index < 1 then
            cur_option_index = #(options)
        end
        if options[cur_option_index].option ~= 0 then
            break
        end
    end

    curCameraConfig[CAMERA_OPTION_INDEX_CONFIG_SET] = cur_option_index
    CurMainPlayer:setCameraConfigOption(CAMERA_OPTION_INDEX_CONFIG_SET, cur_option_index)
    --暂时先全部更新为默认值
    curCameraConfig = TableDeepCopy(tblDefaultSet[cur_option_index])
    GetDefaultCameraConfig(CurMainPlayer:getCurCameraConfig(), curCameraConfig[CAMERA_OPTION_INDEX_CONFIG_SET])
    CurMainPlayer:resetCameraPos()
    CameraFrameRefreshUi()
end

function CameraFrameBuildinModeRightBtn_OnClick()
    local options = tblCameraOptions[CAMERA_OPTION_INDEX_CONFIG_SET].options
    local cur_option_index = curCameraConfig[CAMERA_OPTION_INDEX_CONFIG_SET]

    for i=1, #(options) do
        cur_option_index = cur_option_index + 1
        if cur_option_index > #(options) then
            cur_option_index = 1
        end
        if options[cur_option_index].option ~= 0 then
            break
        end
    end

    curCameraConfig[CAMERA_OPTION_INDEX_CONFIG_SET] = cur_option_index
    CurMainPlayer:setCameraConfigOption(CAMERA_OPTION_INDEX_CONFIG_SET, cur_option_index)
    --暂时先全部更新为默认值
    curCameraConfig = TableDeepCopy(tblDefaultSet[cur_option_index])
    GetDefaultCameraConfig(CurMainPlayer:getCurCameraConfig(), curCameraConfig[CAMERA_OPTION_INDEX_CONFIG_SET])
    CurMainPlayer:resetCameraPos()
    CameraFrameRefreshUi()
end

function CameraFrameTemplateSliderBar_OnValueChanged()
	local value = this:GetValue();
	local ratio = (value-this:GetMinValue())/(this:GetMaxValue()-this:GetMinValue());

	if ratio > 1 then ratio = 1 end
	if ratio < 0 then ratio = 0 end
	local width   = math.floor(200*ratio)

    local valPro = getglobal(this:GetName().."Pro")
	local valFont = getglobal(this:GetParent().."Val");

    if valPro ~= nil then
        valPro:ChangeTexUVWidth(width);
	    valPro:SetWidth(width);
    end
    if valFont ~= nil then
	    valFont:SetText(string.format("%.1f", value));
    end

    curCameraConfig.fov = value
    CurMainPlayer:setCameraConfigFov(value)
end

function CameraFrameTemplateLeftBtn_OnClick()
    local index = this:GetParentFrame():GetClientID()
    local options = tblCameraOptions[index].options
    local cur_option_index = curCameraConfig[index]

    for i=1, #(options) do
        cur_option_index = cur_option_index - 1
        if cur_option_index < 1 then
            cur_option_index = #(options)
        end
        if options[cur_option_index].option ~= 0 then
            break
        end
    end

    curCameraConfig[index] = cur_option_index
    CurMainPlayer:setCameraConfigOption(index, options[cur_option_index].value)
    CameraFrameRefreshUi()
end

function CameraFrameTemplateRightBtn_OnClick()
    local index = this:GetParentFrame():GetClientID()
    local options = tblCameraOptions[index].options
    local cur_option_index = curCameraConfig[index]

    for i=1, #(options) do
        cur_option_index = cur_option_index + 1
        if cur_option_index > #(options) then
            cur_option_index = 1
        end
        if options[cur_option_index].option ~= 0 then
            break
        end
    end

    curCameraConfig[index] = cur_option_index    
    CurMainPlayer:setCameraConfigOption(index, options[cur_option_index].value)
    CameraFrameRefreshUi()
end

function CameraFrameRefreshUi()
    local configFrameHeight = 660
    local configMainFrameHeight = 616
    local backBtn = getglobal("CameraFrameBackBtn")
    local configFrame = getglobal("CameraFrameConfig")    
    local configFrameBkg = getglobal("CameraFrameConfigBkg")
    local configMainFrame = getglobal("CameraFrameConfigAllControl")
    local configAdvanceFrame = getglobal("CameraFrameConfigAllControlAdvance")
    local foldAdvanceIcon  = getglobal("CameraFrameConfigAllControlAdvanceLineNormal")

    if not isEditMode then
        backBtn:Show()
        configFrame:Hide()
        return
    else
        backBtn:Hide()
        configFrame:Show()
    end

    configMainFrame:Show()
    configAdvanceFrame:Show()
    
    
    foldAdvanceIcon:setUvType(4);
    if foldAll then
        configFrame:Hide()
        getglobal("CameraFrameShowConfigBtn"):Show()
        return
    elseif foldAdvance then
        configFrameHeight = 390
        configMainFrameHeight = 346
        configAdvanceFrame:Hide()
        foldAdvanceIcon:setUvType(2);
    elseif not foldAdvance then
        foldAdvanceIcon:setUvType(2);
        foldAdvanceIcon:setUvType(5);
    end

    configFrame:SetHeight(configFrameHeight)
    configFrameBkg:SetHeight(configFrameHeight)
    configMainFrame:SetHeight(configMainFrameHeight)

    --根据当前自定义视角进行UI初始化
    --摄像机选项
    for i=0, maxOptionIndex do
        local option = getglobal("CameraOption"..i.."Selection")
        option:SetText(GetS(tblCameraOptions[i].options[curCameraConfig[i]].option))

        if i ~= 0 then
            local name = getglobal("CameraOption"..i.."Name")
            name:SetText(GetS(tblCameraOptions[i].title))
        end
    end
    --视野滑动条
    local bar = getglobal("CameraValue0Bar")
	bar:SetValue(curCameraConfig.fov);
end

function GetDefaultCameraConfig(config, config_index)
    config:setOption(CAMERA_OPTION_INDEX_CONFIG_SET, config_index)

	config:setOption(CAMERA_OPTION_INDEX_CROSSHAIR,       tblCameraOptions[CAMERA_OPTION_INDEX_CROSSHAIR].options[tblDefaultSet[config_index][CAMERA_OPTION_INDEX_CROSSHAIR]].value)
	config:setOption(CAMERA_OPTION_INDEX_MOVEMENT_LIMIT,  tblCameraOptions[CAMERA_OPTION_INDEX_MOVEMENT_LIMIT].options[tblDefaultSet[config_index][CAMERA_OPTION_INDEX_MOVEMENT_LIMIT]].value)
	config:setOption(CAMERA_OPTION_INDEX_CAMERA_MOTION,   tblCameraOptions[CAMERA_OPTION_INDEX_CAMERA_MOTION].options[tblDefaultSet[config_index][CAMERA_OPTION_INDEX_CAMERA_MOTION]].value)
	config:setOption(CAMERA_OPTION_INDEX_ROTATING,        tblCameraOptions[CAMERA_OPTION_INDEX_ROTATING].options[tblDefaultSet[config_index][CAMERA_OPTION_INDEX_ROTATING]].value)
	config:setOption(CAMERA_OPTION_INDEX_ROTATING_LIMIT,  tblCameraOptions[CAMERA_OPTION_INDEX_ROTATING_LIMIT].options[tblDefaultSet[config_index][CAMERA_OPTION_INDEX_ROTATING_LIMIT]].value)
	config:setOption(CAMERA_OPTION_INDEX_FACE,            tblCameraOptions[CAMERA_OPTION_INDEX_FACE].options[tblDefaultSet[config_index][CAMERA_OPTION_INDEX_FACE]].value)
    config:setOption(CAMERA_OPTION_INDEX_AUTO_ZOOM,       tblCameraOptions[CAMERA_OPTION_INDEX_AUTO_ZOOM].options[tblDefaultSet[config_index][CAMERA_OPTION_INDEX_AUTO_ZOOM]].value)

    config:setFov(tblDefaultSet[config_index].fov)
end

function CameraFrameShow()
    if not CanShow() then
        return
    end

    if IsUGCEditing() then
        foldAll = false
    end
    getglobal("CameraFrame"):Show()
end


function CameraFrameShowForUGCCameraSetting()
    if not CanShow() then
        return
    end

    foldAll = false
    isFromUGCCamerSetting = true
    getglobal("CameraFrame"):Show()
end
