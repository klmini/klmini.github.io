local tostring = _G.tostring
local type = _G.type
CreateMapGuideStep = 0;
--断网提示是否被点击过 点击过后不在提示
local isOffNetworkHint = true;
---------------------------------------------------------Top---------------------------------
local isQQBlueVipBtnLongPressing = false;
local is7k7kBlueVipBtnLongPressing = false;
local net_work_power = 0; -- 网络强度
gNetworkFlag = false
local miniLobbyFrameTopActivity_Num = 0--大厅右上角显示的活动个数
local miniLobbyFrameTopActivity_OffsetX = 0--大厅右上角显示的活动偏移值
local bolOnlineHallGuide = false --是否从大厅引导出来
local arrRecordReportH5Show = {} --记录是否已经上报H5icon show 的埋点
local needReportCache = {}


local ARDressBtnAnimations = ComplexAnimatorFactory:newScreenEdgeDrawerAnimator();

function MiniLobbyFrameARDressBtn_OnClick()
	ARDressBtnAnimations:start();
	if getglobal("MiniLobbyFrameARDressDiamondBtnRedTag"):IsShown() then
		getglobal("MiniLobbyFrameARDressDiamondBtnRedTag"):Hide();
		setkv("firstTimeToShowARDressBtn", true);
	end
	if ARDressBtnAnimations.m_bVisible then
		OpenARDressFrame()
	end
end

--打开星装扮页面
function OpenARDressFrame()
	  -- ShopARDressGuide
	  if not if_open_ar_factory() then
        ShowGameTips(GetS(100264))
        return
    end

	GetInst("ShopDataManager"):InitSkinPartDefs();
	GetInst("ShopDataManager"):InitSkinSeatInfos();

	local shopCustomSkinLibParam = {
		tabType = 2,
	}
	-- 第三个标签：定制
	ShopJumpTabView(3, 0, shopCustomSkinLibParam)

	GetInst("UIManager"):Open("ShopARFactory");

	local ShopARFactoryCtrl = GetInst("UIManager"):GetCtrl("ShopARFactory");
    ShopARFactoryCtrl:DeepLink()
end

function MiniLobbyFrameTopMiniBean_OnClick()
    --[[
    if IsStandAloneMode() then return end
    if getglobal("BeanConvertFrame"):IsShown() then
        getglobal("BeanConvertFrame"):Hide();
    else
        getglobal("BeanConvertFrame"):Show();
    end

	]]-- liya

	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "MiniBeanTopUp", "click") --mark by hfb for new minilobby 原大厅，新埋点
    JumpToBeanConvertFrame()
	
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyMiniBeanBtn");
end

function MiniLobbyFrameTopMiniCoin_OnClick()
    --[[
    if IsStandAloneMode() then return end

    --luoshun 判断是否绑定邮箱
    --getglobal("MiniLobbyFrameBirthSelect"):Show();

    if if_check_bind_email_recharge() and AccountManager.hasBindedEmail then
        local result = AccountManager:hasBindedEmail();
        if result == 0 then
            --未绑定邮箱
            -- getglobal("BindingPhoneEmailFrame"):Show();
            print("luoshun BindingPhoneEmailFrame hasBindedEmail: ", result);
            OpenNewAlertPhoneBindPanel("Email", "Bind")
        elseif result == -1 then
            --无法获取到信息
            print("BindingPhoneEmailFrame hasBindedEmail: ", result);
            -- Log("BindingPhoneEmailFrame 无法获取到信息");
        elseif result == 1 then
            --已绑定邮箱
            print("BindingPhoneEmailFrame hasBindedEmail: ", result);
            -- Log("BindingPhoneEmailFrame 已绑定邮箱");
        end
    end

    --新商城
        ShopJumpTabView(7);
	]]-- liya
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "MiniCoinTopUp", "click") --mark by hfb for new minilobby 原大厅，新埋点
    JumpToMiniCoinRechargeFrame()

	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyMiniCoinBtn");

end

