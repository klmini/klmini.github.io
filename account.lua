local BeforePlayer = nil;
Not_Active_Value 	= 0;			--不活跃
Active_Value		= 300;			--活跃
Very_Active_Value 	= 600;			--很活跃，能切换帐号的活跃度最小值
RequestCoolDown = 0;				--绑定获取验证码冷却时间
LoginRequestCoolDown = 0;			--登录获取验证妈冷却时间
ResetRequestCoolDown = 0;			--重置密码获取验证妈冷却时间
ResetRequestCoolDown_Email = 0;		--邮箱重置密码获取冷却时间
RequestLodinCoolDown = 0; 			--验证登录重置冷却时间

OpenId = 0;							--手Q的openId

-- 0 bingding mobile, 1 bingding email. -1 bingding nothing.  2解绑手机  3解绑邮箱
BindingType = -1;

DisEnableEdit = false

-- BindingOrUnbound: 1 绑定 、 2 解绑
BindingOrUnbound = 0
PCBindedResult = {
	platform = "",
	bindingOrUnBind = false,
}

function AccountLoginFrameCloseBtn_OnClick()

	local content = getglobal("SecuritySettingContent");
	if content:IsShown() then
		content:Hide();
	end

	local list={
	"AccountLoginFrameLoginContentQ1List",
	"AccountLoginFrameLoginContentQ1ListBkg",
	"AccountLoginFrameLoginContentDropDownBkg"

	}

	for i=1,#list do
		if getglobal(list[i]):IsShown() then
			if i==3 then
				DropDown_OnClick()
			else				
				getglobal(list[i]):Hide()
			end
		end
	end
	getglobal("AccountLoginFrame"):Hide();

	GetInst("UIManager"):Close("QQWeChatLoginPC")
end

--进入激活界面
function AccountLoginFrameActivateBtn_OnClick()
	if AccountManager:isBindAccount() then
		getglobal("ActiveTipsFrame"):Show();
	else
		if ClientMgr:getVersionParamInt("AccEncode", 1) ~= 1 then
			ShowGameTips(GetS(779), 3);
			return;
		end
		AccountLoginFrameCloseBtn_OnClick();
		NewAccountHelper:IntergateSetAccountLoginFrame({
			setType = NewAccountHelper.PASSWORD_SET,
		})

		-- SetAccountLoginFrame(1);
	end
end

function AccountLoginFrameChangePasswordBtn_OnClick()
	if ClientMgr:getVersionParamInt("AccEncode", 1) ~= 1 then
		ShowGameTips(GetS(779), 3);
		return;
	end

	local hasBindedPhone = AccountManager:hasBindedPhone();
	local hasBindedEmail = AccountManager:hasBindedEmail();

	if (IsOverseasVer() or isAbroadEvn()) and 1 ~= hasBindedEmail then
		ShowGameTipsWithoutFilter(GetS(32113))
		AccountSecuritySettingsBtn_OnClick();
		return
	elseif 1 ~= hasBindedPhone and 1 ~= hasBindedEmail then
		ShowGameTipsWithoutFilter(GetS(32113))
		AccountSecuritySettingsBtn_OnClick();
		return
	end

	if 1 == hasBindedPhone and not (IsOverseasVer() or isAbroadEvn()) then
		DisEnableEdit = true 
		AccountLoginFrameResetPW_OnClick();
	elseif 1 == hasBindedEmail then
		DisEnableEdit = true
		AccountLoginFrameEmailResetPW_OnClick();
	end
end

function AccountLoginFrame_OnLoad()
	this:RegisterEvent("GIE_SETACCOUNT_RESULT");
	this:RegisterEvent("GE_SYNC_WORLD_LIST");
	if ClientMgr:getVersionParamInt("SecurityBinding", 1) ~= 1 then
		getglobal("AccountSecuritySettingsBtn"):Hide();
	end

	--LLTODO:切换4399账号按钮
	if ClientMgr:getApiId() == 2 then
		--getglobal("AccountLoginFrameLoginContentChTo4399"):Show();
	end

	if ClientMgr:getApiId() == 999 or get_game_env() == 1 then
		getglobal("AccountLoginFrameLoginContentPasswordEdit"):setMaxChar(12);
		getglobal("ActivateAccountFramePasswordEdit"):setMaxChar(12);
		getglobal("ActivateAccountFrameRepeatPWEdit"):setMaxChar(12);
	else
		getglobal("ActivateAccountFrameRepeatPWEdit"):setMaxChar(12);
		getglobal("ActivateAccountFramePasswordEdit"):setMaxChar(12);
		getglobal("AccountLoginFrameLoginContentPasswordEdit"):setMaxChar(12);
	end

	if ClientMgr:getApiId() == 3 or ClientMgr:getApiId() == 34 then
		getglobal("AccountLoginFrameLoginContentPasswordTitle"):SetText(GetS(1085));
		--getglobal("AccountLoginFrameLoginContentPWSwitchBtnTitle"):SetText(GetS(1122),233,21,21);
	else
		getglobal("AccountLoginFrameLoginContentPasswordTitle"):SetText(GetS(3073));
		--getglobal("AccountLoginFrameLoginContentPWSwitchBtnTitle"):SetText(GetS(9024),233,21,21);
	end

	local list="AccountLoginFrameLoginContentQ1List"
	local listBkg="AccountLoginFrameLoginContentQ1ListBkg"
	local base=38
	local QuestionList={}

	local env_ = get_game_env();
	--Log( "call JumpEnvFrame_OnShow, " .. env_ );
	if  env_==10 then
		QuestionList={GetS(9028),GetS(9029),GetS(9030),GetS(9031),GetS(9032),GetS(9033)}
	else
		QuestionList={GetS(9018),GetS(9019),GetS(9020),GetS(9021),GetS(9022),GetS(9023)}
	end


	for i=1,6 do
		getglobal(list.."Question"..i):SetPoint("top","AccountLoginFrameLoginContentQ1List","top",0,base+(i-1)*51);
		getglobal(list.."Question"..i.."Content"):SetText(QuestionList[i]);
		--getglobal(list..i):Show();
	end

	getglobal(listBkg):SetHeight(348);
	getglobal(list.."Question1Line"):Hide();

	ClientMgr:setGameData("LoginMethod",0)



end

function HideAccountRelevantFrame()
	local t = {
				"HomeChestFrame",
				"CreateWorldFrame",
				"AdvancedSetFrame",
				"ChooseModsFrame",
				"CreateWorldRuleFrame",
				"MiniWorksFrame",
				"MultiplayerLobbyFrame",
				"MyModsFrame",
				"MyModsEditorFrame",
				"RoomFrame",
				"CreateRoomFrame",
				"SingleEditorFrame",
				"PlayerCenterFrame",
			}
	for i=1, #(t) do
		local frame = getglobal(t[i]);
		if frame and frame:IsShown() then
			frame:Hide();
		end
	end
end

function AccountLoginFrame_OnEvent()

	if arg1 == "GIE_SETACCOUNT_RESULT" then
		print("AccountLoginFrame_OnEvent GIE_SETACCOUNT_RESULT");
		LoginManager:GIE_SETACCOUNT_RESULT(true)
	elseif arg1 == "GE_SYNC_WORLD_LIST" then
		--local ge = GameEventQue:getCurEvent();
		--local uin = ge.body.syncworldlist.uin;
		--ReqSyncWorldListFromServer(uin);
	end
end

function AccountLoginFrame_OnShow()
	g_open_accountmanagerui_source = 0
	if IsUIFrameShown("LoginScreenFrame") then
		g_open_accountmanagerui_source = 3
	else
		g_open_accountmanagerui_source = 1
	end
	getglobal("AccountLoginFrameMini"):SetText(GetMyUin());

	local activateBtn = getglobal("AccountLoginFrameActivateBtn");
	local changePasswordBtn = getglobal("AccountLoginFrameChangePasswordBtn");
	local normal = getglobal("AccountLoginFrameActivateBtnNormal");
	local activateBtnText = getglobal("AccountLoginFrameActivateBtnText");
	if AccountManager:isBindAccount() then
		--LLTODO:隐藏
		activateBtn:Hide();
		changePasswordBtn:Show();
		--[[
		local active = AccountManager:getActive();
		local level = 1;
		if active >= 800 then
			level = 9;
		elseif active >= 700 then
			level = 8;
		elseif active >= 600 then
			level = 7;
		elseif active >= 500 then
			level = 6;
		elseif active >= 400 then
			level = 5;
		elseif active >= 300 then
			level = 4;
		elseif active >= 200 then
			level = 3;
		elseif active >= 100 then
			level = 2;
		else
			level = 1;
		end
		activateBtnText:SetText(GetS(350)..level);	
		--]]
	else
		changePasswordBtn:Hide();
		activateBtn:Show();
		if ClientMgr:getApiId() == 3 or ClientMgr:getApiId() == 34 then
			activateBtnText:SetText(GetS(1080));
		else
			activateBtnText:SetText(GetS(3071));
		end
	end

	getglobal("AccountLoginFrameLoginContent"):Hide();
	SetArchiveDealMsg(false);

	getglobal("AccountLoginFrameTipsTxt"):SetText(GetS(32112), 73, 70, 63)

	--LLDO:启动页面打开特殊处理
	LoginScreenFrameSetSwitchUserFrame();

	--LLDO:保护模式Facebook按钮置灰
	--ProtectModeFBBtnSetGray();

	--[[
	if ClientMgr:getGameData("LoginMethod")==0 then
		getglobal("AccountLoginFrameLoginContentPWSwitchBtnTitle"):SetText(GetS(9024))
	else
		getglobal("AccountLoginFrameLoginContentPWSwitchBtnTitle"):SetText(GetS(9025))
	end
	]]--

	if HasUIFrame("IdentityNameAuth") and getglobal("IdentityNameAuth"):IsShown() then
		UIFrameMgr:BringFrameAboveFrame("AccountLoginFrame","IdentityNameAuth");
	end
end

function AccountLoginFrame_OnHide()	
	local content = getglobal("AccountLoginFrameLoginContent");
	local miniEdit = getglobal(content:GetName().."MiniEdit");
	local passwordEdit = getglobal(content:GetName().."PasswordEdit");
	local MiniOrEmailEdit = getglobal("AccountLoginFrameLoginContentMiniOrEmailEdit");
	local answer=getglobal("AccountLoginFrameLoginContentStrAnswer")
	local question=getglobal("AccountLoginFrameLoginContentQ1Content")

	

	question:SetTextColor(185,185,185)
	question:SetText(GetS(9016))
	answer:Clear()
	miniEdit:Clear();
	passwordEdit:Clear();
	content:Hide();
	MiniOrEmailEdit:Clear();

	SetArchiveDealMsg(true);

	g_open_accountmanagerui_source = 0
	g_from_activity_ui_open_account_manager_ui = 0
end

function AccountLoginFrameMiniEdit_OnEnterPressed()
	SetCurEditBox("AccountLoginFrameLoginContentPasswordEdit");
end

function AccountLoginFrameMiniEdit_OnTabPressed()
	SetCurEditBox("AccountLoginFrameLoginContentPasswordEdit");
end

function AccountLoginFramePasswordEdit_OnEnterPressed()
	AccountLoginFrameLoginBtn_OnClick();
end

--重设密码
function AccountLoginFrameResetPW_OnClick()
	getglobal("AccountLoginFrame"):Hide();
	ShowPhoneValidateFrame(2);
end

--luoshun 邮箱找回密码
function AccountLoginFrameEmailResetPW_OnClick()
	getglobal("AccountLoginFrame"):Hide();
	ShowEmailValidateFrame(3);
end

--LLTODO:切换4399账号
function AccountLoginFrameChTo4399_OnClick()
	--打开4399账号验证面板
	--[[
	getglobal("Check4399AccountFrame"):Show();
	getglobal("AccountLoginFrame"):Hide();
	]]

	--绑定了, 切换4399账号
	TP4399LoginType = 3;
	SdkManager:sdkSwitch();
	getglobal("AccountLoginFrame"):Hide();

	--LLTEST：模拟调用
	--LoginResult4399(1, 1234567, 0, "test");
end

function AccountLoginFramePasswordEdit_OnTabPressed()
	SetCurEditBox("AccountLoginFrameLoginContentMiniEdit");
end

--登录二级确定
function AccountLoginFrameLoginBtn_OnClick()
	DestructFacebookAccountInfo();

	local content = getglobal("AccountLoginFrameLoginContent");
	local passwordEdit = getglobal(content:GetName().."PasswordEdit");

	local function checkHistoryInside(uin)
		if not uin then return false end
		local accountHistories = AccountManager:get_account_history_list();
		if not accountHistories or #accountHistories <= 0 then return false end
		local length = #accountHistories
		uin = tonumber(uin)
		for i=1, length do 
			if uin == accountHistories[i].Uin then return true end
		end
		return false
	end

	--如果是密码格式，要读取明文的内容
	local password = NewAccountHelper:GetEditBoxText(passwordEdit)
	local question = getglobal("AccountLoginFrameLoginContentQ1Content"):GetText()
	local answerEdit = getglobal("AccountLoginFrameLoginContentStrAnswer")
	local answer = NewAccountHelper:GetEditBoxText(answerEdit)
	if ClientMgr:getApiId() < 300 then
		local miniEdit = getglobal(content:GetName().."MiniEdit");
		local mini = miniEdit:GetText();

		if mini == "" then
			ShowGameTips(GetS(3104), 3);
			return;
		end
		if ClientMgr:getGameData("LoginMethod")==0 then
			if password == "" then
				ShowGameTips(GetS(3105), 3);
				return;
			elseif password == "0" and checkHistoryInside(mini) == false then
				ShowGameTips(GetS(9035))
				return;
			end
		else
			if question=="" then
				ShowGameTips(GetS(9016),3)
				return;
			end
			if 	answer=="" then
				ShowGameTips(GetS(9017),3)
				return;
			end
		end
	else
		local miniOrEmailEdit = getglobal(content:GetName().."MiniOrEmailEdit");
		local miniOrEmail = miniOrEmailEdit:GetText();

		if not (CheckMinihaoValid(miniOrEmail) or CheckEmailValid(miniOrEmail)) then
			ShowGameTips(GetS(6561), 3);
			return;
		end

		if ClientMgr:getGameData("LoginMethod")==0 then
			if password == "" then
				ShowGameTips(GetS(3105), 3);
				return;
			elseif password == "0" and checkHistoryInside(miniOrEmail) == false then
				ShowGameTips(GetS(9035))
				return;
			end
		else
			if question=="" then
				ShowGameTips(GetS(9016),3)
				return;
			end
			if 	answer=="" then
				ShowGameTips(GetS(9017),3)
				return;
			end
		end
	end


	MessageBox(7, GetS(218));
	getglobal("MessageBoxFrame"):SetClientString( "切换帐号二级确定" );
end

--文字问题id与题目匹配
function questionID_switch(question)
	local switch = {}
	local questionID=0;
	local env_ = get_game_env();
	--Log( "call JumpEnvFrame_OnShow, " .. env_ );
	if  env_==10 then
		switch = {
	     [GetS(9028)] = function()    -- for case 1
	         questionID=9028
	     end,
	     [GetS(9029)] = function()    -- for case 2
	         questionID=9029
	     end,
	     [GetS(9030)] = function()    -- for case 3
	         questionID=9030
	     end,
	     [GetS(9031)] = function()    -- for case 4
	         questionID=9031
	     end,
	     [GetS(9032)] = function()    -- for case 5
	         questionID=9032
	     end,
	     [GetS(9033)] = function()    -- for case 6
	         questionID=9033
	     end
	 }
	else
		switch = {
	     [GetS(9018)] = function()    -- for case 1
	         questionID=9018
	     end,
	     [GetS(9019)] = function()    -- for case 2
	         questionID=9019
	     end,
	     [GetS(9020)] = function()    -- for case 3
	         questionID=9020
	     end,
	     [GetS(9021)] = function()    -- for case 4
	         questionID=9021
	     end,
	     [GetS(9022)] = function()    -- for case 5
	         questionID=9022
	     end,
	     [GetS(9023)] = function()    -- for case 6
	         questionID=9023
	     end
	 }
	end

	local question_switch=switch[question]

	if question_switch then
		question_switch()
	end

	return questionID;
end
--登录  -- 未使用
function LoginAccount()
	local content = getglobal("AccountLoginFrameLoginContent");
	local passwordEdit = getglobal(content:GetName().."PasswordEdit");
	--如果是密码格式，要读取明文的内容
	local password = NewAccountHelper:GetEditBoxText(passwordEdit)
	local question = getglobal("AccountLoginFrameLoginContentQ1Content"):GetText()
	local answerEdit = getglobal("AccountLoginFrameLoginContentStrAnswer")
	local answer = NewAccountHelper:GetEditBoxText(answerEdit)

	local questionID=0;
	questionID=questionID_switch(question);


	if ClientMgr:getApiId() < 300 then
		local miniEdit = getglobal(content:GetName().."MiniEdit");
		local mini = miniEdit:GetText();
		if ClientMgr:getGameData("LoginMethod")==0 then
			RequestLoginAccount(mini, password, "");
		else
			RequestLoginAccount1(mini,questionID,answer,"");
		end
	else
		local miniOrEmailEdit = getglobal(content:GetName().."MiniOrEmailEdit");
		local miniOrEmail = miniOrEmailEdit:GetText();
		if ClientMgr:getGameData("LoginMethod")==0 then
			RequestLoginAccount(miniOrEmail, password, "");
		else
			RequestLoginAccount1(miniOrEmail,questionID,answer,"");
		end
	end
end

function RequestLoginAccount1(mini,questionID,answer,code)
	if questionID==0 then
		Log("questionID:"..questionID)
		return
	end

	Log("RequestLoginAccount1:");
	BeforePlayer = GetPlayer2Model();
	--ShowLoadLoopFrame(true)

	if CheckMinihaoValid(mini) then
		mini = getLongUin(mini);
	end

	if AccountManager.question_login and AccountManager:requestEnterGame2New() then

		local result,errorcode = AccountManager:question_login(tonumber(mini),tostring(questionID),tostring(answer))
		print("eddor:",errorcode)
		ShowLoadLoopFrame(false)
		if errorcode and errorcode == ErrorCode.OK then 
			AccountManager:enterGame2New();
        	AccountManager:accountDirty();
        	getglobal("LoginScreenFrame"):Hide();
		elseif errorcode then
			if t_ErrorCodeToString.IsValidCode and t_ErrorCodeToString:IsValidCode(errorcode) then
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[errorcode]), 3)
			else
				ShowGameTips(GetS(3271), 3);
			end
		end
		
		if not result then
    	Log("RequestLoginAccount:result = false");
       		
       		if errorcode and errorcode == ErrorCode.QUESTION_NOT_MATCH then if ShowSwitchEnvAndMailFrame then ShowSwitchEnvAndMailFrame(1)  ShowGameTips(GetS(3115)) end end 
       		if errorcode and errorcode == ErrorCode.ACCOUNT_UIN_NOT_EXIST then if ShowSwitchEnvAndMailFrame then ShowSwitchEnvAndMailFrame(2); end end 
       		if errorcode and errorcode == ErrorCode.ACCOUNT_DB_NOT_FOUND then if ShowSwitchEnvAndMailFrame then ShowSwitchEnvAndMailFrame(2); end end 
   		end 

   		ShowLoadLoopFrame(false)

		--if errorcode and errorcode == ErrorCode.QUESTION_NOT_MATCH then if ShowSwitchEnvAndMailFrame then ShowSwitchEnvAndMailFrame(1); end end 
       -- if errorcode and errorcode == ErrorCode.ACCOUNT_UIN_NOT_EXIST then if ShowSwitchEnvAndMailFrame then ShowSwitchEnvAndMailFrame(2); end end 

	end
end



function RequestLoginAccount(mini, password, code)
	Log("RequestLoginAccount:");
		
	BeforePlayer = GetPlayer2Model();
	ShowLoadLoopFrame(true, "file:account -- func:RequestLoginAccount")
	
	if CheckMinihaoValid(mini) then
		mini = getLongUin(mini);
	end
	-- 账号密码触发了登录

    if LoginManager:DebounceLogin() then
        return 
    end

	LoginManager:LogRequestReport()
	if LoginManager:InnerLoginPreDoing() then
	    local result, errorcode, msg = AccountManager:setAccountPasswd(mini, password, code)

	    Log("RequestLoginAccount:1111");
	    if errorcode and errorcode == ErrorCode.OK then 
			LoginManager:LogSuccessReport()
			LoginManager:InnerLoginLogic(msg)
		end

	    if not result then
	    	Log("RequestLoginAccount:result = false");
			HideNoTransparentLoadLoop()
			LoginManager:LogFailReport(errorcode and tostring(errorcode) or nil)

	        if errorcode and (errorcode == ErrorCode.ACCOUNT_PASSWD_NOT_OK or errorcode == ErrorCode.ACCOUNT_AUTHINFO_NOT_OK) then 
				-- 账号升级优化弹出重新输入框
				if GetInst("AccountSysConfig"):GetFailLoginUiPopStatus() then
					if OpenAlertFailLoginPopDlg then
						OpenAlertFailLoginPopDlg("password", {"password", "question"}, mini)
					end
				else
					if ShowSwitchEnvAndMailFrame then 
						ShowSwitchEnvAndMailFrame(1); 
					end 
				end
			elseif errorcode and errorcode == ErrorCode.ACCOUNT_UIN_NOT_EXIST then 
				if ShowSwitchEnvAndMailFrame then 
					ShowSwitchEnvAndMailFrame(2); 
				end
			end
	    end 

	end
    --[[
	if not AccountManager:setAccountPasswd(mini, password, code) then
		ShowLoadLoopFrame(false)

		--LLDO:尝试切换服务器
		--Log("RequestLoginAccount: code = " .. code);
        --ShowSwitchEnvAndMailFrame(2);
        --功能挪到:setAccountPasswd()函数中.
	end]]
