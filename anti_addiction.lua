local FcmSwitch = true;				--防沉迷开关
RealNameAuthSwitch = true;			--实名认证开关
ForceRealNameAuthSwitch = false;	--强制认证开关

local FcmRate = 100;				--防沉迷收益比例
local t_fcmDatas = {};
local LastTotalOnlineTime = 0;
local IsAdult = false;				--是否成年

CheckFcmAccount = false;
sdkRealNameFlag = false; 			--是否获取到了渠道实名认证的回调结果

function LoadAntiAddictionFile()
	--[[
	local jsonstr = gFunc_readTxtFile("data/antiaddiction.fcm");
	if jsonstr == "" then
		return;
	end

	local fcmDatas = JSON:decode(jsonstr);
	
	local uin = AccountManager:getUin();
	for i=1, #(fcmDatas) do
		table.insert(t_fcmDatas, fcmDatas[i]);

		if uin == fcmDatas[i].uin then
			LastTotalOnlineTime = fcmDatas[i].totalOnlineTime
		end
	end
	]]
	
	local fcmDatas = container:load_from_file("fcm");
	if fcmDatas then
		local uin = AccountManager:getUin();
		for i=1, #(fcmDatas) do
			table.insert(t_fcmDatas, fcmDatas[i]);

			if uin == fcmDatas[i].uin then
				LastTotalOnlineTime = fcmDatas[i].totalOnlineTime
			end
		end
	end
end

function SaveAntiAddictionFile()
	local fcmDatas = {};

	local hasUin = false;
	local uin = AccountManager:getUin();

	for i = 1, #(t_fcmDatas) do
		if t_fcmDatas[i].uin == uin then
			hasUin = true;
			if  AccountManager.get_time_since_online then
				t_fcmDatas[i].totalOnlineTime = LastTotalOnlineTime + AccountManager:get_time_since_online();
			else
				t_fcmDatas[i].totalOnlineTime = LastTotalOnlineTime;
			end

			t_fcmDatas[i].saveTime = AccountManager:getSvrTime();
		end
		
		table.insert(fcmDatas, t_fcmDatas[i]);
	end

	if not hasUin then
		local onlineTime = 0;
		if AccountManager.get_time_since_online then
			onlineTime = AccountManager:get_time_since_online();
		end
		table.insert(t_fcmDatas, {uin=uin, totalOnlineTime=onlineTime, totalOfflineTime=0, saveTime=AccountManager:getSvrTime() });
		table.insert(fcmDatas, {uin=uin, totalOnlineTime=onlineTime, totalOfflineTime=0, saveTime=AccountManager:getSvrTime()});
	end

	container:save_to_file("fcm", fcmDatas);

	--[[
	local jsonstr = JSON:encode(fcmDatas);
	gFunc_writeTxtFile("data/antiaddiction.fcm", jsonstr);
	]]
end

function CountOfflineTime()
	-- 【平台能力】将以前代码中的防沉迷累计下线5小时，累计在线时间清零可继续完去掉
	-- 为了方便热更 就直接注释掉该方法的逻辑  code-by：liwentao
	-- local uin = AccountManager:getUin();
	-- for i = 1, #(t_fcmDatas) do
	-- 	if t_fcmDatas[i].uin == uin then
	-- 		local lastOfflineTime = AccountManager:getSvrTime() - t_fcmDatas[i].saveTime;
	-- 		print("kekeke lastOfflineTime", lastOfflineTime);
	-- 		t_fcmDatas[i].totalOfflineTime = t_fcmDatas[i].totalOfflineTime + lastOfflineTime;
	-- 		if t_fcmDatas[i].totalOfflineTime < 0 then	--玩家修改时间 可能会导致离线时长是一个负数
	-- 			t_fcmDatas[i].totalOfflineTime = 0;
	-- 		end

	-- 		if  t_fcmDatas[i].totalOfflineTime > 5*60*60 then	--累计离线时间大于5个小时，数据清0;
	-- 			LastTotalOnlineTime = 0;
	-- 			t_fcmDatas[i].totalOfflineTime = 0;
	-- 		end
	-- 		break;
	-- 	end		
	-- end
end
LoginSuccess = false;
SendPackageTime = 0;
ReceiveRoomPakcageTime = 0;
ReceiveFriendPakcageTime = 0;

