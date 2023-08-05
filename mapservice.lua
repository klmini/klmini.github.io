
mapservice = {
	--搜索
	searchingUin = -1,
	searchedMaps = {},

	searchResultsPulledHttp = false,

	-- 工坊搜索类型 1：地图  2：作者或uin
	--searchType = 1, --取值受if_open_word_search()控制，用元表来实现，省的四处写
	--搜索地图类型
	searchMapType = 1,
	searchMapId =1,
	--上一次搜索的记录
	searchLastList = {},
	--历史搜索记录
	-- searchRecordMap ={}, --兼容旧版本 放到元表里面处理

	limit_search_user_maps = {},  --搜索玩家地图频率限制

	--首页
	pullingMainPage = false,
	mainPageDataPulled = false,

	pullingMainSpecialMaps = false,
	mainSpecialMapsPulled = false,

	mainPictures = {},

	--LLDO:每周推荐
	mainWeeklyMaps = {},
	mainWeeklyMapRander = nil,
	mainWeeklyMapsTitle = {},

	--主页鉴赏家推荐
	mainExpertMaps = {},
	mainExpertMapRander = nil,
	mainExpertMapsTitle = {},

	--LLDO:置顶
	mainTopSet = {};

	mainLatestMaps = {},
	mainLatestMapRander = nil,
	mainLatestMapsTitle = {},

	mainHotMaps = {},
	mainHotMapRander = nil,
	mainHotMapsTitle = {},

	mainRecommendMaps = {},
	mainRecommendRander = nil,
	mainRecommendTitle = nil,

	--鉴赏家优选
	mainOptimalMaps = {},
	mainOptimalRander = nil,
	mainOptimalTitle = nil,

	--精选地图
	mainFeaturedGameplayMaps = {},
	mainFeaturedGameplayRander = nil,
	mainFeaturedGameplayTitle = nil,

	pullingDailyMaps = false,
	mainDaily = {},

	--LLTODO:好友在玩
	mainFriendPlay = {},
	mainFriendPlayOwids = {},
	mainFriendPlayTitle = {},

	--鉴赏家区
	pullingExpertMaps = false,
	expertMaps = {},
	expertOrderNames = nil,

	--精选
	pullingChosenMaps = false,
	chosenMaps = {},
	chosenOrderNames = nil,

	--审核区
	pullingReviewMaps = false,
	reviewMaps = {},
	reviewOrderNames = nil,

	--玩家地图区
	pullingPlayerMaps = false,
	playerMaps = {},
	playerOrderNames = nil;

	--玩家地图 活动/比赛版块
	pullingActivityMaps = false,
	activityMaps = {},

	curActivityType = 0;
	curActivityId = nil;
	curActivityName = "";

	--我的收藏
	pullingCollectMaps = false,
	collectMapAllOwids = {},
	collectMapPullingIndex = 1,
	collectMapsAll = {},
	collectSandboxRefreshEvt = "Map_Service_Collect_Refresh",

	collectMaps = {},
	collectMapsCurLabel = nil,
	collectOrderNames = nil,
	addingCollectMap = nil,
	removingCollectMap = nil,

	--查找的收藏
	pullingSearchCollectMaps = false,
	searchCollectMaps = {},
	searchCollectMapAllOwids = {},
	searchCollectMapPullingIndex = 1,

	--专题列表
	topics = {},
	topicsPulled = false,

	curTopic = nil,
	curTopicMaps = {},

	--材质包
	materialmods = {},
	materialmodsPulled = false,

	unlockedModUuids = {},
	unlockedModsPulling = false,
	unlockedModsPulled = false,
	unlockedModsWaitingUuids = {},

	unlockingMaterialMods = false,

	--查找的评测地图列表
	pullingSearchExpertMaps = false,
	searchExpertMaps = {},
	searchExpertAllMaps = {},
	searchExpertAllOwInfo = {},
	curExpertLabelOwids = {},
	searchExpertMapPullingIndex = 1,

	--邀请评测地图列表
	pullingExpertTaskMaps = false,
	expertTaskMaps = {},
	expertTaskMapsAllOwids = {},

	--下载
	downloadingMapOwid = nil,
	downloadingMapFromOwid = nil,
	downloadingMapProgress = 0,

	downloadLimit = 99,  --今天还可以下载多少个地图
	downloadLimitPulling = false,
	downloadLimitPulled = false,

	--收藏、点赞、分享数量缓存数据
	collect_list = {},
	like_list = {},
	share_list = {},

	addLikeMapOwid = 0,
	cancelLikeMapOwid = 0,
	addDislikeMapOwid = 0,

	addCollectMapOwid = 0,
	cancelCollectMapOwid = 0,


	--通用的批量下载地图缩略图接口
	curDownloadingThumbnail = nil,
	curDownloadingCountdown = nil,
	waitDownloadThumbnails = {},
	thumbnailDefaultTexture = "ui/snap_empty.png",
	thumbnailServers = {},  --e.g."http://map%d.mini1.cn/map/"
	downloadThumbnailRoot = "data/http/thumbs/", --下载后写入路径png

	--通用的批量获取地图信息接口
	mapInfoCache = {},
	--记录自己的地图信息，用于提取图片封禁信息
	selfMapInfoList = {},
	selfMapInfoListBindUin = 0,

	net_flow = {},    --流控
	
	wait_down = {};		--等待下载的
	
	getserver = function()
		return CSMgr:getHttpMapServer();
	end,

	--buginfo的上传地址
	getserver_buginfo = function()
		if  isAbroadEvn() then
			return "http://hwshequ.mini1.cn:8087/"
		else
			return "http://indevelop.mini1.cn:8087/"
		end
	end,

	--下载的地图列表 盒子那边用的
	mapFromWidList = {};

	--存档申诉的缓存
	mapAppealList = {},

	--存档信息
	mapInfoList = {},

	--记录地图话题信息，因为地图list太散了，取的时候根本不知道放到哪里去，所以在这里统一存取
	mapTopicList = {},
	--点踩上报记录地图owid
	map_report_cid = 0,

	map_info_trans_cache = {},

	map_allcloud_support_cache = {
		check_wait_owids = {},
		check_gen = nil,
		map_support_info = {},
	},

	mapActDataUpdateTime = {},
	--点赞状态数据缓存
	mapLikeState_cache = {},
}


--使用元表来存储受控的属性，省的四处写开关判断
local mapserviceExKeys = {		
	-- 工坊搜索类型 1：地图  2：作者或uin
		searchType = 1, --取值受if_open_word_search()控制，用元表来实现，省的四处写
		searchRecordMap = {},
	}
setmetatable(mapservice, {
	__index = function(t, key)
		if "searchType" == key then
			return mapserviceExKeys.searchType
		elseif "searchRecordMap" == key then
			return mapserviceExKeys.searchRecordMap
		else
			rawget(t, key)
		end
	end,
	__newindex = function(t, key, v)
		if "searchType" == key then
			if if_open_word_search and not if_open_word_search() then
				mapserviceExKeys.searchType = 2
			else
				mapserviceExKeys.searchType = v
			end
		elseif "searchRecordMap" == key then
			mapserviceExKeys.searchRecordMap = {}
			if type(v) == "table" then
				for index, value in ipairs(v) do
					value[3] = value[3] or 1
					table.insert(mapserviceExKeys.searchRecordMap, value)
				end
			end
		else
			rawset(t, key, v)
		end
	end
})

local function reverseTable(tab, si, ei)
	local tlen = #tab
	local tmp
	if si > 0 and ei > si and si <= tlen and ei <= tlen then
		while si < ei do
			tmp = tab[si]
			tab[si] = tab[ei]
			tab[ei] = tmp

			si = si + 1
			ei = ei - 1
		end
	end
end

function MapServiceInit()

	Log("MapServiceInit");

	CheckIosOverseaForGuangDongGamers()

	ReqMapConfig();

	--索引与服务器order相同: 1=random 2=download_count 3=week_download_count 4=score
	mapservice.chosenOrderNames = {
		GetS(3852),
		GetS(3845),
		GetS(3846),
		GetS(3847),
	};

	--random, 日下载, score
	mapservice.reviewOrderNames = {
		GetS(3852),
		GetS(4040),
		GetS(3847),
	};

	mapservice.playerOrderNames = {
		GetS(3852)
	};

	mapservice.collectOrderNames = {
		GetS(3852)
	};

	mapservice.expertOrderNames = {
		GetS(3852)
	};

	math.randomseed(os.time());

	mapservice.searchType = 1
		--Reward
	SandboxLua.eventDispatcher:CreateEvent(nil, "UPDATE_REWARD")
	--收藏刷新
	SandboxLua.eventDispatcher:CreateEvent(nil, "UPDATE_COLLECT")
	--初始化点赞
	SandboxLua.eventDispatcher:CreateEvent(nil, "INIT_LIKESTATE")
	--点赞
	SandboxLua.eventDispatcher:CreateEvent(nil, "ADD_LIKE")
	--取消点赞
	SandboxLua.eventDispatcher:CreateEvent(nil, "CANCEL_LIKE")
	--添加不喜欢
	SandboxLua.eventDispatcher:CreateEvent(nil, "ADD_DISLIKE")
	--取消不喜欢
	SandboxLua.eventDispatcher:CreateEvent(nil, "CANCEL_DISLIKE")
	--更新分享数量
	SandboxLua.eventDispatcher:CreateEvent(nil, "UPDATE_SHARECOUNT")
	--更新关注转态
	SandboxLua.eventDispatcher:CreateEvent(nil, "UPDATE_FOCUSSTATE")
	
    SandboxLua.eventDispatcher:CreateEvent(nil, mapservice.collectSandboxRefreshEvt)
end

function MapServiceOnSwitchAccount()
	mapservice.pullingChosenMaps = false;
	mapservice.pullingReviewMaps = false;
	mapservice.pullingPlayerMaps = false;
	mapservice.pullingCollectMaps = false;
	mapservice.pullingExpertMaps = false;
	mapservice.topicsPulled = false;

	mapservice.pullingSearchCollectMaps = false;
	mapservice.pullingSearchExpertMaps = false;
	mapservice.pullingExpertTaskMaps = false;

	mapservice.materialmods = {};
	mapservice.materialmodsPulled = false;

	mapservice.unlockedModUuids = {};
	mapservice.unlockedModsPulling = false;
	mapservice.unlockedModsPulled = false;
	mapservice.unlockedModsWaitingUuids = {};

	mapservice.unlockingMaterialMods = false;

	mapservice.downloadLimit = 99;
	mapservice.downloadLimitPulling = false;
	mapservice.downloadLimitPulled = false;
	mapservice.mapAppealList = {}
	mapservice.mapInfolList = {}
	mapservice.mapLikeState_cache = {}
end

function SetMapServers(urls)
	if #(mapservice.thumbnailServers)==0 then
		mapservice.thumbnailServers = urls;
	end

	if CSOWorld:getDownloadServerNum()==0 then
		for i = 1, #urls do
			Log("addDownloadServer '"..urls[i].."'");
			CSOWorld:addDownloadServer(urls[i]);
		end
	end

	if  RoomSyncResMgr:getDownloadServerNum() == 0 then
		for i = 1, #urls do
			RoomSyncResMgr:addDownloadServer(urls[i]);
		end
	end
end

function CheckUinLogin(disableTips)
	local havelogin = false;

	if _G.check_use_new_server() then
		if AccountManager:isLogin() then
			havelogin = true;
		else
			if AccountManager:data_update()==0 then
				havelogin = true;
			else
				havelogin = false;
			end
		end
		if (AccountManager:getUin() or 0) < 1000 then
			havelogin = false;
		end
	else
		havelogin = (AccountManager:getUin() or 0)>=1000;
	end
	
	if havelogin then
		return true;
	else
		if not disableTips then
			ShowGameTips(GetS(3272), 3);
		end
		return false;
	end
end

function CheckUin()
	local havelogin = false;

	Log("CheckUin()");

	if _G.check_use_new_server() then
		if AccountManager:isLogin() then
			havelogin = true;
		else
			if AccountManager:data_update()==0 then
				havelogin = true;
			else
				havelogin = false;
			end
		end
		if (AccountManager:getUin() or 0) < 1000 then
			havelogin = false;
		end
	else
		havelogin = (AccountManager:getUin() or 0)>=1000;
	end

	if havelogin then
		return true;
	else
		ShowGameTips(GetS(3272), 3);
		return false;
	end
	--if (AccountManager:getUin() or 0)>=1000 then
	--	return true;
	--else
	--	ShowGameTips(GetS(3272), 3);
	--	return false;
	--end
end

--服务器列表
function ReqMapConfig()
	Log("ReqMapConfig");

	local url = mapservice.getserver().."/miniw/map/?act=get_map_config";
	url = UrlAddAuth(url);
	Log("  url = "..url);

	ns_http.func.rpc(url, RespMapConfig, nil, nil, ns_http.SecurityTypeHigh);  --map
end

function RespMapConfig(ret)
	Log("RespMapConfig");

	if CheckHttpRpcRet(ret, true)==false then
		return;
	end
	
	if ret and  ret.urls then
		SetMapServers(ret.urls);
	end
end

--上传地图多语言配置
function MapUploadMultilingual(owid)
	local MapMultilingual = GetInst("MapMultilingual")
	if owid and MapMultilingual and MapMultilingual.UploadMapMultilingual then
		MapMultilingual:UploadMapMultilingual(owid)
	end
end

--上传地图
function UploadMap(owid, open, archiveType, worldName, text, activity, canrecord, MultiLangName, MultiLangDesc)

	if not CheckUin() then
		return;
	end

	local MapMultilingual = GetInst("MapMultilingual")
 	if MapMultilingual and MapMultilingual:CheckMpaNeedUpload(owid) then	
 		MapMultilingual:AddMpaMultilingual(owid, {Name = { textList = JSON:decode(MultiLangName).textList}, Desc = { textList = JSON:decode(MultiLangDesc).textList} })
	end

	return AccountManager:requestOpenOWorld(owid, open, archiveType, worldName, text, activity, canrecord, MultiLangName, MultiLangDesc);
end


