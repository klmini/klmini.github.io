-- Optimizing Declaration
-- lua tables
local string = _G.string;
-- lua functions
local tostring = _G.tostring;
-- C++ class
-- local ClientMgr = _G.ClientMgr;
-- local SnapshotForShare = _G.SnapshotForShare;
-- local AccountManager = _G.AccountManager;
-- miniworld tables
-- miniworld functions
local getglobal = _G.getglobal;
local check_apiid_ver_conditions = _G.check_apiid_ver_conditions;
local ShowGameTips = _G.ShowGameTips;
local GetS = _G.GetS;
local IsAndroidBlockark = _G.IsAndroidBlockark;
local IsIosPlatform = _G.IsIosPlatform;
local IsProtectMode = _G.IsProtectMode;
local Log = _G.Log;
local print = _G.print;

t_share_data = {
	platformName = {},
	--{{{ 每次分享时调用 SetShareData 同时刷新以下值
	imgPath = nil,
	url = nil,
	title = nil,
	text = nil,
	--}}}

	--{{{埋点预设数据
	shareScene = nil,		-- 分享场景
	shareModelId = "",		-- 分享皮肤、角色、坐骑的id
	--}}}

	--{{{ 地图分享时作者的信息
	worldName = "",
	authorNmae = "",
	authorUin = "",
	thumb_md5 = "",
	--}}}
	MAX_PLATFORM_COUNT = 9,

	--{{{游戏内分享
	m_tShareParams ={},

	--分享后回调
	shareCallback = nil,

	-- 游戏内分享类型
	ShareType = {
		TEXT=0,
		MAP=1,
		SKIN=2,
		RIDE=3,
		ROLE=4,
		AVATAR=5,
		SCREENSHOT =6,
		BATTLE_VICTORY=7,
		BATTLE_FAILURE=8,
		URL=9,
		ACHIEVE = 10,
		CHAMELEON = 11,
		WEAPON = 12,
		GREATEWALL_GUARD = 13,
		DOULUO_TEAM = 14,
		WRRKEND_CARNIVAL = 15,
	},
	---}}}
}

function t_share_data:GetShareTypeConstants()
	return self.SHARE_TYPE;
end

function t_share_data:SetMiniShareParameters(tShareParams, RewardDisplay)
	self.m_tShareParams = tShareParams;
	self.m_clsRewardDisplay = RewardDisplay;
	tShareParams.nickname = AccountManager:getNickName();
end

function t_share_data:GetMiniShareParameters()
	return self.m_tShareParams;
end

function t_share_data:ReshowRewardDisplay()
	local print, Log = Android:Localize(Android.SITUATION.QRCODE_SCANNER);
	print("ReshowRewardDisplay(): ");
	local RewardDisplay = self.m_clsRewardDisplay
	if RewardDisplay and DecoratorUtils:hasInner(RewardDisplay) then
		RewardDisplay:show();
		self.m_clsRewardDisplay = nil
	end
end

function t_share_data:ShowNextRewardDisplay()
	local print, Log = Android:Localize(Android.SITUATION.QRCODE_SCANNER);
	print("ShowNextRewardDisplay(): ");
	local RewardDisplay = self.m_clsRewardDisplay
	print("ShowNextRewardDisplay(): RewardDisplay = ", RewardDisplay);
	if RewardDisplay then
		RewardDisplay:onConfirm();
		self.m_clsRewardDisplay = nil
	end
end

local m_szShareType = nil;
local m_nShareId = nil;
function QQShareResult(result)
	Log("QQShareResult:"..result);
	if result == 0 then	--分享成功
		if m_szShareType then
			Log("QQShareResult m_szShareType:"..m_szShareType);
			if m_szShareType == 'ride' then
				WWW_ma_qq_member_action('nil', 'qq_member_share_ride', m_nShareId, ns_ma.func.download_callback_empty);
			elseif m_szShareType == 'skin' then
				WWW_ma_qq_member_action('nil', 'qq_member_share_skin', m_nShareId, ns_ma.func.download_callback_empty);
			elseif m_szShareType == 'chameleon' then
				WWW_ma_qq_member_action('nil', 'qq_member_share_skin', m_nShareId, ns_ma.func.download_callback_empty);
			elseif m_szShareType == 'role' then
				WWW_ma_qq_member_action('nil', 'qq_member_share_role', m_nShareId, ns_ma.func.download_callback_empty);
			elseif m_szShareType == 'map' then
				WWW_ma_qq_member_action('nil', 'qq_member_share_map', m_nShareId, ns_ma.func.download_callback_empty);
			elseif m_szShareType == 'battle' then
				WWW_ma_qq_member_action('nil', 'qq_member_share_battle', m_nShareId, ns_ma.func.download_callback_empty);
			elseif m_szShareType == 'weapon' then
				WWW_ma_qq_member_action('nil', 'qq_member_share_weapon', m_nShareId, ns_ma.func.download_callback_empty);
			end
		end
	end 
end

-- 为原先的shareSDK加个开关：四个开关组合
function GetSharePlatformJsonStr(bShareToMiniFriends)
	if bShareToMiniFriends == nil then bShareToMiniFriends = false end
	ns_version.qq_share = ns_version.qq_share or {}
	
	-- facebook share for blockark
	local t_shareEnable = {minifriends=bShareToMiniFriends, wxfriends=false, wx=false, qq=false, qzone=false, facebook=not IsProtectMode()}
	if check_apiid_ver_conditions(ns_version.qq_share.wxfriends) then
		t_shareEnable.wxfriends = true
	end
	if check_apiid_ver_conditions(ns_version.qq_share.wx) then
		t_shareEnable.wx = true
	end
	if check_apiid_ver_conditions(ns_version.qq_share.qq) then
		t_shareEnable.qq = true
	end
	if check_apiid_ver_conditions(ns_version.qq_share.qzone) then
		t_shareEnable.qzone = true
	end
	-- local jsonStr = JSON:encode(t_extendData)
	local jsonStr = JSON:encode(t_shareEnable)
	return jsonStr
end

--info_str 自定义字段
function SaveShareParams()
	local str;	
	str = ClientMgr:getVersionParamStrNoCheck("shareUrlIcon", (info_str or GetS(3600)));
	SnapshotForShare:setParam(SHARE_SHAREURLICON, str);

	str = ClientMgr:getVersionParamStrNoCheck("wechatUrlTitle", (info_str or GetS(3601)));
	SnapshotForShare:setParam(SHARE_WECHATURLTITLE, str);

	str = ClientMgr:getVersionParamStrNoCheck("wechatUrlText", (info_str or GetS(3602)));
	SnapshotForShare:setParam(SHARE_WECHATURLTEXT, str);

	str = ClientMgr:getVersionParamStrNoCheck("qqUrlTitle", (info_str or GetS(3603)));
	SnapshotForShare:setParam(SHARE_QQURLTITLE, str);

	str = ClientMgr:getVersionParamStrNoCheck("qqUrlText", (info_str or GetS(3604)));
	SnapshotForShare:setParam(SHARE_QQURLTEXT, str);

	str = ClientMgr:getVersionParamStrNoCheck("sinaUrlTitle", (info_str or GetS(3605)));
	SnapshotForShare:setParam(SHARE_SINAURLTITLE, str);

	-- str = ClientMgr:getVersionParamStrNoCheck("googleplusUrlTitle", (info_str or GetS(3601)));
	-- SnapshotForShare:setParam(SHARE_GOOGLEPLUSURLTITLE, str);

	str = ClientMgr:getVersionParamStrNoCheck("googleplusUrlText", (info_str or GetS(3602)));
	SnapshotForShare:setParam(SHARE_GOOGLEPLUSURLTEXT, str);

	str = ClientMgr:getVersionParamStrNoCheck("facebookUrlText", (info_str or GetS(3602)));
	SnapshotForShare:setParam(SHARE_FACEBOOKURLTEXT, str);

	str = ClientMgr:getVersionParamStrNoCheck("twitterUrlText", (info_str or GetS(3602)));
	SnapshotForShare:setParam(SHARE_TWITTERURLTEXT, str);	
end

function GetDefaultShareUrl()
	return (IsAndroidBlockark() or IsIosPlatform()) and GetBaseShareUrl() .. "&type=_m" or "";
end

