local NumPerRow = 18
NumTotal = 252
local LastShortcut = 1
local SelectionType = 0
local CurSelectedColor = "-1"
local CurSelectedIndex = 36
local CurSelectedHistoryIndex = 0
local CurSavableHistoryIndex = 0

local SelectColorCallback = nil
local SelectType = 0

function PaletteFrame_OnLoad()
    getglobal("PaletteFrameTitle"):SetText(GetS(6028), 255, 135, 27);

    getglobal("PaletteFrameTips1"):SetText(GetS(6080), 255,255,255)
    getglobal("PaletteFrameTips2"):SetText(GetS(6081), 255,255,255)

    --初始化颜色列表
    for i=1, NumTotal/NumPerRow do
        for j=1, NumPerRow do
            local index = (i-1)*NumPerRow+j
            local btn = getglobal("PaletteColorBtn"..index)
            local tex = getglobal("PaletteColorBtn"..index.."Bkg")

            if ColorTable[index] ~= "-1" then
                tex:SetColor(_ColorHexString2ArgbByte(ColorTable[index]))
            else
                getglobal("PaletteColorBtn"..index.."Bkg"):Hide()
                getglobal("PaletteColorBtn"..index.."Bkg2"):Show()
            end
            btn:SetPoint("topleft", "PaletteFrameColorListPlane", "topleft", (j-1)*60, (i-1)*60)
            btn:SetClientID(index)
            btn:Show()
        end
    end

    getglobal("PaletteColorBtn"..CurSelectedIndex.."Checked"):Show()

    --初始化历史列表
    for i=1, 5 do
        local btn = getglobal("PaletteColorHistoryBtn"..i)
        local tex = getglobal("PaletteColorHistoryBtn"..i.."Bkg")

        btn:Hide()
        btn:SetClientID(i)
    end

    --CurMainPlayer:setSelectedColor(tonumber(CurSelectedColor, 16))
end

function PaletteFrame_OnEvent()

end

function PaletteFrame_OnShow()
    local curcolor = CurMainPlayer:getSelectedColor()
    if IsDyeableBlockLua(CurMainPlayer:getCurToolID()) then
        if curcolor == -1 then
            getglobal("PaletteFrameCurrentColor"):Hide()
            getglobal("PaletteFrameCurrentColor2"):Show()
        else            
            local r,g,b
            b = curcolor % 256
            g = ((curcolor)/256) % 256
            r = ((curcolor)/(256*256)) % 256
            getglobal("PaletteFrameCurrentColor"):SetColor(r,g,b)
            getglobal("PaletteFrameCurrentColor"):Show()
            getglobal("PaletteFrameCurrentColor2"):Hide()
        end
    end
    --初始化历史列表
    for i = 1, 5 do
        if string.len(HistoryColorTable[i]) > 0 then
            local btn = getglobal("PaletteColorHistoryBtn"..i)
            local tex = getglobal("PaletteColorHistoryBtn"..i.."Bkg")

            getglobal("PaletteColorHistoryBtn"..i.."Checked"):Hide()
            if SelectionType == 1 then
                if (curcolor == -1 and HistoryColorTable[i] == "-1") or (curcolor ~= -1 and curcolor == tonumber(HistoryColorTable[i], 16)) then
                    getglobal("PaletteColorHistoryBtn"..i.."Checked"):Show()
                    CurSelectedHistoryIndex = i
                end
            end

            if HistoryColorTable[i] ~= "-1" then
                tex:SetColor(_ColorHexString2ArgbByte(HistoryColorTable[i]))
                getglobal("PaletteColorHistoryBtn"..i.."Bkg"):Show()
                getglobal("PaletteColorHistoryBtn"..i.."Bkg2"):Hide()
            else
                getglobal("PaletteColorHistoryBtn"..i.."Bkg"):Hide()
                getglobal("PaletteColorHistoryBtn"..i.."Bkg2"):Show()
            end
            btn:Show()
        end
    end

    --初始化初始选择的颜色
    for  i = 1, NumTotal do
        getglobal("PaletteColorBtn"..i.."Checked"):Hide()
        if SelectionType == 0 then
            if (curcolor == -1 and ColorTable[i] == "-1") or (curcolor ~= -1 and curcolor == tonumber(ColorTable[i], 16)) then
                CurSelectedIndex = i
                CurSelectedColor = ColorTable[CurSelectedIndex]
                getglobal("PaletteColorBtn"..i.."Checked"):Show()
            end
        end
    end

    if SelectType == 0 then
        if not getglobal("PaletteFrame"):IsReshow() then
            ClientCurGame:setOperateUI(true);
        end
        HideAllFrame("PaletteFrame", true);
    end
    --LastShortcut = MainPlayerAttrib:getCurShotcut()
    --if LastShortcut == 0 then
    --    CurMainPlayer:setCurShortcut(1)
    --else
    --    CurMainPlayer:setCurShortcut(0)
    --end
