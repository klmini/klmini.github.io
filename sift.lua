ns_sift = {
    	CELL_HEIGHT 		= 99,
	CELL_INFO_HEIGHT 	= 260,
	PIC_WIDTH 			= 748, --图片宽度
	CONTENT_LIMIT_HEIGHT= 506, --图文内容限制高度（超出则滚动）

	_GOTO_BTN_TYPE_ 	= 1,             --按钮类型
	_CELL_ADS_ID_ 		= 1,             --cell展示的广告id

	open_cell_id 		= 0,          --当前打开哪一个格子
	first_cell_task_id 	= 0,          --第一个格子的任务ID，打开计算曝光
	
	server_config  		= {},

	big_pic_list 		= { index=0, },         --下载大图片文件的列表

	pic_loop_time 		= 15,   --轮播时间间隔
	pic_last_loop 		= 0,    --轮播时间
	has_show_ids 		= {}, --已经展示过的（红点记录）
	show_index 			= 0, --置顶展示的公告

	--content_list 		= { index=0,
	--						{
	--							id, duration, start_time, title
	--							pic = { pic_url, file_name, action, action_url },
	--							texts = { { title = "", text = ""}, ... },
	--							goto_btn = { can_show, action, url_string, action_txt }
	--						},
	--						...
	--}, -- 公告右侧图文内容列表

	text_num = 0; -- 已创建的文字内容控件块的数量

	------------------fqa----------------
	server_fqa            = false,
	server_fqa_callback   = false,

	user_tag = nil,				--用户标签

	label_max = 25,				--显示公告标签数

	label_colors = {
		"label_notice_red",
		"label_notice_darkorange",
		"label_notice_aqua",
		"label_notice_blue",
		"label_notice_gray",
		"label_notice_green",
		"label_notice_olive",
		"label_notice_orange1",
		"label_notice_orangered",
		"label_notice_orchid",
		"label_notice_pink",
		"label_notice_purple",
		"label_notice_radient_purple",
		"label_notice_radient_red",
		"label_notice_royalblue",
	},
	env = 0,
}

----xml functions-----------------------------------------------------------
function SiftFrame_OnLoad()
	----Log( "call SiftFrame_OnLoad" );

	this:setUpdateTime(1);
end

function ReqSiftUserTag(callback,data)
	if callback == nil then return end

	local url_ = g_http_root_map .. '/miniw/php_cmd?act=get_user_biaoqian'..'&' .. http_getS1();

	if ns_sift.user_tag ~= nil then
		local ret = {}
		ret[1] = ns_sift.user_tag
		callback(ret,data)
	else
		ns_http.func.rpc( url_, callback,data);
	end


end


function SiftFrame_OnShow()
	if  SetSlidingFrameState then
		SetSlidingFrameState(false);
	end
	if  ClientCurGame:isInGame() then
		if not getglobal("SiftFrame"):IsReshow() then
			ClientCurGame:setOperateUI(true);
		end
	end

	--红点处理
	--ns_sift.func.updateRedDot(true)
	ns_sift.env = 0;
	if ClientMgr and ClientMgr.getGameData then 
		ns_sift.env = ClientMgr:getGameData('game_env')
	end
	
	--点击cell button时有可能触发这个回调，导致列表弹回
	--修改默认点击不上报埋点
	-- press_btn("SiftSlideCell"..ns_sift.show_index.."Bt");
	SiftCellBtn_OnClick(ns_sift.show_index)
	getglobal("SiftFrameContentSliderBox"):resetOffsetPos();

	if IsShowFguiMain() then
		standReportEvent("2", "NEWS", "-", "view")
	end
end

--设置公告红点为已读
function SetSiftRedDotReaded(v)
	ns_sift.has_show_ids = ns_sift.has_show_ids or {};

	local bNeedAdd2Cache = true;

	for i = 1, #(ns_sift.has_show_ids) do
		if v == ns_sift.has_show_ids[i] then
			bNeedAdd2Cache = false;
			break;
		end
	end

	if bNeedAdd2Cache then
		table.insert(ns_sift.has_show_ids, v);
		setkv("sift_red_dot", ns_sift.has_show_ids);
	end
end

--加载公告缓存
function GetSiftRedDotReaded()
	--print("GetSiftRedDotReaded:");
	local readed_cache = getkv("sift_red_dot") or {};

	--print(readed_cache);

	if readed_cache and #readed_cache > 100 then
		--清缓存
		--print("need clean cache:");
		local temp = {};

		for i = 1, #readed_cache do
			--缓存结构:"106_2019/06/27 10:00:00"
			local _, _, id, y, m, d, h, min, s = string.find(readed_cache[i], "(%d+)_(%d+)/(%d+)/(%d+)%s*(%d+):(%d+):(%d+)");
			--print("xxx:");
			--print(id);
			--print(y, m, d, h, min, s);

			if y and m and d then
				y = tonumber(y);
				m = tonumber(m);
				d = tonumber(d);
				local timestamp = os.time({year=y, month=m, day=d});
				local nowtime = os.time();
				--print("timestamp = ", timestamp);
				--print("nowtime = ", nowtime);

				if timestamp and timestamp > 0 then
					if nowtime - timestamp > 90 * 24 * 60 * 60 then
						--三个月前的清理掉
						--print("too old:");
					else
						--print("new:");
						table.insert(temp, readed_cache[i]);
					end
				end
			end
		end

		if temp and #temp > 0 and #temp < #readed_cache then
			--print("need reWrite cache:");
			readed_cache = temp;
			setkv("sift_red_dot", readed_cache);
		end
	end

	--print("end:");
	--print(readed_cache);
	return readed_cache;
end


function SiftFrame_OnHide()
	--重置按钮排序
	ns_sift.show_index = 0
	ns_sift.open_cell_id = 0

	if  SetSlidingFrameState then
		SetSlidingFrameState(true);
	end

	if  ClientCurGame:isInGame() then
		if not getglobal("SiftFrame"):IsRehide() then
		   ClientCurGame:setOperateUI(false);
		end
	end
end


function SiftFrame_OnEvent()
end


function SiftFrame_OnUpdate()
	--auto_refresh_xml( "ui/mobile/advert.xml" );
end

