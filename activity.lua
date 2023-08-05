
LoginRewardListMaxNum = 7;
ActivityRewardListMaxNum = 30;
ShareGetMiniBeanType = 0;	--分享迷你豆活动的类型 1为普通类型 2为双倍 3为春节
_G.HasShareReward = false;

t_ActivityTypeBtnList = nil;

openYybUrlToGetgift = false; --每日打开应用宝的url后可以得到相应礼包

MiniBaoKuID = 1; --选择的迷你宝库ID

MaxBaokuNum = 6;--宝库最大数量

-------activity--------游戏活动-----(utf-8)-----------------------------------------------------------------------------
ns_activity = {      --namespace activity

};
ns_activity.func = {
	--清洗服务器数据得到有效内容
	cleanData = function()
		Log("ns_activity func cleanData in")
		if  ns_advert.server_config and ns_advert.server_config.login_reward_ads then
			-- 格式化图片数据
			local pics_ = ns_advert.server_config.login_reward_ads;--login_reward_ads配置的图片table
			if pics_ and #pics_ > 0 then
				--选取要下载png图片
				for i=1, #pics_ do
					if  ns_advert.func.check_can_show( pics_[i], "pics" ) == true then --找到一张可以显示的图片就return
						local pic_url;
						local file_name;
						if pics_[i].pic_local then
							pic_url = nil;
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
							local url_ = pics_[i].action_url or "";
							local pic = { pic_url = pic_url,
										  file_name = file_name,
										  check_size = pics_[i].check_size,
										  action = pics_[i].action,
										  action_url = url_ };
							ns_activity.content = {};
							ns_activity.content.pic = pic;
							ns_activity.content.text = pics_[i].title;
							if pics_[i]['title_'..get_game_lang()] then
								ns_activity.content.text = pics_[i]['title_'..get_game_lang()];
							end
							return;
						end
					end
				end
			end -- 格式化图片数据end
		end
	end,
	--按照服务器返回的数据刷新UI
	resetMAUI = function()
		Log("ns_activity func resetMAUI in")
		if not ns_activity.content then
			ns_activity.func.cleanData()
		end

		if ns_activity.content then
			local function downloadPng_cb()
				local content = ns_activity.content;
				--设置图片
				if content.pic then
					print("xxxx:content.pic.file_name = ", content.pic.file_name);
					local new_name_ = check_http_image_jpg( content.pic.file_name );
					local pic = getglobal( "ActivityFrameLoginRewardBigPic" );
					local picFrame = getglobal( "ActivityFrameLoginRewardPicFrame" );
					local picBtn = getglobal( "ActivityFrameLoginRewardPicBtn" );
					pic:ReleaseTexture(new_name_);
					pic:SetTexture( new_name_ );
					pic:Show();
					picFrame:Show();
					picBtn:Show();
					local pic_y = pic:getRelHeight(); -- 图片高度
					if pic_y <= 4 then
						--未完成下载先隐藏
						print("pic_y <= 4")
						pic:Hide();
						picFrame:Hide();
						picBtn:Hide();
					end
				end --图片处理end
			end

			--下载图片
			local picinfo = ns_activity.content.pic;
			local text = ns_activity.content.text or "";
			getglobal("ActivityFrameLoginRewardTitle"):SetText(text)
			if picinfo and picinfo.pic_url and picinfo.task_id ~= "ok" then
				ns_http.func.downloadPng( picinfo.pic_url, picinfo.file_name, picinfo.check_size, nil, downloadPng_cb);
				ns_activity.content.pic.task_id = "ok";--下载过了
			end
		end
	end,
}
------------------------------------------------------------------------------------------------------------------------
function ActivityFrame_OnLoad()
	this:RegisterEvent("GIE_SHARE_GIFT_INFO");
end

function ActivityFrame_OnEvent()
	if arg1 == "GIE_SHARE_GIFT_INFO" then
		if getglobal("LoadLoopFrame"):IsShown() then
			ShowLoadLoopFrame(false)
		end
		local ge 		= GameEventQue:getCurEvent();
		local multiple		= ge.body.sharegiftinfo.multiple;

		if not getglobal("ActivityFrame"):IsShown() then
			ShareGetMiniBeanType = multiple;
		elseif getglobal("GetMiniBeanRewardBtn"):IsChecked() then
			local result 		= ge.body.sharegiftinfo.result;
			local dayTimes  	= ge.body.sharegiftinfo.dayTimes;
			local dayGetTimes  	= ge.body.sharegiftinfo.dayGetTimes;
			local weekGetTimes  	= ge.body.sharegiftinfo.weekGetTimes;
			local miniBean		= ge.body.sharegiftinfo.miniBean;
			local dayGetMax		= ge.body.sharegiftinfo.dayGetMax;
			
			--UpdateGetMiniBeanReward(result, dayTimes, dayGetTimes, weekGetTimes, miniBean, multiple, dayGetMax);
		end
	end
end

local t_SlidingFrame = { "EnchantRandomBox", "EnchantTopBox", "EnchantBottomBox", "AchievementIconInfo",
			"MiniProductBox", "CreateBox", "NormalProductBox", "FurnaceStuffBox",
			"FurnaceFuelBox", "WaitRepairBox", "RepairStuffBox", "RoomRoomBox", "CreateRoomArchiveBox",
			"StorageLeftBox", "StorageRightBox", "ArchiveBox",
			}

function SetSlidingFrameState(state)
	for i=1, #(t_SlidingFrame) do
		local slidingFrame = getglobal(t_SlidingFrame[i]);
		if  slidingFrame and slidingFrame.setDealMsg then
			slidingFrame:setDealMsg(state);
		else
			Log("ERROR: can not find " .. t_SlidingFrame[i] )
			-- MessageBox(5, "ERROR: t_SlidingFrame not find " .. t_SlidingFrame[i] )
		end
	end
end


--if ClientMgr:getVersionParamInt("Share", 1) == 1 then
--GetMiniBeanRewardBtn
--用get_minibean_no_apiids来替换掉xml版本的配置
function getLuaFlagForShare()
	if ns_shop_config2 and ns_shop_config2.share_cfg then
		return check_apiid_ver_conditions(ns_shop_config2.share_cfg);
	end

	--[[
	if  ns_advert and ns_advert.server_config and ns_advert.server_config.web and ns_advert.server_config.web.get_minibean_no_apiids then
		local finder_ = ClientMgr:getApiId();
		local ret     = string.find( ',' .. ns_advert.server_config.web.get_minibean_no_apiids .. ',',  ',' .. finder_ .. ',' );   --禁止列表
		if  ret then
			return false
		else
			return true
		end
	end
	]]
	return false
end

function getTimeByString(timestr)
	local _, _, y, m, d, h, min, s = string.find(timestr, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")

	return os.time({year=y, month = m, day = d, hour = h, min = min, sec = s})
end

function ActivityFrame_OnShow()
	if getglobal("ActivityFrame"):IsReshow() then
		return;
	end

	local btnList = t_ActivityTypeBtnList
	for i=1, #(btnList) do
		local btnName = btnList[i].Name .. 'Btn'
		local btn = getglobal(btnName);
		local name = getglobal(btnName .. "Name");
		btn:Enable();
		if string.find(btnList[i].Name , "MiniTreasury") then 
			
		else 
			name:SetText(GetS(btnList[i].StringId));
		end
	end
	
	SetArchiveDealMsg(false);
	SetSlidingFrameState(false);
	
	if  getLuaFlagForShare() then
		getglobal("GetMiniBeanReward"):Show();
		--[[
		if ShareGetMiniBeanType >= 2 then	--春节活动
			local tagBkg		= getglobal("GetMiniBeanRewardBtnTagBkg");
			local tag		= getglobal("GetMiniBeanRewardBtnTag");

			tagBkg:Show();
			tag:Show();
			if ShareGetMiniBeanType == 2 then
				tag:SetText(GetS(792));
			else
				tag:SetText(GetS(3556));
			end
		end]]
	else
		getglobal("GetMiniBeanReward"):Hide();
	end


	--Zhishu201803Btn 三周年植树 version里配置
	if  check_apiid_ver_conditions( ns_version.zhishu201803_btn, false ) then
		getglobal("Zhishu201803"):Show();
		local tagBkg	= getglobal("Zhishu201803BtnTagBkg");
		local tag		= getglobal("Zhishu201803BtnTag");
		tag:SetText(GetS(966));
		tagBkg:Show();
		tag:Show();
		ActivitBtnFunc("Zhishu201803");
	else
		getglobal("Zhishu201803"):Hide();
		ActivitBtnFunc("LoginReward");		--默认打开登录奖励界面
	end

	--邀请ios
	if false and ns_advert and ns_advert.server_config and ns_advert.server_config.web and ns_advert.server_config.web.SR_invite_no_apiids then
		local finder_ = ClientMgr:getApiId();
		local ret     = string.find( ',' .. ns_advert.server_config.web.SR_invite_no_apiids .. ',',  ',' .. finder_ .. ',' );   --禁止列表
		if  ret then
			getglobal("ShareReservation"):Hide();
		else
			getglobal("ShareReservation"):Show();
			local tagBkg	= getglobal("ShareReservationBtnTagBkg");
			local tag		= getglobal("ShareReservationBtnTag");
			tag:SetText(GetS(893));
			tagBkg:Show();
			tag:Show();
		end
	else
		getglobal("ShareReservation"):Hide();
	end

	--好友召回
	if  ns_advert and ns_advert.server_config and ns_advert.server_config.web and ns_advert.server_config.web.friend_recall_no_apiids then
		local finder_ = ClientMgr:getApiId();
		local ret     = string.find( ',' .. ns_advert.server_config.web.friend_recall_no_apiids .. ',',  ',' .. finder_ .. ',' );   --禁止列表
		if ret then
			getglobal("FriendRecall"):Hide();
		else
			getglobal("FriendRecall"):Show();
		end
	else
		getglobal("FriendRecall"):Hide();
	end

	--Log("元旦活动");
	if ns_ma.ext_gift then
		local giftIndex = ns_ma.ext_gift.index;
		giftIndex = giftIndex and tostring(giftIndex) or "";
		if #giftIndex > 0 and ns_ma.ext_gift[giftIndex] then
			local starttime = getTimeByString(ns_ma.ext_gift.start_time)
			local endtime = getTimeByString(ns_ma.ext_gift.end_time)
			local closetime = getTimeByString(ns_ma.ext_gift.close_time)
			local nowtime = AccountManager:getSvrTime()
			if nowtime < closetime and nowtime >= starttime and nowtime < endtime then
				getglobal("MiniTreasury1BtnName"):SetText(tostring(ns_ma.ext_gift[giftIndex].title));
				getglobal("MiniTreasury1"):Show();
			else
				getglobal("MiniTreasury1"):Hide();
			end
		else
			getglobal("MiniTreasury1"):Hide();
		end
	else
		getglobal("MiniTreasury1"):Hide();
	end

	--mini宝库活动
	for i=1, MaxBaokuNum do
		local frame_name = "MiniTreasury" .. i
		if ns_ma.baoku and ns_ma.baoku[i] then
			local starttime = getTimeByString(ns_ma.baoku[i].start_time)
			local endtime = getTimeByString(ns_ma.baoku[i].end_time)
			local closetime = getTimeByString(ns_ma.baoku[i].close_time)
			local nowtime = AccountManager:getSvrTime()
			
			local name = frame_name.."BtnName"
			if nowtime < closetime and nowtime >= starttime and nowtime < endtime then
				local title = ns_ma.baoku[i].title
				getglobal(name):SetText(title);
				getglobal(frame_name):Show();
			else
				getglobal(frame_name):Hide();
			end
		else
			getglobal(frame_name):Hide();
		end
	end

	if AccountManager:getAccountData():isActivity() then
		if ClientMgr:getApiId() == 1 or IsMiniCps(ClientMgr:getApiId()) then
			getglobal("ActivityReward"):Show();
		else
			getglobal("ActivityReward"):Hide();   --非官方版本不显示
		end
	else
		getglobal("ActivityReward"):Hide();
	end

	--SociallyUseful201903Btn 2019公益活动
	if if_open_sociallyuseful201903_btn() then
		getglobal("SociallyUseful201903"):Show();
		ActivitBtnFunc("SociallyUseful201903");
		press_btn("SociallyUseful201903Btn");
	else
		getglobal("SociallyUseful201903"):Hide();
		ActivitBtnFunc("LoginReward");		--默认打开登录奖励界面
		press_btn("LoginRewardBtn");
	end

	--激活码礼包
	if not ClientMgr:isActivationCodeRewardEnabled() then
		getglobal("ActivationCodeReward"):Hide();
		if ClientMgr:isApple() then --新增配置仅对苹果渠道
			local codecfg = ns_version and ns_version.ios_codereward_cfg;
			if check_apiid_ver_conditions(codecfg) then
				if codecfg and codecfg.open_flag and codecfg.open_flag == 1 then
					getglobal("ActivationCodeReward"):Show();
				end
			end
		end
	end

	-- 幸运盲盒开关
	LuckSquare_CheckOpen()

	-- 生日派对开关
	Birthday_CheckOpen()

	if  ClientCurGame:isInGame() then
		if not getglobal("ActivityFrame"):IsReshow() then
			ClientCurGame:setOperateUI(true);
		end
	end
	WeekendGift_CheckOpen()

	ActivityTypeButtonAligment()

	if IsShowFguiMain() then
		standReportEvent("2", "ACTIVITIES", "-", "view")

		for i=1, #(btnList) do
			local btn = getglobal(btnList[i].Name);
			if btn and btn:IsShown() then
				standReportEvent("2", "ACTIVITIES", "SecondTab", "view", {standby1 = GetS(btnList[i].StringId) or ""})
			end
		end
	end
end

function ActivityTypeButtonAligment()
	local btnList = t_ActivityTypeBtnList
	local hacActivityNum = 0;
	local start_pos = 16;
	local cell_height = 100;
	for i=1, #btnList do
		local frame_name = btnList[i].Name
		-- print("ActivityFrame_OnShow frame_name", i, hacActivityNum, frame_name);
		if getglobal( frame_name ):IsShown() then
			print("ActivityFrame_OnShow frame_name2", frame_name);
			-- if i==1 or i == 2 then
				--首位置是Zhishu201803Btn，不用偏移位置
			-- else
				getglobal( frame_name):SetPoint("topleft", "RewardTypeBoxPlane", "topleft", 9, start_pos+hacActivityNum*cell_height);
			-- end
			hacActivityNum = hacActivityNum + 1
		end
	end

	local box_height = 491
	if hacActivityNum < 6 then
		getglobal("RewardTypeBoxPlane"):SetSize(246, box_height);
	else
		local height = (hacActivityNum-5) * cell_height + box_height + start_pos
		getglobal("RewardTypeBoxPlane"):SetSize(246, height);
	end
end

-- 幸运盲盒开关
function LuckSquare_CheckOpen()
	local bShow = false
	if ns_luck_square_config.activity_switch == 1 then
		if ns_luck_square_config.version_min then
			local clientVersion = ClientMgr:clientVersion()
			local ver_min =	ClientMgr:clientVersionFromStr(ns_luck_square_config.version_min)
			
			if clientVersion >= ver_min then
				bShow = true
			end

			if ns_luck_square_config.version_max then
				local ver_max =	ClientMgr:clientVersionFromStr(ns_luck_square_config.version_max)
				if clientVersion <= ver_max then
					bShow = true
				else
					bShow = false
				end
			end
		end
	end

	if bShow then
		getglobal("LuckSquare"):Show()
	else
		getglobal("LuckSquare"):Hide()
	end
end

-- 生日派对开关
function Birthday_CheckOpen()
	local bShow = false
	
	if check_apiid_ver_conditions(ns_birthday_config.activity_switch) then
		bShow = true
	end

	if bShow then
		getglobal("Birthday"):Show()
	else
		getglobal("Birthday"):Hide()
	end
end

function WeekendGift_CheckOpen()
	getglobal("WeekendGift"):Show()
	standReportEvent("21","ACTIVITIES_PAGE", "Weekendgift", "view")
end

function ActivityFrame_OnHide()
	if SetArchiveDealMsg then     --调试UI容错
		SetArchiveDealMsg(true);
		SetSlidingFrameState(true)
		HideAllActivitBtnCheck();
	end

	if ns_ma.ext_gift and ns_ma.ext_gift.refresh and #ns_ma.ext_gift.refresh > 0 then --迷你宝库刷新
		--Log("ns_ma.ext_gift.refresh");
		--print(ns_ma.ext_gift.refresh)
		GetInst("ShopDataManager"):UpdateSkinPartOwnedFlag(ns_ma.ext_gift.refresh)
	end

	if  ClientCurGame:isInGame() then
		if not getglobal("ActivityFrame"):IsRehide() then
	   		ClientCurGame:setOperateUI(false);
		end
	end
end

function ActivitBtnFUI(btnName, needshowload, param)
	if string.find(btnName, "WeekendGift") then
		param = param or {showInActivityFrame = true}
		ReqGetWeekendGiftStatus(needshowload, param)
		standReportEvent("21","ACTIVITIES_PAGE", "Weekendgift", "click")
	elseif string.find(btnName, "LoginReward") then
		param = param or {showInActivityFrame = true}
		GetInst("activity_home_patService"):OpenUI(param)
	end
end

function ActivityBtnTemplate_OnClick()
	local btnName = this:GetName();
	local frame_name = this:GetParent()
	-- local checked = getglobal(btnName.."Checked");
	-- if btnName == "LoginRewardBtn" then
	-- 	standReportEvent("21", "ACTIVITIES_CONTAINER", "SIGNIN", "click")
	-- end
	getglobal("MItemTipsFrame"):Hide();
	if not getglobal(btnName):IsChecked() then
		threadpool:work(function()
			-- 避免网络的阻塞
			ActivitBtnFunc(frame_name, true);
		end)
		getglobal(btnName .. 'Name'):SetTextColor(55, 54, 49);
	end
	local btnList = t_ActivityTypeBtnList
	for i=1, #btnList do
		local itemBtnName = btnList[i].Name .. 'Btn'
		if itemBtnName ~= btnName then
			getglobal(itemBtnName):Enable(false);

			if HasUIFrame(itemBtnName .. 'Name') then
				getglobal(itemBtnName .. 'Name'):SetTextColor(55, 54, 48);
			end
		else
			if IsShowFguiMain() then
				standReportEvent("2", "ACTIVITIES", "SecondTab", "click", {standby1 = GetS(btnList[i].StringId) or ""})
			end
		end
	end
end

function ActivitBtnFunc(btnName, needshowload , param)
	HideAllActivitBtnCheck();
	local checked = getglobal(btnName.."BtnCheckedBG");
	checked:Show();
	getglobal(btnName..'Btn'):SetChecked(true);

	local td_id_ = 0
	--[[if string.find(btnName, "LoginReward") then	--登录奖励
		td_id_ = 1;
		getglobal("ActivityFrameLoginReward"):Show();
	elseif string.find(btnName, "GetMiniBeanReward") then	--分享奖励]]
	if string.find(btnName, "GetMiniBeanReward") then	--分享奖励
		td_id_ = 2;
		--AccountManager:requestShareGiftInfo();
		ReqOpenGetMiniBeanReward(needshowload)
		if not AccountManager:getNoviceGuideState("sharelink") then
			getglobal("GetMiniBeanRewardBtnRedTag"):Hide();
			AccountManager:setNoviceGuideState("sharelink", true);
			ActivityMainCtrl:CheckRedTag();
		end
	elseif string.find(btnName, "Zhishu201803") then		--植树201803公益
		td_id_ = 3;
		getglobal("ActivityFrameZhishu201803"):Show();
	elseif string.find(btnName, "ActivityReward") then		--活动奖励
		td_id_ = 4;
		getglobal("ActivityFrameActivityReward"):Show();
		--[[
		if not AccountManager:getNoviceGuideState("nationalgift") then
			getglobal("ActivityRewardBtnRedTag"):Hide();
			AccountManager:setNoviceGuideState("nationalgift", true);
			ActivityMainCtrl:CheckRedTag();
		end
		]]
	elseif string.find(btnName, "ShareReservation") then		--ios分享
		td_id_ = 5;
		getglobal("ActivityFrameShareReservation"):Show();

	elseif string.find(btnName, "FriendRecall") then		    --好友召回
		td_id_ = 6;
		getglobal("ActivityFrameFriendRecall"):Show();

	elseif string.find(btnName, "ActivationCodeReward") then
		td_id_ = 7;
		getglobal("ActivityFrameActivationCode"):Show();

	elseif string.find(btnName, "MiniTreasury") then
		MiniBaoKuID = getglobal(btnName):GetClientID()
		td_id_ = 8 + (MiniBaoKuID - 1);
		ActivityMainCtrl:ReqMiniTreasuryData(function()
			getglobal("ActivityFrameTreasury"):Show();			
		end)
	elseif string.find(btnName, "SociallyUseful201903") then
		LoadDonateInfo();
		getglobal("ActivityFrameSociallyUseful201903"):Show();
		--td_id_ = 14;
	elseif string.find(btnName, "LuckSquare") then -- 幸运方块
		LuckSquare_RequestInfo(needshowload)
	elseif string.find(btnName, "Birthday") then -- 生日派对
		getglobal("ActivityFrameBirthday"):Show()
	else
		ActivitBtnFUI(btnName, needshowload, param)
	end

	if  td_id_ > 0 then
		ns_td_exposure_click.add( 1501, td_id_ )   	--活动曝光点击上报
	end
	
end

function HideAllFGUIActivitBtnCheck(frame)
	if frame.Name == "WeekendGift" then
		GetInst("MiniUIManager"):CloseUI("WeekendGiftAutoGen")
		GetInst("MiniUIManager"):CloseUI("Time_limited_giftAutoGen")
	elseif frame.Name == "LoginReward" then
		GetInst("MiniUIManager"):CloseUI("activity_home_patAutoGen")
	end
end

function HideAllActivitBtnCheck()
	local btnList = t_ActivityTypeBtnList
	for i=1, #(btnList) do
		local checked = getglobal(btnList[i].Name .. "BtnCheckedBG");
		checked:Hide();
		getglobal(btnList[i].Name .. 'Btn'):SetChecked(false);
		local frameName = btnList[i].FrameName;
		if frameName ~= "" then
			local frame = getglobal(frameName);
			if frame then
				frame:Hide();
			end
		else
			HideAllFGUIActivitBtnCheck(btnList[i])
		end
	end
end


--------------------------------------------LoginReward-----------------------------------------------
function LoginReward_OnLoad()
	local location = { 27, 137, 238, 347, 454, 559, 665}
	for i=1, LoginRewardListMaxNum do
		getglobal("LoginReward"..i):SetPoint("left", "ActivityFrameLoginRewardProcessBar", "left", location[i], -2);
	end
	this:setUpdateTime(0.1);
	this:RegisterEvent("GE_SIGNIN_CHANGE");
end

function LoginReward_OnEvent()
	if arg1 == "GE_SIGNIN_CHANGE" then
		ActivityMainCtrl:CheckRedTag();
		if getglobal("ActivityFrameLoginReward"):IsShown() then
			UpdateLoginRewardList();
		end
	end
end

function LoginReward_OnUpdate()
	--[[
	local leftArrow = getglobal("ActivityFrameLoginRewardLeftArrow");
	local rightArrow = getglobal("ActivityFrameLoginRewardRightArrow");
	local sliding = getglobal("LoginRewardBox");
	if sliding:getCanMoveLeftDistance() > 0 then
		leftArrow:Show();
	else
		leftArrow:Hide();
	end
	if sliding:getCanMoveRightDistance() > 0 then
		rightArrow:Show();
	else
		rightArrow:Hide();
	end
	--]]
end

function LoginReward_OnShow()
	getglobal("ActivityFrameLoginRewardAdTips"):SetText(GetS(3159), 75, 75, 75);
	UpdateLoginRewardList();
end

function ProcessBar_ValueChanged(i)
	-- location + 14 - 4 = location + 10
	local location = { 0, 37, 147, 248, 357, 464, 569, 675}
	if location[i+1] then
		getglobal("ActivityFrameLoginRewardProcessBarProcess"):ChangeTexUVWidth(location[i+1]);
		if i == 0 then
			getglobal("ActivityFrameLoginRewardProcessBarProcess"):Hide()
		else
			getglobal("ActivityFrameLoginRewardProcessBarProcess"):Show()
			getglobal("ActivityFrameLoginRewardProcessBarProcess"):SetWidth(location[i+1]);
		end
	end
end

local t_DayStringId = {
			[1] = {3146, 3147, 3148, 3149, 3150, 3151, 3152},
			[2] = {3166, 3167, 3168, 3169, 3170, 3171, 3172},
			[3] = {796, 797, 798, 799, 800, 801, 802, 803, 804, 805, 911, 912, 913, 914, 915, 916, 917, 918, 919, 920, 921, 922, 923, 924, 925, 926, 927, 928, 929, 930 },
			}
local t_DayStringStatistics = {
				[1] = {"第一天", "第二天", "第三天", "第四天", "第五天", "第六天", "第七天"},
				[2] = {"星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"},
				[3] = {"一天", "二天", "三天", "四天", "五天", "六天", "七天", "八天", "九天", "十天", "十一天", "十二天", "十三天", "十四天", "十五天", "十六天", "十七天", "十八天", "十九天", "二十天", "二十一", "二十二", "二十三", "二十四", "二十五", "二十六", "二十七", "二十八", "二十九", "三十天" },
				}

function UpdateLoginRewardList()

	if AccountManager.get_time_since_create == nil then
	   return;
	end

	-- getglobal("LoginRewardBox"):resetOffsetPos();

	local signInType = 1;
	local firstSevenDayGift = AccountManager:getAccountData():getFirstSeventDayGift();
	local firstSevenDayTimeGift = AccountManager:getAccountData():getFirstSeventDayTimeGift();
	local seventDayGiftFlag = AccountManager:getAccountData():getSevenDayGiftFlag();
	if true and not AccountManager:isSameWeek(firstSevenDayTimeGift, AccountManager:get_time_since_create()) then
		seventDayGiftFlag = 0;
	end

	if firstSevenDayGift >= 7 then
		signInType = 2;
		if true and AccountManager:isSameDay(firstSevenDayTimeGift, AccountManager:get_time_since_create()) and seventDayGiftFlag == 0 then
			signInType = 1;
		end
	end

	if getglobal("ActivityFrameLoginReward"):IsShown() then
		if signInType == 1 then		--第一周
			getglobal("ActivityFrameLoginRewardAdBkg"):Show();
			getglobal("ActivityFrameLoginRewardAdTips"):Show();
		else				--每周
			getglobal("ActivityFrameLoginRewardAdBkg"):Hide();
			getglobal("ActivityFrameLoginRewardAdTips"):Hide();
		end
	end

	Log( "UpdateLoginRewardList signInType=" .. signInType .. ", firstSevenDayGift=" .. firstSevenDayGift .. ", firstSevenDayTimeGift=" .. firstSevenDayTimeGift);

	--local showNum = 1;
	--local day = nil; --领取第几天的奖励
	--local getBtn = getglobal("ActivityFrameLoginRewardCheckBtn");
	--local getBtnNormal = getglobal("ActivityFrameLoginRewardCheckBtnNormal");
	--getBtnNormal:SetGray(true);
	--getBtn:Disable();
	--for i=1, LoginRewardListMaxNum do
	--	local signInDef = DefMgr:getSignInDef(signInType, i);
	--	if signInDef ~= nil then
	--		local loginReward = getglobal("LoginReward"..i);
	--		local dayFont = getglobal(loginReward:GetName().."Day");
	--		local icon = getglobal(loginReward:GetName().."IconBtnIcon");
	--		local square = getglobal(loginReward:GetName().."Square");
	--		local receivedSquare = getglobal(loginReward:GetName().."ReceivedSquare");
	--		local activeSquare = getglobal(loginReward:GetName().."ActiveSquare");
	--		local iconBkg = getglobal(loginReward:GetName().."IconBkg");
	--		local iconActiveBkg = getglobal(loginReward:GetName().."IconActiveBkg");
	--		local iconActiveArrow = getglobal(loginReward:GetName().."IconActiveArrow");
	--		local num = getglobal(loginReward:GetName() .. "IconBtnNum");
	--		-- local name = getglobal(loginReward:GetName().."Name");
	--		 local iconBtn = getglobal(loginReward:GetName().."IconBtn");
	--		-- local iconBkg1 = getglobal(loginReward:GetName().."IconBtnIconBkg1");
	--		-- local iconBkg2 = getglobal(loginReward:GetName().."IconBtnIconBkg2");
	--
	--		-- local getBtnName = getglobal(loginReward:GetName().."GetBtnName");
	--		-- local getBtnBkg = getglobal(loginReward:GetName().."Bkg");
	--
	--		dayFont:SetText(GetS(t_DayStringId[signInType][i]));
	--		local itemDef = ItemDefCsv:get(signInDef.RewardID);
	--		if itemDef ~= nil then
	--			-- name:SetText(itemDef.Name.."×"..signInDef.RewardNum);
	--			num:SetText("×" .. signInDef.RewardNum);
	--		end
	--		SetItemIcon(icon, signInDef.RewardID);
	--		iconBtn:SetClientUserData(0, signInDef.RewardID);
	--
	--		--Log("XXXX:AccountManager:get_time_since_create()="..AccountManager:get_time_since_create());
	--
	--		if signInType == 2 then
	--			--local whatDay = tonumber(os.date("%w", os.time()));
	--			--LLTODO:
	--			local whatDay = 1;
	--			if true then
	--				whatDay = (math.floor(AccountManager:get_time_since_create() / (24 * 60 * 60)) + 1) % 7;
	--			else
	--				whatDay = tonumber(os.date("%w", AccountManager:getSvrTime()));
	--			end
	--
	--			if whatDay == 0 then whatDay = 7 end
	--			--showNum = whatDay;
	--			Log("whatDay=" .. whatDay)
	--			if whatDay < i then		--还没到日期
	--
	--			else
	--				if true and not AccountManager:check_login_reward() then --bitband(seventDayGiftFlag, i),AccountManager:check_login_reward()
	--				--	iconBkg1:Hide();
	--				--	iconBkg2:Hide();
	--					-- getBtn:Disable();
	--					-- getBtnName:SetTextColor( 118, 96, 64 );
	--					-- getBtnName:SetText(StringDefCsv:get(3411));
	--					-- getBtnNormal:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
	--					-- getBtnNormal:SetTexUV("dljl_ylq01.png");
	--
	--					-- getBtnBkg:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
	--					-- getBtnBkg:SetTexUV("dljl_mrdd_diban01.png");
	--					square:Hide();
	--					receivedSquare:Show();
	--					iconBkg:Show();
	--					iconBtn:SetPoint("center", iconBkg:GetName(), "center", 0, 0);
	--					Log("已经领取" .. i)
	--				else
	--					if whatDay == i then		--可以领取
	--					--	iconBkg1:Hide();
	--					--	iconBkg2:Show();
	--						-- getBtn:Enable();
	--						-- getBtnNormal:SetGray(false);
	--						-- getBtnName:SetText(GetS(3154));
	--
	--						-- getBtnNormal:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
	--						-- getBtnNormal:SetTexUV("dljl_btn01.png");
	--						-- getBtnName:SetTextColor( 10, 80, 10 );
	--
	--						-- getBtnBkg:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
	--						-- getBtnBkg:SetTexUV("dljl_mrdd_diban02.png");
	--						activeSquare:Show();
	--						iconBkg:Hide();
	--						iconActiveBkg:Show();
	--						iconActiveArrow:Show();
	--						iconBtn:SetPoint("center", iconActiveBkg:GetName(), "center", 0, 0);
	--						getBtn:SetClientUserData(0, signInDef.RewardID);
	--						getBtn:SetClientUserData(1, signInDef.RewardNum);
	--						getBtn:SetClientString(signInDef.RewardTips);
	--						getBtn:Enable();
	--						getBtnNormal:SetGray(false);
	--						day = i;
	--					else				--已领取
	--					--	iconBkg1:Hide();
	--					--	iconBkg2:Hide();
	--						-- getBtn:Disable();
	--
	--						-- getBtnName:SetTextColor( 118, 96, 64 );
	--						-- getBtnName:SetText(StringDefCsv:get(3411));
	--						-- getBtnNormal:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
	--						-- getBtnNormal:SetTexUV("dljl_ylq01.png");
	--
	--						-- getBtnBkg:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
	--						-- getBtnBkg:SetTexUV("dljl_mrdd_diban01.png");
	--						activeSquare:Hide();
	--						iconBkg:Show();
	--						iconActiveBkg:Hide();
	--						iconActiveArrow:Hide();
	--						iconBtn:SetPoint("center", iconBkg:GetName(), "center", 0, 0);
	--					end
	--				end
	--			end
	--		elseif signInType == 1 then
	--
	--			Log( "UpdateLoginRewardList firstSevenDayGift=" .. firstSevenDayGift .. "/" .. i );
	--			receivedSquare:Hide();
	--			activeSquare:Hide();
	--			iconActiveBkg:Hide();
	--			iconActiveArrow:Hide();
	--			if i <= firstSevenDayGift then	--已领取
	--			--	iconBkg1:Hide();
	--			--	iconBkg2:Hide();
	--				-- getBtn:Disable();
	--				-- getBtnName:SetText(StringDefCsv:get(3411));
	--				-- getBtnName:SetTextColor( 118, 96, 64 );
	--				-- getBtnNormal:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
	--				-- getBtnNormal:SetTexUV("dljl_ylq01.png");
	--				-- getBtnBkg:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
	--				-- getBtnBkg:SetTexUV("dljl_mrdd_diban01.png");
	--				square:Hide();
	--				receivedSquare:Show();
	--				iconBkg:Show();
	--				iconBtn:SetPoint("center", iconBkg:GetName(), "center", 0, 0);
	--			else
	--				--Log( "UpdateLoginRewardList firstSevenDayTimeGift=" .. firstSevenDayTimeGift .. "/" .. os.time() .. "/" .. AccountManager:getSvrTime() );
	--
	--				if AccountManager:isSameDay(firstSevenDayTimeGift, AccountManager:getSvrTime() ) then --今天的已经领取了
	--					--showNum = firstSevenDayGift;
	--				else
	--					if i == firstSevenDayGift + 1 then	--今天的可领取
	--						--	iconBkg1:Hide();
	--						--	iconBkg2:Show();
	--						-- getBtn:Enable();
	--						-- getBtnNormal:SetGray(false);
	--						-- getBtnName:SetText(GetS(3154));
	--						--showNum = firstSevenDayGift + 1;
	--
	--						activeSquare:Show();
	--						iconBkg:Hide();
	--						iconActiveBkg:Show();
	--						iconActiveArrow:Show();
	--						iconBtn:SetPoint("center", iconActiveBkg:GetName(), "center", 0, 0);
	--						getBtn:SetClientUserData(0, signInDef.RewardID);
	--						getBtn:SetClientUserData(1, signInDef.RewardNum);
	--						getBtn:SetClientString(signInDef.RewardTips);
	--						getBtn:Enable();
	--						getBtnNormal:SetGray(false);
	--						-- getBtnNormal:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
	--						-- getBtnNormal:SetTexUV("dljl_btn01.png");
	--						-- getBtnName:SetTextColor( 10, 80, 10 );
	--						day = i;
	--					else					--之后的尽请期待
	--						--	iconBkg1:Show();
	--						--	iconBkg2:Hide();
	--						-- getBtn:Disable();
	--						-- getBtnName:SetText(GetS(3153));
	--						-- getBtnName:SetTextColor( 118, 96, 64 );
	--						-- getBtnNormal:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
	--						-- getBtnNormal:SetTexUV("dljl_ylq01.png");
	--						-- activeSquare:Show();
	--						-- iconBkg:Hide();
	--						-- iconActiveBkg:Show();
	--						-- iconActiveArrow:Show();
	--						iconBkg:Show();
	--						iconBtn:SetPoint("center", iconBkg:GetName(), "center", 0, 0);
	--					end
	--				end
	--			end
	--		end
	--
	--	end
	--end
	--if day then
	--	getglobal("ActivityFrameLoginRewardCheckBtnName"):SetText(GetS(3561) .. " " .. tostring(day % 7) .. "/7");
	--	ProcessBar_ValueChanged(day % 7);
	--end

	if not AccountManager:check_login_reward() then
		--当前不可以领取登录奖励
		--Log("not check_login_reward()");
		--return;
	end

	local curDay = 0;
	local btn_state = 0; --领取按钮状态: 0不可领取，1~7可领取第几个
	local getBtn = getglobal("ActivityFrameLoginRewardCheckBtn");
	local getBtnNormal = getglobal("ActivityFrameLoginRewardCheckBtnNormal");
	if signInType == 1 then --第一周特殊奖励
		--firstSevenDayGift记录第一周已经签到的天数，从0开始
		curDay = firstSevenDayGift + 1;
	elseif signInType == 2 then --每周一般奖励
		curDay = (math.floor(AccountManager:get_time_since_create() / (24 * 60 * 60)) + 1) % 7;
		if curDay == 0 then curDay = 7 end
	end
	--Log("curDay=" .. curDay)
	--登录签到奖励方案不定，逻辑较乱，UI改版后有时间再梳理 --TODO
	for i=1, LoginRewardListMaxNum do
		local signInDef = DefMgr:getSignInDef(signInType, i);
		if signInDef then
			local icon_state = 0; --图标状态: 0未领取，1当前可领取，2已经领取
			local ui_name = "LoginReward" .. i;
			local square = getglobal(ui_name .."Square");
			local receivedSquare = getglobal(ui_name .."ReceivedSquare");
			local activeSquare = getglobal(ui_name .."ActiveSquare");
			local dayText = getglobal(ui_name .. "Day");
			local iconBkg = getglobal(ui_name .."IconBkg");
			local iconActiveBkg = getglobal(ui_name .."IconActiveBkg");
			local iconActiveArrow = getglobal(ui_name .."IconActiveArrow");
			local iconBtn = getglobal(ui_name.."IconBtn");
			local icon = getglobal(ui_name .."IconBtnIcon");
			local num = getglobal(ui_name .. "IconBtnNum");

			dayText:SetText(GetS(t_DayStringId[signInType][i])); --第几天
			dayText:SetTextColor(55,54,49)
			num:SetText(signInDef.RewardNum); --数量
			SetItemIcon(icon, signInDef.RewardID); --设置物品图标
			iconBtn:SetClientUserData(0, signInDef.RewardID); --设置图标按钮id以弹出tips

			--图标及按钮状态判断
			if curDay == i then
				--if signInType == 1 then --第一周特殊奖励
				--
				--elseif signInType == 2 then --每周一般奖励
				--
				--end
				if AccountManager:check_login_reward() then --AccountManager:check_login_reward()限制每周
					--Log(i.."当前可领取")
					--当前可领取
					icon_state = 1;
					btn_state = i;
					getBtn:SetClientUserData(0, signInDef.RewardID);
					getBtn:SetClientUserData(1, signInDef.RewardNum);
					getBtn:SetClientString(signInDef.RewardTips);
					getBtn:Enable();
					getBtnNormal:SetGray(false);
				else
					--Log(i.."这个周期内已经领取过了")
					--这个周期内已经领取过了
					if AccountManager:isSameDay(firstSevenDayTimeGift, AccountManager:getSvrTime()) then
						if signInType == 1 then
							icon_state = 0;
						else
							icon_state = 2;
						end

					else
						icon_state = 0;
					end

					btn_state = 0;
					getBtn:SetClientUserData(0, signInDef.RewardID);
					getBtn:SetClientUserData(1, signInDef.RewardNum);
					getBtn:SetClientString(signInDef.RewardTips);
					getBtnNormal:SetGray(true);
					getBtn:Disable();
				end
			elseif curDay > i then
				--已经领取
				icon_state = 2;
			else -- curDay < i
				--还未可领取
				icon_state = 0;
			end
			--if signInType == 2 then --每周一般奖励
			--
			--elseif signInType == 1 then --第一周特殊奖励
			--	if firstSevenDayGift >= i then
			--		--已经领取
			--		icon_state = 2;
			--	else
			--		if firstSevenDayGift + 1 == i then
			--			if AccountManager:isSameDay(firstSevenDayTimeGift, AccountManager:getSvrTime()) then
			--				--今天的已经领取了
			--				icon_state = 2;
			--				btn_state = 0;
			--			else
			--				--当前可领取
			--				icon_state = 1;
			--				btn_state = i;
			--			end
			--		else
			--			--还未可领取
			--			icon_state = 0;
			--		end
			--	end
			--end

			--图标贴图状态处理
			if icon_state == 0 then
				--0未领取
				square:Show();
				receivedSquare:Hide();
				activeSquare:Hide();
				iconBkg:Show();
				--iconBkg:SetTexUV("img_icon_custom");
				iconActiveBkg:Hide();
				iconActiveArrow:Hide();
				iconBtn:SetPoint("center", iconBkg:GetName(), "center", 0, 0);
				num:SetPoint("bottomright",iconBkg:GetName(),"bottomright",-5,-5)
			elseif icon_state == 1 then
				--1当前可领取
				square:Hide();
				receivedSquare:Hide();
				activeSquare:Show();
				iconBkg:Hide();
				iconActiveBkg:Show();
				iconActiveArrow:Show();
				iconBtn:SetPoint("center", iconActiveBkg:GetName(), "center", 0, 0);
				num:SetPoint("bottomright",iconActiveBkg:GetName(),"bottomright",-5,-5)
			elseif icon_state == 2 then
				--2已经领取
				square:Hide();
				receivedSquare:Show();
				activeSquare:Hide();
				iconBkg:Show();
				--iconBkg:SetTexUV("img_icon_custom_g");
				iconActiveBkg:Hide();
				iconActiveArrow:Hide();
				iconBtn:SetPoint("center", iconBkg:GetName(), "center", 0, 0);
				num:SetPoint("bottomright",iconBkg:GetName(),"bottomright",-5,-5)
			end

		end
	end

	if curDay then
		if signInType == 1 then
			curDay = curDay - 1;
		else
			if not AccountManager:isSameDay(firstSevenDayTimeGift, AccountManager:getSvrTime()) then
				curDay = curDay - 1;
			end
		end

		getglobal("ActivityFrameLoginRewardCheckBtnName"):SetText(GetS(3561) .. " " .. tostring(curDay % 7) .. "/7");
		ProcessBar_ValueChanged(curDay % 7); --ProcessBar_ValueChanged有处理为0的情况
	end
end

function LoginRewardBtnGetBtn_OnClick()
    local this = this
	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3);
		return;
	end

	if string.find(this:GetName(), "LoginReward") then
		local itemId = this:GetClientUserData(0);
		
		--检查仓库是否已满--超出仓库容量，请清理之后再领取奖励

		local t_loginRewardId={};
		table.insert(t_loginRewardId,itemId);--登录领取迷你豆不提示仓库满
		if AccountManager.itemlist_can_add and not AccountManager:itemlist_can_add(t_loginRewardId) and itemId ~= 10000 then
			StashIsFullTips();
			return;
		end
		if AccountManager:getAccountData():notifyServerSignReward() ~= 0 then
			--ShowGameTips(StringDefCsv:get(282), 3);
		else
			local itemNum = this:GetClientUserData(1);
			local itemDesc = this:GetClientString();

			local itemDef = ItemDefCsv:get(itemId);
			if itemDef ~= nil then
				local t_Items = {};
				table.insert(t_Items, {id=itemId, num=itemNum});
				SetGameRewardFrameInfo(GetS(3141), t_Items, itemDesc);

				--统计签到事件
				local signInType = 1;
				local firstSevenDayGift = AccountManager:getAccountData():getFirstSeventDayGift();
				local firstSevenDayTimeGift = AccountManager:getAccountData():getFirstSeventDayTimeGift();
				local seventDayGiftFlag = AccountManager:getAccountData():getSevenDayGiftFlag();
				if true and not AccountManager:isSameWeek(firstSevenDayTimeGift, AccountManager:get_time_since_create()) then
					seventDayGiftFlag = 0;
				end
				if firstSevenDayGift >= 7 then
					signInType = 2;
					if AccountManager:isSameDay(firstSevenDayTimeGift, AccountManager:getSvrTime()) and seventDayGiftFlag == 0 then
						signInType = 1;
					end
				end
				local idx = this:GetParentFrame():GetClientID();
				local content1 = t_DayStringStatistics[signInType][idx];
				StatisticsTools:gameEvent("LoginSignEvent", "登录签到", content1, "签到获得", itemDef.Name);
			end

			if getglobal("LoginRewardBtnRedTag"):IsShown() then
				getglobal("LoginRewardBtnRedTag"):Hide();
			end

			ActivityMainCtrl:CheckRedTag();
		end
	elseif string.find(this:GetName(), "ActivityReward") then
		if AccountManager:getAccountData():notifyServerActivityReward() ~= 0 then
			--ShowGameTips(StringDefCsv:get(282), 3);
		else
			local itemId = this:GetClientUserData(0);
			local itemNum = this:GetClientUserData(1);
			local itemDesc = this:GetClientString();

			local itemDef = ItemDefCsv:get(itemId);
			if itemDef ~= nil then
				local t_Items = {};
				table.insert(t_Items, {id=itemId, num=itemNum});
				SetGameRewardFrameInfo(GetS(806), t_Items, itemDesc);
			end
			if getglobal("ActivityRewardBtnRedTag"):IsShown() then
				getglobal("ActivityRewardBtnRedTag"):Hide();
			end

			UpdateActivityReward();
			ActivityMainCtrl:CheckRedTag();
		end
	end
