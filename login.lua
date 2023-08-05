IsFirstLogin = false;
isEnterGame = false;
isLoadFinish = false;
waitForTransferData = false;
isInMainGame = false;		--是否进入到过主游戏
LOGINBGTYPE = 1
returnLoginFrameRecord = {   		-- 退回到登录页记录
	backForce = false,				-- 是否强制退出到登录界面
	count = 0, 						-- 退回计数
	backLoginStaying = false,		-- 当前退回登录页面标识, 周期从退出 到  下一次进入
	callback = nil  				--当前退回回调记录
} --强制退出界面记录

local startLoadTime = 0;
function getStartLoadTime()
	return startLoadTime
end
function setStartLoadTime(time)
	startLoadTime = time
end
function LoginFrame_OnLoad()
	-- getglobal("myTest"):Show();
	--标题名
		--游戏启动上报
	local startTime = CommonUtil:getSystemTick()
	setStartLoadTime(startTime);
	standReportEvent("9501","APP_STARTUP","AppStartupPage", "app_active", {
		standby1 = startTime / 1000,
		standby2 = GetAndroidRandomSessionID()
	})
	getglobal("LoginScreenFrameInputTitleFrameName"):SetText(GetS(4882));
	getglobal("LoginScreenFrameInputTitleFrameBkgClose"):Hide();

	InitServerUrls();

	this:RegisterEvent("GE_ENTER_GAME");
	this:RegisterEvent("GE_ENTER_GAME_NEW");
	this:RegisterEvent("GE_LOAD_PROGRESS");
	this:RegisterEvent("GE_HTTP_DOWNLOAD_PROGRESS");
	this:RegisterEvent("GE_HTTP_UPLOADFILE_PROGRESS");
	this:RegisterEvent("GE_PLAYERCENTER_ARCHIEVEMENT_REPORT");	--个人中心成就系统上报
	this:RegisterEvent("GIE_LAST_PING");
	this:setUpdateTime(0.05);

	if LOGINBGTYPE == 1 then
		--getglobal("LoginScreenFrameBkgFX"):addBackgroundEffect("particles/1102.ent", 0, -450, 700);
		getglobal("LoginScreenFrameBkgAnim"):addBackgroundEffect("particles/ui_jiazai.ent",0,100,-250)
	elseif LOGINBGTYPE == 2 then
		getglobal("LoginScreenFrameBkgFX"):setBackground("ui/models/login.omod");
		getglobal("LoginScreenFrameBkgAnim"):addBackgroundEffect("particles/ui_jiazai.ent",0,100,-300)
	end

	if gIsSingleGame then
		getglobal("LoginScreenFrame"):Show();
		getglobal("LoginScreenFrameInputApllyBtn"):Hide();
	else
		--拉取一下scheme信息，是否由一起玩启动的游戏
		-- t_autojump_service.checkScheme();

		if t_autojump_service.autotype ~= 'auz' then
			getglobal("LoginScreenFrame"):Show();

			--下载配置文件  (--海外多语言公告 需要重新拉取)
			if  ClientMgr:isPC() or isAbroadEvn() then
				local downloadXmlRoot = "data/http/config/version.xml";
				local url = GetConfigXmlUrl();
				ns_http.func.downloadXmlConfig(url, downloadXmlRoot, DownLoadXmlConfigResult_https);
			end

			Log("guan LoginFrame_OnLoad");
			WWW_get_cf_info_first();

			if  true then
			    getglobal("LoginScreenFrameInputApllyBtn"):Hide();
				-- getglobal("LoginScreenFrameInputLoginBtn"):SetPoint("topleft","LoginScreenFrameInput","topleft", 180, 188);
			end
		end
		--开屏广告下载操作
		CheckStartAdv()
	end
	--从这里开始初始化XML文件，并加载游戏内所有的LUA文件
	-- GetInst("UIManager"):InitXmlPathList() --延迟到loading过程中执行，不卡启动 code_by:huangfubin
	-- svn认证相关的界面加载已经独立出来
end



--[pc版本] 和 [海外版本] 需要从lua层拉取 version_XXX.xml
--国内android和ios从外部JAVA和OC启动代码拉取 version_XXX.xml
function GetConfigXmlUrl( ishttps )

	local a_ = ClientMgr:getApiId();
	if  isAbroadEvn() then
		--海外
		local verName = "";
		if     a_ >= 400 and a_ < 500 then   --海外PC  410 402
			verName = "version_pc_" .. a_ .. ".xml";
		elseif a_ == 345 or a_ == 346 then
			verName = "version_10_ios.xml"   --海外ios
		elseif a_ == 999 then
			verName = "version_999.xml"      --开发测试
		else
			--301 302 303  version_10.xml
			verName = "version_" .. get_game_env() .. ".xml"   --海外先遣服=version_12.xml  正式=version_10.xml
		end
		Log( verName )

		if  ishttps then		
			--return "https://en.mini1.cn/version/" .. verName;
			--return "https://cdn-mnweb.miniworldgame.com/version/" .. verName;
			return ClientUrl:GetUrlString("HttpsVersion", verName)
		else
			--return  "http://en.mini1.cn/version/" .. verName;
			--return "http://cdn-mnweb.miniworldgame.com/version/" .. verName;
			return ClientUrl:GetUrlString("HttpVersion", verName)
		end

	else
		--国内
		local verName = "";
		if  a_ == 110 or a_ == 112 or a_ == 113 or a_ == 115 then	 --pc官版
			verName = "version_pc.xml";
		elseif a_ == 199 then	                     --pc大厅
			verName = "version_pc_beta.xml";
		elseif ClientMgr:isQQGamePcApi(a_) then	     --pcQQ大厅版
			verName = "version_pc_qq.xml";
		elseif a_ == 998 then	--pc版署版
			verName = "version_pc_banshu.xml";
		elseif a_ == 121 then	--4399版
			verName = "version_pc_4399.xml";
		elseif a_ == 122 then	--7k7k版
			verName = "version_pc_7k7k.xml";
		elseif a_ == 109 then
			verName = "version_pc_qqzone.xml";
		elseif a_ == 123 then
			verName = "version_pc_2144.xml";
		elseif a_ == 124 then
			verName = "version_pc_feihuo.xml";
		elseif a_ == 125 then
			verName = "version_pc_xunlei.xml";
		elseif a_ == 126 then
			verName = "version_pc_360.xml";
		elseif a_ == 127 then
			verName = "version_pc_aipai.xml";
		elseif a_ == 129 then	--趣核版署版
			verName ="version_pc_funnycore.xml";
		else
			verName = "version_999.xml";   --pc内部测试版 999
		end

		Log( verName )

		if  ishttps then
			--return "https://static-www.mini1.cn/version/pc/"..verName;
			return ClientUrl:GetUrlString("HttpsVersion", verName)
		else
			--return  "http://static-www.mini1.cn/version/pc/"..verName;
			return ClientUrl:GetUrlString("HttpVersion", verName)
		end
	end
end


--首次http 失败改为https
function DownLoadXmlConfigResult_https(configText)
	if configText ~= nil and configText ~= "" then
		ClientMgr:onLoadGameVersionXmlAfterDownload(configText);
		Log( "call DownLoadXmlConfigResult_https ok" )
	else
		Log( "call DownLoadXmlConfigResult_https fail" )
		--重新使用https代替http
		local downloadXmlRoot = "data/http/config/version.xml";
		local url = GetConfigXmlUrl(true);
		ns_http.func.downloadXmlConfig(url, downloadXmlRoot, DownLoadXmlConfigResult_http);
	end
end


--二次https
function DownLoadXmlConfigResult_http(configText)
	if configText ~= nil and configText ~= "" then
		ClientMgr:onLoadGameVersionXmlAfterDownload(configText);
		Log( "call DownLoadXmlConfigResult_http ok" )
	else
		Log( "call DownLoadXmlConfigResult_http fail" )
	end
end



Account_Errors = {
	146,
	3115,
	525,
	526,
	527,
	3116,
};

--ios分包审核用
function CreateRoleForIosReview()
	Log("CreateRoleForIosReview");
	local nameText = DefMgr:getRandomName(0);

	if AccountManager:requestModifyRole(nameText, 1, 0, false) then
		if ClientMgr:getApiId() == 53 then
			local nickName = AccountManager:getNickName();
			local worldName = nickName..GetS(59);
			local worldType = 0;
			if AccountManager:requestCreateWorld(worldType, worldName, 1, "", AccountManager:getRoleModel()) then
				ShowLoadingFrame();
			else
				ShowLobby();
			end
		else
			ShowLobby();
		end
	end
end

function LoginFrame_OnEvent()
	local ge = GameEventQue:getCurEvent();
	if arg1 == "GE_ENTER_GAME" then
		if ge.body.entergame.result == 0 then
			isInMainGame = true;
			getglobal("LoginScreenFrame"):Hide();
			IsFirstLogin = ge.body.entergame.firsttime;
			local uin = AccountManager:getUin();
			local nickName = AccountManager:getNickName();
			ClientMgr:setAccount(uin, nickName);

			if not AccountManager:getNoviceGuideState("guideagreement") then
				AccountManager:setNoviceGuideState("guideagreement", true);
			end
			if IsFirstLogin then
				if IsInIosSpecialReview() or ClientMgr:isEducationLiteGame() then --苹果分包审核
					CreateRoleForIosReview();
				else
					getglobal("SelectRoleFrame"):Show();
					StatisticsTools:gameEvent("EnterSelectRole");
					--服务器统计进入选人界面
					local k = "OpenSelectRoleFrame";
					local v = "1";
					local http_req_url = g_http_root.."miniw/php_cmd?act=report&"..http_getS1().."&k="..k.."&v="..v;
					ns_http.func.rpc(http_req_url, nil, nil, nil, true);  --发送http请求

					if  ClientMgr:getNetworkState() == 0 then
						StatisticsTools:gameEvent("NoNetworkEnterSelectRole");
					end
				end
			else
				BuddyManager:getOfflineChat();
				-- getglobal("MiniLobbyFrame"):Show()
				ShowMiniLobby() --mark by hfb for new minilobby
				DeepLinkQueue:dequeue();
			end			
			if ClientMgr:isEducationLiteGame() then
				HideLobby();
			end
		else
			isEnterGame = false;

			local i = ge.body.entergame.result;
			if i < 0 then i = 0 end;
			ShowGameTips(GetS(Account_Errors[i+1]), 3)
		end
	
	
	elseif arg1 == "GE_ENTER_GAME_NEW" then
		returnLoginFrameRecord.backLoginStaying = false
		if ModMgr then ModMgr:reloadCustomMods(); end
		PlayerArchiveInit();
		SetPlayerPurchaseFlag(false);
		OpenNewBPPersistentTask()
		--这里打开一次存档mvc界面，这样在登录时才能接受游戏消息.
		-- GetInst("UIManager"):Open("lobbyMapArchiveList", {UpdateView=false});
		-- GetInst("UIManager"):Close("lobbyMapArchiveList");
		
		-- 开始加载广告配置 codeby:fym
		GetInst("AdService"):InitAllAdConfig()
		
		-- 加载开发者广告作弊惩罚配置  codeby:fym
		GetInst("AdService"):InitAntiDeveloperAdConfig()

		-- 加载皮肤熟练度及皮肤洗点属性相关的数据
		WeaponSkin_HelperModule:HandleLoginEvent();

		-- 登陆成功后设置uin及成年标记到原生层
		if MINIW__OnEnterGameCallback then
			local isAdult = AccountManager:check_adult();
			local currUin = LuaInterface:getUin() or 1;
			MINIW__OnEnterGameCallback(currUin, isAdult);
		end
		if t_autojump_service then
			t_autojump_service.loginshow = false
			t_autojump_service.pushed = false
		end
	elseif arg1 == "GE_LOAD_PROGRESS" then
		if this:IsShown() then
			local RealLoadingProgress = ge.body.loadprogress.progress;
			-- local print = Android:Localize(Android.SITUATION.LOADING);
			-- print("LoginFrame_OnEvent(): RealLoadingProgress = ", RealLoadingProgress);
			local value = RealLoadingProgress/100;
			
			if  value > 1 then
				value = 1;
			end

			if  value < 0 then
				-- 服务器文件热更
                --{{{
				hotfix_and_cfg_download_loading(true)
				local timePass = CommonUtil:getSystemTick()
				local loadDuration = timePass - getStartLoadTime();
				

		
				pcall(standReportEvent,"9501","START_PAGE_LOADING","StartupPageLoadedSuccessfully","page_load_success",{standby1= loadDuration / 1000, standby2 = GetAndroidRandomSessionID()});

				return;
                --}}}

			else
				-- 本地资源加载
				--更新进度条
				change_progress_bar( value );
				local progress = math.floor(value*100);
				getglobal("LoginScreenFrameProgressText"):SetText(GetS(847)..progress.." %");
			end
		
		end
	elseif arg1 == "GE_HTTP_DOWNLOAD_PROGRESS" then
		ns_http.func.handleHttpDownloadprogress();
	elseif arg1 == "GE_HTTP_UPLOADFILE_PROGRESS"  then
		ns_http.func.handleHttpUploadFileProgress();
	elseif arg1 == "GE_PLAYERCENTER_ARCHIEVEMENT_REPORT" then
		--个人中心成就系统上报, 这是在c++中触发的, 通过事件传递到lua中处理.
		print("archievement_event:");
		local nType = ge.body.playercenterArchievementInfo.nType;
		local nData = ge.body.playercenterArchievementInfo.nData;
		local uin 	= ge.body.playercenterArchievementInfo.uin;
		local param = {};

		print(nType, nData, uin);

		if nType == 1001 then
			--击败boss
			param.add = 1;
			param.pos = nData;

			if uin and uin ~= AccountManager:getUin() then
				--如果是自己, 则不需要, 只需客机uin
				param.uin = uin;
			end
		elseif nType == 1002 then
			--获得星球宝藏(宝藏的位置其实是不需要的, 为了和箱子保持一致才加上, 起唯一标识的作用)
			--传uin过来, 表示获取的玩家, 解决联机时客机上报不了的问题.
			param.add = 1;
			param.pos = nData;
			
			if uin and uin ~= AccountManager:getUin() then
				--如果是自己, 则不需要, 只需客机uin
				param.uin = uin;
			end
		elseif nType == 1003 then
			--生存天数
			param.count = nData;
		elseif nType == 1004 then
			--极限模式击杀boss
			param.add = 1;
			param.pos = nData;
		end

		ArchievementGetInstance().func:Report2Server(nType, param);
	elseif arg1 == "GIE_LAST_PING" then
		GetInst("ReportGameDataManager"):SetLastPing(ge.body.lastPing.lastPing) 
	else
		Log("ERROR: unknown event:" .. (arg1 or "nil") );
		local loadDuration = CommonUtil:getSystemTick() - getStartLoadTime();
		standReportEvent("9501","START_PAGE_LOADING","StartupPageLoadFailed","page_load_failed",{standby1= loadDuration / 1000 });

	end