function MiniLobbyFrameTopSetting_OnClick()
    --[[
    -- if true then
    --     GetInst("UIManager"):Open("MiniLobbyEx")
    --     return
    -- end
    GongNengFrameSetGNBtn_OnClick();
    -- PerformanceTest:printGlobalFunctionCallCount();
	]]-- liya

	-- if NewbieGuideManager then
	-- 	NewbieGuideManager:RequestSelectSkinPlay()
	-- end

	-- LoginManager:NotifyCustomEvent(LoginManager.EVENT_OPEN_ACCOUNT_UPGRADE, {mainType = 1, subType = "MinilobbySetting"})

	-- LoginManager:InnerLoginLogic("first_login")
	-- do
	-- 	-- g_returnToLoginFrame()   
	-- 	AccountManager:force_quit_game(ErrorCode.FORCE_QUIT_CODE_PASS_MODIFY)
	-- 	MessageBox(24, GetS(9163), nil)	
	-- 	return
	-- end
	local redIsShow = getglobal('MiniLobbyFrameTopSetting'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Setting", "click", eventTab) --mark by hfb for new minilobby 原大厅，新埋点
    JumpToSettingFrame()

	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbySettingBtn");
	if get_game_env() == 1 then --为了方便测试，测试环境清理下组队引导
	end 
end

function MiniLobbyFrameTopMail_OnClick()
	JumpToMessageCenter()

	local redIsShow = getglobal('MiniLobbyFrameTopMailRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Email", "click", eventTab) --mark by hfb for new minilobby 原大厅，新埋点
    
    
    -- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyMailBtn");
	--新增埋点
	-- statisticsGameEventNew(1201,"","",1,"","",tostring(get_game_lang()))
	
end

function MiniLobbyFrameTopActivity_OnClick()
    --[[
    -- local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
    -- print(debug.traceback());
    --默认打开公告
    --getglobal("ReplayTheaterFrame"):Hide();
    if IsStandAloneMode() then return end

    local noticeFrame = getglobal("SiftFrame");
    if noticeFrame:IsShown() then
        --opened
    else
        if ActivityMainCtrl.def and ActivityMainCtrl.def.type then
            ActivityMainCtrl:Active(ActivityMainCtrl.def.type.sift,false)
        end 
    end

    -- luoshun 从OPPO和VIVO游戏中心启动游戏时给予奖励
    if ClientMgr.getApiId then
        local apiId = ClientMgr:getApiId();
        if (apiId == 13 or apiId == 36 or apiId == 12) and SdkManager:isSdkToStartGame() or (apiId == 21 and openYybUrlToGetgift) then
            WWW_ma_start_game_out(apiId)
        end
    end
	]]-- liya
	local redIsShow = getglobal('MiniLobbyFrameTopActivityRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Activity", "click", eventTab) --mark by hfb for new minilobby 原大厅，新埋点
    JumpToActivityFrame()

	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyActivityBtn");
	
end

function MiniLobbyFrameTopGift_OnClick()
    --[[
    if IsStandAloneMode() then return end
    --前往礼包页面
    ShopJumpTabView(9, 1)
    ]]-- liya
    JumpToGiftFrame()

	--数据埋点
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyGiftPackBtn");
end

function MiniLobbyFrameTopQQBlueVipBtn_OnClick()
	if ClientMgr:isPC() then
		ShowVipQQFrame();
	else
		if isQQBlueVipBtnLongPressing then
			isQQBlueVipBtnLongPressing = false;
		else
			ShowVipQQFrame();
		end
	end
	local eventTab = {standby2 =  0}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Privilege", "click", eventTab)
end

function MiniLobbyFrameTopQQBlueVipBtn_OnMouseEnter()
	if ClientMgr:isPC() then
		getglobal("VipQQBtnTipsPC"):Show();
	end
end

function MiniLobbyFrameTopQQBlueVipBtn_OnMouseLeave()
	if ClientMgr:isPC() then
		getglobal("VipQQBtnTipsPC"):Hide();
	end
end

function MiniLobbyFrameQQBlueVipBtn_OnMouseDown()
	isQQBlueVipBtnLongPressing = false;
end

function MiniLobbyFrameQQBlueVipBtn_MouseDownUpdate()
	if arg1 > 0.7 and (not isQQBlueVipBtnLongPressing) then
		isQQBlueVipBtnLongPressing = true;
		getglobal("VipQQHelpTipsMobile"):Show();
	end
end

function ShowGuanBanFuliBtnAndRedFlags()
    --[[
	if ns_ma.server_ma_apiid1 and ns_ma.server_ma_apiid1[1] and ns_ma.reward_list and next(ns_ma.reward_list) then

		if iOSShouQConfig(8,false) or (isAndroidShouQ() and ns_version.qqvip and ns_version.qqvip.open and ns_version.qqvip.open == 1) then
			getglobal("MiniLobbyFrameTopGuanBanFuliBtn"):Hide()
		else
			getglobal("MiniLobbyFrameTopGuanBanFuliBtn"):Show()
		end
		for k = 1,2 do
			local item_data = ns_ma.server_ma_apiid1[k]
			if item_data == nil then
				break
			end
			for kk = 1,#item_data do
				local r_item = ns_ma.reward_list[item_data[kk].id]
				if r_item and r_item.stat == 1 then
					getglobal("MiniLobbyFrameTopGuanBanFuliBtnRedTag"):Show()
					return
				end
			end
		end
		getglobal("MiniLobbyFrameTopGuanBanFuliBtnRedTag"):Hide()
    end
    ]]-- liya
    SetGuanBanFuliBtnAndRedFlagsShown()
end

function ReportGuanBanEvent()
	if getglobal("MiniLobbyFrameTopGuanBanFuliBtn"):IsShown() then
		--添加特权埋点
		local redTag = getglobal("MiniLobbyFrameTopGuanBanFuliBtnRedTag")
		local eventTab = {standby2 = (redTag:IsShown() and 1 or 0)}
		MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Privilege", "view", eventTab)
	end
end

--显示QQ相关渠道特权按钮
function ReportQQEvent()
	if isQQGame() or ClientMgr:getApiId() == 109 then  --qq大厅渠道
		local eventTab = {standby2 =  0}
		MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Privilege", "view", eventTab)
	end
end


function MiniLobbyFrameTopGuanBanFuliBtn_OnClick()
    --[[
    if IsStandAloneMode() then return end
    GetInst("UIManager"):Open("OfficialRewardCenter")
    ]]-- liya
    JumpToGuanBanFuliFrame()
	local redIsShow = isEnableNewMiniLobby() and getglobal('MiniLobbyExTopGuanBanFuliBtnRedTag'):IsShown() or getglobal('MiniLobbyFrameTopGuanBanFuliBtnRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Privilege", "click", eventTab)
end

-- 迷你点商城入口
function MiniLobbyFrameTopMiniPointBtn_OnClick()
	ShopJumpTabView(11,1)

	--数据埋点
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyPointPackBtn");
end

--7k7k
function MiniLobbyFrameTop7k7kBlueVipBtn_OnClick()
	if ClientMgr:isPC() then
		ShowVip7k7kFrame();
	else
		
	end
end

function MiniLobbyFrameTop7k7kBlueVipBtn_OnMouseEnter()
	if ClientMgr:isPC() then
		getglobal("Vip7k7kBtnTipsPC"):Show();
	end
end

function MiniLobbyFrameTop7k7kBlueVipBtn_OnMouseLeave()
	if ClientMgr:isPC() then
		getglobal("Vip7k7kBtnTipsPC"):Hide();
	end
end

function MiniLobbyFrame7k7kBlueVipBtn_OnMouseDown()
	is7k7kBlueVipBtnLongPressing = false;
end

function MiniLobbyFrame7k7kBlueVipBtn_MouseDownUpdate()
	if arg1 > 0.7 and (not is7k7kBlueVipBtnLongPressing) then
		is7k7kBlueVipBtnLongPressing = true;
		--getglobal("VipQQHelpTipsMobile"):Show();
	end
end
-------------------------------------------QQ会员----------------------------------------------------
WaitQQUserInfo = false;
WaitQQLoginResult = 0;	--0等待登录返回 1登录失败 2登录成功
WaitQQVipRewardState = false;

-- 新版手Q按钮点击事件
function MiniLobbyFrameTopShouqBtn_OnClick()
	if isShouQPlatform() then
		-- 新版手Q渠道 56
		local redTag = getglobal("MiniLobbyFrameTopShouqBtnRedTag");
		if redTag:IsShown() then
			redTag:Hide();
        end
        --[[
        local shouq_config = ns_version.qqvip
        if shouq_config and shouq_config.open == 1 then
            local url = shouq_config.action_url;
            open_http_link(url);
        end
        ]]-- liya
		JumpToShouQLink()
	elseif isIOSShouQ() then
		local centerTextObj = getglobal("MessageBoxFrame2Desc")
		centerTextObj:setCenterLine(true)
		MessageBoxFrame2:Open(4, GetS(35213), GetS(35225),
				function(btn)
					if btn == "right" then
						BindingQQBtn_OnClick();
					end
					centerTextObj:setCenterLine(false)
				end)

	end
end

function MiniLobbyFrameTopQQVipBtn_OnClick()
    getglobal("MiniLobbyFrameTopQQVipBtnRedTag"):Hide();
    JumpToQQVIPFrame()
    --[[
    if not AccountManager:getNoviceGuideState("qqvip") then
        AccountManager:setNoviceGuideState("qqvip", true);
    end

    if next(vip.QQUserInfo) == nil then	--没有会员信息
        getglobal("LoadLoopFrame3"):Show();
        WaitQQUserInfo = true;
        WaitQQLoginResult = 0;
        WaitQQVipRewardState = true;
        local index = 0;
        if not SdkManager:checkQQLogin() then	--没登录	
            for i=1, 10 do
                index = i;
                if WaitQQLoginResult > 0 then
                    if WaitQQLoginResult == 1 then		--登录失败
                        Log("kekeke QQLogin is fail");
                        ShowGameTips(GetS(1166), 3);
                        ShowVipQQFrame();
                        getglobal("LoadLoopFrame3"):Hide();
                        return;
                    else
                        break;
                    end
                end
                threadpool:wait(0.5);
            end
        end
        Log("kekeke QQLogin success:"..index);
        index = 0;
        for i=1, 10 do							--等用户信息
            index = i;
            if not WaitQQUserInfo then
                break;
            end
            threadpool:wait(0.5);
        end
    
        Log("kekeke QQUesrinfo success:"..index);

        if next(vip.QQUserInfo) == nil then	--还是没有会员信息
            ShowGameTips(GetS(1166), 3);
            Log("kekeke QQUesrinfo is nil");
        else
            Log("kekeke Vip is_qq_vip:"..vip.QQUserInfo.is_qq_vip);
            Log("kekeke Vip is_qq_year_vip:"..vip.QQUserInfo.is_qq_year_vip);
            Log("kekeke Vip is_svip:"..vip.QQUserInfo.is_svip);
    
            index = 0;
            if vip.isQQVip then 
                for i=1, 3 do					--等待奖励状态结果
                    index = i;
                    if not WaitQQVipRewardState then
                        break;
                    end
                    threadpool:wait(1);
                end
            end
        end

        ShowVipQQFrame();
        getglobal("LoadLoopFrame3"):Hide();
    else
        ShowVipQQFrame();
    end
    ]]-- liya
    
--	ShowVipQQFrame();
end
------------------------------------------------------------------------------------------------------

function MiniLobbyFrameTop4399LoginBtn_OnClick()
    --[[
    if AccountManager:isBindTPAccount() or IsTPLogin() then
        getglobal("Login4399Frame"):Show();
    else
        TP4399LoginType = 1;
        SdkManager:sdkLogin();
    end
    ]]-- liya
    JumpTo4399LoginFrame()
end

-----------------------------------------------------------------------------------------------------

--点击按钮, 则保存当天红点标记, 之后当天不显示红点.
--暂时去掉uin, 因为在onload()函数中获取到的uin==-1
function MiniLobbyFrameTopQQZoneExternalLink_HandleRedTagFlag(bFlag)
	local filename = "QQZoneExternalLinkSaveRedTagFlag";
	local uin = AccountManager:getUin();
	local timestamp = AccountManager:getSvrTime() or os.time();
	local day = math.floor(timestamp / (60 * 60 * 24) );

	Log("MiniLobbyFrameTopQQZoneExternalLink_HandleRedTagFlag:");
	if uin and day then
		filename = filename .. uin;
		Log("filename = " .. filename);
		Log("day = " .. day);
		Log("uin = " .. uin);

		if bFlag then
			Log("Save:");
			container:save_to_file(filename, day);
			getglobal("MiniLobbyFrameTopQQZoneExternalLinkBtnRedTag"):Hide();
		else
			Log("Get:");
			local day_FromFile = container:load_from_file(filename);

			if day_FromFile then
				Log("day_FromFile = " .. day_FromFile);

				if day_FromFile == day then
					--今天已经点击过了, 则不显示红点.
					getglobal("MiniLobbyFrameTopQQZoneExternalLinkBtnRedTag"):Hide();
				else
					--没点击, 需要显示
					getglobal("MiniLobbyFrameTopQQZoneExternalLinkBtnRedTag"):Show();
				end
			else
				getglobal("MiniLobbyFrameTopQQZoneExternalLinkBtnRedTag"):Show();
			end
		end
	end
end

function MiniLobbyFrameTopQQZoneExternalLink_IsShowRedTag()
	Log("MiniLobbyFrameTopQQZoneExternalLink_IsShowRedTag:");
end

-----------------------------------------------------------------------------------------------------
function MiniLobbyFrameTopQQZoneExternalLink_OnClick()
	--qq大厅版跳转连接
	SdkManager:BrowserShowWebpage(ns_version.qq_hall_btn.url);

	--保存红点显示标志
	MiniLobbyFrameTopQQZoneExternalLink_HandleRedTagFlag(true);
end

-----------------------------------------------------------------------------------------------------
function MiniLobbyFrameTopYYBForumBtn_OnClick()
    --[[
    --local print = Android:Localize();
    local apiId = ClientMgr:getApiId();
    local forum_jump = ns_version.forum_jump;
    -- local url = "https://imgcache.qq.com/club/themes/mobile/middle_page/index.html?url=https%3A%2F%2Fqzs.qq.com%2Fopen%2Fmobile%2Ftransfer-page%2Findex.html%3Fid%3D3%26dest%3Dtmast%253A%252F%252Fappdetails%253Fselflink%253D1%2526appid%253D42286397%2526extradata%253Dscene%253Aplayingcard%26via%3DFBI.ACT.H5.TRANSFER3_MARKET_YINGYONGBAO_COM.TENCENT.ANDROID.QQDOWNLOADER_5848_QDTQ";
    print("MiniLobbyFrameTopYYBForumBtn_OnClick(): forum_jump = ", forum_jump);
    if forum_jump and check_apiid_ver_conditions(forum_jump) and forum_jump[apiId] then 
        local url = forum_jump[apiId];
        print("MiniLobbyFrameTopYYBForumBtn_OnClick(): url = ", url);
        http_openBrowserUrl(url, 1)
    else
        SdkManager:sdkForum();
    end
    ]]-- liya
    JumpToYYBForumLink()
end
-----------------------------------------------------------------------------------------------------
function MiniLobbyFrameTopQQBuLuoBtn_OnClick()
    --[[
    if SdkManager:openQQBuLuo() then
        WWW_ma_qq_member_action('nil', 'qq_member_buluo', 1, ns_ma.func.download_callback_empty);
    end
    ]]-- liya
    JumpToQQBuLuo()
end
-----------------------------------------------------------------------------------------------------
function MiniLobbyFrameTopOppoForumBtn_OnClick()
	SdkManager:sdkForum();
end

function MiniLobbyFrameTopVivoForumBtn_OnClick()
	-- SdkManager:BrowserShowWebpage("https://gamembbs.vivo.com.cn/mvc/module?id=316");
	SdkManager:sdkForum()
end
-----------------------------------------------------------------------------------------------------
function UpdateChannelRewardBtn()
    --[[
	-- local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	local apiId = ClientMgr:getApiId()
	local task = ns_ma.server_config_start_game_out;
	-- apiId = 21
	print("UpdateChannelRewardBtn(): task = ", task)
	if task.task_conditions and task.task_conditions.start_game_out and task.task_conditions.start_game_out == apiId then
		if apiId == 13 then --oppo
			getglobal("MiniLobbyFrameTopChannelRewardBtn"):Show();
			getglobal("MiniLobbyFrameTopChannelRewardBtnNormal"):SetTexUV("icon_oppo");
			getglobal("MiniLobbyFrameTopChannelRewardBtnPushedBG"):SetTexUV("icon_oppo");
		elseif apiId == 36 then --vivo
			getglobal("MiniLobbyFrameTopChannelRewardBtn"):Show();
			getglobal("MiniLobbyFrameTopChannelRewardBtnNormal"):SetTexUV("icon_vivo");
			getglobal("MiniLobbyFrameTopChannelRewardBtnPushedBG"):SetTexUV("icon_vivo");
		elseif apiId == 21 then --yyb
			getglobal("MiniLobbyFrameTopChannelRewardBtn"):Show();
			getglobal("MiniLobbyFrameTopChannelRewardBtn"):SetPoint("right", "MiniLobbyFrameTopYYBForumBtn", "left", -14, 0);
			getglobal("MiniLobbyFrameTopChannelRewardBtnNormal"):SetTexUV("icon_tencentappvip");
			getglobal("MiniLobbyFrameTopChannelRewardBtnPushedBG"):SetTexUV("icon_tencentappvip");
		elseif apiId == 12 then --xiaomi
			getglobal("MiniLobbyFrameTopChannelRewardBtn"):Show();
			getglobal("MiniLobbyFrameTopChannelRewardBtnNormal"):SetTexUV("icon_xiaomi");
			getglobal("MiniLobbyFrameTopChannelRewardBtnPushedBG"):SetTexUV("icon_xiaomi");
		else
			return
		end
		ChannelRewardPresenter:requestShowChannelRewardFrame();
    end
    ]]-- liya
    NewUpdateChannelRewardBtn()
end

function MiniLobbyFrameTopChannelRewardBtn_OnClick()
	-- luoshun 从OPPO和VIVO游戏中心启动游戏时给予奖励
    -- statisticsGameEvent(51001);
    --[[
    if ClientMgr.getApiId then
        local apiId = ClientMgr:getApiId();
        if (apiId == 13 or apiId == 36 or apiId == 12) and SdkManager:isSdkToStartGame() or (apiId == 21 and openYybUrlToGetgift) then
            WWW_ma_start_game_out(apiId)
        end
    end

    getglobal("ChannelRewardFrame"):Show();
	]]-- liya
	-- add by wangyang event standby2 redTag
	local redIsShow = getglobal('MiniLobbyFrameTopChannelRewardBtnRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Privilege", "click", eventTab) --mark by hfb for new minilobby 原大厅，新埋点
    JumpToChannelReward()
	-- statisticsGameEvent(51003);
	
end
-------------------------------------------------------Center-----------------------------------------
function MiniLobbyFrameCenterLocalMap_OnClick()
    Log999( "call MiniLobbyFrameCenterLocalMap_OnClick" )
    --[[
    checkS2tAuth();

    if CreateMapGuideStep == 1 then
        CreateMapGuideStep = 2;
    end
    --新手强制引导结束
    local guideStep = GetGuideStep()
    if guideStep == 7 then 
        SetGuideStep(nil)
    end 
    -- getglobal("MiniLobbyFrame"):Hide();
    HideMiniLobby() --mark by hfb for new minilobby
    ShowLobby();
	]]-- liya
	-- ReportTraceidMgr:setTraceid("startgame")
	if getglobal("MiniLobbyFrameCenterLocalMapFinger"):IsShown() then
		standReportEvent("40", "NEWPLAYER_FILEPAGE_GUIDE", "StartGame", "click");
	end
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_MAINFUNCTION_1", "StartGame", "click") --mark by hfb for new minilobby 原大厅，新埋点
    JumpToLocalMap()
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyLocalMapBtn");
end

function MiniLobbyFrameCenterLocalMap_OnMouseDown()
	getglobal("MiniLobbyFrameCenterLocalMapPic"):SetSize(465, 510);
	getglobal("MiniLobbyFrameCenterLocalMapView"):SetSize(462, 510);
end

function MiniLobbyFrameCenterLocalMap_OnMouseUp()
	getglobal("MiniLobbyFrameCenterLocalMapPic"):SetSize(465, 517);
	getglobal("MiniLobbyFrameCenterLocalMapView"):SetSize(462, 517);
end

function MiniLobbyFrameCenterMultiplayer_OnClick()
    --[[
    if IsStandAloneMode() then return end
    checkS2tAuth();
    RequestLoginRoomServer();
	]]-- liya
	-- 联机大厅
	ReportTraceidMgr:setTraceid("lobby")
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_MAINFUNCTION_1", "MutiplayerLobby", "click") --mark by hfb for new minilobby 原大厅，新埋点
    JumpToMultiplayer()
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyMultiplayerBtn");
	--快手推荐相关需求，非从推荐页进的联机大厅，清除维护的一个状态
	GetInst("ExternalRecommendMgr"):ClearJumpRoomFrameInfo()
	local adsType = RealNameFunc and RealNameFunc.isShowIdentityNameAuth and RealNameFunc:isShowIdentityNameAuth(3)
	if adsType then
		ShowIdentityNameAuthFrame(nil,nil,nil,nil,nil,adsType)
	end

	if NewbieGuideManager and NewbieGuideManager:IsABSwitchV13() and bolOnlineHallGuide == true then
		-- 关闭新手联机大厅指引
		bolOnlineHallGuide = false
		getglobal("MiniLobbyFrameNewGuide"):Hide()
		standReportEvent("3901", "NEWPLAYER_GUIDE_TAP", "Tap", "click")

	end

end

t_client_info = {};
local IsStartCollcectionOverseasNetWorkInfo = false;
function OverseasNetworkInformationCollection(ip,delay)
	Log("Collect Overseas Network Information");

	local roomip = "";
	local mapip = "";
	local friendip = "";
	local accountip = "";
	if CSMgr.getResolveDnsInfo then 
		roomip = CSMgr:getResolveDnsInfo("hwopenroom.mini1.cn");
		mapip = CSMgr:getResolveDnsInfo("hwshequ.mini1.cn");
		friendip = CSMgr:getResolveDnsInfo("hwfriend.mini1.cn");
		accountip = CSMgr:getResolveDnsInfo("hwacchm.mini1.cn");
	else
		Log("CSMgr.getResolveDnsInfo is nil");
	end

	local room_ping = ReceiveRoomPakcageTime - SendPackageTime;
	if room_ping < 0 then
		room_ping = 0;
	end
	local friend_ping = ReceiveFriendPakcageTime - SendPackageTime;
	if friend_ping < 0 then
		friend_ping = 0;
	end
	t_client_info = 
	{
		local_ip = ip,
		ip_list = 
		{
			openroom=
			{
				ip = roomip,
				ping = room_ping
			},
			map=
			{
				ip = mapip,
				ping = 666
			},
			friend=
			{
				ip = friendip,
				ping = friend_ping
			},
			acchm=
			{
				ip = accountip,
				ping = delay
			}
		}
	};
	t_client_info.Operator_NetworkType =gFunc_getOperatorAndNetworkType();
	if Android:IsBlockArt() then	--海外谷歌安卓
		t_client_info.area = get_game_country();
		t_client_info.system = "android";
	elseif ClientMgr:getApiId() == 345 or ClientMgr:getApiId() == 346 then --海外苹果ios
		t_client_info.area = get_game_country();
		t_client_info.system = "ios";
	else									--海外官方pc，steam pc
		if ClientMgr.getCountryFromIpAddress == nil then t_client_info.area = ""
		else t_client_info.area = ClientMgr:getCountryFromIpAddress(t_client_info.local_ip) end
		t_client_info.system = "windows";
	end
	IsStartCollcectionOverseasNetWorkInfo = true;

	if AccountManager.on_network_status_calllback then
		AccountManager:on_network_status_calllback(client_info);
	else
		print("AccountManager.on_network_status_calllback failed",3);
	end

	--if if_test_route_info() then
		--TraceRouteInfoTest(t_client_info);
	--end
end

t_traceRoute = {};
local traceRouteRoomIsEnd = false;
local traceRouteMapIsEnd = false;
local traceRouteFriendIsEnd = false;
local traceRouteAccountIsEnd = false;

function OnTraceRouteInfoResult(index,info)
	if index == 0 then
		t_traceRoute.room =loadstring("return ".. info)();
		traceRouteRoomIsEnd = true;
	elseif index == 1 then
		t_traceRoute.map = loadstring("return ".. info)();
		traceRouteMapIsEnd = true;
	elseif index == 2 then
		t_traceRoute.friend = loadstring("return ".. info)();
		traceRouteFriendIsEnd = true;
	elseif index == 3 then
		t_traceRoute.account = loadstring("return ".. info)();
		traceRouteAccountIsEnd = true;
	end
end

local traceRouteIsEnd =false;
function TraceRouteInfoStart()
	traceRouteIsEnd =false;
	if IsStartCollcectionOverseasNetWorkInfo then
		if ClientMgr.StartTraceRouteInfo then
			local t_traceRoomInfo = {};
			threadpool:work(function ()
				ClientMgr:StartTraceRouteInfo(t_client_info.ip_list.openroom.ip,t_client_info.ip_list.map.ip,t_client_info.ip_list.friend.ip,t_client_info.ip_list.acchm.ip);
				for i=0,72 do
					if traceRouteRoomIsEnd == true and traceRouteMapIsEnd == true and traceRouteFriendIsEnd == true and  traceRouteAccountIsEnd == true then
						
						if ClientMgr.EndTraceRoute then
							ClientMgr:EndTraceRoute();
						end
						traceRouteIsEnd = true;
						break;
					else
						threadpool:wait(5);
					end
				end
				
				traceRouteRoomIsEnd = false;
				traceRouteMapIsEnd = false;
				traceRouteFriendIsEnd = false;
				traceRouteAccountIsEnd = false;
				
				print("----EndTraceRoute----");
			end);

		else
			print("ClientMgr.StartTraceRouteInfo is nil")
		end
	else
		print("---Insufficient collection condition---");
	end
end

function QueryTraceRouteResult()
	if traceRouteIsEnd and t_traceRoute and next(t_traceRoute) ~= nil then
		return t_traceRoute;
	else
		return {};
	end
end
--[[

function TraceRouteInfoTest(client_info)
	Log("-----TraceRouteInfoTest-----")
	if ClientMgr.StartTraceRouteInfo then
		local t_traceRoomInfo = {};
		threadpool:work(function ()
			ClientMgr:StartTraceRouteInfo(client_info.ip_list.openroom.ip,client_info.ip_list.map.ip,client_info.ip_list.friend.ip,client_info.ip_list.acchm.ip);
			for i=0,72 do
				if traceRouteRoomIsEnd == true and traceRouteMapIsEnd == true and traceRouteFriendIsEnd == true and  traceRouteAccountIsEnd == true then
					Log("----EndTraceRoute----");
					client_info.traceroute = t_traceRoute;
					if ClientMgr.EndTraceRoute then
						ClientMgr:EndTraceRoute();
					end
					break;
				else
					threadpool:wait(5);
				end
			end
			if AccountManager.on_network_status_calllback then
				AccountManager:on_network_status_calllback(client_info);
			else
				ShowGameTips("AccountManager.on_network_status_calllback failed",3);
			end
			traceRouteRoomIsEnd = false;
			traceRouteMapIsEnd = false;
			traceRouteFriendIsEnd = false;
			traceRouteAccountIsEnd = false;
		end);
	else
		ShowGameTips("get trace route info is nil",3);
	end
end
--]]



function RequestLoginRoomServer(params)
	-- 下面这一行不要删除，加载xml和异步网络请求回来的event会出现偶发bug
	local frame = getglobal("MultiplayerLobbyFrame")
	local roomframe = getglobal("RoomFrame")
	if ClientMgr:isMobile() and CheckHasCrackTools() then  --安装了破解软件，禁止联机
		return;
	end

	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3);
		return;
	end
	
	--新增审核账号禁止联机功能，但审核开发者广告的仍可联机
	local checker_uin = AccountManager:getUin()
	if IsUserOuterChecker(checker_uin) and not DeveloperAdCheckerUser(checker_uin) then
		ShowGameTips(GetS(100300), 3);
		return;
	end

	RoomFrameRequestLoginRoomServer(params);
end

function MiniLobbyFrameCenterMultiplayer_OnMouseDown()
	getglobal("MiniLobbyFrameCenterMultiplayerPic"):SetSize(356, 510);
	getglobal("MiniLobbyFrameCenterMultiplayerView"):SetSize(352, 493);
end

function MiniLobbyFrameCenterMultiplayer_OnMouseUp()
	getglobal("MiniLobbyFrameCenterMultiplayerPic"):SetSize(356, 517);
	getglobal("MiniLobbyFrameCenterMultiplayerView"):SetSize(352, 500);
end

function MiniLobbyFrameCenterMiniWorksBtnGuide_OnLoad()
	this:setUpdateTime(0.05);
end

local FingerScale = 1;
local ScaleSpeed = 0.1;
function MiniLobbyFrameCenterMiniWorksBtnGuide_OnUpdate()
	FingerScale = FingerScale + ScaleSpeed;
	if FingerScale > 1.3 then
		FingerScale = 1.3;
		ScaleSpeed = -0.05;
	elseif FingerScale < 1.0 then
		FingerScale = 1.0;
		ScaleSpeed = 0.05;
	end
	local width = 100 * FingerScale;
	local height = 100 * FingerScale;
	getglobal("MiniLobbyFrameCenterMiniWorksGuideFinger"):SetSize(width, height);
end

function MiniLobbyFrameCenterMiniWorks_OnClick()
    --[[
    if IsStandAloneMode() then return end

    -- 如果联机房的倒计时还在，关闭它
    if HasUIFrame("RoomFrameTimer") then
        getglobal("RoomFrameTimer"):Hide()
    end

    -- getglobal("MiniLobbyFrame"):Hide();
    HideMiniLobby() --mark by hfb for new minilobby
    if not getglobal("MiniWorksFrame"):IsShown() then
        getglobal("MiniWorksFrame"):Show();
        if WorksArchiveMsgCheck.isdetail then
            GetInst("UIManager"):Open("MiniWorksCommendDetail", {commendtype = WorksArchiveMsgCheck.CommendType})
            ShowMiniWorksMainDetail(true)
            WorksArchiveMsgCheck.isdetail = false
        elseif HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
            ShowMiniWorksMainDetail(true)
        end
    end
    ]]-- liya
    
    ReqCollectMaps()
    
	ReportTraceidMgr:setTraceid("workshop")
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_MAINFUNCTION_1", "WorkShop", "click") --mark by hfb for new minilobby 原大厅，新埋点
	
    JumpToMiniWorks()    

    --统计
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyMiniWorksBtn");

	local adsType = RealNameFunc and RealNameFunc.isShowIdentityNameAuth and RealNameFunc:isShowIdentityNameAuth(4)
	if adsType then
		ShowIdentityNameAuthFrame(nil,nil,nil,nil,nil,adsType)
	end
	
end

function MiniLobbyFrameCenterMiniWorks_OnMouseDown()
	getglobal("MiniLobbyFrameCenterMiniWorksPic"):SetSize(363, 260);
	local btn = getglobal("MiniLobbyFrameCenterResourceShopBt")
	if btn then
		btn:SetPoint("topright", "MiniLobbyFrameCenterMiniWorks", "topright", -20, 7)
	end
end

function MiniLobbyFrameCenterMiniWorks_OnMouseUp()
	getglobal("MiniLobbyFrameCenterMiniWorksPic"):SetSize(363, 267);
	local btn = getglobal("MiniLobbyFrameCenterResourceShopBt")
	if btn then
		btn:SetPoint("topright", "MiniLobbyFrameCenterMiniWorks", "topright", -20, 0)
	end
end

function MiniLobbyFrameCenterHomeChest_OnClick()
	ReportTraceidMgr:setTraceid("homeland")
	local redIsShow = getglobal('MiniLobbyFrameCenterHomeChestRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_MAINFUNCTION_1", "MyHomeland", "click", eventTab) --mark by hfb for new minilobby 原大厅，新埋点
    standReportGameOpenParam = {
		sceneid="9999",
		cardid="MINI_HOMEPAGE_MAINFUNCTION_1",
		compid="MyHomeland", 
	}
	GetInst("ReportGameDataManager"):NewGameLoadParam("9999","MINI_HOMEPAGE_MAINFUNCTION_1","MyHomeland")
	GetInst("ReportGameDataManager"):SetGameMapMode(GetInst("ReportGameDataManager"):GetDefineGameModeType().homeland)
	if GetInst("CreditScoreModel"):GetCreditScore()<100 then
		GetInst("CreditScoreService"):InitReq()
	end

	if IsEnableHomeLand and IsEnableHomeLand() then
		local callback = function()
			threadpool:notify("newpalyer.showauthbox")
		end
		local adsType = RealNameFunc and RealNameFunc.isShowIdentityNameAuth and RealNameFunc:isShowIdentityNameAuth(5)
		if adsType then
			if ShowIdentityNameAuthFrame(nil,nil,nil,callback,callback,adsType) then
				threadpool:wait("newpalyer.showauthbox")
			end
		end
        -- 家园地图
		EnterOwnHomeLand()

    else
        JumpToHomeChest() --家园果实
    end

	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyHomeChestBtn");
end

function JumpToOppoGameCenter(btn)
	if btn == "left" and ClientMgr and ClientMgr.jumpToOppoGameCenter then 
		ClientMgr:jumpToOppoGameCenter();
	end
end

function MiniLobbyFrameCenterHomeChest_OnMouseDown()
	getglobal("MiniLobbyFrameCenterHomeChestPic"):SetSize(363, 258);
end

function MiniLobbyFrameCenterHomeChest_OnMouseUp()
	getglobal("MiniLobbyFrameCenterHomeChestPic"):SetSize(363, 265);
end

local onNetworkState = nil
local state = 1
function OnNetwork(networkState)
	state = networkState or 1;
	onNetworkState = networkState
end

function GetNetworkState()
	if IsStandAloneMode("") then return 0 end
	--获取网卡状态 0异常 
	if onNetworkState then return state end
	local networkCardState = ClientMgr and ClientMgr.getNetworkState and ClientMgr:getNetworkState() or 1;
	if networkCardState == nil then
        state = 1;
		return 1;
	else
        state = networkCardState;
		return networkCardState;
	end
end

--刷新网络信号
function UpdateNetworkSignal()
	if gNetworkFlag then return end
	gNetworkFlag = true

	--改成计时器的方式刷新
	local network_refresh_func = function()
		--主页面
		local LobbyNetworkBkg = getglobal("MiniLobbyFrameBottomNetworkBkg")
		local LobbyNetworkText = getglobal("MiniLobbyFrameBottomNetworkText")

		--断网提示按钮
		local LobbyNoNetworkHintBt = getglobal("MiniLobbyFrameBottomNoNetworkHint")
		local LobbyNoNetworkHintTx = getglobal("MiniLobbyFrameBottomNoNetworkHintText")
		
		--创意工坊
		local MiniWorksNetworkBkg = getglobal("MiniWorksFrameTopNetworkNetworkWifi")
		local MiniWorksNetworkStateText = getglobal("MiniWorksFrameStateText")
		local MiniWorksNoNetworkHintTx = getglobal("MiniWorksFrameNoNetworkHintText");

		--商城
		local ShopWorkNetworkBkg = getglobal("ShopworkNetworkWifi")
		-- 好友
		local FriendWorkNetworkBkg = getglobal("FriendFrameworkNetworkWifi")
		-- 联机大厅
		local RoomWorkNetworkBkg = getglobal("RoomFrameworkNetworkWifi")
		-- 个人信息
		local PlayerWorkNetworkBkg = getglobal("PlayerExhibitionCenterworkNetworkWifi")

		-- 新Fgui首页
		local mainNode = GetInst("MiniUIManager"):GetUI("mainAutoGen")
		local mainWifi
		if mainNode and mainNode.ctrl then
			mainWifi = mainNode.ctrl.view.root:getChild("icon_wifi")
		end

		-- 获取网络强度
		net_work_power = ClientMgr and ClientMgr.getNetworkSignal and ClientMgr:getNetworkSignal() or 0;
		local isNoNetwork = GetNetworkState();
		
		if (isNoNetwork == 1 or isNoNetwork == 2) and net_work_power ~= 0 then	
			--3最强 0网络异常
			if net_work_power == 3 then
				isOffNetworkHint = true;
				
				LobbyNetworkBkg:SetTexUV("icon_wifi_green");
				MiniWorksNetworkBkg:SetTexUV("icon_wifi_green");
				ShopWorkNetworkBkg:SetTexUV("icon_wifi_green");
				FriendWorkNetworkBkg:SetTexUV("icon_wifi_green");
				RoomWorkNetworkBkg:SetTexUV("icon_wifi_green");
				PlayerWorkNetworkBkg:SetTexUV("icon_wifi_green");
				if mainWifi then
					mainWifi:getController("tpSelect"):setSelectedIndex(0)
				end
				
				MiniWorksNoNetworkHintTx:Hide();
				LobbyNoNetworkHintBt:Hide();
				LobbyNoNetworkHintTx:Hide();
				UpdateMiniWorksStateFrame();
			elseif net_work_power == 2 then	
				isOffNetworkHint = true;
				
				LobbyNetworkBkg:SetTexUV("icon_wifi_orange");
				MiniWorksNetworkBkg:SetTexUV("icon_wifi_orange");
				ShopWorkNetworkBkg:SetTexUV("icon_wifi_orange");
				FriendWorkNetworkBkg:SetTexUV("icon_wifi_orange");
				RoomWorkNetworkBkg:SetTexUV("icon_wifi_orange");
				PlayerWorkNetworkBkg:SetTexUV("icon_wifi_orange");
				if mainWifi then
					mainWifi:getController("tpSelect"):setSelectedIndex(1)
				end
			
				MiniWorksNoNetworkHintTx:Hide();
				LobbyNoNetworkHintBt:Hide();
				LobbyNoNetworkHintTx:Hide();
				UpdateMiniWorksStateFrame();
			elseif net_work_power == 1 then
				isOffNetworkHint = true;

				LobbyNetworkBkg:SetTexUV("icon_wifi_red");
				MiniWorksNetworkBkg:SetTexUV("icon_wifi_red");
				ShopWorkNetworkBkg:SetTexUV("icon_wifi_red");
				FriendWorkNetworkBkg:SetTexUV("icon_wifi_red");
				RoomWorkNetworkBkg:SetTexUV("icon_wifi_red");
				PlayerWorkNetworkBkg:SetTexUV("icon_wifi_red");
				if mainWifi then
					mainWifi:getController("tpSelect"):setSelectedIndex(2)
				end
				
				MiniWorksNoNetworkHintTx:Hide();
				LobbyNoNetworkHintBt:Hide();
				LobbyNoNetworkHintTx:Hide();
				UpdateMiniWorksStateFrame();
			end
		else
			LobbyNetworkBkg:SetTexUV("aaa_icon_wifi_1");
			MiniWorksNetworkBkg:SetTexUV("aaa_icon_wifi_1");
			ShopWorkNetworkBkg:SetTexUV("aaa_icon_wifi_1");
			FriendWorkNetworkBkg:SetTexUV("aaa_icon_wifi_1");
			RoomWorkNetworkBkg:SetTexUV("aaa_icon_wifi_1");
			PlayerWorkNetworkBkg:SetTexUV("aaa_icon_wifi_1");
			if mainWifi then
				mainWifi:getController("tpSelect"):setSelectedIndex(3)
			end
			
			MiniWorksNetworkStateText:SetText(GetS(7323));
			LobbyNoNetworkHintBt:Hide();
			LobbyNoNetworkHintTx:Hide();
					
			if isOffNetworkHint and not IsStandAloneMode("") then
				LobbyNoNetworkHintBt:Show();
				LobbyNoNetworkHintTx:Show();
				
				local lnnhText = GetS(7321);
				LobbyNoNetworkHintTx:SetText(lnnhText, 0, 0, 0);
				LobbyNoNetworkHintTx:ScrollFirst();	
			end

			if IsStandAloneMode("") then
				LobbyNetworkText:Show()
				LobbyNetworkBkg:Hide()
			else
				LobbyNetworkText:Hide()
				LobbyNetworkBkg:Show()
			end
		end
	end

	threadpool:timer(2592000, 10, network_refresh_func)
end

------------------------------------------------------Bottom---------------------------------------------
local MiniLobbyFrameBottomShrink = false;
function MiniLobbyFrameBottomShrink_OnClick()
	if MiniLobbyFrameBottomShrink then
		MiniLobbyFrameBottomShrink = false;
	else
		MiniLobbyFrameBottomShrink = true;
	end
	UpdateBottomBtnState()

	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyShrinkBtn");
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_BOTTOM_1", "WiFiCheck", "click") --mark by hfb for new minilobby 原大厅，新埋点
	-- GetInst("UIManager"):Open("BrowserTest");


	-- 网络状态提示
	local networkState = GetNetworkState()
	-- if IsStandAloneMode("") then
	-- 	ChangeStandAloneMode(false)
	-- else
		-- 去除单机模式
		if (networkState == 1 or networkState == 2) and net_work_power ~= 0 then
			if net_work_power == 3 then
				ShowGameTips(GetS(25836))
			elseif net_work_power == 2 then
				ShowGameTips(GetS(25837))
			else
				ShowGameTips(GetS(25838))
			end
		-- else
		-- 	MessageBox(5,GetS(25834),function(str)
		-- 		if str == "left" then
		-- 			ChangeStandAloneMode(true)
		-- 		end
		-- 	end)
		end
	-- end
end

local clickwifisupport = true
function MiniLobbyFrameBottomShrink_OnClick2()	
	Log("MiniLobbyFrameBottomShrink_OnClick2");
	---ShowGameTips("testgjd")
	if IsOverseasVer()  or Android:IsBlockArt() then
		if clickwifisupport == true then
			local uin = AccountManager:getUin() or get_default_uin()
			local country = get_game_country()
			local version = ClientMgr:clientVersionStr()
			local apild = ClientMgr:getApiId()
			local ip_list = CSMgr:getDNSStaticsStr() -- {room="123.23.36.6",proxy="123.23.36.6",acc_proxy="",friend="",mail="",}
			ip_list = gFunc_urlEscape(ip_list)
			local conn = loadwwwcache('conn') or '0'
			conn = gFunc_urlEscape(conn)			
			local function  CreateWiftUrl(_path)

				local builder = {
					url =  _path,
					authparams = nil,			
					addparam = function(self, name, value)
						if value == nil then
							return self
						end			
						local param = tostring(name) .. '=' .. value	
						
						if self.authparams then
							self.authparams = self.authparams .. '&' .. param
						else
							self.authparams = param
						end
			
						return self
					end,
			
					finish = function(self)
						if self.authparams then
							self.url = self.url .. '?' .. self.authparams
						end
						return self.url
					end,
				};
			
				return builder;
			end 

			local tmpUrl = ClientUrl:GetUrlString("HttpServerReport", "server/report")
			local url = CreateWiftUrl(tmpUrl)--"http://164.52.98.58:8080/server/report")
					:addparam("cmd",'net_report')
					:addparam("uin",uin)
					:addparam("country",country)
					:addparam("version",version)
					:addparam("apiid",apild)
					:addparam("ip_list",ip_list)
					:addparam("conn",conn)
					:finish()
	

			---statisticsGameEvent(url);
			Log("MiniLobbyFrameBottomShrink_OnClick2："..url);	
			ns_http.func.rpc_string_raw(url, function() end);

			MiniLobbyFrameBottomShrink_OnClick()

			threadpool:work(function()
				threadpool:wait(10);
				clickwifisupport = true;
			end)	

			clickwifisupport = false	
		end
	else
		MiniLobbyFrameBottomShrink_OnClick()
	end 
end





function MiniLobbyFrameBottomShop_OnClick()
	GetInst("MinilobbyPupTextMgr"):OnTipsHide("ShopTextTip")
	local redIsShow = getglobal('MiniLobbyFrameBottomShopRedTag'):IsShown()
	local effectShow = getglobal('MiniLobbyFrameBottomShopUvA'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0), standby3 = (effectShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_BOTTOM_1", "Shop", "click", eventTab) --mark by hfb for new minilobby 原大厅，新埋点
    JumpToShop()

	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyStoreBtn");
end

function MiniLobbyFrameBottomAR_OnClick()
    --[[
    if AccountManager:isFreeze() then
        ShowGameTips(GetS(762), 3);
        return;
    end

    if ARControl and ARControl.SetARInletTag then
        -- if getglobal("MiniLobbyFrame"):IsShown() then
        if IsMiniLobbyShown() then --mark by hfb for new minilobby
            ARControl:SetARInletTag(1)
            ARControl:SetSeatType(2);
            -- getglobal("MiniLobbyFrame"):Hide()
            HideMiniLobby() --mark by hfb for new minilobby
        end
    end

    InitAvatarStoreFrameUI(2);
    ]]-- liya
    JumpToAR()
end

function MiniLobbyFrameBottomBuddy_OnClick()
    --[[
    GetInst("UIManager"):Open("Chat")
	]]-- liya
	ReportTraceidMgr:setTraceid("friend")
	local redIsShow = getglobal('MiniLobbyFrameBottomBuddyRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_BOTTOM_1", "Friend", "click", eventTab) --mark by hfb for new minilobby 原大厅，新埋点
    JumpToChat()
	InteractiveBtn_OnClick();
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyBuddyBtn");
	--ClientMgr:loadDeveloperGame();
end

function BattlePassEntry_OnClick()
	--[[
	Author: sundy
	EditTime: 2021-08-02
	Description: the reason
	--]]

	GetInst("MinilobbyPupTextMgr"):OnTipsHide("BattlePassTextTip")
	JumpToBattlePass(true)
    -- statisticsGameEvent(701, "%s", "OnClick", "%lls", "BattllePassBtn") --区分新老大厅
	
	local param = getglobal("MiniLobbyFrameBottomBattlePassRedTag"):IsShown() and 1 or 0
	local redIsShow = getglobal('MiniLobbyFrameBottomMatchRedTag'):IsShown() and 1 or 0
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_BOTTOM_1", "BattlePass", "click", { standby1 = param, standby2 = redIsShow})
end

function MiniLobbyFrameBottomNotice_OnClick()
	--getglobal("ReplayTheaterFrame"):Hide()
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_ANNOUNCEMENT_1", "Announcement", "click") --mark by hfb for new minilobby 原大厅，新埋点
	GameSetFrameNoticeBtn_OnClick();
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyNoticeBtn");
end
-------------------订阅----------------------
function MiniLobbyFrameBottomSubscribe_OnClick()
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyFrameBottomSubscribeBtn");
	local redIsShow = getglobal('MiniLobbyFrameBottomSubscribeRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_BOTTOM_1", "Subscription", "click", eventTab) --mark by hfb for new minilobby 原大厅，新埋点
    --[[
    getglobal("SubscribeFrame"):Show();
    MiniLobbyFrameBottomButton_HandleRedTagClick("Subscribe");
    getglobal("MiniLobbyFrameBottomSubscribeRedTag"):Hide();
    ]]-- liya
    JumpToSubscribe()
end

function SubscribeFrameCloseBtn_OnClick()
    --[[
    getglobal("SubscribeFrame"):Hide();
    ]]-- liya
    CloseSubscribe()
end

function SubscribeFrameWeChatBtn_OnClick()
    --[[
	if ns_version.subscribe and ns_version.subscribe.option1 then
		local option = ns_version.subscribe.option1
		if option then 
			local url = option.action_url
			if url then
				statisticsGameEvent(701, "%s", "OnClick", "%lls", "SubscribeFrameWeChatBtn")
				g_openBrowserUrlAuth(url)
			end
		end
    end
    ]]-- liya
    if JumpToWeChat() then
        -- statisticsGameEvent(701, "%s", "OnClick", "%lls", "SubscribeFrameWeChatBtn")
    end
end

function SubscribeFrameWeiboBtn_OnClick()
    --[[
	if ns_version.subscribe and ns_version.subscribe.option2 then
		local option = ns_version.subscribe.option2
		if option then 
			local action = option.action
			local url = option.action_url
			if action and (action == 0) and url then
				statisticsGameEvent(701, "%s", "OnClick", "%lls", "SubscribeFrameWeiboBtn");
				g_openBrowserUrlAuth(url)
			elseif action and (action == 1) then
				if ClientMgr and ClientMgr.openMiniProgram then
					local ret = ClientMgr.openMiniProgram(); --是否能成功打开小程序的标志位
					if ret == false then
						ShowGameTipsWithoutFilter("微信圈子名称复制成功，请打开微信搜索关注");
						ClientMgr:clickCopy("迷你世界")
					end
				end
			end
		end
    end
    ]]-- liya

    if JumpToWeibo() then
        -- statisticsGameEvent(701, "%s", "OnClick", "%lls", "SubscribeFrameWeiboBtn")
    end
end
-----------------------------------------------
function MiniLobbyFrameBottomMatch_OnClick()
	Log( "call MiniLobbyFrameBottomMatch_OnClick" );
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyMatchBtn");
	local redIsShow = getglobal('MiniLobbyFrameBottomMatchRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_BOTTOM_1", "Competition", "click", eventTab) --mark by hfb for new minilobby 原大厅，新埋点
    --[[
    if  ns_version.match and ns_version.match.url then
        open_http_link( ns_version.match.url, "posting");
    end

	MiniLobbyFrameBottomButton_HandleRedTagClick("Match");

    getglobal("MiniLobbyFrameBottomMatchRedTag"):Hide();
    ]]-- liya
    JumpToMatch()
	
	-- local endcall = function (ret)
    --     if ret then
	-- 		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/c_ingame","miniui/miniworld/c_miniwork","miniui/miniworld/c_racesystem"})
	-- 		GetInst("MiniUIManager"):OpenUI("RaceSystemMain", "miniui/miniworld/RaceSystem", "RaceSystemMainAutoGen")
	-- 	else 
	-- 		JumpToMatch()
	-- 	end
    -- end
	
	-- GetInst("RaceSystemServer"):GetConfig(endcall)
end

function MiniLobbyFrameBottomNoticeText_OnClick()
	print("kekeke MiniLobbyFrameBottomNoticeText_OnClick", arg1, arg2);
	if arg1 ~= "LeftButton" then
		SdkManager:BrowserShowWebpage(arg2);
	end
end

function MiniLobbyFrameBottomNoticeText_OnMouseUp()
	print("kekeke MiniLobbyFrameBottomNoticeText_OnMouseUp", arg1, arg2);
end

function MiniLobbyFrameBottomCommunity_OnClick()
	Log( "call MiniLobbyFrameBottomCommunity_OnClick" );
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "ShequBtn");
	local redIsShow = getglobal('MiniLobbyFrameBottomCommunityRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_BOTTOM_1", "Community", "click", eventTab) --mark by hfb for new minilobby 原大厅，新埋点
	standReportEvent("58", "MINI_COMMUNITY_CONTAINER", "Enter", "click");
	if not ClientMgr:isPC() then
		--pc 忽略
		g_community_enter_stamp = os.time()
	end
    --[[
    if  ns_version.shequ and ns_version.shequ.url then
        open_http_link( ns_version.shequ.url, "posting");
    end

	MiniLobbyFrameBottomButton_HandleRedTagClick("Community");

    getglobal("MiniLobbyFrameBottomCommunityRedTag"):Hide();
    ]]-- liya 
    JumpToCommunity()
end

-- 直播按钮
function MiniLobbyFrameBottomVideoLive_OnClick()
	Log("call MiniLobbyFrameBottomVideoLive_OnClick()");
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyVideoLiveBtn");

    JumpToVideoLive()
end

-- 迷你工坊入口
function MiniLobbyFrameBottomDeveloperCenter_OnClick()
    Log("call MiniLobbyFrameBottomDeveloperCenter_OnClick()");
    --statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyVideoLiveBtn");
	ReportTraceidMgr:setTraceid("createcenter")
    JumpToCreationCenter()
end

function MiniLobbyFrameBottomFacebookThumbUp_OnClick()
    Log("MiniLobbyFrameBottomFacebookThumbUp_OnClick");
    --[[
	if if_open_facebook_prize() then
		g_openBrowserUrlAuth( ns_version.facebook_prize.url );
    end

	MiniLobbyFrameBottomButton_HandleRedTagClick("FacebookThumbUp");
    getglobal("MiniLobbyFrameBottomFacebookThumbUpRedTag"):Hide();
    ]]-- liya
    JumpToFacebookThumbUp()
end

function MiniLobbyFrameBottomNoNetworkOff_OnClick()
	isOffNetworkHint=false;
	getglobal("MiniLobbyFrameBottomNetworkBkg"):SetTexUV("aaa_icon_wifi_1");
	local networkState = getglobal("MiniLobbyFrameBottomNoNetworkHint");
	if networkState:IsShown() then
		networkState:Hide();
		getglobal("MiniLobbyFrameBottomNoNetworkHintText"):Hide();
	end
end

--跳到社区某个帖子id
function MiniLobbyFrameBottomCommunity_with_info( shequ_info )
	Log( "call MiniLobbyFrameBottomCommunity_with_info" );
	if  ns_version.shequ and ns_version.shequ.url then
		local url_ = ns_version.shequ.url;
		if  string.find( url_, '%?' ) then
			url_ = url_ .. '&';
		else
			url_ = url_ .. '?';
		end
		url_ = url_ .. shequ_info
		open_http_link( url_, "posting" );
	end
end

function MiniLobbyFrameBottomUnion_OnClick()

end

--【社区】【直播】【订阅】【点赞】【赛事】5个按钮红点
function MiniLobbyFrameBottomButton_HandleRedTag(typeName)
    --[[
    Log( "call MiniLobbyFrameBottomButton_HandleRedTag : ".. typeName);
	
	local nameMap = { Community = "shequ", VideoLive = "live", Subscribe = "subsp", FacebookThumbUp = "prize",Match = "match" };
	if not nameMap[typeName] then
		--print("error typeName")
		return;
	end

	local name = nameMap[typeName];
	ns_version.red_marks = ns_version.red_marks or {};
	local config = ns_version.red_marks[name];
	if not config or not check_apiid_ver_conditions(config) then
		--print("empty :", not config);
		--print(ns_version.red_marks);
		return;
	end
	--print("config :", config)

	-- 检测ver配置是否变更
	local ver_ = "red_tag_ver_"..name;
	local data_ = "red_tag_data_"..name;
	local verIsShow = false; -- ver方案显示开关
	local dataIsShow = false; -- data方案显示开关
	if not getkv(ver_) then
		setkv(ver_, 888)
	end
	if config.ver then
		if getkv(ver_) and config.ver ~= getkv(ver_) then
			verIsShow = true;
		end
	else -- 社区按钮分pc/mobile
		if ClientMgr.isPC and ClientMgr:isPC() and getkv(ver_) and
				config.pc_ver and config.pc_ver ~= getkv(ver_) then
			verIsShow = true;
		elseif ClientMgr.isMobile and ClientMgr:isMobile() and getkv(ver_) and
				config.mb_ver and config.mb_ver ~= getkv(ver_) then
			verIsShow = true;
		end
	end
	--print("ver_ :", verIsShow);

	if config.data then -- 本次登录已显示过 kv是缓存 重启游戏仍然存在 config中的是lua变量 重启游戏不存在
		--print("has showed :", config.data)
		dataIsShow = config.data.isShow;
	else
		local now = getServerNow()+1600;
		--data {
		--	long t; 周期
		--	int c; 计数
		--	bool isShow; 是否显示
		--}
		config.data = getkv(data_) or { t = 0, c = 0, isShow = false };
		--print("hasnot showed :", config.data, now)
		if config.cd and now - config.data.t >= config.cd then
			--print("new t :", now, config.data)
			config.data.c = 0;
			config.data.t = now;
			config.data.isShow = not verIsShow;
			setkv(data_, config.data);
		end

		if config.data.c < config.count then
			--print("data can show :", config.data.c)
			config.data.isShow = true;
			dataIsShow = true;
		end
	end

	if verIsShow and dataIsShow then
		-- 当运营配置红点与原有红点机制同时出现时，默认运营配置红点已生效完成，不再额外多次红点提示
		-- 即仅当前周期不再出现
		config.data.c = config.count;
		config.data.isShow = false;
		setkv(data_, config.data);
		--print("same time : ", config.data);
	end

	--print("both : ", verIsShow, dataIsShow)
	if verIsShow or dataIsShow then
		-- MiniLobbyFrameBottomCommunityRedTag,MiniLobbyFrameBottomVideoLiveRedTag,
		-- MiniLobbyFrameBottomSubscribeRedTag,MiniLobbyFrameBottomFacebookThumbUpRedTag
		getglobal("MiniLobbyFrameBottom" .. typeName .. "RedTag"):Show();
	else
		getglobal("MiniLobbyFrameBottom" .. typeName .. "RedTag"):Hide();
    end
    ]]-- liya
    CommunityAndSoOnButton_HandleRedTag(typeName, getglobal("MiniLobbyFrameBottom" .. typeName .. "RedTag"))
end

function MiniLobbyFrameBottomButton_HandleRedTagClick(typeName)
    --[[
    Log( "call MiniLobbyFrameBottomButton_HandleRedTagClick : ".. typeName);

	local nameMap = { Community = "shequ", VideoLive = "live", Subscribe = "subsp", FacebookThumbUp = "prize", Match = "match"};
	if not nameMap[typeName] then
		return;
	end

	local name = nameMap[typeName];
	ns_version.red_marks = ns_version.red_marks or {};
	local config = ns_version.red_marks[name];
	if not config or not check_apiid_ver_conditions(config) then
		--print(not config);
		--print(ns_version.red_marks);
		return;
	end

	local ver_ = "red_tag_ver_"..name;
	local data_ = "red_tag_data_"..name;

	if config and config.ver then
		setkv(ver_, config.ver)
	else
		if ClientMgr.isPC and ClientMgr:isPC() and config and config.pc_ver then
			setkv(ver_, config.pc_ver);
			--print("has set ver_ pc")
		elseif ClientMgr.isMobile and ClientMgr:isMobile() and config and config.mb_ver then
			setkv(ver_, config.mb_ver);
			--print("has set ver_ mb")
		end
	end


	if getkv(data_) then
		config.data = getkv(data_);
		--print("hava data_", config.data)
		if config.data.c < config.count and getglobal("MiniLobbyFrameBottom"..typeName.."RedTag"):IsShown() then
			--print("click data : ", config.data)
			config.data.c = config.data.c + 1;
			config.data.isShow = false;
			--print("click data after : ", config.data)
			setkv(data_, config.data);
		end
    end
    ]]-- liya
    CommunityAndSoOnButton_HandleRedTagClick(typeName, getglobal("MiniLobbyFrameBottom"..typeName.."RedTag"))
	if typeName == "Match" then
		MatchButton_HandleRedTag(false, true)
	end
end

function GetMiniLobbyFrameBottom_MatchRedTagCfg(firstTime)
	if not getglobal("MiniLobbyFrameBottomMatch"):IsShown() then
		return
	end

	local key = "_MatchBackstageRedTagShowRangeTime_"

	if firstTime then
		local envid = get_game_env()
		local url = ""
		--0正式 1测试 2先遣服
		if envid == 0 or envid == 2 then
			url = "https://wss.mini1.cn/"
		elseif envid == 1 then
			url ="https://wss.miniworldplus.com/"
		end
		url = url.."japi/micro/pub/reddot/game"

		local s2_, s2t_, pure_s2t_ = get_login_sign()
		local time = getServerNow()
		local uin  = AccountManager:getUin() or get_default_uin()
		local md5  = gFunc_getmd5(time .. s2_ .. uin)
		local lang = get_game_lang() or "nil"
		url = url.."?auth=" .. md5.."&time="..time..s2t_.."&langId="..lang.."&uid="..uin;

		ns_http.func.rpc_string(url,function(ret)
			local reslt =json2table(ret)
			if reslt then
				if reslt.code == ErrorCode.OK and reslt.data then
					local startTime = tonumber(reslt.data.startTime)
					local endTime = tonumber(reslt.data.endTime)
					if startTime and endTime then
						local nowTimeNum = getServerTime()
						local value = startTime.."_"..endTime
						local getkvData = getkv(key)
						if nowTimeNum >= startTime and nowTimeNum < endTime and (getkvData==nil or getkvData.rangeTime~=value or (not getkvData.isClicked)) then
							MatchButton_HandleRedTag(true)
							setkv(key, {rangeTime=value, isClicked=false})
						else
							MatchButton_HandleRedTag(false)
						end
					end
				else
					if reslt.msg then
						print("GetMiniLobbyFrameBottom_MatchRedTagCfg error: "..reslt.msg)
					end
				end
			end
		end); 
	else
		local getkvData = getkv(key)
		if getkvData==nil then
			return
		end
		local isShow = false
		local rangeTime = string.split(getkvData.rangeTime, "_")
		if rangeTime and (not getkvData.isClicked) then
			local startTime = tonumber(rangeTime[1])
			local endTime = tonumber(rangeTime[2])
			if startTime and endTime then
				local nowTimeNum = getServerTime()
				if nowTimeNum >= startTime and nowTimeNum < endTime then
					isShow = true
				end
			end
		end
		if isShow then
			MatchButton_HandleRedTag(true)
		else
			MatchButton_HandleRedTag(false)
		end
	end
end

function MatchButton_HandleRedTag(isShow, isClicked)
	local redTag = getglobal("MiniLobbyFrameBottomMatchRedTag")
	if redTag then
		if isShow then
			redTag:Show()
		else
			redTag:Hide()
		end
	
		local key = "_MatchBackstageRedTagShowRangeTime_"
		local getkvData = getkv(key)
		if isClicked and getkvData then
			getkvData.isClicked=true
			setkv(key, getkvData)
		end
	end
end

--点击主题更新提示
function MiniLobbyFrameBottomSkinUpdateTip_OnClick( ... )
	if GotoGameSetFrame then
		GotoGameSetFrame()
	else
		getglobal("GameSetFrame"):Show();
	end
	getglobal("MiniLobbyFrameBottomSkinUpdateTip"):Hide()
	SkinConfigCtrl.recordSkinUpdate() --记录当前皮肤MD5，下次不再提醒更新
end

------------------------------------------------MiniFrameGuide----------------------------------------
local isFirstClickGuide = 0;   --标识用户第一次点击界面引导

function MiniLobbyFrameGuideContentCloseBtn_OnClick()
	getglobal("MiniLobbyFrameGuide"):Hide();
	getglobal("MiniLobbyFrameCenterLocalMap"):SetFrameLevel(1000);
	getglobal("MiniLobbyFrameCenterMultiplayer"):SetFrameLevel(1000);
	getglobal("MiniLobbyFrameCenterMiniWorks"):SetFrameLevel(1000);
	getglobal("MiniLobbyFrameCenterHomeChest"):SetFrameLevel(1000);

	GameUIGuideStep = 0;
	CreateMapGuideStep = 1;
	CreateMapGuide();
	
end

function MiniLobbyFrameGuideContentNextBtn_OnClick()
	if GameUIGuideStep == 1 then
		--埋点，主界面引导-开始游戏-点击 设备码,玩家来源,触发场景,用户类型,语言
		-- statisticsGameEventNew(965,ClientMgr:getDeviceID(),(IsFirstEnterNoviceGuide and not enterGuideAgain) and 1 or 2,IsSkipFromGuideOrFirstMap and 1 or 2,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))

		standReportEvent("39", "NEWPLAYER_HOMEPAGE_GUIDE", "StartGame", "click");
	elseif GameUIGuideStep == 2 then
		--埋点，主界面引导-联机大厅-点击 设备码,玩家来源,触发场景,用户类型,语言
		-- statisticsGameEventNew(966,ClientMgr:getDeviceID(),(IsFirstEnterNoviceGuide and not enterGuideAgain) and 1 or 2,IsSkipFromGuideOrFirstMap and 1 or 2,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))

		standReportEvent("39", "NEWPLAYER_HOMEPAGE_GUIDE", "MutiplayerLobby", "click");
	elseif GameUIGuideStep == 3 then
		--埋点，主界面引导-迷你工坊-点击 设备码,玩家来源,触发场景,用户类型,语言
		-- statisticsGameEventNew(967,ClientMgr:getDeviceID(),(IsFirstEnterNoviceGuide and not enterGuideAgain) and 1 or 2,IsSkipFromGuideOrFirstMap and 1 or 2,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))

		standReportEvent("39", "NEWPLAYER_HOMEPAGE_GUIDE", "WorkShop", "click");
	elseif GameUIGuideStep == 4 then
		--埋点，主界面引导-我的家园-点击 设备码,玩家来源,触发场景,用户类型,语言
		-- statisticsGameEventNew(968,ClientMgr:getDeviceID(),(IsFirstEnterNoviceGuide and not enterGuideAgain) and 1 or 2,IsSkipFromGuideOrFirstMap and 1 or 2,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))

		standReportEvent("39", "NEWPLAYER_HOMEPAGE_GUIDE", "MyHomeland", "click");
	end
	StatisticsTools:send(true, true)
	if GameUIGuideStep == 4 then	--完成
		MiniLobbyFrameGuideContentCloseBtn_OnClick();
		SetGuideStep(7)
	else
		isFirstClickGuide = 0;
		GameUIGuideStep = GameUIGuideStep+1;
		SetGuideStep(GetGuideStep() + 1)
		UpdateGameUIGuide();
	end
end

function MiniLobbyFrameNewGuideContent_OnHide()
	-- getglobal("MiniLobbyFrameCenterLocalMap"):SetFrameLevel(1000);
	getglobal("MiniLobbyFrameCenterMultiplayer"):SetFrameLevel(1000);
	-- getglobal("MiniLobbyFrameCenterMiniWorks"):SetFrameLevel(1000);
	-- getglobal("MiniLobbyFrameCenterHomeChest"):SetFrameLevel(1000);
end

function CreateMapGuide()
	
	if isEnableNewMiniLobby() then
		getglobal("MiniLobbyExCenterLocalMapFinger"):Hide();
	else
		getglobal("MiniLobbyFrameCenterLocalMapFinger"):Hide();
	end
	
	-- 存档新手引导第一步
	if CreateMapGuideStep == 1 then
		if isEnableNewMiniLobby() then
			getglobal("MiniLobbyExCenterLocalMapFinger"):Show();
		else
			-- getglobal("MiniLobbyFrameCenterLocalMapFinger"):Show();
			getglobal("MiniLobbyFrameCenterLocalMapFinger"):Hide();
		end
		standReportEvent("40", "NEWPLAYER_FILEPAGE_GUIDE", "StartGame", "view");
	end
	
	getglobal("CreateArchiveCreateFinger"):Hide();
	getglobal("LobbyFrameNoviceEnterWorldFrame"):Hide()
	getglobal("ArchiveInfoFrameIntroduceStarGameBtnFinger"):Hide()

	local btnname = HideMapSlidingFrameGuide()
	if btnname == "" then return end
	
	--新手引导流程优化，新增几步进入地图指引
	if CreateMapGuideStep == 2 then 
		getglobal("LobbyFrameNoviceEnterWorldFrame"):Show()
		-- statisticsGameEvent(901, '%s', "UIGuideCreateMapFinger","%d",GuideLobby,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
		standReportEvent("40", "NEWPLAYER_FILEPAGE_GUIDE", "CreateMap", "view");
	elseif CreateMapGuideStep == 3 then
		getglobal(btnname.."SlidingFrameFingerGuide"):Show()
		getglobal(btnname.."SlidingFrameFingerGuideTipsContent"):SetText(GetS(973),55,54,49)
		standReportEvent("40", "NEWPLAYER_FILEPAGE_GUIDE", "CreateMap", "click");
		standReportEvent("40", "NEWPLAYER_FILEPAGE_GUIDE", "ClickMap", "view");
	elseif CreateMapGuideStep == 4 then 
		getglobal("ArchiveInfoFrameIntroduceStarGameBtnFinger"):Show()
		standReportEvent("40", "NEWPLAYER_FILEPAGE_GUIDE", "ClickMap", "click");
		standReportEvent("40", "NEWPLAYER_FILEPAGE_GUIDE", "SingleEnter", "view");
	elseif CreateMapGuideStep == 5 then
		-- statisticsGameEvent(901, "%s", "UIGuideStarGame","%d",GuideLobby,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
		standReportEvent("40", "NEWPLAYER_FILEPAGE_GUIDE", "SingleEnter", "click");
	elseif CreateMapGuideStep == 6 then
		-- statisticsGameEvent(901, '%s', "GuideStarGame","%d",GuideLobby,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
	end
end

function HideMapSlidingFrameGuide()
	local btnname = ""
	local listview = getglobal("ArchiveBox")
	local cell = listview:cellAtIndex(0)
	if not cell then return btnname end
	btnname = cell:GetName()

	getglobal(btnname.."SlidingFrameFingerGuide"):Hide()
	
	return btnname
end


------------------------------------------------------------MiniLobbyFrame-------------------------
function saveInGameAnnounceRecords(notic_id)
	local save_key = "IN_GAME_NOTICE"
	local value_tab = {}
	value_tab = getkv(save_key) or {}
	table.sort(value_tab,function(tb1_item,tb2_item)
        return tb1_item > tb2_item
	end)
	if #value_tab >= 10 then
		value_tab[10] = notic_id
	else
		value_tab[#value_tab + 1] = notic_id
	end
	setkv(save_key,value_tab)
end

function hasDisplayNoticById(notice_id)
	local save_key = "IN_GAME_NOTICE"
	local value_tab = {}
	local ret = 0
	value_tab = getkv(save_key) or {}
	for idx = 1,#value_tab do
		local item_id = value_tab[idx]
		if notice_id == item_id then
			ret = 1
			--print("----------find item_id: " .. item_id)
			break
		end
	end
	return ret
end

-- function SetBiomeDef()
-- 	local biomesIDs = {3400,3401,3402,3403,3404,3407,3409,3101,3102,3105,3107,3108,3109,3103,3110,3111,3112,3113,3114,3115,3116,3117,3118,3501,3502,3130,
-- 	3131,3411,3412,3413,3414,3416,3418,3419,3507,3508,3120,3600,3602,3604,3605,3606,3607,3608}

-- 	for i = 0,MAX_BIOME_TYPE - 1 do 
-- 		local biomeDef = DefMgr:getBiomeDef(i)
-- 		if biomeDef then 
-- 			local count = #biomesIDs
-- 			for j = 1,count do 
-- 				if j - 1 > MAX_BIOME_MONSTERS then 
-- 					break 
-- 				end 
-- 				local id = biomesIDs[j]
-- 				local monsterDef = MonsterCsv:get(id)
-- 				if monsterDef then 
-- 					biomeDef.biomeMonster[j] = id 
-- 					biomeDef.biomeMonsterNum[j] = monsterDef.SpawnWeight[i]

-- 					local def = DefMgr:getBiomeDef(i)
-- 					def.biomeMonster[j] = id 
-- 					def.biomeMonsterNum[j] = monsterDef.SpawnWeight[i]
-- 				end 
-- 			end 
-- 		end 
-- 	end 
-- end

-- 消息注册去重
local minilobby_events = {}
local function RegisterEventDeduplicate(eventName)
	if not minilobby_events[eventName] then
		this:RegisterEvent(eventName);
		minilobby_events[eventName] = eventName
	end
end

function MiniLobbyFrame_OnLoad()

	
	this:setUpdateTime(0.05);

	ARDressBtnAnimations
		:setIconUI("MiniLobbyFrameARDressDiamondBtn")
		:setDrawerUI("MiniLobbyFrameARDressBtn")
		:setSlideInSecond(1)
		:setSlideOutSecond(1)
		:setKeepVisibleSecond(3)
		:fromLeftToRight();

	local getglobal = _G.getglobal;

	RegisterEventDeduplicate("GIE_MINICOIN_CHANGE");
	RegisterEventDeduplicate("GIE_MINIBEAN_CHANGE");
	RegisterEventDeduplicate("GE_WATCH_AD_RESULT");
	RegisterEventDeduplicate("GE_TRACE_ROUTE_PARAM");
	RegisterEventDeduplicate("TP_SCREEN_IMAGE_CAPTURER");
	RegisterEventDeduplicate("GE_CALL_LUA_STRING");
	RegisterEventDeduplicate("GE_LOAD_DEVELOPER_INFO");
    RegisterEventDeduplicate("GE_ON_CLICK")
    -- RegisterEventDeduplicate("GE_ON_CHECK")
    RegisterEventDeduplicate("GE_ON_FOCUS_LOST")
	RegisterEventDeduplicate("GIE_APPBACK_PRESSED")
    -- RegisterEventDeduplicate("GE_ON_ENTER_PRESSED")
    -- RegisterEventDeduplicate("GE_ON_MOUSE_ENTER")
    -- RegisterEventDeduplicate("GE_ON_MOUSE_LEAVE")
    -- RegisterEventDeduplicate("GE_ON_MOUSE_UP")
    -- RegisterEventDeduplicate("GE_ON_MOUSE_DOWN_UPDATE")
    RegisterEventDeduplicate("GE_ON_MOUSE_DOWN")
	RegisterEventDeduplicate("GE_USE_STASH_RESULT")
	RegisterEventDeduplicate("GE_PLAYER_DIG_BLOCK_END")
	RegisterEventDeduplicate("GE_MINILOBBYFRAME_ENTER")

	RegisterEventDeduplicate("GE_LUA_CUSTOM_EVENT")

	Lite:InitInterceptedFunctions();

	if isAbroadEvn() == false and IsOverseasVer() == false then
		ReNameRegisterServiceListeners()
	end 

	local apiId = ClientMgr:getApiId()
	--Vip
	if ShowQQVipBtn() then
		getglobal("MiniLobbyFrameTopQQBlueVipBtn"):Show();
		--MiniLobbyFrameTopQQZoneExternalLink_HandleRedTagFlag(false);
	else
		getglobal("MiniLobbyFrameTopQQBlueVipBtn"):Hide();
		getglobal("MiniLobbyFrameTopQQZoneExternalLinkBtn"):Hide();
	end

	MiniLobbyFrameBottomShrink = false;

	getglobal("MiniLobbyFrameCenterLocalMapView"):setCameraWidthFov(30);
	getglobal("MiniLobbyFrameCenterLocalMapView"):setCameraLookAt(0, 0, -1800, 0, 200, 0);
	getglobal("MiniLobbyFrameCenterLocalMapView"):setActorPosition(-220, 0, 0);

	getglobal("MiniLobbyFrameCenterMultiplayerView"):setCameraWidthFov(30);
	getglobal("MiniLobbyFrameCenterMultiplayerView"):setCameraLookAt(0, 0, -1800, 0, 200, 0);
	getglobal("MiniLobbyFrameCenterMultiplayerView"):setActorPosition(-220, 0, 0);

	if apiId == 2 then --4399
		getglobal("MiniLobbyFrameTop4399LoginBtn"):Show();
		ns_a4399.func.downloadLua(); -- 拉取4399礼包按钮配置
	else
		getglobal("MiniLobbyFrameTop4399LoginBtn"):Hide();
	end

	if IsShouQChannel(apiId) then
		if apiId == 47 then
			getglobal("MiniLobbyFrameTopQQVipBtn"):Hide();
			getglobal("MiniLobbyFrameTopQQBlueVipBtn"):SetPoint("right", "MiniLobbyFrameTopActivity", "left", -99, 0);
		else
			getglobal("MiniLobbyFrameTopQQVipBtn"):Show();
		end
		getglobal("MiniLobbyFrameTopQQBuLuoBtn"):Show();
	else
		getglobal("MiniLobbyFrameTopQQVipBtn"):Hide();
		getglobal("MiniLobbyFrameTopQQBuLuoBtn"):Hide();
	end


	if apiId == 21 then --应用宝
		getglobal("MiniLobbyFrameTopYYBForumBtn"):Show();
	else
		getglobal("MiniLobbyFrameTopYYBForumBtn"):Hide();
	end

	if apiId == 13 then
		getglobal("MiniLobbyFrameTopOppoForumBtn"):Show();
	else
		getglobal("MiniLobbyFrameTopOppoForumBtn"):Hide();
	end

	--Lite版拦截UI显示
	if Lite:NeedHiding() then 
		Lite:HideAllUi();
		return 
	end
	
	getglobal("MiniLobbyFrameTopMiniBean"):Show();
	getglobal("MiniLobbyFrameTopMiniCoin"):Show();
	local isShowActivityBtn = Show_MiniLobby_ActivityBtn()
	if isShowActivityBtn then
		getglobal("MiniLobbyFrameTopActivity"):Show()
	else
		getglobal("MiniLobbyFrameTopActivity"):Hide()
	end

	-- 活动栏按钮UI
	for key, value in pairs(ActivityInfo) do
		if getglobal(ActivityRoomBox..value.FrameName) then
			if value.xmlName and value.xmlName ~= "" then
				getglobal(ActivityRoomBox..value.FrameName.."Icon"):SetTextureHuiresXml(string.format("ui/mobile/texture0/%s.xml", value.xmlName))
			end
			if value.icon and value.icon ~= "" then
				getglobal(ActivityRoomBox..value.FrameName.."Icon"):SetTexUV(value.icon)
			end
			if value.title and value.title ~= "" then
				getglobal(ActivityRoomBox..value.FrameName.."Name"):SetText(value.title)
			end
		end
	end

	getglobal("MiniLobbyFrameTopMail"):Show();
	getglobal("MiniLobbyFrameCenterHomeChest"):Show();
	--getglobal("MiniLobbyFrameBottomShrink"):Show();
	getglobal("MiniLobbyFrameBottomNotice"):Show();
	getglobal("MiniLobbyFrameBottomNoticeBkg"):Show();
	--getglobal("MiniLobbyFrameTopActivityRoomBox"):Show();
	--迷你工坊主界面按钮大图
	local szMainlandPath = "ui/mobile/texture0/bigtex/ljdt_qukuaitu03_new.png";
	local szOverseasPath = "ui/mobile/texture0/bigtex/ljdt_qukuaitu03.png";--TODO: 下次更改贴图再更改
    SetTextureMainlandOrOverseas("MiniLobbyFrameCenterMiniWorksPic", szOverseasPath, szOverseasPath);
  
    --我的家园背景
    SetMiniLobbyFrameHomePicture()

    --迷你工坊背景
    SetMiniLobbyFrameWorkshopPicture()

	--[[
	Author: sundy
	EditTime: 2021-08-02
	Description: the reason
	--]]

	MiniLobbyFrame_ChangeUpsidePupTextBack()

	--新ui的入口
	if gFunc_IsNewMiniUIEnable and gFunc_IsNewMiniUIEnable() then
		local entryButton = getglobal("MiniLobbyFrameBottomNewUIDemoCpp")
		if entryButton then
			entryButton:Hide()
		end
		local entryButton = getglobal("MiniLobbyFrameBottomNewUIDemoLua")
		if entryButton then
			entryButton:Hide()
		end
	end
end

	--[[
	Author: sundy
	EditTime: 2021-08-02
	Description: the reason
	--]]

function MiniLobbyFrame_ChangeUpsidePupTextBack()
	local homelandTextTipBkg = getglobal("MiniLobbyFrameTopActivityRoomBoxHomelandBtnTextTipBkg")
	local homelandTextTipMark = getglobal("MiniLobbyFrameTopActivityRoomBoxHomelandBtnTextTipMark")
	homelandTextTipBkg:SetPoint('topright', homelandTextTipBkg:GetParent(), 'center', 0, 0)
	homelandTextTipMark:SetAngle(180)
	homelandTextTipMark:SetPoint('topright', homelandTextTipBkg:GetName(), 'topright', -25, -6)

	local vipBtnBkg = getglobal("MiniLobbyFrameTopActivityRoomBoxMiniVipBtnTextTipBkg")
	local vipBtnMark = getglobal("MiniLobbyFrameTopActivityRoomBoxMiniVipBtnTextTipMark")
	vipBtnBkg:SetPoint('topright', vipBtnBkg:GetParent(), 'center', 0, 0)
	vipBtnMark:SetAngle(180)
	vipBtnMark:SetPoint('topright', vipBtnBkg:GetName(), 'topright', -25, -6)
end

function MiniLobbyFrame_OnEvent()
	if isEnableNewMiniLobby() then
		return --mark by hfb for new minilobby --两边都有监听，不合理
	end
	if IsShowFguiMain() then
		return
	end

	-- local print = Android:Localize(Android.SITUATION.CHANNEL);
	if arg1 == "GIE_MINICOIN_CHANGE" then
		print("MiniLobbyFrame_OnEvent GIE_MINICOIN_CHANGE")
		NewUpdateMiniBeanOrCoin("NewStoreFrameTopMyMiniCoin");

	elseif arg1 == "GIE_MINIBEAN_CHANGE" then
		NewUpdateMiniBeanOrCoin("NewStoreFrameTopMyMiniBean");
	elseif arg1 == "GE_CALL_LUA_STRING" then
		local funcLuaString = loadstring(GameEventQue:getCurEvent().body.callluastringinfo.luaString);
		funcLuaString();
	elseif arg1 == "GE_WATCH_AD_RESULT" then
		local ge = GameEventQue:getCurEvent();
		OnWatchADResult(ge.body.watchadresult.result);
	elseif arg1 == "GE_TRACE_ROUTE_PARAM" then
		local ge = GameEventQue:getCurEvent();
		OnTraceRouteInfoResult(ge.body.traceroute.index,ge.body.traceroute.traceInfo);
	elseif arg1 == "GE_LOAD_DEVELOPER_INFO" then
		loadDeveloperInfo();

	elseif arg1 == "TP_SCREEN_IMAGE_CAPTURER" then
		if ClientMgr:isPC() or IsIosPlatform() then
			SetSnapshottypeValue(101)
			SnapshotForShare:requestSaveSnapshot();
		end
	elseif arg1 == "GE_USE_STASH_RESULT" then
		local ge 	= GameEventQue:getCurEvent();
		local num = ge.body.useStash.num;
		local t_GetItems = {};
		for i=1, num do
			local itemId 	= ge.body.useStash.getitemid[i-1];
			local itemNum 	= ge.body.useStash.getitemnum[i-1];
			table.insert(t_GetItems, {id=itemId, num=itemNum});
		end

		local bUse = false
		local MafBtnExtend = GameRewardFrameGetMafBtnExtend()
		if MafBtnExtend and MafBtnExtend.task_id then
			if MafBtnExtend.task_id == 'showad27' or MafBtnExtend.task_id == 'showad9' then
				bUse = true
			end
		end
		-- print('sundy----->>>MiniLobbyFrame_OnEvent', tostring(MafBtnExtend.task_id), tostring(bUse));
		SetGameRewardFrameInfo(GetS(3160), t_GetItems, "", nil, nil, bUse);
	elseif arg1 == "GE_MINILOBBYFRAME_ENTER" then 
		local eventData = GameEventQue:getCurEvent();
		local isMiniLobbyFrameFirstShow = eventData.body.enterLobbyFrame.isFirstEnter;
		if not eventData then  return end 
		
		threadpool:work(function()
			WWW_get_building_bag_unlock_info() --获取解锁信息
		end);

		if isMiniLobbyFrameFirstShow then			
			threadpool:work(function()			
				WWW_GetMuteData();        --拉取自己的禁言数据
			end);

		
			threadpool:work(function()			
				WWWGetArchiveList()				--拉取互通存档数据
			end);		
			
			threadpool:work(function()
				loadActionBarData() --读取人物动作表
			end);
		end 

			--拉起地图黑名单
		if isMiniLobbyFrameFirstShow then 
			threadpool:work(function()
				threadpool:wait(1)			
				BreakLawMapControl:LoadBreakLawMapInfo();			
			end);
		else
			-- 随机数字1-3先屏蔽
			--[[
			math.randomseed(os.time())
			if math.random(3) == 1 then 
				threadpool:work(function()						
					BreakLawMapControl:LoadBreakLawMapInfo();
				end);
			end
			]]
		end 
		

			-- 主题更新检查
		threadpool:work(function()
			local hascheck = false
			math.randomseed(os.time())
			if math.random(2) == 1 then 
				CheckSkinUpdateTipShow()
				hascheck = true
			end 
			if hascheck == false then 
				math.randomseed(os.time())
				if  math.random(3) == 1 then 
					CheckSkinUpdateTipShow()
					hascheck = true
				end 
			end 
		end);	
			--预设置装备模型文件加载
		threadpool:work(function()
			threadpool:wait(2);
			if SingleEditorFrame_Switch_New then
				CustomModelMgr:copyEquipCustomModel2StudioPath();
				CustomModelMgr:loadEquipCustomModel();			--TODO:加载预设装备模型
				FullyCustomModelMgr:loadEquipFullyCustomModel();--TODO:加载预设装备模型
			end
		end);	

		threadpool:work(function()			
			if isMiniLobbyFrameFirstShow == true then 
				threadpool:wait(3)
				--物理机械PhysicsPartsConnect表 对应信息的加载
				VehicleMgr:loadPhysicsPartsConnectInfo()
			end 
		end);		

		if ClientMgr:isPC() then
			if isMiniLobbyFrameFirstShow == true then 
				ClientMgr:IsCef3CanUse()
				if not GetInst("BrowserReferenceHandle"):HasInitCefBrowser() then
					GetInst("BrowserReferenceHandle"):InitCefBrowser()
				end
			end 
		end
		
	 --mark by hfb for new minilobby 原大厅，新埋点
	 	threadpool:work(function ()
			MiniLobbyStandReportViewEvent()
		end)
			--添加服务器敏感词到客户端
		
		--添加服务器敏感词到客户端
		if not FilterMgr.isAddString then			
			threadpool:work(function()
				threadpool:wait(3)
		   		 --添加服务器敏感词到客户端
				FilterMgr.AddStringToClient()
				--这里主动刷新一下名字显示，可能有过滤
				SetRoleInfo()
				AfterSetRoleInfo()
			end)
		end

		threadpool:work(function ()
			--星舞动拉取动作数据
			ARMotionCapture:Init()
			ARMotionCapture:LoadMotionSeatConfig()
			ARMotionCapture:LoadSelfSeatData()
			ARMotionCapture:SetSeatDataNeedUp(true)
			if not ARMotionCapture:GetSeatOpenState() then
				local curSeatId = ARMotionCapture:GetCurUseSeatID()
				if curSeatId and curSeatId > 0 then
					ARMotionCapture:UseMotionSeat(0)
				end
			elseif IsLobbyShown() then
				getglobal("LobbyFrameUseActionBtn"):Show()
			end
			if GetInst("UIManager"):GetCtrl("ArchiveUseAction", "uiCtrlOpenList") then
				GetInst("UIManager"):GetCtrl("ArchiveUseAction"):Refresh()
			end
		end)


		CheckNeedShowExternalRecommend();
		GetInst("ExternalRecommendMgr"):ClearJumpRoomFrameInfo()--kuaishou
		--kuaishou
		local apiId = ClientMgr:getApiId()
	    if apiId == 57 then
		   local hasBindedKuaishou = AccountManager:isbindopenid("kuaishou")
		   local IsEnableNewBindLogin = IsEnableNewBindLogin and IsEnableNewBindLogin()
		   if check_apiid_ver_conditions( ns_version.kuaishou_bind ) 
		   		and ns_version.kuaishou_bind.onshow == 1 
				and not hasBindedKuaishou
				and not IsEnableNewBindLogin then
			   if not GetInst("UIManager"):GetCtrl("KuaiShouBindMessageBox") then
				   GetInst("UIManager"):Open("KuaiShouBindMessageBox")
			   end
		   end
	    end
	elseif arg1 == "GE_LUA_CUSTOM_EVENT" then
		local ge 	= GameEventQue:getCurEvent();
		local key, data = G_GameEvent_Lua_Custom_Event_Decode(ge.body.luaCustomEventData.data)
		if key == "Act_Concert_St_Sefresh" then
			ActivityRoomRefresh()
		end
	elseif arg1 == "GIE_APPBACK_PRESSED" then
		if getglobal("GameSetFrame"):IsShown() then
			getglobal("GameSetFrame"):Hide();
		elseif getglobal("FeedBackFrame"):IsShown() then
			getglobal("FeedBackFrame"):Hide();
		else
			if getglobal("SetMenuFrame"):IsShown() then
				getglobal("SetMenuFrame"):Hide();
			--	GameSnapshot();
			elseif CurWorld and (CurWorld:getOWID() == NewbieWorldId2) then
				PlayMainFrameGuideSkip_OnClick();
			else
				getglobal("SetMenuFrame"):Show();
			end
		end
    end
end

--资源包下载全局变量
local mSrcPackDownloadParam = {
	checkTime = 0,
	needCkeck = false;
	path = "",
	size = 0;
};

--资源包下载完成检测
function CheckSrcPathIsDownComplete()
	if mSrcPackDownloadParam.checkTime >= 40 then
		mSrcPackDownloadParam.checkTime = 0;

		if mSrcPackDownloadParam.needCkeck then
			--检测
			Log("CheckSrcPathIsDownComplete: 1111");
			if ClientMgr:IsAllFileDownloadComplete() then
				mSrcPackDownloadParam.needCkeck = false;
				Log("XXXXdownload Successful!!!");
				ShowGameTips(GetS(9173), 3);
				-- statisticsGameEvent(10001, '%d', 4);
			end
		end
	else
		mSrcPackDownloadParam.checkTime = mSrcPackDownloadParam.checkTime + 1;
	end
end

--是否有资源包需要下载
local m_bCheckIsHavePackNeedDown_ShowFlag = true;
function CheckIsHavePackNeedDownload(bNotPopBox)
	Log("CheckIsHavePackNeedDownload:");
	if ClientMgr:isPC() then
		Log("isPC, return!");
		return;
	end

	--移动网络才弹
	if ClientMgr:getNetworkState() ~= 2 then
		Log("NetworkState ~= 2, return!");
		return;
	end

	--一次游戏只弹一次
	if m_bCheckIsHavePackNeedDown_ShowFlag then
		m_bCheckIsHavePackNeedDown_ShowFlag = false;
	else
		Log("NotFirst, return!");
		return;
	end

	local packNum = DefMgr:getFileToLoadNum();

	Log("CheckIsHavePackNeedDownload: packNum = " .. packNum);

	local nSumSize = ClientMgr:GetAllModFileSumSize();
	local nSize = tonumber(string.format("%0.1f", nSumSize / 1048576)) or 0;

	if nSize < 0.1 then nSize = 0.1 end
	local text = GetS(9174, "(" .. nSize .. "M)");

	if nSumSize and nSumSize > 0 then
		--有文件需要下载
		-- statisticsGameEvent(10001, '%d', 1);	--统计埋点
		MessageBox(25, text, function(btn)
				if btn == 'right' then
					--下载
					-- statisticsGameEvent(10001, '%d', 3);
					Log("right: downloading");
					ClientMgr:BeginDownloadAllFile();
					mSrcPackDownloadParam.checkTime = 0;
					mSrcPackDownloadParam.needCkeck = true;
					ClientMgr:setDownloadStop(false);
				elseif btn == "left" then
					-- statisticsGameEvent(10001, '%d', 2);
					ClientMgr:setDownloadStop(true);
				end
			end
		);
	end
end

local getVipRewardInfoCountdown = 3;	--每3s本地查询一次vip领奖信息，持续1min
local getVipRewardInfoTotalTime = 60;	--每3s本地查询一次vip领奖信息，持续1min
local MOVE_WIDTH_TICK = 2;

function MiniLobbyFrame_SetNoticeTickStepWidth(width)
    MOVE_WIDTH_TICK = width;
end

function MiniLobbyFrame_OnUpdate()
	-- if QRCodeScanner then
	-- 	local ECommercialMiniCoinParser = QRCodeScanner.ECommercialMiniCoinParser;
	-- 	if ECommercialMiniCoinParser then
	-- 		local RewardDisplay = ECommercialMiniCoinParser.m_clsRewardDisplay;
	-- 		if RewardDisplay and RewardDisplay.onUpdate then
	-- 			RewardDisplay:onUpdate()
	-- 		end
	-- 	end
	-- end
	ARDressBtnAnimations:onUpdate(arg1);

	local rich = getglobal("MiniLobbyFrameBottomNoticeText");
	if rich:IsShown() then
		local disx = rich:GetDispPosX() + MOVE_WIDTH_TICK;
		rich:SetDispPosX( disx )
		if disx - 50 > rich:getLineWidth(0) then
			rich:SetDispPosX( -750 )
		end
	end

	CheckVersionParamsLoaded();

	if getVipRewardInfoTotalTime >= 0 then
		getVipRewardInfoTotalTime = getVipRewardInfoTotalTime - arg1;
		getVipRewardInfoCountdown = getVipRewardInfoCountdown - arg1;
		if getVipRewardInfoCountdown <=0 then
			GongNengFrameVipBtnRefresh();
			ShowGuanBanFuliBtnAndRedFlags();
			getVipRewardInfoCountdown = 3;

			--刷新7k7kvip按钮
			IsShowVip7k7kBtn(getglobal("MiniLobbyFrameTop7k7kBlueVipBtn"));
		end
	end
	
	--CreateMapGuide
	local finger = getglobal("MiniLobbyFrameCenterLocalMapFinger");
	if finger:IsShown() then
		FingerScale = FingerScale + ScaleSpeed;
		if FingerScale > 1.3 then
			FingerScale = 1.3;
			ScaleSpeed = -0.05;
		elseif FingerScale < 1.0 then
			FingerScale = 1.0;
			ScaleSpeed = 0.05;
		end
		local width = 100 * FingerScale;
		local height = 100 * FingerScale;
		finger:SetSize(width, height);
	end

	--if ClientMgr:MonitorCommunityProcessIsClose() == true then
		--ClientMgr:setPause(false);
		--Log("Update GameUI...............................");
	--end

	--资源包下载完成检测
	CheckSrcPathIsDownComplete();

	UpdateUI_WaterMark("MiniLobbyFrameWaterMarkFrameFont")
	getglobal("MiniLobbyFrameWaterMarkFrameFont"):SetBlendAlpha(0.4)

	-- 检测家园果实的时间和家园商人的时间
	--[[
	Author: sundy
	EditTime: 2021-08-02
	Description: the reason
	--]]

	GetInst("MinilobbyPupTextMgr"):OnUptate()

	-- 触发活动倒计时刷新
	local ActivityTriggerBtnUI = "MiniLobbyFrameTopActivityRoomBoxActivityTriggerBtn"
	local ActivityTriggerBtn = getglobal(ActivityTriggerBtnUI)
	if ActivityTriggerBtn and ActivityTriggerBtn:IsShown() then
		local gift_time = GetActivityTriggerConfig("gift_time")
		if CheckActivityTriggerPackageList and next(CheckActivityTriggerPackageList) and gift_time then
			local i, value, tt = 1, 0, 0
			while true do
				value = CheckActivityTriggerPackageList[i]
				if value and value.timer then
					tt = (value.timer + gift_time) - getServerTime()
					if tt then
						break
					else
						tt = 0
					end
				end
				i = i + 1
			end
			
			if tt > 0 then
				local hour = math.floor(tt / 3600)
				local min = math.floor((tt - hour*60) / 60)
				local sec = tt % 60
				local str = ""
				if hour > 0 then
					str = string.format("%02d:%02d:%02d", hour, min, sec)
				else
					str = string.format("%02d:%02d", min, sec)
				end
				getglobal(ActivityTriggerBtnUI.."Time"):SetText(str)
			else
				CheckActivityTriggerPackageList[i] = nil
			end
		else
			ActivityTriggerBtn:Hide()
			ActivityRoomBoxSizeRefresh()
		end
	end
	MiniUIMiniBaseDownLoaderManager:onUpdate()

	GetInst("NewBattlePassDataManager"):onUpdate()

end

--首页轮播公告
function activeMiniLobbyRotateNitice()
	MiniLobbyFrame_SetNoticeTickStepWidth(2);
	--公告滚动test
	--local brief = ClientMgr:getGameNoiceBrief();
	local brief = ns_start_notice.brief or ''
	local rich = getglobal("MiniLobbyFrameBottomNoticeText");
	if brief ~= '' then
		rich:Show();
		rich:resizeRect( rich:GetTextExtentWidth( brief ), 26 );
		rich:SetText(brief, 77, 132, 131);
		rich:ScrollFirst();	
		rich:SetDispPosX( -750 );
		rich:SetWidth( 580 );
	else
		rich:Hide();
	end
end

ARMotionCaptureSeatID = 0

--首页礼包展示
local TopGiftRedPointFirstShow = true
function MiniLobbyTopGiftShow()
	local giftConfig = GetInst("ShopConfig"):GetCfgByKey("giftConfig")
	local parentName = "MiniLobbyFrameTopGift"
	if giftConfig and giftConfig.totalSwitch == 1 and giftConfig.iconSwitch == 1 then
		getglobal("MiniLobbyFrameTopGift"):Show()

		--大厅礼包入口红点
		if giftConfig.redPointSwitch > 0 then
			local isShow = false
			local redPointTime = getkv("shop_gift_redpoint_time")
			local redPointCount = getkv("shop_gift_redpoint_count") or 0
			redPointCount = tonumber(redPointCount)
			if redPointTime then
				local today = os.date("*t")
				local secondOfToday = os.time({day=today.day, month=today.month,year=today.year, hour=0, minute=0, second=0})
				if redPointTime >= secondOfToday and redPointTime < secondOfToday + 24 * 60 * 60 then
					if redPointCount < giftConfig.redPointSwitch then
						redPointCount = redPointCount + 1
						isShow = true
					end
				else
					redPointCount = 1
					isShow = true
				end
			else
				redPointCount = redPointCount + 1
				isShow = true
			end
			if isShow and TopGiftRedPointFirstShow then
				TopGiftRedPointFirstShow = false
				GetInst("ShopConfig"):SetCfgByKey("redPointCount", redPointCount)
				getglobal("MiniLobbyFrameTopGiftRedTag"):Show()
			else
				getglobal("MiniLobbyFrameTopGiftRedTag"):Hide()
			end
		end
	else
		parentName = "MiniLobbyFrameTopActivity"
		local topParentNames = {"QQBlueVipBtn", "GuanBanFuliBtn", "7k7kBlueVipBtn", "Activity4399Btn", "YYBForumBtn", "QQBuLuoBtn", "ChannelRewardBtn"}
		for i, v in pairs(topParentNames) do
			getglobal("MiniLobbyFrameTop" .. v):SetPoint("right", parentName, "left", -14, 0)
		end
	end
	--local topParentNames = {"QQBlueVipBtn", "GuanBanFuliBtn", "7k7kBlueVipBtn", "Activity4399Btn", "YYBForumBtn", "QQBuLuoBtn", "ChannelRewardBtn"}
	--for i, v in pairs(topParentNames) do
	--	getglobal("MiniLobbyFrameTop" .. v):SetPoint("right", parentName, "left", -14, 0)
	--end
end

function CheckNeedShowExternalRecommend()
	local state, t_scheme = GetKuaishouIntentState();
	if state == 1 then
		SetKuaishouIntentState(0, nil);
		ExternalRecommendEnterGameReport(t_scheme, function(bValid)
			if bValid then
				-- ExternalRecommendSetReportPublicParam(t_scheme);
				externalrecommend_func(t_scheme)
			end
		end);
	end
end

MiniLobbyFrame_FirstShow = true;
local MiniLobbyFrame_FirstShow_EventFlag = true;

function MiniLobbyFrame_OnShow()
	-- 当天登录次数
	if MiniLobbyFrame_FirstShow then 
		pcall(function ()
			RecordCurLoginTimes()
		end)
	end 
	
	-- local nowtime = os.time()
	-- Log("enter here 11 time = " .. nowtime);
	Log("call MiniLobbyFrame_OnShow")

	-- if PerformanceTest then
	-- 	if PerformanceTest.initStatisticGlobalFunctionCallCount then
	-- 		PerformanceTest:initStatisticGlobalFunctionCallCount()
	-- 		PerformanceTest.initStatisticGlobalFunctionCallCount = nil
	-- 	end
	-- 	debug.sethook(PerformanceTest.HookGlobalFunctionCallCount, "c")
	-- end
	getglobal("MiniLobbyFrameTopActivityRoomBoxNationalDayBtnRedTag"):Hide()
	ReportTraceidMgr:setTraceid("")
	local getglobal = _G.getglobal;

	if getglobal("StandAloneFrame"):IsShown() then
		getglobal("StandAloneFrame"):Hide()
	end
	

	--大厅显示时刷新聊天悬浮球
	local hoverBallCtrl =  GetInst("MiniUIManager"):GetCtrl("ChatHoverBall")
	if hoverBallCtrl then
		hoverBallCtrl:Refresh()
	end

	local szMainlandPath = "ui/mobile/texture0/bigtex/ljdt_qukuaitu03_new.png";
	local szOverseasPath = "ui/mobile/texture0/bigtex/ljdt_qukuaitu03.png";--TODO: 下次更改贴图再更改
	--SetTextureMainlandOrOverseas("MiniLobbyFrameCenterMiniWorksPic", szOverseasPath, szOverseasPath);

	local apiId = ClientMgr:getApiId()
	if apiId == 13 or apiId == 54 then 
		threadpool:work(function()
			local uin = AccountManager:getUin()
			local nickname = AccountManager:getNickName()
			if not uin then return end
			JavaMethodInvokerFactory:obtain()
				:setClassName("org/appplay/platformsdk/TMobileSDK")
				:setMethodName("ReportUserInfo")
				:setSignature("(Ljava/lang/String;Ljava/lang/String;)V")
				:addString(tostring(uin))
				:addString(tostring(nickname))
				:call()
		end);
	end

	threadpool:work(function()
		local uin = AccountManager:getUin()
		if not uin then return end
		JavaMethodInvokerFactory:obtain()
			:setClassName("org/appplay/lib/GameBaseActivity")
			:setMethodName("setUin")
			:setSignature("(Ljava/lang/String;)V")
			:addString(tostring(uin))
			:call()
	end);

	--上报渠道用户信息数据到大数据那边
	-- OPPO VIVO T4399 应用宝 渠道
	if MiniLobbyFrame_FirstShow then
		local uploadData = nil
		local upload_url = "http://tj3.mini1.cn/miniworld";
		if IsForceRealNameChannel1 and IsForceRealNameChannel1() then 
			threadpool:work(function()
				local uin = AccountManager:getUin()
				local nickname = AccountManager:getNickName()
				local env = ClientMgr:getGameData("game_env");
				if not uin then return end
				uploadData = JavaMethodInvokerFactory:obtain()
					:setClassName("org/appplay/platformsdk/TMobileSDK")
					:setMethodName("UploadUserInfo")
					:setSignature("(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
					:addString(tostring(uin))
					:addString(tostring(nickname))
					:addString(tostring(env))
					:call()
					:getString();
					if uploadData then
						local https_header = "Content-Type: application/json;charset:utf-8"
						local function resultCallback(ret)
						end
						ns_http.func.rpc_do_http_post( upload_url, resultCallback, nil, uploadData, https_header )
					end	
				
				if TakeForceRealNameChannelInfoForJava then
					TakeForceRealNameChannelInfoForJava(1)
				end				
			end)
						
		end
		-- 华为 小米 233 渠道
		if IsForceRealNameChannel2 and IsForceRealNameChannel2() then
			threadpool:work(function()
				local uin = AccountManager:getUin()
				local nickname = AccountManager:getNickName()
				local env = ClientMgr:getGameData("game_env");
				if not uin then return end
				uploadData = JavaMethodInvokerFactory:obtain()
					:setClassName("org/appplay/platformsdk/MobileSDK")
					:setMethodName("UploadUserInfo")
					:setSignature("(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
					:addString(tostring(uin))
					:addString(tostring(nickname))
					:addString(tostring(env))
					:call()
					:getString();
					if uploadData then
						local https_header = "Content-Type: application/json;charset:utf-8"
						local function resultCallback(ret)
						end
						ns_http.func.rpc_do_http_post( upload_url, resultCallback, nil, uploadData, https_header )
					end	

				if TakeForceRealNameChannelInfoForJava then
					TakeForceRealNameChannelInfoForJava(2)
				end		
			end)
		end

		--上报registration_id
		-- if not ClientMgr:isPC() then
        local uin = AccountManager:getUin()
        local nickname = AccountManager:getNickName()
        local env = ClientMgr:getGameData("game_env");

		if Android:IsAndroidChannel(apiId) then
			threadpool:work(function()
				if not uin then return end
				uploadData = JavaMethodInvokerFactory:obtain()
					:setClassName("org/appplay/lib/AppPlayBaseActivity")
					:setMethodName("UploadRegistrationId")
					:setSignature("(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
					:addString(tostring(uin))
					:addString(tostring(nickname))
					:addString(tostring(env))
					:call()
					:getString();
					if uploadData then
						local https_header = "Content-Type: application/json;charset:utf-8"
						local function resultCallback(ret)
						end
						ns_http.func.rpc_do_http_post( upload_url, resultCallback, nil, uploadData, https_header )
						isupload_regisId = true

						uploadData = string.sub(uploadData, 8, -2)

						local ret, data = pcall(JSON.decode, JSON, uploadData)
						if ret then
							if data then
								if data.registration_id then
									setkv("up_mopush_id", tostring(data.registration_id))
								end
							end
						end

					end	
			end)
		end

        if SdkManager.uploadRegistrationId then
            local uploadData = SdkManager:uploadRegistrationId(tostring(uin),tostring(nickname),tostring(env));
            if uploadData then
                local https_header = "Content-Type: application/json;charset:utf-8"
                local function resultCallback(ret)
                end
                ns_http.func.rpc_do_http_post( upload_url, resultCallback, nil, uploadData, https_header )
                isupload_regisId = true

				local ret, data = pcall(JSON.decode, JSON, uploadData)
				if ret then
					if data then
						if data.registration_id then
							setkv("up_mopush_id", data.registration_id)
						end
					end
				end
            end 
        end
	
		-- 应用安全防护配置加载
		GetInst("VisualCfgMgr"):ReqCfg("AppSafeGuard")

		GetInst("PlayerCenterDynamicsManager"):GetRedPoint()
	end



	--欧盟未成年人保护协议
	--新手引导流程优化，将条款显示放到了最开始的引导部分
	--ShowOverseaPolisyFrame();


	threadpool:work(function()			
		--商城初始化
		ShopInit()

		--首页礼包展示
		MiniLobbyTopGiftShow()

		-- 商店迷你点入口展示
		SetMiniPointBtnShow()
		
	end);

	--统计
	threadpool:work(function()		
		ReqAdvertUserTag(function (ret, userdata)
			if ret == nil or ret[1] == nil then
				ns_advert.user_tag={}
			else
				--设置定向推送的数据
				ns_advert.user_tag = ret[1]
			end
		end)	
		
		-- if StatisticsNewWorldType == 1 then
		-- 	statisticsGameEvent(901, '%s', 'G000032')
		-- end
	end);

	threadpool:work(function()
		--新增家园金果实抽奖, 中奖信息轮播
		if GoldenFruitDetailInterface:CheckPrizePlayerInfo() then
			GoldenFruitDetailInterface:PlayNextPrizeInfo();
		else
			activeMiniLobbyRotateNitice();
		end
	end);

	--创角空昵称的保护处理
	MiniLobbyFrame_RoleNickNameProtect();
	-- 如果有创角送的装扮，推迟到这里进行尝试穿戴
	MiniLobbyFrame_TryToDressUpCreateRoleGift();
	--加载一个模型用来生成avatar头像
	HeadCtrl:LoadAvatarBody();
	--角色信息
	SetRoleInfo();
	--首次进入大厅或者是切换账号后进大厅需要请求设置一次角色信息
	if MiniLobbyFrame_FirstShow then
		GetInst("HeadInfoSysMgr"):SetPlayerRoleHeadInfo()

		--请求一下自己创作者相关信息
		GetInst("CreationCenterHomeService"):ReqUserCreatorInfo(AccountManager:getUin())
		--请求一下需要提前用到的配置信息
		GetInst("CreationCenterDataMgr"):GetAllConfigFileName()
		GetInst("CreationCenterDataMgr"):GetPreConfigFile()
	end
	AfterSetRoleInfo()
	local mini_coin = 0
	local mini_bean = 0
	if not IsStandAloneMode("") then
		mini_bean = AccountManager:getAccountData():getMiniBean()
		mini_coin = AccountManager:getAccountData():getMiniCoin()
	end
	--迷你币、迷你豆
	getglobal("MiniLobbyFrameTopMiniCoinNum"):SetText(mini_coin);
	getglobal("MiniLobbyFrameTopMiniBeanNum"):SetText(mini_bean);


	--刷新网络信号强度图标
	UpdateNetworkSignal();

	getglobal("MiniLobbyFrameBottomAR"):Hide()

	--4399
	--如果没有拉取到活动数据，不显示按钮
	if  ns_a4399 and ns_a4399.server_config and ns_a4399.server_config.gift then
		--发现有数据
		getglobal("MiniLobbyFrameTopActivity4399Btn"):Show();
	end
	--4399登录按钮
	if ClientMgr:getApiId() == 2 then
		Update4399LoginBtn();
	end

	CheckVersionParamsLoaded();

	--拉取分享活动信息,看是否有奖励显示红点
	threadpool:work(function ()
		-- threadpool:wait(1)
		if ShareGetMiniBeanType == 0 then
			ReqOpenGetMiniBeanReward()
		end
	end);	

	--工坊引导
	--[[
	if not AccountManager:getNoviceGuideState("guideworks") then
		getglobal("MiniLobbyFrameCenterMiniWorksGuide"):Show();
	else
		getglobal("MiniLobbyFrameCenterMiniWorksGuide"):Hide();
	end
	]]

	--QQ
	GongNengFrameVipBtnRefresh()
	ReportQQEvent()
	--官版
	ReportGuanBanEvent()
	--官网PC,快速登录设置密码
	local bShow = MNSJPC_FirstLoginSetPassWord()

	-- LoginManager:NotifyCustomEvent(LoginManager.EVENT_FLOATLOGIN_DLG_CONFIRM,{showType = "Security"})
	-- LoginManager:NotifyCustomEvent(LoginManager.EVENT_OPEN_ACCOUNT_UPGRADE, {mainType = 1, subType = "MinilobbySetting"})
	-- 新版本账号升级提醒检测
	if not bShow and IsEnableNewLogin and IsEnableNewLogin() then
		LoginManager:NotifyCustomEvent(LoginManager.EVENT_CHECK_OPEN_UPGRADE, {uin = AccountManager:getUin()})
	end
	
	if  MiniLobbyFrame_FirstShow then
		--特长数据
		threadpool:work(function() 
			GetInst("GeniusMgr"):CheckAndResetMyGeniusRef()
		end)

		threadpool:work(function()
			threadpool:wait(10)
			-- 针对偶现新玩家注册之后没有拉取到广告配置的问题的修改：第一次进入主界面再次请求广告配置数据
			if not GetInst("AdService"):GetAllAdConfig() then
				GetInst("AdService"):InitAllAdConfig()
			end
		end)
		
		-- 第一次进入主界面上报：参数：语言，当前皮肤风格  by fym
		-- statisticsGameEventNew(730, get_game_lang(), SkinConfigCtrl.getCurUseSkinId() - 1)

		ns_hotfix.clearErrorProtectCountPatch()   --清理热更新错误计数
		RegisterServiceListeners();
		ShopRefreshRegisterServiceListeners()
		threadpool:work(function()
			if GetInst("NSearchPlatformService") then
				-- GetInst("NSearchPlatformService"):ReqWorkSearchHotWordSync(false, false, generateRequestID(), 10)
			end
		end)
		--获取PC设备信息
		if ClientMgr:isPC() then
			if DevConfigurationInfo then
				local ResolutionInfo = DevConfigurationInfo:GetResolutionInfo()
				local SystemInfo = DevConfigurationInfo:GetSystemInfo()
				local CPUInfo = DevConfigurationInfo:GetCPUInfo()
				local MemoryInfo = DevConfigurationInfo:GetMemoryInfo()
				-- statisticsGameEvent(10200, "%lls", SystemInfo,"%lls", CPUInfo,"%s", ResolutionInfo, "%s", MemoryInfo)
			end
		end

		
		if ClientMgr:getNetworkState() == 1 then
			threadpool:work(function()
				threadpool:wait(5)
				GuideOfflineDataUpload(); --有网时上传新手埋点离线数据
				--上传单机玩家登录数据
				OfflineLoginDataUpload();
			end);		
		end
 

		--外挂检测
		if ClientMgr:isPC() then
			-- threadpool:work(function ()
			-- 	while true do 
			-- 		if CheckPCHasCrackTools() then
			-- 			return;
			-- 		end
			-- 		threadpool:wait(120)
			-- 	end 
			-- end)

			threadpool:work(function ()
				if AntiPluginHandle and g_pc_checkantiplugin_thread_onoff and ClientMgr:getApiId() ~= 999 then
					threadpool:wait(5)
					AntiPluginHandle:StartAntiPluginThread()
				end
			end)
		end
		
		MiniLobbyFrame_FirstShow_EventFlag = true;
		MiniLobbyFrame_FirstShow = false;
		local ip="";
		local accountDelay=0;
		if AccountManager.get_outer_ip_and_delay then
			ip,accountDelay= AccountManager:get_outer_ip_and_delay();
			if ReportMgr and ReportMgr.setIp then
				ReportMgr:setIp(tostring(ip))
			end
		end
		--local ip = "203.69.66.102";
		if ClientMgr:getApiId() > 300 and ip ~= "" and LoginSuccess == true then			
			threadpool:work(function()
				threadpool:wait(10)
				OverseasNetworkInformationCollection(ip,accountDelay);
			end);
			LoginSuccess = false;
		else
			Log("ip or accountDelay is nil");
		end

		InitServerUrls();

		--开发版本连接非开发服上报数据
		if env ~= 1  then
			ReportWaterInfoAfterLogin()
		end

		MapServiceInit();

		WWW_get_cf_info();

		WWW_get_self_profile();             --拉取自己的profile

		--刷新当前用户的任务信息
		--如果玩家经历了新手教程，则不在这里打开入口(新手教程的选择之后有其他地方会打开入口)
		if GetInst('UserTaskInterface') and not GetInst('UserTaskInterface'):IsFromNewbieGuide() then
			GetInst('UserTaskInterface'):UserTaskReFresh()
		end

		--上报破解工具（安卓）
		if ClientMgr:getApiId() < 100 and not IsIosPlatform() then
			ReportCrackToolsInfo();
		end

		if IsShouQChannel(ClientMgr:getApiId()) then
			if not AccountManager:getNoviceGuideState("qqvip") then
				Log("kekeke getNoviceGuideState qqvip false");
				getglobal("MiniLobbyFrameTopQQVipBtnRedTag"):Show();
			end
			StarThreadpoolRemindOpenVip();
		end

		--读取工坊地图搜索记录
		mapservice.searchRecordMap = getkv("works_search") or {};

		-- 触发活动在线时长上报
		if CheckActivityTriggerConfigEventContent(1002) then
			ActivityTriggerOnLineTimeReport()
		end

		--启动家园红点timer
		local tick_func = function()
			--print("this is one tick" .. os.time());
			if isEducationalVersion then
				return
			end

			local chestInfosNum = HomeChestMgr:getChestInfosNum();

			getglobal("MiniLobbyFrameCenterHomeChestRedTag"):Hide();
			for i=1, chestInfosNum do
				local chestInfo = HomeChestMgr:getChestInfo(i-1);

				--Log("()type="..chestInfo.type);
				--Log("()GetFruitRealState(chestInfo)="..GetFruitRealState(chestInfo));
				if nil ~= AccountManager.check_chest_bonus and AccountManager:check_chest_bonus() then
					--赠送给新手的金果实
					if ClientMgr:isEducationLiteGame() == true then return end
					getglobal("MiniLobbyFrameCenterHomeChestRedTag"):Show();
				elseif chestInfo and chestInfo.type ~= 1 and GetFruitRealState(chestInfo) == 2 then
					--非金果实, 且成熟了, 显示红点
					if ClientMgr:isEducationLiteGame() == true then return end
					getglobal("MiniLobbyFrameCenterHomeChestRedTag"):Show();
				end
			end
		end
		local finish_func;
		finish_func = function()
			--print("timer over");
			threadpool:timer(600,5, tick_func, finish_func);
		end
		threadpool:timer(600,5, tick_func, finish_func);
		-- end

		--游戏内公告定时事件
		local ingame_announce_tick_func = function()
			for idx = 1,#ns_notice_by_time do
				--print("-----------------213123213-----------" .. ns_notice_by_time[idx].id)
				if hasDisplayNoticById(ns_notice_by_time[idx].id) == 0 then
					--print("-----------------hasDisplayNoticById-----------")
					local item_start_time = ns_notice_by_time[idx].start_time
					local item_end_time   = ns_notice_by_time[idx].end_time
					local now_time = getServerTime()
					--[[
					print("-----item_start_time-----" .. item_start_time)
					print("-----item_end_time-----" .. item_end_time)
					print("-----now_time-----" .. now_time)
					]]
					--print("======================inGameAnnounceHandle:Show() 0=================")
					if now_time >= item_start_time and now_time <= item_end_time then
						local inGameAnnounceHandle = getglobal("IngameAnnouncementFrame")
						if inGameAnnounceHandle and (not inGameAnnounceHandle:IsShown() and ClientCurGame:isInGame()) then
							local content_item = ns_notice_by_time[idx]
							saveInGameAnnounceRecords(ns_notice_by_time[idx].id)
							update_announcement_content(content_item)
							--print("======================inGameAnnounceHandle:Show()=================")
							inGameAnnounceHandle:Show()
							-- statisticsGameEvent(1410,"%d",get_game_lang());
						end
					end
				end
			end
		end

		if #ns_notice_by_time > 0 then
			local last_announce_start_time = getLastAnnounceStartTime()
			local max_needed_interval = 0
			if not (last_announce_start_time < getServerTime()) then
				max_needed_interval = last_announce_start_time - getServerTime()
				local ingame_announce_finish_func;
				ingame_announce_finish_func = function()
					--print("----in game announce finished----")
				end
				threadpool:timer(max_needed_interval+10,10,ingame_announce_tick_func,ingame_announce_finish_func)
			end
		end

		--功能限制初始化
		FunctionLimitCtrl:Init();

		--对安卓平台的操作
		local apiid = ClientMgr:getApiId();
		if Android:IsAndroidChannel(apiid) then
			js_getUrlParams();
			--这里处理安卓隐私弹窗的数据上报
			GetAndroidPrivacyShow();
		end
		
		threadpool:work(function ()
			CheckMissChargeOrder();
		end);
		GetInst("InspireDataService"):GetInspireIsOpen()
		GetInst('UIEditorModelManager'):initData();
		--识别组队邀请码
		GetInst("TeamupService"):DecodeTeamInviteInfo()
		if GetInst("MusicNumShareManager") then
			GetInst("MusicNumShareManager"):OnResume()
		end
		local guideStep = GetGuideStep();
		if guideStep == nil or guideStep == 7 then
			if GetInst("ActivityAddFriendsManager") then
				GetInst("ActivityAddFriendsManager"):OnResume()
			end
			if GetInst("BoatFestivalManager") then
				GetInst("BoatFestivalManager"):OnResume()
			end
			if GetInst("MapShareInterface") then
				GetInst("MapShareInterface"):OnResume()
			end
			
			if GetInst("AotuActInterface") then
				GetInst("AotuActInterface"):OnResume()
			end
		end
		
		CSCollectRoom:GetCollectRoomIdList(true)

		GetInst("MatchTeamupService"):InitReq()
		
		if RunTeamupFun then RunTeamupFun() end

		GetInst("developerDataMgr"):InitPlayerData(function ()
			YearVoteOnlineCnt()
		end)
		GetInst("ActivityAnniversaryManager"):ReqConfig(function ()
			local startTime = GetInst("ActivityAnniversaryManager"):getTimeStamp(GetInst("ActivityAnniversaryManager").startTime)
			local endTime = GetInst("ActivityAnniversaryManager"):getTimeStamp(GetInst("ActivityAnniversaryManager").endTime)
			local curTimestamp = getServerTime()
			if curTimestamp >= startTime  and curTimestamp <= endTime then
				local CltVersion = LuaInterface and LuaInterface.getCltVersion and LuaInterface:getCltVersion() or 0
				if CltVersion  and CltVersion >= (1*65536+11*256+0) and not getkv("anniversary_invite_letter") then
					GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/activity_anniversary_letter"})
					GetInst("MiniUIManager"):OpenUI("main_letter","miniui/miniworld/activity_anniversary_letter","main_letterAutoGen")
				end
			end
		end)
		
		GetInst("CreditScoreService"):InitReq()--信用分
		RestShowNoNet()

		FriendMgr:PrepareWork()

		--开发者周报生成请求
		ReqWeeklyReport()

		--拉取赛事后台配置的赛事红点状态--原先lua配置展示赛事红点功能保持原样
		threadpool:work(function()
			threadpool:wait(0.5);--下面有拉取lua后台配置展示赛事红点，故延迟0.5s
			GetMiniLobbyFrameBottom_MatchRedTagCfg(true);
		end);

		GetInst("ResourceService"):reqPullUploadedResList()

		----断线重连检测
		-- threadpool:work(function()
		-- 	threadpool:wait(2.0);
		-- 	GetInst("MatchTeamupService"):CheckIsInMatchTeamGame()
		-- end)
	else
		MiniLobbyFrame_FirstShow_EventFlag = false;
		--主界面打开时的定期事件
		check_global_timed_event();
		
		-- 在切换账号后更新回流数据
		if GetInst("ComeBackSysConfig"):GetCfgByKey("switchaccount") then
			WWW_file_comeback_status()  -- 回流状态数据重置
			GetInst("ComeBackSysConfig"):SetSwitchAccountStatus(false)
			GetInst("ComeBackSysConfig"):SetAdventurePanelRefreshState(true)
			GetInst("ComeBackSysConfig"):SetRecordPanelRefreshState(true)
			GetInst("CreditScoreService"):InitReq()--信用分
		end
	end
	
	--请求关键词配置
	ReqKeyWordsCfg()
	ReqMiniCaptionSingleCfgData()
	CheckMyBirthdayDate()

	--Lite版拦截UI显示
	if Lite:NeedHiding() then 
		Lite:HideAllUi();
		return 
	end
	
		--底部按钮
	threadpool:work(function()
		UpdateBottomBtnState();
	end);

	--刷新活动框
	RefreshActivityAllIcons()
	getglobal("MiniLobbyFrameTopMiniBean"):Show();
	getglobal("MiniLobbyFrameTopMiniCoin"):Show();
	local isShowActivityBtn = Show_MiniLobby_ActivityBtn()
	if isShowActivityBtn then
		getglobal("MiniLobbyFrameTopActivity"):Show()
	else
		getglobal("MiniLobbyFrameTopActivity"):Hide()
	end
	getglobal("MiniLobbyFrameTopMail"):Show();
	getglobal("MiniLobbyFrameCenterHomeChest"):Show();
	--getglobal("MiniLobbyFrameBottomShrink"):Show();
	getglobal("MiniLobbyFrameBottomNotice"):Show();
	getglobal("MiniLobbyFrameBottomNoticeBkg"):Show();
	--getglobal("MiniLobbyFrameTopActivityRoomBox"):Show();

	--BattlePass红点
	RefreshBattlePassRedPoint()
	-- 判断是否需要显示悦享卡升级提示弹框
	NewBattlePass_CheckIsUpgradeCanShow()
	GetInst("NewBattlePassDataManager"):PlayMinilobbyAddExpAni()
	--7K7K贵族按钮
	Log("minilobby.lua:7k7k vipbtn");
	IsShowVip7k7kBtn(getglobal("MiniLobbyFrameTop7k7kBlueVipBtn"));

	--迷你点商城累计收益需求: 获取活动红点
	GetAdRevenueRedPointState()

	threadpool:work(function()
		-- 2022/03.30 codeby fym 获取主界面场景使用到的广告数据
		ad_data_new.getAdInfoBySence(ad_data_new.allSenceIdList.minilobby)
	end)
	
	--活动红点
	--UpdateActivityGNBtnRedTag();

	--主界面引导
	-- 7 完成引导
	minilobby_checkNewbieGuide()

	--官网PC,快速登录设置密码
	-- MNSJPC_FirstLoginSetPassWord();

	--qq版本是否显示红点
	if ShowQQVipBtn() then
		MiniLobbyFrameTopQQZoneExternalLink_HandleRedTagFlag(false);
	end
	
	if  if_show_qq_hall_btn() then
		Log("show1")
		getglobal("MiniLobbyFrameTopQQZoneExternalLinkBtn"):Show();
	else
		Log("show2")
		getglobal("MiniLobbyFrameTopQQZoneExternalLinkBtn"):Hide();
	end
	
	if ClientMgr:getApiId() == 36 then
		getglobal("MiniLobbyFrameTopVivoForumBtn"):Show();
	else
		getglobal("MiniLobbyFrameTopVivoForumBtn"):Hide();
	end

	--拉取开发者数据
	threadpool:work(function()
		threadpool:wait(0.4)
		ClientMgr:loadDeveloerInfo();
	end);

	if not getkv("skin_num") then
		setkv("skin_num",45)
	end
	
	local skinPartDefs = GetInst("ShopDataManager"):GetSkinPartDefs()
	if skinPartDefs and getkv("skin_num") and #skinPartDefs > (getkv("skin_num")) then
		setkv("skin_work_redtag1", false);
		setkv("skin_work_redtag3", false);
		setkv("skin_num",#skinPartDefs)
	end
	
	GetInst("ShopConfig"):RefreshLeftPanelRedTag() --后续看情况优化

	local env_ = get_game_env();
	--Log( "call JumpEnvFrame_OnShow, " .. env_ );
	-- 海外版本才展示
	if isAbroadEvn and isAbroadEvn() then
		if  AccountManager.get_user_birthday then	
			local t_tableInfo = AccountManager:get_user_birthday();
			if t_tableInfo and next(t_tableInfo) ~= nil then
				
			else
				print("t_tableInfo is empty()--");
				local netPower = ClientMgr and ClientMgr.getNetworkSignal and ClientMgr:getNetworkSignal() or 0;
				if GetNetworkState() ~= 0 and netPower > 1 and not IsStandAloneMode("")  then
					getglobal("MiniLobbyFrameBirthSelect"):Show()
				end
			end

		end
	end

	--成就系统上报:持续登录
	threadpool:work(function()
		threadpool:wait(5)
		ArchievementGetInstance().func:checkLoginCount();
	end);

	threadpool:work(function()
		--个人中心帖子回复红点
		ZoneSetPostingRedTagState(true);

		--成就系统红点初次显示
		UIAchievementMgr:GetRedTagState();
	end);	

	AccountGameModeClass:UpGameModeUI();

	threadpool:work(function()
		threadpool:wait(0.5)
		--如果没有同步我的地图信息，主动同步，主要是要拿已[Desc5]存档位信息
		RequestBoughtArchiveNum()
	end);	
	
	if getkv("IsShownCharacterActionRedTag") then 
		getglobal("CharacterActionRedTag"):Hide()
	else
		getglobal("CharacterActionRedTag"):Show()
	end 

	--重置密码红点
	UpdateResetPasswordRedTag()

	if (NewbieGuideManager and NewbieGuideManager:GetGuideFinishFlag(NewbieGuideManager.GUIDE_FLAG_GO_HALL)) then
		--运营配置强弹（提取到外面，无需等待2S）
		GetInst("ActivityPopupManager"):CheckForStrongPopup()
		--强弹窗检查
		threadpool:delay(2.0, function ()
			-- 新赛季特写界面展示与否判断
			CheckBPNewSeasonIsNeedPopUp()
	
			-- 触发活动强弹检测
			CheckActivityTriggerEntranceIsShow()
	
			CheckWeekendGiftPopUp()
		end)
	end

	local bindQQBtn = getglobal("MiniLobbyFrameTopBindQQBtn")
	local bindBtnQQRedTag = getglobal("MiniLobbyFrameTopBindQQBtnRedTag")

	if isShouQPlatform() then
		bindQQBtn:Hide()
		bindBtnQQRedTag:Hide()
		--新版手Q渠道 56
		--打开大厅界面的好友列表
		if iOSShouQConfig(3,true) then
			GetInst("UIManager"):Open("MiniLobbyShouQFriends")
		end
		if isAndroidShouQ() then
			threadpool:work(function()
				local shouq_config = ns_version.qqvip
				if shouq_config and shouq_config.open == 1 then
					getglobal("MiniLobbyFrameTopShouqBtn"):Show();
					-- 处理小红点的逻辑
					local shouq_config_red = shouq_config.red_mark;
					if shouq_config_red then
						local cd = shouq_config_red.cd; --后台配置的时间间隔
						local count = shouq_config_red.count; --后台配置的展示次数
						local currentTime = os.time();
						local lastTime = getkv("shouq_red_tag") or 0; --上次显示小红点的时间
						if currentTime - lastTime >= cd and count > 0 then
							getglobal("MiniLobbyFrameTopShouqBtnRedTag"):Show();
							setkv("shouq_red_tag", currentTime);
							shouq_config_red.count = count - 1;
						end
					end
				end
			end)
		else
			if iOSShouQConfig(8,false) and not isIOSShouQ() then
				getglobal("MiniLobbyFrameTopShouqBtn"):Show();
			else
				getglobal("MiniLobbyFrameTopShouqBtn"):Hide();
				getglobal("MiniLobbyFrameTopShouqBtnRedTag"):Hide();
			end
		end
	else
		if IsUIFrameShown("MiniLobbyShouQFriends") then
			GetInst("UIManager"):Close("MiniLobbyShouQFriends")
		end
		getglobal("MiniLobbyFrameTopShouqBtn"):Hide();
		getglobal("MiniLobbyFrameTopShouqBtnRedTag"):Hide();
		local hasBindedQQ = AccountManager.isbindopenid and AccountManager:isbindopenid("qq") or false;
		if iOSBindingQQIcon(1) and not hasBindedQQ and isIOSShouQ() then
			bindQQBtn:Show()
			if iOSBindingQQIcon(2) then
				bindBtnQQRedTag:Hide()
			else
				bindBtnQQRedTag:Hide()
			end
		else
			bindQQBtn:Hide()
			bindBtnQQRedTag:Hide()
		end
	end
	
	threadpool:work(function ()
		if not gLoadOtherUserWorlds then
			LoadOtherUserWorlds()
		end
		WWW_file_rent_advert_config()
	end)
	-- Log("enter here 11 time = " .. (os.time()- nowtime));

	----MiniLobbyFrame_OnShow 这个登录或者未登录或者其他界面跳转到MiniLobbyFrame主界面这里，我加一个lua的事件，后续要在进到这个界面做一些事情可以注册这个事件的处理，同时要注意一下要做的事情是做一次还是每次跳转到MiniLobbyFrame主界面都做。
	GameEventQue:postEnterMiniLobbyFrame(MiniLobbyFrame_FirstShow_EventFlag)

	if ClientMgr.isHarmony and ClientMgr:isHarmony() then
		getglobal("MiniLobbyFrameARDressDiamondBtn"):Show();
		getglobal("MiniLobbyFrameARDressBtn"):Show();
		local firstTimeToShowARDressBtn = getkv("firstTimeToShowARDressBtn");
		firstTimeToShowARDressBtn = false;
		if not firstTimeToShowARDressBtn then
			getglobal("MiniLobbyFrameARDressDiamondBtnRedTag"):Show();
		end
		ARDressBtnAnimations:start()
	end

	--请求玩家首充状态
	MiniLobbyFrame_ReqFirstRechargeStatus()
	--展示领奖气泡提示
	MiniLobbyNoviceTaskBtn_OnShow()
	DeepLinkQueue:dequeue();

	EnterMainMenuInfo.EnterMainMenuBy = ''

	NationalDayOnlineCnt()


	CheckRealNameInfoTips()

	MiniLobbyNewNoviceTaskBtnCheckBubble()

	-- TODO：0427-暂时不做首页工坊UI修改
	-- threadpool:work(function()
    --     GetInst("CreationCenterDataMgr"):ReqCreatorCenterCfg(
    --         function (isOpenNewCC)
    --             if isOpenNewCC then 
    --                 local miniLbyBtn = getglobal("MiniLobbyFrameCenterResourceShopBt")
    --                 if miniLbyBtn then 
    --                     miniLbyBtn:Hide()
    --                 end 
                    
    --                 local miniLbyLbl = getglobal("MiniLobbyFrameCenterMiniWorksName")
    --                 if miniLbyLbl then 
    --                     miniLbyLbl:SetText(GetS(6660001))
    --                 end 
    --             end
    --         end
    --     )
    -- end)

	CheckFriendBubbleNotify()

	CheckAndInitFriendBubbleService()

	if GetInst("RecommendOnlineFriendDataMgr") then
		GetInst("RecommendOnlineFriendDataMgr"):OnLobbyShow()
	end

	-- Vip续订拍脸图
	ShowVipRenewActivity()
	
	-- 拉一次消息中心的新消息数量
	if GetInst("MessageCenterDataMgr") then
		threadpool:work(function()
			GetInst('MessageCenterDataMgr'):RequestTabMsgNewsCount(nil, function() 
				UpdateMiniLobbyFrameMailRedTag()
			end)
		end)
	end


	GetInst("BestPartnerDataMgr"):ReqAccountPartnerData() -- 拉取本账号的拍档数据

	-- if GetInst("AggActInterface") then
	-- 	GetInst("AggActInterface"):OnLobbyShow()
	-- end
	GetInst("MapShareInterface"):CheckStreamerCode()
	if ReportDeepLinkExternOnLobbyShow then
		ReportDeepLinkExternOnLobbyShow()
	end
end

function RecordCurLoginTimes()
	local loginJson = getkv("CURLOGIN_TIMES_STAMP")
	local nowStamp = AccountManager:getSvrTime()
	if loginJson and loginJson ~= "" then 
		local loginData = JSON:decode(loginJson)
		if loginData and loginData.times and loginData.stamp then 
			local oldStamp = loginData.stamp 
			if IsSameDay(oldStamp, nowStamp) then
				local loginTimes = loginData.times 
				local jsonStr = JSON:encode({times=loginTimes+1, stamp=nowStamp}) 
				setkv("CURLOGIN_TIMES_STAMP", jsonStr)
			else 
				local jsonStr = JSON:encode({times=1, stamp=nowStamp})
				setkv("CURLOGIN_TIMES_STAMP", jsonStr)
			end 
		end 
	else 
		local jsonStr = JSON:encode({times=1, stamp=nowStamp})
		setkv("CURLOGIN_TIMES_STAMP", jsonStr)
	end 
end 

--开始联机大厅引导
function minilobby_showOnlineHallGuide()
    GetInst('UserTaskInterface'):SetNewbieGuideStatu(0)
	-- 开始主界面引导
	getglobal("MiniLobbyFrameNewGuide"):Show()
	-- 联机层级在上面
	getglobal("MiniLobbyFrameCenterMultiplayer"):SetFrameLevel(2100)

	standReportEvent("3901", "NEWPLAYER_GUIDE_TAP", "Tap", "view")

	bolOnlineHallGuide = true
end

--检查新手指引
function minilobby_checkNewbieGuide()
	if NewbieGuideManager and NewbieGuideManager:IsABSwitchV13() then
		if NewbieGuideManager:CheckShowOnlineHallGuide() then
			if not NewbieGuideManager:GetGuideFinishFlag(NewbieGuideManager.GUIDE_BE_LOST) then
				NewbieGuideManager:openBeLostV13()
			elseif NewbieGuideManager.needOpenRewardV13 and not getkv("pop_skin_try_on") and
				NewbieGuideManager:GetGuideFinishFlag(NewbieGuideManager.GUIDE_FLAG_GO_ALONE) then
				GetInst('UserTaskInterface'):UserTaskReFresh()

				-- 完成主界面引导
				SetGuideStep(7)
				if getglobal("MiniLobbyFrameNewGuide"):IsShown() then
					getglobal("MiniLobbyFrameNewGuide"):Hide()
					if GetInst("NewbieSocialDataMgr") then
						GetInst("NewbieSocialDataMgr"):OnGuideEnd()
					end
				end
			elseif not NewbieGuideManager.needOpenRewardV13 and
				not NewbieGuideManager:GetGuideFinishFlag(NewbieGuideManager.GUIDE_FLAG_GO_ALONE) then
				minilobby_showOnlineHallGuide()
			end
		else
			-- 完成主界面引导
			SetGuideStep(7)
			if getglobal("MiniLobbyFrameNewGuide"):IsShown() then
				getglobal("MiniLobbyFrameNewGuide"):Hide()
				if GetInst("NewbieSocialDataMgr") then
					GetInst("NewbieSocialDataMgr"):OnGuideEnd()
				end
			end
		end
	elseif NewbieGuideManager:CheckShowOnlineHallGuide() then
		minilobby_showOnlineHallGuide()
	else
		SetGuideStep(7)
		if getglobal("MiniLobbyFrameNewGuide"):IsShown() then
			getglobal("MiniLobbyFrameNewGuide"):Hide()
			if GetInst("NewbieSocialDataMgr") then
				GetInst("NewbieSocialDataMgr"):OnGuideEnd()
			end
		end
		
		GameUIGuideStep = GetUIStepByGuideStep()
		-- 先隐藏存档滑动栏指引引导
		HideMapSlidingFrameGuide()

		if GameUIGuideStep > 0 then
			getglobal("MiniLobbyFrameGuide"):Show();
			UpdateGameUIGuide();
		else
			getglobal("MiniLobbyFrameGuide"):Hide();
		end

		if GameUIGuideStep > 0  and getglobal("MiniLobbyFrameGuide"):IsShown() then
			--当退出新手教学时IsSkipFromGuideOrFirstMap != nil,重新登录时 IsSkipFromGuideOrFirstMap = nil 	 
			--埋点，进入主界面（仅触发主界面引导时上报） 设备码,玩家来源(1.完成新手教程、2.跳过新手教程),触发场景(1.从冒险地图内退出触发、2.重登后触发),用户类型,语言
			-- statisticsGameEventNew(964,ClientMgr:getDeviceID(),(IsFirstEnterNoviceGuide and not enterGuideAgain) and 1 or 2,IsSkipFromGuideOrFirstMap and 1 or 2,
			-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
			StatisticsTools:send(true, true)
		end

		--创建地图引导
		CreateMapGuide();
	end
end

--检查一下实名信息提示
function CheckRealNameInfoTips()
	local myUin = AccountManager:getUin()
	local key = "HaveBeenWarnRealNameInfo_"..myUin
	if getkv(key) then
		--已经提醒过了
		return
	end

	if not AccountManager.get_channel_realname_info then
		return
	end
	
	-- local realname_info_res = {
	-- 	isrealname = false, -- 是否实名
	-- 	use_channel_realname = false,  -- 是否使用渠道实名
	-- 	channel_name = '', -- 渠道名称
	-- }
	local retTab = AccountManager:get_channel_realname_info() or {}
	if not retTab.isrealname then
		return
	end

	setkv(key, true)
	if retTab.use_channel_realname then
		--渠道实名 的 才需要弹框 “本游戏已同步你XXX账号的实名认证，游戏中无需再次认证。现在你已完成实名认证，可以正常进入游戏。”
		MessageBoxFrame2:Open(5, GetS(1000936), GetS(1000931, retTab.channel_name or ""), function(btn) end)
	end
end

--登录成功后查询一下漏掉的[Desc2]订单
function CheckMissChargeOrder()
	local apiId = ClientMgr:getApiId()
	if apiId == 7 then
		--华为查询补单
		JavaMethodInvokerFactory:obtain()
			-- :debug(true)
			:setClassName("org/appplay/platformsdk/MobileSDK")
			:setMethodName("onHwReplenishmentOrder")
			:setSignature("()V")
			:call();
	end
end

function MiniLobbyFrame_OnHide()
	if isShouQPlatform() then
		if GetInst("UIManager"):GetCtrl("MiniLobbyShouQFriends", "uiCtrlOpenList") then
			GetInst("UIManager"):GetCtrl("MiniLobbyShouQFriends", "uiCtrlOpenList"):CloseBtnClicked()
		end
	end
	GetInst("ChatHelper"):OpenChatHoverBallView()
	GetInst("ActivityPopupManager"):RemoveAllActivity()
end

--官网PC版本apiId=110, 如果未设置密码则强制显示设置密码框(快速登录)
function MNSJPC_FirstLoginSetPassWord()
	-- 这里添加渠道的时候，ActivateAccountFrameCloseBtn_OnClick() 那里也处理下
	if NewAccountHelper:IsForceAccountSetPassword() then
		--[[
		local account_login_frame = getglobal("ActivateAccountFrame");
		if nil ~= account_login_frame then
			account_login_frame:Show();

			local set_passwd_btn = getglobal("AccountLoginFrameActivateBtn");
			if nil ~= set_passwd_btn then
				set_passwd_btn:Show();
			end

			--隐藏关闭按钮
			--getglobal("AccountLoginFrameCloseBtn"):Hide();
		end
		]]

		-- SetAccountLoginFrame(1);
		NewAccountHelper:IntergateSetAccountLoginFrame({
			setType = NewAccountHelper.PASSWORD_SET,
		})	
		return true
	end

	return false
end

--防沉迷:每天首次登录提醒
function FirstAntiAddictionTip()
	Log("FirstAntiAddictionTip:");
	--20180125:不校验是否为同一天, 每次登陆, 只要没认证, 都弹框.
	--if ClientMgr:IsNeedAntiAddictionTip() then
		AntiAddictionTip();
	--end
end

--防沉迷提醒
function AntiAddictionTip()
	Log("AntiAddictionTip:");
	if ClientMgr:getAudit() == 2 then
		Log("AntiAddictionTip: Don`t Audit !!! ApiId = " .. ClientMgr:getApiId());
		if isQQGamePc() or ClientMgr:getApiId() == 109 or ClientMgr:getApiId() == 129 or (ClientMgr:getApiId() >= 121 and ClientMgr:getApiId() <=127) then
			MessageBox(17, StringDefCsv:get(4837));
			getglobal("MessageBoxFrame"):SetClientString("立即认证");
		end
	end
end

function UpdateGameUIGuide()
	getglobal("MiniLobbyFrameGuideContentNextBtnText"):SetText(GetS(3772));
	isFirstClickGuide = isFirstClickGuide+1;
	if GameUIGuideStep == 1 then
		getglobal("MiniLobbyFrameCenterLocalMap"):SetFrameLevel(2100);
		getglobal("MiniLobbyFrameGuideContent"):SetPoint("bottomleft", "MiniLobbyFrameCenterLocalMap", "bottom", 220, -100);
		getglobal("MiniLobbyFrameGuideContentText"):SetText(GetS(3773));

		-- 第一次点击才统计上报
		
		-- if isFirstClickGuide == 1 then
		-- 	statisticsGameEvent(901, '%s', "UIGuideLocalMap","%d",GuideLobby,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
		-- end
		standReportEvent("39", "NEWPLAYER_HOMEPAGE_GUIDE", "StartGame", "view");
	elseif GameUIGuideStep == 2 then
		getglobal("MiniLobbyFrameCenterLocalMap"):SetFrameLevel(1000);
		getglobal("MiniLobbyFrameCenterMultiplayer"):SetFrameLevel(2100);
		--getglobal("MiniLobbyFrameGuideContentBkg"):setUvType(4);
		getglobal("MiniLobbyFrameGuideContent"):SetPoint("bottomright", "MiniLobbyFrameCenterMultiplayer", "bottom", -120, -100);
		getglobal("MiniLobbyFrameGuideContentText"):SetText(GetS(3774));


		-- if isFirstClickGuide == 1 then
		-- 	statisticsGameEvent(901, '%s', "UIGuideMultiplayer","%d",GuideLobby,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
		-- end
		standReportEvent("39", "NEWPLAYER_HOMEPAGE_GUIDE", "MutiplayerLobby", "view");
	elseif GameUIGuideStep == 3 then
		getglobal("MiniLobbyFrameCenterMultiplayer"):SetFrameLevel(1000);
		getglobal("MiniLobbyFrameCenterMiniWorks"):SetFrameLevel(2100);
		--getglobal("MiniLobbyFrameGuideContentBkg"):setUvType(2);
		getglobal("MiniLobbyFrameGuideContent"):SetPoint("topright", "MiniLobbyFrameCenterMiniWorks", "left", 25, 55);
		getglobal("MiniLobbyFrameGuideContentText"):SetText(GetS(3775));


		-- if isFirstClickGuide == 1 then
		-- 	statisticsGameEvent(901, '%s', "UIGuideMiniWorks","%d",GuideLobby,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
		-- end
		standReportEvent("39", "NEWPLAYER_HOMEPAGE_GUIDE", "WorkShop", "view");
	elseif GameUIGuideStep == 4 then
		getglobal("MiniLobbyFrameCenterMiniWorks"):SetFrameLevel(1000);
		getglobal("MiniLobbyFrameCenterHomeChest"):SetFrameLevel(2100);
		--getglobal("MiniLobbyFrameGuideContentBkg"):setUvType(4);
		getglobal("MiniLobbyFrameGuideContent"):SetPoint("bottomright", "MiniLobbyFrameCenterHomeChest", "left", 25, 55);
		getglobal("MiniLobbyFrameGuideContentText"):SetText(GetS(3776));
		getglobal("MiniLobbyFrameGuideContentNextBtnText"):SetText(GetS(3777));


		-- if isFirstClickGuide == 1 then
		-- 	statisticsGameEvent(901, '%s', "UIGuideHomeChest","%d",GuideLobby,"save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
		-- end
		standReportEvent("39", "NEWPLAYER_HOMEPAGE_GUIDE", "MyHomeland", "view");
	end
end

function UpdateBottomBtnState()

	MiniLobbyFrameBottomShrink = false;

	if MiniLobbyFrameBottomShrink then
		Log("UpdateBottomBtnState Hide");
		--getglobal("MiniLobbyFrameBottomShrinkNormal"):SetAngle(180);
		--getglobal("MiniLobbyFrameBottomShrinkPushedBG"):SetAngle(180);
		getglobal("MiniLobbyFrameBottomShop"):Hide();
		getglobal("MiniLobbyFrameBottomBuddy"):Hide();
		getglobal("MiniLobbyFrameBottomCommunity"):Hide();
		getglobal("MiniLobbyFrameBottomFacebookThumbUp"):Hide();
		getglobal("MiniLobbyFrameBottomSubscribe"):Hide();
		getglobal("MiniLobbyFrameBottomVideoLive"):Hide();
	else
		--Log("UpdateBottomBtnState Show");
		--getglobal("MiniLobbyFrameBottomShrinkNormal"):SetAngle(0);
		--getglobal("MiniLobbyFrameBottomShrinkPushedBG"):SetAngle(0);
		--单机模式不显示
		if IsStandAloneMode("") then 
			-- getglobal("MiniLobbyFrameBottomBuddy"):Hide();
			getglobal("MiniLobbyFrameBottomCommunity"):Hide();
			-- getglobal("MiniLobbyFrameBottomFacebookThumbUp"):Hide();
			getglobal("MiniLobbyFrameBottomSubscribe"):Hide();
			getglobal("MiniLobbyFrameBottomVideoLive"):Hide();
			getglobal("MiniLobbyFrameBottomMatch"):Hide();
			getglobal("MiniLobbyFrameBottomBattlePass"):Hide()
			
			return
		end

		getglobal("MiniLobbyFrameBottomShop"):Show();
		getglobal("MiniLobbyFrameBottomBuddy"):Show();
		--手Q渠道要替换好友图标
		if (isIOSShouQ() and iOSShouQConfig(2,false)) or isAndroidShouQ() then
			getglobal("MiniLobbyFrameBottomBuddyIcon"):SetTexUV("icon_qq_hall");
		else
			getglobal("MiniLobbyFrameBottomBuddyIcon"):SetTexUV("icon_friend_hall");
		end

        --创作中心
        CheckBottomDeveloperCenterShow();

		--社区按钮
		CheckBottomCommunityShow();

		--facebook 点赞
		CheckBottomFacebookThumbUpShow();

		--直播按钮
		CheckBottomVideoLiveUpShow();

		--订阅
		MiniLobbyFrameBottomSubscribeUpShow();

		--赛事
		MiniLobbyFrameBottomMatchUpShow();

		--BattlePass
		MiniLobbyFrameBottomBattlePassUpShow();


		MiniLobbyFrameBottomButton_HandleRedTag("Community");

		--if not getkv("video_live_has_been_opened") then
		--	getglobal("MiniLobbyFrameBottomVideoLiveRedTag"):Show();
		--end

		MiniLobbyFrameBottomButton_HandleRedTag("VideoLive");

		if getglobal("MiniLobbyFrameBottomSubscribe"):IsShown() then
			MiniLobbyFrameBottomButton_HandleRedTag("Subscribe");
		end

		if getglobal("MiniLobbyFrameBottomFacebookThumbUp"):IsShown() then
			MiniLobbyFrameBottomButton_HandleRedTag("FacebookThumbUp");
		end

		if getglobal("MiniLobbyFrameBottomMatch"):IsShown() then
			MiniLobbyFrameBottomButton_HandleRedTag("Match");
			GetMiniLobbyFrameBottom_MatchRedTagCfg();
		end
	end

end

--创作中心入口
function CheckBottomDeveloperCenterShow()
     --是否显示创作中心按钮
	 local b_show = check_apiid_ver_conditions(ns_version.devcenter_btn);
	 if b_show then
		 getglobal("MiniLobbyFrameBottomDeveloperCenter"):Show();
	 else
		 getglobal("MiniLobbyFrameBottomDeveloperCenter"):Hide();
	 end
end

--社区按钮
function CheckBottomCommunityShow()
	Log( "call CheckBottomCommunityShow" );
	if  ns_version and ns_version.btn and ns_version.btn.community == 1 then		
		--是否打开PC
		local apiId = ClientMgr:getApiId();
		if  apiId ==999 or (apiId>100 and apiId<200) or (apiId>300 and apiId<400) then
			--pc
			if  ns_version.shequ and ns_version.shequ.url_pc2 then
				--打开PC
				ns_version.shequ.url = ns_version.shequ.url_pc2;
			else
				Log( "pc not open" );
				--if  apiId ==999 then
					--ns_version.shequ.url_pc2 = ns_version.shequ.url_mb2;
				--end
				return;
			end
		else
			--mb
			if  ns_version.shequ and ns_version.shequ.url_mb2 then
				--打开mobile
				ns_version.shequ.url = ns_version.shequ.url_mb2;
			else
				Log( "mb not open" );
				return;
			end			
		end


		--标准检测开关
		if  not check_apiid_ver_conditions( ns_version.shequ ) then
			Log("check_apiid_ver_conditions shequ not open")
			return;
		end


		--是否登录成功
		local s2, s2t = get_login_sign();
		if  s2t and  #s2t > 10 then
			getglobal("MiniLobbyFrameBottomCommunity"):Show();
            if getglobal("MiniLobbyFrameBottomDeveloperCenter"):IsShown() then
                getglobal("MiniLobbyFrameBottomCommunity"):SetPoint("right", "MiniLobbyFrameBottomDeveloperCenter", "left", 0, 0);
            else
                getglobal("MiniLobbyFrameBottomCommunity"):SetPoint("right", "MiniLobbyFrameBottomShop", "left", 0, 0);
            end
		else
			Log( "not login s2" );
		end
	else
		Log( "no community btn" );
	end
end

--直播按钮
function CheckBottomVideoLiveUpShow()
	local apiids_no = check_apiid_ver_conditions(ns_version.zhibo_btn);
	if apiids_no then
		if getglobal("MiniLobbyFrameBottomFacebookThumbUp"):IsShown() then
			getglobal("MiniLobbyFrameBottomVideoLive"):SetPoint("right", "MiniLobbyFrameBottomFacebookThumbUp", "left", 0,0);
		elseif getglobal("MiniLobbyFrameBottomCommunity"):IsShown() then
			getglobal("MiniLobbyFrameBottomVideoLive"):SetPoint("right", "MiniLobbyFrameBottomCommunity", "left", 0,0);
        elseif getglobal("MiniLobbyFrameBottomDeveloperCenter"):IsShown() then
            getglobal("MiniLobbyFrameBottomVideoLive"):SetPoint("right", "MiniLobbyFrameBottomDeveloperCenter", "left", 0,0);
		elseif getglobal("MiniLobbyFrameBottomShop"):IsShown() then
			getglobal("MiniLobbyFrameBottomVideoLive"):SetPoint("right", "MiniLobbyFrameBottomShop", "left", 0,0);
		end
		getglobal("MiniLobbyFrameBottomVideoLive"):Show();
	end
end

--facebook 点赞
function CheckBottomFacebookThumbUpShow()
	Log( "call CheckBottomFacebookThumbUpShow" );
	if if_open_facebook_prize() then
		--是否登录成功

		--[[
					local s2, s2t = get_login_sign();
		if  s2t and  #s2t > 10 then
			getglobal("MiniLobbyFrameBottomFacebookThumbUp"):Show();
		else
			Log( "not login s2" );
		end
		--]]

		if not getglobal("MiniLobbyFrameBottomCommunity"):IsShown() then
			getglobal("MiniLobbyFrameBottomFacebookThumbUp"):Show();
		end
		--13岁保护模式特殊处理: 不让点击, 点击飘字
		if IsProtectMode() then
			getglobal("MiniLobbyFrameBottomFacebookThumbUp"):Hide();			
		end
	else
		Log( "facebook_thumbup is not open" );
	end
end

-- 订阅页里两张图片的请求逻辑
function SubscribePictureReq(url, frameName)
	local filePath = g_photo_root .. getHttpUrlLastPart(url) .. "_"
	local function finishCb()
		local fsize = gFunc_getStdioFileSize(filePath)/1000
		if fsize > 0 then
			setkv(url, filePath)
			getglobal(frameName.."Normal"):SetTexture(filePath)
			getglobal(frameName.."PushedBG"):SetTexture(filePath)
		end
	end
	ns_http.func.downloadPng(url, filePath, nil, nil, finishCb())
end

-- 订阅按钮
function MiniLobbyFrameBottomSubscribeUpShow()
	ns_version.qq_share = ns_version.qq_share or {}
	local apiId = ClientMgr:getApiId();
	local ns_wx_wb=check_apiid_ver_conditions(ns_version.qq_share.wx_wb_pub);
	if  (apiId ==999 or apiId<300)  and  ns_wx_wb then
		-- 从CDN下载新图片
		if ns_version.subscribe and ns_version.subscribe.option1 and ns_version.subscribe.option2 then
			local pic1_url = ns_version.subscribe.option1.pic1_url;
			local pic2_url = ns_version.subscribe.option2.pic2_url;
			local function download_subscribe_pic_cb(picPath, frameName)
				local btnNormal = getglobal(frameName.."Normal")
				local btnNormal = getglobal(frameName.."Normal")
			end
			if pic1_url then
				--上方图片
				SubscribePictureReq(pic1_url, "SubscribeFrameWeChatBtn");
			end
			if pic2_url then
				--下方图片
				SubscribePictureReq(pic2_url, "SubscribeFrameWeiboBtn");
			end
		end

		-- 大厅订阅号入口改为公众号
		if true then
			getglobal("MiniLobbyFrameBottomSubscribeName"):SetText(GetS(110102))
		end

		if getglobal("MiniLobbyFrameBottomVideoLive"):IsShown() then
			getglobal("MiniLobbyFrameBottomSubscribe"):SetPoint("right", "MiniLobbyFrameBottomVideoLive", "left", 0,0);
			getglobal("MiniLobbyFrameBottomSubscribe"):Show();
		elseif getglobal("MiniLobbyFrameBottomCommunity"):IsShown() or getglobal("MiniLobbyFrameBottomFacebookThumbUp"):IsShown() then
			if getglobal("MiniLobbyFrameBottomCommunity"):IsShown() then 
				getglobal("MiniLobbyFrameBottomSubscribe"):SetPoint("right", "MiniLobbyFrameBottomCommunity", "left", 0,0);
				getglobal("MiniLobbyFrameBottomSubscribe"):Show();
			end
			if getglobal("MiniLobbyFrameBottomFacebookThumbUp"):IsShown() then
				getglobal("MiniLobbyFrameBottomSubscribe"):SetPoint("right", "MiniLobbyFrameBottomFacebookThumbUp", "left", 0,0);
				getglobal("MiniLobbyFrameBottomSubscribe"):Show();
			end
        elseif getglobal("MiniLobbyFrameBottomDeveloperCenter"):IsShown() then
            getglobal("MiniLobbyFrameBottomSubscribe"):SetPoint("right", "MiniLobbyFrameBottomDeveloperCenter", "left", 0,0);
            getglobal("MiniLobbyFrameBottomSubscribe"):Show();
		else
			if getglobal("MiniLobbyFrameBottomShop"):IsShown() then
				getglobal("MiniLobbyFrameBottomSubscribe"):SetPoint("right", "MiniLobbyFrameBottomShop", "left", 0,0);
				getglobal("MiniLobbyFrameBottomSubscribe"):Show();
			end
		end	
	end
end

-- 赛事按钮
function MiniLobbyFrameBottomMatchUpShow()
	Log( "call MiniLobbyFrameBottomMatchUpShow" );
	if  check_apiid_ver_conditions( ns_version.match ) then
		--是否打开PC
		local apiId = ClientMgr:getApiId();
		if  apiId ==999 or (apiId>100 and apiId<200) or (apiId>400 and apiId<500) then
			--pc
			if  ns_version.match and ns_version.match.url_pc then
				--打开PC
				ns_version.match.url = ns_version.match.url_pc;
			else
				Log( "pc not open" );
				return;
			end
		else
			--mb
			if  ns_version.match and ns_version.match.url_mb then
				--打开mobile
				ns_version.match.url = ns_version.match.url_mb;
			else
				Log( "mb not open" );
				return;
			end
		end
		if getglobal("MiniLobbyFrameBottomSubscribe"):IsShown() then
			getglobal("MiniLobbyFrameBottomMatch"):SetPoint("right", "MiniLobbyFrameBottomSubscribe", "left", 0,0);
		elseif getglobal("MiniLobbyFrameBottomVideoLive"):IsShown() then
			getglobal("MiniLobbyFrameBottomMatch"):SetPoint("right", "MiniLobbyFrameBottomVideoLive", "left", 0,0);
		elseif getglobal("MiniLobbyFrameBottomFacebookThumbUp"):IsShown()  then
			getglobal("MiniLobbyFrameBottomMatch"):SetPoint("right", "MiniLobbyFrameBottomFacebookThumbUp", "left", 0,0);
		elseif getglobal("MiniLobbyFrameBottomCommunity"):IsShown()  then
			getglobal("MiniLobbyFrameBottomMatch"):SetPoint("right", "MiniLobbyFrameBottomCommunity", "left", 0,0);
        elseif getglobal("MiniLobbyFrameBottomDeveloperCenter"):IsShown() then
            getglobal("MiniLobbyFrameBottomMatch"):SetPoint("right", "MiniLobbyFrameBottomDeveloperCenter", "left", 0,0);
		elseif getglobal("MiniLobbyFrameBottomShop"):IsShown()  then
			getglobal("MiniLobbyFrameBottomMatch"):SetPoint("right", "MiniLobbyFrameBottomShop", "left", 0,0);
		end
		getglobal("MiniLobbyFrameBottomMatch"):Show();
	else
		Log( "no Match btn" );
	end
end

-- BattlePass按钮
function MiniLobbyFrameBottomBattlePassUpShow()
	Log( "call MiniLobbyFrameBottomBattlePassUpShow" );
	if  ns_shop_config2 and check_apiid_ver_conditions(ns_shop_config2.battle_pass_sell) then	--根据配置确定是否开启BattlePass
		--是否打开PC
		if getglobal("MiniLobbyFrameBottomMatch"):IsShown() then
			getglobal("MiniLobbyFrameBottomBattlePass"):SetPoint("right", "MiniLobbyFrameBottomMatch", "left", 0,0)
		elseif getglobal("MiniLobbyFrameBottomSubscribe"):IsShown() then
			getglobal("MiniLobbyFrameBottomBattlePass"):SetPoint("right", "MiniLobbyFrameBottomSubscribe", "left", 0,0)
		elseif getglobal("MiniLobbyFrameBottomVideoLive"):IsShown() then
			getglobal("MiniLobbyFrameBottomBattlePass"):SetPoint("right", "MiniLobbyFrameBottomVideoLive", "left", 0,0)
		elseif getglobal("MiniLobbyFrameBottomFacebookThumbUp"):IsShown()  then
			getglobal("MiniLobbyFrameBottomBattlePass"):SetPoint("right", "MiniLobbyFrameBottomFacebookThumbUp", "left", 0,0)
		elseif getglobal("MiniLobbyFrameBottomCommunity"):IsShown()  then
			getglobal("MiniLobbyFrameBottomBattlePass"):SetPoint("right", "MiniLobbyFrameBottomCommunity", "left", 0,0)
        elseif getglobal("MiniLobbyFrameBottomDeveloperCenter"):IsShown() then
            getglobal("MiniLobbyFrameBottomBattlePass"):SetPoint("right", "MiniLobbyFrameBottomDeveloperCenter", "left", 0,0);
		elseif getglobal("MiniLobbyFrameBottomShop"):IsShown()  then
			getglobal("MiniLobbyFrameBottomBattlePass"):SetPoint("right", "MiniLobbyFrameBottomShop", "left", 0,0)
		end
		getglobal("MiniLobbyFrameBottomBattlePass"):Show();
		local param = getglobal("MiniLobbyFrameBottomBattlePassRedTag"):IsShown() and 1 or 0
		local redIsShow = getglobal('MiniLobbyFrameBottomMatchRedTag'):IsShown() and 1 or 0
		MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_BOTTOM_1", "BattlePass", "view", { standby1 = param, standby2 = redIsShow})
	else
		getglobal("MiniLobbyFrameBottomBattlePass"):Hide()
		Log( "no BattlePass btn" );
	end
end

-- 获取主页最左侧显示的功能入口，以便调整皮肤有更新提示的宽度
function getLeftBottomShowMenuNode()
	if getglobal("MiniLobbyFrameBottomBattlePass"):IsShown() then
		return getglobal("MiniLobbyFrameBottomBattlePass")
	elseif getglobal("MiniLobbyFrameBottomMatch"):IsShown() then
		return getglobal("MiniLobbyFrameBottomMatch")
	elseif getglobal("MiniLobbyFrameBottomSubscribe"):IsShown() then
		return getglobal("MiniLobbyFrameBottomSubscribe")
	elseif getglobal("MiniLobbyFrameBottomVideoLive"):IsShown() then
		return getglobal("MiniLobbyFrameBottomVideoLive")
	elseif getglobal("MiniLobbyFrameBottomFacebookThumbUp"):IsShown()  then
		return getglobal("MiniLobbyFrameBottomFacebookThumbUp")
	elseif getglobal("MiniLobbyFrameBottomCommunity"):IsShown()  then
		return getglobal("MiniLobbyFrameBottomCommunity")
    elseif getglobal("MiniLobbyFrameBottomDeveloperCenter"):IsShown() then
        return getglobal("MiniLobbyFrameBottomDeveloperCenter")
	elseif getglobal("MiniLobbyFrameBottomShop"):IsShown()  then
		return getglobal("MiniLobbyFrameBottomShop")
	end
end

-- 主题更新检查
function CheckSkinUpdateTipShow( ... )
	local text = getglobal("MiniLobbyFrameBottomSkinUpdateTip")
	local leftBottomButton = getLeftBottomShowMenuNode()
	if leftBottomButton then
		local boxNetwork = getglobal("MiniLobbyFrameBottomNetworkBkg"):getAbsRect()
		local boxLeftButton = leftBottomButton:getAbsRect()
		local twidth = boxLeftButton.m_nLeft - boxNetwork.m_nRight - 20
		text:SetWidth(twidth)
		text:resizeRichWidth(twidth)
	end
	if true == checkSkinUpdate() then
		text:SetText(GetS(30037),0xff, 0xff,0xff)
		local height = text:GetTotalHeight()
		if height > 20 then
			text:SetHeight(height)
		end
		text:Show()
	else
		text:Hide()
	end
end

local versionLoadChecked = false;
function CheckVersionParamsLoaded()	
	if versionLoadChecked==false and ClientMgr:hasVersionParamsLoaded() then
		Log("VersionParamsLoaded");
		versionLoadChecked = true;

		if ClientMgr:getApiId() == 2 and ClientMgr:getVersionParamInt("Account4399OpBtn", 1) == 1 then  --显示账号按钮
			getglobal("MiniLobbyFrameTop4399LoginBtn"):Show();
		else
			getglobal("MiniLobbyFrameTop4399LoginBtn"):Hide();
		end
	end
end

function Update4399LoginBtn()
	local normal = getglobal("MiniLobbyFrameTop4399LoginBtnNormal");	
	local push = getglobal("MiniLobbyFrameTop4399LoginBtnPushedBG");
	
	if AccountManager:isBindTPAccount() then	--绑定了
		normal:SetTexUV("icon_4399id_h");
		push:SetTexUV("icon_4399id_h");
	else
		normal:SetTexUV("icon_4399id_n");
		push:SetTexUV("icon_4399id_n");
	end
end

function AfterSetRoleInfo()
	local txtUin   = getglobal("MiniLobbyFrameTopRoleInfoUin")
	txtUin:SetText(tostring(GetMyUin()))

	local realNameFrame = getglobal("MiniLobbyFrameRealnameInfoFrame")
	local realNameFrameFont = getglobal("MiniLobbyFrameRealnameInfoFrameFont")

	if not AccountManager.get_channel_realname_info then
		realNameFrame:Hide()
		return
	end
	
	-- local realname_info_res = {
	-- 	isrealname = false, -- 是否实名
	-- 	use_channel_realname = false,  -- 是否使用渠道实名
	-- 	channel_name = '', -- 渠道名称
	-- }
	local retTab = AccountManager:get_channel_realname_info() or {}
	if not retTab.isrealname then
		realNameFrame:Hide()
		return
	end

	realNameFrame:Show()
	if retTab.use_channel_realname then
		realNameFrameFont:SetText(GetS(1000935))
	else
		realNameFrameFont:SetText(GetS(1000934))
	end

	-- local authIcon = getglobal("MiniLobbyFrameTopRoleInfoAuthIcon")
	-- local authNorm = getglobal("MiniLobbyFrameTopRoleInfoAuthIconNormal")
	-- local authPush = getglobal("MiniLobbyFrameTopRoleInfoAuthIconPushedBG")
	-- if not authIcon then return end

	-- local isAuthOpened = checkRealNameAuthSwitch()

	-- if isAuthOpened and t_exhibition.isHost and AccountManager.idcard_info and not UseTpRealNameAuth() then
	-- 	authIcon:Show()
	-- 	local idCardInfo = AccountManager:idcard_info()
	-- 	local state      = AccountManager:realname_state()
	-- 	if state ~= 1 then	--未认证
	-- 		if isAuthOpened then
	-- 			authNorm:SetTexUV("icon_credit_good01");
	-- 			authPush:SetTexUV("icon_credit_good01");
	-- 		else
	-- 			authIcon:Hide();
	-- 		end
	-- 	else
	-- 		if idCardInfo.age < 18 then		--未满182
	-- 			authNorm:SetTexUV("icon_credit_good");
	-- 			authPush:SetTexUV("icon_credit_good");
	-- 		else
	-- 			authNorm:SetTexUV("icon_credit_good");
	-- 			authPush:SetTexUV("icon_credit_good");
	-- 		end
	-- 	end
	-- else
	-- 	authIcon:Hide();
	-- end

	-- local uinStr = txtUin:GetText()
	-- local width  = txtUin:GetTextExtentWidth(uinStr)
	-- authIcon:SetPoint("left", "MiniLobbyFrameTopRoleInfoUin", "left", width + 10, 0)
end

function SetRoleInfo()
	print("SetRoleInfo:");
	--设置头像、头像框
	HeadCtrl:MiniwMainHead();

	local uin = GetMyUin()
	local nickName = AccountManager:getNickName()
	--如果昵称是迷你号不需要屏蔽
	if not IsIgnoreReplace(nickName, {CheckMiniAccountNick = true}) then
		nickName = DefMgr:filterString(nickName, false)
	end
    
	--昵称
	local name = getglobal("MiniLobbyFrameTopRoleInfoName");
	name:SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin()).. nickName, 53, 84, 84);
	
	--7k7kvip图标
	Set7k7kVipIconBeforName(name, nickName, 53, 84, 84);
	
	-- 会员
	G_VipNamePreFixEntrency(name, AccountManager:getUin(), nickName, {r=53, g=84, b=84})
	-- name:SetText('213'..'#A211'..nickName, 0,0,255)

	--uin
	getglobal("MiniLobbyFrameTopRoleInfoUin"):SetText(GetS(359).." "..uin);
end

function SetMiniLobbyFrameHomePicture()
    local localversion = ClientMgr:clientVersionFromStr(ClientMgr:clientVersion())
    local checkversion = 0

    if ns_shop_config2 and ns_shop_config2.HomePicture_url then
        if ns_shop_config2.version_min then
            checkversion = ClientMgr:clientVersionFromStr(ns_shop_config2.version_min)
        end

        if localversion < checkversion then
            return
        end

        local HomePicture_url = ns_shop_config2.HomePicture_url
        local downloadFilePath = g_download_root .. ns_advert.func.trimUrlFile(HomePicture_url) ..".tmp"
        local filePath = g_download_root .. ns_advert.func.trimUrlFile(HomePicture_url) 
        local existPath = getkv("MiniLobbyHomePicture_cache", nil, 101)
           
        --删除未下载完成文件缓存
        if downloadFilePath and gFunc_isFileExist(downloadFilePath) then
			gFunc_deleteStdioFile(downloadFilePath)
        end
        
        --下载完成
        local function downloadFinish()
            --文件重命名
            gFunc_renameStdioPath(downloadFilePath, filePath)

            --判断有效
            local ge = GameEventQue:getCurEvent()
            if ge.body.httpprogress.progress == 100 then
                getglobal("MiniLobbyFrameCenterHomeChestPic"):SetTexture(filePath)
                setkv("MiniLobbyHomePicture_cache", filePath, nil, 101)
            else
                gFunc_deleteStdioFile(filePath)
            end
        end

        --检查缓存
        if existPath and gFunc_isStdioFileExist(existPath) then
            --文件不同删除之前文件
            if existPath ~= filePath then
                gFunc_deleteStdioFile(existPath)
                ns_http.func.downloadPng(HomePicture_url, downloadFilePath, nil, nil, downloadFinish)
            else
                --判断有效（大于1K）
                local picSize = gFunc_getStdioFileSize(filePath)
                if picSize > 1024 then
                    getglobal("MiniLobbyFrameCenterHomeChestPic"):SetTexture(filePath)
                else
                    gFunc_deleteStdioFile(filePath)
                    ns_http.func.downloadPng(HomePicture_url, downloadFilePath, nil, nil, downloadFinish)
                end            
            end
        else
            ns_http.func.downloadPng(HomePicture_url, downloadFilePath, nil, nil, downloadFinish)
        end
    end
end

function SetMiniLobbyFrameWorkshopPicture()
    local localversion = ClientMgr:clientVersionFromStr(ClientMgr:clientVersion())
    local checkversion = 0

    if ns_shop_config2 and ns_shop_config2.WorkshopPicture_url then
        if ns_shop_config2.version_min then
            checkversion = ClientMgr:clientVersionFromStr(ns_shop_config2.version_min)
        end

        if localversion < checkversion then
            return
        end
        
        local WorkshopPicture_url = ns_shop_config2.WorkshopPicture_url
        local downloadFilePath = g_download_root .. ns_advert.func.trimUrlFile(WorkshopPicture_url) ..".tmp"
        local filePath = g_download_root .. ns_advert.func.trimUrlFile(WorkshopPicture_url)
        local existPath = getkv("MiniLobbyWorkshopPicture_cache", nil, 101)

        --删除未下载完成文件缓存
        if downloadFilePath and gFunc_isFileExist(downloadFilePath) then
            gFunc_deleteStdioFile(downloadFilePath)
        end

        --下载完成
        local function downloadFinish()
            --文件重命名
            gFunc_renameStdioPath(downloadFilePath, filePath)

            --判断有效
            local ge = GameEventQue:getCurEvent()
            if ge.body.httpprogress.progress == 100 then
                getglobal("MiniLobbyFrameCenterMiniWorksPic"):SetTexture(filePath)
                setkv("MiniLobbyWorkshopPicture_cache", filePath, nil, 101)
            else
                gFunc_deleteStdioFile(filePath)
            end
        end
        
        --检查缓存
        if existPath and gFunc_isStdioFileExist(existPath) then
            --文件不同删除之前文件
            if existPath ~= filePath then
                gFunc_deleteStdioFile(existPath)
                ns_http.func.downloadPng(WorkshopPicture_url, downloadFilePath, nil, nil, downloadFinish)
            else
                --判断有效（大于1K）
                local picSize = gFunc_getStdioFileSize(filePath)
                if picSize > 1024 then
                    getglobal("MiniLobbyFrameCenterMiniWorksPic"):SetTexture(filePath)
                else
                    gFunc_deleteStdioFile(filePath)
                    ns_http.func.downloadPng(WorkshopPicture_url, downloadFilePath, nil, nil, downloadFinish)
                end
            end
        else
            ns_http.func.downloadPng(WorkshopPicture_url, downloadFilePath, nil, nil, downloadFinish)
        end
    end
end

--个人中心
function MiniLobbyFramePlayerCenter_OnClick()
    Log( "call MiniLobbyFramePlayerCenter_OnClick" );
    --[[
	if IsStandAloneMode() then return end
	
	PlayerCenterFrame_setTarget();    --查看哪个玩家的资料
	--getglobal("MiniLobbyFrame"):Hide();

	-- getglobal("PlayerCenterFrame"):Show();
    OpenNewPlayerCenter(AccountManager:getUin());
	]]-- liya
	-- add by wangyang event standby2 redTag
	local redIsShow = getglobal('MiniLobbyFrameTopRoleInfoHeadPostingRedTag'):IsShown() or getglobal('MiniLobbyFrameTopRoleInfoHeadAchieveRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "PersonInformation", "click", eventTab) --mark by hfb for new minilobby 原大厅，新埋点
    -- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyPlayerCenterBtn");
	DoRealNameAuthWithCheck(function()
		local callback = function()
			threadpool:notify("newpalyer.showauthbox")
		end
		local adsType = RealNameFunc and RealNameFunc.isShowIdentityNameAuth and RealNameFunc:isShowIdentityNameAuth(6)
		if adsType then
			
			if ShowIdentityNameAuthFrame(nil,nil,nil,callback,callback,adsType) then
				threadpool:wait("newpalyer.showauthbox")
			end
		end
	end)
	JumpToPlayerCenter()
end

------------------------------------------------GameHelpFrame----------------------------------------------------
function GameHelpFrameClose_OnClick()
	getglobal("GameHelpFrame"):Hide();
end

function SetGameHelpFrame(title, content)
	getglobal("GameHelpFrameTitle"):SetText(title);
	getglobal("GameHelpBoxContent"):SetText(content, 140, 103, 84);
	
	local lines = getglobal("GameHelpBoxContent"):GetTextLines();
	if lines <= 14 then
		getglobal("GameHelpBoxPlane"):SetSize(890, 370)
	else
		getglobal("GameHelpBoxPlane"):SetSize(890, lines*27+25)
	end

	getglobal("GameHelpBox"):resetOffsetPos();
	getglobal("GameHelpFrame"):Show();
end

function GameHelpFrame_OnShow()

end

function GameHelpFrame_OnHide()

end

-----------------------------------------------------注销账户:closeaccount-------------------------------------
function ShowCloseAccountBtn()
	Log("ShowCloseAccountBtn:");
	--if isAbroadEvn() or 999 == ClientMgr:getApiId() then
		--海外服才有
		--if ClientMgr:isPC() then
			getglobal("CloseAccountFrameEdit"):Clear();
			getglobal("CloseAccountFrameAgreeBtn"):Disable();
			getglobal("CloseAccountFrameAgreeBtnNormal"):SetGray(true);
			getglobal("CloseAccountFrameAgreeBtnPushedBG"):SetGray(true);
			if IsEnableNewAccountSystem() then
				getglobal("GameSetFrameOtherCloseAccountTitle"):Hide();
				getglobal("GameSetFrameOtherCloseAccountBtn"):Hide();
			else
				getglobal("GameSetFrameOtherCloseAccountTitle"):Show();
				getglobal("GameSetFrameOtherCloseAccountBtn"):Show();
			end
		--end

		getglobal("CloseAccountFrameContentText"):SetText(GetS(9222), 61, 69, 70);
	--else
	--	getglobal("GameSetFrameOtherCloseAccountBtn"):Hide();
	--	getglobal("GameSetFrameOtherCloseAccountTitle"):Hide();
	--end
end

function OverseaPolisyFrameEdit_OnFinishChar()
	local text = getglobal("CloseAccountFrameEdit"):GetText();
	Log("OverseaPolisyFrameEdit_OnFinishChar: text = " .. text);

	if text == "DELETE" then
		getglobal("CloseAccountFrameAgreeBtn"):Enable();
		getglobal("CloseAccountFrameAgreeBtnNormal"):SetGray(false);
		getglobal("CloseAccountFrameAgreeBtnPushedBG"):SetGray(false);
	else
		getglobal("CloseAccountFrameAgreeBtn"):Disable();
		getglobal("CloseAccountFrameAgreeBtnNormal"):SetGray(true);
		getglobal("CloseAccountFrameAgreeBtnPushedBG"):SetGray(true);
	end
end

function OverseaPolisyFrameEdit_OnFocusLost()
	Log("OverseaPolisyFrameEdit_OnFocusLost:");
	OverseaPolisyFrameEdit_OnFinishChar();
end

function GameSetFrameOtherCloseAccountBtn_OnClick()
	Log("GameSetFrameOtherCloseAccountBtn_OnClick:");

	getglobal("GameSetFrame"):Hide();

	local env = get_game_env();
	if env == 10 then
		getglobal("ForeignCloseAccountFrame"):Show();
	else
		GetInst("UIManager"):Open("Logout", {frameType = 1})
		-- getglobal("CloseAccountFrame"):Show();
	end
	
	-- statisticsGameEvent(10021, '%d', 1);	--埋點: 打開主銷賬戶界面
end

function CloseForeignAccountFrameCloseBtn_OnClick()
	getglobal("ForeignCloseAccountFrame"):Hide();
end
function CloseAccountFrameCloseBtn_OnClick()
	getglobal("CloseAccountFrame"):Hide();
end

function CloseAccountFrame_OnShow()
	if ClientCurGame:isInGame() then
		ClientCurGame:setOperateUI(true);
	end
end

function CloseAccountFrame_OnHide()
	if ClientCurGame:isInGame() then
		ClientCurGame:setOperateUI(false);
	end
end

function CloseAccountFrameRefuseBtn_OnClick()
	Log("CloseAccountFrameRefuseBtn_OnClick:");
	CloseAccountFrameCloseBtn_OnClick();
	-- statisticsGameEvent(10021, '%d', 2);	--埋點: 左鍵取消
end

function CloseAccountFrameAgreeBtn_OnClick()
	Log("CloseAccountFrameAgreeBtn_OnClick:");
	local text = getglobal("CloseAccountFrameEdit"):GetText();

	if text == "DELETE" then
		if AccountManager.write_off then
			local code = AccountManager:write_off();
			Log("code = " .. code);
			CloseAccountFrameCloseBtn_OnClick();
			--ClientMgr:gameExit();

			--二级弹框
			MessageBox(26, GetS(9227), function()
					ClientMgr:gameExit(false);
				end
			);
		end

		-- statisticsGameEvent(10021, '%d', 3);	--埋點: 右鍵同意
	end
end


--玩家出生日期设置--
function MiniLobbyFrameBirthSelect_OnLoad(...)
	--初始化出生日期UI
	local name1="MiniLobbyFrameBirthSelectMonthListM"
	local name2="MiniLobbyFrameBirthSelectYearListY"
	local base=-11
	local months_btn={GetS(4861),GetS(4860),GetS(4859),GetS(4858),GetS(4857),GetS(4856),GetS(4855),GetS(4854),GetS(4853),GetS(4852),GetS(4851),GetS(4850)}
	for i=1,12 do
		getglobal(name1..i):SetPoint("bottom","MiniLobbyFrameBirthSelectMonthListPlane","bottom",0,base-51*(i-1))
		getglobal(name1..i.."Num"):SetText(months_btn[i])
	end

	getglobal("MiniLobbyFrameBirthSelectTitle2"):SetText(GetS(4845))
	--[[
	getglobal(name1.."1Num"):SetText("December")
	getglobal(name1.."2Num"):SetText("November")
	getglobal(name1.."3Num"):SetText("October")
	getglobal(name1.."4Num"):SetText("September")
	getglobal(name1.."5Num"):SetText("August")
	getglobal(name1.."6Num"):SetText("July")
	getglobal(name1.."7Num"):SetText("June")
	getglobal(name1.."8Num"):SetText("May")
	getglobal(name1.."9Num"):SetText("April")
	getglobal(name1.."10Num"):SetText("March")
	getglobal(name1.."11Num"):SetText("February")
	getglobal(name1.."12Num"):SetText("January")
	]]--

	local base_year=os.date("%Y")-38
	for i=1,40 do
		getglobal(name2..i):SetPoint("bottom","MiniLobbyFrameBirthSelectYearListPlane","bottom",0,base-51*(i-1))
		if i==1 then
			getglobal(name2..i.."Num"):SetText(GetS(4862)..tostring(base_year))
		else
			getglobal(name2..i.."Num"):SetText(tostring(base_year+i-2))
		end
	end

	
	--local sliderFrame1=getglobal("MiniLobbyFrameBirthSelectYearList")
	--local sliderFrame2=getglobal("MiniLobbyFrameBirthSelectMonthList")
	--sliderFrame1:setCurOffsetY(-865)
	--sliderFrame1:setCurOffsetY(-151)

end

function BirthSelectOKBtn_OnClick( ... )
	local index=0;
	local month_number={GetS(4861),GetS(4860),GetS(4859),GetS(4858),GetS(4857),GetS(4856),GetS(4855),GetS(4854),GetS(4853),GetS(4852),GetS(4851),GetS(4850)}
	local user_birth={year=0,month=0}
	local frame="MiniLobbyFrameBirthSelect"
	local user_month=getglobal(frame.."MonthTitleName"):GetText()
	local user_year=getglobal(frame.."YearTitleName"):GetText()

	if user_year==GetS(4843) or user_month==GetS(4844) then
		local duration=0.5
		local interval=0.25
		if not (AnimMgr.playing and next(AnimMgr.playing)~=nil) then
		
			AnimMgr:playBlink("MiniLobbyFrameBirthSelectYearTitle", duration, interval);
			AnimMgr:playBlink("MiniLobbyFrameBirthSelectMonthTitle", duration, interval);
		
		end
		return
	else
		for i=1,12 do
			if month_number[i]==user_month then
				index=i;
				break;
			end
		end
		local u_year=tonumber(user_year)
		if u_year==nil then
			user_birth.year=tonumber(os.date("%Y")-39)
		else
			user_birth.year=u_year
		end
		
		user_birth.month=tonumber(index)
		if AccountManager.set_user_birthday then
			AccountManager:set_user_birthday(user_birth)
			
		end
		getglobal("MiniLobbyFrameBirthSelect"):Hide();
		--print("a_b1",AccountManager:get_user_birthday())
	end
end

function MonthSelect_OnClick( ... )
	local name=this:GetName()
	if name=="MiniLobbyFrameBirthSelectMonthTitle" then
		getglobal("MiniLobbyFrameBirthSelectMonthList"):setCurOffsetY(-151)
		getglobal("MiniLobbyFrameBirthSelectMonthBar"):SetValue(151)
	elseif name=="MiniLobbyFrameBirthSelectYearTitle" then
		getglobal("MiniLobbyFrameBirthSelectYearList"):setCurOffsetY(-865)
		getglobal("MiniLobbyFrameBirthSelectYearBar"):SetValue(865)
	end
	local parent_name=this:GetParentFrame():GetName()
	if getglobal(name.."Down"):IsShown() then
		getglobal(name.."Down"):Hide()
		getglobal(name.."Up"):Show()
		getglobal(parent_name.."List"):Show()
		getglobal(parent_name.."ListBkg"):Show()
		getglobal(parent_name.."Bar"):Show()
	else
		getglobal(name.."Up"):Hide()
		getglobal(name.."Down"):Show()
		getglobal(parent_name.."List"):Hide()
		getglobal(parent_name.."ListBkg"):Hide()
		getglobal(parent_name.."Bar"):Hide()
	end

end


function BirthTime_OnClick( ... )
	
	
	local name=this:GetName()
	local parent=this:GetParentFrame():GetName()
	local time=getglobal(name.."Num"):GetText()
	if parent=="MiniLobbyFrameBirthSelectMonthList" then
		

		getglobal("MiniLobbyFrameBirthSelectMonthTitleName"):SetText(time)
		getglobal(parent):Hide()
		getglobal(parent.."Bkg"):Hide()
		getglobal("MiniLobbyFrameBirthSelectMonthBar"):Hide()
		getglobal("MiniLobbyFrameBirthSelectMonthTitleDown"):Show()
		getglobal("MiniLobbyFrameBirthSelectMonthTitleUp"):Hide()

	else
		getglobal("MiniLobbyFrameBirthSelectYearTitleName"):SetText(time)
		getglobal(parent):Hide()
		getglobal("MiniLobbyFrameBirthSelectYearBar"):Hide()
		getglobal(parent.."Bkg"):Hide()
		getglobal("MiniLobbyFrameBirthSelectYearTitleDown"):Show()
		getglobal("MiniLobbyFrameBirthSelectYearTitleUp"):Hide()
	end
end

function MonthBar_OnValueChanged(...)
	local value=this:GetValue()

	local bar=getglobal("MiniLobbyFrameBirthSelectMonthBar")
	if value>=299 then
		value=303
		bar:SetValue(value)
	elseif value<=4 then
		value=0
		bar:SetValue(value)
	end

	local sliderFrame=getglobal("MiniLobbyFrameBirthSelectMonthList")
	sliderFrame:setCurOffsetY(-value)
	--print("birthbarvaluem",value)
end

function YearBar_OnValueChanged( ... )
	local value=this:GetValue()

	local bar=getglobal("MiniLobbyFrameBirthSelectYearBar")
	if value>=1729 then
		value=1731
		bar:SetValue(value)
	elseif value<=4 then
		value=0
		bar:SetValue(value)
	end

	
	local sliderFrame=getglobal("MiniLobbyFrameBirthSelectYearList")
	sliderFrame:setCurOffsetY(-(value))
	--print("birthbarvaluey",value)
end

function MonthSlide_OnMouseWheel( ... )
	local sliderFrame=getglobal("MiniLobbyFrameBirthSelectMonthList")
	local bar=getglobal("MiniLobbyFrameBirthSelectMonthBar")
	local offsetY=sliderFrame:getCurOffsetY()
	--print("ossety",offsetY)
	
	bar:SetValue(-offsetY)

end

function YearSlide_OnMouseWheel( ... )
	local sliderFrame=getglobal("MiniLobbyFrameBirthSelectYearList")
	local bar=getglobal("MiniLobbyFrameBirthSelectYearBar")
	local offsetY=sliderFrame:getCurOffsetY()
	--print("ossety1",offsetY)
	
	bar:SetValue(-offsetY)
end


function MonthSlide_OnClick( ... )
	--print("kajdklajsd")
end


---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------BreakLawMapControl----------------------------------------------------------

BreakLawMapControl = {
	--BL == BreakLaw
	--[[违规地图id列表
	SetBLMapInfo(info)
	GetBLMapInfo()
	]]
	BLMapInfo = {};

	m_bHasRequested = false, 

	SetBLMapInfo = function(self, info)
		self.BLMapInfo = info;
	end;

	GetBLMapInfo = function(self)
		return self.BLMapInfo;
	end;

	--拉取违规地图id列表
	-- version2:优化拉取黑名单地图，
	-- 服务器会比对version，当本地缓存blMapInfo.version跟服务器相同时，返回值为{["result"]=2}
	LoadBreakLawMapInfo = function(self)
		local blMapInfo = getkv("blMap_info", "blMap_info");
		local version = 0;
		if blMapInfo and blMapInfo.version and blMapInfo.version > 0 then
			version = blMapInfo.version;
		end
		if self.m_bHasRequested then return end
		local myuin = AccountManager:getUin();
		local url = g_http_root_map.."miniw/map/?act=get_black_map_list&version="..version.."&"..http_getS1Map(myuin);
		print("LoadBreakLawMapInfo", url)
		function LSetBLMapInfo(ret)
			self.m_bHasRequested = false;
			print("LoadBreakLawMapInfo info", ret)
			if ret and ret.result == 0 then
				setkv("blMap_info", ret, "blMap_info")
				self:SetBLMapInfo(ret);
			else
				--使用旧版本
				print("LSetBLMapInfo result", blMapInfo)
				self:SetBLMapInfo(blMapInfo);
			end
		end

		self.m_bHasRequested = true;
		ns_http.func.rpc(url, LSetBLMapInfo, nil, nil, ns_http.SecurityTypeHigh);  --map
	end;
	
	IsMapBreakLaw = function(self, fromowid)
		local bl = self:VerifyMapID(fromowid);
		return bl and (bl == 1 or bl == 2) or false;
	end,

	--[[
	0 合法的  1 审核中 2 违法的
	]]
	VerifyMapID = function(self, fromowid)
		local blMapInfo = self.BLMapInfo;
		-- return fromowid  
		-- 	and (blMapInfo.wids and blMapInfo.wids[fromowid] and 2)
		-- 	or (blMapInfo.checking and blMapInfo.checking[fromowid] and 1)
		-- 	or 0;
		if fromowid then
			if blMapInfo then
				if blMapInfo.wids then
					for k, v in pairs(blMapInfo.wids) do
						if tostring(fromowid) == tostring(k) then
							if v == 2 then
								return 2;
							end
						end
					end
				end

				if blMapInfo.checking then
					for k, v in pairs(blMapInfo.checking) do
						if tostring(fromowid) == tostring(k) then
							if v > 0 then
								return 1;
							end
						end
					end
				end
			end
		end
		return 0;
	end,
}
---------------------------------------------------------------------------------------------------------------------------------
--[[记录工坊从操作日志 方便关闭页面的时候返回上一步界面]]
WorksArchiveMsgCheck = {
	isWorksInto = false;
	archindex = 0;
	mapinfo;
}

function GoBackInfoFrame()
	-- MiniLobbyFrameCenterMiniWorks_OnClick();
	JumpToMiniWorks()
	local archindex = WorksArchiveMsgCheck.archindex;

	local map = WorksArchiveMsgCheck.mapinfo;
    if map then 
		local verify = BreakLawMapControl:VerifyMapID(map.owid);
		if verify == 1 then
			ShowGameTips(GetS(10565), 3);
			return;
		elseif verify == 2 then
			ShowGameTips(GetS(3636), 3);
			return;
		end
	end 
	
	--地图详情页换了
	ShowMiniWorksMapDetail(map, {fromUiLabel=CurLabel, fromUiPart=nil});

	MapDownloadReportMgr:SetMiniWorkHomepageSubType(this:GetName());

	--记录位置
	local downBtnUI = this:GetName() .. "FuncBtn";
	MiniworkDownBtnReporePostion(downBtnUI, map);

	WorksArchiveMsgCheck.isWorksInto = false;
	WorksArchiveMsgCheck.archindex = 0;
end

function NewUpdateMiniBeanOrCoin(btnUI)
	Log("NewUpdateMiniBeanOrCoin: btnUI = " .. btnUI);
	--迷你币: type == 1, btnUI = "NewStoreFrameTopMyMiniCoin"
	--迷你豆: type == 2, btnUI = "NewStoreFrameTopMyMiniBean"
	local num = 0;
	local oldNum = 0;
	local uva = nil;
	local font = nil;
	-- if getglobal("MiniLobbyFrame"):IsShown() then
	--if IsMiniLobbyShown() then --mark by hfb for new minilobby
		if string.find(btnUI, "MiniBean") then
			num = AccountManager:getAccountData():getMiniBean();
			font = getglobal("MiniLobbyFrameTopMiniBeanNum");
			uva = getglobal("MiniLobbyFrameTopMiniBeanUvA");

			if font then
				oldNum = tonumber(font:GetText()) or 0;
				font:SetText(num); 
			end
			SandboxLua.eventDispatcher:Emit(nil, "MINIBEAN_CHANGE",  SandboxContext():SetData_Number("num", num - oldNum))
		else
			num = AccountManager:getAccountData():getMiniCoin();
			print("NewUpdateMiniBeanOrCoin getMiniCoin ", num)
			font = getglobal("MiniLobbyFrameTopMiniCoinNum");
			if font then
				oldNum = tonumber(font:GetText()) or 0;
				font:SetText(num);
			end
			uva = getglobal("MiniLobbyFrameTopMiniCoinUvA");

			if (oldNum > 0 or num > 0) and oldNum ~= num then
				if oldNum > num then
					-- 场景触发活动上报: event_id = 2003  商城-消耗迷你币-单位时间内消耗迷你币数量达x
					ActivityTriggerReportEvent(2003, oldNum - num)
				else
					-- 场景触发活动上报: event_id = 2004  商城-[Desc2]迷你币-单位时间内[Desc2]迷你币数量达x
					ActivityTriggerReportEvent(2004, num - oldNum)

					if GetInst("LimitRechargeDataMgr") then
						GetInst("LimitRechargeDataMgr"):OnRecharegeNumChange()
					end
				end
			end
		end
	--end
	
	if IsMiniLobbyShown() then
		if oldNum > 0 and num > oldNum and uva then
			uva:SetUVAnimation(60, false);
		end
	end
end

--模板展示
function ShowTemplateDisplayBtn()
	local apiid = ClientMgr:getApiId();
	local game_env = get_game_env()

	if 999 == apiid and 1 == game_env then
		getglobal("MiniLobbyFrameBottomTempDisplayBtn"):Show();
	end
end

--shift F11触发代码注入，
--在codeInjectionDebug.lua 中写入你要注入的代码按shift F11生效
--DEBUG 模式 方便调试
function CodeInjectForDebug()
	-- local apiid = ClientMgr:getApiId();
	-- local game_env = get_game_env()

	-- if 999 == apiid and 1 == game_env then
	-- 	print("CodeInjectForDebug")
	-- 	dofile("res/ui/mobile/codeInjectionDebug.lua");
	-- end
	dofile("res/ui/mobile/codeInjectionDebug.lua");
end

function MiniLobbyFrameBottomTempDisplayBtn_OnClick()
	GetInst("TemplateDisplayMgr"):Show();
end

function GetAndroidPrivacyShow()
	local ok = JavaMethodInvokerFactory:obtain()
		:setClassName("com/minitech/miniworld/AbsSplashActivity")
		:setMethodName("getPrivacyAgreementShow")
		:setSignature("()Z")
        :call()
		:getBoolean();
		
	local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	print("AndroidPrivacyShow=",ok);
	if ok then
		--隐私协议弹窗
		-- statisticsGameEventNew(1450, AccountManager:getUin())
		--隐私协议勾选同意
		-- statisticsGameEventNew(1451, AccountManager:getUin())
    end
end

-----------活动入口--------------
-- local xmlurl = "ui/mobile/texture2/minilobby.xml"
-- local room1_icon = "icon_notice_hall"
ActivityRoomBox = "MiniLobbyFrameTopActivityRoomBox"
ActivityInfo = {
	-- 该表数据的顺序决定显示顺序：从上到下对应从右到左
	{ ID = 1, FrameName = "PrizeDrawBtn" , icon = "",                title = GetS(32523) },  --扭蛋
	{ ID = 2, FrameName = "SignBtn" ,      icon = "icon_sign",       title = GetS(32520) },  --签到
	{ ID = 3, FrameName = "WelfareBtn",    icon = "",                title = GetS(32524) },  --新手福利
	{ ID = 4, FrameName = "TreasuryBtn",   icon = "icon_mntreasure", title = GetS(32525) },  --迷你宝库
	{ ID = 5, FrameName = "RealNameBtn",   icon = "icon_uid",        title = GetS(32526) },  --实名认证
	{ ID = 6, FrameName = "HomelandBtn",   icon = "",                title = GetS(41158) },  --老版家园

	-- 11-15走配置，id不能随意改动
	{ ID = 11,FrameName = "JumpToH511", },      --跳转到H5页面
	{ ID = 12,FrameName = "JumpToH512", },      --跳转到H5页面
	{ ID = 13,FrameName = "JumpToH513", },      --跳转到H5页面
	{ ID = 14,FrameName = "JumpToH514", },      --跳转到H5页面
	{ ID = 15,FrameName = "JumpToH515", },      --跳转到H5页面

	-- 7-10走配置，icon跟随配置
	{ ID = 7, FrameName = "NationalDayBtn", title = GetS(110000) },  --国庆游园会
	{ ID = 19, FrameName = "MainGuardBtn"},  --成长守护
	{ ID = 8, FrameName = "NoviceWelfareBtn",  icon = "icon_limit_home",    title = GetS(35851) },  --新手活动
	{ ID = 9, FrameName = "FirstRechargeBtn",  icon = "icon_recharge_home", title = GetS(70553) },  --首充/续充
	{ ID = 10,FrameName = "BirthdayPartyBtn",  title = GetS(110083) }, --生日派对
	--{ ID = 20,FrameName = "ConcertBtn",  	   icon = "icon_concert_homepage", xmlName = "concert"}, --音乐会
	
	{ ID = 16, FrameName = "ComeBackBtn",       icon = "icon_return_home", title = GetS(35851) },  --回流系统
	{ ID = 17, FrameName = "ActivityTriggerBtn",title = "惊喜礼包" },  --触发活动
	
	{ ID = 21, FrameName = "TreasureBtn",     icon = "", title = "国宝复刻" },  --国宝复刻
	{ ID = 22, FrameName = "FestivaBtn",     icon = "icon_return_home", title = "嘉年华" },  --嘉年华

	{ ID = 23, FrameName = "YearVoteBtn", title = GetS(101451)},  --年度投票评选
	{ ID = 26, FrameName = "NewYearBtn", title = "新春红包"},  --大唐中国年
	{ ID = 27, FrameName = "ArmorBtn", title = GetS(1001556)},  --铠甲勇士
	{ ID = 28, FrameName = "XiaoLouBtn", title = GetS(102500)},  --花小楼专辑
	{ ID = 30, FrameName = "AnniversaryBtn",     icon = "", title = GetS(102601) },  --周年福利
	{ ID = 31, FrameName = "JuexingBtn" , title = GetS(102700)},  --觉醒试炼
	{ ID = 32, FrameName = "MiniWorkerBtn", title = "WORKER" },  --迷你打工人
	{ ID = 33, FrameName = "BoatFestivalBtn" , title = GetS(103102)},  --端午活动
	{ ID = 34, FrameName = "DouluoBtn" , title = GetS(103394)},  --斗罗大陆
	{ ID = 35, FrameName = "CreateFestivalBtn" , title = GetS(800501)},  --全民创造节活动
	{ ID = 36, FrameName = "PvpCompetitionBtn", icon = "icon_pvp",title = ""},  --PVP赛事升级
	{ ID = 77, FrameName = "VipActBtn" , title = GetS(103394)}, --会员活动
}

--埋点统计
local getStatistics = {
    activityid,
	lang,--当前语言
	uin_own,  --uin
}

--入口信息
local roomInfo ={
	Frame,
	Icon ,
	Name ,
	NameBkg ,
	nameString,
}

local MOVE_TICK = 10 --入口移动间隔
local boxwidth= 0     --入口长度    
local FrameTable ={}

function MiniLobbyFrameTopActivityRoomBox_OnLoad()
	this:setUpdateTime(1)
	getStatistics.lang = get_game_lang();
	getglobal("MiniLobbyFrameTopActivityRoomBoxDropDown"):setUpdateTime(0.01);
	getStatistics.uin_own = AccountManager:getUin()
end

-- 检查图片是否已下载到本地，如果有则直接使用
function CheckPicAndSet(icon, url)
	local filePath = g_photo_root .. getHttpUrlLastPart(url) .."_";
	if gFunc_isStdioFileExist(filePath)  then
		icon:setURL(filePath)
	else
		-- 此回调无法作为下载完成的标志（下载失败或者没有完成下载也会执行此回调）
		DownloadPicAndSet(icon, url)
	end
end

--下载图片并设置
function DownloadPicAndSet(icon,url,Frame)
	if "string" == type(url) and #url > 0 then
		local filePath = g_photo_root .. getHttpUrlLastPart(url) .."_";		--加上"_"后缀		
		local function downloadFinish()     
			 local fsize = gFunc_getStdioFileSize(filePath)/1000
			 if fsize > 0 then
				setkv( url, filePath );
				if icon and icon.SetTexture then
					icon:SetTexture(filePath);
					IconFit(icon);
					if Frame and not Frame:IsShown() then 
						Frame:Show()
					end 
				elseif not tolua.isnull(icon) and icon.setURL then
					if gFunc_isStdioFileExist(filePath) then
						icon:setURL(filePath)
					end
					if not tolua.isnull(Frame) and Frame then 
						Frame:setVisible(true)
					end 
				end
				
				-- RefreshActivityAllIcons()
			 end
		end
		ns_http.func.downloadPng( url, filePath, nil, nil, downloadFinish );
	end
end

function GetFrame(ID, default)
	local actInfo = ActivityLocalInfoByID(ID) or {}
	local frameName = actInfo.FrameName or (default or "")
	frameName = ActivityRoomBox..frameName
	roomInfo.Frame = getglobal(frameName)
	roomInfo.Icon  = getglobal(frameName.."Icon")
	roomInfo.Name  = getglobal(frameName.."Name")
	roomInfo.NameBkg = getglobal(frameName.."NameBkg")
end

function SetFrame(ID,index)
	local bShow = true
	roomInfo.Frame:SetClientID(ID)
	--设置图片,文字
	if action_conf[index] and action_conf[index].nameid then 
		roomInfo.nameString  = StringDefCsv:get(action_conf[index].nameid)
	end 
	if not action_conf[index].nameid or action_conf[index].nameid == 0 then 
		roomInfo.nameString = action_conf[index].name 
	end 
	--[[if string.len(roomInfo.nameString)>6 then
		roomInfo.NameBkg:SetSize(73 ,18)
		roomInfo.Name:SetSize(65,16)
	end--]]
	if roomInfo.nameString and roomInfo.nameString ~= "" then
		roomInfo.Name:SetText(roomInfo.nameString)
	end
	if action_conf[index].color then
		local red = action_conf[index].color.red
		local blue = action_conf[index].color.blue
		local green = action_conf[index].color.green
		roomInfo.Name:SetColor(red,blue,green)
	end
	--海外版不显示文字框
	if get_game_env() >= 10 then
		roomInfo.NameBkg:Hide()
		roomInfo.Name:Hide()
	end
	--如果已经实名，不显示
	if ID == 5 and (AccountSafetyCheck:MiniAutonymCheckState() or get_game_env() >= 10) then
		roomInfo.Frame:Hide()	
		bShow = false
	else
			--进入展示队列
		table.insert(FrameTable, roomInfo.Frame)
		roomInfo.Frame:Show()
		bShow = true
	end
	
	if ID == 6 and roomInfo.Frame:IsShown() then
		local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxHomelandBtnRedTag'):IsShown()
		local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(ID),standby2 = (redIsShow and 1 or 0)}
		MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "MyHomeLandFruit", "view", eventTab)
	end
	if ID == 5 and roomInfo.Frame:IsShown() then
		local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxRealNameBtnRedTag'):IsShown()
		local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(ID),standby2 = (redIsShow and 1 or 0)}
		MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "RealNameAuthentication", "view", eventTab)
	end
	return bShow
end

function MiniLobbyFrame_ShowActivityBox()
	--可视化配置，初始化主页右上角根据产运配置开启的活动
    GetInst("ActivityMgr"):InitTimeLimitedActBtns()
	--检查可视化配置的活动的添加状态
	GetInst("ActivityMgr"):CheckVisualActCfg()
	
	print("MiniLobby action_conf", action_conf)	
	print("MiniLobby anti_addiction", ns_version.anti_addiction)
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "-", "view")
	local ID = 1
	local redtag = nil
	FrameTable = {}
	if action_conf and #action_conf >0 then
		for index = 1, #action_conf do
			if action_conf[index] and check_apiid_ver_conditions(action_conf[index], true) then 
				ID = action_conf[index].id
				--判断是否是h5页面
				local actInfo = ActivityLocalInfoByID(ID)
				if actInfo and next(actInfo) ~= nil then
					local frameName = actInfo.FrameName or ""
					frameName = ActivityRoomBox..frameName
					if action_conf[index].http then
						actInfo.http = action_conf[index].http
					end
                    --jump_app = "fx_wb", --fx_qq,fx_qqkj,fx_wx,fx_pyq,fx_wb 客户端资源为逻辑内增加判断逻辑，判断对应APP是否有安装（qq 微信 微博）
                    --url_ext = "https://www.mini1.cn/", --资源位配置内增加H5字段，用于未安装对应应用时的跳转方式
                    if action_conf[index].jump_app then
                        actInfo.jump_app = action_conf[index].jump_app
                    end
                    if action_conf[index].url_ext then
                        actInfo.url_ext = action_conf[index].url_ext
                    end
					redtag = getglobal(frameName.."RedTag")
					GetFrame(ID)

					local now_        = getServerTime()
					local lastTime    = getkv("activity"..ID.."time", "activity"..ID, getStatistics.uin_own) or 0
					local cd          = tonumber(action_conf[index].cd);
					local toggle	  = tonumber(action_conf[index].red_dot_toggle);
					if ID == 6 and Homechest_RedFlagCtrl.AbTestHit then --家园果实ABtest命中，不走红点
						cd = nil
						toggle = nil
					end
					print("MiniLobbyFrameTopActivityRoomBox_OnShow",now_,lastTime,cd)

					if toggle then
						if toggle ~= 0 and (not getkv("activity"..ID..action_conf[index].start_time)) then
							redtag:Show()
						end
					elseif cd then
						if (now_ - lastTime) >= cd then
							redtag:Show()
						end
					end
					if SetFrame(ID,index) then
						if action_conf[index].oID then
							actInfo.oID = action_conf[index].oID
							standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", action_conf[index].oID, "view")
						end
						DownloadPicAndSet(roomInfo.Icon,action_conf[index].icon,roomInfo.Frame)
					end
				end
			end
		end	
	end

	RefreshActivityAllIcons(true)
end

function MiniLobbyFrameTopActivityRoomBox_OnShow()
	if g_game_userPkgsRsped then
		MiniLobbyFrame_ShowActivityBox()
	end 
end

NewComeBackAwardTips = false;
function ComeBackBtnRefresh(needReport)
	if needReport then
		needReportCache["ReturnSystemEntryNew"] = true
		needReportCache["OldReturnSystemEntry"] = true
	end
	--MiniBase 关闭回流活动入口和刷新
	if MiniBaseManager:isMiniBaseGame() then return end
	if NewbieGuideManager:IsABSwitchV13() and not NewbieGuideManager:GetGuideFinishFlag(NewbieGuideManager.GUIDE_FLAG_GO_HALL) then return end
	if GetInst("MiniUIManager"):GetCtrl("NewNoviceTaskLanding") then return end
	if FguiMainIsVisible() then
		local node = GetInst("MiniUIManager"):GetUI("mainAutoGen")
		if node and node.ctrl then
			node.ctrl:ComeBackBtnRefresh(needReport)
		end
		return
	end
	-- 回流活动入口比较特殊，不走action_conf配置
    local comebackBtnName = "MiniLobbyFrameTopActivityRoomBoxComeBackBtn"
    local comebackBtn = getglobal(comebackBtnName)
	comebackBtn:Hide()
	
    local newComeBackBtnName = "MiniLobbyFrameTopNewComeBackBtn"
	local newComeBackBtn = getglobal(newComeBackBtnName)
	newComeBackBtn:Hide()

	local redTag = getglobal(newComeBackBtnName.."RedTag")
	local rewardCount = getglobal(newComeBackBtnName.."Reward")
	local remainTime = getglobal(newComeBackBtnName.."TaskTime")
	redTag:Hide();
	rewardCount:Hide();

	local oldcomeback_status = GetInst("ComeBackSysConfig"):GetCfgByKey("comeback_status")
	local newComeBackRes = GetInst("UserTaskDataManager").NewComeBackMissions;
	if newComeBackRes and newComeBackRes.msg then
		if newComeBackRes.msg.old_or_new then 
			newComeBackBtn:Show()

			-- 海外版不显示文字
			if IsOverseasVer() or isAbroadEvn() then
				getglobal(newComeBackBtnName.."NameBkg"):Hide()
				getglobal(newComeBackBtnName.."Name"):Hide()
			end
			-- 是否显示回流活动激活页面 new_slapface_type 0 关闭，1 显示老版，2 显示新版回流
			--if newComeBackRes.msg.slapface then
            if newComeBackRes.msg.new_slapface_type then
                if newComeBackRes.msg.new_slapface_type == 2 then
					local param = {}
					if newComeBackRes.msg.new_ui and  newComeBackRes.msg.new_ui == 1 then
						param.bg = "ui/mobile/texture0/bigtex/bg_return_ceremony2.png"
					end
					GetInst("ActivityPopupManager"):InsertActivity(1, function()
						GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/ComeBack", "miniui/miniworld/ComeBack", "miniui/miniworld/common_comp"})
						GetInst("MiniUIManager"):OpenUI("ComeBack","miniui/miniworld/ComeBack","ComeBackAutoGen",param)
					end)  
                elseif newComeBackRes.msg.new_slapface_type == 1 then
                    GetInst("ActivityPopupManager"):InsertActivity(1, function()
                        GetInst("UIManager"):Open("NewComeBackFrame")
                    end)
                end

                newComeBackRes.msg.new_slapface_type = 0
            end
				--newComeBackRes.msg.slapface = false
			--end

			remainTime:SetText(GetInst('UserTaskDataManager'):GetRemainTimeStr(newComeBackRes.msg.end_time))

			local tipsBg = getglobal('MiniLobbyFrameTopNewComeBackBtnTipsBg')
			local tipsBgArrow = getglobal('MiniLobbyFrameTopNewComeBackBtnTipsBgArrow')
			local tips =  getglobal('MiniLobbyFrameTopNewComeBackBtnTips')

			tipsBg:Hide()
			tipsBgArrow:Hide()
			tips:Hide()

			local hasTips = false;
			local canGetRewardCount = GetInst('UserTaskDataManager'):GetNewComeBackCanGetRewardCount();
			if canGetRewardCount >0 then
				rewardCount:SetText(canGetRewardCount);
				redTag:Show();
				rewardCount:Show();

				if  getglobal("MiniLobbyFrame"):IsShown() then
					local showTips = function ()
						local skinTips = getkv('NewComeBackSkinTips') or 0;
						local now = getServerTime();
						local mission = newComeBackRes.msg.task[7]
						if mission and mission.target_bonus[1].status == 1 and math.floor(skinTips/86400) ~= math.floor(now/86400) then 
							tips:SetWidth(360)
							tipsBg:SetWidth(364)
							tips:SetText('恭喜您已完成累计任务，快领取装扮吧!')
							setkv('NewComeBackSkinTips',now)
							return true;
						elseif not NewComeBackAwardTips then
							tips:SetWidth(180)
							tipsBg:SetWidth(184)
							tips:SetText('还有奖励待领取哦~')

							NewComeBackAwardTips = true
							return true;
						end
						return false;
					end

					if showTips() then 
						tipsBg:Show()
						tipsBgArrow:Show()
						tips:Show()
						hasTips = true;
						threadpool.delay(this,5,function ()
							tipsBg:Hide()
							tipsBgArrow:Hide()
							tips:Hide()
						end)
					end
				end
			end
			
			if needReport or needReportCache["ReturnSystemEntryNew"] then
				needReportCache["ReturnSystemEntryNew"] = nil
				local redDot = GetInst('UserTaskDataManager'):GetNewComeBackCanGetRewardCount()>0 and 1 or 2
				local newComeBackMissions = GetInst("UserTaskDataManager").NewComeBackMissions
				local interval=(newComeBackMissions and newComeBackMissions.msg and newComeBackMissions.msg.end_time) - getServerTime()
				local remainDay = math.floor((interval or 0)/(24*60*60))
				standReportEvent(9999, "MINI_HOMEPAGE_GAP1", "ReturnSystemEntryNew", "view",{standby1 =redDot,standby2= hasTips and 1 or 2,standby3= remainDay})
			end

		elseif oldcomeback_status then
			comebackBtn:Show()

			-- 海外版不显示文字
			if IsOverseasVer() or isAbroadEvn() then
				getglobal(comebackBtnName.."NameBkg"):Hide()
				getglobal(comebackBtnName.."Name"):Hide()
			end

			-- 是否显示回流活动激活页面
			if GetInst("ComeBackSysConfig"):GetCfgByKey("comeback_active") then
				GetInst("UIManager"):Open("ComeBackFrame")
				GetInst("ComeBackSysConfig"):SetCfgByKey("comeback_active", false)
			end

			if needReport or needReportCache["OldReturnSystemEntry"] then
				needReportCache["OldReturnSystemEntry"] = nil
				standReportEvent(9999, "MINI_HOMEPAGE_TELESCOPICLIST_1", "OldReturnSystemEntry", "view",{standby1 = GetInst("ActivityMgr"):GetActNameById(16)})
			end
		end
		if newComeBackRes.msg.new_ui and  newComeBackRes.msg.new_ui == 1 then
			getglobal("MiniLobbyFrameTopNewComeBackBtnIcon"):SetTexUV("icon_newcomeback3")
		else
			getglobal("MiniLobbyFrameTopNewComeBackBtnIcon"):SetTexUV("icon_newcomeback")
		end
	end


	-- 刷新按钮位置和底板大小
	ActivityRoomBoxSizeRefresh()
	--获取活动条的长度,用于点击伸缩UI
	boxwidth = getglobal("MiniLobbyFrameTopActivityRoomBox"):GetWidth()
end
--对显示的活动入口展示
function ActivityRoomRefresh(needReport)
	if needReport then
		needReportCache["NewUserWelfare"] = true
		needReportCache["Birthday"] = true
		needReportCache["Concert"] = true
		needReportCache["VipEntry"] = true
	end
	local number = 0

	local ActivityRoomBox = "MiniLobbyFrameTopActivityRoomBox"
	for index = 1, #FrameTable do
		if FrameTable[index] and FrameTable[index]:IsShown() then
			if number < 5 then
				--活动入口上限为5个
				number = number + 1
			else
				FrameTable[index]:Hide()
			end
		end
	end

	ComeBackBtnRefresh(needReport)


	--新手福利
	local noviceWelfareBtn = getglobal(ActivityRoomBox.."NoviceWelfareBtn")
	local noviceWelfareBtnName = getglobal(ActivityRoomBox.."NoviceWelfareBtnName")
	local noviceWelfareRedTag = getglobal(ActivityRoomBox.."NoviceWelfareBtnRedTag")

	--主界面入口是否打开
	local function checkWelfareSwitch()
		local isHasApiid = true
		local switch_apiids = nil
		if  ns_shop_config2 and ns_shop_config2.newplay_welfare then
			switch_apiids = ns_shop_config2.newplay_welfare.switch_apiids_no
		end
		
		if switch_apiids then			
			local finder_ = ',' .. ClientMgr:getApiId() .. ','
			local ret   = string.find( ',' .. switch_apiids .. ',', finder_ )
			if ret then
				isHasApiid =  false
			end
		end
		return isHasApiid
	end

	local isnovice,isShowNoviceWelfare = MiniLobby_IsNoviceWelfare()
	if checkWelfareSwitch() and isShowNoviceWelfare then
		noviceWelfareBtn:Show()
		local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxNoviceWelfareBtnRedTag'):IsShown()
		if needReport or needReportCache["NewUserWelfare"] then
			needReportCache["NewUserWelfare"] = nil
			local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(8),standby2 = (redIsShow and 1 or 0)}
			MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "NewUserWelfare", "view", eventTab)
		end

		local now = AccountManager:getSvrTime()
		local redTagTime = getkv("miniLobbyNovice") or 0
		if IsSameDay(now, redTagTime) then
			noviceWelfareRedTag:Hide()
		else
			noviceWelfareRedTag:Show()
		end

		local data = ns_shop_config2.newplay_welfare
		if data then			
			if isnovice == 1 then
				if data.title_all then
					noviceWelfareBtnName:SetText(GetS(data.title_all))
				end           
			elseif isnovice == 2 then
				if data.title then
					noviceWelfareBtnName:SetText(GetS(data.title))
				end   
			end
		end

		--强弹新手福利 1 开启
		if data and data.power and data.power == 1 then
			local now = AccountManager:getSvrTime()
			local uin = AccountManager:getUin()
			local noviceWelfareTime = getkv("noviceWelfare_strongpopup", "noviceWelfare_uin", uin) or 0
			if not IsSameDay(now, noviceWelfareTime) then--不是同一天
				threadpool:delay(1.0, function ()	
					if IsMiniLobbyShown() then
						GetInst("UIManager"):Open("noviceWelfare")
						local now_ = AccountManager:getSvrTime()
						if noviceWelfareRedTag:IsShown() then
							noviceWelfareRedTag:Hide()
							setkv("miniLobbyNovice", now_) 
						end			
						setkv("noviceWelfare_strongpopup", now_, "noviceWelfare_uin", uin)
					end
				end)
			end		
		end
	else
		noviceWelfareBtn:Hide()
	end
	
	-- 生日派对 不走action_conf配置
	local birthdayPartyBtn = getglobal(ActivityRoomBox.."BirthdayPartyBtn")
	if birthdayPartyBtn then
		if CheckActivityRoomBirthdayPartyBtnShow() then
			local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxBirthdayPartyBtnRedTag'):IsShown()
			if needReport or needReportCache["Birthday"] then
				needReportCache["Birthday"] = nil
				local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(10),standby2 = (redIsShow and 1 or 0)}
				MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "Birthday", "view", eventTab)
			end
			birthdayPartyBtn:Show()

			-- 刷新图标  文本
			RefreshActivityRoomBirthdayPartyBtn(birthdayPartyBtn)

			-- 刷新红点
			RefreshActivityRoomBirthdayPartyBtnRedTagShow(birthdayPartyBtn)

		else
			birthdayPartyBtn:Hide()
		end
	end

	-- 音乐会 不走action_conf配置
	local concertBtn = getglobal(ActivityRoomBox.."ConcertBtn")
	if concertBtn then
		if CheckActivityRoomConcertBtnShow() then
			if needReport or needReportCache["Concert"] then
				needReportCache["Concert"] = nil
				standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "Concert", "view")
			end

			concertBtn:Show()

			-- 刷新图标  文本
			RefreshActivityRoomConcertBtn(concertBtn)

			-- 刷新红点

		else
			concertBtn:Hide()
		end
	end

	--皮肤售卖活动，每次刷新首页活动的时候需要刷新判断一下是否有新的可以领取皮肤奖励红点
	local SkinSaleBtn = getglobal(ActivityRoomBox.."SkinSaleBtn")
	local SkinSaleBtnRedTag = getglobal(ActivityRoomBox.."SkinSaleBtnRedTag")
	if SkinSaleBtn and SkinSaleBtn:IsShown() then
		local now = AccountManager:getSvrTime()
		local uin = AccountManager:getUin()
		local redTagTime = getkv("SkinSaleBtn_click_uin"..uin) or 0
		local callBack = function()
			if SkinSaleBtnRedTag then
				local hasReward = GetInst("main_pifushoumaiManager"):HaveSkinSaleReward()
				if IsSameDay(now, redTagTime) and not hasReward then
					SkinSaleBtnRedTag:Hide()
				else
					SkinSaleBtnRedTag:Show()
				end
			end
		end
		GetInst("main_pifushoumaiManager"):JudgeSkinSaleReward(callBack)
	end
	
	-- 迷你基地-引流
	RefreshActivityRoomMiniBaseDrainageBt()

	--下载器
	-- RefreshActivityLobbyMiniBaseDownLoaderBtn()

	-- 刷新按钮位置和底板大小
	ActivityRoomBoxSizeRefresh()
	--获取活动条的长度,用于点击伸缩UI
	boxwidth = getglobal("MiniLobbyFrameTopActivityRoomBox"):GetWidth()
end

-- 刷新活动框大小和按钮位置
function ActivityRoomBoxSizeRefresh()
	if not getglobal(ActivityRoomBox):IsShown() then
		return --父节点或者自己已经没显示的情况下，就不走以下逻辑了，避免误隐藏
	end

	local offsetY = -15;
	local offsetX = -8;
	local number = 0
	if get_game_env() >= 10 then--海外没有文字，需要居中显示icon
		offsetY = 16
	end

	local btn
	for key, value in pairs(ActivityInfo) do
		btn = getglobal(ActivityRoomBox..value.FrameName)
		if btn and btn:IsShown() then
			btn:SetPoint("right", ActivityRoomBox, "right", offsetX, offsetY)
			offsetX = offsetX - 75
			number = number + 1
		end
	end

	--设置当前活动的个数和偏移值,方便显示首充	
	miniLobbyFrameTopActivity_Num = number
	miniLobbyFrameTopActivity_OffsetX = offsetX

	--如果没有活动就直接不显示框
	if miniLobbyFrameTopActivity_Num <= 0 then 
		getglobal(ActivityRoomBox):Hide()
	else
		getglobal(ActivityRoomBox):SetSize(30 + 75 * miniLobbyFrameTopActivity_Num, 36)
	end

	MiniLobbyRefreshLeftIconPos()
end

-- 回流系统入口
function MiniLobbyFrameTopComeBackBtn_OnClick()
    --[[
	if not GetInst("UIManager"):GetCtrl("Shop") then
		MiniLobbyFrameBottomShop_OnClick()
		GetInst("UIManager"):GetCtrl("Shop"):CloseBtnClicked()
	end
    GetInst("UIManager"):Open("ComeBackEntrance")
	]]-- liya
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyReturnSystem")
	local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxComeBackBtnRedTag'):IsShown()
	local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(16),standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "OldReturnSystemEntry", "click", eventTab)
	JumpToComeBack(false, true)
end

function MiniLobbyActivePlayerBtn_OnClick()
	local isRedTagShow = getglobal("MiniLobbyFrameTopActivePlayerBtnRedTag"):IsShown()
	if isRedTagShow then
		standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "HighFreqExclusive", "click", {standby1 = 1})
	else
		standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "HighFreqExclusive", "click", {standby1 = 0})
	end
    GetInst('ActivePlayerBenefitsManager'):ReqActivePlayerInfo(function (data)
		getglobal("MiniLobbyFrameTopActivePlayerBtn"):Hide()
		if data then
			if data.w_status == 1 then
				GetInst('ActivePlayerBenefitsManager'):OpenEgg()
				getglobal("MiniLobbyFrameTopActivePlayerBtn"):Show()
			elseif data.w_status == 2 then
				GetInst('ActivePlayerBenefitsManager'):OpenMain()
				getglobal("MiniLobbyFrameTopActivePlayerBtn"):Show()
			end
		end
	end)
end

function MiniLobbyActivePlayerBtn_OnShow()
	local isRedTagShow = getglobal("MiniLobbyFrameTopActivePlayerBtnRedTag"):IsShown()
	if isRedTagShow then
		standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "HighFreqExclusive", "view", {standby1 = 1})
	else
		standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "HighFreqExclusive", "view", {standby1 = 0})
	end
end

function MiniLobbyNewComeBackBtn_OnClick()
	local redDot = GetInst('UserTaskDataManager'):GetNewComeBackCanGetRewardCount()>0 and 1 or 2

	local newComeBackMissions = GetInst("UserTaskDataManager").NewComeBackMissions
	local interval=(newComeBackMissions and newComeBackMissions.msg and newComeBackMissions.msg.end_time) - getServerTime()
	local remainDay = math.floor((interval or 0)/(24*60*60))
	standReportEvent(9999, "MINI_HOMEPAGE_GAP1", "ReturnSystemEntryNew", "click",{standby1 =redDot,standby2= 2,standby3= remainDay})
    JumpToComeBack(true, true)
end

--H5icon 显示
function AtivityRoomTemplate_OnShow()
	local id = this:GetClientID()
	if id > 10 and id < 16 then  --11到15代表H5跳转id
		local actConfigInfo = ActivityConfigInfoByID(id) or {}
		local activity_state = GetInst("TimerUtil"):IsNowTimeInRange(actConfigInfo.start_time,actConfigInfo.end_time)
		if activity_state == 1 and arrRecordReportH5Show[id] == nil then--活动开启
			arrRecordReportH5Show[id] = 1
			local nameid = ""
			if actConfigInfo.nameid then
				nameid = StringDefCsv:get(actConfigInfo.nameid)
			end
			arrRecordReportH5Show[id] = 1
			local strActivity = "H5activity"..id
			if id == 14 then --历史遗留问题 14埋点在之前的版本单独埋过，所以要特殊处理，保持原有埋点
				strActivity = "H5activity"
			end
			standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", strActivity, "view",{ standby1 = GetInst("ActivityMgr"):GetActNameById(id)});
		end		
	end
end


--H5页面跳转
function AtivityRoomTemplate_OnClick()
	local id = this:GetClientID()
	if id > 10 and id < 16  then --11到15代表H5跳转id
		local actConfigInfo = ActivityConfigInfoByID(id) or {}
		local nameid = ""
		if actConfigInfo.nameid then
			nameid = StringDefCsv:get(actConfigInfo.nameid)
		end
		local strActivity = "H5activity"..id
		if id == 14 then --历史遗留问题 14埋点在之前的版本单独埋过，所以要特殊处理，保持原有埋点
			strActivity = "H5activity"
		end
		standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", strActivity, "click",{ standby1 = GetInst("ActivityMgr"):GetActNameById(id)});
	end
	local now_ = getServerTime()
	if getglobal("MiniLobbyFrameTopActivityRoomBoxJumpToH5"..id.."RedTag"):IsShown() then
		--取消红点
		getglobal("MiniLobbyFrameTopActivityRoomBoxJumpToH5"..id.."RedTag"):Hide()
	end
	setkv("activity"..id.."time", now_, "activity"..id, getStatistics.uin_own)
	local actInfo = ActivityLocalInfoByID(id) or {}

    if actInfo and actInfo.jump_app and actInfo.url_ext then
        if actInfo.jump_app ~= "" and actInfo.url_ext ~= "" and ClientMgr:CheckAppInstall(actInfo.jump_app) then --有安装app 跳转app
            open_http_link(actInfo.http or "");
        else
            open_http_link(actInfo.url_ext);
        end
    else
        open_http_link(actInfo.http or "");
    end

	getStatistics.activityid = id
	-- statisticsGameEventNew(820,getStatistics.activityid,getStatistics.lang);
	if actInfo.oID then
		standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", actInfo.oID, "click", {standby1 = GetInst("ActivityMgr"):GetActNameById(id)})
	end
end

--点击跳转,扭蛋
function ActivityRoomPrizeDrawBtn_OnClick()
	GetInst("UIManager"):Open("Shop",{entryType = 0, tabType = 8,});
	local ID = this:GetClientID()
	local shopCtrl = GetInst("UIManager"):GetCtrl("Shop");
	shopCtrl:ChangeTab(shopCtrl.define.tabType.prizeDraw)
	local actInfo = ActivityLocalInfoByID(ID) or {}
	local frameName = actInfo.FrameName or ""
	frameName = ActivityRoomBox..frameName
	local redtag = getglobal(frameName.."RedTag")
	 if redtag and redtag:IsShown() then
		redtag:Hide()
	 end
	getStatistics.activityid = ID
	-- statisticsGameEventNew(820,getStatistics.activityid,getStatistics.lang);

end

--签到
function ActivityRoomSignBtn_OnClick()
	getglobal("ActivityMainFrame"):Show()
	ActivityMainFrame:TypeBtnOnClick(2)
	local ID = this:GetClientID()
	getStatistics.activityid = ID
	-- statisticsGameEventNew(820,getStatistics.activityid,getStatistics.lang);
end

--福利
function AtivityRoomWelfareBtn_OnClick()
	getglobal("ActivityMainFrame"):Show()
	ActivityMainFrame:TypeBtnOnClick(3)
	local ID = this:GetClientID()
	getStatistics.activityid = ID
	-- statisticsGameEventNew(820,getStatistics.activityid,getStatistics.lang);
end

--迷你宝库
function AtivityRoomTreasuryBtn_OnClick()
	OpenActivityFrame();
	ActivitBtnFunc("MiniTreasury");
	press_btn("MiniTreasuryBtn")
	local ID = this:GetParent():GetClientID()
	getStatistics.activityid = ID
	-- statisticsGameEventNew(820,getStatistics.activityid,getStatistics.lang);
end

--实名认证
function AtivityRoomRealNameBtn_OnClick()
	local adsType = RealNameFunc and RealNameFunc.isShowIdentityNameAuth and RealNameFunc:isShowIdentityNameAuth(10)
	if adsType then
		ShowIdentityNameAuthFrame(nil,nil,nil,nil,nil,adsType,true)
	else
		ShowIdentityNameAuthFrame()
	end
	local ID = this:GetClientID()
	getStatistics.activityid = ID
	-- statisticsGameEventNew(820,getStatistics.activityid,getStatistics.lang);
	local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxRealNameBtnRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "RealNameAuthentication", "click", eventTab)
