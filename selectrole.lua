
SelectRoleIndex = -1; 
RoleNickName = "";	
GameUIGuideStep = 0;

local InputRoleBtnEabled = true;  -- 避免 InputRoleNameFrameOkBtn_OnClick 连续点击响应里面的代码,必须执行完里面代码，才能响应下一次点击
--------------------------------------------------------SelectRoleFrame--------------------------------------------
--[[
local t_RoleBindId = { 2, 4, 3, 5, 6 };
local t_PlayerIndices = { 
				{index=1, roleName="player02xiaonanhai"},
				{index=0, roleName="player01dashu"},
				{index=7, roleName="player08dama"},
				{index=6, roleName="player07xiaonvhai"},
				{index=5, roleName="player06xionghaizi"},
			};
]]

local t_RoleBindId = {2, 3};
local t_PlayerIndices = { 
				{index=1, roleName="player02xiaonanhai"},
				{index=7, roleName="player08xiaonvhai"},
			};
local t_RoleInfo ={
			{nameId=538, desc="    原名巴扎·黑，从小生活在原始部落，拥有较强的生存能力", effectId=1103},
			{nameId=584, desc="	妮妮是巴扎的妹妹，心地善良，喜欢大自然的花花草草", effectId=1104},	
		}

function SelectRoleFrame_OnLoad()
	local SelectRoleView = getglobal("SelectRoleView")
	--SelectRoleView:addBackgroundEffect("particles/1101.ent", 0, 0, 0);
	SelectRoleView:setCameraWidthFov(30);
	SelectRoleView:setCameraLookAt(0, 220, -1200, 0, 128, 0);
	SelectRoleView:setActorPosition(-220, 0, -320);

	local env_ = get_game_env();
	--Log( "call JumpEnvFrame_OnShow, " .. env_ );

	if env_==1 or env_==10 then
		getglobal("SelectRoleFrameBirthSelect"):Show()
	end
	
	


end

function SelectRoleFrame_OnEvent()
end

function PopLockScreenMessageBoxAsRegOverLoad()
	local isneedCheck = check_apiid_ver_conditions(ns_version.check_reg_overload)
	if isneedCheck then
		MessageBox(14, GetS(35500))
		_G.IgnoreEsc = true
	end
end

function SelectRoleFrame_OnShow()
	--新手引导流程优化，先展示用户协议
	ShowOverseaPolisyFrame()
	--角色创建界面隐藏物理指数
	ClientMgr:setGameData("physxparam", 0);
	DebugMgr:setRenderInfoPhysx(false);

	local isLoadBgWorld = false;
	threadpool:work(function ()
		while not isLoadBgWorld do
			if ClientCurGame then
				ClientCurGame:loadBGWorld();
				isLoadBgWorld = true;
			end
			threadpool:wait(0.1);
		end
	end)

	getglobal("InputRoleNameFrame"):Show();	
	-- local enablealternick = if_open_alter_name();
	-- getglobal("InputRoleNameFrameNameEdit"):enableEdit(enablealternick);
	-- local env = get_game_env()
	-- local is_debug = LuaInterface and LuaInterface:isdebug() or false
	-- if env == 1 or is_debug == true  then 
	-- 	getglobal("InputRoleNameFrameNameEdit"):enableEdit(true);
	-- end 		
	InputRoleNameFrameRandomBtn_OnClick();
	local SelectRoleView = getglobal("SelectRoleView")
	for i=1, 2 do
		local player = UIActorBodyManager:getRoleBody(t_PlayerIndices[i].index);
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			SelectRoleView:attachActorBody(player, i-1)
		else
			player:attachUIModelView(SelectRoleView, i-1);
		end
		SelectRoleView:bindActorToAnchor(t_RoleBindId[i], i-1);
		SelectRoleView:playActorAnim(100100,i-1);		
	end
	SelectRoleView:playEffect(1038, 0);
	SelectRoleView:playEffect(1038, 1);

	--初始选择小男孩
	CurSelectIndex = 0;
	SelectRoleIndex = 0;
	SelectRoleView:playActorAnim(100108, SelectRoleIndex);
	SelectRoleView:setActorCollide(false, SelectRoleIndex);
	SelectRoleView:setActorScale(1.4, 1.4, 1.4, SelectRoleIndex);
	SelectRoleView:playEffect(t_RoleInfo[SelectRoleIndex+1].effectId, SelectRoleIndex);

	--添加服务器敏感词到客户端
	if not FilterMgr.isAddString then
		threadpool:delay(3.0,function()
		    --添加服务器敏感词到客户端
			FilterMgr.AddStringToClient()
		end)
	end 

	--延迟一段时间上报埋点数据，直接上报貌似会大概率失败
	threadpool:delay(2.0,function()
		DelayReportStandData()
	end)
