local SIGNALPARSER_GRID_MAX = 256;
local LINE_BTN_MAX = 8;
local LINE_MAX = 7;
local LEFT_LINE_MAX = 96;

local InstructionTitle ="";
local InstructionValue = 0.2;
local InstructionTable = "";
local InstructionSwitchTable ="";



--指令集排列
local valueTable = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

-- 指令集开关
local switchTable = {0,0,0,0,0,0,0,0}

function SignalParserFrame_OnLoad()
	--排列布局 start
	--中间指令格子
	for i=1,SIGNALPARSER_GRID_MAX/8 do
		for j=1,8 do
			local item = getglobal("SignalParserBoxItem"..((i-1)*8+j));
			-- local itemColor = getglobal("SignalParserBoxItem"..((i-1)*8+j).."Y");
			item:SetPoint("topleft", "SignalParserBoxPlane", "topleft", (j-1)*92+21+16+50+2, (i-1)*76+12);
			item:SetSize(54,54);
		end
	end

	--上方指令格子
	for i=1,LINE_BTN_MAX/8 do
		for j=1,8 do
			local linebtn = getglobal("SignalParserFrameLayout"..((i-1)*8+j));
			local uv = getglobal("SignalParserFrameTopBoxIndexUV"..((i-1)*8+j));
			local btn = getglobal("SignalParserFrameTopBoxIndexB"..((i-1)*8+j));
			linebtn:SetPoint("topleft", "SignalParserFrameTopBkg", "topleft", (j-1)*92+30, (i-1)*76+3);
			uv:SetPoint("topleft","SignalParserFrameTopBkg", "topleft", (j-1)*92, (i-1)*94-2);
			btn:SetPoint("topleft", "SignalParserFrameTopBkg", "topleft", (j-1)*92+35, (i-1)*94+8);
		end
	end

	-- 上方与中间的分割线
	for i=1,LINE_MAX/7 do
		for j=1,7 do
			local topLine = getglobal("SignalParserFrameTopBoxT"..((i-1)*7+j));
			local centerLine = getglobal("SignalParserFrameTopBoxC"..((i-1)*7+j));
			topLine:SetPoint("topleft", "SignalParserFrameTopBkg", "topleft", (j-1)*92+98, (i-1)*74+2);
			topLine:SetSize(2,46);
			centerLine:SetPoint("topleft", "SignalParserFrameTopBkg2", "topleft", j*92+6, (i-1)*74+5);
			centerLine:SetSize(2,281);
		end
	end

	-- 左侧数字、横线
	for i=1,LEFT_LINE_MAX/3 do
		local number = getglobal("SignalParserBoxN"..i);
		number:SetPoint("topleft", "SignalParserBoxPlane", "topleft", 0, (i-1)*76+28);
		local leftLine = getglobal("SignalParserBoxS"..i);
		leftLine:SetPoint("topleft", "SignalParserBoxPlane", "topleft", 6, (i)*76);
		leftLine:SetSize(38,2);
		local centerHLine = getglobal("SignalParserBoxL"..i);
		centerHLine:SetPoint("topleft", "SignalParserBoxPlane", "topleft", 70, (i)*76);
		centerHLine:SetSize(738,2);
	end
	-- 排列布局 end


	InstructionTable = TableToStr(valueTable);
	InstructionSwitchTable=TableToStr(switchTable);


	WirelessYGLayout();


	
end

function SignalParserFrame_OnShow()
	--读取数据
	local grid = CurMainPlayer:getBackPack():index2Grid(CurMainPlayer:getCurShortcut() + CurMainPlayer:getShortcutStartIndex())
    local str = grid:getUserdataStr()

	-- SignalParserFrameClearBtn_OnClick()

	if string.len(str) > 0 then
        InstructionTitle,InstructionValue, InstructionTable,InstructionSwitchTable= InstructionParse(str);

        local table = StrToTable(InstructionTable);
        local stable = StrToTable(InstructionSwitchTable);
	    for k,v in ipairs(valueTable) do
	    	valueTable[k] = table[k];
	    end 
	    for k,v in ipairs(switchTable) do
	    	switchTable[k] = stable[k];
	    end 
    end


    --指令集开关
    for k,v in ipairs(switchTable) do
		local btn = getglobal("SignalParserFrameTopBoxIndexB"..k);
		local uv = getglobal("SignalParserFrameTopBoxIndexUV"..k);
		if  switchTable[k] == 0 then
			btn:Hide();
			uv:Hide();
		else
			btn:Show();
			uv:Show();
		end


		for i=1,32 do
			if btn:IsShown() then
				getglobal("SignalParserBoxItem"..k):Disable();
				k=k+8;
			else
				getglobal("SignalParserBoxItem"..k):Enable();
				k=k+8;
			end
		end
	end

    --标题
	getglobal("SignalParserFrameTitle"):SetText(InstructionTitle);

	--解析速度值
	 local valFont = getglobal("SignalParserFrameModelScaleVal");
	 local val = tonumber(string.format("%.1f", InstructionValue/10));
	 if val <0.2 then
	 	val = 0.2
	 end
	 valFont:SetText(val.. GetS(6283));

	 getglobal("SignalParserFrameModelScaleBar"):SetValue(25*InstructionValue-40);


	--提示
	local bkg =getglobal("SignalParserFrameHelpBtnBkg");
	local tips= getglobal("SignalParserFrameHelpBtnTips");
	if bkg:IsShown() then
		bkg:Hide();
		tips:Hide();
	end


	--刷新界面
	InstructionLabelBtn_UpdateUV();
	getglobal("SignalParserBox"):setCurOffsetY(0);

	if not getglobal("SignalParserFrame"):IsReshow() then
        ClientCurGame:setOperateUI(true);
    end
	HideAllFrame("SignalParserFrame", true);