end


--修改进度条
function change_progress_bar( value )
	local offsetX = value * 500;
	--getglobal("AnimationBarSmoke"):SetPoint("bottomright","AnimationBar","bottomleft", offsetX, 0);
	--getglobal("AnimationBarZombie"):SetPoint("bottomleft","AnimationBarSmoke","bottomright", -40, -12);
	--getglobal("AnimationBarChicken"):SetPoint("bottomleft","AnimationBarZombie","bottomright", 0, 0);

	getglobal("LoginScreenFrameProgressBar"):SetValue(value);
	getglobal("LoginScreenFrameProgressBarCursorTex"):SetPoint("left", "LoginScreenFrameProgressBar", "left", 512*value-2, 0);
end


-- 热更、配置文件逻辑处理   bFirstIn:首次进入登录页面
function hotfix_and_cfg_download_loading( bFirstIn )
	threadpool:work(function ()
		--埋点，是否需要热更  设备码,用户类型,是否热更,语言
		local config = loadwwwcache('config')
		local isUpdate = 2
		local ret1_, ret2_, ret3_ = g_check_init_finish()
		if config and config.hotfix then
			if  ret3_ and ret3_ > 1 then
				isUpdate = 1
			end
		end
		-- statisticsGameEventNew(980,ClientMgr:getDeviceID(),ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),isUpdate,tostring(get_game_lang()))
		StatisticsTools:send(true, true)

		--检测热更新是否完成
		-- 增加一项：下载登陆配置
		--LoginManager:StartDownloadCfg()
		local hret2_, hret3_= 0, 0
		local cc_ = 0   --一个文件下载等待了多少秒
		--for i=1, 60 do
		while true do
			ret1_, ret2_, ret3_ = g_check_init_finish()
			local ret1_cfg, ret2_cfg, ret3_cfg = LoginManager:GetCfgDownloadStatus()

			ret1_ = ret1_ and ret1_cfg
			ret2_ = ret2_ + ret2_cfg
			ret3_ = ret3_ + ret3_cfg

			print( "g_check_init_finish=" .. cc_ .. " : " .. (ret1_ and 1 or 0) .. " / " .. (ret2_ or 'n') .. " / " .. (ret3_ or 'n') )						
			local end_ = "..."
			if cc_%3==1 then
				end_ = ".  "
			elseif cc_%3==2 then
				end_ = ".. "
			end

			--热更新进度条
			if  ret3_ and ret3_ > 1 then
				change_progress_bar( ret2_ / ret3_ )
				getglobal("LoginScreenFrameProgressText"):SetText(GetS(847) .. " (" .. ret2_ .. "/" .. ret3_ .. ")" .. end_ );
			end

			if  ret1_ then
				print( " g_check_init_finish return true" );
				if LoginManager:GetSwitchCfg() and LoginManager:GetSwitchCfg():IsPcGoChannelBind() then
					if JuHeLoginEventCallback then
						JuHeLoginEventCallback(1)
					end
				end
				
				-- 登陆首页相关配置
				LoginManager:ParseSwitch(ns_version)
				break;
			else
				cc_ = cc_ + 1
				--if  cc_ >= 10 then
					--break;   --单步等待时间过10秒
				--end
				threadpool:wait(1);
				if  ret2_ == hret2_ and ret3_ == hret3_ then
					--未改变
				else
					cc_ = 0 --有变化 重新计数
					hret2_ = ret2_
					hret3_ = ret3_
				end
			end
		end

		-- -- 新版登陆获取开关
		-- if LoginManager then
		-- 	LoginManager:CallJavaSwitch()
		-- end

		isLoadFinish = true;
		if isUpdate == 1 then
			--埋点，热更完成  设备码,用户类型,语言
			-- statisticsGameEventNew(981,ClientMgr:getDeviceID(),ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
			StatisticsTools:send(true, true)
		end

		-- 进度条完成
		if LOGINBGTYPE ~= 3 then
			getglobal("LoginScreenFrameProgress"):Hide();
		end

		-- -- 开始分支
		-- if IsEnableNewLogin and IsEnableNewLogin() then
		-- 	-- LoginManager:NotifyCustomEvent(LoginManager.EVENT_HOMEPAGE_DLG_SHOW)
		-- else
		-- 	-- 底部协议部分
		-- 	if not AccountManager:getNoviceGuideState("guideagreement") or ClientMgr:isPC() or ClientMgr:isMobile() then
		-- 		getglobal("LoginScreenFrameAgreement"):Show();
		-- 	end

		-- 	if  isAbroadEvn() then
		-- 		getglobal("LoginScreenFrameAgreement"):Show();
		-- 	end

		-- 	if not ClientMgr:isPC() then
		-- 		getglobal("LoginScreenFrameAgreement"):Show();
		-- 		if not AccountManager:getNoviceGuideState("guideagreement") then
		-- 			getglobal("LoginScreenFrameAgreementTickIcon"):Hide();
		-- 		else
		-- 			getglobal("LoginScreenFrameAgreementTickIcon"):Show();
		-- 		end
		-- 	else
		-- 		getglobal("LoginScreenFrameAgreement"):Hide();
		-- 	end
		-- end
		--产品需求 都不显示了
		getglobal("LoginScreenFrameAgreement"):Hide()

		-- 渠道自动登陆部分
		if IsBetaEnv() then
			getglobal("LoginScreenFrameInput"):Show();
		else
			--手Q授权登录按钮
			ShouQLoginUpdateView();

			if IsEnableNewAccountSystem() then
				--显示新的登录按钮
				LoginScreenFrameShowLoginBtn()
			else
				getglobal("LoginScreenFrameEnterGame"):Show();
			end
			threadpool:wait(0)

			-- 首次启动
			if bFirstIn then
				if IsEnableNewLogin and IsEnableNewLogin() then
					LoginManager:NotifyCustomEvent(LoginManager.EVENT_AUTO_LOGIN)
				else
					--抖音云游戏登录逻辑
					DouyinCloudLoginUpdateView()
	
					--快手渠道登录
					local apiId = ClientMgr:getApiId()
					if apiId == 57 or apiId == 37 then
						ShowNoTransparentLoadLoop()
						getglobal("LoginScreenFrameAgreement"):Hide();
						SdkManager:sdkLogin()
					end
				end

				-- if ClientMgr:isMobile() then
				t_autojump_service.checkScheme();
				-- end
				local autotype = t_autojump_service.autotype;
				print("LoginFrame_OnEvent(): t_autojump_service.play_together = " + t_autojump_service.play_together);
				print("LoginFrame_OnEvent(): t_autojump_service.play_together.anchorUin = " + t_autojump_service.play_together.anchorUin);
				-- 联机房间启动游戏不走GameNewIntent的逻辑
				if t_autojump_service.play_together.anchorUin > 0 then
					if isShouQPlatform() then
						if isShouQAuthorize() or isIOSShouQ() then
							ShowGameTips(GetS(1103), 3);
							g_uiroot:get('LoginScreenFrame'):OnClick();
						else
							ShowGameTips(GetS(35209), 3);
						end
					else
						ShowGameTips(GetS(1103), 3);
						g_uiroot:get('LoginScreenFrame'):OnClick();
					end
					-- 外部拉起迷你世界直接进入游戏大厅
					-- "m" : 迷你工坊的地图
					-- "_m" : 游戏大厅
				else
					GameNewIntent(t_autojump_service.scheme_json);
					-- threadpool:work(function()
					-- 	GameNewIntent(t_autojump_service.scheme_json);
					-- end);
				end
			end
		end

		--健康提示滚动
		--[[
		local rich = getglobal("LoginScreenFrameTips2");
		local bkg = getglobal("LoginScreenFrameTips2Bkg")
		local hour = tonumber( os.date("%H",AccountManager:getSvrTime()) );
		print("kekeke hour:", hour);
		if 0 <= hour and hour < 7 then
			bkg:Show();
			rich:Show();
			rich:resizeRect( rich:GetTextExtentWidth( GetS(1332) ), 26 );
			rich:SetText(GetS(1332), 242, 225, 199);
			rich:ScrollFirst();	
			rich:SetDispPosX( -873 );
			rich:SetWidth( 846 );
		else
			bkg:Hide();
			rich:Hide();
		end
		]]
		return;
	end )
end

local WaitTimeStandAlone = 10;
-- 倒计时？秒数后弹出单机模式选择
function StandAloneFrame_OnLoad()
	-- this:setUpdateTime(1)
end

function StandAloneFrame_OnShow()
	-- if ns_data then
	-- 	WaitTimeStandAlone = ns_data.alone_timeout or 10
	-- else
	-- 	WaitTimeStandAlone = 10
	-- end
end

function StandAloneFrame_OnHide()
	-- getglobal("MessageBoxFrameEx"):Hide()
end

function StandAloneFrame_OnUpdate()
	-- WaitTimeStandAlone = WaitTimeStandAlone - arg1
	-- if isInMainGame or getglobal("MiniLobbyFrame"):IsShown() then
	-- 	getglobal("MessageBoxFrameEx"):Hide()
	-- 	if this and getglobal("StandAloneFrame"):IsShown() then
	-- 		this:Hide()
	-- 	end
	-- 	return
	-- end
	-- if WaitTimeStandAlone <= 0 then
	-- 	HideNoTransparentLoadLoop()
	-- 	if ns_data then ns_data.login_alone_tips_show = true end
	-- 	if getglobal("LoginSafetyCheckFrame"):IsShown() or getglobal("OursValidateFrame"):IsShown() then
	-- 		this:Hide()
	-- 		return
	-- 	end
	-- 	local strType = MessageBoxEx(3, GetS(25834), "");
	-- 	if strType ~= nil then
	-- 		isEnterGame = false
	-- 		if strType == "ok" then
	-- 			ChangeStandAloneMode(true)
	-- 			if ns_data then ns_data.login_alone_tips_show = false end
	-- 			WaitTimeStandAlone = 10
	-- 			g_uiroot:get('LoginScreenFrame'):OnClick();
	-- 			if this and getglobal("StandAloneFrame"):IsShown() then
	-- 				this:Hide()
	-- 			end
	-- 		elseif strType == "cancel" then
	-- 			if ns_data then ns_data.login_alone_tips_show = false end
	-- 			WaitTimeStandAlone = 10
	-- 			g_uiroot:get('LoginScreenFrame'):OnClick();
	-- 			if this and getglobal("StandAloneFrame"):IsShown() then
	-- 				this:Hide()
	-- 			end
	-- 		elseif strType == "close" then
	-- 			-- GameExit()
	-- 			GameEndBtn_OnClick()
	-- 		end
	-- 	end
	-- else
	-- 	getglobal("MessageBoxFrameEx"):Hide()
	-- end
end

local oldMusicOpen = 0;
function LoginFrame_OnShow()
	gOldMusicOpen = ClientMgr:getGameData("musicopen")
	if gOldMusicOpen == 1 then
		ClientMgr:setGameData("musicopen", 0);
		ClientMgr:appalyGameSetData()
	end
	
	--[[
	print("LoginFrame_OnShow", VideoPlayerInterface);
	if not getglobal("LoginScreenFrame"):IsReshow() and VideoPlayerInterface and VideoPlayerInterface.showFullScreenVideo then
		if VideoPlayerInterface:showFullScreenVideo("video/login.mp4") then
			getglobal("LoginScreenFrameBkg"):Hide();
			getglobal("LoginScreenFrameBkgAnim"):Hide();
			oldMusicOpen = ClientMgr:getGameData("musicopen");
			if ClientMgr:getGameData("musicopen") == 1 then
				ClientMgr:setGameData("musicopen", 0);
				ClientMgr:appalyGameSetData();
			end
		end
	end
	]]

	--MiniBase 隐藏登录界面
	if MiniBase then 
		UIFrameMgr:hideAllFrame()
		return
	end

	--新式埋点上报
	standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "-", "view")
	standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "Announcement", "view")
	standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "LogIn", "view")

	if t_autojump_service then
		t_autojump_service.loginshow = true
		if t_autojump_service.loginPushReport then
			t_autojump_service.loginPushReport()
		end
	end
	local apiId = ClientMgr:getApiId()
	Log( 'LoginFrame apiId=' .. apiId );
	if IsBetaEnv() then
		getglobal("BetaFrame"):Show();
	else
		getglobal("BetaFrame"):Hide();
	end
	getglobal("LoginScreenFrameEnterGame"):SetSize(329, 59);
	isEnterGame = false;
	isLoadFinish = false;
	ClientMgr:playMusic("sounds/music/theme1.ogg");

	local desc_ = GetS(528).." "..ClientMgr:clientVersionToStr(ClientMgr:clientVersion()) .. "." .. get_game_env()  --.. "." .. apiId;
	desc_= desc_.. getPatchVerStr() --资源热更patch号
	if  ns_hotfix.isPatchEnable() then
		desc_ = desc_ .. "h"  --使用了热更新
	end
	getglobal("LoginScreenFrameVersion"):SetText( desc_ );

	--if  apiId == 999 then
	--	getglobal( 'LoginScreenFrameLangBtn' ):Show();
	--	getglobal( 'LoginScreenFrameEnvBtn' ):Show();
	--end

	getglobal("LoginScreenFrameTipsBkg"):Hide();
	getglobal("LoginScreenFrameTips"):Hide();

	showDownloadQRCode()

	local smoke = getglobal("AnimationBarSmoke")
	local zombie = getglobal("AnimationBarZombie")
	local chicken = getglobal("AnimationBarChicken")

	smoke:SetUVAnimation(120, true);
	zombie:SetUVAnimation(100, true);
	chicken:SetUVAnimation(120, true);
	smoke:Show();
	zombie:Show();
	chicken:Show();

	-- if apiId == 5 then	--联通要弹版号信息 --渠道5用作鸿蒙平台 注释掉之前不用的提示页面
	-- 	getglobal("VersionNumberInfoFrame"):Show();
	-- end

	isEducationalVersion = ClientMgr:isEducationLiteGame();
	--教育版不弹提示
	if not IsOverseasVer() and not ClientMgr:isEducationLiteGame() then
		local hour = tonumber( os.date("%H",AccountManager:getSvrTime()) );
		if 0 <= hour and hour < 7 then
			MessageBox(4, GetS(1332)); 
		end
	end

	local game_env = get_game_env()
	if game_env  ==  0 then
		getglobal("LoginScreenFrameAgeTag"):Show()
	else
		getglobal("LoginScreenFrameAgeTag"):Hide()
	end

	--展示渠道logo
	ShowChannelLogo()

	if IsIosPlatform() then
		local screenFrameDesc = getglobal("LoginScreenFrameDesc")
		screenFrameDesc:SetAnchorOffset(screenFrameDesc:GetAnchorOffsetX(), -45)
	end
	
	if IsEnableNewLogin and IsEnableNewLogin() then
		-- 新版本处理具体按钮登陆按钮逻辑
	else
		local btn1 = getglobal("LoginScreenFrameSwitchUserBtn")
		local btn2 = getglobal("LoginScreenFrameNoticeBtn")
		local btn3 = getglobal("LoginScreenFrameLangBtn")
		if isEducationalVersion then
			if btn1 then
				btn1:Hide()
			end
			if btn2 then
				btn2:Hide()
			end
			if btn3 then
				btn3:Hide()
			end
		end
	end

	local edit=getglobal("LoginScreenFrameInputPasswordEdit")
	if ClientMgr:isPC() then
		edit:ChangeCoderEditMethod()
	end