end

local CurSelectIndex = -1;
function SelectRoleFrame_OnMouseDown()
	local SelectRoleView = getglobal("SelectRoleView")
	local index = SelectRoleView:getActorOnScreenPoint(GetCursorPosX(),GetCursorPosY());
	if index ~= -1 then
		CurSelectIndex = index;
		SelectRoleView:setActorScale(1.0, 1.0, 1.0, CurSelectIndex);	
	end
end

function SelectRoleFrame_OnMouseUp()
	if CurSelectIndex ~= -1 then
		local SelectRoleView = getglobal("SelectRoleView")

		if SelectRoleIndex ~= -1 then
		--	SelectRoleView:bindActorToAnchor(t_RoleBindId[SelectRoleIndex+1], SelectRoleIndex);
			SelectRoleView:playActorAnim(100100, SelectRoleIndex);
			SelectRoleView:setActorCollide(true, SelectRoleIndex);
			SelectRoleView:setActorScale(1.0, 1.0, 1.0, SelectRoleIndex);
			SelectRoleView:stopEffect(t_RoleInfo[SelectRoleIndex+1].effectId, SelectRoleIndex);
			SelectRoleView:playEffect(1038, SelectRoleIndex);
		end
		
		SelectRoleIndex = CurSelectIndex;
	--	SelectRoleView:bindActorToAnchor(1, SelectRoleIndex);
		SelectRoleView:playActorAnim(100108, SelectRoleIndex);
		SelectRoleView:setActorCollide(false, SelectRoleIndex);

		SelectRoleView:setActorScale(1.4, 1.4, 1.4, SelectRoleIndex);
		CurSelectIndex = -1;
		
		SelectRoleView:stopEffect(1038, SelectRoleIndex);
		SelectRoleView:playEffect(t_RoleInfo[SelectRoleIndex+1].effectId, SelectRoleIndex);

		if SelectRoleIndex == 0 then
			standReportEvent("37", "NEWPLAYER_ROLECHOOSE", "Switch", "click", {
				standby1 = "kaka",
			});
		else
			standReportEvent("37", "NEWPLAYER_ROLECHOOSE", "Switch", "click", {
				standby1 = "nini",
			});
		end
	end
	
end

function SelectRoleFrame_OnHide()
	DebugMgr:setRenderInfoPhysx(true);
	ClientMgr:setGameData("physxparam", 1);
	local SelectRoleView = getglobal("SelectRoleView")
	if SelectRoleIndex ~= -1 then 
		SelectRoleView:setActorScale(1.0, 1.0, 1.0, SelectRoleIndex);
		SelectRoleView:stopEffect(t_RoleInfo[SelectRoleIndex+1].effectId, SelectRoleIndex);
	end
	SelectRoleView:stopEffect(1038, 0);
	SelectRoleView:stopEffect(1038, 1);
	if ClientCurGame and ClientCurGame.unloadBGWorld ~= nil then
		ClientCurGame:unloadBGWorld();
	end 
end

function EnterLobby()
	if not AccountManager:getNoviceGuideState("noviceteach") and ClientMgr:isMobile() then
		AccountManager:setNoviceGuideState("noviceteach", true);
	end

	getglobal("SelectRoleFrame"):Hide();
	-- getglobal("MiniLobbyFrame"):Show();
	ShowMiniLobby(); --mark by hfb for new minilobby
end

function SelectRoleFrameSkipNextBtn_OnClick()
 	if AccountManager:requestEnterWorld(NewbieWorldId) then
		StatisticsTools:gameEvent("EnterSurviveWNum");
		getglobal("SelectRoleFrame"):Hide();
		ShowLoadingFrame();
	else
		-- getglobal("MiniLobbyFrame"):Show();
		ShowMiniLobby(); --mark by hfb for new minilobby
	end