--预计上传地图，请求上传地址
function getUploadPreUrl( fn_wid, open)
	if  fn_wid and #fn_wid > 7 then
		local url_ =  mapservice.getserver() .. "/miniw/map/?act=upload_pre&v=3&fn=".. fn_wid .. addUploadNodeInfo();
		local owid = string.sub(fn_wid, 2, #fn_wid)
		if type(open) == 'number' and (open == 1 or open == 2) then
			url_ = url_.."&open="..open
		end

		--增加手机号验证
		local long_url_ = url_addParams(url_) .. "&" .. http_getRealNameMobileSum()

		long_url_ = UrlAddAuth(long_url_);
		long_url_ = ns_http_sec.encodeS7Url( long_url_ );    --encode
		return long_url_
	else
		return ""
	end	
end

--增加成就值信息
function addUploadAchieveInfo()
	local ret_ = ""
	if ns_data.self_total_achieve and ns_data.self_total_achieve > 0 then
		local check_sum_str_ = "_" .. ns_data.self_total_achieve
		ret_ = "&tk1=" .. ns_data.self_total_achieve .. '&tks=' .. ns_http_sec.get_tk_sum(check_sum_str_)
	end
	return ret_
end

--增加npc商店统计信息
function addUploadNpcShopInfo(wid)
	local ret_ = ""
	--1.带商店的生物插件数 = hasShopNum
	--2.生物商店总商品数 = skuNumSum
	--3.生物商店广告开关打开状态下总商品数 = showADNumSum
	local hasShopNum = 0
	local skuNumSum = 0
	local showADNumSum = 0

	local npcList = {}
	if wid and ModEditorMgr:ensureMapHasDefualtMod(wid) then
		local inGame = ClientCurGame and ClientCurGame:isInGame()
		local loaded = false
		if not inGame then
			loaded = ModMgr:loadWorldMods(wid)
		end
		local currentModCount = ModMgr:getMapModCount()
		for i = 1, currentModCount do
			local moddesc = ModMgr:getMapModDescByIndex(i-1);
			local uuid = moddesc.uuid;
			local mod = ModMgr:getMapModByUUID(uuid);
			local allShopNum = mod:GetNpcShopDefSize()--带商店的生物插件数
			for i = 1, allShopNum do	
				local def = mod:GetNpcShopDefByIndex(i-1)
				if def then
					local skuNum = def:getSkuSize();
					local shopID = def.iShopID
					local showADNum = 0
					if skuNum > 0 then
						for i = 0, skuNum-1 do
							local skuDef = def:getNpcShopSkuDefByIdx(i)
							local iShowAD = skuDef.iShowAD;
							if iShowAD == 1 then--开了广告
								showADNum = showADNum + 1
							end
						end
					end
					skuNumSum = skuNumSum + skuNum
					showADNumSum = showADNumSum + showADNum

					local has = false
					for _, value in ipairs(npcList) do
						if value == def.sInnerKey then
							has = true
						end
					end
					if not has then
						table.insert(npcList, def.sInnerKey)
					end
				end
			end
		end
		
		if loaded then
			ModMgr:unLoadCurMods(wid,false)
		end
	end
	hasShopNum = #npcList
	ret_ = "&npcshop_ad=" .. tostring(hasShopNum) .. '&npcshop_item=' .. tostring(skuNumSum) .. '&npcshop_aditem=' .. tostring(showADNumSum)
	return ret_
end
--增加介绍图信息
function addUploadAchieveIntroPics()
	local ret_ = ""
	local intropics = GetCurIntroPics();
	if intropics and #intropics > 0 then
		ret_ = "&intropics=";
		for i = 1 , #intropics do
			local filepath = intropics[i];
			local begin = string.find(filepath, "/intropics/");
			local filename = string.sub(filepath, begin+11);
			if #intropics == i then
				ret_ = ret_ .. filename;
			else
				ret_ = ret_ .. filename .. ',';
			end
		end
	end
	return ret_
end

--设置上传结果 upload_ret
function getUploadRetUrl( params_, isRentDebugMode )
	if  params_ and #params_ > 32 then
		-- 增加有无设置广告字段
		if SSMgr_HasAdv then
			local hasadv = SSMgr_HasAdv(params_)
			if hasadv ~= nil then
				params_ = params_ .. '&hasadv='..hasadv
			end
		end
		local wid = g_UploadRetWid 
		local plmode = nil
		local pl = nil
		local para = {}
		if wid ~= 0 then
			if CSOWorldMgr then
				plmode = CSOWorldMgr:GetWDescExtValue(wid, "TeamSetType")
				pl = CSOWorldMgr:GetWDescExtValue(wid, "TeamSetMaxNum")
			end
			g_UploadRetWid = 0
			if GetInst("MapFileParseInterface") and  GetInst("MapFileParseInterface").GetUpatePara then
				para =GetInst("MapFileParseInterface"):GetUpatePara(wid)
			end

		end
		plmode = plmode or 1
		pl = pl or 0

		local add = addUploadAchieveIntroPics();
		local add2 = addUploadNpcShopInfo(wid);
		local url_ =  mapservice.getserver() .. "/miniw/map/?act=upload_ret&v=3&".. params_ .. addUploadAchieveInfo()..add..add2.."&plmode="..plmode.."&pl="..pl;

		local thumb_status = GetInst("ShareArchiveInterface"):GetThumbStatus(wid)
		if thumb_status and type(thumb_status) == 'number' then
			url_ = url_.."&thumb_status="..thumb_status
		end

		local totalTryPlayTime = GetInst("ShareArchiveInterface"):GetTryPlayTime(wid)
		if totalTryPlayTime and type(totalTryPlayTime) == 'number' then
			local is_tested = 0 -- 0未做测试  1做了测试
			if totalTryPlayTime > 0 then
				is_tested = 1
			end
			url_ = url_.."&is_tested="..is_tested
			url_ = url_.."&test_time="..totalTryPlayTime
		end

		if isRentDebugMode then
			url_ = url_ .. "&debug=1"
		else
			local shareArchive = GetInst("UIManager"):GetCtrl("ShareArchive");
			if shareArchive and shareArchive.model and shareArchive.model.GetWillUpTag then
				local willTagInfo = GetInst("UIManager"):GetCtrl("ShareArchive").model:GetWillUpTag(wid)
				if willTagInfo and "string" == type(willTagInfo.totalStrs) and "" ~= willTagInfo.totalStrs then
					url_ = url_ .. "&tag_list=" .. willTagInfo.totalStrs
				end
			end
		end
		for k,v in pairs(para) do
			url_=url_.."&"..k.."="..tostring(v)	
		end

		--添加是否设置为云服字段
		if wid ~= 0 then
			local isSetBeCloud = 0
			if CSOWorldMgr then
				isSetBeCloud = CSOWorldMgr:GetWDescExtValue(wid, "cloudMapSwitch")==1 and 1 or 0
			end
			print("--getUploadRetUrl--isSetBeCloud=", isSetBeCloud)
			url_=url_.."&cloud="..isSetBeCloud
		end
		print("--getUploadRetUrl--url_=", url_)
		local long_url_ = url_addParams(url_);
		long_url_ = UrlAddAuth(long_url_) .. "&" .. http_getRealNameMobileSum()
	    

		long_url_ = ns_http_sec.encodeS7Url( long_url_ );    --encode
		return long_url_
	end	
	return ""
end

--获取官方模板
function getOfficialTemplate()
	ShowLoadLoopFrame(true, "file:mapservice -- func:getOfficialTemplate");
	local url = mapservice.getserver().."/miniw/map/?act=get_official_map_template";
	url = UrlAddAuth(url);

	local RespOfficialTemplate = function(ret,userdata)
		ShowLoadLoopFrame(false);
		if not ret then
			ShowGameTipsWithoutFilter(GetS(1000710));
			return;
		end
		if ret.ret ~= 0 then
			return;
		end
		if ret.list == nil or #ret.list == 0 then
			return;			
		end

		local function GetMapDetailResp(maps, userdata)
			if type(maps) ~= "table" then
				ShowGameTipsWithoutFilter(GetS(1000710));
				maps = {};
			end
			table.insert(maps, 1, {UseOldDevelopMode="true", name=GetS(1000709)})
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/common_comp", "miniui/miniworld/compose", "miniui/miniworld/c_miniwork"});
    		GetInst("MiniUIManager"):OpenUI("GameTemplatePanel", "miniui/miniworld/ugc_game_template", "GameTemplatePanelAutoGen", maps);
		end	
		ReqMapInfo(ret.list, GetMapDetailResp, nil , {'normal', 'select'}, true);
	end;

	ns_http.func.rpc(url, RespOfficialTemplate, nil,nil, ns_http.SecurityTypeHigh)   --map
end

--获取官方模板
function getOfficialRankTemplateList()
	local function GetRankTemplateListCb(maps, reqInfo)
		if maps == nil or reqInfo == nil or reqInfo.label == nil or reqInfo.buyType == nil or reqInfo.order == nil then
            return;
        end
		if type(maps) ~= "table" or #maps == 0 then
			ShowGameTipsWithoutFilter(GetS(1000710));
			maps = {};
		end
		table.insert(maps, 1, {UseOldDevelopMode="true", name=GetS(1000709)})

		local gameTemplatePanelAutoGen = GetInst("MiniUIManager"):GetUI("GameTemplatePanelAutoGen");
		if gameTemplatePanelAutoGen and gameTemplatePanelAutoGen.ctrl then
			gameTemplatePanelAutoGen.ctrl.model:SetIncomingParam(maps);
			gameTemplatePanelAutoGen.ctrl:RefreshList();
		else
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/common_comp", "miniui/miniworld/compose", "miniui/miniworld/c_miniwork"});
			GetInst("MiniUIManager"):OpenUI("GameTemplatePanel", "miniui/miniworld/ugc_game_template", "GameTemplatePanelAutoGen", maps);
		end
	end	

	GetInst("MiniWorksService"):ReqMapTemplateData(1, 1, 3, GetRankTemplateListCb);
end

--处理上传结果（ok不处理）
function lua_respUpload(ret, owid, isRentDebugMode)
	print("lua_respUpload ", ret)
	if string.find(ret, "fail:filter") then
		ShowGameTipsWithoutFilter(GetS(10546), 3)
		AccountManager:requestAbortOpenWorld(owid);
	elseif string.find(ret, "fail:check_score") then
		--开关限制不允许分享
		ShowGameTipsWithoutFilter(GetS(339), 3)
	elseif string.find(ret, "fail:need_uin_auth") then
		ShowGameTipsWithoutFilter(GetS(100255), 3)
	elseif string.find(ret, 'fail:checking') then
		ShowGameTipsWithoutFilter(GetS(25810), 3)
	elseif string.find(ret, "fail:need_uin_mobile") then
		ShowGameTipsWithoutFilter(GetS(100254), 3)
	elseif string.find(ret, "fail:map_list_limit") then
		ShowGameTipsWithoutFilter(GetS(32020), 3)
	elseif string.find(ret, "fail:noRealNameMobile00") or string.find(ret, "fail:noRealNameMobile01") then
		ShowGameTipsWithoutFilter(GetS(22037), 3)
	elseif string.find(ret, "fail:noRealNameMobile10") then
		ShowGameTipsWithoutFilter(GetS(10643), 3)
	elseif string.find(ret, "fail:studio info error") then
		MessageBox(5, GetS(60116), function(btn)
			if btn == 'left' then
				if owid then CSOWorld:reqAfterUpload(owid) end 
			end
		end)
	else
		ShowGameTips(GetS(100254), 3)
	end

	--xyang
	ShareArchive_MapUploadFailed(owid, isRentDebugMode)

	-- 上传失败错误日志，定位原因
	owid = owid or ""
	ret = ret or "nil"
	GetInst("ReportGameLuaErrorManager"):AddErrorToCache("lua_respUpload failed" .. ", owid:" .. owid .. ",ret:" .. ret)
end

--增加就近node信息
function addUploadNodeInfo()
	local ret_ = ""
	if  ns_data.node_info and ns_data.node_info.n then
		ret_ = "&n=" .. ns_data.node_info.n
	end
	return ret_
end


--预计上传临时文件，请求上传地址
function getUploadTempPreUrl( type_ )
	if  type_ == "time" then
		local url_ =  mapservice.getserver() .. "/miniw/map/?act=upload_pre_time" .. addUploadNodeInfo();
		local long_url_ = url_addParams(url_);
		long_url_ = UrlAddAuth(long_url_);
		--Log( "call lua getUploadTempPreUrl url2=" .. long_url_ )
		long_url_ = ns_http_sec.encodeS7Url( long_url_ );    --encode
		return long_url_
	elseif type_ == "plugin" then
		local url_ =  mapservice.getserver() .. "/miniw/map/?act=upload_pre_plugin&ext=zip" .. addUploadNodeInfo();
		local long_url_ = url_addParams(url_);
		long_url_ = UrlAddAuth(long_url_);
		--Log( "call lua getUploadTempPreUrl url2=" .. long_url_ )
		long_url_ = ns_http_sec.encodeS7Url( long_url_ );    --encode
		return long_url_
	else
		Log("ERROR: unknow type_")
		assert(0);
	end
	return ""
end



--设置下载结果--------------------------------------
g_download_ret_where = {}
function setDownloadWhere( from_wid_, where_ )
	if  from_wid_ and where_ then
		local ret_, fromowid_ = check_wid2( from_wid_ )
		if  ret_ then		
			g_download_ret_where[ fromowid_ ] = where_
		end
	end
end

function getDownloadRetUrl( from_wid_ )	
	if  from_wid_ and #from_wid_ >= 7 then
		--assert(g_download_ret_where[from_wid_]);    --打开这里查找遗漏点
		from_wid_ = "w"..from_wid_

		local url_ =  mapservice.getserver() .. "/miniw/map/?act=download_ret&v=2&fn=".. from_wid_;
		
		Log("call getDownloadRetUrl")
		
		local ret_, fromowid_ = check_wid2(from_wid_);
		if  g_download_ret_where[fromowid_] then
			url_ = url_ .. "&where=" .. g_download_ret_where[ fromowid_ ]
		end

		local long_url_ = UrlAddAuth(url_)--url_addParams(url_);
		-- long_url_ = UrlAddAuth(long_url_);
		-- long_url_ = ns_http_sec.encodeS7Url( long_url_ );    --encode

		g_download_ret_where[ from_wid_ ] = nil
		return long_url_
	end
	
	return ""
end

--通知服务器下载成功
function ReqDownloadRet(from_wid_)
	local url = getDownloadRetUrl(from_wid_)
	if url == "" then return end

	--记录下下载时间
    local t_ = GetInst("lobbyDataManager")
    if t_ and t_.AddDownloadTime then
        GetInst("lobbyDataManager"):AddDownloadTime(from_wid_, os.time())        
    end

	ns_http.func.rpc(url, RespDownloadRet, from_wid_,nil, ns_http.SecurityTypeHigh)   --map

	-- 向福利服上传下载地图记录
	if DeveloperWelfareReport then
		DeveloperWelfareReport:reportDownMap(from_wid_)
	end	
end

function RespDownloadRet(ret, userdata)
	if CheckHttpRpcRet(ret, true)==false then return end
	
	if ret and ret.ret ~= nil and ret.ret == 0 then
		if ret.msg and ret.msg == "ok1" then--这里表示是开发者通行证收费地图
			AccountManager:syncWorldDesc(userdata, 1)
		elseif ret.is_creator ~= nil and ret.is_creator >= 1 then--这里表示是开发者地图
			AccountManager:syncWorldDesc(userdata, 2)
		end
	end
end

--撤销审核地图
function ReqUnChecking(url,owid)
	if url == "" or owid == "" then return end
	local num_owid = tonumber(owid)
	local function RspUnChecking(ret,owids)
		if ret and string.find(ret, 'ok') then
			ShowGameTips(GetS(10652), 3);
		else
			ShowGameTips(GetS(10653), 3);
		end
		ReqSyncWorldListFromServer(AccountManager:getUin(),owids)
	end
	ns_http.func.rpc_string_raw(url,RspUnChecking,{num_owid}, nil)
end

function PauseUploadMap(owid)
	AccountManager:requestPauseOpenWorld(owid);
end

function ContinueUploadMap(owid)

	if not CheckUin() then
		return;
	end

	AccountManager:requestContinueOpenWorld(owid);
end



--下载地图失败， 打印报错
function lua_respDownload( error_code,  progress, url_, owid_, retry_, task_id_ )
	Log( "call lua_respDownload code=" .. error_code .. "|" .. (progress or 'nil') .. "|" ..
	     ( url_ or "nil" ) .. "|" .. ( owid_ or "nil" ) .. "|"  .. ( retry_ or 'nil' ) )

	if  retry_ and retry_ > 0 then
		--正在重试
	else
		local txt_ =  "";
		if     'error_md5'           == error_code then
			txt_ = GetS(9090)          -- 下载失败:地图校验出错
		elseif 'error_unzip'         == error_code then
			txt_ = GetS(9091)		   -- 下载失败:地图解压出错
		elseif 'error_update'        == error_code then
			txt_ = GetS(9092)          -- 下载失败:地图检测出错
		elseif 'error_httpcode'      == error_code then
			txt_ = GetS(9093)		   -- 下载失败:地图文件不存在
		elseif 'error_file_no_found' == error_code then
			txt_ = GetS(9094)          -- 下载失败:地图文件未能找到
		else   
			-- error_unknow
			txt_ = GetS(3851)          -- 地图下载失败
		end	
		if reportMapDownloadEvent then
			local standby3 = error_code or "error_other"
			local tb = {
				standby3 = standby3 .. "#" .. tostring(progress),
				button_state = url_,
			}
			reportMapDownloadEvent(owid_,"download_error",nil,nil,nil,tb)
		end
        if MessageBox then
            MessageBox(4, txt_ .. ":" ..  (progress or "") );            
        end
	end

	--上报错误
	if  progress and url_ then
		lua_http_error_report( "download", progress, url_, (owid_ or ""), task_id_ )
	end
	
end


--上报地图成功
function lua_respDownload_ok( url_, owid_, task_id_ )
	local cacheRptInfo = {}
	if reportMapDownloadEvent then
		local tb = {
			button_state = url_,
		}
		cacheRptInfo = reportMapDownloadEvent(owid_,"download_ok",nil,nil,nil,tb) or {}
	end
	lua_http_ok_report( "download_ok", url_, (owid_ or ""), task_id_ )

    if NewBattlePassEventOnTrigger then
        NewBattlePassEventOnTrigger("downloadmap");        
    end

	if "table" ~= type(cacheRptInfo.tb) then
		cacheRptInfo.tb = {}
	end
    if ClientMgr:isPureServer() == false then        
        local sceneInfo = {
            scene_id = cacheRptInfo.sid,
            card_id = cacheRptInfo.cid,
            comp_id = cacheRptInfo.oid,
            trace_id = ReportTraceidMgr:PackWholeTraceid(cacheRptInfo.tb.trace_id),
        }
        SafeCallFunc(GetInst("ArchiveLobbyDataManager").AddOrUpNativeStoreRecord, GetInst("ArchiveLobbyDataManager"), owid_, false, sceneInfo)
    end                
end

function CheckArchiveCapTip()
	if GetInst("mainDataMgr"):AB_NewArchiveLobbyMain() then
		local totalKB = GetInst("ArchiveLobbyDataManager"):GetTotalWorldDescSizeKB() --kb
		local settingCap = GameSetArchiveCap_GetValue() --mb
	
		if settingCap <= totalKB/1024 then
			ShowGameTipsWithoutFilter(GetS("29013"))
		end
	end
end

function DownloadMap(map, options)

	if not CheckUin() then
		return false;
	end

	local function startDownload( map )
		if map then
			--LLTODO:上报玩家喜好(下载)
			add_map_prefs( map.label, 1 );

			if map then
				--记录下下载时间
				GetInst("lobbyDataManager"):AddDownloadTime(map.owid, os.time())
			end

			options = options or {};

			Log("DownloadMap: owid="..map.owid..", download_count="..map.download_count..", from_tdr="..tostring(map.from_tdr));

			if map.client_ver>0 and ClientMgr:getVersionParamInt("DownMapCheckCltVer", 1) == 1 then
				if math.floor(map.client_ver / 256.0) > math.floor(ClientMgr:clientVersion() / 256.0) then
					ShowGameTips(GetS(4028));
					return false;
				end
			end

			local listids = nil
			if ns_version and ns_version.outer_checker_uin and ns_version.outer_checker_uin.list then
				listids = ns_version.outer_checker_uin.list
			end
			local matchuin = ","..AccountManager:getUin()..","
			local checked = (listids and string.find(","..listids..",", matchuin) or false)

			--黑词库与本地敏感词库过滤
			if not checked and (CheckFilterString(map.name..", "..map.memo, false)
					or FilterMgr.GetFilterScore(map.name) or FilterMgr.GetFilterScore(map.memo)) then
				ShowGameTips(GetS(10547), 3)
				return false;
			end

			local btnstate = GetMapDownloadBtnState(map);
			Log("  btnstate.buttontype = "..tostring(btnstate.buttontype));
			SafeCallFunc(CheckArchiveCapTip)
			if btnstate.buttontype == DOWNBTN_DOWNLOAD then  --下载
				-- if map.worldtype ~= 9 and AccountManager:getMyWorldList():getDownWorldNum() >= DownMapMaxNum() then
				if map.worldtype ~= 9 and GetDownArchiveNum() >= DownArchiveMaxNum() then
					ShowGameTips(GetS(28), 3);
					return false;
				end
				
				-- if map.worldtype == 9 and AccountManager:getMyWorldList():getDownRecordNum() >= DownRecordMapMaxNum() then
				if map.worldtype == 9 and GetDownArchiveNum() >= DownArchiveMaxNum() then
					ShowGameTips(GetS(7571), 3);
					return false;
				end

				if  getglobal("MiniWorksFrame"):IsShown() and mapservice.net_flow.wait and mapservice.net_flow.wait > 0 then
				
					if   ClientMgr:getApiId() == 999 then
						--999渠道不受速度限制
						mapservice.net_flow.wait = 2;
					end
					
					if t_ad_data.canShow(12) then
						OnReqWatchADDownMap();
					end
					SetWaitDownMapFrame(map, options, mapservice.net_flow.wait);
					return false;
				else
					ReqDownloadNewMap(map, options);
				end
				
			elseif btnstate.buttontype == DOWNBTN_CONTINUE_DOWNLOAD then  --继续下载
				CSOWorld:ContinueDownloadMap(map);
			end

			return true;
		else
			return false;
		end
	end

	local isauthor = (map.author_uin == AccountManager:getUin());  --自己是原作者
	local owid = map.owid
	--新增白名单判断 
	if isauthor then
		--作者下载忽略禁下白名单的限制
		return startDownload(map)
	else
		if CheckSupportAllCloud_IsSupport(owid) then
			ShowGameTipsWithoutFilter(GetS(7001000))
			return
		end

		--社交大厅地图不让下载
        if GetInst("SocialHallDataMgr") and GetInst("SocialHallDataMgr"):IsSocialMap(owid) then
			ShowGameTips(GetS(7001000));
			return false
        end
		--获取白名单配置
		local whiteList = GetInst("VisualCfgMgr"):GetCfg("WhiteList")
		if whiteList then
			for i, v in ipairs(whiteList.List) do
				if owid == v.ID then
					ShowGameTips(GetS(7001000));
					return false
				end
			end
			return startDownload(map)
		else
			return startDownload(map)
		end
	end
end

function ReqDownloadNewMap(map, options)
	if map and ns_version and ns_version.forceReqMapInDownload==1 then
		local url = mapservice.getserver().."/miniw/map/?act=get_single_map_info&fn="..map.owid;
		url = AddPlayableArg(url)
		url = UrlAddAuth(url);
		ns_http.func.rpc(url, function(ret)
				if CheckHttpRpcRet(ret, true) then
					if ret._k_ == map.owid then
						local servermap = ret.normal or ret.select;
						if servermap then
							map.download_dir = servermap.dir or "";
							map.download_node = tonumber(servermap.node) or 0;
							map.download_md5 = servermap.md5 or "";
						end

						if "number" == type(ret.open_svr) then
							map.opensvr = ret.open_svr
						end
					end		
				end
				OLD_ReqDownloadNewMap(map, options)
			end, nil,nil, ns_http.SecurityTypeHigh);
	else
		OLD_ReqDownloadNewMap(map, options)
	end
end	

function OLD_ReqDownloadNewMap(map, options)
	Log("OLD_ReqDownloadNewMap: "..map.owid);

	if mapservice.downloadLimitPulling then
		return;
	end

	local netState = ClientMgr:getNetworkState()
	if netState == 0 then
		ShowGameTips(GetS(3893), 3)
		return
	end

	local data = {map=map, options=options};

	if options.isqqmap or CSOWorld:isGmCommandsEnabled() then  --qq大厅同步地图、GM账号 都没有限制
		DoDownloadNewMap(data);
	end

	if mapservice.downloadLimitPulled then
		Log("mapservice.downloadLimit = "..mapservice.downloadLimit);
		if mapservice.downloadLimit >= 1 then
			mapservice.downloadLimit = mapservice.downloadLimit - 1;
			DoDownloadNewMap(data);
		else
			ShowGameTips(GetS(4522), 3);
		end

	else
		mapservice.downloadLimitPulling = true;

		local url = mapservice.getserver().."/miniw/map/?act=download_map_limit";
		url = UrlAddAuth(url);
		ShowLoadLoopFrame(true, "file:mapservice -- func:OLD_ReqDownloadNewMap");
		ns_http.func.rpc_string(url, RespDownloadNewMap, data,nil, ns_http.SecurityTypeHigh);
	end
end

function RespDownloadNewMap(ret, data)
	Log("RespDownloadNewMap '"..tostring(ret).."'");

	mapservice.downloadLimitPulling = false;
	ShowLoadLoopFrame(false)

	mapservice.downloadLimitPulled = true;

	if ret and string.find(ret, 'ok') then
		local num = tonumber(string.match(ret, "ok:(%d+)"));
		mapservice.downloadLimit = num or 0;
		mapservice.downloadLimit = mapservice.downloadLimit - 1;
		DoDownloadNewMap(data);
	else
		-- mapservice.downloadLimit = 0;
		ShowGameTips(GetS(4522), 3);
	end
end

function DoDownloadNewMap(data)

	local map = data.map;
	local options = data.options;

	StatisticsTools:gameEvent("LoadWorld");
	if not map.from_tdr then
		StatisticsTools:gameEvent("httpDownload_Start");
	end
	
	local isauthor = (map.author_uin == AccountManager:getUin());  --自己是原作者
	if map.from_tdr then
		if isauthor then
			AccountManager:requestDownWorld(map.owid, 4);  --自己是原作者
		else
			AccountManager:requestDownWorld(map.owid, 2);  --下载别人的地图
		end
	else
		local isqqmap = options.isqqmap or false;
		CSOWorld:DownloadMap(map, false, isqqmap);
	end

	--通行证缓存重置
	if not isauthor then
		if map.worldtype == 4 or map.worldtype == 5 then--编辑和玩法模式
			AccountManager:setCurWorldPassPortEndTime(map.owid, -1)
		end
	end

	if options.statisticsDownload then
		local fromUiLabel = options.fromUiLabel or -1;
		local fromUiPart = options.fromUiPart or "";
		local supportlang = map.translate_supportlang or 0;
		local sourcelang = map.translate_sourcelang or 0;
		if supportlang <= math.pow(2,sourcelang) then
			supportlang = -1;
		end
		StatisticsTools:miniworksDownMap(map.owid, map.author_uin, fromUiLabel, fromUiPart,supportlang);
	end
end

function StopDownloadMap(map)
	if map then
		CSOWorld:PauseDownloadMap(map);
	end
end

function EnterDownloadedMap(map)
	if ClientCurGame:isInGame() then	--已经在存档内了
 		ShowGameTips(GetS(1204), 3);
 		return false;
 	end
	local teamupSer = GetInst("TeamupService")
	if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
        ShowGameTips(GetS(26045))
        return false
    end

	local worldtype = -1;
	local worldid = -1;
	local fromowid = -1;
	local gameLabel = -1;
	local supportlang = -1;
	local srclang = -1;
	local curlang = -1;
	local worldInfo = {}
	for i = 0, AccountManager:getMyWorldList():getNumWorld() - 1 do
		local wdesc = AccountManager:getMyWorldList():getWorldDesc(i);
		if wdesc == nil then return end
		local from_http = wdesc.fromHttp;
		local from_tdr = (from_http == 0);
		if (wdesc.worldid == map.owid or wdesc.fromowid == map.owid) and from_tdr == map.from_tdr then
			if wdesc.shareVersion == map.share_version then
				worldid = wdesc.worldid;
				worldtype = wdesc.worldtype;
				fromowid = wdesc.fromowid;
				gameLabel = wdesc.gameLabel;
				supportlang = wdesc.translate_supportlang;
				srclang = wdesc.translate_sourcelang;
				curlang = wdesc.translate_currentlang
				worldInfo = wdesc
				break
			end
		end
	end

	if worldid > 0 then
		local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(fromowid);
		if mapIsBreakLaw then end
		if mapIsBreakLaw == 1 then
			ShowGameTips(GetS(10561), 3);
			return;
		elseif mapIsBreakLaw == 2 then
			ShowGameTips(GetS(3632), 3);
			return;
		end

		if CheckPassPortInfo(worldInfo) ~= 0 then return false end
		
		RequestEnterWorld(worldid, false, function(succeed)
			if succeed then
				HideLobby();	
				ShowLoadingFrame();
				if AccountManager:findWorldDesc(worldid) then
					if supportlang > math.pow(2,srclang) then
						-- statisticsGameEvent(62002,"%s",tostring(curlang),"%s",tostring(worldid),"%s",tostring(fromowid))
					end
				end
				-- statisticsGameEvent(8007,"%d",worldtype);
				-- statisticsGameEvent(8008,"%d",gameLabel);
			end
		end);
		
		ns_ma.ma_play_map_set_enter( { where="downloadUI" } )
		return true;
	else
		return false;
	end
end

--return table {buttontype=DOWNBTN_PAUSE_DOWNLOAD, progress=23}
function GetMapDownloadBtnState(map)
	local buttontype, progress, isWaiting = CSOWorld:getDownWorldBtnState(map, 0, 0, false);
	local stateInfo = {buttontype=buttontype, progress=progress}
	if isWaiting then
		stateInfo.isWaiting = isWaiting
	end
	return stateInfo
end

--根据下载的地图id获取存档里的地图id
function GetMapOwidByFromOwid(fromOwid, shareVersion)
	--自己的存档数量
	local num = AccountManager:getMyWorldList():getNumWorld();
	for i=1, num do
		local worldInfo = AccountManager:getMyWorldList():getWorldDesc(i-1);
		if worldInfo and worldInfo.fromowid and worldInfo.fromowid == fromOwid and 
			worldInfo.shareVersion and worldInfo.shareVersion == shareVersion then
			return worldInfo.worldid
		end
	end

	return 0
end

-- return: 
-- value1: 0 本地地址 1 httpurl
-- value2: string path2
-- value3： string or nil explain文本
function GetMapThumbnailPath(map, ingorDefault, ingorArchive)
	if not map then return end
	Log("GetMapThumbnailPath() owid="..map.owid.." thumb_md5="..tostring(map.download_thumb_md5).." node="..tostring(map.download_node).." dir="..tostring(map.download_dir).." ui_obj_name="..tostring(ui_obj_name));
	if BreakLawMapControl:VerifyMapID(map.owid) == 1 then
		return 0, "ui/snap_jubao.png", GetS(20309)
	elseif BreakLawMapControl:VerifyMapID(map.owid) == 2 then
		return 0, "ui/snap_jubao.png", GetS(3635)
	end


	if  map.download_thumb_url and #map.download_thumb_url>=10 then   --http://
		--服务器下发了完整的下载地址
		return 1, map.download_thumb_url;

	elseif map.download_dir==nil or map.download_node==nil or map.download_thumb_md5==nil or map.download_thumb_md5=="" then
		Log("thumbnail owid="..map.owid.." invalid params");
		--地图被禁的话显示提示词
		if map.download_thumb_md5_ban and map.download_thumb_md5_ban~="" then
			return 0, "ui/snap_jubao.png", GetS(25237)
		end
	end

	local url_list = {};

	for i = 1, #(mapservice.thumbnailServers) do
		local server_url = mapservice.thumbnailServers[i];
		--e.g. http://map1.mini1.cn/map/1/20170302/1a5c4a60daeae1684e7ac7e8414ece53.png
		if map.download_thumb_md5 and map.download_thumb_md5 ~= "" then
			local url = ServerUrlReplaceNode(server_url, map.download_node)..tostring(map.download_node).."/"..map.download_dir.."/"..map.download_thumb_md5..".png";
			table.insert(url_list, url);
		end
	end

	if #url_list > 0 then
		return 1, url_list[1];
	else
		if not ingorArchive then
			local worldInfo = AccountManager:findWorldDesc(map.owid)
			if worldInfo then
				local imgPath = string.format("data/w%s/thumb.png_", worldInfo.worldid)
				if gFunc_isStdioFileExist(imgPath) then
					return 0, imgPath;
				end
			end
		end
		if not ingorDefault then
			return 0, mapservice.thumbnailDefaultTexture;
		end
	end

	return nil, nil
end

--地图缩略图
function GetMapThumbnail(map, ui_obj_name, isnew, userdata)
	if not map then return end
	Log("GetMapThumbnail() owid="..map.owid.." thumb_md5="..tostring(map.download_thumb_md5).." node="..tostring(map.download_node).." dir="..tostring(map.download_dir).." ui_obj_name="..tostring(ui_obj_name));
	local explainComponent = getglobal(ui_obj_name .. "Explain");
	if BreakLawMapControl:VerifyMapID(map.owid) == 1 then
		if explainComponent then
			explainComponent:SetText(GetS(20309));
			explainComponent:Show();
		end
		getglobal(ui_obj_name):SetTexture("ui/snap_jubao.png");
		if isnew then getglobal(ui_obj_name):Show() end
		return;
	elseif BreakLawMapControl:VerifyMapID(map.owid) == 2 then
		if explainComponent then
			explainComponent:SetText(GetS(3635));
			explainComponent:Show();
		end
		getglobal(ui_obj_name):SetTexture("ui/snap_jubao.png");
		if isnew then getglobal(ui_obj_name):Show() end
		return;
	end

	if explainComponent then
		explainComponent:Hide();
	end

	if  map.download_thumb_url and #map.download_thumb_url>=10 then   --http://
		--服务器下发了完整的下载地址
		Log("download_thumb_url owid=" .. map.owid .. ", url=" .. map.download_thumb_url );
		local url_list = { map.download_thumb_url }
		local cache_file_path = mapservice.downloadThumbnailRoot .. ns_advert.func.trimUrlFile(map.download_thumb_url)
		Log("download_thumb_url path=" .. cache_file_path );

		if not isnew then
			getglobal(ui_obj_name):SetTexture(mapservice.thumbnailDefaultTexture);
		end
		DownloadThumbnail(url_list, cache_file_path, ui_obj_name, nil, nil, userdata);
		return;

	elseif map.download_dir==nil or map.download_node==nil or map.download_thumb_md5==nil or map.download_thumb_md5=="" then
		Log("thumbnail owid="..map.owid.." invalid params");
		getglobal(ui_obj_name):SetTexture(mapservice.thumbnailDefaultTexture);
		--地图被禁的话显示提示词
		if map.download_thumb_md5_ban and map.download_thumb_md5_ban~="" then
			getglobal(ui_obj_name):SetTexture("ui/snap_jubao.png");
			if explainComponent then
				explainComponent:SetText(GetS(25237));
				explainComponent:Show();
			end
		end
		if isnew then getglobal(ui_obj_name):Show() end
		return;
	end

	local url_list = {};

	for i = 1, #(mapservice.thumbnailServers) do
		local server_url = mapservice.thumbnailServers[i];
		--e.g. http://map1.mini1.cn/map/1/20170302/1a5c4a60daeae1684e7ac7e8414ece53.png
		local url = ServerUrlReplaceNode(server_url, map.download_node)..tostring(map.download_node).."/"..map.download_dir.."/"..map.download_thumb_md5..".png";
		table.insert(url_list, url);
	end


	local cache_file_path = mapservice.downloadThumbnailRoot..map.download_thumb_md5..".png_";
	local check_md5 = map.download_thumb_md5;

	if not isnew then
		getglobal(ui_obj_name):SetTexture(mapservice.thumbnailDefaultTexture);
	end
	DownloadThumbnail(url_list, cache_file_path, ui_obj_name, check_md5, nil, userdata);
end
--load 设置地图缩略图
function LoadSetMapThumbnail(map, mapload, isnew, userdata)
	if not map then return end
	Log("GetMapThumbnail() owid="..map.owid.." thumb_md5="..tostring(map.download_thumb_md5).." node="..tostring(map.download_node).." dir="..tostring(map.download_dir).." ui_obj_name="..tostring(ui_obj_name));
	if BreakLawMapControl:VerifyMapID(map.owid) == 1 then
		mapload:setIcon("ui/snap_jubao.png")
		if isnew then mapload:setVisible(true) end
		return;
	elseif BreakLawMapControl:VerifyMapID(map.owid) == 2 then
		mapload:setIcon("ui/snap_jubao.png")
		if isnew then mapload:setVisible(true) end
		return;
	end
	if  map.download_thumb_url and #map.download_thumb_url>=10 then   --http://
		--服务器下发了完整的下载地址
		Log("download_thumb_url owid=" .. map.owid .. ", url=" .. map.download_thumb_url );
		local url_list = { map.download_thumb_url }
		local cache_file_path = mapservice.downloadThumbnailRoot .. ns_advert.func.trimUrlFile(map.download_thumb_url)
		Log("download_thumb_url path=" .. cache_file_path );

		if not isnew then
			mapload:setIcon(mapservice.thumbnailDefaultTexture)
		end
		LoadDownloadThumbnail(url_list, cache_file_path, mapload, nil, nil, userdata)
		return;

	elseif map.download_dir==nil or map.download_node==nil or map.download_thumb_md5==nil or map.download_thumb_md5=="" then
		Log("thumbnail owid="..map.owid.." invalid params");
		mapload:setIcon(mapservice.thumbnailDefaultTexture)
		--地图被禁的话显示提示词
		if map.download_thumb_md5_ban and map.download_thumb_md5_ban~="" then
			mapload:setIcon("ui/snap_jubao.png")
		end
		if isnew then mapload:setVisible(true) end
		return;
	end

	local url_list = {};

	for i = 1, #(mapservice.thumbnailServers) do
		local server_url = mapservice.thumbnailServers[i];
		--e.g. http://map1.mini1.cn/map/1/20170302/1a5c4a60daeae1684e7ac7e8414ece53.png
		local url = ServerUrlReplaceNode(server_url, map.download_node)..tostring(map.download_node).."/"..map.download_dir.."/"..map.download_thumb_md5..".png";
		table.insert(url_list, url);
	end
	local cache_file_path = mapservice.downloadThumbnailRoot..map.download_thumb_md5..".png_";
	local check_md5 = map.download_thumb_md5;
	if not isnew then
		mapload:setIcon(mapservice.thumbnailDefaultTexture)
	end
	LoadDownloadThumbnail(url_list, cache_file_path, mapload, check_md5, nil, userdata)
end

------------------------------------------------------------------------------------------------

--首页
function ReqMainPageData()

	if not CheckUin() then
		return;
	end

	if mapservice.pullingMainSpecialMaps==false and mapservice.mainSpecialMapsPulled==false then
		ReqMainSpecialMapsList();
	end
	if mapservice.pullingMainPage==false and mapservice.mainPageDataPulled==false then

		mapservice.mainPictures = {};
		mapservice.mainRecommendMaps = {};
		mapservice.mainDailyMaps = {};

		mapservice.pullingMainPage = true;
		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqMainPageData");
		WWW_file_map_homepage();
	end
end

function RespMainPageData(ret)
	Log("RespMainPageData:");
	ShowLoadLoopFrame(false)
	mapservice.pullingMainPage = false;
	mapservice.mainPageDataPulled = true;
	if not ret then
		mapservice.mainPageDataPulled = false;
		NotifyMiniWorksMainShow();
	else
		if isEnableNewMiniWorksMain and isEnableNewMiniWorksMain() then
			--或许因为网络原因拉取失败,下次打开界面重新拉取
			--成功或失败都调用一次回调
			if not ret then
				mapservice.mainPageDataPulled = false;
			end
			NotifyMiniWorksMainShow();
		else
			if UseNewMiniWorksMain then
				GetInst("MiniWorksService"):RespMainPicInfo(ret)
			else
				if  ret and ret.pic_list and ret.recomment then
					--数据正确
				else
					Log("can not get main page data")
					return
				end
				--轮播图片
				mapservice.mainPictures = {};
				local srcpic = ret.pic_list or {};
				for i = 1, #srcpic do
					local picture_data =
					{
						url = srcpic[i].pic,
						staytime = srcpic[i].staytime or 10,
						jump_type = srcpic[i].tp or nil,  --tp 1=存档 2=专题
						jump_id = srcpic[i].id or nil,
					};
					table.insert(mapservice.mainPictures, picture_data);
				end
				--编辑推荐
				mapservice.mainRecommendTitle = ret.recomment.title or "";
				mapservice.mainRecommendRander = OwidRander(ret.recomment.map_list or {});

				--每日精选
				mapservice.mainDaily = {};
				local srclist = ret.day_select or {};
				for i = 1, #srclist do
					local daily = 
					{
						title = srclist[i].title,
						owids = srclist[i].map_list,
						maps = {},
					};
					table.insert(mapservice.mainDaily, daily);
				end

				--LLDO:置顶
				mapservice.mainTopSet = {};
				mapservice.mainTopSet = ret.top_set;

				--notify to UI
				MiniWorksFrameMain_OnPicturesPulled();

				ReqMainRecommendMaps();

				ReqMainDaily(1);
			end
			NotifyMiniWorksMainShow();
		end
	end
end

--编辑推荐
function ReqMainRecommendMaps()	
	Log("ReqMainRecommendMaps");

	mapservice.mainRecommendMaps = {};

	--LLTODO:4张改为6张
	local owids = mapservice.mainRecommendRander:get_next(6);
	ReqMapInfo(owids, RespMainRecommendMaps);
end

function RespMainRecommendMaps(maps, userdata)
	Log("RespMainRecommendMaps");
	mapservice.mainRecommendMaps = maps;

	MiniWorksFrameMain_OnRecommendsUpdated();
end

--最新精选和当前最热
function ReqMainSpecialMapsList()
	Log("ReqMainSpecialMapsList");
	
	mapservice.mainLatestMaps = {};
	mapservice.mainHotMaps = {};
	mapservice.mainWeeklyMaps = {};	--LLDO:weekly, 每周推荐.
	mapservice.mainExpertMaps = {};
	mapservice.mainOptimalMaps = {};
	mapservice.mainFeaturedGameplayMaps = {};

	local url = mapservice.getserver().."miniw/map/?act=get_fp_recomment_list";
	url = UrlAddAuth(url);
	Log("  url = "..url);

	mapservice.pullingMainSpecialMaps = true;
	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqMainSpecialMapsList");
	ns_http.func.rpc(url, RespMainSpecialMapsList, nil,nil, ns_http.SecurityTypeHigh);   --map
end

function RespMainSpecialMapsList(ret)
	ShowLoadLoopFrame(false)

	mapservice.pullingMainSpecialMaps = false;
	mapservice.mainSpecialMapsPulled = true;

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespMainSpecialMapsList");

	if ret.urls then
		SetMapServers(ret.urls);
	end



	--精选地图
	local part1 = ret[1] or {};
	if part1 then
		local owids = {};
		for i = 1, #part1 do
			local owid = tonumber(part1[i].wid);
			if owid then
				table.insert(owids, owid);
			end
		end
		mapservice.mainFeaturedGameplayMaps = {};
		mapservice.mainFeaturedGameplayRander = OwidRander(owids);

		local title_ = part1.title or "";
		if  part1[ 'title_' .. get_game_lang() ] then
			title_ = part1[ 'title_' .. get_game_lang() ]
		end
		mapservice.mainFeaturedGameplayTitle = title_;
	end


	--LLTODO:精彩推荐（不再使用）
	--local part1 = ret[1] or {};
	local part1 = {};
	if part1 then
		local owids = {};
		for i = 1, #part1 do
			local owid = tonumber(part1[i].wid);
			if owid then
				table.insert(owids, owid);
			end
		end
		mapservice.mainLatestMaps = {};
		mapservice.mainLatestMapRander = OwidRander(owids);

		local title_ = part1.title or "";
		if  part1[ 'title_' .. get_game_lang() ] then
			title_ = part1[ 'title_' .. get_game_lang() ]
		end
		mapservice.mainLatestMapsTitle = title_;
	end


	--LLTODO:当前热门 s2-c3
	local part2 = ret[2] or {};
	if part2 then
		local owids = {};
		for i = 1, #part2 do
			local owid = tonumber(part2[i].wid);
			if owid then
				table.insert(owids, owid);
			end
		end
		mapservice.mainHotMaps = {};
		mapservice.mainHotMapRander = OwidRander(owids);

		local title_ = part2.title or "";
		if  part2[ 'title_' .. get_game_lang() ] then
			title_ = part2[ 'title_' .. get_game_lang() ]
		end
		mapservice.mainHotMapsTitle = title_;
	end

	--LLTODO:好友在玩(新加)mainFriendPlay.(暂时去掉) 最新精选 s3-c4
	--[[
	local part3 = ret[3] or {};
	if part3 then
		local owids = {};
		for i = 1, #part3 do
			local owid = tonumber(part3[i].wid);
			if owid then
				table.insert(owids, owid);
			end
		end
		mapservice.mainFriendPlay = {};
		mapservice.mainFriendPlayOwids = owids;	--地图ID列表

		local title_ = part3.title or "";
		if  get_game_lang() == 1    and part3.title_1 then
			title_ = part3.title_1;
		elseif get_game_lang() == 2 and part3.title_2 then
			title_ = part3.title_2;
		else
			
		end
		mapservice.mainFriendPlayTitle = title_;
	end
	--]]

	--LLDO:每周推荐,weekly.(暂时拿laterMaps测试,即ret[1])
	local part3 = ret[3] or {};
	if part3 then
		local owids = {};
		for i = 1, #part3 do
			local owid = tonumber(part3[i].wid);
			if owid then
				table.insert(owids, owid);
			end
		end
		mapservice.mainWeeklyMaps = {};
		mapservice.mainWeeklyMapRander = OwidRander(owids);

		local title_ = part3.title or "";
		if  part3[ 'title_' .. get_game_lang() ] then
			title_ = part3[ 'title_' .. get_game_lang() ]
		end
		mapservice.mainWeeklyMapsTitle = title_;
		--mapservice.mainWeeklyMapsTitle = "每周推荐"; --测试
	end

	--鉴赏家推荐 s4-c2
	local part4 = ret[4] or {};
	if part4 then
		local owids = {};
		for i = 1, #part4 do
			local owid = tonumber(part4[i].wid);
			if owid then
				table.insert(owids, owid);
			end
		end
		mapservice.mainExpertMaps = {};
		mapservice.mainExpertMapRander = OwidRander(owids);

		local title_ = part4.title or "";
		if  part4[ 'title_' .. get_game_lang() ] then
			title_ = part4[ 'title_' .. get_game_lang() ]
		end
		mapservice.mainExpertMapsTitle = title_;
	end

		--鉴赏家优选
	local part5 = ret[5] or {};
	if part5 then
		local owids = {};
		for i = 1, #part5 do
			local owid = tonumber(part5[i].wid);
			if owid then
				table.insert(owids, owid);
			end
		end
		mapservice.mainOptimalMaps = {};
		mapservice.mainOptimalRander = OwidRander(owids);

		local title_ = part5.title or "";
		if  part5[ 'title_' .. get_game_lang() ] then
			title_ = part5[ 'title_' .. get_game_lang() ]
		end
		mapservice.mainOptimalTitle = title_;
	end

	--LLTODO:拉取地图信息()
	--ReqMainLatestMaps();    --最新精选   s1未使用
	--ReqMainHotMaps();       --当前热门   s2 c3
	--ReqMainWeeklyMaps();	  --最新精选   s3 c1 
	--ReqMainExpertMaps();    --鉴赏家     s4 c2

	ReqMainWeeklyMaps();	--最新精选 c1 s3
	ReqMainExpertMaps();    --鉴赏家   c2 s4
	ReqMainHotMaps();       --当前热门 c3 s2
	ReqMainFeaturedGameplayMaps(); --精选玩法
	ReqMainOptimalConnoisseurMaps(); --鉴赏家优选
	--精选玩法 c4 config homepage_config
	--RespMainPageData 
		-- ReqMainRecommendMaps 
			-- mainRecommendRander   
	
end

function ReqMainLatestMaps()	
	Log("ReqMainLatestMaps");

	--LLTODO:4张改为6张
	local owids = mapservice.mainLatestMapRander:get_next(6);
	ReqMapInfo(owids, RespMainLatestMaps);
end

function RespMainLatestMaps(maps, userdata)
	Log("RespMainLatestMaps");

	mapservice.mainLatestMaps = maps;

	MiniWorksFrameMain_OnLatestMapsPulled();
end

function ReqMainHotMaps()
	Log("ReqMainHotMaps");

	--LLTODO:4张改为6张
	local owids = mapservice.mainHotMapRander:get_next(6);
	ReqMapInfo(owids, RespMainHotMaps);
end

--精选玩法
function RespMainFeaturedGameplayMaps(maps, userdata)
	Log("RespMainHotMaps");

	mapservice.mainFeaturedGameplayMaps = maps;

	MiniWorksFrameMain_OnFeaturedGameplayMapsPulled();
end

function ReqMainFeaturedGameplayMaps()
	Log("ReqMainHotMaps");


	local owids = mapservice.mainFeaturedGameplayRander:get_next(6);
	ReqMapInfo(owids, RespMainFeaturedGameplayMaps);
end

function RespMainHotMaps(maps, userdata)
	Log("RespMainHotMaps");

	mapservice.mainHotMaps = maps;

	MiniWorksFrameMain_OnHotMapsPulled();
end

--LLDO:weekly,拉取每周推荐地图列表
function ReqMainWeeklyMaps()	
	Log("ReqMainWeeklyMaps");

	local owids = {};	--mapservice.mainWeeklyMapRander:get_next(6);

	--如果有置顶, 则塞到前面
	local nRanderNum = 6;
	local nTopSetNum = 0;

	if mapservice.mainTopSet and #mapservice.mainTopSet > 0 then
		nTopSetNum = #mapservice.mainTopSet
		nRanderNum = nRanderNum - nTopSetNum;

		if nRanderNum < 0 then
			nRanderNum = 0;
		end

		owids = mapservice.mainTopSet;
	end

	--剩下的随机
	Log("nRanderNum = " .. nRanderNum);
	local randOwids = mapservice.mainWeeklyMapRander:get_next(nRanderNum);

	if nTopSetNum > 0 then
		Log("have top_set:");

		for i = 1, #randOwids do
			--去重
			local bCanInsert = true;
			for j = 1, nTopSetNum do
				if owids[j] == randOwids[i] then
					Log("repeat: owids[j] = " .. owids[j]);
					bCanInsert = false;
					break;
				end
			end

			--追加到后面.
			if bCanInsert then
				table.insert(owids, randOwids[i]);
			end
		end
	else
		Log("dont have top_set:");
		owids = randOwids;
	end

	Log("owids: ");
	ReqMapInfo(owids, RespMainWeeklyMaps);
end

function RespMainWeeklyMaps(maps, userdata)
	Log("RespMainWeeklyMaps");

	mapservice.mainWeeklyMaps = maps;
	--mapservice.mainWeeklyMaps = {};	--weekly, 测试设为空.

	MiniWorksFrameMain_OnWeeklyMapsPulled();
end

--拉取首页鉴赏家推荐地图详情
function ReqMainExpertMaps()	
	Log("ReqMainExpertMaps");

	local owids = mapservice.mainExpertMapRander:get_next(8);
	ReqMapInfo(owids, RespMainExpertMaps, nil, {'normal', 'select'}, true);
end

function RespMainExpertMaps(maps)
	Log("RespMainExpertMaps");

	--mapservice.mainExpertMaps = maps;
	mapservice.mainExpertMaps = {};
	for i=1, #maps do
		if  maps[i] and maps[i].push_comments and maps[i].push_comments[1] then
			mapservice.mainExpertMaps[ #mapservice.mainExpertMaps + 1 ] = maps[i]
		end
	end
	
	
	

	MiniWorksFrameMain_OnConnoisseurMapsPulled();
end

--拉取首页鉴赏家(优选)地图详情
function ReqMainOptimalConnoisseurMaps()
	Log("ReqMainExpertMaps");

	local owids = mapservice.mainOptimalRander:get_next(8);
	ReqMapInfo(owids, RespMainOptimalConnoisseurMaps, nil, {'normal', 'select'}, true);
end

function RespMainOptimalConnoisseurMaps(maps)
	Log("RespMainExpertMaps");

	--mapservice.mainExpertMaps = maps;
	mapservice.mainOptimalMaps = {};
	for i=1, #maps do
		--if  maps[i] and maps[i].push_comments and maps[i].push_comments[1] then
		mapservice.mainOptimalMaps[ #mapservice.mainOptimalMaps + 1 ] = maps[i]
		--end
	end

	MiniWorksFrameMain_OnOptimalConnoisseurMapsPulled();
end

--每日精选
function ReqMainDaily(day_index)

	Log("ReqMainDaily "..day_index);

	local daily = mapservice.mainDaily[day_index];

	if daily==nil then
		return false;
	end

	if daily.maps and #daily.maps > 0 then
		MiniWorksFrameMain_OnDailyPulled(day_index);
		return true;
	end

	if not mapservice.pullingDailyMaps then

		mapservice.pullingDailyMaps = true;
		ReqMapInfo(daily.owids, RespMainDaily, day_index);
	end
end

function RespMainDaily(maps, day_index)
	mapservice.pullingDailyMaps = false;

	Log("RespMainDaily "..day_index);

	local daily = mapservice.mainDaily[day_index];
	daily.maps = maps;

	MiniWorksFrameMain_OnDailyPulled(day_index);
end

--地图精选
--标签 label: 1=综合, 2=生存, 3=创造, 4=对战, 5=电路, 6=解密, 7=跑酷, 8=其它
--排序 order: 1=random  2=download_count  3=week_download_count 4=score
function ReqChosenMaps(label, order, isrefresh)

	if not CheckUin() then
		return;
	end

	Log("ReqChosenMaps: label="..label..", order="..order);
	if not mapservice.pullingChosenMaps then

		local offset;

		mapservice.pullingChosenMaps = true;
		if isrefresh==true then
			mapservice.chosenMaps = {};
			offset = 0;
		else
			offset = #(mapservice.chosenMaps);
		end

		local url = mapservice.getserver().."/miniw/map/?act=get_rank_select_list";

		if label ~= nil and label ~= 1 then
			url = url.."&label="..tostring(label);
		end

		url = url .."&order="..tostring(order);

		if order ~= 1 then
			url = url.."&offset="..offset;
		end

		url = UrlAddAuth(url);
		if label == 1 then
			url = url .. get_map_prefs_string();
		end

		Log("ReqChosenMaps url = "..url);

		local user_data = isrefresh;
		CancelAllDownloadingThumbnails();
		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqChosenMaps");
		ns_http.func.rpc(url, RespChosenMaps, user_data,nil, ns_http.SecurityTypeHigh);   --map
	end
end

function RespChosenMaps(ret, user_data)
	ShowLoadLoopFrame(false)
	mapservice.pullingChosenMaps = false;

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespChosenMaps");

	if ret.urls then
		SetMapServers(ret.urls);
	end

	for i = 1, #(ret) do
		local src = ret[i];

		local map = CreateMapInfoFromHttpResp(src, push_comments, src.push_up3);

		UpdateMapInfoFromHttpRespComment(map, src.comment);

		PrintMapInfo(map);

		table.insert(mapservice.chosenMaps, map);
	end

	local isrefresh = user_data;
	MiniWorksFrameChosen_OnChosenMapsPulled(#(ret), isrefresh);
	if getglobal("MiniWorksTemplate"):IsShown() then
		GetInst("UIManager"):GetCtrl("MiniWorksTemplate"):ReqsMapList();
	end
end

--审核区
--标签 label: 1=综合, 2=生存, 3=创造, 4=对战, 5=电路, 6=解密, 7=跑酷, 8=其它
--排序 order: 1=random 3=日下载 4=评分
function ReqReviewMaps(label, order, isrefresh)

	if not CheckUin() then
		return;
	end

	Log("ReqReviewMaps: label="..label..", order="..order);
	if not mapservice.pullingReviewMaps then

		local offset;

		mapservice.pullingReviewMaps = true;
		if isrefresh==true then
			mapservice.reviewMaps = {};
			offset = 0;
		else
			offset = #(mapservice.reviewMaps);
		end

		local url = mapservice.getserver().."/miniw/map/?act=get_rank_post_list";

		if label ~= nil and label ~= 1 then
			url = url.."&label="..tostring(label);
		end

		local server_orders = {1, 3, 4};
		local serverorder = server_orders[order];

		url = url .."&order="..tostring(serverorder);

		if serverorder ~= 1 then
			url = url.."&offset="..offset;
		end

		url = UrlAddAuth(url);

		Log("  url = "..url);

		local user_data = isrefresh;
		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqReviewMaps");
		ns_http.func.rpc(url, RespReviewMaps, user_data,nil, ns_http.SecurityTypeHigh);   --map
	end
end

function RespReviewMaps(ret, user_data)
	ShowLoadLoopFrame(false)
	mapservice.pullingReviewMaps = false;

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespReviewMaps");

	if ret.urls then
		SetMapServers(ret.urls);
	end

	for i = 1, #(ret) do
		local src = ret[i];

		local map = CreateMapInfoFromHttpResp(src, push_comments, src.push_up3);

		UpdateMapInfoFromHttpRespComment(map, src.comment);

		PrintMapInfo(map);

		table.insert(mapservice.reviewMaps, map);
	end

	local isrefresh = user_data;
	MiniWorksFrameReview_OnReviewMapsPulled(#(ret), isrefresh);
end

function GetReviewMapIndexByOwid(owid)
	for i = 1, #(mapservice.reviewMaps) do
		local map = mapservice.reviewMaps[i];
		if map.owid == owid then
			return i;
		end
	end
	return -1;
end

function GetReviewMapByOwid(owid)
	for i = 1, #(mapservice.reviewMaps) do
		local map = mapservice.reviewMaps[i];
		if map.owid == owid then
			return map;
		end
	end
	return nil;
end

--玩家地图区
--标签 label: 1=综合, 2=生存, 3=创造, 4=对战, 5=电路, 6=解密, 7=跑酷, 8=其它
function ReqPlayerMapsRand(label)

	if not CheckUin() then
		return;
	end

	Log("ReqPlayerMapsRand: label="..label);
	if not mapservice.pullingPlayerMaps then

		mapservice.pullingPlayerMaps = true;
		
		mapservice.playerMapsOffset = 0;
		mapservice.playerMaps = {};

		local url = mapservice.getserver().."/miniw/map/?act=get_rank_normal_list";

		if label ~= nil and label ~= 1 then
			url = url.."&label="..tostring(label);
		end

		url = url.."&order=5"  --order 5=随机

		url = UrlAddAuth(url);

		if  label == 1 then
			url = url .. get_map_prefs_string()
		end
		Log("  url = "..url);

		CancelAllDownloadingThumbnails();
		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqPlayerMapsRand");
		ns_http.func.rpc(url, RespPlayerMaps, nil,nil, ns_http.SecurityTypeHigh);   --map
	end
end

function RespPlayerMaps(ret)
	ShowLoadLoopFrame(false)
	mapservice.pullingPlayerMaps = false;

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespPlayerMaps");

	if ret.urls then
		SetMapServers(ret.urls);
	end

	for i = 1, #(ret) do
		local src = ret[i];

		local map = CreateMapInfoFromHttpResp(src, push_comments, src.push_up3);

		UpdateMapInfoFromHttpRespComment(map, src.comment);

		table.insert(mapservice.playerMaps, map);
	end

	MiniWorksFramePlayer_OnMapsPulled();
end

--玩家地图区 活动比赛版块
function FetchActivityInfo()

	--map_special2 = {
		--{
			--type = 2,  --外部投稿 1=普通活动 2=外部网页投稿活动
			--id   = 20180822,
			--name = '全民创造节',
		--},
	--},

	if  ns_advert and ns_advert.server_config and ns_advert.server_config.map_special2 and #(ns_advert.server_config.map_special2)>0 then
		local data = ns_advert.server_config.map_special2[1];
		mapservice.curActivityType = data.type or 0;
		mapservice.curActivityId   = data.id;
		mapservice.curActivityName = data.name;
		mapservice.allActivity = ns_advert.server_config.map_special2
	else
		mapservice.curActivityType = 0;
		mapservice.curActivityId   = nil;
		mapservice.curActivityName = "";
	end
	Log("FetchActivityInfo: id="..tostring(mapservice.curActivityId).." name='"..tostring(mapservice.curActivityName)
	                            .." type=" .. mapservice.curActivityType );
end

function ReqActivityMaps()
	Log("ReqActivityMaps");

	if  mapservice.curActivityId and mapservice.curActivityType==1 then  --1=普通活动 2=外部投稿
		--普通活动开启
	else
		return;
	end

	if  not mapservice.pullingActivityMaps then
		mapservice.pullingActivityMaps = true;

		--mapservice.activityMaps = {};

		local url = mapservice.getserver().."/miniw/map/?act=get_rank_normal_list";

		if  label ~= nil and label ~= 1 then
			url = url.."&label="..tostring(label);
		end

		url = url.."&order=5&special="..mapservice.curActivityId  --order 5=随机，

		url = UrlAddAuth(url);

		Log("  url = "..url);

		CancelAllDownloadingThumbnails();
		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqActivityMaps");
		ns_http.func.rpc(url, RespActivityMaps, nil,nil, ns_http.SecurityTypeHigh);    --map
	else
		Log("LLTODO:false, false, false");
	end
end

function RespActivityMaps(ret)
	ShowLoadLoopFrame(false)
	mapservice.pullingActivityMaps = false;

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespActivityMaps");

	local tempmaps = {};

	for i = 1, #(ret) do
		local src = ret[i];

		local map = CreateMapInfoFromHttpResp(src, push_comments, src.push_up3);

		UpdateMapInfoFromHttpRespComment(map, src.comment);

		PrintMapInfo(map);

		table.insert(tempmaps, map);
	end

	--一次最多加载几张地图, 4 -> 8
	local MaxNum = 8;

	if #tempmaps > MaxNum then
		local index = math.random(1, #tempmaps - MaxNum + 1);
		mapservice.activityMaps = {};
		for i = index, (index + MaxNum - 1) do
			table.insert(mapservice.activityMaps, tempmaps[i]);
		end
	else
		if #tempmaps > 0 then
			--LLDO:有地图时才刷新, 没地图不刷新
			mapservice.activityMaps = {};
			mapservice.activityMaps = tempmaps;
		end
	end

	MiniWorksFramePlayer_OnActivityMapsPulled();
end

--我的收藏
function CollectMapsDoFilter(label)
	
	mapservice.collectMapsCurLabel = label;

	mapservice.collectMaps = {};

	for i = 1, #(mapservice.collectMapsAll) do
		local map = mapservice.collectMapsAll[i];

		if map.label == mapservice.collectMapsCurLabel or mapservice.collectMapsCurLabel == 1 then
			if BreakLawMapControl:VerifyMapID(map.owid) ~= 2 then
				table.insert(mapservice.collectMaps, map);
			end
		end
	end

	if IsUIFrameShown("CreatorFestival") then
		-- 刷新全民创造节的收藏按钮
		if GetInst("UIManager"):GetCtrl("CreatorFestivalLottery") then
			GetInst("UIManager"):GetCtrl("CreatorFestivalLottery"):OnRefreshCollectBtn()
		end
	end

	MiniWorksFrameCollect_OnMapsPulled();
end

function ReqCollectMaps()

	if not CheckUin() then
		return;
	end

	Log("ReqCollectMaps");

	if not mapservice.pullingCollectMaps then

		mapservice.pullingCollectMaps = true;
		
		mapservice.collectMapPullingIndex = 1;
		mapservice.collectMapAllOwids = {};
		mapservice.collectMapsAll = {};
		mapservice.collectMaps = {};

		local url = mapservice.getserver().."/miniw/map/?act=getCollectList";
		url = UrlAddAuth(url);
		Log("  url = "..url);

		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqCollectMaps");
		ns_http.func.rpc(url, RespCollectMaps, nil,nil, ns_http.SecurityTypeHigh);   --map
	end
end


--LLTODO:进入地图上报  where_ 从哪里进入游戏
function NotifyServerWhenEnterMap(fromowid, map_label, info_ )
	Log( "call NotifyServerWhenEnterMap" );
	--Log( debug.traceback() );
	
	--避免重复上报
	local now_ = getServerNow()
	if  ns_data.play_select_map_history then
		if  ns_data.play_select_map_history.fromowid == fromowid then
			if  now_ - ns_data.play_select_map_history.last_time >= 30 then
				--可以再次上报
			else
				Log( "report same fromowid in 30 sec." )
				return
			end
		end
	else
		ns_data.play_select_map_history = {}
	end

	--记录最后地图id
	ns_data.play_select_map_history.fromowid  = fromowid
	ns_data.play_select_map_history.last_time = now_

	--url = "http://proxy_url:8080/miniw/recommend/?act=play_select_map1&fn=18899882233&in=1&(AUTH"
	local ret_, fromowid_ = check_wid2( fromowid )
	if  ret_ then
		--上报在玩地图和label
		if  ns_version and ns_version.proxy_url then
			local url =  ns_version.proxy_url .. "/miniw/recommend/?act=play_select_map";

			-- 地图ID,&fn
			url = url.."&fn="..fromowid;

			if  map_label then
				url = url.."&label="..map_label;
			end

			if  info_.where then
				url = url.."&where="..info_.where;
			end

			-- auth
			url = UrlAddAuth(url);
			ns_http.func.rpc(url,nil,nil,nil,2);
		end

		--上报玩家喜好(进入游戏)
		add_map_prefs( map_label, 2 );
	end
end

function RespCollectMaps(ret)
	ShowLoadLoopFrame(false)

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespCollectMaps #ret="..#(ret));

	--cdn
	if  ret.urls then
		SetMapServers(ret.urls);
	end

	--net_flow
	if  ret.net_flow then
		mapservice.net_flow = ret.net_flow;
		if 	mapservice and mapservice.net_flow and mapservice.net_flow.limit then
		
			if   ClientMgr:getApiId() == 999 then
				--999渠道不受速度限制
			else
				if  HttpFileUpDownMgr.setDownloadSpeed then
					HttpFileUpDownMgr:setDownloadSpeed( mapservice.net_flow.limit );
				end			
			end
		end
		UpdateMiniWorksStateFrame();
	end
	
	for i = 1, #(ret) do
		local src = ret[i];

		local owid = string.gsub(src.fn, "w", "");
		owid = tonumber(owid);

		table.insert(mapservice.collectMapAllOwids, owid);
	end

	mapservice.collectMapPullingIndex = 1;
	ReqCollectMapDetail();
end

function ReqCollectMapDetail()

	if not mapservice.pullingCollectMaps then
		return;
	end

	local first = mapservice.collectMapPullingIndex;
	local last = first + 10;
	if last > #(mapservice.collectMapAllOwids) then
		last = #(mapservice.collectMapAllOwids);
	end

	mapservice.collectMapPullingIndex = last + 1
	if mapservice.collectMapPullingIndex > #(mapservice.collectMapAllOwids) then
		mapservice.collectMapPullingIndex = #mapservice.collectMapAllOwids
	end

	Log("ReqCollectMapDetail ["..first..","..last.."]");

	if first >= last then
		if first == last and last==1 then
			local owids = {};
			table.insert(owids, mapservice.collectMapAllOwids[first]);
			ReqMapInfo(owids, RespOneCollectMapDetail, nil, {'normal', 'select'});
		else
			EndCollectMaps();
		end
		return;
	end

	local owids = {};
	for i = first, last do
		table.insert(owids, mapservice.collectMapAllOwids[i]);
	end

	ReqMapInfo(owids, RespCollectMapDetail, nil, {'normal', 'select'});
end

function DealCollectMapDetail(maps)
	ShowLoadLoopFrame(false)

	if not mapservice.pullingCollectMaps then
		return;
	end

	Log("RespCollectMapDetail");

	for i,v in ipairs(maps) do
		table.insert(mapservice.collectMapsAll, v);
	end

	CollectMapsDoFilter(mapservice.collectMapsCurLabel);
end

function RespCollectMapDetail(maps)
	DealCollectMapDetail(maps)
	ReqCollectMapDetail();
end

function RespOneCollectMapDetail(maps)
	DealCollectMapDetail(maps)
	EndCollectMaps();
end

function EndCollectMaps()
	Log("EndCollectMaps");

	ShowLoadLoopFrame(false)
	mapservice.pullingCollectMaps = false;

	CollectMapsDoFilter(mapservice.collectMapsCurLabel);
	SandboxLua.eventDispatcher:Emit(nil, mapservice.collectSandboxRefreshEvt, SandboxContext())
end

function FindLikeCount(mapOwid)
	local logaa = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	if like_list then
		for index, value in ipairs(like_list) do
			logaa("FindLikeCount1")
			if value.owid == mapOwid then
				logaa("FindLikeCount3")
				--,dislike_count = ret.dislike
				return value.like_count,value.dislike_count
			end
			logaa("FindLikeCount2")
		end
	end
end

--更新缓存点赞、不喜欢
function UpdateLikeListCount(owid, like, dislike)
	if not like_list then
		like_list = {}
	end
	for i, v in pairs(like_list) do
		if v.owid == owid then
			v.like_count = like or 0
			v.dislike_count = dislike or 0
			return
		end
	end
	table.insert(like_list,{owid = owid, like_count = like or 0, dislike_count = dislike or 0})
end

function FindCollectCount(mapOwid)
	if collect_list then
		for index, value in ipairs(collect_list) do
			if value.owid == mapOwid then
				return value.collect_count
			end
		end
	end
end

--更新缓存收藏
function UpdateCollectListCount(owid, collectc)
	if not collect_list then
		collect_list = {}
	end
	for index, value in pairs(collect_list) do
		if value.owid == owid then
			value.collect_count = collectc or 0
			return
		end
	end
	table.insert(collect_list,{owid = owid, collect_count = collectc or 0})
end

function FindShareCount(mapOwid)
	if share_list then
		for index, value in ipairs(share_list) do
			if value.owid == mapOwid then
				return value.share_count
			end
		end
	end
end

--更新缓存分享
function UpdateShareListCount(owid, share)
	if not share_list then
		share_list = {}
	end
	for i, v in pairs(share_list) do
		if v.owid == owid then
			v.share_count = share or 0
			return
		end
	end
	table.insert(share_list,{owid = owid, share_count = share or 0})
end

function ReqAddCollectMap(map, callback)

	if not CheckUin() then
		return;
	end

	if IsMapCollected(map.owid) then
		return;
	end

	Log("ReqAddCollectMap: "..map.owid);
	if mapservice.addingCollectMap == nil then

		mapservice.addingCollectMap = map;

		local url = mapservice.getserver().."/miniw/map/?act=addCollect&fn=w"..tostring(map.owid);
		url = UrlAddAuth(url);
		Log("  url = "..url);

		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqAddCollectMap");
		ns_http.func.rpc_string(url, function(ret) 
			RespAddCollectMap(ret) 
			if callback then 
				callback(ret)
			end 
		end, nil, nil, true);
		addCollectMapOwid = map.owid
		--收藏上报
		MapHandleReport("Collection", 0, map.owid);
	end
end

function RespAddCollectMap(ret)
	--Log("RespAddCollectMap: '"..ret.."'");

	ShowLoadLoopFrame(false)
	if ret then
		if mapservice.addingCollectMap ~= nil then

			if string.find(ret, "ok") then
				local ret_str = string.split(ret,",")
				local count = tonumber(ret_str[2])
				if string.find(ret, "ok") then
					local ret_str = string.split(ret,",")
					local count = tonumber(ret_str[2])
					--更新收藏数量缓存数据
					if collect_list and addCollectMapOwid and addCollectMapOwid ~= 0 then 
						local isFind = false
						for i, v in pairs(collect_list) do
							if v.owid == addCollectMapOwid then
								v.collect_count = count
								isFind = true
								break;
							end
						end
						if not isFind then
							table.insert(collect_list,{owid = addCollectMapOwid,collect_count = count})
						end
					else
						collect_list = {}
						table.insert(collect_list,{owid = addCollectMapOwid,collect_count = count})
					end	
					addCollectMapOwid = 0
				end
				ShowGameTips(GetS(3890), 3);
				UpdateArchiveInfoCollectBtnState(true,count);
				NewBattlePassEventOnTrigger("collectmap")
				GetInst("NoviceTaskInterface"):SubmitTaskFinish(6,1)
			elseif string.find(ret, "map_added") then
				ShowGameTips(GetS(3892), 3)
			else
				ShowGameTips(GetS(3893), 3);
			end

			ReqCollectMaps(mapservice.collectMapsCurLabel, true);

			mapservice.addingCollectMap = nil;
		end
	else
		ShowGameTips(GetS(282), 3);
		if mapservice.addingCollectMap ~= nil then
			mapservice.addingCollectMap = nil;
		end
	end
end

function ReqRemoveCollectMap(map)
	if not CheckUin() then
		return;
	end

	if not IsMapCollected(map.owid) then
		return;
	end

	Log("ReqRemoveCollectMap: "..map.owid);
	if mapservice.removingCollectMap == nil then

		mapservice.removingCollectMap = map;

		local url = mapservice.getserver().."/miniw/map/?act=delCollect&fn=w"..tostring(map.owid);
		url = UrlAddAuth(url);
		Log("  url = "..url);

		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqRemoveCollectMap");
		ns_http.func.rpc_string(url, RespRemoveCollectMap, nil, nil, true);
		addCollectMapOwid = map.owid
		--取消收藏上报
		MapHandleReport("CancelCollection", 0, map.owid);
	end

end

function RespRemoveCollectMap(ret)
	--Log("RespRemoveCollectMap: '"..ret.."'");

	ShowLoadLoopFrame(false)
	if ret then
		if mapservice.removingCollectMap ~= nil then

			if string.find(ret, "ok") then
				local ret_str = string.split(ret,",")
				local count = tonumber(ret_str[2])
				--更新收藏数量缓存数据
				if collect_list and addCollectMapOwid and addCollectMapOwid ~= 0 then 
					local isFind = false
					for i, v in pairs(collect_list) do
						if v.owid == addCollectMapOwid then
							v.collect_count = count
							isFind = true
							break;
						end
					end
					if not isFind then
						table.insert(collect_list,{owid = addCollectMapOwid,collect_count = count})
					end
				else
					collect_list = {}
					table.insert(collect_list,{owid = addCollectMapOwid,collect_count = count})
				end	
				addCollectMapOwid = 0

				ShowGameTips(GetS(3891), 3);
				UpdateArchiveInfoCollectBtnState(false,count);
			else
				ShowGameTips(GetS(3893), 3);
			end

			ReqCollectMaps(mapservice.collectMapsCurLabel, true);

			mapservice.removingCollectMap = nil;
		end
	else
		ShowGameTips(GetS(282), 3);
		if mapservice.removingCollectMap ~= nil then
			mapservice.removingCollectMap = nil;
		end
	end
end

--点赞状态请求
function ReqMapLikeState(map)
	mapservice.addingLikeMap = map
	if not CheckUin() then
		return;
	end
	ReqMapLikeStateByOwid(map.owid)
end

function ReqMapLikeStateByOwid(owid)
	if not CheckUin() then
		return;
	end
	local url = mapservice.getserver().."/miniw/map/?act=map_ld_state".."&wid="..owid
	url = UrlAddAuth(url);
	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqAddmap_likeMap");
	local userdata = {mapOwid = owid}
	if mapservice.mapLikeState_cache[owid] then
		ResMapLikeState(mapservice.mapLikeState_cache[owid],userdata)
	else
		ns_http.func.rpc(url, ResMapLikeState, userdata,nil, ns_http.SecurityTypeHigh)   --map
	end
	MapHandleReport("map_like", 0, owid);
end

function ResMapLikeState(ret, userdata)
	ShowLoadLoopFrame(false)

	if ret then
		if ret.ret == 0 then
			mapservice.mapLikeState_cache[userdata.mapOwid] = ret
			if ret.state == 0 then
				InitArchiveInfoLikeBtnIconState(false,false)
			elseif ret.state == 1 then
				InitArchiveInfoLikeBtnIconState(true,false)
			elseif ret.state == 2 then
				InitArchiveInfoLikeBtnIconState(false,true)
			end
			--优先使用原样返回的数据而非全局变量
			local mapOwid = (userdata and userdata.mapOwid) and userdata.mapOwid or 0
			-- standReportEvent("48", "MINI_MAP_DETAIL_1", "Dislike", "view", {cid = mapOwid})
			-- standReportEvent("48", "MINI_MAP_DETAIL_1", "Like", "view", {cid = mapOwid})
		else
			InitArchiveInfoLikeBtnIconState()
			print("[xqluo].ResMapLikeState...faild")
		end
	else
		InitArchiveInfoLikeBtnIconState()
		ShowGameTips(GetS(25262))
	end
end

--点赞请求
function ReqAddLikeMap(map)

	if not CheckUin() then
		return;
	end

	if not map.owid then 
		return
	end

	Log("ReqAddCollectMap: "..map.owid);

	local url = mapservice.getserver().."/miniw/map/?act=map_like".."&wid="..map.owid;

	url = UrlAddAuth(url);

	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqAddmap_likeMap");
	local userdata = {mapOwid = map.owid}
	ns_http.func.rpc(url,RespAddLikeMap, userdata,nil, ns_http.SecurityTypeHigh);   --map
	addLikeMapOwid = map.owid
	--收藏上报
	MapHandleReport("map_like", 0, map.owid);
end

function RespAddLikeMap(ret, userdata)
	ShowLoadLoopFrame(false)
	if ret then
		if ret.ret == 0 then
			--更新点赞数量缓存数据
			if like_list and addLikeMapOwid and addLikeMapOwid ~= 0 then 
				local isFind = false
				for i, v in pairs(like_list) do
					if v.owid == addLikeMapOwid then
						v.like_count = ret.like
						v.dislike_count  = ret.dislike
						isFind = true
						break;
					end
				end
				if not isFind then
					table.insert(like_list,{owid = addLikeMapOwid,like_count = ret.like,dislike_count = ret.dislike})
				end
			else
				like_list = {}
				table.insert(like_list,{owid = addLikeMapOwid,like_count = ret.like,dislike_count = ret.dislike})
			end	
			--优先使用原样返回的数据而非全局变量
			local mapOwid = (userdata and userdata.mapOwid) and userdata.mapOwid or addLikeMapOwid
			standReportEvent("48", "MINI_MAP_DETAIL_1", "Like", "click",{cid = mapOwid,standby1 = 1})
			--	本地刷新缓存
			UpadateLocalMapLikeStateCache(mapOwid,1)
			addLikeMapOwid = 0
			ArchiveInfoAddLikeMap(ret.like,ret.dislike)
		elseif ret.ret == 2 then
			print("[xqluo].RespAddLikeMap...Not operated")
		elseif ret.ret == 4 then
			print("[xqluo].RespAddLikeMap...Repeat operation")
		elseif ret.ret == 3 then
			print("[xqluo].RespAddLikeMap...storage error")
		elseif ret.ret == 1 then
			print("[xqluo].RespAddLikeMap...parm error")
		else
			print("[xqluo].RespAddLikeMap...other error")
		end
	else
		ShowGameTips(GetS(25262))
	end
end

function UpadateLocalMapLikeStateCache(owid,state)
	if mapservice.mapLikeState_cache[owid] then
		mapservice.mapLikeState_cache[owid].state = state
	end
end

--取消点赞请求
function ReqCancelLikeMap(map)
	if not CheckUin() then
		return;
	end

	if not map.owid then
		return
	end

	Log("ReqCancelLikeMap: "..map.owid);

	local url = mapservice.getserver().."/miniw/map/?act=map_like".."&wid="..map.owid.."&cancel=1";

	url = UrlAddAuth(url);

	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqAddmap_likeMap");
	local userdata = {mapOwid = map.owid}
	ns_http.func.rpc(url,ResCancelLikeMap, userdata,nil, ns_http.SecurityTypeHigh);   --map
	cancelLikeMapOwid = map.owid

	--收藏上报
	MapHandleReport("map_like", 0, map.owid);
end

function ResCancelLikeMap(ret, userdata)
	ShowLoadLoopFrame(false)
	if ret then
		if ret.ret == 0 then
			--更新点赞数量缓存数据
			if like_list and cancelLikeMapOwid and cancelLikeMapOwid ~= 0 then 
				local isFind = false
				for i, v in pairs(like_list) do
					if v.owid == cancelLikeMapOwid then
						v.like_count = ret.like
						v.dislike_count = ret.dislike
						isFind = true
						break;
					end
				end
				if not isFind then
					table.insert(like_list,{owid = cancelLikeMapOwid,like_count = ret.like,dislike_count = ret.dislike})
				end
			else
				like_list = {}
				table.insert(like_list,{owid = cancelLikeMapOwid,like_count = ret.like,dislike_count = ret.dislike})
			end	
			--优先使用原样返回的数据而非全局变量
			local mapOwid = (userdata and userdata.mapOwid) and userdata.mapOwid or cancelLikeMapOwid
			standReportEvent("48", "MINI_MAP_DETAIL_1", "Like", "click",{cid = mapOwid, standby1 = 2})
			--	本地刷新缓存
			UpadateLocalMapLikeStateCache(mapOwid,0)
			cancelLikeMapOwid = 0
			ArchiveInfoCancelLikeMap(ret.like,ret.dislike)
		elseif ret.ret == 2 then
			print("[xqluo].ResCancelLikeMap...Not operated")
		elseif ret.ret == 4 then
			print("[xqluo].ResCancelLikeMap...Repeat operation")
		elseif ret.ret == 3 then
			print("[xqluo].ResCancelLikeMap...storage error")
		elseif ret.ret == 1 then
			print("[xqluo].ResCancelLikeMap...parm error")
		else
			print("[xqluo].ResCancelLikeMap...other error")
		end
	else
		ShowGameTips(GetS(25262))
	end
end

--添加不喜欢服务请求
function ReqAddDislikeMap(map)
	if not CheckUin() then
		return;
	end

	if not map.owid then
		return
	end

	local url = mapservice.getserver().."/miniw/map/?act=map_dislike".."&wid="..map.owid;

	url = UrlAddAuth(url);
	Log("  url = "..url);

	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqRemoveCollectMap");
	local userdata = {mapOwid = map.owid}
	ns_http.func.rpc(url, ResAddDislikeMap, userdata,nil, ns_http.SecurityTypeHigh);   --map
	addDislikeMapOwid = map.owid
	--取消收藏上报
	MapHandleReport("CancelCollection", 0, map.owid);
end

--不喜欢服务请求之后的回调
function ResAddDislikeMap(ret, userdata)
	ShowLoadLoopFrame(false)
	if ret then
		if ret.ret == 0 then
			--更新点赞数量缓存数据
			if like_list and addDislikeMapOwid and addDislikeMapOwid ~= 0 then 
				local isFind = false
				for i, v in pairs(like_list) do
					if v.owid == addDislikeMapOwid then
						v.like_count = ret.like
						v.dislike_count = ret.dislike
						isFind = true
						break;
					end
				end
				if not isFind then
					table.insert(like_list,{owid = addDislikeMapOwid,like_count = ret.like,dislike_count = ret.dislike})
				end
			else
				like_list = {}
				table.insert(like_list,{owid = addDislikeMapOwid,like_count = ret.like,dislike_count = ret.dislike})
			end
			--优先使用原样返回的数据而非全局变量
			local mapOwid = (userdata and userdata.mapOwid) and userdata.mapOwid or addDislikeMapOwid
			standReportEvent("48", "MINI_MAP_DETAIL_1", "Dislike", "click",{cid = mapOwid, standby1 = 1})
			--	本地刷新缓存
			UpadateLocalMapLikeStateCache(mapOwid,2)	
			addDislikeMapOwid = 0
			ArchiveInfoAddDislikeMap(ret.like,ret.dislike)
		elseif ret.ret == 2 then
			print("[xqluo].ResAddDislikeMap...Not operated")
		elseif ret.ret == 4 then
			print("[xqluo].ResAddDislikeMap...Repeat operation")
		elseif ret.ret == 3 then
			print("[xqluo].ResAddDislikeMap...storage error")
		elseif ret.ret == 1 then
			print("[xqluo].ResAddDislikeMap...parm error")
		else
			print("[xqluo].ResAddDislikeMap...other error")
		end
	else
		ShowGameTips(GetS(25262))
	end
end

--取消不喜欢服务请求
function ReqCancelDislikeMap(map)
	if not CheckUin() then
		return;
	end

	if (not map) or (not map.owid) then
		return
	end

	local url = mapservice.getserver().."/miniw/map/?act=map_dislike".."&wid="..map.owid.."&cancel=1";

	url = UrlAddAuth(url);
	Log("  url = "..url);

	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqRemoveCollectMap");
	local userdata = {mapOwid = map.owid}
	ns_http.func.rpc(url, ResCancelDislikeMap, userdata,nil, ns_http.SecurityTypeHigh);   --map

	--取消收藏上报
	MapHandleReport("CancelCollection", 0, map.owid);
	map_report_cid = map.owid
end


function ResCancelDislikeMap(ret, userdata)
	ShowLoadLoopFrame(false)

	if ret then
		if ret.ret == 0 then
			--优先使用原样返回的数据而非全局变量
			local mapOwid = (userdata and userdata.mapOwid) and userdata.mapOwid or map_report_cid
			standReportEvent("48", "MINI_MAP_DETAIL_1", "Dislike", "click",{cid = mapOwid, standby1 = 2})
			--	本地刷新缓存
			UpadateLocalMapLikeStateCache(mapOwid,0)	
			ArchiveInfoCancelDislikeMap(ret.like,ret.dislike)
			map_report_cid = 0
		elseif ret.ret == 2 then
			print("[xqluo].ResCancelDislikeMap...Not operated")
		elseif ret.ret == 4 then
			print("[xqluo].ResCancelDislikeMap...Repeat operation")
		elseif ret.ret == 3 then
			print("[xqluo].ResCancelDislikeMap...storage error")
		elseif ret.ret == 1 then
			print("[xqluo].ResCancelDislikeMap...parm error")
		else
			print("[xqluo].ResCancelDislikeMap...other error")
		end
	else
		ShowGameTips(GetS(25262))
	end
end

--分享请求
function ReqShareCountMap(map)
	if not CheckUin() then
		return;
	end

	if not map.owid then
		return
	end

	local url = mapservice.getserver().."/miniw/map/?act=share_count".."&wid="..map.owid;

	url = UrlAddAuth(url);
	Log("  url = "..url);

	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqShareCountMap");
	ns_http.func.rpc(url, RespShareCountMap, {mapid = map.owid},nil, ns_http.SecurityTypeHigh);  --map
	--取消收藏上报
	MapHandleReport("ReqShareCountMap", 0, map.owid);
end

function RespShareCountMap(ret, userdata)
	ShowLoadLoopFrame(false)

	if ret then
		userdata = userdata or {}
		if ret.ret == 0 and userdata.mapid and userdata.mapid ~= 0 then
			--更新分享数量缓存数据
			if share_list then 
				local isFind = false
				for i, v in pairs(share_list) do
					if v.owid == userdata.mapid then
						v.share_count = ret.share
						isFind = true
						break;
					end
				end
				if not isFind then
					table.insert(share_list,{owid = userdata.mapid,share_count = ret.share})
				end
			else
				share_list = {}
				table.insert(share_list,{owid = userdata.mapid,share_count = ret.share})
			end	

			ArchiveInfoUpdataShareCountMap(ret.share, userdata.mapid)
			standReportEvent("48", "MINI_MAP_DETAIL_1", "Share", "click")
		elseif ret.ret == 2 then
			print("[xqluo].RespShareCountMap...Not operated")
		elseif ret.ret == 1 then
			print("[xqluo].RespShareCountMap...parm error")
		else
			print("[xqluo].RespShareCountMap...other error")
		end
	else
		ShowGameTips(GetS(25262))
	end
end

function ReqClearAllCollectMaps()
	if not CheckUin() then
		return;
	end

	Log("ReqClearAllCollectMaps: ")
	if not mapservice.ClearingAllCollectMaps then

		mapservice.ClearingAllCollectMaps = true;

		local url = mapservice.getserver().."/miniw/map/?act=delCollect&fn=all"
		url = UrlAddAuth(url)
		Log("ReqClearAllCollectMaps url = "..url)

		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqClearAllCollectMaps");
		ns_http.func.rpc_string(url, RespClearAllCollectMaps, nil, nil, true);
	end

end

function RespClearAllCollectMaps(ret)
	Log("RespClearAllCollectMaps: '"..ret.."'");

	ShowLoadLoopFrame(false)

	if mapservice.ClearingAllCollectMaps then

		if string.find(ret, "ok") then
			ShowGameTips(GetS(3891), 3);
			UpdateArchiveInfoCollectBtnState(false);
		else
			ShowGameTips(GetS(3893), 3);
		end

		ReqCollectMaps(mapservice.collectMapsCurLabel, true);

		mapservice.ClearingAllCollectMaps = false;
	end
end

function GetCollectMapIndexByOwid(owid)
	for i = 1, #(mapservice.collectMaps) do
		local map = mapservice.collectMaps[i];
		if map.owid == owid then
			return i;
		end
	end
	return -1;
end

function GetCollectMapByOwid(owid)
	for i = 1, #(mapservice.collectMaps) do
		local map = mapservice.collectMaps[i];
		if map.owid == owid then
			return map;
		end
	end
	return nil;
end

--获取地图是否被收藏
function IsMapCollected(owid)
	for i = 1, #(mapservice.collectMapsAll) do
		local m = mapservice.collectMapsAll[i];
		if m.owid == owid then
			return true;
		end
	end
	return false;
end

--拉取某个人的收藏地图列表
function ReqSearchCollectMaps(target_uin)

	if not CheckUin() then
		return;
	end

	Log("ReqSearchCollectMaps");

	if not mapservice.pullingSearchCollectMaps then
		mapservice.pullingSearchCollectMaps = true;

		mapservice.searchCollectMaps = {};
		mapservice.searchCollectMapAllOwids = {};

		local url = mapservice.getserver().."/miniw/map/?act=getCollectList&op_uin="..target_uin;
		url = UrlAddAuth(url);
		Log("  url = "..url);

		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqSearchCollectMaps");
		ns_http.func.rpc(url, RespSearchCollectMaps, nil,nil, ns_http.SecurityTypeHigh);   --map
	end
end

function RespSearchCollectMaps(ret)
	ShowLoadLoopFrame(false)

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespSearchCollectMaps #ret="..#(ret));

	--cdn
	if  ret.urls then
		SetMapServers(ret.urls);
	end

	--flow
	if  ret.net_flow then
		mapservice.net_flow = ret.net_flow;
		if 	mapservice and mapservice.net_flow and mapservice.net_flow.limit then
		
			if   ClientMgr:getApiId() == 999 then
				--999渠道不受速度限制
			else
				if  HttpFileUpDownMgr.setDownloadSpeed then
					HttpFileUpDownMgr:setDownloadSpeed( mapservice.net_flow.limit );
				end			
			end
		end
	end
	
	for i = 1, #(ret) do
		local src = ret[i];
		local owid = string.gsub(src.fn, "w", "");
		owid = tonumber(owid);
		if BreakLawMapControl:VerifyMapID(owid) ~= 2 then
			table.insert(mapservice.searchCollectMapAllOwids, owid);
		end
	end

	mapservice.searchCollectMapPullingIndex = 1;
	mapservice.pullingSearchCollectMaps = false;

	if next(mapservice.searchCollectMapAllOwids) == nil then
		SearchCollectResult();
	else
		ReqSearchCollectMapDetail();
	end
end

--每次拉取20个详细的信息
function ReqSearchCollectMapDetail()
	local first = mapservice.searchCollectMapPullingIndex;
	local last = first + 19;
	if last > #(mapservice.searchCollectMapAllOwids) then
		last = #(mapservice.searchCollectMapAllOwids);
	end

	mapservice.searchCollectMapPullingIndex = mapservice.searchCollectMapPullingIndex + 20;

	Log("ReqSearchCollectMapDetail ["..first..","..last.."]");

	if first > last then
		return "no_more";
	end

	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqSearchCollectMapDetail");

	local owids = {};
	for i = first, last do
		table.insert(owids, mapservice.searchCollectMapAllOwids[i]);
	end

	ReqMapInfo(owids, RespSearchCollectMapDetail, nil, {'normal', 'select'});
end

function RespSearchCollectMapDetail(maps)
	ShowLoadLoopFrame(false)

	Log("RespSearchCollectMapDetail");

	for i,v in ipairs(maps) do
		table.insert(mapservice.searchCollectMaps, v);
	end

	SearchCollectResult();
end

function SearchCollectResult()
	if getglobal("CenterCollectArchiveBox"):IsShown() then
		UpdateCenterCollectArchive();
	end
end

--拉取鉴赏家推荐的地图详情
--target_uin 拉取这个target_uin鉴赏家的评测
function ReqExpertMapInfo(owids, callback, userdata, version, target_uin)
	Log("ReqExpertMapInfo");

	local data = 
	{
		owids = owids,
		callback = callback,
		userdata = userdata,
		maps = {},
		version = version or {'select'},
	};

	local owids_str = "";
	for i = 1, #owids do

		local owid = owids[i];

		if #owids_str > 0 then
			owids_str = owids_str.."-";
		end
		owids_str = owids_str..owid;
	end

	if #owids_str > 0 then
		local url = mapservice.getserver().."/miniw/map/?act=get_map_list_info_expert&fn_list="..owids_str;
		if target_uin then
			url = url.."&op_uin="..target_uin;
		end
        if ns_SRR and ns_SRR.cloud_mode == 1 then
            url = url .. '&cloud=1'
        end        
		url = UrlAddAuth(url);
		if ClientMgr:isPureServer() == false then
		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqExpertMapInfo");
		end
		ns_http.func.rpc(url, RespExpertMapInfo, data,nil, ns_http.SecurityTypeHigh);   --map
	else
		data.maps = ReorderMapsByOwids(data.owids, data.maps);
		data.callback(data.maps, userdata, nil, nil, true);
	end
end

function RespExpertMapInfo(ret, data)
	if ClientMgr:isPureServer() == false then
		ShowLoadLoopFrame(false)
	end

	Log("RespExpertMapInfo");
	
	if CheckHttpRpcRet(ret)==true then
	
		for owid, src in pairs(ret) do

			local servermap = nil;

			for i,v in ipairs(data.version) do
				if v=='select' then
					servermap = src.select;
				elseif v=='normal' then
					servermap = src.normal;
				end
				if servermap then break end
			end

			local push_comments = src.push_comments;

			if servermap then
				--地图模板信息
				servermap.template = src.template;

				print("kekeke servermap", servermap, src.comment);
				local map = CreateMapInfoFromHttpResp(servermap, push_comments, src.push_up3, owid);
				map.owid = owid;

				UpdateMapInfoFromHttpRespComment(map, src.comment);
				
				--在地图详情数据里面插入收藏数量的数据
				UpdateMapInfoRespCollectc(map,src)

				if src.select then
					map.display_rank = src.select.rank;
				end

				table.insert(data.maps, map);
			end
		end
	end

	data.maps = ReorderMapsByOwids(data.owids, data.maps);
	data.callback(data.maps, data.userdata);
end

--拉取某个人鉴赏家的评测列表
function ReqSearchExpertMaps(target_uin, cur_label)
	if not CheckUin() then
		return;
	end

	Log("ReqSearchExpertMaps");

	if not mapservice.pullingSearchExpertMaps then
		mapservice.pullingSearchExpertMaps = true;

		mapservice.searchExpertMaps = {};
		mapservice.searchExpertAllMaps = {};
		mapservice.searchExpertAllOwInfo = {};

		local url = mapservice.getserver().."/miniw/map/?act=getExpertList&op_uin="..target_uin;
		url = UrlAddAuth(url);
		Log("  url = "..url);

		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqSearchExpertMaps");
		ns_http.func.rpc(url, RespSearchExpertMaps, {uin=target_uin, label=cur_label},nil, ns_http.SecurityTypeHigh)  --map
	end
end

function RespSearchExpertMaps(ret, user_data)
	ShowLoadLoopFrame(false)

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespSearchExpertMaps #ret="..#(ret));

	--cdn
	if  ret.urls then
		SetMapServers(ret.urls);
	end

	--flow
	if  ret.net_flow then
		mapservice.net_flow = ret.net_flow;
		if 	mapservice and mapservice.net_flow and mapservice.net_flow.limit then
		
			if   ClientMgr:getApiId() == 999 then
				--999渠道不受速度限制
			else
				if  HttpFileUpDownMgr.setDownloadSpeed then
					HttpFileUpDownMgr:setDownloadSpeed( mapservice.net_flow.limit );
				end			
			end
		end
	end
	
	for i = 1, #(ret) do
		local src = ret[i];

		local owid = string.gsub(src.fn, "w", "");
		owid = tonumber(owid);
		local label = src.label and tonumber(src.label) or 1;

		table.insert(mapservice.searchExpertAllOwInfo, {owid=owid, label=label});
	end

	print("kekeke searchExpertAllOwInfo", mapservice.searchExpertAllOwInfo);

	mapservice.searchExpertMapPullingIndex = 1;
	mapservice.pullingSearchExpertMaps  = false;

	if next(mapservice.searchExpertAllOwInfo) == nil then
		SearchExpertResult();
	else
		SetCurExpertLabelOwids(user_data.label);
		ReqSearchExpertMapDetail(user_data.uin);
	end
end

function SetCurExpertLabelOwids(label)
	mapservice.curExpertLabelOwids = {};

	print("kekeke SetCurExpertLabelOwids searchExpertAllOwInfo", mapservice.searchExpertAllOwInfo);
	for i=1, #mapservice.searchExpertAllOwInfo do
		if tonumber(mapservice.searchExpertAllOwInfo[i].label) == label or label == 1 then
			table.insert(mapservice.curExpertLabelOwids, mapservice.searchExpertAllOwInfo[i].owid);
		end
	end

	print("kekeke SetCurExpertLabelOwids", label, mapservice.curExpertLabelOwids);
end

function ExistExpertMap(owid)
	for i=1, #mapservice.searchExpertAllMaps do
		if mapservice.searchExpertAllMaps[i].owid == owid then
			table.insert(mapservice.searchExpertMaps, mapservice.searchExpertAllMaps[i]);

			return true;
		end
	end

	return false;
end

--一次拉12张评测
function ReqSearchExpertMapDetail(target_uin)
	local first = mapservice.searchExpertMapPullingIndex;
	local last = first + 5;
	if last > #(mapservice.curExpertLabelOwids) then
		last = #(mapservice.curExpertLabelOwids);
	end

	mapservice.searchExpertMapPullingIndex = mapservice.searchExpertMapPullingIndex + 6;

	Log("ReqSearchExpertMapDetail ["..first..","..last.."]");

	if first > last then
		return "no_more";
	end

	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqSearchExpertMapDetail");

	local owids = {};
	for i = first, last do
		if not ExistExpertMap(mapservice.curExpertLabelOwids[i]) then
			table.insert(owids, mapservice.curExpertLabelOwids[i]);
		end
	end

	if next(owids) == nil then
		SearchExpertResult();
	else
		ReqExpertMapInfo(owids, RespSearchExpertMapDetail, nil, {'normal', 'select'}, target_uin);
	end
end

function RespSearchExpertMapDetail(maps)
	ShowLoadLoopFrame(false)

	Log("RespSearchCollectMapDetail");

	for i,v in ipairs(maps) do
		print("kekeke RespSearchExpertMapDetail:", i, v.push_comments);
		table.insert(mapservice.searchExpertMaps, v);
		table.insert(mapservice.searchExpertAllMaps, v);
	end

	SearchExpertResult();
end

function SearchExpertResult()
	ShowLoadLoopFrame(false)
	if getglobal("CenterConnoisseurArchiveBox"):IsShown() then
		UpdateCenterConnoisseurArchive();
	end
end

--拉取邀请评测的地图列表
function ReqExpertTaskMaps()
	if not CheckUin() then
		return;
	end

	Log("ReqExpertTaskMaps");

	if not mapservice.pullingExpertTaskMaps then
		mapservice.pullingExpertTaskMaps = true;

		mapservice.expertTaskMaps = {};
		mapservice.expertTaskMapsAllOwids = {};

		local url = mapservice.getserver().."/miniw/map/?act=getExpertTaskDay";
		url = UrlAddAuth(url);
		Log("  url = "..url);

		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqExpertTaskMaps");
		ns_http.func.rpc(url, RespExpertTaskMaps, nil,nil, ns_http.SecurityTypeHigh);   --map
	end
end

function RespExpertTaskMaps(ret)
	ShowLoadLoopFrame(false)

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespExpertTaskMaps #ret="..#(ret));

	--cdn
	if  ret.urls then
		SetMapServers(ret.urls);
	end

	--flow
	if  ret.net_flow then
		mapservice.net_flow = ret.net_flow;
		if 	mapservice and mapservice.net_flow and mapservice.net_flow.limit then
		
			if   ClientMgr:getApiId() == 999 then
				--999渠道不受速度限制
			else
				if  HttpFileUpDownMgr.setDownloadSpeed then
					HttpFileUpDownMgr:setDownloadSpeed( mapservice.net_flow.limit );
				end			
			end
		end
	end
	
	for i = 1, #(ret) do
		local src = ret[i];
		local owid = tonumber(src.fn);
		local star = tonumber(src.star);

		if star == 0 then	--自己没评测过的
			table.insert(mapservice.expertTaskMapsAllOwids, owid);
		end
	end

 	setkv("expert_task_owids", mapservice.expertTaskMapsAllOwids, "expert_task");

	mapservice.pullingExpertTaskMaps  = false;

	if next(mapservice.expertTaskMapsAllOwids) == nil then
		ExpertTaskResult();
	else
		ReqExpertTaskMapDetail();
	end
end

function ReqExpertTaskMapDetail()
	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqExpertTaskMapDetail");
	if not mapservice.pullingExpertTaskMaps then
		mapservice.pullingExpertTaskMaps = true;

		if next(mapservice.expertTaskMapsAllOwids) == nil then
			ExpertTaskResult();
		else
			ReqMapInfo(mapservice.expertTaskMapsAllOwids, RespExpertTaskMapDetail, nil, {'normal', 'select'});
		end
	end
end

function RespExpertTaskMapDetail(maps)
	ShowLoadLoopFrame(false)

	Log("RespExpertTaskMapDetail");
	mapservice.pullingExpertTaskMaps = false;

	for i,v in ipairs(maps) do
		table.insert(mapservice.expertTaskMaps, v);
	end

	ExpertTaskResult();
end

function ExpertTaskResult()
	if getglobal("EvaluationInviteBox"):IsShown() then
		UpdateEvaluationInviteArchive();
	end
end

function RemoveExpertTaskMapsById(owid)
	Log("RemoveExpertTaskMapsById:"..owid);

	for i=1, #mapservice.expertTaskMapsAllOwids do
		if mapservice.expertTaskMapsAllOwids[i] == owid then
			table.remove(mapservice.expertTaskMapsAllOwids, i);
			break;
		end
	end

	setkv("expert_task_owids", mapservice.expertTaskMapsAllOwids, "expert_task");

	for i=1, #mapservice.expertTaskMaps do
		local map = mapservice.expertTaskMaps[i];
		if map.owid == owid then
			table.remove(mapservice.expertTaskMaps, i);
			break;
		end
	end

	UpdateEvaluationInviteArchive();
end

--拉鉴赏家评测区的地图详情
--标签 label: 1=综合, 2=生存, 3=创造, 4=对战, 5=电路, 6=解密, 7=跑酷, 8=其它
--排序 order: 1=默认
function ReqExpertMaps(label, order, isrefresh)

	if not CheckUin() then
		return;
	end

	Log("ReqExpertMaps: label="..label..", order="..order);
	if not mapservice.pullingExpertMaps then

		local offset;

		mapservice.pullingExpertMaps = true;
		if isrefresh==true then
			mapservice.expertMaps = {};
			offset = 0;
		else
			offset = #(mapservice.expertMaps);
		end

		local url = mapservice.getserver().."/miniw/map/?act=get_rank_expert_list";

		if label ~= nil and label ~= 1 then
			url = url.."&label="..tostring(label);
		end

		url = url .."&order="..tostring(order);

		if order ~= 1 then
			url = url.."&offset="..offset;
		end

		url = UrlAddAuth(url);
		if label == 1 then
			url = url .. get_map_prefs_string();
		end

		Log("ReqExpertMaps url = "..url);

		local user_data = isrefresh;
		CancelAllDownloadingThumbnails();
		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqExpertMaps");
		ns_http.func.rpc(url, RespExpertMaps, user_data,nil, ns_http.SecurityTypeHigh);  --map
	end
end

function RespExpertMaps(ret, user_data)
	ShowLoadLoopFrame(false)
	mapservice.pullingExpertMaps = false;

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespExpertMaps");

	if ret.urls then
		SetMapServers(ret.urls);
	end

	for i = 1, #(ret) do
		local src = ret[i];

		local map = CreateMapInfoFromHttpResp(src, src.push_comments, src.push_up3);

		UpdateMapInfoFromHttpRespComment(map, src.comment);

		table.insert(mapservice.expertMaps, map);
	end

	local isrefresh = user_data;
	MiniWorksFrameExpert_OnExpertMapsPulled(#(ret), isrefresh);
end

--获取拉取更多地图（地图分页）的参数
--排序 order: 1=默认, 2=最新, 3=本周热门, 4=评分, 5=下载次数
--[[
function GetMoreMapsParams(order, oldmaps)
	if order == nil or order == 1 or order == 2 then
		local index = -1;
		local value = 0;
		for i = 1, #(oldmaps) do
			local v = oldmaps[i].create_time;
			if index==-1 or v < value then
				index = i;
				value = v;
			end
		end
		if index >= 1 then
			return "&co_time="..value;
		else
			return "";
		end

	elseif order == 3 then

		local index = -1;
		local value = 0;
		for i = 1, #(oldmaps) do
			local v = oldmaps[i].week_download_count;
			if index==-1 or v < value then
				index = i;
				value = v;
			end
		end
		if index >= 1 then
			return "&co_time="..value;
		else
			return "";
		end

	elseif order == 4 then
		local index = -1;
		local value = 0;
		for i = 1, #(oldmaps) do
			local v = oldmaps[i].star;
			if index==-1 or v < value then
				index = i;
				value = v;
			end
		end
		if index >= 1 then
			return "&co_time="..(value*10);  --服务器端score是0~50之间的整数
		else
			return "";
		end

	elseif order == 5 then
		local index = -1;
		local value = 0;
		for i = 1, #(oldmaps) do
			local v = oldmaps[i].download_count;
			if index==-1 or v < value then
				index = i;
				value = v;
			end
		end
		if index >= 1 then
			return "&co_time="..value;
		else
			return "";
		end

	end
end
]]

function GetPlayerMapIndexByOwid(owid)
	for i = 1, #(mapservice.playerMaps) do
		local map = mapservice.playerMaps[i];
		if map.owid == owid then
			return i;
		end
	end
	return -1;
end

function GetPlayerMapByOwid(owid)
	for i = 1, #(mapservice.playerMaps) do
		local map = mapservice.playerMaps[i];
		if map.owid == owid then
			return map;
		end
	end
	return nil;
end


function updataWorkSearchRecordMapList(input, searchType, categoryType)
	--categoryType 主类别
	--categoryType： 1 目标是搜地图 searchType：1地图名 2：作者或者uin
	--categoryType： 2 目标是搜联机 searchType：暂无 默认为1

	categoryType = categoryType or 1

	local flag = true
	local findIdx = 0
	for i,v in ipairs(mapservice.searchRecordMap) do
		if v[1] == input and v[2] == searchType and v[3] == categoryType then
			flag = false;
			findIdx = i
		end
	end

	if not flag then
		table.remove(mapservice.searchRecordMap, findIdx)
	end

	local num = #mapservice.searchRecordMap
	if num >= 10 then
		table.remove(mapservice.searchRecordMap,10);
	end
	table.insert(mapservice.searchRecordMap,1,{input, searchType, categoryType})
end


-- 工坊搜索 
function ReqSearchMapsByType(target_input,isRecord)

	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqSearchMapsByType");

	--去掉空格
	-- target_input = LuaReomve(target_input," ")
	--Escape转码，防止乱码
	local escapeInput = gFunc_urlEscape(target_input)
	if mapservice.searchType == 2 then
		--搜作者或uin


		local url = mapservice.getserver().."/miniw/map/?act=search_by_key&type=player&key="..escapeInput
		url = UrlAddAuth(url);
		Log("Work Search Player "..url);
		ns_http.func.rpc(url, RespSearchMapsByPlayer, nil,nil, ns_http.SecurityTypeHigh);  --map
		--记录玩家搜索内容
		if not isRecord then
			updataWorkSearchRecordMapList(target_input,2);
		end

	else
		-- 搜地图
		-- local input = tonumber(target_input) or 0
		-- if input >= 1000 then
		-- 	-- uin
		-- 	if   input >= ns_const.__INT32__ then
		-- 		ShowGameTips(GetS(6351), 3);        --输入的迷你号有误

		-- 		--该迷你号不存在
		-- 		Miniworks_UselessReport(2, input, 3);

		-- 		return;
		-- 	end
		-- 	ReqSearchMapsByUin(escapeInput)
		-- 	--记录玩家搜索内容
		-- 	if not isRecord then
		-- 		updataWorkSearchRecordMapList(target_input,2);
		-- 	end
		-- else
		local mapType = mapservice.searchMapId;
		if mapType == 1 then
			mapType = 0;
		end
		local url = mapservice.getserver().."/miniw/map/?act=search_by_key&type=map&key="..escapeInput.."&label="..mapType;

		if mapType == 0 then
			url = mapservice.getserver().."/miniw/map/?act=search_by_key&type=map&key="..escapeInput;
		end
		--是否勾选“仅搜索地图模板”
		if mapservice.isTick then
			url = url .. "&temptype=1"
		end
		url = UrlAddAuth(url);
		Log("Work Search Map "..url);
		ns_http.func.rpc(url, RespSearchMapsByMap, nil,nil, ns_http.SecurityTypeHigh);  --map
		--记录玩家搜索内容
		if not isRecord then
			updataWorkSearchRecordMapList(target_input,1);
		end
		-- end
	end

	-- if string.len(target_input) <= 2 then
	-- 	if getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 		getglobal("MiniWorksFrameSearchArchiveBoxNullTitle"):SetText(GetS(21826))
	-- 		getglobal("MiniWorksFrameSearchArchiveBoxNullTitleS"):SetText("")
	-- 	end
	-- else
	-- 	if getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 		getglobal("MiniWorksFrameSearchArchiveBoxNullTitle"):SetText(GetS(21824))
	-- 		getglobal("MiniWorksFrameSearchArchiveBoxNullTitleS"):SetText(mapservice.searchType==2 and GetS(21855) or GetS(21854))
	-- 	end
	-- end
	-- if getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):ClearAllWorkSearchUI()
	-- else
		clearAllWorkSearchUI();
	-- end
	return true;
end


--搜索地图
function ReqSearchMapsByUin(target_uin, selcet)

	if not CheckUin() then
		return;
	end

	local uu_ = tonumber(target_uin) or 0
	if  uu_ < 1000 or uu_ >= ns_const.__INT32__ then
		ShowGameTips(GetS(6351), 3);        --输入的迷你号有误

		--该迷你号不存在
		Miniworks_UselessReport(2, uu_, 3);

		return;
	end
	
	target_uin = getLongUin( target_uin );
	
	Log("ReqSearchMapsByUin "..target_uin);

	mapservice.searchingUin = target_uin;
	mapservice.searchedMaps = {};
	mapservice.searchResultsPulledHttp = false;

	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqSearchMapsByUin");


	local url = mapservice.getserver().."/miniw/map/?act=search_user_maps&op_uin="..target_uin;
	if selcet then
		url = mapservice.getserver().."/miniw/map/?act=search_user_select_maps&op_uin="..target_uin;
	end
    url = AddPlayableArg(url)
	url = UrlAddAuth(url);
	-- 搜uin
	ns_http.func.rpc(url, RespSearchMapsByUin, nil,nil, ns_http.SecurityTypeHigh);  --map

	return true;
end

function RespSearchMapsByPlayer(ret)
	mapservice.searchResultsPulledHttp = true;
	ShowLoadLoopFrame(false)
	local players = "";
     
	if ret and ret.ret == 0 and ret.data.msg and next(ret.data.msg) then
		print("RespSearchMapsByPlayer1")
		for i=1,#ret.data.msg do
			if i == 1 then
				players = JSON:decode(ret.data.msg[i].id);
			else
				players = players.."-"..JSON:decode(ret.data.msg[i].id);
			end
		end

		local url = mapservice.getserver().."/miniw/profile/?act=getProfileBatch2&op_uin_list="..players;
		url = UrlAddAuth(url);
		ShowLoadLoopFrame(true, "file:mapservice -- func:RespSearchMapsByPlayer");
		print("RespSearchMapsByPlayer10,",url)
		ns_http.func.rpc(url, RespSearchMapsByPlayerInfo, nil,nil, ns_http.SecurityTypeHigh);  --profile
		-- if getglobal("MiniWorksFrameSearch"):IsShown() and GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):IsMapSearchType() then
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNull"):Hide();
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNullTitle"):Hide();
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNullTitleS"):Hide();
		-- else
			getglobal("SearchArchiveBoxNull"):Hide();
			getglobal("SearchArchiveBoxNullTitle"):Hide();
		-- end
	else
		print("RespSearchMapsByPlayer2")
		-- if getglobal("MiniWorksFrameSearch"):IsShown() and GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):IsMapSearchType() then
		-- 	for i=1,#mapservice.searchLastList do
		-- 		getglobal("MiniWorksFrameSearchArchiveBoxAuthor"..i):Hide();
		-- 	end
		-- 	for i=1,#mapservice.searchedMaps do
		-- 		local archiveui = getglobal("MiniWorksFrameSearchListArchive"..i);
		-- 		if archiveui then
		-- 			archiveui:Hide()
		-- 		end
		-- 	end
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNull"):Show();
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNullTitle"):Show();
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNullTitleS"):Show();
		-- else
			for i=1,60 do
				getglobal("SearchAuthor"..i):Hide();
				getglobal("SearchArchive"..i):Hide();
			end
			getglobal("SearchArchiveBoxNull"):Show();
			getglobal("SearchArchiveBoxNullTitle"):Show();
		-- end
	end
end

function RespSearchMapsByPlayerInfo(ret)
	ShowLoadLoopFrame(false)
	print("RespSearchMapsByPlayerInfo,",ret)
	-- if getglobal("MiniWorksFrameSearch"):IsShown() and GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):IsMapSearchType() then
	-- 	mapservice.searchLastList = {}
	-- 	for _, value in ipairs(ret) do
	-- 		-- body
	-- 		if value.profile and next(value.profile) and value.profile.RoleInfo and next(value.profile.RoleInfo) then
	-- 			table.insert(mapservice.searchLastList, value)
	-- 		end
	-- 	end
	-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):RoleInfoBack_OnClick()
	-- 	if #mapservice.searchLastList == 0 then
	-- 		if getglobal("MiniWorksFrameSearch"):IsShown() and GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):IsMapSearchType() then
	-- 			for i=1,#mapservice.searchedMaps do
	-- 				local archiveui = getglobal("MiniWorksFrameSearchListArchive"..i);
	-- 				if archiveui then
	-- 					archiveui:Hide()
	-- 				end
	-- 			end
	-- 			getglobal("MiniWorksFrameSearchArchiveBoxNull"):Show();
	-- 			getglobal("MiniWorksFrameSearchArchiveBoxNullTitle"):Show();
	-- 			getglobal("MiniWorksFrameSearchArchiveBoxNullTitleS"):Show();
	-- 		end
	-- 	end
	-- 	return;
	-- end

	-- local input = getglobal("MiniWorksFrameSearch1InputEdit"):GetText();
	-- local num = #ret
	-- local index = 0
	-- for i=1,60 do
	-- 	local workFram = getglobal("SearchAuthor"..i)
	-- 	local uinFram = getglobal("SearchArchive"..i)
	-- 	-- local iconPushedBG = getglobal("SearchAuthor"..i.."PicPushedBG")

	-- 	uinFram:Hide();
	-- 	if i <= num then
	-- 		workFram:Show();
	-- 		if ret and ret[i].profile.RoleInfo and ret[i].profile.RoleInfo.NickName then
	-- 			index = index + 1
	-- 			local icon = getglobal("SearchAuthor"..index.."PicIcon")
	-- 			local name = getglobal("SearchAuthor"..index.."Name");
	-- 			local uin = getglobal("SearchAuthor"..index.."AuthorName")
	-- 			local btn = getglobal("SearchAuthor"..index.."FuncBtn")
	-- 			local funCount = getglobal("SearchAuthor"..index.."Down")
	-- 			local mapCount = getglobal("SearchAuthor"..index.."NowPlayer")
	-- 			local iconBtn = getglobal("SearchAuthor"..index.."Pic")
	-- 			local iconBox = getglobal("SearchAuthor"..index.."PicIconBox")

	-- 			local text = JoinHighlightString(ret[i].profile.RoleInfo.NickName,input);
	-- 			name:SetText(ReplaceFilterString(text))
    --             HeadCtrl:SetPlayerHeadByUin(icon:GetName(),ret[i].uin,ret[i].profile.RoleInfo.head_id,ret[i].profile.RoleInfo.SkinID,ret[i].profile.RoleInfo.HasAvatar);
	-- 			--local file = "ui/roleicons/".. ret[i].profile.RoleInfo.head_id ..".png";
	-- 			--icon:SetTexture(file);
	-- 			-- pic_obj_:SetTexture( HeadFrameCtrl:getTexPath(head_frame_id_) );
	-- 			-- changeHeadFrameTxtPic( (ret[i].profile.RoleInfo.head_id or 1) , iconBox );
	-- 			iconBox:SetTexture( HeadFrameCtrl:getTexPath(ret[i].profile.head_frame_id or 1) );

	-- 			uin:SetText("(".. getShortUin(ret[i].uin)..")")
	-- 			btn:SetClientUserData(0,ret[i].uin);
	-- 			iconBtn:SetClientUserData(0,ret[i].uin);
	-- 			funCount:SetText(ret[i].profile.fun_count)
	-- 			mapCount:SetText(ret[i].profile.map_count)
	-- 		else
	-- 			workFram:Hide();
	-- 			-- getglobal("SearchArchiveBoxNull"):Show();
	-- 			-- getglobal("SearchArchiveBoxNullTitle"):Show();
	-- 		end
			
	-- 		-- local frameFile = HeadFrameCtrl:getTexPath(ret[i].profile.RoleInfo.head_id);
	-- 		-- iconNormal:SetTexture(frameFile)
	-- 		-- iconPushedBG:SetTexture(frameFile)
	-- 		-- print("skdjfhkjsdhfkjh",HeadFrameCtrl:getTexPath(ret[i].profile.RoleInfo.head_id))
			
	-- 		-- changeHeadFrameTxtPic( (ret[i].profile.RoleInfo.head_id or 1) , iconNormal );
	-- 	else
	-- 		workFram:Hide();
	-- 	end	
	-- 	-- owids[i] =(ret.data.msg[i].id)
	-- end

	-- local plane = getglobal("SearchArchiveBoxPlane");
	-- local totalHeight = math.ceil(num / 2) * 138;
	-- if totalHeight < getglobal("SearchArchiveBox"):GetRealHeight() then
	-- 	totalHeight = getglobal("SearchArchiveBox"):GetRealHeight();
	-- end
	-- plane:SetHeight(totalHeight);
end





--检查中文，并返回所有中文字符
function CheckChineseReturnTab( s ) 
	local ret = {};
	local f = '[%z\1-\127\194-\244][\128-\191]*';
	for v in s:gfind(f) do
		table.insert(ret, {c=v,isChinese=(#v~=1)});
	end
	return ret;
end

--连接高亮字符串
function JoinHighlightString(ret,input)
	local str = CheckChineseReturnTab(ret);

	local text ="";
	for i=1,#str do
		local s = nocase(input)
		local a,b = string.find(s,str[i].c,1,true); 
		if a and b then
			text = text.."#cFF6D25"..str[i].c.."#n";
		else
			text = text..str[i].c;
		end
	end
	return text;

end


function nocase (s)
    s = string.gsub(s, "%a", function (c)
      return string.format("[%s%s]", string.lower(c),
                                          string.upper(c))
    end)
    return s
end



function RespSearchMapsByMap(ret)
	print("ReqSearchMapsByType, RespSearchMapsByMap:", ret)
	mapservice.searchResultsPulledHttp = true;
	ShowLoadLoopFrame(false)
	if CheckHttpRpcRet(ret)==false then
		return;
	end

	--[[if getglobal("MiniWorksFrameSearch"):IsShow() then
		GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):--]]

	if ret and ret.ret == 0 and ret.data.msg and next(ret.data.msg) then
		local owids = {};
		for i=1,#ret.data.msg do
			table.insert(owids,JSON:decode(ret.data.msg[i].id))
			-- owids[i] =(ret.data.msg[i].id)
		end
		ShowLoadLoopFrame(true, "file:mapservice -- func:RespSearchMapsByMap");
		ReqMapInfo(owids, RespSearchMapsByMapInfo);
		-- if getglobal("MiniWorksFrameSearch"):IsShown() and GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):IsMapSearchType() then
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNull"):Hide();
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNullTitle"):Hide();
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNullTitleS"):Hide();
		-- else
			getglobal("SearchArchiveBoxNull"):Hide();
			getglobal("SearchArchiveBoxNullTitle"):Hide();
		-- end
	else
		-- if getglobal("MiniWorksFrameSearch"):IsShown() and GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):IsMapSearchType() then
		-- 	for i=1,#mapservice.searchLastList do
		-- 		getglobal("MiniWorksFrameSearchArchiveBoxAuthor"..i):Hide();
		-- 	end
		-- 	for i=1,#mapservice.searchedMaps do
		-- 		local archiveui = getglobal("MiniWorksFrameSearchListArchive"..i);
		-- 		if archiveui then
		-- 			archiveui:Hide()
		-- 		end
		-- 	end
		-- 	getglobal("MiniWorksFrameSearchList"):Hide();
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNull"):Show();
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNullTitle"):Show();
		-- 	getglobal("MiniWorksFrameSearchArchiveBoxNullTitleS"):Show();
		-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):StandReportMapResult(0, true)
		-- else
			for i=1,60 do
				getglobal("SearchArchive"..i):Hide();
				getglobal("SearchAuthor"..i):Hide();
			end
			getglobal("SearchArchiveBoxNull"):Show();
			getglobal("SearchArchiveBoxNullTitle"):Show();
		-- end
			
	end