function GetBaseShareUrl()
	return "http://www.miniworldgame.com/openMiniWorld.html?l=" .. get_game_lang_str();
end

function _G.MiniwShare(imgPath, url, title, content)
	--[[
		参考一下两种形式，不能同时分享图片和链接
		MiniwShare(imgPath, "", ...)
		MiniwShare("", url, ...)
	]]
	if title == nil then title = "" end
	if content == nil then content = "" end
	
	SetShareData(imgPath, url, title, content)

	getglobal("ShareOnOptionMenuFrame"):Show();

	--if (ClientMgr.isPC and ClientMgr:isPC()) or (false and IsAndroidBlockark() and IsProtectMode()) then
	--	getglobal("MiniWorksShareMapFrame"):Show();
	--else
	--	getglobal("ShareOnOptionMenuFrame"):Show();
	--end
end

function MiniwShareEx(filepath, callback_Failed, callback_ShareToQQ)
	local snapshotPath = ClientMgr:getDataDir()..filepath
	if SnapshotForShare:saveSnapshot(filepath) then
		Log("ShareOnGetItem: saveSnapshot succeed, path = "..snapshotPath);
		
		ShareToDynamic:SetPicName(filepath);  --设置动态分享的文件名

		if not IsShouQChannel(ClientMgr:getApiId()) then
			if IsAndroidBlockark() then
				MiniwShare(snapshotPath, t_share_data.url, t_share_data.title, t_share_data.text);
			else
				MiniwShare(snapshotPath, "");	
			end	
		else
			if callback_ShareToQQ then
				callback_ShareToQQ()
			end
			SdkManager:shareToQQ(snapshotPath, t_share_data.url, t_share_data.title, t_share_data.text);
		end
	else
		Log("ShareOnGetItem: saveSnapshot failed, path = "..snapshotPath);
		if callback_Failed then
			callback_Failed()
		end
	end
end

function StartShareOnGetItem(type, id, url, title, content)
	if false and IsAndroidBlockark() and IsProtectMode() then 
		ShowGameTips(GetS(4842), 3);
		return
	end
	check_ma_share("item_" .. type);
	m_szShareType = type;
	m_nShareId = id;
	if IsAndroidBlockark() or IsIosPlatform() then 
		t_share_data.url = url or "";
	else
		t_share_data.url = "";
	end
	t_share_data.text =  content and content or GetS(1504);

	getglobal("ShareOnGetItem"):Show();
end

local m_nSnapshotType = -1;
local m_nSnapshotSerialNumber = -1;
function StartShareOnScreenshot(type, id, snapshotType, url, title, content)
	if false and IsAndroidBlockark() and IsProtectMode() then 
		ShowGameTips(GetS(4842), 3);
		return
	end
	check_ma_share("screenshot_" .. type);
	m_szShareType = type;
	m_nShareId = id;
	t_share_data.url = (IsAndroidBlockark() or IsIosPlatform()) and url or "";
	t_share_data.title = title and title or "";
	t_share_data.text = content and content or GetS(1505);
	m_nSnapshotType = snapshotType and snapshotType or 2;

	getglobal("ShareOnScreenshot"):Show();

	--if  ClientMgr.isPC and  ClientMgr:isPC() then
	--	MiniwShare("", "");
	--else
	--	getglobal("ShareOnScreenshot"):Show();
	--end
end

function StartShareUrl(url, stringId)
	if false and IsAndroidBlockark() and IsProtectMode() then 
		ShowGameTips(GetS(4842), 3);
		return
	end
	check_ma_share("url");
	if bShareToMiniFriends == nil then bShareToMiniFriends = false end
	local str = nil;
	if  stringId then
		str = GetS(stringId);
	else
		str = GetS(4767)
	end
	
	SaveShareParams();
	MiniwShare("", url, str);
end

local ShareActivityFrame = nil
local ShareActivityFramePic = nil
local isShareActivityClick = false
function StartShareActivity()
	
	local imgpath = ""
	local url = "http://10.0.8.119:8080/?type=open_minibeans"
	local title = "分享即送迷你豆，快来一起薅羊毛啊！"
	local content = "我在玩超好玩的沙盒游戏《迷你世界》，快来一起创造新地图吧！"
		
	isShareActivityClick = false

	getglobal("ShareActivityFrameAuthorName"):SetText("@"..GetS(1254, AccountManager:getNickName(), GetMyUin()))

	if not ShareActivityFrame or not ShareActivityFramePic then
		ShareActivityFrame = getglobal("ShareActivityFrame")
		ShareActivityFramePic = getglobal("ShareActivityFramePic")
	end
	local weekday = os.date("%w", AccountManager:getSvrTime());
	if weekday == 0 then
		weekday = 7
	end
	local picKey = "picture" .. weekday
	local picPath = "ui/mobile/texture2/bigtex/shengli.png"
	if ns_shop_config2.share_cfg[picKey] then
		local filePath = g_download_root .. "activityPic_" .. ns_advert.func.trimUrlFile(ns_shop_config2.share_cfg[picKey])
		gFunc_isStdioFileExist(filePath)
		picPath = filePath
	end
	ShareActivityFramePic:SetTexture(picPath)
	ShareActivityFrame:Show()
	SetSnapshottypeValue(0)
	SnapshotForShare:requestSaveSnapshot()
	local filepath = "SnapshotForShare"..".png"
	if gFunc_isStdioFileExist(filepath) then
		gFunc_deleteStdioFile(filepath)
	end

	local i = 1
	while i < 10 do
		if SnapshotForShare:isSnapshotFinished() then
			print("ShareIconBtnTemplate_OnClick MiniwShareEx ", filepath)
			-- MiniwShareEx(filepath)
			MiniwShare(imgpath, url, title, content);
			return
		end
		i = i + 1
		threadpool:wait(0.1)
	end
	ShareActivityFrame:Hide()
end

function ShareActivityFrame_OnShow()
end

function ShareActivityFrame_OnHide()
	local filepath = g_download_root .. "activity_share_tmp.png"
	if gFunc_isStdioFileExist(filepath) then
		gFunc_deleteStdioFile(filepath)
	end
	--isShareActivityClick = true;
	print("NotifyShareOrWatchAD  Share",isShareActivityClick);
	if isShareActivityClick then
		--请求完成分享
		isShareActivityClick = false
		-- cctodo 告诉服务器分享完成
		--local temp_url = g_http_root .. "miniw/php_cmd?act=set_share_wni_bean_data&" .. http_getS1()
		--ns_http.func.rpc(temp_url, nil, nil, nil, true)

		NotifyShareOrWatchAD(1);
	end
end

-- 迷你工坊地图分享（参数：地图table）
function StartMiniworksMapShare(map)
	if false and IsAndroidBlockark() and IsProtectMode() then 
		ShowGameTips(GetS(4842), 3);
		return
	end

	local map = MiniWorksMapShare_CurrentMap;
	local worldDesc = AccountManager:findWorldDesc(map.owid);
	local imgPath = ClientMgr:getDataDir() .. "data/http/thumbs/" .. map.download_thumb_md5 .. ".png_";
	local url = "http://www.miniworldgame.com/openMiniWorld.html?type=m&i=" .. tostring(map.owid);
	local title = "";
	local connoisseurCount = tonumber(map.push_up3);
	local content = "";
	if  connoisseurCount > 0 then 
		content = GetS(1501, map.name, map.download_count, map.push_up3);
	else
		content = GetS(1500, map.name, map.download_count);
	end
	connoisseurCount = nil;

	MiniwShare(imgPath, url, title, content);
end

