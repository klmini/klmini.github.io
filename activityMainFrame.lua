--活动主页面
ActivityMainFrame = {}
ActivityMainFrame.__index = ActivityMainFrame

--由UI触发的逻辑，将逻辑放到CTRL处理
function ActivityMainFrame:OnLoad()
	getglobal("ActivityMainFrameBkg"):SetPoint("center","ActivityMainFrame","center", 56, 2)
	ActivityMainCtrl:Load()
end

function ActivityMainFrame:OnShow()
	if IsShowFguiMain() then
		standReportEvent("2", "CONTAINER", "-", "view")
	else
		standReportEvent("21", "ACTIVITIES_TOP", "-", "view")
		standReportEvent("21", "ACTIVITIES_TOP", "Close", "view")
		local tb = {
			"-",
			"FeaturedContent",
			"AvtivityContent",
			"BonusContent",
			"AnnouncementContent"		
		}
		for _, value in ipairs(tb) do
			standReportEvent("21", "ACTIVITIES_CONTAINER", value, "view")
		end

		-- standReportEvent("21", "ACTIVITIES_CONTAINER", "-", "view")
	end

	self:UpdateFirstTabRef()

	ActivityMainCtrl:Active();
end

--更新一级标签相关
function ActivityMainFrame:UpdateFirstTabRef()
	-- ActivityMainFrameTypeBtn1...5 --对应顺序：公告 活动 福利 精选 特权
	local btnPosYTab = {342, 174, 258, 90, 426} --默认顺序是 精选 活动 福利 公告 特权(不显示)
	local privilegeBtnShow = false

	if IsShowFguiMain() then
		if IsGuanBanFuliBtnCanShow() then
			--新界面 并且是官版 显示特权
			btnPosYTab = {426, 90, 258, 174, 342} --新顺序：活动 精选 福利 特权 公告
			privilegeBtnShow = true
		else
			--新界面 不是官版 不显示特权
			btnPosYTab = {342, 90, 258, 174, 426} --新顺序：活动 精选 福利 公告
			privilegeBtnShow = false
		end
	end

	if self.tabInfo and self.tabInfo[5] and getglobal(self.tabInfo[5].uiName) then
		if privilegeBtnShow then
			getglobal(self.tabInfo[5].uiName):Show()
		else
			getglobal(self.tabInfo[5].uiName):Hide()
		end
	end

	for i=1, #self.tabInfo do
		local btn = getglobal(self.tabInfo[i].uiName)
		if btn then
			btn:SetPoint("topright","ActivityMainFrameBkg","topleft", 6, btnPosYTab[i])
		end
	end
end

function ActivityMainFrame:BackBtnOnClick()
	standReportEvent("21", "ACTIVITIES_TOP", "Close", "click")
	getglobal("MItemTipsFrame"):Hide();
	ActivityMainCtrl:AntiActive()
	setkv("marketactivity_looked"..tostring(AccountManager:getUin()),ActivityMainCtrl.marketactivity_looked)
end

function ActivityMainFrame:TypeBtnOnClick(id)
	local index;
	if id then
		index = id;
	else
		index = this:GetClientID();
	end
	print("ActivityMainFrame:TypeBtnOnClick(): id = ", id);
	print("ActivityMainFrame:TypeBtnOnClick(): index = ", index);

	if IsShowFguiMain() then
		--index 对应的顺序是：--公告 活动 福利 精选 特权
		--一个click
		local clickTab = 
		{
			"NoticeTab",
			"ActivitiesTab",
			"BenefitTab",
			"NewsTab",
			"PrivilegeTab"
		}
		standReportEvent("2", "CONTAINER", clickTab[index], "click")
	else
		local tb = {
			"AnnouncementContent",
			"AvtivityContent",
			"BonusContent",
			"FeaturedContent",
		}
		
		-- standReportEvent("21", "ACTIVITIES_CONTAINER", tb[index], "view")
		if self.tabBtns[index] and self.tabBtns[index].redTag and self.tabBtns[index].redTag:IsShown() then
			standReportEvent("21", "ACTIVITIES_CONTAINER", tb[index], "click",{standby1=1}) --1 有红点，0 无红点
		else
			standReportEvent("21", "ACTIVITIES_CONTAINER", tb[index], "click",{standby1=0})
		end

	end
	threadpool:work(function()
		local ret = ActivityMainCtrl:UpdateWelfareConfig();
		end
	)
	ActivityMainCtrl:SelectType(index)

	if ActivityMainCtrl.def.isConfigWelfareAD then
		threadpool:work(function()
			local ret = ActivityMainCtrl:UpdateWelfareConfig();
			if ret and not ActivityMainCtrl.def.isShowWelfareAD then
				local curType = ActivityMainCtrl.data.curType
				ActivityMainCtrl.data.curType = 1
				ActivityMainCtrl:SelectType(curType,true)
			end
		end)
	end
