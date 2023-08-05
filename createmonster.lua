local CreateMonsterTable = {
    config = {
        widgetAttributes = {
            {
                Type = 'Selection',
                Name_StringID = 6317, --选择生物
                CurVal = 0,
                CanShow = true
            },
            {
                Type = 'Line',
                Title_StringID = 21201, --数量设置
                CanShow = true
            },
            {
                Type = 'Slider',
                Name_StringID = 21202, --每次生成数量
                CurVal = 1, Min = 1, Max = 32, Step = 1,
                ValShowType = 'Int',
                CanShow = true
            },
            {
                Type = 'Switch',
                Name_StringID = 21208, --数量检测
                CurVal = false,
                CanShow = true,
                HelpButton = true,
            },
            {
                Type = 'Slider',
                Name_StringID = 21203, --范围内最大数量
                CurVal = 10, Min = 1, Max = 100, Step = 1,
                ValShowType = 'Int',
                CanShow = false,
                HelpButton = true,
            },
            {
                Type = 'Line',
                Title_StringID = 21204, --生成范围
                CanShow = true
            },
            {
                Type = 'Slider',
                Name_StringID = 21204, --生成范围
                CurVal = 1, Min = 1, Max = 32, Step = 1,
                ValShowType = 'IntUnit', Unit_StringID = 9111, -- 格
                CanShow = true
            },
            {
                Type = 'Slider',
                Name_StringID = 21205, --生成高度
                CurVal = 1, Min = 1, Max = 256, Step = 1,
                ValShowType = 'IntUnit', Unit_StringID = 9111, -- 格
                CanShow = true
            },
            {
                Type = 'Line',
                Title_StringID = 21206, --生成间隔
                CanShow = true
            },
            {
                Type = 'Switch',
                Name_StringID = 21206, --生成间隔
                CurVal = false,
                CanShow = true
            },
            {
                Type = 'Slider',
                Name_StringID = 21207, --每次生成间隔
                CurVal = 18, Min = 1, Max = 180, Step = 1,
                ValShowType = 'IntUnit', Unit_StringID = 559, -- 秒
                CanShow = false
            }
        },
        defaultMonsters = {
            {
                Type = 1,
                ID = { 3400, 3401, 3402, 3403, 3405, 3406, 3407, 3408, 3409, 3410, 3415, 3418, 3419, 3423, 3424 }
            },
            {
                Type = 2,
                ID = { 3101, 3102, 3105, 3107, 3109, 3110, 3111, 3112, 3130, 3131 }
            }
        },
        helpButtons = {
            SingleCreateSelection1HelpBtn = {
                name = "SingleCreateSelection1HelpBtn",
                childName = { "Bkg", "Icon", "Choose", "Attribute", "Life", "Attack", "Describe", "Details" },
                children = {},
                childrenAttr = {
                    closed = {
                        -- function, this, params...
                        { "point", "Bkg",       "top",   "SingleCreateSelection1HelpBtnNormal", "bottom", -61, 0 },
                        { "point", "",          "bottomleft",      "SingleCreateSelection1Btn", "bottomright", 5, 0 },
                        { "point", "Normal",    "bottomleft",  "SingleCreateSelection1Btn", "bottomright", 5, 0 },
                        { "point", "PushedBG",  "bottomleft",   "SingleCreateSelection1Btn", "bottomright", 5, 0 },
                        { "size", "", 30, 31 },
                        { "strata", "", 4 }
                    },
                    opening = {
                        { "point", "Bkg",       "top", "SingleCreateSelection1HelpBtnNormal", "bottom", -61, 0 },
                        { "point", "",          "bottomleft",      "SingleCreateSelection1Btn", "bottomright", 5, 0 },
                        { "point", "Normal",    "bottomleft",  "SingleCreateSelection1Btn", "bottomright", 5, 0 },
                        { "point", "PushedBG",  "bottomleft",   "SingleCreateSelection1Btn", "bottomright", 5, 0 },
                        { "size", "", 668, 200 },
                        { "strata", "", 5 }
                    }
                }
            }
        },
        height = {
            Line = 40, Switch = 60, Slider = 70, Selection = 150
        }
    },
    constants = {
        INIT_ID = 4000,
        MAX_TAB_NUM = 3,
        MAX_ORGANISM_GRID_NUM = 81,
        IO_PARAMS_NAME = { "MobResID", "everyNum", "maxNum", "spawnWide", "spawnHigh", "spawnDelay", "numSwitch", "DelaySwitch" },
        IO_PARAMS_INDEX = { 1, 3, 5, 7, 8, 11, 4, 10 },
        TAB_NAME_STRING_ID = { 3964, 3965, 4544 }
    },
    organismdefs = {}
}
local main = CreateMonsterTable

