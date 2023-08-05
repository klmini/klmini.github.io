-----------------------------新版个人中心-----------------------------
local PEC_MaxMaps = 20;				--存档地图最大数量
local PEC_CollectMaxMaps = 100;					--收藏地图显示的最大数量
local PEC_ConnoisseurMaxMaps = 100;
PEC_FromJumpFrameName = "";  --跳转进个人中心之前的界面
local PEC_JumpToFrameName = "";  --跳转出去的界面名称
local PEC_DynamicJumpOut = false;  --从个人中心跳转出去标志位
local statisticsType = 1 ;  --上报进入个人中心字段，0-自己，1-他人
local IsAchieveNeedInit = true
local IsFirstShowSkinModel = false
local VIP_ICON_WIDTH = 22 -- VIP图片的宽度
local mapListColumn = 4
local MapListCell_TemplateName = "ExhibitionMapArchiveTemplate"
local MapList_Name = "ExhibitionMapFramePage1"

local FingerScale = 1
local ScaleSpeed = 0.1;

local PreEnterMainMenuBy = nil

local InitMountViewAngle = 0

 t_exhibition ={ -- 基本信息展示
	is_three_version = false,	-- 当前第三版标识

	uin = nil,
	isHost = true,		--玩家自身

	retPool ={},		--玩家信息缓存池
	net_ok =false,		--网络情况
	self_data_dirty =false, 	--需要重新拉取自己数据

	close_upload = 1,   ---相册上传控制开关

	black = 0, --封号标识 black1 = 1 为封号
	playerinfo = {},
	closeCallBackFunc = nil, --关闭界面后. 执行的回调函数

	creatorInfo = nil,		--创作者相关信息
	--------------------------玩家心情--------------------------
	mood_icon = "";
	mood_icon_select = "";		--准备修改的值
	mood_icon_last = "";		--上一个
	mood_text = "";
	mood_text_select = "";

	--------------------------头像框--------------------------
	head_frame_read_cache = 0;   --是否已经读取过cache
	-- head_frame_id         = 1;   --玩家现在使用的头像框id	--头像框的值放在了"playerinfo"中
	-- head_frame_id_select  = 1;   --玩家准备修改的值
	head_max 			  = 100;  --一个栏目下最大头像数字
	head_select = {};
	headIndexFile   	  = "";        --玩家头像文件

	head_select_type    = 1;     --玩家现在所在的头像分类
	upload_photo_index  = 0;     --玩家现在所上传的文件index
	add_photo_index     = 0;     --add按钮所在的位置
	head_unlock     	= 0;         --玩家是否已经解锁头像 0=未解锁 1=解锁

	--------------------------性别--------------------------
	gender_select = 0;

	--------------------------优先展示----------------------
	first_ui = 1;	--1: 地图 2:动态 3:相册
	first_ui_select = 1;

	--------------------------是否可评论--------------------------
	open_comment = 1;	--0:不可 1:可
	open_comment_select = 1;

	--------------------------评论权限和查看权限--------------------------
	auth_rep = 2;
	auth_see = 0;
	auth_skin = 0;

	--------------------------当前模型信息（为防止模型野指针）---------------
	curBodyInfo = 
	{
		bodyType = 0,
		bodyId = 0,
	},
	--最佳拍档开关
	bestpartner_switch = 1;
	--------------------------举报相关--------------------------
	has_requested = {}, -- 外部调用自己判断
	uin_to_profile_black_stat = {},

	-- 个人中心第三版开关
	isThreeVerOpen = function (self)
		return self.is_three_version
	end,

	-- AB实验上架，配置关闭
	-- AB实验下架，配置根据实验效果打开或者关闭
	parseSwitch = function (self)
		local realSwitch = false
		print("parseSwitch start!")
		-- if SetAndGetABTest and SetAndGetABTest("exp_gf_home_personal") then
		-- 	print("parseSwitch abtest!")
		-- 	-- 中桶
		-- 	realSwitch = true
		-- else
			print("parseSwitch config!")
			realSwitch = self:parseVersionSwitch()
		-- end

		-- 目前关闭
		self.is_three_version = realSwitch
		print("ParseSwitch realSwitch", realSwitch)
	end,

	-- 解析新版个人中心开关
	parseVersionSwitch = function (self)
		-- 开关 && 渠道号 && 版本
		print("ns_version.profile_revision ", ns_version.profile_revision )
		if not ns_version.profile_revision then 
			return false
		end

		return check_apiid_ver_conditions(ns_version.profile_revision.switch)
	end,

	-- 个人中心UI名
	getUiName = function(self)
		local uiName = "PlayerExhibitionCenter"
		return uiName
	end,

	-- 个人中心心情发表UI名
	getMoodUiName = function(self)
		local uiName = "MoodPublishFrame"
		-- if self:isThreeVerOpen() then
		-- 	uiName = "PlayerCenterDataEditPage1MoodFrame"
		-- end
		return uiName
	end,
	
	-- 个人中心模型展示UI名
	getModelViewUiName = function(self)
		local uiName = "PlayerExhibitionCenterModeViewRoleView"
		-- if self:isThreeVerOpen() then
		-- 	uiName = "PlayerExhibitionCenterModelFrameModeViewRoleView"
		-- end
		return uiName
	end,
	getModelView1UiName = function(self)
		local uiName = "PlayerExhibitionCenterModeViewRole1View"
		-- if self:isThreeVerOpen() then
		-- 	uiName = "PlayerExhibitionCenterModelFrameModeViewRoleView"
		-- end
		return uiName
	end,

	-- 个人中心新版上报
	NewStandReport = function(self, cID, oID, evCode, evTb)
		if self:isThreeVerOpen() then
			standReportEvent("7", cID, oID, evCode, evTb)
		end
	end,

	init = function (uin)
		if uin<1000 or uin>=ns_const.__INT32__ then return end
		t_ExhibitionCenter:initTab()
		t_exhibition.uin = uin;
		t_exhibition.net_ok = false;
		local achieveCanShow = UIAchievementMgr:AchieveModuleCanShow(); --根据配置文件判断成就模块是否显示
		if achieveCanShow then
			UIAchievementMgr:GetRedTagState(t_exhibition.uin);
		else
			getglobal("ExhibitionInfoPage4"):Hide();
		end

		-- 初始化新版模型
		-- if t_exhibition:isThreeVerOpen() then
		-- 	t_ExhibitionModelView:Init(t_exhibition.uin)
		-- end

		local cardTb = {
			{
				"PERSONAL_INFO_TOP",
				"PERSONAL_INFO_CONTAINER",
				-- "PERSONAL_INFO_HOMEPAGE"
			},
			{
				"PLAYER_INFO_TOP",
				"PLAYER_INFO_CONTAINER",
				-- "PLAYER_INFO_HOMEPAGE"
			}
		}
		local compTb = {
			{
				"-",
				"Help",
				"Close"
			},
			{
				"-",
				"HomePageContent",
				"MapContent",
				"UpdatesContent",
				"MedalContent",
			},
		}
		local isMy = 1
		if uin ~=  AccountManager:getUin() then
			isMy = 2
		end
		for index, cardid in ipairs(cardTb[isMy]) do
			for _, compid in ipairs(compTb[index]) do
				local tempTb = nil
				if isMy == 2 and index==1 and compid== "-" then
					tempTb = {standby1 = tostring(uin)}
				end
				standReportEvent(isMy == 1 and "7" or "43", cardid, compid, "view",tempTb)
			end
		end

		if uin ==  AccountManager:getUin() then
			t_exhibition.isHost=true;
			statisticsType = 0;
			standReportEvent("7", "PERSONAL_INFO_CONTAINER", "Settings", "view")
			--拉取权限设置
			ZoneGetRepandSeeAuthState();
			--拉取个人资产展示权限设置
			ZoneGetPlayerProfile();
			--拉取装扮图鉴展示权限设置
			ZoneGetPlayerDressupBook();
			--LLTODO:成就系统上报： 角色数量; 皮肤数量; 坐骑数量等(关闭商城页面的时候也检查)
			ArchievementGetInstance().func:checkStoreInfo();
			ArchievementGetInstance().func:checkHandbookCount();		--检查图鉴
			ArchievementGetInstance().func:checkTotalAdd_OnlyReport();	--累计上报缓存检测
			ArchievementGetInstance().func:checkLoginCount();			--成就系统上报:持续登录
		else
			t_exhibition.isHost=false;
			-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterEnterBtn");
			statisticsType = 1;
			standReportEvent("43", "PLAYER_INFO_TOP", "Report", "view")
		end

		-- statisticsGameEvent(705, "%d", statisticsType)
		--动态初始化
		ZoneDynamicInit(uin);	
		--获取profile
		PEC_GetPlayerProfileByUin(t_exhibition.uin);

		--个人中心上报
		if CanAddUinAsFriend(t_exhibition.uin) and  CanFollowPlayer(t_exhibition.uin) then
			-- statisticsGameEvent(709, "%%lls", "EnterPlayerCenterNotAttention")
		elseif  CanAddUinAsFriend(t_exhibition.uin) then
			-- statisticsGameEvent(708, "%%lls", "EnterPlayerCenterNotFriends")
		end

		if t_exhibition.isHost then
			MapDownloadReportMgr:SetPlayerCenterType(ReportDefine.PlayerCenterDefine.Oneself);
		else
			MapDownloadReportMgr:SetPlayerCenterType(ReportDefine.PlayerCenterDefine.Others);
		end

		--设置ui的显示与隐藏
		GetInst("GeniusMgr"):CheckAndResetMyGeniusRef()
		t_exhibition:ShowOrHideUI(t_exhibition.isHost)
		t_exhibition:ShowHideVersionUIBefore(t_exhibition.isHost)
	end,


	--显示或隐藏ui, 访问自己和访问别人有的ui显示不一样
	ShowOrHideUI = function(self, isHost)
		print("ShowOrHideUI:", isHost);
		local uiName = t_exhibition:getUiName()
		
		--1. 地图
		local mapBtn1Name = getglobal("ExhibitionMapFrameTabsTab1Name");	--作品
		local mapBtn2Name = getglobal("ExhibitionMapFrameTabsTab2Name");	--收藏
		local mapBtn3Name = getglobal("ExhibitionMapFrameTabsTab3Name");	

		--2. 动态
		local dynamicBtn1Name = getglobal("DynamicHandleFrameTabBtn1Name");	--动态
		local dynamicBtn2 = getglobal("DynamicHandleFrameTabBtn2");			--我的动态
		local dynamicBtn3 = getglobal("DynamicHandleFrameTabBtn3");			--最近回复
		local publishDynamic = getglobal("DynamicHandleFramePublishBtn");	--发布动态

		--个人中心云服入口
		local myServer = getglobal("PlayerExhibitionCenterLeftTabMyServer");	--发布动态

		local network = getglobal(uiName.."work")
		local reportBtn = getglobal(uiName.."ReportBtn");
		local setBtn = getglobal(uiName.."SetBtn");
		local moodBtn = getglobal(uiName.."MoodBtn");

		--检查一下是否需要做 天赋特长引导
		t_exhibition:CheckGeniusGuide()

		if isHost then
			print("查看自己的个人中心:");
			mapBtn1Name:SetText(GetS(20654));
			mapBtn2Name:SetText(GetS(20655));
			mapBtn3Name:SetText(GetS(1262));

			dynamicBtn1Name:SetText(GetS(20525));
			dynamicBtn2:Show();
			dynamicBtn3:Show();
			publishDynamic:Show();

			reportBtn:Hide();
			setBtn:Show();
			moodBtn:Show();

			if GetInst("GameHallDataManager"):CheckSupport() then
				myServer:Show();
			else
				myServer:Hide();
			end
		else
			print("查看别人的个人中心:")
			mapBtn1Name:SetText(GetS(20656));
			mapBtn2Name:SetText(GetS(20657));
			mapBtn3Name:SetText(GetS(1262));

			dynamicBtn1Name:SetText(GetS(20653));
			dynamicBtn2:Hide();
			dynamicBtn3:Hide();
			publishDynamic:Hide();

			reportBtn:Show();
			setBtn:Hide();
			moodBtn:Hide();
			network:SetPoint("left",uiName,"topleft",1100,30)

			myServer:Hide();
		end		

		--排序按钮名称
		local sortName = {GetS(524),GetS(6660429)}--{"默认", "最多游玩"}
		local sortBtn1Name = getglobal("ExhibitionMapFrameSortTabsTab1Name");	--按更新时间排序（默认）
		local sortBtn2Name = getglobal("ExhibitionMapFrameSortTabsTab2Name");	--按游玩次数排序
		sortBtn1Name:SetText(sortName[1]);
		sortBtn2Name:SetText(sortName[2]);
	end,

	-- 检测是否需要新特长引导
	CheckGeniusGuide = function(self)
		local isFirtTab = (curClickID and (curClickID==t_ExhibitionCenter.define.tabHome)) or false
		if t_exhibition.isHost and GetInst("GeniusMgr"):IsOpenGeniusSys() and GetInst("GeniusMgr"):CheckCanGuide(1) and isFirtTab then
			t_exhibition:SetGeniusGuideEntryGuideVisible(true)
		else
			t_exhibition:SetGeniusGuideEntryGuideVisible(false)
		end
	end,

	-- 播放特长入口引导动画
	PlayGeniusGuideEntryGuideAnim = function(self)
		local finger = getglobal("PlayerExhibitionCenterGeniusBtnFinger")
		
		if finger and finger:IsShown() then
			FingerScale = FingerScale + ScaleSpeed;
			if FingerScale > 1.2 then
				FingerScale = 1.2;
				ScaleSpeed = tonumber(arg1) and -arg1 * 0.5 or -0.05;
			elseif FingerScale < 1.0 then
				FingerScale = 1.0;
				ScaleSpeed = tonumber(arg1) and arg1 * 0.5 or 0.05;
			end
			local width = 121 * FingerScale;
			local height = 121 * FingerScale;
			finger:SetSize(width, height);
		end
	end,

	-- 新特长入口引导
	SetGeniusGuideEntryGuideVisible = function(self, bView)
		getglobal("PlayerExhibitionCenterGuide"):setUpdateTime(1/30)
		
		if bView then
			getglobal("PlayerExhibitionCenterGuide"):Show()
			getglobal("PlayerExhibitionCenterGuideMaskBkg"):SetColor(0,0,0,178)
			getglobal("PlayerExhibitionCenterGeniusBtnTipBg"):Show()
			getglobal("PlayerExhibitionCenterGeniusBtnTipBgArrow"):Show()
			getglobal("PlayerExhibitionCenterGeniusBtnTip"):Show()
			getglobal("PlayerExhibitionCenterGeniusBtnFinger"):Show()
		else
			getglobal("PlayerExhibitionCenterGuide"):Hide()
			getglobal("PlayerExhibitionCenterGeniusBtnTipBg"):Hide()
			getglobal("PlayerExhibitionCenterGeniusBtnTipBgArrow"):Hide()
			getglobal("PlayerExhibitionCenterGeniusBtnTip"):Hide()
			getglobal("PlayerExhibitionCenterGeniusBtnFinger"):Hide()
		end
	end,

	-- 版本显示隐藏UI （返回数据前）
	ShowHideVersionUIBefore = function(self, isHost)
		print("ShowHideVersionUIBefore:", isHost)
		
		local uiName 			= t_exhibition:getUiName()
		local ui_friendNum 		= getglobal(uiName.."FriendNum")
		local ui_rewardNum 		= getglobal(uiName.."RewardNum")
		local ui_focusNum 		= getglobal(uiName.."FocusNum")
		local ui_hotNum 		= getglobal(uiName.."HotNum")
		local moodFrame			= getglobal(uiName.."MoodFrame")
		local rotateView		= getglobal(uiName.."RotateView")
		local lockBtn			= getglobal(uiName.."LockBtn")
		local divider			= getglobal(uiName.."Divider")
		local network 			= getglobal(uiName.."work")
		local setBtn 			= getglobal(uiName.."SetBtn")
		local moodBtn 			= getglobal(uiName.."MoodBtn")
		local modeView 			= getglobal(uiName.."ModeView")
		local newSetBtn 		= getglobal(uiName.."NewSetting");

		-- 首页地图
		local ExhibitionInfo = getglobal("ExhibitionInfo")
		
		lockBtn:Hide()  -- 锁开始前隐藏，之后数据返回再定显示隐藏
		if t_exhibition:isThreeVerOpen() then
			ExhibitionInfo:Hide()
			network:Hide()
			setBtn:Hide()

			ui_rewardNum:Hide()
			ui_friendNum:Show()
			ui_focusNum:Show()
			ui_hotNum:Show()
			moodFrame:Hide()
			-- rotateView:Hide()
			divider:Hide()
			moodBtn:Hide()
			-- modeView:Hide()
			
			-- modeView:SetPoint("bottomleft", uiName, "bottomleft", 235, 60)
			rotateView:SetPoint("bottom", modeView:GetName(), "bottom", -320, -130)
			-- moodBtn:SetPoint("topright", rotateView:GetName(), "bottom", -45, 6)

			if isHost then
				newSetBtn:Show()
			else
				newSetBtn:Hide()
			end

		end
	end,

	-- 版本显示隐藏UI （返回数据后）
	ShowHideVersionUIEnd = function(self, isHost)
		print("ShowHideVersionUIEnd:", isHost)
		
		local uiName 		= t_exhibition:getUiName()
		local ui_lock 		= getglobal(uiName.."LockBtn");
		local ui_mood 		= getglobal(uiName.."MoodBtn");

		-- if t_exhibition:isThreeVerOpen() then
		-- 	ui_lock:Hide()
		-- 	ui_mood:Hide()
		-- else
			if isHost then
				ui_lock:Show();
				ui_mood:Show();

				--形象锁暂时只开放999&&测试服
				local apiid = ClientMgr:getApiId();
				local env = ClientMgr:getGameData("game_env");
				if true or 999 == apiid and 1 == env then
					ui_lock:Show();
				else
					ui_lock:Hide();
				end 

				--锁图标状态
				ZoneSetLockIconState();
			else 
				ui_lock:Hide();
				ui_mood:Hide();
			end
		-- end
	end,

	-- 是否是自己
	isLookSelf = function(self)
		return self.uin == AccountManager:getUin();
	end,

	setRetToPool=function (ret) --设置到对象池中
		if ret and t_exhibition.uin then 
			t_exhibition.retPool[t_exhibition.uin] = ret;
		end
	end,

	--地图详情界面会用到,防止重复拉取
	setRetToPoolByUin=function(ret, uin)
		if ret and uin then 
			t_exhibition.retPool[uin] = ret;
		end
	end,

	getRetFromPool =function (uin)
		if uin and t_exhibition.retPool and t_exhibition.retPool[uin] then
			return t_exhibition.retPool[uin];
		else 
			Log("get ret by uin is fail :getRetFromPool()");
			return nil;
		end
	end,

	getPlayerInfo = function () --获取显示个人中心顶部信息
		if t_exhibition.playerinfo then 
			return t_exhibition.playerinfo;
		else 
			Log("get player info fail :getPlayerInfo()")
			return nil;
		end
	end,

	clearMapInfo = function ()
	
	end

}

--展示中心
t_ExhibitionCenter = { 
	selectMap = 1, --默认显示的地图
	
	uploadPhotoId=-1,		--上传相册索引
	photoPraiseIndex = 1,  	-- 相册点赞索引
	photoMax = 30 ,			--相册最大数量

	offsetY = 0, --缩略图slider偏移值

	define = {
		tabHome 		= 1,
		tabMap 			= 2,
		tabDynamic 		= 3,
		tabWardrobe 	= 4,
		tabWareHouse 	= 5,
		tabMiniShow 	= 6,
		tabPhoto		= 7,
		tabStudio 		= 8,
		tabAchievement 	= 9,
		tabDressGallery = 10,
	},

	init = function(self)
		self.photoFileList = {} --相册列表
		self.Photoinfo = {} --相册的相关信息
		self.photoServerIndex = {} --相册服务器的坑位id，用来处理上传时候获取没有的索引

		self.defaultSelect = self.define.tabHome --默认显示的页面
		self.curSelectTabID = self.define.tabHome	--当前选择的页面
		self.tab = {  --后续可能会添加tab，修改顺序，逻辑通过读配置表方便后期需求的修改
			{ title="20524", pageName="ExhibitionInfoPage1", moreBtn_OnClick = ExhibitionInfoPage1MoreBtn_OnClick}, --地图
			{ title="20525", pageName="ExhibitionInfoPage2", moreBtn_OnClick = ExhibitionInfoPage2MoreBtn_OnClick}, --动态
			{ title="20526", pageName="ExhibitionInfoPage3", moreBtn_OnClick = nil},	--相册
			{ title="20593", pageName="ExhibitionInfoPage4", moreBtn_OnClick = nil},	--勋章
		}

		self:initTab()
	end,

	initTab = function(self)
		--左侧导航按钮
		if t_exhibition:isThreeVerOpen() then
			self.leftTabs = {
				--首页 地图 动态 衣橱 仓库 迷你show 相册 工作室
				ID = {
					self.define.tabHome, self.define.tabMap, self.define.tabDynamic, 
					self.define.tabWardrobe, self.define.tabWareHouse, self.define.tabMiniShow, 
					self.define.tabPhoto, self.define.tabStudio, self.define.tabDressGallery
				},
				nameID = {"3859", "20524", "20525", "110084", "3056", "110085", "20526", "60015", "1623"},
				pageName = {"", "ExhibitionMapFrame", "", "", "", "", "ExhibitionInfoPage3", "", ""},
				mvcCtrl = {"", "", "", "NewPlayerCenterWardrobe", "ShopWarehouse", "NewPlayerCenterMiniShow", "", "", ""},
				iconRes = {
					"ui/mobile/texture0/miniwork.xml",
					"ui/mobile/texture0/miniwork.xml",
					"ui/mobile/texture0/playercenter.xml",
					"ui/mobile/texture0/miniwork.xml",
					"ui/mobile/texture0/miniwork.xml",
					"ui/mobile/texture0/miniwork.xml",
					"ui/mobile/texture0/playercenter.xml",
					"ui/mobile/texture0/playercenter.xml",
					"ui/mobile/texture0/miniwork.xml",
				},
				iconUv = {
					"icon_home_tab", 
					"icon_map_tab", 
					"icon_track_tab", 
					"icon_wardrobe_tab", 
					"icon_warehouse_tab", 
					"icon_show_tab", 
					"icon_album_tab", 
					"icon_album_tab", 
					"icon_dressmanual_tab", 
				},			  
			}
		else
			self.leftTabs = {
				--首页 地图 动态 成就 相册 工作室
				ID = {
					self.define.tabHome, self.define.tabMap, self.define.tabDynamic, 
					self.define.tabAchievement, self.define.tabPhoto, self.define.tabStudio, 
					self.define.tabDressGallery
				},

				nameID = {"3859", "20524", "20525", "20593", "20526", "60015", "1623"},
				pageName = {"", "ExhibitionMapFrame", "", "ExhibitionInfoPage4", "ExhibitionInfoPage3", "", ""},
				mvcCtrl = {"", "", "", "", "", "", ""},
				iconRes = {
					"ui/mobile/texture0/miniwork.xml",
					"ui/mobile/texture0/miniwork.xml",
					"ui/mobile/texture0/playercenter.xml",
					"ui/mobile/texture0/playercenter.xml",
					"ui/mobile/texture0/playercenter.xml",
					"ui/mobile/texture0/miniwork.xml",
					"ui/mobile/texture0/miniwork.xml",
				},
				iconUv = {
					"icon_home_tab", 
					"icon_map_tab", 
					"icon_track_tab", 
					"icon_album_tab", 
					"icon_album_tab",
					"icon_studio_tab" ,
					"icon_show_tab", 
				},			  
			}         		  
		end
	end,

	-- 自己和别人需要隐藏的左栏目
	getLeftShowCfgs = function (self, host, bThreeVersion)
		local showCfgs = {}
		showCfgs[self.define.tabHome] = true
		showCfgs[self.define.tabMap] = true
		showCfgs[self.define.tabDynamic] = true
		if host then
			if bThreeVersion then
				-- showCfgs[self.define.tabWardrobe] = true
				showCfgs[self.define.tabWareHouse] = true
				showCfgs[self.define.tabMiniShow] = true
				showCfgs[self.define.tabDressGallery] = GetInst("SkinCollectManager"):isOpen()
			else
				showCfgs[self.define.tabAchievement] = true
			end

			--是否是开发者
			local b_develop = ScriptSupportFunc:checkIsDeveloper();
			if host and GetInst("WorkSpaceDataManager"):isOpen() and b_develop then
				showCfgs[self.define.tabStudio] = true
			end

		else
			if bThreeVersion then
				showCfgs[self.define.tabMiniShow] = true
				showCfgs[self.define.tabDressGallery] = GetInst("SkinCollectManager"):isOpen()
			else
				showCfgs[self.define.tabAchievement] = true
			end
		end

		--相册目前是直接隐藏的，等有显示逻辑的时候再处理

		return showCfgs
	end,


	getPhotoInfo = function ()
		if t_ExhibitionCenter.Photoinfo then 
			return t_ExhibitionCenter.Photoinfo;
		else 
			Log("get Photoinfo is fail :getPhotoInfo()");
			return
		end
	end,

	getPhotoFileList = function ()
		if t_ExhibitionCenter.photoFileList then 
			return t_ExhibitionCenter.photoFileList;
		else 
			Log("get photoFileList is fail :getPhotoFileList()");
			return
		end
	end,

	reset = function ()
		t_ExhibitionCenter.selectMap = 1;
		t_ExhibitionCenter.curSelectTabID = t_ExhibitionCenter.define.tabHome;
		t_ExhibitionCenter.photoPraiseIndex = 1;
		t_ExhibitionCenter.photoFileList = {};
	end
}

t_exhibitionMap = { --展示中心地图相关
	defaultSelect = 1,
	curSelectTab = 1, --当前选择的页面
	curSelectMapIndex = 1, --默认选择的地图索引

	sortSelectTab = 1,		--1：按照时间倒序（默认） 2：按游戏次数倒序

	isExpert =false;  --是否是鉴赏家
	tab = {
		{title="1263", maplist={} },  
		{title="897", maplist={} },
		{title="1262", maplist={} },
	},

	recommendList = {},    	--地图推荐语列表 [owid] = memo
	collectList = {},	   	--收藏地图列表，存入地图id，需要二次拉取
	evaluateList = {},		--鉴赏家地图id

	thumbMapList = {},		--缩略图页面map列表

	mapTop = { maptype = -1},   --maptype: 1:作品地图，2收藏地图

	getTabInfo = function (index)
		if type(index) ~='number' and index<=0 then 
			Log("index is not expected :getTabInfo()");
			return;
		end

		if t_exhibitionMap and t_exhibitionMap.tab[index] then 
			return t_exhibitionMap.tab[index];
		end
	end,

	cancelCollect = function (owid)
	 	owid = CurArchiveMap.owid or owid;
		-- 清空数据
		local mapList = t_exhibitionMap.tab[2].maplist;
		if mapList then 
			for k,v in pairs(mapList) do 
				if v.owid == owid then 
					table.remove(mapList,k);
					break;
				end
			end
		end

		local thumbMapList = t_exhibitionMap.thumbMapList 
		if thumbMapList then 
			for k,v in pairs(thumbMapList) do 
				if v.owid == owid then 
					table.remove(thumbMapList,k);
					break;
				end
			end
		end

		-- 更新当前模块的显示
		PEC_MapTabState(t_exhibitionMap.curSelectTab);
		PEC_ExhibitionMapArchiveSwitch(t_exhibitionMap.curSelectTab);

		local btn_edit = getglobal("ExhibitionMapFrameEditFrame");
		if btn_edit and btn_edit:IsShown()  then 
			btn_edit:Hide();
		end

		-- 更新主页地图的显示
		PEC_GetMapRospond();

	end,

	clearMap = function ()
		t_exhibitionMap.isExpert =false;
		
		for i=1,#(t_exhibitionMap.tab) do
			t_exhibitionMap.tab[i].maplist = {};	
		end

		t_exhibitionMap.recommendList ={};
		t_exhibitionMap.collectList = {};
		t_exhibitionMap.evaluateList = {};
		t_exhibitionMap.thumbMapList = {};
		t_exhibitionMap.mapTop = { maptype = -1};
	end,

	getCurSelectMap = function ()

		local id = t_exhibitionMap.curSelectMapIndex;
		local map = t_exhibitionMap.tab[t_exhibitionMap.curSelectTab].maplist[id];
		if map then 
			return map;
		else 
			Log("get map is false:getCurSelectMap()")
			return nil;
		end
	end,

}

local t_frameInfo ={
	uin ="",
	tab = -1, --展示中心tab索引
	isMapFrameShow = false, --地图频道是否打开
	mapTab = -1, --地图频道tab索引
	mapIndex = -1, --地图频道选中索引
	isMapTipsFrame = flase, --地图详情页是否打开

	reset = function(self)
		self.uin = "";
		self.tab = -1;
		self.isMapFrameShow = false;
		self.mapTab = -1;
		self.mapIndex = -1;
		self.isMapTispFrame = flase;
	end,
}


-- profile不完整例子：
-- {
-- 	photo_unlock = 4, 
-- 	_t_ = 1558595430, 
-- 	photo = {
-- 		{
-- 			filename = [[data/http/photo/911ee28e66f56a652dcb136a6f97e97a.png]], 
-- 			md5 = [[911ee28e66f56a652dcb136a6f97e97a]], 
-- 			ext = [[png]], 
-- 			url = [[http://indevelop.mini1.cn:8080/map/1/20190520/911ee28e66f56a652dcb136a6f97e97a.png]], 
-- 			checked = 1, 
-- 			dir = [[20190520]], 
-- 			node = [[1]]
-- 		}, 
-- 		{
-- 			filename = [[data/http/photo/c5d6c0871ccfe36ef1b9e52e3b850dfa.png]], 
-- 			md5 = [[c5d6c0871ccfe36ef1b9e52e3b850dfa]], 
-- 			ext = [[png]], 
-- 			url = [[http://indevelop.mini1.cn:8080/map/1/20190521/c5d6c0871ccfe36ef1b9e52e3b850dfa.png]], 
-- 			checked = 1, 
-- 			dir = [[20190521]], 
-- 			node = [[1]]
-- 		}
-- 	}, 
-- 	head_frames = {

-- 	}, 
-- 	head_frames_temp = {

-- 	}, 
-- 	mood_icon = [[A100]], 
-- 	all_download_st = 1558595430, 
-- 	RoleInfo = {
-- 		SkinID = 42, 
-- 		NickName = [[Seckawijoki]], 
-- 		Model = 2, 
-- 		head_id = 71
-- 	}, 
-- 	uin = 205075351, 
-- 	report2 = {
-- 		t = 1558333626
-- 	}, 
-- 	head_unlock = 1, 
-- 	head_frame_id = 1, 
-- 	custom_skin = {
-- 		[1001] = {
-- 			md5 = [[9fbd8b3032aadfdfbbc62768f4f27e96]], 
-- 			ext = [[png]], 
-- 			checked = 1, 
-- 			dir = [[20190226]], 
-- 			node = [[1]]
-- 		}, 
-- 		[1002] = {
-- 			md5 = [[1c213dc9835dfdf4973076a033cba4c9]], 
-- 			ext = [[png]], 
-- 			checked = 1, 
-- 			dir = [[20190302]], 
-- 			node = [[1]]
-- 		}, 
-- 		[1005] = {
-- 			md5 = [[f1df3d700519af7b19609eceb153661d]], 
-- 			ext = [[png_]], 
-- 			checked = 1, 
-- 			dir = [[20190222]], 
-- 			node = [[1]]
-- 		}
-- 	}, 
-- 	mood_text = [[心情]], 
-- 	relation = {
-- 		friend_beapply = 0,
--   ????
function t_exhibition:CheckProfileBlackStat(uin)
	uin = uin or self.uin;
	uin = uin and tonumber(uin);
	if not uin then return false end
	local black_stat = nil;
	-- print("t_exhibition:CheckProfileBlackStat(): uin = ", uin);
	if self.uin_to_profile_black_stat and self.uin_to_profile_black_stat[uin] then 
		-- print("t_exhibition:CheckProfileBlackStat(): self.uin_to_profile_black_stat = ", self.uin_to_profile_black_stat);
		black_stat = self.uin_to_profile_black_stat[uin];
	elseif not self.has_requested[uin] then
		-- print("t_exhibition:CheckProfileBlackStat(): request");
		-- print("t_exhibition:CheckProfileBlackStat(): self.has_requested = ", self.has_requested);
		self.has_requested[uin] = true;
		threadpool:work(function()
			function onResponseGetProfile(ret, user_data)
				if  IsMyFriend(uin) then   ---判断是好友
					--存储到文件
					if  ret and ret.profile and ret.profile._t_  and ret.profile.uin and ret.profile.RoleInfo then
						if  ret._from_local_ then
							print( "friend_profile from_local")  --已经是从本地读取 不保存
						else
							print( "friend_profile save_cache")
							ret._t_save_ = getServerNow()   ---记录最后存盘时间
							setkv( "data", ret, "friend_profile_" .. ret.profile.uin,  101 )   --作为公共UIN 101 存储
						end
					end
				end

				-- print("t_exhibition:CheckProfileBlackStat()#onResponseGetProfile(): uin = ", uin);
				-- print("t_exhibition:CheckProfileBlackStat()#onResponseGetProfile(): ret = ", ret);
				local t_exhibition = t_exhibition;
				t_exhibition.has_requested = t_exhibition.has_requested or {};
				t_exhibition.has_requested[uin] = false;
				t_exhibition.uin_to_profile_black_stat = t_exhibition.uin_to_profile_black_stat or {};
				t_exhibition.uin_to_profile_black_stat[uin] = ret and ret.profile and ret.profile.black_stat or 0;
				t_exhibition.retPool[uin] = ret;
				-- t_exhibition.uin_to_profile_black_stat[uin] = ret and ret.profile and (ret.profile.black_stat or 0) or nil; --针对ret和ret.profile赋nil
			end
			t_exhibition:GetPlayerProfileByUin(uin, onResponseGetProfile);
		end);
	end
	-- local black_stat = self.uin_to_profile_black_stat and self.uin_to_profile_black_stat[uin] 
	-- or (not self.has_requested[uin] and self.GetPlayerProfileByUin and self:GetPlayerProfileByUin(uin, onResponseGetProfile));
	return black_stat and (black_stat == 1 or black_stat == 2);
end

function t_exhibition:CheckOtherProfileBlackStat(uin)
	uin = uin or self.uin;
	uin = uin and tonumber(uin);
	return uin and AccountManager:getUin() ~= uin and self:CheckProfileBlackStat(uin);
end

--添加参数强制重新拉取
function t_exhibition:GetPlayerProfileByUin(uin, callback, ext_callback,force)
	print("GetPlayerProfileByUin:" .. uin);
	if (uin<1000 or uin>=ns_const.__INT32__) and ext_callback then
		ext_callback( {ret=1} );  --号码错误
		return
	end

	local t_exhibition = self;
	if not force then
		if  t_exhibition.net_ok and t_exhibition.retPool and t_exhibition.retPool[uin] then
			Log( "find cache for " .. uin );
			--已经拉取该UIN的数据
			if t_exhibition.isHost and t_exhibition.self_data_dirty then
				--自己的数据已经修改，需要重新拉取
				Log("111:");
				t_exhibition.self_data_dirty = false;
			elseif callback then
				Log("222:");
				callback(t_exhibition.retPool[uin], { callback=ext_callback }  );
				return;
			end
			
		else
			---friend_profile cache
			if  IsMyFriend(uin) then   ---判断是好友
				--- 1 判断本地文件
				local data_ = getkv( "data", "friend_profile_" .. uin, 101 )
				print( "friend_profile getkv" .. uin )
				--print( data_ )
	
				if  data_ and data_.profile and data_.profile._t_ then
					---2 有cache
					local now_ = getServerNow()
					if  math.abs( now_ - data_.profile._t_ ) < 20*86400 then
						---活跃玩家，重新拉取数据
						print( "friend_profile active player" )
					else
						print( "friend_profile no-active player" )
						---非活跃玩家
						if  data_._t_save_ and math.abs( now_ - data_._t_save_ ) < 7*86400 then
							---最近存盘时间少于7天( 可以使用cache )
							print( "friend_profile no-active player, cache less 7 day " )
							data_._from_local_ = 1
							callback( data_, { callback=ext_callback } );
							return
						else
							--超过7天，重新拉取
							print( "friend_profile no-active player, cache exceed 7 day " )
						end
					end	
				else				
					print( "friend_profile no cache file or data" )
				end
			end
		
		end
	end
	Log("333:");
	local url_ = g_http_root_map .. 'miniw/profile?act=getProfile&op_uin=' .. uin .. "&pop=1" .. '&' .. http_getS1Map();
	Log( url_ );
	ns_http.func.rpc( url_, callback, { callback=ext_callback },nil, ns_http.SecurityTypeHigh);
end

---------------------------------------数据请求逻辑--------------------------------------------------
function PEC_GetPlayerProfileByUin(uin, ext_callback) 
	t_exhibition:GetPlayerProfileByUin(uin, PEC_GetPlayerProfileByUin_cb, ext_callback,true)
end


function PEC_GetPlayerProfileByUin_cb(ret, user_data)  --获取个人中心玩家信息回调函数
	print("PEC_GetPlayerProfileByUin_cb:");
	if user_data and user_data.callback then user_data.callback(ret) end

	local t_exhibition = t_exhibition;

	if  ret and ret.ret then
		print("ret ok:");
		if  ret.ret == 1 then
			--uin error
			ShowGameTips(GetS(3272), 3);
			return;
		elseif ret.ret == 404 then
			--新用户
		end

		-- 控制相册是否可以上传图片
		t_exhibition.close_upload = ret.close_upload or 1;
		t_exhibition.setRetToPool(ret);
		t_exhibition.net_ok	= true;

		local profile = ret.profile;
		if profile then 
			print("profile", profile );
			local playerInfo = {};
			playerInfo.gender        = profile.gender        or 0;
			playerInfo.head_frame_id = profile.head_frame_id or 1;   --默认为头像1
			playerInfo.head_unlock   = profile.head_unlock   or 0;
			t_exhibition.head_unlock = profile.head_unlock   or 0;

			playerInfo.head_frames      = profile.head_frames      or {};     --已经解锁的头像
			playerInfo.head_frames_temp = profile.head_frames_temp or {};     --已经解锁的头像(30天)

			t_exhibition.first_ui = profile.first_ui or 1;			--优先展示
			t_exhibition.open_comment = profile.open_comment or 1;	--是否可评论

			--兼容旧数据(旧版本头像) 20210
			if  (profile.is_zhubo==1) and (not playerInfo.head_frames[20210]) then
				playerInfo.head_frames[20210] = { t=os.time() };
			end
			if profile.bestpartner_switch ~= nil then
				t_exhibition.bestpartner_switch = tonumber(profile.bestpartner_switch)
			else
				t_exhibition.bestpartner_switch = 1
			end
			print("hx PEC_GetPlayerProfileByUin_cb bestpartner_switch",t_exhibition.bestpartner_switch)
			--昵称 角色 皮肤
			if  profile.RoleInfo then
				playerInfo.NickName = profile.RoleInfo.NickName or "";
				playerInfo.SkinID   = profile.RoleInfo.SkinID   or 0;
				playerInfo.Model    = profile.RoleInfo.Model    or 0;
				if  playerInfo.Model <= 0 then
					playerInfo.Model = 2
				end
			end

			--鉴赏家
			playerInfo.expert = profile.expert or nil ;

			--好友 关注 人气值
			playerInfo.friend_count    = 0;
			playerInfo.attention_count = 0;
			playerInfo.popularity_count = 0;
			if  profile.relation then
				playerInfo.friend_count    = (profile.relation.friend_eachother   or 0) + (profile.relation.friend_oneway or 0);
				playerInfo.attention_count = (profile.relation.friend_beattention or 0);
			end
			playerInfo.popularity_count = ret.popularity or 0;

			--自定义头像
			if  profile.header and profile.header.url then
				if profile.uin and AccountManager:getUin() ~= profile.uin and profile.black_stat and (profile.black_stat == 1 or profile.black_stat == 2) then
					playerInfo.headIndexFile = "ui/snap_jubao.png";
					playerInfo.head_url = nil;
				else
					playerInfo.head_checked = profile.header.checked or 0; --审核状态
					if  playerInfo.head_checked == 2 then
						playerInfo.head_url     = "f"       --审核失败
					else
						playerInfo.head_url     = profile.header.url;
					end
				end
				PEC_SetPlayerHeadFile(playerInfo);
			else
				if  playerInfo.Model and playerInfo.SkinID then
					playerInfo.head_url = "";
					if profile.uin and AccountManager:getUin() ~= profile.uin and profile.black_stat and (profile.black_stat == 1 or profile.black_stat == 2) then
						playerInfo.headIndexFile = "ui/snap_jubao.png";
					elseif t_exhibition.isHost then
						playerInfo.headIndexFile = GetHeadIconPath();  	--头像文件
					else
						local headPath = GetInst("HeadInfoSysMgr"):GetPlayerHeadPathByUin(profile.uin)
						playerInfo.headIndexFile = headPath or "ui/roleicons/".. GetHeadIconIndex( playerInfo.Model, playerInfo.SkinID ) ..".png";  	--头像文件
					end
					PEC_SetPlayerHeadFile(playerInfo);
				end
			end

			if profile.tips and profile.tips.total then
				playerInfo.tips = profile.tips or {};
			end

			--心情描述  
			print("PlayerCenter_SetMood:");
			t_exhibition.mood_icon = profile.mood_icon;
			t_exhibition.mood_icon_select = t_exhibition.mood_icon or "A100";
			t_exhibition.mood_text = unescape(profile.mood_text);
			PlayerCenter_SetMood(profile.mood_icon, t_exhibition.mood_text);

			t_exhibition.playerinfo=playerInfo;

			--显示个人信息的文字
			PEC_ShowPlayerInfo()

			--设置相册
			local PhotoInfo = {};
			PhotoInfo.photo_unlock  = profile.photo_unlock  or 3;


			t_ExhibitionCenter.photoServerIndex ={};
			local photo_index = 0;
			if profile.photo then
				for k ,v in pairs(profile.photo) do
					if v then
						photo_index = photo_index+1;
						table.insert(t_ExhibitionCenter.photoServerIndex,k);
						table.insert(t_ExhibitionCenter.photoFileList,photo_index,v);
					end
				end
			end

			for i=1,  t_ExhibitionCenter.photoMax do
				if  t_ExhibitionCenter.photoFileList[i] then
					t_ExhibitionCenter.photoFileList[i].filename = g_photo_root .. getHttpUrlLastPart( t_ExhibitionCenter.photoFileList[i].url );
				end
			end

			t_ExhibitionCenter.Photoinfo = PhotoInfo;

			--设置默认显示的展示中心页面
			t_ExhibitionCenter.defaultSelect = profile.first_ui or t_ExhibitionCenter.define.tabHome;
			t_exhibition.black = profile.black or 0 ;
			if not PEC_SetBlackShow(t_exhibition.black) then
				PEC_GetPlayerMapByUin(t_exhibition.uin,1,1);  --获取地图接口调用
			end

			--成就系统上报:好友数/粉丝数(t_exhibition.isHost这个判断是不是有失误的情况, 有报上报的好友数跟实际好友不同的, 是不是报到别人的好友呢?)
			--海外版本, uin比较的时候注意长uin和短uin
			local uin = t_exhibition.uin;
			local myUin = AccountManager:getUin();
			print("***Archievement report:profile_cb: uin = ", uin, ", myUin = ", myUin);
			if myUin == uin then
				print("Archievement report:profile_cb: uin = ", uin);
				ArchievementGetInstance().func:checkFriendInfo(playerInfo.friend_count, playerInfo.attention_count, playerInfo.expert);

				--检查实名认证
				ArchievementGetInstance().func:checkRealname();	
			else
				NewBattlePassEventOnTrigger("visitplayerCenter");
			end
		end
		
	else
		Log("ret is nil:PEC_GetPlayerProfileByUin_cb()");
	end
end

function PEC_GetPlayerMapByUin(target_uin,mome2,map_top,userdata) ---获取玩家的地图信息 mome2：推荐语，map_top：获取置顶地图
	if not CheckUin() then
		return;
	end

	local uu_ = tonumber(target_uin) or 0
	if  uu_ < 1000 or uu_ >= ns_const.__INT32__ then
		ShowGameTips(GetS(6351), 3);        --输入的迷你号有误
		return;
	end

	target_uin = getLongUin( target_uin );

	t_exhibitionMap.clearMap();  --清空存档

	ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:PEC_GetPlayerMapByUin");

	local url = mapservice.getserver().."/miniw/map/?act=search_user_maps&get_memo2="..mome2.."&map_top="..map_top.."&op_uin="..target_uin;
	--local url = mapservice.getserver().."/miniw/map/?act=search_user_maps&op_uin="..target_uin;
    url = AddPlayableArg(url)
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, PEC_RespGetPlayerMapByUin, userdata,nil, ns_http.SecurityTypeHigh);  --map

	return true;
end

function PEC_RespGetPlayerMapByUin(ret, userdata)
	ShowLoadLoopFrame(false)

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	if ret.urls then
		SetMapServers(ret.urls);
	end

	--print("PEC_RespGetPlayerMapByUin(): ret = ", ret);
	--print("PEC_RespGetPlayerMapByUin(): ret.map_info_list = ", ret.map_info_list);
	if ret.map_info_list then
		for owid, src in pairs(ret.map_info_list) do
			if BreakLawMapControl:VerifyMapID(owid) ~= 2 then

				--print("PEC_RespGetPlayerMapByUin(): owid = ", owid);
				--print("PEC_RespGetPlayerMapByUin(): src = ", src);
				local map = CreateMapInfoFromHttpResp(src, src.push_comments, src.push_up3, owid); 
				map.owid = owid;

				UpdateMapInfoFromHttpRespComment(map, src.comment);
				--print("PEC_RespGetPlayerMapByUin(): map.black_stat = ", map.black_stat);

				if ret.map_top and  map.author_uin ~= t_exhibition.uin  and ret.map_top == owid then
				elseif ret.map_top == owid then 
					table.insert(t_exhibitionMap.tab[1].maplist,1, map);
				else
					table.insert(t_exhibitionMap.tab[1].maplist, map);
				end
			end
		end
	end
	
	if ret.map_top then 
		t_exhibitionMap.mapTop["owid"] = ret.map_top;
	else
		t_exhibitionMap.mapTop["owid"] = nil;
	end

	local sortId = userdata and userdata.sortId or t_exhibitionMap.sortSelectTab
	PEC_ExhibitionSortMapArchive(sortId)

	if ret.memo2_list then 
		t_exhibitionMap.recommendList = ret.memo2_list;
	end 

	if ret.collect_list then 
		for k,v in pairs(ret.collect_list) do 
			table.insert(t_exhibitionMap.collectList,v.fn);
		end
	end

	if ret.expert  then 

		if ret.expert.stat== 2 then 
			t_exhibitionMap.isExpert =true;

			if ret.expert.push_list then 
				t_exhibitionMap.evaluateList = ret.expert.push_list;
			end
		end
	end

	t_exhibitionMap.thumbMapList={};
	for i =1 ,#(t_exhibitionMap.tab[1].maplist) do 
		t_exhibitionMap.thumbMapList[i] = t_exhibitionMap.tab[1].maplist[i]
	end

	if t_exhibitionMap.collectList and #(t_exhibitionMap.collectList)>0 then 

		PEC_GetMapsInfoByList(t_exhibitionMap.collectList,PEC_RespGetMapsInfoByList); --加载收藏地图
		
	else
		PEC_GetMapRospond();
	end

	if getglobal("ExhibitionMapFrame"):IsShown() then 

		PEC_ExhibitionMapArchiveSwitch(t_exhibitionMap.curSelectTab);
	end
	
end

function PEC_GetMapsInfoByList(list,funcName)  --批量获取地图信息
	if list ==nil then return end 

	local owidStr = "";
	for i=1,#list do
		if i ~= #list then 
			owidStr = owidStr.. list[i].."-"
		else 
			owidStr = owidStr.. list[i]
		end
	end
	
	ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:PEC_GetMapsInfoByList");

	local url = mapservice.getserver().."/miniw/map/?act=search_maps_list&fn_list="..owidStr.."&get_memo2=1".."&op_uin="..t_exhibition.uin;
	url = AddPlayableArg(url)
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, funcName, nil,nil, ns_http.SecurityTypeHigh);  --map
end

function PEC_RespGetMapsInfoByList(ret)
	ShowLoadLoopFrame(false)

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	if ret.urls then
		SetMapServers(ret.urls);
	end

	if ret.map_info_list then
		for owid, src in pairs(ret.map_info_list) do
			if BreakLawMapControl:VerifyMapID(owid) ~= 2 then

				local map = CreateMapInfoFromHttpResp(src, src.push_comments, src.push_up3, owid);
				map.owid = owid;

				UpdateMapInfoFromHttpRespComment(map, src.comment);
				
				if t_exhibitionMap.mapTop and t_exhibitionMap.mapTop.owid ==owid then 
					table.insert(t_exhibitionMap.tab[2].maplist,1, map);
				else 
					table.insert(t_exhibitionMap.tab[2].maplist, map);
				end

			end
		end
	end

	if ret.memo2_list then 

		for k,v in pairs(ret.memo2_list) do 
			t_exhibitionMap.recommendList[k]=v
		end
	end 

	local mapNum = #(t_exhibitionMap.tab[1].maplist) + #(t_exhibitionMap.tab[2].maplist);
	if mapNum>20 then 
		mapNum =20;
	end

	local archiveNum = #(t_exhibitionMap.tab[1].maplist);

	if archiveNum<mapNum then 
		for i=archiveNum+1,mapNum do 
			local map_temp = t_exhibitionMap.tab[2].maplist[i - archiveNum];
			local maptop = t_exhibitionMap.mapTop.owid;
			if maptop and t_exhibitionMap.tab[2].maplist[i - archiveNum].author_uin == t_exhibition.uin then
				--判断是自己的作品
			elseif maptop and maptop == t_exhibitionMap.tab[2].maplist[i - archiveNum].owid then
				table.insert(t_exhibitionMap.thumbMapList,1,map_temp);
			elseif t_exhibitionMap.tab[2].maplist[i - archiveNum].author_uin ~= t_exhibition.uin then
				table.insert(t_exhibitionMap.thumbMapList,map_temp);
			end

		end
	end

	PEC_ReqGetRecommend(1104011156135)

	if getglobal("ExhibitionMapFrame"):IsShown() then 
		PEC_ExhibitionMapArchiveSwitch(t_exhibitionMap.curSelectTab);
	end

	PEC_GetMapRospond();
end

function PEC_ResGetEvaluateMapsByList(ret)
	ShowLoadLoopFrame(false)

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	if ret.urls then
		SetMapServers(ret.urls);
	end

	if ret.map_info_list then
		for owid, src in pairs(ret.map_info_list) do
			if BreakLawMapControl:VerifyMapID(owid) ~= 2 then

				local map = CreateMapInfoFromHttpResp(src, src.push_comments, src.push_up3, owid);
				map.owid = owid;
				
				UpdateMapInfoFromHttpRespComment(map, src.comment);
				table.insert(t_exhibitionMap.tab[3].maplist, map);
			end
		end
	end
end

function PEC_RespEvaluatemap(maps)  --获取测评地图的详细信息
	if next(maps) ~= nil then
		t_exhibitionMap.tab[3].maplist = {} 
		for owid,map in pairs(maps) do 
			table.insert(t_exhibitionMap.tab[3].maplist, map);
		end
	end
end

function PEC_ReqMapVisibility(open,owid) --open： 1=公开投稿 2=不可见 3=仅搜索可见
	ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:PEC_RespEvaluatemap");

	local url = mapservice.getserver().."/miniw/map/?act=set_map_open&fn="..owid.."&open="..open;
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, PEC_RespMapVisibility, nil,nil, ns_http.SecurityTypeHigh);  --map
end

function PEC_RespMapVisibility(ret)
	ShowLoadLoopFrame(false)

	if ret and ret.ret == 0 then 
		getglobal("ExhibitionMapFrameEditFrame"):Hide();
		PlayerExhibitionCenter_OnShow()
		t_exhibition.init(t_exhibition.uin)
		ShowGameTips(GetS(20527))
	elseif ret and ret.ret == 5 then
		ShowGameTips(GetS(344), 5);
	else
		ShowGameTips(GetS(3272), 3);
	end

end

function PEC_ReqSetRecommend(memo2,owid) --设置推荐语言 
	-- if memo2 =="" then 
	-- 	memo2 = " "; --这里不需要特殊处理，服务器接受空内容
	-- end

	if string.len(memo2) >150 then 
		memo2 = string.sub(memo2,1,150);
	end

	if CheckFilterString(memo2) then return end
	ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:PEC_ReqSetRecommend");
	memo2 = escape(memo2);
	local url = mapservice.getserver().."/miniw/map/?act=set_map_memo2&fn="..owid.."&memo2="..memo2;
	url = url .. "&" .. http_getRealNameMobileSum()
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, PEC_RespSetRecommend, nil,nil, ns_http.SecurityTypeHigh);  --map
end

function PEC_RespSetRecommend(ret)
	ShowLoadLoopFrame(false)
	if ret then
		if ret.ret == 0 then 
			PlayerExhibitionCenter_OnShow()
			PEC_GetPlayerMapByUin(t_exhibition.uin,1,1)
			getglobal("ExhibitionRecomendFrameTextEdit"):Clear();
			getglobal("ExhibitionRecomendFrame"):Hide();
			getglobal("ExhibitionRecomendFrameEditDefaultTxt"):Show();
			getglobal("ExhibitionMapFrameEditFrame"):Hide();
			if IsOverseasVer() or isAbroadEvn() then 
				ShowGameTips(GetS(20667), 3)
			else
				ShowGameTips(GetS(20666), 3)
			end
		elseif ret.ret == 2 then --字符太长返回2
			ShowGameTips(GetS(180005), 3)
		elseif ret.ret == 3 then --字符自定审查鉴定违规返回3
			ShowGameTips(GetS(180004), 3)
		elseif ret.ret == 11 then 
			if ret_.flag == "00" then
				ShowGameTipsWithoutFilter(GetS(22037), 3)	--手机 身份证 校验失败
			elseif ret_.flag == "01" then
				ShowGameTipsWithoutFilter(GetS(10643), 3)	--手机号 校验失败
			elseif ret_.flag == "10" then
				ShowGameTipsWithoutFilter(GetS(100218), 3)	--身份证 校验失败
			end
		elseif ret.ret == 12 then 
			ShowGameTips(GetS(121), 3)
		end
	else
		ShowGameTips(GetS(3272), 3);
	end
end

function PEC_ReqGetRecommend(owid) --获取推荐语
	ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:PEC_ReqGetRecommend");

	local url = mapservice.getserver().."/miniw/map/?act=get_map_memo2&fn="..owid;
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, PEC_RespGetRecommend, nil,nil, ns_http.SecurityTypeHigh);  --map
end

function PEC_RespGetRecommend(ret)
	ShowLoadLoopFrame(false)
end

function PEC_ReqClearMapTop(owid) --取消置顶
	ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:PEC_ReqSetMapTop");
	local url = mapservice.getserver().."/miniw/map/?act=clear_map_top&fn="..owid;
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, PEC_RespClearMapTop, nil,nil, ns_http.SecurityTypeHigh);  --map
end

function PEC_RespClearMapTop(ret)
	ShowLoadLoopFrame(false)

	if ret and ret.ret == 0 then 
		if getglobal("ExhibitionMapFrame"):IsShown() then
			getglobal("ExhibitionMapFrameEditFrame"):Hide();
			t_exhibition.init(t_exhibition.uin)
			ShowGameTips(GetS(20578));
		end
	else
		ShowGameTips(GetS(3272), 3);
	end
end

function PEC_ReqSetMapTop(owid) --设置置顶
	ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:PEC_ReqSetMapTop");
	local url = mapservice.getserver().."/miniw/map/?act=set_map_top&fn="..owid;
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, PEC_RespSetMapTop, nil,nil, ns_http.SecurityTypeHigh);  --map
end

function PEC_RespSetMapTop(ret)
	ShowLoadLoopFrame(false)

	if ret and ret.ret == 0 then 
		if getglobal("ExhibitionMapFrame"):IsShown() then
			getglobal("ExhibitionMapFrameEditFrame"):Hide();
			t_exhibition.init(t_exhibition.uin)
			ShowGameTips(GetS(20530));
		end
	else
		ShowGameTips(GetS(3272), 3);
	end
end

function PEC_ReqAlbumPraise(op_uin,photo_index)  --相册点赞
	ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:PEC_ReqAlbumPraise");
	local url = mapservice.getserver().."/miniw/profile/?act=prize_photo&op_uin="..op_uin.."&seq="..photo_index;
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, PEC_ResqAlbumPraise, nil,nil, ns_http.SecurityTypeHigh);  --profile
end

function PEC_ResqAlbumPraise(ret)
	ShowLoadLoopFrame(false)
	if ret.ret == 0 then 
		PEC_PhotoPraiseNumAdd(1);
	else 
		local index = t_ExhibitionCenter.photoPraiseIndex;

		local cellName = "ExhibitionInfoPage3CommentSliderCell";
		local ui_praiseIcon		=getglobal(cellName..index.."PraiseBtnIcon");
		local ui_praiseFont		=getglobal(cellName..index.."PraiseBtnFont");
		-- ui_praiseIcon:SetTexUV("mngfg_dianzan02");
		ui_praiseFont:SetTextColor(180,242,128);

		ShowGameTips(GetS(20545));
	end
end

--------------------------------界面相关的回调接口----------------------------------------------------
local downloadMapSign = false; --下载地图按钮更新状态标志位

-- 检测当前左栏配置是否存在 && 是否显示，默认首页
function PEC_CheckLeftTabBtIDInvalid(IDCfgs, ID)
	if not ID or not IDCfgs then
		return t_ExhibitionCenter.define.tabHome
	end

	for index = 1, #IDCfgs do
		local tab = getglobal(t_exhibition:getUiName().."LeftTabBtn" .. index)
		if IDCfgs[index] == ID and tab and tab:IsShown()  then
			return ID
		end
	end

	return t_ExhibitionCenter.define.tabHome
end

--当前点击了第几个页签
local curClickID = nil
local curTabParas = nil
--左侧导航按钮点击
-- ID: 为t_ExhibitionCenter.define
function ExhibitionLeftTabBtnTemplate_OnClick(ID, inParas, bForceRefresh,ThemeNum)
	print("ExhibitionLeftTabBtnTemplate_OnClick: pre ID = ", ID);
	ID = ID or this:GetClientID()

	-- 清除个人中心首页角色音效
	ClientMgr:playStoreSound2D("")

	if not bForceRefresh and curClickID == ID then
		return 
	end

	local t_Tab = t_ExhibitionCenter.leftTabs
	ID = PEC_CheckLeftTabBtIDInvalid(t_Tab.ID, ID)
	local uiName = t_exhibition:getUiName()
	local bThreeVersionSwitch = t_exhibition:isThreeVerOpen()
	local defineTabIDs = t_ExhibitionCenter.define
	
	curClickID = ID
	curTabParas = inParas
	print("ExhibitionLeftTabBtnTemplate_OnClick: end ID = ", ID);

	if EnterMainMenuInfo.PlayerCenterBackInfo then
		EnterMainMenuInfo.PlayerCenterBackInfo.clickID = curClickID
	end

	if  PassFirstInitPlayerExhibitionCenter then
		local sceneTb = {
			"7",
			"43"
		}
		local cardTb = {
			"PERSONAL_INFO_CONTAINER",
			"PLAYER_INFO_CONTAINER"
		}
		local tb = {
			[defineTabIDs.tabHome] = "HomePageContent",
			[defineTabIDs.tabMap] = "MapContent",
			[defineTabIDs.tabDynamic] = "UpdatesContent",
			[defineTabIDs.tabAchievement] = "MedalContent",
			[defineTabIDs.tabWardrobe] = "WardrobeContent",
			[defineTabIDs.tabWareHouse] = "StorageContent",
			[defineTabIDs.tabMiniShow] = "MiniShowContent",
		}
		if tb[ID] then
			local isMy = IsLookSelf() and 1 or 2
			standReportEvent(sceneTb[isMy], cardTb[isMy], tb[ID], "click")

			local compTb = {}
			if ID == defineTabIDs.tabHome then
				if IsLookSelf() then
					local tb1 = {
						PERSONAL_INFO_HOMEPAGE = {
							"-",
							"IDCertification",
							"UinCopy",
							"MoodSendButton",
							"AvatarLock",
						},
					}
					for key, value in pairs(tb1) do
						for _, val in ipairs(value) do
							standReportEvent("7", key, val, "view")
						end
					end
					if #t_exhibitionMap.thumbMapList > 0 and t_ExhibitionCenter.selectMap <= #t_exhibitionMap.thumbMapList then
						for index=1,#t_exhibitionMap.thumbMapList do
							local cid = t_exhibitionMap.thumbMapList[index].owid
							standReportEvent("7", "PERSONAL_INFO_HOMEPAGE", "MyMapCard", "view",{cid=cid,slot=tostring(index),ctype="1"})
						end
					end
				else
					-- body
					local tb1 = {
						PLAYER_INFO_HOMEPAGE = {
							"-",
							"UinCopy",
						}
					}
					for key, value in pairs(tb1) do
						for _, val in ipairs(value) do
							standReportEvent("43", key, val, "view")
						end
					end
				end
			elseif ID == defineTabIDs.tabMap then
				local cardTb = {
					"PERSONAL_INFO_MAP",
					"PLAYER_INFO_MAP"
				}
				compTb = {
					{
						"-",
						"MyWorksContent",
						"MyFavoritesContent",
						-- "AppraisalContent"
					},
					{
						"-",
						"PlayerWorksContent",
						"PlayerFavoritesContent",
						-- "AppraisalContent"
					}
				}
				for index=1,3 do
					standReportEvent(sceneTb[isMy], cardTb[isMy], compTb[isMy][index], "view")
				end
				if t_exhibitionMap.isExpert then
					standReportEvent(sceneTb[isMy], cardTb[isMy], "AppraisalContent", "view")
				end
			elseif ID == defineTabIDs.tabDynamic then
				-- local cardTb = {
				-- 	"PERSONAL_INFO_UPDATES",
				-- 	"PLAYER_INFO_UPDATES"
				-- }
				-- local compTb = {
				-- 	{
				-- 		"-",
				-- 		"SendUpdatesButton",
				-- 		"Updates",
				-- 		"Comment",
				-- 		"Like",
				-- 		"Avatar"
				-- 	},
				-- 	{
				-- 		"-",
				-- 		"UpdatesContent",
				-- 		"Updates",
				-- 		"Comment",
				-- 		"Like"
				-- 	}
				-- }
				-- for _, value in ipairs(compTb[isMy]) do
				-- 	standReportEvent(sceneTb[isMy], cardTb[isMy], value, "view")
				-- end
			elseif ID == defineTabIDs.tabAchievement then
				local cardTb = {
					"PERSONAL_INFO_MEDAL",
					"PLAYER_INFO_MEDAL"
				}
				compTb = {
					{
						"-",
						"CollectRewards",
						-- "Medal"
					},
					{
						"-",
						-- "Medal"
					}
				}
				for _, value in ipairs(compTb[isMy]) do
					standReportEvent(sceneTb[isMy], cardTb[isMy], value, "view")
				end
			end
		end
	end

	PassFirstInitPlayerExhibitionCenter = true
	-- 关闭设置页面
	if getglobal("PlayerCenterDataEdit"):IsShown() then
		getglobal("PlayerCenterDataEdit"):Hide();
	end
	
	--设置IP提示框层级
	PlayerExhibitionCenter_SetIPAddressFrameLevel(ID,defineTabIDs)

	-- LZLDO : 拟解决tab被子界面的背景图遮挡的层级问题
	if ID == defineTabIDs.tabHome then
		getglobal(uiName.."LeftTabBkgWhite"):Hide()
		getglobal(uiName.."LeftTabBkgHuaWen"):Hide()
	else
		getglobal(uiName.."LeftTabBkgWhite"):Show()
		getglobal(uiName.."LeftTabBkgHuaWen"):Show()
	end

	getglobal("PlayerExhibitionCenterGeniusBtn"):Hide()

	if ID == defineTabIDs.tabHome then
		t_exhibition:CheckGeniusGuide()
	end
	
	if ID == defineTabIDs.tabHome then
		-- 登陆页会初始化首页
		-- if t_ExhibitionModelView:GetOpenStatus() then
		-- 	t_ExhibitionModelView:UpdateModelView()
		-- end
		--刷新模型
		if getglobal(t_exhibition:getUiName()):IsShown() and IsFirstShowSkinModel then
			PEC_ShowSkinModel(true)
		end

		if GetInst("GeniusMgr"):IsOpenGeniusSys() and t_exhibition.isHost then
			getglobal("PlayerExhibitionCenterGeniusBtn"):Show()
		end
	elseif ID == defineTabIDs.tabMap then
		--存档
		-- PEC_ExhibitionMap();
	elseif ID == defineTabIDs.tabDynamic then
		--动态
		-- PEC_ExhibitionDynamic();

		-- --发帖按钮开关
		-- local pushBtn = getglobal("ExhibitionInfoMore");
		-- print("ns_version.posting_btn = ", ns_version.posting_btn);
		-- pushBtn:Hide();
		-- if t_exhibition.isHost and ns_version and check_apiid_ver_conditions(ns_version.posting_btn, false) then
		-- 	-- pushBtn:Show();
		-- end
	elseif ID == defineTabIDs.tabAchievement then
		--成就
		PEC_ExhibitionAchievement(ID);
	elseif ID == defineTabIDs.tabPhoto then
		--相册
		PEC_ExhibitionAlbum(ID);
		-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterAlbumBtn");
	elseif ID == defineTabIDs.tabMiniShow then
		if t_exhibition.isHost then
			standReportEvent("7", "PERSONAL_INFO_CONTAINER", "PersonalMatch", "click")
		else
			standReportEvent("43", "PERSONAL_INFO_CONTAINER", "PersonalMatch", "click")
		end
	end

	for i = 1, #t_Tab.ID do
		local checked = getglobal(uiName.."LeftTabBtn" .. i .. "Checked");
		local name = getglobal(uiName.."LeftTabBtn" .. i .. "Name");
		local pageName = t_Tab.pageName[i];
		local mvcCtrl = t_Tab.mvcCtrl[i];
		local idTemp = t_Tab.ID[i];

		if idTemp == ID then
			checked:Show();
			name:SetTextColor(255, 153, 63);

			--切换页面
			if pageName and pageName ~= "" then
				getglobal(pageName):Show();
			elseif mvcCtrl and mvcCtrl ~= "" then
				GetInst("UIManager"):Open(mvcCtrl, {uin = t_exhibition.uin, paras = inParas})
				if idTemp == defineTabIDs.tabWareHouse
				and GetInst("UIManager"):GetCtrl(mvcCtrl) then
					GetInst("UIManager"):GetCtrl(mvcCtrl).view.root:SetFrameLevel(2505)
				end
			end
		else
			checked:Hide();
			name:SetTextColor(158, 225, 231);

			--切换页面
			if pageName and pageName ~= "" then
				getglobal(pageName):Hide();
			elseif mvcCtrl and mvcCtrl ~= "" then
				if idTemp == defineTabIDs.tabWareHouse 
					and GetInst("UIManager"):GetCtrl(mvcCtrl) then
					GetInst("UIManager"):GetCtrl(mvcCtrl).view.root:SetFrameLevel(1011)
				end
				GetInst("UIManager"):Close(mvcCtrl)
			end
		end

		if idTemp == defineTabIDs.tabStudio then
			if idTemp == ID then
				--个人中心工作室入口
				GetInst("WorkSpaceInterface"):ShowWorkSpaceLobby()
				standReportEvent("7", "PERSONAL_INFO_CONTAINER", "StudioContent", "click")
				
				-- GetInst("WorkSpaceInterface"):ShowWorkSpace(2)
			else
				GetInst("WorkSpaceInterface"):CloseWorkSpace()
			end
		end
	end

	local uiName = t_exhibition:getUiName()
	if getglobal(uiName):IsShown() then
		PEC_ShowSkinModel();
	end

	GetInst("MiniUIManager"):CloseUI("SkinCollect_MainAutoGen",true)
	GetInst("MiniUIManager"):CloseUI("SkinCollect_TopicAutoGen",true)
	GetInst("MiniUIManager"):CloseUI("playerCenterDynamicDetailAutoGen",true)
	GetInst("MiniUIManager"):CloseUI("playerCenterDynamicsAutoGen",true)

	if ID == defineTabIDs.tabDressGallery then--装扮图鉴
		-- GetInst("MiniUIManager"):OpenUI("SkinCollect_Topic", "miniui/miniworld/SkinCollect_Topic", "SkinCollect_TopicAutoGen")
		if ThemeNum and ThemeNum>0 then
			GetInst("SkinCollectManager"):OpenTopic({themeNum = ThemeNum,query_uin = t_exhibition.uin, from = "skinCollect"})
		else
			GetInst("SkinCollectManager"):OpenMain({query_uin = t_exhibition.uin, from = "skinCollect"})
		end
		if t_exhibition.isHost then
			standReportEvent("7", "PERSONAL_MATCH", "ChaseLightPlan", "click")
		else
			standReportEvent("43", "PERSONAL_MATCH", "ChaseLightPlan", "click")
		end
	elseif ID == defineTabIDs.tabDynamic then
		inParas = inParas or {}
		inParas.fullScreen  = {Type="Normal"}
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/Chat"})
		GetInst("MiniUIManager"):OpenUI("playerCenterDynamics", "miniui/miniworld/playerCenter", "playerCenterDynamicsAutoGen",inParas)
	end
end

function PlayerExhibitionCenter_OnLoad()
	t_ExhibitionCenter:init()
	this:setUpdateTime(0.1);
	this:RegisterEvent("GIE_ENTER_WORLD");

	local uiName = t_exhibition:getUiName()

	--标题栏, 关闭按钮
	getglobal(uiName.."TitleName"):SetText(GetS(3447));
    UITemplateBaseFuncMgr:registerFunc(uiName.."CloseBtn", PlayerExhibitionCenterClose_OnClick, "个人中心关闭按钮");
	--帮助按钮
	UITemplateBaseFuncMgr:registerFunc(uiName.."HelpBtn", PEC_ExhitionInfoHelpBtn_OnClick, "个人中心帮助按钮");
	--初始化到首页
	ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabHome);

	--空页面提示
	getglobal("ExhibitionMapFrameEmptyFrameTip"):SetText(GetS(9085));	--暂时没有地图

	local FocusNumIcon = getglobal(uiName.."FocusNumIcon")
	local HotNumIcon = getglobal(uiName.."HotNumIcon")
	local RewardNumIcon = getglobal(uiName.."RewardNumIcon")
	local CharmNumIcon = getglobal(uiName.."CharmNumIcon")
	
	--设置按扭
	getglobal(uiName.."SetBtnName"):SetText(GetS(9008));
	getglobal(uiName.."SetBtnIcon"):SetSize(33, 31);
	getglobal(uiName.."SetBtnIcon"):SetTextureHuiresXml( "ui/mobile/texture2/common_icon.xml" );
	getglobal(uiName.."SetBtnIcon"):SetTexUV("icon_set.png");	
	
	--图标
	FocusNumIcon:SetTexUV("icon_fans");
	FocusNumIcon:SetSize(34, 31);
	HotNumIcon:SetTexUV("icon_map_hot_black");
	HotNumIcon:SetSize(24, 33);
	RewardNumIcon:SetTextureHuiresXml( "ui/mobile/texture2/common_icon.xml" );
	RewardNumIcon:SetTexUV("icon_reward_black");
	RewardNumIcon:SetSize(26, 29);
	CharmNumIcon:SetTexUV("icon_charm");
	CharmNumIcon:SetSize(29, 23);
	SandboxLua.eventDispatcher:CreateEvent(nil, "TITLESYSTEM_CHANGE");
	SandboxLua.eventDispatcher:SubscribeEvent(nil, "TITLESYSTEM_CHANGE", PlayerExhibitionCenterTitleChange)

	--天赋有关事件注册
	PlayerExhibitionCenter_GeniusSubscibeEvents()
end

function PlayerExhibitionCenterTitleChange(context)
	local paramData = context:GetParamData()
	local RoleInfoName 		= t_exhibition:getUiName().."RoleInfo"
	local TitleSystem		= getglobal(RoleInfoName.."TitleSystem") -- 称号系统
	if paramData.id > 0 then
		GetInst("TitleSystemInterface"):SetSelfCurrentTitleIcon(TitleSystem)
		needShowTitle = true;
	else
		TitleSystem:Hide();
		needShowTitle = false;
	end
	PEC_RefreshNewHomePage(t_exhibition:getUiName(),needShowTitle)
end

function PlayerExhibitionCenter_OnEvent()
	if arg1 == "GIE_ENTER_WORLD" then
		mComeBackInlineState = 0   --进游戏就清理掉回流的
		PEC_DynamicJumpOut = false; --每次打开界面还原标志位信息
		PEC_JumpToFrameName = "";  --还原跳转出去界面名字
		t_frameInfo:reset();
		t_ExhibitionCenter.reset();
		local uiName = t_exhibition:getUiName()
		if getglobal(uiName):IsShown() then
			getglobal(uiName):Hide()
		end
	end
end

local needShowTitle = false
function PlayerExhibitionCenter_OnShow(realShow)
	local uiName = t_exhibition:getUiName()
	getglobal(uiName.."RoleInfoWorkSapce"):Hide()
	local isThreeVersion = t_exhibition:isThreeVerOpen()

	getglobal("PlayerExhibitionCenterIPAddressFrameContent"):Hide()

	--左侧导航栏
	local posY = 122
	local t_Tab = t_ExhibitionCenter.leftTabs;
	local showTabCfgs = t_ExhibitionCenter:getLeftShowCfgs(t_exhibition.isHost, isThreeVersion)
	local defineTabIDs = t_ExhibitionCenter.define
	for i = 1, #t_Tab.ID do
		local tabBtn = getglobal(uiName.."LeftTabBtn" .. i);
		local name = getglobal(uiName.."LeftTabBtn" .. i .. "Name");
		local icon = getglobal(uiName.."LeftTabBtn" .. i .. "Icon");
		icon:SetTextureHuiresXml(t_Tab.iconRes[i])
        icon:SetTexUV(t_Tab.iconUv[i]);
		tabBtn:SetClientID(t_Tab.ID[i])
		tabBtn:SetPoint("topleft", uiName.."LeftTab", "topleft", 0, posY);
		name:SetText(GetS(t_Tab.nameID[i]));

		if showTabCfgs[t_Tab.ID[i]] then
			tabBtn:Show()
			posY = posY + 79
			if defineTabIDs.tabStudio == t_Tab.ID[i] then 
				standReportEvent("7", "PERSONAL_INFO_CONTAINER", "StudioContent", "view")
			elseif defineTabIDs.tabMiniShow == t_Tab.ID[i] then 
				if t_exhibition.isHost then
					standReportEvent("7", "PERSONAL_INFO_CONTAINER", "PersonalMatch", "view")
				else
					standReportEvent("43", "PERSONAL_INFO_CONTAINER", "PersonalMatch", "view")
				end
				
			end
		else
			tabBtn:Hide()
		end
	end	

	PEC_DynamicJumpOut = false; --每次打开界面还原标志位信息
	PEC_JumpToFrameName = "";  --还原跳转出去界面名字
	PEC_SetCloseCallBack(nil); --打开的时候重置一下关闭回调函数
	
	--迷你工坊标题栏会挡住当前标题栏
	-- local miniWorks = getglobal("MiniWorksFrame");
	-- if miniWorks:IsShown() then
	-- 	MiniWorksFrameCloseBtn_OnClick()
	-- end

	--关闭互通存档界面
	local playArchivs = getglobal("PlayerArchiveSlots");
	if playArchivs and playArchivs:IsShown() then
		GetInst("UIManager"):Close("PlayerArchiveSlots");
	end

	if IsLookSelf() and check_creator_link_open() then
		getglobal(uiName.."FramerCenterLink"):Show();
		t_exhibition:NewStandReport("PERSONAL_INFO_TOP", "AuthorCenter","view")
	else
		getglobal(uiName.."FramerCenterLink"):Hide();
	end

	-- 版本首页位置调整
	PEC_RefreshNewHomePage(uiName,needShowTitle)	

	if isThreeVersion and t_exhibition.uin then
		-- 新版首页拉取成就信息
		PEC_ExhibitionAchievement();
	end
	
	if not ClientCurGame:isInGame() then
		PreEnterMainMenuBy = EnterMainMenuInfo.EnterMainMenuBy
		EnterMainMenuInfo.EnterMainMenuBy = 'PlayerCenter'
	end

	PEC_UpdatePlayerCenterState()

	--更新一下 个人中心 在线时长统计参数 区分自己的 还是别人的
	UIDisplayStatisticsUpdateParamForPlayerCenter(AccountManager:getUin() == t_exhibition.uin)
	local ui_CreditScore			= getglobal("PlayerExhibitionCenterRoleInfoCreditScore")
	local ui_CreditscoreBtn			= getglobal("PlayerExhibitionCenterRoleInfoCreditscoreBtn")
	ui_CreditScore:SetText(GetS(111404,"0"))

	ui_CreditscoreBtn:Hide()
	ui_CreditScore:Hide()
	if GetInst("CreditScoreService") then
		GetInst("CreditScoreService"):ReqGetCreditScore(function(data)
			if data and not tolua.isnull(ui_CreditScore) then
				ui_CreditScore:SetText(GetS(111404,data.score))
				if AccountManager:getUin() == t_exhibition.uin then
					GetInst("CreditScoreModel"):SetCreditScore(data.score)
				end

				ui_CreditScore:Show()
				if t_exhibition.isHost then
					ui_CreditscoreBtn:Show()
				else
					ui_CreditscoreBtn:Hide()
				end

			end
		end,t_exhibition.uin)
	end
	local RoleInfoName 		= t_exhibition:getUiName().."RoleInfo"
	local TitleSystem		= getglobal(RoleInfoName.."TitleSystem") -- 称号系统
	if GetInst("TitleSystemInterface"):TitleIsOPen() then
		if AccountManager:getUin() == t_exhibition.uin then
			GetInst("TitleSystemInterface"):GetSelfTitleInfo(function (code,data)
				if code == 0 then
					if data.curTitle > 0 then
						needShowTitle = true;
						GetInst("TitleSystemInterface"):SetSelfCurrentTitleIcon(TitleSystem)
					else
						needShowTitle = false;
					end
					PEC_RefreshNewHomePage(t_exhibition:getUiName(),needShowTitle)
				end
			end)
		else
			GetInst("TitleSystemInterface"):SetTitleIcon(TitleSystem,t_exhibition.uin,function (id)
				if id > 0 then
					needShowTitle = true;
				end
				PEC_RefreshNewHomePage(t_exhibition:getUiName(),needShowTitle)
			end)
		end
	end
	GetInst("ChatHelper"):OpenChatHoverBallView()

	--获取玩家创作者身份信息
	PEC_ReqUserCreatorInfo()

	--刷新天赋特长
	--不开放特长系统 隐藏封装在方法内
	PEC_RefreshGeniusShow(t_exhibition.isHost, realShow)
	GetInst("SkinCollectManager"):CheckRedtag()

	
	GetInst("PlayerCenterManager"):OrganizeSkinListData()
	GetInst("PlayerCenterManager"):OrganizeMountsListData()

	getglobal('PlayerExhibitionCenterBestPartnerBtn'):Show()
	if IsInHomeLandMap and IsInHomeLandMap() then -- 从家园里打开不显示
		getglobal('PlayerExhibitionCenterBestPartnerBtn'):Hide()
	end
end

--上报特长相关的埋点
function PEC_ReportGeniusRef(realShow)
	if realShow then
		--真正的show 才上报埋点
		--standby1:特长类型_等级，没有装备特长时显示0
		--standby2: 1.有引导气泡  2.无引导气泡
		local stb1 = 0
		local gType = GetInst("GeniusMgr"):GetCurGeniusType()
		if gType then
			local gLv = GetInst("GeniusMgr"):GetGeniusLvByType(gType)
			stb1 = gType.."_"..gLv
		end

		local stb2 = 2
		if GetInst("GeniusMgr"):CheckCanGuide(1) then
			stb2 = 1
		end
		standReportEvent("7", "PERSONAL_INFO_HOMEPAGE", "Skill", "view", {standby1=stb1, standby2=stb2})
	end
end

function PEC_RefreshNewHomePage(uiName,titleShow)
	-- 个人信息
	local uiName 			= uiName or t_exhibition:getUiName()
	local RoleInfoName 		= uiName.."RoleInfo"
	local RoleInfo 			= getglobal(RoleInfoName)
	--local Name 				= getglobal(RoleInfoName.."Name")
	local NameCheck 		= getglobal(RoleInfoName.."NameCheck")
	local Uin 				= getglobal(RoleInfoName.."Uin")
	local CreditScore 		= getglobal(RoleInfoName.."CreditScore")

	local CopyUin 			= getglobal(RoleInfoName.."CopyUin")
	local CreditscoreBtn 			= getglobal(RoleInfoName.."CreditscoreBtn")

	local Head 				= getglobal(RoleInfoName.."Head")
	local ui_homeland 		= getglobal(uiName.."HomeLandBtn") --家园按钮
	local ui_MoodFrame 		= getglobal(uiName.."MoodFrame")
	local ui_Friend 		= getglobal(uiName.."Friend");
	local ui_attention  	= getglobal(uiName.."Focus");
	local ConnoisseurBbtn   = getglobal(uiName.."ConnoisseurBtn") -- 鉴赏家
	local workSpaceBtn      = getglobal(uiName.."RoleInfoWorkSapce") -- 工作室
	local moodBtn 			= getglobal(uiName.."MoodBtn");
	local lockBtn			= getglobal(uiName.."LockBtn")
	local TitleSystem		= getglobal(RoleInfoName.."TitleSystem") -- 称号系统

	-- 热度 好友数量
	local ui_friendNum 		= getglobal(uiName.."FriendNum");
	local ui_rewardNum 		= getglobal(uiName.."RewardNum");
	local ui_focusNum 		= getglobal(uiName.."FocusNum");
	local ui_hotNum 		= getglobal(uiName.."HotNum");
	local ui_charmNum 		= getglobal(uiName.."CharmNum");


	local SlidingFrameName 				= getglobal(RoleInfoName.."SlidingFrameName")
	local Plane 				= getglobal(RoleInfoName.."SlidingFrameNamePlane")
	local Name2 				= getglobal(RoleInfoName.."SlidingFrameNameName2")

	local realName          =  getglobal(RoleInfoName.."RealName")

	SlidingFrameName:resetOffsetPos(); --重置滚动setCurOffsetX(0)--

	local newVersionAdjust = function(item, pos, realUiName, posY)
		if item then
			local itemName = item:GetName()
			getglobal(itemName.."Line1"):Hide()
			getglobal(itemName.."Line2"):Hide()
			getglobal(itemName.."Font"):Hide()
			item:SetWidth(106)
			item:SetHeight(24)

			local Icon = getglobal(itemName.."Icon")
			local Font2 = getglobal(itemName.."Font2")
			Font2:Show()

			Icon:SetPoint("bottomleft", itemName, "bottomleft", 0, 0)
			Font2:SetPoint("left", Icon:GetName(), "right", 10, 4)
			posY = posY or 20
			item:SetPoint("bottomleft", realUiName, "bottomleft", pos, posY)
		end
	end

	if t_exhibition:isThreeVerOpen() then
		-- 个人信息位置调整
		RoleInfo:SetWidth(578)
		RoleInfo:SetPoint("topright", uiName, "topright", 0, 72)

		local headName = Head:GetName()
		local posX = 110
		SlidingFrameName:SetPoint("topleft", headName, "topleft", posX, 10)
		
		-- 关注按钮移动到昵称栏目
		-- if ui_attention:IsShown() then
		-- 	ui_attention:SetPoint("left", Uin:GetName(), "right", -8, 0)
		-- 	ui_attention:SetWidth(30)  -- 50
		-- 	ui_attention:SetHeight(32)	-- 53
		-- 	CopyUin:SetPoint("left", Uin:GetName(), "right", 10 + ui_attention:GetWidth(), 0)
		-- else
			CopyUin:SetPoint("left", Uin:GetName(), "right", -8, 0)
		-- end
		
		-- workSpaceBtn:Show()
		if titleShow then
			TitleSystem:Show();
			Uin:SetPoint("left", headName, "left", posX, 30)
			TitleSystem:SetPoint("left", headName, "left", posX, 0)
	
			if workSpaceBtn:IsShown() then
				workSpaceBtn:SetPoint("left", CopyUin:GetName(), "right", 24, 0)
				CreditScore:SetPoint("left", workSpaceBtn:GetName(), "right", -10, 0)
			else
				CreditScore:SetPoint("left", CopyUin:GetName(), "right", 24, 0)
			end
		else
			TitleSystem:Hide();
			Uin:SetPoint("left", headName, "left", posX, 0)
			CreditScore:SetPoint("left", headName, "left", posX, 30)
			if workSpaceBtn:IsShown() then
				workSpaceBtn:SetPoint("left", CopyUin:GetName(), "right", 24, 0)
			end
		end
		

		newVersionAdjust(ui_friendNum, posX, headName)
		posX = posX + 66
		newVersionAdjust(ui_focusNum, posX, headName)
		posX = posX + 130
		newVersionAdjust(ui_hotNum, posX, headName)
		posX = posX + 113
		newVersionAdjust(ui_charmNum, posX, headName, 16)
		-- 个人信息位置调整 备注名（真实昵称）
		local nickName = PEC_GetShowPlayerNickName(t_exhibition.isHost)
		local nameWidth = Name2:GetTextExtentWidth(nickName)
		if realName:IsShown() and not t_exhibition.isHost then --如果有备注
			local note = GetFriendNote(t_exhibition.uin) or ""
			nameWidth = Name2:GetTextExtentWidth(note)
		end

		local bVip = GetInst('MembersSysMgr'):IsMemberByUin(t_exhibition.uin)
		local vipIconWidth = bVip and VIP_ICON_WIDTH or 0
		local startPosX = nameWidth + vipIconWidth
		if startPosX > 190 then
			startPosX = 190
		end

		if nameWidth > 190 then
			Name2:SetWidth(nameWidth)
			Plane:SetSize(nameWidth+2, 30)
		end
		
		if NameCheck:IsShown() then
			NameCheck:SetPoint("left", SlidingFrameName:GetName(), "left", startPosX, -4)
			startPosX = startPosX + NameCheck:GetTextExtentWidth(GetS(20669))
		else
			startPosX = startPosX + 10
		end

		
		if realName:IsShown() and not t_exhibition.isHost then
			realName:SetPoint("left", SlidingFrameName:GetName(), "left", startPosX, -4)
			local nickName = GetFriendNote(t_exhibition.uin) or ""
			startPosX = startPosX + realName:GetTextExtentWidth(nickName)
		else
			startPosX = startPosX + 10
		end

		--增加性别开关
		if not if_show_gender() then
			getglobal("PlayerExhibitionCenterRoleInfoGender"):Hide()
		end

		local listItem = nil
		local list = UIAchievementMgr.RoleInfoIcon
		for index = 1, #list do
			listItem = getglobal(list[index].name)
			-- listItem:Show()
			if listItem and listItem:IsShown() then
				listItem:SetPoint("left",SlidingFrameName:GetName(),"left", startPosX, -6)
				startPosX = startPosX + listItem:GetWidth() + 10
			end
		end

		-- 家园
		ui_homeland:SetPoint("topleft", uiName, "topleft", 210, 72)
		-- getglobal(ui_homeland:GetName().."Title"):Hide()
		-- local homeLandIcon = getglobal(ui_homeland:GetName().."Icon")
		-- homeLandIcon:SetTexUV("icon_garden")
		-- homeLandIcon:SetWidth(30)
		-- homeLandIcon:SetHeight(36)

		-- 心情泡泡
		ui_MoodFrame:SetPoint("topleft", uiName, "topleft", 293, 118)

		-- 添加好友
		-- ui_Friend:SetPoint("bottom", t_ExhibitionModelView:GetUiName(), "bottom", 0, -38)
		--if ConnoisseurBbtn:IsShown() then
		--	ConnoisseurBbtn:SetPoint("top", ui_homeland:GetName(), "bottom", 0, 20)
		--end
	else
		if ui_Friend:IsShown() then
			getglobal(ui_Friend:GetName().."Title"):Hide()		
			ui_Friend:SetPoint("center", moodBtn:GetName(), "center", 0, 0)
		end
	
		if ui_attention:IsShown() then
			getglobal(ui_attention:GetName().."Title"):Hide()		
			ui_attention:SetPoint("center", lockBtn:GetName(), "center", 0, 0)
		end
	end
end

-- 特性引导update
function PlayerExhibitionCenterGuide_OnUpdate()
	t_exhibition:PlayGeniusGuideEntryGuideAnim()
end

function PlayerExhibitionCenter_OnUpdate()
	if downloadMapSign then
		local changes = {};
		if getglobal("ExhibitionMapFramePage1"):IsShown() then
			local id = t_exhibitionMap.curSelectTab;
			local maplist = t_exhibitionMap.tab[id].maplist;
			for i = 1, #(maplist) do
				local m = maplist[i];
				if t_exhibition.isHost and id  == 3  then 
					table.insert(changes, {"ExhibitionMapFramePage1Cell"..i, m});
				else
					table.insert(changes, {"ExhibitionMapFramePage1Cell"..i, m});
				end
			end
		end

		--编辑面板下载按钮
		if getglobal("ExhibitionMapFrameEditFrame"):IsShown() then 
			local editMap = t_exhibitionMap.getCurSelectMap();
			if editMap then 
				table.insert(changes, {"ExhibitionMapFrameEditFrame", editMap})
			end
		end

		for i = 1, #changes do
			local archui = getglobal(changes[i][1]);
			local map = changes[i][2];
			UpdateSingleArchiveDownloadState(archui, map);
		end

		for i = 1, #changes do
			local map = changes[i][2];
			if map then 
				state = GetMapDownloadBtnState(map); 
				if state.buttontype == DOWNBTN_PAUSE_DOWNLOAD then  
					downloadMapSign = true;
					break;
				else
					downloadMapSign = false;
				end
			end
		end
	end

	--心情面板计时
	PlayerExhibitionCenterMood_UpdateTime();
	UpdateUI_WaterMark("PlayerExhibitionCenterWaterMarkFrameFont")
end


function PlayerExhibitionCenter_OnHide()
	IsFirstShowSkinModel = false
	needShowTitle = false
	ZoneDetachPlayerCenterUIModel();
	CloudServerRoomAuthorityMgr:MgrPanelJump(2020)
	getglobal("ExhibitionMapFrameEditFrame"):Hide();
	-- 清除个人中心角色音效
	ClientMgr:playStoreSound2D("")

	if PEC_JumpToFrameName == "" then
		t_ExhibitionCenter.reset();
	end
	PEC_SetCloseCallBack(nil); --关闭的时候重置一下关闭回调函数

	local t_Tab = t_ExhibitionCenter.leftTabs;
	for i = 1, #t_Tab.ID do
		local mvcCtrl = t_Tab.mvcCtrl[i];
		if mvcCtrl and mvcCtrl ~= "" then
			if t_Tab.ID[i] == t_ExhibitionCenter.define.tabWareHouse
				and GetInst("UIManager"):GetCtrl(mvcCtrl) then
				GetInst("UIManager"):GetCtrl(mvcCtrl).view.root:SetFrameLevel(1011)
			end
			GetInst("UIManager"):Close(mvcCtrl)
		end
	end	

	if ZoneReStore2Root() then
		--恢复到老的空间
		return;
	end

	local skinCollectViewData = GetInst("SkinCollectManager"):getStoreViewData()
	if skinCollectViewData and skinCollectViewData.newRestoreData then
		local param = GetInst("SkinCollectManager"):getStoreViewData()
		GetInst("SkinCollectManager"):TurnOnReStore();
		GetInst("SkinCollectManager"):ReStoreViewData();
	end

	--解决退回到"LobbyFrame"界面模型卡住的问题
	if IsLobbyShown() then
		print("PlayerExhibitionCenter_OnHide:go back LobbyFrame:");
		local roleview = getglobal("LobbyFrameRoleView");
		-- roleview:playActorAnim(100108, 0);
		SetLobbyFrameModelView();
	end

	--从好友界面跳转过来，关闭几面还是要回去好友界面的
	print("PEC_FromJumpFrameName = ", PEC_FromJumpFrameName);
	if PEC_FromJumpFrameName ~= "" and getglobal(PEC_FromJumpFrameName) then
		if "ResourceShopSearch" == PEC_FromJumpFrameName then
			GetInst("UIManager"):Show("ResourceShopSearch");
			GetInst("UIManager"):Show("ResourceShop");
		else
			getglobal(PEC_FromJumpFrameName):Show();
		end

		PEC_FromJumpFrameName = "";
	end

	--游戏中关闭界面时，隐藏鼠标
	local isShown = getglobal("RoomUIFrame"):IsShown(); --游戏世界内房间信息打开个人中心的操作鼠标显示文问题
	if ClientCurGame:isInGame() and not isShown then
		ClientCurGame:setOperateUI(false);
	end

	if not ClientCurGame:isInGame() then
		
	end

	--把RoomFrame的层级设置回来
	-- SetRoomFrameLevel(1500)

	if not IsUIFrameShown("TeamupMain") then
		GetInst("MiniUIManager"):HideUI("ChatHoverBallAutoGen")
	end

	if GetInst("MiniUIManager"):GetCtrl("ArchiveInfoDetail") then
		GetInst("MiniUIManager"):GetCtrl("ArchiveInfoDetail"):RefreshBodyView()
	end
	if GetInst("SkinCollectManager") then
		GetInst("SkinCollectManager"):HideAllWindows()
	end

	--关闭个人形象和个人头像编辑界面
	if GetInst("MiniUIManager"):IsShown("main_personalImage_setting") then
		GetInst("MiniUIManager"):CloseUI("main_personalImage_settingAutoGen", true)
	end
	if GetInst("MiniUIManager"):IsShown("main_personalHead_setting") then
		GetInst("MiniUIManager"):CloseUI("main_personalHead_settingAutoGen", true)
	end

	if GetInst("MiniUIManager"):IsShown("playerCenterDynamics") then
		GetInst("MiniUIManager"):CloseUI("playerCenterDynamicsAutoGen",true)
		GetInst("MiniUIManager"):CloseUI("playerCenterDynamicDetailAutoGen",true)
	end
	
end

function PEC_AddFriendBtn_OnClick(paramUin)
	if t_exhibition:CheckOtherProfileBlackStat(paramUin) then 
		ShowGameTips(string.format(GetS(10593), GetS(4094)));
		return false, "banned";
	end

	local uin = paramUin or t_exhibition.uin;

	if getglobal("MiniWorksFrame"):IsShown()	then
		SetStatisticIdAndSrc(6000,"MiniWorksAddFriend");
	end

	if not isShouQPlatform() then
		if GetFriendDataByUin(uin)~=nil then
			ShowGameTips(GetS(38), 3);
			return false, friendservice.ret_code.is_friend;
		end
	end
	
	if GetMyFriendNum() >= MaxFriends then
		ShowGameTips(GetS(1112927), 3);
		return false, friendservice.ret_code.friend_limit;
	end

	local retCode = -1
	if isShouQPlatform() then
		local fridData = GetFriendDataByUin(uin)
		if fridData and  fridData.relation and  fridData.relation.is_qq then
			retCode = ReqAddQQFriendSync(uin)
		else
			retCode = AddUinAsFriendSync(uin);
		end
	else
		retCode = AddUinAsFriendSync(uin);
	end
	standReportEvent("43", "PLAYER_INFO_HOMEPAGE", "FriendRequestButton", "click", {standby1=uin})
	t_exhibition.self_data_dirty = true;
	-- statisticsGameEvent(710, "%%lls", "PlayerCenterAddFriend")

	return retCode and (retCode == 0 or retCode == friendservice.ret_code.has_apply), retCode
end

function PEC_ConnoisseurBtn_OnClick()
	local cardid = IsLookSelf() and "PERSONAL_INFO_HOMEPAGE" or "PLAYER_INFO_HOMEPAGE"
	standReportEvent(IsLookSelf() and "7" or "43", cardid, "ConnoisseurIcon", "click")
	if t_exhibition.isHost then
		getglobal("ConnoisseurInfoFrame"):Show();
		if not getkv("connoisseur_guide") then
			setkv("connoisseur_guide", true);
			getglobal("PlayerExhibitionCenterConnoisseurBtnEffect"):Hide();
		end
	else
		getglobal("ConnoisseurHelpFrame"):Show();
	end
end

function PEC_ExhitionInfoHelpBtn_OnClick()
	standReportEvent("7", "PERSONAL_INFO_TOP", "Help", "click")
	getglobal("FriendHelpFrame"):Show();
	getglobal("FriendHelpFrameBoxContent"):SetText(GetS(20537), 98, 65, 48);
	getglobal("FriendHelpFrameTitleName"):SetText(GetS(3447));

end

function PEC_AddAttentionBtn_OnClick()
	--控制点击频率
	if not GetInst("CommUIInterfaceCtrl"):CanButtonBeClicked(1) then
		--交互太频繁了哦，请放松，慢点节奏
		ShowGameTips(GetS(41500))
		return
	end

	if t_exhibition:CheckOtherProfileBlackStat() then 
		ShowGameTips(string.format(GetS(10593), GetS(4738)));
		return;
	end

	standReportEvent("43", "PLAYER_INFO_HOMEPAGE", "FollowButton", "click")
	t_exhibition.self_data_dirty = true

	local uin = t_exhibition.uin
	local bCanFollow = CanFollowPlayer(uin)
	local bHaveFollowed = false

	if bCanFollow then
		--关注
		ReqFollowPlayer(uin, true)
		bHaveFollowed = true
	else
		--取消关注
		ReqFollowPlayer(uin, false)
		bHaveFollowed = false
	end

	--因为关注和取消关注'ReqFollowPlayer'是个异步请求, 这里其实还没有返回, 故用'bHaveFollowed'来标记
	PEC_UpdateFollowBtnState_Ext(uin, bHaveFollowed)

	-- --订阅
	-- MiniworksSetOrCancelsubscribe(false, t_exhibition.uin)
	local playerInfo =  t_exhibition.getPlayerInfo()
	if playerInfo then 
		if bHaveFollowed then
			playerInfo.attention_count = playerInfo.attention_count + 1
			-- statisticsGameEvent(711, "%%lls", "PlayerCenterAddAttention")

			-- if getglobal("MiniWorksFrameSearch1"):IsShown() then
			-- 	statisticsGameEventNew(41110, "follow", AccountManager:getUin(), t_exhibition.uin)
			-- end
		else
			playerInfo.attention_count = playerInfo.attention_count - 1
			if playerInfo.attention_count < 0 then
				playerInfo.attention_count = 0
			end
		end

		getglobal("PlayerExhibitionCenterFocusNumFont"):SetText(playerInfo.attention_count)
	end
end

--刷新关注按钮状态
function PEC_UpdateFollowBtnState_Ext(uin, bHaveFollowed)
	-- local bCanFollow = CanFollowPlayer(uin);	--'CanFollowPlayer'这个函数里面有一个判断是:是好友则无法关注
	local bCanFollow = CanFollowPlayer(uin)
	-- local friendData = GetFriendDataByUin(uin)

	-- if friendData then 
	-- 	bCanFollow = false
	-- else 
	-- 	bCanFollow = true
	-- end
	if uin == AccountManager:getUin() then 
		bCanFollow = false
	end

	if nil == bHaveFollowed then
		local playerData = GetFlowingPlayerData(uin)
		if playerData then 
			bHaveFollowed = true 
		else 
			bHaveFollowed = false 
		end
	end

	-- --bCanFollow:是否可以关注
	-- --bHaveFollowed:是否已经关注
	local frame_name = t_exhibition:getUiName()
	local btn  		 = getglobal(frame_name.."Focus")
	local icon  	 = getglobal(frame_name.."FocusIcon")
	if false == bCanFollow then
		btn:Disable()
		return
	end

	btn:Enable()

	if bHaveFollowed then
		icon:SetTexUV("icon_like_h")
	else
		icon:SetTexUV("icon_like_n")
	end
end

function PEC_MapFrameCell_OnClick(index)
	local id ;
	if index == nil then
		id = this:GetClientID() + 1
	else
		id = index;
	end
	if getglobal("PlayerExhibitionCenterIPAddressFrameContent"):IsShown() then
		getglobal("PlayerExhibitionCenterIPAddressFrameContent"):Hide()
	end
	t_exhibitionMap.curSelectMapIndex = id;
	local map = t_exhibitionMap.tab[t_exhibitionMap.curSelectTab].maplist[id];
	if map then 
		-- ShowMapDetail(map, {fromUiLabel=CurLabel, fromUiPart=nil});
		ExhibitionMapFramePage1_standReportItem(id,map,"click")

		local frame_name = "ArchiveInfoFrameIntroduce" 
		local btn_start = getglobal(frame_name .. "StarGameBtn")
		local btn_online =getglobal(frame_name .. "StarOnlineBtn")
		local btn_edit = getglobal(frame_name .. "RecordEditBtn")
		local btn_play = getglobal(frame_name .. "RecordPlayBtn")
		local btn_collect = getglobal(frame_name .. "CollectBtn")
		local btn_func = getglobal(frame_name .. "MiniworksFuncBtn")

		-- getglobal("ArchiveInfoFrame"):SetClientID(map.owid);
		GetInst("CommentSystemInterface"):CloseArchiveInfoFrame()
		ShowMiniWorksMapDetailByMapID(map.owid);
		-- print("PEC_MapFrameCell_OnClick(): map.owid = ", map.owid);
		btn_start:Hide();
		btn_online:Hide();
		btn_edit:Hide();
		btn_play:Hide();
		btn_func:Hide();
		if t_exhibition.isHost then 
			btn_collect:Hide();
		end

		local index, btnName = GetCreateRoomUI2WorldId(map.owid); --判断是不是在存档内
		if index then
			if ArchiveWorldDesc and ArchiveWorldDesc.worldtype == 9 then
				--btn_edit:Show()
			else 
				btn_start:Show();
				btn_online:Show();
				btn_collect:Hide();
			end
		else
			if t_exhibitionMap.curSelectTab ==2 and t_exhibition.isHost then 
				getglobal("ArchiveInfoFrameIntroduceCollectBtnCancel"):Show();
				getglobal("ArchiveInfoFrameIntroduceCollectBtnCollect"):Hide();
				getglobal("ArchiveInfoFrameIntroduceCollectBtnNormal"):SetTexUV("mngf_btn04");
				getglobal("ArchiveInfoFrameIntroduceCollectBtnPushedBG"):SetTexUV("mngf_btn04");
				btn_collect:Show();
			end
		 	
		 	btn_func:Show();
		end

		--自己个人中心 收藏地图详细图显示问题，单独做处理
		GetMapThumbnail(map, "ArchiveInfoFrameIntroducePic");
	end
end

function PEC_FriendNumBtn_OnClcik(index)
	if index == 1 then
		ShowGameTips(GetS(209))
	elseif index == 2 then 
		ShowGameTips(GetS(210))
	elseif  index == 3 then 
		ShowGameTips(GetS(20535))
	end 
end

function PEC_CharmNumBtn_OnClick()
	local inst = GetInst("FriendGiftDataMgr")
	if not inst then
		return
	end

	local uiName 			= t_exhibition:getUiName()
	local ui_charmNum 		= getglobal(uiName.."CharmNumFont2");
	local curCharm = tonumber(ui_charmNum:GetText())
	if t_exhibition.uin == AccountManager:getUin() then
		standReportEvent("2210", "RECEIVE", "ClickReceive", "click", {standby1 = curCharm, standby2 = t_exhibition.uin, standby3 = 1})
	else
		standReportEvent("2210", "RECEIVE", "ClickReceive", "click", {standby1 = curCharm, standby2 = t_exhibition.uin, standby3 = 2})
	end
	if curCharm == 0 then
		inst:OpenRuleUI(1)
	else
		inst:OpenGiftUI(t_exhibition.uin, 2, 1)
	end
	--if #inst.data.get_gift == 0 then
	--	inst:OpenRuleUI()
	--else
	--end
end

--新家园地图
function PEC_HomeLand_OnClick()
	if IsEnableHomeLand and IsEnableHomeLand() then
		standReportEvent("7", "PERSONAL_INFO_HOMEPAGE", "HomelandButton", "click")
		standReportEvent("43", "PLAYER_INFO_HOMEPAGE", "HomelandButton", "click", {
			standby1 = (UinGetMyFriendsBrief(t_exhibition.uin or 0) and {"1"} or {"0"})[1],
		})
		if ClientCurGame:isInGame() and not IsInHomeLandMap() then	--已经在其他存档内了
			ShowGameTips(GetS(1204), 3)
			return;
		end

		local teamupSer = GetInst("TeamupService")
		if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
			ShowGameTips(GetS(26045))
			return
		end
		
		local uin = t_exhibition.uin or AccountManager:getUin()
		OpenHomeLandByUin(uin)
		local uiName = t_exhibition:getUiName()
		if IsUIFrameShown(uiName) then
			getglobal(uiName):Hide()
		end
		if IsUIFrameShown("FriendFrame") then
			getglobal("FriendFrame"):Hide()
		end
		if IsUIFrameShown("SearchFriendFrame") then
			getglobal("SearchFriendFrame"):Hide()
		end
		if IsLobbyShown() then
			HideLobby() --存档界面
		end
		local ResourceShopCtrl = GetInst("UIManager"):GetCtrl("ResourceShop","uiCtrlOpenList")
		if ResourceShopCtrl then
			ResourceShopCtrl:CloseBtnClicked()
		end
		if IsUIFrameShown("GroupFriendFrame") then
			getglobal("GroupFriendFrame"):Hide()
		end
	end
end

function PEC_GeniusBtn_OnClick()
	--不开放特长系统
	if not GetInst("GeniusMgr"):IsOpenGeniusSys() then
		return
	end

	t_exhibition:SetGeniusGuideEntryGuideVisible(false)

	--1.个人中心、2.开始游戏 3.游戏内背包 4.仓库使用
	local guide = GetInst("GeniusMgr"):CheckCanGuide(1)
	GetInst("GeniusMgr"):OpenGenius({showGuide = guide, from = 1})
	
	--隐藏IP详情
	local IPAddressFrameContent = getglobal("PlayerExhibitionCenterIPAddressFrameContent")
	if IPAddressFrameContent then
		IPAddressFrameContent:Hide()
	end
end

function PEC_RewardNumBtn_OnClcik()
	ShowGameTips(GetS(21788));
end

function PEC_PhotoCell_OnClick()
	if  t_exhibition.close_upload == 1 or t_exhibition.isHost ~= true then
		return;
	end
	local id = this:GetClientID();
	t_ExhibitionCenter.selectPhotoId = id;
	getglobal("ExhibitionPhotoEdit"):Show();
end

function PEC_ExhibitionPhotoEdit_OnClick(act)
	if act == 0 then 
		getglobal("ExhibitionPhotoEdit"):Hide();
	elseif act == 1 then 
		if ns_data.IsGameFunctionProhibited("u", 10579, 10580) then 
			return 
		end
		PEC_BeginUploadPhoto(t_ExhibitionCenter.selectPhotoId);
		getglobal("ExhibitionPhotoEdit"):Hide();
	elseif act == 2 then
		seq_ = t_ExhibitionCenter.photoServerIndex[t_ExhibitionCenter.selectPhotoId];
		ns_http.func.del_user_profile_photo(seq_ , PEC_PhotoEditDel_cb );
		t_exhibition.self_data_dirty = true;
		getglobal('ExhibitionPhotoEdit'):Hide();
	end
end

function PlayerExhibitionCenterClose_OnClick()
	ReportTraceidMgr:setTraceid("")
	GetInst("MiniUIManager"):CloseUI("SkinCollect_MainAutoGen",true)
	GetInst("MiniUIManager"):CloseUI("SkinCollect_TopicAutoGen",true)
	GetInst("MiniUIManager"):CloseUI("playerCenterDynamicDetailAutoGen",true)
	GetInst("MiniUIManager"):CloseUI("playerCenterDynamicsAutoGen",true)

	EnterMainMenuInfo.PlayerCenterBackInfo = nil
	--由于可以从很多地方跳转到个人中心，就会导致原先的EnterMainMenuBy被个人中心覆盖，故主动关闭时就还原EnterMainMenuBy，保证原先的链路正常
	if PreEnterMainMenuBy then
		EnterMainMenuInfo.EnterMainMenuBy = PreEnterMainMenuBy
		PreEnterMainMenuBy = nil
	end
	if GetInst("WorkSpaceInterface"):CloseOpenList() then
		return
	end
	-- getglobal('WorkSpaceDetail'):Hide();
	if IsUIFrameShown("WorkSpaceDetail") or IsUIFrameShown("WorkSpaceSearchLobby") then
		return
	end

	if IsLookSelf() then
		standReportEvent("7", "PERSONAL_INFO_TOP", "close", "click")
	else
		standReportEvent("43", "PLAYER_INFO_TOP", "close", "click")
	end
	ZoneCloseBtnClick_SetReStoreState();

	if t_exhibition.closeCallBackFunc and type(t_exhibition.closeCallBackFunc) =="function" then
		local func = t_exhibition.closeCallBackFunc
		threadpool:work(function()
			threadpool:wait(0.01)
			func()
		end)
	end
	
    getglobal(t_exhibition:getUiName()):Hide();
	RefreshMiniLobbyExRoleView() --mark by hfb for new minilobby
	if isEnableNewLobby and isEnableNewLobby() then
		RefreshMapArchiveListRoleView();
	end
	curClickID = nil
	threadpool:wait(gen_gid(),0.1,{tick=function()
		threadpool:notify("teamup.checkMinBtn")
	end})

	local shopSkinLibCtrl = GetInst("UIManager"):GetCtrl("ShopSkinLib")
	if getglobal("ShopSkinLib"):IsShown() and shopSkinLibCtrl and shopSkinLibCtrl.view then
		shopSkinLibCtrl.view:AttachAllActor()
	end
end

function PEC_RotateView_OnMouseDown()
	--[[InitModelViewAngle =  getglobal(t_exhibition:getModelViewUiName()):getRotateAngle();
	InitMountViewAngle =  getglobal("PlayerExhibitionCenterModeViewMountsView"):getRotateAngle(1);]]
	GetInst("BestPartnerPlayerCenter"):RotateViewOnMouseDown();
end

function PEC_UnlockPhotoFrameClose_OnClick()
	getglobal("UnlockPhotoFrame"):Hide();
end

function PEC_UnlockPhotoSure_OnClick()
	PEC_UnlockPhoto();
end

--转动模型
function PEC_View_OnMouseMove()
	
		GetInst("BestPartnerPlayerCenter"):ViewOnMouseMove();
	--[[local posX = getglobal(t_exhibition:getModelViewUiName()):getActorPosX();
	local posY = getglobal(t_exhibition:getModelViewUiName()):getActorPosY();

	if arg1 > posX-120 and arg1 < posX+120 and arg2 > posY-410 and arg2 < posY+30 then	--按下的位置是角色范围内
		local angle = (arg1 - arg3)*1;

		if angle > 360 then
			angle = angle - 360;
		end
		if angle < -360 then
			angle = angle + 360;
		end

		local angle2 = InitMountViewAngle + angle;

		angle = angle + InitModelViewAngle;
		getglobal(t_exhibition:getModelViewUiName()):setRotateAngle(angle);

		getglobal("PlayerExhibitionCenterModeViewMountsView"):setRotateAngle(angle2, 1);
	end]]
end

--最佳拍档模型转动
function PEC_View1_OnMouseMove()
	GetInst("BestPartnerPlayerCenter"):BestPartnerRotateViewOnMouseMove();
	--[[local posX = getglobal(t_exhibition:getModelView1UiName()):getActorPosX();
	local posY = getglobal(t_exhibition:getModelView1UiName()):getActorPosY();

	if arg1 > posX-60 and arg1 < posX+60 and arg2 > posY-410 and arg2 < posY+30 then	--按下的位置是角色范围内
		local angle = (arg1 - arg3)*1;

		if angle > 360 then
			angle = angle - 360;
		end
		if angle < -360 then
			angle = angle + 360;
		end

		local angle2 = InitMountViewAngle + angle;

		angle = angle + InitModelViewAngle;
		getglobal(t_exhibition:getModelView1UiName()):setRotateAngle(angle);

		getglobal("PlayerExhibitionCenterModeViewMounts1View"):setRotateAngle(angle2, 1);
	end]]
end

--最佳拍档
function PEC_View1_OnMouseDown()
	GetInst("BestPartnerPlayerCenter"):BestPartnerRotateViewOnMouseDown();
	--[[InitModel1ViewAngle =  getglobal(t_exhibition:getModelView1UiName()):getRotateAngle();
	InitMount1ViewAngle =  getglobal("PlayerExhibitionCenterModeViewMounts1View"):getRotateAngle(1);]]
end


function PECTab_OnClick()
	local id = this:GetClientID();
	-- PEC_ExhibitionTab(id)
end

function PECAuthIcon_OnClick() --实名认证方法
	standReportEvent("7", "PERSONAL_INFO_HOMEPAGE", "IDCertification", "click")
	if AccountManager.idcard_info then
		local idCardInfo = AccountManager:idcard_info();
		if AccountSafetyCheck:MiniAutonymCheckState()  then
			IdentityNameAuthClass:CheckIsCanOptionType()
			local idcardtype = AccountSafetyCheck:GetIdCardType()
			if idcardtype ~= 0 and idcardtype ~= 1 and IdentityNameAuthClass:GetCanResetAuth() then
				local callback2 = function(btn2)
					if btn2 and btn2 == 'left' then 
						if AccountManager:hasBindedPhone() ~= 1 then
							ShowPhtoneBindingAwardFrame(false)
						else
							
						end
					end
				end

				local callback1 = function(btn1)
					if btn1 and btn1 == 'left' then 
						if IdentityNameAuthClass:GetShowResetTips() then
							if AccountManager:hasBindedPhone() == 1 then
								MessageBox(4, GetS(22021) .. "#r#n" .. GetS(22022) .. "#r#n" .. GetS(22023), callback2)
							else
								MessageBox(39, GetS(22021) .. "#r#n" .. GetS(22022) .. "#r#n" .. GetS(22023), callback2)
							end
						else
							MessageBox(5, GetS(22024), function(btn)
								if btn and btn == 'left' then 
									IdentityNameAuthClass:SetCanOptionType(false)
									local adsType = RealNameFunc and RealNameFunc.isShowIdentityNameAuth and RealNameFunc:isShowIdentityNameAuth(8)
									if adsType then
										ShowIdentityNameAuthFrame(true, true, false,nil,nil,adsType,true)
									else
										ShowIdentityNameAuthFrame(true, true, false)
									end
								end
								end)
						end
					end
				end

				MessageBox(38, GetS(5994), callback1)
				return
			end
		end

		if AccountManager:realname_state() ~= 1 then	--未认证
			--实名弹框埋点记录场景
			IdentityNameAuthClass:SetStatisticsPopupScene(IdentityNameAuthClass.StatisticsPopupScene.pECAuthIconClick)

			local adsType = RealNameFunc and RealNameFunc.isShowIdentityNameAuth and RealNameFunc:isShowIdentityNameAuth(8)
			if adsType then
				ShowIdentityNameAuthFrame(nil, nil, nil,nil,nil,adsType,true)
			else
				ShowIdentityNameAuthFrame()
			end
		elseif idCardInfo.age and idCardInfo.age < 18 then		--未满18
			MessageBox(4, GetS(5995));
		else
			standReportEvent("7", "ID_CERTIFICATION_POPUP", "-", "view")
			standReportEvent("7", "ID_CERTIFICATION_POPUP", "ConfirmButton", "view")
			MessageBox(4, GetS(5994),function()
				standReportEvent("7", "ID_CERTIFICATION_POPUP", "ConfirmButton", "click")
			end);
		end
	end
end

function PECRealnameInfoFrame_OnClick() --实名信息点击回调
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

	if retTab.use_channel_realname then
		--渠道实名
		MessageBox(4, GetS(1000933, retTab.channel_name or ""), function() end)
	else
		--游戏实名
		MessageBox(4, GetS(1000932), function() end)
	end
end

--点击设置头像和头像框
function PECRoleInfoHead_OnClick()
	if not t_exhibition.isHost then return end
	GetInst("PlayerCenterManager"):OpenPersonalPhotoSetting()
	standReportEvent("7", "PROFILE_EDIT", "ProfileEditButton", "click", {standby1 = 1})
end

--手机绑定按钮
function PECPhoneBindingIcon_OnClick()
	-- statisticsGameEvent(56025)
	local hasBindedPhone = AccountManager:hasBindedPhone();
	if hasBindedPhone == 1 then
		MessageBox(4, GetS(22018));
		return
	end

	ShowPhtoneBindingAwardFrame()
end

function PECCopyUin_OnClick()
	if IsLookSelf() then
		standReportEvent("7", "PERSONAL_INFO_HOMEPAGE", "UinCopy", "click")
	else
		standReportEvent("43", "PLAYER_INFO_HOMEPAGE", "UinCopy", "click")
	end
	local txt_ = "" .. getShortUin(t_exhibition.uin);

	ClientMgr:clickCopy(txt_);
	ShowGameTipsWithoutFilter( txt_ .. " " .. GetS(739), 3);
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterCopyUinBtn");
end

--信用分点击
function Creditscore_OnClick()
	
	if GetInst("CreditScoreModel"):GetCreditScoreUrl() then
		local creditScoreUrl = GetInst("CreditScoreModel"):GetCreditScoreUrl()
		local url = GetInst("CreditScoreService"):GetReqWebUrl(creditScoreUrl)
		global_jump_ui(99,url)
	else
		GetInst("CreditScoreService"):ReqPersonalCenter(function(data)
			if data then
				local creditScoreUrl = data.index
				GetInst("CreditScoreModel"):SetCreditScoreUrl(creditScoreUrl)
	
				local url = GetInst("CreditScoreService"):GetReqWebUrl(creditScoreUrl)
				global_jump_ui(99,url)
			end
		end)
	end

	standReportEvent("7", "PERSONAL_INFO_HOMEPAGE", "CreditSscore", "click")
end

local curplayer_workspaceInfo
--个人中心请求当前玩家工作室数据
function PlayerCenterQueryPlayerWorkSpaceInfo(uin)
	local ui_name = t_exhibition:getUiName();
	curplayer_workspaceInfo=nil
	local workSpaceBtn=getglobal(ui_name.."RoleInfoWorkSapce")
	local name=getglobal(ui_name.."RoleInfoWorkSapceName")
	local bg=getglobal(ui_name.."RoleInfoWorkSapceBg")
	local id=getglobal(ui_name.."RoleInfoUin")
	
	workSpaceBtn:Hide()
	if uin then
		local uins={uin}
		GetInst("WorkSpaceDataManager"):ReqWorkSpacesInfoByUins(uins,
			function(ret,data)
				if ret and ret[1] then
					curplayer_workspaceInfo=ret[1]
					workSpaceBtn:Show()
					name:SetText(string.format("%s", curplayer_workspaceInfo.workName))
					local namewidth=name:GetTextExtentWidth(string.format("%s", curplayer_workspaceInfo.workName)) or 100
					--ui调整
					bg:SetSize(namewidth+45,26)
					workSpaceBtn:SetSize(namewidth+45+15,35)
					id:SetPoint("topleft", ui_name.."RoleInfo", "topleft", 116,55)

					-- 版本首页位置调整
					PEC_RefreshNewHomePage(ui_name,needShowTitle)
				end
			end,uins)
	end
end
--个人中心打开当前玩家工作室
function PlayerCenterWorkSapceDetailOnClick()
	if curplayer_workspaceInfo and curplayer_workspaceInfo.workSpaceId then
		GetInst("WorkSpaceInterface"):ShowWorkSpace_ex(1,curplayer_workspaceInfo.workSpaceId)
	else
		ShowGameTips("获取工作室id错误")
	end
end

function PECReportBtn_OnClick()
	local playerInfo = t_exhibition.getPlayerInfo();
	-- t_exhibition.mood_text -- 个人心情
	if playerInfo then 
		local uin = t_exhibition.uin;
		local nickname = playerInfo.NickName;

		-- InformControl:AddInformInfo(102, 
		-- 	uin, 
		-- 	nickname, 
		-- 	0, 
		-- 	GetS(10517) .. "#c1ec832" .. nickname .. "(" .. uin .. ")")
		-- 	:Enqueue();
		GetInst("ReportManager"):OpenReportView({
			tid = GetInst("ReportManager"):GetTidTypeTbl().player_center,
			op_uin = uin,
			nickname = nickname,
			mood = t_exhibition.mood_text
		})
		standReportEvent("43", "PLAYER_INFO_TOP", "Report", "click", {standby1 = tostring(uin)})
		--SetReportOptionFrame("selfcenter", t_exhibition.uin, playerInfo.NickName);
	end
end

function PEC_PhotoAddBtn_OnClick()  --上传相册
	if ns_data.IsGameFunctionProhibited("u", 10579, 10580) then 
		return 
	end
	local id = this:GetParentFrame():GetClientID();

	if t_exhibition.isHost then 

		if  t_exhibition.close_upload == 1 then
			ShowGameTips( GetS(3479), 3 );  --"此功能暂未开放。", 3);
			return;
		end

		if IsProtectMode() then
			ShowGameTips(GetS(4842), 3);
			return;
		end

		t_ExhibitionCenter.selectPhotoId = id;
		PEC_BeginUploadPhoto(id);
	end

end

function PEC_PhotoPraiseBtn_OnClick()
	local id = this:GetParentFrame():GetClientID();

	if not t_exhibition.isHost then
		t_ExhibitionCenter.photoPraiseIndex = id;
		PEC_ReqAlbumPraise(t_exhibition.uin,id);
	else
		ShowGameTips(GetS(20546));
	end
end

function PEC_PhotoUnlockBtn_OnClick()
	local id = this:GetParentFrame():GetClientID();

	local frame_name = "UnlockPhotoFrame";
	getglobal( frame_name ):Show();
	getglobal( frame_name.."ContentNeedCostText" ):SetText( GetS(3475) ); --"是否解锁一个新的相册位置？" );
	getglobal( frame_name.."ContentNeedCost" ):SetText( "5" );
end

function PEC_ThumbMapBtn_OnClick() --显示缩略图点击方法
	local id = this:GetClientID();
	if id == t_ExhibitionCenter.selectMap then return end 
	t_ExhibitionCenter.selectMap = id;
	if t_exhibitionMap and #t_exhibitionMap.thumbMapList > 0 and t_ExhibitionCenter.selectMap <= #t_exhibitionMap.thumbMapList then
		local map = t_exhibitionMap.thumbMapList[id]
		if IsLookSelf() then
			standReportEvent("7", "PERSONAL_INFO_HOMEPAGE", "MyMapCard", "click",{cid=tostring(map.owid),slot=tostring(id),ctype="1"})
		else
			standReportEvent("43", "PLAYER_INFO_HOMEPAGE", "PlayerMapCard", "click",{cid=tostring(map.owid),slot=tostring(id),ctype="1"})
		end
		
	end
	PEC_SetCoverMap(t_ExhibitionCenter.selectMap);
	PEC_ShowMapComment(t_ExhibitionCenter.selectMap);
	PEC_ThumbMapState(t_ExhibitionCenter.selectMap);
end

function PEC_MapFrameCloseBtn_OnClick()
	local btn_edit = getglobal("ExhibitionMapFrameEditFrame");
	if btn_edit and btn_edit:IsShown()  then 
		btn_edit:Hide();
	end

	getglobal("ExhibitionMapFrame"):Hide();
end

function PEC_MapTopBtn_OnClick() --置顶按钮点击
	local map = t_exhibitionMap.getCurSelectMap();

	if map then 
		local standy = t_exhibitionMap.curSelectTab - 1
		if t_exhibitionMap.mapTop.owid and map.owid == t_exhibitionMap.mapTop.owid then --取消置顶
			PEC_ReqClearMapTop(map.owid);
			-- statisticsGameEvent(702, "%lld", map.owid);  --取消置顶按钮
			standReportEvent("7", "MAP_CARD_MORE_POPUP", "StickPostCancel", "click",{cid=tostring(map.owid),ctype="1",standby1=standy}) --"cid, ctype=1standby1（0=我的作品，1=我的收藏）"
		else
			PEC_ReqSetMapTop(map.owid);
			-- statisticsGameEvent(702, "%lld", map.owid);  --置顶按钮
			standReportEvent("7", "MAP_CARD_MORE_POPUP", "StickPost", "click",{cid=tostring(map.owid),ctype="1",standby1=standy})
		end
	end
	-- 隐藏页签面板
	if getglobal("ExhibitionMapFrameEditFrame"):IsShown() then 
		getglobal("ExhibitionMapFrameEditFrame"):Hide();
	end
end

function PEC_MapHideBtn_OnClick() --隐藏地图按钮点击
	local map = t_exhibitionMap.getCurSelectMap();
	local canShare = ShareArchiveInfoFrameCanShare(true)
	if canShare then
		--可以分享才能够改地图隐藏状态
		if map and map.open ~=2  then 
			PEC_ReqMapVisibility(2,map.owid);
			-- statisticsGameEvent(703, "%lld", map.owid);  --隐藏地图按钮
		elseif map then 
			PEC_ReqMapVisibility(1,map.owid);
		end
	end 
	-- 隐藏页签面板
	if getglobal("ExhibitionMapFrameEditFrame"):IsShown() then 
		getglobal("ExhibitionMapFrameEditFrame"):Hide();
	end
end

function PEC_SubmitRecommendBtn_OnClick()
	if Check_Safety_Platform_Switch("map_recommend") then
		return
	end
	
	local map = t_exhibitionMap.getCurSelectMap();
	local edit = getglobal("ExhibitionRecomendFrameTextEdit")
	local editText = edit:GetText()
	--敏感词检测
	if DefMgr:checkFilterString(editText) then
		ShowGameTipsWithoutFilter(GetS(9200100), 3)
		edit:Clear()
		return
	end

	if false == AccountSafetyCheck:FunCheck(AccountSafetyCheck.FunType.MAP_COMMENT, ArchiveGradeFrameConfirmBtn_OnClick) then
		return
	end

	if map then 
		local owid = map.owid;
		PEC_ReqSetRecommend(editText,owid);
		-- statisticsGameEvent(704, "%lld", map.owid);  --设置地图推荐语按钮
		
	end	
end

function PEC_SubmitRecommendBtn_OnFocusLost()
	
end

function PEC_SubmitRecommendBtn_OnFocusGained()
	getglobal("ExhibitionRecomendFrameEditDefaultTxt"):Hide();
end

function PEC_MapRecommendBtn_OnClick() --推荐语按钮点击
	if false == AccountSafetyCheck:FunCheck(AccountSafetyCheck.FunType.MAP_RECOMMEND, PEC_MapRecommendBtn_OnClick) then
		getglobal("ExhibitionMapFrameEditFrame"):Hide();
		return
	end

	if Check_Safety_Platform_Switch("map_recommend") then
		return
	end
	
	local t_exhibitionMap = t_exhibitionMap;
	t_exhibitionMap.curSelectTab = t_exhibitionMap.curSelectTab or 0;

	local map;
	if t_exhibitionMap.curSelectTab ~= 3 then
		map = t_exhibitionMap.getCurSelectMap();
	else
		if not (t_exhibitionMap 
		and t_exhibitionMap.tab 
		and t_exhibitionMap.tab[t_exhibitionMap.curSelectTab]
		and t_exhibitionMap.tab[t_exhibitionMap.curSelectTab].maplist) then 
			return 
		end
		map = t_exhibitionMap.tab[t_exhibitionMap.curSelectTab].maplist[this:GetParentFrame():GetClientID()];
	end

	if not map or not map.owid then 
		print("PEC_MapRecommendBtn_OnClick(): map nil")
		return 
	end
	
	local standy = t_exhibitionMap.curSelectTab - 1 --standby1（0=我的作品，1=我的收藏）"
	standReportEvent("7", "MAP_CARD_MORE_POPUP", "Recommendation", "click",{cid=tostring(map.owid),ctype="1",standby1=standy})

	local black_stat = BreakLawMapControl:VerifyMapID(map.owid);
	if black_stat == 1 or black_stat == 2 then 
		ShowGameTipsWithoutFilter(GetS(10570));
		return;
	end

	getglobal("ExhibitionRecomendFrame"):Show();
	-- 隐藏页签面板
	if getglobal("ExhibitionMapFrameEditFrame"):IsShown() then 
		getglobal("ExhibitionMapFrameEditFrame"):Hide();
	end
end

function PEC_ExhibitionRecomendFrameClose_OnClcik()
	getglobal("ExhibitionRecomendFrame"):Hide();
end

function ExhibitionRecomendFrame_OnShow()
	getglobal("ExhibitionMapFramePage1"):setDealMsg(false);
	getglobal("ExhibitionRecomendFrameTitleFrameName"):SetText(GetS(20531));
end

function ExhibitionRecomendFrame_OnHide()
	getglobal("ExhibitionMapFramePage1"):setDealMsg(true);
end

function PEC_ExhibitionMapFrame_OnShow() --地图页面显示接口
	if t_exhibitionMap.isExpert then 
		getglobal("ExhibitionMapFrameTabsTab3"):Show();
	else
		getglobal("ExhibitionMapFrameTabsTab3"):Hide();
	end 

	PEC_CreatorFrame(t_exhibitionMap.defaultSelect)
	PEC_ExhibitionMapSortTabChange(t_exhibitionMap.sortSelectTab)
	PEC_ExhibitionSortMapArchive(t_exhibitionMap.sortSelectTab)

	PEC_MapTabState(t_exhibitionMap.defaultSelect);
	PEC_ExhibitionMapArchiveSwitch(t_exhibitionMap.defaultSelect);

	PEC_DownLoadEvaluateMap(); --下载评测地图，是否需要下载，内部判断

	local mask_btn = getglobal("ExhibitionMapFrameEditFrameMask");
	local height = getglobal("ExhibitionMapFrame"): GetRealHeight();
	local width = getglobal("ExhibitionMapFrame"):GetRealWidth();
	mask_btn:SetHeight(height);
	mask_btn:SetWidth(width);
end

function PEC_ExhibitionMapFrame_OnHide()
	t_exhibitionMap.curSelectMapIndex = 1;
	t_exhibitionMap.curSelectTab = 1;
	if IsMapDetailInfoShown() and (not g_fromDetailInfoPanelHeadIcon) then
		HideMapDetailInfo();
	end
end

function PEC_ExhibitionInfoPage1_OnShow()
	
end

function PEC_ExhibitionInfoPage1_OnHide()

end

function PEC_MapTabBtn_OnClick(index)
	local id;
	if index then
		id =index;
	else
		id = this:GetClientID();
	end
	if IsLookSelf() then
		local tb = {
			"MyWorksContent",
			"MyFavoritesContent",
			"AppraisalContent",
		}
		if id >= 1 and id <= 3 then
			standReportEvent("7", "PERSONAL_INFO_MAP", tb[id], "click")
		end
	else
		local tb = {
			"PLAYER_WORKS",
			"PLAYER_FAVORITES",
			"APPRAISAL"
		}
		local clickComp = {
			"PlayerWorksContent",
			"PlayerFavoritesContent",
			"AppraisalContent"
		}
		if id >= 1 and id <= 3 then
			standReportEvent("43", "PLAYER_INFO_MAP",clickComp[id],"click")
			standReportEvent("43", tb[id],"-","view")
		end
	end
	t_exhibitionMap.curSelectTab = id;

	PEC_CreatorFrame(id)

	PEC_MapTabState(id);
	PEC_ExhibitionMapArchiveSwitch(id);
	if EnterMainMenuInfo.PlayerCenterBackInfo then
		EnterMainMenuInfo.PlayerCenterBackInfo.selectTab = t_exhibitionMap.curSelectTab
	end

	local btn_edit = getglobal("ExhibitionMapFrameEditFrame");
	if btn_edit and btn_edit:IsShown()  then 
		btn_edit:Hide();
	end
end

function PEC_ReqUserCreatorInfo()
	t_exhibition.creatorInfo = nil
	GetInst("CreationCenterHomeService"):ReqUserCreatorInfo(t_exhibition.uin, function(ret)
		t_exhibition.creatorInfo = GetInst("CreationCenterHomeService"):ConverCreatorInfo(ret)
	end)
end

function PEC_CreatorFrame(topTabIndex)
	--若没有数据不显示
	local creatorInfo = t_exhibition.creatorInfo
	if not creatorInfo then
		topTabIndex = 0
	end

	local idType = 0	--默认非发布地图者
	if creatorInfo and creatorInfo.idType then
		idType = creatorInfo.idType
	end

	local creatorFrameName = "ExhibitionMapFrameCreatorFrame"
	local listview = getglobal("ExhibitionMapFramePage1");
	local creatorFrame = getglobal(creatorFrameName);
	if topTabIndex == 1 and idType ~= 0 then	--非发布地图者也不显示
		listview:SetPoint("topleft", "ExhibitionMapFrameBodyBkg", "topleft", 10, 50)
		creatorFrame:Show();
		getglobal("ExhibitionMapFrameSortTabs"):Show()

		if t_exhibition:isLookSelf() then
			standReportEvent("7", "MY_WORKS", "CreatorStatus", "view", {standby1=idType})
		else
			standReportEvent("43", "PLAYER_WORKS", "CreatorStatus", "view", {standby1=idType})
		end
	else
		listview:SetPoint("topleft", "ExhibitionMapFrameBodyBkg", "topleft", 10, 12)
		creatorFrame:Hide();
		getglobal("ExhibitionMapFrameSortTabs"):Hide()
		--其他tab不需要设置后面的参数
		return
	end

	--数据
	local workCount = creatorInfo.worksNum
	local playCount = creatorInfo.playsNum
	local honorTxt = creatorInfo.honor
	local mileStoneCount = creatorInfo.mileStoneNum
	
	local fontSize = 18
	
	local idNameTxts = {GetS(6660472), GetS(6660475)}--{"见习创作者", "创作者"}
	local txtListTxts = {GetS(6660476),GetS(6660467),GetS(6660478),GetS(6660479),GetS(6660480)}--{"里程碑", "作品", "累计游玩次数", "我要转正", "查看里程碑"}
	local idName = getglobal(creatorFrameName.."IDName");
	local txt = idNameTxts[idType]
	local scy = fontSize/idName:GetTextExtentHeight(txt)
	idName:SetSize(idName:GetTextExtentWidth(txt)*scy, 22)
	idName:SetText(txt)

	local honorBg = getglobal(creatorFrameName.."HonorBg");
	local honor = getglobal(creatorFrameName.."Honor");
	if honorTxt=="" then
		honorBg:SetSize(2, 22)
		honorBg:Hide()
	else
		honorBg:Show()
		scy = fontSize/honor:GetTextExtentHeight(honorTxt)
		honorBg:SetSize(honor:GetTextExtentWidth(honorTxt)*scy + 6, 22)
		honor:SetSize(honor:GetTextExtentWidth(honorTxt)*scy, 22)
	end
	honor:SetText(honorTxt)

	local mileStoneSign = getglobal(creatorFrameName.."MileStoneSign");
	local mileStoneComp = getglobal(creatorFrameName.."MileStone");
	txt = txtListTxts[1]..":"..mileStoneCount
	scy = fontSize/mileStoneComp:GetTextExtentHeight(txt)
	mileStoneComp:SetSize(mileStoneComp:GetTextExtentWidth(txt)*scy, 22)
	mileStoneComp:SetText(txt)

	local workCountComp = getglobal(creatorFrameName.."Works");
	txt = txtListTxts[2]..":"..workCount
	scy = fontSize/workCountComp:GetTextExtentHeight(txt)
	workCountComp:SetSize(workCountComp:GetTextExtentWidth(txt)*scy, 22)
	workCountComp:SetText(txt)

	local playCountComp = getglobal(creatorFrameName.."Plays");
	txt = txtListTxts[3]..":"..playCount
	scy = fontSize/playCountComp:GetTextExtentHeight(txt)
	playCountComp:SetSize(playCountComp:GetTextExtentWidth(txt)*scy, 22)
	playCountComp:SetText(txt)

	--见习创作者不显示头衔，里程碑数据
	if idType==1 then
		honorBg:Hide()
		honor:Hide()
		mileStoneSign:Hide()
		mileStoneComp:Hide()
		workCountComp:SetPoint("left", creatorFrameName.."IDName", "right", 45, 0)
	else
		if honorTxt~="" then
			honorBg:Show()
		end
		honor:Show()
		mileStoneSign:Show()
		mileStoneComp:Show()
		workCountComp:SetPoint("left", creatorFrameName.."MileStone", "right", 45, 0)
	end

	--成为创作者/查看里程碑
	local beFullCreator = getglobal(creatorFrameName.."BeFullCreator");
	local lookMileStone = getglobal(creatorFrameName.."LookMileStone");
	beFullCreator:Hide()
	lookMileStone:Hide()
	if t_exhibition:isLookSelf() then
		if idType==1 then
			beFullCreator:Show()
		else
			lookMileStone:Show()
		end
	end
	local beFullCreatorName = getglobal(creatorFrameName.."BeFullCreatorName");
	beFullCreatorName:SetText(txtListTxts[4])
	local lookMileStoneName = getglobal(creatorFrameName.."LookMileStoneName");
	lookMileStoneName:SetText(txtListTxts[5]..">")
end

function ExhibitionInfoPage1_BeFullCreatorBtn_OnClick()
	--跳转创作中心--有可能创作中心没打开过，故走一下获取配置
	GetInst("CreationCenterDataMgr"):ReqCreatorCenterCfg(
		function (isOpenNewCC)
			if isOpenNewCC then
				PlayerExhibitionCenterClose_OnClick()
				GetInst("CreationCenterInterface"):OpenUI()

				standReportEvent("7", "MY_WORKS", "Upgrade", "click")
			end 
		end
	)
end

function ExhibitionInfoPage1_LookMileStoneBtn_OnClick()
	--跳转里程碑网页
	local jumpUrls = GetInst("CreationCenterDataMgr"):GetInformationList("createcenterH5JumpUrl")
	if jumpUrls and jumpUrls.devMileStoneJumpUrl then
		open_http_link(jumpUrls.devMileStoneJumpUrl)

		standReportEvent("7", "MY_WORKS", "Milestone", "click")
	end
end

function PEC_SortTabBtn_OnClick(index)
	local id = index or this:GetClientID();
	
	if t_exhibitionMap.sortSelectTab == id then
		return
	end
	
	PEC_ExhibitionMapSortTabChange(id);
	if not PEC_SetBlackShow(t_exhibition.black) then
		PEC_GetPlayerMapByUin(t_exhibition.uin,1,1,{sortId=id});  --获取地图接口调用
	end
end

function PEC_ExhibitionMapSortTabChange(sortId)
	local tabName = "ExhibitionMapFrameSortTabsTab";
	--分类按钮2个
	for i=1,2 do 
		local ui_text = getglobal(tabName..i.."Name");
		if ui_text then
			if sortId == i then 
				--ui_text:SetFontSize(24)
				ui_text:SetTextColor(61,61,61);
				ui_text:SetScale(1.2)
			else 
				--ui_text:SetFontSize(20)
				ui_text:SetTextColor(143,143,143);
				ui_text:SetScale(1.0)
			end
		end
	end
end

--排序只针对我的/他的作品
function PEC_ExhibitionSortMapArchive(sortId)
	--主动点击，被动不管
	if t_exhibitionMap.sortSelectTab ~= sortId then
		local creatorinfo = t_exhibition.creatorInfo
		local idType = creatorinfo and creatorinfo.idType or 0
		local compId = sortId==1 and "Default" or "MostPlay"
		if t_exhibition:isLookSelf() then
			standReportEvent("7", "MY_WORKS", compId, "click", {standby1=idType})
		else
			standReportEvent("43", "PLAYER_WORKS", compId, "click", {standby1=idType})
		end
	end
	t_exhibitionMap.sortSelectTab = sortId
	local maplist = t_exhibitionMap.tab[1].maplist;
	--1：按照时间倒序（默认） 2：按游戏次数倒序  --置顶地图不排
	local topOwid = t_exhibitionMap.mapTop.owid
	table.sort(maplist, function(a, b)
		if (not topOwid) or (topOwid and a.owid ~= topOwid and b.owid ~= topOwid) then
			if sortId==1 then
				return a.last_upload_time > b.last_upload_time
			else
				return a.play_count > b.play_count
			end
		end
	end)
end

function PEC_MapEditFrameMask_OnClick()
	if getglobal("ExhibitionMapFrameEditFrame"):IsShown() then 
		 getglobal("ExhibitionMapFrameEditFrame"):Hide();
	end
end

function PEC_MapArchiveEditBtn_OnClick()
	local btn_edit = getglobal("ExhibitionMapFrameEditFrame");

	local id = this:GetParentFrame():GetClientID() + 1
	
	local standy = t_exhibitionMap.curSelectTab - 1 --standby1（0=我的作品，1=我的收藏）"
	
	if btn_edit then 
		if btn_edit:IsShown() and t_exhibitionMap.curSelectMapIndex == id then 
			btn_edit:Hide();
		else
			local frame_name = "ExhibitionMapFrameEditFrame";
			local ui_hideBtn = getglobal(frame_name.."HideBtn");
			local ui_recommendBtn = getglobal(frame_name.."RecommendBtn");
			local ui_frame = getglobal(frame_name);
			local ui_bkg = getglobal(frame_name.."Bkg");

			if t_exhibitionMap.curSelectTab ==1 then 
				ui_hideBtn:Hide(); --看代码后面已经隐藏了 修改框的大小
				ui_recommendBtn:SetPoint("top", frame_name, "top", 0, 72);
				ui_frame:SetHeight(140);
				ui_bkg:SetHeight(140);
			elseif t_exhibitionMap.curSelectTab ==2 then 
				ui_hideBtn:Hide();
				ui_recommendBtn:SetPoint("top", frame_name, "top", 0, 72);
				ui_frame:SetHeight(140);
				ui_bkg:SetHeight(140);
			end

			t_exhibitionMap.curSelectMapIndex = id;

			local hideBtn = getglobal("ExhibitionMapFrameEditFrameHideBtn");
			local map = t_exhibitionMap.getCurSelectMap();
			if map then 
				if t_exhibitionMap.curSelectTab == 1 then
					standReportEvent("7", "MY_WORKS", "MapCardMore", "click", {slot=tostring(id),ctype="1",cid=tostring(map.owid)})
				elseif t_exhibitionMap.curSelectTab == 2 then
					standReportEvent("7", "MY_FAVORITES", "MapCardMore", "click", {slot=tostring(id),ctype="1",cid=tostring(map.owid)})
				elseif t_exhibitionMap.curSelectTab == 3 then
					standReportEvent("7", "APPRAISAL", "MapCardMore", "click", {slot=tostring(id),ctype="1",cid=tostring(map.owid)})
				end

				UpdateSingleArchiveDownloadState(btn_edit, map);

				--隐藏按钮
				
				local hideBtnNormal = getglobal("ExhibitionMapFrameEditFrameHideBtnNormal");
				local hideBtnPushed = getglobal("ExhibitionMapFrameEditFrameHideBtnPushedBG");

				--置顶按钮
				local topBtn = getglobal("ExhibitionMapFrameEditFrameTopBtn");
				local topBtnNormal = getglobal("ExhibitionMapFrameEditFrameTopBtnNormal");
				local topBtnPushed = getglobal("ExhibitionMapFrameEditFrameTopBtnPushedBG");

				if map.open == 2 then 
					getglobal("ExhibitionMapFrameEditFrameHideBtnText"):SetText(GetS(20529));

					--已经隐藏, 则不让置顶
					topBtn:Disable();
					topBtnNormal:SetGray(true);
					topBtnPushed:SetGray(true);
				else 
					getglobal("ExhibitionMapFrameEditFrameHideBtnText"):SetText(GetS(20528));

					topBtn:Enable();
					topBtnNormal:SetGray(false);
					topBtnPushed:SetGray(false);
					
				end

				if t_exhibitionMap.mapTop.owid and map.owid == t_exhibitionMap.mapTop.owid then
					getglobal("ExhibitionMapFrameEditFrameTopBtnText"):SetText(GetS(20567)); --20567 取消置顶 20530 已置顶

					--已经置顶了, 则不让隐藏
					hideBtn:Disable();
					hideBtnNormal:SetGray(true);
					hideBtnPushed:SetGray(true);
					standReportEvent("7", "MAP_CARD_MORE_POPUP", "StickPostCancel", "view",{cid=tostring(map.owid),ctype="1",standby1=standy})
				else 
					getglobal("ExhibitionMapFrameEditFrameTopBtnText"):SetText(GetS(1054));

					hideBtn:Enable();
					hideBtnNormal:SetGray(false);
					hideBtnPushed:SetGray(false);

					standReportEvent("7", "MAP_CARD_MORE_POPUP", "StickPost", "view",{cid=tostring(map.owid),ctype="1",standby1=standy})
				end
				standReportEvent("7", "MAP_CARD_MORE_POPUP", "-", "view")
				
				standReportEvent("7", "MAP_CARD_MORE_POPUP", "Recommendation", "view",{cid=tostring(map.owid),ctype="1",standby1=standy})
			end

			local btnName = this:GetParentFrame():GetName()

			btn_edit:SetPoint("topright", btnName, "topright", 0, 43);
			btn_edit:Show();
			hideBtn:Hide();
		end
	end
end

function PEC_MapArchiveFuncBtn_OnClick()
	local id = this:GetParentFrame():GetClientID();
	local map = {};
	local funcBtnUi;

	if t_exhibition.isHost and  t_exhibitionMap.curSelectTab ~= 3 then 
		map = t_exhibitionMap.getCurSelectMap();
		funcBtnUi = getglobal("ExhibitionMapFrameEditFrameFuncBtn");
	else 
		map = t_exhibitionMap.tab[t_exhibitionMap.curSelectTab].maplist[id];
		funcBtnUi = getglobal(this:GetParentFrame():GetName().."FuncBtn");
	end 

	if map then
		if HandleGmMapCommands(map) then  --处理gm命令
			return;
		end
		PEC_MapFuncBtn(funcBtnUi, map, {fromUiLabel=CurLabel, fromUiPart=nil});
	end

end

--跳转到地图详情
function jumpMapDetails_OnClick()
	local  selectMap = t_exhibitionMap.thumbMapList[t_ExhibitionCenter.selectMap];
	if selectMap then
		ShowMiniWorksMapDetailByMapID(selectMap.owid);

		-- if getglobal("MiniWorksFrameSearch1"):IsShown() then
		-- 	statisticsGameEventNew(41111, "more",AccountManager:getUin(), selectMap.owid)
		-- end
	end
end

--更多按钮点击
function ExhibitionInfoMore_OnClick()
	if t_ExhibitionCenter.curSelectTabID == t_ExhibitionCenter.define.tabMap and ns_data.IsGameFunctionProhibited("p", 10585, 10586) then 
		return; 
	end
	
	if t_exhibition:CheckOtherProfileBlackStat() then 
		ShowGameTips(string.format(GetS(10593), GetS(3034)));
		return;
	end

	for i = 1, #(t_ExhibitionCenter.tab) do
		if t_ExhibitionCenter.curSelectTabID == i then
			if t_ExhibitionCenter.tab[i].moreBtn_OnClick then
				t_ExhibitionCenter.tab[i].moreBtn_OnClick();
			end
		end
	end

	if t_ExhibitionCenter.curSelectTabID == t_ExhibitionCenter.define.tabHome then 
		getglobal("ExhibitionMapFrame"):Show();
		-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterMapBtn");
	end
end

function ExhibitionInfoPage1MoreBtn_OnClick() --地图页面更多按钮触发的方法
	getglobal("ExhibitionMapFrame"):Show();
end

function ExhibitionAchieveSuccessFrameCloseBtn_OnClick()
	standReportEvent("7", "MEDAL_REWARD_POPUP", "Close", "click")
	getglobal("ExhibitionAchieveSuccessFrame"):Hide();
	getglobal("ExhibitionInfoPage4AchievementSlider"):setDealMsg(true);
end

function ExhibitionRewardFrame_OnShow()
	print("ExhibitionRewardFrame_OnShow:");
	getglobal("ExhibitionInfoPage4AchievementSlider"):setDealMsg(false);
	getglobal("ExhibitionRewardFrameTitleFrameName"):SetText(GetS(20604));
end

function ExhibitionRewardFrame_Hide()
	getglobal("ExhibitionInfoPage4AchievementSlider"):setDealMsg(true);
end

--------------------------------界面相关的逻辑方法----------------------------------------------------
--数量进位：当粉丝和人气值上万后，用万作为单位，四舍五入。即：原本是1499566粉丝，显示149.96万。最大可显示的数字为6个，数字居中对齐。如果已经超出10000万，就显示亿
function PEC_ConvertNumber(value) --9000011 3841
	
	local num = tonumber(value)
	local str = num
	if num > 10000 and num < 100000000 then --万
		str = string.format("%0.2f"..GetS(3841), (num)/10000)
	elseif  num > 100000000 then --亿
		str = string.format("%0.2f"..GetS(9000011), (num)/100000000)
	end
	return str
end

--显示个人信息中心头顶的信息
function PEC_ShowPlayerInfo()
	local playerInfo = t_exhibition.getPlayerInfo();
	if playerInfo==nil then 
		Log("get playerinfo is fail :PEC_ShowPlayerInfo()") 
		return 
	end

	local frame_name = t_exhibition:getUiName();

	local isSelf 			= t_exhibition.isHost;
	--local ui_name 			= getglobal(frame_name.."RoleInfoName");
	local ui_uin			= getglobal(frame_name.."RoleInfoUin");
	local ui_CreditScore			= getglobal(frame_name.."RoleInfoCreditScore");
	local ui_friendNum 		= getglobal(frame_name.."FriendNumFont");
	local ui_friendNum2 	= getglobal(frame_name.."FriendNumFont2");
	local ui_rewardNum 		= getglobal(frame_name.."RewardNumFont");
	local ui_rewardNum2 	= getglobal(frame_name.."RewardNumFont2");
	local ui_focusNum 		= getglobal(frame_name.."FocusNumFont");
	local ui_focusNum2 		= getglobal(frame_name.."FocusNumFont2");
	local ui_hotNum 		= getglobal(frame_name.."HotNumFont");
	local ui_hotNum2 		= getglobal(frame_name.."HotNumFont2");
	local ui_gender			= getglobal(frame_name.."RoleInfoGender");
	local ui_title 			= getglobal("ExhibitionInfoTitle");
	local ui_commentName 	= getglobal("ExhibitionInfoPage1AhutorCommentName");
	local ui_homeland		= getglobal(frame_name.."HomeLandBtn") --家园按钮

	local SlidingFrameName 				= getglobal(frame_name.."RoleInfoSlidingFrameName")
	local Name2 				= getglobal(frame_name.."RoleInfoSlidingFrameNameName2")
	local realName          =  getglobal(frame_name.."RoleInfoRealName")
	if ui_homeland then
		if IsEnableHomeLand and IsEnableHomeLand() then
			standReportEvent("7", "PERSONAL_INFO_HOMEPAGE", "HomelandButton", "view")
			standReportEvent("43", "PLAYER_INFO_HOMEPAGE", "HomelandButton", "view", {
				standby1 = (UinGetMyFriendsBrief(t_exhibition.uin or 0) and {"1"} or {"0"})[1],
			})
			ui_homeland:Show()
		else
			ui_homeland:Hide()
		end
		--[[
			Author: wangyang
			EditTime: 2022-12-12
			Description: [最佳拍档]功能中去掉此入口,去掉自己的入口
		--]]
		if tonumber(getShortUin(t_exhibition.uin)) == tonumber(AccountManager:getUin())then
			ui_homeland:Hide()
		end
	end

	PEC_Tools.SetUiTextSelfAdaptionScale(ui_title,GetS(20536));

	if AccountManager.data_update and (t_exhibition.uin == AccountManager:getUin()) then -- 自己的时候才更新数据
		AccountManager:data_update()
	end

	local nickName = PEC_GetShowPlayerNickName(isSelf)
	--好友备注
	if not isSelf and HasFriendNote(t_exhibition.uin) then
		nickName = GetFriendNote(t_exhibition.uin)
		realName:SetText("（"..PEC_GetShowPlayerNickName(isSelf).."）",61,69,70)
		realName:Show()
	else
		realName:Hide()
	end

	local _, bVip = G_VipNamePreFixEntrency(Name2, t_exhibition.uin, nickName, {r = 61, g = 69, b = 70})
	-- if isSelf then 
	-- 	ui_name:SetText(nickName, 61, 69, 70);
	-- 	ui_commentName:SetText(nickName);
	-- else
	-- 	ui_name:SetText(nickName, 61, 69, 70);
	-- 	ui_commentName:SetText(nickName);
	-- end
	local vipIconWidth = bVip and VIP_ICON_WIDTH or 0;
	ui_gender:SetPoint("left", SlidingFrameName:GetName(), "left", 10 + Name2:GetTextExtentWidth(nickName) + vipIconWidth, -5)
	
	-- 昵称审核状态
	if isAbroadEvn() == false and IsOverseasVer() == false then
		local renameState = AccountManager.get_rename_review and AccountManager.get_rename_review() or 0
		local isReview = tonumber(renameState) == 3
		PEC_ShowRenameReviewUI(isReview)
	end

	ui_uin:SetText(GetS(3070)..":"..tostring(getShortUin(t_exhibition.uin)));
	-- ui_CreditScore:SetText("")
	ui_friendNum:SetText(playerInfo.friend_count);
	ui_friendNum2:SetText(playerInfo.friend_count);
	local str = PEC_ConvertNumber(playerInfo.attention_count)
	ui_focusNum:SetText(playerInfo.attention_count);
	ui_focusNum2:SetText(str);
	local str = PEC_ConvertNumber(playerInfo.popularity_count)
	ui_hotNum:SetText(playerInfo.popularity_count);
	ui_hotNum2:SetText(str);
	
	if playerInfo.tips and playerInfo.tips.total then
		ui_rewardNum:SetText(playerInfo.tips.total);
		ui_rewardNum2:SetText(playerInfo.tips.total);
	else
		ui_rewardNum:SetText(0);
		ui_rewardNum2:SetText(0);
	end

	PEC_ShowConnoisseur(playerInfo.expert, getShortUin(t_exhibition.uin))
	PEC_SetGenderPic(ui_gender,playerInfo.gender);
	PEC_ShowQQVIPIcon(t_exhibition.uin);

	--设置头像
	PEC_SetPlayerHead( playerInfo.headIndexFile,playerInfo.head_frame_id)

	--设置模型显示
	-- if not t_ExhibitionModelView:GetOpenStatus() then
		PEC_ShowSkinModel();
		IsFirstShowSkinModel = true
	-- end

	-- 数据返回后设置版本隐藏
	t_exhibition:ShowHideVersionUIEnd(t_exhibition.isHost)

	-- 设置返回数据后的显示
	PEC_PlayerCenterStateShow(t_exhibition.isHost);

	--设置这个玩家的工作室状态
	PlayerCenterQueryPlayerWorkSpaceInfo(getShortUin(t_exhibition.uin))

	-- 版本首页位置调整
	PEC_RefreshNewHomePage(frame_name,needShowTitle)

	PEC_RefreshCharmNum()
end

--刷新特长UI
function PEC_RefreshGeniusShow(isSelf, doReport)
	--不开放特长系统
	local geniusBtn = getglobal("PlayerExhibitionCenterGeniusBtn")
	if not GetInst("GeniusMgr"):IsOpenGeniusSys() then
		geniusBtn:Hide()
		return
	end
	
	if isSelf then
		--修改地图里面的推荐语会触发PlayerExhibitionCenter_OnShow调用此处显示特长按钮，此处做一次首页判断
		if curClickID and curClickID==t_ExhibitionCenter.define.tabHome then
			geniusBtn:Show()
		end
	else
		geniusBtn:Hide()
		return
	end

	PEC_ReportGeniusRef(doReport)

	local geniusNormalBkg= getglobal("PlayerExhibitionCenterGeniusBtnNormalBkg")
	local geniusPushedBkg= getglobal("PlayerExhibitionCenterGeniusBtnPushedBkg")
	local iconPath = GetInst("GeniusMgr"):GetCurEquipGeniusIcon()
	geniusNormalBkg:SetTexture(iconPath)
	geniusPushedBkg:SetTexture(iconPath)
end

function PEC_GetShowPlayerNickName(isSelf)
	local nickName = ""
	if isSelf then 
		nickName = AccountManager:getBlueVipIconStr(AccountManager:getUin()).. DefMgr:filterString(AccountManager:getNickName(), false)
	else
		local playerInfo = t_exhibition.getPlayerInfo()
		nickName = playerInfo.NickName and DefMgr:filterString(playerInfo.NickName, false) or ""
	end

	return nickName
end

--显示审核改名UI
function PEC_ShowRenameReviewUI(isReview)
	local uiName = t_exhibition:getUiName();
	local roleInfoName = uiName.."RoleInfo"

	local SlidingFrameName 				= getglobal(roleInfoName.."SlidingFrameName")
	local Name2 				= getglobal(roleInfoName.."SlidingFrameNameName2")

	if isReview and t_exhibition.isHost then
		--审核中	
		getglobal(roleInfoName.."NameCheck"):Show()	
		getglobal(roleInfoName.."NameCheck"):SetText(GetS(20669),1,170,16)
		if t_exhibition:isThreeVerOpen() then
			SlidingFrameName:SetPoint("topleft", roleInfoName, "topleft", 116, 7)
		else
			SlidingFrameName:SetPoint("topleft", roleInfoName, "topleft", 116, 29)
		end
	else 
		getglobal(roleInfoName.."NameCheck"):Hide()
		SlidingFrameName:SetPoint("topleft", roleInfoName, "topleft", 110, 7)
	end

	-- getglobal(roleInfoName.."AuthIcon"):SetPoint("left",roleInfoName.."Gender","right",10,0)
	-- getglobal(roleInfoName.."PhoneBindingIcon"):SetPoint("left",roleInfoName.."AuthIcon","right",10,-2)
	getglobal(roleInfoName.."RealnameInfoFrame"):SetPoint("left",roleInfoName.."Gender","right",10,0)
	getglobal(roleInfoName.."PhoneBindingIcon"):SetPoint("left",roleInfoName.."RealnameInfoFrame","right",10,-2)
	getglobal(roleInfoName.."QQVipIcon"):SetPoint("left",roleInfoName.."PhoneBindingIcon","right",12,-2)
end

--刷新昵称
function PEC_RefleshNick(data)
	if data and data.result then
		if tonumber(data.result) == 1 then --审核成功
			if data.new_name then --刷新昵称数据
				local nickName = DefMgr:filterString(data.new_name, false)
				getglobal("LobbyFrameHeadInfoRoleName"):SetText(nickName)
				-- getglobal("MiniLobbyFrameTopRoleInfoName"):SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin())..nickName, 53, 84, 84)
				local nameFrame = GetMiniLobbyRoleInfoNameRichTextFrame()
				if nameFrame then
					nameFrame:SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin())..nickName, 53, 84, 84)
				end --mark by hfb for new minilobby

				local SlidingFrameName 				= getglobal("PlayerExhibitionCenterRoleInfoSlidingFrameName")
				local Name2 				= getglobal("PlayerExhibitionCenterRoleInfoSlidingFrameNameName2")

				--local uiName = getglobal("PlayerExhibitionCenterRoleInfoName")
				local namStr, bVip = G_VipNamePreFixEntrency(Name2, AccountManager:getUin(), AccountManager:getBlueVipIconStr(AccountManager:getUin())..nickName, {r = 61, g = 69, b = 70})
				local vipIconWidth = bVip and 22 or 0
				local width = Name2:GetTextExtentWidth(namStr) + vipIconWidth
				-- uiName:SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin())..nickName, 61, 69, 70)
				getglobal("PlayerExhibitionCenterRoleInfoGender"):SetPoint("left", Name2:GetName(), "left", width + 10, -5)
				getglobal("GameSetFrameBaseLayersScrollName"):SetText(nickName)
				getglobal("PlayerCenterDataEditPage1NickNameName"):SetText(nickName)	
			end
		end
	end
end

function PEC_GetMapRospond() --获取地图之后显示主页缩略地图的回调
	print("PEC_GetMapRospond:");
	local mapNum = #(t_exhibitionMap.thumbMapList);
	if mapNum and mapNum <0 then 
		Log("map num is error : PEC_GetMapRospond()")
		mapNum = 0;
	end

	if mapNum <= 0 then --没有地图
		PEC_NoneMapShowExhibition()
	else 
		PEC_SetCoverMap(t_ExhibitionCenter.selectMap);
		PEC_ShowMapComment(t_ExhibitionCenter.selectMap);
		PEC_MapThumbSliderLayout(mapNum);

		--成就上报:自己精选地图数量
		--t_exhibitionMap.tab[1].maplist
		if t_exhibition:isLookSelf() then
			if t_exhibitionMap.tab[1] and t_exhibitionMap.tab[1].maplist and #(t_exhibitionMap.tab[1].maplist) > 0 then
				local maplist = t_exhibitionMap.tab[1].maplist;
				local chosenMapCount = 0;

				print("checkChosenMap111:");
				local myUin = AccountManager:getUin();
				for i = 1, #maplist do
					if maplist[i] and maplist[i].author_uin and maplist[i].author_uin == myUin then
						print("i = ", i);
						print("mapname = ", maplist[i].name);
						print("author_uin = ", maplist[i].author_uin);
						if maplist[i].display_rank and (maplist[i].display_rank == 2 or maplist[i].display_rank == 1) then
							print("is chosenmap:");
							chosenMapCount = chosenMapCount + 1;
						end
					end
				end

				--上报精选地图数量
				ArchievementGetInstance().func:checkChosenMapCount(chosenMapCount);
			end
		end
		
	end
	
end

function PEC_NoneMapShowExhibition()
	local frameName = "ExhibitionInfoPage1";
	local ui_pic = getglobal(frameName.."CoverPic");
	local ui_tagBkg = getglobal(frameName.."CoverTagBkg");
	local ui_tagName = getglobal(frameName.."CoverTagName");
	local ui_labelBkg = getglobal(frameName.."CoverLabelBkg");
	local ui_labelName = getglobal(frameName.."CoverLabelName");
	local ui_name = getglobal(frameName.."CoverName");
	local ui_down =	getglobal(frameName.."CoverDown");
	local ui_downIcon =	getglobal(frameName.."CoverDownIcon");
	local ui_comment = getglobal(frameName.."CoverComment");
	local ui_commentIcon = getglobal(frameName.."CoverCommentIcon");
	local ui_mapType = getglobal(frameName.."CoverTypeName");
	local ui_mapPic = getglobal(frameName.."CoverTypePic");

	ui_tagName:Hide();
	ui_tagBkg:Hide();
	ui_labelBkg:Hide();
	ui_labelName:Hide();
	ui_tagName:Hide();
	ui_down:Hide();
	ui_downIcon:Hide();
	ui_commentIcon:Hide();
	ui_comment:Hide();
	ui_mapPic:Hide();
	ui_mapType:Hide();
	ui_pic:SetTexture(mapservice.thumbnailDefaultTexture);
	
	if t_exhibition.isHost  then 
		ui_name:SetText(GetS(20540));
	else
		ui_name:SetText(GetS(20540));
	end

	for i =2 ,PEC_MaxMaps do
		local cell =getglobal(frameName.."ThumbSliderCell"..i);
		cell:Hide();
	end

	local ui_cellCheck = getglobal(frameName.."ThumbSliderCell1Checked");
	local ui_cellNormal = getglobal(frameName.."ThumbSliderCell1Normal");
	ui_cellCheck:Show();
	ui_cellNormal:SetTexture(mapservice.thumbnailDefaultTexture);

	getglobal(frameName.."AhutorCommentContent"):SetText(GetS(20533));

end

function PEC_ShowMapComment(index) --显示地图评论
	local map= t_exhibitionMap.thumbMapList[index];
	if map == nil then return end

	local ui_comment = getglobal("ExhibitionInfoPage1AhutorCommentContent");

	local mapComment;

	if t_exhibitionMap.recommendList and t_exhibitionMap.recommendList[map.owid] then 
		mapComment = t_exhibitionMap.recommendList[map.owid].txt;
	else
		mapComment =  GetS(178);
	end

	if string.len(mapComment)>150 then 
		mapComment = string.sub(mapComment,1,150);
	end

	mapComment = DefMgr:filterString(mapComment);
	ui_comment:SetText(mapComment);


end

function PEC_MapThumbSliderLayout(num)
	if type(num) ~= 'number' or num<0 then
		Log("num is error :PEC_MapThumbSliderLayout(num)") 
		return 
	end

	---TODO 处理地图为空的显示
	local maplist = t_exhibitionMap.thumbMapList;

	local sliderName	= "ExhibitionInfoPage1ThumbSlider";
	local ui_plane 		= getglobal(sliderName.."Plane");
	local hight = 0;

	for i=1, PEC_MaxMaps do 
		local ui_cell = getglobal(sliderName.."Cell"..i);

		if i<= num then
			if i ==t_ExhibitionCenter.selectMap then 
				getglobal(sliderName.."Cell"..t_ExhibitionCenter.selectMap.."Checked"):Show();
			else 
				getglobal(sliderName.."Cell"..i.."Checked"):Hide();
			end

			ui_cell:Show();
			GetMapThumbnail(maplist[i], sliderName.."Cell"..i.."Normal");
			ui_cell:SetClientID(i);

			ui_cell:SetPoint("top", sliderName.."Plane", "top", 0, hight);
			hight = hight + 77;
		else 
			ui_cell:Hide();
		end
	end

	ui_plane:SetHeight(math.max(470, hight));

end

function PEC_ThumbMapState(index)  --设置选中的缩略图地图
	if index<=0 or index>PEC_MaxMaps then return end
	local sliderName	= "ExhibitionInfoPage1ThumbSlider";

	--TODO 处理为空时候的显示

	for i =1 ,PEC_MaxMaps do 
		if i<= #(t_exhibitionMap.thumbMapList) then 
			if i ==t_ExhibitionCenter.selectMap then 
				getglobal(sliderName.."Cell"..t_ExhibitionCenter.selectMap.."Checked"):Show();
			else 
				getglobal(sliderName.."Cell"..i.."Checked"):Hide();
			end
		end
	end
end

function PEC_SetCoverMap(index) --设置地图的封面
	local map= t_exhibitionMap.thumbMapList[index];
	if map == nil then return end

	local plane_name = "ExhibitionInfoPage1Cover";

	GetMapThumbnail(map, plane_name.."Pic");
	local ui_typeName = getglobal(plane_name.."LabelName");
	local ui_mapName = getglobal(plane_name.."Name");
	local ui_tagBkg = getglobal(plane_name.."TagBkg");
	local ui_tagName = getglobal(plane_name.."TagName");
	local ui_cover = getglobal(plane_name);
	local ui_mapType = getglobal(plane_name.."TypeName");
	local ui_mapPic = getglobal(plane_name.."TypePic");


	if map.author_uin == t_exhibition.uin then
		ui_mapType:Hide();
		ui_mapPic:Hide();
		ui_mapType:SetText(GetS(20548))
	else
		ui_mapType:Show();
		ui_mapPic:Show();
		ui_mapType:SetText(GetS(897))
	end

	--地图类型
	local gameLabel = tonumber(map.label) or 0;
	if gameLabel == 0 then
		gameLabel = GetLabel2Owtype(map.worldtype or 0);
	end
	SetRoomTag(nil, ui_typeName, gameLabel);

	--更新下载按钮状态：去掉下载按钮
	--UpdateSingleArchiveDownloadState(ui_cover, map)

	--设置地图名字
	local mapname = map.name or "";
	if string.len(mapname) >30 then 
		mapname = string.sub(mapname,1,30).."...";
	end
	
	ui_mapName:SetText(mapname);

	--角标
	local display_rank = map.display_rank or 0;
	if display_rank == 0  then  --0=已上传
		ui_tagBkg:Hide();
		ui_tagName:Hide();
	elseif display_rank == 1 then  --1=已投稿
		ui_tagBkg:Show();
		ui_tagBkg:SetTexUV("label_map_hot");
		ui_tagName:Show();
		ui_tagName:SetText(GetS(3842));  --待审
		ui_tagName:SetTextColor(55, 54, 49);	 --设置颜色
	elseif display_rank == 2 then  --2=已精选
		ui_tagBkg:Show();
		ui_tagBkg:SetTexUV("label_map_selection");
		ui_tagName:Show();
		ui_tagName:SetText(GetS(3843));  --精选
		ui_tagName:SetTextColor(55, 54, 49);	 --设置颜色
	elseif display_rank == 3 then  --3=已推荐
		ui_tagBkg:Hide();
		ui_tagName:Hide();
	end

	--设置下载量和评论数
	local download_num = map.download_count or 0;
	-- getglobal(plane_name.."Down"):Show();
	-- getglobal(plane_name.."DownIcon"):Show();
	if  lang_show_as_K() and download_num > 1000 then
		getglobal(plane_name.."Down"):SetText(string.format("%0.1f", download_num/1000).. 'K');
	elseif download_num > 10000 then
		getglobal(plane_name.."Down"):SetText(string.format("%0.1f", download_num/10000)..GetS(3841)); --X.X万
	else
		getglobal(plane_name.."Down"):SetText(tostring(download_num));
	end

	local comment_num = map.comment_num or 0;
	-- getglobal(plane_name.."Comment"):Show();
	-- getglobal(plane_name.."CommentIcon"):Show();
	getglobal(plane_name.."Comment"):SetText(tostring(comment_num)..GetS(6027));

end

--设置性别显示ui
function PEC_SetGenderPic(ui_pic,gender)
	-- 1=男 2=女 0=保密
	if ui_pic then 
		if gender == 1 then
			ui_pic:SetTexUV( "icon_male.png"  );
			ui_pic:SetWidth(25);
			ui_pic:SetHeight(25);
		elseif gender == 2 then
			ui_pic:SetTexUV( "icon_female.png"  );
			ui_pic:SetWidth(25);
			ui_pic:SetHeight(25);
		else
			ui_pic:SetTexUV( "icon_sex.png"  );
			ui_pic:SetWidth(28);
			ui_pic:SetHeight(10);
		end
		--增加性别开关
		if not if_show_gender() then
			ui_pic:Hide()
		end
	end
end

function  PEC_SetPlayerHeadFile(playerInfo)
	print("PEC_SetPlayerHeadFile:");
	local url_ = playerInfo.head_url;
	local checked_=playerInfo.head_checked;

	if  url_ and #url_ > 3 then
		print("111:");
		local file_name_ = g_photo_root .. getHttpUrlLastPart( url_ ) .. "_";	--加上"_"后缀
		--TODO 设置审核的状态

		local function downloadPng_head_cb()
			Log( "call downloadPng_head_cb, file=" .. file_name_ );

			--保存头像文件路径
			if  t_exhibition:isLookSelf() then
				print("setkv:head_pic_cache:file_name_ = " .. file_name_);
				setkv( "head_pic_cache", file_name_ );
			end

			playerInfo.headIndexFile = file_name_;
			PEC_SetPlayerHead( playerInfo.headIndexFile,playerInfo.head_frame_id)
		end

		ns_http.func.downloadPng( url_, file_name_, nil, nil, downloadPng_head_cb );   --下载文件
	elseif  url_ == "d" then
		print("222:");
		playerInfo.headIndexFile = GetHeadIconPath();  	--头像文件
		if  t_exhibition:isLookSelf() then
			setkv( "head_pic_cache", nil );
			PEC_SetPlayerHead( playerInfo.headIndexFile,playerInfo.head_frame_id)
		end
	elseif url_ == "f" then  --头像审核失败
		print("333:");
		if t_exhibition:isLookSelf() then
			setkv( "head_pic_cache", nil );
		end
		--hide
		--TODO 设置审核的状态为隐藏
	else
		print("444:");
		--hide checked png
		--TODO 设置审核的状态为隐藏
	end
end

function PEC_SetHeadCheckState(ui_pic,ui_str) --设置审核状态
	-- body
end

function PEC_SetPlayerHead(file_name,frame_id) --设置头像显示
	local getglobal = _G.getglobal;
	local ui_name = t_exhibition:getUiName();

	if not t_exhibition.isHost and t_exhibition:CheckProfileBlackStat() then
		getglobal(ui_name.."RoleInfoHeadIcon" ):SetTexture("ui/snap_jubao.png");
		showPicNoStretch( ui_name.."RoleInfoHeadIcon" );
	else
        if t_exhibition.isHost then
            showPicNoStretch(ui_name.."RoleInfoHeadIcon");
			-- HeadCtrl:CurrentHeadIcon( 'MiniLobbyFrameTopRoleInfoHeadIcon');
			HeadCtrl:CurrentHeadIcon( GetMiniLobbyRoleInfoIconFrameName() ) --mark by hfb for new minilobby
            HeadCtrl:CurrentHeadIcon(ui_name.."RoleInfoHeadIcon");
        else
			if file_name and string.find(file_name, "data/http/") then
				getglobal(ui_name.."RoleInfoHeadIcon"):SetTexture(file_name);
				showPicNoStretch(ui_name.."RoleInfoHeadIcon");
			else
				HeadCtrl:SetPlayerHeadByUin(ui_name.."RoleInfoHeadIcon",t_exhibition.uin,t_exhibition.playerinfo.Model,t_exhibition.playerinfo.SkinID);
			end
        end
	end


	--设置头像框
	local frameFile = PEC_GetHeadFrameName(frame_id)
	getglobal(ui_name.."RoleInfoHeadNormal"):SetTexture(frameFile);
	getglobal(ui_name.."RoleInfoHeadPushedBG"):SetTexture(frameFile);

	--评论头像
	getglobal("ExhibitionInfoPage1AhutorCommentHeadIcon"):SetTexture( file_name);
	getglobal("ExhibitionInfoPage1AhutorCommentHeadNormal"):SetTexture( frameFile);
	getglobal("ExhibitionInfoPage1AhutorCommentHeadPushedBG"):SetTexture( frameFile);

	--资料设置页面头像
	getglobal("PlayerCenterDataEditPage1HeadBtnHead"):SetTexture( file_name);
	getglobal("PlayerCenterDataEditPage1HeadBtnFrame"):SetTexture( frameFile);

	--资料设置页面头像
	-- getglobal("ZoneHeadEditHead"):SetTexture( file_name);
	resetAllHead();
end

function PEC_GetHeadFrameName(head_id_)
	if head_id_ == nil then
		head_id_ = 1;
	end
    if not g_heads_frame_config_map then
		g_heads_frame_config_map = loadwwwcache('res.HeadFrameDef');
		g_heads_frame_config_map[1] = { FrameID=1, ItemID=1, StringID=5300, Group=1 };				--增加默认框
    end

    if g_heads_frame_config_map[head_id_] and g_heads_frame_config_map[head_id_].IsActive and g_heads_frame_config_map[head_id_].IsActive == 1 then
		local path_ = "ui/headframes/" ..  head_id_ .. ".gif";
		if  gFunc_isFileExist then
			if  gFunc_isFileExist( path_ ) then
				return path_;
			else
				local path_png_ = "ui/headframes/" ..  head_id_ .. ".png";
				if  gFunc_isFileExist( path_png_ ) then
					return path_png_
				else
					return "ui/headframes/1.png"
				end
			end
		else
			return "ui/headframes/" ..  head_id_ .. ".png";
		end
    else
        local suffix;
        if     ClientMgr:isAndroid() then
            suffix = ".ktx";
        elseif ClientMgr:isApple() then
            suffix = ".pvr";
        else
            suffix = ".png";
        end

        local path_ = "ui/headframes/" ..  head_id_ .. suffix;
        if  gFunc_isFileExist then
            --先找ktx pvr
            if  gFunc_isFileExist( path_ ) then
                return "ui/headframes/" ..  head_id_ .. ".png";
            else
                --找png
                local path_png_ = "ui/headframes/" ..  head_id_ .. ".png";
                if  gFunc_isFileExist( path_png_ ) then
                    return path_png_
                else
                    return "ui/headframes/1.png"
                end
            end
        else
            return "ui/headframes/" ..  head_id_ .. ".png";
        end
    end
end

--设置模型显示
function PEC_ShowSkinModel(bNotAni)

	GetInst("BestPartnerPlayerCenter"):InitTable(bNotAni)
	--GetInst("BestPartnerPlayerCenter"):ShowSkinModel(bNotAni)

	--[[ZoneDetachPlayerCenterUIModel();
	local modeBase = getglobal("PlayerExhibitionCenterModeViewModeBase")
	modeBase:SetAnchorOffset(-350,-130)
	modeBase:SetSize(208,45)

	local actorPosOffsetY = 0
	local mountPosOffsetX = 200
	local mountPosOffsetY = 0
	--折叠屏需分别手动调整人物和坐骑模型的位置进行适配
	-- if SdkManager:isCollapsableDevice() then 
	-- 	local screenWidth = GetScreenWidth()
	-- 	local screenHeight = GetScreenHeight()
	-- 	--收起
	-- 	if screenWidth/screenHeight <= 2.5 then
	-- 		actorPosOffsetY = -200
	-- 		mountPosOffsetY = -200
	-- 	end
	-- end
	local roleview = getglobal(t_exhibition:getModelViewUiName())
	roleview:setCameraWidthFov(30);
	roleview:setCameraLookAt(0, 220, -1200, 0, 128, 0);
	roleview:setActorPosition(0, 30+actorPosOffsetY, -320);

	local callBack = function(player,roleInfo)
		--人物模型设置
		if player then
			if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
				roleview:attachActorBody(player, 0, false)
			else
				player:attachUIModelView(roleview, 0, false);
			end
			player:setScale(1);	
	
			if not bNotAni then
				roleview:playActorAnim(1, 0);
				ZonePlayAnim(player,false,1,roleInfo);
			end
		end
		--坐骑模型设置
		local horseView = getglobal("PlayerExhibitionCenterModeViewMountsView")
		local mountsID = roleInfo and roleInfo.MountID or 0
		if mountsID and mountsID > 0 then
			horseView:Show()
			local horseBody = UIActorBodyManager:getHorseBody(mountsID, false);
			if horseBody then
				if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
					horseView:attachActorBody(horseBody, 1, false)
				else
					horseBody:attachUIModelView(horseView, 1, false);
				end

				horseView:setCameraWidthFov(30)
				horseView:setCameraLookAt(0, 220, -1300, 0, 128, 0);
				horseView:setActorPosition(-260+mountPosOffsetX, 20+mountPosOffsetY, -150,1);
				horseView:setRotateAngle(30,1)

				roleview:setActorPosition(20, 30+actorPosOffsetY, -320);
				modeBase:SetAnchorOffset(-330,-120)
				modeBase:SetSize(416,90)

				local def_scale = 0.9
				local horseDef = DefMgr:getHorseDef(mountsID)
				if horseDef then
					if horseDef.ShopUIScale > 0 then
						def_scale = horseDef.ShopUIScale
					end
					if horseDef.PlayerCenterPosition and horseDef.PlayerCenterPosition ~= "" then
						local positionList = split(horseDef.PlayerCenterPosition,',')
						horseView:setActorPosition(positionList[1]+mountPosOffsetX, positionList[2]+mountPosOffsetY, positionList[3],1);
					end
				end
				horseBody:setScale(def_scale)
			end
		else
			horseView:Hide()
		end
	end
	ZoneGetPlayer2Model(callBack);
	]]
	
end

function PEC_ExhibitionTab(index) --展示界面切换
	print("PEC_ExhibitionTab:");
	print(debug.traceback());
	--[[
	if index ==nil or index <=0 then return end

	if index >= 2 and t_exhibition:CheckOtherProfileBlackStat() then 
		ShowGameTips(GetS(10593));
		return;
	end

	if index == 3 and IsProtectMode() then
		--13岁保护模式:不让查看相册
		ShowGameTips(GetS(4842), 3);
		return;
	end

	PEC_ExhibitionTabState(index);

	if index == 1 then 
		PEC_ExhibitionMap();
	elseif index == 2 then 
		PEC_ExhibitionDynamic();

		--发帖按钮开关
		local pushBtn = getglobal("ExhibitionInfoMore");
		print("ns_version.posting_btn = ", ns_version.posting_btn);
		pushBtn:Hide();
		if t_exhibition.isHost and ns_version and check_apiid_ver_conditions(ns_version.posting_btn, false) then
			-- pushBtn:Show();
		end
	elseif index == 3 then
		PEC_ExhibitionAlbum(index);
		statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterAlbumBtn");
	elseif index == 4 then --成就
		PEC_ExhibitionAchievement(index);
	end
	]]
end

function PEC_ExhibitionMap() --展示界面地图页
	getglobal("ExhibitionInfoMore"):Show();
end

function PEC_ExhibitionDynamic() --展示界面动态页
	-- body
	ZoneDynamicTabOnClick();
end

function PEC_ExhibitionAlbum(index) --展示界面相册页
	local getglobal = _G.getglobal;
	-- getglobal("ExhibitionInfoMore"):Hide();

	local photoList = t_ExhibitionCenter.getPhotoFileList();
	local PhotoInfo = t_ExhibitionCenter.getPhotoInfo();

	local cellName = "ExhibitionInfoPage3CommentSliderCell";
	local ui_plane = getglobal("ExhibitionInfoPage3CommentSliderPlane")
	local showNum = 6;

	if PhotoInfo and PhotoInfo.photo_unlock and PhotoInfo.photo_unlock == t_ExhibitionCenter.photoMax then 
		showNum = t_ExhibitionCenter.photoMax;
	elseif PhotoInfo and PhotoInfo.photo_unlock and PhotoInfo.photo_unlock >= showNum  then 
		local tempNum = (PhotoInfo.photo_unlock)%2 ;
		if tempNum ==1 then  
			showNum = PhotoInfo.photo_unlock + 1;
		else 
			showNum = PhotoInfo.photo_unlock + 2;
		end
	end

	LayoutManagerFactory:newRelativeOffsetGridLayoutManager()
		:setRelativeTo("ExhibitionInfoPage3CommentSliderPlane")
		:addRegularUICount(cellName, t_ExhibitionCenter.photoMax)
		-- :setBoxItemNamePrefix()
		:setHorizontal()
		:setBoxItemWidth(345)
		:setBoxItemHeight(279)
		:setMarginX(24)
		:setMarginY(38)
		:setOffsetX(46)
		:setOffsetY(0)
		:setMaxColumn(3)
		:layoutAll(showNum)
		:hideRestUI()
		:resetPlaneWithMinimalSize(1104, 535)
		:recycle()

	for i=1 ,showNum do 
		local ui_cell  			= getglobal(cellName..i);
		local ui_pic  			= getglobal(cellName..i.."Pic");
		local ui_picNone  		= getglobal(cellName..i.."PicNone")
		local ui_lockBtn 		= getglobal(cellName..i.."Lock");
		local ui_addBtn 		= getglobal(cellName..i.."Add");
		local ui_examinePic 	= getglobal(cellName..i.."Label");
		local ui_examineText 	= getglobal(cellName..i.."LabelText");
		local ui_praiseBtn 		= getglobal(cellName..i.."PraiseBtn");
		local ui_praiseIcon		= getglobal(cellName..i.."PraiseBtnIcon");
		local ui_praiseFont		= getglobal(cellName..i.."PraiseBtnFont");
		local pic_name 			= cellName..i.."Pic"

		ui_picNone:Hide();
		ui_praiseBtn:Hide();

		if PhotoInfo and PhotoInfo.photo_unlock and i <= PhotoInfo.photo_unlock then 
			ui_pic:Hide();
			--ui_cell:Disable();

			local photoFile = photoList[i];
			if photoFile then 
				if t_exhibition.isHost then
					ui_cell:Enable();
					local code = photoFile.checked;
					if code ==1 then --审核通过
						ui_examineText:Hide();
						ui_examinePic:Hide();
						ui_praiseBtn:Show(); 
					elseif code ==2 then --审核失败
						ui_examineText:Show();
						ui_examinePic:Show();
						ui_examineText:SetText(GetS(3468));
					else --未审核
						ui_examineText:Show();
						ui_examinePic:Show();
						ui_examineText:SetText(GetS(3469));
					end	
				else 
					ui_examineText:Hide();
					ui_examinePic:Hide();
					ui_praiseBtn:Show(); 
				end

				--点赞
				-- ui_praiseIcon:SetTexUV("mngfg_dianzan03");
				ui_praiseFont:SetTextColor(255,255,255);
				if photoFile.ppc then 
					ui_praiseFont:SetText("（"..photoFile.ppc.."）");
				else 
					ui_praiseFont:SetText("（0）")
				end

				ui_lockBtn:Hide();
				ui_addBtn:Hide();

				if not IsLookSelf() and t_exhibition:CheckProfileBlackStat(ns_playercenter.op_uin) then 
					ui_pic:SetTextureCentrally("ui/snap_jubao.png");
					ui_pic:Show();
				else
					local function no_stretch()
						showPicNoStretch( pic_name );
						ui_pic:Show();
					end
					ns_http.func.downloadPng( photoFile.url, 
											photoFile.filename .. "_",		--加上"_"后缀
											nil, pic_name, no_stretch );   --下载文件
				end
			else 
				ui_lockBtn:Hide();
				ui_examineText:Hide();
				ui_examinePic:Hide();

				if t_exhibition.isHost then 
					ui_addBtn:Show();
				else  
					ui_picNone:Show();
					ui_addBtn:Hide();
				end
			end 

		else
			--ui_cell:Disable();
			ui_pic:Hide();
			ui_lockBtn:Show();

			if t_exhibition.isHost then
				ui_lockBtn:Enable();
			else
				ui_lockBtn:Disable();
			end
			ui_addBtn:Hide();
			
			ui_examineText:Hide();
			ui_examinePic:Hide();
		end

	end
end

function PEC_ExhibitionAchievement(index) --成就页面
	print("PEC_ExhibitionAchievement:");
	UIAchievementMgr:Init();
	-- UIAchievementMgr:SetRequestAllFlag()
end

function PEC_MapTabState(index)
	local tabName = "ExhibitionMapFrameTabsTab";

	for i=1,3 do 
		local ui_selected = getglobal(tabName..i.."Checked");
		local ui_text = getglobal(tabName..i.."Name");

		local tabInfo = t_exhibitionMap.getTabInfo(i);

		if index ==i then 
			ui_selected:Show();
			-- ui_text:SetText(GetS(tabInfo.title));
			ui_text:SetTextColor(76,76,76);
		else 
			ui_selected:Hide();
			-- ui_text:SetText(GetS(tabInfo.title));
			ui_text:SetTextColor(191,228,227);
		end 
	end
end

function ExhibitionMapFramePage1_numberOfCellsInTableView(tableView)
	return #(t_exhibitionMap.tab[t_exhibitionMap.curSelectTab].maplist or {})
end

function ExhibitionMapFramePage1_tableCellSizeForIndex(tableView, index)
    local colidx = math.mod(index, 4)
	return 10 + colidx * 258, colidx * 8, 256, 329
end

function ExhibitionMapFramePage1_tableCellWillRecycle(tableView, cell)
    if cell then
        cell:Hide()
    end
end

function ExhibitionMapFramePage1_tableCellAtIndex(tableView, idx)
	local view_name = MapList_Name
	local cell_tmpl = MapListCell_TemplateName
	local cell, uiidx = tableView:dequeueCell(0)

	if not cell then
		local cell_name = view_name .. "Item" .. uiidx
		cell = UIFrameMgr:CreateFrameByTemplate("Frame", cell_name, cell_tmpl, view_name)
	else
		cell:Show()
	end
	local mapInfo = t_exhibitionMap.tab[t_exhibitionMap.curSelectTab].maplist[idx + 1];
	ExhibitionMapFramePage1_ResetCellItemData(cell, mapInfo, idx)
	local id = idx + 1
	local map = t_exhibitionMap.tab[t_exhibitionMap.curSelectTab].maplist[id];
	if map then 
		ExhibitionMapFramePage1_standReportItem(id,map,"view")
	end
	return cell
end

function ExhibitionMapFramePage1_ResetCellItemData(archui, map, index)
	local options = {hideRankTag=false};
	local archname = archui:GetName();

	if map then
		local mapname = map.name or ""; --限制8个中文字符

		getglobal(archname.."Name"):SetText(ReplaceFilterString(mapname));

		GetMapThumbnail(map, archname.."Pic");

		
		local download_num = map.download_count or 0;

		--下载量
		if  lang_show_as_K() and download_num > 1000 then
			getglobal(archname.."Down"):SetText(string.format("%0.1f", download_num/1000).. 'K');
		elseif download_num > 10000 then
			getglobal(archname.."Down"):SetText(string.format("%0.1f", download_num/10000)..GetS(3841)); --X.X万
		else
			getglobal(archname.."Down"):SetText(tostring(download_num));
		end

		--评论数
		local comment_num = map.comment_num;
		getglobal(archname.."Comment"):SetText(tostring(comment_num)..GetS(6027));

		local gameLabel = tonumber(map.label) or 0;
		if gameLabel == 0 then
			gameLabel = GetLabel2Owtype(map.worldtype or 0);
		end
		SetRoomTag(getglobal(archname.."LabelIcon"), getglobal(archname.."LabelName"), gameLabel);

		--脚标
		local display_rank = map.display_rank or 0;
		if display_rank == 0 or options.hideRankTag then  --0=已上传
			getglobal(archname.."TagBkg"):Hide();
			getglobal(archname.."TagName"):Hide();
		elseif display_rank == 1 then  --1=已投稿
			getglobal(archname.."TagBkg"):Show();
			getglobal(archname.."TagBkg"):SetTexUV("label_map_hot");
			getglobal(archname.."TagName"):Show();
			getglobal(archname.."TagName"):SetText(GetS(3842));  --待审
			getglobal(archname.."TagName"):SetTextColor(55, 54, 49);	 --设置颜色
		elseif display_rank == 2 then  --2=已精选
			getglobal(archname.."TagBkg"):Show();
			getglobal(archname.."TagBkg"):SetTexUV("label_map_selection");
			getglobal(archname.."TagName"):Show();
			getglobal(archname.."TagName"):SetText(GetS(3843));  --精选
			getglobal(archname.."TagName"):SetTextColor(55, 54, 49);	 --设置颜色
		elseif display_rank == 3 then  --3=已推荐
			getglobal(archname.."TagBkg"):Hide();
			getglobal(archname.."TagName"):Hide();
		end

		--分数
		-- SetArchiveGradeUI(getglobal(archname.."Grade"), map.star or 3);
		
		local labelFrame = getglobal(archname.."EditLabel");
		local labelFramePic = getglobal(archname.."EditLabelPic");
		local labelFrameIcon = getglobal(archname.."EditLabelIcon");

		labelFrame:Hide();
		if t_exhibitionMap.curSelectTab == 3 then
			-- getglobal(archname.."EditLabelPic"):Hide();
			-- getglobal(archname.."EditLabelTitle"):Hide();
		else 
			if map.open == 2 then 
				--隐藏
				labelFrame:Show();
				labelFramePic:SetTexUV("label_map_hide");
				labelFrameIcon:SetTexUV("icon_hide_white");
				labelFrameIcon:SetSize(17, 11);
				-- getglobal(archname.."EditLabelPic"):Show();
				-- getglobal(archname.."EditLabelPic"):SetTexUV( "drlj_yshoucnag02.png"  );
				-- getglobal(archname.."EditLabelTitle"):Show();
				-- getglobal(archname.."EditLabelTitle"):SetText(GetS(20528));
			else 
				-- getglobal(archname.."EditLabelPic"):Hide();
				-- getglobal(archname.."EditLabelTitle"):Hide();
			end

			if t_exhibitionMap.mapTop.owid and map.owid == t_exhibitionMap.mapTop.owid then 
				--置顶
				labelFrame:Show();
				labelFramePic:SetTexUV("label_map_top");
				labelFrameIcon:SetTexUV("icon_top");
				labelFrameIcon:SetSize(17, 8);
				-- getglobal(archname.."EditLabelPic"):Show();
				-- getglobal(archname.."EditLabelPic"):SetTexUV( "drlj_yshoucnag.png"  );
				-- getglobal(archname.."EditLabelTitle"):Show();
				-- getglobal(archname.."EditLabelTitle"):SetText(GetS(1054));
			elseif map.open ~= 2 then 
				-- getglobal(archname.."EditLabelPic"):Hide();
				-- getglobal(archname.."EditLabelTitle"):Hide();
			end
		end

		--游玩次数
		local ui_playCount = getglobal(archname.."PlayCount");
		ui_playCount:SetText(GetS(6660468)..": "..map.play_count)
		--更新时间
		local ui_updateTime = getglobal(archname.."UpdateTime");
		local sTime = os.date("%Y-%m-%d", map.last_upload_time or map.createtime);
		ui_updateTime:SetText(GetS(25227)..": "..sTime)

		--推荐语 和下载按钮显示
		local ui_recommend = getglobal(archname.."Recommend");
		-- local ui_download = getglobal(archname.."FuncBtn");
		local ui_EditBtn = getglobal(archname.."EditBtn");
		local mapComment;


		if t_exhibitionMap.curSelectTab ~= 3 then
			if t_exhibitionMap.recommendList and t_exhibitionMap.recommendList[map.owid] then
				mapComment = GetS(15500)..'\r\n'..t_exhibitionMap.recommendList[map.owid].txt;
			elseif map.memo~= nil and map.memo ~= "" then
				mapComment = map.memo --GetS(15501)..'\r\n'..map.memo
			else
				mapComment =  GetS(178);
				if t_exhibition.isHost then
					mapComment = GetS(20532);
				else
					mapComment = GetS(20533)
				end
			end
		elseif  t_exhibitionMap.curSelectTab == 3 then
			if map.push_comments[1] and map.push_comments[1].msg then 
				mapComment = unescape(map.push_comments[1].msg);
			else 
				mapComment = ""
			end
		end
		mapComment = DefMgr:filterString(mapComment);
		ui_recommend:SetText(GetInst("GameHallToolInterface"):CutStringByWord(mapComment, 28));
		UpdateSingleArchiveDownloadState(archui, map);
		if t_exhibition.isHost and t_exhibitionMap.curSelectTab ~= 3 then
			-- ui_download:Hide();
			ui_EditBtn:Show();
		else 
			-- ui_download:Show();
			ui_EditBtn:Hide();
		end
	else
		getglobal(archname.."Pic"):SetTexture("");
	end
end

function PEC_ExhibitionMapArchiveSwitch( index )
	local maplist = t_exhibitionMap.tab[index].maplist;

	local panelName= "ExhibitionMapFramePage1";
	local ui_panel = getglobal(panelName);
	local emptyFrame = getglobal("ExhibitionMapFrameEmptyFrame");

	if maplist and #maplist>0 then 
		ui_panel:Show();
		emptyFrame:Hide();
		local num = #maplist;	 
		local row = math.ceil(num/mapListColumn)
		local listWidth = getglobal("ExhibitionMapFramePage1"):GetRealWidth2()
		local listHeight = getglobal("ExhibitionMapFramePage1"):GetRealHeight2()
		getglobal("ExhibitionMapFramePage1"):initData(listWidth, listHeight, row, mapListColumn)
		-- getglobal("ExhibitionMapFramePage1"):Show()
	else 
		ui_panel:Hide();
		emptyFrame:Show();
	end
end

function PEC_MapFuncBtn(funcBtnUi, map, options)
	Log("MapFuncBtn_OnClick btn="..funcBtnUi:GetName());

	options = options or {};

	if funcBtnUi and map then
		if getglobal(funcBtnUi:GetName().."Name1"):IsShown() then  --下载
			local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(map.owid);
			if mapIsBreakLaw == 1 then
				ShowGameTips(GetS(10559), 3);
				return;
			elseif mapIsBreakLaw == 2 then
				ShowGameTips(GetS(3636), 3);
				return;
			end

			--存档多语言判断
			local supportlang = map.translate_supportlang or 0;
			local sourcelang  = map.translate_sourcelang or 0;
			if supportlang - math.pow(2, sourcelang) <= 0 then
				supportlang = -1;
			end

			MapDownloadReportMgr:TryReportMapDownload(map.owid,supportlang);
			--MapDownloadReportMgr:TryReportMapDownload(map.owid);
			downloadMapSign = true;	--LLTODO:开始刷新按钮
			if getglobal("MiniWorksFrame"):IsShown() then
				options.statisticsDownload = true;
				DownloadMap(map, options);
			else
				DownloadMap(map, options);
			end
		elseif getglobal(funcBtnUi:GetName().."Name2"):IsShown() then  --进入
			local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(map.owid);
			if mapIsBreakLaw == 1 then
				ShowGameTips(GetS(10561), 3);
				return;
			elseif mapIsBreakLaw == 2 then
				ShowGameTips(GetS(3636), 3);
				return;
			end

			if EnterDownloadedMap(map) then
				-- statisticsGameEvent(707, "%d", statisticsType, "%lld",map.owid);
				UIFrameMgr:hideAllFrame();
				ShowLoadingFrame();
			end

		elseif getglobal(funcBtnUi:GetName().."Name3"):IsShown() then  --暂停
			StopDownloadMap(map);
		end
	end
end

function PEC_DownLoadEvaluateMap()
	local mapIdList = {};

	if t_exhibitionMap.isExpert and #(t_exhibitionMap.evaluateList)>0 then 
		for i=1, #(t_exhibitionMap.evaluateList) do 
			table.insert(mapIdList,t_exhibitionMap.evaluateList[i].fn);
		end
	end

	if #mapIdList >0 then 
		ReqExpertMapInfo(mapIdList, PEC_RespEvaluatemap, nil, {'normal', 'select'}, t_exhibition.uin);
	end
end

function PEC_UpdatePlayerCenterState() --
	local frame_name			 = t_exhibition:getUiName();
	local ui_Friend 			 = getglobal(frame_name.."Friend");
	local ui_attention  		 = getglobal(frame_name.."Focus");
	local ui_FriendIcon 		 = getglobal(frame_name.."FriendIcon");
	local ui_attentionIcon  	 = getglobal(frame_name.."FocusIcon");

	if ui_attention:IsShown() then
		
		local uin = t_exhibition.uin
		local fridData = GetFlowingPlayerData(uin)
		local followStatus = fridData and fridData.relation and fridData.relation.is_toattention
		local bCanFollow = CanFollowPlayer(uin)

		if not followStatus then
			ui_attentionIcon:SetTexUV("icon_like_h")
		else 
			ui_attentionIcon:SetTexUV("icon_like_n")
		end

		-- local bCanFollow = CanFollowPlayer(uin)
		-- local friendData = GetFriendDataByUin(uin)

		-- if friendData then 
		-- 	bCanFollow = false
		-- else 
		-- 	bCanFollow = true
		-- end
		if uin == AccountManager:getUin() then 
			bCanFollow = false
		end

		if bCanFollow == false then
			ui_attention:Disable()
		else
			ui_attention:Enable()
		end
	end

	if ui_Friend:IsShown() then 
		if CanAddUinAsFriend(t_exhibition.uin) then
			ui_Friend:Enable();
			ui_FriendIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
			ui_FriendIcon:SetTexUV("icon_addFriend")
			ui_FriendIcon:SetWidth(34);
			ui_FriendIcon:SetHeight(34);
		else
			ui_Friend:Disable();
			ui_FriendIcon:SetTextureHuiresXml("ui/mobile/texture2/friend.xml");
			ui_FriendIcon:SetTexUV("icon_isFriend")
			ui_FriendIcon:SetWidth(34);
			ui_FriendIcon:SetHeight(34);
		end
	end
	
end


--判断自身还是别的人个人空间，进行相关按钮的显示与隐藏
function PEC_PlayerCenterStateShow(isSelf)
	local frame_name			 = t_exhibition:getUiName();

	local ui_Friend 			 = getglobal(frame_name.."Friend");
	local ui_attention  		 = getglobal(frame_name.."Focus");

	if isSelf then
		ui_Friend:Hide();
		ui_attention:Hide()
	else 
		ui_Friend:Show();
		ui_attention:Show();
		standReportEvent("43", "PLAYER_INFO_HOMEPAGE", "FriendRequestButton", "view", {standby1=t_exhibition.uin or "0"})
		standReportEvent("43", "PLAYER_INFO_HOMEPAGE", "FollowButton", "view")
		PEC_UpdatePlayerCenterState()
	end
end

function PEC_BeginUploadPhoto(index) --上传相册
	local photoInfo = t_ExhibitionCenter.getPhotoInfo();

	if photoInfo and index <= photoInfo.photo_unlock then 
		t_ExhibitionCenter.upload_pic_callback = function()		
			if  gFunc_isStdioFileExist(g_photo_root .. "photo_upload_tmp.png") then
				--请求上传位置
				ns_http.func.upload_md5_file_pre( PEC_BeginUploadPhotoPre_cb );

				--TODO ui处理
				getglobal("ExhibitionInfoPage3CommentSliderCell"..index.."Add"):Hide();
				getglobal("ExhibitionInfoPage3CommentSliderCell"..index.."BarBkg"):Show();
				getglobal("ExhibitionInfoPage3CommentSliderCell"..index.."Bar"):Show();

			else
				Log("cancel upload");  			--没有文件，放弃
			end
		end

		--bool showImagePicker(std::string path, int type, bool crop=true);	//type 1相册 2相机
		if  ClientMgr:showImagePicker( g_photo_root .. "photo_upload_tmp.png", 1 )  then
			--select ok
		else
			t_ExhibitionCenter.upload_pic_callback = nil;
			Log( "showImagePicker = false" );
		end

	end
end

--开始上传图片回调
function PEC_BeginUploadPhotoPre_cb( ret_ )
	if  string.sub( ret_, 1, 3 ) == "ok:" then
		local upload_url_ =  string.sub( ret_, 4 );
		upload_url_ = string_trim( upload_url_ );
		Log( "[" .. upload_url_  .. "]" );
		ns_http.func.upload_md5_file( g_photo_root .. "photo_upload_tmp.png",  upload_url_, PEC_BeginUploadPhoto_cb  );

	else
		Log( "PlayerCenterFrame_uploadPhotoPre_cb = false" );
	end
end

--上传图片完成回调
function PEC_BeginUploadPhoto_cb( ret, token_ )
	--设置玩家相册
	if  ret == 200 then
		--进度条
		print("PEC_BeginUploadPhoto_cb:111:");
		getglobal("ExhibitionInfoPage3CommentSliderCell"..t_ExhibitionCenter.selectPhotoId.."BarBkg"):Hide();
		getglobal("ExhibitionInfoPage3CommentSliderCell"..t_ExhibitionCenter.selectPhotoId.."Bar"):Hide();
		
		--ok:token=6f8c3d78a2b238bd0e9a259b6c7605a5&node=2&dir=20170415
		if  token_ and  string.sub( token_, 1, 3 ) == "ok:" then
			print("PEC_BeginUploadPhoto_cb:222:")
			local sub_token_ = string.sub( token_, 4 );
			sub_token_ = string_trim( sub_token_ );
			Log( "[" .. sub_token_  .. "]" );
			local file_path_ = g_photo_root .. "photo_upload_tmp.png";
			local seq_ =PEC_GetPhotoUploadIndex();
			t_ExhibitionCenter.uploadPhotoId = seq_;

			if seq_ ~= -1 then
				print("PEC_BeginUploadPhoto_cb:333:")
				ns_http.func.set_user_profile_photo( file_path_, seq_, sub_token_, PEC_SetPlayerProfilePhoto_cb );
				t_exhibition.self_data_dirty = true;
			end
		end

	elseif token_ and token_ == "progress" then
		--进度条
		ret = ret or 0;
		local width = tonumber(ret) or 0;
		width = (width / 200) * 316;
		print("PEC_BeginUploadPhoto_cb: width = ", width);
		getglobal("ExhibitionInfoPage3CommentSliderCell"..t_ExhibitionCenter.selectPhotoId.."Bar"):SetWidth( width or 0 );

	else

	end
end

--设置图片成功
function PEC_SetPlayerProfilePhoto_cb( ret_ )
	--请求玩家头像下载地址 更新为新上传的图片
	if  string.sub( ret_, 1, 3 ) == "ok:" then
		local upload_url_ =  string.sub( ret_, 4 );
		upload_url_ = string_trim( upload_url_ );
		Log( "[" .. upload_url_  .. "]" );

		--改文件，节省流量
		PEC_Rename_photo_pic_to_md5( "photo_upload_tmp.png" );
		PEC_SetPlayerPhotoByUrl( upload_url_ );

		--模拟点击相册
		ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabPhoto);
	else
		operate_fail();
	end
end

--直接改文件名，节省流量
function  PEC_Rename_photo_pic_to_md5( file_name )
	Log( "call rename_photo_pic_to_md5" );
	local f1_  = g_photo_root .. file_name;
	local md5_ = gFunc_getBigFileMd5(f1_);
	local f2_  = g_photo_root .. md5_ .. ".png";
	gFunc_renameStdioPath( f1_, f2_ );
end

--更新图片文件
function  PEC_SetPlayerPhotoByUrl( url_ )
	if  url_ and #url_ > 3 then
		local file_name_ = g_photo_root .. getHttpUrlLastPart( url_ );

		local i = t_ExhibitionCenter.selectPhotoId
		t_ExhibitionCenter.photoFileList[i] = t_ExhibitionCenter.photoFileList[i] or {};
		t_ExhibitionCenter.photoFileList[i].url      = url_;
		t_ExhibitionCenter.photoFileList[i].filename = file_name_;
		if t_ExhibitionCenter.uploadPhotoId ~= -1 then
			table.insert(t_ExhibitionCenter.photoServerIndex,t_ExhibitionCenter.uploadPhotoId);
			t_ExhibitionCenter.uploadPhotoId = -1;
		end

		if  t_ExhibitionCenter.photoFileList[i] then
			t_ExhibitionCenter.photoFileList[i].checked = 0;
		end

		PEC_RefreshUI();
	end
end

function PEC_UnlockPhoto() --解锁相册逻辑
	ns_http.func.unlockCost( "unlock_photo", PEC_UnlockPhoto_cb );
end


function PEC_UnlockPhoto_cb( ret_ )
	Log( "call beginUnlockPhoto_cb=" .. ret_ );

	if  AccountManager.data_update then
		AccountManager:data_update();
	end

	if  string.sub( ret_, 1, 3 ) == "ok:" then
		local ret_code_ =  string.sub( ret_, 4 );
		ret_code_ = string_trim( ret_code_ );
		Log( "ret_code=" .. (ret_code_ or '0' ) );
		ret_code_ = tonumber( ret_code_ );
		if  ret_code_ > 3 then
			local photoInfo =  t_ExhibitionCenter.getPhotoInfo();
			if photoInfo then 
				photoInfo.photo_unlock = ret_code_;
			end
			ShowGameTips( GetS(3476), 3 );  --"你解锁了新的相册位置！", 3 );
		else
			--ns_playercenter.head_unlock = 0;
			ShowGameTips( GetS(3474), 3 );     --"解锁失败，请稍后重试。", 3 );
		end
	else
		ShowGameTips( GetS(3474), 3 );     --"解锁失败，请稍后重试。", 3 );
	end

	t_exhibition.self_data_dirty = true;
	PEC_RefreshUI()
	getglobal( 'UnlockPhotoFrame' ):Hide();
end

function PEC_PhotoEditDel_cb(ret)
	if  string.sub( ret, 1, 3 ) == "ok:" then
		--重新刷新图片
		table.remove(t_ExhibitionCenter.photoFileList,t_ExhibitionCenter.selectPhotoId);
		table.remove(t_ExhibitionCenter.photoServerIndex,t_ExhibitionCenter.selectPhotoId);
		PEC_RefreshUI();

		--模拟点击相册
		ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabPhoto);
	else
		Log( "delete photo is fail :PEC_PhotoEditDel_cb()" );
	end
end

function PEC_RefreshUI()
	PEC_ShowPlayerInfo();
	ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabPhoto);

	if getglobal("ExhibitionMapFrame"):IsShown() then 
		PEC_ExhibitionMapArchiveSwitch(t_exhibitionMap.curSelectTab);
	end
end

function PEC_ShowConnoisseur(expert, uin)
	local uiName = t_exhibition:getUiName();
	local btn_name = uiName.."ConnoisseurBtn";
	--local auth_name = uiName.."RealnameInfoFrame" --uiName.."RoleInfoAuthIcon";
	local phone_bindingN = uiName.."RoleInfoPhoneBindingIconNormal";
	local phone_bindingR = uiName.."RoleInfoPhoneBindingIconRedTag";

	local stat = expert and expert.stat or 0;
	local level = expert and expert.level or 0;

	--鉴赏家徽章
	if stat == 2 then
		getglobal(btn_name):Show();

		if not getkv("connoisseur_guide") and  t_exhibition.isHost then
			getglobal(btn_name.."Effect"):Show();
			local cardid = IsLookSelf() and "PERSONAL_INFO_HOMEPAGE" or "PLAYER_INFO_HOMEPAGE"
			standReportEvent(IsLookSelf() and "7" or "43", cardid, "ConnoisseurIcon", "view")
			getglobal(btn_name.."Effect"):SetUVAnimation(100, true);
		end

		local index = level+1;
		
		local uvName = "cwjsj_huizhang0"..index;
		getglobal(btn_name.."Normal"):SetTexUV(uvName);
		getglobal(btn_name.."PushedBG"):SetTexUV(uvName);

	else
		getglobal(btn_name):Hide();
	end

	print("PEC_ShowConnoisseur", RealNameAuthSwitch, expert)

	local realNameFrame = getglobal("PlayerExhibitionCenterRoleInfoRealnameInfoFrame")
	local realNameFrameBg = getglobal("PlayerExhibitionCenterRoleInfoRealnameInfoFrameBg")
	local realNameFrameFont = getglobal("PlayerExhibitionCenterRoleInfoRealnameInfoFrameFont")

	--自己面板 才显示 是否实名
	if t_exhibition.isHost and AccountManager.get_channel_realname_info then
		-- local realname_info_res = {
		-- 	isrealname = false, -- 是否实名
		-- 	use_channel_realname = false,  -- 是否使用渠道实名
		-- 	channel_name = '', -- 渠道名称
		-- }
		local retTab = AccountManager:get_channel_realname_info() or {}
		if retTab.isrealname then
			realNameFrame:Show()
			if retTab.use_channel_realname then
				realNameFrameFont:SetText(GetS(1000935))
				realNameFrameBg:SetSize(107, 20)
			else
				realNameFrameFont:SetText(GetS(1000934))
				realNameFrameBg:SetSize(92, 20)
			end
		else
			realNameFrame:Hide()
		end
	else
		realNameFrame:Hide()
	end

	-- local auth_switch = checkRealNameAuthSwitch()
	-- if auth_switch and uin and tonumber(uin) and AccountManager:getUin() == tonumber(uin) and t_exhibition.isHost and AccountManager.idcard_info and not UseTpRealNameAuth() then
	-- 	getglobal(auth_name):Show();
	-- 	local idCardInfo = AccountManager:idcard_info();
	-- 	local state = AccountManager:realname_state()
	-- 	if state ~= 1 then	--未认证
	-- 		if auth_switch then
	-- 			getglobal(auth_name.."Normal"):SetTexUV("icon_credit_good01");
	-- 			getglobal(auth_name.."PushedBG"):SetTexUV("icon_credit_good01");
	-- 		else
	-- 			getglobal(auth_name):Hide();
	-- 		end
	-- 	else
	-- 		if idCardInfo.age < 18 then		--未满182
	-- 			getglobal(auth_name.."Normal"):SetTexUV("icon_credit_good");
	-- 			getglobal(auth_name.."PushedBG"):SetTexUV("icon_credit_good");
	-- 		else
	-- 			getglobal(auth_name.."Normal"):SetTexUV("icon_credit_good");
	-- 			getglobal(auth_name.."PushedBG"):SetTexUV("icon_credit_good");
	-- 		end
	-- 	end
	-- else
	-- 	getglobal(auth_name):Hide();
	-- end

	local hasBindedPhone = AccountManager:hasBindedPhone()
	local phoneBinding = getglobal(phone_bindingN)
	if hasBindedPhone == 1 then
		getglobal(phone_bindingR):Hide()
		phoneBinding:SetGray(false)
	elseif uin and tonumber(uin) and AccountManager:getUin() == tonumber(uin) then
		getglobal(phone_bindingR):Show()
		phoneBinding:SetGray(true)
	else
		getglobal(phone_bindingR):Hide()
	end
end

function PEC_SetBlackShow(isBlack)  --封号处理
	
	local pageName = "ExhibitionInfoPage"
	local tabName = "ExhibitionInfoTab";

	if isBlack ==1 then 
		getglobal("ExhibitionInfoNull"):Show();
		getglobal("ExhibitionInfoNullTitle"):Show();
		getglobal("ExhibitionInfoNullTitle"):SetText(GetS(20543));
		getglobal("PlayerExhibitionCenterFriend"):Hide();
		getglobal("PlayerExhibitionCenterFocus"):Hide();
	else 
		getglobal("ExhibitionInfoNull"):Hide();
		getglobal("ExhibitionInfoNullTitle"):Hide();
	end

	
	if isBlack==1 then 
		for i =1 ,#(t_ExhibitionCenter.tab) do 
			getglobal(pageName..i):Hide();
			getglobal(tabName..i):Disable();
		end
		return true;
	else
		for i =1 ,#(t_ExhibitionCenter.tab) do 
			--getglobal(pageName..i):Show();
			getglobal(tabName..i):Enable();
		end
		return false;
	end	
end

function PEC_PhotoPraiseNumAdd(num)
	local index = t_ExhibitionCenter.photoPraiseIndex;
	local cellName = "ExhibitionInfoPage3CommentSliderCell";
	local ui_praiseBtn 		= getglobal(cellName..index.."PraiseBtn");
	local ui_praiseIcon		=getglobal(cellName..index.."PraiseBtnIcon");
	local ui_praiseFont		=getglobal(cellName..index.."PraiseBtnFont");
    ui_praiseBtn:Show();

    local photoList = t_ExhibitionCenter.getPhotoFileList();

    if photoList and photoList[index] then 
    	local photoFile = photoList[index];

    	-- ui_praiseIcon:SetTexUV("mngfg_dianzan02");
		ui_praiseFont:SetTextColor(180,242,128);
		if photoFile.ppc then 
			ui_praiseFont:SetText("（"..(photoFile.ppc +num).."）");
		else 
			ui_praiseFont:SetText("（"..num.."）")
		end
    end
	
end

function PEC_GetPhotoUploadIndex()
	local t_index = t_ExhibitionCenter.photoServerIndex;
	local isHas = true;

	if #t_index == 0 then
		return 1;
	end

	if t_index then
		for i =1,t_ExhibitionCenter.photoMax do
			for k,v in pairs(t_index) do
				if v==i then
					isHas =true;
					break;
				else
					isHas=false;
				end
			end
			if isHas ==false then
				return i;
			end
		end
		return -1;
	end
end

function PEC_SetFromJumpFrameName (name) -- 设置跳转的界面名字
	if name ~=nil  then
		PEC_FromJumpFrameName = name;
	end
end

function PEC_BackFormOtherFrame()  --动态分享跳转出其他界面，关闭返回个人中心界面

	-- MiniLobbyFramePlayerCenter_OnClick()
	JumpToPlayerCenter()--mark by hfb for new minilobby 不要埋点
end

ShareToDynamic ={   --游戏内分享到动态
	filename = "",  	--海外分享的截图和国内分享的截图名字不一样 需要通过截图时候传过来
	md5 = "",
	isShareDynamic = false;  				--标志位，用于区分通过分享发动态还是个人中心发动态 DynamicPublishFrame_OnHide():false
	t_actionParameter = {					--跳转参数 global_jump_ui( ui_id, params, string_code ) 对应这个方法
		action = "" ,
		action_url ="",
		action_title = ""	},

	SetPicName = function(self,pic_name)  	--设置图片名字
		if pic_name and pic_name ~= "" then
			self.filename = pic_name;
			self.md5 = gFunc_getBigFileMd5(pic_name) --计算md5，用来确保图片不被篡改
		end
	end,

	GetPicName = function(self, uncheck_md5) -- 获取图片名字，默认校验md5
		if not gFunc_isStdioFileExist(self.filename) then
			return ""
		end

		if not uncheck_md5 then
			local md5 = gFunc_getBigFileMd5(self.filename)
			if md5 ~= self.md5 then
				return ""
			end
		end

		return self.filename
	end,

	SetActionParameter = function(self,action,action_url,action_title)  --设置跳转参数
		if action then
			self.t_actionParameter.action = escape(action);
		end

		if action_url then
			self.t_actionParameter.action_url = escape(action_url);
		end

		if action_title then
			self.t_actionParameter.action_title = action_title or ""
		end
	end,

	Init = function (self)  				--分享动态按钮点击调用，进行初始化
		print("ShareToDynamic:Init()")
		self.isShareDynamic = true;
		if ns_version and check_apiid_ver_conditions(ns_version.posting_pic, false) and check_apiid_ver_conditions(ns_version.posting_link, false) then
			getglobal("DynamicPublishFrameInsertPicBtn"):Enable();
			getglobal("DynamicPublishFrameInsertLinkBtn"):Enable();
		else
			getglobal("DynamicPublishFrameInsertPicBtn"):Disable();
			getglobal("DynamicPublishFrameInsertLinkBtn"):Disable();
		end
	end,

	Reset = function(self)
		print("ShareToDynamic:Reset()")
		self.isShareDynamic = false;
		self.t_actionParameter.action = "";
		self.t_actionParameter.action_url = "";
		getglobal("DynamicPublishFrameInsertPicBtn"):Enable();
		getglobal("DynamicPublishFrameInsertLinkBtn"):Enable();
	end,

	AddPicture = function(self)   			--加入图片显示到界面
		print("ShareToDynamic:AddPicture()");
		local index = GetZoneDynamicMgrParam ().curPicCount + 1;
		local file = self:GetPicName()
		if  file ~= "" then
			print("file ok:");
			print(file);
			GetZoneDynamicMgrParam ().curPicCount = GetZoneDynamicMgrParam ().curPicCount + 1;
			local picUI = "DynamicPublishFrameDynamicPic" .. index;
			local delUI = "DynamicPublishFrameDynamicPic" .. index .. "Del";
			getglobal(picUI):Show();
			getglobal(delUI):Show();
			--getglobal(picUI):ReleaseTexture(file);	--先释放内存中的图片资源
			if string.find(file,"thumb")then
				if Snapshot:isModifyThumbLocalFile(file) then
					getglobal(picUI):SetTexture(file);
				else
					getglobal(picUI):SetTexture("ui/snap_empty.png");
				end
			else
				getglobal(picUI):SetTexture(file);
			end
			-- getglobal(picUI):SetTexture("data/http/photo/dynamic_upload_tmp1.png");
			--getglobal(picUI):SetTexture("ui/mobile/4399icon.png");
			GetZoneDynamicMgrParam ().curPicSeatUsed[1] = true;
			showPicNoStretch(picUI);
		else
			print("file error:");  			--没有文件，放弃
		end
	end,

	UploadPicture = function(self, picIndex)
		print("ShareToDynamic:UploadPicture()");
		local callback_pos = function(ret_)
			--请求位置成功
			print("callback_pos:", ret_);
			if  ret_ and string.sub( ret_, 1, 3 ) == "ok:" then
				local upload_url_ =  string.sub( ret_, 4 );
				upload_url_ = string_trim( upload_url_ );
				print( "[" .. upload_url_  .. "]" );
				local callback_up = function(ret, token_)
					--上传成功
					print("callback_up:");
					print(ret);
					print(token_);
					if  ret == 200 then
						print("successful:200:");
						--ok:token=6f8c3d78a2b238bd0e9a259b6c7605a5&node=2&dir=20170415
						if  token_ and  (string.sub( token_, 1, 3 ) == "ok:" or string.sub( token_, 1, 3 ) == "ok,") then
							print("ok:");
							local sub_token_ = string.sub( token_, 4 );
							sub_token_ = string_trim( sub_token_ );
							Log( "[" .. sub_token_  .. "]" );
							local file_path_ = self:GetPicName();
							if file_path_ ~= "" then
								local callback_add = function(ret_)
									print("callback_add:", ret_);
									if ret_ and ret_.ret == 0 then
										--4. 设置临时相册成功
										GetZoneDynamicMgrParam ().UploadedPicCount = GetZoneDynamicMgrParam ().UploadedPicCount + 1;
										print("self.UploadedPicCount = " .. GetZoneDynamicMgrParam ().UploadedPicCount);
										if GetZoneDynamicMgrParam ().UploadedPicCount >= GetZoneDynamicMgrParam ().curPicCount then
											--全部上传成功, 发布动态
											print("all picture Upload Successful:");
											GetZoneDynamicMgrParam ():PushDynamic();
											ShareToDynamic:Reset();
										end
									else
										if ret_ == nil or ret_ < 0 then
											ShowGameTips(GetS(146));
											ShowLoadLoopFrame(false)
										end
									end
								end

								--3. 把图片设置到玩家临时相册
								local md5 = self.md5
								print("md5 = " .. md5);
								local url = ns_version.proxy_url .. '/miniw/posting?act=add_posting_pic' .. "&seq=" .. picIndex .. "&md5=" .. md5 .. "&ext=png" .. "&" .. sub_token_ .. "&" .. http_getS2Act("posting");
								ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:UploadPicture 1");
								ns_http.func.rpc( url, callback_add, nil, nil, true);
								getglobal("DynamicPublishFrameCommitBtn"):Disable();
								threadpool:work(function ()
									threadpool:wait(3);
									getglobal("DynamicPublishFrameCommitBtn"):Enable();
								end)
							else
								print("file error: UploadPicture")
							end
						end
					else	
						print(ret..'...'..token_);
						if ret == nil or ret < 0 then
							ShowGameTips(GetS(146));
							ShowLoadLoopFrame(false)
						end
					end
				end

				--2. 请求上传图片
				local filename = self.filename;
				print("filename = " .. filename);
				ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:UploadPicture 2");
				ns_http.func.upload_md5_file( filename,  upload_url_, callback_up );
			else
				Log( "PlayerCenterFrame_uploadHeadPre_cb = false" );
				if ret_ == nil or ret_ < 0 then
					ShowGameTips(GetS(146));
					ShowLoadLoopFrame(false)
				end
			end
		end

		--1. 请求上传位置
		ns_http.func.upload_md5_file_pre(callback_pos);
	end,

}

function PEC_SetJumpToFrameName(framename) --跳转出去界面名称设置
	print(" PEC_SetJumpToFrameName(framename)",",framename:",framename)
	if framename ~= "" then
		PEC_JumpToFrameName = framename;
		PEC_StoreFrameInfo();
	end
end

function PEC_GetJumpToFrameName()
	print("PEC_GetJumpToFrameName()",",PEC_JumpToFrameName:",PEC_JumpToFrameName)
	if PEC_JumpToFrameName ~= "" then
		return PEC_JumpToFrameName ;
	end
	return nil;
end

function PEC_StoreFrameInfo()
	--print(" PEC_StoreFrameInfo():", debug.traceback());
	t_frameInfo:reset();
	t_frameInfo.uin = t_exhibition.uin;
	t_frameInfo.tab = t_ExhibitionCenter.curSelectTabID;

	if getglobal("ExhibitionMapFrame"):IsShown() then
		t_frameInfo.isMapFrameShow = true;
		getglobal("ExhibitionMapFrame"):Hide();
	end
	t_frameInfo.mapTab = t_exhibitionMap.curSelectTab;
	t_frameInfo.mapIndex = t_exhibitionMap.curSelectMapIndex;

	if  IsMapDetailInfoShown() then
		t_frameInfo.isMapTipsFrame = true;
	end
end

function PEC_ShowHistoricalFrame()  --显示历史记录的界面信息
	if t_frameInfo.uin ~= nil and t_exhibition.uin == t_frameInfo.uin then
		if t_frameInfo.isMapFrameShow then
			getglobal("ExhibitionMapFrame"):Show()
		end
		getglobal(t_exhibition:getUiName()):Show();

		t_ExhibitionCenter.curSelectTabID = t_frameInfo.tab;
		t_exhibitionMap.curSelectTab = t_frameInfo.mapTab;
		t_exhibitionMap.curSelectMapIndex = t_frameInfo.mapIndex;

		if t_frameInfo.isMapTipsFrame then
			PEC_MapFrameCell_OnClick(t_frameInfo.mapIndex)
		end
		PEC_MapTabBtn_OnClick(t_frameInfo.mapIndex)
		PEC_RefreshUI()

		t_frameInfo:reset();
	end
end

function PEC_SetCloseCallBack(callBack)
	t_exhibition.closeCallBackFunc = callBack
end

------------------------------------------------------成就界面---------------------------------------------------------------------------------
UIAchievementMgr = {}; --管理类
AchievementDefine = {}; -- 事件定义类
PEC_Tools ={}; --工具类
local AchievementData = {}; --数据类
local PEC_AchievementPanel = {};--成就界面
local PEC_AchievementNewPanel = {};--新版成就界面
local PEC_ExhibitionRewardPanel = {}; --成就奖励界面
local PEC_AchieveSuccessPanel = {}; --成就获得界面
local PEC_ObtainAchieveRewardPanel = {}; --勋章获取展示界面
local PEC_ShareAchievePanel={}; --成就分享界面

local PECAchieveShare = true;
local PECFpsShow = true;

--成就系统事件定义
AchievementDefine ={
	ShowAchievementPanel = "ShowAchievementPanel";
	ShowAchieveSuccessPanel = "ShowAchieveSuccessPanel";
	ShowAchieveRewardPanel = "ShowAchieveRewardPanel";
	SelectAchievelevelCell = "SelectAchievelevelCell";         --选中某个成就具体等级的cell
	SetUseAchieveSuccess = "SetUseAchieveSuccess";
	CancelUseAchieve = "CancelUseAchieve";
	ObtainAchieveIncrementData = "ObtainAchieveIncrementData";
	ObtainAchieveRewardSuccess = "ObtainAchieveRewardSuccess"; --领取奖励成功
	ShowObtainAchieveRewardPanel = "ShowObtainAchieveRewardPanel"; --显示获取成就奖励面板
	SetNeedExhibitAchieveData = "SetNeedExhibitAchieveData",  --设置需要展示的成就信息
	ExhibitPanelUseAchieve = "ExhibitPanelUseAchieve",  --成就获取展示面板使用勋章
	UpdateAchieveMainPanelRedTag = "UpdateAchieveMainPanelRedTag" ,  --刷新成就主界面的红点显示
	StartSnapshotForAchieveShare = "StartSnapshotForAchieveShare", --开始为成就分享截图
	EndSnapshotForAchieveShare = "EndSnapshotForAchieveShare",  --结束为成就分享截图
	ShowAchievementPopPanel = "ShowAchievementPopPanel",
}

--成就界面主面板
PEC_AchievementPanel= {
	achieveMgr = nil,
	panelName = nil,

	maxCell = 40,
	--------------------------------------------------------------------------------------
	OnLoad = function(self)
		self.panelName = PEC_AchievementPanel;
		self.achieveMgr = UIAchievementMgr;
		self:OnRegisterEvent();
	end,

	OnRegisterEvent = function(self)
		self.achieveMgr:RegisterEvent(AchievementDefine.ShowAchievementPanel,self.panelName);
		self.achieveMgr:RegisterEvent(AchievementDefine.SetUseAchieveSuccess,self.panelName);
		self.achieveMgr:RegisterEvent(AchievementDefine.CancelUseAchieve,self.panelName);
		self.achieveMgr:RegisterEvent(AchievementDefine.ObtainAchieveIncrementData,self.panelName);
		self.achieveMgr:RegisterEvent(AchievementDefine.UpdateAchieveMainPanelRedTag,self.panelName);
	end,

	OnEvent = function(self,eventName,data)
		if eventName == AchievementDefine.ShowAchievementPanel then
			self:ShowAchievementMainPanel();
			self:UpdateRedTag()
		elseif eventName == AchievementDefine.SetUseAchieveSuccess then
			self:ShowUseAchieveLabel();
		elseif eventName == AchievementDefine.CancelUseAchieve then
			self:HideUseAchieveLabel();
		elseif eventName == AchievementDefine.ObtainAchieveIncrementData then
			self:UpdateRedTag()
		elseif eventName == AchievementDefine.UpdateAchieveMainPanelRedTag then
			self:UpdateRedTag();
		end
	end,
	--------------------------------------------------------------------------------------

	--显示一个成就的信息显示
	ShowOneAchievementCell = function(self,uiName,achieveData,isUse)
		local cellName = uiName; -- ExhibitionInfoPage4AchievementSliderCell27
		local ui_cell = getglobal(cellName);
		local ui_name= getglobal(cellName.."Text");
		local ui_getTime = getglobal(cellName.."TimeText");
		local ui_useLabel = getglobal(cellName.."Label");
		local ui_redTag = getglobal(cellName.."RedTag");

		local ui_iconBtn = getglobal(cellName.."AchievementBtn".."Icon");
		local ui_frameBtn = getglobal(cellName.."AchievementBtn".."Frame");
		local ui_noneBtn = getglobal(cellName.."AchievementBtn".."None");
		local ui_TextBtn = getglobal(cellName.."AchievementBtn".."Text");
		local ui_effect = getglobal(cellName.."AchievementBtn".."Mask");

		if isUse and t_exhibition.isHost then
			ui_useLabel:Show();
		else
			ui_useLabel:Hide();
		end

		ui_effect:Hide();

		if achieveData and next(achieveData)~= nil then
			ui_name:SetText(GetS(achieveData.title));
			ui_cell:SetClientID(achieveData.id);

			local icon_Res = self.achieveMgr:GetIconResources(achieveData.id);
			local frame_Res = self.achieveMgr:GetFrameResources(achieveData.achieve_level);

			ui_iconBtn:Show();
			ui_frameBtn:Show();

			if icon_Res and icon_Res.icon_name then
				ui_iconBtn:SetTextureHuiresXml( "ui/mobile/texture2/achievement.xml" );
				ui_iconBtn:SetTexUV(icon_Res.icon_name..".png");
			end

			if achieveData.achieve_time then
				local time = GetS(20600, self.achieveMgr:GetTimeStamp(achieveData.achieve_time))

				ui_getTime:Show()
				ui_getTime:SetText(time);
				ui_frameBtn:SetGray(false);
				ui_iconBtn:SetGray(false);
				ui_noneBtn:Hide();
				ui_TextBtn:Hide();

				if achieveData.achieve_level ==4 then
					ui_effect:Show();
					ui_effect:SetTexture("ui/mobile/effect/ico_medalf_4.png");
					ui_effect:SetUVAnimation(100, true);
				elseif achieveData.achieve_level ==5 then
					ui_effect:Show();
					ui_effect:SetTexture("ui/mobile/effect/ico_medalf_5.png");
					ui_effect:SetUVAnimation(100, true);
				end

				if frame_Res ~= nil then
					ui_frameBtn:SetTextureHuiresXml( "ui/mobile/texture2/achievement.xml" );
					ui_frameBtn:SetTexUV(frame_Res..".png");
				end
			else

				--ui_frameBtn:SetTexture("ui/mobile/texture/test/"..frame_Res..".png")
				ui_frameBtn:SetTextureHuiresXml( "ui/mobile/texture2/achievement.xml" );
				ui_frameBtn:SetTexUV("cj_wood.png");
				ui_frameBtn:SetGray(true);
				ui_iconBtn:SetGray(true);

				ui_getTime:Hide();
				ui_noneBtn:Hide();
				ui_TextBtn:Show();
			end

			ui_redTag:Hide();
			if achieveData.achieve_to_get and achieveData.achieve_to_get == 1 and t_exhibition.isHost and getglobal(t_exhibition:getUiName()):IsShown() then
				--达成了新成就, 可解锁
				ui_redTag:Show();
				ui_getTime:SetText(GetS(3702));
				ui_getTime:Show();
				ui_TextBtn:Hide();
			end

		end

	end,

	SetAllAchievementLayerout = function(self,num)
		local sliderName = "ExhibitionInfoPage4AchievementSlider";
		if not getglobal(t_exhibition:getUiName()):IsShown() then
			sliderName = "BlockSetHonorFrameAchievementSlider"
		end
		local planeName = sliderName.."Plane";
		if num <=0 then
			getglobal(sliderName):Hide();
		else
			getglobal(sliderName):Show();
		end

		--布局
		local x = 0;
		local y = 0;

		for i =1,self.maxCell do
			local ui_Cell = getglobal(sliderName.."Cell"..i);
			if i <= num then
				local row = math.ceil(i / 4);
				local cel = (i - 1) % 4 + 1;

				x = 18 + (cel - 1) * 254;
				y = (row - 1) * 325;

				ui_Cell:Show();
				ui_Cell:SetClientID(i);
				ui_Cell:SetPoint("topleft", planeName, "topleft",  x, y);
			else
				ui_Cell:Hide();
			end
		end

		local ui_plane = getglobal(planeName);
		y = y + 325;
		ui_plane:SetHeight((y > 503 and y) or 503);
	end,

	--显示成就面板的状态信息，包括总的成就值，将获取的奖励物品
	ShowAchievementState = function(self, data)
		local ui_name = "ExhibitionInfoPage4AchievementState";
		local ui_panel = getglobal(ui_name);
		local ui_achieveObtain = getglobal(ui_name.."Num");
		local ui_achieveAllNum = getglobal(ui_name.."AllNum");
		local ui_achieveBar = getglobal(ui_name.."Bar");
		local ui_rewardPic = getglobal(ui_name.."RewardBtnPic")
		local ui_redTag = getglobal(ui_name.."RewardBtnRedTag");
		local ui_text = getglobal(ui_name.."Text");
		local bodyBkg = getglobal("ExhibitionInfoPage4BodyBkg");

		if t_exhibition.isHost then
			ui_panel:Show();
			bodyBkg:SetAnchorOffset(0, 125);
		else
			ui_panel:Hide();
			bodyBkg:SetAnchorOffset(0, 50);
			return
		end

		PEC_Tools.SetUiTextSelfAdaptionWidth(ui_text,GetS(20594));

		if data then
			PEC_Tools.SetUiTextSelfAdaptionWidth(ui_achieveObtain,data.Num)
			PEC_Tools.SetUiTextSelfAdaptionWidth(ui_achieveAllNum,"/"..data.AllNum)

			local value = (data.Num - data.LastNum)/(data.AllNum-data.LastNum)
			if data.Num  == data.AllNum then value = 1 end
			if value >1 then value =1 end

			ui_achieveBar:SetWidth(value * 820);
			SetItemIcon(ui_rewardPic,data.RewardId);

			if data.NeedGetGift ==1 then
				ui_redTag:Show();
			else
				ui_redTag:Hide();
			end

			--设置奖励列表的相关值
			local uiFrame = "ExhibitionRewardFrameRewardPage";
			PEC_Tools.SetUiTextSelfAdaptionWidth(getglobal(uiFrame .. "Num"), data.Num);
			PEC_Tools.SetUiTextSelfAdaptionWidth(getglobal(uiFrame .. "AllNum"), "/"..data.AllNum);
			getglobal(uiFrame .. "Bar"):SetWidth(value * 820);
		end
	end,

	--显示成就主界面
	ShowAchievementMainPanel = function(self)
		local data = self.achieveMgr:GetAchievementPanelData();
		if data and next(data)~= nil then
			self:ShowAchievePanelBeforeGetData()

			self:ShowAchievementState(data.achieveValue);
			local panelName = "ExhibitionInfoPage4AchievementSliderCell";
			local ui_none = getglobal("ExhibitionInfoPage4EmptyFrame");
			local ui_noneTip = getglobal("ExhibitionInfoPage4EmptyFrameTip");
			local honorFrame = "BlockSetHonorFrameAchievementSliderCell"

			ui_none:Hide();

			local allAchieveData = self:SortAchieveData(data);
			if #allAchieveData <=0  and t_exhibition.isHost == false then
				ui_none:Show();
				ui_noneTip:SetText(GetS(20596));
			end

			local achieveNum = #allAchieveData;


			--if isAbroadEvn() then   					--海外隐藏实名成就
			--	achieveNum = achieveNum -1;
			--end
			self:SetAllAchievementLayerout(achieveNum);

			local uiIndex = 0;
			for i =1,data.AllNum do
				if allAchieveData[i] and allAchieveData[i]~=nil   then
					--if isAbroadEvn() and allAchieveData[i].id == 1021 then			--海外隐藏实名成就
					--if  allAchieveData[i].id == 1021 then			--海外隐藏实名成就
					--
					--else
						uiIndex  = uiIndex +1;
						local cellName = panelName..uiIndex;
						local cellName2 = honorFrame..uiIndex
						local curUseAchieve= self.achieveMgr:GetCurUseAchieve();
						local isUse = false;
						if curUseAchieve and next(curUseAchieve) ~= nil then
							if curUseAchieve.id == allAchieveData[i].id then
								isUse =true;
							end
						end
						if getglobal(t_exhibition:getUiName()):IsShown() then
							self:ShowOneAchievementCell(cellName,allAchieveData[i],isUse);
						else
							self:ShowOneAchievementCell(cellName2,allAchieveData[i],false)
						end
					--end
				end
			end
		end
	end,

	--排序成就，拥有的放在前面，之后按照id排序，是自己的个人中心返回全部成就，别人的，只返回拥有的
	SortAchieveData = function(self,data)
		local allAchieveData = {};

		local t_hasAchieve ={};  --拥有的成就
		local t_otherAchieve = {}; --没有拥有的成就

		if data.AllAchieve then  --分类成就
			for k,v in pairs(data.AllAchieve) do
				if v.achieve_time then
					table.insert(t_hasAchieve,v);
				else
					table.insert(t_otherAchieve,v);
				end
			end
		end

		if t_exhibition.isHost then
			for k,v in pairs(data.AllAchieve) do
				table.insert(allAchieveData,v);
			end

			for i =1 ,(#allAchieveData ) do
				for j =1,(#allAchieveData -i) do
					if allAchieveData[j].id > allAchieveData[j+1].id then
						local temp = allAchieveData[j]
						allAchieveData[j] = allAchieveData[j+1];
						allAchieveData[j+1] = temp;
					end
				end
			end

			--排序成就，年度投票勋章排在前面 yearVote
			table.sort(allAchieveData, function (a, b) 
				local vote_list = {[1025]=true,[1026]=true,[1027]=true,[1028]=true}
				local is_a_vote = vote_list[a.id] or false
				local is_b_vote = vote_list[b.id] or false
				if is_a_vote == is_b_vote then
					return a.id < b.id
				else
					return is_a_vote
				end
				return false
			end )

			return allAchieveData
		else
			for i =1 ,(#t_hasAchieve ) do
				for j =1,(#t_hasAchieve -i) do
					if t_hasAchieve[j].id > t_hasAchieve[j+1].id then
						local temp = t_hasAchieve[j]
						t_hasAchieve[j] = t_hasAchieve[j+1];
						t_hasAchieve[j+1] = temp;
					end
				end
			end

			--排序成就，年度投票勋章排在前面 yearVote
			table.sort(t_hasAchieve, function (a, b) 
				local vote_list = {[1025]=true,[1026]=true,[1027]=true,[1028]=true}
				local is_a_vote = vote_list[a.id] or false
				local is_b_vote = vote_list[b.id] or false
				if is_a_vote == is_b_vote then
					return a.id < b.id
				else
					return is_a_vote
				end
				return false
			end )
			return t_hasAchieve;
		end

			------排序
			--for i =1 ,(#t_hasAchieve ) do
			--	for j =1,(#t_hasAchieve -i) do
			--		if t_hasAchieve[j].id > t_hasAchieve[j+1].id then
			--			local temp = t_hasAchieve[j]
			--			t_hasAchieve[j] = t_hasAchieve[j+1];
			--			t_hasAchieve[j+1] = temp;
			--		end
			--	end
			--end
			--allAchieveData =t_hasAchieve;
			--
			--if t_exhibition.isHost then
			--	for i =1 ,(#t_otherAchieve ) do
			--		for j =1,(#t_otherAchieve -i) do
			--			if t_otherAchieve[j].id > t_otherAchieve[j+1].id then
			--				local temp = t_otherAchieve[j];
			--				t_otherAchieve[j] = t_otherAchieve[j+1];
			--				t_otherAchieve[j+1] = temp;
			--			end
			--		end
			--	end
			--
			--	for i=1,#t_otherAchieve do
			--		local num = #t_hasAchieve + i
			--		table.insert(allAchieveData,t_otherAchieve[i]);
			--	end
			--end
			--return allAchieveData;
	end,

	ShowUseAchieveLabel = function(self)
		local data = self.achieveMgr:GetAchievementPanelData();
		local panelName = "ExhibitionInfoPage4AchievementSliderCell";
		local curUseAchieve= self.achieveMgr:GetCurUseAchieve();

		for i =1,data.AllNum do
			local ui_cell = getglobal(panelName..i)
			local ui_label = getglobal(panelName..i.."Label");

			local id = ui_cell:GetClientID();

			if id ==curUseAchieve.id then
				ui_label:Show();
			else
				ui_label:Hide();
			end
		end
	end,

	HideUseAchieveLabel= function(self)
		local data = self.achieveMgr:GetAchievementPanelData();
		local panelName = "ExhibitionInfoPage4AchievementSliderCell";

		for i =1,data.AllNum do
			local ui_label = getglobal(panelName..i.."Label");
			ui_label:Hide();
		end
	end,

	UpdateRedTag = function(self)
		local data = self.achieveMgr:GetAchievementPanelData();
		if data ==nil or next(data) ==nil then return end

		local hasReceive = false;  --有未领取的奖励

		local cellName = 'ExhibitionInfoPage4AchievementSliderCell'
		for i =1,data.AllNum do
			local id = getglobal(cellName..i):GetClientID();
			getglobal(cellName..i.."RedTag"):Hide();
			if id >1000 then
				local achieve_to_get = data.AllAchieve[id].achieve_to_get;

				if  achieve_to_get ==1 and t_exhibition.isHost then
					getglobal(cellName..i.."RedTag"):Show();
					hasReceive =true;
				end
			end
		end


		---奖励面板的红点判断
		local reward_data = self.achieveMgr:GetAchieveRewardData();
		local rewardList = nil;
		if reward_data then
			rewardList = reward_data.rewardList;
		end

		local reward_redTag = "ExhibitionInfoPage4AchievementStateRewardBtnRedTag";
		local ui_rewardRedTag = getglobal(reward_redTag);
		ui_rewardRedTag:Hide();

		if rewardList then
			for k,v in pairs(rewardList) do
				if v.stat == 1 and t_exhibition.isHost then
					ui_rewardRedTag:Show();
					return
				end
			end
		end

		--如果没有要领取的奖励，设置数据
		if not ui_rewardRedTag:IsShown() then self.achieveMgr.t_data.achieve_gifts_to_get  = 0 end

		local ui_tabRedTag = getglobal("PlayerExhibitionCenterLeftTabBtn4RedTag");
		-- local ui_headRedTag = getglobal("MiniLobbyFrameTopRoleInfoHeadAchieveRedTag");
		local ui_headRedTag = GetMiniLobbyRoleInfoHeadArchiveRedTagFrame(); --mark by hfb for new minilobby
		if ui_rewardRedTag:IsShown() or hasReceive  then
			self.achieveMgr:SetRedTagState(true);
			if t_exhibition.isHost then
				ui_tabRedTag:Show();
			else
				ui_tabRedTag:Hide();
			end

			ui_headRedTag:Show();
			RefreshFguiMainHeadReadTag(true)
		else
			ui_tabRedTag:Hide();
			ui_headRedTag:Hide();
			RefreshFguiMainHeadReadTag(false)
			self.achieveMgr:SetRedTagState(false);
		end
	end,

	--默认没有加载到数据的时候需要做的显示处理
	HideAchievePanelBeforeGetData = function(self)
		getglobal("ExhibitionInfoPage4"):Hide();
		getglobal("ExhibitionInfoPage4AchievementSlider"):Hide()
	end,

	--加载到数据的时候需要做的显示预处理
	ShowAchievePanelBeforeGetData = function(self)
		--加保护，在加载数据时候切换到其他的界面，数据加载完成也不再显示
		if t_ExhibitionCenter.curSelectTabID ~= t_ExhibitionCenter.define.tabAchievement then
			return
		end

		getglobal("ExhibitionInfoPage4"):Show();
	end,

}

--成就界面(首页和弹框)
PEC_AchievementNewPanel= {
	achieveMgr = nil,
	panelName = nil,

	define = {},
	maxCell = 40,  -- 家园弹框

	OnLoad = function(self)
		self.panelName = PEC_AchievementNewPanel;
		self.achieveMgr = UIAchievementMgr;
		
		self.smallMedalFrameName = t_exhibition:getUiName().."MedalFrame"
		self.smallMedalFrame = getglobal(self.smallMedalFrameName)
		self.smallMedalFrame:Show()
		self.smallMedalFrameList = getglobal(self.smallMedalFrameName.."ListView")
		self.emptyFrame = getglobal(self.smallMedalFrameName.."EmptyFrame")
		self.moreBt = getglobal(self.smallMedalFrameName.."MoreMetalBt")
		local emptyTips = getglobal(self.emptyFrame:GetName().."Tip")
		local emptyBkg = getglobal(self.emptyFrame:GetName().."Bkg")
		emptyBkg:SetWidth(435 * 0.6)
		emptyBkg:SetHeight(247 * 0.6)
		emptyTips:SetFontType("BlackFont24")
		emptyTips:SetText(GetS(20596))
		
		self.popMedalFrameName = "NewPlayerCenterMedalView"
		self.popMedalFrame = getglobal(self.popMedalFrameName)
		self.popMedalFrameList = getglobal(self.popMedalFrame:GetName().."ListView")

		-- 家园内弹框
		self.homeMedalFrameName = "BlockSetHonorFrame"

		-- 最大勋章展示数量
		self.define.maxRightMetalNum = 6
		self.define.maxRightNoMetalNum = 3
		self.define.maxRightRowMetalNum = 3
		self.define.maxRightRowNum = 2   -- 最大行
		self.define.maxPopDlgRowMetalNum = 4
		
		-- 勋章数据
		self.allMedalDats = {}
		self.smallMedalDats = {}

		-- 勋章item引用
		self.popMedalItems = {}  -- [id] = metal
		self.smallMedalItems = {}

		self:OnRegisterEvent()
	end,

	OnRegisterEvent = function(self)
		self.achieveMgr:RegisterEvent(AchievementDefine.ShowAchievementPanel,self.panelName)
		self.achieveMgr:RegisterEvent(AchievementDefine.ShowAchievementPopPanel,self.panelName)
		self.achieveMgr:RegisterEvent(AchievementDefine.SetUseAchieveSuccess,self.panelName)
		self.achieveMgr:RegisterEvent(AchievementDefine.CancelUseAchieve,self.panelName)
		self.achieveMgr:RegisterEvent(AchievementDefine.ObtainAchieveIncrementData,self.panelName)
		self.achieveMgr:RegisterEvent(AchievementDefine.UpdateAchieveMainPanelRedTag,self.panelName)
		self.achieveMgr:RegisterEvent(AchievementDefine.ObtainAchieveRewardSuccess,self.panelName)
	end,

	OnEvent = function(self,eventName,data)
		print("PEC_AchievementNewPanel eventName", eventName)
		if eventName == AchievementDefine.ShowAchievementPanel then
			self:ShowAchievementHomePanel()
			self:ShowAchievementSmallPanel()
			self:RefreshAchievementPopPanel()
			self:UpdateRedTag()
		elseif eventName == AchievementDefine.ShowAchievementPopPanel then
			self:ShowAchievementPopPanel()
			self:UpdateRedTag()
		elseif eventName == AchievementDefine.SetUseAchieveSuccess then
			self:ShowUseAchieveLabel()
		elseif eventName == AchievementDefine.CancelUseAchieve then
			self:HideUseAchieveLabel()
		elseif eventName == AchievementDefine.ObtainAchieveIncrementData then
			self:UpdateRedTag()
		elseif eventName == AchievementDefine.UpdateAchieveMainPanelRedTag then
			self:UpdateRedTag()
		elseif eventName == AchievementDefine.ObtainAchieveRewardSuccess then
			self:UpdateRedTag()
		end
	end,
	--------------------------------------------------------------------------------------

	--显示一个成就的信息显示
	ShowOneAchievementCell = function(self,uiName,achieveData,isUse)
		local cellName = uiName
		local ui_cell = getglobal(cellName)
		local ui_name= getglobal(cellName.."Text")
		local ui_getTime = getglobal(cellName.."TimeText")
		local ui_useLabel = getglobal(cellName.."Label")
		local ui_redTag = getglobal(cellName.."RedTag")

		local ui_iconBtn = getglobal(cellName.."AchievementBtn".."Icon")
		local ui_frameBtn = getglobal(cellName.."AchievementBtn".."Frame")
		local ui_noneBtn = getglobal(cellName.."AchievementBtn".."None")
		local ui_TextBtn = getglobal(cellName.."AchievementBtn".."Text")
		local ui_effect = getglobal(cellName.."AchievementBtn".."Mask")

		if isUse and t_exhibition.isHost then
			ui_useLabel:Show()
		else
			ui_useLabel:Hide()
		end

		ui_effect:Hide()

		if achieveData and next(achieveData)~= nil then
			ui_name:SetText(GetS(achieveData.title))
			ui_cell:SetClientID(achieveData.id)

			local icon_Res = self.achieveMgr:GetIconResources(achieveData.id)
			local frame_Res = self.achieveMgr:GetFrameResources(achieveData.achieve_level)

			ui_iconBtn:Show()
			ui_frameBtn:Show()

			if icon_Res and icon_Res.icon_name then
				ui_iconBtn:SetTextureHuiresXml( "ui/mobile/texture2/achievement.xml" )
				ui_iconBtn:SetTexUV(icon_Res.icon_name..".png")
			end

			if achieveData.achieve_time then
				local time = GetS(20600, self.achieveMgr:GetTimeStamp(achieveData.achieve_time))

				ui_getTime:Show()
				ui_getTime:SetText(time)
				ui_frameBtn:SetGray(false)
				ui_iconBtn:SetGray(false)
				ui_noneBtn:Hide()
				ui_TextBtn:Hide()

				if achieveData.achieve_level ==4 then
					ui_effect:Show()
					ui_effect:SetTexture("ui/mobile/effect/ico_medalf_4.png")
					ui_effect:SetUVAnimation(100, true)
				elseif achieveData.achieve_level ==5 then
					ui_effect:Show()
					ui_effect:SetTexture("ui/mobile/effect/ico_medalf_5.png")
					ui_effect:SetUVAnimation(100, true)
				end

				if frame_Res ~= nil then
					ui_frameBtn:SetTextureHuiresXml( "ui/mobile/texture2/achievement.xml" )
					ui_frameBtn:SetTexUV(frame_Res..".png")
				end
			else
				ui_frameBtn:SetTextureHuiresXml( "ui/mobile/texture2/achievement.xml" )
				ui_frameBtn:SetTexUV("cj_wood.png")
				ui_frameBtn:SetGray(true)
				ui_iconBtn:SetGray(true)

				ui_getTime:Hide()
				ui_noneBtn:Hide()
				ui_TextBtn:Show()
			end

			ui_redTag:Hide()
			if achieveData.achieve_to_get and achieveData.achieve_to_get == 1 and t_exhibition.isHost and getglobal(t_exhibition:getUiName()):IsShown() then
				--达成了新成就, 可解锁
				ui_redTag:Show()
				ui_getTime:SetText(GetS(3702))
				ui_getTime:Show()
				ui_TextBtn:Hide()
			end
		end
	end,

	--显示成就面板的状态信息，包括总的成就值，将获取的奖励物品
	ShowAchievementState = function(self,data)
		local ui_name = self.popMedalFrameName
		local ui_achieveState = ui_name .. "AchievementState"
		local ui_panel = getglobal(ui_achieveState)
		local ui_achieveObtain = getglobal(ui_achieveState.."Num")
		local ui_achieveAllNum = getglobal(ui_achieveState.."AllNum")
		local ui_achieveBar = getglobal(ui_achieveState.."Bar")
		local ui_rewardPic = getglobal(ui_achieveState.."RewardBtnPic")
		local ui_redTag = getglobal(ui_achieveState.."RewardBtnRedTag")
		local ui_text = getglobal(ui_achieveState.."Text")

		if t_exhibition.isHost then
			ui_panel:Show()
		else
			ui_panel:Hide()
			return
		end

		PEC_Tools.SetUiTextSelfAdaptionWidth(ui_text,GetS(20594))

		if data then
			PEC_Tools.SetUiTextSelfAdaptionWidth(ui_achieveObtain,data.Num)
			PEC_Tools.SetUiTextSelfAdaptionWidth(ui_achieveAllNum,"/"..data.AllNum)

			local value = (data.Num - data.LastNum)/(data.AllNum-data.LastNum)
			if data.Num  == data.AllNum then value = 1 end
			if value >1 then value =1 end

			ui_achieveBar:SetWidth(value * 820)
			SetItemIcon(ui_rewardPic,data.RewardId)

			if data.NeedGetGift ==1 then
				ui_redTag:Show()
			else
				ui_redTag:Hide()
			end

			--设置奖励列表的相关值
			local uiFrame = "ExhibitionRewardFrameRewardPage"
			PEC_Tools.SetUiTextSelfAdaptionWidth(getglobal(uiFrame .. "Num"), data.Num)
			PEC_Tools.SetUiTextSelfAdaptionWidth(getglobal(uiFrame .. "AllNum"), "/"..data.AllNum)
			getglobal(uiFrame .. "Bar"):SetWidth(value * 820)
		end
	end,

	RefreshMetalItems = function (self, tableView, cell, cfgs, col, isHost, idx)
		local metal = nil
		local isUse = false
		local curUseAchieve= self.achieveMgr:GetCurUseAchieve()
		for index = 1, col do
			metal = getglobal(cell:GetName().."Metal"..tostring(index))
			isUse = false
			if cfgs[index] then
				if curUseAchieve and next(curUseAchieve) ~= nil then
					if curUseAchieve.id == cfgs[index].id then
						isUse =true
					end
				end

				self:ShowOneAchievementCell(metal:GetName(), cfgs[index], isUse)
		
				metal:SetClientID(cfgs[index].id)
				if self:IsPopViewListView(tableView) then
					self.popMedalItems[metal:GetClientID()] = metal
				else
					self.smallMedalItems[metal:GetClientID()] = metal
				end

				metal:Show()
			else
				metal:Hide()
				if self:IsPopViewListView(tableView) then
					self.popMedalItems[metal:GetClientID()] = nil
				else
					self.smallMedalItems[metal:GetClientID()] = nil
				end
			end
		end
	end,

	GetSmallAchievementRowNum = function (self, all)
		local num = 0
		if all then
			num = math.ceil(#self.allMedalDats / self.define.maxPopDlgRowMetalNum)
		else
			num = math.ceil(#self.smallMedalDats / self.define.maxRightRowMetalNum)
		end
		print("GetSmallAchievementRowNum num", num)
		return num
	end,

	IsPopViewListView = function (self, tableView)
		if not tableView  then return false end

		return self.popMedalFrameList == tableView
	end,

	-- 刷新listview
	RefreshMetals = function (self, listView, row, width, height)
		if not listView then return end

		local listWidth = width or listView:GetRealWidth2()
		local listHeight = height or listView:GetRealHeight2()
		listView:initData(listWidth, listHeight, row, 1)
		listView:setCurOffsetY(0)		
	end,

	GetAchievementRowData = function (self, datas, col, idx)
		local cfgs = {}
		if datas and col and idx then
			local startIndex = idx * col + 1
			local endIndex = startIndex + col - 1
	
			for index = startIndex, endIndex, 1 do
				cfgs[#cfgs + 1] = datas[index]
			end
		end
	
		return cfgs		
	end,

	TableCellAtIndex = function (self, tableView, idx)
		local isPopViewList = self:IsPopViewListView(tableView)
		local listData = self.smallMedalDats
		local col = self.define.maxRightRowMetalNum
		local templateName = "NewPlayerCenterMetalRowTemplate"
		if isPopViewList then
			listData = self.allMedalDats
			col = self.define.maxPopDlgRowMetalNum
			templateName = "NewPlayerCenterMetalRowTemplate2"
		end
		
		if #listData == 0 then return nil end

		local cell, index = tableView:dequeueCell(0)

		if not cell then
			local parentName = tableView:GetName()
			local cell_name = parentName .. "Cell" .. tostring(index)
			cell = UIFrameMgr:CreateFrameByTemplate("Frame", cell_name, templateName, parentName)
		else
			cell:Show()
		end

		local datas = self:GetAchievementRowData(listData, col, idx)
		self:RefreshMetalItems(tableView, cell, datas, col, t_exhibition.isHost, self.achieveMgr)

		return cell
	end,

	NumberOfCellsInTableView = function (self, tableView)
		local isPopViewList = self:IsPopViewListView(tableView)
		return self:GetSmallAchievementRowNum(isPopViewList)
	end,

	TableCellSizeForIndex = function (self, tableView, idx)
		local isPopViewList = self:IsPopViewListView(tableView)
		if isPopViewList then
			return 0, 24, 992, 304
		end

		return 0, 16, 500, 185
	end,

	TableCellWillRecycle = function (self, tableview, cell)
		if cell then 
			cell:Hide() 

			local metal = nil
			if self:IsPopViewListView(tableview) then
				for index = 1, self.define.maxPopDlgRowMetalNum do
					metal = getglobal(cell:GetName().."Metal"..tostring(index))
					self.popMedalItems[metal:GetClientID()] = nil
				end
			else
				for index = 1, self.define.maxRightRowMetalNum do
					metal = getglobal(cell:GetName().."Metal"..tostring(index))
					self.smallMedalItems[metal:GetClientID()] = nil
				end
			end
		end
	end,

	--显示成就小界面  
	ShowAchievementSmallPanel = function(self)
		self.smallMedalItems = {}
		local data = self.achieveMgr:GetAchievementPanelData()
		self.emptyFrame:Show()
		self.moreBt:Hide()

		if data and next(data)~= nil then
			local hasAchieveData, allAchieveData = self:SortAchieveData(data)
			self:ShowAchievePanelBeforeGetData()

			self:SetSmallData(hasAchieveData, allAchieveData)
			self:SetAllData(hasAchieveData, allAchieveData)

			if #self.smallMedalDats <= 0 then
				self.emptyFrame:Show()
			else
				self.emptyFrame:Hide()
			end

			if #self.allMedalDats > self.define.maxRightMetalNum and t_exhibition.isHost then
				self.moreBt:Show()
			end

			-- 刷新成就
			local rowNum = self:GetSmallAchievementRowNum(false)
			self:RefreshMetals(self.smallMedalFrameList, rowNum)
		end
	end,

	--显示家园内勋章弹框
	ShowAchievementHomePanel = function(self)
		local data = self.achieveMgr:GetAchievementPanelData()
		if data and next(data)~= nil then
			local honorFrame = self.homeMedalFrameName.."AchievementSliderCell"
			local hasAchieveData, allAchieveData = self:SortAchieveData(data)
			print("ShowAchievementHomePanel allAchieveData", allAchieveData)
			
			local achieveNum = #allAchieveData
			self:SetHomeAllAchievementLayerout(achieveNum)

			local cellName2 = ""
			for i =1, achieveNum do
				cellName2 = honorFrame..i
				self:ShowOneAchievementCell(cellName2, allAchieveData[i], false)
			end
		end
	end,

	SetHomeAllAchievementLayerout = function(self, num)
		local sliderName = self.homeMedalFrameName.."AchievementSlider"
		local planeName = sliderName.."Plane"
		if num <=0 then
			getglobal(sliderName):Hide()
		else
			getglobal(sliderName):Show()
		end

		--布局
		local x = 0
		local y = 0

		for i =1, self.maxCell do
			local ui_Cell = getglobal(sliderName.."Cell"..i)
			if i <= num then
				local row = math.ceil(i / 4)
				local cel = (i - 1) % 4 + 1

				x = 18 + (cel - 1) * 254
				y = (row - 1) * 325

				ui_Cell:Show()
				ui_Cell:SetClientID(i)
				ui_Cell:SetPoint("topleft", planeName, "topleft",  x, y)
			else
				ui_Cell:Hide()
			end
		end

		local ui_plane = getglobal(planeName)
		y = y + 325
		ui_plane:SetHeight((y > 503 and y) or 503)
	end,

	--刷新成就弹框界面
	RefreshAchievementPopPanel = function(self)		
		if self:IsPopMedalFrameShow() then
			self:ShowAchievementPopPanel()
		end
	end,

	--显示成就弹框界面
	ShowAchievementPopPanel = function(self)
		self.popMedalItems = {}		
		local isMy = t_exhibition.isHost
		local rowNum = self:GetSmallAchievementRowNum(true)
		-- 刷新成就
		local listViewH = 370
		local listBgH = 398
		if not isMy then
			listViewH = listViewH + 120
			listBgH = listBgH + 120
		end
		self:RefreshMetals(self.popMedalFrameList, rowNum, nil, listViewH)
		getglobal(self.popMedalFrameName.."MetalBg"):SetHeight(listBgH)
		getglobal(self.popMedalFrameName.."MetalBg"):SetWidth(1050)
		
		-- 成就面板
		local data = self.achieveMgr:GetAchievementPanelData()
		if data and next(data)~= nil then
			self:ShowAchievePanelBeforeGetData()
			self:ShowAchievementState(data.achieveValue)
		end

		-- title
		local titleName = getglobal(self.popMedalFrameName.."TitleName")
		titleName:SetPoint("left", titleName:GetParentFrame():GetName(), "left", 33, 0)
		titleName:SetText(GetS(20593))
		getglobal(self.popMedalFrameName.."TitleIcon"):Hide()
	end,

	-- 自己  显示6个（不管有没有获得）， 其他人只展示获得, 并且可以滑动
	SetSmallData = function(self, hasAchieveData, allAchieveData)
		-- 取前面获得的6个， 没有获得展示3个
		self.smallMedalDats = {}
		if t_exhibition.isHost then
			for index = 1, #allAchieveData do
				self.smallMedalDats[#self.smallMedalDats+1] = allAchieveData[index]
				if index == self.define.maxRightMetalNum then
					break
				end
			end
		else
			self.smallMedalDats = hasAchieveData
		end
		
		print("smallMedalDats", self.smallMedalDats)
	end,

	SetAllData = function(self, hasAchieveData, allAchieveData)
		self.allMedalDats = {}
		if t_exhibition.isHost then
			self.allMedalDats = allAchieveData
		end
		
		print("allMedalDats", self.allMedalDats)
	end,

	-- 排序成就，拥有的放在前面，之后按照时间排序
	SortAchieveData = function(self,data)
		local allAchieveData = {}

		local t_hasAchieve ={}  --拥有的成就
		local t_otherAchieve = {} --没有拥有的成就

		if data.AllAchieve then  --分类成就
			for k,v in pairs(data.AllAchieve) do
				if v.achieve_time then
					table.insert(t_hasAchieve,v)
				else
					table.insert(t_otherAchieve,v)
				end
			end
		end

		--排序成就，年度投票勋章排在前面 yearVote
		table.sort(t_hasAchieve, function (a, b) 
			local vote_list = {[1025]=true,[1026]=true,[1027]=true,[1028]=true}
			local is_a_vote = vote_list[a.id] or false
			local is_b_vote = vote_list[b.id] or false
			if is_a_vote and is_b_vote then
				return a.id < b.id
			elseif not is_a_vote and not is_b_vote then
				return a.achieve_time > b.achieve_time
			else
				return is_a_vote
			end
		end )

		for k,v in pairs(t_hasAchieve) do
			table.insert(allAchieveData,v)
		end

		for k,v in pairs(t_otherAchieve) do
			table.insert(allAchieveData,v)
		end

		return t_hasAchieve, allAchieveData
	end,

	ShowUseAchieveLabel = function(self)
		-- 勋章itemlabel
		local curUseAchieve= self.achieveMgr:GetCurUseAchieve()
		local showUseLabel = function (metalItems)
			for key, value in pairs(metalItems) do
				if value and value:IsShown() then
					if key == curUseAchieve.id then
						getglobal(value:GetName().."Label"):Show()
					else
						getglobal(value:GetName().."Label"):Hide()
					end				
				end
			end
		end

		showUseLabel(self.smallMedalItems)
		if self:IsPopMedalFrameShow() then
			showUseLabel(self.popMedalItems)
		end
	end,

	HideUseAchieveLabel= function(self)
		-- 勋章itemlabel
		local hideUseLabel = function (metalItems)
			for key, value in pairs(metalItems) do
				if value and value:IsShown() then
					getglobal(value:GetName().."Label"):Hide()
				end
			end
		end

		hideUseLabel(self.smallMedalItems)
		if self:IsPopMedalFrameShow() then
			hideUseLabel(self.popMedalItems)
		end
	end,

	-- 成就弹框是否显示
	IsPopMedalFrameShow = function(self)
		if not self.popMedalFrame then return false end

		return self.popMedalFrame:IsShown()
	end,
	
	-- 更新红点
	UpdateRedTag = function(self)
		local ui_tabRedTag = self.achieveMgr:GetLeftTabTag()
		ui_tabRedTag:Hide()

		if not t_exhibition.isHost then return end
		local data = self.achieveMgr:GetAchievementPanelData()
		if data ==nil or next(data) ==nil then return end

		-- 勋章item红点
		local hasMetalReceive = false
		local allMetalItemRedDots = {} -- [id] = true
		local smallMetalItemRedDots = {} -- [id] = true
		for key, value in pairs(data.AllAchieve) do
			if value.achieve_to_get and value.achieve_to_get == 1 then
				allMetalItemRedDots[key] = true
				hasMetalReceive = true
			end
		end

		-- 成就面板红点
		local hasPanelReceive = false
		if data.achieveValue and next(data.achieveValue)~= nil and data.achieveValue.NeedGetGift then
			--成就奖励界面
			if getglobal("ExhibitionRewardFrame"):IsShown() and self.achieveMgr.getAwardCellNum == 0 then
				data.achieveValue.NeedGetGift = 0
				self.achieveMgr.t_data.achieve_gifts_to_get = 0
			end
			hasPanelReceive = (data.achieveValue.NeedGetGift == 1)
		end

		-- 刷新勋章红点
		local showRedTag = function (metalItems, bSmall)
			for key, value in pairs(metalItems) do
				if value and value:IsShown() then
					if allMetalItemRedDots[key] then
						getglobal(value:GetName().."RedTag"):Show()
						if bSmall then
							smallMetalItemRedDots[key] = true
						end
					else
						getglobal(value:GetName().."RedTag"):Hide()
					end				
				end
			end
		end

		showRedTag(self.smallMedalItems, true)
		if self:IsPopMedalFrameShow() then
			showRedTag(self.popMedalItems, false)
		end
	
		-- tab && 头像  & 成就面板红点显示
		if hasMetalReceive or hasPanelReceive then
			self.achieveMgr:SetRedTagState(true)
		else
			self.achieveMgr:SetRedTagState(false)
		end

		-- 更多红点 （排除小布局勋章的红点）
		local hasMoreRedDot = false
		for key, value in pairs(allMetalItemRedDots) do
			if not smallMetalItemRedDots[key] then
				hasMoreRedDot = true
				break
			end
		end

		if self.moreBt and self.moreBt:IsShown() then
			if hasMoreRedDot or hasPanelReceive then
				getglobal(self.moreBt:GetName().."RedTag"):Show()
			else
				getglobal(self.moreBt:GetName().."RedTag"):Hide()
			end
		end

		print("allMetalItemRedDots", allMetalItemRedDots)
		print("smallMetalItemRedDots", smallMetalItemRedDots)
	end,

	--默认没有加载到数据的时候需要做的显示处理
	HideAchievePanelBeforeGetData = function(self)
	end,

	--加载到数据的时候需要做的显示预处理
	ShowAchievePanelBeforeGetData = function(self)
		--加保护，在加载数据时候切换到其他的界面，数据加载完成也不再显示
		if t_ExhibitionCenter.curSelectTabID ~= t_ExhibitionCenter.define.tabHome then
			return
		end
	end,

}

--成就奖励界面
PEC_ExhibitionRewardPanel= {
	achieveMgr = nil,
	panelName = nil,

	maxCellNum = 20,

	OnLoad = function(self)
		self.panelName = PEC_ExhibitionRewardPanel;
		self.achieveMgr = UIAchievementMgr;
		self:OnRegisterEvent();

	end,

	OnRegisterEvent = function(self)
		self.achieveMgr:RegisterEvent(AchievementDefine.ShowAchieveRewardPanel,self.panelName);
		self.achieveMgr:RegisterEvent(AchievementDefine.ObtainAchieveRewardSuccess,self.panelName);
	end,

	OnEvent = function(self,eventName,data)
		if eventName == AchievementDefine.ShowAchieveRewardPanel then
			self:ShowAchieveRewardPanel();
		elseif  eventName == AchievementDefine.ObtainAchieveRewardSuccess then
			self:ObtainAchieveSuccess(data);
		end
	end,

	----------------------------------------------------------------------------------------------------

	--显示单个奖励选项的内容
	ShowOneRewardCell = function(self,uiIndex,data)
		local cellName = "ExhibitionReward";
		local ui_cell = getglobal(cellName..uiIndex);
		local ui_achieveNum = getglobal(cellName..uiIndex.."Title");
		local ui_RewardName = getglobal(cellName..uiIndex.."IconBtnName");
		local ui_icon = getglobal(cellName..uiIndex.."IconBtnIcon");
		local ui_btn = getglobal(cellName..uiIndex.."GetBtn");
		local ui_btnName = getglobal(cellName..uiIndex.."GetBtnName")
		local ui_btnNormal = getglobal(cellName..uiIndex.."GetBtnNormal")
		local ui_btnPushed = getglobal(cellName..uiIndex.."GetBtnPushedBG")
		local ui_bg = getglobal(cellName..uiIndex.."Bkg");


		if data and next(data) ~= nil then
			ui_achieveNum:SetText(data.achieve);
            local itemDef = ItemDefCsv:get(data.id);
            if itemDef then
                -- ui_RewardName:SetText(itemDef.Name.." x "..data.num);
                ui_RewardName:SetText(" x "..data.num);
            end

			--ui_cell:SetClientUserData(uiIndex,data.code);
			ui_btn:SetClientUserData(0,uiIndex);
			ui_btn:SetClientUserData(1,data.code);
			ui_btn:SetClientUserData(2,data.id);
			ui_btn:SetClientUserData(3,data.num);
			SetItemIcon(ui_icon, data.id);
		end

		--设置按钮显示
		ui_btn:Disable();
		if data.stat == 0 then --未完成
			ui_btnNormal:SetGray(true);
			ui_btnName:SetText(GetS(20605))
		elseif data.stat==1 then --已完成未领取
			ui_btnNormal:SetGray(false);
			ui_btnName:SetText(GetS(3028))
			ui_btn:Enable();
		elseif data.stat==2 then --已领取
			ui_btnName:SetText(GetS(3029))
			ui_btnNormal:SetGray(true);

		end

	end,

	--显示所有的奖励以及布局
	SetAchieveRewardLayerout = function(self,num)
		if num > self.maxCellNum then  num = self.maxCellNum end
		local cellName = "ExhibitionReward";
		local ui_plane = getglobal("ExhibitionRewardBoxPlane");

		for i = 1,self.maxCellNum do
			local ui_cell = getglobal(cellName..i);
			if i<=num then
				ui_cell:Show();
				ui_cell:SetPoint("left", "ExhibitionRewardBoxPlane", "left", (i - 1) * 182, 0);
			else
				ui_cell:Hide();
			end
		end

		if num > 4 then
			ui_plane:SetWidth(182 * num);
		else
			ui_plane:SetWidth(970);
		end

	end,

	--显示成就奖励面板
	ShowAchieveRewardPanel = function(self)
		local data = self.achieveMgr:GetAchieveRewardData();
		local rewardList = data.rewardList;

		local uiName = "ExhibitionRewardFrameRewardPage";
		if next(data) ~= nil and next(rewardList)~= nil then
			getglobal("ExhibitionRewardFrameRewardPage"):Show();
			local num = #rewardList;
			self:SetAchieveRewardLayerout(num);
			self.achieveMgr.getAwardCellNum = 0
			for i=1 ,num do
				self:ShowOneRewardCell(i,rewardList[i]);
				if rewardList[i].stat and rewardList[i].stat == 1 then
					self.achieveMgr.getAwardCellNum = self.achieveMgr.getAwardCellNum + 1
				end
			end
		else
			getglobal("ExhibitionRewardFrameRewardPage"):Hide();
		end

		getglobal("ExhibitionRewardFrame"):Show();
	end,

	--获取成就奖励成功回调显示
	ObtainAchieveSuccess = function(self,data)
		local reward_data = self.achieveMgr:GetAchieveRewardData();
		local rewardList = reward_data.rewardList;

		for k,v in pairs(rewardList) do
			if v.code == data.code then
				v.stat = 2;
			end
		end

		local t_reward = {};
		table.insert(t_reward,data);

		SetGameRewardFrameInfo(GetS(20604), t_reward, "");

		local cellName = "ExhibitionReward";
		local uiIndex = data.uiIndex;
		local ui_btn = getglobal(cellName..uiIndex.."GetBtn");
		local ui_btnName = getglobal(cellName..uiIndex.."GetBtnName")
		local ui_btnNormal = getglobal(cellName..uiIndex.."GetBtnNormal")

		ui_btn:Disable();
		ui_btnNormal:SetGray(true);
		ui_btnName:SetText(GetS(3029))
		self.achieveMgr.getAwardCellNum = self.achieveMgr.getAwardCellNum - 1
	end,

}

--成就获取界面
PEC_AchieveSuccessPanel= {
	achieveMgr = nil,
	panelName = nil,

	curSelectLevel = 0, -- 当前选中的勋章等级
	curAchievedLevel = 0, -- 玩家已完成的进度
	curUIName = "",
	achieveData = {};
	achieveName = "";
	achieveId = 1;
	achieveFinished = 0; --当前完成的成就点数

	curSelectIndex = 1; -- 选项卡显示的第一个索引，achieveData的索引值

	OnLoad = function(self)
		self.panelName = PEC_AchieveSuccessPanel;
		self.achieveMgr = UIAchievementMgr;
		self:OnRegisterEvent();

	end,

	OnRegisterEvent = function(self)
		self.achieveMgr:RegisterEvent(AchievementDefine.ShowAchieveSuccessPanel,self.panelName);
		self.achieveMgr:RegisterEvent(AchievementDefine.SelectAchievelevelCell,self.panelName);
		self.achieveMgr:RegisterEvent(AchievementDefine.SetUseAchieveSuccess,self.panelName);
		self.achieveMgr:RegisterEvent(AchievementDefine.CancelUseAchieve,self.panelName);
	end,

	OnEvent = function(self,eventName,data)
		if eventName == AchievementDefine.ShowAchieveSuccessPanel then
			self:ShowSuccessPanel(data);
			getglobal("ExhibitionAchieveSuccessFrame"):Show();
			standReportEvent("7", "MEDAL_REWARD_POPUP", "-", "view")
		elseif eventName== AchievementDefine.SelectAchievelevelCell then
			self:SetSelectLevelCellState(data);
		elseif eventName== AchievementDefine.SetUseAchieveSuccess then
			self:SetAchieveLevelLabel(data);
		elseif eventName== AchievementDefine.CancelUseAchieve then
			self:CancelUseAchieveLabel();
		end
	end,

	OnReset = function(self)
		self.curSelectLevel = 0;
		self.curSelectIndex = 1;
		self.curAchievedLevel = 0;
		self.achieveData = {};
		self.achieveName = "";
		self.achieveId = 1;
		self.curUIName = "";
		self.achieveFinished = 0;
	end,
-----------------------------------------------------------------------------------------------------------
	--初始化显示成就详细信息的面板
	ShowSuccessPanel = function(self,id)
		local planeName = "ExhibitionAchieveSuccessFrame";
		local ui_Text = getglobal(planeName.."TitleText");

		if id ~= self.achieveId then
			self:OnReset();
		end

		--获取当前勋章的信息并保存下来
		local t_data = self.achieveMgr:GetAchieveDetailById(id);
		if t_data ==nil or (t_data and next(t_data) ==nil)  then return end
		self.achieveId = id;
		self.achieveData = t_data.data;

		self.achieveName = t_data.achieveName;
		self.achieveFinished = t_data.finished;
		ui_Text:SetText(GetS(self.achieveName));

		--显示最高等级选中状态
		local maxUnlockIndex = self:GetAchieveMaxUnlockIndex();
		local levelNum = #self.achieveData;
		if maxUnlockIndex <= 0 then
			maxUnlockIndex = 1
		end
		self.curAchievedLevel = self.achieveData[maxUnlockIndex].level;

		local data = { level =self.curAchievedLevel }
		self.curSelectIndex = maxUnlockIndex;
		self:SetSelectLevelCellState(data);

		--设置界面的进度
		self:ShowObtainAchieveProgress(levelNum,maxUnlockIndex)
		self:ShowAllAchieveCell();
	end,

	--获取当前解锁的最大索引值
	GetAchieveMaxUnlockIndex = function(self)
		local maxUnlockIndex = -1;
		local levelNum = #self.achieveData;
		for i =1 ,levelNum do
			if self.achieveData[i].time and self.achieveData[i].stat == 2 then
				maxUnlockIndex =i;
			end
		end
		return maxUnlockIndex
	end,

	--显示获取勋章进度ui
	ShowObtainAchieveProgress = function(self,levelNum,unlockIndex)
		local planeName = "ExhibitionAchieveSuccessFrame";

		print("level num ",levelNum)
		-- 计算进度条长度
		local ui_Progress 			= 		getglobal(planeName.."Progress");
		local ui_AchievedProgress 	= 		getglobal(planeName.."AchievedProgress");
		local unitProgress 			= 		getglobal("ExhibitionAchievements1"):GetWidth(); -- 一个等级对应的长度
		local maxProgress = unitProgress * (levelNum - 1);
		local curProgress = 0.1;
		if unlockIndex > 0 then
			local curLevelNum = self.achieveData[unlockIndex].target or 0;
			local nextLevelNum = self.achieveData[unlockIndex + 1] and self.achieveData[unlockIndex + 1].target or 99999;
			local finishLevelNum = self.achieveData[unlockIndex].level - self.achieveData[1].level

			maxProgress = unitProgress * (levelNum - 1.35); 			-- 背景长度，含减去的被左右两端的勋章覆盖的长度
			curProgress = finishLevelNum * unitProgress - unitProgress * 0.35
					+ (self.achieveFinished - curLevelNum) / (nextLevelNum - curLevelNum) * unitProgress; -- 分段计算比例
		end

		if curProgress <= 0 then curProgress = 1 end
		if maxProgress <= 0 then maxProgress = 1 end
		ui_Progress:SetWidth(maxProgress);
		ui_AchievedProgress:SetWidth(curProgress);
	end,

	--点击选中勋章展示信息
	OnChangeShowAchieveCell = function(self, data)
		print("OnChangeShowAchieveCell(): ");
		if not data or not next(data) then return end

		local level = data.level;
		if not level then return end

		self:SetSelectLevelCellState(data);
	end,

	--通过等级获取索引值，有的勋章只有三个等级，等级起始为3，需要的所索引值为1
	GetAchieveLevelIndexByLevel = function(self, level)
		local achieveData = self.achieveData;

		if not achieveData or not next(achieveData) then return end
		for i=1, #achieveData do 
			if achieveData[i].level == level then return i end
		end

	end,

	--显示当前勋章所有的等级图标和布局
	ShowAllAchieveCell = function(self)
		if  self.achieveData ==nil or self.achieveData =={} then return end

		local levelNum = #self.achieveData;					--总共多少个等级

		--显示所有成就图标
		for i = 1, levelNum do
			self:ShowOneDetailCellInfo(i, self.achieveData[i]);
		end

		--根据数量，重新布局勋章位置
		LayoutManagerFactory:newHorizontalSplitLayoutManager()
							:setPoint("top")
							:setRelativeTo("ExhibitionAchieveSuccessFrameTitleText")
							:setRelativePoint("bottom")
							:setBoxItemNamePrefix("ExhibitionAchievements")
							:setOffsetY(29)
							:layoutAll(levelNum, 5)
							:recycle()
		local tempNum = levelNum
		if tempNum%2 ~= 0 then
			tempNum = tempNum + 1
		end
		tempNum = tempNum / 2
		local centerInfo = getglobal("ExhibitionAchieveSuccessFrameCenterInfo")
		if centerInfo then
			centerInfo:SetPoint("top", "ExhibitionAchievements"..tempNum, "bottom", 0, 6)
		end
	end,

	--显示单个成就图标
	ShowOneDetailCellInfo = function(self, uiIndex, data)
		local detailPanelName = "ExhibitionAchievements";
		local ui_detailPanel = getglobal(detailPanelName..uiIndex);
		local ui_achieveBtn = getglobal(detailPanelName..uiIndex.."AchievementBtn")

		local ui_iconBtn = getglobal(detailPanelName..uiIndex.."AchievementBtn".."Icon");
		local ui_frameBtn = getglobal(detailPanelName..uiIndex.."AchievementBtn".."Frame");
		local ui_noneBtn = getglobal(detailPanelName..uiIndex.."AchievementBtn".."None");
		local ui_EffectBtn = getglobal(detailPanelName..uiIndex.."AchievementBtn".."Mask");


		local icon_Res = self.achieveMgr:GetIconResources(self.achieveId);
		local frame_Res = self.achieveMgr:GetFrameResources(data.level);

		ui_detailPanel:SetClientID(data.level);

		ui_iconBtn:Show();
		ui_frameBtn:Show();

		if icon_Res and icon_Res.icon_name then
			ui_iconBtn:SetTextureHuiresXml( "ui/mobile/texture/uitachieve.xml" );
			ui_iconBtn:SetTexUV(icon_Res.icon_name..".png");
		end
		
		ui_frameBtn:SetTextureHuiresXml( "ui/mobile/texture/uitachieve.xml" );
		ui_frameBtn:SetTexUV(frame_Res..".png");

		if self.curSelectIndex == uiIndex then
			ui_achieveBtn:SetSize(220, 220);
		else
			ui_achieveBtn:SetSize(106, 107);
		end

		ui_EffectBtn:Hide();
		if data.time and data.stat == 2 then

			ui_noneBtn:Hide();

			ui_frameBtn:SetGray(false);
			ui_iconBtn:SetGray(false);

			if data.level ==4 then
				ui_EffectBtn:Show();
				ui_EffectBtn:SetTexture("ui/mobile/effect/ico_medalf_4.png");
				ui_EffectBtn:SetUVAnimation(100, true);
			elseif data.level ==5 then
				ui_EffectBtn:Show();
				ui_EffectBtn:SetTexture("ui/mobile/effect/ico_medalf_5.png");
				ui_EffectBtn:SetUVAnimation(100, true);
			end
		else

			ui_frameBtn:SetGray(true);
			ui_iconBtn:SetGray(true);
			ui_noneBtn:Hide();
		end
	end,

	--当前成就点击
	SetSelectLevelCellState = function(self,data)
		print("SetSelectLevelCellState:");
		if data and next(data) == nil  then return; end

		local planeName = "ExhibitionAchieveSuccessFrameCenterInfo";

		local ui_CenterInfo = 	getglobal(planeName);
		local ui_FinishedTime = getglobal(planeName .. "FinishedTime");
		local ui_NeedNum = 		getglobal(planeName .. "NeedNum");
		local ui_AddNum = 		getglobal(planeName .. "AddNum");
		local ui_UseBtn = 		getglobal(planeName .. "SetBtn");
		local ui_UseBtnText = 	getglobal(planeName .. "SetBtn".."Name");
		local ui_UpgradeNum = 	getglobal(planeName .. "UpgradeNum");
		local ui_HomelandHFSetBtn = getglobal(planeName .. "HomelandHonorframeSet")
		local ui_HomelandHFSetBtnText = getglobal(planeName .. "HomelandHonorframeSetName")

		local level = data.level;
		self.curSelectLevel = level;

		local index = self:GetAchieveLevelIndexByLevel(level);
		if not index then return end
		self.curSelectIndex = index

		local curAchieve ={};
		for k,v in pairs(self.achieveData) do
			if v.level == level then
				curAchieve = v;
			end
		end

		local finishedNum = self.achieveFinished;			--已完成的数量
		ui_CenterInfo:SetClientID(curAchieve.level);

		--1. 完成的时间
		ui_FinishedTime:Hide();
		if curAchieve.time and curAchieve.stat == 2 then
			local TimeText = GetS(20600, self.achieveMgr:GetTimeStamp(curAchieve.time));
			ui_FinishedTime:Show();
			ui_FinishedTime:SetText(TimeText);
		end

		--3. 达成条件
		local icon_Res = self.achieveMgr:GetIconResources(self.achieveId);
		if icon_Res and icon_Res.describe then
			ui_NeedNum:SetText(GetS(icon_Res.describe, "#cff8920" .. curAchieve.target));	--"好友数量达到60"
		end


		--2. 勋章值
		ui_AddNum:SetText(GetS(20594) .. "#cff8920" .. curAchieve.add_achieve .."#n");

		--计算当前解锁的等级和最高等级
		local unlockLevel = 0;		--当前解锁的最高等级
		local mostLevel = 0;		--最高等级
		local nextLevel = self.curSelectLevel + 1;	--下一级
		local nextLevelNum = 0;		--下一级对应的数

		for i = 1, #(self.achieveData) do
			local node = self.achieveData[i];

			if node.time and node.stat == 2 then
				--已解锁
				if node.level > unlockLevel then
					unlockLevel = node.level;
				end
			end

			if node.level > mostLevel then
				mostLevel = node.level;
			end

			if nextLevel == node.level then
				nextLevelNum = node.target;
			end
		end

		--3. 距离升级还需
		if self.curSelectLevel == unlockLevel then
			ui_UpgradeNum:Show();
			if unlockLevel < mostLevel then
				--离升级还差...
				ui_UpgradeNum:SetText(GetS(20649, "#cff8920" .. nextLevelNum - finishedNum));
			else
				--已经是最高级
				ui_UpgradeNum:SetText(GetS(20650));
			end
		else
			ui_UpgradeNum:Hide();
		end

		ui_HomelandHFSetBtn:Hide()
		local useAchieve = self.achieveMgr:GetCurUseAchieve();
		if not getglobal(t_exhibition:getUiName()):IsShown() then
			ui_UseBtn:Hide()
			if getglobal("BlockSetHonorFrame"):IsShown() then
				if useAchieve and next(useAchieve) ==nil then
					--目标未达成
					ui_HomelandHFSetBtn:Hide()
				elseif curAchieve.stat ~= 2 then
					ui_HomelandHFSetBtn:Hide()
				else
					ui_HomelandHFSetBtn:Show()
					local achieveData = GetInst("UIManager"):GetCtrl("BlockSetHonorFrame"):GetCurSelectAchieve()
					if achieveData.id == self.achieveId and achieveData.level == curAchieve.level then
						ui_HomelandHFSetBtnText:SetText(GetS(20134))
					else
						ui_HomelandHFSetBtnText:SetText(GetS(41372))
					end
				end
			end
		elseif useAchieve and next(useAchieve) ==nil then
			--没有当前使用的成就
			ui_UseBtn:Hide();
		elseif useAchieve and next(useAchieve) ~=nil and useAchieve.level ==level and self.achieveId ==useAchieve.id then
			--7302:取消
			ui_UseBtn:Show();
			ui_UseBtnText:SetText(GetS(7302))
		elseif curAchieve.time and curAchieve.stat ==2 then
			--20595:佩戴
			ui_UseBtn:Show();
			ui_UseBtnText:SetText(GetS(20595))
		elseif curAchieve.target > finishedNum  then
			--目标未达成
			ui_UseBtn:Hide();
		end

		--设置勋章的大小
		for i = 1, 5 do
			local ui_CellBtn = getglobal("ExhibitionAchievements" .. i .. "AchievementBtn");
			if i == self.curSelectIndex then
				ui_CellBtn:SetSize(220, 220);
			else
				ui_CellBtn:SetSize(107, 106);
			end
		end
	end,

	--设置面板的label属性
	SetAchieveLevelLabel = function (self,data)
		--点击佩戴后
		self:SetSelectLevelCellState(data);
	end,

	--取消显示使用标签
	CancelUseAchieveLabel = function(self)
		--点击取消使用
		local data = {level = self.curSelectLevel}
		self:SetSelectLevelCellState(data);
	end,
}

--领取勋章成功展示界面
PEC_ObtainAchieveRewardPanel={
	achieveMgr = nil,
	panelName = nil,

	needShowList = {}, --所以需要显示的勋章集合
	currExhibitData = {};

	OnLoad = function(self)
		self.panelName = PEC_ObtainAchieveRewardPanel;
		self.achieveMgr = UIAchievementMgr;
		self:OnRegisterEvent();

	end,

	OnRegisterEvent = function(self)
		self.achieveMgr:RegisterEvent(AchievementDefine.ShowObtainAchieveRewardPanel,self.panelName);
		self.achieveMgr:RegisterEvent(AchievementDefine.SetNeedExhibitAchieveData,self.panelName);
		self.achieveMgr:RegisterEvent(AchievementDefine.ExhibitPanelUseAchieve,self.panelName);
	end,

	OnEvent = function(self,eventName,data)
		if eventName == AchievementDefine.ShowObtainAchieveRewardPanel then
			self:JudgeAndShowExhibitAchieve()
		elseif eventName == AchievementDefine.SetNeedExhibitAchieveData then
			self:SetNeedExhibitData(data);
		elseif eventName == AchievementDefine.ExhibitPanelUseAchieve then
			self:UseCurrAchieve();
		end
	end,

	----------------------------------------------------------------------------------------------------

	--设置界面显示的一些参数  --data.id   --data.level   --data.time   --data.title
	ShowObtainAchieveRewardPanel = function(self,data)
		self.currExhibitData = data;

		local uiName = "ObtainAchieveRewardFrame";
		local ui_view 		= getglobal(uiName.."View");
		local ui_Title 		= getglobal(uiName.."Title");
		local ui_name 		= getglobal(uiName.."Name");
		local ui_icon 		= getglobal(uiName.."Icon");
		local ui_frame 		= getglobal(uiName.."Frame");
		local ui_effect 	= getglobal(uiName.."Effect1");
		local ui_effect1 	= getglobal(uiName.."Mask");
		local ui_shareBtn 	= getglobal(uiName.."ShareBtn");
		local ui_titleBkg 	= getglobal(uiName.."TitleBkg");
		local ui_RewardPanel = getglobal(uiName );

		local icon_Res = self.achieveMgr:GetIconResources(data.id);
		local frame_Res = self.achieveMgr:GetFrameResources(data.level);

		ui_shareBtn:SetClientUserData(0,data.id);
		ui_shareBtn:SetClientUserData(1,data.level);
		ui_shareBtn:SetClientUserData(2,data.title);
		ui_shareBtn:SetClientUserData(3,data.target);



		ui_effect1:Hide();
		if data.level ==4 then
			ui_effect1:Show();
			ui_effect1:SetTexture("ui/mobile/effect/ico_medalf_4.png");
			ui_effect1:SetUVAnimation(100, true);
		elseif data.level ==5 then
			ui_effect1:Show();
			ui_effect1:SetTexture("ui/mobile/effect/ico_medalf_5.png");
			ui_effect1:SetUVAnimation(100, true);
		end


		local width = PEC_Tools.SetUiTextSelfAdaptionWidth(ui_Title,GetS(20597))
		if width >450 then
			ui_titleBkg:SetWidth(width+10);
		end

		PEC_Tools.SetUiTextSelfAdaptionWidth(ui_name,GetS(data.title))

		if icon_Res and icon_Res.icon_name then
			ui_icon:SetTextureHuiresXml( "ui/mobile/texture/uitachieve.xml" );
			ui_icon:SetTexUV(icon_Res.icon_name..".png");
		end
		
		ui_frame:SetTextureHuiresXml( "ui/mobile/texture/uitachieve.xml" );
		ui_frame:SetTexUV(frame_Res..".png");

		ui_view:playActorAnim(100108,0);
		ui_view:stopEffect(1038, 0);
		ui_view:addBackgroundEffect("particles/shop_unlock.ent", 0, 80, 150);
		ClientMgr:playSound2D("sounds/ui/info/shop_unlock.ogg", 1);

		ui_effect:SetUVAnimation(100, false);
		ui_RewardPanel:Show();

	end,

	--保存到需要展示的数据
	SetNeedExhibitData = function(self,data)
		if  data ==nil or next(data) == nil then return end

		for k,v in pairs(data) do
			table.insert(self.needShowList,1,v);
		end

		local num = #self.needShowList;
		for i =1 ,num do
			for j=1,num-i do
				if self.needShowList[j].level> self.needShowList[j+1].level then
					local temp = self.needShowList[j];
					self.needShowList[j] = self.needShowList[j+1];
					self.needShowList[j+1] = temp;
				end
			end
		end
	end,

	--从自身保存的数据中判断是否有需要展示的，并展示
	JudgeAndShowExhibitAchieve = function(self)
		if self.needShowList  and next(self.needShowList) ~= nil then
			local data = self.needShowList[1];
			self:ShowObtainAchieveRewardPanel(data);
			table.remove(self.needShowList,1);
		end
	end,

	--获取是否还有需要展示的数据
	GetNeedExhibitDataNum = function(self)
		if self.needShowList and next(self.needShowList) ~= nil then
			return #self.needShowList;
		else
			self.currExhibitData = {};
			return 0;
		end

	end,

	--使用成就勋章
	UseCurrAchieve = function(self)
		local data = self.currExhibitData;

		if data and next(data)~= nil then
			self.achieveMgr:ReqUseAchieve(data.level,data.id);
		else
			ShowGameTips( "使用成就勋章失败", 3 );
		end
	end,

}

--成就分享界面
PEC_ShareAchievePanel = {
	achieveMgr = nil,
	panelName = nil,

	OnLoad = function(self)
		self.panelName = PEC_ShareAchievePanel;
		self.achieveMgr = UIAchievementMgr;
		self:OnRegisterEvent();
	end,

	OnRegisterEvent = function(self)
		self.achieveMgr:RegisterEvent(AchievementDefine.StartSnapshotForAchieveShare,self.panelName);
		self.achieveMgr:RegisterEvent(AchievementDefine.EndSnapshotForAchieveShare,self.panelName);
	end,

	OnEvent = function(self,eventName,data)
		if eventName == AchievementDefine.StartSnapshotForAchieveShare then
			self:SetShareParameter(data);
			self:OnShowShareInfo(data);--先设置参数，然后开始截图
		elseif eventName == AchievementDefine.EndSnapshotForAchieveShare then
			self:SetSnapshotSuccessState();  --截图并保存图片到本地完成，打开分享按钮界面
		end
	end,

	-----------------------------------------------------------------------------------------------------
	--设置分享界面的显示
	OnShowShareInfo = function(self,data)
		local uiName = "ExhibitionAchieveShareFrame";
		local ui_Icon = getglobal(uiName.."Icon");
		local ui_Frame = getglobal(uiName.."Frame");
		local ui_AchieveName = getglobal(uiName.."AchieveName");
		local ui_AchieveDescribe = getglobal(uiName.."AchieveDescribe");
		local ui_AuthorName = getglobal(uiName.."RoleInfoAuthorName");
		local ui_panel = getglobal(uiName);

		if (ClientMgr:getGameData("fpsbuttom")) == 1 then  				--判断游戏设置是否显示fps
			DebugMgr:setRenderInfoFPS(true);
			PECFpsShow = true;
		end
		local icon_Res = self.achieveMgr:GetIconResources(data.id);
		local frame_Res = self.achieveMgr:GetFrameResources(data.level);

		if icon_Res and icon_Res.icon_name then
			ui_Icon:SetTextureHuiresXml( "ui/mobile/texture/uitachieve.xml" );
			ui_Icon:SetTexUV(icon_Res.icon_name..".png");
		end

		local desc = ""
		if icon_Res and icon_Res.icon_name then
			desc = GetS(20607)..GetS(icon_Res.describe,data.target)
		end
		
		ui_AchieveDescribe:SetText(desc);
		ui_AchieveName:SetText(GetS(data.title));

		ui_Frame:SetTextureHuiresXml( "ui/mobile/texture/uitachieve.xml" );
		ui_Frame:SetTexUV(frame_Res..".png");

		ui_AuthorName:SetText("@"..GetS(1254, AccountManager:getNickName(), GetMyUin()));
		ui_panel:Show(); 													--界面显示

		self:SetQRCodeState(); --设置二维码是否显示

		SnapshotForShare:requestSaveSnapshot();
		threadpool:wait(0.5);

	end,

	--设置一些分享的参数
	SetShareParameter = function(self,data)
		SetShareScene("Achieve");
		local url = GetBaseShareUrl() .. "&type=Achieve" ; 					--深度链接
		local content = "快看呀！这是我新解锁的成就勋章";
		SetShareData("", url, "", content);

		local tShareParams = {};									--游戏内好友分享参数设置
		tShareParams.shareType = t_share_data.ShareType.ACHIEVE;
		tShareParams.id = data.id;
		tShareParams.level = data.level;
		tShareParams.title = data.title;
		t_share_data:SetMiniShareParameters(tShareParams);

		ShareToDynamic:SetActionParameter(); 								--设置游戏内动态分享的跳转参数

	end,

	--设置二维码是否显示
	SetQRCodeState = function(self)
		local uiName = "ExhibitionAchieveShareFrame";

		if not check_apiid_ver_conditions(ns_version.qq_share.show_QR_code) then
			getglobal(uiName.."RoleInfoQRCode"):Hide();
		end
		if getglobal(uiName.."RoleInfoQRCode"):IsShown() then
			getglobal(uiName.."RoleInfoLogo"):SetPoint("right","ExhibitionAchieveShareFrameRoleInfoQRCode","right",-130,-17);
		else
			getglobal(uiName.."RoleInfoLogo"):SetPoint("topright",uiName,"topright",-5,0);
		end
	end,

	--截图完成的处理
	SetSnapshotSuccessState = function(self)

		if PECFpsShow then
			DebugMgr:setRenderInfoFPS(false);
			PECFpsShow = false;
		end

		-- 海外版google分享时图片不能重名
		local svrtime = '';
		if IsAndroidBlockark() then
			svrtime = AccountManager:getSvrTime();
		end

		--设置截图路径
		local filepath = "SnapshotForShare"..svrtime..".png"
		MiniwShareEx(filepath)
	end,



}

-- 数据类
AchievementData = {
	achieveMgr = nil,
	total_achieve= 0; -- 总的成就值
	task_size = 0; -- 总的成就数
	prize = {}; -- 成就值阶段
	used_achieve ={}; -- 当前使用的成就
	next_achieve_target=0;
	achieve_gifts_to_get = 0, -- 1有未领取奖励，0是没有需要领取的奖励
	allAchieveData = {};-- 所有的成就数据，包括已经获取到的
	-------------------------------------------------------------
	curMaxAchieveValue = 0; --当前成就等级的最大成就值
	-------------------------------------------------------------
	achieveDetail = {};  --所有成就详细列表

	rewardList = {}; --所有奖励的列表

	--------------------------------------------------------------
	incrementList = {}; --增量数据列表

	--------------------------------------------------------------
	icon_Resources = {}; --成就的图标列表
	frame_Resources = {}; --成就品质图标

	temp = nil; --临时的透传参数，使用完记得清空

	Init = function(self)
		self.achieveMgr = UIAchievementMgr;
		self:ReqAllAchieveInfo() --初始化所有要显示的数据
		self:InitAchieveResources();
	end,

	Reset = function(self)
		self.achieveMgr = nil;
		------------------------------------------------------------------
		self.task_size = 0; -- 总的成就数
		self.prize = {}; -- 成就值阶段
		self.used_achieve ={}; -- 当前使用的成就
		self.allAchieveData = {};-- 所有的成就数据，包括已经获取到的
		-------------------------------------------------------------
		self.curMaxAchieveValue = 0; --当前成就等级的最大成就值
		-------------------------------------------------------------
		self.achieveDetail = {};  --所有成就详细列表

		self.rewardList = {}; --所有奖励的列表
		--------------------------------------------------------------
		self.incrementList = {}; --增量数据列表

		self.temp = nil; --临时的透传参数，使用完记得清空
	end,

	--获取成就的基本信息，初始化执行一次
	ReqAllAchieveInfo = function(self)
		if self.achieveMgr.AchievementShow then
			local uin = t_exhibition.uin;
			local url_ =  g_http_common..'/miniw/achieve?act=query_all_achieve_task&op_uin='..uin..'&' .. http_getS1();
			Log( url_ );
			ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:ReqAllAchieveInfo");
			local seq = gen_gid()
			ns_http.func.rpc( url_,  function (ret) threadpool:notify(seq, ErrorCode.OK, ret) self.RespAllAchieveInfo(ret)end, { callback=ext_callback }, nil, true );
			local timeout = 10  --timeout or config and config.timeout or 10
			local code, http_result = threadpool:wait(seq, timeout, tick)
		end
	end,

	RespAllAchieveInfo = function(ret)
		print("AchievementData.RespAllAchieveInfo()",ret);
		ShowLoadLoopFrame(false)
		if ret  then
			if ret.ret ==0 then
				AchievementData.total_achieve = ret.total_achieve or 0; -- 总的成就值
				AchievementData.task_size = ret.task_size or 0;
				AchievementData.prize = ret.prize or {};
				AchievementData.used_achieve = ret.used_achieve or {};
				AchievementData.allAchieveData = ret.data or {};
				AchievementData.next_achieve_target = ret.next_achieve_target or 0;
				AchievementData.achieve_gifts_to_get = ret.achieve_gifts_to_get or 0;

				if AchievementData.prize then
					AchievementData:SetCurAchieveLevel();
				end

				AchievementData.achieveMgr:NotifyEvent(AchievementDefine.ShowAchievementPanel);
				
				IsAchieveNeedInit = false
				return
			else
				ShowGameTips( "成就获取失败", 3 );
			end
		end
		IsAchieveNeedInit = true
	end,

	--获取成就奖励信息
	ReqAchieveRewardList =function (self)
		if self.achieveMgr.AchievementShow then

			local  now_ = os.time();
			local  uin_ = AccountManager:getUin() or get_default_uin()
			local  spliceStr= http_getS1();

			local uin = t_exhibition.uin;
			local url_ =  g_http_common..'/miniw/achieve?act=get_achieve_task_reward&op_uin='..uin..'&' .. spliceStr;
			Log( url_ );
			ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:ReqAchieveRewardList");
			ns_http.func.rpc( url_, self.RespAchieveRewardList, { callback=ext_callback }, nil, true );
		end
	end,

	RespAchieveRewardList = function(ret)
		print("AchievementData.ResqAchieveRewardList()",ret);
		ShowLoadLoopFrame(false)
		if ret and ret.ret ==0 then
			AchievementData.rewardList = ret.data or {};
			UIAchievementMgr:NotifyEvent(AchievementDefine.ShowAchieveRewardPanel);
		else
			ShowGameTips( "获取奖励列表失败", 3 );
		end
	end,

	--获取当前成就的具体等级信息
	ReqCurAchieveLevelList = function(self,temp)
		if self.achieveMgr.AchievementShow then
			local uin = t_exhibition.uin;
			local url_ =  g_http_common..'/miniw/achieve?act=query_achieve_task&op_uin='..uin..'&' .. http_getS1();
			Log( url_ );
			self.temp =temp;
			ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:ReqCurAchieveLevelList");
			ns_http.func.rpc( url_, self.RespCurAchieveLevelList, { callback=ext_callback }, nil, true );
		end
	end,

	RespCurAchieveLevelList = function(ret)
		print("AchievementData.RespCurAchieveLevelList()",ret);
		ShowLoadLoopFrame(false)
		if ret and ret.ret == 0 then
			AchievementData.achieveDetail = ret.data or {};
			if AchievementData.temp ~=nil then
				UIAchievementMgr:ObtainedAchieveDetailCallBack(AchievementData.temp);
			end
			AchievementData.temp=nil;
		else
			ShowGameTips( "成就详细信息列表显示失败", 3 );
		end
	end,

	GetTotalAchieve = function(self)
		return self.total_achieve;
	end,

	--获取当前成就等级的成就最大值
	SetCurAchieveLevel = function(self)
		local isInit = false;
		local curMaxValue = self:GetTotalAchieve();
		for k,v in pairs(self.prize) do
			if v> self:GetTotalAchieve() and v < curMaxValue then
				curMaxValue =v;
			elseif v > self:GetTotalAchieve()  and isInit ==false then
				curMaxValue =v;
				isInit = true;
			end
		end
		self.curMaxAchieveValue = curMaxValue;
		return curMaxValue;
	end,

	InitAchieveResources = function(self)
		self.icon_Resources = {
			[1001] = { icon_name = "cj_bosskiller", describe= 9340},
			[1002] = { icon_name = "cj_baozangnum", describe= 9341},
			[1003] = { icon_name = "cj_shengcuntianshu", describe= 9342},
			[1004] = { icon_name = "cj_jixianbosskiller", describe= 9343},
			[1005] = { icon_name = "cj_shenmiliwu", describe= 9344},
			[1006] = { icon_name = "cj_hotmapnum", describe= 9345},
			[1007] = { icon_name = "cj_jianshangjia", describe= 9346},
			[1008] = { icon_name = "cj_haoyounum", describe= 9347},
			[1009] = { icon_name = "cj_fensinum", describe= 9348},
			[1010] = { icon_name = "cj_dianzan", describe= 9349},
			[1011] = { icon_name = "cj_jiaohua", describe= 9350},
			[1012] = { icon_name = "cj_chuchong", describe= 9351},
			[1013] = { icon_name = "cj_tujiannum", describe= 9352},
			[1014] = { icon_name = "cj_shouhuonum", describe= 9353},
			[1015] = { icon_name = "cj_guoshilv", describe= 9354},
			[1016] = { icon_name = "cj_juesenum", describe= 9355},
			[1017] = { icon_name = "cj_jueselv", describe= 9356},
			[1018] = { icon_name = "cj_pifunum", describe= 9357},
			[1019] = { icon_name = "cj_zuojinum", describe= 9358},
			[1020] = { icon_name = "cj_avtnum", describe= 9359},
			[1021] = { icon_name = "cj_shimingzhi", describe= 9360},
			[1022] = { icon_name = "cj_chixudenglu", describe= 9361},
			[1024] = { icon_name = "cj_fangzhapian", describe= 9385}, --防诈骗徽章配置
			--yearVote
			[1025] = { icon_name = "cj_mapcreator", describe= 9391},--年度投票勋章配置 创作之星
			[1026] = { icon_name = "cj_videocreator", describe= 9392}, --视频之星
			[1027] = { icon_name = "cj_communitystar", describe= 9393}, --社区之星
			[1028] = { icon_name = "cj_finalists", describe= 9394}, --年度入围者

			[1029] = { icon_name = "cj_gunskin", describe= 9395}, --火力十足勋章

			[1030] = { icon_name = "cj_yinxiang", describe= 9397}, --银享卡勋章
			
			[1031] = { icon_name = "cj_aotudasai", describe= 9400}, --凹凸勋章
		}

		self.frame_Resources ={
			[1]="cj_wood",
			[2]="cj_stone",
			[3]="cj_iron",
			[4]="cj_gold",
			[5]="cj_diamond",
		}
	end,

	SetIncrementAchieveData = function(self,data)
		if self.allAchieveData then
			for k,v in pairs(data) do
				local t_achieveEpitome = self.allAchieveData[k];
				if t_achieveEpitome then
					t_achieveEpitome.achieve_to_get = 1;
				end

				local achieveDetailList = self.achieveDetail; --成就详细信息没有加载出来，就先保存，下次加载出来再去设置
				if achieveDetailList == nil or next(achieveDetailList) == nil then
					self.incrementList = data;
					return;
				end

				self.incrementList ={};
				local t_achieveDetail = self.achieveDetail[k];
				if t_achieveDetail and t_achieveDetail.achieve_levels then  --
					for k1,v1 in pairs(t_achieveDetail.achieve_levels) do
						for k2,v2 in pairs(v.achieve_levels) do
							if v2.level ==v1.level then
								v1.stat=v2.stat;
								break;
							end
						end
					end
				end

			end
		end
	end,

	SetObtainAchieveData = function(self,id)
		if id <1000 then return end

		local t_changeData= self.allAchieveData[id]
		local t_achieveDetail = self.achieveDetail[id];

		if t_changeData and next(t_changeData)~= nil then
			t_changeData.achieve_to_get = 2;
		end

		-- 这里加个判空，其他用地方都有加，这里是漏了吧
		if t_achieveDetail and t_achieveDetail.achieve_levels then
			for k,v in pairs(t_achieveDetail.achieve_levels) do
				v.stat = 2;
				if t_changeData and next(t_changeData)~= nil then
					if t_changeData.achieve_level==nil or t_changeData.achieve_level <v.level then
						t_changeData.achieve_level = v.level;
						t_changeData.achieve_time = v.time;
					end
				end
			end
		end
	end,

	--获取成就值上一个等级数 number 当前的成就数
	GetLastAchieveLevelValue = function(self,number)
		if number <0 then return end
		local lastValue = 0;

		for k,v in pairs(self.prize) do
			if v<= number and v>lastValue then
				lastValue = v;
			end
		end
		return lastValue;
	end,

}

--个人中心成就系统的管理类
UIAchievementMgr = {
	IsInit = false;
	IsHFInit = false,
	t_data = AchievementData;
	uin = AccountManager:getUin();
	AchievementShow = true; --成就模块是否显示，服务器控制
	getAwardCellNum = 0,

	EventList ={}, --{eventName ={panel1,panel2}}

	PanelList = {},
	RoleInfoIcon = {
		{name = t_exhibition:getUiName().."RoleInfoGender"},
		{name = t_exhibition:getUiName().."RoleInfoRealnameInfoFrame"},--{name = t_exhibition:getUiName().."RoleInfoAuthIcon"},
		{name = t_exhibition:getUiName().."RoleInfoPhoneBindingIcon"},
		{name = t_exhibition:getUiName().."RoleInfoQQVipIcon"},
	},

	SetRequestAllFlag = function ()
		IsAchieveNeedInit = true
	end,

	Init = function(self)
		-- 只初始化一次
		if next(self.PanelList) == nil then
			print("t_exhibition:isThreeVerOpen()", t_exhibition:isThreeVerOpen())
			if t_exhibition:isThreeVerOpen() then
				self.PanelList[#self.PanelList + 1] = PEC_AchievementNewPanel
			else
				self.PanelList[#self.PanelList + 1] = PEC_AchievementPanel
			end
	
			self.PanelList[#self.PanelList + 1] = PEC_ExhibitionRewardPanel
			self.PanelList[#self.PanelList + 1] = PEC_AchieveSuccessPanel
			self.PanelList[#self.PanelList + 1] = PEC_ObtainAchieveRewardPanel
			self.PanelList[#self.PanelList + 1] = PEC_ShareAchievePanel
		end

		if check_apiid_ver_conditions(ns_version.achieve) and ns_version.achieve.url then
			self.AchievementShow =true;
		else
			self.AchievementShow = false;
		end

		if t_exhibition.isHost == false or self.uin ~= t_exhibition.uin then
			self.IsInit = false;
			self.IsHFInit = false
			self.uin = t_exhibition.uin;
			AchievementData:Reset();
			self.PanelList[1]:HideAchievePanelBeforeGetData();
		end

		if self.AchievementShow then
			if (not IsAchieveNeedInit) and
				((self.IsInit and getglobal(t_exhibition:getUiName()):IsShown()) or 
				(self.IsHFInit and getglobal("BlockSetHonorFrame"):IsShown())) then
				--增量数据
				self:ReqIncrementAchieveData();
			else
				-- 先初始化监听组件，再去拉取数据
				for k,v in pairs(self.PanelList) do
					v:OnLoad();
				end
				
				self.t_data = AchievementData;
				self.t_data:Init();


				if getglobal(t_exhibition:getUiName()):IsShown() then
					self.IsInit = true;
				elseif getglobal("BlockSetHonorFrame"):IsShown() then
					self.IsHFInit = true
				end
			end

			UIAchievementMgr.t_data:ReqCurAchieveLevelList(); --成就具体信息每次打开界面加载，具体的完成数每次都会变

		end


	end,

	RegisterEvent = function(self,eventName,panelName)
		if self.EventList[eventName] == nil then
			self.EventList[eventName] ={};
		end
		for k,v in pairs(self.EventList[eventName]) do
			if v ==panelName then return end
		end
		table.insert(self.EventList[eventName],panelName);
	end,

	UnRegisterEvent = function(self,eventName,panelName)
		if self.EventList[eventName] == nil then
			return
		end
		for k,v in pairs(self.EventList[eventName]) do
			if v ==panelName then
				table.remove(self.EventList[eventName],panelName);
			end
		end
	end,

	NotifyEvent = function(self,eventName,data)
		if self.EventList[eventName] then
			for k,v in pairs(self.EventList[eventName]) do
				v:OnEvent(eventName,data);
			end
		end
	end,

------------------------------------------------------------------------------------------------
	--获取成就主界面的所有显示数据
	GetAchievementPanelData = function(self)
		local data ={};
		data.AllNum = self.t_data.task_size;
		data.AllAchieve = self.t_data.allAchieveData;

		data.achieveValue={
			Num=self.t_data:GetTotalAchieve();
			AllNum = self.t_data:SetCurAchieveLevel();
			LastNum = self.t_data:GetLastAchieveLevelValue(self.t_data:GetTotalAchieve());
			RewardId = self.t_data.next_achieve_target;
			NeedGetGift = self.t_data.achieve_gifts_to_get;
		}
		return data;
	end,

	--获取某一个成就的具体信息
	GetAchieveDetailById = function(self,id)
		local t_detail= {};
		local t_data = {};

		t_detail = self.t_data.achieveDetail[id];
		if t_detail ==nil or next(t_detail)==nil then return nil end

		if t_detail.achieve_levels then
			for k,v in pairs(t_detail.achieve_levels) do
				local t_temp = {};
				for k1,v1 in pairs(t_detail.levels) do
					if v.level == v1.level then
						t_temp =v1;
						t_temp.time = v.time;
						t_temp.stat = v.stat or 2;
						break;
					end
				end
			end
		end

		t_data.data = t_detail.levels
		t_data.achieveName = self.t_data.allAchieveData[id].title;
		t_data.finished = t_detail.finished;
		return t_data;
	end,

	--加载成就奖励界面信息
	GetAchieveRewardData = function(self)
		if next(self.t_data.rewardList) ~= nil then
			local data = {};
			data.rewardList= self.t_data.rewardList;
			data.totalAchieve = self.t_data:GetTotalAchieve();
			return data;
		else
			Log("获取成就奖励信息失败");
			return nil;
		end
	end,

	--判断是否已经加载了成就的详细信息
	ObtainedAchieveDetail = function(self,temp) --temp 临时的透传参数
		if self.t_data.achieveDetail == nil or next(self.t_data.achieveDetail) == nil  then
			self.t_data:ReqCurAchieveLevelList(temp);
			return false
		else
			return true;
		end
	end,

	--加载奖励列表数据
	LoadAchieveRewardList = function(self)
		self.t_data:ReqAchieveRewardList();
	end,

	--时间戳转化年月日
	GetTimeStamp= function(self,t)
		return os.date("%Y.%m.%d", t)
	end,

	--获取当前使用的成就
	GetCurUseAchieve = function(self)
		local used_achieve = self.t_data.used_achieve;
		if next(used_achieve) ~= nil then
			return used_achieve;
		end
	end,

	--设置使用成就
	ReqUseAchieve = function(self,level,id)
		print("ReqUseAchieve: level = ", level, ", id = ", id);

		if self.AchievementShow then
			local achieveId = id;
			if achieveId == nil or achieveId<0 then
				achieveId = PEC_AchieveSuccessPanel.achieveId;
			end

			local data =self.t_data.allAchieveData[achieveId];
			if next(data) ~= nil then
				data.level = level;
				local uin = t_exhibition.uin;
				local url_ =  g_http_common..'/miniw/achieve?act=use_achieve_medal&op_uin='..uin..'&aid='..achieveId.."&level="..level.."&" .. http_getS1();
				Log( url_ );
				ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:ReqUseAchieve");
				ns_http.func.rpc( url_, self.RespUseAchieve, data, nil, true );
			end
		end
	end,

	RespUseAchieve = function(ret,data)
		print("UIAchievementMgr:RespUseAchieve()",ret);
		ShowLoadLoopFrame(false)
		if ret and ret.ret ==0 then
			ShowGameTips( GetS(20601,GetS(data.title)) );
			if next(data) ~=nil then
				UIAchievementMgr.t_data.used_achieve.id =data.id;
				UIAchievementMgr.t_data.used_achieve.level = data.level;
				UIAchievementMgr.t_data.used_achieve.title = data.title;
				UIAchievementMgr:NotifyEvent(AchievementDefine.SetUseAchieveSuccess,data);
			end
		else
			ShowGameTips( GetS(20626), 3 );
		end
	end,

	--获取成就的icon资源列表
	GetIconResources = function(self,id)
		local t_icon = self.t_data.icon_Resources;

		if t_icon and  next(t_icon) == nil then
			self.t_data:InitAchieveResources();
		end

		if t_icon and   next(t_icon)~= nil and t_icon[id] and next(t_icon[id]) then
			return t_icon[id];
		end
	end,

	--获取成就的品质资源列表
	GetFrameResources = function(self,level)
		local t_frame = self.t_data.frame_Resources;

		if t_frame and  next(t_frame) == nil then
			self.t_data:InitAchieveResources();
		end

		if next(t_frame) ~= nil and t_frame[level] then
			return t_frame[level];
		end
	end,

	--取消使用成就勋章
	ReqCancelUseAchieve = function(self)
		if self.AchievementShow then
			local uin = t_exhibition.uin;
			local url_ =  g_http_common..'/miniw/achieve?act=cancel_achieve_medal&op_uin='..uin..'&' .. http_getS1();
			Log( url_ );
			ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:ReqCancelUseAchieve");
			ns_http.func.rpc( url_, self.RespCancelUseAchieve, data, nil, true );
		end
	end,

	RespCancelUseAchieve =function(ret)
		print("UIAchievementMgr:RespCancelUseAchieve()",ret);
		ShowLoadLoopFrame(false)

		if next(ret) ~= nil and ret.ret ==0 then
			local title = UIAchievementMgr.t_data.used_achieve.title;
			ShowGameTips( GetS(20602,GetS(title)), 3 );
			UIAchievementMgr.t_data.used_achieve = {};
			UIAchievementMgr:NotifyEvent(AchievementDefine.CancelUseAchieve);
		else
			--ShowGameTips( "取消使用成就失败", 3 );
		end
	end,

	--查询增量的数据
	ReqIncrementAchieveData = function(self)
		if self.AchievementShow then
			local uin = t_exhibition.uin;
			local url_ =  g_http_common..'/miniw/achieve?act=query_achieve_increment_task&op_uin='..uin..'&' .. http_getS1();
			Log( url_ );
			ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:ReqIncrementAchieveData");
			ns_http.func.rpc( url_, self.RespIncrementAchieveData, nil, nil, true);
		end
	end,

	RespIncrementAchieveData = function(ret)
		print("UIAchievementMgr:RespIncrementAchieveData()",ret);
		ShowLoadLoopFrame(false)
		if ret and ret.ret ==0 then
			UIAchievementMgr.PanelList[1]:ShowAchievePanelBeforeGetData();
			if ret.data and next(ret.data) ~= nil then
				UIAchievementMgr.t_data:SetIncrementAchieveData(ret.data);
			end
			UIAchievementMgr:NotifyEvent(AchievementDefine.ObtainAchieveIncrementData);
		else
			ShowGameTips( GetS(20644), 3 );
		end
	end,

	--获取成就
	ReqGetAchieve = function(self,id)
		if self.AchievementShow then
			local uin = t_exhibition.uin;
			local url_ =  g_http_common..'/miniw/achieve?act=set_achieve_medal&op_uin='..uin..'&task_id='..id.."&" .. http_getS1();
			Log( url_ );
			ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:ReqGetAchieve");
			ns_http.func.rpc( url_, self.RespGetAchieve, id, nil, true);
		end
	end,

	RespGetAchieve =function (ret,id)
		print("UIAchievementMgr:RespGetAchieve()",ret);
		ShowLoadLoopFrame(false)

		if ret and ret.ret ==0 then
			--ShowGameTips( "获取勋章成功", 3 );
			UIAchievementMgr.t_data.total_achieve = ret.total_achieve;
			UIAchievementMgr.t_data.next_achieve_target = ret.next_achieve_target or UIAchievementMgr.t_data.next_achieve_target;

			local dataList = UIAchievementMgr:GetNeedShowAchieveToExhibition(id);
			UIAchievementMgr:NotifyEvent(AchievementDefine.SetNeedExhibitAchieveData,dataList);
			UIAchievementMgr:QueryAndExhibitObtainAchieve();

			UIAchievementMgr.t_data:SetObtainAchieveData(id);

			UIAchievementMgr:NotifyEvent(AchievementDefine.ShowAchieveSuccessPanel,id);
			UIAchievementMgr:NotifyEvent(AchievementDefine.ShowAchievementPanel,id);

			UIAchievementMgr:NotifyEvent(AchievementDefine.UpdateAchieveMainPanelRedTag);
		else
			ShowGameTips(GetS(20644), 3 );
		end
	end,

	--获取需要展示在展示成就界面的数据
	GetNeedShowAchieveToExhibition = function(self,id)
		local t_changeData= self.t_data.allAchieveData[id]
		local t_achieveDetail = self.t_data.achieveDetail[id];

		local t_retData = {};

		if t_achieveDetail and t_achieveDetail.achieve_levels and next(t_achieveDetail.achieve_levels) ~= nil then
			for k,v in pairs(t_achieveDetail.achieve_levels) do
				if v.stat ==1 then
					local temp ={};
					temp.id = id;
					temp.level = v.level;
					temp.time = v.time;
					temp.title =t_changeData.title;
					temp.target =""; --达成成就的要求

					--获取成就达成的要求
					for k1,v1 in pairs(t_achieveDetail.levels) do
						if v1.level == v.level then
							temp.target = v1.target;
						end
					end

					table.insert(t_retData,temp);
				end
			end
		end

		return t_retData;
	end,

	--成就详细信息列表获取完成
	ObtainedAchieveDetailCallBack = function(self,id)
		if self.t_data.incrementList and next(self.t_data.incrementList)~= nil then
			self.t_data:SetIncrementAchieveData(self.t_data.incrementList);
		end

		local t_achieveEpitome = self.t_data.allAchieveData[id];
		if t_achieveEpitome and t_achieveEpitome.achieve_to_get and t_achieveEpitome.achieve_to_get ==1 then
			self:ReqGetAchieve(id);
		else
			self:NotifyEvent(AchievementDefine.ShowAchieveSuccessPanel,id);
		end

	end,

	--获取是否显示成就功能
	AchieveModuleCanShow = function(self)
		if check_apiid_ver_conditions(ns_version.achieve) and ns_version.achieve.url then
			return	true;
		else
			return false;
		end
	end,

	--领取奖励信息
	ReqAchieveRewardByCode = function(self,data)
		if self.AchievementShow then
			local  now_ = os.time();
			local  uin_ = AccountManager:getUin() or get_default_uin()
			local  spliceStr = http_getS1();

			local uin = t_exhibition.uin;
			local url_ =  g_http_common..'/miniw/achieve?act=send_achieve_task_reward_result&op_uin='..uin.."&code="..data.code..'&' .. spliceStr;
			Log( url_ );
			ShowLoadLoopFrame(true, "file:PlayerExhibitionCenter -- func:ReqAchieveRewardByCode");
			ns_http.func.rpc( url_, self.RespAchieveRewardByCode, data, nil, true );
		end
	end,

	RespAchieveRewardByCode = function(ret,data)
		print("UIAchievementMgr:RespAchieveRewardByCode()",ret);
		ShowLoadLoopFrame(false)

		if ret then
			if ret.ret ==0 then
				if  AccountManager.notify_data_update then
					AccountManager:notify_data_update()
				end
				UIAchievementMgr:NotifyEvent(AchievementDefine.ObtainAchieveRewardSuccess,data);
				UIAchievementMgr:NotifyEvent(AchievementDefine.UpdateAchieveMainPanelRedTag,data);
			elseif ret.ret ==2 then
				ShowGameTips( GetS(20626), 3 );
			elseif ret.ret ==3 then
				ShowGameTips( GetS(20626), 3 );
			elseif ret.ret ==4 then
				ShowGameTips( GetS(4911), 3 );
			else
				ShowGameTips( GetS(4089), 3 );
			end
		end

	end,

	--查询是否还有需要展示的成就，并展示
	QueryAndExhibitObtainAchieve = function(self)
		local num = PEC_ObtainAchieveRewardPanel:GetNeedExhibitDataNum();
		if num >0 then
			self:NotifyEvent(AchievementDefine.ShowObtainAchieveRewardPanel);
		end
	end,

	GetLeftTabTag = function(self)
		local ui_tabRedTag = getglobal("PlayerExhibitionCenterLeftTabBtn4RedTag")
		if t_exhibition:isThreeVerOpen() then
			local t_Tab = t_ExhibitionCenter.leftTabs
			for index = 1, #t_Tab.ID do
				if t_ExhibitionCenter.define.tabHome == t_Tab.ID[index]  then
					ui_tabRedTag = getglobal(t_exhibition:getUiName().."LeftTabBtn" .. t_Tab.ID[index].."RedTag");
					break
				end
			end
		end

		return ui_tabRedTag
	end,

	GetRewardRedTag = function(self)
		local ui_rewardRedTag = getglobal("ExhibitionInfoPage4AchievementStateRewardBtnRedTag")
		if t_exhibition:isThreeVerOpen() then
			ui_rewardRedTag = getglobal("NewPlayerCenterMedalViewAchievementStateRewardBtnRedTag")
		end

		return ui_rewardRedTag
	end,

	--判断显示大厅界面和个人中心成就的tab红点显示
	SetRedTagState = function(self,isShow,id)
		local keyName = "AchieveRedTag";
		local ui_tabRedTag = self:GetLeftTabTag()
		local ui_headRedTag = GetMiniLobbyRoleInfoHeadArchiveRedTagFrame(); --mark by hfb for new minilobby
		local ui_rewardRedTag = self:GetRewardRedTag()

		if isShow then
			if t_exhibition.isHost then
				ui_tabRedTag:Show();
			else
				ui_tabRedTag:Hide();
			end
			ui_headRedTag:Show();
			RefreshFguiMainHeadReadTag(true)
			if tonumber(id) == 1 then  --指有可以领取的奖励
				ui_rewardRedTag:Show();
				self:SetToGetGiftRewardSign(true);
			end
		else
			ui_tabRedTag:Hide();
			ui_headRedTag:Hide();
			ui_rewardRedTag:Hide();
			RefreshFguiMainHeadReadTag(false)
		end
		setkv(keyName,isShow);
	end,

	--从内存中读取大厅界面的红点是否显示的数据
	GetRedTagState = function(self,op_uin)
		local ui_tabRedTag = getglobal("PlayerExhibitionCenterLeftTabBtn4RedTag");
		local ui_headRedTag = GetMiniLobbyRoleInfoHeadArchiveRedTagFrame(); --mark by hfb for new minilobby
		local keyName = "AchieveRedTag";

		local isShow = getkv(keyName,nil,op_uin);
		if isShow then
			ui_tabRedTag:Show();
			ui_headRedTag:Show();
			RefreshFguiMainHeadReadTag(true)
		else
			ui_tabRedTag:Hide();
			ui_headRedTag:Hide();
			RefreshFguiMainHeadReadTag(false)
		end
	end,

	--设置是否有需要领取的奖励的数据
	SetToGetGiftRewardSign = function(self,isHas)
		if isHas then
			self.t_data.achieve_gifts_to_get =1;
		else
			self.t_data.achieve_gifts_to_get =0;
		end
	end,
}

--工具类
PEC_Tools = {
	--设置文字大小的自适应增加字体的宽度
	SetUiTextSelfAdaptionWidth=function (UiText,text)
		UiText:SetText(text);
		local width =UiText:GetTextExtentWidth(text);
		UiText:SetWidth(width)
		return width;
	end,

--设置文字在固定大小的宽度中文字缩放,文字的对其方式为左对齐
	SetUiTextSelfAdaptionScale = function (UiText,text)
		UiText:SetText(text);
		local width1 = UiText:GetTextExtentWidth(text);
		local realWidth = UiText:GetWidth();

		local scale = 1
		if width1>=realWidth then
			scale = realWidth/width1
		end

		UiText:SetScale(scale);
	end	,
}

--游戏内所有玩家的使用的成就保存数据
playerAchieveUsed = {
	AllUsedAchieve = {},

	SetUsedAchieve = function(uin,achieveData)
		print("playerAchieveUsed.SetUsedAchieve()",uin,achieveData);
		local  this = playerAchieveUsed;
		if achieveData and uin then
			this.AllUsedAchieve[uin] = achieveData;
		end
	end,

	ClearUsedAchieve = function(uin)
		if uin == nil then return end
		local this = playerAchieveUsed;

		local achieveData = this.AllUsedAchieve[uin];
		if achieveData ~= nil then
			this.AllUsedAchieve[uin] = {};
		end
	end,

	GetUsedAchieve = function(uin)
		--print("playerAchieveUsed.GetUsedAchieve()",uin)
		if uin == nil then return end
		local this = playerAchieveUsed;

		local achieveData = this.AllUsedAchieve[uin];
		if achieveData then
			return achieveData;
		else
			return nil;
		end
	end,

}

--游戏内显示成就请求数据
function ReqCurUseAchieveByUin(uin)
	print("ReqCurUseAchieveByUin()",uin)
	
	local canShow = UIAchievementMgr:AchieveModuleCanShow();
	if canShow ==false then  return end

	local url_ =  g_http_common..'/miniw/achieve?act=query_others_achieve_task&op_uin='..uin..'&' .. http_getS1();
	Log( url_ );
	ns_http.func.rpc( url_, RespCurUseAchieveByUin, uin, nil, true);
end

function RespCurUseAchieveByUin(ret,uin)
	print("RespCurUseAchieveByUin()",ret)

	if ret and ret.ret ==0 then
		local achieveData = ret.data[1].used_achieve;
		local canShow = false;
		if achieveData and next(achieveData) ~= nil then
			playerAchieveUsed.SetUsedAchieve(uin,achieveData);
			ShowGameScenePlayerAchieve(uin);
			-- 重新更新一下会员vipicon的位置
			OnPlayerEnter(uin)
		else
			canShow = false
			playerAchieveUsed.ClearUsedAchieve(uin);
		end


	end

end

--显示游戏内玩家的成就信息
function ShowGameScenePlayerAchieve(uin)
	local canShow = false;
	local achieveData;

	achieveData = playerAchieveUsed.GetUsedAchieve(uin);

	if achieveData and next(achieveData) ~= nil then
		canShow =true;
	else
		canShow = false
	end

	if not CurWorld then --容错
		return
	end

	local num = CurWorld:getActorMgr():getNumPlayer();
	if num<= 0 then return end

	local player = nil;

	--获取player
	for i= 0,num-1 do
		local t_player = CurWorld:getActorMgr():getIthPlayer(i)
		if t_player and t_player:getUin() == uin then
			player = t_player;
			break;
		end
	end

	if player == nil then return end

	if canShow then
		UIAchievementMgr.t_data:InitAchieveResources();
		local icon_Res = UIAchievementMgr:GetIconResources(achieveData.id);
		local frame_Res = UIAchievementMgr:GetFrameResources(achieveData.level);
		if icon_Res and icon_Res.icon_name then
			player:setAchieveInfo(true,icon_Res.icon_name,frame_Res);
		end
		--player:setAchieveInfo(true,"cj_avtnum_s","cj_diamond_s");
	else
		player:setAchieveInfo(true,"","");
	end
end

--服务器推送成就红点数据
function OnAchievePostingMsg(msg)
	print("OnAchievePostingMsg(msg)",msg);
	if msg then
		UIAchievementMgr:SetRedTagState(true,msg.id);
	end
end

--------------------------------------------------------------------
function AchievementSlider_OnMouseWheel()
end

--单个成就的点击方法
function PEC_AchievementBtn_OnClick()
	if t_exhibition.isHost == false then return end
	getglobal("ExhibitionInfoPage4AchievementSlider"):setDealMsg(false);
	local id = this:GetParentFrame():GetClientID();
	-- standReportEvent("7", "PERSONAL_INFO_MEDAL", "Medal", "view", {slot=tostring(id)})
	local isShowRedTag = false;

	if getglobal(this:GetParentFrame():GetName().."RedTag"):IsShown() then
		isShowRedTag = true;
	end

	if isShowRedTag then
		--UIAchievementMgr:ReqGetAchieve(id);
		standReportEvent("7", "PERSONAL_INFO_MEDAL"	, "Medal", "click", {slot=tostring(id)})
		UIAchievementMgr.t_data:ReqCurAchieveLevelList(id);
	else
		if UIAchievementMgr:ObtainedAchieveDetail(id) then
			standReportEvent("7", "PERSONAL_INFO_MEDAL"	, "CollectRewards", "click", {slot=tostring(id)})
			UIAchievementMgr:NotifyEvent(AchievementDefine.ShowAchieveSuccessPanel,id);
			if getglobal("BlockSetHonorFrame"):IsShown() then
				GetInst("UIManager"):GetCtrl("BlockSetHonorFrame"):SetCurOpenAchieveId(id)
			end
		end
	end

end

function PEC_AchieveSuccessArrowBtn_OnClick(id)
	if id ==1 then
		UIAchievementMgr:NotifyEvent(AchievementDefine.SuccessPanelArrowBtnClick,false);
	elseif id ==2 then
		UIAchievementMgr:NotifyEvent(AchievementDefine.SuccessPanelArrowBtnClick,true);
	end
end

--中间成就详情页的'佩戴/摘下'按钮点击(old:"PEC_AchieveLevelCellGetBtn_OnClick")
function ExhibitionAchieveSuccessFrameCenterInfoSetBtn_OnClick()
	if t_exhibition.isHost == false then return end

	if getglobal(t_exhibition:getUiName()):IsShown() then
		local id = this:GetParentFrame():GetClientID();
		local ui_text = getglobal(this:GetName().."Name")

		local content = ui_text:GetText();
		if string.find(content,GetS(7302))~= nil then
			--取消佩戴
			UIAchievementMgr:ReqCancelUseAchieve();
		elseif  string.find(content,GetS(20595))~= nil then
			--佩戴
			UIAchievementMgr:ReqUseAchieve(id);
		end
	elseif getglobal("BlockSetHonorFrame"):IsShown() then
		local ui_HomelandHFSetBtnText = getglobal(this:GetName().."Name")
		--[[
		local HFAchieveData = GetInst("UIManager"):GetCtrl("BlockSetHonorFrame"):GetCurSelectAchieve()
		if HFAchieveData.id == PEC_AchieveSuccessPanel.achieveId and HFAchieveData.level == PEC_AchieveSuccessPanel.curSelectIndex then
			ui_HomelandHFSetBtnText:SetText("取消取消")
		else
			ui_HomelandHFSetBtnText:SetText("佩戴佩戴")
		end]]
		local content = ui_HomelandHFSetBtnText:GetText();
		if string.find(content,GetS(20134))~= nil then
			--取消
			ui_HomelandHFSetBtnText:SetText(GetS(41372))
			GetInst("UIManager"):GetCtrl("BlockSetHonorFrame"):HonorFrameShowBtn_OnClick(false)
		elseif  string.find(content,GetS(41372))~= nil then
			ui_HomelandHFSetBtnText:SetText(GetS(20134))
			local level = this:GetParentFrame():GetClientID()
			GetInst("UIManager"):GetCtrl("BlockSetHonorFrame"):HonorFrameShowBtn_OnClick(true, level)
		end
	end
end

function PEC_RewardBtn_OnClick()
	if t_exhibition.isHost == false then return end
	standReportEvent("7", "PERSONAL_INFO_MEDAL", "CollectRewards", "view")
	UIAchievementMgr:LoadAchieveRewardList();
end

function PEC_AchieveLevelCellBtn_OnClick()
	if t_exhibition.isHost == false then return end

	local level = this:GetClientID();
	local uiName = this:GetName();
	local data={};
	data.level = level;
	data.uiName = uiName;
	UIAchievementMgr:NotifyEvent(AchievementDefine.SelectAchievelevelCell,data)
end

function PEC_AchieveLevelCellIconBtn_OnClick()
	if t_exhibition.isHost == false then return end

	local level = this:GetParentFrame():GetClientID();
	local uiName = this:GetParentFrame():GetName();
	local data={};
	data.level = level;
	data.uiName = uiName;
	UIAchievementMgr:NotifyEvent(AchievementDefine.SelectAchievelevelCell,data)
end

function PEC_AchieveLevelCellGetBtn_OnClick()
	if t_exhibition.isHost == false then return end

	local id = this:GetParentFrame():GetClientID();
	local ui_text = getglobal(this:GetName().."Name")

	local content = ui_text:GetText();
	if string.find(content,GetS(7302))~= nil then
		UIAchievementMgr:ReqCancelUseAchieve();
	elseif  string.find(content,GetS(20595))~= nil then
		UIAchievementMgr:ReqUseAchieve(id);
	end
end

function PEC_GetAchieveRewardBtn_OnClick()
	local m_uiIndex = this:GetClientUserData(0);
	local m_code = this:GetClientUserData(1);
	local m_id = this:GetClientUserData(2);
	local m_num = this:GetClientUserData(3);

	local data = {
		uiIndex = m_uiIndex,
		code = m_code;
		id = m_id;
		num = m_num;
	};

	UIAchievementMgr:ReqAchieveRewardByCode(data);

end

function PEC_ObtainAchieveRewardFrame_OnLoad()
	this:setUpdateTime(0.05);
end

local t_viewScale = 0.2  --特效缩放用到的一个临时变量
function PEC_ObtainAchieveRewardFrame_OnUpdate()
	local ui_view = getglobal("ObtainAchieveRewardFrameView");
	if t_viewScale < 1 then
		t_viewScale = t_viewScale + 0.1;
	end

	if t_viewScale > 1 then
		t_viewScale = 1
	end
	ui_view:setActorScale(0.95*t_viewScale, 0.95*t_viewScale, 0.95*t_viewScale);


end

function PEC_ObtainAchieveRewardFrame_OnShow()
end

function PEC_ObtainAchieveRewardFrame_OnClick()
	getglobal("ObtainAchieveRewardFrame"):Hide();
	UIAchievementMgr:QueryAndExhibitObtainAchieve();
end

function PEC_UseAchieveBtn_OnClick()
	UIAchievementMgr:NotifyEvent(AchievementDefine.ExhibitPanelUseAchieve);
end

function PEC_ExhibitAchievePanelShareBtn_OnClick()
	local id = this:GetClientUserData(0);
	local level = this:GetClientUserData(1);
	local title = this:GetClientUserData(2);
	local target = this:GetClientUserData(3);
	local data = {};
	data.id = id;
	data.level = level ;
	data.title = title;
	data.target = target;

	-- statisticsGameEvent(61035,"%d",id,"%d",level)
	UIAchievementMgr:NotifyEvent(AchievementDefine.StartSnapshotForAchieveShare,data)
end

function ExhibitionInfoPage4_OnShow()

end

function ExhibitionAchieveShareFrame_OnLoad()
	this:setUpdateTime(0);
end

function ExhibitionAchieveShareFrame_OnShow()

end

function ExhibitionAchieveShareFrame_OnHide()
	PECAchieveShare = true;
end

function ExhibitionAchieveShareFrame_OnUpdate()
	if SnapshotForShare:isSnapshotFinished() and PECAchieveShare  then
		PECAchieveShare = false;
		UIAchievementMgr:NotifyEvent(AchievementDefine.EndSnapshotForAchieveShare);
	end
end

function ExhibitionAchieveSuccessFrame_OnClick()
end

--显示个人中心QQ会员图标
function PEC_ShowQQVIPIcon(uin)
	if isShouQPlatform() and iOSShouQConfig(9,true) then
		local list = UIAchievementMgr.RoleInfoIcon
		local qqVip = getglobal(list[4].name)
		if isShouQTencentVip(uin, PEC_ShowQQVIPIcon) then
			local result = ReqShouQvip()
			if result and tonumber(result) > 0 then
				result = tonumber(result) or 0
				for i=#list, 1, -1 do
					local curFrame = getglobal(list[i].name)
					if i<4 and curFrame:IsShown() then
						--超级会员
						if LuaInterface:band(result, LuaInterface:lshift(1, 1)) ~= 0 then 
							qqVip:SetTexUV("icon_qqvip")
						elseif LuaInterface:band(result, 1) ~= 0 then
							qqVip:SetTexUV("logo_qqvip")
						end
						qqVip:SetPoint("LEFT", list[i].name, "RIGHT", 10, 0);
						qqVip:Show()
						return;
					end
				end
			else
				qqVip:Hide()
			end
		else
			qqVip:Hide()
		end
	end
end


---------------------------------------------------地图下载上报统计------------------------------------------------------------
--下载地图上报的定义
ReportDefine = {
	friendDefine = {
		Friend = 1, --好友
		Playmate = 2, --最近玩伴
		Attention = 3, -- 关注
		AddFriend = 4, --添加好友
		BlackList = 5, -- 黑名单
		QQFriend = 6, -- QQ好友
	},

	frameDefine = {
		FriendFrame = 1, --好友界面
		RoomFrame = 2, --联机大厅
		MiniWorkFrame = 3, --迷你工坊
	},

	--联机大厅参数
	roomDefine = {
		DownLoad = 1, --正常下载
		Collection = 2, --收藏下载
		Search = 3, --搜索下载
		Popular = 4, --热门下载
	},

	roomSubDefine = {
		All = 1,  --综合
		Adventure = 2,  --冒险
		Create = 3,  --创造
		Battle = 4,  -- 对战
		Parkour = 5,  -- 跑酷
		Decrypt = 6,  -- 解密
		Circuit =7,  --  电路
		Other =8,  -- 其他

	},

	PlayerCenterDefine = {
		Oneself = 1, --自己个人中心
		Others = 2, -- 他人个人中心
	},

	--迷你工坊参数
	MiniWorkDefine = {
		HomePage =1, --主页
		Map = 2, --地图
		Special = 3, --专题
		Collection =4, -- 收藏
		Search = 5, --搜索
		MyType = 6, --我的
	},

	MiniWorkHomepageSubDefine = {
		Selected = 1, --精选
		Recommend = 2, --推荐
		Popular = 3, --热门
		Selectiveplay = 4, -- 精选玩法

		Select = 5,
		Creator = 6,
		Expect = 7,
		Select_Second = 8,
		Creator_Second = 9,
		Expect_Second = 10,
	},

	MiniWorkMapSubDefine = {
		Selected = 1, --精选
		Recommend = 2, --推荐
		Gameplayer = 3, --玩家
	},

	MiniWorkMytypeSubDefine = {
		MyMap = 1, --我的作品
		Subscribe = 2, --订阅
		Attention = 3, --关注鉴赏家
	}


}

MapDownloadReportMgr = {
	--主界面字段保存，存储好友界面或者联机大厅或者工坊，判断从哪里下载的
	mainFrameName = -1;

	--好友界面的参数
	friendTabId = -1; --好友界面侧边栏id

	--联机大厅的参数
	roomType = -1;
	roomSubType = -1; --联机大厅下载类型，综合，对战等

	--个人中心参数
	playerCenterType= -1,

	--工坊的参数
	miniworkType = -1,
	miniworkHomepageSubType = -1,
	miniworkMapSubType = -1,
	miniworkMyTypeSubType = -1,

	---------------------------------------------------------------------------
	--设置窗口的名字显示
	SetFrameName = function (self,frameID)
		if frameID <= 0 then return end
		self.mainFrameName = frameID;
	end,

	ClearFrameName = function(self)
		self.mainFrameName = -1;
	end,

	--设置好友界面的索引
	SetFriendDownloadType = function(self,friendId)
		if friendId <= 0 then return end
		self.friendTabId = friendId;
	end,

	--设置联机大厅的索引
	SetRoomDownloadType = function(self,typeId)
		if typeId <= 0 then return end
		self.roomType = typeId;
	end,

	--设置联机大厅子索引
	SetRoomDownloadSubType = function(self,typeId)
		if typeId <= 0 then return end
		self.roomSubType = typeId;
	end,

	--设置个人中心上报的类型
	SetPlayerCenterType = function(self,typeId)
		if typeId <= 0 then return end
		self.playerCenterType = typeId;

	end,

	--设置迷你工坊类型
	SetMiniWorkType = function(self,typeId)
		print("SetMiniWorkType()",typeId)
		if typeId <= 0 then return end

		if typeId == 7 then
			self.miniworkType = ReportDefine.MiniWorkDefine.HomePage;
		elseif typeId == 1 then
			self.miniworkType = ReportDefine.MiniWorkDefine.Map;
		elseif typeId == 4 then
			self.miniworkType = ReportDefine.MiniWorkDefine.Special;
		elseif typeId == 5 then
			self.miniworkType = ReportDefine.MiniWorkDefine.Collection;
		elseif typeId == 6 then
			self.miniworkType = ReportDefine.MiniWorkDefine.Search;
		elseif typeId == 3 then
			self.miniworkType = ReportDefine.MiniWorkDefine.MyType;
		end
	end,

	-- 设置迷你工坊主页子类型
	SetMiniWorkHomepageSubType = function(self,uiName)
		print("SetMiniWorkHomepageSubType()",uiName)
		if uiName then
			if string.find(uiName,"SectionWeeklyMaps") then
				self.miniworkHomepageSubType = ReportDefine.MiniWorkHomepageSubDefine.Selected;
			elseif string.find(uiName,"SectionHotMaps") then
				self.miniworkHomepageSubType = ReportDefine.MiniWorkHomepageSubDefine.Popular;
			elseif string.find(uiName,"FeaturedGameplay") then
				self.miniworkHomepageSubType = ReportDefine.MiniWorkHomepageSubDefine.Selectiveplay;
			elseif string.find(uiName,"SectionConnoisseurMapsArchive") then
				self.miniworkHomepageSubType = ReportDefine.MiniWorkHomepageSubDefine.Recommend;
			end
		end
	end,

	-- 新版设置迷你工坊主页子类型
	SetMiniWorkMainSubType = function(self, commendtype)
		print("SetMiniWorkMainSubType() commendtype = ", commendtype)
		if commendtype == 1 then
			self.miniworkHomepageSubType = ReportDefine.MiniWorkHomepageSubDefine.Select;
		elseif commendtype == 2 then
			self.miniworkHomepageSubType = ReportDefine.MiniWorkHomepageSubDefine.Creator;
		elseif commendtype == 3 then
			self.miniworkHomepageSubType = ReportDefine.MiniWorkHomepageSubDefine.Expect;
		elseif commendtype == 4 then
			self.miniworkHomepageSubType = ReportDefine.MiniWorkHomepageSubDefine.Select_Second;
		elseif commendtype == 5 then
			self.miniworkHomepageSubType = ReportDefine.MiniWorkHomepageSubDefine.Creator_Second;
		elseif commendtype == 6 then
			self.miniworkHomepageSubType = ReportDefine.MiniWorkHomepageSubDefine.Expect_Second;
		end
	end,

	-- 设置迷你工坊地图子类型
	SetMiniWorkMapSubType = function(self,typeId)
		print("SetMiniWorkMapSubType()",typeId)
		if typeId <= 0 then return end
		if typeId == 1 then
			self.miniworkMapSubType = ReportDefine.MiniWorkMapSubDefine.Recommend;
		elseif typeId == 2 then
			self.miniworkMapSubType = ReportDefine.MiniWorkMapSubDefine.Selected;
		elseif typeId == 3 then
			self.miniworkMapSubType = ReportDefine.MiniWorkMapSubDefine.Gameplayer;
		end

	end,

	-- 设置迷你工坊我的子类型
	SetMiniWorkMyTypeSubType = function(self,typeId)
		print("SetMiniWorkMyTypeSubType()",typeId)
		if typeId <= 0 then return end
		self.miniworkMyTypeSubType = typeId;
	end,

	--准备进行上报统计，将每一个模块的统计都区分出来单独逻辑处理，用到的参数已经提前设置好了
	TryReportMapDownload = function(self,owid,supportlang)
		if self.mainFrameName == ReportDefine.frameDefine.FriendFrame then
			self:ReportFriendMapDownload(owid,tostring(supportlang));
		elseif self.mainFrameName == ReportDefine.frameDefine.MiniWorkFrame then
			self:ReportMiniworkMapDownload(owid,tostring(supportlang));
		elseif self.mainFrameName == ReportDefine.frameDefine.RoomFrame then
			self:ReportRoomMapDownload(owid,tostring(supportlang));
		else
			self:ReportPlayerCenterMapDownload(owid,tostring(supportlang));
		end
	end,

	ReportPlayerCenterMapDownload = function(self,owid,supportlang)
		if self.playerCenterType == ReportDefine.PlayerCenterDefine.Oneself then
			--Log("下载地图埋点测试".."自己个人中心")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",1, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 1)
		elseif self.playerCenterType == ReportDefine.PlayerCenterDefine.Others then
			--Log("下载地图埋点测试".."他人个人中心")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",2, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 2)
		end
	end,

	ReportFriendMapDownload = function(self,owid,supportlang)
		if self.friendTabId == ReportDefine.friendDefine.AddFriend then
			--Log("下载地图埋点测试".."加好友")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",3,"%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 3)
		elseif self.friendTabId == ReportDefine.friendDefine.Attention then
			--Log("下载地图埋点测试".."关注")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",4, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 4)
		elseif self.friendTabId == ReportDefine.friendDefine.BlackList then
			--Log("下载地图埋点测试".."黑名单")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",5, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 5)
		elseif self.friendTabId == ReportDefine.friendDefine.Friend then
			--Log("下载地图埋点测试".."好友")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",6, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 6)
		elseif self.friendTabId == ReportDefine.friendDefine.Playmate then
			--Log("下载地图埋点测试".."最近玩伴")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",7, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 7)
		end
	end,

	ReportRoomMapDownload = function(self,owid,supportlang)
		if self.roomType == ReportDefine.roomDefine.Collection then
			--Log("下载地图埋点测试".."收藏")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",8, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 8)
		elseif self.roomType == ReportDefine.roomDefine.DownLoad then
			--Log("下载地图埋点测试".."下载")
			self:ReportRoomMapSubTypeDownload(owid,supportlang);
		elseif self.roomType == ReportDefine.roomDefine.Popular then
			--Log("下载地图埋点测试".."受欢迎")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",10, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 10)
		elseif self.roomType == ReportDefine.roomDefine.Search then
			--Log("下载地图埋点测试".."查找")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",11, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 11)
		end
	end,

	ReportRoomMapSubTypeDownload = function(self,owid,supportlang)
		if self.roomSubType == ReportDefine.roomSubDefine.All then
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",9, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 9)
		elseif self.roomSubType == ReportDefine.roomSubDefine.Adventure then
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",25, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 25)
		elseif self.roomSubType == ReportDefine.roomSubDefine.Battle then
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",26, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 26)
		elseif self.roomSubType == ReportDefine.roomSubDefine.Circuit then
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",27, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 27)
		elseif self.roomSubType == ReportDefine.roomSubDefine.Create then
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",28, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 28)
		elseif self.roomSubType == ReportDefine.roomSubDefine.Decrypt then
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",29, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 29)
		elseif self.roomSubType == ReportDefine.roomSubDefine.Parkour then
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",30, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 30)
		elseif self.roomSubType == ReportDefine.roomSubDefine.Other then
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",31, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 31)
		end

	end,

	ReportMiniworkMapDownload = function(self,owid,supportlang)
		if self.miniworkType == ReportDefine.MiniWorkDefine.HomePage then
			if self.miniworkHomepageSubType ==ReportDefine.MiniWorkHomepageSubDefine.Popular then
				--Log("下载地图埋点测试".."主页".."热门")
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",12, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 12)
			elseif self.miniworkHomepageSubType ==ReportDefine.MiniWorkHomepageSubDefine.Recommend then
				--Log("下载地图埋点测试".."主页".."推荐")
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",13, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 13)
			elseif self.miniworkHomepageSubType ==ReportDefine.MiniWorkHomepageSubDefine.Selected then
				--Log("下载地图埋点测试".."主页".."精选")
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",14, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 14)
			elseif self.miniworkHomepageSubType ==ReportDefine.MiniWorkHomepageSubDefine.Selectiveplay then
				--Log("下载地图埋点测试".."主页".."精选玩法")
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",15, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 15)
			elseif self.miniworkHomepageSubType ==ReportDefine.MiniWorkHomepageSubDefine.Select then--精选推荐首页
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",32, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 32)
			elseif self.miniworkHomepageSubType ==ReportDefine.MiniWorkHomepageSubDefine.Creator then--为你推荐首页
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",33, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 33)
			elseif self.miniworkHomepageSubType ==ReportDefine.MiniWorkHomepageSubDefine.Expect then--鉴赏家推荐首页
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",34, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 34)
			elseif self.miniworkHomepageSubType ==ReportDefine.MiniWorkHomepageSubDefine.Select_Second then--精选推荐二级界面
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",35, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 35)
			elseif self.miniworkHomepageSubType ==ReportDefine.MiniWorkHomepageSubDefine.Creator_Second then--为你推荐二级界面
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",36, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 36)
			elseif self.miniworkHomepageSubType ==ReportDefine.MiniWorkHomepageSubDefine.Expect_Second then--鉴赏家推荐二级界面
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",37, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 37)
			end
		elseif self.miniworkType == ReportDefine.MiniWorkDefine.Map then
			if self.miniworkMapSubType ==ReportDefine.MiniWorkMapSubDefine.Selected then
				--Log("下载地图埋点测试".."地图".."精选")
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",16, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 16)
			elseif self.miniworkMapSubType ==ReportDefine.MiniWorkMapSubDefine.Recommend then
				--Log("下载地图埋点测试".."地图".."推荐")
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",17, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 17)
			elseif self.miniworkMapSubType ==ReportDefine.MiniWorkMapSubDefine.Gameplayer then
				--Log("下载地图埋点测试".."地图".."玩家")
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",18, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 18)
			end
		elseif self.miniworkType == ReportDefine.MiniWorkDefine.Special then
			--Log("下载地图埋点测试".."专题")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",19, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 19)
		elseif self.miniworkType == ReportDefine.MiniWorkDefine.Collection then
			--Log("下载地图埋点测试".."收藏")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",20, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 20)
		elseif self.miniworkType == ReportDefine.MiniWorkDefine.Search then
			--Log("下载地图埋点测试".."查找")
			-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",21, "%lld",owid,"%s",supportlang)
			setDownloadWhere(owid, 21)
		elseif self.miniworkType == ReportDefine.MiniWorkDefine.MyType then
			if self.miniworkMyTypeSubType ==ReportDefine.MiniWorkMytypeSubDefine.Attention then
				--Log("下载地图埋点测试".."我的".."关注")
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",22, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 22)
			elseif self.miniworkMyTypeSubType ==ReportDefine.MiniWorkMytypeSubDefine.MyMap then
				--Log("下载地图埋点测试".."我的".."我的地图")
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",23, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 23)
			elseif self.miniworkMyTypeSubType ==ReportDefine.MiniWorkMytypeSubDefine.Subscribe then
				--Log("下载地图埋点测试".."我的".."订阅")
				-- statisticsGameEvent(62001, "%%lls", "MapDownload","%d",24, "%lld",owid,"%s",supportlang)
				setDownloadWhere(owid, 24)
			end
		end
	end,


}

function PlayerExhibitionCenterFramerCenterLinkBtnClicked()
	local url;
	local env_ = get_game_env();

	local is_developer = g_DeveloperInfo
	local uin =  AccountManager:getUin();
	local developer_number = 0
	if is_developer == nil then
		is_developer = (AccountManager:dev_developer_info(uin) == ErrorCode.OK)
	end
	if is_developer then
		developer_number = 1
	end
	standReportEvent("7", "PERSONAL_INFO_TOP","DeveloperCenter","click",{standby1 = developer_number})
	t_exhibition:NewStandReport("PERSONAL_INFO_TOP", "AuthorCenter","click")
	-- if env_ == 1 then --测试
	-- 	url = "s4_https://kfz-test.mini1.cn/#/home";
	-- else 
	-- 	url = "s4_https://kfz.mini1.cn/#/home"
	-- end
	local tmpUrl = ClientUrl:GetUrlString("HttpsKFZ", "#/home")
	url = "s4_"..tmpUrl
	
	url = url_addParams( url )
	url = string_trim(url) --前面带空格会导致url转换异常
	--url = url .. '&' .. http_getS2Act( "posting");
	local platform = ""
	if ClientMgr.getPlatformStr then
		platform = ClientMgr:getPlatformStr()
	end
	url = url .. "&platform="..platform;
	local conn = _G.container.conn
	if conn and conn.token and conn.token ~= "" then
		url = url .. "&tk=" ..conn.token
	end
	--处理pc版本打开浏览器
	if ClientMgr:isPC() then
		-- if ClientMgr.OpenCommunityProcess then
		-- 	ClientMgr:setPause(true);
		-- 	local ret_ = ClientMgr:OpenCommunityProcess(url, 1);
		-- 	if  ret_ == 1 then
		-- 		g_openBrowserUrlAuth( url, 2);  --外置
		-- 	end
		-- else
			url = url .. '&' .. "openBrowser=1";
			g_openBrowserUrlAuth( url, 1);       --外置
		--end
	else
		url = url .. '&' .. "openBrowser=2";
		g_openBrowserUrlAuth( url, 2);       --内置浏览器
	end
end

function HandlePlayerCenterGoShop()
	getglobal("PlayerExhibitionCenter"):Hide()
end

-- 从商城返回跳转tab栏目
function HandleShopComebackPlayerCenter(param)
	getglobal("PlayerExhibitionCenter"):Show()
	if t_exhibition:isThreeVerOpen() then
		if curClickID then
			ExhibitionLeftTabBtnTemplate_OnClick(curClickID, curTabParas, true)
		else
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabHome, nil, true)
		end
	else
		ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabDynamic)
	end
	if param == "personalImage_setting" then
		GetInst("PlayerCenterManager"):OpenPersonalImageSetting()
	end
end

--跳转云服入口
function MyServer_OnClick()
	NewRoomBtn_OnClick(true)
	getglobal('WorkSpaceDetail'):Hide();
	getglobal("PlayerExhibitionCenter"):Hide()
	GetInst("WorkSpaceInterface"):CloseWorkSpace()

	GetInst("MiniUIManager"):CloseUI("SkinCollect_MainAutoGen",true)
	GetInst("MiniUIManager"):CloseUI("SkinCollect_TopicAutoGen",true)
	GetInst("MiniUIManager"):CloseUI("playerCenterDynamicsAutoGen",true)
end


function PlayerExhibitionCenter_GeniusSubscibeEvents()
	local eventsTab = {
		{name = "RespGetCurGenius", 		callback = PlayerExhibitionCenter_GetCurGeniusCallback},     		--获取天赋信息
		{name = "RespUpgradeGenius", 		callback = PlayerExhibitionCenter_GeniusEquipCallback},     		--激活、升级天赋
		{name = "RespEquipGenius", 			callback = PlayerExhibitionCenter_GeniusDemoutCallback},     		--装备天赋
		{name = "RespDemountGenius", 		callback = PlayerExhibitionCenter_GeniusUpgradeCallback},     		--卸下天赋
	}

	for _, eventInfo in pairs(eventsTab) do
        local eventName = eventInfo.name
        local callback = eventInfo.callback

        if not eventName or not callback then
            return
        end

        SandboxLua.eventDispatcher:CreateEvent(nil, eventName)
        SandboxLua.eventDispatcher:SubscribeEvent (nil, eventName,
            function(context)
                local param = context:GetParamData()
                if not param then
                    return
                end

				--因为该事件目前处理的都是ui更新，所以如果该页面没显示的话，就直接丢弃了
				--后期如果有需要的话 就可以放开
				if not getglobal("PlayerExhibitionCenter"):IsShown() then
					return
				end

                return callback(param)
            end
        )
    end
end

function PlayerExhibitionCenter_GetCurGeniusCallback(param)
	local code = param.code
	if code ~= ErrorCode.OK then
		return
	end 

	local uin = param.uin
	if uin ~= AccountManager:getUin() then
		return
	end

	PEC_RefreshGeniusShow(t_exhibition.isHost)
end

--天赋装备回调
function PlayerExhibitionCenter_GeniusEquipCallback(param)
	local code = param.code
	if code == ErrorCode.OK then
		PEC_RefreshGeniusShow(t_exhibition.isHost)
	end
end

--天赋卸下回调
function PlayerExhibitionCenter_GeniusDemoutCallback(param)
	local code = param.code
	if code == ErrorCode.OK then
		PEC_RefreshGeniusShow(t_exhibition.isHost)
	end
end

--天赋激活\升级回调
function PlayerExhibitionCenter_GeniusUpgradeCallback(param)
	local code = param.code
	if code == ErrorCode.OK then
		PEC_RefreshGeniusShow(t_exhibition.isHost)
	end
end




----------------------------------------第三版-------------------------------------------------
function PlayerExhibitionCenterMedalFrame_MoreMetalBt_OnClick()
	getglobal("NewPlayerCenterMedalView"):Show()
end

function NewPlayerCenterMedalView_OnShow()
	AchievementData.achieveMgr:NotifyEvent(AchievementDefine.ShowAchievementPopPanel);
end

-- C++ 层调用  
--个人中心首页勋章列表
function PlayerExhibitionCenterMedalFrameListView_tableCellAtIndex(tableview, idx)
    return PEC_AchievementNewPanel:TableCellAtIndex(tableview, idx)
end

function PlayerExhibitionCenterMedalFrameListView_numberOfCellsInTableView(tableview)
    return PEC_AchievementNewPanel:NumberOfCellsInTableView(tableview)
end

function PlayerExhibitionCenterMedalFrameListView_tableCellSizeForIndex(tableview, idx)
    return PEC_AchievementNewPanel:TableCellSizeForIndex(tableview, idx)
end

function PlayerExhibitionCenterMedalFrameListView_tableCellWillRecycle(tableview, cell)
	PEC_AchievementNewPanel:TableCellWillRecycle(tableview, cell)
end

--个人中心弹框勋章列表
function NewPlayerCenterMedalViewListView_tableCellAtIndex(tableview, idx)
    return PEC_AchievementNewPanel:TableCellAtIndex(tableview, idx)
end

function NewPlayerCenterMedalViewListView_numberOfCellsInTableView(tableview)
    return PEC_AchievementNewPanel:NumberOfCellsInTableView(tableview)
end

function NewPlayerCenterMedalViewListView_tableCellSizeForIndex(tableview, idx)
    return PEC_AchievementNewPanel:TableCellSizeForIndex(tableview, idx)
end

function NewPlayerCenterMedalViewListView_tableCellWillRecycle(tableview, cell)
    PEC_AchievementNewPanel:TableCellWillRecycle(tableview, cell)
end

--IP地址Tip点击
function PlayerExhibitionCenter_IPAddress_OnClick()
	if getglobal("PlayerExhibitionCenterIPAddressFrameContent"):IsShown() then
		getglobal("PlayerExhibitionCenterIPAddressFrameContent"):Hide()
	else	
		getglobal("PlayerExhibitionCenterIPAddressFrameContent"):Show()
	end
end

--显示IP归属地
function PlayerExhibitionCenter_ShowIPAddress(ipaddress,uin)
	if uin == AccountManager:getUin() then
		getglobal("PlayerExhibitionCenterIPAddressFrameTipsBtn"):Show()
	else
		getglobal("PlayerExhibitionCenterIPAddressFrameTipsBtn"):Hide()
	end
	getglobal("PlayerExhibitionCenterIPAddressFrameIPAddressText"):Show()
	if ipaddress == "" then
		ipaddress = GetS(4896)
	end
	getglobal("PlayerExhibitionCenterIPAddressFrameIPAddressText"):SetText(GetS(9200102,ipaddress))
end

--获取IP地址
function PlayerExhibitionCenter_GetIPAdress(_uin)
	if _uin == nil then return end
	if ns_version.ip_home and check_apiid_ver_conditions(ns_version.ip_home) then
		local url = g_http_root .. 'miniw/user_ext?act=get_user_addr&op_uin=' .. _uin .. '&' .. http_getS1Map(true)
		local callback = function(ret)
			print("get_user_addr ",ret)
			if ret and ret.result and ret.result == 0 and ret.msg and ret.msg.addr then
				PlayerExhibitionCenter_ShowIPAddress(ret.msg.addr,_uin)
			else
				PlayerExhibitionCenter_ShowIPAddress(GetS(4896),_uin)
			end
		end
		ns_http.func.rpc(url, callback, nil, nil, true)
	else
		getglobal("PlayerExhibitionCenterIPAddressFrameTipsBtn"):Hide()
		getglobal("PlayerExhibitionCenterIPAddressFrameIPAddressText"):Hide()
	end
end

--设置IPtips显示层级
function PlayerExhibitionCenter_SetIPAddressFrameLevel(ID,defineTabIDs)
	if ns_version.ip_home and check_apiid_ver_conditions(ns_version.ip_home) then
		if getglobal("PlayerExhibitionCenterIPAddressFrameContent"):IsShown() then
			getglobal("PlayerExhibitionCenterIPAddressFrameContent"):Hide()
		end
		if ID == defineTabIDs.tabWareHouse or ID == defineTabIDs.tabDressGallery then
			getglobal("PlayerExhibitionCenterIPAddressFrameContent"):SetFrameLevel(1000)
			getglobal("PlayerExhibitionCenterIPAddressFrameTipsBtn"):SetFrameLevel(1000)
		elseif  ID == defineTabIDs.tabMap or ID == defineTabIDs.tabHome then
			getglobal("PlayerExhibitionCenterIPAddressFrameContent"):SetFrameLevel(3100)
			getglobal("PlayerExhibitionCenterIPAddressFrameTipsBtn"):SetFrameLevel(2550)
		else
			getglobal("PlayerExhibitionCenterIPAddressFrameContent"):SetFrameLevel(3100)
			getglobal("PlayerExhibitionCenterIPAddressFrameTipsBtn"):SetFrameLevel(3100)
		end
	end
end

function ExhibitionMapFramePage1_standReportItem(id,map,reportVal)
	if IsLookSelf() then
		if t_exhibitionMap.curSelectTab == 1 then
			standReportEvent("7", "MY_WORKS", "MapCard", reportVal,{slot=tostring(id),cid=tostring(map.owid),ctype=GetInst("ReportGameDataManager"):GetCtypeDefine().ctypeMap})
		elseif t_exhibitionMap.curSelectTab == 2 then
			standReportEvent("7", "MY_FAVORITES", "MapCard", reportVal,{slot=tostring(id),cid=tostring(map.owid),ctype=GetInst("ReportGameDataManager"):GetCtypeDefine().ctypeMap})
		elseif t_exhibitionMap.curSelectTab == 3 then
			standReportEvent("7", "APPRAISAL", "MapCard", reportVal,{slot=tostring(id),cid=tostring(map.owid),ctype=GetInst("ReportGameDataManager"):GetCtypeDefine().ctypeMap})
		end
	else
		if t_exhibitionMap.curSelectTab == 1 then
			standReportEvent("43", "PLAYER_WORKS", "MapCard", reportVal,{slot=tostring(id),cid=tostring(map.owid),ctype=GetInst("ReportGameDataManager"):GetCtypeDefine().ctypeMap})
		elseif t_exhibitionMap.curSelectTab == 2 then
			standReportEvent("43", "PLAYER_FAVORITES", "MapCard", reportVal,{slot=tostring(id),cid=tostring(map.owid),ctype=GetInst("ReportGameDataManager"):GetCtypeDefine().ctypeMap})
		elseif t_exhibitionMap.curSelectTab == 3 then
			standReportEvent("43", "APPRAISAL", "MapCard", reportVal,{slot=tostring(id),cid=tostring(map.owid),ctype=GetInst("ReportGameDataManager"):GetCtypeDefine().ctypeMap})
		end
	end
end

function PlayerExhibitionCenter_SendGiftBtn_OnClick()
	local inst = GetInst("FriendGiftDataMgr")
	if not inst then
		return
	end

	if t_exhibition.uin == AccountManager:getUin() then
		standReportEvent("7", "PERSONAL_INFO_HOMEPAGE", "GiveGIft", "click")
		inst:OpenGiftUI(t_exhibition.uin, 1, 1)

	else
		standReportEvent("43", "PLAYER_INFO_HOMEPAGE", "GiveGIft", "click", {standby1 = t_exhibition.uin})
		inst:OpenGiftUI(t_exhibition.uin, 1, 2)

	end
end

function PEC_RefreshCharmNum()
	local uiName 			= t_exhibition:getUiName()
	local ui_charmNum 		= getglobal(uiName.."CharmNumFont2");
	ui_charmNum:SetText("0")
	threadpool:work(function()
	
		local ret = GetInst("FriendGiftDataMgr"):ReqData(t_exhibition.uin)
		if ret.ret == 0 then
			ui_charmNum:SetText(PEC_ConvertNumber(ret.data.charm_value))
		end
	end)
end