end
----------------------------------ActivateAccountFrame----------------------------
--保存密码到本地文件
local m_AccountPassword = 0;
local m_AccountStrQuestion1="";
local m_AccountStrQuestion2="";
local m_AccountStrAnswer1="";
local m_AccountStrAnswer2="";
function SavePassword2File(uin,bindNickName)
	Log("SavePassword2File: m_AccountPassword = " .. m_AccountPassword);
	local uin = uin or GetMyUin();
	local nickName = bindNickName or AccountManager:getNickName();
	local digital_pw=GetS(3073)
	local str_q1=GetS(9027).."1"
	local str_q2=GetS(9027).."2"
	local str_a=GetS(9026)

	if ClientMgr:isPC() then
		Log("111");
		local prefix = ClientMgr:GetPCDesktopDir();

		if prefix then
			local fileName = "MiniPassword" --uin .. "_Password";
			local title = nickName .. GetS(9167);
			local path = prefix .. "/"  .. fileName .. ".txt";
			local content = title .. "\n" .. GetS(4484) .. ": " .. uin .. "\n" .. digital_pw .. ": " .. m_AccountPassword.."\n"..str_q1..": "..m_AccountStrQuestion1.."\n"..str_a..": "..m_AccountStrAnswer1.."\n"..str_q2..": "..m_AccountStrQuestion2.."\n"..str_a..": "..m_AccountStrAnswer2;


			Log("path = " .. path .. ", content = " .. content);

			local ff = io.open(path, 'w+')
		    if ff then 
		    	Log("OK");
		        ff:write(content);
		        ff:close();

	        	--提示保存成功
				MessageBox(4, GetS(9165));
		    end
		end
		
	    getglobal("ActivateAccountFrame"):Hide();
	else
		Log("222");
		if not IsIosPlatform() then
			--Android平台
			Log("333");
			SetSnapshottypeValue(100);
			local title = nickName .. GetS(9167);
			local content = title .. "\n" .. GetS(4484) .. ": " .. uin .. "\n" .. digital_pw .. ": " .. m_AccountPassword.."\n"..str_q1..": "..m_AccountStrQuestion1.."\n"..str_a..": "..m_AccountStrAnswer1.."\n"..str_q2..": "..m_AccountStrQuestion2.."\n"..str_a..": "..m_AccountStrAnswer2;
			ClientMgr:clickCopy(content);
			SnapshotForShare:requestSaveSnapshot();
		end
	end
end

local ActivateAccountType = 1;	--1设置密码 2重设密码（手机）  3 邮箱设置密码
local ActivateAccountCode = ""; --重设密码所需的验证码

function ActivateAccountFrameCloseBtn_OnClick()
	--LLTODO:官网PC, 没有设置密码不能关闭设置密码窗口
	if NewAccountHelper:IsForceAccountSetPassword() then
		--设置密码按钮设为不可用
		getglobal("ActivateAccountFrameActivateBtn"):Disable();
		getglobal("ActivateAccountFrameActivateBtnNormal"):SetGray(true);
		getglobal("ActivateAccountFrameCloseBtn"):Hide();
		return;
	end

	local list={
	{"ActivateAccountFrameQ1List","ActivateAccountFrameQ1ListBkg"},
	{"ActivateAccountFrameQ2List","ActivateAccountFrameQ2ListBkg"},
	{"ActivateAccountFrameStrA1Bkg","ActivateAccountFrameStrA1"},
	{"ActivateAccountFrameStrA2Bkg","ActivateAccountFrameStrA2"}
	}

	for i=1,#list do
		if getglobal(list[i][1]):IsShown() then
			getglobal(list[i][1]):Hide()
			getglobal(list[i][2]):Hide()
		end
	end

	
	getglobal("ActivateAccountFrame"):Hide();
end

function ActivateAccountFramePasswordTips_OnMouseDown()
	local tipsTem = getglobal("TipsTemplate")
	local tipsTemText = getglobal("TipsTemplateText")
	tipsTemText:SetText(GetS(32114))
	tipsTem:Show()
	tipsTem:SetPoint("topright", "ActivateAccountFramePasswordTitle", "bottomright", 0, 0)
end

function ActivateAccountFramePasswordTips_OnMouseUp()
	getglobal("TipsTemplate"):Hide()
end

function ActivateAccountFrameStrQ1Title_OnMouseDown()
	local tipsTem = getglobal("TipsTemplate")
	local tipsTemText = getglobal("TipsTemplateText")
	tipsTemText:SetText(GetS(32115))
	tipsTem:Show()
	tipsTem:SetPoint("topright", "ActivateAccountFrameStrQ1Title", "bottomright", 0, 0)
end

function ActivateAccountFrameStrQ1Title_OnMouseUp()
	getglobal("TipsTemplate"):Hide()
end

function ActivateAccountFrameQ2Title_OnMouseDown()
	local tipsTem = getglobal("TipsTemplate")
	local tipsTemText = getglobal("TipsTemplateText")
	tipsTemText:SetText(GetS(32115))
	tipsTem:Show()
	tipsTem:SetPoint("topright", "ActivateAccountFrameStrQ2Title", "bottomright", 0, 0)
end

function ActivateAccountFrameQ2Title_OnMouseUp()
	getglobal("TipsTemplate"):Hide()
end