function OnSnapshotForShareFinished()
	local print = Android:Localize(Android.SITUATION.CHANNEL);
	print("OnSnapshotForShareFinished(): m_nSnapshotType = ", m_nSnapshotType);
	local getglobal = getglobal;
	ClientMgr:setClickEffectEnabled(true);

	if m_nSnapshotType == 2 then
		if not ClientMgr:isPC() then
			getglobal("UIHideFrameExitBtn"):Show();
			getglobal("UIHideFrameScreenshotBtn"):Show();
		end

	elseif m_nSnapshotType == 3 then
		--getglobal("ActivityFrameZhishuShare"):Hide();
		getglobal("ActivityFrameZhishuShareBtn"):Show();
		getglobal("ActivityFrameZhishuShareCloseBtn"):Show();
	elseif m_nSnapshotType == 4 then
		ARStoreFrameBottomHideBtn_OnClick();
		getglobal("ARStoreFrameBottom"):Show();
	elseif m_nSnapshotType == 100 then
		--LLDO:保存账号密码截图
		local fileName = "./data/" .. "MiniPassword" .. ".png";
		if m_nSnapshotSerialNumber > 0 then
			fileName = "./data/" .. "MiniPassword_" .. tostring(m_nSnapshotSerialNumber) .. ".png";
		end

		local snapshotPath = ClientMgr:getDataDir() .. fileName;
		Log("fileName = " .. fileName);
		if SnapshotForShare:saveSnapshot(fileName) then
			Log("Password: OK, path = " .. snapshotPath);
			if IsIosPlatform() then
				ClientMgr:scanImage(snapshotPath)
			end
			if MINIW__CheckHasPermission(DevicePermission_WriteExternalStorage) and ClientMgr:isAndroid() then
				ClientMgr:scanImage(snapshotPath)
			end
			--提示保存成功
			-- {{如果没有存储权限，则将密码信息保存到剪贴板；lingbj
			if MINIW__CheckHasPermission(DevicePermission_WriteExternalStorage) then
				-- end lingbj 2021.11.9}}
				--LLDO:保存账号密码截图
				MessageBox(4, GetS(9166));
			end
		else
			Log("Password: Failed, path = " .. snapshotPath);
		end

		--截完图再关闭密码框, 不然就截不到密码了(老版设置密码界面).
		getglobal("ActivateAccountFrame"):Hide();
		--截完图再关闭密码框, 不然就截不到密码了(新版设置密码界面).
		GetInst("UIManager"):GetCtrl("ActivateAccount"):CloseBtn_OnClick();
	elseif m_nSnapshotType == 101 then
		local fileName = "screenImgCapture.png";
		print("OnSnapshotForShareFinished(): fileName = ", fileName);
		local snapshotPath = ClientMgr:getDataDir() .. "/" .. fileName;
		print("OnSnapshotForShareFinished(): snapshotPath = ", snapshotPath);
		if SnapshotForShare:saveSnapshot(fileName) then
			print("OnSnapshotForShareFinished(): saveSnapshot ");
			if ClientMgr.ScreenCaptureCallback then
				print("OnSnapshotForShareFinished(): ScreenCaptureCallback ");
				ClientMgr:ScreenCaptureCallback(snapshotPath);
			end
		else
			print("OnSnapshotForShareFinished(): saveSnapshot failed ");
		end
	end
end

--设置'm_nSnapshotType'值为100, 保存账号密码截图用, 给外部文件用的接口
function SetSnapshottypeValue(value, serialNumber)
	Log("SetSnapshottypeValue: value = " .. value);
	Log("SetSnapshottypeValue: serialNumber = " .. tostring(serialNumber or -1));
	m_nSnapshotType = value;
	m_nSnapshotSerialNumber = serialNumber or -1
end


local Sharescreenshot = {
		OnGetItem = true;--分享获得物品、解锁角色
		OnScreenshot = true;--游戏截图分享
		IsSaveSnapshot = false; --是否已调用保存
		Game = true;--游戏胜利失败分享
		MiniWork = true;--迷你工坊分享
		ScreenshotStyle = true;--截图分享样式(AR分享)
}
--
-- 分享获得物品、解锁角色
--
local fpsbutton = true;--fps
function ShareOnGetItem_OnLoad()
	this:setUpdateTime(0);
end