end


function RespSearchMapsByMapInfo(aMaps, userdata)
	mapservice.searchedMaps ={};
	ShowLoadLoopFrame(false)
	for k,map in pairs(aMaps) do
		table.insert(mapservice.searchedMaps, map);
	end
	for i=1,60 do
		getglobal("SearchAuthor"..i):Hide();
	end
	-- if getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):UpdateSearchMaps()
	-- else
		UpdateSearchArchive();
	-- end

	-- if #mapservice.searchedMaps == 0 then
	-- 	if getglobal("MiniWorksFrameSearch"):IsShown() and GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):IsMapSearchType() then
	-- 		getglobal("MiniWorksFrameSearchList"):Hide();
	-- 		getglobal("MiniWorksFrameSearchArchiveBoxNull"):Show();
	-- 		getglobal("MiniWorksFrameSearchArchiveBoxNullTitle"):Show();
	-- 		getglobal("MiniWorksFrameSearchArchiveBoxNullTitleS"):Show();
	-- 	end
	-- end
end

function RespSearchMapsByUin(ret)
	mapservice.searchResultsPulledHttp = true;
	ShowLoadLoopFrame(false)

	if CheckHttpRpcRet(ret)==false then
		return;
	end
	Log("RespSearchMapsByUin");
	
	if ret and ret.urls then
		SetMapServers(ret.urls);
	end
	if mapservice.searchedMaps then
		mapservice.searchedMaps = {}
	end
	if ret and ret.map_info_list then
		for owid, src in pairs(ret.map_info_list) do
			if BreakLawMapControl:VerifyMapID(owid) ~= 2 then
				--remove tdr map with a same owid
				--local tdrmapindex = GetSearchedMapIndexByOwid(owid);
				--if tdrmapindex > 0 and mapservice.searchedMaps[tdrmapindex].from_tdr then
				--	table.remove(mapservice.searchedMaps, tdrmapindex);
				--end

				local map = CreateMapInfoFromHttpResp(src, src.push_comments, src.push_up3, owid);
				map.owid = owid;

				UpdateMapInfoFromHttpRespComment(map, src.comment);

				PrintMapInfo(map);

				table.insert(mapservice.searchedMaps, map);
			end
		end
	end

	Log("RespSearchMapsByUin: map_sum = "..#mapservice.searchedMaps);

	if getglobal("PlayerCenterFrame"):IsShown() then
		--LLTODO:个人存挡结果处理
		PlayerCenterReqSelfInfo_OnResults();
	elseif getglobal("PlayerExhibitionCenter"):IsShown() then 
		--PEC_GetMapRospond();
	-- elseif getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 	MiniWorksFrameSearch1_OnResultsPulled();
	elseif IsRoomFrameShown() then
		--房间
		RespRoomSearchMapsByUin();
	end
end

function GetSearchedMapByOwid(owid)
	for i = 1, #(mapservice.searchedMaps) do
		local map = mapservice.searchedMaps[i];
		if map.owid == owid then
			return map;
		end
	end
	return nil;
end

function GetSearchedMapIndexByOwid(owid)
	for i = 1, #(mapservice.searchedMaps) do
		local map = mapservice.searchedMaps[i];
		if map.owid == owid then
			return i;
		end
	end
	return -1;
end

--专题列表
function ReqTopicList()

	if not CheckUin() then
		return;
	end

	Log("ReqTopicList");

	if not mapservice.topicsPulled then
		mapservice.topics = {};

		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqTopicList");
		WWW_file_map_topic();
	else
		MiniWorksFrameThemeList_OnThemeListPulled();
	end
end

function RespTopicList(ret)
	ShowLoadLoopFrame(false)

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespTopicList");

	if ret and  ret.urls then
		SetMapServers(ret.urls);
	end

	mapservice.topicsPulled = true;

	for i = 1, #(ret) do
		local src = ret[i];

		local topic = CreateTopicInfoFromHttpResp(src);
		if topic then
			table.insert(mapservice.topics, topic);
		end

	end

	MiniWorksFrameThemeList_OnThemeListPulled();	
end

--专题区
function ReqTopicMaps(topic)
	Log("ReqTopicMaps");
	ReqMapInfo(topic.map_owids, RespTopicMaps, topic);
end

function RespTopicMaps(maps, topic)
	ShowLoadLoopFrame(false)

	Log("RespTopicMaps");

	topic.maps = maps;

	MiniWorksFrameThemeList_OnThemeMapsPulled();
end

--QQ大厅
function RespCollectQQModMapsTable(owid_str)
	Log("RespCollectQQModMapsTable");

	local owids = safe_string2table(owid_str);

	ReqMapInfo(owids, RespQQModMaps);
end

function RespQQModMaps(maps)
	Log("RespQQModMaps #maps="..#maps);

	for i, map in ipairs(maps) do
		Log("checking map:");
		PrintMapInfo(map);

		if DownloadMap(map, {isqqmap=true}) == false then
			return;
		end
	end
end

--GM命令
function SetMapChosen(map, ischosen)
	if CSOWorld:isGmCommandsEnabled() then
		Log("SetMapChosen: owid="..map.owid.."  ischosen="..tostring(ischosen));
		if map.from_tdr then
			ShowGameTips("Error! old map", 5);
			return;
		end
		if ischosen then
			ShowGameTips("Set Map Chosen", 5);
		else
			ShowGameTips("Cancel Map Chosen", 5);
		end
		CSOWorld:reqSetMapChosen(map.owid, ischosen);
	end
end

function SetMapBlack(map, isblack)
	if CSOWorld:isGmCommandsEnabled() then
		Log("SetMapBlack: owid="..map.owid.."  isblack="..tostring(isblack));
		if map.from_tdr then
			ShowGameTips("Error! old map", 5);
			return;
		end
		if isblack then
			ShowGameTips("Set Map Black", 5);
		else
			ShowGameTips("Cancel Map Black", 5);
		end
		CSOWorld:reqSetMapBlack(map.owid, isblack);
	end
end

function CheckMySelfMapInfoCacheReset()
	if mapservice.selfMapInfoListBindUin ~= AccountManager:getUin() then
		mapservice.selfMapInfoListBindUin = AccountManager:getUin()
		mapservice.selfMapInfoList = {}
	end
end

--同步我的地图
function ReqSyncWorldListFromServer(uin, owids)

	--频率限制
	if  uin and (not owids) then
		if  not mapservice.limit_search_user_maps[uin] then	mapservice.limit_search_user_maps[uin] = 0	end
		local now_ = os.time();
		if  now_ - mapservice.limit_search_user_maps[uin] < 10 then
			Log("ReqSyncWorldListFromServer limit = "..uin )
			return
		end
		mapservice.limit_search_user_maps[uin] = now_
		CheckMySelfMapInfoCacheReset()
	end

	if uin == AccountManager:getUin() and type(owids) ~= 'table' then
	end

	Log("ReqSyncWorldListFromServer uin = "..uin);

	--重新获得key
	reset_login_sign();

	local uu_ = tonumber(uin) or 0
	if  uu_ < 1000 or uu_ >= ns_const.__INT32__ then
		--ShowGameTips(GetS(6351), 3);        --输入的迷你号有误
		return false;
	end

	local url = mapservice.getserver().."/miniw/map/?act=search_user_maps&op_uin="..uin;
	local breqbywid = false
	if type(owids) == 'table' and #owids > 0 then
		breqbywid = true
		if #owids == 1 then
			url = url .. "&fn=" .. owids[1]
		else
			url = url .. "&fn_list="
			for i=1,#owids do
				if i == #owids then
					url = url .. owids[i]
				else
					url = url .. owids[i] .. ","
				end
			end
		end
	end
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, RespSyncWorldListFromServer, {uin=uin, breqbywid=breqbywid},nil, ns_http.SecurityTypeHigh);  --map

	return true;
end

function RespSyncWorldListFromServer(ret, data)
	if CheckHttpRpcRet(ret, true)==false then
		CSOWorld:onSyncMyWorldFromServerFinish();
		return;
	end

	Log("RespSyncWorldListFromServer");

	if data.uin == AccountManager:getUin() and not data.breqbywid then
		SetBoughtArchiveNum(ret.unlock_cells)
		--针对多端同步的问题，这里重置一下本地的存档分享状态
		CSOWorld:resetOpenStatusOfShareWorlds()
	end
	
	if ret.urls then
		SetMapServers(ret.urls);
	end

	if ret.map_info_list then
		MyMapInfo = ret.map_info_list
		for owid, src in pairs(ret.map_info_list) do

			local map = CreateMapInfoFromHttpResp(src, src.push_comments, src.push_up3, owid);
			map.owid = owid;

			if data.uin == AccountManager:getUin() then
				--UpdateMapAppealListItem(owid, src)

				if map.temptype == 3 then
					map.temptype = 0
				end
				if map.owid then
					WorldArchiveMgr:addDirtyUinOWID(map.owid)
				end
			end

			UpdateMapInfoFromHttpRespComment(map, src.comment);
			if type(src.open_svr) ~= 'number' then
				map.opensvr = 0
			else
				map.opensvr = src.open_svr
			end
			UpdateMapInfoRespCollectc(map,src)

			PrintMapInfo(map);

			CSOWorld:onSyncMyWorldFromServer(map);

			if data.uin == AccountManager:getUin() then
				mapservice.selfMapInfoList[map.owid] = map;--yang20210414				
			end

			pcall(function()
				if map.opensvr == 10 then
					if mapservice.mapInfoCache[map.owid] then
						mapservice.mapInfoCache[map.owid].tags = map.tags or {}
					end
				end
			end)
		end
	end

	CSOWorld:onSyncMyWorldFromServerFinish();
end

--请求下载的他人的地图状态信息
function ReqOtherUserWorldStatus(owids, callback)
	if type(owids) ~= 'table' and #owids == 0 then return end

	local checkAllCsWids = {}
	local url = mapservice.getserver().."/miniw/map/?act=get_map_flags&fn_list="
	for i=1,#owids do
		table.insert(checkAllCsWids, owids[i].fromowid)
		if i == #owids then
			url = url .. owids[i].fromowid
		else
			url = url .. owids[i].fromowid .. "-"
		end
	end
	url = UrlAddAuth(url)

	ns_http.func.rpc(url, RespOtherUserWorldStatus, {owids=owids, callback=callback},nil, ns_http.SecurityTypeHigh)  --map

	--Modify by huangrulin 2022/02/17 全面云服 创建房间不走云服 因此不需要预获取地图是否支持全面云服信息
	--2022/03/31 分发框架改版 又需要预获取了 huangrulin
	pcall(function() CheckSupportAllCloud_AddWaitOwids(checkAllCsWids) end)
end

function RespOtherUserWorldStatus(ret, data)
	if not CheckHttpRpcRet(ret, true) or not data or type(data.owids) ~= 'table' then return end

	local bNeedUpdate, owids = false, data.owids
	if ret.ret == 0 and type(ret.data) == 'table' then
		local opensvr, share_version, share13_version, my_version = 0, 0, 0, 0
		for i=1,#owids do
			local info = ret.data[owids[i].fromowid]
			if info and info.open then
				my_version = owids[i].ver
				if info.open_svr == nil then
					opensvr = -1
				else
					opensvr = tonumber(info.open_svr)
				end

				if info.share_version == nil then
					share_version = 0
				else
					share_version = tonumber(info.share_version) or 0
				end

				if info.share_version_13 == nil then
					share13_version = 0
				else
					share13_version = tonumber(info.share_version_13)
				end

				if my_version <= share_version then--这个版本是过审的版本
				elseif my_version <= share13_version then--这个版本是灰度版本
					if share_version > 0 then
						opensvr = 13
					end
					share_version = share13_version
				else--版本出错了
				end

				if opensvr == 4 or info.black_stat == 2 then
					UpdateMapAppealListItem(owids[i].fromowid, info)
				end

				if CSOWorld:onSyncOtherUserWorldInfoFromServer(owids[i].owid, tonumber(info.open), opensvr, share_version) then
					bNeedUpdate = true
				end
			end
		end

		if data.callback then data.callback() end
	end

	if bNeedUpdate then
		CSOWorld:onSyncMyWorldFromServerFinish()
	end
end

-- open_svr 对应的状态
-- CHECKING        = 0,    ---未定 审核中  (仅自己可见)
-- OK              = 1,    ---审核成功     (公开)
-- HIDE            = 2,    ---隐藏        (仅自己可见)
-- SEARCH_ONLY     = 3,        ---仅搜索可见   (半公开)
-- FAIL            = 4,    ---审核失败     (都不可见)
-- REAL_NAME_HIDE  = 7,    ---未实名隐藏   (仅自己可见)
-- HIDE_THUMB      = 8,    ---隐藏截图     (地图可见)
-- WAIT_GM         = 9,    ---等待GM人工审核 (都不可见) (地图评论)(地图)
--更新申诉列表
function UpdateMapAppealListItem( owid, map_info )
	--print("UpdateMapAppealListItem( owid, map_info )", owid)
	--print(map_info)
	mapservice.mapInfoList[owid] = map_info

	if map_info.black_stat == 2 then --黑名单
		local blMapInfo = BreakLawMapControl:GetBLMapInfo()
		if blMapInfo then
			blMapInfo.wids = blMapInfo.wids or {}
			blMapInfo.wids[owid] = 2 --黑名单那边数据是1/101
		end
	-- elseif (map_info.open_svr==2 or map_info.open_svr==4 or map_info.open_svr==9) then --需要申诉的地图
	elseif map_info.open_svr==4 then --需要申诉的地图
		mapservice.mapAppealList[owid] = { appeal = map_info.appeal or {} }
	end
end

--查询当前地图的申诉状态
function ReqMapAppealQuery( uin, owid, callback )
	local url = mapservice.getserver().."/miniw/map/?act=appeal&type=map&query=1&fn="..owid
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, RespMapAppealQuery, callback,nil, ns_http.SecurityTypeHigh);   --map
end