--激活
function ActivateAccountFrameActivateBtn_OnClick()

	local netState = ClientMgr:getNetworkState();
	
	if netState ==  0 then
		ShowGameTips(GetS(161), 3);
		return; 
	end

	local edit = getglobal("ActivateAccountFramePasswordEdit"); 
	local password = NewAccountHelper:GetEditBoxText(edit)
	
	local havenum = false;
	local haveyinwen = false;
	local havefuhao = false;
	local havecount = 0;
	for i=1,#password do
		local charcode = tonumber(string.byte(password, i, i));
		if charcode >= 48 and charcode <= 57 then
			havenum = true;
		elseif (charcode >= 65 and charcode <= 90) or (charcode >= 97 and charcode <= 122) then 
			haveyinwen = true;
		elseif charcode~= 32 and charcode < 127 then
			havefuhao = true;
		else
			havecount = -5;
			break;
		end
	end
	if havenum then
		havecount = havecount + 1;
	end
	if haveyinwen then
		havecount = havecount + 1;
	end
	if havefuhao then
		havecount = havecount + 1;
	end
	
	if havecount < 0 then
		ShowGameTips(GetS(32124));
		return;
	end
		
	if password and (#password < 8 or #password > 12 or havecount < 2) then 
		ShowGameTips(GetS(32111));
		return;
	end
	m_AccountPassword = password;

	local question1=getglobal("ActivateAccountFrameQ1Content"):GetText();
	local question2=getglobal("ActivateAccountFrameQ2Content"):GetText();
	local answer1= NewAccountHelper:GetEditBoxText(getglobal("ActivateAccountFrameStrA1"))
	local answer2= NewAccountHelper:GetEditBoxText(getglobal("ActivateAccountFrameStrA2"))

	-- 修改密码问题不做校验
	-- if answer1~=DefMgr:filterString(answer1, false) then
	-- 	ShowGameTips(GetS(121))
	-- 	return
	-- end

	-- if answer2~=DefMgr:filterString(answer2, false) then
	-- 	ShowGameTips(GetS(121))
	-- 	return
	-- end

	m_AccountStrQuestion1=question1;
	m_AccountStrQuestion2=question2;
	m_AccountStrAnswer1=answer1;
	m_AccountStrAnswer2=answer2;

	local question1ID=0;
	local question2ID=0;
	question1ID=questionID_switch(question1)
	question2ID=questionID_switch(question2)

	local uin = tonumber( getglobal("ActivateAccountFrameMini"):GetText() );
	
	if ActivateAccountType == 1 then
		ActivateAccountCode = "";
	end  

	uin = getLongUin(uin);
	local result,bindNickName
	if ActivateAccountType == 3 then
        if question1ID ~= 0 and question2ID ~= 0 then 
			print("reset_passwd_by_email0");
            result,bindNickName = AccountManager:reset_passwd_by_email(uin, password, ActivateAccountCode, {{1, tostring(question1ID), tostring(answer1)}, {2, tostring(question2ID), tostring(answer2)}});
        else
            result,bindNickName = AccountManager:reset_passwd_by_email(uin, password, ActivateAccountCode);
        end 
    elseif ActivateAccountType == 2 then
        --{{{ 使用手机重置密码
        if question1ID ~= 0 and question2ID ~= 0 then 
            result,bindNickName = AccountManager:bindAccount(uin, password, ActivateAccountCode, {{1, tostring(question1ID), tostring(answer1)}, {2, tostring(question2ID), tostring(answer2)}});
        else
            result,bindNickName = AccountManager:bindAccount(uin, password, ActivateAccountCode);
        end
        --}}}
	else
		if AccountManager.auth_set and question1ID~=0 and question2ID~=0 then
			result = AccountManager:auth_set({
				{0,password},
				{1,tostring(question1ID),tostring(answer1)},
				{2,tostring(question2ID),tostring(answer2)}
				})
			Log("q1"..question1ID.."   "..question2ID)
			--AccountManager:question_set(1,tostring(question1ID),tostring(answer1))
			--AccountManager:question_set(2,tostring(question2ID),tostring(answer2))
			getglobal("LobbyFrameAccountBtn"):Hide();
		end
	end
	
	--print("reset_passwd_by_emai result:"..tostring(result));
	local text = ""
	if result == -1 then
		return;
	elseif result == 0 then
		text = GetS(3103);	
		--[[
		local accountBtnName = getglobal("LobbyFrameAccountBtnName");
		if AccountManager:isBindAccount() then
			accountBtnName:SetText(StringDefCsv:get(3131));
		else
			accountBtnName:SetText(StringDefCsv:get(3077));
		end
		]]
	elseif result == 1 then
		text = GetS(3107);
	elseif result == 2 then
		text = GetS(3108);
	elseif result == 3 then
		text = GetS(3109);
	elseif result == 4 then
		text = GetS(3110);
	elseif result == 5 then
		text = GetS(3111);
	elseif result == 6 then
		text = GetS(3112);
	elseif result == 7 then
		text = GetS(3113);
	else
		--LLTODO:官网PC,110
		if ClientMgr:getApiId() == 110 and AccountManager:isBindAccount() then
			text = GetS(3103);	
			getglobal("ActivateAccountFrame"):Hide();
		end
	end
	ShowGameTips(text, 3);
	--{{弹窗, 是否保存密码到本地
	if 0 == result then
		if ClientMgr:isPC() then
			--PC端逻辑在保存窗口出来之前就将密码界面隐藏，android则是在保存窗口且截完图再关闭密码框，不然截不到密码。
			getglobal("ActivateAccountFrame"):Hide();
			print(" reset  passwd ok  111");
			local function callback(btnName)
				if btnName == "right" then 
					SavePassword2File(uin,bindNickName)
					if uin ~= AccountManager:getUin() then 
						ShowGameTipsWithoutFilter(GetS(32128))
					end 
					--保存修改过密码的迷你号到micro_account.txt给微端判定游客登录后有没有修改密码
					local save_profile_dir = ClientMgr:getDataDir() .. "data/account"
					if save_profile_dir then
						local fileName = "micro_account"
						local content = uin .. "\n"
						local path = save_profile_dir .. "/" .. fileName .. ".txt"
						Log("path = " .. path .. ", content = " .. content)
						local mf = io.open(path,'a')
						if mf then
							Log("----OK----")
							mf:write(content)
							mf:close();
						end
					end
				else
					getglobal("ActivateAccountFrame"):Hide();	--截完图在关闭密码框, 不然就截不到密码了.
					getglobal("MessageBoxFrame"):Hide();
				end 
			end 
			MessageBox(24, GetS(9163),callback);
			--getglobal("MessageBoxFrame"):SetClientString( "保存密码到本地" );
		else
			print(" reset  passwd ok 222");
			if not IsIosPlatform() then
				--Android平台
				if not MINIW__CheckHasPermission(DevicePermission_WriteExternalStorage) then
					MessageBox(24, GetS(9164));
				else --如果没有权限则保存到剪贴板
					MessageBox(24, "缺少相册访问权限，无法存储。您可复制并粘贴密码到安全位置");
				end
					getglobal("MessageBoxFrame"):SetClientString( "保存密码到本地" );
			end
		end
	end
	--}}

	ShowPhtoneBindingAwardFrame()
end

function ActivateAccountFramePasswordEdit_OnFocusLost()
	local edit1 = getglobal("ActivateAccountFramePasswordEdit");
	local edit2 = getglobal("ActivateAccountFrameRepeatPWEdit");
	local password1 = NewAccountHelper:GetEditBoxText(edit1)
	local password2 = NewAccountHelper:GetEditBoxText(edit2)
	local passRult = getglobal("ActivateAccountFramePasswordRult") 
	
	local index, textID = CheckPasswordStandard(password1)
	passRult:SetText(GetS(textID))

	CheckActivatePassWord(password1, password2);
end

--[[校验密码是否符合标准]]
function CheckPasswordStandard(password)
    local havenum = false;
    local haveyinwenb = false;
    local haveyinwend = false;
    local havefuhao = false;
    local havecount = 0;
    for i=1,#password do
        local charcode = tonumber(string.byte(password, i, i));
        if charcode >= 48 and charcode <= 57 then
            havenum = true;
        elseif (charcode >= 65 and charcode <= 90) then
            haveyinwenb = true;
        elseif (charcode >= 97 and charcode <= 122) then 
        	haveyinwend = true;
        elseif charcode~= 32 and charcode < 127 then
            havefuhao = true;
        else
            havecount = -5;
            break;
        end
    end

    if havenum then
        havecount = havecount + 1;
    end

    if haveyinwenb then
        havecount = havecount + 1;
    end
    
    if haveyinwend then
    	havecount = havecount + 1;
    end

    if havefuhao then
        havecount = havecount + 1;
    end

    -- local passRult = getglobal("ActivateAccountFramePasswordRult")   

	if #password <= 0 then
		-- passRult:SetText(GetS(32116))
		return 1, 32116
	end

	--少于两种字符类型
	if (havecount < 3 and haveyinwenb and haveyinwend) or havecount < 2 then
		-- passRult:SetText(GetS(32117))
		return 2, 32117
	end

	--小于8位
	if #password < 8 then
		-- passRult:SetText(GetS(32117))
		return 3, 32117
	end

	if password and #password >= 8 and #password <= 12 and havecount >= 2 then  
	    --符合条件
	    if havecount == 2 then
			return 0, 32118
			-- passRult:SetText(GetS(32118))
	    else
			return 0, 32119
			-- passRult:SetText(GetS(32119))
	    end
	end
end

function ActivateAccountFrameRepeatPWEdit_OnFocusLost()
	local edit1 = getglobal("ActivateAccountFramePasswordEdit");
	local edit2 = getglobal("ActivateAccountFrameRepeatPWEdit");	

	local password1 = NewAccountHelper:GetEditBoxText(edit1)
	local password2 = NewAccountHelper:GetEditBoxText(edit2)
	CheckActivatePassWord(password1, password2);
end

function ActivateAccountFramePasswordEdit_OnEnterPressed()
	SetCurEditBox("ActivateAccountFrameRepeatPWEdit");
end

function ActivateAccountFramePasswordEdit_OnTabPressed()
	SetCurEditBox("ActivateAccountFrameRepeatPWEdit");
end

function ActivateAccountFramePasswordEdit_OnUpdate()
	local password = NewAccountHelper:GetEditBoxText(getglobal("ActivateAccountFramePasswordEdit"))
	if password~="" then
		getglobal("ActivateAccountFrameRepeatPWEdit"):Show();
		getglobal("ActivateAccountFrameRepeatPWEditBkg"):Show();
	else
		getglobal("ActivateAccountFrameRepeatPWEdit"):Hide();
		getglobal("ActivateAccountFrameRepeatPWEditBkg"):Hide();
	end
end


function ActivateAccountFrameRepeatPWEdit_OnEnterPressed()
	--[[local edit1 = getglobal("ActivateAccountFramePasswordEdit");
	local edit2 = getglobal("ActivateAccountFrameRepeatPWEdit");	

	local password1 = edit1:GetText();
	local password2 = edit2:GetText();
	if password1 == password2 then
		ActivateAccountFrameActivateBtn_OnClick();
	else
		SetCurEditBox("ActivateAccountFrameRepeatPWEdit");
	end]]--
end

function ActivateAccountFrameRepeatPWEdit_OnTabPressed()
	SetCurEditBox("ActivateAccountFrameStrA1");
end

function ActivateAccountFrameRepeatPWEdit_OnHide( ... )
	
	
	getglobal("ActivateAccountFrameRepeatPWEdit"):Clear();
	getglobal("ActivateAccountFrameTips2"):Hide();

end

function ActivateAccountFrameRepeatPWEdit_OnFinishChar()
	local edit1 = getglobal("ActivateAccountFramePasswordEdit");
	local edit2 = getglobal("ActivateAccountFrameRepeatPWEdit");	

	local password1 = NewAccountHelper:GetEditBoxText(edit1)
	local password2 = NewAccountHelper:GetEditBoxText(edit2)
	CheckActivatePassWord(password1, password2);
end

function CheckActivatePassWord(password1, password2)
	local tips = getglobal("ActivateAccountFrameTips2");
	local tips1 = getglobal("ActivateAccountFrameTips3");
	local tips2 = getglobal("ActivateAccountFrameTips4");
	local StrA1=getglobal("ActivateAccountFrameStrA1"):GetText()
	local StrA2=getglobal("ActivateAccountFrameStrA2"):GetText()
	local StrQ1=getglobal("ActivateAccountFrameQ1Content"):GetText()
	local StrQ2=getglobal("ActivateAccountFrameQ2Content"):GetText()
	tips1:Hide();
	tips2:Hide();
	if password1~="" and password2~="" and password1 == password2  and #password1 >= 8 then
		tips:Hide();
		if  StrA1~="" and StrA2~="" and StrQ1~=GetS(9016) and StrQ2~=GetS(9016)  and #StrA1 >= 8 and #StrA2 >= 8 then
			getglobal("ActivateAccountFrameActivateBtn"):Enable();
			getglobal("ActivateAccountFrameActivateBtnNormal"):SetGray(false);
		else
			getglobal("ActivateAccountFrameActivateBtn"):Disable();
			getglobal("ActivateAccountFrameActivateBtnNormal"):SetGray(true);
		end
	else
		getglobal("ActivateAccountFrameActivateBtn"):Disable();
		getglobal("ActivateAccountFrameActivateBtnNormal"):SetGray(true);
		if password2 ~= "" then
			tips:Show();
		else
			tips:Hide();
		end
		if password1~="" and password2~="" and password1 == password2 and #password1 < 8 then
			tips:SetText(GetS(32120));
		else
			tips:SetText(GetS(3102));
		end
	end
	if #StrA1 < 8 and getglobal("ActivateAccountFrameStrA1"):IsShown() then		
		tips1:Show();
	end
	if #StrA2 < 8 and getglobal("ActivateAccountFrameStrA2"):IsShown() then		
	   tips2:Show();
	end
end

function ActivateAccountFrame_OnLoad()
	local apiId = ClientMgr:getApiId();
	if apiId == 3 or apiId == 34 then
		getglobal("ActivateAccountFrameTitleFrameTitle"):SetText(GetS(1080));
		getglobal("ActivateAccountFrameStrQ1Title"):SetText(GetS(1121).."1");
		getglobal("ActivateAccountFrameStrQ2Title"):SetText(GetS(1121).."2");
		--getglobal("ActivateAccountFrameRepeatPWTitle"):SetText(GetS(1082));
		getglobal("ActivateAccountFrameTitleFrameTips1"):SetText(GetS(1083));
		getglobal("ActivateAccountFrameTips2"):SetText(GetS(1086));
	else
		getglobal("ActivateAccountFrameTitleFrameTitle"):SetText(GetS(3071));
		getglobal("ActivateAccountFrameStrQ1Title"):SetText(GetS(9015).."1");
		getglobal("ActivateAccountFrameStrQ2Title"):SetText(GetS(9015).."2")
		--getglobal("ActivateAccountFrameRepeatPWTitle"):SetText(GetS(3076));
		getglobal("ActivateAccountFrameTitleFrameTips1"):SetText(GetS(3101));
		getglobal("ActivateAccountFrameTips2"):SetText(GetS(3102));
	end

	StrQuestionList_OnLoad(1)
	StrQuestionList_OnLoad(2)



end

function StrQuestionList_OnLoad(index)
	

	local list="ActivateAccountFrameQ"..index.."ListQuestion"
	local listBkg="ActivateAccountFrameQ"..index.."ListBkg"
	local base=38
	local QuestionList={}

	local env_ = get_game_env();
	--Log( "call JumpEnvFrame_OnShow, " .. env_ );
	if  env_==10 then
		QuestionList={GetS(9028),GetS(9029),GetS(9030),GetS(9031),GetS(9032),GetS(9033)}
	else
		QuestionList={GetS(9018),GetS(9019),GetS(9020),GetS(9021),GetS(9022),GetS(9023)}
	end


	for i=1,6 do
		getglobal(list..i):SetPoint("top","ActivateAccountFrameQ"..index.."List","top",0,base+(i-1)*51);
		getglobal(list..i.."Content"):SetText(QuestionList[i]);
		getglobal(list..i):Show();
	end

	getglobal(listBkg):SetHeight(348);
	getglobal(list.."1Line"):Hide();
	getglobal(list.."2Line"):Show();

end

function ActivateAccountFrame_OnEvent()

end

-- 第一版设置密码
--type  1设置密码 2重设密码（手机）  3 邮箱设置密码
function SetAccountLoginFrame(type, uin, code)
	ActivateAccountType = type;

	local rich = getglobal("ActivateAccountFrameTips");
	local text = GetS(3078);
	local apiId = ClientMgr:getApiId();
	if apiId == 3 or apiId == 34 or apiId == 7 then
		text = GetS(1084);
	end
	rich:SetText(text, 61, 69, 70);
	rich:SetFontType(0);
	
	local miniFont = getglobal("ActivateAccountFrameMini");
	if ActivateAccountType == 1 then
		miniFont:SetText(GetMyUin());
	elseif ActivateAccountType == 2 then
		miniFont:SetText(uin)
		ActivateAccountCode = code;
	elseif ActivateAccountType == 3 then
		miniFont:SetText(uin);
		ActivateAccountCode = code;
	end

	getglobal("ActivateAccountFrameActivateBtn"):Disable();
	getglobal("ActivateAccountFrameActivateBtnNormal"):SetGray(true);
	getglobal("ActivateAccountFrameRepeatPWEdit"):Hide();
	getglobal("ActivateAccountFrameRepeatPWEditBkg"):Hide()
	getglobal("ActivateAccountFrameTips2"):Hide();

	SetArchiveDealMsg(false);
	
	if ClientMgr:isPC() then
		SetCurEditBox("ActivateAccountFramePasswordEdit");
	end

	getglobal("ActivateAccountFrame"):Show();
end

function ActivateAccountFrame_OnShow()
	getglobal("ActivateAccountFramePasswordRult"):SetText(GetS(32116))
	getglobal("ActivateAccountFramePasswordTitle"):SetText("#L#c373631" .. GetS(3073))
	getglobal("ActivateAccountFrameStrQ1Title"):SetText("#L#c373631" .. GetS(9015) .. "1")
	getglobal("ActivateAccountFrameStrQ2Title"):SetText("#L#c373631" .. GetS(9015) .. "2")

	if NewAccountHelper:IsForceAccountSetPassword() then
		getglobal("ActivateAccountFrameCloseBtn"):Hide();
	end

	local edit1 = getglobal("ActivateAccountFramePasswordEdit");
	local edit2 = getglobal("ActivateAccountFrameRepeatPWEdit");

	local edit3=getglobal("ActivateAccountFrameStrA1");
	local edit4=getglobal("ActivateAccountFrameStrA2");

	if ClientMgr:isPC() then
		edit1:ChangeCoderEditMethod()
		edit2:ChangeCoderEditMethod()
		edit3:ChangeCoderEditMethod()
		edit4:ChangeCoderEditMethod()
	end
end

function ActivateAccountFrame_OnHide()
	print("ActivateAccountFrame_OnHide")
	local edit1 = getglobal("ActivateAccountFramePasswordEdit");
	local edit2 = getglobal("ActivateAccountFrameRepeatPWEdit");

	local edit3=getglobal("ActivateAccountFrameStrA1");
	local edit4=getglobal("ActivateAccountFrameStrA2");

	edit1:Clear();
	edit2:Clear();
	edit3:Clear();
	edit4:Clear();
	getglobal("ActivateAccountFrameStrA1"):Hide();
	getglobal("ActivateAccountFrameStrA2"):Hide();
	
	getglobal("ActivateAccountFrameQ1Content"):SetText(GetS(9016))
	getglobal("ActivateAccountFrameQ2Content"):SetText(GetS(9016))
	getglobal("ActivateAccountFrameQ1Content"):SetTextColor(144,144,144)
	getglobal("ActivateAccountFrameQ2Content"):SetTextColor(144,144,144)

	SetArchiveDealMsg(true);
end

function StrQuestionDropDown_OnClick( ... )

	local list=getglobal("ActivateAccountFrameQ1List");
	local bkg=getglobal("ActivateAccountFrameQ1ListBkg");
	local list2=getglobal("ActivateAccountFrameQ2List");
	local bkg2=getglobal("ActivateAccountFrameQ2ListBkg");

	if this:GetName()=="ActivateAccountFrameQ2DropDown" then
		list=getglobal("ActivateAccountFrameQ2List")
		bkg=getglobal("ActivateAccountFrameQ2ListBkg")
		local list2=getglobal("ActivateAccountFrameQ1List");
		local bkg2=getglobal("ActivateAccountFrameQ1ListBkg");
	end

	if list:IsShown() then
		list:Hide();
		bkg:Hide();

	else
		if list2:IsShown() then
			list2:Hide();
			bkg2:Hide();
		end
		list:Show();
		bkg:Show();
	end
end

function StrQuestionTemplate_OnClick( ... )

	local question=this:GetName().."Content"
	local p_Name=this:GetParentFrame():GetName()
	local pp_Name=this:GetParentFrame():GetParentFrame():GetName();

	getglobal(pp_Name.."Content"):SetText(getglobal(question):GetText())
	getglobal(pp_Name.."Content"):SetTextColor(255,255,255)
	getglobal(pp_Name.."ListBkg"):Hide()
	getglobal(p_Name):Hide()

	if p_Name=="ActivateAccountFrameQ1List" then
		getglobal("ActivateAccountFrameStrA1"):Show();
		getglobal("ActivateAccountFrameStrA1Bkg"):Show();
	elseif p_Name=="ActivateAccountFrameQ2List" then
		getglobal("ActivateAccountFrameStrA2"):Show();
		getglobal("ActivateAccountFrameStrA2Bkg"):Show();
	end

end

function StrQ1_OnUpdate( ... )

end

function StrQ2_OnUpdate( ... )

end

function QList_OnShow( ... )
	local QuestionList={}	
	local listName=this:GetName()
	local questionID_used=0;
	local question_used="";
	local env_ = get_game_env();

	if listName=="ActivateAccountFrameQ1List" then
		question_used=getglobal("ActivateAccountFrameQ2Content"):GetText()
	else
		question_used=getglobal("ActivateAccountFrameQ1Content"):GetText()
	end

	questionID_used=questionID_switch(question_used)
	if questionID_used~=0 then
		if env_==10 then
			questionID_used=questionID_used-9027
		else
			questionID_used=questionID_used-9017
		end
	end

	if questionID_used~=0 then

		getglobal(listName.."Question"..questionID_used):Hide()
		for i=questionID_used,6 do
			getglobal(listName.."Question"..i):SetPoint("top",listName,"top", 0, 38+(i-2)*51)
			getglobal(listName.."Bkg"):SetHeight(297)
			if i==1 then
				getglobal(listName.."Question2Line"):Hide()
			end
		end
	end

end

function QList_OnHide( ... )
	local index=1
	if this:GetName()=="ActivateAccountFrameQ2List" then
		index=2
	end
	StrQuestionList_OnLoad(index)
end



function StrA1_OnUpdate( ... )
	-- body
end

function StrA2_OnUpdate( ... )
	-- body
end

function StrA1_OnFocusLost( ... )
	local edit1 = getglobal("ActivateAccountFramePasswordEdit");
	local edit2 = getglobal("ActivateAccountFrameRepeatPWEdit");	

	local password1 = NewAccountHelper:GetEditBoxText(edit1)
	local password2 = NewAccountHelper:GetEditBoxText(edit2)
	CheckActivatePassWord(password1, password2);
end

function StrA2_OnFocusLost( ... )
	local edit1 = getglobal("ActivateAccountFramePasswordEdit");
	local edit2 = getglobal("ActivateAccountFrameRepeatPWEdit");	

	local password1 = NewAccountHelper:GetEditBoxText(edit1)
	local password2 = NewAccountHelper:GetEditBoxText(edit2)
	CheckActivatePassWord(password1, password2);
end

function StrA1_OnFinishChar( ... )
	local edit1 = getglobal("ActivateAccountFramePasswordEdit");
	local edit2 = getglobal("ActivateAccountFrameRepeatPWEdit");	

	local password1 = NewAccountHelper:GetEditBoxText(edit1)
	local password2 = NewAccountHelper:GetEditBoxText(edit2)
	CheckActivatePassWord(password1, password2);
end

function StrA2_OnFinishChar( ... )
	local edit1 = getglobal("ActivateAccountFramePasswordEdit");
	local edit2 = getglobal("ActivateAccountFrameRepeatPWEdit");	

	local password1 = NewAccountHelper:GetEditBoxText(edit1)
	local password2 = NewAccountHelper:GetEditBoxText(edit2)
	CheckActivatePassWord(password1, password2);
end

function StrA1_OnTabPressed( ... )
	SetCurEditBox("ActivateAccountFrameStrA2");
end

function StrA2_OnTabPressed( ... )
	SetCurEditBox("ActivateAccountFramePasswordEdit");
end

--------------------------------------------------------ActiveTipsFrame--------------------------------------------
function ActiveTipsFrame_OnShow()
	local active = AccountManager:getActive();
	local text = "";
	if active >= 800 then
		text = GetS(349);
	elseif active >= 700 then
		text = GetS(348);
	elseif active >= 600 then
		text = GetS(347);
	elseif active >= 500 then
		text = GetS(346);
	elseif active >= 400 then
		text = GetS(345);
	elseif active >= 300 then
		text = GetS(344);
	elseif active >= 200 then
		text = GetS(343);
	elseif active >= 100 then
		text = GetS(342);
	else
		text = GetS(341);
	end
	getglobal("ActiveTipsFrameTips"):SetText(text, 255, 255, 255);
end

function ActiveTipsFrame_Onclick()
	getglobal("ActiveTipsFrame"):Hide();
end

--点击切换迷你号按钮
function AccountFrameSwitchAcountBtn_OnClick()
	local netState = ClientMgr:getNetworkState();
	if netState ==  0 then
		ShowGameTips(GetS(161), 3);
		do return end 
	end

	if IsEnableNewLogin and IsEnableNewLogin() then
		if not NewAccountSwitchCfg:GetNewAccountSwtichStatus() then
			ShowGameTips(GetS(778), 3)
			return
		end
	elseif ClientMgr:getVersionParamInt("AccSwitch", 1) ~= 1 then	
		ShowGameTips(GetS(778), 3)
		return
	end

	local content = getglobal("AccountLoginFrameLoginContent");
	if not content:IsShown() then
		content:Show();
		Log("LoginMethod: "..ClientMgr:getGameData("LoginMethod"))
		getglobal("AccountLoginFrameLoginBtn"):Show()
		if ClientMgr:getGameData("LoginMethod")==0 then
			getglobal("AccountLoginFrameLoginContentPasswordEdit"):Show()
			getglobal("AccountLoginFrameLoginContentPasswordTitle"):Show()
			getglobal("AccountLoginFrameLoginContentPasswordEditBkg"):Show()
			getglobal("AccountLoginFrameLoginContentQ1"):Hide()
			getglobal("AccountLoginFrameLoginContentStrQuestionTitle"):Hide()
			getglobal("AccountLoginFrameLoginContentStrAnswerTitle"):Hide()
			getglobal("AccountLoginFrameLoginContentStrAnswerBkg"):Hide()
			getglobal("AccountLoginFrameLoginContentStrAnswerCoderBtn"):Hide()
			getglobal("AccountLoginFrameLoginContentStrAnswer"):Hide()
		else
			getglobal("AccountLoginFrameLoginContentPasswordEdit"):Hide()
			getglobal("AccountLoginFrameLoginContentPasswordTitle"):Hide()
			getglobal("AccountLoginFrameLoginContentPasswordEditBkg"):Hide()
			getglobal("AccountLoginFrameLoginContentQ1"):Show()
			getglobal("AccountLoginFrameLoginContentStrQuestionTitle"):Show()
			getglobal("AccountLoginFrameLoginContentStrAnswerTitle"):Show()
			getglobal("AccountLoginFrameLoginContentStrAnswerBkg"):Show()
			if ClientMgr:isPC() then
				getglobal("AccountLoginFrameLoginContentStrAnswerCoderBtn"):Show()
			end
			getglobal("AccountLoginFrameLoginContentStrAnswer"):Show()
		end
		SetCurEditBox("AccountLoginFrameLoginContentMiniEdit");
	end

	-- luoshun:开关：邮箱找回
	local emailResetPW = getglobal("AccountLoginFrameLoginContentEmailResetPW");
	if check_apiid_ver_conditions( ns_version.email_find_back, true) then
		if not emailResetPW:IsShown() then
			emailResetPW:Show();
		end
	else
		if emailResetPW:IsShown() then
			emailResetPW:Hide();
		end
	end

	-- luoshun:邮箱达到登录账号的效果
	local loginTitle = getglobal("AccountLoginFrameLoginContentTitle");
	local loginMiniEdit = getglobal("AccountLoginFrameLoginContentMiniEdit");
	local loginMiniOrEmailEdit = getglobal("AccountLoginFrameLoginContentMiniOrEmailEdit");
	if ClientMgr:getApiId() > 300 then
		loginTitle:SetText(GetS(6560));
		loginMiniEdit:Hide();
		loginMiniOrEmailEdit:Show();
	else
		loginTitle:SetText(GetS(3070));
		loginMiniEdit:Show();
		loginMiniOrEmailEdit:Hide();
	end

	-- luoshun 开关：facebook登陆
	local FaceBookLoginBtn = getglobal("AccountLoginFrameFaceBookLoginBtn");
	if check_apiid_ver_conditions(ns_version.facebook_bind_btn, false) then
		if not FaceBookLoginBtn:IsShown() then
			FaceBookLoginBtn:Show();
		end
	else
		if FaceBookLoginBtn:IsShown() then
			FaceBookLoginBtn:Hide();
		end
	end

	--LLTODO:海外版本隐藏找回密码按钮
	if isAbroadEvn() then
		local ResetPWBtn = getglobal("AccountLoginFrameLoginContentResetPW");
		if ResetPWBtn:IsShown() then
			ResetPWBtn:Hide();
		end
	end

	if ClientMgr:getVersionParamInt("MobileBinding", 1) ~= 1 then
		getglobal("AccountLoginFrameLoginContentResetPW"):Hide();
	end

	local content = getglobal("SecuritySettingContent");
	if content:IsShown() then
		content:Hide();
	end

	if getkv("DropDown_OnClick") then
		DropDown_Hide();--隐藏切换账号面板
	end

	local list=getglobal("AccountLoginFrameLoginContentQ1List")
	local listBkg=getglobal("AccountLoginFrameLoginContentQ1ListBkg")
	if list:IsShown() then
		list:Hide()
		listBkg:Hide()
		getglobal("AccountLoginFrameLoginContentStrAnswer"):Show()
		if ClientMgr:isPC() then
			getglobal("AccountLoginFrameLoginContentStrAnswerCoderBtn"):Show()
		end
	end
	getglobal("AccountLoginFrameLoginContentNumberPwdLogin"):Show();
	getglobal("AccountLoginFrameLoginContentTextPwdLogin"):Show();
	if WeChatOptionConfig() then
		getglobal("AccountLoginFrameLoginContentWeChatLogin"):Show();
	else
		getglobal("AccountLoginFrameLoginContentWeChatLogin"):Hide();
	end
	if QQOptionConfig() then
		local qqLoginBtn = getglobal("AccountLoginFrameLoginContentQQLogin")
		if not WeChatOptionConfig() then
			qqLoginBtn:SetPoint("left","AccountLoginFrameLoginContentTextPwdLogin","right",24,0)
		else
			qqLoginBtn:SetPoint("left","AccountLoginFrameLoginContentWeChatLogin","right",24,0)
		end
		qqLoginBtn:Show();
	else
		getglobal("AccountLoginFrameLoginContentQQLogin"):Hide();
	end
end

--点击绑定按钮
function  AccountSecuritySettingsBtn_OnClick()
	-- statisticsGameEvent(56023)
	local netState = ClientMgr:getNetworkState();
	if netState ==  0 then
	--	ShowGameTips(StringDefCsv:get(161), 3);
		do return end 
	end

	local content = getglobal("SecuritySettingContent");
	if not content:IsShown() then
		content:Show();
	end

	local content = getglobal("AccountLoginFrameLoginContent");
	if content:IsShown() then
		content:Hide();
	end

	local result = nil;
	local result2 = nil;
	local result3 = nil;
	local hasBindedQQ = nil;
	local hasBindedWeChat = nil;
	if AccountManager.hasBindedPhone then
		result = AccountManager:hasBindedPhone();
	else
		result = -2;
	end
	if AccountManager.hasBindedEmail then
		result2 = AccountManager:hasBindedEmail();
	else
		result2 = -2;
	end
	if AccountManager.hasBindedFacebook then
		result3 = AccountManager:hasBindedFacebook();
	else
		result3 = -2;
	end

	if AccountManager.isbindopenid then
		hasBindedQQ = AccountManager:isbindopenid("qq");
		hasBindedWeChat = AccountManager:isbindopenid("wechat");
		if ClientMgr:isPC() then--PC在服务器数据没有更新时，使用本地缓存数据
			if PCBindedResult.platform == "qq" then
				hasBindedQQ = PCBindedResult.bindingOrUnBind
			elseif PCBindedResult.platform == "wechat" then
				hasBindedWeChat = PCBindedResult.bindingOrUnBind
			end
		end
	else
		if ClientMgr:isPC() then--PC在服务器数据没有更新时，使用本地缓存数据
			if PCBindedResult.platform == "qq" then
				hasBindedQQ = PCBindedResult.bindingOrUnBind
			elseif PCBindedResult.platform == "wechat" then
				hasBindedWeChat = PCBindedResult.bindingOrUnBind
			end
		end
	end

	--local mobileText =  getglobal("SecuritySettingContentBindedMobile");
	local mobileText =  getglobal("SecuritySettingContentBindedMobile");
	local emailText =  getglobal("SecuritySettingContentBindedEmail");
	local faceBookText = getglobal("SecuritySettingContentBindedFaceBook");
	local qqText = getglobal("SecuritySettingContentBindedQQ");
	local weChatText = getglobal("SecuritySettingContentBindedWeChat");

	local bindedMobileIcon = getglobal("SecuritySettingContentBindedMobileIcon");
	local bindedEmailIcon = getglobal("SecuritySettingContentBindedEmailIcon");
	local bindedFaceBookIcon = getglobal("SecuritySettingContentBindedFaceBookIcon");
	local bindedQQIcon = getglobal("SecuritySettingContentBindedQQIcon");
	local bindedWeCharIcon = getglobal("SecuritySettingContentBindedWeChatIcon");


	local bindMobileButton = getglobal("SecuritySettingContentBindingMobileBtn");
	local bindEmailButton = getglobal("SecuritySettingContentBindingEmailBtn");
	local bindFaceBookButton = getglobal("SecuritySettingContentBindingFaceBookBtn");
	local bindingQQButton = getglobal("SecuritySettingContentBindingQQBtn");
	local bindingWeChatButton = getglobal("SecuritySettingContentBindingWeChatBtn");


	local unboundMobileBtn = getglobal("SecuritySettingContentUnboundMobileBtn");
	local unboundEmailBtn = getglobal("SecuritySettingContentUnboundEmailBtn");
	local unboundQQBtn = getglobal("SecuritySettingContentUnboundQQBtn");
	local unboundWeChatBtn = getglobal("SecuritySettingContentUnboundWeChatBtn");

	getglobal("SecuritySettingContentUnboundQQBtn"):Hide();
	getglobal("SecuritySettingContentUnboundWeChatBtn"):Hide();

	if result == -1 then
		--无法获取到信息
		mobileText:SetText(GetS(3433));
		bindedMobileIcon:Hide();
		bindMobileButton:Hide();
		unboundMobileBtn:Hide();
	elseif result == 0 then
		--未绑定手机
		mobileText:SetText(GetS(3434));
		bindedMobileIcon:Hide();
		bindMobileButton:Show();
		unboundMobileBtn:Hide();
		--LLTODO:海外版, 隐藏掉绑定手机一栏
		if isAbroadEvn() then
			AbroadBindingUI();
		else
			DomesticBindingUI()
		end
	elseif result == 1 then
		--已绑定
		mobileText:SetText(AccountManager:getBindedPhoneWithEncryption());
		bindedMobileIcon:Show();
		bindMobileButton:Hide();
		unboundMobileBtn:Show();
	end

	if result2 == -1 then
		--无法获取到信息
		emailText:SetText(GetS(3433));
		bindedEmailIcon:Hide();
		bindEmailButton:Hide();
	elseif result2 == 0 then
		--未绑定
		emailText:SetText(GetS(3434));
		bindedEmailIcon:Hide();
		bindEmailButton:Show();
		unboundEmailBtn:Hide();
	elseif result2 == 1 then
		--已绑定
		emailText:SetText(AccountManager:getBindedEmailWithEncryption());
		bindedEmailIcon:Show();
		bindEmailButton:Hide();
		unboundEmailBtn:Show();
	end

	Log("hasBindedFacebook result3 : "..result3);
	if check_apiid_ver_conditions(ns_version.facebook_bind_btn, false) and ClientMgr:getApiId() ~= 999 then
		if result3 == -1 then
			--无法获取到信息
			faceBookText:SetText(GetS(3433));
			bindedFaceBookIcon:Hide();
			bindFaceBookButton:Hide();
		elseif result3 == 0 then
			--未绑定
			faceBookText:SetText(GetS(3434));
			bindedFaceBookIcon:Hide();
			bindFaceBookButton:Show();
		elseif result3 == 1 then
			--已绑定
			local userId, nickName = AccountManager:getBindedFaceBookWithEncryption()
			if userId ~= nil and nickName ~= nil then
				faceBookText:SetText(nickName);
				bindedFaceBookIcon:Show();
				bindFaceBookButton:Hide();
			else
				Log("getBindedFaceBookWithEncryption return nil");
			end
		elseif result3 == -2 then
			--此功能暂未开放 （AccountManager.hasBindedFacebook 此接口不存在）
			faceBookText:SetText(GetS(3479));
			bindedFaceBookIcon:Hide();
			bindFaceBookButton:Hide();
		end
	else
		HideBindingFaceBookBtn();
	end

	bindedQQIcon:Hide();
	--QQ
   if not hasBindedQQ then
		--未绑定
	    qqText:SetText(GetS(3434));
		bindedQQIcon:Hide();
		bindingQQButton:Show();
		unboundQQBtn:Hide();
	else
		--已绑定
	    qqText:SetText(GetS(3416));
		bindedQQIcon:Show();
		bindingQQButton:Hide();
		unboundQQBtn:Show();
	end
    --WeChat
	if not hasBindedWeChat then
		--未绑定
		weChatText:SetText(GetS(3434));
		bindedWeCharIcon:Hide();
		bindingWeChatButton:Show();
		unboundWeChatBtn:Hide();
	else
		--已绑定
		weChatText:SetText(GetS(3416));
		bindedWeCharIcon:Show();
		bindingWeChatButton:Hide();
		unboundWeChatBtn:Show();
	end

	if isAbroadEvn() then
		AbroadBindingUI()
	else
		DomesticBindingUI()
	end

	if ClientMgr:getVersionParamInt("MobileBinding", 1) ~= 1 then
		HideBindingPhone()
	end

	if if_show_acc_logincheck_switch() then
		local state = 0
		if AccountSafetyCheck:GetSwitchState() then 
			state = 1
		end

		getglobal("SecuritySettingContentSafetyCheckText"):Show()
		getglobal("SecuritySettingContentSafetyCheckSwitch"):Show()
		SetSwitchBtnState("SecuritySettingContentSafetyCheckSwitch", state)
	else
		unboundMobileBtn:Hide()
		unboundEmailBtn:Hide()
		getglobal("SecuritySettingContentSafetyCheckText"):Hide()
		getglobal("SecuritySettingContentSafetyCheckSwitch"):Hide()
	end

	getglobal("SecuritySettingContentSafetyCheckText"):SetText(GetS(100201), 61, 69, 70)
end



--国外绑定UI--隐藏绑定手机一栏(海外版不绑定手机)
function AbroadBindingUI()
	local mobileNoTitle =  getglobal("SecuritySettingContentMobileNoTitle");
	local mobileNoBkg =  getglobal("SecuritySettingContentMobileNoBkg");
	local mobileText =  getglobal("SecuritySettingContentBindedMobile");
	local bindMobileButton = getglobal("SecuritySettingContentBindingMobileBtn");
	local unboundBtn = getglobal("SecuritySettingContentUnboundMobileBtn");

	mobileNoTitle:Hide();
	mobileNoBkg:Hide();
	mobileText:Hide();
	bindMobileButton:Hide();
	unboundBtn:Hide();
	--绑定邮箱的位置上移.移标题就够了，后面位置是相对于标题的
	local emailTitle =  getglobal("SecuritySettingContentEmailTitle");
	emailTitle:SetPoint("topright", "SecuritySettingContent", "topleft", 190, 0);

	getglobal("SecuritySettingContentIcon"):Show();
	getglobal("SecuritySettingContentTipRewardBkgArrow"):Show();
	getglobal("SecuritySettingContentTipRewardBkg"):Show();
	getglobal("SecuritySettingContentRewardTip"):Hide();

	getglobal("SecuritySettingContentBindingQQBtn"):Hide();
	getglobal("SecuritySettingContentUnboundQQBtn"):Hide();
	getglobal("SecuritySettingContentUnboundWeChatBtn"):Hide();
	getglobal("SecuritySettingContentBindingWeChatBtn"):Hide();
	getglobal("SecuritySettingContentQQTitle"):Hide();
	getglobal("SecuritySettingContentQQBkg"):Hide();
	getglobal("SecuritySettingContentWeChatTitle"):Hide();
	getglobal("SecuritySettingContentWeChatBkg"):Hide();
	getglobal("SecuritySettingContentBindedQQ"):Hide();
	getglobal("SecuritySettingContentBindedWeChat"):Hide();


end

function IsHideQQOrWeChat()
	local isShowQQ = check_apiid_ver_conditions(ns_version.qq_binding)
	local isShowWeChat = check_apiid_ver_conditions(ns_version.wx_binding)
	if not isShowQQ then
		getglobal("SecuritySettingContentBindingQQBtn"):Hide();
		getglobal("SecuritySettingContentUnboundQQBtn"):Hide();
		getglobal("SecuritySettingContentQQTitle"):Hide();
		getglobal("SecuritySettingContentQQBkg"):Hide();
		getglobal("SecuritySettingContentBindedQQ"):Hide();
	end
	if not isShowWeChat then
		getglobal("SecuritySettingContentUnboundWeChatBtn"):Hide();
		getglobal("SecuritySettingContentBindingWeChatBtn"):Hide();
		getglobal("SecuritySettingContentWeChatTitle"):Hide();
		getglobal("SecuritySettingContentWeChatBkg"):Hide();
		getglobal("SecuritySettingContentBindedWeChat"):Hide();
	end
	if not isShowQQ then
		if not isShowWeChat then
			local checkText =  getglobal("SecuritySettingContentSafetyCheckText");
			checkText:SetPoint("topright", "SecuritySettingContent", "topleft", 190, 120);
		else
			local weChatTitle =  getglobal("SecuritySettingContentWeChatTitle");
			weChatTitle:SetPoint("topright", "SecuritySettingContent", "topleft", 190, 120);
			local checkText =  getglobal("SecuritySettingContentSafetyCheckText");
			checkText:SetPoint("topright", "SecuritySettingContent", "topleft", 190, 180);
		end
	else
		if not isShowWeChat then
			local checkText =  getglobal("SecuritySettingContentSafetyCheckText");
			checkText:SetPoint("topright", "SecuritySettingContent", "topleft", 190, 180);
		end
	end
end

--隐藏绑定手机一栏
function HideBindingPhone()
	local mobileNoTitle =  getglobal("SecuritySettingContentMobileNoTitle");
	local mobileNoBkg =  getglobal("SecuritySettingContentMobileNoBkg");
	local mobileText =  getglobal("SecuritySettingContentBindedMobile");
	local bindMobileButton = getglobal("SecuritySettingContentBindingMobileBtn");
	local unboundBtn = getglobal("SecuritySettingContentUnboundMobileBtn");
	local mobileIcon = getglobal("SecuritySettingContentBindedMobileIcon");

	mobileNoTitle:Hide();
	mobileNoBkg:Hide();
	mobileText:Hide();
	bindMobileButton:Hide();
	unboundBtn:Hide();
	mobileIcon:Hide();
	--绑定邮箱的位置上移.移标题就够了，后面位置是相对于标题的
	local emailTitle =  getglobal("SecuritySettingContentEmailTitle");
	emailTitle:SetPoint("topright", "SecuritySettingContent", "topleft", 190, 0);
end

--国内绑定UI
function DomesticBindingUI()
    local icon =	getglobal("SecuritySettingContentIcon");
	local arrow = getglobal("SecuritySettingContentTipRewardBkgArrow");
	local rewardBkg = getglobal("SecuritySettingContentTipRewardBkg");
	local rewardTip = getglobal("SecuritySettingContentRewardTip");
	icon:Hide();
	arrow:Hide();
	rewardBkg:Hide();
	rewardTip:Hide();
	local safetySwitch = getglobal("SecuritySettingContentSafetyCheckSwitch");
	local safetyText = getglobal("SecuritySettingContentSafetyCheckText");
	safetyText:SetPoint("topright", "SecuritySettingContent", "topleft", 190, 230);
	safetySwitch:SetPoint("left", "SecuritySettingContentSafetyCheckText", "right", 10, -5);
	HideBindingFaceBookBtn()
	IsHideQQOrWeChat();
end
--------------------------------------------luoshun EmailValidateFrame---------------------------------
local ValidateResetUin_Email = 0;

function ShowEmailValidateFrame(type)
	ValidateType = type;
	local emailFont = getglobal("EmailValidateFrameEmail");
	local emailEdit = getglobal("EmailValidateFrameEmailEdit");
	emailEdit:Clear();
	getglobal("EmailValidateFrameVCEdit"):Clear();
	if type == 3 then
		ValidateResetUin_Email = 0;
		getglobal("EmailValidateFrameEmail"):Hide();
		getglobal("EmailValidateFrameEmailEdit"):Show();
		if DisEnableEdit then 
			getglobal("EmailValidateFrameEmailEdit"):enableEdit(false)
			getglobal("EmailValidateFrameEmailEdit"):SetText(AccountSafetyManage:GetBindingEmail());
			getglobal("EmailValidateFrameEmailEdit"):SetTextColor(185,185,185)
		else
			getglobal("EmailValidateFrameEmailEdit"):enableEdit(true)
			getglobal("EmailValidateFrameEmailEdit"):SetText("");
			getglobal("EmailValidateFrameEmailEdit"):SetTextColor(255,255,255)
		end 
		getglobal("EmailValidateFrameOkBtnText"):SetText(GetS(381));
	end

	if not getglobal("EmailValidateFrame"):IsShown() then
		getglobal("EmailValidateFrame"):Show();
	end
end

function EmailValidateFrame_OnShow()
	local text = getglobal("EmailValidateFrameRequestVCBtnText");
	if(ValidateType == 3 and ResetRequestCoolDown_Email <= 0) then
		text:SetText(GetS(3430));
		getglobal("EmailValidateFrameRequestVCBtn"):Enable();
		getglobal("EmailValidateFrameRequestVCBtnNormal"):SetGray(false);
	else
		getglobal("EmailValidateFrameRequestVCBtn"):Disable();
		getglobal("EmailValidateFrameRequestVCBtnNormal"):SetGray(true);
	end

	TemplateEditBoxCoderBtn_OnShow(getglobal("EmailValidateFrameEmailEdit"), getglobal("EmailValidateFrameEmailCoderBtn"))
	TemplateEditBoxCoderBtn_OnShow(getglobal("EmailValidateFrameVCEdit"), getglobal("EmailValidateFrameVCCoderBtn"))

	local esp = getglobal("EmailValidateFrameSwitchPhone")
	if IsOverseasVer() or isAbroadEvn() then
		esp:Hide()
	else
		esp:SetText(GetS(32122), 55, 54, 49)
		esp:Show()
	end
end

function EmailValidateFrame_OnHide()
	DisEnableEdit = false
end

function EmailValidateFrameCloseBtn_OnClick()
	getglobal("EmailValidateFrame"):Hide();
end

function EmailValidateFrameRequestVCBtn_OnClick()
	local emailEdit = getglobal("EmailValidateFrameEmailEdit")
	local email = NewAccountHelper:GetEditBoxText(emailEdit)
	if CheckEmailValid(email) then
		local result;
		result, ValidateResetUin_Email = AccountManager:send_email_verify_code(email)
		print("luoshun EmailValidateFrameRequestVCBtn_OnClick result=", result);
		if result == ErrorCode.OK then
			getglobal("EmailValidateFrameRequestVCBtn"):Disable();
			getglobal("EmailValidateFrameRequestVCBtnNormal"):SetGray(true);
			ShowGameTips(GetS(3431), 3);
			ResetRequestCoolDown_Email = 60;
			CoolTimeUpdate(ResetRequestCoolDown_Email, 3);
		else
		-- elseif result == ErrorCode.PRECHECK_EMAIL_NOT_BOUND then
			ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[result]), 3);
		-- elseif result == ErrorCode.PRECHECK_EMAIL_HAS_ALREADY_BEAN_BOUND then
		-- 	ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[retult]), 3);
		-- elseif result == ErrorCode.PRECHECK_EMAIL_VERIFY_CODE_TIMEOUT then
		-- 	ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[retult]), 3);
		-- elseif result == ErrorCode.PRECHECK_EMAIL_VERIFY_CODE_MISMATCH then
		-- 	ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[retult]), 3);
		-- else
		-- 	ShowGameTips(GetS(3433), 3);
		end
	else
		ShowGameTips(GetS(6087), 3);
	end

