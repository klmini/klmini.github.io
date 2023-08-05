

-------http------下载文件和访问接口-----


ns_http = {        -- namespace http

	handle = false;
	data = {};     -- 数据段


	lua_task    = {};    -- 普通任务列表
	png_task    = {};    -- 图片的任务列表
	config_task = {};    -- lua config 可缓存配置文件
	xml_task    = {};	 -- xml config 配置文件
	file_task   = {};    -- 任意文件下载的任务列表
	upload_task = {};    -- 文件上传任务

	png_task_queue = {};   --队列

	func        = {};      -- 函数列表
	sec          = "mPPXHwsbc7miniwXUQloSLWvT2017DzIebBc033G",

	std_b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',

	SecurityTypeLow  = 1, --加密类型1
	SecurityTypeHigh = 2, --加密类型2

};



-----------------------------------逻辑函数部分--------------------

-- 网络或者登录失败的时候默认的UIN 12345
function get_default_uin()
	if  isAbroadEvn() then
		return 1013011401
	else
		return   13011401
	end
end

--是否需要过滤default_uin 和网络不好的时候的http请求
function bolContinueReq(user_data,url_)
	local bolReturn = false
	-- if AccountManager:getUin() < 1000 or AccountManager:getUin() == get_default_uin()  then
	-- 	bolReturn = true
	-- end
	-- if user_data and type(user_data) == "table" and user_data.act then
	-- 	if  user_data.act == "get_cf_info" or user_data.act == "inner_account_login" then
	-- 		bolReturn = false
	-- 	end
	-- end
	if  not ifNetworkStateOK() then
		bolReturn = true
	end
	
	return bolReturn
end

--增加URL参数
function url_addParams( url_ )
	js_getUrlParams()
	local uin_   = AccountManager:getUin() or 0;
	if  uin_ < 1000 then
		uin_ = get_default_uin();
	end

	local apiid_ = ClientMgr:getApiId() or "nil"	
	local ver_   = ClientMgr:clientVersionToStr(ClientMgr:clientVersion()) or "nil"
	local lang_  = get_game_lang()    or "nil"
	local cnty_  = get_game_country() or "nil"
	--for minicode
	local channel_id = isEducationalVersion and (ClientMgr.getChannelId and ClientMgr:getChannelId() or 0) or 0;
	local production_id = isEducationalVersion and (ClientMgr.getProductionId and ClientMgr:getProductionId() or 0) or 0;
	--local headInd_ = GetHeadIconIndex() or "nil"


	local long_url_;
	if  string.find( url_, '%?' ) then
		long_url_ = url_ .. '&';
	else
		long_url_ = url_ .. '?';
	end
	long_url_ = long_url_ .. "uin="      .. uin_
	                      .. "&ver="     .. ver_
						  .. (((channel_id > 0) and ("&channel_id="..channel_id)) or "")
						  .. (((production_id > 0) and ("&production_id="..production_id)) or "")	                      
						  .. "&apiid="   .. apiid_
	                      .. "&lang="    .. lang_
						  .. "&country=" .. cnty_
	local params = {
		uin = uin_,
		ver = ver_,
		apiid = apiid_,
		lang =  lang_,
		country =  cnty_,
		channel_id = channel_id > 0 and channel_id or '',
		production_id = production_id > 0 and production_id or '',
	}

	--增加安全
	if  string.sub( long_url_, 1, 1 ) == 's' and string.sub( long_url_, 3, 3 ) == "_" then
		long_url_ =  getUrlSafeInfo( long_url_ );    --增加url安全
	end

	return long_url_, params;
end


function getUrlSafeInfo( url_, uin)
	local type_ = tonumber( string.sub( url_, 2, 2 ) or "0" ) or 0
	
	local ret = string.sub( url_, 4 )	  --去掉 's1_'
	
	-- 增加显示uin传入（登陆拉取配置需要）
	local uin_   = uin and uin or (AccountManager:getUin() or 0);
	print("getUrlSafeInfo type_", type_)
	print("getUrlSafeInfo uin_", uin_)
	if  uin_ < 1000 then
		return ret;      --未能取得帐号信息
	end

	if  string.find( ret, '%?' ) then
		ret = ret .. '&';
	else
		ret = ret .. '?';
	end

	local now_ = getServerNow();
	local s2, s2t = get_login_sign();
	if  type_ == 1 then
		if _G.IsServerBuild and CSOWorld then
			s2, s2t = CSOWorld:getS2(s2, s2t)
		else
			--固定最简验证 s1_
			s2 = '#_php_miniw_2016_#';
		end
		local md5_ = gFunc_getmd5(uin_..s2..now_);
		ret = ret .. 'auth=' .. md5_ .. '&time=' .. now_;
	elseif type_ == 2 then
		--服务器s2  s2_
		local md5_ = gFunc_getmd5(now_..s2..uin_);
		ret = ret .. 'auth=' .. md5_ .. '&time=' .. now_ .. s2t;
	elseif type_ == 3 then
		----服务器s2 + posting  s3_
		local md5_ = gFunc_getmd5(now_..s2..uin_..'posting');
		ret = ret .. 'auth=' .. md5_ .. '&time=' .. now_ .. s2t;
	elseif type_ == 4 then
		--服务器s2 + 昵称  s4_
		local md5_ = gFunc_getmd5(now_..s2..uin_);
		ret = ret .. 'auth=' .. md5_ .. '&time=' .. now_ .. s2t .. "&headIndex=" .. GetHeadIconIndex() .. "&nickname=" .. gFunc_urlEscape(AccountManager:getNickName())
	elseif type_ == 5 then
		----服务器s2 + posting + 昵称  s5_
		local md5_ = gFunc_getmd5(now_..s2..uin_..'posting');
		ret = ret .. 'auth=' .. md5_ .. '&time=' .. now_ .. s2t .. "&nickname=" .. gFunc_urlEscape(AccountManager:getNickName())
	elseif type_ == 6 then
		----服务器s2 + 昵称 + tk验证 s6_
		local md5_ = gFunc_getmd5(now_..s2..uin_);
		ret = ret .. 'auth=' .. md5_ .. '&time=' .. now_ .. s2t .. "&headIndex=" .. GetHeadIconIndex() .. "&nickname=" .. gFunc_urlEscape(AccountManager:getNickName())
		local conn = _G.container.conn
		if conn and conn.token and conn.token ~= "" then
			ret = ret .. "&tk=" ..conn.token
		end
	else
		--s0_ 不加认证
	end

	return ret;

end



--98分享跳转简单参数验证
function url_addParams_share98( url_ )
	local uin_ = AccountManager:getUin() or get_default_uin();
	local long_url_;
	if  string.find( url_, '%?' ) then
		long_url_ = url_ .. '&';
	else
		long_url_ = url_ .. '?';
	end

	local s2, s2t = '', ''
	if _G.IsServerBuild and CSOWorld then
		s2, s2t = CSOWorld:getS2(s2, s2t)
	else
		--固定最简验证 s1_
		s2 = '#_php_miniw_2016_#';
		s2t = getServerNow()
	end

	local auth_ = gFunc_getmd5( uin_ .. s2 .. s2t )
	auth_ = string.sub( auth_, 1, 10 )
	long_url_ = long_url_ .. "uin=" .. uin_ .. "&a=" .. auth_ .. "&t=" .. now_

	return long_url_;
end



--只有999渠道打印日志
function Log999( txt )
	if  ClientMgr:getApiId() == 999 then
		Log(txt);
	end
end

--全局sign
g_login_sign = false;
g_login_s2t  = false;
g_login_pure_s2t = false;
g_login_s2t_last = false;   --最后一次更新s2t时间，用来计算过期


function reset_login_sign()
	Log999( "call reset_login_sign" );
	g_login_sign = false;
	g_login_s2t  = false;
	g_login_pure_s2t = false;
	CSOWorld:setS2("", "");

	get_login_sign()
end


--当服务器没有s2t的时候，再重新获取
function checkS2tAuth()
	Log999( "call checkS2tAuth" )

	if  g_login_s2t and #g_login_s2t>5 and #g_login_pure_s2t > 0 then
		Log999( "s2t ok" );
		return true;
	else
		Log999( "need retry s2t" );
	end

	--也许此时客户端已经拿到了s2t鉴权
	local s2_, s2t_, s2tpure_ = get_login_sign();
	if  s2t_ and #s2t_ > 5 and #s2tpure_ > 0 then
		CSOWorld:setS2(s2_, s2tpure_);
		return true;
	else
		--仍然未能拿到s2t
		if IsStandAloneMode and IsStandAloneMode("") then
		else
			ShowGameTips(GetS(353), 3);
		end
	end

	return false;
end

function login2JoinRoom()
	-- statisticsGameEvent(1820);
	-- getglobal("MiniLobbyFrame"):Show()
	ShowMiniLobby() --mark by hfb for new minilobby
	threadpool:work(function ()
		local count = 5
		while(1) do
			if g_login_sign then -- 等待s2t设置完成
				if getglobal("LoginScreenFrame"):IsShown() then
					getglobal("LoginScreenFrame"):Hide();
				end
				-- statisticsGameEvent(1821)
				t_autojump_service.play_together.LoginRoomServer();
				break;
			elseif count <= 0 then
				HideLoadingIndicator()
				print("kekeke login2JoinRoom login roomserver count == 5")
				break;
			else
				if getglobal("LoginScreenFrame"):IsShown() then
					g_uiroot:get('LoginScreenFrame'):OnClick();
				end
				print("kekeke login2JoinRoom login roomserver g_login_sign == false")
			end
			count = count - 1
			threadpool:wait(1)
		end
	end);
end


function get_login_sign()
	print("g_login_sign", g_login_sign)
	if  g_login_sign then
		if  g_login_s2t_last then
			local inter_ = getServerNow() - g_login_s2t_last
			if  inter_ >= 0 and inter_ < 3600 then
				return g_login_sign, g_login_s2t, g_login_pure_s2t;   --有效期内
			end
		else
			return g_login_sign, g_login_s2t, g_login_pure_s2t;
		end
	end

	if  container and container.conn and container.conn.sign and #container.conn.sign > 10 then
		print("container.conn.sign", tostring(container.conn.sign))
		local s2_all_ = container.conn.sign;
		local pos_ = string.find( s2_all_, '_' );
		if  pos_ then
			local login_sign_ = string.sub( s2_all_, 1, pos_ - 1 );
			local login_s2t_  = string.sub( s2_all_,    pos_ + 1 );
			if  #login_sign_ > 5 and #login_s2t_ > 5 then
				g_login_sign =            login_sign_;
				g_login_s2t  = '&s2t=' .. login_s2t_;
				g_login_pure_s2t = login_s2t_;
				g_login_s2t_last = getServerNow()
				print( "server_name=[" .. g_login_sign .. "] [" .. g_login_s2t .. "] [" .. g_login_pure_s2t .. "]" );
				CSOWorld:setS2(g_login_sign, g_login_pure_s2t);
				return g_login_sign, g_login_s2t, g_login_pure_s2t;
			end
		end
	end

	if _G.IsServerBuild and CSOWorld then
		local s2, s2t = '', ''
		s2, s2t = CSOWorld:getS2(s2, s2t)
		return s2, "&s2t="..s2t,s2t
	else
		return '#_php_miniw_2016_#', '', '';
	end