function RespMapAppealQuery( ret, callback )
	local result = nil
	if ret and ret.ret then
		if ret.ret == 1 then
			if ret.data and ret.data.stat then
				result = ret.data.stat
			end
		elseif ret.ret == 0 then
			print(ret.msg)
		elseif ret.ret == 2 then --拉入黑名单
			local blMapInfo = BreakLawMapControl:GetBLMapInfo()
			if blMapInfo then
				blMapInfo.wids = blMapInfo.wids or {}
				blMapInfo.wids[owid] = 2
			end
			result = 2
		end
	end

	if callback and type(callback)=="function" then
		callback(result)
	end
end

--地图申诉
function ReqMapAppeal( owid, strReason, strName, strIdentity, strPhone )
	-- local uin = AccountManager:getUin()
	local url = mapservice.getserver().."/miniw/map/?act=appeal&type=map&fn="..owid
	if strReason~="" then
		url = url .. "&desc=" .. gFunc_urlEscape(strReason)
	end
	if strName~="" then
		url = url .. "&name=" .. gFunc_urlEscape(strName)
	end
	if strIdentity~="" then
		url = url .. "&id_num=" .. gFunc_urlEscape(strIdentity)
	end
	if strPhone~="" then
		url = url .. "&mobile=" .. gFunc_urlEscape(strPhone)
	end
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, RespMapAppeal, owid,nil, ns_http.SecurityTypeHigh);  --map
end

