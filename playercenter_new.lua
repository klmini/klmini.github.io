
local m_NewPlayerCenterParam = {
	m_bIsNew = true;			--是否打开新版个人中心
};

local settingPage3Name = "PlayerCenterDataEditPage3";

local permissionStateTextName = {
	[settingPage3Name+"LocateStatusText"] = DevicePermission_Location, -- 定位
	[settingPage3Name+"AlbumStatusText"]  =DevicePermission_WriteExternalStorage, --相册
	[settingPage3Name+"CameraStatusText"] = DevicePermission_Camera,  --相机
	[settingPage3Name+"ContactStatusText"] = DevicePermission_Contacts,  --通讯录
	[settingPage3Name+"MicrophoneStatusText"] = DevicePermission_MicroPhone, --麦克风
	[settingPage3Name+"CalendarStatusText"] = DevicePermission_Calendar,	-- 日历
}

local permissionUIName = {
	[1]="PlayerCenterDataEditPage3Locate", -- 定位
	[2]="PlayerCenterDataEditPage3Album", --相册
	[3]="PlayerCenterDataEditPage3Camera",  --相机
	[4]="PlayerCenterDataEditPage3Contact",  --通讯录
	[5]="PlayerCenterDataEditPage3Microphone", --麦克风
	[6]="PlayerCenterDataEditPage3Calendar",	-- 日历
	[7]="PlayerCenterDataEditPage3Recommend",	-- 个性化推荐
	[8]="PlayerCenterDataEditPage3BestPartner",	-- 最佳拍档
}


-- 隐私权限
local m_permissionIdx = {
	locate 		= 1,  --定位
	album 		= 2,  --相册
	camera 		= 3,  --摄像头
	contact 	= 4,  --通讯录
	microphone 	= 5,  --麦克风
	calendar 	= 6,  --日历
	recommend 	= 7,  --个性化推荐
	bestpartner = 8, --最佳拍档
}


local m_permissionTitle = {
	GetS(1000614),-- 	"为什么需要获取我的定位权限？",
	GetS(1000615),-- 	"为什么需要获取我的相册权限？",
	GetS(1000616),-- 	"为什么需要获取我的摄像头权限？",
	GetS(1000617),-- 	"为什么需要获取我的通讯录权限？",
	GetS(1000618),-- 	"为什么需要获取我的麦克风权限？",
	GetS(1000619),-- 	"为什么需要获取我的日历权限？",
}

local m_permissionContent = {
	GetS(1000623),
	GetS(1000624),
	GetS(1000625),
	GetS(1000626),
	GetS(1000627),
	GetS(1000628),
	GetS(1000629),
}

local m_emojis = {
	{code='#A106', icon='face1.png', 	anim = 100166, effect = "anim_100166"},	--亲亲, 100166
	{code='#A101', icon='face2.png', 	anim = 100167, effect = "anim_100167"},	--坏笑, 100167
	{code='#A104', icon='face3.png', 	anim = 100168, effect = "anim_100168"},	--尴尬, 100168
	{code='#A102', icon='face4.png', 	anim = 100169, effect = "anim_100169"},	--发呆, 100169,?
	{code='#A103', icon='face5.png', 	anim = 100158, effect = "anim_100158"},	--生气, 100158
	{code='#A105', icon='face6.png', 	anim = 100159, effect = "anim_100159"},	--哭泣, 100159

	{code='#A107', icon='xihuan.png', 	anim = 100171, effect = "anim_100171"},
	{code='#A108', icon='wabikong.png', anim = 100172, effect = "anim_100172"},
	{code='#A109', icon='dianzan.png', 	anim = 100173, effect = "anim_100173"},
	{code='#A110', icon='haixiu.png', 	anim = 100174, effect = "anim_100174"},
	{code='#A111', icon='liulei.png', 	anim = 100175, effect = "anim_100175"},
	{code='#A112', icon='keai.png', 	anim = 100176, effect = "anim_100176"},
	{code='#A113', icon='shouqibao.png', anim = 100177, effect = "anim_100177"},
	{code='#A114', icon='kun.png', 		anim = 100178, effect = "anim_100178"},
	{code='#A115', icon='jingya.png', 	anim = 100179, effect = "anim_100179"},
	{code='#A116', icon='yun.png', 		anim = 100180, effect = "anim_100180"},
	{code='#A117', icon='shaojiao.png', anim = 100181, effect = "anim_100181"},
	{code='#A118', icon='bye.png', 		anim = 100182, effect = "anim_100182"},
	{code='#A100', icon='face6.png', 	anim = 100108},	--空表情(100108:商城展示动作)

	callback = nil;
};

g_heads_frame_config     = nil;
g_heads_frame_config_map = nil;

g_picType = 0;  --上传图片类型 0：失败 1：png 2：gif


--[[------------------------------------------------------------------------------------
函数名: OpenNewPlayerCenter(playerUin)
功  能: 打开新个人中心
参  数: playerUin: 要访问的用户uin; lastFrame:上一个页面
--]]------------------------------------------------------------------------------------

--注释：NewPlayerCenterFrameCloseBtn_OnClick已经没有被调用了 lastFrame 没作用了，所以对于ArchiveInfoFrameEx的特殊处理移动到外部处理
function OpenNewPlayerCenter(playerUin,from,ThemeNum)
	if threadpool.running then
		__IN_OpenNewPlayerCenter(playerUin,from,ThemeNum)
	else
		threadpool:work(function()
			__IN_OpenNewPlayerCenter(playerUin,from,ThemeNum)
		end)
	end
end

function __IN_OpenNewPlayerCenter(playerUin,from,ThemeNum)
	print("OpenNewPlayerCenter:");
	EnterMainMenuInfo.PlayerCenterBackInfo = {
		uin = playerUin,
		from = from,
		ThemeNum = ThemeNum,
	}
	PlayerCenterFrame_setTarget(playerUin);

	if m_NewPlayerCenterParam.m_bIsNew then
		t_exhibition:parseSwitch()
		t_exhibition.init(playerUin);
		ResetMapArchiveListRoleView()
		getglobal("PlayerExhibitionCenter"):Show();
		if getglobal("MiniLobbyFrameTopRoleInfoHeadMsgCount"):IsShown() then
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabDynamic,{tab = 4},true);
		else
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabHome,nil,true);		--默认切到主页页标签
		end
		--IP归属地
		PlayerExhibitionCenter_GetIPAdress(playerUin)

		--游戏中调出界面时，显示鼠标
		if ClientCurGame:isInGame() and not ClientCurGame:isOperateUI() then
			ClientCurGame:setOperateUI(true);
		end
	else
		-- 第一版本
		getglobal("PlayerCenterFrame"):Show();
	end
	
	if from then
		if from == 'mobpush_personal_medal' then
			getglobal("NewPlayerCenterMedalView"):Show()
		elseif from == 'mobpush_personal_map' then
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabMap);
		elseif from == 'mobpush_personal_update' then
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabDynamic);
		elseif from == 'mobpush_personal_warehouse' then
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabWareHouse);
		elseif from == 'mobpush_personal_dress' then
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabMiniShow);
		elseif from == 'mobpush_personal_friend_map' then
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabMap);
		elseif from == 'mobpush_personal_friend_update' then
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabDynamic);
		elseif from == 'mobpush_personal_friend_dress' then
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabMiniShow);
		elseif from == 'mobpush_personal_dress_gallery' then
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabDressGallery,nil,nil,ThemeNum or 0);
		end
	end
end

function NewPlayerCenterFrameCloseBtn_OnClick()
	getglobal("NewPlayerCenterFrame"):Hide();
end

---------------------------------------------------------帖子回复红点------------------------------------------------------------
--监听事件, 是否帖子有回复, 有则显示红点
local m_ZoneIsPostingRedTagShow = false;
function OnPostingMsg( msg_ )
	print("OnPostingMsg:");
	ZoneSetPostingRedTagState(false, true);
end

function ZoneSetPostingRedTagState(bIsInit, bNeedShow)
	--bIsInit: 是否是初始化, 即打开游戏, 根据getkv的值初始化红点状态.
	print("ZoneSetPostingRedTagState:");
	local k = "zone_postredtag";

	if bIsInit then
		print("Init:");
		bNeedShow = getkv(k, k);
	else
		print("not Init:");
	end

	if bNeedShow then
		print("111:");
		setkv(k, true, k);
		-- getglobal("MiniLobbyFrameTopRoleInfoHeadPostingRedTag"):Show();
		ShowMiniLobbyHeadPostingRedTag(0) --mark by hfb for new minilobby
		--getglobal("ExhibitionInfoTab2PostingRedTag"):Show();
		--getglobal("ExhibitionInfoMorePostingRedTag"):Show();
		getglobal("PlayerExhibitionCenterLeftTabBtn3RedTag"):Show();
		m_ZoneIsPostingRedTagShow = true;

		GetInst("PlayerCenterDynamicsManager"):GetRedPoint()
	else
		print("222:");
		setkv(k, false, k);
		-- getglobal("MiniLobbyFrameTopRoleInfoHeadPostingRedTag"):Hide();
		HideMiniLobbyHeadPostingRedTag(0) --mark by hfb for new minilobby
		--getglobal("ExhibitionInfoTab2PostingRedTag"):Hide();
		--getglobal("ExhibitionInfoMorePostingRedTag"):Hide();
		getglobal("PlayerExhibitionCenterLeftTabBtn3RedTag"):Hide();
		m_ZoneIsPostingRedTagShow = false;
	end
end

function ZoneGetPostingRedTagState()
	print("ZoneGetPostingRedTagState:");
	print(m_ZoneIsPostingRedTagShow);
	return m_ZoneIsPostingRedTagShow;
end

----------------------------------------新版的部分逻辑-----------------------------------------------------------------------------
local m_ExhibitionCenter = {};

--动态子页面的相关功能
function ExhibitionInfoPage2_OnLoad()
	print("ExhibitionInfoPage2_OnLoad:");
end

function CreateDynamicItemsByTemplate()
	print("CreateDynamicItemsByTemplate:");
	--朋友圈条目:动态创建N个
	local list = {
		{	--1. 朋友圈
			singleH = 137,
			boxH = 502,
			createCount = 200,
			type_name = "Button",
			template_name = "FriendDynamicTemplate";
			parent_name = "ExhibitionInfoPage2CommentSlider";
			planeUI = "ExhibitionInfoPage2CommentSliderPlane";
			firstName = "ExhibitionInfoPage2CommentSliderCell",
		},
		{	--2. 我的动态
			singleH = 137,
			boxH = 502,
			createCount = 200,
			type_name = "Button",
			template_name = "MyDynamicTemplate";
			parent_name = "MyDynamicBox";
			planeUI = "MyDynamicBoxPlane";
			firstName = "MyDynamicBoxCell",
		},
		{	--3. 最近回复
			singleH = 137,
			boxH = 502,
			createCount = 200,
			type_name = "Button",
			template_name = "LatestDynamicTemplate";
			parent_name = "LatestDynamicBox";
			planeUI = "LatestDynamicBoxPlane";
			firstName = "LatestDynamicBoxCell",
		},
		{	--4. 详情页评论:TODO:最近回复看不到, 需要再调整.
			singleH = 100,
			boxH = 405,
			createCount = 200,
			type_name = "Button",
			template_name = "FriendDynamicReplyTemplate";
			parent_name = "FriendDynamicFrameReplyBox";
			planeUI = "FriendDynamicFrameReplyBoxPlane";
			firstName = "FriendDynamicFrameReplyBoxItem",
		},
	};

	local y = 0;
	local planeUI = "";

	for i = 1, #list do
		local list_node = list[i];
		local planeUI = list_node.planeUI;
		local plane = getglobal(planeUI);
		local createCount = list_node.createCount;


		for i = 1, createCount do    
			local name = list_node.firstName .. i;
			local item = UIFrameMgr:CreateFrameByTemplate(list_node.type_name, name, list_node.template_name, list_node.parent_name);

			if item then
				item:Hide();
				item:SetHeight(list_node.singleH);
				--item:SetPoint("top", planeUI, "top", 0, y);
				item:SetClientID(i);
				y = y + list_node.singleH;
			end
		end

		y = math.max(y, 465);
		plane:SetHeight(y);
	end
end

function ExhibitionInfoPage2_OnShow()
	--控制更多按钮的显示逻辑放在了PEC_ExhibitionTabState(index)中



	-- print("ExhibitionInfoPage2_OnShow:");

	-- --获取表
	-- m_ExhibitionCenter = GetExhibitionCenter();

	-- local moreBtnUI = "ExhibitionInfoMore";
	-- local moreBtn = getglobal(moreBtnUI);
	-- local moreBtnNormal = getglobal(moreBtnUI .. "Normal");

	-- if  IsLookSelf() then
	-- 	moreBtn:Show();
	-- 	moreBtn:SetSize(104, 104);
	-- 	moreBtnNormal:SetTexUV("grzx_icon_edit");
	-- else
	-- 	moreBtn:Hide();
	-- end
end

function ExhibitionInfoPage2_OnHide()
	-- print("ExhibitionInfoPage2_OnHide:");

	-- local moreBtnUI = "ExhibitionInfoMore";
	-- local moreBtn = getglobal(moreBtnUI);
	-- local moreBtnNormal = getglobal(moreBtnUI .. "Normal");

	-- moreBtn:SetSize(102, 116);
	-- moreBtnNormal:SetTexUV("grzx_icon_more");
end

--更多按钮: 发布动态
function ExhibitionInfoPage2MoreBtn_OnClick()
	print("ExhibitionInfoPage2_MoreBtn_OnClick:");
	if checkSafetyModifyRef and not checkSafetyModifyRef() then
		return
	end

	if GetInst("CreditScoreService"):CheckLimitAction(GetInst("CreditScoreService"):GetTypeTbl().dynamic, GetInst("CreditScoreService"):GetSubTypeTbl().player_dynamic) then
        return	
    end

	if false == AccountSafetyCheck:FunCheck(AccountSafetyCheck.FunType.DYNAMIC_PUBLISH, ExhibitionInfoPage2MoreBtn_OnClick) then
		return
	end

	--ShareToDynamic:Init();
	-- if ns_data.IsGameFunctionProhibited("p", 10585, 10586) then
	-- 	return
	-- end
	standReportEvent("7", "PERSONAL_INFO_UPDATES", "SendUpdatesButton", "click")
	getglobal("DynamicPublishFrame"):Show();
end

-------------------------------------动态发布页面--------------------------------------------------------------------------
local m_ZoneStoreData = {
	--保存第一个用户的空间的数据(用于空间嵌套跳转是回到最初状态)
	rootData = {
		bIsRoot = true,					--是否是根空间, 如果不是根空间, 退出空间是需要重新打开根空间.
		bNeedRestoreData = false,		--是否需要恢复数据
		bIsClickCloseBtn = false,		--是否是点击close按钮, 只有是点击close按钮才判断是否退回根空间
	};
};