end

function LoginScreenFrameSdkLoginBtnShow()
	local appId = ClientMgr:getApiId()
	local isSdkLoginNeed = true
	if appId == 15  then	--360显示帐号登录
		getglobal("LoginScreenFrameSdkLoginBtnName"):SetText("360登录")
	elseif appId == 313 then	--海外OPPO显示帐号登录
		getglobal("LoginScreenFrameSdkLoginBtnName"):SetText(GetS(1111))
	elseif appId == 13 then --国内OPPO显示账号登录
		getglobal("LoginScreenFrameSdkLoginBtnName"):SetText("渠道账号" .. GetS(1111))
	else
		isSdkLoginNeed = false
		getglobal("LoginScreenFrameSdkLoginBtn"):Hide()
	end

	if isSdkLoginNeed then
		if LoginManager:GetSwitchCfg():IsForceAppid() 
			or LoginManager:GetSwitchCfg().IsEnableRegistChannelForceLogin and LoginManager:GetSwitchCfg():IsEnableRegistChannelForceLogin() then
			getglobal("LoginScreenFrameSdkLoginBtn"):Hide()
		else
			getglobal("LoginScreenFrameSdkLoginBtn"):Show()
		end
	end
end


function LoginFrame_OnHide()
	--[[
	if not getglobal("LoginScreenFrame"):IsRehide() and VideoPlayerInterface and VideoPlayerInterface.closeFullScreenVideo then
		VideoPlayerInterface:closeFullScreenVideo();
		if oldMusicOpen == 1 then
			ClientMgr:setGameData("musicopen", 1);
			ClientMgr:appalyGameSetData();
		end
	end
	]]

	if IsEnableNewLogin and IsEnableNewLogin()then
		LoginManager:HideHomePage()
	end
end

-- 已经交给luascript/login.lua， 这个函数无效
function LoginFrame_OnClick()
	Log( "call LoginFrame_OnClick" )
    if isShouQPlatform() then
		if not isShouQAuthorize() then
			Log( "return isShouQAuthorize" )
			return;
		elseif ClientMgr:getNetworkState() == 0 and not LocalHasAccount() then
			Log( "return getNetworkState == 0" )
			return;
		end
	end
	
	if IsEnableNewAccountSystem() and HasNotCurrentAndHasHistory then
		GetInst("UIManager"):Open("SwitchAccountUI")
		return
	end

	if  isEnterGame then
		Log( "return isEnterGame" )
		return;
	end
	if  getglobal("LoginScreenFrameProgress"):IsShown() or not isLoadFinish then
		Log( "return isLoadFinish" )
		return;
	end
	if  ClientMgr:getDataTransferState()~=0 then
		waitForTransferData = true;
		Log( "return getDataTransferState" )
		return;
	end

	if IsEnableNewLogin and IsEnableNewLogin() and LoginManager:InterruptPrivatePolicyCheck()  then
		return
	else
		if IsOverseasVer() or ClientMgr:isPC() then
			--开了隐私条款的不用勾选
		else
			local CltVersion = LuaInterface and LuaInterface.getCltVersion and LuaInterface:getCltVersion() or 0
			if CltVersion and CltVersion >= 28 * 256 and getglobal("LoginScreenFrameAgreementContent"):IsShown() 
			   and not getglobal("LoginScreenFrameAgreementTickIcon"):IsShown() then
				ShowGameTips(GetS(3837), 3);
				if AnimMgr.stopByName then AnimMgr:stopByName("LoginScreenFrameAgreementTick"); end
				if AnimMgr.playBlink then AnimMgr:playBlink("LoginScreenFrameAgreementTick", 1, 0.5); end
			   return;
			end
		end
	end

	isEnterGame = true;
	EnterGame();  -- 已经交给luascript/login.lua， 这个函数无效
end


--适龄提示
function LoginScreenFrameAgeTag_OnClick()
	LoginManager:OpenUI("main_popuptips_12", "MiniUITipsMain", {closeCan = true,sortingOrder = 200})
end

function LoginBtn_OnClick()
	local name = getglobal("LoginScreenFrameInputUserNameEdit"):GetText();
	if ( name == "" ) then
	else
		name = getLongUin(name);
		ClientCurGame:requestLogin(name, getglobal("LoginScreenFrameInputPasswordEdit"):GetPassWord());
	end
end

function WebSocketCallback(s, packdata, isbin)
	local mp = gPackages['MessagePack'];

	local d =  mp.unpack(packdata)
	Log("unpack = ("..d[1]..", "..d[2]..", "..d[3]..")")
end

function TestMsgPacker()
	local s = CSMgr:openLuaWebSocket("ws://103.243.25.218:9010/ajaxchattest")
	s:setLuaCallback("WebSocketCallback")

	local mydata = {1,  "dddd",  4.2}
	local mp = gPackages['MessagePack'];
	--local mp = require 'res.luascript.MessagePack'
	mp.set_number 'float'

	local  packdata = mp.pack(mydata)
	s:send(packdata, string.len(packdata))

	while(true)
	do
		s:tick()
	end

	CSMgr:closeLuaWebSocket(s)
end

-- 已经交给luascript/login.lua， 这个函数无效
function EnterGame()
	--测试websocket和messagepack消息打包解包
	--TestMsgPacker()
	-- 网络不好，提示网络问题
	if CheckNetworkErrTipsShow and CheckNetworkErrTipsShow() then
		return
	end

	if CallJavaChannelLoginStatus then
        if not CallJavaChannelLoginStatus() then
            return
        end
    end

	if ClientMgr:getApiId() == 47 then
		if not AccountManager:requestEnterGameByOpenstring(SdkManager:getTpLoginAccount(), SdkManager:getTpLoginAccountParams()) then
			MessageBox(4, StringDefCsv:get(158));
			getglobal("MessageBoxFrame"):SetClientString( "存储空间不够" );
		end
		--[[if not AccountManager:requestEnterGameByOpenstring("F417A5C3EE2F8E6BB944373BFFE373E3", "pf=qq_m_qq-10021755-android-10021755-qq-1105856612-F417A5C3EE2F8E6BB944373BFFE373E3-android&openkey=AC316715CF933FC53837FDDC9311E92C&openid=F417A5C3EE2F8E6BB944373BFFE373E3") then
			MessageBox(4, StringDefCsv:get(158));
			getglobal("MessageBoxFrame"):SetClientString( "存储空间不够" );
		end]]
	elseif ClientMgr:isQQGamePcApi(ClientMgr:getApiId()) or ClientMgr:getApiId() == 121 or ClientMgr:getApiId() == 122 or ClientMgr:getApiId() == 124 or ClientMgr:getApiId() == 125 or ClientMgr:getApiId() == 126 then
		if not AccountManager:requestEnterGameByOpenstring(SdkManager:getTpLoginAccount(), SdkManager:getTpLoginAccountParams()) then
			AccountManager:requestEnterGameByOpenstring(SdkManager:getTpLoginAccount(), SdkManager:getTpLoginAccountParams());
		end
	else
		if not AccountManager:requestEnterGame() then  -- 不会进入，无效
			MessageBox(4, StringDefCsv:get(158));
			getglobal("MessageBoxFrame"):SetClientString( "存储空间不够" );
		end
	end
end

local alphaIncSpeed = 0.25/10;
local changeAlpha = alphaIncSpeed;
local curAlpha = 0
local angleSpeed = 10;
local angle = 0;
local EnterGameScale = 1.0
local ScaleSpeed = 0.005;
local MOVE_WIDTH_TICK = 2;
function LoginFrame_OnUpdate()
	if getglobal("LoginScreenFrameEnterGame"):IsShown() then
		EnterGameScale = EnterGameScale + ScaleSpeed;
		if EnterGameScale > 1 then
			EnterGameScale = 1;
			ScaleSpeed = -0.01
		elseif EnterGameScale < 0.9 then
			EnterGameScale = 0.9;
			ScaleSpeed = 0.005;
		end

		getglobal("LoginScreenFrameEnterGame"):SetScale(EnterGameScale);--	SetSize(216*EnterGameScale, 46*EnterGameScale);
	end

	if waitForTransferData then
		local transferState = ClientMgr:getDataTransferState();
		if transferState == 0 then
			waitForTransferData = false;
			getglobal("MessageBoxFrame"):Hide();
			isEnterGame = true;
			EnterGame();

		elseif transferState == 1 then
			waitForTransferData = true;
			MessageBox(14, GetS(3695));
			getglobal("MessageBoxFrame"):SetClientString("正在转移数据");

		elseif transferState == 2 then
			waitForTransferData = false;
			MessageBox(4, GetS(3696));
			getglobal("MessageBoxFrame"):SetClientString("数据转移完成");
		end
	end

    --[[
	local rich = getglobal("LoginScreenFrameTips2");
	if rich:IsShown() then
		local disx = rich:GetDispPosX() + MOVE_WIDTH_TICK;
		rich:SetDispPosX( disx )
		if disx - 10 > rich:getLineWidth(0) then
			rich:SetDispPosX( -873 )
		end
	end
	]]
end

--新手引导流程优化，用户协议同意按钮也增加放大缩小效果
function OverseaPolisyFrame_OnShow()
	--标题栏
	getglobal("OverseaPolisyFrameTitleFrameName"):SetText(GetS(9214));

	-- getglobal("OverseaPolisyFrameAgreeBtnNormal"):SetPoint("center", this:GetName(), "center", 215, 180)
	--隐藏img_close_bd
	getglobal("OverseaPolisyFrameTitleFrameBkgClose"):Hide()
end 

function OverseaPolisyFrame_OnUpdate()
	-- if getglobal("OverseaPolisyFrame"):IsShown() then
	-- 	local orginWidth = 169
	-- 	local orginHeight = 55
	-- 	if getglobal("MessageBoxFrame"):IsShown() then
	-- 		getglobal("OverseaPolisyFrameAgreeBtnNormal"):SetWidth(orginWidth)
	-- 		getglobal("OverseaPolisyFrameAgreeBtnNormal"):SetHeight(orginHeight)
	-- 	else
	-- 		EnterGameScale = EnterGameScale + ScaleSpeed;
	-- 		if EnterGameScale > 1 then
	-- 			EnterGameScale = 1
	-- 			ScaleSpeed = -0.05
	-- 		elseif EnterGameScale < 0.9 then
	-- 			EnterGameScale = 0.9
	-- 			ScaleSpeed = 0.05
	-- 		end
	-- 		getglobal("OverseaPolisyFrameAgreeBtnNormal"):SetWidth(EnterGameScale * orginWidth)
	-- 		getglobal("OverseaPolisyFrameAgreeBtnNormal"):SetHeight(EnterGameScale * orginHeight)
	-- 	end
	-- end 
end

function LoginScreenFrameNoticeBtn_OnClick()
	--TODO:测试
	if  ns_start_notice.txt and #ns_start_notice.txt > 0 then
		SetNoticeInfoLua()
	else
		ShowGameTips(GetS(242), 3);
	end
	--新式埋点上报
	standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "Announcement", "click")
	
	
	--local content = NoticeManager:getGameContent();
	--if content == "" then
		--ShowGameTips(StringDefCsv:get(242), 3);
	--else
		--SetNoticeInfo();
	--end
end

function LoginScreenFrameAgreementBtn_OnClick()
	getglobal("AgreementFrame"):Show();
end

--[[
function SetNoticeInfoOld()
	local btnText = getglobal("GameUpdateFrameUpdateGameBtnText");
	local title = getglobal("GameUpdateFrameTitle");
	local type = NoticeMgr:getType();

	--local content = NoticeManager:getGameContent();
	getglobal("UpdateContentBoxContent"):SetText(content, 140, 103, 84);
	getglobal("GameUpdateFrameCloseBtn"):Show();
	if type == 1 then	--系统更新
		local version = ClientMgr:clientVersionToStr(NoticeMgr:getCode())
		title:SetText(version..GetS(241));
		btnText:SetText(GetS(157));
	else
		title:SetText(GetS(228));
		btnText:SetText(GetS(226));
	end
	getglobal("GameUpdateFrame"):Show();
end
--]]


--新版本读取lua config
function SetNoticeInfoLua()
	if ClientMgr:isEducationLiteGame() then
		return
	end

	Log( "call SetNoticeInfoLua" )
	--MiniBase不显示公告
	if MiniBase then return end

	local btnText = getglobal("GameUpdateFrameUpdateGameBtnText");
	local title   = getglobal("GameUpdateFrameTitleFrameName");

	local content    = ns_start_notice.txt        or ""
	local type       = ns_start_notice.type       or 0
	local NoticeCode = ns_start_notice.NoticeCode or "0.0.0"

	getglobal("UpdateContentBoxContent"):SetText(content, 61, 69, 70);
	getglobal("GameUpdateFrameCloseBtn"):Show();

	if  type == 1 then	--系统更新
		local version = NoticeCode
		title:SetText(version..GetS(241));
		btnText:SetText(GetS(157));
	else
		title:SetText(GetS(228));

		if getglobal("LoginScreenFrame"):IsShown() then
			btnText:SetText(GetS(3011));
			btnText:SetTextColor(55, 54, 51);
		else
			btnText:SetText(GetS(226));
		end
	end
	getglobal("GameUpdateFrame"):Show();
	
end


function LoginScreenFrameSdkLoginBtn_OnClick()
	local ApiId = ClientMgr:getApiId();
	if ApiId == 13 or ApiId == 15 or ApiId == 313 then	--SDK帐号登录
		SdkManager:sdkLogin();
	end
end