end

function EmailValidateFrameOkBtn_OnClick()
	local vcEdit = getglobal("EmailValidateFrameVCEdit")
	local code = NewAccountHelper:GetEditBoxText(vcEdit)
	if ValidateType == 3 then 			--修改迷你密码邮箱验证
		if CheckVCValid(code) then
			local emailEdit = getglobal("EmailValidateFrameEmailEdit")
			local email = NewAccountHelper:GetEditBoxText(emailEdit)
			if AccountManager:check_email_verify_code(email, code) then
				if ValidateResetUin_Email == 0 then
					ShowGameTips(GetS(6217), 3);
				else
					getglobal("EmailValidateFrame"):Hide();
					NewAccountHelper:IntergateSetAccountLoginFrame({
						setType = NewAccountHelper.PASSWORD_MODIFY,
						tag = NewAccountHelper.ACCOUNT_TAG_EMAIL,
						number = email,
						code = code,
						uin = ValidateResetUin_Email
					})
					-- SetAccountLoginFrame(3, ValidateResetUin_Email, code);
					ShowGameTips(GetS(3575), 3);
				end
			else
				ShowGameTips(GetS(3421), 3);
			end
		else
			ShowGameTips(GetS(3421), 3);
		end
	end
end

function EmailValidateFrameSwitchPhone_OnClick()
	local disable = DisEnableEdit
	if disable then
		if AccountManager:hasBindedPhone() == 1 then  
			EmailValidateFrameCloseBtn_OnClick();
			DisEnableEdit = disable
			AccountLoginFrameResetPW_OnClick();
		else
			ShowGameTipsWithoutFilter(GetS(32125))
		end 
	else
		EmailValidateFrameCloseBtn_OnClick();
		AccountLoginFrameResetPW_OnClick();
	end 
end
--------------------------------------------PhoneValidateFrame---------------------------------
ValidateType = 0;

local ValidateLoginPhone;
local ValidateLoginUin;
local ValidateLoginPassword;
local ValidateResetUin=0;
function ShowPhoneValidateFrame(type, phoneNum, uin, password)
	ValidateType = type;
	local phoneFont = getglobal("PhoneValidateFramePhone");
	local phoneEdit = getglobal("PhoneValidateFramePhoneEdit");
	phoneEdit:Clear();
	getglobal("PhoneValidateFrameVCEdit"):Clear();
	if type == 1 then --登录手机验证
		----------StringBuilder-----
		local text = GetS(3566, uin);
		getglobal("PhoneValidateFrameDesc"):SetText(text);

		ValidateLoginPhone = phoneNum;
		local head = string.sub(phoneNum,1,3);
		local tail = string.sub(phoneNum,8,11);
		phoneFont:SetText(head.."****"..tail);
		phoneFont:Show();
		phoneEdit:Hide();

		getglobal("PhoneValidateFrameOkBtnText"):SetText(GetS(3565));
		ValidateLoginUin = uin;
		ValidateLoginPassword = password
	elseif type == 2 then --修改迷你手机验证
		getglobal("PhoneValidateFrameDesc"):SetText(GetS(3568));
		ValidateResetUin = 0;
		phoneEdit:Show();
		if DisEnableEdit then 
			phoneEdit:enableEdit(false)
			phoneEdit:SetText(AccountSafetyManage:GetBindingPhone())
			phoneEdit:SetTextColor(185,185,185)
		else
			phoneEdit:enableEdit(true)
			phoneEdit:SetText("")
			phoneEdit:SetTextColor(255,255,255)
		end 
		phoneFont:Hide();
		getglobal("PhoneValidateFrameOkBtnText"):SetText(GetS(381));
	end

	if not getglobal("PhoneValidateFrame"):IsShown() then
		getglobal("PhoneValidateFrame"):Show();
	end
end

function PhoneValidateFrame_OnShow()
	local text = getglobal("PhoneValidateFrameRequestVCBtnText");
	if (ValidateType == 1 and LoginRequestCoolDown <= 0) or (ValidateType == 2 and ResetRequestCoolDown <= 0) then
		text:SetText(GetS(3430));
		getglobal("PhoneValidateFrameRequestVCBtn"):Enable();
		getglobal("PhoneValidateFrameRequestVCBtnNormal"):SetGray(false);
	else
		getglobal("PhoneValidateFrameRequestVCBtn"):Disable();
		getglobal("PhoneValidateFrameRequestVCBtnNormal"):SetGray(true);
	end	

	TemplateEditBoxCoderBtn_OnShow(getglobal("PhoneValidateFramePhoneEdit"),getglobal("PhoneValidateFramePhoneCoderBtn"))
	TemplateEditBoxCoderBtn_OnShow(getglobal("PhoneValidateFrameVCEdit"),getglobal("PhoneValidateFrameVCCoderBtn"))


	local psp = getglobal("PhoneValidateFrameSwitchEmail")
	psp:SetText(GetS(32123), 55, 54, 49)
end

function PhoneValidateFrame_OnHide()
	DisEnableEdit = false
end

function PhoneValidateFrameSwitchEmail_OnClick()
	local disable = DisEnableEdit
	if disable then 
		if AccountManager:hasBindedEmail() == 1 then 
			PhoneValidateFrameCloseBtn_OnClick();
			DisEnableEdit = disable
			AccountLoginFrameEmailResetPW_OnClick();
		else
			ShowGameTipsWithoutFilter(GetS(32126))
		end 
	else
		PhoneValidateFrameCloseBtn_OnClick();
		AccountLoginFrameEmailResetPW_OnClick();
	end 
end

function PhoneValidateFrameCloseBtn_OnClick()
	getglobal("PhoneValidateFrame"):Hide();
end

function PhoneValidateFrameRequestVCBtn_OnClick()
	if ValidateType == 1 then	--登录手机验证
	--	local mobile = getglobal("PhoneValidateFramePhone"):GetText();
		if CheckMobileValid(ValidateLoginPhone) then
			local result = AccountManager:requestMobileCodeLogin(ValidateLoginPhone);
			if result == ErrorCode.OK then
				getglobal("PhoneValidateFrameRequestVCBtn"):Disable();
				getglobal("PhoneValidateFrameRequestVCBtnNormal"):SetGray(true);
				ShowGameTipsWithoutFilter(GetS(3431), 3);
				LoginRequestCoolDown = 60;
				CoolTimeUpdate(LoginRequestCoolDown, 1);
			else
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[result]), 3);
			-- elseif result == 3 then
			-- 	ShowGameTips(GetS(3429).." "..result, 3);
			-- elseif result == 4 then
			-- 	ShowGameTips(GetS(3432).." "..result, 3);
			-- elseif result == 5 then
			-- 	ShowGameTips(GetS(3435).." "..result, 3);
			-- else
			-- 	ShowGameTips(GetS(3433).." "..result, 3);
			end
		else					
			ShowGameTipsWithoutFilter(GetS(3419), 3);
		end
	elseif ValidateType == 2 then	--修改迷你手机验证
		local phoneEdit = getglobal("PhoneValidateFramePhoneEdit")
		local mobile = NewAccountHelper:GetEditBoxText(phoneEdit)
		if CheckMobileValid(mobile) then
			local result;
			result, ValidateResetUin = AccountManager:requestMobileCodeResetPassword(mobile, ValidateResetUin);
			print("luoshun PhoneValidateFrameRequestVCBtn_OnClick result=", result);

			if result == 0 then
				getglobal("PhoneValidateFrameRequestVCBtn"):Disable();
				getglobal("PhoneValidateFrameRequestVCBtnNormal"):SetGray(true);
				ShowGameTipsWithoutFilter(GetS(3431), 3);
				ResetRequestCoolDown = 60
				CoolTimeUpdate(ResetRequestCoolDown, 2);
			else
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[result]), 3);
			-- elseif result == 2 then
			-- 	ShowGameTips(GetS(3577).." "..result, 3);
			-- elseif result == 3 then
			-- 	ShowGameTips(GetS(3429).." "..result, 3);
			-- elseif result == 4 then
			-- 	ShowGameTips(GetS(3432).." "..result, 3);
			-- elseif result == 5 then
			-- 	ShowGameTips(GetS(3435).." "..result, 3);
			-- else
			-- 	ShowGameTips(GetS(3433).." "..result, 3);
			end
		else					
			ShowGameTipsWithoutFilter(GetS(3419), 3);
		end
	end
end

function PhoneValidateFrameOkBtn_OnClick()
	local vcEdit = getglobal("PhoneValidateFrameVCEdit")
	local code = NewAccountHelper:GetEditBoxText(vcEdit)
	if ValidateType == 1 then	--登录手机验证
		if CheckVCValid(code) then
			RequestLoginAccount(ValidateLoginUin, ValidateLoginPassword, code);
		else
			ShowGameTips(GetS(3421), 3);
		end
	elseif ValidateType == 2 then	--修改迷你手机验证
		if CheckVCValid(code) then
			local phoneEdit = getglobal("PhoneValidateFramePhoneEdit")
			local phone = NewAccountHelper:GetEditBoxText(phoneEdit)
			if AccountManager:checkResetPasswordCode(phone, code, ValidateResetUin) then
				if ValidateResetUin == 0 then
					ShowGameTips(GetS(6217), 3);
				else
					getglobal("PhoneValidateFrame"):Hide();
					NewAccountHelper:IntergateSetAccountLoginFrame({
						setType = NewAccountHelper.PASSWORD_MODIFY,
						tag = NewAccountHelper.ACCOUNT_TAG_PHONE,
						number = phone,
						code = code,
						uin = ValidateResetUin
					})

					-- SetAccountLoginFrame(2, ValidateResetUin, code);
					ShowGameTips(GetS(3575), 3);
				end
			else
				ShowGameTips(GetS(3421), 3);
			end
		else
			ShowGameTips(GetS(3421), 3);
		end
	end
end



function PhoneValidateFramePhoneEdit_OnEnterPressed()

end

function PhoneValidateFramePhoneEdit_OnTabPressed()

end

function PhoneValidateFrameVCEdit_OnEnterPressed()
end

function PhoneValidateFrameVCEdit_OnTabPressed()

end

--编辑框切换 密码/明文状态
function PhoneValidateFramePhoneCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("PhoneValidateFramePhoneEdit"),getglobal("PhoneValidateFramePhoneCoderBtn"))
end
function PhoneValidateFramePhoneCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("PhoneValidateFramePhoneEdit"),getglobal("PhoneValidateFramePhoneCoderBtn"))
end

function PhoneValidateFrameVCCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("PhoneValidateFrameVCEdit"),getglobal("PhoneValidateFrameVCCoderBtn"))
end
function PhoneValidateFrameVCCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("PhoneValidateFrameVCEdit"),getglobal("PhoneValidateFrameVCCoderBtn"))
end

-----------------------------------------------------------------------------------------------
-- 绑定面板