end


-- function http_getParamMD5(tParam, useServerTime)
-- 	local privateKey = '3dbc5f33add11d1af78ba2af365e0952'
-- 	local md5Keys = {'title','production_id','fee_id','survival','status','taskidx','s2t','buy_times',
-- 	'awardid','nickname','value','item_id','ver','param_num','time','headIndex','itemid','num',
-- 	'auth','type','target','avatarUrl','itemtype','pricetype','ad_id','times','cost','event',
-- 	'ishide','prices_id','skinid','price','op_ret','coin_num','iswarehouse','platform',
-- 	'friend_uin','apiid','id','act','content','fee_type','gift_id','itemnum',
-- 	'encrypt_ver','buy_id','param_id','uin', 'position_id', 'platform_id' }
-- 	table.sort(md5Keys, function (a, b)
-- 		return a < b
-- 	end)

-- 	local tempParam = copy_table(tParam)
-- 	tempParam.time = useServerTime and getServerTime() or os.time()
-- 	local s2, s2t = get_login_sign();
-- 	tempParam.s2t = string.gsub(s2t, '&s2t=', '')
-- 	tempParam.encrypt_ver = 1 -- 加密类型

-- 	local _, morParam = url_addParams('')
-- 	for k, v in pairs(morParam) do
-- 		if v ~= '' then
-- 			tempParam[k] = v
-- 		end
-- 	end

-- 	local md5_table = {}
-- 	for i, v in ipairs(md5Keys) do
-- 		if tempParam[v] then
-- 			table.insert(md5_table, v .. '=' .. tempParam[v])
-- 		end
-- 	end
-- 	local md5Str = table.concat(md5_table, '&')
-- 	local md5 = gFunc_getmd5(md5Str .. privateKey)

-- 	local allParames = {}
-- 	for k, v in pairs(tempParam) do
-- 		table.insert(allParames, k .. '=' .. v)
-- 	end