function ShareOnGetItem_OnShow()
	local getglobal = getglobal;
	-- 是否用二维码
	if not check_apiid_ver_conditions(ns_version.qq_share.show_QR_code) then
		getglobal("ShareOnGetItemShareCode"):Hide();
	end

	--分享者信息的显示
	if getglobal("ShareOnGetItemShareCode"):IsShown() then
		getglobal("ShareOnGetItemRoleInfo"):SetPoint("topright","ShareOnGetItem","topright",-50,150);
	else
		getglobal("ShareOnGetItemRoleInfo"):SetPoint("topright","ShareOnGetItem","topright",0,0);	
	end 
		
	--手Q新渠道显示二维码
	if isShouQPlatform() and  iOSShouQConfig(6,true) then
		getglobal("ShareOnGetItemShareCode"):Show();

		getglobal("ShareOnGetItemShareCodeQRCode"):SetTextureHuiresXml("ui/mobile/texture0/common.xml");
		getglobal("ShareOnGetItemShareCodeQRCode"):SetTexUV("fxjm_erweima_qq");

		getglobal("ShareOnGetItemRoleInfo"):SetPoint("topright","ShareOnGetItem","topright",-50,200);
		getglobal("ShareOnGetItemShareCode"):SetSize(160, 160);
		getglobal("ShareOnGetItemShareCode"):SetPoint("topright","ShareOnScreenshot","topright",-50, 300);

	end


	if (ClientMgr:getGameData("fpsbuttom")) == 1 then
		fpsbutton = true;
		DebugMgr:setRenderInfoFPS(true);
	end

	ClientMgr:setClickEffectEnabled(false);

	m_nSnapshotType = 1;

	local headIndex = AccountManager:getRoleModel();
	local skinModel = AccountManager:getRoleSkinModel();
	if skinModel > 0 then
		local skinDef = RoleSkinCsv:get(skinModel);
		if skinDef ~= nil then
			headIndex = skinDef.Head;
		end
	end
	-- getglobal("ShareOnGetItemRoleInfoPlayerIcon"):SetTexture("ui/roleicons/"..headIndex..".png");	
	getglobal("ShareOnGetItemRoleInfoPlayerUid"):SetText("@"..GetS(1254, AccountManager:getNickName(), GetMyUin()));
	local yearImgNames = {"fu.png", "lu.png", "shou.png", "xi.png"};
	local yearImgName = yearImgNames[math.random(1, #yearImgNames)];
	getglobal("ShareOnGetItemSpecImgImg"):SetTexUV(yearImgName);	
	local ItemShareTitle = getglobal("ShareOnGetItemShareTitleTitle1");
	local Textwidth = ItemShareTitle:GetTextExtentWidth(ItemShareTitle:GetText());
	-- print("GetTextExtentWidth",Textwidth);
	if Textwidth == 0 or ItemShareTitle:GetText() == "" then
		ItemShareTitle:Hide();
		getglobal("ShareOnGetItemShareTitleBkg"):Hide();
	else 
		ItemShareTitle:Show();
		getglobal("ShareOnGetItemShareTitleBkg"):Show();
	end 
	if Textwidth < 550 then
		ItemShareTitle:SetSize(Textwidth+50, 110);
		getglobal("ShareOnGetItemShareTitleBkg"):SetSize(Textwidth+80, (Textwidth/600)*23 +30);
	else
		ItemShareTitle:SetSize(600, 110);
		getglobal("ShareOnGetItemShareTitleBkg"):SetSize(610, (Textwidth/600)*23 +50);
	end

	-- if t_share_data.m_tShareParams.delayTime then
	-- 	threadpool:work(function()
	-- 		threadpool:wait(t_share_data.m_tShareParams.delayTime)
	-- 		SnapshotForShare:requestSaveSnapshot();
	-- 	end) 
	-- else
	SnapshotForShare:requestSaveSnapshot();
	-- end 
end

function ShareOnGetItem_OnHide()
	Log("*************** ShareOnGetItem_OnHide ***************");
	Sharescreenshot.OnGetItem = true;
end

function ShareOnGetItem_OnUpdate()
	if SnapshotForShare:isSnapshotFinished() and Sharescreenshot.OnGetItem then
		Sharescreenshot.OnGetItem = false;
		-- getglobal("ShareOnGetItem"):Hide();
		if fpsbutton then
			DebugMgr:setRenderInfoFPS(false);
			fpsbutton = false;
		end
		-- 海外版google分享图片时不能重名
		local svrtime = '';
		if IsAndroidBlockark() then
			svrtime = AccountManager:getSvrTime();
		end
		local filepath = "SnapshotForShare"..svrtime..".png"
		MiniwShareEx(filepath)
	end
end

--
-- 分享游戏截图
--
function ShareOnScreenshot_OnLoad()
	this:setUpdateTime(0);
end

function ShareOnScreenshot_OnShow()
	if IsStandAloneMode() then return end
	
	Sharescreenshot.IsSaveSnapshot = false
	local getglobal = getglobal;
	Log("*************** ShareOnScreenshot_OnShow ***************");
	-- 是否用二维码
	if not check_apiid_ver_conditions(ns_version.qq_share.show_QR_code) then
		getglobal("ShareOnScreenshotShareCode"):Hide();
	end

	if getglobal("ShareOnScreenshotShareCode"):IsShown() then
		getglobal("ShareOnScreenshotPlayerName"):SetPoint("topright","ShareOnScreenshot","topright",-120,70);
	else 
		getglobal("ShareOnScreenshotPlayerName"):SetPoint("topright","ShareOnScreenshot","topright",-7,70);
	end 

	--手Q新渠道显示二维码(显示的位置也重新调整，区别于其他渠道)
	if isShouQPlatform() and  iOSShouQConfig(6,true) then
		getglobal("ShareOnScreenshotShareCode"):Show();

		getglobal("ShareOnScreenshotShareCodeQRCode"):SetTextureHuiresXml("ui/mobile/texture0/common.xml");
		getglobal("ShareOnScreenshotShareCodeQRCode"):SetTexUV("fxjm_erweima_qq");
		
		getglobal("ShareOnScreenshotPlayerName"):SetPoint("topright","ShareOnScreenshot","topright",-50,200);
		getglobal("ShareOnScreenshotShareCode"):SetSize(160, 160);
		getglobal("ShareOnScreenshotShareCode"):SetPoint("topright","ShareOnScreenshot","topright",-50,250);
	end

	getglobal("GongNengFrameScreenshotBtn"):Hide();
	getglobal("GongNengFrameOpenCameraModeBtn"):Hide()
	if (ClientMgr:getGameData("fpsbuttom")) == 1 then
		fpsbutton = true;
		DebugMgr:setRenderInfoFPS(true);
	end
	ClientMgr:setClickEffectEnabled(false);
	
	if m_nSnapshotType == 2 then
		getglobal("UIHideFrameExitBtn"):Hide();
		getglobal("UIHideFrameScreenshotBtn"):Hide();

		local worldDesc = AccountManager:getCurWorldDesc();
		if worldDesc then
			if IsInHomeLandMap and IsInHomeLandMap() then
				getglobal("ShareOnScreenshotMapName"):SetText(GetS(42002, DefMgr:filterString(worldDesc.realNickName)));
			else
				getglobal("ShareOnScreenshotMapName"):SetText(GetS(1252, DefMgr:filterString(worldDesc.worldname)));
			end
			getglobal("ShareOnScreenshotAuthorName"):SetText(GetS(1253, DefMgr:filterString(worldDesc.realNickName), worldDesc.realowneruin));
			getglobal("ShareOnScreenshotPlayerName"):SetText("@"..GetS(1254, DefMgr:filterString(AccountManager:getNickName()), GetMyUin()));
		else
			local roomDesc = nil
			local roomInfo = AllRoomManager.RoomsCache[AllRoomManager.CurrentChooseRoomIdx]
			if roomInfo and roomInfo.type then
				if roomInfo.type == AllRoomManager.RoomType.Normal then
					roomDesc = AccountManager:getIthRoom(roomInfo.roomid-1);
				elseif roomInfo.type == AllRoomManager.RoomType.CloudServer then
					roomDesc = AllRoomManager.CSRoomsList[roomInfo.roomid];
					local serverid = roomDesc["_k_"]
					local uin,roomid = getRoomUinAndRoomID(serverid)
					local profile = PlayerProfileCtrl:GetProfileUin(uin)
					if not profile then
						local code, ret = PlayerProfileCtrl:ReqPlayerProfile(uin)
						if code == 0 then
							profile = ret[1]
						end
					end
					roomDesc.ownername = profile.profile and profile.profile.RoleInfo and profile.profile.RoleInfo.NickName or ""
					roomDesc.owneruin = uin
					roomDesc.roomname = roomDesc.room_name
				end
			end
			if roomDesc then
				getglobal("ShareOnScreenshotMapName"):SetText(GetS(1252, roomDesc.roomname));
				getglobal("ShareOnScreenshotAuthorName"):SetText(GetS(1253, roomDesc.ownername, roomDesc.owneruin));
				getglobal("ShareOnScreenshotPlayerName"):SetText("@"..GetS(1254, AccountManager:getNickName(), GetMyUin()));
			end

			Log("ShareOnScreenshot_OnShow worldDesc is nil");
		end
	else
		getglobal("ShareOnScreenshotMapName"):SetText("");
		getglobal("ShareOnScreenshotAuthorName"):SetText("");
		getglobal("ShareOnScreenshotPlayerName"):SetText("");
	end

	Sharescreenshot.IsSaveSnapshot = true
	SnapshotForShare:requestSaveSnapshot();
end

function ShareOnScreenshot_OnHide()
	if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.MAP) then--xyang自定义UI
		getglobal("GongNengFrameScreenshotBtn"):Show();
	end
	if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.CAMERA) then--xyang自定义UI
		getglobal("GongNengFrameOpenCameraModeBtn"):Show()
		GongNengFrame_ReportEventCameraButton("view")
	end
	if m_nSnapshotType == 2 then
		-- UnhideAllUI();
	elseif m_nSnapshotType == 3 then
		getglobal("ActivityFrameZhishuShareBtn"):Show();
		getglobal("ActivityFrameZhishuShareCloseBtn"):Show();
	end
	Sharescreenshot.OnScreenshot = true;
	Log("*************** ShareOnScreenshot_OnHide ***************");
end

function ShareOnScreenshot_OnUpdate()
	local getglobal = _G.getglobal;
	local SetMenuFrame = getglobal("SetMenuFrame");
	if SetMenuFrame:IsShown() then
		ShareOnOptionMenuFrame_OnClick();
		return;
	end

	if SnapshotForShare:isSnapshotFinished() and Sharescreenshot.OnScreenshot and Sharescreenshot.IsSaveSnapshot then
		Sharescreenshot.OnScreenshot = false;
		-- getglobal("ShareOnScreenshot"):Hide();
		if fpsbutton then
			DebugMgr:setRenderInfoFPS(false);
			fpsbutton = false;
		end

		-- 海外版google分享时图片不能重名
		local svrtime = '';
		if IsAndroidBlockark() then
			svrtime = AccountManager:getSvrTime();
		end
		local filepath = "SnapshotForShare"..svrtime..".png"
		MiniwShareEx(filepath, function()
			getglobal("ActivityFrameZhishuShareBtn"):Show();
			getglobal("ActivityFrameZhishuShareCloseBtn"):Show();
		end)
	end
end
--
-- 游戏胜利失败截图分享
--
function GamesharingFrame_OnLoad()
	this:setUpdateTime(0);
end

function GamesharingFrame_OnShow()
	Log("*************** GamesharingFrame_OnShow ***************");
	if (ClientMgr:getGameData("fpsbuttom")) == 1 then
		fpsbutton = true;
		DebugMgr:setRenderInfoFPS(true);
	end

	
	local briefInfo = ClientCurGame:getPlayerBriefInfo(-1);	--自己
	local result = briefInfo.cgamevar[1];--1：胜利 2：失败 3：平局
	print("result:sda",result)
	getglobal("GamesharingFrameShareTitleTitle1"):SetText(GetS(1252,t_share_data.worldName));
	getglobal("GamesharingFrameShareTitleTitle2"):SetText(GetS(1253,t_share_data.authorNmae,t_share_data.authorUin));
	if result == 1 then
		getglobal("GamesharingFrameBkg"):SetTexture("ui/mobile/texture2/bigtex/shengli.png");
		getglobal("GamesharingFrameRoleInfoTitle"):SetText(GetS(1508,briefInfo.nickname,t_share_data.worldName));

	end
	if result == 2 then
		getglobal("GamesharingFrameBkg"):SetTexture("ui/mobile/texture2/bigtex/shibai.png");
		getglobal("GamesharingFrameRoleInfoTitle"):SetText(GetS(1509,briefInfo.nickname,t_share_data.worldName));
	end
	if result == 3 then
		getglobal("GamesharingFrameBkg"):SetTexture("ui/mobile/texture2/bigtex/shengli.png");
		getglobal("GamesharingFrameRoleInfoTitle"):SetText(GetS(1508,briefInfo.nickname,t_share_data.worldName));
	end
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
		local worldDesc = AccountManager:findWorldDesc(CurWorld:getOWID());
		local huires = Snapshot:getSnapshotTexture(worldDesc.worldid);--获取缩略图
		getglobal("GamesharingFrameSharephotoQRCode"):SetTextureHuires(huires);
	else
		if g_ScreenshotShareRoomDesc and g_ScreenshotShareRoomDesc.thumbnail_url~="" and g_ScreenshotShareRoomDesc.thumbnail_md5~="" then
			local url_list = {g_ScreenshotShareRoomDesc.thumbnail_url};
			local cache_file_path = "data/http/thumbs/"..g_ScreenshotShareRoomDesc.thumbnail_md5..g_ScreenshotShareRoomDesc.thumbnail_ext;
			DownloadThumbnail(url_list, cache_file_path, getglobal("GamesharingFrameSharephotoQRCode"):GetName(), g_ScreenshotShareRoomDesc.thumbnail_md5);
		end
	end

	local index = GetHeadIconIndex();
	--getglobal("GamesharingFrameRoleInfoIcon"):SetTexture("ui/roleicons/"..index..".png");
	HeadCtrl:CurrentHeadIcon("GamesharingFrameRoleInfoIcon");
	HeadFrameCtrl:CurrentHeadFrame("GamesharingFrameRoleInfoIconFrame");
	SnapshotForShare:requestSaveSnapshot();