--点击了绑定手机按钮
function AccountFrameBindingMobileAcountBtn_OnClick()
	-- statisticsGameEvent(56024)
	ShowPhtoneBindingAwardFrame(false)
	
	-- BindingType = 0;
	-- AccountLoginFrameCloseBtn_OnClick();
	-- local content = getglobal("BindingPhoneEmailFrame");
	-- if not content:IsShown() then
	-- 	content:Show();
	-- end

	-- ResetBindingPhoneEmailFrame(1);

	-- getglobal("BindingPhoneEmailFrameTitleFrameTitle"):SetText(GetS(3424));
	-- getglobal("BindingPhoneEmailFramePhoneOrEmailTitle"):SetText(GetS(3413));
	-- getglobal("BindingPhoneEmailFramePhoneEdit"):Show();
	-- getglobal("BindingPhoneEmailFramePhoneCoderBtn"):Show();
	-- getglobal("BindingPhoneEmailFrameEmailEdit"):Hide();
	-- getglobal("BindingPhoneEmailFrameEmailCoderBtn"):Hide();
	-- getglobal("BindingPhoneEmailFrameBindingBtnText"):SetText(GetS(3415));

	-- SetCurEditBox("BindingPhoneEmailFramePhoneEdit");

	setkv("PhtoneBindingRedHintTime", os.time())
	if PhtoneBindingAwardClass then
		PhtoneBindingAwardClass:UpdatePhtoneBindingRedTag()
	end
end

--点击解绑手机按钮
function AccountFrameUnboundMobileAcountBtn_OnClick()
	BindingType = 3;
	AccountLoginFrameCloseBtn_OnClick();
	local content = getglobal("BindingPhoneEmailFrame");
	if not content:IsShown() then
		content:Show();
	end

	ResetBindingPhoneEmailFrame(3);

	getglobal("BindingPhoneEmailFrameTitleFrameTitle"):SetText(GetS(100211));
	getglobal("BindingPhoneEmailFramePhoneOrEmailTitle"):SetText(GetS(3413));
	getglobal("BindingPhoneEmailFramePhoneEdit"):Show();
	getglobal("BindingPhoneEmailFramePhoneCoderBtn"):Show();
	getglobal("BindingPhoneEmailFrameEmailEdit"):Hide();
	getglobal("BindingPhoneEmailFrameEmailCoderBtn"):Hide();
	getglobal("BindingPhoneEmailFrameFaceBookBindingBtn"):Hide();

	getglobal("BindingPhoneEmailFrameBindingBtnText"):SetText(GetS(381));
	SetCurEditBox("BindingPhoneEmailFramePhoneEdit");
end

--点击了绑定邮箱按钮
function AccountFrameBindingEmailAcountBtn_OnClick()
	BindingType = 1;
	AccountLoginFrameCloseBtn_OnClick();
	local content = getglobal("BindingPhoneEmailFrame");
	if not content:IsShown() then
		content:Show();
	end
	
	ResetBindingPhoneEmailFrame(2);

	getglobal("BindingPhoneEmailFrameTitleFrameTitle"):SetText(GetS(3425));
	getglobal("BindingPhoneEmailFramePhoneOrEmailTitle"):SetText(GetS(3414));
	getglobal("BindingPhoneEmailFramePhoneEdit"):Hide();
	getglobal("BindingPhoneEmailFramePhoneCoderBtn"):Hide();
	getglobal("BindingPhoneEmailFrameEmailEdit"):Show();
	getglobal("BindingPhoneEmailFrameEmailCoderBtn"):Show();
	getglobal("BindingPhoneEmailFrameBindingBtnText"):SetText(GetS(3415));

	SetCurEditBox("BindingPhoneEmailFrameEmailEdit");

	if ns_version and check_apiid_ver_conditions(ns_version.facebook_bind_btn, false) then
		getglobal("BindingPhoneEmailFrameFaceBookBindingBtn"):Show();
	else
		getglobal("BindingPhoneEmailFrameFaceBookBindingBtn"):Hide();
	end
end

--点击解绑邮箱按钮
function AccountFrameUnboundEmailAcountBtn_OnClick()
	BindingType = 4;
	AccountLoginFrameCloseBtn_OnClick();
	local content = getglobal("BindingPhoneEmailFrame");
	if not content:IsShown() then
		content:Show();
	end

	ResetBindingPhoneEmailFrame(4);

	getglobal("BindingPhoneEmailFrameTitleFrameTitle"):SetText(GetS(100210));
	getglobal("BindingPhoneEmailFramePhoneOrEmailTitle"):SetText(GetS(3414));
	getglobal("BindingPhoneEmailFramePhoneEdit"):Hide();
	getglobal("BindingPhoneEmailFramePhoneCoderBtn"):Hide();
	getglobal("BindingPhoneEmailFrameEmailEdit"):Show();
	getglobal("BindingPhoneEmailFrameEmailCoderBtn"):Show();
	getglobal("BindingPhoneEmailFrameFaceBookBindingBtn"):Hide();
	SetCurEditBox("BindingPhoneEmailFramePhoneEdit");

	getglobal("BindingPhoneEmailFrameBindingBtnText"):SetText(GetS(381));
end

--绑定微信
function BindingWeChatBtn_OnClick()
	if IsStandAloneMode() then
		ShowGameTipsWithoutFilter(GetS(32169))
		return
	end
	local bind_source = 0
	if g_open_accountmanagerui_source == 3 then
		bind_source = 3
	else
		if g_from_activity_ui_open_account_manager_ui == 1 then
			bind_source = 2
		else
			bind_source = 1
		end
	end
	BindingOrUnbound = 1;
	if ClientMgr:isPC() then
		local param = {method="bind",type="wechat",op = 1,bindfrom="bind",source_open=bind_source}
		GetInst("UIManager"):Open("QQWeChatLoginPC",param)
	else
		SdkManager:sdkLogin(2);
	end
	GetInst("QQWeChatLoginManager"):SetLoginQQWeChatSdkUserData("wechat","Bind",1)
end

--解绑微信
function UnboundWeChatBtn_OnClick()
	if IsStandAloneMode() then
		ShowGameTipsWithoutFilter(GetS(32168))
		return
	end
	local account_svr = AccountManager.account and AccountManager.account.Account
	local pwdChangeTime = account_svr.AccountBindTime or 0
	if pwdChangeTime <= 0 then --该迷你号还没有设置密码，不允许解绑微信
		--tips提示~~~
		ShowGameTipsWithoutFilter(GetS(32167))
		return;
	end

	local bind_source = 0
	if g_open_accountmanagerui_source == 3 then
		bind_source = 3
	else
		if g_from_activity_ui_open_account_manager_ui == 1 then
			bind_source = 2
		else
			bind_source = 1
		end
	end
	BindingOrUnbound = 2;
	if ClientMgr:isPC() then
		local param = {method="bind",type="wechat",op = 0,bindfrom="bind",source_open=bind_source}
		GetInst("UIManager"):Open("QQWeChatLoginPC",param)
	else
		SdkManager:sdkLogin(2);
	end
	GetInst("QQWeChatLoginManager"):SetLoginQQWeChatSdkUserData("wechat","UnBind",1)
end

--绑定QQ
function BindingQQBtn_OnClick()
	if IsStandAloneMode() then
		ShowGameTipsWithoutFilter(GetS(32169))
		return
	end
	local bind_source = 0
	if g_open_accountmanagerui_source == 3 then
		bind_source = 3
	else
		if g_from_activity_ui_open_account_manager_ui == 1 then
			bind_source = 2
		else
			bind_source = 1
		end
	end
	BindingOrUnbound = 1;
	if ClientMgr:isPC() then
		local param = {method="bind",type="qq",op = 1,bindfrom="bind",source_open=bind_source}
		GetInst("UIManager"):Open("QQWeChatLoginPC",param)
	else
		SdkManager:sdkLogin(1)
	end
	GetInst("QQWeChatLoginManager"):SetLoginQQWeChatSdkUserData("qq","Bind",1)
end

--解绑QQ
function UnboundQQBtn_OnClick()
	if IsStandAloneMode() then
		ShowGameTipsWithoutFilter(GetS(32168))
		return
	end
	local account_svr = AccountManager.account and AccountManager.account.Account
	local pwdChangeTime = account_svr.AccountBindTime or 0
	if pwdChangeTime <= 0 then --该迷你号还没有设置密码，不允许解绑QQ
		--tips提示~~~
		ShowGameTipsWithoutFilter(GetS(32167))
		return;
	end
	local bind_source = 0
	if g_open_accountmanagerui_source == 3 then
		bind_source = 3
	else
		if g_from_activity_ui_open_account_manager_ui == 1 then
			bind_source = 2
		else
			bind_source = 1
		end
	end
	BindingOrUnbound = 2;
	if ClientMgr:isPC() then
		local param = {method="bind",type="qq",op = 0,bindfrom="bind",source_open=bind_source}
		GetInst("UIManager"):Open("QQWeChatLoginPC",param)
	else
		SdkManager:sdkLogin(1)
	end
	GetInst("QQWeChatLoginManager"):SetLoginQQWeChatSdkUserData("qq","UnBind",1)
end

function FreshBindQQAndWeChatUI(bindType,result,platform)
	if bindType == 1 then -- 解绑
		if result == 0 then
			if platform == "qq" then
				local bindedQQIcon = getglobal("SecuritySettingContentBindedQQIcon");
				local qqText = getglobal("SecuritySettingContentBindedQQ");
				local bindingQQButton = getglobal("SecuritySettingContentBindingQQBtn");
				local unboundQQBtn = getglobal("SecuritySettingContentUnboundQQBtn");
				qqText:SetText(GetS(3416));
				bindedQQIcon:Show();
				bindingQQButton:Hide();
				unboundQQBtn:Show();
				PCBindedResult.platform = "qq"
				PCBindedResult.bindingOrUnBind = true
			elseif platform == "wechat" then
				local bindedWeCharIcon = getglobal("SecuritySettingContentBindedWeChatIcon");
				local weChatText = getglobal("SecuritySettingContentBindedWeChat");
				local bindingWeChatButton = getglobal("SecuritySettingContentBindingWeChatBtn");
				local unboundWeChatBtn = getglobal("SecuritySettingContentUnboundWeChatBtn");
				weChatText:SetText(GetS(3416));
				bindedWeCharIcon:Show();
				bindingWeChatButton:Hide();
				unboundWeChatBtn:Show();
				PCBindedResult.platform = "wechat"
				PCBindedResult.bindingOrUnBind = true
			end
		end
	elseif bindType == 0 then --绑定
		if result == 0 then
			if platform == "qq" then
				local bindedQQIcon = getglobal("SecuritySettingContentBindedQQIcon");
				local qqText = getglobal("SecuritySettingContentBindedQQ");
				local bindingQQButton = getglobal("SecuritySettingContentBindingQQBtn");
				local unboundQQBtn = getglobal("SecuritySettingContentUnboundQQBtn");
				qqText:SetText(GetS(3434));
				bindedQQIcon:Hide();
				bindingQQButton:Show();
				unboundQQBtn:Hide();
				PCBindedResult.platform = "qq"
				PCBindedResult.bindingOrUnBind = false
			elseif platform == "wechat" then
				local bindedWeCharIcon = getglobal("SecuritySettingContentBindedWeChatIcon");
				local weChatText = getglobal("SecuritySettingContentBindedWeChat");
				local bindingWeChatButton = getglobal("SecuritySettingContentBindingWeChatBtn");
				local unboundWeChatBtn = getglobal("SecuritySettingContentUnboundWeChatBtn");
				weChatText:SetText(GetS(3434));
				bindedWeCharIcon:Hide();
				bindingWeChatButton:Show();
				unboundWeChatBtn:Hide();
				PCBindedResult.platform = "wechat"
				PCBindedResult.bindingOrUnBind = false
			end
		end
	end
end

-- 未使用
function PCWebWeChatAndQQCallBack(platform,bindType,result,authCode)
	local LoginQQWeChatUserData = GetInst("QQWeChatLoginManager"):GetLoginQQWeChatSdkUserData()
	if LoginQQWeChatUserData.from == "Bind" or LoginQQWeChatUserData.from == "UnBind" then
		FreshBindQQAndWeChatUI(bindType,result,platform)
	elseif LoginQQWeChatUserData.from == "BindUinAndLoginInGame" then
		if result == 0 then
			local info = {}
			if platform == "qq" then
				info.appid = "101901986"
			elseif platform == "wechat" then
				info.appid = "wx0344e7ba7bfcacaf"
			end
			info.code = authCode
			info.apiid = ClientMgr:getApiId()
			if LoginQQWeChatUserData.inner_from and LoginQQWeChatUserData.inner_from == 1 then
				local LoginData = GetInst("QQWeChatLoginManager"):GetBindUinAndLoginData()
				if not LoginData or not next(LoginData) then
					print("========PC BindUinAndLoginInGame OCCURS ERROR!!!===========")
					return
				end
				info.uin = tonumber(LoginData.Uin or 0)
				if LoginData.Type == "number" then
					info.passwd = LoginData.PassWord
				else
					info.key = LoginData.Question
					info.value = LoginData.PassWord
				end
				GetInst("QQWeChatLoginManager"):BindAndLogin(info,function ()
					FreshBindQQAndWeChatUI(bindType,result,platform)
				end)
			else
				--注册绑定并登录
				GetInst("QQWeChatLoginManager"):RegisterAccountAndBindLogin(info,function ()
					FreshBindQQAndWeChatUI(bindType,result,platform)
				end)
			end
		end
	elseif LoginQQWeChatUserData.from == "BindUinAndLoginOutGame" then
		if result == 0 then
			local info = {}
			if platform == "qq" then
				info.appid = "101901986"
			elseif platform == "wechat" then
				info.appid = "wx0344e7ba7bfcacaf"
			end
			info.code = authCode
			info.apiid = ClientMgr:getApiId()
			FreshBindQQAndWeChatUI(bindType,result,platform)
			if LoginQQWeChatUserData.inner_from and LoginQQWeChatUserData.inner_from == 1 then
				local LoginData = GetInst("QQWeChatLoginManager"):GetBindUinAndLoginData()
				if not LoginData or not next(LoginData) then
					print("========PC BindUinAndLoginOutGame OCCURS ERROR!!!===========")
					return
				end
				info.uin = tonumber(LoginData.Uin or 0)
				if LoginData.Type == "number" then
					info.passwd = LoginData.PassWord
				else
					info.key = LoginData.Question
					info.value = LoginData.PassWord
				end
				GetInst("QQWeChatLoginManager"):BindAndLogin(info)
			else
				--注册绑定并登录
				GetInst("QQWeChatLoginManager"):RegisterAccountAndBindLogin(info)
			end
		end
	end
	GetInst("QQWeChatLoginManager"):ResetLoginQQWeChatSdkUserData()
end

function MobileBindQQWeChatFreshUI(type)
	if type == 1 then
		local bindedQQIcon = getglobal("SecuritySettingContentBindedQQIcon");
		local qqText = getglobal("SecuritySettingContentBindedQQ");
		local bindingQQButton = getglobal("SecuritySettingContentBindingQQBtn");
		local unboundQQBtn = getglobal("SecuritySettingContentUnboundQQBtn");
		qqText:SetText(GetS(3416));
		bindedQQIcon:Show();
		bindingQQButton:Hide();
		unboundQQBtn:Show();
		local bindQQBtn = getglobal("MiniLobbyFrameTopBindQQBtn")
		if bindQQBtn and bindQQBtn:IsShown() and isIOSShouQ() then
			bindQQBtn:Hide();
		end
	elseif type == 2 then
		local bindedWeCharIcon = getglobal("SecuritySettingContentBindedWeChatIcon");
		local weChatText = getglobal("SecuritySettingContentBindedWeChat");
		local bindingWeChatButton = getglobal("SecuritySettingContentBindingWeChatBtn");
		local unboundWeChatBtn = getglobal("SecuritySettingContentUnboundWeChatBtn");
		weChatText:SetText(GetS(3416));
		bindedWeCharIcon:Show();
		bindingWeChatButton:Hide();
		unboundWeChatBtn:Show();
	end
end

-- 第三方登陆回调函数
function SDKLoginCallBack(type,appId,authCode,result)
	if IsEnableNewAccountSystem() then
		threadpool:work(function ()
			while getglobal("LoginScreenFrameProgress"):IsShown() or not GetInst("QQWeChatLoginManager") do  
				threadpool:wait(0.1)
			end	
			
			NewLoginSystem_SDKLoginCallBack(type,appId,authCode,result)
			end)	
		return
	end
end

-------------------------------------- luoshun 海外绑定账号 --------------------------------------------------------------------------------------------------------


local faceBook_LoginType = -1; 			--   1 FaceBook绑定 2 Facebook登录
local is_facebook_login = false;
local facebook_id = nil;
local facebook_token = nil;
local facebook_nickname = nil;

-- 初始化Facebook登录信息
function ConstructorFacebookAccountInfo(loginType)  -- loginType : 1 Facebook绑定； 2 Facebook登录
	faceBook_LoginType = loginType;
	is_facebook_login = false;
	facebook_id = nil;
	facebook_token = nil;
	facebook_nickname = nil;
end

--清理facebook登录信息
function DestructFacebookAccountInfo()
	faceBook_LoginType = -1;
	is_facebook_login = false;
	facebook_id = nil
	facebook_token = nil
	facebook_nickname = nil;
end

-- 获取Facebook登录信息
function GetFacebookLoginInfo()
	return is_facebook_login, facebook_token, facebook_id, facebook_nickname;
end

-- 点击了绑定FaceBook账号按钮
function AccountFrameBindingFaceBookAcountBtn_OnClick()
	--LLDO:13岁保护模式特殊处理: 不让点击, 点击飘字
	if IsProtectMode() then
		ShowGameTips(GetS(20211), 3);
		return;
	end

	ConstructorFacebookAccountInfo(1);
	SdkManager:sdkAccountBinding(1);
end


function BindingFaceBookGoogleFrameCloseBtn_OnClick()
	getglobal("BindingFaceBookGoogleFrame"):Hide();
end

--切换FB账号按钮进行绑定
function BindingFrameSwitchBtn_OnClick()
	if 1 == faceBook_LoginType then
		ConstructorFacebookAccountInfo(1);
		SdkManager:sdkAccountBinding(1);   				--1 FaceBook绑定  2 FaceBook登陆
	end
end

--确认绑定按钮
function BindingFaceBookGoogleFrameBindingBtn_OnClick()
	Log("luoshun BindingFaceBookGoogleFrameBindingBtn_OnClick faceBook_LoginType : "..faceBook_LoginType);
	--binding FaceBook
	if 1 == faceBook_LoginType then
		local nickName = getglobal("BindingFaceBookGoogleFrameFaceBookOrGoogleId"):GetText();
		local uin = getglobal("BindingFaceBookGoogleFrameUin"):GetText();
		if  AccountManager.bind_facebook then
			Log("luoshun BindingFaceBookGoogleFrameBindingBtn_OnClick AccountManager:bind_facebook facebook_id="..facebook_id..", facebook_token="..facebook_token.."\n nickName="..nickName);
			local code = AccountManager:bind_facebook(facebook_id, facebook_token, nickName);
			Log("AccountManager:bind_facebook result : "..code);
			if code == ErrorCode.OK then
				getglobal("BindingFaceBookGoogleFrame"):Hide();
				DestructFacebookAccountInfo();
				ShowGameTips(GetS(3428), 3);
			else
				if t_ErrorCodeToString then
					ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
				else
					ShowGameTips(GetS(3436), 3);
				end
			end
		end
	end
end

function BindingFaceBookGoogleFrame_OnHide()
	getglobal("BindingFaceBookGoogleFrameFaceBookOrGoogleId"):SetText("");
	if faceBook_LoginType == 1 then
		DestructFacebookAccountInfo();
	end
	facebook_token = nil;
end

function HideBindingFaceBookBtn()
	local faceBookTitle = getglobal("SecuritySettingContentFaceBookTitle");
	local faceBookBkg = getglobal("SecuritySettingContentFaceBookBkg");
	local faceBookText = getglobal("SecuritySettingContentBindedFaceBook");
	local bindFaceBookButton = getglobal("SecuritySettingContentBindingFaceBookBtn");
	local bindFaceBookIcon = getglobal("SecuritySettingContentBindedFaceBookIcon");

	faceBookTitle:Hide();
	faceBookBkg:Hide();
	faceBookText:Hide();
	bindFaceBookButton:Hide();
	bindFaceBookIcon:Hide();
end

function BindingPhoneEmailFrameFaceBookBindingBtn_OnClick()
	BindingPhoneEmailFrameCloseBtn_OnClick();
	AccountFrameBindingFaceBookAcountBtn_OnClick();
end

-------------------------------------- luoshun FaceBook账号登陆-----------------------------------------------
function AccountLoginFrameFaceBookLoginBtn_OnClick()
	--LLDO:13岁保护模式特殊处理: 不让点击, 点击飘字
	--if IsProtectMode() then
	--	ShowGameTips(GetS(20211), 3);
	--	return;
	--end
	
	ConstructorFacebookAccountInfo(2);							-- 1 绑定Facebook   2 登录Facebook
	MessageBox(7, GetS(6558));
	getglobal("MessageBoxFrame"):SetClientString( "海外切换帐号二级确定" );
end


-- 获取第三方登陆信息
function GetFaceBookInfo(jsonstr, token)
    threadpool:work(function ()
        if token == "onCancel" then
            ShowGameTips(GetS(6563), 3);
            return;
        elseif token == "onError" then
            ShowGameTips(GetS(6564), 3);
            return;
        end

        -- 隐藏 "切换FB账号" 按钮
        local FBSwitchBtn = getglobal("BindingFaceBookGoogleFrameSwitchBtn");
    	FBSwitchBtn:Hide();

        if nil ~= jsonstr and nil ~= token then
        	local userDates = JSON:decode(jsonstr);
        	local userId = userDates["userId"];
        	local nickName = userDates["nickName"];

            ShowGameTips(GetS(6562), 3); 
            local uin = AccountManager:getUin();
            Log("binding_info Token: "..token..", userId : "..userId..", Uin : "..uin..", faceBook_LoginType="..faceBook_LoginType);
            facebook_id = userId;
            facebook_token = token;
            facebook_nickname = nickName;
            if 1 == faceBook_LoginType then  			-- Facebook账号登录成功
                getglobal("BindingFaceBookGoogleFrameUin"):SetText(uin);
                getglobal("BindingFaceBookGoogleFrameFaceBookOrGoogleId"):SetText(nickName);
                getglobal("BindingFaceBookGoogleFrameChenDi"):SetHeight(460);
                AccountLoginFrameCloseBtn_OnClick();
                local content = getglobal("BindingFaceBookGoogleFrame");
                if not content:IsShown() then
                    content:Show();
                end

                getglobal("BindingFaceBookGoogleFrameTitle"):SetText(GetS(6554));
                getglobal("BindingFaceBookGoogleFrameFaceBookOrGoogleTitle"):SetText(GetS(6555));
                getglobal("BindingFaceBookGoogleFrameUinTitle"):SetText(GetS(3070));
                getglobal("BindingFaceBookGoogleFrameFaceBookGoogleTips"):SetText(GetS(6556))
            elseif 2 == faceBook_LoginType then
                is_facebook_login = true;
                Log("GetFaceBookInfo facebook_id="..facebook_id..", facebook_token="..facebook_token..",\nfacebook_nickname="..facebook_nickname);
                local result, code, msg = AccountManager:switchAccountByOpenString(facebook_id, facebook_token, facebook_nickname);
                if result and code == ErrorCode.OK then
					ShowGameTips("-- facebook账号切换成功", 3);
					if msg and type(msg) == "string" and IsEnableNewLogin and IsEnableNewLogin() then
						LoginManager:InnerLoginLogic(msg)
					end
                    -- ShowGameTips()
                else
                    ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
                end
            end
        end
    end )