end

function PaletteFrame_OnHide()
    if CurSelectedIndex ~= 0 then
        getglobal("PaletteColorBtn"..CurSelectedIndex.."Checked"):Hide()
        CurSelectedIndex = 0
    end
    if CurSelectedHistoryIndex ~= 0 then
        getglobal("PaletteColorHistoryBtn"..CurSelectedHistoryIndex.."Checked"):Hide()
        CurSelectedHistoryIndex = 0
    end

    if string.len(CurSelectedColor) > 0 then
        --比较历史列表中的颜色，如果没有，则保存
        local found = false
        for i=1, 5 do
            if HistoryColorTable[i] == CurSelectedColor then
                found = true
                break
            end
        end
        if not found then
            CurSavableHistoryIndex = CurSavableHistoryIndex + 1
            HistoryColorTable[CurSavableHistoryIndex] = CurSelectedColor
            CurSavableHistoryIndex = CurSavableHistoryIndex % 5
        end
    end

    if SelectColorCallback then
        return
    end

    if not getglobal("PaletteFrame"):IsRehide() then
        ClientCurGame:setOperateUI(false);
    end
     
    SetGunMagazine(0,0)
    ShowMainFrame();
    --CurMainPlayer:setCurShortcut(LastShortcut)
end

function PaletteFrame_OnUpdate()

end

function PaletteColorBtnTpl_OnClick()
    local index = this:GetClientID()
    local btn = getglobal("PaletteColorBtn"..index)
    local tex = getglobal("PaletteColorBtn"..index.."Bkg")

    if CurSelectedIndex ~= 0 then
        getglobal("PaletteColorBtn"..CurSelectedIndex.."Checked"):Hide()
        CurSelectedIndex = 0
    end
    if CurSelectedHistoryIndex ~= 0 then
        getglobal("PaletteColorHistoryBtn"..CurSelectedHistoryIndex.."Checked"):Hide()
        CurSelectedHistoryIndex = 0
    end
    
    CurSelectedIndex = index
    CurSelectedColor = ColorTable[index]
    getglobal("PaletteColorBtn"..CurSelectedIndex.."Checked"):Show()
    UpdateTipsFrame(GetS(6056)..":"..GetColorTipsString(tonumber(CurSelectedColor, 16)), 0)
    SaveCurrentColor()
end

function PaletteColorBtnTpl2_OnClick()
    local index = this:GetClientID()
    local btn = getglobal("PaletteColorHistoryBtn"..index)
    local tex = getglobal("PaletteColorHistoryBtn"..index.."Bkg")

    if CurSelectedIndex ~= 0 then
        getglobal("PaletteColorBtn"..CurSelectedIndex.."Checked"):Hide()
        CurSelectedIndex = 0
    end
    if CurSelectedHistoryIndex ~= 0 then
        getglobal("PaletteColorHistoryBtn"..CurSelectedHistoryIndex.."Checked"):Hide()
        CurSelectedHistoryIndex = 0
    end
    
    CurSelectedHistoryIndex = index
    CurSelectedColor = HistoryColorTable[index]
    getglobal("PaletteColorHistoryBtn"..CurSelectedHistoryIndex.."Checked"):Show()
    UpdateTipsFrame(GetS(6056)..":"..GetColorTipsString(tonumber(CurSelectedColor, 16)), 0)
    SaveCurrentColor()
end

function PaletteFrameSaveBtn_OnClick(save)
	local paletteFrame = getglobal("PaletteFrame");
    paletteFrame:Hide()
    if SelectColorCallback then
        SelectColorCallback(CurSelectedColor)
        SelectColorCallback = nil
    end