function LoginScreenFrameQQLoginBtn_OnClick()
	if isShouQPlatform() then
		if not isShouQAuthorize() then
			JavaMethodInvokerFactory:obtain()
									:setSignature("()V")
									:setClassName("org/appplay/platformsdk/MobileSDK")
									:setMethodName("ShouQTencentLogin")
									:call();
			return;
		elseif ClientMgr:getNetworkState() == 0 and not LocalHasAccount() then
			ShowGameTips(GetS(35206));
			return;
		end
	end
end

function AddClickPos(x, y)
	if ClientCurGame and not ClientCurGame:isInGame() then
		ClientCurGame:createClickPos(x, y);
	end
	if ClientMgr:isMobile() then
		if HasUIFrame("ChatInputFrame") then
			if getglobal("ChatInputFrame"):IsShown() then
				getglobal("ChatInputFrame"):Hide();
				--ClientCurGame:setOperateUI(false);
				UIFrameMgr:setCurEditBox(nil);
			end
		end
	end
end

-------------------------------------LoginScreenFrameAgreement---------------------------
function LoginScreenFrameAgreementTick_OnClick()
	local tick = getglobal("LoginScreenFrameAgreementTickIcon");
	if tick:IsShown() then
		tick:Hide();
	else
		tick:Show();
	end
end

function LoginScreenFrameAgreement_OnShow()
	getglobal("LoginScreenFrameAgreementContent"):SetText(GetS(3835), 237, 231, 217);
end

function LoginScreenFrameAgreementContent_OnClick()
	Log("LoginScreenFrameAgreementContent_OnClick:");
	-- Log("arg1 = " .. arg1 .. ", arg2 = " .. arg2 .. ", arg3 = " .. arg3);
	
	if arg1 then
		local url = ClientUrl:GetUrlString("HttpMini1", "index.php/privacyPolicy")--"http://www.mini1.cn/index.php/privacyPolicy";
		local appid = ClientMgr:getApiId();
		local pc = ClientMgr:isPC();
		local mobilePrivacyIdx = nil;
		if pc or appid <300 then
			if arg1 == "《游戏许可及服务协议》" or arg1 == "Terms of Use" then
				Log("Link1:");
				url = ClientUrl:GetUrlString("HttpMini1", "index.php/licenseAgreement")--"http://www.mini1.cn/index.php/licenseAgreement";
				-- statisticsGameEvent(10012, '%d', 1, '%d', pc);	--埋點: 国内-游戏许可及服务协议链接
				mobilePrivacyIdx = g_Article_Agreement_Url_Index;
			elseif arg1 == "隐私协议" or arg1 == "Privacy Policy" then
				Log("Link2:");
				url = ClientUrl:GetUrlString("HttpMini1", "index.php/privacyPolicy")--"http://www.mini1.cn/index.php/privacyPolicy";
				-- statisticsGameEvent(10012, '%d', 2, '%d', pc);	--埋點: 国内-隐私条款链接
				mobilePrivacyIdx = g_Privacy_Agreement_Url_Index;
			elseif arg1 == "儿童隐私政策" then
				url = ClientUrl:GetUrlString("HttpsMini1", "children.html")--"https://www.mini1.cn/children.html";
				mobilePrivacyIdx = g_Children_Privacy_Agreement_Url_Index;
			end
		elseif appid > 300 then
			if arg1 == "Terms of Use" or arg1 == "《游戏许可及服务协议》" then
				Log("Link3:");
				url = ClientUrl:GetUrlString("HttpMini1", "index.php/terms?id=1")--"http://en.mini1.cn/index.php/terms?id=1";
				-- statisticsGameEvent(10012, '%d', 3, '%d', pc);	--埋點: 国外-游戏许可及服务协议链接
			elseif arg1 == "Privacy Policy" or arg1 == "隐私协议" then
				Log("Link4:");
				url = ClientUrl:GetUrlString("HttpMini1", "index.php/terms?id=2")--"http://en.mini1.cn/index.php/terms?id=2";
				-- statisticsGameEvent(10012, '%d', 4, '%d', pc);	--埋點: 国外-隐私条款链接
			end
		end
		if mobilePrivacyIdx then
			if ClientMgr:isAndroid() then
				if MINIW__JumpPolicyPage then
					MINIW__JumpPolicyPage(mobilePrivacyIdx);
				end
			elseif ClientMgr:isApple() then
				if SdkManager.JumpPolicyPage then
					SdkManager:JumpPolicyPage(mobilePrivacyIdx);
				end
			else
				SdkManager:BrowserShowWebpage(url);
			end
		else
			SdkManager:BrowserShowWebpage(url);
		end
	end
end

-- 《游戏许可及服务协议》
function LoginScreenFrameAgreement_OnClick()
	if gIsSingleGame then
		local msgframe = getglobal("AgreementFrame")
		if msgframe then
			msgframe:SetClientUserData(1, 100503)
			msgframe:SetClientUserData(2, 100501)
			msgframe:Show()
		end
		return
	end
	-- getglobal("AgreementFrame"):Show();
	-- Log("arg1 = " .. arg1 .. ", arg2 = " .. arg2 .. ", arg3 = " .. arg3);

	if arg1 then
		local url = ClientUrl:GetUrlString("HttpMini1", "index.php/privacyPolicy")--"http://www.mini1.cn/index.php/privacyPolicy";
		local appid = ClientMgr:getApiId();
		local pc = ClientMgr:isPC();
		local monilePrivacyIdx = g_Privacy_Agreement_Url_Index;
		if appid <300 and arg1 == "游戏许可及服务协议" then
			Log("Link1:");
			url = ClientUrl:GetUrlString("HttpMini1", "index.php/licenseAgreement")--"http://www.mini1.cn/index.php/licenseAgreement";
			-- statisticsGameEvent(10013, '%d', 1, '%d', pc);	--埋點: 国内-游戏许可及服务协议链接
			monilePrivacyIdx = g_Article_Agreement_Url_Index;
		elseif appid > 300 and arg1 == "Terms of Use" then
			Log("Link3:");
			url = ClientUrl:GetUrlString("HttpMini1", "index.php/terms?id=1")--"http://en.mini1.cn/index.php/terms?id=1";
			-- statisticsGameEvent(10013, '%d', 2, '%d', pc);	--埋點: 国外-游戏许可及服务协议链接
		end
		if monilePrivacyIdx then
			if ClientMgr:isAndroid() then
				if MINIW__JumpPolicyPage then
					MINIW__JumpPolicyPage(monilePrivacyIdx);
				end
			elseif ClientMgr:isApple() then
				if SdkManager.JumpPolicyPage then
					SdkManager:JumpPolicyPage(monilePrivacyIdx);
				end
			else
				SdkManager:BrowserShowWebpage(url);
			end
		else
			SdkManager:BrowserShowWebpage(url);
		end
	end
end

-- 欧盟隐私条款链接1
function LoginScreenFrameAgreement2_OnClick()
	local url = ClientUrl:GetUrlString("HttpMini1", "index.php/terms?id=1")
	SdkManager:BrowserShowWebpage(url)--"http://en.mini1.cn/index.php/terms?id=1");
	-- statisticsGameEvent(10011, '%d', 1);	--埋點: 欧盟隐私条款链接1
end

-- 《隐私政策》
function LoginScreenFrameAgreement3_OnClick()
	if gIsSingleGame then
		local msgframe = getglobal("AgreementFrame")
		if msgframe then
			msgframe:SetClientUserData(1, 100504)
			msgframe:SetClientUserData(2, 100502)
			msgframe:Show()
		end
		return
	end
	-- SdkManager:BrowserShowWebpage("http://en.mini1.cn/index.php/terms?id=2");
	-- statisticsGameEvent(10011, '%d', 2);	--埋點: 欧盟隐私条款链接2
	-- Log("arg1 = " .. arg1 .. ", arg2 = " .. arg2 .. ", arg3 = " .. arg3);
	if arg1 then
		local url = ClientUrl:GetUrlString("HttpMini1", "index.php/privacyPolicy")--"http://www.mini1.cn/index.php/privacyPolicy";
		local appid = ClientMgr:getApiId();
		local pc = ClientMgr:isPC();
		local mobilePrivacyIdx = nil;
		if appid <300 and (arg1 == "隐私协议" or arg1 == "隐私政策") then
			Log("Link2:");
			url = ClientUrl:GetUrlString("HttpMini1", "index.php/privacyPolicy")--"http://www.mini1.cn/index.php/privacyPolicy";
			-- statisticsGameEvent(10014, '%d', 1, '%d', pc);	--埋點: 国内-隐私条款链接
			mobilePrivacyIdx = g_Privacy_Agreement_Url_Index;

		elseif appid > 300 and arg1 == "Privacy Policy" then
			Log("Link4:");
			url = ClientUrl:GetUrlString("HttpMini1", "index.php/terms?id=2")--"http://en.mini1.cn/index.php/terms?id=2";
			-- statisticsGameEvent(10014, '%d', 2, '%d', pc);	--埋點: 国外-隐私条款链接
		end

--[[		if mobilePrivacyIdx then
			if ClientMgr:isAndroid() then
				if MINIW__JumpPolicyPage then
					MINIW__JumpPolicyPage(mobilePrivacyIdx);
				end
			elseif ClientMgr:isApple() then
				if SdkManager.JumpPolicyPage then
					SdkManager:JumpPolicyPage(mobilePrivacyIdx);
				end
			else
				SdkManager:BrowserShowWebpage(url);
			end
		else
			SdkManager:BrowserShowWebpage(url);
		end--]]
		if ns_version.privacy_policy_url and ns_version.privacy_policy_url.url and ns_version.privacy_policy_url.url ~= "" then
			if check_apiid_ver_conditions( ns_version.privacy_policy_url, true) then
				url = ns_version.privacy_policy_url.url
			end
		end
		--SdkManager:BrowserShowWebpage(url);
		open_http_link(url)
	end
end

-- 《儿童隐私协议》
function LoginScreenFrameAgreement4_OnClick()
	local url = ClientUrl:GetUrlString("HttpsMini1", "children.html")--"https://www.mini1.cn/children.html";
	if ClientMgr:isAndroid() then
		if MINIW__JumpPolicyPage then
			MINIW__JumpPolicyPage(g_Children_Privacy_Agreement_Url_Index); -- 手机端走内嵌webview
		end
	elseif ClientMgr:isApple() then
		if SdkManager.JumpPolicyPage then
			SdkManager:JumpPolicyPage(g_Children_Privacy_Agreement_Url_Index); -- 手机端走内嵌webview
		end
	else
		SdkManager:BrowserShowWebpage(url);
	end
end

----------------------------------GameUpdateFrame-------------------------------------
IsNotSetUpdateContent = true;
function GameUpdateFrameClose_OnClick()
	getglobal("GameUpdateFrame"):Hide();
end

--获取设备ID仅测试服使用
function GameUpdateFrameCopyDeviceIDBtn_OnClick()
	if get_game_env() == 1 then
		local deviceId = ClientMgr:getDeviceID() or ""
		ClientMgr:clickCopy(deviceId)
		ShowGameTipsWithoutFilter(deviceId)
	end
end

-- 已经交给luascript/login.lua， 这个函数无效
function GameUpdateFrameUpdateGameBtn_OnClick()
	getglobal("GameUpdateFrame"):Hide();
	local text = getglobal("GameUpdateFrameUpdateGameBtnText");
	local name = text:GetText();
	if string.find(name, GetS(157)) then
		ClientMgr:startUpdate();
	elseif string.find(name, GetS(3011)) then
		if getglobal("LoginScreenFrameProgress"):IsShown() then return end
		if getglobal("LoginScreenFrame"):IsShown() then
			EnterGame();  -- 已经交给luascript/login.lua， 这个函数无效
		end
	end
end

function GameUpdateFrame_OnLoad()
	--标题栏
	getglobal("GameUpdateFrameTitleFrameName"):SetText(GetS(147));
	
	--不再使用旧版本公告
	--this:RegisterEvent("GE_GAME_NOTICE");
end

function GameUpdateFrame_OnEvent()
	if arg1 == "GE_GAME_NOTICE" then

		local ge = GameEventQue:getCurEvent();
		local type             = ge.body.gameNotice.type;
		local versionCode      = ge.body.gameNotice.code;
		local notice_showcount = ge.body.gameNotice.showcount or 0;
		local notice_interval  = ge.body.gameNotice.interval  or 86400;
		
		
		local function show_GameUpdateFrame()
			if isEducationalVersion then
				return
			end

			getglobal("GameUpdateFrame"):Show();		
			local title = 0;
			local close = getglobal("GameUpdateFrameCloseBtn");
			local text = getglobal("GameUpdateFrameUpdateGameBtnText");
			close:Hide();
			if type == 1 then
				local version = ClientMgr:clientVersionToStr(versionCode)
				title = version..GetS(241);
				if ge.body.gameNotice.forceupdate == 0 then
					close:Show();
				end

				text:SetText(GetS(157));
			elseif type == 2 then
				close:Show();
				title = GetS(228);
				NoticeMgr:setCode(versionCode);
				text:SetText(GetS(226));
			end
			getglobal("GameUpdateFrameTitleFrameName"):SetText(title);
		end

		Log( "noticetype="       .. type )
		Log( "versionCode="      .. versionCode )
		Log( "notice_showcount=" .. notice_showcount )
		Log( "notice_interval="  .. notice_interval )

		if  notice_showcount > 0 then
			--判断展示次数和间隔			
			if  ClientMgr.getGameDataPath then
				local showcount_ = ClientMgr:getGameDataPath( "GameData.Notice", "showcount" )
				local last_time_ = ClientMgr:getGameDataPath( "GameData.Notice", "last_time" )
				
				Log( "GameData showcount=" .. showcount_ )
				Log( "GameData last_time=" .. last_time_ )


				--版本号是否有变化
				local ver_old_ = NoticeMgr:getCode()
				if  ver_old_ ~= versionCode then
					Log( "versioncode changed" )
					last_time_ = 0;
				end

				local now_ = os.time()   --不能取服务器，只能取自己的时间
				if  IsSameDay( now_, last_time_ ) then
					Log( "same day" )
				else
					Log( "not same day" )
					showcount_ = 0;  	--非同一天
				end

				if  showcount_ < notice_showcount then
					--还有显示次数
					--是否跨interval
					if  now_ - last_time_ >= notice_interval then
						showcount_ = showcount_ + 1
						ClientMgr:setGameDataPath( "GameData.Notice", "showcount", showcount_ );
						ClientMgr:setGameDataPath( "GameData.Notice", "last_time", now_ );
						show_GameUpdateFrame()
					else
						Log( "can not show again. notice_interval=" .. now_ - last_time_ .. " / " .. notice_interval )
					end
				else
					Log( "can not show again. showcount_=" .. showcount_ .. " / " .. notice_showcount )
				end
			end
		else
			show_GameUpdateFrame()  --旧版本
		end
		
	end