end

--老版家园
function AtivityRoomHomelandBtn_OnShow()
	Homechest_RedFlagCtrl:MainHomelandBtn_RefreshByABTest()
end

--老版家园
function AtivityRoomHomelandBtn_OnClick()
	local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxHomelandBtnNameBkg'):IsShown()
	local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(6),standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "MyHomeLandFruit", "click", eventTab)
	
	if not Homechest_RedFlagCtrl.AbTestHit then
		local id = this:GetClientID()
		local actInfo = ActivityLocalInfoByID(id) or {}
		local frameName = actInfo.FrameName or ""
		frameName = ActivityRoomBox..frameName
		local actionConfig = ActivityConfigInfoByID(id)
		local redtag = getglobal(frameName.."RedTag")
		 if redtag and redtag:IsShown() then
			redtag:Hide()
			local now_ = getServerTime()
			setkv("activity"..id.."time", now_, "activity"..id, getStatistics.uin_own) 
			setkv("activity"..id..actionConfig.start_time,true)
		 end  
	end

	--[[
	Author: sundy
	EditTime: 2021-08-02
	Description: the reason
	--]]

	GetInst("MinilobbyPupTextMgr"):OnTipsHide("HomelandBtnTextTip")

    JumpToHomeChest()
end

--活动入口缩放按钮
function MiniLobbyFrameTopDropDown_OnClick()
	local room = getglobal("MiniLobbyFrameTopActivityRoomBox")
    local icon1 = getglobal("MiniLobbyFrameTopActivityRoomBoxDropDownIcon1")
	local icon2 = getglobal("MiniLobbyFrameTopActivityRoomBoxDropDownIcon2")
	if icon1:IsShown() then
		icon1:Hide()
		icon2:Show()
	else  
		icon2:Hide()
		icon1:Show()
	end