function SiftFramePlayAd(AdPosition)
	local etag = string.find(AdPosition,"ad")
	if not etag then
		return
	end
	local adIndex = tonumber(string.sub(AdPosition,etag + 2))
	if adIndex then
		--[[
		if not ShopAdvertCtrl then
			GetInst("UIManager"):Open("ShopAdvert")
			GetInst("UIManager"):Close("ShopAdvert")
			ShopAdvertCtrl = GetInst("UIManager"):GetCtrl("ShopAdvert")
		end
		ShopAdvertCtrl:PlayAdBtnClicked(nil, adIndex, false)]]

		if IsAdUseNewLogic(adIndex) then	
			local callback = function(ad_info)
				local key = "shopAdNum"..AccountManager:getUin()
				local maxKey = "shopAdMaxNum"
				local playAdNum = getkv(key) or 0
				local playAdMaxNum = getkv(maxKey,nil,102) or 20
				if ad_info and ad_info.finish.count and ad_info.finish.count > playAdNum then
					playAdNum = ad_info.finish.count
					setkv(key, playAdNum)
				end
				if ad_info and ad_info.num_total and ad_info.num_total > playAdMaxNum then
					playAdMaxNum = ad_info.num_total
					setkv(maxKey, playAdMaxNum, nil, 102)--102 跟账号无关
				end
				if not(playAdNum and playAdMaxNum and playAdNum < playAdMaxNum) then
					ShowGameTipsWithoutFilter(GetS(32003))
					return
				end
		
				-- local t_adPosList = {
				-- 	{pos=26, trigger_priority=999999999},
				-- 	{pos=16, trigger_priority=999999999},
				-- 	{pos=14, trigger_priority=999999999},
				-- }
				local adIndex = ad_data_new.getCanShowAdPosByMainId(26, true)
				if not adIndex then
					ShowGameTips(GetS(4980))
					return
				end
		
				local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(adIndex)
				if not curWatchADType then
					ShowGameTipsWithoutFilter(GetS(32002))
					Log("SiftFramePlayAd failed")
					return
				end
				Log("SiftFramePlayAd success : curWatchADType" .. curWatchADType .. "adpos" .. adIndex)
		
				local adPlayFinish2 = function ()
					AdService:Ad_Finish(adIndex, function(ad_info) 
						setkv(key, playAdNum + 1)
						setkv(maxKey, playAdMaxNum, nil, 102)--102 跟账号无关
	
						local adPlatform = {platform_id = id}
						AccountManager:ad_finish(adIndex, adPlatform);
						
						local adType = 1;
						if adIndex == 14 then
							adType = 2;
						elseif adIndex == 16 then
							adType = 6;
						end
						statisticsGameEventNew(1302, id, 48,"","","",GetCurrentCSRoomId(), adType);
					end)
				end
				
				statisticsGameEventNew(1301, id, 48,"","","",GetCurrentCSRoomId());
				GetInst("AdService"):Ad_StartPlay(adIndex, function()
					ad_data_new.curADCallBack = adPlayFinish2
					local isSuccess = Advertisement:request(curWatchADType, id or 0, adIndex)
				end)			
			end
			GetInst("AdService"):GetAdInfo(adIndex, callback)
		else
			local key = "shopAdNum"..AccountManager:getUin()
			local maxKey = "shopAdMaxNum"
			local playAdNum = getkv(key) or 0
			local playAdMaxNum = getkv(maxKey,nil,102) or 20
			local ad_info = AccountManager:ad_position_info(adIndex)
			if ad_info and ad_info.finish.count and ad_info.finish.count > playAdNum then
				playAdNum = ad_info.finish.count
				setkv(key, playAdNum)
			end
			if ad_info and ad_info.num_total and ad_info.num_total > playAdMaxNum then
				playAdMaxNum = ad_info.num_total
				setkv(maxKey, playAdMaxNum, nil, 102)--102 跟账号无关
			end
			if not(playAdNum and playAdMaxNum and playAdNum < playAdMaxNum) then
				ShowGameTipsWithoutFilter(GetS(32003))
				return
			end
	
			local t_adPosList = {
				{pos=26, trigger_priority=999999999},
				{pos=16, trigger_priority=999999999},
				{pos=14, trigger_priority=999999999},
			}
			local adIndex = t_ad_data.getCanShowAdPosByList(t_adPosList, true);
			if not adIndex then
				ShowGameTips(GetS(4980))
				return
			end
	
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(adIndex);
			if not curWatchADType then
				ShowGameTipsWithoutFilter(GetS(32002))
				Log("SiftFramePlayAd failed")
				return
			end
			Log("SiftFramePlayAd success : curWatchADType" .. curWatchADType .. "adpos" .. adIndex)
	
			local adPlayFinish2 = function ()
				threadpool:wait(0)
				setkv(key, playAdNum + 1)
				setkv(maxKey, playAdMaxNum, nil, 102)--102 跟账号无关
				local adPlatform = {platform_id = id}
				AccountManager:ad_finish(adIndex, adPlatform);
	
				local adType = 1;
				if adIndex == 14 then
					adType = 2;
				elseif adIndex == 16 then
					adType = 6;
				end
				statisticsGameEventNew(1302, id, 48,"","","",GetCurrentCSRoomId(), adType);
			end
			
			statisticsGameEventNew(1301, id, 48,"","","",GetCurrentCSRoomId());
			t_ad_data.curADCallBack = adPlayFinish2
			local isSuccess = Advertisement:request(curWatchADType, id or 0, adIndex)
		end
	end
end

---------------------------------------------------------------------------
function OpenMarketActivityFrame()
	ActivityMainCtrl:Active(ActivityMainCtrl.def.type.welfare,false)
end

function OpenActivityFrame()
	ActivityMainCtrl:Active(ActivityMainCtrl.def.type.activity,false)
end