end

--type : 1 绑定手机. 2 绑定邮箱.
function ResetBindingPhoneEmailFrame(type)
	getglobal("BindingPhoneEmailFrameChenDi"):SetHeight(480);
	getglobal("BindingPhoneEmailFramePhoneOrEmailTips"):Show();
	local tipsObj = getglobal("BindingPhoneEmailFramePhoneOrEmailTips");
	if type == 1 then
		tipsObj:SetText(GetS(3571))
	elseif type == 2 then
		tipsObj:SetText(GetS(3567))
	elseif type == 3 then
		tipsObj:SetText(GetS(100213))
	elseif type == 4 then
		tipsObj:SetText(GetS(100212))
	end

	--getglobal("BindingPhoneEmailFrameTitleFrameTitle"):SetPoint("topleft", "BindingPhoneEmailFrameTitleFrame", "topleft", 53, 6);
	--getglobal("BindingPhoneEmailFramePhoneOrEmailTitle"):SetPoint("topright", "BindingPhoneEmailFramecontentBkg", "topleft", 165, 27);
	--getglobal("BindingPhoneEmailFramePhoneOrEmailTips"):SetPoint("topleft", "BindingPhoneEmailFramecontentBkg", "bottomleft", 20, 15);
end

function BindingPhoneEmailFrameCloseBtn_OnClick()
	HidePhtoneBindingAwardFrame();
end

function BindingPhoneEmailFramePhoneEdit_OnEnterPressed()
	SetCurEditBox("BindingPhoneEmailFrameVCEdit");
end

function BindingPhoneEmailFramePhoneEdit_OnTabPressed()
	SetCurEditBox("BindingPhoneEmailFrameVCEdit");
end

function BindingPhoneEmailFrameEmailEdit_OnEnterPressed()
	SetCurEditBox("BindingPhoneEmailFrameVCEdit");
end

function BindingPhoneEmailFrameEmailEdit_OnTabPressed()
	SetCurEditBox("BindingPhoneEmailFrameVCEdit");
end

--获取验证码按钮
function BindingFrameRequestVCBtn_OnClick()
	--request mobile vc
	if BindingType == 0 then
		local phoneEdit = getglobal("BindingPhoneEmailFramePhoneEdit")
		local mobile = NewAccountHelper:GetEditBoxText(phoneEdit)
		if CheckMobileValid(mobile) then
			-- -1获取失败
			--0成功 1 类型错误 2数据错误 3手机或邮箱已绑定过 4验证码已发出在冷却 5账号已绑定了手机或者邮箱

			local result = NewAccountService:SendVerifyCode(NewAccountHelper.ACCOUNT_TAG_PHONE, NewAccountHelper.FEATURE_NORMAL, 1, mobile)
			if result == ErrorCode.OK then
				getglobal("BindingPhoneEmailFrameRequestVCBtn"):Disable();
				getglobal("BindingPhoneEmailFrameRequestVCBtnNormal"):SetGray(true);
				ShowGameTips(GetS(3431), 3);
				RequestCoolDown = 60;
				CoolTimeUpdate(RequestCoolDown, 0);
			else
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[result]), 3);
			-- elseif result == 3 then
			-- 	ShowGameTips(GetS(3429).." "..result, 3);
			-- elseif result == 4 then
			-- 	ShowGameTips(GetS(3432).." "..result, 3);
			-- elseif result == 5 then
			-- 	ShowGameTips(GetS(3435).." "..result, 3);
			-- else
			-- 	ShowGameTips(GetS(3433).." "..result, 3);
			end
		else
			ShowGameTips(GetS(3419), 3);
		end

	--request email vc
	elseif BindingType == 1 then
		local emailEdit = getglobal("BindingPhoneEmailFrameEmailEdit")
		local email = NewAccountHelper:GetEditBoxText(emailEdit)
		if CheckEmailValid(email) then

			local result = AccountManager:requestEmailVerificationCode(email, 1);
			if result == 0 then
				getglobal("BindingPhoneEmailFrameRequestVCBtn"):Disable();
				getglobal("BindingPhoneEmailFrameRequestVCBtnNormal"):SetGray(true);
				ShowGameTips(GetS(3431), 3);
				RequestCoolDown = 60;
				CoolTimeUpdate(RequestCoolDown, 0);
			else
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[result]), 3);
			-- elseif result == 3 then
			-- 	ShowGameTips(GetS(3429).." "..result, 3);
			-- elseif result == 4 then
			-- 	ShowGameTips(GetS(3432).." "..result, 3);
			-- elseif result == 5 then
			-- 	ShowGameTips(GetS(3435).." "..result, 3);
			-- else
			-- 	ShowGameTips(GetS(3307).." "..result, 3);
			end
		else
			ShowGameTips(GetS(3420), 3);
		end
	elseif BindingType == 3 then	--手机解绑
		local phoneEdit = getglobal("BindingPhoneEmailFramePhoneEdit")
		local mobile = NewAccountHelper:GetEditBoxText(phoneEdit)
		if CheckMobileValid(mobile) then
			local result = NewAccountService:SendVerifyCode(NewAccountHelper.ACCOUNT_TAG_PHONE, NewAccountHelper.FEATURE_NORMAL, 2, mobile)
			if result == ErrorCode.OK then
				getglobal("BindingPhoneEmailFrameRequestVCBtn"):Disable();
				getglobal("BindingPhoneEmailFrameRequestVCBtnNormal"):SetGray(true);
				ShowGameTips(GetS(3431), 3);
				RequestCoolDown = 60;
				CoolTimeUpdate(RequestCoolDown, 0);
			else
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[result]), 3);
			end
		else
			ShowGameTips(GetS(3419), 3);
		end
	elseif BindingType == 4 then	--邮箱解绑		
		local emailEdit = getglobal("BindingPhoneEmailFrameEmailEdit")
		local email = NewAccountHelper:GetEditBoxText(emailEdit)
		if CheckEmailValid(email) then
			local result = AccountManager:requestEmailVerificationCode(email, 2);
			if result == 0 then
				getglobal("BindingPhoneEmailFrameRequestVCBtn"):Disable();
				getglobal("BindingPhoneEmailFrameRequestVCBtnNormal"):SetGray(true);
				ShowGameTips(GetS(3431), 3);
				RequestCoolDown = 60;
				CoolTimeUpdate(RequestCoolDown, 0);
			else
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[result]), 3);
			end
		else
			ShowGameTips(GetS(3420), 3);
		end
	end
end

function BindingPhoneEmailFrameVCEdit_OnEnterPressed()
	BindingPhoneEmailFrameBindingBtn_OnClick();
end

function BindingPhoneEmailFrameVCEdit_OnTabPressed()
	local edit = getglobal("BindingPhoneEmailFramePhoneEdit");
	if edit:IsShown() then
		SetCurEditBox("BindingPhoneEmailFramePhoneEdit");
	else
		SetCurEditBox("BindingPhoneEmailFrameEmailEdit");
	end
end

--确认绑定按钮
function BindingPhoneEmailFrameBindingBtn_OnClick()
	--binding mobile 
	if BindingType == 0 then
		local phoneEdit = getglobal("BindingPhoneEmailFramePhoneEdit")
		local mobile = NewAccountHelper:GetEditBoxText(phoneEdit)
		if CheckMobileValid(mobile) then
			local vcEdit = getglobal("BindingPhoneEmailFrameVCEdit")
			local vc = NewAccountHelper:GetEditBoxText(vcEdit)

			if CheckVCValid(vc) then
				local code = AccountManager:requestMobileVerifyCode(mobile, vc, 1)
				if code == ErrorCode.OK then
					getglobal("BindingPhoneEmailFrame"):Hide();
					ShowGameTips(GetS(3428), 3);
					BpReportEventOnHold("authphone")
				else
					if t_ErrorCodeToString then
						ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3)
					else
						ShowGameTips(GetS(3421), 3);
					end
				end
				
				if AccountManager.data_update then
					AccountManager:data_update();
				end
			else
				ShowGameTips(GetS(3421), 3);
			end
		else
			ShowGameTips(GetS(3419), 3);
		end
	--binding email
	elseif BindingType == 1 then
		local emailEdit = getglobal("BindingPhoneEmailFrameEmailEdit")
		local email = NewAccountHelper:GetEditBoxText(emailEdit)
		if CheckEmailValid(email) then
			local vcEdit = getglobal("BindingPhoneEmailFrameVCEdit")
			local vc = NewAccountHelper:GetEditBoxText(vcEdit)
			if CheckVCValid(vc) then
				local code = AccountManager:requestVerifyEmail(email, vc, 1);
				if code == ErrorCode.OK then
					getglobal("BindingPhoneEmailFrame"):Hide();
					ShowGameTips(GetS(3428), 3);
					BpReportEventOnHold("authmail")
				else
					if t_ErrorCodeToString then
						ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3)
					else
						ShowGameTips(GetS(3421), 3);
					end
				end
			else
				ShowGameTips(GetS(3421), 3);
			end
		else
			ShowGameTips(GetS(3420), 3);
		end
	elseif BindingType == 3 then
		local phoneEdit = getglobal("BindingPhoneEmailFramePhoneEdit")
		local mobile = NewAccountHelper:GetEditBoxText(phoneEdit)
		if CheckMobileValid(mobile) then
			local vcEdit = getglobal("BindingPhoneEmailFrameVCEdit")
			local vc = NewAccountHelper:GetEditBoxText(vcEdit)
			if CheckVCValid(vc) then
				local code = AccountManager:requestMobileVerifyCode(mobile, vc, 2)
				if code == ErrorCode.OK then
					getglobal("BindingPhoneEmailFrame"):Hide();
					ShowGameTips(GetS(100214), 3);
				else
					
				end
			else
				ShowGameTips(GetS(3421), 3);
			end
		else
			ShowGameTips(GetS(3419), 3);
		end

		if AccountManager.data_update then
			--实名弹框埋点记录场景
			IdentityNameAuthClass:SetStatisticsPopupScene(IdentityNameAuthClass.StatisticsPopupScene.bindedPhone)

			AccountManager:data_update();
		end
	elseif BindingType == 4 then
		local emailEdit = getglobal("BindingPhoneEmailFrameEmailEdit")
		local email = NewAccountHelper:GetEditBoxText(emailEdit)
		if CheckEmailValid(email) then
			local vcEdit = getglobal("BindingPhoneEmailFrameVCEdit")
			local vc = NewAccountHelper:GetEditBoxText(vcEdit)
			if CheckVCValid(vc) then
				print("BindingPhoneEmailFrameBindingBtn_OnClick4", email, vc)
				local code = AccountManager:requestVerifyEmail(email, vc, 2);
				if code == ErrorCode.OK then
					getglobal("BindingPhoneEmailFrame"):Hide();
					ShowGameTips(GetS(100214), 3);
				else

				end
			else
				ShowGameTips(GetS(3421), 3);
			end
		else
			ShowGameTips(GetS(3420), 3);
		end
	end
end


function BindingPhoneEmailFrame_OnLoad()

end

function BindingPhoneEmailFrame_OnShow()
	local getglobal = _G.getglobal
	getglobal("BindingPhoneEmailFrameRequestVCBtn"):Enable();
	getglobal("BindingPhoneEmailFrameRequestVCBtnNormal"):SetGray(false);
	local buttonText = getglobal("BindingPhoneEmailFrameRequestVCBtnText");
	buttonText:SetText(GetS(3417));
	SetArchiveDealMsg(false);
	if RequestCoolDown > 0 then
		local buttonText = getglobal("BindingPhoneEmailFrameRequestVCBtnText");
		buttonText:SetText(GetS(3430).."("..math.floor(RequestCoolDown)..")");
		getglobal("BindingPhoneEmailFrameRequestVCBtn"):Disable();
		getglobal("BindingPhoneEmailFrameRequestVCBtnNormal"):SetGray(true);
	else
		buttonText:SetText(GetS(3430));
		getglobal("BindingPhoneEmailFrameRequestVCBtn"):Enable();
		getglobal("BindingPhoneEmailFrameRequestVCBtnNormal"):SetGray(false);
	end

	TemplateEditBoxCoderBtn_OnShow(getglobal("BindingPhoneEmailFramePhoneEdit"), getglobal("BindingPhoneEmailFramePhoneCoderBtn"))
	TemplateEditBoxCoderBtn_OnShow(getglobal("BindingPhoneEmailFrameEmailEdit"), getglobal("BindingPhoneEmailFrameEmailCoderBtn"))
	TemplateEditBoxCoderBtn_OnShow(getglobal("BindingPhoneEmailFrameVCEdit"), getglobal("BindingPhoneEmailFrameVCCoderBtn"))
end

function BindingPhoneEmailFrame_OnHide()
	getglobal("BindingPhoneEmailFramePhoneEdit"):Clear();
	getglobal("BindingPhoneEmailFrameEmailEdit"):Clear();
	getglobal("BindingPhoneEmailFrameVCEdit"):Clear();
	BindingType = -1;
	--IsInRequestCoolDown = false;
	--RequestCoolDown = 60;
	SetArchiveDealMsg(true);
end


function BindingPhoneEmailFrame_OnUpdate()
	--[[
	if IsInRequestCoolDown then
		RequestCoolDown = RequestCoolDown - arg1;
		local buttonText = getglobal("BindingPhoneEmailFrameRequestVCBtnText");
		buttonText:SetText(StringDefCsv:get(3430).."("..math.floor(RequestCoolDown)..")");

		if RequestCoolDown < 0 then
			buttonText:SetText(StringDefCsv:get(3430));
			IsInRequestCoolDown = false;
			RequestCoolDown = 60;
			getglobal("BindingPhoneEmailFrameRequestVCBtn"):Enable();
			getglobal("BindingPhoneEmailFrameRequestVCBtnNormal"):SetGray(false);
		end
	end]]
end

--获取手机验证码
function GetMobileVCBtn_OnClick()
	local mobile = getglobal("bindingMobileNumberEdit"):GetText();
	if CheckMobileValid(mobile) then
		if NewAccountService:SendVerifyCode(NewAccountHelper.ACCOUNT_TAG_PHONE, NewAccountHelper.FEATURE_NORMAL, 1, mobile) then
			ShowGameTips(GetS(3427), 3);
		end
	else
		ShowGameTips(GetS(3419), 3);
	end
end

--绑定手机
function  AccountBindingMobileBtn_OnClick()
	local mobile = getglobal("bindingMobileNumberEdit"):GetText();
	if CheckMobileValid(mobile) then
		local vc = getglobal("bindingMobileVCEdit"):GetText();

		if CheckVCValid(vc) then
			if AccountManager:requestBindingMobile(mobile, vc) then
				AccountManager:addFeedBack();
			end
		else
			ShowGameTips(GetS(3421), 3);
		end
	else
		ShowGameTips(GetS(3419), 3);
	end

end

--获取邮箱验证码
function GetEmailVCBtn_OnClick()
	local email = getglobal("bindingEmailAddressEdit"):GetText();
	if CheckEmailValid(email) then
		if AccountManager:requestEmailVerificationCode(email) then
			AccountManager:addFeedBack();
		end
	else
		ShowGameTips(GetS(3420), 3);
	end
end

--绑定邮箱
function  AccountBindingEmailBtn_OnClick()
	local email = getglobal("bindingEmailAddressEdit"):GetText();
	local vc = getglobal("bindingEmailVCEdit"):GetText();
	if CheckEmailValid(email) then
		if CheckVCValid(vc) then
			if AccountManager:requestBindingEmail(mobile, vc) then
				AccountManager:addFeedBack();
			else
			end
		else
			ShowGameTips(GetS(3421), 3);
		end
	else
		ShowGameTips(GetS(3420), 3);
	end
end


function CheckMobileValid(mobile)
	return string.match(mobile,"[1][3,4,5,6,7,8,9]%d%d%d%d%d%d%d%d%d") == mobile;
end

function CheckEmailValid(email)
	return string.match(email,"[A-Za-z0-9%_%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") == email;
end

function CheckVCValid(vc)
	return string.match(vc,"%d%d%d%d%d%d") == vc;
end

function CheckMinihaoValid(minihao)
	return string.match(minihao, "[0-9]+") == minihao;
end

--切换输入框 隐藏/显示 按钮
function BindingPhoneEmailFramePhoneCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("BindingPhoneEmailFramePhoneEdit"), this)
end
function BindingPhoneEmailFramePhoneCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("BindingPhoneEmailFramePhoneEdit"), this)
end

function BindingPhoneEmailFrameEmailCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("BindingPhoneEmailFrameEmailEdit"), this)
end
function BindingPhoneEmailFrameEmailCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("BindingPhoneEmailFrameEmailEdit"), this)
end

function BindingPhoneEmailFrameVCCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("BindingPhoneEmailFrameVCEdit"), this)
end
function BindingPhoneEmailFrameVCCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("BindingPhoneEmailFrameVCEdit"), this)
end

---------------------------------------------4399登录---------------------------
TP4399LoginType = 0; --0普通登录 1绑定登录 2[Desc2]登录 3切换账号

local tp_info = {};
function ClearTPInfo()
	tp_info = {};
end

function IsTPLogin()
	if next(tp_info) == nil then
		Log('IsTPLogin false');
		return false;
	else
		Log('IsTPLogin true');
		return true;
	end
end

function action_SetAccountAuth_SandBox(uid, token, sign)
	local result =  AccountManager:setAccountAuth_SandBox(uid, token, sign);
	if SandboxMgr then
		local ret = {result}
		SandboxMgr:doActionRet(GE_SET_GAME_ACCOUNTAUTH, JSON:encode(ret));
	end
end
function LoginResult4399(result, uid, token, userName)
	Log("LoginResult4399:"..result.." "..uid.." "..token.." "..userName);
	ClearTPInfo();
	--if TP4399LoginType > 0 then
		if result == -1 then		--登录失败
			ShowGameTips(GetS(3740), 3);
		elseif result == 1 then		--登录成功
			tp_info = {["UID"]=uid, ["Token"]=token, ["UserName"]=userName};
			if TP4399LoginType == 1 then
				getglobal("Login4399Frame"):Show();
			elseif TP4399LoginType == 2 then
				--提示玩家继续[Desc2]
				if StorePayInfo.OnePayInfo then
					local t = StorePayInfo.OnePayInfo
					SdkPay(t.Name, t.Money, t.TradeId, t.Type);
				end

				StorePayInfo.OnePayInfo = nil;
			elseif TP4399LoginType == 3 then
				--LLTODO:切换4399账号登录
				local md5 = gFunc_getmd5("4399Game"..tp_info.UID)
				local openString = "state="..md5.."&uid="..tp_info.UID;
				Log("4399:changeAccount: accoutname:"..tp_info.UserName.."  openString:"..openString);
				local m_userName = "4399Game"..tp_info.UserName;
				local result, code, msg = AccountManager:switchAccountByOpenString(m_userName, openString);
				if code == ErrorCode.OK then
					if msg and type(msg) == "string" and IsEnableNewLogin and IsEnableNewLogin() then
						LoginManager:InnerLoginLogic(msg)
					end
                end
			end
		end
		TP4399LoginType = 0;
	--end
end

function Login4399FrameCloseBtn_OnClick()
	getglobal("Login4399Frame"):Hide();
end

function Login4399FrameBindingBtn_OnClick()
	if AccountManager:isBindTPAccount() then
		ShowGameTips(GetS(3751), 3);
		getglobal("Login4399Frame"):Hide();
	elseif IsTPLogin() then	
		local md5 = gFunc_getmd5("4399Game"..tp_info.UID)
		local openString = "state="..md5.."&uid="..tp_info.UID;
		Log("bindRealAccount: accoutname:"..tp_info.UserName.."  openString:"..openString);
		local userName = "4399Game"..tp_info.UserName;
		local result = CSMgr:bindRealAccount(userName, openString);
		Log("bindRealAccount result:"..result);
		if result == -1 then
			return;
		elseif result == 0 then
			text = GetS(3428);	
			getglobal("Login4399Frame"):Hide();
			Update4399LoginBtn();
		elseif result == 7 then	--此4399账号已经绑定了uin
			text = GetS(3744);
		else
			text = GetS(3272);
		end
		ShowGameTips(text, 3);
	else
		TP4399LoginType = 1;
		SdkManager:sdkLogin();
	end
end

function Login4399FrameSwitchBtn_OnClick()
	TP4399LoginType = 1;
	SdkManager:sdkSwitch();
	getglobal("Login4399Frame"):Hide();
end

function Login4399Frame_OnLoad()
	this:RegisterEvent("GE_TPLOGIN");
end

function Login4399Frame_OnEvent()
	if arg1 == "GE_TPLOGIN" then
		local ge 		= GameEventQue:getCurEvent();
		local result 	= ge.body.tplogin.result;
		local uid 	= ge.body.tplogin.uid;
		local token 	= ge.body.tplogin.token;
		local username 	= ge.body.tplogin.username;

		LoginResult4399(result, uid, token, username);
	end
end