end

function GamesharingFrame_OnHide()
	Log("*************** GamesharingFrame_OnHide ***************");
	Sharescreenshot.Game = true;
end

function GamesharingFrame_OnUpdate()
	if SnapshotForShare:isSnapshotFinished() and Sharescreenshot.Game then
		Sharescreenshot.Game = false;
		-- getglobal("GamesharingFrame"):Hide();
		if fpsbutton then
			DebugMgr:setRenderInfoFPS(false);
			fpsbutton = false;
		end
		-- 海外版google分享时图片不能重名
		local svrtime = '';
		if IsAndroidBlockark() then
			svrtime = AccountManager:getSvrTime();
		end
		local filepath = "SnapshotForShare"..svrtime..".png"
		MiniwShareEx(filepath, function()
			getglobal("ActivityFrameZhishuShareBtn"):Show();
			getglobal("ActivityFrameZhishuShareCloseBtn"):Show();
		end, function()
			getglobal("GamesharingFrame"):Hide();
		end)
	end
end
--
-- 迷你工坊截图分享
--
function MiniWorkShareFrame_OnLoad()
	this:setUpdateTime(0);
end
--在ArchiveInfoFrameIntroduceShareBtn_OnClick里调SetMiniWorkShareFrame(MiniWorksMapShare_CurrentMap);
function SetMiniWorkShareFrame(map)
	if map == nil then
		print("地图为空");
		return;
	end

	if (ClientMgr:getGameData("fpsbuttom")) == 1 then
		fpsbutton = true;
		DebugMgr:setRenderInfoFPS(true);
	end

	local pic_name = map.download_thumb_md5 .. ".png_"
	if type(map.download_thumb_url) == 'string' and #map.download_thumb_url>=10 then
		pic_name = ns_advert.func.trimUrlFile(map.download_thumb_url) .. "_"
	end
	local imgPath
	if pic_name == "" or pic_name == ".png_" then 
		imgPath = "ui/snap_empty.png"
	else
		imgPath = mapservice.downloadThumbnailRoot..pic_name
	end 
	local MapName = getglobal("MiniWorkShareFrameShareDescribeMapName") 
	local DownNum = getglobal("MiniWorkShareFrameShareDescribeDown");
	local LikeNum = getglobal("MiniWorkShareFrameShareDescribeLike");
	local icon = getglobal("MiniWorkShareFrameShareDescribeIcon");
	local iconFrame = getglobal("MiniWorkShareFrameShareDescribeIconFrame");
	local Name = getglobal("MiniWorkShareFrameShareDescribePlayerName");
	local MiniUin = getglobal("MiniWorkShareFrameShareDescribePlayerUin");
	getglobal("MiniWorkShareFrameSharephotoQRCode"):SetTexture(imgPath);
	getglobal("MiniWorkShareFrameRoleInfoAuthorName"):SetText("@"..GetS(1254, AccountManager:getNickName(), GetMyUin()))
	MapName:SetText(map.name);
	
	--下载人数
	local download_num = map.download_count or 0;		
	if  lang_show_as_K() and download_num > 1000 then
		DownNum:SetText(string.format("%0.1f", download_num/1000).. 'K'..GetS(3845));
	elseif download_num > 10000 then
		DownNum:SetText(string.format("%0.1f", download_num/10000)..GetS(3841)..GetS(3845)); --X.X万
	else
		DownNum:SetText(tostring(download_num)..GetS(3845));
	end

	--鉴赏家推荐人数
	if map and map.push_up3 and map.push_up3 > 0 then
		getglobal("MiniWorkShareFrameShareDescribeLikeIcon"):Show();
		LikeNum:Show();
		LikeNum:SetText(GetS(1336, map.push_up3));
	else
		getglobal("MiniWorkShareFrameShareDescribeLikeIcon"):Hide();
		LikeNum:Hide();
	end
	-- huangxin 修改分享无效果情况
	local ShortUin = 0
	HeadCtrl:SetPlayerHeadByUin(icon:GetName(),map.author_uin,map.author_icon);
	HeadFrameCtrl:SetPlayerheadFrameName(iconFrame:GetName(),map.author_frame_id);
	Name:SetText(map.author_name);
	Name:Show();
    ShortUin = getShortUin(map.author_uin);
	--[[
	if isEnableNewLobby and isEnableNewLobby() then
		local worldid = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
		local worldDesc = AccountManager:findWorldDesc(worldid)
		if worldDesc == nil then return end
		--头像
		HeadCtrl:SetPlayerHeadByUin(icon:GetName(),worldDesc.realowneruin,worldDesc.realModel);
		HeadFrameCtrl:SetPlayerheadFrameName(iconFrame:GetName(),worldDesc.ownerIconFrame);
		--玩家名称
		Name:SetText(worldDesc.realNickName);
		Name:Show();

		ShortUin = getShortUin(worldDesc.realowneruin);
	else
		if ArchiveWorldDesc == nil then return end
		--头像
		HeadCtrl:SetPlayerHeadByUin(icon:GetName(),ArchiveWorldDesc.realowneruin,ArchiveWorldDesc.realModel);
		HeadFrameCtrl:SetPlayerheadFrameName(iconFrame:GetName(),ArchiveWorldDesc.ownerIconFrame);
		--玩家名称
		Name:SetText(ArchiveWorldDesc.realNickName);
		Name:Show();

		ShortUin = getShortUin(ArchiveWorldDesc.realowneruin);
	end
	 --]]
	 --huangxin 修改结束
	MiniUin:SetText(GetS(359)..ShortUin);

	SetSnapshottypeValue(0);
	getglobal("MiniWorkShareFrame"):Show();

	SnapshotForShare:requestSaveSnapshot();
	threadpool:wait(0.5);
end

function MiniWorkShareFrame_OnShow()
	Log("*************** GamesharingFrame_OnShow ***************");
	-- 是否用二维码
	if not check_apiid_ver_conditions(ns_version.qq_share.show_QR_code) then
		getglobal("MiniWorkShareFrameRoleInfoQRCode"):Hide();
	end
	if getglobal("MiniWorkShareFrameRoleInfoQRCode"):IsShown() then
		getglobal("MiniWorkShareFrameRoleInfoLogo"):SetPoint("right","MiniWorkShareFrameRoleInfoQRCode","right",-130,-17);	
	else 
		getglobal("MiniWorkShareFrameRoleInfoLogo"):SetPoint("topright","MiniWorkShareFrame","topright",-5,0);
	end  
end

function MiniWorkShareFrame_OnHide()
	Log("*************** GamesharingFrame_OnHide ***************");
	Sharescreenshot.MiniWork = true;
end