end

function GameUpdateFrame_OnShow()
	if ClientCurGame and ClientCurGame:isInGame() and not getglobal("GameUpdateFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end

	if get_game_env() == 1 then
		getglobal("GameUpdateFrameCopyDeviceIDBtn"):Show()
	end
end

function GameUpdateFrame_OnHide()
	if ClientCurGame and ClientCurGame:isInGame() and not getglobal("GameUpdateFrame"):IsRehide()  then
		ClientCurGame:setOperateUI(false);
	end
end

function GameUpdateFrame_OnUpdate()
	if IsNotSetUpdateContent then
		getglobal("UpdateContentBox"):resetOffsetPos();
		getglobal("UpdateContentBoxContent"):clearHistory();
		getglobal("UpdateContentBoxContent"):Clear();
		
		--local content = NoticeManager:getGameContent();
		local content = ""
		if  ns_start_notice.txt then
			content = ns_start_notice.txt
		end

		getglobal("UpdateContentBoxContent"):SetText(content, 61, 69, 70);
		local lines = getglobal("UpdateContentBoxContent"):GetTextLines();
		if lines > 0 then
			IsNotSetUpdateContent = false;
			local lines = getglobal("UpdateContentBoxContent"):GetTextLines();
			if lines <= 14 then
				getglobal("UpdateContentBoxPlane"  ):SetSize(890, 561);
				getglobal("UpdateContentBoxContent"):SetSize(890, 561);
			else
				getglobal("UpdateContentBoxPlane"  ):SetSize(890, 561+(lines-14)*27);
				getglobal("UpdateContentBoxContent"):SetSize(890, 561+(lines-14)*27);
			end
		end
	end
end

function UpdateContentBoxContent_OnClick()
	if arg1 ~= "LeftButton" then
		SdkManager:BrowserShowWebpage(arg2);
	end
end
----------------------------------------AgreementFrame-------------------------------------------------
function AgreementFrameClose_OnClick()
	getglobal("UpdateContentBox"):setDealMsg(true);
	getglobal("AgreementFrame"):Hide();
end

function AgreementFrame_OnLoad()
end

function AgreementFrame_OnShow()
	getglobal("AgreementFrameBkg"):SetHeight(590);
	UITemplateBaseFuncMgr:registerFunc("AgreementFrameCloseBtn", AgreementFrameClose_OnClick, "设置页面关闭按钮");
	local titleId = this:GetClientUserData(1)
	local contentId = this:GetClientUserData(2)
	if titleId > 0 then
		getglobal("AgreementFrameTitleName"):SetText(GetS(titleId));
	else
		getglobal("AgreementFrameTitleName"):SetText(GetS(3838));
	end

	if getglobal("GameSetFrame"):IsShown() then
		getglobal("GameSetFrame"):Hide();
	end
	getglobal("UpdateContentBox"):setDealMsg(false);
	if contentId > 0 then
		getglobal("AgreementFrameBoxContent"):SetText(GetS(contentId), 61, 69, 70);
	elseif getglobal("ShareArchiveInfoFrame"):IsShown() then
		getglobal("AgreementFrameBoxContent"):SetText(GetS(4076), 61, 69, 70);
	elseif HasUIFrame("ShareArchive") and getglobal("ShareArchive"):IsShown() then
		--新存档分享界面
		getglobal("AgreementFrameBoxContent"):SetText(GetS(4076), 61, 69, 70);
	else
		getglobal("AgreementFrameBoxContent"):SetText(GetS(3836), 61, 69, 70);
	end
	local lines = getglobal("AgreementFrameBoxContent"):GetTextLines();
	getglobal("AgreementFrameBoxPlane"):SetSize(890, 10+lines*27);
	getglobal("AgreementFrameBoxContent"):SetSize(890, 10+lines*27);
end


function LoginScreenFrameLangBtn_OnClick()
	getglobal("SwitchLangFrame"):Show();
end


function LoginScreenFrameEnvBtn_OnClick()
	getglobal( "JumpEnvFrame" ):Show();
end


lang_now = 999;
lang_list = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };

function SwithLangFrame_OnHide()
	if ClientCurGame and ClientCurGame:isInGame() then
		ClientCurGame:setOperateUI(false);
	end
end

function SwithLangFrame_OnShow()
	if ClientCurGame and ClientCurGame:isInGame() then
		ClientCurGame:setOperateUI(true);
	end

	--标题栏
	getglobal("SwitchLangFrameTitleFrameName"):SetText(GetS(3499));

	if  lang_now == 999 then
		--首次记录
		lang_now = get_game_lang();
	end

	local isOversea = get_game_env() >= 10
	if isOversea then
		local lang_index = nil
		if lang_now == 2 then
			lang_index = 0
		elseif lang_now > 2 then
			lang_index = lang_now - 1
		else
			lang_index = lang_now
		end
		getglobal("SwitchLangFrameLayout"):Hide()
		getglobal("SwitchLangFrameLayoutOversea"):Show()
		getglobal( 'SwitchLangFrameLayoutOverseaLang' .. lang_index ):Checked();
	else 
		getglobal("SwitchLangFrameLayoutOversea"):Hide()
		getglobal("SwitchLangFrameLayout"):Show()
		getglobal( 'SwitchLangFrameLayoutLang' .. lang_now ):Checked();
	end
	setLangChecked( lang_now );

	Log( "call SwithLangFrame_OnShow, lang_now=" .. lang_now );


	--"cn",  //简体 0   3495
	--"en",  //英语 1   3496
	--"tw",  //繁体 2   3497
	--"tha", //泰语 3      975
	--"esn", //西班牙 4    976
	--"ptb", //葡萄牙 5    977
	--"fra", //法语 6      978
	--"jpn", //日语 7      979
	--"ara", //阿拉伯 8    980
	--"kor", //韩语 9      981
	--"vie", //越南 10     982
	--"rus", //俄语 11     983
	--"tur", //土耳其 12   984
	--"ita", //意大利 13   985
	--"ger"  //德语 14 	   986
	--"ind"  //印尼语 15   987

	--排序
	local column_ = 0	
	local row_    = 0
	
	local show_cc = 0
	local hasExcepted = false
	for i=0, 15 do
		if isOversea then
			if i == 7 then
				--隐藏
				local btn_ = getglobal( 'SwitchLangFrameLayoutOverseaLang' .. i )
				if  btn_ then
					btn_:Hide()
					hasExcepted = true
				end	
			end
		else
			if i == 8 then
				--隐藏			
				local btn_ = getglobal( 'SwitchLangFrameLayoutLang' .. i )
				if  btn_ then
					btn_:Hide()
					hasExcepted = true
				end
			end
		end
	
		if not hasExcepted then	
			-- row_    = math.floor(show_cc / 3)

			-- column_ = show_cc % 3
			-- show_cc = show_cc + 1
			local btn_ = nil
			local txt_ = nil
			if isOversea then
				btn_ = getglobal( 'SwitchLangFrameLayoutOverseaLang' .. i )
				txt_ = getglobal( 'SwitchLangFrameLayoutOverseaLang' .. i .. "Tips" )
			else
				btn_ = getglobal( 'SwitchLangFrameLayoutLang' .. i )
				txt_ = getglobal( 'SwitchLangFrameLayoutLang' .. i .. "Tips" )
			end

			if  btn_ then
				-- btn_:SetPoint("topleft", "SwitchLangFrameBkg", "topleft",  144 + column_*246 , row_ * 88 + 114);
				if isOversea then
					if txt_ then
						if i == 0 then
							txt_:SetText( GetS(3497) )
						elseif i == 1 then
							txt_:SetText( GetS(3496) )
						else
							txt_:SetText( GetS(975-2+i) )
						end
					end
				else
					if i < 3 then
						txt_:SetText( GetS(3495+i) )
					else
						txt_:SetText( GetS(975-3+i) )
					end
				end
			end
		end
		if hasExcepted then
			hasExcepted = false
		end

	end

	--刷新布局:使用布局控件来刷新布局
	if isOversea then
		getglobal("SwitchLangFrameLayoutOversea"):UpdateLayout();	
	else
		getglobal("SwitchLangFrameLayout"):UpdateLayout();
	end
end