function SiftCellBtn_OnClick(defaultID)
	--if  ns_sift.open_cell_id == this:GetClientID() then
	--	ns_sift.open_cell_id = 0;
	--else
	local old_open = ns_sift.open_cell_id;
	ns_sift.open_cell_id = defaultID or this:GetParentFrame():GetClientID();
	--end

	--获取对应的ID
	-- local cell_ads_id = this:GetParentFrame():GetClientUserData( ns_sift._CELL_ADS_ID_ );

	getglobal("SiftSlideCell" .. ns_sift.open_cell_id .. "BtRedDot"):Hide();
	--红点处理end

	if  ns_sift.open_cell_id ~= old_open then
		--左侧点击埋点
		local content = ns_sift.content_list[ ns_sift.open_cell_id ];
		if IsShowFguiMain() then
			standReportEvent("2", "NEWS", "SecondTab", "click", {standby1 = content.id or 0, standby2 = content.title or "null"})
			standReportEvent("2", "NEWS", "NewsPic", "view", {standby1 = content.id or 0, standby2 = content.title or "null"})
			standReportEvent("2", "NEWS", "GoButton", "view", {standby1 = content.id or 0, standby2 = content.title or "null"})
		else
			if defaultID == nil then --默认打开不上报埋点
				-- statisticsGameEventNew(1702, content.id, content.tag_txt, get_game_lang());
				standReportEvent("21", "FEATURED_CONTENT", "ActivityPit", "click", {slot=ns_sift.open_cell_id,cid = content.id,ctype=2,standby1 = content.title})
				standReportEvent("21", "FEATURED_CONTENT", "ActivityDisplay", "view", {cid = content.id,ctype=2,standby1 = content.title})
				standReportEvent("21", "FEATURED_CONTENT", "ActivityButton", "view", {cid = content.id,ctype=2,standby1 = content.title})
			end
		end
	end

	ns_sift.func.updateContent(ns_sift.content_list[ ns_sift.open_cell_id ].id, true)

	--内容有变化 曝光日志
	if ns_sift.content_list and ns_sift.content_list.index ~= old_
			and ns_sift.content_list[ ns_sift.content_list.index ]
			and ns_sift.content_list[ ns_sift.content_list.index ].id then
		--埋点
		local content = ns_sift.content_list[ ns_sift.open_cell_id ];
		-- statisticsGameEventNew(1703, content.id, content.tag_txt, get_game_lang())
	end

	for i = 1, ns_sift.label_max do
		local ui_check = getglobal("SiftSlideCell" .. i .. "BtCheckedBG")
		if i == ns_sift.open_cell_id then
			ui_check:Show()
		else
			ui_check:Hide()
		end
	end
	--ns_sift.func.updateRedDot(false);

	if getglobal("SiftFrameGotoBtn"):IsShown() and ns_sift.open_cell_id ~= old_open and ns_sift.content_list[ ns_sift.open_cell_id ] then
		local content = ns_sift.content_list[ ns_sift.open_cell_id ];
		if content.goto_btn and content.goto_btn.action then
			if content.goto_btn.action == 38 and content.goto_btn.url_string then   --迷你点广告按钮曝光埋点
				local etag = string.find(content.goto_btn.url_string,"ad")
				if not etag then
					return
				end
				local adIndex = tonumber(string.sub(content.goto_btn.url_string,etag + 2))
				if not adIndex then
					return;
				end

				local curWatchADType, id = t_ad_data.getWatchADIDAndType(adIndex);
				statisticsGameEventNew(1300, id or "",48,"","","",GetCurrentCSRoomId())
			end
		end
	end
end

function SiftBtnGoto_OnClick()
	----Log( this:GetName() .. ", id=" .. this:GetClientID() .. ", btn_type=" .. btn_goto_type );
	local content = ns_sift.content_list[ ns_sift.open_cell_id ];
	standReportEvent("21", "FEATURED_CONTENT", "ActivityButton", "click", {cid = content.id,ctype=2,standby1 = content.title})
	local btn_goto_type = content.goto_btn.action;
	local ads_id_ = content.id
	if  ads_id_ then
		if IsShowFguiMain() then
			standReportEvent("2", "NEWS", "GoButton", "click", {standby1 = ads_id_ or 0, standby2 = content.title or "null"})
		else
			-- statisticsGameEventNew(1705, ads_id_, content.tag_txt)
		end
	end

	if  btn_goto_type < 80 then    --99 98
		--隐藏公告界面
		ActivityMainCtrl:AntiActive()
	end
	local url = content.goto_btn.url_string

	--jump_app = "fx_wb", --fx_qq,fx_qqkj,fx_wx,fx_pyq,fx_wb 客户端资源为逻辑内增加判断逻辑，判断对应APP是否有安装（qq 微信 微博）
	--url_ext = "https://www.mini1.cn/", --资源位配置内增加H5字段，用于未安装对应应用时的跳转方式
	local jump_app = content.goto_btn.jump_app --- 客户端资源为逻辑内增加判断逻辑，判断对应APP是否有安装（qq 微信 微博）fx_qq,fx_qqkj,fx_wx,fx_pyq,fx_wb
	local url_ext = content.goto_btn.url_ext --- 资源位配置内增加H5字段，用于未安装对应应用时的跳转方式
	local params_ext = {}
	params_ext.jump_app = jump_app
	params_ext.url_ext = url_ext
	global_jump_ui( btn_goto_type, url, nil, params_ext);   --full url or totid=xxx

	--统一处理，除了跳外链,APP之外的跳转，都关闭页面
	if btn_goto_type ~= 99 and IsUIFrameShown("ActivityMainFrame") then
		ActivityMainCtrl:AntiActive()
	end
end


--中间图片按钮
function SiftPicBtn_OnClick()
	if  ns_sift.content_list and ns_sift.content_list.index  then
		----Log( "call SiftPicBtn_OnClick, index=" .. ns_sift.content_list.index );
		
		if ns_sift.content_list[ ns_sift.content_list.index ]
				and ns_sift.content_list[ ns_sift.content_list.index ].pic
				and ns_sift.content_list[ ns_sift.content_list.index ].pic.action then
			if  ns_sift.content_list[ ns_sift.content_list.index ].id then
				--ns_td_exposure_click.add( 1402, ns_sift.content_list[ ns_sift.content_list.index ].id )   --大图片点击
				--大图片点击埋点
				local content = ns_sift.content_list[ ns_sift.content_list.index ];
				if IsShowFguiMain() then
					standReportEvent("2", "NEWS", "NewsPic", "click", {standby1 = content.id or 0, standby2 = content.title or "null"})
				else
					-- statisticsGameEventNew(1704, content.id, content.tag_txt);
					standReportEvent("21", "FEATURED_CONTENT", "ActivityDisplay", "click", {cid=ns_sift.content_list[ ns_sift.content_list.index ].id,ctype=2,standby1 = content.title})
				end
			end

			if  ns_sift.content_list[ ns_sift.content_list.index ].pic.action < 90 then  --99 98
				--隐藏公告界面
				ActivityMainCtrl:AntiActive()
			end

			--jump_app = "fx_wb", --fx_qq,fx_qqkj,fx_wx,fx_pyq,fx_wb 客户端资源为逻辑内增加判断逻辑，判断对应APP是否有安装（qq 微信 微博）
			--url_ext = "https://www.mini1.cn/", --资源位配置内增加H5字段，用于未安装对应应用时的跳转方式
			local jump_app = ns_sift.content_list[ ns_sift.content_list.index ].pic.jump_app --- 客户端资源为逻辑内增加判断逻辑，判断对应APP是否有安装（qq 微信 微博）fx_qq,fx_qqkj,fx_wx,fx_pyq,fx_wb
			local url_ext = ns_sift.content_list[ ns_sift.content_list.index ].pic.url_ext --- 资源位配置内增加H5字段，用于未安装对应应用时的跳转方式
			local params_ext = {}
			params_ext.jump_app = jump_app
			params_ext.url_ext = url_ext

			global_jump_ui( ns_sift.content_list[ ns_sift.content_list.index ].pic.action,
					ns_sift.content_list[ ns_sift.content_list.index ].pic.action_url,
					ns_sift.content_list[ ns_sift.content_list.index ].string_code,
					params_ext);

			--统一处理，除了跳外链,APP之外的跳转，都关闭页面
			if ns_sift.content_list[ ns_sift.content_list.index ].pic.action ~= 99 and IsUIFrameShown("ActivityMainFrame") then
				ActivityMainCtrl:AntiActive()
			end
		end

	end