local tmpChooseMonsterDef
local curChooseMonsterDef
local curChooseType = 1
local needInit = true

function getCreateMonsterTable()
    return CreateMonsterTable
end
-- 获取对应怪物的类型
local function getType(id)
    local type = 3
    for i = 1, #main.config.defaultMonsters do
        local ids = main.config.defaultMonsters[i]
        for j = 1, #ids.ID do
            if id == ids.ID[j] then
                type = ids.Type
            end
        end
    end
    return type
end
-- 设置图标
local function setIcon(icon, def)
    if tonumber(def.ID) and tonumber(def.ID) == main.constants.INIT_ID then
        return
    end
    --微雕
    if def.ModelType == MONSTER_CUSTOM_MODEL then
        SetModelIcon(icon, def.Model, ACTOR_MODEL);
        return;
    elseif def.ModelType == MONSTER_FULLY_CUSTOM_MODEL then
        SetModelIcon(icon, def.Model, FULLY_ACTOR_MODEL);
        return;
    elseif def.ModelType == MONSTER_IMPORT_MODEL then
        SetModelIcon(icon, def.Model, IMPORT_ACTOR_MODEL);
        return
    end
    if tonumber(def.Icon) and tonumber(def.Icon) > 0 then
        icon:SetTexture("ui/roleicons/" .. def.Icon .. ".png", true)
    else
        icon:SetTexture("ui/roleicons/" .. def.ID .. ".png", true) -- 个别怪物没有填写icon列
    end 
    if type(def.Icon) == "string" then
        if (string.sub(def.Icon,1,1)) == "a" then 
            --avatar图标
            AvatarSetIconByID(def,icon)
        end 
    end
end
-- 隐藏除exclude外的帮助按钮信息，给0则全部隐藏
local function hideHelpBtn(exclude)
    if getglobal("SingleCreateSlider2HelpBtnBkg"):IsShown() and exclude ~= 1 then
        getglobal("SingleCreateSlider2HelpBtnBkg"):Hide()
        getglobal("SingleCreateSlider2HelpBtnTips"):Hide()
        getglobal("SingleCreateSlider2HelpBtn"):SetFrameStrataInt(4)
        getglobal("SingleCreateSlider2HelpBtn"):SetSize(30, 31)
    end
    if getglobal("SingleCreateSwitch1HelpBtnBkg"):IsShown() and exclude ~= 2  then
        getglobal("SingleCreateSwitch1HelpBtnBkg"):Hide()
        getglobal("SingleCreateSwitch1HelpBtnTips"):Hide()
        getglobal("SingleCreateSwitch1HelpBtn"):SetFrameStrataInt(4)
        getglobal("SingleCreateSwitch1HelpBtn"):SetSize(30, 31)
    end
    if getglobal("SingleCreateSelection1HelpBtnBkg"):IsShown() and exclude ~= 3  then
        getglobal("SingleCreateSelection1HelpBtn"):SetFrameStrataInt(4)
        getglobal("SingleCreateSelection1HelpBtn"):SetSize(30, 31)
        getglobal("SingleCreateSelection1HelpBtnBkg"):SetPoint("top", "SingleCreateSelection1HelpBtn", "top", -61, 0)
        getglobal("SingleCreateSelection1HelpBtn"):SetPoint("bottomleft", "SingleCreateSelection1", "bottomright", 5, 0)