function RespMapAppeal( ret, owid )
	if ret and ret.ret then
		if ret.ret == 0 then
			mapservice.mapAppealList[owid] = { appeal = {stat = 0} }
			local strTips = GetS(1010050)
			if IsOverseasVer() or isAbroadEvn() then
				strTips = GetS(10633)
			end
			ShowGameTips(strTips, 3)
			--需要刷新一下状态
			local lobbyCtrl = GetInst("UIManager"):GetCtrl("lobbyMapArchiveList")
			if lobbyCtrl then 
				lobbyCtrl:UpdateMyMapArchive(owid)
			end
		elseif ret.ret == 2 then --拉入黑名单
			local blMapInfo = BreakLawMapControl:GetBLMapInfo()
			if blMapInfo then
				blMapInfo.wids = blMapInfo.wids or {}
				blMapInfo.wids[owid]=2
			end
			-- ShowGameTips(ret.msg or "", 3)
			ns_error_msg.show(ret, 3)
		else
			-- print(ret.ret, ret.msg)
			-- ShowGameTips(ret.msg or "", 3)
			ns_error_msg.show(ret, 3)
		end
	end
end

--查询地图的申诉状态
function MapAppealStatus( owid )
	if mapservice.mapAppealList[owid] and mapservice.mapAppealList[owid].appeal then
		return mapservice.mapAppealList[owid].appeal.stat or 2
	end
	return nil