end

function LoginRewardBtnIconBtn_OnClick()
	if arg1 < 0.6 then return end

	local itemId = this:GetClientUserData(0);
	if itemId > 0 then	--星星不显示tips
		SetMTipsInfo(-1, this:GetName(), true, itemId);
	end
end

function LoginRewardBtnIconBtn_OnMouseUp()
	local MItemTipsFrame = getglobal("MItemTipsFrame");
	if MItemTipsFrame:IsShown() and IsLongPressTips then
		MItemTipsFrame:Hide();
	end
end

--鼠标进入, 显示详情页
function LoginRewardBarItemTemplate_OnMouseEnter_PC()
	--Log("MARewardBtnTemplate_OnMouseEnter_PC:");
	if getglobal("MItemTipsFrame"):IsShown() then
		return;
	end

	local itemId = this:GetClientUserData(0);
	if itemId > 0 then	--星星不显示tips
		SetMTipsInfo(-1, this:GetName(), true, itemId);
	end
end

--鼠标移出, 关闭
function LoginRewardBarItemTemplate_OnMouseLeave_PC()
	HideMTipsInfo();
end
--登录奖励图片按钮
function LoginRewardPicBtn_OnClick()
	local content = ns_activity.content;
	if content and content.pic and content.pic.action then
		global_jump_ui( content.pic.action, content.pic.action_url, content.pic.string_code );
		ActivityMainFrame:BackBtnOnClick();
	end
end

-------------------------------weekendgift start --------------------------------------------

function ReqGetWeekendGiftStatus(needshowload, param)
	--[[if GetInst("WeekendGiftDataMgr").init then
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/weekend_package", "miniui/miniworld/c_weekend_package"})
		GetInst("MiniUIManager"):OpenUI("WeekendGift","miniui/miniworld/weekend_package","WeekendGiftAutoGen", param)
		return
	end]]
	if needshowload then
		ShowLoadLoopFrame(true, "file:activity -- func:ReqGetWeekendGiftStatus")
	end

	local function getWeekendStatusCallBack(retstr)
		--if getglobal("WeekendGiftBtn"):IsChecked() then
			ShowLoadLoopFrame(false)
		--end
		print("ReqGetWeekendGiftStatus", retstr);

		local ret = safe_string2table(retstr)
		print("ReqGetWeekendGiftStatus ret", ret);

		if ret.ret == 0 then
			GetInst("WeekendGiftDataMgr"):OnDataCallback(ret.msg)
		else
			return
		end
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/weekend_package", "miniui/miniworld/c_weekend_package"})
		GetInst("MiniUIManager"):OpenUI("WeekendGift","miniui/miniworld/weekend_package","WeekendGiftAutoGen", param)
	end
	if GetInst("WeekendPackagev2DataManager"):CanShow() then
		WeekendGiftReqGiftStatusV2()
	else
		WeekendGiftReqGiftStatus(getWeekendStatusCallBack)
	end
end

-------------------------------weekendgiftend -----------------------------------------


----------------------------------------GetMiniBeanReward---------------------------------------------
function ReqOpenGetMiniBeanReward(needshowload)
	--[[
	if not ns_shop_config2 or not ns_shop_config2.share_cfg then
		ShowGameTips("分享迷你豆配置信息拉取失败");
	end
	]]

	local get_share_win_bean_info_CallBack = function (ret)
		if getglobal("GetMiniBeanRewardBtn"):IsChecked() then
			ShowLoadLoopFrame(false)
		end
		print("ReqOpenGetMiniBeanReward ret", ret);
		--cctodo	AdTimes参数待服务器补充接口
		if ret and ret.ret == 0 then
			if getglobal("GetMiniBeanRewardBtn"):IsChecked() then
				UpdateGetMiniBeanReward(0, ret.data)
			else  --更新红点
				if ret.data.first_share_status == 1 then
					getglobal("GetMiniBeanRewardBtnRedTag"):Show();
					_G.HasShareReward = true;
				else
					getglobal("GetMiniBeanRewardBtnRedTag"):Hide();
					_G.HasShareReward = false;
				end
			end
		else
			if ret then
				print("ReqOpenGetMiniBeanReward error ret:", ret.ret);
			end
		end
	end
	if needshowload then
		ShowLoadLoopFrame(true, "file:activity -- func:ReqOpenGetMiniBeanReward")
	end
	local temp_url = g_http_root .. "miniw/php_cmd?act=get_share_win_bean_info&" .. http_getS1(true)
	ns_http.func.rpc(temp_url, get_share_win_bean_info_CallBack, nil, nil, true)
end