--        getglobal("SingleCreateSelection1HelpBtnNormal"):SetPoint("topleft", "SingleCreateSelection1HelpBtn", "topleft", 0, 0)
--        getglobal("SingleCreateSelection1HelpBtnPushedBG"):SetPoint("center", "SingleCreateSelection1HelpBtn", "center", 0, 0)
        local names = main.config.helpButtons["SingleCreateSelection1HelpBtn"].childName
        for i = 1, #names do
            getglobal("SingleCreateSelection1HelpBtn" .. names[i]):Hide()
        end
    end
end

function CreateMonsterFrame_OnClick()
    if getglobal("SingleCreateSelection1HelpBtnBkg"):IsShown() then
        CreateMonsterHelpBtn_OnClick();
    end

    hideHelpBtn(0)
end

function CreateMonsterFrame_OnShow()
    if not needInit then
        return
    end
    needInit = false
    HideAllFrame("CreateMonsterFrame", true)
    hideHelpBtn(0)

    LoadOrganismDef()
    if not getglobal("CreateMonsterFrame"):IsReshow() then
        ClientCurGame:setOperateUI(true)
    end
    -- 根据config配置各个控件
    local curSetting = OpenContainer:getBrushMonsterAttr()
    local names = main.constants.IO_PARAMS_NAME
    local indexs = main.constants.IO_PARAMS_INDEX
    for i = 1, #names do
        main.config.widgetAttributes[indexs[i]].CurVal = curSetting[names[i]]
        if names[i] == "spawnDelay" then
            -- 20 is conversion ratio of interval
            main.config.widgetAttributes[indexs[i]].CurVal = main.config.widgetAttributes[indexs[i]].CurVal / 20
        end
        if string.find(names[i], "Switch") then
            main.config.widgetAttributes[indexs[i] + 1].CanShow = curSetting[names[i]]
        end
    end
    if main.config.widgetAttributes[1].CurVal == main.constants.INIT_ID then
        curChooseMonsterDef = nil
        tmpChooseMonsterDef = nil
    end
    UpdateCreateMonsterFrame()
end

function CreateMonsterFrame_OnHide()
    -- 当且仅当主窗口CreateMonsterFrame隐藏过后，才需要初始化
    needInit = true
    curChooseType = 1
    curChooseMonsterDef = nil
    tmpChooseMonsterDef = nil
    ShowMainFrame()

    if not getglobal("CreateMonsterFrame"):IsRehide() then
        ClientCurGame:setOperateUI(false)
    end

    UIFrameMgr:setCurEditBox(nil)
end

function CreateMonsterFrame_OnLoad()
    UpdateCreateMonsterFrame()
    for i = 1, main.constants.MAX_ORGANISM_GRID_NUM / 9 do
        for j = 1, 9 do
            local index = (i - 1) * 9 + j;
            local grid = getglobal("OrganismGrid" .. index);
            grid:SetPoint("topleft", "OrganismGridBoxPlane", "topleft", (j - 1) * 84, (i - 1) * 84);
        end
    end
end

function CreateMonsterFrameCloseBtn_OnClick()
    hideHelpBtn(0)
    getglobal("CreateMonsterFrame"):Hide()
end