end

--黄色指令覆盖
function WirelessYGLayout()
	for i=1,8 do
		for j=1,i do
			local instructionID = getglobal("SignalParserFrameLayout"..i.."Y"..j);
			instructionID:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
			instructionID:SetTexUV("btn_min_instructi_h");
		end
	end
end




function SignalParserFrame_OnHide()

	if not getglobal("SignalParserFrame"):IsRehide() then
       ClientCurGame:setOperateUI(false);
    end

	ShowMainFrame();


end


function SignalParserFrame_OnClick()
	getglobal("SignalParserFrameHelpBtnBkg"):Hide();
	getglobal("SignalParserFrameHelpBtnTips"):Hide();
end


function SignalParserFrameClearBtn_OnClick()
	InstructionTitle =""
	InstructionUin = 0
	InstructionAuthor = ""
 	InstructionTable = ""


 	valueTable = nil;



end


function SignalParserAnalysisSpeedTemplateBar_OnValueChanged()
    local value = this:GetValue();
    local width = math.floor(328*(value/100))

    getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
    getglobal(this:GetName().."Pro"):SetWidth(width);

    local valFont = getglobal(this:GetParent().."Val");


    local multiple = 0.2 +  string.format("%.1f", value/270);



	if multiple < 0.2 then
  		multiple = 0.2;
  	end

  	if multiple > 0.6 then
  		multiple = 0.6;
  	end


  	valFont:SetText(multiple .. GetS(6283));

  	InstructionValue = multiple * 10;

end

function SignalParserAnalysisSpeedTemplateLeftBtn_OnClick()
	local value = getglobal(this:GetParent() .. "Bar"):GetValue();
	local ratio = 20;
	
	value = value - ratio;
	getglobal(this:GetParent().."Bar"):SetValue(value);
end

function SignalParserAnalysisSpeedTemplateRightBtn_OnClick()
	local value = getglobal(this:GetParent() .. "Bar"):GetValue();
	local ratio = 20;
	value = value + ratio;
	getglobal(this:GetParent().."Bar"):SetValue(value);

end




function SignalParserFrameResetBtn_OnClick()
	MessageBox(5,GetS(1099));
	getglobal("MessageBoxFrame"):SetClientString("指令集重置");
end

function InstructionSetReset()
	if next(valueTable) ~= nil then
		for k,v in ipairs(valueTable) do
			valueTable[k] = 0;
		end
	end
	if next(switchTable) ~= nil then
		for k,v in ipairs(switchTable) do
			switchTable[k] = 0;
		end
	end

	for i=1,8 do
		getglobal("SignalParserFrameTopBoxIndexB"..i):Hide();
		getglobal("SignalParserFrameTopBoxIndexUV"..i):Hide();
	end

	for j=1,256 do
		getglobal("SignalParserBoxItem"..j):Enable();
	end




	local itable = TableToStr(valueTable);
	local stable = TableToStr(switchTable);
	local t = {title=InstructionTitle, value=string.format("%d",InstructionValue), itable=itable, stable=stable};
    local str = JSON:encode(t);
    
    --local str = InstructionTitle.."|"..string.format("%d",InstructionValue).."|"..itable.."|"..stable;
    if not str then
        CurMainPlayer:writeInstruction(CurMainPlayer:getCurShortcut() + CurMainPlayer:getShortcutStartIndex(), "")
    else
        CurMainPlayer:writeInstruction(CurMainPlayer:getCurShortcut() + CurMainPlayer:getShortcutStartIndex(), str)
    end

    --刷新手上指令
    CurMainPlayer:setCurShortcut(MainPlayerAttrib:getCurShotcut());

	InstructionLabelBtn_UpdateUV();