end
--------------------------------InputRoleNameFrame-----------------------------------------------
local isTrueModify = false;
function InputRoleNameFrame_OnShow()
	InputRoleNameFrameRandomBtn_OnClick();
--	local uvTex = getglobal("InputRoleNameFrameOkBtnUVAnimationTex");
--	uvTex:Show();
--	uvTex:SetUVAnimation(120, true);
end

function InputRoleNameFrameNameEdit_OnFocusGained()
	if not isTrueModify then
		isTrueModify = true;
		StatisticsTools:gameEvent("ModifyName", AccountManager:getUin());
	end
end

function InputRoleNameFrameNameEdit_OnFocusLost()
	--[[
	if ReplaceFilterString(getglobal("InputRoleNameFrameNameEdit"):GetText()) then 
		InputRoleNameFrameRandomBtn_OnClick();
	end
	]]
end

function InputRoleNameFrameNameEdit_OnEnterPressed()
	UIFrameMgr:setCurEditBox(nil);
	InputRoleNameFrameOkBtn_OnClick();
end

function InputRoleNameFrameNameEdit_OnClick()
	print('InputRoleNameFrameNameEdit_OnClick:');
	standReportEvent("37", "NEWPLAYER_NAME_CANTAINER", "InputName", "click");
	if FunctionLimitCtrl:IsNormalBtnClick(FunctionType.RSET_NICKNAME) then
		--常规
	else
		--限制输入
		-- getglobal('InputRoleNameFrameNameEdit'):enableEdit(false);
		return;
	end
end