function CreateMonsterFrameSaveBtn_OnClick()
    hideHelpBtn(0)
    if curChooseMonsterDef then
        local params = {}
        local attr = CreateMonsterTable.config.widgetAttributes

        params.id = curChooseMonsterDef.ID
        params.everyNum = attr[3].CurVal
        params.maxNum = attr[5].CurVal
        params.spawnWide = attr[7].CurVal
        params.spawnHigh = attr[8].CurVal
        params.spawnDelay = attr[11].CurVal
        params.numSwitch = attr[4].CurVal
        params.delaySwitch = attr[10].CurVal
        if next(params) == nil then
            Log("CreateMonsterFrameSaveBtn_OnClick : params ERROR !!!")
        else
            OpenContainer:setBrushMonsterAttr(params.id, params.everyNum, params.maxNum, params.spawnWide, params.spawnHigh, params.spawnDelay, params.numSwitch, params.delaySwitch)
        end
        ShowGameTips(GetS(3940))
        getglobal("CreateMonsterFrame"):Hide()
    end
end

function ChooseOrganismFrame_OnLoad()
    
end

function ChooseOrganismFrame_OnShow()
    UpdateOrganismGridBox(1)
    getglobal("ChooseOrganismFrameOkBtn"):SetClientID(0);
end

function ChooseOrganismFrame_OnHide()

end

local checkedHaloName -- halo of choosing grid
function OrganismGridTemplate_OnClick()
    local id = this:GetClientID();
    if checkedHaloName then
        getglobal(checkedHaloName .. "Checked"):Hide();
    end

    checkedHaloName = this:GetName()
    getglobal(checkedHaloName .. "Checked"):Show();

    --curChooseMonsterDef = nil;
    tmpChooseMonsterDef = nil
    local def = ModEditorMgr:getMonsterDefById(id);
    if not def then
        def = MonsterCsv:get(id);
    end
    --弹出提示框
    if def then
        UpdateTipsFrame(def.Name, 0);
        tmpChooseMonsterDef = def
        --curChooseMonsterDef = def;
        print(tmpChooseMonsterDef.ID)
    end
end

function CreateTabTemplate_OnClick()
    local index = this:GetClientID();
    local btnName = this:GetName();
    local checked = getglobal(btnName .. "Checked");
    if checked:IsShown() then
        return
    end
    curChooseType = index
    --Log("CreateTabTemplate_OnClick:"..btnName);
    UpdateOrganismGridBox();
    SetChooseOrganismFrameTab();
end

function ChooseOrganismFrameClose_OnClick()
    hideHelpBtn(0)
    getglobal("ChooseOrganismFrame"):Hide()
    tmpChooseMonsterDef = nil
end

function ChooseOrganismFrameOkBtn_OnClick()
    curChooseMonsterDef = tmpChooseMonsterDef
    if curChooseMonsterDef then
        getglobal("ChooseOrganismFrame"):Hide()
        main.config.widgetAttributes[1].CurVal = curChooseMonsterDef.ID
        local name = getglobal("SingleCreateSelection1" .. "Choose")
        local icon = getglobal("SingleCreateSelection1" .. "Btn" .. "Icon")
        name:SetText(curChooseMonsterDef.Name)
        setIcon(icon, curChooseMonsterDef)

        getglobal("SingleCreateSelection1" .. "HelpBtn"):Show()
        name:Show()
        icon:Show()
    end
end

