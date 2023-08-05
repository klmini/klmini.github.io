g_pc_checkantiplugin_thread_onoff = true

hasBlackTools = false;
hasBlackToolNames = {};
g_server_black_tools = {};
hasBlackToolTopWindowTitles = {}

g_default_server_black_tools = {
	list = {
		"catch_.me_.if_.you_.can_",  --GameGuardian
		"com.joke.bamenzhushou",  --八门助手
		"cn.mc.sq",  --八门神器
		"com.xxAssistant",  --叉叉助手
		"com.zmngame.woodpecker",  --啄木鸟游戏修改器
		"com.oozhushou",  --圈圈助手
		"com.jbelf.imei",  --尖兵手机修改器
		"com.android.vending.billing.InAppBillingService.LOCK",  --Lucky Patcher
		"com.saitesoft.gamecheater",  --手机游侠
		"com.touch18.player",  --超好玩魔盒
		--"com.muzhiwan.market",  --拇指玩
		"com.huang.hl",  --晃游修改大师
		"com.lizimodifier",  --栗子单机游戏修改器
		"com.paojiao.youxia",  --泡椒修改器
		"com.muzhiwan.gamehelper.memorymanager",  --游戏修改器
		"com.cyjh.gundam",  --游戏蜂窝
		"org.sbtools.gamehack",  --Game Hacker
		"com.xiongmaoxia.gameassistant",  --熊猫侠游戏修改器
		"com.huluxia.gametools",  --葫芦侠
		"com.huluxia.gametools",  --葫芦侠
		"com.huluxia.gametools",  --葫芦侠SVIP版
		"com.lion.market",  --虫虫助手
		"com.psomwjyellhr.wlvqr.e",  --鑫菌修改器
		"com.vavgsbkwtamvm.tudyrr",  --GG修改器
		"com.vkontakte.andro",  --GG修改器a
	},
	{
		checkversion=">=0.15.0",
		{name="GameGuardian", package="catch_.me_.if_.you_.can_"},
		{name="八门助手", package="com.joke.bamenzhushou"},
		{name="八门神器", package="cn.mc.sq"},
		{name="叉叉助手", package="com.xxAssistant"},
		{name="啄木鸟游戏修改器", package="com.zmngame.woodpecker"},
		{name="圈圈助手", package="com.oozhushou"},
		{name="尖兵手机修改器", package="com.jbelf.imei"},
		{name="Lucky Patcher", package="com.android.vending.billing.InAppBillingService.LOCK"},
		{name="手机游侠", package="com.saitesoft.gamecheater"},
		{name="超好玩魔盒", package="com.touch18.player"},
		--{name="拇指玩", package="com.muzhiwan.market"},
		{name="晃游修改大师", package="com.huang.hl"},
		{name="栗子单机游戏修改器", package="com.lizimodifier"},
		{name="泡椒修改器", package="com.paojiao.youxia"},
		{name="游戏修改器", package="com.muzhiwan.gamehelper.memorymanager"},
		{name="游戏蜂窝", package="com.cyjh.gundam"},
		{name="Game Hacker", package="org.sbtools.gamehack"},
		{name="熊猫侠游戏修改器", package="com.xiongmaoxia.gameassistant"},
		--{name="葫芦侠", package="com.huluxia.gametools"},
		{name="虫虫助手", package="com.lion.market"},
		{name="鑫菌修改器", package="com.psomwjyellhr.wlvqr.e"},
		{name="迷你助手", package="com.MiniAssistant"},
	},

	PC_Contents =
	{
		"cheat",
		"迷你辅助",
		"迷你世界辅助",
		"迷你助手",
		"迷你世界助手",
		"AlinFine",
		"LAZW",
		"八门助手",
		"八门神器",
		"叉叉助手",
		"啄木鸟游戏修改器",
		"圈圈助手",
		"尖兵手机修改器",
		"Lucky Patcher",
		"手机游侠",
		"超好玩魔盒",
		"晃游修改大师",
		"栗子单机游戏修改器",
		"泡椒修改器",
		"游戏修改器",
		"游戏蜂窝",
		"Game Hacker",
		"熊猫侠游戏修改器",
		"虫虫助手",
		"鑫菌修改器",
		"残月迷你世界辅助",
		"独龙迷你世界辅助",
		"Mini Word方框透视",
		"迷你外挂",
		"黑白辅助",
		"Mini丶",
		"迷你萌芽",
		"迷你萌芽外挂",
		"独星辅助",
		"迷你世界修改",
		"作弊",
		"修改器",
		"外挂",
		"破解",
		"雨寒",
		"迷你世界极品辅助",
		"迷你世界萌白辅助",
		"韩青迷你世界",
		"迷你盒子",
		"萌白",
		"韩青",
		"栀寒",
		"辅助",
	},
};