end

-----------------------------------逻辑函数部分--------------------

ns_sift.func =         --避免和其他全局函数冲突
{
	updateRedDot = function(isSetReaded)
		ns_sift.has_show_ids = GetSiftRedDotReaded();
		--print("---sift_red_dot---1>", ns_sift.has_show_ids)
		--print(ns_sift.has_show_ids)
		local show_index = 0;
		local haveNotReaded = false;
		for i=1, ns_sift.label_max do
			local cell = getglobal("SiftSlideCell" .. i);
			local cellBt = getglobal("SiftSlideCell" .. i.."Bt");
			local bIsShow = true;

			--print(" i = ", i);
            if ns_sift.content_list then 
				if i <= #ns_sift.content_list then
					--print("has show : ", i)
					for k,v in ipairs(ns_sift.has_show_ids) do
						--print("=====>>>>>>>>", v, ",", cell:GetClientUserData( ns_sift._CELL_ADS_ID_ ), ns_sift._CELL_ADS_ID_, ns_sift.content_list[i].start_time)
						--local ds = cell:GetClientUserData( ns_sift._CELL_ADS_ID_ ) .. '_' .. ns_sift.content_list[i].start_time;
						if v == (ns_sift.content_list[i].id .. '_' .. ns_sift.content_list[i].start_time) then
							-- 该公告已看过，不再显示红点
							getglobal("SiftSlideCell" .. i .. "BtRedDot"):Hide();
							bIsShow = false;
							break;
						end
					end

					if bIsShow then
						--根据配置的红点显示的期限设置红点是否显示
						local start_time_ = uu.get_time_stamp(ns_sift.content_list[i].start_time);
						if ns_sift.content_list[i].red_day == -1 or ns_sift.content_list[i].red_day <=0 then
							getglobal("SiftSlideCell" .. i .. "BtRedDot"):Hide();
							bIsShow = false;
						elseif ns_sift.content_list[i].red_day>0 then

							local red_day_ = ns_sift.content_list[i].red_day*24*60*60 +start_time_
							if red_day_<os.time() then
								bIsShow = false;
								getglobal("SiftSlideCell" .. i .. "BtRedDot"):Hide();
							end
						end


						if show_index == 0  then
							--local id = cell:GetClientUserData( ns_sift._CELL_ADS_ID_ );
							local id = ns_sift.content_list[i].id;
							--设置公告红点为已读
							if isSetReaded  then
								SetSiftRedDotReaded(id .. '_' .. ns_sift.content_list[i].start_time);
							end

							--if ns_sift.content_list[i].no_top == -1 then --根据配置设置按钮是否置顶
							 	show_index = i;
							--end
						else
							if bIsShow == true then
								haveNotReaded = bIsShow;
							end
						end
					end
					cellBt:SetChecked(false);
					cellBt:Enable();
				end
			end
		end
		ns_sift.unRead = {};
		if haveNotReaded == true then
			ns_sift.unRead = {k = 1}; --兼容老代码，随便赋值
			getglobal("ActivityMainFrameTypeBtn4RedTag"):Show();
		else
			getglobal("ActivityMainFrameTypeBtn4RedTag"):Hide();
		end
		ActivityMainCtrl:CheckRedTagForSift();
		if show_index == 0 then
			show_index = 1;
		end
		local cell_ads_id = getglobal("SiftSlideCell"..show_index):GetClientUserData( ns_sift._CELL_ADS_ID_ );
		--ns_sift.func.updateContent(cell_ads_id, true)
		--设置优先展示的公告下标
		ns_sift.show_index = show_index
		if show_index ~= 1 and not getglobal("SiftFrame"):IsShown() then
			--将显示的公告按钮置顶
			ns_sift.func.updateCellPos();
		end

		--返回优先显示的公告id
		return cell_ads_id
	end,

	updateContent = function(cell_ads_id, isSetChecked)

		--图片内容以及底部内容需要有配置才显示
		getglobal( "SiftFrameBigPic" ):Hide();
		getglobal( "SiftFramePicFrame" ):Hide();
		getglobal( "SiftFrameDuration" ):Hide();
		getglobal( "SiftFrameGotoBtn" ):Hide();
		getglobal("SiftFramePicBtn"):Hide();

		if ns_sift.content_list == nil then return end
		local old_ = ns_sift.content_list.index
		for i = 1, #ns_sift.content_list do
			local ui_cell = getglobal("SiftSlideCell" .. i);
			local ui_cellBt = getglobal("SiftSlideCell" .. i .. "Bt");
			local ui_cellLabel = getglobal("SiftSlideCell" .. i .. "Label");
			local ui_cellBtLabelBg = getglobal("SiftSlideCell" .. i .. "LabelBg");
			local ui_cellBtLabelText = getglobal("SiftSlideCell" .. i .. "LabelText");
			if ns_sift.content_list[i].id == cell_ads_id then
				--红点处理，点击后再也不显示红点
				SetSiftRedDotReaded(cell_ads_id .. '_' .. ns_sift.content_list[i].start_time);
				--红点处理end

				local plane_y = 0; -- 滑动条的高度
				local content = ns_sift.content_list[i];
				ns_sift.content_list.index = i;

				--图片处理
				local pic_x; -- 图片宽度
				local pic_y;
				if content.pic then
					getglobal( "SiftFramePicFrame" ):Show();
					getglobal( "SiftFrameBigPic" ):Show();
					getglobal("SiftFramePicBtn"):Show();

					print("xxxx:content.pic.file_name = ", content.pic.file_name);
					--print(content.pic);
					local new_name_ = check_http_image_jpg( content.pic.file_name );
					getglobal( "SiftFrameBigPic" ):ReleaseTexture(new_name_);
					getglobal( "SiftFrameBigPic" ):SetTexture( new_name_ );

					pic_x = ns_sift.PIC_WIDTH; 
					pic_y = getglobal( "SiftFrameBigPic" ):getRelHeight(); -- 图片高度
					if pic_y <= 4 then
						--未完成下载先隐藏
						print("pic_y <= 4")
						getglobal( "SiftFramePicFrame" ):Hide();
						--getglobal( "SiftFrameBigPic" ):Hide();
						--getglobal("SiftFramePicBtn"):Hide();
					end
					--print("pic_x = ", pic_x, ", pic_y = ", pic_y);
					getglobal( "SiftFramePicFrame" ):SetSize(pic_x+10, pic_y+10); -- 设置相框大小
					getglobal( "SiftFrameBigPic" ):SetSize(pic_x, pic_y);
					getglobal("SiftFramePicBtn"):SetSize(pic_x, pic_y);

					plane_y = pic_y;

					--ui_cell:SetChecked(false);
				end --图片处理end

				--文字处理
				local line_y = 24; -- 一行的高度
				local blocks_len = {};
				if content.texts then
					local texts_num = #content.texts;
					ns_sift.func.create_ui_content(texts_num);
					for j = 1, ns_sift.text_num do
						local ui_block = getglobal("SiftFrameContentBlock" .. j);
						if j <= texts_num then
							local ui_title = getglobal("SiftFrameContentBlock" .. j .. "Title");
							local ui_text = getglobal("SiftFrameContentBlock" .. j .. "Text");
							local text_y = 0; --该文字块的高度
							local has_title = not IsEmptyString(content.texts[j].title);

							if has_title then --暂时兼容旧公告无标题的content
								ui_title:SetText(content.texts[j].title);
								ui_text:SetPoint("topleft", "SiftFrameContentBlock" .. j .. "Title", "bottomleft", 1, 14);
								ui_title:Show();
								text_y = 24 + 14; --标题的高度 + 标题与内容的距离
							else
								ui_text:SetPoint("topleft", "SiftFrameContentBlock" .. j, "topleft", 0, 0);
								ui_title:Hide();
							end

							ui_text:SetText(content.texts[j].text, 111, 145, 150);
							local lines = ui_text:GetTextLines();
							if lines > 0 then
								ui_text:SetSize(748, line_y * lines + 10);
								text_y = text_y + line_y * lines;
							end
							ui_block:SetSize(746, text_y);
							table.insert(blocks_len, text_y);

							if has_title then
								plane_y = plane_y + 14 + 24; -- 标题与上一部分的距离 + 标题的高度
							end
							-- 文字块中， + 标题和内容的距离 + 内容的高度
							plane_y = plane_y + 14 + line_y * lines;

							ui_block:Show();
						else
							ui_block:Hide();
						end

					end
				else
					for j = 1, ns_sift.text_num do
						getglobal("SiftFrameContentBlock" .. j):Hide();
					end
				end --文字处理end

				-- 图文滚动处理
				if plane_y < ns_sift.CONTENT_LIMIT_HEIGHT then
					getglobal("SiftFrameDetailSliderBoxPlane"):SetSize(758, ns_sift.CONTENT_LIMIT_HEIGHT);
				else
					getglobal("SiftFrameDetailSliderBoxPlane"):SetSize(758, plane_y+12+16);
				end
				local y = 0;
				if content.pic then
					getglobal("SiftFramePicFrame"):SetPoint("topleft", "SiftFrameDetailSliderBoxPlane", "topleft", 0, 0);
					y = y + pic_y + 5 + 14;
				end
				if #blocks_len > 0 then
					for j = 1, #blocks_len do
						getglobal("SiftFrameContentBlock" .. j):SetPoint("topleft", "SiftFrameDetailSliderBoxPlane", "topleft", -1, y);
						y = y + blocks_len[j] + 14;
					end
				end
				getglobal("SiftFrameDetailSliderBox"):resetOffsetPos(); --重置滚动
				--图文滚动处理end

				-- 活动时间
				if content.duration then
					getglobal( "SiftFrameDuration" ):SetText( content.duration );
					getglobal( "SiftFrameDuration" ):Show();
				else
					getglobal( "SiftFrameDuration" ):Hide();
				end

				-- 跳转按钮
				local ui_goto_btn = getglobal("SiftFrameGotoBtn");
				local goto_btn = content.goto_btn;
				if goto_btn and goto_btn.can_show then

					if goto_btn.action_txt then -- 按钮文字
						getglobal("SiftFrameGotoBtnText"):SetText(goto_btn.action_txt);
					else
						getglobal("SiftFrameGotoBtnText"):SetText("立即参加");
					end
					 --一键直播需初始化后再判断是否可显示按钮
					 if goto_btn.action == ns_data.live_button_id then
						ui_goto_btn:SetClientID(goto_btn.action);
						if ns_sift.func.check_button_canshow(goto_btn) then
							ui_goto_btn:Show();
						else
							ui_goto_btn:Hide();
						end
					else
						ui_goto_btn:Show();
					end
				else
					ui_goto_btn:Hide();
				end --跳转按钮end
			else
				if isSetChecked then
					ui_cellBt:SetChecked(false);
				end
			end

		end

	end,

	check_can_show = function( data_, name_ )
		local ret_ = ns_sift.func.__check_can_show( data_, name_ )
		if  not ret_ then
			----Log( "======ma_check_show_conditions_false=====ad====" .. (data_.id or "no_id") .. " / " .. (data_.title or "no_title") )
		end
		return ret_
	end,

	__check_can_show = function( data_, name_ )
		--过滤图片和公告 日期 渠道 版本
		--start_time = "2016/11/01 00:00:00",
		--end_time   = "2016/11/02 23:59:59",
		--apiid      = 1
		--ver        = 9.4

		if  data_ then		
			if  data_.start_time then
				local start_time_ = uu.get_time_stamp( data_.start_time );
				if   start_time_ > os.time() then
					return false;
				end
			end


			if  data_.end_time then
				local end_time_ = uu.get_time_stamp( data_.end_time );
				if  end_time_ < os.time() then
					return false;
				end
			end

			--其他条件判断 apiids  version  uin等
			if  not ma_check_show_conditions( data_, "ad" ) then
				return false
			end

			--判断广告情况 --469 资源工坊 专题id
			if data_.action_url and data_.action_url ~= "" and string.len(data_.action_url) < 10 and data_.action_button ~= 469 and data_.action_button ~= 4000 then
				local adtag = string.find(data_.action_url,"ad")
				if adtag then
					local advertCfg = GetInst("ShopConfig"):GetCfgByKey("advertCfg")
					return advertCfg and advertCfg.advert and advertCfg.advert == 1
				else
					return false
				end
			end

			--新手福利活动
			if data_.action_button == 39 then
				local isnovice,isWelfare = MiniLobby_IsNoviceWelfare();
				print("MiniLobby_IsNoviceWelfare", isnovice, isWelfare)
				return isWelfare;
			end

			return true;
		end

		----Log( "call advert check_can_show no data_" );
		return false;
	end,

	--倒序查找
	reverseFind  = function (str, k)
		local ts = string.reverse(str);
		local i  = string.find(ts, k);
		if i then
			return #str - i + 1;
		end
		return nil;
	end,

	trimUrlFile = function(url)
		-- ww.xxx:8080/openG3/m/appPanel.vm?appId=1&appk
		local ret = url;
		-- trim ?
		local pos = string.find( ret, '?' );
		if pos then
			ret = string.sub(ret, 1, pos-1);
		end

		pos = ns_sift.func.reverseFind( ret, '/' );
		if pos then
			ret = string.sub(ret, pos+1);
		end

		----Log( "trim ret=[" .. ret .. "]" );
		return ret;
	end,


	--按照服务器返回的数据刷新UI
	resetMAUI = function()
		----Log("resetMAUI in")

		-- 以下逻辑跟获取用户标记数据没有关系，没必要等到结果后再执行；
		-- 相反，如果异步等到结果后再执行，与 SiftFrame_OnShow() 的执行顺序不确定，会导致首次红点显示bug		
			if not ns_sift.content_list or #ns_sift.content_list <= 0 then

				ns_sift.func.cleanData()
			end

		
			--更新内容
			if  ns_sift.content_list and #ns_sift.content_list > 0 then
				local content_list = ns_sift.content_list

			--	if ns_sift.show_index == 0 then
					ns_sift.func.updateRedDot(false)
			--	end

				-- 下载图片
				local function downloadPng_cb()
					if ns_sift.content_list and #ns_sift.content_list > 0 then
						local pic_y = getglobal( "SiftFrameBigPic" ):getRelHeight(); -- 图片高度
						if ns_sift and ns_sift.open_cell_id --[[and pic_y <= 4--]] then -- 这里 ui_texture 默认的empty.png 高度是32, 4太小了，下载完也走不进if里面；这里选择不做高度判断了
							local content = ns_sift.content_list[ns_sift.open_cell_id]
							if content and content.pic then
								ns_sift.func.updateContent(ns_sift.content_list[ns_sift.open_cell_id].id, false)
							end
						end
					end
				end

				--优先下载优先展示的图片
				if ns_sift.show_index ~= 0 then
					local pic = content_list[ns_sift.show_index].pic
					if pic and pic.pic_url then
						----Log("fisrt download :" .. pic.pic_url)
						ns_http.func.downloadPng( pic.pic_url, pic.file_name, pic.check_size, nil, downloadPng_cb);
					end
				end

				for i=1, #content_list do
					if ns_sift.show_index ~= i then
						local pic = content_list[i].pic
						if pic and pic.pic_url then
							ns_http.func.downloadPng( pic.pic_url, pic.file_name, pic.check_size, nil, downloadPng_cb);
							pic.task_id = "ok";                  --已经完成
						end
					end
				end-- 格式化图片数据end

				--左侧按钮
				local high_ = 31; -- start_pos of plane
				for i = 1, ns_sift.label_max do
					if i <= #content_list then

						local title = content_list[i].title or "";
						local ui_title;
						local btn_name = "SiftSlideCell" .. i;
						getglobal(btn_name):Show();
						getglobal(btn_name):SetClientUserData( ns_sift._CELL_ADS_ID_, content_list[i].id );
						high_ = high_ + ns_sift.CELL_HEIGHT;

						local ui_longText = getglobal("SiftSlideCell" .. i .. "BtLongText");
						ui_longText:SetText(title, 55, 54, 49);
						local lines = ui_longText:GetTextLines();
						ui_longText:Hide();

						if lines <= 1 then
							--单行使用居中短标题(FontString)
							ui_title = getglobal("SiftSlideCell" .. i .. "BtShortText");
							ui_title:SetText(title);
						else
							--多行使用左对齐长标题(RichText)
							if lines > 2 then
								getglobal("SiftSlideCell" .. i):SetSize(224, 107);
								ns_sift.content_list[i].is_long_title = true;
								high_ = high_ + 22; -- 107 - 85
							end
							getglobal("SiftSlideCell" .. i .. "BtShortText"):Hide()
							ui_title = ui_longText;
						end

						ui_title:Show();
						--标签处理
						local content = ns_sift.content_list[i];
						local ui_cellLabel = getglobal("SiftSlideCell" .. i .. "Label");
						local ui_cellBtLabelBg = getglobal("SiftSlideCell" .. i .. "LabelBg");
						local ui_cellBtLabelText = getglobal("SiftSlideCell" .. i .. "LabelText");
						if content.tag_color and ns_sift.label_colors[content.tag_color] and (content.tag_txt or content.tag_txt_2) then
							ui_cellLabel:Show();
							local label_color = ns_sift.label_colors[content.tag_color];
							ui_cellBtLabelBg:SetTexUV(label_color);
							if content.tag_txt_2 and content.tag_txt_2 ~= "" and content.tag_txt_2 ~= " " then 
								ui_cellBtLabelText:SetText(content.tag_txt_2);
							else
								ui_cellBtLabelText:SetText(GetS(content.tag_txt));
							end 
							--海外统一长度
							if (ns_sift.env >= 10) then
								ui_cellLabel:SetWidth(96);
								ui_cellBtLabelBg:SetWidth(106);
								ui_cellLabel:SetPoint("topleft", "SiftSlideCell" .. i .. "Bt", "topleft", 20, -16);
							else
								local width
								if content.tag_txt_2 and content.tag_txt_2 ~= "" and content.tag_txt_2 ~= " " then 
									width = ui_cellLabel:GetTextExtentWidth(content.tag_txt_2)
								else
									width = ui_cellLabel:GetTextExtentWidth(GetS(content.tag_txt))
								end 
								ui_cellLabel:SetWidth(width+48);
								ui_cellBtLabelBg:SetWidth(width+58);
								ui_cellLabel:SetPoint("topleft", "SiftSlideCell" .. i .. "Bt", "topleft", 20, -16);
								-- if content.tag_txt == 32505 then
								-- 	ui_cellLabel:SetWidth(76);
								-- 	ui_cellBtLabelBg:SetWidth(86);
								-- 	ui_cellLabel:SetPoint("topleft", "SiftSlideCell" .. i .. "Bt", "topleft", 20, -16);
								-- end
								-- if content.tag_txt == 32509 then
								-- 	ui_cellLabel:SetWidth(96);
								-- 	ui_cellBtLabelBg:SetWidth(106);
								-- 	ui_cellLabel:SetPoint("topleft", "SiftSlideCell" .. i .. "Bt", "topleft", 20, -16);
								-- end
							end
						else
							ui_cellLabel:Hide();
						end

						if IsShowFguiMain() then
							standReportEvent("2", "NEWS", "SecondTab", "view", {standby1 = content_list[i].id or 0, standby2 = content_list[i].title or "null"})
						end
					else
						local btn_name = "SiftSlideCell" .. i;
						getglobal(btn_name):Hide();
					end
				end
				if  high_ < ns_sift.CONTENT_LIMIT_HEIGHT then
					high_ = ns_sift.CONTENT_LIMIT_HEIGHT
				end
				getglobal("SiftFrameContentSliderBoxPlane"):SetSize(246, high_ );
				--左侧按钮end
			end

			--更新位置
			ns_sift.func.updateCellPos();

	end,

	--清洗服务器数据得到有效内容
	cleanData = function()
		--Log("SiftFrame cleanData in")
		if  ns_sift.server_config and #ns_sift.server_config > 0 then


			ns_sift.content_list = { index = 0, };
			local ads_raw_ = ns_sift.server_config; --数据列表
			local ads_ = {};
			for i=1, #ads_raw_ do
				if  ns_sift.func.check_can_show( ads_raw_[i], "right" ) == true and ads_raw_[i].id ~=nil then
					table.insert( ads_, ads_raw_[i] );
				end
			end


			if ads_ and #ads_ > 0 then
				ns_sift.open_cell_id = 0;--默认收缩公告

				for i=1, ns_sift.label_max do
					if i <= #ads_ then

						local content = { id = ads_[i].id};

						--整理图片数据,下载图片
						local pic_ = ads_[i].pic2;    
						----Log( "pics_.size=" .. #pics_ );
						local pic_url;
						local file_name;
						if  ads_[i].pic2 then
							pic_url   =  ads_[i].pic2;
							file_name = g_download_root .. ns_sift.func.trimUrlFile( ads_[i].pic2) .."_";		--加上"_"后缀
							--no pic
						end

						if file_name and #file_name > 3 then
							--if pic_url then
							--	ns_http.func.downloadPng( pic_url, file_name, pics_[i].check_size, nil, downloadPng_cb);
							--end
							--pics_[i].task_id = "ok";                  --已经完成
							local url_ =  ads_[i].pic_url or "";
							local pic = { pic_url = pic_url,
											file_name = file_name,
											check_size = ads_[i].check_size,
											action =ads_[i].action_pic,
											action_url = url_,
											jump_app =ads_[i].jump_app_pic,
											url_ext =ads_[i].url_ext_pic};
							
							content.pic = pic;
						end

						--整理图片数据,下载图片end
						table.insert(ns_sift.content_list, content);

						--记录开始时间，用于红点
						content.start_time = ads_[i].start_time;

						content.red_day = ads_[i].red_day or -1;  	-- 默认不显示红点 red_day 红点显示的天数
						--content.no_top = ads_[i].no_top or -1; 		-- 1:参与置顶排序 -1：不参与置顶排序
						content.no_top = 1;

						--按钮文字
						content.title = ads_[i].title;

						--goto按钮类型
						local goto_btn = {};
						if  ads_[i].action_button and ads_[i].action_button>0 then
							goto_btn.can_show = true;
							goto_btn.action = ads_[i].action_button;

							if ads_[i].action_button == 99 or ads_[i].action_button == 98 or ads_[i].action_button == 94 or ads_[i].action_button == 31 or ads_[i].action_button == 38 or ads_[i].action_button == 469 or ads_[i].action_button == 4000 then
								--99=跳url  --98=分享	--31=礼包跳转+礼包id --469 资源工坊 专题id
								local url_ = ads_[i].action_url or "";
								goto_btn.url_string = url_;
								goto_btn.jump_app = ads_[i].jump_app;
								goto_btn.url_ext = ads_[i].url_ext;
							elseif ads_[i].action_button == 83 or ads_[i].action_button == 23 or ads_[i].action_button == 25  or ads_[i].action_button == 121 then
								--23=带帖子ID跳社区   (like xxx=yy&totid=22 ) 25=地图详情页
								local info_ = ads_[i].action_url or "";
								goto_btn.url_string = info_;
							end
						else
							goto_btn.can_show = false;
						end

						--文字内容操作
						local texts = {};
						if ads_[i].contents then
							for j = 1, #ads_[i].contents  do
								if ads_[i].contents[j].title and ads_[i].contents[j].text then
									table.insert(texts, ads_[i].contents[j]);
								elseif not ads_[i].contents[j].title and ads_[i].contents[j].text then
									--只有文字，没有标题，也可以展示
									ads_[i].contents[j].title = ""
									table.insert(texts,ads_[i].contents[j])
								end
							end
						elseif ads_[i].content then --兼容旧版本配置
							local text = { title="", text=ads_[i].content };
							table.insert(texts, text);
						end

						if  ads_[i].action_txt then
							goto_btn.action_txt = ads_[i].action_txt;
						end

						content.texts = texts; --文字内容
						content.duration = ads_[i].time; --活动时间
						content.goto_btn = goto_btn; --跳转按钮状态
						content.tag_txt = ads_[i].tag_txt;
						content.tag_color = ads_[i].tag_color;
						content.tag_txt_2 = ads_[i].tag_txt_2;

					else
						--local btn_name = "SiftSlideCell" .. i; -- TODO
						--getglobal(btn_name):Hide();
					end
				end

			end 
			-- 格式化图片数据

			--for i = 1, #ns_sift.content_list do
			--	print(ns_sift.content_list[i])
			--end

			--更新位置
			--ns_sift.func.updateCellPos();
		end
	end,

	--设置条目的宽度和位置
	updateCellPos = function ()
		----Log( "call updateCellPos, open_cell_id=" ..  ns_sift.open_cell_id );
		if not ns_sift.content_list then
			return
		end
		local height = 16; -- start_pos
		local first = ns_sift.show_index or 0
		if first ~= 0 then
			getglobal("SiftSlideCell" .. first):SetPoint("topleft", "SiftFrameContentSliderBoxPlane", "topleft", 9, height);
			height = height + ns_sift.CELL_HEIGHT;
			if ns_sift.content_list[first] and ns_sift.content_list[first].is_long_title then
				-- 三行的长标题需要加高标题框
				height = height + 22; -- 标准高度为85，加高后为107，得差22
			end
		end

		for i = 1, ns_sift.label_max do
			if first ~= i then
				local btn_name = "SiftSlideCell" .. i;

				getglobal(btn_name):SetPoint("topleft", "SiftFrameContentSliderBoxPlane", "topleft", 9, height);
				height = height + ns_sift.CELL_HEIGHT;
				if ns_sift.content_list[i] and ns_sift.content_list[i].is_long_title then
					-- 三行的长标题需要加高标题框
					height = height + 22; -- 标准高度为85，加高后为107，得差22
				end
			end
		end
	end,

	check_button_canshow = function(data_)
		--微信视频号一键直播
		if data_.action == ns_data.live_button_id then
			if WXGameLiveMgr then
				local uin_ = AccountManager:getUin() or 0;
				local result = WXGameLiveMgr:checkSupport(uin_);
			end
			return true;
		end
		return false;
	end,
	
	--是否弹窗
	check_pop_advert = function()
		if  ns_sift.server_config and ns_sift.server_config.pop_advert then
			local data_ = ns_sift.server_config.pop_advert
			--print(data_)
			--check time
			if data_.pop_advert and data_.pop_advert == 0 then
				return false;
			end
			local now_ = getServerNow()

			if  check_apiid_ver_conditions( data_ ) then
				--需要显示

				if  not ns_sift.pop_advert_data then
				ns_sift.pop_advert_data = getkv( "data", "pop_ads", 101 ) or { t=0, cc=0 }  --102公共uin
				end
				--print(ns_sift.pop_advert_data)
				if  now_ - ns_sift.pop_advert_data.t >= 86400 then
					ns_sift.pop_advert_data.cc = 0
					ns_sift.pop_advert_data.t  = now_
				end

				ns_sift.pop_advert_data.cc = ns_sift.pop_advert_data.cc + 1
				if  ns_sift.pop_advert_data.cc <= data_.count then
					setkv( "data",  ns_sift.pop_advert_data, "pop_ads", 101 )
					return true   --可以显示
				end
				--Log("check_pop_advert : count enough")
			end

			return false   --不显示
		end
	end,
	

	--是否弹窗
	check_pop_advert_show = function(cb_)
		--每次启动只判断一次
		if  ns_sift.pop_advert_data then
			----Log("pop_advert_data has set, checked, ignore")
			return
		end
	
		--1 新手不弹 ( 首次打开游戏的新手没有pop_ads字段 )
		ns_sift.pop_advert_data = getkv( "data", "pop_ads", 101 )
		if  not ns_sift.pop_advert_data then
			ns_sift.pop_advert_data = { t=0, cc=0 }
			----Log( "call check_pop_advert_show, new player" )
			setkv( "data", ns_sift.pop_advert_data, "pop_ads", 101 )   --新手首次打开
			return
		else
			----Log( "call check_pop_advert_show, old player" )
		end

		--未过配置检测不弹
		if not ns_sift.func.check_pop_advert() then
			return
		end

		--新手引导过程中不弹
		local guideStep = GetGuideStep()
		if guideStep and guideStep >= 0 and guideStep <= 7 then 
			--print("新手引导过程中不弹")
			return 
		end

		if not ns_sift.content_list then
			ns_sift.func.cleanData()
		end
		ns_sift.func.updateRedDot(false)

		--2 下载第一幅图片成功后，才开始弹
		local pic_info_
		if  ns_sift.content_list and #ns_sift.content_list > 0 then
			if ns_sift.show_index ~= 0 then
				pic_info_ = ns_sift.content_list[ns_sift.show_index].pic
			end
		end

		if  pic_info_ then
			--Log( "has pic2, download:" .. pic_info_.pic_url )
			--if  ns_sift.func.check_pop_advert() then
			--	--Log( "download start" )
				ns_http.func.downloadPng( pic_info_.pic_url, pic_info_.file_name, pic_info_.check_size, nil, cb_ );
			--else
			--	--Log( "download not start, check_pop_advert false" )
			--end
		else
			----Log( "no pic2" )
			--没有图片，直接打开
			if cb_ then
				cb_() 
			end
		end

	end,

	--动态创建文字块UI控件
	create_ui_content = function(num)
		-- 数量已满足则直接返回
		if ns_sift.text_num >= num then
			return
		end
		local type_name = "Frame"
		local template_name = "SiftContentBlockTemplate"
		local parent_name = "SiftFrameDetailSliderBox";

		for i = ns_sift.text_num+1, num do
			local name = "SiftFrameContentBlock" .. i;
			local text = UIFrameMgr:CreateFrameByTemplate(type_name, name, template_name, parent_name);
			--RichText需要先定义Rect，否则接下来的第一次绘制会失败
			getglobal(text:GetName() .. "Text"):SetSize(748, 113)
			getglobal(text:GetName() .. "Text"):resizeRect(748, 748);
			if i == 1 then
				-- 初始化默认对齐于图片，若无图片修改第一个文字块的位置即可
				text:SetPoint("topleft", "SiftFramePicFrame", "bottomleft", -1, 14);
			else
				text:SetPoint("topleft", "SiftFrameContentBlock"..i-1, "bottomleft", 0, 14);
			end
			if text then
				text:Hide();
			end
		end

		ns_sift.text_num = num;
	end,

};     --end func


-- 精选 - 一键直播 --
MiniLiveSDKInterface = 
{
	onSupport = function(self, isSupport)
		if WXGameLiveMgr then
			print("Fxkk1=======>>>", isSupport);
			WXGameLiveMgr:onSupportCallback(isSupport);		
		end
	end,

	onLiveStateEvent = function(self, state)
		if not WXGameLiveMgr then return end
		print("Fxkk2=======>>>", state);
		if state == 0 then
			WXGameLiveMgr:onBeginLiveShow();
		elseif state == 1 then
			WXGameLiveMgr:onEndedLiveShow();
		end

	end,
}