function UpdateCreateMonsterFrame()
    local attributes = main.config.widgetAttributes
    local height = main.config.height
    local widgetIndex = {
        Selection = 1,
        Line = 1,
        Switch = 1,
        Slider = 1
    }
    local pointY = 0;

    for i = 1, #attributes do
        local frame = getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type])
        if frame then
            if attributes[i].Type == 'Slider' then
                local name = getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "Name")
                local valFont = getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "Val")
                local bar = getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "Bar")
                local curVal = attributes[i].CurVal

                bar:SetMinValue(attributes[i].Min)
                bar:SetMaxValue(attributes[i].Max)
                bar:SetValueStep(attributes[i].Step)
                bar:SetValue(curVal)
                name:SetText(GetS(attributes[i].Name_StringID))

                if attributes[i].ValShowType == 'Int' then
                    valFont:SetText(curVal)
                elseif attributes[i].ValShowType == 'IntUnit' then
                    valFont:SetText(curVal .. GetS(attributes[i].Unit_StringID))
                end
            elseif attributes[i].Type == 'Line' then
                if attributes[i].Title_StringID then
                    getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "LineZheZhao"):Show()
                    getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "Title"):Show()
                    getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "Title"):SetText(GetS(attributes[i].Title_StringID))
                else
                    getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "LineZheZhao"):Hide()
                    getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "Title"):Hide()
                end
            elseif attributes[i].Type == 'Switch' then
                local name = getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "Name")
                local switchBtn = getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "Btn")
                local state = attributes[i].CurVal and 1 or 0

                name:SetText(GetS(attributes[i].Name_StringID))
                SetSwitchBtnState(switchBtn:GetName(), state)
            elseif attributes[i].Type == 'Selection' then
                local name = getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "Name")
                local attrBtn = getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "HelpBtn")
                local choose = getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "Choose")
                local id = attributes[i].CurVal
                local btn = getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "Btn")
                local icon = getglobal(btn:GetName() .. "Icon");
                name:SetText(GetS(attributes[i].Name_StringID))
                if attributes[i].CurVal ~= main.constants.INIT_ID then
                    btn:Show()
                    curChooseMonsterDef = ModEditorMgr:getMonsterDefById(id);
                    if not curChooseMonsterDef then
                        curChooseMonsterDef = MonsterCsv:get(id);
                    end
                    if curChooseMonsterDef then
                        setIcon(icon, curChooseMonsterDef)
                        choose:SetText(curChooseMonsterDef.Name)
                        choose:Show()
                        attrBtn:Show()
                        icon:Show()
                    else

                    end
                else
                    choose:Hide()
                    attrBtn:Hide()
                    icon:Hide()
                end

            end
            frame:SetClientID(i)

            if i == 1 then -- Selection 不在滚动栏中
                frame:SetPoint("bottom", "SingleCreateAttrBox", "top", 0, pointY)
            else
                frame:SetPoint("top", "SingleCreateAttrBoxPlane", "top", 0, pointY)
            end

            if attributes[i].HelpButton then
                getglobal("SingleCreate" .. attributes[i].Type .. widgetIndex[attributes[i].Type] .. "HelpBtn"):Show()
            end

            if i > 1 and attributes[i].CanShow then
                pointY = pointY + height[attributes[i].Type]
            end

        else
            Log("ERROR : uiFrame is nil")
        end

        if attributes[i].CanShow then
            frame:Show()
        else
            frame:Hide()
        end
        widgetIndex[attributes[i].Type] = widgetIndex[attributes[i].Type] + 1
    end

    if pointY < 516 then
        pointY = 516
    end
    getglobal("SingleCreateAttrBoxPlane"):SetHeight(pointY)
end

local function getTableByType(type)
    local defs = main.organismdefs
    for i = 1, #(defs) do
        if type == defs[i].Type then
            return defs[i].t;
        end
    end
    return nil
end

function UpdateOrganismGridBox()
    if checkedHaloName then
        getglobal(checkedHaloName .. "Checked"):Hide();
    end
    getglobal("OrganismGridBox"):resetOffsetPos();

    local typeTable = getTableByType(curChooseType);
    if typeTable == nil then
        ShowGameTips(GetS(3758), 3);
        getglobal("ChooseOrganismFrame"):Hide();
        return ;
    end

    local num = #(typeTable)
    for i = 1, main.constants.MAX_ORGANISM_GRID_NUM do

        local grid = getglobal("OrganismGrid" .. i)
        if i <= num then
            grid:Show()
            grid:SetClientID(typeTable[i].ID)
            local icon = getglobal(grid:GetName() .. "Icon")
            setIcon(icon, typeTable[i])
        else
            grid:Hide()
        end
    end

    local height = 333 + math.ceil((num - 36) / 9) * 84
    if height < 333 then
        height = 333
    end

    getglobal("OrganismGridBoxPlane"):SetSize(755, height)