function CheckHasCrackTools()
	if _CheckHasCrackTools() then
		MessageBox(4, GetS(3722));
		getglobal("MessageBoxFrame"):SetClientString("");
		return true;
	else
		return false;
	end
end

function CheckPCHasCrackTools()
	local black_tools = g_server_black_tools or g_default_server_black_tools
	if AntiPluginHandle then
		AntiPluginHandle:SetBlackToolsConfigData(JSON:encode(black_tools))
	end

	-- if _CheckPCHasCrackTools() then
	-- 	CrashToolsOutGame(hasBlackToolNames[1] or '');
	-- 	return true;
	-- else
	-- 	return false;
	-- end
end


function _CheckHasCrackTools()
	Log("_CheckHasCrackTools");

	hasBlackTools = false;
	hasBlackToolNames = {};

	local black_tools = g_server_black_tools or g_default_server_black_tools;

	for i = 1, #black_tools do
		local data = black_tools[i];
		Log("CheckVersionMatch: "..ClientMgr:clientVersionStr()..", "..data.checkversion)
		if CheckVersionMatch(ClientMgr:clientVersionStr(), data.checkversion) then

			for j = 1, #data do
				local name = data[j].name;
				local pkgname = data[j].package;
				Log("blacktools: check "..name..": "..pkgname);
				if ClientMgr:CheckAppExist(pkgname) then
					hasBlackTools = true;
					table.insert(hasBlackToolNames, name);
				end
			end

			break;
		end
	end

	return hasBlackTools;
end

-- function _CheckPCHasCrackTools()
-- 	Log("CheckPCHasCrackTools----")
-- 	hasBlackTools = false;
-- 	hasBlackToolNames = {};

-- 	local black_tools = g_server_black_tools or g_default_server_black_tools;
-- 	for i = 1, #black_tools do
-- 		if CheckVersionMatch(ClientMgr:clientVersionStr(), black_tools[i].checkversion) then
-- 			local data = black_tools.PC_List;
-- 			if data ~= nil then
-- 				for j = 1, #(data) do
-- 					local name = data[j].name;
-- 					local pkgname = data[j].process;
-- 					Log("blacktools: check "..name..": "..pkgname);
-- 					if ClientMgr:CheckAppExist(pkgname) then
-- 						hasBlackTools = true;
-- 						table.insert(hasBlackToolNames, name);
-- 					end
-- 				end
-- 			end
-- 			break;
-- 		end
-- 	end

-- 	return hasBlackTools;
-- end

-- function GetPCCrackToolsContent()
-- 	hasBlackToolTopWindowTitles = {};
-- 	local black_tools = {}
-- 	if not g_server_black_tools or (not next(g_server_black_tools)) then
-- 		black_tools = g_default_server_black_tools
-- 	else
-- 		black_tools = g_server_black_tools
-- 	end
-- 	--black_tools = g_default_server_black_tools
-- 	for i = 1, #black_tools do
-- 		if CheckVersionMatch(ClientMgr:clientVersionStr(), black_tools[i].checkversion) then
-- 			local pccontent = black_tools.PC_Contents;
-- 			if pccontent ~= nil then
-- 				hasBlackToolTopWindowTitles = pccontent
-- 			end
-- 		end
-- 	end
-- 	if AntiPluginHandle then
-- 		AntiPluginHandle:SetBackToolsConfigData(JSON:encode(hasBlackToolTopWindowTitles))
-- 	end
-- end