local m_ZoneDynamicMgrParam = {
	--每打开一次空间, 第一次切到动态页的时候拉取数据，避免频繁拉取
	needPull = true,		--是否需要拉取朋友圈
	needPullMyList = true,	--是否需要拉取"我的动态"
	needPullLatest = true,
	uin = 0,				--访问的空间的uin
	curDynamicIndex = 1,	--当前点击的动态
	curDynamicDetail = {},	--当前动态详情数据
	curCommentList = {},	--当前动态的评论的详情
	curLastCommentCT = 0,	--最后一条评论的时间, 0表示拉取第一个20条, 非零表示接着拉后面的, -1表示全部拉完了不要再继续拉了
	curFriendCircleCT = 0,	--最后一条朋友圈的时间.
	curMyListCT = 0,		--最后一条"我的动态"的时间
	curLatestCT = 0,		--最近回复时间
	bNeedSetCommentBottom = false,--是否需要将评论列表拉到最底部(评论成功后, 该条评论在最后面, 方便查看)
	curReplyIndex = 0,		--当前恢复的目标, 0:回复本尊;	1, 2 .. n: 评论的索引, 回复对应索引的人.
	curPicCount = 0,		--当前发表的图片数量
	curLink = nil,          --当前分享的链接
	curLinkTitle = nil,		--当前分享链接得标题
	curPicSeatUsed = {false, false, false}, --当前图片的坑位使用情况
	bIsPublishing = false,	--是否正在发布动态
	UploadedPicCount = 0,	--已上传完成数量
	bIsMainPageDirty = true,
	bIsMyPageDirty = true,
	bIsLatestPageDirty = true,

	CircleList = {},		--朋友圈动态列表
	MyDataList = {},		--我的动态列表
	LatestList = {},		--最近回复列表
	WhiteList = {},			--动态发布GIF图，链接，官方动态角标白名单

	DataList = {},			--指向上面的两个之一
	curPullType = 1,		--动态详情页中, 指示当前类型

	curFrame = "",			--详情页:FriendDynamicFrame, 我的动态页: DynamicHandleFrame, 主页: "ZoneMainPage"

	SensitiveWordShieldingPicPath = "ui/snap_jubao.png", --敏感词被屏蔽后显示的默认图片

	SensitiveWordWhiteList = { [1000] = 1, [1000001000] = 1, [1001] = 1, [1000001001] = 1, [1002] = 1, [1000001002] = 1,},--不会过滤敏感词的uin列表

	DomesticPublishWhiteList = { [1000] = 1, [1101] = 1, [1102] = 1, [1109] = 1, [2315] = 1, [1103] = 1,},--国内官方动态角标显示名单

	OverseasPublishWhiteList = { [1000001000] = 1, },--海外官方动态角标显示名单
	
	myCommentList = {}, --特殊时期特殊处理的东西 TODO 后面要处理掉
	--[[
	DataList = {
		list = {
			{content = "你好", pid="111_222"},
			{},
		},

		role_info_list = {
			[uin1] = {head_id = 1, NickName = "小菜鸟", uin=204507528},
			[uin2] = {},
		},
	},
	]]

	Init = function(self, _uin)
		--打开个人中心的时候调用
		print("Init:uin = " .. _uin);
		self.curDynamicDetail = {};
		self.curCommentList = {};
		self.curDynamicIndex = 1;
		self.curLastCommentCT = 0;
		self.curFriendCircleCT = 0;
		self.curMyListCT = 0;
		self.curLatestCT = 0;

		self.curLink = nil;
		self.curReplyIndex = 0;
		self.curPicCount = 0;
		self.curPicSeatUsed = {false, false, false};
		self.bNeedSetCommentBottom = false;
		self.needPull = true;
		self.needPullMyList = true;
		self.needPullLatest = true;
		self.bIsMainPageDirty = true;
		self.bIsMyPageDirty = true;
		self.curPullType = 1;
		self.CircleList = {};
		self.MyDataList = {};
		self.uin = _uin;
		self.selectPullType = 1;

		--判断是不是海外服
		self.WhiteList = self.DomesticPublishWhiteList
		local env = ClientMgr:getGameData("game_env")
		if env == 10 or env > 10 then
			self.WhiteList = self.OverseasPublishWhiteList
		end

		--隐藏左右条目
		self:IninCellList("ExhibitionInfoPage2CommentSliderCell");
		self:IninCellList("MyDynamicBoxCell");
		self:IninCellList("LatestDynamicBoxCell");

		--恢复数据
		self:ReStoreRootData();
		GetInst("SkinCollectManager"):ReStoreViewData();

		--朋友圈列表重置到开始
		getglobal("ExhibitionInfoPage2CommentSlider"):resetOffsetPos();
		getglobal("MyDynamicBox"):resetOffsetPos();
		getglobal("LatestDynamicBox"):resetOffsetPos();
	end,

	InitPublishFrame = function(self)
		--初始化发布页面
		print("InitPublishFrame:");
		self.curPicCount = 0;
		self.curLink = nil;
		self.curLinkTitle = nil;
		self.curPicSeatUsed = {false, false, false};
		self.UploadedPicCount = 0;
		self.bIsUploadingPic = false;

		for i = 1, 3 do
			getglobal("DynamicPublishFrameDynamicPic" .. i):Hide();
			getglobal("DynamicPublishFrameDynamicPic" .. i .. "Del"):Hide();
		end
		getglobal("DynamicPublishFrameDynamicLink"):Hide(); 

		if ShareToDynamic.isShareDynamic then
			ShareToDynamic:AddPicture();
		end

		--上传图片开关
		print("ns_version.posting_pic = ", ns_version.posting_pic);
		-- print(ns_version);
		local picBtn = getglobal("DynamicPublishFrameInsertPicBtn");
		picBtn:Hide();
		if ns_version and check_apiid_ver_conditions(ns_version.posting_pic, false) then
			print("上传图片开关:");
			picBtn:Show();
		end
		ZoneDynamicInsertPicBtnPos()
		--上传链接开关

		local linkBtn = getglobal("DynamicPublishFrameInsertLinkBtn");
		linkBtn:Hide();
		if ns_version and check_apiid_ver_conditions(ns_version.posting_link, false) then
			print("上传链接开关:");
			linkBtn:Show();
		end
		
	end,

	PushDynamic = function(self)
		print("PushDynamic:");
		local content = getglobal("DynamicPublishFrameTextEdit"):GetText() or "";
		if CheckFilterString(content) then
			return;
		end

		if content == nil or content == "" then
			--请输入内容
			ShowGameTips(GetS(20562));
			ShowLoadLoopFrame(false)
			return;
		end

		-- if string.len(content) < 3 then
		-- 	--至少输入三个字符
		-- 	ShowGameTips("至少输入三个字符", 3);
		-- 	ShowLoadLoopFrame(false)
		-- 	-- ShowGameTips(GetS(20562));
		-- 	return;
		-- end

		content = escape(content);

		if  ns_version and ns_version.proxy_url then
			print("ns_version.proxy_url = " .. ns_version.proxy_url);
		else
			--ip配置文件拉取失败
			ShowGameTips(GetS(20561));
			return;
		end

		local callback = function(ret)
			print("callback:", ret);
			ShowLoadLoopFrame(false)
			getglobal("DynamicPublishFrame"):Hide();
			getglobal("DynamicPublishFrameTextEdit"):Clear();
			getglobal("DynamicLinkEditFrameLinkEdit"):Clear();
			getglobal("DynamicLinkEditFrameTitleEdit"):Clear();
			getglobal("DynamicPublishFrameCommitBtn"):Enable();
			t_share_data:ShowNextRewardDisplay();

			if not ret then
				ShowGameTips(GetS(20561) .. ", ret is nil");
				return
			end

			if ret and ret.ret == 0 then
				print("发表成功");
				if IsOverseasVer() or isAbroadEvn() then 
					ShowGameTips(GetS(20667), 3)
				else
					ShowGameTips(GetS(20591), 3);
				end
				print(ret);
				self.needPull = true;
				self.needPullLatest = true;
				self.needPullMyList = true;
				self.bIsMainPageDirty = true;
				self.bIsMyPageDirty = true;
				self.bIsLatestPageDirty = true;
				self.curFriendCircleCT = 0;
				self.curMyListCT = 0;
				self.curLatestCT = 0;
				self.CircleList = {};
				self.MyDataList = {};
				self.LatestList = {};
				self.DataList = {};
				self:PullDyanmicList(1);
				getglobal("ExhibitionInfoPage2CommentSlider"):resetOffsetPos();
				NewBattlePassEventOnTrigger("publish");
				--更新分享数量
				if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx") then
					GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):ShareSuccess()
				end
			else
				if ret.ret == 9 then --黑词校验失败 服务器聚合检测
					ShowGameTips(GetS(121) .. "(" .. ret.ret .. ")", 3)
				elseif ret.ret == 21 then --实名校验失败
					ShowGameTips(GetS(22037) .. "(" .. ret.ret .. ")", 3)
				elseif ret.ret == 22 then --手机号 
					ShowGameTipsWithoutFilter(GetS(10643) .. "(" .. ret.ret .. ")", 3)
				elseif ret.ret == 20 then --验证码 校验失败
					ShowGameTipsWithoutFilter(GetS(100218) .. "(" .. ret.ret .. ")", 3)
				elseif ret.ret == 1 then --请求频率的限制
					ShowGameTipsWithoutFilter(GetS(3306), 3)
				elseif ret.ret == 5 and ret.black_time then --黑名单时间限制
					local limitDate = os.date("%Y-%m-%d %H:%M", ret.black_time) or 0
					ShowGameTipsWithoutFilter(GetS(10585,limitDate), 3)
				elseif ret.ret then
					--发布失败
					ShowGameTips(GetS(20561) .. "(" .. ret.ret .. ")");
				else
					--发布失败
					ShowGameTips(GetS(20561));
				end
			end
		end

		local seq = "";
		if self.curPicCount == 1 then
			seq = "1"
		elseif self.curPicCount == 2 then
			seq = "1,2";
		elseif self.curPicCount == 3 then
			seq = "1,2,3";
		end

		local action ="";
		local actionParametar = ShareToDynamic.t_actionParameter;
		action = "&action="..actionParametar.action.."&action_url="..actionParametar.action_url .. "&action_title="..actionParametar.action_title;
		--action = "&action=25&action_url=19430636735461&action_title=wokeyi"


		local url = "";
		if self.curPicCount > 0 then
			url = ns_version.proxy_url .. '/miniw/posting?act=add_posting'..action .. "&content=" .. content .. "&seq=" .. seq .. "&" .. http_getS2Act("posting");
		else
			url = ns_version.proxy_url .. '/miniw/posting?act=add_posting'..action .. "&content=" .. content .. "&" .. http_getS2Act("posting");
		end
		url = url .. "&" .. http_getRealNameMobileSum(content)
		url = DynamicFrameUrlAddToken(url)
		print("PushDynamic url", url );

		print( url );
		ns_http.func.rpc( url, callback, nil, nil, true );
	end,

	PullDyanmicList = function(self, nPullType)
		--nPullType: 1: 朋友圈; 2: 我的动态; 3: 最近回复
		local needPull = true;
		local curLastCT = 0;		--最后一条动态的ct
		self.selectPullType = nPullType	

		if nPullType == 2 then
			print("拉取我的动态列表:");
			self.DataList = self.MyDataList;
			needPull = self.needPullMyList;
			curLastCT = self.curMyListCT;
		elseif nPullType == 3 then
			print("拉取最近回复列表:");
			self.DataList = self.LatestList;
			needPull = self.needPullLatest;
			curLastCT = self.curLatestCT;
		else
			print("拉取朋友圈:");
			self.DataList = self.CircleList;
			needPull = self.needPull;
			curLastCT = self.curFriendCircleCT;
		end	

		print("needPull:", needPull);
		print("curLastCT:", curLastCT);

		if needPull and curLastCT ~= -1 then
			if  ns_version and ns_version.proxy_url then
				print("ns_version.proxy_url = " .. ns_version.proxy_url);
			else
				ShowGameTips(GetS(21849));
				return;
			end

			local callback = function(ret)
				print("callback:");
				print(ret);
				if ret and ret.ret == 0 then
					print("获取动态列表成功", nPullType);

					--判断是否有20条, 小于20条表示没有更多了.
					local isOver = false;
					if ret.data and ret.data.list then
						if #(ret.data.list) < 19 then
							isOver = true;
						end
					end

					if nPullType == 2 then
						self.bIsMyPageDirty = true;
						self.needPullMyList = false;
						self.bIsMainPageDirty = true;
						--self.MyDataList = ret.data;

						self.curMyListCT = ret.data.ct or 0;
						if isOver then
							self.curMyListCT = -1;
						end

						--是第一次拉取, 直接赋值并返回
						if curLastCT == 0 then
							print("第一次拉取:");
							self.MyDataList = ret.data;
						end
					elseif nPullType == 3 then
						self.bIsLatestPageDirty = true;
						self.needPullLatest = false;
						-- self.LatestList = ret.data;

						self.curLatestCT = ret.data.ct or 0;
						if isOver then
							self.curLatestCT = -1;
						end
						print("self.curLatestCT = " .. self.curLatestCT);

						--是第一次拉取, 直接赋值并返回
						if curLastCT == 0 then
							print("第一次拉取:");
							self.LatestList = ret.data;
						end
					else
						self.bIsMainPageDirty = true;
						self.needPull = false;
						--self.CircleList = ret.data;

						--记录ct
						self.curFriendCircleCT = ret.data.ct or 0;
						if isOver then
							self.curFriendCircleCT = -1;	----负1表示不要再继续拉了.
						end
						print("self.curFriendCircleCT = " .. self.curFriendCircleCT);

						--是第一次拉取, 直接赋值并返回
						if curLastCT == 0 then
							print("第一次拉取:");
							self.CircleList = ret.data;
						end
					end

					--判断是否重复拉取了
					if curLastCT == ret.data.ct and curLastCT > 0 then
						print("rePullDynamic, return;");
						return;
					end

					--分批拉取(当不是第一次的时候执行-------------------------------------
					if curLastCT > 0 then
						print("不是第一次拉取:");
						if ret.data and ret.data.list then
							local num = 0;
							self.DataList.list = self.DataList.list or {};

							for i = 1, #(ret.data.list) do
								num = num + 1;
								table.insert(self.DataList.list, ret.data.list[i]);
							end
						end

						if ret.data and ret.data.role_info_list then
							self.DataList.role_info_list = self.DataList.role_info_list or {};

							for k, v in pairs(ret.data.role_info_list) do
								if k and v then
									self.DataList.role_info_list[k] = v;
								end
							end
						end
					end
				else
					print("获取动态列表失败");
				end

				--不管拉取成功还是失败都要刷新界面, 因为失败的时候要隐藏所有条目
				if nPullType == 2 then
					if t_exhibition:isLookSelf() then
						self:UpdateMyPage();
					else
						self:UpdateMainPage();
					end
				elseif nPullType == 3 then
					self:UpdateLatelyPage();
				else
					self:UpdateMainPage();
				end

				ShowLoadLoopFrame(false)
			end

			local op_uin = self.uin;
			print("op_uin = " .. op_uin);

			if op_uin > 0 then
				local act = "get_posting_list";
				if t_exhibition:isLookSelf() then
					if nPullType == 2 then
						act = "get_posting_list";
					elseif nPullType == 3 then
						act = "get_reps_list";
					else
						act = "get_friend_posting";
					end
				else
					act = "get_posting_list";
				end

				local url = "";
				-- if nPullType and nPullType == 3 then
				-- 	--最近回复:"&order=lt"
				-- 	url = ns_version.proxy_url .. '/miniw/posting?act=' .. act .. "&op_uin=" .. op_uin .. "&order=lt" .. "&" .. http_getS2Act("posting");
				-- else
				-- 	url = ns_version.proxy_url .. '/miniw/posting?act=' .. act .. "&op_uin=" .. op_uin .. "&" .. http_getS2Act("posting");
				-- end
				url = ns_version.proxy_url .. '/miniw/posting?act=' .. act .. "&op_uin=" .. op_uin .. "&" .. http_getS2Act("posting") .. getFriendRelationReqStr(op_uin);

				if curLastCT > 0 then
					url = url .. "&ct=" .. curLastCT;
				end

				print( url );
				ShowLoadLoopFrame(true, "file:playercenter_new -- func:PullDyanmicList");
				ns_http.func.rpc( url, callback, nil, nil, true );
			end
		end

		if nPullType == 2 then
			if t_exhibition:isLookSelf() then
				self:UpdateMyPage();
			else
				self:UpdateMainPage();
			end
		elseif nPullType == 3 then
			self:UpdateLatelyPage();
		else
			self:UpdateMainPage();
		end

		ShowLoadLoopFrame(false)
	end,

	AddLink = function (self)
		print("AddLink:");
		getglobal("DynamicLinkEditFrame"):Hide();

		self.curLink = getglobal("DynamicLinkEditFrameLinkEdit"):GetText();
		self.curLinkTitle = getglobal("DynamicLinkEditFrameTitleEdit"):GetText();

		local url_ = self.curLink
		--判断是否输入了链接
		if  url_ == "" then
			print("url_=", url);
			ShowGameTips(GetS(21846));
			getglobal("DynamicPublishFrameDynamicLink"):Hide();
			return;
		end
		-- 判断是否输入了标题
		if self.curLinkTitle == "" or self.curLinkTitle == nil then
			ShowGameTips(GetS(21846));
			getglobal("DynamicPublishFrameDynamicLink"):Hide();
			return
		end
		local dynamic_linkText_ = GetS(21848)..url_;

		print("dynamic_linkText_=",dynamic_linkText_);

		local isAction = tonumber(url_);   --设置游戏内分享参数 并判断是游戏内跳转还是外部链接跳转
		if isAction then 
			ShareToDynamic:SetActionParameter(url_);
		else 
			ShareToDynamic:SetActionParameter(99,url_,self.curLinkTitle);
		end

		getglobal("DynamicPublishFrameDynamicLinkCurLink"):SetText(dynamic_linkText_);
		getglobal("DynamicPublishFrameDynamicLink"):Show();
		ShowGameTips(GetS(21847));
	end,

	AddPicture = function(self)
		print("AddPicture:");
		if self.curPicCount >= 3 then
			print("最多传3张图片");
			return;
		end

		--找到一个空的坑位
		local emptySeat = 1;
		for i = 1, 3 do
			if self.curPicSeatUsed[i] then
				--这个坑现在有图片
			else
				emptySeat = i;
				break;
			end
		end

		print("emptySeat = ", emptySeat);

		local index = emptySeat; --self.curPicCount + 1;
		local filename = "dynamic_upload_tmp" .. index .. ".png";

		ns_playercenter.upload_pic_callback = function()
			--设置回调, 选择图片完成, 回调到这里
			print("AddPicture:Successful:");
			local file = g_photo_root .. filename;
			if  gFunc_isStdioFileExist( file ) then
				print("file ok:");
				print(file);
				self.curPicCount = self.curPicCount + 1;
				self.curPicSeatUsed[emptySeat] = true;	--填充坑位
				local picUI = "DynamicPublishFrameDynamicPic" .. index;
				local delUI = "DynamicPublishFrameDynamicPic" .. index .. "Del";
				getglobal(picUI):Show();
				getglobal(delUI):Show();
				getglobal(picUI):ReleaseTexture(file);	--先释放内存中的图片资源
				getglobal(picUI):SetTexture(file);
				-- showPicNoStretch(picUI);
				ZoneDynamicInsertPicBtnPos()
			else
				print("file error:");  			--没有文件，放弃
			end
		end

		--bool showImagePicker(std::string path, int type, bool crop=true);	//type 1相册 2相机
		--判断是否支持上传Gif   false 支持  true 不支持
		local crop = true     
		if ns_version and check_apiid_ver_conditions(ns_version.posting_link, false) then
			crop = false
		end 
		g_picType = ClientMgr:showImagePicker( g_photo_root .. filename, 1 , crop)
		if  g_picType ~= 0  then
			--select ok
			if g_picType == 2 then
				filename = string.sub(filename,0,string.len(filename)-4)
				filename = filename..".gif"
			end
		else
			Log( "showImagePicker = false" );
			ns_playercenter.upload_pic_callback = nil;
		end
	end,

	DeletePic = function(self, id)
		print("DeletePic:id = ", id);
		self.curPicSeatUsed[id] = false;	--释放坑位
		self.curPicCount = self.curPicCount - 1;
		local picUI = "DynamicPublishFrameDynamicPic" .. id;
		local delUI = "DynamicPublishFrameDynamicPic" .. id .. "Del";
		getglobal(picUI):Hide();
		getglobal(delUI):Hide();
	end,

	UploadPicture = function(self, picIndex)
		--picIndex:是第几张图片, 要根据picIndex找到对应的坑位, 坑位的索引跟文件名才是对应的.因为加了删除图片的功能, 所以不能再根据picIndex直接确定文件名.
		--因为有可能picIndex==2时, 就是第二张图片, 放在了第三个坑位, 这时候的文件名是filename3.
		print("UploadPicture:");
		local filenameIndex = 1;
		local seatUsedCount = 0;
		for i = 1, 3 do
			if self.curPicSeatUsed[i] then
				seatUsedCount = seatUsedCount + 1;
				if picIndex == seatUsedCount then
					filenameIndex = i;
					break;
				end
			end
		end

		print("picIndex = ", picIndex, "filenameIndex = ", filenameIndex);

		local callback_pos = function(ret_)
			--请求位置成功
			print("callback_pos:", ret_);
			if ret_ and string.sub( ret_, 1, 3 ) == "ok:" then
				local upload_url_ =  string.sub( ret_, 4 );
				upload_url_ = string_trim( upload_url_ );
				upload_url_ = upload_url_ 
				print( "[" .. upload_url_  .. "]" );
				local callback_up = function(ret, token_)
					--上传成功
					print("callback_up:");
					print(ret);
					print(token_);
					if  ret == 200 then
						print("successful:200:");
						--ok:token=6f8c3d78a2b238bd0e9a259b6c7605a5&node=2&dir=20170415
						if  token_ and  string.sub( token_, 1, 3 ) == "ok:" then
							print("ok:");
							local sub_token_ = string.sub( token_, 4 );
							sub_token_ = string_trim( sub_token_ );
							Log( "[" .. sub_token_  .. "]" );
							local file_path_ = g_photo_root .. "dynamic_upload_tmp" .. filenameIndex;
							local ext = "png"
							if g_picType == 2 then
								file_path_ = file_path_..".gif"
								ext = "gif"
							else
								file_path_ = file_path_..".png"
							end
							local callback_add = function(ret_)
								print("callback_add:", ret_);
								if ret_ and ret_.ret == 0 then
									--4. 设置临时相册成功
									self.UploadedPicCount = self.UploadedPicCount + 1;
									print("self.UploadedPicCount = " .. self.UploadedPicCount);
									if self.UploadedPicCount >= self.curPicCount then
										--全部上传成功, 发布动态
										print("all picture Upload Successful:");
										self:PushDynamic();
									end
								else
									if ret_ == nil or ret_.ret ~= 0 then
										ShowGameTips(GetS(146));
										ShowLoadLoopFrame(false)
									end
								end
							end

							--3. 把图片设置到玩家临时相册
							local md5 = gFunc_getBigFileMd5(file_path_);
							print("file_path_ = " .. file_path_);
							print("md5 = " .. md5);
							local url = ns_version.proxy_url .. '/miniw/posting?act=add_posting_pic' .. "&seq=" .. picIndex .. "&md5=" .. md5 .. "&ext=" .. ext .. "&" .. sub_token_ .. "&" .. http_getS2Act("posting");
							--local url = ns_version.proxy_url .. '/miniw/posting?act=add_posting_pic' .. "&seq=" .. picIndex .. "&md5=" .. md5 .. "&" .. sub_token_ .. "&" .. http_getS2Act("posting");
							ShowLoadLoopFrame(true, "file:playercenter_new -- func:UploadPicture 1");
							ns_http.func.rpc( url, callback_add, nil, nil, true );
						end
					else
						if ret == nil or ret < 0 then
							ShowGameTips(GetS(146));
							ShowLoadLoopFrame(false)
						end
					end
				end

				--2. 请求上传图片
				local filename = g_photo_root .. "dynamic_upload_tmp" .. filenameIndex;
				if g_picType == 2 then
					filename = filename..".gif"
				else
					filename = filename..".png"
				end
				print("filename = " .. filename);
				ShowLoadLoopFrame(true, "file:playercenter_new -- func:UploadPicture 2");
				ns_http.func.upload_md5_file( filename,  upload_url_, callback_up  );
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

	--在缓存中更新Count值避免为了刷新界面重新拉取数据
	UploadCommentCount = function(self,num)
		self.DataList.list[self.curDynamicIndex].comment_count = self.DataList.list[self.curDynamicIndex].comment_count or 0;
		self.DataList.list[self.curDynamicIndex].comment_count = num;
		if t_exhibition:isLookSelf() then
			local Curlist = self.CircleList;
			local Otherlist = self.MyDataList;
			if self.curPullType == 2 then
				Curlist = self.MyDataList;
				Otherlist = self.CircleList;
			elseif self.curPullType == 3 then
				--最近回复特殊处理
				if Curlist and Curlist.list then
					for i, v in pairs(Curlist.list) do
						if v.pid == self.DataList.list[self.curDynamicIndex].pid then
							Curlist.list[i].comment_count = num;
							break;
						end
					end
				end
				if Otherlist and Otherlist.list then
					for i, v in pairs(Otherlist.list) do
						if v.pid == self.DataList.list[self.curDynamicIndex].pid then
							Otherlist.list[i].comment_count = num;
							break;
						end
					end
				end
				return;
			end
			Curlist.list[self.curDynamicIndex].comment_count = num;
			if Otherlist and Otherlist.list then
				for i, v in pairs(Otherlist.list) do
					if v.pid == self.DataList.list[self.curDynamicIndex].pid then
						Otherlist.list[i].comment_count = num;
						break;
					end
				end
			end
		end
	end,

	--删除评论的时候刷新下缓存中的最近回复避免重新拉取数据
	UploadLastComments = function(self,list)
		if self.curPullType ~= 3 then
			self.DataList.list[self.curDynamicIndex].last_comments = self.DataList.list[self.curDynamicIndex].last_comments or {};
			self.DataList.list[self.curDynamicIndex].last_comments = list;
		end
		if t_exhibition:isLookSelf() then
			local Curlist = self.CircleList;
			local Otherlist = self.MyDataList;
			if self.curPullType == 2 then
				Curlist = self.MyDataList;
				Otherlist = self.CircleList;
			elseif self.curPullType == 3 then
				--最近回复特殊处理
				if Curlist and Curlist.list then
					for i, v in pairs(Curlist.list) do
						if v.pid == self.DataList.list[self.curDynamicIndex].pid then
							Curlist.list[i].last_comments = list;
							break;
						end
					end
				end
				if Otherlist and Otherlist.list then
					for i, v in pairs(Otherlist.list) do
						if v.pid == self.DataList.list[self.curDynamicIndex].pid then
							Otherlist.list[i].last_comments = list;
							break;
						end
					end
				end
				return;
			end
			Curlist.list[self.curDynamicIndex].last_comments = list;
			if Otherlist and Otherlist.list then
				for i, v in pairs(Otherlist.list) do
					if v.pid == self.DataList.list[self.curDynamicIndex].pid then
						Otherlist.list[i].last_comments = list;
						break;
					end
				end
			end
		end
	end,

	AddComment = function(self)
		print("AddComment:");
		local content = getglobal("FriendDynamicFrameEditTextEdit"):GetText() or "";
		if CheckFilterString(content) then
			return;
		end

		if self.DataList 
		and self.DataList.list 
		and self.DataList.list[self.curDynamicIndex] then
			local black_stat = self.DataList.list[self.curDynamicIndex].black_stat;
			if black_stat == 1 or black_stat == 2 then 
				ShowGameTipsWithoutFilter(GetS(10574));
				return
			end
		end

		if content == nil or content == "" then
			--请输入内容
			ShowGameTips(GetS(20562));
			return;
		end

		print("content = " .. content);
		--内容前面加上回复对象的昵称
		-- local des_nickname = "";
		local op_uin = 0;

		if self.curReplyIndex == 0 then
			--直接回复帖子, 即1级回复, 前面不显示回复了某某.
			print("111:");
			-- local pid = self.DataList.list[self.curDynamicIndex].pid;
			-- local role_info_list = self.DataList.role_info_list;
			-- local op_uin, time = self:ParseUinByPid(pid);
			-- local RoleInfo = self:GetRoleInfoByUin(role_info_list, op_uin);
			-- des_nickname = (RoleInfo and RoleInfo.NickName) or "";
		else
			--二级回复, 显示"回复了某某".
			print("222:");
			local commentData = self.curCommentList;
			if commentData and commentData.list and commentData.list[self.curReplyIndex] then
				list_node = commentData.list[self.curReplyIndex];
				print(list_node.uin);
				local RoleInfo = commentData.role_info_list[tostring(list_node.uin)];
				-- des_nickname = (RoleInfo and RoleInfo.NickName) or "";
				op_uin = list_node.uin;	--回复对象的uin
			end
		end
		
		print("content = " .. content);
		-- content = escape(content);
		content = gFunc_urlEscape(content);

		local pid = self.DataList.list[self.curDynamicIndex].pid;
		local _pid_uin, _time = self:ParseUinByPid(pid);
		local ctime = os.time()
		local url = "";
		if op_uin > 0 then
			url = ns_version.proxy_url .. '/miniw/posting?act=add_comment' .. "&content=" .. content .. "&pid=" .. pid .. "&op_uin=" .. op_uin .. "&" .. http_getS2Act("posting");
		else
			url = ns_version.proxy_url .. '/miniw/posting?act=add_comment' .. "&content=" .. content .. "&pid=" .. pid .. "&" .. http_getS2Act("posting");
		end

		local callback = function(ret)
			print("AddComment callback:", ret);
			ShowLoadLoopFrame(false)
			if ret then
				if ret.ret == 0 then
					print("评论成功", ret.ret);
					if IsOverseasVer() or isAbroadEvn() then 
						ShowGameTips(GetS(20667), 3)
					else
						ShowGameTips(GetS(20665), 3)
					end
					--重新拉取评论
					self.bNeedSetCommentBottom = true;
					self.curLastCommentCT = 0;
					self.curCommentList = {};

					local _ipaddress = ret.location or nil --IP归属地

					self:AddMyComment(pid, ctime, _time, _pid_uin, content,_ipaddress)
					self:PullComment();
					self.bIsMainPageDirty = true;
					self.bIsMyPageDirty = true;
					self.bIsLatestPageDirty = true;
					self.needPull = true;
					self.needPullMyList = true;
					self.needPullLatest = true;
					getglobal("FriendDynamicFrameEditTextEdit"):Clear();

					--插入到最近两条评论, 免得为了刷新界面而重新拉取帖子列表
					--if t_exhibition:isLookSelf() then
					print("AddComment callback222:", self.curPullType, self.DataList)
					if self.curPullType and 3 ~= self.curPullType then
						if self.DataList and self.DataList.list and self.DataList.list[self.curDynamicIndex] then
							local pid = self.DataList.list[self.curDynamicIndex].pid;
							local _pid_uin, _time = self:ParseUinByPid(pid);
							self.DataList.list[self.curDynamicIndex].last_comments = self.DataList.list[self.curDynamicIndex].last_comments or {};
							table.insert(self.DataList.list[self.curDynamicIndex].last_comments, 1, {
								uin = GetMyUin(),
								time = os.time(),
								pid_ct = os.time(),
								pid_uin = _pid_uin;
								content = unescape(content),
								op_uin = op_uin,
								location = _ipaddress,
							});

							local commentCount = self.DataList.list[self.curDynamicIndex].comment_count and self.DataList.list[self.curDynamicIndex].comment_count + 1 or 1;
							self:UploadCommentCount(commentCount)
						end

						--如果role_info中没有, 要加上
						if self.DataList then
							self.DataList.role_info_list = self.DataList.role_info_list or {};
							if not self.DataList.role_info_list[GetMyUin()] then
								print("Comment Successful Then Add RoleInfo:");
								print(self.DataList.role_info_list);
								self.DataList.role_info_list[GetMyUin()] = {head_id = GetHeadIconIndex(), uin = GetMyUin(), NickName = AccountManager:getNickName()};
							end
						end
					end
					--end

				elseif ret.ret == 2 then
					ShowGameTips("评论重复");
				elseif ret.ret == 5 and ret.black_time then
					--被加入黑名单不能评论
					-- local NickName = getglobal("FriendDynamicFrameInfoName"):GetText() or "";
					-- ShowGameTips(GetS(21839, NickName));
					-- return;
					local limitDate = os.date("%Y-%m-%d %H:%M", ret.black_time) or 0
					ShowGameTipsWithoutFilter(GetS(10587,limitDate), 3)
				elseif ret.ret == 9 then --黑词校验失败 服务器聚合检测
					ShowGameTips(GetS(121), 3)
				elseif ret.ret == 21 then --实名校验失败
					ShowGameTips(GetS(22037), 3)
				elseif ret.ret == 20 then --手机号 实名校验失败
					ShowGameTipsWithoutFilter(GetS(100218), 3)
				elseif ret.ret == 22 then  --手机号校验失败
					ShowGameTipsWithoutFilter(GetS(10643), 3)
				else
					if ret.msg then
						if string.find(ret.msg, "only_self") or string.find(ret.msg, "only_friend") or string.find(ret.msg, "only_follow") then
							--作者设置了回复权限
							ShowGameTips(GetS(20586), 3);
						else
							ShowGameTips(GetS(20563) .. "(" .. ret.msg .. ")");
						end
					else
						ShowGameTips(GetS(21840));
					end
				end
					else
					--评论失败
					ShowGameTips(GetS(20563));
					end
		end

		url = url .. "&" .. http_getRealNameMobileSum(content)

		url = url .. getFriendRelationReqStr( _pid_uin )
		url = DynamicFrameUrlAddToken(url)
		
		print( "------------------->>>>", url );
		ShowLoadLoopFrame(true, "file:playercenter_new -- func:AddComment");
		ns_http.func.rpc( url, callback, nil, nil, true );
	end,

	--[[
		type 0:删除单条
			 1:删除除这个人所有评论
	]]
	DeleteComment = function(self, index, type)
	 	local pid,op_uin,op_create_time = self:GetReportCommentInfo(index);
		local o_pid = pid
		local callback = function(ret)
			if ret then
				if ret.ret and ret.ret >= 0 then
					self:UploadCommentCount(ret.ret);
					self:UploadLastComments(ret.last_comments);

					self.bIsMainPageDirty = true;
					self.bIsMyPageDirty = true;
					self.bIsLatestPageDirty = true;
					self.needPullLatest = true;
					self.curLatestCT = 0;
					self.curLastCommentCT = 0;
					self.curCommentList = {};

					self:DeleteMyComment(o_pid, op_create_time)
					self:PullComment(); 
					ShowGameTips(GetS(21833));
				else
					ShowLoadLoopFrame(false)
					ShowGameTips(GetS(773));
				end
			end
		end
        
        local url = "";
		if type == 0 then
			pid = pid .. "_" .. op_uin .. "_" .. op_create_time;
			url = ns_version.proxy_url .. '/miniw/posting?act=delete_single_comment' .. "&pid=" .. pid .. "&" .. http_getS2Act("posting");
		else
			pid = pid .. "_" .. op_uin;
			url = ns_version.proxy_url .. '/miniw/posting?act=delete_player_comment' .. "&pid=" .. pid .. "&" .. http_getS2Act("posting");
		end
		url = DynamicFrameUrlAddToken(url)
		print("delete_single_comment url", url)

		ShowLoadLoopFrame(true, "file:playercenter_new -- func:DeleteComment");
		ns_http.func.rpc( url, callback, nil, nil, true );
	end,

	OpenCommentEditFrame = function(self, index)
		print("OpenCommentEditFrame:");
		print("index = ", index);

		if self.DataList 
		and self.DataList.list 
		and self.DataList.list[self.curDynamicIndex] then
			local black_stat = self.DataList.list[self.curDynamicIndex].black_stat;
			if black_stat == 1 or black_stat == 2 then 
				ShowGameTipsWithoutFilter(GetS(10574));
				return
			end
		end

		self.curReplyIndex = index or 0;
		local defaultText = getglobal("FriendDynamicFrameEditEditDefaultTxt");
		local ui_edittext = getglobal("FriendDynamicFrameEditTextEdit");
		defaultText:Hide();
		ui_edittext:Clear();

		--警告提示:"请勿发布虚假和诈骗信息"
		local wangText = getglobal("FriendDynamicFrameEditEditWarnTxt");
		wangText:Show();
		wangText:SetAnchorOffset(0, 5);

		if index and index > 0 then
			--回复评论时, 不要自己回复自己
			local commentData = self.curCommentList;
			if commentData and commentData.list and commentData.list[self.curReplyIndex] then
				--找到该条评论的uin, 然后和自己的uin对比
				list_node = commentData.list[self.curReplyIndex];
				print(list_node.uin);
				if list_node.uin == GetMyUin() then
					print("不要自己回复自己:");
					return;
				end
			end

			--"回复XXX"这样的提示
			local op_RoleInfo = self:GetRoleInfoByUin(commentData.role_info_list, list_node.uin);
			if op_RoleInfo then
				local NickName = (op_RoleInfo and op_RoleInfo.NickName) or "";
				local defaultContent = GetS(20609) .. NickName .. ":";	--回复了某某
				defaultText:Show();
				defaultText:SetText(defaultContent);
				wangText:SetAnchorOffset(0, 35);
			end
		end

		--评论权限
		if self.curDynamicDetail and self.curDynamicDetail.posting and self.curDynamicDetail.posting.auth_rep and self.curDynamicDetail.posting.auth_rep == 3 then
			print("作者关闭了评论:");
			ShowGameTips(GetS(20585), 3);	--作者关闭了评论
			return;
		end

		getglobal("FriendDynamicFrameEdit"):Show();
	end,

	--[[
		点击动态的评论按钮，拉取动态的详情信息
	]]
	PullDynamicDetail = function(self, index, nPullType)
		--获取一条动态的详情
		print("PullDynamicDetail");
		if nPullType == 2 then
			print("222");
			self.DataList = self.MyDataList;
		elseif nPullType == 3 then
			print("333");
			self.DataList = self.LatestList;
		else
			print("111");
			self.DataList = self.CircleList;
		end

		self.curPullType = nPullType or 1;
		self.curDynamicIndex = index;
		self.curDynamicDetail = {};
		getglobal("FriendDynamicFrameReplyBox"):resetOffsetPos();
		print("PullDynamicDetail, index = " .. index);
		local callback = function(ret)
			print("callback:");
			if ret and ret.ret == 0 then
				print("获取动态详情成功");
				print(ret);

				self.curDynamicDetail = ret.data;
				self.curLastCommentCT = 0;		--每打开详情页, 从第一条评论开始拉
				self.curCommentList = {};		--清空评论
				self:PullComment();
			else
				-- 获取动态详情失败
				ShowGameTips(GetS(20564));
			end
		end

		if self.DataList and self.DataList.list and self.DataList.list[self.curDynamicIndex] then
			local pid = self.DataList.list[self.curDynamicIndex].pid;
			local url = ns_version.proxy_url .. '/miniw/posting?act=get_posting' .. "&pid=" .. pid .. "&" .. http_getS2Act("posting");
			print( url );
			ns_http.func.rpc( url, callback, nil, nil, true );
			return pid
		end
	end,

	PullComment = function(self)
		print("PullComment:");
		if self.curLastCommentCT and self.curLastCommentCT == -1 then
			ShowGameTips(GetS(770), 3);	--没有更多评论了
			return;
		end

		local pid = self.DataList.list[self.curDynamicIndex].pid;

		--接着拉评论
		local callback = function(ret)
			print("callback:");
			ShowLoadLoopFrame(false)
			if ret and ret.ret == 0 then
				print("获取评论成功");
				print(ret);
				print("**************************************");
				-- self.curCommentList = ret.data; --修改为分批拉取, 就不要用赋值要用插入
				if ret.data and ret.data.list then
					local num = 0;
					self.curCommentList.list = self.curCommentList.list or {};

					for i = 1, #(ret.data.list) do
						num = num + 1;
						table.insert(self.curCommentList.list, ret.data.list[i]);
						self.curLastCommentCT = ret.data.list[i].last_time or 0;
						print("self.curLastCommentCT, ", self.curLastCommentCT);
					end

					if num < 20 then
						--说明评论全部拉完了
						self.curLastCommentCT = -1;		--负1表示不要再继续拉了.
					end
				end

				if ret.data and ret.data.role_info_list then
					self.curCommentList.role_info_list = self.curCommentList.role_info_list or {};
					for k, v in pairs(ret.data.role_info_list) do
						if k and v then
							self.curCommentList.role_info_list[k] = v;
						end
					end
				end

				if self.myCommentList[GetMyUin()] then
					local mclist = self.myCommentList[GetMyUin()]
					self.curCommentList.role_info_list = self.curCommentList.role_info_list or {};
					for i = 1, #mclist do
						if mclist[i].pid_ and mclist[i].pid_ == pid then
							local ccl = self.curCommentList.list
							local isInsert = true
							for j = 1, #ccl do
								if ccl[j].uin == GetMyUin() and ccl[j].last_time == mclist[i].last_time and 
									ns_http.func.url_decode(ccl[j].content) == mclist[i].content then
									isInsert = false
								end
							end

							if isInsert then
								table.insert(self.curCommentList.list, mclist[i]);
								self.curCommentList.role_info_list[mclist[i].uin] = {
									NickName = AccountManager:getNickName(),
									uin = mclist[i].uin,
									head_id = GetHeadIconIndex(),
								}
							end
						end
					end
				end
				print(self.curCommentList);
			else
				-- ShowGameTips("获取评论失败");
			end

			self:UpdateDetailPage();
		end

		
		local url = ns_version.proxy_url .. '/miniw/posting?act=get_comment' .. "&pid=" .. pid .. "&" .. http_getS2Act("posting");

		if self.curLastCommentCT and self.curLastCommentCT > 0 then
			--拉取后面的评论
			  local ct = self.curLastCommentCT;
			  url = ns_version.proxy_url .. '/miniw/posting?act=get_comment' .. "&pid=" .. pid .. "&ct=" .. ct .. "&" .. http_getS2Act("posting");
		else
			--拉取第一个20条评论
		end

		print( url );
		ShowLoadLoopFrame(true, "file:playercenter_new -- func:PullComment");
		ns_http.func.rpc( url, callback, nil, nil, true );
	end,

	PrizeDynamic = function(self, index, bIsCai, cellUI)
		print("PrizeDynamic: index = " .. index);
		if self.DataList.list and next(self.DataList.list) then
			
		else
			print("error: self.DataList.list = nil");
			return;
		end

		local list_node = self.DataList.list[index];
		local pid = list_node.pid;

		local callback = function(ret)
			print("callback:");
			print(ret);
			ShowLoadLoopFrame(false)
			if ret and ret.ret == 0 then
				print("点赞成功:");
				if bIsCai then
					list_node.cai_count = list_node.cai_count or 0;
					list_node.cai_count = list_node.cai_count + 1;
				else
					list_node.prize_count = list_node.prize_count or 0;
					list_node.prize_count = list_node.prize_count + 1;

					NewBattlePassEventOnTrigger("prize");
				end

				self:SetPriseState(pid, bIsCai);
				self:SetCommentNum(list_node, cellUI);
			else
				print("点赞/踩失败");
			end
		end

		if not self:IsPrised(pid, bIsCai) then
			print("可以点赞")
			ShowLoadLoopFrame(true, "file:playercenter_new -- func:PrizeDynamic");
			local url = "";
			if bIsCai then
				url = ns_version.proxy_url .. '/miniw/posting?act=prize_posting' .. "&pid=" .. pid .. "&cai=" .. 1 .. "&" .. http_getS2Act("posting");
			else
				url = ns_version.proxy_url .. '/miniw/posting?act=prize_posting' .. "&pid=" .. pid .. "&" .. http_getS2Act("posting");
			end

			print( url );
			ns_http.func.rpc( url, callback, nil, nil, true );
		else
			print("不能重复点赞")
		end
	end,

	UpdateMainPage = function(self)
		if t_exhibition:isLookSelf() then
			print("self:");
			self.DataList = self.CircleList;
		else
			print("other:");
			self.DataList = self.MyDataList;
		end
		getglobal("DynamicHandleFrameEmptyFrame"):Hide();

		local num = 0;
		-- print(self.list);
		if self.bIsMainPageDirty then
			self.bIsMainPageDirty = false;
			self:IninCellList("ExhibitionInfoPage2CommentSliderCell");
			local list = {};

			if self.DataList and self.DataList.list then
				list = self.DataList.list;
			end
			
			local role_info_list = self.DataList.role_info_list;
			
			local y = 5;
			local height = 340;

			if list and next(list) then
				num = #list;
			end

			print("num=",num);
			print(role_info_list);
			print("................................");
			print(list);

			for i = 1, 999 do
				local cellUI = "ExhibitionInfoPage2CommentSliderCell" .. i
				if not HasUIFrame(cellUI) then
					break;
				end

				local cell = getglobal(cellUI);
				local contentUI = cellUI .. "Content";

				if i <= num and list[i] and list[i].pid then
					--帖子一定要有pid
					print("朋友圈: i = ", i);
					
					if list[i].auth_see and list[i].auth_see == 3 then
						--帖子状态为'隐藏'
						cell:Hide();
					else
						cell:Show();
						cell:SetPoint("top", "ExhibitionInfoPage2CommentSliderPlane", "top", 0, y);
						local op_uin, time = self:ParseUinByPid(list[i].pid);
						local RoleInfo = self:GetRoleInfoByUin(role_info_list, op_uin);--role_info_list[op_uin] or role_info_list[tostring(op_uin)];
						local content = unescape(list[i].content);
						local black_stat = list[i].black_stat or nil ; --1=审核中  nil=未进入审核池
						local ipaddress = list[i].location  or nil --IP归属地

						local ui_reportPic = 		getglobal(cellUI.."ReportPic");
						local ui_reportTitle = 		getglobal(cellUI.."ReportTitle");
						local ui_officialBkg = 		getglobal(cellUI.."OfficialBkg");
						local ui_official=			getglobal(cellUI.."Official");
						--迷你队长发的动态会有官方动态标签
						local uin = tonumber(op_uin)
						if self.WhiteList[uin] == 1 then
							ui_officialBkg:Show();
							ui_official:Show();
						else
							ui_officialBkg:Hide();
							ui_official:Hide();
						end

						self:SetRoleInfo(RoleInfo, cellUI);

						if  black_stat == nil or black_stat ~=1 then
							self:SetContent(content, time, cellUI,false,ipaddress);
							self:Set3Pic(list[i].pic_list, cellUI);
							ui_reportPic:Hide();
							ui_reportTitle:Hide();
							--[[ui_officialBkg:Hide();
							ui_official:Hide();--]]

						elseif   black_stat ==1 then
							ui_reportPic:Show();
							ui_reportTitle:Show();
							ui_reportTitle:SetText(GetS(20309))
							ui_officialBkg:Show();
							ui_official:Show();

							if AccountManager:getUin() == tonumber(op_uin) then
								ui_reportPic:SetPoint("top", cell:GetName(), "top", 297, 11);
								self:SetContent(content, time, cellUI,false,ipaddress);
								self:Set3Pic(list[i].pic_list, cellUI);
							else
								ui_reportPic:SetPoint("top", cell:GetName(), "top", 0, 30);
								self:SetContent("", time, cellUI,false,ipaddress);
								self:Set3Pic(nil, cellUI);
							end

						end
						
						--处于审核中的评论不显示
						local last_comments = {};
						if list[i].last_comments then
							for k,v in pairs(list[i].last_comments) do
								local black_stat = v.black_stat or nil ; --1=审核状态 nil=未进入审核池
								if black_stat == nil or black_stat ~= 1 then
									table.insert(last_comments,v);
								end
							end
						end
						self:Set2LastComment(last_comments, cellUI, true);
						self:SetCommentNum(list[i], cellUI, true);
						--self:SetSourceDes(RoleInfo, cellUI, list[i].from_type);
						self:SetCommentBtnState(cellUI .. "CommentBtn", list[i].auth_rep);	--评论按钮状态
						
						local jumpText = getglobal(cellUI .. "JumpText")
						local infoPic = getglobal(cellUI .. "Pic")
						jumpText:Hide()
						local posting = list[i]
						if posting and posting.action and "" ~= posting.action then
							jumpText:Show()
							cell:SetHeight(cell:GetHeight() + 20)
							infoPic:SetPoint("topleft",contentUI,"bottomleft",0,45)
							if posting.action == 99 then -- 超链接
								local title = posting.action_title or "超链接"
								jumpText:SetText("#L#c0A7FEF" .. title)
							else
								jumpText:SetText("#L#c0A7FEF" .. GetS(4756))
							end
						else
							infoPic:SetPoint("topleft",contentUI,"bottomleft",0,25)
						end

						height = cell:GetHeight() + 10;
						y = y + height;
					end
				else
					cell:Hide();
				end
			end

			y = (502 < y and y) or 502;
			getglobal("ExhibitionInfoPage2CommentSliderPlane"):SetHeight(y);

			--是否显示返回顶部按钮
			-- local gotoTopBtn = getglobal("ExhibitionInfoPage2Go2Top");
			ExhibitionInfoPage2CommentSlider_SetGotoTopBtnState();
		end

		if not self.DataList or not self.DataList.list or 0 == #(self.DataList.list) then
			--没有动态时, 界面显示.
			print("UpdateMainPage_NoList:");
			getglobal("DynamicHandleFrameEmptyFrame"):Show();
			getglobal("DynamicHandleFrameEmptyFrameTip"):SetText(GetS(20589));
		end
	end,

	UpdateDetailPage = function(self)
		--刷新动态详情页
		print("UpdateDetailPage:");
		local detailData = self.curDynamicDetail;
		print(detailData);
		local cellUI = "FriendDynamicFrameInfo";
		local ui_Info = getglobal(cellUI);
		local ui_EmptyBkg = getglobal("FriendDynamicFrameEmptyBkg");
		local ui_EmptyTips = getglobal("FriendDynamicFrameEmptyTips");

		ui_Info:Hide();
		ui_EmptyBkg:Show();
		ui_EmptyTips:Show();
		getglobal("FriendDynamicFrameReplyBox"):Hide();
		if self.DataList and self.DataList.list and self.DataList.list[self.curDynamicIndex] and detailData.posting then
			local list_node = self.DataList.list[self.curDynamicIndex];
			local role_info_list = self.DataList.role_info_list;
			local op_uin, time = self:ParseUinByPid(list_node.pid);
			local RoleInfo = self:GetRoleInfoByUin(role_info_list, op_uin);
			local content = unescape(detailData.posting.content);
			--1. 动态详情
			list_node.comment_count = list_node.comment_count or detailData.posting.comment_count;	--起始评论数直接从帖子详情拿就好, 不用从列表拿.
			local black_stat = list_node.black_stat or nil ; --1=审核状态 nil=未进入审核池
			local ipaddress = detailData.posting.location  or nil --IP归属地

			local ui_reportPic = 		getglobal(cellUI.."ReportPic");
			local ui_reportTitle = 		getglobal(cellUI.."ReportTitle");
			local btn_reportBtn = 		getglobal(cellUI.."ReportBtn");

			ui_Info:SetClientID(self.curDynamicIndex);--屏蔽词白名单查找迷你号使用
			if  black_stat == nil or black_stat ~=1 then
				self:SetContent(content, time, cellUI,false,ipaddress);
				self:Set3Pic_DetailPage(detailData.posting.pic_list);	--图片要从详情页数据拿，因为最近回复列表没有图片.
				ui_reportPic:Hide();
				ui_reportTitle:Hide();
				if AccountManager:getUin() == tonumber(op_uin) then
					btn_reportBtn:Hide();
				else
					btn_reportBtn:Show();
				end

			elseif black_stat ==1 then
				btn_reportBtn:Hide();
				ui_reportPic:Show();
				ui_reportTitle:Show();
				ui_reportTitle:SetText(GetS(20309))

				if AccountManager:getUin() == tonumber(op_uin) then
					ui_reportPic:SetPoint("top", getglobal(cellUI):GetName(), "top", 462, 5);
					self:SetContent(content, time, cellUI,false,ipaddress);
					self:Set3Pic_DetailPage(detailData.posting.pic_list);	--图片要从详情页数据拿，因为最近回复列表没有图片.
				else
					ui_reportPic:SetPoint("top", getglobal(cellUI):GetName(), "top", 0, 30);
					self:SetContent("", time, cellUI,false,ipaddress);
					self:Set3Pic_DetailPage(_);	--图片要从详情页数据拿，因为最近回复列表没有图片.
				end
			end

			self:SetRoleInfo(RoleInfo, cellUI);
			self:SetCommentNum(list_node, cellUI);
			self:SetCommentBtnState(cellUI .. "CommentBtn", list_node.auth_rep);	--评论按钮状态

			--2. 评论列表
			self:UpdateCommentList();

			--3. 是否显示跳转按钮(游戏内分享)
			local jumpBtn = getglobal("FriendDynamicFrameJumpBtn");
			jumpBtn:Hide();
			print("detailData.posting.action = ", detailData.posting.action);
			-- if detailData.posting and detailData.posting.action and "" ~= detailData.posting.action then
			-- 	print("detailData.posting.action:");
			-- 	jumpBtn:Show();
			-- end

			--4,显示跳转链接（取代之前的按钮）
			local jumpText = getglobal("FriendDynamicFrameInfoJumpText")
			local infoPic = getglobal("FriendDynamicFrameInfoPic")
			--local row = math.ceil((CalculateStringWidth(content) / 2) / math.floor(820/22)) -- 展示文本行数

			--通过设置RichText文字来获取高度，重设文字、根据是否有图片重设整体高度
			local fContent = getglobal("FriendDynamicFrameInfoContent")
			local fContentH = 48		--fContent:GetHeight()--下面有重设高度，防止被修改，一直保持最初高度
			local rContent = getglobal("FriendDynamicFrameInfoRContent")
			rContent:SetText(fContent:GetText())
			local h = rContent:GetTotalHeight()
			fContent:SetHeight(h)
			-- local lines = rContent:GetTextLines()
			local picH = 0				--有分享图片就不管，没分享图片就把图片高度减掉
			if not detailData.posting.pic_list or #detailData.posting.pic_list==0 then
				picH = -infoPic:GetHeight()
			end
			local uiInfoH = 300 		--ui_Info:GetHeight()--下面有重设高度，防止被修改，一直保持最初高度
			ui_Info:SetHeight(uiInfoH + h - fContentH + picH)

			jumpText:Hide()
			if detailData.posting and detailData.posting.action and "" ~= detailData.posting.action then
				print("detailData.posting.action:");
				jumpText:Show();
				-- infoPic:SetPoint("bottomleft","FriendDynamicFrameInfo","bottomleft",0,-13)
				-- if row <= 1 then
				-- 	jumpText:SetPoint("topleft","FriendDynamicFrameInfoContent","bottomleft",0,-20)
				-- 	infoPic:SetPoint("bottomleft","FriendDynamicFrameInfo","bottomleft",0,-35)
				-- else
				-- 	jumpText:SetPoint("topleft","FriendDynamicFrameInfoContent","bottomleft",0,5)
				-- 	infoPic:SetPoint("bottomleft","FriendDynamicFrameInfo","bottomleft",0,-35)
				-- end
				if detailData.posting.action == 99 then -- 超链接
					local title = detailData.posting.action_title or "超链接"
					jumpText:SetText("#L#c0A7FEF" .. title)
				else
					jumpText:SetText("#L#c0A7FEF" .. GetS(4756))
				end
			else
				infoPic:SetPoint("bottomleft","FriendDynamicFrameInfo","bottomleft",0,-35)
			end

			ui_Info:Show();
			ui_EmptyBkg:Hide();
			ui_EmptyTips:Hide();
		else
			ui_Info:Hide();
			ui_EmptyBkg:Show();
			ui_EmptyTips:Show();
		end
	end,

	UpdateCommentList = function(self)
		print("UpdateCommentList:");
		--2. 评论列表
		local y = 36;
		local commentData = self.curCommentList;
		local ui_replyBox = getglobal("FriendDynamicFrameReplyBox");
		local ui_replyEmptyBkg = getglobal("FriendDynamicFrameReplyBoxEmptyBkg");
		local ui_replyEmptyTips = getglobal("FriendDynamicFrameReplyBoxEmptyTips");
		local ui_replyPlane = getglobal("FriendDynamicFrameReplyBoxPlane");
		ui_replyBox:Show();
		ui_replyEmptyBkg:Hide();
		ui_replyEmptyTips:Hide();
		ui_replyPlane:Show();
		for i = 1, 200 do
			local itemUI = "FriendDynamicFrameReplyBoxItem" .. i;
			if not HasUIFrame(itemUI) then
				break;
			end

			local item = getglobal(itemUI);
			item:Hide();
			if commentData and commentData.list then
				--有评论, 设置评论详情
				if i <= #(commentData.list) then
					item:Show();
					y = y + item:GetHeight();
					list_node = commentData.list[i];
					print("commentData.role_info_list: i = ", i);
					print(commentData.role_info_list);
					print(list_node);
					print(list_node.uin);
					local RoleInfo = self:GetRoleInfoByUin(commentData.role_info_list, list_node.uin); --commentData.role_info_list[tostring(list_node.uin)];	--该条评论自己的信息
					local op_RoleInfo = (list_node.op_uin and list_node.op_uin > 0 and self:GetRoleInfoByUin(commentData.role_info_list, list_node.op_uin)) or nil;							--该条评论回复对象的信息
					local content = unescape(list_node.content);
					local time = list_node.last_time;
					local op_NickName = "";--list_node.NickName or "";	--回复对象的昵称.
					print("list_node.content = " .. list_node.content);
					print("comment_content = " .. content);
					local ipaddress = list_node.location  or nil --IP归属地

					if op_RoleInfo then
						op_NickName = op_RoleInfo.NickName;
					end

					if op_NickName and op_NickName ~= "" then
						content = GetS(20566) .. op_NickName .. ": " .. content;
					end

					local black_stat = list_node.black_stat or nil ; --1=审核状态 nil=未进入审核池
					local ui_reportPic = getglobal(itemUI.."ReportPic");
					local ui_reportTitle = getglobal(itemUI.."ReportTitle");


					if  black_stat == nil or black_stat ~=1 then
						self:SetContent(content, time, itemUI, true,ipaddress);
						ui_reportPic:Hide();
						ui_reportTitle:Hide();
					elseif black_stat ==1 then
						ui_reportPic:Show();
						ui_reportTitle:Show();
						ui_reportTitle:SetText(GetS(20309))

						if AccountManager:getUin() == tonumber(list_node.uin) then
							ui_reportPic:SetPoint("center", item:GetName(), "center", 475, 0);
							self:SetContent(content, time, itemUI, true,ipaddress);
						else
							ui_reportPic:SetPoint("center", item:GetName(), "center", -17, 0);
							self:SetContent("", time, itemUI, true,ipaddress);
						end
					end

					self:SetRoleInfo(RoleInfo, itemUI);

				end
			end
		end

		local boxH = getglobal("FriendDynamicFrameReplyBox"):GetHeight();
		y = (y < boxH and boxH) or y;
		print("y = " .. y);
		getglobal("FriendDynamicFrameReplyBoxPlane"):SetHeight(y);

		--没有评论的时候显示空白页
		if not commentData or not commentData.list or #(commentData.list) <= 0 then
			ui_replyEmptyBkg:Show();
			ui_replyEmptyTips:Show();
			ui_replyPlane:Hide();
			return;
		end

		-- 若果是评论完重新拉详情页, 那么把列表拉到最下面.
		-- if self.bNeedSetCommentBottom then
		-- 	self.bNeedSetCommentBottom = false;
		-- 	getglobal("FriendDynamicFrameReplyBox"):setCurOffsetY(0 - y);
		-- end
	end,

	UpdateMyPage = function(self)
		--动态管理->我的动态页
		print("UpdateMyPage:");
		getglobal("DynamicHandleFrameEmptyFrame"):Hide();

		if self.bIsMyPageDirty and self.selectPullType == 2 then
			self.bIsMyPageDirty = false;
			self.DataList = self.MyDataList;
			self:IninCellList("MyDynamicBoxCell");

			if self.DataList.list then
				print("UpdateMyPage: ok:");
				local list = self.DataList.list;
				local role_info_list = self.DataList.role_info_list;
				local num = #list;
				local y = 5;
				local height = 166;
				local firstUI = "MyDynamicBox";
				local planeUI = firstUI .. "Plane";
				print(role_info_list);
				print("***************");
				print(list);

				for i = 1, 200 do
					local cellUI = firstUI .. "Cell" .. i;
					if not HasUIFrame(cellUI) then
						break;
					end
					local cell = getglobal(cellUI);
					local contentUI = cellUI .. "Content";

					if i <= num and list[i] and list[i].pid then
						cell:Show();
						cell:SetPoint("top", planeUI, "top", 0, y);
						local op_uin, time = self:ParseUinByPid(list[i].pid);
						local RoleInfo = self:GetRoleInfoByUin(role_info_list, op_uin) --role_info_list[op_uin];
						local content = unescape(list[i].content);
						local ipaddress = list[i].location  or nil --IP归属地

						local state = list[i].stat or 0;
						self:SetRoleInfo(RoleInfo, cellUI);
						self:SetContent(content, time, cellUI,false,ipaddress);
						self:SetState(list[i], cellUI);
						self:Set3Pic_MyPage(list[i].pic_list, cellUI);
						self:Set2LastComment(list[i].last_comments, cellUI, true);
						self:SetCommentNum(list[i], cellUI, true);
						--调整设置按钮长度
						-- getglobal(cellUI .. "Func"):SetHeight(cell:GetHeight());
						-- 超链接
						local jumpText = getglobal(cellUI .. "JumpText")
						local infoPic = getglobal(cellUI .. "Pic")
						jumpText:Hide()
						local posting = list[i]
						if posting and posting.action and "" ~= posting.action then
							jumpText:Show()
							cell:SetHeight(cell:GetHeight() + 20)
							infoPic:SetPoint("topleft",contentUI,"bottomleft",0,45)
							if posting.action == 99 then -- 超链接
								local title = posting.action_title or "超链接"
								jumpText:SetText("#L#c0A7FEF" .. title)
							else
								jumpText:SetText("#L#c0A7FEF" .. GetS(4756))
							end
						else
							infoPic:SetPoint("topleft",contentUI,"bottomleft",0,25)
						end

						if list[i].stat and list[i].stat == 4 then
							--帖子已经删除了, 就不显示了
							cell:Hide();
						else
							height = cell:GetHeight() + 10;
							y = y + height;
						end
					else
						cell:Hide();
					end
				end

				y = (502 < y and y) or 502;
				getglobal(planeUI):SetHeight(y);
			end
		end

		if not self.DataList or not self.DataList.list or 0 == #(self.DataList.list) then
			--没有动态时, 界面显示.
			print("UpdateMainPage_NoList:");
			getglobal("DynamicHandleFrameEmptyFrame"):Show();
			getglobal("DynamicHandleFrameEmptyFrameTip"):SetText(GetS(20589));
		end
	end,

	UpdateLatelyPage = function(self)
		print("UpdateLatelyPage:");
		getglobal("DynamicHandleFrameEmptyFrame"):Hide();
		if self.bIsLatestPageDirty then
			self.bIsLatestPageDirty = false;
			self.DataList = self.LatestList;
			self:IninCellList("LatestDynamicBoxCell");

			if self.DataList.list then
				print("UpdateLatelyPage: ok:");
				local list = self.DataList.list;
				local role_info_list = self.DataList.role_info_list;
				local num = #list;
				local y = 5;
				local height = 166;
				local firstUI = "LatestDynamicBox";
				local planeUI = firstUI .. "Plane";
				print(self.DataList);

				for i = 1, 200 do
					local cellUI = firstUI .. "Cell" .. i;
					if not HasUIFrame(cellUI) then
						break;
					end
					local cell = getglobal(cellUI);
					local contentUI = cellUI .. "Content";
					local comment = getglobal(cellUI .. "Comment1");

					if i <= num and list[i] and (list[i].black_stat and list[i].black_stat ~= 1 and list[i].black_stat ~= 2 or not list[i].black_stat) then
						cell:Show();
						cell:SetPoint("top", planeUI, "top", 0, y);
						local op_uin = list[i].uin;
						local time = list[i].time;
						local RoleInfo = self:GetRoleInfoByUin(role_info_list, op_uin) --role_info_list[op_uin];
						local content = unescape(list[i].pid_content);
						local commentTxt = unescape(list[i].content);
						local ipaddress = list[i].location  or nil --IP归属地

						self:SetRoleInfo(RoleInfo, cellUI);
						self:SetContent(content, time, cellUI,false,ipaddress);

						--评论
						print("latelyComment1:", commentTxt);
						--检查是否有敏感词
						local index = getglobal(cellUI):GetClientID();
						if not self:IsUinInWhiteList(list, index) then
							local text = self:SensitiveWordsShieldTxtOrPic(nil,commentTxt);
							if text ~= "" then commentTxt = text; end
						end
						commentTxt = DefMgr:filterString(commentTxt);
						comment:SetText(commentTxt, 61, 69, 70);

						local scale = UIFrameMgr:GetScreenScaleY();
						local firstLineHeight = comment:GetLineHeight(1) / scale;
						if firstLineHeight < 35 then
							--没有表情
							comment:SetHeight(22);
							comment:SetPoint("topleft", cellUI .. "Name", "bottomleft", 5, 15);
						else
							--有表情
							comment:SetHeight(40);
							comment:SetPoint("topleft", cellUI .. "Name", "bottomleft", 5, 15);
						end


						--拼成pid
						list[i].pid = list[i].pid_uin .. "_" .. list[i].pid_ct;

						height = cell:GetHeight() + 10;
						y = y + height;
					else
						cell:Hide();
					end
				end

				y = (502 < y and y) or 502;
				getglobal(planeUI):SetHeight(y);
			end
		end

		if not self.DataList or not self.DataList.list or 0 == #(self.DataList.list) then
			--没有动态时, 界面显示.
			print("UpdateMainPage_NoList:");
			getglobal("DynamicHandleFrameEmptyFrame"):Show();
			getglobal("DynamicHandleFrameEmptyFrameTip"):SetText(GetS(20589));
		end
	end,

	IninCellList = function(self, firstUI)
		--初始化列表, 初始都隐藏掉
		print("IninCellList: firstUI = ", firstUI);
		for i = 1, 200 do
			local cellUI = firstUI .. i;
			if not HasUIFrame(cellUI) then
				break;
			end

			local cell = getglobal(cellUI)
			cell:Hide();
		end
	end,

	GetRoleInfoByUin = function(self, role_info_list, uin)
		print("GetRoleInfoByUin:");
		if role_info_list and next(role_info_list) then
			for k, v in pairs(role_info_list) do
				if k then
					if tonumber(uin) == tonumber(k) then
						print("find role_info:");
						print(v);
						return v;
					end
				end
			end
		end

		return nil;
	end,

	SetRoleInfo = function(self, RoleInfo, cellUI)
		--设置用户信息: 头像、昵称
		print("SetRoleInfo:");
		if RoleInfo then
			print(RoleInfo);
			if AccountManager:getUin() == RoleInfo.uin or (type(RoleInfo.uin) == 'string' and AccountManager:getUin() == tonumber(RoleInfo.uin)) then
				HeadCtrl:CurrentHeadIcon(cellUI .. "HeadIcon");
				HeadFrameCtrl:CurrentHeadFrame(cellUI .. "HeadNormal");
				HeadFrameCtrl:CurrentHeadFrame(cellUI .. "HeadPushedBG");
			else
				-- if RoleInfo.HasAvatar and RoleInfo.HasAvatar >= 1 then
					HeadCtrl:SetPlayerHeadByUin(cellUI .. "HeadIcon",RoleInfo.uin,RoleInfo.head_id,nil,RoleInfo.HasAvatar);
				-- else
				-- 	HeadCtrl:SetPlayerHead(cellUI .. "HeadIcon",2,RoleInfo.head_id);
				-- end
				if RoleInfo.head_frame_id then
					HeadFrameCtrl:SetPlayerheadFrame(cellUI .. "Head", tonumber(RoleInfo.head_frame_id));
				end
			end

			if RoleInfo.NickName then
				local name = getglobal(cellUI .. "Name");
				local str = RoleInfo.NickName
				if not IsIgnoreReplace(str, {CheckMiniAccountNick = true}) then
					str = ReplaceFilterString(str)
				end
				G_VipNamePreFixEntrency(name, RoleInfo.uin, str, {r=101, g=116, b=118})
				-- name:SetText(str);
			end
		end
	end,

	Set2LastComment = function(self, last_comments, cellUI, bIsRichText)
		--设置最近的两条评论
		print("Set2LastComment:");
		local role_info_list = self.DataList.role_info_list;
		print(role_info_list);

		for i = 1, 2 do
			local commentUI = cellUI .. "Comment" .. i;

			if not HasUIFrame(commentUI) then
				break;
			end


			local comment = getglobal(commentUI);
			comment:Hide();

			if last_comments and i <= #last_comments then
				local RoleInfo = self:GetRoleInfoByUin(role_info_list, last_comments[i].uin);
				local op_RoleInfo = (last_comments[i].op_uin and self:GetRoleInfoByUin(role_info_list, last_comments[i].op_uin)) or nil;
				local NickName = (RoleInfo and RoleInfo.NickName) or "";
				local op_NickName = (op_RoleInfo and op_RoleInfo.NickName) or "";
				local content = ns_http.func.url_decode(last_comments[i].content);
				
				--检查是否有敏感词
				if not self:IsUinInWhiteList(last_comments, i) then
					local text = self:SensitiveWordsShieldTxtOrPic(nil,content);
					if text ~= "" then content = text; end
				end

				--评论是好友,显示好友备注名
				NickName = GetNewFriendNote(RoleInfo.uin,NickName)
			
				local txt = "#c4d9bad" .. NickName .. "：" .. "#c819688" .. content;
				comment:Show();

				if bIsRichText then
					-- comment:SetText(txt, 159, 124, 82);
					G_VipNamePreFixEntrency(comment, RoleInfo.uin, txt, {r = 159, g = 124, b = 82},nil,nil,nil,true)
				else
					comment:SetText(txt);
				end

				if i == 1 then
					--第一行根据有没有表情实时调整下位置, 没表情的时候向下移一点儿, 表情的高度是40.
					local scale = UIFrameMgr:GetScreenScaleY();
					local firstLineHeight = comment:GetLineHeight(1) / scale;
					print("scale = ", scale);
					print("firstLineHeight = ", firstLineHeight);
					if firstLineHeight < 35 then
						--没有表情
						comment:SetHeight(30);
						comment:SetPoint("topleft", cellUI .. "Comment", "topleft", 98, 15);
					else
						--有表情
						comment:SetHeight(40);
						comment:SetPoint("topleft", cellUI .. "Comment", "topleft", 98, 5);
					end
				end
			end
		end

		--根据评论个数调整高度
		local num = 0;
		local primaryH = 137;		--原始的高, 即没有评论的时候的高
		local commentH = 10;
		local commentFrame = getglobal(cellUI .. "Comment");
		if last_comments and next(last_comments) then
			num = #last_comments;
		end

		-- if string.find(cellUI, "MyDynamicBox") then
		-- 	-- primaryH = 114;
		-- 	primaryH = getglobal(cellUI):GetHeight();
		-- elseif string.find(cellUI, "ExhibitionInfoPage2") then
		-- 	primaryH = getglobal(cellUI):GetHeight();
		-- end
		primaryH = getglobal(cellUI):GetHeight();
		
		commentFrame:Hide();

		if num == 0 then
			commentH = 1;
			commentFrame:SetHeight(1);
		elseif num == 1 then
			commentH = 45;
			commentFrame:SetHeight(45);
			commentFrame:Show();
		else
			commentH = 85;
			commentFrame:SetHeight(85);
			commentFrame:Show();
		end

		local cellHeight = primaryH + commentH;
		local cell = getglobal(cellUI);
		cell:SetHeight(cellHeight);		
	end,

	--检测是否在在白名单中，在就不走敏感词逻辑
	IsUinInWhiteList = function(self, list, index)
		local curList = list or {};
		if curList ~= {} and curList[index] and curList[index].pid then
			local uin = tonumber(string.sub(curList[index].pid,1,string.find(curList[index].pid,"_")-1));
			if uin and self.SensitiveWordWhiteList[uin] then
				return true;
			end
		elseif  curList ~= {} and curList[index] and curList[index].uin then -- 最近回复的数据不太一样特殊处理
			if self.SensitiveWordWhiteList[curList[index].uin] then
				return true;
			end
		end
		return false;
	end,

	--[[
		 picUI:如果文字有敏感词就连图片也屏蔽
		 text：将传进来的文字检测一遍，如果有敏感词就换成默认文字并return出来，如果没敏感词就直接return出来
		 pic和text只能传一个，一个传了另一个参数就传nil
	]]
	SensitiveWordsShieldTxtOrPic = function(self, picUI, text)
		local promptText = GetS(10545);
		if picUI then
			local pic = getglobal(picUI);
			local picBtn = getglobal(picUI .. "Btn");
			local content = (pic:GetParentFrame():GetParentFrame():GetName()) .. "Content";

			if HasUIFrame(content) then
				local curList = self.DataList.list or {};
				local index = getglobal(pic:GetParentFrame():GetParentFrame():GetName()):GetClientID();
				local ContentText = getglobal(content):GetText();
				--检查是否有敏感词
				if not self:IsUinInWhiteList(curList, index) and (string.find(ContentText,promptText) ~= nil or FilterMgr.GetFilterScore(ContentText)) then
					pic:SetTexture(self.SensitiveWordShieldingPicPath);
					picBtn:SetClientString(self.SensitiveWordShieldingPicPath);
					pic:Show();
					picBtn:Show();
					showPicNoStretch( picUI );
					return false;
				end
			end
			return true;
		elseif text then
			--检查是否有敏感词
			if string.find(text,promptText) ~= nil or FilterMgr.GetFilterScore(text) then text = promptText end
			return text;
		end
		return "";
	end,

	SetContent = function(self, content, time, cellUI, bIsRichText,ipaddress)
		--设置动态内容和时间
		print("SetContent:");
		print(content);
		print(time);
		--检查是否有敏感词
		local curList = self.DataList.list or {};
		if string.find(cellUI, "FriendDynamicFrameReplyBox") then
			curList = self.curCommentList.list or {};
		end
		local index = getglobal(cellUI):GetClientID();
		if not self:IsUinInWhiteList(curList, index) then
			local text = self:SensitiveWordsShieldTxtOrPic(nil,content);
			if text ~= "" then content = text; end
		end

		local contentObj = getglobal(cellUI .. "Content");
		local timeObj = getglobal(cellUI .. "Date");

		if bIsRichText then
			contentObj:SetText("***", 61, 69, 70);
			if content then
				content = DefMgr:filterString(content);
				contentObj:SetText(content, 61, 69, 70);
			end
		else
			contentObj:SetText("***");
			if content then
				content = DefMgr:filterString(content);
				contentObj:SetText(content);
			end
		end


		--时间
		local nowTime = os.time();

		if time then
			if nowTime - time < 86400 then
				--小于1小时显示分钟; 大于1小时, 小于一天, 显示XX小时前
				local minute = math.ceil((nowTime - time) / 60);
				if minute <= 0 then
					minute = 1;
				end

				if minute < 60 then
					timeContent = minute .. GetS(20587)
					timeObj:SetText(timeContent);	--3分钟前
				else
					local hour = math.ceil((nowTime - time) / 3600);
					if hour <= 0 then
						hour = 1;
					end
					timeContent = hour .. GetS(20588)
					timeObj:SetText(timeContent);	--3小时前
				end
			else
				--大于一天, 显示年月日
				timeContent = os.date("%Y-%m-%d", time)
				timeObj:SetText(timeContent);
			end
		else
			timeContent = os.date("%Y-%m-%d", time)
			timeObj:SetText(timeContent);
		end

		-- timeObj:SetPoint("BOTTOMLEFT", cellUI .. "Comment", "TOPLEFT", 98, -15)
		--IP归属地
		if ipaddress then
			if ipaddress == "" then
				ipaddress = GetS(4896)
			end
			if ns_version.ip_home and check_apiid_ver_conditions(ns_version.ip_home) then
				timeObj:SetText(timeContent .. "  " .. GetS(9200104,ipaddress))
			end
		end
	end,

	SetCommentNum = function(self, list_node, cellUI, refreshPos)
		--设置评论数、点赞数、踩数
		print("SetCommentNum:");
		refreshPos = refreshPos or false
		print(list_node);
		local commentNum = list_node.comment_count or 0;
		local priseNum = list_node.prize_count or 0;
		local negativeNum = list_node.cai_count or 0;
		local comment = getglobal(cellUI .. "CommentBtnFont");
		local prise = getglobal(cellUI .. "PraiseBtnFont");
		local negative = getglobal(cellUI .. "NegativeBtnFont");
		comment:SetText("(" .. commentNum .. ")");
		prise:SetText("(" .. priseNum .. ")");
		negative:SetText("(" .. negativeNum .. ")");

		--是否点过赞
		local pid = list_node.pid;
		local priseIcon = getglobal(cellUI .. "PraiseBtnIcon");
		local caiIcon = getglobal(cellUI .. "NegativeBtnIcon");
		if self:IsPrised(pid) then
			priseIcon:SetTextureHuiresXml("ui/mobile/texture2/miniwork.xml")
			priseIcon:SetTexUV("icon_thumb_h");
		else
			priseIcon:SetTextureHuiresXml("ui/mobile/texture2/playercenter.xml")
			priseIcon:SetTexUV("icon_thumb_big");
		end

		if refreshPos then
			local commentBg = getglobal(cellUI .. "Comment")
			local posY = -12
			if commentBg and commentBg:IsShown() then
				posY = posY - commentBg:GetHeight() + 3
				-- posY = -92
			end
	
			if getglobal(cellUI .. "Date") then
				getglobal(cellUI .. "Date"):SetPoint("bottomleft", cellUI, "bottomleft", 98, posY + 4)
			end
	
			if getglobal(cellUI .. "CommentBtn") then
				getglobal(cellUI .. "CommentBtn"):SetPoint("bottomright", cellUI, "bottomright", -295, posY)
			end
	
			if getglobal(cellUI .. "PraiseBtn") then
				getglobal(cellUI .. "PraiseBtn"):SetPoint("bottomright", cellUI, "bottomright", -136, posY)
			end
		end

		-- getglobal(cellUI .. "CommentBtn"):SetPoint("BOTTOMLEFT", cellUI .. "Date", "BOTTOMLEFT", 516, 0)
		-- getglobal(cellUI .. "PraiseBtn"):SetPoint("TOPLEFT", cellUI .. "CommentBtn", "TOPLEFT", 150, 0)
		--"踩"去掉了
		-- if self:IsPrised(pid, true) then
		-- 	caiIcon:SetTexUV("mngfg_dianzan02");
		-- else
		-- 	caiIcon:SetTexUV("mngfg_dianzan01");
		-- end
	end,

	Set3Pic = function(self, pic_list, cellUI)
		print("Set3Pic:");
		local cell = getglobal(cellUI);
		local picFrame = getglobal(cellUI .. "Pic");
		local hasPicH = 270;
		local notHasPicH = 137;

		if pic_list then
			-- print(pic_list);
			-- print(cellUI);
			cell:SetHeight(hasPicH);
			picFrame:Show();

			for i = 1, 3 do
				local picUI = cellUI .. "Pic" .. i;
				if not HasUIFrame(picUI) then
					break;
				end

				print("picUI = " .. picUI);
				local pic = getglobal(picUI);
				local picBtn = getglobal(picUI .. "Btn");
				pic:Hide();
				picBtn:Hide();
				picBtn:SetClientString("");

				if i <= #pic_list then
					if self:SensitiveWordsShieldTxtOrPic(picUI) then
						local no_stretch = function(ret)
							print("Set3Pic:callback:", ret);
							local picUI = ret;
							if picUI then
								local pic = getglobal(picUI);
								local picBtn = getglobal(picUI .. "Btn");
								pic:Show();
								picBtn:Show();
								showPicNoStretch( picUI );
							end
						end

						local url = pic_list[i].url;
						local filename = g_photo_root .. getHttpUrlLastPart( url );
						picBtn:SetClientString(filename .. "_");
						print("url = " .. url);
						print("filename = " .. filename);
						ns_http.func.downloadPng( url,
								filename .. "_",		--加上"_"后缀
								nil,
								picUI,				--ui名
								no_stretch			--回调
						);
					end
				end
			end
		else
			print("dont have pic:");
			cell:SetHeight(notHasPicH);
			picFrame:Hide();
		end
	end,

	Set3Pic_DetailPage = function(self, pic_list)
		--详情页的三张图片
		print("Set3Pic_DetailPage:");
		local cellUI = "FriendDynamicFrameInfo";
		local cell = getglobal(cellUI);
		local picFrame = getglobal(cellUI .. "Pic");
		local box = getglobal("FriendDynamicFrameReplyBox");

		if pic_list then
			cell:SetHeight(276);
			picFrame:Show();
			box:SetHeight(365);

			for i = 1, 3 do
				local picUI = cellUI .. "Pic" .. i;
				if not HasUIFrame(picUI) then
					break;
				end

				print("picUI = " .. picUI);
				local pic = getglobal(picUI);
				local picBtn = getglobal(picUI .. "Btn");
				pic:Hide();
				picBtn:Hide();
				picBtn:SetClientString("");

				if i <= #pic_list then
					if self:SensitiveWordsShieldTxtOrPic(picUI) then
						local no_stretch = function(ret)
							print("Set3Pic_DetailPage:callback:", ret);
							local picUI = ret;
							if picUI then
								local pic = getglobal(picUI);
								local picBtn = getglobal(picUI .. "Btn");
								pic:Show();
								picBtn:Show();
								showPicNoStretch( picUI );
							end
						end

						local url = pic_list[i].url;
						local filename = g_photo_root .. getHttpUrlLastPart( url );
						picBtn:SetClientString(filename .. "_");	--保存图片文件名
						print("url = " .. url);
						print("filename = " .. filename);
						ns_http.func.downloadPng( url,
								filename .. "_",		--加上"_"后缀
								nil,
								picUI,				--ui名
								no_stretch			--回调
						);
					end
				end
			end
		else
			print("dont have pic:");
			cell:SetHeight(160);
			box:SetHeight(488);
			picFrame:Hide();
		end
	end,

	Set3Pic_MyPage = function(self, pic_list, cellUI)
		--我的动态列表的三张图片
		print("Set3Pic_MyPage:", cellUI);
		local cell = getglobal(cellUI);
		local picFrame = getglobal(cellUI .. "Pic");

		if pic_list then
			cell:SetHeight(270);
			picFrame:Show();

			for i = 1, 3 do
				local picUI = cellUI .. "Pic" .. i;
				if not HasUIFrame(picUI) then
					break;
				end

				print("picUI = " .. picUI);
				local pic = getglobal(picUI);
				local picBtn = getglobal(picUI .. "Btn");
				pic:Hide();
				picBtn:Hide();
				picBtn:SetClientString("");

				if i <= #pic_list then
					if self:SensitiveWordsShieldTxtOrPic(picUI) then
						local no_stretch = function(ret)
							print("Set3Pic_MyPage:callback:", ret);
							local picUI = ret;
							if picUI then
								local pic = getglobal(picUI);
								local picBtn = getglobal(picUI .. "Btn");
								pic:Show();
								picBtn:Show();
								showPicNoStretch( picUI );
							end
						end

						local url = pic_list[i].url;
						local filename = g_photo_root .. getHttpUrlLastPart( url );
						local length = string.len(filename);
						if string.find(filename,'_') ==length then
							filename = string.sub(filename,1,length-1);
						end

						picBtn:SetClientString(filename .. "_");	--保存图片文件名
						print("url = " .. url);
						print("filename = " .. filename);
						ns_http.func.downloadPng( url,
								filename .. "_",		--加上"_"后缀
								nil,
								picUI,				--ui名
								no_stretch			--回调
						);
					end
				end
			end
		else
			print("dont have pic:");
			cell:SetHeight(137);
			picFrame:Hide();
		end
	end,

	SetOfficialDes = function(self, RoleInfo, cellUI, pid)
	--设置是否为官方动态
		local official = getglobal(cellUI .. "Official");
		local bkg = getglobal(cellUI .. "OfficialBkg");
		local uin = "";
		local x = 1
		if pid then
			local pos = string.find(pid, "_");
			if pos > 0 then
				uin = string.sub(pid, 0, pos - 1);
			end
		end

		if RoleInfo.uin == 1000 or uin == 1000 then
			official:Show();
			bkg:Show();
		else
			official:Hide();
			bkg:Hide();
		end
	end,

	SetSourceDes = function(self, RoleInfo, cellUI, from_type)
		--设置动态来源标签
		--from_type="nil":普通动态 from_type="web":网页发的动态
		local source_id = (RoleInfo and RoleInfo.relation) or 0;
		print("SetSourceDes: source_id = ", source_id);
		local source = getglobal(cellUI .. "Source");
		local bkg = getglobal(cellUI .. "SourceBkg");

		if RoleInfo and RoleInfo.uin == GetMyUin() then
			source_id = 0;
		end

		if t_exhibition:isLookSelf() then
			--暂时全部都隐藏, 不要这个功能
			bkg:Hide();
			source:Hide();

			--1. 好友关系
			if source_id > 0 then
				if source_id >= 16 then
					--关注动态
					source:SetText(GetS(20551));
				else
					--好友动态
					source:SetText(GetS(20550));
				end
			else
				--我的动态(如果是我的不用显示)
				-- source:SetText(GetS(20549));
				bkg:Hide();
				source:Hide();
			end

			--2. 动态来源
			if from_type and from_type == "web" then
				bkg:Show();
				source:Show();
				source:SetText(GetS(21561));
			end
		else
			bkg:Hide();
			source:Hide();
		end
	end,

	ParseUinByPid = function(self, pid)
		--根据动态pid获取对应的uin和时间
		print("ParseUinByPid:");
		print("pid = ", pid);
		local uin = "";
		local time = "";
		if pid then
			local pos = string.find(pid, "_");
			if pos > 0 then
				uin = string.sub(pid, 0, pos - 1);
				time = string.sub(pid, pos + 1);
			end
		end

		print("uin = " .. uin);
		print("time = " .. time);
		return uin, time;
	end,

	------------------------------点赞管理-----------------------------

	m_PriseLib = {},
	LoadPriseLib = function(self)
		print("LoadPriseLib:");
		if self.m_PriseLib and next(self.m_PriseLib) then

		else
			local k = "zoneprise";
			self.m_PriseLib = getkv(k, k) or {};

			if type(self.m_PriseLib) ~= "table" then
				print("LoadPriseLib:数据被写坏了:")
				self.m_PriseLib = {};
				self:SavePriseLib();
				return;
			end

			--清理7天之前的
			for k, v in pairs(self.m_PriseLib) do
				if k and v then
					if nil == v.last_time then
						--数据没有last_time, 都当没点过赞
						print("not has last_time: k = " .. k);
						v.last_time = 0;
					end

					if os.time() - v.last_time > (7 * 86400) then
						k = nil;
					end
				end
			end
		end

		print(LoadPriseLib);
	end,

	SavePriseLib = function(self)
		print("SavePriseLib:");
		local k = "zoneprise";
		setkv(k, self.m_PriseLib, k);
	end,

	SetPriseState = function(self, pid, bIsCai)
		print("SetPriseState:");
		self:LoadPriseLib();

		if not self:IsPrised(pid, bIsCai) then
			print("set state:");
			if bIsCai then
				--踩
				if self.m_PriseLib[pid] then
					self.m_PriseLib[pid].cai = true;
				else
					self.m_PriseLib[pid] = {};
					self.m_PriseLib[pid].cai = true;
				end
			else
				--赞
				if self.m_PriseLib[pid] then
					self.m_PriseLib[pid].zan = true;
				else
					self.m_PriseLib[pid] = {};
					self.m_PriseLib[pid].zan = true;
				end
			end

			self.m_PriseLib[pid].last_time = os.time();	--设置时间
			self:SavePriseLib();
		end
	end,

	IsPrised = function(self, pid, bIsCai)
		print("IsPrised: pid = " .. pid);
		self:LoadPriseLib();
		if self.m_PriseLib and next(self.m_PriseLib) then
			if self.m_PriseLib[pid] then
				if bIsCai then
					return self.m_PriseLib[pid].cai;
				else
					return self.m_PriseLib[pid].zan;
				end
			else
				return false;
			end
		else
			return false;
		end
	end,

	-----------------------------我的动态管理-------------------------
	--删除帖子
	DeleteDynamic = function(self, index)
		print("DeleteDynamic:");
		index = self.curDynamicIndex;

		if index > 0 and self.MyDataList and self.MyDataList.list and self.MyDataList.list[index] then
			print("index = " .. index);
			local callback_del = function(ret)
				print("callback_del:");
				print(ret);
				ShowLoadLoopFrame(false)
				if ret and ret.ret == 0 then
					print("删除动态成功");
					ShowGameTips(GetS(20583), 3);
					table.remove(self.MyDataList.list, index);
					--self.needPullMyList = true;
					self.bIsMyPageDirty = true;
					self:UpdateMyPage();

					--重新拉取朋友圈
					self.needPull = true;
					self.curFriendCircleCT = 0;
					self:PullDyanmicList(1);
				else
					--删除动态失败
					ShowGameTips(GetS(20565));
				end
			end

			local pid = self.MyDataList.list[index].pid;
			local url = ns_version.proxy_url .. '/miniw/posting?act=delete_posting' .. "&pid=" .. pid .. "&" .. http_getS2Act("posting");
			url = DynamicFrameUrlAddToken(url)
			print("DeleteDynamic", url );
			ShowLoadLoopFrame(true, "file:playercenter_new -- func:DeleteDynamic");
			ns_http.func.rpc( url, callback_del, nil, nil, true );
		end
	end,

	--置顶帖子
	SetTopDynamic = function(self)
		print("SetTopDynamic:");
		local index = self.curDynamicIndex;
		local bIsCancel = false;	--是否是取消置顶
		print("index = ", index);

		if index > 0 and self.MyDataList and self.MyDataList.list and self.MyDataList.list[index] then
			local list_node = self.MyDataList.list[self.curDynamicIndex];
			local pid = list_node.pid;

			local callback_settop = function(ret)
				print("callback_settop:");
				ShowLoadLoopFrame(false)
				if ret and ret.ret == 0 then
					print("置顶帖子成功");
					local node = deep_copy_table(self.MyDataList.list[index]);
					table.remove(self.MyDataList.list, index);
					table.insert(self.MyDataList.list, 1, node);
					self.MyDataList.top_pid = pid;
					self.bIsMyPageDirty = true;
					self.needPullMyList = true;
					self.curMyListCT = 0;
					-- self:UpdateMyPage();
					self:PullDyanmicList(2);
					getglobal("MyDynamicBox"):resetOffsetPos();

					if bIsCancel then
						ShowGameTips(GetS(20578), 3);	--已取消置顶
					else
						ShowGameTips(GetS(20577), 3);	--已置顶
					end
				else
					print("置顶帖子失败");
				end
			end

			if list_node and list_node.auth_see == 3 then
				--隐藏的帖子不可以置顶
				ShowGameTips(GetS(20584), 3);
				return;
			else

				if self.MyDataList.top_pid and self.MyDataList.top_pid == pid then
					--已置顶, 则是取消置顶, 把top_pid置为0.
					pid = 0;
					bIsCancel = true;
				end

				local url = ns_version.proxy_url .. '/miniw/posting?act=set_top' .. "&pid=" .. pid .. "&" .. http_getS2Act("posting");
				print( url );
				ShowLoadLoopFrame(true, "file:playercenter_new -- func:SetTopDynamic");
				ns_http.func.rpc( url, callback_settop, nil, nil, true );
			end
		end
	end,

	--设置帖子权限
	SetPostingAuth = function(self, bIsAll, ptype, pauth)
		--bIsAll: 是否是设置所有权限.
		print("SetPostingAuth:");
		print("ptype, pauth: ", ptype, pauth);

		local pid = 0;
		local MyDataList = {};
		if bIsAll then
			pid = "acc";
		else
			local index = self.curDynamicIndex;
			MyDataList = self.MyDataList.list[index];
			pid = MyDataList.pid;
		end

		local callback_auth = function(ret)
			print("callback_auth:");
			print(ret);
			ShowLoadLoopFrame(false)
			if ret and ret.ret == 0 then
				print("设置权限成功:");

				if bIsAll then
					if ptype == "see" then
						t_exhibition.auth_see = pauth;
					elseif ptype == "rep" then
						t_exhibition.auth_rep = pauth;
					end
					ZoneUpdateRepAndSeeUIState();
				else
					if ptype == "see" then
						MyDataList.auth_see = pauth;

						if pauth == 3 then
							ShowGameTips(GetS(20581), 3);	--已隐藏
						else
							ShowGameTips(GetS(20582), 3);	--已取消隐藏
						end
					elseif ptype == "rep" then
						MyDataList.auth_rep = pauth;

						if pauth == 3 then
							ShowGameTips(GetS(20579), 3);	--已关闭评论
						else
							ShowGameTips(GetS(20580), 3);	--已取消关闭评论
						end
					end

					-- self.needPullMyList = true;
					self.bIsMyPageDirty = true;
					self:UpdateMyPage();
				end
			else
				--设置权限失败
				-- ShowGameTips(GetS(20565));
			end
		end

		local url = ns_version.proxy_url .. '/miniw/posting?act=setPostingAuth' .. "&pid=" .. pid .. "&ptype=" .. ptype .. "&pauth=" .. pauth .. "&" .. http_getS2Act("posting");
		print( url );
		ShowLoadLoopFrame(true, "file:playercenter_new -- func:SetPostingAuth");
		ns_http.func.rpc( url, callback_auth, nil, nil, true );
	end,

	--更新ui上帖子权限的显示
	UpdatePostingAuth = function(self)
		print("UpdatePostingAuth:");
		local firstUI = "EditMenuFrameDialog";
		local topCommentTxt = getglobal(firstUI .. "Btn1Name");
		local closeCommentTxt = getglobal(firstUI .. "Btn2Name");
		local hideCommentTxt = getglobal(firstUI .. "Btn3Name");
		local index = self.curDynamicIndex;

		topCommentTxt:SetText(GetS(20557));			--置顶
		closeCommentTxt:SetText(GetS(20558));		--关闭
		hideCommentTxt:SetText(GetS(20559));		--隐藏

		if index > 0 and self.MyDataList and self.MyDataList.list and self.MyDataList.list[index] then
			print("ok:");
			local list_node = self.MyDataList.list[index];

			--1. 置顶
			if self.MyDataList.top_pid and self.MyDataList.top_pid == list_node.pid then
				topCommentTxt:SetText(GetS(20577));
			end

			--2. 关闭
			print("list_node.auth_rep:", list_node.auth_rep);
			if list_node.auth_rep and list_node.auth_rep == 3 then
				closeCommentTxt:SetText(GetS(20568));
			end

			--3. 隐藏
			print("list_node.auth_see:", list_node.auth_see);
			if list_node.auth_see and list_node.auth_see == 3 then
				hideCommentTxt:SetText(GetS(20569));
			end
		end
	end,

	--设置审核状态/置顶状态/隐藏状态
	SetState = function(self, list_node, cellUI)
		print("SetState:");
		local state = list_node.stat;

		--1. 审核状态
		local state_obj = getglobal(cellUI .. "State");
		state_obj:Show();

		if state == 0 then
			--审核中
			state_obj:SetText(GetS(20552));
		elseif state == 1 then
			--审核通过
			-- state_obj:SetText("帖子审核通过");
			state_obj:SetText("");
		elseif state == 2 then
			--审核失败
			state_obj:SetText(GetS(20554));
		elseif state == 3 then
			--隐藏私有
			state_obj:SetText(GetS(20555));
		elseif state == 4 then
			--帖子删除
			state_obj:SetText(GetS(20556));
		elseif state == 9 then
			--审核中
			state_obj:SetText(GetS(20552));
		elseif state == 10 then
			--国内环境 审核通过
			state_obj:SetText("");
		else
			state_obj:Hide();
		end

		print(self.MyDataList.top_pid);
		print(list_node.auth_see);

		local label = getglobal(cellUI .. "Label");
		local labelPic = getglobal(cellUI .. "LabelPic");
		local labelIcon = getglobal(cellUI .. "LabelIcon");
		label:Hide();
		if self.MyDataList.top_pid and self.MyDataList.top_pid == list_node.pid then
			--2. 置顶状态
			print("置顶:");
			label:Show();
			labelPic:SetTexUV("label_map_top");
			labelIcon:SetTexUV("icon_top");
		else
			--3. 隐藏状态
			if list_node.auth_see and list_node.auth_see == 3 then
				print("隐藏:");
				label:Show();
				labelPic:SetTexUV("label_map_hide");
				labelIcon:SetTexUV("icon_hide_white");
			end
		end

		--4. 关闭评论状态
		self:SetCommentBtnState(cellUI .. "CommentBtn", list_node.auth_rep);
	end,

	SetCommentBtnState = function(self, commentBtnUI, auth_rep)
		--如果auth_ret==3, 即不可回复, 则回复按钮置灰.
		print("SetCommentBtnState:");
		print("auth_ret=", auth_rep)
		local commentIcon = getglobal(commentBtnUI .. "Icon");
		local commentBtn = getglobal(commentBtnUI);

		if auth_rep and auth_rep == 3 then
			commentIcon:SetGray(true);
			commentBtn:Disable();
		else
			commentIcon:SetGray(false);
			commentBtn:Enable();
		end
	end,

	--------------------------空间嵌套跳转管理------------------------
	StoreRootData = function(self)
		--从跟空间跳转到其它空间, 要保存根空间数据
		print("StoreRootData:");
		getglobal("PlayerExhibitionCenter"):Hide();

		if m_ZoneStoreData.rootData.bIsRoot then
			print("store:ok:");
			if getglobal("FriendDynamicFrame"):IsShown() then
				--详情页
				self.curFrame = "FriendDynamicFrame";
			elseif getglobal("DynamicHandleFrame"):IsShown() then
				--我的动态页
				self.curFrame = "DynamicHandleFrame";
			else
				self.curFrame = "ZoneMainPage";
			end

			m_ZoneStoreData.rootData.bIsRoot = false;

			m_ZoneStoreData.rootData.needPull = self.needPull;
			m_ZoneStoreData.rootData.needPullMyList = self.needPullMyList;
			m_ZoneStoreData.rootData.needPullLatest = self.needPullLatest;
			m_ZoneStoreData.rootData.uin = self.uin;				--访问的空间的uin
			m_ZoneStoreData.rootData.curDynamicIndex = self.curDynamicIndex;
			m_ZoneStoreData.rootData.curCommentList = deep_copy_table(self.curCommentList);
			m_ZoneStoreData.rootData.curPicCount = 0;
			m_ZoneStoreData.rootData.bIsPublishing = self.bIsPublishing;
			m_ZoneStoreData.rootData.UploadedPicCount = self.UploadedPicCount;
			m_ZoneStoreData.rootData.bIsMainPageDirty = true;
			m_ZoneStoreData.rootData.bIsMyPageDirty = true;
			m_ZoneStoreData.rootData.bIsLatestPageDirty = true;

			m_ZoneStoreData.rootData.CircleList = deep_copy_table(self.CircleList);
			m_ZoneStoreData.rootData.MyDataList = deep_copy_table(self.MyDataList);
			m_ZoneStoreData.rootData.LatestList = deep_copy_table(self.LatestList);
			m_ZoneStoreData.rootData.DataList = deep_copy_table(self.DataList);
			m_ZoneStoreData.rootData.curPullType = self.curPullType or 1;
			m_ZoneStoreData.rootData.curFrame = self.curFrame;
		end
	end,

	ReStoreRootData = function(self)
		--恢复数据
		print("ReStoreRootData:");
		if m_ZoneStoreData.rootData.bIsRoot and m_ZoneStoreData.rootData.bNeedRestoreData then
			print("need restore:");
			m_ZoneStoreData.rootData.bNeedRestoreData = false;
			self.needPull 			= 	m_ZoneStoreData.rootData.needPull;
			self.needPullMyList 	= 	m_ZoneStoreData.rootData.needPullMyList;
			self.needPullLatest 	= 	m_ZoneStoreData.rootData.needPullLatest;
			self.uin 				= 	m_ZoneStoreData.rootData.uin;				--访问的空间的uin
			self.curDynamicIndex 	= 	m_ZoneStoreData.rootData.curDynamicIndex;
			self.curCommentList 	= 	deep_copy_table(m_ZoneStoreData.rootData.curCommentList);
			self.curPicCount 		= 	m_ZoneStoreData.rootData.curPicCount;
			self.bIsPublishing 		= 	m_ZoneStoreData.rootData.bIsPublishing;
			self.UploadedPicCount 	= 	m_ZoneStoreData.rootData.UploadedPicCount;
			self.bIsMainPageDirty 	= 	m_ZoneStoreData.rootData.bIsMainPageDirty;
			self.bIsMyPageDirty 	= 	m_ZoneStoreData.rootData.bIsMyPageDirty;
			self.bIsLatestPageDirty = 	m_ZoneStoreData.rootData.bIsLatestPageDirty;

			self.CircleList 		= 	deep_copy_table(m_ZoneStoreData.rootData.CircleList);
			self.MyDataList 		= 	deep_copy_table(m_ZoneStoreData.rootData.MyDataList);
			self.LatestList 		= 	deep_copy_table(m_ZoneStoreData.rootData.LatestList);
			self.DataList 			= 	deep_copy_table(m_ZoneStoreData.rootData.DataList);
			self.curPullType 		= 	m_ZoneStoreData.rootData.curPullType;
			self.curFrame			=	m_ZoneStoreData.rootData.curFrame;

			print("self.curFrame = ", self.curFrame);

			if string.find(self.curFrame, "FriendDynamicFrame") then
				--详情页
				print("111:");
				self:PullDynamicDetail(self.curDynamicIndex, self.curPullType);
				getglobal("FriendDynamicFrame"):Show();
			elseif string.find(self.curFrame, "DynamicHandleFrame") then
				--我的动态页
				print("222");
				-- getglobal("DynamicHandleFrame"):Show();
			end
		end
	end,

	ReStore2Root = function(self)
		--关闭空间的时候触发, 检查当前是否是需要恢复到根空间;
		print("ReStore2Root:");
		local bRet = false;
		print(m_ZoneStoreData.rootData.bIsRoot);
		if m_ZoneStoreData.rootData.bIsClickCloseBtn and m_ZoneStoreData.rootData.bIsRoot == false then
			--如果当前在非根空间, 且点击close按钮, 那么需要退回主空间
			print("ReStore2Root:ok:");
			m_ZoneStoreData.rootData.bIsRoot = true;
			m_ZoneStoreData.rootData.bIsClickCloseBtn = false;

			if string.find(self.curFrame, "ZoneMainPage") then
				--主页
				print("主页");
				m_ZoneStoreData.rootData.bNeedRestoreData = false;	--主页不用恢复数据
				OpenNewPlayerCenter(m_ZoneStoreData.rootData.uin);
			elseif string.find(self.curFrame, "FriendDynamicFrame") then
				--详情页
				print("详情页");
				-- self:PullDynamicDetail(self.curDynamicIndex, self.curPullType);
				m_ZoneStoreData.rootData.bNeedRestoreData = true;
				OpenNewPlayerCenter(m_ZoneStoreData.rootData.uin);
				--详情页要恢复数据, 并且要在Init()函数之后, 不然就被Init函数覆盖了.

			elseif string.find(self.curFrame, "DynamicHandleFrame") then
				print("我的动态页");
				m_ZoneStoreData.rootData.bNeedRestoreData = true;
				OpenNewPlayerCenter(m_ZoneStoreData.rootData.uin);
			end

			--切到动态页标签
			ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabDynamic);

			bRet = true;
		end

		return bRet;
	end,

	Step2FriendZone = function(self, nType, id)
		--跳转好友空间
		--nType == 1: 主页; nType == 2: 我的动态页; nType == 3: 详情页;
		print("Step2FriendZone: nType = " .. nType);
		local DataList = nil;
		if nType == 1 then
			DataList = self.CircleList;
			if DataList and DataList.list and DataList.list[id] then
				local op_uin, time = self:ParseUinByPid(DataList.list[id].pid);

				op_uin = tonumber(op_uin) or 0;

				if self:CanJumpZone(op_uin) then
					self:StoreRootData();
					getglobal("DynamicHandleFrame"):Hide();

					OpenNewPlayerCenter(op_uin);
				end
			end
		elseif nType == 2 then


		elseif nType == 3 then
			local op_uin = 0;
			local commentData = self.curCommentList;
			if commentData and commentData.list and commentData.list[id] then
				op_uin = commentData.list[id].uin or 0;

				if self:CanJumpZone(op_uin) then
					self:StoreRootData();
					getglobal("FriendDynamicFrame"):Hide();
					if getglobal("DynamicHandleFrame"):IsShown() then
						getglobal("DynamicHandleFrame"):Hide();
					end

					if getglobal("DynamicPublishFrame"):IsShown() then
						getglobal("DynamicPublishFrame"):Hide();
					end

					OpenNewPlayerCenter(op_uin);
				end
			end
		else

		end
	end,

	CanJumpZone = function(self, op_uin)
		--判断是否满足跳转条件
		print("CanJumpZone:");
		local bRet = true;
		local my_uin = GetMyUin();

		if op_uin and op_uin > 0 and op_uin ~= self.uin and op_uin ~= my_uin then
			--不能跳转到自己
			if m_ZoneStoreData.rootData.uin and m_ZoneStoreData.rootData.uin == op_uin then
				--不能跳转回根, 只能通过关闭回到根空间
				bRet = false;
			end
		else
			bRet = false;
		end

		print(bRet);
		return bRet;
	end,

	--------------------------动态举报------------------------

	--点击动态后
	GetPid = function(self,index)
		if self.DataList ==nil or self.DataList.list ==nil then return nil end

		local list_node
		if index and index >0 then
			list_node = self.DataList.list[index];
		else
			list_node = self.DataList.list[self.curDynamicIndex];
		end

		if list_node == nil  then return nil end

		local pid = list_node.pid;
		return pid;
	end,

	--获取动态评论举报、删除、加入黑名单用到的信息
	GetReportCommentInfo = function(self,index)
		print("信息查询")
		print(index);
		if index and index > 0 then
			local commentData = self.curCommentList;
			if commentData and commentData.list and commentData.list[index] then
				local list_node = commentData.list[index];
				return list_node.pid_uin.."_"..list_node.pid_ct, list_node.uin, list_node.last_time, list_node, commentData.role_info_list;
			end
		end
		return nil
	end,

	CheckReportCommentState = function(self, index)
		if index and index > 0 then
			local commentData = self.curCommentList;
			if commentData and commentData.list and commentData.list[index] then
				local list_node = commentData.list[index];
				return list_node.black_stat;
			end
		end
		return nil
	end;

	CheckDynamicState = function(self,index)
		if index and index >0 then
			local list = self.DataList.list;
			if list and list[index] then
				local black_stat = list[index].black_stat or nil ; --1=审核中  nil=未进入审核池
				return black_stat
			end
		end
		return nil
	end,

	AddMyComment = function(self, pid, ctime, _time, _pid_uin, content,_ipaddress)
		if IsOverseasVer() or isAbroadEvn() then
			return
		end

		if not self.myCommentList[GetMyUin()] then
			self.myCommentList[GetMyUin()] = {}
		end

		table.insert(self.myCommentList[GetMyUin()], {
			pid_ = pid,
			uin = GetMyUin(),
			last_time = ctime,
			pid_ct = _time,
			pid_uin = tonumber(_pid_uin);
			content = unescape(content),
			op_uin = 0,
			location = _ipaddress,
		});
	end,

	DeleteMyComment = function(self, pid, last_time)
		if self.myCommentList[GetMyUin()] then
			local mclist = self.myCommentList[GetMyUin()]
			for i = 1, #mclist do
				if mclist[i].pid_ and mclist[i].pid_ == pid and mclist[i].pid_ct and mclist[i].last_time == last_time then
					table.remove(self.myCommentList[GetMyUin()], i);
					break
				end
			end
		end
	end,
};