end

function SetChooseOrganismFrame()
    LoadOrganismDef()
    SetChooseOrganismFrameTab()
    UpdateOrganismGridBox()
    getglobal("ChooseOrganismFrame"):Show()
end

function SetChooseOrganismFrameTab()
    local defs = main.organismdefs
    for i = 1, main.constants.MAX_TAB_NUM do
        local tab = getglobal("ChooseOrganismFrameTabs" .. i)
        local name = getglobal("ChooseOrganismFrameTabs" .. i .. "Name")
        local normal = getglobal("ChooseOrganismFrameTabs" .. i .. "Normal")
        local checked = getglobal("ChooseOrganismFrameTabs" .. i .. "Checked")
        tab:SetClientID(i)
        if defs[i] and defs[i].Type == curChooseType then
            normal:Hide()
            checked:Show()
        else
            normal:Show()
            checked:Hide()
        end

        tab:Show()
        local type = defs[i].Type
        name:SetText(GetS(main.constants.TAB_NAME_STRING_ID[type]))
    end
end

function LoadOrganismDef()
    main.organismdefs = {}
    local defs = main.organismdefs
    --自定义生物
    local customNum = ModMgr:getMonsterCount()
    table.insert(defs, { Type = 3, t = {} });
    local customTable = getTableByType(3)
    for i = 1, customNum do
        local tryGetDef = ModMgr:tryGetMonsterDefByIndex(i - 1)
        local def = ModMgr:tryGetMonsterDef(tryGetDef.ID)
        if def and def.CopyID > 0 then
            table.insert(customTable, def);
        end
    end

    for i = 1, #main.config.defaultMonsters do
        local one = main.config.defaultMonsters[i]
        for j = 1, #one.ID do
            local def = MonsterCsv:get(one.ID[j])
            if def then
                local t = getTableByType(one.Type)
                if t == nil then
                    table.insert(defs, { Type = one.Type, t = { def } });
                else
                    table.insert(t, def);
                end
            end
        end
    end
    table.sort(defs, function(a, b)
        return a.Type < b.Type
    end);
end

function CreateMonsterHelpBtn_OnClick()
    hideHelpBtn(3)

    local btn = main.config.helpButtons["SingleCreateSelection1HelpBtn"]
    local attr
    if next(btn.children) == nil then
        for i = 1, #btn.childName do
            btn.children[btn.childName[i]] = getglobal(btn.name .. btn.childName[i])
        end
    end

    setIcon(btn.children.Icon, curChooseMonsterDef)
    btn.children.Choose:SetText(curChooseMonsterDef.Name)
    btn.children.Attribute:SetText(GetS(1107) .. GetS(8503) .. GetS(main.constants.TAB_NAME_STRING_ID[getType(curChooseMonsterDef.ID)]))
    btn.children.Life:SetText(GetS(4300) .. GetS(8503) .. curChooseMonsterDef.Life)
    btn.children.Attack:SetText(GetS(4302) .. GetS(8503) .. curChooseMonsterDef.Attack)
    if tostring(curChooseMonsterDef.Desc) ~= "" then
        btn.children.Details:SetText(curChooseMonsterDef.Desc)
    else
        btn.children.Details:SetText(GetS(58))
    end

    if btn.children.Bkg and btn.children.Bkg:IsShown() then
        attr = btn.childrenAttr.closed
    else
        attr = btn.childrenAttr.opening
    end

    for i = 1, #attr do
        local fun = attr[i]
        local obj = getglobal( btn.name .. fun[2] )
        if fun[1] == "point" then
            obj:SetPoint(fun[3], fun[4], fun[5], fun[6], fun[7])
        elseif fun[1] == "size" then
            obj:SetSize(fun[3], fun[4])
        elseif fun[1] == "strata" then
            obj:SetFrameStrataInt(fun[3])

        end
    end
    for i = 1, #btn.childName do
        local child = btn.children[btn.childName[i]]
        if child:IsShown() then
            child:Hide()
        else
            child:Show()
        end
    end

