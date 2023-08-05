--在有开发者福利活动的时候, 下载地图,下载资源需要上报福利服务器做下载计数统计
DeveloperWelfareReport = {}

DeveloperWelfareReport.define = {
	CheckApi = {
		':playAdvertising',
		-- 'playAdvertisingTask',
	}
}

-- 检查是调用广告api
function DeveloperWelfareReport:checkFileContent(content, fileFullPath)
	-- print("checkFileContent:" .. fileFullPath)
	
	for _, key in ipairs(self.define.CheckApi) do
		if string.find(content, key) then
			return true
		end
	end
	
	return false
end

-- 遍历目录下所有脚本文件, 查看脚本文件是否调用广告api
function DeveloperWelfareReport:LoadMapScriptPathList(dirpath, findlist, pathEx)
	pathEx = pathEx or ""
	local env = utils.env
	local isSet = false
	for _, findinfo in ipairs(findlist) do
		if findinfo.isdir then
			local dirname = findinfo.name
			local fullpath = dirpath .. dirname .. '/' .. pathEx
			local sstype = ScriptSupportSetting:nameToType(dirname)
			if not sstype or not next(sstype) then
				return
			end

			local fileList = ScriptSupportCtrl:findFromDir(fullpath)
			if fileList then
				for _, fileinfo in ipairs(fileList) do
					if not fileinfo.isdir and not string.find(fileinfo.name, 'config') then
						local fileFullPath = fullpath .. fileinfo.name
						local content = ScriptSupportSetting:readFile(fileFullPath)
						
						if self:checkFileContent(content, fileFullPath) then
							if env == 1 then
								-- ShowGameTips(fileinfo.name .. "调用了 广告Api")
								print(fileinfo.name .. "调用了 广告Api")
							end
							
							isSet = true
						end
					end
				end
			end

			if isSet then
				break
			end
		end
	end

	return isSet
end

-- 扫描data\wxxxx\ss目录
function DeveloperWelfareReport:LoadMapScriptPath(owid)
	local dirpath = ScriptSupportSetting:getScriptDirPath(owid)
	local findlist = dirpath and ScriptSupportCtrl:findFromDir(dirpath)
	if not findlist then
		return false
	end

	return self:LoadMapScriptPathList(dirpath, findlist)
end

function DeveloperWelfareReport:LoadMapScript_ModPacket(owid)
	local dirpath = "data/w" .. tostring(owid) .. "/modpkg/"
    local findlist = dirpath and ScriptSupportCtrl:findFromDir(dirpath)
    if not findlist then
        return
    end

	return self:LoadMapScriptPathList(dirpath, findlist, "ss/trigger/")
end

-- 获取地图的触发器跟脚本 中是否有 调用广告api
function DeveloperWelfareReport:GetMapScriptSetByOwid(owid)

	local isSet = self:LoadMapScriptPath(owid)
	isSet = isSet or self:LoadMapScript_ModPacket(owid)
	isSet = isSet and 1 or 0

	return isSet
end

-- 检查开发者商店是否设置了道具
function DeveloperWelfareReport:GetMapDeveloperStoreSetByOwid(owid)
	local num = 0
	local uin = AccountManager:getUin()
	-- local code, list = AccountManager:dev_mapstore_get_itemlist(uin, owid, false)
	local code, list = GetInst("DevelopStoreDataManager"):SyncGetMapStoreItemList(uin, owid, false)
	if code == ErrorCode.OK then
		num = #list
	end

	return num > 0 and 1 or 0
end

-- 检查重生规则设置的是自动重生还是手动重生
function DeveloperWelfareReport:GetMapReviveSetByOwid(owid)
	local option = CSMgr:getMapReviveSet(owid)
	return option == 71 and 1 or 0
end

function DeveloperWelfareReport:resavePaySet(owid)
	if not ActivityMainCtrl or not ActivityMainCtrl:CheckDeveloperWelfareOpen() then
		return
	end

	if not owid then
		return
	end
	
	local curVal = CSMgr:loadSetPay(owid)
	CSMgr:saveSetPay(owid, 0, self:GetMapScriptSetByOwid(owid))

	-- 商店
	CSMgr:saveSetPay(owid, 2, self:GetMapDeveloperStoreSetByOwid(owid))

	-- 复活广告
	CSMgr:saveSetPay(owid, 4, self:GetMapReviveSetByOwid(owid))
	local newrVal = CSMgr:loadSetPay(owid)
	print("curVal, newrVal", curVal, newrVal)
end

--上报福利服务器地图下载
function DeveloperWelfareReport:reportDownMap(fromowid)
	if not ActivityMainCtrl or not ActivityMainCtrl:CheckDeveloperWelfareOpen() then
		return
	end

	local worldDesc = AccountManager:findWorldDesc(fromowid)
	if not worldDesc then
		return
	end
	local curVal = CSMgr:loadSetPay(worldDesc.worldid)

	local uploadTime = worldDesc.shareVersion
	local author_uin = worldDesc.realowneruin
	if not ActivityMainCtrl:CheckDeveloperWelfareOpen(uploadTime) then
		return
	end

	if author_uin == AccountManager:getUin() then
		return
	end

	--develop_download表示下载普通地图，develop_pay_download表示下载[Desc3]地图，
	local mapType = curVal > 0 and "develop_pay_download" or "develop_download"
	local param = {}
	param.developer = author_uin
	param.map_type = mapType
	param.mapid = fromowid
	

	self:report(param)
end

-- 上报福利服务器资源下载
function DeveloperWelfareReport:reportDownResource(skuid)
	if not ActivityMainCtrl or not ActivityMainCtrl:CheckDeveloperWelfareOpen() then
		return
	end

	--develop_chosen_download表示下载精选资源
	local skuInfo = GetInst("ResourceService"):GetSkuInfo(skuid)
	if not skuInfo then
		print("reportDownResource not skuInfo ....")
		return 
	end

	if skuInfo.rank ~= 2 then
		return
	end

	if not ActivityMainCtrl:CheckDeveloperWelfareOpen(skuInfo.id) then
		return
	end
	if skuInfo.uin == AccountManager:getUin() then
		return
	end

	local param = {}
	param.developer = skuInfo.uin
	param.map_type = "develop_chosen_download"
	param.mapid = skuid

	self:report(param)
end


function DeveloperWelfareReport:report(param)
	local url_ = g_http_root .. "miniw/php_cmd?act=download_map_report&"..http_getS1(AccountManager:getUin())
	for key, value in pairs(param) do
		url_ = string.format("%s&%s=%s", url_, key, tostring(value))
	end

	ns_http.func.rpc(url_, nil, nil, nil, ns_http.SecurityTypeHigh)   --ma
end
