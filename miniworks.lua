
local CurLabel = 7;		--1精选(->地图) 2投稿 3玩家区(我的) 4专题区 5收藏区 6搜索区 7主页 8材质包(->新材质包)
local LastLabel = 7;
local Chosen_Archive_Max = 60;
local Review_Archive_Max = 60;
local Player_Archive_Max = 20;
local Theme_List_Max = 100;
local Theme_Archive_Max = 50;
local Collect_Archive_Max = 40;
local Search_Archive_Max = 60;
local Material_Mods_Max = 20;
local Connoisseur_Archive_Max = 16;
local MapShowIndex = {}

local Chosen_CurLabel = 1;  --默认标签：综合
local Chosen_CurOrder = 1;  --默认排序：时间
local Review_CurLabel = 1;  --默认标签：综合
local Review_CurOrder = 1;  --默认排序：时间
local Player_CurLabel = 1;  --默认标签：综合
local Player_CurOrder = 1;  --默认排序：时间
local Collect_CurLabel = 1;  --默认标签：综合
local Collect_CurOrder = 1;  --默认排序：时间
local Connoisseur_CurLabel = 1;  --默认标签：综合
local Connoisseur_CurOrder = 1;  --默认排序：时间

local nextMapSetBlack = false;
local nextMapCancelBlack = false;
local nextMapSetChosen = false;
local nextMapCancelChosen = false;
local nextMapCopyOwid = false;

local CurTopicObj = nil;

local MaterialInfoFrame_mod = nil;

--变量定义
local mMeteralLoadState = {};		--材质包下载状态
local SingleArchiveHeight = 138;	--存挡条高度(130 + 8)
local SingleArchiveOffset = 10;		--存挡条间隔
local MiniWorks_CurrentSwitchBtn = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};	--当前选中的按钮{地图, ...首页..}, 顺序同CurLabel;
local MiniWorks_SwitchBtnNum = {5, 1, 1, 1, 1, 1, 1, 2};		--按钮个数, 顺序同CurLabel;(材质包页暂时去掉玩家按钮)
local MiniWorks_SwitchBtnName = { {191, 3816, 3817, 3870, 6063}, {3816, 3817}, {3816, 3817}, {3816, 3817}, {3816, 3817}, {3816, 3817}, {3816, 3817}, {6032, 6033} };	--按钮ID名字, 顺序同CurLabel;
local MiniWorks_ChildPageName = {{"MiniWorksFrameConnoisseur", "MiniWorksFrameChosen", "MiniWorksFramePlayer", "MiniWorksFrameReview", "MiniWorksFrameMapActivity"}, {}, {}, {}, {}, {}, {}, {"MiniWorksFrameMaterial", nil}};	--子页面名称,{{1,精选,玩家}, } 顺序同CurLabel;
local MiniWorks_MainShow = false;    --首页改版，记录首页是否要显示

--页面顺序, 改为全局变量, 
--1. "精选"页面->"地图"页面:MiniWorksFrameChosen->MiniWorksFrameMap
--2. "材质包"页面:MiniWorksFrameMaterial->MiniWorksFrameMaterialNew
--3. "玩家"->个人中心:MiniWorksFramePlayer->MiniWorksFrameSelfCenter
local CONST_FRAME_NAME = {
	MAP 			= "MiniWorksFrameMap",
	REVIEW 			= "MiniWorksFrameReview",
	SELF_CENTER 	= "MiniWorksFrameSelfCenter",
	THEME_LIST 		= "MiniWorksFrameThemeList",
	COLLECT 		= "MiniWorksFrameCollect",
	SEARCH 			= "MiniWorksFrameSearch",
	MAIN 			= "MiniWorksMain",
	MATERIAL_NEW 	= "MiniWorksFrameMaterialNew",
	TEMPLATE 		= "MiniWorksTemplate",
	MAP_TEMPLATE 	= "MiniWorksMapTemplate",
	TOPIC 			= "MiniWorksTopic",
	ACTDRAMA 		= "MiniWorksActDrama",
}

local t_MiniWorks_FrameName = {
	CONST_FRAME_NAME.MAP,
	CONST_FRAME_NAME.REVIEW,
	CONST_FRAME_NAME.SELF_CENTER,
	CONST_FRAME_NAME.THEME_LIST,
	CONST_FRAME_NAME.COLLECT,
	CONST_FRAME_NAME.SEARCH,
	CONST_FRAME_NAME.MAIN,
	CONST_FRAME_NAME.MATERIAL_NEW,
	CONST_FRAME_NAME.TEMPLATE,
	CONST_FRAME_NAME.MAP_TEMPLATE,
	CONST_FRAME_NAME.TOPIC,
	CONST_FRAME_NAME.ACTDRAMA,
}

--导航按钮布局
local t_LabelInfo = {
	{uvName="icon_map_tab", nameId=6030, uvNameClick="icon_map_tab", iconW="41", iconH="49"},	--精选->改为地图(3816->6030, mngf_icon03->mngfg_icon04)
	{uvName="icon_home_tab", nameId=3870, uvNameClick="icon_home_tab", iconW="45", iconH="39"},	--审助
	{uvName="icon_mine_tab", nameId=6031, uvNameClick="icon_mine_tab", iconW="42", iconH="53"},	--玩家->我的(3817->6031, mngf_icon06->mngfg_icon014)
	{uvName="icon_subject_tab", nameId=3871, uvNameClick="icon_subject_tab", iconW="42", iconH="49"},	--专题
	{uvName="icon_like_tab", nameId=3872, uvNameClick="icon_like_tab", iconW="40", iconH="42"},	--收藏->(mngf_icon08->mngfg_icon012)
	{uvName="icon_search_tab", nameId=3818, uvNameClick="icon_search_tab", iconW="38", iconH="49"},	--搜索->(mngf_icon05->mngfg_icon018)
	{uvName="icon_home_tab", nameId=3859, uvNameClick="icon_home_tab", iconW="45", iconH="39"},	--首页
	{uvName="icon_material_tab", nameId=4777, uvNameClick="icon_material_tab", iconW="31", iconH="42"},	--材质包->(4770->4777)
	{uvName="icon_mould_tab", nameId=25217, uvNameClick="icon_mould_tab", iconW="31", iconH="42"}, --模板页
	{uvName="icon_mould_tab", nameId=25217, uvNameClick="icon_mould_tab", iconW="31", iconH="42"}, --地图模板
	{uvName="icon_topic_tab", nameId=25239, uvNameClick="icon_topic_tab", iconW="42", iconH="49"}, --话题
	{uvName="icon_video_tab", nameId=75002, uvNameClick="icon_video_tab", iconW="52", iconH="52"}, --互动剧
};

-- 展示tab组件顺序
local t_LabelISeq = {
	7, --首页
	1, --地图
	9, --模板
	2, --助审, gm版本才显示
	4, --专题
	5, --收藏
	12, --互动剧
	10,--地图模板
	8, --材质
	6, --搜索
	3, --我的
	11, -- 话题
}

function IsMiniWorksFrameType(idx, frameName)
	return t_MiniWorks_FrameName[idx] == frameName
end

local t_MiniWorks_FrameNameIdx = {}
-- 获取frame对应的tab index
function GetMiniWorksFrameIdxByName(frameName)
	if t_MiniWorks_FrameNameIdx[frameName] then
		return t_MiniWorks_FrameNameIdx[frameName]
	end

	for k, _frameName in pairs(t_MiniWorks_FrameName) do
		if _frameName == frameName then
			t_MiniWorks_FrameNameIdx[frameName] = k
			return k
		end
	end
end

-- 防止因调整Tab顺序导致子页面btnIndex 在 MiniWorks_CurrentSwitchBtn 越界问题，动态为需要记录switchIdx的按钮分配btnIndex
local function GetCurFrameSubPageSwitchBtnIdx(frameTabIdx)
	if not MiniWorks_CurrentSwitchBtn[frameTabIdx] then
		MiniWorks_CurrentSwitchBtn[frameTabIdx] = 1
	end

	return MiniWorks_CurrentSwitchBtn[frameTabIdx]
end

function GetMiniWorksFrame_GetMapFrameIdx()
	local frameNameIdx = GetMiniWorksFrameIdxByName(CONST_FRAME_NAME.MAP)
	
	return GetCurFrameSubPageSwitchBtnIdx(frameNameIdx)
end
-------------------------------------------------new_add:曝光---------------------------------------------
local m_ExposureParam = {
	-- boxFrames = {
	-- 	"MainArchiveBox",
	-- 	"ConnoisseurArchiveBox",
	-- 	"ThemeListBox",
	-- },

	boxFrames = {
		-- {labelid = 7, firstShow = true, planeOffset = 0, boxOffset = 0, ui = "MainArchiveBox"},			--主页
		{labelid = 7, firstShow = true, planeOffset = 0, boxOffset = 0, ui = "MiniWorksMainListFrame"},			--主页
		{labelid = 1, firstShow = true, planeOffset = 0, boxOffset = 0, ui = "ConnoisseurArchiveBox"},	--地图
		{labelid = 4, firstShow = true, planeOffset = 0, boxOffset = 0, ui = "ThemeListBox"},				--专题
	},

	updateCD = 0;		--刷新间隔
	startTime = 0;		--当前时间(单位s)
	state = 0;			--0:开始计时; 1:达到时间, 曝光.
	boxH = 0;			--box高度
	planeH = 0;			--plane高度
	planeOffset = 0;	--plane当前滑动位置
	boxOffset = 0;		--正确的偏移


	--重置时间，开始计时
	Init = function(self)
		print("ExposureInit:");
		-- local boxs = {
		-- 	{labelid = 7, firstShow = true, planeOffset = 0, boxOffset = 0, ui = "MainArchiveBox"},			--主页
		-- 	{labelid = 1, firstShow = true, planeOffset = 0, boxOffset = 0, ui = "ConnoisseurArchiveBox"},	--地图
		-- 	{labelid = 4, firstShow = true, planeOffset = 0, boxOffset = 0, ui = "ThemeListBox"},				--专题
		-- };
		local boxs = self.boxFrames;

		--打开页面的时候并没有滑动滚轮消息, 这里计算初始值.
		for i = 1, #boxs do
			if CurLabel == boxs[i].labelid then
				local box = getglobal(boxs[i].ui);
				local plane = getglobal(boxs[i].ui .. "Plane");

				self.boxH = box:GetRealHeight();
				self.planeH = plane:GetHeight();

				if boxs[i].firstShow then
					boxs[i].firstShow = false;
					self.planeOffset = self.planeH;
					self.boxOffset = 0;

					--保存初始值
					boxs[i].planeOffset = self.planeOffset;
					boxs[i].boxOffset = self.boxOffset;
				else
					self.planeOffset = boxs[i].planeOffset;
					self.boxOffset = boxs[i].boxOffset;
				end

				break;
			end
		end

		self.startTime = os.time();
		self.state = 0;
	end,

	SetParam = function(self, planeH, planeOffset, boxH, boxOffset)
		print("SetParam:");
		print("planeH:" .. planeH, "planeOffset:" .. planeOffset, "boxH:" .. boxH, "boxOffset:" .. boxOffset);
		self.planeH = planeH;
		self.planeOffset = planeOffset;
		self.boxH = boxH;
		self.boxOffset = boxOffset;

		local boxs = self.boxFrames;
		for i = 1, #boxs do
			if CurLabel == boxs[i].labelid then
				--保存当前的偏移值, 切换标签页的时候有用
				boxs[i].planeOffset = self.planeOffset;
				boxs[i].boxOffset = self.boxOffset;
				break;
			end
		end
	end,

	--是否达到曝光条件
	IsNeededReport = function(self)
		local interval = os.time() - self.startTime;
		-- print("IsNeededReport:");
		--print("startTime = " .. self.startTime, "interval = " .. interval);

		if self.state == 0 then
			--print("111");
			if interval > 1 then
				--print("222");
				self.state = 1;
				return true;
			else
				--print("333");
				return false;
			end
		elseif self.state == 1 then
			--print("444");
			return false;
		end
	end,

	--处理曝光
	Handle = function(self)
		print("Handle:CurLabel = " .. CurLabel);
		print("planeH:" .. self.planeH, "planeOffset:" .. self.planeOffset, "boxH = ", self.boxH);

		if self.planeOffset > self.planeH then
			self.planeOffset = self.planeH;
		end

		--计算可视区
		--local viewStart = self.planeH - self.planeOffset;
		local viewStart = self.planeH - self.planeOffset + self.boxOffset;
		local viewEnd = viewStart + self.boxH;
		print("viewStart = " .. viewStart, "viewEnd	= " .. viewEnd);

		if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAIN) then
			--主页
			local group = {	{startPos = 208, singleH = 130, archiveNum = 6, column = 2, ui = "MainArchiveBoxSectionWeeklyMaps"},			--1.精选
							{startPos = 208, singleH = 346, archiveNum = 8, column = 4, ui = "MainArchiveBoxSectionConnoisseurMaps"},		--2.鉴赏家
							{startPos = 208, singleH = 130, archiveNum = 6, column = 2, ui = "MainArchiveBoxSectionHotMaps"},				--3.当前热门
							{startPos = 208, singleH = 130, archiveNum = 6, column = 2, ui = "MainArchiveBoxSectionRecommend"},				--4.编辑推荐
							{startPos = 208, singleH = 130, archiveNum = 6, column = 2, ui = "MainArchiveBoxFeaturedGameplay"},				--5.精选玩法(原打点字段16)
							{startPos = 208, singleH = 346, archiveNum = 8, column = 4, ui = "MainArchiveBoxOptimalConnoisseurMaps"},		--6.鉴赏家优选(原打点字段17)

			};

			for i = 2, #group do
				group[i].startPos = group[i - 1].startPos + getglobal(group[i - 1].ui):GetHeight();
			end

			print("Handle:主页:");
			print(group);

			for i = 1, #group do
				for j = 1, group[i].archiveNum do
					local archiveUI = group[i].ui .. "Archive" .. j;

					if HasUIFrame(archiveUI) then
						if getglobal(archiveUI):IsShown() then
							--计算条目位置
							local column = group[i].column;
							local curRow = math.floor((j - 1) / column);			--第几行(0, 1, 2)
							local topY = group[i].startPos + curRow * group[i].singleH;	--archive的起始位置
							local endY = topY + group[i].singleH;

							Log("i = " .. i .. ", j = " .. j .. ", topY = " .. topY .. ", endY = " .. endY);

							--判断当前条目是否在可视区内
							if topY >= viewStart and endY <= viewEnd then
								Log("i = " .. i .. ", j = " .. j .. ", inview******!");
								local map = GetMapFromArchiveUi(getglobal(archiveUI));
								local fromId = i;	--来源
								local posIndex = j;	--位置

								--上报曝光
								if map then
									Log("map.owid = " .. map.owid);
									-- if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAIN) then
									-- 	--fromId 1.精选 2.鉴赏家 3.当前热门 4.编辑推荐 5.精选玩法(原打点字段16) 6.鉴赏家优选(原打点字段17)
									-- 	--posIndex 第几个地图
									-- 	statisticsGameEventNew(41120, "exposure", fromId, posIndex, map.owid);
									-- end
								end
							end
						end
					end
				end
			end
		elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP) then
			--地图
			print("地图:");
			local singleH = 346;
			local column = 4;
			local groupType = 1;
			local firstUI = "ConnoisseurArchive"


			if GetCurFrameSubPageSwitchBtnIdx(CurLabel) == 1 then
				--推荐
				print("推荐:");
				singleH = 346;
				column = 4;
				groupType = 5;
				firstUI = "ConnoisseurArchive";
			elseif GetCurFrameSubPageSwitchBtnIdx(CurLabel) == 2 then
				--精选
				print("精选:");
				singleH = 130;
				column = 2;
				groupType = 6;
				firstUI = "ChosenArchive";
			elseif GetCurFrameSubPageSwitchBtnIdx(CurLabel) == 3 then
				--玩家
				print("玩家:");
				singleH = 130;
				column = 2;
				groupType = 7;
				firstUI = "PlayerArchiveBoxPlayerMapsArchive";
			end

			for i = 1, 100 do
				local archiveUI = firstUI .. i;
				if HasUIFrame(archiveUI) then
					if getglobal(archiveUI):IsShown() then
						local curRow = math.floor((i - 1) / column);
						local topY = curRow * singleH;
						local endY = topY + singleH;

						Log("i = " .. i .. ", topY = " .. topY .. ", endY = " .. endY);

						if topY >= viewStart and endY <= viewEnd then
							Log("i = " .. i .. ", inview******!");

							local map = GetMapFromArchiveUi(getglobal(archiveUI));
							local fromId = groupType;	--来源
							local posIndex = i;			--位置

							--上报曝光
							if map then
								Log("map.owid = " .. map.owid);
								-- if CurLabel  == 1 then
								-- 	--fromId 5.图鉴 6.精选 7.玩家
								-- 	--posIndex 第几张地图
								-- 	statisticsGameEventNew(41121, "exposure", fromId, posIndex, map.owid);
								-- end
							end
						end
					end
				end
			end

		elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.THEME_LIST) then
			--专题
			print("专题:");
			local singleH = 130;

			for i = 1, 100 do
				local archiveUI = "Theme" .. i;
				if HasUIFrame(archiveUI) then
					if getglobal(archiveUI):IsShown() then
						local curRow = math.floor((i - 1) / 2);
						local topY = curRow * singleH;
						local endY = topY + singleH;

						Log("i = " .. i .. ", topY = " .. topY .. ", endY = " .. endY);

						if topY >= viewStart and endY <= viewEnd then
							Log("i = " .. i .. ", inview******!");
							local fromId = 11;		--来源
							local posIndex = i;		--位置

							--上报曝光
							--local topicTitle, topicId = self:GetTopicNameAndId(posIndex);
							-- if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.THEME_LIST) then
							-- 	statisticsGameEventNew(41122, "exposure", posIndex);
							-- end
						end
					end
				end
			end
		end
	end,

	--点击上报
	HandleClick = function(self, ui, type)
		--typs: 2:点击 3:下载 4:下载完成
		print("HandleClick: ui =" .. ui .. ", type = " .. type);
		local typeStr = "";
		if type == 2 then typeStr = "Click"; elseif type == 3 then typeStr = "Download"; elseif type == 4 then typeStr = "DownloadFinish"; end
		local id = getglobal(ui):GetClientID();
		local posIndex = id;
		Log("id = " .. id);
		--fromId 1.精选 2.鉴赏家 3.当前热门 4.编辑推荐 5.精选玩法(原打点字段16) 6.鉴赏家优选(原打点字段17)
		--posIndex 第几张地图
		if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAIN) and string.find(ui, "MainArchiveBox") then
			--首页
			local map = GetMapFromArchiveUi(getglobal(ui));

			-- if map and IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAIN) then
			-- 	if string.find(ui, "WeeklyMaps") then
			-- 		--1. 精选
			-- 		local fromId = 1;
			-- 		-- statisticsGameEventNew(41120, typeStr, fromId, posIndex, map.owid);
			-- 	elseif string.find(ui, "OptimalConnoisseurMaps") then
			-- 		--6 鉴赏家优选
			-- 		local fromId = 6;
			-- 		-- statisticsGameEventNew(41120, typeStr, fromId, posIndex, map.owid);
			-- 	elseif string.find(ui, "ConnoisseurMaps") then
			-- 		--2. 鉴赏家
			-- 		local fromId = 2;
			-- 		-- statisticsGameEventNew(41120, typeStr, fromId, posIndex, map.owid);
			-- 	elseif string.find(ui, "SectionHotMaps") then
			-- 		--3. 当前热门
			-- 		local fromId = 3;
			-- 		-- statisticsGameEventNew(41120, typeStr, fromId, posIndex, map.owid);
			-- 	elseif string.find(ui, "SectionRecommend") then
			-- 		--4. 编辑推荐
			-- 		local fromId = 4;
			-- 		-- statisticsGameEventNew(41120, typeStr, fromId, posIndex, map.owid);
			-- 	elseif string.find(ui, "FeaturedGameplay") then
			-- 		--5. 精选玩法
			-- 		local fromId = 5;
			-- 		-- statisticsGameEventNew(41120, typeStr, fromId, posIndex, map.owid);
			-- 	end
			-- end
		elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP) then
			--地图
			local map = GetMapFromArchiveUi(getglobal(ui));
			local fromId = GetCurFrameSubPageSwitchBtnIdx(CurLabel) + 4;

			-- if map and IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP) then
			-- 	--fromId 5.图鉴 6.精选 7.玩家
			-- 	--posIndex 第几张地图
			-- 	statisticsGameEventNew(41121, typeStr, fromId, posIndex, map.owid);
			-- end
		elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.THEME_LIST) and string.find(ui, "Theme") then
			print("Theme:");
			if string.find(ui, "ThemeArchive") then
				--专题条目:点击, 下载, 下载完成
				--Log("111:");
				--local fromId = 12;
				--local map = GetMapFromArchiveUi(getglobal(ui));
				--if map and IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.THEME_LIST) then
				--	statisticsGameEventNew(41122, typeStr, posIndex);
				--end
			else
				--专题列表:点击
				Log("222:");
				--local topicTitle, topicId = self:GetTopicNameAndId(posIndex);
				-- if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.THEME_LIST) then
				-- 	statisticsGameEventNew(41122, typeStr, posIndex);
				-- end
			end
		elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.COLLECT) and string.find(ui, "Collect") then
			--收藏
			if type == 3 or type == 4 then
				--下载/下载完成
				local map = GetMapFromArchiveUi(getglobal(ui));
				-- if map and IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.COLLECT) then
				-- 	--自己收藏
				-- 	statisticsGameEventNew(41123, typeStr, posIndex, map.owid);
				-- end
			end
		elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.SEARCH) then
			--搜索点击
			local map = GetMapFromArchiveUi(getglobal(ui));
			if map then
				Miniworks_UselessReport(3, {index = posIndex, owid = map.owid});
			end
		end
	end,

	--获取专题信息
	GetTopicNameAndId = function(self, index)
		local curTopic = nil;
		local topicTitle = "";
		local topicId = 0;
		if mapservice.topics then
			local curTopic = mapservice.topics[index];
			if curTopic then
				topicTitle = curTopic.title;
				topicId = curTopic.id;
			end
		end

		print("GetTopicNameAndId: topicTitle = " .. topicTitle .. ", topicId = " .. topicId);
		return topicTitle, topicId;
	end,

	--下载按钮点击上报
	HandleDownLoadClick = function(self, ui)
		print("HandleDownLoadClick: ui =" .. ui);
		local parentUI = getglobal(ui):GetParentFrame():GetName();
		self:HandleClick(parentUI, 3);
	end,

	--下载完成上报(工坊)
	HandleDownLoadComplete = function(self, ui)
		if getglobal("MiniWorksFrame"):IsShown() then
			print("HandleDownLoadComplete: ui = " .. ui);
			local parentUI = getglobal(ui):GetParentFrame():GetName();
			self:HandleClick(parentUI, 4);
		end
	end,
};

local standReportMapData = {
	[7] = "HomeContent",
	[1] = "MapContent",
	[8] = "MaterialContent",
	[4] = "SpecialContent",
	[5] = "CollectionContent",
	[6] = "SearchContent",
	[11] = "TopicContent",
	[10] = "TemplateContent",
}

--地图操作(收藏，取消收藏)上报
function MapHandleReport(typeStr, index, owid)
	print("MapHandleReport:");
	-- statisticsGameEventNew(41123, typeStr, index, owid);
end

--工坊下载按钮上报位置
function MiniworkDownBtnReporePostion(btnUI, map)
	print("MiniworkDownBtnReporePostion:btnUI = " .. btnUI);
	--print(map);

	if  btnUI and map then
		Log("OK:");
		local where = 0;
		if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAIN) then
			--主页
			where = 1
			if string.find(btnUI, "WeeklyMaps") then
				--1. 精选
				-- where = 2;
			elseif string.find(btnUI, "ConnoisseurMaps") then
				--2. 鉴赏家
				where = 5;
			elseif string.find(btnUI, "SectionHotMaps") then
				--3. 当前热门
				--where = 3;
			elseif string.find(btnUI, "SectionRecommend") then
				--4. 编辑推荐
				-- where = 1;
			end
		elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP) then
			--地图:1:推荐 2:精选 3:玩家
			where = GetCurFrameSubPageSwitchBtnIdx(CurLabel);
		elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.THEME_LIST) then
			--专题
			where = 8;
		elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.COLLECT) then
			--收藏
			where = 7;
		else
			print( "ERROR: CurLabel=" .. (CurLabel or 'nil') );
		end
		
		if  where > 0 then
			--setDownloadWhere(map.owid, where);
		end		

		print("MiniworkDownBtnReporePostion: where = " .. where .. " / " .. (map.owid or "") );
	end
end

--新增数据埋点(41103, 41104, 41105, 41106, 41107)
function Miniworks_UselessReport(nFromId, userdata, nType)
	--nType: 1:曝光 2:点击
	--nFromId: 1:tab按钮 2:搜索 3:搜索结果点击 4:滚动栏 5:地图筛选
	print("Miniworks_UselessReport:nFromId = ", nFromId);
	print("userdata = ", userdata);
	print("nType = ", nType);

	if nFromId == 1 then
		--1:tab按钮点击, userdata:索引1~7.
		local index = userdata;
		-- statisticsGameEvent(41103, '%d', index);
		if standReportMapData[index] then
			standReportEvent("3","MINI_WORKSHOP_CONTAINER_1",standReportMapData[index],"click")
		end
	elseif nFromId == 2 then
		--2: 搜索点击, userdata:search_uin, nType:1成功 2失败
		local search_uin = userdata;
		-- statisticsGameEvent(41104, '%d', search_uin, "%d", nType);
	elseif nFromId == 3 then
		--3:搜索结果点击, userdata = {index = 1, owid = 123456789};
		local index = userdata.index or 0;
		local owid = userdata.owid or 0;
		-- statisticsGameEvent(41105, '%d', index, "%d", owid);

		-- if getglobal("SearchArchiveBoxRoleInfo"):IsShown() then
		-- 	statisticsGameEventNew(41111, "more",AccountManager:getUin(), owid)
		-- else
		-- 	statisticsGameEventNew(41109, "more",AccountManager:getUin(), owid)
		-- end
        
	elseif nFromId == 4 then
		--4:滚动栏, userdata:index。 已经有了, 事件402、403
		-- local index = userdata;
		-- local nType = nType or 2;	--默认是点击
		-- statisticsGameEvent(41106, '%d', nType, "%d", index);
	elseif nFromId == 5 then
		--5:地图筛选点击, userdata:index
		local index = userdata;
		-- statisticsGameEvent(41107, '%d', index);
	end
end

function MainArchiveBox_Scroll()
	Log("MainArchiveBox_Scroll:");
	local planeH = arg3;
	local planeOffset = arg2;
	local boxH = arg1;
	local offset = 0 - arg4;	--当前偏移, 总偏移=planeH - planeOffset + offset;

	m_ExposureParam:Init();
	m_ExposureParam:SetParam(planeH, planeOffset, boxH, offset);
end

function ConnoisseurArchiveBox_Scroll()
	Log("ConnoisseurArchiveBox_Scroll:");
	local planeH = arg3;
	local planeOffset = arg2;
	local boxH = arg1;
	local offset = 0 - arg4;

	m_ExposureParam:Init();
	m_ExposureParam:SetParam(planeH, planeOffset, boxH, offset);
end

function ChosenArchiveBox_Scroll()
	Log("ChosenArchiveBox_Scroll:");
	local planeH = arg3;
	local planeOffset = arg2;
	local boxH = arg1;
	local offset = 0 - arg4;

	m_ExposureParam:Init();
	m_ExposureParam:SetParam(planeH, planeOffset, boxH, offset);
end

function PlayerArchiveBox_Scroll()
	Log("PlayerArchiveBox_Scroll:");
	local planeH = arg3;
	local planeOffset = arg2;
	local boxH = arg1;
	local offset = 0 - arg4;

	m_ExposureParam:Init();
	m_ExposureParam:SetParam(planeH, planeOffset, boxH, offset);
end

function ThemeListBox_Scroll()
	Log("ThemeListBox_Scroll:");
	local planeH = arg3;
	local planeOffset = arg2;
	local boxH = arg1;
	local offset = 0 - arg4;

	m_ExposureParam:Init();
	m_ExposureParam:SetParam(planeH, planeOffset, boxH, offset);
end


--"我的页面"----------------------------------------------------------------------------------------------
local g_ProductionMaps = {};								--"我的作品":全局变量, 保存地图信息
local bIsHaveChosenMapInProdection = false;					--作品中是否存在精选地图,有精选地图才能订阅.
local g_nProdectionDynaminCurTime = 0;						--跟新订阅动态, 最后的时间
local g_SubscribeList = {};				--订阅列表
local g_SubscribeDynamicList = {};		--订阅动态列表
local g_SubscribeDynamicMapList = {};	--订阅动态中的地图列表
local g_SubscribeDynamicMapIDList = {};	--待拉取的地图列表
local g_SubscribeDynamicPlayerInfo = {};--个人信息

function SetMiniWorksCurLabel(label)
	CurLabel = label;
end

function WorksLabelTemplate_OnClick()
	local label = this:GetClientID();
	if label == 6 --[[and GetInst("NSearchPlatformService"):ABTestSwitch()]] then
		standReportEvent("54","SEARCH_ENTRY_NEW","SearchEntryNew","click",{standby1 = 3})
		GetInst('NSearchPlatformService'):ShowSearchPlatform()
		return
	end
	--埋点
	Miniworks_UselessReport(1, label);
	MiniworksGotoLabel(label);

	--地图下载埋点设置参数
	MapDownloadReportMgr:SetMiniWorkType(label);
end

--跳转到界面
function MiniworksGotoLabel(label)
	if label ~= CurLabel then
		CurLabel = label;
		--设置当前选中的按钮索引
		
		Log("CurLabel = "..CurLabel);
		UpdateLabelState();
		ShowCurWorksFrame(true);

		m_ExposureParam:Init();
	end
end

function  UpdateLabelState()

	--禁用工坊页签
	if CurLabel and ClientMgr:getVersionParamInt("MiniworksLabel"..CurLabel, 1) == 0 then
		ShowGameTips(GetS(4038), 3);
		CurLabel = LastLabel;
	end

	--助审区只有GM可以进
	if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.REVIEW) and CSOWorld:isGmCommandsEnabled()==false then
		ShowGameTips(GetS(4038), 3);
		CurLabel = LastLabel;
	end

	local count = #t_LabelInfo
	for i=1, count do
			local normal = getglobal("MiniWorksFrameLabel"..i.."Normal");
			local checked 	= getglobal("MiniWorksFrameLabel"..i.."Checked");
			local name 	= getglobal("MiniWorksFrameLabel"..i.."Name");
			local icon = getglobal("MiniWorksFrameLabel"..i.."Icon");

			if CurLabel == i then
				normal:Hide();
				checked:Show();
				name:SetTextColor(255,153,63);
				-- --话题采用别的颜色
				-- if t_LabelInfo[i].nameId == 25239 then
				-- 	name:SetTextColor(255, 229, 56);
				-- end
				-- name:SetBaseColorByState(true);
				--name:SetShadowColor(235, 203, 151);

				--选中和不选中的图标也不一样
				icon:SetTexUV(t_LabelInfo[i].uvNameClick);
			else
				normal:Show();
				checked:Hide();
				name:SetTextColor(158, 225, 231);
				-- if t_LabelInfo[i].nameId == 25239 then
				-- 	name:SetTextColor(255,255,255);
				-- end
				-- name:SetBaseColorByState(false);
				--name:SetShadowColor(90, 59, 27);

				icon:SetTexUV(t_LabelInfo[i].uvName);
			end
		end

	if not CSOWorld:isGmCommandsEnabled() then
		getglobal("MiniWorksFrameLabel2Name"):SetTextColor(128, 128, 128);
		getglobal("MiniWorksFrameLabel2Name"):SetShadowColor(80, 80, 80);
	end

	LastLabel = CurLabel;
end

function MiniWorksFrameCloseBtn_OnClick()
	if ReportMgr and ReportMgr.setExpInfo then
		ReportMgr:setExpInfo(nil,nil,"")
	end
	if HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
		GetInst("UIManager"):GetCtrl("MiniWorksMain"):ShowCommendDetailPanel(false)
		return
	elseif HasUIFrame("MapTemplateCommend") and getglobal("MapTemplateCommend"):IsShown() then
		GetInst("UIManager"):GetCtrl("MiniWorksMapTemplate"):ShowTemplateCommendPanel(false)
		return
	else
		standReportEvent("3","MINI_WORKSHOP_TOP_1","Close","click")
	end
	if HasUIFrame("MiniWorksTopic") and getglobal("MiniWorksTopic"):IsShown() then
		GetInst("UIManager"):Close("MiniWorksTopic");
	end

	--关闭互动剧栏目
	GetInst("MiniWorksActDramaInterface"):CloseActDrama()

	JsBridge:PopFunction();
	
	getglobal("MiniWorksFrame"):Hide();
	
	--游戏中退出界面 不显示
	if  not ClientCurGame:isInGame() then
		if isEnableNewLobby and isEnableNewLobby() and newlobby_GetFromNewLobbyOpenMiniWorks() then
			ShowLobby()
			newlobby_SetFromNewLobbyOpenMiniWorks(false)
		else
			-- getglobal("MiniLobbyFrame"):Show();
			if not IsLobbyShown() then
				ShowMiniLobby() --mark by hfb for new minilobby
			end
		end
	end
	getglobal("NewMiniWorkMainLoadWaitFrame"):Hide();
	
	GetInst("MiniUIManager"):CloseUI("WorksManageAutoGen")
	
	EnterMainMenuInfo.MiWorkMoreMapDetailIndex1 = nil
	EnterMainMenuInfo.MiWorkMoreMapDetailIndex2 = nil
	
	EnterMainMenuInfo.MiWorkTopicIndex1 = nil
	EnterMainMenuInfo.MiWorkTopicIndex2 = nil
	
	EnterMainMenuInfo.WorksManageOpen = nil
end

function MiniWorksFrameHelpBtn_OnClick()
	standReportEvent("3","MINI_WORKSHOP_TOP_1","Help","click")
	SetMiniWorksBoxsDealMsg(false);
	getglobal("MiniWorksHelpFrame"):Show();

	StatisticsTools:gameEvent("OpenWorksHelpFrame");
end

--重排一下左侧导航按钮的布局顺序
function Miniworks_ReLayoutLeftLabelBtn()
	print("LabelBtn:", t_LabelISeq)
	local nBtnNum = #t_LabelISeq;		--按钮数量
	local nOffset = 10;				--y轴偏移
	local lastBtn = nil;			--上一个按钮
	
	local isNewCreationCenter = isEnableNewCreationCenter and isEnableNewCreationCenter()
	local topPad = 10
	
	if isNewCreationCenter then 
		threadpool:delay(0.02, function ()
			if not GetInst("UIManager"):GetCtrl("lobbyMapArchiveList") then 
				GetInst("UIManager"):Open("lobbyMapArchiveList", {})
			end 
			
			local mCtrl = GetInst("UIManager"):GetCtrl("lobbyMapArchiveList", "uiCtrlOpenList")
			if mCtrl then 
				mCtrl:CloseBtnClicked()
				GetInst("UIManager"):Close("lobbyMapArchiveList")
			end
		end)
		
		topPad = 60
		getglobal("MiniWorksFrameStartCreatingBtn"):Show()
		getglobal("MiniWorksFrameWorksManageBtn"):Show()
		
		-- 开始创作按钮 view
		standReportEvent("3", "MINI_WORKSHOP_CONTAINER_1", "CreateButton", "view")
		-- 作品管理按钮 view
		standReportEvent("3", "MINI_WORKSHOP_CONTAINER_1", "MycontentContent", "view")
		
		-- getglobal("MiniWorksFrameTitleName"):SetText(GetS(6660001))
		-- getglobal("MiniWorksHelpFrameTitleName"):SetText(GetS(6660002))
		-- getglobal("WorksHelpBoxContent"):SetText(GetS(6660003), 61, 69, 70)
	else 
		getglobal("MiniWorksFrameStartCreatingBtn"):Hide()
		getglobal("MiniWorksFrameWorksManageBtn"):Hide()
	end 

	for i=1, nBtnNum do
		local btn = getglobal("MiniWorksFrameLabel"..t_LabelISeq[i]);
		
		if btn then
			if i == 1 then
				btn:SetPoint("top", "MiniWorksFrameLeftLabelsDiban", "top", 0, topPad);
				--print("Miniworks_ReLayoutLeftLabelBtn setBtnPos1", btn:GetClientID())
			else
				btn:SetPoint("top", lastBtn:GetName(), "bottom", 0, nOffset);
				--print("Miniworks_ReLayoutLeftLabelBtn setBtnPos2", btn:GetClientID())
			end
		end
		
		local labelIdx = t_LabelISeq[i]
		--助审
		if IsMiniWorksFrameType(labelIdx, CONST_FRAME_NAME.REVIEW) then
			--if CSOWorld:isGmCommandsEnabled() then
			btn:Hide();
			if false then	--左侧导航按钮隐藏助审，助审区挪到了地图分支里
				lastBtn = btn;
			end
		elseif IsMiniWorksFrameType(labelIdx, CONST_FRAME_NAME.TEMPLATE) then
			--教育版本模板 隐藏
			if isEducationalVersion and if_open_miniwork_template() then
				lastBtn = btn
				btn:Show()
			else
				btn:Hide()
			end
		elseif IsMiniWorksFrameType(labelIdx, CONST_FRAME_NAME.MAP_TEMPLATE) then
			if not isEducationalVersion then
				lastBtn = btn
				btn:Show()
			else
				btn:Hide()
			end
		elseif IsMiniWorksFrameType(labelIdx, CONST_FRAME_NAME.SEARCH) then --搜索有AB测试
			-- if not GetInst("NSearchPlatformService"):ABTestSwitch() then
			-- 	lastBtn = btn
			-- 	getglobal("MiniWorksFrameNSearchBtn"):Hide()
			-- 	btn:Show()
			-- else
				standReportEvent("54","SEARCH_ENTRY_NEW","SearchEntryNew","view",{standby1 = 3})
				if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAIN) then
					--getglobal("MiniWorksFrameNSearchBtn"):Show()
					btn:Hide()
				end
			-- end
		elseif IsMiniWorksFrameType(labelIdx, CONST_FRAME_NAME.SELF_CENTER) then 	--"我的"hide掉
			btn:Hide();
		elseif IsMiniWorksFrameType(labelIdx, CONST_FRAME_NAME.COLLECT) then 	--"收藏"hide掉
			if isNewCreationCenter then
				btn:Hide()
			else
				btn:Show()
				lastBtn = btn
			end
		elseif IsMiniWorksFrameType(labelIdx, CONST_FRAME_NAME.ACTDRAMA) then	--互动剧
			local b_actDrama_opened = GetInst("MiniWorksActDramaInterface"):GetIsShowCfg()
			if b_actDrama_opened then
				lastBtn = btn
				btn:Show()
			else
				btn:Hide()
			end
		else
			lastBtn = btn;
		end

		--print("Miniworks_ReLayoutLeftLabelBtn btnVisible:", btn:GetClientID(), btn:IsShown() and "true" or "false")
	end
	
	local b_topic_opened = GetInst("ShareArchiveInterface"):IsTopicOpened()--话题开关
	if b_topic_opened then
		getglobal("MiniWorksFrameLabel11"):Show();
	else
		getglobal("MiniWorksFrameLabel11"):Hide();
	end
	--话题排最后一个
	for index = nBtnNum, 1, -1 do
		local btn = getglobal("MiniWorksFrameLabel3");
		if btn:IsShown() then
			local topicLabel = getglobal("MiniWorksFrameLabel11");
			topicLabel:SetPoint("top", btn:GetName(), "bottom", 0, 5);
			break;
		end
	end