function MiniWorkShareFrame_OnUpdate()

	if SnapshotForShare:isSnapshotFinished() and Sharescreenshot.MiniWork == true then
		Sharescreenshot.MiniWork = false
		-- getglobal("MiniWorkShareFrame"):Hide();
		if fpsbutton then
			DebugMgr:setRenderInfoFPS(false);
			fpsbutton = false;
		end

		-- 海外版google分享时图片不能重名
		local svrtime = '';
		if IsAndroidBlockark() then
			svrtime = AccountManager:getSvrTime();
		end
		local filepath = "SnapshotForShare"..svrtime..".png"
		MiniwShareEx(filepath, function()
			getglobal("ActivityFrameZhishuShareBtn"):Show();
			getglobal("ActivityFrameZhishuShareCloseBtn"):Show();
		end)
	end
end
---
-- 游戏截图样式1
--
function ScreenshotStyleFrame_OnLoad()
	this:setUpdateTime(0);
end

function ScreenshotStyleFrame_OnShow()
	Log("*************** ScreenshotStyleFrame_OnShow ***************");
	if (ClientMgr:getGameData("fpsbuttom")) == 1 then
		fpsbutton = true;
		DebugMgr:setRenderInfoFPS(true);
	end

	-- 是否用二维码
	if not check_apiid_ver_conditions(ns_version.qq_share.show_QR_code) then
		getglobal("ScreenshotStyleFrameRoleInfoQRCode"):Hide();
	end

	if getglobal("ARGradeFrame"):IsShown() then
		getglobal("ARGradeFrameSkip"):Hide();
		getglobal("ARGradeFrameRephotograph"):Hide();
		getglobal("ARGradeFrameShareBtn"):Hide();
	else 
		if not(ARControl:GetBottomBtnHideState()) then
			ARStoreFrameHideView();
		end
		getglobal("ARStoreFrameBottom"):Hide();
		getglobal("ARStoreFrameHideBtn"):Hide();
	end
	getglobal("ScreenshotStyleFrameRoleInfoAuthorName"):SetText("@"..GetS(1254, AccountManager:getNickName(), GetMyUin()));
	SnapshotForShare:requestSaveSnapshot();
end

function ScreenshotStyleFrame_OnHide()
	Log("*************** ScreenshotStyleFrame_OnHide ***************");
	if getglobal("ARGradeFrame"):IsShown() then
		getglobal("ARGradeFrameSkip"):Show();
		getglobal("ARGradeFrameRephotograph"):Show();
		getglobal("ARGradeFrameShareBtn"):Show();
	else 
		if ARControl:GetBottomBtnHideState() then
			ARStoreFrameShowView();
		end
		getglobal("ARStoreFrameBottom"):Show();
		getglobal("ARStoreFrameHideBtn"):Show();
	end 
	Sharescreenshot.ScreenshotStyle = true;
end

function ScreenshotStyleFrame_OnUpdate()
	if SnapshotForShare:isSnapshotFinished() and Sharescreenshot.ScreenshotStyle == true then
		Sharescreenshot.ScreenshotStyle = false;
		if fpsbutton then
			DebugMgr:setRenderInfoFPS(false);
			fpsbutton = false;
		end

		-- 海外版google分享时图片不能重名
		local svrtime = '';
		if IsAndroidBlockark() then
			svrtime = AccountManager:getSvrTime();
		end
		local filepath = "SnapshotForShare"..svrtime..".png"
		MiniwShareEx(filepath)
	end
end
-----------------------------------------------------------------------------------------
-- 上报玩家share行为
g_check_ma_share_last_time = 0
function check_ma_share( msg )	
	Log("call check_ma_share")
	--每30秒一次
	local  now_ = getServerNow();
	if  now_ - g_check_ma_share_last_time > 30 then
		g_check_ma_share_last_time = now_
		WWW_ma_press_share( msg )
	else
		Log("check_ma_share no 30 " ..  now_ .. " / " .. g_check_ma_share_last_time )
	end
end

---------------------------- 分享菜单 begin-----------------------------
-- 每次分享是调用该函数刷新一下
function SetShareData(imgPath, url, title, text)
	t_share_data.imgPath = imgPath
	t_share_data.url = url
	t_share_data.title = title
	t_share_data.text = text
end

function GetShareDate()
	return t_share_data;
end

-- 当前分享场景:Scene 场景；modelId 有些地方需要记录皮肤、坐骑、角色等的id
function SetShareScene(Scene, modelId)
	if Scene == nil then Scene = "" end
	if modelId == nil then modelId = "" end

	t_share_data.shareScene = Scene
	t_share_data.shareModelId = tostring(modelId)
end

function GetShareScene()
	return t_share_data.shareScene
end

function GetShareModelId()
	return t_share_data.shareModelId
end

function SetShareMiniWorksAuthorInfo(t_authorInfo)
	t_share_data.worldName = t_authorInfo.name
	t_share_data.authorNmae = t_authorInfo.uin_name
	t_share_data.authorUin = t_authorInfo.uin
	t_share_data.thumb_md5 = t_authorInfo.thumb_md5
end

-- 分享完成后清理数据
function CleanShareScene()
	t_share_data.shareScene = ""
	t_share_data.shareModelId = ""
end

local function ShareOnOptionMenuFrame_showPlatformIcon()
	if t_share_data.shareScene == "IntegralTask" then -- vip活动积分任务，不显示端外分享按钮
		t_share_data.platformName = {
			"fx_game",
			"fx_group"
		}
	end
	for i=1,#t_share_data.platformName do
		if isShouQPlatform() and  iOSShouQConfig(6,true) then
			if t_share_data.platformName[i] == "fx_qq" then
				getglobal("ShareOnOptionMenuFrameList"..i.."Normal"):SetTexUV("btn_qqshare_qq")
				getglobal("ShareOnOptionMenuFrameList"..i.."PushedBG"):SetTexUV("btn_qqshare_qq")
			elseif t_share_data.platformName[i] == "fx_qqkj" then
				getglobal("ShareOnOptionMenuFrameList"..i.."Normal"):SetTexUV("btn_qqshare_qzone")
				getglobal("ShareOnOptionMenuFrameList"..i.."PushedBG"):SetTexUV("btn_qqshare_qzone")
			else
				getglobal("ShareOnOptionMenuFrameList"..i.."Normal"):SetTexUV(t_share_data.platformName[i])
				getglobal("ShareOnOptionMenuFrameList"..i.."PushedBG"):SetTexUV(t_share_data.platformName[i])
			end
			
		else
			getglobal("ShareOnOptionMenuFrameList"..i.."Normal"):SetTexUV(t_share_data.platformName[i])
			getglobal("ShareOnOptionMenuFrameList"..i.."PushedBG"):SetTexUV(t_share_data.platformName[i])
		end

		getglobal("ShareOnOptionMenuFrameList"..i):Show()
	end
	if #t_share_data.platformName < t_share_data.MAX_PLATFORM_COUNT then
		for i=#t_share_data.platformName + 1, t_share_data.MAX_PLATFORM_COUNT do
			getglobal("ShareOnOptionMenuFrameList"..i):Hide()
		end
	end
end

function ShareOnOptionMenuBtnStandReportEvent(btnType, eventcode)
	if t_share_data.shareScene == "RewardBean" then  --分享迷你豆的埋点
		local t_oID = {
			fx_qq = "QQ",
			fx_wx = "Wechat",
			fx_wb = "SinaWeibo",
			fx_pyq = "Moments",
			fx_qqkj = "QZone",
		}
		if t_oID[btnType] then
			standReportEvent("21", "MINI_SHAREBUTTON", t_oID[btnType], eventcode);
		end
	end
end

