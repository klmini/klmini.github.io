
-------个人中心-----(utf-8)----------
-- 半废弃状态，建议用PlayerExhibitionCenter.lua里的代码
ns_playercenter = {
	func = {};
	head_max = 32;          --一个栏目下最大头像数字
	head_select = {};
	net_ok  = false;        --是否成功访问网络


	server_ret_pool  = {};      --用户资料池  [uin1]=ret1 [uin2]=ret2
	server_ret = {};

	self_data_dirty = false;   --自己的资料是否已经被修改

	uin      = 0;   --发起请求的UIN
	op_uin   = 0;   --目标uin


	--------------------------
	NickName = "";
	SkinId   = 0;
	Model    = 2;

	friend_count    = 0;
	attention_count = 0;
	posting_num     = 0;

	head_frame_read_cache = 0;   --是否已经读取过cache
	head_frame_id         = 1;   --玩家现在使用的头像框id
	head_frame_id_select  = 1;   --玩家准备修改的值
	head_frames           = {};  --玩家已经解锁的头像
	head_frames_temp      = {};  --玩家已经解锁的头像(30天 N天)


	gender          = 0;         --玩家性别  0=保密  1=男  2=女
	gender_select   = 0;         --玩家准备修改的值

	headIndexFile   = "";        --玩家头像文件
	head_url        = "";        --玩家当前头像url
	head_checked    = 0;         --玩家头像是否已经审核

	photoFileList   = {};        --相册文件列表

	----------------------------------
	head_select_type    = 1;     --玩家现在所在的头像分类
	upload_photo_index  = 0;     --玩家现在所上传的文件index
	add_photo_index     = 0;     --add按钮所在的位置


	------------------------------------------------------
	head_unlock     = 0;         --玩家是否已经解锁头像 0=未解锁 1=解锁
	photo_unlock    = 3;         --玩家已经解锁的图片栏个数

	expert = {};				 --玩家的鉴赏家信息

};


-- [20201] = {
	-- FrameID = 20201,
	-- MiniBean = 10,
	-- ItemID = 20201,
	-- StringID = 5301,
	-- Group = 2
-- },


--LLTODO:从地图详情页, 进入个人中心, 滑动框会重叠, 需要屏蔽详情页
local PlayerCenter_MNGFFrameState = false;
local PlayerCentr_Maps_MaxNum = 60;				--存档地图最大数量
local CollectMaps_Max = 120;					--收藏地图显示的最大数量
local ConnoisseurMaps_Max = 100;					--测评地图显示的最大数量

local Connoisseur_CurLabel = 1;  --默认标签：综合
local Connoisseur_CurOrder = 1;  --默认排序：默认

local PalyerCenter_ArchiveType = 1;		--1:作品 2:收藏

function PlayerCenterFrame_SetFilter(label, order)
	if Connoisseur_CurLabel ~= label or Connoisseur_CurOrder ~= order then
		Connoisseur_CurLabel = label;
		Connoisseur_CurOrder = order;
		UpdateCenterFilterUI();

		CenterConnoisseurArchiveLayout(false);
		getglobal("CenterConnoisseurArchiveBox"):resetOffsetPos();

		mapservice.searchExpertMapPullingIndex = 1;
		mapservice.searchExpertMaps = {};

		SetCurExpertLabelOwids(label);
		ReqSearchExpertMapDetail(ns_playercenter.op_uin);
	end
end

function UpdateCenterFilterUI()
	--已废弃
	-- local t_LabelId = { 427, 418, 419, 420, 421, 422, 423, 3027, 7570};
	local t_OrdelId ={3852};
	getglobal("PlayerCenterFrameSubPage4FilterType"):SetText(GetS(t_LabelId[Connoisseur_CurLabel]));
	getglobal("PlayerCenterFrameSubPage4FilterRank"):SetText(GetS(t_OrdelId[Connoisseur_CurOrder]));
end

--是否查看自己
function IsLookSelf()
	return ns_playercenter.uin == ns_playercenter.op_uin;
end


function ns_playercenter:CheckProfileBlackStat(uin)
	uin = uin or self.uin;
	if not uin then return true end
	local profile = self.server_ret_pool and self.server_ret_pool[uin] and self.server_ret_pool[uin].profile;
	print("CheckProfileBlackStat(): profile = ", profile);
	profile = profile or (self.func.WWW_get_player_profile and self.func.WWW_get_player_profile(uin));
	local black_stat = profile and profile.black_stat;
	return black_stat and (black_stat == 1 or black_stat == 2);
end

--设置是查看自己还是查看别人
function PlayerCenterFrame_setTarget( op_uin_ )
	if  op_uin_ and op_uin_ < 1000 then
		Log( "op_uin_ error." );
		return;
	end

	ns_playercenter.uin      = AccountManager:getUin();
	if  ns_playercenter.uin >= 1000 then
		ns_playercenter.op_uin = op_uin_ or ns_playercenter.uin;
		if  IsLookSelf() then
			--ns_playercenter.NickName = AccountManager:getNickName();
			resetAllHead();
			if #ns_playercenter.headIndexFile <= 0 then
				ns_playercenter.headIndexFile = GetHeadIconPath();  	--头像文件
			end
		else
			--后面获取昵称
			if ns_playercenter.black_stat == 1 or ns_playercenter.black_stat == 2 then 
				ns_playercenter.headIndexFile = "ui/snap_jubao.png";
			end
		end

	else
		Log( "call PlayerCenterFrame_setTarget, op_uin error." );
	end

end


function getShowModel()
	if  IsLookSelf() then
		return GetPlayer2Model()
	else
		local  mode_ = ns_playercenter.Model;
		local  skin_ = ns_playercenter.SkinID;
		if  mode_ and skin_ then
			Log( "mode=" .. mode_ .. ", skin=" .. skin_ );
			return GetPlayer2ModelByNum(mode_, skin_)
		else
			return GetPlayer2Model()
		end
	end
end


function PlayerCenterFrame_OnHide()
	--[[
	local player = getShowModel();
	player:detachUIModelView(getglobal("PlayerCenterFrameModelView"));

	--getglobal("MiniLobbyFrame"):Show();
	]]
	if IsMapDetailInfoShown() then
		HideMapDetailInfo();
	end
	DetachPlayerCenterUIModel()

	--LLTODO:还原迷你工坊窗口显示状态
	local MNGFFrame = getglobal("ArchiveInfoFrameEx");
	local FriendFrame = getglobal("FriendFrame");

	if MNGFFrame:IsShown() and PlayerCenter_MNGFFrameState then
		PlayerCenter_MNGFFrameState = false;
		--恢复滑动框
		Log("(LLTODO:)Sliding Frame DisEnable: ArchiveInfoFrameEx");
		getglobal("MiniWorksMapCommentBox"):setDealMsg(true);
		SetMiniWorksBoxsDealMsg(true);

		--重新加载地图详情页
		ReLoadMiniWorksMapDetail();
	elseif FriendFrame:IsShown() and PlayerCenter_MNGFFrameState then
		PlayerCenter_MNGFFrameState = false;
		Log("(LLTODO:)Sliding Frame DisEnable: FriendFrame");
		getglobal(FriendMgr:GetListViewName(FriendMgr.DlgType_MyFriends)):setDealMsg(true)  --好友列表
		getglobal(FriendMgr:GetListViewName(FriendMgr.DlgType_NearbyFriends)):setDealMsg(true);		--附近的人
		getglobal(FriendMgr:GetListViewName(FriendMgr.DlgType_FollowingPlayers)):setDealMsg(true)
		getglobal("ChatMessages"):setDealMsg(true);
	else

	end
	--把RoomFrame的层级设置回来
	-- SetRoomFrameLevel(1500)
end

function DetachPlayerCenterUIModel()
	local player = getglobal("PlayerCenterFrameModelView"):getActorbody();
	if player then
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			getglobal("PlayerCenterFrameModelView"):detachActorBody(player)
		else
			player:detachUIModelView(getglobal("PlayerCenterFrameModelView"));
		end

		local seatID = AccountManager:avatar_seat_current();
		if seatID and seatID > 0 and seatID <= 20 then
			--UIActorBodyManager:releaseAvatarBody(seatID);
		end
	end
end


--显示个人中心
function PlayerCenterFrame_OnShow()
	-- 首先调用   PlayerCenterFrame_setTarget()
	--ArchiveInfoFrameEx层级设置
	if IsMapDetailInfoShown() then
		HideMapDetailInfo();
	end

	if getglobal("ArchiveInfoFrameEx"):IsShown() then
		GetInst("CommentSystemInterface"):SetArchiveInfoFrameLevel(3000);
		MiniWorksTopicDetailSetLevel()
	end

	getglobal("PlayerCenterFrameRightBtn4"):Hide();
	getglobal("PlayerCenterFrameSubPage1ConnoisseurBtn"):Hide();
	getglobal("PlayerCenterFrameSubPage1ConnoisseurBtnEffect"):Hide();

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


	--查看自己的个人中心
	getglobal("PlayerCenterFrameSubPage1AddQQFriendBtn"):Hide();
	if  IsLookSelf() then
		getglobal("PlayerCenterFrameSubPage1EditBtn"):Show();
		getglobal("PlayerCenterFrameSubPage1AddFriendBtn"):Hide();
		getglobal("PlayerCenterFrameSubPage1FollowBtn"):Hide();
		getglobal("PlayerCenterFrameSubPage1ReportBtn"):Hide();
	else  --查看其它玩家的资料
		getglobal("PlayerCenterFrameSubPage1EditBtn"):Hide();

		if  CanAddUinAsFriend(ns_playercenter.op_uin) then
			getglobal("PlayerCenterFrameSubPage1AddFriendBtn"):Show();
		else
			getglobal("PlayerCenterFrameSubPage1AddFriendBtn"):Hide();
		end

		if  CanFollowPlayer(ns_playercenter.op_uin) then
			getglobal("PlayerCenterFrameSubPage1FollowBtn"):Show();
		else
			getglobal("PlayerCenterFrameSubPage1FollowBtn"):Hide();
		end

		getglobal("PlayerCenterFrameSubPage1ReportBtn"):Show();

		getglobal("PlayerCenterFrameSubPage1AddQQFriendBtn"):SetClientString("");
		threadpool:work(function ()
			if CanShowAddQQFriendBtn() then
				getglobal("PlayerCenterFrameSubPage1AddQQFriendBtn"):Show();
			end
		end)
	end


	--没有网络，取不到uin
	if  ns_playercenter.uin < 1000 then
		getglobal( "PlayerCenterFrameSubPage0" ):Show();
		getglobal( "PlayerCenterFrameRightBtn1" ):Disable();
		getglobal( "PlayerCenterFrameRightBtn2" ):Disable();
		return;
	end


	-- 默认网络不好
	if  ns_playercenter.net_ok then
		--是否有图片
		Log("net_ok=true");
		checkPage1_3Photo();
	else
		Log("net_ok=false");
		getglobal( "PlayerCenterFrameSubPage0" ):Show();
		getglobal( "PlayerCenterFrameRightBtn1" ):Disable();
		getglobal( "PlayerCenterFrameRightBtn2" ):Disable();
	end


	--进行网络数据拉取
	if  IsLookSelf() then
		ns_playercenter.func.WWW_get_player_profile(ns_playercenter.op_uin);
	end

	--清除上一个人的存档信息
	mapservice.searchedMaps = {};

	--清除上一个人的收藏存档的信息
	mapservice.searchCollectMaps = {};
	mapservice.searchCollectMapAllOwids = {};	
	getglobal("CenterCollectArchiveBox"):resetOffsetPos();

	--清除上一个人的评测存档的信息
	Connoisseur_CurLabel = 1;
	Connoisseur_CurOrder = 1;

	mapservice.searchExpertMaps = {};
	mapservice.searchExpertAllMaps = {};
	mapservice.searchExpertAllOwInfo = {};
	mapservice.curExpertLabelOwids = {};
	getglobal("CenterConnoisseurArchiveBox"):resetOffsetPos();

	--LLDO:13岁保护模式特殊处理: 不让点击, 点击飘字
	if IsProtectMode() then
		getglobal("PlayerCenterFrameRightBtn2Normal"):SetGray(true);
		getglobal("PlayerCenterFrameRightBtn2Checked"):SetGray(true);
	else
		getglobal("PlayerCenterFrameRightBtn2Normal"):SetGray(false);
		getglobal("PlayerCenterFrameRightBtn2Checked"):SetGray(false);
	end	
end

function CanShowAddQQFriendBtn()
	local apiId = ClientMgr:getApiId();
	if not IsShouQChannel(apiId) then 	--自己不是官网
		return false;
	end

	if AccountManager.other_baseinfo == nil then return false; end
		
	local ret, mlookBaseInfo = AccountManager:other_baseinfo(ns_playercenter.op_uin);
	if ret ~= ErrorCode.OK or not IsShouQChannel(apiId) then	--查看的uin 不是官网
		return false;
	end

	local openId = "";
	if mlookBaseInfo.extra.openid then 
		openId = mlookBaseInfo.extra.openid;
	end
	getglobal("PlayerCenterFrameSubPage1AddQQFriendBtn"):SetClientString(openId);
	return true;
end

--LLTODO:
local SelfInfoUpdateBtnTime = 10;	--下载的时候刷新按钮进度用
function PlayerCenterFrame_OnLoad()
	SelfInfoUpdateBtnTime = 10;
end

--LLTODO:更新
function PlayerCenterFrame_OnUpdate()
	if SelfInfoUpdateBtnTime < 10 then
		SelfInfoUpdateBtnTime = SelfInfoUpdateBtnTime + arg1;

		local changes = {};
		if getglobal("SelfInfoArchiveBox"):IsShown() then
			for i = 1, #(mapservice.searchedMaps) do
				local m = mapservice.searchedMaps[i];
				table.insert(changes, {"SelfInfoArchive"..i, m});
			end
		end
		for i = 1, #changes do
			local archui = getglobal(changes[i][1]);
			local map = changes[i][2];
			UpdateSingleArchiveDownloadState(archui, map);
		end
	end
end

--LLTODO:请求存档信息
function PlayerCenterReqSelfInfo()
	--ReqSearchMapsByUin(GetMyUin());
	ReqSearchMapsByUin( ns_playercenter.op_uin )
end