function setLangChecked( op )
	local isOversea = get_game_env() >= 10
	if isOversea then
		lang_list = {2,1,3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
		for k,v in pairs(lang_list) do
			local btn = getglobal( 'SwitchLangFrameLayoutOverseaLang' .. (k-1) );
			if btn then
				if v == op then
					Log( "v==" .. op )
					btn:Disable();
				else
					Log( "v!=" .. op )
					btn:Enable();
					btn:DisChecked();
				end
			end
		end
	else
		for k,v in pairs(lang_list) do
			local btn  = getglobal( 'SwitchLangFrameLayoutLang' .. v );
			if btn then
				if v == op then
					Log( "v==" .. op )
					btn:Disable();
				else
					Log( "v!=" .. op )
					btn:Enable();
					btn:DisChecked();
				end
			end
		end
	end
end


--切换语言 lang_set
function SwithLangFrame_OnClick( op )
	Log( "call SwithLangFrame_OnClick=" .. op .. "/" .. lang_now );

	if  op == 999 then
		getglobal("SwitchLangFrame"):Hide();   --关闭
	else
		if  lang_now == op then
			--没有切换
		else
			getglobal("SwitchLangFrame"):Hide();
			MessageBox(5, GetS(3498) , function(btn)
				if  btn == 'left' then
					ClientMgr:setGameData( "lang", op);    --0=cn 1=en 2=tw
					g_game_lang = nil
					ns_hotfix.clearErrorProtectCountPatch()   --清理热更新错误计数
					ClientMgr:gameExit(true);
				end
			end);
		end

		--setLangChecked( op );
	end
end


function LoginScreenFrameSwitchIsCheckBtn_OnClick()
   if not getglobal("OursValidateFrame"):IsShown() then
	   OursValidateFrameInit()
	else
		getglobal("OursValidateFrame"):Hide()
   end
end




function VersionNumberInfoFrameOkBtn_OnClick()
	getglobal("VersionNumberInfoFrame"):Hide();
end

-- LLDO:是否显示登陆界面的切换账号按钮.-------------------------------------------------------------------------
local m_IsShowLoginBtnOnLodingPage = false	--是否在启动页面显示登陆按钮

function func_show_login_btn(data_)
	print("func_show_login_btn: login_btn", ns_version.login_btn);
	
	local apiids_cond = check_apiid_ver_conditions(ns_version.login_btn);
	print("func_show_login_btn: apiids_cond", apiids_cond);
	if apiids_cond then
			--匹配
		LoginFrameIsShowLoginBtn(true);
	else
		LoginFrameIsShowLoginBtn(false);
		return false;
	end
end

function ShowAccountManageAndAccountLoginBtn(isshow)
	if getglobal("LoginScreenFrameAccountLoginBtn"):IsShown() and (not isshow) then
		getglobal("LoginScreenFrameAccountLoginBtn"):Hide()
	end
	if getglobal("LoginScreenFrameAccountManageBtn"):IsShown() and (not isshow) then
		getglobal("LoginScreenFrameAccountManageBtn"):Hide()
	end

	RefreshAccountManageAndAccountLoginBtnPos()
end

function RefreshAccountManageAndAccountLoginBtnPos()
	local accountLoginBtShow = getglobal("LoginScreenFrameAccountLoginBtn"):IsShown()  -- 没有登陆记录显示 （login_bt控制）
	local accountMgrBtShow = getglobal("LoginScreenFrameAccountManageBtn"):IsShown()   -- 有登陆记录显示
	if accountLoginBtShow or accountMgrBtShow then
		getglobal("LoginScreenFrameEnterGameBtn"):SetPoint("bottom", "LoginScreenFrame", "bottom", 0, -158)
	else
		getglobal("LoginScreenFrameEnterGameBtn"):SetPoint("bottom", "LoginScreenFrame", "bottom", 0, -117)
	end
end


function LoginFrameIsShowLoginBtn(bShow)
	--登陆按钮
	if IsEnableNewAccountSystem() then
		ShowAccountManageAndAccountLoginBtn(bShow)
	else
		if bShow and not isEducationalVersion then
			getglobal("LoginScreenFrameSwitchUserBtn"):Show();
			m_IsShowLoginBtnOnLodingPage = true;
	
		else
			getglobal("LoginScreenFrameSwitchUserBtn"):Hide();
			m_IsShowLoginBtnOnLodingPage = false;
		end
	end

	--"国际版"字样
	if true and isAbroadEvn() then
		--国际版字样不受,bShow,开关影响.
		getglobal("LoginScreenFrameAbroad"):Show();
	else
		getglobal("LoginScreenFrameAbroad"):Hide();
	end
end

--打开切换迷你号界面
function LoginScreenFrameSwitchUserBtn_OnClick()
	Log("LoginScreenFrameSwitchUserBtn_OnClick:");
	local hasOldAccount = GetInst("QQWeChatLoginManager"):HasLoginHistoryData()
	if hasOldAccount then
		GetInst("UIManager"):Open("QQWechatAccessTokenLogin")
	else
		if NewAccountSwitchCfg and NewAccountSwitchCfg:IsOpen() then
			NewAccountManager:NotifyEvent(NewAccountManager.DLG_ACCOUNT_MANAGER, {})
		elseif _G.IsEnableNewAccountSystem and IsEnableNewAccountSystem() then
			if _G.IsUIFrameShown and (not IsUIFrameShown("AccountManage")) then
				OpenAccountManagePanel("MinilobbyAccountManage")
			end
		else
			getglobal("AccountLoginFrame"):Show();

			--模拟点击"切换迷你号"按钮
			AccountFrameSwitchAcountBtn_OnClick();
		end
	end
end

--设置"切换迷你号页面".如果在启动页面打开, 则要使找回密码按钮和绑定按钮不可用.
--被调函数: AccountFrameSwitchAcountBtn_OnClick().
function LoginScreenFrameSetSwitchUserFrame()
	local mini = getglobal("AccountLoginFrameMini");
	local setPDBtn = getglobal("AccountLoginFrameActivateBtn");
	local setPDBtnNormal = getglobal("AccountLoginFrameActivateBtnNormal");
	local setPDBtnPushed = getglobal("AccountLoginFrameActivateBtnPushedBG");
	local bindBtn = getglobal("AccountSecuritySettingsBtn");
	local bindBtnNormal = getglobal("AccountSecuritySettingsBtnNormal");
	local bindBtnPushed = getglobal("AccountSecuritySettingsBtnPushedBG");

	if getglobal("LoginScreenFrame"):IsShown() and m_IsShowLoginBtnOnLodingPage then
		setPDBtn:Disable();
		bindBtn:Disable();
		setPDBtnNormal:SetGray(true);
		bindBtnNormal:SetGray(true);
		setPDBtnPushed:SetGray(true);
		bindBtnPushed:SetGray(true);
		mini:SetText("");
		getglobal("AccountLoginFrameLoginContentPWSwitchBtnTitle"):Hide()
	else
		setPDBtn:Enable();
		bindBtn:Enable();
		setPDBtnNormal:SetGray(false);
		bindBtnNormal:SetGray(false);
		setPDBtnPushed:SetGray(false);
		bindBtnPushed:SetGray(false);
		getglobal("AccountLoginFrameLoginContentPWSwitchBtnTitle"):Hide()
	end
end
-------------------------------------------------------切换语言按钮-----------------------------------------------------
function  func_show_lang_btn(isShow)
	local getglobal = _G.getglobal;
	local langBtn = getglobal("LoginScreenFrameLangBtn");
	if isShow and not isEducationalVersion then
		-- if getglobal("LoginScreenFrameEnvBtn"):IsShown() then
		-- 	langBtn:SetPoint("bottomright","LoginScreenFrame","bottomright", -101, -14);
		-- else
		-- 	langBtn:SetPoint("bottomright","LoginScreenFrame","bottomright", -20, -14);
		-- end
		if IsEnableNewLogin and IsEnableNewLogin() then
		else
			langBtn:Show();
		end
	else
		langBtn:Hide();
	end
end
-------------------------------------------------------end------------------------------------------------------------

-----------------------------------------------------------------------------其它------------------------------------

--欧盟隐私条款相关----------------------------------------------------begin---------------------------
function ShowOverseaPolisyFrame()
	Log("ShowOverseaPolisyFrame:");
	local apiid = ClientMgr:getApiId();
	if true then		--增加国内手机版
		--local curVersion = ClientMgr:clientVersion();		--LLDO:20180721:去掉版本信息, 不用每次更新都提示
		local k = "PrivacyPolicy"; --.. curVersion;
		local v = getkv(k);

		Log("k = " .. k);

		if false and v then
			--已经同意过条款
			Log("Have Agreed!");
		else
			--当前版本未曾同意
			Log("Have not Agree!");

			--因为ios不能退游戏，所以只有确认按钮
			if IsIosPlatform() then
				local okBtn = getglobal("OverseaPolisyFrameAgreeBtn");
				getglobal("OverseaPolisyFrameRefuseBtn"):Hide();
				okBtn:SetPoint("bottom", "OverseaPolisyFrameChenDi", "bottom", 0, -20);
			end

			if IsOverseasVer() then
				getglobal("OverseaPolisyFrame"):Show();
				getglobal("OverseaPolisyFrameContentText"):SetText(GetS(9215), 61, 69, 70);
			else
				getglobal("OverseaPolisyFrameContentText"):SetText(GetS(9223), 61, 69, 70);
			end

			-- statisticsGameEvent(10010, '%d', 1);	--埋點: 打开条款界面
			--埋点，打开用户使用条款&隐私政策 设备码,用户类型,语言
			-- statisticsGameEventNew(955,ClientMgr.getDeviceID and ClientMgr:getDeviceID() or "",
			-- 	ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
			StatisticsTools:send(true, true)
		end
	end
end

function OverseaPolisyFrameIsShown()
	if getglobal("OverseaPolisyFrame"):IsShown() then 
		return true
	elseif getglobal("NewbieSelectPlayerTypeView"):IsShown() 
			or getglobal("NewbieSelectSexAgeView"):IsShown() then
		return true 
	else
		return false 
	end 
end

--C++调用lua端的方法，新手引导选角色
function updateRoleSelect()
	if getglobal("NewbieCreateRole"):IsShown() then
		GetInst("UIManager"):GetCtrl("NewbieCreateRole"):updateNameDesc()
	end
	local ctrl = GetInst("MiniUIManager"):GetCtrl("main_createrole")
	if ctrl then
		ctrl:UpdateNameDesc()
	end 
end

function ShowOverseaPolisyFrameFont()
	Log("ShowOverseaPolisyFrameFont:");
	if isAbroadEvn() or 999 == ClientMgr:getApiId() then
		-- getglobal("GameSetFrameOtherAgreement2"):Show();
		-- getglobal("GameSetFrameOtherAgreement3"):Show();
		-- getglobal("GameSetFrameOtherAgreement2"):SetText(GetS(9225), 98, 65, 48);
		-- getglobal("GameSetFrameOtherAgreement3"):SetText(GetS(9226), 98, 65, 48);
	end
end

function OverseaPolisyFrameCloseBtn_OnClick()
	this:GetParentFrame():Hide();
end

--打开游戏许可及服务协议网页
function OpenPage_LicenseAndServiceAgreement()
	arg1, arg2 = GetS(100503), "1"
	OverseaPolisyFrameContentText_OnClick()
end

--打开隐私政策网页
function OpenPage_PrivacyPolicy()
	arg1, arg2 = GetS(100504), "2"
	OverseaPolisyFrameContentText_OnClick()
end

--打开儿童隐私政策网页
function OpenPage_ChildPrivacyPolicy()
	arg1, arg2 = GetS(1000601), "3"
	OverseaPolisyFrameContentText_OnClick()
end
-- 儿童隐私政策
function OpenPage_ChildrenPrivacyPolicy()
	LoginScreenFrameAgreement4_OnClick();
end

-- 《隐私政策摘要》
function OpenPage_PrivacyPolicySummary()
	local url = ClientUrl:GetUrlString("HttpsMini1", "article/20190527/2255.html")
	open_http_link(url) -- https://www.mini1.cn/article/20190527/2255.html
end

--[[detail_info_url = {
        player_detail_url = "", --个人信息清单配置地址
		third_share_info = "", --第三方信息共享清单配置地址
        },--]]
--个人信息清单
function OpenPage_PlayerDetail()
	local url = ClientUrl:GetUrlString("HttpPlayerDetail", "")
	if ns_version.detail_info_url and ns_version.detail_info_url.player_detail_url and ns_version.detail_info_url.player_detail_url ~= "" then
		if check_apiid_ver_conditions( ns_version.detail_info_url, true) then
			url = ns_version.detail_info_url.player_detail_url
		end
	end
	--SdkManager:BrowserShowWebpage(url);
	open_http_link(url)
end

--第三方信息共享清单
function OpenPage_ThirdShareInfo()
	local url = ClientUrl:GetUrlString("HttpThirdShareInfo", "")
	if ns_version.detail_info_url and ns_version.detail_info_url.third_share_info and ns_version.detail_info_url.third_share_info ~= "" then
		if check_apiid_ver_conditions( ns_version.detail_info_url, true) then
			url = ns_version.detail_info_url.third_share_info
		end
	end
	--SdkManager:BrowserShowWebpage(url);
	open_http_link(url)
end

function OverseaPolisyFrameContentText_OnClick()
	Log("OverseaPolisyFrameContentText_OnClick:");
	-- Log("arg1 = " .. arg1 .. ", arg2 = " .. arg2 .. ", arg3 = " .. arg3);
	if arg1 and arg2 then
		if arg2 == "1" then
			-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CONTAINER", "LicenseAndServiceAgreement", "click"); --1034914 埋点下线需求
		else
			-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CONTAINER", "PrivacyPolicy", "click"); --1034914 埋点下线需求
		end
	end
	if gIsSingleGame then
		local msgframe = getglobal("AgreementFrame")
		if msgframe then
			if arg1 and arg2 then
				if arg2 == "1" then
					msgframe:SetClientUserData(1, 100503)
					msgframe:SetClientUserData(2, 100501)
				else
					msgframe:SetClientUserData(1, 100504)
					msgframe:SetClientUserData(2, 100502)
				end
				msgframe:Show()
			end
		end
		return
	end

	if IsOverseasVer() then
		--海外版跳转链接
		if arg1 and arg2 then
			local url = ClientUrl:GetUrlString("HttpMini1", "index.php/terms?id=2")--"http://en.mini1.cn/index.php/terms?id=2";
			if arg2 == "1" then
				Log("Link1:");
				url = ClientUrl:GetUrlString("HttpMini1", "index.php/terms?id=1")--"http://en.mini1.cn/index.php/terms?id=1"
			else
				Log("Link2:");
				url = ClientUrl:GetUrlString("HttpMini1", "index.php/terms?id=2")--"http://en.mini1.cn/index.php/terms?id=2"
			end

			SdkManager:BrowserShowWebpage(url);
		end
	else
		--国内版跳转链接
		if arg1 and arg2 then
			local url = ClientUrl:GetUrlString("HttpsMini1", "index.php/licenseAgreement")--"https://www.mini1.cn/index.php/licenseAgreement";
			local mobilePrivacyIdx = nil;
			if arg2 == "1" then
				Log("Link1:");
				url = ClientUrl:GetUrlString("HttpsMini1", "index.php/licenseAgreement")--"https://www.mini1.cn/index.php/licenseAgreement"
				mobilePrivacyIdx = g_Article_Agreement_Url_Index;
			elseif arg2 == "2" then
				Log("Link2:");
				url = ClientUrl:GetUrlString("HttpsMini1", "index.php/privacyPolicy")--"https://www.mini1.cn/index.php/privacyPolicy"
				mobilePrivacyIdx = g_Privacy_Agreement_Url_Index
				if ns_version.privacy_policy_url and ns_version.privacy_policy_url.url and ns_version.privacy_policy_url.url ~= "" then
					if check_apiid_ver_conditions( ns_version.privacy_policy_url, true) then
						url = ns_version.privacy_policy_url.url
					end
				end
				--SdkManager:BrowserShowWebpage(url);
				open_http_link(url)
				return
			elseif arg2 == "3" then
				url = ClientUrl:GetUrlString("HttpsMini1", "children.html")--"https://www.mini1.cn/children.html"
				mobilePrivacyIdx = g_Children_Privacy_Agreement_Url_Index;
			end

			if mobilePrivacyIdx then
				if ClientMgr:isAndroid() then
					if MINIW__JumpPolicyPage then
						MINIW__JumpPolicyPage(mobilePrivacyIdx);
					end
				elseif ClientMgr:isApple() then
					if SdkManager.JumpPolicyPage then
						SdkManager:JumpPolicyPage(mobilePrivacyIdx);
					end
				else
					SdkManager:BrowserShowWebpage(url);
				end
			else
				SdkManager:BrowserShowWebpage(url);
			end
		end
	end
end

function OverseaPolisyFrameRefuseBtn_OnClick()
	Log("OverseaPolisyFrameRefuseBtn_OnClick:");
	--放弃二次确认
	-- if GuideLobby > 0 then
	-- 	statisticsGameEvent(901, '%s', "GiveUpAgreement","%d",GuideLobby,"%s",os.date("%Y%m%d%H%M%S",os.time()));
	-- end
	-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CONTAINER", "Cancle", "click"); --1034914 埋点下线需求
	--新手引导流程优化，只有一个确认按钮，且点击只关闭二级弹框，不产生其他影响
	-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CANCLE", "-", "view"); --1034914 埋点下线需求
	-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CANCLE", "Confirm", "view"); --1034914 埋点下线需求
	MessageBox(4, GetS(2035), function(btn)
		if btn == 'left' then 	--确认
			-- Log("left:");
			-- this:GetParentFrame():Hide();
			-- statisticsGameEvent(10010, '%d', 2);	--埋點: 左键拒绝
			-- if GuideLobby > 0 then
			-- 	statisticsGameEvent(901, '%s', "AgreeUserAgreement","%d",GuideLobby,"%s",os.date("%Y%m%d%H%M%S",os.time()));
			-- 	StatisticsTools:send(false, true);
			-- end
			-- setkv("no_privacy_policy",true);      -- 标记用户拒绝协议
			-- ClientMgr:gameExit();
		-- elseif btn == 'right' then  --取消
		-- 	if GuideLobby > 0 then
		-- 		statisticsGameEvent(901, '%s', "CancelAgreementButom","%d",GuideLobby,"%s",os.date("%Y%m%d%H%M%S",os.time()));
		-- 	end
		elseif btn == "center" then
			-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CANCLE", "Confirm", "click"); --1034914 埋点下线需求
		end
	end);
end

function OverseaPolisyFrameAgreeBtn_OnClick()
	Log("OverseaPolisyFrameAgreeBtn_OnClick:");
	--local curVersion = ClientMgr:clientVersion();
	local k = "PrivacyPolicy"; -- .. curVersion;		--LLDO:20180721:去掉版本信息, 不用每次更新都提示
	local v = true;	--同意则设为true

	Log("k = " .. k);
	setkv( k, v);
	this:GetParentFrame():Hide();
	ShowGameTips(GetS(9220), 3);
	--statisticsGameEvent(10010, '%d', 3);	--埋點: 右键同意
	-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CONTAINER", "Agree", "click"); --1034914 埋点下线需求
	-- if GuideLobby > 0 then
	-- 	statisticsGameEvent(901, '%s', "NoUserAgreement","%d",GuideLobby,"%s",os.date("%Y%m%d%H%M%S",os.time()));
	-- end
	--埋点，点击"同意" 设备码,用户类型,语言
	-- statisticsGameEventNew(956,ClientMgr.getDeviceID and ClientMgr:getDeviceID() or "",
	-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
	StatisticsTools:send(true, true)
end

--欧盟隐私条款相关----------------------------------------------------end--------------------------------

-- 获取手机型号
function GetDeviceModel()
	local deviceInfoStatistics = {};
	if ClientMgr.getMobilePhoneInfo then
		local infoJson = ClientMgr:getMobilePhoneInfo();
		if infoJson then
			local t_info = JSON:decode(infoJson);
			if t_info then
				deviceInfoStatistics["Model"] = t_info.Model
				deviceInfoStatistics["SDTotal"] = t_info.SDTotal
				deviceInfoStatistics["RamTotal"] = t_info.RamTotal
				deviceInfoStatistics["WindowWidth"] = t_info.WindowWidth
				deviceInfoStatistics["WindowHeigh"] = t_info.WindowHeigh
			else
				print("GetDeviceModel() t_info is nil")
			end
		else
			print("GetDeviceModel() infoJson is nil")
		end
	else
		print("ClientMgr.getMobilePhoneInfo() is null");
	end
	return JSON:encode(deviceInfoStatistics)
end

----------开屏广告Begine--------------
local advShowTime = 0;
local advDuringTime = 1;
-- 开屏广告
function LoginFrameStartAdv_OnUpdate()
	local curTime = AccountManager:getSvrTime()
	if curTime - advShowTime > advDuringTime then
		getglobal("LoginScreenFrameStartAdv"):Hide();
	end
end
-- 检查是否开启开屏广告
-- 检查本地是否有该广告图
-- 按照渠道分别显示广告
function CheckStartAdv()
	local startAds = getkv( "ads", "game_start_ads", 101 );
	local advFrame = getglobal("LoginScreenFrameStartAdv")
	if startAds == nil or #startAds == 0 then
		advFrame:Hide()
		return
	end
	local curTime = AccountManager:getSvrTime();
	local adsCount = getkv( "ads_count", "game_start_ads", 101 );

	for i, v in ipairs(startAds) do
		local advPath = v.file_name
		local startTime = uu.get_time_stamp( v.start_time );
		local endTime = uu.get_time_stamp( v.end_time );
		Log("CheckStartAdv:"..advPath.." start time: "..startTime.." end time: "..endTime.." is exist: "..tostring(gFunc_isStdioFileExist(advPath)))
		if advPath and 
			startTime < curTime and 
			endTime > curTime and 
			gFunc_isStdioFileExist( advPath ) then

			getglobal("LoginScreenFrameStartAdvBkg"):SetTexture( advPath )

			advShowTime = curTime;
			advDuringTime = tonumber(v.time)
			-- 最小1s 最大3s
			advDuringTime = advDuringTime > 0 and advDuringTime or 1
			advDuringTime = advDuringTime < 4 and advDuringTime or 3
			if adsCount == nil then -- 不存在记录
				local adsCountTable = {
						["time"] = curTime, 
						["counts"] = 1
					};
				setkv("ads_count",adsCountTable,"game_start_ads",101)
				if v.count > 0 then
					advFrame:Show()
				end
			else
				if IsSameDay(curTime, adsCount.time) then -- 同一天 需要比较次数
					if adsCount.counts < v.count then
						advFrame:Show()
						adsCount.counts = adsCount.counts + 1
						setkv("ads_count",adsCount,"game_start_ads",101)
					end
				else	-- 不同天 检查一下配置的次数是否大于0
					if v.count > 0 then
						adsCount.time = curTime
						adsCount.counts = 1
						advFrame:Show()
						setkv("ads_count",adsCount,"game_start_ads",101)
					end
				end
			end
			return
		else
			advFrame:Hide()
		end
	end
end
----------开屏广告End------------
--获取设备类型、系统版本,选择屏蔽广告
function AdGetDeviceInfo()
	local deviceInfo = {};
	if ClientMgr.getMobilePhoneInfo then
		local infoJson = ClientMgr:getMobilePhoneInfo();
		if infoJson then
			local t_info = JSON:decode(infoJson);
			deviceInfo["SystemVersion"] = t_info and t_info.SystemVersion and t_info.SystemVersion or ""
		else
			print("AdDevTypeAndVersion() infoJson is nil")
		end
	else
		print("ClientMgr.getMobilePhoneInfo() is null");
	end

	if ClientMgr.getPlatformStr then
		local platform = ClientMgr:getPlatformStr()
		deviceInfo["Platform"] = platform;
	end
	return deviceInfo
end

------------------------------------更新按钮------------------------------------
local updatebtn_istest = false;	--测试配置开关

local text_updatebtn = {
	[999] = {
		--是否显示按钮
		canshow = true,

		--最大版本号
		maxversion = "0.41.6",

		--这些语言不显示按钮
		-- ex_langs = {1, },

		--链接
		url = ClientUrl:GetUrlString("HttpsHWDownload", "miniwmobile/android-miniwan-blockart-ow.apk")--"https://hw-mdownload.mini1.cn/miniwmobile/android-miniwan-blockart-ow.apk",
	},

	[310] = {
		--是否显示按钮
		canshow = true,
		maxversion = "0.41.5",
		url = ClientUrl:GetUrlString("HttpsHWDownload", "miniwmobile/android-miniwan-blockart-ow.apk")--"https://hw-mdownload.mini1.cn/miniwmobile/android-miniwan-blockart-ow.apk",
	},

	[345] = {
		canshow = true,
		maxversion = "0.41.5",
		url = ClientUrl:GetUrlString("HttpsHWDownload", "miniwmobile/android-miniwan-blockart-ow.apk")--"https://hw-mdownload.mini1.cn/miniwmobile/android-miniwan-blockart-ow.apk",
	},
};

--是否排除了当前语言
local function isEXCurLang(ex_langs)
	if ex_langs then
		local curLang = get_game_lang();
		for i = 1, #ex_langs do
			if curLang == ex_langs[i] then
				return true;
			end
		end
	end
	return false;
end

--外部接口:是否显示更新按钮
function CheckCanShowUpdateBtn()
	print("CheckCanShowUpdateBtn:");
	--测试配置
	local updatebtn_config = ns_version.updatebtn;
	if updatebtn_istest then
		updatebtn_config = text_updatebtn;
	end

	print("updatebtn_config = ", updatebtn_config);
	if nil == updatebtn_config then
		return false;
	end

	local apiid = ClientMgr:getApiId();
	local curConfig = updatebtn_config[apiid];

	if nil == curConfig then
		return false;
	end

	local maxversion = curConfig.maxversion;
	if nil == maxversion then
		return false;
	end

	if curConfig.canshow then
		--版本号判断
		local _maxversion = ClientMgr:clientVersionFromStr(maxversion);
		local curversion = ClientMgr:clientVersion();

		if curversion >= _maxversion then
			return false;
		end
		
		--是否排除了当前语言
		-- if isEXCurLang(curConfig.ex_langs) then
		-- 	return false;
		-- end

		return true;
	else
		return false;
	end
end


--外部接口:是否强弹更新界面
function CheckCanPopupUpdateFrame()
	local ret = false
	if ns_version and ns_version.updatebtn then
		local apiid = ClientMgr:getApiId()
		local curConfig = ns_version.updatebtn[apiid]
		if curConfig then
			local curConfigMaxVersion = curConfig.maxversion
			local curConfigPopup = curConfig.popup
			if curConfigMaxVersion and curConfigPopup then
				local maxversion = ClientMgr:clientVersionFromStr(curConfigMaxVersion)
				local curversion = ClientMgr:clientVersion()
				local lastTimePopupVer = container:load_from_file("update_btn_popup_maxversion") or curversion
				ret = curConfigPopup and (maxversion > curversion) and (maxversion > lastTimePopupVer)
				if ret == true then
					container:save_to_file("update_btn_popup_maxversion", maxversion)
					container:save_to_file("update_btn_popup_already", true)
				end
			end
		end
	end
	return ret
end


function LoginScreenFrame_PopupUpdateFrame()
	local apiid = ClientMgr:getApiId()
	if Android:IsMainland(apiid) and CheckCanPopupUpdateFrame() then
	-- if CheckCanPopupUpdateFrame() then
		LoginScreenFrameUpdateBtn_OnClick()
	end
end

function LoginScreenFrame_ShowPrivacyUpdateDialog()
	local onlinePrivacyAgreementVersion = ns_version and ns_version.privacy_agreement_version or "0";
	print("ns_version.privacy_agreement_version：",onlinePrivacyAgreementVersion);
	if ClientMgr:isApple() then
		if SdkManager.ShowPrivacyUpdateDialog then
			SdkManager:ShowPrivacyUpdateDialog(onlinePrivacyAgreementVersion);
		end
	else
		if MINIW__ShowPrivacyUpdateDialog then
			MINIW__ShowPrivacyUpdateDialog(onlinePrivacyAgreementVersion);
		end
	end
	
end

function LoginScreenFrame_ShowUpdateBtn()
	local btn = getglobal("LoginScreenFrameUpdateBtn");

	if CheckCanShowUpdateBtn() then
		btn:Show();
	else
		btn:Hide();
	end

	--刷新一下三个按钮的位置
	local btnList = {
		"LoginScreenFrameEnvBtn",
		"LoginScreenFrameLangBtn",
		"LoginScreenFrameUpdateBtn",
	};

	local y = 0;
	for i = 1, #btnList do
		local btn = getglobal(btnList[i]);
		if btn and btn:IsShown() then
			btn:SetPoint("bottom", "LoginScreenFrameLangBox","bottom", 0, y);
			y = y - 100;
		end
	end
end

--更新按钮点击
function LoginScreenFrameUpdateBtn_OnClick()
	local id = ClientMgr:getApiId();
	--国内采用新的下载方法
	if Android:IsMainland(id) then
		GetInst("UIManager"):Open("GameRequestUpdateFrame");
	else
		-- --测试配置
		local updatebtn_config = ns_version.updatebtn;
		if updatebtn_istest then
			updatebtn_config = text_updatebtn;
		end

		if nil == updatebtn_config then
			return;
		end

		local apiid = ClientMgr:getApiId();
		local curConfig = updatebtn_config[apiid];

		if curConfig and curConfig.url then
			local url = curConfig.url;
			print("url = ", url);

			SdkManager:BrowserShowWebpage(url);
		end
	end
end

--抖音云游戏登录按钮视图刷新
function DouyinCloudLoginUpdateView()
	if not (isDouyinCloudPlatform and isDouyinCloudPlatform()) then
		return
	end

	local douyinyunLogin = function ()
		local douyinPkgName = 'com.minitech.miniworld.douyincloud'
		local douyinToken = nil
		local qaz = Android:Localize(Android.SITUATION.JAVA2LUA);
		--隐藏“进入游戏”、“账号管理”、“账号登录”按钮 和游戏服务协议
		getglobal("LoginScreenFrameEnterGameBtn"):Hide()		
		getglobal("LoginScreenFrameAccountManageBtn"):Hide()
		getglobal("LoginScreenFrameAccountLoginBtn"):Hide()
		getglobal("LoginScreenFrameAgreement"):Hide();

		-- 网络不好，提示网络问题
		if CheckNetworkErrTipsShow and CheckNetworkErrTipsShow() then
			getglobal("LoginScreenFrameEnterGameBtn"):Show()
			return
		end

		if CallJavaChannelLoginStatus then
			if not CallJavaChannelLoginStatus() then
				getglobal("LoginScreenFrameEnterGameBtn"):Show()
				return
			end
		end

		ShowNoTransparentLoadLoop()
		-- 确保数据能拿到
		local tryTime = 3
		local tick = CommonUtil:getSystemTick()
		while not douyinToken or string.len(douyinToken) <= 0 do
			ClientMgr:CheckDouYinToken()
			print("DouyinCloudLoginUpdateView tick ", CommonUtil:getSystemTick() - tick)
			tick = CommonUtil:getSystemTick()
			tryTime = tryTime - 1
			if tryTime < 0 then
				break
			end
			threadpool:wait(2)
			
			douyinToken = SdkManager:getTpLoginAccountParams()
		end
		HideNoTransparentLoadLoop()
		
		-- 如果还是没拿到，那就是原生内部出问题，，直接提示数据错误
		print("DouyinCloudLoginUpdateView douyinToken ", douyinToken)
		if not douyinToken or douyinToken == "" then
			ShowGameTipsWithoutFilter(GetS(759))
			getglobal("LoginScreenFrameEnterGameBtn"):Show()
		else
			LoginManager:LogRequestReport()
			if LoginManager:InnerLoginPreDoing() then
				local loginRet = false
				-- qaz("DOUYIN :  douyinToken =  ",douyinToken)
				-- douyinToken = '4wCCjXN711APO6pjqMqf3b4Z05e/e9VmgepmzxZPqlir2nlmnfnOD1fUGDKm0GhAayxJQu/pUMDz6GZ6gMLT2wbIs25A0xjsZGBpEbg+GFuODjhKQUA2naJ9mkYrPnwPeoyKFEr2sytLpOxTsQtkFg=='
				local info = {token=douyinToken, package_name=douyinPkgName}
				--多做两次联机尝试
				
				local seq = gen_gid()
				threadpool:work(function()
					loginRet = AccountManager:unionid_bind_login_dycloud(info)
					threadpool:notify(seq, ErrorCode.OK)
				end)
				
				local code = threadpool:wait(seq, 4)
				print("DouyinCloudLoginUpdateView code ", code)
				if code ~= ErrorCode.OK then 
					ShowGameTipsWithoutFilter(GetS(120137))
					getglobal("LoginScreenFrameEnterGameBtn"):Show()
				end
				
				print("DouyinCloudLoginUpdateView code ", loginRet)
				--成功后跳转到大厅
				if loginRet == true then
					LoginManager:InnerLoginLogic("")
				else
					getglobal("LoginScreenFrameEnterGameBtn"):Show()
					HideNoTransparentLoadLoop()
				end
			end
		end
	end

	LoginManager:RunnInThread(douyinyunLogin)
end

--手Q授权登录按钮视图刷新
function ShouQLoginUpdateView()
	if IsEnableNewLogin and IsEnableNewLogin() then
		return 
	end

	local mrLog = Android:Localize(Android.SITUATION.PAYMENT);
	local mrTag = "AbsMobileSDK---";
    mrLog("isShouQPlatform: ",isShouQPlatform())
    mrLog("isShouQAuthorize: ",isShouQAuthorize())
    if isShouQPlatform() and isAndroidShouQ() then
		--隐藏手Q渠道《游戏服务协议》
		getglobal("LoginScreenFrameAgreement"):Hide();
		--如果没网且本地没账号也显示授权登录
        if isShouQAuthorize() and not(ClientMgr:getNetworkState() == 0 and not LocalHasAccount()) then
            getglobal("LoginScreenFrameQQLoginBtn"):Hide();
			getglobal("LoginScreenFrameEnterGameBkg"):Show();
			if IsEnableNewAccountSystem() then
				LoginScreenFrameShowLoginBtn()
				getglobal("LoginScreenFrameEnterGameBkg"):Hide();
			else
				getglobal("LoginScreenFrameEnterGame"):Show();
			end
			getglobal("LoginScreenFrameShouQLogoutBtn"):Show();
        else
            getglobal("LoginScreenFrameShouQLogoutBtn"):Hide();
            getglobal("LoginScreenFrameQQLoginBtn"):Show();
            getglobal("LoginScreenFrameEnterGameBkg"):Hide();
			if IsEnableNewAccountSystem() then
				HideNewLoginSysBtn()
			else
				getglobal("LoginScreenFrameEnterGame"):Hide();
			end
        end
    end
end

function LoginScreenFrameShouQLogoutBtn_OnClick()
    JavaMethodInvokerFactory:obtain()
                            :setClassName("org/appplay/platformsdk/MobileSDK")
                            :setMethodName("ShouQTencentLogout")
                            :setSignature("()V")
                            :call();
    ShouQLoginUpdateView();
end

function SetLogoutNickName(nickName)
    getglobal("LoginScreenFrameShouQLogoutBtnNickName"):SetText(nickName or "");
end

function LocalHasAccount()
	local current = AccountManager:load_from_file('current')
	if current then
		return true
	end
	return false
end

--展示渠道logo
function ShowChannelLogo()
	local apiId = ClientMgr:getApiId()
	--qq渠道才展示
	if apiId == 56 then
		getglobal("LoginScreenFrameQQIcon"):SetTexture("ui/login_logo_qq.png")
	else
		if get_game_lang() == 0 or get_game_lang() == 2 then 
			getglobal("LoginScreenFrameQQIcon"):SetTexture("ui/login_logo.png")
		else
			getglobal("LoginScreenFrameQQIcon"):SetTexture("overseas_res/english/texture/login_logo.png")
		end 
	end
end

--根据登入的场景显示登录按钮
function LoginScreenFrameShowLoginBtn()
	getglobal("LoginScreenFrameNoticeBtn"):Hide()
	if IsEnableNewLogin and IsEnableNewLogin() then
		LoginManager:NotifyCustomEvent(LoginManager.EVENT_HOMEPAGE_DLG_SHOW, LOGINBGTYPE)
		LoginManager:NotifyCustomEvent(LoginManager.EVENT_HOMEPAGE_LOGINBT_REFRESH, {})
		LoginManager:NotifyCustomEvent(LoginManager.EVENT_HOMEPAGE_OTHERBT_REFRESH)

		-- 2、聚合登录结果还没到，进度条跑完，需等待
		if LoginManager:GetSwitchCfg():GetThirdChannelBindSwitch() 
			and _G.g_channelLoginResultFlag == nil then
			ShowLoadLoopFrame2(true,"LoginScreenFrameShowLoginBtn", 5)
		end
		return 
	end

	print("LoginScreenFrameShowLoginBtn start!")
	getglobal("LoginScreenFrameNoticeBtn"):Show()
	HasNotCurrentAndHasHistory = false
	local openstring = SdkManager:getTpLoginAccountParams()
	if not openstring or openstring == ''  then --不是第三方渠道登录
		--账号管理,账号登录根据配置是否显示 规则：
		-- 1、当前或者历史记录都不存在，根据ns_version.login_btn显示账号登陆按钮
		-- 2、反之根据ns_version.login_btn 显示账号管理

		if isAndroidShouQ() then
			getglobal("LoginScreenFrameEnterGameBtn"):Hide()
		else
			getglobal("LoginScreenFrameEnterGameBtn"):Show()
		end
		getglobal("LoginScreenFrameProgress"):Hide();
		getglobal("LoginScreenFrameThirdLoginBtn"):Hide()
		getglobal("LoginScreenFrameEnterGameBtnQQIcon"):Hide()
		-- 设置游客/迷你号
		local accountInfo = AccountManager.uin_history and  AccountManager:uin_history() or nil
		local current = accountInfo and accountInfo.last_login or nil --当前登录账号
		local history = accountInfo and accountInfo.history or nil --历史登录记录

		local visitorModeText =''
		if current and next(current) then
			if ns_version and ns_version.login_btn and next(ns_version.login_btn) then
				local apiids_cond = check_apiid_ver_conditions(ns_version.login_btn)
				if apiids_cond then
					standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "AccountManagementButton", "view")
					getglobal("LoginScreenFrameAccountManageBtn"):Show()
				else
					getglobal("LoginScreenFrameAccountManageBtn"):Hide()
				end
			else
				standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "AccountManagementButton", "view")
				getglobal("LoginScreenFrameAccountManageBtn"):Show()
			end	
			getglobal("LoginScreenFrameAccountLoginBtn"):Hide()
			local Uin = current and current.Uin or AccountManager:getUin()
			visitorModeText = table.concat({GetS(359),Uin})
			getglobal("LoginScreenFrameEnterGameBtnVisitorMode"):SetText(visitorModeText)
			getglobal("LoginScreenFrameEnterGameBtnText"):SetPoint("top", "LoginScreenFrameEnterGameBtn", "top", 0, 14)

			if ClientMgr:getApiId() == 45 and current.authinfo and current.authinfo.openid_type then
				if  current.authinfo.openid_type == "qq" then
					setIsShouQLogin(true);
					local qqIcon = getglobal("LoginScreenFrameEnterGameBtnQQIcon")
					qqIcon:Show()
	
					local qqBtnMode = getglobal("LoginScreenFrameEnterGameBtnVisitorMode")
					local qName = getShouQNickName() or ""
					if #qName > 15 then
						qName = string.sub(qName,1,15).."..."
					end
					local length = qqBtnMode:GetTextExtentWidth(qName)
					qqBtnMode:SetText(qName)
					qqIcon:SetPoint("center", "LoginScreenFrameEnterGameBtnVisitorMode", "center", length/2*(-1) - 14, -3)
				end
			end
			if not DeepLinkQueue:empty() then
				g_uiroot:get('LoginScreenFrame').EnterGameBtn:OnClick();
			end
		else
			if history and next(history) then 
				HasNotCurrentAndHasHistory = true
				if ns_version and ns_version.login_btn and next(ns_version.login_btn) then
					local apiids_cond = check_apiid_ver_conditions(ns_version.login_btn)
					if apiids_cond then
						standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "AccountManagementButton", "view")
						getglobal("LoginScreenFrameAccountManageBtn"):Show()
					else
						getglobal("LoginScreenFrameAccountManageBtn"):Hide()
					end
				else
					standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "AccountManagementButton", "view")
					getglobal("LoginScreenFrameAccountManageBtn"):Show()
				end	
				getglobal("LoginScreenFrameAccountLoginBtn"):Hide()
				getglobal("LoginScreenFrameEnterGameBtnVisitorMode"):SetText(visitorModeText)
				getglobal("LoginScreenFrameEnterGameBtnText"):SetPoint("center", "LoginScreenFrameEnterGameBtn", "center", 0, 0)
				if not DeepLinkQueue:empty() then
					g_uiroot:get('LoginScreenFrame').EnterGameBtn:OnClick();
				end
			else --无当前登录账户和历史登录记录显示游客登录
				if ns_version and ns_version.login_btn and next(ns_version.login_btn)then
					local apiids_cond = check_apiid_ver_conditions(ns_version.login_btn)
					if apiids_cond then
						standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "AccountLogIn", "view")
						getglobal("LoginScreenFrameAccountLoginBtn"):Show()
					else
						getglobal("LoginScreenFrameAccountLoginBtn"):Hide()
					end
				else
					standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "AccountLogIn", "view")
					getglobal("LoginScreenFrameAccountLoginBtn"):Show()
				end
				if ClientMgr:getApiId() == 60 then getglobal("LoginScreenFrameAccountLoginBtn"):Hide() end
				getglobal("LoginScreenFrameAccountManageBtn"):Hide()
				--visitorModeText = table.concat({'(',GetS(35552),')'})
				getglobal("LoginScreenFrameEnterGameBtnVisitorMode"):SetText(visitorModeText)
				getglobal("LoginScreenFrameEnterGameBtnText"):SetPoint("center", "LoginScreenFrameEnterGameBtn", "center", 0, 0)
				--getglobal("LoginScreenFrameEnterGameBtnText"):SetPoint("top", "LoginScreenFrameEnterGameBtn", "top", 0, 14)
			end
		end		
    else
		-- 第三方登陆
		getglobal("LoginScreenFrameEnterGameBtn"):Hide()
		getglobal("LoginScreenFrameAccountLoginBtn"):Hide()
		getglobal("LoginScreenFrameAccountManageBtn"):Hide()
		getglobal("LoginScreenFrameThirdLoginBtn"):Show()
		--新式埋点上报
		standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "ThirdLogInButton", "view")
    end

	RefreshAccountManageAndAccountLoginBtnPos()
	-- sdk渠道登陆按钮
	LoginScreenFrameSdkLoginBtnShow()