end

--地图是否需要进行申诉
function IsMapNeadAppeal( owid )
	local mapstatus = MapAppealStatus(owid)
	if mapstatus == 0 or mapstatus == 2 then
		return true
	end
	return false
end

--地图是否下载
function IsDownloadMap( map_info )
	if map_info.realowneruin ~= 0 and map_info.owneruin ~= map_info.realowneruin then
		return true
	end
	return false
end

--地图是否可以联机
function CheckMapOpenOnline( owid, open, isDown, localwid, notShowTip)
	--未分享且不是下载地图
	local ShowGameTips = _G.ShowGameTips
	if notShowTip then
		ShowGameTips = function() end
	end
	if not isDown and open and open == 0 then
		ShowGameTips(GetS(10641), 3)
		return false
	end

	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(owid)
	if mapIsBreakLaw == 1 then
		ShowGameTips(GetS(10639), 3)
		return false
	elseif mapIsBreakLaw == 2 then
		ShowGameTips(GetS(3633), 3)
		return false
	end

	local mapAppealStat = MapAppealStatus(owid)
	if mapAppealStat == 0 then
		ShowGameTips(GetS(10639), 3)
		return false
	elseif mapAppealStat == 2 then
		ShowGameTips(GetS(10640), 3)
		return false
	end

	local env_ = get_game_env()
    if env_ < 10 then
		if not isDown and open == 1 then
			local wdesc = AccountManager:findWorldDesc(owid)
			if wdesc then
				if wdesc.OpenSvr == 0 then
					ShowGameTips(GetS(10639), 3)
					return false
				elseif wdesc.OpenSvr == 2 then
					ShowGameTips(GetS(25812), 3)
					return false
				elseif wdesc.OpenSvr == 4 or wdesc.OpenSvr == 14 then
					ShowGameTips(GetS(10640), 3)
					return false
				elseif wdesc.OpenSvr == 9 then
					ShowGameTips(GetS(10657), 3)
					return false
				end
			end
		end

		if isDown and localwid then
			local wdesc = AccountManager:findWorldDesc(localwid)
			if wdesc then
				if wdesc.OpenSvr == 4 or wdesc.OpenSvr == 14 then
					ShowGameTips(GetS(10640), 3)
					return false
				elseif wdesc.OpenSvr == 2 then
					ShowGameTips(GetS(10640), 3)
					return false
				elseif wdesc.VersionPass == 2 then --灰度版本过期
					ShowGameTips(GetS(10658), 3)
					return false
				elseif wdesc.VersionPass ~= 1 then
					ShowGameTips(GetS(10649), 3)
					return false
				elseif wdesc.OpenSvr == 9 then
					ShowGameTips(GetS(10657), 3)
					return false
				end
			end
		end
	end

	local mapInfo = mapservice.mapInfoList[owid]
	if mapAppealStat ~= 1 and mapInfo and mapInfo.open_svr and mapInfo.open_svr == 2 then
		ShowGameTips(GetS(10640), 3)
		return false
	end

	--未分享且不是下载地图或仅自己可见
	if not isDown and open and open == 2 then
		ShowGameTips(GetS(10642), 3)
		return false
	end

	return true
end

-- 当前是否公开地图
function CheckCurMapIsOpen()
	local bOpen = false
	local worldDesc = CurWorld and AccountManager:findWorldDesc(CurWorld:getOWID())
	if not worldDesc then
		local connect_mode = nil
		if RoomInteractiveData.connect_mode then
			connect_mode = RoomInteractiveData.connect_mode
		else
			local roomDesc = AccountManager:getCurHostRoom()
			if roomDesc then -- 客机加入主机能取到这个值		
				if roomDesc.connect_mode then
					connect_mode = roomDesc.connect_mode
				end
			end
		end
		-- ShowGameTips("connect_mode=" .. tostring(connect_mode))
		if connect_mode == 0 then -- 客机且房间模式connect_mode = 0:公开房间 , 1:协作模式(好友非公开地图联机)
			bOpen = true
		end
	else
		local isDown = IsDownloadMap(worldDesc)
		local fromowid = worldDesc.fromowid
		if fromowid == 0 then
			fromowid = worldDesc.worldid
		end

		if CheckMapOpenOnline(fromowid, worldDesc.open, isDown, fromowid, true) then
			bOpen = true
		end
	end
	return bOpen
end

---------------------------------------------- 材质包 --------------------------------------------------

--材质包列表
function ReqMaterialMods(callback)
	Log("ReqMaterialMods");	
	if mapservice.materialmodsPulled then
		RespMaterialMods(ns_data.server_plugin);
	else
		if not callback then
			ShowLoadLoopFrame(true, "file:mapservice -- func:ReqMaterialMods");
		end
		WWW_file_plugin(callback);
	end
end

function RespMaterialMods(data)
	ShowLoadLoopFrame(false)

	print("kekeke RespMaterialMods")
	print("kekeke RespMaterialMods", data)
	Log("RespMaterialMods");

	if data and data.apk_packs then
		mapservice.materialmodsPulled = true;

		mapservice.materialmods = {};

		local t_prefix = {"", "en_", "tw_", "tha_", "esn_", "ptb_", "fra_", "jpn_", "ara_",
							  "kor_","vie_","rus_","tur_", "ita_","ger_", "ind_" }
		for i = 1, #data.apk_packs do
			local raw = data.apk_packs[i];

			local mod;
			local lang = get_game_lang()+1;
			local prefix = t_prefix[lang];

			if  prefix and #prefix > 0 then
				--先本国 再英文 再中文
				if  not raw[prefix.."name"] then
					prefix = "en_"
					if  not raw[prefix.."name"] then
						prefix = ""
					end
				end
			else
				if  get_game_lang() > 0 then
					prefix = "en_"   --国外默认为英文
				else
					prefix = ""      --国内默认中文
				end
			end

			--print("kekeke lang", lang);

			mod = {
				uuid = raw.uuid or "",
				author_uin = tonumber(raw.uin) or 0,

				author_name = raw[prefix.."author"] or "",

				name = raw[prefix.."name"] or "",

				desc = raw[prefix.."desc"] or "",

				thumb_url = raw.pic or "",
				download_count = 0,  --TODO
				cost_item_id = 0,
				cost_item_num = 0,
			};

			if raw.price then
				mod.cost_item_id = raw.price.id;
				mod.cost_item_num = raw.price.num;
			end

			table.insert(mapservice.materialmods, mod);
		end
	end

	MiniWorksFrameMaterial_OnMaterialModsPulled();
	ReqUnlockedMaterialMods();
end

--查询材质包是否解锁
function ReqUnlockedMaterialMods()
	Log("ReqUnlockedMaterialMods");

	if not mapservice.unlockedModsPulling then
		mapservice.unlockedModsPulling = true;
		mapservice.unlockedModsPulled = false;
		mapservice.unlockedModUuids = {};

		mapservice.unlockedModsWaitingUuids = {};
		for i = 1, #mapservice.materialmods do
			local mod = mapservice.materialmods[i];
			table.insert(mapservice.unlockedModsWaitingUuids, mod.uuid);
		end

		ReqPullNextUnlockedMatMod();
	end
end

function ReqPullNextUnlockedMatMod()
	Log("ReqPullNextUnlockedMatMod");

	if #mapservice.unlockedModsWaitingUuids == 0 then
		RespUnlockedMaterialMods();
		return;
	end

	local uuid = mapservice.unlockedModsWaitingUuids[1];
	table.remove(mapservice.unlockedModsWaitingUuids, 1);

	Log("uuid = "..uuid);

	local url = g_http_root_map .. 'miniw/profile?act=CheckMatUnlock'..
					'&uuid='..uuid..'&'..http_getS1Map();
	url = url_addParams(url)
	--Log(url);
	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqPullNextUnlockedMatMod");
	ns_http.func.rpc_string_raw(url, RespPullNextUnlockedMatMod, uuid);
end

function RespPullNextUnlockedMatMod(retstr, uuid)
	ShowLoadLoopFrame(false)

	Log("RespPullNextUnlockedMatMod");
	Log("retstr = "..tostring(retstr));
	Log("uuid = "..tostring(uuid));

	if retstr and tonumber(retstr)==1 then
		mapservice.unlockedModUuids[uuid] = true;
	else
		mapservice.unlockedModUuids[uuid] = false;
	end

	ReqPullNextUnlockedMatMod();
end

function RespUnlockedMaterialMods()
	Log("RespUnlockedMaterialMods");
	mapservice.unlockedModsPulled = true;
	MiniWorksFrameMaterial_OnUnlockStateUpdated();
	BpReportEventOnHold("materialmod", true);
end

--解锁材质包
function ReqUnlockMaterialMod(mod)
	Log("ReqUnlockMaterialMod "..mod.uuid);

	if not mapservice.unlockingMaterialMods then
		mapservice.unlockingMaterialMods = true;

		local url = g_http_root_map .. 'miniw/profile?act=unlock'..
						'&tp=unlock_mat'..'&uuid='..mod.uuid..'&'..http_getS1Map();
		
		url = url_addParams(url)		
		--Log(url);

		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqUnlockMaterialMod");
		ns_http.func.rpc_string_raw(url, RespUnlockMaterialMod, mod);
	end
end

function RespUnlockMaterialMod(retstr, mod)
	mapservice.unlockingMaterialMods = false;
	ShowLoadLoopFrame(false)

	Log("RespUnlockMaterialMod");

	if retstr and string.find(retstr, 'ok') then
		ShowGameTips(GetS(4773), 3);
		BpReportEventOnHold("materialmod");
	else
		ShowGameTips(GetS(4774), 3);
	end

	ReqGetMaterialModUnlocked(mod.uuid, function()
		MiniWorksFrameMaterial_OnUnlockStateUpdated();
	end)
end

--查询是否已解锁
function ReqGetMaterialModUnlocked(uuid, callback, userdata)
	Log("ReqGetMaterialModUnlocked "..uuid);

	local url = g_http_root_map .. 'miniw/profile?act=CheckMatUnlock'..
					'&uuid='..uuid..'&'..http_getS1Map();

	url = url_addParams(url)
	--Log(url);

	ShowLoadLoopFrame(true, "file:mapservice -- func:ReqGetMaterialModUnlocked");
	ns_http.func.rpc_string_raw(url, RespGetMaterialModUnlocked, {uuid=uuid, callback=callback, userdata=userdata});
end

function RespGetMaterialModUnlocked(retstr, data)
	ShowLoadLoopFrame(false)

	Log("RespGetMaterialModUnlocked "..data.uuid);
	Log(retstr);
	if data then
		if retstr and tonumber(retstr)==1 then
			mapservice.unlockedModUuids[data.uuid] = true;
			data.callback(true, data.userdata);
		else
			mapservice.unlockedModUuids[data.uuid] = false;
			data.callback(false, data.userdata);
		end
	end
end

-----------------------------------------------------------------------------------------------------------