--LLTODO:加载存挡, 结果处理
local SelfInfoArchiveBtnWidth = 121;	--存档条高度(164)
local SelfInfoArchiveBtnOffset = 15;	--存档垂直偏移(10)
function PlayerCenterReqSelfInfo_OnResults()
	if getglobal("PlayerCenterFrame"):IsShown() then
		if #(mapservice.searchedMaps) == 0 then
			--没有存挡
			--ShowGameTips(GetS(3831), 3);
			getglobal( "PlayerCenterFrameSubPage0Txt" ):SetText(GetS(6026));
			getglobal( "PlayerCenterFrameSubPage0" ):Show();
			SelfInfoArchiveLayout(false);
			--getglobal( "PlayerCenterFrameSubPage3" ):Show();
		else
			getglobal( "PlayerCenterFrameSubPage0" ):Hide();
			SelfInfoArchiveLayout(true);
			UpdateSelfInfoArchive();
		end
	end
end

--LLTODO:更新地图条目
function UpdateSelfInfoArchive()
	for i = 1, PlayerCentr_Maps_MaxNum do
		local archui = getglobal("SelfInfoArchive"..i);
		local archuiName = archui:GetName();

		if i <= #(mapservice.searchedMaps) then
			local map = mapservice.searchedMaps[i];
			archui:Show();
			--UpdateSingleArchive(archui, map);

			--人气/精选等脚标
			--getglobal(archuiName.."TagBkg"):SetTexUV("grzx_jiaobiao");
			UpdateSelfInfoArchiveUI(archui, map);
		else
			archui:Hide();
			UpdateSingleArchive(archui, nil);
		end
	end

	local plane = getglobal("SelfInfoArchiveBoxPlane");
	local totalHeight = math.ceil(#(mapservice.searchedMaps)) * (SelfInfoArchiveBtnWidth + SelfInfoArchiveBtnOffset);
	if totalHeight < getglobal("SelfInfoArchiveBox"):GetRealHeight() then
		totalHeight = getglobal("SelfInfoArchiveBox"):GetRealHeight();
	end
	plane:SetSize(1248, totalHeight);
end


--数字按千来显示的语言
function  lang_show_as_K()
	local lang_ = get_game_lang()
	if  lang_ == 1 or 
		lang_ == 4 or
		lang_ == 5 or
		lang_ == 6 or
		lang_ == 9 or
		lang_ == 12 or
		lang_ == 13 or
		lang_ == 14 or
		lang_ == 15 then
		return true
	else
		return false
	end	
end


--LLTODO:刷新条目ui
function UpdateSelfInfoArchiveUI(archui, map)
	local options = {hideRankTag=false};
	local archname = archui:GetName();

	if map then
		local mapname = map.name or "";
		getglobal(archname.."Name"):SetText(mapname);

		GetMapThumbnail(map, archname.."Pic");

		--作者名字
		local author_name = map.author_name or "";
		--getglobal(archname.."AuthorName"):SetText(author_name);

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
			getglobal(archname.."TagBkg"):SetTexUV("mngfg_rqdb");
			getglobal(archname.."TagName"):Show();
			getglobal(archname.."TagName"):SetText(GetS(3842));  --待审
			getglobal(archname.."TagName"):SetTextColor(6, 121, 146);	 --设置颜色
		elseif display_rank == 2 then  --2=已精选
			getglobal(archname.."TagBkg"):Show();
			getglobal(archname.."TagBkg"):SetTexUV("grzx_jiaobiao");
			getglobal(archname.."TagName"):Show();
			getglobal(archname.."TagName"):SetText(GetS(3843));  --精选
			getglobal(archname.."TagName"):SetTextColor(123, 82, 3);	 --设置颜色
		elseif display_rank == 3 then  --3=已推荐
			getglobal(archname.."TagBkg"):Hide();
			getglobal(archname.."TagName"):Hide();
		end

		--分数
		SetArchiveGradeUI(getglobal(archname.."Grade"), map.star or 3);
		UpdateSingleArchiveDownloadState(archui, map);
	else
		getglobal(archname.."Pic"):SetTexture("");
	end
end


--LLTODO:单击存档条,显示地图详细信息
function SelfInfoArchive_OnClick()
	local archindex = this:GetClientID();
	Log("SelfInfoArchive_OnClick");

	if string.find(this:GetName(), "CenterCollectArchive") then
		map = mapservice.searchCollectMaps[archindex];
	else
		map = mapservice.searchedMaps[archindex];
	end

	if map then
		ShowMapDetail(map, {fromUiLabel=CurLabel, fromUiPart=nil});
	end
end

--LLTODO:进入存挡地图
function SelfInfoArchiveTemplateFuncBtn_OnClick()
	local archui = this:GetParentFrame();
	if archui then
		local archindex = archui:GetClientID();
		local map = nil;
		if string.find(archui:GetName(), "SelfInfoArchive") then
			map = mapservice.searchedMaps[archindex];
		elseif string.find(archui:GetName(), "CenterCollectArchive") then
			map = mapservice.searchCollectMaps[archindex];
		end

		if map then
			if HandleGmMapCommands(map) then  --处理gm命令
				return;
			end

			local funcBtnUi = getglobal(archui:GetName().."FuncBtn");
			InfoMapFuncBtn_OnClick(funcBtnUi, map, {fromUiLabel=CurLabel, fromUiPart=nil});
		end
	end
end

--LLTODO:存档条功能按钮
function InfoMapFuncBtn_OnClick(funcBtnUi, map, options)
	Log("MapFuncBtn_OnClick btn="..funcBtnUi:GetName());

	options = options or {};

	if funcBtnUi and map then

		if getglobal(funcBtnUi:GetName().."Name1"):IsShown() then  --下载
			SelfInfoUpdateBtnTime = 0;	--LLTODO:开始刷新按钮
			if getglobal("MiniWorksFrame"):IsShown() then
				options.statisticsDownload = true;
				DownloadMap(map, options);
			else
				DownloadMap(map, options);
			end
		elseif getglobal(funcBtnUi:GetName().."Name2"):IsShown() then  --进入
			if EnterDownloadedMap(map) then
				UIFrameMgr:hideAllFrame();
				ShowLoadingFrame();
			end

		elseif getglobal(funcBtnUi:GetName().."Name3"):IsShown() then  --暂停
			StopDownloadMap(map);
		end
	end
end

--LLTODO:存档条布局
function SelfInfoArchiveLayout(bIsShow)
	for i=1, PlayerCentr_Maps_MaxNum do
		local archive = getglobal("SelfInfoArchive"..i);

		if bIsShow then
			archive:SetPoint("top", "SelfInfoArchiveBoxPlane", "top", 4, (i-1)*(SelfInfoArchiveBtnWidth+SelfInfoArchiveBtnOffset)) ;
		else
			archive:Hide();
		end
	end
end


--LLTODO:加载的存挡
function SelfInfoLoadArchive()
	PlayerCenterReqSelfInfo();
end

function SelfInfoArchiveBox_OnShow()
	if next(mapservice.searchedMaps) == nil then
		--首先隐藏掉默认的地图条目
		SelfInfoArchiveLayout(false);
		SelfInfoLoadArchive();
	end
end

-----------------------------CenterCollectArchive---------------------------------
function UpdateCenterCollectArchive()
	if next(mapservice.searchCollectMapAllOwids) == nil then
		getglobal( "PlayerCenterFrameSubPage0Txt" ):SetText(GetS(1264));
		getglobal( "PlayerCenterFrameSubPage0" ):Show();

		return;
	else
		getglobal( "PlayerCenterFrameSubPage0" ):Hide();		
	end

	for i = 1, CollectMaps_Max do
		local archui = getglobal("CenterCollectArchive"..i);
		local archuiName = archui:GetName();

		if i <= #(mapservice.searchCollectMaps) then
			local map = mapservice.searchCollectMaps[i];
			archui:Show();
			UpdateSelfInfoArchiveUI(archui, map);
		else
			archui:Hide();
		end
	end

	local plane = getglobal("CenterCollectArchiveBoxPlane");
	local totalHeight = math.ceil(#(mapservice.searchCollectMaps)) * (SelfInfoArchiveBtnWidth + SelfInfoArchiveBtnOffset);
	if mapservice.searchCollectMapPullingIndex > #(mapservice.searchCollectMapAllOwids) then
		getglobal("CenterCollectArchiveBoxMoreBtn"):Hide();
	else
		getglobal("CenterCollectArchiveBoxMoreBtn"):Show();
		totalHeight = totalHeight+40;
	end

	if totalHeight < getglobal("CenterCollectArchiveBox"):GetRealHeight() then
		totalHeight = getglobal("CenterCollectArchiveBox"):GetRealHeight();
	end
	plane:SetSize(1248, totalHeight);
end

--收藏存档条布局
function CenterCollectArchiveLayout(bIsShow)
	for i=1, CollectMaps_Max do
		local archive = getglobal("CenterCollectArchive"..i);

		if bIsShow then
			archive:SetPoint("top", "CenterCollectArchiveBoxPlane", "top", 4, (i-1)*(SelfInfoArchiveBtnWidth+SelfInfoArchiveBtnOffset));
		else
			archive:Hide();
		end
	end
end

--加载的收藏存挡
function CenterCollectLoadArchive()
	if next(mapservice.searchCollectMaps) == nil then
		ReqSearchCollectMaps(ns_playercenter.op_uin);
	else
		UpdateCenterCollectArchive();
	end
end

function CenterCollectArchiveBox_OnMoveFinished()
	if mapservice.searchCollectMapPullingIndex <= #(mapservice.searchCollectMapAllOwids) then
		ReqSearchCollectMapDetail();
	end
end

function CenterCollectArchiveBox_OnShow()
	if next(mapservice.searchCollectMaps) == nil then
		--首先隐藏掉默认的地图条目
		CenterCollectArchiveLayout(false);
		CenterCollectLoadArchive();
	end
end
---------------------------------PlayerCenterFrameSubPage3----------------------------------
function SubPage3SwitchBtn_OnClick(page)
	getglobal( "PlayerCenterFrameSubPage0" ):Hide();

	local t_page = {"SelfInfoArchiveBox", "CenterCollectArchiveBox"};

	for i=1, 2 do
		local switchBtnBkg = getglobal("PlayerCenterFrameSubPage3SwitchBtn"..i.."Bkg");
		if page == i then
			switchBtnBkg:SetTexUV("mngfg_btn02");
			getglobal(t_page[i]):Show();
			PalyerCenter_ArchiveType = page;
		else
			switchBtnBkg:SetTexUV("mngfg_btn03");
			getglobal(t_page[i]):Hide();
		end
	end
end

function PlayerCenterFrameSubPage3_OnLoad()
	--收藏存档条布局
	CenterCollectArchiveLayout(true);
end

--LLTODO:存挡页面
function PlayerCenterFrameSubPage3_OnShow()
	local MNGFFrame = getglobal("ArchiveInfoFrameEx");
	local FriendFrame = getglobal("FriendFrame");

	if MNGFFrame then
		--是否从工坊进入个人中心, 处理滑动框重叠的情况
		if MNGFFrame:IsShown() then
			PlayerCenter_MNGFFrameState = true;

			--防止滑动框的冲突
			Log("(LLTODO:)Sliding Frame DisEnable: ArchiveInfoFrameEx");
			getglobal("MiniWorksMapCommentBox"):setDealMsg(false);
			SetMiniWorksBoxsDealMsg(false);
		elseif FriendFrame:IsShown() then
		--是否从好友页面进入个人中心.
			PlayerCenter_MNGFFrameState = true;

			Log("(LLTODO:)Sliding Frame DisEnable: FriendFrame");
			getglobal(FriendMgr:GetListViewName(FriendMgr.DlgType_MyFriends)):setDealMsg(false)  --好友列表
			getglobal(FriendMgr:GetListViewName(FriendMgr.DlgType_NearbyFriends)):setDealMsg(false);		--附近的人
			getglobal(FriendMgr:GetListViewName(FriendMgr.DlgType_FollowingPlayers)):setDealMsg(false)
		else
			PlayerCenter_MNGFFrameState = false;
		end
	end

	--默认打开作品页面
	SubPage3SwitchBtn_OnClick(1);
end

function PlayerCenterFrameSubPage3_OnHide()

end

------------------------------------PlayerCenterFrameSubPage4----------------------------------------
--测评存档条布局
function CenterConnoisseurArchiveLayout(bIsShow)
	local row = math.ceil(ConnoisseurMaps_Max/3);
	for i=1, row do
		for j=1, 3 do
			local index = j+(i-1)*3;
			if HasUIFrame("CenterConnoisseurArchive"..index) then
				local archive = getglobal("CenterConnoisseurArchive"..index);
			
				if bIsShow then
					archive:SetPoint("topleft", "CenterConnoisseurArchiveBoxPlane", "topleft", 20+(j-1)*262, (i-1)*295);
					archive:SetHeight(280)
					getglobal(archive:GetName().."ConnoisseurInfo"):Hide();
				else
					archive:Hide();
				end
			end
		end
	end
end

function PlayerCenterFrameSubPage4Filter_OnClick()
	ShowArchiveFilterFrame(Connoisseur_CurLabel, Connoisseur_CurOrder, {GetS(3852)}, 0);
end

function PlayerCenterFrameSubPage4Refresh_OnClick()
	-- body
end

function PlayerCenterFrameSubPage4_OnLoad()
	CenterConnoisseurArchiveLayout(true);
end

function PlayerCenterFrameSubPage4_OnShow()
	local MNGFFrame = getglobal("ArchiveInfoFrameEx");
	local FriendFrame = getglobal("FriendFrame");

	if MNGFFrame then
		--是否从工坊进入个人中心, 处理滑动框重叠的情况
		if MNGFFrame:IsShown() then
			PlayerCenter_MNGFFrameState = true;

			--防止滑动框的冲突
			Log("(LLTODO:)Sliding Frame DisEnable: ArchiveInfoFrameEx");
			getglobal("MiniWorksMapCommentBox"):setDealMsg(false);
			SetMiniWorksBoxsDealMsg(false);
		elseif FriendFrame:IsShown() then
		--是否从好友页面进入个人中心.
			PlayerCenter_MNGFFrameState = true;

			Log("(LLTODO:)Sliding Frame DisEnable: FriendFrame");
			getglobal(FriendMgr:GetListViewName(FriendMgr.DlgType_MyFriends)):setDealMsg(false)  --好友列表
			getglobal("PhonePlayers"):setDealMsg(false);			--手机好友
			getglobal(FriendMgr:GetListViewName(FriendMgr.DlgType_NearbyFriends)):setDealMsg(false);		--附近的人
			getglobal(FriendMgr:GetListViewName(FriendMgr.DlgType_FollowingPlayers)):setDealMsg(false)
			getglobal("ChatMessages"):setDealMsg(false);
		else
			PlayerCenter_MNGFFrameState = false;
		end
	end

	UpdateCenterFilterUI();
	if next(mapservice.searchExpertAllOwInfo) == nil then
		--首先隐藏掉默认的地图条目
		CenterConnoisseurArchiveLayout(false);
		CenterConnoisseurLoadArchive();
	else

	end
end

function CenterConnoisseurLoadArchive()
	if next(mapservice.searchExpertAllOwInfo) == nil then
		ReqSearchExpertMaps(ns_playercenter.op_uin, Connoisseur_CurLabel);
	else
		UpdateCenterConnoisseurArchive();
	end
end

function CenterConnoisseurArchiveBoxMoreBtn_OnClick()
	ReqSearchExpertMapDetail(ns_playercenter.op_uin);
end

function UpdateCenterConnoisseurArchive()
	--[[
	if next(mapservice.searchCollectMapAllOwids) == nil then
		getglobal( "PlayerCenterFrameSubPage0Txt" ):SetText(GetS(1264));
		getglobal( "PlayerCenterFrameSubPage0" ):Show();

		return;
	else
		getglobal( "PlayerCenterFrameSubPage0" ):Hide();		
	end
	]]

	for i = 1, ConnoisseurMaps_Max do
		local archui = getglobal("CenterConnoisseurArchive"..i);
		local archuiName = archui:GetName();

		if i <= #(mapservice.searchExpertMaps) then
			local map = mapservice.searchExpertMaps[i];
			archui:Show();
			
			UpdateSingleConnoisseurArchive(archui, map, false);
		else
			archui:Hide();
			UpdateSingleConnoisseurArchive(archui, nil);
		end
	end

	local plane = getglobal("CenterConnoisseurArchiveBoxPlane");
	local totalHeight = math.ceil(#(mapservice.searchExpertMaps)/3) * 295;
	if mapservice.searchExpertMapPullingIndex > #(mapservice.curExpertLabelOwids) then
		getglobal("CenterConnoisseurArchiveBoxMoreBtn"):Hide();
	else
		getglobal("CenterConnoisseurArchiveBoxMoreBtn"):Show();
		totalHeight = totalHeight+40;
	end

	if totalHeight < getglobal("CenterConnoisseurArchiveBox"):GetRealHeight() then
		totalHeight = getglobal("CenterConnoisseurArchiveBox"):GetRealHeight();
	end
	plane:SetSize(1248, totalHeight);
end

-----------------------------------------------------------------------------------------------------------

--转动模型
function PlayerCenterRotateView_OnMouseDown()
	InitModelViewAngle =  getglobal("PlayerCenterFrameModelView"):getRotateAngle();
end


--转动模型
function PlayerCentertateView_OnMouseMove()
	local posX = getglobal("PlayerCenterFrameModelView"):getActorPosX();
	local posY = getglobal("PlayerCenterFrameModelView"):getActorPosY();

	if arg1 > posX-170 and arg1 < posX+170 and arg2 > posY-410 and arg2 < posY+30 then	--按下的位置是角色范围内
		local angle = (arg1 - arg3)*1;

		if angle > 360 then
			angle = angle - 360;
		end
		if angle < -360 then
			angle = angle + 360;
		end

		angle = angle + InitModelViewAngle;
		getglobal("PlayerCenterFrameModelView"):setRotateAngle(angle);
	end
end

--跳转
function PlayerCenterFrameViewJumpStore_OnClick()
	getglobal("PlayerCenterFrame"):Hide();
	ShopJumpTabView(2)
end

----xml functions-----------------------------------------------------------
function PlayCenterFrameBackBtn_OnClick()
	getglobal("PlayerCenterFrame"):Hide();
	if IsLobbyShown() then
		SetLobbyFrameModelView();
	end
end

function PlayerCenterFrameConnoisseurBtn_OnClick()
	if IsLookSelf() then
		getglobal("ConnoisseurInfoFrame"):Show();
		if not getkv("connoisseur_guide") then
			setkv("connoisseur_guide", true);
			getglobal("PlayerCenterFrameSubPage1ConnoisseurBtnEffect"):Hide();
		end
	else
		getglobal("ConnoisseurHelpFrame"):Show();
	end
end

function PlayerCenterFrameAuthIcon_OnClick()
	if AccountManager.idcard_info then
		local idCardInfo = AccountManager:idcard_info();
		local state = AccountManager:realname_state()
		if state ~= 1 then	--未认证
			local adsType = RealNameFunc and RealNameFunc.isShowIdentityNameAuth and RealNameFunc:isShowIdentityNameAuth(8)
			if adsType then
				ShowIdentityNameAuthFrame(nil,nil,nil,nil,nil,adsType,true)
			else
				ShowIdentityNameAuthFrame()
			end
		else
			if idCardInfo.age < 18 then		--未满18
				MessageBox(4, GetS(5995));
			else
				MessageBox(4, GetS(5994));
			end
		end
	end
end

--拷贝uin
function PlayerCenterFrameCopyUin_OnClick()
	local txt_ = "" .. getShortUin(ns_playercenter.op_uin);
	ClientMgr:clickCopy(txt_);
	ShowGameTipsWithoutFilter( txt_ .. " " .. GetS(739), 3);
	-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterCopyUinBtn");
end


--显示帮助
function PlayerCenterFrameHelpBtn_OnClick()
	getglobal("PlayerCenterFrameHelpFrame"):Show();
end

function PlayerCenterFrameHelpFrame_OnLoad()
	getglobal("PlayerCenterFrameHelpBoxContent"):SetText(GetS(3464), 140, 103, 84);
end

function PlayerCenterFrameHelpFrame_OnShow()
	local lines = getglobal("PlayerCenterFrameHelpBoxContent"):GetTextLines();
	if lines <= 14 then
		getglobal("PlayerCenterFrameHelpBoxPlane"):SetSize(890, 370);
		getglobal("PlayerCenterFrameHelpBoxContent"):SetSize(890, 370);
	else
		getglobal("PlayerCenterFrameHelpBoxPlane"):SetSize(890, 370+(lines-14)*30);
		getglobal("PlayerCenterFrameHelpBoxContent"):SetSize(890, 370+(lines-14)*30);
	end
end

function PlayerCenterFrameHelpClose_OnClick()
	getglobal("PlayerCenterFrameHelpFrame"):Hide();
end


--右侧分类按钮 资料=1 相册=2 存挡=3 评测=4
function PlayCenterFrameRightBtn_OnClick( num_ )
	Log("call PlayCenterFrameRightBtn_OnClick=" .. num_);

	if num_ == 1 then
		-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterDataBtn");
	elseif num_ == 2 then
		--LLDO:13岁保护模式特殊处理: 不让点击, 点击飘字
		if IsProtectMode() then
			ShowGameTips(GetS(20211), 3);
			getglobal( "PlayerCenterFrameRightBtn2"):SetChecked(true);
			return;
		end

		-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterAlbumBtn");
	elseif num_ == 3 then
		--LLTODO:加载存挡
		--SelfInfoLoadArchive();
	end

	if  not ns_playercenter.net_ok then
		ns_playercenter.func.net_not_ready();
		do return end
	end

	for i=1, 4 do
		if  num_ == i then
			--选中
			getglobal( "PlayerCenterFrameSubPage"  .. i ):Show();
			getglobal( "PlayerCenterFrameRightBtn" .. i ):Disable();
			getglobal( "PlayerCenterFrameRightBtn" .. i .. "Txt" ):SetTextColor( 108, 75, 59 );
		else
			--未选中
			getglobal( "PlayerCenterFrameSubPage"  .. i ):Hide();
			getglobal( "PlayerCenterFrameRightBtn" .. i ):Enable();
			getglobal( "PlayerCenterFrameRightBtn" .. i .. "Txt" ):SetTextColor( 179, 147, 105 );
			getglobal( "PlayerCenterFrameRightBtn" .. i ):DisChecked();
			getglobal( "PlayerCenterFrameSubPage0"):Hide();
		end
	end

end



--玩家第一页的3个图片摘要
function checkPage1_3Photo()
	Log( "call checkPage1_3Photo, index=" .. ns_playercenter.upload_photo_index );

	if  ns_playercenter.photoFileList[1] or ns_playercenter.photoFileList[2] or ns_playercenter.photoFileList[3] then
		--有图
		getglobal( "PlayerCenterFrameSubPage1CreatePhotoBtn" ):Hide();
		getglobal( "PlayerCenterFrameSubPage1Photo0un" ):Hide();
		getglobal( "PlayerCenterFrameSubPage1Photo0txt" ):Hide();

		for i=1, 3 do
			getglobal( "PlayerCenterFrameSubPage1Photo" .. i ):Show();
			getglobal( "PlayerCenterFrameSubPage1Photo" .. i .. "bkg"):Show();

			if  ns_playercenter.photoFileList[i] then
				getglobal( "PlayerCenterFrameSubPage1Photo" .. i ):Show();
				getglobal( "PlayerCenterFrameSubPage1Photo" .. i ):SetTexUV(0, 0, 0, 0);

				local tmp_file_ = 'PlayerCenterFrameSubPage1Photo' .. i;
				local function no_stretch()
					showPicNoStretch( tmp_file_ );
				end

				--Log( "url=" .. ns_playercenter.photoFileList[ i ].url );
				--Log( "filename=" .. ns_playercenter.photoFileList[ i ].filename .. "_" );
				ns_http.func.downloadPng( ns_playercenter.photoFileList[ i ].url,
				                          ns_playercenter.photoFileList[ i ].filename .. "_",       		 --加上"_"后缀
				                          nil, 'PlayerCenterFrameSubPage1Photo' .. i, no_stretch );          --下载文件

				getglobal( "PlayerCenterFrameSubPage1Photo" .. i .. "un"):Hide();

				private_PlayerCenter_set_checked_pic( 'PlayerCenterFrameSubPage1PendingPic' .. i , 
				                                      'PlayerCenterFrameSubPage1PendingTxt' .. i , 
													  ns_playercenter.photoFileList[ i ].checked ,
													  'PlayerCenterFrameSubPage1Photo' .. i
													  );

			else
				getglobal( "PlayerCenterFrameSubPage1Photo" .. i .. "un"):Show();
				getglobal( "PlayerCenterFrameSubPage1Photo" .. i ):Hide();
				--getglobal( "PlayerCenterFrameSubPage1Photo" .. i ):SetTextureHuiresXml("ui/mobile/texture/uitex4.xml");
				--getglobal( "PlayerCenterFrameSubPage1Photo" .. i ):SetTexUV("grzx_diban03.png");
				--getglobal( "PlayerCenterFrameSubPage1Photo" .. i ):Hide();

				private_PlayerCenter_set_checked_pic( 'PlayerCenterFrameSubPage1PendingPic' .. i , 'PlayerCenterFrameSubPage1PendingTxt' .. i , 1 );
			end
		end

	else

		Log("Hide map");
		if  IsLookSelf() then
			--无图
			getglobal( "PlayerCenterFrameSubPage1CreatePhotoBtn" ):Show();
			getglobal( "PlayerCenterFrameSubPage1Photo0un" ):Show();
			getglobal( "PlayerCenterFrameSubPage1Photo0txt" ):Show();

			for i=1, 3 do
				getglobal( "PlayerCenterFrameSubPage1Photo" .. i ):Hide();
				getglobal( "PlayerCenterFrameSubPage1Photo" .. i .. "un"):Hide();
				getglobal( "PlayerCenterFrameSubPage1Photo" .. i .. "bkg"):Hide();

				private_PlayerCenter_set_checked_pic( 'PlayerCenterFrameSubPage1PendingPic' .. i , 'PlayerCenterFrameSubPage1PendingTxt' .. i , 1 );
			end
		else
			getglobal( "PlayerCenterFrameSubPage1CreatePhotoBtn" ):Hide();
			getglobal( "PlayerCenterFrameSubPage1Photo0un" ):Hide();
			getglobal( "PlayerCenterFrameSubPage1Photo0txt" ):Hide();

			for i=1, 3 do
				getglobal( "PlayerCenterFrameSubPage1Photo" .. i ):Hide();
				getglobal( "PlayerCenterFrameSubPage1Photo" .. i .. "un"):Show();
				getglobal( "PlayerCenterFrameSubPage1Photo" .. i .. "bkg"):Show();
				private_PlayerCenter_set_checked_pic( 'PlayerCenterFrameSubPage1PendingPic' .. i , 'PlayerCenterFrameSubPage1PendingTxt' .. i , 1 );
			end
		end

	end
end



--不拉升高宽适配，居中显示一个图片
function  showPicNoStretch( obj_name )
	local obj_ = getglobal( obj_name );
	if not obj_ then
		--兼容不报错
		return
	end

	local w1_, h1_ = obj_:getRelWidth(), obj_:getRelHeight();
	local w2_, h2_ = obj_:GetWidth(),    obj_:GetHeight();
	--Log( "w=" .. w1_ .. ", h=" .. h1_ .. ", ww=" .. w2_ .. ", hh=" .. h2_ );

	if w1_>0 and w2_>0 and h1_>0 and h2_>0 then
		local r1 = w1_ / h1_;  --图片
		local r2 = w2_ / h2_;  --框

		local u_, v_ = w1_, h1_;   --图片实际大小

		if  r1 > r2 then
			--图片更宽     h1*(w2/h2)
			u_ = h1_ * ( w2_ / h2_);
			local u_begin = ( w1_ - u_ )*0.5;
			--Log( "0=" .. u_begin .. ", 0=" .. 0 .. ", u=" .. u_ .. ", v=" .. v_ );
			obj_:SetTexUV( u_begin, 0, u_, v_ );
		else
			--图片窄
			v_ = w1_ * ( h2_ / w2_ );    			--v_ = w1_ / ( w2_ / h2_ );
			local v_begin = ( h1_ - v_ ) * 0.5;
			--Log( "0=" .. 0 .. ", 0=" .. v_begin .. ", u=" .. u_ .. ", v=" .. v_ );
			obj_:SetTexUV( 0, v_begin, u_, v_ );
		end
	end
end



--显示个人中心 - 资料分页
function PlayerCenterFrameSubPage1_OnShow()
	Log("call PlayerCenterFrameSubPage1_OnShow");

	if  ns_playercenter.net_ok then
		--
	else
		--隐藏
		getglobal( "PlayerCenterFrameSubPage1CreatePhotoBtn" ):Hide();
		getglobal( "PlayerCenterFrameSubPage1Photo0un" ):Hide();
		getglobal( "PlayerCenterFrameSubPage1Photo0txt" ):Hide();

		for i=1, 3 do
			getglobal( "PlayerCenterFrameSubPage1Photo" .. i ):Hide();
			getglobal( "PlayerCenterFrameSubPage1Photo" .. i .. "un"):Hide();
		end
	end


	--图片比例
	for i=1, 3 do
		showPicNoStretch( "PlayerCenterFrameSubPage1Photo" .. i );
	end
end

--刷新鉴赏家图标
function resetConnoisseurIcon()
	local scale = UIFrameMgr:GetScreenScaleY();
	local offsetX = getglobal( "PlayerCenterFrameSubPage1Txt1" ):GetTextExtentWidth( ns_playercenter.NickName  )/scale + 41;

	local stat = ns_playercenter.expert and ns_playercenter.expert.stat or 0;
	local level = ns_playercenter.expert and ns_playercenter.expert.level or 0;

	--评测分类
	if stat == 2 and (IsLookSelf() or if_show_experter_push_map()) then		
		getglobal("PlayerCenterFrameRightBtn4"):Show();

	else
		getglobal("PlayerCenterFrameRightBtn4"):Hide();
	end

	--鉴赏家徽章
	if stat == 2 then
		getglobal("PlayerCenterFrameSubPage1ConnoisseurBtn"):Show();
		getglobal("PlayerCenterFrameSubPage1ConnoisseurBtn"):SetPoint("left", "PlayerCenterFrameSubPage1Txt1", "left", offsetX+7, -4);

		if not getkv("connoisseur_guide") and IsLookSelf() then
			getglobal("PlayerCenterFrameSubPage1ConnoisseurBtnEffect"):Show();
			getglobal("PlayerCenterFrameSubPage1ConnoisseurBtnEffect"):SetUVAnimation(100, true);
		end

		local index = level+1;
		
		local uvName = "cwjsj_huizhang0"..index;
		getglobal("PlayerCenterFrameSubPage1ConnoisseurBtnNormal"):SetTexUV(uvName);
		getglobal("PlayerCenterFrameSubPage1ConnoisseurBtnPushedBG"):SetTexUV(uvName);

		--[[
		if IsLookSelf() then
			getglobal("PlayerCenterFrameSubPage1ConnoisseurBtn"):Enable();
		else
			getglobal("PlayerCenterFrameSubPage1ConnoisseurBtn"):Disable()
		end
		]]
	else
		getglobal("PlayerCenterFrameSubPage1ConnoisseurBtn"):Hide();
	end

	--实名认证标签
	if getglobal("PlayerCenterFrameSubPage1ConnoisseurBtn"):IsShown() then
		getglobal("PlayerCenterFrameSubPage1AuthIcon"):SetPoint("left", "PlayerCenterFrameSubPage1Txt1", "left", offsetX+42, -2);
	else
		getglobal("PlayerCenterFrameSubPage1AuthIcon"):SetPoint("left", "PlayerCenterFrameSubPage1Txt1", "left", offsetX+7, -2);
	end

	--实名认证标签
	if IsLookSelf() and AccountManager.idcard_info and not UseTpRealNameAuth() then
		getglobal("PlayerCenterFrameSubPage1AuthIcon"):Show();
		
		local idCardInfo = AccountManager:idcard_info();
		local state = AccountManager:realname_state()
		if state ~= 1  then	--未认证
			if RealNameAuthSwitch then
				getglobal("PlayerCenterFrameSubPage1AuthIconNormal"):SetTexUV("ljdt_renzheng01");
				getglobal("PlayerCenterFrameSubPage1AuthIconPushedBG"):SetTexUV("ljdt_renzheng01");
			else
				getglobal("PlayerCenterFrameSubPage1AuthIcon"):Hide();
			end
		else
			if idCardInfo and idCardInfo.age and idCardInfo.age < 18 then		--未满182
				getglobal("PlayerCenterFrameSubPage1AuthIconNormal"):SetTexUV("ljdt_renzheng02");
				getglobal("PlayerCenterFrameSubPage1AuthIconPushedBG"):SetTexUV("ljdt_renzheng02");
			else
				getglobal("PlayerCenterFrameSubPage1AuthIconNormal"):SetTexUV("ljdt_renzheng03");
				getglobal("PlayerCenterFrameSubPage1AuthIconPushedBG"):SetTexUV("ljdt_renzheng03");
			end
		end
	else
		getglobal("PlayerCenterFrameSubPage1AuthIcon"):Hide();
	end
end



--刷新资料
--设置名字和迷你号
function  resetNameAndMode()

	Log( "call resetNameAndMode, nickname=" .. ns_playercenter.NickName );

	getglobal( "PlayerCenterFrameSubPage1Txt1" ):SetText( ns_playercenter.NickName );
	getglobal( "PlayerCenterFrameSubPage1Txt2" ):SetText( GetS(359) .. getShortUin(ns_playercenter.op_uin) );
	local scale = UIFrameMgr:GetScreenScaleY();
	local offsetX = getglobal( "PlayerCenterFrameSubPage1Txt1" ):GetTextExtentWidth( ns_playercenter.NickName  )/scale + 10;
	getglobal( "PlayerCenterFrameSubPage1Gender" ):SetPoint("left", "PlayerCenterFrameSubPage1Txt1", "left", offsetX, -5 );
	offsetX = getglobal( "PlayerCenterFrameSubPage1Txt2" ):GetTextExtentWidth( GetS(359) .. getShortUin(ns_playercenter.op_uin)  )/scale + 10;
	getglobal( "PlayerCenterFrameSubPage1CopyUin" ):SetPoint("left", "PlayerCenterFrameSubPage1Txt2", "left", offsetX, -5 );


	-- 3d形象
	if getglobal("PlayerCenterFrame"):IsShown() then
		local roleview = getglobal("PlayerCenterFrameModelView")
		local player = getShowModel();
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			roleview:attachActorBody(player, 0, false)
		else
			player:attachUIModelView(roleview, 0, false);
		end
		player:setScale(0.75);	--roleview:setActorScale(1.2, 1.2, 1.2);
		--roleview:playActorAnim(100100,0);
		--roleview:playEffect(1038, 0);
		roleview:playActorAnim(100108, 0);
		roleview:playEffect(1038, 0);
		local skinModel;
		if  IsLookSelf() then
		    skinModel = AccountManager:getRoleSkinModel();
		else
		    skinModel = ns_playercenter.SkinID;
		end
		if skinModel > 0 then
			local skinDef = RoleSkinCsv:get(skinModel);
			if skinDef ~= nil then
				ClientMgr:playStoreSound2D("sounds/skin/"..skinDef.Sound..".ogg");
				if skinDef.ShowTimeEffect ~= nil then
				   roleview:playEffect(skinDef.ShowTimeEffect, 0);
				end
			end
		end
	
	end


	-- 玩家详细信息
	for i=1, 4 do
		local icon_ = getglobal( "PlayerCenterFrameSubPage1Info" .. i .. "Icon");
		icon_:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
		icon_:SetTexUV("grzx_icon0" .. i .. ".png");

		--LLDO:信用
		if i == 4 then
			icon_:SetSize(31, 27);
			icon_:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
			icon_:SetTexUV("grzx_icon_credit");
		end

		--   relation = {
		--    friend_beapply=1, friend_eachother=2, friend_oneway=2, friend_beattention=0, friend_toapply=2,
		--   }

		local txt_ = getglobal( "PlayerCenterFrameSubPage1Info" .. i .. "Txt");
		if     i==1 then
			local text_ = GetS(209)..":".. ns_playercenter.friend_count;
			txt_:SetText( text_ );
		elseif i==2 then
			local text_ = GetS(210)..":".. ns_playercenter.attention_count;
			txt_:SetText( text_ );
		elseif i==3 then
			local text_ = GetS(3457).. ns_playercenter.posting_num;
			txt_:SetText( text_ );
		elseif i==4 then
			txt_:SetText( GetS(10510) .. g_CreditDesc:GetColor() .. g_CreditDesc:GetRank() );	--LLDO:信用值
		end
	end

end


-- 编辑按钮展示
function PlayerCenterFrameInfoEdit_OnShow()
	ns_playercenter.NickName = AccountManager:getNickName();
	getglobal( "PlayerCenterFrameInfoEditNickName" ):SetText( ns_playercenter.NickName  );
end


--数据变化后 刷新所有界面
function refresh_ui()

	--gender
	changeGenderTxtPic(  ns_playercenter.gender, 'PlayerCenterFrameInfoEditGenderPic', 'PlayerCenterFrameInfoEditGenderName' );
	changeGenderTxtPic(  ns_playercenter.gender, 'PlayerCenterFrameSubPage1Gender'  );


	--ns_playercenter.head_frame_id
	changeHeadFrameTxtPic( ns_playercenter.head_frame_id, 'PlayerCenterFrameSubPage1HeadFrame' );
	changeHeadFrameTxtPic( ns_playercenter.head_frame_id, 'PlayerCenterFrameInfoEditHeadBtnFrame' );

	if  IsLookSelf() then
		-- changeHeadFrameTxtPic( ns_playercenter.head_frame_id, 'MiniLobbyFrameTopRoleInfoHeadNormal' );
		-- changeHeadFrameTxtPic( ns_playercenter.head_frame_id, 'MiniLobbyFrameTopRoleInfoHeadPushedBG' );
		changeHeadFrameTxtPic( ns_playercenter.head_frame_id, GetMiniLobbyRoleInfoIconNormalFrameName() );
		changeHeadFrameTxtPic( ns_playercenter.head_frame_id, GetMiniLobbyRoleInfoIconPushedBGFrameName() ); --mark by hfb for new minilobby
	end


	--刷新昵称和模型
	resetNameAndMode();


	--头像url更新
	if ns_playercenter.op_uin == AccountManager:getUin() then
		setPlayerHeadByUrl( ns_playercenter.head_url );
	end
	--是否解锁上传头像
	if  IsLookSelf() then
		resetUploadHead();
	end

	--第一页的3个图片摘要
	checkPage1_3Photo();

	--相册2
	resetPage2AllPhoto();


	--鉴赏家图标
	resetConnoisseurIcon();
end

--编辑个人资料
function PlayerCenterFrameSubPage1EditBtn_OnClick()
	if  IsLookSelf() then
		getglobal("PlayerCenterFrameInfoEdit"):Show();
		-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterEditBtn");
	end
end


--没有图片的时候 新建立图片 去看看
function PlayerCenterFrameSubPage1CreatePhotoBtn_OnClick()
	if  IsLookSelf() then
		--跳到相册
		PlayCenterFrameRightBtn_OnClick(2);
		
		if IsProtectMode() then
			getglobal( "PlayerCenterFrameRightBtn2" ):DisChecked();
		else
			getglobal( "PlayerCenterFrameRightBtn2" ):SetChecked(true);
		end
	end
end


--资料编辑窗口 关闭
function PlayerCenterFrameInfoEditCloseBtn_OnClick()
	getglobal("PlayerCenterFrameInfoEdit"):Hide();

	--重刷界面
	PlayerCenterFrameSubPage1_OnShow();
end

-- 修改资料 1=头像  2=昵称  3=性别
function PlayerCenterFrameInfoEditBtn_OnClick( num_ )

	if  IsLookSelf() then
		if     num_ == 1 then
			getglobal("PlayerCenterFrameHeadEdit"):Show();
			-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterHeadEditBtn");
		elseif num_ == 2 then
			if checkModifyHeadNameSignatureOpened() then
				getglobal("NickModifyFrame"):Show();
			end
			-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterNicknameEditBtn");
		elseif num_ == 3 then
			getglobal("PlayerCenterFrameEditGender"):Show();
			-- statisticsGameEvent(701, "%s", "OnClick", "%lls", "PlayerCenterGenderEditBtn");
		end
	end
end

--关闭头像编辑框
function PlayerCenterFrameHeadEditCloseBtn_OnClick()
	getglobal("PlayerCenterFrameHeadEdit"):Hide();
end


--显示资料编辑 - 头像
function PlayerCenterFrameHeadEdit_OnShow()
	PlayerCenterFrameInfoEditChannel_OnClick(1);
	getglobal( "PlayerCenterFrameHeadEditChannel1" ):Checked();

	local x_, y_ = 0, 0;
	for i=1, ns_playercenter.head_max do
		x_ = x_ + 1;
		if  x_ > 7 then
			x_ = 1;
			y_ = y_ + 1;
		end
		getglobal('PlayerCenterFrameHeadEditHeadFrame' .. i ):SetPoint( "topleft", "PlayerCenterFrameHeadEditBkg1", "topleft", x_*90 + 105, y_*81 + 20 );
	end

end


--选择头像分类 1=全部 2=主播专属 2=主播专属
function PlayerCenterFrameInfoEditChannel_OnClick(num_)
	Log("call PlayerCenterFrameInfoEditChannel_OnClick=" .. num_)

	ns_playercenter.head_frame_id_select = ns_playercenter.head_frame_id;   --记录备选值

	getglobal('PlayerCenterFrameHeadEditTips1'):Hide();
	getglobal('PlayerCenterFrameHeadEditTips2'):Hide();

	for i=1, 3 do
		if  i==num_ then
			getglobal( "PlayerCenterFrameHeadEditChannel" .. i  ):Disable();
			getglobal( "PlayerCenterFrameHeadEditChannel" .. i .. "Txt"  ):SetTextColor( 99, 72, 42 );
			ShowAllHeadByType( i );
		else
			getglobal( "PlayerCenterFrameHeadEditChannel" .. i  ):Enable();
			getglobal( "PlayerCenterFrameHeadEditChannel" .. i .. "Txt"  ):SetTextColor( 213, 176, 125 );
			getglobal( "PlayerCenterFrameHeadEditChannel" .. i  ):DisChecked();
		end
	end

end

-- 按照类型展示头像
function ShowAllHeadByType( type_ )
	ns_playercenter.head_select_type = type_;  --记录当前玩家选择的分类

	-- 1=所有头像 2=主播 过滤选项
	ns_playercenter.head_select = {};


	--Hidetype
	local function is_no_hide_ ( v )		
		if  v.HideType and v.HideType == 1 then
			--没有开通隐藏头像
			if  func_has_opened_head_frames( v.FrameID ) > 0 then
				return true
			else
				return false  --没有开通，隐藏
			end
		end
		return true
	end


	--for i=1, #g_heads_frame_config do
	for k, v in ipairs(g_heads_frame_config) do
		if  type_ == 1 then
			--所有头像
			if  is_no_hide_( v ) then
				table.insert( ns_playercenter.head_select, v );
			end
		else
			--分类头像
			if  type_ == v.Group then
				if  is_no_hide_( v ) then
					table.insert( ns_playercenter.head_select, v );
				end
			end
		end
	end


	for i=1, ns_playercenter.head_max do
		if  ns_playercenter.head_select[i] then
			getglobal('PlayerCenterFrameHeadEditHeadFrame' .. i ):Show();

			local icon_ = getglobal( "PlayerCenterFrameHeadEditHeadFrame" .. i .. "Frame");
			icon_:SetTexture( HeadFrameCtrl:getTexPath( ns_playercenter.head_select[i].FrameID ) );
			icon_:Show();


			--是否显示锁
			local locker_ = getglobal( "PlayerCenterFrameHeadEditHeadFrame" .. i .. "Lock");
			local temp_   = getglobal( "PlayerCenterFrameHeadEditHeadFrame" .. i .. "Temp");
			temp_:Hide();
			local open_, left_ = func_has_opened_head_frames(ns_playercenter.head_select[i].FrameID)
			Log( "head_frame open=" .. open_ .. ", left=" .. left_ .. ", for " .. ns_playercenter.head_select[i].FrameID );
			if  open_ > 0 then
				locker_:Hide();
				if  left_ > 0 then
					temp_:Show();     --显示临时标志
				end
			else
				locker_:Show();
			end

		else
			getglobal('PlayerCenterFrameHeadEditHeadFrame' .. i ):Hide();
		end


		--显示玩家头像
		if  ns_playercenter.head_select[i] and ns_playercenter.head_select[i].FrameID == ns_playercenter.head_frame_id_select then
			getglobal( 'PlayerCenterFrameHeadEditHeadFrame' .. i .. 'Head' ):Show();
		else
			getglobal( 'PlayerCenterFrameHeadEditHeadFrame' .. i .. 'Head' ):Hide();
		end

	end

end



--点击一个头像
function PlayerCenterHeadFrameBtn_OnClick()
	local id = this:GetClientID();
	if  id == 0 then
		Log( "call PlayerCenterHeadFrameBtn_OnClick=0, normal ignore." );  --不能点击的外部按钮
	else
		if  ns_playercenter.head_select and ns_playercenter.head_select[ id ] then
			if  ns_playercenter.head_frame_id_select ~= ns_playercenter.head_select[ id ].FrameID then
				Log( "call PlayerCenterHeadFrameBtn_OnClick=" .. id .. ", head=" .. ns_playercenter.head_select[ id ].FrameID );
				ns_playercenter.head_frame_id_select =  ns_playercenter.head_select[ id ].FrameID;
				ShowAllHeadByType( ns_playercenter.head_select_type );
			end

			----显示说明
			local  info_ = g_heads_frame_config_map[ns_playercenter.head_frame_id_select];
			if  info_ and info_.StringID then
				local tips1_ = getglobal('PlayerCenterFrameHeadEditTips1');
				tips1_:SetText( GetS(info_.StringID) );
				tips1_:Show();
				
				local tips2_ = getglobal('PlayerCenterFrameHeadEditTips2');
				local open_, left_ = func_has_opened_head_frames(ns_playercenter.head_frame_id_select)
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


-- -- 确认修改头像
-- function layerCenterFrameHeadEditConfirm1_OnClick()
-- 	Log( "call layerCenterFrameHeadEditConfirm1_OnClick, id=" .. ns_playercenter.head_frame_id_select);

-- 	--是否已经在使用
-- 	if  ns_playercenter.head_frame_id_select == ns_playercenter.head_frame_id then
-- 		--未变化
-- 		Log("same headframe");
-- 		ShowGameTips(GetS(5298));
-- 		return
-- 	end

-- 	local select_ =  g_heads_frame_config_map[ ns_playercenter.head_frame_id_select ];
-- 	if  select_ then
-- 		--判断是否已经开通
-- 		if  func_has_opened_head_frames( ns_playercenter.head_frame_id_select ) > 0 then
-- 			--已经开通
-- 			Log( "has open" )
-- 		else
-- 			--未开通
-- 			Log( "not open" )
-- 			ShowGameTips(GetS(5299));
-- 			return
-- 		end


-- 		--如果是鉴赏家头像框，检测权限
-- 		if  ns_playercenter.head_frame_id_select == 20220 or ns_playercenter.head_frame_id_select == 20320 then
-- 			if  ns_playercenter.expert and ns_playercenter.expert.stat and ns_playercenter.expert.stat == 2 then
-- 				--是鉴赏家
-- 			else
-- 				Log( "not experter" )
-- 				ShowGameTips(GetS(1331));
-- 				return
-- 			end
-- 		end
		
		
-- 		--切换头像框
-- 		ns_playercenter.func.WWW_setPlayerFrameId( ns_playercenter.head_frame_id_select );

-- 		getglobal("PlayerCenterFrameHeadEdit"):Hide();
-- 	else
-- 		Log( "error: no this id" );
-- 	end
-- end


--upload头像按钮
function PlayerCenterFrameUploadHeadBtn_OnClick()
	Log( "call PlayerCenterFrameUploadHeadBtn_OnClick" );

	if  IsLookSelf() then
		--normal
	else
		return;
	end


	if  t_exhibition.close_upload == 1 then
		ShowGameTips( GetS(3479), 3 );  --"此功能暂未开放。", 3);
		return;
	end

	if  ns_playercenter.head_unlock == 0 then
		--getglobal( 'UnlockCostCommFrame' ):Show();
		beginUnlockHead(1);
		return;
	end

	local head_path_ = getkv( "head_pic_cache" );
	Log( "head_path_=" .. (head_path_ or "nil") );
	if  head_path_ and #head_path_>0 and gFunc_isStdioFileExist( head_path_ ) then
		PlayerCenterFrameHeadChange_OnClick(0);
	else
		private_upload_head();
	end


end


function private_upload_head()

	--设置回调
	ns_playercenter.upload_pic_callback = function()
		if  gFunc_isStdioFileExist( g_photo_root .. "head_upload_tmp.png" ) then
			--请求上传位置
			ns_http.func.upload_md5_file_pre( PlayerCenterFrame_uploadHeadPre_cb );
		else
			Log("cancel upload");  			--没有文件，放弃
		end
	end


	--bool showImagePicker(std::string path, int type, bool crop=true);	//type 1相册 2相机
	if  ClientMgr:showImagePicker( g_photo_root .. "head_upload_tmp.png", 1 )  then
		--select ok
	else
		Log( "showImagePicker = false" );
		ns_playercenter.upload_pic_callback = nil;
	end

end


function private_remove_head()
	ns_http.func.reset_user_profile_head( PlayerCenterFrame_resetHead_cb )
	t_exhibition.self_data_dirty = true;
end



--调用完成
function onImagePicked( ret )
	Log( "call onImagePicked=" .. (ret or "nil") );
	if  ns_playercenter.upload_pic_callback then
		Log( "call upload_pic_callback" );
		ns_playercenter.upload_pic_callback();
		ns_playercenter.upload_pic_callback = nil;
	else
		Log( "call upload_pic_callback nil..." );
	end

	if t_ExhibitionCenter.upload_pic_callback then
		t_ExhibitionCenter.upload_pic_callback();
		t_ExhibitionCenter.upload_pic_callback =nil;
	end

	if sa_ImagePackerManager.upload_pic_callback then
		sa_ImagePackerManager.upload_pic_callback(ret);
		sa_ImagePackerManager.upload_pic_callback =nil;
	end

	if sa_ImagePackerManager.upload_pic_callback2 then
		sa_ImagePackerManager.upload_pic_callback2(ret);
		sa_ImagePackerManager.upload_pic_callback2 =nil;
	end

	if gTools_WorkSpaceHead.upload_pic_callback then
		gTools_WorkSpaceHead.upload_pic_callback(ret);
		gTools_WorkSpaceHead.upload_pic_callback =nil;
	end

	if GetInst("ResourceDataManager") then
		GetInst("ResourceDataManager"):pickPicOk(ret);
	end
	
	if gRaceSystemInterface and gRaceSystemInterface.upload_pic_callback then 
		gRaceSystemInterface.upload_pic_callback(ret)
	end 

	local pCallRet, senddata = pcall(JSON.encode, JSON, {ret=ret})
	if pCallRet then
		SandboxLua.eventDispatcher:Emit(nil, "ON_IMAGE_PICKED", SandboxContext():SetData_String("ret", senddata))
	end
end



--取消
function PlayerCenterFrameUploadHeadBtnCancel_OnClick()
	Log( "call PlayerCenterFrameUploadHeadBtn_OnClick" );
	beginUnlockHead(99);
end


-- 获得上传的地址
function PlayerCenterFrame_uploadHeadPre_cb( ret_ )
	Log( "PlayerCenterFrame_uploadHeadPre_cb ret=" .. ret_ );
	--ok:http://xxxxxxxxxx/miniw/upload/?type=photo&node=2&dir=20170414&token=9db87135d11d929db7a8df1aee3163b4&uin=1166200

	if  string.sub( ret_, 1, 3 ) == "ok:" then
		local upload_url_ =  string.sub( ret_, 4 );
		upload_url_ = string_trim( upload_url_ );
		Log( "[" .. upload_url_  .. "]" );
		ns_http.func.upload_md5_file( g_photo_root .. "head_upload_tmp.png",  upload_url_, PlayerCenterFrame_uploadHead_cb  );

		-- getglobal('PlayerCenterFrameHeadEditBarBkg'):Show();
		-- getglobal('PlayerCenterFrameHeadEditBar'):Show();
		-- getglobal('PlayerCenterFrameHeadEditBar'):SetWidth(0);
		getglobal('ZoneHeadEditBarBkg'):Show();
		getglobal('ZoneHeadEditBar'):Show();
		getglobal('ZoneHeadEditBar'):SetWidth(0);

	else
		Log( "PlayerCenterFrame_uploadHeadPre_cb = false" );
	end
end


-- reset头像
function PlayerCenterFrame_resetHead_cb( ret_ )
	Log( "PlayerCenterFrame_resetHead_cb ret=" .. ret_ );
	if  string.sub( ret_, 1, 2 ) == "ok" then
		--将审核中的状态也隐藏掉
		t_exhibition.playerinfo.head_checked = 1;
		private_PlayerCenter_set_checked_pic( 'ZoneHeadEditPendingPic', 'ZoneHeadEditPendingTxt', t_exhibition.playerinfo.head_checked  );

		--做个标记，avatar 头像信息更新在时候用
		HeadCtrl.headInfoResetFlag = 1;

		-- setPlayerHeadByUrl("d");
		t_exhibition.playerinfo.head_url = "d";
		PEC_SetPlayerHeadFile(t_exhibition.playerinfo);

		--这里还应该主动重新拉取 profile
		ns_playercenter.self_data_dirty = true
		WWW_update_self_profile()
	else
		Log( "PlayerCenterFrame_uploadHeadPre_cb = false" );
	end
end




--上传头像完成
function PlayerCenterFrame_uploadHead_cb( ret, token_ )

	Log("call PlayerCenterFrame_uploadHead_cb");

	--设置玩家头像
	if  ret == 200 then
		getglobal('ZoneHeadEditBarBkg'):Hide();
		getglobal('ZoneHeadEditBar'):Hide();

		--ok:token=6f8c3d78a2b238bd0e9a259b6c7605a5&node=2&dir=20170415
		if  token_ and  string.sub( token_, 1, 3 ) == "ok:" then
			local sub_token_ = string.sub( token_, 4 );
			sub_token_ = string_trim( sub_token_ );
			Log( "[" .. sub_token_  .. "]" );
			local file_path_ = g_photo_root .. "head_upload_tmp.png";
			ns_http.func.set_user_profile_head( file_path_, sub_token_, PlayerCenterFrame_setPlayerProfileHead_cb  );
			t_exhibition.self_data_dirty = true;
		end

		t_exhibition.playerinfo.head_checked = 0;
		private_PlayerCenter_set_checked_pic( 'ZoneHeadEditPendingPic', 'ZoneHeadEditPendingTxt', t_exhibition.playerinfo.head_checked  );

	elseif  token_ and token_ == 'progress' then
		if  ret > 0 then
			getglobal('ZoneHeadEditBar'):SetWidth( ret );
		else
			getglobal('ZoneHeadEditBar'):SetWidth( 0 );
		end
	else

	end
end


--设置玩家头像profile数据成功
function PlayerCenterFrame_setPlayerProfileHead_cb( ret_ )
	Log("call PlayerCenterFrame_setPlayerProfileHead_cb=" .. (ret_ or "nil") );

	--请求玩家头像下载地址 更新为新上传的图片
	if  string.sub( ret_, 1, 3 ) == "ok:" then
		local upload_url_ =  string.sub( ret_, 4 );
		upload_url_ = string_trim( upload_url_ );
		Log( "[" .. upload_url_  .. "]" );

		rename_photo_pic_to_md5( "head_upload_tmp.png" );

		--setPlayerHeadByUrl( upload_url_ );
		t_exhibition.playerinfo.head_url = upload_url_;
		PEC_SetPlayerHeadFile(t_exhibition.playerinfo);
	else
		operate_fail();
	end
end



--按照状态来设置审核图片的样式
function  private_PlayerCenter_set_checked_pic( bkg_, txt_, stat_, photo_ )
	local bkg_o_ = getglobal( bkg_ );
	local txt_o_ = getglobal( txt_ );

	if     stat_ == 1 then
		bkg_o_:Hide();
		txt_o_:Hide();    --通过审核
	elseif stat_ == 2 then
		bkg_o_:Show();
		txt_o_:Show();
		txt_o_:SetText( GetS(3468) ); --"审核失败");

		if  photo_ then
			local photo_obj_ = getglobal( photo_ );
			if  photo_obj_ then
				photo_obj_:Hide()
			end
		end
		
	else
		bkg_o_:Show();
		txt_o_:Show();
		txt_o_:SetText( GetS(3469)  ); --"未审核");
	end

