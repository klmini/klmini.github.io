
-------market activity--------运营活动-----(utf-8)----------

ns_ma = {      -- namespace market activity

	CELL_HEIGHT      = 182,

	_GOTO_BTN_TYPE_  = 0,             --按钮类型

	_GET_BTN_TASK_ID_  = 1,           --任务ID

	open_cell_id     = 1,             --当前打开哪一页

	server_config    = {},
	ext_gift         = false,         --国庆2018活动配置

	reward_list      = {},
	server_config_start_game_out = {},    --oppo vivo需求

	reward_random    = {},
	reward_map       = {},            --奖励id到物品对应表

	activity_has_gift = false,

	server_qq_blue   = {},          --qq蓝钻
	server_qq_yellow = {},          --qq黄钻
	server_qq_member = {},          --qq会员
	server_7k7k      = {},          --7k7k vip
	server_ma_apiid1 = {},          --官包福利

	need_press_action_task_id  = {},  --需要点击后才能领取的任务列表

	share_ma_task      = 0,           --share共享次数
	share_ma_task_max  = 2,           --默认最多两次 ns_version配置

	--任务完成后，可触发事件的事件列表
	--如果玩家的福利任务里有浇水 联网 在线时间任务，则会触发后续事件
	server_task_events = {};      --water  multigame  online_time

	welfare_config = {};--保存福利配置用于检查(check_can_show)是否展示福利广告

	remember_get_btn_clicked = false, --用于标记福利领取按钮的点击状态，防止频繁点击
	remember_notify_server_receive_award = false, --用于标记网路等待状态，网路等待中提示领取失败

	fuli_tab_max = 10,	--左侧福利按钮最大数量
	content_list_max = 50, --内容列表最多可显示的项(cell数量)

	--首充福利配置固定ID40000
	firstRechargeId = 40000,
	firstRechargeTaskId = 20200910,

	-- 开发者福利配置 固定ID
	developer_welfare_id = 30294,

	-- 
	--[[
	Author: sundy
	EditTime: 2021-08-21
	Description: 9、27号福利位ad未加载完时的call
		{
			[9] = function() end,
			[27] = function() end,
		}
		for 时不要用iv 用kv
	--]]
	ad_positon_call_pool = {},

        --年度评选
	annual_selection = {},
};


--切换账号后，清理数据
ns_ma.clear_data = function()

	--ns_ma.reward_list = {}
	ns_ma.ext_gift = {}	
	
	ns_ma.server_config_start_game_out = {}
	ns_ma.reward_random = {}
	ns_ma.reward_map = {}
	ns_ma.activity_has_gift = false
	
	ns_ma.need_press_action_task_id = {}
	ns_ma.server_task_events = {}

	ns_ma.welfare_config = {};

	ns_ma.ad_positon_call_pool = {}
end

----xml functions-----------------------------------------------------------

---------------拉取次序----
-- advert

-- 1 奖励列表 reward_list
-- 2 ma_config
-- 3 qq_blue qq_yellow


--首次加载
function MarketActivityFrame_OnLoad()
	Log( "call MarketActivityFrame_OnLoad" );
	ActivityRegisterServiceListeners();
	--this:setUpdateTime(1);

	--if  g_debug_ui == true then
		--g_debug_ui_hide = getglobal("MarketActivityFrame");
	--end
end

function ActivityRegisterServiceListeners()
    --{{{
	if AccountManager and type(AccountManager.service) == 'table' then
		AccountManager.service:listento('ma.update', OnMaUpdate);         --福利活动更新 活动状态等
		AccountManager.service:listento('avatar.update', OnAvatarUpdateListeners); 
	end
    --}}}
end

--avatar部件信息刷新 消息处理
function OnAvatarUpdateListeners(msg_)
	if msg_ and type(msg_) == "number" then
		GetInst("ShopDataManager"):UpdateSkinPartOwnedFlag(msg_)
	else
		--请求商城皮肤部件的已拥有信息,整体更新一遍
		if GetInst("ShopService") then
			GetInst("ShopService"):ReqOwnedPartInfo()
		end
	end
end

g_switch_uin = 0;   --用来统计切帐号

function WWW_file_get_qq_vip()
	-- QQ大厅移动版 apiid = 47   QQ大厅PC版 apiid = 101
	local appid_ = ClientMgr:getApiId();
	if  isQQGame() then
		local file_name_, download_  = getLuaConfigFileInfo( "qq_blue" );
		ns_http.func.downloadLuaConfig( file_name_, download_, ns_data.cf_md5s['qq_blue'],    WWW_file_get_qq_blue_callback, "cdn" );      --拉取蓝钻config
	elseif appid_ == 109 then
		local file_name_, download_  = getLuaConfigFileInfo( "qq_yellow" );
		ns_http.func.downloadLuaConfig( file_name_, download_, ns_data.cf_md5s['qq_yellow'],  WWW_file_get_qq_yellow_callback, "cdn" );      --拉取黄钻config
	elseif IsShouQChannel(appid_) then
		local file_name_, download_  = getLuaConfigFileInfo( "qq_member" );
		ns_http.func.downloadLuaConfig( file_name_, download_, ns_data.cf_md5s['qq_member'],  WWW_file_get_qq_member_callback, "cdn" );      --拉取qq会员
	elseif appid_ == 122 then
		local file_name_, download_  = getLuaConfigFileInfo( "7k7k" );
		ns_http.func.downloadLuaConfig( file_name_, download_, ns_data.cf_md5s['7k7k'],       WWW_file_get_7k7k_callback, "cdn" );           --拉取7k7k
	elseif isMaApiid1() then
		local file_name_, download_  = getLuaConfigFileInfo( "ma_apiid1" );
		ns_http.func.downloadLuaConfig( file_name_, download_, ns_data.cf_md5s['ma_apiid1'],  WWW_file_get_ma_apiid1_callback, "cdn" );      --拉取官包福利
	else
		--没有vip
	end
end


function WWW_file_get_qq_blue_callback( server_data_ )
	Log("call WWW_file_get_qq_blue_callback");
	ns_ma.server_qq_blue = server_data_;
end

function WWW_file_get_qq_yellow_callback( server_data_ )
	Log("call WWW_file_get_qq_yellow_callback");
	ns_ma.server_qq_yellow = server_data_;
end

function WWW_file_get_qq_member_callback( server_data_ )
	Log("call WWW_file_get_qq_member_callback");
	ns_ma.server_qq_member = server_data_;
end

function WWW_file_get_7k7k_callback( server_data_ )
	Log("call WWW_file_get_7k7k_callback");
	ns_ma.server_7k7k = server_data_;
end


function WWW_file_get_ma_apiid1_callback( server_data_ )
	Log("call WWW_file_get_ma_apiid1_callback");
	ns_ma.server_ma_apiid1 = server_data_;
end



--完成浇水任务
function WWW_ma_water()
	Log("call WWW_ma_water")

	if  ns_ma.server_task_events["water"] then
		--有浇水任务
	else
		return;
	end

	--只浇水一次
	if  ns_ma.water_ma_task then
		do return end;
	end
	ns_ma.water_ma_task = true;


	local uin_ = AccountManager:getUin();
	if  uin_ and uin_ >= 1000  then
		local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=water&' .. http_getS1();
		Log( reward_list_url_ );
		ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
	else
		Log( "water can not get uin_=" .. (uin_ or "nil") );
	end
end


--完成进入联网游戏任务
function  WWW_ma_multigame()
	if  ns_ma.server_task_events["multigame"] then
		--有联网任务
	else
		return;
	end

	--只上报一次
	if  ns_ma.multigame_ma_task then
		do return end;
	end
	ns_ma.multigame_ma_task = true;

	local uin_ = AccountManager:getUin();
	if  uin_ and uin_ >= 1000  then
		local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=multigame&' .. http_getS1();
		Log( reward_list_url_ );
		ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
	else
		Log( "multigame can not get uin_=" .. (uin_ or "nil") );
	end
end



--[[
	从游戏中心调起游戏完成活动任务  
	out:外部调用者名称
]]
function  WWW_ma_start_game_out( out )
	-- local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	print("WWW_ma_start_game_out(): ns_ma.start_game_out = ", ns_ma.start_game_out);
	--只能调用一次
	if  ns_ma.start_game_out then
		do return end;
	end
	ns_ma.start_game_out = true;

	local uin_ = AccountManager:getUin();
	if  uin_ and uin_ >= 1000  then
		local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=start_game_out&out=' .. out .. '&' .. http_getS1();
		Log( reward_list_url_ );
		print("WWW_ma_start_game_out(): rpc_string");
		ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
	else
		print( "start_game_out can not get uin_=" .. (uin_ or "nil") );
	end
end



--点击一次分享
function  WWW_ma_press_share(msg)
	if  ns_ma.server_task_events["share"] then
		--有share任务
	else
		Log("no share task")
		return;
	end

	if  ns_ma.share_ma_task >= ns_ma.share_ma_task_max then
		Log("share task max")
		do return end;
	end

	local uin_ = AccountManager:getUin();
	if  uin_ and uin_ >= 1000  then
		local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=share&share_msg=' .. msg .. "&" .. http_getS1();
		Log( reward_list_url_ );
		ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
		ns_ma.share_ma_task = ns_ma.share_ma_task + 1
	else
		Log( "share can not get uin_=" .. (uin_ or "nil") );
	end
end



--完成在线时长任务
function  WWW_ma_online_time()
	Log( "call WWW_ma_online_time" );

	if  ns_ma.server_task_events["online_time"] then
		--有在线时长任务
	else
		return;
	end

	--计算在线时长
	local now_        = getServerNow();
	local time_start_ = getkv( "online_time_start", "online_count" ) or g_client_start;
	local time_count_ = getkv( "online_time_count", "online_count" ) or 0;

	if  now_ - time_start_ < 86400 then
		--未跨天
		time_count_  = time_count_ + (now_ - time_start_);
	else
		--跨天清零
		time_count_  = now_ - g_client_start;
	end

	setkv( "online_time_start", now_, "online_count" )   --记录下次计时时间

	if  time_count_ < ns_ma.server_task_events["online_time"] then
		-- 未完成
		Log( "unfinish online_time:" .. time_count_ .. "/" .. ns_ma.server_task_events["online_time"] );
		setkv( "online_time_count", time_count_, "online_count" ) ;
		do return end;
	end

	--完成
	setkv( "online_time_start", nil, "online_count" );
	setkv( "online_time_count", nil, "online_count" );


	local uin_ = AccountManager:getUin();
	if  uin_ and uin_ >= 1000  then
		local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=online_time&online_time=' .. time_count_ .. '&' .. http_getS1();
		Log( reward_list_url_ );
		ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
	else
		Log( "multigame can not get uin_=" .. (uin_ or "nil") );
	end

end


--玩指定的地图任务 (世界杯地图)
function  WWW_ma_play_map( from_wid_ )
	local ret_, wid_ = check_wid( from_wid_ )
	if  not ret_ then
		return
	end

	if  ns_ma.server_task_events.play_map and ns_ma.server_task_events.play_map[wid_] then
		--有play_map任务
		ns_ma.server_task_events.play_map[wid_] = ns_ma.server_task_events.play_map[wid_] + 1
		if  ns_ma.server_task_events.play_map[wid_] > 1 then   --0+1
			Log("ignore play_map " .. wid_ .. ", cc=" .. ns_ma.server_task_events.play_map[wid_] )
			return   --已经完成
		end
	else
		return  --没有该地图任务
	end


	local uin_ = AccountManager:getUin();
	if  uin_ and uin_ >= 1000  then
		local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=play_map&wid='..wid_..'&' .. http_getS1();
		Log( reward_list_url_ );
		ns_http.func.rpc_string( reward_list_url_, ns_ma.func.download_callback_empty, nil, nil, true );           --加载lua内容
	else
		Log( "play_map can not get uin_=" .. (uin_ or "nil") );
	end
end







--设置QQ会员事件 (当有会员的时候)
--WWW_ma_qq_member_action( open_id, is_qq_member_vip,  1, call_back ) 设置会员
--WWW_ma_qq_member_action( open_id, share,      1, call_back ) 分享
--WWW_ma_qq_member_action( open_id, add_friend, 1, call_back ) 加好友
function  WWW_ma_qq_member_action( open_id, k, v, call_back )
	local uin_ = AccountManager:getUin() or get_default_uin();
	if  uin_ and uin_ >= 1000  then
		--user_action=qq_member openId=XXXX is_member=1

		--open_id 和 uin加密
		local openIdA = gFunc_getmd5( open_id .. '#ou#' .. uin_ )
		local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=set_ma_task&user_action=qq_member&openId=' .. open_id
											 .. '&' .. k .. '=' .. v
		                                     .. '&openIdA=' .. openIdA
		                                     .. '&' .. http_getS1();
		Log( reward_list_url_ );
		if  k == 'is_qq_member_vip' then
			ns_http.func.rpc       ( reward_list_url_, call_back, nil, nil, 2 );   --return table
		else
			ns_http.func.rpc_string( reward_list_url_, call_back, nil, nil, 2 );   --return string
		end
	else
		Log( "multigame can not get uin_=" .. (uin_ or "nil") );
	end
end



function sort_table_gift()
	if  ns_ma.server_config and ns_ma.reward_list then

		function sort_gift( a, b )
			local aa = 1;
			local bb = 1;
			if  ns_ma.reward_list[a.id]  and  ns_ma.reward_list[a.id].stat  then
				if     ns_ma.reward_list[a.id].stat == 2 then
					aa = 0
				elseif ns_ma.reward_list[a.id].stat == 1 then
					aa = 2
				else
					aa = 1
				end
			end

			if  ns_ma.reward_list[b.id]  and  ns_ma.reward_list[b.id].stat  then
				if     ns_ma.reward_list[b.id].stat == 2 then
					bb = 0
				elseif ns_ma.reward_list[b.id].stat == 1 then
					bb = 2
				else
					bb = 1
				end
			end


			if  aa == bb then
				return a.id < b.id
			else
				return aa > bb
			end

		end


		for page=1,   #ns_ma.server_config do
			table.sort(ns_ma.server_config[page], sort_gift )  	--table排序
		end

	end