--动态初始化
function ZoneDynamicInit(uin)
	print("ZoneDynamicInit:");
	m_ZoneDynamicMgrParam:Init(uin);
end

--点击动态tab按钮, 打开动态页
function ZoneDynamicTabOnClick()
	print("ZoneDynamicTabOnClick:");
	-- statisticsGameEvent(51100, '%d', 3);

	--切到第一个tab页(关注动态)
	DynamicHandleTabBtnTemplate_OnClick(1);

	if t_exhibition:isLookSelf() then
		--访问自己是拉取朋友圈
		--红点
		if ZoneGetPostingRedTagState() then
			getglobal("ExhibitionInfoMorePostingRedTag"):Show();
		end
	else
		--访问别人是拉取别人的动态

	end
end

--关闭空间, 恢复到上一个空间
function ZoneReStore2Root()
	print("ZoneReStore2Root:");
	local bRet = m_ZoneDynamicMgrParam:ReStore2Root();

	return bRet;
end

--点击关闭按钮, 设置恢复标志位
function ZoneCloseBtnClick_SetReStoreState()
	print("ZoneCloseBtnClick_SetReStoreState:");
	m_ZoneStoreData.rootData.bIsClickCloseBtn = true;
end

function DynamicPublishFrameCloseBtn_OnClick()
	getglobal("DynamicPublishFrameTextEdit"):SetText("");
	getglobal("DynamicPublishFrame"):Hide();
	t_share_data:ShowNextRewardDisplay();