--local MiniBeanDayAdTimes;
--local MiniBeanWeekGetTimes;
local weekFont = nil
--local localWeekTimes = 0
local ShareBeanRewards = nil
function UpdateGetMiniBeanReward(result, data)
	local t_data = {
		total_data = 0,
		first_share_status = 0,
		share_times = 0,
		ad_times = 0,
		reward = nil,
	}
	--收到服务器的数据，更新一下信息
	for key, value in pairs(data) do
		if t_data[key] then
			t_data[key] = value;
		end
	end

	print("kekeke UpdateGetMiniBeanReward", t_data)

	local totalTips 	= getglobal("ActivityFrameGetMiniBeanRewardName")
	local getBtn 		= getglobal("ActivityFrameGetMiniBeanRewardGetBtn")
	local getBtnDesc	= getglobal("ActivityFrameGetMiniBeanRewardGetBtDesc")
	local getBtnNum		= getglobal("ActivityFrameGetMiniBeanRewardGetBtNum")
	local BarIcon		= getglobal("ActivityFrameGetMiniBeanRewardBarIcon")
	local FirstShareTipsDesc = getglobal("ActivityFrameGetMiniBeanRewardFirstShareTipsDesc")
	local FirstShareTipsNum = getglobal("ActivityFrameGetMiniBeanRewardFirstShareTipsNum")

	--if ClientMgr and ClientMgr:isMobile() then
	if ClientMgr and ClientMgr:isPC() then
		getBtn:Show();
		getBtnDesc:Show();
		getBtnNum:Show();
	else
		getBtn:Hide();
		getBtnDesc:Hide();
		getBtnNum:Hide();
	end

	local toal_days = t_data.total_data;	--累计天数
	totalTips:SetText(GetS(71003, toal_days));
	local dayState = t_data.share_times;	--分享次数
	local pcFirstShareStatus = t_data.first_share_status;
	ShareBeanRewards = data.reward
	--MiniBeanDayAdTimes = 3
	--MiniBeanWeekGetTimes = weekGetTimes;
	getBtnNum:SetText(ns_shop_config2.share_cfg.reward.share_first_reward[2])

	FirstShareTipsNum:SetText(ns_shop_config2.share_cfg.reward.share_first_reward[2])
	FirstShareTipsDesc:SetText(GetS(ns_shop_config2.share_cfg.reward.share_firest_word1))
	if result == 0 then	--拉取到分享信息
		--local descTitle 	= getglobal("ActivityFrameGetMiniBeanRewardDescTitle");
		--local descIcon 	= getglobal("ActivityFrameGetMiniBeanRewardDescIcon");
		--local desc		= getglobal("ActivityFrameGetMiniBeanRewardDesc");
		--local clickNumTitle	= getglobal("ActivityFrameGetMiniBeanRewardClickNumTitle");
		--local clickNumBkg	= getglobal("ActivityFrameGetMiniBeanRewardClickNumBkg");
		--local clickNum		= getglobal("ActivityFrameGetMiniBeanRewardClickNum");
		--local weekTitle		= getglobal("ActivityFrameGetMiniBeanRewardWeekTitle");

		--ShareGetMiniBeanType = 0;
		local scale = UIFrameMgr:GetScreenScale();
		local width;
		--[[
		if ShareGetMiniBeanType == 3 then	--春节活动
			--clickNumTitle:Show();
			--clickNumBkg:Show();
			--clickNum:Show();

			--clickNum:SetText(dayTimes);

			--descTitle:SetText(GetS(3557));
			width = descTitle:GetTextExtentWidth(GetS(3557))/scale + 10;
			desc:SetText(GetS(3558));

			--weekTitle:SetText(GetS(3572));

			--todayFont:SetText(hasTimes);
			weekFont:SetText(GetS(71003, weekGetTimes));
			localWeekTimes = weekGetTimes

			if hasTimes > 0 then
				getBtn:Enable();
				getBtnDesc:SetText(GetS(3702))
				getBtnDesc:SetTextColor(10, 170, 26)
				--getBtnNormal:SetGray(false);
			else
				getBtn:Disable();
				getBtnDesc:SetText(GetS(3720))
				getBtnDesc:SetTextColor(142, 153, 155)
				--getBtnNormal:SetGray(true);
				--beanNum:SetText(0);
			end
		else
			--clickNumTitle:Hide();
			--clickNumBkg:Hide();
			--:Hide();

			--descTitle:SetText(GetS(732));
			--width = descTitle:GetTextExtentWidth(GetS(732))/scale + 10;
			--desc:SetText(GetS(733));

			--weekTitle:SetText(GetS(735));

			--if dayTimes > 5 then dayTimes = 5 end

			weekFont:SetText(GetS(71003, weekGetTimes));
			localWeekTimes = weekGetTimes
			if times > 0 then
				getBtn:Enable();
				getBtnDesc:SetText(GetS(3702))
				getBtnDesc:SetTextColor(10, 170, 26)
				--getBtnNormal:SetGray(false);
			else
				getBtn:Disable();
				getBtnDesc:SetText(GetS(3720))
				getBtnDesc:SetTextColor(142, 153, 155)
				--getBtnNormal:SetGray(true);
			end

			if multiple == 2 then
				--tagBkg:Show();
				--tag:Show();
				--beanNum:SetTextColor(244, 178, 34);
			else

			end
		end]]
		if toal_days <= 0 then
			BarIcon:SetWidth(15)
		else
			BarIcon:SetWidth(45 + (toal_days - 1)* 64)
		end

		if dayState == 0 then
			getglobal("ActivityFrameGetMiniBeanRewardFirstShareTips"):Show()
		else
			getglobal("ActivityFrameGetMiniBeanRewardFirstShareTips"):Hide()
		end
		if pcFirstShareStatus == 0 then
			getBtn:Disable();  --迷你豆领取图标
			getBtnDesc:SetText(GetS(3158))
			getBtnDesc:SetTextColor(142, 153, 155)
		elseif pcFirstShareStatus == 1 then
			getBtn:Enable();
			getBtnDesc:SetText(GetS(3702))
			getBtnDesc:SetTextColor(10, 170, 26)
		elseif pcFirstShareStatus == 2 then
			getBtn:Disable();
			getBtnDesc:SetText(GetS(3720))
			getBtnDesc:SetTextColor(142, 153, 155)
		end
	else
		ShowGameTips(GetS(761), 3);
		----todayFont:SetText(0);
		--weekFont:SetText(GetS(71003, 0));
		--localWeekTimes = weekGetTimes
		--beanNum:SetText("20");
		getBtn:Disable();
		getBtnDesc:SetText(GetS(3720))
		getBtnDesc:SetTextColor(142, 153, 155)
		--getBtnNormal:SetGray(true);
		BarIcon:SetWidth(15)
	end

	local t_accumulation = ns_shop_config2.share_cfg.reward.accumulation;
	for k, v in pairs(t_accumulation) do
		local GetMiniBeanRewardGiftBtn = getglobal("ActivityFrameGetMiniBeanRewardGiftBtn" .. k)
		local Icon = getglobal("ActivityFrameGetMiniBeanRewardGiftBtn" .. k.."Icon");
		if not data.reward or (data.reward and data.reward[v[1]] and data.reward[v[1]] == 0) then
			GetMiniBeanRewardGiftBtn:SetGray(false)
			GetMiniBeanRewardGiftBtn:SetSize(92, 92)
			if v[1] == 7 then  --7天大奖
				Icon:SetTexture("items/icon_box_2.png");
			else
				Icon:SetTexture("items/icon_box_1.png");
			end
		elseif data.reward and data.reward[v[1]] and data.reward[v[1]] == 1 then
			GetMiniBeanRewardGiftBtn:SetGray(false)
			GetMiniBeanRewardGiftBtn:SetSize(100, 100)
			if v[1] == 7 then
				Icon:SetTexture("items/icon_box_2.png");
			else
				Icon:SetTexture("items/icon_box_1.png");
			end
		elseif data.reward and data.reward[v[1]] and data.reward[v[1]] == 2 then
			GetMiniBeanRewardGiftBtn:SetGray(true)
			GetMiniBeanRewardGiftBtn:SetSize(92, 92)
			if v[1] == 7 then
				Icon:SetTexture("items/icon_box_4.png");
			else
				Icon:SetTexture("items/icon_box_3.png");
			end
		else
			GetMiniBeanRewardGiftBtn:SetGray(false)
			GetMiniBeanRewardGiftBtn:SetSize(92, 92)
			if v[1] == 7 then
				Icon:SetTexture("items/icon_box_2.png");
			else
				Icon:SetTexture("items/icon_box_1.png");
			end
		end
	end

	if not getglobal("ActivityFrameGetMiniBeanReward"):IsShown() then
		getglobal("ActivityFrameGetMiniBeanReward"):Show();
		
		MiniBeanRewardViewStandReportEvent(t_data)
	end

	UpdateGetMiniBeanRewardADBtn(t_data.ad_times, dayState);
end

--分享迷你豆曝光相关埋点
function MiniBeanRewardViewStandReportEvent(t_data)
	--埋点
	standReportEvent("21", "SHAERWINMINIBEAN", "-", "view", {standby1 = t_data.total_data});	
	for i=1, 4 do
		standReportEvent("21", "SHAERWINMINIBEAN", "ActivityButton"..i, "view");
	end
	local isPc = (ClientMgr and ClientMgr:isPC()) and 1 or 0;
	standReportEvent("21", "SHAERWINMINIBEAN", "ShareButton", "view", {standby1=isPc});
	if isPc == 1 then
		standReportEvent("21", "SHAERWINMINIBEAN", "PCShareReward", "view");
	end
end

local ActivityFrameGetMiniBeanRewardPic = nil
function GetMiniBeanReward_OnShow()
	--getglobal("ActivityFrameTitleTitleFont"):SetText(StringDefCsv:get(731));

	local ind = 1
	local activityPicList = {}
	while true do
		local picKey = "picture" .. ind
		if not ns_shop_config2.share_cfg[picKey] then
			break
		end
		local filekey = ns_advert.func.trimUrlFile(ns_shop_config2.share_cfg[picKey])
		activityPicList[filekey] = ns_shop_config2.share_cfg[picKey]
		ind = ind + 1
	end
	activityPicList[ns_advert.func.trimUrlFile(ns_shop_config2.share_cfg.Title_picture)] = ns_shop_config2.share_cfg.Title_picture

	local loadingCache = getkv("ActivityBannerCache") or {}
	if loadingCache then
		for key, value in pairs(loadingCache) do
			local isExist = -1
			local keyPath = g_download_root .. "activityPic_" .. key
			-- 删除不在服务器下发列表中的图片，删除记录
			if activityPicList[key] then
				if gFunc_isStdioFileExist(keyPath) then
					loadingCache[key] = true
				else
					loadingCache[key] = false
				end
			else
				-- 图片不存在,删除记录
				if gFunc_isStdioFileExist(keyPath) then
					gFunc_deleteStdioFile(keyPath)
				end
				loadingCache[key] = false
			end
		end
	end

	for key, value in pairs(activityPicList) do
		local keyPath = g_download_root .. "activityPic_" .. key
		local function downloadFinish()
			if gFunc_isStdioFileExist(keyPath) then
				local loadingCache2 = getkv("ActivityBannerCache") or {}
				loadingCache2[key] = true
				setkv("ActivityBannerCache", loadingCache2)
			end
		end
		if not gFunc_isStdioFileExist(keyPath) then
			ns_http.func.downloadPng(value, keyPath, nil, nil, downloadFinish)
		else
			local loadingCache2 = getkv("ActivityBannerCache") or {}
			loadingCache2[key] = true
			setkv("ActivityBannerCache", loadingCache2)
		end
	end

	local picCache = getkv("ActivityBannerCache") or {}
	local titlePic = "ui/mobile/texture0/bigtex/shengli1.png"
	if picCache[ns_advert.func.trimUrlFile(ns_shop_config2.share_cfg.Title_picture)] then
		local keyPath = g_download_root .. "activityPic_" .. ns_advert.func.trimUrlFile(ns_shop_config2.share_cfg.Title_picture)
		if gFunc_isStdioFileExist(keyPath) then
			titlePic = keyPath
		end
	end

	if not ActivityFrameGetMiniBeanRewardPic then
		ActivityFrameGetMiniBeanRewardPic = getglobal("ActivityFrameGetMiniBeanRewardPic")
	end
	ActivityFrameGetMiniBeanRewardPic:SetTexture(titlePic)


	local uin = AccountManager:getUin();
	local text = "";
	if uin == 1 then
		text = GetS(760);
	--elseif IsOverseasVer() then
		--text = "http://en.mini1.cn/";
	else
		text = ClientMgr:getShareLink().."?uin="..uin;
	end
	--getglobal("ActivityFrameGetMiniBeanRewardLink"):SetText(text);

	--[[
	if SdkManager:isShareEnabled() then
		if ClientMgr:isPC() then
			getglobal("ActivityFrameGetMiniBeanRewardCopyBtnName"):SetText(GetS(32043));
		else
			getglobal("ActivityFrameGetMiniBeanRewardCopyBtnName"):SetText(GetS(3510));
		end

	end]]

	UpdateBeanRewardTime();

	if ns_shop_config2 and ns_shop_config2.share_cfg then
		for i=1, 4 do
			local tips =  getglobal("ActivityFrameGetMiniBeanRewardDayTips"..i) ;
			local keyname = "sum"..i.."_string";
			if ns_shop_config2.share_cfg[keyname] then
				tips:SetText(GetS(ns_shop_config2.share_cfg[keyname]));
			end
		end

		getglobal("ActivityFrameGetMiniBeanRewardGiftBtn4TagName"):SetText(GetS(ns_shop_config2.share_cfg.tag_string))
	end
end

function UpdateGetMiniBeanRewardADBtn(ad_times, dayState)
	--local t = {dayTimes = MiniBeanDayAdTimes, weekTimes = MiniBeanWeekGetTimes}

	local configShow = false;
	local adMax =3;
	if ns_shop_config2 and ns_shop_config2.share_cfg and ns_shop_config2.share_cfg.reward then 
		if ns_shop_config2.share_cfg.reward.ad_apiids then 
			local finder_ = ',' .. ClientMgr:getApiId() .. ',';
			configShow = string.find( ',' .. ns_shop_config2.share_cfg.reward.ad_apiids  .. ',', finder_ );
		end
		if ns_shop_config2.share_cfg.reward and ns_shop_config2.share_cfg.reward.ad_max then
			adMax = ns_shop_config2.share_cfg.reward.ad_max;
		end
	end

	if ClientMgr and ClientMgr:isPC() then
		configShow = false
	end

	local t = {adTimes = ad_times}
	print("canshow:", ns_shop_config2.share_cfg.apiids, configShow, t);
	local position_id = 7
	if IsAdUseNewLogic(position_id) then	
		-- codeby : fym 7号广告位：公告福利页-活动-观看广告代替一次分享
		if configShow then
			GetInst("AdService"):IsAdCanShow(position_id, function(result, ad_info)
				if result then
					getglobal("ActivityFrameGetMiniBeanRewardADBtn"):Show();
					StatisticsADNew('show', position_id, ad_info);
					standReportEvent("21", "SHAERWINMINIBEAN", "WatchButton1", "view");

					if IsAdReportUseNewLogic(position_id) then
						GetInst("AdService"):Ad_Show(position_id)
					elseif AccountManager.ad_show then
						AccountManager:ad_show(position_id);				
					end
	
					if dayState == 0 then
						getglobal("ActivityFrameGetMiniBeanRewardADBtnName"):SetText(GetS(4936))
					else
						getglobal("ActivityFrameGetMiniBeanRewardADBtnName"):SetText(GetS(30122))
					end
	
					if ad_times >= adMax then
						getglobal("ActivityFrameGetMiniBeanRewardADBtn"):Disable()
					else 
						getglobal("ActivityFrameGetMiniBeanRewardADBtn"):Enable();
					end
				else
					getglobal("ActivityFrameGetMiniBeanRewardADBtn"):Hide();
				end
			end)
		else
			getglobal("ActivityFrameGetMiniBeanRewardADBtn"):Hide();
		end
	else
		if t_ad_data.canShow(7, t) and configShow then	--广告
			getglobal("ActivityFrameGetMiniBeanRewardADBtn"):Show();
			StatisticsAD('show', 7);
			standReportEvent("21", "SHAERWINMINIBEAN", "WatchButton1", "view");
			if AccountManager.ad_show then
				AccountManager:ad_show(7);
			end
	
			if dayState == 0 then
				getglobal("ActivityFrameGetMiniBeanRewardADBtnName"):SetText(GetS(4936))
			else
				getglobal("ActivityFrameGetMiniBeanRewardADBtnName"):SetText(GetS(30122))
			end
	
			if ad_times >= adMax then
				getglobal("ActivityFrameGetMiniBeanRewardADBtn"):Disable()
			else 
				getglobal("ActivityFrameGetMiniBeanRewardADBtn"):Enable();
			end
		else
			getglobal("ActivityFrameGetMiniBeanRewardADBtn"):Hide();
		end
	end
end

--LLTODO:更新时间,显示多久后可领取
function UpdateBeanRewardTime()
	--local TimeTip = getglobal("ActivityFrameGetMiniBeanRewardTimeTip");

	local nTimestamp = getServerNow() % 86400 + 8 * 60 * 60;

	if nTimestamp / (60 * 60) >= 24 then
		nTimestamp = nTimestamp - 24 * 60 * 60;
	end

	--每天4点刷新
	if nTimestamp >= 4 * 60 * 60 then
		nTimestamp = 24 * 60 * 60 - (nTimestamp - 4 * 60 * 60);
	else
		nTimestamp = 4 * 60 * 60 - nTimestamp;
	end

	if true then
		--提示多久后能领取
		local nShowTime = 1;
		local TimeTipText = "";

		if nTimestamp / (60 * 60) >= 1 then
			--时
			TimeTipText = "（"..math.floor(nTimestamp / (60 * 60))..GetS(931).."）";
		elseif nTimestamp / (60) >= 1 then
			--分
			TimeTipText = "（"..math.floor(nTimestamp / (60))..GetS(932).."）";
		else
			--不足一分算一分
			TimeTipText = "（1"..GetS(932).."）";
		end

		--TimeTip:SetText(TimeTipText);
		--TimeTip:Show();
	else
		--可以领取
		--TimeTip:Hide();
	end
end

function GetMiniBeanReward_OnHide()
	if getglobal("LoadLoopFrame"):IsShown() then
		ShowLoadLoopFrame(false)
	end
end

function GetMiniBeanRewardGetBtn_OnClick()
	-- cctodo	PC端点击迷你豆图标领取奖励
	local RewardGetBtn_CallBack = function (ret)
		print("RewardGetBtn_CallBack ret", ret);
		
		if ret and ret.ret == 0 then
			UpdateGetMiniBeanReward(0, ret.data);

			local t_GetItems = {};			
			if ret.num and ret.num > 0 and ns_shop_config2 and ns_shop_config2.share_cfg.reward.share_first_reward then
				local t_shareReward = ns_shop_config2.share_cfg.reward.share_first_reward;
				if t_shareReward[1] and type(t_shareReward[1]) == 'number' then
					table.insert(t_GetItems, {id=t_shareReward[1], num=ret.num})  --分享
				end
			end

			SetGameRewardFrameInfo(GetS(3403), t_GetItems, GetS(4891));
			_G.HasShareReward = false;
		else
			if ret then
				print("分享获得迷你豆提示 error:", ret.ret);
			end
		end
	end

	--埋点
	local itemIds = "";
	if ns_shop_config2 and ns_shop_config2.share_cfg.reward.share_first_reward then
		local t_shareReward = ns_shop_config2.share_cfg.reward.share_first_reward;
		itemIds = ""..t_shareReward[1];
	end
	standReportEvent("21", "SHAERWINMINIBEAN", "PCShareReward", "click", {standby1=itemIds});

	local temp_url = g_http_root .. "miniw/php_cmd?act=get_first_share_reward&" .. http_getS1(true)
	ns_http.func.rpc(temp_url, RewardGetBtn_CallBack, nil, nil, true)

	--[[
	local getBtn 		= getglobal("ActivityFrameGetMiniBeanRewardGetBtn");
	local getBtnDesc	= getglobal("ActivityFrameGetMiniBeanRewardGetBtDesc")
	local miniBean = AccountManager:requestShareGift();
	if miniBean == -1 then		--数据错误
		ShowGameTips(GetS(759), 3);
	elseif miniBean == -2 then	--每天次数限制
		ShowGameTips(GetS(756), 3);
	elseif miniBean == -3 then	--每周次数限制
		ShowGameTips(GetS(757), 3);
	elseif miniBean == -999 then	--网络异常
		--ShowGameTips(GetS(37), 3); ---异常提示tips在c++里已经发出
	else				--成功领取
		ShowGameTips(GetS(758), 3);
		AccountManager:getAccountData():setMiniBean(miniBean);
		UpdateGetMiniBeanRewardDay();

		--统计领取分享奖励
		StatisticsTools:gameEvent("ShareRewardEvent",AccountManager:getUin());
	end
	getBtn:Disable();
	getBtnDesc:SetText(GetS(3720))
	getBtnDesc:SetTextColor(142, 153, 155)
	]]
end

--看广告后或者移动端分享成功后通知到服务器
function NotifyShareOrWatchAD_CallBack(ret)
	print("NotifyShareOrWatchAD_CallBack ret", ret);
	if ret and ret.ret == 0 then
		--ShowGameTips("分享获得迷你豆提示");
		UpdateGetMiniBeanReward(0, ret.data);

		local t_GetItems = {};
		print("ns_shop_config2.share_cfg = ",ns_shop_config2.share_cfg)
		if ret.data and ret.data.first_share_status ~= 1 and ret.share_num and ret.share_num > 0 
			and ns_shop_config2 and ns_shop_config2.share_cfg.reward.share_first_reward then
			local t_shareReward = ns_shop_config2.share_cfg.reward.share_first_reward;
			if t_shareReward[1] and type(t_shareReward[1]) == 'number' then
				table.insert(t_GetItems, {id=t_shareReward[1], num=ret.share_num})  --分享
			end
		end
		if ret.ad_num and ret.ad_num > 0 and ns_shop_config2 and ns_shop_config2.share_cfg.reward.ad_reward then
			local t_adReward = ns_shop_config2.share_cfg.reward.ad_reward;
			if t_adReward[1] and type(t_adReward[1]) == 'number' then
				table.insert(t_GetItems, {id=t_adReward[1], num=ret.ad_num})	--看广告
			end
		end
		SetGameRewardFrameInfo(GetS(3403), t_GetItems, GetS(4891));
	else
		if ret then
			print("分享获得迷你豆提示 error:", ret.ret);
		end
	end
end
--type 1移动端分享、2看广告
function NotifyShareOrWatchAD(shareType)
	--埋点
	local itemIds = "";
	if ns_shop_config2 and ns_shop_config2.share_cfg.reward.share_first_reward then
		local t_shareReward = ns_shop_config2.share_cfg.reward.share_first_reward;
		if t_shareReward[1] and type(t_shareReward[1]) == 'number' then
			if itemIds ~= "" then
				itemIds = itemIds..",";
			end
			itemIds = itemIds..t_shareReward[1];
		end
	end
	if ns_shop_config2 and ns_shop_config2.share_cfg.reward.ad_reward then
		local t_adReward = ns_shop_config2.share_cfg.reward.ad_reward;
		if t_adReward[1] and type(t_adReward[1]) == 'number' then
			if itemIds ~= "" then
				itemIds = itemIds..",";
			end
			itemIds = itemIds..t_adReward[1];
		end
	end
	if shareType == 2 then
		standReportEvent("21", "SHAERWINMINIBEAN", "WatchButton2", "ad_complete", {standby1=itemIds});
	elseif shareType == 1 then
		-- standReportEvent("21", "SHAERWINMINIBEAN", "MobileShareSuccessful", "-", {standby1=itemIds});
	end

	local temp_url = g_http_root .. "miniw/php_cmd?act=set_share_win_bean_data&" .. http_getS1(true).."&flag="..shareType
	ns_http.func.rpc(temp_url, NotifyShareOrWatchAD_CallBack, nil, nil, true)
end

function UpdateGetMiniBeanRewardDay()
	--local todayFont 	= getglobal("ActivityFrameGetMiniBeanRewardToday");

	--local num = --todayFont:GetText() - 1;
	--todayFont:SetText(num);

	--if num == 0 then
	--	local getBtn 		= getglobal("ActivityFrameGetMiniBeanRewardGetBtn");
	--	local getBtnNormal	= getglobal("ActivityFrameGetMiniBeanRewardGetBtnNormal");
	--	getBtn:Disable();
	--	getBtnNormal:SetGray(true);
	--end
	--local num = localWeekTimes+1;
	--:SetText(GetS(71003, num));
	localWeekTimes = num
end

function GetMiniBeanRewardCopyBtn_OnClick()
	local isPc = (ClientMgr and ClientMgr:isPC()) and 1 or 0;

	standReportEvent("21", "SHAERWINMINIBEAN", "ShareButton", "click", {standby1=isPc});
	if SdkManager:isShareEnabled() then
		Log("isShareEnabled");
		
		if ClientMgr and ClientMgr:isPC() then
			local temp_url = g_http_root .. "miniw/php_cmd?act=set_share_win_bean_data&" .. http_getS1().."&flag=0"
			local long_url_ = url_addParams(temp_url);
			long_url_ = ns_http_sec.encodeS7Url( long_url_ );

			ClientMgr:clickCopy(long_url_)
			--ClientMgr:clickCopy(ClientMgr:getShareLink().."?uin=" .. AccountManager:getUin())
			ShowGameTips(GetS(739), 3);
		else
			standReportEvent("2103", "SHAREBOX_MINIBEAN", "Minibeanshare", "click")  
			SetShareScene("RewardBean")
			--StartShareActivity()
			local para={};
			para.shareType=MapShareType.MiniBeans
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/c_miniwork", "miniui/miniworld/c_minilobby"})
			GetInst("MiniUIManager"):OpenUI("MapAndMiniBeansShare", "miniui/miniworld/share", "MapAndMiniBeansShareAutoGen",para)
		end	
	else
		Log("not isShareEnabled");
		local temp_url = g_http_root .. "miniw/php_cmd?act=set_share_win_bean_data&" .. http_getS1().."&flag=0"
		local long_url_ = url_addParams(temp_url);
		print("before encode:", long_url_)
		long_url_ = ns_http_sec.encodeS7Url( long_url_ );
		print("after encode:", long_url_)

		ClientMgr:clickCopy(long_url_)
		--ClientMgr:clickCopy(ClientMgr:getShareLink().."?uin=" .. AccountManager:getUin())
		ShowGameTips(GetS(739), 3);
	end
end

function GetMiniBeanRewardADBtn_OnClick()	
	if IsAdUseNewLogic(7) then	
		StatisticsADNew('onclick', 7);
	else
		StatisticsAD('onclick', 7);
	end
	
	if WatchADNetworkTips(OnReqWatchADGetMiniBean) then
		OnReqWatchADGetMiniBean();
		standReportEvent("21", "SHAERWINMINIBEAN", "WatchButton1", "ad_play");
	end
end

function GetMiniBeanRewardHelpBtn_OnClick()
	GetInst("UIManager"):Open(
        "CommonHelp",
        {
            textTitle = GetS(71004),
            textContent = GetS(71005, ns_shop_config2.share_cfg.reward.share_first_reward[2])
        }
    )
end

function GetMiniBeanRewardGiftBtn_OnClick(giftIndex)
	local giftInfo = ns_shop_config2.share_cfg.reward.accumulation[giftIndex]
	local rewards = ShareBeanRewards
	if giftInfo then
		local itemIds = ""..giftInfo[2];	

		if rewards and rewards[giftInfo[1]] and rewards[giftInfo[1]] == 1 then  --可领取状态
			-- cctodo 发起领取奖励
			local TotalRewardGetBtn_CallBack = function (ret)
				print("GetMiniBeanRewardGiftBtn_OnClick ret", ret);
				if ret and ret.ret == 0 then

					UpdateGetMiniBeanReward(0, ret.data);
		
					if ret.data and type(ret.data.reward) == 'table' then
						if type(giftInfo[2]) == 'number' and type(giftInfo[3]) == 'number' then	--分享
							SetGameRewardFrameInfo(GetS(3403), {{id=giftInfo[2], num=giftInfo[3]}}, GetS(4891));
						end
					end
				else
					if ret then
						print("分享获得迷你豆提示 error:", ret.ret);
					end
				end
			end

			--埋点领取奖励
			standReportEvent("21", "SHAERWINMINIBEAN", "ActivityButton"..giftIndex, "click", {standby1=itemIds, standby2=1});
			
			local temp_url = g_http_root .. "miniw/php_cmd?act=get_share_win_bean_reward&" .. http_getS1().."&idx="..giftInfo[1]
			ns_http.func.rpc(temp_url, TotalRewardGetBtn_CallBack, nil, nil, true)
		else
			local itemId = giftInfo[2]
			local num = giftInfo[3]
			OpenItemInfoFrameNoUse(itemId, num)

			--埋点查看领取奖励
			standReportEvent("21", "SHAERWINMINIBEAN", "ActivityButton"..giftIndex, "click", {standby1=itemIds, standby2=0});
		end
	else
		ShowGameTipsWithoutFilter("no Gift")
	end