function InputRoleNameFrameOkBtn_OnClick()
	standReportEvent("37", "NEWPLAYER_NAME_CANTAINER", "Enter", "click", {
		standby1 = (ClientCurGame:getSelectRoleIndex() == 0 and {"kaka"} or {"nini"})[1],
		standby2 = getglobal("SelectRoleFrameBirthSelectMonthTitleName"):GetText() .. "_" .. getglobal("SelectRoleFrameBirthSelectYearTitleName"):GetText()
	});
	if InputRoleBtnEabled == false then
		return;
	end
	InputRoleBtnEabled = false;

	local nameText = getglobal("InputRoleNameFrameNameEdit"):GetText();
	--提示角色名有敏感词
	if CheckFilterString(nameText) then
		InputRoleBtnEabled = true;
		--埋点，创建角色 设备码,创建结果,角色类型,用户类型,语言
		-- statisticsGameEventNew(957,ClientMgr:getDeviceID(),2,ClientCurGame:getSelectRoleIndex()+1,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
		StatisticsTools:send(true, true)
		return;
	end

	--角色名字含有空格
	if ClientMgr:getApiId() < 300 or ClientMgr:getApiId() == 999 then
		if string.find(nameText,"%s") then
			ShowGameTips(GetS(20663), 3);
			InputRoleBtnEabled = true;
			--埋点，创建角色 设备码,创建结果,角色类型,用户类型,语言
			-- statisticsGameEventNew(957,ClientMgr:getDeviceID(),2,ClientCurGame:getSelectRoleIndex()+1,
			-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
			StatisticsTools:send(true, true)
			return;
		end
	end
	--角色名字含有'#'号
	if string.find(nameText,"#") then
		ShowGameTips(GetS(121), 3);
		InputRoleBtnEabled = true;
		--埋点，创建角色 设备码,创建结果,角色类型,用户类型,语言
		-- statisticsGameEventNew(957,ClientMgr:getDeviceID(),2,ClientCurGame:getSelectRoleIndex()+1,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),get_game_lang())
		StatisticsTools:send(true, true)
		return;
	end
	if nameText == "" then
		--提示角色名不能为空
		ShowGameTips(GetS(45), 3)
		InputRoleBtnEabled = true;
		--埋点，创建角色 设备码,创建结果,角色类型,用户类型,语言
		-- statisticsGameEventNew(957,ClientMgr:getDeviceID(),2,ClientCurGame:getSelectRoleIndex()+1,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
		StatisticsTools:send(true, true)
		return;
	end
	--创建角色
	local i = ClientCurGame:getSelectRoleIndex();
	if i < 0 then
		ShowGameTips(GetS(89), 3)
		InputRoleBtnEabled = true;
		--埋点，创建角色 设备码,创建结果,角色类型,用户类型,语言
		-- statisticsGameEventNew(957,ClientMgr:getDeviceID(),2,ClientCurGame:getSelectRoleIndex()+1,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
		StatisticsTools:send(true, true)
		return;
	end
	local user_birth={year=0,month=0}
	local index = 0
	local month_number={"$4850",GetS(4851),GetS(4852),GetS(4853),GetS(4854),GetS(4855),GetS(4856),GetS(4857),GetS(4858),GetS(4859),GetS(4860),GetS(4861)}
	local user_month=getglobal("SelectRoleFrameBirthSelectMonthTitleName"):GetText()
	local user_year=getglobal("SelectRoleFrameBirthSelectYearTitleName"):GetText()
	local env_ = get_game_env();
	--Log( "call JumpEnvFrame_OnShow, " .. env_ );
	if not gIsSingleGame then
		if env_==1 or env_==10 then
			if user_month==GetS(4844) or user_year==GetS(4843) then
				
				local duration=0.5
				local interval=0.25
				if not (AnimMgr.playing and next(AnimMgr.playing)~=nil) then
					
					AnimMgr:playBlink("SelectRoleFrameBirthSelectYearTitle", duration, interval);
					AnimMgr:playBlink("SelectRoleFrameBirthSelectMonthTitle", duration, interval);
						
				end
				InputRoleBtnEabled = true;
				--埋点，创建角色 设备码,创建结果,角色类型,用户类型,语言
				-- statisticsGameEventNew(957,ClientMgr:getDeviceID(),2,ClientCurGame:getSelectRoleIndex()+1,
				-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
				StatisticsTools:send(true, true)
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
					ShowNoTransparentLoadLoop()
					AccountManager:set_user_birthday(user_birth)
					HideNoTransparentLoadLoop()
				end
			end
		end
	end

	SelectRoleIndex = i;

	local result, code = AccountManager:requestModifyRole(nameText, t_PlayerIndices[SelectRoleIndex+1].index+1, 0)
	local reportData = LoginManager:GetReportRegistExtraData()
	reportData.standby2 = code
	if result then
		-- if ClientMgr:getApiId() == 89 then
		-- 	ClientMgr:sdkCreateRole();
		-- end
		if gIsSingleGame then
			local uin = AccountManager:getUin();
			local nickName = AccountManager:getNickName();
			StatisticsTools:chooseRole(t_PlayerIndices[SelectRoleIndex+1].roleName, nickName, uin);
			-- MessageBox(6, GetS(91));
			-- getglobal("MessageBoxFrame"):SetClientString("进入教学");
			-- statisticsGameEvent(901, "%s", "NoviceGuidePopUps","save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()), "%d", SelectRoleIndex);
			--新手引导埋点数据uin替换上传
			readStatisticsData();
			StatisticsTools:gameEvent("EnterLobby");
			local GoogleAnalytics = _G.GoogleAnalytics;
			GoogleAnalytics:CreatePostBuilder()
				:SetAction(GoogleAnalytics.Actions.CREATE_ROLE)
				:Post();
		end
		
		EnterGuideWorld()
		--埋点，创建角色 设备码,创建结果,角色类型,用户类型,语言
		-- statisticsGameEventNew(957,ClientMgr:getDeviceID(),1,ClientCurGame:getSelectRoleIndex()+1,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
		StatisticsTools:send(true, true)
		--创角成功上报
		LoginManager:ReportRegist3701StandData("NEWPLAYER_NAME_CANTAINER","Next","reg_success", reportData);

	else
		StatisticsTools:gameEvent("EnterLobbyFail");
		--埋点，创建角色 设备码,创建结果,角色类型,用户类型,语言
		-- statisticsGameEventNew(957,ClientMgr:getDeviceID(),2,ClientCurGame:getSelectRoleIndex()+1,
		-- ClientMgr.isFirstEnterGame and (ClientMgr:isFirstEnterGame() and 1 or 2),tostring(get_game_lang()))
		StatisticsTools:send(true, true)
		ShowGameTips(GetS(583), 3);

		--创角失败上报
		LoginManager:ReportRegist3701StandData("NEWPLAYER_NAME_CANTAINER","Next","reg_failed",reportData);
	end

	InputRoleBtnEabled = true;
end

function EnterGuideWorld()
	--新手引导流程优化，修改为去掉跳过弹框
	getglobal("GuideTipsFrame"):Hide();
	SelectRoleFrameSkipNextBtn_OnClick();
	-- statisticsGameEvent(901, "%s", "EnterNoviceMap","save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
	GoogleAnalytics:CreatePostBuilder()
		:SetCategory("pc410")
		:SetAction("enter_novice_map")
		:Post();
	--第一次进入新手引导
	IsFirstEnterNoviceGuide = true;
	if ClientMgr:getApiId() == 345 or ClientMgr:getApiId() == 346 or Android:IsBlockArt() then
		StatisticsTools:appsFlyer("tutorial");
	end
	--UI引导
	GameUIGuideStep = 1;	
	SetGuideStep(1)

	HideIdentityNameAuthFrame()
	-- bilibili渠道上传角色创建信息
	if ClientMgr:getApiId() == 52 then
		local uin = AccountManager:getUin();
		local nickname = AccountManager:getNickName();
		JavaMethodInvokerFactory:obtain()
					:debug(true)
					:setSignature("(Ljava/lang/String;Ljava/lang/String;)V")
					:setClassName("org/appplay/platformsdk/MobileSDK")
					:setMethodName("createRole")
					:addString(tostring(uin))
					:addString(tostring(nickname))
					:call()
	end
end

function InputRoleNameFrameRandomBtn_OnClick()
	local nickname = DefMgr:getRandomName(0)
	--[[
	if not ClientCurGame:requestCheckNickname(nickname) then
		nickname = nickname..(math.random(1,999))
	end
	]]
	getglobal("InputRoleNameFrameNameEdit"):SetText(nickname)
	standReportEvent("37", "NEWPLAYER_NAME_CANTAINER", "RandomName", "click");
end


--玩家出生日期设置


function New_BirthSelect_OnLoad( ... )
	--初始化出生日期UI
	getglobal("SelectRoleFrameBirthSelectTitle"):SetText(GetS(4840))
	local name1="SelectRoleFrameBirthSelectMonthListM"
	local name2="SelectRoleFrameBirthSelectYearListY"
	local base=-11
	local months={GetS(4861),GetS(4860),GetS(4859),GetS(4858),GetS(4857),GetS(4856),GetS(4855),GetS(4854),GetS(4853),GetS(4852),GetS(4851),GetS(4850)}
	for i=1,12 do
		getglobal(name1..i):SetPoint("bottom","SelectRoleFrameBirthSelectMonthListPlane","bottom",0,base-51*(i-1))
		getglobal(name1..i.."Num"):SetText(months[i])
	end
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
		getglobal(name2..i):SetPoint("bottom","SelectRoleFrameBirthSelectYearListPlane","bottom",0,base-51*(i-1))
		if i==1 then
			getglobal(name2..i.."Num"):SetText(GetS(4862)..tostring(base_year))
		else
			getglobal(name2..i.."Num"):SetText(tostring(base_year+i-2))
		end
	end

	getglobal("SelectRoleFrameBirthSelectTitle2"):SetText(GetS(4845))
		


end

function New_MonthSelect_OnClick( ... )

	
	
	local name=this:GetName()
	if name=="SelectRoleFrameBirthSelectMonthTitle" then
		getglobal("SelectRoleFrameBirthSelectMonthList"):setCurOffsetY(-151)
		getglobal("SelectRoleFrameBirthSelectMonthBar"):SetValue(151)
		standReportEvent("37", "NEWPLAYER_BIRTHDAY_CONTAINER", "Month", "click");
	elseif name=="SelectRoleFrameBirthSelectYearTitle" then
		getglobal("SelectRoleFrameBirthSelectYearList"):setCurOffsetY(-865)
		getglobal("SelectRoleFrameBirthSelectYearBar"):SetValue(865)
		standReportEvent("37", "NEWPLAYER_BIRTHDAY_CONTAINER", "Year", "click");
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

function New_BirthTime_OnClick( ... )
	local name=this:GetName() 
	local parent=this:GetParentFrame():GetName()
	local time=getglobal(name.."Num"):GetText()
	
	if parent=="SelectRoleFrameBirthSelectMonthList" then
	
		getglobal("SelectRoleFrameBirthSelectMonthTitleName"):SetText(time)
		getglobal(parent):Hide()
		getglobal(parent.."Bkg"):Hide()
		getglobal("SelectRoleFrameBirthSelectMonthBar"):Hide()
		getglobal("SelectRoleFrameBirthSelectMonthTitleDown"):Show()
		getglobal("SelectRoleFrameBirthSelectMonthTitleUp"):Hide()

	else
		
		getglobal("SelectRoleFrameBirthSelectYearTitleName"):SetText(time)
		getglobal(parent):Hide()
		getglobal(parent.."Bkg"):Hide()
		getglobal("SelectRoleFrameBirthSelectYearBar"):Hide()
		getglobal("SelectRoleFrameBirthSelectYearTitleDown"):Show()
		getglobal("SelectRoleFrameBirthSelectYearTitleUp"):Hide()
	end
end

function New_MonthBar_OnValueChanged(...)
	local value=this:GetValue()

	local bar=getglobal("SelectRoleFrameBirthSelectMonthBar")
	if value>=299 then
		value=303
		bar:SetValue(value)
	elseif value<=3 then
		value=0
		bar:SetValue(value)
	end

	

	local sliderFrame=getglobal("SelectRoleFrameBirthSelectMonthList")
	sliderFrame:setCurOffsetY(-value)
	
	
end

function New_YearBar_OnValueChanged( ... )
	local value=this:GetValue()
	local bar=getglobal("SelectRoleFrameBirthSelectYearBar")
	if value>=1700 then
		value=1731
		bar:SetValue(value)
	elseif value<=6 then
		value=0
		bar:SetValue(value)
	end

	
	local sliderFrame=getglobal("SelectRoleFrameBirthSelectYearList")
	sliderFrame:setCurOffsetY(-value)
	
end

function New_MonthSlide_OnMouseWheel()
	local sliderFrame=getglobal("SelectRoleFrameBirthSelectMonthList")
	local bar=getglobal("SelectRoleFrameBirthSelectMonthBar")
	local offsetY=sliderFrame:getCurOffsetY()
	
	
	bar:SetValue(-offsetY)
end

function New_YearSlide_OnMouseWheel()
	local sliderFrame=getglobal("SelectRoleFrameBirthSelectYearList")
	local bar=getglobal("SelectRoleFrameBirthSelectYearBar")
	local offsetY=sliderFrame:getCurOffsetY()
	
	
	bar:SetValue(-offsetY)
end

function DelayReportStandData()
	-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CONTAINER", "-", "view"); --1034914 埋点下线需求
	-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CONTAINER", "LicenseAndServiceAgreement", "view"); --1034914 埋点下线需求
	-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CONTAINER", "PrivacyPolicy", "view"); --1034914 埋点下线需求
	-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CONTAINER", "Cancle", "view"); --1034914 埋点下线需求
	-- standReportEvent("36", "NEWPLAYER_CLAUSEANDPOLICY_CONTAINER", "Agree", "view"); --1034914 埋点下线需求

	standReportEvent("37", "NEWPLAYER_ROLECHOOSE", "-", "view");
	standReportEvent("37", "NEWPLAYER_ROLECHOOSE", "Switch", "view");
	standReportEvent("37", "NEWPLAYER_NAME_CANTAINER", "-", "view");
	standReportEvent("37", "NEWPLAYER_NAME_CANTAINER", "RandomName", "view");
	standReportEvent("37", "NEWPLAYER_NAME_CANTAINER", "InputName", "view");
	standReportEvent("37", "NEWPLAYER_NAME_CANTAINER", "Enter", "view");

	if getglobal("SelectRoleFrameBirthSelect"):IsShown() then
		standReportEvent("37", "NEWPLAYER_BIRTHDAY_CONTAINER", "-", "view");
		standReportEvent("37", "NEWPLAYER_BIRTHDAY_CONTAINER", "Month", "view");
		standReportEvent("37", "NEWPLAYER_BIRTHDAY_CONTAINER", "Year", "view");
	end
end