end



--按照用户的url设置头像
function  setPlayerHeadByUrl( url_, checked_ )
	Log( "call setPlayerHeadByUrl" );

	if  url_ and #url_ > 3 then
		print("111:");
		local file_name_ = g_photo_root .. getHttpUrlLastPart( url_ ) .. "_";	--加上"_"后缀
		private_PlayerCenter_set_checked_pic( 'PlayerCenterFrameHeadEditPendingPic', 'PlayerCenterFrameHeadEditPendingTxt', ns_playercenter.head_checked );

		local function downloadPng_head_cb()
			Log( "call downloadPng_head_cb, file=" .. file_name_ );

			--保存头像文件路径
			if  IsLookSelf() then
				setkv( "head_pic_cache", file_name_ );
			end

			ns_playercenter.headIndexFile = file_name_;
			t_exhibition.playerinfo.headIndexFile = file_name_;
			resetAllHead();
		end

		ns_http.func.downloadPng( url_, file_name_, nil, nil, downloadPng_head_cb );   --下载文件
	elseif  url_ == "d" then
		ns_playercenter.headIndexFile = GetHeadIconPath();  	--头像文件
		t_exhibition.playerinfo.headIndexFile = GetHeadIconPath();  	--头像文件
		if  IsLookSelf() then
			setkv( "head_pic_cache", nil );
		end
		resetAllHead();
	elseif url_ == "f" then  --头像审核失败

		if  IsLookSelf() then
			setkv( "head_pic_cache", nil );
		end
		resetAllHead();
		--hide
		private_PlayerCenter_set_checked_pic( 'PlayerCenterFrameHeadEditPendingPic', 'PlayerCenterFrameHeadEditPendingTxt', 2 );
	else
		print("222:");
		if  IsLookSelf() then
			setkv( "head_pic_cache", nil );
		end
		resetAllHead();
		--hide checked png
		private_PlayerCenter_set_checked_pic( 'PlayerCenterFrameHeadEditPendingPic', 'PlayerCenterFrameHeadEditPendingTxt', 1 );
	end