end

--活动入口缩放
function MiniLobbyFrameTopDropDown_OnUpdate()
	local icon1 = getglobal("MiniLobbyFrameTopActivityRoomBoxDropDownIcon1")
	local room = getglobal("MiniLobbyFrameTopActivityRoomBox")
	local posx =room:GetAnchorOffsetX()
	if icon1:IsShown() then
        if posx > 0 then
            posx = posx-MOVE_TICK
    		if posx < 0 then						
    			posx = 0
    		end
            room:SetAnchorOffset(posx,88)
        end	
	else
        if posx < boxwidth - 36 then
            posx = posx+MOVE_TICK			
    		if posx > boxwidth - 36  then	
    			posx = boxwidth - 36
    		end
            room:SetAnchorOffset(posx,88)
        end	
	end
end

function ReNameRegisterServiceListeners()
	if AccountManager and type(AccountManager.service) == 'table' then
		AccountManager.service:listento('renameresult.update', OnReNameUpdate) --推送改成结果
	end
end

--改名更新结果推送
function OnReNameUpdate(data)
	if data then
		if data.result then
			if AccountManager.data_update then
				AccountManager:data_update()
			end
			PEC_RefleshNick(data)
			local isReview = tonumber(data.result) == 3 --审核中

			PEC_ShowRenameReviewUI(isReview)
			PEC_RefreshNewHomePage()	
		end
	end
