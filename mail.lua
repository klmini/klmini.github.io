
-- 改成全局变量，方便其他地方统一调用
mailservice = {
	mails = {},
	mailsSystem = {},
	mailsFriend = {},

	pullingMails = false,
	isOneKeyTakeMail = false, 	-- 是否一件领取
	isOneKeyDelMail = false, 	-- 是否一件删除

	MAIL_TYPE = { -- 对应消息中心的channel id
		MAIL_SYSTEM = 1, --系统
		MAIL_FRIEND = 2, --好友
	},

	MAIL_CONTENT_REWARD_ITEM_MAX_NUM = 14, -- 邮件最大奖励数量

	curMailIndex = 0,-- 默认选择第一封
	curSelMailType = 1, -- 默认是系统邮件

	desc = {}, -- 邮件描述文件key 邮件ID， value = {标题，来源，内容}

	USE_DEBUG_DATA = false, -- 使用本地调试数据，谨慎使用
	WRITE_PATH_FORMAT = "G:/miniw/mailData/%s",

	MAX_REWARD_NUM = 6,
};

--------------------------------------- mail http ------------------------------------------------

function ResetMailData()
	mailservice.mails = {};
	mailservice.mailsSystem = {};
	mailservice.mailsFriend = {};
end
-- 默认只做url和json解码
DecodeMailData = function(strEncode, isBase64)
	local content = ns_http.func.url_decode(strEncode)

	if not content or content == "" then
		return {}
	end

	if isBase64 then
		content = ns_http.func.base64_decode(content)
	end
	
	local data = JSON:decode(content)

	return data
end

local function CreateMailRequest(_server, _path)
	local builder = {
		server = _server,
		path = _path,
		url = _server.._path,
		authparams = "",
	};

	builder.__index = builder;

	builder.addparam = function(self, name, value, url_escape)

		if #self.authparams > 0 then
			self.url = self.url.."&";
			self.authparams = self.authparams.."&";
		else
			self.url = self.url.."?";
		end

		if url_escape then
			self.url = self.url..name.."="..gFunc_urlEscape(value);
		else
			self.url = self.url..name.."="..value;
		end

		self.authparams = self.authparams..name.."="..value;

		return self;
	end

	builder.finish = function(self)
		local md5 = gFunc_getmd5(self.authparams.."f5711eb1640712de051e5aedc35329c3");
		self.url = self.url.."&auth="..md5;
		return self.url;
	end

	builder.finishwithoutauth = function(self)
		return self.url;
	end
	return builder;
end

local function GetMailMobileOS()
	local mobile_os = -1;
	if ClientMgr:isPC() then
		mobile_os = 3;
	elseif ClientMgr:isAndroid() then
		mobile_os = 1;
	elseif ClientMgr:isApple() then
		mobile_os = 2;
	end

	return mobile_os
end

local function GetMailCreatorFlag()
	SynloadDeveloperInfo()
    local CreateLevel = getCreateLevel()
	local uin = tonumber(AccountManager:getUin())
    if CreateLevel ~=-1 and uin then
        return "&creator="..((CreateLevel+365) * uin)
    end

	return nil
end

function ReqGetMailList(mailType) -- 废弃的接口，只是暂时保留防止，以后由消息中心统一拉取
	-- 更新邮件列表
	-- DO NOTHING
	GetInst('MessageCenterDataMgr'):RequestChannelHistoryMsgIDList((GetSelectMailType()), getServerTime())
end

function TransferMsgToMailDataList()
	ResetMailData()

	local msgList = GetInst('MessageCenterDataMgr'):GetChannelMsgData(GetSelectMailType())
	if not msgList or not msgList.msg_ids then
		return
	end

	for msgID, msgData in pairs(msgList.msg_ids) do
		if msgData.detail then
			local mail = CreateNewMailData(msgData.detail)
			table.insert(mailservice.mails, mail)
		end
	end
end

-- 老邮件解析
function CreateMailData(src)
	local mail = {
		id 			= src.id or -1,
		title 		= src.title or "",
		content 	= src.body or "",
		create_time = src.send_time or 0,
		end_time 	= src.end_time or 0,
		have_read 	= false,  --服务器发过来的都是没读过的
		have_taken 	= false,  --肯定也没有领取过
		items 		= {},
		jump_to 	= src.jump_to or nil,
		isImportant = (src.important == 1),   --是否为重要邮件
		type 		= src.type or 0, --邮件类型
		sender 		= src.sender or "", --发件人昵称(迷你号)
		image 		= src.image or nil, --图片链接
		image_jump_to = src.image_jump_to or nil,--发件人昵称(迷你号)
		from 		= src.from or nil, --发送类型
		unique_id 	= src.unique_id or -1,--邮件ID
		jump_name 	= src.jump_name or "", --按钮文字
		ctx 		= src.ctx or "", --索取邮件透传
		extraImages = JSON:decode(src.extraImages or ""),  --举报地图广告图片
	};

	ParseMailMultiLangContent(mail, src.loadstringId) -- 多语言
	ParseMailAttachs(mail, src.attach) -- 附件
	ParseVerifyCode(mail) -- 验证码

	return mail;
end

function CreateNewMailData(src)
	local mail = {
		id 			= src.id or -1,
		title 		= src.title or "",
		content 	= src.content or "",
		create_time = src.createtime or 0,
		recv 		= src.recv, -- 接收方
		have_read 	= (src.status == 1 or src.status == 3),  -- status 1 已读， status 2 已领取， status 3 已读已领取
        have_taken 	= (src.status == 2 or src.status == 3),  --肯定也没有领取过
		items 		= {},
		isImportant = (src.important == 1),	--是否为重要邮件
		channel		= src.channel, 		-- 邮件大类 ，1 是系统，2是好友
	};

	if src.extra then
		mail.end_time 	= src.expiretime or src.extra.end_time or 0
		mail.ctx 		= src.extra.ctx or ""	-- 索取邮件透传
		mail.from 		= src.extra.from		-- 来源
		mail.type 		= tonumber(src.extra.type) or 0 		--邮件类型
		mail.unique_id	= src.extra.unique_id
		mail.sender		= src.extra.sender

		-- 跳转信息
		if src.extra.jump then
			local jumpInfo	= src.extra.jump
			mail.image		= jumpInfo.image 
			mail.jump_name	= jumpInfo.jump_name
			mail.jump_to	= jumpInfo.jump_to
			mail.jump_type	= jumpInfo.jump_type
			mail.image_jump_to		= jumpInfo.image_jump_to
			mail.image_jump_type	= jumpInfo.image_jump_type
			mail.images = jumpInfo.images
		end
		
		mail.extraImages = JSON:decode(src.extra.extraImages or ""),  --举报地图广告图片

		ParseMailMultiLangContent(mail, src.extra.loadstringId) -- 多语言
		ParseMailAttachs(mail, src.extra.attach) -- 附件
		ParseVerifyCode(mail) -- 验证码
	end

	print("create new data:", mail)

	return mail;
end