end
------------------------------------------------ActivityFrameActivityReward----------------------------------
function ActivityFrameActivityReward_OnLoad()
	for i=1, ActivityRewardListMaxNum do
		local activityReward = getglobal("ActivityReward"..i);
		activityReward:SetPoint("left", "ActivityRewardBoxPlane", "left", (i-1)*188, 0);
	end

	this:setUpdateTime(0.1);
end


function ActivityFrameActivityReward_OnUpdate()
	--[[
	local leftArrow = getglobal("ActivityFrameActivityRewardLeftArrow");
	local rightArrow = getglobal("ActivityFrameActivityRewardRightArrow");
	local sliding = getglobal("ActivityRewardBox");
	if sliding:getCanMoveLeftDistance() > 0 then
		leftArrow:Show();
	else
		leftArrow:Hide();
	end
	if sliding:getCanMoveRightDistance() > 0 then
		rightArrow:Show();
	else
		rightArrow:Hide();
	end
	--]]
end

function ActivityFrameActivityReward_OnShow()
	getglobal("ActivityFrameActivityRewardTitle"):SetText(GetS(793), 255, 255, 255)
	--getglobal("ActivityFrameTitleTitleFont"):SetText(GetS(795));

	UpdateActivityReward();
end


function UpdateActivityReward()

	--Log( "UpdateActivityReward signInType=" .. signInType );

	local hasNum = 0;
	local activityGiftTime = AccountManager:getAccountData():getActivityGiftTime();
	local activityGift = AccountManager:getAccountData():getActivityGift();
	for i=1, ActivityRewardListMaxNum do
		local signInDef = DefMgr:getSignInDef(3, i);
		local activityReward = getglobal("ActivityReward"..i);
		if signInDef ~= nil then
			hasNum = hasNum + 1;
			activityReward:Show();

			local dayFont 		= getglobal(activityReward:GetName().."Day");
			local name 		= getglobal(activityReward:GetName().."Name");
			local iconBtn 		= getglobal(activityReward:GetName().."IconBtn");
			local icon 		= getglobal(activityReward:GetName().."IconBtnIcon");
			local iconBkg1 		= getglobal(activityReward:GetName().."IconBtnIconBkg1");
			local iconBkg2 		= getglobal(activityReward:GetName().."IconBtnIconBkg2");
			local getBtn 		= getglobal(activityReward:GetName().."GetBtn");
			local getBtnNormal 	= getglobal(activityReward:GetName().."GetBtnNormal");
			local getBtnName 	= getglobal(activityReward:GetName().."GetBtnName");

			local getBtnBkg = getglobal(activityReward:GetName().."Bkg");


			dayFont:SetText(GetS(t_DayStringId[3][i]));
			local itemDef = ItemDefCsv:get(signInDef.RewardID);
			if itemDef ~= nil then
				name:SetText(itemDef.Name.."×"..signInDef.RewardNum);
			end
			SetItemIcon(icon, signInDef.RewardID);
			iconBtn:SetClientUserData(0, signInDef.RewardID);
			getBtn:SetClientUserData(0, signInDef.RewardID);
			getBtn:SetClientUserData(1, signInDef.RewardNum);
			getBtn:SetClientString(signInDef.RewardTips);

			if i < activityGift then	--已领取
				iconBkg1:Hide();
				iconBkg2:Hide();
				getBtn:Disable();

				--getBtnNormal:SetGray(true);
				--getBtnName:SetText(StringDefCsv:get(3029));
				getBtnName:SetTextColor( 118, 96, 64 );
				getBtnName:SetText(StringDefCsv:get(3411));
				getBtnNormal:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
				getBtnNormal:SetTexUV("dljl_ylq01.png");

				--getBtnBkg:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
				---getBtnBkg:SetTexUV("dljl_mrdd_diban01.png");

			else
				if AccountManager:isSameDay(activityGiftTime, AccountManager:getSvrTime()) then --今天的已经领取了
					iconBkg1:Show();
					iconBkg2:Hide();
					getBtn:Disable();
					--getBtnNormal:SetGray(true);
					--getBtnName:SetText(StringDefCsv:get(3153));
					getBtnName:SetText(GetS(3153));
					getBtnName:SetTextColor( 118, 96, 64 );
					getBtnNormal:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
					getBtnNormal:SetTexUV("dljl_ylq01.png");


				else
					if i == activityGift then	--今天的可领取
						iconBkg1:Hide();
						iconBkg2:Show();
						getBtn:Enable();
						getBtnNormal:SetGray(false);
						getBtnName:SetText(GetS(3154));
					else					--之后的尽请期待
						iconBkg1:Show();
						iconBkg2:Hide();
						getBtn:Disable();
						--getBtnNormal:SetGray(true);
						--getBtnName:SetText(StringDefCsv:get(3153));
						getBtnName:SetText(GetS(3153));
						getBtnName:SetTextColor( 118, 96, 64 );
						getBtnNormal:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
						getBtnNormal:SetTexUV("dljl_ylq01.png");
					end
				end
			end
		else
			activityReward:Hide();
		end
	end

	if activityGift >= 4 then
		getglobal("ActivityRewardBoxPlane"):SetPoint("left", "ActivityRewardBox", "left", -534, 0);
		getglobal("ActivityRewardBox"):setCurOffsetX(-534);
	end
end

------------------------------------------------ShareReservation----------------------------------
function ShareReservation_OnLoad()
	local scale = UIFrameMgr:GetScreenScale();
	--local descTitle = getglobal("ActivityFrameShareReservationDescTitle");
	--local descIcon = getglobal("ActivityFrameShareReservationDescIcon");
	--local width = descTitle:GetTextExtentWidth(GetS(865))/scale + 10;
	--descIcon:SetPoint("left", descTitle:GetName(), "left", width, 0);

	local apiId = ClientMgr:getApiId();
	local bindBtnName = getglobal("ActivityFrameShareReservationGotoBindBtnName");

	if apiId == 345 or apiId == 346 then
		--LLDO:海外ios版本, 绑定手机-->绑定邮箱
		bindBtnName:SetText(GetS(3425));
		getglobal('ActivityFrameShareReservationDesc'):SetText(GetS(6332), 98, 65, 48);
	else
		bindBtnName:SetText(GetS(3424));
		getglobal('ActivityFrameShareReservationDesc'):SetText(GetS(866), 98, 65, 48);
	end
end

function ShareReservation_OnShow()
	--getglobal("ActivityFrameTitleTitleFont"):SetText(StringDefCsv:get(867));

	local apiId = ClientMgr:getApiId();
	if  apiId == 45 or apiId == 345 or apiId == 346 or apiId == 999 then
		--可以去绑定
		getglobal("ActivityFrameShareReservationGotoBindBtn"):Show();
	end

	g_invite_ret_code = false;

	if  false then
		local uin = AccountManager:getUin();
		local text = "";
		if uin == 1 then
			text = GetS(760);
		else
			text =  g_http_root .. "oa/appoint.php?uin="..uin;
		end
		getglobal("ActivityFrameShareReservationLink"):SetText(text);


		if  SdkManager:isShareEnabled() then
			getglobal("ActivityFrameShareReservationCopyBtnName"):SetText(GetS(3510));
		end

	end

end

function ShareReservation_OnHide()

end


function ShareReservationBindBtn_OnClick()
	--前去绑定
	ActivityMainCtrl:AntiActive()
	LobbyFrameAccountBtn_OnClick();
	AccountSecuritySettingsBtn_OnClick();
end

--PC 回车
function ShareReservationEdit_OnEnterPressed()
	ShareReservationCopyBtn_OnClick();
end