end

--发布动态按钮
function DynamicPublishFrameCommitBtn_OnClick()
	--1. 上传图片 2. OnUpdate中检测是否全部上传完成 3. 图片全部上传完成, 发布动态
	-- m_ZoneDynamicMgrParam:PushDynamic();
	if ns_data.IsGameFunctionProhibited("p", 10585, 10586) then -- 禁止发布动态
		return
	end

	if checkSafetyModifyRef and not checkSafetyModifyRef() then
		return
	end

	local content = getglobal("DynamicPublishFrameTextEdit"):GetText() or "";
	--敏感词检测
	if DefMgr:checkFilterString(content) then
		ShowGameTipsWithoutFilter(GetS(9200100), 3)
		getglobal("DynamicPublishFrameTextEdit"):Clear()
		return
	end


	if content == nil or content == "" then
		ShowGameTips(GetS(20562));	--请输入内容
		return;
	end

	ShowLoadLoopFrame(true, "file:playercenter_new -- func:DynamicPublishFrameCommitBtn_OnClick");
	if m_ZoneDynamicMgrParam.curPicCount and m_ZoneDynamicMgrParam.curPicCount > 0 then
		for i = 1, m_ZoneDynamicMgrParam.curPicCount do
			if ShareToDynamic.isShareDynamic and i ==1 then
				ShareToDynamic:UploadPicture(i);
			else
				m_ZoneDynamicMgrParam:UploadPicture(i);
			end
		end
	else
		m_ZoneDynamicMgrParam:PushDynamic();
	end

	-- 提交分享动态任务
	local midautuInterface = GetInst("MidautuInterface")
	if midautuInterface then 
		midautuInterface:SubmitShareTaskFinish()
	end 
end

--清空动态编辑
function DynamicPublishFrameCleanBtn_OnClick()
	m_ZoneDynamicMgrParam:InitPublishFrame();
	getglobal("DynamicPublishFrameTextEdit"):SetText("");
	getglobal("DynamicLinkEditFrameLinkEdit"):SetText("");
	getglobal("DynamicLinkEditFrameTitleEdit"):SetText("");
	getglobal("DynamicPublishFrameDynamicLink"):Hide();
end

function DynamicPublishFrame_OnShow()
	print("DynamicPublishFrame_OnShow:");
	getglobal("DynamicPublishFrameEditDefaultTxt"):Show();
	m_ZoneDynamicMgrParam:InitPublishFrame();
end

function DynamicPublishFrame_OnHide()
	print("DynamicPublishFrame_OnHide:");
	ShareToDynamic:Reset();
	while ClientCurGame:isInGame() and  ClientCurGame:isOperateUI() and getglobal("PlayerExhibitionCenter"):IsShown() == false do
		ClientCurGame:setOperateUI(false)
	end
	if ClientCurGame:isInGame() and GetShareScene() and string.find(GetShareScene(), "Battle", 1) then 
		ClientCurGame:setOperateUI(true)
	end
end

function DynamicPublishFrame_OnUpdate()

end

--插入图片按钮
function DynamicPublishFrameInsertPicBtn_OnClick()
	--13岁保护模式:不让上传图片
	if IsProtectMode() then
		ShowGameTips(GetS(4842), 3);
		return;
	end

	m_ZoneDynamicMgrParam:AddPicture();
end

--重新设置按钮位置--m_ZoneDynamicMgrParam.curPicCount
function ZoneDynamicInsertPicBtnPos()
	local picBtn = getglobal("DynamicPublishFrameInsertPicBtn");
	local num = m_ZoneDynamicMgrParam.curPicCount==3 and 2 or m_ZoneDynamicMgrParam.curPicCount
	picBtn:SetPoint("topleft","DynamicPublishFrameDynamicPic","topleft", 5+num*140, 0)
	if m_ZoneDynamicMgrParam.curPicCount==3 then
		picBtn:Hide();
	else
		if ns_version and check_apiid_ver_conditions(ns_version.posting_pic, false) then
			picBtn:Show();
		end
	end
end

--删除图片
function DynamicPublishFrameDynamicPicDel_OnClick(id)
	print("DynamicPublishFrameDynamicPicDel_OnClick,id=", id);
	m_ZoneDynamicMgrParam:DeletePic(id);

	ZoneDynamicInsertPicBtnPos()
end

--插入连接按钮
function DynamicPublishFrameInsertLinkBtn_OnClick()
	getglobal("DynamicLinkEditFrame"):Show();
	local link_ = m_ZoneDynamicMgrParam.curLink;
	local linkTitle_ = m_ZoneDynamicMgrParam.curLinkTitle
	if link_ then
		getglobal("DynamicLinkEditFrameEditBkg"):Show();
		getglobal("DynamicLinkEditFrameLinkEdit"):SetText(link_);
		getglobal("DynamicLinkEditFrameEditDefaultTxt"):Hide()
	else
		DynamicLinkEditFrameLinkEdit_OnFocusLost()
	end

	if linkTitle_ then
		getglobal("DynamicLinkEditFrameLinkEdit"):Show()
		getglobal("DynamicLinkEditFrameTitleEdit"):SetText(linkTitle_)
		getglobal("DynamicLinkEditFrameEditDefaultTxt2"):Hide()
	else
		DynamicLinkEditFrameTitleEdit_OnFocusLost()
	end
end

--发布评论按钮
function FriendDynamicFrameEditSendBtn_OnClick()
	--游客模式限制功能
	if not FunctionLimitCtrl:IsNormalBtnClick(FunctionType.PL_HOMEPAGE_COMMENT) then
		return 
	end

	if GetInst("CreditScoreService"):CheckLimitAction(GetInst("CreditScoreService"):GetTypeTbl().dynamic_comment) then
        return
    end

	--敏感词检测
	local edit = getglobal("FriendDynamicFrameEditTextEdit")
	local editText = edit:GetText()
	if DefMgr:checkFilterString(editText) then
		ShowGameTipsWithoutFilter(GetS(9200100), 3)
		edit:Clear()
		return
	end

	if false == AccountSafetyCheck:FunCheck(AccountSafetyCheck.FunType.DYNAMIC_COMMENT, FriendDynamicFrameEditSendBtn_OnClick) then
		return
	end

	if ns_data.IsGameFunctionProhibited("pc", 10587, 10588) then 
		return; 
	end

	getglobal("FriendDynamicFrameEdit"):Hide();
	m_ZoneDynamicMgrParam:AddComment();
end

--回车键
function FriendDynamicFrameEditTextEdit_OnEnterPressed()
	FriendDynamicFrameEditSendBtn_OnClick();
end

--有输入, 去掉"回复XXX"
function FriendDynamicFrameEditTextEdit_OnTextSet()
	print("FriendDynamicFrameEditTextEdit_OnTextSet:");
	local defaultText = getglobal("FriendDynamicFrameEditEditDefaultTxt");

	if defaultText:IsShown() then
		defaultText:Hide();
	end

	--警告提示
	local wangText = getglobal("FriendDynamicFrameEditEditWarnTxt");
	if wangText:IsShown() then
		wangText:Hide();
	end
end

-- 点击评论输入框
function FriendDynamicFrameEditTextEdit_OnFocusGained()
	if GetInst("CreditScoreService"):CheckLimitAction(GetInst("CreditScoreService"):GetTypeTbl().dynamic_comment) then
		getglobal("FriendDynamicFrameEditTextEdit"):enableEdit(false)
    else
		getglobal("FriendDynamicFrameEditTextEdit"):enableEdit(true)
    end
end

--主页面"点赞"按钮
function FriendDynamicTemplatePriseBtn_OnClick(nType)
	--nType == 1: 点赞.
	--nType == 2: 踩.
	local index = this:GetParentFrame():GetClientID();
	local cellUI = this:GetParentFrame():GetName();
	
	if IsLookSelf() then
		standReportEvent("7", "PERSONAL_INFO_UPDATES", "Like", "click")
	else
		standReportEvent("43", "PLAYER_INFO_UPDATES", "Like", "click")
	end
	if nType == 2 then
		--踩
		m_ZoneDynamicMgrParam:PrizeDynamic(index, true, cellUI);
	else

		local black_stat = m_ZoneDynamicMgrParam:CheckDynamicState(index)
		if black_stat == 1 or black_stat == 2 then
			ShowGameTipsWithoutFilter(GetS(10574));
			return
		end
		--赞
		m_ZoneDynamicMgrParam:PrizeDynamic(index, false, cellUI);
	end
end

--我的动态详情页"点赞"按钮
function FriendDynamicFrameInfoPraiseBtn_OnClick(nType)
	if ns_data.IsGameFunctionProhibited("pc", 10587, 10588) then 
		return; 
	end
	local index = m_ZoneDynamicMgrParam.curDynamicIndex;
	local cellUI = this:GetParentFrame():GetName();

	if m_ZoneDynamicMgrParam.DataList 
	and m_ZoneDynamicMgrParam.DataList.list 
	and m_ZoneDynamicMgrParam.DataList.list[m_ZoneDynamicMgrParam.curDynamicIndex] then
		local black_stat = m_ZoneDynamicMgrParam.DataList.list[m_ZoneDynamicMgrParam.curDynamicIndex].black_stat;
		if black_stat == 1 or black_stat == 2 then 
			-- 该动态已违规，无法点赞
			ShowGameTipsWithoutFilter(GetS(10574));
			return
		end
	end

	if nType == 2 then
		--踩
		m_ZoneDynamicMgrParam:PrizeDynamic(index, true, cellUI);
	else
		--赞
		m_ZoneDynamicMgrParam:PrizeDynamic(index, false, cellUI);
	end

	m_ZoneDynamicMgrParam.bIsMainPageDirty = true;
end

-- 动态管理按钮
function DynamicPublishFrameManageBtn_OnClick()
	-- getglobal("DynamicPublishFrame"):Hide();
	getglobal("DynamicHandleFrame"):Show();
	-- statisticsGameEvent(51100, '%d', 1);

	--press_btn("DynamicHandleFrameTabBtn1");
end

function DynamicHandleFrameCloseBtn_OnClick()
	getglobal("DynamicHandleFrame"):Hide();

	--如果进行了评论, 那么重新拉取朋友圈
	m_ZoneDynamicMgrParam.curMyListCT = 0;
	m_ZoneDynamicMgrParam:PullDyanmicList(1);
	-- m_ZoneDynamicMgrParam:PullDyanmicList(2);
end

--返回朋友圈顶部按钮
function ExhibitionInfoPage2Go2Top_OnClick()
	getglobal("ExhibitionInfoPage2CommentSlider"):resetOffsetPos();
end

-----------------------------------------链接编辑界面-----------------------------------------------------------

--输入链接按钮
function DynamicLinkEditFrameInputLinkBtn_OnClick()
	getglobal("DynamicLinkEditFrameEditBkg"):Show();
	getglobal("DynamicLinkEditFrameLinkEdit"):Show();
	getglobal("DynamicLinkEditFrameLinkEdit"):SetText("");
	getglobal("DynamicLinkEditFrameTitleEdit"):SetText("");
end

--清空按钮
function DynamicLinkEditFrameCancleBtn_OnClick()
	getglobal("DynamicLinkEditFrameLinkEdit"):SetText("");
	getglobal("DynamicLinkEditFrameTitleEdit"):SetText("");
end

--确定按钮
function DynamicLinkEditFrameDeterBtn_OnClick()
	m_ZoneDynamicMgrParam:AddLink();
end

function DynamicLinkEditFrameCloseBtn_OnClick()
	getglobal("DynamicLinkEditFrame"):Hide();
end

function DynamicLinkEditFrameLinkEdit_OnFocusLost()
	local text = getglobal("DynamicLinkEditFrameLinkEdit"):GetText();
	if text == "" then
		getglobal("DynamicLinkEditFrameEditDefaultTxt"):Show();
	else
		getglobal("DynamicLinkEditFrameEditDefaultTxt"):Hide();
	end
end

function DynamicLinkEditFrameLinkEdit_OnFocusGained()
	getglobal("DynamicLinkEditFrameEditDefaultTxt"):Hide();
end

function DynamicLinkEditFrameTitleEdit_OnFocusLost()
	local text = getglobal("DynamicLinkEditFrameTitleEdit"):GetText();
	if text == "" then
		getglobal("DynamicLinkEditFrameEditDefaultTxt2"):Show();
	else
		getglobal("DynamicLinkEditFrameEditDefaultTxt2"):Hide();
	end
end

function DynamicLinkEditFrameTitleEdit_OnFocusGained()
	getglobal("DynamicLinkEditFrameEditDefaultTxt2"):Hide();
end


-------------------------------------动态管理页面--------------------------------------------------------------------------
function DynamicHandleFrame_OnLoad()
	print("DynamicHandleFrame_OnLoad:");
	
	--tab按钮:
	local nameIds = {
		20525,	--1. 新增:关注动态
		20515, 	--2. 我的动态
		20516,	--3. 最近回复
	};

	for i = 1, #nameIds do
		local btnname = getglobal("DynamicHandleFrameTabBtn" .. i .. "Name");
		btnname:SetText(GetS(nameIds[i]));
	end
end

function DynamicHandleFrame_OnShow()
	print("DynamicHandleFrame_OnShow:");

	if ZoneGetPostingRedTagState() then
		--有最近回复, tab切到最近回复
		ZoneSetPostingRedTagState(false, false);
		DynamicHandleTabBtnTemplate_OnClick(2);
	else
		DynamicHandleTabBtnTemplate_OnClick(1);
	end
end

function DynamicHandleFrame_OnHide()
	print("DynamicHandleFrame_OnHide:");

end

--动态管理: tab按钮, 1: 我的动态, 2:最近回复
function DynamicHandleTabBtnTemplate_OnClick(id)
	print("DynamicHandleTabBtnTemplate_OnClick:");
	if id then id = id; else id = this:GetClientID(); end

	local frameUIList = {
		"ExhibitionInfoPage2CommentSlider",	--1. 关注动态(朋友圈)
		"MyDynamicBox",		--2. 我的动态
		"LatestDynamicBox", --3. 最近回复
	};
	if EnterMainMenuInfo.PlayerCenterBackInfo then
		EnterMainMenuInfo.PlayerCenterBackInfo.selectTab = id
	end
	for i = 1, 3 do
		local btnui = "DynamicHandleFrameTabBtn" .. i;
		local name = getglobal(btnui .. "Name");
		local Checked = getglobal(btnui .. "Checked");
		local page = getglobal(frameUIList[i]);

		if i == id then
			name:SetTextColor(76, 76, 76);
			Checked:Show();
			page:Show();
		else
			name:SetTextColor(191, 228, 227);
			Checked:Hide();
			page:Hide();
		end
	end

	print("id = ", id);

	if id == 1 then
		--关注动态(朋友圈)
		--是自己, 则拉取朋友圈, 是别人, 则拉取'我的动态'
		local tb = {
			"-",
			"Updates",
			"Comment",
			"Like",
			"Avatar",
		}
		
		if t_exhibition:isLookSelf() then
			for _, value in ipairs(tb) do
				standReportEvent("7", "PERSONAL_INFO_UPDATES", value, "view")
			end
			m_ZoneDynamicMgrParam:PullDyanmicList(1);
			standReportEvent("7", "PERSONAL_INFO_UPDATES", "SendUpdatesButton", "view")
		else
			for index=1,4 do
				standReportEvent("43", "PLAYER_INFO_UPDATES", tb[index], "view")
			end
			m_ZoneDynamicMgrParam:PullDyanmicList(2);
		end
	elseif id == 2 then
		--我的动态
		standReportEvent("7", "MY_UPDATES", "-", "view")
		m_ZoneDynamicMgrParam:PullDyanmicList(2);
	elseif id == 3 then
		--最近回复
		standReportEvent("7", "RECENT_REPLY", "-", "view")
		m_ZoneDynamicMgrParam:PullDyanmicList(3);
		-- statisticsGameEvent(51100, '%d', 2);
	end
end

--点击"我的动态条目"
function MyDynamicTemplate_OnClick(id)
	--打开详情页
	if id then id = id; else id = this:GetClientID(); end
	standReportEvent("7", "MY_UPDATES", "Updates", "click",{slot=tostring(id)})
	if id and id > 0 then
		OpenFriendDynamicFrame(id, false, 2);
	end
end

function MyDynamicTemplateMore_OnClick()
	local id = this:GetParentFrame():GetClientID();
	MyDynamicTemplate_OnClick(id);
end

--点击"最近回复"条目
function LatestDynamicTemplate_OnClick()
	local id = this:GetClientID();
	if id and id > 0 then
		local pid = OpenFriendDynamicFrame(id, false, 3);
		local tb = {}
		if pid then
			local uin = ""
			local pos = string.find(pid, "_");
			if pos > 0 then
				uin = string.sub(pid, 0, pos - 1);
			end
			tb.standby1 = uin
			tb.slot = tostring(id)
		end
		standReportEvent("7", "RECENT_REPLY", "Reply", "click", tb)
	end
end

--编辑按钮
function MyDynamicTemplateFunc_OnClick()
	local id = this:GetParentFrame():GetClientID();
	local ui = this:GetName();
	standReportEvent("7", "MY_UPDATES", "MyUpdatesMore", "click",{slot=tostring(id)})
	ShowEditMenuFrame(id, ui);
	m_ZoneDynamicMgrParam.curDynamicIndex = id;
	m_ZoneDynamicMgrParam:UpdatePostingAuth();
end

-------------------------------------编辑菜单页面--------------------------------------------------------------------------
function ShowEditMenuFrame(id, ui)
	print("ShowEditMenuFrame: id = " .. id .. ", ui = " .. ui);

	local btn = getglobal(ui);
	-- local top = btn:GetTop();

	getglobal("EditMenuFrameDialog"):SetPoint("topright", ui, "bottom", 21, 0);
	getglobal("EditMenuFrame"):Show();
end

function EditMenuFrame_OnShow()
	print("EditMenuFrame_OnShow:");
	local tb = {
		"-",
		"StickPost",
		"CloseComment",
		"Conceal",
		"Delete"
	}
	for _, value in ipairs(tb) do
		standReportEvent("7", "MY_UPDATES_MORE_POPUP", value, "view")
	end
end

function EditMenuFrame_OnHide()
	print("EditMenuFrame_OnHide:");
end

function EditMenuFrame_OnClick()
	getglobal("EditMenuFrame"):Hide();
end

--删除
function EditMenuFrameDeleteBtn_OnClick()
	getglobal("EditMenuFrame"):Hide();
	standReportEvent("7", "MY_UPDATES_MORE_POPUP", "Delete", "click")
	m_ZoneDynamicMgrParam:DeleteDynamic();
end

--置顶
function EditMenuFrameTopBtn_OnClick()
	getglobal("EditMenuFrame"):Hide();
	standReportEvent("7", "MY_UPDATES_MORE_POPUP", "StickPost", "click")
	m_ZoneDynamicMgrParam:SetTopDynamic();
end

--关闭评论
function EditMenuFrameCloseCommentBtn_OnClick()
	--关闭评论: 即设置回复权限为仅自己
	getglobal("EditMenuFrame"):Hide();
	standReportEvent("7", "MY_UPDATES_MORE_POPUP", "CloseComment", "click")
	if m_ZoneDynamicMgrParam.MyDataList.list then
		local index = m_ZoneDynamicMgrParam.curDynamicIndex;
		local list_node = m_ZoneDynamicMgrParam.MyDataList.list[index];

		if list_node and list_node.auth_rep == 3 then
			--当前是仅自己->设置成所有人
			m_ZoneDynamicMgrParam:SetPostingAuth(false, "rep", 0);
		else
			--设置成仅自己
			m_ZoneDynamicMgrParam:SetPostingAuth(false, "rep", 3);
		end
	end
end

--隐藏评论
function EditMenuFrameHideCommentBtn_OnClick()
	--隐藏: 即设置查看权限为仅自己
	getglobal("EditMenuFrame"):Hide();
	standReportEvent("7", "MY_UPDATES_MORE_POPUP", "Conceal", "click")
	if m_ZoneDynamicMgrParam.MyDataList.list then
		local index = m_ZoneDynamicMgrParam.curDynamicIndex;
		local list_node = m_ZoneDynamicMgrParam.MyDataList.list[index];

		if list_node and list_node.auth_see == 3 then
			--当前是仅自己->设置成所有人
			m_ZoneDynamicMgrParam:SetPostingAuth(false, "see", 0);
		else
			--设置成仅自己
			m_ZoneDynamicMgrParam:SetPostingAuth(false, "see", 3);
		end
	end
end

-------------------------------------好友动态页面：详情页--------------------------------------------------------------------------
function FriendDynamicFrameCloseBtn_OnClick()
	getglobal("FriendDynamicFrame"):Hide();
end

--滑动拉取评论
function FriendDynamicFrameReplyBox_OnMovieFinished()
	if getglobal("LoadLoopFrame"):IsShown() then
		print("正在转圈:");
		return;
	end

	m_ZoneDynamicMgrParam:PullComment();
end

--滑动拉取朋友圈
function ExhibitionInfoPage2CommentSlider_OnMovieFinished()
	if getglobal("LoadLoopFrame"):IsShown() then
		print("正在转圈:");
		return;
	end

	m_ZoneDynamicMgrParam.needPull = true;
	m_ZoneDynamicMgrParam:PullDyanmicList(1);
end

function ExhibitionInfoPage2CommentSlider_OnMouseWheel()
	ExhibitionInfoPage2CommentSlider_SetGotoTopBtnState();
end

function ExhibitionInfoPage2CommentSlider_SetGotoTopBtnState()
	--print("ExhibitionInfoPage2CommentSlider_SetGotoTopBtnState:");
	-- local gotoTopBtn = getglobal("ExhibitionInfoPage2Go2Top");
	local curOffsetY = getglobal("ExhibitionInfoPage2CommentSlider"):getCurOffsetY();

	--print("Page2CommentSlider:curOffsetY = ", curOffsetY);
	if curOffsetY < -10 then
		-- gotoTopBtn:Show();
	else
		-- gotoTopBtn:Hide();
	end
end

--滑动拉取"我的动态"
function MyDynamicBox_OnMovieFinished()
	if getglobal("LoadLoopFrame"):IsShown() then
		print("正在转圈:");
		return;
	end

	m_ZoneDynamicMgrParam.needPullMyList = true;
	m_ZoneDynamicMgrParam:PullDyanmicList(2);
end

--滑动拉取"最近回复"
function LatestDynamicBox_OnMovieFinished()
	if getglobal("LoadLoopFrame"):IsShown() then
		print("正在转圈:");
		return;
	end

	m_ZoneDynamicMgrParam.needPullLatest = true;
	m_ZoneDynamicMgrParam:PullDyanmicList(3);
end

--点击图片查看大图
function FriendDynamicFrameInfoPicBtn_OnClick(id)
	print(id);
	local filename = this:GetClientString();

	if filename and filename ~= "" then
		ZoneOpenPicDisplayFrame(filename);
	end
end

--点击主页"朋友圈条目", 打开详情页
function FriendDynamicTemplate_OnClick(id, isEdit)
	if checkSafetyModifyRef and not checkSafetyModifyRef() then
		return
	end

	if id then id = id; else id = this:GetClientID(); end
	
	if t_exhibition:isLookSelf() then
		local pid = OpenFriendDynamicFrame(id, isEdit);
		local tb = {slot=tostring(id)}
		if pid then
			local uin = ""
			local pos = string.find(pid, "_");
			if pos > 0 then
				uin = string.sub(pid, 0, pos - 1);
			end
			local myUin = tostring(AccountManager:getUin())
			tb.standby1 = uin == myUin and "1" or "2"
			tb.standby2 = uin
		end
		standReportEvent("7", "PERSONAL_INFO_UPDATES", "Updates", "click", tb)
	else
		standReportEvent("43", "PLAYER_INFO_UPDATES", "Updates", "click", {slot=tostring(id)})
		OpenFriendDynamicFrame(id, isEdit, 2);
	end
end

--点击"主页头像"跳转好友空间
function FriendDynamicTemplateHeadBtn_OnClick()
	local id = this:GetParentFrame():GetClientID();
	standReportEvent("7", "PERSONAL_INFO_UPDATES", "Avatar", "click")
	m_ZoneDynamicMgrParam:Step2FriendZone(1, id);

end

--点击"详情页头像"跳转好友空间
function FriendDynamicReplyTemplateHead_OnClick()
	local id = this:GetParentFrame():GetClientID();

	m_ZoneDynamicMgrParam:Step2FriendZone(3, id);
end

--更多按钮
function FriendDynamicTemplateMoreBtn_OnClick()
	local id = this:GetParentFrame():GetClientID();

	FriendDynamicTemplate_OnClick(id);
end

function FriendDynamicTemplateCommentBtn_OnClick(id)
	if id then id = id; else id = this:GetParentFrame():GetClientID(); end
	if IsLookSelf() then
		standReportEvent("7", "PERSONAL_INFO_UPDATES", "Comment", "click")
	else
		standReportEvent("43", "PLAYER_INFO_UPDATES", "Comment", "click")
	end
	local black_stat = m_ZoneDynamicMgrParam:CheckDynamicState(id)
	if black_stat == 1 or black_stat == 2 then
		ShowGameTipsWithoutFilter(GetS(10574)) --无法对审核中的动态进行操作
		return
	end

	FriendDynamicTemplate_OnClick(id, true);
end

--打开好友动态页面
function OpenFriendDynamicFrame(id, isEdit, nPullType)
	print("OpenFriendDynamicFrame: id = " .. id);

	if isEdit then
		m_ZoneDynamicMgrParam:OpenCommentEditFrame(0);
	else
		getglobal("FriendDynamicFrameEdit"):Hide();
	end

	local pid = m_ZoneDynamicMgrParam:PullDynamicDetail(id, nPullType);
	getglobal("FriendDynamicFrame"):Show();
	return pid
end

--function FriendDynamicFrame_OnLoad()
	--print("FriendDynamicFrame_OnLoad:");
	-- LayoutFriendDynamic();
	-- LayoutZoneMyDynamic();
	-- LayoutZoneLatestDynamic();
--end

function FriendDynamicFrame_OnClick()
	getglobal("FriendDynamicFrameCommentFunc"):Hide();
end

function FriendDynamicFrameInfo_OnClick()
	getglobal("FriendDynamicFrameCommentFunc"):Hide();
end
function FriendDynamicFrame_OnShow()
	getglobal("FriendDynamicFrameInfo"):Hide();
	getglobal("FriendDynamicFrameReplyBox"):Hide();
	getglobal("FriendDynamicFrameEmptyBkg"):Show();
	getglobal("FriendDynamicFrameEmptyTips"):Show();
	getglobal("ExhibitionInfoPage2CommentSlider"):setDealMsg(false)
	getglobal("MyDynamicBox"):setDealMsg(false)
	getglobal("LatestDynamicBox"):setDealMsg(false)
end

function FriendDynamicFrame_OnHide()
	getglobal("FriendDynamicFrameCommentFunc"):Hide();
	--清理输入框
	getglobal("FriendDynamicFrameEditTextEdit"):Clear();
	getglobal("ExhibitionInfoPage2CommentSlider"):setDealMsg(true)
	getglobal("MyDynamicBox"):setDealMsg(true)
	getglobal("LatestDynamicBox"):setDealMsg(true)
	--退回主界面, 刷新一下主界面
	if getglobal("LatestDynamicBox"):IsShown() then
		m_ZoneDynamicMgrParam:PullDyanmicList(3);
	end
	m_ZoneDynamicMgrParam:UpdateMainPage();
	m_ZoneDynamicMgrParam:UpdateMyPage();
end

--分享跳转地图
function FriendDynamicFrameJumpBtn_OnClick()
	local detailData = m_ZoneDynamicMgrParam.curDynamicDetail;
	print(detailData);

	if detailData and detailData.posting then
		print("ok:");
		local action = detailData.posting.action;
		local action_url = detailData.posting.action_url;

		print("action", action);
		print("action_url", action_url);

		if action then
			getglobal("FriendDynamicFrame"):Hide();

			if action and (action == 25 or action == 98 or action ~= 99) then
				--跳转地图详情, 不关闭个人中心页面.因为地图如果分享后又取消分享则跳不过去.
				--家园特殊处理
				local uin = AccountManager:getUin()
				if detailData.posting.pid then
					strs = StringSplit(detailData.posting.pid, '_')
					uin = tonumber(strs[1])
				end
				local owid = tonumber(detailData.posting.action_url) or 0
				if tonumber(SpecialHomeLandWorldID())==owid then
					ShowGameTips(GetS(9170), 3)
					return 
				elseif gFunc_IsHomeGardenWorldType and gFunc_IsHomeGardenWorldType(owid) then
					uin = gFunc_GetUinByHomeGardenWorldID(owid)
					OpenHomeLandByUin(uin)
					getglobal("PlayerExhibitionCenter"):Hide();
					return 
				end
			else
				getglobal("PlayerExhibitionCenter"):Hide();
			end

			if action == 1 then
				action_url = 6
			elseif action == 2 then
				if action_url ~= "" then
					local id = tonumber(action_url)
					local skinDef = GetInst("ShopDataManager"):GetSkinDefById(id)
					if skinDef then
						action = 36
						action_url = id
						getglobal("PlayerExhibitionCenter"):Hide();
					end
				else
					action_url = 6
				end
			elseif action == 26 then
				action_url = JSON:decode(action_url)
			end

			-- PEC_DynamicJumpOut =true;
			global_jump_ui(action, action_url);

			-- if getglobal("DynamicHandleFrame"):IsShown() then
			-- 	getglobal("DynamicHandleFrame"):Hide();
			-- 	getglobal("DynamicPublishFrame"):Hide();
			-- end
		end
	end
end