-- 	local paramStr = table.concat(allParames, '&')
-- 	-- local urlFix = md5Str .. '&md5=' .. md5
-- 	return paramStr , md5
-- end
function http_getParamMD5_roomServer(tParam)
	local privateKey = 'f5711eb1640712de051e5aedc35329c3'
	local md5_key_list = { -- 参与加密的字段
        cmd = 1,
        country = 1,
        lang = 1,
        map_type = 1,
        page = 1,
        page_size = 1,
        s2t = 1,
        time = 1,
		uin = 1,
    }

	local tempParam = copy_table(tParam)
	tempParam.time = getServerTime()
	local s2, s2t = get_login_sign();
	tempParam.s2t = string.gsub(s2t, '&s2t=', '')
	tempParam.encrypt_ver = 2 -- 加密类型

	local _, morParam = url_addParams('')
	for k, v in pairs(morParam) do
		if v ~= '' then
			tempParam[k] = v
		end
	end

	local needEnctyptKey = {}
    for k, _ in pairs(tempParam) do
        if md5_key_list[k] then
            needEnctyptKey[#needEnctyptKey+1] = k
        end
    end
	table.sort(needEnctyptKey, function (a, b)
		return a < b
	end)

	local md5_table = {}
	for i, v in ipairs(needEnctyptKey) do
		if tempParam[v] then
			table.insert(md5_table, v .. '=' .. tempParam[v])
		end
	end
	local md5Str = table.concat(md5_table, '&')
	local md5 = gFunc_getmd5(md5Str .. privateKey)
	
	local allParames = {}
	for k, v in pairs(tempParam) do
		table.insert(allParames, k .. '=' .. v)
	end

	local paramStr = table.concat(allParames, '&')
	-- local urlFix = md5Str .. '&md5=' .. md5
	return paramStr , md5
end


function http_getParamMD5(tParam)
	local privateKey = '3dbc5f33add11d1af78ba2af365e0952'
	local md5_exclude_list = {
        log = 1,
        test = 1,
        json = 1,
        nickname = 1,
        title = 1,
        content = 1,
        md5 = 1,
        auth = 1,
		content_ctx = 1,
    }

	local tempParam = copy_table(tParam)
	tempParam.time = getServerTime()
	local s2, s2t = get_login_sign();

	local function urlEncode(s)
		s = string.gsub(s, "([^%w%.%- _])", function(c) return string.format("%%%02X", string.byte(c)) end)
	   return string.gsub(s, " ", "+")
	end

	--创建局部方法，避免使用时方法未加载出现报错
	local function urlDncode(s)
		s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
		return s
	end

	s2 = urlEncode(s2)
	tempParam.s2 = s2;
	tempParam.s2t = string.gsub(s2t, '&s2t=', '')
	tempParam.encrypt_ver = 3 -- 加密类型

	local _, morParam = url_addParams('')
	for k, v in pairs(morParam) do
		if v ~= '' then
			tempParam[k] = v
		end
	end

    local needEnctyptKey = {}
    for k, _ in pairs(tempParam) do
        if not md5_exclude_list[k] then
            needEnctyptKey[#needEnctyptKey+1] = k
        end
    end
	table.sort(needEnctyptKey, function (a, b)
		return a < b
	end)

	local md5_table = {}
	for i, v in ipairs(needEnctyptKey) do
		if tempParam[v] then
			local decode_parm = urlDncode(tempParam[v])	--防止业务层进行过Encode，所以先decode再Encode
			local encode_parm = urlEncode(decode_parm)
			table.insert(md5_table, v .. '=' .. encode_parm)
		end
	end
	local md5Str = table.concat(md5_table, '&')
	local md5 = gFunc_getmd5(md5Str .. privateKey)
	
	local allParames = {}
	for k, v in pairs(tempParam) do
		if k ~= 's2' then --清除s2防止泄漏
			table.insert(allParames, k .. '=' .. v)	
		end
	end

	local paramStr = table.concat(allParames, '&')
	-- local urlFix = md5Str .. '&md5=' .. md5
	return paramStr , md5
end

--s1=s2(两个函数一样 唯一区别： md5=)
function http_getS1(useServerTime)
	local  s2, s2t = get_login_sign();
	local  now_ = os.time();
	if useServerTime then
		now_ = getServerTime()
	end
	local  uin_ = AccountManager:getUin() or get_default_uin()
	local  md5_ = gFunc_getmd5( now_ .. s2 .. uin_ );
	return 'time=' .. now_ .. '&md5=' .. md5_ .. s2t;
end


--s1=s2(两个函数一样 唯一区别：auth=)
function  http_getS1Map(useServerTime)
	local  s2, s2t = get_login_sign();
	local  now_ = os.time();
	if useServerTime then
		now_ = getServerTime()
	end

	local  uin_ = AccountManager:getUin() or get_default_uin()
	local  md5_ = gFunc_getmd5( now_ .. s2 .. uin_ );
	return 'time=' .. now_ .. '&auth=' .. md5_ .. s2t;
end

--小程序专用
function http_getS1MapWX(useServerTime)
	local  now_ = os.time();
	if useServerTime then
		now_ = getServerTime()
	end

	local  openid_ = AccountManager:getUin() or get_default_uin()
	local  md5_ = gFunc_getmd5( openid_ .. "_wx_" .. now_ );
	return 'time=' .. now_ .. '&auth=' .. md5_ .. "&open_id=" .. openid_;
end

--带act的s2 ( 带 auth + act_ )
function http_getS2Act( act_ , useServerTime)
	local  s2, s2t = get_login_sign();
	local  now_ = os.time();
	if useServerTime then
		now_ = getServerTime()
	end
	
	local  uin_ = AccountManager:getUin() or get_default_uin()
	local  md5_ = gFunc_getmd5( now_ .. s2 .. uin_ .. (act_ or "") );
	return 'time=' .. now_ .. '&auth=' .. md5_ .. s2t;
end

--新手引导专用
function  http_getS1GuardMap(act,useServerTime)
	local  now_ = os.time();
	if useServerTime then
		now_ = getServerTime()
	end
	local  md5_;
	local  newmd5_;
	local  s2, s2t = get_login_sign();
	if act == "ab_test_all" then
		local  uin_ = AccountManager:getUin() or get_default_uin()
		newmd5_ = gFunc_getmd5(now_..s2..uin_);
		return 'time=' .. now_ ..'&uin='..uin_.. '&auth=' .. newmd5_.. s2t;
	elseif act == "ab_test_device_all" then
		md5_ = gFunc_getmd5( ClientMgr:getDeviceID().. now_);
		newmd5_ = gFunc_getmd5(md5_..act.. ClientMgr:getDeviceID());
		return 'time=' .. now_ ..'&device_id='..ClientMgr:getDeviceID().. '&auth=' .. newmd5_;
	end

end

--当玩家上传一段文字内容的时候，计算实名制和手机验证的key
--返回值: "mmsum=498b142258111589268342"
function http_getRealNameMobileSum( content_ )

	local ret_ = "mmsum=nil"

	if  AccountManager.getmmsum then
        local sum_ = AccountManager:getmmsum()  --25cfde8f698c339870778e3fa02d793a111589253639
        --Log( "mmsum=" .. (sum_ or 'nil') )

		if  sum_ == ns_http.mmsum then
			--未变化
        elseif  sum_ and #sum_ >= 40 then
            local t_ = {}
			t_[1] = string.sub( sum_, 1,  32 )  --md5
			t_[2] = string.sub( sum_, 33, 34 )  --flag
			t_[3] = string.sub( sum_, 35 )      --time
            if  t_[3] and #t_[3] >= 10 then
				t_[3] = tonumber( t_[3] ) or 0
				ns_http.mmsum   = sum_
				ns_http.mmsum_t = t_
            end
        end

        if  ns_http.mmsum_t then
            local now_interval_ = getServerNow() - ns_http.mmsum_t[3]
            local server_md5_1_ = string.sub( gFunc_getmd5( ns_http.mmsum_t[1] .. now_interval_ ), 7, 16 )
            local auth_mmsum_   = now_interval_ .. ns_http.mmsum_t[2] .. server_md5_1_ .. ns_http.mmsum_t[3]
            ret_ =  "mmsum=" .. auth_mmsum_
        end

	end

	---对内容加密，可选
	if  content_ and g_login_pure_s2t then
		local  content_hash_ = string.sub( gFunc_getmd5( AccountManager:getUin() ..content_ .. g_login_pure_s2t ), 7, 16 )
		ret_ = ret_ .. "&cthash=" .. content_hash_
	end

	return ret_
end


--是否没有网络
function ifNetworkStateOK()
	local stat_ = 1
	if  ClientMgr and ClientMgr.getNetworkState  then
		stat_ = ClientMgr:getNetworkState()
	end

	if gIsSingleGame then
		stat_ = 0
	end
	return (stat_ ~= 0)
end


function is_https_url (url_)  --"https:"
	local header_ = string.lower( string.sub( url_, 1,  6 ) )
	--Log( "header_=[" .. header_ .. "]" )
	return ( header_ == "https:" )
end

--js网页获取URL参数
function js_getUrlParams()
	local uin_   = AccountManager:getUin() or 0;
	if  uin_ < 1000 then
		uin_ = get_default_uin();
	end
	local ver_   = ClientMgr:clientVersionToStr(ClientMgr:clientVersion()) or "nil"
	local apiid_ = ClientMgr:getApiId() or "nil"
	local lang_  = get_game_lang()    or "nil"
	local cnty_  = get_game_country() or "nil"
	local headInd_ = GetHeadIconIndex() or "nil"

	local  s2, _, s2t = get_login_sign();
	local  now_ = os.time();
	local  uin_ = AccountManager:getUin() or get_default_uin()
	local  md5_ = gFunc_getmd5( now_ .. s2 .. uin_ );
	local  nickname_ = gFunc_urlEscape(AccountManager:getNickName())

	--安卓平台的特殊处理，多保存s2值
	if Android and Android:IsAndroidChannel(apiid_) then
		if SdkManager.setUrlAuth then
			local urlParams = {
				uin = uin_,
				ver = ver_,
				apiid = apiid_,
				lang  = lang_,
				country = cnty_,
				auth = md5_,
				time  = now_,
				s2 = s2,
				s2t   = s2t,
				headeIndex = headInd_,
				nickname = nickname_,
			}
			local params = JSON:encode(urlParams)
			SdkManager:setUrlAuth(params)
			return;
		end
	end

	local urlParams_ = {
		uin = uin_,
		ver = ver_,
		apiid = apiid_,
		lang  = lang_,
		country = cnty_,
		auth = md5_,
		time  = now_,
		s2t   = s2t,
		headeIndex = headInd_,
		nickname = nickname_,
	}
	local params = JSON:encode(urlParams_)
	return params or "";

end

ns_http.func =
{

	--需要至少注册一个event handle
	set_event_handle = function( handle_, force_ )
		if ns_http.handle and force_ ~= true then
			Log( "http event handle has set" );
		else
			handle_:RegisterEvent("GE_HTTP_DOWNLOAD_PROGRESS");
			ns_http.handle = handle_;
		end
	end,


	-- rpc 远程异步调用   返回的回调中，ret是lua table (具体用法搜一下 ns_http.func.rpc 的例子 ）
	-- 参数1： url_       标准http请求协议：  http://www.req.com/miniw/?a=xxx&b=yyy&uin=get_default_uin()
	-- 参数2： callback_  异步回调函数：      function callback( ret ) end;   ret 是 lua table
	-- 参数3： user_data_ 任意回传对象：      这个对象会被原样回传给回调函数，可以为nil
	-- 参数4： pri_       优先级信道： 0=普通 1=协议 2=热更新 3=大文件  [兼容false=0 true=1]
	-- 参数5： sec_       是否加密 (true or 1)=普通第一版本加密 2=第二版本加密
	-- 参数6： bNoAddParam  是否需要加上额外的参数
	rpc = function( url_, callback_, user_data_, pri_, sec_, bNoAddParam)
		if bolContinueReq(user_data_,url_) then
			if callback_ then callback_() end
			do return end
		end

		if  type(pri_) ~= 'number' then
			pri_ = pri_ and 1 or 0 --[兼容false=0 true=1]
		end

		local long_url_ = bNoAddParam and url_ or url_addParams(url_)
		if sec_ == nil or sec_ == false then  --协议默认要加密
			sec_ = ns_http.SecurityTypeHigh
		end
		local task_ = {
			url       = long_url_;
			callback  = callback_;
			time      = os.time();
			user_data = user_data_;
			id        = 0;
		};
		print("rpc......",long_url_)
		if  sec_ == ns_http.SecurityTypeHigh then
			long_url_ = ns_http_sec.encodeS7Url_V2( long_url_ )
			print("rpc encode......", long_url_)
		elseif sec_ then
			long_url_ = ns_http_sec.encodeS7Url( long_url_ )
			print("rpc encode......", long_url_)
		else
			Log("rpc_without_s7t=" .. long_url_ )
		end

		if  is_https_url(url_) then
			task_.id = HttpDownloader:downloadHttpFileHttps( long_url_, nil, nil, nil, pri_ );
		else
			task_.id = HttpDownloader:downloadHttpFile( long_url_, nil, nil, nil, pri_ );   --只有一个参数或者第二个参数为空，表示不写文件，直接下载到内存
		end

		if task_.id > 0 then
			ns_http.lua_task [ task_.id ] =  task_;
		end
	end,


	-- rpc 远程异步调用  用法与上面的rpc一致，返回的回调中，ret是string
	-- sec 无用 但现有调用有很多已经传了该参数，请勿修改
	rpc_string = function( url_, callback_, user_data_, pri_, sec_, bNoAddParam)
		if  not ifNetworkStateOK() then
			if callback_ then callback_() end
			do return end
		end

		if  type(pri_) ~= 'number' then
			pri_ = pri_ and 1 or 0 --[兼容false=0 true=1]
		end

		local long_url_ = bNoAddParam and url_ or url_addParams(url_)
		local task_ = {
			url       = long_url_;
			callback  = callback_;
			time      = os.time();
			user_data = user_data_;
			id        = 0;
			ret_type  = "string";
		};

		if  sec_ == ns_http.SecurityTypeHigh then
			long_url_ = ns_http_sec.encodeS7Url_V2( long_url_ );
			print("rpc encode......", long_url_)
		elseif  sec_ then
			long_url_ = ns_http_sec.encodeS7Url( long_url_ );
			print("rpc encode......", long_url_)
		else
			Log("rpc_without_s7t=" .. long_url_ )
		end

		if  is_https_url(url_) then
			task_.id = HttpDownloader:downloadHttpFileHttps( long_url_, nil, nil, nil, pri_ );   --只有一个参数或者第二个参数为空，表示不写文件，直接下载到内存
		else
			task_.id = HttpDownloader:downloadHttpFile( long_url_, nil, nil, nil, pri_ );   --只有一个参数或者第二个参数为空，表示不写文件，直接下载到内存
		end

		if  task_.id > 0 then
			ns_http.lua_task [ task_.id ] =  task_;
		end
	end,

	--商业化接口加密 ,因rpc_string方法很多地方调用传入了5个参数,所有重写改方法
	-- rpc 远程异步调用  用法与上面的rpc一致，返回的回调中，ret是string
	rpc_string_business = function( url_, callback_, user_data_, pri_)
		if bolContinueReq(user_data_,url_) then
			if callback_ then callback_() end
			do return end
		end

		if  type(pri_) ~= 'number' then
			pri_ = pri_ and 1 or 0 --[兼容false=0 true=1]
		end

		local long_url_ = url_
		local task_ = {
			url       = long_url_;
			callback  = callback_;
			time      = os.time();
			user_data = user_data_;
			id        = 0;
			ret_type  = "string";
		};

		if  is_https_url(url_) then
			task_.id = HttpDownloader:downloadHttpFileHttps( long_url_, nil, nil, nil, pri_ );   --只有一个参数或者第二个参数为空，表示不写文件，直接下载到内存
		else
			task_.id = HttpDownloader:downloadHttpFile( long_url_, nil, nil, nil, pri_ );   --只有一个参数或者第二个参数为空，表示不写文件，直接下载到内存
		end

		if  task_.id > 0 then
			ns_http.lua_task [ task_.id ] =  task_;
		end
	end,

	-- rpc 远程异步调用  用法与上面的rpc一致，不会自动添加uin、apiid等额外参数
	rpc_string_raw = function( url_, callback_, user_data_, pri_ )
		local indexLogin = string.find(url_, "act=inner_account_login")
		if indexLogin and indexLogin >0 then
			user_data_ = {}
			user_data_.act = "inner_account_login"
		end
		if bolContinueReq(user_data_,url_) then
			if callback_ then callback_() end
			do return end
		end

		if  type(pri_) ~= 'number' then
			pri_ = pri_ and 1 or 0 --[兼容false=0 true=1]
		end

		local task_ = {
			url       = url_;
			callback  = callback_;
			time      = os.time();
			user_data = user_data_;
			id        = 0;
			ret_type  = "string";
		};

		if  is_https_url(url_) then
			task_.id = HttpDownloader:downloadHttpFileHttps( url_, nil, nil, nil, pri_ );
		else
			task_.id = HttpDownloader:downloadHttpFile( url_, nil, nil, nil, pri_ );   --只有一个参数或者第二个参数为空，表示不写文件，直接下载到内存
		end

		if task_.id > 0 then
			ns_http.lua_task [ task_.id ] =  task_;
		end
	end,

	-- rpc 远程异步调用  用法与上面的rpc一致，不会自动添加uin、apiid等额外参数,同时增加一个加密功能，
	-- ps 为什么不扩展上面的rpc_string_raw函数的参数，因为第五个参数有被使用，哪怕它并没有第五个参数
	-- 参数5： sec_       是否加密 (true or 1)=普通第一版本加密 2=第二版本加密 ( 参考rpc接口 )
	-- 参数6: nosec_ 是否不加密 部分接口不能使用默认加密添加参数
	rpc_string_raw_ex = function( url_, callback_, user_data_, pri_ , sec_ ,nosec_)
		if bolContinueReq(user_data_,url_) then
			if callback_ then callback_() end
			do return end
		end

		if  type(pri_) ~= 'number' then
			pri_ = pri_ and 1 or 0 --[兼容false=0 true=1]
		end

		if sec_ == nil or sec_ == false then  --协议默认要加密
			sec_ = ns_http.SecurityTypeHigh
		end
		if nosec_ then
			sec_ = nil
		end

		local task_ = {
			url       = url_;
			callback  = callback_;
			time      = os.time();
			user_data = user_data_;
			id        = 0;
			ret_type  = "string";
		};

		if  sec_ == ns_http.SecurityTypeHigh then
			url_ = ns_http_sec.encodeS7Url_V2( url_ );
			print("rpc encode......", url_)
		elseif  sec_ then
			url_ = ns_http_sec.encodeS7Url( url_ );
			print("rpc encode......", url_)
		else
			Log("rpc_without_s7t=" .. url_ )
		end

		if  is_https_url(url_) then
			task_.id = HttpDownloader:downloadHttpFileHttps( url_, nil, nil, nil, pri_ );
		else
			task_.id = HttpDownloader:downloadHttpFile( url_, nil, nil, nil, pri_ );   --只有一个参数或者第二个参数为空，表示不写文件，直接下载到内存
		end

		if task_.id > 0 then
			ns_http.lua_task [ task_.id ] =  task_;
		end
	end,


	-- rpc 远程异步调用  用法与上面的rpc一致，不会自动添加uin、apiid等额外参数
	rpc_string_raw_https = function( url_, callback_, user_data_, pri_, post_, header_, ca_path_ )
		if bolContinueReq(user_data_,url_) then
			if callback_ then callback_() end
			do return end
		end

		if  type(pri_) ~= 'number' then
			pri_ = pri_ and 1 or 0 --[兼容false=0 true=1]
		end

		local task_ = {
			url       = url_;
			callback  = callback_;
			time      = os.time();
			user_data = user_data_;
			id        = 0;
			ret_type  = "string";
		};

		--只有一个参数或者第二个参数为空，表示不写文件，直接下载到内存
		task_.id = HttpDownloader:downloadHttpFileHttps( url_, nil, nil, nil, pri_, post_, header_, ca_path_ );

		if  task_.id > 0 then
			ns_http.lua_task [ task_.id ] =  task_;
		end
	end,

		-- rpc 远程异步调用  用法与上面的rpc一致，不会自动添加uin、apiid等额外参数
		rpc_do_async_http_post = function( url_, callback_, user_data_, post_, header_)

			if  not ifNetworkStateOK() then
				if callback_ then callback_() end
				do return end
			end
	
			if  type(pri_) ~= 'number' then
				pri_ = pri_ and 1 or 0 --[兼容false=0 true=1]
			end
	
			local task_ = {
				url       = url_;
				callback  = callback_;
				time      = os.time();
				user_data = user_data_;
				id        = 0;
				ret_type  = "string";
			};
	
			--只有一个参数或者第二个参数为空，表示不写文件，直接下载到内存
			--task_.id = HttpDownloader:httpPost( url_, post_, nil, user_data_, header_, setHttps_);
			task_.id = HttpDownloader:AsyncHttpClientPost( url_, post_, user_data_, header_);

            if  task_.id > 0 then
                ns_http.lua_task [ task_.id ] =  task_;
            end
		end,

		-- rpc 远程异步调用  用法与上面的rpc一致，不会自动添加uin、apiid等额外参数
		-- user_data_不传入c++接口中，仅存在于lua中
		rpc_do_async_http_post2 = function( url_, callback_, user_data_, post_, header_)

			if  not ifNetworkStateOK() then
				if callback_ then callback_() end
				do return end
			end

			if  type(pri_) ~= 'number' then
				pri_ = pri_ and 1 or 0 --[兼容false=0 true=1]
			end

			local task_ = {
				url       = url_;
				callback  = callback_;
				time      = os.time();
				user_data = user_data_;
				id        = 0;
				ret_type  = "string";
			};

			task_.id = HttpDownloader:AsyncHttpClientPost( url_, post_, nil, header_);

            if  task_.id > 0 then
                ns_http.lua_task [ task_.id ] =  task_;
            end
		end,

	-- rpc 远程异步调用  用法与上面的rpc一致，不会自动添加uin、apiid等额外参数
	rpc_do_http_post = function( url_, callback_, user_data_, post_, header_ )

		if  not ifNetworkStateOK() then
			if callback_ then callback_() end
			do return end
		end

		if  type(pri_) ~= 'number' then
			pri_ = pri_ and 1 or 0 --[兼容false=0 true=1]
		end

		local task_ = {
			url       = url_;
			callback  = callback_;
			time      = os.time();
			user_data = user_data_;
			id        = 0;
			ret_type  = "string";
		};

		--只有一个参数或者第二个参数为空，表示不写文件，直接下载到内存
		task_.id = HttpDownloader:httpPost( url_, post_, nil, user_data_, header_);

		if  task_.id > 0 then
			ns_http.lua_task [ task_.id ] =  task_;
		end
	end,

	t_downloadingLuaBeginTime = {},  --下载的文件记录开始下载的时间
	clearDwnloadingLuaBeginTime = function(url_, originalurl_) --清除记录
		if originalurl_ and ns_http.func.t_downloadingLuaBeginTime[originalurl_] then
			ns_http.func.t_downloadingLuaBeginTime[originalurl_] = nil
		elseif ns_http.func.t_downloadingLuaBeginTime[url_] then
			ns_http.func.t_downloadingLuaBeginTime[url_] = nil
		end
	end,
	-- 下载 xxx.lua config 并对比md5   --is_cdn_ 是否是走ma类的专用cdn
	-- url_ http://operate.mini1.cn:8080/miniw/ma/version.lua 
	-- file_name_ data/http/ma/version.lua
	-- md5_  99ed31f7d58dd8e5
	downloadLuaConfig = function ( url_, file_name_, md5_, callback_, is_cdn_ )
		if ns_http.func.t_downloadingLuaBeginTime[url_] and getServerTime() - ns_http.func.t_downloadingLuaBeginTime[url_] < 10 then --有正在下载的同样的任务且时间间隔小于10秒了，丢弃此次下载
			return
		end

		if  not ifNetworkStateOK() then
			if callback_ then callback_() end
			do return end
		end

		md5_ = md5_ or "";
		-- 先判断本地是否已经有cache文件
		if  gFunc_isStdioFileExist(file_name_) then
			local check_md5_ = string.sub( gFunc_getSmallFileMd5(file_name_, ns_http.sec), 1, #md5_ );
			print( "check_md5_config for " .. file_name_ .. ": ".. check_md5_ .. " / " .. md5_ );
			if  check_md5_ and #check_md5_ > 10 then
				if  check_md5_ == md5_ then
					print( "find cache, md5 match, file=" .. file_name_ );
					if  callback_ then
						local ret_table_ = safe_string2table( gFunc_getSmallFileTxt( file_name_, ns_http.sec ) );
						callback_( ret_table_ );
					end
					do return end;
				else
					print( "file md5 no match, file=" .. file_name_ .. ", " .. check_md5_ .. " / " .. md5_ );
				end
			else
				--need download
			end

			gFunc_deleteStdioFile( file_name_ );  --清理旧文件
		end

		ns_http.func.t_downloadingLuaBeginTime[url_] = getServerTime() --记录开始下载的时间

		--先判断cdn下载，失败再回源
		if  is_cdn_ == "cdn" and #md5_>0 and ns_data.cf_md5s and ns_data.cf_md5s.cdn then
			print("cdn down", ns_data.cf_md5s,ns_data.cf_md5s.cdn)
			local function cb_func_( ret_ )
				if  ret_ then
					print( "==cdn下载成功: " .. file_name_ )
					callback_( ret_ )
				else
					--2 下载失败，重新从源站拉取
					print( "==cdn下载失败: " .. file_name_ )
					ns_http.func.private_cb_downloadLuaConfig( url_, file_name_, md5_, callback_, url_)
				end
			end
			--1 使用cdn拉取
			local cdn_url = ns_data.cf_md5s.cdn .. md5_
			ns_http.func.private_cb_downloadLuaConfig( cdn_url, file_name_, md5_, cb_func_, url_ )
		else
			--1 源站拉取
			ns_http.func.private_cb_downloadLuaConfig( url_, file_name_, md5_, callback_, url_ )
		end

	end,


	--【不要在代码调用这个函数】 私有回调
	private_cb_downloadLuaConfig = function ( url_, file_name_, md5_, callback_, originalurl_)
		local task_ = {
			url         	= url_;
			file_name   	= file_name_;
			md5         	= md5_;
			callback    	= callback_;
			time        	= os.time();
			id          	= 0;
			originalurl_ 	= originalurl_;
		};
		if  is_https_url(url_) then
			task_.id = HttpDownloader:downloadHttpFileHttps( url_, file_name_, ns_http.sec );
		else
			task_.id = HttpDownloader:downloadHttpFile( url_, file_name_, ns_http.sec );
		end
		if  task_.id > 0 then
			ns_http.config_task [ task_.id ] =  task_;
		end
	end,


	-- 下载 png, 下载完成后直接替换
	downloadPng = function ( url_, file_name_, check_size_, global_name_, callback_ )
		Log("downloadPng: "..url_..", "..file_name_);

		if not url_ or url_=="" or not file_name_ or file_name_=="" then
			return --下载地址或者文件名为空就不往下执行了 code_by:huangfubin
		end

		if  file_name_ then
			--检测是否是 png_ png会存到玩家相册中
			if  'png' == getFileExt( file_name_ ) then
				Log("try to download and write a png file. name=" .. file_name_ )
				Log( debug.traceback() )
				assert(0)
			end
		end

		if  not ifNetworkStateOK() then
			if callback_ then callback_() end
			do return end
		end

		local task_ = {
			url         = url_;
			file_name   = file_name_;
			check_size  = check_size_;
			global_name = global_name_;
			png_cb      = callback_;
		}

		task_.callback = function()
			if  #ns_http.png_task_queue > 0 then
				local tmp_ = ns_http.png_task_queue[1];
				if  tmp_  and tmp_.png_cb then
					if tmp_.global_name then
						tmp_.png_cb(tmp_.global_name);
					else
						tmp_.png_cb();
					end
				end
				table.remove(ns_http.png_task_queue, 1);
			end

			Log( "private_do_next_png finish one, size=" .. #ns_http.png_task_queue );
			ns_http.func.private_do_next_png();
		end

		table.insert( ns_http.png_task_queue, task_ );
		ns_http.func.private_do_next_png();
	end,


	--下载 xxx.xml Config文件
	downloadXmlConfig = function ( url_, file_name_, callback_ )

		if  not ifNetworkStateOK() then
			if callback_ then callback_() end
			do return end
		end

		if  gFunc_isStdioFileExist(file_name_) then
			gFunc_deleteStdioFile( file_name_ );  --清理旧文件
		end
		local task_ = {
			url      = url_;
			callback  = callback_;
			file_name   = file_name_;
			time     = os.time();
			id       = 0;
		};

		if  is_https_url(url_) then
			task_.id = HttpDownloader:downloadHttpFileHttps( url_ , file_name_, ns_http.sec);
		else
			task_.id = HttpDownloader:downloadHttpFile( url_ , file_name_, ns_http.sec);
		end

		if task_.id > 0 then
			ns_http.xml_task [ task_.id ] =  task_;
		end
	end,


	-- 下载任意文件, 用md5检验cache
	-- 回调函数可以接受两个参数：1.user_data_ 原样传回  2.errcode：nil=本地md5验证OK 0=下载成功，非0=出错为错误码
	-- progress_callback_ 进度条数字回调
	downloadFile = function ( url_, file_name_, check_md5_, callback_, user_data_, progress_callback_,sec_ )

		if  not ifNetworkStateOK() then
			if callback_ then callback_() end
			do return end
		end

		--Log("downloadFile: "..url_..", "..file_name_);

		if  file_name_ then
			--检测是否是 png_ png会存到玩家相册中
			if  'png' == getFileExt( file_name_ ) then
				Log("try to download and write a png file. name=" .. file_name_ )
				Log( debug.traceback() )
				assert(0)
			end
		end

		--先判断本地是否已经有cache
		if gFunc_isStdioFileExist(file_name_) then
			if check_md5_ then
				local file_md5 = gFunc_getSmallFileMd5(file_name_);
				if check_md5_ == file_md5 then
					Log("downloadFile: md5 match");
					callback_(user_data_);  --md5 match, succeed
					return nil;
				else
					Log("ERROR: downloadFile: md5 not match! need redownload");
				end
			else
				Log("downloadFile: file exist");
				callback_(user_data_);  --not check md5, succeed
				return nil;
			end

			print("downloadFile gFunc_deleteStdioFile", file_name_)
			gFunc_deleteStdioFile(file_name_);  --清理旧文件
		end

		--文件使用中有可能删除失败 直接返回不在下载
		if gFunc_isStdioFileExist(file_name_) then
			print("downloadFile delete error", file_name_)
			return nil;
		end
		if sec_ and  sec_ == ns_http.SecurityTypeHigh then
			url_ = ns_http_sec.encodeS7Url_V2( url_ )
			print("rpc encode url_......", url_)
		end
		local task_ = {
			url         = url_;
			file_name   = file_name_;
			user_data   = user_data_;
			callback    = callback_;
			md5         = check_md5_;
			progress_callback = progress_callback_;
			time        = os.time();
			id          = 0;
		};

		if  is_https_url(url_) then
			task_.id = HttpDownloader:downloadHttpFileHttps(url_, file_name_);
		else
			task_.id = HttpDownloader:downloadHttpFile(url_, file_name_);
		end

		if  task_.id > 0 then
			ns_http.file_task [ task_.id ] =  task_;
		end

		return task_.id;
	end,


	--处理下载事件
	handleHttpDownloadprogress = function()
		local ge = GameEventQue:getCurEvent();
		if  ge.body.httpprogress.progress == 100  then
			Log( "download taskid=" .. ge.body.httpprogress.task_id .. ", progress 100" );
			local task_id = ge.body.httpprogress.task_id;

			if     ns_http.lua_task[ task_id ] then    			--lua下载任务

				if  HttpDownloader:getHttpContentSize( task_id ) > 0 then
					local content = HttpDownloader:getHttpContentStr( task_id );
					Log( "content size====" .. HttpDownloader:getHttpContentSize( task_id ) );

					local ret;
					if  ns_http.lua_task[ task_id ].ret_type and ns_http.lua_task[ task_id ].ret_type == "string" then
						--ret = safe_string2table( content );
						ret = content;
						Log( ret );
					else
						ret = safe_string2table( content );
					end

					local user_data = ns_http.lua_task[ task_id ].user_data;

					if  ns_http.lua_task[ task_id ].callback  then
						Log( "call lua_task callback" );
						ns_http.lua_task[ task_id ].callback(ret, user_data);
					end

				end

				ns_http.lua_task[ task_id ] = nil;    --clear task;

			elseif ns_http.config_task[ task_id ] then         --lua config文件下载
				local write_file_path = HttpDownloader:getFileName( task_id );
				Log( "download one config ok. name=" .. ns_http.config_task [ task_id ].file_name .. ", path=" .. write_file_path );

				local ret_table_ = safe_string2table( gFunc_getSmallFileTxt( ns_http.config_task [ task_id ].file_name, ns_http.sec ) );
				if  ns_http.config_task[ task_id ].callback  then
					ns_http.config_task[ task_id ].callback(ret_table_);
				end

				ns_http.func.clearDwnloadingLuaBeginTime(ns_http.config_task[ task_id ].url, ns_http.config_task[ task_id ].originalurl_) --清除记录
				ns_http.config_task[ task_id ] = nil;    --clear task;

			elseif ns_http.png_task[ task_id ] then            --图片下载任务

				local write_file_path = HttpDownloader:getFileName( task_id );
				Log( "download one png ok. name=" .. ns_http.png_task [ task_id ].file_name .. ", path=" .. write_file_path );

				if  ns_http.png_task [ task_id ].global_name then
					local new_name_ = check_http_image_jpg( ns_http.png_task [ task_id ].file_name );
					getglobal( ns_http.png_task [ task_id ].global_name ):SetTexture( new_name_ );
					--getglobal( ns_ma.png_task_list[ge.body.httpprogress.task_id].frame_name ):SetTexUV( 0, 0, 127, 127 );
				end

				if  ns_http.png_task[ task_id ].callback  then
					ns_http.png_task[ task_id ].callback();
				end

				ns_http.png_task[ task_id ] = nil;    --clear task;

			elseif ns_http.file_task[ task_id ] then            --任意文件下载任务

				local write_file_path = HttpDownloader:getFileName( task_id );
				Log( "download file ok. name=" .. ns_http.file_task [ task_id ].file_name .. ", path=" .. write_file_path );

				if  ns_http.file_task[ task_id ].callback  then
					ns_http.file_task[ task_id ].callback(ns_http.file_task[ task_id ].user_data, 0);
				end

				ns_http.file_task[ task_id ] = nil;    --clear task;

			elseif ns_http.xml_task[ task_id ] then		--xml config 文件下载
				local write_file_path = HttpDownloader:getFileName( task_id );
				Log( "download one xml ok. name=" .. ns_http.xml_task [ task_id ].file_name .. ", path=" .. write_file_path );

				if  ns_http.xml_task[ task_id ].callback  then
					local configText = gFunc_getSmallFileTxt( ns_http.xml_task [ task_id ].file_name, ns_http.sec )
					Log( "download one xml DownLoadXmlConfigResult. configText="..configText );
					ns_http.xml_task[ task_id ].callback(configText);
				end
			else
				Log( "download unknow, task_id=" .. ge.body.httpprogress.task_id );
			end


			if  false then  		--打印出所有正在下载的任务
				for k, v in pairs( ns_http.lua_task ) do
					Log( "exist task =" .. k );
				end

				for k, v in pairs( ns_http.png_task ) do
					Log( "exist task =" .. k );
				end

				for k, v in pairs( ns_http.file_task ) do
					Log( "exist task =" .. k );
				end
			end

		elseif ge.body.httpprogress.progress < 0 then
			--任务出错
			local task_id = ge.body.httpprogress.task_id;


	--lua_task    = {};    -- 普通任务列表
	--png_task    = {};    -- 图片的任务列表
	--config_task = {};    -- lua config 可缓存配置文件
	--xml_task    = {};	 -- xml config 配置文件
	--file_task   = {};    -- 任意文件下载的任务列表
	--upload_task = {};    -- 文件上传任务


			if  ns_http.file_task[ task_id ] then               --任意文件下载任务
				lua_http_error_report( "download", ge.body.httpprogress.progress,
					ns_http.file_task[ task_id ].url, ns_http.file_task[ task_id ].file_name )

				local write_file_path = HttpDownloader:getFileName( task_id );
				Log( "download file failed. name=" .. ns_http.file_task [ task_id ].file_name .. ", path=" .. write_file_path );
				--出错时必须删除下载的文件
				gFunc_deleteStdioFile(ns_http.file_task[ task_id ].file_name);
				local errcode = ge.body.httpprogress.progress;
				if  ns_http.file_task[ task_id ].callback  then
					ns_http.file_task[ task_id ].callback(ns_http.file_task[ task_id ].user_data, errcode);
				end
				ns_http.file_task[ task_id ] = nil;    --clear task;
			elseif  ns_http.lua_task[ task_id ] then    		--lua下载任务
				--会引起无限循环 rpc_string 不能调用 lua_http_error_report
				if  ns_http.lua_task[ task_id ].callback  then
					ns_http.lua_task[ task_id ].callback(nil, ns_http.lua_task[ task_id ].user_data);
				end
				ns_http.lua_task[ task_id ] = nil;    --clear task;
			elseif  ns_http.config_task[ task_id ] then         --lua config文件下载

				lua_http_error_report( "download", ge.body.httpprogress.progress,
					ns_http.config_task[ task_id ].url, ns_http.config_task[ task_id ].file_name )

				if  ns_http.config_task[ task_id ].callback  then
					ns_http.config_task[ task_id ].callback();
				end
				ns_http.func.clearDwnloadingLuaBeginTime(ns_http.config_task[ task_id ].url, ns_http.config_task[ task_id ].originalurl_) --清除记录
				ns_http.config_task[ task_id ] = nil;    --clear task;
			elseif  ns_http.png_task[ task_id ] then            --图片下载任务

				lua_http_error_report( "download", ge.body.httpprogress.progress,
					ns_http.png_task[ task_id ].url, ns_http.png_task[ task_id ].file_name )

				if  ns_http.png_task[ task_id ].callback  then
					ns_http.png_task[ task_id ].callback();
				end
				ns_http.png_task[ task_id ] = nil;    --clear task;
			elseif  ns_http.xml_task[ task_id ] then		--xml config 文件下载

				lua_http_error_report( "download", ge.body.httpprogress.progress,
					ns_http.xml_task[ task_id ].url, ns_http.xml_task[ task_id ].file_name )

				if  ns_http.xml_task[ task_id ].callback  then
					ns_http.xml_task[ task_id ].callback();
				end
				ns_http.xml_task[ task_id ] = nil;    --clear task;
			else
				Log( "download unknow, task_id=" .. ge.body.httpprogress.task_id );
			end


		else
			--任务正在下载中
			--Log( "downloading taskid=" .. ge.body.httpprogress.task_id .. ", progress2=" .. ge.body.httpprogress.progress );

			local task_id = ge.body.httpprogress.task_id;

			if  ns_http.file_task[ task_id ] then           --任意文件下载任务
				if  ns_http.file_task[ task_id ].progress_callback  then
					Log( "downloading file taskid=" .. ge.body.httpprogress.task_id .. ", progress=" .. ge.body.httpprogress.progress );
					ns_http.file_task[ task_id ].progress_callback( ge.body.httpprogress.progress );
				end

			elseif  ns_http.png_task[ task_id ] then        --图片下载任务
				if  ns_http.png_task[ task_id ].progress_callback  then
					Log( "downloading png taskid=" .. ge.body.httpprogress.task_id .. ", progress=" .. ge.body.httpprogress.progress );
					ns_http.png_task[ task_id ].progress_callback( ge.body.httpprogress.progress );
				end

			else
				--Log( "downloading unknow, task_id=" .. ge.body.httpprogress.task_id .. ", progress2=" .. ge.body.httpprogress.progress );
			end

		end

	end,


	-----------------------------------------------------
	--上传文件事件
	handleHttpUploadFileProgress = function()
		Log( "call handleHttpUploadFileProgress" );
		local ge = GameEventQue:getCurEvent();

		if  ge.body.httpprogress.progress == 100  then
			Log( "upload taskid=" .. ge.body.httpprogress.task_id .. ", progress=" .. ge.body.httpprogress.progress );

			local task_id = ge.body.httpprogress.task_id;
			if  ns_http.upload_task[ task_id ] then   --是否有这个任务
				local code_ =  HttpFileUpDownMgr:getTaskRespCode( task_id );
				if code_ == 200 then   --200ok
					local string_ =  HttpFileUpDownMgr:getTaskRespString( task_id );
					Log( "string=" .. (string_ or "nil" ) );
					if  ns_http.upload_task[ task_id ].callback  then
						ns_http.upload_task[ task_id ].callback( code_ , string_, ns_http.upload_task[ task_id ].user_data);
					end

				end

			else
				Log( "ERROR: upload task not find=" .. task_id );
			end

			ns_http.upload_task[ task_id ] = nil;    --clear task;
		else
			--任务正在中
			local task_id = ge.body.httpprogress.task_id;
			if  ns_http.upload_task[ task_id ] then   --是否有这个任务

				if  ge.body.httpprogress.progress < 0 then
					lua_http_error_report( "upload", ge.body.httpprogress.progress,
						ns_http.upload_task[ task_id ].url, ns_http.upload_task[ task_id ].file_name )
				end

				if  ns_http.upload_task[ task_id ].callback  then
					ns_http.upload_task[ task_id ].callback( ge.body.httpprogress.progress, "progress", ns_http.upload_task[ task_id ].user_data);
				end

			else
				Log( "ERROR: upload task not find=" .. task_id );
			end

		end

		--显示日志
		for k, v in pairs( ns_http.upload_task ) do
			Log( "exist task =" .. k );
		end

	end,

	--上传文件到md5服务器pre
	upload_md5_file_pre = function( cb_ )
		--pre 获得下载地址
		local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
			local url_ = g_http_root_map .. 'miniw/profile?act=upload_pre_photo' .. addUploadNodeInfo() .. "&" .. http_getS1Map();
			Log( url_ );
			ns_http.func.rpc_string( url_, cb_ );
		else
			Log( "water can not get uin_=" .. (uin_ or "nil") );
			ns_http.func.tipsNoUin();
		end
	end,

	--开始上传文件
	upload_md5_file = function( fpath_, url_, cb_ , user_data_)
		if  gFunc_getStdioFileSize(fpath_)  <= 0 then
			Log( "file size error." );
			return 0;
		end

		local task_ = {
			url         = url_;
			file_name   = fpath_;
			user_data   = user_data_;
			callback    = cb_;
			time        = os.time();
			id          = 0;
		};
		task_.id = HttpFileUpDownMgr:uploadFile( url_, fpath_ );
		if  task_.id > 0 then
			ns_http.upload_task [ task_.id ] =  task_;
		end

		return task_.id;
	end,

	upload_md5_absolute_file = function( fpath_, url_, cb_ , user_data_)
		if  gFunc_getAbsoluteStdioFileSize(fpath_)  <= 0 then
			Log( "file size error." );
			return 0;
		end

		local task_ = {
			url         = url_;
			file_name   = fpath_;
			user_data   = user_data_;
			callback    = cb_;
			time        = os.time();
			id          = 0;
		};
		task_.id = HttpFileUpDownMgr:uploadFile( url_, fpath_ , true);
		if  task_.id > 0 then
			ns_http.upload_task [ task_.id ] =  task_;
		end

		return task_.id;
	end,

	--设置上传结果 - 头像
	set_user_profile_head = function( file_path_, token_, cb_ )
		local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
			local md5_ = gFunc_getBigFileMd5(file_path_);
			Log( "md5_=" .. md5_ );
			local ext_ = getFileExt( file_path_ );
			local url_ = g_http_root_map .. 'miniw/profile?act=set_usr_header&' .. token_
			                             .. "&md5=" .. md5_ .. "&ext=" .. ext_ ..  "&" .. http_getS1Map();
			Log( url_ );
			ns_http.func.rpc_string( url_, cb_ );
		else
			Log( "can not get uin_=" .. (uin_ or "nil") );
			ns_http.func.tipsNoUin();
		end
	end,


	--恢复头像
	reset_user_profile_head = function( cb_ )
		local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
			local url_ = g_http_root_map .. 'miniw/profile?act=set_usr_header&del=1&' .. http_getS1Map();
			Log( url_ );
			ns_http.func.rpc_string( url_, cb_ );
		else
			Log( "can not get uin_=" .. (uin_ or "nil") );
			ns_http.func.tipsNoUin();
		end
	end,

	--设置上传结果 - 头像 --为了2.0作用的 在profile header2
	set_user_profile_head2 = function( file_path_, token_, cb_ )
		local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
			local md5_ = gFunc_getBigFileMd5(file_path_);
			Log( "md5_=" .. md5_ );
			local ext_ = getFileExt( file_path_ );
			local url_ = g_http_root_map .. 'miniw/profile?act=set_usr_header2&' .. token_
			                             .. "&md5=" .. md5_ .. "&ext=" .. ext_ ..  "&" .. http_getS1Map();
			Log( url_ );
			ns_http.func.rpc_string( url_, cb_ );
		else
			Log( "can not get uin_=" .. (uin_ or "nil") );
			ns_http.func.tipsNoUin();
		end
	end,

	--拍照模式上传结果
	take_photo_upload = function( file_path_, token_, cb_ )
		local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
			local md5_ = gFunc_getBigFileMd5(file_path_);
			Log( "md5_=" .. md5_ );
			local ext_ = getFileExt( file_path_ );
			local url_ = g_http_root_map .. 'miniw/map?act=upload_pic_ret&' .. token_
			                             .. "&md5=" .. md5_ .. "&ext=" .. ext_ ..  "&" .. http_getS1Map();
			Log( url_ );
			ns_http.func.rpc_string( url_, cb_ );
		else
			Log( "can not get uin_=" .. (uin_ or "nil") );
			ns_http.func.tipsNoUin();
		end
	end,

	--设置上传结果 - 相册
	set_user_profile_photo = function( file_path_, seq_, token_, cb_ )
		local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
			local md5_ = gFunc_getBigFileMd5(file_path_);
			Log( "md5_=" .. md5_ );
			local ext_ = getFileExt( file_path_ );
			local url_ = g_http_root_map .. 'miniw/profile?act=set_usr_photo&' .. token_ .. "&seq=" .. seq_
			                             .. "&md5=" .. md5_ .. "&ext=" .. ext_ ..  "&" .. http_getS1Map();
			Log( url_ );
			ns_http.func.rpc_string( url_, cb_ );
		else
			Log( "can not get uin_=" .. (uin_ or "nil") );
			ns_http.func.tipsNoUin();
		end
	end,

	--设置custom上传结果
	set_user_ar_tex = function(file_path_, seq_, token_, cb_)
		local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
			local md5_ = gFunc_getBigFileMd5(file_path_);
			Log( "md5_=" .. md5_ );
			local url_ = g_http_root_map .. 'miniw/profile?act=set_custom_skin&' .. token_ .. "&seq=" .. seq_
			                             .. "&md5=" .. md5_ ..  "&" .. http_getS1Map();

			if string.find(file_path_, "png_") then
				url_ = url_ .. "&ext=png_";
			else
				url_ = url_ .. "&ext=png";
			end
			Log( "set_user_ar_tex:" .. url_ );
			ns_http.func.rpc_string( url_, cb_ );
		else
			Log( "can not get uin_=" .. (uin_ or "nil") );
			ns_http.func.tipsNoUin();
		end
	end,

	--设置用户图片绑定
	set_user_photo = function( file_path_, act, seq_, token_, cb_ )
		local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
			local md5_ = gFunc_getBigFileMd5(file_path_);
			Log( "md5_=" .. md5_ );
			local url_ = g_http_root_map .. "miniw/profile?act=" .. act .. "&" .. token_ .. "&seq=" .. seq_
			                             .. "&md5=" .. md5_ ..  "&" .. http_getS1Map();

			if string.find(file_path_, "png_") then
				url_ = url_ .. "&ext=png_";
			else
				url_ = url_ .. "&ext=png";
			end
			Log( "set_user_ar_tex:" .. url_ );
			ns_http.func.rpc( url_, cb_, nil, nil, ns_http.SecurityTypeHigh);   --profile
		else
			Log( "can not get uin_=" .. (uin_ or "nil") );
			ns_http.func.tipsNoUin();
		end
	end,

	--删除ar texture
	del_user_ar_tex = function( seq_, cb_ )
		local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
			local url_ = g_http_root_map .. 'miniw/profile?act=set_custom_skin&del=1&seq=' .. seq_ .. "&" .. http_getS1Map();
			Log( url_ );
			ns_http.func.rpc_string( url_, cb_ );
		else
			Log( "can not get uin_=" .. (uin_ or "nil") );
			ns_http.func.tipsNoUin();
		end
	end,

	--删除photo
	del_user_profile_photo = function( seq_, cb_ )
		local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
			local url_ = g_http_root_map .. 'miniw/profile?act=set_usr_photo&del=1&seq=' .. seq_ .. "&" .. http_getS1Map();
			Log( url_ );
			ns_http.func.rpc_string( url_, cb_ );
		else
			Log( "can not get uin_=" .. (uin_ or "nil") );
			ns_http.func.tipsNoUin();
		end
	end,


	--commom cost接口
	unlockCost = function( action_, cb_ )
		local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
			local url_ = g_http_root_map .. 'miniw/profile?v=2&act=unlock&tp=' .. action_ .. "&" .. http_getS1Map();
			Log( url_ );
			ns_http.func.rpc_string( url_, cb_ );
		else
			Log( "can not get uin_=" .. (uin_ or "nil") );
			ns_http.func.tipsNoUin();
		end
	end,


	--提示无法获得UIN
	tipsNoUin = function()
		ShowGameTips("您还未成功登录游戏，请检查网络是否连接正常。", 3);
	end,


	----------------------------------------------------------------------------------
	--私有函数 继续下一个下载任务
	private_do_next_png = function()
		Log( "private_do_next_png, size=" .. #ns_http.png_task_queue );
		if  #ns_http.png_task_queue > 0 then
			local tmp_ = ns_http.png_task_queue[1];
			local now_ = os.time();
			if  tmp_.begin_time then
				if  now_ - tmp_.begin_time > 15 then
					--超时
					Log( "ERROR png timeout, size=" .. #ns_http.png_task_queue );
					table.remove( ns_http.png_task_queue, 1 );
					ns_http.func.private_do_next_png();
				else
					--任务继续
					do return end
				end
			else
				--开始新任务
				tmp_.begin_time = now_;
				ns_http.func.private_downloadPng( tmp_.url, tmp_.file_name, tmp_.check_size, tmp_.global_name, tmp_.callback );
			end
		end
	end,


	--私有函数 下载png
	private_downloadPng = function ( url_, file_name_, check_size_, global_name_, callback_ )

		--先判断本地是否已经有cache
		if  gFunc_isStdioFileExist(file_name_) then
			local fsize_ = gFunc_getStdioFileSize(file_name_);
			if  check_size_ and check_size_ > 0 then
				if  check_size_ == fsize_ then
					Log( "find cache, size match, pic=" .. file_name_ );
					if  global_name_ then
						getglobal( global_name_ ):SetTexture( file_name_ );
					end
					if  callback_ then
						callback_();
					end
					do return end;
				else
					Log( "file size no match, pic=" .. file_name_ .. ", " .. fsize_ .. " / " .. check_size_ );
				end
			elseif  fsize_ > 0 then
				Log( "find cache pic without check_size=" .. file_name_ );
				if global_name_ then
					getglobal( global_name_ ):SetTexture( file_name_ );
				end
				if  callback_ then
					callback_();
				end
				do return end;
			else
				--need download
			end

			gFunc_deleteStdioFile( file_name_ );  --清理旧文件
		end

		local task_ = {
			url         = url_;
			file_name   = file_name_;
			check_size  = check_size_;
			global_name = global_name_;
			callback    = callback_;
			time        = os.time();
			id          = 0;
		};

		if  is_https_url(url_) then
			task_.id = HttpDownloader:downloadHttpFileHttps( url_, file_name_ );
		else
			task_.id = HttpDownloader:downloadHttpFile( url_, file_name_ );
		end

		if task_.id > 0 then
			ns_http.png_task [ task_.id ] =  task_;
		end

	end,





	url_encode = function(s)
		s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
		return string.gsub(s, " ", "+")
	end,

	url_decode = function(s)
		s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
		return s
	end,


	--编码 not_http_get=1:不做转换 ( GET请求不能含有/和=和+ )
	base64_encode = function(str_, not_http_get )
		local  ret64_ = ns_std_base64.encodeBase64(str_, ns_http.std_b64chars);
		if  not_http_get then
			return ret64_
		else
			ret64_ = string.gsub(ret64_,"+","-")
			ret64_ = string.gsub(ret64_,"/",";")
			ret64_ = string.gsub(ret64_,"=","_")
			return ret64_
		end
	end,

	--解码 not_http_get=1:不做转换 ( GET请求不能含有/和=和+)
	base64_decode = function(str64_, not_http_get)
		--if  not_http_get then
			--return ns_std_base64.decodeBase64(str64_, ns_http.std_b64chars);
		--else
			local s_ = string.gsub(str64_,"-","+")
			      s_ = string.gsub(s_    ,";","/")
				  s_ = string.gsub(s_    ,"_","=")
				  s_ = string.gsub(s_    ," ","+")   --兼容旧数据
			return ns_std_base64.decodeBase64(s_,     ns_http.std_b64chars);
		--end
	end,


};     --end func



-- url get中的特殊字段( "空格 + / ? % # & = ")
-- 标准     +/=  需要转 +/=
-- 自定义   -;=  需要转   =
-- [ + -> - ]   [ / -> ; ] [ = -> _ ]

ns_http_sec = {
	--自定义的base64，与正式版本不一样(不能修改)
	g_myb64chars = 'Vg21WQ5KdRt0yNpc' .. 'r9m4O3PoHaZvsLe' .. 'CY8FjSwiTkUbuEBIJ' .. 'lAG7fqXM6xDnzh-;',   -- +/=

	--url加密
	encodeS7Url = function( url_ )
		local env = get_game_env();
		if  ns_version and (ns_version.s7==0 and (env == 1 or env == 11)) then --测试服可以不加密
			Log( "no s7" );
			return url_;
		else
			-- 默认使用S7加密
			Log( "encodeS7Url=" .. url_ );
		end

		local url_new_ = url_ .. "&s7e=1" ;
		local pos_ = string.find( url_new_, "?" );
		--http://xxxx.com/yyyy?aaaa=bbbb&ccc=dddd
		if  pos_ and pos_ > 10 then
			local u1 = string.sub( url_new_, 1, pos_ );
			local u2 = string.sub( url_new_, pos_+1 );
			--Log( "u1====" .. u1 );
			--Log( "u2====" .. u2 );

			--加密u2
			local u2sec, s7t  = ns_http_sec.getS7( u2 );
			--url_new_  = u1 .. "s7t=" .. s7t .. "&s7=" .. u2sec;
			url_new_  = u1 .. "s7=" .. u2sec .. "&s7t=" .. s7t;
		end
		return url_new_;
	end,


	-- 第二版本加密, 目前支持过网关的微服务: g_http_root g_http_root_map ns_version.proxy_url g_http_root_mail mapservice.getserver()
	-- ! 暂不支持的地址: 地图服和房间服 friendservice.getserver() AccountManager:getRoomServerUrl()
	encodeS7Url_V2 = function( url_ )
		if  ns_http_s7_sec2.init_ok then
			if  ns_version and ns_version.s7_V2 == 1 then
				return ns_http_s7_sec2.private_encodeS7Url_V2( url_ )
			end
		end
		return ns_http_sec.encodeS7Url( url_ )
	end,


	--获得url s7加密
	getS7 = function( s7key )
		local  u2sec = ns_http_sec.ToMyBase64( s7key );
		local  md5 = gFunc_getmd5 ( "s7" .. (u2sec or "") );
		local  s7t = string.sub( md5, 7, 11);
		return u2sec, s7t;
	end,


	ToMyBase64 = function(str_)
		local  ret64_ = ns_std_base64.encodeBase64(str_, ns_http_sec.g_myb64chars);
		if  not not_http_get then
			ret64_ = string.gsub(ret64_,"=","_")
		end
		return ret64_
	end,


	--task数据加密验证
	get_tk_sum = function( content )
		local  md5 = gFunc_getmd5 ( "_tk_" .. (content or "") )
		local  ret = string.sub( md5, 7, 11)
		return ret
	end,

}



---第二版本url加密 ( 业务代码逻辑中不需要使用该类 )
ns_http_s7_sec2 = {
	--自定义的base64，与正式版本不一样(不能修改)
	g_myb64chars4url = 'NpcVg21KdRWQ5t0y'..'sLer9mPoH4O3aZv'..'EBIwiTJCY8FjSkUbu'..'XM6lfqxAG7Dnzh';  --for shuffle
	--g_myb64chars_V2  = { seed='', ver='20', str='', temp={} };

	init_ok = false;   ---是否可用

	init_gate_name = function( seed1_ )
		if  ns_http_s7_sec2.init_ok then
			if  ns_http_s7_sec2.g_myb64chars_V2.seed == seed1_ then
				return   --已经初始化且值未变化
			end
		end

		local ver1_ = string.sub( seed1_, 1, 2 )
		ns_http_s7_sec2.g_myb64chars_V2 = { seed = seed1_,  ver=ver1_, temp={}, }
		local info_ = ns_http_s7_sec2.g_myb64chars_V2

		info_.str = ns_http_s7_sec2.shuffle_base64_string( seed1_ )
		for i=1, 64 do
			info_.temp[ string.sub( info_.str, i, i ) ] = i
		end
		info_.temp[ '_' ] = 0
		info_.temp[ '=' ] = 0

		ns_http_s7_sec2.init_ok = 1  --初始化ok
	end,


	--重新计算加密字符串
	shuffle_base64_string = function( p_seed_ )
		local string_ = ns_http_s7_sec2.g_myb64chars4url
		local tmp_ = {}
		for i=1, #string_ do
			tmp_[ #tmp_ + 1 ] = string.sub( string_, i, i )
		end

		local seed_ = gFunc_getmd5( 'sf' .. p_seed_ )
		for i=1, #seed_, 2 do
			local i1 = ( string.byte( seed_, i )   % #string_) + 1
			local i2 = ( string.byte( seed_, i+1 ) % #string_) + 1
			if  i1 ~= i2 then
				tmp_[i1], tmp_[i2] = tmp_[i2], tmp_[i1]
			end
		end

		local pos_ = 16 + ( string.byte( seed_, 1 ) + string.byte( seed_, 2 ) % 32 )
		local ret_ = table.concat( tmp_ )

		return  ( string.sub( ret_, pos_ ) .. string.sub( ret_, 1, pos_-1 ) .. '-;' )
	end,


	--客户端只需要加密部分
	ToMyBase64_V2 = function( str )
		local b64chars = ns_http_s7_sec2.g_myb64chars_V2.str
		local s64_list = {}
		local b64char
		local index_ = 1

		while #str >= index_ do
			local bytes_num = 0
			local buf = 0

			for _=1,3 do
				buf = (buf * 256)
				if #str >= index_ then
					buf = buf + string.byte(str, index_, index_)
					bytes_num = bytes_num + 1
					index_ = index_ + 1
				end
			end

			for _=1,(bytes_num+1) do
				b64char = math.fmod(math.floor(buf/262144), 64) + 1
				s64_list[ #s64_list + 1 ] = string.sub(b64chars, b64char, b64char)
				buf = buf * 64
			end

			for _=1,(3-bytes_num) do
				s64_list[ #s64_list + 1 ] = '_'
			end
		end
		return table.concat( s64_list )
	end,


	--url加密 new (业务不要直接使用这个函数，使用 ns_http_sec.encodeS7Url_V2 )
	private_encodeS7Url_V2 = function( url_ )
		local url_new_ = url_ .. "&s7e=1" ;
		local pos_ = string.find( url_new_, "?" );
		--http://xxxx.com/yyyy?aaaa=bbbb&ccc=dddd
		if  pos_ and pos_ > 10 then
			local u1 = string.sub( url_new_, 1, pos_ );
			local u2 = string.sub( url_new_, pos_+1 );
			--Log( "u1====" .. u1 );
			--Log( "u2====" .. u2 );

			--加密u2
			local u2sec, s7t  = ns_http_s7_sec2.getS7_V2( u2 );
			--url_new_  = u1 .. "s7t=" .. s7t .. "&s7=" .. u2sec;
			url_new_  = u1 .. "s7=" .. u2sec .. "&s7t=" .. s7t;
		end
		return url_new_;
	end,


	--获得url s7加密
	getS7_V2 = function( s7key )
		local  u2sec = ns_http_s7_sec2.ToMyBase64_V2( s7key );
		local  md5 = gFunc_getmd5 ( "s7" .. (u2sec or "") .. ns_http_s7_sec2.g_myb64chars_V2.seed );
		local  s7t = ns_http_s7_sec2.g_myb64chars_V2.ver .. string.sub( md5, 7, 11);
		return u2sec, s7t;
	end,

}



-- 不要使用这个类，使用 ns_http.func.base64_decode 和 ns_http.func.base64_encode
ns_std_base64 = {

	--标准base64加密
	encodeBase64 = function (str, seq_ )
		if  not str then
			return ""
		elseif #str <= 0 then
			return ""
		end

		local b64chars = seq_
		local s64_list = {}
		local b64char

		local index_ = 1
		while #str >= index_ do
			local bytes_num = 0
			local buf = 0

			for _=1,3 do
				buf = (buf * 256)
				if #str >= index_ then
					buf = buf + string.byte(str, index_, index_)
					bytes_num = bytes_num + 1
					index_ = index_ + 1
				end
			end

			for _=1,(bytes_num+1) do
				b64char = math.fmod(math.floor(buf / 262144), 64) + 1
				s64_list[#s64_list + 1] = string.sub(b64chars, b64char, b64char)
				buf = buf * 64
			end

			for _=1,(3-bytes_num) do
				s64_list[#s64_list + 1] = '='
			end
		end

		return table.concat(s64_list)
	end ,


	--标准base64解密
	decodeBase64 = function (str64, seq)
		if  not str64 then
			return ""
		elseif #str64 <= 0 then
			return ""
		end

		local b64chars = seq
		local temp={}
		for i=1,64 do
			temp[string.sub(b64chars,i,i)] = i
		end
		temp['=']=0
		local str_list = {}
		for i=1,#str64,4 do
			if i>#str64 then
				break
			end
			local data = 0
			local str_count=0
			for j=0,3 do
				local str1=string.sub(str64,i+j,i+j)
				if not temp[str1] then
					return
				end
				if temp[str1] < 1 then
					data = data * 64
				else
					data = data * 64 + temp[str1]-1
					str_count = str_count + 1
				end
			end
			for j=16,0,-8 do
				if str_count > 0 then
					local m_ = math.pow(2, j)
					str_list[#str_list + 1] = string.char(math.floor(data / m_))
					data = data % m_
					str_count = str_count - 1
				end
			end
		end

		local last = tonumber(string.byte(str_list[#str_list]))
		if last == 0 then
			str_list[#str_list] = nil
		end

		return table.concat(str_list)
	end,

}


--检查从http下载的文件(公告 广告) 预留的统一接口
function check_http_image_jpg( filename )
	return filename
end

asy_upload = {
	ErrorCode = {
		OK = 0;
		RPC_PRE_ERROR = 1;	--请求上传位置失败
		UPLOAD_TOKEN_ERROR = 2;
		BIND_ERROR = 3;
		RPC_UPLOAD_ERROR = 4;
	};

	--[[
	path： 图片路径
	bind_act: 图片上传完成后需要绑定的act
	seq：上传图片序号
	]]
	photo = function(self, path, bind_act, seq)
		--1. 请求上传位置
		local _, upload_pre_ret = self:upload_pre("upload_pre_photo");
		if string.sub( upload_pre_ret, 1, 3 ) == "ok:" then
			--2.获取上传地址
			local upload_url =  string.sub( upload_pre_ret, 4 );
			upload_url = string_trim( upload_url );
			upload_url = upload_url .. '&no_conv=1';

			--3.开始上传图片
			local _, upload_ret, upload_token = self:upload_md5_file(path, upload_url);
			--4.上传成功
			if upload_ret then
				if upload_token and  string.sub( upload_token, 1, 3 ) == "ok:" then
					--5.获取文件token
					local sub_token = string.sub( upload_token, 4 );
					sub_token = string_trim( sub_token );

					--6.将图片绑定到用户
					local _, bind_ret = self:set_photo_binduser(path, bind_act, seq, sub_token);
					
					--7.绑定结果
					if bind_ret and bind_ret.ret == 0 then
						return self.ErrorCode.OK, bind_ret;	--成功
					else
						return self.ErrorCode.RPC_UPLOAD_ERROR, bind_ret;	--绑定失败
					end
				else
					return self.ErrorCode.RPC_UULOAD_ERROR, upload_token;	--token 获取失败
				end
			else
				return self.ErrorCode.RPC_UULOAD_ERROR, upload_ret;	--上传失败
			end
		else
			if string.find( upload_pre_ret, "noRealNameMobile" ) then
				if string.find( upload_pre_ret, "00" ) then
					ShowGameTipsWithoutFilter(GetS(22037), 3)
				elseif string.find( upload_pre_ret, "01" ) then
					ShowGameTipsWithoutFilter(GetS(10643), 3)
				elseif string.find( upload_pre_ret, "10" ) then
					ShowGameTipsWithoutFilter(GetS(100218), 3)
				end
			end

			return self.ErrorCode.RPC_PRE_ERROR, upload_pre_ret;	--获取上传位置失败
		end
	end;

	--上传文件前置 先请求上传位置
	upload_pre = function(self, act)
		local upload_pre_url = g_http_root_map .. "miniw/profile?act=" .. act .. 
		"&" .. addUploadNodeInfo() .. 
		"&" .. http_getRealNameMobileSum() .. 
		"&" .. http_getS1Map();
		return http_get_string_with_rpc(upload_pre_url);
	end;

	--上传文件前置 先请求上传位置
	upload_pre2 = function(self, url)
		while not ns_http do threadpool:wait(0) end 
        local timeout = timeout or config and config.timeout or 30
        local seq = gen_gid()    

		ns_http.func.rpc(url, function (ret, token) 
			threadpool:notify(seq, ErrorCode.OK, ret, token) 
		end);
		return threadpool:wait(seq, timeout, tick)
	end;

	--上传文件
	--local rec_seq = {seq , process = 200};
	upload_md5_file = function(self, path, upload_url, timeout, tick)
		while not ns_http do threadpool:wait(0) end 
        timeout = timeout or config and config.timeout or 30
		
		local seq = gen_gid()        
		local function upload_cb_(ret_, token_)
			if token_ == "progress" then
				return
			end

       		if ret_ == 200 then
	        	threadpool:notify(seq, ErrorCode.OK, ret_, token_)
			else
				threadpool:notify(seq, ErrorCode.FAILED, ret_, token_)
	        end
       	end

        ns_http.func.upload_md5_file(path, upload_url, upload_cb_);

 		return threadpool:wait(seq, timeout, tick)
	end;

	--将文件绑定到用户
	set_photo_binduser = function(self, path, act, bindSeq, sub_token)
		while not ns_http do threadpool:wait(0) end 
        timeout = timeout or config and config.timeout or 30

        local seq = gen_gid()
        ns_http.func.set_user_photo(path, act, bindSeq, sub_token, function (ret, token) threadpool:notify(seq, ErrorCode.OK, ret, token) end);
 		return threadpool:wait(seq, timeout, tick)
	end;
}

--http请求校验时间错误的提示, 目前商业化业务的请求才用到
function TipsByHttpTimeCheckError(ret)
	if ret == 9999 then
		ShowGameTipsWithoutFilter(GetS(70456))
		return true;
	end

	return false
end

---@return string 加入md5签名后的url
function getUrlSafeInfoWithSortMd5(url, key, post_)
    return Md5Sgin:GetMd5ByStringParam(url, key, post_)
end

-- rpc 远程异步调用  用法与上面的rpc一致，不会自动添加uin、apiid等额外参数
ns_http.func.rpc_sort_md5_do_post = function( url_, callback_, key, post_, bNoAddParam, user_data_, pri_, sec_, header_, setHttps_)

    if  not ifNetworkStateOK() then
        if callback_ then callback_() end
        do return end
    end

    if  type(pri_) ~= 'number' then
        pri_ = pri_ and 1 or 0 --[兼容false=0 true=1]
    end

    print("rpc_sort_md5_do_post url is", url_)
    local long_url_ = bNoAddParam and url_ or url_addParams(url_)
    local timestamp = getServerTime() or os.time()
    if bNoAddParam then
        long_url_ = long_url_ .. "?timestamp=" .. timestamp
    else
        long_url_ = long_url_ .. "&timestamp=" .. timestamp
    end    
    local safeInfoStr = getUrlSafeInfoWithSortMd5(long_url_, key, post_)

    local task_ = {
        url       = url_;
        callback  = callback_;
        time      = os.time();
        user_data = user_data_;
        id        = 0;
        ret_type  = "string";
    };
    long_url_ = long_url_ .. "&sign=" ..  safeInfoStr
    print("rpc......",long_url_)
    if  sec_ then
        long_url_ = ns_http_sec.encodeS7Url( long_url_ );
        print("rpc encode......", long_url_)
    else
        Log("rpc_without_s7t=" .. long_url_ )
    end

    --只有一个参数或者第二个参数为空，表示不写文件，直接下载到内存
    task_.id = HttpDownloader:httpPost( long_url_, post_, nil, user_data_, header_, setHttps_);

	if task_.id > 0 then
		ns_http.lua_task [ task_.id ] =  task_;
	end

end

--获取公共的请求参数pure_s2t,cur_time,token
function GetCommonReqParams()
	local s2_, s2t_, pure_s2t = get_login_sign()
	local src_uin = AccountManager:getUin()
	local cur_time = getServerTime()
	local token = gFunc_getmd5("" .. cur_time .. s2_ .. src_uin)
	return pure_s2t,cur_time,token
end