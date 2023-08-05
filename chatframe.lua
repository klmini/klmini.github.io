


function ChatInputFrame_OnShow()
	if CurWorld:getOWID() == NewbieWorldId or CurWorld:getOWID() == NewbieWorldId2 then
		this:Hide();
		return;
	end
	if IsInHomeLandMap and IsInHomeLandMap() then
		UIFrameMgr:setCurEditBox(getglobal("ChatInputBox"));
	else
		UIFrameMgr:setCurEditBox(getglobal("ChatInputBox"));
		UIFrameMgr:setCurEditBox(nil);
		--显示新版聊天输入框
		if not GetInst("MiniUIManager"):IsShown("chat_view") then
			GetInst("ChatHelper"):OpenChatView()
		end
		local chatViewCtrl =  GetInst("MiniUIManager"):GetCtrl("chat_view")
		if chatViewCtrl then
			if GetInst("MiniUIManager"):IsShown("chat_view") then --有些界面会关闭掉聊天框
				chatViewCtrl:SetChatViewType(1)
				chatViewCtrl:UpdateEditBoxStatus(true)
			end
		end
		getglobal("ChatInputFrame"):Hide();
		local isShow = CurMainPlayer and CurMainPlayer:isSightMode() or false
		GetInst("ChatHelper"):SetSightMode(isShow)
	end
	
	--if not getglobal("ChatInputFrame"):IsReshow() then
	--	ClientCurGame:setOperateUI(true);
	--end

	--LLDO:13岁保护模式
	ProtectModeChatFrameTip();
end

function ChatInputFrame_OnHide()
	--if not getglobal("ChatInputFrame"):IsRehide() then
	--   ClientCurGame:setOperateUI(false);
	--end
end


function ChatInputBox_OnEnterPressed()
	local editbox = getglobal("ChatInputBox");
	getglobal("ChatInputFrame"):Hide();
	UIFrameMgr:setCurEditBox(nil);

	local text = editbox:GetText();
	
	editbox:Clear();
	getglobal("ChatInputFrame"):Hide();
	UIFrameMgr:setCurEditBox(nil);
	if ns_data.IsGameFunctionProhibited("ch", 10581, 10582) then 
		return 
	end
	editbox:AddStringToHistory(text);
	if ClientCurGame then 
		if  if_open_google_translate_room(ClientCurGame:getHostUin()) then
			ClientCurGame:sendChat(text,0,0,get_game_lang());
		else
			ClientCurGame:sendChat(text);
		end
	end 
end

function ChatContentFrame_OnLoad()
	this:RegisterEvent("GE_UPDATE_CHATMSG");
end

ChatDisplayTime = 0