function SendPackageForTestOverseasNetworkDelay()
	LoginSuccess = true;
	Log("keke SendPackageForTestOverseasNetworkDelay");
	local roomip = "";
	local friendip = "";
	if CSMgr.getResolveDnsFriendip and CSMgr.getResolveDnsRoomip then
		roomip = CSMgr:getResolveDnsRoomip();
		friendip = CSMgr:getResolveDnsFriendip();
	else
		Log("getResolveDnsFriendip and getResolveDnsRoomip is nil");
	end

	if ClientMgr:getApiId() > 300 and  roomip ~= "" and friendip ~= "" then
		local friend_url = "http://" .. friendip .. ":8280/server/friend?cmd=ping_server";
		local room_url ="http://" .. roomip .. ":8080/server/room?cmd=ping_server";
		SendPackageTime = threadpool:msec();
		ns_http.func.rpc_string_raw(room_url,ReceiveRoomPackageCallback,nil,nil,true);
		ns_http.func.rpc_string_raw(friend_url,ReceiveFriendPackageCallback,nil,nil,true);
		Log("send http request to servers  time=" .. SendPackageTime);
	else
		Log("Send http request failed");
	end
end

function ReceiveRoomPackageCallback(retstr)
	Log("ReceiveRoomPackage");
	local ret = JSON:decode(retstr);
	if ret and ret.result == 0 then
		--成功
		Log("ReceiveRoomPackage Success");
		ReceiveRoomPakcageTime = threadpool:msec();
	else
		Log("ReceiveRoomPackage Failed");
	end
end

function ReceiveFriendPackageCallback(retstr)
	Log("ReceiveFriendPackage");
	local ret = JSON:decode(retstr);
	if ret and ret.result == 0 then
		Log("ReceiveFriendPakcage Success");
		ReceiveFriendPakcageTime = threadpool:msec();
	else
		Log("ReceiveFriendPakcage Failed");
	end
end





function OnLoginAccountSvrSuccess()
	-- print("kekeke OnLoginAccountSvrSuccess");
	if ClientMgr:getApiId() > 300 then
		SendPackageForTestOverseasNetworkDelay();
	end
	--新手引导流程优化，新手引导时不弹出防沉迷
	local guideStep = GetGuideStep()
	print(" OnLoginAccountSvrSuccess() guideStep = "..tostring(guideStep))
	if not getglobal("SelectRoleFrame"):IsShown() then
		if 0 == GetNetworkState() then
			--没网络不用弹
			print("没网络:");
		else
			CheckFcmAccountAudit("OnLoginAccountSvrSuccess");
		end
	else
		CheckFcmAccount = true;
	end
	
	if RunTeamupFun then RunTeamupFun() end
end

function CheckFcmAccountAudit(callScene)
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	-- print("CheckFcmAccountAudit(): ns_data.hasCheckRealNameAuth = ", ns_data.hasCheckRealNameAuth);
	if AccountManager.get_antiaddiction_def then
		local def = AccountManager:get_antiaddiction_def();
		-- print("CheckFcmAccountAudit(): def = ", def);
		if def then
			-- print("CheckFcmAccountAudit(): def.ForceAuth = ", def.ForceAuth);
			-- print("CheckFcmAccountAudit(): def.AntiAddiction = ", def.AntiAddiction);
			-- print("CheckFcmAccountAudit(): def.Auth = ", def.Auth);
			if def.AntiAddiction then
				FcmSwitch = def.AntiAddiction == 1;
			else
				FcmSwitch = true
			end

			if def.Auth then
				RealNameAuthSwitch = def.Auth > 0
			else
				RealNameAuthSwitch = true
			end

			if def.ForceAuth then
				ForceRealNameAuthSwitch = def.ForceAuth == 2
			else
				ForceRealNameAuthSwitch = true
			end
			-- print("CheckFcmAccountAudit", FcmSwitch, RealNameAuthSwitch, ForceRealNameAuthSwitch);
		end
	end

	if not guideStep or guideStep == 0  then 
		UpdateRealNameAuthFrameState(callScene);
	end
	if  isSdkRealName() then
		ClientMgr:setAdult(true);
		FcmSwitch = true;
	else
		UpdateAdultState();
	end

	if not IsAdult then
		if next(t_fcmDatas) == nil then
			LoadAntiAddictionFile();
		end

		CountOfflineTime();
		SaveAntiAddictionFile();
	end

	CountFcmRate();
end