end

-- 调整tab位置，从oldTabIdx 插入到newTabIdx 位置，其余按钮往下顺移
function MiniWorksFrame_SwapTabPos(oldTabIdx, newTabIdx)
	local newLabelBtn = table.clone(t_LabelISeq)
	local newMiniWorks_SwitchBtnName 	= {}
	local newMiniWorks_ChildPageName 	= {}
	local newMiniWorks_SwitchBtnNum 	= {}
	local newStandReportMapData 		= {}
	local oldIdx = oldTabIdx
	local newIdx = newTabIdx
	local displayIdx = table.remove(newLabelBtn, oldIdx)
	table.insert(newLabelBtn, newIdx, displayIdx)

	local newLabelInfo = {}
	local newFrameName = {}

	for i=1, #t_LabelISeq do
		local oldIdx = t_LabelISeq[i]
		local newIdx = newLabelBtn[i]

		newLabelInfo[oldIdx] = t_LabelInfo[newIdx]
		newFrameName[oldIdx] = t_MiniWorks_FrameName[newIdx]
		newMiniWorks_SwitchBtnNum[oldIdx] = MiniWorks_SwitchBtnNum[newIdx]
		newMiniWorks_SwitchBtnName[oldIdx] = MiniWorks_SwitchBtnName[newIdx]
		newMiniWorks_ChildPageName[oldIdx] = MiniWorks_ChildPageName[newIdx]

		newStandReportMapData[oldIdx] = standReportMapData[newIdx]
	end

	t_LabelInfo = newLabelInfo
	t_MiniWorks_FrameName 	= newFrameName
	MiniWorks_SwitchBtnNum 	= newMiniWorks_SwitchBtnNum
	MiniWorks_SwitchBtnName = newMiniWorks_SwitchBtnName
	MiniWorks_ChildPageName = newMiniWorks_ChildPageName
	standReportMapData 		= newStandReportMapData

	--print("t_MiniWorks_FrameName:", t_MiniWorks_FrameName)
end

-- 更新左侧tab文案
function MiniWorksFrame_UpdateLeftTabName()
	local count = #t_LabelInfo
	for i=1, count do
		local icon 	= getglobal("MiniWorksFrameLabel"..i.."Icon");
		local name 	= getglobal("MiniWorksFrameLabel"..i.."Name");

		icon:SetTextureHuiresXml("ui/mobile/texture2/miniwork.xml")
		icon:SetTexUV(t_LabelInfo[i].uvName);
		name:SetText(GetS(t_LabelInfo[i].nameId));
	end
end

local bTabMenuInit = false -- 只需要设置一次，之所以没放到onload是因为ABTest数据还没到位，影响到开关的效果
function MiniWorksFrame_SetTabInfo()
	if bTabMenuInit then
		return
	end
	bTabMenuInit = true

	-- 更新tab的位置，从第七位换到第二位
	MiniWorksFrame_SwapTabPos(7, 2)
	--初始或左侧导航条按钮
	MiniWorksFrame_UpdateLeftTabName()
	--左侧导航按钮位置重新排列
	Miniworks_ReLayoutLeftLabelBtn();
end

function MiniWorksFrame_OnLoad()
	this:setUpdateTime(0.05);

	-- 注册关闭按钮点击事件
	UITemplateBaseFuncMgr:registerFunc("MiniWorksFrameCloseBtn", MiniWorksFrameCloseBtn_OnClick, "迷你工坊关闭按钮");
	
	UITemplateBaseFuncMgr:registerFunc("MiniWorksFrameHelpBtn", MiniWorksFrameHelpBtn_OnClick, "迷你工坊帮助按钮");
	getglobal("MiniWorksFrameTitleName"):SetText(GetS(3815));

	
	--精选存档
	local realWidth = getglobal("MiniWorksFrameMap"):GetRealWidth2();
	local ChosenArchiveBoxPlane = getglobal("ChosenArchiveBoxPlane");
	ChosenArchiveBoxPlane:SetWidth(realWidth);
	for i=1, Chosen_Archive_Max/2 do
		for j=1, 2 do
			local archive = getglobal("ChosenArchive"..((i-1)*2+j));
			if j == 1 then
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topright", "ChosenArchiveBoxPlane", "top", -5, (i-1)*SingleArchiveHeight + 8);
			else
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topleft", "ChosenArchiveBoxPlane", "top", 5, (i-1)*SingleArchiveHeight + 8);
			end
		end
	end

	--助审区
	for i=1, Review_Archive_Max/2 do
		for j=1, 2 do
			local archive = getglobal("ReviewArchive"..((i-1)*2+j));
			if j == 1 then
				archive:SetPoint("topright", "ReviewArchiveBoxPlane", "top", -8, (i-1)*SingleArchiveHeight);
			else
				archive:SetPoint("topleft", "ReviewArchiveBoxPlane", "top", 8, (i-1)*SingleArchiveHeight);
			end
		end
	end

	--专题列表
	realWidth = getglobal("MiniWorksFrameTheme"):GetRealWidth2();
	local ThemeArchiveBoxPlane = getglobal("ThemeArchiveBoxPlane");
	ThemeArchiveBoxPlane:SetWidth(realWidth);
	for i=1, Theme_Archive_Max/2 do
		for j=1, 2 do
			local theme = getglobal("ThemeArchive"..((i-1)*2+j));
			if j == 1 then
				theme:SetWidth(realWidth/2 - 15);
				theme:SetPoint("topright", "ThemeArchiveBoxPlane", "top", -4, (i-1)*SingleArchiveHeight+5);
			else
				theme:SetWidth(realWidth/2 - 15);
				theme:SetPoint("topleft", "ThemeArchiveBoxPlane", "top", 4, (i-1)*SingleArchiveHeight+5);
			end
		end
	end

	--专题
	realWidth = getglobal("MiniWorksFrameThemeList"):GetRealWidth2();
	local ThemeListBoxPlane = getglobal("ThemeListBoxPlane");
	ThemeListBoxPlane:SetWidth(realWidth);
	for i=1, Theme_List_Max/2 do
		for j=1, 2 do
			local theme = getglobal("Theme"..((i-1)*2+j));
			if j == 1 then
				theme:SetWidth(realWidth/2 - 15);
				theme:SetPoint("topright", "ThemeListBoxPlane", "top", -4, (i-1)*SingleArchiveHeight);
			else
				theme:SetWidth(realWidth/2 - 15);
				theme:SetPoint("topleft", "ThemeListBoxPlane", "top", 4, (i-1)*SingleArchiveHeight);
			end
		end
	end

	--收藏区
	realWidth = getglobal("MiniWorksFrameCollect"):GetRealWidth2();
	local CollectArchiveBoxPlane = getglobal("CollectArchiveBoxPlane");
	CollectArchiveBoxPlane:SetWidth(realWidth);
	for i=1, Collect_Archive_Max/2 do
		for j=1, 2 do
			local archive = getglobal("CollectArchive"..((i-1)*2+j));
			if j == 1 then
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topright", "CollectArchiveBoxPlane", "top", -4, (i-1)*SingleArchiveHeight);
			else
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topleft", "CollectArchiveBoxPlane", "top", 4, (i-1)*SingleArchiveHeight);
			end
		end
	end 

	--搜索存档
	realWidth = getglobal("MiniWorksFrameSearch1"):GetRealWidth2();
	local SearchArchiveBoxPlane = getglobal("SearchArchiveBoxPlane");
	SearchArchiveBoxPlane:SetWidth(realWidth);
	for i=1, Search_Archive_Max/2 do
		for j=1, 2 do
			local archive = getglobal("SearchArchive"..((i-1)*2+j));
			if j == 1 then
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topright", "SearchArchiveBoxPlane", "top", -3, (i-1)*SingleArchiveHeight);
			else
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topleft", "SearchArchiveBoxPlane", "top", 3, (i-1)*SingleArchiveHeight);
			end
		end
	end
	--搜索存档
	for i=1, Search_Archive_Max/2 do
		for j=1, 2 do
			local archive = getglobal("SearchAuthor"..((i-1)*2+j));
			if j == 1 then
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topright", "SearchArchiveBoxPlane", "top", -3, (i-1)*SingleArchiveHeight);
			else
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topleft", "SearchArchiveBoxPlane", "top", 3, (i-1)*SingleArchiveHeight);
			end
		end
	end

	--材质包
	realWidth = getglobal("MiniWorksFrameMaterialNew"):GetRealWidth2();
	local MaterialsPlane = getglobal("MaterialsPlane");
	MaterialsPlane:SetWidth(realWidth);
	for i=1, Material_Mods_Max/2 do
		for j=1, 2 do
			local archive = getglobal("MaterialsEntry"..((i-1)*2+j));
			if j == 1 then
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topright", "MaterialsPlane", "top", -3, (i-1)*SingleArchiveHeight);
			else
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topleft", "MaterialsPlane", "top", 3, (i-1)*SingleArchiveHeight);
			end
		end
	end

	this:RegisterEvent("GE_WORLD_CHANGE");
	this:RegisterEvent("GE_MAP_TRANSFER");
	this:RegisterEvent("GIE_OWWATCH_RESULT");

	--Title的层级需要高于内容
	getglobal("MiniWorksFrameTitle"):SetFrameLevel(1100)
	getglobal("MiniWorksFrameHelpBtn"):SetFrameLevel(1101)
	getglobal("MiniWorksFrameCloseBtn"):SetFrameLevel(1101)
	getglobal("MiniWorksFrameTopNetwork"):SetFrameLevel(1101)
	getglobal("MiniWorksFrameNSearchBtn"):SetFrameLevel(1101)

	--getglobal("PlayerArchiveBoxActivityMapsRefresh"):SetText(GetS(3849));
	--getglobal("PlayerArchiveBoxActivityMapsHeaderText"):SetText("ABCDE");
	--UpdateSectionLayout("PlayerArchiveBoxActivityMaps");

	getglobal("PlayerArchiveBoxPlayerMapsRefresh"):SetText(GetS(3849));
	--getglobal("PlayerArchiveBoxPlayerMapsHeaderText"):SetText(GetS(3723));
	--UpdateSectionLayout("PlayerArchiveBoxPlayerMaps");

	local section_ui_name = "PlayerArchiveBoxPlayerMaps"
	local realWidth = getglobal("MiniWorksFrameMap"):GetRealWidth2();
	local PlayerArchiveBoxPlane = getglobal("PlayerArchiveBoxPlane");
	PlayerArchiveBoxPlane:SetWidth(realWidth);
	for i = 1, Player_Archive_Max/2 do
		for j = 1, 2 do
			local archive = getglobal(section_ui_name.."Archive"..2*(i-1)+j);
			if j == 1 then
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topright", "PlayerArchiveBoxPlane", "top", -5,(i-1)*SingleArchiveHeight+8);
			else
				archive:SetWidth(realWidth/2 - 15);
				archive:SetPoint("topleft", "PlayerArchiveBoxPlane", "top", 5,(i-1)*SingleArchiveHeight+8);
			end
		end
	end

	GetInst("MiniWorksActDramaInterface"):InitCfg()
end

function MiniWorksFrame_OnShow(label)
	--[[
	if not AccountManager:getNoviceGuideState("guideworksnovice") then
		CurLabel = 4;
	end
	]]

	MiniWorksFrame_SetTabInfo()
	
	-- getglobal("MiniLobbyFrame"):Hide();
	HideMiniLobby() --mark by hfb for new minilobby
	
	--LLDO:专题按钮红点处理, 初始化不显示
	MiniWorksLeftLabelBtnRedTagHandle(false);

	checkS2tAuth();

	if label then 
		CurLabel = label
	else
		CurLabel = 7; --默认首页
	end

	--地图下载埋点参数设置
	MapDownloadReportMgr:SetFrameName(ReportDefine.frameDefine.MiniWorkFrame);
	MapDownloadReportMgr:SetMiniWorkType(CurLabel);
	
	getglobal("MiniWorksFrameBackBtn"):Hide();
	getglobal("MiniWorksFrameCloseBtn"):Show();

	UpdateLabelState();

	--活动比赛模块信息
	FetchActivityInfo();

	ShowCurWorksFrame();

	--isGmCommandsEnabled貌似在OnLoad中无效, 在这里才有效
	Miniworks_ReLayoutLeftLabelBtn();

	if CSOWorld:isGmCommandsEnabled() then
		getglobal("MiniWorksFrameSetBlackBtn"):Show();
		getglobal("MiniWorksFrameCancelBlackBtn"):Show();
		getglobal("MiniWorksFrameSetChosenBtn"):Show();
		getglobal("MiniWorksFrameCancelChosenBtn"):Show();
		getglobal("MiniWorksFrameCopyOwidBtn"):Show();	
		getglobal("MiniWorksFrameGmReviewBtn"):Show();
	else
		getglobal("MiniWorksFrameSetBlackBtn"):Hide();
		getglobal("MiniWorksFrameCancelBlackBtn"):Hide();
		getglobal("MiniWorksFrameSetChosenBtn"):Hide();
		getglobal("MiniWorksFrameCancelChosenBtn"):Hide();
		getglobal("MiniWorksFrameCopyOwidBtn"):Hide();
		getglobal("MiniWorksFrameGmReviewBtn"):Hide();
	end

	m_ExposureParam:Init();

	--迷你工坊曝光打点
	-- statisticsGameEventNew(650,"MiniWorksFrame");

	--24号广告位
	AdvertCommonHandle:ShowAdvert(24, ADVERT_PLAYTYPE.AUTOSHOW_DIALOG);

	if GetInst("UIManager"):GetCtrl("AccountGameMode","uiCtrlOpenList") then
		GetInst("UIManager"):GetCtrl("AccountGameMode"):Refresh()
	end 

	--testgjd
	--迷你工坊游戏界面落地数据埋点
	MiniWorksFrame_BuriedDatapoints();
	
	--到达工坊界面-关闭CloudServerLobby界面
	GetInst("UIManager"):Close("CloudServerLobby")

	standReportWorksComp()

	resetFramePos();
	EnterMainMenuInfo.EnterMainMenuBy = 'MiniWork'
end

function MiniWorksFrame_OnHide()
	ShowMiniWorksMainDetail(false, nil, nil, true)
	ShowMiniWorksMain(false)
	-- ShowMiniWorksMVC(false,"MiniWorksFrameSearch")
	ShowMiniWorksMVC(false,"MiniWorksTemplate")
	ShowMiniWorksMVC(false,"MiniWorksMapTemplate")

	if HasUIFrame("MapTemplateCommend") and getglobal("MapTemplateCommend"):IsShown() then
		GetInst("UIManager"):Close("MapTemplateCommend")
	end
	if HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
		GetInst("UIManager"):Close("MiniWorksCommendDetail")
	end
	if HasUIFrame("ComeBackEntrance") and getglobal("ComeBackEntrance"):IsShown() then
		GetInst("UIManager"):Close("ComeBackEntrance")
	end
	if HasUIFrame("MiniWorksTopic") and getglobal("MiniWorksTopic"):IsShown() then
		GetInst("UIManager"):Close("MiniWorksTopic");
	end
end

function UpdateMiniWorksStateFrame()
	getglobal("MiniWorksFrameTopNetworkStateIcon"):Show();
	getglobal("MiniWorksFrameTopNetworkStateText"):Show();

	if mapservice.net_flow and next(mapservice.net_flow) ~= nil then
		if mapservice.net_flow.color == 0 then	--空闲
			getglobal("MiniWorksFrameTopNetworkStateIcon"):SetTexUV("icon_wificircle_green");
			getglobal("MiniWorksFrameTopNetworkStateText"):SetText(GetS(4903, "#c288c00", GetS(4904), mapservice.net_flow.cc))

			-- standReportEvent("11","MINI_WORKSHOP_TOP_1","OnlineStatus","view",{button_state="0"})
		elseif mapservice.net_flow.color == 1 then	--繁忙
			getglobal("MiniWorksFrameTopNetworkStateIcon"):SetTexUV("icon_wificircle_orange");
			getglobal("MiniWorksFrameTopNetworkStateText"):SetText(GetS(4903, "#cfa9628", GetS(4905), mapservice.net_flow.cc))

		elseif mapservice.net_flow.color == 2 then	--爆满
			getglobal("MiniWorksFrameTopNetworkStateIcon"):SetTexUV("icon_wificircle_red");
			getglobal("MiniWorksFrameTopNetworkStateText"):SetText(GetS(4903, "#cc82814", GetS(4906), mapservice.net_flow.cc))

			-- standReportEvent("11","MINI_WORKSHOP_TOP_1","OnlineStatus","view",{button_state="1"})
		else
			getglobal("MiniWorksFrameTopNetworkStateIcon"):SetTexUV("icon_wificircle_red");
			getglobal("MiniWorksFrameTopNetworkStateText"):SetText(GetS(7323))

		end
	else
		getglobal("MiniWorksFrameTopNetworkStateIcon"):SetTexUV("icon_wificircle_red");
		getglobal("MiniWorksFrameTopNetworkStateText"):SetText(GetS(7323))

	end
end

--刷新限制1秒三次
local WorksRefreshCD = 0;		
local WorksRefreshTimes = 0;
local WorksCanRefresh = true;	
function CanRefreshWorksByServer()
	if WorksCanRefresh then
		if WorksRefreshTimes == 0 then	--第一次点击,开启计算CD
			WorksRefreshCD = 1;		
		end
		WorksRefreshTimes = WorksRefreshTimes+1;
		return true;
	else
		return false;
	end
end

function MiniWorksFrame_OnUpdate()
	if WorksRefreshCD > 0 then
		WorksRefreshCD = WorksRefreshCD - arg1;
		if WorksRefreshTimes >= 3 then
			WorksCanRefresh = false;
		end
		if WorksRefreshCD < 0 then
			InitWorksRefreshInfo();
		end	
	end

	--材质包下载状态
	if mMeteralLoadState then
		for k, v in pairs(mMeteralLoadState) do
			--Log("MiniWorksFrame_OnUpdate:mod_state!");

			if v.loading then
				--正在下载
				if -1 == ModMgr:isLoadCompleted(k) then
					--下载好了
					Log("DownloadOk!!!");
					mMeteralLoadState[k] = nil;		--把自己删除, 防止一直刷新
					SetMeteralBtnDownloadState(v._btnUI, 2);
					MiniworksUpdateMaterialMods();	--刷新UI
				end
			end
		end
	end

	m_ExposureParam.updateCD = m_ExposureParam.updateCD + 1;
	if m_ExposureParam.updateCD > 20 then
		m_ExposureParam.updateCD = 0;
		if m_ExposureParam:IsNeededReport() then
			--达到曝光条件, 曝光
			Log("MiniWorksFrame_OnUpdate:IsNeededReport:true:");
			m_ExposureParam:Handle();
		end
	end
	if not isEnableNewMiniWorksMain or not isEnableNewMiniWorksMain() then
		if getglobal("MiniWorksMain"):IsShown() then
			GetInst("UIManager"):GetCtrl("MiniWorksMain"):UpdateUI_WaterMark()
			getglobal("MiniWorksFrameWaterMarkFrameFont"):SetText("")
		else
			getglobal("MiniWorksFrameWaterMarkFrame"):SetFrameLevel(1510)
			UpdateUI_WaterMark("MiniWorksFrameWaterMarkFrameFont")
		end
	end
end

function InitWorksRefreshInfo()
	WorksCanRefresh = true;
	WorksRefreshCD = 0;
	WorksRefreshTimes = 0;
end

--return { {arch_ui_name, map_obj}, ... }
function FindWorldChangeMaps(worldchangeevent)
	local owid = worldchangeevent.owid;
	local fromowid = worldchangeevent.fromowid;
	local from_tdr;
	if worldchangeevent.from_http == 1 then
		from_tdr = false;
	else
		from_tdr = true;
	end

	local changes = {};

	--Log("FindWorldChangeMaps: "..owid..","..fromowid..","..tostring(from_tdr));

	local archui = nil;
	local map = nil;

	if getglobal("HotMap"):IsShown() then --回流玩家下载要刷新
		local hotMap = GetInst("UIManager"):GetCtrl("HotMap")
		local listdata = hotMap:GetListInfo()
		local local_owid, m, item
		for i = 1, #listdata do
			local_owid = listdata[i].owid
			m = mapservice.mapInfoCache[local_owid]
			if m and (local_owid == owid or local_owid == fromowid) and m.from_tdr == from_tdr then
				table.insert(changes, {listdata[i].name, m})
				break
			end
		end
	end

	if getglobal("NewHotMap"):IsShown() then --回流玩家下载要刷新
		local NewHotMap = GetInst("UIManager"):GetCtrl("NewHotMap")
		local listdata = NewHotMap:GetListInfo()
		local local_owid, m, item
		for i = 1, #listdata do
			local_owid = listdata[i].owid
			m = mapservice.mapInfoCache[local_owid]
			if m and (local_owid == owid or local_owid == fromowid) and m.from_tdr == from_tdr then
				table.insert(changes, {listdata[i].name, m})
				break
			end
		end
	end

	if getglobal("CenterCollectArchiveBox"):IsShown() then
		for i = 1, #(mapservice.searchCollectMaps) do
			local m = mapservice.searchCollectMaps[i];
			if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					table.insert(changes, {"CenterCollectArchive"..i, m});
					break;
			end
		end
	elseif getglobal("MiniWorksSelfCenterProductionPage"):IsShown() then
		--"我的作品"页面下载地图, 同GetMapFromArchiveUi()函数一样, 这条判断需要放在前面
		--Log("1. enter");
		if g_ProductionMaps then
			--Log("2. sum = "..#g_ProductionMaps);
			for i = 1, #g_ProductionMaps do
				local m = g_ProductionMaps[i];
				if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					--Log("3.XXX");
					table.insert(changes, {"ProductionPageMapBoxArchive"..i, m});
					break;
				end
			end
		end
	elseif getglobal("MiniWorksSelfCenterSubscribePage"):IsShown() then  --订阅动态页面
		if g_SubscribeDynamicList and g_SubscribeDynamicMapList then
			Log("MiniWorksSelfCenterSubscribePage");
			for i = 1, #g_SubscribeDynamicList do
				for j = 1, #g_SubscribeDynamicMapList do
					if g_SubscribeDynamicList[i].wid == g_SubscribeDynamicMapList[j].owid then
						--匹配
						Log("break: i = "..i..", j = " ..j);
						local m = g_SubscribeDynamicMapList[j];
						local WndName = "SubscribePageBoxWnd" .. i;
						local ArchiveName = WndName .. "InfoArchive1";
						table.insert(changes, {ArchiveName, m});
						break;
					end
				end
			end
		end
	elseif getglobal("MiniWorksSelfCenterEvaluationInvitePage"):IsShown() then  --评测邀请页面
		for i = 1, #mapservice.expertTaskMaps do
			local m = mapservice.expertTaskMaps[i];
			if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
				--Log("3.XXX");
				table.insert(changes, {"EvaluationInvite"..i, m});
				break;
			end
		end
	-- elseif (IsRoomFrameShown() and getglobal("MiniWorksFrameSearch"):IsShown()) and not getglobal("MiniWorksFrame"):IsShown() then  --搜索区
	-- 	for i = 1, #(mapservice.searchedMaps) do
	-- 		local m = mapservice.searchedMaps[i];
	-- 		if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
	-- 			local listview = getglobal("MiniWorksFrameSearchList")
	-- 			local item =  listview:cellAtIndex(i-1)
	-- 			if item then
	-- 				table.insert(changes, {item:GetName(), m});
	-- 				break;
	-- 			end
	-- 		end
	-- 	end
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP) then  --精选--精选改成了地图, 地图有两个子页面:1.精选2.玩家
		if GetCurFrameSubPageSwitchBtnIdx(CurLabel) == 2 then
			--精选
			for i = 1, #(mapservice.chosenMaps) do
				local m = mapservice.chosenMaps[i];
				Log("["..i.."]: "..m.owid..","..tostring(m.from_tdr));
				if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					table.insert(changes, {"ChosenArchive"..i, m});
					break;
				end
			end
		elseif GetCurFrameSubPageSwitchBtnIdx(CurLabel) == 3 then
			--玩家
			for i = 1, #(mapservice.playerMaps) do
				local m = mapservice.playerMaps[i];
				if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					table.insert(changes, {"PlayerArchiveBoxPlayerMapsArchive"..i, m});
					break;
				end
			end
		elseif GetCurFrameSubPageSwitchBtnIdx(CurLabel) == 4 then
			--助审
			for i = 1, #(mapservice.reviewMaps) do
				local m = mapservice.reviewMaps[i];
				if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					table.insert(changes, {"ReviewArchive"..i, m});
					break;
				end
			end
		elseif GetCurFrameSubPageSwitchBtnIdx(CurLabel) == 5 then
			--活动
			for i = 1, #(mapservice.activityMaps) do
				local m = mapservice.activityMaps[i];
				if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					table.insert(changes, {"MapActivityArchiveBoxActivityMapsArchive"..i, m});
					break;
				end
			end
		end
		--[[
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.REVIEW) then  --助审区
		for i = 1, #(mapservice.reviewMaps) do
			local m = mapservice.reviewMaps[i];
			Log("["..i.."]: "..m.owid..","..tostring(m.from_tdr));
			if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
				table.insert(changes, {"ReviewArchive"..i, m});
				break;
			end
		end
		]]
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.SELF_CENTER) then --玩家区--:改为"我的"


	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.THEME_LIST) and CurTopicObj ~= nil then --主题区
		for i = 1, #(CurTopicObj.maps) do
			local m = CurTopicObj.maps[i];
			if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
				table.insert(changes, {"ThemeArchive"..i, m});
				break;
			end
		end

	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.COLLECT) then  --收藏区
		for i = 1, #(mapservice.collectMaps) do
			local m = mapservice.collectMaps[i];
			if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					table.insert(changes, {"CollectArchive"..i, m});
					break;
			end
			end

	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.SEARCH) then  --搜索区
		-- for i = 1, #(mapservice.searchedMaps) do
		-- 	local m = mapservice.searchedMaps[i];
		-- 	if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
		-- 		local listview = getglobal("MiniWorksFrameSearchList")
		-- 		local item =  listview:cellAtIndex(i-1)
		-- 		if item then
		-- 			table.insert(changes, {item:GetName(), m});
		-- 			break;
		-- 		end
		-- 	end
		-- end

	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAIN) then  --首页
		if UseNewMiniWorksMain then
			local listdata, local_owid, m

			if HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
				changes = GetInst("UIManager"):GetCtrl("MiniWorksCommendDetail"):GetLoadCells(owid, fromowid, from_tdr)
			else
				local itemname = 
				{
					"ChoiceCommend",
					"ToYouCommend",
					"ConnoisseurCommend"
				}

				for commendType=1,3 do
					listdata = GetInst("MiniWorksService"):GetMainCommendRandom(commendType)
					for i=1,#listdata do
						local_owid = tonumber(listdata[i])
						m = mapservice.mapInfoCache[local_owid]
						if m and (local_owid == owid or local_owid == fromowid) and m.from_tdr == from_tdr then
							table.insert(changes, {"MiniWorksMainListFrame"..itemname[commendType].."FrameItem"..i, m})
							break
						end
					end
				end
			end
		else
			for i = 1, #(mapservice.mainRecommendMaps) do
				local m = mapservice.mainRecommendMaps[i];
				if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					table.insert(changes, {"MainArchiveBoxSectionRecommendArchive"..i, m});
					break;
				end
			end

			for day_index = 1, #mapservice.mainDaily do
				local daily = mapservice.mainDaily[day_index];

				for i = 1, #daily.maps do
					local m = daily.maps[i];
					if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
						table.insert(changes, {"MainArchiveBoxSectionDaily"..day_index.."Archive"..i, m});
						break;
					end
				end
			end

			for i = 1, #(mapservice.mainLatestMaps) do
				local m = mapservice.mainLatestMaps[i];
				if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					table.insert(changes, {"MainArchiveBoxSectionLatestMapsArchive"..i, m});
					break;
				end
			end

			for i = 1, #(mapservice.mainHotMaps) do
				local m = mapservice.mainHotMaps[i];
				if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					table.insert(changes, {"MainArchiveBoxSectionHotMapsArchive"..i, m});
					break;
				end
			end

			-- LLDO:weekly,每周精选.
			for i = 1, #(mapservice.mainWeeklyMaps) do
				local m = mapservice.mainWeeklyMaps[i];
				if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					table.insert(changes, {"MainArchiveBoxSectionWeeklyMapsArchive"..i, m});
					break;
				end
			end

			for i = 1, #(mapservice.mainFeaturedGameplayMaps) do
				local m = mapservice.mainFeaturedGameplayMaps[i];
				if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					table.insert(changes, {"MainArchiveBoxFeaturedGameplayArchive"..i, m});
					break;
				end
			end
		end
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.TEMPLATE) then  --模板
		local maplist = GetInst("MiniWorksService"):GetDataWithKey("templateMaps") or {}
		for i = 1, #maplist do
			local m = maplist[i]
			if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
				table.insert(changes, {"MiniWorksTemplateMapsListArchive"..i, m});
				break;
			end
		end
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP_TEMPLATE) then  --地图模板化
		if HasUIFrame("MapTemplateCommend") and getglobal("MapTemplateCommend"):IsShown() then
			-- 模板推荐界面
			local ctrl = GetInst("UIManager"):GetCtrl("MapTemplateCommend")
			if ctrl and ctrl.GetCurDownloadItemFrame then
				local frameName, m = ctrl:GetCurDownloadItemFrame(fromowid, owid, from_tdr)
				if frameName and m then
					table.insert(changes, {frameName, m})
				end
			end
		else
			--todo 地图数据如何保存与取出
			local maplist = GetInst("MiniWorksService"):GetMapTemplateData() or {}
			for i = 1, #maplist do
				local m = maplist[i]
				if (m.owid == owid or m.owid == fromowid) and m.from_tdr == from_tdr then
					local frameName = ""
					local ctrl = GetInst("UIManager"):GetCtrl("MiniWorksMapTemplate")
					if ctrl and ctrl.GetCurDownFrame then
						local frame = ctrl:GetCurDownFrame(fromowid)
						if frame then
							frameName = frame:GetName()
						end
					end
					table.insert(changes, {frameName, m})
					break
				end
			end
		end
	end

	return changes;
end

function MiniWorksFrame_OnEvent()
	getglobal("WaitDownMapFrame"):setUpdateTime(1.0);
	if arg1 == "GE_WORLD_CHANGE" then  --地图改动通知
		local ge = GameEventQue:getCurEvent();
		local changes = FindWorldChangeMaps(ge.body.worldchange);
		Log("FindWorldChangeMaps: ");
		for i = 1, #changes do
			local archui = getglobal(changes[i][1]);
			local map = changes[i][2];

			-- if (IsRoomFrameShown() and getglobal("MiniWorksFrameSearch"):IsShown()) and not getglobal("MiniWorksFrame"):IsShown() then
			-- 	UpdateSingleArchiveDownloadState(archui, map);
			-- else
				if UseNewMiniWorksMain and IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAIN) or getglobal("HotMap"):IsShown() or getglobal("NewHotMap"):IsShown()then
					UpdateStatusBtn(changes[i][1], map)
				elseif UseNewMiniWorksMain and IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP_TEMPLATE) then --地图模板化特殊处理
					UpdateDownloadBtnStatus(changes[i][1], map, true)
				else
					UpdateSingleArchiveDownloadState(archui, map);
				end
			-- end
		end

		if IsMapDetailInfoShown() and CurArchiveMap then
			local funcBtnUi = getglobal("ArchiveInfoFrameIntroduceMiniworksFuncBtn");
			UpdateFuncBtnDownloadState(funcBtnUi, CurArchiveMap);
		end

		-- if getglobal("ArchiveInfoFrameEx"):IsShown() and CurArchiveMap then
		-- 	local funcBtnUi = getglobal("ArchiveInfoFrameExBodyRightFuncBtn");
		-- 	UpdateFuncBtnDownloadState(funcBtnUi, CurArchiveMap, "ArchiveInfoFrameEx", true);
		-- end

	elseif arg1 == "GE_MAP_TRANSFER" then  --上传下载地图事件
		local ge = GameEventQue:getCurEvent();
		local type = ge.body.maptransfer.type;
		local code = ge.body.maptransfer.code;

		if type == 1 then  --下载
			if code == -10 then  --地图不存在=-10
				ShowGameTips(GetS(3850), 3);
			elseif code < 0 then  --下载失败
				ShowGameTips(GetS(3851), 3);
			end
		end
	elseif arg1 == "GIE_OWWATCH_RESULT" then
		local ge = GameEventQue:getCurEvent();
		if ge.body.owresult.result == 4 then  --4:转发到mapservice
			--RespSearchMapsByUin_Tdr();
		end
	end
end

function ShowCurWorksFrame(statistics, isWorksMgr)
	MiniworksSelfCenterShowBackBtn(false)
	
	--:页面名定义改为全局变量
	for i=1, #(t_MiniWorks_FrameName) do
		local frame = getglobal(t_MiniWorks_FrameName[i]);
		if frame then
			local bShow = false
			if i == CurLabel then
				if t_MiniWorks_FrameName[i] ~= "MiniWorksFrameThemeList" and getglobal("MiniWorksFrameTheme"):IsShown() then
					getglobal("MiniWorksFrameTheme"):Hide()
				end
	
				bShow = true
			end
	
			if IsMiniWorksFrameType(i, CONST_FRAME_NAME.MAIN) then
				ShowMiniWorksMain(bShow)
			elseif IsMiniWorksFrameType(i, CONST_FRAME_NAME.TEMPLATE) or
					-- t_MiniWorks_FrameName[i] == "MiniWorksFrameSearch" or
					IsMiniWorksFrameType(i, CONST_FRAME_NAME.MAP_TEMPLATE) or
					IsMiniWorksFrameType(i, CONST_FRAME_NAME.TOPIC) then
	
				if IsMiniWorksFrameType(i, CONST_FRAME_NAME.TOPIC) then
					local b_topic_opened = GetInst("ShareArchiveInterface"):IsTopicOpened()--话题开关
					if not b_topic_opened then
						--保险起见开关关闭则不显示界面
						return 
					end
				end
				ShowMiniWorksMVC(bShow, t_MiniWorks_FrameName[i])
			else
				if bShow then
					frame:Show()
				else
					frame:Hide()
				end
			end
	
			if bShow then
				local MiniWorksNoNetworkHintTx = getglobal("MiniWorksFrameNoNetworkHintText");
				-- if (GetNetworkState() == 0) and (i == 7) or (GetNetworkState() == 0) and (i == 1) then
				if (GetNetworkState() == 0) and (i == 1) then
					local mwnwhText = GetS(7322);
					MiniWorksNoNetworkHintTx:Show();
					MiniWorksNoNetworkHintTx:SetText(mwnwhText, 150, 100, 50);
					MiniWorksNoNetworkHintTx:ScrollFirst();
					frame:Hide();
				else
					MiniWorksNoNetworkHintTx:Hide();
				end
	
				if statistics then
					StatisticsTools:gameEvent("MiniWorksFrame", "按钮名字", t_MiniWorks_FrameName[i]);
				end
	
				if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.SELF_CENTER) then
					getglobal("MiniWorksFrameLabel3RedTag"):Hide();
				end
			else
				if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.SELF_CENTER) then
					getglobal("MiniWorksFrameLabel3RedTag"):Hide();
				end
			end
		else
			if IsMiniWorksFrameType(i, CONST_FRAME_NAME.ACTDRAMA) then
				if not getglobal("MiniWorksFrame"):IsShown() then
					return;
				end
				if i == CurLabel then
					standReportEvent("3","MINI_WORKSHOP_CONTAINER_1","InteractiveVideoTab","click")
					GetInst("MiniWorksActDramaInterface"):OpenActDrama()
				else
					GetInst("MiniWorksActDramaInterface"):CloseActDrama()
				end
			end
		end
	end
	
	ShowWorksManage(isWorksMgr)
end

function NotifyMiniWorksMainShow()
	local name = "MiniWorksMain" 
	getglobal("NewMiniWorkMainLoadWaitFrame"):Hide();
	if not mapservice.mainPageDataPulled then
		if MiniWorks_MainShow then
			getglobal("NewMiniWorkMainLoadErrorFrame"):Show();
		end
		return;
	end
	if MiniWorks_MainShow then
		if isEnableNewMiniWorksMain and isEnableNewMiniWorksMain() then
			if not getglobal("MiniWorksFrame"):IsShown() or CurLabel ~= 7 then
				return;
			end
			GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common_comp", "miniui/miniworld/common", "miniui/miniworld/c_miniwork"})
			GetInst("MiniUIManager"):OpenUI("newMiniWorksMain", 
			"miniui/miniworld/newMiniWorks", "NewMiniWorksMainAutoGen")
			getglobal("MiniWorksFrameNSearchBtn"):Hide();
		else
			GetInst("UIManager"):Open(name)
			local curTabCtrl = GetInst("UIManager"):GetCtrl(name)
			if curTabCtrl and curTabCtrl.Show then 
				curTabCtrl:Show()
			end
			-- if GetInst("NSearchPlatformService"):ABTestSwitch() then
				getglobal("MiniWorksFrameNSearchBtn"):Show();
			-- end
		end
	else
		getglobal("MiniWorksFrameNSearchBtn"):Hide();
		if isEnableNewMiniWorksMain and isEnableNewMiniWorksMain() then
			GetInst("MiniUIManager"):HideUI("NewMiniWorksMainAutoGen")
			getglobal("NewMiniWorkMainLoadErrorFrame"):Hide();
			GetInst("MiniUIManager"):CloseUI("MiniWorksDetailsAutoGen");
			GetInst("MiniUIManager"):CloseUI("MiniWorksTopicsAutoGen");
			GetInst("MiniUIManager"):CloseUI("WorksManageAutoGen");
			GetInst("UIManager"):Close("MapDetailInfo")	

			--also close old ui, sometimes old ui show when the configuration is in pull
			GetInst("UIManager"):Hide(name)
			local curTabCtrl = GetInst("UIManager"):GetCtrl(name)
			if curTabCtrl and curTabCtrl.Hide then 
				curTabCtrl:Hide()
			end 
			if getglobal("MiniWorksFrameNSearchBtn") then
				getglobal("MiniWorksFrameNSearchBtn"):Hide();
			end
		else
			GetInst("UIManager"):Hide(name)
			local curTabCtrl = GetInst("UIManager"):GetCtrl(name)
			if curTabCtrl and curTabCtrl.Hide then 
				curTabCtrl:Hide()
			end 
			getglobal("MiniWorksFrameNSearchBtn"):Hide();
		end
	end
	MiniWorks_MainShow = false;
