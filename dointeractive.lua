local contentall = ''; 
function SendDoLuaUIFrameChat()
    --{{{
	local content = getglobal("DoluaChatEdit"):GetText();
	if content == nil or content == "" then return end
	getglobal("DoluaChatEdit"):Clear();

    local gm = container and container.servicemap and container.servicemap.client and container.servicemap.client.gm
    if gm then 
        local cmd, arg_string = content:gmatch('([^%s]+)%s?(.*)')()
        if cmd == 'clear' then 
            contentall = ''
            UpdateDoluaChatBox();
            return
        else
            gm:exec(cmd, arg_string)
        end 
    end 
    content = content.."#n\n\n";
    local time = "("..os.date("%Y", os.time()).."-"..os.date("%m", os.time()).."-"..os.date("%d", os.time()).." "..os.date("%X", os.time())..")";
    content = time..":#n\n"..content;
    contentall = contentall..content;
    UpdateDoluaChatBox();
    --}}}
end		

function UpdateDoluaChatBox()
    --{{{
	local chatRich = getglobal("DoluaChatBoxContent");
	chatRich:SetText(contentall, 255, 255, 255);
	
	local lines = chatRich:GetTextLines();
	if lines <= 16 then
		getglobal("DoluaChatBoxPlane"):SetSize(640, 500);
		getglobal("DoluaChatBoxContent"):SetSize(640, 500);
	else
		getglobal("DoluaChatBoxPlane"):SetSize(640, 500+(lines-16)*31);
		getglobal("DoluaChatBoxContent"):SetSize(640, 500+(lines-16)*31);
	end

	getglobal("DoluaChatBoxPlane"):SetPoint("bottom", "DoluaChatBox", "bottom", 0, 0);
	if lines <= 16 then
		getglobal("DoluaChatBox"):setCurOffsetY(0);
	else
		getglobal("DoluaChatBox"):setCurOffsetY(-(lines-16)*31);
	end
    --}}}
end	

local log = nil

function DoluaUIFrame_OnShow()
    --{{{ 重定向print
    log = _G.print
    contentall = ''
    _G.print = function (...)
        --{{{
        local a = {...}
        local m = ''
        for i, v in ipairs (a) do 
            if type(v) == 'table' then 
                local ss = table.tostring and table.tostring(v) or tostring(v)
                if #ss > 8000 then ss = string.sub(ss, 1, 8000) end 
                m = m .. ss .. ' ' 
            else
                local ss = tostring(v)
                if #ss > 8000 then ss = string.sub(ss, 1, 8000) end 
                m = m .. ss .. ' ' 
            end 
        end 
        --m = m .. '\n@@@@@@@@@Lua@@@@@@\n'
        --{{{

        if #m >= 8*1024 then m = string.sub(m, 1, 8*1024 - 1) end 
        if #contentall >= 32*1024 then contentall = '' end 
        contentall = contentall .. m .. '\n'
        UpdateDoluaChatBox()
        --}}}
        --}}}
    end 
    --print('DoluaUIFrame_OnShow')
    --}}}
end 
function DoluaUIFrame_OnHide()
    --{{{重定向print
    if log then _G.print = log end 
    --print('DoluaUIFrame_OnHide')
    --}}}
end 