function UpdateRealNameAuthFrameState(callScene)
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	-- print("UpdateRealNameAuthFrameState(): ");
	HideIdentityNameAuthFrame()
	-- print("UpdateRealNameAuthFrameState(): isEducationalVersion = ", isEducationalVersion)
	if isEducationalVersion == false then
		local idCardInfo = AccountManager:idcard_info();
		local state = AccountManager:realname_state()
		-- print("UpdateRealNameAuthFrameState(): idCardInfo = ", idCardInfo);
		-- print("UpdateRealNameAuthFrameState(): RealNameAuthSwitch = ", RealNameAuthSwitch);
		if isSdkRealName() then
			SdkManager:sdkRealNameAuth();
		elseif (state == 0 or state == 2) and RealNameAuthSwitch then
			if callScene then
				--实名弹框埋点记录场景
				if callScene == "LobbyFrame_OnShow" then
					IdentityNameAuthClass:SetStatisticsPopupScene(IdentityNameAuthClass.StatisticsPopupScene.firstIntoArchive)
				elseif callScene == "OnLoginAccountSvrSuccess" then
					IdentityNameAuthClass:SetStatisticsPopupScene(IdentityNameAuthClass.StatisticsPopupScene.firstInGame)
				elseif callScene == "NoviceGuideEndFrameStarBtn_OnClick" then
					IdentityNameAuthClass:SetStatisticsPopupScene(IdentityNameAuthClass.StatisticsPopupScene.noviceGuidanceEnd)
				end
			end
			if callScene == "OnLoginAccountSvrSuccess" then
				DoRealNameAuthWithCheck(function()
					local adsType = RealNameFunc:isShowIdentityNameAuth(1)
					ShowIdentityNameAuthFrame(nil,nil,nil,nil,nil,adsType)
				end)
			elseif callScene == "NoviceGuideEndFrameStarBtn_OnClick"  then
				-- local adsType = RealNameFunc:isShowIdentityNameAuth(14)
				-- ShowIdentityNameAuthFrame(nil,nil,nil,nil,nil,adsType)
			elseif callScene == "LobbyFrame_OnShow" then
				local adsType = RealNameFunc:isShowIdentityNameAuth(2)
				ShowIdentityNameAuthFrame(nil,nil,nil,nil,nil,adsType)
			else
				ShowIdentityNameAuthFrame()
			end

			
		end
	end
end

function UpdateAdultState()
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	local idCardInfo = AccountManager:idcard_info();
	
	-- print("UpdateAdultState() idCardInfo = ", idCardInfo);
	-- print("UpdateAdultState() FcmSwitch = ", FcmSwitch);
	IsAdult = false
	if FcmSwitch then	--防沉迷
		if AccountManager:realname_state() == 1 and idCardInfo and idCardInfo.age and idCardInfo.age >= 18 then	--认证满18岁了
			IsAdult = true;
		end
	else
		IsAdult = true;
	end

	-- print("UpdateAdultState(): IsAdult = ", IsAdult);
	ClientMgr:setAdult(IsAdult);
end

function sdkRealNameCallback(age)
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	-- print("sdkRealNameCallback(): age = ", age);
	if age >=18 then
		IsAdult = true;
		FcmSwitch = false;
	else
		IsAdult = false
	end

	if ClientMgr.setAdult then
		ClientMgr:setAdult(IsAdult);
	end

	CountFcmRate()
	sdkRealNameFlag = true
	-- print("sdkRealNameCallback(): IsAdult = ", IsAdult);
	-- print("sdkRealNameCallback(): FcmSwitch = ", FcmSwitch);
end

function CountFcmRate()
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	-- print("CountFcmRate(): IsAdult = ", IsAdult);
	if not UseTpRealNameAuth() then
		if not IsAdult then	--未成年
			local time = GetTimeOnline();
			-- print("CountFcmRate(): time = ", time);
			if time > 3*60*60 then	--3小时，沉迷状态
				SetFcmRate(0);
			else
				SetFcmRate(100);
			end
		else
			SetFcmRate(100);
		end
	end
end

function GetFcmRate()
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	
	--关闭游戏防沉迷 未成年人玩3个小时 进不去家园果实 的影响
	-- if UseTpRealNameAuth() then
	-- 	return ClientMgr:getFcmRate();
	-- else
	-- 	return FcmRate;
	-- end

	return 100
end

function SetFcmRate(rate)
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	FcmRate = rate;
	ClientMgr:setFcmRate(rate);
end

function GetTimeOnline()
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	if UseTpRealNameAuth() then	
		return ClientMgr:timeAntiaddictionStartup()
	else
		if AccountManager.get_time_since_online then
			local t = LastTotalOnlineTime + AccountManager:get_time_since_online();
			return t;
		else
			return 0;
		end
	end
end

-- 使用渠道的实名认证
function isSdkRealName()
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	-- return ClientMgr:getApiId() == 7
	return false
end