end



--头像功能是否已经解锁
function resetUploadHead()
	Log( "ns_playercenter.head_unlock=" .. ns_playercenter.head_unlock );
	if  ns_playercenter.head_unlock == 1 then
		getglobal( 'PlayerCenterFrameHeadEditUploadBtnText' ):SetText( GetS(3470) ); --"上传头像" );
		getglobal( 'PlayerCenterFrameHeadEditUploadBtnIcon1' ):SetTexUV("txbj_icon05.png");
	else
		getglobal( 'PlayerCenterFrameHeadEditUploadBtnText' ):SetText( GetS(4771) ); --"解锁" );
		getglobal( 'PlayerCenterFrameHeadEditUploadBtnIcon1' ):SetTexUV("bjjm_suo01.png");
	end
end

------------------------------------------------------
--显示选择性别
function PlayerCenterFrameEditGender_OnShow()
	PlayerCenterFrameEditGenderSelect_OnClick(  ns_playercenter.gender );
	getglobal( "PlayerCenterFrameEditGenderSelect" ..  ns_playercenter.gender ):Checked();

	ns_playercenter.gender_select = ns_playercenter.gender;   --记录备选值
end


--关闭性别选择界面
function PlayerCenterFrameEditGenderCloseBtn_OnClick()
	getglobal("PlayerCenterFrameEditGender"):Hide();