function ShareOnOptionMenuFrame_updateShareFrame()
	local index = 1

	ns_version.qq_share = ns_version.qq_share or {}

	t_share_data.platformName = {}

	if check_apiid_ver_conditions(ns_version.qq_share.posting)
		and (t_share_data.shareScene ~= "RewardBean") --分享迷你豆屏蔽游戏内分享
		and (t_share_data.shareScene ~= "MarketActivity") 
		and (t_share_data.shareScene ~= "InvitePlayers") then -- deeplink进入房间分享屏蔽
		t_share_data.platformName[index] = "fx_dt";
		index =index +1;
	end

	if check_apiid_ver_conditions(ns_version.qq_share.minifriends) 
	and (t_share_data.shareScene ~= "GameScreenshot") -- 特殊处理：进入游戏后截图分享的时候没有内部分享按钮
	and (t_share_data.shareScene ~= "AvatarStoreFrameBottomShare") -- Avatar分享暂时屏蔽
	and (t_share_data.shareScene ~= "RewardBean") --分享迷你豆屏蔽游戏内分享
	and (t_share_data.shareScene ~= "InvitePlayers") then -- deeplink进入房间分享屏蔽
		t_share_data.platformName[index] = "fx_game"
		index = index + 1
	end

	if check_apiid_ver_conditions(ns_version.qq_share.minifriends) 
	and (t_share_data.shareScene ~= "GameScreenshot") -- 特殊处理：进入游戏后截图分享的时候没有内部分享按钮
	and (t_share_data.shareScene ~= "AvatarStoreFrameBottomShare") -- Avatar分享暂时屏蔽
	and (t_share_data.shareScene ~= "RewardBean") --分享迷你豆屏蔽游戏内分享
	and (t_share_data.shareScene ~= "InvitePlayers") then -- deeplink进入房间分享屏蔽
		if friendservice.groupchat_switch then
			t_share_data.platformName[index] = "fx_group"
			--这个是群组
			index = index + 1
		end 
	end

	if (ClientMgr.isPC and ClientMgr:isPC()) or (false and IsAndroidBlockark() and IsProtectMode()) then

	else
		if check_apiid_ver_conditions(ns_version.qq_share.qq) then
			t_share_data.platformName[index] = "fx_qq"
			index = index + 1
			ShareOnOptionMenuBtnStandReportEvent("fx_qq", "view")
		end
		if check_apiid_ver_conditions(ns_version.qq_share.wx) then
			t_share_data.platformName[index] = "fx_wx"
			index = index + 1
			ShareOnOptionMenuBtnStandReportEvent("fx_wx", "view")
		end
		if check_apiid_ver_conditions(ns_version.qq_share.wb) then
			t_share_data.platformName[index] = "fx_wb"
			index = index + 1
			ShareOnOptionMenuBtnStandReportEvent("fx_wb", "view")
		end
		if check_apiid_ver_conditions(ns_version.qq_share.wxfriends) then
			t_share_data.platformName[index] = "fx_pyq"
			index = index + 1
			ShareOnOptionMenuBtnStandReportEvent("fx_pyq", "view")
		end
		if check_apiid_ver_conditions(ns_version.qq_share.qzone) then
			t_share_data.platformName[index] = "fx_qqkj"
			index = index + 1
			ShareOnOptionMenuBtnStandReportEvent("fx_qqkj", "view")
		end
		if check_apiid_ver_conditions(ns_version.qq_share.facebook) and ClientMgr:CheckAppInstall("fx_fb") then
			t_share_data.platformName[index] = "fx_fb"
			index = index + 1
		end
		if check_apiid_ver_conditions(ns_version.qq_share.twitter) and ClientMgr:CheckAppInstall("fx_tw") then
			t_share_data.platformName[index] = "fx_tw"
			index = index + 1
		end

		if isShouQPlatform() and isIOSShouQ() then
			t_share_data.platformName = {}
			index = 1
			if check_apiid_ver_conditions(ns_version.qq_share.posting)
				and (t_share_data.shareScene ~= "RewardBean") --分享迷你豆屏蔽游戏内分享
				and (t_share_data.shareScene ~= "MarketActivity") 
				and (t_share_data.shareScene ~= "InvitePlayers") then -- deeplink进入房间分享屏蔽
				t_share_data.platformName[index] = "fx_dt";
				index =index +1;
			end
			if check_apiid_ver_conditions(ns_version.qq_share.qq) then
				t_share_data.platformName[index] = "fx_qq"
				index = index + 1
				ShareOnOptionMenuBtnStandReportEvent("fx_qq", "view")
			end
			if check_apiid_ver_conditions(ns_version.qq_share.qzone) then
				t_share_data.platformName[index] = "fx_qqkj"
				index = index + 1
				ShareOnOptionMenuBtnStandReportEvent("fx_qqkj", "view")
			end
		end

		--手Q新渠道添加图片下载按钮（邀请离线好友需要屏蔽）
		if (isShouQPlatform() and iOSShouQConfig(6,true)) and t_share_data.shareScene ~= "InvitePlayers" then
			t_share_data.platformName[index] = "btn_qqshare_down"
			index = index + 1
		end
	end

	ShareOnOptionMenuFrame_showPlatformIcon()
end

function ShareOnOptionMenuFrame_OnShow()
	local getglobal = getglobal;
	Log("ShareOnOptionMenuFrame_OnShow:")
	ShareOnOptionMenuFrame_updateShareFrame()
end

function ShareOnOptionMenuFrame_OnHide()
	local getglobal = getglobal;
	Log("***********ShareOnOptionMenuFrame_OnHide***************")
	if getglobal("ShareOnGetItem"):IsShown() then
		getglobal("ShareOnGetItem"):SetFrameStrataInt(5);
		getglobal("ShareOnGetItem"):Hide();
	elseif getglobal("ShareOnScreenshot"):IsShown() then
		getglobal("ShareOnScreenshot"):Hide();
	elseif getglobal("GamesharingFrame"):IsShown() then
		getglobal("GamesharingFrame"):Hide();
	elseif getglobal("MiniWorkShareFrame"):IsShown() then
		getglobal("MiniWorkShareFrame"):Hide();
	elseif ShareActivityFrame and ShareActivityFrame:IsShown() then
		getglobal("ShareActivityFrame"):Hide();
	end
	if getglobal("ScreenshotStyleFrame"):IsShown() then
		getglobal("ScreenshotStyleFrame"):Hide();
	-- elseif getglobal("ARUnlockResultFrame"):IsShown() then
	-- 	getglobal("ARUnlockResultFrameBkg"):Show();
	-- 	if getglobal("ARUnlockResultFrameSuccess"):IsShown() then
	-- 		getglobal("ARUnlockResultFrameSuccessConfirmBtn"):Show()
	-- 		getglobal("ARUnlockResultFrameSuccessShareBtn"):Show()
	-- 	end
	elseif getglobal("ExhibitionAchieveShareFrame"):IsShown() then
		getglobal("ExhibitionAchieveShareFrame"):Hide();
	elseif GetInst("UIManager"):GetCtrl("ShopGain") and GetInst("UIManager"):GetCtrl("ShopGain"):IsShopGainOpen() then
		GetInst("UIManager"):Close("ShopGain")
	end
	OnSnapshotForShareFinished();

	local szShareScene = GetShareScene();
	if ClientCurGame:isInGame() and not (szShareScene == "BattleWin" or szShareScene == "BattleFailed" or getglobal("DynamicPublishFrame"):IsShown()) then
		ClientCurGame:setOperateUI(false);
	end

	if t_share_data.shareCallback then
		t_share_data:shareCallback()
		t_share_data.shareCallback = nil
	end
end

-- 安卓渠道项目迁移到 Adnroid Studio，分享能力从common中分离
function isUseNewShare()
	local apiId = ClientMgr:getApiId()
	local t_newShareId = {1, 2, 12, 17, 18, 32}
	for i=1,#(t_newShareId) do
		if apiId == t_newShareId[i] or IsMiniCps(apiId) then
			return true;
		end
	end
	return false;
