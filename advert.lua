
-------advert--------游戏公告-----(utf-8)----------


ns_advert = {      --namespace advert

	CELL_HEIGHT 		= 99,
	CELL_INFO_HEIGHT 	= 260,
	PIC_WIDTH 			= 748, --图片宽度
	CONTENT_LIMIT_HEIGHT= 432, --图文内容限制高度（超出则滚动）

	_GOTO_BTN_TYPE_ 	= 1,             --按钮类型
	_CELL_ADS_ID_ 		= 2,             --cell展示的广告id

	open_cell_id 		= 1,          --当前打开哪一个格子
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
}


----xml functions-----------------------------------------------------------
function AdvertFrame_OnLoad()
	--Log( "call AdvertFrame_OnLoad" );

	this:setUpdateTime(1);
end


--拉取fqa信息
function  WWW_file_getFQA( call_back )
	if  ns_advert.server_fqa then
		--已经拉取
		Log( "WWW_file_getFQA use cache" );
	else
		Log( "call WWW_file_getFQA" );
		ns_advert.server_fqa_callback = call_back;
		local file_name_, download_  = getLuaConfigFileInfo( "fqa" );
		ns_http.func.downloadLuaConfig( file_name_, download_, ns_data.cf_md5s['fqa'], WWW_file_getFQA_callback, "cdn" );

	end
end