end


--选择性别 0=秘密 1=男 2=女
function PlayerCenterFrameEditGenderSelect_OnClick(num_)
	for i=0, 2, 1 do
		if i == num_ then
			getglobal( "PlayerCenterFrameEditGenderSelect" .. i  ):Disable();
			ns_playercenter.gender_select = num_;
			getglobal( "PlayerCenterFrameEditGenderSelect" .. i  .. "Tips" ):SetTextColor( 251, 253, 246 );

		else
			getglobal( "PlayerCenterFrameEditGenderSelect" .. i  ):Enable();
			getglobal( "PlayerCenterFrameEditGenderSelect" .. i  ):DisChecked();
			getglobal( "PlayerCenterFrameEditGenderSelect" .. i  .. "Tips" ):SetTextColor( 149, 131, 95 );
		end
	end
end


--确认或者取消修改性别  0=取消 1=确定
function PlayerCenterFrameEditGenderConfirm_OnClick( num_ )
	if num_ == 1 then
		--修改
		if  ns_playercenter.gender_select == ns_playercenter.gender then
			--未变化
			getglobal("PlayerCenterFrameEditGender"):Hide();
		else
			ns_playercenter.func.WWW_setPlayerGender( ns_playercenter.gender_select );
			getglobal("PlayerCenterFrameEditGender"):Hide();
		end

	else
		getglobal("PlayerCenterFrameEditGender"):Hide();
	end