end

--商店道具刷新监听
function ShopRefreshRegisterServiceListeners()
	if AccountManager and type(AccountManager.service) == 'table' then
		AccountManager.service:listento('refresh_item_notify', OnShopRefreshUpdate)
	end
end
--商店道具刷新结果推送
function OnShopRefreshUpdate(data)
	local refreshList = {}
	if data then
		if data.items_list then
			for key, value in pairs(data.items_list) do
				local itemId = value.id or value.itemid
				local itemDef =  ItemDefCsv:get(itemId);
				if itemDef and itemDef.ShowType > 0 then
					--获取道具在itemDef里配置的展示类型然后去重
					refreshList[itemDef.ShowType] = itemDef.ShowType
				end
			end
		end
	end
	for key, value in pairs(refreshList) do
		--1-皮肤，2-坐骑，3-avatar，6-武器皮肤道具，9-喷漆道具
		if key == 1 then
			local code = AccountManager:data_update()
			local skinLab = GetInst('UIManager'):GetCtrl('ShopSkinLib')
			if skinLab then
				skinLab.model:OrganizeSkinListData()
				skinLab:RefreshForUseSkin()
				skinLab:RefreshForBuySkin()
			end
		elseif key == 2 then
		elseif key == 3 then
			--请求商城皮肤部件的已拥有信息
			local refreshCall = function()
				local skinLab = GetInst('UIManager'):GetCtrl('ShopCustomSkinLib')
				if skinLab then
					skinLab:RefreshForUseSkin()
				end
			end
			local ShopServiceInst = GetInst("ShopService")
			ShopServiceInst:ReqOwnedPartInfo(refreshCall)
		elseif key == 6 then
			--请求玩家所有武器皮肤数据
			local refreshCall = function()
				if if_show_shop_weaponStyle() then
					if GetInst("UIManager"):GetCtrl("ShopWeapon") then
						GetInst("UIManager"):GetCtrl("ShopWeapon"):UpdateWeaponListView()
					end
				else
					if GetInst("UIManager"):GetCtrl("ShopCustomSkinLib") then
						GetInst("UIManager"):GetCtrl("ShopCustomSkinLib"):UpdateWeaponListView()
					end
				end
			end
			GetInst("ShopService"):ReqAllWeaponSkin(refreshCall)
		elseif key == 9 then
			--请求玩家所有喷漆道具
			local refreshCall = function()
				local ShopSprayPaint = GetInst('UIManager'):GetCtrl('ShopSprayPaint')
				if ShopSprayPaint then
					ShopSprayPaint:UpdateListview()
				end
			end
			GetInst("ShopPaintDataManager"):RequestOwnedInfo(true,refreshCall)
		end
	end