end


local marketReportHistory = {}

function MarketActivityFrame_OnShow()
	--local print = Android:Localize();
	print("MarketActivityFrame_OnShow(): ");
	local ns_ma = _G.ns_ma
	if  false and ClientMgr:getApiId() == 999 then
		if  HttpDownloader and HttpDownloader.downloadHttpFileHttps then
			Log( "call downloadHttpFileHttps" )
			local function cb_( ret )
				Log( "downloadHttpFileHttps cb=" .. (ret or 'nil') )
			end

			local https_header = "Content-Type: application/json; charset=utf-8";
			local t_needTranslate_data={};
			t_needTranslate_data.q="qq" .. math.random(1000000,2000000);
			t_needTranslate_data.target = "zh-cn";
			local postData = JSON:encode(t_needTranslate_data);
			--url_, callback_, user_data_, pri_, post_, header_, ca_path_
			ns_http.func.rpc_string_raw_https( "https://www.sogou.com/", cb_, nil, true, postData, https_header )
		end
	end

	if  SetSlidingFrameState then
		SetSlidingFrameState(false);
	end

	local start_pos = 16;
	local cell_height = 100;

	--取两者（最大tab数，传入tab配置数）中的更小值用来给tab列表调整位置
	local minTab = (#ns_ma.server_config < ns_ma.fuli_tab_max and #ns_ma.server_config) or ns_ma.fuli_tab_max
	for i=1, minTab do
		-- <Anchor point="topleft" relativePoint="topleft" relativeTo="$parentLeftBkg" >  --MarketActivityFrameContentSliderBoxPlane
		getglobal("MarketActivityFrameFuli" .. i):SetPoint("topleft", "MarketActivityFrameFuliSliderBoxPlaneFuli", "topleft", 9, start_pos+(i-1)*cell_height);
	end

	if  ClientCurGame:isInGame() then
		if not getglobal("MarketActivityFrame"):IsReshow() then
			ClientCurGame:setOperateUI(true);
		end
	end

	local page = ns_ma.open_cell_id or 1
	local server_config = ns_ma.server_config;
	local server_config_page = server_config[page];
	print("MarketActivityFrame_OnShow(): page = ", page);
	print("MarketActivityFrame_OnShow(): server_config = ", server_config);
	print("MarketActivityFrame_OnShow(): server_config_page = ", server_config_page);
	if server_config_page then
		local id_
		if  server_config_page.id then
			id_ = server_config_page.id
		elseif server_config_page[1] and server_config_page[1].id then
			id_ = server_config_page[1].id
		end
		print("MarketActivityFrame_OnShow(): id_ = ", id_);
		if  id_ then
			print("MarketActivityFrame_OnShow(): ns_td_exposure_click = ", ns_td_exposure_click);
			ns_td_exposure_click.add( 1601, id_ )  --福利点击 上报大分类
		end
	end
	
	-- 默认打开第一个页面
	-- press_btn("MarketActivityFrameFuli1Btn");
	MAFFuli_OnClick(1)
	-- press_btn("MarketActivityFrameFuli2");
	-- press_btn("MarketActivityFrameFuli1");

	if IsShowFguiMain() then
		standReportEvent("2", "BENEFIT", "-", "view")

		
		local server_config = ns_ma.server_config;
		local tabMaxCount = ns_ma.fuli_tab_max
		for i = 1, tabMaxCount do
			if server_config[i] then
				local id = server_config[i].id or 0
				local title = server_config[i].title or "null"
				standReportEvent("2", "BENEFIT", "SecondTab", "view", {standby1=id, standby2=title})
			end
		end
	else
		local curTime = os.clock()
		if marketReportHistory and marketReportHistory.time_onShow and curTime - marketReportHistory.time_onShow <= 0.5 then
			return  --0.5s内重复打开不进行后续代码
		end

		marketReportHistory = {}
		marketReportHistory.time_onShow = curTime
		marketReportHistory.defaultID = 1
		local server_config = ns_ma.server_config and ns_ma.server_config[1] or {}
		MAFSlideCell_NewTips_Check(server_config)
		if server_config then
			for i=1, 2 do --打开时只能看到2个条目
				if i <= #server_config then
					marketReportHistory[i] = true
					if  server_config[i].action and server_config[i].action>0 then
						standReportEvent("21", "BONUS_CONTENT", "ActivityButton1", "view", {cid=server_config[i].id or 0,ctype=2,
						standby1 = ns_ma.server_config[1].title,standby2 = server_config[i].name})	
					end
					standReportEvent("21", "BONUS_CONTENT", "ActivityButton2", "view", {cid=server_config[i].id or 0,ctype=2,
					standby1 = ns_ma.server_config[1].title,standby2 = server_config[i].name})
					standReportEvent("21", "BONUS_CONTENT", "ActivityDisplay", "view", {slot=1,cid=server_config[i].id,ctype=2,
					standby1 = ns_ma.server_config[1].title,standby2 = server_config[i].name})	
					ActivityMainCtrl.marketactivity_looked[server_config[i].id] = 1
				end
			end
		end
	end
end



function MarketActivityFrame_OnHide()
	if  SetSlidingFrameState then
		SetSlidingFrameState(true);
	end

	if  ClientCurGame:isInGame() then
		if not getglobal("MarketActivityFrame"):IsRehide() then
		   ClientCurGame:setOperateUI(false);
		end
	end
end

function MarketActivityFrameContentSliderBox_OnMouseMove()
	local sliderBox = getglobal("MarketActivityFrameContentSliderBox")
	local offsetY = sliderBox:getCurOffsetY()
	
	local ns_ma = _G.ns_ma
	local topY = 0 --条目上边缘
	local bottomY = 0 --条目下边缘
	local server_config = ns_ma.server_config and ns_ma.server_config[marketReportHistory.defaultID or 1] or {}
	if server_config then
		for i=1, #server_config do
			topY = 183 * (i - 1) + offsetY
			bottomY = 183 * (i - 1) + offsetY + 173
			if topY >= 0 and bottomY <= 482 then --在曝光位置范围
				if not marketReportHistory[i] then
					marketReportHistory[i] = true
					if  server_config[i].action and server_config[i].action>0 then
						standReportEvent("21", "BONUS_CONTENT", "ActivityButton1", "view", {cid=server_config[i].id or 0,ctype=2,
						standby1 = ns_ma.server_config[marketReportHistory.defaultID or 1].title,standby2 = server_config[i].name})	
					end
					standReportEvent("21", "BONUS_CONTENT", "ActivityButton2", "view", {cid=server_config[i].id or 0,ctype=2,
					standby1 = ns_ma.server_config[marketReportHistory.defaultID or 1].title,standby2 = server_config[i].name})
					standReportEvent("21", "BONUS_CONTENT", "ActivityDisplay", "view", {slot=marketReportHistory.defaultID or 1, cid=server_config[i].id,ctype=2,
					standby1 = ns_ma.server_config[marketReportHistory.defaultID or 1].title,standby2 = server_config[i].name})	
					ActivityMainCtrl.marketactivity_looked[server_config[i].id] = 1
				end
			end
		end
	end
end

function MAFSlideCell_NewTips_Check(server_config)
	for i=1, #server_config do
		local newBkg   = getglobal( "MAFSlideCell" .. i .. "NewBkg");
		local newTxt   = getglobal( "MAFSlideCell" .. i .. "NewTxt");
		if not ActivityMainCtrl.marketactivity_looked[server_config[i].id] and ActivityMainCtrl:CheckStartTime(server_config[i].start_time) then
			newBkg:Show()
			newTxt:Show()
		else
			newBkg:Hide()
			newTxt:Hide()
		end
	end
end

function MarketActivityFrame_OnEvent()
end


function MarketActivityFrame_OnUpdate()
	--auto_refresh_xml( "ui/mobile/marketactivity.xml" );

	-- ns_ma.ad_positon_call_pool
	for k, v in pairs(ns_ma.ad_positon_call_pool) do
		if v then
			if v() then
				ns_ma.ad_positon_call_pool[k] = nil
			end
		end
	end
end

---------------------------------------------------------------------------
--切换活动
function MAFFuli_OnClick(defaultID)
	local id = defaultID or this:GetParentFrame():GetClientID();
	
	Log( "call MAFFuli_OnClick, id=" .. id);
	--[[
	Author: sundy
	EditTime: 2021-08-21
	Description: 切换页时清掉广告的回调
	另一处 ActivityMainFrame:ShowActivityByType()
	--]]
	ns_ma.ad_positon_call_pool = {}
	ns_ma.func.resetMAUI(id);
	getglobal("MItemTipsFrame"):Hide();
	ActivityMainCtrl:CheckRedTagForWelfare(true);

	if IsShowFguiMain() then
		local tmpId = ns_ma.server_config[id].id or 0
		local title = ns_ma.server_config[id].title or "null"
		standReportEvent("2", "BENEFIT", "SecondTab", "click", {standby1=tmpId, standby2=title})
		standReportEvent("2", "BENEFIT", "Benefit", "view", {standby1=tmpId, standby2=title})	
	else
		if defaultID == nil then --默认打开不上传埋点,点击时上传
			standReportEvent("21", "BONUS_CONTENT", "ActivityPit", "click", {slot=id,cid=ns_ma.server_config[id].id,ctype=2,standby1 = ns_ma.server_config[id].title})
			marketReportHistory = {}
			marketReportHistory.defaultID = id
			local server_config = ns_ma.server_config[id] or {}
			MAFSlideCell_NewTips_Check(server_config)
			for i=1, 2 do --打开时只能看到2个条目
				if i <= #server_config then
					marketReportHistory[i] = true
					if  server_config[i].action and server_config[i].action>0 then
						standReportEvent("21", "BONUS_CONTENT", "ActivityButton1", "view", {cid=server_config[i].id or 0,ctype=2,standby1 = ns_ma.server_config[id].title,standby2 = server_config[i].name})	
					end
					standReportEvent("21", "BONUS_CONTENT", "ActivityButton2", "view", {cid=server_config[i].id or 0,ctype=2,standby1 = ns_ma.server_config[id].title,standby2 = server_config[i].name})
					standReportEvent("21", "BONUS_CONTENT", "ActivityDisplay", "view", {slot=id,cid=server_config[i].id,ctype=2,standby1 = ns_ma.server_config[id].title,standby2 = server_config[i].name})	
					ActivityMainCtrl.marketactivity_looked[server_config[i].id] = 1	
				end
			end
		end
	end

	if  ns_ma.server_config[id] then
		local id_
		if  ns_ma.server_config[id].id then
			id_ = ns_ma.server_config[id].id
		elseif ns_ma.server_config[id][1] and ns_ma.server_config[id][1].id then
			id_ = ns_ma.server_config[id][1].id
		end

		if  id_ then
			ns_td_exposure_click.add( 1601, id_ )  --福利点击 上报大分类
		end


		--是否有广告(统计上报)
		for i=1, #ns_ma.server_config[id] do
			if  ns_ma.server_config[id][i] and ns_ma.server_config[id][i].id then
				local task_id_ = ns_ma.server_config[id][i].id
				if  ns_ma.reward_list[task_id_] then
					if  ns_ma.reward_list[task_id_].has_ad then
						if IsAdUseNewLogic(9) then
							StatisticsADNew('show', 9);	
						else
							StatisticsAD('show', 9);	
						end
						--break;
					elseif  ns_ma.reward_list[task_id_].has_ad15 then
						if IsAdUseNewLogic(15) then
							StatisticsADNew('show', 15);	
						else
							StatisticsAD('show', 15);	
						end
						--break;
					elseif ns_ma.reward_list[task_id_].has_ad27 then
						if IsAdUseNewLogic(27) then
							StatisticsADNew('show', 27);	
						else
							StatisticsAD('show', 27);	
						end
					end
				end
			end
		end
	end

end


--用来做活动跳转
function jump_MAFFuli_OnClick(id_)
	ns_ma.func.resetMAUI(id_);
	ActivityMainCtrl:CheckRedTagForWelfare(true);
	local slide_ = getglobal("MarketActivityFrameContentSliderBox");
	slide_:resetOffsetPos();
end


--function MAFCellBtn_OnClick()
	--Log( this:GetName() .. ", id=" .. this:GetClientID() );
--end


--跳转商店按钮
function MAFBtnGoto_OnClick()
	
	local btn_goto_type = this:GetClientUserData( ns_ma._GOTO_BTN_TYPE_ );

	local task_id_ = this:GetClientID()
	
	local id = ""
	if ns_ma.server_config[task_id_] then
		if  ns_ma.server_config[task_id_].id then
			id = ns_ma.server_config[task_id_].id
		elseif ns_ma.server_config[task_id_][1] and ns_ma.server_config[task_id_][1].id then
			id = ns_ma.server_config[task_id_][1].id
		end
	end
	local standby1 = ""
	local standby2 = ""
	if ns_ma.open_cell_id and ns_ma.server_config[ns_ma.open_cell_id] then 
		standby1 = ns_ma.server_config[ns_ma.open_cell_id].title
		local parentId = this:GetParentFrame():GetClientID()
		if parentId and ns_ma.server_config[ns_ma.open_cell_id] and ns_ma.server_config[ns_ma.open_cell_id][parentId] then
			standby2 = ns_ma.server_config[ns_ma.open_cell_id][parentId].name 
		end 
	end 
	standReportEvent("21", "BONUS_CONTENT", "ActivityButton1", "click", {cid=task_id_,ctype=2,standby1 = standby1,standby2 = standby2})
	Log( this:GetName() .. ", id=" .. task_id_ .. ", btn_type=" .. btn_goto_type );

	--是否有id事件
	if  task_id_ > 0 then
		if  ns_ma.need_press_action_task_id[ task_id_ ] then
			ns_ma.need_press_action_task_id[ task_id_ ].pressed = 1
			--需要刷新UI
			ActivityMainCtrl:CheckRedTagForWelfare(true)
		end
	end

	if  tonumber(btn_goto_type) < 80 then   --99 98
		--隐藏奖励frame
		ActivityMainCtrl:AntiActive()
	end


	local data = {}
	local page = ns_ma.open_cell_id or 1
	local config = ns_ma.server_config[page] or {}

	for k,v in pairs(config) do
		if v and type(v) == 'table' and v.id and v.id == task_id_ then
			data = v
			break
		end
	end
	--jump_app = "fx_wb", --fx_qq,fx_qqkj,fx_wx,fx_pyq,fx_wb 客户端资源为逻辑内增加判断逻辑，判断对应APP是否有安装（qq 微信 微博）
	--url_ext = "https://www.mini1.cn/", --资源位配置内增加H5字段，用于未安装对应应用时的跳转方式
	local params_ext = {}
	params_ext.jump_app = data.jump_app
	params_ext.url_ext = data.url_ext
	global_jump_ui( btn_goto_type, this:GetClientString(), nil, params_ext);
	welfare_jump_report(btn_goto_type, task_id_);

	--统一处理，除了跳外链,APP之外的跳转，都关闭页面
	if btn_goto_type ~= 99 and IsUIFrameShown("ActivityMainFrame") then
		ActivityMainCtrl:AntiActive()
	end
end


--完成了[Desc5]事件
function MAFB_finish_buy()
	if  ns_ma.server_task_events and ns_ma.server_task_events.buy then
		ActivityMainCtrl:RequestWelfareRewardData()
	end
end



--领取奖励按钮
function MAFBtnGet_OnClick(page_index,extend)
	--local print = Android:Localize();
	print("MAFBtnGet_OnClick===")
	local this = this
	local ad_show = nil
	if extend and extend.task_id then
		ad_show = extend.task_id
	end
	--ns_ma.func.resetMAUI(id);
	GameRewardFrameSetMafBtnExtend(nil)
	GameRewardFrameSetMafBtnExtend2(nil)
	local pageId = 0
	local cellId = 0
	local task_id = 0
	if page_index ~= nil then
		if page_index == 51 then	--首充福利
			task_id = ns_ma.firstRechargeTaskId
		end
		pageId = page_index
		cellId = 1
	else
		task_id = this:GetClientUserData( ns_ma._GET_BTN_TASK_ID_ );
		pageId = ns_ma.open_cell_id
		cellId = this:GetParentFrame():GetClientID()
	end

	if extend and extend.ADTaskId then
		task_id =  extend.ADTaskId
	end

	if extend and extend.pageId and extend.cellId then
		pageId = extend.pageId 
		cellId = extend.cellId
	end

	local server_config_ = ns_ma.server_config[pageId][cellId]

	if  not (type(server_config_) == 'table') then
		return
	end
	GameRewardFrameSetMafBtnExtend({pageId = pageId,cellId = cellId})
	GameRewardFrameSetMafBtnExtendTaskId(ad_show)
	GameRewardFrameSetMafBtnExtendADTaskId(task_id)
	
	local standby1 = ""
	local standby2 = ""
	if pageId and ns_ma.server_config[pageId] then 
		standby1 = ns_ma.server_config[pageId].title
		if cellId and ns_ma.server_config[pageId][cellId] then
			standby2 = ns_ma.server_config[pageId][cellId].name 
		end 
	end 
	if IsShowFguiMain() then
		standReportEvent("2", "BENEFIT", "GetButton", "click", {standby1=ns_ma.server_config[pageId].id or 0, standby2=server_config_.title or "null"})		
	else
		standReportEvent("21", "BONUS_CONTENT", "ActivityButton2", "click", {cid=server_config_.id or "",ctype=2,standby1 = standby1,standby2 = standby2})
	end
	
	local gift_ = {}
	if ns_ma.reward_random[task_id] and ns_ma.reward_random[task_id] > 0 and server_config_.gift_random then
		gift_ = server_config_.gift_random[ns_ma.reward_random[task_id]]
	else
		gift_ = server_config_.gift
	end
	--如果服务发来奖励
	if  ns_ma.reward_list[task_id] and ns_ma.reward_list[task_id].gift then
		gift_ = ns_ma.reward_list[task_id].gift;
	end

	print("MAFBtnGet_OnClick(): ns_ma.reward_list[task_id] = ", ns_ma.reward_list[task_id]);	
	--检查仓库是否已满
	local t_reward_id = {};
	if gift_ then for i=1,#(gift_) do
		table.insert(t_reward_id,gift_[i].id);
	end end
	if AccountManager.itemlist_can_add and not AccountManager:itemlist_can_add(t_reward_id) then
		StashIsFullTips();
		return;
	end

	print(ns_ma.reward_list[task_id])
	if  ns_ma.reward_list[task_id].has_ad or ad_show == "showad9" then
		Log("has_ad pressed")
		if OnReqWatchADWelfare9 then
			OnReqWatchADWelfare9(task_id, pageId, cellId, ad_show, this)			
		end
	elseif  ns_ma.reward_list[task_id].has_ad27 or ad_show == "showad27" then
		Log("has_ad27 pressed")	
		if OnReqWatchADWelfare27 then
			OnReqWatchADWelfare27(task_id, pageId, cellId, ad_show, this)			
		end
	elseif  ns_ma.reward_list[task_id].has_ad15 then
		--点击了vivo广告 15
		Log("has_ad15 pressed Get")
		RequestWelfareAwardCallback(false, task_id, pageId, cellId, this)
	else
		Log("has_ad false")
		--这里做频繁点击和等待网络回包的处理
		if ns_ma.remember_get_btn_clicked then
			ShowGameTips(GetS(3306), 3)
			return
		else
			ns_ma.remember_get_btn_clicked = true
			threadpool:work(function ()
				threadpool:wait(1) --点击间隔1s
				ns_ma.remember_get_btn_clicked = false
			end)

			if ns_ma.remember_notify_server_receive_award then
				ShowGameTips(GetS(3402), 3) --网络等待中，提示稍后再试
				threadpool:work(function ()
					threadpool:wait(5) --等待5s
					ns_ma.remember_notify_server_receive_award = false
				end)
				return
			end
		end
		
		RequestWelfareAwardCallback(false, task_id, pageId, cellId, this)
	end
end

function MAFRewardsGet(taskId, serverConfig)
	local task_id = taskId;
	local server_config_ = serverConfig
	local gift_ = {}
	if ns_ma.reward_random[task_id] and ns_ma.reward_random[task_id] > 0 and server_config_.gift_random then
		gift_ = server_config_.gift_random[ns_ma.reward_random[task_id]]
	else
		gift_ = server_config_.gift
	end
	--如果服务发来奖励
	if  ns_ma.reward_list[task_id] and ns_ma.reward_list[task_id].gift then
		gift_ = ns_ma.reward_list[task_id].gift;
	end

	print("MAFRewardsGet: ns_ma.reward_list[task_id] = ", ns_ma.reward_list[task_id]);	
	--检查仓库是否已满
	local t_reward_id = {};
	if gift_ then for i=1,#(gift_) do
		table.insert(t_reward_id,gift_[i].id);
	end end
	if AccountManager.itemlist_can_add and not AccountManager:itemlist_can_add(t_reward_id) then
		StashIsFullTips();
		return;
	end

	local function cb_requestAward()
		local bUse = false
		local MafBtnExtend = GameRewardFrameGetMafBtnExtend()
		if MafBtnExtend and MafBtnExtend.task_id then
			if MafBtnExtend.task_id == 'showad27' or MafBtnExtend.task_id == 'showad9' then
				bUse = true
			end
		end

		ns_ma.func.requestAward( task_id, ns_ma.open_cell_id, nil, bUse);

		--将这个任务设置为已经领取
		if  ns_ma.reward_list[task_id] and ns_ma.reward_list[task_id].stat then
			ns_ma.reward_list[task_id].stat = 2;  --已经领取
		end

		--this:Disable();
		ActivityMainCtrl:CheckRedTagForWelfare(true);

		--如果是continued任务 再次拉取福利
		if  ns_ma.reward_list[task_id].static and ns_ma.reward_list[task_id].static.continued then
			ActivityMainCtrl:RequestWelfareRewardData("continued=1")
		end
	end

	cb_requestAward();
end


--增加或者减少积分 迷你宝盒
function add_miniTreasures_score( rewardList )
	local giftIndex = ns_ma.ext_gift and ns_ma.ext_gift.index;
	if  not giftIndex or giftIndex == "" then
		return;
	end

	if  ns_ma.ext_gift and	
		ns_ma.ext_gift.user_data and
		ns_ma.ext_gift.user_data.trade_score and
		ns_ma.ext_gift.user_data.trade_score[rewardList.id] then
		ns_ma.ext_gift.user_data.trade_score[rewardList.id].score = ns_ma.ext_gift.user_data.trade_score[rewardList.id].score + rewardList.num
	end
end

function UpdateMarketActivityRightBtnState()
	--local print = Android:Localize();
	local ns_ma = _G.ns_ma
	--右侧按钮列表
	local page = ns_ma.open_cell_id;
	
	if  ns_ma.server_config and #ns_ma.server_config > 0 then

		--第几个按钮
		if ns_ma.server_config[page] and #ns_ma.server_config[page] > 0 then

			for i=1, ns_ma.content_list_max do
				if i <= #ns_ma.server_config[page] then

					local getBtnName   = getglobal( "MAFSlideCell" .. i .. "GetText");
					local getBtnNormal = getglobal( "MAFSlideCell" .. i .. "GetNormal");

					getglobal( "MAFSlideCell" .. i .. "Get"):SetChecked(true);
					getglobal( "MAFSlideCell" .. i .. "Get"):Disable();
					-- getglobal( "MAFSlideCell" .. i .. "GetText"):SetTextColor(150, 150, 150);
					-- getBtnNormal:SetTextureHuiresXml("ui/mobile/texture/uitcomm1.xml");
					-- getBtnNormal:SetTexUV("hdfl_btn_lq02.png");
					getBtnNormal:SetGray(true);
					
					local time_out_ = false;
					local end_time_ = uu.get_time_stamp( ns_ma.server_config[page][i].end_time );
					if  end_time_ < os.time() then	--过期
						-- getglobal( "MAFSlideCell" .. i .. "GetText"):SetTextColor(150, 160, 150);
						getglobal( "MAFSlideCell" .. i .. "GetText"):SetText(StringDefCsv:get(3412) );   --已过期
						time_out_ = true;
					else
						--goto按钮文字和领取按钮文字
						if  ns_ma.server_config[page][i].action_txt then
							getglobal("MAFSlideCell" .. i  .. "GotoText"):SetText( ns_ma.server_config[page][i].action_txt );
						end

						if  ns_ma.server_config[page][i].get_txt then
							getglobal("MAFSlideCell" .. i  .. "GetText"):SetText( ns_ma.server_config[page][i].get_txt );
						else
							getglobal( "MAFSlideCell" .. i .. "GetText"):SetText(StringDefCsv:get(3028));       --领取奖励
						end
						-- getBtnNormal:SetGray(false);
						-- local gotoBtnNormal = getglobal( "MAFSlideCell" .. i .. "GotoNormal");
						-- if  gotoBtnNormal then
						-- 	gotoBtnNormal:SetTextureHuiresXml("ui/mobile/texture/uitcomm1.xml");
						-- 	gotoBtnNormal:SetTexUV("hdfl_btn_tz.png");
						-- end

					end

					if  ns_ma.server_config[page][i] and ns_ma.server_config[page][i].task_conditions and
							ns_ma.server_config[page][i].task_conditions.ad_press_cb then
						--一次都没看过广告的情况，将观看按钮置亮
						if  not ns_ma.reward_list[ ns_ma.server_config[page][i].id ] then
							ns_ma.reward_list[ ns_ma.server_config[page][i].id ] = {}
						end
					end


					local in_game = nil
					--red tag
					for k, v in pairs(ns_ma.reward_list) do
						--Log( "1=" .. k .. " / " .. ns_ma.server_config[page][i].id .. " / stat2=" .. (v.stat or "") );
						if k == ns_ma.server_config[page][i].id then
							if  v.show_txt and  ns_ma.server_config[page][i].title then
								getglobal("MAFSlideCell" .. i .. "Title"):SetText( ns_ma.server_config[page][i].title .. " " .. v.show_txt );
							end

							in_game = v.in_game
							
							--是否需要点击后才能领取
							local stat_ = v.stat
							if  ns_ma.server_config[page][i].need_press_action == 1 then
								if  stat_ == 1 then
									if  ns_ma.need_press_action_task_id[ k ] and ns_ma.need_press_action_task_id[ k ].pressed == 1 then
										--已经点击
									else
										--未点
										stat_ = 0
										-- local gotoBtnNormal = getglobal( "MAFSlideCell" .. i .. "GotoNormal");
										-- if  gotoBtnNormal then
										-- 	gotoBtnNormal:SetTextureHuiresXml("ui/mobile/texture/uitcomm1.xml");
										-- 	gotoBtnNormal:SetTexUV("hdfl_btn_lq01.png");
										-- end
									end
								end
							end

							--Log( "2=" .. k .. " / " .. ns_ma.server_config[page][i].id .. " / stat2=" .. (stat_ or "") );
							-- if ns_ma.server_config[page][i].get_btn_action then
							-- 	print('sundy----->>>' , ns_ma.server_config[page][i] , stat_);
							-- end
							if  stat_ == 1 then			--可领
								getglobal( "MAFSlideCell" .. i .. "Get"):SetChecked(false);
								getglobal( "MAFSlideCell" .. i .. "Get"):Enable();

								if  time_out_ == true then
									getglobal( "MAFSlideCell" .. i .. "GetText"):SetText(StringDefCsv:get(3028));       --领取奖励
								end
								getBtnNormal:SetGray(false);

								--[[
								Author: sundy
								EditTime: 2021-08-21
								Description: 对广告位判断广告的加载状态设置按钮的状态
								--]]
								if ns_ma.server_config[page][i].get_btn_action then
									local action_to_id = {
										ad = 9,
										ad27 = 27,
									}
									local adId = action_to_id[ns_ma.server_config[page][i].get_btn_action]
									if adId then	
										if IsAdUseNewLogic(adId) then
											local callback = function(result)
												if not result then
													getglobal( "MAFSlideCell" .. i .. "Get"):Disable();
													getBtnNormal:SetGray(true);
		
													if not ad_data_new.getAdLoadStatus(adId) then
														-- 回调方法处理广告加载完成时更新按钮状态
														ns_ma.ad_positon_call_pool[adId] = function()
															if ad_data_new.getAdLoadStatus(adId) then
																getglobal( "MAFSlideCell" .. i .. "Get"):SetChecked(false);
																getglobal( "MAFSlideCell" .. i .. "Get"):Enable();
																return true
															end
															return false
														end
													end
												end
											end
											GetInst("AdService"):IsAdCanShow(adId, callback)
										else
											local bAdLoadStatus = t_ad_data.getAdLoadStatus(adId)
											if not bAdLoadStatus then
												getglobal( "MAFSlideCell" .. i .. "Get"):Disable();
												getBtnNormal:SetGray(true);
		
												-- 回调方法处理广告加载完成时更新按钮状态
												-- ns_ma.ad_positon_call_pool
												ns_ma.ad_positon_call_pool[adId] = function()
													if t_ad_data.getAdLoadStatus(adId) then
														getglobal( "MAFSlideCell" .. i .. "Get"):SetChecked(false);
														getglobal( "MAFSlideCell" .. i .. "Get"):Enable();
														return true
													end
													return false
												end
											end
										end
									end				
								end
							elseif stat_ == 2 then		--已领
								--getglobal( "MAFSlideCell" .. i .. "GetText"):SetTextColor(150, 160, 150);
								--getglobal( "MAFSlideCell" .. i .. "GetText"):SetText(StringDefCsv:get(3411));           --已领取
								-- getBtnName:SetTextColor( 118, 96, 64 );
								getBtnName:SetText(StringDefCsv:get(3411));
								-- getBtnNormal:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
								-- getBtnNormal:SetTexUV("dljl_ylq01.png");
								getBtnNormal:SetGray(true);
							else
								if  ns_ma.server_config[page][i] and ns_ma.server_config[page][i].task_conditions and
									ns_ma.server_config[page][i].task_conditions.ad_press_cb then
									--去看广告
									getglobal( "MAFSlideCell" .. i .. "Get"):SetChecked(false);
									getglobal( "MAFSlideCell" .. i .. "Get"):Enable();

									--[[
									Author: sundy
									EditTime: 2021-08-21
									Description: 对广告位判断广告的加载状态设置按钮的状态
									--]]
									if ns_ma.server_config[page][i].get_btn_action then
										local action_to_id = {
											ad = 9,
											ad27 = 27,
										}
										local adId = action_to_id[ns_ma.server_config[page][i].get_btn_action]
										if adId then
											if IsAdUseNewLogic(adId) then																																		
												local callback = function(result)
													if not result then
														getglobal( "MAFSlideCell" .. i .. "Get"):Disable();
														getBtnNormal:SetGray(true);
			
														if not ad_data_new.getAdLoadStatus(adId) then
															-- 回调方法处理广告加载完成时更新按钮状态
															ns_ma.ad_positon_call_pool[adId] = function()
																if ad_data_new.getAdLoadStatus(adId) then
																	getglobal( "MAFSlideCell" .. i .. "Get"):SetChecked(false);
																	getglobal( "MAFSlideCell" .. i .. "Get"):Enable();
																	return true
																end
																return false
															end
														end
													end
												end
												GetInst("AdService"):IsAdCanShow(adId, callback)
											else	
												local bAdLoadStatus = t_ad_data.getAdLoadStatus(adId)
												if not bAdLoadStatus then
													getglobal( "MAFSlideCell" .. i .. "Get"):Disable();
													getBtnNormal:SetGray(true);
		
													-- 回调方法处理广告加载完成时更新按钮状态
													-- ns_ma.ad_positon_call_pool
													ns_ma.ad_positon_call_pool[adId] = function()
														if t_ad_data.getAdLoadStatus(adId) then
															getglobal( "MAFSlideCell" .. i .. "Get"):SetChecked(false);
															getglobal( "MAFSlideCell" .. i .. "Get"):Enable();
															return true
														end
														return false
													end
												end
											end
										end							
									end
								else
									--不能领取
									getBtnNormal:SetGray(true);
								end
							end

							break;
						end
					end

					-- 冒险活动
					if ns_ma.server_config[page][i].risk_activity and ns_ma.server_config[page][i].risk_activity == 1 then
						local task_conditions = ns_ma.server_config[page][i].task_conditions
						local title = ns_ma.server_config[page][i].title
						if title then
							local strList = split(title,"%s")
							local conTab = {}
							local str = ""
							local idx = 1
							for _, val in pairs(task_conditions) do
								if GetInst("SpringFestivalManager") then
									local index = GetInst("SpringFestivalManager").typeIndex[_]
									if index then
										if type(val) == "table" then
											for _x,_y in pairs(val) do
												local num = 0
												local name = ""
												if type(_x) == "number" then
													_x = tostring(_x)
												end
												if in_game and in_game[_] and in_game[_][_x] then
													num = in_game[_][_x]
												end
												local s = strList[idx] or ""
												if index >= 1 and index <= 3 then
													local def = MonsterCsv:get(_x)
													if def then
														name = def.Name
													end
													str = str .. s .. name
													idx = idx + 1
													s = strList[idx] or ""
													str = str .. s .. (num .. "/" .. _y)
													idx = idx + 1
												elseif index == 4 or index == 7 then
													local def = BlockDefCsv:get(_x)
													if def then
														name = def.Name
													end
													str = str .. s .. name
													idx = idx + 1
													s = strList[idx] or ""
													str = str .. s .. (num .. "/" .. _y)
													idx = idx + 1
												elseif index == 9 then
													str = str .. s .. (num .. "/" .. _y)
													idx = idx + 1
												elseif index == 5 then
													if GetInst("SpringFestivalManager").confer_type then
														name = GetInst("SpringFestivalManager").confer_type[_x] or ""
													end
													str = str .. s .. name
													idx = idx + 1
													s = strList[idx] or ""
													str = str .. s .. (num .. "/" .. _y)
													idx = idx + 1
												elseif index >= 100 and index <= 103 then
													if in_game and in_game[_] then
														num = in_game[_][_y] or 0
													end
													str = str .. s .. (num .. "/" .. 1)
													idx = idx + 1
												end
											end
										elseif type(val) == "number" then
											local num = 0
											if in_game and in_game[_] then
												num = in_game[_][1] or 0
											end
											local s = strList[idx] or ""
											if index == 6 or index == 8 or index >= 10 and index <= 11 then
												str = str .. s .. (num .. "/" .. val)
												idx = idx + 1
											end
										end
									end
								end
							end
							local lastStr = strList[idx] or ""
							str = str .. lastStr
							getglobal("MAFSlideCell" .. i .. "Title"):SetText(str)
						end
					end

					--幸运盲盒任务
					if ns_ma.server_config[page][i] and ns_ma.server_config[page][i].task_conditions then
						local task_conditions = ns_ma.server_config[page][i].task_conditions
						local task_id = ns_ma.server_config[page][i].id
						local totalNum = 0
						for key, val in pairs(task_conditions) do
							if key == 'blind_box_join' or key == 'blind_box_run' or key == 'blind_box_repel' then
								totalNum = val
								local title = ns_ma.server_config[page][i].title or ''
								MarketActivity_ShowLuckSquare_Task(task_id,title,totalNum,i)
							end
						end
					end
				end
			end
		end
	end
end 

--显示幸运方块进度
function MarketActivity_ShowLuckSquare_Task(task_id,title,totalNum,index)
	local num = 0
	for k, v in pairs(ns_ma.reward_list) do
		if k == task_id then
			num = v.cc
			break
		end
	end
	local str =  title .."("..num .. "/" .. totalNum..")"
	getglobal("MAFSlideCell" .. index .. "Title"):SetText(str)
end

--是否显示红点 oppo和vivo渠道单独奖励
function  if_showOppoVivoRedTag()
	-- local print = Android:Localize();
	-- print(debug.traceback());
	if  ns_ma.server_config_start_game_out and ns_ma.server_config_start_game_out.id then
		-- print("if_showOppoVivoRedTag(): ns_ma.server_config_start_game_out.id = ", ns_ma.server_config_start_game_out.id);
		local id_ = ns_ma.server_config_start_game_out.id
		if  ns_ma.reward_list and ns_ma.reward_list[ id_ ] and ns_ma.reward_list[ id_ ].stat == 1 then
			-- print("if_showOppoVivoRedTag(): ns_ma.reward_list[id_] = ", ns_ma.reward_list[id_]);
			return true
		end
	end
	return false
end


--设置玩地图info 描述信息
function ns_ma.ma_play_map_set_enter( info_ )
	--Log("call ma_play_map_set_enter")
	ns_ma.play_map_info = info_
end


--开始玩某一个地图
function ns_ma.play_map_report()
	local fromowid, gameLabel = 0, 0
	local worldDesc = AccountManager:getCurWorldDesc();
	if  worldDesc then
		--自建游戏(单机或联网) 能拿到 worldDesc
		Log( "ma_play_map: worldDesc fromowid=" .. worldDesc.fromowid .. ", worldid="  .. worldDesc.worldid )
		fromowid, gameLabel = worldDesc.fromowid, worldDesc.gameLabel
	else
		--联网游戏模式
		--fromowid, gameLabel 在ns_ma.play_map_info里设置
		if  ns_ma.play_map_info then
			if  ns_ma.play_map_info.fromowid then
				fromowid = ns_ma.play_map_info.fromowid
			end

			if  ns_ma.play_map_info.gamelabel then
				gameLabel = ns_ma.play_map_info.gamelabel
			end
		end
	end

	--进行任务上报
	WWW_ma_play_map( fromowid )

	--进入游戏上报
	if  not ns_ma.play_map_info and worldDesc ~= nil then
		Log( "ERROR: play_map can not set where enter" )
		if  worldDesc.fromowid == 0  then
			--新建立的图 未分享
		elseif  worldDesc.fromowid == worldDesc.worldid then
			--玩家还没上传的图
		else
			Log( debug.traceback())
		   --ma_play_map_set_enter
		end
	else
		NotifyServerWhenEnterMap(fromowid, gameLabel, ns_ma.play_map_info );
		ns_ma.play_map_info = nil  --上报完成后清理
	end

end


-----------------------------------逻辑函数部分--------------------



ns_ma.func =         --避免和其他全局函数冲突
{
	--请求服务器获得第 open_cell_id 项活动的第 item_id 个项奖励
	-- new add by : sundy   reason : bUseOverSeasTemp 指定获取物品时的展示样式
	requestAward = function( task_id, open_cell_id, item_id, bUseOverSeasTemp)
		-- local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
		local ns_ma = _G.ns_ma;
		print("requestAward(): task_id = ", task_id);
		print("requestAward(): open_cell_id = ", open_cell_id);
		print("requestAward(): item_id = ", item_id);
		--Log( "requestAward: task_id=" .. (task_id or "nil") .. ", page=" .. (open_cell_id or "nil") .. ", itemid=" .. (item_id or "nil") );

		local reward_random = ns_ma.reward_random
		local reward_map = ns_ma.reward_map
		if task_id and task_id > 0 then
			ns_ma.remember_notify_server_receive_award = true --标记
			-- local result, avatorList, itemmap = AccountManager:getAccountData():notifyServerReceiveAward( task_id , (reward_random[task_id] or -1));
			-- ns_ma.remember_notify_server_receive_award = false --取消标记
			-- local reward_list = GetRequestAwardList(task_id, result, avatorList, itemmap)
			-- if reward_list and next(reward_list) then
			-- 	SetGameRewardFrameInfo( GetS(3403), reward_list, "", nil, nil, bUseOverSeasTemp);					
			-- end

			--[[
				{
					ret = 0,
					data = {
					itemmap = { {id = _id, num = _num},  {id = _id, num = _num}, ....}
					}
				}
			]]
			local gid = gen_gid()
			local timeout = 15

			local function callback(ret)
				ns_ma.remember_notify_server_receive_award = false
				local result = 0
				local avatorList = {}
				local itemmap = {}
				if ret and ret.ret == 0 then
					result = 0
					if type(ret.data) == "table" and type(ret.data.itemmap) == "table" and next(ret.data.itemmap) then
						--为了满足GetRequestAwardList的调用数据结构 转换一下数据结构
						for k, v in pairs(ret.data.itemmap) do
							local pair = {v.id, v.num}
							table.insert(itemmap, pair)
						end
					end
				else
					result = -1
				end

				local reward_list = GetRequestAwardList(task_id, result, avatorList, itemmap)
				if reward_list and next(reward_list) then
					--SetGameRewardFrameInfo( GetS(3403), reward_list, "", nil, nil, bUseOverSeasTemp);	
					local rewardMgr = GetInst("RewardMgr")
					if rewardMgr then
						local rewardList = {}
						rewardList.title = GetS(3403)
						rewardList.desc = ""
						rewardList.bUseOverSeasTemp = bUseOverSeasTemp
						rewardList.data = ret.data.itemmap
						if open_cell_id and item_id and ns_ma.server_config and ns_ma.server_config[open_cell_id] and ns_ma.server_config[open_cell_id][item_id] then
							rewardList.giftType = ns_ma.server_config[open_cell_id][item_id].giftType
						end
						--如果是地图内道具，获取一下道具的iconUrl，用来发奖展示
						if rewardList.giftType and rewardList.giftType == 1 then 
							local giftCfg = ns_ma.server_config[open_cell_id][item_id].gift 
							for i = 1,#giftCfg do 
								for j = 1,#rewardList.data do 
									if giftCfg[i].id == rewardList.data[j].id then 
										rewardList.data[j].giftType = 1
										rewardList.data[j].name = giftCfg[i].name 
										rewardList.data[j].desc = giftCfg[i].desc 
										rewardList.data[j].iconUrl = giftCfg[i].iconUrl
										break 
									end 
								end 
							end 
						end 

						rewardMgr:PushReward(rewardList, rewardMgr:GetDataTypeEnum().task_reward)
					end				
				end

				threadpool:notify(gid, result)
			end
			ReqServerReceiveAward(task_id, (reward_random[task_id] or -1), callback)
			threadpool:wait(gid, timeout)
		end

	end,

	getTimeFormat	= function ( config_ )
		local AbroadEvnMounth = {"Jan.", "Feb.", "Mar.", "Apr.", "May", "Jun.", "Jul.", "Aug.", "Sept.", "Oct.", "Nov.", "Dec."};

		if  config_.start_time and config_.end_time then
			if  get_game_lang() > 0  then
				--LLTODO:海外版时间显示的月份用英文缩写
				--return  AbroadEvnMounth[tonumber(string.sub(config_.start_time, 6, 7 ))] .. string.sub(config_.start_time, 9, 10 ) .. ","..string.sub(config_.start_time, 1, 4 ).. '~' .. AbroadEvnMounth[tonumber(string.sub(config_.end_time, 6, 7 ))] .. string.sub(config_.end_time, 9, 10)..","..string.sub(config_.end_time, 1, 4 );
				local end_time_  = uu.get_time_stamp( config_.end_time );
				local end_int_   = end_time_ - getServerNow();

				return   uu.formatLeftTime( end_int_ );
			else
				-- return  string.sub(config_.start_time, 6, 7 ) .. '月' .. string.sub(config_.start_time, 9, 10 ) .. '日~' .. string.sub(config_.end_time, 6, 7) .. '月' .. string.sub(config_.end_time, 9, 10) .. '日';
				return  string.sub(config_.start_time, 6, 7 ) .. '.' .. string.sub(config_.start_time, 9, 10 ) .. ' ~ ' .. string.sub(config_.end_time, 6, 7) .. '.' .. string.sub(config_.end_time, 9, 10);
			end
		end
		return "";
	end,


	--[[
		按照服务器返回的数据刷新第i个活动UI
		
		@param page number 福利界面内侧左边的第几个tab
	]]
	resetMAUI = function( page )
		-- local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
		--local print = Android:Localize(Android.SITUATION.ADVERTISEMENT_9);
		print("marketactivity.lua(957): page = ", page);
		local ns_ma = _G.ns_ma;
		local server_config = ns_ma.server_config;
		-- print("resetMAUI(): server_config = ", server_config);
		-- print("resetMAUI(): #server_config = ", #server_config);
		page = page or ns_ma.open_cell_id or 1
		if page > 50 and server_config[page] ~= nil then
			--处理不在福利列表中的奖励
			local server_config_page = server_config[page]
			for i=1, ns_ma.content_list_max do
				if i <= #server_config_page then
					local gift_ = server_config_page[i].gift or {};
					if  ns_ma.reward_map[ server_config_page[i].id ] then
						--记录礼物
						--如果没有礼物，取一次gift的礼物
						if  not ns_ma.reward_map[ server_config_page[i].id ][1] and gift_[1] then
							ns_ma.reward_map[ server_config_page[i].id ] = copy_table(gift_);
						else
							ns_ma.reward_map[server_config_page[i].id .. "temp"] = gift_;
						end

					else
						ns_ma.reward_map[ server_config_page[i].id ] = copy_table(gift_);
					end
				end
			end
			return
		end

		ns_ma.open_cell_id = page;
		ns_ma.func.updateTabBtns()

		--更新内容
		print("resetMAUI(): 更新内容");
		if server_config and #server_config > 0 then
			-- ns_ma.open_cell_id = page;

			--右侧第几个按钮
			print("resetMAUI(): page = ", page);
			if page and server_config[page] and #server_config[page] > 0 then

				local server_config_page = server_config[page];
				print("resetMAUI(): #server_config_page = ", #server_config_page);
				local high_ = 150 + #server_config_page * ns_ma.CELL_HEIGHT;
				if  high_ < 482 then
					high_ = 482
				end
				getglobal("MarketActivityFrameContentSliderBoxPlane"):SetSize(752, high_ );

				for i=1, ns_ma.content_list_max do
					if i <= #server_config_page then
						local btn_name = "MAFSlideCell" .. i;
						getglobal(btn_name):Show();
						print("resetMAUI(): server_config_page[i] = ", server_config_page[i]);
						print("resetMAUI(): server_config_page[i].gift_random = ", tostring(server_config_page[i].gift_random));
						-- print("resetMAUI(): server_config_page[i].action = ", server_config_page[i].action);
						-- print("resetMAUI(): server_config_page[i].id = ", server_config_page[i].id);
						-- print("resetMAUI(): server_config_page[i].action = ", server_config_page[i].action);
						--goto按钮类型
						if  server_config_page[i].action and server_config_page[i].action>0 then
							getglobal(btn_name .. "Goto" ):Show();
							getglobal(btn_name .. "Goto" ):SetClientUserData( ns_ma._GOTO_BTN_TYPE_,   server_config_page[i].action );

							if  server_config_page[i].need_press_action == 1 then
								getglobal(btn_name .. "Goto" ):SetClientID( server_config_page[i].id );
							end

							if  server_config_page[i].action == 99 or server_config_page[i].action == 98 then
								local url_ = server_config_page[i].action_url or "";
								getglobal(btn_name .. "Goto" ):SetClientString( url_ );
							elseif server_config_page[i].action == 23 then
								--23=带帖子ID跳社区   (like xxx=yy&totid=22 )
								local info_ = server_config_page[i].action_url or "";
								getglobal(btn_name .. "Goto" ):SetClientString( info_ );
							else
								if  server_config_page[i].action_url then
									getglobal(btn_name .. "Goto" ):SetClientString( server_config_page[i].action_url );
								end
							end

						else
							getglobal(btn_name .. "Goto" ):Hide();
						end

						--goto按钮文字和领取按钮文字
						if  server_config_page[i].action_txt then
							getglobal(btn_name .. "GotoText"):SetText( server_config_page[i].action_txt );
						end

						if  server_config_page[i].get_txt then
							getglobal(btn_name .. "GetText"):SetText( server_config_page[i].get_txt );
						end


						if  not server_config_page[i].title then
							server_config_page[i].title = ""
						end
						--如果是在线任务，计算在线时间
						getglobal(btn_name .. "Title"):SetText( server_config_page[i].title .. private_get_online_desc( server_config_page[i], getVipRewardStat( server_config_page[i].id ) ) );
						getglobal(btn_name .. "Date" ):SetText( ns_ma.func.getTimeFormat( server_config_page[i] ) );

						print("set reward_random key title", server_config_page[i].id, server_config_page[i].title)
						--处理礼物列表
						local gift_ = server_config_page[i].gift or {};
						local giftType = server_config_page[i].giftType or 0
						--随机奖励
						if server_config_page[i].gift_random and #server_config_page[i].gift_random > 0 then
							local reward_random = ns_ma.reward_random;
							if reward_random[server_config_page[i].id] and reward_random[server_config_page[i].id] >= 0 then
								--上次随机的奖励还未领取
								if reward_random[server_config_page[i].id] == 0 then
									-- 使用旧的gift
								else
									-- 使用gift_random
									gift_ = server_config_page[i].gift_random[reward_random[server_config_page[i].id]] or {}
								end
							else
								local id_random = math.random(0,10000) % #server_config_page[i].gift_random;
								if id_random == 0 then
									-- 使用旧的gift
								else
									-- 使用gift_random
									gift_ = server_config_page[i].gift_random[id_random] or {}
								end
								reward_random[server_config_page[i].id] = id_random
							end
						end

						--奖励frame排序和隐藏
						for cc=1, 5 do
							local reword_node_ = getglobal( btn_name .. "Reward" .. cc );
							reword_node_:SetPoint("topleft", btn_name, "topleft", (cc-1)*104 + 19, 56);
							reword_node_:Hide()  --先隐藏全部奖励frame

							--还原位置 广告可能改动
							getglobal( btn_name .. "GiftTxt"):SetPoint("topleft", btn_name, "topleft", 40, 45);
							getglobal( btn_name .. "Reward1Name" ):Hide();
							getglobal( btn_name .. "PressAD"):Hide();
						end
						getglobal( "MAFSlideCell" .. i .. "Get"):Show()
						if IsShowFguiMain() then
							standReportEvent("2", "BENEFIT", "GetButton", "view", {standby1=server_config_page.id or 0, standby2=server_config_page[i].title or "null"})
						end

						local reward_list = ns_ma.reward_list;
						if  reward_list[ server_config_page[i].id ] then						
							if reward_list[ server_config_page[i].id ].gift then
								--如果服务器发来奖励
								gift_ = reward_list[ server_config_page[i].id ].gift;
							end
						
							--vivo广告
							if  reward_list[ server_config_page[i].id ].has_ad15 then
								--ad15隐藏奖励标志
								gift_.has_ad15 = reward_list[ server_config_page[i].id ].has_ad15

								local iconUrl_ad15_ = server_config_page[i].iconUrl
								if  iconUrl_ad15_ then

									getglobal( btn_name .. "Reward1" ):Show();
									local icon_ = getglobal( btn_name .. "Reward1Icon" );
									if  server_config_page[i].iconPath and #server_config_page[i].iconPath>0 then
										--有png文件
										icon_:SetTexture( server_config_page[i].iconPath )
									else
										--下载广告图片
										local icon_file_name_ = g_download_root .. ns_advert.func.trimUrlFile(iconUrl_ad15_) .."_";		--加上"_"后缀
										ns_http.func.downloadPng( iconUrl_ad15_, icon_file_name_, nil, btn_name .. "Reward1Icon" );
									end

									local numf_ = getglobal( btn_name .. "Reward1Num" );
									local chip_ = getglobal( btn_name .. "Reward1IconChip" );
									numf_:SetText("")
									chip_:Hide();

									--显示广告字符串
									local name_ = getglobal( btn_name .. "Reward1Name" );
									name_:SetText(GetS(1125));
									name_:Show();									
									
									
									--偏移位置
									local gt_ = getglobal( btn_name .. "GiftTxt")
									gt_:SetPoint("topleft", btn_name, "topleft", 110, 55);

									if  server_config_page[i].gift and server_config_page[i].gift.txt then
										gift_.txt = server_config_page[i].gift.txt
									end

									--大按钮
									getglobal( btn_name .. "PressAD"):Show();
									getglobal( btn_name .. "PressAD"):SetClientUserData( ns_ma._GET_BTN_TASK_ID_, server_config_page[i].id );
								end

								--没有礼物，隐藏
								if  server_config_page[i].gift and server_config_page[i].gift.has_gift == 0 then
									getglobal( "MAFSlideCell" .. i .. "Get"):Hide()
								end								
							end
						end

						
						--27号广告位奖励显示处理
						if server_config_page[i].get_btn_action == 'ad27' then
							server_config_page[i].gift = nil
							-- 处理账号服配置广告位的逻辑，与福利服区分开
							--if AccountManager and AccountManager.ad_position_info then
								-- 处理27号广告位的奖励显示
								-- 原数据例如：12963,12963|10000,12999|10009,10009,10009,10009
								-- 处理之后：12963, 10000, 10009（取第一个和竖线右边第一个）
								local reward_table = {}
								local ad_27_position_info = nil
								if IsAdUseNewLogic(27) then	
									ad_27_position_info = GetInst("AdService"):GetAdInfoByPosId(27)
								else
									ad_27_position_info = AccountManager:ad_position_info(27);
								end
								if ad_27_position_info and ad_27_position_info.extra then
									local rewards = tostring(ad_27_position_info.extra.reward_id);
									local ad_27_reward = "|"..string.gsub(rewards, " ", "") --前面补齐一个"|"方便解析
									if ad_27_reward then
										-- index_split: |的索引，index_comma：,的索引
										for index_split = 1, #ad_27_reward do
											local current_char_start = string.sub(ad_27_reward, index_split, index_split)
											if current_char_start == '|' then
												for index_comma = index_split + 1, index_split + 6 do
													local current_char_end = string.sub(ad_27_reward, index_comma, index_comma)
													if current_char_end == ',' then
														local reward = string.sub(ad_27_reward, index_split+1, index_comma-1)
														print(index_split.." "..index_comma.." "..reward)
														local t_reward = {num = 0, id = tonumber(reward)}
														table.insert(reward_table, t_reward)
													end
												end
											end
										end
									end
								end
								server_config_page[i].gift = reward_table
								gift_ = reward_table
								gift_.has_ad27 = reward_list[ server_config_page[i].id ] and reward_list[ server_config_page[i].id ].has_ad27 or nil;
							--end
						end

						if  gift_.txt then
							getglobal( btn_name .. "GiftTxt"):SetText( gift_.txt );
						else
							getglobal( btn_name .. "GiftTxt"):SetText( "" );
						end

						--Log("=========================== gift ");

						getglobal(btn_name .. "Get" ):SetClientUserData( ns_ma._GET_BTN_TASK_ID_, server_config_page[i].id );
						if  ns_ma.reward_map[ server_config_page[i].id ] then
							--记录礼物
							--如果没有礼物，取一次gift的礼物
							if  not ns_ma.reward_map[ server_config_page[i].id ][1] and gift_[1] then
								ns_ma.reward_map[ server_config_page[i].id ] = copy_table(gift_);
							else
								ns_ma.reward_map[server_config_page[i].id .. "temp"] = gift_;
							end

                        else
							ns_ma.reward_map[ server_config_page[i].id ] = copy_table(gift_);
						end

						--Log("=========================== reward_map ");

						if  gift_ and #gift_ > 0 and (not gift_.has_ad15) then
							--礼物列表
							for j=1, 5 do

								if j <= #gift_ then
									
									getglobal( btn_name .. "Reward" .. j ):Show();

									local id_  = gift_[j].id;
									local num_ = gift_[j].num;

									if id_ and num_ then

										local name_ = getglobal( btn_name .. "Reward" .. j .. "Name" );
										local numf_ = getglobal( btn_name .. "Reward" .. j .. "Num" );
										local icon_ = getglobal( btn_name .. "Reward" .. j .. "Icon" );
										local chip_ = getglobal( btn_name .. "Reward" .. j .. "IconChip" );

										if giftType == 1 then 
											--新增地图内道具 
											numf_:SetText( num_ );
											if num_ == 0 then
												numf_:SetText( '' );
											end

											DownloadPicAndSet(icon_,gift_[j].iconUrl) 
										else
											local itemDef = ItemDefCsv:get(id_);
											if itemDef then
												name_:SetText(itemDef.Name);
												numf_:SetText( num_ );
												if num_ == 0 then
													numf_:SetText( '' );
												end
											end

											if itemDef and itemDef.Chip == 1 then
												chip_:Show();
											else
												chip_:Hide();
											end

											--Log( "pic_file_name=" .. "items/" .. itemDef.Icon .. ".png" .. ", pos=" .. j*110-80 );
											--icon_:SetTexture( "items/" .. itemDef.Icon .. ".png"  );

											g_SetItemTexture( icon_, id_ );
											getglobal( btn_name .. "Reward" .. j ):SetClientUserData(1, id_)

											if gift_.has_ad27 and gift_.has_ad27 == 1 then
												-- 27号广告位不显示奖励数量
												numf_:Hide()
											else
												numf_:Show();
											end
										end 
									end

								end

							end
						end

					else
						local btn_name = "MAFSlideCell" .. i;
						getglobal(btn_name):Show();
					end
				end
			end

		end
		

		--更新位置	
		print("resetMAUI(): 更新位置");
		ns_ma.func.updateCellPos( page );
	end,

	updateTabBtns = function()
		local server_config = ns_ma.server_config;
		local tabMaxCount = ns_ma.fuli_tab_max
		local curSelectIdx = ns_ma.open_cell_id

		local titleDefaultColor = {55, 54, 48}

		local minHeight = 540
		local maxHeight = tabMaxCount * 100 + 31
		local realHeight = #server_config * 100 + 31
		realHeight = realHeight < minHeight and minHeight or realHeight
		realHeight = realHeight > maxHeight and maxHeight or realHeight
		getglobal("MarketActivityFrameFuliSliderBoxPlaneFuli"):SetSize(246, realHeight);

		for i = 1, tabMaxCount do
			local idx_frame = getglobal("MarketActivityFrameFuli" .. i);
			idx_frame:Hide()
			if server_config[i] then
				local idx_frame_title = getglobal("MarketActivityFrameFuli" .. i .. "BtnTitle");
				idx_frame_title:SetText(server_config[i].title or '');
				local useColor = server_config[i].color or titleDefaultColor
				idx_frame_title:SetTextColor(useColor[1], useColor[2], useColor[3])

				idx_frame:Show()

				local idx_frame_checked = getglobal("MarketActivityFrameFuli" .. i .. 'BtnCheckedBG');
				if curSelectIdx == i then
					idx_frame_checked:Show()
				else
					idx_frame_checked:Hide()
				end
			end
		end
	end,

	--设置条目的宽度和位置
	updateCellPos = function ( page )
		local start_pos = 0

		local ns_ma = _G.ns_ma;
		local server_config = ns_ma.server_config;
		for i=1, ns_ma.content_list_max do
			local btn_name = "MAFSlideCell" .. i;

			if server_config and #server_config > 0 and server_config[page] and server_config[page][i] then
				getglobal(btn_name):SetPoint("top", "MarketActivityFrameContentSliderBoxPlane", "top", 0, start_pos + (i-1)*ns_ma.CELL_HEIGHT);
				getglobal ( btn_name ):Show();
			else
				getglobal ( btn_name ):Hide();
			end

		end
	end,


	download_callback_empty = function( ret )
		Log( "call download_callback_empty" );
		if  ret then
			Log(  "msg=" .. ret );
			if  string.find( ret, "|ma|" ) then
				-- 重新拉取福利
				ActivityMainCtrl:RequestWelfareRewardData()
			end

		end
	end,


	--[[
		对二位数组ns_ma.welfare_config中元素逐个保存
		@return 是否可插入到活动或福利界面的数据中
	]]
	check_can_show = function( task_data )
		local ret_ = ns_ma.func.__check_can_show( task_data )
		if  not ret_ then
			Log( "======ma_check_show_conditions_false=====ma====" .. (task_data.id or "no_id") .. " / " .. (task_data.title or "no_title") )
		end
		return ret_
	end,

	__check_can_show = function( task_data )
		-- local print, Log = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
		local ns_ma = _G.ns_ma

		--过滤图片和公告 日期 渠道 版本
		--show_time  = "2016/11/01 00:00:00",  --可以展示 不能完成
		--start_time = "2016/11/01 00:00:00",
		--end_time   = "2016/11/02 23:59:59",
		--apiids     = "1,2,3,4,5",
		--ver        = 9.4

		if  task_data then
			if  task_data.id then
				--ok
			else
				Log( "call check_can_show ========task_no_id============= "  );
			end

			if  task_data.show_time  then
				local show_time_ = uu.get_time_stamp( task_data.show_time );
				if  show_time_ > os.time() then
					Log( "show_time_="  ..  show_time_ .. " / " .. os.time()  );
					return false;
				end
			elseif  task_data.start_time then
				local start_time_ = uu.get_time_stamp( task_data.start_time );
				if  start_time_ > os.time() then
					Log( "__check_can_show(): start_time="  ..  start_time_ .. " / " .. os.time()  );
					return false;
				end
			end


			if  task_data.close_time then
				local close_time_ = uu.get_time_stamp( task_data.close_time );
				if  close_time_ < os.time() then
					Log( "__check_can_show():close_time="  .. close_time_  .. " / " .. os.time()  );
					return false;
				end
			end


			--是否已经领取
			--Log( "task_data id=" ..  task_data.id .. ", hide=" .. (task_data.hide or "nil") );
			--1=领奖后隐藏  2=未完成隐藏+领奖后隐藏  3=未完成隐藏+领奖后不隐藏  4=一定隐藏
			local reward_list_task = ns_ma.reward_list[task_data.id]

			--福利定向推送筛选
			if  type(reward_list_task) == 'table' and reward_list_task.hide == 4 then
				Log("hide==4")
				return false
			end

			if  task_data.hide == 1 then
				if  reward_list_task and reward_list_task.stat == 2 then
					Log( "hide cell task_id=" .. task_data.id .. ", v.stat=2" );
					return false  --已经领取
				end
			elseif  task_data.hide == 2 then
				if  reward_list_task and reward_list_task.stat == 1 then
					--可领的时候显示
				else
					Log( "hide cell task_id=" .. task_data.id .. ", v.stat~=1" );
					return false  --不能领取或者已经领取
				end
			elseif  task_data.hide == 3 then

				if  reward_list_task and
				    reward_list_task.stat and
				    reward_list_task.stat >= 1 then
					--可领和领奖后显示
				else
					Log( "hide cell task_id=" .. task_data.id .. ", v.stat<1" );
					return false  --无法领取
				end
			else
				--一直显示
			end

			if task_data.pos and task_data.pos ~= 1 then -- 每日免费礼包
				return false
			end
			--广告按钮事件
			if  task_data.get_btn_action then

				Log(" find get_btn_action=" .. task_data.get_btn_action )

				if  task_data.get_btn_action == 'ad' then    --9号广告位
					local position_id = 9
					if IsAdUseNewLogic(position_id) then
						local callback = function(result, ad_info)
							--if  t_ad_data.canShow(9, nil, true) then
							if result then
								Log("get_btn_action ad9, AdService.IsAdCanShow true")
	
								--if  get_game_env() == 1 then
								--	ShowGameTips( "ad9 canShow get ok for " .. task_data.id , 3);
								--end
	
								if not reward_list_task then
									ns_ma.reward_list[task_data.id] = {}
									reward_list_task = ns_ma.reward_list[task_data.id]
								end
								reward_list_task.has_ad = ad_data_new.getAdLoadStatus(9) and 1 or 0   --有广告
							else
								--if  get_game_env() == 1 then
								--	ShowGameTips( "ad9 canShow get fail for " .. task_data.id , 3);
								--end
	
								if  get_game_env() == 1 and ClientMgr:getApiId() == 999 then
									if  not reward_list_task then
										ns_ma.reward_list[task_data.id] = {}
										reward_list_task = ns_ma.reward_list[task_data.id]
									end
		
									reward_list_task.has_ad = 1   --有广告
		
									task_data.title    = task_data.id .. "-测试空广告ad9";
									task_data.iconUrl  = 'http://imgwsdl.vivo.com.cn/appstore/developer/icon/20180807/20180807121104553016.png';
		
									local txt_ad15_    = '广告位9测试数据换行1换行2换行3换行4换行5换行6换行7换行8vivo15';
									task_data.gift     = task_data.gift or {}
									task_data.gift.txt = Utf8StringSub(txt_ad15_, 27)
									task_data.gift.txt = Utf8StringInsert(task_data.gift.txt, 14, "\n")
								else
									Log("get_btn_action ad9, AdService IsAdCanShow false")
									return false
								end
							end
						end
						GetInst("AdService"):IsAdCanShow(position_id, callback, nil, true)
					else
						if  t_ad_data.canShow(9, nil, true) then
							Log("get_btn_action ad9, t_ad_data.canShow true")

							--if  get_game_env() == 1 then
							--	ShowGameTips( "ad9 canShow get ok for " .. task_data.id , 3);
							--end

							if  not reward_list_task then
								ns_ma.reward_list[task_data.id] = {}
								reward_list_task = ns_ma.reward_list[task_data.id]
							end

							reward_list_task.has_ad = t_ad_data.getAdLoadStatus(9) and 1 or 0   --有广告
						else

							--if  get_game_env() == 1 then
							--	ShowGameTips( "ad9 canShow get fail for " .. task_data.id , 3);
							--end

							if  get_game_env() == 1 and ClientMgr:getApiId() == 999 then
								if  not reward_list_task then
									ns_ma.reward_list[task_data.id] = {}
									reward_list_task = ns_ma.reward_list[task_data.id]
								end

								reward_list_task.has_ad = 1   --有广告

								task_data.title    = task_data.id .. "-测试空广告ad9";
								task_data.iconUrl  = 'http://imgwsdl.vivo.com.cn/appstore/developer/icon/20180807/20180807121104553016.png';

								local txt_ad15_    = '广告位9测试数据换行1换行2换行3换行4换行5换行6换行7换行8vivo15';
								task_data.gift     = task_data.gift or {}
								task_data.gift.txt = Utf8StringSub(txt_ad15_, 27)
								task_data.gift.txt = Utf8StringInsert(task_data.gift.txt, 14, "\n")
							else
								Log("get_btn_action ad9, t_ad_data.canShow false")
								return false
							end
						end
					end
				elseif task_data.get_btn_action == 'ad15' then    --vivo自定义广告

					if  t_ad_data.canShow(15) then
						Log("get_btn_action ad15, t_ad_data.canShow true")

						--if  get_game_env() == 1 then
						--	ShowGameTips( "ad15 canShow get ok for " .. task_data.id , 3);
						--end


						if  not reward_list_task then
							ns_ma.reward_list[task_data.id] = {}
							reward_list_task = ns_ma.reward_list[task_data.id]
						end
						reward_list_task.has_ad15 = 1   --有广告

						local info_ = getSdkAdInfo()
						Log( "call getSdkAdInfo=[" .. (info_ or 'nil') .. "]" )
						if  info_ and #info_ > 10 then
							local ret = JSON:decode(info_);	
							if  ret and type(ret) == 'table' then
								if  not (task_data.title and #task_data.title > 0) then
									task_data.title   = Utf8StringSub(ret.title   or "", 22);
								end
								task_data.iconUrl = ret.iconUrl or "";

								--直接从url拉取
								--if #task_data.iconUrl > 0 and ret.iconPath then
									--Log( "iconPath1=" .. ret.iconPath )
									--local i_path_ = ret.iconPath  --下载文件地址
									--去掉前置目录
									--local pos_ = string.find(i_path_, "data/http/" )
									--if  pos_ then
										--task_data.iconPath = string.sub( i_path_, pos_ )
										--Log( "iconPath2=" .. task_data.iconPath )
									--end
								--end

								task_data.gift    = task_data.gift or {}
								if  not (task_data.gift.txt and #task_data.gift.txt > 0) then
									task_data.gift.txt = Utf8StringSub( ret.desc or "", 27)
									task_data.gift.txt = Utf8StringInsert( task_data.gift.txt, 14, "\n")
								end
							end
						end

						if  task_data.iconUrl and  #task_data.iconUrl > 5 then
							--取到了广告
						else
							Log("get_btn_action ad15, t_ad_data.canShow true, but iconUrl is nil")
							return false
						end

					else

						--if  get_game_env() == 1 then
						--	ShowGameTips( "ad15 canShow get fail for " .. task_data.id , 3);
						--end

						if  get_game_env() == 1 and ClientMgr:getApiId() == 999 then
							if  not reward_list_task then
								ns_ma.reward_list[task_data.id] = {}
								reward_list_task = ns_ma.reward_list[task_data.id]
							end
							reward_list_task.has_ad15 = 1   --有广告

							task_data.title    = task_data.id .. "-测试空广告ad15";
							task_data.iconUrl  = 'http://imgwsdl.vivo.com.cn/appstore/developer/icon/20180807/20180807121104553016.png';

							local txt_ad15_    = '广告位十五测试数据换行1换行2换行3换行4换行5换行6换行7换行8vivo15';
							task_data.gift     = task_data.gift or {}
							task_data.gift.txt = Utf8StringSub(txt_ad15_, 27)
							task_data.gift.txt = Utf8StringInsert(task_data.gift.txt, 14, "\n")
						else
							Log("get_btn_action ad15, t_ad_data.canShow false")
							return false
						end

					end

				elseif task_data.get_btn_action == 'ad27' then --27号广告位	
					local position_id = 27
					if IsAdUseNewLogic(position_id) then
						local callback = function(result, ad_info)
							--if t_ad_data.canShow(27, nil, true) then
							if result then
								-- Log("get_btn_action 27, t_ad_data.canShow true")
								if  not reward_list_task then
									-- Log("get_btn_action 27, not reward_list_task")
									ns_ma.reward_list[task_data.id] = {10000}
									reward_list_task = ns_ma.reward_list[task_data.id]
								else
									-- Log("get_btn_action 27, reward_list_task")
									ns_ma.reward_list[task_data.id] = {10000}
									reward_list_task = ns_ma.reward_list[task_data.id]
								end
								reward_list_task.has_ad27 = ad_data_new.getAdLoadStatus(position_id) and 1 or 0   --有广告
							else
								if  get_game_env() == 1 and ClientMgr:getApiId() == 999 then
									if  not reward_list_task then
										ns_ma.reward_list[task_data.id] = {}
										reward_list_task = ns_ma.reward_list[task_data.id]
									end
									reward_list_task.has_ad27 = 1   --有广告
									task_data.title    = task_data.id .. "-测试空广告ad27";
									task_data.iconUrl  = 'http://imgwsdl.vivo.com.cn/appstore/developer/icon/20180807/20180807121104553016.png';
									local txt_ad27_    = '广告位27测试数据换行1换行2换行3换行4换行5换行6换行7换行8vivo15';
									task_data.gift     = task_data.gift or {}
									task_data.gift.txt = Utf8StringSub(txt_ad27_, position_id)
									task_data.gift.txt = Utf8StringInsert(task_data.gift.txt, 14, "\n")
								else
									Log("get_btn_action ad27, t_ad_data.canShow false")
									return false
								end
							end
						end
	
						local ad_info = GetInst("AdService"):GetAdInfoByPosId(position_id)
						if ad_info then
							local result = ad_data_new.canShow(position_id, ad_info, nil, true) or false
							callback(result, ad_info)
						else
							GetInst("AdService"):IsAdCanShow(position_id, callback, nil, true)
						end	
					else
						if  t_ad_data.canShow(27, nil, true) then
							-- Log("get_btn_action 27, t_ad_data.canShow true")
							if  not reward_list_task then
								-- Log("get_btn_action 27, not reward_list_task")
								ns_ma.reward_list[task_data.id] = {10000}
								reward_list_task = ns_ma.reward_list[task_data.id]
							else
								-- Log("get_btn_action 27, reward_list_task")
								ns_ma.reward_list[task_data.id] = {10000}
								reward_list_task = ns_ma.reward_list[task_data.id]
							end
							reward_list_task.has_ad27 = t_ad_data.getAdLoadStatus(27) and 1 or 0   --有广告
						else
							if  get_game_env() == 1 and ClientMgr:getApiId() == 999 then
								if  not reward_list_task then
									ns_ma.reward_list[task_data.id] = {}
									reward_list_task = ns_ma.reward_list[task_data.id]
								end
								reward_list_task.has_ad27 = 1   --有广告
								task_data.title    = task_data.id .. "-测试空广告ad27";
								task_data.iconUrl  = 'http://imgwsdl.vivo.com.cn/appstore/developer/icon/20180807/20180807121104553016.png';
								local txt_ad27_    = '广告位27测试数据换行1换行2换行3换行4换行5换行6换行7换行8vivo15';
								task_data.gift     = task_data.gift or {}
								task_data.gift.txt = Utf8StringSub(txt_ad27_, 27)
								task_data.gift.txt = Utf8StringInsert(task_data.gift.txt, 14, "\n")
							else
								Log("get_btn_action ad27, t_ad_data.canShow false")
								return false
							end
						end
					end
				end
			end


			--其他条件判断 apiids  version  uin等
			if  not ma_check_show_conditions( task_data, "ma" ) then
				return false
			end


			local apiid_ = ClientMgr:getApiId()
			--渠道vivo和oppo另外做了面板领取 ( 一定放在最后判断 )
			local task_conditions = task_data.task_conditions
			if  task_conditions and task_conditions.start_game_out then
				if  apiid_ == 13 or apiid_ == 36 or apiid_ == 21 or apiid_ == 12 or apiid_ == 54 then
					Log( "hide start_game_out 13 or 36 ==" .. task_conditions.start_game_out )
					if  type(task_conditions.start_game_out)=='number' and task_conditions.start_game_out == apiid_ then
						--存放到 server_config_start_game_out
						ns_ma.server_config_start_game_out = task_data
						ns_ma.reward_map[ task_data.id ] = task_data.gift or {};
						
						ChannelRewardPresenter:requestSaveRewardTask(task_data);
					end

					return false;
				end
			end

			--渠道oppo含额外增加的周二登录奖励
			if  task_data.start_game_out_extra then
				if  (apiid_ == 13 or apiid_ == 54) and (task_data.start_game_out_extra == 13 or task_data.start_game_out_extra == 54) then
					Log( "start_game_out_extra 13 or 54 ==" .. task_data.start_game_out_extra )
					ns_ma.reward_map[ task_data.id ] = task_data.gift or {};
					ChannelRewardPresenter:requestSaveExtraRewardTask(task_data);

					return false;
				end
			end

			Log("can show:" .. task_data.id );
			return true;
		end

		Log( "call ma check_can_show no task_data" );
		return false;
	end,


};     --end func


--帐号服推送的福利活动可领取状态
function OnMaUpdate(msg_)
	Log( "call OnMaUpdate" )
	if  type(msg_) == 'table' then
		if  msg_.mtype == "get_reward_list" then
			ActivityMainCtrl:RequestWelfareRewardData()   --重新拉取福利活动
		elseif msg_.mtype == "welfare_love_total_num" then
			Charity201903:UpLoveHeartInfo(true);   --重新拉取福利活动
		elseif msg_.mtype == "real_authed" then	--实名制奖励领取
			ActivityMainCtrl:RequestWelfareRewardData()	
			if IdentityNameAuthClass.IsAutoAward then
				MAFRewardsGet(IdentityNameAuthClass.maid, IDGetMarketActivity(IdentityNameAuthClass.maid))
			end
		elseif msg_.mtype == "new_real_auth" then
			print("new_real_auth")
			-- local list = RealNameFunc:getGift()
			-- SetGameRewardFrameInfo( GetS(3403), list, "")
		elseif msg_.mtype == "phone_binding" then	--实名制奖励领取
			ActivityMainCtrl:RequestWelfareRewardData()	
			if PhtoneBindingAwardClass and PhtoneBindingAwardClass.IsAutoAward then
				MAFRewardsGet(PhtoneBindingAwardClass.maid, IDGetMarketActivity(PhtoneBindingAwardClass.maid))
			end
		else
			Log( "ERROR: OnMaUpdate unkown mtype" )
		end
	else
		Log( "ERROR: OnMaUpdate msg not table" )
	end
end

-- data.conditions
function ma_check_show_conditions( task_data_, type_ )

	local data_
	--限制条件配置在conditions或者配在外面都可以生效
	if  task_data_.conditions then
		data_ = task_data_.conditions
	else
		data_ = task_data_
	end

	if  data_ then

		--超级白名单
		if  data_.super_uin_list then
			local uin = AccountManager:getUin();
			local pos_  = string.find( ',' .. data_.super_uin_list .. ',', ',' .. uin .. ',' )
			if  pos_ then
				Log("in slist")
				return true
			end
		end


		--白名单
		if  data_.uin_list then
			local uin = AccountManager:getUin();
			local pos_  = string.find( ',' .. data_.uin_list .. ',', ',' .. uin .. ',' )
			if  pos_ then
				--ok
			else
				Log("not in uin_list");
				return false
			end
		end	
	
	
		if  data_.uin_min then
			local uin = AccountManager:getUin();
			if  uin and uin >= data_.uin_min then
				--匹配
			else
				Log("uin_min");
				return false;
			end
		end


		if  data_.uin_max then
			local uin = AccountManager:getUin();
			if  uin and uin <= data_.uin_max then
				--匹配
			else
				Log("uin_max");
				return false;
			end
		end

		if  data_.lang then
			local lang_ = get_game_lang()
			if  data_.lang == lang_ then
				--语言匹配
			else
				Log( "lang not match= " .. data_.lang .. " / " .. lang_ )
				return false;
			end
		end


		if  data_.langs then
			local lang_ = get_game_lang()
			local finder_ = ',' .. lang_ .. ',';
			local ret     = string.find( ',' .. data_.langs .. ',', finder_ );
			Log( finder_ .. " | " ..  data_.langs  .. " | " .. (ret or "nil" ) );
			if  ret then
				--匹配
			else
				Log("langs=" .. data_.langs .. " / " .. lang_ );
				return false;
			end
		end


		if  data_.apiid and  type(data_.apiid) == 'number' and data_.apiid > 0 then
			if  data_.apiid == 	ClientMgr:getApiId() then
				--匹配
			else
				Log("apiid");
				return false;
			end
		end


		if  data_.apiids and  type(data_.apiids) == 'string' then
			local finder_ = ',' .. ClientMgr:getApiId() .. ',';
			local ret     = string.find( ',' .. data_.apiids .. ',', finder_ );
			Log( finder_ .. " | " ..  data_.apiids  .. " | " .. (ret or "nil" ) );
			if  ret then
				--匹配
			else
				Log("apiids");
				return false;
			end
		end


		if  data_.apiids_no and  type(data_.apiids_no) == 'string' then
			local finder_ = ',' .. ClientMgr:getApiId() .. ',';
			local ret     = string.find( ',' .. data_.apiids_no .. ',', finder_ );
			Log( "appids= " .. finder_ .. " | " ..  data_.apiids_no  .. " | " .. (ret or "nil" ) );
			if  ret then
				--匹配 禁止显示
				Log("apiids_no" )
				return false;
			end
		end


		if  data_.version_min then
			local version_min_ = ClientMgr:clientVersionFromStr( data_.version_min );
			local version_now_ = ClientMgr:clientVersion();
			if  version_min_ > version_now_ then
				Log( "version_min_=" .. version_min_ .. "/" .. version_now_ );
				return false;
			end
		end


		if  data_.version_max then
			local version_max_  = ClientMgr:clientVersionFromStr( data_.version_max );
			local version_now_  = ClientMgr:clientVersion();

			if  version_max_ < version_now_ then
				Log( "version_max_=" .. version_max_ .. "/" .. version_now_ );
				return false;
			end
		end


		--至少注册N天
		if  data_.reg_day_min then
			if  AccountManager.get_account_create_time then
				local time_ = AccountManager:get_account_create_time() or 0
				if  time_ > 0 then
					local day_ =  math.floor ( (getServerNow() - time_) / 86400 )
					if  day_ >= data_.reg_day_min then
						--正常
					else
						Log( "reg_day_min check fail: " .. day_ .. "/" .. data_.reg_day_min )
						return false
					end
				end
			else
				Log( "reg_day_min check fail: not get_account_create_time" )
				return false  --无接口
			end
		end


		--最多注册N天
		if  data_.reg_day_max then
			if  AccountManager.get_account_create_time then
				local time_ = AccountManager:get_account_create_time() or 0
				if  time_ > 0 then
					local day_ =  math.floor ( (getServerNow() - time_) / 86400 )
					if  day_ <= data_.reg_day_max then
						--正常
					else
						Log( "reg_day_max check fail: " .. day_ .. "/" .. data_.reg_day_max )
						return false
					end
				end
			else
				Log( "reg_day_max check fail: not get_account_create_time" )
				return false  --无接口
			end
		end


		--至少流失N天
		if  data_.afk_day_min then
			if  ns_ma.reward_list and ns_ma.reward_list.afk_time then
				if  ns_ma.reward_list.afk_time >= data_.afk_day_min * 86400 then
					--满足条件
				else
					Log("afk_day_min: afk_time check fail:" .. data_.afk_day_min )
					return false
				end
			else
				Log("afk_day_min: no afk_time")
				return false
			end
		end


		--最多流失N天 在N天内有登录过
		if  data_.afk_day_max then
			if  ns_ma.reward_list and ns_ma.reward_list.afk_time then
				if  ns_ma.reward_list.afk_time <= data_.afk_day_max * 86400 then
					--满足条件
				else
					Log("afk_day_max: afk_time check fail:" .. data_.afk_day_max )
					return false
				end
			end
		end


		--至少[Desc2]N迷你币
		if  data_.recharge_total_min then
			if  AccountManager.recharge_minicoin_total then
				local minicoin_ = AccountManager:recharge_minicoin_total() or 0
				if  minicoin_ >= data_.recharge_total_min then
					--正常
				else
					Log( "recharge_total_min check fail: " .. minicoin_ .. "/" .. data_.recharge_total_min )
					return false
				end
			else
				Log( "recharge_total_min check fail: not recharge_minicoin_total" )
				return false  --无接口
			end

		end

		--最多[Desc2]N迷你币
		if  data_.recharge_total_max then
			if  AccountManager.recharge_minicoin_total then
				local minicoin_ = AccountManager:recharge_minicoin_total() or 0
				if  minicoin_ <= data_.recharge_total_max then
					--正常
				else
					local bShow = false
					if task_data_ and task_data_.id then
						local reward_list_task = ns_ma.reward_list[task_data_.id]
						if reward_list_task and reward_list_task.stat == 1 then
							bShow = true
						end
					end

					Log( "recharge_total_max check fail: " .. minicoin_ .. "/" .. data_.recharge_total_max )
					if not bShow then
						return false
					end
				end
			else
				Log( "recharge_total_max check fail: not recharge_minicoin_total" )
				return false  --无接口
			end
		end


		---- 匹配地域 data_.tag_area = "Shenzhen,Guangzhou"
		if data_.tag_area then
			if AccountManager.account and AccountManager.account.svrinfo  then
                local area
                if isAbroadEvn() == false and AccountManager.account.svrinfo.city then
                    area = AccountManager.account.svrinfo.city
                elseif isAbroadEvn() and AccountManager.account.svrinfo.country then
                    area = AccountManager.account.svrinfo.country
                else
                    return false
                end

				local ret = string.find(data_.tag_area,area)
				if ret then
					--正常
				else
					return false
				end
			else
				return false
			end
		end

		-- 匹配迷你号 data_.tag_uins = "123456,23456,23456"
		--if data_.tag_uins then
		--	local uin  = AccountManager:getUin()
		--	local ret = string.find(data_.tag_uins,uin)
		--	if ret then
		--
		--	else
		--		return false
		--	end
		--end

		-- 匹配建号时间（前面有）data_.tag_create_time = "2019/06/27-2019/06/28"
		if data_.tag_create_time then
			if  AccountManager.get_account_create_time then
				local time_ = AccountManager:get_account_create_time() or 0
				if time_>0 then
					local _, _, y, m, d, y1, m1, d1 = string.find(data_.tag_create_time, "(%d+)/(%d+)/(%d+)-(%d+)/(%d+)/(%d+)");
					local min_time = os.time({year=y, month = m, day = d});
					local max_time = os.time({year=y1, month = m1, day = d1});

					if min_time and max_time then
						if min_time<= time_ and max_time>= time_ then

						else
							return false
						end
					end

				end
			else
				return false
			end
		end

		-- 匹配回流用户 data_.tag_recur_user = 7
		if data_.tag_recur_user then
			if ns_advert.user_tag  then
				if ns_advert.user_tag.active_7days  ~= nil and ns_advert.user_tag.active_7days ~= 0  then
					return false
				end
			else
				return false
			end

		end

		-- 匹配[Desc3]用户 data_.tag_pay_money = 1 ：是[Desc3]用户，2：不是[Desc3]用户
		if data_.tag_pay_money then
			if ns_advert.user_tag  then
				if data_.tag_pay_money == 1 then
					if ns_advert.user_tag.pay_money == nil or ns_advert.user_tag.pay_money == 0 then
						return false
					end
				elseif data_.tag_pay_money == 2 then
					if ns_advert.user_tag.pay_money ~= nil then
						return false
					end
				end
			else
				return false
			end
		end

		-- 匹配最近一周活跃度 data_.tag_active_day = "1-3"
		if data_.tag_active_day then
			if ns_advert.user_tag and ns_advert.user_tag.active_7days  and ns_advert.user_tag.active_7days >0   then
				local _, _, d1, d2=string.find(data_.tag_active_day, "(%d+)-(%d+)");
				d1 = tonumber(d1)
				d2 = tonumber(d2)
				if d1 and d2 and ns_advert.user_tag.active_7days>=d1 and ns_advert.user_tag.active_7days <=d2 then

				else
					return false
				end

			else
				return false
			end

		end

		-- 匹配年龄 data_.tag_age = "8-10"
		if data_.tag_age and isAbroadEvn() == false  then
			if ns_advert.user_tag and ns_advert.user_tag.birthday  then

				local _, _, age1, age2=string.find(data_.tag_age, "(%d+)-(%d+)");
				--local min_time = os.time({year=os.date("%Y")-age2, month = os.date("%m"), day = os.date("%d")});
				--local max_time = os.time({year=os.date("%Y")-age1, month = os.date("%m"), day = os.date("%d")});
				local min_time = os.time({year=os.date("%Y")-age2, month = 1, day = 1});
				local max_time = os.time({year=os.date("%Y")-age1, month = 12, day = 31});

				local _, _, y, m, d=string.find(ns_advert.user_tag.birthday, "(%d+)-(%d+)-(%d+)");
				local birth_time = os.time({year=y, month = m, day = d});

				if min_time and  max_time and birth_time and birth_time>=min_time and birth_time <=max_time then

				else
					return false
				end

			else
				return false
			end
		end

		-- 匹配性别 data_.tag_sex= 1:男 ，0：女
		if data_.tag_sex and isAbroadEvn() == false  then
			if ns_advert.user_tag and ns_advert.user_tag.sex and ns_advert.user_tag.sex == data_.tag_sex then

			else
				return false
			end
		end

		--lang_x
		--海外版本只显示对应的语言
		if  type_ == "ma" then
			--活动无title不显示
			if  isAbroadEvn() then
				if  not task_data_.title then
					Log( "no_title" )
					return false   --处理后没有title
				end
			end
		elseif type_ == "ad" then
			--
		else

		end

		if data_.userPkgs then 
			--人群包允许列表
			local userPkgs = string.split(data_.userPkgs,",")
			local curUserPkgs = get_game_userPkgs()  
			local isFind = find_game_userPkgs(userPkgs,curUserPkgs)
			if not isFind then
				return false 
			end 
		elseif data_.noUserPkgs then 
			--人群包禁止列表
			local noUserPkgs = string.split(data_.noUserPkgs,",")
			local curUserPkgs = get_game_userPkgs()  
			local isFind = find_game_userPkgs(noUserPkgs,curUserPkgs)
			if isFind then
				return false 
			end
		end 

		if data_.isExtLink and data_.isExtLink == 1 then 
			--是外链
			local cfg = GetInst("VisualCfgMgr"):GetCfg("activity") 
			if cfg and cfg.activity and cfg.activity.extLinksCfg and cfg.activity.extLinksCfg.extLinksFlag then
				--如果一键关闭外链开关是打开的，则表示禁止使用外链
				return false 
			end 
		end

	end

	return true
end

local reqMAInfo = {
	Config = {},
	Award = {}
}

function requestMaketActivityAward(id)
	while not ns_http do threadpool:wait(0) end 
    local timeout = timeout or config and config.timeout or 30

    local seq = gen_gid();

    local url_ = g_http_root_map .. '/miniw/php_cmd?act=get_reward_list&target=' .. id
			.. '&' .. http_getS1() .. '&' .. addWWWGrlc()

    threadpool:work(function()
    	local ma_callback = function(ret)
    		threadpool:notify(seq, ErrorCode.OK, ret)
    	end

    	threadpool:wait(0.2);

		ns_http.func.rpc( url_, ma_callback, nil, nil,true);
	end)

	return threadpool:wait(seq, timeout);
end

function requestMaketActivityConfig(id)
	while not ns_http do threadpool:wait(0) end
	local timeout = timeout or config and config.timeout or 30

	local seq = gen_gid();

	local url_ = g_http_root_map .. '/miniw/php_cmd?act=get_reward_list&target=' .. id
			.. '&' .. http_getS1() .. '&' .. addWWWGrlc()

	threadpool:work(function()
		local ma_callback = function(ret)
			threadpool:notify(seq, ErrorCode.OK, ret)
		end

		threadpool:wait(0.2);

		ns_http.func.rpc( url_, ma_callback, nil, nil, true);
	end)

	return threadpool:wait(seq, timeout);
end

--仅可显示的活动
function IDGetMarketActivity(id)
	local num = 0
	while(true)
	do
		num = num + 1
		threadpool:wait(1)
		if ns_ma and ns_ma.server_config and #ns_ma.server_config > 0  then
			for k, v in pairs(ns_ma.server_config) do
				if type(v) == "table" then
					for p, q in pairs(v) do
						if type(q) == "table" then
							if tonumber(q.id) == id then
								return q
							end
						end
					end
				end
			end

			return nil
		end

		if num > 60 then
			return nil
		end
	end
end

--全部的活动配置
function IDGetAllMarketActivity(id)
	local num = 0
	while(true)
	do
		num = num + 1
		threadpool:wait(1)
		if ns_ma and ns_ma.welfare_config then
			for k, v in pairs(ns_ma.welfare_config) do
				if type(v) == "table" then
					for p, q in pairs(v) do
						if type(q) == "table" then
							if tonumber(q.id) == id then
								return q
							end
						end
					end
				end
			end

			return nil
		end

		if num > 60 then
			return nil
		end
	end
end

----------------------------------------------------------------LLDO:奖励物品详情页------------------------------------------------------------------
--点击礼物, 打开详情页
function MARewardBtnTemplate_OnClick()
	Log("MARewardBtnTemplate_OnClick:");

	-- local gift_ = ns_ma.server_config[ns_ma.open_cell_id][this:GetParentFrame():GetClientID()].gift;
	local server_config_ = ns_ma.server_config[ns_ma.open_cell_id][this:GetParentFrame():GetClientID()]
	if not server_config_ then return end

	local gift_ = nil
	local task_id = 0
		
	if server_config_.gift_random then
		-- gift_ = server_config_.gift_random[ns_ma.reward_random[task_id]]
		task_id = this:GetClientUserData(1)
		SetMTipsInfo(-1, this:GetName(), true, task_id)
		return
	else
		gift_ = server_config_.gift
	end
	local index = this:GetClientID();

	Log("index = " .. index);

	if gift_ and gift_[index] then
		if server_config_.giftType and server_config_.giftType == 1 then 
			--新增地图内道具
			SetMTipsInfoInMap(this:GetName(), true, gift_[index])
		else
			SetMTipsInfo(-1, this:GetName(), true, gift_[index].id);
		end 
	end
end


--点击广告vivo15
function MAFBtnPressAD_OnClick()
	local task_id_ = this:GetClientUserData( ns_ma._GET_BTN_TASK_ID_ );
	Log( "press MAFBtnPressAD_OnClick " .. (task_id_ or 'nil') )
	StatisticsAD('onclick', 15);
	SdkAdOnClick();
end


--鼠标进入, 显示详情页
function MARewardBtnTemplate_OnMouseEnter_PC()
	Log("MARewardBtnTemplate_OnMouseEnter_PC:");

	MARewardBtnTemplate_OnClick();
end

--鼠标移出, 关闭
function MARewardBtnTemplate_OnMouseLeave_PC()
	--Log("MARewardBtnTemplate_OnMouseLeave_PC:");
	HideMTipsInfo();
end

function UpdateActivityRewardListByItemid(id) --在领取奖励之后刷新奖励列表，例如邮件，兑换码
	if id == 10003 or id == 10004 then
		ActivityMainCtrl:RequestWelfareRewardData()
	end
end

-- 请求发奖逻辑数据整理
function GetRequestAwardList(task_id, result, avatorList, itemmap)
	local ns_ma = _G.ns_ma;
	local reward_random = ns_ma.reward_random
	local reward_map = ns_ma.reward_map
	print("RequestAward_CallBack: reward_random[task_id] = ", reward_random[task_id]);
	if reward_random[task_id] then
		--随机奖励已经被领取
		reward_random[task_id] = -1
	end
	if result == 0 then

		print("RequestAward_CallBack: award unlocked!");
		ClientMgr:playSound2D("sounds/ui/info/book_seriesunlock.ogg", 1);

		if reward_map[task_id] and #reward_map[task_id] == 0 and reward_map[task_id .. "temp"] and #reward_map[task_id .. "temp"] > 0 then
			reward_map[task_id] = copy_table(reward_map[task_id .. "temp"])
		end

		if itemmap then
			reward_map[task_id] = {}
			for key, value in pairs(itemmap) do
				local pair = {id = key, num = value}
				table.insert(reward_map[task_id], pair)
			end
		end

		local reward_list = reward_map[task_id] or {};
		--LLDO:已拥有的avator装扮转化为迷你豆
		if avatorList then
			for i = 1, #avatorList do
				for j = 1, #reward_list do
					if reward_list[j].id == avatorList[i][1] then
						--需要转化为迷你豆
						reward_list[j].id = 10000;
						reward_list[j].num = avatorList[i][2];
					end
				end
			end
		end

		--增加积分 10003 or 10004
		for j = 1, #reward_list do
			if reward_list[j].id == 10003 or  reward_list[j].id == 10004 then
				--转化为迷你盒子积分
				print("RequestAward_CallBack: reward_list[j].id = ", reward_list[j].id);
				add_miniTreasures_score( reward_list[j] )
			end
		end

		print("RequestAward_CallBack: SetGameRewardFrameInfo");

		--成就任务检测:神秘礼物
		ArchievementGetInstance().func:checkReward(task_id);
		print("RequestAward_CallBack: checkReward");

		return reward_list
	else
		-- ShowGameTips(GetS(3402), 5); --这里会提示4050等其他了，暂时把这个提示放到等待网络的情况再提示--黄福彬2020/03/10
		Log("unlock award failed! ret=" .. (result or "nil") );
		return nil
	end
end