--分享列表点击超链接跳转
function FriendDynamicFrameListJumpBtn_OnClick(id)
	--打开详情页
	if id then id = id; else id = this:GetParentFrame():GetClientID() end
	if id and id > 0 then
		local dataList = m_ZoneDynamicMgrParam.DataList.list
		if m_ZoneDynamicMgrParam.selectPullType == 2 then
			dataList = m_ZoneDynamicMgrParam.MyDataList.list
		elseif m_ZoneDynamicMgrParam.selectPullType == 1 then
			dataList = m_ZoneDynamicMgrParam.CircleList.list
		end
		local data = dataList[id]
		if data then
			local action = data.action
			local action_url = data.action_url
			local enterType = nil
			if action then
				if action and (action == 25 or action == 98 or action == 99 ) then
					--跳转地图详情, 不关闭个人中心页面.因为地图如果分享后又取消分享则跳不过去.
					--家园特殊处理
					local uin = AccountManager:getUin()
					if data.pid then
						strs = StringSplit(data.pid, '_')
						uin = tonumber(strs[1])
					end
					local owid = tonumber(data.action_url) or 0
					if tonumber(SpecialHomeLandWorldID())==owid then
						ShowGameTips(GetS(9170), 3)
						return 
					elseif gFunc_IsHomeGardenWorldType and gFunc_IsHomeGardenWorldType(owid) then
						uin = gFunc_GetUinByHomeGardenWorldID(owid)
						OpenHomeLandByUin(uin)
						getglobal("PlayerExhibitionCenter"):Hide();
						return 
					end
				else
					getglobal("PlayerExhibitionCenter"):Hide();
				end

				if action == 1 then
					action_url = 6
				elseif action == 2 then
					if action_url ~= "" then
						local id = tonumber(action_url)
						local skinDef = GetInst("ShopDataManager"):GetSkinDefById(id)
						if skinDef then
							action = 36
							action_url = id
							enterType = 1
						end
					else
						action_url = 6
					end
				elseif action == 26 then
					action_url = JSON:decode(action_url)
				elseif action == 57 then
					if action_url ~= "" then
						local id = tonumber(action_url)
						local weaponDef = GetInst("ShopDataManager"):FindCurrentWeaponDef(id)
						if weaponDef then
							action = 58
							action_url = id
						end
					end
				end
	
				-- PEC_DynamicJumpOut =true;
				global_jump_ui(action, action_url,enterType);
			end
		end
	end
end

--点击"详情页-评论"按钮
function FriendDynamicFrameInfoCommentBtn_OnClick()
	if ns_data.IsGameFunctionProhibited("pc", 10587, 10588) then 
		return; 
	end
	m_ZoneDynamicMgrParam:OpenCommentEditFrame(0);
end

--点击"评论条目-评论"按钮
function FriendDynamicReplyTemplateCommentBtn_OnClick()
	if ns_data.IsGameFunctionProhibited("pc", 10587, 10588) then 
		return; 
	end
	getglobal("FriendDynamicFrameCommentFunc"):Hide();
	local id = this:GetClientID();
	m_ZoneDynamicMgrParam:OpenCommentEditFrame(id);
end

----------------------------------------------------------------------------------------------------------------
--点击选择表情, 回调
-- function DynamicEmoji_ClickCallBack(index)
-- 	local e = m_emojis[index];
-- 	getglobal("FriendDynamicFrameEditTextEdit"):AddText(e.code);
-- 	getglobal("DynamicEmojiFrame"):Hide();
-- end

function FriendDynamicFrameEditMoodBtn_OnClick()
	-- m_emojis.callback = DynamicEmoji_ClickCallBack;
	-- getglobal("DynamicEmojiFrameDialog"):SetPoint("bottomleft", "DynamicEmojiFrame", "bottomleft", 115, -150);
	-- getglobal("DynamicEmojiFrame"):Show();

	InitEmojisPageTab({1,2},function(emojiCfg, idx, content)
		getglobal("FriendDynamicFrameEditTextEdit"):AddText(content or emojiCfg.code);
	end)
	SetEmojiFrameAligment('FriendDynamicFrameEditMoodBtn')
	EmojiPageTab_OnClick(1)
	getglobal("ChatEmojiFrameMask"):Show();
end

-- 表情面板关闭
function DynamicEmojiFrameDialogCloseBtn_OnClick()
	getglobal("DynamicEmojiFrame"):Hide();

	--发布心情的时候:取消设置表情
	local moodFrameName = t_exhibition:getMoodUiName()
	if getglobal(moodFrameName):IsShown() then
		t_exhibition.mood_icon_select = "A100";	--设置空表情
		getglobal(moodFrameName.."MoodPageEmojiTxt"):Clear();
	end
end

--点击选择表情, 处理
-- function DynamicEmojiBtnTemplate_OnClick()
-- 	local index = this:GetClientID();
	
-- 	if m_emojis.callback then
-- 		m_emojis.callback(index);
-- 	end
-- end

function FriendDynamicFrameEdit_OnShow()
	SetCurEditBox("FriendDynamicFrameEditTextEdit");
end

function FriendDynamicFrameEdit_OnClick()
	getglobal("FriendDynamicFrameEdit"):Hide();

end

function DynamicEmojiFrame_OnClick()
	getglobal("DynamicEmojiFrame"):Hide();
end

function DynamicEmojiFrame_OnShow()
	local cancleBtn = getglobal("DynamicEmojiFrameDialogCancle");

	if getglobal(t_exhibition:getMoodUiName()):IsShown() then
		cancleBtn:Show();
	else
		cancleBtn:Hide();
	end
end

-------------------------------------图片展示页面--------------------------------------------------------------------------
function ZoneOpenPicDisplayFrame(filename)
	print("ZoneOpenPicDisplayFrame:");
	--测试: filename = g_photo_root .. "dynamic_upload_tmp1.png";

	if filename and filename ~= "" then
		print("filename", filename);
		local pic = getglobal("ZonePicDisplayFramePic");
		pic:SetTexture(filename);

		--图片尺寸
		local m_iRelWidth = pic:getRelWidth();
		local m_iRelHeight = pic:getRelHeight();

		--最大尺寸
		local maxWidth = 1080;
		local maxHeight = 630;

		--展示尺寸
		local desWidth = m_iRelWidth;
		local desHeight = m_iRelHeight;

		if m_iRelWidth ==256 and m_iRelHeight ==144 then  --地图分享中生成动态
			desWidth = 640;
			desHeight = 360;
		elseif m_iRelWidth > maxWidth or m_iRelHeight > maxHeight then
			local radio = 1.0;	--缩小比例
			if m_iRelHeight > maxHeight then
				radio = m_iRelHeight / maxHeight;
			elseif m_iRelWidth > maxWidth then
				radio = m_iRelWidth / maxWidth;
			end

			print("radio = " .. radio);
			desWidth = math.floor(desWidth / radio);
			desHeight = math.floor(desHeight / radio);

		end
		print(m_iRelWidth);
		print(m_iRelHeight);
		print(desWidth);
		print(desHeight);

		pic:SetSize(desWidth, desHeight);
		getglobal("ZonePicDisplayFrame"):Show();
	end
end

function ZonePicDisplayFrame_OnShow()
	print("ZonePicDisplayFrame_OnShow:");
end

function ZonePicDisplayFrame_OnClick()
	getglobal("ZonePicDisplayFrame"):Hide();
end

-------------------------------------发表心情页面--------------------------------------------------------------------------
local m_PlayerCenterMoodParam = {
	curMood = "";
	curMood_select = "";
	bIsShow = false;
	curTick = 0;
};

--停止播放动作
function ZoneStopPlayAnim(player, mood_icon)
	print("ZoneStopPlayAnim:");
	if player and mood_icon and mood_icon ~= "" then
		print("mood_icon = " .. mood_icon);
		local id, effect = ZoneGetModeViewAnimId(mood_icon);
		player:stopAnimBySeqId(id);

		if effect and "" ~= effect then
			print("ZoneStopPlayAnim:222:" .. ", effect = " .. effect);
			local roleview = getglobal(t_exhibition:getModelViewUiName());
			roleview:stopEffect(effect, 0);
		end
	end
end

--播放动作
function ZonePlayAnim(player, bNeedAttach,extrasFlag,roleInfo)
	print("ZonePlayAnim:");
	local roleview = getglobal(t_exhibition:getModelViewUiName());

	--local player = ZoneGetPlayer2Model();
	if player then
		player:setAnimSwitchIsCall(true);
		Log("ZonePlayAnim:111:");

		-- if bNeedAttach then
		-- 	player:attachUIModelView(roleview, 0, false);
		-- 	player:setScale(1);
		-- end

		--ZoneStopPlayAnim(player, t_exhibition.mood_icon_last);
		
		if player and  t_exhibition.mood_icon_last and  t_exhibition.mood_icon_last ~= "" then
			print("mood_icon = " ..  t_exhibition.mood_icon_last);
			local id, effect = ZoneGetModeViewAnimId( t_exhibition.mood_icon_last);
		
			if extrasFlag == 0 then 
				player = PlayerCenterGetActorBody();					
			elseif extrasFlag ==  1 then
				local callBack = function (playerModel)
					player = playerModel
				end
				ZoneGetPlayer2Model(callBack);
			else

			end  
			if player == nil then return end	
			player:stopAnimBySeqId(id);
			player:playAnimBySeqId(100100);
	
			if effect and "" ~= effect then
				print("ZoneStopPlayAnim:222:" .. ", effect = " .. effect);
				local exhibitionCenterRoleView = getglobal(t_exhibition:getModelViewUiName());
				if exhibitionCenterRoleView:IsShown() then
					exhibitionCenterRoleView:stopEffect(effect, 0);
				end
			end
		end	
		

		local animId, effect = ZoneGetModeViewAnimId(t_exhibition.mood_icon, roleInfo);

		--动作
		print("ZonePlayAnim:animId = " .. animId);
		roleview:playActorAnim(animId, 0);

		--特效
		if effect and "" ~= effect then
			print("ZonePlayAnim:222:" .. ", effect = " .. effect);
			roleview:playEffect(effect, 0);
		else
			print("ZonePlayAnim:333:");
			-- roleview:playEffect(1038, 0);

			--非avator, 则播放入场特效
			if ZoneIsCurModeIsAvator(roleInfo) then
				--是avator
				print("ZonePlayAnim:444:");
			else
				--不是avator
				print("ZonePlayAnim:555:");
				local errcode = 0;
				local info = nil;

				-- errcode, info = ZoneGetLockInfo();

				local callback = function (SkinID)
					if SkinID and SkinID > 0 then
						local skinDef = RoleSkinCsv:get(SkinID);
						if skinDef then
							if skinDef.ShowTimeEffect ~= nil then
								local tabHomeChecked = getglobal(t_exhibition:getUiName().."LeftTabBtn" .. t_ExhibitionCenter.define.tabHome .. "Checked")
								if tabHomeChecked and tabHomeChecked:IsShown() then
									ClientMgr:playStoreSound2D("sounds/skin/"..skinDef.Sound..".ogg");
								end
								roleview:playEffect(skinDef.ShowTimeEffect, 0);
							end
						end
					end
				end

				--仅皮肤需要播放动画
				if roleInfo then
					if not roleInfo.HasAvatar or (roleInfo and roleInfo.HasAvatar < 1) then
						callback(roleInfo.SkinID)
					end
				else
					errcode, info = ZoneGetLockInfo();

					local skinModel = 0;
					if  t_exhibition.isHost then
						skinModel = AccountManager:getRoleSkinModel();
					else
						local playerInfo = t_exhibition.getPlayerInfo();
						if playerInfo and playerInfo.SkinID then 
							print("ZonePlayAnim:666:");
							-- print("SkinID = " ..playerInfo.SkinID);
							-- print("model = " .. playerInfo.Model);
							skinModel = playerInfo.SkinID;
						end
					end
	
					if errcode == ErrorCode.OK and info then
						--上锁了
						skinModel = info.RoleInfo.SkinID;
					end
					callback(skinModel)
				end
			end
		end
	end
end


function ZonePlayAnimByName(player,name, bNeedAttach,extrasFlag,roleInfo)
	print("ZonePlayAnim:");
	local roleview = getglobal(name);

	--local player = ZoneGetPlayer2Model();
	if player then
		player:setAnimSwitchIsCall(true);
		Log("ZonePlayAnim:111:");
		if player and  t_exhibition.mood_icon_last and  t_exhibition.mood_icon_last ~= "" then
			print("mood_icon = " ..  t_exhibition.mood_icon_last);
			local id, effect = ZoneGetModeViewAnimId( t_exhibition.mood_icon_last);
		
			if extrasFlag == 0 then 
				player = PlayerCenterGetActorBody();					
			elseif extrasFlag ==  1 then
				local callBack = function (playerModel)
					player = playerModel
				end
				ZoneGetPlayer2Model(callBack);
			else

			end  
			if player == nil then return end	
			player:stopAnimBySeqId(id);
			player:playAnimBySeqId(100100);
	
			if effect and "" ~= effect then
				print("ZoneStopPlayAnim:222:" .. ", effect = " .. effect);
				local exhibitionCenterRoleView = getglobal(name);
				if exhibitionCenterRoleView:IsShown() then
					exhibitionCenterRoleView:stopEffect(effect, 0);
				end
			end
		end	
		

		local animId, effect = ZoneGetModeViewAnimId(t_exhibition.mood_icon, roleInfo);

		--动作
		print("ZonePlayAnim:animId = " .. animId);
		roleview:playActorAnim(animId, 0);

		--特效
		if effect and "" ~= effect then
			print("ZonePlayAnim:222:" .. ", effect = " .. effect);
			roleview:playEffect(effect, 0);
		else
			print("ZonePlayAnim:333:");
			-- roleview:playEffect(1038, 0);

			--非avator, 则播放入场特效
			if ZoneIsCurModeIsAvator(roleInfo) then
				--是avator
				print("ZonePlayAnim:444:");
			else
				--不是avator
				print("ZonePlayAnim:555:");
				local errcode = 0;
				local info = nil;

				-- errcode, info = ZoneGetLockInfo();

				local callback = function (SkinID)
					if SkinID and SkinID > 0 then
						local skinDef = RoleSkinCsv:get(SkinID);
						if skinDef then
							if skinDef.ShowTimeEffect ~= nil then
								local tabHomeChecked = getglobal(t_exhibition:getUiName().."LeftTabBtn" .. t_ExhibitionCenter.define.tabHome .. "Checked")
								if tabHomeChecked and tabHomeChecked:IsShown() then
									ClientMgr:playStoreSound2D("sounds/skin/"..skinDef.Sound..".ogg");
								end
								roleview:playEffect(skinDef.ShowTimeEffect, 0);
							end
						end
					end
				end

				--仅皮肤需要播放动画
				if roleInfo then
					if not roleInfo.HasAvatar or (roleInfo and roleInfo.HasAvatar < 1) then
						callback(roleInfo.SkinID)
					end
				else
					errcode, info = ZoneGetLockInfo();

					local skinModel = 0;
					if  t_exhibition.isHost then
						skinModel = AccountManager:getRoleSkinModel();
					else
						local playerInfo = t_exhibition.getPlayerInfo();
						if playerInfo and playerInfo.SkinID then 
							print("ZonePlayAnim:666:");
							-- print("SkinID = " ..playerInfo.SkinID);
							-- print("model = " .. playerInfo.Model);
							skinModel = playerInfo.SkinID;
						end
					end
	
					if errcode == ErrorCode.OK and info then
						--上锁了
						skinModel = info.RoleInfo.SkinID;
					end
					callback(skinModel)
				end
			end
		end
	end
end

--模型动作播放:暂时只有avator有, 皮肤同意播放"100108"
function ZoneGetModeViewAnimId(mood_icon, roleInfo)
	print("ZoneGetModeViewAnimId");

	local animId = 100108;
	local effect = "";

	if ZoneIsCurModeIsAvator(roleInfo) then
		--是avator
		print("is avator:");
		if mood_icon then
			for i = 1, #m_emojis do
				if string.find(m_emojis[i].code, mood_icon) then
					animId = m_emojis[i].anim;
					effect = m_emojis[i].effect;
					break;
				end
			end
		end
	else
		print("not avator:");
		
	end

	print("animId = " .. animId);

	return animId, effect;
end

function PlayerCenterActorAnimComplete(animID)
	local roleview = getglobal(t_exhibition:getModelViewUiName());
	local roleview1 = getglobal(t_exhibition:getModelView1UiName());
	if roleview:IsShown() then
		local body = roleview:getActorBody();
		if body and animID == 100108  and body.getPlayerIndex and body:getPlayerIndex() > 0 then
			ActorAnimCtrl.IsAngle = true
			body:setAnimSwitchIsCall(false)
			local skinModel = body:getSkinID()
			if skinModel == 74 or skinModel == 75 or skinModel == 76 then
				local skinDef = RoleSkinCsv:get(skinModel);
				if skinDef and skinDef.ChangeContact and skinDef["ChangeContact"][0] then
					local horse = UIActorBodyManager:getHorseBody(skinDef["ChangeContact"][0] + 0,false);
					if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
						roleView:detachActorBody(body)
						roleView:attachActorBody(horse)
					else
						body:detachUIModelView(roleview)
						horse:attachUIModelView(roleview)
					end
					horse:setScale(1.0);
				end
			end
			ActorAnimCtrl:ActorAngle("LobbyFrameRoleView")
		end
	end
end

--初始化参数 心情气泡
function PlayerExhibitionCenterMood_Init(bIsShow)
	m_PlayerCenterMoodParam.bIsShow = bIsShow;
	m_PlayerCenterMoodParam.curTick = 0;

	if bIsShow then
		getglobal("PlayerExhibitionCenterMoodFrame"):Show();
	else
		getglobal("PlayerExhibitionCenterMoodFrame"):Hide();
	end
end

--心情展示倒计时10秒
function PlayerExhibitionCenterMood_UpdateTime()
	if m_PlayerCenterMoodParam.bIsShow then
		-- print("PlayerExhibitionCenterMood_UpdateTime:");

		m_PlayerCenterMoodParam.curTick = m_PlayerCenterMoodParam.curTick + 1;

		if m_PlayerCenterMoodParam.curTick >= 100 then
			m_PlayerCenterMoodParam.curTick = 0;
			m_PlayerCenterMoodParam.bIsShow = false;
			print("TimeOutCloseMoodFrame:");
			getglobal("PlayerExhibitionCenterMoodFrame"):Hide();
		end
	end
end

function PlayerExhibitionCenterMoodBtn_OnClick()
	--修改签名功能开关
	if not checkModifyHeadNameSignatureOpened() then
		return
	end

	if checkSafetyModifyRef and not checkSafetyModifyRef() then
		return
	end

	if GetInst("CreditScoreService"):CheckLimitAction(GetInst("CreditScoreService"):GetTypeTbl().mood) then
        return
    end
	
	standReportEvent("7", "PERSONAL_INFO_HOMEPAGE", "MoodSendButton", "click")
	if false == AccountSafetyCheck:FunCheck(AccountSafetyCheck.FunType.MOOD_PUBLISH, PlayerExhibitionCenterMoodBtn_OnClick) then
		return
	end

	getglobal(t_exhibition:getMoodUiName()):Show();
end

function MoodPublishFrame_OnShow()
	--标题栏
	local MoodPublishFrameName = t_exhibition:getMoodUiName()
	local TitleFrame = getglobal(MoodPublishFrameName.."TitleFrameName")
	if TitleFrame then
		TitleFrame:SetText(GetS(20518));
	end

	if t_exhibition.mood_text and t_exhibition.mood_text ~= getglobal(MoodPublishFrameName.."MoodPageTextEdit"):GetText() then -- 修复切换未设置心情的账号默认显示上一个账号的心情
		getglobal(MoodPublishFrameName.."MoodPageTextEdit"):SetText(t_exhibition.mood_text);
		if t_exhibition.mood_text == "" then
			getglobal(MoodPublishFrameName.."MoodPageEditDefaultTxt"):Show()
		else
			getglobal(MoodPublishFrameName.."MoodPageEditDefaultTxt"):Hide()
		end
		PlayerCenter_SetMood(t_exhibition.mood_icon, t_exhibition.mood_text);
	end

	local tb = {
		"-",
		"Close",
		"Input",
		"Emoji",
		"SendButton",
		"CancleButton"
	}
	for _, value in ipairs(tb) do
		standReportEvent("7", "MOOD_SEND_POPUP", value, "view")
	end
end

function MoodPublishFrame_OnHide()

end

function MoodPublishFrameCloseBtn_OnClick()
	standReportEvent("7", "MOOD_SEND_POPUP", "Close", "click")

	getglobal(t_exhibition:getMoodUiName()):Hide();

	--清除表情
	if (t_exhibition.mood_icon_select == "A100" or t_exhibition.mood_icon_select == "") and t_exhibition.mood_icon ~= "A100" and t_exhibition.mood_icon ~= "" then
		WWW_setPlayerMood(t_exhibition.mood_icon_select, t_exhibition.mood_text_select);
		getglobal("PlayerExhibitionCenterMoodFrameMood"):Clear();
	end
end

function MoodPublishFrameTextEdit_OnFocusLost()
	local moodFrameName = t_exhibition:getMoodUiName()
	local MoodPageName = moodFrameName.."MoodPage"
	local text = getglobal(MoodPageName.."TextEdit"):GetText();
	if text == "" then
		print("标情况中的文字是:",getglobal(MoodPageName.."EmojiTxt"):GetTextLines())
		getglobal(MoodPageName.."EditDefaultTxt"):Show();
	else
		getglobal(MoodPageName.."EditDefaultTxt"):Hide();
	end
end

function MoodPublishFrameTextEdit_OnFocusGained()
	standReportEvent("7", "MOOD_SEND_POPUP", "Input", "click")
	if ns_data.IsGameFunctionProhibited("um", 500100, 500101) then -- 禁用个人心情提示
		return
	end
	getglobal(t_exhibition:getMoodUiName().."MoodPageEditDefaultTxt"):Hide();
end

--点击选择表情, 回调
-- function MoodPublish_ClickCallBack(index)
-- 	local e = m_emojis[index];
-- 	local moodFrameName = t_exhibition:getMoodUiName()
-- 	getglobal(moodFrameName.."MoodPageEditDefaultTxt"):Hide();

-- 	t_exhibition.mood_icon_select = e.code;
-- 	-- getglobal("PlayerExhibitionCenterMoodFrameMood"):SetText(e.code, 255, 253, 233);
-- 	getglobal(moodFrameName.."MoodPageEmojiTxt"):SetText(e.code, 255, 253, 233);
-- 	getglobal("DynamicEmojiFrame"):Hide();
-- end

function MoodPublishFrameInsertEmojiBtn_OnClick()
	standReportEvent("7", "MOOD_SEND_POPUP", "Emoji", "click")

	InitEmojisPageTab({1,2},function(emojiCfg, idx, content)
		local moodFrameName = t_exhibition:getMoodUiName()
		getglobal(moodFrameName.."MoodPageEditDefaultTxt"):Hide();

		t_exhibition.mood_icon_select = content or emojiCfg.code;
		-- getglobal("PlayerExhibitionCenterMoodFrameMood"):SetText(e.code, 255, 253, 233);
		getglobal(moodFrameName.."MoodPageEmojiTxt"):SetText(content or emojiCfg.code, 255, 253, 233);

	end)
	SetEmojiFrameAligment('MoodPublishFrameMoodPageMoodBtn')
	EmojiPageTab_OnClick(1)
	getglobal("ChatEmojiFrameMask"):Show();
end

function MoodPublishFrameCancelBtn_OnClick()
	standReportEvent("7", "MOOD_SEND_POPUP", "CancleButton", "click")
	MoodPublishFrameCloseBtn_OnClick();
end

--设置心情
function PlayerCenter_SetMood(mood, txt)
	print("PlayerCenter_SetMood:");
	PlayerCenter_CleanMood();

	-- 空表情并且空文字，隐藏
	if (mood ==nil or mood =="A100" or mood =="") and (txt == nil or txt == "") then 
		PlayerExhibitionCenterMood_Init(false);
		return
	else  
		PlayerExhibitionCenterMood_Init(true);
	end

	local uiMoodFrameName = t_exhibition:getUiName().."MoodFrame"
	local txtObj = getglobal(uiMoodFrameName.."Txt");
	local moodObj = getglobal(uiMoodFrameName.."Mood");
	
	if mood and string.find(mood, "A") then
		if not string.find(mood, "#") then
			mood = "#" .. mood;
		end
		moodObj:SetText(mood, 255, 253, 233);

		getglobal(t_exhibition:getMoodUiName().."MoodPageEmojiTxt"):SetText(mood, 255, 253, 233);
	end

	local w = moodObj:GetTotalHeight();
	print("w = " .. w);
	if w and w > 0 then
		--表情存在, 要调整文字位置
		txtObj:SetPoint("left", uiMoodFrameName, "left", 70, 0);
		txtObj:resizeRichWidth(234);
	else
		txtObj:SetPoint("center", uiMoodFrameName, "center", 0, 0);
		txtObj:resizeRichWidth(295);
	end

	if txt then
		print("txt:" .. txt);
		txt = DefMgr:filterString(txt);
		txtObj:SetText(txt, 55, 54, 49);
	end
end

function PlayerCenter_CleanMood()
	print("PlayerCenter_CleanMood:");
	local txtObj = getglobal("PlayerExhibitionCenterMoodFrameTxt");
	local moodObj = getglobal("PlayerExhibitionCenterMoodFrameMood");

	txtObj:Clear();
	moodObj:Clear();
end

--提交心情
function MoodPublishFrameCommitBtn_OnClick()
	standReportEvent("7", "MOOD_SEND_POPUP", "SendButton", "click")

	if ns_data.IsGameFunctionProhibited("um", 500100, 500101) then -- 禁用个人心情提示
		return
	end

	local moodFrameName = t_exhibition:getMoodUiName()
	local txt = getglobal(moodFrameName.."MoodPageTextEdit"):GetText();

	--敏感词检测
	if DefMgr:checkFilterString(txt) then
		ShowGameTipsWithoutFilter(GetS(9200100), 3)
		getglobal(moodFrameName.."MoodPageTextEdit"):Clear()
		return
	end

	-- 检测是否有会员表情
	if GetInst('MembersSysMgr'):CheckStringFitVipFaceCode(txt) then
		return
	end

	--提交
	t_exhibition.mood_text_select = txt;
	WWW_setPlayerMood(t_exhibition.mood_icon_select, t_exhibition.mood_text_select);
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterMoodBtn");

	-- if not t_exhibition:isThreeVerOpen() then
		getglobal(moodFrameName):Hide();
	-- end
end

-- 设置用户心情
function WWW_setPlayerMood(mood_icon, mood_text)
	print("WWW_setPlayerMood:");
	if mood_icon and string.find(mood_icon, "#") then
		--上传服务器时去掉井号
		print("mood_icon = " .. mood_icon);
		mood_icon = string.gsub(mood_icon, "#", "");
		print("mood_icon = " .. mood_icon);
	end

	if  t_exhibition.net_ok then
		local mood_text = escape(mood_text);
		local url_ = g_http_root_map .. 'miniw/profile?act=setProfile&mood_icon=' .. mood_icon .. "&mood_text=" .. mood_text .. '&' .. http_getS1Map();
		url_ = url_ .. "&" .. http_getRealNameMobileSum(mood_text)
		print( url_ );
		ns_http.func.rpc( url_, WWW_setPlayerMood_cb, nil, nil, true );
		t_exhibition.self_data_dirty = true;
	else
		
	end
end

function WWW_setPlayerMood_cb(ret_)
	print( "call WWW_setPlayerFrameId_cb", ret_);
	if  ret_ and ret_.ret then
		if  ret_.ret == 0 then   				--修改成功
			t_exhibition.mood_icon_last = t_exhibition.mood_icon;
			t_exhibition.mood_icon = t_exhibition.mood_icon_select;
			t_exhibition.mood_text = t_exhibition.mood_text_select;
			PlayerCenter_SetMood(t_exhibition.mood_icon, t_exhibition.mood_text);
			-- PlayerExhibitionCenterMood_Init(true);
			if IsOverseasVer() or isAbroadEvn() then 
				ShowGameTips(GetS(20667), 3)
			else
				ShowGameTips(GetS(20666), 3);
			end

			--播放动画
			local player = PlayerCenterGetActorBody();
			Log( "call WWW_setPlayerFrameId_cb player" );
			if player then
				ZonePlayAnim(player,false,0);
			end 
		elseif  ret_.ret == 11 then  
			if ret_.flag == "00" then
				ShowGameTipsWithoutFilter(GetS(22037), 3)	--手机 身份证 校验失败
			elseif ret_.flag == "01" then
				ShowGameTipsWithoutFilter(GetS(10643), 3)	--手机号 校验失败
			elseif ret_.flag == "10" then
				ShowGameTipsWithoutFilter(GetS(100218), 3)	--身份证 校验失败
			end
		elseif  ret_.ret == 12 then  
			ShowGameTips(GetS(121), 3) 	--内容违规
		end
	else
		Log( "ERROR: ret=nil" );
	end
end

-------------------------------------个人设置页面--------------------------------------------------------------------------
local RepNameIds = {20570, 20572, 20571, 20573};	--所有人, 粉丝, 好友, 不可回复
local SeeNameIds = {20570, 20572, 20571, 20574};	--所有人, 粉丝, 好友, 仅自己可见
local SkinNameIds = {20570, 20571, 20574};			--所有人, 好友, 仅自己可见
local DressNameIds = {20570, 20571, 20574};			--所有人, 好友, 仅自己可见
local GenderIds  = {3465, 3466, 3467};				--男, 女, 保密
local TitleSystemIDS = {9100000,9100001,9100002} --

local m_PlayerCenterDataEditParam = {
	curPage = 1,

	tab = {
		{name = 3454, },	--资料
		{name = 9008, }
	},
};

function PECSetBtn_OnClick()
	--使左侧tab按钮全部为'未选中'状态
	standReportEvent("7", "PERSONAL_INFO_CONTAINER", "Settings", "click")
	getglobal("PlayerCenterSetFrame"):Show();
end

function PlayerCenterDataEditCloseBtn_OnClick()
	--如果下拉框打开了, 就关闭

	if getglobal("PlayerCenterDataEditPage2CommentAuthListBox"):IsShown() then
		PlayerCenterDataEditPage2CommentAuthList_OnClick();
	end

	getglobal("PlayerCenterDataEdit"):Hide();
end

function PlayerCenterSetFrame_OnLoad()
	--性别选择
	local iconList = {
		[1] = "icon_male",
		[2] = "icon_female",
		[3] = "icon_sex",
	}
	local y = 0;
	for i = 1, 3 do
		local item = getglobal("PlayerCenterDataEditPage1GenderListF" .. i);
		local name = getglobal("PlayerCenterDataEditPage1GenderListF" .. i .. "Name");
		local icon = getglobal("PlayerCenterDataEditPage1GenderListF" .. i .. "Icon");
		item:SetPoint("top", "PlayerCenterDataEditPage1GenderList", "top", 0, y);
		name:SetText(GetS(GenderIds[i]));
		icon:Show();
		icon:SetTexUV(iconList[i]);
		y = y + 46;
		if i == 3 then 
			getglobal("PlayerCenterDataEditPage1GenderListF3Line"):Hide();
			icon:SetSize(28, 10);
		elseif i == 2 then
			icon:SetSize(25, 25);
		else
			icon:SetSize(25, 25);
		end
	end
	getglobal("PlayerCenterDataEditPage1TitleSystemBtnNameBkg"):SetBlendAlpha(0.3);

	SandboxLua.eventDispatcher:SubscribeEvent(nil, "TITLESYSTEM_CHANGE", PlayerCenterSetFrameTitleChange)
end

function PlayerCenterSetFrameTitleChange(context)
	local paramData = context:GetParamData()
	PlayerCenterSetFrameTitleSystemUpDate();
end

function PlayerCenterSetFrameTitleSystemUpDate()
	local Title =  getglobal("PlayerCenterDataEditPage1TitleSystemBtnTitle");
	local name = getglobal("PlayerCenterDataEditPage1TitleSystemBtnName");
	local nameBkg = getglobal("PlayerCenterDataEditPage1TitleSystemBtnNameBkg");
	if GetInst("TitleSystemInterface"):GetSelfCurrentTitle() > 0 then
		GetInst("TitleSystemInterface"):SetSelfCurrentTitleIcon(Title)
		Title:Show()
		name:Hide();
		nameBkg:Hide();
	else
		Title:Hide()
		name:Show();
		nameBkg:Show();
	end
end

-- 重置协议UI
function ResetAgreementUI(topCommentname)
	local config = {
		[1] = { uiname = "PrivacyPolicy", text = 100504 },                -- 《隐私政策》
		[2] = { uiname = "PrivacyPolicySummary", text = 1000641 },        -- 《隐私政策摘要》
		[3] = { uiname = "LicenseAndServiceAgreement", text = 100503 },   -- 《游戏许可及服务协议》
		[4] = { uiname = "ChildrenPrivacyPolicy", text = 1000601 },       -- 《儿童隐私协议》
		[5] = { uiname = "PlayerDetail", text = 1000636 },                -- 《个人信息手机清单》
		[6] = { uiname = "ThirdShareInfo", text = 1000637 },              -- 《第三方信息共享清单》
	}
	
	local parentName = "PlayerCenterDataEditPage2"
	local relativeTo = ""
	local scale = UIFrameMgr:GetScreenScale();
	for i = 1, 6 do
		local name = parentName .. config[i].uiname
		local ui = getglobal(name)
		if ui then
			if config[i].text then
				local str = GetS(config[i].text) or ""
				if i % 4 == 1 then
					ui:SetPoint("bottomleft", parentName .. topCommentname, "bottomleft", (i == 1) and 90 or 220, (i == 1) and 60 or 110)
				else
					ui:SetPoint("left", relativeTo, "right", 50, 0)
				end
				relativeTo = name
				ui:SetText(str, 255, 0, 0);
				local width = ui:GetTextExtentWidth(str)
				width = width / scale;
				ui:SetWidth(width)
				ui:Show()
			else
				ui:Hide()
			end				
		end
	end
end

function PlayerCenterSetFrame_OnShow()
	print("PlayerCenterDataEdit_OnShow:");
	local tb = {
		"-",
		"AvatarFrame",
		"NameChange",
		"Gender",
		"UpdatesReplyLimit",
		"UpdatesViewLimit",
		"Close"
	}
	for _, value in ipairs(tb) do
		standReportEvent("7", "PERSONAL_INFO_SETTINGS", value, "view")
	end
	
	--标题栏
	getglobal("PlayerCenterSetFrameTitleFrameName"):SetText(GetS(9008));
	
	--ResetAgreementUI()

	-- 心情发布展示，开关控制
	local DataEditFrame = "PlayerCenterDataEdit"
	local PlaneName = DataEditFrame.."Plane"
	local editPage1Name = DataEditFrame.."Page1"
	local editPage2Name = DataEditFrame.."Page2"
	local editPage3Name = DataEditFrame.."Page3"
	local MoodFrameName = editPage1Name.."MoodFrame"

	local MoodFrameNameHeight = 0
	-- if t_exhibition:isThreeVerOpen() then
	-- 	MoodFrameNameHeight = getglobal(MoodFrameName):GetHeight()
	-- 	getglobal(MoodFrameName):Show()
	-- 	getglobal(editPage1Name):SetHeight(350 + MoodFrameNameHeight + 20)
	-- else
		
		getglobal(MoodFrameName):Hide()
	-- end

	local delatH = 400 --动态查看权限 点开后 超出的高度

	getglobal(editPage2Name):SetPoint("top", editPage1Name, "bottom", 0, 10);
	if ClientMgr:isPC() then
		getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + delatH);
	else
		getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + getglobal(editPage3Name):GetHeight())
	end
	--1. 页面初始化  (心情发布展示自动初始化)
	PlayerCenterDataEdit_PageInit();

	--初始化隐私部分访问权限
	InitPermissionState();

	InitPermissionUI();
	--个性化推荐
	SetSwitchBtnState(DataEditFrame.."Page3RecommendStatus", G_GetRecommendationsOpen() and 1 or 0)

	--最佳拍档PlayerCenterDataEditPage3BestPartnerStatus
	GetInst("BestPartnerManager"):InitBestSwich()

	if GetInst("TitleSystemInterface"):TitleIsOPen() then
		getglobal(editPage1Name):SetHeight(435)
		getglobal(editPage2Name):SetHeight(640)
		InitTitleSystemUI()
		getglobal("PlayerCenterDataEditPage2DressAuth"):SetPoint("top", "PlayerCenterDataEditPage2TitleSystem", "bottom", 0, 0)
	else
		getglobal(editPage1Name):SetHeight(350)
		getglobal(editPage2Name):SetHeight(555)
		getglobal("PlayerCenterDataEditPage1TitleSystem"):Hide()
		getglobal("PlayerCenterDataEditPage2TitleSystem"):Hide()
		getglobal("PlayerCenterDataEditPage2DressAuth"):SetPoint("top", "PlayerCenterDataEditPage2SkinAuth", "bottom", 0, 0)
	end
	ResetAgreementUI("DressAuth")

	--增加性别开关
	if not if_show_gender() then
		local height = getglobal("PlayerCenterDataEditPage1"):GetHeight()
		getglobal("PlayerCenterDataEditPage1"):SetHeight(height-85)
		getglobal("PlayerCenterDataEditPage1Gender"):Hide()
		getglobal("PlayerCenterDataEditPage1TitleSystem"):SetPoint("top", "PlayerCenterDataEditPage1NickName", "bottom", 0, 0)
	end
end

function PlayerCenterSetFrameCloseBtn_OnClick()
	standReportEvent("7", "PERSONAL_INFO_SETTINGS", "Close", "click")
	getglobal("PlayerCenterSetFrame"):Hide();
end

function InitTitleSystemUI()
	ZoneUpdateTitleSytemState()
	PlayerCenterSetFrameTitleSystemUpDate()
end

--页面初始化
function PlayerCenterDataEdit_PageInit()
	print("PlayerCenterDataEdit_PageInit:");

	--昵称、
	-- local profile = t_exhibition.getPlayerInfo();
	-- if profile then
	-- 	getglobal("PlayerCenterDataEditPage1NickNameName"):SetText(profile.NickName);
	-- end

	--上面的可以
	zone_refresh_ui();

	--动态评论权限
	local y = 0;
	for i = 1, 4 do
		local item = getglobal("PlayerCenterDataEditPage2CommentAuthListBoxF" .. i);
		local name = getglobal("PlayerCenterDataEditPage2CommentAuthListBoxF" .. i .. "Name");

		name:SetText(GetS(RepNameIds[i]));
		item:SetPoint("top", "PlayerCenterDataEditPage2CommentAuthListBox", "top", 0, y);
		y = y + 46;
	end

	--个人搭配权限
	local y = 0;
	for i = 1, 3 do
		local item = getglobal("PlayerCenterDataEditPage2SkinAuthListBoxF" .. i);
		local name = getglobal("PlayerCenterDataEditPage2SkinAuthListBoxF" .. i .. "Name");

		name:SetText(GetS(SkinNameIds[i]));
		item:SetPoint("top", "PlayerCenterDataEditPage2SkinAuthListBox", "top", 0, y);
		y = y + 46;
	end

	--装扮图鉴权限
	local y = 0;
	for i = 1, 3 do
		local item = getglobal("PlayerCenterDataEditPage2DressAuthListBoxF" .. i);
		local name = getglobal("PlayerCenterDataEditPage2DressAuthListBoxF" .. i .. "Name");

		name:SetText(GetS(DressNameIds[i]));
		item:SetPoint("top", "PlayerCenterDataEditPage2DressAuthListBox", "top", 0, y);
		y = y + 46;
	end
	
	--称号展示权限
	local y = 0;
	for i = 1, 3 do
		--PlayerCenterDataEditPage2TitleSystemList
		local item = getglobal("PlayerCenterDataEditPage2TitleSystemListBoxF" .. i);
		local name = getglobal("PlayerCenterDataEditPage2TitleSystemListBoxF" .. i .. "Name");

		name:SetText(GetS(TitleSystemIDS[i]));
		item:SetPoint("top", "PlayerCenterDataEditPage2TitleSystemListBox", "top", 0, y);
		y = y + 46;
	end