function ChatContentFrameEvent(tanslate,type,sp,contents,doNotFilter, filterInfo, extend)
	if IsHideUI then
		getglobal("ChatContentFrame"):Hide();
    elseif IsInHomeLandMap() then
		-- 家园系统事件展示框埋点上报
		Homeland_StandReport_MainUIView("SystemEventDisplay", "view")
		--家园聊天调用刷新数据
		if HomeLandChatCall then
			HomeLandChatCall("DoRefresh", "chat_content_frame_event")
		end
		local chattype = type;
		local speaker = ReplaceFilterString(sp);
		local content = contents;

		local isGiftMsg, _content = GetFriendGiftMsg(extend, false)
		if isGiftMsg then
			content = _content
		end
		local adjustContent = ""
		local color = {r=255, g=255,b=255}
		print("homemap chat content event----:chattype:",chattype," speaker:",speaker," content:",content);
		if content ~= "" and (chattype==0 or chattype==1 or chattype==3  or chattype==5 ) then
			if not doNotFilter  and chattype ~= 5 then
				content = DefMgr:filterString(content);	--过滤敏感词
			end 
			if chattype == 0 or chattype == 3 then
				Log("homemap chat type:" .. chattype);
				if speaker == "" then
					Log("homemap speaker" .. speaker)
					local nickName = ReplaceFilterString(AccountManager:getNickName());
					-- adjustContent = AccountManager:getBlueVipIconStr(AccountManager:getUin()).."#c64de32"..nickName..getSpectatorIconStr(AccountManager:getUin()).."：#n"..content;
					adjustContent = AccountManager:getBlueVipIconStr(AccountManager:getUin())..nickName..getSpectatorIconStr(AccountManager:getUin()).."：#n#cffffff"..content;
					color = {r=100, g=222, b=50}
				else
					local nickName = ReplaceFilterString(AccountManager:getNickName());
					-- adjustContent = "#cf4b222"..speaker.."：#n"..content;
					adjustContent = speaker.."：#n#cffffff"..content;
					color = {r=244, g=178, b=34}

					local uin;
					if nickName == speaker then
						uin = AccountManager:getUin();						
						-- adjustContent = "#c64de32"..speaker.."：#n"..content;						
						adjustContent = speaker.."：#n#cffffff"..content;						
						color = {r=100, g=222, b=50}
					else
						uin = GetRoomPlayerUin2Name(speaker);
					end

					if uin ~= 0 then
						if ReportChatCon:CheckUinBlacklist(uin) then
							return;
						end
                        
                        --是否屏蔽该用户消息
						if IsMaskPlayersSpeaking(uin) then
							return
						end

						-- adjustContent = "#cf4b222"..speaker..getSpectatorIconStr(uin).."：#n"..content;
						adjustContent = speaker..getSpectatorIconStr(uin).."：#n#cffffff"..content;
						color = {r=244, g=178, b=34}
						adjustContent = AccountManager:getBlueVipIconStr(uin)..adjustContent;						
					end
				end
			else
				adjustContent = "#cffffff" .. content
			end
		elseif chattype == 2 then
			-- 系统提示、迷你队长提示公告
			adjustContent = "#cffffff" .. content
		end
		if HomeSysMsg == nil then 
			HomeSysMsg = {} 
		end
		-- 好友消息去重
		if type == 3 and filterInfo then
			local isExist = false
			for i = 1, #HomeSysMsg do
				if HomeSysMsg[i].msgType == type and HomeSysMsg[i].filterInfo then
					if HomeSysMsg[i].filterInfo.time == filterInfo.time and 
						HomeSysMsg[i].filterInfo.src_uin == filterInfo.src_uin and 
						HomeSysMsg[i].content == adjustContent then
						--ShowGameTips("过滤掉重复的好友消息："..adjustContent)
						return
					end
				end
			end
		end
	
		table.insert(HomeSysMsg, #HomeSysMsg+1, {msgType = type, speaker = sp, content = adjustContent, filterInfo = filterInfo, color= color})
		-- 调整消息内容，超过显示区域的将不再显示
        AdjustHomeSysMsg()
        
        --初始化透明度
        getglobal("HomeChatContentFrame"):Show()
        ChatDisplayTime = 10.0
        getglobal("HomeChatContentFrameBkg"):SetBlendAlpha(1);
        for i=1, #HomeSysMsgUI do--#HomeSysMsg do
            if HomeSysMsgUI[i] then
                HomeSysMsgUI[i].TagBkg:SetBlendAlpha(1);
                HomeSysMsgUI[i].MsgTag:SetBlendAlpha(1);
                HomeSysMsgUI[i].Content:SetAlpha(1);
            end
        end
	else
		--社交大厅return 掉
		if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
			return
		end
		local chattype = type;
		local speaker = ReplaceFilterString(sp);
		local content = contents;
		print("chat content event----:chattype:",chattype," speaker:",speaker," content:",content);
		local extendJson = ""

		if extend then
			extendJson = JSON:encode(extend)
		end
		local sb_cont = SandboxContext()
			:SetData_Number("chattype", chattype)
			:SetData_String("speaker", speaker)
			:SetData_String("content", content)
			:SetData_Bool("doNotFilter", doNotFilter)
			:SetData_Number("sp_uin", (filterInfo and filterInfo.src_uin) and filterInfo.src_uin or 0)
			:SetData_String("extend", extendJson)
		if tanslate then
			sb_cont:SetData_String("jsonTranslate", JSON:encode(tanslate))
		end

		local resultObj = SandboxLua.eventDispatcher:Emit(nil, g_ChatConfig.EVENT.CHAT_MODULE_ON_RECEIVE_ROOM_MSG, sb_cont)

		-- 新聊天逻辑执行成功，直接返回，忽略老逻辑
		if resultObj:IsExecSuccessed() then
			return
		end

		if content ~= "" and (chattype==0 or chattype==1 or chattype==5) then
			local systips = getglobal( "ChatContentText" );
			if not doNotFilter and chattype ~= 5 then
				content = DefMgr:filterString(content);	--过滤敏感词
			end 
			if chattype == 0 then
				Log("chat type:" .. chattype);
				if speaker == "" then
					Log("speaker" .. speaker)
					local nickName = ReplaceFilterString(AccountManager:getNickName());
					local blueVipStr = AccountManager:getBlueVipIconStr(AccountManager:getUin())
					-- local text = AccountManager:getBlueVipIconStr(AccountManager:getUin()).."#c64de32"..nickName..getSpectatorIconStr(AccountManager:getUin()).."：#n"..content;
					local text = nickName..getSpectatorIconStr(AccountManager:getUin()).."：#n#cffffff"..content
					-- systips:AddText(text, 255, 255, 255);
					G_VipNamePreFixEntrency(systips, AccountManager:getUin(), text, {r=100,g=222,b=50}, false, blueVipStr, true)
				else
					local nickName = ReplaceFilterString(AccountManager:getNickName());
					local translateContent =content;
					Log("chat message translate")
					if ClientCurGame and ClientCurGame.getHostUin and if_open_google_translate_room(ClientCurGame:getHostUin()) and  tanslate.translatedText ~= nil  and tanslate.translatedText ~= "" then
						Log("translated-----")
						translateContent = tanslate.translatedText;
					end

					local color = {r=244,g=178,b=34}
					local blueVipStr = ''
					local text = speaker.."：#n#cffffff"..translateContent;

					local uin;
					if nickName == speaker then
						uin = AccountManager:getUin();
						color = {r=100,g=222,b=50}
						text = speaker.."：#n#cffffff"..translateContent;
						
                    else
						uin = GetRoomPlayerUin2Name(speaker);
					end

					if uin ~= 0 then
						if ReportChatCon:CheckUinBlacklist(uin) then
							return;
						end

                        --是否屏蔽该用户消息   
						if IsMaskPlayersSpeaking(uin) then
							return
						end
						color = {r=244,g=178,b=34}
						blueVipStr = AccountManager:getBlueVipIconStr(uin)
						text = "#L".. speaker..getSpectatorIconStr(uin).."#n：#n#cffffff"..translateContent;
						local bVip = GetInst('MembersSysMgr'):IsMemberByUin(tonumber(uin))
						
						if bVip then --设置超链接颜色
							systips:SetLinkTextColor(209,59,59)
						else
							systips:SetLinkTextColor(244,178,34)
						end
						-- text = AccountManager:getBlueVipIconStr(uin)..text;						
					end

					-- systips:AddText(text, 255, 255, 255); 
					G_VipNamePreFixEntrency(systips, uin, text, color, false, blueVipStr, true)
				end
			else
				local text = content;
				systips:AddText(text, 244, 178, 34); 
			end
			systips:SetDispPos(systips:GetStartDispPos());

			maxviewlines = systips:GetAccurateViewLines()
			nNum = systips:GetTextLines() - maxviewlines

			systips:SetDispPos(systips:GetStartDispPos());
			systips:ScrollEnd();

		elseif chattype == 2 then
			local systips = getglobal("ChatContentText");
			--迷你队长提示公告去掉"迷你队长温馨提示："字样
			local text = content;
			systips:SetText(text, 255, 255, 255);

			systips:SetDispPos(systips:GetStartDispPos());

			maxviewlines = systips:GetAccurateViewLines()
			nNum = systips:GetTextLines() - maxviewlines

			for i = 1, nNum do
				systips:ScrollDown();
			end
		end

		if not getglobal("RoomUIFrame"):IsShown() and ClientCurGame:isInGame() and (chattype==0 or chattype==1 or chattype == 2) then
			print("ChatContentFrame, show1111")
			getglobal("ChatContentFrame"):Show();
			local bkg = getglobal("ChatContentFrameBkg");
			local text = getglobal("ChatContentText");
			bkg:SetBlendAlpha(0.25);
			text:SetAlpha(1.0);
			
			ChatDisplayTime = 10.0

			if isEducationalVersion then
				bkg:SetBlendAlpha(0.5);
				ChatDisplayTime = 20.0
			end

			if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
				standReportEvent("1003", "CHAT_FLOAT", "-", "view")
			else
				standReportEvent("1001", "CHAT_FLOAT", "-", "view")
			end
		end
	end
end

function ChatContentFrame_OnEvent()
	if arg1 == "GE_UPDATE_CHATMSG" then
		Log("ChatContentFrame_OnEvent");

		return;
		--[[
local ge = GameEventQue:getCurEvent();

		local chattype = ge.body.chat.chattype;
		local speaker = ge.body.chat.speaker;
		local content = ge.body.chat.content;
		local uin = ge.body.chat.uin;
		local language = ge.body.chat.language;

		if IsHideUI then
			this:Hide();
		else
			if content ~= "" and (chattype==0 or chattype==1) then
				local systips = getglobal( "ChatContentText" );
				content = DefMgr:filterString(content);	--过滤敏感词
				if chattype == 0 then
					if speaker == "" then
						local nickName = AccountManager:getNickName();
						local text = AccountManager:getBlueVipIconStr(AccountManager:getUin()).."#c64de32"..nickName..getSpectatorIconStr(AccountManager:getUin()).."：#n"..content;
						systips:AddText(text, 255, 255, 255);
					else
						local nickName = AccountManager:getNickName();
							local translateContent = content;
							Log("chat begin translate------")

							if if_open_google_translate() and language ~= get_game_lang() then
								local transText,srcLang = Google_Language_Translate(content,get_game_lang_str());
								if transText ~= "" then
									t_tanslate.translatedText = transText;
									t_tanslate.translateSrc = srcLang;
									t_tanslate.IsTranslated = true;
									translateContent = transText;
								else
									ShowGameTips("translate fail",3);
								end
							end

							RoomUIFrameCenterEvent(t_tanslate,chattype,speaker,content,uin,language);

							local text = "#cf4b222"..speaker.."：#n"..translateContent;

							local uin;
							if nickName == speaker then
								uin = AccountManager:getUin();
								text = "#c64de32"..speaker.."：#n"..translateContent;
							else
								uin = GetRoomPlayerUin2Name(speaker);
							end
							if uin ~= 0 then
								text = "#cf4b222"..speaker..getSpectatorIconStr(uin).."：#n"..translateContent;
								text = AccountManager:getBlueVipIconStr(uin)..text;						
							end
							systips:AddText(text, 255, 255, 255); 
					end
				else
					local text = content;
					systips:AddText(text, 244, 178, 34); 
				end
				systips:SetDispPos(systips:GetStartDispPos());

				maxviewlines = systips:GetAccurateViewLines()
				nNum = systips:GetTextLines() - maxviewlines

				systips:SetDispPos(systips:GetStartDispPos());
				for i = 1, nNum do
					systips:ScrollDown();
				end
			end

			if not getglobal("RoomUIFrame"):IsShown() then
				getglobal("ChatContentFrame"):Show();
				local bkg = getglobal("ChatContentFrameBkg");
				local text = getglobal("ChatContentText");
				bkg:SetBlendAlpha(0.25);
				text:SetAlpha(1.0);
				
				ChatDisplayTime = 10.0
			end
		end

		--]]
		
	end
end

function ChatContentFrame_OnUpdate()
	if IsInHomeLandMap() then return end
	ChatDisplayTime = ChatDisplayTime - arg1
	local bkg = getglobal("ChatContentFrameBkg");
	local text = getglobal("ChatContentText");
	if ChatDisplayTime <= 3 then
		local alpha1 = bkg:GetBlendAlpha();		
		alpha1 = alpha1 - 0.25*arg1/3;
		if alpha1 < 0 then
			alpha1 = 0;
		end
	
		bkg:SetBlendAlpha(alpha1);
		
		local alpha2 = text:GetAlpha();
		alpha2 = alpha2 - 1*arg1/3;		
		if alpha2 < 0 then
			alpha2 = 0;
		end
		text:SetAlpha(alpha2);

		if ChatDisplayTime <= 0 then
			this:Hide();
			bkg:SetBlendAlpha(0.25);
			text:SetAlpha(1.0);
		end
	end
end

function Accelkey_AltGroup( szFrame, nIndex )
end

function ReqCheckSendChat(content, isRoomOw)
	local needCheck = true;

	-- 检测是否有会员表情
	if GetInst('MembersSysMgr'):CheckStringFitVipFaceCode(content) then
		return
	end

	--字牌或者海外版不用检查或者配置了不检查
	if (ClientCurGame:isInGame() and ClientCurGame:getCurOpenContanierIndex() == SIGNS_START_INDEX) 
		or isAbroadEvn() or not if_open_chat3rdCheck() then
		needCheck = false;
	end
	--提示语  系统提示不用审核
	if string.find(content, "^&%d$") == 1 then
		needCheck = false;
	end

	if needCheck then 
		local desUinList = "";
		local myBriefInfo = ClientCurGame:getPlayerBriefInfo(-1);
		if myBriefInfo then
			desUinList = myBriefInfo.uin;
		end

		local num = ClientCurGame:getNumPlayerBriefInfo();
		if num > 0 then
			desUinList = desUinList..",";
		end

		for i=1, num do
			local briefInfo = ClientCurGame:getPlayerBriefInfo(i-1);
			if briefInfo then
				desUinList = desUinList..briefInfo.uin;
				if i ~= num then
					desUinList = desUinList..",";
				end
			end
		end
		ReqCheckString(content, {content=content, type="SendChat", isroomow=isRoomOw}, desUinList, "in_map_chat");
	else
		RespCheckSendChat(content,  {content=content, type="SendChat", isroomow=isRoomOw});
	end
end

function RespCheckSendChat(content, extendData)
	if extendData.isroomow ~= nil then
		local extend = {
			bubble = GetInst("ChatBubbleMgr"):GetCurrentUsingBubble(),
		}
		local extendStr = JSON:encode(extend)
		if if_open_google_translate_room(ClientCurGame:getHostUin()) then
            ClientCurGame:sendChat(content, 0, 0, get_game_lang(), extendStr);
        else
            ClientCurGame:sendChat(content, 0, 0, 1, extendStr);
		end
		
		-- statisticsGameEvent(53002, "%s", "sendChatText", "%d", extendData.isroomow);
	else
		ClientCurGame:sendChat(content);
	end

	NewBattlePassEventOnTrigger("sendchat");
end

--[[==================================家园地图聊天框逻辑============================================]]
function HomeChatContentFrame_OnLoad()
	HomeSysMsgUI = {}
	for i = 1, 10 do
		HomeSysMsgUI[i] = {
			Item = getglobal("HomeChatMessagesMsg"..i),
			TagBkg = getglobal("HomeChatMessagesMsg"..i.."TagBkg"),
			MsgTag = getglobal("HomeChatMessagesMsg"..i.."Tag"),
			Content = getglobal("HomeChatMessagesMsg"..i.."Content")
		}
	end
end

function HomeChatContentFrame_OnUpdate()
    if (not IsInHomeLandMap()) or (#HomeSysMsg < 1) then
        getglobal("HomeChatContentFrame"):Hide()
        return 
    end

    local alphaTagBkg=HomeSysMsgUI[1].TagBkg:GetBlendAlpha()
    local alphaMsgTag=HomeSysMsgUI[1].MsgTag:GetBlendAlpha()
    local alphaContent=HomeSysMsgUI[1].Content:GetAlpha()

	ChatDisplayTime = ChatDisplayTime - arg1
	if ChatDisplayTime <= 3 then
		alphaTagBkg = alphaTagBkg - 0.25*arg1/3;
		if alphaTagBkg < 0 then
			alphaTagBkg = 0;
		end
	
		alphaMsgTag = alphaMsgTag - 1*arg1/3;		
		if alphaMsgTag < 0 then
			alphaMsgTag = 0;
		end

        alphaContent = alphaContent - 1*arg1/3;		
		if alphaContent < 0 then
            alphaContent = 0;
            getglobal("HomeChatContentFrame"):Hide();

            if getglobal("HomelandFarmTipFrame"):GetClientString() ~= "" then
                getglobal("HomelandFarmTipFrame"):Show()
            end
		end

        for i=1, #HomeSysMsgUI do--#HomeSysMsg do
            if HomeSysMsgUI[i] then
                HomeSysMsgUI[i].TagBkg:SetBlendAlpha(alphaTagBkg);
                HomeSysMsgUI[i].MsgTag:SetBlendAlpha(alphaMsgTag);
                HomeSysMsgUI[i].Content:SetAlpha(alphaContent);
            end
        end

		if ChatDisplayTime <= 0 then
            getglobal("HomeChatContentFrame"):Hide();
            
            for i=1, #HomeSysMsgUI do--#HomeSysMsg do
                if HomeSysMsgUI[i] then
                    HomeSysMsgUI[i].TagBkg:SetBlendAlpha(1);
                    HomeSysMsgUI[i].MsgTag:SetBlendAlpha(1);
                    HomeSysMsgUI[i].Content:SetAlpha(1);
                end
            end
		end
    end
end


--隐藏家园消息ui
function HideAllHomeLandMsg()
	if HomeSysMsgUI then
		for i = 1, #HomeSysMsgUI do
			if HomeSysMsgUI[i] and HomeSysMsgUI[i].Item then
				HomeSysMsgUI[i].Item:Hide()
			end
		end
	end
end

--设置透明度
function SetHomeSysMsgUiAhpha(item,alpha)
	if item then
		item.TagBkg:SetBlendAlpha(alpha);
		item.MsgTag:SetBlendAlpha(alpha);
		item.Content:SetAlpha(alpha);
	end
end

-- 调整消息内容，超出显示区域的部分删除
function AdjustHomeSysMsg()
	HideAllHomeLandMsg()
	local MaxItemCount = 10
	local MsxHeight = 175
	local totalHeight, height = 0, 0
	local count = #HomeSysMsg
	local ChatContentText = getglobal("HomeChatContentFrameTest")
	--print("count = ", count)
    local firstLine = 0
    local msg = ""
	for i = count, 1, -1 do
		ChatContentText:SetText(HomeSysMsg[i].content, 255, 255, 255)
		height = ChatContentText:GetTotalHeight()
		firstLine = ChatContentText:GetLineHeight(1)
		totalHeight = totalHeight + height + 5 -- +5为RichText行间距
		-- if count > 10 then--totalHeight > MsxHeight then
		-- 	--print("remove index = ", i)
		-- 	table.remove(HomeSysMsg, i)
		-- else
			HomeSysMsg[i].height = height			
			HomeSysMsg[i].firstLineHeight = firstLine
		-- end
        --print("i = "..i.."firstLine = "..firstLine..", height = "..height..", totalHeight = "..totalHeight)
	end
	--print(HomeSysMsg)

	local startY = totalHeight - MsxHeight
    startY = math.max(startY, 0)

	-- 刷新SlidingFrameUI
	local slidingY = 10
	local tag = GetS(41493)
	local name = ""
	local height = 0
	local reUseIndex = 1
	for i = 1, count do
		local ItemUi = nil
		if HomeSysMsg[i] then
			--print("i = "..i..", content = "..HomeSysMsg[i].content)
			if HomeSysMsg[i].msgType == 0 then
				tag = GetS(41200)  -- 家园
			elseif HomeSysMsg[i].msgType == 2 then
				tag = GetS(41493)  -- 系统
			elseif HomeSysMsg[i].msgType == 3 then
				tag = GetS(209)    -- 好友
			end
			height = 3 + HomeSysMsg[i].firstLineHeight - 19

			local item = HomeSysMsgUI[i]
			local bReUse = false
			if not item then
				item = HomeSysMsgUI[reUseIndex]
				bReUse = true
			end
			if item then
				local index = i 
				if index > MaxItemCount then
					index = reUseIndex
				end
				item.TagBkg:SetPoint("topleft", "HomeChatMessagesMsg"..index, "topleft", 10, height)
				item.MsgTag:SetText(tag)
				if HomeSysMsg[i].filterInfo and HomeSysMsg[i].filterInfo.src_uin then
					local fontColor = HomeSysMsg[i].color or {r=255,g=255,b=255}
					G_VipNamePreFixEntrency(item.Content, HomeSysMsg[i].filterInfo.src_uin, HomeSysMsg[i].content, fontColor)
					-- item.Content:SetText(HomeSysMsg[i].content, HomeSysMsg[i].color.r, HomeSysMsg[i].color.g, HomeSysMsg[i].color.b)
				else
					if HomeSysMsg[i].color then
						item.Content:SetText(HomeSysMsg[i].content, HomeSysMsg[i].color.r, HomeSysMsg[i].color.g, HomeSysMsg[i].color.b)
					else
						item.Content:SetText(HomeSysMsg[i].content, 255, 255, 255)
					end
				end
				item.Item:SetSize(315, HomeSysMsg[i].height)
				local itemSlidingY = count <= 1 and math.max(slidingY-startY, 3) or slidingY-startY
				item.Item:SetPoint("topleft", "HomeChatContentFrame", "topleft", 0, itemSlidingY)
				item.Item:Show()
				SetHomeSysMsgUiAhpha(item, 1)
				if bReUse then
					reUseIndex = reUseIndex + 1
					if reUseIndex > MaxItemCount then
						reUseIndex = 1
					end
				end
			end
			slidingY = slidingY + HomeSysMsg[i].height + 5 -- +5为RichText行间距
		elseif HomeSysMsgUI[i] then
			--print("i = "..i.." not show ")
			HomeSysMsgUI[i].Content:SetText("", 255, 255, 255)
			HomeSysMsgUI[i].Item:Hide()
		end
	end
	--print("slidingY = "..slidingY)
	getglobal("HomeChatMessages"):setCurOffsetY(slidingY)

	--清理数据
	--保持数据为10个
	local uiCount = #HomeSysMsgUI
	local msgLen = #HomeSysMsg 
	local startIdx = msgLen - uiCount
	if startIdx > 0 then
		local tmpList = {}
		for i = startIdx+1, msgLen do
			table.insert(tmpList, HomeSysMsg[i])
		end
		HomeSysMsg = tmpList
	end
end


function ChatContentFrame_OnClick(parm)
	--获取房间的人员信息
	local userinfo = GetRoomUserInfo(parm or arg1)
	if next(userinfo) then
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common","miniui/miniworld/userInfoInteract"})
		GetInst("MiniUIManager"):OpenUI("main_userinfocard","miniui/miniworld/userInfoInteract","main_userinfocardAutoGen",userinfo)
	end
	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
		standReportEvent("1003", "CHAT_FLOAT", "Username", "click")
	else
		standReportEvent("1001", "CHAT_FLOAT", "Username", "click")
	end
end