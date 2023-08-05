local function __tostring(value, indent, vmap)
    --{{{
    local str = ''
    indent = indent or ''
    vmap = vmap or {}

    if (type(value) ~= 'table') then
        if (type(value) == 'string') then
            
            if string.byte(value,1) == 91 then 
                str = string.format("'%s'", value)
            else
                if value:match('%[') then 
                    str = string.format('"%s"', value)
                else
                    str = string.format("[[%s]]", value)
                end 
            end 

        else
            str = tostring(value)
        end
    else
        if type(vmap) == 'table' then
            if vmap[value] then return '('..tostring(value)..')' end
            vmap[value] = true
        end
        local auxTable = {}
        local iauxTable = {}
        local iiauxTable = {}
        for i, v in pairs(value) do
            if type(i) == 'number' then
                if i == 0 then
                    table.insert(iiauxTable, i)
                else
                    table.insert(iauxTable, i)
                end
            else
                table.insert(auxTable, i)
            end
        end 

        table.sort(iauxTable)

        str = str..'{\n'
        local separator = ""
        local entry = "\n"
        local barray = true
        local kk,vv
        for i, k in ipairs (iauxTable) do 
            if i == k and barray then
                entry = __tostring(value[k], indent..'    ', vmap)
                str = str..separator..indent..'    '..entry
                separator = ", \n"
            else
                barray = false
                table.insert(iiauxTable, k)
            end
        end 
        for i, fieldName in ipairs (iiauxTable) do 
            kk = tostring(fieldName)
            if type(fieldName) == "number" then kk = '['..kk.."]" end 
            if type(fieldName) == "string" and (fieldName:match("%.") or fieldName:match("-")) then kk = '["'..kk..'"]' end 
            entry = kk .. " = " .. __tostring(value[fieldName],indent..'    ',vmap)

            str = str..separator..indent..'    '..entry
            separator = ", \n"
        end 
        for i, fieldName in ipairs (auxTable) do 
            kk = tostring(fieldName)
            if type(fieldName) == "number" then kk = '['..kk.."]" end 
            if type(fieldName) == "string" and (fieldName:match("%.") or fieldName:match("-"))then kk = '["'..kk..'"]' end 

            vv = value[fieldName]
            entry = kk .. " = " .. __tostring(value[fieldName],indent..'    ',vmap)


            str = str..separator..indent..'    '..entry
            separator = ", \n"
        end 
        str = str..'\n'..indent..'}'
    end
    return str
    --}}}
end
table.tostring =  __tostring

deep_copy_table = function(obj)
	if type(obj) == 'table' then
		local temp = {}
		for k, v in pairs(obj) do
			if not v then
				temp[k] = nil
			else
				temp[k] = deep_copy_table(v)
			end
		end
		return temp
	elseif type(obj) == 'string' or type(obj) == 'number' or type(obj) == 'boolean' then
		return obj
	end
end