end

 --mark by hfb for new minilobby 原大厅，新埋点
--新版埋点，大厅 view 统一处理
local minilobbyStandReportEventTable = {
	MINI_HOMEPAGE_TOP_1 = {
							PersonInformation = "MiniLobbyFrameTopRoleInfo",
							MiniBeanTopUp = "MiniLobbyFrameTopMiniBean",
							MiniCoinTopUp = "MiniLobbyFrameTopMiniCoin",
							Privilege = "MiniLobbyFrameTopChannelRewardBtn",
							Activity = "MiniLobbyFrameTopActivity",
							Email = "MiniLobbyFrameTopMail",
							Setting = "MiniLobbyFrameTopSetting",
						},
	MINI_HOMEPAGE_MAINFUNCTION_1 = {
							StartGame = "MiniLobbyFrameCenterLocalMap",
							WorkShop = "MiniLobbyFrameCenterMiniWorks",
							MutiplayerLobby = "MiniLobbyFrameCenterMultiplayer",
							MyHomeland = "MiniLobbyFrameCenterHomeChest",
						},	
	MINI_HOMEPAGE_ANNOUNCEMENT_1 = {
							Announcement = "MiniLobbyFrameBottomNotice",
						},
	MINI_HOMEPAGE_BOTTOM_1 = {
							WiFiCheck = "MiniLobbyFrameBottomShrink",
							Competition = "MiniLobbyFrameBottomMatch",
							Subscription = "MiniLobbyFrameBottomSubscribe",
							Community = "MiniLobbyFrameBottomCommunity",
							Shop = "MiniLobbyFrameBottomShop",
							Friend = "MiniLobbyFrameBottomBuddy",
							ResourceShop = "MiniLobbyFrameCenterResourceShopBt"
						},
}
--统一埋点view
function MiniLobbyStandReportViewEvent()
	local event = "view"
	for cID, oTable in pairs(minilobbyStandReportEventTable) do
		MiniLobbyStandReportSingleEvent(cID, "-", event)
		for oID, frameName in pairs(oTable) do
			if IsUIFrameShown(frameName) then
				local eventTab = nil
				local redTagName = frameName .. 'RedTag'
				local effectName = frameName .. 'UvA'
				if frameName == 'MiniLobbyFrameTopRoleInfo' then
					local redIsShow = getglobal('MiniLobbyFrameTopRoleInfoHeadPostingRedTag'):IsShown() or getglobal('MiniLobbyFrameTopRoleInfoHeadAchieveRedTag'):IsShown()
					eventTab = {standby2 = (redIsShow and 1 or 0)}
				elseif HasUIFrame(redTagName) then
					local redIsShow = IsUIFrameShown(redTagName) and 1 or 0
					eventTab = {standby2 = redIsShow}
				elseif frameName == 'MiniLobbyFrameBottomShop' then
					local redIsShow = IsUIFrameShown(redTagName) and 1 or 0
					local effectShow = IsUIFrameShown(effectName) and 1 or 0
					eventTab = {standby2 = redIsShow, standby3 = effectShow}
				end
				MiniLobbyStandReportSingleEvent(cID, oID, event, eventTab)
			end
		end
	end