end

function ShowMiniWorksMain(bShow)
	--改为在这里拉取配置
	MiniWorks_MainShow = bShow;
	if bShow then
		getglobal("NewMiniWorkMainLoadWaitFrame"):Show();
	else
		getglobal("NewMiniWorkMainLoadWaitFrame"):Hide();	
	end
	if not mapservice.mainPageDataPulled then
		ReqMainPageData();
	else
		NotifyMiniWorksMainShow();
	end
end

function ShowMiniWorksMVC(bShow,frameName)
	local name = frameName
	if bShow then
		GetInst("UIManager"):Open(name)
		local curTabCtrl = GetInst("UIManager"):GetCtrl(name)
		if curTabCtrl and curTabCtrl.Show then 
			curTabCtrl:Show()
		end 
	else
		GetInst("UIManager"):Hide(name)
		local curTabCtrl = GetInst("UIManager"):GetCtrl(name)
		if curTabCtrl and curTabCtrl.Hide then 
			curTabCtrl:Hide()
		end 
	end
end

function resetFramePos()
	local switchFrames = {
		{name = "MiniWorksMain", pos = {"topleft", "MiniWorksFrame", "topleft", "180", "120"}},

		-- {name = "MiniWorksFrameMap", pos = {"topleft", "MiniWorksFrame", "topleft", "192", "120"}},
		-- {name = "MiniWorksFrameThemeList", pos = {"topleft", "MiniWorksFrame", "topleft", "192", "120"}},
		-- {name = "MiniWorksFrameTheme", pos = {"topleft", "MiniWorksFrame", "topleft", "192", "120"}},
		-- {name = "MiniWorksFrameCollect", pos = {"topleft", "MiniWorksFrame", "topleft", "192", "170"}},
		-- {name = "MiniWorksFrameMaterialNew", pos = {"topleft", "MiniWorksFrame", "topleft", "192", "120"}},

		-- {name = "MiniWorksCommendDetail", pos = {"topleft", "UIClient", "topleft", "0", "120"}},
		-- {name = "MiniWorksMapTemplate", pos = {"topleft", "UIClient", "topleft", "192", "120"}},
		-- {name = "MapTemplateCommend", pos = {"topleft", "UIClient", "topleft", "0", "120"}},
		-- {name = "MiniWorksTopic", pos = {"topleft", "UIClient", "topleft", "192", "120"}},
	}
	for index, value in ipairs(switchFrames) do
		local obj = getglobal(value.name)
		if obj then
			obj:SetPoint(value.pos[1],value.pos[2],value.pos[3],value.pos[4], --[[GetInst("NSearchPlatformService"):ABTestSwitch() and]] value.pos[5] --[[or "56"]]);
		end
	end
end

local lastStr = GetS(3815)
function ShowMiniWorksMainDetail(bShow, strtxt, frameName, notShowMvc)
	if not notShowMvc then
		if frameName == nil then
			ShowMiniWorksMain(not bShow)
		else
			ShowMiniWorksMVC(not bShow, frameName)
		end
		-- ShowMiniWorksMVC(not bShow, frameName or "MiniWorksMain")
	end
	MiniWorksHideLeftBtns(not bShow)
	getglobal("MiniWorksFrameLabel3"):Hide()

	local tabbg = getglobal("MiniWorksFrameTabBkg")
	if bShow then
		tabbg:Hide()
		getglobal("MiniWorksFrameTitleBkgHelp"):Hide()
		getglobal("MiniWorksFrameCloseBtnNormal"):SetTexUV("btn_return")
		getglobal("MiniWorksFrameCloseBtnPushedBG"):SetTexUV("btn_return")
		getglobal("MiniWorksFrameHelpBtn"):Hide()
		getglobal("MiniWorksFrameTitleName"):SetPoint("left", "MiniWorksFrameTitle", "left", 22, 0)
		strtxt = strtxt and strtxt or lastStr
		lastStr = strtxt
		getglobal("MiniWorksFrameTitleName"):SetText(strtxt)
	else
		tabbg:Show()
		getglobal("MiniWorksFrameCloseBtnNormal"):SetTexUV("btn_close")
		getglobal("MiniWorksFrameCloseBtnPushedBG"):SetTexUV("btn_close")
		getglobal("MiniWorksFrameHelpBtn"):Show()
		getglobal("MiniWorksFrameTitleBkgHelp"):Show()
		getglobal("MiniWorksFrameTitleName"):SetPoint("left", "MiniWorksFrameTitle", "left", 77, 0)
		getglobal("MiniWorksFrameTitleName"):SetText(GetS(3815))
	end
end

function HandleGmMapCommands(map)
	if nextMapSetChosen then  --设置为精选
		nextMapSetChosen = false;
		SetMapChosen(map, true);
		return true;
	elseif nextMapCancelChosen then  --从精选撤下
		nextMapCancelChosen = false;
		SetMapChosen(map, false);
		return true;
	elseif nextMapSetBlack then  --加入黑名单
		nextMapSetBlack = false;
		SetMapBlack(map, true);
		return true;
	elseif nextMapCancelBlack then  --取消黑名单
		nextMapCancelBlack = false;
		SetMapBlack(map, false);
		return true;
	elseif nextMapCopyOwid then  --复制owid
		nextMapCopyOwid = false;
		ClientMgr:clickCopy(tostring(map.owid));
		ShowGameTips("Copy: "..map.owid, 3);
		return true;
	end

	return false;
end

function GetMapFromArchiveUi(archui)
	local archindex = archui:GetClientID();

	local arch_ui_name = archui:GetName();	

	local map = nil;

	local isSearchResult = false
	local newVersion = SetAndGetABTest and SetAndGetABTest("exp_gf_home_xiaolong")

	if getglobal("MiniWorksSelfCenterProductionPage"):IsShown() then 	--"我的作品"地图信息, 这个判断需要放在最前面, 因为被的页面都可以打开这个页面, 放在后面可能会被截获.
		if g_ProductionMaps and #g_ProductionMaps > 0 then
			map = g_ProductionMaps[archindex];
		end
	elseif getglobal("MiniWorksSelfCenterSubscribePage"):IsShown() then  --订阅动态页面
		map = GetSubscribeDynamicMapFromArchive(archui);
	-- elseif (IsRoomFrameShown() and getglobal("MiniWorksFrameSearch"):IsShown()) and not getglobal("MiniWorksFrame"):IsShown() then  --搜索区
	-- 	archindex = archui:GetClientUserData(0);
	-- 	map = mapservice.searchedMaps[archindex];
	-- 	isSearchResult = true
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP) then  --精选--"精选"改成了"地图",地图下面有两个子页面:精选and玩家. 加一个活动页面
		--map = mapservice.chosenMaps[archindex];
		if arch_ui_name:find("ChosenArchive") then
			--精选
			if newVersion then
				local realIndex = 8 - archindex
				if MapShowIndex.UpdateChosenArchive - realIndex > 0 then
					archindex = MapShowIndex.UpdateChosenArchive - realIndex
				else
					archindex = #mapservice.chosenMaps + MapShowIndex.UpdateChosenArchive - realIndex
				end
			end
			map = mapservice.chosenMaps[archindex];

			--在地图详情数据里面插入点赞数量数据
			if map and map.owid then
				local tempMap = mapservice.mapInfoCache[map.owid]
				if tempMap and tempMap.like then
					map.like = tempMap.like
				end
			end
		elseif arch_ui_name:find("PlayerArchiveBox") then
			--玩家
			if arch_ui_name:find("ActivityMaps") then
				--map = mapservice.activityMaps[archindex];
			elseif arch_ui_name:find("PlayerMaps") then
				if newVersion then
				local realIndex = 8 - archindex
					if MapShowIndex.UpdateSectionMaps - realIndex > 0 then
						archindex = MapShowIndex.UpdateSectionMaps - realIndex
					else
						archindex = #mapservice.playerMaps + MapShowIndex.UpdateSectionMaps - realIndex
					end
				end	
				map = mapservice.playerMaps[archindex];
			end
		elseif arch_ui_name:find("Review") then
			--助审
			map = mapservice.reviewMaps[archindex];
		elseif arch_ui_name:find("ActivityArchiveBox") then
			--活动
			map = mapservice.activityMaps[archindex];
		elseif arch_ui_name:find("ConnoisseurArchive") then
			--鉴赏家推荐
			map = mapservice.expertMaps[archindex];
		end
		--[[
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.REVIEW) then  --助审区
		map = mapservice.reviewMaps[archindex];
	
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.SELF_CENTER) or getglobal("MiniWorksSelfCenterProductionPage"):IsShown() then	--玩家区-->改成"我的",
			]]
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.SELF_CENTER) and  getglobal("MiniWorksSelfCenterEvaluationInvitePage"):IsShown() then --评测邀请
		map = mapservice.expertTaskMaps[archindex];
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.THEME_LIST)  then  --专题区
		map = CurTopicObj.maps[archindex];
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.COLLECT) then  --收藏区
		map = mapservice.collectMaps[archindex];
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.SEARCH) then  --搜索
		-- archindex = archui:GetClientUserData(0);
		-- map = mapservice.searchedMaps[archindex];
		-- isSearchResult = true
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAIN) then  --首页
		local section_ui = archui:GetParentFrame();
		if section_ui then
			if arch_ui_name:find("SectionRecommend") then
				map = mapservice.mainRecommendMaps[archindex];

			elseif arch_ui_name:find("SectionDaily") then
				local day_index = section_ui:GetClientID();
				local daily = mapservice.mainDaily[day_index] or {};
				if daily and daily.maps then
					map = daily.maps[archindex];
				end

			elseif arch_ui_name:find("SectionLatestMaps") then
				map = mapservice.mainLatestMaps[archindex];

			elseif arch_ui_name:find("SectionHotMaps") then
				map = mapservice.mainHotMaps[archindex];
			elseif arch_ui_name:find("SectionWeeklyMaps") then --LLDO:weekly, 每周推荐
				map = mapservice.mainWeeklyMaps[archindex];
			elseif arch_ui_name:find("OptimalConnoisseurMaps") then
				-- 鉴赏家优选
				map = mapservice.mainOptimalMaps[archindex];
			elseif arch_ui_name:find("ConnoisseurMap") then
				--主页鉴赏家推荐
				map = mapservice.mainExpertMaps[archindex];
			elseif arch_ui_name:find("FeaturedGameplay") then
				map = mapservice.mainFeaturedGameplayMaps[archindex];
			end
		end
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.TEMPLATE) then --模板
		local maplist = GetInst("MiniWorksService"):GetDataWithKey("templateMaps") or {}
		map = maplist[archindex];
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP_TEMPLATE) then --地图模板
		local maplist = GetInst("MiniWorksService"):GetMapTemplateData() or {}
		map = maplist[archindex];
	end

	if map then
		Log("GetMapFromArchiveUi "..arch_ui_name.." -> "..tostring(map.owid));
	else
		Log("GetMapFromArchiveUi "..arch_ui_name.." -> nil");
	end

	return map, isSearchResult
end

--单击存档条
function WorksArchive_OnClick()
	Log("WorksArchive_OnClick");
	local archindex = this:GetClientID();
	WorksArchiveMsgCheck.archindex = archindex;

	local map, isSearchResult = GetMapFromArchiveUi(this);
	if not map then
		return
	end

	local appendReportInfo = {}
	-- if isSearchResult and GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch") then
	-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):StandReportMapContentClick(map.owid, false)
	-- 	appendReportInfo = GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):GetAppendReportInfo()
	-- end

	WorksArchiveMsgCheck.mapinfo = map;
	local type = GetCurFrameSubPageSwitchBtnIdx(CurLabel)
	if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.THEME_LIST) then
		standReportEvent("3","MINI_WORKSHOP_SUBJECT_1","MapCard1","click",{slot=tostring(archindex),cid=tostring(map.owid)})
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.COLLECT) then
		standReportEvent("3","MINI_WORKSHOP_COLLECT_1","MapCard1","click",{slot=tostring(archindex),cid=tostring(map.owid)})
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP) then
		local subPageBtnIdx = GetMiniWorksFrame_GetMapFrameIdx()
		
		if subPageBtnIdx == 1 then
			standReportEvent("3","MINI_WORKSHOP_MAPREC_1","MapCard1","click",{slot=tostring(archindex),cid=tostring(map.owid)})
		elseif subPageBtnIdx == 2 then
			standReportEvent("3","MINI_WORKSHOP_NICEMAP_1","MapCard1","click",{slot=tostring(archindex),cid=tostring(map.owid)})
		elseif subPageBtnIdx == 3 then
			standReportEvent("3","MINI_WORKSHOP_PLAYERMAP_1","MapCard1","click",{slot=tostring(archindex),cid=tostring(map.owid)})
		end
		
	end
	
	local verify = BreakLawMapControl:VerifyMapID(map.owid);
	if verify == 1 then
		ShowGameTips(GetS(10565), 3);
		return;
	elseif verify == 2 then
		ShowGameTips(GetS(3636), 3);
		return;
	end
	
	--在地图详情数据里面插入点赞数量数据
	if map.owid then
		local tempMap = mapservice.mapInfoCache[map.owid]
		if tempMap and tempMap.like then
			map.like = tempMap.like
		end
	end

	--地图详情页换了
	ShowMiniWorksMapDetail(map, {fromUiLabel=CurLabel, fromUiPart=nil}, nil, appendReportInfo);
	--ShowMapDetail(map, {fromUiLabel=CurLabel, fromUiPart=nil});

	--点击上报
	m_ExposureParam:HandleClick(this:GetName(), 2);

	MapDownloadReportMgr:SetMiniWorkHomepageSubType(this:GetName());

	--记录位置
	local downBtnUI = this:GetName() .. "FuncBtn";
	MiniworkDownBtnReporePostion(downBtnUI, map);
end

--存档条功能按钮
function MapFuncBtn_OnClick(funcBtnUi, map, options, frameName, isFromSearch)
	--在"我的订阅"界面中点击下载, 有个地图总是提示display_rank为nil, 于是加了下面一句.
	map.display_rank = map.display_rank or 0;

	Log("MapFuncBtn_OnClick btn="..funcBtnUi:GetName().."  display_rank:"..map.display_rank.."  author_uin:"..map.author_uin);

	options = options or {};

	if funcBtnUi and map then
		HeadFrameCtrl:SaveFrameIdByUin(map.author_uin,map.author_frame_id);
        if getglobal(funcBtnUi:GetName().."Name1"):IsShown() then  --下载
            --MiniWorksArchiveInfoFrame	弃用改成ArchiveInfoFrameEx
            if frameName and frameName == "ArchiveInfoFrameEx" then
                local cid = map and map.owid and tostring(map.owid) or "0"
                ArchiveInfoFrameExFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "MapDownload", "click", {cid = cid}, true)

                local state = GetMapDownloadBtnState(map)
                if state.progress > 0 then
                    ArchiveInfoFrameExFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "MapDownload", "map_continue", {cid = cid}, true)
                else
                    ArchiveInfoFrameExFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "MapDownload", "map_download", {cid = cid}, true)
                end
			end
			if frameName and frameName == "MiniWorksFrameChosen" and not isFromSearch then
				local type = GetCurFrameSubPageSwitchBtnIdx(CurLabel)
				local state = GetMapDownloadBtnState(map)
				if state.progress > 0 then
					standReportEvent("3",reportWorksCardName[6+type],"DownloadButton","map_continue",{cid=tostring(map.owid),slot=tostring(options.slot)})
				else 
					standReportEvent("3",reportWorksCardName[6+type],"DownloadButton","map_download",{cid=tostring(map.owid),slot=tostring(options.slot)})
				end
			end
			local verify = BreakLawMapControl:VerifyMapID(map.owid);
			if verify == 1 then
				ShowGameTips(GetS(10559), 3);
				return;
			elseif verify == 2 then
				ShowGameTips(GetS(3632), 3);
				return;
			end

            local download_fail = false
			if getglobal("MiniWorksFrame"):IsShown() then
				if map.display_rank == 2 and mapservice.net_flow.wait and mapservice.net_flow.wait > 0 then
					MessageBox(20, GetS(1064), function(btn)
						if btn == 'left' then		--联机玩
							SearchSelectRoomOWByUin(map.author_uin, map.owid, map);
						elseif btn == 'right' then	--排队下载
							options.statisticsDownload = true;
                            if not DownloadMap(map, options) then
                                download_fail = true
                            end
						end
					end)
				else
					options.statisticsDownload = true;
					if not DownloadMap(map, options) then
                        download_fail = true
                    end
				end
			else
				if not DownloadMap(map, options) then
                    download_fail = true
                end
            end

			local supportlang = map.translate_supportlang or 0;
			local sourcelang  = map.translate_sourcelang or 0;
			if supportlang - math.pow(2, sourcelang) <= 0 then
				supportlang = -1;
			end

			MapDownloadReportMgr:TryReportMapDownload(map.owid,supportlang);

			--下载设置来源
			MiniworkDownBtnReporePostion(funcBtnUi:GetName(), map);
			--工坊搜索新增埋点
			if getglobal("MiniWorksFrame"):IsShown() then
				if getglobal("MiniWorksFrameSearch1"):IsShown() and IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.SEARCH) then
					-- statisticsGameEventNew(41111, "download",AccountManager:getUin(),map.owid)
				elseif  IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.SEARCH) then
					-- statisticsGameEventNew(41109, "download",AccountManager:getUin(),map.owid)
				end
			end
        elseif getglobal(funcBtnUi:GetName().."Name2"):IsShown() then  --进入
            --mark by liya 新埋点
            if frameName and frameName == "ArchiveInfoFrameEx" or frameName == "MiniWorksFrameChosen" then
				local cid = map and map.owid and tostring(map.owid) or "0"
				GetInst("RoomService"):AsynReqMapPlayerCount({cid})
				local appendTraceID = nil
				local compId = "SinglePlayer"
				if options.rptCompId then
					compId = options.rptCompId
				end
				if frameName == "ArchiveInfoFrameEx" then
					appendTraceID = ArchiveInfoFrameExFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", compId, "click", {cid = cid})
				elseif frameName == "MiniWorksFrameChosen" then
					local type = GetCurFrameSubPageSwitchBtnIdx(CurLabel)
					standReportEvent("3",reportWorksCardName[6+type],compId,"click",{cid=tostring(map.owid),slot=tostring(options.slot)})
				end

                local hundredNum, tenNum, singleNum = 0, 1, 0
                -- 是自己图
                if map and map.author_uin == AccountManager:getUin() then
                    hundredNum = 1
                else
                    hundredNum = 2
                end

                if map then
                    -- local gameLabel = map.label
                    -- if gameLabel == 0 then
                    --     gameLabel = GetLabel2Owtype(map.worldtype)
                    -- end

                    -- -- 冒险模式
                    -- if gameLabel == 2 then
                    --     singleNum = 1
                    -- -- 创造模式
                    -- elseif gameLabel == 3 then
                    --     singleNum = 2
                    -- -- 开发者模式
                    -- else
                    --     singleNum = 3
                    -- end
                    singleNum = map.worldtype or map.label or 0
                end

                local standby1 = hundredNum * 100 + tenNum * 10 + singleNum
                -- game_open上报
                standReportGameOpenParam = {
                    cid         = tostring(cid),
					standby1    = tostring(standby1),
					sceneid     = "48",
					cardid		= "MINI_MAP_DETAIL_1",
					compid		= compId,
					trace_id    = appendTraceID,
				}
				if frameName == "MiniWorksFrameChosen" then
					local subPageBtnIdx = GetCurFrameSubPageSwitchBtnIdx(CurLabel)
					standReportGameOpenParam.sceneid = "3"
					standReportGameOpenParam.cardid = reportWorksCardName[6 + subPageBtnIdx]
					GetInst("ReportGameDataManager"):NewGameLoadParam("3",reportWorksCardName[6 + subPageBtnIdx], compId)
				else
					GetInst("ReportGameDataManager"):NewGameLoadParam("48","MINI_MAP_DETAIL_1", compId)
				end
				GetInst("ReportGameDataManager"):SetGameMapOwn(hundredNum)
				GetInst("ReportGameDataManager"):SetGameNetType(GetInst("ReportGameDataManager"):GetGameNetTypeDefine().singleMode)
				GetInst("ReportGameDataManager"):SetGameMapMode(singleNum)
			end
			local verify = BreakLawMapControl:VerifyMapID(map.owid);
			if verify == 1 then
				ShowGameTips(GetS(10561), 3);
				return;
			elseif verify == 2 then
				ShowGameTips(GetS(3632), 3);
				return;
			end

			if EnterDownloadedMap(map) then
				if getglobal("MiniWorksFrame"):IsShown() then
					EnterMainMenuInfo.EnterMainMenuBy = "MiniWork";
					EnterMainMenuInfo.MiWorkCurLabel = CurLabel;
					if HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
						EnterMainMenuInfo.CommendType = GetInst("UIManager"):GetCtrl("MiniWorksCommendDetail"):GetCommendType()
					end
				elseif getglobal("PlayerExhibitionCenter"):IsShown() then
					EnterMainMenuInfo.EnterMainMenuBy = "PlayerCenter";
				elseif getglobal("ArchiveDownload"):IsShown() then
					--从奥特曼活动窗口进入
					EnterMainMenuInfo.EnterMainMenuBy = "ArchiveDownload";
					GetInst("UIManager"):Close("ArchiveDownload")
				end

				-- fym 装扮换装改版需求：判断是否是从装扮详情页跳转至地图内，如果是则需要关闭装扮详情页和商城界面
				EnterGameFromShopSkinDisplay()
				
				local cInterface = GetInst("CreationCenterInterface")
				if cInterface and cInterface.EnterGameCloseCreationCenterFrames then
					cInterface:EnterGameCloseCreationCenterFrames()
				end

				GetInst("UIManager"):Close("CloudServerLobby")
				GetInst("UIManager"):Close("ComeBackEntrance") --关闭掉回流
				if getglobal("ArchiveInfoFrameEx"):IsShown() then
					GetInst("UIManager"):Close("ArchiveInfoFrameEx")
				end
				pcall(function()
					local worldListRecentlyOpened = AccountManager:getMyRecentlyOpenedWorldList()
					if worldListRecentlyOpened then
						worldListRecentlyOpened:saveRecentlyPlayedMap(map.owid, 0, map.download_thumb_url, "", map.name, CREAT_ROOM);
					end
				end)
				CloseRoomFrame()
				UIFrameMgr:hideAllFrame();
				ShowLoadingFrame();
			end

		elseif getglobal(funcBtnUi:GetName().."Name3"):IsShown() then  --暂停
            StopDownloadMap(map);

            --新埋点
            if frameName and frameName == "ArchiveInfoFrameEx" then
                local cid = map and map.owid and tostring(map.owid) or "0"
                ArchiveInfoFrameExFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "MapDownload", "map_pause", {cid = cid})
			end
			if frameName and frameName == "MiniWorksFrameChosen" then
				local type = GetCurFrameSubPageSwitchBtnIdx(CurLabel)
				standReportEvent("3",reportWorksCardName[6+type],"DownloadButton","map_pause",{cid=tostring(map.owid),slot=tostring(options.slot)})
			end
		end
	end
end

function WorksArchiveTemplateFuncBtn_OnClick()
	local archui = this:GetParentFrame();
	local function checkUI(archui)
		if archui then
			local archindex = archui:GetClientID();
			MapDownloadReportMgr:SetMiniWorkHomepageSubType(archui:GetName())
			

			Log("WorksArchiveTemplateFuncBtn_OnClick");
			
			local map, isSearchResult = GetMapFromArchiveUi(archui);

			if map then
				if HandleGmMapCommands(map) then  --处理gm命令
					return;
				end

				local funcBtnUi = getglobal(archui:GetName().."FuncBtn");

				-- if isSearchResult then					
				-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):StandReportMapContentClick(map.owid, true, getglobal(funcBtnUi:GetName().."Name1"):IsShown())
				-- end
				
				local num = 0              					--玩家地图存档的最大数目
				local archiveNum = 0;						--当前的存档数量
				local uin = AccountManager:getUin()
				if map.author_uin == uin then
					--LLDO:自己的
					-- archiveNum = AccountManager:getMyWorldList():getMyCreateWorldNum();		--已创建的存档数
					-- num = GetCreateMapMax();												--自己可以创建多少存档
					archiveNum = GetCreateArchiveNum()
					num = CreateArchiveMaxNum()
				else
					--下载的存档数量
					-- archiveNum = AccountManager:getMyWorldList():getDownWorldNum();			--已下载的存档数量
					-- num = DownMapMaxNum();													--可以下载多少存档(别人的)
					archiveNum = GetDownArchiveNum()
					num = DownArchiveMaxNum()
				end
				local btnstate = GetMapDownloadBtnState(map);
				
				if archiveNum >= num  and not getglobal(funcBtnUi:GetName().."Name2"):IsShown() 
					and btnstate.buttontype ~= DOWNBTN_PAUSE_DOWNLOAD and btnstate.buttontype ~= DOWNBTN_CONTINUE_DOWNLOAD then 
					--可以[Desc5]则先弹[Desc5]的窗口
					if map.author_uin == uin and CanShowNotEnoughArchiveWithOperate(function () checkUI(archui) end) then
						return
					end
					
			        local text = GetS(10);
			        MessageBox(4, text);
					return;
			    end
				MapFuncBtn_OnClick(funcBtnUi, map, {fromUiLabel=CurLabel, fromUiPart=nil,slot=archindex},"MiniWorksFrameChosen", isSearchResult);

				--下载上报
				--m_ExposureParam:HandleDownLoadClick(this:GetName());
			end
		end
	end
	checkUI(archui)
end

function MiniWorksFrameSetBlackBtn_OnClick()
	nextMapSetBlack = true;
end

function MiniWorksFrameCancelBlackBtn_OnClick()
	nextMapCancelBlack = true;
end

function MiniWorksFrameSetChosenBtn_OnClick()
	nextMapSetChosen = true;
end

function MiniWorksFrameCancelChosenBtn_OnClick()
	nextMapCancelChosen = true;
end

function MiniWorksFrameCopyOwidBtn_OnClick()
	nextMapCopyOwid = true;
end

function MiniWorksFrameGmReviewBtn_OnClick()
	MiniworksGotoLabel(2);
end

--筛选对话框 确认
function MiniWorksFrame_SetFilter(label, order)
	Log("MiniWorksFrame_SetFilter: "..label..", "..order);

	if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP) then
		--MiniWorksFrameChosen_SetFilter(label, order);
		--精选(1)和玩家(3)两个label合成了一个地图label(1)
		local subPageBtnIdx = GetMiniWorksFrame_GetMapFrameIdx()

		if subPageBtnIdx == 1 then
			MiniWorksFrameConnoisseur_SetFilter(label, order);
		elseif subPageBtnIdx == 2 then
			--精选
			MiniWorksFrameChosen_SetFilter(label, order);
		elseif subPageBtnIdx == 3 then
			--玩家
			MiniWorksFramePlayer_SetFilter(label, order);
		elseif subPageBtnIdx == 4 then 
			--助审
			MiniWorksFrameReview_SetFilter(label, order);
		end
		--[[
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.REVIEW) then
		MiniWorksFrameReview_SetFilter(label, order);
		]]
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.SELF_CENTER) then
		--注意现在CurLabel=3不代表玩家
		--MiniWorksFramePlayer_SetFilter(label, order);
	elseif IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.COLLECT) then
		MiniWorksFrameCollect_SetFilter(label, order);
	end
end

--显示地图详情对话框
function ShowMapDetail(map, options)
	if map then
		ShowMiniWorksMapDetail(map)
	end
end

--tsetgjd
--迷你工坊
local checkdelayminiwork = true
function MiniWorksFrame_BuriedDatapoints()
	if checkdelayminiwork == true then
		local playeractive = AccountManager:get_active_days();
		local playermod = nil
		if playeractive >= 2 then
			playermod = 1
		else 
			playermod = 0
		end 
		-- statisticsGameEventNew(56103, AccountManager:getUin(),playermod)
		checkdelayminiwork = false;
		threadpool:work(function()
			threadpool:wait(300);
			checkdelayminiwork = true;
		end)
	end
end

-------------------------------------------------------------MiniWorksFrameMain---------------------------------------------------------

local mainFrameFirstShow = true;

local Section_Archive_Max = 20;

--“每日精选”等头部的高
local section_header_h = 45;
local section_heights = {};

local indicator_num = 5;

local curPictureIndex = 1;
local curPictureTime = 0;

--首页
function MiniWorksFrameMain_OnShow()
	Log("MiniWorksFrameMain_OnShow");

	ReqMainPageData();

	if mainFrameFirstShow then
		mainFrameFirstShow = false;
		
		UpdateSectionLayout("MainArchiveBoxSectionWeeklyMaps");		 --weekly:每周推荐
		UpdateSectionLayout("MainArchiveBoxSectionConnoisseurMaps"); --鉴赏家推荐
		UpdateSectionLayout("MainArchiveBoxSectionLatestMaps");		 --最新精选, 地图条目布局
		UpdateSectionLayout("MainArchiveBoxSectionHotMaps");		 --当前热门
		UpdateSectionLayout("MainArchiveBoxSectionRecommend");		 --编辑推荐	--
		UpdateSectionLayout("MainArchiveBoxFeaturedGameplay");      --精选玩法
		UpdateSectionLayout("MainArchiveBoxOptimalConnoisseurMaps");      --鉴赏家优选

		-- ui改版，小图标删除
		-- getglobal("MainArchiveBoxSectionLatestMapsHeaderIcon"):SetTexUV("mngfg_icon015");	--小标题图标,最新精选->精彩推荐
		-- getglobal("MainArchiveBoxSectionHotMapsHeaderIcon"):SetTexUV("mngfg_icon016");		--当前热门
		--getglobal("MainArchiveBoxSectionRecommendHeaderIcon"):SetTexUV("mngfg_icon015");	--编辑推荐	--样式变了

		--分割线的长度要根据中英文而改变, 不然英文的会盖住字. -- ui改版，横线删除
		-- if isAbroadEvn() then
		-- 	local line = getglobal("MainArchiveBoxSectionLatestMapsHeaderLine");
		-- 	line:SetWidth(810);
		-- 	line:SetPoint("left", "MainArchiveBoxSectionLatestMapsHeaderBkg", "left", 230, 0);

		-- 	line = getglobal("MainArchiveBoxSectionHotMapsHeaderLine");
		-- 	line:SetWidth(810);
		-- 	line:SetPoint("left", "MainArchiveBoxSectionHotMapsHeaderBkg", "left", 230, 0);
		-- end
	else
		UpdateWeeklyMaps();		--每周推荐,weekly.
		UpdateLatestMaps();
		UpdateHotMaps();
		UpdateRecommendMaps();
		UpdateFeaturedGameplayMaps();
	end

	curPictureTime = 0;
end

function MiniWorksFrameMain_OnHide()
	ShowLoadLoopFrame(false)
	CancelAllDownloadingThumbnails();
end

function MiniWorksFrameMain_OnUpdate()
	local deltatime = arg1;
	if curPictureIndex then
		curPictureTime = curPictureTime + deltatime;
		local pictureData = mapservice.mainPictures[curPictureIndex];
		if pictureData then
			if curPictureTime > pictureData.staytime then  --自动切到下一个图片
				MainArchiveBoxPublicityRightBtn_OnClick();
			end
		end
	end
end

----------------------- pictures -----------------------

function MiniWorksFrameMain_OnPicturesPulled()
	Log("pictures pulled");
	getglobal("MainArchiveBoxPublicity"):Show();
	MiniWorksFrameMain_SwitchPicture(curPictureIndex);
end

function MainArchiveBoxPublicityLeftBtn_OnClick()
	MiniWorksFrameMain_SwitchPicture(curPictureIndex - 1);
end

function MainArchiveBoxPublicityRightBtn_OnClick()
	MiniWorksFrameMain_SwitchPicture(curPictureIndex + 1);
end

function MainArchiveBoxPublicityCenterBtn_OnClick()
	Log("MainArchiveBoxPublicityCenterBtn_OnClick: "..curPictureIndex);

	local pictureData = mapservice.mainPictures[curPictureIndex];
	if pictureData then
		local jump_type = pictureData.jump_type;  --1=存档 2=专题
		local jump_id = pictureData.jump_id;
		if jump_type == 1 then
			JumpToShowSingleMap(jump_id, curPictureIndex);
		elseif jump_type == 2 then
			JumpToTopic(jump_id);
		elseif jump_type == 18 then
			MiniworksGotoLabel(8);
		end

		-- statisticsGameEvent(402, '%d', curPictureIndex);
	end
end


local statistics_403 = {}   --打开游戏只上报一次

function MiniWorksFrameMain_SwitchPicture(index)
	Log("MiniWorksFrameMain_SwitchPicture "..index);

	local count = #mapservice.mainPictures;
	index = (index-1)%count + 1;

	curPictureIndex = index;
	curPictureTime = 0;

	-- if  not statistics_403[ index ] then
	-- 	statisticsGameEvent(403, "%d", index);
	-- 	statistics_403[ index ] = 1
	-- end

	local pic_ui_names = {"MainArchiveBoxPublicityPicLeft", "MainArchiveBoxPublicityPicCenter", "MainArchiveBoxPublicityPicRight"};
	local btn_ui_names = {"MainArchiveBoxPublicityLeftBtn", "MainArchiveBoxPublicityCenterBtn", "MainArchiveBoxPublicityRightBtn"};
	local pic_indices = {(index-1-1)%count + 1, index, (index+1-1)%count + 1};

	for i = 1, 3 do

		local pic_ui_name = pic_ui_names[i];
		local btn_ui_name = btn_ui_names[i];

		local pictureData = mapservice.mainPictures[pic_indices[i]];
		if pictureData then
			getglobal(btn_ui_name):Show();
			getglobal(pic_ui_name):Show();
			getglobal(pic_ui_name):SetTexture("ui/mobile/texture2/bigtex/ckjm_diban04.png");
			local cachePath = "data/http/thumbs/"..GetCacheFileNameFromUrl(pictureData.url);
			DownloadThumbnail({pictureData.url}, cachePath, pic_ui_name, nil);
		else
			getglobal(btn_ui_name):Hide();
			getglobal(pic_ui_name):Hide();
		end
	end

	for i = 1,indicator_num do
		if i == curPictureIndex then
			getglobal("MainArchiveBoxPublicityIndicator"..i):SetTexUV("mngf_icon10");
		else
			getglobal("MainArchiveBoxPublicityIndicator"..i):SetTexUV("mngf_icon11");
		end
	end
end

--跳转
function JumpToShowSingleMap(owid, curPictureIndex)
	Log("JumpToShowSingleMap "..owid..", "..curPictureIndex);
	ReqMapInfo({owid}, RespJumpToShowSingleMap, curPictureIndex);
end

function RespJumpToShowSingleMap(maps, pictureIndex)
	local map = maps[1];
	ShowMapDetail(map, {fromUiLabel=CurLabel, fromUiPart='main_pictures_'..pictureIndex});
end

local jumpingTopicId = nil;

function JumpToTopic(topic_id)
	if topic_id then
		jumpingTopicId = topic_id;
		ReqTopicList();
	end
end

function IsJumpingToTopic()
	return iif(jumpingTopicId, true, false);
end

function RespJumpToTopic()
	if jumpingTopicId then
		for i = 1, #mapservice.topics do
			if mapservice.topics[i].id == jumpingTopicId then
				jumpingTopicId = nil;
				MiniworksGotoLabel(4);
				JumpToTopicByIndex(i);
				break;
			end
		end
	end
end

----------------------- special maps -----------------------
--LLDO:设置首页横线的长度(随不同的的语言调整) --ui改版，横线删除
function MiniworksMain_SetHorizonLineSize(textName)
	-- Log("MiniworksMain_SetHorizonLineSize:");
	-- if textName then
	-- 	Log("textName = " .. textName);
	-- 	local HeaderText = getglobal(textName);
	-- 	local parentObj = HeaderText:GetParentFrame();

	-- 	local parentName = parentObj:GetName();
	-- 	Log("parentName = " .. parentName);

	-- 	local headerLine = getglobal(parentName .. "HeaderLine");
		
	-- 	local HeaderTextWidth = HeaderText:GetTextExtentWidth(HeaderText:GetText());
	-- 	Log("HeaderTextWidth = " .. HeaderTextWidth);

	-- 	local xOffset = HeaderTextWidth + 50;
	-- 	headerLine:SetPoint("left", parentName .. "HeaderBkg", "left", xOffset, 0);
	-- end
end

function MiniWorksFrameMain_OnLatestMapsPulled()
	UpdateLatestMaps();
	getglobal("MainArchiveBoxSectionLatestMapsHeaderText"):SetText(mapservice.mainLatestMapsTitle);

	MiniworksMain_SetHorizonLineSize("MainArchiveBoxSectionLatestMapsHeaderText");
end
function UpdateLatestMaps()
	UpdateSectionMaps("MainArchiveBoxSectionLatestMaps", mapservice.mainLatestMaps);
	UpdateMainLayout();
end
function MainArchiveBoxSectionLatestMapsRefresh_OnClick()
	if CanRefreshWorksByServer() then
		ReqMainLatestMaps();
	else
		MiniWorksFrameMain_OnLatestMapsPulled();
	end
end

--LLDO:每周推荐,weekly, 拉取地图成功后响应UI.
function MiniWorksFrameMain_OnWeeklyMapsPulled()
	Log("MiniWorksFrameMain_OnWeeklyMapsPulled:");
	UpdateWeeklyMaps();
	getglobal("MainArchiveBoxSectionWeeklyMapsHeaderText"):SetText(mapservice.mainWeeklyMapsTitle);

	MiniworksMain_SetHorizonLineSize("MainArchiveBoxSectionWeeklyMapsHeaderText");
end
function UpdateWeeklyMaps()
	Log("UpdateWeeklyMaps:");
	UpdateSectionMaps("MainArchiveBoxSectionWeeklyMaps", mapservice.mainWeeklyMaps);
	UpdateMainLayout();
end
function MainArchiveBoxSectionWeeklyMapsRefresh_OnClick()	--刷新按钮点击.
	if CanRefreshWorksByServer() then
		ReqMainWeeklyMaps();
	else
		MiniWorksFrameMain_OnWeeklyMapsPulled();
	end
end

function MiniWorksFrameMain_OnConnoisseurMapsPulled()
	Log("MiniWorksFrameMain_OnConnoisseurMapsPulled:");
	UpdateConnoisseurMaps();
	getglobal("MainArchiveBoxSectionConnoisseurMapsHeaderText"):SetText(mapservice.mainExpertMapsTitle);

	MiniworksMain_SetHorizonLineSize("MainArchiveBoxSectionConnoisseurMapsHeaderText");
end

function UpdateConnoisseurMaps()
	Log("UpdateConnoisseurMaps:");
	UpdateSectionMaps("MainArchiveBoxSectionConnoisseurMaps", mapservice.mainExpertMaps);
	UpdateMainLayout();
end