g_invite_ret_code = false;   --历史服务器回复
function ShareReservationCopyBtn_OnClick()

	Log( "call ShareReservationCopyBtn_OnClick" );
	--检测apiid
	local apiId = ClientMgr:getApiId();
	if  apiId == 45 or apiId == 345 or apiId == 346 or apiId == 999 then
		--可以提交
	else
		ShowGameTips(GetS(6350), 3);     --您不是IOS新手玩家
		return;
	end

	if  g_invite_ret_code then
		cb_invite_ios_user( g_invite_ret_code );
		return;
	end

	--检测数字
	local text = getglobal("ActivityFrameShareReservationEdit"):GetText();
	local op_uin_ = tonumber( text or 0 ) or 0;
	if  op_uin_ < 1000 then
		ShowGameTips(GetS(6351), 3);        --输入的迷你号有误
	else
		local uin_ = AccountManager:getUin();
		if  uin_ == getLongUin(op_uin_) then
			ShowGameTips(GetS(6352), 3);    --你输入的是自己的迷你号，请输入好友的迷你号
			return;
		end

		--二次确认
		--MessageBox(5, "您输入的迷你号是" .. op_uin_ .. "，继续提交？" , function(btn)
		MessageBox(5, GetS(6353, op_uin_) , function(btn)
			if btn == 'left' then
				--rpc
				if  uin_ and uin_ >= 1000  then
					local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=invite_ios_user&op_uin=' .. getLongUin(op_uin_)  .. '&' .. http_getS1();
					Log( reward_list_url_ );
					ns_http.func.rpc_string( reward_list_url_, cb_invite_ios_user, nil, nil, true);
				else
					ShowGameTips(GetS(1073), 3);  --你还没有登录游戏
				end
			end
		end);

	end


	if  false  then
		local text = getglobal("ActivityFrameShareReservationLink"):GetText();
		if text == "" or text == nil then return end

		if SdkManager:isShareEnabled() then
			StartShareUrl(text);
		else
			ClientMgr:clickCopy(text);
			ShowGameTips(GetS(739), 3);
		end
	end
end




function  cb_invite_ios_user( ret )
	Log( "call cb_invite_ios_user" );
	Log( "ret=" .. ret );

	if  ret and #ret > 2 then
		local code_ = tonumber( string.sub( ret, 1, 1 ) ) or -1;
		Log( "code=[" .. code_ .. "]" );

		if  not g_invite_ret_code then
			g_invite_ret_code = ret;  --保存结果cache
		end

		if     code_ == 0 then
			ShowGameTips(GetS(6354), 3);     --请求发送成功，稍后即可领取奖励
			ActivityMainCtrl:RequestWelfareRewardData()
			g_invite_ret_code = "6:has_get";
		elseif code_ == 1 then
			ShowGameTips(GetS(1073), 3);     --你还没有正确登录游戏，请检查网络后重试
		elseif code_ == 2 then
			ShowGameTips(GetS(6355), 3);     --你的帐号已经不是新手玩家啦
		elseif code_ == 3 then
			ShowGameTips(GetS(6356), 3);     --你还没有绑定手机号码或者邮箱呢
		elseif code_ == 4 then
			ShowGameTips(GetS(6352), 3);     --你输入的是自己的迷你号，请输入好友的迷你号
			g_invite_ret_code = false;
		elseif code_ == 5 then
			ShowGameTips(GetS(6358), 3);     --好友的迷你号输入错误
			g_invite_ret_code = false;
		elseif code_ == 6 then
			ShowGameTips(GetS(6357), 3);     --你已经获取该奖励啦
		elseif code_ == 7 then
			ShowGameTips(GetS(6359), 3);     --服务器被外星人抓走了，请稍后重试
		elseif code_ == 8 then
			ShowGameTips(GetS(6360), 3);     --您不是Ios手机玩家
		else
			ShowGameTips(GetS(6359), 3);     --服务器被外星人抓走了，请稍后重试
		end

		return;
	else
		ShowGameTips(GetS(6359), 3);         --服务器被外星人抓走了，请稍后重试
	end

end



------------------------------------植树-----------------------------------
function get_zhishu201803_energy()
	local energy = 0
	if 	ns_ma.reward_list and
	    ns_ma.reward_list.zhishu201803 and
		ns_ma.reward_list.zhishu201803.energy then
		energy = ns_ma.reward_list.zhishu201803.energy
		if  energy > 100 then
			energy = 100
		end
	end
	return energy
end


function get_zhishu201803_txt()
	local txt = ""
	if 	ns_ma.reward_list and
	    ns_ma.reward_list.zhishu201803 and
		ns_ma.reward_list.zhishu201803.txt then
		txt = ns_ma.reward_list.zhishu201803.txt
	end
	return txt
end


function get_zhishu201803_seq()
	local seq_ = 0
	if 	ns_ma.reward_list and
	    ns_ma.reward_list.zhishu201803 and
		ns_ma.reward_list.zhishu201803.seq then
		seq_ = ns_ma.reward_list.zhishu201803.seq
	end
	return seq_
end



function test_set_random_energy()
	if 	ns_ma.reward_list and
	    ns_ma.reward_list.zhishu201803 and
		ns_ma.reward_list.zhishu201803.energy then		
		ns_ma.reward_list.zhishu201803.energy = math.random(0, 200)
	end
end


--是否需要进行提醒植树
--已经设置了祝福语后不提醒，否则每天只提醒一次
function NeedRemindZhishu()	
	--获得提醒天
	local today_      = os.date( "%Y%m%d", os.time() )	
	local record_day_ = getkv("zhishu_redtag") or ""
	Log("NeedRemindZhishu:" .. today_ .. "/" .. record_day_ )	
	if  today_ == record_day_ then
		return false
	else
		return true
	end
end


--设置已经访问了植树活动
function SetHasRemindZhishu()
	local today_      = os.date( "%Y%m%d", os.time() )	
	local record_day_ = getkv("zhishu_redtag") or ""
	Log("SetHasRemindZhishu:" .. today_ .. "/" .. record_day_ )	
	if  today_ == record_day_ then
		--
	else
		setkv("zhishu_redtag", today_)
	end
end




function Zhishu201803Frame_OnShow()
	Log("Zhishu201803Frame_OnShow")
	
	checkS2tAuth();
	SetHasRemindZhishu();
	getglobal("Zhishu201803BtnRedTag"):Hide();

	--random test
	--test_set_random_energy()

	local energy = get_zhishu201803_energy()
	
	getglobal("ActivityFrameZhishu201803ProgressBar"):SetValue(energy/100);
	getglobal("ActivityFrameZhishu201803ProgressBarCursorTex"):SetPoint("left", "ActivityFrameZhishu201803ProgressBar", "left", 2.31*(energy)-22, 0);	
	getglobal("ActivityFrameZhishu201803ProgressBarInfo2"):SetText( energy .. "/100" )


	--是否已经完成
	local txt_ = get_zhishu201803_txt()
	if  #txt_ > 0 then

		getglobal("ActivityFrameZhishu201803Tree"):Hide();
		getglobal("ActivityFrameZhishu201803BigTree"):Show();
		getglobal("ActivityFrameZhishu201803BigTree"):SetUVAnimation(120, true);

		getglobal("ActivityFrameZhishu201803JoinZhishu"):Hide()

		getglobal("ActivityFrameZhishu201803ZhishuViewMap"):Show()
		if  ClientMgr:getApiId()==999 or ( SdkManager:isShareEnabled() and not ClientMgr:isPC() ) then
			getglobal("ActivityFrameZhishu201803ZhishuOutShare"):Show()
			getglobal("ActivityFrameZhishu201803ZhishuViewMap"):SetPoint("center", "ActivityFrameZhishu201803", "center", -120,180);
			getglobal("ActivityFrameZhishu201803ZhishuOutShare"):SetPoint("center", "ActivityFrameZhishu201803", "center", 120,180);
		else
			getglobal("ActivityFrameZhishu201803ZhishuOutShare"):Hide()
			getglobal("ActivityFrameZhishu201803ZhishuViewMap"):SetPoint("center", "ActivityFrameZhishu201803", "center", 0,180);
		end
	else	
		getglobal("ActivityFrameZhishu201803JoinZhishu"):Show()
		getglobal("ActivityFrameZhishu201803ZhishuViewMap"):Hide()
		getglobal("ActivityFrameZhishu201803ZhishuOutShare"):Hide()

		if  energy >= 100 then
			--参与活动
			getglobal("ActivityFrameZhishu201803JoinZhishuName"):SetText( GetS(948) )
			getglobal("ActivityFrameZhishu201803JoinZhishuTxt"):SetText( GetS(936) )
			
			getglobal("ActivityFrameZhishu201803Tree"):Hide();		
			getglobal("ActivityFrameZhishu201803BigTree"):Show();
			getglobal("ActivityFrameZhishu201803BigTree"):SetUVAnimation(120, true);
		else	
			--去完成任务
			getglobal("ActivityFrameZhishu201803JoinZhishuName"):SetText( GetS(938) )
			getglobal("ActivityFrameZhishu201803JoinZhishuTxt"):SetText( GetS(947) )

			getglobal("ActivityFrameZhishu201803BigTree"):Hide();
			getglobal("ActivityFrameZhishu201803Tree"):Show();
			getglobal("ActivityFrameZhishu201803Tree"):SetUVAnimation(120, true);
		end
	end

end


--参加活动
function Zhishu201803_join_OnClick()
	Log("Zhishu201803_join_OnClick")

	local energy = get_zhishu201803_energy()
	if  energy >= 100 then
		--准备输入祝福语言
		local txt_ = get_zhishu201803_txt()
		if  #txt_ > 0 then
			--已经填写
			ShowGameTips( GetS(1024), 3);  --已经填写
		else
			--打开填写页面
			getglobal("ZhishuInputTextFrame"):Show()
			getglobal("ZhishuInputTextFrameContent"):SetText( GetS(1043), 173, 105, 72 )

			--3487 昵称
			--3070 迷你号
			local info_ = GetS(3487) .. ": " .. AccountManager:getNickName() .. "        " .. GetS(3070) .. ": " .. AccountManager:getUin();
			getglobal("ZhishuInputTextFrameNameMiniHao"):SetText( info_ );
		end
	else
		--跳到活动页面
		global_jump_ui(101)
	end
end



--确认提交祝福语
function ZhishuInputTextFrameConfirm_OnClick()
	Log("call ZhishuInputTextFrameConfirm_OnClick")
	local txt_ = get_zhishu201803_txt()
	if  #txt_ > 0 then
		ShowGameTips( GetS(1024), 3);  --已经填写
	else
		--发送填写请求
		WWW_set_zhishu201803txt()
	end
end


--发送填写请求
function WWW_set_zhishu201803txt()

	local uin_ = AccountManager:getUin();
	if  uin_ and uin_ >= 1000  then
		--normal
	else
		--未登录成功
		return
	end

	local nick_ = AccountManager:getNickName();
	local txt_  = getglobal("ZhishuInputTextFrameEdit"):GetText()
	if  #txt_>0 and #nick_>0 then
		--normal
	else
		ShowGameTips( GetS(1032), 3);
		return
	end

	--if  DefMgr:checkFilterString(txt_) then
		--Log("filtre!!!")
	--end

	--植树节活动特殊处理--检查仓库是否已满
	local zhishujieReward = 
	{
		{id=20216, num=1},     --专属头像
		{id=20035, num=100},   --梭梭碎片
		{id=12851, num=1},     --欢乐礼包
		{id=12988, num=1},     --装扮体验卡
	}

	local t_zhifhujieReward={};
	for i=1,#(zhishujieReward) do
		table.insert(t_zhifhujieReward,zhishujieReward[i].id);
	end

	if AccountManager.itemlist_can_add and not AccountManager:itemlist_can_add(t_zhifhujieReward) then
		StashIsFullTips();
		return;
	end
	
	ns_ma.zhishu_txt_record_base64 = ns_http.func.base64_encode(txt_)
	
	local zhishu_txt_url_ = g_http_root .. 'miniw/php_cmd?act=set_user_vars&ext_action=zhishu201803&txt='
										.. ns_ma.zhishu_txt_record_base64
										.. "&nickname=" .. ns_http.func.base64_encode(nick_)
										.. "&" .. http_getS1();
	Log( zhishu_txt_url_ );

	ns_http.func.rpc( zhishu_txt_url_, cb_WWW_set_zhishu201803txt, nil, nil, ns_http.SecurityTypeHigh );   --ma
end




--发送填写请求回调
function cb_WWW_set_zhishu201803txt(ret)
	if  ret.ret == 0 then
		ShowGameTips( GetS(1034), 3);  --成功
	    ns_ma.reward_list.zhishu201803     = ns_ma.reward_list.zhishu201803 or {}
		ns_ma.reward_list.zhishu201803.txt = ns_ma.zhishu_txt_record_base64 or ""
		ns_ma.reward_list.zhishu201803.seq = ret.seq or 0

		-- 刷新界面
		Zhishu201803Frame_OnShow()

		-- 奖励
		if  ret.gift then
			SetGameRewardFrameInfo( GetS(3403), ret.gift, "");
		end
		
	elseif ret.ret == 1 then
		ShowGameTips( GetS(947),  3);  --未完成
	elseif ret.ret == 2 then
		ShowGameTips( GetS(1024), 3);  --已经填写

		-- 刷新界面
		Zhishu201803Frame_OnShow()		
	else
		ShowGameTips( GetS(1033) .. (ret.ret or 'nil') , 3);  --失败
	end

	ZhishuInputTextFrameClose_OnClick()

end


--展示详情
function Zhishu201803_showInfo_OnClick()
	getglobal("CommSlideInfoFrame"):Show()
	getglobal("CommSlideInfoFrameTitle"):SetText( GetS(939) )
	--getglobal("CommSlideInfoFrameContentBoxContent"):SetText( GetS(937), 98, 65, 48 )
	
	--local txt = "#R" .. GetS(1039) .. "#n\n" .. GetS(1040) .. "\n\n#R" .. GetS(1041) .. "#n\n" .. GetS(1042)	
	--getglobal("CommSlideInfoFrameContentBoxContent"):SetText( txt, 98, 65, 48 )


	local function resetPic_( name_ )
		local pic_obj_ = getglobal("CommSlideInfoFrameContentBoxPic")
		if  pic_obj_ then
			Log( "resetPic_=" .. name_ )
			pic_obj_:SetTexture( name_ )
		end
	end

	--按渠道展示图片
	local apiId = ClientMgr:getApiId();
	if  ClientMgr:isPC() then
		if  apiId == 101 or apiId == 116 then			
			--resetPic_( "ui/mobile/texture/bigtex_comm/zhishu_pc_101_p4.png" )
		else
			---resetPic_( "ui/mobile/texture/bigtex_comm/zhishu_pc_p2.png" )
		end
	else
		if  apiId == 47 then
			--resetPic_( "ui/mobile/texture/bigtex_comm/zhishu_m_47_p3.png" )
		end
	end

end


--跳URL
function CommSlideInfoFrameJumpUrl_OnClick()
	g_openBrowserUrlAuth( "http://gongyi.qq.com/succor/detail.htm?id=2437" );
	CommSlideInfoFrameClose_OnClick();
end


--关闭
function CommSlideInfoFrameClose_OnClick()
	getglobal("CommSlideInfoFrame"):Hide()
end

function ZhishuInputTextFrameClose_OnClick()
	getglobal("ZhishuInputTextFrame"):Hide()
end


--参与活动
function Zhishu201803_view_map_OnClick()
	Log("call Zhishu201803_view_map_OnClick")	
	ActivityMainCtrl:AntiActive()
	getglobal("MiniWorksFrame"):Show();
	MiniworksGotoLabel(4);
	JumpToTopicByIndex(2);
end


--分享链接
function Zhishu201803_out_share_OnClick()
	
	--开始进行随机替换 默认sz0到sz9随机
	--http://map1.mini1.cn/zhishu/zs0.png
	local num_ = math.random( 0, 100 ) % 10   -- 0-9
	if num_ == 0 then
		--不替换
		StartShareOnScreenshot("zhishu", 0, 3);
		getglobal("ActivityFrameZhishuShare"):Show();
	else
		--先下载替换
		local file_name_ = g_photo_root .. "zs" .. num_ .. ".png_";	  -- zs5.png_

		local function downloadPng_cb_()
			Log( "call downloadPng_cb_, file=" .. file_name_ );			
			getglobal("ActivityFrameZhishuShare"):Show();
		end
		ns_http.func.downloadPng( "http://map1.mini1.cn/zhishu/zs" .. num_ .. ".png" , file_name_, nil, "ActivityFrameZhishuSharePic", downloadPng_cb_ );   --下载文件		
	end	
	
end


------------------------------------植树分享截图--------------------------
function ActivityFrameZhishuShare_OnShow()
	getglobal("ActivityFrameZhishuShareBtn"):Show();
	getglobal("ActivityFrameZhishuShareCloseBtn"):Show();

	local num = get_zhishu201803_seq();--第几位
	
	if  num > 0 then
		getglobal("ActivityFrameZhishuShareNum"):SetText(GetS(1037, num));
		getglobal("ActivityFrameZhishuShareTitle"):SetText( GetS(1038) );
	else	
		getglobal("ActivityFrameZhishuShareNum"):SetText( "" );
		getglobal("ActivityFrameZhishuShareTitle"):SetText( "" );
	end

	local offsetX = getglobal("ActivityFrameZhishuShareNum"):GetTextExtentWidth(GetS(1037, num))/UIFrameMgr:GetScreenScaleY()+2;
	getglobal("ActivityFrameZhishuShareTitle"):SetPoint("Left", "ActivityFrameZhishuShareNum", "Left", offsetX, 0);
end

function ActivityFrameZhishuShareCloseBtn_OnClick()
	getglobal("ActivityFrameZhishuShare"):Hide();
end


function ActivityFrameZhishuShareBtn_OnClick()
	ns_ma.server_task_events["share"] = 1;
	check_ma_share("zhishu201803");
	getglobal("ActivityFrameZhishuShareBtn"):Hide();
	getglobal("ActivityFrameZhishuShareCloseBtn"):Hide();
	StartShareOnScreenshot("zhishu", 0, 3);
end

------------------------------------好友召回-------------------------------
--PC 回车
function FriendRecallEdit_OnEnterPressed()
	FriendRecallCopyBtn_OnClick();
end


g_friendrecall_ret_code = false;   --历史服务器回复
function FriendRecallCopyBtn_OnClick()

	Log( "call FriendRecallCopyBtn_OnClick" ); 
	if  g_friendrecall_ret_code then
		cb_friend_recall_user( g_friendrecall_ret_code );
		return;
	end

	--检测数字
	local text = getglobal("ActivityFrameFriendRecallEdit"):GetText();
	local op_uin_ = tonumber( text or 0 ) or 0;
	if  op_uin_ < 1000 then
		ShowGameTips(GetS(6351), 3);          --输入的迷你号有误
	else
		local uin_ = AccountManager:getUin();

		if  uin_ == getLongUin(op_uin_) then
			ShowGameTips(GetS(6352), 3);       --你输入的是自己的迷你号，请输入好友的迷你号
			return;
		end

		--二次确认
		--MessageBox(5, "您输入的迷你号是" .. op_uin_ .. "，继续提交？" , function(btn)
		MessageBox(5, GetS(6353, op_uin_) , function(btn)
			if btn == 'left' then
				--rpc
				if  uin_ and uin_ >= 1000  then
					local reward_list_url_ = g_http_root .. 'miniw/php_cmd?act=friend_recall&op_uin=' .. getLongUin(op_uin_)  .. '&' .. http_getS1();
					Log( reward_list_url_ );
					ns_http.func.rpc_string( reward_list_url_, cb_friend_recall_user, nil, nil, true);
				else
					ShowGameTips(GetS(1073), 3);          --你还没有登录游戏
				end
			end
		end);

	end

end


function  cb_friend_recall_user( ret )
	Log( "call cb_friend_recall_user" );
	Log( "ret=" .. ret );

	if  ret and #ret > 2 then
		local code_ = tonumber( string.sub( ret, 1, 1 ) ) or -1;
		Log( "code=[" .. code_ .. "]" );

		if  not g_friendrecall_ret_code then
			g_friendrecall_ret_code = ret;  --保存结果cache
		end

		if     code_ == 0 then
			ShowGameTips(GetS(6354), 3);       --请求发送成功，稍后即可领取奖励
			ActivityMainCtrl:RequestWelfareRewardData()
			g_friendrecall_ret_code = "6:has_get";
		elseif code_ == 1 then
			ShowGameTips(GetS(1073), 3);        --你还没有正确登录游戏，请检查网络后重试
		elseif code_ == 2 then
			ShowGameTips(GetS(6361), 3);        --你输入的迷你号已经被其他玩家召回过一次了
		elseif code_ == 3 then
			ShowGameTips(GetS(6362), 3);        --你输入的迷你号回归时间已经超过24小时
		elseif code_ == 4 then
			ShowGameTips(GetS(6352), 3);        --你输入的是自己的迷你号，请输入好友的迷你号
			g_friendrecall_ret_code = false;
		elseif code_ == 5 then
			ShowGameTips(GetS(6358), 3);        --好友的迷你号输入错误
			g_friendrecall_ret_code = false;
		elseif code_ == 6 then
			ShowGameTips(GetS(6357), 3);        --你已经获取该奖励啦
		elseif code_ == 7 then
			ShowGameTips(GetS(6363), 3);        --你不满足被召回条件
		else
			ShowGameTips(GetS(6359), 3);        --服务器被外星人抓走了，请稍后重试
		end

		return;
	else
		ShowGameTips(GetS(6359), 3);            --服务器被外星人抓走了，请稍后重试
	end

end


------------------------------------------------FriendRecall----------------------------------
function FriendRecall_OnLoad()
	local scale = UIFrameMgr:GetScreenScale();
	--local descTitle = getglobal("ActivityFrameFriendRecallDescTitle");
	--local descIcon = getglobal("ActivityFrameFriendRecallDescIcon");
	--local width = descTitle:GetTextExtentWidth(GetS(941))/scale + 10;
	--descIcon:SetPoint("left", descTitle:GetName(), "left", width, 0);
	getglobal('ActivityFrameFriendRecallDesc'):SetText(GetS(942), 98, 65, 48);
end


function FriendRecall_OnShow()
	--getglobal("ActivityFrameTitleTitleFont"):SetText(StringDefCsv:get(867));
	g_friendrecall_ret_code = false;
end

function FriendRecall_OnHide()

end



---------------------------------------ActivationCode---------------------------
function ActivationCode_OnShow()
	getglobal("ActivityFrameActivationCodeEdit"):Clear();
	SetCurEditBox("ActivityFrameActivationCodeEdit");
end

function ActivityFrameActivationCodeEdit_OnEnterPressed()
	ActivationBtn_OnClick();
end

--激活
function ActivationBtn_OnClick()
	if AccountManager.is_iteminfo_full and AccountManager:is_iteminfo_full() then
		StashIsFullTips();
		return;
	end
	local cdkey = getglobal("ActivityFrameActivationCodeEdit"):GetText();
	if cdkey == "" then
		ShowGameTips(GetS(281), 3);
		return;
	end

	CDKeyEditor:parseQRCode(cdkey);
end

function ActivationCodeStoreGNBtn_OnClick()
	ActivityMainCtrl:AntiActive()
	ShopJumpTabView(1)
end

function ActivationCodeStashBtn_OnClick()
	ActivityMainCtrl:AntiActive()
	ShopJumpTabView(8)
end

---------------------------------------------GameRewardFrame----------------------------------------
local t_RewardItems = {};
local GameRewardFrame = {
	m_funcOnFuncBtnClick = nil,
	m_funcOnGetBtnClick = nil,
	RewardDisplay = nil,
}
function GameRewardFrame_OnLoad()
	this:setUpdateTime(0.05);
    UITemplateBaseFuncMgr:registerFunc("GameRewardFrameCloseBtn", GameRewardFrameGetBtn_OnClick, "登录奖励界面关闭按钮");
end

local GameRewardAngleSpeed = 5;
local GameRewardAngle = 0;
function GameRewardFrame_OnUpdate()
	GameRewardAngle = GameRewardAngle + GameRewardAngleSpeed;
	if GameRewardAngle > 360 then
		GameRewardAngle = GameRewardAngle - 360;
	end
	getglobal("GameRewardFrameEffect"):SetAngle(GameRewardAngle);
end

local PropsType = nil;
function SetGameRewardPropsType(type) --0 普通道具 1 解锁型道具
	PropsType = type;
end

local MafBtnExtend = {}
function GameRewardFrameSetMafBtnExtend(extend)
	MafBtnExtend = extend
end

function GameRewardFrameGetMafBtnExtend()
	return MafBtnExtend
end

local MafBtnExtend2 = {}
function GameRewardFrameSetMafBtnExtend2(extend)
	MafBtnExtend2 = extend
end

function GameRewardFrameGetMafBtnExtend2()
	return MafBtnExtend2
end

function GameRewardFrameSetMafBtnExtendTaskId(task_id)
	if MafBtnExtend == nil then MafBtnExtend = {} end
	MafBtnExtend.task_id = task_id
end
function GameRewardFrameSetMafBtnExtendADTaskId(ADTaskId)
	if MafBtnExtend == nil then MafBtnExtend = {} end
	MafBtnExtend.ADTaskId = ADTaskId
end

--[[
	道具领取小框
	add param by : sundy
	reason: 需要指定使用海外版的展示方式
]]
GameRewardShowInfoList = {}
function SetGameRewardFrameInfo(titleText, t_Items, itemDesc, funcOnGetBtnClick, funcBtnInfo, bUseOverSeasTemp)
	--local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
	print("SetGameRewardFrameInfo", titleText, t_Items, itemDesc, funcOnGetBtnClick, funcBtnInfo, bUseOverSeasTemp)
	bUseOverSeasTemp = bUseOverSeasTemp or false

	if ClientMgr:getIsOverseasVer() then
		-- print('sundy----->>>111');
		if #(t_Items) > 0 then
			ShowMoreRewardExhibition(g_OverseaCusEnum.RewardExhibitionFrom.GAME_REWARD, t_Items, titleText)
		end
	elseif bUseOverSeasTemp then
		-- print('sundy----->>>222');
		getglobal("GameAllRewardFrameTitleName"):SetText(titleText);
		-- getglobal("GameAllRewardFrameItemDesc"):SetText(itemDesc);
		ShowGameAllRewardFrame(t_Items)
	else
		-- 如果当前弹框之前还有未完成的其他弹框，则对当前弹框内容做缓存，待其他弹框全部显示之后再继续显示当前弹框
		if getglobal("GameRewardFrame"):IsShown() or (t_RewardItems and next(t_RewardItems)) then
			table.insert(GameRewardShowInfoList, {
				titleText = titleText, 
				t_Items = copy_table(t_Items), 
				itemDesc = itemDesc, 
				funcOnGetBtnClick = funcOnGetBtnClick, 
				funcBtnInfo = copy_table(funcBtnInfo), 
				bUseOverSeasTemp = bUseOverSeasTemp
			})
			return
		end

		if GetInst("SkinCollectManager"):isOpen() then
			if #(t_Items) > 0 then
				local param = {}
				for i = #(t_Items), 1, -1 do
					local itemDef = DefMgr:getItemDef(t_Items[i].id)
					if itemDef and itemDef.ShowType == 4 then --皮肤碎片
						table.insert(param,{id=t_Items[i].id, num = t_Items[i].num})
						table.remove(t_Items,i)
					end
				end

				if #param > 0 then
					GetInst("SkinCollectManager"):OpenSkinFragmentPopup(param)
				end
	
				if #(t_Items) <= 0 then
					return
				end
			end
		end

		-- print('sundy----->>>333');
		t_RewardItems = t_Items;
		getglobal("GameRewardFrameTitleName"):SetText(titleText);
		getglobal("GameRewardFrameItemDesc"):SetText(itemDesc);

		print("SetGameRewardFrameInfo t_RewardItems",t_RewardItems)
		print("SetGameRewardFrameInfo t_RewardItems",#(t_RewardItems))
		if #(t_RewardItems) > 0 then
			UpdateRewardFrame();
		end

		GameRewardFrame.m_funcOnGetBtnClick = funcOnGetBtnClick;	

		-- 增加辅助按钮
		if funcBtnInfo and funcBtnInfo[1] then
			getglobal("GameRewardFrameFuncBtn"):Show()
			getglobal("GameRewardFrameFuncBtnText"):SetText(funcBtnInfo[1])
			getglobal("GameRewardFrameGetBtn"):SetPoint("bottom", "GameRewardFrameBkg2", "bottom", -106, -25)
			GameRewardFrame.m_funcOnFuncBtnClick = funcBtnInfo[2]
		else
			GameRewardFrame.m_funcOnFuncBtnClick = nil
		end
	end
end

function UpdateRewardFrame()
	if t_RewardItems[1] then
		-- local print = Android:Localize(Android.SITUATION.CHANNEL_REWARD);
		local icon = getglobal("GameRewardFrameIcon");
		local iconName = getglobal("GameRewardFrameIconName");
		local getBtn = getglobal("GameRewardFrameGetBtn");
		if t_RewardItems[1].giftType == 1 then 
			--地图内道具
			DownloadPicAndSet(icon,t_RewardItems[1].iconUrl)
		else
			SetItemIcon(icon, t_RewardItems[1].id);
		end 
		UpdateActivityRewardListByItemid(t_RewardItems[1].id)
		local itemDef = ItemDefCsv:get(t_RewardItems[1].id);
		
		if t_RewardItems[1].giftType == 1 then 
			--地图内道具
			local c = t_RewardItems[1].color or "#c3D4546"
			iconName:SetText(c..t_RewardItems[1].name.."#n".."×"..t_RewardItems[1].num)
		else
			if itemDef then
				local _, _, modelID = string.find(itemDef.Icon,"%p%a+%d+_(%d+)");
				print("UpdateRewardFrame1", itemDef.Type, itemDef.Icon, modelID)
				if itemDef.Type and tonumber(itemDef.Type) and tonumber(itemDef.Type) == 6 and modelID then
					print("UpdateRewardFrame2")
					threadpool:work(function()
						GetInst("ShopDataManager"):UpdateSkinPartOwnedFlag(tonumber(modelID))
					end)
				end
				print("UpdateRewardFrame3")
				if not t_RewardItems or not t_RewardItems[1] then
					print("error item data -----")
					return
				end
				local c = t_RewardItems[1].color or "#c3D4546"
				if t_RewardItems[1].num ~= nil then
					iconName:SetText(c..itemDef.Name.."#n".."×"..t_RewardItems[1].num);
				elseif t_RewardItems[1].count ~= nil then
					iconName:SetText(c..itemDef.Name.."#n".."×"..t_RewardItems[1].count);
				else
					iconName:SetText(c..itemDef.Name);
				end
			end
		end 
		
		if t_RewardItems[1].title ~= nil then
			getglobal("GameRewardFrameTitleName"):SetText(t_RewardItems[1].title);
		end
		if not getglobal("GameRewardFrame"):IsShown() then
			getglobal("GameRewardFrame"):Show();
		end

		getglobal("GameRewardFrameGetBtnEffect1"):SetUVAnimation(100, false);
		ClientMgr:playSound2D("sounds/ui/info/book_seriesunlock.ogg", 1);

		if t_RewardItems[1].id == 10046 then --积分道具自动转为积分
			GetInst("IntegralMallManager"):ExchangeItemToIntegralInfo(t_RewardItems[1].num or t_RewardItems[1].count or 1)
		end
		
		table.remove(t_RewardItems, 1);
	end
end

local isCheckAdFinish = false
function GameRewardFrame_OnShow()
	Log("GameRewardFrame_OnShow_start")
	isCheckAdFinish = false
	threadpool:work(function()
		while true do
			if not getglobal("GameRewardFrame"):IsShown() then
				return
			end
			GameRewardFrameCheckAdShow()
			threadpool:wait(0.5)
		end
	end)
end

function GameRewardFrameCheckAdShow()
	if isCheckAdFinish == true then return end
	if MafBtnExtend and MafBtnExtend.task_id then
		local task_id = MafBtnExtend.task_id
		print("GameRewardFrame_OnShow taskId " .. task_id)

		-- codeby : fym 9/26/27号广告位
		local position_id = 0
		if task_id == "showad9" then
			position_id = 9   -- 9广告位：公告-福利-广告商的赞助 
		elseif task_id == "showad26" and isAbroadEvn() then
			position_id = 26  -- 26广告位：公告-精选公告-点击播放广告
		elseif task_id == "showad27" then
			position_id = 27  -- 27广告位：公告-福利-广告商的赞助-2
		end

		if IsAdUseNewLogic(position_id) then
			getglobal("GameRewardFrameAgainBtn"):Hide()
			getglobal("GameRewardFrameCount"):SetText("")
			getglobal("GameRewardFrameGetBtn"):SetPoint("bottom", "GameRewardFrameBkg2", "bottom", 0, -25)

			if position_id > 0 then
				print("GameRewardFrame_OnShow position_id "..position_id)
				local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id);
				if curWatchADType then
					local callback = function(result, ad_info)
						if result and ad_info and ad_info.finish and ad_info.finish.count ~= ad_info.num_total and ad_info.num_total ~= 0 then	
							print(ad_info)
							GameRewardFrameSetMafBtnExtend2(MafBtnExtend)

							getglobal("GameRewardFrameCount"):SetText(GetS(30112,ad_info.finish.count,ad_info.num_total))
							getglobal("GameRewardFrameAgainBtn"):Show()
							getglobal("GameRewardFrameGetBtn"):SetPoint("bottom", "GameRewardFrameBkg2", "bottom", -106, -25)

							if isCheckAdFinish == false then
								StatisticsADNew('againshow', position_id, ad_info)
							end
							isCheckAdFinish = true
						end
					end
					GetInst("AdService"):IsAdCanShow(position_id, callback)
				end
			end	
		else
			local ADTaskId = MafBtnExtend.ADTaskId
			local ad_info = nil
			local curWatchADType27, id27 = t_ad_data.getWatchADIDAndType(27)
			local curWatchADType9, id9 = t_ad_data.getWatchADIDAndType(9)
			print("GameRewardFrame_OnShow_start__taskId=" .. task_id)
			if task_id == "showad27" and t_ad_data.canShow(27) and curWatchADType27 then
				ad_info = AccountManager:ad_position_info(27)
				print("GameRewardFrame_OnShow_task_id ========= 27")
			elseif task_id == "showad9" and t_ad_data.canShow(9) and curWatchADType9 then
				ad_info = AccountManager:ad_position_info(9)
				print("GameRewardFrame_OnShow_task_id ========= 9")
			elseif task_id == "showad26" and isAbroadEvn() and t_ad_data.canShow(26) then
				ad_info = AccountManager:ad_position_info(26)
				print("GameRewardFrame_OnShow_task_id ========= 26")
			end
			print("GameRewardFrame_OnShow_adinfo ========= ",ad_info)
			if ad_info and ad_info.finish.count ~= ad_info.num_total and ad_info.num_total ~= 0 then
				
				print("GameRewardFrame_OnShow_finish.count ========= " ..  ad_info.finish.count .. "num_total====" .. ad_info.num_total)
				GameRewardFrameSetMafBtnExtend2(MafBtnExtend)
				
				getglobal("GameRewardFrameCount"):SetText(GetS(30112,ad_info.finish.count,ad_info.num_total))
				getglobal("GameRewardFrameAgainBtn"):Show()
				getglobal("GameRewardFrameGetBtn"):SetPoint("bottom","GameRewardFrameBkg2","bottom",-106,-25)
				
				if isCheckAdFinish == false then
					if task_id == "showad27" then
						StatisticsAD('againshow', 27);
					elseif task_id == "showad9" then
						StatisticsAD('againshow', 9);
					elseif task_id == "showad26" then
						StatisticsAD('againshow', 26);
					end
				end
				isCheckAdFinish = true
			else
				getglobal("GameRewardFrameAgainBtn"):Hide()
				getglobal("GameRewardFrameCount"):SetText("")
				getglobal("GameRewardFrameGetBtn"):SetPoint("bottom","GameRewardFrameBkg2","bottom",0,-25)
			end
		end

	elseif GameRewardFrame.m_funcOnFuncBtnClick then

	else
		getglobal("GameRewardFrameFuncBtn"):Hide()
		getglobal("GameRewardFrameAgainBtn"):Hide()
		getglobal("GameRewardFrameCount"):SetText("")
		getglobal("GameRewardFrameGetBtn"):SetPoint("bottom","GameRewardFrameBkg2","bottom",0,-25)
	end
end

function GameRewardFrame_OnHide()
	print("GameRewardFrame_OnHide")
	GameRewardFrameSetMafBtnExtend(nil)
	GameRewardFrameSetMafBtnExtend2(nil)
	getglobal("GameRewardFrameFuncBtn"):Hide()
	getglobal("GameRewardFrameAgainBtn"):Hide()
	getglobal("GameRewardFrameCount"):SetText("")
	getglobal("GameRewardFrameGetBtn"):SetPoint("bottom","GameRewardFrameBkg2","bottom",0,-25)

	-- 在弹框关闭的时候检测是否有其他弹框待显示
	threadpool:work(function()
		if GameRewardShowInfoList and next(GameRewardShowInfoList) and not getglobal("GameRewardFrame"):IsShown() then
			local info = GameRewardShowInfoList[1]
			if info.titleText and info.t_Items and next(info.t_Items) then
				SetGameRewardFrameInfo(info.titleText, info.t_Items, info.itemDesc, info.funcOnGetBtnClick, info.funcBtnInfo, info.bUseOverSeasTemp);
			end
			table.remove(GameRewardShowInfoList, 1)
		end
	end)
end

function ShowGameRewardFrame(RewardDisplay)
	getglobal("GameRewardFrame"):Show();
	GameRewardFrame.RewardDisplay = RewardDisplay;
end

function GameRewardFrameGetBtn_OnClick()
	if #(t_RewardItems) > 0 then
		UpdateRewardFrame();
	else
		--植物升级得到的奖励
		if IsChestTreeLevelUp then
			IsChestTreeLevelUp = false;
		end
		getglobal("GameRewardFrame"):Hide();
		--一键领取邮件
		if mailservice.isOneKeyTakeMail then
			MailFrameMailOneKeyTakeContinue()
		end 
		
		if GameRewardFrame.m_funcOnGetBtnClick then
			GameRewardFrame.m_funcOnGetBtnClick();
		end
	end

	if getglobal("HomeChestFrame"):IsShown() and  PropsType~=nil then
		if PropsType == 0	then
			HomeChestFrameStashBtn_OnClick();
		else
			getglobal("PokedexFrame"):Show();
		end
		PropsType = nil;
	end

	local RewardDisplay = GameRewardFrame.RewardDisplay
	if RewardDisplay then
		if RewardDisplay:empty() then
			GameRewardFrame.RewardDisplay = nil;
		end
		RewardDisplay:onConfirm();
	end
end

-- 通用领取奖励弹框增加辅助功能按钮(在可直接关闭弹框不需要其他操作的情况下使用)
function GameRewardFrameFuncBtn_OnClick()	
	if GameRewardFrame.m_funcOnFuncBtnClick then
		GameRewardFrame.m_funcOnFuncBtnClick();
	end
	getglobal("GameRewardFrame"):Hide()
end

-- 再次播放广告
function GameRewardFrameAgainBtn_OnClick()
	print("GameRewardFrameAgainBtn_OnClick")
	if MafBtnExtend2 == nil or MafBtnExtend2.task_id == nil then return end
	local table = MafBtnExtend2
	local task_id = MafBtnExtend2.task_id
	getglobal("GameRewardFrame"):Hide()

	print("GameRewardFrameAgainBtn_OnClick_tabletask_id ========= " ..  task_id)
	if task_id == "showad9" then
		
		print("GameRewardFrameAgainBtn_OnClick_task_id ========= 27")
		MAFBtnGet_OnClick(nil,table)
	elseif task_id == "showad27" then
		print("GameRewardFrameAgainBtn_OnClick_task_id ========= 9")
		MAFBtnGet_OnClick(nil,table)
	elseif task_id == "showad26" and isAbroadEvn() then
		GetInst("UIManager"):GetCtrl("ShopAdvert"):PlayAdBtnClicked(true)
		print("GameRewardFrameAgainBtn_OnClick_task_id ========= 26")
	end	
end


--回调
function cb_getZhishu201803OthersList( ret )
	Log( "call cb_getZhishu201803OthersList, size=" .. #ret )
	local userlist_ = {};

	--如果自己已经完成，加在第一位
	if 	ns_ma.reward_list and
	    ns_ma.reward_list.zhishu201803 and
		ns_ma.reward_list.zhishu201803.txt then		

		local user_ = {};
		user_.seq      = ns_ma.reward_list.zhishu201803.seq
		user_.uin      = AccountManager:getUin()
		user_.nickname = AccountManager:getNickName()
		user_.txt      = ns_http.func.base64_decode(ns_ma.reward_list.zhishu201803.txt)

		--敏感词
		user_.nickname = ReplaceFilterString(user_.nickname)
		user_.txt      = ReplaceFilterString(user_.txt)

		userlist_[ #userlist_ + 1 ] = user_;
	end


	for i=1, #ret do
		Log( i .. " " .. ret[i] )
		local t_ = split( ret[i], "|" )		
		local user_ = {};
		user_.seq = t_[2]
		user_.uin = t_[3]
		user_.nickname =  ns_http.func.base64_decode( t_[4] )
		user_.txt      =  ns_http.func.base64_decode( t_[5] )

		--敏感词
		user_.nickname = ReplaceFilterString(user_.nickname)
		user_.txt      = ReplaceFilterString(user_.txt)

		userlist_[ #userlist_ + 1 ] = user_;
	end
	

	
	
	InitPlantTree(userlist_)
end	

--获得植树节其他玩家列表
function  WWW_getZhishu201803OthersList( num_ )
	local uin_ = AccountManager:getUin();
		if  uin_ and uin_ >= 1000  then
		local http_req_url = g_http_root.."miniw/php_cmd?act=get_zhishulist&read=" .. num_ .. "&" .. http_getS1()	
		--回调
		ns_http.func.rpc( http_req_url, cb_getZhishu201803OthersList, nil, nil, ns_http.SecurityTypeHigh );  --发送http请求
	end
end



-----------------------------------------TreasuryFrame------------------------------------------
local exchangeItemNum=60;
local goodsItemNum = 5;
local exchangeItemIndex = 0;
local TS_giftList={};
--_G.ItemUseSkinDef = loadwwwcache('res.ItemUseSkinDef');  第一次登录的新号调用太早了，热更文件还没下载下来，注释掉
local gExchangeInfo = {}

function TreasuryFrame_OnShow() --迷你宝库界面显示
	getglobal("ExchangeRecordPanel"):Hide()
	TreasuryFrame_dataSort(); ----排序
	if isTreasuryCanExchange(MiniBaoKuID) then
		getglobal("MiniTreasury"..MiniBaoKuID.."BtnRedTag"):Show();
	else
		getglobal("MiniTreasury"..MiniBaoKuID.."BtnRedTag"):Hide();
	end

	UpdateTreasureTitle();
	getglobal("ActivityFrameTreasuryExchangeList"):initData(680,353,2,4)
	
	--TreasuryFrame_Layout();
end

function TFBtnTemplate_OnMouseEnter_PC()
	TreasuryFrame_GoodsItemOnClick();
end

function TFBtnTemplate_OnMouseLeave_PC()
	HideMTipsInfo();
end

function TreasuryFrame_GoodsItemOnClick() --物品按钮点击提示界面显示
	if #TS_giftList <= 0 then return end
	local id = this:GetParentFrame():GetClientUserData(0) --先判断是不是道具
	if id == 0 then  --判断是不是兑换记录道具
		id = this:GetClientID()
	end
	local itemId = 11015
	local baoku = ns_ma.baoku[MiniBaoKuID]
	if id == 0 then --货币
		itemId = baoku.coin
	elseif id > 100000 then
		local t_score = ns_ma.baoku[MiniBaoKuID].user_data.trade_score or {};
		local recordlist = t_score.record
		if not recordlist then return end
		recorddata = recordlist[id-100000]
		if not recorddata then return end
		if type(recorddata) == "string" then
			recorddata = decodeRecordData(recorddata)
		end
		itemId = tonumber(recorddata.id)
	elseif #TS_giftList >= id then
		itemId= TS_giftList[id].itemId
	end

	SetMTipsInfo(-1, this:GetName(), true, itemId)
end

function ExchangeBtn_OnClick() --兑换按钮点击方法
	exchangeItemIndex = this:GetParentFrame():GetClientUserData(0)
	local id = MiniBaoKuID
	if #TS_giftList < exchangeItemIndex then return end

	local listitemdata = TS_giftList[exchangeItemIndex]
	if not listitemdata.itemId or not gExchangeInfo.useitemid then return end

	local t_score = ns_ma.baoku[id].user_data.trade_score or {}
	local leftnum, idx = 0, ns_ma.baoku[id].id
	local ownscore = t_score[gExchangeInfo.useitemid]["score"] or 0
	local costnum = listitemdata.price or 1
	if t_score[idx].limit == nil or t_score[idx].limit[exchangeItemIndex] == nil then
		leftnum = listitemdata.limit
	else
		leftnum = listitemdata.limit - t_score[idx].limit[listitemdata.goodId]
	end

	gExchangeInfo.maxexchangenum = math.min(leftnum, math.floor(ownscore/costnum))
	-- if gExchangeInfo.maxexchangenum <= 0 then return end

	setExchangeInfo(costnum, listitemdata.itemId, listitemdata.num, 1)
	if listitemdata.limit == 1 then
		getglobal("ExchangeConfirmFrame"):Show()
	else
		getglobal("SelectCountFrame"):Show()
	end
end

-------迷你宝库逻辑---------------------------------------
function setExchangeInfo(costnum, giftitemid, giftitemnum, selectnum)
	if costnum then
		gExchangeInfo.costnum = costnum
	end

	if giftitemid then
		gExchangeInfo.giftitemid = giftitemid
	end

	if giftitemnum then
		gExchangeInfo.giftitemnum = giftitemnum
	end

	if selectnum then
		gExchangeInfo.selectnum = selectnum
	end
end

function isTreasuryCanExchange(id)
	if not ns_ma.baoku then return end
	--没有就不判断了，这个会影响红点
	if getglobal("MiniTreasury"..id):IsShown() == false then
		return false;
	end
	
	if not ns_ma.baoku[id] then return end

	local baoku = ns_ma.baoku[id]
	local giftIndex = baoku.id;
	local coin = baoku.coin
	if  giftIndex == "" then
		return;
	end
	--为了防止切换账号后，第一时间没有拉取到配置
    if baoku.user_data == nil then
        baoku["user_data"]={};
    end

	if baoku.user_data[giftIndex]==nil then
        baoku.user_data[giftIndex] ={
            --score=0;
            --limit={};
        };
	end

	local t_score = baoku.user_data.trade_score or {};
	local treasuryData = baoku.goods;

	if t_score[giftIndex] == nil then
		t_score[giftIndex] = {}
	end

	if t_score[coin] == nil then
		t_score[coin] = {}
		t_score[coin].score = 0
	end

	if t_score  then
		for k,v in pairs(treasuryData) do  
			if t_score[giftIndex].limit ==nil  then
                t_score[giftIndex].limit ={};
                t_score[giftIndex].limit[k]=0;
			end
			
			if t_score[giftIndex].limit[k] == nil then
                t_score[giftIndex].limit[k]=0;
			end

			if v.num <= t_score[coin].score and v.limit> t_score[giftIndex].limit[k] then
				return true;
			end
		end
	end

	return false;
end

function TreasuryFrame_dataSort()
	if not ns_ma.baoku or not ns_ma.baoku[MiniBaoKuID] then return end
	--这个btn没有显示，说明没有活动
	if getglobal("MiniTreasury"..MiniBaoKuID.."Btn"):IsShown() == false then
		return;
	end
	local baoku = ns_ma.baoku[MiniBaoKuID]
	local giftIndex, useitemid = baoku.id, baoku.coin

	if giftIndex == "" then return end
    if not baoku.user_data then baoku["user_data"] = {} end

    local t_score = baoku.user_data.trade_score or {};
	local treasuryData = baoku.goods;
	local index, sortList = 1, {}
	if not treasuryData then return end
	if not t_score[giftIndex] then t_score[giftIndex] = {} end

	local ownscore = t_score[useitemid] and t_score[useitemid].score or 0
	local idx1, idx2, idx3, idx4, idx5 = 1, 1, 1, 1, 1
	for k,v in pairs(treasuryData) do
		if t_score[giftIndex].limit == nil then
            t_score[giftIndex].limit = {}
            t_score[giftIndex].limit[k] = 0
        elseif t_score[giftIndex].limit[k] == nil then
        	t_score[giftIndex].limit[k] = 0
		end
		--存储一下物品ID
		if not v.goodId then 
			v.goodId = k
		end
		-- 加精能兑换>加精不能兑换>普通能兑换>普通不能兑换>兑换完毕（次数用光）
		if v.limit > t_score[giftIndex].limit[k] then
			if v.focus == 1 then
				if v.price > ownscore then
					table.insert(sortList, idx2, v)
				else
					table.insert(sortList, idx1, v)
					idx1 = idx1 + 1
				end
				idx2 = idx2 + 1
				idx3 = idx3 + 1
			else
				if v.price > ownscore then
					table.insert(sortList, idx4, v)
				else
					table.insert(sortList, idx3, v)
					idx3 = idx3 + 1
				end
			end

			idx4 = idx4 + 1
			idx5 = idx5 + 1
		else
			if v.focus == 1 then
				table.insert(sortList, idx5, v)
				idx5 = idx5 + 1
			else
				table.insert(sortList, v)
			end
		end	
	end

	TS_giftList = sortList
	print("mini==",TS_giftList,t_score)
end

function ActivityFrameTreasuryExchangeList_tableCellAtIndex(tableView,index)
	local cell, uiidx = tableView:dequeueCell(0)
	local idx = index + 1

	if not cell then
		local cell_name = "TreasuryExchangeItem" .. uiidx

		cell = UIFrameMgr:CreateFrameByTemplate("Frame", cell_name, "TreasureItemTemplate",tableView:GetName())
	else
		cell:Show()
	end
	cell:SetClientUserData(0,idx)
	TreasuryFrame_ShowDetail(cell, idx)  ---控件数据

	return cell
end

function ActivityFrameTreasuryExchangeList_numberOfCellsInTableView(tableView)
	local num = #TS_giftList
	if num > exchangeItemNum then
		num = exchangeItemNum
	end
	return num
end

function ActivityFrameTreasuryExchangeList_tableCellSizeForIndex(tableView,index)
	local colidx = math.mod(index, 4)
	local colidy = index%4
	return (20+155)*colidx,10,155,214
end

function ActivityFrameTreasuryExchangeList_tableCellWillRecycle(tableView,cell)
	if cell then cell:Hide() end 
end

function UpdateTreasureTitle()
	if not ns_ma.baoku then return end

	local titleitem = getglobal("TreasureTitleItem")
	titleitem:Show()
	titleitem:SetPoint("top", "ActivityFrameTreasury", "top", 2, 0)
	local ui_frame;
	local baoku = ns_ma.baoku[MiniBaoKuID]
	local giftIndex, useitemid = baoku.id, baoku.coin
	if  giftIndex == "" or not useitemid then
		return;
	end

	gExchangeInfo.useitemid = useitemid
    local t_score = baoku.user_data.trade_score or {};

	local useiteminfo = t_score[useitemid]
	if useiteminfo then
		ui_frame = getglobal("TreasureTitleItemUseItemIcon")
		SetItemIcon(ui_frame, useitemid)

		ui_frame = getglobal("TreasureTitleItemUseItem")
		ui_frame:SetClientID(0);

		ui_frame = getglobal("TreasureTitleItemOwn");
		ui_frame:SetText(useiteminfo["score"] or 0)
	end

	ui_frame = getglobal("TreasureTitleItemActiveTime");
	ui_frame:SetText(baoku.txt1);

	ui_frame = getglobal("TreasureTitleItemIntroduceTitle");
	ui_frame:SetText(baoku.txt2);

	ui_frame = getglobal("TreasureTitleItemLink");
	if baoku.url then
		ui_frame:SetText("#L#cFA7A0F" .. GetS(4879))
		ui_frame:Show()
	else
		ui_frame:Hide()
	end
end

function TreasuryFrame_ShowDetail(cell, idx) --迷你宝库显示内容
	local baoku = ns_ma.baoku[MiniBaoKuID]
	local giftIndex, useitemid = baoku.id, baoku.coin
	if  giftIndex == "" or not useitemid then
		return;
	end

	gExchangeInfo.useitemid = useitemid
    local t_score = baoku.user_data.trade_score or {};

	local treasuryData = baoku.goods;

    if baoku.user_data == nil then
        baoku["user_data"]={};
    end

	if baoku.user_data[giftIndex]==nil then
        baoku.user_data[giftIndex] ={
            score=0;
            limit={};
        };
	end

	local goodsLItemName="ExchangeBtn";
	local goodsRItemName="GoodsItem";

	local colorred="#cFF0000";
	local colorgreen="#c008000";
	local colorend="#n";
	local num, leftnum = "", 0
	local seq, focus, exchangebtn = 1, 0, nil
	local ownscore = t_score[useitemid]["score"] or 0

	seq = TS_giftList[idx].goodId
	focus = TS_giftList[idx].focus

	local bkg = getglobal(cell:GetName().."Bkg")
	if focus == 1 then
		bkg:SetTexUV("board_activity_box_blue")
		colorgreen = "#cF3F3F2"
	else
		bkg:SetTexUV("board_activity_box_white")
		colorgreen = "#c008000"
	end

	local btnIcon=getglobal(cell:GetName()..goodsLItemName.."Icon")
	SetItemIcon(btnIcon,useitemid);

	local text=getglobal(cell:GetName()..goodsLItemName.."Text")
	text:SetText(TS_giftList[idx].price);

	local goodsItem=getglobal(cell:GetName()..goodsRItemName); 
	goodsItem:SetClientID(idx);

	local goodsIcon = getglobal(cell:GetName()..goodsRItemName.."Icon")
	SetItemIcon(goodsIcon, TS_giftList[idx].itemId)

	local goodsNum = getglobal(cell:GetName()..goodsRItemName.."Num")
	goodsNum:SetText(TS_giftList[idx].num)

	local btnNum=getglobal(cell:GetName().."Leftnum");
	if t_score[giftIndex].limit==nil or  t_score[giftIndex].limit[seq]==nil then
		leftnum = TS_giftList[idx].limit
		num = leftnum.."/".. leftnum;
	else
		leftnum =TS_giftList[idx].limit - t_score[giftIndex].limit[seq]
		if leftnum <= 0 then
			leftnum = 0 
			restNum = colorred..leftnum..colorend;
		else 
			restNum= colorgreen..leftnum..colorend;
		end
		num = restNum.."/".. TS_giftList[idx].limit;
	end

	btnNum:SetText(num, 67, 80, 82);

	local btn = getglobal(cell:GetName().."ExchangeBtn")
	if leftnum == 0 or ownscore < TS_giftList[idx].price then
		btn:Disable()
		getglobal(cell:GetName().."ExchangeBtnNormal"):SetGray(true)
		getglobal(cell:GetName().."ExchangeBtnIcon"):SetGray(true)
	else
		btn:Enable()
		getglobal(cell:GetName().."ExchangeBtnNormal"):SetGray(false)
		getglobal(cell:GetName().."ExchangeBtnIcon"):SetGray(false)
	end
end

function TreasuryItemExchange() --兑换按钮点击
	local url; --合成接口
	local baoku = ns_ma.baoku[MiniBaoKuID]
	local giftIndex = baoku.id;
	local coin = baoku.coin
	if  giftIndex == "" or exchangeItemIndex == 0 then
		return;
	end
	local treasuryData = baoku[giftIndex];
	local userdata = baoku.user_data[giftIndex];
    local t_score = baoku.user_data.trade_score or {};

	if t_score[giftIndex] == nil and t_score[giftIndex].limit[seq]==nil then return end
	if TS_giftList[exchangeItemIndex] == nil then return end
	if exchangeItemIndex == 0 then return end
	local seq = TS_giftList[exchangeItemIndex].goodId;
	--判断满足条件
	if t_score[giftIndex].limit==nil or t_score[giftIndex].limit[seq]==nil or t_score[giftIndex].limit[seq]<TS_giftList[exchangeItemIndex].limit  then
		if TS_giftList[exchangeItemIndex].price<=t_score[coin].score then
			local refresh = baoku.refresh or {};
			local itemId = TS_giftList[exchangeItemIndex].itemId
			if ItemUseSkinDef[itemId] then
				local modelID = ItemUseSkinDef[itemId].ModelID;
				table.insert(refresh, modelID);
			end
			if not baoku.refresh then
				baoku.refresh  = refresh;
			end
			local goodID = TS_giftList[exchangeItemIndex].goodId
			local selectnum = gExchangeInfo.selectnum or 1
			url= g_http_root.."miniw/mission?act=baoku_purchase&id="..giftIndex.."&subId="..goodID.."&num="..selectnum.."&"..http_getS1(true);
			print("sssssssss",url)
			ns_http.func.rpc(url, ExchangeItem_Cb, nil, nil, true);
		end
	end
end

function ExchangeItem_Cb(ret)
	print("ExchangeItem_Cb",ret)
	if not ret then return end
	if ret.ret==0 then
		if ret.msg then
			--刷新宝库数据
			local data = ret.msg
			local baoku = {}
			for i = 1,#ns_ma.baoku do
				if data.baokuId and data.baokuId == ns_ma.baoku[i].id then
					baoku = ns_ma.baoku[i]
					break;
				end
			end
			local giftIndex = baoku.id
			local coin = baoku.coin
			local trade = baoku.user_data.trade_score
	        if data.coin then
	        	trade[coin].score = data.coin
	        end

	        if data.count then
	        	for k,v in pairs(data.count) do
	        		trade[giftIndex].limit[k] = v
	        	end
	        end

	        if data.record then
	        	table.insert(trade.record,data.record[1])
	        end

			if data.bonus==nil then
				Log("trade gift is nil ");
			else
				if  AccountManager.notify_data_update then
					AccountManager:notify_data_update()
				end
				local gift = {}
				gift[1] = {}
				if data.bonus.itemId and data.bonus.num then
					gift[1].id = data.bonus.itemId
					gift[1].num = data.bonus.num
				end

				SetGameRewardFrameInfo(GetS(3160), gift, "");
			end
			--判断是否还在兑换物品的宝库
			--[[local curBaoku = ns_ma.baoku[MiniBaoKuID]
			if data.baokuId and data.baokuId == curBaoku.id then
				local tableView = getglobal("ActivityFrameTreasuryExchangeList")
				local cell = tableView:cellAtIndex(exchangeItemIndex - 1)
				TreasuryFrame_ShowDetail(cell,exchangeItemIndex)
			end
			UpdateTreasureTitle();--]]
		end
	else 
		Log("trade is fail ,error:"..ret.msg);
		--TODO 提示信息
	end

	getglobal("ActivityFrameTreasury"):Show();

end

function ExchangeBtnState() -- 按钮状态改变
	local baoku = ns_ma.bauku[MiniBaoKuID]
	if exchangeItemIndex == 0 then return end
	local giftIndex = baoku.id;
	local coin = baoku.coin
	if  giftIndex == "" then
		return;
	end

    if baoku.user_data == nil then
        baoku["user_data"]={};
    end

	if baoku.user_data[giftIndex]==nil then
			baoku.user_data[giftIndex] ={
				score=0;
				limit={};
			};
	end
	local t_score = baoku.user_data.trade_score or {};
	local userdata = baoku.user_data[giftIndex];
	local seq = TS_giftList[exchangeItemIndex].goodId;

	local ui_btn1=getglobal("TreasuryExchangeItem"..exchangeItemIndex.."ExchangeBtn");
	local ui_btn1Text = getglobal("TreasuryExchangeItem"..exchangeItemIndex.."ExchangeBtnText");
	local ui_btn1Icon=getglobal("TreasuryExchangeItem"..exchangeItemIndex.."ExchangeBtnNormal");
	local ui_btn2=getglobal("TreasuryExchangeItem"..exchangeItemIndex.."FinishBtn");

	if t_score[giftIndex].limit[seq] >= TS_giftList[exchangeItemIndex].limit then
		ui_btn1:Hide();
		ui_btn2:Show();
	else
		ui_btn1:Show();
		ui_btn2:Hide();
		ui_btn2:Disable();

		--ui_btn1Icon:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
		if TS_giftList[exchangeItemIndex].price>t_score[coin].score then
			ui_btn1Text:SetText(GetS(609));	
			--ui_btn1Icon:SetTexUV("hdfl_btn_lq02");
			ui_btn1Icon:SetGray(true);
			ui_btn1:Disable();
		else
			ui_btn1Text:SetText(GetS(460));
			--ui_btn1Icon:SetTexUV("hdfl_btn_lq01");
			ui_btn1Icon:SetGray(false);
			ui_btn1:Enable();
		end	
		exchangeItemIndex = 0;
		return;
	end
	exchangeItemIndex = 0;
end
--跳转按钮点击
function JumpToURL()
	local baoku = ns_ma.baoku[MiniBaoKuID]
	if baoku.url then
		local action = baoku.url.action
		local url = baoku.url.url

		--外部链接不隐藏
		if action and (99 == action or 98 == action) then
		else
			ActivityMainFrame:BackBtnOnClick();
		end

		global_jump_ui(action,url)
	end

	statisticsGameEventNew(1603,get_game_lang())
end

------------------------------------------2019周年庆活动-----------------------------------------
Charity201903 = {
	--update 刷新时间
	UIUpTime = 1;

	--捐献进度最大值
	MaxProgressBar = 150000;

	--贡献度档位list
	DonateGreadList = {25000, 75000, 100000, 150000};

	--播放过达成特效位置list
	AccomplishEffList = {};

	--进度条长度
	HeartProgressBarLength = 460;

	--捐赠点击爱心播放特效id
	DnateHeartPlayEntID = 1;

	--捐赠点击爱心特效列表
	DnateHeartEntList = {"ui_love_100.ent", "ui_love_dianji.ent", "ui_love_dongtai.ent", "ui_love_tuo.ent"};
	
	GetDnatePlayID = function(self)
		return self.DnateHeartPlayEntID;
	end;

	SetDnatePlayID = function(self, id)
		self.DnateHeartPlayEntID = id;
	end;

	GetDnatePlayEntName = function(self)
		return self.DnateHeartEntList[self.DnateHeartPlayEntID];
	end;

	--个人爱心捐赠信息
	OwnLoveInfo = {
		--爱心分数 100分可以换取一颗爱心
		LoveScore = 0;
		--已有爱心数
		HaveLoveNum = 0;
		--捐赠爱心数
		DonateLoveNum = 0;
	};

	--获取自身爱心分数
	GetOwnLoveSocre = function(self)
		return self.OwnLoveInfo.LoveScore;
	end;

	--设置自身爱心分数
	SetOwnLoveSocre = function(self, num)
		self.OwnLoveInfo.LoveScore = num;
	end;

	--获取拥有爱心数
	GetOwnHaveLoveNum = function(self)
		return self.OwnLoveInfo.HaveLoveNum;
	end;

	SetOwnHaveLoveNum = function(self, num)
		self.OwnLoveInfo.HaveLoveNum = num;
	end;

	--获取自身爱心捐赠数
	GetOwnDonateNum = function(self)
		return self.OwnLoveInfo.DonateLoveNum;
	end;

	SetOwnDonateNum = function(self, num)
		self.OwnLoveInfo.DonateLoveNum = num;
	end;

	--捐献爱心
	DonateLovingHeart = function(self)
		print("DonateLovingHeart1")
		local haveLoveNum = self.OwnLoveInfo.HaveLoveNum

		if haveLoveNum > 0 then
			local call_back = function(ret)
				print("DonateLovingHeart3", ret)
				if ret and ret.ret == 0 and ret.msg == "ok" then
					self:SetOwnDonateNum(ret.love_num);
					self:UpLoveHeartInfo(true);

					local uin = AccountManager:getUin();
					if self.AllServerInfo.DonateInfoList[uin] then
						self.AllServerInfo.DonateInfoList[uin].nickname = AccountManager:getNickName();
						self.AllServerInfo.DonateInfoList[uin].num = haveLoveNum;
					else
						self.AllServerInfo.DonateInfoList[uin] = {};
						self.AllServerInfo.DonateInfoList[uin]["nickname"] = AccountManager:getNickName();
						self.AllServerInfo.DonateInfoList[uin]["num"] = haveLoveNum;
					end
				else
					
				end
			end;

			local http_req_url = g_http_root .. "miniw/php_cmd?act=welfare_donate&donate=" .. haveLoveNum .. "&" .. http_getS1();
			print("DonateLovingHeart2", http_req_url)
			ns_http.func.rpc(http_req_url, call_back, nil, nil, true);  --发送http请求
		end
	end;

	--刷新爱心值
	UpOwnLoveScore = function(self)
		local call_back = function(ret)
			print("UpOwnLoveScore2", ret)
			if ret and ret.ret == 0 and ret.msg == "ok" and ret.energy then
				print("UpOwnLoveScore3", ret.energy)
				self:SetOwnLoveSocre(ret.energy);
			else
				
			end
			UpDonateInfoUI();
		end;

		local http_req_url = g_http_root .. "miniw/php_cmd?act=gongyi201903_query&" .. http_getS1();
		print("UpOwnLoveScore1", http_req_url)
		ns_http.func.rpc(http_req_url, call_back, nil, nil, true);  --发送http请求
	end;

	--上次拉取爱心捐赠数据
	UpLoveHeartInfoTime = 0;

	GetUpLoveHeartInfoTime = function(self)
		return self.UpLoveHeartInfoTime;
	end;

	SetUpLoveHeartInfoTime = function(self, time)
		self.UpLoveHeartInfoTime = time;
	end;

	--刷新爱心数据
	UpLoveHeartInfo = function(self, isCoerceUp)
		local serverTime = AccountManager:getSvrTime();
		if not isCoerceUp then
			if serverTime - self:GetUpLoveHeartInfoTime() < 30 then
				UpDonateInfoUI();
				return;
			end
		end

		self:SetUpLoveHeartInfoTime(serverTime);
		local call_back = function(ret)
			print("UpOwnLoveInfo2", ret)
			if ret and ret.ret == 0 and ret.msg == "ok" and ret.data then
				self:SetOwnLoveSocre(ret.data.user_love_energy);
				self:SetOwnHaveLoveNum(ret.data.user_love_num);
				self:SetOwnDonateNum(ret.data.user_donate_num);
				self:SetAllServerDonateNum(ret.data.love_total_num);
				self:SetIsHadBlessing(ret.data.user_bless);
				print("UpOwnLoveInf3", self.OwnLoveInfo)
			else
				
			end
			UpDonateInfoUI();
		end;

		local http_req_url = g_http_root .. "miniw/php_cmd?act=welfare_love_total_num&" .. http_getS1();
		print("UpOwnLoveInfo1", http_req_url)
		ns_http.func.rpc(http_req_url, call_back, nil, nil, true);  --发送http请求
	end;

	AllServerInfo = {
		LoveNum = 0;

		--当前显示index
		ShowIndex = 1;

		--捐献角色数据展示  Charity201903
		DonateInfoList = {
			--{"uin" = 10001, "nickname" = "abc", "num" = 100}
		};
	};

	GetAllServerDonateNum = function(self)
		return self.AllServerInfo.LoveNum;
	end;

	SetAllServerDonateNum = function(self, num)
		self.AllServerInfo.LoveNum = num;
	end;
	
	--上次拉取全服爱心捐赠数据时间
	UpAllServerDonInfoTime = 0;

	GetUpAllServerDonInfoTime = function(self)
		return self.UpAllServerDonInfoTime;
	end;

	SetUpAllServerDonInfoTime = function(self, time)
		self.UpAllServerDonInfoTime = time;
	end;

	GetDonateInfoList = function(self)
		return self.AllServerInfo.DonateInfoList;
	end;

	GetShowIndexDInfo = function(self)
		return self.AllServerInfo.ShowIndex;
	end;

	SetShowIndexDInfo = function(self, index)
		self.AllServerInfo.ShowIndex = index;
	end;

	UpAllServerDonateInfo = function(self)
		local call_back = function(ret)
			if ret and ret.ret == 0 and ret.msg == "ok" and ret.data then
				if self.AllServerInfo.DonateInfoList then
					local index = 1;
					for k, v in ipairs(self.AllServerInfo.DonateInfoList) do
						index = index + 1;

						if index > 1800 then
							self.AllServerInfo.DonateInfoList[k] = nil;
						end
					end
				end

				for k, v in ipairs(ret.data) do
					if v.uin and v.nickname and v.donate_num then
						local uin = v.uin;
						if self.AllServerInfo.DonateInfoList[uin] then
							self.AllServerInfo.DonateInfoList[uin].nickname = v.nickname;
							self.AllServerInfo.DonateInfoList[uin].num = v.donate_num;
						else
							self.AllServerInfo.DonateInfoList[uin] = {};
							self.AllServerInfo.DonateInfoList[uin]["nickname"] = v.nickname;
							self.AllServerInfo.DonateInfoList[uin]["num"] = v.donate_num;
						end
					end
				end
				setkv("DonateInfo", self.AllServerInfo.DonateInfoList, "Charity201903");
			end
		end;

		local http_req_url = g_http_root .. "miniw/php_cmd?act=welfare_new_list&" .. http_getS1();
		print("UpAllDonateInfo1", http_req_url)
		ns_http.func.rpc(http_req_url, call_back, nil, nil, true);  --发送http请求
	end;

	--提交祝福语
	UpLoadBlessing = function(self, text)
		local call_back = function(ret)
			print("UpLoadBlessing2", ret)
			if ret and ret.ret == 0 and ret.msg == "ok" then
				self:UpLoveHeartInfo(true);
				getglobal("SociallyUseful2019BlessingFrame"):Hide();
				ShowGameTips(GetS(21549));
			end
		end;

		local http_req_url = g_http_root .. "miniw/php_cmd?act=welfare_blessing_add&blessing=" .. escape(text) .. "&" .. http_getS1();
		print("UpLoadBlessing1", http_req_url)
		ns_http.func.rpc(http_req_url, call_back, nil, 0, true);  --发送http请求 
	end;

	--标识玩家是否已经提交过祝福
	IsHadBlessing = true;

	GetIsHadBlessing = function(self)
		return self.IsHadBlessing;
	end;

	SetIsHadBlessing = function(self, bl)
		if bl == 1 then
			self.IsHadBlessing = true;
		else
			self.IsHadBlessing = false;
		end
	end;
}

function ActivityFrameSociallyUseful201903_OnLoad()
	this:setUpdateTime(Charity201903.UIUpTime);
end

function ActivityFrameSociallyUseful201903_OnUpdate()
	--print("ActivityFrameSociallyUseful201903_OnUpdate");
	local list = Charity201903:GetDonateInfoList();
	local showIndex = Charity201903:GetShowIndexDInfo();
	local index = 0;

	--print("ActivityFrameSociallyUseful201903_OnUpdate1", list, showIndex)
	local scrollingTag = getglobal("ActivityFrameSociallyUseful201903BottomScrollingTag");
	if list then
		scrollingTag:Hide();
		for k, v in pairs(list) do
			index = index + 1
			--print("ActivityFrameSociallyUseful201903_OnUpdate2", v)
			if index > showIndex then
				local id = index - showIndex;
				if id > 4 then
					return;
				end

				local sobj = getglobal("ActivityFrameSociallyUseful201903BottomScrolling" .. 5 - id);
				sobj:Show();
				local uin = tostring(k);
				uin = uin.sub(uin, 1, 2) .. "****" .. uin.sub(uin, string.len(uin)-1, string.len(uin));
				if id == 1 then
					sobj:SetText(GetS(21581, v.nickname, uin, v.num));
					sobj:SetBlendAlpha(0.5);
				elseif id <= 4 then
					sobj:SetText(GetS(21546, v.nickname, uin, v.num));
				end
				Charity201903:SetShowIndexDInfo(showIndex + 1);
			end
		end
	else
		scrollingTag:Show();
	end

	Charity201903:SetShowIndexDInfo(0);
end

function ActivityFrameSociallyUseful201903_OnShow()
	if Charity201903.IsFirstShow then
		Charity201903.IsFirstShow = false;
	end;

	if if_open_sy201903SeeActivity_btn() then
		getglobal("ActivityFrameSociallyUseful201903ContentExplanation"):Show();
	else
		getglobal("ActivityFrameSociallyUseful201903ContentExplanation"):Hide();
	end

	getglobal("ActivityFrameSociallyUseful201903TopAllNum"):SetText(GetS(21544, 0));
	getglobal("ActivityFrameSociallyUseful201903TopOwnNum"):SetText(GetS(21545, 0));
	
	getglobal("ActivityFrameSociallyUseful201903ContentAllScaleAccomplishTag"):Hide();

	--local dnateheartView3 = getglobal("ActivityFrameSociallyUseful201903ContentDonateBtnView3");
	Charity201903:SetDnatePlayID(3);
	
	local entPath = "particles/" .. Charity201903:GetDnatePlayEntName();
	--dnateheartView3:Show();
	--dnateheartView3:addBackgroundEffect(entPath, 0, 80, 400);

	local serverTime = AccountManager:getSvrTime();

	Charity201903:UpLoveHeartInfo();
	local list = getkv("Charity201903AE");
	if list then
		Charity201903.AccomplishEffList = list;
	end

	print("ActivityFrameSociallyUseful201903_OnShow", serverTime)
	if serverTime - Charity201903:GetUpAllServerDonInfoTime() > 60 * 60 then
		Charity201903:SetUpAllServerDonInfoTime(serverTime);
		Charity201903:UpAllServerDonateInfo();
	end

	local scrollingTag = getglobal("ActivityFrameSociallyUseful201903BottomScrollingTag");
	scrollingTag:Show();
	local list = getkv("DonateInfo", "Charity201903");
	if list then
		Charity201903.AllServerInfo.DonateInfoList = list;
		scrollingTag:Hide();
		ActivityFrameSociallyUseful201903_OnUpdate();
	end
end;

function SociallyUseful201903BottomBlessingBtn_OnClick()
	local uin = AccountManager:getUin();
	if  uin and uin >= 1000  then
		if Charity201903:GetIsHadBlessing() then
			if ns_ma.ext_gift and ns_ma.ext_gift.gongyi201903btn and ns_ma.ext_gift.gongyi201903btn.url1 then
				--查看祝福按钮
				open_http_link(ns_ma.ext_gift.gongyi201903btn.url1);
			end
		else
			getglobal("SociallyUseful2019BlessingFrameNickName"):SetText(GetS(21556) .. AccountManager:getNickName());
			getglobal("SociallyUseful2019BlessingFrameMiniUin"):SetText(GetS(21557) .. AccountManager:getUin());
			getglobal("SociallyUseful2019BlessingFrame"):Show();
		end
	else
		--未登录成功
		return
	end
end

function SociallyUseful201903BanBottomBlessingBtn_OnClick()
	ShowGameTips(GetS(21548));
end

function SociallyUseful201903BanBottomAwardBtn_OnClick()
	global_jump_ui(101);
end

function SociallyUseful2019BlessingFrame_OnClick()
	getglobal("SociallyUseful2019BlessingFrame"):Hide();
end

function SociallyUseful2019BlessingFrameEdit_OnFocusGained()
	print("SociallyUseful2019BlessingFrameEdit_OnEnterPressed")
	getglobal("SociallyUseful2019BlessingFrameEditHint"):Hide();
end

function SociallyUseful2019BlessingFrameEdit_OnFocusLost()
	local text = getglobal("SociallyUseful2019BlessingFrameEdit"):GetText();
	if not text or string.len(text) <= 0 then
		getglobal("SociallyUseful2019BlessingFrameEditHint"):Show();
	end
end

function SociallyUseful201903InputTextFrameConfirm_OnClick()
	local uin = AccountManager:getUin();
	local text = getglobal("SociallyUseful2019BlessingFrameEdit"):GetText();

	if text and string.len(text) > 0 then
		if CheckFilterString(text) then
			return;
		end

		Charity201903:UpLoadBlessing(text);
	else
		ShowGameTips(GetS(21560));
	end
end

function SociallyUseful201903DonateBtn_OnClick()
	if Charity201903:GetOwnHaveLoveNum() < 1 then
		ShowGameTips(GetS(21547));
		return;
	end

	-- local dnateheartView3 = getglobal("ActivityFrameSociallyUseful201903ContentDonateBtnView3");
	-- Charity201903:SetDnatePlayID(3);
	-- local entPath3 = "particles/" .. Charity201903:GetDnatePlayEntName();
	-- dnateheartView3:Hide();

	-- local dnateheartView2 = getglobal("ActivityFrameSociallyUseful201903ContentDonateBtnView2");
	-- Charity201903:SetDnatePlayID(2);
	-- entPath2 = "particles/" .. Charity201903:GetDnatePlayEntName();
	-- dnateheartView2:Show();
	-- dnateheartView2:addBackgroundEffect(entPath2, 0, 80, 400);

	-- threadpool:work(function()
	-- 	threadpool:wait(3);
	-- 		dnateheartView2:Hide();

	-- 		Charity201903:SetDnatePlayID(3);
	-- 		dnateheartView3:Show();
	-- 		dnateheartView3:addBackgroundEffect(entPath3, 0, 80, 400);
	-- 	end)

	Charity201903:DonateLovingHeart();

	ActivityMainCtrl:RequestWelfareRewardData()
end

function LoadDonateInfo()
	Charity201903:UpLoveHeartInfo();
end

function UpDonateInfoUI()
	if not getglobal("ActivityFrameSociallyUseful201903"):IsShown() then
		return;
	end

	local ownDonateNum = Charity201903:GetOwnDonateNum();
	local allDNum = Charity201903:GetAllServerDonateNum();
	getglobal("ActivityFrameSociallyUseful201903TopAllNum"):SetText(GetS(21544, allDNum));
	getglobal("ActivityFrameSociallyUseful201903TopOwnNum"):SetText(GetS(21545, ownDonateNum));
	
	--进度条长度
	local pbLen = 526;
	--计算进度条进度
	local redPbLen = 0;
	--math.modf(allDNum / 10000000) * (Charity201903.MaxProgressBar / 4) + (allDNum / Charity201903.MaxProgressBar * pbLen)
	local numList = Charity201903.DonateGreadList;
	if allDNum < numList[1] then
		redPbLen = 30 * allDNum/numList[1];
	elseif allDNum >= numList[1] and allDNum < numList[2] then
		redPbLen = 30 + (allDNum - numList[1]) / (numList[2] - numList[1]) * ((pbLen - 60) / 3);
	elseif allDNum >= numList[2] and allDNum < numList[3] then
		redPbLen = 30 + ((allDNum - numList[2]) / (numList[3] - numList[2]) + 1) * ((pbLen - 60) / 3);
	elseif allDNum >= numList[3] and allDNum < numList[4] then
		redPbLen = 30 + ((allDNum - numList[3]) / (numList[4] - numList[3])  + 2) * ((pbLen - 60) / 3);
	else
		redPbLen = 526 - 30 + 30 * (allDNum - numList[4])/numList[1];
	end

	print("UpDonateInfoUI1", pbLen, allDNum, Charity201903.MaxProgressBar, redPbLen)
	if redPbLen > pbLen then
		redPbLen = pbLen;
	end
	getglobal("ActivityFrameSociallyUseful201903ContentAllScaleProgress"):SetWidth(redPbLen);

	local dontateView = getglobal("ActivityFrameSociallyUseful201903ContentAllScaleProgressView");
	dontateView:Hide();
	dontateView:deleteBackgroundEffect("particles/ui_love_jindu.ent");
	dontateView:addBackgroundEffect("particles/ui_love_jindu.ent", 100, 70, -100);
	dontateView:SetPoint("left", "ActivityFrameSociallyUseful201903ContentAllScaleProgress", "right", -40, 0);
	dontateView:Show();

	if allDNum >= Charity201903.DonateGreadList[1] then
		local heartView1 = getglobal("ActivityFrameSociallyUseful201903ContentAllScaleHeartView1");
		local redHeartView1 = getglobal("ActivityFrameSociallyUseful201903ContentAllScaleRedHeart1");
		if allDNum <  Charity201903.DonateGreadList[2] then
			if not Charity201903.AccomplishEffList[Charity201903.DonateGreadList[1]] then
				Charity201903.AccomplishEffList[Charity201903.DonateGreadList[1]] = true;
				setkv("Charity201903AE", Charity201903.AccomplishEffList);

				heartView1:Show();
				heartView1:deleteBackgroundEffect("particles/ui_love_dacheng.ent");
				heartView1:addBackgroundEffect("particles/ui_love_dacheng.ent", 0, 100, -300);

				threadpool:work(function()
					threadpool:wait(2);
					heartView1:deleteBackgroundEffect("particles/ui_love_dacheng.ent");
					heartView1:Hide();
					end)
			end

			redHeartView1:Show();
			redHeartView1:addBackgroundEffect("particles/ui_love_tuo.ent", 0, 100, -200);
		else
			redHeartView1:Hide();

			heartView1:deleteBackgroundEffect("particles/ui_love_dacheng.ent");
			heartView1:Hide();
			getglobal("ActivityFrameSociallyUseful201903ContentAllScaleRedHeart1Tex"):Show()
		end
	end

	if allDNum >= Charity201903.DonateGreadList[2] then
		local heartView2 = getglobal("ActivityFrameSociallyUseful201903ContentAllScaleHeartView2");
		local redHeartView2 = getglobal("ActivityFrameSociallyUseful201903ContentAllScaleRedHeart2");
		if allDNum <  Charity201903.DonateGreadList[3] then
			if not Charity201903.AccomplishEffList[Charity201903.DonateGreadList[2]] then
				Charity201903.AccomplishEffList[Charity201903.DonateGreadList[2]] = true;
				setkv("Charity201903AE", Charity201903.AccomplishEffList);

				heartView2:Show();
				heartView2:deleteBackgroundEffect("particles/ui_love_dacheng.ent");
				heartView2:addBackgroundEffect("particles/ui_love_dacheng.ent", 0, 100, -300);

				threadpool:work(function()
					threadpool:wait(2);
					heartView2:deleteBackgroundEffect("particles/ui_love_dacheng.ent");
					heartView2:Hide();
					end)
			end

			redHeartView2:Show();
			redHeartView2:addBackgroundEffect("particles/ui_love_tuo.ent", 0, 100, -200);
		else
			redHeartView2:Hide();
			heartView2:deleteBackgroundEffect("particles/ui_love_dacheng.ent");
			heartView2:Hide();
			getglobal("ActivityFrameSociallyUseful201903ContentAllScaleRedHeart2Tex"):Show()
		end
	end

	if allDNum >= Charity201903.DonateGreadList[3] then
		local heartView3 = getglobal("ActivityFrameSociallyUseful201903ContentAllScaleHeartView3");
		local redHeartView3 = getglobal("ActivityFrameSociallyUseful201903ContentAllScaleRedHeart3");

		if allDNum <  Charity201903.DonateGreadList[4] then
			if not Charity201903.AccomplishEffList[Charity201903.DonateGreadList[3]] then
				Charity201903.AccomplishEffList[Charity201903.DonateGreadList[3]] = true;
				setkv("Charity201903AE", Charity201903.AccomplishEffList);

				heartView3:Show();
				heartView3:deleteBackgroundEffect("particles/ui_love_dacheng.ent");
				heartView3:addBackgroundEffect("particles/ui_love_dacheng.ent", 0, 100, -300);

				threadpool:work(function()
					threadpool:wait(2);
					heartView3:deleteBackgroundEffect("particles/ui_love_dacheng.ent");
					heartView3:Hide();
					end)
			end

			redHeartView3:Show();
			redHeartView3:addBackgroundEffect("particles/ui_love_tuo.ent", 0, 100, -200);
		else
			redHeartView3:Hide();
			heartView3:deleteBackgroundEffect("particles/ui_love_dacheng.ent");
			heartView3:Hide();
			getglobal("ActivityFrameSociallyUseful201903ContentAllScaleRedHeart3Tex"):Show()
		end
	end

	if allDNum >= Charity201903.DonateGreadList[4] then
		getglobal("ActivityFrameSociallyUseful201903ContentAllScaleAccomplishTag"):Show();

		if not Charity201903.AccomplishEffList[Charity201903.DonateGreadList[4]] then
			Charity201903.AccomplishEffList[Charity201903.DonateGreadList[4]] = true;
			setkv("Charity201903AE", Charity201903.AccomplishEffList);

			local heartView4 = getglobal("ActivityFrameSociallyUseful201903ContentAllScaleHeartView4");
			heartView4:Show();
			heartView4:deleteBackgroundEffect("particles/ui_love_dacheng.ent");
			heartView4:addBackgroundEffect("particles/ui_love_dacheng.ent", 0, 100, -300);

			threadpool:work(function()
					threadpool:wait(2);
					heartView4:deleteBackgroundEffect("particles/ui_love_dacheng.ent");
					heartView4:Hide();
					end)
		end

		local redHeartView4 = getglobal("ActivityFrameSociallyUseful201903ContentAllScaleRedHeart4");
		redHeartView4:Show();
		redHeartView4:addBackgroundEffect("particles/ui_love_tuo.ent", 0, 100, -200);
	end

	local haveLoveNum = Charity201903:GetOwnHaveLoveNum();
	local ownLoveSocre = Charity201903:GetOwnLoveSocre();
	getglobal("ActivityFrameSociallyUseful201903ContentDonateBtnNum"):SetText(haveLoveNum);
	getglobal("ActivityFrameSociallyUseful201903ContentDonateBtnScore"):SetText(ownLoveSocre .. "/100");
	getglobal("ActivityFrameSociallyUseful201903ContentDonateBtnOwnScaleProgress"):SetWidth(ownLoveSocre / 100 * 100);

	local banBlessingBtn = getglobal("ActivityFrameSociallyUseful201903BottomBanBlessingBtn");
	local blessingBtn = getglobal("ActivityFrameSociallyUseful201903BottomBlessingBtn");
	if ownDonateNum >= 1 then
		banBlessingBtn:Hide();
		blessingBtn:Show();
		
		if Charity201903:GetIsHadBlessing() then
			if if_open_sy201903SeeBlessing_btn() then
				getglobal("ActivityFrameSociallyUseful201903BottomBlessingBtnName"):SetText(GetS(21542));
			else
				blessingBtn:Hide();
			end
		else
			getglobal("ActivityFrameSociallyUseful201903BottomBlessingBtnName"):SetText(GetS(21541));
		end
	else
		banBlessingBtn:Show();
		blessingBtn:Hide();
	end

	-- local dnateheartView3 = getglobal("ActivityFrameSociallyUseful201903ContentDonateBtnView3");
	-- local dnateheartView1 = getglobal("ActivityFrameSociallyUseful201903ContentDonateBtnView1");
	-- local entPath = "particles/" .. Charity201903:GetDnatePlayEntName();

	-- if haveLoveNum >= 1 then
	-- 	Charity201903:SetDnatePlayID(1);
	-- 	entPath = "particles/" .. Charity201903:GetDnatePlayEntName();
	-- 	dnateheartView1:Show();
	-- 	dnateheartView1:addBackgroundEffect(entPath, 0, 90, 300);
	-- else
	-- 	dnateheartView1:deleteBackgroundEffect(entPath);
	-- 	dnateheartView1:Hide();
	-- end

	Charity201903:SetDnatePlayID(3);
end

--活动介绍
function SociallyUseful201903ContentExplanation_OnClick()
	if ns_ma.ext_gift and ns_ma.ext_gift.gongyi201903btn and ns_ma.ext_gift.gongyi201903btn.url2 then
		--活动介绍
		open_http_link(ns_ma.ext_gift.gongyi201903btn.url2);
	end
end

--刷新周年庆活动红点提示
function UpCharity201903RadTag()
	-- local call_back = function(ret)
	-- 	if ret and ret.ret == 0 and ret.msg == "ok" and ret.data and ret.data.user_love_num and ret.data.user_love_num >= 1 then
	-- 		getglobal("SociallyUseful201903BtnRedTag"):Show();
	-- 		getglobal(        "AdvertFrameACTBtnRedTag"):Show();         --活动
	-- 		getglobal("MarketActivityFrameACTBtnRedTag"):Show();         --活动
	-- 		getglobal(      "ActivityFrameACTBtnRedTag"):Show();         --活动
	-- 	else
	-- 		getglobal("SociallyUseful201903BtnRedTag"):Hide();
	-- 	end
	-- end;

	-- local http_req_url = g_http_root .. "miniw/php_cmd?act=welfare_love_total_num&" .. http_getS1();
	-- ns_http.func.rpc(http_req_url, call_back);  --发送http请求 
end

------------------确认兑换弹板----------------------------------------
function ExchangeConfirmFrame_OnShow()
	getglobal("RewardTypeBox"):setDealMsg(false)
	getglobal("ActivityFrameTreasuryExchangeList"):setDealMsg(false)
	loadConfirmFrameInfo()
end

function ExchangeConfirmFrame_OnHide()
	getglobal("RewardTypeBox"):setDealMsg(true)
	getglobal("ActivityFrameTreasuryExchangeList"):setDealMsg(true)
end

function ExchangeConfirmFrame_OnClick()
	getglobal("ExchangeConfirmFrame"):Hide()

	if this:GetClientID() == 1 then
		TreasuryItemExchange();
		-- ExchangeBtnState();
	end
end

function ExchangeBtnRecord_OnClick()
	getglobal("ExchangeRecordPanel"):Show()
end

function loadConfirmFrameInfo()
	local useitemid = gExchangeInfo.useitemid or 10003
	local itemDef = ItemDefCsv:get(useitemid)
	if not itemDef then
		getglobal("ExchangeConfirmFrame"):Hide()
		return
	end

	local useitemname = itemDef.Name.."x"..(gExchangeInfo.selectnum*gExchangeInfo.costnum)
	itemDef = ItemDefCsv:get(gExchangeInfo.giftitemid)
	if not itemDef then
		getglobal("ExchangeConfirmFrame"):Hide()
		return
	end

	local giftitemname = itemDef.Name
	if gExchangeInfo.giftitemnum > 1 then
		giftitemname = itemDef.Name.."*"..gExchangeInfo.giftitemnum
	end
	-- local str = "您将消耗#c15a815"..useitemname.."#n来兑换#cff8920"..gExchangeInfo.selectnum.."#n份#cff8920"..giftitemname.."#n，请确认"
	local str = GetS(4866, "#c15a815"..useitemname.."#n", "#cff8920"..gExchangeInfo.selectnum.."#n", "#cff8920"..giftitemname.."#n")
	local tipslab = getglobal("ExchangeConfirmFrameTips")
	tipslab:setCenterLine(true)
	tipslab:SetText(str, 55, 55, 50);
	SetItemIcon(getglobal("ExchangeConfirmFrameIcon"), gExchangeInfo.giftitemid)
end

------------------选择数量弹板----------------------------------------
local gSelectCount = 1
local gMaxSelectCount = 1

function SelectCountFrame_OnShow()
	getglobal("RewardTypeBox"):setDealMsg(false)
	getglobal("ActivityFrameTreasuryExchangeList"):setDealMsg(false)
	gSelectCount = 1
	gMaxSelectCount = gExchangeInfo.maxexchangenum

	SetItemIcon(getglobal("SelectCountFrameIcon"), gExchangeInfo.giftitemid)

	loadSelectCountFrameInfo()
end

function SelectCountFrame_OnHide()
	getglobal("RewardTypeBox"):setDealMsg(true)
	getglobal("ActivityFrameTreasuryExchangeList"):setDealMsg(true)
end

function SelectCountFrame_OnClick()
	getglobal("SelectCountFrame"):Hide()

	if this:GetClientID() == 1 then
		setExchangeInfo(nil, nil, nil, gSelectCount)
		getglobal("ExchangeConfirmFrame"):Show()
	end
end

function SelectCountFrameMinusBtn_OnClick()
	if gSelectCount <= 1 then return end

	gSelectCount = gSelectCount - 1
	loadSelectCountFrameInfo()
end

function SelectCountFramePlusBtn_OnClick()
	if gSelectCount >= gMaxSelectCount then return end
	
	gSelectCount = gSelectCount + 1
	loadSelectCountFrameInfo()
end

function SelectCountFrameMaxBtn_OnClick()
	gSelectCount = gMaxSelectCount
	loadSelectCountFrameInfo()
end

function loadSelectCountFrameInfo()
	local selectLab = getglobal("SelectCountFrameSelectNumLabel")
	selectLab:SetText(""..gSelectCount)

	local str = GetS(4876).."#c15a815"..gSelectCount.."#n/"..gMaxSelectCount
	local selectlab = getglobal("SelectCountFrameTips")
	selectlab:SetText(str, 55, 55, 50);
end

--------------------兑换记录弹板---------------------
local gCurPageIdx = 1
local gMaxPageIdx = 1

function ExchangeRecordPanel_OnLoad()
	-- body
	initRecordItem()
end

function ExchangeRecordPanel_OnShow()
	getglobal("ActivityFrameTreasuryExchangeList"):setDealMsg(false)
	initPageData()
	loadRecordInfo()
end

function ExchangeRecordPanel_OnHide()
	getglobal("ActivityFrameTreasuryExchangeList"):setDealMsg(true)
end

function ExchangeBtnRecordClose_OnClick()
	getglobal("ExchangeRecordPanel"):Hide()
end

function ExchangeRecordPanelLeftBtn_OnClick()
	if gCurPageIdx <= 1 then return end

	gCurPageIdx = gCurPageIdx - 1
	loadRecordInfo()
end

function ExchangeRecordPanelRightBtn_OnClick()
	if gCurPageIdx >= gMaxPageIdx then return end

	gCurPageIdx = gCurPageIdx + 1
	loadRecordInfo()
end

function initRecordItem()
	local uiitem, alignparent = nil, "ExchangeRecordPanelBkg2"
	local offsety, h, height = 5, 10, 0
	
	for i=1,8 do
		uiitem = getglobal("ExchangeRecordPanelItem"..i.."UseItemIcon")
		uiitem:SetWidth(32)
		uiitem:SetHeight(32)

		uiitem = getglobal("ExchangeRecordPanelItem"..i)
		if i == 1 then height = uiitem:GetHeight() end
		uiitem:SetPoint("top", alignparent, "top", 0, offsety+(height+h)*(i-1))
	end
end

function initPageData()
	local baoku = ns_ma.baoku[MiniBaoKuID]
	local t_score = baoku.user_data.trade_score or {};
	local tradelist = t_score.record

	gCurPageIdx = 1
	gMaxPageIdx = 1 + math.floor((#tradelist-1)/8)
end

function loadRecordInfo()
	local pageLab = getglobal("ExchangeRecordPanelPageLabel")
	local maxpage = math.max(1, gMaxPageIdx)
	pageLab:SetText(""..gCurPageIdx.."/"..maxpage)

	local baoku = ns_ma.baoku[MiniBaoKuID]
	local t_score = baoku.user_data.trade_score or {};
	local tradelist = t_score.record

	local idx, recorddata = 1, nil
	for i=1,8 do
		idx = (gCurPageIdx-1)*8 + i
		recorddata = tradelist[idx]
		if type(recorddata) == "string" then
			recorddata = decodeRecordData(recorddata)
		end

		uiitem = getglobal("ExchangeRecordPanelItem"..i)
		if recorddata then
			uiitem:Show()

			uiitem = getglobal("ExchangeRecordPanelItem"..i.."UseItem")
			uiitem:SetClientID(100000+idx)

			uiitem = getglobal("ExchangeRecordPanelItem"..i.."UseItemIcon")
			SetItemIcon(uiitem, recorddata.id)

			uiitem = getglobal("ExchangeRecordPanelItem"..i.."ExchangeNum")
			uiitem:SetText(""..recorddata.num);

			uiitem = getglobal("ExchangeRecordPanelItem"..i.."CostIcon")
			SetItemIcon(uiitem, gExchangeInfo.useitemid)

			uiitem = getglobal("ExchangeRecordPanelItem"..i.."CostNum")
			uiitem:SetText(""..recorddata.cost)

			uiitem = getglobal("ExchangeRecordPanelItem"..i.."ExchangeTime")
			uiitem:SetText(os.date("%m.%d-%H:%M:%S", recorddata.time))
		else
			uiitem:Hide()
		end
	end
end
--解析领取记录数据
function decodeRecordData(data)
	if not data then return end

	local record = {}
	local word,value = "",1
	for word in string.gmatch(data,"%d+") do
		if value == 1 then
			record.id = word
			value = value + 1
		elseif value == 2 then
			record.time = word 
			value = value + 1
		elseif value == 3 then
			record.num = word
			value = value + 1
		elseif value == 4 then
			record.cost = word
			value = 1
		end
	end

	return record
end

--[[
Author: sundy
EditTime: 2021-08-23
Description: 全部显示的 只处理了9号、27号广告位的
--]]

function GameAllRewardFrameGetBtn_OnClick()
	getglobal("GameAllRewardFrame"):Hide()
end

-- 再次播放广告
function GameAllRewardFrameAgainBtn_OnClick()
	if MafBtnExtend2 == nil or MafBtnExtend2.task_id == nil then return end
	local table = MafBtnExtend2
	local task_id = MafBtnExtend2.task_id
	getglobal("GameAllRewardFrame"):Hide()

	if task_id == "showad9" then
		MAFBtnGet_OnClick(nil,table)
	elseif task_id == "showad27" then
		MAFBtnGet_OnClick(nil,table)
	-- elseif task_id == "showad26" and isAbroadEvn() then
	-- 	GetInst("UIManager"):GetCtrl("ShopAdvert"):PlayAdBtnClicked(true)
	-- 	print("GameRewardFrameAgainBtn_OnClick_task_id ========= 26")
	end	
end

function GameAllRewardFrame_OnLoad()
	this:setUpdateTime(0.05);
    UITemplateBaseFuncMgr:registerFunc("GameAllRewardFrameCloseBtn", GameAllRewardFrameGetBtn_OnClick, "登录奖励界面关闭按钮");
	-- ShowGameAllRewardFrame()
end

local GameAllRewardAngleSpeed = 5;
local GameAllRewardAngle = 0;
function GameAllRewardFrame_OnUpdate()
	GameAllRewardAngle = GameAllRewardAngle + GameAllRewardAngleSpeed;
	if GameAllRewardAngle > 360 then
		GameAllRewardAngle = GameAllRewardAngle - 360;
	end
	getglobal("GameAllRewardFrameEffect"):SetAngle(GameAllRewardAngle);
end

function GameAllRewardFrame_OnShow()
	Log("GameRewardFrame_OnShow_start")
	isCheckAdFinish = false
	threadpool:work(function()
		while true do
			if not getglobal("GameAllRewardFrame"):IsShown() then
				return
			end
			GameRewardFrameCheckAdShow()
			threadpool:wait(0.5)
		end
	end)
end

function GameAllRewardFrame_OnHide()
	-- print("GameRewardFrame_OnHide")
	GameRewardFrameSetMafBtnExtend(nil)
	GameRewardFrameSetMafBtnExtend2(nil)
	-- getglobal("GameRewardFrameFuncBtn"):Hide()
	-- getglobal("GameRewardFrameAgainBtn"):Hide()
	getglobal("GameAllRewardFrameLeftCount"):SetText("")
	-- getglobal("GameRewardFrameGetBtn"):SetPoint("bottom","GameRewardFrameBkg2","bottom",0,-25)
end

function ShowGameAllRewardFrame(tItems)
	-- print('sundy----->>>444');
	local task_id = MafBtnExtend.task_id
	local ad_id = task_id == 'showad9' and 9 or 0
	if ad_id == 0 then
		ad_id = task_id == 'showad27' and 27 or 0
	end
	
	local callback = function(ad_info)
		if ad_info and ad_info.finish and ad_info.finish.count and ad_info.num_total then
			if ad_info.finish.count >= ad_info.num_total then
				-- print('sundy----->>>444111111' , ad_id);
				getglobal("GameAllRewardFrameGetBtn"):SetPoint('bottom', 'GameAllRewardFrameBkg2', 'bottom', 0, -25)
				getglobal("GameAllRewardFrameAgainBtn"):Hide()
			else
				-- print('sundy----->>>444111222' , ad_id);
				getglobal("GameAllRewardFrameGetBtn"):SetPoint('bottom', 'GameAllRewardFrameBkg2', 'bottom', -106, -25)
				getglobal("GameAllRewardFrameAgainBtn"):Show()
			end
			getglobal("GameAllRewardFrameLeftCount"):SetText(GetS(30112,ad_info.finish.count,ad_info.num_total))
		else
			print("sundy ShowGameAllRewardFrame ad_info error", ad_id);
		end
		-- print('sundy----->>>444111' , MafBtnExtend.task_id,  ad_id);	
	end

	if IsAdUseNewLogic(ad_id) then
		GetInst("AdService"):GetAdInfo(ad_id, callback)
	else
		local ad_info = AccountManager:ad_position_info(ad_id);
		if AccountManager.ad_position_info2 then
			ad_info = AccountManager:ad_position_info2(ad_id);
		end
		callback(ad_info)
	end

	tItems = tItems or {}
	if #tItems == 0 then
		return 
	end
	local bkg2 = getglobal("GameAllRewardFrameBkg2")

	local width = #tItems * 140 - 30
	local curWidth = bkg2:GetWidth()
	if curWidth < width then
		bkg2:SetWidth(width + 100)
	end

	local item1 = getglobal('GameAllRewardFrameItem1')
	if #tItems > 1 then
		item1:SetPoint("top", "GameAllRewardFrameBkg2", "top", 0 - ((#tItems - 1) * 140) / 2, 129)
	else
		item1:SetPoint("top", "GameAllRewardFrameBkg2", "top", 0, 129)
	end

	for i = 1, 5 do
		-- local item = getglobal('GameAllRewardFrameItem' .. i)
		local widget = {
			this = getglobal('GameAllRewardFrameItem' .. i),
			icon = getglobal(string.format("GameAllRewardFrameItem%d%s", i, 'Icon')),
			iconName = getglobal(string.format("GameAllRewardFrameItem%d%s", i, 'IconName')),
			itemDesc = getglobal(string.format("GameAllRewardFrameItem%d%s", i, 'ItemDesc')),
			count = getglobal(string.format("GameAllRewardFrameItem%d%s", i, 'Count')),
		}
		widget.this:Hide()


		local item = tItems[i]
		if item then
			local itemDef = ItemDefCsv:get(item.id);
			SetItemIcon(widget.icon, item.id);
			local color = item.color or "#c3D4546"
			local count = item.num or item.count or nil
			count = count and ('#nx' .. count) or ''
			local text = color .. itemDef.Name .. count
			widget.iconName:SetFontSize(24)
			widget.iconName:SetText(text)

			-- 24
			local width = widget.iconName:GetTextExtentWidth(text)
			if width > 120 then
				widget.iconName:SetFontSize(20)
				local height = widget.iconName:GetTextExtentHeight(text)
				local scale = height / 20
				local sizeHeight = math.ceil(width / 120 / scale) * 20
				widget.iconName:SetSize(120, sizeHeight)
			end
			widget.this:Show()
		end
	end

	if not getglobal("GameAllRewardFrame"):IsShown() then
		getglobal("GameAllRewardFrame"):Show();
	end

	-- print('sundy----->>>555');
	getglobal("GameAllRewardFrameGetBtnEffect1"):SetUVAnimation(100, false);
	ClientMgr:playSound2D("sounds/ui/info/book_seriesunlock.ogg", 1);

	-- 9/27号广告中有迷你点需要客户端主动刷新监听事件	
	UpdateMiniPointWithoutTip()
end

----------------------------------------幸运方块-----------------------------------------
local LuckSquare_data = nil -- 服务器数据
local LuckSquare_adposition = 32

function LuckSquare_OnLoad()
	this:setUpdateTime(1.0)
end


--获取当前的活动
function LuckSquare_GetCurrentActivity()
	--每期活动时间
	if ns_luck_square_config.activity and next(ns_luck_square_config.activity) then
		for key, value in pairs(ns_luck_square_config.activity) do
			local start_time =  value.start_time
			local end_time =  value.end_time
			 if start_time and end_time and AccountManager:getSvrTime() >= start_time and AccountManager:getSvrTime() <= end_time then
				return value
			 end
		end
	end
	return nil
end

--获取上一次的活动
function LuckSquare_GetLastActivity()
	if ns_luck_square_config.activity and next(ns_luck_square_config.activity) then
		local sortActivity = {}
		--先排序
		for _, value in pairs(ns_luck_square_config.activity) do
			table.insert(sortActivity,value)
		end
		table.sort(sortActivity,function (a, b) return a.start_time < b.start_time end)

		--取上一次活动
		local count = #sortActivity or 0
		if count > 0 then
			for index, value in ipairs(sortActivity) do
				local end_time =  value.end_time
				if end_time and AccountManager:getSvrTime() > end_time then
					if index == count then
						return value
					else
						return sortActivity[index-1]
					end
				end
			end
		end
	end
	return nil
end

--显示背景图
function LuckSquare_ShowBackgroundImage()
	local valid = LuckSquare_CheckActivityIsValid()
	local activityData = nil
	if valid == 0 then
		activityData = LuckSquare_GetLastActivity()
	elseif valid == 1 then
		activityData = LuckSquare_GetCurrentActivity()
	elseif valid == 2 then
		activityData = LuckSquare_GetCurrentActivity()
	end

	if activityData and activityData.url and activityData.url ~= '' then
		local tmpPath  = g_download_root .. "lucksquare_" .. ns_advert.func.trimUrlFile(activityData.url) .. ".tmp"
		local szFilepath  = g_download_root .. "lucksquare_" .. ns_advert.func.trimUrlFile(activityData.url) .. "_"
		if gFunc_isFileExist(tmpPath) then
			gFunc_deleteStdioFile(tmpPath)
		end
		if not gFunc_isFileExist(szFilepath) then
			local function downloadPng_cb()
				gFunc_renameStdioPath(tmpPath, szFilepath)
				getglobal("ActivityFrameLuckSquareBkg"):ReleaseTexture(szFilepath)
				getglobal("ActivityFrameLuckSquareBkg"):SetTexture(szFilepath)
			end
			ns_http.func.downloadPng(activityData.url, tmpPath, nil, nil, downloadPng_cb)
		else
			getglobal("ActivityFrameLuckSquareBkg"):ReleaseTexture(szFilepath)
			getglobal("ActivityFrameLuckSquareBkg"):SetTexture(szFilepath)
		end
	end
end


--显示活动时间
function LuckSquare_ShowActivityDate()
	if ns_luck_square_config.activity_date_switch and ns_luck_square_config.activity_date_switch == 1 then
		local valid = LuckSquare_CheckActivityIsValid()
		getglobal("ActivityFrameLuckSquareDate"):Show()
		local leftTimeText = ''
		if valid == 0 then
			leftTimeText = GetS(70791)
		elseif valid == 1 then
			local curActivity = LuckSquare_GetCurrentActivity()
			if curActivity then
				local end_time =  curActivity.end_time
				local leftTime = end_time - AccountManager:getSvrTime()
				if leftTime > 86400  then --天
					local day = math.floor(leftTime/86400)
					leftTimeText = GetS(70799)..GetS(70792,day)
				elseif leftTime < 86400 and leftTime > 3600 then --小时
					local hour = math.floor(leftTime/3600)
					leftTimeText = GetS(70799)..GetS(70793,hour)
				elseif leftTime < 3600 and leftTime > 60 then --分钟
					local minute = math.floor(leftTime/60)
					leftTimeText = GetS(70799)..GetS(70794,minute)
				else --秒
					leftTimeText = GetS(70799)..GetS(70795,leftTime)
				end
			end
		elseif valid == 2 then
			leftTimeText =  GetS(70796)
		end
		getglobal("ActivityFrameLuckSquareDate"):SetText(leftTimeText)
	else
		getglobal("ActivityFrameLuckSquareDate"):Hide()
	end
end

function LuckSquare_OnUpdate()
	if LuckSquare_data and LuckSquare_data.last_flush_energy_time > 0 then
		local time = LuckSquare_data.last_flush_energy_time - AccountManager:getSvrTime();
		local timeFont = getglobal("ActivityFrameLuckSquareStrengthLayerRestTitle")
		if time > 0 then
			timeFont:Show()
			local hour = math.floor(time/3600);
			local remain = time-hour*3600;
			local minute = math.floor(remain/60);
			local seconds = remain - minute*60;
			
			-- if hour > 0 and hour < 10 then
			-- 	hour = "0"..hour;
			-- end
			if minute >= 0 and minute < 10 then
				minute = "0"..minute;
			end
			if seconds >= 0 and seconds < 10 then
				seconds = "0"..seconds;
			end
			-- local text = hour..":"..minute..":"..seconds;
			local text = minute..":"..seconds;
			timeFont:SetText(string.format("%s" .. GetS(70660), text));
		else -- 增加体力
			timeFont:SetText("00:00" .. GetS(70660))
			LuckSquare_data.energy = math.min(LuckSquare_data.energy + 1, LuckSquare_data.max_energy)
			if LuckSquare_data.energy == LuckSquare_data.max_energy then
				LuckSquare_data.last_flush_energy_time = 0
				timeFont:Hide()
			else
				LuckSquare_data.last_flush_energy_time = LuckSquare_data.energy_flush_time + AccountManager:getSvrTime()
			end
			LuckSquare_UpdateStrengthTitle()
		end
	end

	LuckSquare_ShowActivityDate()
end

function LuckSquarePlayDesc_OnClick() -- 点玩法说明
	GetInst("UIManager"):Open("LuckSquarePlayDesc")
end
--[[
function LuckSquare_PlayAd(position_id, callBack, reportEventCallBackTbl)
	
	-- 广告播放完成回调
	local adPlayFinish = function (data)
		local position_id = (data and data.adPos) or position_id
		if IsAdUseNewLogic(position_id) then
			GetInst("AdService"):Ad_Finish(position_id, function(ad_info)
				local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
				statisticsGameEventNew(1302, id, position_id,"","","","","",GetCurrentCSRoomId())	
				AccountManager:ad_finish(position_id, {platform_id = id})
	
				if reportEventCallBackTbl.ad_complete then
					reportEventCallBackTbl.ad_complete()
				end
	
				if callBack then
					callBack()
				end
			end)
		else
			local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
			statisticsGameEventNew(1302, id, position_id,"","","","","",GetCurrentCSRoomId())	
			AccountManager:ad_finish(position_id, {platform_id = id})

			if reportEventCallBackTbl.ad_complete then
				reportEventCallBackTbl.ad_complete()
			end

			if callBack then
				callBack()
			end
		end		
	end

	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):Ad_StartPlay(position_id, function()
			local curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(position_id)
			ad_data_new.curADCallBack = adPlayFinish;
			ad_data_new.curAdCallData = {adPos = position_id}
			statisticsGameEventNew(1301, id, position_id,"","","",GetCurrentCSRoomId())
			if reportEventCallBackTbl.click then
				reportEventCallBackTbl.click()
			end
			local isSuccess = Advertisement:request(curWatchADType, id, position_id)
			if reportEventCallBackTbl.ad_play then
				reportEventCallBackTbl.ad_play()
			end
		end)
	else
		local curWatchADType, id = t_ad_data.getWatchADIDAndType(position_id);
		t_ad_data.curADCallBack = adPlayFinish;
		t_ad_data.curAdCallData = {adPos = position_id}
		statisticsGameEventNew(1301, id, position_id,"","","",GetCurrentCSRoomId())
		if reportEventCallBackTbl.click then
			reportEventCallBackTbl.click()
		end

		local isSuccess = Advertisement:request(curWatchADType, id, position_id)
		if reportEventCallBackTbl.ad_play then
			reportEventCallBackTbl.ad_play()
		end
	end
end
]]
-- bAd_free_button 是否弹窗界面点击观看广告
function LuckSquareFreePlayBtn_OnClick(bAd_free_button) -- 点广告闯关
	local valid = LuckSquare_CheckActivityIsValid()
	if valid == 0 then
		ShowGameTipsWithoutFilter(GetS(70797))
		return
	elseif  valid == 2 then
		ShowGameTipsWithoutFilter(GetS(70798))
		return
	end
	local programID = "LUCK_BOX_START"
	local componentID = "ad_button"
	if bAd_free_button then
		programID = "LACK_STRENGTH_SHOW"
		componentID = "ad_free_button"
	end
	if LuckSquare_data.watch_ad_times < LuckSquare_data.max_watch_ad_times then
		local isLoaded = false
		if IsAdUseNewLogic(LuckSquare_adposition) then	
			isLoaded = ad_data_new.getAdLoadStatus(LuckSquare_adposition)
		else
			isLoaded = t_ad_data.getAdLoadStatus(LuckSquare_adposition)
		end
		if isLoaded then
			OnReqWatchADLuckSquarePlayAd(LuckSquare_adposition, nil,{
				click = function()
					LuckSquare_ReportEvent(programID, componentID, "click", {standby1=LuckSquare_data.max_watch_ad_times-LuckSquare_data.watch_ad_times})
				end,
				ad_play = function()
					LuckSquare_ReportEvent(programID, componentID, "ad_play", {standby1=LuckSquare_data.max_watch_ad_times-LuckSquare_data.watch_ad_times})
				end,
				ad_complete = function()
					LuckSquare_ReportEvent(programID, componentID, "ad_complete", {standby1=LuckSquare_data.max_watch_ad_times-LuckSquare_data.watch_ad_times})
				end
			})
		else
			ShowGameTips(GetS(4977)) -- 广告还没准备好
		end
	else
		ShowGameTips(GetS(30120)) -- 今日广告次数已用完，明天再来吧
	end
end

function LuckSquarePlayBtn_OnClick() -- 点开始闯关
	local valid = LuckSquare_CheckActivityIsValid()
	if valid == 0 then
		ShowGameTipsWithoutFilter(GetS(70797))
		return
	elseif  valid == 2 then
		ShowGameTipsWithoutFilter(GetS(70798))
		return
	end
	if LuckSquare_data.energy > 0 then
		LuckSquare_ReportEvent("LUCK_BOX_START", "button", "click")
		LuckSquare_RequestEnterGame(true, 2)
	else
		-- 显示结果回调
		local canShowCallBack = function(result, ad_info)
			if result then
				local callback = function(btnName)
					if btnName == "left" then
						LuckSquareFreePlayBtn_OnClick(true)
					end
				end
				LuckSquare_ReportEvent("LACK_STRENGTH_SHOW", "-", "view")
				StrengthNotEnoughMsgBox(
					{
						note = GetS(70696),
						title = GetS(70697),
						btnString = GetS(70662),
						callback = callback,
					}
				)
			else
				ShowGameTips(GetS(1571)) -- 体力值不足！
			end
		end
		if IsAdUseNewLogic(LuckSquare_adposition) then	
			GetInst("AdService"):IsAdCanShow(LuckSquare_adposition, canShowCallBack)			
		else
			canShowCallBack(t_ad_data.canShow(LuckSquare_adposition, nil, true))
		end
	end
end

function LuckSquareContinueBtn_OnClick() -- 继续闯关
	LuckSquare_ReportEvent("LUCK_BOX_START", "continue_button", "click")
	local valid = LuckSquare_CheckActivityIsValid()
	if valid == 0 then
		ShowGameTipsWithoutFilter(GetS(70797))
		return
	elseif  valid == 2 then
		ShowGameTipsWithoutFilter(GetS(70798))
		return
	end

	LuckSquare_EnterGame()
end

--检查活动是否过期
-- 0 未开始 1 进行中 2，已结束
function LuckSquare_CheckActivityIsValid()
	local valid = 0
	if ns_luck_square_config.activity and next(ns_luck_square_config.activity) then
		local sortActivity = {}
		--先排序
		for _, value in pairs(ns_luck_square_config.activity) do
			table.insert(sortActivity,value)
		end
		table.sort(sortActivity,function (a, b) return a.start_time < b.start_time end)
		local count = #sortActivity or 0 
		for index, value in ipairs(sortActivity) do
			local start_time =  value.start_time
			local end_time =  value.end_time
			if start_time and end_time and AccountManager:getSvrTime() >= start_time and AccountManager:getSvrTime() <= end_time then
			  	valid = 1
			elseif AccountManager:getSvrTime() > end_time then
				if index == count then
					valid = 2
				end
			end	
		end
	end
	return valid
end

-- 幸运盲盒埋点
function LuckSquare_ReportEvent(programID, componentID, event_code, ext)
	standReportEvent("2104", programID, componentID, event_code, ext)
end

function LuckSquare_RequestInfo(needshowload)
	getglobal("ActivityFrameLuckSquare"):Hide()
	local get_luck_square_info_CallBack = function (ret)
		if getglobal("LuckSquareBtn"):IsChecked() then
			ShowLoadLoopFrame(false)
		end

		-- print("LuckSquare_RequestInfo ret", ret);

		if ret and ret.ret == 0 and ret.data then
			if getglobal("LuckSquareBtn"):IsChecked() then
				LuckSquare_ReportEvent("LUCK_BOX_START", "-", "view")
				LuckSquare_UpdateUI(ret.data)
			end
		else
			if ret then
				ShowGameTips(GetS(ret.ret))
				-- print("LuckSquare_RequestInfo error ret:", ret.ret);
			end
		end
	end
	if needshowload then
		ShowLoadLoopFrame(true, "file:activity -- func:LuckSquare_RequestInfo")
	end
	local temp_url = g_http_root .. "miniw/welfare?"
	local reqParams = {
		act = "lucky_block_data",
	}
	local paramStr, md5 = http_getParamMD5(reqParams)
	temp_url = temp_url .. paramStr .. '&md5=' .. md5
	ns_http.func.rpc(temp_url, get_luck_square_info_CallBack, nil, nil, false, true)
end

-- 幸运方块闯关请求回调：观看广告免费、使用体力
function LuckSquare_RequestEnterGameCB(ret)
	print("LuckSquare_RequestEnterGameCB ret = ", ret);
	if getglobal("LuckSquareBtn"):IsChecked() then
		ShowLoadLoopFrame(false)
	end
	if ret and ret.ret == 0 and ret.data then
		local data = ret.data
		LuckSquare_data.energy = data.energy
		LuckSquare_data.last_flush_energy_time = data.last_flush_time
		LuckSquare_data.layer = 1 -- 关卡为1
		LuckSquare_updateAdEnterGameBtn()
		LuckSquare_UpdateStrengthTitle()
		LuckSquare_CheckGameStatus()
		LuckSquare_EnterGame()
	elseif ret then
		ShowGameTips(GetS(ret.ret))
	end
end
-- 幸运方块闯关请求回调：nType 1:看广告后开始 2:使用体力
function LuckSquare_RequestEnterGame(needshowload, nType)
	print("LuckSquare_RequestEnterGame nType = ", nType)
	if needshowload then
		ShowLoadLoopFrame(true, "file:activity -- func:LuckSquare_RequestEnterGame")
	end
	local temp_url = g_http_root .. "miniw/welfare?"
	local reqParams = {
		act = "lucky_block_enter",
		type = nType
	}
	local paramStr, md5 = http_getParamMD5(reqParams)
	temp_url = temp_url .. paramStr .. '&md5=' .. md5
	ns_http.func.rpc(temp_url, LuckSquare_RequestEnterGameCB, nil, nil, ns_http.SecurityTypeHigh, true)
end

function LuckSquare_UpdateStrengthTitle() -- 更新体力
	local strengthTitle = getglobal("ActivityFrameLuckSquareStrengthLayerTitle") -- 当前体力值
	strengthTitle:SetText(string.format("%d/%d", LuckSquare_data.energy, LuckSquare_data.max_energy))
end

function LuckSquare_EnterGame() 
	GetInst("UIManager"):Close("LuckSquareGame")
	GetInst("UIManager"):Open("LuckSquareGame", LuckSquare_data)
	LuckSquare_ReportEvent("LUCK_BOX_GAMEING", "-", "view")
end

function LuckSquare_CheckGameStatus() -- 检查当前游戏状态
	if LuckSquare_data.layer > 0 then -- 在游戏中
		getglobal("ActivityFrameLuckSquareFreePlayBtn"):Hide()
		getglobal("ActivityFrameLuckSquarePlayBtn"):Hide()
		getglobal("ActivityFrameLuckSquareContinueBtn"):Show()
	else 
		-- 未开始游戏
		getglobal("ActivityFrameLuckSquarePlayBtn"):Show()
		getglobal("ActivityFrameLuckSquareContinueBtn"):Hide()
		getglobal("ActivityFrameLuckSquareFreePlayBtn"):Hide()

		if IsAdUseNewLogic(LuckSquare_adposition) then
			GetInst("AdService"):IsAdCanShow(LuckSquare_adposition, function(result, ad_info)
				if result then
					getglobal("ActivityFrameLuckSquareFreePlayBtn"):Show()
				end
			end)
		else
			if t_ad_data.canShow(LuckSquare_adposition, nil, true) then
				getglobal("ActivityFrameLuckSquareFreePlayBtn"):Show()
			end
		end
	end
end

function LuckSquare_updateAdEnterGameBtn() -- 更新广告进入按钮
	local freePlayBtnText = getglobal("ActivityFrameLuckSquareFreePlayBtnText")
	-- freePlayBtnText:SetText(GetS(70662, LuckSquare_data.watch_ad_times, LuckSquare_data.max_watch_ad_times))
	freePlayBtnText:SetText(GetS(70662))
end

function LuckSquare_UpdateUI(ret)
	getglobal("ActivityFrameLuckSquare"):Show()
	getglobal("ActivityFrameLuckSquareStrengthLayerRestTitle"):Hide()
	-- layer = data.layer,                             --当前多少关
	-- energy = data.energy,                           --当前体力值
	-- last_flush_energy_time = data.last_pick_time,   --上次获得体力时间
	-- play_times = data.play_times,                   --今日剩余次数
	-- items = data.items,                             --当前拥有的奖励列表
	-- is_alive = data.is_alive,                       --当前拥有的祝福（true为当前拥有祝福）
	-- watch_ad_times = data.watch_times,              --当日通过广告进入的次数
	-- last_pick_type = data.last_pick_type,           --上次抽中的类型	
	-- is_monkey = data.is_monkey,                     --当前抽中的是猴子（true为当前抽中的是猴子）

	LuckSquare_data = ret
	LuckSquare_data.max_energy = ns_luck_square_config.max_energy -- 体力最大上限值(读配置表)
	LuckSquare_data.max_watch_ad_times = ns_luck_square_config.max_watch_ad_times -- 广告观看最大次数(读配置表)
	LuckSquare_data.energy_flush_time = ns_luck_square_config.energy_flush_time -- 刷新体力时间(读配置表)
	-- LuckSquare_data.last_flush_energy_time = AccountManager:getSvrTime() + LuckSquare_data.energy_flush_time -- test

	-- 埋点位 position_id 广告按钮曝光
	local curWatchADType, id
	if IsAdUseNewLogic(LuckSquare_adposition) then	
		curWatchADType, id = GetInst("AdService"):GetAdTypeByAdId(LuckSquare_adposition)
	else
		curWatchADType, id = t_ad_data.getWatchADIDAndType(LuckSquare_adposition);
	end
	statisticsGameEventNew(1300, id or "", LuckSquare_adposition,"","","",GetCurrentCSRoomId());

	LuckSquare_updateAdEnterGameBtn()
	LuckSquare_UpdateStrengthTitle()
	LuckSquare_CheckGameStatus()
	LuckSquare_ShowBackgroundImage()--更新背景
end
-----------------------------------------------------------------------------------------

function GetGameRewardFrame()
	return GameRewardFrame
end

function SetGameRewardFrame(value)
	GameRewardFrame = value
end

function BirthdayGotoBtn_OnClick()
	if BirthdayPartyMgr then
		BirthdayPartyMgr:ShowRightView()
	end
end