end
-------------------------------------------------------
--由CTRL触发的页面操作

--关闭页面
function ActivityMainFrame:Close()
	if self.frame then
		for i = 1,#self.tabBtns do 
			local btns = self.tabBtns[i];
			btns.btn:SetChecked(false);
			btns.btn:Enable();
		end 
		self.frame:Hide()
		self:HideAllChildFrame()
		ns_td_exposure_click.report_all();
	end 
end

--初始化页面
function ActivityMainFrame:Init()
	self.ctrl = ActivityMainCtrl

	self.frame = getglobal("ActivityMainFrame")

	self.titleIcon = getglobal("ActivityMainFrameTitleIcon")
	self.titleText = getglobal("ActivityMainFrameTitleName")

	self.tabBtns = {}
	for i = 1,self.ctrl.def.typeCount do 
		local btn = getglobal("ActivityMainFrameTypeBtn" .. i)
		local name = getglobal("ActivityMainFrameTypeBtn" .. i .. "Name")
		local redTag = getglobal("ActivityMainFrameTypeBtn" .. i .. "RedTag")
		table.insert(self.tabBtns,
		{
			btn = btn,
			name = name,
			redTag = redTag,
		})
	end
	self.tabInfo ={
		{uiName="ActivityMainFrameTypeBtn1", nameID = 3449}, 
		{uiName="ActivityMainFrameTypeBtn2", nameID = 3451},
		{uiName="ActivityMainFrameTypeBtn3", nameID = 3450}, 
		{uiName="ActivityMainFrameTypeBtn4", nameID = 3816},
		{uiName="ActivityMainFrameTypeBtn5", nameID = 1110500},
	}

	-- todo 这里没用了
	self.titleImgs = {}
	table.insert(self.titleImgs,{xml = "ui/mobile/texture2/common_icon.xml",uv = "icon_notice"})
	table.insert(self.titleImgs,{xml = "ui/mobile/texture2/common_icon.xml",uv = "icon_08"})
	table.insert(self.titleImgs,{xml = "ui/mobile/texture2/common_icon.xml",uv = "icon_giftback"})
	table.insert(self.titleImgs,{xml = "ui/mobile/texture2/common_icon.xml",uv = "icon_giftback"})

	self.childFrames = 
	{
		getglobal("AdvertFrame"),
		getglobal("ActivityFrame"),
		getglobal("MarketActivityFrame"),
		getglobal("SiftFrame"),
		getglobal("OfficialRewardCenterNew"),
	}
end