-- function CheckExistPCCrackToolsByProcessPath(processPath)
-- 	hasBlackTools = false;
-- 	local function trim(s)
-- 		return (string.gsub(s, "^%s*(.-)%s*$","%1"))
-- 	end
-- 	if processPath and processPath ~= "" then
-- 		processPath = trim(processPath)
-- 		processPath = string.lower(processPath)
-- 	else
-- 		return hasBlackTools
-- 	end
-- 	if hasBlackToolTopWindowTitles and next(hasBlackToolTopWindowTitles) then
-- 		for i = 1,#hasBlackToolTopWindowTitles do
-- 			local s = hasBlackToolTopWindowTitles[i]
-- 			s = trim(s)
-- 			s = string.lower(s)
-- 			local ret = string.find(processPath,s)
-- 			if ret then
-- 				hasBlackTools = true;
-- 				return hasBlackTools
-- 			end
-- 		end
-- 	end
-- 	return hasBlackTools
-- end

-- function CheckExistPCCrackToolsByParam(crack_content)
-- 	hasBlackTools = false;
-- 	--去除头尾的空格
-- 	local function trim(s)
-- 		return (string.gsub(s, "^%s*(.-)%s*$","%1"))
-- 	end
-- 	if crack_content and crack_content ~= "" then
-- 		crack_content = trim(crack_content)
-- 		crack_content = string.lower(crack_content)
-- 	else
-- 		return hasBlackTools
-- 	end
-- 	if hasBlackToolTopWindowTitles and next(hasBlackToolTopWindowTitles) then
-- 		for i = 1,#hasBlackToolTopWindowTitles do
-- 			local s = hasBlackToolTopWindowTitles[i]
-- 			s = trim(s)
-- 			s = string.lower(s)
-- 			local ret = string.find(crack_content,s)
-- 			if ret then
-- 				hasBlackTools = true;
-- 				CrashToolsOutGame(crack_content or '');
-- 				return hasBlackTools
-- 			end
-- 		end
-- 	end
-- 	return hasBlackTools
-- end

function WWW_file_get_black_tools()
	Log("call WWW_file_get_black_tools");
	local file_name_, download_  = getLuaConfigFileInfo( "black_tools" );

	Log("blacktools: load default");
	g_server_black_tools = g_default_server_black_tools;

	if gFunc_isStdioFileExist(file_name_) then
		Log("blacktools: load from cache");
		g_server_black_tools = safe_string2table( gFunc_getSmallFileTxt( file_name_, ns_http.sec ) );
	end

	Log("downloading black_tools lua from: "..download_);
	ns_http.func.downloadLuaConfig( file_name_, download_, ns_data.cf_md5s['black_tools'],  WWW_file_get_black_tools_callback, "cdn" );      --拉取安全黑名单config
end

function WWW_file_get_black_tools_callback( server_data_ )
	Log("call WWW_file_get_black_tools_callback")
	Log("blacktools: load from server")
	g_server_black_tools = server_data_ or {}

	if ClientMgr:isMobile() then
		CheckHasCrackTools()
	elseif g_pc_checkantiplugin_thread_onoff then
		CheckPCHasCrackTools()
	end
end

function ReportCrackToolsInfo()
	Log("ReportCrackToolsInfo");
	if ClientMgr:isMobile() and  _CheckHasCrackTools() then
		for i = 1, #hasBlackToolNames do
			StatisticsTools:gameEvent("CheckCrackTools", "name", hasBlackToolNames[i]);
		end
	else
		-- for i = 1, #hasBlackToolNames do
		-- 	statisticsGameEvent(10000,"%s","PC_CheckCrackTools","%s",hasBlackToolNames[i]);
		-- end
	end
end

function OnPCCheatingPluginFound(pluginName)
	if pluginName == nil then
		pluginName = ""
	end
	
	if hasBlackToolNames and #hasBlackToolNames == 0 then
		hasBlackToolNames[1] = pluginName;
	end
	
	CrashToolsOutGame(pluginName)
end