end

-- 改性别
function changeGenderTxtPic( gender_, pic_, txt_ )
	local pic_obj_, txt_obj_ = nil, nil;
	if  pic_ and #pic_ > 0 then
		pic_obj_ = getglobal( pic_ );
	end

	if  txt_ and #txt_>0 then
		txt_obj_ = getglobal( txt_ );
	end

	-- 1=男 2=女 0=保密
	if       gender_ == 1 then
		if  pic_obj_ then
			pic_obj_:SetTexUV( "icon_male.png"  );
			pic_obj_:SetSize(25, 25);
		end
		if  txt_obj_ then
			txt_obj_:SetText( GetS(3465) );
		end

	elseif   gender_ == 2 then
		if  pic_obj_ then
			pic_obj_:SetTexUV( "icon_female.png"  );
			pic_obj_:SetSize(25, 25);
		end
		if  txt_obj_ then
			txt_obj_:SetText( GetS(3466) );
		end

	else
		if  pic_obj_ then
			pic_obj_:SetTexUV( "icon_sex.png"  );
			pic_obj_:SetSize(28, 10);
		end
		if  txt_obj_ then
			txt_obj_:SetText( GetS(3467) );
		end
	end
end

--头像框编辑
function PlayerCenterDataEditPage1Head_OnClick()
	--修改头像功能开关
	if not checkModifyHeadNameSignatureOpened() then
		return
	end

	-- getglobal("ZoneHeadEdit"):Show();
	-- -- 埋点 头像框详情页栏目	-	view
	-- standReportEvent("7", "HEAD_FREAM","-", "view")

	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterHeadEditBtn");
	-- standReportEvent("7", "PERSONAL_INFO_SETTINGS", "AvatarFrame", "click")
	GetInst("PlayerCenterManager"):OpenPersonalPhotoSetting()
	standReportEvent("7", "PROFILE_EDIT", "ProfileEditButton", "click", {standby1 = 2})
	--关闭下拉框
	if getglobal("PlayerCenterDataEditPage2CommentAuthListBox"):IsShown() then
		PlayerCenterDataEditPage2CommentAuthList_OnClick();
	end

	if getglobal("PlayerCenterDataEditPage1GenderList"):IsShown() then
		PlayerCenterDataEditPage1GenderBtn_OnClick();
	end
end

--名字编辑(old:PlayerCenterFrameInfoEditBtn_OnClick()).
function PlayerCenterDataEditPage1NickName_OnClick()
	standReportEvent("7", "PERSONAL_INFO_SETTINGS", "NameChange", "click")
	if IsOverseasVer() or isAbroadEvn() then
		getglobal("NickModifyFrame"):Show()
	else
		local renameState = AccountManager.get_rename_review and AccountManager.get_rename_review() or 0 -- 昵称审核状态
		if renameState == 3 then
			ShowGameTips(GetS(20670), 3)
		else
			--修改昵称功能开关
			if not checkModifyHeadNameSignatureOpened() then
				return
			end
			getglobal("NickModifyFrame"):Show()
		end
	end

	
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterNicknameEditBtn");
end

--性别编辑
function PlayerCenterDataEditPage1Gender_OnClick()
	getglobal("ZoneEditGender"):Show();
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterGenderEditBtn");
end

--打开称号设置界面
function PlayerCenterDataEditPage1TitleSystem_OnClick()
	GetInst("TitleSystemInterface"):OpenTitleSystemSetFrom()
end

--下拉框选择
function TemplateZoneListItem_OnClick(id)
	print("TemplateZoneListItem_OnClick:");
	if id then id = id; else id = this:GetClientID(); end

	print("id = " .. id);
	local btnname = this:GetName();

	if string.find(btnname, "Priority") then
		--优先展示频道
		print("Priority:");
		WWW_setZoneFirstUI(id);
	elseif string.find(btnname, "CommentAuth") then
		--评论权限
		print("CommentAuth:");
		local auth_rep_list = {0, 1, 2, 3};			--0:所有, 1:好友和粉丝, 2:粉丝, 3:自己
		local auth_rep = auth_rep_list[id];
		print("auth_rep:", auth_rep);

		m_ZoneDynamicMgrParam:SetPostingAuth(true, "rep", auth_rep);
		PlayerCenterDataEditPage2CommentAuthList_OnClick();
	elseif string.find(btnname, "SkinAuth") then
		print("SkinAuth:");
		local auth_skin_list = {0, 1, 2};
		local auth_skin = auth_skin_list[id] or 0
		print("auth_skin:", auth_skin);

		WWW_setPlayerSkinAuth(auth_skin);
		PlayerCenterDataEditPage2SkinAuthList_OnClick();
	elseif string.find(btnname, "DressAuth") then
		print("DressAuth:");
		local auth_dress_list = {0, 1, 2};
		local auth_dress = auth_dress_list[id] or 0
		print("auth_dress:", auth_dress);

		WWW_setPlayerDressAuth(auth_dress);
		PlayerCenterDataEditPage2DressAuthList_OnClick();
	elseif string.find(btnname, "Gender") then
		--性别选择
		print("Gender:");
		t_exhibition.gender_select = id;
		WWW_setPlayerGender( t_exhibition.gender_select );

		--关闭弹框
		PlayerCenterDataEditPage1GenderBtn_OnClick();
	elseif string.find(btnname, "TitleSystem") then
		local Title_System_list = {0, 1, 2};
		local Title_System = Title_System_list[id]
		WWW_setPlayerTitleSystem(Title_System)
		PlayerCenterDataEditPage2TitleSystemList_OnClick()
	else
	end
end
-- 设置用户个性搭配权限
function WWW_setPlayerTitleSystem(Title_System)
	if  t_exhibition.net_ok then
		GetInst("TitleSystemInterface"):SetTitleDisplay(Title_System,function (code,data)
			t_exhibition.auth_titleSystem =data.display
			ZoneUpdateTitleSytemState()
		end)
	end
end

-- 设置用户个性搭配权限
function WWW_setPlayerSkinAuth(auth_skin)
	local callback = function(data)
		print("setPlayerSkinAuth_callback:");
		local ret = data.ret
		print(ret);
		if ret == 0 then
			print("设置用户个性搭配权限成功:");
			t_exhibition.auth_skin = tonumber(data.display or 0);	--默认0, 即所有人
			ZoneUpdateRepAndSeeUIState();
		else
			print("设置用户个性搭配权限失败:");
		end
	end
	print("WWW_setPlayerSkinAuth:");
	if  t_exhibition.net_ok then
		local url_ = g_http_root_map .. 'miniw/profile?act=setProfile&display=' .. auth_skin .. '&' .. http_getS1Map();
		Log( url_ );
		ns_http.func.rpc( url_, callback, nil, nil, true );
		t_exhibition.self_data_dirty = true;
		t_exhibition.first_ui_select = first_ui;
	else
		
	end
end

-- 设置用户装扮图鉴权限
function WWW_setPlayerDressAuth(auth_dress)

	print("WWW_setPlayerDressAuth:");
    local url = g_http_root .. "/miniw/welfare?"
	local reqParams = { act = 'avatar_collect_set_premissions', premissions = auth_dress }
	local paramStr, md5 = http_getParamMD5(reqParams)
	url = url .. paramStr .. '&md5=' .. md5
	Log( url );
    local call_back = call_back
    local isclick = isclick
    ns_http.func.rpc(url, function(data)
		print("setPlayerDressAuth_callback:");
		local ret = data.ret
		print(ret);
		if ret == 0 then
			print("设置用户装扮图鉴权限成功:");
			t_exhibition.auth_dress = tonumber(data.data.premissions or 0);	--默认0, 即所有人
			ZoneUpdateRepAndSeeUIState();
		else
			print("设置用户装扮图鉴权限失败:");
		end
    end, nil, nil, true, true)

	t_exhibition.self_data_dirty = true;
	t_exhibition.first_ui_select = first_ui;


end

-- 设置用户心情
function WWW_setZoneFirstUI(first_ui)
	print("WWW_setZoneFirstUI: first_ui = " .. first_ui);
	if  t_exhibition.net_ok then
		local url_ = g_http_root_map .. 'miniw/profile?act=setProfile&first_ui=' .. first_ui .. '&' .. http_getS1Map();
		Log( url_ );
		ns_http.func.rpc( url_, WWW_setZoneFirstUI_cb, nil, nil, true );
		t_exhibition.self_data_dirty = true;
		t_exhibition.first_ui_select = first_ui;
	else
		
	end
end

function WWW_setZoneFirstUI_cb(ret_)
	print( "call WWW_setZoneFirstUI_cb" );
	if  ret_ and ret_.ret then
		if  ret_.ret == 0 then   				--修改成功
			t_exhibition.first_ui = t_exhibition.first_ui_select;
			ShowGameTips(GetS(20527));
			PlayerCenter_SetFirstUI();
		end
	else
		print( "ERROR: ret=nil" );
	end
end

function PlayerCenter_SetFirstUI()
	local nameIds = {20524, 20525, 20526, 20593};

	if t_exhibition.first_ui and nameIds[t_exhibition.first_ui] then
		local txt = GetS(nameIds[t_exhibition.first_ui]);
	end
end

-------------------------------------允许他人评论权限------------------------------------------------------------------------
--拉取权限信息
function ZoneGetRepandSeeAuthState()
	print("ZoneGetRepandSeeAuthState:");
	
	if ns_version.proxy_url then
		local callback = function(ret)
			print("authstate_callback:");
			print(ret);
			if ret then
				print("获取权限状态成功:");
				t_exhibition.auth_rep = ret.auth_rep or 2;	--默认回复权限为2, 即好友可回复
				t_exhibition.auth_see = ret.auth_see or 0;
				ZoneUpdateRepAndSeeUIState();
			else
				print("获取权限状态失败:");
			end
		end


		local url = ns_version.proxy_url .. '/miniw/posting?act=getPostingPlayerInfo' .. "&" .. http_getS2Act("posting");
		ShowLoadLoopFrame(true, "file:playercenter_new -- func:ZoneGetRepandSeeAuthState");
		ns_http.func.rpc( url, callback, nil, nil, true );
	end
end

--拉取个人资产展示权限设置
function ZoneGetPlayerProfile()
	local uin = t_exhibition.uin
	local url = g_http_root_map .. 'miniw/profile?act=getProfile&op_uin=' .. uin .. '&' .. http_getS1Map();
	ShowLoadLoopFrame(true, "file:ZoneGetPlayerProfile -- func:getProfile");


	local callback = function(data)
		ShowLoadLoopFrame(false)
		if data and data.ret and data.ret == 0 then
			print("请求玩家profile成功:");
			local profile = data.profile or {}
			local permission = profile.permission or {}
			t_exhibition.auth_skin = tonumber(permission.display or 0)--个人中心展示权限0 所有人 1 好友 2 自己 默认所有用户
			--t_exhibition.bestpartner_switch = 
		else
			print("请求玩家profile失败:");
		end
	end
	ns_http.func.rpc(url, callback, nil, nil, ns_http.SecurityTypeHigh);
end

--拉取装扮图鉴展示权限设置
function ZoneGetPlayerDressupBook()
	local url = g_http_root .. "/miniw/welfare?"
	local reqParams = { act = 'avatar_collect_get_premissions'}
	local paramStr, md5 = http_getParamMD5(reqParams)
	url = url .. paramStr .. '&md5=' .. md5
	ShowLoadLoopFrame(true, "file:ZoneGetPlayerDressupBook -- func:getDressupBook");

    ns_http.func.rpc(url, function(data)
		print("setPlayerDressAuth_callback:");
		local ret = data.ret
		print(ret);
		if ret == 0 then
			print("设置用户装扮图鉴权限成功:");
			t_exhibition.auth_dress = tonumber(data.data.premissions or 0);	--默认0, 即所有人
			ZoneUpdateRepAndSeeUIState();
		else
			print("设置用户装扮图鉴权限失败:");
		end
    end, nil, nil, true, true)

end

function ZoneUpdateRepAndSeeUIState()
	print("ZoneUpdateRepAndSeeUIState:");

	local auth_rep = t_exhibition.auth_rep;
	local auth_skin = t_exhibition.auth_skin;
	local auth_dress = t_exhibition.auth_dress or 0;

	local repTxt = GetS(RepNameIds[auth_rep + 1]);
	local skinTxt = GetS(SkinNameIds[auth_skin + 1]);
	local dressTxt = GetS(DressNameIds[auth_dress + 1]);

	local rep = getglobal("PlayerCenterDataEditPage2CommentAuthListName");
	local skin = getglobal("PlayerCenterDataEditPage2SkinAuthListName");
	local dress = getglobal("PlayerCenterDataEditPage2DressAuthListName");

	rep:SetText(repTxt);
	skin:SetText(skinTxt);
	dress:SetText(dressTxt);

	if not GetInst("SkinCollectManager"):isOpen() then
		getglobal("PlayerCenterDataEditPage2DressAuth"):Hide();
	end
end

function ZoneUpdateTitleSytemState()
	local titleSystem = t_exhibition.auth_titleSystem;
	local title = getglobal("PlayerCenterDataEditPage2TitleSystemListName");
	if not t_exhibition.auth_titleSystem then
		GetInst("TitleSystemInterface"):GetSelfTitleInfo(
			function ()
				 titleSystem = t_exhibition.auth_titleSystem;
				local titleSystemtxt = GetS(TitleSystemIDS[titleSystem + 1]);
				title:SetText(titleSystemtxt);
			end
		)
	else
		local titleSystemtxt = GetS(TitleSystemIDS[titleSystem + 1]);
		title:SetText(titleSystemtxt);
	end
	
end

function PlayerCenterDataEditPage2CommentAuthList_OnClick()
	local box = getglobal("PlayerCenterDataEditPage2CommentAuthListBox");
	local down = getglobal("PlayerCenterDataEditPage2CommentAuthListDown");
	local up   = getglobal("PlayerCenterDataEditPage2CommentAuthListUp");
	standReportEvent("7", "PERSONAL_INFO_SETTINGS", "UpdatesReplyLimit", "click")
	if box:IsShown() then
		box:Hide();
		down:Show();
		up:Hide();
	else
		box:Show()
		down:Hide();
		up:Show();

		if getglobal("PlayerCenterDataEditPage1GenderList"):IsShown() then
			PlayerCenterDataEditPage1GenderBtn_OnClick();
		end

		if getglobal("PlayerCenterDataEditPage2SkinAuthListBox"):IsShown() then
			PlayerCenterDataEditPage2SkinAuthList_OnClick();
		end

		if getglobal("PlayerCenterDataEditPage2DressAuthListBox"):IsShown() then
			PlayerCenterDataEditPage2DressAuthList_OnClick();
		end
		
		if getglobal("PlayerCenterDataEditPage2TitleSystemListBox"):IsShown() then
			PlayerCenterDataEditPage2TitleSystemList_OnClick();
		end
	end
end

-------------------------------------称号权限权限------------------------------------------------------------------------
function PlayerCenterDataEditPage2TitleSystemList_OnClick()
	local box = getglobal("PlayerCenterDataEditPage2TitleSystemListBox");
	local down = getglobal("PlayerCenterDataEditPage2TitleSystemListDown");
	local up   = getglobal("PlayerCenterDataEditPage2TitleSystemListUp");
	standReportEvent("7", "PERSONAL_INFO_SETTINGS", "UpdatesViewLimit", "click")

	-- 心情发布展示，开关控制
	local DataEditFrame = "PlayerCenterDataEdit"
	local PlaneName = DataEditFrame.."Plane"
	local editPage1Name = DataEditFrame.."Page1"
	local editPage2Name = DataEditFrame.."Page2"
	local editPage3Name = DataEditFrame.."Page3"

	local delatH = 200 --动态查看权限 点开后 超出的高度

	if box:IsShown() then
		box:Hide();
		down:Show();
		up:Hide();

		--调整面板的高度
		if ClientMgr:isPC() then
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + delatH)
		else
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + getglobal(editPage3Name):GetHeight())
		end
	else
		box:Show()
		down:Hide();
		up:Show();

		if getglobal("PlayerCenterDataEditPage2CommentAuthListBox"):IsShown() then
			PlayerCenterDataEditPage2CommentAuthList_OnClick();
		end

		if getglobal("PlayerCenterDataEditPage1GenderList"):IsShown() then
			PlayerCenterDataEditPage1GenderBtn_OnClick();
		end

		if getglobal("PlayerCenterDataEditPage2SkinAuthListBox"):IsShown() then
			PlayerCenterDataEditPage2SkinAuthList_OnClick();
		end

		if getglobal("PlayerCenterDataEditPage2DressAuthListBox"):IsShown() then
			PlayerCenterDataEditPage2DressAuthList_OnClick();
		end

		if ClientMgr:isPC() then
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + delatH)
		else
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + getglobal(editPage3Name):GetHeight() + delatH)
		end
	end
end

-------------------------------------装扮图鉴权限------------------------------------------------------------------------
function PlayerCenterDataEditPage2DressAuthList_OnClick()
	local box = getglobal("PlayerCenterDataEditPage2DressAuthListBox");
	local down = getglobal("PlayerCenterDataEditPage2DressAuthListDown");
	local up   = getglobal("PlayerCenterDataEditPage2DressAuthListUp");

	-- 心情发布展示，开关控制
	local DataEditFrame = "PlayerCenterDataEdit"
	local PlaneName = DataEditFrame.."Plane"
	local editPage1Name = DataEditFrame.."Page1"
	local editPage2Name = DataEditFrame.."Page2"
	local editPage3Name = DataEditFrame.."Page3"

	local delatH = 200 --动态查看权限 点开后 超出的高度

	if box:IsShown() then
		box:Hide();
		down:Show();
		up:Hide();

		--调整面板的高度
		if ClientMgr:isPC() then
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + delatH)
		else
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + getglobal(editPage3Name):GetHeight())
		end
	else
		box:Show()
		down:Hide();
		up:Show();

		if getglobal("PlayerCenterDataEditPage2CommentAuthListBox"):IsShown() then
			PlayerCenterDataEditPage2CommentAuthList_OnClick();
		end

		if getglobal("PlayerCenterDataEditPage1GenderList"):IsShown() then
			PlayerCenterDataEditPage1GenderBtn_OnClick();
		end

		if getglobal("PlayerCenterDataEditPage2SkinAuthListBox"):IsShown() then
			PlayerCenterDataEditPage2SkinAuthList_OnClick();
		end

		if ClientMgr:isPC() then
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + delatH)
		else
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + getglobal(editPage3Name):GetHeight() + delatH)
		end
	end
end

-------------------------------------个人搭配权限------------------------------------------------------------------------
function PlayerCenterDataEditPage2SkinAuthList_OnClick()
	local box = getglobal("PlayerCenterDataEditPage2SkinAuthListBox");
	local down = getglobal("PlayerCenterDataEditPage2SkinAuthListDown");
	local up   = getglobal("PlayerCenterDataEditPage2SkinAuthListUp");

	-- 心情发布展示，开关控制
	local DataEditFrame = "PlayerCenterDataEdit"
	local PlaneName = DataEditFrame.."Plane"
	local editPage1Name = DataEditFrame.."Page1"
	local editPage2Name = DataEditFrame.."Page2"
	local editPage3Name = DataEditFrame.."Page3"

	local delatH = 200 --动态查看权限 点开后 超出的高度

	if box:IsShown() then
		box:Hide();
		down:Show();
		up:Hide();

		--调整面板的高度
		if ClientMgr:isPC() then
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + delatH)
		else
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + getglobal(editPage3Name):GetHeight())
		end
	else
		box:Show()
		down:Hide();
		up:Show();

		if getglobal("PlayerCenterDataEditPage2CommentAuthListBox"):IsShown() then
			PlayerCenterDataEditPage2CommentAuthList_OnClick();
		end

		if getglobal("PlayerCenterDataEditPage1GenderList"):IsShown() then
			PlayerCenterDataEditPage1GenderBtn_OnClick();
		end

		if getglobal("PlayerCenterDataEditPage2DressAuthListBox"):IsShown() then
			PlayerCenterDataEditPage2DressAuthList_OnClick();
		end

		if ClientMgr:isPC() then
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + delatH)
		else
			getglobal(PlaneName):SetHeight(getglobal(editPage1Name):GetHeight() + getglobal(editPage2Name):GetHeight() + getglobal(editPage3Name):GetHeight() + delatH)
		end
	end
end

local TitleIsShow = false
-------------------------------------性别选择下拉框------------------------------------------------------------------------
function PlayerCenterDataEditPage1GenderBtn_OnClick()
	local box = getglobal("PlayerCenterDataEditPage1GenderList");
	local down = getglobal("PlayerCenterDataEditPage1GenderDown");
	local up   = getglobal("PlayerCenterDataEditPage1GenderUp");
	local listBkg = getglobal("PlayerCenterDataEditPage1GenderListBkg");
	local Title =  getglobal("PlayerCenterDataEditPage1TitleSystemBtnTitle");
	local name = getglobal("PlayerCenterDataEditPage1TitleSystemBtnName");
	local nameBkg = getglobal("PlayerCenterDataEditPage1TitleSystemBtnNameBkg");

	--local titleIs
	--PlayerCenterDataEditPage1TitleSystemBtnTitle
	--PlayerCenterDataEditPage1TitleSystemBtnNameBkg
	--PlayerCenterDataEditPage1TitleSystemBtnName
	local page2 = getglobal("PlayerCenterDataEditPage2");
	standReportEvent("7", "PERSONAL_INFO_SETTINGS", "Gender", "click")
	if box:IsShown() then
		box:Hide();
		down:Show();
		up:Hide();
		listBkg:Hide();
		if GetInst("TitleSystemInterface"):TitleIsOPen() then
			if TitleIsShow then
				Title:Show();
			else
				name:Show();
				nameBkg:Show();
			end
		else
			page2:SetPoint("top", "PlayerCenterDataEditPage1", "bottom", 0, 10);
		end
		
		--
	else
		
		box:Show();
		down:Hide();
		up:Show();
		listBkg:Show();
		if GetInst("TitleSystemInterface"):TitleIsOPen() then
			if Title:IsShown() then
				TitleIsShow = true
			end
			Title:Hide();
			name:Hide();
			nameBkg:Hide();
		else
			page2:SetPoint("top", "PlayerCenterDataEditPage1", "bottom", 0, 60);
		end
	end
end

-------------------------------------头像框设置页面--------------------------------------------------------------------------

--加载头像框配置
function ZoneLoadHeadFrameConfig()
	print("ZoneLoadHeadFrameConfig:");
	if 	not g_heads_frame_config then
		g_heads_frame_config = {};

		g_heads_frame_config_map = loadwwwcache('res.HeadFrameDef');
		g_heads_frame_config_map[1] = { FrameID=1, ItemID=1, StringID=5300, Group=1 };				--增加默认框
		for k, v in pairs( g_heads_frame_config_map ) do
			if  v.ItemID == v.FrameID then
				table.insert( g_heads_frame_config, v );
			end
		end

		--按照id排序
		local function comps_(a, b)
			return a.FrameID < b.FrameID
		end
		table.sort( g_heads_frame_config, comps_ );
	end
end

function ZoneHeadEdit_OnLoad()
	print("ZoneHeadEdit_OnLoad:");
end

function ZoneHeadEdit_OnShow()
	print("ZoneHeadEdit_OnShow:");

	--标题名
	getglobal("ZoneHeadEditTitleFrameName"):SetText(GetS(3489));

	ZoneLoadHeadFrameConfig();
	ZoneHeadEditChannel_OnClick(1);
	getglobal( "ZoneHeadEditChannel1" ):Checked();
end

--类别tab
--选择头像分类 1=全部 2=主播专属 2=主播专属(old:PlayerCenterFrameInfoEditChannel_OnClick())
function ZoneHeadEditChannel_OnClick(num_)
	Log("call ZoneHeadEditChannel_OnClick=" .. num_)

	t_exhibition.playerinfo.head_frame_id_select = t_exhibition.playerinfo.head_frame_id;   --记录备选值

	for i=1, 4 do
		if  i==num_ then
			getglobal( "ZoneHeadEditChannel" .. i  ):Disable();
			getglobal( "ZoneHeadEditChannel" .. i  ):SetGray(false);
			ZoneShowAllHeadByType( i );
		else
			getglobal( "ZoneHeadEditChannel" .. i  ):Enable();
			getglobal( "ZoneHeadEditChannel" .. i  ):DisChecked();
		end
	end

	-- 会员头像框tabbtn点击
	if num_ == 4 then
		-- 埋点 会员头像框分页按钮	MiniVipHeadFream	click
		standReportEvent("7", "HEAD_FREAM","MiniVipHeadFream", "click")
	end
end

function ZoneHeadEditBox_tableCellAtIndex(tableView, idx)
	local type_name = "Button"
	local template_name = "ZoneHeadFrameTemplate"
	local parent_name = "ZoneHeadEditBox";
	local cell, uiidx = tableView:dequeueCell(0)

	if not cell then
		local cell_name = "ZoneHeadEditHeadFrame" .. uiidx
		cell = UIFrameMgr:CreateFrameByTemplate(type_name, cell_name, template_name, parent_name)
	else
		cell:Show()
	end

	local info = t_exhibition.head_select[idx + 1]
	if info then
		RefreshZoneHeadEditBoxList(cell, info, idx)
	end

	return cell
end

function RefreshZoneHeadEditBoxList(cell, info, idx)
	idx = idx + 1
	if info and cell then
		local cellname = cell:GetName()
		cell:Show();

		local icon_ = getglobal( cellname .. "Frame");
		icon_:SetTexture( HeadFrameCtrl:getTexPath( info.FrameID ) );
		icon_:Show();


		--是否显示锁
		local locker_ = getglobal( cellname .. "Lock");
		local temp_   = getglobal( cellname .. "Temp");
		temp_:Hide();
		local open_, left_ = func_has_opened_head_frames(info.FrameID)
		Log( "head_frame open=" .. open_ .. ", left=" .. left_ .. ", for " .. info.FrameID );
		if  open_ > 0 then
			locker_:Hide();
			if  left_ > 0 then
				temp_:Show();     --显示临时标志
			end
		else
			locker_:Show();
		end
		if info.VipType and info.VipType == 1 then
			if GetInst('MembersSysMgr'):IsMember() then
				locker_:Hide()
			else
				locker_:Show()
			end
		end
		if t_exhibition.playerinfo.head_frame_id_select == info.FrameID then
			getglobal( cellname .. 'Head' ):Show();
			showPicNoStretch( cellname .. 'Head' );
			HeadCtrl:CurrentHeadIcon(cellname .. 'Head');
		else
			getglobal( cellname .. 'Head' ):Hide();
		end
	end
end


function ZoneHeadEditBox_numberOfCellsInTableView(tableView)
	local count = #t_exhibition.head_select
	return count
end

function ZoneHeadEditBox_tableCellWillRecycle(tableView,cell)
	if cell then cell:Hide() end
end

--获取部件大小
function ZoneHeadEditBox_tableCellSizeForIndex(tableView,index)
    local cellIndex = math.mod(index,6)
	return 107*cellIndex , 10, 90, 90
end

--排序头像框, 解锁的放前面
local ZoneSortHeadFrameByOpenType = function(it1, it2)
	print("ZoneSortHeadFrameByOpenType:");
	if nil == it1 or nil == it2 then
		return false;
	end

	local open1, left1 = func_has_opened_head_frames(it1.FrameID);
	local open2, left1 = func_has_opened_head_frames(it2.FrameID);

	print(open1, open2);

	-- if open1 == open2 then
	-- 	return false;
	-- else
	-- 	return open1 > open2;
	-- end

	if open1 > open2 then
		return true;
	end

	if open1 < open2 then
		return false;
	end

	--如果open1==open2, 则比较"FrameID"
	if it1.FrameID > it2.FrameID then
		return true;
	end

	if it1.FrameID < it2.FrameID then
		return false;
	end

	return false;
end

-- 按照类型展示头像(old:ShowAllHeadByType())
function ZoneShowAllHeadByType( type_ )
	print("ZoneShowAllHeadByType: type_ = " .. type_);
	t_exhibition.head_select_type = type_;  --记录当前玩家选择的分类

	-- 1=所有头像 2=主播 过滤选项
	t_exhibition.head_select = {};


	--显示
	local function is_no_hide_ ( v )		
		-- if  v.HideType and v.HideType == 1 then
		-- 	--没有开通隐藏头像
		-- 	if  func_has_opened_head_frames( v.FrameID ) > 0 then
		-- 		return true
		-- 	else
		-- 		return false  --没有开通，隐藏
		-- 	end
		-- end
		-- return true

		local beginTime = 0
		if func_has_opened_head_frames( v.FrameID ) <= 0 then
			-- 没解锁
			if v.BeginTime and type(v.BeginTime) == "number" then				
				beginTime = v.BeginTime
			end
			if AccountManager:getSvrTime() >= beginTime then
				-- 到达展示时间
				if v.HideType and v.HideType == 1 then
					return false
				end
			else
				return false
			end
		end

		return true
	end


	--for i=1, #g_heads_frame_config do
	for k, v in ipairs(g_heads_frame_config) do
		if  type_ == 1 then
			--所有头像
			if  is_no_hide_( v ) then
				table.insert( t_exhibition.head_select, v );
			end
		else
			--分类头像
			if  type_ == v.Group then
				if  is_no_hide_( v ) then
					table.insert( t_exhibition.head_select, v );
				end
			end
		end
	end

	if t_exhibition.head_select then
		table.sort(t_exhibition.head_select, ZoneSortHeadFrameByOpenType);
	end

	local boxUI = getglobal("ZoneHeadEditBox");
	local count = #t_exhibition.head_select
	local row = math.ceil(count/6);
	local totalH = row * 100 + 20;
	totalH = math.max(boxUI:GetHeight(), totalH);

    boxUI:initData(620, totalH, row, 6, false)
end

function UpdateZoneHeadSelect(index)
    local CellCount = #t_exhibition.head_select

    for i=1, CellCount do
        local cell = getglobal("ZoneHeadEditBox"):cellAtIndex(i-1)
        if cell and index == i then
			local cellname = cell:GetName()
            --选中高亮
            getglobal( cellname .. 'Head' ):Show();
			showPicNoStretch( cellname .. 'Head' );
			HeadCtrl:CurrentHeadIcon(cellname .. 'Head');
        elseif cell and index ~= i then
			local cellname = cell:GetName()
			getglobal( cellname .. 'Head' ):Hide();
        end
    end
end

--玩家是否已经解锁了这个头像
--类型/1是7天，2是30天，3是永久，4是1天（只2和3有效）
function func_has_opened_head_frames( head_id_ )
	if  head_id_ == 1 then
		return 3, 0   --默认头像 永久开通
	else
		if     t_exhibition.playerinfo.head_frames      and t_exhibition.playerinfo.head_frames[ head_id_ ] then
			return 3, 0   --永久开通
		elseif t_exhibition.playerinfo.head_frames_temp and t_exhibition.playerinfo.head_frames_temp[ head_id_ ] then
			--计算剩余时间
			local t_      = t_exhibition.playerinfo.head_frames_temp[ head_id_ ].t    or 0
			local left_   = t_exhibition.playerinfo.head_frames_temp[ head_id_ ].left or 0
			local s_time_ = getServerNow()
			local left_   = (t_+left_) - s_time_
			if  left_ > 0 then
				return 1, left_   --临时开通
			end
		end
	end

	return 0, 0  --未开通
end

--头像框点击(old:PlayerCenterHeadFrameBtn_OnClick())
function ZoneHeadFrameTemplate_OnClick()
	local id = this:GetClientID();
	id = id + 1
	if  id == 0 then
		Log( "call ZoneHeadFrameTemplate_OnClick=0, normal ignore." );  --不能点击的外部按钮
	else
		if  t_exhibition.head_select and t_exhibition.head_select[ id ] then
			if  t_exhibition.playerinfo.head_frame_id_select ~= t_exhibition.head_select[ id ].FrameID then
				Log( "call ZoneHeadFrameTemplate_OnClick=" .. id .. ", head=" .. t_exhibition.head_select[ id ].FrameID );
				t_exhibition.playerinfo.head_frame_id_select =  t_exhibition.head_select[ id ].FrameID;
				-- ZoneShowAllHeadByType( t_exhibition.head_select_type );
				UpdateZoneHeadSelect(id)
			end

			----显示说明
			local  info_ = g_heads_frame_config_map[t_exhibition.playerinfo.head_frame_id_select];
			if info_ then
				getglobal('ZoneHeadEditUploadBtn'):Show()

				if info_.VipType and info_.VipType == 1 then
					-- 解锁按钮显示与否
					if GetInst('MembersSysMgr'):IsMember() then
						getglobal('ZoneHeadEditUploadBtn'):Hide()
					end
				end

				if info_.StringID then
					local tips1_ = getglobal('ZoneHeadEditTips1');
					if info_.StringID == 5300 then
						tips1_:SetText(GetS(5300))
					else
						local itemDef = ItemDefCsv:get(info_.FrameID)
						if itemDef then
							tips1_:SetText(tostring(itemDef.Name)..": "..tostring(itemDef.GetWay));
						else
							tips1_:SetText("")
						end
					end
				
					tips1_:Show();
					
					local tips2_ = getglobal('ZoneHeadEditTips2');
					local open_, left_ = func_has_opened_head_frames(t_exhibition.playerinfo.head_frame_id_select)
					if  left_ > 0 then
						local day  = math.floor( left_ / 86400 )
						local hour = math.floor( (left_ % 86400) / 3600 )					
						local left_text_  = GetS(3179)..":"..day..GetS(3118)..hour..GetS(4088);
						tips2_:Show()
						tips2_:SetText( left_text_ )
					else
						tips2_:Hide()
					end				
				end
			end



		end
	end
end

--重置所有玩家头像
function resetAllHead()
	print("resetAllHead:");
	if m_NewPlayerCenterParam.m_bIsNew then
		-----------------------------------------------------------------new-----------------------------------------------------------------
		local file_name_ =  t_exhibition.playerinfo.headIndexFile;

		if file_name_ then
			print("file_name_:" .. file_name_);
			if IsLookSelf() then
				print("lookSelf:");
				--主页
				-- HeadCtrl:CurrentHeadIcon('MiniLobbyFrameTopRoleInfoHeadIcon' );
				-- HeadFrameCtrl:CurrentHeadFrame('MiniLobbyFrameTopRoleInfoHeadNormal');
				-- HeadFrameCtrl:CurrentHeadFrame('MiniLobbyFrameTopRoleInfoHeadPushedBG');
				ResetMiniLobbyRoleInfoIcon() --mark by hfb for new minilobby
				--个人中心
				HeadCtrl:CurrentHeadIcon('PlayerExhibitionCenterRoleInfoHeadIcon')
				--getglobal( 'MiniLobbyFrameTopRoleInfoHeadIcon' ):SetTextureCentrally( file_name_ );
			elseif t_exhibition:CheckProfileBlackStat(ns_playercenter.uin) then
				-- getglobal( 'MiniLobbyFrameTopRoleInfoHeadIcon' ):SetTextureCentrally("ui/snap_jubao.png");
				local headIcon = GetMiniLobbyRoleInfoIconFrame()
				if tolua.type(headIcon) == "miniui.GLoader" then
					headIcon:setIcon("ui/snap_jubao.png")
				else
					headIcon:SetTextureCentrally("ui/snap_jubao.png")
				end

			end

			getglobal( 'ZoneHeadEditHead' ):Show();
			if file_name_ and string.find(file_name_, "data/http/") then
				getglobal( 'ZoneHeadEditHead' ):SetTexture( file_name_ );
				showPicNoStretch( 'ZoneHeadEditHead' );
			else
				HeadCtrl:CurrentHeadIcon('ZoneHeadEditHead');
			end
			getglobal( 'PlayerCenterDataEditPage1HeadBtnHead' ):Show();
			--getglobal( 'PlayerCenterDataEditPage1HeadBtnHead' ):SetTexture( file_name_ );
			--showPicNoStretch( 'PlayerCenterDataEditPage1HeadBtnHead' );
			HeadCtrl:CurrentHeadIcon( 'PlayerCenterDataEditPage1HeadBtnHead');

			-- for i=1, t_exhibition.head_max do
			-- 	showPicNoStretch( 'ZoneHeadEditHeadFrame' .. i .. 'Head' );
			-- 	HeadCtrl:CurrentHeadIcon('ZoneHeadEditHeadFrame' .. i .. 'Head');
			-- 	--getglobal( 'ZoneHeadEditHeadFrame' .. i .. 'Head' ):SetTexture( file_name_ );
			-- 	--showPicNoStretch( 'ZoneHeadEditHeadFrame' .. i .. 'Head' );
			-- end
		end



	else
		-- local file_name_ =  ns_playercenter.headIndexFile;
		-- Log( "call resetAllHead=" .. file_name_ );

		-- --小头像
		-- getglobal( 'PlayerCenterFrameSubPage1HeadHead' ):SetTexture( file_name_ );
		-- getglobal( 'PlayerCenterFrameInfoEditHeadBtnHead' ):SetTexture( file_name_ );

		-- if  t_exhibition:isLookSelf() then
		-- 	getglobal( 'MiniLobbyFrameTopRoleInfoHeadIcon' ):SetTexture( file_name_ );
		-- end

		-- getglobal( 'PlayerCenterFrameHeadEditHead' ):Show();
		-- getglobal( 'PlayerCenterFrameHeadEditHead' ):SetTexture( file_name_ );

		-- showPicNoStretch( 'PlayerCenterFrameSubPage1HeadHead' );
		-- showPicNoStretch( 'PlayerCenterFrameInfoEditHeadBtnHead' );
		-- showPicNoStretch( 'PlayerCenterFrameHeadEditHead' );

		-- if  t_exhibition:isLookSelf() then
		-- 	showPicNoStretch( 'MiniLobbyFrameTopRoleInfoHeadIcon' );
		-- end

		-- for i=1, ns_playercenter.head_max do
		-- 	getglobal( 'PlayerCenterFrameHeadEditHeadFrame' .. i .. 'Head' ):SetTexture( file_name_ );
		-- 	showPicNoStretch( 'PlayerCenterFrameHeadEditHeadFrame' .. i .. 'Head' );
		-- end
	end
end