--更新页签
function ActivityMainFrame:UpdateTab(selectType)
	--local print = Android:Localize();
	print("ActivityMainFrame:UpdateTab(): selectType = ", selectType);
	TemplateTabBtn2_SetState(self.tabInfo, selectType)
	print("ActivityMainFrame:UpdateTab(): #self.tabBtns = ", #self.tabBtns);
	for i = 1,#self.tabBtns do 
		local btns = self.tabBtns[i];
		print("ActivityMainFrame:UpdateTab(): i = ", i);
		print("ActivityMainFrame:UpdateTab(): btns.name = ", btns.name);
		if i == selectType then
			btns.btn:Disable(false);
		else
			btns.btn:Enable(false);
		end
	end 
end

--更新标题(公告和福利的标题是从服务端读取的)
function ActivityMainFrame:UpdateTitle(data)
    if data == nil then return end
	local selectType = data.curType
	if selectType == nil then return end 
	local title = ""
	--self.titleIcon:SetTextureHuiresXml(self.titleImgs[selectType].xml) -- TODO
    --self.titleIcon:SetTexUV(self.titleImgs[selectType].uv)
    if selectType == self.ctrl.def.type.notice and data.typeData[selectType] then	
    	title = data.typeData[selectType].title
    elseif selectType == self.ctrl.def.type.activity then 
    	title = GetS(3451)
 	elseif selectType == self.ctrl.def.type.welfare then 
 		title = GetS(3450)
	elseif selectType == self.ctrl.def.type.sift then
		title = GetS(32515)
	elseif selectType == self.ctrl.def.type.privilege then
		title = GetS(24000)
	end

    self.titleText:SetText(title)
end

--展示子类型活动
function ActivityMainFrame:ShowActivityByType(data,isStatistic)
	--local print = Android:Localize();
	--[[
	Author: sundy
	EditTime: 2021-08-21
	Description: 切换页时清掉广告的回调
	另一处 MAFFuli_OnClick()
	--]]
	ns_ma.ad_positon_call_pool = {}
	local selectType = data.curType
	print("ShowActivityByType(): selectType = ", selectType);
	local typeData = data.typeData[selectType]
	-- print("ShowActivityByType(): typeData = ", typeData);
	print("ShowActivityByType(): self.ctrl.def.type.notice = ", self.ctrl.def.type.notice);
	print("ShowActivityByType(): self.ctrl.def.type.activity = ", self.ctrl.def.type.activity);
	print("ShowActivityByType(): self.ctrl.def.type.welfare = ", self.ctrl.def.type.welfare);
	getglobal("MItemTipsFrame"):Hide();
	if selectType == self.ctrl.def.type.notice then 
		--重置UI
		ns_advert.func.resetMAUI()
		--统计
		-- if isStatistic then 
		-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "OpenADBtn")
		-- end 
		--显示页面
		self:ShowChildFrame(selectType)
	elseif selectType == self.ctrl.def.type.activity then
		--刷新签到奖励页面
		ns_activity.func.resetMAUI();
		--统计
		if not isStatistic and not ClientMgr:isPC() then
			if IsAdUseNewLogic(10) then
				GetInst("AdService"):IsAdCanShow(10, function(result, ad_info)
					if result then
						OnReqWatchADActivityFrame()
					end
				end)
			else
				if t_ad_data.canShow(10) then
					OnReqWatchADActivityFrame()
				end
			end
			-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "OpenACTBtn")	
		end
		--显示页面
		self:ShowChildFrame(selectType)
		--重置红点
		self.ctrl:CheckRedTagForActivity()
		self:UpdateRedTagByType(self.ctrl.data.redTag,self.ctrl.def.type.activity,self.ctrl.data.typeData)
		--[[
		-- PC10号活动插屏广告已弃用
		if ClientMgr:isPC() then
			local position_id = 10
			if IsAdUseNewLogic(position_id) then	
				GetInst("AdService"):IsAdCanShow(position_id, function(result, ad_info)
					if result then
						if AccountManager.ad_show then
							AccountManager:ad_show(position_id);
						end
						GetInst("AdService"):Ad_Show(position_id)
						GetInst("UIManager"):Open("PcAdvertisement", {from = "activity"})
					end
				end)
			else
				if  t_ad_data.canShow(10) then
					if AccountManager.ad_show then
						AccountManager:ad_show(10);
					end
					GetInst("UIManager"):Open("PcAdvertisement",{from = "activity"})
				end
			end
		end
		--]]
	elseif selectType == self.ctrl.def.type.welfare then 
		--重置UI
		ns_ma.open_cell_id = nil
		ns_ma.func.resetMAUI()
		if not isStatistic then
			for i=1, ns_ma.fuli_tab_max do
				if ns_ma.server_config[i] then
					standReportEvent("21", "BONUS_CONTENT", "ActivityPit", "view", {slot=i,cid=ns_ma.server_config[i].id,ctype=2,standby1 = ns_ma.server_config[i].title})
				end
			end
			standReportEvent("21", "BONUS_CONTENT", "-", "view")
			-- standReportEvent("21", "BONUS_CONTENT", "ActivityDisplay", "view", {slot=1,cid=ns_ma.server_config[1].id,ctype=2})
		end
		--统计
		-- if isStatistic then 
			if t_ad_data.canShow(11) then
				OnReqWatchADMarketActivity()
			end
			-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "OpenMABtn")
		-- end 
		--显示页面
		-- print("ShowActivityByType(): ns_ma.server_config = ", ns_ma.server_config);
		print("ShowActivityByType(): tostring(ns_ma.server_config) = ", tostring(ns_ma.server_config));
		if  ns_ma.server_config and #ns_ma.server_config > 0 then
			self:ShowChildFrame(selectType)
		else
			ShowGameTips(GetS(442), 3)
		end
		--重置红点
		self.ctrl:CheckRedTagForWelfare()
		self:UpdateRedTagByType(self.ctrl.data.redTag,self.ctrl.def.type.welfare,self.ctrl.data.typeData)
	elseif selectType == self.ctrl.def.type.sift then
		ns_sift.func.resetMAUI()
		-- statisticsGameEventNew(1701, get_game_lang());
		if  ns_sift and ns_sift.content_list and #ns_sift.content_list > 0 then
			if not isStatistic then
				standReportEvent("21", "FEATURED_CONTENT", "-", "view")
				for i=1, #ns_sift.content_list do
					standReportEvent("21", "FEATURED_CONTENT", "ActivityPit", "view", {slot=i,cid=ns_sift.content_list[i].id,ctype=2,standby1 = ns_sift.content_list[i].title})
				end
			end
			self:ShowChildFrame(selectType)
			--self.ctrl:CheckRedTag();
		else
		end
	elseif selectType == self.ctrl.def.type.privilege then
		self:ShowChildFrame(selectType)
	end