end

function ShowPaletteFrame(data)
    local paletteFrame = getglobal("PaletteFrame")
    if not data then
        SelectColorCallback = nil
        SelectType = 0
    else
        SelectColorCallback = data.callback
        SelectType = data.selecttype
    end
    if paletteFrame:IsShown() then
        paletteFrame:Hide()
    else
        paletteFrame:Show()
    end
end

function IsShownPaletteFrame()
	return getglobal("PaletteFrame"):IsShown()
end

function SaveCurrentColor()
    if string.len(CurSelectedColor) > 0 then
        if CurSelectedIndex > 0 then
            SelectionType = 0
        else
            SelectionType = 1
        end

        if SelectColorCallback then
            if CurSelectedColor == "-1" then
                getglobal("PaletteFrameCurrentColor"):Hide()
                getglobal("PaletteFrameCurrentColor2"):Show()
            else            
                getglobal("PaletteFrameCurrentColor"):SetColor(_ColorHexString2ArgbByte(CurSelectedColor))
                getglobal("PaletteFrameCurrentColor"):Show()
                getglobal("PaletteFrameCurrentColor2"):Hide()
            end
        else
            --保存颜色
            if CurSelectedColor == "-1" then
                CurMainPlayer:setSelectedColor(-1)
                SetColoredGunOrEggSelectedColor(-1)

                local toolId = CurMainPlayer:getCurToolID()
                if IsDyeableBlockLua(toolId) then
                    local index = CurMainPlayer:getCurShortcut() + CurMainPlayer:getShortcutStartIndex()
                    local new_blockid= GetDefaultBlockId(toolId)
                    local bp = CurMainPlayer:getBackPack();
                    bp:replaceItem(index, new_blockid,bp:getGridNum(index), -1)
                    if CurWorld and CurWorld:isRemoteMode() then
                        local params = {
                            playerid = CurMainPlayer:getObjId(), 
                            itemid = new_blockid,
                            itemnum=bp:getGridNum(index),
                            userdata="",
                            index = index
                        };
                        SandboxLuaMsg.sendToHost(_G.SANDBOX_LUAMSG_NAME.GLOBAL.REPLACE_GRID_WITH_USERDATASTR, params)
                    end
                end  

                getglobal("PaletteFrameCurrentColor"):Hide()
                getglobal("PaletteFrameCurrentColor2"):Show()
            else            
                CurMainPlayer:setSelectedColor(tonumber(CurSelectedColor, 16))
                SetColoredGunOrEggSelectedColor(tonumber(CurSelectedColor, 16))           

                local toolId = CurMainPlayer:getCurToolID()
                if IsDyeableBlockLua(toolId) then
                    local index = CurMainPlayer:getCurShortcut() + CurMainPlayer:getShortcutStartIndex()
                    local new_blockid,new_blockdata= Color2BlockInfo(tonumber(CurSelectedColor, 16),toolId)
                    local bp = CurMainPlayer:getBackPack();
                    bp:replaceItem(index, new_blockid,bp:getGridNum(index), -1,0,0,nil,tostring(new_blockdata))
                    if CurWorld and CurWorld:isRemoteMode() then
                        local params = {
                            playerid = CurMainPlayer:getObjId(), 
                            itemid = new_blockid,
                            itemnum=bp:getGridNum(index),
                            userdata=tostring(new_blockdata),
                            index = index
                        };
                        SandboxLuaMsg.sendToHost(_G.SANDBOX_LUAMSG_NAME.GLOBAL.REPLACE_GRID_WITH_USERDATASTR, params)
                    end
                end  

                getglobal("PaletteFrameCurrentColor"):SetColor(_ColorHexString2ArgbByte(CurSelectedColor))
                getglobal("PaletteFrameCurrentColor"):Show()
                getglobal("PaletteFrameCurrentColor2"):Hide()
            end

  
        end
    end
 
end

function ShowColorTip(color)
    UpdateTipsFrame(GetS(6056)..":"..GetColorTipsString(color), 0, nil, nil, nil, color)
end

function SetCurSelectedColor(color)
    local colorStr = string.format("%x", color)
    local lackLen = 6 - string.len(colorStr);
    for i=1, lackLen do
        colorStr = "0"..colorStr;
    end
    CurSelectedColor = colorStr
end