end

function SignalParserFrameCloseBtn_OnClick()
	getglobal("SignalParserFrame"):Hide();

	local grid = CurMainPlayer:getBackPack():index2Grid(CurMainPlayer:getCurShortcut() + CurMainPlayer:getShortcutStartIndex())
    local str = grid:getUserdataStr()


	if string.len(str) > 0 then
        InstructionTitle, InstructionValue,InstructionTable,InstructionSwitchTable= InstructionParse(str);

        local table = StrToTable(InstructionTable);
	    for k,v in ipairs(valueTable) do
	    	valueTable[k] = table[k];
	    end 

	    local stable = StrToTable(InstructionSwitchTable);
	    for k,v in ipairs(switchTable) do
	    	switchTable[k] = stable[k];
	    end
    end



    for k,v in ipairs(valueTable) do
    	valueTable[k] = 0;
    end 

    for k,v in ipairs(switchTable) do
    	switchTable[k] = 0
    end

    

    InstructionTitle="";
    InstructionValue = 0.2;
	-- InstructionUin = 0
	InstructionTable = ""
end


function SignalParserFrameHelpBtn_OnClick()
	local bkg =getglobal("SignalParserFrameHelpBtnBkg");
	local tips= getglobal("SignalParserFrameHelpBtnTips");
	if bkg:IsShown() then
		bkg:Hide();
		tips:Hide();
	else
		bkg:Show();
		tips:Show();
	end
end



function WirelessLabelBtn_OnClick()
	local n = string.sub(this:GetName(),-1,-1);
	local btn = getglobal("SignalParserFrameTopBoxIndexB"..n);
	local uv = getglobal("SignalParserFrameTopBoxIndexUV"..n);

	local number = tonumber(n);
	if not btn:IsShown() then
		btn:Show();
		uv:Show();
		switchTable[number] = 1;	
	else

		btn:Hide();
		uv:Hide();
		switchTable[number] = 0;	
	end

	for i=1,32 do
		if btn:IsShown() then
			getglobal("SignalParserBoxItem"..n):Disable();
			n=n+8;
		else
			getglobal("SignalParserBoxItem"..n):Enable();
			n=n+8;
		end
	end

end



function InstructionLabelBtn_OnClick()
	local n = string.sub(this:GetName(),20,-1);
	n = tonumber(n);

	for k,v in ipairs(valueTable) do
		if n==k then
			if valueTable[n] == 1 then
				valueTable[n] = 0
			else
				valueTable[n] = 1
			end
		end
	end
	InstructionLabelBtn_UpdateUV();
end

--刷新红黄指令颜色
function InstructionLabelBtn_UpdateUV()

	-- local table = StrToTable(InstructionTable);
	for k,v in ipairs(valueTable) do
		local instructionUV = getglobal("SignalParserBoxItem"..k.."Y");
		instructionUV:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
		if valueTable[k] == 1 then
			instructionUV:SetTexUV("btn_instruct_h");
		elseif valueTable[k] == 0 then
			instructionUV:SetTexUV("btn_instruct_n");
		end
	end
end

-- 标题
function SignalParserTitle_OnFocusLost()
    if getglobal("SignalParserFrameTitle"):IsShown() then
    	InstructionTitle = ReplaceFilterString(this:GetText())
    	InstructionTitle = LuaReomve(InstructionTitle," ");  --去掉空格
	    if Utf8StringLen(InstructionTitle) > 10 then        
	        InstructionTitle = Utf8StringSub(InstructionTitle, 10)
	        ShowGameTips(GetS(3244), 3)
	    end
	    this:SetText(InstructionTitle)
    end
end


-- 保存
function SignalParserFrameSaveBtn_OnClick(flag)
	    -- 保存数据
    if flag then
    	local itable = TableToStr(valueTable);
    	local stable = TableToStr(switchTable);

    	local itable = TableToStr(valueTable);
		local stable = TableToStr(switchTable);
		local t = {title=InstructionTitle, value=string.format("%d",InstructionValue), itable=itable, stable=stable};
	    local str = JSON:encode(t);
    
    --local str = InstructionTitle.."|"..string.format("%d",InstructionValue).."|"..itable.."|"..stable;
    	if not str then
            CurMainPlayer:writeInstruction(CurMainPlayer:getCurShortcut() + CurMainPlayer:getShortcutStartIndex(), "")
        else
            CurMainPlayer:writeInstruction(CurMainPlayer:getCurShortcut() + CurMainPlayer:getShortcutStartIndex(), str)
        end

        --刷新手上指令
        CurMainPlayer:setCurShortcut(MainPlayerAttrib:getCurShotcut())
        getglobal("SignalParserFrame"):Hide()

    else
        getglobal("SignalParserFrame"):Hide()
    end

    for k,v in ipairs(valueTable) do
    	valueTable[k] = 0;
    end 

    for k,v in ipairs(switchTable) do 
    	switchTable[k] = 0;
    end
    InstructionTitle=""
	InstructionValue = 0.2
	InstructionTable = ""
	InstructionSwitchTable= ""