end

--显示子页面
function ActivityMainFrame:ShowChildFrame(selectType)
	--local print = Android:Localize();
	print("ActivityMainFrame:ShowChildFrame(): selectType = ", selectType);
	for i = 1,#self.childFrames do 
		print("ActivityMainFrame:ShowChildFrame(): i = ", i);
		print("ActivityMainFrame:ShowChildFrame(): self.childFrames[i]:GetName() = ", self.childFrames[i]:GetName());
		if i == selectType then 
			if selectType == self.ctrl.def.type.privilege then
				GetInst("UIManager"):Open("OfficialRewardCenterNew")
			else
				self.childFrames[i]:Show()
			end
		else
			if i == self.ctrl.def.type.privilege then
				GetInst("UIManager"):Close("OfficialRewardCenterNew")
			else
				self.childFrames[i]:Hide()
			end
		end 
	end 
end

--隐藏所有子页面
function ActivityMainFrame:HideAllChildFrame()
	for i = 1,#self.childFrames do 
		if i == self.ctrl.def.type.privilege then
			GetInst("UIManager"):Close("OfficialRewardCenterNew")
		else
			self.childFrames[i]:Hide()
		end
	end 
end

--更新所有红点提示
function ActivityMainFrame:UpdateRedTag(redTagData,typeData)
	if self.ctrl then
		self:UpdateBtnRedTag(redTagData)
		self:UpdateTabRedTag(redTagData)
		for i = 1,self.ctrl.def.typeCount do 
			self:UpdateRedTagByType(redTagData,i,typeData)
		end 
	end 
end

--更新主按钮的红点提示
function ActivityMainFrame:UpdateBtnRedTag(redTagData)
	local haveRedTag = false
	for i = 1,self.ctrl.def.typeCount do 
		local aRedTagData = redTagData[i]
		for k,v in pairs(aRedTagData) do 
			if v then
				haveRedTag = true 
				break
			end 
		end 
	end 
	if haveRedTag then 
		getglobal("GongNengFrameActivityGNBtnRedTag"):Show()
		-- getglobal("MiniLobbyFrameTopActivityRedTag"):Show()
		ShowMiniLobbyActivityRedTag() --mark by hfb for new minilobby
	else
		getglobal("GongNengFrameActivityGNBtnRedTag"):Hide()
		-- getglobal("MiniLobbyFrameTopActivityRedTag"):Hide()
		HideMiniLobbyActivityRedTag() --mark by hfb for new minilobby
	end 
	if if_showOppoVivoRedTag() then
		-- getglobal("MiniLobbyFrameTopChannelRewardBtnRedTag"):Show()
		ShowMiniLobbyChannelRewardRedTag() --mark by hfb for new minilobby
	else
		-- getglobal("MiniLobbyFrameTopChannelRewardBtnRedTag"):Hide()
		HideMiniLobbyChannelRewardRedTag() --mark by hfb for new minilobby
	end