function Login4399Frame_OnShow()
	getglobal("Login4399FrameSwitchBtn"):Hide();
	if AccountManager:isBindTPAccount() then
		getglobal("Login4399FrameBindingBtn"):SetPoint("bottom", "Login4399FrameChenDi", "bottom", 0, -10);
		local name = string.gsub(AccountManager:getAccountName(), "4399Game", "");		
		getglobal("Login4399FrameDesc"):SetText(GetS(3742, name, AccountManager:getUin()), 98, 65, 48);
		getglobal("Login4399FrameBindingBtnText"):SetText(GetS(3010));
	elseif IsTPLogin() then
		getglobal("Login4399FrameDesc"):SetText(GetS(3743, tp_info.UserName, AccountManager:getUin()), 98, 65, 48);
		getglobal("Login4399FrameBindingBtnText"):SetText(GetS(3415));
		getglobal("Login4399FrameBindingBtn"):SetPoint("bottom", "Login4399FrameChenDi", "bottom", -180, -10);
		getglobal("Login4399FrameSwitchBtn"):Show();
	else
		TP4399LoginType = 1;
		SdkManager:sdkLogin();
	end
end

--LLTODO:4399账号验证
function Check4399AccountFrameCloseBtn_OnClick()

	getglobal("Check4399AccountFrame"):Hide();
end

function Check4399AccountFrame_OnShow()	
	local InfoText = getglobal("Check4399AccountFrameInfoText");
	if nil ~= InfoText then
		InfoText:SetText(GetS(5231), 98, 65, 48);
	end
end

function Check4399AccountFrameCheckBtn_OnClick()
	local EditText = getglobal("Check4399AccountFrameEdit"):GetText();

	if nil == EditText or 0 == #EditText then
		MessageBox(4, GetS(5234));
		return;
	end

	--查询4399账号是否绑定迷你号
	if AccountManager:bindcheck(EditText) then
		--绑定了, 切换4399账号
		TP4399LoginType = 3;
		SdkManager:sdkSwitch();

		--LLTEST：模拟调用
		--LoginResult4399(1, 1234567, 0, "test");
	else
		MessageBox(4, GetS(5235));
	end
end

--刷新倒计时时间   
function CoolTimeUpdate(time, type_coro)   			-- type_coro  0绑定手机获取验证码冷却时间 1绑定获取验证码冷却时间 2手机重置密码获取验证码冷却时间 3邮箱重置密码获取验证码冷却时间
	threadpool:work(function ()
		while time >= 0 do
			time = time - 1;
			print("luoshun time", time, type_coro);
			UpdateVerifyCodeCoolDown(type_coro);

			threadpool:wait(1);
		end
	end)
end

function UpdateVerifyCodeCoolDown(type_coro)
	if RequestCoolDown > 0 and type_coro == 0 then
		RequestCoolDown = RequestCoolDown - 1;

		local content = getglobal("BindingPhoneEmailFrame");
		if content:IsShown() then
			local buttonText = getglobal("BindingPhoneEmailFrameRequestVCBtnText");
			buttonText:SetText(GetS(3430).."("..RequestCoolDown..")");

			if RequestCoolDown <= 0 then
				buttonText:SetText(GetS(3430));
				getglobal("BindingPhoneEmailFrameRequestVCBtn"):Enable();
				getglobal("BindingPhoneEmailFrameRequestVCBtnNormal"):SetGray(false);
			end
		end
	end

	if LoginRequestCoolDown > 0 and type_coro == 1 then  						-- and ValidateType == 1
		LoginRequestCoolDown = LoginRequestCoolDown - 1;
		
		if getglobal("PhoneValidateFrame") then
			local text = getglobal("PhoneValidateFrameRequestVCBtnText");
			if LoginRequestCoolDown <= 0 then
				text:SetText(GetS(3430));
				getglobal("PhoneValidateFrameRequestVCBtn"):Enable();
				getglobal("PhoneValidateFrameRequestVCBtnNormal"):SetGray(false);
			else
				text:SetText(GetS(3430).."("..LoginRequestCoolDown..")");
			end
		end
	end

	if ResetRequestCoolDown > 0 and type_coro == 2 then   						-- and ValidateType == 2
		ResetRequestCoolDown = ResetRequestCoolDown - 1;
		print("luoshun ResetRequestCoolDown=", ResetRequestCoolDown);
		
		-- if getglobal("PhoneValidateFrame") then
			local text = getglobal("PhoneValidateFrameRequestVCBtnText");
			if ResetRequestCoolDown <= 0 then
				text:SetText(GetS(3430));
				getglobal("PhoneValidateFrameRequestVCBtn"):Enable();
				getglobal("PhoneValidateFrameRequestVCBtnNormal"):SetGray(false);
			else
				text:SetText(GetS(3430).."("..ResetRequestCoolDown..")");
			end
		-- end
	end

	if ResetRequestCoolDown_Email > 0 and type_coro == 3 then 					-- and ValidateType == 3
		ResetRequestCoolDown_Email = ResetRequestCoolDown_Email - 1;

		-- if getglobal("EmailValidateFrame") then
			local text1 = getglobal("EmailValidateFrameRequestVCBtnText");
			if ResetRequestCoolDown_Email <= 0 then
				text1:SetText(GetS(3430));
				getglobal("EmailValidateFrameRequestVCBtn"):Enable();
				getglobal("EmailValidateFrameRequestVCBtnNormal"):SetGray(false);
				print("luoshun ResetRequestCoolDown_Email=", ResetRequestCoolDown_Email);
			else
				text1:SetText(GetS(3430).."("..ResetRequestCoolDown_Email..")");
				print("luoshun ResetRequestCoolDown_Email=", ResetRequestCoolDown_Email);
			end
		-- end
	end

	if RequestLodinCoolDown > 0 and type_coro == 4 then 					-- and 登陆验证
		RequestLodinCoolDown = RequestLodinCoolDown - 1;
		local text1 = getglobal("LoginSafetyCheckFrameRequestVCBtnText");
		if RequestLodinCoolDown <= 0 then
			text1:SetText(GetS(3430));
			getglobal("LoginSafetyCheckFrameRequestVCBtn"):Enable();
			getglobal("LoginSafetyCheckFrameRequestVCBtnNormal"):SetGray(false);
		else
			text1:SetText(GetS(3430).."("..RequestLodinCoolDown..")");
		end
	end
end

function AccountLoginFrameLoginContentPassWordCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("AccountLoginFrameLoginContentPasswordEdit"), this)
end

function AccountLoginFrameLoginContentPassWordCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("AccountLoginFrameLoginContentPasswordEdit"), this)
end

function AccountLoginFrameLoginContentStrAnswerCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("AccountLoginFrameLoginContentStrAnswer"), this)
end

function AccountLoginFrameLoginContentStrAnswerCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("AccountLoginFrameLoginContentStrAnswer"), this)
end

function DropDown_Hide()
	setkv("DropDown_OnClick",false);
	DropDown_OnClick();
end

function QQOptionConfig()
	return check_apiid_ver_conditions(ns_version.QQ_Entry_Option)
end

function WeChatOptionConfig()
	return check_apiid_ver_conditions(ns_version.WeChat_Entry_Option)
end

function DropDown_OnClick()
	local datadef = AccountManager:get_account_history_list();
	local mininum = #datadef;
	if mininum>10 then mininum=10 end
	if mininum<3 then
		getglobal("AccountLoginFrameLoginContentDropDownBoxPlane"):SetSize(200,204);
	else
		getglobal("AccountLoginFrameLoginContentDropDownBoxPlane"):SetSize(200,mininum*68);
	end
	for i=1,mininum do
		getglobal("AccountLoginFrameLoginContentDropDownBoxDropDownBox"..i):SetPoint("topleft",
			"AccountLoginFrameLoginContentDropDownBoxPlane","topleft",0,(i-1)*68);
		if datadef[i].NickName~=nil and datadef[i].Uin~=nil then 
			getglobal("AccountLoginFrameLoginContentDropDownBoxDropDownBox"..i.."Title1"):SetText(ReplaceFilterString(datadef[i].NickName));
			getglobal("AccountLoginFrameLoginContentDropDownBoxDropDownBox"..i.."Title2"):SetText(datadef[i].Uin);
			getglobal("AccountLoginFrameLoginContentDropDownBoxDropDownBox"..i):Show();
		end
	end

	if getglobal("AccountLoginFrameLoginContentDropDownBkg"):IsShown() then
		setkv("DropDown_OnClick",false);
		getglobal("AccountLoginFrameLoginContentDropDownBkg"):Hide();
		getglobal("AccountLoginFrameLoginBtn"):Show();
		getglobal("AccountLoginFrameLoginContentNumberPwdLogin"):Show();
		getglobal("AccountLoginFrameLoginContentTextPwdLogin"):Show();
		if WeChatOptionConfig() then
			getglobal("AccountLoginFrameLoginContentWeChatLogin"):Show();
		end
		if QQOptionConfig() then
			getglobal("AccountLoginFrameLoginContentQQLogin"):Show();
		end
		if ClientMgr:getGameData("LoginMethod")==0 then
			if ClientMgr:isPC() then
				getglobal("AccountLoginFrameLoginContentPassWordCoderBtn"):Show();
			end
			getglobal("AccountLoginFrameLoginContentPasswordEdit"):Show();
			getglobal("AccountLoginFrameLoginContentPasswordEditBkg"):Show();
		else
			--getglobal("AccountLoginFrameLoginContentQ1DropDown"):Show();
			--getglobal("AccountLoginFrameLoginContentQ1Content"):Show();
			getglobal("AccountLoginFrameLoginContentQ1"):Show();
			if ClientMgr:isPC() then
				getglobal("AccountLoginFrameLoginContentStrAnswerCoderBtn"):Show();
			end			
			getglobal("AccountLoginFrameLoginContentStrAnswer"):Show();
			getglobal("AccountLoginFrameLoginContentStrAnswerBkg"):Show();
		end
		for i=1,10 do
			getglobal("AccountLoginFrameLoginContentDropDownBoxDropDownBox"..i):Hide();
		end
	else
		setkv("DropDown_OnClick",true);
		getglobal("AccountLoginFrameLoginContentDropDownBkg"):Show();
		getglobal("AccountLoginFrameLoginContentDropDownBox"):Show();
		getglobal("AccountLoginFrameLoginBtn"):Hide();
		getglobal("AccountLoginFrameLoginContentNumberPwdLogin"):Hide();
		getglobal("AccountLoginFrameLoginContentTextPwdLogin"):Hide();
		getglobal("AccountLoginFrameLoginContentWeChatLogin"):Hide();
		getglobal("AccountLoginFrameLoginContentQQLogin"):Hide();
		if getglobal("AccountLoginFrameLoginContentPasswordTitle"):IsShown() then
			getglobal("AccountLoginFrameLoginContentPassWordCoderBtn"):Hide();
			getglobal("AccountLoginFrameLoginContentPasswordEdit"):Hide();
			getglobal("AccountLoginFrameLoginContentPasswordEditBkg"):Hide();
		else
			--getglobal("AccountLoginFrameLoginContentQ1DropDown"):Hide();
			--getglobal("AccountLoginFrameLoginContentQ1Content"):Hide();
			getglobal("AccountLoginFrameLoginContentQ1"):Hide();
			getglobal("AccountLoginFrameLoginContentQ1List"):Hide();
			getglobal("AccountLoginFrameLoginContentQ1ListBkg"):Hide();
			getglobal("AccountLoginFrameLoginContentStrAnswerCoderBtn"):Hide();
			getglobal("AccountLoginFrameLoginContentStrAnswer"):Hide();
			getglobal("AccountLoginFrameLoginContentStrAnswerBkg"):Hide();
		end
	end

end

function DropdownBox_OnClick()	
	DropDown_OnClick()
	local btnName = this:GetName();
	local num=tonumber(string.sub(btnName,-1));
	if num==0 then	num=10 end
	local datadef = AccountManager:get_account_history_list();
	if datadef~=nil and AccountManager:requestEnterGame2New() then 
		local uin = datadef[num].Uin;
		if type(uin) == 'number' and uin >= 1000 then
			ns_playercenter.uin = uin;
			ns_playercenter.func.WWW_get_player_profile(uin, refresh_WWW_get_self_profile )
		end	
		
		local result, errorcode = AccountManager:switch_account_by_history(uin, datadef[num].Passwd);
		if errorcode and errorcode == ErrorCode.OK then 
			AccountManager:enterGame2New();
        	AccountManager:accountDirty();
        	getglobal("LoginScreenFrame"):Hide();
		end
	end 
end

function AccountLoginFrameLayout(isNumberPwd)
	local frameWorkHeight = 496
	local contentBkgHeight = 370
	local loginContainerHeight = 256
	local loginMethod = getglobal("AccountLoginFrameLoginContentLoginMethodTitle")
	local numLoginBtn = getglobal("AccountLoginFrameLoginContentNumberPwdLogin")
	local textLoginBtn = getglobal("AccountLoginFrameLoginContentTextPwdLogin")
	local wechatLoginBtn = getglobal("AccountLoginFrameLoginContentWeChatLogin")
	local qqLoginBtn = getglobal("AccountLoginFrameLoginContentQQLogin")
	local LoginBtn = getglobal("AccountLoginFrameLoginBtn")
	local facebookBtn = getglobal("AccountLoginFrameFaceBookLoginBtn")
	if isNumberPwd then
		frameWorkHeight = 496
		contentBkgHeight = 370
		loginContainerHeight = 256
		getglobal("AccountLoginFrameChenDi"):SetHeight(frameWorkHeight)
		getglobal("AccountLoginFramecontentBkg"):SetHeight(contentBkgHeight)
		getglobal("AccountLoginFrameLoginContent"):SetHeight(loginContainerHeight)
		loginMethod:SetPoint("topright","AccountLoginFrameLoginContentPasswordTitle","topright",0,60)
	else
		frameWorkHeight = 496+70
		contentBkgHeight = 370+70
		loginContainerHeight = 256+70
		getglobal("AccountLoginFrameChenDi"):SetHeight(frameWorkHeight)
		getglobal("AccountLoginFramecontentBkg"):SetHeight(contentBkgHeight)
		getglobal("AccountLoginFrameLoginContent"):SetHeight(loginContainerHeight)
		loginMethod:SetPoint("topright","AccountLoginFrameLoginContentStrAnswerTitle","topright",0,60)
	end
	numLoginBtn:SetPoint("left","AccountLoginFrameLoginContentLoginMethodTitle","right",27,0)
	textLoginBtn:SetPoint("left","AccountLoginFrameLoginContentNumberPwdLogin","right",24,0)
	
	if WeChatOptionConfig() then
		wechatLoginBtn:SetPoint("left","AccountLoginFrameLoginContentTextPwdLogin","right",24,0)
		wechatLoginBtn:Show();
	end
	if QQOptionConfig() then
		if not WeChatOptionConfig() then
			qqLoginBtn:SetPoint("left","AccountLoginFrameLoginContentTextPwdLogin","right",24,0)
		else
			qqLoginBtn:SetPoint("left","AccountLoginFrameLoginContentWeChatLogin","right",24,0)
		end
		qqLoginBtn:Show();
	end

	LoginBtn:SetPoint("bottom","AccountLoginFramecontentBkg","bottom",9,-20)
	facebookBtn:SetPoint("center","AccountLoginFrameLoginBtn","center",-240,15)
end

function AccountLoginFramePWSwitchBtn_OnClick( ... )
	local StrQuestion=getglobal("AccountLoginFrameLoginContentQ1")
	local QTitle=getglobal("AccountLoginFrameLoginContentStrQuestionTitle")
	local ABkg=getglobal("AccountLoginFrameLoginContentStrAnswerBkg")
	local ATitle=getglobal("AccountLoginFrameLoginContentStrAnswerTitle")
	local Answer = getglobal("AccountLoginFrameLoginContentStrAnswer")
	local AnswerCoderBtn = getglobal("AccountLoginFrameLoginContentStrAnswerCoderBtn")
	--local switchTitle=getglobal("AccountLoginFrameLoginContentPWSwitchBtnTitle")
	
	local PWTitle=getglobal("AccountLoginFrameLoginContentPasswordTitle")
	local PWBkg=getglobal("AccountLoginFrameLoginContentPasswordEditBkg")
	local PWEdit=getglobal("AccountLoginFrameLoginContentPasswordEdit")
	local PWCoderBtn=getglobal("AccountLoginFrameLoginContentPassWordCoderBtn")
	
	local list={
	"AccountLoginFrameLoginContentQ1List",
	"AccountLoginFrameLoginContentQ1ListBkg",
	"AccountLoginFrameLoginContentDropDownBkg",
	}

	local clientID = this:GetClientID()

	for i=1,#list do
		if getglobal(list[i]):IsShown() then
			if i==3 then
				DropDown_OnClick()
			else
				getglobal(list[i]):Hide()
			end
		end
	end

	if ClientMgr:getGameData("LoginMethod")== 1 and clientID == 112 then --点击数字密码登录按钮
		Log("change to digitalpassword-logining:")
		ClientMgr:setGameData("LoginMethod",0)
		StrQuestion:Hide()
		QTitle:Hide()
		ABkg:Hide()
		ATitle:Hide()
		Answer:Hide()
		AnswerCoderBtn:Hide()
		PWTitle:Show()
		PWBkg:Show()
		PWEdit:Show()
		if ClientMgr:isPC() then
			PWCoderBtn:Show()
		end
		getglobal("AccountLoginFrameLoginContentTextPwdLogin"):Enable()
		getglobal("AccountLoginFrameLoginContentNumberPwdLogin"):Disable()
		-- if ClientMgr:getApiId() == 3 or ClientMgr:getApiId() == 34 then
		-- 	switchTitle:SetText(GetS(1123),233,21,21)
		-- else
		-- 	switchTitle:SetText(GetS(9024),233,21,21)
		-- end
		AccountLoginFrameLayout(true)
	elseif ClientMgr:getGameData("LoginMethod")==0 and clientID == 113 then --点击文字密码按钮
		Log("change to textpassword-logining:")
		ClientMgr:setGameData("LoginMethod",1)
		StrQuestion:Show()
		QTitle:Show()
		ABkg:Show()
		ATitle:Show()
		Answer:Show()
		if ClientMgr:isPC() then
			AnswerCoderBtn:Show()
		end
		
		PWTitle:Hide()
		PWBkg:Hide()
		PWEdit:Hide()
		PWCoderBtn:Hide()
		getglobal("AccountLoginFrameLoginContentTextPwdLogin"):Disable()
		getglobal("AccountLoginFrameLoginContentNumberPwdLogin"):Enable()
		-- if ClientMgr:getApiId() == 3 or ClientMgr:getApiId() == 34 then
		-- 	switchTitle:SetText(GetS(1122),233,21,21)
		-- else
		-- 	switchTitle:SetText(GetS(9025),233,21,21)
		-- end
		AccountLoginFrameLayout(false)
	end
end

function AccountLoginFrameStrQDropDown_OnClick( ... )
	local list=getglobal("AccountLoginFrameLoginContentQ1List")
	local listBkg=getglobal("AccountLoginFrameLoginContentQ1ListBkg")
	if list:IsShown() then
		list:Hide()
		listBkg:Hide()
		getglobal("AccountLoginFrameLoginContentStrAnswer"):Show()
		if ClientMgr:isPC() then
			getglobal("AccountLoginFrameLoginContentStrAnswerCoderBtn"):Show()
		end
		getglobal("AccountLoginFrameLoginContentNumberPwdLogin"):Show();
		getglobal("AccountLoginFrameLoginContentTextPwdLogin"):Show();
		if WeChatOptionConfig() then
			getglobal("AccountLoginFrameLoginContentWeChatLogin"):Show();
		end
		if QQOptionConfig() then
			getglobal("AccountLoginFrameLoginContentQQLogin"):Show();
		end
	else
		list:Show()
		listBkg:Show()
		getglobal("AccountLoginFrameLoginContentStrAnswer"):Hide()
		getglobal("AccountLoginFrameLoginContentStrAnswerCoderBtn"):Hide()
		getglobal("AccountLoginFrameLoginContentNumberPwdLogin"):Hide();
		getglobal("AccountLoginFrameLoginContentTextPwdLogin"):Hide();
		getglobal("AccountLoginFrameLoginContentWeChatLogin"):Hide();
		getglobal("AccountLoginFrameLoginContentQQLogin"):Hide();
	end
end

function StrQuestionTemplate1_OnClick( ... )
	local name=this:GetName()
	local qName = getglobal(name.."Content"):GetText()

	getglobal("AccountLoginFrameLoginContentQ1Content"):SetText(qName)
	getglobal("AccountLoginFrameLoginContentQ1Content"):SetTextColor(185,185,185)
	getglobal("AccountLoginFrameLoginContentStrAnswer"):Show()
	if ClientMgr:isPC() then
		getglobal("AccountLoginFrameLoginContentStrAnswerCoderBtn"):Show()
	end

	getglobal("AccountLoginFrameLoginContentNumberPwdLogin"):Show();
	getglobal("AccountLoginFrameLoginContentTextPwdLogin"):Show();
	if WeChatOptionConfig() then
		getglobal("AccountLoginFrameLoginContentWeChatLogin"):Show();
	end
	if QQOptionConfig() then
		getglobal("AccountLoginFrameLoginContentQQLogin"):Show();
	end

	getglobal("AccountLoginFrameLoginContentQ1ListBkg"):Hide();
	getglobal("AccountLoginFrameLoginContentQ1List"):Hide()

end

function AccountLoginFrameStrQuestion_OnUpdate( ... )
	-- body
end


function StrAnswer_OnFocusLost( ... )
	-- body
end
function StrAnswer_OnEnterPressed( ... )
	-- body
end

function AccountLoginFrameQList_OnShow( ... )
	-- body
end

function AccountLoginFrameQuestion_OnHide( ... )
	
	
	local answer=getglobal("AccountLoginFrameLoginContentStrAnswer")
	local question=getglobal("AccountLoginFrameLoginContentQ1Content")

	

	question:SetTextColor(185,185,185)
	question:SetText(GetS(9016))
	answer:Clear()


end

function AccountFrameSafetyCheckAcountBtn_OnClick()
	getglobal("AccountLoginFrameSafetyCheckTips"):Show()
end