end


----------------------------------------------------------sub page2-------
--显示相册分页
function PlayerCenterFrameSubPage2_OnShow()
	for i=1, 6 do
		if  ns_playercenter.photoFileList[ i ] then
			showPicNoStretch( 'PCenterPhoto' .. i .. 'Photo' );
		end
	end
end


--点击上传相册
function PlayerCenterFrameUploadPhotoBtn_OnClick()
	ns_playercenter.upload_photo_index = ns_playercenter.add_photo_index;
	Log( "call PlayerCenterFrameUploadPhotoBtn_OnClick ... id=" .. ns_playercenter.upload_photo_index );

	if  t_exhibition.close_upload == 1 then
		ShowGameTips( GetS(3479), 3 );  --"此功能暂未开放。", 3);
		return;
	end

	private_begin_upload_file();
end



function private_begin_upload_file()
	if  ns_playercenter.upload_photo_index <= ns_playercenter.photo_unlock then

		--设置回调
		ns_playercenter.upload_pic_callback = function()
			Log( "call upload_pic_callback_photo" );

			if  gFunc_isStdioFileExist(g_photo_root .. "photo_upload_tmp.png") then
				--请求上传位置
				ns_http.func.upload_md5_file_pre( PlayerCenterFrame_uploadPhotoPre_cb );

				getglobal( 'PlayerCenterFrameSubPage2UploadBtn' ):Hide();

				--进度条
				getglobal ('PCenterPhoto' .. ns_playercenter.upload_photo_index .. 'BarBkg' ):Show();
				getglobal ('PCenterPhoto' .. ns_playercenter.upload_photo_index .. 'Bar' ):Show();
				getglobal ('PCenterPhoto' .. ns_playercenter.upload_photo_index .. 'Bar' ):SetWidth(0);

			else
				Log("cancel upload");  			--没有文件，放弃
			end
		end

		--bool showImagePicker(std::string path, int type, bool crop=true);	//type 1相册 2相机
		if  ClientMgr:showImagePicker( g_photo_root .. "photo_upload_tmp.png", 1 )  then
			--select ok
		else
			ns_playercenter.upload_pic_callback = nil;
			Log( "showImagePicker = false" );
		end
	end
end



function PlayerCenterFrame_uploadPhotoPre_cb( ret_ )
	Log( "PlayerCenterFrame_uploadPhotoPre_cb ret=" .. ret_ );
	--ok:http://xxxxxxxxxx/miniw/upload/?type=photo&node=2&dir=20170414&token=9db87135d11d929db7a8df1aee3163b4&uin=1166200

	if  string.sub( ret_, 1, 3 ) == "ok:" then
		local upload_url_ =  string.sub( ret_, 4 );
		upload_url_ = string_trim( upload_url_ );
		Log( "[" .. upload_url_  .. "]" );
		ns_http.func.upload_md5_file( g_photo_root .. "photo_upload_tmp.png",  upload_url_, PlayerCenterFrame_uploadPhoto_cb  );

	else
		Log( "PlayerCenterFrame_uploadPhotoPre_cb = false" );
	end
end



--上传图片完成
function PlayerCenterFrame_uploadPhoto_cb( ret, token_ )

	Log("call PlayerCenterFrame_uploadPhoto_cb");

	--设置玩家相册
	if  ret == 200 then
		--进度条
		getglobal ('PCenterPhoto' .. ns_playercenter.upload_photo_index .. 'BarBkg' ):Hide();
		getglobal ('PCenterPhoto' .. ns_playercenter.upload_photo_index .. 'Bar' ):Hide();

		--ok:token=6f8c3d78a2b238bd0e9a259b6c7605a5&node=2&dir=20170415
		if  token_ and  string.sub( token_, 1, 3 ) == "ok:" then
			local sub_token_ = string.sub( token_, 4 );
			sub_token_ = string_trim( sub_token_ );
			Log( "[" .. sub_token_  .. "]" );
			local file_path_ = g_photo_root .. "photo_upload_tmp.png";
			local seq_ = ns_playercenter.upload_photo_index;
			ns_http.func.set_user_profile_photo( file_path_, seq_, sub_token_, PlayerCenterFrame_setPlayerProfilePhoto_cb  );
			ns_playercenter.self_data_dirty = true;
		end

	elseif token_ and token_ == "progress" then
		--进度条
		getglobal ('PCenterPhoto' .. ns_playercenter.upload_photo_index .. 'Bar' ):SetWidth( (tonumber(ret) or 0 ) );

	else

	end
end



--设置图片成功
function PlayerCenterFrame_setPlayerProfilePhoto_cb( ret_ )
	Log( "call PlayerCenterFrame_setPlayerProfilePhoto_cb=" ..  (ret_ or "nil") )

	--请求玩家头像下载地址 更新为新上传的图片
	if  string.sub( ret_, 1, 3 ) == "ok:" then
		local upload_url_ =  string.sub( ret_, 4 );
		upload_url_ = string_trim( upload_url_ );
		Log( "[" .. upload_url_  .. "]" );

		--改文件，节省流量
		rename_photo_pic_to_md5( "photo_upload_tmp.png" );
		setPlayerPhotoByUrl( upload_url_ );
	else
		operate_fail();
	end

end


--直接改文件名，节省流量
function  rename_photo_pic_to_md5( file_name )
	Log( "call rename_photo_pic_to_md5" );
	local f1_  = g_photo_root .. file_name;
	local md5_ = gFunc_getBigFileMd5(f1_);
	local f2_  = g_photo_root .. md5_ .. ".png";
	gFunc_renameStdioPath( f1_, f2_ );
end



--更新图片文件
function  setPlayerPhotoByUrl( url_ )
	if  url_ and #url_ > 3 then
		local file_name_ = g_photo_root .. getHttpUrlLastPart( url_ );
		ns_playercenter.photoFileList[ ns_playercenter.upload_photo_index ] = ns_playercenter.photoFileList[ ns_playercenter.upload_photo_index ] or {};
		ns_playercenter.photoFileList[ ns_playercenter.upload_photo_index ].url      = url_;
		ns_playercenter.photoFileList[ ns_playercenter.upload_photo_index ].filename = file_name_;

		local i = ns_playercenter.upload_photo_index;
		if  ns_playercenter.photoFileList[ i ] then
			ns_playercenter.photoFileList[ i ].checked = 0;
		end

		if  i < 4 then
			private_PlayerCenter_set_checked_pic( 'PlayerCenterFrameSubPage1PendingPic' .. i , 'PlayerCenterFrameSubPage1PendingTxt' .. i , 0 );
		end
		private_PlayerCenter_set_checked_pic( 'PCenterPhoto' .. i .. 'PendingPic', 'PCenterPhoto' .. i .. 'PendingTxt', 0 );

		refresh_ui();
	end
end



--更新所有图片
function resetPage2AllPhoto()
	Log( "resetPage2AllPhoto" );

	local empty_ = 100;    --空图标，放置点击上传按钮

	for i=1, 6 do

		if  ns_playercenter.photoFileList[ i ] then
			--有图
			local tmp_file_ = 'PCenterPhoto' .. i .. 'Photo';			
			getglobal( tmp_file_ ):Show();			
			private_PlayerCenter_set_checked_pic( 'PCenterPhoto' .. i .. 'PendingPic', 'PCenterPhoto' .. i .. 'PendingTxt',  ns_playercenter.photoFileList[ i ].checked, tmp_file_ );

			local function no_stretch()
				showPicNoStretch( tmp_file_ );
			end
			ns_http.func.downloadPng( ns_playercenter.photoFileList[ i ].url, 
			                          ns_playercenter.photoFileList[ i ].filename .. "_",		--加上"_"后缀
									  nil, tmp_file_, no_stretch );   --下载文件

		else
			--无图
			private_PlayerCenter_set_checked_pic( 'PCenterPhoto' .. i .. 'PendingPic', 'PCenterPhoto' .. i .. 'PendingTxt',  1 );
			empty_ = math.min( i, empty_ );
			getglobal( 'PCenterPhoto' .. i .. 'Photo' ):Hide();
		end

		if i <= ns_playercenter.photo_unlock then
			--空图
			--getglobal( 'PCenterPhoto' .. i .. 'PhotoLock' ):SetTextureHuiresXml("ui/mobile/texture/uitex4.xml");
			getglobal( 'PCenterPhoto' .. i .. 'PhotoLock' ):SetTexUV("txbj_xzicon01.png");
		else
			--锁
			--getglobal( 'PCenterPhoto' .. i .. 'PhotoLock' ):SetTextureHuiresXml("ui/mobile/texture/uitex4.xml");
			getglobal( 'PCenterPhoto' .. i .. 'PhotoLock' ):SetTexUV("bjjm_suo02.png");
		end
	end

	Log( "empty_=" .. empty_ );

	local  btn_add_ = getglobal( 'PlayerCenterFrameSubPage2UploadBtn' );

	if IsLookSelf() then
		if  empty_ <= ns_playercenter.photo_unlock then
			btn_add_:Show();
			--移动位置
			local x, y = 15, 85;
			if  empty_ == 2 then
				x, y = 280, 85;
			elseif   empty_ == 3 then
				x, y = 545, 85;
			elseif   empty_ == 4 then
				x, y = 15, 320;
			elseif   empty_ == 5 then
				x, y = 285, 320
			elseif   empty_ == 6 then
				x, y = 545, 320
			else
				--x, y = 15, 85;
			end
			btn_add_:SetPoint("topleft", "PlayerCenterFrameSubPage2", "topleft", x, y );
			ns_playercenter.add_photo_index = empty_;
		else
			btn_add_:Hide();
			--无空位
			ns_playercenter.add_photo_index = 0;  --无空位
		end
	else
		btn_add_:Hide();
	end

end



--点击一个图片
function PlayerCenterPhotoTemplate_OnClick()
	local id = this:GetClientID();

	if  IsLookSelf() then
		Log( "call PlayerCenterPhotoTemplate_OnClick = " .. (id or 0) );

		if  t_exhibition.close_upload == 1 then
			ShowGameTips( GetS(3479), 3 );   --"此功能暂未开放。", 3);
			return;
		end

		if  id <= ns_playercenter.photo_unlock then
			ns_playercenter.upload_photo_index = id;
			--展示修改和删除
			getglobal('PlayerCenterFramePhotoEdit'):Show();
		else
			ns_playercenter.upload_photo_index = 0;

			--展示解锁图片
			beginUnlockPhoto();
		end
	else
		--LLDO:访问别人, 显示举报按钮
		-- if  id <= ns_playercenter.photo_unlock then
		-- 	local btn = getglobal("PCenterPhoto" .. id .. "ReportBtn");
		-- 	if btn:IsShown() then btn:Hide(); else btn:Show(); end
		-- end
	end
end



--关闭photo修改面板
function PlayerCenterFramePhotoEditCloseBtn_OnClick()
	getglobal('PlayerCenterFramePhotoEdit'):Hide();
end