end
local minilobby_report_time = nil
--上报单个大厅埋点
function MiniLobbyStandReportSingleEvent(cID, oID, event, eventTb)
	local curTime = os.clock()
	local timeKey = cID.."_"..oID.."_"..event
	if not minilobby_report_time then minilobby_report_time = {} end
	if minilobby_report_time[timeKey] then
		if curTime - minilobby_report_time[timeKey] <= 0.5 then
			return
		end
		print("MiniLobbyStandReportSingleEvent"..tostring(curTime - minilobby_report_time[timeKey])..cID..oID..event)
	end
	minilobby_report_time[timeKey] = curTime
	local sID = "9999"
	-- print("MiniLobbyStandReportSingleEvent"..sID..cID..oID..event)
	-- local eventTb = nil
	standReportEvent(sID, cID, oID, event, eventTb)
end

function MiniLobbyFrameCenterMiniWorksResourceShopBt_OnClick()
	if IsStandAloneMode() then return end
	-- statisticsGameEventNew(1113, 1);
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "MiniLobbyResources");

	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_BOTTOM_1", "ResourceShop", "click");
	GetInst("ResourceDataManager"):SetIsFromLobby(ResourceCenterOpenFrom.FromLobby)
    GetInst("UIManager"):Open("ResourceShop", { isFromLobby=true }) --大厅打开资源工坊，不显示资源中心入口
    local ctrl = GetInst("UIManager"):GetCtrl("ResourceCenter")
    if not ctrl then
        GetInst("UIManager"):Open("ResourceCenter",{ UpdateView=false })
        GetInst("UIManager"):Close("ResourceCenter")
	end
	local frame = getglobal("ResourceShop");
	if frame and not frame:IsShown() then
		frame:Show();
  end
end

function MiniLobbyFrameCenterMiniWorksResourceShopBt_OnMouseDown()
	local pic = getglobal("MiniLobbyFrameCenterResourceShopBtPic")
	if pic then
		pic:SetSize(70, 70)
	end
	local txt = getglobal("MiniLobbyFrameCenterResourceShopBtText")
	if txt then
		txt:SetPoint("top","MiniLobbyFrameCenterResourceShopBt","top",0,40)
	end
end
function MiniLobbyFrameCenterMiniWorksResourceShopBt_OnMouseUp()
	local pic = getglobal("MiniLobbyFrameCenterResourceShopBtPic")
	if pic then
		pic:SetSize(70, 80)
	end
	local txt = getglobal("MiniLobbyFrameCenterResourceShopBtText")
	if txt then
		txt:SetPoint("top","MiniLobbyFrameCenterResourceShopBt","top",0,45)
	end
end

function MiniLobbyFrameCenterMiniWorksMoneyGodBtn_OnClick()
	GetInst("chinesenewyearMgr"):openMainMapUI();
	GetInst("chinesenewyearMgr"):openMoneyGodUI();
	standReportEvent("9999", "MINI_HOMEPAGE_FLOAT", "WealthButton", "click");

end

function MiniLobbyFrameCenterMiniWorksMoneyGodBtn_OnShow()
	getglobal("MiniLobbyFrameCenterMoneyGodBtnUVAnimationTex"):Show()
	getglobal("MiniLobbyFrameCenterMoneyGodBtnUVAnimationTex"):SetUVAnimation(60, true)
	-- standReportEvent("9999", "MINI_HOMEPAGE_FLOAT", "WealthButton", "view");
end

--新手福利入口点击
function MiniLobbyNoviceWelfareBtn_OnClick()
	local noviceWelfareRedTag = getglobal("MiniLobbyFrameTopActivityRoomBoxNoviceWelfareBtnRedTag")
	if noviceWelfareRedTag:IsShown() then
		noviceWelfareRedTag:Hide()
		local now =  getServerTime()
		setkv("miniLobbyNovice", now) 
	end
	local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxNoviceWelfareBtnRedTag'):IsShown()
	local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(8),standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "NewUserWelfare", "click", eventTab)
	GetInst("UIManager"):Open("noviceWelfare")
end

--是否在新手福利活动期间
function MiniLobby_IsNoviceWelfare()
	local isnovice = 0 -- 1,活动之前的玩家 ，2，活动开始后的新玩家
	local isShowNoviceWelfare = false --是否显示新手福利
	if ns_shop_config2 and ns_shop_config2.newplay_welfare then --是否有新手福利	
		local createTime = AccountManager.get_account_create_time and AccountManager:get_account_create_time() or 0
		local now =  getServerTime()
		local HOUR24 = 86400	--一天等于多少秒
		local start_time = 0
		local end_time = 0
		--过滤版本，渠道相关
		ns_shop_config2.newplay_welfare.apiids = nil
		if check_apiid_ver_conditions(ns_shop_config2.newplay_welfare) and MiniLobby_CheckNoviceWelfare_NewAppIDs() then
			if createTime < MiniLobby_NoviceWelfare_GetStartTime() then--全员开放
				isnovice = 1
				start_time = MiniLobby_GetTodayTimeStamp(MiniLobby_NoviceWelfare_GetStartTime())
			elseif createTime >= MiniLobby_NoviceWelfare_GetStartTime()  then--新手
				isnovice = 2
				--如果玩家是在活动之后创建的号，开始时间等于创号时间 
				start_time = MiniLobby_GetTodayTimeStamp(createTime)			
			end
			end_time = start_time + MiniLobby_NoviceWelfare_GetDays() * HOUR24
			--活动期间
			if now >= start_time and now <= end_time then
				isShowNoviceWelfare = true
			else
				isShowNoviceWelfare = false
			end	
		else
			isShowNoviceWelfare = false
		end
	end
	return isnovice,isShowNoviceWelfare
end

-- 线上新手任务入口,通过这个函数控制线上状态，但是显示时机先做好判断
-- 若需要显示，必须的参数为 param.endtime--任务结束时间(有效期)
-- 其他参数 param.hasReward=true ,存在待领物
local NoviceTaskParam={}
NoviceTaskParam.bNeedBubbleTips=false
NoviceTaskParam.day=nil
NoviceTaskParam.hasReward=nil
function MiniLobbyNoviceTaskBtn_Show(bshow,param)
	--[[
		MiniLobbyFrameTopNoviceTaskBtn--按钮整体
		MiniLobbyFrameTopNoviceTaskBtnRedTag--红点，标识未有未领取物
		MiniLobbyFrameTopNoviceTaskBtnTaskTime--任务时间
		MiniLobbyFrameTopNoviceTaskBtnTipBg--小提示
		MiniLobbyFrameTopNoviceTaskBtnTipBgArrow
		MiniLobbyFrameTopNoviceTaskBtnTip
	--]]
	getglobal("MiniLobbyFrameTopNoviceTaskBtn"):Hide()
	if bshow then
		param=param or {}
		if not param.activateTime or not param.durationTime then--单位是秒，且任务时间是零点刷新，零点结束
			return;
		end
		local nextday=os.date("*t",param.activateTime+24*60*60)
    	local nextday_morrning=os.time({day=nextday.day, month=nextday.month, year=nextday.year, hour=0, minute=0, second=0})
		local task_deadline=nextday_morrning+param.durationTime
		local day=(task_deadline-os.time())/(24*60*60)
		if day>=1 then
			--超过一天显示XX天
			getglobal("MiniLobbyFrameTopNoviceTaskBtnTaskTime"):SetText(string.format("剩余%s天",math.floor(day)))
		else
			--不足一天显示XX小时
			local hours=(task_deadline-os.time())/(60*60)
			getglobal("MiniLobbyFrameTopNoviceTaskBtnTaskTime"):SetText(string.format("剩余%s小时",math.ceil(hours)))
		end
		NoviceTaskParam.day=day
		if not getglobal("MiniLobbyFrameTopNoviceTaskBtn"):IsShown() then
			local m_param={}
			m_param.standby1= param.hasReward and 1 or 0
			m_param.standby2= math.floor(day)
			standReportEvent("9999", "MINI_HOMEPAGE_GAP1", "NoviceTaskEntry", "view", m_param);
		end

		getglobal("MiniLobbyFrameTopNoviceTaskBtn"):Show()
		if not param.hasReward then
			MiniLobbyNoviceTask_ShowRewardRedTag(false)

		else
			MiniLobbyNoviceTask_ShowRewardRedTag(true)
			NoviceTaskParam.bNeedBubbleTips=true
			if getglobal("MiniLobbyFrame"):IsShown() then
				MiniLobbyNoviceTaskBtn_OnShow()
			end
		end
	end
end

--是否有待领取物，显示气泡
function MiniLobbyNoviceTaskBtn_OnShow()
	if NoviceTaskParam.bNeedBubbleTips then
		local ret,param=GetInst("UserTaskInterface"):CheckOpenNoviceTask()
		if ret and param.hasReward then
			MiniLobbyNoviceTask_ShowRewardBubbleTips(true)
			threadpool:work(function()
				threadpool:wait(3)
				MiniLobbyNoviceTask_ShowRewardBubbleTips(false)
				NoviceTaskParam.bNeedBubbleTips=false
			end)
		end
	end
end
--新手任务入口点击
function MiniLobbyNoviceTaskBtn_OnClick()

	GetInst("UserTaskInterface"):OpenNoviceTask()
	MiniLobbyNoviceTask_ShowRewardBubbleTips(false)
	-->report
	local param={}
	param.standby1= getglobal("MiniLobbyFrameTopNoviceTaskBtnRedTag"):IsShown() and 1 or 0
	if NoviceTaskParam.day then
		param.standby2= math.floor(NoviceTaskParam.day)
	end
	standReportEvent("9999", "MINI_HOMEPAGE_GAP1", "NoviceTaskEntry", "click", param);
	--<
end
--红点
function MiniLobbyNoviceTask_ShowRewardRedTag(bshow)
	if not bshow then
		getglobal("MiniLobbyFrameTopNoviceTaskBtnRedTag"):Hide()
	else
		getglobal("MiniLobbyFrameTopNoviceTaskBtnRedTag"):Show()
	end
end
--有奖励可领的提示气泡，展示3秒自动消失或玩家点击任务按钮，进入任务界面时消失
function MiniLobbyNoviceTask_ShowRewardBubbleTips(bshow)
	if not bshow then
		getglobal("MiniLobbyFrameTopNoviceTaskBtnTipBg"):Hide()
		getglobal("MiniLobbyFrameTopNoviceTaskBtnTipBgArrow"):Hide()
		getglobal("MiniLobbyFrameTopNoviceTaskBtnTip"):Hide()
	else
		getglobal("MiniLobbyFrameTopNoviceTaskBtnTipBg"):Show()
		getglobal("MiniLobbyFrameTopNoviceTaskBtnTipBgArrow"):Show()
		getglobal("MiniLobbyFrameTopNoviceTaskBtnTip"):Show()
	end
end


--新手任务二期入口点击
function MiniLobbyNewNoviceTaskBtn_OnClick()
	-- 是否还没开启新手任务
	if GetInst("UserTaskDataManager").data.NewNoviceTaskData.notice_flag == 0 then
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common_comp","miniui/miniworld/common","miniui/miniworld/newNoviceTask", "miniui/miniworld/c_newNoviceTask"})
		GetInst("MiniUIManager"):OpenUI("skin_try_on","miniui/miniworld/newNoviceTask","skin_try_onAutoGen")
		return
	end
	GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/newNoviceTask", "miniui/miniworld/c_newNoviceTask"})
	GetInst("MiniUIManager"):OpenUI("NewNoviceTaskLanding","miniui/miniworld/newNoviceTask","NewNoviceTaskLandingAutoGen")
	local taskdata = GetInst("UserTaskDataManager"):GetNewNoviceTaskStatus();
	local redDot  = 2;
	local interval = taskdata.notice_end_time - getServerTime()
	local remainDay = math.floor(interval/(24*60*60))
	if remainDay <1 then remainDay = 0 end
	if taskdata.final_award_status== 1 or GetInst("UserTaskDataManager"):GetNewNoviceTaskByStatus(1)then
		redDot = 1;
	end
	standReportEvent("9999", "MINI_HOMEPAGE_GAP1", "NoviceTaskEntry2", "click", { standby1 = redDot,standby3=remainDay})
end

function MiniLobbyNewNoviceTaskBtn_OnShow()
	local redDot = 2;
	local taskdata = GetInst("UserTaskDataManager"):GetNewNoviceTaskStatus();
	local interval = taskdata.notice_end_time - getServerTime()
	if taskdata.notice_flag == 1 and interval <= 0  then
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtn"):Hide()
		MiniLobbyRefreshLeftIconPos();
		return;
	end
	local remainDay = math.floor(interval/(24*60*60))
	if remainDay <1 then remainDay = 0 end
	if taskdata and taskdata.final_award_status == 1 then
		redDot = 1
	else
		if GetInst("UserTaskDataManager"):GetNewNoviceTaskByStatus(1) then
			redDot = 1
		end
	end
	MiniLobbyNewNoviceTaskBtnCheckBubble()
	standReportEvent("9999", "MINI_HOMEPAGE_GAP1", "NoviceTaskEntry2", "view", { standby1 = redDot,standby3=remainDay})

end

-- 新手任务二期检测气泡
function MiniLobbyNewNoviceTaskBtnCheckBubble()
	local taskdata = GetInst("UserTaskDataManager"):GetNewNoviceTaskStatus();
	if not taskdata then
		return
	end
	if taskdata and taskdata.final_award_status == 1 and not taskdata.flag1 then
		taskdata.flag1 = true
		MiniLobbyNewNoviceTask_ShowRewardBubbleTips(true)
		threadpool:work(function()
			getglobal("MiniLobbyFrameTopNewNoviceTaskBtnTips"):SetText(GetS(1001207))
			threadpool:wait(3)
			MiniLobbyNewNoviceTask_ShowRewardBubbleTips(false)
		end)
	else
		if GetInst("UserTaskDataManager"):GetNewNoviceTaskByStatus(1) and not taskdata.flag2 then
			taskdata.flag2 = true
			MiniLobbyNewNoviceTask_ShowRewardBubbleTips(true)
			threadpool:work(function()
				getglobal("MiniLobbyFrameTopNewNoviceTaskBtnTips"):SetText(GetS(1001208))
				threadpool:wait(3)
				MiniLobbyNewNoviceTask_ShowRewardBubbleTips(false)
			end)
		else
			if taskdata.notice_flag == 0 and not taskdata.flag3 then
				taskdata.flag3 = true
				MiniLobbyNewNoviceTask_ShowRewardBubbleTips(true)
				threadpool:work(function()
					getglobal("MiniLobbyFrameTopNewNoviceTaskBtnTips"):SetText(GetS(1001207))
					threadpool:wait(3)
					MiniLobbyNewNoviceTask_ShowRewardBubbleTips(false)
				end)
			end
		end
	end
end

function MiniLobbyNewNoviceTask_ShowRewardBubbleTips(bshow)
	if not bshow then
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtnTipsBg"):Hide()
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtnTipsBgArrow"):Hide()
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtnTips"):Hide()
	else
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtnTipsBg"):Show()
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtnTipsBgArrow"):Show()
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtnTips"):Show()
	end
end

function RefreshMiniLobbyNewNoviceTaskBtn()
	if FguiMainIsVisible() then
		local node = GetInst("MiniUIManager"):GetUI("mainAutoGen")
		if node and node.ctrl then
			node.ctrl:RefreshMiniLobbyNewNoviceTaskBtn()
		end
		return
	end
	local taskdata = GetInst("UserTaskDataManager"):GetNewNoviceTaskStatus();
	if taskdata.tasks then
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtn"):Show()
		RefreshNewNoviceTaskBtnRedTag();
		MiniLobbyRefreshLeftIconPos();
		if GetInst("UserTaskDataManager").data.NewNoviceTaskData.notice_flag == 1 then
			getglobal("MiniLobbyFrameTopNewNoviceTaskBtnTaskTime"):SetText(GetS(1001224)..GetInst('UserTaskDataManager'):GetRemainTimeStr(taskdata.notice_end_time))
		else
			getglobal("MiniLobbyFrameTopNewNoviceTaskBtnTaskTime"):SetText('')
		end
	else
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtn"):Hide()
	end
end

function CheckShopBeanIconEffectState()
	local loginNum = getkv("shop_effect_login") or 0

	GetInst('UserTaskDataManager'):ReqNoviceNewuserStatus(function (res)
		if res.ret == 0 then
			if res.msg.new_user_award.state == 0 and loginNum > 1 then
				local shopIcon = getglobal("MiniLobbyFrameBottomShopIcon")
				local shopUva = getglobal("MiniLobbyFrameBottomShopUvA")
				shopIcon:Hide()
				shopUva:Show()
				shopUva:SetUVAnimation(60,true)
			end	
		end
	end)
end

function ShopBeanIconEffectClose()
	local shopIcon = getglobal("MiniLobbyFrameBottomShopIcon")
	local shopUva = getglobal("MiniLobbyFrameBottomShopUvA")
	shopIcon:Show()
	shopUva:Hide()
end

-----------------------------新手任务优化-----------------------------
function CheckNoviceTaskOptimizeBtn(data)
	if data then
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtn"):Show()
		standReportEvent("9999", "MINI_HOMEPAGE_GAP1", "Newplayer_Mission", "view")
	else
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtn"):Hide()
	end
end

function MiniLobbyNoviceTaskOptimizeBtn_OnShow()
	local data = GetInst("NoviceTaskInterface"):GetTaskInfo()
	if data then
		local leftday = data.left_day
		if leftday > 0 then
			getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTaskTime"):SetText("剩余"..leftday.."天")
		else
			--不足一天显示XX小时
			local endTime = data.first_ts + data.duration * 24 * 60 * 60
			local curTime = AccountManager:getSvrTime()
			local hours = (endTime-curTime) / (60*60)
			getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTaskTime"):SetText(string.format("剩余%s小时",math.ceil(hours)))
		end
	end
	MiniLobbyNoviceTaskOptimizeRefreshRedDot()
end

function MiniLobbyNoviceTaskOptimizeBtn_OnClick()
	local count = GetInst("NoviceTaskInterface"):GetRewardCount()
	standReportEvent("9999", "MINI_HOMEPAGE_GAP1", "Newplayer_Mission", "click", {standby1 = count > 1 and 1 or 0})
	GetInst("MiniUIManager"):OpenUI("main_novicetask", "miniui/miniworld/newtask", "main_novicetaskAutoGen")
	getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTipsBgArrow"):Hide()
	getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTips2"):Hide()
	getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTipsBg2"):Hide()
end

function MiniLobbyNoviceTaskOptimizeRefreshRedDot()
	local count = GetInst("NoviceTaskInterface"):GetRewardCount()
	if count > 0 then
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnReward"):SetText(count)
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnRedTag"):Show()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnReward"):Show()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTipsBg"):Show()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTipsBgArrow"):Show()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTips"):Show()
	else
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnRedTag"):Hide()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnReward"):Hide()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTipsBg"):Hide()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTipsBgArrow"):Hide()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTips"):Hide()
	end
end

function MiniLobbyNoviceTaskOptimizeShowBubble(isShow)
	local count = GetInst("NoviceTaskInterface"):GetRewardCount()
	if not isShow or count > 0 then
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTipsBgArrow"):Hide()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTips2"):Hide()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTipsBg2"):Hide()
		return 
	end

	local isNextDay = false
	local lastTime = getkv("OptimizeTask") or {"0","0","0"}
	local curTime = os.date("%Y.%m.%d", AccountManager:getSvrTime()):split('.')
	for i = #curTime, 1, -1 do
		if lastTime[i] ~= curTime[i] then
			isNextDay = true
			break
		end
	end
	if isNextDay then
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTipsBgArrow"):Show()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTips2"):Show()
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnTipsBg2"):Show()
		setkv("OptimizeTask", curTime)
	end
end

function MiniLobbyNoviceTaskOptimizeShowGuide(isShow)
	local Uva = getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtnUvA")
	if isShow then
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtn"):SetFrameLevel(3003)
		Uva:Show()
		Uva:SetUVAnimation(60,true)
		getglobal("MiniLobbyFrameNewTaskGuide"):Show()
	else
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtn"):SetFrameLevel(1500)
		Uva:Hide()
		getglobal("MiniLobbyFrameNewTaskGuide"):Hide()
	end
end

-----------------------------新手任务优化-----------------------------

function RefreshNewNoviceTaskBtnRedTag()
	if IsShowFguiMain() then
		local node = GetInst("MiniUIManager"):GetUI("mainAutoGen")
		if node and node.ctrl then
			node.ctrl:RefreshNewNoviceTaskBtnRedTag()
		end
		return
	end
	local taskdata = GetInst("UserTaskDataManager"):GetNewNoviceTaskStatus();
	local rewardCount =  0;
	for k, v in pairs(taskdata.tasks) do
		if v.status == 1 then 
			rewardCount = rewardCount+1;
		end
	end

	local signdata = GetInst('UserTaskDataManager'):GetDailySignData()
	if signdata and sign_state == 1 then
		rewardCount = rewardCount+1;
	end
	
	if rewardCount>0 then
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtnRedTag"):Show()
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtnReward"):SetText(rewardCount)
	else
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtnRedTag"):Hide()
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtnReward"):SetText("")
	end
end

function RefreshNewNoviceTaskBubbleTips()
	
end

--检测新版渠道ID
function MiniLobby_CheckNoviceWelfare_NewAppIDs()
	local hasNewApiid = false
	local new_apiids = nil
	if ns_shop_config2 and ns_shop_config2.newplay_welfare then
		new_apiids = ns_shop_config2.newplay_welfare.new_apiids
	end
	
	if new_apiids then			
		local finder_ = ',' .. ClientMgr:getApiId() .. ','
		local ret   = string.find( ',' .. new_apiids .. ',', finder_ )
		if ret then
			hasNewApiid =  true
		end
	end
	return hasNewApiid
end

--获取活动开始时间
function MiniLobby_NoviceWelfare_GetStartTime()
	local curApiId = ClientMgr:getApiId()
	if ns_shop_config2.newplay_welfare.new_apiid_cfg and ns_shop_config2.newplay_welfare.new_apiid_cfg[curApiId] then
		return ns_shop_config2.newplay_welfare.new_apiid_cfg[curApiId].starttime or 0
	end
	return ns_shop_config2.newplay_welfare.default_starttime or 0
end

--获取活动持续天数
function MiniLobby_NoviceWelfare_GetDays()
	local curApiId = ClientMgr:getApiId()
	if ns_shop_config2.newplay_welfare.new_apiid_cfg and ns_shop_config2.newplay_welfare.new_apiid_cfg[curApiId] then
		return ns_shop_config2.newplay_welfare.new_apiid_cfg[curApiId].days or 0
	end
	return ns_shop_config2.newplay_welfare.days or 0
end

function MiniLobby_GetLimitSkinDiscount()
	local limitDiscountData = nil
	if ns_shop_config2 and ns_shop_config2.newplay_welfare then
		limitDiscountData = ns_shop_config2.newplay_welfare.skin_discount
	end
	return limitDiscountData
end

--查找限时折扣对应的皮肤价格
function MiniLobby_FindLimitSkinDiscount(skinid)
	local discount = 0
	local days = 0
	local startTime = 0  
    local endTime = 0
	local islimitDicount = false --限时折扣活动
	local isnovice = 0
	isnovice,islimitDicount = MiniLobby_IsNoviceWelfare()
	local createTime = AccountManager.get_account_create_time and AccountManager:get_account_create_time() or 0
	local curTime = AccountManager:getSvrTime() --现在的时间戳  
	if islimitDicount then
		if isnovice == 1 then
			startTime = MiniLobby_GetTodayTimeStamp(MiniLobby_NoviceWelfare_GetStartTime())
		elseif isnovice == 2 then
			startTime = MiniLobby_GetTodayTimeStamp(createTime)
		end
		local limitDiscountData = MiniLobby_GetLimitSkinDiscount()
		
		if limitDiscountData then
			for i = 1, #limitDiscountData do
				local skinTab = limitDiscountData[i]
				if skinTab[1] == skinid then
					endTime = startTime + (skinTab[3] * 86400)--活动结束时间
					local leftTime = endTime - curTime
					if leftTime > 0 then
						discount = skinTab[2]
						days = skinTab[3]
					end
				end
			end
		end
	end
	return discount,days,startTime
end

function MiniLobby_GetTodayTimeStamp(curTime)
    local cDateCurrectTime = os.date("*t",curTime)
    local cDateTodayTime = os.time({year=cDateCurrectTime.year, month=cDateCurrectTime.month, day=cDateCurrectTime.day, hour=0,min=0,sec=0})
    return cDateTodayTime 
end

function MiniLobbyFrameTopActivityRoomBox_OnUpdate()
	MiniLobby_CheckNoviceWelfareIsExpire()
	Homechest_RedFlagCtrl:onUpdate()
end

--检测大厅新手福利是否到期
function MiniLobby_CheckNoviceWelfareIsExpire()
	local noviceWelfareBtn = getglobal("MiniLobbyFrameTopActivityRoomBoxNoviceWelfareBtn")
	if noviceWelfareBtn:IsShown() then
		if ns_shop_config2 and ns_shop_config2.newplay_welfare then
			local createTime = AccountManager.get_account_create_time and AccountManager:get_account_create_time() or 0
			local now =  getServerTime()
			local start_time = 0
			local end_time = 0
			local cDateCurrectTime = 0
			if createTime < MiniLobby_NoviceWelfare_GetStartTime() then
				cDateCurrectTime = os.date("*t",MiniLobby_NoviceWelfare_GetStartTime())
			elseif createTime >= MiniLobby_NoviceWelfare_GetStartTime()  then
				cDateCurrectTime = os.date("*t",createTime)
			end
			start_time = os.time({year=cDateCurrectTime.year, month=cDateCurrectTime.month, day=cDateCurrectTime.day, hour=0,min=0,sec=0})	
			end_time = start_time + MiniLobby_NoviceWelfare_GetDays() * 86400
			--新手福利到期，刷新UI
			if now > end_time then
				RefreshActivityAllIcons()
			end
		end
	end
end

--新UI的演示demo入口
function MiniLobbyFrameNewUIDemo_OnClick()
	Log('new UI cpp demo click')
	if gFunc_IsNewMiniUIEnable and gFunc_IsNewMiniUIEnable() then
		if gFunc_ShowNewUIDemo then
			Log('new UI cpp demo show')
			gFunc_ShowNewUIDemo()
		end
	end
end

function MiniLobbyFrameNewUIDemoLua_OnClick()
	if gFunc_IsNewMiniUIEnable and gFunc_IsNewMiniUIEnable() then
		--for test hfb --2021.03.23
		Log('new UI lua demo show')
		--UIPackage:addPackage("miniui/miniworld/common")
		--GetInst("MiniUIManager"):OpenUI("TestUI", "miniui/miniworld/compose", "MiniUITest", {})
		--do return end

		-- 测demo开这里
		GetInst("MiniUISceneMgr"):loadScene("MenuScene", {})
		HideMiniLobby()
	end
end

--请求玩家首充状态
function MiniLobbyFrame_ReqFirstRechargeStatus()
	if get_game_env() >= 10 then--海外
		return 
	else
		--是否显示首充,开关控制
		if if_show_first_pay() and newfirstrecharge_status.isShowRenew and newfirstrecharge_status.rechargeType == nil then
			GetInst("ShopService"):ReqFirstRechargeStatus(function(ret)
				if ret and ret.ret == ErrorCode.OK then
					local charge_status = {
						rechargeType = ret.type, -- 0 首充 1 续充
						first_charge_status = ret.first_charge_status,--首充奖励状态   0.未达到领取条件  1.可以领取  2.已经领取
						second_charge_status = ret.second_charge_status, --续充奖励状态   0.未达到领取条件  1.可以领取  2.已经领取
						amount = ret.amount, --[Desc2]金额 
						isShowRenew = true,} --默认显示续充
					newfirstrecharge_status = charge_status
					MiniLobbyFrame_ShowFirstRechargeBtn(charge_status)
				end
			end)
		end
	end
end

--点击首冲按钮
function MiniLobbyFrameFirstRechargeBtn_OnClick()
	local firstRechargeRedTag = getglobal("MiniLobbyFrameTopActivityRoomBoxFirstRechargeBtnRedTag")
	--如果再大厅拉取到数据则直接显示，没有拉到数据则重新请求
	if newfirstrecharge_status and next(newfirstrecharge_status) and newfirstrecharge_status.rechargeType ~= nil then
		local isPayed = false
		if (newfirstrecharge_status.rechargeType == 0 and newfirstrecharge_status.first_charge_status ~= 0) or 
		   (newfirstrecharge_status.rechargeType == 1 and newfirstrecharge_status.second_charge_status ~= 0) then
			isPayed = true
		end
		if not isPayed then
			if firstRechargeRedTag:IsShown() then
				firstRechargeRedTag:Hide()
				local now =  getServerTime()
				setkv("miniLobbyFirstRechargeRedTag", now)
			end
		end
		GetInst("UIManager"):Open("ShopFirstRecharge")
	else
		GetInst("ShopService"):ReqFirstRechargeStatus(function(ret)
			if ret and ret.ret == ErrorCode.OK then
				local charge_status = {
					rechargeType = ret.type, -- 0 首充 1 续充
					first_charge_status = ret.first_charge_status,--首充奖励状态   0.未达到领取条件  1.可以领取  2.已经领取
					second_charge_status = ret.second_charge_status, --续充奖励状态   0.未达到领取条件  1.可以领取  2.已经领取
					amount = ret.amount, --[Desc2]金额 
					isShowRenew = true,} --默认显示续充
				newfirstrecharge_status = charge_status
				local isPayed = false
				if (charge_status.rechargeType == 0 and charge_status.first_charge_status ~= 0) or 
				(charge_status.rechargeType == 1 and charge_status.second_charge_status ~= 0) then
					isPayed = true
				end
				if not isPayed then
					if firstRechargeRedTag:IsShown() then
						firstRechargeRedTag:Hide()
						local now =  getServerTime()
						setkv("miniLobbyFirstRechargeRedTag", now)
					end
				end
				GetInst("UIManager"):Open("ShopFirstRecharge")
			end
		end)
	end

	--上报埋点数据
	local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxFirstRechargeBtnRedTag'):IsShown()
	local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(9),standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "ExclusiveReward", "click", eventTab)

end

--隐藏首充[Desc2]按钮
function MiniLobbyFrame_HideFirstRechargeBtn()
	local firstRechargeBtn = getglobal("MiniLobbyFrameTopActivityRoomBoxFirstRechargeBtn")
	firstRechargeBtn:Hide()
	ActivityRoomRefresh()
end

--显示首充按钮
-- local charge_status = {
-- 	rechargeType , -- 0 首充 1 续充
-- 	first_charge_status,--首充奖励状态   0.未达到领取条件  1.可以领取  2.已经领取
-- 	second_charge_status, --续充奖励状态   0.未达到领取条件  1.可以领取  2.已经领取
-- 	amount = ret.amount, } --[Desc2]金额
function MiniLobbyFrame_ShowFirstRechargeBtn(charge_status,switchAccount,needReport)
	if needReport then
		needReportCache["ExclusiveReward"] = true
	end
	if  charge_status.rechargeType == nil or charge_status.isShowRenew == false then
		return
	end
	local firstRechargeBtn = getglobal("MiniLobbyFrameTopActivityRoomBoxFirstRechargeBtn")
	local firstRechargeRedTag = getglobal("MiniLobbyFrameTopActivityRoomBoxFirstRechargeBtnRedTag")

	if charge_status.second_charge_status ~= 2 then
		if switchAccount  then
			ActivityRoomRefresh()
		end
		firstRechargeBtn:Show()
		ActivityRoomBoxSizeRefresh()
		local isPayed = false --是否[Desc2]
		local isRecieveAward = false --是否领取奖励
		if (charge_status.rechargeType == 0  and charge_status.first_charge_status ~= 0) or 
			(charge_status.rechargeType == 1  and charge_status.second_charge_status ~= 0) then
				isPayed =  true
		end
		if (charge_status.rechargeType == 0  and charge_status.first_charge_status == 1) or 
			(charge_status.rechargeType == 1  and charge_status.second_charge_status == 1) then
			isRecieveAward =  true
		end
		--玩家是否[Desc2]
		if isPayed then
			if isRecieveAward then--未领取奖励
				-- firstRechargeRedTag:Show()
			else
				firstRechargeRedTag:Hide()
			end
		else --未[Desc2] 一周显示一次红点
			local now = AccountManager:getSvrTime()
			local redTagTime = getkv("miniLobbyFirstRechargeRedTag") or 0
			if AccountManager:isSameWeek(now, redTagTime) then
				firstRechargeRedTag:Hide()
			else 
				-- firstRechargeRedTag:Show()
			end
		end
		if miniLobbyFrameTopActivity_Num <= 0 then 
			getglobal("MiniLobbyFrameTopActivityRoomBox"):Hide()
		else
			getglobal("MiniLobbyFrameTopActivityRoomBox"):SetSize(30+75*miniLobbyFrameTopActivity_Num,36)
			boxwidth = getglobal("MiniLobbyFrameTopActivityRoomBox"):GetWidth()	
		end
		--上报埋点数据
		local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxFirstRechargeBtnRedTag'):IsShown()
		if needReport or needReportCache["ExclusiveReward"] then
			needReportCache["ExclusiveReward"] = nil
			local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(9),standby2 = (redIsShow and 1 or 0)}
			MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "ExclusiveReward", "view", eventTab)
		end

		if ns_version.firstpay.iconName then
			getglobal("MiniLobbyFrameTopActivityRoomBoxFirstRechargeBtnName"):SetText(ns_version.firstpay.iconName)
		end
		if ns_version.firstpay.icon then
			DownloadPicAndSet(getglobal("MiniLobbyFrameTopActivityRoomBoxFirstRechargeBtnIcon"), ns_version.firstpay.icon)
		end
	else
		firstRechargeBtn:Hide()
		if switchAccount  then
			ActivityRoomRefresh()
		end
	end