function MainArchiveBoxSectionConnoisseurMapsRefresh_OnClick()
	if CanRefreshWorksByServer() then
		ReqMainExpertMaps();
	else
		MiniWorksFrameMain_OnConnoisseurMapsPulled();
	end
end

function MiniWorksFrameMain_OnHotMapsPulled()
	UpdateHotMaps();
	getglobal("MainArchiveBoxSectionHotMapsHeaderText"):SetText(mapservice.mainHotMapsTitle);

	MiniworksMain_SetHorizonLineSize("MainArchiveBoxSectionHotMapsHeaderText");
end
function UpdateHotMaps()
	UpdateSectionMaps("MainArchiveBoxSectionHotMaps", mapservice.mainHotMaps);
	UpdateMainLayout();
end
function MainArchiveBoxSectionHotMapsRefresh_OnClick()
	if CanRefreshWorksByServer() then
		ReqMainHotMaps();
	else
		MiniWorksFrameMain_OnHotMapsPulled();
	end
end

----------------------- recommends -----------------------

function MiniWorksFrameMain_OnRecommendsUpdated()
	UpdateRecommendMaps();	--去掉编辑推荐
	getglobal("MainArchiveBoxSectionRecommendHeaderText"):SetText(mapservice.mainRecommendTitle);
end

function UpdateRecommendMaps()
	UpdateSectionMaps("MainArchiveBoxSectionRecommend", mapservice.mainRecommendMaps);
	UpdateMainLayout();
end

function MainArchiveBoxSectionRecommendRefresh_OnClick()
	if CanRefreshWorksByServer() then
		ReqMainRecommendMaps();
	else
		MiniWorksFrameMain_OnRecommendsUpdated();
	end
end

----------------------- daily -----------------------

local nextPullDailyIndex = 1;

function MiniWorksFrameMain_OnDailyPulled(index)
	--[[每日精选
	local daily = mapservice.mainDaily[index];

	UpdateSectionMaps("MainArchiveBoxSectionDaily"..index, daily.maps);

	getglobal("MainArchiveBoxSectionDaily"..index.."HeaderText"):SetText(daily.title);

	if index < #mapservice.mainDaily then
		getglobal("MainArchiveBoxMoreMap"):Show();
	else
		getglobal("MainArchiveBoxMoreMap"):Hide();
	end

	UpdateMainLayout();

	if nextPullDailyIndex < index + 1 then
		nextPullDailyIndex = index + 1;
	end
	]]
end

function MainArchiveBoxMoreMap_OnClick()
	ReqMainDaily(nextPullDailyIndex);
end

function MainArchiveBox_OnMoveFinished()
	-- MainArchiveBoxMoreMap_OnClick();
end

----------------------- common -----------------------