--通用的批量获取地图信息接口
--version: {'select'}, {'normal'}, {'select,normal'}, {'normal,select'}
--isExpert true：拉取评测过这张图的鉴赏家相关的信息
function ReqMapInfo(owids, callback, userdata, version, isExpert)
	Log("ReqMapInfo");
	--Modify by huangrulin 2022/02/17 全面云服 创建房间不走云服 因此不需要预获取地图是否支持全面云服信息
	--2022/03/31 分发框架改版 又需要预获取了 huangrulin
	--判断是否是云服改为直接判断地图内对应是否是云服字段
	-- pcall(function() 
	-- 	CheckSupportAllCloud_AddWaitOwids(owids) 
	-- end)

	local data = 
	{
		owids = owids,
		callback = callback,
		userdata = userdata,
		maps = {},
		version = version or {'select'},
	};
	if not owids then
		return
	end

	local owids_str = "";
	local serverTime = getServerTime()
	local checker_uin = AccountManager:getUin()

	for i = 1, #owids do
		local owid = owids[i];
		print(mapservice.mapInfoCache[owid])
		if mapservice.mapInfoCache[owid] ~= nil and not IsUserOuterChecker(checker_uin) then  --load from cache -审核人员 需要拿最新地图方便审核最新地图。
			local map = mapservice.mapInfoCache[owid];
			table.insert(data.maps, map);
		else  --load from http
			if #owids_str > 0 then
				owids_str = owids_str.."-";
			end
			owids_str = owids_str..owid;
		end
	end
	print(#owids_str)
	if #owids_str > 0 then
		local url = mapservice.getserver().."/miniw/map/?act=get_map_list_info&fn_list="..owids_str;

		if isExpert then
			url = url.."&expert=1";
		end

        if ns_SRR and ns_SRR.cloud_mode == 1 then
            url = url .. '&cloud=1'
        end
        
		url = UrlAddAuth(url);

        if zmqMgr_ and zmqMgr_.IsDevelopRoom and zmqMgr_:IsDevelopRoom() then
            url = mapservice.getserver().."/miniw/map/?cmd=get_single_map_info2&fn="..owids_str;
            data.version = {'debug'};
            local uin_ = AccountManager:getUin();
            local  now_ = os.time();            
            local token = uin_..'#LY1006#'..now_..'#get_single_map_info2#'
            token = gFunc_getmd5(token)
            url = url .. "&token=" .. token .. "&time=" .. now_
        end
        
		if ClientMgr:isPureServer() == false then
		ShowLoadLoopFrame(true, "file:mapservice -- func:ReqMapInfo");
		end
		ns_http.func.rpc(url, RespMapInfo, data,nil, ns_http.SecurityTypeHigh);  --map
		mIsUpload = false
	else
		data.maps = ReorderMapsByOwids(data.owids, data.maps);
		data.callback(data.maps, userdata, nil, nil, true);
	end
end

function AddPlayableArg(url)
	if "string" == type(url) then
		--不是GM或者审核账号，则添加获取地图可玩版本的字段（满足1：请求者不是作者，2地图open_svr为0/1/9,返回可玩版本的地图信息）
		if not (CSOWorld:isGmCommandsEnabled() or IsUserOuterChecker(AccountManager:getUin())) then 
			if not (ns_SRR and ns_SRR.cloud_mode == 1) then --云服运行环境不加
				url = url .. "&playable=1"
			end
		end
	end
	return url
end

--强制更新获取地图信息
function ForeceGetMapInfo(owid,callback)
	local data = 
	{
		owids = {owid},
		callback = callback,
		userdata = userdata,
		maps = {},
		version = version or {'select'},
	};
	if not owid then
		return
	end
	local owids_str = "";
	local serverTime = getServerTime()
	local checker_uin = AccountManager:getUin()
	owids_str = owids_str..owid;
	if #owids_str > 0 then
		local url = mapservice.getserver().."/miniw/map/?act=get_map_list_info&fn_list="..owids_str;

		if isExpert then
			url = url.."&expert=1";
		end

        if ns_SRR and ns_SRR.cloud_mode == 1 then
            url = url .. '&cloud=1'
        end
        
		url = UrlAddAuth(url);

        if zmqMgr_ and zmqMgr_.IsDevelopRoom and zmqMgr_:IsDevelopRoom() then
            url = mapservice.getserver().."/miniw/map/?cmd=get_single_map_info2&fn="..owids_str;
            data.version = {'debug'};
            local uin_ = AccountManager:getUin();
            local  now_ = os.time();            
            local token = uin_..'#LY1006#'..now_..'#get_single_map_info2#'
            token = gFunc_getmd5(token)
            url = url .. "&token=" .. token .. "&time=" .. now_
        end
        
		if ClientMgr:isPureServer() == false then
			ShowLoadLoopFrame(true, "file:mapservice -- func:ReqMapInfo");
		end
		ns_http.func.rpc(url, RespMapInfo, data,nil, ns_http.SecurityTypeHigh);  --map
		mIsUpload = false
	end


end

function RespMapInfo(ret, data)
	if ClientMgr:isPureServer() == false then
        ShowLoadLoopFrame(false)
	end

	Log("RespMapInfo");
	
	if CheckHttpRpcRet(ret)==true then
	
		print("RespMapInfo data", ret);
	
		for owid, src in pairs(ret) do

			local servermap = nil;
			if type(src) ~= "table" then
                src = {}
            end
            if type(owid) == "string" and type(src._k_) == "number" then
                owid = src._k_
            end

			for i,v in ipairs(data.version) do
				if v=='select' then
					servermap = src.select;
				elseif v=='normal' then
					servermap = src.normal;
                elseif v=='debug' then
					servermap = src.debug or src.normal or src.select;                    
				end
				--地图模板信息
				if servermap then
					servermap.template = src.template;
				end

				--[[地图服 不同接口 返回的数据结构会有不同 这里做下兼容]]
				if servermap and src.mul then
					servermap["mul"] = src.mul;
				end

				if servermap then
					if src.manor then
						servermap.manor = src.manor;
					end
					if src.comment and src.comment.tips and src.comment.tips.total then
						servermap["tips"] = src.comment.tips;
					end
					break 
				end
			end

			if servermap then
				--添加是否是云服地图,此处cloud数据在地图信息外层src里面
				servermap.cloud = src.cloud						--是否云服地图 0：非云服 1：云服
				servermap.cloud_source = src.cloud_source		--云服地图产生方式 0：非云服地图 1：玩家主动设置  2：运营设置

				local map = CreateMapInfoFromHttpResp(servermap, src.push_comments, src.push_up3, owid);
				map.owid = owid;

				UpdateMapInfoFromHttpRespComment(map, src.comment);

				if src.select then
					map.display_rank = src.select.rank;
				end
				
				--在地图详情数据里面插入收藏数量的数据
				UpdateMapInfoRespCollectc(map,src)

				table.insert(data.maps, map);

				mapservice.mapInfoCache[map.owid] = map;
			end
		end
	end

	if data then
		data.maps = ReorderMapsByOwids(data.owids, data.maps);
		data.callback(data.maps, data.userdata);
	end
end

function ReorderMapsByOwids(owid_list, map_list)
	local maps = {};
	for i = 1, #owid_list do
		local owid = owid_list[i];
		for j = 1, #map_list do
			local map = map_list[j];
			-- if tonumber(map.owid) == tonumber(owid) then
			-- 	table.insert(maps, map);
			-- 	break;
			-- end
			if wid_compare(map.owid, owid) then
				table.insert(maps, map);
				break;
			end
		end
	end
	return maps;
end

--通用的缩略图下载接口
--新加参数 callback(errcode, filepath)
local thumbnail_taskid = 1;
function DownloadThumbnail(url_list, cache_file_path, ui_obj_name, check_md5, delay, userdata, callback)

	if  cache_file_path and string.endswith(cache_file_path, ".png") then
		cache_file_path = cache_file_path.."_";  --abc.png->abc.png_
	end

	if url_list==nil or #(url_list)==0 or cache_file_path==nil or cache_file_path=="" then
		Log("DownloadThumbnail error: invalid params");
		return;
	end

	local obj = {
		taskid = thumbnail_taskid,
		file_path = cache_file_path,
		check_md5 = check_md5,
		url_list = url_list,
		url_index = 1,
		ui_obj_names = {ui_obj_name},
		ui_loads={},
		delay = delay or 0.2,
		callback = callback,
	};

	if userdata then
		obj.userdatas = {userdata}
	end
	thumbnail_taskid = thumbnail_taskid + 1;

	--Log("DownloadThumbnail ["..obj.taskid.."] "..cache_file_path.." -> "..ui_obj_name);

	local downloading_obj = GetDownloadingThumbnailInfo(obj.file_path);

	if downloading_obj==nil then  --not downloading

		if gFunc_isStdioFileExist(obj.file_path) then
			Log("thumbnail ["..obj.taskid.."] load from cache file");
			if ui_obj_name then
				local path2 = iif(ClientMgr:isPC(), obj.file_path, obj.file_path);
				getglobal(ui_obj_name):SetTexture(path2);
				getglobal(ui_obj_name):Show()
			end
			if callback and type(callback) == "function" then
				callback(0, obj.file_path, {userdata});
			end
		else
			Log("thumbnail ["..obj.taskid.."] add to download queue");
			
			table.insert(mapservice.waitDownloadThumbnails, obj);

			if mapservice.curDownloadingThumbnail == nil then
				DownloadNextThumbnail();
			end
		end

	else  --already downloading
		Log("thumbnail ["..obj.taskid.."] already downloading ["..downloading_obj.taskid.."]");
		table.insert(downloading_obj.ui_obj_names, ui_obj_name);
		if userdata and downloading_obj.userdatas then
			table.insert(downloading_obj.userdatas, userdata)
		end
	end
end
--Load下载设置图片
function LoadDownloadThumbnail(url_list, cache_file_path, mapload, check_md5, delay, userdata, callback)

	if  cache_file_path and string.endswith(cache_file_path, ".png") then
		cache_file_path = cache_file_path.."_";  --abc.png->abc.png_
	end

	if url_list==nil or #(url_list)==0 or cache_file_path==nil or cache_file_path=="" then
		Log("DownloadThumbnail error: invalid params");
		return;
	end

	local obj = {
		taskid = thumbnail_taskid,
		file_path = cache_file_path,
		check_md5 = check_md5,
		url_list = url_list,
		url_index = 1,
		ui_obj_names = {},
		ui_loads={mapload},
		delay = delay or 0.2,
		callback = callback,
	};
	local downloading_obj = GetDownloadingThumbnailInfo(obj.file_path);

	if downloading_obj==nil then  --not downloading

		if gFunc_isStdioFileExist(obj.file_path) then
			Log("thumbnail ["..obj.taskid.."] load from cache file");
			if mapload then
				local path2 = iif(ClientMgr:isPC(), obj.file_path, obj.file_path);
				if not tolua.isnull(mapload) then
					mapload:setIcon(path2)
					mapload:setVisible(true)
				end
			end
			if callback and type(callback) == "function" then
				callback(0, obj.file_path);
			end
		else
			Log("thumbnail ["..obj.taskid.."] add to download queue");
			
			table.insert(mapservice.waitDownloadThumbnails, obj);

			if mapservice.curDownloadingThumbnail == nil then
				DownloadNextThumbnail();
			end
		end

	else  --already downloading
		Log("thumbnail ["..obj.taskid.."] already downloading ["..downloading_obj.taskid.."]");
		table.insert(downloading_obj.ui_loads, mapload);
		if userdata and downloading_obj.userdatas then
			table.insert(downloading_obj.userdatas, userdata)
		end
	end
end

function WorksDownloadThumbnail(url_list, cache_file_path, ui_obj_name, check_md5, delay, userdata, callback, must)

	if  cache_file_path and string.endswith(cache_file_path, ".png") then
		cache_file_path = cache_file_path.."_";  --abc.png->abc.png_
	end

	if url_list==nil or #(url_list)==0 or cache_file_path==nil or cache_file_path=="" then
		Log("DownloadThumbnail error: invalid params");
		return;
	end

	local packCb = function(code, file_path)
		if callback and type(callback) == "function" then
			callback(code, file_path, {userdata});
		end
		callback = nil
		userdata = nil
	end
	local obj = {
		must = must,
		taskid = thumbnail_taskid,
		file_path = cache_file_path,
		check_md5 = check_md5,
		url_list = url_list,
		url_index = 1,
		ui_obj_names = {ui_obj_name},
		ui_loads={},
		delay = delay or 0.2,
		packCbs = {packCb},
	};

	if userdata then
		obj.userdatas = {userdata}
	end
	thumbnail_taskid = thumbnail_taskid + 1;

	--Log("DownloadThumbnail ["..obj.taskid.."] "..cache_file_path.." -> "..ui_obj_name);

	local downloading_obj = GetDownloadingThumbnailInfo(obj.file_path);

	if downloading_obj==nil then  --not downloading

		if gFunc_isStdioFileExist(obj.file_path) then
			Log("thumbnail ["..obj.taskid.."] load from cache file");
			if ui_obj_name then
				local path2 = iif(ClientMgr:isPC(), obj.file_path, obj.file_path);
				getglobal(ui_obj_name):SetTexture(path2);
				getglobal(ui_obj_name):Show()
			end
			if callback and type(callback) == "function" then
				callback(0, obj.file_path, {userdata});
			end
		else
			Log("thumbnail ["..obj.taskid.."] add to download queue");
			
			table.insert(mapservice.waitDownloadThumbnails, obj);

			if mapservice.curDownloadingThumbnail == nil then
				DownloadNextThumbnail();
			end
		end

	else  --already downloading
		Log("thumbnail ["..obj.taskid.."] already downloading ["..downloading_obj.taskid.."]");
		table.insert(downloading_obj.ui_obj_names, ui_obj_name);
		if userdata and downloading_obj.userdatas then
			table.insert(downloading_obj.userdatas, userdata)
		end
		downloading_obj.packCbs = downloading_obj.packCbs or {}
		table.insert(downloading_obj.packCbs, packCb)
	end
end

-- "http://xxxxxx:8080/miniw/ma/1115.png" -> "miniw_ma_1115.png"
function GetCacheFileNameFromUrl(url)
	local p1,p2 = url:find('//');
	if p1 then
		local q1 = url:find('/', p2 + 1);
		if q1 then
			return url:sub(q1 + 1):gsub('/', '_');
		end
	end
	return "";
end

function GetDownloadingThumbnailInfo(file_path)
	for i = 1, #(mapservice.waitDownloadThumbnails) do
		local obj = mapservice.waitDownloadThumbnails[i];
		if obj.file_path == file_path then
			return obj;
		end
	end
	return nil;
end

function DownloadNextThumbnail()
	--Log("DownloadNextThumbnail");

	if mapservice.curDownloadingThumbnail == nil then
		for i = 1, #(mapservice.waitDownloadThumbnails) do

			local obj = mapservice.waitDownloadThumbnails[i];

			if obj.url_index <= #(obj.url_list) then  -- Start download

				mapservice.curDownloadingThumbnail = obj;

				if obj.delay==nil or obj.delay<=0.01 then
					mapservice.curDownloadingCountdown = nil;
					ReqDownloadCurThumbnail();
				else
					mapservice.curDownloadingCountdown = obj.delay;
				end

				break;

			else  -- Download failed
				Log("thumbnail ["..obj.taskid.."] failed, all urls tried");
				table.remove(mapservice.waitDownloadThumbnails, i);
				i = i - 1;
			end
		end
	end
end

function ReqDownloadCurThumbnail()
	--Log("ReqDownloadCurThumbnail");

	if mapservice.curDownloadingThumbnail ~= nil then
		local obj = mapservice.curDownloadingThumbnail;

		Log("thumbnail ["..obj.taskid.."] start download");

		local download_url = obj.url_list[obj.url_index];

		
		
		ns_http.func.downloadFile(download_url, obj.file_path, obj.check_md5, RespDownloadThumbnail, obj);
	end
end

function RespDownloadThumbnail(obj, errcode)
	if not obj then
		return;
	end
	Log("thumbnail ["..obj.taskid.."] download finish. errcode=".. (errcode or 'nil') );

	local taskindex = -1;

	for i = 1, #(mapservice.waitDownloadThumbnails) do
		if mapservice.waitDownloadThumbnails[i].file_path == obj.file_path then
			taskindex = i;
			break;
		end
	end

	if taskindex >= 1 then
		if errcode==0 and gFunc_isStdioFileExist(obj.file_path) then  --succeed			
			--Log("thumbnail ["..obj.taskid.."] succeeded");
			-- if obj.userdatas then
			-- 	for i=1,#obj.userdatas do
			-- 		local userdata = obj.userdatas[i]
			-- 		if userdata.list and userdata.idx then
			-- 			local item = userdata.list:cellAtIndex(userdata.idx-1)
			-- 			if item then
			-- 				getglobal(item:GetName().."Pic"):SetTexture(obj.file_path)
			-- 			end
			-- 		end
			-- 	end
			-- else
			-- 	for i = 1, #(obj.ui_obj_names) do
			-- 		local ui_obj_name = obj.ui_obj_names[i];
			-- 		local path2 = iif(ClientMgr:isPC(), obj.file_path, obj.file_path);
			-- 		getglobal(ui_obj_name):SetTexture(path2);
			-- 		getglobal(ui_obj_name):Show()
			-- 	end
			-- end
			local path2 = iif(ClientMgr:isPC(), obj.file_path, obj.file_path);
			for i = 1, #(obj.ui_obj_names) do
				local ui_obj_name = obj.ui_obj_names[i];
				getglobal(ui_obj_name):SetTexture(path2);
				getglobal(ui_obj_name):Show()
			end
			for i = 1, #(obj.ui_loads) do
				local ui_load = obj.ui_loads[i];
				if ui_load then
					if not tolua.isnull(ui_load) then
						ui_load:setIcon(path2)
						ui_load:setVisible(true)
					end
				end
			end
		else  --failed
			Log("thumbnail ["..obj.taskid.."] failed, file not exist");
			obj.url_index = obj.url_index + 1;  --try next server
			
			for i = 1, #(obj.ui_obj_names) do
				local ui_obj_name = obj.ui_obj_names[i];
				getglobal(ui_obj_name):Show()
			end
			for i = 1, #(obj.ui_loads) do
				local ui_load = obj.ui_loads[i];
				if not tolua.isnull(ui_load) then
					ui_load:setVisible(true)
				end
			end
		end
		if obj.callback and type(obj.callback) == "function" then
			obj.callback(errcode, obj.file_path, obj.userdatas);
		end
		
		obj.packCbs = obj.packCbs or {}
		for index, packCb in ipairs(obj.packCbs) do
			pcall(packCb, errcode, obj.file_path)
		end

		table.remove(mapservice.waitDownloadThumbnails, taskindex);
	end

	mapservice.curDownloadingThumbnail = nil;
	mapservice.curDownloadingCountdown = nil;
	DownloadNextThumbnail();
end

function CancelAllDownloadingThumbnails()
	Log("CancelAllDownloadingThumbnails()");
	local pre = mapservice.waitDownloadThumbnails or {}

	mapservice.waitDownloadThumbnails = {};
	
	--正在下还是不能清 不然有概率出问题
	--mapservice.curDownloadingThumbnail = nil;
	for index, value in ipairs(pre) do
		if value.must then
			table.insert(mapservice.waitDownloadThumbnails, value)
		elseif mapservice.curDownloadingThumbnail == value then
			table.insert(mapservice.waitDownloadThumbnails, value)
		end
	end
end

function UpdateThumbnailDownload(deltatime)
	if mapservice.curDownloadingThumbnail and mapservice.curDownloadingCountdown then

		mapservice.curDownloadingCountdown = mapservice.curDownloadingCountdown - deltatime;
		if mapservice.curDownloadingCountdown <= 0 then
			mapservice.curDownloadingCountdown = nil;
			ReqDownloadCurThumbnail();
		end
	end
end

function CacheCloudMapSupport(ret)
	if not ret or "table" ~= type(ret) then
		return
	end
	local map_support_info = mapservice.map_allcloud_support_cache.map_support_info
	local owid = tonumber(ret.owid)
	if owid then	
		local info = {
			owid = owid,
			support = ret.cloud,
			cloudMapType = ret.cloud_source,
		}
		map_support_info[owid] = info
	end
end

local TestSupport_hock_cache = {}
function TestSupport_SetHockSupport(owid, value)
	TestSupport_hock_cache[owid] = value
end

function TestSupport_HockCloudNotSupport(owid)
	if get_game_env() == 1 and nil ~= TestSupport_hock_cache[owid] then
		return true, TestSupport_hock_cache[owid]		
	end
	return false
end

function CheckSupportAllCloud_IsSupport(owid)
	owid = tonumber(owid)
	if owid then
		if get_game_env() == 1 then
			local hocked, value = TestSupport_HockCloudNotSupport(owid)
			if hocked then
				return value
			end
		end
		local map_support_info = mapservice.map_allcloud_support_cache.map_support_info
		local info = map_support_info[owid]
		print("--CheckSupportAllCloud_IsSupport--info-", info)
		if info and info.support then
			return info.support==1
		end
	end
	return false
end

function CheckSupportAllCloud_HasData(owid)
	owid = tonumber(owid)
	if owid then
		local map_support_info = mapservice.map_allcloud_support_cache.map_support_info
		return nil ~= map_support_info[owid]
	end
	return false
end

function CheckSupportAllCloud_TickReqDelay()
	threadpool:work(function()
		local cache = mapservice.map_allcloud_support_cache
		if cache.check_gen or not next(cache.check_wait_owids) then
			return
		end
	
		local callFunc = function()
			local cache = mapservice.map_allcloud_support_cache
			cache.check_gen = nil
			local owids = cache.check_wait_owids
			cache.check_wait_owids = {}
	
			CheckSupportAllCloud_AsyncReqCheck(owids)
			CheckSupportAllCloud_TickReqDelay()
		end
		local delayTime = 0.1
		cache.check_gen = threadpool:timer(delayTime, delayTime, nil, callFunc)
	end)
end

function CheckSupportAllCloud_TickReqRealTime()
	local cache = mapservice.map_allcloud_support_cache
	if not next(cache.check_wait_owids) then
		return
	end
	local owids = cache.check_wait_owids
	cache.check_wait_owids = {}
	CheckSupportAllCloud_AsyncReqCheck(owids)
	-- todo check
end

function CheckSupportAllCloud_DataOutTime(wd)
	if not (wd and tonumber(wd)) then return true end
	wd = tonumber(wd)
	local cache = mapservice.map_allcloud_support_cache
	local info = cache.map_support_info[wd]

	if info and info.outTime then
		return os.time() > info.outTime
	end
	return true
end

function CheckSupportAllCloud_AddWaitOwids(owids)
	if "table" ~= type(owids) then
		return
	end
	local cache = mapservice.map_allcloud_support_cache
	
	local dirty = false
	for index, value in ipairs(owids) do
		local wd = tonumber(value)
		if wd and wd > 0 then
			if CheckSupportAllCloud_DataOutTime(wd) then
				table.insert(cache.check_wait_owids, wd)
				dirty = true
			end
		end
	end

	if dirty then
		CheckSupportAllCloud_TickReqDelay()
	end
end

function CheckSupportAllCloud_AsyncReqCheck(owids)
	threadpool:work(function()
		GetInst("RoomService"):SyncReqMapSupportQuickupRentMut(owids)
	end)
end

function CheckSupportAllCloud_SyncReqCheck(owids, outtime, showLoadLoop)
	outtime = outtime or 15
	local gid = gen_gid();	
	local bNeedWaiting = true
	
	local callback = function(_ret)
		bNeedWaiting = false;
		threadpool:notify(gid, ErrorCode.OK, _ret);
	end

	threadpool:work(function()
		GetInst("RoomService"):SyncReqMapSupportQuickupRentMut(owids, nil, 15, showLoadLoop)
		callback()
	end)

	if bNeedWaiting then
		threadpool:wait(gid, outtime);
	end
end

--不检查缓存中已经有的
function CheckSupportAllCloud_SyncReqWeakCheck(owids, outtime, showLoadLoop)
	if "table" == type(owids) then
		local needCheckWids = {}
		for index, value in ipairs(owids) do
			local wd = tonumber(value)
			if wd and wd > 0 then
				if CheckSupportAllCloud_DataOutTime(wd) then
					table.insert(needCheckWids, wd)
				end
			end
		end
	
		if #needCheckWids > 0 then
			CheckSupportAllCloud_SyncReqCheck(needCheckWids, outtime, showLoadLoop)
		end
	end
end

--
-- utils
--
function CreateMapInfoFromHttpResp(src, push_comments, push_up3, wid)
	local map = MapInfoHttp();

	map.owid = tonumber(src.wid) or 0;

	map.size = tonumber(src.size) or 0;
	map.from_tdr = false;
	map.rank = tonumber(src.rank) or 0;  --地图工坊状态：0=已上传 1=已投稿 2=已精选 3=已推荐
	map.client_ver = tonumber(src.ver) or 0;

	map.display_rank = map.rank or 0;  --用于显示的地图工坊状态

	map.name = src.name or "";
	map.memo = src.memo or "";
	map.intropics = src.intropics or {};
	if src.mul then
		local lang = tostring(get_game_lang() or 0)
		if src.mul.Name and src.mul.Name.textList and src.mul.Name.textList[lang] then
			map.name = src.mul.Name.textList[lang]
		end	

		if src.mul.Desc and src.mul.Desc.textList and src.mul.Desc.textList[lang] then
			map.memo = src.mul.Desc.textList[lang]
		end
	end

	map.worldtype = tonumber(src.worldtype) or 0;
	map.label = tonumber(src.label) or 1;
	map.open = tonumber(src.open) or 0;
	map.download_count = tonumber(src.download_count) or 0;

	--在地图详情数据里面插入收藏数量、分享数量等数据
	map.collectc = tonumber(src.collectc) or 0
	map.share = tonumber(src.share) or map.share

	map.star = tonumber(src.score) or 30;  --服务器端score是0~50之间的整数，没人评论时服务器返回nil要显示成3分
	map.star = map.star / 10;
	map.share_version = tonumber(src.share_version) or 0;
	map.have_mod = tonumber(src.have_mod) or 0;
	map.activityId = tonumber(src.special) or -1;

	map.author_name = src.uin_name or "";

	map.play_count = src.play_count or 0;
	
	

	--map.author_uin = tonumber(src.uin) or 0;
	map.author_uin =  tonumber(src.author_uin) or tonumber(src.uin) or 0;  --优先取原始作者
	map.author_frame_id = tonumber(src.head_frame_id) or 0;
	map.author_icon = tonumber(src.uin_icon) or 0;
	if map.author_name == "" then
		local callBack = function(ret)
			if ret and ret.ret then
				if  ret.ret == 1 then
					return;
				elseif ret.ret == 404 then
					--新用户
				end
				local function pcallFunction()
					t_exhibition.setRetToPoolByUin(ret, uin);
					local profile = ret.profile;
					if profile then 
						if  profile.RoleInfo then
							map.author_name = profile.RoleInfo.NickName or "";
						end
					end
				end
				pcall(pcallFunction);
			end
		end
        if t_exhibition then
            t_exhibition:GetPlayerProfileByUin(map.author_uin, callBack, nil)            
        end
	end

	if src.HasAvatar ~= nil and src.HasAvatar >0 and ClientMgr:isPureServer() == false then
		-- map.author_avt = HeadCtrl:SearchAvatarInfo(map.author_uin);
		threadpool:work(function()
			local seatInfo = avatarContentCacheByUin(map.author_uin, 1)
		    if seatInfo ~= nil then
		        SkinDataSort(seatInfo)
		        local filterData = {}
		        filterData.skin = HeadCtrl:FilterAvtData(seatInfo.skin)
		        map.author_avt = JSON:encode(filterData)
		    end
	    end)
	else
		map.author_avt = "";
	end


	map.author_vip = tonumber(src.vip) or 0;

	map.create_time = tonumber(src.create_time) or 0;
	map.week_download_count = tonumber(src.week_download_count) or 0;
	map.last_upload_time = tonumber(src.last_time) or 0;
	map.upload_count = tonumber(src.update_count) or 0;

	map.download_dir = src.dir or "";
	map.download_node = tonumber(src.node) or 0;
	local downmd5 =nil;
	if src.md5 then
		downmd5 = src.md5
	elseif   src.md5_black then
		downmd5 = src.md5_black
	end
	map.download_md5 = downmd5 or "";
	map.download_thumb_md5 = src.thumb_md5 or "";
	map.download_thumb_md5_ban = src.thumb_md5_ban or "";--如图片因自动审核被禁，则thumb_md5_ban有值
	if  src.thumb_url then
		map.download_thumb_url = src.thumb_url;      ---完整的下载url，随机截图使用
	end
	map.push_comments = push_comments or {};
	map.push_up3 = push_up3 or 0;
	map.canrecord = src.canrecord or 0;
	map.record_original_uin = src.record_original_uin or 0;
	map.translate_supportlang = src.supportlang or 0;
	map.translate_sourcelang = src.lang or 0;
	map.total = src.tips and src.tips.total or 0;
	if src.manor then
		map.specialType = tonumber(src.manor);
	end
	if src.editorSceneSwitch then
		map.editorSceneSwitch = tonumber(src.editorSceneSwitch)
	end
	--默认设置显示语言为当前客户端语言,如果不支持则设置为作者客户端语言
	if LuaInterface:band(map.translate_supportlang,math.pow(2,get_game_lang())) == math.pow(2,get_game_lang()) then
		map.translate_currentlang = get_game_lang()
	else
		map.translate_currentlang = map.translate_sourcelang
	end

    map.translate = src.translate

	--LLTODO:评论数
	map.comment_num = 0;
	if src.stars then
		for i = 1, 5 do
			map.comment_num = map.comment_num + (src.stars[i] or 0);
		end
	end

	--LLTODO:当前地图正在玩的人数
	map.play_cc = tonumber(src.play_cc) or 0;

	--总下载次数
	map.total_download_count = (src.comment and src.comment.download_count) and tonumber(src.comment.download_count) or 0

	--昨日新增下载次数
	map.yesterday_download_count = (src.comment and src.comment.dd1) and tonumber(src.comment.dd1) or 0

	--普通玩家推荐数
	map.push_up1 = (src.comment and src.comment.push_up1) and tonumber(src.comment.push_up1) or 0
	
	--教育侧地图
	--编程新工具的值为2，方便追踪地图是否从编程APP过来，值为3时表示迷你世界里新工具创建的地图
	if src.open_code then
        map.open_code = src.open_code

		--此处表示该地图表示是新工具创建的
		if src.open_code == 2 or src.open_code == 3 then
			map.editorSceneSwitch = 1
		end
	end

	--地图模版化
	-- char temptype; //模版类型： 0：非模版；1：仅供学习；2：买断
	-- char pricetype;//价格类型（char）0：免费；1：迷你币；2：迷你豆；3：迷你点  （注意：只有tempType为2的时候才会有价格）
	-- int price;     //价格
	-- long long gwid;//祖先的地图id
	-- long long pwid;//父系的地图id
	if src.template then
		if src.template.temptype then
			map.temptype = src.template.temptype
		end
		
		if src.template.pricetype then
			map.pricetype = src.template.pricetype
		end
		
		if src.template.price then
			map.price = src.template.price
		end
		
		if src.template.gwid then
			map.gwid = src.template.gwid
		end
		
		if src.template.pwid then
			map.pwid = src.template.pwid
		end
	end

	--地图话题
	map.topic = src.topic
	--Xyang 全局话题存储
	if map.topic then
		if 0 ~= map.owid then
			mapservice.mapTopicList[map.owid] = map.topic
		elseif wid then
			mapservice.mapTopicList[wid] = map.topic
		end
	end

	map.tags = {}
	if "string" == type(src.tag_list) then
		local temp = string.split(src.tag_list, ',')
		for index, value in ipairs(temp) do
			table.insert(map.tags, tonumber(value))
		end
	end


	if 0 ~= map.owid then
		mapservice.map_info_trans_cache[map.owid] = map
	elseif wid then
		mapservice.map_info_trans_cache[wid] = map
	end

	--CheckSupportAllCloud_AddWaitOwids({wid or map.owid})
	
	map.cloud = src.cloud					--是否云服地图 0：非云服 1：云服
	map.cloud_source = src.cloud_source		--云服地图产生方式 0：非云服地图 1：玩家主动设置  2：运营设置

	--缓存是否是云服地图信息
	local info = {
		owid = wid or map.owid,
		cloud = src.cloud,
		cloud_source = src.cloud_source,
	}
	CacheCloudMapSupport(info)
	
	if type(src.open_svr) ~= 'number' then
		map.opensvr = 0
	else
		map.opensvr = src.open_svr
	end
	return map;
end

function CreateMapInfoFromTdrResp(wdesc)  --see struct WorldDesc in C++
	if wdesc == nil then return end
	local map = MapInfoHttp();
	
	map.owid = wdesc.worldid;
	map.size = wdesc.fileSize;
	map.from_tdr = wdesc.fromHttp == 0;
	map.rank = 0;  --地图工坊状态：0=已上传 1=已投稿 2=已精选 3=已推荐
	map.client_ver = ClientMgr:clientVersionFromStr(wdesc.ownerCltVer);
	
	map.display_rank = map.rank;  --用于显示的地图工坊状态

	map.name = wdesc.worldname;
	map.memo = wdesc.memo;
	map.worldtype = wdesc.worldtype;
	map.label = wdesc.gameLabel;
	map.open = wdesc.open;
	map.download_count = wdesc.downloadNum;
	map.star = wdesc.creditfloat;
	map.share_version = wdesc.shareVersion;
	map.have_mod = 0;
	map.activityId = -1;

	map.author_name = wdesc.realNickName;
	map.author_uin = wdesc.realowneruin;
	map.author_icon = wdesc.realModel;
	map.author_vip = wdesc.credit;

	map.create_time = wdesc.createtime;
	map.week_download_count = 0;
	map.last_upload_time = wdesc.shareVersion;
	map.upload_count = 1;

	map.download_dir = "";
	map.download_node = 0;
	map.download_md5 = "";
	map.download_thumb_md5 = "";
	--map.download_thumb_url

	map.push_up1 = 0;	--邀请鉴赏家评测的人数

	return map;
end

function UpdateMapInfoFromHttpRespComment(map, comment)
	
	if map == nil then
		return nil;
	end

	if comment == nil then
		return map;
	end

	map.download_count = tonumber(comment.download_count) or 0;
	map.push_up1 = tonumber(comment.push_up1) or 0;	--邀请鉴赏家评测的人数
	map.push_up3 = tonumber(comment.push_up3) or 0;	--鉴赏家推荐的人数
	map.yesterday_download_count = tonumber(comment.dd1) or 0 	--昨日新增下载次数

	--在地图详情数据里面插入点踩、点赞数量、收藏数量、分享数量等数据
	map.dislike = tonumber(comment.dislike) or 0
	map.like = tonumber(comment.like) or 0
	map.collectc = tonumber(comment.collectc) or 0
	map.share = tonumber(comment.share) or map.share
	--累计被玩次数
	map.play_count = tonumber(comment.play_count) or 0;
	
	if map.comment_num == 0 then
		if comment.stars then
			for i = 1, 5 do
				map.comment_num = map.comment_num + (comment.stars[i] or 0);
			end
		end
	end

	return map;
end

--在地图详情数据里面插入收藏数量、分享数量等数据
function UpdateMapInfoRespCollectc(map, src)
	
	if map == nil then
		return nil;
	end

	if src == nil then
		return map;
	end

	map.collectc = tonumber(src.collectc) or 0
	if src.share then
		map.share = tonumber(src.share) 
	end
	
	if src.appeal then
		mapservice.mapAppealList[map.owid]={ appeal =src.appeal }
	end

	return map;
end

function CreateWorldDescFromMap(map)
	local wdesc = WorldDesc();

	local from_http;
	if map.from_tdr then
		from_http = 0;
	else
		from_http = 1;
	end

	wdesc.worldid = map.owid;
	wdesc.fromowid = map.owid;

	wdesc.fileSize = map.size;
	wdesc.from_http = from_http;
	wdesc.ownerIconFrame = map.author_frame_id;
	wdesc.ownerIconParts = map.display_rank or 0;  --地图工坊状态 仅用于显示
	
	wdesc.worldname = map.name;
	wdesc.memo = map.memo;
	wdesc.worldtype = map.worldtype;
	wdesc.gameLabel = map.label;
	wdesc.open = map.open;
	wdesc.downloadNum = map.download_count;
	wdesc.creditfloat = map.star;
	wdesc.shareVersion = map.share_version;

	wdesc.realNickName = map.author_name;
	wdesc.realowneruin = map.author_uin;
	wdesc.realModel = map.author_icon;
	wdesc.credit = map.author_vip;
	wdesc.realAVT = map.author_avt;
	if wdesc.OpenCode and map.open_code then
	    wdesc.OpenCode = map.open_code;
	end
	changeAbroadRealowneruin(wdesc)   	--转换uin 海外代理
	return wdesc;
end

function CreateTopicInfoFromHttpResp(src)
	local lang = get_game_lang()
	local isShow = false
	if src and src.lang then
		for _, v in ipairs(src.lang) do
			if type(lang) == "number" and type(v) == "number" then
				if lang == v then
					isShow = true;
				end
			end
		end
		if not isShow then
			return nil;
		end
	else
		return nil;
	end

	local index = ""
	if type(lang) == "number"  then
		if lang > 0 then
			index = index.."_"..lang
		end
	end
	local topic = {
		id = src.id or -1,
		title = src["title"..index] or "",
		txt_big = src["txt1"..index] or "",
		txt_small = src["txt2"..index] or "",
		pic_big = src.pic1,
		pic_small = src.pic2,
		map_owids = src.map_list,
		maps = {},

		--LLDO:专题红点相关.
		red_version = src.red_version or 0,

	};

	--每天都显示一次红点
	if  topic.red_version == "everyday" then
		topic.red_version = tonumber( os.date( "%Y%m%d", getServerNow() ) )
		Log("red_version=" .. topic.red_version )
	end

	return topic;
end

function OwidRander(owid_list)

	local rander = {
		all = owid_list,
		notused = {},
		used = {},
	};
	rander.__index = rander;
	rander.reset = function(self)
		self.used = {};
		self.notused = {};
		for i = 1, #self.all do
			table.insert(self.notused, self.all[i]);
		end
	end
	rander.get_next = function(self, num)
		if #self.notused == 0 then
			self:reset();
		end
		local owids = {};
		for i = 1, num do
			if #self.notused == 0 then
				break;
			end

			local index = math.random(1, #self.notused);
			local owid = self.notused[index];
			table.remove(self.notused, index);

			table.insert(self.used, owid);

			table.insert(owids, owid);
		end

		return owids;
	end

	rander:reset();

	return rander;
end

-- os.time() 改成 serverTime
function UrlAddAuth_Ex(url)
	return url .. "&" .. http_getS1Map(true) .. "&v2=1";
end

function UrlAddAuth(url)
	local uin_ = AccountManager:getUin();
	return url .. "&" .. http_getS1Map();   --uin will be added in ns_http.func.rpc
end

function UrlAddAuthUseServerTime(url)
	local uin_ = AccountManager:getUin();
	return url .. "&" .. http_getS1Map(true);   --uin will be added in ns_http.func.rpc
end

--小程序专用
function UrlAddAuthWX(url) 
	return url .. "&" .. http_getS1MapWX();
end

function  UrlAddAuthAct(url, act_)
	return url .. "&" .. http_getS2Act( act_ );   --rpc for recommend
end


function CheckHttpRpcRet(ret, nogametips)
	if type(ret) == 'table' then
		return true;
	elseif ret == nil then
		if not nogametips  and ClientMgr:isPureServer() == false then
			ShowGameTips(GetS(282), 3);
		end
		return false;
	else
		Log("http rpc return format error");
		return false;
	end
end

--in: server_url="http://map%d.mini1.cn/map/", node=3
--out: "http://map3.mini1.cn/map/"
function ServerUrlReplaceNode(server_url, node)
	return string.gsub(server_url, "%%d", tostring(node));
end

function PrintMapInfo(map)

	if map==nil then
		Log(" map = nil");
		return;
	end

	Log(" map = { owid="..tostring(map.owid).." author="..tostring(map.author_uin).." activityId="..tostring(map.activityId).." }");

--	Log("map = {");

--	Log("  owid = '"..tostring(map.owid).."'");
--	Log("  size = '"..tostring(map.size).."'");
--	Log("  from_tdr = '"..tostring(map.from_tdr).."'");
--	Log("  rank = '"..tostring(map.rank).."'");
--	Log("  client_ver = '"..tostring(map.client_ver).."'");
	
--	Log("  name = '"..tostring(map.name).."'");
--	Log("  memo = '"..tostring(map.memo).."'");
--	Log("  worldtype = '"..tostring(map.worldtype).."'");
--	Log("  label = '"..tostring(map.label).."'");
--	Log("  open = '"..tostring(map.open).."'");
--	Log("  download_count = '"..tostring(map.download_count).."'");
--	Log("  star = '"..tostring(map.star).."'");
--	Log("  share_version = '"..tostring(map.share_version).."'");
--	Log("  have_mod = '"..tostring(map.have_mod).."'");

--	Log("  author_name = '"..tostring(map.author_name).."'");
--	Log("  author_uin = '"..tostring(map.author_uin).."'");
--	Log("  author_icon = '"..tostring(map.author_icon).."'");
--	Log("  author_vip = '"..tostring(map.author_vip).."'");
--
--	Log("  create_time = '"..tostring(map.create_time).."'");
--	Log("  week_download_count = '"..tostring(map.week_download_count).."'");
--	Log("  last_upload_time = '"..tostring(map.last_upload_time).."'");
--	Log("  upload_count = '"..tostring(map.upload_count).."'");
--
--	Log("  download_dir = '"..tostring(map.download_dir).."'");
--	Log("  download_node = '"..tostring(map.download_node).."'");
--	Log("  download_md5 = '"..tostring(map.download_md5).."'");
--	Log("  download_thumb_md5 = '"..tostring(map.download_thumb_md5).."'");

	Log("}");
end

function NoticeSeverConnoisseurFQAFinish()
	ShowLoadLoopFrame(true, "file:mapservice -- func:NoticeSeverConnoisseurFQAFinish");
	local url = mapservice.getserver().."miniw/map/?act=expert_action&op=fqa_ok";
	url = UrlAddAuth(url);
	Log("  url = "..url);

	mapservice.pullingMainSpecialMaps = true;
	ShowLoadLoopFrame(true, "file:mapservice -- func:NoticeSeverConnoisseurFQAFinish");
	ns_http.func.rpc(url, RespNoticeSeverConnoisseurFQAFinish, nil,nil, ns_http.SecurityTypeHigh);   --map
end

function RespNoticeSeverConnoisseurFQAFinish(data)
	print("kekeke RespNoticeSeverConnoisseurFQAFinish", data);
	ShowLoadLoopFrame(false)
	if data.ret == 0 then
		getglobal("ConnoisseurTestPassFrame"):Show();
		ns_data.self_profile.expert.stat = 2;
	elseif data.ret == 1 then
		if data.msg == 'no_invite' then
			ShowGameTips(GetS(1279), 3);
		end
	end
end

function EncodeFromWid(id)
	return tonumber(id) - 20150320;
end

function DecodeFromWid(id)
	return tonumber(id) + 20150320;
end

function RemoveRecordMapList(DeleteMapFormWid)
	Log("RemoveRecordMapList:"..DeleteMapFormWid);

	local recorded, t = CheckRecordedFromWidByUin(AccountManager:getUin());
	print("kekeke RemoveRecordMapList", recorded, t);
	if recorded and t then
		for i=1, #(t.map_time) do
			local id = DecodeFromWid(t.map_time[i]);
			print("kekeke id:", id);
			if id == tonumber(DeleteMapFormWid) then
				table.remove(t.map_time, i);
				SaveMapFromWidFile();
				return;
			end
		end
	end
end

function chkArrayValue(tab, val)
	for i=1,#tab do
      if tab[i] == val then 
         return true
      end
	end
	return false		
end


function CheckRecordedFromWidByUin(uin)
	if next(mapservice.mapFromWidList) == nil then
		local file_ = "data/play_map_time.plist";
		local s_ = gFunc_readTxtFile( file_ );
		if s_ == "" then return false; end

		mapservice.mapFromWidList = JSON:decode(s_);
	else
		local file_ = "data/play_map_time.plist";
		local s_ = gFunc_readTxtFile( file_ );
		if s_ == "" then return false; end
		local stempMapFromFilstList =  JSON:decode(s_);
		print("kekeke mapservice.mapFromWidList begin:", mapservice.mapFromWidList);
		print("kekeke stempMapFromFilstList:", stempMapFromFilstList);
		local bhasinserted = false 
		for i=1, #(stempMapFromFilstList) do
			for j=1, #(mapservice.mapFromWidList) do
				if tostring(stempMapFromFilstList[i].uin) == tostring(mapservice.mapFromWidList[j].uin) then
					for k=1, #(stempMapFromFilstList[i].map_time) do 
						if chkArrayValue(mapservice.mapFromWidList[j].map_time,tostring(stempMapFromFilstList[i].map_time[k])) == false then
							table.insert(mapservice.mapFromWidList[j].map_time, tostring(stempMapFromFilstList[i].map_time[k]))
						end 
					end 
					bhasinserted = true
				end 
			end
			if bhasinserted == false then 
				table.insert(mapservice.mapFromWidList, {uin=tostring(stempMapFromFilstList[i].uin), map_time=stempMapFromFilstList[i].map_time})
			end 
		end 
		print("kekeke mapservice.mapFromWidList end:", mapservice.mapFromWidList);
	end   

	for i=1, #(mapservice.mapFromWidList) do
		if uin ~= 0 and tostring(mapservice.mapFromWidList[i].uin) == tostring(uin) then
			return true, mapservice.mapFromWidList[i];
		end
	end

	return false;
end

function SaveMapFromWidFile()
	local file_ = "data/play_map_time.plist";

	local jsonStr = JSON:encode(mapservice.mapFromWidList);
	gFunc_writeTxtFile(file_, jsonStr);
	print("kekeke SaveMapFromWidFile:", mapservice.mapFromWidList);
end

--地图互动数据接口（点赞数，不喜欢数，投块数，收藏数，分享数）
function GetMapActDataCount(owid,call_back,userdata)
	if not owid then return end
	--刷新时间未到，不用去请求
	if mapservice.mapActDataUpdateTime[owid] and getServerTime() <= mapservice.mapActDataUpdateTime[owid] + 5 then
		--但若本地也没缓存只能强制去请求
		local cacheData = getCacheActDataCount(owid)
		if cacheData then
			if call_back then
				call_back(cacheData, userdata)
			end
			return
		end
	end
	--请求数据
	local url = mapservice.getserver().."/miniw/map/?act=get_map_interact_data&wid="..owid;
	if ns_SRR and ns_SRR.cloud_mode == 1 then
		url = url .. '&cloud=1'
	end    
	url = UrlAddAuth(url);
	ShowLoadLoopFrame(true, "file:mapservice -- func:GetMapActDataCount");
	local call = function(ret, userdata)
		ShowLoadLoopFrame(false);
		if not userdata or userdata.owid ~= owid or (not ret) or type(ret)~="table" or ret.ret~=0 or (not ret.data) then
			return
		end
		print("GetMapActInfoCount, ret = ", ret)
		local data = ret.data
		--该地图缓存服务端下次可以更新的时间戳
		mapservice.mapActDataUpdateTime[owid] = data.expire
		--更新缓存数据
		updateMapActDataCount(owid, data)
		--回调更新数据
		if call_back then
			call_back(data, userdata)
		end
	end
	ns_http.func.rpc(url, call, userdata,nil, ns_http.SecurityTypeHigh);  --map
end


--获取地图本地缓存互动数据(若本地没缓存数据则需要强制获取)
--点赞，不喜欢，收藏，分享，投块任意一个没有就需去服务端拉取数据
function getCacheActDataCount(owid)
	local cacheData = {}
	local like_count ,dislike_count= FindLikeCount(owid)
	if (not like_count) and (not dislike_count) then
		return
	else
		cacheData.like = like_count or 0
		cacheData.dislike = dislike_count or 0
	end
	local collect_count = FindCollectCount(owid)
	if not collect_count then
		return
	else
		cacheData.collectc = collect_count or 0
	end
	local share_count = FindShareCount(owid)
	if not share_count then
		return
	else
		cacheData.share = share_count or 0
	end
	cacheData.tips = {}
	cacheData.tips.total = MapRewardClass:GetMapTotlaScore(owid)

	return cacheData
end
--更新缓存互动数据
function updateMapActDataCount(owid, data)
	if not owid or not data then
		return
	end
	--更新收藏
	UpdateCollectListCount(owid, data.collectc)
	--更新点赞、不喜欢
	UpdateLikeListCount(owid, data.like, data.dislike)
	--更新分享
	UpdateShareListCount(owid, data.share)
	--投块
	local total = (data.tips and data.tips.total) or 0
	MapRewardClass:SetMapTotlaScore(total, owid)
end

--请求开发者地图是否是收费地图（通行证）
function ReqMapPassPortInfo(wid, callback)
	if not wid then return end

	local url = mapservice.getserver().."/miniw/map/?act=getMapPassCardTime&wid="..wid
	url = UrlAddAuth(url);
	Log("ReqMapPassPortInfo url = "..url);

	ns_http.func.rpc(url, callback, nil, nil, ns_http.SecurityTypeHigh);  --map
end

function CheckPassPortInfo(worldInfo, callback)----callback just for online check
	-- local env = ClientMgr and ClientMgr:getGameData("game_env") or 0
	if AccountManager and worldInfo.fromowid > 0 and worldInfo.owneruin ~= worldInfo.realowneruin and not gIsSingleGame then
		local bPaymentMap = (worldInfo.passportflag ~= nil and worldInfo.passportflag == 1)
		if bPaymentMap then--[Desc3]地图
			--if return < -1 means free map, return == -1 means no data need req data, return >= 0 means payment map
			local iEndTime = AccountManager:getCurWorldPassPortEndTime(worldInfo.fromowid)
			if iEndTime == -1 then
				local netState = ClientMgr:getNetworkState()
				if netState == 0 then
					if callback then
						callback(-1)
					else
						ShowGameTips(GetS(3893), 3)
					end
					return -1
				end

				local RespMapPassPortInfo = function(resp)
					if CheckHttpRpcRet(resp, true) == false then
						if callback then
							callback(-1)
						else
							ShowGameTips(GetS(3893), 3)
						end
						return
					end

					if resp.ret ~= nil and resp.ret == 0 then
						local result = 0
						if resp.map_passcard ~= nil then
							if resp.map_passcard == 0 then
								iEndTime = -2
							else
								iEndTime = resp.expire

								local nowTime = AccountManager:getSvrTime()
								if nowTime >= iEndTime then result = 1 end
							end
						end
						AccountManager:setCurWorldPassPortEndTime(worldInfo.fromowid, iEndTime)
						if resp.iteminfo then
							setPassPortDef(worldInfo.fromowid, resp.iteminfo)
						end

						if callback then
							callback(result)
						end
					end
				end

				ReqMapPassPortInfo(worldInfo.fromowid, RespMapPassPortInfo)
				if callback then
					return 0
				end
			end

			if callback then
				if iEndTime >= 0 then
					local nowTime = AccountManager:getSvrTime()
					if nowTime >= iEndTime then
						callback(1)
						return 1
					end
				end
			end

		end
	end

	if callback then
		callback(0)
	end
	return 0
end

--请求开发者余额
function ReqDeveloperBalance(callback)
	if not ifNetworkStateOK() then
		ShowGameTips(GetS(37), 3)
		return
	end
	ShowNoTransparentLoadLoop()
	threadpool:delay(0.3, function()
		HideNoTransparentLoadLoop()
	end)

	local url = mapservice.getserver().."/miniw/map/?act=getCreatorWalletInfo"
	url = UrlAddAuth(url)
	Log("  url = "..url)
	local userdata = 
	{
		callback = callback
	}

	ns_http.func.rpc(url, RespDeveloperBalance, userdata,nil, ns_http.SecurityTypeHigh)  --map
end

function RespDeveloperBalance(ret, userdata)
	if not CheckHttpRpcRet(ret, true) then return end

	if userdata and userdata.callback then
		if ret.ret ~= 0 and ret.ret ~= 1 then
			ShowGameTips(GetS(759), 3)
		elseif ret.is_creator == 1 then  --是开发者
			if ret.ret == 0 then
				userdata.callback({ret=0, isdeveloper=true})
			else
				userdata.callback({ret=1, isdeveloper=true})
			end
		else
			userdata.callback({ret=0})--不是开发者
		end
	end
end

--请求使用模版
function ReqUseTempMap(pwid, wid, callback)
	if not ifNetworkStateOK() then
		ShowGameTips(GetS(37), 3)
		return
	end

	-- 线上出现pwid=0的情况，加个判断
	if not pwid or pwid==0 or not wid or not callback then
		ShowGameTips(GetS(16314), 3)
		return
	end

	local newwid = AccountManager:preCreateWorldByTemp(wid);

	ShowNoTransparentLoadLoop()
	local seq = threadpool:delay(15, function()
		HideNoTransparentLoadLoop()
	end)

	local url = mapservice.getserver().."/miniw/map/?act=useMapTemplate&wid="..pwid.."&wid2="..newwid
	url = UrlAddAuth(url)
	Log("  url = "..url)
	local userdata = 
	{
		callback = callback,
		pwid = pwid,
		wid = wid,
		newwid = newwid,
		seq = seq
	}

	ns_http.func.rpc(url, RespUseTempMap, userdata,nil, ns_http.SecurityTypeHigh)  --map
end

function RespUseTempMap(ret, userdata)
	if not CheckHttpRpcRet(ret, true) then
		HideNoTransparentLoadLoop()
		ShowGameTips(GetS(9924))
		return
	end

	if ret.ret ~= 0 then
		HideNoTransparentLoadLoop()
		ns_error_msg.show(ret, 3)
	elseif not ret.ts or not ret.wid or not ret.wid2 or not ret.sign then
		HideNoTransparentLoadLoop()
		ShowGameTips(GetS(16314))		
	elseif userdata and userdata.callback and ret.wid == userdata.pwid and ret.wid2 == userdata.newwid then
		if userdata.seq then
			threadpool.kick(userdata.seq)
		else
			HideNoTransparentLoadLoop()
		end
		userdata.callback(ret.wid, ret.wid2, ret.ts, ret.sign)
	else
		HideNoTransparentLoadLoop()
		ShowGameTips(GetS(16314))
	end
end

MyMapInfo = nil
function CheckOwnUpPermission(funtype)
	print("CheckOwnUpPermission")
	local uin = AccountManager:getUin()
	if funtype == 1 then	--地图内字牌 信纸
		local owid = AccountManager:getCurWorldId()
		if owid then
			local worldDesc = AccountManager:findWorldDesc(owid)
			if worldDesc and worldDesc.realowneruin and worldDesc.ownerIconParts and 2 == worldDesc.ownerIconParts and uin == worldDesc.realowneruin then
				return true
			end

			if 0 == worldDesc.ownerIconParts and MyMapInfo then
				for k, v in pairs(MyMapInfo) do
					if k == owid and v.rank and v.uin and tonumber(v.uin) == uin and tonumber(v.rank) == 2 then
						return true
					end
				end
			end

            if worldDesc.realowneruin and uin == worldDesc.realowneruin and g_DeveloperInfo and g_DeveloperInfo.Level then
               return true
            end
		end
	elseif funtype == 2 then	--分享地图描述
		local archiveIndex = getglobal("ShareArchiveInfoFrame"):GetClientUserData(0);
		local archiveData = GetOneArchiveData(archiveIndex);
		local worldDesc = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)
		local owid = worldDesc.worldid
		if worldDesc and worldDesc.realowneruin and worldDesc.ownerIconParts and 2 == worldDesc.ownerIconParts and uin == worldDesc.realowneruin then
			return true
		end

		if 0 == worldDesc.ownerIconParts and MyMapInfo then
			for k, v in pairs(MyMapInfo) do
				if k == owid and v.rank and v.uin and tonumber(v.uin) == uin and tonumber(v.rank) == 2 then
					return true
				end
			end
		end

		if worldDesc.realowneruin and uin == worldDesc.realowneruin and g_DeveloperInfo and g_DeveloperInfo.Level then
           return true
        end
	end

	return false
end

--获取地图下载URL地址并下载Zip文件
function DownloadZipFile(owid, path_zip)
	if not owid then return end

	local isChecker = IsUserOuterChecker(AccountManager:getUin())
	local action = "/miniw/map/?act=get_map_list_info";
	if isChecker then --审核人员修改下载方式
		action = "/miniw/map/?act=search_user_maps&op_uin=12345";
	else
		action = AddPlayableArg(action)
	end

	local map_info_url = mapservice.getserver().. action .. "&fn_list=" ..owid;
    if ns_SRR and ns_SRR.cloud_mode == 1 then
        map_info_url = map_info_url .. '&cloud=1'
    end    
	map_info_url = UrlAddAuth(map_info_url);

	local nextDownloadMap = function(flag, cowid)
		print("Func===>>>GetDownloadHttpURL!!", flag, path_zip)
		local banned = flag=="BAN!!" and true or false;
		LoaderMgr:updateFailedList(cowid, banned);

		LoaderMgr:nextDownloadMap(cowid);
	end

	local callback = function(ret)
		if ret then
			if ret[owid] or isChecker then
				local info = nil
				if ret[owid] then 
					info = ret[owid].select or ret[owid].normal
				else
					info = ret.map_info_list and ret.map_info_list[owid]
				end
				if not info then nextDownloadMap("NO INFO!!", owid); return; end

				local download_dir = info.dir or "";
				local download_md5 = info.md5 or "";
				local download_node = info.node or "0";
				local black_md5 = info.md5_black or "";

				--地图被禁 无需下载
				if info.black==1 or info.black_stat==2 or info.open_svr==4 then
					nextDownloadMap("BAN!!", owid); return;
				end
				if #download_md5 == 0 then --未知错误
					nextDownloadMap("Error!!", owid); return;
				end

				if ret.urls and #ret.urls>0 then
					local server = LoaderMgr:getDownloadServer(ret.urls[1], download_node)
					local download_url = server..download_node..'/'..download_dir..'/'..download_md5
					local taskId = HttpDownloader:downloadHttpFile(download_url, path_zip);
					--local taskId = HttpFileDownloadMgr:downloadFile(download_url, path_zip);
					print("Funk==================>>>", taskId, download_url)
					if taskId > 0 then LoaderMgr:updateLoadedList(taskId, owid) end --加入到下载列表里
				else
					print("Funk1==================>>>", taskId, download_url)
				end
			else
				nextDownloadMap("Error!!", owid);
			end
		end
	end

	ns_http.func.rpc(map_info_url, callback, nil,nil, ns_http.SecurityTypeHigh)
end

function getUploadHttpURL(owid, uin, server)
	if not owid or not uin then return end
	
	local upload_url = "";
	local action = "map_check?act=reportTextBigDataPost";
	local server_url = string.format("http://%s:8050/miniw/", server)
	
	upload_url = server_url .. action .. "&wid="..owid.."&uin=" ..uin;
	upload_url = UrlAddAuth(upload_url);

	local apiid_ = ClientMgr:getApiId() or "nil"	
	local ver_   = ClientMgr:clientVersionToStr(ClientMgr:clientVersion()) or "nil"
	local lang_  = get_game_lang()    or "nil"
	local cnty_  = get_game_country() or "nil"
	local params = "ver="..ver_.."&apiid="..apiid_.."&lang="..lang_.."&country="..cnty_

	upload_url = upload_url .. "&" .. params

	return upload_url;
end

--上传提取好的文字信息
function UploadZipFile(owid, uin, postdata)
	if not owid or not uin then return end

	local callback = function(ret)
		if ret then --
			print("Ret===========>>>>>>", ret)
		end
	end

	local upload_url = getUploadHttpURL(owid, uin);
	ns_http.func.rpc_do_http_post(map_info_url, callback, nil, postdata)
	
end

--获取录像存储的名字
function GetWorldMapRecordName(OWName)
	local num = getkv("WorldMapRecordCreateNum") or 0
	local letter = getkv("WorldMapRecordCreateLetter") or 97
	num = num + 1
	if num > 9999 then
		num = 1
		letter = letter + 1
	end
	if letter > 122 then letter = 122 end
	local lter = string.char(letter)
	local name = OWName .. string.upper(lter) .. num
	if CalculateStringWidth(name) > 22 then
		name = string.sub(OWName,1,18) .. string.upper(lter) .. num
	end
	setkv("WorldMapRecordCreateNum", num)
	setkv("WorldMapRecordCreateLetter", letter)
	return name
end

--检测当前地图存档是否为协作模式
function IsArchiveMapCollaborationMode(checkWorldid)
	if _G.IsServerBuild then
		return false
	end

	if _G.ForceUseFriendRoom and utils.env == 1 then
		return _G.ForceUseFriendRoom == 1
	end

	if not ClientCurGame then
		return false
	end
	
	checkWorldid = tonumber(checkWorldid)
	if checkWorldid and checkWorldid <= 0 then
		checkWorldid =  nil
	end
	
    if checkWorldid then
        if gFunc_IsHomeGardenWorldType(checkWorldid) then
            if AccountManager:getUin() == gFunc_GetUinByHomeGardenWorldID(checkWorldid) then
                return false
            end
        end
    end

	--MiniBase创建地图时好友联机直接返回
	if MiniBaseManager and MiniBaseManager:isMiniBaseGame() and MiniBaseManager:isAssistModeGame() then
		return true
	end
	
	local isServerSwitchOn = false
	if ns_version and ns_version.collaborationmodeon == 1 then
		isServerSwitchOn = true
	end
	
	local isRoomOwner = IsRoomOwner()
	if (isRoomOwner or AccountManager:getMultiPlayer() == 0) and ClientCurGame:isInGame() and not checkWorldid then 
		--游戏中，并且单人模式或者多人房间房主
		--print("IsArchiveMapCollaborationMode 111 ", isRoomOwner, AccountManager:getMultiPlayer())
		local worldDesc = AccountManager:getCurWorldDesc()

		return isServerSwitchOn and worldDesc ~= nil and worldDesc.owneruin == worldDesc.realowneruin and (worldDesc.open == 0 or worldDesc.open == 2 or (worldDesc.open == 1 and (worldDesc.OpenSvr == 0 or worldDesc.OpenSvr == 9)))
	else
		--print("IsArchiveMapCollaborationMode 222") 
		local worldId
		if not ClientCurGame:isInGame() then
			if checkWorldid or gCreateRoomWorldID then
				local worldDesc = AccountManager:findWorldDesc(checkWorldid or gCreateRoomWorldID)
				if worldDesc then
					--房主处于选地图开房间过程中
					--print("IsArchiveMapCollaborationMode 333 ", worldDesc.open, worldDesc.OpenSvr)
					return isServerSwitchOn and worldDesc ~= nil and worldDesc.owneruin == worldDesc.realowneruin and (worldDesc.open == 0 or worldDesc.open == 2 or (worldDesc.open == 1 and (worldDesc.OpenSvr == 0 or worldDesc.OpenSvr == 9)))
				end
			end

			--print("IsArchiveMapCollaborationMode 444") 
			--玩家处于进房过程中
			worldId = t_autojump_service.play_together.worldId
		else
			--print("IsArchiveMapCollaborationMode 555") 
			--玩家处于游戏中
			worldId = WorldMgr:getWorldId()
		end

		--print("IsArchiveMapCollaborationMode 666 ")
		return worldId ~= nil and worldId ~= 1 and t_autojump_service and t_autojump_service.play_together.GuestInCollaborationModeArr[worldId] == true
	end
end

------------------------------------------------------------------------------------------
--地图存档压缩解压失败路径显示
function ShowMapCompressErrorPath(err, errpath)
	errpath = GetS(25798) + errpath
	MessageBox(45, errpath)
end