-- 确认修改头像(old:layerCenterFrameHeadEditConfirm1_OnClick())
function ZoneHeadEditConfirm_OnClick(callBack)
	Log( "call ZoneHeadEditConfirm_OnClick, id=" .. t_exhibition.playerinfo.head_frame_id_select);

	--是否已经在使用
	if  t_exhibition.playerinfo.head_frame_id_select == t_exhibition.playerinfo.head_frame_id then
		--未变化
		Log("same headframe");
		ShowGameTips(GetS(5298));
		return
	end
	local curSel = g_heads_frame_config_map[t_exhibition.playerinfo.head_frame_id_select]
	-- 非会员时提示[Desc5]会员
	if curSel.VipType and curSel.VipType == 1 then
		if not GetInst('MembersSysMgr'):IsMember() then
			MessageBox(5, GetS(70784), function(btn)
				if btn == 'right' then return end
				GetInst('MembersSysMgr'):ToMembersPayView(function()
					ZoneShowAllHeadByType( t_exhibition.head_select_type )
				end, onOpenShopSetFrameLevel, onCloseShopSetFrameLevel)
			end)
		else
			GetInst('MembersSysMgr'):ReqSetPrivilege(1, 1, curSel.FrameID, function(ret)
				if func_has_opened_head_frames( t_exhibition.playerinfo.head_frame_id_select ) > 0 then
					HeadFrameCtrl:SetHeadFrameId(t_exhibition.playerinfo.head_frame_id_select);
				else
					ShowGameTips(GetS(5299));
				end
				WWW_setPlayerFrameId( t_exhibition.playerinfo.head_frame_id_select );

				--佩戴头像框打点（默认头像框不打点） 会员头像打点的先不处理
				-- if curSel.FrameID ~= 1 then
				-- 	local itemDef = ItemDefCsv:get(curSel.ItemID)
				-- 	local open_, left_ = func_has_opened_head_frames(curSel.FrameID);
				-- 	if open_ > 0 then
				-- 		local timeType = left_ > 0 and 2 or 1;
				-- 		statisticsGameEvent(62004, "%d", curSel.FrameID, "%lls", itemDef.Name, "%d", timeType, "%d", 2);
				-- 	end
				-- end
				if callBack then
					callBack()
				end
				getglobal("ZoneHeadEdit"):Hide();
			end)
		end
		return
	end

	local select_ =  g_heads_frame_config_map[ t_exhibition.playerinfo.head_frame_id_select ];
	if  select_ then
		--判断是否已经开通
		if  func_has_opened_head_frames( t_exhibition.playerinfo.head_frame_id_select ) > 0 then
			--已经开通
			Log( "has open" )
			HeadFrameCtrl:SetHeadFrameId(t_exhibition.playerinfo.head_frame_id_select);
		else
			--未开通
			Log( "not open" )
			ShowGameTips(GetS(5299));
			return
		end

		--如果是鉴赏家头像框，检测权限
		--[[
		if  t_exhibition.head_frame_id_select == 20220 or t_exhibition.head_frame_id_select == 20320 then
			if  t_exhibition.expert and t_exhibition.expert.stat and t_exhibition.expert.stat == 2 then
				--是鉴赏家
			else
				Log( "not experter" )
				ShowGameTips(GetS(1331));
				return
			end
		end
		]]
		
		
		--切换头像框
		WWW_setPlayerFrameId( t_exhibition.playerinfo.head_frame_id_select );

		--佩戴头像框打点（默认头像框不打点）
		if select_.FrameID ~= 1 then
			local itemDef = ItemDefCsv:get(select_.ItemID)
			local open_, left_ = func_has_opened_head_frames(select_.FrameID);
			if open_ > 0 then
				local timeType = left_ > 0 and 2 or 1;
				-- statisticsGameEvent(62004, "%d", select_.FrameID, "%lls", itemDef.Name, "%d", timeType, "%d", 2);
			end
		end

		if callBack then
			callBack()
		end
		getglobal("ZoneHeadEdit"):Hide();
	else
		Log( "error: no this id" );
	end
end

-- 设置用户头像框
function WWW_setPlayerFrameId( head_frame_id_ )
	print("WWW_setPlayerFrameId:");
	if  t_exhibition.net_ok then
		local url_ = g_http_root_map .. 'miniw/profile?act=setProfile&head_frame_id=' .. head_frame_id_ .. '&' .. http_getS1Map();
		Log( url_ );
		ns_http.func.rpc( url_, WWW_setPlayerFrameId_cb, nil, nil, true );
		t_exhibition.self_data_dirty = true;
	else

	end
end

function WWW_setPlayerFrameId_cb( ret_,bolTip )
	Log( "call WWW_setPlayerFrameId_cb" );
	if  ret_ and ret_.ret then
		if  ret_.ret == 0 then   				--修改成功
			t_exhibition.playerinfo.head_frame_id = t_exhibition.playerinfo.head_frame_id_select;

			--保存头像框
			if  t_exhibition:isLookSelf() then
				setkv( "head_frame_id_cache", t_exhibition.playerinfo.head_frame_id );
			end

			zone_refresh_ui();
			if bolTip then
				ShowGameTips(GetS(5297));
			end
		else
			
		end
	else
		Log( "ERROR: ret=nil" );
	end
end

-- 改头像框
function changeHeadFrameTxtPic( head_frame_id_, pic_ )
	Log( "call changeHeadFrameTxtPic = " .. head_frame_id_ );

	local pic_obj_ = getglobal( pic_ );
	if  pic_obj_ then
		pic_obj_:SetTexture( HeadFrameCtrl:getTexPath(head_frame_id_) );
	end
end

--数据变化后 刷新所有界面(old:refresh_ui())
function zone_refresh_ui()
	print("zone_refresh_ui:");
	--性别gender
	changeGenderTxtPic(  t_exhibition.playerinfo.gender, 'PlayerCenterDataEditPage1GenderPic', 'PlayerCenterDataEditPage1GenderName' );
	changeGenderTxtPic(  t_exhibition.playerinfo.gender, 'PlayerExhibitionCenterRoleInfoGender'  );

	--刷新头像框
	--changeHeadFrameTxtPic( t_exhibition.playerinfo.head_frame_id, 'PlayerExhibitionCenterRoleInfoHeadNormal' );
	--changeHeadFrameTxtPic( t_exhibition.playerinfo.head_frame_id, 'PlayerExhibitionCenterRoleInfoHeadPushedBG' );
	HeadFrameCtrl:SetPlayerheadFrame("PlayerExhibitionCenterRoleInfoHead",t_exhibition.playerinfo.head_frame_id);
	--changeHeadFrameTxtPic( t_exhibition.playerinfo.head_frame_id, 'ExhibitionInfoPage1AhutorCommentHeadNormal' );
	--changeHeadFrameTxtPic( t_exhibition.playerinfo.head_frame_id, 'ExhibitionInfoPage1AhutorCommentHeadPushedBG' );
	HeadFrameCtrl:SetPlayerheadFrame("ExhibitionInfoPage1AhutorCommentHead",t_exhibition.playerinfo.head_frame_id);
	--changeHeadFrameTxtPic( t_exhibition.playerinfo.head_frame_id, 'PlayerCenterDataEditPage1HeadBtnFrame' );
	HeadFrameCtrl:SetPlayerheadFrameName("PlayerCenterDataEditPage1HeadBtnFrame",t_exhibition.playerinfo.head_frame_id);
	--changeHeadFrameTxtPic( t_exhibition.playerinfo.head_frame_id, 'LobbyFrameHeadBtnIconFrame' );
	--changeHeadFrameTxtPic( t_exhibition.playerinfo.head_frame_id, 'HomeChestFrameRoleInfoHeadBtnIconFrame' );

	if  t_exhibition:isLookSelf() then
		--changeHeadFrameTxtPic( t_exhibition.playerinfo.head_frame_id, 'MiniLobbyFrameTopRoleInfoHeadNormal' );
		--changeHeadFrameTxtPic( t_exhibition.playerinfo.head_frame_id, 'MiniLobbyFrameTopRoleInfoHeadPushedBG' );
		-- HeadFrameCtrl:SetPlayerheadFrame("MiniLobbyFrameTopRoleInfoHead",t_exhibition.playerinfo.head_frame_id);
		HeadFrameCtrl:SetPlayerheadFrame( GetMiniLobbyRoleInfoHeadFrameName(),t_exhibition.playerinfo.head_frame_id); --mark by hfb for new minilobby
	end

	--优先展示频道
	PlayerCenter_SetFirstUI();

	--是否可评论
	ZoneUpdateRepAndSeeUIState();

	--刷新昵称和模型
	-- resetNameAndMode();
	getglobal("PlayerCenterDataEditPage1NickNameName"):SetText(t_exhibition.playerinfo.NickName);

	--头像url更新
	setPlayerHeadByUrl( t_exhibition.playerinfo.head_url );

	--是否解锁上传头像
	if  IsLookSelf() then
		-- resetUploadHead();
		Zone_resetUploadHead();
	end

	-- --第一页的3个图片摘要
	-- checkPage1_3Photo();

	-- --相册2
	-- resetPage2AllPhoto();


	-- --鉴赏家图标
	-- resetConnoisseurIcon();
end

function Zone_resetUploadHead()
	print("Zone_resetUploadHead:");
	if  t_exhibition.head_unlock == 1 then
		getglobal( 'ZoneHeadEditUploadBtnText' ):SetText( GetS(3470) ); --"上传头像" );
		getglobal('ZoneHeadEditUploadBtn'):Hide()
		getglobal('ZoneHeadEditChangeHeadBtn'):Show()
		getglobal('ZoneHeadEditDelHeadBtn'):Show()
	else
		getglobal( 'ZoneHeadEditUploadBtnText' ):SetText( GetS(4771) ); --"解锁" );
		getglobal('ZoneHeadEditUploadBtn'):Show()
		getglobal('ZoneHeadEditChangeHeadBtn'):Hide()
		getglobal('ZoneHeadEditDelHeadBtn'):Hide()
	end
end

-------------------------------------上传头像页面--------------------------------------------------------------------------
function CheckBeforeEditHeadImage(discard_upload_check)
	-- 操作头像动作前的检查
	if ns_data.IsGameFunctionProhibited("u", 10579, 10580) then 
		return 
	end
	
	if  IsLookSelf() then
		--normal
	else
		return;
	end

	if  t_exhibition.close_upload == 1 and not discard_upload_check then
		ShowGameTips( GetS(3479), 3 );  --"此功能暂未开放。", 3);
		return;
	end

	if IsProtectMode() then
		ShowGameTips(GetS(4842), 3);
		return;
	end

	if  t_exhibition.head_unlock == 0 then
		--getglobal( 'UnlockCostCommFrame' ):Show();
		beginUnlockHead(1);
		return;
	end

	return true;
end

function ZoneHeadEditUploadHeadBtn_OnClick()
	Log( "call ZoneHeadEditUploadHeadBtn_OnClick" ..  t_exhibition.playerinfo.head_frame_id_select);
	local curSel = g_heads_frame_config_map[t_exhibition.playerinfo.head_frame_id_select]
	-- 非会员时提示[Desc5]会员
	if curSel.VipType and curSel.VipType == 1 then
		if not GetInst('MembersSysMgr'):IsMember() then
			SetNeedChangeFrameSelectTag(1)
			MessageBox(5, GetS(70784), function(btn)
				if btn == 'right' then return end
				-- 埋点 非会员使用头像框跳转[Desc5]确认按钮	BuySure	click
				standReportEvent("7", "HEAD_FREAM","BuySure", "click")
				GetInst('MembersSysMgr'):ToMembersPayView(function()
					ZoneShowAllHeadByType( t_exhibition.head_select_type )
				end, onOpenShopSetFrameLevel, onCloseShopSetFrameLevel)
			end)
		end
		return
	end


	if not CheckBeforeEditHeadImage() then
		return
	end

	local head_path_ = getkv( "head_pic_cache" );
	Log( "head_path_=" .. (head_path_ or "nil") );
	if  head_path_ and #head_path_>0 and gFunc_isStdioFileExist( head_path_ ) then
		PlayerCenterFrameHeadChange_OnClick(0);
	else
		private_upload_head();
	end
end

function ZoneHeadEditChangeHeadBtn_OnClick()
	-- 编辑头像
	if not CheckBeforeEditHeadImage() then
		return
	end

	local head_path_ = getkv( "head_pic_cache" );
	Log( "head_path_=" .. (head_path_ or "nil") );
	if  head_path_ and #head_path_>0 and gFunc_isStdioFileExist( head_path_ ) then
		PlayerCenterFrameHeadChange_OnClick(1);
	else
		private_upload_head();
	end
end

function ZoneHeadEditDelHeadBtn_OnClick()
	-- 恢复默认
	-- 功能关闭的时候也可以恢复默认
	if not CheckBeforeEditHeadImage(1) then
		return
	end

	local file_name_ =  t_exhibition.playerinfo.headIndexFile;
	if file_name_ and string.find(file_name_, "data/http/") then
	else
		ShowGameTips(GetS(25301))
		return
	end

	PlayerCenterFrameHeadChange_OnClick(2)
end

function PlayerCenterFrameHeadChange_OnClick( act_ )
	Log( "call PlayerCenterFrameHeadChange_OnClick, act=" .. act_ );

	if  t_exhibition:isLookSelf() then
		--self
	else
		return
	end

	if act_ == 0 then
		getglobal("PlayerCenterFrameHeadChange"):Show();
	elseif act_ == 1 then
		--修改头像
		private_upload_head();
		getglobal("PlayerCenterFrameHeadChange"):Hide();
	elseif act_ == 2 then
		--恢复默认
		private_remove_head();
		getglobal("PlayerCenterFrameHeadChange"):Hide();
	else
		--关闭
		getglobal("PlayerCenterFrameHeadChange"):Hide();
	end

end

-------------------------------------名字设置页面--------------------------------------------------------------------------
-- 数值修改回调 1=头像  2=昵称  3=性别
function PlayerCenterFrame_dataChange( value )
	-- if  value == 2 then
	-- 	ns_playercenter.NickName = AccountManager:getNickName();
	-- 	ns_playercenter.self_data_dirty = true;
	-- 	getglobal( "PlayerCenterFrameInfoEditNickName" ):SetText( ns_playercenter.NickName  );
	-- 	PlayerCenterFrameSubPage1_OnShow();
	-- end

	if  value == 2 then
		t_exhibition.playerinfo.NickName = AccountManager:getNickName();
		t_exhibition.self_data_dirty = true;
		getglobal( "PlayerCenterDataEditPage1NickNameName" ):SetText( t_exhibition.playerinfo.NickName  );
		
	end
end

-------------------------------------性别设置页面--------------------------------------------------------------------------

function ZoneEditGender_OnShow()
	ZoneEditGenderSelect_OnClick(  t_exhibition.playerinfo.gender );
	getglobal( "ZoneEditGenderSelect" ..  t_exhibition.playerinfo.gender ):Checked();

	t_exhibition.gender_select = t_exhibition.playerinfo.gender;   --记录备选值
end


function ZoneEditGenderCloseBtn_OnClick()
	getglobal("ZoneEditGender"):Hide();
end

--选择性别 0=秘密 1=男 2=女(old:PlayerCenterFrameEditGenderSelect_OnClick())
function ZoneEditGenderSelect_OnClick(num_)
	print("ZoneEditGenderSelect_OnClick:num_ = " .. num_);

	for i=0, 2, 1 do
		if i == num_ then
			getglobal( "ZoneEditGenderSelect" .. i  ):Disable();
			t_exhibition.gender_select = num_;
			getglobal( "ZoneEditGenderSelect" .. i  .. "Tips" ):SetTextColor( 251, 253, 246 );

		else
			getglobal( "ZoneEditGenderSelect" .. i  ):Enable();
			getglobal( "ZoneEditGenderSelect" .. i  ):DisChecked();
			getglobal( "ZoneEditGenderSelect" .. i  .. "Tips" ):SetTextColor( 149, 131, 95 );
		end
	end
end

--确认或者取消修改性别  0=取消 1=确定(old:PlayerCenterFrameEditGenderConfirm_OnClick())
function ZoneEditGenderConfirm_OnClick( num_ )
	if num_ == 1 then
		--修改
		if  t_exhibition.gender_select == t_exhibition.playerinfo.gender then
			--未变化
		else
			WWW_setPlayerGender( t_exhibition.gender_select );
		end
	end

	getglobal("ZoneEditGender"):Hide();
end

-- 设置用户性别:0=秘密 1=男 2=女
function WWW_setPlayerGender( gender_ )
	print("WWW_setPlayerGender:");
	if  t_exhibition.net_ok then
		local url_ = g_http_root_map .. 'miniw/profile?act=setProfile&gender=' .. gender_ .. '&' .. http_getS1Map();
		Log( url_ );
		ns_http.func.rpc( url_, WWW_setPlayerGender_cb, nil, nil, true );
		t_exhibition.self_data_dirty = true;
	else
		
	end
end


function WWW_setPlayerGender_cb( ret_ )
	Log( "call WWW_setPlayerGender_cb" );
	if  ret_ and ret_.ret then
		if ret_.ret == 0 then   --修改成功
			t_exhibition.playerinfo.gender = t_exhibition.gender_select;
			zone_refresh_ui();
		else
			
		end
	else
		Log( "ERROR: ret=nil" );
	end
end

-------------------------------------形象锁按钮--------------------------------------------------------------------------
--设置锁按钮图标
function ZoneSetLockIconState()
	local lockIcon 		 = getglobal ("PlayerExhibitionCenterLockBtnIcon");
	lockIcon:SetTexUV("icon_image");

	local errcode, info = ZoneGetLockInfo();
	if errcode == ErrorCode.OK and info then
		--已经上锁了
		lockIcon:SetTexUV("icon_image");
	end
end

function PlayerExhibitionCenterLockBtn_OnClick()
	if GetInst("PlayerCenterManager") then
		--装扮锁的功能修改为打开形象编辑
		standReportEvent("7", "LOOK_EDIT", "LookEditButton", "click")
		GetInst("PlayerCenterManager"):OpenPersonalImageSetting()
		return
	end
	
	if AccountManager.role_lock_info then
		standReportEvent("7", "PERSONAL_INFO_HOMEPAGE", "AvatarLock", "click")
		print("have func role_lock_info:")
		local info = AccountManager:role_lock_info();
		print(info);

		if AccountManager:check_role_unlock() then
			--已上锁-->解锁
			ShowGameTips(GetS(20538), 3);
			AccountManager:role_unlock();

			--刷新模型到当前
			ZoneDetachPlayerCenterUIModel();
			PEC_ShowSkinModel();
		else
			if ZoneCheckAvatorPartAllForever() then
				print("all forever:");
				ShowGameTips(GetS(20544), 3);
				AccountManager:role_lock();
				local info = AccountManager:role_lock_info();
				-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterLockBtn");
				print("after lock:");
				print(info);
			else
				print("not all forever:");
				ShowGameTips(GetS(20542), 3);
			end
		end

		--刷新锁按钮图标状态
		ZoneSetLockIconState();
	end
end

function ZoneGetLockInfo()
	print("ZoneGetLockInfo:");
	local errcode = 0;
	local info = nil;

	if AccountManager.role_lock_info then
		if t_exhibition:isLookSelf() then
			info = AccountManager:role_lock_info();
			print("ZoneGetLockInfo self")
		else
			errcode, info = AccountManager:other_role_lock_info(t_exhibition.uin);
			print("ZoneGetLockInfo other")
		end

		if info then
			print("ZoneGetLockInfo", info)
		end
	end

	return errcode, info;
end


function ZoneGetLockInfoByUin(uin)
	print("ZoneGetLockInfo:");
	local errcode = 0
	local info = nil;

	if AccountManager.role_lock_info then
		if uin ==  AccountManager:getUin() then
			info = AccountManager:role_lock_info();
			print("ZoneGetLockInfo self")
		else
			errcode, info = AccountManager:other_role_lock_info(uin);
			print("ZoneGetLockInfo other")
		end
	end

	return errcode, info;
end

--设置玩家模型信息  1 角色  2 皮肤  3 avatar
function PlayerCenterSetBodyInfo(bodyType,bodyId)
	t_exhibition.curBodyInfo = {}
	t_exhibition.curBodyInfo.bodyType = bodyType
	t_exhibition.curBodyInfo.bodyId = bodyId
end

--获取玩家模型 临时C++引用，禁止本地持有
function PlayerCenterGetActorBody()
	local body = nil 
	if t_exhibition.curBodyInfo and t_exhibition.curBodyInfo.bodyType > 0 and t_exhibition.curBodyInfo.bodyId >= 0 then
		if t_exhibition.curBodyInfo.bodyType == 1 then 
			body = UIActorBodyManager:getRoleBody(t_exhibition.curBodyInfo.bodyId,false)
		elseif t_exhibition.curBodyInfo.bodyType == 2 then 
			body = UIActorBodyManager:getSkinBody(t_exhibition.curBodyInfo.bodyId,false)
		elseif t_exhibition.curBodyInfo.bodyType == 3 then 
			body = UIActorBodyManager:getAvatarBody(t_exhibition.curBodyInfo.bodyId,false)
		end 
	end 
	return body  
end

--设置玩家角色模型
function ZoneGetPlayer2Model(callBack)
	Log("ZoneGetPlayer2Model:");

	local info = nil;
	local errcode = 0;
	local player = nil;

	local myBool = true;
	if getglobal("HomeChestFrame"):IsShown() then
		myBool = false;
	else
		myBool = false;
	end

	local skinModel = 0;
	local model = 0;
	local seatInfo = nil;

	local showOldModel = function ()
		--是否上了锁
		errcode, info = ZoneGetLockInfo();
		if errcode == ErrorCode.OK and info then
			--上锁了
			print("have locked:");
			if info.RoleInfo then
				model = info.RoleInfo.Model;
				skinModel = info.RoleInfo.SkinID;

				print("model = " .. model);
				print("skinModel = " .. skinModel);
			end

			if info.seat then
				seatInfo = info.seat;
			end

			player = UIActorBodyManager:getRoleBody(model-1, myBool);
			PlayerCenterSetBodyInfo(1, model-1)
			if skinModel > 0 then
				print("have skinModel:");
				player = UIActorBodyManager:getSkinBody(skinModel, myBool);
				PlayerCenterSetBodyInfo(2, skinModel)
			end

			if seatInfo then
				print("seatInfo = ", seatInfo);
				player = PlayCenterGetAtModel(seatInfo);
				PlayerCenterSetBodyInfo(3, 97)
			end
		else
			--没上锁
			print("unlocked:");
			print("t_exhibition.isHost:", t_exhibition.isHost);
			if t_exhibition.isHost then 
				skinModel = AccountManager:getRoleSkinModel();
				model = AccountManager:getRoleModel();

				PlayerCenterSetBodyInfo(1,model-1)
				if skinModel > 0 then
					PlayerCenterSetBodyInfo(2,skinModel)
				end

				seatInfo = GetInst("ShopDataManager"):GetPlayerUsingSeatInfo()
				player = UIActorBodyManager:getRoleBody(model-1, myBool);
				if skinModel > 0 then
					player = UIActorBodyManager:getSkinBody(skinModel, myBool);
				end
					
				if seatInfo then
					print("seatInfo = ", seatInfo);
					PlayerCenterSetBodyInfo(3,99)
					Zone_SeatInfoGetAvatarBody(99, seatInfo);
					player = UIActorBodyManager:getAvatarBody(99, myBool);
					if seatInfo.scale then
						player:setScale(seatInfo.scale)
					end
				end
				-- return player;
			else
				--别人的avator装扮
				local code, info = AccountManager:avatar_other_seat_info(t_exhibition.uin, 0);
				if code == ErrorCode.OK and info then
					Log("ZoneGetPlayer2Model:888:");
					if t_exhibition:CheckProfileBlackStat(t_exhibition.uin) then 
						-- 审核状态默认显示裸模
						player = UIActorBodyManager:getAvatarBody(98, myBool); 
						PlayerCenterSetBodyInfo(3,98)
					else
						PlayerCenterSetBodyInfo(3,99)
						Zone_SeatInfoGetAvatarBody(99, info, t_exhibition.uin);
						player = UIActorBodyManager:getAvatarBody(99, myBool);
					end
					if info and info.scale then
						player:setScale(info.scale);
					end
				else
					Log("ZoneGetPlayer2Model:777:");
					local playerInfo = t_exhibition.getPlayerInfo();
					if playerInfo and playerInfo.SkinID and playerInfo.Model then 
						Log("ZoneGetPlayer2Model:SkinID = " ..playerInfo.SkinID.." model = " .. playerInfo.Model);
						local bolSkin
						player,bolSkin = GetPlayer2ModelByNum(playerInfo.Model, playerInfo.SkinID);		
						if playerInfo.SkinID and playerInfo.SkinID > 0 and bolSkin then 
							PlayerCenterSetBodyInfo(2,playerInfo.SkinID)
						else
							PlayerCenterSetBodyInfo(1,playerInfo.Model-1)
						end 
					else
						player = nil;
					end
				end
			end
		end
		if callBack then
			callBack(player)
		end
	end

	local showModelfuc = function(roleInfo)
		if roleInfo.Model > 0 then
			player = UIActorBodyManager:getRoleBody(roleInfo.Model-1);
			PlayerCenterSetBodyInfo(1, roleInfo.Model-1)
		end
		if roleInfo.SkinID and roleInfo.SkinID > 0 then
			player = UIActorBodyManager:getSkinBody(roleInfo.SkinID); 
			PlayerCenterSetBodyInfo(2, roleInfo.SkinID)
		end
		if roleInfo.AvatarSkin and roleInfo.HasAvatar and roleInfo.HasAvatar >= 1 then
			if roleInfo.AvatarSkin[1] and roleInfo.AvatarSkin[1].def then
				--新定制装扮的数据 按未上锁方式处理
				seatInfo = roleInfo.AvatarSkin[1].def
				PlayerCenterSetBodyInfo(3,99)
				Zone_SeatInfoGetAvatarBody(99, seatInfo);
				player = UIActorBodyManager:getAvatarBody(99, myBool);
				if seatInfo.scale then
					-- player:setScale(seatInfo.scale)
				end
			else
				--旧定制装扮的数据 按上锁方式处理
				local info = {skin = {}}
				info.skin = roleInfo.AvatarSkin
				player = PlayCenterGetAtModel(info);
				PlayerCenterSetBodyInfo(3, 97)
			end
		end
		if callBack and player then
			callBack(player, roleInfo)
		else
			showOldModel()
		end
	end

	--没上锁
	print("unlocked:");
	print("t_exhibition.isHost:", t_exhibition.isHost);
	if t_exhibition.isHost then 
		local roleInfo = GetInst("PlayerCenterManager"):GetPlayerCurInfo()
		if roleInfo and next(roleInfo) then
			showModelfuc(roleInfo) 
		else
			-- roleInfo不存在的话则获取一次并保存
			local callback = function(ret)
				if ret.code == 0 and ret.data then
					GetInst("PlayerCenterManager"):SetPlayerSkinInfo(ret.data)
					showModelfuc(ret.data) 
				else
					showOldModel()
				end
			end
			GetInst("PlayerCenterManager"):GetPersonCenterInfo(callback)
		end
	else
		local callback = function (ret) 
			if ret.code == 0 and ret.data then
				--形象存在设置形象
				local roleInfo = ret.data
				if roleInfo and roleInfo.HasAvatar and roleInfo.HasAvatar >= 1 then
					roleInfo.AvatarSkin = GetInst("PlayerCenterManager"):OrganizePlayerAvaterPartDefs(roleInfo.AvatarSkin)
				end
				showModelfuc(roleInfo)
			else
				showOldModel()
			end
		end
		GetInst("PlayerCenterManager"):GetPersonCenterInfo(callback,t_exhibition.uin)
	end
	
	return player;
end


function ZoneGetPlayer2ModelByUin(uin,callBack)
	local info = nil;
	local errcode = 0;
	local player1 = nil;

	local isSelf =false;
	if uin ==  AccountManager:getUin() then
		isSelf = true;
	end
	local myBool = false;
   local skinModel = 0;
	local model = 0;
	local seatInfo = nil;
	local showOldModel = function ()
		--是否上了锁
		local errcode, info = ZoneGetLockInfoByUin(uin);
		if errcode == ErrorCode.OK and info then
			--上锁了
			print("have locked:");
			if info.RoleInfo then
				model = info.RoleInfo.Model;
				skinModel = info.RoleInfo.SkinID;

				print("model = " .. model);
				print("skinModel = " .. skinModel);
			end

			if info.seat then
				seatInfo = info.seat;
			end

			player1 = UIActorBodyManager:getRoleBodyWithoutCache(model-1);
			if skinModel > 0 then
				print("have skinModel:");
				player1 = UIActorBodyManager:getSkinBodyWithoutCache(skinModel);
			end

			if seatInfo then
				print("seatInfo = ", seatInfo);
				player1 = PlayCenterGetAtModel(seatInfo);
			end
		else
			--没上锁
			if isSelf then 
				skinModel = AccountManager:getRoleSkinModel();
				model = AccountManager:getRoleModel();
				seatInfo = GetInst("ShopDataManager"):GetPlayerUsingSeatInfo()
				player1 = UIActorBodyManager:getRoleBodyWithoutCache(model-1);
				if skinModel > 0 then
					player1 = UIActorBodyManager:getSkinBodyWithoutCache(skinModel);
				end

				if seatInfo then
					Zone_SeatInfoGetAvatarBody(99, seatInfo);
					player1 = UIActorBodyManager:getAvatarBodyWithoutCache(99);
					if seatInfo.scale then
						player1:setScale(seatInfo.scale)
					end
				end
				-- return player;
			else
				--别人的avator装扮
				local code, info = AccountManager:avatar_other_seat_info(t_exhibition.uin, 0);
				if code == ErrorCode.OK and info then
					Log("ZoneGetPlayer2Model:888:");
					if t_exhibition:CheckProfileBlackStat(t_exhibition.uin) then 
						-- 审核状态默认显示裸模
						player1 = UIActorBodyManager:getAvatarBodyWithoutCache(98); 
					else
						Zone_SeatInfoGetAvatarBody(99, info, t_exhibition.uin);
						player1 = UIActorBodyManager:getAvatarBodyWithoutCache(99);
					end
					if info and info.scale then
						player1:setScale(info.scale);
					end
				else
					Log("ZoneGetPlayer2Model:777:");
					local playerInfo = t_exhibition.getPlayerInfo();
					if playerInfo and playerInfo.SkinID and playerInfo.Model then 
						Log("ZoneGetPlayer2Model:SkinID = " ..playerInfo.SkinID.." model = " .. playerInfo.Model);
						local bolSkin
						player1,bolSkin = GetPlayer2ModelByNum(playerInfo.Model, playerInfo.SkinID);		
					else
						player1 = nil;
					end
				end
			end
		end
		if callBack then
			callBack(player1)
		end
	end

	local showModelfuc = function(roleInfo)
		if roleInfo.Model > 0 then
			player1 = UIActorBodyManager:getRoleBodyWithoutCache(roleInfo.Model-1);
		end
		if roleInfo.SkinID and roleInfo.SkinID > 0 then
			player1 = UIActorBodyManager:getSkinBodyWithoutCache(roleInfo.SkinID); 
		end
		if roleInfo.AvatarSkin and roleInfo.HasAvatar and roleInfo.HasAvatar >= 1 then
			if roleInfo.AvatarSkin[1] and roleInfo.AvatarSkin[1].def then
				--新定制装扮的数据 按未上锁方式处理
				seatInfo = roleInfo.AvatarSkin[1].def
				Zone_SeatInfoGetAvatarBody(99, seatInfo);
				player1 = UIActorBodyManager:getAvatarBodyWithoutCache(99);
				if seatInfo.scale then
					player1:setScale(seatInfo.scale)
				end
			else
				--旧定制装扮的数据 按上锁方式处理
				local info = {skin = {}}
				info.skin = roleInfo.AvatarSkin
				player1 = PlayCenterGetAtModel(info);
			end
		end
		if callBack and player1 then
			callBack(player1, roleInfo)
		else
			showOldModel()
		end
	end

	
	local  callback = function (ret) 
		if ret.code == 0 and ret.data then
			--形象存在设置形象
			local roleInfo = ret.data
			if isSelf then
				GetInst("PlayerCenterManager"):SetPlayerSkinInfo(ret.data)
			else
				if roleInfo and roleInfo.HasAvatar and roleInfo.HasAvatar >= 1 then
					roleInfo.AvatarSkin = GetInst("PlayerCenterManager"):OrganizePlayerAvaterPartDefs(roleInfo.AvatarSkin)
				end
			end
			showModelfuc(roleInfo)
		else
			showOldModel()
		end
	end
	if isSelf then 
		GetInst("PlayerCenterManager"):GetPersonCenterInfo(callback)
	else
		GetInst("PlayerCenterManager"):GetPersonCenterInfo(callback,uin)
	end
end

function BestPartZoneGetPlayer2ModelByUin(uin,callBack)
	local info = nil;
	local errcode = 0;
	local player1 = nil;

	local isSelf =false;
	if uin ==  AccountManager:getUin() then
		isSelf = true;
	end
	local myBool = false;
   local skinModel = 0;
	local model = 0;
	local seatInfo = nil;
	local showOldModel = function ()
		--是否上了锁
		local errcode, info = ZoneGetLockInfoByUin(uin);
		if errcode == ErrorCode.OK and info then
			--上锁了
			print("have locked:");
			if info.RoleInfo then
				model = info.RoleInfo.Model;
				skinModel = info.RoleInfo.SkinID;

				print("model = " .. model);
				print("skinModel = " .. skinModel);
			end

			if info.seat then
				seatInfo = info.seat;
			end

			player1 = UIActorBodyManager:getRoleBodyWithoutCache(model-1);
			if skinModel > 0 then
				print("have skinModel:");
				player1 = UIActorBodyManager:getSkinBodyWithoutCache(skinModel);
			end

			if seatInfo then
				print("seatInfo = ", seatInfo);
				player1 = PlayCenterGetAtModel(seatInfo);
			end
		else
			--没上锁
			if isSelf then 
				skinModel = AccountManager:getRoleSkinModel();
				model = AccountManager:getRoleModel();
				seatInfo = GetInst("ShopDataManager"):GetPlayerUsingSeatInfo()
				player1 = UIActorBodyManager:getRoleBodyWithoutCache(model-1);
				if skinModel > 0 then
					player1 = UIActorBodyManager:getSkinBodyWithoutCache(skinModel);
				end

				if seatInfo then
					player1 = Zone_SeatInfoGetAvatarBody(100, seatInfo);
					if seatInfo.scale then
						player1:setScale(seatInfo.scale)
					end
				end
				-- return player;
			else
				--别人的avator装扮
				local code, info = AccountManager:avatar_other_seat_info(t_exhibition.uin, 0);
				if code == ErrorCode.OK and info then
					Log("ZoneGetPlayer2Model:888:");
					if t_exhibition:CheckProfileBlackStat(t_exhibition.uin) then 
						-- 审核状态默认显示裸模
						player1 = UIActorBodyManager:getAvatarBodyWithoutCache(98); 
					else
						player1 =Zone_SeatInfoGetAvatarBody(100, info, t_exhibition.uin);
					end
					if info and info.scale then
						player1:setScale(info.scale);
					end
				else
					Log("ZoneGetPlayer2Model:777:");
					local playerInfo = t_exhibition.getPlayerInfo();
					if playerInfo and playerInfo.SkinID and playerInfo.Model then 
						Log("ZoneGetPlayer2Model:SkinID = " ..playerInfo.SkinID.." model = " .. playerInfo.Model);
						local bolSkin
						player1,bolSkin = GetPlayer2ModelByNum(playerInfo.Model, playerInfo.SkinID);		
					else
						player1 = nil;
					end
				end
			end
		end
		if callBack then
			callBack(player1)
		end
	end

	local showModelfuc = function(roleInfo)
		if roleInfo.Model > 0 then
			player1 = UIActorBodyManager:getRoleBodyWithoutCache(roleInfo.Model-1);
		end
		if roleInfo.SkinID and roleInfo.SkinID > 0 then
			player1 = UIActorBodyManager:getSkinBodyWithoutCache(roleInfo.SkinID); 
		end
		if roleInfo.AvatarSkin and roleInfo.HasAvatar and roleInfo.HasAvatar >= 1 then
			if roleInfo.AvatarSkin[1] and roleInfo.AvatarSkin[1].def then
				--新定制装扮的数据 按未上锁方式处理
				seatInfo = roleInfo.AvatarSkin[1].def
				
				--player1 = UIActorBodyManager:getAvatarBodyWithoutCache(100);
				player1 = Zone_SeatInfoGetAvatarBody(100, seatInfo);
				if seatInfo.scale then
					player1:setScale(seatInfo.scale)
				end
			else
				--旧定制装扮的数据 按上锁方式处理
				local info = {skin = {}}
				info.skin = roleInfo.AvatarSkin
				player1 = PlayCenterGetAtModel(info);
			end
		end
		if callBack and player1 then
			callBack(player1, roleInfo)
		else
			showOldModel()
		end
	end

	
	local  callback = function (ret) 
		if ret.code == 0 and ret.data then
			--形象存在设置形象
			local roleInfo = ret.data
			if isSelf then
				GetInst("PlayerCenterManager"):SetPlayerSkinInfo(ret.data)
			else
				if roleInfo and roleInfo.HasAvatar and roleInfo.HasAvatar >= 1 then
					roleInfo.AvatarSkin = GetInst("PlayerCenterManager"):OrganizePlayerAvaterPartDefs(roleInfo.AvatarSkin)
				end
			end
			showModelfuc(roleInfo)
		else
			showOldModel()
		end
	end
	if isSelf then 
		GetInst("PlayerCenterManager"):GetPersonCenterInfo(callback)
	else
		GetInst("PlayerCenterManager"):GetPersonCenterInfo(callback,uin)
	end
end



--avator(SeatInfoSetAvatarBody)
function Zone_SeatInfoGetAvatarBody(seatID, seatInfo, uin)
	print("Zone_SeatInfoGetAvatarBody1", seatID, uin, seatInfo)
	if not seatID or seatID < 0 then
		return
	end
	
	if not uin then
		uin = AccountManager:getUin();
	end

	local seatModel = UIActorBodyManager:getAvatarBody(seatID,false);
	seatModel:addAnimModel(3);
	SeatInfoSetCustomBody(seatID, seatInfo, uin)
	seatModel = UIActorBodyManager:getAvatarBody(seatID,false);
	
	return seatModel;
end

--解锁模型
function ZoneDetachPlayerCenterUIModel()
	print("ZoneDetachPlayerCenterUIModel:");
	local player = PlayerCenterGetActorBody();
	local roleview = getglobal(t_exhibition:getModelViewUiName())
	if player and player.getPlayerIndex and player:getPlayerIndex() > 0 then
		local skinModel = player:getSkinID()
		if skinModel == 74 or skinModel == 75 or skinModel == 76 then
			local body = roleview:getActorBody();
			if body then
				if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
					roleview:detachActorBody(body)
				else
					body:detachUIModelView(roleview);
				end
			end
		else
			if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
				roleview:detachActorBody(player)
			else
				player:detachUIModelView(roleview);
			end
		end
	elseif player then
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			roleview:detachActorBody(player)
		else
			player:detachUIModelView(roleview);
		end
	else 
		return;
	end
	local seatID = AccountManager:avatar_seat_current();
	UIActorBodyManager:releaseAvatarBody(99);

	local horseView = getglobal("PlayerExhibitionCenterModeViewMountsView")
	if horseView then
		local body = horseView:getActorbody(1);
		if body then
			if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
				horseView:detachActorBody(body,1)
			else
				body:detachUIModelView(horseView,1)
			end
		end
	end