function AccountFrameSafetyCheckAcountTipsBtn_OnClick()
	getglobal("AccountLoginFrameSafetyCheckTips"):Hide()
end

function EmailValidateFrameEmailEdit_OnEnterPressed()

end

function EmailValidateFrameEmailEdit_OnTabPressed()

end

function EmailValidateFrameVCEdit_OnEnterPressed()

end

function EmailValidateFrameVCEdit_OnTabPressed()

end

--切换输入框 显示/隐藏 状态
function EmailValidateFrameEmailCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("EmailValidateFrameEmailEdit"),this)
end
function EmailValidateFrameEmailCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("EmailValidateFrameEmailEdit"),this)
end

function EmailValidateFrameVCCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("EmailValidateFrameVCEdit"),this)
end
function EmailValidateFrameVCCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("EmailValidateFrameVCEdit"),this)
end

-------------------------------------------LoginSafetyCheckFrame-------------------------------------------

function LoginSafetyCheckFrame_OnShow()
	AccountSafetyCheck.VCCheckState = LoginSafetyCheck.State.Show
	UpLoginSafetyCheckFrame(AccountSafetyUIManage.CheckType)

	TemplateEditBoxCoderBtn_OnShow(getglobal("LoginSafetyCheckFramePhoneEdit"),getglobal("LoginSafetyCheckFramePhoneCoderBtn"))
	TemplateEditBoxCoderBtn_OnShow(getglobal("LoginSafetyCheckFrameEmailEdit"),getglobal("LoginSafetyCheckFrameEmailCoderBtn"))
	TemplateEditBoxCoderBtn_OnShow(getglobal("LoginSafetyCheckFrameVCEdit"),getglobal("LoginSafetyCheckFrameVCCoderBtn"))
end

function LoginSafetyCheckFrame_OnHide()
	AccountSafetyCheck.VCCheckState = LoginSafetyCheck.State.Hide
end

function UpLoginSafetyCheckFrame(type)
	if type == 1 or type == 3 then
		getglobal("LoginSafetyCheckFrameCheckTypeShiftText"):SetText("#L" .. GetS(100208))
		getglobal("LoginSafetyCheckFramePhoneOrEmailTitle"):SetText(GetS(3413))
		getglobal("LoginSafetyCheckFramePhoneEdit"):SetText("")
		getglobal("LoginSafetyCheckFramePhoneEdit"):Show()
		getglobal("LoginSafetyCheckFramePhoneCoderBtn"):Show()
		getglobal("LoginSafetyCheckFrameEmailEdit"):Hide()
		getglobal("LoginSafetyCheckFrameEmailCoderBtn"):Hide()
	else
		getglobal("LoginSafetyCheckFrameCheckTypeShiftText"):SetText("#L" .. GetS(100207))
		getglobal("LoginSafetyCheckFramePhoneOrEmailTitle"):SetText(GetS(3414))
		getglobal("LoginSafetyCheckFrameEmailEdit"):SetText("")
		getglobal("LoginSafetyCheckFramePhoneEdit"):Hide()
		getglobal("LoginSafetyCheckFramePhoneCoderBtn"):Hide()
		getglobal("LoginSafetyCheckFrameEmailEdit"):Show()
		getglobal("LoginSafetyCheckFrameEmailCoderBtn"):Show()
	end

	getglobal("LoginSafetyCheckFrameVCEdit"):SetText("")
end

function LoginSafetyCheckFrameCloseBtn_OnClick()
	getglobal("LoginSafetyCheckFrame"):Hide()
end

function LoginSafetyCheckTypeShiftTextBtn_OnClick()
	local type = AccountSafetyUIManage.CheckType
	if type == 1 then
		AccountSafetyUIManage.CheckType = 2
	elseif type == 2 then
		AccountSafetyUIManage.CheckType = 1
	elseif type == 3 then
		AccountSafetyUIManage.CheckType = 4
	elseif type == 4 then
		AccountSafetyUIManage.CheckType = 3
	end

	UpLoginSafetyCheckFrame(AccountSafetyUIManage.CheckType)
end

--登陆安全校验
function LoginSafetyCheckFrameRequestVCBtn_OnClick()
	local type = AccountSafetyUIManage.CheckType
	print("LoginSafetyCheckFrameRequestVCBtn_OnClick0", type)
	if type == 1 then
		local phoneEdit = getglobal("LoginSafetyCheckFramePhoneEdit")
		local mobile = NewAccountHelper:GetEditBoxText(phoneEdit)
		if CheckMobileValid(mobile) then
			print("LoginSafetyCheckFrameRequestVCBtn_OnClick1", mobile)
			local result = NewAccountService:SendVerifyCode(NewAccountHelper.ACCOUNT_TAG_PHONE, NewAccountHelper.FEATURE_NORMAL, 3, mobile)
			print("LoginSafetyCheckFrameRequestVCBtn_OnClick2", result)
			if result == ErrorCode.OK then
				getglobal("LoginSafetyCheckFrameRequestVCBtn"):Disable();
				getglobal("LoginSafetyCheckFrameRequestVCBtnNormal"):SetGray(true);
				ShowGameTips(GetS(3431), 3);
				RequestLodinCoolDown = 60;
				CoolTimeUpdate(RequestLodinCoolDown, 4);
			elseif result == ErrorCode.PRECHECK_SMS_PHONENUM_BINDED_DIFF then
				ShowGameTips(GetS(3419), 3);
			else
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[result]), 3);
			end
		else
			ShowGameTips(GetS(3419), 3);
		end
	elseif type == 2 then
		local emailEdit = getglobal("LoginSafetyCheckFrameEmailEdit")
		local email = NewAccountHelper:GetEditBoxText(emailEdit)
		if CheckEmailValid(email) then
			local result = AccountManager:requestEmailVerificationCode(email, 3);
			if result == 0 then
				getglobal("LoginSafetyCheckFrameRequestVCBtn"):Disable();
				getglobal("LoginSafetyCheckFrameRequestVCBtnNormal"):SetGray(true);
				ShowGameTips(GetS(3431), 3);
				RequestLodinCoolDown = 60;
				CoolTimeUpdate(RequestLodinCoolDown, 4);
			elseif result == ErrorCode.PRECHECK_SMS_EMAIL_BINDED_DIFF then
				ShowGameTips(GetS(3420), 3);
			else
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[result]), 3);
			end
		else
			ShowGameTips(GetS(3420), 3);
		end
	elseif type == 3 then
		local phoneEdit = getglobal("LoginSafetyCheckFramePhoneEdit")
		local mobile = NewAccountHelper:GetEditBoxText(phoneEdit)
		if CheckMobileValid(mobile) then
			print("LoginSafetyCheckFrameRequestVCBtn_OnClick1", mobile)
			local result = NewAccountService:SendVerifyCode(NewAccountHelper.ACCOUNT_TAG_PHONE, NewAccountHelper.FEATURE_NORMAL, 4, mobile)
			print("LoginSafetyCheckFrameRequestVCBtn_OnClick2", result)
			if result == ErrorCode.OK then
				getglobal("LoginSafetyCheckFrameRequestVCBtn"):Disable();
				getglobal("LoginSafetyCheckFrameRequestVCBtnNormal"):SetGray(true);
				ShowGameTips(GetS(3431), 3);
				RequestLodinCoolDown = 60;
				CoolTimeUpdate(RequestLodinCoolDown, 4);
			elseif result == ErrorCode.PRECHECK_SMS_PHONENUM_BINDED_DIFF then
				ShowGameTips(GetS(3419), 3);
			else
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[result]), 3);
			end
		else
			ShowGameTips(GetS(3419), 3);
		end
	elseif type == 4 then
		local emailEdit = getglobal("LoginSafetyCheckFrameEmailEdit")
		local email = NewAccountHelper:GetEditBoxText(emailEdit)
		if CheckEmailValid(email) then
			local result = AccountManager:requestEmailVerificationCode(email, 4);
			if result == 0 then
				getglobal("LoginSafetyCheckFrameRequestVCBtn"):Disable();
				getglobal("LoginSafetyCheckFrameRequestVCBtnNormal"):SetGray(true);
				ShowGameTips(GetS(3431), 3);
				RequestLodinCoolDown = 60;
				CoolTimeUpdate(RequestLodinCoolDown, 4);
			elseif result == ErrorCode.PRECHECK_SMS_EMAIL_BINDED_DIFF then
				ShowGameTips(GetS(3420), 3);
			else
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[result]), 3);
			end
		else
			ShowGameTips(GetS(3420), 3);
		end
	end
end

function LoginSafetyCheckFrameBindingBtn_OnClick()
	local type = AccountSafetyUIManage.CheckType
	print("LoginSafetyCheckFrameBindingBtn_OnClick1", type)
	if type == 1 then	--手机验证登陆
		local phoneEdit = getglobal("LoginSafetyCheckFramePhoneEdit")
		local mobile = NewAccountHelper:GetEditBoxText(phoneEdit)
		if CheckMobileValid(mobile) then
			local vcEdit = getglobal("LoginSafetyCheckFrameVCEdit")
			local vc = NewAccountHelper:GetEditBoxText(vcEdit)
			if CheckVCValid(vc) then
				local code = AccountManager:requestMobileVerifyCode(mobile, vc, 3)
				if code == ErrorCode.OK then
					getglobal("LoginSafetyCheckFrame"):Hide()
					AccountSafetyCheck.VCCheckState = LoginSafetyCheck.State.Succeed
				else
					AccountSafetyCheck.VCCheckState = LoginSafetyCheck.State.Failure
				end
			else
				ShowGameTips(GetS(3421), 3);
			end
		else
			ShowGameTips(GetS(3419), 3);
		end
	elseif type == 2 then	--邮箱验证登陆
		local emailEdit = getglobal("LoginSafetyCheckFrameEmailEdit")
		local email = NewAccountHelper:GetEditBoxText(emailEdit)
		if CheckEmailValid(email) then
			local vcEdit = getglobal("LoginSafetyCheckFrameVCEdit")
			local vc = NewAccountHelper:GetEditBoxText(vcEdit)
			if CheckVCValid(vc) then
				print("LoginSafetyCheckFrameBindingBtn_OnClick", email, vc)
				local code = AccountManager:requestVerifyEmail(email, vc, 3)
				if code == ErrorCode.OK then
					getglobal("LoginSafetyCheckFrame"):Hide()
					AccountSafetyCheck.VCCheckState = LoginSafetyCheck.State.Succeed
				else
					AccountSafetyCheck.VCCheckState = LoginSafetyCheck.State.Failure
				end
			else
				ShowGameTips(GetS(3421), 3);
			end
		else
			ShowGameTips(GetS(3420), 3);
		end
	elseif type == 3 then	--验证登陆开关手机验证
		local phoneEdit = getglobal("LoginSafetyCheckFramePhoneEdit")
		local mobile = NewAccountHelper:GetEditBoxText(phoneEdit)
		if CheckMobileValid(mobile) then
			local vcEdit = getglobal("LoginSafetyCheckFrameVCEdit")
			local vc = NewAccountHelper:GetEditBoxText(vcEdit)
			if CheckVCValid(vc) then
				local code = AccountManager:requestMobileVerifyCode(mobile, vc, 4)
				if code == ErrorCode.OK then
					getglobal("LoginSafetyCheckFrame"):Hide()
					
					local state = 0
					if AccountSafetyCheck:GetSwitchState() then 
						state = 1
					end
					SetSwitchBtnState("SecuritySettingContentSafetyCheckSwitch", state)
					AccountSafetyCheck.VCCheckState = LoginSafetyCheck.State.Succeed
				else
					AccountSafetyCheck.VCCheckState = LoginSafetyCheck.State.Failure
				end
			else
				ShowGameTips(GetS(3421), 3);
			end
		else
			ShowGameTips(GetS(3419), 3);
		end
	elseif type == 4 then	--验证登陆开关邮箱验证
		local emailEdit = getglobal("LoginSafetyCheckFrameEmailEdit")
		local email = NewAccountHelper:GetEditBoxText(emailEdit)
		if CheckEmailValid(email) then
			local vcEdit = getglobal("LoginSafetyCheckFrameVCEdit")
			local vc = NewAccountHelper:GetEditBoxText(vcEdit)
			if CheckVCValid(vc) then
				print("LoginSafetyCheckFrameBindingBtn_OnClick", email, vc)
				local code = AccountManager:requestVerifyEmail(email, vc, 4)
				if code == ErrorCode.OK then
					getglobal("LoginSafetyCheckFrame"):Hide()

					local state = 0
					if AccountSafetyCheck:GetSwitchState() then 
						state = 1
					end
					SetSwitchBtnState("SecuritySettingContentSafetyCheckSwitch", state)
					AccountSafetyCheck.VCCheckState = LoginSafetyCheck.State.Succeed
				else
					AccountSafetyCheck.VCCheckState = LoginSafetyCheck.State.Failure
				end
			else
				ShowGameTips(GetS(3421), 3);
			end
		else
			ShowGameTips(GetS(3420), 3);
		end
	end
end

function SetLoginSafetyCheckSwitchState()
	if not AccountManager:isBindAccount() then
		ShowGameTips(GetS(100202))
		return false
	end
	print("SetLoginSafetyCheckSwitchState", AccountManager:hasBindedPhone(), AccountManager:hasBindedEmail(), AccountManager:hasBindedFacebook())
	if AccountManager:hasBindedPhone() == 0 and AccountManager:hasBindedEmail() == 0 and AccountManager:hasBindedFacebook() == 0 then
		ShowGameTips(GetS(100203))
		return false
	end
	
	local state = false
	if not AccountSafetyCheck:GetSwitchState() then
		state = true
	end

	ShowLoginSafetyCheckFrame(2)
	return
end

-- 久远函数， 只有client安全认证会使用，，新版账号管理在client就拦截，不会走到这里
function ShowLoginSafetyCheckFrame(frameType)
	local title = getglobal("LoginSafetyCheckFrameTitleFrameTitle")
	local tips = getglobal("LoginSafetyCheckFramePhoneOrEmailTips")
	local btnName = getglobal("LoginSafetyCheckFrameBindingBtnText")
	frameType = frameType or 1
	if frameType == 2 then
		AccountSafetyUIManage.CheckType = 3
		if IsOverseasVer() or isAbroadEvn() then 
			AccountSafetyUIManage.CheckType = 4
			getglobal("LoginSafetyCheckFrameCheckTypeShiftText"):Hide()
		end

		title:SetText(GetS(100228))
		tips:SetText(GetS(100229))
		btnName:SetText(GetS(969))
	else
		AccountSafetyUIManage.CheckType = 1
		if IsOverseasVer() or isAbroadEvn() then 
			AccountSafetyUIManage.CheckType = 2
			getglobal("LoginSafetyCheckFrameCheckTypeShiftText"):Hide()
		end

		title:SetText(GetS(100205))
		tips:SetText(GetS(100206))
		btnName:SetText(GetS(3565))
	end
	if _G.IsEnableNewAccountSystem and IsEnableNewAccountSystem() then
		if frameType == 1 then
			OpenLoginSafetyPanel("LoginSafety")
		end
	else
		getglobal("LoginSafetyCheckFrame"):Show()
	end
end

--输入框切换 显示/隐藏 状态
function LoginSafetyCheckFramePhoneCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("LoginSafetyCheckFramePhoneEdit"),this)
end
function LoginSafetyCheckFramePhoneCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("LoginSafetyCheckFramePhoneEdit"),this)
end

function LoginSafetyCheckFrameEmailCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("LoginSafetyCheckFrameEmailEdit"),this)
end
function LoginSafetyCheckFrameEmailCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("LoginSafetyCheckFrameEmailEdit"),this)
end

function LoginSafetyCheckFrameVCCoderBtn_OnClick()
	TemplateEditBoxCoderBtn_OnClick(getglobal("LoginSafetyCheckFrameVCEdit"),this)
end
function LoginSafetyCheckFrameVCCoderBtn_OnShow()
	TemplateEditBoxCoderBtn_OnShow(getglobal("LoginSafetyCheckFrameVCEdit"),this)
end


---------------------------------------------password error--------------------------------------------------
--密码错误引导是否已经触发过
local PEGuidanceHappened = false
--[[密码错误引导]]
function PasswordErrorGuidance()
	PEGuidanceHappened = true
	local lsfIsShow = getglobal("LoginScreenFrame"):IsShown()
	local accSwitch = ClientMgr:getVersionParamInt("AccSwitch", 1)

	if IsEnableNewLogin and IsEnableNewLogin() then
		local newSwitch = NewAccountSwitchCfg:GetNewAccountSwtichStatus()
		print("PasswordErrorGuidance newSwitch", newSwitch)
		accSwitch = newSwitch and 1 or 0
	end

	local loginBtn = check_apiid_ver_conditions(ns_version.login_btn)

	ShowGameTipsWithoutFilter(GetS(25819))
	--设置界面 切号按钮 关
	if not lsfIsShow and 1 ~= accSwitch then
		
	--load界面登陆按钮 关
	elseif lsfIsShow and not loginBtn then

	else
		LoginScreenFrameSwitchUserBtn_OnClick()
	end
end

function GetPEGuidanceHappened()
	return PEGuidanceHappened
end

function SetPEGuidanceHappened(state)
	PEGuidanceHappened = state
end

function AccountLoginFrameWeChatLogin_OnClick()
	LoginManager:SetCurReportLoginType("wechat")
	LoginManager:SetCurReportLoginScene(2)

	-- 授权需要 开关判断
	if not GetInst("AccountSysConfig"):GetCfgByKey("wechatLoginBtnCfg") then
		LoginManager:LogClickReport(LoginManager.C_ERR_FAIL)
		ShowGameTipsWithoutFilter(string.format(GetS(1112084), GetS(35510)))
		return
	end

	-- 网络不好，提示网络问题
	if CheckNetworkErrTipsShow and CheckNetworkErrTipsShow() then
		LoginManager:LogClickReport(LoginManager.C_ERR_NET)
		return
	end

	if CallJavaChannelLoginStatus then
        if not CallJavaChannelLoginStatus() then
			LoginManager:LogClickReport(LoginManager.C_ERR_CH_LOGIN_NO)
            return
        end
    end

	LoginManager:LogClickReport(LoginManager.C_ERR_OK)
	print("===AccountLoginFrameWeChatLogin_OnClick===")
	local isInGame = 0
	if not getglobal("LoginScreenFrame"):IsShown() then
		isInGame = 1
	end
	local bind_source = 0
	if g_open_accountmanagerui_source == 3 then
		bind_source = 3
	else
		bind_source = 1
	end
	GetInst("QQWeChatLoginManager"):SetLoginQQWeChatSdkUserData("wechat","Login",isInGame)
	if ClientMgr:isPC() then
		local param = {method="login",type="wechat",op = 0,source_open=bind_source}
		GetInst("UIManager"):Open("QQWeChatLoginPC",param)
	else
		SdkManager:sdkLogin(2);
	end
end

function AccountLoginFrameQQLogin_OnClick()
	LoginManager:SetCurReportLoginType("qq")
	LoginManager:SetCurReportLoginScene(2)

	-- 授权需要 开关判断
	if not GetInst("AccountSysConfig"):GetCfgByKey("qqLoginBtnCfg") then
		LoginManager:LogClickReport(LoginManager.C_ERR_FAIL)
		ShowGameTipsWithoutFilter(string.format(GetS(1112084), GetS(35509)))
		return
	end

	-- 网络不好，提示网络问题
	if CheckNetworkErrTipsShow and CheckNetworkErrTipsShow() then
		LoginManager:LogClickReport(LoginManager.C_ERR_NET)
		return
	end

	if CallJavaChannelLoginStatus then
        if not CallJavaChannelLoginStatus() then
			LoginManager:LogClickReport(LoginManager.C_ERR_CH_LOGIN_NO)
            return
        end
    end

	LoginManager:LogClickReport(LoginManager.C_ERR_OK)
	print("===AccountLoginFrameQQLogin_OnClick===")
	local isInGame = 0
	if not getglobal("LoginScreenFrame"):IsShown() then
		isInGame = 1
	end
	local bind_source = 0
	if g_open_accountmanagerui_source == 3 then
		bind_source = 3
	else
		bind_source = 1
	end
	GetInst("QQWeChatLoginManager"):SetLoginQQWeChatSdkUserData("qq","Login",isInGame)
	if ClientMgr:isPC() then
		local param = {method="login",type="qq",op = 0,source_open=bind_source}
		GetInst("UIManager"):Open("QQWeChatLoginPC",param)
	else
		SdkManager:sdkLogin(1);
	end
end

function AccountLoginFrameKuaishouLogin_OnClick()
	LoginManager:SetCurReportLoginType("kuaishou")
	LoginManager:SetCurReportLoginScene(2)

	-- 网络不好，提示网络问题
	if CheckNetworkErrTipsShow and CheckNetworkErrTipsShow() then
		LoginManager:LogClickReport(LoginManager.C_ERR_NET)
		return
	end

	if CallJavaChannelLoginStatus then
        if not CallJavaChannelLoginStatus() then
			LoginManager:LogClickReport(LoginManager.C_ERR_CH_LOGIN_NO)
            return
        end
    end
	
	LoginManager:LogClickReport(LoginManager.C_ERR_OK)
	print("===AccountLoginFrameKuaishouLogin_OnClick===")
	local isInGame = 0
	if not getglobal("LoginScreenFrame"):IsShown() then
		isInGame = 1
	end
	local bind_source = 0
	if g_open_accountmanagerui_source == 3 then
		bind_source = 3
	else
		bind_source = 1
	end
	GetInst("QQWeChatLoginManager"):SetLoginQQWeChatSdkUserData("kuaishou","Login",isInGame)
	if not ClientMgr:isPC() then
		threadpool:work(function ()
			JavaMethodInvokerFactory:obtain()
									:setSignature("()V")
									:setClassName("org/appplay/platformsdk/MobileSDK")
									:setMethodName("KuaiShouLogout")
									:call();
			threadpool:wait(1)
			JavaMethodInvokerFactory:obtain()
									:setSignature("()V")
									:setClassName("org/appplay/platformsdk/MobileSDK")
									:setMethodName("KuaiShouSwitchUserLogin")
									:call();

		end)
	end
end