end
--点击分享平台icon进行分享
function ShareIconBtnTemplate_OnClick()
	Log("ShareIconBtnTemplate_OnClick")
	local index = this:GetClientID()
	if t_share_data.platformName[index] == "fx_dt" and false == AccountSafetyCheck:FunCheck(AccountSafetyCheck.FunType.DYNAMIC_PUBLISH) then
		Log("ShareIconBtnTemplate_OnClick ShareOnOptionMenuFrame_OnClick")
		ShareOnOptionMenuFrame_OnClick()
		return
	end
	local print, Log = Android:Localize(Android.SITUATION.QRCODE_SCANNER);
	print("ShareIconBtnTemplate_OnClick(): ");
	-- statisticsGameEvent(1900, "%s", t_share_data.platformName[index], "%s", GetShareScene(), "%s", GetShareModelId())
	Log("ShareIconBtnTemplate_OnClick index:" .. index .. ", iconName:" .. t_share_data.platformName[index])

	if t_share_data.m_tShareParams.shareType == t_share_data.ShareType.CHAMELEON then
		getglobal("ARUnlockResultFrame"):Hide()
	end

	isShareActivityClick = true
	ShareOnOptionMenuBtnStandReportEvent(t_share_data.platformName[index], "click");

	NewBattlePassEventOnTrigger("share")

	getglobal("ShareOnOptionMenuFrame"):Hide()
	if t_share_data.platformName[index] == "fx_game" then
		getglobal("MiniWorksShareMapFrame"):Show();
	elseif t_share_data.platformName[index] == "fx_group" then 
		GetInst("UIManager"):Open("GroupChatShare")
	elseif t_share_data.platformName[index] == "fx_dt" then
		local imgPath
		local text
		if t_share_data.text and t_share_data.text ~= "" then
			text = t_share_data.text
		end
		if t_share_data.imgPath and t_share_data.imgPath ~= "" then
			imgPath = t_share_data.imgPath
			if not string.find(imgPath, ClientMgr:getDataDir()) and ClientMgr:isPC() then
				imgPath = ClientMgr:getDataDir().."/"..t_share_data.imgPath
			end
		end
	
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/playerCenter","miniui/miniworld/Chat"})
		GetInst("MiniUIManager"):OpenUI("playerCenterPublish", "miniui/miniworld/playerCenter", "playerCenterPublishAutoGen",{
			picUrlList = {
				imgPath
			},
			text = text
		})
		
		-- getglobal("DynamicPublishFrame"):AddLevelRecursive(1)
		-- getglobal("DynamicPublishFrameCommitBtn"):SetPoint("bottom", "DynamicPublishFrameBkg", "bottom", -10, -23);

	elseif t_share_data.platformName[index] == "btn_qqshare_down" then
		if isAndroidShouQ() then
			--点击保存图片按钮（手Q新渠道）
			local downloadPic = JavaMethodInvokerFactory:obtain()
														:setSignature("(Ljava/lang/String;)V")
														:setClassName("org/appplay/lib/GameBaseActivity")
														:setMethodName("downloadShareScreenShot")
														:addString(t_share_data.imgPath)
														:call()
		else
			ClientMgr:scanImage(t_share_data.imgPath)
		end
	else
		--LLDO:13岁保护模式特殊处理: 不让点击, 点击飘字
		if false and IsAndroidBlockark() and IsProtectMode() then
			ShowGameTips(GetS(20211), 3);
			return;
		end
		if isUseNewShare() then
			SdkManager:startMiniwShare(
					t_share_data.platformName[index],
					t_share_data.imgPath,
					t_share_data.url,
					t_share_data.title,
					t_share_data.text
			)
		else
			SdkManager:startOnlineShare(
					t_share_data.platformName[index],
					t_share_data.imgPath,
					t_share_data.url,
					t_share_data.title,
					t_share_data.text
			)
		end
		if t_share_data.m_tShareParams.shareType == t_share_data.ShareType.SKIN then
			t_share_data:ShowNextRewardDisplay();
		elseif t_share_data.m_tShareParams.shareType == t_share_data.ShareType.CHAMELEON  then
			t_share_data:ReshowRewardDisplay();
		end
		
		CleanShareScene() --每次分享完成后清理一下比较保险，放置后期增加分享事件时忘记设置统计场景
	end
end

function ShareOnOptionMenuFrameListCloseBtn_OnClick()
	getglobal("ShareOnOptionMenuFrame"):Hide()
	t_share_data:ShowNextRewardDisplay();
end

function ShareOnOptionMenuFrameListBigCloseBtn_OnClick()
	ShareOnOptionMenuFrameListCloseBtn_OnClick()
end

function ShareOnOptionMenuFrame_OnClick()
	Log("ShareOnOptionMenuFrame_OnClick:")
	ShareOnOptionMenuFrameListCloseBtn_OnClick()
end
---------------------------- 分享菜单 end-----------------------------

function CreateShareRequest()
	local _server = g_http_root .. 'miniw/php_cmd'

	local builder = {
		url = _server,
		authparams = "",

		addparam = function(self, name, value, url_escape)

			if #self.authparams > 0 then
				self.url = self.url.."&";
				self.authparams = self.authparams.."&";
			else
				self.url = self.url.."?";
			end

			if url_escape then
				self.url = self.url..name.."="..gFunc_urlEscape(value);
			else
				self.url = self.url..name.."="..value;
			end

			self.authparams = self.authparams..name.."="..value;

			return self;
		end,

		finish = function(self)
			print("friend req = "..self.url);
			return self.url;
		end,
	};

	return builder;
end

function OnShareSuccess()
	local tShareParams = t_share_data.tShareParams;
	local ShareType = t_share_data.ShareType;
	local szGeneralShareKey = "general_share_others";
	local szGeneralShareValue = 1;
	if tShareParams == nil or tShareParams.shareType == nil then return end
	if tShareParams.shareType == ShareType.MAP then
		szGeneralShareKey = "general_share_map";

	elseif tShareParams.shareType == ShareType.SKIN or tShareParams.shareType == ShareType.CHAMELEON then
		szGeneralShareKey = "general_share_skin";
		szGeneralShareValue = tShareParams.skinId;

	elseif tShareParams.shareType == ShareType.RIDE then 
		szGeneralShareKey = "general_share_ride";
		szGeneralShareValue = tShareParams.rideId;

	elseif tShareParams.shareType == ShareType.ROLE then
		szGeneralShareKey = "general_share_role";
		szGeneralShareValue = tShareParams.roleIndex;

	elseif tShareParams.shareType == ShareType.BATTLE_VICTORY then
		szGeneralShareKey = "general_share_battle";

	elseif tShareParams.shareType == ShareType.BATTLE_FAILURE then
		szGeneralShareKey = "general_share_battle";

	elseif tShareParams.shareType == ShareType.ACHIEVE then
		szGeneralShareKey = "general_share_achieve";

	elseif tShareParams.shareType == ShareType.WEAPON then
		szGeneralShareKey = "general_share_weapon";
		szGeneralShareValue = tShareParams.skinId;
	else
		return;

	end

	local url = CreateShareRequest()		
		:addparam("act", "set_ma_task")
		:addparam("user_action", "general_share")
		:addparam(szGeneralShareKey, szGeneralShareValue)
		:finish();

	url = url .. '&' .. http_getS1();
	
	ns_http.func.rpc(url, nil, nil, nil, ns_http.SecurityTypeHigh)    --ma
end

local function IsWeiboShareEnable()
	local apiId = ClientMgr:getApiId()
	return IsIosPlatform() 
		or apiId == 35 -- 酷派
		or apiId == 89 -- 爱奇艺
		or apiId == 1 -- 国内官包
		or apiId == 76 -- cps18183
		or apiId == 88 -- cps7723
		or apiId == 99 -- 国内先遣服
		or apiId == 62 -- cpsGG助手
		or apiId == 78 -- cps金立应用
		or apiId == 64 -- cps聚丰
		or apiId == 81 -- cps快看漫画
		or apiId == 65 -- cps酷比
		or apiId == 66 -- cps雷震
		or apiId == 80 -- cps美图
		or apiId == 92 -- cps7723
		or apiId == 67 -- cps努比亚
		or apiId == 82 -- cpsPP助手
		or apiId == 75 -- cps青柠
		or apiId == 91 -- cps市场部
		or apiId == 69 -- cps锤子
		or apiId == 83 -- cps神马搜索
		or apiId == 84 -- cps豌豆荚
		or apiId == 79 -- cps悟饭
		or apiId == 74 -- cps移动MM
		or apiId == 93 -- cps易乐
		or apiId == 70 -- cps觅途有方
		or apiId == 73 -- cps应用汇
		or apiId == 71 -- cps中兴
		or apiId == 13 -- OPPO
		or apiId == 54 -- OPPO体验
		or apiId == 49 -- 三星
		or apiId == 21 -- 应用宝
		or apiId == 47 -- QQ游戏大厅
		or apiId == 36 -- vivo
		or apiId == 15 -- 360
end

function getAvatarShareIds(seatInfo)
	if not seatInfo then return "" end

	local idx, ids = 1, ""
	if seatInfo and seatInfo.skin then
		for k, v in pairs(seatInfo.skin) do
			if v and v.cfg and v.cfg.ModelID then
				if idx == 1 then
					ids = v.cfg.ModelID
				else
					ids = ids .. "," .. v.cfg.ModelID
				end
			end
		end
	end

	return ids
end