function UpdateSectionMaps(section_ui_name, maps)
	Log("UpdateSectionMaps "..section_ui_name);
	if (maps==nil) or (#maps==0) or (GetNetworkState() == 0) then
		getglobal(section_ui_name):Hide();
	else
		getglobal(section_ui_name):Show();
	end

	local realcount = 0;

	local newVersion = false
	if SetAndGetABTest and SetAndGetABTest("exp_gf_home_xiaolong") and  string.find(section_ui_name, "PlayerArchiveBoxPlayerMaps") then
		newVersion = true
	end

	for i = 1, 100 do
		if not HasUIFrame(section_ui_name.."Archive"..i) then
			break;
		end

		local archui = getglobal(section_ui_name.."Archive"..i);
		if newVersion then
			if maps and i <= #(maps) and i<=8 then
				realcount = i;
				MapShowIndex.UpdateSectionMaps = MapShowIndex.UpdateSectionMaps or 0
				local maxNum = #(maps)
				MapShowIndex.UpdateSectionMaps = MapShowIndex.UpdateSectionMaps % maxNum + 1
				local map = maps[MapShowIndex.UpdateSectionMaps];
				archui:Show();
				if string.find(section_ui_name, "ConnoisseurMaps") then
					UpdateSingleConnoisseurArchive(archui, map, true);
				else	
					-- hideRankTag=true/false决定显不显示tagName(精选/人气等)
					UpdateSingleArchive(archui, map, {hideRankTag=false});
				end
			else
				archui:Hide();
				if string.find(section_ui_name, "ConnoisseurMaps") then
					UpdateSingleConnoisseurArchive(archui, nil);
				else
					UpdateSingleArchive(archui, nil);
				end
			end
		else
			if maps and i <= #(maps) then
				realcount = i;
				local map = maps[i];
				archui:Show();
				if string.find(section_ui_name, "ConnoisseurMaps") then
					UpdateSingleConnoisseurArchive(archui, map, true);
				else	
					-- hideRankTag=true/false决定显不显示tagName(精选/人气等)
					UpdateSingleArchive(archui, map, {hideRankTag=false});
				end
			else
				archui:Hide();
				if string.find(section_ui_name, "ConnoisseurMaps") then
					UpdateSingleConnoisseurArchive(archui, nil);
				else
					UpdateSingleArchive(archui, nil);
				end
			end
		end
	end

	local archiveHeight = SingleArchiveHeight;
	local col = 2;
	if string.find(section_ui_name, "ConnoisseurMaps") then
		archiveHeight = 346;
		col = 4;
	end
	totalHeight = section_header_h + math.ceil(realcount / col) * archiveHeight + 8;

	section_heights[section_ui_name] = totalHeight;

	--获取宽
	local section_width = getglobal(section_ui_name):GetWidth();
	getglobal(section_ui_name):SetSize(section_width, totalHeight);
end

function UpdateSectionLayout(section_ui_name)
	for i = 1, 999 do
		if not HasUIFrame(section_ui_name.."Archive"..i) then
			break;
		end

		local archive = getglobal(section_ui_name.."Archive"..i);

		if string.find(section_ui_name, "ConnoisseurMaps") then --鉴赏家
			local row = math.floor((i - 1) / 4);  --starts at 0
			local col = (i-1)%4;
			archive:SetPoint("topleft", section_ui_name, "topleft", col*270 + 13, section_header_h+row*346);
		else
			local row = math.floor((i - 1) / 2);  --starts at 0

			if (i-1)%2 == 0 then
				archive:SetPoint("topright", section_ui_name, "top", -8, section_header_h + 4 + row*SingleArchiveHeight);
			else
				archive:SetPoint("topleft", section_ui_name, "top", 8, section_header_h + 4 + row*SingleArchiveHeight);
			end
		end

		archive:Hide();
	end
end

function UpdateMainLayout()
	Log("UpdateMainLayout");

	--去掉每日精选和更多地图按钮
	local layout_uis = {
		"MainArchiveBoxSectionWeeklyMaps",	--weekly,每周推荐
		"MainArchiveBoxSectionConnoisseurMaps",
		"MainArchiveBoxSectionLatestMaps",
		"MainArchiveBoxSectionHotMaps",
		"MainArchiveBoxSectionRecommend",	--去掉编辑推荐
		"MainArchiveBoxFeaturedGameplay",      --精选玩法
		"MainArchiveBoxOptimalConnoisseurMaps", --鉴赏家优选

	};

	local plane_name = "MainArchiveBoxPlane";

	--Publicity的高+间距
	local y = 140 + 18;

	for i=1,#layout_uis do

		local ui_name = layout_uis[i];

		local ui_obj = getglobal(ui_name);

		ui_obj:SetPoint("top", plane_name, "top", 0, y);

		if ui_obj:IsShown() then
			y = y + ui_obj:GetHeight() + 14;
		end

		local ui_obj_mapbkg = getglobal(layout_uis[i] .. "MapBkg");
		ui_obj_mapbkg:SetSize(ui_obj:GetWidth(), ui_obj:GetHeight() - 36);
	end
	--获取plane宽
	local plane_width = getglobal(plane_name):GetWidth();
	local totalHeight = y;
	local containerHeight = getglobal("MainArchiveBox"):GetRealHeight();
	totalHeight = clamp(totalHeight, containerHeight, nil);
	getglobal(plane_name):SetSize(plane_width, totalHeight);
end

-----------------------------------------------------------MiniWorksFrameConnoisseur------------------------------------------------------
function ConnoisseurInfo_OnClick()
	local uin = tonumber(this:GetClientString());
	print("kekeke ConnoisseurInfo_OnClick", uin);
	SearchPlayerByUin(uin);
end

function ConnoisseurArchiveTemplate_OnClick()

	local uiName = this:GetName();
	local index = this:GetClientID();
	WorksArchiveMsgCheck.archindex = index;
	local map = nil;

	local commentUin = nil;
	if string.find(uiName, "CenterConnoisseurArchive") then
		map = mapservice.searchExpertMaps[index];
		commentUin = ns_playercenter.op_uin;
	elseif string.find(uiName, "ConnoisseurArchive") then
		local newVersion = SetAndGetABTest and SetAndGetABTest("exp_gf_home_xiaolong")
		if newVersion then
			local realIndex = 8 - index
			if MapShowIndex.UpdateConnoisseurArchive - realIndex > 0 then
				index = MapShowIndex.UpdateConnoisseurArchive - realIndex
			else
				index = #mapservice.expertMaps + MapShowIndex.UpdateConnoisseurArchive - realIndex
			end
		end	
		map = mapservice.expertMaps[index];
		--在地图详情数据里面插入点赞数量数据
		if map and map.owid then
			local tempMap = mapservice.mapInfoCache[map.owid]
			if tempMap and tempMap.like then
				map.like = tempMap.like
			end
		end

		if map then 
			commentUin = map.push_comments[1] and map.push_comments[1].uin or nil;
		end 
	elseif string.find(uiName, "SectionConnoisseurMapsArchive") then
		MapDownloadReportMgr:SetMiniWorkHomepageSubType(uiName);
		map = mapservice.mainExpertMaps[index];	
		if map then 
			commentUin = map.push_comments[1] and map.push_comments[1].uin or nil;
		end 
	elseif string.find(uiName, "OptimalConnoisseurMapsArchive") then
		map = mapservice.mainOptimalMaps[index];
		if map then 
			commentUin = map.push_comments[1] and map.push_comments[1].uin or nil;
		end 
	end

	if map then
		standReportEvent("3",reportWorksCardName[7],"DescribeCard","click",{cid=tostring(map.owid),slot=tostring(index)})
		local verify = BreakLawMapControl:VerifyMapID(map.owid);
		if verify == 1 then
			ShowGameTips(GetS(10565), 3);
			return;
		elseif verify == 2 then
			ShowGameTips(GetS(3636), 3);
			return;
		end

		WorksArchiveMsgCheck.mapinfo = map;

		ShowMiniWorksMapDetail(map, nil, commentUin);

		--点击上报
		m_ExposureParam:HandleClick(this:GetName(), 2);
	end
end

function MiniWorksFrameConnoisseurFilter_OnClick()
	getglobal("ConnoisseurArchiveBox"):setDealMsg(false);
	ShowArchiveFilterFrame(Connoisseur_CurLabel, Connoisseur_CurOrder, mapservice.expertOrderNames, 1);
end

function MiniWorksFrameConnoisseurFilter2_OnClick()
	getglobal("ConnoisseurArchiveBox"):setDealMsg(false);
	ShowArchiveFilterFrame(Connoisseur_CurLabel, Connoisseur_CurOrder, mapservice.expertOrderNames, 2);
end

function MiniWorksFrameConnoisseurRefresh_OnClick()
	ReqExpertMaps(Connoisseur_CurLabel, Connoisseur_CurOrder, true);
	standReportEvent("3",reportWorksCardName[7],"Refresh","click")
end

function MiniWorksFrameConnoisseur_OnLoad()
 	
end

function MiniWorksFrameConnoisseur_OnShow()
	local planeWidth = getglobal("ConnoisseurArchiveBoxPlane"):GetRealWidth();
	local width = 256;
	local offsetX = 10;
	local offsetXList = {-(5 + 256 + 10 + 256 / 2), -(5 + 256 / 2), (5 + 256 / 2), (5 + 256 + 10 + 256 / 2)};
	for i=1, Connoisseur_Archive_Max/4 do
 		for j=1, 4 do
 			local index = j+(i-1)*4;
 			local archui = getglobal("ConnoisseurArchive"..index);
 			archui:SetPoint("top", "ConnoisseurArchiveBoxPlane", "top", offsetXList[j], (i-1)*337)
 		end
 	end

	if next(mapservice.expertMaps) == nil then
		ReqExpertMaps(Connoisseur_CurLabel, Connoisseur_CurOrder, true);
	end 

	UpdateConnoisseurArchive();

	UpdateFilterName(6);
end

function MiniWorksFrameConnoisseur_OnHide()
	-- body
end

function MiniWorksFrameExpert_OnExpertMapsPulled(isrefresh)
	if isrefresh then
		getglobal("ConnoisseurArchiveBox"):resetOffsetPos();
	end

	UpdateConnoisseurArchive();

	if getglobal("MiniWorksFrame"):IsShown() and getglobal("ArchiveInfoFrameIntroduce"):IsShown() and CurArchiveMap ~= nil then
		UpdateShareArchiveInfoIntroduce();
	end
end

function UpdateConnoisseurArchive()
	if #mapservice.expertMaps == 0 then
		getglobal("MiniWorksFrameMapTipsFrame"):Show();
	else
		getglobal("MiniWorksFrameMapTipsFrame"):Hide();
	end
	local newVersion = false
	if SetAndGetABTest and SetAndGetABTest("exp_gf_home_xiaolong") then
		newVersion = true
	end

	for i=1, Connoisseur_Archive_Max do
		local archui = getglobal("ConnoisseurArchive"..i);
		if newVersion then
			if i <= #(mapservice.expertMaps) and i <= 8 then
				MapShowIndex.UpdateConnoisseurArchive = MapShowIndex.UpdateConnoisseurArchive or 0
				local maxNum = #(mapservice.expertMaps)
				MapShowIndex.UpdateConnoisseurArchive = MapShowIndex.UpdateConnoisseurArchive % maxNum + 1
				local map = mapservice.expertMaps[MapShowIndex.UpdateConnoisseurArchive];
				archui:Show();
				UpdateSingleConnoisseurArchive(archui, map, true);
			else
				archui:Hide();
				UpdateSingleConnoisseurArchive(archui,nil);
			end
		else
			if i <= #(mapservice.expertMaps) then
				local map = mapservice.expertMaps[i];
				archui:Show();
				
				UpdateSingleConnoisseurArchive(archui, map, true);
			else
				archui:Hide();
				UpdateSingleConnoisseurArchive(archui,nil);
			end
		end
	end

	local lines = math.ceil(#(mapservice.expertMaps)/4);
	if newVersion then
		local temp = #mapservice.expertMaps >= 8 and 8 or #mapservice.expertMaps
		lines = temp/4
	end
	local height = lines * 346;
	local boxHeight = getglobal("ChosenArchiveBox"):GetRealHeight();
	height = height > boxHeight and height or boxHeight;

	getglobal("ConnoisseurArchiveBoxPlane"):SetHeight(height);
end

function ConnoisseurArchiveBox_OnMovieFinished(  )
	-- body
end

function MiniWorksFrameConnoisseur_SetFilter(label, order)
	Log("MiniWorksFrameConnoisseur_SetFilter: "..label..", "..order);
	if label ~= Connoisseur_CurLabel or order ~= Connoisseur_CurOrder then
		if label ~= Connoisseur_CurLabel then
			standReportEvent("3", "MINI_WORKSHOP_MAPREC_1", "ContentComboBox", "click", {standby1=tostring(label)})
		else
			standReportEvent("3", "MINI_WORKSHOP_MAPREC_1", "RankComboBox", "click", {standby1=tostring(order)})
		end
		
		Connoisseur_CurLabel = label;
		Connoisseur_CurOrder = order;

		ReqExpertMaps(Connoisseur_CurLabel, Connoisseur_CurOrder, true);

		Log("Connoisseur_CurOrder = "..type(Connoisseur_CurOrder)..", "..Connoisseur_CurOrder);

		UpdateFilterName(6);
		WorksFilterStatistics(6, label, order);
		
	end
end
-------------------------------------------------------------MiniWorksFrameChosen---------------------------------------------------------

local chosenFrameFirstShow = true;

function MiniWorksFrameChosen_OnLoad()
	UpdateChosenArchive(0);
end

function MiniWorksFrameChosen_OnShow()

	if chosenFrameFirstShow then
		chosenFrameFirstShow = false;
		ReqChosenMaps(Chosen_CurLabel, Chosen_CurOrder, true);
	end

	UpdateChosenArchive(#(mapservice.chosenMaps));

	UpdateFilterName(1);
end

function MiniWorksFrameChosen_OnHide()
	ShowLoadLoopFrame(false)
	CancelAllDownloadingThumbnails();
end

function MiniWorksFrameChosen_OnChosenMapsPulled(num_pulled, isrefresh)
	if isrefresh then
		getglobal("ChosenArchiveBox"):resetOffsetPos();
	end

	UpdateChosenArchive(num_pulled);

	if getglobal("MiniWorksFrame"):IsShown() and getglobal("ArchiveInfoFrameIntroduce"):IsShown() and CurArchiveMap ~= nil then
		UpdateShareArchiveInfoIntroduce();
	end
end

function MiniWorksFrameChosenFilter_OnClick()
	ShowArchiveFilterFrame(Chosen_CurLabel, Chosen_CurOrder, mapservice.chosenOrderNames, 1);
end

function MiniWorksFrameChosenFilter2_OnClick()
    ShowArchiveFilterFrame(Chosen_CurLabel, Chosen_CurOrder, mapservice.chosenOrderNames, 2);
end

function MiniWorksFrameChosen_SetFilter(label, order)
	Log("MiniWorksFrameChosen_SetFilter: "..label..", "..order);
	if label ~= Chosen_CurLabel or order ~= Chosen_CurOrder then
		if label ~= Chosen_CurLabel then
			standReportEvent("3", "MINI_WORKSHOP_NICEMAP_1", "ContentComboBox", "click", {standby1=tostring(label)})
		else
			standReportEvent("3", "MINI_WORKSHOP_NICEMAP_1", "RankComboBox", "click", {standby1=tostring(order)})
		end
		Chosen_CurLabel = label;
		Chosen_CurOrder = order;

		ReqChosenMaps(Chosen_CurLabel, Chosen_CurOrder, true);

		Log("Chosen_CurOrder = "..type(Chosen_CurOrder)..", "..Chosen_CurOrder);

		--[[把“刷新”、“换一批”字样去掉
		if Chosen_CurOrder == 1 then
			getglobal("MiniWorksFrameChosenRefreshName"):SetText(GetS(3849));  --换一批
		else
			getglobal("MiniWorksFrameChosenRefreshName"):SetText(GetS(3853));  --刷新
		end
		--]]

		UpdateFilterName(1);
		WorksFilterStatistics(1, label, order);
	end
end

function MiniWorksFrameChosenRefresh_OnClick()
	if Chosen_CurOrder == 1 then  --换一批
		ReqChosenMaps(Chosen_CurLabel, Chosen_CurOrder, true);
	else  --刷新
		ReqChosenMaps(Chosen_CurLabel, Chosen_CurOrder, true);
	end
	standReportEvent("3",reportWorksCardName[8],"Refresh","click")
end

function ChosenArchiveBox_OnMovieFinished()
	if getglobal("ChosenArchiveBoxMoreMap"):IsShown() then
		if Chosen_CurOrder ~= 1 then  --更多地图
			ReqChosenMaps(Chosen_CurLabel, Chosen_CurOrder, false);
		end
	end
end

--更多地图
function ChosenArchiveBoxMoreMap_OnClick()
	if Chosen_CurOrder ~= 1 then
		ReqChosenMaps(Chosen_CurLabel, Chosen_CurOrder, false);
	end
end

--换一批
function ChosenArchiveBoxMoreMap2_OnClick()
	if Chosen_CurOrder == 1 then
		ReqChosenMaps(Chosen_CurLabel, Chosen_CurOrder, true);
	end
end

function UpdateChosenArchive(num_pulled)
	local newVersion = false
	if SetAndGetABTest and SetAndGetABTest("exp_gf_home_xiaolong") then
		newVersion = true
	end

	for i = 1, Chosen_Archive_Max do

		local archui = getglobal("ChosenArchive"..i);
		if newVersion then
			if i <= #(mapservice.chosenMaps) and i<=8 then
				archui:Show();
				MapShowIndex.UpdateChosenArchive = MapShowIndex.UpdateChosenArchive or 0
				local maxNum = #(mapservice.chosenMaps)
				MapShowIndex.UpdateChosenArchive = MapShowIndex.UpdateChosenArchive % maxNum + 1
				local map = mapservice.chosenMaps[MapShowIndex.UpdateChosenArchive];
				UpdateSingleArchive(archui, map, {hideRankTag=false});
			else
				archui:Hide();
				UpdateSingleArchive(archui, nil);
			end
		else
			if i <= #(mapservice.chosenMaps)  then
				local map = mapservice.chosenMaps[i];
				archui:Show();
				UpdateSingleArchive(archui, map, {hideRankTag=false});
			else
				archui:Hide();
				UpdateSingleArchive(archui, nil);
			end
		end
	end

	local plane = getglobal("ChosenArchiveBoxPlane");
	local totalHeight = math.ceil(#(mapservice.chosenMaps) / 2) * SingleArchiveHeight;
	if newVersion then
		local tempNum = #mapservice.chosenMaps >= 8 and 8 or #mapservice.chosenMaps
		totalHeight = math.ceil(tempNum / 2) * SingleArchiveHeight;
	end
	getglobal("ChosenArchiveBoxMoreMap"):SetPoint("top", "ChosenArchiveBoxPlane", "top", 0, totalHeight + 8);
	getglobal("ChosenArchiveBoxMoreMap2"):SetPoint("top", "ChosenArchiveBoxPlane", "top", 0, totalHeight + 8);
	getglobal("ChosenArchiveBoxMoreMapNotice"):SetPoint("top", "ChosenArchiveBoxPlane", "top", 0, totalHeight + 8);

	--无法加载更多地图
	if Chosen_CurOrder == 1 then
		getglobal("ChosenArchiveBoxMoreMap"):Hide();  --更多地图
		getglobal("ChosenArchiveBoxMoreMapNotice"):Hide();  --拉到底提示文字
		
		if (num_pulled~=nil and num_pulled<20) or #(mapservice.chosenMaps) >= Chosen_Archive_Max then  --换一批
			getglobal("ChosenArchiveBoxMoreMap2"):Hide();
		else
			--[[去掉底部的加载更多按钮
			getglobal("ChosenArchiveBoxMoreMap2"):Show();
			--]]
		end
	else
		getglobal("ChosenArchiveBoxMoreMap2"):Hide();  --换一批

		if (num_pulled~=nil and num_pulled<20) or #(mapservice.chosenMaps) >= Chosen_Archive_Max then  --更多地图
			getglobal("ChosenArchiveBoxMoreMap"):Hide();
			getglobal("ChosenArchiveBoxMoreMapNotice"):Show();  --拉到底提示文字
		else
			getglobal("ChosenArchiveBoxMoreMap"):Show();
			getglobal("ChosenArchiveBoxMoreMapNotice"):Hide();
		end
	end

	local height = getglobal("ChosenArchiveBox"):GetRealHeight();
	if totalHeight < height then
		totalHeight = height;
	end
	plane:SetHeight(totalHeight + 63 + 16);
	if newVersion then
		plane:SetHeight(totalHeight + 16);
	end
	
end

-------------------------------------------------------------MiniWorksFrameReview---------------------------------------------------------

local reviewFrameFirstShow = true;

function MiniWorksFrameReview_OnLoad()
	UpdateReviewArchive(0);
end

function MiniWorksFrameReview_OnShow()

	if reviewFrameFirstShow then
		reviewFrameFirstShow = false;
		ReqReviewMaps(Review_CurLabel, Review_CurOrder, true);
	end

	UpdateReviewArchive(#(mapservice.reviewMaps));

	UpdateFilterName(2);
end

function MiniWorksFrameReview_OnHide()
	ShowLoadLoopFrame(false)
	CancelAllDownloadingThumbnails();
end

function MiniWorksFrameReview_OnReviewMapsPulled(num_pulled, isrefresh)
	if isrefresh then
		getglobal("ReviewArchiveBox"):resetOffsetPos();
	end

	UpdateReviewArchive(num_pulled);

	if getglobal("MiniWorksFrame"):IsShown() and getglobal("ArchiveInfoFrameIntroduce"):IsShown() and CurArchiveMap ~= nil then
		UpdateShareArchiveInfoIntroduce();
	end
end

function MiniWorksFrameReviewFilter_OnClick()
	ShowArchiveFilterFrame(Review_CurLabel, Review_CurOrder, mapservice.reviewOrderNames, 1);
end

function MiniWorksFrameReviewFilter2_OnClick()
	ShowArchiveFilterFrame(Review_CurLabel, Review_CurOrder, mapservice.reviewOrderNames, 2);
end

function MiniWorksFrameReview_SetFilter(label, order)
	Log("MiniWorksFrameReview_SetFilter: "..label..", "..order);
	if label ~= Review_CurLabel or order ~= Review_CurOrder then
		Review_CurLabel = label;
		Review_CurOrder = order;

		ReqReviewMaps(Review_CurLabel, Review_CurOrder, true);

		Log("Review_CurOrder = "..type(Review_CurOrder)..", "..Review_CurOrder);

		--[[把“刷新”、“换一批”字样去掉
		if Review_CurOrder == 1 then
			getglobal("MiniWorksFrameReviewRefreshName"):SetText(GetS(3849));  --换一批
		else
			getglobal("MiniWorksFrameReviewRefreshName"):SetText(GetS(3853));  --刷新
		end
		]]

		UpdateFilterName(2);
		WorksFilterStatistics(2, label, order);
	end
end

function MiniWorksFrameReviewRefresh_OnClick()
	if Review_CurOrder == 1 then  --换一批
		ReqReviewMaps(Review_CurLabel, Review_CurOrder, true);
	else  --刷新
		ReqReviewMaps(Review_CurLabel, Review_CurOrder, true);
	end
end

function ReviewArchiveBox_OnMovieFinished()
	if getglobal("ReviewArchiveBoxMoreMap"):IsShown() then
		if Review_CurOrder ~= 1 then  --更多地图
			ReqReviewMaps(Review_CurLabel, Review_CurOrder, false);
		end
	end
end

--更多地图
function ReviewArchiveBoxMoreMap_OnClick()
	if Review_CurOrder ~= 1 then
		ReqReviewMaps(Review_CurLabel, Review_CurOrder, false);
	end
end

--换一批
function ReviewArchiveBoxMoreMap2_OnClick()
	if Review_CurOrder == 1 then
		ReqReviewMaps(Review_CurLabel, Review_CurOrder, true);
	end
end

function UpdateReviewArchive(num_pulled)
	if #mapservice.reviewMaps == 0 then
		getglobal("MiniWorksFrameMapTipsFrame"):Show();
	else
		getglobal("MiniWorksFrameMapTipsFrame"):Hide();
	end

	for i = 1, Review_Archive_Max do

		local archui = getglobal("ReviewArchive"..i);

		if i <= #(mapservice.reviewMaps) then
			local map = mapservice.reviewMaps[i];
			archui:Show();
			UpdateSingleArchive(archui, map, {hideRankTag=true});
		else
			archui:Hide();
			UpdateSingleArchive(archui, nil);
		end
	end

	local plane = getglobal("ReviewArchiveBoxPlane");
	local totalHeight = math.ceil(#(mapservice.reviewMaps) / 2) * SingleArchiveHeight;

	getglobal("ReviewArchiveBoxMoreMap"):SetPoint("top", "ReviewArchiveBoxPlane", "top", 0, totalHeight + 8);
	getglobal("ReviewArchiveBoxMoreMap2"):SetPoint("top", "ReviewArchiveBoxPlane", "top", 0, totalHeight + 8);
	getglobal("ReviewArchiveBoxMoreMapNotice"):SetPoint("top", "ReviewArchiveBoxPlane", "top", 0, totalHeight + 8);

	--无法加载更多地图
	if Review_CurOrder == 1 then
		getglobal("ReviewArchiveBoxMoreMap"):Hide();  --更多地图
		getglobal("ReviewArchiveBoxMoreMapNotice"):Hide();  --拉到底提示文字
		
		if (num_pulled~=nil and num_pulled<20) or #(mapservice.reviewMaps) >= Review_Archive_Max then  --换一批
			getglobal("ReviewArchiveBoxMoreMap2"):Hide();
		else
			getglobal("ReviewArchiveBoxMoreMap2"):Show();
		end
	else
		getglobal("ReviewArchiveBoxMoreMap2"):Hide();  --换一批

		if (num_pulled~=nil and num_pulled<20) or #(mapservice.reviewMaps) >= Review_Archive_Max then  --更多地图
			getglobal("ReviewArchiveBoxMoreMap"):Hide();
			getglobal("ReviewArchiveBoxMoreMapNotice"):Show();  --拉到底提示文字
		else
			getglobal("ReviewArchiveBoxMoreMap"):Show();
			getglobal("ReviewArchiveBoxMoreMapNotice"):Hide();
		end
	end

	local height = getglobal("ReviewArchiveBox"):GetRealHeight();
	if totalHeight < height then
		totalHeight = height;
	end

	--获取实时宽
	local plane_width = plane:GetWidth();
	--plane:SetSize(1248, totalHeight + 63 + 16);
	plane:SetSize(plane_width, totalHeight + 63 + 16);
end

-----------------------------------------------------------MiniWorksFramePlayer-------------------------------------------------

local setPlayerMapsScroll = false;
local playerFrame_firstShow = true;
local MiniWorksFrameMap_firstShow = true;

function MiniWorksFramePlayer_OnLoad()
	
end

function MiniWorksFramePlayer_OnShow()

	if playerFrame_firstShow then
		playerFrame_firstShow = false;

		setPlayerMapsScroll = false;
		ReqPlayerMapsRand(Player_CurLabel);
	else
		UpdatePlayerArchive();
	end

	UpdateFilterName(3);
	UpdatePlayerLayout();
end

function MiniWorksFramePlayer_OnHide()
	ShowLoadLoopFrame(false)
	CancelAllDownloadingThumbnails();
end

function PlayerArchiveBoxActivityMapsRefresh_OnClick()
	if CanRefreshWorksByServer() then
		ReqActivityMaps();
	else
		MiniWorksFramePlayer_OnActivityMapsPulled();
	end
end

function PlayerArchiveBoxPlayerMapsRefresh_OnClick()
	setPlayerMapsScroll = false;
	if CanRefreshWorksByServer() then
		ReqPlayerMapsRand(Player_CurLabel);
	else
		MiniWorksFramePlayer_OnMapsPulled();
	end
	standReportEvent("3",reportWorksCardName[9],"Refresh","click")
end

function PlayerArchiveBoxMoreMap_OnClick()
	setPlayerMapsScroll = true;
	ReqPlayerMapsRand(Player_CurLabel);
end

function MiniWorksFramePlayerFilter_OnClick()
	ShowArchiveFilterFrame(Player_CurLabel, Player_CurOrder, mapservice.playerOrderNames, 1);
end

function MiniWorksFramePlayerFilter2_OnClick()
	ShowArchiveFilterFrame(Player_CurLabel, Player_CurOrder, mapservice.playerOrderNames, 2);
end

function MiniWorksFramePlayer_SetFilter(label, order)
	Log("MiniWorksFramePlayer_SetFilter: "..label..", "..order);
	if label ~= Player_CurLabel or order ~= Player_CurOrder then
		if label ~= Player_CurLabel then
			standReportEvent("3", "MINI_WORKSHOP_PLAYERMAP_1", "ContentComboBox", "click", {standby1=tostring(label)})
		else
			standReportEvent("3", "MINI_WORKSHOP_PLAYERMAP_1", "RankComboBox", "click", {standby1=tostring(order)})
		end
		Player_CurLabel = label;
		Player_CurOrder = order;
		setPlayerMapsScroll = false;
		ReqPlayerMapsRand(Player_CurLabel);
		
		UpdateFilterName(3);
		WorksFilterStatistics(3, label, order);
	end
end

--活动地图回调
function MiniWorksFramePlayer_OnActivityMapsPulled()
	UpdateActivityArchive();
	UpdateMapActivityLayout();
	--UpdatePlayerLayout();

	if getglobal("MiniWorksFrame"):IsShown() and getglobal("ArchiveInfoFrameIntroduce"):IsShown() and CurArchiveMap ~= nil then
		UpdateShareArchiveInfoIntroduce();
	end
end

function MiniWorksFramePlayer_OnMapsPulled()

	if setPlayerMapsScroll then
		setPlayerMapsScroll = false;
		getglobal("PlayerArchiveBox"):setCurOffsetY(-407);
	end

	getglobal("PlayerArchiveBox"):resetOffsetPos();

	UpdatePlayerArchive();
	UpdatePlayerLayout();

	if getglobal("MiniWorksFrame"):IsShown() and getglobal("ArchiveInfoFrameIntroduce"):IsShown() and CurArchiveMap ~= nil then
		UpdateShareArchiveInfoIntroduce();
	end
end

function UpdateActivityArchive()
	MiniWorksFrameMap_IsShowActivityBtn();
	UpdateMapActivityArchive();
	--LLTDOO:去掉活动地图
	--getglobal("PlayerArchiveBoxActivityMapsHeaderText"):SetText(mapservice.curActivityName);
	
end

function UpdatePlayerArchive()
	UpdateSectionMaps("PlayerArchiveBoxPlayerMaps", mapservice.playerMaps);
	--[[加载更多按钮去掉
	getglobal("PlayerArchiveBoxMoreMap"):Show();
	--]]
end

function UpdatePlayerLayout()
	Log("UpdatePlayerLayout");

	local layout_uis = {
		--"PlayerArchiveBoxActivityMaps",
		"PlayerArchiveBoxPlayerMaps",
		--"PlayerArchiveBoxMoreMap",
	};

	local plane_name = "PlayerArchiveBoxPlane";
	--顶部间隔8->0
	local y = 0;

	for i=1,#layout_uis do

		local ui_name = layout_uis[i];

		local ui_obj = getglobal(ui_name);

		ui_obj:SetPoint("top", plane_name, "top", 0, y);

		if ui_obj:IsShown() then
			y = y + ui_obj:GetHeight() + 8;
		end
	end

	local totalHeight = y;
	local containerHeight = getglobal("PlayerArchiveBox"):GetRealHeight();
	totalHeight = clamp(totalHeight, containerHeight, nil);
	getglobal(plane_name):SetSize(1246, totalHeight);
end

-----------------------------------------------------------MiniWorksFrameMapActivity, begin-------------------------------------------------
--活动页面
function MiniWorksFrameMapActivity_OnLoad()
	UpdateMapActivityLayout();

	--条目布局
	local section_ui_name = "MapActivityArchiveBoxActivityMaps"
	for i = 1, 999 do
		if not HasUIFrame(section_ui_name.."Archive"..i) then
			break;
		end

		local archive = getglobal(section_ui_name.."Archive"..i);

		local row = math.floor((i - 1) / 2);  --starts at 0

		if (i-1)%2 == 0 then
			archive:SetPoint("topright", section_ui_name, "top", -8,row*SingleArchiveHeight);
		else
			archive:SetPoint("topleft", section_ui_name, "top", 8,row*SingleArchiveHeight);
		end
	end
end

function MiniWorksFrameMapActivity_OnShow()
	UpdateMapActivityArchive();
	UpdateActivityArchive();
	UpdateMapActivityLayout();
end

function MiniWorksFrameMapActivity_OnHide()

end

function UpdateMapActivityLayout()
	Log("UpdateMapActivityLayout");

	local layout_uis = {
		"MapActivityArchiveBoxTitleFrame",
		"MapActivityArchiveBoxActivityMaps",
	};

	local plane_name = "MapActivityArchiveBoxPlane";						
	--顶部间隔8->0
	local y = 0;

	for i=1,#layout_uis do

		local ui_name = layout_uis[i];

		local ui_obj = getglobal(ui_name);

		ui_obj:SetPoint("top", plane_name, "top", 0, y);

		if ui_obj:IsShown() then
			y = y + ui_obj:GetHeight() + 8;
		end
	end

	local totalHeight = y;
	local containerHeight = getglobal("MapActivityArchiveBox"):GetRealHeight();
	totalHeight = clamp(totalHeight, containerHeight, nil);
	getglobal(plane_name):SetSize(1246, totalHeight);
end

function UpdateMapActivityArchive()
	--更新活动标题
	local ActivityTitle = mapservice.curActivityName or "活动";
	getglobal("MapActivityArchiveBoxTitleFrameText"):SetText(ActivityTitle);

	--更新地图列表
	UpdateSectionMaps("MapActivityArchiveBoxActivityMaps", mapservice.activityMaps);
end

function MiniWorksFrameMap_IsShowActivityBtn()
	--第三个按钮是"活动", 当活动地图列表为空是代表无活动, 要把第三个地图隐藏
	local num = #mapservice.activityMaps or 0;

	getglobal("MiniWorksFrameMapSwitchBtn5"):SetPoint("left", "MiniWorksFrameMapSwitchBtn3", "right", 10, 0);
	if  num > 0 and MiniWorks_SwitchBtnNum[1] >= 5 then
		getglobal("MiniWorksFrameMapSwitchBtn5"):Show();
		if getglobal("MiniWorksFrameMapSwitchBtn4"):IsShown() and getglobal("MiniWorksFrameMapSwitchBtn5"):IsShown() then
			getglobal("MiniWorksFrameMapSwitchBtn5"):SetPoint("left", "MiniWorksFrameMapSwitchBtn4", "right", 10, 0);
		end
	else
		--LLDO:20180904:刷到地图数量为0, 则不要刷新界面
		-- if getglobal("MiniWorksFrameMapActivity"):IsShown() then
		-- 	--切换页面
		-- 	--MiniWorksSwitchBtnLayout(1);
		-- 	getglobal("MiniWorksFrameMapActivity"):Hide();
		-- end

		-- getglobal("MiniWorksFrameMapSwitchBtn5"):Hide();
	end

	--活动类型为外部投稿活动时，不显示“活动”按钮
	FetchActivityInfo();
	if  mapservice.curActivityId  == 0 or (not mapservice.curActivityId) or mapservice.curActivityType == 2 then
		getglobal("MiniWorksFrameMapSwitchBtn5"):Hide();
	end

end
-----------------------------------------------------------MiniWorksFrameMapActivity, end-------------------------------------------------

--子窗口内切换页面按钮
--MiniWorks_CurrentSwitchBtn
--MiniWorks_SwitchBtnNum
--MiniWorks_SwitchBtnName
--MiniWorks_ChildPageName
--t_MiniWorks_FrameName
--按钮布局
--btnIndex:当前选中的按钮索引(1, 2, 3...)
function MiniWorksSwitchBtnLayout(btnIndex)
	getglobal("MiniWorksFrameMapTipsFrame"):Hide();
	
	local last_btn = nil;									--上一个按钮
	local parentUIName = t_MiniWorks_FrameName[CurLabel];	--当前页面

	for i = 1, MiniWorks_SwitchBtnNum[CurLabel] do
		local btn = getglobal(parentUIName.."SwitchBtn"..i)
		local name = getglobal(parentUIName.."SwitchBtn"..i.."Name");
		local name_text = GetS(MiniWorks_SwitchBtnName[CurLabel][i]);
		local pic = getglobal(btn:GetName().."Pic");
		local child_page = getglobal(MiniWorks_ChildPageName[CurLabel][i]);
		
		if btn then
			if btnIndex > 0 then
				--1. 设置位置
				if i > 1 and last_btn then
					btn:SetPoint("topleft", last_btn:GetName(), "topright", 10, 0);
				end

				--2. 设置按钮上的文字(步骤1,2只运行一次)
				if name and name_text then
					name:SetText(name_text);
				end
			end

			--3. 置选中状态,切换页面
			if btnIndex then
				if i == btnIndex then
					if pic then
						btn:SetSize(120, 49);
						pic:SetTexUV("tab_up_h");			--按钮背景
						name:SetTextColor(76, 76, 76);		--按钮文字颜色
					end

					if child_page then
						child_page:Show();						--切换页面
					end
				else
					if pic then
						btn:SetSize(120, 46);
						pic:SetTexUV("tab_up_n");
						name:SetTextColor(191, 228, 227);
					end

					if child_page then
						child_page:Hide();
					end
				end
			end	
		end

		if btn:IsShown() then
			last_btn = btn;
		end
	end

	--设置当前选中的按钮索引
	MiniWorks_CurrentSwitchBtn[CurLabel] = btnIndex;
end

--页面切换按钮
function MiniWorksSwitchBtnTemplate_OnClick()
	local btnID = this:GetClientID();
	local btnIndex = btnID % 10;		--按钮的索引
	--local parentUIName = t_MiniWorks_FrameName[CurLabel];	--按钮的父窗口名

	if GetCurFrameSubPageSwitchBtnIdx(CurLabel) == btnIndex then
		return;
	end


	MapDownloadReportMgr:SetMiniWorkMapSubType(btnID);
	MiniWorksSwitchBtnLayout(btnIndex);

	if IsMiniWorksFrameType(CurLabel, CONST_FRAME_NAME.MAP) then
		--地图页, 曝光初始化
		m_ExposureParam:Init();
	end
	local tb = {
		"-",
		"ContentComboBox",
		"RankComboBox",
		"Refresh"
	}
	for _, v in ipairs(tb) do
		local subPageBtnIdx = GetMiniWorksFrame_GetMapFrameIdx()
		local cardName = reportWorksCardName[subPageBtnIdx + 6]
		if v=="RankComboBox" then
			standReportEvent("3", cardName, v, "view", {standby1="0"})
		elseif v == "ContentComboBox" then
			standReportEvent("3", cardName, v, "view", {standby1=tostring(Connoisseur_CurLabel)})
		else
			standReportEvent("3", cardName, v, "view")
		end
	end
end

--"地图"页面
function MiniWorksFrameMap_OnShow()
	--助审开关
	if CSOWorld:isGmCommandsEnabled() or getExpert().stat == 2 then
		getglobal("MiniWorksFrameMapSwitchBtn4"):Show() 
	else
		getglobal("MiniWorksFrameMapSwitchBtn4"):Hide() 
	end
	local tb = {
		"-",
		"ContentComboBox",
		"RankComboBox",
		"Refresh"
	}
	for _, v in ipairs(tb) do
		local subPageBtnIdx = GetMiniWorksFrame_GetMapFrameIdx()
		
		local cardName = reportWorksCardName[subPageBtnIdx + 6]
		if v=="RankComboBox" then
			standReportEvent("3", cardName, v, "view", {standby1="0"})
		elseif v == "ContentComboBox" then
			standReportEvent("3", cardName, v, "view", {standby1=tostring(Connoisseur_CurLabel)})
		else
			standReportEvent("3", cardName, v, "view")
		end
		
	end
	--按钮布局
	MiniWorksSwitchBtnLayout(GetCurFrameSubPageSwitchBtnIdx(CurLabel));

	MapDownloadReportMgr:SetMiniWorkMapSubType(GetCurFrameSubPageSwitchBtnIdx(CurLabel));

	if MiniWorksFrameMap_firstShow then
		MiniWorksFrameMap_firstShow = false;

		--活动按钮:UpdateActivityArchive
		ReqActivityMaps();
		MiniWorksFrameMap_IsShowActivityBtn();
	else
		if #mapservice.activityMaps <= 0 then
			ReqActivityMaps();
			MiniWorksFrameMap_IsShowActivityBtn();
		end
	end


end

function MiniWorksFrameMap_OnLoad()
	
end

function MiniWorksFrameMap_OnHide()
	
end

--新"材质包"页面
function MiniWorksFrameMaterialNew_OnShow()
	--按钮布局
	standReportEvent("3", "MINI_WORKSHOP_TEXTURE_1","-", "view")
	MiniWorksSwitchBtnLayout(GetCurFrameSubPageSwitchBtnIdx(CurLabel));
end

function MiniWorksFrameMaterialNew_OnHide()

end

--"我的"页面
function MiniWorksFrameSelfCenter_OnShow()
	--个人信息
	MiniWorksSetRoleInfo("MiniWorksFrameSelfCenterTopHeadBtnIcon", "MiniWorksFrameSelfCenterTopName", "MiniWorksFrameSelfCenterTopMini");

	--金币
	local CoinNum = AccountManager:getAccountData():getMiniCoin()
	getglobal("MiniWorksFrameSelfCenterTopCoin"):SetText(CoinNum);

	if getExpert().stat == 2 then
		getglobal("MiniWorksFrameSelfCenterEvaluationInvite"):Show();
	else
		getglobal("MiniWorksFrameSelfCenterEvaluationInvite"):Hide();
	end
end

--显示个人信息
function MiniWorksSetRoleInfo(strHeadIcon, strName, strUin)
	--头像
	--如果有自定义头像文件，先切换头像文件
	local head_path_ = getkv( "head_pic_cache" );
	if  head_path_ and #head_path_>0 and gFunc_isStdioFileExist( head_path_ ) then
		getglobal(strHeadIcon):SetTexture( head_path_ );
	else
		-- local index = GetHeadIconIndex();
		local headPath = GetHeadIconPath()
		getglobal(strHeadIcon):SetTexture(headPath);
	end

	--昵称
	local name = getglobal(strName);
	--name:SetText(AccountManager:getBlueVipIconStr(AccountManager:getUin())..AccountManager:getNickName(), 98, 65, 48);
	name:SetText(AccountManager:getNickName());

	--uin
	getglobal(strUin):SetText(GetMyUin());
end

--隐藏左侧导航按钮
function MiniWorksHideLeftBtns(bShow)
	local btnNum = #t_LabelInfo;

	--1. 按钮
	for i = 1, btnNum do
			local btn = getglobal("MiniWorksFrameLabel"..i);

			if nil ~= btn then
				if IsMiniWorksFrameType(i, CONST_FRAME_NAME.REVIEW) then
					--助审
					if bShow and CSOWorld:isGmCommandsEnabled() then
						btn:Show();
					else
						btn:Hide();
					end
				elseif IsMiniWorksFrameType(i, CONST_FRAME_NAME.COLLECT) then 
					if isEnableNewCreationCenter and isEnableNewCreationCenter() then 
						btn:Hide()
					end
				elseif IsMiniWorksFrameType(i, CONST_FRAME_NAME.SEARCH) then
					-- if bShow and not GetInst("NSearchPlatformService"):ABTestSwitch() then
					-- 	btn:Show();
					-- else
						btn:Hide();
					-- end					
				else
					if bShow then
						--bShow == true, 显示
						btn:Show();
					else
						--隐藏
						btn:Hide();
					end
				end
			end
	end

	--2. 底板
	local diban = getglobal("MiniWorksFrameLeftLabelsDiban");
	if nil ~= diban then
		if bShow then
			diban:Show();
		else
			diban:Hide();
		end
	end
end

--隐藏/显示"我的"及左侧导航按钮
function Miniworks_IsShowSelfCentr(bShow)
	if bShow then
		getglobal("MiniWorksFrameSelfCenter"):Show();
	else
		getglobal("MiniWorksFrameSelfCenter"):Hide();
	end
	
	MiniWorksHideLeftBtns(bShow);
end

--工坊主页面上关闭按钮和返回按钮切换
function MiniworksSelfCenterShowBackBtn(bShow)
	if bShow then
		--显示返回按钮
		getglobal("MiniWorksFrameBackBtn"):Show();
		getglobal("MiniWorksFrameCloseBtn"):Hide();
	else
		--显示关闭按钮
		getglobal("MiniWorksFrameBackBtn"):Hide();
		getglobal("MiniWorksFrameCloseBtn"):Show();
	end
end

--通用, 初始化条目布局
function MiniWorks_InitBoxFrameArchive(box_name, offset_X, archive_h, offset_top)
	local plane_name = box_name.."Plane";

	for i = 1, 999 do
		if not HasUIFrame(box_name.."Archive"..i) then
			break;
		end

		local archive = getglobal(box_name.."Archive"..i);
		local row = math.floor((i - 1) / 2);  --starts at 0

		if (i-1)%2 == 0 then
			archive:SetPoint("topright", plane_name, "top", 0 - offset_X, offset_top + row * archive_h);
		else
			archive:SetPoint("topleft", plane_name, "top", offset_X, offset_top + row * archive_h);
		end

		archive:Hide();
	end
end

--我的作品-----------------------------------------------------------------------------------
function MiniWorksSelfCenterProductionPageCloseBtn_OnClick()
	this:GetParentFrame():Hide();
end

--新版本:点击订阅用户列表项
function SubscribePageBoxWnd_OnClick()
	local uin = getglobal(this:GetName() .. "Mini"):GetText();
	print("**************",this:GetName());
	OpenProductionPage(uin, true);
end

function MiniWorksSelfCenterProductionEnter_OnClick()
	OpenProductionPage(GetMyUin(), true);
	MapDownloadReportMgr:SetMiniWorkMyTypeSubType(ReportDefine.MiniWorkMytypeSubDefine.MyMap);
end

function OpenProductionPage(uin, bIsEnterFromSelfCenter)
	if uin then
		if false == bIsEnterFromSelfCenter and uin == GetMyUin() then
			--从地图详情页进入, 不允许查看自己
			ShowGameTips("不能查看自己");
		else
			--加载个人信息
			local uinName = getglobal("MiniWorksFrameSelfCenterTopName"):GetText();
			local head_path_ = getkv( "head_pic_cache" );
			if  head_path_ and #head_path_>0 and gFunc_isStdioFileExist( head_path_ ) then
				-- getglobal(strHeadIcon):SetTexture( head_path_ );
				SetProductionPageSelfInfo(uin,uinName,head_path_, bIsEnterFromSelfCenter);
			else
				-- local index = GetHeadIconIndex();
				-- local uinIcon = "ui/roleicons/"..index..".png";
				local headPath = GetHeadIconPath()
				-- getglobal(strHeadIcon):SetTexture("ui/roleicons/"..index..".png");
				SetProductionPageSelfInfo(uin,uinName,headPath, bIsEnterFromSelfCenter);
			end
			--SetProductionPageSelfInfo(uin,uinName,uinIcon, bIsEnterFromSelfCenter);

			--显示"我的作品"
			local productionFrame = getglobal("MiniWorksSelfCenterProductionPage");
			productionFrame:Show();
			--SetProductionPageSelfInfo()函数中使用setpoint调整界面位置, 子控件没有刷新, 还是在老位置, 下面将父窗口位置调整一下, 子控件才刷新, 是有某个属性控制子控件的刷新???
			local w = productionFrame:GetRealWidth();
			local h = productionFrame:GetRealHeight();
			productionFrame:SetSize(w - 1, h - 1);
			productionFrame:SetSize(w, h);
		end
	end
end

function SetProductionPageSelfInfo(uin,uinName,uinIcon, bIsEnterFromSelfCenter)
	local titleFrame = getglobal("MiniWorksSelfCenterProductionPageTitleFrame");	--标题栏
	local topFrame = getglobal("ProductionPageInfoFrame");							--个人信息栏
	local uinObj = getglobal("ProductionPageInfoFrameMini");			--迷你号
	local takeBtn01 = getglobal("ProductionPageInfoFrameTakeBtn01");	--订阅按钮
	local takeBtn02 = getglobal("ProductionPageInfoFrameTakeBtn02");	--取消订阅按钮
	local signatureObj1 = getglobal("ProductionPageInfoFrameIntroduceEdit");			--签名, 编辑框
	local signatureObj2 = getglobal("ProductionPageInfoFrameIntroduce");				--签名, 文本框
	local signatureIconObj = getglobal("ProductionPageInfoFrameIntroduceEditIcon");		--签名, 铅笔图标. 查看自己的时候才显示.

	if bIsEnterFromSelfCenter then
		--从"我的"进入, 显示标题栏
		titleFrame:Show();
		topFrame:SetPoint("top", "MiniWorksSelfCenterProductionPage", "top", 0, 140);
	else
		titleFrame:Hide();
		topFrame:SetPoint("top", "MiniWorksSelfCenterProductionPage", "top", 0, 65);
	end

	--在拉取个人信息之前, 名字头像等初始状态显示,171102.
	--local uinName = getglobal("MiniWorksFrameSelfCenterTop"):GetText();
	-- local uinName = getglobal(this:GetName() .. "Mini"):GetName;
	--local uin11 = getglobal(this:GetName() .. "Mini"):GetText();
	getglobal("ProductionPageInfoFrameName"):SetText(uinName);
	getglobal("ProductionPageInfoFrameHeadBtnIcon"):SetTexture(uinIcon);

	--迷你号
	uinObj:SetText(uin);

	--查看 自己/别人
	if uin and uin == GetMyUin() then
		takeBtn01:Hide();
		takeBtn02:Hide();

		--自我介绍, 显示编辑框
		signatureIconObj:Show();	--只有查看自己的时候, 才显示这个铅笔图标.
		signatureObj1:Show();
		signatureObj2:Hide();
		signatureObj1:Clear();
	else
		--根据订阅状态, 显示不同的按钮?????????????
		takeBtn01:Hide();
		takeBtn02:Hide();

		--自我介绍, 显示静态文本
		signatureIconObj:Hide();
		signatureObj1:Hide();
		signatureObj2:Show();
		signatureObj2:SetText(GetS(6059));	--初始化为默认签名:暂无自我介绍.
	end

	--获取个人信息
	--GetProductionPageIntroduce(uin);

	--请求地图
	ReqProductionMapsByUin(uin, ReqProductionMap_OnResults);
end

function ProdectionMapsLayout(maps, box_name, archive_h, offset_top)			--作品地图布局
	local totalHeight = 0;

	if g_ProductionMaps then
		local sum = #g_ProductionMaps;

		for i = 1, 999 do
			if not HasUIFrame(box_name.."Archive"..i) then
				break;
			end

			local archive = getglobal(box_name.."Archive"..i);
			
			if i <= sum then
				archive:Show();
				UpdateSingleArchive(archive, g_ProductionMaps[i], {hideRankTag=false});
			else
				archive:Hide();
			end
		end

		totalHeight = math.ceil(sum / 2) * archive_h + offset_top;
		boxHeight = getglobal(box_name):GetRealHeight();
		if totalHeight < boxHeight then
			totalHeight = boxHeight;
		end
	end

	local plane = getglobal(box_name.."Plane");
	local planeWidth =plane:GetWidth();
	plane:SetSize(planeWidth, totalHeight);
end

function ReqProductionMap_OnResults(maps, target_uin)										--请求地图结果处理
	g_ProductionMaps = nil;
	g_ProductionMaps = {};
	g_ProductionMaps = maps;

	local num = #g_ProductionMaps;

	Log("ReqProductionMap_OnResults: maps num = "..num);

	--LLDO:获取地图后, 再获取个人信息(因为,bIsHaveChosenMapInProdection,由精选地图来确定, 首先要拉取地图)????
	GetProductionPageIntroduce(target_uin);

	ProdectionMapsLayout(g_ProductionMaps, "ProductionPageMapBox", 132, 14);
end

function ReqProductionMapsByUin(target_uin, callback, selcet)					--请求地图
	if not CheckUin() then
		return;
	end

	local uu_ = tonumber(target_uin) or 0
	if  uu_ < 1000 or uu_ >= ns_const.__INT32__ then
		ShowGameTips(GetS(6351), 3);        --输入的迷你号有误
		return;
	end

	target_uin = getLongUin( target_uin );
	
	Log("ReqProductionMapsByUin "..target_uin);

	mapservice.searchingUin = target_uin;
	mapservice.searchedMaps = {};
	mapservice.searchResultsPulledHttp = false;

	ShowLoadLoopFrame(true, "file:miniworks -- func:ReqProductionMapsByUin");

	local url = mapservice.getserver().."/miniw/map/?act=search_user_maps&op_uin="..target_uin;
	if selcet then
		url = mapservice.getserver().."/miniw/map/?act=search_user_select_maps&op_uin="..target_uin;
	end
    url = AddPlayableArg(url)
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, RespProductionMapsByUin, {_callback = callback, _target_uin = target_uin}, nil, 2);

	return true;
end

function RespProductionMapsByUin(ret, data)									--请求地图回调, data = { _callback, _target_uin }
	mapservice.searchResultsPulledHttp = true;
	ShowLoadLoopFrame(false)

	if CheckHttpRpcRet(ret)==false then
		return;
	end

	Log("RespProductionMapsByUin");
	
	if ret.urls then
		SetMapServers(ret.urls);
	end

	--存放地图
	local maps = {};
	bIsHaveChosenMapInProdection = false;
	if ClientMgr:getApiId() == 999 then
		--测试服都能订阅
		bIsHaveChosenMapInProdection = true;
	end

	if ret.map_info_list then
		for owid, src in pairs(ret.map_info_list) do
			local map = CreateMapInfoFromHttpResp(src,nil,nil,owid);
			map.owid = owid;

			PrintMapInfo(map);

			--table.insert(mapservice.searchedMaps, map);
			table.insert(maps, map);

			--判断是否是精选地图
			if map.display_rank == 2 then
				bIsHaveChosenMapInProdection = true;
			end
		end
	end

	if data and data._callback then
		data._callback(maps, data._target_uin);
	end
end

function ProductionPageIntroduceEdit_OnFocusGained()	--编辑框, 得到焦点
	--背景
	-- local bkg = getglobal("ProductionPageInfoFrameIntroduceEditBkg");
	-- bkg:SetPoint("center", "ProductionPageInfoFrameIntroduceEdit", "center", 0, 0);
	-- bkg:Show();
end

function ProductionPageIntroduceEdit_OnFocusLost()		--编辑框, 失去焦点
	--背景
	-- local bkg = getglobal("ProductionPageInfoFrameIntroduceEditBkg");
	-- bkg:Hide();

	--保存信息
	SaveProductionPageIntroduce(this:GetText());
end

function ProductionPageIntroduceEdit_OnEnterPressed()	--编辑框, 回车键
	UIFrameMgr:setCurEditBox(nil);
end

function SaveProductionPageIntroduce(text)		--保存编辑框信息
	if text then
		Log("SaveProductionPageIntroduce: text = "..text);

		--敏感词
		if CheckFilterString(text) then
			return;
		end

		--请求服务器, 设置信息
		local signature_ = ns_http.func.base64_encode(text);
		local uin_ = GetMyUin();
		local url_ = g_http_root_map .. 'miniw/profile?act=setProfile&signature=' .. signature_ .. '&' .. http_getS1Map();
		url_ = url_ .. "&" .. http_getRealNameMobileSum(signature_)
		Log("signature_="..signature_);
		Log( "url_ = "..url_ );
		ns_http.func.rpc( url_, Resp_SaveProductionPageIntroduce, nil, nil, true );
	end
end

function Resp_SaveProductionPageIntroduce(ret)		--设置个人介绍, 回调函数.
	if ret then
		Log("Resp_SaveProductionPageIntroduce: ret = ");

		if ret.ret == 0 then
			--成功

		end
	end
end

function GetProductionPageIntroduce(uin, call_back, extend, fast)			--拉取个人信息
	--请求服务器, 获取信息
		local uin_ = uin;
		fast = fast or 110
		local url_ = g_http_root_map .. 'miniw/profile?act=getProfile&op_uin=' .. uin_.. '&' .. 'fast=' ..tostring(fast) .. '&' .. http_getS1Map();
		Log( "url_ = "..url_ );

		if call_back == nil then call_back = Resp_GetProductionPageIntroduce; end
		if extend  == nil then extend = uin; end

		ns_http.func.rpc( url_, call_back, extend, nil, ns_http.SecurityTypeHigh);
end

function SetUserHeadIconByUrl(url_, checked_, uin_, headIcon_)		--设置用户自定义头像
	Log( "call SetUserHeadIconByUrl" );

	if  url_ and #url_ > 3 then
		local file_name_ = g_photo_root .. getHttpUrlLastPart( url_ ) .."_";		--加上"_"后缀

		local function downloadPng_head_cb()
			Log( "call downloadPng_head_cb, file=" .. file_name_ );

			--保存头像文件路径
			if  uin_ == GetMyUin() then
				setkv( "head_pic_cache", file_name_ );
			end

			--设置头像
			headIcon_:SetTexture(file_name_);
		end

		ns_http.func.downloadPng( url_, file_name_, nil, nil, downloadPng_head_cb );   --下载文件
	elseif  url_ == "d" then
		local headPath = GetHeadIconPath()
		local file_name_ = headPath;  	--头像文件
		if uin_ == GetMyUin() then
			setkv( "head_pic_cache", nil );
		end
		
		--设置头像
		headIcon_:SetTexture(file_name_);
	else
		--resetAllHead();
	end
end

function Resp_GetProductionPageIntroduce(ret, uin_)		--获取个人介绍, 回调函数.
	if ret then
		Log("Resp_GetProductionPageIntroduce: uin_="..uin_.."ret = ");

		local headObj = getglobal("ProductionPageInfoFrameHeadBtnIcon");	--头像
		local nameObj = getglobal("ProductionPageInfoFrameName");			--名字
		local watchObj = getglobal("ProductionPageInfoFrameWatchNum");		--查看数量
		local fansObj = getglobal("ProductionPageInfoFrameFansNum");		--粉丝数量
		local takeBtn01 = getglobal("ProductionPageInfoFrameTakeBtn01");	--订阅按钮
		local takeBtn02 = getglobal("ProductionPageInfoFrameTakeBtn02");	--取消订阅按钮
		local signatureObj1 = getglobal("ProductionPageInfoFrameIntroduceEdit");	--签名, 编辑框
		local signatureObj2 = getglobal("ProductionPageInfoFrameIntroduce");		--签名, 文本框

		if ret.ret == 0 and ret.profile and ret.profile.RoleInfo then
			--成功

			local uin = ret.profile.uin or uin_;		--迷你号
			local signature = "";						--签名
			if ret.profile.signature then
				Log("Have, signature_1:"..signature);
				signature = ns_http.func.base64_decode(ret.profile.signature);
				--Log("Have, signature_2:"..signature);
			end

			local name = ret.profile.RoleInfo.NickName or "名字最多七个字";
			local model = ret.profile.RoleInfo.Model or 0;
			local skinid = ret.profile.RoleInfo.SkinID or 0;
			
			Log("uin = "..uin);

			--名字
			nameObj:SetText(name);

			--头像
			if ret.profile.header and ret.profile.header.url then
				--自定义头像
				SetUserHeadIconByUrl(ret.profile.header.url, ret.profile.header.checked, uin, headObj);
			else
				-- headObj:SetTexture("ui/roleicons/"..GetHeadIconIndex( model, skinid )..".png");
				HeadCtrl:SetPlayerHeadByUin(headObj, uin, model, skinid)
			end
			
			--头像框
			changeHeadFrameTxtPic( (ret.profile.head_frame_id or 1) , "ProductionPageInfoFrameHeadBtnIconFrame" );

			--自我介绍
			if signature and signature ~= "" then
				Log("signature = "..signature);

				--敏感词过滤
				if CheckFilterString(signature) then
					--是敏感词, 屏蔽.
					Log("have filterstring!!!");
					--signatureObj2:SetText(GetS(6059));
					--signatureObj2:Clear();
				else
					signatureObj1:SetText(signature);
					signatureObj2:SetText(signature);
				end
			end

			--查看 自己/别人
			if uin and uin == GetMyUin() then
				--1. 订阅按钮
				--[[
				takeBtn01:Hide();
				takeBtn02:Hide();
				]]

				--2. 自我介绍, 显示编辑框
				signatureObj1:Show();
				signatureObj2:Hide();

				--3. 订阅数和粉丝数
				MiniworksGetSubscribeNumByUin();

			else
				--根据订阅状态, 显示不同的按钮
				local fansNum = 0;
				local SubscribeNum = 0;
				local ret = false;

				ret, fansNum, SubscribeNum = MiniworksGetSubscribeStateByUin(uin);
				Log("fansNum: " .. fansNum);
				Log("SubscribeNum: " .. SubscribeNum);

				--1. 订阅按钮
				--[[新版本, 去掉订阅按钮
				if bIsHaveChosenMapInProdection then
					--存在精选地图才能被订阅
					if ret then
						--已订阅
						takeBtn01:Hide();
						takeBtn02:Show();
					else
						--未订阅
						takeBtn01:Show();
						takeBtn02:Hide();
					end
				else
					takeBtn01:Hide();
					takeBtn02:Hide();
				end
				]]

				--2. 自我介绍, 显示静态文本
				signatureObj1:Hide();
				signatureObj2:Show();

				--3. 订阅、粉丝数量
				MiniworksUpdateSubscribeUI(fansNum, SubscribeNum);
			end
		else
			--失败
			--签名设置默认值
			signatureObj1:Clear();
			signatureObj2:SetText(GetS(6082));
		end
	end
end

function MiniworksGetSubscribeStateByUin(_uin)					--判断是否订阅了
	Log("MiniworksGetSubscribeStateByUin:");

	if g_SubscribeList and _uin then
		Log("uin = " .. _uin);
		for k, v in pairs(g_SubscribeList) do
			--Log("MiniworksGetSubscribeStateByUin: k, v:");
			--Log("k = " .. k);
			--Log("v = ");

	        if _uin == k then
	        	--找到了
	        	local fansNum = v.besub_cc or 0;			--粉丝数量
	        	local SubscribeNum = v.sub_cc or 0;			--订阅数量

	        	Log("true: " .. "fansNum = " .. fansNum .. ", SubscribeNum = " .. SubscribeNum);
	            return true, fansNum, SubscribeNum;
	        end
	    end
	end

	Log("false");
	--返回订阅状态和订阅数量
	return false, 0, 0;
end

function MiniworksGetSubscribeNumByUin()					--获取自己订阅数和粉丝数
	Log("MiniworksGetSubscribeNumByUin");

	if  ns_version and ns_version.proxy_url then
		local url = ns_version.proxy_url.."/miniw/subsp/?act=get_subsp_info";
		url = UrlAddAuth(url);
		Log("url = "..url);

		ns_http.func.rpc(url, Resp_MiniworksGetSubscribeNumByUin,  nil, nil, true);
	end	
end

function Resp_MiniworksGetSubscribeNumByUin(ret)
	local fansNum = 0;
	local SubscribeNum = 0;

	if ret and ret.ret == 0 then
		if ret.infos then
			fansNum = ret.infos.besub_cc or 0;
			SubscribeNum = ret.infos.sub_cc or 0;
		end
	end

	MiniworksUpdateSubscribeUI(fansNum, SubscribeNum);

end

function MiniworksSetOrCancelsubscribe(bIsCancel, _op_uin)		--订阅或取消订阅
	Log("MiniworksSetOrCancelsubscribe");

	if  ns_version and ns_version.proxy_url then
		local url = ns_version.proxy_url.."/miniw/subsp/?act=add";
		url = url .. "&op_uin="..  getLongUin(_op_uin);
		--url = url_addParams(url);
		url = UrlAddAuth(url);

		if bIsCancel then
			--取消订阅
			url = url .. "&cancel=1";
		end

		Log("  url = "..url);
		ShowLoadLoopFrame(true, "file:miniworks -- func:MiniworksSetOrCancelsubscribe");

		ns_http.func.rpc(url, Resp_MiniworksSetOrCancelsubscribe, bIsCancel, nil, true);
	end
end

function Resp_MiniworksSetOrCancelsubscribe(ret, bIsCancel)
	Log("Resp_MiniworksSetOrCancelsubscribe:");
	ShowLoadLoopFrame(false)

	if ret and ret.ret == 0 then
		if getglobal("ArchiveInfoFrameEx"):IsShown() then
			--地图详情页订阅信息刷新
			local fansObj = getglobal("ProductionPageInfoFrameFansNum");		--粉丝数量
			local text = 0;
			local num = 0;

			if getglobal("MiniWorksSelfCenterProductionPage"):IsShown() then
				text = fansObj:GetText();
				num = tonumber(text) or 0;
			end

			if bIsCancel then
				--取消订阅成功
				Log("Cancel Successful! ");
				if num > 0 then
					num = num - 1;
				end
			else
				--订阅成功
				Log("Subscribe Successful! ");
				 num = num + 1;
			end

			--1. 更新UI
			MiniworksUpdateSubscribeUI(num, -1, bIsCancel);

			--2. 重新拉取订阅列表, 因为订阅信息变了.
			MiniworksGetSubscribeList(0);
		elseif getglobal("MiniWorksSelfCenterSubscribePage"):IsShown() then
			--新版本, 重新拉取订阅列表, 并刷新订阅用户列表
			MiniworksGetSubscribeList(0, UpdateSubscribePageUsersList);
		end
	end
end

function MiniworksUpdateSubscribeUI(fansNum, SubscribeNum, bIsCancel)				--刷新订阅相关的ui
	if getglobal("MiniWorksSelfCenterProductionPage"):IsShown() then
		local watchObj = getglobal("ProductionPageInfoFrameWatchNum");		--订阅数量
		local fansObj = getglobal("ProductionPageInfoFrameFansNum");		--粉丝数量
		local btn1 = getglobal("ProductionPageInfoFrameTakeBtn01");			--订阅(订阅改关注)
		local btn2 = getglobal("ProductionPageInfoFrameTakeBtn02");			--取消订阅(订阅改关注)

		if nil ~= bIsCancel then
			Log("1111");
			if bIsCancel then
				--取消订阅
				Log("2222");
				btn1:Show();
				btn2:Hide();
			else
				Log("3333");
				btn1:Hide();
				btn2:Show();
			end
		end

--		local uin = tonumber(string.sub(getglobal("MiniWorksArchiveInfoFrameTopMini"):GetText(), 2, -2)) or 0;
--		if CanAddUinAsFriend(uin) and  CanFollowPlayer(uin) then
--			Log("555")
--			btn1:Show();
--			btn2:Hide();
--		else
--			Log("444")
--			btn1:Hide();
--			btn2:Show();
--		end

		--粉丝数量
		if fansNum >= 0 then
			fansObj:SetText(fansNum);
		end

		if SubscribeNum >= 0 then
			watchObj:SetText(SubscribeNum);
		end
	end
end

function MiniworksUpdateTakeBtn(bIsCancel)
	if getglobal("ArchiveInfoFrameEx"):IsShown() then
		--在地图详情页也加上订阅按钮.
		local btn1 = getglobal("ArchiveInfoFrameExBodyRightMapDetailsTakeBtn01");			--订阅
		local btn2 = getglobal("ArchiveInfoFrameExBodyRightMapDetailsTakeBtn02");			--取消订阅

		if nil ~= bIsCancel then
			Log("1111");
			if bIsCancel then
				--取消订阅
				Log("2222");
				btn1:Show();
				btn2:Hide();
			else
				Log("3333");
				btn1:Hide();
				btn2:Show();
			end
		end
	end
	
	if getglobal("MapDetailInfo"):IsShown() and IsShowFguiStartMain() then
		--在地图详情页也加上订阅按钮.
		local takeBtn01 = getglobal("MapDetailInfoContentPanelIntroduceTakeBtn01");	--关注
		local takeBtn02 = getglobal("MapDetailInfoContentPanelIntroduceTakeBtn02");	--取消关注
		if nil ~= bIsCancel then
			if bIsCancel then
				takeBtn01:Show();
				takeBtn02:Hide();
			else
				takeBtn01:Hide();
				takeBtn02:Show();
			end
		end
	end
	SandboxLua.eventDispatcher:Emit(nil, "UPDATE_FOCUSSTATE", SandboxContext()
	:SetData_Bool("bIsCancel", bIsCancel))
	--[[if GetInst("MiniUIManager"):GetCtrl("ExitGameMenu") then
		if nil ~= bIsCancel then
			GetInst("MiniUIManager"):GetCtrl("ExitGameMenu"):SetFocusState(bIsCancel) 
		end 
	end]]
end

function MiniworksGetSubscribeList(CurTime, callback)				--获取订阅列表

	if  ns_version and ns_version.proxy_url then

		ShowLoadLoopFrame(false)
		ShowLoadLoopFrame(true, "file:miniworks -- func:MiniworksGetSubscribeList");	

		local url = ns_version.proxy_url .."/miniw/subsp/?act=get_list";
		--url = url_addParams(url);
		url = UrlAddAuth(url);

		if CurTime and CurTime > 0 then
			url = url .. "&ct=" .. CurTime;
		end

		Log("MiniworksGetSubscribeList:");
		Log("url = " .. url);

		if callback then
			ns_http.func.rpc(url, Resp_MiniworksGetSubscribeList, callback, nil, true);
		else
			ns_http.func.rpc(url, Resp_MiniworksGetSubscribeList, nil,      nil, true);
		end

	end
	
end

function Resp_MiniworksGetSubscribeList(ret, _callback)
	ShowLoadLoopFrame(false)
	Log("Resp_MiniworksGetSubscribeList:");

	--1. 订阅列表
	if ret and ret.ret == 0 and ret.uin_list then
		g_SubscribeList = nil;
		g_SubscribeList = {};

		g_SubscribeList = ret.uin_list;
	end

	--旧版本废弃
	--2. 订阅动态列表
	g_SubscribeDynamicMapIDList = nil;	--每次只需获取该次的10张地图.
	g_SubscribeDynamicMapIDList = {};
	-- if ret and ret.ret == 0 and ret.list then
	-- 	for i=1, #(ret.list) do
	-- 		--追加到动态列表
	-- 		table.insert(g_SubscribeDynamicList, ret.list[i]);

	-- 		--追加到地图id列表
	-- 		table.insert(g_SubscribeDynamicMapIDList, ret.list[i].wid);
	-- 	end

	-- 	--拉取地图.
	-- 	if getglobal("MiniWorksSelfCenterSubscribePage"):IsShown() then
	-- 		ReqMapInfo(g_SubscribeDynamicMapIDList, RestSubscribeDynamicMap, i, {'normal', 'select'});
	-- 	end

	-- 	--记录最小时间
	-- 	if #(ret.list) < 10 then
	-- 		--全拉取完了
	-- 		g_nProdectionDynaminCurTime = 0;
	-- 	else
	-- 		g_nProdectionDynaminCurTime = g_SubscribeDynamicList[10].t or 0;
	-- 	end
	-- end

	--3. 回调函数
	if _callback then
		_callback();
	end
end

function MiniWorksSelfCenterProductionPage_OnShow()
	--隐藏地图详情页
	if getglobal("ArchiveInfoFrameEx"):IsShown() then
		GetInst("UIManager"):Close("ArchiveInfoFrameEx")
	end

	--隐藏当前页及专题列表
	getglobal(t_MiniWorks_FrameName[CurLabel]):Hide();
	if getglobal("MiniWorksFrameTheme"):IsShown() then
		getglobal("MiniWorksFrameTheme"):Hide();
	end

	--处理滑动窗口重叠
	SetMiniWorksBoxsDealMsg(false);

	--子页面切换
	MiniWorksProductionPageSwitchBtnLayout(1);

	--按钮锁图标
	local Suo1 = getglobal("ProductionPageInfoFrameSwitchBtn1SuoIcon");
	local Suo2 = getglobal("ProductionPageInfoFrameSwitchBtn2SuoIcon");
	local Suo3 = getglobal("ProductionPageInfoFrameSwitchBtn3SuoIcon");
	Suo1:Hide();
	Suo2:Show();
	Suo3:Show();
end

function MiniWorksSelfCenterProductionPage_OnHide()
	--显示当前页
	if getglobal("MiniWorksFrame"):IsShown() and HasUIFrame("MiniWorksCommendDetail") and not getglobal("MiniWorksCommendDetail"):IsShown() then
		if not ("MiniWorksMapTemplate" == t_MiniWorks_FrameName[CurLabel] 
		and HasUIFrame("MapTemplateCommend") 
		and getglobal("MapTemplateCommend"):IsShown()) then
			--getglobal(t_MiniWorks_FrameName[CurLabel]):Show();
			ShowCurWorksFrame();
		end
	end

	--处理滑动窗口重叠
	SetMiniWorksBoxsDealMsg(true);
end

function MiniWorksSelfCenterProductionPage_OnLoad()
	MiniWorks_InitBoxFrameArchive("ProductionPageMapBox", 24, 132, 14);
end

function MiniWorksProductionPageUpdateSelfInfo(bIsSelf)
	if bIsSelf then
		--1. 是自己
	else
		--2. 是别人
	end
end

function MiniWorksProductionPageSwitchBtnLayout(index)
	--页面切换按钮布局
	if index then
		local btnNum = 3;
		local Name = "ProductionPageInfoFrameSwitchBtn";
		local ChildFrames = {"MiniWorksSelfCenterProductionPage"};

		--位置
		local btn1 = getglobal(Name.."1");
		local btn2 = getglobal(Name.."2");
		local btn3 = getglobal(Name.."3");
		local offsetX = 18;
		btn1:SetPoint("center", "ProductionPageInfoFrameFenGeXian", "center", 0, 0);
		--btn2:SetPoint("center", "ProductionPageInfoFrameFenGeXian", "center", 0, 0);
		--btn3:SetPoint("center", "ProductionPageInfoFrameFenGeXian", "center", 120 + offsetX, 0);
		btn2:Hide();
		btn3:Hide();

		--文字在表中的索引值
		local TextNameIndex = {6030, 6074, 4777};

		if ChildFrames and ChildFrames[index] then
			--需要切换的页面存在才切换
			local frameObj = getglobal(ChildFrames[i]);

			for i = 1, btnNum do
				local btnName = Name..i; 
				local textName = btnName.."Name";
				local text = GetS(TextNameIndex[i]);
				local btnBkg = getglobal(btnName.."Pic");
				local textObj = getglobal(textName);

				--文字
				textObj:SetText(text);

				--选中状态, 切换页面
				if index == i then
					btnBkg:SetTexUV("mngfg_btn09");
					textObj:SetTextColor(254, 249, 209);
					frameObj:Show();
				else
					btnBkg:SetTexUV("mngfg_btn010");
					textObj:SetTextColor(228, 205, 145);
					frameObj:Hide();
				end
			end
		else
			--需要切换的页面不存在
		end
	end
end

function MiniWorksProductionSwitchBtnTemplate_OnClick()
	--切换页面
	local index = this:GetClientID();

	MiniWorksProductionPageSwitchBtnLayout(index);
end

function ProductionPageInfoFrameTakeBtn_Onclick(index)		--订阅/取消订阅
	Log("ProductionPageInfoFrameTakeBtn_Onclick:");
	--[[老版本
	local uin = getglobal("ProductionPageInfoFrameMini"):GetText();
	--]]

	--新版本
	local uiParent = this:GetParentFrame();
	local uin = getglobal(uiParent:GetName() .. "Mini"):GetText();

	Log("uin = " .. uin);
	TakeOrCancleSubscribeCommonHandle(index, uin);
	
end

--通用处理, 订阅/取消订阅
function TakeOrCancleSubscribeCommonHandle(index, uin)
	if index == 1 then
		--关注
		ReqFollowPlayer(uin, true)
		--订阅
		MiniworksSetOrCancelsubscribe(false, uin);
	elseif index == 2 then
		--取消关注
		ReqFollowPlayer(uin, false)
		--取消订阅
		MiniworksSetOrCancelsubscribe(true, uin);
	end
end

--我的订阅-----------------------------------------------------------------------------------
function SubscribeWndLayout()		--一级子页面布局
	local box_name = "SubscribePageBox";
	local archive_h = 115;
	local plane_name = box_name.."Plane";
	local titleHeight = 42;
	local topOffset = 10;
	local y = topOffset;

	for i = 1, 999 do
		if not HasUIFrame(box_name.."Wnd"..i) then
			break;
		end

		local Wnd = getglobal(box_name.."Wnd"..i);
		if Wnd:IsShown() then
			Wnd:SetPoint("top", plane_name, "top", 0, y);

			--二级页面地图布局
			-- local info_name = box_name.."Wnd"..i.."Info";
			-- SubscribeMapLayout(info_name);
			-- archive_h = titleHeight + getglobal(info_name):GetHeight();
			-- Wnd:SetHeight(archive_h);

			y = y + archive_h;
		end
	end

	--设置Plane大小
	local boxHeight = getglobal(box_name):GetRealHeight();
	if y < boxHeight then
		y = boxHeight;
	end

	local plane = getglobal(plane_name);
	local planeWidth =plane:GetWidth();
	plane:SetSize(planeWidth, y);
end

function SubscribeMapLayout(InfoName)		--二级页面, 地图布局
	local offset_X = 24;
	local archive_h = 132;
	local offset_top = 83;
	local y = 0;

	for i = 1, 999 do
		if not HasUIFrame(InfoName.."Archive"..i) then
			break;
		end

		local archive = getglobal(InfoName.."Archive"..i);

		if (i-1)%2 == 0 then
			archive:SetPoint("topright", InfoName, "top", 0 - offset_X, offset_top + y);
		else
			archive:SetPoint("topleft", InfoName, "top", offset_X, offset_top + y);
		end

		local row = math.floor(i / 2);
		y = row * archive_h;
	end

	--设置info总高度
	local totalHeight = y + offset_top + archive_h;
	local InfoObj = getglobal(InfoName);
	local infoWidth = InfoObj:GetWidth();
	InfoObj:SetSize(infoWidth, totalHeight);
end

function MiniWorksSelfCenterSubscribeEnter_OnClick()
	getglobal("MiniWorksSelfCenterSubscribePage"):Show();
	MapDownloadReportMgr:SetMiniWorkMyTypeSubType(ReportDefine.MiniWorkMytypeSubDefine.Subscribe);
end

function MiniWorksSelfCenterSubscribePageCloseBtn_OnClick()
	this:GetParentFrame():Hide();
end

function MiniWorksSelfCenterSubscribePage_OnShow()
	--[[老版本, 地图动态列表
	--1. 把时间重置一下, 表示从头开始拉
	g_nProdectionDynaminCurTime = 0;

	--2. 重置活动窗口
	getglobal("SubscribePageBox"):resetOffsetPos();

	--3. 重置订阅动态列表
	g_SubscribeDynamicList = nil;
	g_SubscribeDynamicList = {};
	g_SubscribeDynamicPlayerInfo = nil;
	g_SubscribeDynamicPlayerInfo = {};

	--4. 改成这样的????, 拉取订阅列表
	MiniworksGetSubscribeList(0, UpdateSubscribePageDynamicUI);
	]]

	--新版本, 订阅用户列表
	getglobal("SubscribePageBox"):resetOffsetPos();
	MiniworksGetSubscribeList(0, UpdateSubscribePageUsersList);
end

--新版本, 订阅列表, 订阅用户信息
function UpdateSubscribePageUsersList()
	Log("UpdateSubscribePageUsersList:");

	--拉取订阅用户的信息,接口:GetProductionPageIntroduce();
	--1. 把uin列表整理成顺序的.
	local uinList = {};
	for k, v in pairs(g_SubscribeList) do
		table.insert(uinList, k);
	end

	--Log("uinList:")

	--2. 更新个人信息
	for i = 1, 999 do
		local WndName = "SubscribePageBoxWnd"..i;

		if not HasUIFrame(WndName) then
			break;
		end

		local WndObj = getglobal(WndName);

		--更新信息
		if uinList and #uinList > 0 and uinList[i] then
			--存在信息, 显示此条
			WndObj:Show();

			--2. 拉取个人信息	
			local userdata = {_uin = uinList[i], _WndObj = WndObj};
			GetSubscribeDynamicSelfInfo(uinList[i], Resp_UpdateSubscribeSignalUserInfo, userdata);
		else
			WndObj:Hide();
		end	

	end

	--3. 调整滑动窗口布局
	SubscribeWndLayout();
end

--更新单条订阅用户信息, 参考:Rest_GetSubscribeDynamicSelfInfo()
function Resp_UpdateSubscribeSignalUserInfo(ret, userdata)
	Log("Resp_UpdateSubscribeSignalUserInfo:");

	if ret and ret.ret == 0 and ret.profile and userdata then
		local WndObj = userdata._WndObj;
		local WndName = WndObj:GetName();
		local InfoName = getglobal(WndName.."Name");
		local InfoMini = getglobal(WndName.."Mini");
		local headObj = getglobal(WndName.."HeadBtnBkg");

		-- 1. 名字
		local infoNameStr = "";
		if ret.profile.RoleInfo and ret.profile.RoleInfo.NickName then
			infoNameStr = ret.profile.RoleInfo.NickName;			
		end
		InfoName:SetText(infoNameStr);

		-- 2. 迷你号
		local infoMiniStr = userdata._uin or 0;
		InfoMini:SetText(infoMiniStr);

		-- 3. 头像
		local model = ret.profile.RoleInfo and ret.profile.RoleInfo.Model or 0;
		local skinid = ret.profile.RoleInfo and ret.profile.RoleInfo.SkinID or 0;
		if ret.profile.header and ret.profile.header.url then
			--自定义头像
			SetUserHeadIconByUrl(ret.profile.header.url, ret.profile.header.checked, uin, headObj);
		else
			-- headObj:SetTexture("ui/roleicons/"..GetHeadIconIndex( model, skinid )..".png");
			HeadCtrl:SetPlayerHeadByUin(headObj, userdata._uin, model, skinid)
		end

		--3. 头像框
		local headFrameUI = WndName .. "HeadBtnFrame";
		local headFrameId = ret.profile.head_frame_id or 1;
		Log("HeadFrameId = " .. headFrameId);
		changeHeadFrameTxtPic( (ret.profile.head_frame_id or 1) , headFrameUI );

		-- 4. 保存个人信息
		local bIsExisted = false;
		ret.profile.uin = infoMiniStr;
		if #g_SubscribeDynamicPlayerInfo > 0 then
			for i = 1, #g_SubscribeDynamicPlayerInfo do
				if ret.profile.uin == g_SubscribeDynamicPlayerInfo[i].profile.uin then
					--已存在
					bIsExisted = true;
				end
			end
		end

		if not bIsExisted then
			Log("Save UserProfile, uin = " .. ret.profile.uin);
			table.insert(g_SubscribeDynamicPlayerInfo, ret);
		end
	end
end

function UpdateSubscribePageDynamicUI()				--更新"我的订阅"界面UI
	--2. 更新订阅动态
	UpdateSubscribeDynamic();

	--1. 一级子页面布局
	SubscribeWndLayout();
end

function MiniWorksSelfCenterSubscribePage_OnHide()

end

function SubscribePageBox_OnMovieFinished()			--加载更多动态
	Log("SubscribePageBox_OnMovieFinished");
	Log("g_nProdectionDynaminCurTime = "..g_nProdectionDynaminCurTime);

	if g_nProdectionDynaminCurTime <= 0 then
		--没有更多动态
	else
		--加载更多动态
		MiniworksGetSubscribeList(g_nProdectionDynaminCurTime, UpdateSubscribePageDynamicUI);
	end
end

function UpdateSubscribeDynamic()		--更新订阅动态
	Log("UpdateSubscribeDynamic:");

	--1. 更新个人信息
	for i = 1, 999 do
		local WndName = "SubscribePageBoxWnd"..i;
		--Log("WndName = " .. WndName);

		if not HasUIFrame(WndName) then
			break;
		end

		local WndObj = getglobal(WndName);

		--更新信息
		--g_SubscribeDynamicList = {1, 2};
		if g_SubscribeDynamicList and #g_SubscribeDynamicList > 0 and g_SubscribeDynamicList[i] then
			--存在信息, 显示此条
			WndObj:Show();

			UpdateSignalSubscribeDynamic(WndObj, g_SubscribeDynamicList[i]);
		else
			WndObj:Hide();
		end	

	end

	--2. 更新地图ui
end

function UpdateSignalSubscribeDynamic(_WndObj, _SignalDynamic)		--更新单条动态
	local WndName = _WndObj:GetName();
	local timeObj = getglobal(WndName.."Time");

	--1. 时间
	local timeString = tostring(_SignalDynamic.t or 0);
	timeString = os.date("%Y-%m-%d    %H:%M:%S", timeString);	
	timeObj:SetText(timeString);

	--2. 拉取个人信息
	local userdata = {uin = _SignalDynamic.uin, WndObj = _WndObj};
	GetSubscribeDynamicSelfInfo(_SignalDynamic.uin, Rest_GetSubscribeDynamicSelfInfo, userdata);
end

function RestSubscribeDynamicMap(maps, _WndObj)						--拉取动态中的地图回调
	--地图保存在这里:g_SubscribeDynamicMapList
	Log("RestSubscribeDynamicMap:");
	Log("maps:");

	if false then
		--1. 拉取一张地图, 废弃
		local WndName = _WndObj:GetName();
		local InfoName = WndName .. "Info";

		--Log("WndName = "..WndName);

		if maps and maps[1] and _WndObj then
			local map = maps[1];

			--1. 刷新UI
			local archui = getglobal(InfoName.."Archive1");
			UpdateSingleArchive(archui, map, {hideRankTag=false});

			--2. 地图列表
			table.insert(g_SubscribeDynamicMapList, map);
		else
			--拉取地图失败
			getglobal(InfoName .. "Archive1"):Hide();
			getglobal(InfoName .. "Error"):Show();
		end
	else
		--2. 拉取一组10张地图
		for i = 1, #maps do
			local map = maps[i];
			table.insert(g_SubscribeDynamicMapList, map);
		end

		for i = 1, 999 do
			local WndName = "SubscribePageBoxWnd"..i;
			local ArchiveName = WndName .. "InfoArchive1"
			--Log("WndName = " .. WndName);

			if not HasUIFrame(WndName) then
				break;
			end

			if i > #g_SubscribeDynamicList then
				break;
			end

			--更新信息
			local errObj = getglobal(WndName.."InfoError");
			local archui = getglobal(ArchiveName);
			for k = 1, #g_SubscribeDynamicMapList do
				if g_SubscribeDynamicList[i] and g_SubscribeDynamicList[i].wid == g_SubscribeDynamicMapList[k].owid then
					--有地图信息
					local map = g_SubscribeDynamicMapList[k];
					errObj:Hide();
					archui:Show();
					UpdateSingleArchive(archui, map, {hideRankTag=false});					
					break;
				else					
					errObj:Show();
					archui:Hide();
				end
			end
		end
	end
end

function GetSubscribeDynamicSelfInfo(_op_uin, _callback, _userdata)			--拉取个人信息
	local uin_ = _op_uin;
	local url_ = g_http_root_map .. 'miniw/profile?act=getProfile&op_uin=' .. uin_.. '&' .. 'fast=110' .. '&' .. http_getS1Map();
	Log( "url_ = "..url_ );

	if _callback then
		--如果个人信息已经有了, 则不用重复拉取?????????????????
		if g_SubscribeDynamicPlayerInfo and #g_SubscribeDynamicPlayerInfo > 0 then
			for i = 1, #g_SubscribeDynamicPlayerInfo do
				if _op_uin == g_SubscribeDynamicPlayerInfo[i].profile.uin then
					--_callback = Rest_GetSubscribeDynamicSelfInfo			
					_callback(g_SubscribeDynamicPlayerInfo[i], _userdata);				
					return;
				end
			end
		end

		Log("Don`t_Existed, Need_Get_From_Server");
		ns_http.func.rpc( url_, _callback, _userdata, nil, ns_http.SecurityTypeHigh);
	end
end

function Rest_GetSubscribeDynamicSelfInfo(ret, _userdata)
	--_userdata = {uin = _SignalDynamic.uin, WndObj = _WndObj};
	Log("Rest_GetSubscribeDynamicSelfInfo:");

	local WndObj = _userdata.WndObj;
	local WndName = WndObj:GetName();
	local InfoName = getglobal(WndName.."InfoName");
	local InfoMini = getglobal(WndName.."InfoMini");
	local headObj = getglobal(WndName.."InfoHead");

	if ret and ret.ret == 0 and ret.profile then
		-- 1. 名字
		local infoNameStr = "";
		if ret.profile.RoleInfo and ret.profile.RoleInfo.NickName then
			infoNameStr = ret.profile.RoleInfo.NickName;			
		end
		InfoName:SetText(infoNameStr);

		-- 2. 迷你号
		local infoMiniStr = _userdata.uin or 0;
		InfoMini:SetText(infoMiniStr);

		-- 3. 头像
		local model = ret.profile.RoleInfo.Model or 0;
		local skinid = ret.profile.RoleInfo.SkinID or 0;
		if ret.profile.header and ret.profile.header.url then
			--自定义头像
			SetUserHeadIconByUrl(ret.profile.header.url, ret.profile.header.checked, uin, headObj);
		else
			-- headObj:SetTexture("ui/roleicons/"..GetHeadIconIndex( model, skinid )..".png");
			HeadCtrl:SetPlayerHeadByUin(headObj, _userdata.uin, model, skinid)
		end

		-- 4. 保存个人信息
		ret.profile.uin = infoMiniStr;
		table.insert(g_SubscribeDynamicPlayerInfo, ret);
	end
end

function GetSubscribeDynamicMapFromArchive(archui )
	Log("GetSubscribeDynamicMapFromArchive:");

	local map = nil;
	local WndObj = archui:GetParentFrame():GetParentFrame();
	local archindex = WndObj:GetClientID() or 1;

	if g_SubscribeDynamicList and g_SubscribeDynamicList[archindex] and g_SubscribeDynamicMapList then
		for i = 1, #g_SubscribeDynamicMapList do
			if g_SubscribeDynamicList[archindex].wid == g_SubscribeDynamicMapList[i].owid then
				--找到了地图
				Log("break: i = "..i);
				map = g_SubscribeDynamicMapList[i];
				break;
			end
		end
	end

	return map;
end

--我的[Desc5]-----------------------------------------------------------------------------------
function MiniWorksSelfCenterPurchaseEnter_OnClick()
	getglobal("MiniWorksSelfCenterPurchasePage"):Show();
end

function MiniWorksSelfCenterPurchasePageCloseBtn_OnClick()
	this:GetParentFrame():Hide();
end

function MiniWorksSelfCenterPurchasePage_OnShow()

end

function MiniWorksSelfCenterPurchasePage_OnHide()

end

--作者之家-----------------------------------------------------------------------------------
function MiniWorksSelfCenterHomeEnter_OnClick()
	getglobal("MiniWorksSelfCenterHomePage"):Show();
end

function MiniWorksSelfCenterHomePageCloseBtn_OnClick()
	this:GetParentFrame():Hide();
end

function MiniWorksSelfCenterHomePage_OnShow()

end

function MiniWorksSelfCenterHomePage_OnHide()

end

--关注的鉴赏家---------------------------------------------------------------------------------
local t_AttentionConnoisseurUins = {};
local t_ConnoisseurUins = {};
local pullingAttentionConnoisseurUins = false;

function AttentionConnoisseruOnSwitchAccount()
	t_AttentionConnoisseurUins = {};
	pullingAttentionConnoisseurUins = false;
end

function UpdateAttentionConnoisseurUins(t_ConnoisseurUins)
	t_AttentionConnoisseurUins = {};
	for i=1, #t_ConnoisseurUins do
		local fridData = GetFlowingPlayerData and GetFlowingPlayerData(tonumber(t_ConnoisseurUins[i])) or nil;
		if fridData then
			table.insert(t_AttentionConnoisseurUins, tonumber(t_ConnoisseurUins[i]));
		end
	end

	print("kekeke t_AttentionConnoisseurUins", t_AttentionConnoisseurUins)
end

function UpdateAttentionConnoisserurUI()
	for i=1, 999 do
		if HasUIFrame("AttentionConnoisseur"..i) == false then
			break;
		end

		local ui = getglobal("AttentionConnoisseur"..i);
		if i <= #t_AttentionConnoisseurUins then
			ui:Show();

			local fridData = GetFlowingPlayerData and GetFlowingPlayerData(t_AttentionConnoisseurUins[i]) or nil;
			if fridData then
				getglobal(ui:GetName().."Name"):SetText(fridData.name or "");
				getglobal(ui:GetName().."Uin"):SetText(GetS(4714, getShortUin(fridData.uin or 0)));

                HeadCtrl:SetPlayerHeadByUin(ui:GetName().."HeadBtnIcon",fridData.uin,fridData.headmodel,fridData.headskin)
				if fridData.headurl and fridData.headurl ~= "" then
					HeadCtrl:SetPlayerHead(ui:GetName().."HeadBtnIcon",1,fridData.headurl)
				end
                HeadFrameCtrl:SetPlayerheadFrameName(ui:GetName().."HeadBtnFrame",fridData.headframe);

			else
				getglobal(ui:GetName().."Name"):SetText("???");
				getglobal(ui:GetName().."Uin"):SetText(GetS(4714, getShortUin(t_AttentionConnoisseurUins[i] or 0)));
				getglobal(ui:GetName().."HeadBtnIcon"):SetTexture("items/hand.png");
			end
		else
			ui:Hide();
		end
	end

	local num = #t_AttentionConnoisseurUins;
	local height = math.max((num-1)*117 + 109, 515);
	getglobal("AttentionConnoisseurBoxPlane"):SetHeight(height);

end

function AttentionConnoisserurRefreshUpdate()
	threadpool:work(function ()
		local box = getglobal("AttentionConnoisseurBox");
		while box:IsShown() do
			--刷新好友的详细信息
			for i=1, 999 do
				if HasUIFrame("AttentionConnoisseur"..i) == false then
					break;
				end
				local fridUi = getglobal("AttentionConnoisseur"..i);

				local top = fridUi:GetRealTop();
				local boxtop = box:GetRealTop();

				if fridUi:IsShown() and top - boxtop <= 465 then
					local fridData = GetFlowingPlayerData and GetFlowingPlayerData(t_AttentionConnoisseurUins[i]) or nil;
					if fridData and fridData.needpull and fridData.needpull < 3 then
						fridData.needpull = fridData.needpull + 1;
						local code, ret = QueryGriendInfo(fridData.uin);
						if not box:IsShown() then return end

						if code == ErrorCode.OK then
							OnFriendInfo(ret);
						else
							ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3)
						end
					end
				end
			end

			threadpool:wait(2);
		end
	end)
end

function ReqConnoisseurUins()
	if pullingAttentionConnoisseurUins then return end

	pullingAttentionConnoisseurUins = true;

	local url = mapservice.getserver().."/miniw/map/?act=get_all_experter_list";

	url = UrlAddAuth(url);
	if ClientMgr:isPureServer() == false then
		ShowLoadLoopFrame(true, "file:miniworks -- func:ReqConnoisseurUins");
	end
	ns_http.func.rpc(url, RespConnoisseurUins, nil, nil, true);
end

function RespConnoisseurUins(data)
	print("kekeke RespConnoisseurUins:", data);
	ShowLoadLoopFrame(false)

	if pullingAttentionConnoisseurUins then
		pullingAttentionConnoisseurUins = false;
		if data.ret ~= "" then
			local t = StringSplit(data.ret, ",");
			if t then
				print("kekeke t_ConnoisseurUins", t)
				t_ConnoisseurUins = t;
				UpdateAttentionConnoisseurUins(t);
				UpdateAttentionConnoisserurUI();
				AttentionConnoisserurRefreshUpdate();
			end
		end
	end
end

function AttentionConnoisseurBox_OnMouseMove()
	getglobal("AttentionConnoisseurBoxFuncFrame"):Hide();
end

function AttentionConnoisseurTemplate_OnClick()
	getglobal("AttentionConnoisseurBoxFuncFrame"):Hide();

end

function AttentionConnoisseurTemplateFuncBtn_OnClick()
	if getglobal("AttentionConnoisseurBoxFuncFrame"):IsShown() then
		getglobal("AttentionConnoisseurBoxFuncFrame"):Hide();
	else
		local index = this:GetParentFrame():GetClientID()
		local top = this:GetRealTop();
		local boxtop = getglobal("AttentionConnoisseurBox") :GetRealTop();

		if top - boxtop > 324 then
			getglobal("AttentionConnoisseurBoxFuncFrameArrow"):setUvType(5);
			getglobal("AttentionConnoisseurBoxFuncFrame"):SetPoint("bottomright", this:GetName(), "topright", 12, 14);	
			getglobal("AttentionConnoisseurBoxFuncFrameArrow"):SetPoint("top", "AttentionConnoisseurBoxFuncFrame", "bottomright", -45, -13);
		else
			getglobal("AttentionConnoisseurBoxFuncFrameArrow"):setUvType(0);
			getglobal("AttentionConnoisseurBoxFuncFrame"):SetPoint("topright", this:GetName(), "bottomright", 12, -14);	
			getglobal("AttentionConnoisseurBoxFuncFrameArrow"):SetPoint("bottom", "AttentionConnoisseurBoxFuncFrame", "topright", -45, 13);
		end	

		getglobal("AttentionConnoisseurBoxFuncFrame"):SetClientID(index);
		getglobal("AttentionConnoisseurBoxFuncFrame"):Show();
	end
end

function AttentionConnoisseurBoxFuncCancelAttention_OnClick()
	local index = this:GetParentFrame():GetClientID();
	if index > 0 and index <= #(t_AttentionConnoisseurUins) then
		local uin = t_AttentionConnoisseurUins[index];

		ReqFollowPlayer(uin, false);

		--关注-1
		local txt_ = getglobal( "PlayerCenterFrameSubPage1Info2Txt");
		local text_ = GetS(210)..":".. (ns_playercenter.attention_count - 1);
		txt_:SetText( text_ );

		if  ns_playercenter.server_ret.profile and ns_playercenter.server_ret.profile.relation then
			ns_playercenter.server_ret.profile.relation.friend_beattention = ns_playercenter.attention_count - 1;
		end
	end
end

function RemoveAttentionConnoisseur(uin)
	for k, v in ipairs(t_AttentionConnoisseurUins) do
		if v == uin then 
			table.remove(t_AttentionConnoisseurUins, k);
			return true;
		end
	end

	return false;
end

function TryAddAttentionConnoisseur(uin)
	print("kekeke TryAddAttentionConnoisseur", t_ConnoisseurUins, uin);
	for k, v in ipairs(t_ConnoisseurUins) do
		if tonumber(v) == uin then 
			table.insert(t_AttentionConnoisseurUins, tonumber(v));
			break;
		end
	end
end

function UpdateAttentionConnoisseurOnChange(uin, type)
	print("kekeke UpdateAttentionConnoisseurOnChange", uin, type)
	if type == "remove" then
		if RemoveAttentionConnoisseur(uin) then
			if getglobal("AttentionConnoisseurBox"):IsShown() then
				getglobal("AttentionConnoisseurBoxFuncFrame"):Hide();
				UpdateAttentionConnoisserurUI();
			end
		end
	elseif type == "add" then
		TryAddAttentionConnoisseur(uin);
	end

	print("kekeke t_AttentionConnoisseurUins", t_AttentionConnoisseurUins)
end

function AttentionConnoisseurBoxFuncDetail_OnClick()
	local index = this:GetParentFrame():GetClientID();
	if index > 0 and index <= #(t_AttentionConnoisseurUins) then
		local uin = t_AttentionConnoisseurUins[index];
		SearchPlayerByUin(uin);
	end
end

function MiniWorksSelfCenterAttentionConnoisseurEnter_OnClick()
	getglobal("MiniWorksSelfCenterAttentionConnoisseurPage"):Show();
	MapDownloadReportMgr:SetMiniWorkMyTypeSubType(ReportDefine.MiniWorkMytypeSubDefine.Attention);
end

function MiniWorksSelfCenterAttentionConnoisseurPageCloseBtn_OnClick()
	this:GetParentFrame():Hide();
end

function MiniWorksSelfCenterAttentionConnoisseurPage_OnLoad()
	for i = 1, 999 do
		if HasUIFrame("AttentionConnoisseur"..i) == false then
			break;
		end

		local ui = getglobal("AttentionConnoisseur"..i);
		ui:SetPoint("topleft", "AttentionConnoisseurBoxPlane", "topleft", 0, 117 * (i - 1));
	end
end

function MiniWorksSelfCenterAttentionConnoisseurPage_OnShow()
	if next(t_AttentionConnoisseurUins) == nil then
		ReqConnoisseurUins();
		UpdateAttentionConnoisserurUI();
	else
		UpdateAttentionConnoisserurUI();
		AttentionConnoisserurRefreshUpdate();
	end
end

function MiniWorksSelfCenterAttentionConnoisseurPage_OnHide()
	getglobal("AttentionConnoisseurBoxFuncFrame"):Hide();
end

function MiniWorksSelfCenterAttentionConnoisseurPage_OnClick()
	getglobal("AttentionConnoisseurBoxFuncFrame"):Hide();
end

--评测邀请-------------------------------------------------------------------------------------
local EvaluationInviteArchive_Max = 20;
function MiniWorksSelfCenterEvaluationInviteEnter_OnClick()
	-- body
	getglobal("MiniWorksFrameSelfCenterEvaluationInviteRedTag"):Hide();
	getglobal("MiniWorksSelfCenterEvaluationInvitePage"):Show();
end

function MiniWorksSelfCenterEvaluationInvitePageCloseBtn_OnClick()
	this:GetParentFrame():Hide();
end

function MiniWorksSelfCenterEvaluationInvitePageRefresh_OnClick()
	EvaluationInviteArchiveLayout(false);
	getglobal("EvaluationInviteBox"):resetOffsetPos();
	ReqExpertTaskMaps();
end

function EvaluationInviteArchiveLayout(isShow)
	for i=1, EvaluationInviteArchive_Max/2 do
		for j=1, 2 do
			local index = j+(i-1)*2;
			local archUI 	= getglobal("EvaluationInvite"..index);
			if isShow then
				archUI:Show();
				archUI:SetWidth(591);
				local likeIcon 	= getglobal("EvaluationInvite"..index.."NowPlayerIcon");
				local funcBtn 	= getglobal("EvaluationInvite"..index.."FuncBtn");
				archUI:SetPoint("topleft", "EvaluationInviteBoxPlane", "topleft", (j-1)*617, (i-1)*130);
				funcBtn:SetPoint("right", archUI:GetName(), "right", -5, -10);
				likeIcon:SetTexUV("mngf_icon_js");
			else
				archUI:Hide();
			end
		end
	end
end

function MiniWorksSelfCenterEvaluationInvitePage_OnLoad()
	EvaluationInviteArchiveLayout(true);
end

function MiniWorksSelfCenterEvaluationInvitePage_OnShow()
	EvaluationInviteArchiveLayout(false);
	getglobal("EvaluationInviteBox"):resetOffsetPos();

	if next(mapservice.expertTaskMapsAllOwids) == nil then
		local t = getkv("expert_task_owids", "expert_task");
		if t and next(t) ~= nil then
			print("kekeke MiniWorksSelfCenterEvaluationInvitePage_OnShow t", t)
			--local t = JSON:decode(str);
			for i=1, #t do
				table.insert(mapservice.expertTaskMapsAllOwids, t[i])
			end
		else
			print("kekeke MiniWorksSelfCenterEvaluationInvitePage_OnShow t is nil")

			ReqExpertTaskMaps();
		 	return;
		end
	end

	if next(mapservice.expertTaskMaps) == nil then
		ReqExpertTaskMapDetail();
	else
		UpdateEvaluationInviteArchive();
	end
end

function MiniWorksSelfCenterEvaluationInvitePage_OnHide()
	-- body
end

function UpdateEvaluationInviteArchive()
	for i=1, EvaluationInviteArchive_Max do
		local archUI = getglobal("EvaluationInvite"..i);
		if i <= #mapservice.expertTaskMaps then
			local map = mapservice.expertTaskMaps[i];

			archUI:Show();
			UpdateSingleArchive(archUI, map);
			--多少人邀请测评
			local nowPlayer = getglobal(archUI:GetName().."NowPlayer");
			if map.rank == 1 and map.push_up1 and map.push_up1 > 0 then
				nowPlayer:SetText(GetS(1306, map.push_up1))
			else
				nowPlayer:SetText(GetS(1307))
			end
		else
			archUI:Hide();
		end 
	end

	local num = #(mapservice.expertTaskMaps);
	print("kekeke UpdateEvaluationInviteArchive num", num);
	local height = math.ceil(#(mapservice.expertTaskMaps)/2) * 130;
	height = height > 515 and height or 515;

	getglobal("EvaluationInviteBoxPlane"):SetHeight(height);
end
-----------------------------------------------------------------------------------------------
--左侧导航按钮红点处理
function MiniWorksLeftLabelBtnRedTagHandle(bIsShow)
	--专题要加上红点
	Log("MiniWorksLeftLabelBtnRedTagHandle:");
	local needShow = false;

	for i = 1, Theme_List_Max do
		if i <= #(mapservice.topics) then
			local topic = mapservice.topics[i];
			
			--刷新专题红点
			if MiniWorksThemeredTag_SaveOrGet(topic.id, topic.red_version, false) then
				--LLDO:更新左侧专题按钮红点
				needShow = true;
			end
		end
	end

	if needShow then
		getglobal("MiniWorksFrameLabel4RedTag"):Show();
	else
		getglobal("MiniWorksFrameLabel4RedTag"):Hide();
	end

	local time = getkv("expert_task_time");
	if getExpert() == 2 and (time == nil or not AccountManager:isSameDay(time, os.time())) then
		setkv("expert_task_time", os.time());
		getglobal("MiniWorksFrameLabel3RedTag"):Show();
		getglobal("MiniWorksFrameSelfCenterEvaluationInviteRedTag"):Show();
	end
end

--点击专题后, 保存标志.
function MiniWorksThemeredTag_SaveOrGet(themeId, red_version, bIsSave)
	--return value: true:需要显示红点, false:隐藏红点.
	Log("MiniWorksThemeredTag_SaveOrGet:");

	if themeId and red_version and 0 ~= red_version then
		local uin = GetMyUin();
		local strFlag = "map_topic_red_";
		local filename = "map_topic_redtag";		--缓存文件的文件名
		local k = "" .. themeId .. red_version;		--专题的唯一标识
		--[[
		文件:map_topic_redtag:
		map_topic_redtag = {
			[k] = true or false;
		}
		]]

		local cache = getkv(filename, filename) or {};

		if bIsSave then
			print("Save:");
			cache[k] = true;
			setkv(filename, cache, filename);
		else
			print("Get:");
			if cache and cache[k] then
				--已经点击过
				print("111:");
				return false;
			else
				print("222");
				return true;
			end
		end
	else
		return false;
	end
end

--刷新专题红点
function MiniWorksThemeredTag_Update(themeIndex, bIsSave)
	print("MiniWorksThemeredTag_Update: themeIndex = ", themeIndex);
	print(mapservice.topics[themeIndex]);
	local uiName = "Theme" .. themeIndex;
	local themeObj = getglobal(uiName);
	local topicOjb = mapservice.topics[themeIndex];
	local redtagObj = getglobal(uiName .. "RedTag");

	redtagObj:Hide();

	if MiniWorksThemeredTag_SaveOrGet(topicOjb.id, topicOjb.red_version, bIsSave) then
		redtagObj:Show();
	end

	--LLDO:更新左侧专题按钮红点
	--MiniWorksLeftLabelBtnRedTagHandle(true);
end

--------------------------------------------------------LLDO:end--------------------------------------------

--------------------------------------------------------MiniWorksFrameThemeList--------------------------------------------

local ThemeList_FirstShow = true;

function ThemeListTemplate_OnShow()
	local index = this:GetClientID();
	local id = tostring(mapservice.topics[index].id)
	standReportEvent("3", "MINI_WORKSHOP_SUBJECT_1","SubjectCard", "view",{slot=tostring(index),cid=id,ctype=GetInst("ReportGameDataManager"):GetCtypeDefine().ctypeSpecial})
end

function ThemeListTemplate_OnClick()
	local index = this:GetClientID();
	JumpToTopicByIndex(index);

	--LLDO:保存红点点击信息.
	MiniWorksThemeredTag_Update(index, true);

	--点击上报
	m_ExposureParam:HandleClick(this:GetName(), 2);
	local id = tostring(mapservice.topics[index].id)
	standReportEvent("3", "MINI_WORKSHOP_SUBJECT_1","SubjectCard", "click",{slot=tostring(index),cid=id,ctype=GetInst("ReportGameDataManager"):GetCtypeDefine().ctypeSpecial})
end

function JumpToTopicByIndex(index)
	EnterMainMenuInfo.MiWorkCurrentIndex = index
	-- dev by wuyuwang： 打开新的专题UI
	if isEnableNewMiniWorksMain and isEnableNewMiniWorksMain() then
		if not mapservice.topics[index] then 
			ReqTopicList()
			threadpool:wait(1)
		end
		
		if not mapservice.topics[index] then 
			return
		end 

		local config = {
			isOldData = true,
			item_id = "MINI_WORKSHOP_SUBJECT_1",
			id = mapservice.topics[index].id,
			title = mapservice.topics[index].title,
			txt1 = mapservice.topics[index].txt_big,
			pic1 = mapservice.topics[index].pic_big,
			map_list = mapservice.topics[index].map_owids
		}
		
		UIPackage:addPackage("miniui/miniworld/common_comp")
		GetInst("MiniUIManager"):OpenUI(
			"MiniWorksTopics", 
			"miniui/miniworld/newMiniWorks", 
			"MiniWorksTopicsAutoGen", 
			{config = config}
		)
	else 
		CurTopicObj = mapservice.topics[index];
		
		getglobal("MiniWorksFrameThemeList"):Hide();
		getglobal("MiniWorksFrameTheme"):Show();
		getglobal("ThemeArchiveBox"):resetOffsetPos();
	end

	if index == 1 and not AccountManager:getNoviceGuideState("guideworksnovice") then
		AccountManager:setNoviceGuideState("guideworksnovice", true);
		getglobal("MiniWorksFrameThemeListGuide"):Hide();
	end
end

function MiniWorksFrameThemeListGuide_OnLoad()
	this:setUpdateTime(0.05);
end

local FingerScale = 1;
local ScaleSpeed = 0.1;
function MiniWorksFrameThemeListGuide_OnUpdate()
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
	getglobal("MiniWorksFrameThemeListGuideFinger"):SetSize(width, height);
end

function MiniWorksFrameThemeList_OnLoad()
	
end

function MiniWorksFrameThemeList_OnShow()
	standReportEvent("3", "MINI_WORKSHOP_SUBJECT_1","-", "view")
	getglobal("MiniWorksFrameThemeListGuide"):Hide();
	if ThemeList_FirstShow then
		ThemeList_FirstShow = false;
		if not AccountManager:getNoviceGuideState("guideworksnovice") then
			getglobal("MiniWorksFrameThemeListGuide"):Show();
		end
	end
	if CurTopicObj ~= nil then
		getglobal("MiniWorksFrameThemeList"):Hide();
		getglobal("MiniWorksFrameTheme"):Show();
	end

	--LLDO:test
	if true then
		if mapservice.topics then
			Log("LLDO:topic_test: topics = :");
		end
	end

	--UpdateThemeList();

	threadpool:work(function()
		-- threadpool:wait(1);
		ReqTopicList();
	end);
end

function MiniWorksFrameThemeList_OnHide()

end

function MiniWorksFrameThemeList_OnThemeListPulled()
	UpdateThemeList();

	if IsJumpingToTopic() then
		RespJumpToTopic();
	end
end

function UpdateThemeList()
	print("UpdateThemeList:");
	for i = 1, Theme_List_Max do

		local themeui = getglobal("Theme"..i);

		if i <= #(mapservice.topics) then
			local topic = mapservice.topics[i];
			themeui:Show();
			UpdateSingleTopic(themeui, topic);

			--LLDO:刷新专题红点
			MiniWorksThemeredTag_Update(i, false)
		else
			themeui:Hide();
			UpdateSingleTopic(themeui, nil);
		end
	end

	--LLDO:更新左侧专题按钮红点
	MiniWorksLeftLabelBtnRedTagHandle(true);

	local plane = getglobal("ThemeListBoxPlane");
	local totalHeight = math.ceil(#(mapservice.topics) / 2) * SingleArchiveHeight + 16;
	local height = getglobal("ThemeListBox"):GetRealHeight();

	if totalHeight < height then
		totalHeight = height;
	end
	plane:SetHeight( totalHeight);
end

function UpdateSingleTopic(ui, topic)
	local uiname = ui:GetName();
	if topic then
		local title = topic.title or "";
		getglobal(uiname.."Name"):SetText(title);

		local desc = topic.txt_small or "";
		getglobal(uiname.."Desc"):SetText(desc);

		getglobal(uiname.."Pic"):SetTexture(mapservice.thumbnailDefaultTexture);

		local texurl = topic.pic_small;
		if texurl and texurl~="" then
			local filename = mapservice.downloadThumbnailRoot..ns_advert.func.trimUrlFile(texurl).."_";  --"XXX.png_"
			ns_http.func.downloadPng(texurl, filename, nil, uiname.."Pic");
		end
	else
		getglobal(uiname.."Pic"):SetTexture("");
	end
end

------------------------------------------------------MiniWorksFrameTheme------------------------------------------

function MiniWorksFrameThemeBackBtn_OnClick()	
	CurTopicIndex = -1;
	CurTopicObj = nil;
	getglobal("MiniWorksFrameTheme"):Hide();
	getglobal("MiniWorksFrameThemeList"):Show();
end

function MiniWorksFrameBackBtn_OnClick()
	if getglobal("MiniWorksFrameTheme"):IsShown() then
		CurTopicIndex = -1;
		CurTopicObj = nil;
		getglobal("MiniWorksFrameTheme"):Hide();
		getglobal("MiniWorksFrameThemeList"):Show();
	-- elseif getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):DelBtn_OnClick()
	end	
	RoomFrameShowBackBtn(false)
end

function ThemeArchiveBoxMoreMap_OnClick()

end

function MiniWorksFrameTheme_OnShow()
	ClearThemeMapsUi();
	ReqTopicMaps(CurTopicObj);
	MiniworksSelfCenterShowBackBtn(true)

end

function MiniWorksFrameTheme_OnHide()
	MiniworksSelfCenterShowBackBtn(false)
end

function MiniWorksFrameThemeList_OnThemeMapsPulled()
	UpdateThemeMaps();
end

function ClearThemeMapsUi()

--	getglobal("ThemeArchiveBoxPublicityPic"):SetTexture(mapservice.thumbnailDefaultTexture);

	getglobal("MiniWorksFrameThemeTitleFrameDesc"):SetText("");

	for i = 1, Theme_Archive_Max do

		local archui = getglobal("ThemeArchive"..i);

		archui:Hide();
		UpdateSingleArchive(archui, nil);
	end

	local plane = getglobal("ThemeArchiveBoxPlane");
	local publicityHeight = 318;
	local scaleY = UIFrameMgr:GetScreenScaleY();
	local totalHeight = publicityHeight + math.ceil(#(CurTopicObj.maps) / 2) * SingleArchiveHeight + 16;

	local height = getglobal("ThemeArchiveBox"):GetHeight() / scaleY;
	if totalHeight < height then
		totalHeight = height;
	end
	plane:SetHeight(totalHeight);
end

function UpdateThemeMaps()
	----[[
	--不去服务器拉专题图了
	--getglobal("ThemeArchiveBoxPublicityPic"):SetTexture(mapservice.thumbnailDefaultTexture);

	--local texurl = CurTopicObj.pic_big;
	--if texurl and texurl~="" then
		--local filename = mapservice.downloadThumbnailRoot..ns_advert.func.trimUrlFile(texurl).."_";  --"XXX.png_"
		--ns_http.func.downloadPng(texurl, filename, nil, "ThemeArchiveBoxPublicityPic");
	--end
	--]]

	if CurTopicObj then
		local title_ = CurTopicObj.title or "";
		getglobal("MiniWorksFrameThemeTitleFrameTitle"):SetText(title_);

		local desc = CurTopicObj.txt_big or "";
		getglobal("MiniWorksFrameThemeTitleFrameDesc"):SetText("——" .. desc);


		for i = 1, Theme_Archive_Max do

			local archui = getglobal("ThemeArchive"..i);

			if i <= #(CurTopicObj.maps) then
				local map = CurTopicObj.maps[i];
				archui:Show();
				UpdateSingleArchive(archui, map, {hideRankTag=true});
			else
				archui:Hide();
				UpdateSingleArchive(archui, nil);
			end
		end

		local plane = getglobal("ThemeArchiveBoxPlane");
		local publicityHeight = 318;
		local totalHeight = publicityHeight + math.ceil(#(CurTopicObj.maps) / 2) * SingleArchiveHeight + 16;

		local height = getglobal("ThemeArchiveBox"):GetHeight();
		if totalHeight < height then
			totalHeight = height;
		end
		plane:SetHeight(totalHeight);
	end
end

-----------------------------------------------------------MiniWorksFrameCollect-------------------------------------------------

function MiniWorksFrameCollect_OnLoad()
	
end

function MiniWorksFrameCollect_OnShow()
	local temp = 
	{
		"-",
		"ContentComboBox",
		"RankComboBox",
		"Refrech"
	}
	for _, value in ipairs(temp) do
		standReportEvent("3", "MINI_WORKSHOP_COLLECT_1",value, "view")
	end
	
	UpdateFilterName(5);
	if IsUserOuterChecker(AccountManager:getUin()) then
		getglobal("MiniWorksFrameCollectClearAllCollectionBtn"):Show()
	else
		getglobal("MiniWorksFrameCollectClearAllCollectionBtn"):Hide()
	end

	--从迷你工坊-收藏里进入游戏，从游戏退出返回收藏，不做数据刷新
	local fromEndGame = EnterMainMenuInfo and EnterMainMenuInfo.FromEndGame
	local beforeLabel = EnterMainMenuInfo and EnterMainMenuInfo.MiWorkCurLabel or -1
	if fromEndGame and beforeLabel == 5 then
		EnterMainMenuInfo.FromEndGame = nil
		return
	end
	CollectMapsDoFilter(Collect_CurLabel);
end

function MiniWorksFrameCollect_OnHide()
	ShowLoadLoopFrame(false)
	CancelAllDownloadingThumbnails();
end

function MiniWorksFrameCollectRefresh_OnClick()
	--CollectMapsDoFilter(Collect_CurLabel);
	if CanRefreshWorksByServer() then
		ReqCollectMaps();
	else
		MiniWorksFrameCollect_OnMapsPulled();
	end
	standReportEvent("3","MINI_WORKSHOP_COLLECT_1","Refrech","click")
end

function MiniWorksFrameCollectFilter_OnClick()
	ShowArchiveFilterFrame(Collect_CurLabel, Collect_CurOrder, mapservice.collectOrderNames, 1);
end

function MiniWorksFrameCollectFilter2_OnClick()
	ShowArchiveFilterFrame(Collect_CurLabel, Collect_CurOrder, mapservice.collectOrderNames, 2);
end

function MiniWorksFrameCollect_SetFilter(label, order)
	Log("MiniWorksFrameCollect_SetFilter: "..label..", "..order);
	if label ~= Collect_CurLabel or order ~= Collect_CurOrder then
		Collect_CurLabel = label;
		Collect_CurOrder = order;

		CollectMapsDoFilter(Collect_CurLabel);
		
		UpdateFilterName(5);
		WorksFilterStatistics(5, label, order);
	end
end

function MiniWorksFrameCollect_OnMapsPulled()
	UpdateCollectArchive();

	if getglobal("MiniWorksFrame"):IsShown() and getglobal("ArchiveInfoFrameIntroduce"):IsShown() and CurArchiveMap ~= nil then
		UpdateShareArchiveInfoIntroduce();
	elseif getglobal("MiniWorksFrame"):IsShown() and getglobal("ArchiveInfoFrameEx"):IsShown() and CurArchiveMap ~= nil then
		--新地图详情页面(MiniWorksArchiveInfoFrame)则调用MiniWorksMapInfoIntroduce();
		MiniWorksMapInfoIntroduce();
	end

	if isEnableNewLobby() and GetInst("UIManager"):GetCtrl("lobbyMapArchiveList") then
		GetInst("UIManager"):GetCtrl("lobbyMapArchiveList"):updateCollectView(true)
	end
end

function UpdateCollectArchive()
	Log("UpdateCollectArchive");

	for i = 1, Collect_Archive_Max do

		local archui = getglobal("CollectArchive"..i);

		if i <= #(mapservice.collectMaps) then
			local map = mapservice.collectMaps[i];
			archui:Show();
			UpdateSingleArchive(archui, map);
		else
			archui:Hide();
			UpdateSingleArchive(archui, nil);
		end
	end

	local plane = getglobal("CollectArchiveBoxPlane");
	local totalHeight = math.ceil(#(mapservice.collectMaps) / 2) * SingleArchiveHeight + 16;
	local scaleY = UIFrameMgr:GetScreenScaleY();
	local height = getglobal("CollectArchiveBox"):GetRealHeight() / scaleY;
	if totalHeight < height then
		totalHeight = height;
	end
	plane:SetHeight(totalHeight);
end

-------------------------------------------------------------MiniWorksFrameSearch1---------------------------------------------------------
function MiniWorksFrameSearch1InputEdit_OnFocusLost()
	if ClientMgr:isMobile() then
		MiniWorksFrameSearch1InputBtn_OnClick();
	end
end

function MiniWorksFrameSearch1InputEdit_OnEnterPressed()
	UIFrameMgr:setCurEditBox(nil);
	MiniWorksFrameSearch1InputBtn_OnClick();
end

function MiniWorksFrameSearch1InputBtn_OnClick()
	local input = getglobal("MiniWorksFrameSearch1InputEdit"):GetText();

	if input == nil or input == "" then
		ShowGameTips(GetS(21739), 3);
		return;
	end
	--去掉空格
	input = LuaReomve(input," ")
	input = LuaReomve(input,"\r")
	input = LuaReomve(input,"\n")
	--GM账号不检测敏感词
	if CheckFilterString(input) and not getglobal("MiniWorksFrameSetBlackBtn"):IsShown() then
		return;
	end

	if not CanUseNet() then
		return;		
	end

	for i=1, Search_Archive_Max/2 do
		for j=1, 2 do
			local archive = getglobal("SearchArchive"..((i-1)*2+j));
			if j == 1 then
				archive:SetPoint("topright", "SearchArchiveBoxPlane", "top", -3, (i-1)*SingleArchiveHeight);
			else
				archive:SetPoint("topleft", "SearchArchiveBoxPlane", "top", 3, (i-1)*SingleArchiveHeight);
			end
		end
	end

	for i=1,60 do
		getglobal("SearchAuthor"..i):Hide();
	end
	
	getglobal("SearchArchiveBox"):setCurOffsetY(0);
	getglobal("SearchArchiveBoxRoleInfo"):Hide();
	ReqSearchMapsByType(input);
end

function MiniWorksFrameSearch1_OnResultsPulled()
	local uin = tonumber(getglobal("MiniWorksFrameSearch1InputEdit"):GetText()) or 0;
	-- if getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 	uin = tonumber(getglobal("MiniWorksFrameSearchInputEdit"):GetText()) or 0;
	-- end

	if #(mapservice.searchedMaps) == 0 then
		ShowGameTips(GetS(3831), 3);	--3831:作者还没有分享地图

		--搜索迷你号埋点:该迷你号无存档
		Miniworks_UselessReport(2, uin, 2);
	else
		--该迷你号有存档
		Miniworks_UselessReport(2, uin, 1);
	end
	-- if getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):UpdateAuthorSearchMaps()
	-- else
 		UpdateSearchArchive();
 	-- end

	if getglobal("MiniWorksFrame"):IsShown() and getglobal("ArchiveInfoFrameIntroduce"):IsShown() and CurArchiveMap ~= nil then
		UpdateShareArchiveInfoIntroduce();
	end
end

function MiniWorksFrameSearch1_OnLoad()

end

function MiniWorksFrameSearch1_OnShow()
	-- UpdateSearchArchive();
	if not getglobal("ArchiveInfoFrameEx"):IsShown() then
		MiniWorksFrameSearch1DelBtn_OnClick();
	end

	UpdateMiniWorksFrameSearch1()
end

function MiniWorksFrameSearch1_OnHide()
	ShowLoadLoopFrame(false)
	CancelAllDownloadingThumbnails();
end

function UpdateSearchArchive()
	for i = 1, Search_Archive_Max do

		local archui = getglobal("SearchArchive"..i);

		if i <= #(mapservice.searchedMaps) then
			local map = mapservice.searchedMaps[i];
			archui:Show();
			UpdateSingleArchive(archui, map);
		else
			archui:Hide();
			UpdateSingleArchive(archui, nil);
		end
	end

	local plane = getglobal("SearchArchiveBoxPlane");
	--还有个头 显示用户信息 需要+1
	local totalHeight = (math.ceil(#(mapservice.searchedMaps) / 2) + 1 )* SingleArchiveHeight;
	if totalHeight < getglobal("SearchArchiveBox"):GetRealHeight() then
		totalHeight = getglobal("SearchArchiveBox"):GetRealHeight();
	end

	plane:SetHeight(totalHeight);
end

function MiniWorksFrame_ShowSearchUinUI(uin)
	HideLobby();
	getglobal("MiniWorksFrame"):Show();

	local searchLabel = 6;
	if searchLabel ~= CurLabel then
		CurLabel = searchLabel;
		UpdateLabelState();
		ShowCurWorksFrame(true);
	end

	getglobal("MiniWorksFrameSearch1InputEdit"):SetText(tostring(uin));
	MiniWorksFrameSearch1InputBtn_OnClick();
end

-------------------------------------------------------------MiniWorksFrameMaterial---------------------------------------------------------

function MiniWorksFrameMaterial_OnShow()
	ReqMaterialMods();
	MiniworksUpdateMaterialMods();
end

function MiniWorksFrameMaterial_OnHide()
	ShowLoadLoopFrame(false)
	CancelAllDownloadingThumbnails();
end

function MiniWorksFrameMaterial_OnMaterialModsPulled()
	MiniworksUpdateMaterialMods();
end

function MiniWorksFrameMaterial_OnUnlockStateUpdated()
	MiniworksUpdateMaterialMods();
	if getglobal("MaterialInfoFrame"):IsShown() then
		SetMaterialInfoFrame(MaterialInfoFrame_mod);
	end
end

function MiniworksUpdateMaterialMods()
	Log("MiniworksUpdateMaterialMods");
	local materialLibCtrl = GetInst("UIManager"):GetCtrl("MaterialLib")
	local materialLibMaterialCtrl = GetInst("UIManager"):GetCtrl("MaterialLibMaterial")
	if materialLibCtrl and IsUIFrameShown("MaterialLib") and materialLibMaterialCtrl and IsUIFrameShown("MaterialLibMaterial") then
		materialLibMaterialCtrl:UpdateMaterialMods();
		return
	end
	for i = 1, Material_Mods_Max do

		local ui = getglobal("MaterialsEntry"..i);
		
		if i <= #(mapservice.materialmods) then
			local mod = mapservice.materialmods[i];
			Log(mod.uuid);
			ui:Show();
			UpdateSingleMod(ui, mod);
		else
			ui:Hide();
			UpdateSingleMod(ui, nil);
		end
	end

	local plane = getglobal("MaterialsPlane");
	local totalHeight = math.ceil(#(mapservice.materialmods) / 2) * SingleArchiveHeight + 16;

	local height = getglobal("Materials"):GetRealHeight();
	if totalHeight < height then
		totalHeight = height;
	end

	--设置plane高
	plane:SetHeight(totalHeight);
end

local buyingMaterialMod = nil;

--下载材质包
function Miniworks_DownLoadMeteralPack(mod, btnUI)
	Log("Miniworks_DownLoadMeteralPack: btnUI = " .. btnUI);
	local modSize = ModMgr:isModExisted(mod.uuid);

	if -1 == modSize then
		--已存在, 直接跳转
		JumpToShowMaterialMod();
	else
		--不存在, 需下载
		Log("DownLoad: uuid = " .. mod.uuid);

		if mMeteralLoadState and mMeteralLoadState[mod.uuid] and mMeteralLoadState[mod.uuid].loading then
			--正在下载, 不要重复下载
			Log("Is Loading Now!");
		else
			Log("Start Load!");
			ModMgr:downLoadModFile(mod.uuid);
			mMeteralLoadState[mod.uuid] = {loading = true, toLoadSize = modSize, _btnUI = btnUI};

			--设置按钮为正在下载状态
			SetMeteralBtnDownloadState(btnUI, 1);
		end

		--埋点
		if mod.cost_item_id == 10000 then
			--卡通
			-- statisticsGameEvent(10002, '%d', 1);
		elseif mod.cost_item_id == 10002 then
			--写实
			-- statisticsGameEvent(10002, '%d', 2);
		end
	end
end

--设置材质包下载按钮的下载状态
function SetMeteralBtnDownloadState(btnUI, state)
	Log("SetMeteralBtnDownloadState: state = " .. state);
	if btnUI then
		local downicon = getglobal(btnUI .. "DownIcon");
		local downsize = getglobal(btnUI .. "DownSize");
		local text = getglobal(btnUI .. "TxtUse");

		Log("btnUI = " .. btnUI);
		downicon:Hide();
		downsize:Hide();

		if 1 == state then
			--正在下载
			text:Show();
			text:SetText(GetS(9258));	--正在下載
		elseif 2 == state then
			--下载完成
			text:Show();
			text:SetText(GetS(4772));	--前往使用
			text:SetTextColor(51,55,55);
		end
	end
end

function MiniworksModTemplateFuncBtn_OnClick()
	local index = this:GetParentFrame():GetClientID();
	local mod = mapservice.materialmods[index];
	local userdata = {_mod = mod, _btnUI = this:GetName()};

	if ns_data.mod_unlock_list and ns_data.mod_unlock_list[mod.uuid] then  --查询过已经解锁了
		Miniworks_DownLoadMeteralPack(mod, this:GetName());
	else	
		ReqGetMaterialModUnlocked(mod.uuid, function(hasunlocked, userdata)
			local mod = userdata._mod;
			local btnUI = userdata._btnUI;
			Log("material mod "..mod.uuid.."  hasunlocked="..tostring(hasunlocked));

			if hasunlocked then  --使用
				if not ns_data.mod_unlock_list then
					ns_data.mod_unlock_list = {};
				end
				ns_data.mod_unlock_list[mod.uuid] = true;
				Miniworks_DownLoadMeteralPack(mod, btnUI);
			else
				AskBuyMaterialMod(mod);
			end
		end, userdata);
	end
end

function JumpToShowMaterialMod()
	local creationCenterMainCtrl = GetInst("MiniUIManager"):GetCtrl("CreationCenterMain")
	if creationCenterMainCtrl and GetInst("MiniUIManager"):IsShown("CreationCenterMain") then
		creationCenterMainCtrl:ReturnBtnClick()
	end
	getglobal("MiniWorksFrame"):Hide();
	ShowLobby();
	--新版开始游戏全量了，这段打开某个地图卡片可以不用了
	-- local worldlist = AccountManager:getMyWorldList();
	-- if worldlist:getNumWorld() > 0 then
	-- 	local wdesc = worldlist:getWorldDesc(0);
	-- 	if isEnableNewLobby and isEnableNewLobby() then
	-- 		GetInst("lobbyDataManager"):SetCurSelectedArchiveData(wdesc.worldid)
	-- 	else
	-- 		ArchiveWorldDesc = wdesc
	-- 		ArchiveWorldDescWorldId  = ArchiveWorldDesc.worldid
	-- 	end
	-- 	ShowMapDetailInfo();
	-- 	getglobal("ArchiveInfoFrameEditMaterialBtnGuide"):Show();
	-- end
end

function AskBuyMaterialMod(mod)
	if mod.cost_item_id > 0 and mod.cost_item_num > 0 then
		local costItem = ItemDefCsv:get(mod.cost_item_id);

		local canAfford = false;
		if mod.cost_item_id == 10000 then  --迷你豆
			canAfford = mod.cost_item_num <= AccountManager:getAccountData():getMiniBean();
		elseif mod.cost_item_id == 10002 then  --迷你币
			canAfford = mod.cost_item_num <= AccountManager:getAccountData():getMiniCoin();
		else
			return;
		end

		if canAfford then
			buyingMaterialMod = mod;
			local text = GetS(3801, costItem.Name, mod.cost_item_num, mod.name);
			StoreMsgBox(5, text, GetS(3802), -4, mod.cost_item_num, mod.cost_item_num, mod.cost_item_id);
			getglobal("StoreMsgboxFrame"):SetClientString("确认解锁材质包");
		else
			buyingMaterialMod = nil;
			
			if mod.cost_item_id == 10000 then  --迷你豆
				ShowGameTips(GetS(4775), 3);
				getglobal("BeanConvertFrame"):Show();
			elseif mod.cost_item_id == 10002 then  --迷你币
				local lackNum = mod.cost_item_num - AccountManager:getAccountData():getMiniCoin();
				local cost, buyNum = GetPayRealCost(lackNum);
				local text = GetS(453, cost, buyNum);
				StoreMsgBox(6, text, GetS(456), -3, lackNum, mod.cost_item_num, nil, NotEnoughMiniCoinCharge, cost);			
			end			
		end
	end
end

function ConfirmBuyMaterialMod()
	Log("ConfirmBuyMaterialMod "..buyingMaterialMod.uuid);
	ReqUnlockMaterialMod(buyingMaterialMod);
end

function MiniworksModTemplate_OnClick()
	local index = this:GetClientID();
	local mod = mapservice.materialmods[index];
	SetMaterialInfoFrame(mod);
	standReportEvent("3", "MINI_WORKSHOP_TEXTURE_1","TextureCard", "click",{slot=tostring(index)})
end

-------------------------------------------------------------通用---------------------------------------------------------

function UpdateSingleArchive(archui, map, options)

	if options == nil then
		options = {hideRankTag=false};
	end

	local archname = archui:GetName();
	if map then
		local mapname = map.name or "";

		--工坊搜索单独处理
		if getglobal("SearchArchiveBox"):IsShown() then
			local input = getglobal("MiniWorksFrameSearch1InputEdit"):GetText();
			local text = JoinHighlightString(mapname,input);

			getglobal(archname.."Name"):SetText(ReplaceFilterString(text))
			
		else
			getglobal(archname.."Name"):SetText(ReplaceFilterString(mapname));
		end

		

		GetMapThumbnail(map, archname.."Pic");

		local author_name = map.author_name or "";
		local author_uin = map.author_uin or "";
		-- getglobal(archname.."AuthorName"):SetText(ReplaceFilterString(author_name));
		G_VipNamePreFixEntrency(getglobal(archname.."AuthorName"), author_uin, ReplaceFilterString(author_name), {r=101,g=116,b=118})

		local download_num = map.download_count or 0;
		
		if  lang_show_as_K() and download_num > 1000 then
			getglobal(archname.."Down"):SetText(string.format("%0.1f", download_num/1000).. 'K');
		elseif download_num > 10000 then
			getglobal(archname.."Down"):SetText(string.format("%0.1f", download_num/10000)..GetS(3841)); --X.X万
		else
			getglobal(archname.."Down"):SetText(tostring(download_num));
		end

		--累计被玩次数
		local play_count = map.play_count or 0;
		local play_count_ui = getglobal(archname.."NowPlayer");
		if nil ~= play_count_ui then
			play_count_ui:SetText(tostring(play_count));
		end

		--改为调用地图分类管理体系的接口来显示分类
		GetInst("MapKindMgr"):ShowKind(map.label,1,1,map.worldtype,getglobal(archname.."LabelName"),getglobal(archname.."LabelIcon"),nil)
		
		local display_rank = map.display_rank or 0;
		local TagName = getglobal(archname.."TagName");
		local TagBkg = getglobal(archname.."TagBkg");

		if display_rank == 0 or options.hideRankTag then  --0=已上传
			TagBkg:Hide();
			TagName:Hide();
		elseif display_rank == 1 then  --1=已投稿
			TagBkg:Show();
			TagBkg:SetTextureHuiresXml("ui/mobile/texture2/miniwork.xml");
			TagBkg:SetTexUV("label_map_hot");	--设置人气脚标:grzx_jiaobiao->mngfg_rqdb
			TagName:Show();
			TagName:SetText(GetS(3842));  --待审
			TagName:SetTextColor(55, 54, 49);	 --设置颜色
		elseif display_rank == 2 then  --2=已精选
			TagBkg:Show();
			TagBkg:SetTextureHuiresXml("ui/mobile/texture2/miniwork.xml");
			TagBkg:SetTexUV("label_map_selection");
			TagName:Show();
			TagName:SetText(GetS(3843));  --精选
			TagName:SetTextColor(55, 54, 50);	 --设置颜色
		elseif display_rank == 3 then  --3=已推荐
			TagBkg:Hide();
			TagName:Hide();
		end

		if map.open_code == 1 then
			getglobal(archname.."HaveCodePic"):Show();
		else
			getglobal(archname.."HaveCodePic"):Hide();
		end

		--有mod
		if map.have_mod == 1 and not getglobal(archname.."HaveCodePic"):IsShown() then
			getglobal(archname.."HaveModPic"):Show();
		else
			getglobal(archname.."HaveModPic"):Hide();
		end


		local isShowActivity = false
		if map.activityId > 0 and type(mapservice.allActivity) == "table" then
			for i = 1,#mapservice.allActivity do
				if map.activityId == mapservice.allActivity[i].id then
					isShowActivity = true
				end
			end
		end

		--参加了投稿活动 (这里不用限制 curActivityType)
		if isShowActivity then
			getglobal(archname.."ActivityLabelBkg"):Show();
			getglobal(archname.."ActivityLabelName"):Show();
		else
			getglobal(archname.."ActivityLabelBkg"):Hide();
			getglobal(archname.."ActivityLabelName"):Hide();
		end

		--分数
		SetArchiveGradeUI(getglobal(archname.."Grade"), map.star or 3);
		UpdateSingleArchiveDownloadState(archui, map);
	else
		getglobal(archname.."Pic"):SetTexture("");
	end
end

function UpdateSingleConnoisseurArchive(archui, map, showConnoisseurInfo)
	local archuiName = archui:GetName();
	if map then
		--存档地图
		GetMapThumbnail(map, archuiName.."Pic");

		--Label
		local gameLabel = tonumber(map.label) or 0;
		if gameLabel == 0 then
			gameLabel = GetLabel2Owtype(map.worldtype or 0);
		end
		SetRoomTag(nil, getglobal(archuiName.."LabelName"), gameLabel);

		--map名字
		local mapname = map.name or "";
		getglobal(archuiName.."Name"):SetText(ReplaceFilterString(mapname));

		--tag
		local display_rank = map.display_rank or 0;
		print("kekeke display_rank", display_rank);
		if display_rank == 0 then  --0=已上传
			getglobal(archuiName.."TagBkg"):Hide();
			getglobal(archuiName.."TagName"):Hide();
		elseif display_rank == 1 then  --1=已投稿
			getglobal(archuiName.."TagBkg"):Show();
			getglobal(archuiName.."TagBkg"):SetTextureHuiresXml("ui/mobile/texture2/miniwork.xml");
			getglobal(archuiName.."TagBkg"):SetTexUV("label_map_hot");	--设置人气脚标:grzx_jiaobiao->mngfg_rqdb
			getglobal(archuiName.."TagName"):Show();
			getglobal(archuiName.."TagName"):SetText(GetS(3842));  --待审
			--getglobal(archuiName.."TagName"):SetTextColor(6, 121, 146);	 --设置颜色
		elseif display_rank == 2 then  --2=已精选
			getglobal(archuiName.."TagBkg"):Show();
			getglobal(archuiName.."TagBkg"):SetTextureHuiresXml("ui/mobile/texture2/miniwork.xml");
			getglobal(archuiName.."TagBkg"):SetTexUV("label_map_selection");
			getglobal(archuiName.."TagName"):Show();
			getglobal(archuiName.."TagName"):SetText(GetS(3843));  --精选
			--getglobal(archuiName.."TagName"):SetTextColor(123, 82, 3);	 --设置颜色
		elseif display_rank == 3 then  --3=已推荐
			getglobal(archuiName.."TagBkg"):Show();
			getglobal(archuiName.."TagBkg"):SetTextureHuiresXml("ui/mobile/texture2/miniwork.xml");
			getglobal(archuiName.."TagBkg"):SetTexUV("label_map_hot");
			getglobal(archuiName.."TagName"):Show();
			getglobal(archuiName.."TagName"):SetText(GetS(191));  --推荐
			--getglobal(archuiName.."TagName"):SetTextColor(38, 89, 54);	 --设置颜色
		end

		--鉴赏家
		getglobal(archuiName.."ConnoisseurInfo"):SetClientString("");
		if map.push_comments and type(map.push_comments) == 'table' and next(map.push_comments) ~= nil and map.push_comments[1] then
			--评测内容
			getglobal(archuiName.."Desc"):SetText(unescape(map.push_comments[1].msg));
			if showConnoisseurInfo then
				--鉴赏家头像
				HeadCtrl:SetPlayerHeadByUin(archuiName.."ConnoisseurInfoHead",map.push_comments[1].uin,map.push_comments[1].uin_icon)
				HeadFrameCtrl:SetPlayerheadFrameName(archuiName.."ConnoisseurInfoHeadFrame",map.push_comments[1].head_frame_id);
				--鉴赏家名字
				-- getglobal(archuiName.."ConnoisseurInfoName"):SetText( GetS( 1308, ReplaceFilterString(unescape(map.push_comments[1].nickname)) ) );
				local nickName = ReplaceFilterString(unescape(map.push_comments[1].nickname))
				nickName = GetNewFriendNote(map.push_comments[1].uin,nickName)
				local showName =  GetS(1308, nickName)
				G_VipNamePreFixEntrency(getglobal(archuiName.."ConnoisseurInfoName"), map.push_comments[1].uin,showName, {r = 101, g = 116, b = 118},nil,nil,nil,true)

				getglobal(archuiName.."ConnoisseurInfoHead"):Show();

				getglobal(archuiName.."ConnoisseurInfo"):SetClientString(tostring(map.push_comments[1].uin));
			end
		else
			getglobal(archuiName.."Desc"):SetText("");
			if showConnoisseurInfo then
				getglobal(archuiName.."ConnoisseurInfoName"):SetText("");
				getglobal(archuiName.."ConnoisseurInfoHead"):SetTexture("");
				getglobal(archuiName.."ConnoisseurInfoHead"):Hide();
			end
		end
	else
		getglobal(archuiName.."Pic"):SetTexture("");
	end
end

function UpdateSingleMod(ui, mod, options)

	options = options or {};

	local uiname = ui:GetName();
	if mod then
		getglobal(uiname.."Name"):SetText(mod.name or "");

		getglobal(uiname.."Pic"):SetTexture(mapservice.thumbnailDefaultTexture);
		if mod.thumb_url and #mod.thumb_url > 0 then
			local cachePath = mapservice.downloadThumbnailRoot..GetCacheFileNameFromUrl(mod.thumb_url);
			DownloadThumbnail({mod.thumb_url}, cachePath, uiname.."Pic");
		end

		-- getglobal(uiname.."AuthorName"):SetText(mod.author_name or "");
		G_VipNamePreFixEntrency(getglobal(uiname.."AuthorName"), mod.author_uin, mod.author_name, {r=101,g=116,b=118})

		getglobal(uiname.."Desc"):SetText(mod.desc or "");

		local download_num = mod.download_count or 0;
		
		if  lang_show_as_K() and download_num > 1000 then
			getglobal(uiname.."Down"):SetText(string.format("%0.1f", download_num/1000).. 'K');
		elseif  download_num > 10000 then
			getglobal(uiname.."Down"):SetText(string.format("%0.1f", download_num/10000)..GetS(3841)); --X.X万
		else
			getglobal(uiname.."Down"):SetText(tostring(download_num));
		end

		UpdateSingleModFuncBtn(getglobal(uiname.."FuncBtn"), mod);

	else
		getglobal(uiname.."Pic"):SetTexture("");
	end
end

function UpdateSingleModFuncBtn(funcBtn, mod)
	local getglobal = getglobal;
	if mapservice.unlockedModsPulled then

		local funcBtnName = funcBtn:GetName();
		local TxtUse = getglobal(funcBtnName.."TxtUse");
		local CostIcon = getglobal(funcBtnName.."CostIcon");
		local CostNum = getglobal(funcBtnName.."CostNum");

		funcBtn:Show();

		local hasunlocked = (mapservice.unlockedModUuids[mod.uuid] == true);

		if hasunlocked then
			--已解锁, 判断是否需要下载
			--"材质包详情页"特殊处理, 有"解锁"字样
			TxtUse:Show();
			TxtUse:SetText(GetS(4772));
			CostIcon:Hide();
			CostNum:Hide();

			local modSize = ModMgr:isModExisted(mod.uuid) or 0;
			Log("UpdateSingleModFuncBtn, modSize = " .. modSize);
			if funcBtnName == "MaterialInfoFrameIntroduceUnlockBtn" then
				getglobal(funcBtnName.."TxtUnlock"):Hide();
			else
				--设置背景:mngf_btn05
				--funcBtn:SetSize(91, 43);
				if -1 == modSize then
					-- -1:代表已存在
					getglobal(funcBtnName.."Normal"):SetTextureTemplate("TemplateBkg15");
					getglobal(funcBtnName .. "PushedBG"):SetTextureTemplate("TemplateBkg15");
					--getglobal(funcBtnName.."PushedBG"):SetSize(87, 40);
				else
					--不存在, 需要下载
					getglobal(funcBtnName.."Normal"):SetTextureTemplate("TemplateBkg9");
					getglobal(funcBtnName .. "PushedBG"):SetTextureTemplate("TemplateBkg9");
					--getglobal(funcBtnName.."PushedBG"):SetSize(87, 40);
				end
			end

			--下载相关
			local modSize = ModMgr:isModExisted(mod.uuid) or 0;
			Log("UpdateSingleModFuncBtn, modSize = " .. modSize);
			if -1 == modSize then
				-- -1:代表已存在
				Log("UpdateSingleModFuncBtn: uuid = " .. mod.uuid .. ", Existed!!!");
				getglobal(funcBtnName.."DownIcon"):Hide();
				getglobal(funcBtnName.."DownSize"):Hide();
			else
				--不存在, 需要下载
				Log("UpdateSingleModFuncBtn: uuid = " .. mod.uuid .. ", Not Existed!!!");
				modSize = modSize / 1024 / 1024;
				local modSize = string.format("%.1f", modSize);
				TxtUse:Hide();
				getglobal(funcBtnName.."DownIcon"):Show();
				getglobal(funcBtnName.."DownSize"):Show();
				getglobal(funcBtnName.."DownSize"):SetText(modSize .. "M");
			end
		else
			--未解锁
			--"材质包详情页"特殊处理, 有"解锁"字样
			TxtUse:SetText(GetS(4771))
			TxtUse:SetTextColor(55,54,51);
			CostIcon:Show();
			CostNum:Show();

			if funcBtnName == "MaterialInfoFrameIntroduceUnlockBtn" then
				TxtUse:Hide();
				getglobal(funcBtnName.."TxtUnlock"):Show();
				SetItemIcon(getglobal(funcBtnName.."CostIcon"), mod.cost_item_id);
				getglobal(funcBtnName.."CostNum"):SetText(tostring(mod.cost_item_num));
			else
				TxtUse:Show();
				if mod.cost_item_num > 0 and mod.cost_item_id >= 0 then
					if mod.cost_item_id ~= 10002 then
						if mod.cost_item_id == 10000 then
							getglobal(funcBtnName.."CostIcon"):SetTexUV("icon_bean");
						else
							SetItemIcon(getglobal(funcBtnName.."CostIcon"), mod.cost_item_id);
						end
					end
					getglobal(funcBtnName.."CostNum"):SetText(tostring(mod.cost_item_num));
				else
					getglobal(funcBtnName.."CostIcon"):Hide();	
					getglobal(funcBtnName.."CostNum"):Hide();
				end

				--设置背景:mngfg_suo ??????
				--funcBtn:SetSize(91, 43);
				getglobal(funcBtnName.."Normal"):SetTextureTemplate("TemplateBkg9");
				getglobal(funcBtnName.."PushedBG"):SetTextureTemplate("TemplateBkg9");
			end

			getglobal(funcBtnName.."DownIcon"):Hide();
			getglobal(funcBtnName.."DownSize"):Hide();
		end
	else
		funcBtn:Hide();
	end
end

function UpdateSingleArchiveDownloadState(archui, map)
	local funcBtnUi = getglobal(archui:GetName().."FuncBtn");
	UpdateFuncBtnDownloadState(funcBtnUi, map);
end

function UpdateFuncBtnDownloadState(funcBtnUi, map, frameName, isDownloaded)
	local funcBtnName = funcBtnUi:GetName();
	local isBigBtn = false
	if string.find(funcBtnName, "ArchiveInfoFrameExBodyRightFuncBtn") 
	or string.find(funcBtnName, "MapRoomBodyRightDownloadBtn")
	or string.find(funcBtnName, "ArchiveDownloadFuncBtn") then
		isBigBtn = true
	end

	Log("UpdateFuncBtnDownloadState "..funcBtnName);

	local state = GetMapDownloadBtnState(map);
	--Log("map owid="..map.owid.." download buttontype: "..state.buttontype..", "..state.progress);

	getglobal(funcBtnName.."ProgressTex"):SetWidth(90 * (state.progress / 100.0));
	if not isBigBtn then
		getglobal(funcBtnName.."ProgressTex"):SetWidth(90 * (state.progress / 100.0));
	else
		getglobal(funcBtnName.."ProgressTex"):SetWidth(180 * (state.progress / 100.0));
	end

	local size = map.size or 0;
	Log("UpdateFuncBtnDownloadState size:"..size);
	getglobal(funcBtnName.."Size"):SetText(string.format("%0.2f", size/1048576).."M"); --X.XXM
	if not isBigBtn then
		if size/1048576 < 100 then
			getglobal(funcBtnName.."Size"):SetFontSize(18)
		else
			getglobal(funcBtnName.."Size"):SetFontSize(17)
		end
	end

	local PicDown = getglobal(funcBtnName.."PicDown");	--下载、暂停图标

	if state.buttontype == DOWNBTN_DOWNLOAD then  --显示下载按钮
		--显示下载箭头图片,"下载"字样依然要show出来, 因为下载的时候是根据字样来判断下载状态的,可以将大小调味1*1进行隐藏
		if nil ~= PicDown then
			PicDown:Show();
			PicDown:SetTexUV("icon_download_black");
		end

		getglobal(funcBtnName.."Name1"):Show();
		getglobal(funcBtnName.."Name1"):SetSize(1, 1);	--设置大小
		getglobal(funcBtnName.."Name1"):SetTextColor(55, 54, 51);
		getglobal(funcBtnName.."Name2"):Hide();
		getglobal(funcBtnName.."Name3"):Hide();
		--if string.find(funcBtnName,"EditFrame") == 1 then
			getglobal(funcBtnName.."Normal"):SetTextureTemplate("TemplateBkg9");
			getglobal(funcBtnName.."PushedBG"):SetTextureTemplate("TemplateBkg9");
		--end
		if isBigBtn then
			getglobal(funcBtnName.."Normal"):SetTextureTemplate("TemplateBkg3");
			getglobal(funcBtnName.."PushedBG"):SetTextureTemplate("TemplateBkg3");
		end

		getglobal(funcBtnName.."ProgressBarBkg"):Hide();
		getglobal(funcBtnName.."ProgressTex"):Hide();
        getglobal(funcBtnName.."Size"):Show();

	elseif state.buttontype == DOWNBTN_CONTINUE_DOWNLOAD then  --显示继续下载按钮
		if nil ~= PicDown then
			PicDown:Show();
			PicDown:SetTexUV("icon_download_black");
			if isBigBtn then
				PicDown:Hide();
			end
		end

		getglobal(funcBtnName.."Name1"):Show();
		getglobal(funcBtnName.."Name1"):SetTextColor(55, 54, 51);
		--if not string.find(funcBtnName, "MiniWorksArchiveInfoFrameTopFuncBtn") then
			getglobal(funcBtnName.."Name1"):SetSize(1, 1);	--回复大小
		--end
		getglobal(funcBtnName.."Name2"):Hide();
		getglobal(funcBtnName.."Name3"):Hide();

		getglobal(funcBtnName.."ProgressBarBkg"):Show();
		getglobal(funcBtnName.."ProgressTex"):Show();
        getglobal(funcBtnName.."Size"):Show();

		if isBigBtn then
			getglobal(funcBtnName.."Normal"):SetTextureTemplate("TemplateBkg2");
			getglobal(funcBtnName.."PushedBG"):SetTextureTemplate("TemplateBkg2");
			getglobal(funcBtnName.."Name1"):SetText(GetS(434))
			getglobal(funcBtnName.."Name1"):SetSize(200, 23);
			getglobal(funcBtnName.."Size"):Hide();
		else
			getglobal(funcBtnName.."Normal"):SetTextureTemplate("TemplateBkg9");
			getglobal(funcBtnName.."PushedBG"):SetTextureTemplate("TemplateBkg9");
		end

	elseif state.buttontype == DOWNBTN_PAUSE_DOWNLOAD then  --显示暂停按钮
		if nil ~= PicDown then
			PicDown:Hide();
			--PicDown:SetTexUV("icon_pause_white");	--箭头改为暂停的标志"||", mngfg_zanting01
		end

		getglobal(funcBtnName.."Name1"):Hide();
		getglobal(funcBtnName.."Name2"):Hide();
		getglobal(funcBtnName.."Name3"):Show();
		getglobal(funcBtnName.."Name3"):SetTextColor(55, 51, 51);
		--getglobal(funcBtnName.."Name3"):SetSize(1, 1);
		--if string.find(funcBtnName,"EditFrame") == 1 then
			getglobal(funcBtnName.."Normal"):SetTextureTemplate("TemplateBkg21");
			getglobal(funcBtnName.."PushedBG"):SetTextureTemplate("TemplateBkg21");
		--end
		if isBigBtn then
			getglobal(funcBtnName.."Normal"):SetTextureTemplate("TemplateBkg3_1");
			getglobal(funcBtnName.."PushedBG"):SetTextureTemplate("TemplateBkg3_1");
		end
		
		getglobal(funcBtnName.."ProgressBarBkg"):Show();
		getglobal(funcBtnName.."ProgressTex"):Show();
        getglobal(funcBtnName.."Size"):Hide();

	elseif state.buttontype == DOWNBTN_ENTERWORLD then  --显示进入按钮
		if nil ~= PicDown then
			PicDown:Hide();
		end

		getglobal(funcBtnName.."Name1"):Hide();
		getglobal(funcBtnName.."Name2"):Show();
		getglobal(funcBtnName.."Name3"):Hide();
		getglobal(funcBtnName.."Name2"):SetTextColor(51, 55, 55);
		--if string.find(funcBtnName,"EditFrame") == 1 then
			getglobal(funcBtnName.."Normal"):SetTextureTemplate("TemplateBkg15");
			getglobal(funcBtnName.."PushedBG"):SetTextureTemplate("TemplateBkg15");
		--end
		
		if isBigBtn then
			getglobal(funcBtnName.."Normal"):SetTextureTemplate("TemplateBkg2");
			getglobal(funcBtnName.."PushedBG"):SetTextureTemplate("TemplateBkg2");
		end
		getglobal(funcBtnName.."ProgressBarBkg"):Hide();
		getglobal(funcBtnName.."ProgressTex"):Hide();
		getglobal(funcBtnName.."Size"):Hide();

		--下载完成上报
        -- m_ExposureParam:HandleDownLoadComplete(funcBtnName);
        
        --mark by liya 新埋点
        if frameName and frameName == "ArchiveInfoFrameEx" then
			if GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx") then
				GetInst("UIManager"):GetCtrl("ArchiveInfoFrameEx"):UpdateFuncBtnTitle()
			end
            ArchiveInfoFrameExFrame_StandReportSingleEvent("MINI_MAP_DETAIL_1", "SinglePlayer", "view", {cid = cid})
        end
	end

	return state.buttontype
end

function UpdateFilterName(curlabel)
	local mapKinds = GetInst("MapKindMgr"):GetMapKinds(1,1)
	if curlabel == 1 then
		local t_ChosenOrdelId ={3852, 3863, 3846, 3847};
		getglobal("MiniWorksFrameChosenFilterType"):SetText(GetS(mapKinds[Chosen_CurLabel].nameId));
		getglobal("MiniWorksFrameChosenFilter2Type"):SetText(GetS(t_ChosenOrdelId[Chosen_CurOrder]));
	elseif curlabel == 2 then
		local t_ReviewOrdelId ={3852, 4040, 3847};
		getglobal("MiniWorksFrameReviewFilterType"):SetText(GetS(mapKinds[Review_CurLabel].nameId));
		getglobal("MiniWorksFrameReviewFilter2Type"):SetText(GetS(t_ReviewOrdelId[Review_CurOrder]));
	elseif curlabel == 3 then
		local t_PlayerOrdelId ={3852};
		getglobal("MiniWorksFramePlayerFilterType"):SetText(GetS(mapKinds[Player_CurLabel].nameId));
		getglobal("MiniWorksFramePlayerFilter2Type"):SetText(GetS(t_PlayerOrdelId[Player_CurOrder]));
	elseif curlabel == 5 then
		local t_CollectOrdelId ={3852};
		getglobal("MiniWorksFrameCollectFilterType"):SetText(GetS(mapKinds[Collect_CurLabel].nameId));
		getglobal("MiniWorksFrameCollectFilter2Type"):SetText(GetS(t_CollectOrdelId[Collect_CurOrder]));
	elseif curlabel == 6 then
		local t_ConnoisseurOrdelId ={3852};
		getglobal("MiniWorksFrameConnoisseurFilterType"):SetText(GetS(mapKinds[Connoisseur_CurLabel].nameId));
		getglobal("MiniWorksFrameConnoisseurFilter2Type"):SetText(GetS(t_ConnoisseurOrdelId[Connoisseur_CurOrder]));
	end
end

function WorksFilterStatistics(curlabel, gamelabel, order)
	local t_LabelName = { "综合", "生存", "创造", "对战", "电路", "解密", "跑酷", "其他"};
	local t_PlayerOrderName = {"随机"};
	local t_ChosenOrderName = {"最新", "下载次数", "本周热门", "评分",};
	local t_ReviewOrderName = {"最新", "下载次数", "本周热门", "评分",};
	local t_CollectOrderName = {"默认"};
	local orderName, eventName;
	if curlabel == 1 then
		orderName = t_ChosenOrderName[order];
		eventName = "WorksChosenFilter";
	elseif curlabel == 2 then
		orderName = t_ReviewOrderName[order];
		eventName = "WorksReviewFilter";
	elseif curlabel == 3 then
		orderName = t_PlayerOrderName[order];
		eventName = "WorksPlayerFilter"
	elseif curlabel == 5 then
		orderName = t_CollectOrderName[order];
		eventName = "WorksCollectFilter";
	elseif curlabel == 6 then
		orderName = t_CollectOrderName[order];
		eventName = "WorksConnoisseurFilter";
	else
		return;
	end

	--统计
	StatisticsTools:gameEvent(eventName, "类别", t_LabelName[gamelabel], "排行", orderName);
end

function SetMiniWorksBoxsDealMsg(isDeal)
	-- getglobal("MainArchiveBox"):setDealMsg(isDeal);
	-- getglobal("MiniWorksFrameSearchList"):setDealMsg(isDeal);
	getglobal("MiniWorksMapTemplateListView"):setDealMsg(isDeal);
	getglobal("MiniWorksMainListFrame"):setDealMsg(isDeal);
	getglobal("ConnoisseurArchiveBox"):setDealMsg(isDeal);
	getglobal("ChosenArchiveBox"):setDealMsg(isDeal);
	getglobal("ReviewArchiveBox"):setDealMsg(isDeal);
	getglobal("PlayerArchiveBox"):setDealMsg(isDeal);
	getglobal("ThemeListBox"):setDealMsg(isDeal);
	getglobal("ThemeArchiveBox"):setDealMsg(isDeal);
	getglobal("CollectArchiveBox"):setDealMsg(isDeal);
	getglobal("SearchArchiveBox"):setDealMsg(isDeal);
	getglobal("Materials"):setDealMsg(isDeal);

	getglobal("SubscribePageBox"):setDealMsg(isDeal);	--LLDO:"我的订阅"界面
end

--------------------------------------MiniWorksHelpFrame---------------------------------------

function MiniWorksHelpFrame_OnLoad()
	getglobal("WorksHelpBoxContent"):SetText(GetS(3833), 61, 69, 70);
	getglobal("MiniWorksHelpFrameTitleName"):SetText(GetS(3832))
end

function MiniWorksHelpFrame_OnShow()
	SetMiniWorksBoxsDealMsg(false);
	local lines = getglobal("WorksHelpBoxContent"):GetTextLines();
	if lines <= 14 then
		getglobal("WorksHelpBoxPlane"):SetSize(890, 370);
		getglobal("WorksHelpBoxContent"):SetSize(890, 370);
	else
		getglobal("WorksHelpBoxPlane"):SetSize(890, 370+(lines-14)*30);
		getglobal("WorksHelpBoxContent"):SetSize(890, 370+(lines-14)*30);
	end
end

function MiniWorksHelpFrameClose_OnClick()
	getglobal("MiniWorksHelpFrame"):Hide();
	SetMiniWorksBoxsDealMsg(true);
end
---------------------------------------------------MaterialInfoFrame----------------------------------------------------

function SetMaterialInfoFrame(mod)
--	local 
	MaterialInfoFrame_mod = mod;

	getglobal("MaterialInfoFrameIntroduceName"):SetText(mod.name or "");

	-- getglobal("MaterialInfoFrameIntroduceAuthor"):SetText(mod.author_name or "");
	G_VipNamePreFixEntrency(getglobal("MaterialInfoFrameIntroduceAuthor"), mod.author_uin, mod.author_name, {r=101,g=116,b=118})

	getglobal("MaterialInfoFrameIntroduceThumb"):SetTexture(mapservice.thumbnailDefaultTexture);
	if mod.thumb_url and #mod.thumb_url > 0 then
		local cachePath = mapservice.downloadThumbnailRoot..GetCacheFileNameFromUrl(mod.thumb_url);
		DownloadThumbnail({mod.thumb_url}, cachePath, "MaterialInfoFrameIntroduceThumb");
	end

	getglobal("MaterialInfoFrameIntroduceDesc"):SetText(mod.desc or "");

	UpdateSingleModFuncBtn(getglobal("MaterialInfoFrameIntroduceUnlockBtn"), mod);

	if not getglobal("MaterialInfoFrame"):IsShown() then
		getglobal("MaterialInfoFrame"):Show();
		SetMiniWorksBoxsDealMsg(false);
	end
end

function MaterialInfoFrameUnlockBtn_OnClick()

	local mod = MaterialInfoFrame_mod;
	local userdata = {_mod = mod, _btnUI = this:GetName()};

	ReqGetMaterialModUnlocked(mod.uuid, function(hasunlocked, userdata)
		local mod = userdata._mod;
		local btnUI = userdata._btnUI;
		Log("material mod "..mod.uuid.."  hasunlocked="..tostring(hasunlocked));

		if hasunlocked then  --使用
			getglobal("MaterialInfoFrame"):Hide();
			-- JumpToShowMaterialMod();
			Miniworks_DownLoadMeteralPack(mod, btnUI);
		else
			AskBuyMaterialMod(mod);
		end
	end, userdata);
end

function MaterialInfoFrame_OnShow()
	getglobal("MaterialInfoFrameMask"):Show();
end

function MaterialInfoFrame_OnHide()
	getglobal("MaterialInfoFrameMask"):Hide();
	SetMiniWorksBoxsDealMsg(true);

	local materialLibCtrl = GetInst("UIManager"):GetCtrl("MaterialLib")
	local MaterialLibMaterialCtrl = GetInst("UIManager"):GetCtrl("MaterialLibMaterial")
	if materialLibCtrl and IsUIFrameShown("MaterialLib") and MaterialLibMaterialCtrl and IsUIFrameShown("MaterialLibMaterial") then
		MaterialLibMaterialCtrl:SetSlidingDealMsg(true)
	end
end

function MaterialInfoFrameCloseBtn_OnClick()
	getglobal("MaterialInfoFrame"):Hide();
end

function MaterialInfoFrameMask_OnClick()
	MaterialInfoFrameCloseBtn_OnClick();
end

--------------------------------------------WaitDownMapFrame--------------------------------------------------
local WaitDowmMapTime = 0;
function SetWaitDownMapFrame(map, options, waitTime)
	mapservice.wait_down.map = map;
	mapservice.wait_down.options = options;
	WaitDowmMapTime = math.random(math.ceil(waitTime/2), waitTime);
	if WaitDowmMapTime < 2 then
		WaitDowmMapTime = 2;
	end
	getglobal("WaitDownMapFrameText"):SetText(GetS(4902, WaitDowmMapTime));
	getglobal("WaitDownMapFrame"):Show();
end

function WaitDownMapFrameNoWaitBtn_OnClick()
	ClearWaitDownMapInfo();
	getglobal("WaitDownMapFrame"):Hide();
end

function WaitDownMapFrame_OnUpdate()
	WaitDowmMapTime = WaitDowmMapTime - arg1;
	if WaitDowmMapTime <= 0 then
		if mapservice.wait_down.map and mapservice.wait_down.options then
			ReqDownloadNewMap(mapservice.wait_down.map, mapservice.wait_down.options);
			ClearWaitDownMapInfo();
			getglobal("WaitDownMapFrame"):Hide();
		end
	else
		getglobal("WaitDownMapFrameText"):SetText(GetS(4902, math.ceil(WaitDowmMapTime)));
	end
end

function ClearWaitDownMapInfo()
	mapservice.wait_down = {};
	WaitDowmMapTime = 0;
end




--鉴赏家优选----------------------------------------------------------------------------------

function MiniWorksFrameMain_OnOptimalConnoisseurMapsPulled()
	Log("MiniWorksFrameMain_OnOptimalConnoisseurMapsPulled:");
	UpdateOptimalConnoisseurMaps();
	getglobal("MainArchiveBoxOptimalConnoisseurMapsHeaderText"):SetText(mapservice.mainOptimalTitle);

	MiniworksMain_SetHorizonLineSize("MainArchiveBoxOptimalConnoisseurMapsHeaderText");
end

function UpdateOptimalConnoisseurMaps()
	Log("UpdateConnoisseurMaps:");
	UpdateSectionMaps("MainArchiveBoxOptimalConnoisseurMaps", mapservice.mainOptimalMaps);
	UpdateMainLayout();
end

function MainArchiveBoxSectionOptimalConnoisseurMapsRefresh_OnClick()
	if CanRefreshWorksByServer() then
		ReqMainOptimalConnoisseurMaps();
	else
		MiniWorksFrameMain_OnOptimalConnoisseurMapsPulled();
	end
end




--精选玩法----------------------------------------------------------------------------------

function UpdateFeaturedGameplayMaps()


	UpdateSectionMaps("MainArchiveBoxFeaturedGameplay", mapservice.mainFeaturedGameplayMaps);
	UpdateMainLayout();
end

function MiniWorksFrameMain_OnFeaturedGameplayMapsPulled()
	UpdateFeaturedGameplayMaps();
	getglobal("MainArchiveBoxFeaturedGameplayHeaderText"):SetText(mapservice.mainFeaturedGameplayTitle);

	--MiniworksMain_SetHorizonLineSize("MainArchiveBoxFeaturedGameplayHeaderText");
end

function MainArchiveBoxSectionFeaturedGameplayMapsRefresh_OnClick()
	if CanRefreshWorksByServer() then
		ReqMainFeaturedGameplayMaps();
	else
		MiniWorksFrameMain_OnFeaturedGameplayMapsPulled();
	end
end











--------------------------------------------------- 工坊搜索--------------------------------------------------------------------
function WorksSelectAuthorTemplateFuncBtn_OnClick()
	-- body
	local target_uin = this:GetClientUserData(0);
	if target_uin == nil then
		return;
	end
	-- if getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):AuthorFuncBtn_OnClick(target_uin)
	-- 	return;
	-- end
	for i=1,60 do
		getglobal("SearchAuthor"..i):Hide();
	end
	ShowLoadLoopFrame(true, "file:miniworks -- func:WorksSelectAuthorTemplateFuncBtn_OnClick");
	mapservice.searchingUin = target_uin;
	mapservice.searchedMaps = {};
	mapservice.searchResultsPulledHttp = false;

	local url = mapservice.getserver().."/miniw/map/?act=search_user_maps&op_uin="..target_uin;
    url = AddPlayableArg(url)
	url = UrlAddAuth(url);
	-- 搜uin
	ns_http.func.rpc(url, RespSearchMapsByUin, nil, nil, true);


	local url = mapservice.getserver().."/miniw/profile/?act=getProfileBatch2&op_uin_list="..target_uin;
	url = UrlAddAuth(url);
	ns_http.func.rpc(url, RespSearchMapsByUinInfo, nil, nil, ns_http.SecurityTypeHigh);

	clearAllWorkSearchUI();
	getglobal("SearchArchiveBoxRoleInfo"):Show();
	for i=1, Search_Archive_Max/2 do
		for j=1, 2 do
			local archive = getglobal("SearchArchive"..((i-1)*2+j));
			if j == 1 then
				archive:SetPoint("topright", "SearchArchiveBoxPlane", "top", -3, (i-1)*SingleArchiveHeight+130);
			else
				archive:SetPoint("topleft", "SearchArchiveBoxPlane", "top", 3, (i-1)*SingleArchiveHeight+130);
			end
		end
	end


	getglobal("SearchArchiveBox"):setCurOffsetY(0);

	-- statisticsGameEventNew(41110, "more", AccountManager:getUin(), target_uin)

	-- local playerInfo =  t_exhibition.getPlayerInfo();
	if CanFollowPlayer(target_uin) then 
		getglobal("SearchArchiveBoxRoleInfoFocus"):Enable();
		getglobal("SearchArchiveBoxRoleInfoFocusIcon"):SetTexUV("icon_like_n.png");
	else
		getglobal("SearchArchiveBoxRoleInfoFocus"):Disable();
		getglobal("SearchArchiveBoxRoleInfoFocusIcon"):SetTexUV("icon_like_h.png");
	end

end

function WorksSelectAuthorTemplateWorkSpaceBtn_OnClick()
	local target_uin = this:GetClientUserData(0);
	if target_uin == nil or target_uin <=0 then
		ShowGameTips("未获取工作室id")
		return;
	end

	-- local workSpaceInfoByUins=GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch").model:GetWorkSpaceInfos()
	-- if workSpaceInfoByUins and workSpaceInfoByUins[target_uin] and workSpaceInfoByUins[target_uin].workSpaceId then
	-- 	GetInst("WorkSpaceInterface"):ShowWorkSpace(1,workSpaceInfoByUins[target_uin].workSpaceId)
	-- else
	-- 	ShowGameTips("未获取工作室id")
	-- end
end


function RespSearchMapsByUinInfo(ret)

	if ret[1].profile and ret[1].profile.RoleInfo then
		HeadCtrl:SetPlayerHeadByUin("SearchArchiveBoxRoleInfoHeadIcon",ret[1].uin,ret[1].profile.RoleInfo.head_id,nil,ret[1].profile.RoleInfo.HasAvatar);
		HeadFrameCtrl:SetPlayerheadFrameName("SearchArchiveBoxRoleInfoHeadIconBox",ret[1].profile.head_frame_id);
		getglobal("SearchArchiveBoxRoleInfoUin"):SetText(getShortUin(ret[1].uin));
		getglobal("SearchArchiveBoxRoleInfoName"):SetText(ReplaceFilterString(ret[1].profile.RoleInfo.NickName));
	end

end
function MiniWorksFrameSearch1SwitchBtn_OnClick()
	local typeName = getglobal("MiniWorksFrameSearch1SwitchBtnType");
	local switchBtn = getglobal("MiniWorksFrameSearch1Filter");
	local filter = getglobal("ArchiveFilterFrame");
	local default = getglobal("MiniWorksFrameSearch1InputEdit");
	if mapservice.searchType == 1 then
		mapservice.searchType = 2;
		UpdateMiniWorksFrameSearch1()
	elseif if_open_word_search() then
		mapservice.searchType = 1;
		UpdateMiniWorksFrameSearch1()
	end

	--埋点
	-- statisticsGameEventNew(41108, "change",AccountManager:getUin())
end

--[[刷新搜索类型显示]]
function UpdateMiniWorksFrameSearch1()
	local typeName = getglobal("MiniWorksFrameSearch1SwitchBtnType");
	local switchBtn = getglobal("MiniWorksFrameSearch1Filter");
	local filter = getglobal("ArchiveFilterFrame");
	local default = getglobal("MiniWorksFrameSearch1InputEdit");
	if mapservice.searchType == 1 then
		typeName:SetText(GetS(21818));
		switchBtn:Show();
		default:SetDefaultText(GetS(21820));
	elseif if_open_word_search() then
		typeName:SetText(GetS(21817));
		switchBtn:Hide();
		filter:Hide();
		default:SetDefaultText(GetS(21819));
	end
end


function SearchArchiveBoxRoleInfoBack_OnClick( )

	local ret = mapservice.searchLastList
	if ret == nil then
		return;
	end 
	getglobal("SearchArchiveBoxRoleInfo"):Hide();
	local input = getglobal("MiniWorksFrameSearch1InputEdit"):GetText();
	for i=1,60 do

		local icon = getglobal("SearchAuthor"..i.."PicIcon")
		local workFram = getglobal("SearchAuthor"..i)
		local uinFram = getglobal("SearchArchive"..i)
		local name = getglobal("SearchAuthor"..i.."Name");
		local uin = getglobal("SearchAuthor"..i.."AuthorName")
		local btn = getglobal("SearchAuthor"..i.."FuncBtn")
		local funCount = getglobal("SearchAuthor"..i.."Down")
		local mapCount = getglobal("SearchAuthor"..i.."NowPlayer")



		uinFram:Hide();

		local num = #ret
		if i <= num then
			workFram:Show();

			-- local a,b = string.find(ret[i].profile.RoleInfo.NickName,input);
			-- if a and b then

			-- 	local beforeString = string.sub(ret[i].profile.RoleInfo.NickName,1,a-1) ;
			-- 	local endString = string.sub(ret[i].profile.RoleInfo.NickName,b+1,-1);
			-- 	local subString = string.sub(ret[i].profile.RoleInfo.NickName,a,b) ;

			-- 	name:SetText(beforeString.."#cFF6D25"..subString.."#n"..endString)
			-- else
			-- 	name:SetText(ret[i].profile.RoleInfo.NickName)
			-- end
			if ret[i].profile.RoleInfo and ret[i].profile.RoleInfo.NickName then
				local text = JoinHighlightString(ret[i].profile.RoleInfo.NickName,input);
				name:SetText(ReplaceFilterString(text));
				HeadCtrl:SetPlayerHeadByUin("SearchArchiveBoxRoleInfoHeadIcon",ret[1].uin,ret[1].profile.RoleInfo.head_id,nil,ret[1].profile.RoleInfo.HasAvatar);
			end


			uin:SetText("("..getShortUin(ret[i].uin)..")")
			btn:SetClientUserData(0,ret[i].uin);
			funCount:SetText(ret[i].profile.fun_count)
			mapCount:SetText(ret[i].profile.map_count)

			
			-- local file = HeadFrameCtrl:getTexPath(ret[i].profile.RoleInfo.head_id);
			
		else
			workFram:Hide();
		end

		
		-- owids[i] =(ret.data.msg[i].id)
	end

end



function MiniWorksFrameSearch1DelBtn_OnClick( )
	-- body
	for i=1,60 do
		getglobal("SearchAuthor"..i):Hide();
		getglobal("SearchArchive"..i):Hide();
		getglobal("SearchArchiveBoxRoleInfo"):Hide();
	end
	for i=1,10 do
		getglobal("SearchHotWord"..i):Hide();
		getglobal("SearchRecord"..i):Hide();
	end

	getglobal("SearchArchiveBoxNull"):Hide();
	getglobal("SearchArchiveBoxNullTitle"):Hide();

	getglobal("MiniWorksFrameSearch1InputEdit"):SetText("");
	getglobal("SearchArchiveBoxHistoryRecord"):Show();
	-- getglobal("SearchArchiveBoxHotRecommend"):Show();
	getglobal("SearchArchiveBoxDelBtn"):Show();
	getglobal("SearchArchiveBoxLine"):Show();
	-- getglobal("SearchArchiveBoxLine1"):Show();

	updateWorkSearchRecordView();
	-- updateWorkSearchHotView();

	if not if_open_word_search() then
		mapservice.searchType = 1;
		MiniWorksFrameSearch1SwitchBtn_OnClick();
	end

end

function clearAllWorkSearchUI( )
	for i=1,10 do
		getglobal("SearchHotWord"..i):Hide();
		getglobal("SearchRecord"..i):Hide();
	end
	for i=1, Search_Archive_Max/2 do
		for j=1, 2 do
			local archive = getglobal("SearchArchive"..((i-1)*2+j));
			if j == 1 then
				archive:SetPoint("topright", "SearchArchiveBoxPlane", "top", -3, (i-1)*SingleArchiveHeight);
			else
				archive:SetPoint("topleft", "SearchArchiveBoxPlane", "top", 3, (i-1)*SingleArchiveHeight);
			end
		end
	end
	getglobal("SearchArchiveBoxHotRecommend"):Hide();
	getglobal("SearchArchiveBoxHistoryRecord"):Hide();
	getglobal("SearchArchiveBoxDelBtn"):Hide();
	getglobal("SearchArchiveBoxLine"):Hide();
	getglobal("SearchArchiveBoxLine1"):Hide();
	getglobal("SearchArchiveBoxNull"):Hide();
	getglobal("SearchArchiveBoxNullTitle"):Hide();
end


function updateWorkSearchHotView()

	local url = mapservice.getserver().."/miniw/map/?act=search_by_key&type=hot_words";
	url = UrlAddAuth(url);
	Log("Work Search Player "..url);
	ns_http.func.rpc(url, RespSearchMapsByHot, nil, nil, true);	
end

function RespSearchMapsByHot( ret )
	-- body
	if ret and ret.ret == 0 and ret.data.msg and next(ret.data.msg) then
		local text ={}
		for i=1,#ret.data.msg do
			table.insert(text,ret.data.msg[i]);
		end

		--计算搜索记录列表的高度
		local num = #mapservice.searchRecordMap
		local recordHight = 2;
		local recordSum = 0;
		if num <= 0 then
			recordHight =0;
			getglobal("SearchArchiveBoxHistoryRecord"):Hide();
			getglobal("SearchArchiveBoxLine"):Hide();
			getglobal("SearchArchiveBoxDelBtn"):Hide();
		else
			for i=1,num do
				local recordBtn = getglobal("SearchRecord"..i);
				local width = recordBtn:GetWidth();
				recordSum = recordSum+width;

				if recordSum > 950 then
					recordSum = width;	
					-- recordBtn:SetPoint("topleft","SearchArchiveBox","topleft",32,heigh*65);
					recordHight = recordHight+ 1;
				end
			end
			getglobal("SearchArchiveBoxHistoryRecord"):Show();
			getglobal("SearchArchiveBoxLine"):Show();
			getglobal("SearchArchiveBoxDelBtn"):Show();

		end


		getglobal("SearchArchiveBoxHotRecommend"):SetPoint("topleft","SearchArchiveBox","topleft",19,recordHight*60+21)
		

		local sum = 0;
		local heigh  = recordHight+1;
		for i=1,#text do
			local hotBtn = getglobal("SearchHotWord"..i);
			local name = getglobal("SearchHotWord"..i.."Name");
			name:SetText(text[i]);
			local len = getStringCharCount(name:GetText());
			hotBtn:SetSize(len*22+20,50);
			name:SetSize(len*25,25)
			
			local width = hotBtn:GetWidth();
			sum = sum + width;
			if i == 1 then
				hotBtn:SetPoint("topleft","SearchArchiveBox","topleft",32,heigh*65)
				heigh = heigh+ 1;
			elseif i > 1 then
				hotBtn:SetPoint("left","SearchHotWord"..(i-1),"right",10,0);
			end

			if sum > 950 then
				sum = width;	
				hotBtn:SetPoint("topleft","SearchArchiveBox","topleft",32,heigh*65);
				heigh = heigh+ 1;
			end
			hotBtn:Show();
		end
	else
		for i=1,10 do
			getglobal("SearchHotWord"..i):Hide();	
		end
		getglobal("SearchArchiveBoxHotRecommend"):Hide();
		getglobal("SearchArchiveBoxLine1"):Hide();
	end
end



function updateWorkSearchRecordView()

	local num = #mapservice.searchRecordMap
	if num == 0 then
		getglobal("SearchArchiveBoxDelBtn"):Hide();
		return;
	else
		getglobal("SearchArchiveBoxDelBtn"):Show();
	end

	local sum1 = 0;
	local heigh1 = 1;
	for i=1,num do
		local recordBtn = getglobal("SearchRecord"..i);
		local recordName = getglobal("SearchRecord"..i.."Name");
		recordName:SetText(mapservice.searchRecordMap[i][1]);

		local len = getStringCharCount(recordName:GetText());
		recordBtn:SetSize(len*22+20,50);
		recordName:SetSize(len*25,25)

		local width = recordBtn:GetWidth();
		sum1 = sum1 + width;

		if i == 1 then
			recordBtn:SetPoint("topleft","SearchArchiveBox","topleft",32,heigh1*65)
			heigh1 = heigh1+ 1;
		elseif i > 1 then
			recordBtn:SetPoint("left","SearchRecord"..(i-1),"right",10,0);
		end

		if sum1 > 950 then
			sum1 = width;	
			recordBtn:SetPoint("topleft","SearchArchiveBox","topleft",32,heigh1*65);
			heigh1 = heigh1+ 1;
		end

		recordBtn:Show();

	end
end






--热词搜索
function WorkSelectHotWordTemplate_OnClick( )
	local id = this:GetClientID();
	-- if getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):HotWord_OnClick(id)
	-- 	return;
	-- end
	local input = getglobal("SearchHotWord"..id.."Name"):GetText();
	local url = mapservice.getserver().."/miniw/map/?act=search_by_key&type=map&key="..input;
	url = UrlAddAuth(url);
	Log("Work Search Map "..url);
	ns_http.func.rpc(url, RespSearchMapsByMap, nil, nil, true);
	getglobal("MiniWorksFrameSearch1InputEdit"):SetText(getglobal(this:GetName().."Name"):GetText());
	clearAllWorkSearchUI();

	mapservice.searchType =2;
	-- MiniWorksFrameSearch1SwitchBtn_OnClick();


end

--历史记录搜索
function WorkSelectTemplate_OnClick(  )
	local id = this:GetClientID();
	-- if getglobal("MiniWorksFrameSearch"):IsShown() then
	-- 	GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):WorkSelect_OnClick(id)
	-- 	return;
	-- end
	-- updateWorkSearchRecordView()
	local name = getglobal("MiniWorksFrameSearch1SwitchBtnType");
	if mapservice.searchRecordMap[id][1] and mapservice.searchRecordMap[id][3] == 1 then
		if mapservice.searchRecordMap[id][2] ==1 then
			mapservice.searchType = 1;
			getglobal("MiniWorksFrameSearch1Filter"):Show();
			name:SetText(GetS(21818));
		elseif mapservice.searchRecordMap[id][2] ==2 then
			mapservice.searchType = 2;
			getglobal("MiniWorksFrameSearch1Filter"):Hide();
			name:SetText(GetS(21817));
		end
		ReqSearchMapsByType(mapservice.searchRecordMap[id][1],true);

		-- statisticsGameEventNew(41112, "onClick")
	end
	getglobal("MiniWorksFrameSearch1InputEdit"):SetText(getglobal(this:GetName().."Name"):GetText());
	clearAllWorkSearchUI();
end

--删除历史搜索记录
function SearchArchiveBoxDelBtn_OnClick()


	MessageBox(5, GetS(21822) , function(btn)
			if btn == 'left' then
				mapservice.searchRecordMap = {};
				MiniWorksFrameSearch1DelBtn_OnClick();
				-- statisticsGameEventNew(41108, "delete",AccountManager:getUin())
			end
		end);

end


--关注
function SearchArchiveBoxRoleInfoAttention_OnClick()
	if t_exhibition:CheckOtherProfileBlackStat() then 
		ShowGameTips(string.format(GetS(10593), GetS(4738)));
		return;
	end
	local uin = tonumber(getglobal("SearchArchiveBoxRoleInfoUin"):GetText())  
	ReqFollowPlayer(uin, true);
	t_exhibition.self_data_dirty = true;

	if CanFollowPlayer(uin) then 
		getglobal("SearchArchiveBoxRoleInfoFocus"):Disable();
		getglobal("SearchArchiveBoxRoleInfoFocusIcon"):SetTexUV("icon_like_h.png");

	else
		getglobal("SearchArchiveBoxRoleInfoFocus"):Enable();
		getglobal("SearchArchiveBoxRoleInfoFocusIcon"):SetTexUV("icon_like_n.png");
	end

	-- statisticsGameEventNew(41110, "follow", AccountManager:getUin(), uin);

	-- local playerInfo =  t_exhibition.getPlayerInfo();
	-- if playerInfo then 
	-- 	-- playerInfo.attention_count = playerInfo.attention_count +1;
	-- 	-- getglobal("PlayerExhibitionCenterFocusNumFont"):SetText(playerInfo.attention_count);
	-- 	getglobal("SearchArchiveBoxRoleInfoFocus"):Disable();
	-- 	getglobal("SearchArchiveBoxRoleInfoFocusIcon"):SetTexUV("icon_like_h");
	-- 	statisticsGameEvent(711, "%%lls", "PlayerCenterAddAttention")
	-- end
end


--头像跳转个人中心
function SearchAuthorPic_OnClick()
	-- FriendEntryBasicInfoTemplateHead_OnClick();
	local target_uin = this:GetClientUserData(0);
	if not target_uin then
		return;
	end
	SearchPlayerByUin(target_uin);
	-- statisticsGameEventNew(41110, "more", AccountManager:getUin(), target_uin)
	-- GetInst("UIManager"):GetCtrl("MiniWorksFrameSearch"):StandReportAuthorContentClick(target_uin, false)		
end


function getStringCharCount(str)
    local lenInByte = #str
    local charCount = 0
    local i = 1
    while (i <= lenInByte) 
    do
        local curByte = string.byte(str, i)
        local byteCount = 1;
        if curByte > 0 and curByte <= 127 then
            byteCount = 2                                               --1字节字符
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2                                               --双字节字符
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3                                               --汉字
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4                                               --4字节字符
        end
         
        local char = string.sub(str, i, i + byteCount - 1)
        i = i + byteCount                                               -- 重置下一字节的索引
        charCount = charCount + 1                                       -- 字符的个数（长度）
    end
    return charCount
 end

 -- 新增一键清空存档功能
function MiniWorksFrameCollectClearAllCollectionBtn_OnClick()
	local callback = function(flag, data)
		if flag == "left" then--确认
			ReqClearAllCollectMaps()
		end 
	end
	titles = "确认要清空您收藏的全部地图么？"
	MessageBox(5, titles, callback, nil)
end

function reSetExposureParam(planeH, planeOffset, boxH, offset)
	m_ExposureParam:Init()
	m_ExposureParam:SetParam(planeH, planeOffset, boxH, offset)
end

function standReportWorksComp()
	local tb = {
		MINI_WORKSHOP_TOP_1 = {
				"-",
				"Close",
				"Help",
		},
		MINI_WORKSHOP_CONTAINER_1 = {
				"-",
				"HomeContent",
				"MapContent",
				"MaterialContent",
				"SpecialContent",
				"CollectionContent",
				"SearchContent",
		},
		MINI_WORKSHOP_BANNER_1 = {
				"-",
				"LeftPage",
				"RightPage",
		}
	}
	for key, val in pairs(tb) do
		for _, comp in ipairs(val) do
			standReportEvent("3",key,comp,"view")
		end
	end
end

function MiniWorksCommendDetailListScroll(arg1,arg2,arg3,arg4)
	Log("MainArchiveBox_Scroll:");
	local planeH = arg3;
	local planeOffset = arg2;
	local boxH = arg1;
	local offset = 0 - arg4;	--当前偏移, 总偏移=planeH - planeOffset + offset;

	m_ExposureParam:Init();
	m_ExposureParam:SetParam(planeH, planeOffset, boxH, offset);
end

function GetCurLabel()
	return CurLabel
end

function GetCurTopicObj()
	return CurTopicObj
end

function NewMiniWorkMainLoadErrorFrame_OnClick()
	getglobal("NewMiniWorkMainLoadErrorFrame"):Hide();
	ShowMiniWorksMain(true);
end

function MiniWorksSwitchAccountHandel()
	local mCtrl = GetInst("MiniUIManager"):GetCtrl("NewMiniWorksMain")
	if mCtrl then 
		mCtrl.isClose = true
	end
	
	GetInst("MiniUIManager"):CloseUI("NewMiniWorksMainAutoGen");
	GetInst("MiniUIManager"):CloseUI("WorksManageAutoGen")
end

-----------------------local变量的set，get接口-------------------------------------------

function GetMiniWorks_CurrentSwitchBtn()
	return MiniWorks_CurrentSwitchBtn	
end

function SetMiniWorks_CurrentSwitchBtn(value)
	MiniWorks_CurrentSwitchBtn = value
end

function SetCurLabel( value )
	CurLabel = value
end

function SetCurTopicObj(value)
	CurTopicObj = value 
end

-------------------------------------------
-- 开始创造按钮事件
function StartCreatingBtn_OnClick() 
	getOfficialRankTemplateList();
	
	-- 开始创作按钮 click
	standReportEvent("3", "MINI_WORKSHOP_CONTAINER_1", "CreateButton", "click")
end

function WorksManageBtn_OnClick() 
	if GetInst("MiniUIManager"):IsShown("WorksManageAutoGen") then
		return 
	end
	
	local normal 	= getglobal("MiniWorksFrameLabel"..CurLabel.."Normal")
	local checked 	= getglobal("MiniWorksFrameLabel"..CurLabel.."Checked")
	local name 	= getglobal("MiniWorksFrameLabel"..CurLabel.."Name")
	
	if normal then 
		normal:Show()
		checked:Hide()
		name:SetTextColor(158, 225, 231)
	end 
	
	CurLabel = -1
	
	ShowCurWorksFrame(true, true)
	
	-- 作品管理按钮 click
	standReportEvent("3", "MINI_WORKSHOP_CONTAINER_1", "MycontentContent", "click")
end

-- 显示作品管理页
function ShowWorksManage(bShow)
	if bShow then
		getglobal("MiniWorksFrameWorksManageBtnNormal"):Hide()
		getglobal("MiniWorksFrameWorksManageBtnChecked"):Show()
		
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common_comp", "miniui/miniworld/common", "miniui/miniworld/CreationCenter"})
		GetInst("MiniUIManager"):OpenUI("WorksManage", "miniui/miniworld/CreationCenter", "WorksManageAutoGen")
	else
		GetInst("MiniUIManager"):HideUI("WorksManageAutoGen")
		
		getglobal("MiniWorksFrameWorksManageBtnNormal"):Show()
		getglobal("MiniWorksFrameWorksManageBtnChecked"):Hide()
	end
end 