end

--账号登录
function LoginScreenFrameAccontLoginBtn_OnClick()
	if IsEnableNewLogin and IsEnableNewLogin() and LoginManager:InterruptPrivatePolicyCheck()  then
		return
	else
		if IsOverseasVer() or ClientMgr:isPC() then
			--开了隐私条款的不用勾选
		else
			local CltVersion = LuaInterface and LuaInterface.getCltVersion and LuaInterface:getCltVersion() or 0
			if CltVersion and CltVersion >= 28 * 256 and getglobal("LoginScreenFrameAgreementContent"):IsShown() 
			   and not getglobal("LoginScreenFrameAgreementTickIcon"):IsShown() then
				ShowGameTips(GetS(3837), 3);
				if AnimMgr.stopByName then AnimMgr:stopByName("LoginScreenFrameAgreementTick"); end
				if AnimMgr.playBlink then AnimMgr:playBlink("LoginScreenFrameAgreementTick", 1, 0.5); end
			   return;
			end
		end
	end

	standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "AccountLogIn", "click")
	if IsEnableNewAccountSystem() then
		LoginMainUIInit()
	end

	if OpenLoginUi then
		OpenLoginUi({srcType = 2})
	end
end

--账号管理
function LoginScreenFrameAccontManageBtn_OnClick()
	if IsEnableNewLogin and IsEnableNewLogin() and LoginManager:InterruptPrivatePolicyCheck()  then
		return
	else
		if IsOverseasVer() or ClientMgr:isPC() then
			--开了隐私条款的不用勾选
		else
			local CltVersion = LuaInterface and LuaInterface.getCltVersion and LuaInterface:getCltVersion() or 0
			if CltVersion and CltVersion >= 28 * 256 and getglobal("LoginScreenFrameAgreementContent"):IsShown() 
				and not getglobal("LoginScreenFrameAgreementTickIcon"):IsShown() then
				ShowGameTips(GetS(3837), 3);
				if AnimMgr.stopByName then AnimMgr:stopByName("LoginScreenFrameAgreementTick"); end
				if AnimMgr.playBlink then AnimMgr:playBlink("LoginScreenFrameAgreementTick", 1, 0.5); end
				return;
			end
		end
	end


	standReportEvent("10000", "MINI_LANDINGPAGE_START_1", "AccountManagementButton", "click")
	if IsEnableNewAccountSystem() then
		LoginMainUIInit()
	end
	OpenAccountManagePanel("LoginAccountManage")