end

function SingleCreateFeatureHelpBtn_OnClick()
    local bkg
    local tips
    if string.find(this:GetName(), "Slider") then
        hideHelpBtn(1)
        bkg = getglobal("SingleCreateSlider2HelpBtnBkg")
        tips = getglobal("SingleCreateSlider2HelpBtnTips")
        if bkg:IsShown() then
            getglobal("SingleCreateSlider2HelpBtnNormal"):SetPoint("topleft", "SingleCreateSlider2HelpBtn","topleft", 0, 0)
        else
            getglobal("SingleCreateSlider2HelpBtnNormal"):SetPoint("bottomright", "SingleCreateSlider2HelpBtn","bottomright", 0, 0)
            this:SetSize(240, 200)
        end

    else -- Switch
        hideHelpBtn(2)
        bkg = getglobal("SingleCreateSwitch1HelpBtnBkg")
        tips = getglobal("SingleCreateSwitch1HelpBtnTips")
        if bkg:IsShown() then

        else
            this:SetSize(220, 220)
        end
    end

    if bkg:IsShown() then
        bkg:Hide()
        tips:Hide()
        this:SetFrameStrataInt(4)
        this:SetSize(30, 31)
    else
        this:SetFrameStrataInt(5)
        bkg:Show()
        tips:Show()
    end
end

function CreateSliderTemplateLeftBtn_OnClick()
    hideHelpBtn()
    local value = getglobal(this:GetParent() .. "Bar"):GetValue()
    local index = this:GetParentFrame():GetClientID()
    local widget = main.config.widgetAttributes[index]

    value = value - widget.Step
    getglobal(this:GetParent() .. "Bar"):SetValue(value)
end

function CreateSliderTemplateBar_OnValueChanged()
    hideHelpBtn()
    local value = this:GetValue()
    local ratio = (value - this:GetMinValue()) / (this:GetMaxValue() - this:GetMinValue());

    if ratio > 1 then
        ratio = 1
    end
    if ratio < 0 then
        ratio = 0
    end
    local width = math.floor(183 * ratio)
    getglobal(this:GetName() .. "Pro"):ChangeTexUVWidth(width);
    getglobal(this:GetName() .. "Pro"):SetWidth(width);

    local index = this:GetParentFrame():GetClientID()
    local t = main.config.widgetAttributes[index]

    t.CurVal = value
    local valFont = getglobal(this:GetParent() .. "Val")
    if t.ValShowType then
        if t.ValShowType == 'Int' then
            valFont:SetText(value)
        elseif t.ValShowType == 'IntUnit' then
            valFont:SetText(value .. GetS(t.Unit_StringID))
        end
    end
end

function CreateSliderTemplateRightBtn_OnClick()
    hideHelpBtn()
    local value = getglobal(this:GetParent() .. "Bar"):GetValue()
    local index = this:GetParentFrame():GetClientID()
    local widget = main.config.widgetAttributes[index]

    value = value + widget.Step
    getglobal(this:GetParent() .. "Bar"):SetValue(value)
end

function CreateSelBtnTemplate_OnClick()
    if getglobal("SingleCreateSelection1HelpBtnBkg"):IsShown() then
        CreateMonsterHelpBtn_OnClick();
    end
    
    hideHelpBtn()
    SetChooseOrganismFrame()
end

function CreateSwitchTemplateBtn_OnClick(swithcName, state)
    hideHelpBtn()
    local switch = getglobal(swithcName)

    local index = switch:GetParentFrame():GetClientID()
    local widget = main.config.widgetAttributes[index]

    state = state == 1
    widget.CurVal = state
    if state then
        main.config.widgetAttributes[index + 1].CanShow = true
    else
        main.config.widgetAttributes[index + 1].CanShow = false
    end
    UpdateCreateMonsterFrame()
end