--修改还是删除图片
function PlayerCenterFramePhotoEditChange_OnClick(act_)
	if  act_ == 1 then
		--修改上传
		private_begin_upload_file();
		getglobal('PlayerCenterFramePhotoEdit'):Hide();
	elseif act_ == 2 then
		--删除
		ns_http.func.del_user_profile_photo( ns_playercenter.upload_photo_index, PlayerCenterFramePhotoEditDel_cb );
		ns_playercenter.self_data_dirty = true;
		getglobal('PlayerCenterFramePhotoEdit'):Hide();
	end
end


--删除图片的回调
function PlayerCenterFramePhotoEditDel_cb( ret_ )
	Log("call PlayerCenterFramePhotoEditDel_cb, ret=" .. ret_ )

	if  string.sub( ret_, 1, 3 ) == "ok:" then
		--重新刷新图片
		ns_playercenter.photoFileList[ ns_playercenter.upload_photo_index ] = nil;
		refresh_ui();
	else
		Log( "PlayerCenterFramePhotoEditDel_cb = false" );
	end

end


------------------------------------------------------

-- 点击解锁花费
g_UnlockCostCommFrame_type = "";

function UnlockCostCommFrameBtn_OnClick(act_)

	if  t_exhibition:isLookSelf() then
		--self
	else
		return
	end

	Log( "call UnlockCostCommFrameBtn_OnClick, act=" .. act_ );
	if  act_ == 0 then
		getglobal( 'UnlockCostCommFrame' ):Hide();
	else

		local num_ = AccountManager:getAccountData():getMiniCoin();
		if  num_ < 5 then
			ShowGameTips( GetS(3281), 3 );
			return;
		end

		--确认解锁
		if      g_UnlockCostCommFrame_type == "unlock_head"  then
			--解锁可上传头像
			ns_http.func.unlockCost( "unlock_head", beginUnlockHead_cb );
			t_exhibition.self_data_dirty = true;
		elseif  g_UnlockCostCommFrame_type == "unlock_photo" then
			--解锁玩家相册数 3到6
			ns_http.func.unlockCost( "unlock_photo", beginUnlockPhoto_cb );
			t_exhibition.self_data_dirty = true;
		else
			getglobal( 'UnlockCostCommFrame' ):Hide();
		end
	end

end



--解锁头像------------------------------------
function beginUnlockHead( act_ )
	if act_ == 1 then
		g_UnlockCostCommFrame_type = "unlock_head";
		getglobal( 'UnlockCostCommFrame' ):Show();
		getglobal( 'UnlockCostCommFrameContentNeedCostText' ):SetText( GetS(3472) ); --"是否现在开启自定义头像？" );
		getglobal( 'UnlockCostCommFrameContentNeedCost' ):SetText( "5" );
	elseif act_ == 99 then
		--取消
		local function unlockCost_cb( ret_ )
			--ShowGameTips( "data clearned" );
			ns_playercenter.net_ok = false;
			ns_playercenter.func.WWW_get_player_profile(ns_playercenter.op_uin);
		end
		ns_http.func.unlockCost( "unlock_head_cancel", unlockCost_cb );
		ns_playercenter.self_data_dirty = true;
	else

	end
end


function beginUnlockHead_cb( ret_ )

	if  AccountManager.data_update then
		AccountManager:data_update();
	end

	Log( "call beginUnlockHead_cb=" .. ret_ );
	if  string.sub( ret_, 1, 3 ) == "ok:" then
		local ret_code_ =  string.sub( ret_, 4 );
		ret_code_ = string_trim( ret_code_ );
		Log( "ret_code=" .. (ret_code_ or '0' ) );
		if ret_code_ == '1' then
			t_exhibition.head_unlock = 1;
			ShowGameTips( GetS(3473), 3 );     --"你解锁了头像上传功能！", 3 );
		else
			t_exhibition.head_unlock = 0;
			ShowGameTips( GetS(3474), 3 );     --"解锁失败，请稍后重试。", 3 );
		end
	else
		ShowGameTips( GetS(3474), 3 );         --"解锁失败，请稍后重试。", 3 );
	end

	-- refresh_ui();
	Zone_resetUploadHead();
	getglobal( 'UnlockCostCommFrame' ):Hide();
end


--解锁相册图片-----------------------------------------
function beginUnlockPhoto()
	g_UnlockCostCommFrame_type = "unlock_photo";
	getglobal( 'UnlockCostCommFrame' ):Show();
	getglobal( 'UnlockCostCommFrameContentNeedCostText' ):SetText( GetS(3475) ); --"是否解锁一个新的相册位置？" );
	getglobal( 'UnlockCostCommFrameContentNeedCost' ):SetText( "5" );
end


function beginUnlockPhoto_cb( ret_ )
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
			ns_playercenter.photo_unlock = ret_code_;
			ShowGameTips( GetS(3476), 3 );  --"你解锁了新的相册位置！", 3 );
		else
			--ns_playercenter.head_unlock = 0;
			ShowGameTips( GetS(3474), 3 );     --"解锁失败，请稍后重试。", 3 );
		end
	else
		ShowGameTips( GetS(3474), 3 );     --"解锁失败，请稍后重试。", 3 );
	end

	refresh_ui();
	getglobal( 'UnlockCostCommFrame' ):Hide();
end

-----------------------------------逻辑函数部分--------------------

ns_playercenter.func =         --避免和其他全局函数冲突
{
	--拉取用户数据
	WWW_get_player_profile = function(player_uin, ext_callback)
		Log( "call WWW_get_player_profile, uin=" .. player_uin );
		player_uin = tonumber(player_uin);
		if  player_uin<1000 or player_uin>=ns_const.__INT32__ then
			ext_callback( {ret=1} );  --号码错误
			do return end
		end

		
		if  ns_playercenter.self_data_dirty then
			--自己的资料需要重刷
			ns_playercenter.self_data_dirty = false
			local uin_ = AccountManager:getUin()
			if  ns_playercenter.server_ret_pool and ns_playercenter.server_ret_pool[uin_] then
				ns_playercenter.server_ret_pool[uin_] = nil
			end
		end

		if  ns_playercenter.net_ok and ns_playercenter.server_ret_pool and ns_playercenter.server_ret_pool[player_uin] then
			--使用cache
			Log( "find cache for " .. player_uin );
			ns_playercenter.func.WWW_get_player_profile_cb( ns_playercenter.server_ret_pool[player_uin], { callback=ext_callback }  );
			return;
		end

		--重新拉取
		local url_ = g_http_root_map .. 'miniw/profile?act=getProfile&op_uin=' .. player_uin .. '&' .. http_getS1Map();
		Log( url_ );
		ns_http.func.rpc( url_, ns_playercenter.func.WWW_get_player_profile_cb, { callback=ext_callback } , nil, 2);
	end,


	WWW_get_player_profile_cb = function( ret_, user_data_ )
		Log( "call WWW_get_player_profile_cb" );

		if isEducationalVersion then
			return
		end

		if user_data_ and user_data_.callback then user_data_.callback(ret_) end

		if  ret_ and ret_.ret then
			if  ret_.ret == 1 then
				--uin error
				ns_playercenter.func.net_not_ready();
				return;
			elseif ret_.ret == 404 then
				--新用户
			end

			ns_playercenter.server_ret   = ret_;
			ns_playercenter.net_ok       = true;

			--云服GM 
			ns_playercenter.rent_sup     = ret_.rent_sup or false

			if  check_use_new_server() then
				t_exhibition.close_upload = ret_.close_upload or 1;   --是否允许上传图片
			else
				Log( "check_use_new_server return false." );
			end


			getglobal( "PlayerCenterFrameSubPage0" ):Hide();
			--getglobal( "PlayerCenterFrameSubPage1" ):Show();
			getglobal( "PlayerCenterFrameRightBtn1" ):SetChecked(true);  --默认选1
			PlayCenterFrameRightBtn_OnClick(1);

			-- 设置用户数据
			ns_playercenter.server_ret.profile = ns_playercenter.server_ret.profile or {};
			local profile_ = ns_playercenter.server_ret.profile;
			if  profile_ then
				ns_playercenter.gender        = profile_.gender        or 0;
				ns_playercenter.head_frame_id = profile_.head_frame_id or 1;   --默认为头像1
				ns_playercenter.head_unlock   = profile_.head_unlock   or 0;
				ns_playercenter.photo_unlock  = profile_.photo_unlock  or 3;

				ns_playercenter.head_frames      = profile_.head_frames      or {};     --已经解锁的头像
				ns_playercenter.head_frames_temp = profile_.head_frames_temp or {};     --已经解锁的头像(30天)

				--兼容旧数据(旧版本头像) 20210
				if  (profile_.is_zhubo==1) and (not ns_playercenter.head_frames[20210]) then
					ns_playercenter.head_frames[20210] = { t=os.time() };
				end

				--昵称 角色 皮肤
				if  profile_.RoleInfo then
					DetachPlayerCenterUIModel();

					ns_playercenter.NickName = profile_.RoleInfo.NickName or "";
					ns_playercenter.SkinID   = profile_.RoleInfo.SkinID   or 0;
					ns_playercenter.Model    = profile_.RoleInfo.Model    or 0;
					if  ns_playercenter.Model <= 0 then
						ns_playercenter.Model = 2
					end

					Log( "set mode=" .. ns_playercenter.Model .. ", skin=" .. ns_playercenter.SkinID );
				end


				--好友 关注
				ns_playercenter.friend_count    = 0;
				ns_playercenter.attention_count = 0;
				if  profile_.relation then
					ns_playercenter.friend_count    = (profile_.relation.friend_eachother   or 0) + (profile_.relation.friend_oneway or 0);
					ns_playercenter.attention_count = (profile_.relation.friend_beattention or 0);
				end


				--发贴数
				ns_playercenter.posting_num = profile_.posting_num or 0;

				ns_playercenter.op_uin = profile_.uin or 0;

				--自定义头像
				if  profile_.header and profile_.header.url then
					ns_playercenter.head_checked = profile_.header.checked or 0;
					if  ns_playercenter.head_checked == 2 then
						ns_playercenter.head_url     = "f"       --审核失败
					else
						ns_playercenter.head_url     = profile_.header.url;
					end
					if profile_.uin == AccountManager:getUin() then
						setPlayerHeadByUrl( ns_playercenter.head_url );
					end
				else
					if  ns_playercenter.Model and ns_playercenter.SkinID then
						ns_playercenter.head_url = "";
						if IsLookSelf() then
							ns_playercenter.headIndexFile = GetHeadIconPath();  	--头像文件
						else
							local headPath = GetInst("HeadInfoSysMgr"):GetPlayerHeadPathByUin(profile_.uin)
							ns_playercenter.headIndexFile = headPath or "ui/roleicons/".. GetHeadIconIndex( ns_playercenter.Model, ns_playercenter.SkinID ) ..".png";  	--头像文件
						end
						if profile_.uin == AccountManager:getUin() then
							setPlayerHeadByUrl( ns_playercenter.head_url );
						end
					end
				end

				Log( "head_url=" .. ns_playercenter.head_url );


				--相册
				ns_playercenter.photoFileList = profile_.photo or {};
				for i=1, 6 do
					if  ns_playercenter.photoFileList[i] then
						ns_playercenter.photoFileList[i].filename = g_photo_root .. getHttpUrlLastPart( ns_playercenter.photoFileList[i].url );
					end
				end

				--已经设置变量 存储到玩家池
				if ns_playercenter.op_uin ~= nil then 
					ns_playercenter.server_ret_pool[ ns_playercenter.op_uin ] = ns_playercenter.server_ret;
				end 
				if  IsLookSelf() then
					refresh_WWW_get_self_profile( ns_playercenter.server_ret )  --保存到自己
				end


				--鉴赏家信息
				if profile_.expert then
					ns_playercenter.expert = profile_.expert;
				else
					ns_playercenter.expert = nil;
				end

				--LLDO:信用值
				if profile_.report2 and profile_.report2.score then
					ns_playercenter.selfScore = profile_.report2.score;
					Log("ns_playercenter.selfScore = " .. ns_playercenter.selfScore);
				else
					ns_playercenter.selfScore = 100;
				end


				--刷新界面
				refresh_ui();
			end

		else
			Log( "ERROR: ret=nil" );
		end
	end,


	-- 设置用户性别
	WWW_setPlayerGender = function( gender_ )
		if  ns_playercenter.net_ok then
			local url_ = g_http_root_map .. 'miniw/profile?act=setProfile&gender=' .. gender_ .. '&' .. http_getS1Map();
			Log( url_ );
			ns_http.func.rpc( url_, ns_playercenter.func.WWW_setPlayerGender_cb, nil, nil, true );
			ns_playercenter.self_data_dirty = true;
		else
			ns_playercenter.func.net_not_ready();
		end
	end,


	WWW_setPlayerGender_cb = function( ret_ )
		Log( "call WWW_setPlayerGender_cb" );
		if  ret_ and ret_.ret then
			if ret_.ret == 0 then   --修改成功
				ns_playercenter.gender = ns_playercenter.gender_select;
				refresh_ui();
			else
				ns_playercenter.func.operate_fail();
			end
		else
			Log( "ERROR: ret=nil" );
		end
	end,


	-- 设置用户头像框
	WWW_setPlayerFrameId = function( head_frame_id_ )
		if  ns_playercenter.net_ok then
			local url_ = g_http_root_map .. 'miniw/profile?act=setProfile&head_frame_id=' .. head_frame_id_ .. '&' .. http_getS1Map();
			Log( url_ );
			ns_http.func.rpc( url_, ns_playercenter.func.WWW_setPlayerFrameId_cb, nil, nil, true );
			ns_playercenter.self_data_dirty = true;
		else
			ns_playercenter.func.net_not_ready();
		end
	end,


	WWW_setPlayerFrameId_cb = function( ret_ )
		Log( "call WWW_setPlayerFrameId_cb" );
		if  ret_ and ret_.ret then
			if  ret_.ret == 0 then   				--修改成功
				ns_playercenter.head_frame_id = ns_playercenter.head_frame_id_select;

				--保存头像框
				if  IsLookSelf() then
					setkv( "head_frame_id_cache", ns_playercenter.head_frame_id );
				end

				refresh_ui();
				ShowGameTips(GetS(5297));
			else
				ns_playercenter.func.operate_fail();
			end
		else
			Log( "ERROR: ret=nil" );
		end
	end,


	--点击使用头像框
	WWW_try_open_head_frames = function( itemDef, cb_, use_all_ )
		Log("call WWW_try_open_head_frames, id=" .. itemDef.ID );

		local num_ = 1
		if  use_all_ then
			num_ = AccountManager:getAccountData():getAccountItemNum(itemDef.ID);
		end
		Log( "num_ = " .. (num_ or 0) )

		ns_playercenter.uin      = AccountManager:getUin();
		if  ns_playercenter.uin >= 1000 then
			local url_ = g_http_root_map .. 'miniw/profile?act=openHeadFrame&frame_id=' .. itemDef.ID;
			if  num_ > 1 then
				url_ = url_ .. "&num=" .. num_
			end
			url_ = url_ .. '&' .. http_getS1Map();
			Log( url_ );

			ns_http.func.rpc( url_, cb_, nil, nil, true );
			ns_playercenter.self_data_dirty = true;
		else
			ns_playercenter.func.net_not_ready();
		end
	end,


	--网络未通
	net_not_ready = function()
		ShowGameTips(GetS(3272), 3);
	end,


	--操作失败
	operate_fail = function()
		ShowGameTips(GetS(5297), 3);
	end,

	--加一个方法 判断玩家是否是 云服的GM
	IsPlayerRentSup = function()
		return ns_playercenter.rent_sup
	end,

};     --end func