function WWW_file_getFQA_callback( ret_table_ )
	Log( "call WWW_file_getFQA_callback" );
	--ns_advert.server_fqa = ret_table_ or {};

	ns_advert.server_fqa = {}
	
	--过滤一次条件contitions
	if ret_table_  ~= nil then 
		for i=1, #ret_table_ do
			local  tmp_ = {}
			for j=1, #ret_table_[i] do
				if  ret_table_[i][j].conditions then
					if  check_apiid_ver_conditions(ret_table_[i][j].conditions, false) then					
						tmp_[ #tmp_ + 1 ] = ret_table_[i][j]
					end
				else
					tmp_[ #tmp_ + 1 ] = ret_table_[i][j]
				end
			end		
			if  #tmp_ > 0 then
				ns_advert.server_fqa[ #ns_advert.server_fqa + 1 ] = tmp_
			end		
		end
	end 

	
	--进行多语言转换
	for i=1, #ns_advert.server_fqa do
		for j=1, #ns_advert.server_fqa[i] do
			if  ns_advert.server_fqa[i][j].q and ns_advert.server_fqa[i][j].a then
				resetLangText( ns_advert.server_fqa[i][j], "q" );
				resetLangText( ns_advert.server_fqa[i][j], "a" );
			end
		end
	end

	--回调
	if  ns_advert.server_fqa_callback then
		ns_advert.server_fqa_callback();
		ns_advert.server_fqa_callback = nil;
	end
end

function ReqAdvertUserTag(callback,data)
	if callback == nil then return end

	local url_ = g_http_root_map .. '/miniw/php_cmd?act=get_user_biaoqian'..'&' .. http_getS1();

	if ns_advert.user_tag ~= nil then
		local ret = {}
		ret[1] = ns_advert.user_tag
		callback(ret,data)
	else
		ns_http.func.rpc( url_, callback, data, nil, ns_http.SecurityTypeHigh);
	end


end


function AdvertFrame_OnShow()
	--Log( "call AdvertFrame_OnShow" );
	-- if IsAndroidBlockark() then
		-- Advertisement:preload(1015, 9);
		-- Advertisement:preload(1015, 10);
		-- Advertisement:preload(1015, 15);
		-- statisticsGameEvent(1303, "%d", 1015, "%d", 9);
		-- statisticsGameEvent(1303, "%d", 1015, "%d", 10);
		-- statisticsGameEvent(1303, "%d", 1015, "%d", 15);
	-- end

	if IsShowFguiMain() then
		standReportEvent("2", "NOTICE", "-", "view")

		--埋点公告view
		if  ns_advert.content_list and #ns_advert.content_list > 0 then
			local content_list = ns_advert.content_list
			--左侧按钮
			for i = 1, ns_advert.label_max do
				if i <= #content_list then
					standReportEvent("2", "NOTICE", "Notice1", "view", {standby1=content_list[i].id})
				else
					break
				end
			end
		end
	end

	if  SetSlidingFrameState then
		SetSlidingFrameState(false);
	end
	if  ClientCurGame:isInGame() then
		if not getglobal("AdvertFrame"):IsReshow() then
			ClientCurGame:setOperateUI(true);
		end
	end

	--首次右侧曝光
	--if  ns_advert.open_cell_id > 0  and ns_advert.first_cell_task_id > 0 then
	--	ns_td_exposure_click.add( 1403, ns_advert.first_cell_task_id )   --公告右侧查看点击
	--	print("dadian 1403")
	--end

	--红点处理
	ns_advert.func.updateRedDot(true)
	press_btn("AdvertSlideCell" .. ns_advert.show_index);

	getglobal("AdvertFrameContentSliderBox"):resetOffsetPos();
end

--设置公告红点为已读
function SetAdvertRedDotReaded(v)
	--v的结构: "106_2019/06/27 10:00:00"
	--print("SetAdvertRedDot:");
	--print(v);
	ns_advert.has_show_ids = ns_advert.has_show_ids or {};

	local bNeedAdd2Cache = true;

	for i = 1, #(ns_advert.has_show_ids) do
		if v == ns_advert.has_show_ids[i] then
			bNeedAdd2Cache = false;
			break;
		end
	end

	if bNeedAdd2Cache then
		table.insert(ns_advert.has_show_ids, v);
		setkv("advert_red_dot", ns_advert.has_show_ids);
	end
end

--加载公告缓存
function GetAdvertRedDotReaded()
	--print("GetAdvertRedDotReaded:");
	local readed_cache = getkv("advert_red_dot") or {};

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
			setkv("advert_red_dot", readed_cache);
		end
	end

	--print("end:");
	--print(readed_cache);
	return readed_cache;
end


function AdvertFrame_OnHide()
	--重置按钮排序
	ns_advert.show_index = 0

	if  SetSlidingFrameState then
		SetSlidingFrameState(true);
	end

	if  ClientCurGame:isInGame() then
		if not getglobal("AdvertFrame"):IsRehide() then
		   ClientCurGame:setOperateUI(false);
		end
	end
end


function AdvertFrame_OnEvent()
end


function AdvertFrame_OnUpdate()
	--auto_refresh_xml( "ui/mobile/advert.xml" );
end


---------------------------------------------------------------------------
function OpenMarketActivityFrame()
	ActivityMainCtrl:Active(ActivityMainCtrl.def.type.welfare,false)
end

function OpenActivityFrame()
	ActivityMainCtrl:Active(ActivityMainCtrl.def.type.activity,false)
end

function AdvertCellBtn_OnClick()
	--Log( this:GetName() .. ", id=" .. this:GetClientID() );

	--if  ns_advert.open_cell_id == this:GetClientID() then
	--	ns_advert.open_cell_id = 0;
	--else
	local old_open = ns_advert.open_cell_id;
	ns_advert.open_cell_id = this:GetClientID();
	--end

	--获取对应的ID
	local cell_ads_id = this:GetClientUserData( ns_advert._CELL_ADS_ID_ );
	--Log( "cell_ads_id=" .. cell_ads_id );

	getglobal("AdvertSlideCell" .. this:GetClientID() .. "RedDot"):Hide();
	--红点处理end

	if  ns_advert.open_cell_id ~= old_open then
		ns_td_exposure_click.add( 1403, cell_ads_id )   --公告标题按钮查看点击
	end

	ns_advert.func.updateContent(cell_ads_id, true)

	--内容有变化 曝光日志
	if ns_advert.content_list and ns_advert.content_list.index ~= old_
			and ns_advert.content_list[ ns_advert.content_list.index ]
			and ns_advert.content_list[ ns_advert.content_list.index ].id then
		ns_td_exposure_click.add( 1401, ns_advert.content_list[ ns_advert.content_list.index ].id );
	end

	for i = 1, ns_advert.label_max do
		local ui_check = getglobal("AdvertSlideCell" .. i .. "CheckedBG")
		if i == ns_advert.open_cell_id then
			ui_check:Show()
		else
			ui_check:Hide()
		end
	end

	--
	if IsShowFguiMain() then
		standReportEvent("2", "NOTICE", "Notice1", "click", {standby1=cell_ads_id})
	end
end

function AdvertBtnGoto_OnClick()
	local btn_goto_type = this:GetClientUserData( ns_advert._GOTO_BTN_TYPE_ );
	--Log( this:GetName() .. ", id=" .. this:GetClientID() .. ", btn_type=" .. btn_goto_type );


	local ads_id_ = this:GetClientUserData( ns_advert._CELL_ADS_ID_ );
	if  ads_id_ then
		ns_td_exposure_click.add( 1404, ads_id_ )   --公告右侧跳转点击
	end

	if  btn_goto_type < 80 then    --99 98
		--隐藏公告界面
		ActivityMainCtrl:AntiActive()
	end

	global_jump_ui( btn_goto_type, this:GetClientString() );   --full url or totid=xxx

end


--中间图片按钮
function AdvertPicBtn_OnClick()
	if  ns_advert.content_list and ns_advert.content_list.index  then
		--Log( "call AdvertPicBtn_OnClick, index=" .. ns_advert.content_list.index );

		if ns_advert.content_list[ ns_advert.content_list.index ]
				and ns_advert.content_list[ ns_advert.content_list.index ].pic
				and ns_advert.content_list[ ns_advert.content_list.index ].pic.action then
			if  ns_advert.content_list[ ns_advert.content_list.index ].id then
				ns_td_exposure_click.add( 1402, ns_advert.content_list[ ns_advert.content_list.index ].id )   --大图片点击
			end

			if  ns_advert.content_list[ ns_advert.content_list.index ].pic.action < 90 then  --99 98
				--隐藏公告界面
				ActivityMainCtrl:AntiActive()
			end

			global_jump_ui( ns_advert.content_list[ ns_advert.content_list.index ].pic.action,
					ns_advert.content_list[ ns_advert.content_list.index ].pic.action_url,
					ns_advert.content_list[ ns_advert.content_list.index ].string_code );
		end

	end
end

-----------------------------------逻辑函数部分--------------------

ns_advert.func =         --避免和其他全局函数冲突
{
	updateRedDot = function(isSetReaded)
		ns_advert.has_show_ids = GetAdvertRedDotReaded();
		--print("---advert_red_dot---1>", ns_advert.has_show_ids)
		--print(ns_advert.has_show_ids)

		local show_index = 0;
		for i=1, ns_advert.label_max do
			local cell = getglobal("AdvertSlideCell" .. i);
			local bIsShow = true;

			--print(" i = ", i);
            if ns_advert.content_list then 
				if i <= #ns_advert.content_list then
					--print("has show : ", i)
					for k,v in ipairs(ns_advert.has_show_ids) do
						--print("=====>>>>>>>>", v, ",", cell:GetClientUserData( ns_advert._CELL_ADS_ID_ ), ns_advert._CELL_ADS_ID_, ns_advert.content_list[i].start_time)
						--print("=====>>>>>>>>", cell:GetClientUserData( ns_advert._CELL_ADS_ID_ ) .. '_' .. ns_advert.content_list[i].start_time);
						if v == (cell:GetClientUserData( ns_advert._CELL_ADS_ID_ ) .. '_' .. ns_advert.content_list[i].start_time) then
							-- 该公告已看过，不再显示红点
							--print("hide reddot:");
							getglobal("AdvertSlideCell" .. i .. "RedDot"):Hide();
							bIsShow = false;
							break;
						end
					end

					if bIsShow then
						--根据配置的红点显示的期限设置红点是否显示
						local start_time_ = uu.get_time_stamp(ns_advert.content_list[i].start_time);
						if ns_advert.content_list[i].red_day == -1 or ns_advert.content_list[i].red_day <=0 then
							getglobal("AdvertSlideCell" .. i .. "RedDot"):Hide();
						elseif ns_advert.content_list[i].red_day>0 then

							local red_day_ = ns_advert.content_list[i].red_day*24*60*60 +start_time_
							if red_day_<os.time() then
								getglobal("AdvertSlideCell" .. i .. "RedDot"):Hide();
							end
						end


						if show_index == 0  then
							local id = cell:GetClientUserData( ns_advert._CELL_ADS_ID_ );
							--设置公告红点为已读
							if isSetReaded and ns_advert.content_list[i].no_top == -1 then
								SetAdvertRedDotReaded(id .. '_' .. ns_advert.content_list[i].start_time);
							end

							if ns_advert.content_list[i].no_top == -1 then --根据配置设置按钮是否置顶
								show_index = i;
							end
						end
					end
					cell:SetChecked(false);
					cell:Enable();
				end
			end
		end

		if show_index == 0 then
			show_index = 1;
		end
		local cell_ads_id = getglobal("AdvertSlideCell" .. show_index):GetClientUserData( ns_advert._CELL_ADS_ID_ );
		--ns_advert.func.updateContent(cell_ads_id, true)

		--设置优先展示的公告下标
		ns_advert.show_index = show_index
		if show_index ~= 1 then
			--将显示的公告按钮置顶
			ns_advert.func.updateCellPos();
		end

		--返回优先显示的公告id
		return cell_ads_id
	end,

	updateContent = function(cell_ads_id, isSetChecked)

		--图片内容以及底部内容需要有配置才显示
		getglobal( "AdvertFrameBigPic" ):Hide();
		getglobal( "AdvertFramePicFrame" ):Hide();
		getglobal( "AdvertFrameFixNodeDuration" ):Hide();
		getglobal( "AdvertFrameGotoBtn" ):Hide();
		getglobal("AdvertFramePicBtn"):Hide();

		if ns_advert.content_list == nil then return end
		local old_ = ns_advert.content_list.index
		for i = 1, #ns_advert.content_list do
			local ui_cell = getglobal("AdvertSlideCell" .. i);
			if ns_advert.content_list[i].id == cell_ads_id then
				--红点处理，点击后再也不显示红点
				SetAdvertRedDotReaded(cell_ads_id .. '_' .. ns_advert.content_list[i].start_time);
				--红点处理end

				local plane_y = 0; -- 滑动条的高度
				local content = ns_advert.content_list[i];
				ns_advert.content_list.index = i;

				--图片处理
				local pic_x; -- 图片宽度
				local pic_y;
				if content.pic then
					getglobal( "AdvertFramePicFrame" ):Show();
					getglobal( "AdvertFrameBigPic" ):Show();
					getglobal("AdvertFramePicBtn"):Show();

					print("xxxx:content.pic.file_name = ", content.pic.file_name);
					--print(content.pic);
					local new_name_ = check_http_image_jpg( content.pic.file_name );
					getglobal( "AdvertFrameBigPic" ):ReleaseTexture(new_name_);
					getglobal( "AdvertFrameBigPic" ):SetTexture( new_name_ );

					pic_x = ns_advert.PIC_WIDTH;
					pic_y = getglobal( "AdvertFrameBigPic" ):getRelHeight(); -- 图片高度
					if pic_y <= 4 then
						--未完成下载先隐藏
						print("pic_y <= 4")
						getglobal( "AdvertFramePicFrame" ):Hide();
						--getglobal( "AdvertFrameBigPic" ):Hide();
						--getglobal("AdvertFramePicBtn"):Hide();
					end
					--print("pic_x = ", pic_x, ", pic_y = ", pic_y);
					getglobal( "AdvertFramePicFrame" ):SetSize(pic_x+10, pic_y+10); -- 设置相框大小
					getglobal( "AdvertFrameBigPic" ):SetSize(pic_x, pic_y);
					getglobal("AdvertFramePicBtn"):SetSize(pic_x, pic_y);

					plane_y = pic_y;

					--ui_cell:SetChecked(false);
				end --图片处理end

				--文字处理
				local line_y = 24; -- 一行的高度
				local blocks_len = {};
				if content.texts then
					local texts_num = #content.texts;
					ns_advert.func.create_ui_content(texts_num);
					for j = 1, ns_advert.text_num do
						local ui_block = getglobal("AdvertFrameContentBlock" .. j);
						if j <= texts_num then
							local ui_title = getglobal("AdvertFrameContentBlock" .. j .. "Title");
							local ui_text = getglobal("AdvertFrameContentBlock" .. j .. "Text");
							local text_y = 0; --该文字块的高度
							local has_title = not IsEmptyString(content.texts[j].title);

							if has_title then --暂时兼容旧公告无标题的content
								ui_title:SetText(content.texts[j].title);
								ui_text:SetPoint("topleft", "AdvertFrameContentBlock" .. j .. "Title", "bottomleft", 1, 14);
								ui_title:Show();
								text_y = 24 + 14; --标题的高度 + 标题与内容的距离
							else
								ui_text:SetPoint("topleft", "AdvertFrameContentBlock" .. j, "topleft", 0, 0);
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
					for j = 1, ns_advert.text_num do
						getglobal("AdvertFrameContentBlock" .. j):Hide();
					end
				end --文字处理end

				-- 图文滚动处理
				if plane_y < ns_advert.CONTENT_LIMIT_HEIGHT then
					getglobal("AdvertFrameDetailSliderBoxPlane"):SetSize(758, ns_advert.CONTENT_LIMIT_HEIGHT);
				else
					getglobal("AdvertFrameDetailSliderBoxPlane"):SetSize(758, plane_y+12);
				end

				local y = 0;
				if content.pic then
					getglobal("AdvertFramePicFrame"):SetPoint("topleft", "AdvertFrameDetailSliderBoxPlane", "topleft", 0, 0);
					y = y + pic_y + 5 + 14;
				end
				if #blocks_len > 0 then
					for j = 1, #blocks_len do
						getglobal("AdvertFrameContentBlock" .. j):SetPoint("topleft", "AdvertFrameDetailSliderBoxPlane", "topleft", -1, y);
						y = y + blocks_len[j] + 14;
					end
				end
				getglobal("AdvertFrameDetailSliderBox"):resetOffsetPos(); --重置滚动
				--图文滚动处理end

				-- 活动时间
				if content.duration then
					getglobal( "AdvertFrameFixNodeDuration" ):SetText( content.duration );
					getglobal( "AdvertFrameFixNodeDuration" ):Show();
				else
					getglobal( "AdvertFrameFixNodeDuration" ):Hide();
				end

				-- 跳转按钮
				local ui_goto_btn = getglobal("AdvertFrameGotoBtn");
				local goto_btn = content.goto_btn;
				if goto_btn and goto_btn.can_show then
					ui_goto_btn:SetClientUserData( ns_advert._CELL_ADS_ID_, content.id );
					ui_goto_btn:SetClientUserData( ns_advert._GOTO_BTN_TYPE_, goto_btn.action );
					ui_goto_btn:SetClientString( goto_btn.url_string );

					if goto_btn.action_txt then -- 按钮文字
						getglobal("AdvertFrameGotoBtnText"):SetText(goto_btn.action_txt);
					else
						getglobal("AdvertFrameGotoBtnText"):SetText("立即参加");
					end
					ui_goto_btn:Show();
				else
					ui_goto_btn:Hide();
				end --跳转按钮end

			else
				if isSetChecked then
					ui_cell:SetChecked(false);
				end
			end

		end

	end,

	check_can_show = function( data_, name_ )
		local ret_ = ns_advert.func.__check_can_show( data_, name_ )
		if  not ret_ then
			--Log( "======ma_check_show_conditions_false=====ad====" .. (data_.id or "no_id") .. " / " .. (data_.title or "no_title") )
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
					--Log( "start_time" )
					return false;
				end
			end


			if  data_.end_time then
				local end_time_ = uu.get_time_stamp( data_.end_time );
				if  end_time_ < os.time() then
					--Log( "end_time" )
					return false;
				end
			end

			--其他条件判断 apiids  version  uin等
			if  not ma_check_show_conditions( data_, "ad" ) then
				--Log( "======ma_check_show_conditions_false=====ad====" .. (data_.id or "no_id") .. " / " .. (data_.title or "no_title") )
				return false
			end

			return true;
		end

		--Log( "call advert check_can_show no data_" );
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

		pos = ns_advert.func.reverseFind( ret, '/' );
		if pos then
			ret = string.sub(ret, pos+1);
		end

		--Log( "trim ret=[" .. ret .. "]" );
		return ret;
	end,


	--按照服务器返回的数据刷新UI
	resetMAUI = function()
		--Log("resetMAUI in")
		--逻辑修改为登陆成功后，获取到用户标记数据后才能打开公告
		ReqAdvertUserTag(function (ret)

			if ret == nil or ret[1] == nil then
				print("data is nil")
				ns_advert.user_tag={}
			else
				--设置定向推送的数据
				ns_advert.user_tag = ret[1]
			end
		end)

		-- 以下逻辑跟获取用户标记数据没有关系，没必要等到结果后再执行；
		-- 相反，如果异步等到结果后再执行，与 AdvertFrame_OnShow() 的执行顺序不确定，会导致首次红点显示bug		
			if not ns_advert.content_list then
				ns_advert.func.cleanData()
			end

			--更新内容
			if  ns_advert.content_list and #ns_advert.content_list > 0 then
				local content_list = ns_advert.content_list

				if ns_advert.show_index == 0 then
					ns_advert.func.updateRedDot(false)
				end

				-- 下载图片
				local function downloadPng_cb()
					if ns_advert.content_list and #ns_advert.content_list > 0 then
						local pic_y = getglobal( "AdvertFrameBigPic" ):getRelHeight(); -- 图片高度
						if ns_advert and ns_advert.show_index --[[and pic_y <= 4--]] then -- 这里 ui_texture 默认的empty.png 高度是32, 4太小了，下载完也走不进if里面；这里选择不做高度判断了
							local content = ns_advert.content_list[ns_advert.show_index]
							if content and content.pic then
								local cell_ads_id = getglobal("AdvertSlideCell" .. ns_advert.show_index):GetClientUserData( ns_advert._CELL_ADS_ID_ );
								ns_advert.func.updateContent(cell_ads_id, false)
							end
						end
					end
				end

				--优先下载优先展示的图片
				if ns_advert.show_index ~= 0 then
					local pic = content_list[ns_advert.show_index].pic
					if pic and pic.pic_url then
						--Log("fisrt download :" .. pic.pic_url)
						ns_http.func.downloadPng( pic.pic_url, pic.file_name, pic.check_size, nil, downloadPng_cb);
					end
				end

				for i=1, #content_list do
					if ns_advert.show_index ~= i then
						local pic = content_list[i].pic
						if pic and pic.pic_url then
							ns_http.func.downloadPng( pic.pic_url, pic.file_name, pic.check_size, nil, downloadPng_cb);
							pic.task_id = "ok";                  --已经完成
						end
					end
				end-- 格式化图片数据end

				--左侧按钮
				local high_ = 31; -- start_pos of plane
				for i = 1, ns_advert.label_max do
					if i <= #content_list then
						local title = content_list[i].title or "";
						local ui_title;
						local btn_name = "AdvertSlideCell" .. i;
						getglobal(btn_name):Show();
						getglobal(btn_name):SetClientUserData( ns_advert._CELL_ADS_ID_, content_list[i].id );
						high_ = high_ + ns_advert.CELL_HEIGHT;

						local ui_longText = getglobal("AdvertSlideCell" .. i .. "LongText");
						ui_longText:SetText(title, 55, 54, 49);
						local lines = ui_longText:GetTextLines();
						ui_longText:Hide();

						if lines <= 1 then
							--单行使用居中短标题(FontString)
							ui_title = getglobal("AdvertSlideCell" .. i .. "ShortText");
							ui_title:SetText(title);
						else
							--多行使用左对齐长标题(RichText)
							if lines > 2 then
								getglobal("AdvertSlideCell" .. i):SetSize(224, 107);
								ns_advert.content_list[i].is_long_title = true;
								high_ = high_ + 22; -- 107 - 85
							end
							getglobal("SiftSlideCell" .. i .. "BtShortText"):Hide()
							ui_title = ui_longText;
						end

						ui_title:Show();

						if IsShowFguiMain() then
							standReportEvent("2", "NOTICE", "Notice1", "view", {standby1=content_list[i].id})
						end
					else
						local btn_name = "AdvertSlideCell" .. i;
						getglobal(btn_name):Hide();
					end
				end
				if  high_ < 536 then
					high_ = 536
				end
				getglobal("AdvertFrameContentSliderBoxPlane"):SetSize(246, high_ );
				--左侧按钮end
			end

			--更新位置
			ns_advert.func.updateCellPos();

	end,

	--清洗服务器数据得到有效内容
	cleanData = function()
		Log("cleanData in")
		if  ns_advert.server_config and #ns_advert.server_config >= 2 then

			ns_advert.content_list = { index = 0, };

			-- 格式化文字以及跳转数据
			local ads_raw_ = ns_advert.server_config[2];     --1=图片轮播 2=文字列表
			local ads_ = {};
			for i=1, #ads_raw_ do
				if  ns_advert.func.check_can_show( ads_raw_[i], "right" ) == true then
					table.insert( ads_, ads_raw_[i] );
				end
			end
			--Log( "ads_.size=" .. #ads_ );
			if ads_ and #ads_ > 0 then
				ns_advert.open_cell_id = 0;--默认收缩公告

				for i=1, ns_advert.label_max do
					if i <= #ads_ then

						-- 寻找是否已有图片
						local content = { id = ads_[i].id};
						table.insert(ns_advert.content_list, content);

						--记录开始时间，用于红点
						content.start_time = ads_[i].start_time;

						content.red_day = ads_[i].red_day or -1;  	-- 默认不显示红点 red_day 红点显示的天数
						content.no_top = ads_[i].no_top or -1; 		-- 1:参与置顶排序 -1：不参与置顶排序

						--按钮文字
						content.title = ads_[i].title;

						--goto按钮类型
						local goto_btn = {};
						if  ads_[i].action and ads_[i].action>0 then
							goto_btn.can_show = true;
							goto_btn.action = ads_[i].action;

							if ads_[i].action == 99 or ads_[i].action == 98 or ads_[i].action == 94 or ads_[i].action == 31 or ads_[i].action == 469 or ads_[i].action == 4000 then
								--99=跳url  --98=分享	--31=礼包跳转+礼包id --469 资源工坊 专题id
								local url_ = ads_[i].action_url or "";
								goto_btn.url_string = url_;
							elseif ads_[i].action == 23 or ads_[i].action_button == 25 or ads_[i].action == 121 then
								--23=带帖子ID跳社区   (like xxx=yy&totid=22 )  25=地图详情页
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

					else
						--local btn_name = "AdvertSlideCell" .. i; -- TODO
						--getglobal(btn_name):Hide();
					end
				end

			end --格式化文字以及跳转数据end

			-- 格式化图片数据
			local pics_ = ns_advert.server_config[1];     --1=图片轮播 2=文字列表
			--Log( "pics_.size=" .. #pics_ );
			if pics_ and #pics_ > 0 then
				--准备下载png图片
				for i=1, #pics_ do
					if  ns_advert.func.check_can_show( pics_[i], "pics" ) == true then
						local pic_url;
						local file_name;
						if pics_[i].pic_local then
							pic_url = nil;
							--if IsOverseasVer() then
							--file_name = "ui/mobile/texture/bigtex_comm/"..pics_[i].pic_local; --TODO
							--else
							--	file_name = "overseas_res/english/texture/"..pics_[i].pic_local;
							--end
						elseif  pics_[i].pic2 then
							pic_url   = pics_[i].pic2;
							file_name = g_download_root .. ns_advert.func.trimUrlFile(pics_[i].pic2) .."_";		--加上"_"后缀
						elseif pics_[i].pic then
							pic_url   = g_http_root .. "miniw/ma/" .. pics_[i].pic;
							file_name = g_download_root .. pics_[i].pic .."_";		--加上"_"后缀
						else
							--no pic
						end

						if  #file_name > 3 then
							--if pic_url then
							--	ns_http.func.downloadPng( pic_url, file_name, pics_[i].check_size, nil, downloadPng_cb);
							--end
							--pics_[i].task_id = "ok";                  --已经完成
							local url_ = pics_[i].action_url or "";
							local pic = { pic_url = pic_url,
										  file_name = file_name,
										  check_size = pics_[i].check_size,
										  action = pics_[i].action,
										  action_url = url_ };
							--只有图片id没有与之配对的文字id的公告，就屏蔽掉
							for j = 1, #ns_advert.content_list do
								if pics_[i].id == ns_advert.content_list[j].id then
									ns_advert.content_list[j].pic = pic;
									break;
								end
							end
						end
					end
				end
			end -- 格式化图片数据end

			--for i = 1, #ns_advert.content_list do
			--	print(ns_advert.content_list[i])
			--end

			--更新位置
			ns_advert.func.updateCellPos();
		end
	end,

	--设置条目的宽度和位置
	updateCellPos = function ()

		--Log( "call updateCellPos, open_cell_id=" ..  ns_advert.open_cell_id );
		if not ns_advert.content_list then
			return
		end
		local height = 0; -- start_pos
		local first = ns_advert.show_index or 0
		if first ~= 0 then
			getglobal("AdvertSlideCell" .. first):SetPoint("topleft", "AdvertFrameContentSliderBoxPlane", "topleft", 9, height);
			height = height + ns_advert.CELL_HEIGHT;
			if ns_advert.content_list[first] and ns_advert.content_list[first].is_long_title then
				-- 三行的长标题需要加高标题框
				height = height + 22; -- 标准高度为85，加高后为107，得差22
			end
		end

		for i = 1, ns_advert.label_max do
			if first ~= i then
				local btn_name = "AdvertSlideCell" .. i;

				getglobal(btn_name):SetPoint("topleft", "AdvertFrameContentSliderBoxPlane", "topleft", 9, height);
				height = height + ns_advert.CELL_HEIGHT;
				if ns_advert.content_list[i] and ns_advert.content_list[i].is_long_title then
					-- 三行的长标题需要加高标题框
					height = height + 22; -- 标准高度为85，加高后为107，得差22
				end
			end
		end
	end,

	
	--是否弹窗
	check_pop_advert = function()
		if  ns_advert.server_config and ns_advert.server_config.pop_advert then
			--Log("call check_pop_advert")
			local data_ = ns_advert.server_config.pop_advert
			--print(data_)
			--check time
			local now_ = getServerNow()

			if  check_apiid_ver_conditions( data_ ) then
				--需要显示
				Log("pass check_apiid_ver_conditions")
				if  not ns_advert.pop_advert_data then
				ns_advert.pop_advert_data = getkv( "data", "pop_ads", 101 ) or { t=0, cc=0 }  --101公共uin
				end
				--print(ns_advert.pop_advert_data)
				if  now_ - ns_advert.pop_advert_data.t >= 86400 then
					ns_advert.pop_advert_data.cc = 0
					ns_advert.pop_advert_data.t  = now_
				end

				ns_advert.pop_advert_data.cc = ns_advert.pop_advert_data.cc + 1
				if  ns_advert.pop_advert_data.cc <= data_.count then
					setkv( "data",  ns_advert.pop_advert_data, "pop_ads", 101 )
					return true   --可以显示
				end
				Log("check_pop_advert : count enough")
			end

			return false   --不显示
		end
	end,
	

	--是否弹窗
	check_pop_advert_show = function(cb_)
		--Log("check_pop_advert_show in")
		--每次启动只判断一次
		if  ns_advert.pop_advert_data then
			--Log("pop_advert_data has set, checked, ignore")
			return
		end
	
		--1 新手不弹 ( 首次打开游戏的新手没有pop_ads字段 )
		ns_advert.pop_advert_data = getkv( "data", "pop_ads", 101 )
		if  not ns_advert.pop_advert_data then
			ns_advert.pop_advert_data = { t=0, cc=0 }
			--Log( "call check_pop_advert_show, new player" )
			setkv( "data", ns_advert.pop_advert_data, "pop_ads", 101 )   --新手首次打开
			return
		else
			--Log( "call check_pop_advert_show, old player" )
		end

		--未过配置检测不弹
		if not ns_advert.func.check_pop_advert() then
			return
		end

		--新手引导过程中不弹
		local guideStep = GetGuideStep()
		if guideStep and guideStep >= 0 and guideStep <= 7 then 
			--print("新手引导过程中不弹")
			return 
		end

		if not ns_advert.content_list then
			ns_advert.func.cleanData()
		end
		ns_advert.func.updateRedDot(false)

		--2 下载第一幅图片成功后，才开始弹
		local pic_info_
		if  ns_advert.content_list and #ns_advert.content_list > 0 then
			if ns_advert.show_index ~= 0 then
				pic_info_ = ns_advert.content_list[ns_advert.show_index].pic
			end
		end

		if  pic_info_ then
			--Log( "has pic2, download:" .. pic_info_.pic_url )
			--if  ns_advert.func.check_pop_advert() then
			--	Log( "download start" )
				ns_http.func.downloadPng( pic_info_.pic_url, pic_info_.file_name, pic_info_.check_size, nil, cb_ );
			--else
			--	Log( "download not start, check_pop_advert false" )
			--end
		else
			--Log( "no pic2" )
			--没有图片，直接打开
			if cb_ then
				cb_() 
			end
		end

	end,

	--动态创建文字块UI控件
	create_ui_content = function(num)
		-- 数量已满足则直接返回
		if ns_advert.text_num >= num then
			return
		end
		local type_name = "Frame"
		local template_name = "AdvertContentBlockTemplate"
		local parent_name = "AdvertFrameDetailSliderBox";

		for i = ns_advert.text_num+1, num do
			local name = "AdvertFrameContentBlock" .. i;
			local text = UIFrameMgr:CreateFrameByTemplate(type_name, name, template_name, parent_name);
			--RichText需要先定义Rect，否则接下来的第一次绘制会失败
			getglobal(text:GetName() .. "Text"):SetSize(748, 113)
			getglobal(text:GetName() .. "Text"):resizeRect(748, 748);
			if i == 1 then
				-- 初始化默认对齐于图片，若无图片修改第一个文字块的位置即可
				text:SetPoint("topleft", "AdvertFramePicFrame", "bottomleft", -1, 14);
			else
				text:SetPoint("topleft", "AdvertFrameContentBlock"..i-1, "bottomleft", 0, 14);
			end
			if text then
				text:Hide();
			end
		end

		ns_advert.text_num = num;
	end,

};     --end func

