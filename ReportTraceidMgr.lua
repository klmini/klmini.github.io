local ReportTraceidMgr = {

}

ReportTraceidMgr.def_sp_traceids = {
	["team"] = true,
}

ReportTraceidMgr.cache_traceid_stack = {}

function ReportTraceidMgr:setTraceid(traceid)
	if "string" == type(traceid) then		
		self.cache_traceid_stack = {traceid}

		if ReportMgr and ReportMgr.setTraceid then
			ReportMgr:setTraceid(self.cache_traceid_stack[#self.cache_traceid_stack] or "")
		end
	end
end

function ReportTraceidMgr:pushTraceid(traceid)
	if "string" == type(traceid) then
		for index = #self.cache_traceid_stack, 1, -1 do
			if traceid == self.cache_traceid_stack[index] then
				table.remove(self.cache_traceid_stack, index)
			end
		end

		table.insert(self.cache_traceid_stack, traceid)

		if ReportMgr and ReportMgr.setTraceid then
			ReportMgr:setTraceid(traceid)
		end
	end
end

function ReportTraceidMgr:popTraceid(traceid)
	if "string" == type(traceid) then
		local isTop = false
		for index = #self.cache_traceid_stack, 1, -1 do
			if traceid == self.cache_traceid_stack[index] then
				isTop = isTop or (index == #self.cache_traceid_stack)
				table.remove(self.cache_traceid_stack, index)
			end
		end

		if isTop then
			if ReportMgr and ReportMgr.setTraceid then
				ReportMgr:setTraceid(self.cache_traceid_stack[#self.cache_traceid_stack] or "")
			end
		end
	end
end

function ReportTraceidMgr:PackWholeTraceid(traceid)
	traceid = tostring(traceid or "")

	local temp = string.split(traceid, "#") or {}
	local base = self.cache_traceid_stack[#self.cache_traceid_stack] or ""
	table.insert(temp, 1, base)

	local ret = {}
	for index, value in ipairs(temp) do
		if "" ~= value then
			table.insert(ret, value)
		end
 	end
	return table.concat(ret, "#")
end

_G.ReportTraceidMgr = ReportTraceidMgr;