end

-- ID索引活动信息
function ActivityLocalInfoByID(id)
	for _, value in pairs(ActivityInfo) do
		if id == value.ID then
			return value
		end
	end

	return {}
end
--ID索引配置活动信息
function ActivityConfigInfoByID(id)
	for _, value in pairs(action_conf) do
		if id == value.id then
			return value
		end
	end

	return {}
end

--刷新活动框
function RefreshActivityAllIcons(needReport)
	ActivityRoomRefresh(needReport);
	MiniLobbyFrame_ShowFirstRechargeBtn(newfirstrecharge_status,false,needReport)
end

------------------------------音乐会活动---------------------------------------
function CheckActivityRoomConcertBtnShow()
	return false --ActivityConcertMgr and ActivityConcertMgr:CheckIsInActivityPeroid()
end

function CheckActivityRoomBox_MiniVipShow()
	if not ns_business_config or not ns_business_config.vip_cfg then
		return false
	end

	return check_apiid_ver_conditions(ns_business_config.vip_cfg.VipLobbyEntranceCfg)
end

function RefreshActivityRoomConcertBtn(bt)
	if not bt then return end
	GetFrame(nil, "ConcertBtn")

	local iconUrl = ""
	if ActivityConcertMgr then
		iconUrl = ActivityConcertMgr:GetIconUrl()
	end

	if roomInfo.Name then
		roomInfo.Name:SetText(ActivityConcertMgr:GetIconName())
	end
	
	DownloadPicAndSet(roomInfo.Icon, iconUrl, roomInfo.Frame)
end

function ActivityRoomConcertBtn_OnClick()
	local concertBtn = this
	if concertBtn and concertBtn:IsShown() and ActivityConcertMgr then
		ActivityConcertMgr:ShowActivityPaper()
	end
end

function ActivityRoomConcertBtn_OnShow()
	getglobal("MiniLobbyFrameTopActivityRoomBoxConcertBtnIcon"):Hide()
	getglobal("MiniLobbyFrameTopActivityRoomBoxConcertBtnUVAnimationTex"):Show()
	getglobal("MiniLobbyFrameTopActivityRoomBoxConcertBtnUVAnimationTex"):SetUVAnimation(40, true)

end

------------------------------生日派对活动--------------------------------------
function CheckActivityRoomBirthdayPartyBtnShow()
	-- return BirthdayPartyMgr and BirthdayPartyMgr:IsSwitch() -- 打开首页大厅生日派对按钮的显示
	return false -- 隐藏首页大厅生日派对按钮的显示，入口改到活动页
end

function RefreshActivityRoomBirthdayPartyBtn(bt)
	if not bt then return end
	GetFrame(nil, "BirthdayPartyBtn")

	local iconUrl = ""
	if BirthdayPartyMgr then
		iconUrl = BirthdayPartyMgr:GetPartyConfig().icon or ""
	end
	
	DownloadPicAndSet(roomInfo.Icon, iconUrl, roomInfo.Frame)
end

function RefreshActivityRoomBirthdayPartyBtnRedTagShow(bt)
	if not bt then return end
	local bShow = BirthdayPartyMgr:GetIconRedTagShow() or false
	local redTag = getglobal(bt:GetName().."RedTag")
	if redTag then
		bShow = bShow or false
		if bShow and not redTag:IsShown() then
			redTag:Show()
		elseif not bShow and redTag:IsShown() then
			redTag:Hide()
		end
	end
end

--点击生日派对
function ActivityRoomBirthdayPartyBtn_OnClick()
	local birthdayPartyBtn = this
	if birthdayPartyBtn and birthdayPartyBtn:IsShown() and BirthdayPartyMgr then
		local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxBirthdayPartyBtnRedTag'):IsShown()
		local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(10),standby2 = (redIsShow and 1 or 0)}
		MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "Birthday", "click", eventTab)

		-- 交给 BirthdayPartyMgr
		local bShow = BirthdayPartyMgr:ShowRightView()

		-- 红点展示逻辑， time后显示
		local bRedTagShow = BirthdayPartyMgr:GetIconRedTagShow() or false 
		if bShow and bRedTagShow then
			BirthdayPartyMgr:SetIconRedTagShow(false)
			BirthdayPartyMgr:SetBirhDayIconRedTime()
			
			RefreshActivityRoomBirthdayPartyBtnRedTagShow(birthdayPartyBtn)
			local delayTime = BirthdayPartyMgr:GetPartyConfig().red_day or 0
			BirthdayPartyMgr:RemoveThreadDelay(1)
			local gid = threadpool:delay(delayTime, function ()
				BirthdayPartyMgr:SetIconRedTagShow(true)
				RefreshActivityRoomBirthdayPartyBtnRedTagShow(birthdayPartyBtn)
			end)

			BirthdayPartyMgr:SetThreadDelayID(1, gid)
		end
	end
end


function MiniLobbyFrameWholePeopleCreateBtn_OnClick()
	local checkVersion = nil;
	if action_conf and #action_conf >0 then
		for index = 1, #action_conf do
			if action_conf[index].id and action_conf[index].id == 7 then
				checkVersion = action_conf[index].check_version;
			end
		end
	end
	if not checkVersion then
		ShowGameTips(GetS(41474), 3);
		return;
	end
	local checkVersionNumber = ClientMgr:clientVersionFromStr(checkVersion);
	local gameVersion = LuaInterface:getCltVersion();
	if gameVersion < checkVersionNumber then
		ShowGameTips(GetS(110001), 3)
		return;
	end
	local id = this:GetClientID()
	local actInfo = ActivityLocalInfoByID(id) or {}
	local frameName = actInfo.FrameName or ""
	frameName = ActivityRoomBox..frameName
	local redtag = getglobal(frameName.."RedTag")
	if redtag and redtag:IsShown() then
	   redtag:Hide()
	   local now_ = getServerTime()
	   setkv("activity"..id.."time", now_, "activity"..id, getStatistics.uin_own) 
	end  
	--打开抽奖页面
	GetInst("UIManager"):Open("CreatorFestival")
end


function MiniLobbyFrameMainGuardBtn_OnClick()
	GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/signin", "miniui/miniworld/c_activity"})
	GetInst("MiniUIManager"):OpenUI("main_guard","miniui/miniworld/signin","main_guardAutoGen")	
end

function MiniLobbyFrameMainGuardBtn_OnShow()
	GetInst("MainGuardManager"):init();
end

function MiniLobbyFrameNationalDayBtn_OnClick()
	GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/activitychinesestyle", "miniui/miniworld/c_activity"})
	GetInst("MiniUIManager"):OpenUI("main","miniui/miniworld/activitychinesestyle","MiniUINationalDayMain")	
end

function MiniLobbyFrameNationalDayBtn_OnShow()
	standReportEvent("9802", "NATIONAL_DAY_TOP", "", "view");
end

function MiniLobbyFrameWholePeopleCreateBtn_OnShow()

end

function MiniLobbyFrameTreasureBtn_OnClick()
	GetInst("countryTreasureDataMgr"):InitPlayerData()

end

function MiniLobbyFrameTreasureBtn_OnShow()

end

function MiniLobbyFrameYearVoteBtn_OnClick()

	GetInst("developerDataMgr"):openPanel()
end

function MiniLobbyFrameYearVoteBtn_OnShow()

end

function MiniLobbyFrameArmorBtn_OnClick()

	GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/Armorwarrior", "miniui/miniworld/c_img_armorwarrior"})
	GetInst("MiniUIManager"):OpenUI("ArmorMain","miniui/miniworld/Armorwarrior","ArmorMainAutoGen")	
end

function MiniLobbyFrameArmorBtn_OnShow()

end

function MiniLobbyFrameXiaoLouBtn_OnClick()
	GetInst("DigitalAlbumManager"):OpenActivityView()
end

function MiniLobbyFrameXiaoLouBtn_OnShow()

end


function MiniLobbyFrameFestivaBtn_OnClick()
	-- GetInst("countryTreasureDataMgr"):InitPlayerData()

	--[[JumpToShop()
	GetInst("UIManager"):GetCtrl("Shop"):TabBtnClicked(3)]]
	--GetInst("ActivityConcertMgrCls"):ReqJoinActivityRoom()
	GetInst("MiNiMusicFestivalService"):OpenUI()
end

function MiniLobbyFrameFestivaBtn_OnShow()

	getglobal("MiniLobbyFrameTopActivityRoomBoxFestivaBtnIcon"):Hide()
	getglobal("MiniLobbyFrameTopActivityRoomBoxFestivaBtnUVAnimationTex"):Show()
	getglobal("MiniLobbyFrameTopActivityRoomBoxFestivaBtnUVAnimationTex"):SetUVAnimation(40, true)
end

function MiniLobbyFrameNewYearBtn_OnClick()
	local find = false
	for i, v in ipairs(action_conf) do
		if v.id == 26 then
			global_jump_ui(v.jump)
			find = true
			break
		end
	end
	if not find then
		GetInst("chinesenewyearMgr"):openMainMapUI()
	end
end


function MiniLobbyFrameNewYearBtn_OnShow()

	getglobal("MiniLobbyFrameTopActivityRoomBoxNewYearBtnIcon"):Hide()
	getglobal("MiniLobbyFrameTopActivityRoomBoxNewYearBtnUVAnimationTex"):Show()
	getglobal("MiniLobbyFrameTopActivityRoomBoxNewYearBtnUVAnimationTex"):SetUVAnimation(40, true)
end

function MiniLobbyFrameAnniversaryBtn_OnClick()
	GetInst("ActivityAnniversaryManager"):OpenAnniversaryMainView(1)
	local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxAnniversaryBtnRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "AnniversaryOld", "click", eventTab)
end


function MiniLobbyFrameAnniversaryBtn_OnShow()

	getglobal("MiniLobbyFrameTopActivityRoomBoxAnniversaryBtnIcon"):Hide()
	getglobal("MiniLobbyFrameTopActivityRoomBoxAnniversaryBtnUVAnimationTex"):Show()
	getglobal("MiniLobbyFrameTopActivityRoomBoxAnniversaryBtnUVAnimationTex"):SetUVAnimation(40, true)

	local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxAnniversaryBtnRedTag'):IsShown()
	local eventTab = {standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "AnniversaryOld", "view", eventTab)
end

function MiniLobbyFrameMiniWorkerBtn_OnClick()
	-- ShowGameTips("打开迷你打工人")
	standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "HappyTown", "click");
	GetInst("MiniWorkerManger"):OpenMiniWorkerMainView()
end

function MiniLobbyFrameMiniWorkerBtn_OnShow()
	standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "HappyTown", "view");
	getglobal("MiniLobbyFrameTopActivityRoomBoxMiniWorkerBtnIcon"):Hide()
	getglobal("MiniLobbyFrameTopActivityRoomBoxMiniWorkerBtnUVAnimationTex"):Show()
	getglobal("MiniLobbyFrameTopActivityRoomBoxMiniWorkerBtnUVAnimationTex"):SetUVAnimation(90, true)
end

---------------------------------觉醒活动---------------------------------
function MiniLobbyFrameJuexingBtn_OnShow()
	standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "Awaken", "view");
end

function MiniLobbyFrameJuexingBtn_OnClick()
	GetInst("ActivityAwakenManager"):OpenHall()
	standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "Awaken", "click");
end

---------------------------------端午活动---------------------------------

function MiniLobbyFrameBoatFestivalBtn_OnClick()
	GetInst("BoatFestivalManager"):OpenMainView()
	standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "DragonBoatFestival", "click");
end

function MiniLobbyFrameBoatFestivalBtn_OnShow()
	GetInst("BoatFestivalManager"):Init();
	getglobal("MiniLobbyFrameTopActivityRoomBoxBoatFestivalBtnIcon"):Hide()
	getglobal("MiniLobbyFrameTopActivityRoomBoxBoatFestivalBtnUVAnimationTex"):Show()
	getglobal("MiniLobbyFrameTopActivityRoomBoxBoatFestivalBtnUVAnimationTex"):SetUVAnimation(90, true)
	standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "DragonBoatFestival", "view");
end

function RefreshMiniLobbyBoatFestivalBtn(activity_state)
	local btn = getglobal("MiniLobbyFrameTopActivityRoomBoxBoatFestivalBtn")
	if btn and activity_state == 1 then
		btn:Show()
	elseif btn then
		btn:Hide()
	end
end


---------------------------------斗罗大陆活动---------------------------------
function MiniLobbyFrameDouluoBtn_OnClick()
	GetInst("ActivityDouluoManager"):OpenMainUI();
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "MiniDouluo", "click");
end

function MiniLobbyFrameDouluoBtn_OnShow()
	getglobal("MiniLobbyFrameTopActivityRoomBoxDouluoBtnIcon"):Hide()
	getglobal("MiniLobbyFrameTopActivityRoomBoxDouluoBtnUVAnimationTex"):Show()
	getglobal("MiniLobbyFrameTopActivityRoomBoxDouluoBtnUVAnimationTex"):SetUVAnimation(90, true)
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "MiniDouluo", "view");
end

----------------------------------PVP---------------------------------------
function MiniLobbyFramePvpCompetitionBtn_OnShow()

	--[[getglobal("MiniLobbyFrameTopActivityRoomBoxPvpCompetitionBtnIcon"):Hide()
	getglobal("MiniLobbyFrameTopActivityRoomBoxPvpCompetitionBtnUVAnimationTex"):Show()
	getglobal("MiniLobbyFrameTopActivityRoomBoxPvpCompetitionBtnUVAnimationTex"):SetUVAnimation(40, true)--]]
	getglobal("MiniLobbyFrameTopActivityRoomBoxPvpCompetitionBtnRedTag"):Show()
	local pvpItemConfig = nil
	for i, v in ipairs(action_conf) do
		if v.id == 82 then
			pvpItemConfig = v
			break
		end
	end
	standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "Fight_Activity", "click");
	GetInst("PvpCompetitionManager"):getPvpCacheConfigFile(pvpItemConfig)
end

function MiniLobbyFramePvpCompetitionBtn_OnClick()
	-- GetInst("PvpCompetitionManager"):pvpEventReport("9999", "MINI_HOMEPAGE_PVPEVENTCOMPETITION", "Fight_Activity", "click")
	ShowNoTransparentLoadLoop()	--拦截点击事件菊花	
	local pvpItemConfig = nil
	for i, v in ipairs(action_conf) do
		if v.id == 82 then
			pvpItemConfig = v
			break
		end
	end
	GetInst("PvpCompetitionManager"):openPvpEventByNotice(pvpItemConfig.http);
end

---------------------------------会员活动---------------------------------

function MiniLobbyFrameVipActBtn_OnClick()
	local open = function()
		if getglobal("MiniLobbyFrame"):IsShown() then
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/common_comp"})
    		GetInst("MiniUIManager"):OpenUI("Party_main","miniui/miniworld/Member_group","Party_mainAutoGen", {fullScreen={Type="Normal", bkgName="loader_img_Member_group_bg11"}})
		end
	end
	if not GetInst('VipActDataManager'):GetConfig() then -- 如果没有拉取到配置
		GetInst('UserTaskService'):ReqMissionLuaConfig(nil,function(ret)
			if ret and type(ret)=="table" then
				local config_parse = {}
				for k, v in pairs(ret) do
					if type(k)=="number" and type(v)=="table" then
						config_parse[k]=v
					end 
				end
				GetInst("VipActDataManager"):InitMissionConfg(config_parse)
				open()
			end
		end)
	else
		open()
	end
end

function MiniLobbyFrameVipActBtn_OnShow()
	-- GetInst("BoatFestivalManager"):Init();
	getglobal("MiniLobbyFrameTopActivityRoomBoxVipActBtnIcon"):Hide()
	getglobal("MiniLobbyFrameTopActivityRoomBoxVipActBtnUVAnimationTex"):Show()
	-- standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "DragonBoatFestival", "view");
end

---------------------------------全民创造节活动---------------------------------

function MiniLobbyFrameCreateFestivalBtn_OnClick()
	GetInst("NationalCreateFestivalMgr"):OpenMainView()
	--standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "DragonBoatFestival", "click");
end

function MiniLobbyFrameCreateFestivalBtn_OnShow()
	--GetInst("NationalCreateFestivalMgr"):Init();
	getglobal("MiniLobbyFrameTopActivityRoomBoxCreateFestivalBtnIcon"):Hide()
	--getglobal("MiniLobbyFrameTopActivityRoomBoxCreateFestivalBtnUVAnimationTex"):Show()
	--getglobal("MiniLobbyFrameTopActivityRoomBoxCreateFestivalBtnUVAnimationTex"):SetUVAnimation(90, true)
	--standReportEvent("9999", "MINI_HOMEPAGE_TELESCOPICLIST_1", "DragonBoatFestival", "view");
end

function RefreshMiniLobbyCreateFestivalBtn(activity_state)
	local btn = getglobal("MiniLobbyFrameTopActivityRoomBoxCreateFestivalBtn")
	if btn and activity_state == 1 then
		btn:Show()
	elseif btn then
		btn:Hide()
	end
end

------------------------------特定场景触发的活动推送--------------------------------------

-- 入口按钮
function MiniLobbyFrameActivityTriggerBtn_OnClick()
	local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxActivityTriggerBtnRedTag'):IsShown()
	local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(17),standby2 = (redIsShow and 1 or 0)}
	MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "Surprise", "click", eventTab)
	CheckActivityTriggerEntranceIsShow(true)
end

-- 显示触发活动界面
function ShowActivityTriggerMainFrame(ret, isClick)
	if not getglobal("MiniLobbyFrame"):IsShown() then return end
	local isShow = false
	if ret and ret.ret == 0 then
		if ret.data and next(ret.data) then
			if isClick and not ClientCurGame:isInGame() then
				-- 玩家主动点击则直接打开
				GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/common_comp", "miniui/miniworld/c_activity"})
				GetInst("MiniUIManager"):OpenUI("main_avtivitytigger", "miniui/miniworld/activitytrigger", "ActivityTriggerMain", ret.data)
			else
				-- 玩家行为触发活动上报，需判断当前是否有触发新的礼包
				local index, count = 0, 0
				if CheckActivityTriggerPackageList then
					local list = CheckActivityTriggerPackageList
					for key, value in pairs(ret.data) do
						count = count + 1
						for i = 1, #list do
							if list[i] and list[i].id and key == list[i].id then
								index = index + 1
								break
							end
						end
					end
				end
				if (index ~= count or CheckActivityTriggerPackageList == nil) and not ClientCurGame:isInGame() then
					-- 如果有新增的礼包则强弹（游戏内不弹）
					GetInst("ActivityPopupManager"):InsertActivity(1, function(param)
						GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/common_comp", "miniui/miniworld/c_activity"})
						GetInst("MiniUIManager"):OpenUI("main_avtivitytigger", "miniui/miniworld/activitytrigger", "ActivityTriggerMain", param)
					end, ret.data)
				end
			end
			-- 显示活动入口
			isShow = true
			-- 重置数据
			local i, info = 0, {}
			for key, value in pairs(ret.data) do
				i = i + 1
				info[i] = {id = key, timer = value}
			end
			table.sort(info, function(a, b) return a.timer < b.timer end)
			CheckActivityTriggerPackageList = info
		else
			CheckActivityTriggerPackageList = nil
		end
	else
		CheckActivityTriggerPackageList = nil
	end
	local ActivityTriggerBtn = getglobal("MiniLobbyFrameTopActivityRoomBoxActivityTriggerBtn")
	if ActivityTriggerBtn then
		if isShow then
			ActivityTriggerBtn:Show()
			local redIsShow = getglobal('MiniLobbyFrameTopActivityRoomBoxActivityTriggerBtnRedTag'):IsShown()
			local eventTab = {standby1 = GetInst("ActivityMgr"):GetActNameById(17),standby2 = (redIsShow and 1 or 0)}
			MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "Surprise", "view", eventTab)
		else
			ActivityTriggerBtn:Hide()
		end
		ActivityRoomBoxSizeRefresh()
	end
end

-- 礼包查询
function CheckActivityTriggerEntranceIsShow(isClick)
	threadpool:work(function()
		if not IsActivityTriggerOpen then return end
		if isClick then
			ShowLoadLoopFrame(true, "CheckActivityTriggerEntranceIsShow business?act=pushactivity_gift_query_new")
		end

		local url = g_http_root .. "/miniw/business?"
		local reqParams = {
			act = 'pushactivity_gift_query_new',
		}
		local paramStr, md5 = http_getParamMD5(reqParams)
		url = url .. paramStr .. '&md5=' .. md5
		ns_http.func.rpc(url, function(ret)
			if isClick then
				ShowLoadLoopFrame(false)
			end
			ShowActivityTriggerMainFrame(ret, isClick)
		end, nil, nil, 2, true)  --business
	end)
end

-- 触发事件上报
function ActivityTriggerReportEvent(eventId, value, id)
	threadpool:work(function()
		if not CheckActivityTriggerConfigEventContent(eventId) then return end
		local url = g_http_root .. "/miniw/business?"
		local reqParams = {
			act = 'pushactivity_event_update_new',
			event = eventId,
			value = value,
			param_id = id or 0,
		}
		local paramStr, md5 = http_getParamMD5(reqParams)
		url = url .. paramStr .. '&md5=' .. md5
		ns_http.func.rpc(url, function(ret)
			--事件上报时，取消惊喜礼包弹窗，改为返回大厅后主动查询
			-- ShowActivityTriggerMainFrame(ret)
		end, nil, nil, 2, true)  --business
	end)
end

-- 通过事件id获取配置
--[[
	ns_shop_config2.Pushactivity = {
        switch            = 1,           -- 功能开关：1开启，0关闭 
        version_min       = '0.52.5',    -- 最小版本号 
        apiids            = '1,110,999,45', -- 开启的渠道 
        day_limit         = 10,         -- 每日触发个数上限
        times_limit       = 5,          -- 同一时间内礼包的触发上限
        gift_time         = 1800,       -- 礼包有效时长
        event             = {
       		[3014]        = {                        -- 根据上述场景定义每个具体内容的事件标识，如1代表完成1次扭蛋5连抽，以此类推
				title     ="家园礼包",
				target    = 10,                      -- 部分事件类型内的值
				id = { [1] = true, [2] = true } ,

				times     = 3600,                -- 单位时间配置，单位秒
				rate      = 60,                        -- 完成对应时间后，触发礼包的概率，百分比值

				prices_id = 10000,                -- 货币类型，[Desc5]礼包的消耗货币
				prices    = 10,                        -- 礼包价格
				gift      = {                     -- 礼包内容
						{ id = 20154, num = 10 }, 
						{ id = 20155, num = 10 },
						{ id = 20156, num = 10 },
				},
			},
        },
	},
]]
function GetActivityTriggerConfigByIndex(index)
	if IsActivityTriggerOpen then
		if index and ns_shop_config2.Pushactivity.gift_list then
			return copy_table(ns_shop_config2.Pushactivity.gift_list[index])
		end
	end
	return nil
end

--[[
	检测一个eventid的活动存在与否
	@param: eventid 事件id 用来检测该事件存在与否
	@param：id 相应的id列表的id 判断该物品id（皮肤、坐骑、avatar等）是否在id列表中 从而需要上报数据
--]]
function CheckActivityTriggerConfigEventContent(eventid, id)
	local enabled = false
	if ns_shop_config2 and ns_shop_config2.Pushactivity and ns_shop_config2.Pushactivity.event_list then
		local eventList = ns_shop_config2.Pushactivity.event_list[eventid]
		if eventList then
			if id then
				for index, value in ipairs(eventList) do
					if value.id and value.id[id] then
						enabled =true
						break
					end
				end
			else
				enabled = true
			end
		end
	end

	return enabled
end

-- 判断触发器活动配置是否开启
IsActivityTriggerOpen = false
function CheckActivityTriggerSwitch()
	if ns_shop_config2 and ns_shop_config2.Pushactivity and ns_shop_config2.Pushactivity.switch == 1 and
		check_apiid_ver_conditions(ns_shop_config2.Pushactivity) then
		IsActivityTriggerOpen = true
	end
end

-- 获取配置
function GetActivityTriggerConfig(param)
	if IsActivityTriggerOpen then
		return ns_shop_config2.Pushactivity[param]
	end
	return nil
end

-- 在线时长上报
function ActivityTriggerOnLineTimeReport()
	if ActivityTriggerOnLineTimeReportTimer then
		threadpool:kick(ActivityTriggerOnLineTimeReportTimer)
		ActivityTriggerOnLineTimeReportTimer = nil
	end
	ActivityTriggerOnLineTimeReportTimer = threadpool:work(function()
		local interval = 10 * 60
		while true do
			threadpool:wait(interval)
			if AccountManager.get_time_since_online then
				-- 场景触发活动上报: event_id = 1002  游戏玩法-在线时长-1、游戏在线时长达x （以秒为单位）
				ActivityTriggerReportEvent(1002, interval)
			end

		end
	end)
end

function NationalDayOnlineCnt()
	threadpool:work(function ()
		local cnt = 1
		while true do
			if #GetInst("UserTaskDataManager").nationalDayMissions > 0 then
				local inCompleteTask = GetInst("UserTaskDataManager"):GetInCompleteNationalMission(22)
				if not inCompleteTask then
					return
				end
				if cnt >= 60 then
					local param = {}
					param.event = 22 -- "OnlineTime" = 22, --在线时长
					GetInst("UserTaskDataManager"):ReqNationalMissionEvent(param)
					cnt = 0
				end
				cnt = cnt + 1
			end
			threadpool:wait(1)
		end
	end)
end

function YearVoteOnlineCnt()
	-- 年度投票初始化
	threadpool:work(function ()
		local cntDevelop = 1
		while true do
			if GetInst("developerDataMgr"):getMissionLen() > 0 and GetInst("developerDataMgr"):GetActivityStage() == 1 then
				local inCompleteTask = GetInst("developerDataMgr"):GetInCompleteMission(22)
				if inCompleteTask == nil then
					return
				end
				if cntDevelop >= 60 then
					local param = {}
					param.event = 22 -- "OnlineTime" = 22, --在线时长
					param.value = 60
					param.mission_type = GetInst("developerDataMgr"):GetActivityType()
					GetInst("developerDataMgr"):ReqMissionEvent(param,function()
						local ctrl = GetInst("MiniUIManager"):GetCtrl("getTickets")
						if ctrl then
							ctrl:RefreshList()
						end
					end)
					cntDevelop = 0
				end
				cntDevelop = cntDevelop + 1
			end
			threadpool:wait(1)
		end
	end)
end

-- 签到初始化
function InitWeekSign()
	-- body
	GetInst("activity_home_patService"):Init()
end

------------------迷你基地-引流-----------------------------
function GetActivityRoomMiniBaseDrainageBtSwitch(sceneStr)
	local bShow = false
	if ns_version and ns_version.mini_base_drainage_cfg and ns_version.mini_base_drainage_cfg[sceneStr] then
		bShow = check_apiid_ver_conditions( ns_version.mini_base_drainage_cfg[sceneStr])
	end

	print("GetActivityRoomMiniBaseDrainageBtSwitch mini_base_drainage_cfg", ns_version.mini_base_drainage_cfg or {})

	return bShow
end

function GetActivityRoomMiniBaseDrainageBtIcon()
	local textureRes = "icon_prize_b"

	local curTime = AccountManager:getSvrTime() or os.time()
	local tb = os.date("*t", curTime)
	if AccountManager.get_week_day then
		local wday = AccountManager:get_week_day(tonumber(tb.wday))
		-- 1357 女生
		if wday and (1 == (wday % 2)) then
			textureRes = "icon_prize_g"
		end
	end

	return textureRes
end

function RefreshActivityRoomMiniBaseDrainageBt()
	local miniBaseBtName = "MiniLobbyFrameTopMiniBaseDrainageBtn"
	local miniBaseBt = getglobal(miniBaseBtName)
	if not miniBaseBt then return end
	--MiniBase隐藏迷你基地下载
	if MiniBaseManager:isMiniBaseGame() then 
		miniBaseBt:Hide()
		return
	end

	
	local bShow = GetActivityRoomMiniBaseDrainageBtSwitch("lobby")
	if bShow then
		miniBaseBt:Show()
		MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "SkinReward", "view")
	else
		miniBaseBt:Hide()
	end

	local Icon = getglobal(miniBaseBtName.."Icon")
	local textureRes = GetActivityRoomMiniBaseDrainageBtIcon()
	if Icon and textureRes then
		Icon:SetTexUV(textureRes);
	end
end

-- src： 1 大厅， 2 地图游戏内
function MiniLobbyMiniBaseDrainageBtn_OnClick(src)
	src =  src or 1
	local bShow = GetActivityRoomMiniBaseDrainageBtSwitch((src == 2) and "game" or "lobby")
	if bShow and ns_version.mini_base_drainage_cfg.http then
		local jumpHttp = ns_version.mini_base_drainage_cfg.http or ""
		if src == 1 then
			jumpHttp = jumpHttp.."?from=home"
		elseif src == 2 then
			jumpHttp = jumpHttp.."?from=detail"
		end

		open_http_link(jumpHttp, "posting")

		if src == 2 then
			--1001普通房间游戏是作为客机进入游戏  1003打开地图游戏是作为主机进入游戏（单机和作为房主开联机房间）
			local sceneID = "";
			if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
				sceneID = "1003";
			else--客机
				sceneID = "1001";
			end		
			local cId = (sceneID == "1001") and "MINI_GAMEROOM_GAME_1" or "MINI_GAMEOPEN_GAME_1"
			standReportEvent(sceneID, cId, "SkinReward", "view")
		else
			MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TELESCOPICLIST_1", "SkinReward", "click")
		end
	end
end

--下载器点击入口
function MiniLobbyMiniBaseDownloadManagerBtn_OnClick()
	if ClientMgr:isAndroid() then
		MiniUIMiniBaseDownLoaderManager:showLobbyDownLoaderUI()
	end
end

--下载器状态刷新
function RefreshActivityLobbyMiniBaseDownLoaderBtn()
	if FguiMainIsVisible() then
		local node = GetInst("MiniUIManager"):GetUI("mainAutoGen")
		if node and node.ctrl then
			node.ctrl:RefreshActivityLobbyMiniBaseDownLoaderBtn()
		end
		return
	end
	if ClientMgr:isAndroid() then
		local miniBaseDownBtn = "MiniLobbyFrameCenterMiniBaseDownloadManagerBtn"
		local miniBaseDownBtn = getglobal(miniBaseDownBtn)
		if not miniBaseDownBtn then return end
		
		--0不存在任务 1任务正在下载 2任务暂停 3任务已完成 4任务死亡了，出异常了
		local status = MiniUIMiniBaseDownLoaderManager:getDownloadTaskStatus()
		if status > 0 then
			miniBaseDownBtn:Show()
		else
			miniBaseDownBtn:Hide()
		end
	end	
end

-- 刷新左侧icon位置
function MiniLobbyRefreshLeftIconPos()
	local leftIconBts = {
		getglobal("MiniLobbyFrameTopNoviceTaskBtn"),
		getglobal("MiniLobbyFrameTopNewNoviceTaskBtn"),
		getglobal("MiniLobbyFrameTopNewComeBackBtn"),
		getglobal("MiniLobbyFrameTopMiniBaseDrainageBtn"),
		getglobal("MiniLobbyFrameTopNoviceTaskOptimizeBtn"),
	}

	local posX = -10
	for index = 1, #leftIconBts do
		if leftIconBts[index] and leftIconBts[index]:IsShown() then
			leftIconBts[index]:SetPoint("right", "MiniLobbyFrameTopActivityRoomBox", "left", posX, -17)

			posX = posX - leftIconBts[index]:GetWidth() - 15
		end
	end
end


--聚合压力接口返回结果上报到大数据
function UpLoadPressureResult()
	local uploadData = nil;
	threadpool:work(function()
		uploadData = JavaMethodInvokerFactory:obtain()
			:setClassName("org/appplay/lib/GameBaseActivity")
			:setMethodName("getPressureData")
			:setSignature("()Ljava/lang/String;")
			:call()
			:getString();
			if uploadData then
				local https_header = "Content-Type: application/json;charset:utf-8"
				local function resultCallback(ret)
				end
				ns_http.func.rpc_do_http_post( upload_url, resultCallback, nil, uploadData, https_header )
			end	
					
	end)
	
end

function CheckWeekendGiftPopUp()
	if GetInst("WeekendPackagev2DataManager"):CanShow() then
		return
	end
	local code, info =  AccountManager:realname_get_age()
	if code == ErrorCode.OK and info.age < 18 then
	else
		return
	end

	WeekendGiftReqGiftStatus(function (retstr)
		--if getglobal("WeekendGiftBtn"):IsChecked() then
		ShowLoadLoopFrame(false)
		--end
		local ret = safe_string2table(retstr)
		if ret.ret == 0 then
			GetInst("WeekendGiftDataMgr"):OnDataCallback(ret.msg)
		else
			return
		end
		local time = AccountManager:getSvrTime()
		local w = tonumber(os.date("%w", time))
		local h = tonumber(os.date("%H", time))
		if (w == 5 or w == 6 or w == 0 ) and (h >= 20 and h < 22) then
			local popUpTime = tonumber(getkv("weekendgiftpopup") or "0")
			if IsSameDay(popUpTime, time) then
				return
			end
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/weekend_package", "miniui/miniworld/c_weekend_package"})
			GetInst("MiniUIManager"):OpenUI("WeekendGift","miniui/miniworld/weekend_package","WeekendGiftAutoGen", {from="popup"})
	
			setkv("weekendgiftpopup", time)
		end
	end)

end


function CheckNewNoviceTask()
	local kv = getkv("pop_skin_try_on") or 0
	if kv == 1 then
		return
	end
	threadpool:work(function ()
		while true do
			if not GetInst("UserTaskDataManager").data.NewNoviceTaskData.init or IsRoomFrameShown() then
				threadpool:wait(0.1)
				--print("CheckNewNoviceTask() wait(0.1)")
			else
				if NewbieGuideManager.needOpenRewardV13 then
					if NewbieGuideManager:GetGuideFinishFlag(NewbieGuideManager.GUIDE_FLAG_GO_ALONE) then
						NewbieGuideManager.needOpenRewardV13 = nil
						NewbieGuideManager:openGuideRewardV13()
						setkv("pop_skin_try_on", 1)
					end
					return
				elseif NewbieGuideManager:GetGuideFinishFlag(NewbieGuideManager.GUIDE_FLAG_GO_HALL) or not NewbieGuideManager:IsABSwitchV13() then
					if GetInst("mainDataMgr"):GetSwitch() then
						if GetInst("UserTaskDataManager").data.NewNoviceTaskData.notice_flag == 0 then
							GetInst("ActivityPopupManager"):InsertActivity(1, function()
								GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/newNoviceTask", "miniui/miniworld/c_newNoviceTask"})
								GetInst("MiniUIManager"):OpenUI("skin_try_on","miniui/miniworld/newNoviceTask","skin_try_onAutoGen")
								setkv("pop_skin_try_on", 1)
							end)
						end
						return
					else
						local guideStep = GetGuideStep();
						if guideStep == 7 then
							print("data.NewNoviceTaskData ", GetInst("UserTaskDataManager").data.NewNoviceTaskData)
							-- 是否还没开启新手任务
							if GetInst("UserTaskDataManager").data.NewNoviceTaskData.notice_flag == 0 then
								GetInst("ActivityPopupManager"):InsertActivity(1, function()
									GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/newNoviceTask", "miniui/miniworld/c_newNoviceTask"})
									GetInst("MiniUIManager"):OpenUI("skin_try_on","miniui/miniworld/newNoviceTask","skin_try_onAutoGen")
									setkv("pop_skin_try_on", 1)
								end)
							end
							return
						else
							print("CheckNewNoviceTask ", guideStep)
							return
						end
					end
				else
					return
				end
			end
		end
	end)
end

function CheckNoviceOptimizeTask()
	local kv = getkv("novice_optimize_guide") or 0
	if kv == 1 then
		return
	end
	threadpool:work(function ()
		while true do
			if not GetInst("NoviceTaskInterface"):GetTaskInfo() or IsRoomFrameShown() then
				threadpool:wait(0.1)
			else
				if GetInst("NoviceTaskInterface"):GetTaskInfo() then
					local guideStep = GetGuideStep();
					if guideStep == 7 then
						MiniLobbyNoviceTaskOptimizeShowGuide(true)
						setkv("novice_optimize_guide", 1)
						return
					else
						print("CheckNoviceOptimizeTask ", guideStep)
						return
					end
				else
					return
				end
			end
		end
	end)
end

-- 创角后空昵称保护
function MiniLobbyFrame_RoleNickNameProtect()
	local resultNickName = AccountManager:getNickName()

	if resultNickName == nil or string.len(resultNickName) == 0 then
		-- 发现当前昵称是空的
		print("albert comfirmSettings requestModifyRole fail nickName result ==", tostring(resultNickName));
		local name2 = getkv("protectNickName")
		if name2 then
			LoginManager.protectNickName = name2
		end
		if LoginManager.protectNickName and LoginManager.protectNickName ~= "" then
			--而且存了保护值
			-- 再尝试一次设置昵称
			print("albert MiniLobbyFrame_RoleNickNameProtect retry requestModifyRole", LoginManager.protectNickName);
			local result = AccountManager:requestModifyRole(LoginManager.protectNickName, 2, 0);
		end
	end
end

-- 如果有创角送的装扮，推迟到这里进行尝试穿戴
function MiniLobbyFrame_TryToDressUpCreateRoleGift()
	local needToDressUp = getkv("need_to_dressup_createrolegift");
	local giftid = getkv("need_to_dressup_createrolegift_id");

	local ret = nil;
	if needToDressUp ~= nil then
		if needToDressUp == 1 then
			--avatar装扮模式
			--如果有特殊情况导致总是穿不上，怀疑这里会有问题
			ret = AccountManager:avatar_seat_use(1);
			--存储个信息，判断是创建角色的定制皮肤
			local seatInfo = GetInst("ShopDataManager"):GetSkinSeatInfo(1)
			if seatInfo and seatInfo.def and seatInfo.def.ts then
				setkv( "seatInfo_ts_createrole" ..AccountManager:getUin(), seatInfo.def.ts)
			end
		elseif needToDressUp == 2 then
			--皮肤模式
			ret = AccountManager:useRoleSkinModel(giftid);
			--使用
		elseif needToDressUp == 3 then
			--没有申请赠送任何东西,也需要把皮肤替换为空avatar
			--经测试使用第一个没东西的装扮就可以
			ret = AccountManager:avatar_seat_use(1);
		end

		if ret == true or ret == 0 then
			setkv("need_to_dressup_createrolegift", nil);
			setkv("need_to_dressup_createrolegift_id", nil);
		else
			ShowGameTips(GetS(3865));
			-- ShowGameTips(GetS(50283));
		end
	end
end