-- 解析邮件多语言内容
function ParseMailMultiLangContent(mail, loadstringId)
	if not loadstringId then
		return
	end

	local stringIds = StringSplit(loadstringId, ",");
	if  stringIds and type(stringIds) == 'table' and #(stringIds) >= 2 then
		mail.title = GetS(tonumber(stringIds[1]));

		if  #(stringIds) > 2 then
			local left_ = {}
			for m=3, #stringIds do
				if  string.sub(stringIds[m], 1, 5) == 'GetS_' then
					--参数也需要转换多语言文字
					left_[ #left_+1 ] = GetS( string.sub(stringIds[m], 6, -1) )
				else
					left_[ #left_+1 ] = stringIds[m]
				end
			end
			Log("mail content1")

			local org_str_ = GetS( tonumber(stringIds[2]) )
			if  string.find( org_str_, "@1" ) then
				mail.content = GetS ( tonumber(stringIds[2]), unpack(left_) )   --使用@1 @2来替换
			else
				mail.content = string.format( org_str_, unpack(left_) )	        --使用%d %s来替换
			end
		else
			Log("mail content2")
			mail.content = GetS( tonumber(stringIds[2]) );
		end

	end
end

-- 解析邮件附件
function ParseMailAttachs(mail, attach)
	if not attach then
		return
	end

	for j = 1, #attach do
		local itemsrc = attach[j];
		if itemsrc.num > 0 and itemsrc.id > 0 then
			table.insert(mail.items, {
				id = itemsrc.id, 
				count = itemsrc.num});
		end
	end
end

-- 解析验证码
function ParseVerifyCode(mail)
	if mail.ctx == "" then
		return
	end

	local url_decode_ctxStr = ns_http.func.url_decode(mail.ctx)
	local ctxData = JSON:decode(url_decode_ctxStr)
	if ctxData and ctxData.verify_code then
		mail.verify_code = ctxData.verify_code
	end
end

--设置邮件已读
function SetMailReaded(mail)
	if mailservice.USE_DEBUG_DATA or (not mail) or not CheckUinLogin() then
		return
	end

	-- 已读邮件无需更新服务器状态
	if CheckSendMailReaded(mail) then
		return
	end

	mail.have_read = true;

	GetInst("MessageCenterDataMgr"):SetChannelMsgRead(mail.channel, mail.id) -- 本地已读状态更新
	GetInst('MessageCenterDataMgr'):RequestMailRead(mail.channel, {mail.id}, RespSetMailReaded) -- 告知服务器
end

function RespSetMailReaded(ret)
	if not ret or ret.ret ~= 0 then
		return
	end

	--ShowGameTips("设置服务器已读成功")
end

--删除邮件
function DeleteMail(index)
	Log("DeleteMail index="..index);

	local mail = GetMailIndex(index)--mailservice.mails[index];
	if not mail then
		Log("mail not exist:index="..index);
		return
	end

	if mail.items and (#mail.items > 0) and (not mail.have_taken) then
		ShowGameTipsWithoutFilter(GetS(21004), 3);
		return
	end
	--如果邮件中缓存图片数据，则清空图片
	if mail.id and mail.image then
		local szFilepath  = g_download_root .. "mailImage_" .. mail.id .. trimUrlFile(mail.image) .. "_"
		if gFunc_isFileExist(szFilepath) then
			gFunc_deleteStdioFile(szFilepath)
		end
	end
	--删除举报地图缓存
	if mail.id and mail.extraImages ~= nil then
		for i,v in ipairs(mail.extraImages) do
			local image = v
			local szFilepath  = g_download_root .. "mailImage_" .. mail.id .. trimUrlFile(image) .. "_"
			if gFunc_isFileExist(szFilepath) then
				gFunc_deleteStdioFile(szFilepath)
			end
		end
	end

	--索取皮肤邮件,删除对应的邮件id
	GetInst("ShopService"):RemoveWantGiftMailID(mail.id)

	MailFrameSendStatistics(mail,4)
	Log("mail.id="..mail.id);
	--table.remove(mailservice.mails, index);
	for k,v in pairs(mailservice.mails) do
		if v.id == mail.id then
			table.remove(mailservice.mails, k);
			break
		end
	end

	-- 重新分类
	ClassifyMailList()

	--delete from server
	if not mail.have_read then
		SetMailReaded(mail);
	end

	-- 邮件删除
	GetInst('MessageCenterDataMgr'):RequestChannelMsgDelete(mail.channel, {mail.id}, nil, function(ret)
		--[[
			30	消息卡(第2版消息中心）	MAIL_CONTENT_2	删除按钮（官方邮件、好友邮件）	Delete	点击	click	按钮被点击 
			#standby1：一级页签名，根据配置返回字段显示 
			#standby2：二级页签名，根据配置返回字段显示（无）
			#standby3：三级页签名，根据配置返回字段显示（无）
			#standby4：邮件标题
			#standby5：邮件ID
			#standby6：返回结果，1-成功，0-失败
			#standby7：领取方式，1-一键删除，0-单个删除
		-- ]]
		local errCode = nil
		local str = ""
		if ret then
			if ret.ret == ErrorCode.OK then
				str = "success"
			else
				errCode = ret.result
				str = "failed"
			end
		end
		GetInst("MessageCenterDataMgr"):ReportEvent('MAIL_CONTENT_2', 'Delete', str, {
				standby1 = GetInst('MessageCenterDataMgr'):GetTabTitle(GetSelectMailType()),
				standby2 = nil,
				standby3 = nil,
				standby4 = GetMailTitle(mail),
				standby5 = mail.id,
				standby6 = nil,
				standby7 =  mailservice.isOneKeyDelMail and 1 or 0,
				standby8 = errCode,
		})


		if not ret or ret.ret ~= 0 then
			--ShowGameTips("RequestChannelMsgDelete not ret or ret ~= 0")
			return
		end

		-- 更新邮件列表
		SandboxLua.eventDispatcher:Emit(nil, "MessageCenter_Mail_OnUpdateMailList",  SandboxContext())

		
	end)
	SandboxLua.eventDispatcher:Emit(nil, "MessageCenter_Msg_Delete",  SandboxContext()) -- 先从内存删除，刷新UI，不用等结果返回再刷新
	
	--[[
		30	消息卡(第2版消息中心）	MAIL_CONTENT_2	删除按钮（官方邮件、好友邮件）	Delete	点击	click	按钮被点击 
		#standby1：一级页签名，根据配置返回字段显示 
		#standby2：二级页签名，根据配置返回字段显示（无）
		#standby3：三级页签名，根据配置返回字段显示（无）
		#standby4：邮件标题
		#standby5：邮件ID
		#standby6：返回结果，1-成功，0-失败
		#standby7：领取方式，1-一键删除，0-单个删除
	-- ]]
	GetInst("MessageCenterDataMgr"):ReportEvent('MAIL_CONTENT_2', 'Delete', 'click', {
			standby1 = GetInst('MessageCenterDataMgr'):GetTabTitle(GetSelectMailType()),
			standby2 = nil,
			standby3 = nil,
			standby4 = GetMailTitle(mail),
			standby5 = mail.id,
			standby6 = nil,
			standby7 = mailservice.isOneKeyDelMail and 1 or 0,
	})
	
	MailCommentViewStandReport(mail, "Delete", "click", true);
end

--领取邮件物品
function TakeMailItems(mail)
	Log("TakeMailItems id="..mail.id);
	if (#mail.items > 0) and (not mail.have_taken) then
		--判断是赠送的会员邮件
		local rewardList={};
		for i = 1, mailservice.MAX_REWARD_NUM do
			if i <= #mail.items and _G.check_use_new_server() then
				local itemDef = ItemDefCsv:get(mail.items[i].id);
				if itemDef then
					table.insert(rewardList,itemDef.ID);
				end
			end
		end
		if AccountManager.itemlist_can_add and not AccountManager:itemlist_can_add(rewardList) then
			print("仓库已满")
			mailservice.isOneKeyTakeMail = false
			StashIsFullTips();
			return;
		end

		GetInst("MessageCenterDataMgr"):ReportEvent('MAIL_CONTENT_2', 'Receive', "click", {
			standby1 = GetInst('MessageCenterDataMgr'):GetTabTitle(GetSelectMailType()),
			standby2 = nil,
			standby3 = nil,
			standby4 = GenerateUBBStr_old( GetMailTitle(mail) ),
			standby5 = mail.id,
			standby6 = nil,
			-- standby7 = mailservice.isOneKeyTakeMail and 1 or 0,
			-- standby8 = nil,
		})

		GetInst("MessageCenterDataMgr"):RequestMailAttachments(GetSelectMailType(),{mail.id},  function(ret)
			--WriteDataToDisk(string.format(mailservice.WRITE_PATH_FORMAT, "mail_take.lua"), ret)
			print("lwtaoP RequestMailAttachments ",ret)
			if ret and ret.ret == ErrorCode.OK then
				mail.have_taken = true;
				
				local idInfos = ret.data[mail.id]
				if not idInfos then
					return
				end

				GetInst('MessageCenterDataMgr'):SetMailTakeState(GetSelectMailType(), mail.id, 3)
				local list = {}
				for i=1, #idInfos do
					list[#list + 1] = idInfos[i]
				end

				if #list > 0 then
					local total_reward_items = {};
					for i = 1, #list do
						local item = list[i];
						table.insert(total_reward_items, {id=item.id, num=item.num});
						UpdateActivityRewardListByItemid(item.id)
					end

					--SetGameRewardFrameInfo(GetS(4090), total_reward_items, "");
					local rewardMgr = GetInst("RewardMgr")
					if rewardMgr then
						local rewardList = {}
						rewardList.title = GetS(4090)
						rewardList.data = total_reward_items
						rewardMgr:PushReward(rewardList, rewardMgr:GetDataTypeEnum().mail_items)
					end
					--[[
					30	消息卡(第2版消息中心）	MAIL_CONTENT_2	领取按钮	Receive	点击	success/failed	按钮被点击		"
						#standby1：一级页签名，根据配置返回字段显示 
						#standby2：二级页签名，根据配置返回字段显示  
						#standby3：三级页签名，根据配置返回字段显示
						#standby4：邮件标题
						#standby5：邮件ID
						#standby6：跳转按钮名，根据配置返回字段
						#standby7：消息模板ID"
					]] 
					GetInst("MessageCenterDataMgr"):ReportEvent('MAIL_CONTENT_2', 'Receive', "success", {
						standby1 = GetInst('MessageCenterDataMgr'):GetTabTitle(GetSelectMailType()),
						standby2 = nil,
						standby3 = nil,
						standby4 = GenerateUBBStr_old( GetMailTitle(mail) ),
						standby5 = mail.id,
						standby6 = nil,
						-- standby7 = mailservice.isOneKeyTakeMail and 1 or 0,
						-- standby8 = nil,
					})
				end

				SandboxLua.eventDispatcher:Emit(nil, "MessageCenter_MailDetail_Refresh",  SandboxContext())
				SandboxLua.eventDispatcher:Emit(nil, "MessageCenter_Mail_OnTakeMailItems",  SandboxContext())
			else
				ShowGameTipsWithoutFilter("err msg:" ..  (ret and ret.ret) or "no return data")
				
				--[[
				30	消息卡(第2版消息中心）	MAIL_CONTENT_2	领取按钮	Receive	点击	success/failed	按钮被点击		"
					#standby1：一级页签名，根据配置返回字段显示 
					#standby2：二级页签名，根据配置返回字段显示  
					#standby3：三级页签名，根据配置返回字段显示
					#standby4：邮件标题
					#standby5：邮件ID
					#standby6：跳转按钮名，根据配置返回字段
					#standby7：消息模板ID"
				]] 
				GetInst("MessageCenterDataMgr"):ReportEvent('MAIL_CONTENT_2', 'Receive', "failed", {
						standby1 = GetInst('MessageCenterDataMgr'):GetTabTitle(GetSelectMailType()),
						standby2 = nil,
						standby3 = nil,
						standby4 = GenerateUBBStr_old( GetMailTitle(mail) ),
						standby5 = mail.id,
						standby6 = nil,
						-- standby7 = mailservice.isOneKeyTakeMail and 1 or 0,
						standby7 = ret.ret,
					})
			end
		end)
	end
end

--邮件跳转的函数
local JumpToFucntion = {
	-- [1] 跳转ID
	--商城-坐骑
	[1] = function()
		ShopJumpTabView(4)
	end,
	--商城-装扮
	[2] = function()
		ShopJumpTabView(2)
	end,
	--商城-角色
	[3] = function()
		if GetInst("GeniusMgr"):IsOpenGeniusSys() then
			--如果开启了特长系统
			ShopJumpTabView(2)
		else
			ShopJumpTabView(5)
		end
	end,
	--商城-道具
	[4] = function()
		ShopJumpTabView(6)
	end,
	--商城-[Desc2]
	[5] = function()
		ShopJumpTabView(7)
	end,
	--家园
	[6] = function()
		-- MiniLobbyFrameCenterHomeChest_OnClick()
		JumpToHomeChest()--mark by hfb for new minilobby 不要埋点
	end,
	--奖励-登录
	[7] = function()
		GongNengFrameActivityGNBtn_OnClick()
		OpenActivityFrame()
		ActivitBtnFunc("LoginReward")
	end,
	--奖励-分享
	[8] = function()
		GongNengFrameActivityGNBtn_OnClick()
		OpenActivityFrame()
		ActivitBtnFunc("GetMiniBeanReward")
	end,
	--奖励-礼包
	[9] = function()
		GongNengFrameActivityGNBtn_OnClick()
		OpenActivityFrame()
		ActivitBtnFunc("ActivationCodeReward")
	end,
	--工坊首页
	[10] = function()
		-- MiniLobbyFrameCenterMiniWorks_OnClick()
		JumpToMiniWorks()--mark by hfb for new minilobby 不要埋点
		MiniworksGotoLabel(7)
	end,
	--多人联机-wifi
	[11] = function()
		-- MiniLobbyFrameCenterMultiplayer_OnClick()
		JumpToMultiplayer()--mark by hfb for new minilobby 不要埋点
		-- MultiplayerLobbyFrameRoom()
	end,
	--好友
	[12] = function()
		-- MiniLobbyFrameBottomBuddy_OnClick()
		JumpToChat()
		InteractiveBtn_OnClick();--mark by hfb for new minilobby 不要埋点
	end,
	--提交建议
	[13] = function()
		getglobal("FeedBackFrame"):Show()
	end,
	--个人信息
	[14] = function()
		-- MiniLobbyFramePlayerCenter_OnClick()
		JumpToPlayerCenter()--mark by hfb for new minilobby 不要埋点
	end,
	--鉴赏家测试题
	[19] = function()
		if getExpert().stat == 2 then
			ShowGameTipsWithoutFilter(GetS(1280), 3)
			return
		else
			OpenQuestionnaireFrame("connoisseur", 20)
		end
	end,
	--扭蛋
	[20] = function()
		ShopJumpTabView(10)
	end,
	--商城装扮
	[26] = function()
		ShopJumpTabView(2)
	end,
	[48] = function ()
		GongNengFrameActivityGNBtn_OnClick();
		OpenActivityFrame();
		ActivitBtnFunc("WeekendGift", false, { showInActivityFrame = true, from="mail"});
	end,
	--工作室同意邀请 0=拒绝，1=接受
	[460] = function(workSpaceId, accept)
		if GetInst("WorkSpaceDataManager") then
            GetInst("WorkSpaceDataManager"):ReqConfirmInvite(tonumber(workSpaceId), accept)
        end
	end,
	[463] = function(accept)
		if accept == 0 then
			GetInst("WorkSpaceDataManager"):ReqConfirmVipInvite(accept)
		else
			GetInst("WorkSpaceDataManager"):gotoWebCheckVipInvite()
		end
	end,
}

--从邮件界面跳转到家园、道具等界面
--type 0 默认按钮跳转， 1 图片跳转
function DoMailJump(mail,junmptype)
	--新版 跳转： 1,游戏内某个界面 id  2,游戏外网页 url  3，社区内帖子 post_id=1231231
	--旧版 游戏内某个界面跳转,直接添加id
	local jump_to
	local community = 0
	if junmptype == 0 then
		jump_to = mail.jump_to
	elseif junmptype == 1 then
		jump_to = mail.image_jump_to
	end

	if jump_to == "" then
		return
	end
	
 	if  type(jump_to) == 'string' then
		if  #jump_to < 8 then   --'http://'
			local j_ = tonumber(jump_to)
			if  j_ and j_ > 0 then
				jump_to = j_
			end
		end
	end
	if type(jump_to) == "number" then  --跳转到游戏界面
		if mail and mail.unique_id then --根据unique_id判断,新的流程走全局跳转
			if jump_to == 19 then --鉴赏家特殊处理
				if JumpToFucntion[jump_to] then
					JumpToFucntion[jump_to]()
				end
			elseif jump_to == 460 then --工作室邀请
				if JumpToFucntion[jump_to] then
					JumpToFucntion[jump_to](mail.jump_name, 1)
				end
			elseif jump_to == 463 then
				JumpToFucntion[jump_to]()
			elseif jump_to == 48 then
				JumpToFucntion[jump_to]()
			elseif jump_to == 466 then
				global_jump_ui(462)
			elseif jump_to == 467 then
				WWW_file_map_homepage()
				global_jump_ui(jump_to)
			else
				global_jump_ui(jump_to)
			end
			MailFrameSendStatistics(mail,(junmptype == 1) and 6 or 5,jump_to)
		else --旧版邮件
			if JumpToFucntion[jump_to] then
				JumpToFucntion[jump_to]()
			end
		end

		GetInst("MiniUIManager"):CloseUI("MessageCenterAutoGen", true)
	elseif type(jump_to) == "string" then
		if string.find(jump_to, 'http') then
			global_jump_ui(99,jump_to)
		elseif string.find(jump_to, "comment") then
			if isEnableNewCommonSystem and isEnableNewCommonSystem() then
				GetInst("CommentSystemInterface"):MailJump(jump_to);
			end
		else --社区 post_id=123313
			community = 23
			global_jump_ui(23,jump_to)
		end
		if mail and mail.unique_id then --根据unique_id判断,新的流程走全局跳转
			if community == 23 then
				MailFrameSendStatistics(mail,(junmptype == 1) and 6 or 5,23)
			else
				MailFrameSendStatistics(mail,(junmptype == 1) and 6 or 5,99)
			end
		end
	end

	-- GetInst("MiniUIManager"):CloseUI("MessageCenterAutoGen", true)
end

--跳转按钮埋点
function MailJumpStandReport(maildata,sid, eventCode, needExtra, btnGoText)
	maildata = maildata or GetCurMail();
	if not maildata then
		return;
	end

	--[[
		"standby1:按钮文案
		standby2：1-游戏内位置 2.游戏外网页
		standby3  邮件ID
		button_state 邮件名"
	--]]
	local id = maildata.unique_id --邮件ID
	local name = maildata.title --邮件名称
	local jump_to = maildata.jump_to
	local jumpType = 1 --1-游戏内位置 2.游戏外网页
	if type(jump_to) == "string" then 
		jumpType = 2
	end
	
	standReportEvent(30, "MAIL_CONTENT", sid, eventCode, {standby1 = btnGoText, standby2 = jumpType, standby3 = id, button_state = name})
end

function RemoveOverdueMail()
	local curtime = os.time();
	print("kekeke RemoveOverdueMail", curtime, mailservice.mails);
	for i = #(mailservice.mails), 1, -1  do
		if mailservice.mails[i].end_time > 0 and curtime > mailservice.mails[i].end_time then
			table.remove(mailservice.mails, i);
		end
	end
end

function SetCurMailIdx(idx)
	mailservice.curMailIndex = idx or 1
end

function GetCurMailIdx()
	return mailservice.curMailIndex
end

function GetCurMailList()
	local selectType = GetSelectMailType()
	if selectType == mailservice.MAIL_TYPE.MAIL_SYSTEM then
		return mailservice.mailsSystem
	else
		return mailservice.mailsFriend
	end
end

--从邮件界面跳转到反馈界面
function DoMailFeedBackJump(jsonData)
	if jsonData and type(jsonData) == "table" then
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/feedback"})
		GetInst("MiniUIManager"):OpenUI("feedback","miniui/miniworld/feedback","feedbackAutoGen", {map_id=jsonData.map_id,seq=jsonData.seq})
	end
end

--当前是否处于一键领取的状态中
mailservice.isOneKeyTakeMail = false
function MailTemplateDeleteBtn_OnClick()
	local index = GetCurMailIdx()
	local curMail = GetCurMail()

	if curMail.isImportant then
		--如果是重要邮件，进行二次确认
		MessageBox(5, GetS(4035), function(btn)
			if btn == 'left' then
				DeleteMail(index)
			end
		end);
		getglobal("MessageBoxFrame"):SetClientUserData(0, index);
		getglobal("MessageBoxFrame"):SetClientString("删除邮件");
	else
		--否则直接删除
		DeleteMail(index)
		ShowGameTipsWithoutFilter(GetS(3992),3)
	end
end
--设置图片
function MailDownloadIconPng(url,id, callfunc)
	local tmpPath  = g_download_root .. "mailImage_" .. id .. trimUrlFile(url) .. ".tmp"
	local szFilepath  = g_download_root .. "mailImage_" .. id .. trimUrlFile(url) .. "_"

	if gFunc_isFileExist(tmpPath) then
		gFunc_deleteStdioFile(tmpPath)
	end

	if not gFunc_isFileExist(szFilepath) then
		ns_http.func.downloadPng(url, tmpPath, nil, nil, function()
			gFunc_renameStdioPath(tmpPath, szFilepath)
			callfunc(szFilepath)
		end)
		else
		callfunc(szFilepath)
	end
end

--一键领取
function MailFrameMailOneKeyTakeBtn_OnClick()
	if not mailservice.isOneKeyTakeMail then
		print("点击了按钮一键领取所有附件")
		MessageBox(5, GetS(21213))
		getglobal("MessageBoxFrame"):SetClientString("一键领取所有附件")
	end
end

--一键领取所有附件确认回调
function MailFrameMailOneKeyTakeBtn_OnClickCallback()
	print("一键领取所有附件确认回调")
	mailservice.isOneKeyTakeMail = true
	MailFrameMailOneKeyTakeContinue()
end

--继续领取附件
function MailFrameMailOneKeyTakeContinue()
	print("继续领取附件1")
	local mails = GetMailList()
	local excuteMail = nil
	local index = nil
	for i = 1,#mails do
		local aMail = mails[i]
		-- 一键领取的时候加个已读操作
		if not aMail.have_read then
			SetMailReaded(aMail)
		end
		if aMail.items and #aMail.items > 0 and not aMail.have_taken then
			--某邮件有附件可领
			excuteMail = aMail
			index = i
			break
		end
	end
	if excuteMail then
		MailFrameSendStatistics(excuteMail,7)

		local id = excuteMail.unique_id --邮件ID
		local name = excuteMail.title --邮件名称
		
		if GetSelectMailType() == mailservice.MAIL_TYPE.MAIL_SYSTEM then
			MailAllReceiveStandReport(excuteMail, "MAIL_OFFICIALl_CONTENT","AllReceive", "click");
		else
			MailAllReceiveStandReport(excuteMail, "MAIL_FRIEND_CONTENT", "AllReceive", "click");
		end

		print("继续领取附件2")
		TakeMailItems(excuteMail)
	else
		print("停止领取附件")
		--停止领取
		mailservice.isOneKeyTakeMail = false
		-- 刷新大厅icon红点
		UpdateMiniLobbyFrameMailRedTag();
	end
end

--一键领取上报
function MailAllReceiveStandReport(maildata, cid, sid, eventCode)
	maildata = maildata or GetCurMail();
	if not maildata then
		return;
	end

--[["standby1:1.邀请评价 2.点赞推送 3.作者新评论 4.热评地图  5.圈消息推送 6.用户新评论 7.普通邮件8.赠送物品邮件 9.被索要皮肤邮件 10.微信/[Desc1]宝分享皮肤邮件 11.赠送武器皮肤邮件 12.审核邮件 13.工作室邮件
standby2:1.发邮件到客户端打开邮件时差
standby3  邮件ID
button_state 邮件名"--]]

	local id = maildata.unique_id --邮件ID
	local name = maildata.title --邮件名称
	local mailType = tonumber(maildata.type) or 0;
	local numJump = tonumber(maildata.jump_to)
	if type(numJump) == 'number' and (numJump >= 460 and numJump <= 466) then --工作室给个约定类型 20
		mailType = g_enum_comm.email_comm_type.workSpace or 20
	end

	local ct = getServerTime() - maildata.create_time
	standReportEvent(30, cid, sid, eventCode, {standby1 = mailType, button_state = name,standby2 = ct,standby3 = id})
end

--删除已读
function MailFrameMailOneKeyDeleteBtn_OnClick()
	local isNeedDelete = false

	local mails = GetMailList()
	for i = 1,#mails do
		if CheckSendMailReaded(mails[i]) then -- 判断是否已读且领取
			isNeedDelete = true
			break
		end
	end

	if isNeedDelete then
		print("点击了删除已读邮件")
		MessageBox(5, GetS(181013),function(btn)
			local selectType = GetSelectMailType()

			if btn == 'right' then
				if selectType == mailservice.MAIL_TYPE.MAIL_SYSTEM then--官方邮件
					standReportEvent(30, "MAIL_OFFICIALl_CONTENT","DeleteInterface","click",{
						standby1 = 2
					})
				else
					standReportEvent(30, "MAIL_FRIEND_CONTENT","DeleteInterface","click",{
						standby1 = 2
					})
				end
			elseif btn == "left" then --确认
				MailFrameMailOneKeyDeleteBtn_OnClickCallback()
				if selectType == mailservice.MAIL_TYPE.MAIL_SYSTEM then--官方邮件
					standReportEvent(30, "MAIL_OFFICIALl_CONTENT","DeleteInterface","click",{
						standby1 = 1
					})
				else
					standReportEvent(30, "MAIL_FRIEND_CONTENT","DeleteInterface","click",{
						standby1 = 1
					})
				end
 			end
		end)
	else
		ShowGameTipsWithoutFilter(GetS(181014),3)
	end

	if selectType == mailservice.MAIL_TYPE.MAIL_SYSTEM then--官方邮件
		standReportEvent(30, "MAIL_OFFICIALl_CONTENT","DeleteHasRead","click")
	else
		standReportEvent(30, "MAIL_FRIEND_CONTENT","DeleteHasRead","click")
	end
end

--删除已读邮件确认回调
function MailFrameMailOneKeyDeleteBtn_OnClickCallback()
	print("删除已读邮件确认回调")
	MailFrameMailOneKeyDeleteContinue()
end

--删除已读邮件
function MailFrameMailOneKeyDeleteContinue()
	print("继续领取附件1")
	mailservice.isOneKeyDelMail = true
	local mails = GetMailList()
	for i = #mails,1,-1 do
		if CheckSendMailReaded(mails[i]) then -- 判断是否已读切领取
			DeleteMail(i)
		end
	end
	ShowGameTipsWithoutFilter(GetS(3992),3)
end

-- 获取礼物名称
function GetMailDataGiftName(jsonData)
	-- body
	if jsonData.giftType == g_enum_comm.FriendGiftType.SPRAY_PAINT then
		local ID = jsonData.items[1].id
		local itemDef = ItemDefCsv:get(ID)
		if itemDef then
			return itemDef.Name
		end
		return ""
	end
	if jsonData.giftType == g_enum_comm.FriendGiftType.WEAPON_SKIN then
		local skinID = ItemUseSkinDefTools:getSkinIDByItemID(jsonData.items[1].id)
		local weaponDef = GetInst("ShopDataManager"):FindCurrentWeaponDef(skinID)
		if weaponDef then
			return weaponDef.Name
		end
		return ""
	end
	if jsonData.giftType == g_enum_comm.FriendGiftType.CUSTOM_SKIN then
		local partModleList = {}
		for i, v in ipairs(jsonData.items) do
			local avatarModelID = ItemUseSkinDefTools:getAvatarModelIDByItemID(v.id)
			if avatarModelID then
				table.insert(partModleList, avatarModelID)
			end
		end
		local strs = {}
		for k, v in pairs(partModleList) do
			local modelDef = GetInst("ShopDataManager"):GetSkinPartDefById(v)
			local id = tonumber(modelDef.AstringID)
			local itemdef = ItemDefCsv:get(id) or {}
			local name = itemdef.Name
			local str = GetS(30321, 1, name or "")
			table.insert(strs, str)
		end
		if #strs > 0 then
			return table.concat(strs, ",")
		end
		return ""
	end
	if jsonData.giftType == g_enum_comm.FriendGiftType.ITEM_SPEC or
	jsonData.giftType == g_enum_comm.FriendGiftType.ITEM_SHOP then
		local itemid = jsonData.items[1].id
		local num = jsonData.items[1].num
		local itemDef = ItemDefCsv:get(itemid)
		if itemDef then
			local str = GetS(30321, num, itemDef.Name)
			return str
		end
		return ""
	end
	return ""
end

function MailCheckboxIsSelect()
	local ret = false

	local resultObj = SandboxLua.eventDispatcher:Emit(nil, "MessageCenter_Mail_IsCheckboxSelected",  SandboxContext() )
	if resultObj:IsExecSuccessed() then
		ret = resultObj:GetData_Bool("isSelected")
	end
	
	return ret and 1 or 0
end

--领取物品
function MailFrameMailContTakeBtn_OnClick()
	--根据当前邮件状态（已领取，未领取）来判断该按钮执行什么功能，如果已领取，则变成删除；如果未领取，则变成领取
	local maildata = GetCurMail()
	if maildata and maildata.type and (g_enum_comm.email_comm_type.wantgift == tonumber(maildata.type) 
	or g_enum_comm.email_comm_type.vipcard_demand == tonumber(maildata.type)
	or g_enum_comm.email_comm_type.demandItem == tonumber(maildata.type)) then
		if GetInst("ShopService"):FindWantGiftMailID(maildata.id) then --已领取
			mailservice.isOneKeyDelMail = false
			DeleteMail(GetCurMailIdx())
		else
			if g_enum_comm.email_comm_type.wantgift == tonumber(maildata.type) then
				local url_decode_jsonStr = ns_http.func.url_decode(maildata.ctx)
				local base64_decode_jsonStr = ns_http.func.base64_decode(url_decode_jsonStr)
				local jsonData = JSON:decode(base64_decode_jsonStr)
				local skinid = 0
				local wantuin = 0
				if jsonData then
					skinid =  jsonData.skinid or 0
					wantuin =  jsonData.wantuin or 0
				end
			
				local skinDef = GetInst("ShopDataManager"):GetSkinDefById(skinid)
				local skinTime = AccountManager:getAccountData():getSkinTime(skinid)
				if skinid ~= 0 then
					if skinDef then
						GetInst("UIManager"):Open("ShopFriendGift",{
							enterType = 1,
							mailid = maildata.id,
							wantuin = wantuin,
							Data = { ID = skinid } ,
							giftType = g_enum_comm.FriendGiftType.SKIN,
							frameType = 1, --ShopFriendGift FrameType 赠送窗口
							HideEditNum = true,
							HideWantTab = skinTime == -1,
							})
					else 	--如果低版本没有索要的皮肤	
						ShowGameTipsWithoutFilter(GetS(158))
					end

					GetInst("MiniUIManager"):CloseUI("MessageCenterAutoGen", true)
				end
			elseif g_enum_comm.email_comm_type.vipcard_demand == tonumber(maildata.type) then
				local jsonData = json2table(maildata.ctx)
				local wantuin = 0
				local giftData = nil
				if jsonData then
					wantuin =  jsonData.wantuin or 0
					giftData = jsonData.giftData
				end
				GetInst("UIManager"):Open("ShopFriendGift",{
							enterType = 1,
							mailid = maildata.id,
							wantuin = wantuin,
							Data = giftData,
							giftType = g_enum_comm.FriendGiftType.VIPCARD,
							frameType = 1, --ShopFriendGift FrameType 赠送窗口
							})

				GetInst("MiniUIManager"):CloseUI("MessageCenterAutoGen", true)
			elseif g_enum_comm.email_comm_type.demandItem == tonumber(maildata.type) then--索取道具
				local url_decode_jsonStr = ns_http.func.url_decode(maildata.ctx)
				local base64_decode_jsonStr = ns_http.func.base64_decode(url_decode_jsonStr)
				local jsonData = JSON:decode(base64_decode_jsonStr)
				local senderNickName =  ""
				if jsonData then
					senderNickName =  jsonData.sendname or ""
				end
				local wantuin = 0
				local giftData = nil
				local sendGiftSucceedReply = function ()
					if #jsonData.items > 0 then
						local items = {}
						local strs = {}
						for i, v in ipairs(jsonData.items) do
							local str = v.id.."_"..v.num
							table.insert(strs, str)
						end
						strs = table.concat(strs, ",")

						local ishide = MailCheckboxIsSelect()
						GetInst("ShopService"):AddWantGiftMailID(maildata.id)
						GetInst("MallGiveDataMgr"):ReplayDemand(strs, jsonData.wantuin, 1, maildata.type, ishide, "", "")
					end
				end
				if jsonData then
					wantuin =  jsonData.wantuin or 0
					if jsonData.giftType == g_enum_comm.FriendGiftType.SPRAY_PAINT then
						if not AccountSafetyCheck:ShowSafetyBindCheck() then
							ShowGameTipsWithoutFilter(GetS(30174))
							return
						end
						giftData = {
							ID = jsonData.items[1].id,
							COST = GetInst("ShopPaintDataManager"):GetSprayPaint(jsonData.items[1].id).cost_num
						}
						local owned = GetInst("ShopPaintDataManager"):CheckSprayPaintIsOwned(jsonData.items[1].id)
						GetInst("UIManager"):Open("ShopFriendGift",{
							enterType = 1,
							mailid = maildata.id,
							wantuin = wantuin,
							Data = giftData,
							giftType = jsonData.giftType,
							frameType = 1, --ShopFriendGift FrameType 赠送窗口
							--HideTab = curData.ownedTime == -1,
							HideEditNum = true,
							sendGiftSucceedReply = sendGiftSucceedReply,
							HideWantTab = owned,
							})
					elseif jsonData.giftType == g_enum_comm.FriendGiftType.WEAPON_SKIN then
						if not AccountSafetyCheck:ShowSafetyBindCheck() then
							ShowGameTipsWithoutFilter(GetS(30174))
							return
						end
						local skinID = ItemUseSkinDefTools:getSkinIDByItemID(jsonData.items[1].id)
						local weaponDef = GetInst("ShopDataManager"):FindCurrentWeaponDef(skinID)
						if weaponDef then
							local weaponView =
							{	
								cameraWidthFov = 30,
								cameraLookAt = {0,220,-1200,0,128,0},
								actorPosition = {0,0,400},
								actorRotateAngle = 155,
								actorScale = 1.0,--武器模型大小
								actorComparePos1 = 170,
								actorComparePos2 = 410,
								actorComparePos3 = 30,
								actorCompareAngle = 360,
								actorScale1 = 1.6,--人物模型大小
								actorPosition1 = {0,-30,0},
								actorRotateAngle1 = -25,
								actorScale2 = 2.6,--手持刀剑,工具模型大小
							}
							local weaponSkinTime = GetInst("ShopDataManager"):GetWeaponSkinTime(weaponDef.SkinID)

							local data = {weaponDef = weaponDef,weaponView = weaponView}
							GetInst("UIManager"):Open("ShopFriendGift",{
								Data = data ,
								giftType = g_enum_comm.FriendGiftType.WEAPON_SKIN,
								frameType = 1, --ShopFriendGift FrameType 赠送窗口
								HideEditNum = true,
								wantuin = wantuin,
								sendGiftSucceedReply = sendGiftSucceedReply,
								HideWantTab = weaponSkinTime == -1,

								})
						end
					elseif jsonData.giftType == g_enum_comm.FriendGiftType.CUSTOM_SKIN then
						if not AccountSafetyCheck:ShowSafetyBindCheck() then
							ShowGameTipsWithoutFilter(GetS(30174))
							return
						end
						local partModleList = {}
						for i, v in ipairs(jsonData.items) do
							local avatarModelID = ItemUseSkinDefTools:getAvatarModelIDByItemID(v.id)
							if avatarModelID then
								table.insert(partModleList, avatarModelID)
							end
						end
						local data = { PartModleList = partModleList };
						GetInst("UIManager"):Open("ShopFriendGift",{
							Data = data ,
							giftType = g_enum_comm.FriendGiftType.CUSTOM_SKIN,
							frameType = 1, --ShopFriendGift FrameType 赠送窗口
							HideEditNum = true,
							wantuin = wantuin,
							sendGiftSucceedReply = sendGiftSucceedReply

						})
					elseif jsonData.giftType == g_enum_comm.FriendGiftType.ITEM_SPEC or
						jsonData.giftType == g_enum_comm.FriendGiftType.ITEM_SHOP then
						if not AccountSafetyCheck:ShowSafetyBindCheck() then
							ShowGameTipsWithoutFilter(GetS(30174))
							return
						end
						local itemid = jsonData.items[1].id
						local num = jsonData.items[1].num
						local config = GetInst("MallGiveDataMgr"):GetItemMallGiveCfg(itemid)
						local data = { ID = itemid , COST = config.mini_coin, num = num };
						GetInst("UIManager"):Open("ShopFriendGift",{
							Data = data ,
							giftType = jsonData.giftType,
							frameType = 1, --ShopFriendGift FrameType 赠送窗口
							wantuin = wantuin,
							sendGiftSucceedReply = sendGiftSucceedReply
						})
					
					end
				end
				
				GetInst("MiniUIManager"):CloseUI("MessageCenterAutoGen", true)
			end
		end	
	else
		if #maildata.items == 0 or maildata.have_taken then
			MailTemplateDeleteBtn_OnClick()
		else
			TakeMailItems(GetCurMail())
			
			MailFrameSendStatistics(GetCurMail(),3)
		end
	end
	MailCommentViewStandReport(maildata, "GetButton", "click", true);
end

function MailFrameMailContGotoBtn_OnClick()
	local maildata = GetCurMail()
	if not maildata then
		return 
	end
	MailCommentViewStandReport(maildata, "Check", "click", true);
	
	local mailType = maildata.type
	if IsFriendGiftOperaMailType(mailType) then
		if not GetInst("ShopService"):FindWantGiftMailID(maildata.id) then
			--发送索取操作状态接口
			if g_enum_comm.email_comm_type.wantgift == mailType then
				local url_decode_jsonStr = ns_http.func.url_decode(maildata.ctx)
				local base64_decode_jsonStr = ns_http.func.base64_decode(url_decode_jsonStr)
				local jsonData = JSON:decode(base64_decode_jsonStr)
				local skinid = 0
				local wantuin = 0
				local skinprice = 0
				local friendname = ""
				if jsonData then
					skinid =  jsonData.skinid or 0
					wantuin =  jsonData.wantuin or 0
					skinprice =  jsonData.skinprice or 0
					friendname =  jsonData.friendname or ""
				end
				local title = ns_http.func.url_encode(GetS(30200)) 
				local skinDef = GetInst("ShopDataManager"):GetSkinDefById(skinid)
				local skinName = ""
				if skinDef then
					skinName = skinDef.Name or ""
				end
				local content = ns_http.func.url_encode(GetS(30199,friendname,skinName))
				local ishide = MailCheckboxIsSelect()
				
				GetInst("ShopService"):SendWantGiftReq(skinid,wantuin,skinprice,title,content,0,ishide, nil, {titlestr= 30200, contentstr = 30199, param1 = friendname, param2 = skinName, skinid = skinid})
			elseif g_enum_comm.email_comm_type.vipcard_demand == mailType then
				local url_decode_jsonStr = ns_http.func.url_decode(maildata.ctx)
				local jsonData = JSON:decode(url_decode_jsonStr)
				local store_id = 0
				local wantuin = 0
				local skinprice = 0
				local friendname = ""
				local giftData = nil
				if jsonData then
					giftData = jsonData.giftData
					wantuin =  jsonData.wantuin or 0
					skinprice =  jsonData.skinprice or 0
					friendname =  jsonData.friendname or ""
					store_id = jsonData.giftData and jsonData.giftData.store_id or 0
				end
				local title = ns_http.func.url_encode(GetS(70848)) --邮件标题
				local giftName = ''
				if giftData then
					local itemDef = ItemDefCsv:get(giftData.item_id)
					if itemDef then
						giftName = itemDef.Name
					end
				end
				local content = ns_http.func.url_encode(GetS(70849 ,friendname,giftName))
				local ishide = MailCheckboxIsSelect()
				
				local ctx = {
					titlestr = 70848,
					contentstr = 70849,
					param1 = friendname,
					param2 = giftName,
					itemid = giftData.item_id,
				}
				ctx = JSON:encode(ctx)
				ctx = ns_http.func.base64_encode(ctx)
				GetInst("MembersSysMgr"):ReqVipDemandReply(store_id,wantuin,ishide,title,content,3,ctx, maildata.id)
			elseif g_enum_comm.email_comm_type.demandItem == mailType then
				local url_decode_jsonStr = ns_http.func.url_decode(maildata.ctx)
				local base64_decode_jsonStr = ns_http.func.base64_decode(url_decode_jsonStr)
				local jsonData = JSON:decode(base64_decode_jsonStr)
				if #jsonData.items > 0 then
					local items = {}
					local strs = {}
					for i, v in ipairs(jsonData.items) do
						local str = v.id.."_"..v.num
						table.insert(strs, str)
					end
					strs = table.concat(strs, ",")
					
					local ishide = MailCheckboxIsSelect()
					
					local content = GetS(30327, "[color=#cFA7A0F]".. AccountManager:getNickName() .."[/color]", "[color=#cFA7A0F]".. GetMailDataGiftName(jsonData).."[/color]")
					
					GetInst("MallGiveDataMgr"):ReplayDemand(strs, jsonData.wantuin, 0, maildata.type, ishide, GetS(30325), content, {
						titlestr = 30325,
						contentstr = 30327,
						replyname = AccountManager:getNickName(),
						items = copy_table(jsonData.items),
						giftType = jsonData.giftType,
					})
				end

			end
			mailservice.isOneKeyDelMail = false
			DeleteMail(GetCurMailIdx())
		end
	elseif (g_enum_comm.email_comm_type.XQlabelresult == mailType) then
		local url_decode_jsonStr = ns_http.func.url_decode(maildata.ctx)
		local jsonData = JSON:decode(url_decode_jsonStr)
		local appeal_end_time = 0
		if jsonData then
			appeal_end_time = jsonData.appeal_end_time or 0
		end

		local ct = getServerTime()
		--appeal_end_time 申述结束时间  星启计划邮件 申诉邮件创建时间＞15天  已过申诉时效，无法申诉
		if appeal_end_time and appeal_end_time ~= 0 and ct > appeal_end_time then 
			ShowGameTipsWithoutFilter(GetS(181016), 3);
		else
			DoMailJump(GetCurMail(),0);
		end
	elseif g_enum_comm.email_comm_type.mapReportResult == mailType then -- 地图举报申诉
		local url_decode_jsonStr = ns_http.func.url_decode(maildata.ctx)
		local jsonData = JSON:decode(url_decode_jsonStr)
		if jsonData.modify_api then
			ns_http.func.rpc_string_raw(jsonData.modify_api, function(res)
                local ok, json = pcall(JSON.decode, JSON, res)
                if ok and type(json) == 'table' then 
                    -- if json.code and json.code == 0 then
						ShowGameTipsWithoutFilter(json.message)
                    -- end
                end 
            end)
		end
	elseif (g_enum_comm.email_comm_type.feedback == mailType) then
		local url_decode_jsonStr = ns_http.func.url_decode(maildata.ctx)
		local jsonData = JSON:decode(url_decode_jsonStr) or {}
		DoMailFeedBackJump(jsonData)
	else
		DoMailJump(GetCurMail(),0);
	end

	MailJumpStandReport(GetCurMail(), "JumpButton", "click", true);
end

function MailFrameMailContGotoBtn2_OnClick()
	local maildata = GetCurMail()

	--工作室邀请
	if maildata.jump_to == '460' then 
		JumpToFucntion[460](maildata.jump_name, 0)
	elseif maildata.jump_to == '463' then 
		JumpToFucntion[463](0)
	elseif maildata and maildata.type and g_enum_comm.email_comm_type.mapReportResult == tonumber(maildata.type) then -- 地图举报申诉
		local url_decode_jsonStr = ns_http.func.url_decode(maildata.jump_to)
		global_jump_ui(99, url_decode_jsonStr)
	end
end

function ConverVerificationCodeToAsterisk(verify_code, content)
	if not verify_code then return content end
	verify_code = tostring(verify_code)
	if verify_code=="" then return content end

	local asterisk = ""
	for i = 1, #verify_code do
		asterisk = asterisk.."*"
	end

	content = string.gsub(content, verify_code, asterisk, 1)

	return content
end

-- 对邮件进行时间排序,按照未读优先，然后时间最新的优先
function SortListMail()
	if mailservice.mails and #mailservice.mails > 0 then
		table.sort(mailservice.mails, function(a, b)
			if not a or not b then
				return false
			end
			if a == b then
				return false
			end
			if a.have_read and not b.have_read then
				return false
			end
			if b.have_read and not a.have_read then
				return true
			end
			if a.create_time and b.create_time then
				return a.create_time > b.create_time
			end
			return false
		end)
	end
end

function UpdateMiniLobbyFrameMailRedTag()
	local notread_mails = 0;

	-- for i = 1, #mailservice.mails do
	-- 	local maildata = mailservice.mails[i];

	-- 	if CheckSendMailReaded(maildata) == false then
	-- 		notread_mails = notread_mails + 1;
	-- 	end
	-- end

	-- 系统/好友消息新消息数量
	local msgCount = GetInst('MessageCenterDataMgr'):GetMsgTabUnReadCount(false)
	local newMsgCount = GetInst('MessageCenterDataMgr'):GetMsgTabNewsCount(false)
	notread_mails = notread_mails + msgCount + newMsgCount

	if notread_mails > 0 then
		-- getglobal("MiniLobbyFrameTopMailRedTag"):Show();
		ShowMiniLobbyMailRedTag() --mark by hfb for new minilobby
		SetMiniLobbyMailRedTagNumber(notread_mails)
	else
		-- getglobal("MiniLobbyFrameTopMailRedTag"):Hide();
		HideMiniLobbyMailRedTag() --mark by hfb for new minilobby
	end
end

local function canOneKeyTake()
	local mails = GetMailList()
	if #mails == 0 then
		return false
	end

	local bCanOneKeyTake = false
	for i = 1,#mails do
		local aMail = mails[i]
		if #aMail.items > 0 and not aMail.have_taken then
			bCanOneKeyTake = true
			break
		end
	end

	return bCanOneKeyTake
end

local function canOneKeyRead()
	local mails = GetMailList()
	if #mails == 0 then
		return false
	end

	local bCanOneKeyRead = false
	for i = 1,#mails do
		local aMail = mails[i]
		if not aMail.have_read then
			bCanOneKeyRead = true
			break
		end
	end

	return bCanOneKeyRead
end

--更新一键领取和已读按钮状态
function updateOneKeyTakeBtnState()
	--如果有附件可以领取，一键领取按钮亮起，否则置灰
	SandboxLua.eventDispatcher:Emit(nil, "MessageCenter_Mail_OnUpdateOneKeyTakeState",  SandboxContext() :SetData_Bool("isEnabled", canOneKeyTake()) )
	--如果有附件未读，一键已读按钮亮起，否则置灰
	SandboxLua.eventDispatcher:Emit(nil, "MessageCenter_Mail_OnUpdateOneKeyReadState",  SandboxContext() :SetData_Bool("isEnabled", canOneKeyRead()) )
end

function GetMailList()
	if GetSelectMailType() == mailservice.MAIL_TYPE.MAIL_SYSTEM then
		return mailservice.mailsSystem
	else
		return mailservice.mailsFriend
	end
end

function GetMailIndex(index)
	return GetMailList()[index]
end

function GetCurMail()
	return GetMailIndex(GetCurMailIdx())
end

--发送埋点数据
function MailFrameSendStatistics(maildata,actionID,jump_id)
	if maildata then
		local id = maildata.unique_id --邮件ID
		local name = maildata.title --邮件名称
		local sendtype --发送类型 1. 后台群发邮件数据；2. 全服邮件数据；3. 活动网页等服务器自动下发奖励邮件数据
		if maildata.from == "backend_send_all" then
			sendtype = 2
		elseif maildata.from == "backend_send_mass" then
			sendtype = 1
		end
		-- statisticsGameEventNew(1201,id or "",name or "",actionID,sendtype or "",jump_id or "",tostring(get_game_lang()))
	end
end

function MailCommentViewStandReport(maildata,sid, eventCode, needExtra)
	maildata = maildata or GetCurMail();
	if not maildata then
		return;
	end

--[[standby2:1.发邮件到客户端打开邮件时差
"standby3  邮件ID
button_state 邮件名"--]]

	local id = maildata.unique_id --邮件ID
	local name = maildata.title --邮件名称
	local mailType = tonumber(maildata.type) or 0;
	local numJump = tonumber(maildata.jump_to)
	if type(numJump) == 'number' and (numJump >= 460 and numJump <= 466) then --工作室给个约定类型 20
		mailType = g_enum_comm.email_comm_type.workSpace or 20
	end

	local ct = getServerTime() - maildata.create_time
	standReportEvent(30, "MAIL_CONTENT", sid, eventCode, {standby1 = mailType, button_state = name,standby2 = ct,standby3 = id})
end

--选择邮件类型
function SetSelectMailType(selectType)
	mailservice.curSelMailType = selectType or mailservice.MAIL_TYPE.MAIL_SYSTEM
end

function GetSelectMailType()
	return mailservice.curSelMailType
end

--判断是否系统邮件
function CheckSystemMail(maildata)
	if not maildata then
		return true
	end
	
	if maildata and maildata.type and g_enum_comm.email_comm_type.sendpresent == tonumber(maildata.type) then
	elseif maildata and maildata.type and g_enum_comm.email_comm_type.wantgift == tonumber(maildata.type) then--索取装扮邮件
	elseif maildata and maildata.type and g_enum_comm.email_comm_type.sharewantgift == tonumber(maildata.type) then--微信/[Desc1]宝分享皮肤[Desc4]邮件
	elseif maildata and maildata.type and g_enum_comm.email_comm_type.weaponskin == tonumber(maildata.type) then--武器皮肤邮件
	elseif maildata and maildata.type and g_enum_comm.email_comm_type.vipcard_present == tonumber(maildata.type) then--赠送会员邮件
	elseif maildata and maildata.type and g_enum_comm.email_comm_type.vipcard_demand == tonumber(maildata.type) then--索要会员邮件
	elseif maildata and maildata.type and g_enum_comm.email_comm_type.demandItem == tonumber(maildata.type) then--索要道具邮件
	elseif maildata and maildata.type and g_enum_comm.email_comm_type.sendItem == tonumber(maildata.type) then--赠送道具邮件
	else
		--工作室占用 jump_to 说明
		--460 邀请加入工作室邮件 发给被邀请人
		--461 被邀请人同意加入邮件 发给会长
		--462 同意申请加入 发给申请人
		--463 邀请签约 发给被邀请人
		--464 同意签约工作室 发送室长
		--465 拒绝签约工作室 发送室长
		--466 创建工作室成功 发送室长
--[[		local numJump = tonumber(maildata.jump_to)
		if type(numJump) == 'number' and (numJump >= 460 and numJump <= 466) then
		else
			--除1，3，4，10 及jump_to 460-466
			return true
		end--]]
		return true --策划确认工作室邮件算官方
	end
	return false
end

--邮件分类
function ClassifyMailList()
	mailservice.mailsSystem = {}
	mailservice.mailsFriend = {}

	for k, maildata in pairs(mailservice.mails) do
		if maildata.channel == mailservice.MAIL_TYPE.MAIL_SYSTEM then
			table.insert(mailservice.mailsSystem, maildata);
		else
			table.insert(mailservice.mailsFriend, maildata);
		end
	end
end

--判断是否已读且领取
function CheckSendMailReaded(maildata)
	if not maildata then
		return false
	end
	if maildata and maildata.have_read == false then
		return false
	else
		if maildata.items and (#maildata.items > 0) and (not maildata.have_taken) then
			return false
		end
	end
	return true
end

function GetFriendMailUnreadNum()
	local count = 0

	for k, maildata in pairs(mailservice.mailsFriend) do
		if not CheckSendMailReaded(maildata) then
			count = count + 1
		end
	end
	
	return count
end

function GetSysMailUnreadNum()
	local count = 0

	for k, maildata in pairs(mailservice.mailsSystem) do
		if not CheckSendMailReaded(maildata) then
			count = count + 1
		end
	end

	return count
end

function GetMailTitle(maildata)
	local desc = GetMailDesc(maildata)
	local strTitle, _ = GenerateUBBStr_old(desc and desc.strTitle or "")
	return strTitle
end


-- 皮肤索要消息内容
local function GetSkinAskForContent(organizedContent, jsonData)
	local strContent = organizedContent

	if jsonData.skinid and jsonData.blesssStr then
		local skinDef = GetInst("ShopDataManager"):GetSkinDefById(jsonData.skinid)
		local skinName = skinDef and skinDef.Name or ""
		local tipsText = GetS(jsonData.blesssStr, "#cFA7A0F" .. skinName .. "#n")
		strContent = GetS(30198, jsonData.friendname, tipsText) or ""
	end

	return strContent
end

-- 获得武器装扮消息内容
local function GetWeaponSkinContent(organizedContent, jsonData)
	if jsonData.blesssStr then
		local weaponDef = GetInst("ShopDataManager"):FindCurrentWeaponDef(jsonData.weaponid)
		local weaponName = weaponDef.Name .."（"..GetS(611).."）"
		organizedContent = GetS(30169, jsonData.sendname, jsonData.senduin,weaponName,GetS(jsonData.blesssStr))
	end
	
	return string.gsub( organizedContent, '\\n', '#r') or ""
end

-- VIP卡赠送消息内容
local function GetVipPresentContent(organizedContent, jsonData)
	if jsonData.vipstr and jsonData.giftData then
		local itemDef = ItemDefCsv:get(jsonData.giftData.item_id)
		local vipcardName = itemDef and itemDef.Name or ""
		organizedContent = GetS(30169, jsonData.sendname , jsonData.friendUin, vipcardName, GetS(jsonData.vipstr))
	end
	return (string.gsub( organizedContent, '\\n', '#r') .. GetS(70850)) or ""
end

-- VIP卡索要消息内容
local function GetVipCardDemandContent(organizedContent, jsonData)
	if jsonData.vipstr and jsonData.giftData then
		local btis = jsonData.vipstr
		local itemDef = ItemDefCsv:get(jsonData.giftData.item_id)
		local giftName = itemDef and itemDef.Name or ""
		local tipsText = GetS(btis, "#cFA7A0F"..giftName.."#n")

		organizedContent = GetS(30198,jsonData.friendname, tipsText)
	end
	
	return string.gsub( organizedContent, '\\n', '#r') or ""
end

-- 赠送道具消息内容
local function GetSendItemContent(organizedContent, maildata, jsonData)
	local senderNickName = jsonData.sendname
	local itemid 	= maildata.items[1].id
	local num 		= maildata.items[1].count
	local itemDef 	= ItemDefCsv:get(itemid)
	local itemName 	= itemDef and  GetS(30321, num, itemDef.Name) or ""
	
	return GetS(30169, senderNickName, jsonData.uin or 0, itemName, organizedContent) or ""
end

local function GetMailOffcialContent(organizedContent, maildata, jsonData)
	if jsonData and jsonData.strid and jsonData.friendname and jsonData.skinName then
		organizedContent = GetS(jsonData.strid, jsonData.friendname, jsonData.skinName)
	end

	if maildata.verify_code and maildata.verify_code ~= "" then -- 需要对内容验证码进行加密
		organizedContent = ConverVerificationCodeToAsterisk(maildata.verify_code, organizedContent)
	else
		organizedContent = string.gsub( organizedContent, '\\n', '#r') or ""
	end

	return organizedContent
end

local function GetRewardListStr(maildata)
	-- list 滑动栏
	local itemName = ""
	for i = 1, mailservice.MAIL_CONTENT_REWARD_ITEM_MAX_NUM do
		if i <= #maildata.items and _G.check_use_new_server() then
			local item = maildata.items[i];
			local itemDef = ItemDefCsv:get(item.id);
			local iName = ""
			if itemDef then
				iName = itemDef.Name
			end

			if i == 1 then
				itemName = itemName .. iName
			else
				itemName = itemName .. "," .. iName
			end
		end
	end

	return itemName
end

--索取皮肤邮件显示 删除并拒绝 / 前往赠送   索取皮肤邮件 maildata.type = 3,拒绝赠送皮肤邮件 maildata.type = 0
function IsFriendGiftOperaMailType(mailType)
	if mailType == g_enum_comm.email_comm_type.wantgift
	or mailType == g_enum_comm.email_comm_type.vipcard_demand
	or mailType == g_enum_comm.email_comm_type.demandItem then

		return true
	end

	return false
end

function GetMailDesc(maildata)
	if not maildata then
		return
	end

	if mailservice.desc[maildata.id] then
		return mailservice.desc[maildata.id]
	end
	
	local strTitle = ""
	local strSource = "" 	-- 邮件来源
	local strContent = "" 	-- 邮件内容
	local organizedContent = maildata.content or ""

	local mailType = tonumber(maildata.type)
	local enumMailType = g_enum_comm.email_comm_type
	
	if enumMailType.sendpresent == mailType then
		local _, _, senderNickName, senderUin = string.find(maildata.sender, "(.+)%((%d+)%)")

		senderNickName = DefMgr:filterString(senderNickName or "")
		strTitle = GetS(30168) -- 收到礼物
		strSource = GetS(30159, senderNickName) -- 来自@1

		strContent = GetS(30169, senderNickName, senderUin, GetRewardListStr(maildata), organizedContent) or ""
	elseif enumMailType.wantgift == mailType then --索取装扮邮件

		local jsonData = DecodeMailData(maildata.ctx, true)
		strTitle = GetS(30185) -- 装扮索要
		strSource = GetS(30159, jsonData and DefMgr:filterString(jsonData.sendname or "") or "") -- 来自@1

		strContent = GetSkinAskForContent(organizedContent, jsonData)
	elseif enumMailType.sharewantgift == mailType then--微信/[Desc1]宝分享皮肤[Desc4]邮件

		strTitle = GetS(30168) -- 收到礼物
		strSource = GetS(30295) -- 来自神秘好友

		strContent = GetS(30296, GetRewardListStr(maildata))
	elseif enumMailType.weaponskin == mailType or  --武器皮肤邮件
		enumMailType.vipcard_present == mailType then --赠送会员邮件
		
		local jsonData = DecodeMailData(maildata.ctx)

		strTitle = GetS(30168) -- 收到礼物
		strSource = GetS(30159, jsonData and DefMgr:filterString(jsonData.sendname or "") or "") -- 来自@1

		if enumMailType.vipcard_present == mailType then
			strContent = GetVipPresentContent(organizedContent, jsonData)
		else
			strContent = GetWeaponSkinContent(organizedContent, jsonData)
		end
	elseif enumMailType.vipcard_demand == mailType then  --索要会员邮件

		local jsonData = DecodeMailData(maildata.ctx)

		strTitle = GetS(70840) -- 会员索要
		strSource = GetS(30159, jsonData and DefMgr:filterString(jsonData.sendname or "") or "") -- 来自@1
		strContent = GetVipCardDemandContent(organizedContent, jsonData)
	elseif enumMailType.demandItem == mailType then

		local jsonData = DecodeMailData(maildata.ctx, true)

		strTitle = GetS(30323)  -- 好友索要
		strSource = GetS(30159, jsonData and DefMgr:filterString(jsonData.sendname or "") or "") -- 来自@1
		strContent = GetS(jsonData.contentStr, "#cFA7A0F"..GetMailDataGiftName(jsonData).."#n")
	elseif enumMailType.sendItem == mailType then

		local jsonData = DecodeMailData(maildata.ctx, true)
		
		strTitle = GetS(30168)  -- 收到礼物
		strSource = GetS(30159, jsonData and DefMgr:filterString(jsonData.sendname or "") or "") -- 来自@1
		strContent = GetSendItemContent(GetS(jsonData.contentStr), maildata, jsonData)
	elseif enumMailType.demandItemReplay == mailType then

		local jsonData = DecodeMailData(maildata.ctx, true)
		maildata.title = GetS(jsonData.titlestr)

		strTitle = maildata.title
		local replyName = DefMgr:filterString(jsonData.replyname or "")
		strContent =  GetS(jsonData.contentstr, "#cFA7A0F".. replyName .."#n", "#cFA7A0F".. GetMailDataGiftName(jsonData.items or {}).."#n")
	elseif enumMailType.sendFriendGift == mailType then
		local jsonData = JSON:decode(maildata.ctx)
		if jsonData and jsonData.id and jsonData.num and jsonData.role_name then
			local itemDef = ItemDefCsv:get(jsonData.id);

			strTitle = GetS(70972, jsonData.num, itemDef and itemDef.Name or "")
			strSource = GetS(4082) -- 来自迷你官方
			local config = GetInst("FriendGiftDataMgr"):GetItemConfig(jsonData.id)
			strContent = GetS(70973, jsonData.role_name, jsonData.num, itemDef and itemDef.Name or "", config and config.charm_value, config.intimacies)
			
		else
			strTitle = maildata.title or ""
			strSource = GetS(4082) -- 来自迷你官方
			strContent = GetMailOffcialContent(organizedContent, maildata, jsonData)
		end
	elseif enumMailType.sendRedPocket == mailType then
		-- 好友代付红包邮件通知
		local jsonData = JSON:decode(maildata.ctx)
		if jsonData and jsonData.minicoin and jsonData.rolename then
			strTitle = maildata.title or ""
			strSource = GetS(4082) -- 来自迷你官方
			strContent = GetS(70987, jsonData.rolename, jsonData.minicoin, GetS(74))
		else
			strTitle = maildata.title or ""
			strSource = GetS(4082) -- 来自迷你官方
			strContent = GetMailOffcialContent(organizedContent, maildata, jsonData)
		end
	else
		local jsonData = DecodeMailData(maildata.ctx, true)
		if jsonData and jsonData.titlestr then
			maildata.title = GetS(jsonData.titlestr)
			organizedContent = GetS(jsonData.contentstr, jsonData.param1, jsonData.param2)
		end

		strTitle = maildata.title or ""
		strSource = GetS(4082) -- 来自迷你官方
		strContent = GetMailOffcialContent(organizedContent, maildata, jsonData)

		local numJump = tonumber(maildata.jump_to)
		if type(numJump) == 'number' and (numJump >= 460 and numJump <= 466) then
			strSource = ''
		end
	end

	-- 限制标题在15个字符以内
	local strlen, bOverflow = getStringLength(strTitle, 15 * 3)
	if bOverflow then
		strTitle = string.sub(strTitle, 1, strlen).."..."
	end	

	-- 缓存相关数据
	mailservice.desc[maildata.id] =
		{
			["strTitle"] = strTitle, 
			["strSource"] = strSource, 
			["strContent"] = strContent
		}

	return mailservice.desc[maildata.id]
end