end

--隐藏新流程的登录按钮
function HideNewLoginSysBtn()
	getglobal("LoginScreenFrameEnterGameBtn"):Hide()
	getglobal("LoginScreenFrameAccountLoginBtn"):Hide()
	getglobal("LoginScreenFrameAccountManageBtn"):Hide()
	getglobal("LoginScreenFrameThirdLoginBtn"):Hide()

	RefreshAccountManageAndAccountLoginBtnPos()
end

-- 已经交给luascript/login.lua， 这个函数无效
function NewLoginBtn_OnClick()
    if isShouQPlatform() and not isIOSShouQLogin then
		if not isShouQAuthorize() then
			Log( "return isShouQAuthorize" )
			return;
		elseif ClientMgr:getNetworkState() == 0 and not LocalHasAccount() then
			Log( "return getNetworkState == 0" )
			return;
		end
	end

	if IsEnableNewAccountSystem() and HasNotCurrentAndHasHistory then
		GetInst("UIManager"):Open("SwitchAccountUI")
		return
	end

	if  isEnterGame then
		Log( "return isEnterGame" )
		return;
	end
	if  getglobal("LoginScreenFrameProgress"):IsShown() or not isLoadFinish then
		Log( "return isLoadFinish" )
		return;
	end
	if  ClientMgr:getDataTransferState()~=0 then
		waitForTransferData = true;
		Log( "return getDataTransferState" )
		return;
	end

	if (not ClientMgr:isPC() or not AccountManager:getNoviceGuideState("guideagreement")) and not
	    getglobal("LoginScreenFrameAgreementTickIcon"):IsShown() then
	 	ShowGameTips(GetS(3837), 3);
		AnimMgr:stopByName("LoginScreenFrameAgreementTick");
		AnimMgr:playBlink("LoginScreenFrameAgreementTick", 1, 0.5);
	 	return;
	 end

	isEnterGame = true;
	EnterGame();  -- 已经交给luascript/login.lua， 这个函数无效
end

-- 已经交给luascript/login.lua， 这个函数无效
function ThirdLoginBtn_OnClick()
    if isShouQPlatform() then
		if not isShouQAuthorize() then
			Log( "return isShouQAuthorize" )
			return;
		elseif ClientMgr:getNetworkState() == 0 and not LocalHasAccount() then
			Log( "return getNetworkState == 0" )
			return;
		end
	end

	if IsEnableNewAccountSystem() and HasNotCurrentAndHasHistory then
		GetInst("UIManager"):Open("SwitchAccountUI")
		return
	end

	if  isEnterGame then
		Log( "return isEnterGame" )
		return;
	end
	if  getglobal("LoginScreenFrameProgress"):IsShown() or not isLoadFinish then
		Log( "return isLoadFinish" )
		return;
	end
	if  ClientMgr:getDataTransferState()~=0 then
		waitForTransferData = true;
		Log( "return getDataTransferState" )
		return;
	end

	if IsEnableNewLogin and IsEnableNewLogin() and LoginManager:InterruptPrivatePolicyCheck()  then
		return
	else
		if IsOverseasVer() or ClientMgr:isPC() then
			--开了隐私条款的不用勾选
		else
			local CltVersion = LuaInterface and LuaInterface.getCltVersion and LuaInterface:getCltVersion() or 0
			if CltVersion and CltVersion >= 28 * 256 and getglobal("LoginScreenFrameAgreementContent"):IsShown() 
				and not getglobal("LoginScreenFrameAgreementTickIcon"):IsShown() then
				ShowGameTips(GetS(3837), 3);
				if AnimMgr.stopByName then AnimMgr:stopByName("LoginScreenFrameAgreementTick"); end
				if AnimMgr.playBlink then AnimMgr:playBlink("LoginScreenFrameAgreementTick", 1, 0.5); end
				return;
			end
		end
	end

	isEnterGame = true;
	EnterGame();  -- 已经交给luascript/login.lua， 这个函数无效
end

function showDownloadQRCode()
	local apiId = ClientMgr:getApiId();
	if apiId == 1  or apiId == 110 or apiId == 81 or apiId == 45 or (IsMiniCps(apiId) and apiId ~= 69 and apiId ~= 94) then
		if apiId ~= 79 then
			getglobal("LoginScreenFrameDownloadQrCode"):Show()
		else
			getglobal("LoginScreenFrameDownloadQrCode"):SetTexture("ui/mobile/texture0/bigtex/wx_qr_code.png")
			getglobal("LoginScreenFrameDownloadQrCode"):Show()
		end
	else
		getglobal("LoginScreenFrameDownloadQrCode"):Hide()
	end	
end