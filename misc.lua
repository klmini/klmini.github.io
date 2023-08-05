local antiAddictionState = 0;
local LastSaveFileTime = 0;
function UpdateAntiAddiction()  --防沉迷
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());

	if GetTimeOnline == nil then return end

	local t = GetTimeOnline();--ClientMgr:timeAntiaddictionStartup(); 
	local hour = 3600;

	if not UseTpRealNameAuth() then --恒等于true
		if LastSaveFileTime == 0 then
			LastSaveFileTime = os.time();
		end

		if t > 0 and os.time() - LastSaveFileTime > 5 then	--每五秒钟保存一下防沉迷数据
			UpdateAdultState()
			LastSaveFileTime = os.time();
			SaveAntiAddictionFile();

			if isSdkRealName() then
				SdkManager:sdkRealNameAuth();
			end
		end	
	end

	if antiAddictionState == 0 then
		if t > 1*hour then
			ShowAntiAddictionMsg(GetS(3690));
			antiAddictionState = 1;
		end
	elseif antiAddictionState == 1 then
		if t > 2*hour then
			ShowAntiAddictionMsg(GetS(4521));
			antiAddictionState = 2;
		end
	elseif antiAddictionState == 2 then
		if t > 3*hour then
			ShowAntiAddictionMsg(GetS(3691));
			antiAddictionState = 3;
		end
	elseif antiAddictionState == 3 then
		if t > (3*hour + 20) then
			ShowAntiAddictionMsg(GetS(3692));
			antiAddictionState = 4;
			SetFcmRate(0);
		end
	elseif antiAddictionState >= 4 then
		if t > (3*hour + 20 + (antiAddictionState - 3)*15*60 ) then
			ShowAntiAddictionMsg(GetS(3692));
			antiAddictionState = antiAddictionState + 1;
		end
	end
end

function ShowAntiAddictionMsg(msg)
	--屏蔽掉游戏内原来的防沉迷弹框
	do return end
	
	if gIsSingleGame then return end
	--local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	--print(debug.traceback());
	-- print("ShowAntiAddictionMsg(): ");
	local isSdkRealName = isSdkRealName();
	-- print("ShowAntiAddictionMsg(): isSdkRealName = ", isSdkRealName);
	if isSdkRealName then
		SdkManager:sdkRealNameAuth()
		-- print("ShowAntiAddictionMsg(): sdkRealNameFlag = ", sdkRealNameFlag);
		if not sdkRealNameFlag then
			return
		end
	end

	-- print("ShowAntiAddictionMsg(): 2");
	--MessageBox(4, GetS(3693));
	getglobal("AntiAddictMsgFrame"):Show();
	getglobal("AntiAddictMsgFrameDesc"):SetText(msg, 61, 69, 70);
end

function AntiAddictMsgFrameCenterBtn_OnClick()
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	getglobal("AntiAddictMsgFrame"):Hide();
end

function AntiAddictMsgFrame_OnShow()
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	if ClientCurGame and ClientCurGame:isInGame() and not getglobal("AntiAddictMsgFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end
end

function AntiAddictMsgFrame_OnHide()
	-- local print = Android:Localize(Android.SITUATION.REAL_NAME_AUTH);
	-- print(debug.traceback());
	if ClientCurGame and ClientCurGame:isInGame() and not getglobal("AntiAddictMsgFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
end