end

--更新页签红点提示
function ActivityMainFrame:UpdateTabRedTag(redTagData)
	for i = 1,self.ctrl.def.typeCount do
		local haveRedTag = false  
		local aRedTagData = redTagData[i]
		for k,v in pairs(aRedTagData) do 
			if v then
				haveRedTag = true
				break 
			end
		end

		if haveRedTag then 
			getglobal("ActivityMainFrameTypeBtn" .. i .. "RedTag"):Show()
			--getglobal("ActivityMainFrameTypeBtn" .. i .. "CheckedRedTag"):Show()
		else
			getglobal("ActivityMainFrameTypeBtn" .. i .. "RedTag"):Hide()
			--getglobal("ActivityMainFrameTypeBtn" .. i .. "CheckedRedTag"):Hide()
		end 
	end 
end

--更新子类型活动的红点提示
function ActivityMainFrame:UpdateRedTagByType(redTagData,selectType,typeData)
	if not redTagData then
		return;
	end
	local typeRedTagData = redTagData[selectType]
	local typeData = typeData[selectType]
	if selectType == self.ctrl.def.type.notice then 
		--公告暂时没有红点显示
	elseif selectType == self.ctrl.def.type.activity then 
		if typeData then
			for i = 1,#typeData do 
				local aActivityBtnRedTag = getglobal(typeData[i].Name.."BtnRedTag")
				if typeRedTagData[i] then 
					if i == 3 then
						-- getglobal("MiniLobbyFrameTopActivityRoomBoxSignBtnRedTag"):Show()
						ShowMiniLobbyRoomBoxSignRedTag() --mark by hfb for new minilobby
					elseif i == 8 then
						-- getglobal("MiniLobbyFrameTopActivityRoomBoxTreasuryBtnRedTag"):Show()
						ShowMiniLobbyRoomBoxTreasuryRedTag() --mark by hfb for new minilobby
					end 
					aActivityBtnRedTag:Show()
				else
					if i == 3 then
						-- getglobal("MiniLobbyFrameTopActivityRoomBoxSignBtnRedTag"):Hide()
						HideMiniLobbyRoomBoxSignRedTag() --mark by hfb for new minilobby
					elseif i == 8 then
						-- getglobal("MiniLobbyFrameTopActivityRoomBoxTreasuryBtnRedTag"):Hide()
						HideMiniLobbyRoomBoxTreasuryRedTag() --mark by hfb for new minilobby
					end 
					aActivityBtnRedTag:Hide()
				end 
			end 
		end
	elseif selectType == self.ctrl.def.type.welfare then 
		for i = 1,self.ctrl.def.typeWelfareCount do
		 	local aWelfareBtnRedTag = getglobal( "MarketActivityFrameFuli" .. i .. "BtnRedTag")
		 	if typeRedTagData[i] then 
				 aWelfareBtnRedTag:Show()
				--  getglobal("MiniLobbyFrameTopActivityRoomBoxWelfareBtnRedTag"):Show()
				ShowMiniLobbyRoomBoxWelfareRedTag() --mark by hfb for new minilobby
		 	else
				 aWelfareBtnRedTag:Hide()
				--  getglobal("MiniLobbyFrameTopActivityRoomBoxWelfareBtnRedTag"):Hide()
				HideMiniLobbyRoomBoxWelfareRedTag() --mark by hfb for new minilobby
		 	end 
		end 
	elseif selectType == self.ctrl.def.type.sift then
		--精选类型红点不在这判断
	end
end

function ActivityMainFrame:tabIsHaveRedPoint(index)
	if self.tabBtns and self.tabBtns[index] and self.tabBtns[index].redTag and self.tabBtns[index].redTag:IsShown() then
		return true
	end
	return false
end