--------------------------------------
function JumpEnvFrameClose_OnClick()
	getglobal( 'JumpEnvFrame' ):Hide();
end

function JumpEnvFrame_OnShow()
	local env_ = get_game_env();
	--Log( "call JumpEnvFrame_OnShow, " .. env_ );
	local apiId = ClientMgr:getApiId();

	if     env_ == 0  then
		getglobal( "JumpEnvFrameTitle" ):SetText("当前环境是：现网0 渠道" .. apiId);
	elseif env_ == 2  then
		getglobal( "JumpEnvFrameTitle" ):SetText("当前环境是：先遣服2 渠道" .. apiId);
	elseif env_ == 1  then
		getglobal( "JumpEnvFrameTitle" ):SetText("当前环境是：开发服1 渠道" .. apiId);
	else
		getglobal( "JumpEnvFrameTitle" ):SetText("当前环境是：" .. env_ .. " 渠道" .. apiId);
	end
end


function JumpEnvFrame_OnClick(env)
	getglobal("JumpEnvFrame"):Hide();
	JumpEnvFrame_OnShow();
	MessageBox(5, "您将切换到环境" .. env .. "，重启游戏后生效." , function(btn)
		if  btn == 'left' then
			set_game_env(env)
			ns_hotfix.clearErrorProtectCountPatch()   --清理热更新错误计数
			ClientMgr:gameExit(true);
		end
	end);
end


--清理热更新
function JumpEnvFrameCleanHF_OnClick(env)
	getglobal("JumpEnvFrame"):Hide();
	JumpEnvFrame_OnShow();
	MessageBox(5, "清理热更新文件?  \n需要重启游戏后生效." , function(btn)
		if  btn == 'left' then
			ns_hotfix.clearPatchFile()
			ns_hotfix.clearErrorProtectCountPatch()   --清理热更新错误计数
			ClientMgr:gameExit(true);
		end
	end);
end



--申请添加玩家为好友
function PlayerCenterFrameSubPage1AddFriendBtn_OnClick()
	local uin = ns_playercenter.op_uin;

	if getglobal("MiniWorksFrame"):IsShown()	then
		SetStatisticIdAndSrc(6000,"MiniWorksAddFriend");
	end


	if GetFriendDataByUin(uin)~=nil then
		ShowGameTips(GetS(38), 3);
		return;
	end
	if GetMyFriendNum() >= MaxFriends then
		ShowGameTips(GetS(1112927), 3);
		return;
	end
	AddUinAsFriend(uin);

end

--关注玩家
function PlayerCenterFrameSubPage1FollowBtn_OnClick()
	ReqFollowPlayer(ns_playercenter.op_uin, true);

	--关注+1
	local txt_ = getglobal( "PlayerCenterFrameSubPage1Info2Txt");
	local text_ = GetS(210)..":".. (ns_playercenter.attention_count + 1);
	txt_:SetText( text_ );

	if  ns_playercenter.server_ret.profile and ns_playercenter.server_ret.profile.relation then
		ns_playercenter.server_ret.profile.relation.friend_beattention = ns_playercenter.attention_count + 1;
	end

end

--举报玩家
local ReportTypes = nil;
local CurReportType = 1;
function PlayerCenterFrameSubPage1ReportBtn_OnClick()
	-- if ReportTypes == nil then
	-- 	ReportTypes = {
	-- 		{name=GetS(4743), serverparam='header'},
	-- 		{name=GetS(4744), serverparam='photo'},
	-- 	};
	-- 	for i = 1, 2 do
	-- 		getglobal("ReportFrameType"..i.."Txt"):SetText(ReportTypes[i].name);
	-- 	end
	-- end

	-- getglobal("ReportFrame"):Show();
	-- getglobal("ReportFrame"):SetClientID(ns_playercenter.op_uin);
	-- CurReportType = 1;
	-- ReportFrameUpdateTypeBtns();

	--LLDO:new
	SetReportOptionFrame("selfcenter", ns_playercenter.op_uin, ns_playercenter.NickName);
end

--LLDO:点击图片
function PlayerCenterPicBtn_OnClick(id)
	Log("PlayerCenterPicBtn_OnClick: id = " .. id);

	if not IsLookSelf() and ns_playercenter.photoFileList[id] then
		local btn = getglobal("PlayerCenterFrameSubPage1Photo" .. id .. "BtnReportBtn");
		if btn:IsShown() then btn:Hide(); else btn:Show(); end
	end
end

--举报图片
function PlayerCenterPicReportBtn_OnClick(id)
	if id then id = id; else id = this:GetParentFrame():GetClientID(); end

	this:Hide();
	PlayerCenterFrameSubPage1ReportBtn_OnClick();
end

--加QQ好友
local CanNotifyQQAuthorize = true;
function PlayerCenterFrameSubPage1AddQQFriendBtn_OnClick()
	local otherOpenid = getglobal("PlayerCenterFrameSubPage1AddQQFriendBtn"):GetClientString();
	if otherOpenid ~= "" then						--要加的人有了QQ的授权
		-- ShowLoadLoopFrame3(true,"auto");
        ShowLoadLoopFrame3(true, "file:playercenter -- func:PlayerCenterFrameSubPage1AddQQFriendBtn_OnClick")

		local index = 0;
		WaitQQLoginResult = 0;
		if not SdkManager:checkQQLogin() then	--没登录	
			for i=1, 10 do
				index = i;
				if WaitQQLoginResult > 0 then
					if WaitQQLoginResult == 1 then		--登录失败
						Log("kekeke QQLogin is fail");
						ShowGameTips(GetS(1170), 3);
						-- HideLoadLoopFrame3();
                        ShowLoadLoopFrame3(false)
						return;
					else
						break;
					end
				end
				threadpool:wait(0.5);
			end
		end

		Log("kekeke QQLogin success:"..index);
		WWW_ma_qq_member_action('nil', 'qq_member_add_friend', 1, ns_ma.func.download_callback_empty);

		local label = GetS(4767).."-"..ns_playercenter.NickName;
		local msg = GetS(4767).."-"..AccountManager:getNickName();
		SdkManager:addQQFriend(otherOpenid, label, msg);	

		-- HideLoadLoopFrame3();	
        ShowLoadLoopFrame3(false)
	else											--通知对方授权QQ
		if AccountManager.mobileqq_notify and CanNotifyQQAuthorize then
			local t_data = {
				uin = AccountManager:getUin(),
				nickName = AccountManager:getNickName(),
				type = "QQAuthorize",
				key = "QQAuthorize"..AccountManager:getUin(),
			}
			AccountManager:mobileqq_notify(ns_playercenter.op_uin, t_data);
			ShowGameTips(GetS(1147), 3);

			CanNotifyQQAuthorize = false;
			threadpool:work(function ()
				threadpool:wait(3);
				CanNotifyQQAuthorize = true;
			end)
		end
	end
end

function ReportFrameCloseBtn_OnClick()
	getglobal("ReportFrame"):Hide();
	getglobal("ReportFrame"):SetClientID(0);
end

function ReportFrameTypeBtn_OnClick()
	local index = this:GetClientID();
	CurReportType = index;
	ReportFrameUpdateTypeBtns();
end

function ReportFrameUpdateTypeBtns()
	for i = 1, 2 do
		if i == CurReportType then
			getglobal("ReportFrameType"..i.."Normal"):SetTextureTemplate("TexTemplate_hyxt_diban04");
			getglobal("ReportFrameType"..i.."PushedBG"):SetTextureTemplate("TexTemplate_hyxt_diban04");
			getglobal("ReportFrameType"..i.."Txt"):SetTextColor(254, 249, 209);
		else
			getglobal("ReportFrameType"..i.."Normal"):SetTextureTemplate("TexTemplate_hyxt_diban05");
			getglobal("ReportFrameType"..i.."PushedBG"):SetTextureTemplate("TexTemplate_hyxt_diban05");
			getglobal("ReportFrameType"..i.."Txt"):SetTextColor(149, 131, 95);
		end
	end
end

function ReportFrameSubmitBtn_OnClick()

	local uin = getglobal("ReportFrame"):GetClientID();

	local e = ReportTypes[CurReportType].serverparam;

	Log("req player_report "..uin..", "..e);

	local url = g_http_root_map .. 'miniw/profile?act=player_report'..
					'&op_uin='..uin..
					'&e='..e..
					'&'..http_getS1Map();
	url = url_addParams( url )
	Log("url = "..url);

	ShowLoadLoopFrame(true, "file:playercenter -- func:ReportFrameSubmitBtn_OnClick");
	ns_http.func.rpc_string_raw(url, function(retstr)
		ShowLoadLoopFrame(false)
		if string.find(retstr, 'ok') then
			ShowGameTips(GetS(4745), 3);
			getglobal("ReportFrame"):Hide();
			getglobal("ReportFrame"):SetClientID(0);
		else
			ShowGameTips(GetS(4729), 3);
		end
	end);
end

---------------------------------------------------------13岁保护模式---------------------------------------------------------
--玩家年龄判断, 是否大于13岁
function IsPlayerAgeMoreThen13()
	Log("IsPlayerAgeMoreThen13:");
	
	local test_uin = {204507528, };

	if test_uin and next(test_uin) then
		for i = 1, #test_uin do
			if test_uin[i] == GetMyUin() then
				--test_uin:都大于13岁
				print("is test uin:");
				return true;
			end
		end
	end

	--return true;
	if AccountManager.check_older_than_13 then
		Log("Have Func!!!");
		return AccountManager:check_older_than_13();
	else
		Log("Not Have Func!!!");
		return false;
	end

end

--是否处于保护模式
function IsProtectMode()
	--测试
	-- if true then
	-- 	return false;
	-- end

	--or ClientMgr:getApiId() == 999
	if (isAbroadEvn() or ClientMgr:getApiId() == 999 or IsAndroidBlockark()) and not IsPlayerAgeMoreThen13() then
		Log("IsProtectMode: In Protected Mode!!!");
		return true;
	else
		Log("IsProtectMode: Not In Protected Mode!!!");
		return false;
	end
end

--保护模式facebook按钮置灰
function ProtectModeFBBtnSetGray()
	if IsProtectMode() then
		getglobal("AccountLoginFrameFaceBookLoginBtnNormal"):SetGray(true);
		getglobal("AccountLoginFrameFaceBookLoginBtnPushedBG"):SetGray(true);
		getglobal("SecuritySettingContentBindingFaceBookBtnNormal"):SetGray(true);
		getglobal("SecuritySettingContentBindingFaceBookBtnPushedBG"):SetGray(true);
	else
		getglobal("AccountLoginFrameFaceBookLoginBtnNormal"):SetGray(false);
		getglobal("AccountLoginFrameFaceBookLoginBtnPushedBG"):SetGray(false);
		getglobal("SecuritySettingContentBindingFaceBookBtnNormal"):SetGray(false);
		getglobal("SecuritySettingContentBindingFaceBookBtnPushedBG"):SetGray(false);
	end
end

--保护模式聊天框默认提示
function ProtectModeChatFrameTip()
	if IsProtectMode() then
		getglobal("ChatInputBox"):SetDefaultText(GetS(20210));
	else
		getglobal("ChatInputBox"):SetDefaultText("");
	end
end

--[[
--LLDO:13岁保护模式特殊处理: 不让点击, 点击飘字
	if IsProtectMode() then
		ShowGameTips(GetS(20211), 3);
		return;
	end
]]


----------------------------------之前"FriendDynamicFrame_OnLoad"函数在playercenter_new.lua中会报为nil的错误, 而却还是偶现, 于是换个文件试试, 貌似不报错了, 暂未定位原因----------------------------------

function FriendDynamicFrame_OnLoad()
	CreateDynamicItemsByTemplate();
	
	LayoutFriendDynamic();
	LayoutZoneMyDynamic();
	LayoutZoneLatestDynamic();
end

--布局当前好友动态
function LayoutFriendDynamic()
	print("LayoutFriendDynamic:");
	--1. 信息: 头像, 名字, 发布内容

	--2. 点赞列表

	--3. 回复列表
	local num = 10;
	local y = 36;
	local singleH = 100;
	local planeUI = "FriendDynamicFrameReplyBoxPlane";
	local plane = getglobal(planeUI);

	for i = 1, 200 do
		local itemUI = "FriendDynamicFrameReplyBoxItem" .. i;

		if not HasUIFrame(itemUI) then break; end

		local item = getglobal(itemUI);

		item:Hide();
		item:SetPoint("top", planeUI, "top", 0, y);
		y = y + singleH;
	end

	y = math.max(y, 350);
	plane:SetHeight(y);
end

--"我的动态"布局
function LayoutZoneMyDynamic(id)
	print("LayoutZoneMyDynamic:");
	local num = 10;
	local y = 0;
	local singleH = 176;
	local planeUI = "MyDynamicBoxPlane";
	local plane = getglobal(planeUI);

	for i = 1, 200 do
		local itemUI = "MyDynamicBoxItem" .. i;

		if not HasUIFrame(itemUI) then break; end

		local item = getglobal(itemUI);

		item:Hide();
		item:SetPoint("top", planeUI, "top", 0, y);
		y = y + singleH;
	end

	y = math.max(y, 530);
	plane:SetHeight(y);
end

--最近回复布局
function LayoutZoneLatestDynamic()
	print("LayoutZoneLatestDynamic:");
	local num = 10;
	local y = 0;
	local singleH = 90;
	local boxUI = "LatestDynamicBox"
	local planeUI = boxUI .. "Plane";
	local plane = getglobal(planeUI);

	for i = 1, 200 do
		local itemUI = boxUI .. "Item" .. i;

		if not HasUIFrame(itemUI) then break; end

		local item = getglobal(itemUI);

		Hide:Hide();
		item:SetPoint("top", planeUI, "top", 0, y);
		y = y + singleH;
	end

	y = math.max(y, 530);
	plane:SetHeight(y);
end