end


--avator部件是否全部永久
function ZoneCheckAvatorPartAllForever()
	print("ZoneCheckAvatorPartAllForever:");

	local seatInfo = GetInst("ShopDataManager"):GetPlayerUsingSeatInfo()
	if seatInfo then
		--是avator
		print("is avator:");

		if seatInfo and seatInfo.skin then
			print(seatInfo);
			for k, v in pairs(seatInfo.skin) do
				if v and v.skin then
					print("ZoneCheckAvatorPartAllForever:v:");
					print(v);
					if v.skin.ExpireTime then
						--永久
						if v.skin.ExpireTime == -1 then
							print("ZoneCheckAvatorPartAllForever:111");
						else
							print("ZoneCheckAvatorPartAllForever:222");
							return false;
						end
					else
						--永久????(没有ExpireTime这个字段是永久?)
						print("ZoneCheckAvatorPartAllForever:333");
					end					
				end
			end

			print("ZoneCheckAvatorPartAllForever:444");
			return true;
		end

		print("ZoneCheckAvatorPartAllForever:555");
		return false;
	else
		--不是avator
		print("not avator:");
		local skinModel = AccountManager:getRoleSkinModel();
		local model = AccountManager:getRoleModel();

		if skinModel and skinModel > 0 then
			--皮肤
			local time = AccountManager:getAccountData():getSkinTime(skinModel);
			print("time = " .. time);

			if time < 0 then
				return true;
			else
				return false;
			end
		else
			--角色
			return true;
		end
	end
end

--当前展示的是否是avator模型, avator模型可以播放表情
function ZoneIsCurModeIsAvator(roleInfo)
	print("ZoneIsCurModeIsAvator:");
	local errcode = 0;
	local info = nil;
	if roleInfo and roleInfo.HasAvatar then
		if roleInfo.HasAvatar >= 1 then
			return true;
		else
			return false;
		end
	end

	errcode, info = ZoneGetLockInfo();

	if errcode == ErrorCode.OK and info then
		--上锁了
		print("ZoneIsCurModeIsAvator:111");
		if info.seat then
			seatInfo = info.seat;
			--是avator
			print("ZoneIsCurModeIsAvator:222");
			return true;
		end
	else
		--没上锁
		print("ZoneIsCurModeIsAvator:333");
		if t_exhibition:isLookSelf() then
			local seatInfo = GetInst("ShopDataManager"):GetPlayerUsingSeatInfo()

			if seatInfo then
				print("ZoneIsCurModeIsAvator:444");
				return true;
			end
		else
			print("ZoneIsCurModeIsAvator:666");
			local code, info = AccountManager:avatar_other_seat_info(t_exhibition.uin, 0);
			if code == ErrorCode.OK and info then
				return true;
			else
				return false;
			end
		end
	end

	print("ZoneIsCurModeIsAvator:555");
	return false;
end

function GetZoneDynamicMgrParam ()
	return m_ZoneDynamicMgrParam;
end


--动态举报
function FriendDynamicFrameReportBtn_OnClick()
	InformControl:ClearAllInformInfo();
	local text = GetS(10517).."#c1ec832"..GetS(10557).."#n";

	local op_uin;
	local pid;

	if string.find(this:GetParentFrame():GetName(),"FriendDynamicFrame") ~= nil then
		pid = m_ZoneDynamicMgrParam:GetPid()
	elseif string.find(this:GetParentFrame():GetName(),"ExhibitionInfoPage") ~= nil then
		local id = this:GetParentFrame():GetClientID();
		pid = m_ZoneDynamicMgrParam:GetPid(id)
	end

	if pid then
		op_uin = m_ZoneDynamicMgrParam:ParseUinByPid(pid)
	else
		return
	end

	if op_uin == nil then return end

	-- print("FriendDynamicFrameReportBtn_OnClick m_ZoneDynamicMgrParam.curDynamicDetail = ", m_ZoneDynamicMgrParam.curDynamicDetail)
	if m_ZoneDynamicMgrParam.curDynamicDetail and m_ZoneDynamicMgrParam.curDynamicDetail.black_stat then
		local black_stat = m_ZoneDynamicMgrParam.curDynamicDetail.black_stat;
		if black_stat == 1 or black_stat == 2 then 
			ShowGameTipsWithoutFilter(GetS(10574));
			return
		end
	end

	-- InformControl:AddInformInfo(107,op_uin,nil,nil,text):SetPid(pid):Enqueue();

	GetInst("ReportManager"):OpenReportView({
		tid = GetInst("ReportManager"):GetTidTypeTbl().player_dynamic,
		op_uin = op_uin,
		pid = pid
	})
end

--评论点击
function FriendDynamicFrameReplyBoxItem_OnClick()
	local id = this:GetClientID();

	local pid,op_uin,op_create_time,list = m_ZoneDynamicMgrParam:GetReportCommentInfo(id);
	local myUin = AccountManager:getUin();
    local isMyReply = false;
	if myUin == tonumber(op_uin) and myUin ~= list.pid_uin then
		return;
	elseif myUin == tonumber(op_uin) then
		--自己的评论不能回复、举报、黑名单，只能删除
		isMyReply = true;
	end
	
	local black_stat = m_ZoneDynamicMgrParam:CheckReportCommentState(id);
	if black_stat == 1 or black_stat == 2 then
		ShowGameTipsWithoutFilter(GetS(10573), 3);
		return;
	end

	local frame_func = getglobal("FriendDynamicFrameCommentFunc");
	local btn_ReplyBtn = getglobal("FriendDynamicFrameCommentFuncReplyBtn");
	local btn_ReportBtn = getglobal("FriendDynamicFrameCommentFuncReportBtn");
	local btn_BlacklistBtn = getglobal("FriendDynamicFrameCommentFuncBlacklistBtn");
	local btn_DeleteBtn = getglobal("FriendDynamicFrameCommentFuncDeleteBtn");
	if list.pid_uin == myUin and not isMyReply then
		btn_ReplyBtn:Show();
		btn_ReportBtn:Show();
		btn_BlacklistBtn:Show();
		btn_DeleteBtn:Show();
		frame_func:SetHeight(253);
		frame_func:SetPoint("center", this:GetName(), "center", 0, -85);
		btn_DeleteBtn:SetPoint("top", "FriendDynamicFrameCommentFuncReplyBtn", "bottom", 0, 9);
	elseif isMyReply then
		btn_ReplyBtn:Hide();
		btn_ReportBtn:Hide();
		btn_BlacklistBtn:Hide();
		btn_DeleteBtn:Show();
		frame_func:SetHeight(76);
		frame_func:SetPoint("center", this:GetName(), "center", 0, 0);
		btn_DeleteBtn:SetPoint("center", "FriendDynamicFrameCommentFunc", "center", 0, 0);
	else
		btn_ReplyBtn:Show();
		btn_ReportBtn:Show();
		btn_BlacklistBtn:Hide();
		btn_DeleteBtn:Hide();
		frame_func:SetHeight(139);
		frame_func:SetPoint("center", this:GetName(), "center", 0, -35);
	end

	TemplateZoneListItem_OnClick();
	if frame_func:IsShown() then
		frame_func:Hide();
	else
		frame_func:Show();
		btn_ReplyBtn:SetClientID(id);
		btn_ReportBtn:SetClientID(id);
		btn_BlacklistBtn:SetClientID(id);
		btn_DeleteBtn:SetClientID(id);
	end
end

--评论举报
function FriendDynamicFrameReplyReportBtn_OnClick()
	getglobal("FriendDynamicFrameCommentFunc"):Hide();
	local id = this:GetClientID();
	local pid,op_uin,op_create_time = m_ZoneDynamicMgrParam:GetReportCommentInfo(id);

	if pid and op_uin and op_create_time then
		-- local text = GetS(10517).."#c1ec832"..GetS(10558).."#n";
		-- InformControl:AddInformInfo(108,op_uin,nil,nil,text)
		-- 	:SetPid(pid)
		-- 	:SetOpCreateTime(op_create_time)
		-- 	:Enqueue();

		GetInst("ReportManager"):OpenReportView({
			tid = GetInst("ReportManager"):GetTidTypeTbl().player_dynamic_comment,
			op_uin = op_uin,
			pid = pid,
			op_create_time = op_create_time
		})
	end
end
--删除评论
function FriendDynamicFrameCommentFuncDeleteBtn_OnClick()
	local id = getglobal("FriendDynamicFrameCommentFuncDeleteBtn"):GetClientID();
	local AlertFrame = getglobal("FriendDynamicFrameAlertFrame");
	local AlertFrameOkBtn = getglobal("FriendDynamicFrameAlertFrameOkBtn");
	AlertFrameOkBtn:SetClientID(id);
	AlertFrame:SetClientID(id);
	AlertFrame:Show();
	this:GetParentFrame():Hide();
end
--黑名单
function FriendDynamicFrameCommentFuncBlacklistBtn_OnClick()
	local id = getglobal("FriendDynamicFrameCommentFuncBlacklistBtn"):GetClientID();
	getglobal("FriendDynamicFrameAlertFrameOkBtn"):SetClientID(id);
	local _,op_uin,_,_,role_info_list = m_ZoneDynamicMgrParam:GetReportCommentInfo(id);
	if IncludeBlacklistByUin(op_uin) then
		ShowGameTips(GetS(21842));
		return;
	end

	local role_info = m_ZoneDynamicMgrParam:GetRoleInfoByUin(role_info_list,op_uin)
	local text =  GetS(21837,role_info.NickName,op_uin);
	MessageBox(31, text, function(btn,param)
		if btn == 'right' then
			if param then
				ReqAddBlacklist(param);
				FriendDynamicFrameCommentFuncDeleteBtn_OnClick();
			end
		end
	end,op_uin);
	this:GetParentFrame():Hide();
end

-------------------------------------FriendDynamicFrameAlertFrame--------------------------------------------------------
function FriendDynamicFrameAlertFrame_OnShow()
	local tickBtn = getglobal("FriendDynamicFrameAlertFrameTickBtn");
	local tickIcon = getglobal("FriendDynamicFrameAlertFrameTickBtnTick");
	local AlertFrameDesc = getglobal("FriendDynamicFrameAlertFrameDesc");
	local id = this:GetClientID();
	--打钩按钮重置
	tickBtn:SetClientID(0);
	if tickIcon:IsShown() then
		tickIcon:Hide();
	end

	local pid,op_uin,op_create_time,list,role_info_list = m_ZoneDynamicMgrParam:GetReportCommentInfo(id);
	local role_info = m_ZoneDynamicMgrParam:GetRoleInfoByUin(role_info_list,op_uin)
	local text = unescape(list.content)
	if not m_ZoneDynamicMgrParam:IsUinInWhiteList({[1] = list}, 1) then
		local curtext = m_ZoneDynamicMgrParam:SensitiveWordsShieldTxtOrPic(nil,text);
		if curtext ~= "" then text = curtext; end
	end
	local len = string.len(text);
	if len > 80 then
		text = string.sub(text, 1, 50).."...";
	end
	AlertFrameDesc:SetText("#c4D9BAD"..role_info.NickName .. ":#n\n" .. text);
end
function FriendDynamicFrameAlertFrameOkBtn_OnClick()
	local id = this:GetClientID();
	local type = getglobal("FriendDynamicFrameAlertFrameTickBtn"):GetClientID();
	m_ZoneDynamicMgrParam:DeleteComment(id,type);
	this:GetParentFrame():Hide();
end

function FriendDynamicFrameAlertFrameClose_OnClick()
	getglobal("FriendDynamicFrameAlertFrame"):Hide();
end

function FriendDynamicFrameAlertFrameTickBtn_OnClick()
	local tickBtn = getglobal("FriendDynamicFrameAlertFrameTickBtnTick");
	if tickBtn:IsShown() then
		tickBtn:Hide();
		this:SetClientID(0);
	else
		local id = this:GetParentFrame():GetClientID();
		local _,op_uin,_,_,role_info_list = m_ZoneDynamicMgrParam:GetReportCommentInfo(id);
		local role_info = m_ZoneDynamicMgrParam:GetRoleInfoByUin(role_info_list,op_uin)
		local text =  GetS(21836,role_info.NickName,op_uin);
		MessageBox(31, text, function(btn,param)
			if btn == 'right' then
				param.tickBtn:Show();
				param.thisFrame:SetClientID(1);
			end
		end,{tickBtn = tickBtn, thisFrame = this});
	end
end
----------------------------------------------end--------------------------------------------------------



----------------------------------------------新版个人中心模型显示区--------------------------------------------------------
t_ExhibitionModelView = {
	-- 是否需要展示
	uiName = "PlayerExhibitionCenterModelFrame",
	isOpenStatus = false,
	-- 自己展示位所有数据
	allMyPosShowDatas = {},
	-- 其他玩家临时展示位所有数据（只展示已经有的形象）
	allOtherPosShowDatas = {},
	-- showType
	showType = {
		unlock = -1,	-- 未解锁
		default = 0,   -- 已经解锁
		dress = 1,	   -- 装扮 skin
		awatar = 2,	   -- awatar
		model = 3	   -- 角色
	},

	actorViewCfgs = 
	{
		cameraWidthFov = 30,
		cameraLookAt = {0,220,-1200,0,128,0},
		actorPosition = {0,-35,-320},
		actorScale1 = 1.5,
		actorScale2 = 1.0,
	},
}

-- 初始化
function t_ExhibitionModelView:Init(uin)
	self.uin = uin or AccountManager:getUin()
	self.isMy = self.uin == AccountManager:getUin()
	self.isOpenStatus = true
	self.circleChildNum = 0
	self.InitModelViewAngle = 0
	self.maxPosShowNum = 9
	self.buyNeedNum = 100  -- 默认[Desc5]迷你豆数量
	self.isMovingFlag = false
	if ns_version.profile_revision then 
		if ns_version.profile_revision.max_show_num  then
			self.maxPosShowNum = ns_version.profile_revision.max_show_num 
			if self.maxPosShowNum < 1 then
				self.maxPosShowNum = 1  -- 最少也有一个默认位
			end
		end

		if ns_version.profile_revision.purchase_show_coin then
			self.buyNeedNum = ns_version.profile_revision.purchase_show_coin
		end
	end
	
	self:InitView()
	
	-- 当前展示位数据  自己的数据只请求一次， 其他玩家每次都清空
	if not self.isMy then
		self.allOtherPosShowDatas = {}
	end
	
	self:SetCurPosShowIndex(1)
	self:ReqPosShowDatas(true)
end

function t_ExhibitionModelView:InitView()
	self.mainView = getglobal(self.uiName)
	self.circleContainer = getglobal(self.uiName.."CircleContainer")
	self.actorView = getglobal(t_exhibition:getModelViewUiName()) -- 模型
	local ModeBase = getglobal(self.uiName.."ModeViewModeBase")
	self.actorView:SetPoint("bottom", ModeBase:GetParentFrame():GetName(), "bottom", 0, 0)
	ModeBase:SetPoint("bottom", ModeBase:GetParentFrame():GetName(), "bottom", 0, 0)
	
	local AddShowBtIcon = getglobal(self.uiName.."AddShowBtIcon")
	AddShowBtIcon:SetTexUV("icon_add_white")

	local UnLockShowBt = getglobal(self.mainView:GetName().."UnLockShowBt")
	local UnLockShowBtTip = getglobal(UnLockShowBt:GetName().."Tip")
	UnLockShowBtTip:SetText(GetS(110096))

	self.mainView:Show()
end

function t_ExhibitionModelView:GetUiName()
	return self.uiName
end

function t_ExhibitionModelView:GetOpenStatus()
	return self.isOpenStatus
end

function t_ExhibitionModelView:GetAllPosShowDatas()
	if not self.isMy then
		return self.allOtherPosShowDatas
	end
	return self.allMyPosShowDatas
end

function t_ExhibitionModelView:GetAllPosShowNum()
	if not self.isMy then
		return #self.allOtherPosShowDatas
	end
	return #self.allMyPosShowDatas
end

function t_ExhibitionModelView:GetCurPosShowData()
	if not self.isMy then
		return self.allOtherPosShowDatas[self.curPosShowIndex]
	end
	return self.allMyPosShowDatas[self.curPosShowIndex]
end

function t_ExhibitionModelView:SetCurPosShowIndex(index)
	index = index or 1
	self.curPosShowIndex = index
end

function t_ExhibitionModelView:GetCurPosShowIndex()
	return self.curPosShowIndex
end

-- 外部接口刷新 只提供修改展示位后刷新
function t_ExhibitionModelView:Refresh()
	if self.uin == AccountManager:getUin() then
		self:ReqPosShowDatas(false)
	end
end

function t_ExhibitionModelView:UpdateShowPosView()
	self:UpdateElementsView()
	self:UpdateModelView()
	self:SetNameDesc()
	self:RefreshCircleContainer()
end

-- 刷新圆圈布局
function t_ExhibitionModelView:RefreshCircleContainer()
	local totalNum = self:GetAllPosShowNum()
	if totalNum > 1 then
		self.circleContainer:Show()
	else
		self.circleContainer:Hide()
		-- 没必要再去刷新
		return 
	end

	local curIndx = self:GetCurPosShowIndex()
	local parentName = self.circleContainer:GetName()
	local childNamePre = parentName.."Item"
	self.circleChildNum = math.max(self.circleChildNum, totalNum)
	local intervalH = 11
	if totalNum > 0 then
		self.circleContainer:SetWidth(totalNum * 12 + (totalNum - 1) * intervalH)
	end

	local posStarx = 0
	local item = nil
	local itemIcon = nil
	local childName = ""
	for index = 1, self.maxPosShowNum do
		childName = childNamePre..index
		item = getglobal(childName)
		if not item then
			item = UIFrameMgr:CreateFrameByTemplate("Frame", childName, "NewPlayerCenterModelViewCircleTemplate", parentName)
		end

		if index <= totalNum then
			item:Show()
			item:SetPoint("left", parentName, "left", posStarx, 0)
			itemIcon = getglobal(childName.."Icon")
			if index == curIndx then
				itemIcon:SetTexUV("img_label_page_yellow")
			else
				itemIcon:SetTexUV("img_label_page")
			end

			posStarx = posStarx + intervalH + item:GetWidth()
		else
			item:Hide()
		end
	end
end

function t_ExhibitionModelView:UpdateElementsView()
	local UnLockShowBt = getglobal(self.mainView:GetName().."UnLockShowBt")
	local AddShowBt = getglobal(self.mainView:GetName().."AddShowBt")
	local DelModelBt = getglobal(self.mainView:GetName().."DelModelBt")
	local PreBt = getglobal(self.mainView:GetName().."PreBt")
	local NextBtn = getglobal(self.mainView:GetName().."NextBtn")

	-- 解锁、添加形象
	local showPosCfgs = self:GetCurPosShowData()
	local curShowIndex = self:GetCurPosShowIndex()
	if showPosCfgs and showPosCfgs.type then
		if showPosCfgs.type <= self.showType.unlock then
			-- 加锁
			UnLockShowBt:Show()
			AddShowBt:Hide()
			DelModelBt:Hide()
		elseif showPosCfgs.type == self.showType.default then
			--  空位
			UnLockShowBt:Hide()
			AddShowBt:Show()
			DelModelBt:Hide()
		else
			-- 第一个展示位不可删除
			if curShowIndex == 1 then
				DelModelBt:Hide()
			else
				DelModelBt:Show()
			end
			AddShowBt:Hide()
			UnLockShowBt:Hide()
		end
	else
		-- 没有数据
		DelModelBt:Hide()
		AddShowBt:Hide()
		UnLockShowBt:Hide()
	end
end

function t_ExhibitionModelView:SetNameDesc()
	if not self.mainView then return end

	local showPosCfgs = self:GetCurPosShowData()
	local skinName = ""
	if showPosCfgs and showPosCfgs.type and showPosCfgs.type > self.showType.default then
		if showPosCfgs.type == self.showType.dress then
			skinName = DefMgr:getRoleSkinDef(showPosCfgs.infoid).Name or ""
		elseif showPosCfgs.type == self.showType.model then
			skinName = DefMgr:getRoleDef(showPosCfgs.infoid, 0).Name or ""
		elseif type(showPosCfgs.infoid) == "table" and showPosCfgs.infoid.name then
			-- awatar
			skinName = showPosCfgs.infoid.name
		end
	end

	local name = getglobal(self.mainView:GetName().."Name")
	if name then
		name:SetText(skinName)
	end
end

-- 展示模型
function t_ExhibitionModelView:UpdateModelView()
	if not self.actorView then return end
	--解绑角色
	local actor = self.actorView:getActorbody()
	if actor then 
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			self.actorView:detachActorBody(actor)
		else
			actor:detachUIModelView(self.actorView)
		end
	end 

	local showPosCfgs = self:GetCurPosShowData()
	local scale = self.actorViewCfgs.actorScale1
	local actor = nil
	if showPosCfgs and showPosCfgs.type and showPosCfgs.type > self.showType.default and showPosCfgs.infoid then
		self.actorView:Show()
		--设置角色视图
		self.actorView:setCameraWidthFov(self.actorViewCfgs.cameraWidthFov)
		self.actorView:setCameraLookAt(self.actorViewCfgs.cameraLookAt[1],self.actorViewCfgs.cameraLookAt[2],self.actorViewCfgs.cameraLookAt[3],
		self.actorViewCfgs.cameraLookAt[4],self.actorViewCfgs.cameraLookAt[5],self.actorViewCfgs.cameraLookAt[6])
		self.actorView:setActorPosition(self.actorViewCfgs.actorPosition[1],self.actorViewCfgs.actorPosition[2],self.actorViewCfgs.actorPosition[3])
		if type(showPosCfgs.infoid) == "number"  then
			if showPosCfgs.type == self.showType.dress then
				actor = UIActorBodyManager:getSkinBodyWithoutCache(showPosCfgs.infoid)
				--设置角色  无缓存， 迷你秀里面有一个， 会有冲突
				local skinDef = DefMgr:getRoleSkinDef(showPosCfgs.infoid)
				if skinDef.WindowScale and skinDef.WindowScale > 0 then
					scale = self.actorViewCfgs.actorScale2
				end
			else
				actor = UIActorBodyManager:getRoleBodyWithoutCache(showPosCfgs.infoid - 1)
			end
		else
			actor = UIActorBodyManager:getAvatarBody(98,false)
			-- 清理角色部件
			GetInst("AvatarBodyManager"):DelSkinPart({isAll = true, body = actor, isUse = false})

			if (showPosCfgs.type == self.showType.awatar) and type(showPosCfgs.infoid) == "table" then
				-- 使用角色部件
				GetInst("AvatarBodyManager"):AddSkinPart({
					actorView = self.actorView,
					id = showPosCfgs.infoid,
					body = actor,
					isAsyn = true,
					asynInterval = 0.1,
					isUse = true})
			end
		end

		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			self.actorView:attachActorBody(actor, 0, false)
		else
			actor:attachUIModelView(self.actorView,0,false)
		end
		actor:setScale(scale)
	else
		self.actorView:Hide()
	end
end

function t_ExhibitionModelView:GetPosShowDefaultData()
	return  {
		type = self.showType.unlock,
		infoid = 0,
	}
end

-- { type=0, infoid=0 }
-- 如果type为1时，则填的是skinid
-- 如果type为2时，则填avatar存放的扎位 
function t_ExhibitionModelView:ReqPosShowDatas(bChangeIndex)
	local allPosShowDatas = {}
	self:ReqPlayerDefaultPos(allPosShowDatas)
	local code = ErrorCode.OK
	local ret = nil
	if self.isMy then
		ret = AccountManager:query_personal_show_list()
	else
		code, ret = AccountManager:other_query_personal_show_list(self.uin)
	end
	print("ReqPosShowDatas code", code)
	print("ReqPosShowDatas ret", ret)
	local singleData = self:GetPosShowDefaultData()
	if code == ErrorCode.OK and type(ret) == "table" then
		for index = 1, #ret do
			singleData = self:GetPosShowDefaultData()
			singleData.type = ret[index].type
			singleData.infoid = ret[index].infoid
			allPosShowDatas[#allPosShowDatas + 1] = singleData
		end
	end

	if self.isMy then
		self.allMyPosShowDatas = allPosShowDatas
	else
		self.allOtherPosShowDatas = allPosShowDatas
	end

	print("pre allPosShowDatas ", allPosShowDatas)
	self:CheckRespData()

	bChangeIndex = bChangeIndex or false
	if bChangeIndex then
		self:CheckSelectIndex(false)
	end
	self:UpdateShowPosView()
end

-- 获取玩家默认展示位置  第一位
-- 自己 直接走 role_lock_info   errcode默认ErrorCode.OK
-- 别人 走 other_role_lock_info  根据errcode 走分支
function t_ExhibitionModelView:ReqPlayerDefaultPos(outDatas)
	--是否上了锁
	local defalutData = self:GetPosShowDefaultData()
	local errcode, info = ZoneGetLockInfo()

	local skinModel = 0
	local model = 0
	local seatInfo = nil

	if errcode == ErrorCode.OK and info then
		if info.seat then
			defalutData.type = self.showType.awatar
			defalutData.infoid = info.seat -- table
		elseif info.RoleInfo then
			model = info.RoleInfo.Model
			skinModel = info.RoleInfo.SkinID

			defalutData.type = self.showType.model
			defalutData.infoid = model
			if skinModel > 0 then
				defalutData.type = self.showType.dress
				defalutData.infoid = skinModel
			end
		end
	else
		if self.isMy then 
			skinModel = AccountManager:getRoleSkinModel()
			model = AccountManager:getRoleModel()
			seatInfo = GetInst("ShopDataManager"):GetPlayerUsingSeatInfo()
			if seatInfo then
				defalutData.type = self.showType.awatar
				defalutData.infoid = seatInfo -- table
			else	
				defalutData.type = self.showType.model
				defalutData.infoid = model
				if skinModel > 0 then
					defalutData.type = self.showType.dress
					defalutData.infoid = skinModel
				end
			end
		else
			--别人的avator装扮
			local code, info = AccountManager:avatar_other_seat_info(self.uin, 0)
			if code == ErrorCode.OK and info then
				if t_exhibition:CheckProfileBlackStat(self.uin) then 
					-- 审核状态默认显示裸模
					defalutData.type = self.showType.awatar
					defalutData.infoid = info  -- 98
				else
					defalutData.type = self.showType.awatar
					defalutData.infoid = info  -- 99
				end
			else
				local playerInfo = t_exhibition.getPlayerInfo();
				if playerInfo and playerInfo.SkinID and playerInfo.Model then
					model = playerInfo.Model
					skinModel = playerInfo.SkinID

					defalutData.type = self.showType.model
					defalutData.infoid = model
					if skinModel > 0 then
						defalutData.type = self.showType.dress
						defalutData.infoid = skinModel
					end
				end
			end
		end
	end

	outDatas[#outDatas + 1] = defalutData
end

function t_ExhibitionModelView:CheckRespData()
	if self.isMy then
		local totalPosShowNum = self:GetAllPosShowNum()
		if totalPosShowNum > self.maxPosShowNum then
			-- 减去多余
			for index = self.maxPosShowNum + 1, totalPosShowNum do
				self.allMyPosShowDatas[index] = nil
			end
		elseif (totalPosShowNum > 0 and totalPosShowNum < self.maxPosShowNum) 
			and self.allMyPosShowDatas[totalPosShowNum].type ~= self.showType.unlock  then
			-- 如果最后一个是非加锁状态 添加加锁位
			local defaultData = self:GetPosShowDefaultData()
			self.allMyPosShowDatas[#self.allMyPosShowDatas + 1] = defaultData
		end
	else
		-- 其他玩家只显示已有的形象
		local tempDatas = {}
		for index = 1, #self.allOtherPosShowDatas do
			if self.allOtherPosShowDatas[index].type > self.showType.default  then
				tempDatas[#tempDatas + 1] = self.allOtherPosShowDatas[index]
			end
		end
		self.allOtherPosShowDatas = tempDatas
	end
end

function t_ExhibitionModelView:CheckSelectIndex(bDel)
	bDel = bDel or false
	local checkIndex = self:GetCurPosShowIndex()
	if bDel then
		checkIndex = checkIndex - 1
		if checkIndex < 1 then
			checkIndex = 1
		end
	else
		local allDatas = self:GetAllPosShowDatas()
		for index = 2, #allDatas do
			if allDatas[index].type > self.showType.default then
				checkIndex = index
				break
			end
		end
	end

	self:SetCurPosShowIndex(checkIndex)
end

-- 解锁添加展示位  1 添加 2 解锁
function t_ExhibitionModelView:AddModelBt_OnClick(bDel)
	local id = this:GetClientID()
	if id == 1 then
		-- 添加 跳转到衣橱栏目
		ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabWardrobe, {index = self:GetCurPosShowIndex()})
	else
		-- 解锁
		self:BuyUnlockShowPos()
	end
end

function t_ExhibitionModelView:BuyUnlockShowPos()
	-- 判断[Desc5]所需货币是否足够
	local needNum = self.buyNeedNum
	local state = CheckMiniBean(needNum)
	if state == 0 then
		--迷你豆不足，弹出兑换迷你豆页面
		getglobal("BeanConvertFrame"):Show()
		return
	end
	
	-- 迷你豆充足
	local costId = 10000
	local index = self:GetCurPosShowIndex()
	local content = GetS(110101, needNum, tostring(index))
	-- [Desc5]结果回调
	local callback = function(btnName, param)
		if btnName == "right" then		
			-- 位置 - 1  第一个位置为默认形象，后端只发后面八个
			local code, ret = AccountManager:personal_show_buy_seat(index - 1)
			print("BuyUnlockShowPos code", code)
			print("BuyUnlockShowPos ret", ret)
			if code == ErrorCode.OK then
				local singleData = self:GetPosShowDefaultData()
				singleData.type = self.showType.default
				self.allMyPosShowDatas[index] = singleData
				-- 刷新
				self:CheckRespData()
				self:UpdateShowPosView()
			end
		end
	end

	StoreMsgBox(5, content, GetS(110096), -4, needNum, needNum, costId, callback)
end

-- 删除形象
function t_ExhibitionModelView:DelModePos_OnClick()
	MessageBoxFrame2:Open(2, GetS(110100), GetS(110099), function(btn)
		if btn == "right" then
			ShowLoadLoopFrame(true, "file:playercenter_new-- DelModePos_OnClick")
			local delIndex = self:GetCurPosShowIndex()
			print("DelModePos_OnClick delIndex", delIndex)

			-- 位置 - 1  第一个位置为默认形象，后端只发后面八个
			local code, ret = AccountManager:personal_show_set(delIndex - 1, 0, 0)
			if code == ErrorCode.OK then
				local singleData = self:GetPosShowDefaultData()
				singleData.type = self.showType.default
				self.allMyPosShowDatas[delIndex] = singleData
				-- 刷新
				self:UpdateShowPosView()
			end

			ShowLoadLoopFrame(false)
		end
	end)
end

-- 上一页
function t_ExhibitionModelView:PrePage_OnClick()
	local curIndex = self:GetCurPosShowIndex()
	curIndex = curIndex - 1
	if curIndex < 1 then
		return 
	end

	self:SetCurPosShowIndex(curIndex)
	self:UpdateShowPosView()
end

-- 下一页
function t_ExhibitionModelView:NextPage_OnClick()
	local totalNum = self:GetAllPosShowNum()
	local curIndex = self:GetCurPosShowIndex()
	curIndex = curIndex + 1
	if curIndex > totalNum then
		return 
	end

	self:SetCurPosShowIndex(curIndex)
	self:UpdateShowPosView()
end

-- 按钮点击开始
function t_ExhibitionModelView:RotateView_OnMouseDown()
	if not self.actorView then return end
	self.InitModelViewAngle = self.actorView:getRotateAngle()
	self.isMovingFlag = false
end

--按钮点击移动
function t_ExhibitionModelView:RotateView_OnMouseMove()
	if not self.actorView then return end
	local posX = self.actorView:getActorPosX()
	local posY = self.actorView:getActorPosY()
	if arg1 > posX-170 and arg1 < posX+170 and arg2 > posY-410 and arg2 < posY+30 then	--按下的位置是角色范围内
		local angle = (arg1 - arg3)*1

		if angle > 360 then
			angle = angle - 360
		end
		if angle < -360 then
			angle = angle + 360
		end

		angle = angle + self.InitModelViewAngle
		self.actorView:setRotateAngle(angle)
		self.isMovingFlag = true
	end
end

--按钮抬起过程
function t_ExhibitionModelView:RotateView_OnMouseUp()
	if not self.isMovingFlag then
		-- 添加 跳转到衣橱栏目
		ExhibitionLeftTabBtnTemplate_OnClick(t_ExhibitionCenter.define.tabWardrobe, {index = self:GetCurPosShowIndex()})
	end

	self.isMovingFlag = false
end

function t_ExhibitionModelView:OnPermissionDetailClick(permissionType)
	getglobal("PlayerCenterDataEdit"):Hide();
	getglobal("PlayerCenterSetFrameBack"):Show();
	getglobal("PlayerCenterPermissionDetail"):Show();
	self:ShowPermissionDetailContent(permissionType);
end

function t_ExhibitionModelView:ShowPermissionDetailContent(permissionIdx)
	local detailName = "PlayerCenterPermissionDetail";
	if not permissionIdx and not m_permissionContent[permissionIdx] then
		return
	end
	--非个性推荐
	if permissionIdx < m_permissionIdx.recommend then
		getglobal(detailName.."Content1TitleText"):SetText(m_permissionContent[permissionIdx]);
		getglobal(detailName.."Explain"):Hide();
		for i=1,4 do
			getglobal(detailName.."title"..i):Show();
			getglobal(detailName.."Content"..i):Show();
		end
		getglobal(detailName.."title1TitleText"):SetText(m_permissionTitle[permissionIdx]);
		getglobal(detailName.."Plane"):SetHeight(700);

	elseif permissionIdx < m_permissionIdx.bestpartner then
		--个性化推荐
		getglobal(detailName.."Explain"):Show();
		for i=1,4 do
			getglobal(detailName.."title"..i):Hide();
			getglobal(detailName.."Content"..i):Hide();
		end
		getglobal(detailName.."ExplainText"):SetText(m_permissionContent[permissionIdx]);
		getglobal(detailName.."Plane"):SetHeight(getglobal(detailName):GetHeight());
	else -- 最佳拍档
		getglobal(detailName.."Explain"):Show();
		for i=1,4 do
			getglobal(detailName.."title"..i):Hide();
			getglobal(detailName.."Content"..i):Hide();
		end
		getglobal(detailName.."ExplainText"):SetText(m_permissionContent[permissionIdx]);
		getglobal(detailName.."Plane"):SetHeight(getglobal(detailName):GetHeight());
	end
end

function t_ExhibitionModelView:OnPermissionLocateSettingClick(textType,name)
	if not name then
		return;
	end
	local textName = settingPage3Name..name.."StatusText";
	local permissionId = self:findPermissionIdxByName(textName);
	if permissionId then
		local bHasPermission = false;
		if ClientMgr:isAndroid() then
			bHasPermission = MINIW__CheckHasPermission(permissionId)
		elseif ClientMgr:isApple() then
			bHasPermission = SdkManager:CheckHasPermission(permissionId)
		else
			bHasPermission = MINIW__CheckHasPermission(permissionId)
		end
		if bHasPermission then
			-- 已有权限，去设置关闭
			print("MINIW__OpenSystemSetting");
			if MINIW__OpenSystemSetting and ClientMgr:isAndroid() then
				MINIW__OpenSystemSetting()
			elseif SdkManager.OpenSystemSetting and ClientMgr:isApple() then
				SdkManager:OpenSystemSetting();
			end
		else
			-- 没有权限，去申请权限
			print("MINIW__RequestPermission permissionId=",permissionId);
			if MINIW__RequestPermission and ClientMgr:isAndroid() then
				MINIW__RequestPermission(permissionId)
			elseif SdkManager.RequestPermission and ClientMgr:isApple() then
				SdkManager:RequestPermission(permissionId);
			end
		end
		PlayerCenterSetFrameCloseBtn_OnClick();
	end
end

function t_ExhibitionModelView:findPermissionIdxByName(textName)
	for k,v in pairs(permissionStateTextName) do
		if textName == k then
			return v;
		end
	end
	return nil;
end

function t_ExhibitionModelView:OnPermissionDetailBackClick()
	getglobal("PlayerCenterDataEdit"):Show();
	getglobal("PlayerCenterSetFrameBack"):Hide();
	getglobal("PlayerCenterPermissionDetail"):Hide();
end

function InitPermissionState()
	for k,v in pairs(permissionStateTextName) do
		if getglobal(k) then
			getglobal(k):SetTextColor(61,69,70);
			if ClientMgr:isAndroid() then
				if MINIW__CheckHasPermission and MINIW__CheckHasPermission(v) then
					-- 有权限
					getglobal(k):SetText(GetS(1000633));  --已开启
					getglobal(k):SetTextColor(10,170,26);
				else
					-- 没有权限
					getglobal(k):SetText(GetS(1000634)); --去设置
					getglobal(k):SetTextColor(61,69,70);
				end
			elseif ClientMgr:isApple() then
				local isOpen = false
                if v == DevicePermission_Calendar then -- 日历权限
					local ok, ret = luaoc.callStaticMethod("MNCalendarEventManager", "getCalendarPermission", {})
					print("MNCalendarEventManager->getCalendarPermission:" .. tostring(ret))
					if ok then
						isOpen = ret
					end
				else
					if SdkManager.CheckHasPermission and SdkManager:CheckHasPermission(v) then
						isOpen = true
					else
						isOpen = false
					end
				end
				if isOpen then
					-- 有权限
					getglobal(k):SetText(GetS(1000633));  --已开启
					getglobal(k):SetTextColor(10,170,26);
				else
					-- 没有权限
					getglobal(k):SetText(GetS(1000634)); --去设置
					getglobal(k):SetTextColor(61,69,70);
				end
			end
		end
	end
end

--初始化权限显示
function InitPermissionUI()
	local BestPartnerIndex = 8
	for k,v in pairs(permissionUIName) do
		if ClientMgr:isPC() then
			if k == 7 then
				getglobal(v):Show()
				getglobal(v):SetPoint("topleft", "PlayerCenterDataEditPage3", "topleft", 29, 60)
			elseif k == BestPartnerIndex then --最佳拍档开关显示
				getglobal(v):Show()
			else
				getglobal(v):Hide()
			end
		else
			if k == 4 then
				--[4]="PlayerCenterDataEditPage3Contact",  --通讯录
				local item = getglobal(v)
				item:SetPoint("center", permissionUIName[k-1], "center", 0, 0)
				item:Hide()
			else
				getglobal(v):Show()
			end
		end
	end
end