end


function InstructionParse(str)
    local InstructionValue = 0.2
    local InstructionTitle = ""
    local InstructionTable = ""
    local InstructionSwitchTable = ""

    local t = JSON:decode(str);
    if t and type(t) == "table" then
--        print("kekeke LettersParse:", str, t);
        if t.title  then
            InstructionTitle = t.title;
        end

        if t.value and tonumber(t.value) then
            InstructionValue = tonumber(t.value);
        end

        if t.itable then
            InstructionTable = t.itable;
        end

        if t.stable then
            InstructionSwitchTable = t.stable;
        end
     else  
	    while (str ~= nil and string.len(str) > 0) do
	        local pos_beg = 1
	        local pos_end = string.find(str, "|")
	        if pos_end == nil then
	            break
	        end
	        InstructionTitle = string.sub(str, pos_beg, pos_end-1);


	        pos_beg = pos_end+1
	        pos_end = string.find(str, "|", pos_beg)
	        if pos_end == nil then
	            break
	        end
	        InstructionValue = tonumber(string.sub(str, pos_beg, pos_end-1),10);
	        

	        pos_beg = pos_end+1
	        pos_end = string.find(str, "|", pos_beg)
	        if pos_end == nil then
	            break
	        end
	        InstructionTable = string.sub(str, pos_beg, pos_end-1)


	        pos_beg = pos_end+1
	        InstructionSwitchTable = string.sub(str, pos_beg)
	        break
	    end
	end

    return InstructionTitle, InstructionValue,InstructionTable,InstructionSwitchTable
end



function SignalParserFrame_OnEvent()
	-- InstructionLabelBtn_UpdateUV();
end



local m_SignalProducerState = {GetS(21118),GetS(21100),GetS(21101),GetS(21102),GetS(21103),GetS(21104),GetS(21105)}
local m_SignalReceiverState = {GetS(21119),GetS(21106),GetS(21107),GetS(21108),GetS(21109),GetS(21110),GetS(21111)}
local m_SignaInterpreterState = {GetS(21120),GetS(21112),GetS(21113),GetS(21114),GetS(21115),GetS(21116),GetS(21117)}

function SignalStateTips(number,blockId,isRemoteMode)

	-- if (not IsRoomOwner() and not isRemoteMode) or (IsRoomOwner() and not isRemoteMode) then
	if blockId == 1052 then
		UpdateTipsFrame(m_SignalProducerState[number+1],0);
	elseif blockId == 1053 then
		UpdateTipsFrame(m_SignalReceiverState[number+1],0);
	elseif blockId == 1054 then
		UpdateTipsFrame(m_SignaInterpreterState[number+1],0);
	end
	-- end
	
end


function ToStringEx(value)
    if type(value)=='table' then
       return TableToStr(value)
    elseif type(value)=='string' then
        return "\'"..value.."\'"
    else
       return tostring(value)
    end
end



function TableToStr(t)
    if type(t) ~='table' then 
		return "" 
	end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..ToStringEx(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..ToStringEx(key).."]="..ToStringEx(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..TableToStr(getmetatable(key)).."*e".."="..ToStringEx(value)
                else
                    retstr = retstr..signal..key.."="..ToStringEx(value)
                end
            end
        end

        i = i+1
    end

     retstr = retstr.."}"
     return retstr
end



function StrToTable(str)
    if str == nil or type(str) ~= "string" then
        return
    end
    
    return loadstring("return " .. str)()
end


function LuaReomve(str,remove)
    local lcSubStrTab = {}
    while true do
        local lcPos = string.find(str,remove)
        if not lcPos then
            lcSubStrTab[#lcSubStrTab+1] =  str    
            break
        end
        local lcSubStr  = string.sub(str,1,lcPos-1)
        lcSubStrTab[#lcSubStrTab+1] = lcSubStr
        str = string.sub(str,lcPos+1,#str)
    end
    local lcMergeStr =""
    local lci = 1
    while true do
        if lcSubStrTab[lci] then
            lcMergeStr = lcMergeStr .. lcSubStrTab[lci] 
            lci = lci + 1
        else 
            break
        end
    end
    return lcMergeStr
end



function StringToTable(s)
    local tb = {}






    for utfChar in string.sub(s, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(tb, utfChar)
    end
    
    return tb
end