-------------------------------------------------------UI改版相关接口------------------------------------2020/11/17
--新版大厅开关 --mark by hfb for new minilobby
local ApiIdsForNewMiniLobby = {
	1,		--官版Android
	79,		--微信公众号官包
	81,		--IP线官包
	99,		--国内移动先遣服
	199,	--国内pc先遣服
	399,	--海外移动先遣服
	499,	--海外pc先遣服
	--999,	--内网开发服
}
function isEnableNewMiniLobby()
	-- 这里开关目前的规划是跟版本走，不走后台配置
	-- do return false end -- 12.23版本先关掉，年后再安排
	-- -- mark by hfb for ab_test
	-- local abtest_old_ui_flag = getkv("abtest_old_ui_flag") --通过get_cf_info设定，没有取到则用上次缓存的
	-- if abtest_old_ui_flag == 1 then
	-- 	return false --使用旧版大厅
	-- end

	-- if ClientMgr.getApiId then
	-- 	local apiId = ClientMgr:getApiId();
	-- 	for _, id in ipairs(ApiIdsForNewMiniLobby) do
	-- 		if id == apiId then
	-- 			return true
	-- 		end
	-- 	end
	-- end
	-- return false
	return false;
end

local function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

-- 新fgui首页是否已经显示
function FguiMainIsVisible()
	if IsShowFguiMain() then
		return GetInst("MiniUIManager"):IsShown("mainAutoGen")
	end
	return false
end

-- 是否显示新fgui首页
function IsShowFguiMain()
	-- return true
	return GetInst("mainDataMgr") and GetInst("mainDataMgr"):GetSwitch() 
end

-- 是否显示新fgui首页--开始游戏
function IsShowFguiStartMain()
	-- return true
	return GetInst("mainDataMgr") and GetInst("mainDataMgr"):GetStartSwitch() or false
end

-- 注意：不建议在页面的周期函数OnHide()里面调用此函数
-- 显示主界面
function ShowMiniLobby()
	-- 防止其他页面在强制关闭的时候，又在hide周期函数里面调用此函数
	if returnLoginFrameRecord.backForce then
		return 
	end

	standReportEvent("9999","TECG_MAIN_PAGE","HomePageLoadRequest","page_active");
	if IsShowFguiMain() then
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/homepage", "miniui/miniworld/c_hpm"}) 
        GetInst("MiniUIManager"):OpenUI("main","miniui/miniworld/homepage","mainAutoGen", {fullScreen={Type="Normal", bkgName="img_home_background"}})
	else
		if IsUIStageEnable then
			if isEnableNewMiniLobby and isEnableNewMiniLobby() then
				UIStageDirector:openStage("MiniLobbyEx",
					nil,
					UIStageOpenWay.UI_STAGE_OPEN_WAY_CLEAR,
					{ui_type = UIFrameType.UI_FRAME_MVC},
					true,
					nil)
			else
				UIStageDirector:openStage("MiniLobbyFrame",
					nil,
					UIStageOpenWay.UI_STAGE_OPEN_WAY_CLEAR,
					{ui_type = UIFrameType.UI_FRAME_NORMAL},
					true,
					nil)
				getglobal("MiniLobbyFrameTopActivityRoomBox"):Show()
			end
			return -- 沙盒 UIStage 方式管理
		end

		if isEnableNewMiniLobby and isEnableNewMiniLobby() then
			if GetInst("UIManager"):GetCtrl("MiniLobbyEx","uiCtrlOpenList") then
				GetInst("UIManager"):GetCtrl("MiniLobbyEx"):Refresh()
			else
				GetInst("UIManager"):Open("MiniLobbyEx")
			end
		else
			getglobal("MiniLobbyFrame"):Show()
			getglobal("MiniLobbyFrameTopActivityRoomBox"):Show()
		end
	end


end

-- 隐藏主界面
function HideMiniLobby()
	if IsShowFguiMain() then
        GetInst("MiniUIManager"):HideUI("mainAutoGen")
	else
		if IsUIStageEnable then
			if isEnableNewMiniLobby and isEnableNewMiniLobby() then
				UIStageDirector:closeStage("MiniLobbyEx")
			else
				UIStageDirector:closeStage("MiniLobbyFrame")
			end
			return -- 沙盒 UIStage 方式管理
		end

		if GetInst("UIManager"):GetCtrl("MiniLobbyEx", "uiCtrlOpenList") then
			GetInst("UIManager"):Close("MiniLobbyEx")
		end

		if IsUIFrameShown("MiniLobbyFrame") then
			getglobal("MiniLobbyFrame"):Hide()
		end

		if IsUIFrameShown("CreatorFestival") then
			GetInst("UIManager"):Close("CreatorFestival");
		end
	end
end

-- 主界面是否显示中
function IsMiniLobbyShown()
	if isEnableNewMiniLobby and isEnableNewMiniLobby() then
		return IsUIFrameShown("MiniLobbyEx")
	else
		return IsUIFrameShown("MiniLobbyFrame") or FguiMainIsVisible()
	end
end

--更新游戏模式标题
function ShowMiniLobbyGameMode(sTitle, bShow)
	if isEnableNewMiniLobby() then
        --TODO 新UI的显示
        local miniLobbyFrame = getglobal("MiniLobbyEx")
		if miniLobbyFrame ~= nil and miniLobbyFrame:IsShown() then
			local gameModeUI    = getglobal("MiniLobbyExGameMode")
			local gameModeText  = getglobal("MiniLobbyExGameModeText")
			gameModeText:SetText(sTitle)
			gameModeText:SetTextColor(177,254,255)
			if bShow then
				gameModeUI:Show()
			else
				gameModeUI:Hide()
			end
		end
	else
		local miniLobbyFrame = getglobal("MiniLobbyFrame")
		-- if miniLobbyFrame ~= nil and miniLobbyFrame:IsShown() then
		if miniLobbyFrame ~= nil then
			local gameModeUI    = getglobal("MiniLobbyFrameNewGameMode")
			local gameModeText  = getglobal("MiniLobbyFrameNewGameModeText")
			local oldGameModeUI    = getglobal("MiniLobbyFrameGameMode")
			local olgGameModeText  = getglobal("MiniLobbyFrameGameModeText")
			if ns_version.opennewauth == 1 then
				gameModeText:SetText(sTitle)
				if bShow then
					gameModeUI:Show()
				else
					gameModeUI:Hide()
					GetInst("UIManager"):Close("CutDownTimer")
				end
				oldGameModeUI:Hide()
			else
				olgGameModeText:SetText(sTitle)
				olgGameModeText:SetTextColor(177,254,255)
				if bShow then
					oldGameModeUI:Show()
				else
					oldGameModeUI:Hide()
					GetInst("UIManager"):Close("CutDownTimer")
				end
				gameModeUI:Hide()
			end
		end
	end
end

--更新游戏模式倒计时
function SetMiniLobbyGameModeTick(tickStr)
	if isEnableNewMiniLobby() then
        --TODO 新UI的显示
        local miniLobbyEx =	getglobal("MiniLobbyEx")
		if miniLobbyEx ~= nil and miniLobbyEx:IsShown() then
			local time = getglobal("MiniLobbyExGameModeTime")
			time:SetText(tickStr)
		end
	else
		local miniLobbyFrame =	getglobal("MiniLobbyFrame");
		if miniLobbyFrame ~= nil and miniLobbyFrame:IsShown() then
			if ns_version.opennewauth == 1 then
				local time = getglobal("MiniLobbyFrameNewGameModeTime");
				time:SetText(tickStr);
			else
				local time = getglobal("MiniLobbyFrameGameModeTime");
				time:SetText(tickStr);
			end
		end
	end
end

--获取主页滚动文字frame
function GetMiniLobbyNoticeTextFrame()
	if isEnableNewMiniLobby() then
		--TODO 新大厅的组件
		return getglobal("MiniLobbyExNoticeFrameNoticeText");
	else
		return getglobal("MiniLobbyFrameBottomNoticeText");
	end
end

--显示主页滚动文字
function ActiveMiniLobbyRotateNotice()
	if isEnableNewMiniLobby() then
		--TODO 新大厅的滚动文字显示
		if GetInst("UIManager"):GetCtrl("MiniLobbyEx") then --加个判断，没打开过就不要执行相应的逻辑
			GetInst("UIManager"):GetCtrl("MiniLobbyEx"):ActiveMiniLobbyRotateNotice()
		end
	else
		activeMiniLobbyRotateNitice()
	end
end

--显示主页QQvip按钮
function ShowMiniLobbyQQVipBtn()
	if isEnableNewMiniLobby() then
        --TODO 新大厅按钮
        getglobal("MiniLobbyExTopQQVipBtn"):Show()
	else
		getglobal("MiniLobbyFrameTopQQVipBtn"):Show()
	end
end
--隐藏主页QQvip按钮
function HideMiniLobbyQQVipBtn()
	if isEnableNewMiniLobby() then
        --TODO 新大厅按钮
        getglobal("MiniLobbyExTopQQVipBtn"):Hide()
	else
		getglobal("MiniLobbyFrameTopQQVipBtn"):Hide()
	end
end

--显示主页QQvip红点
function ShowMiniLobbyQQVipBtnRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅按钮
        getglobal("MiniLobbyExTopQQVipBtnRedTag"):Show()
	else
		getglobal("MiniLobbyFrameTopQQVipBtnRedTag"):Show()
	end
end
--隐藏主页QQvip红点
function HideMiniLobbyQQVipBtnRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅按钮
        getglobal("MiniLobbyExTopQQVipBtnRedTag"):Hide()
	else
		getglobal("MiniLobbyFrameTopQQVipBtnRedTag"):Hide()
	end
end

--显示主页QQBuLuo按钮
function ShowMiniLobbyQQBuLuoBtn()
	if isEnableNewMiniLobby() then
        --TODO 新大厅按钮
        getglobal("MiniLobbyExTopQQBuLuoBtn"):Show()
	else
		getglobal("MiniLobbyFrameTopQQBuLuoBtn"):Show()
	end
end
--隐藏主页QQBuLuo按钮
function HideMiniLobbyQQBuLuoBtn()
	if isEnableNewMiniLobby() then
        --TODO 新大厅按钮
        getglobal("MiniLobbyExTopQQBuLuoBtn"):Hide()
	else
		getglobal("MiniLobbyFrameTopQQBuLuoBtn"):Hide()
	end
end

--显示主页社区按钮
function ShowMiniLobbyCommunityBtn()
	if isEnableNewMiniLobby() then
        --TODO 新大厅按钮
		GetInst("UIManager"):GetCtrl("MiniLobbyEx"):CheckTopCommunityShow(true)
	else
		getglobal("MiniLobbyFrameBottomCommunity"):Show()
        getglobal("MiniLobbyFrameBottomCommunity"):SetPoint("right", "MiniLobbyFrameBottomShop", "left", 0, 0)
	end
end

--结束主页引导
function CloseMiniLobbyGuide()
	if isEnableNewMiniLobby() then
		--TODO 新大厅结束引导
		if GetInst("UIManager"):GetCtrl("MiniLobbyEx") then
			GetInst("UIManager"):GetCtrl("MiniLobbyEx"):GuideContentCloseBtn_OnClick()
		end
	else
		if MiniLobbyFrameGuideContentCloseBtn_OnClick then
			MiniLobbyFrameGuideContentCloseBtn_OnClick()
		end		
	end
end

--显示主页活动红点
function ShowMiniLobbyActivityRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅红点
        getglobal("MiniLobbyExRightActivityRedTag"):Show()
	else
		getglobal("MiniLobbyFrameTopActivityRedTag"):Show()
	end
end
--隐藏主页活动红点
function HideMiniLobbyActivityRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅红点
        getglobal("MiniLobbyExRightActivityRedTag"):Hide()
	else
		getglobal("MiniLobbyFrameTopActivityRedTag"):Hide()
	end
end

--显示主页ChannelReward红点
function ShowMiniLobbyChannelRewardRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅红点
        getglobal("MiniLobbyExTopChannelRewardBtnRedTag"):Show()
	else
		getglobal("MiniLobbyFrameTopChannelRewardBtnRedTag"):Show()
	end
end
--隐藏主页ChannelReward红点
function HideMiniLobbyChannelRewardRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅红点
        getglobal("MiniLobbyExTopChannelRewardBtnRedTag"):Hide()
	else
		getglobal("MiniLobbyFrameTopChannelRewardBtnRedTag"):Hide()
	end
end

--显示主页ActivityRoomBoxSignBtn红点
function ShowMiniLobbyRoomBoxSignRedTag()
	if isEnableNewMiniLobby() or IsShowFguiMain() then
        -- 新版大厅不处理
	else
		getglobal("MiniLobbyFrameTopActivityRoomBoxSignBtnRedTag"):Show()
	end
end
--隐藏主页ActivityRoomBoxSignBtn红点
function HideMiniLobbyRoomBoxSignRedTag()
	if isEnableNewMiniLobby() or IsShowFguiMain() then
        -- 新版大厅不处理
	else
		getglobal("MiniLobbyFrameTopActivityRoomBoxSignBtnRedTag"):Hide()
	end
end

--显示主页ActivityRoomBoxTreasuryBtn红点
function ShowMiniLobbyRoomBoxTreasuryRedTag()
	if isEnableNewMiniLobby() or IsShowFguiMain() then
       -- 新版大厅不处理
	else
		getglobal("MiniLobbyFrameTopActivityRoomBoxTreasuryBtnRedTag"):Show()
	end
end
--隐藏主页ActivityRoomBoxTreasuryBtn红点
function HideMiniLobbyRoomBoxTreasuryRedTag()
	if isEnableNewMiniLobby() or IsShowFguiMain() then
        -- 新版大厅不处理
	else
		getglobal("MiniLobbyFrameTopActivityRoomBoxTreasuryBtnRedTag"):Hide()
	end
end

--显示主页ActivityRoomBoxWelfareBtn红点
function ShowMiniLobbyRoomBoxWelfareRedTag()
	if isEnableNewMiniLobby() then
        -- 新版大厅不处理
	else
		getglobal("MiniLobbyFrameTopActivityRoomBoxWelfareBtnRedTag"):Show()
	end
end
--隐藏主页ActivityRoomBoxWelfareBtn红点
function HideMiniLobbyRoomBoxWelfareRedTag()
	if isEnableNewMiniLobby() then
        -- 新版大厅不处理
	else
		getglobal("MiniLobbyFrameTopActivityRoomBoxWelfareBtnRedTag"):Hide()
	end
end

--显示主页Buddy红点
function ShowMiniLobbyBuddyRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅红点
        getglobal("MiniLobbyExTopBuddyRedTag"):Show()
	else
		getglobal("MiniLobbyFrameBottomBuddyRedTag"):Show()
	end
	getglobal("MiniLobbyFrameBottomBuddyReward"):Show()
end
--隐藏主页Buddy红点
function HideMiniLobbyBuddyRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅红点
        getglobal("MiniLobbyExTopBuddyRedTag"):Hide()
	else
		getglobal("MiniLobbyFrameBottomBuddyRedTag"):Hide()
	end
	getglobal("MiniLobbyFrameBottomBuddyReward"):Hide()
end

--更新主页社区按钮的显示
function CheckMiniLobbyCommunityShow()
	if isEnableNewMiniLobby() then
		--TODO 新大厅社区按钮
		if GetInst("UIManager"):GetCtrl("MiniLobbyEx") then --加个判断，没打开过就不要执行相应的逻辑
			GetInst("UIManager"):GetCtrl("MiniLobbyEx"):CheckTopCommunityShow()
		end
	else
		if CheckBottomCommunityShow then
			CheckBottomCommunityShow()
		end
	end
end

--更新主页订阅按钮的显示
function CheckMiniLobbySubscribeUpShow()
	if isEnableNewMiniLobby() then
		--TODO 新大厅社区按钮
		if GetInst("UIManager"):GetCtrl("MiniLobbyEx") then --加个判断，没打开过就不要执行相应的逻辑
			GetInst("UIManager"):GetCtrl("MiniLobbyEx"):TopSubscribeUpShow()
		end
	else
		MiniLobbyFrameBottomSubscribeUpShow()
	end
end

--显示网络模式（true单机，false联网)
function ShowMiniLobbyStandAloneMode(status)
	if isEnableNewMiniLobby() then
        --TODO 新大厅的wifi显示
        local LobbyNetworkText  = getglobal("MiniLobbyExBottomNetworkText")
        local LobbyNetworkBkg   = getglobal("MiniLobbyExBottomNetworkBkg")
        local LobbyNetwork      = getglobal("MiniLobbyExBottomNetwork")
		if status == true then
			LobbyNetworkText:Show()
            LobbyNetworkBkg:Hide()
            LobbyNetwork:Hide()
		else
			LobbyNetworkText:Hide()
            LobbyNetworkBkg:Show()
            LobbyNetwork:Show()
		end
	else
		local LobbyNetworkText  = getglobal("MiniLobbyFrameBottomNetworkText")
		local LobbyNetworkBkg   = getglobal("MiniLobbyFrameBottomNetworkBkg")
		if status == true then
			LobbyNetworkText:Show()
			LobbyNetworkBkg:Hide()
		else
			LobbyNetworkText:Hide()
			LobbyNetworkBkg:Show()
		end
	end
end

--设置迷你币
function SetMiniLobbyMiniCoinNum(num)
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        getglobal("MiniLobbyExTopMiniCoinNum"):SetText(num)
	else
		getglobal("MiniLobbyFrameTopMiniCoinNum"):SetText(num)
	end
end
--设置迷你豆
function SetMiniLobbyMiniBeanNum(num)
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        getglobal("MiniLobbyExTopMiniBeanNum"):SetText(num)
	else
		getglobal("MiniLobbyFrameTopMiniBeanNum"):SetText(num)
	end
end

--刷新底部按钮
function UpdateMiniLobbyBottomBtnState()
	if isEnableNewMiniLobby() then
		--TODO 新大厅
		GetInst("UIManager"):GetCtrl("MiniLobbyEx"):UpdateMiniLobbyExTopBtnState()
	else
		UpdateBottomBtnState()
	end
end

--显示回流按钮？
function ShowMiniLobbyRoomBoxBtn()
	if isEnableNewMiniLobby() then
		-- 新版大厅不处理
	   	if GetInst("UIManager"):GetCtrl("MiniLobbyEx") then --加个判断，没打开过就不要执行相应的逻辑
			GetInst("UIManager"):GetCtrl("MiniLobbyEx"):CheckComeBackShow()
	   	end
	else
		getglobal("MiniLobbyFrameTopActivityRoomBox"):Show()
	end
end

--获取玩家名字richText
function GetMiniLobbyRoleInfoNameRichTextFrame()
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        return getglobal("MiniLobbyExTopRoleInfoName")
	else
		return getglobal("MiniLobbyFrameTopRoleInfoName")
	end
end


--获取玩家头像frame
function GetMiniLobbyRoleInfoIconFrame()
	if IsShowFguiMain() then
		local ctrl = GetInst("MiniUIManager"):GetCtrl("main")
		if ctrl then
			return ctrl:GetHeadIcon()
		end
	end
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        return getglobal("MiniLobbyExTopRoleInfoHeadIcon")
	else
		return getglobal("MiniLobbyFrameTopRoleInfoHeadIcon")
	end
end

--获取玩家头像框
function GetFguiMainHeadBoard()
	if IsShowFguiMain() then
		local ctrl = GetInst("MiniUIManager"):GetCtrl("main")
		if ctrl then
			return ctrl:GetHeadBoard()
		end
	end
end

--设置头像
function SetMiniLobbyRoleInfoIcon(texturePath)
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        return getglobal("MiniLobbyExTopRoleInfoHeadIcon"):SetTexture(texturePath)
	else
		return getglobal("MiniLobbyFrameTopRoleInfoHeadIcon"):SetTexture(texturePath)
	end
end

--获取玩家头像icon框名字
function GetMiniLobbyRoleInfoIconFrameName()
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        return 'MiniLobbyExTopRoleInfoHeadIcon'
	else
		return 'MiniLobbyFrameTopRoleInfoHeadIcon'
	end
end

--获取玩家头像框名字
function GetMiniLobbyRoleInfoHeadFrameName()
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        return 'MiniLobbyExTopRoleInfoHead'
	else
		return 'MiniLobbyFrameTopRoleInfoHead'
	end
end

--获取玩家头像Normal框名字
function GetMiniLobbyRoleInfoIconNormalFrameName()
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        return 'MiniLobbyExTopRoleInfoHeadNormal'
	else
		return 'MiniLobbyFrameTopRoleInfoHeadNormal'
	end
end

--获取玩家头像PushedBG框名字
function GetMiniLobbyRoleInfoIconPushedBGFrameName()
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        return 'MiniLobbyExTopRoleInfoHeadPushedBG'
	else
		return 'MiniLobbyFrameTopRoleInfoHeadPushedBG'
	end
end

--显示QQBlueVip
function ShowMiniLobbyQQBlueVipBtn()
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        getglobal("MiniLobbyExTopQQBlueVipBtn"):Show()
	else
		getglobal("MiniLobbyFrameTopQQBlueVipBtn"):Show()
	end
end

--隐藏QQBlueVip
function HideMiniLobbyQQBlueVipBtn()
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        getglobal("MiniLobbyExTopQQBlueVipBtn"):Hide()
	else
		getglobal("MiniLobbyFrameTopQQBlueVipBtn"):Hide()
	end
end

--设置QQBlueVip背景图
function SetMiniLobbyQQBlueVipBtnBg(normal, pushedbg)
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        getglobal("MiniLobbyExTopQQBlueVipBtnNormal"):SetTexUV(normal)
		getglobal("MiniLobbyExTopQQBlueVipBtnPushedBG"):SetTexUV(pushedbg)
	else
		getglobal("MiniLobbyFrameTopQQBlueVipBtnNormal"):SetTexUV(normal)
		getglobal("MiniLobbyFrameTopQQBlueVipBtnPushedBG"):SetTexUV(pushedbg)
	end
end

function SetMiniLobbyMailRedTagNumber(notread_mails)
	local notreadMailStr = ""
	getglobal("MiniLobbyFrameTopMailRedTag"):SetTextureHuiresXml("ui/mobile/texture0/common.xml")
	if notread_mails <= 9 then
		notreadMailStr = tostring(notread_mails)
		getglobal("MiniLobbyFrameTopMailRedTag"):SetTexUV("img_dot_tips.png");
		--getglobal("MiniLobbyFrameTopMailRedTag"):SetTexture("ui/mobile/texture0/common/img_dot_tips.png",true);
		getglobal("MiniLobbyFrameTopMailRedTag"):SetWidth(16)
	elseif notread_mails <= 99 then
		notreadMailStr = tostring(notread_mails)
		getglobal("MiniLobbyFrameTopMailRedTag"):SetTexUV("img_num_tips.png");
		--getglobal("MiniLobbyFrameTopMailRedTag"):SetTexture("ui/mobile/texture0/common/img_num_tips.png",true);
		getglobal("MiniLobbyFrameTopMailRedTag"):SetWidth(24)
	else
		notreadMailStr = "99+"
		getglobal("MiniLobbyFrameTopMailRedTag"):SetTexUV("img_num_tips.png");
		--getglobal("MiniLobbyFrameTopMailRedTag"):SetTexture("ui/mobile/texture0/common/img_num_tips.png",true);
		getglobal("MiniLobbyFrameTopMailRedTag"):SetWidth(32)
	end
	getglobal("MiniLobbyFrameTopMailReward"):SetText(notreadMailStr)
end

--显示主页mail红点
function ShowMiniLobbyMailRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅红点
        getglobal("MiniLobbyExTopMailRedTag"):Show()
	else
		getglobal("MiniLobbyFrameTopMailRedTag"):Show()
	end
	getglobal("MiniLobbyFrameTopMailReward"):Show()
end
--隐藏主页mail红点
function HideMiniLobbyMailRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅红点
        getglobal("MiniLobbyExTopMailRedTag"):Hide()
	else
		getglobal("MiniLobbyFrameTopMailRedTag"):Hide()
	end
	getglobal("MiniLobbyFrameTopMailReward"):Hide()
end

--按位存储的头像红点值（不为0则显示红点）
local HeadPosting_RedValue = 0

--显示主页HeadPosting红点(bit红点位 0帖子回复 1装扮收集)
function ShowMiniLobbyHeadPostingRedTag(bit)
	HeadPosting_RedValue = LuaInterface:bor(HeadPosting_RedValue, LuaInterface:lshift(1,bit))

	if isEnableNewMiniLobby() then
		--TODO 新大厅红点
		if not getglobal("MiniLobbyExTopRoleInfoHeadPostingRedTag"):IsShown() then
			getglobal("MiniLobbyExTopRoleInfoHeadPostingRedTag"):Show()
		end
	else
		if not getglobal("MiniLobbyFrameTopRoleInfoHeadPostingRedTag"):IsShown() then
			getglobal("MiniLobbyFrameTopRoleInfoHeadPostingRedTag"):Show()
		end
	end
end

--隐藏主页HeadPosting红点(bit红点位 0帖子回复 1装扮收集)
function HideMiniLobbyHeadPostingRedTag(bit)
	HeadPosting_RedValue = LuaInterface:band(HeadPosting_RedValue, LuaInterface:bnot(LuaInterface:lshift(1,bit)))

	if HeadPosting_RedValue == 0 then
		if isEnableNewMiniLobby() then
			--TODO 新大厅红点
			if getglobal("MiniLobbyExTopRoleInfoHeadPostingRedTag"):IsShown() then
				getglobal("MiniLobbyExTopRoleInfoHeadPostingRedTag"):Hide()
			end
		else
			if getglobal("MiniLobbyFrameTopRoleInfoHeadPostingRedTag"):IsShown() then
				getglobal("MiniLobbyFrameTopRoleInfoHeadPostingRedTag"):Hide()
				getglobal("MiniLobbyFrameTopRoleInfoHeadMsgCount"):Hide();
			end
		end
	end
end

--按位存储的商城红点值（不为0则显示红点）
local Shop_RedValue = 0
--取得主页商城红点值
function GetMiniLobbyShopRedValue()
	return Shop_RedValue
end
function RefreshMiniLobbyShopRedTag()
	if Shop_RedValue > 0 then
		ShowMiniLobbyShopRedTag(Shop_RedValue)
	else
		HideMiniLobbyShopRedTag(Shop_RedValue)
	end
end
--显示主页BottomShop红点(bit红点位 由 ShopCtrl.define.tabType 决定)
function ShowMiniLobbyShopRedTag(bit)
	local oldValue = Shop_RedValue
	Shop_RedValue = LuaInterface:bor(oldValue, LuaInterface:lshift(1,bit))

	if oldValue == 0 and Shop_RedValue > 0 then
		if isEnableNewMiniLobby() then
			--TODO 新大厅红点
			if not Shop_RedTagIsShown then
				getglobal("MiniLobbyExRightShopRedTag"):Show()
			end
		else
			if not Shop_RedTagIsShown then
				getglobal("MiniLobbyFrameBottomShopRedTag"):Show()
			end
		end
	end
end

--隐藏主页BottomShop红点(bit红点位 由 ShopCtrl.define.tabType 决定)
function HideMiniLobbyShopRedTag(bit)
	local oldValue = Shop_RedValue
	Shop_RedValue = LuaInterface:band(oldValue, LuaInterface:bnot(LuaInterface:lshift(1,bit)))

	if oldValue > 0 and Shop_RedValue == 0 then
		if isEnableNewMiniLobby() then
			--TODO 新大厅红点
			getglobal("MiniLobbyExRightShopRedTag"):Hide()
		else
			getglobal("MiniLobbyFrameBottomShopRedTag"):Hide()
		end
	end
end

--重置玩家头像
function ResetMiniLobbyRoleInfoIcon()
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        HeadCtrl:CurrentHeadIcon('MiniLobbyExTopRoleInfoHeadIcon' )
		HeadFrameCtrl:CurrentHeadFrame('MiniLobbyExTopRoleInfoHeadNormal')
		HeadFrameCtrl:CurrentHeadFrame('MiniLobbyExTopRoleInfoHeadPushedBG')
	else
		HeadCtrl:CurrentHeadIcon('MiniLobbyFrameTopRoleInfoHeadIcon' )
		HeadFrameCtrl:CurrentHeadFrame('MiniLobbyFrameTopRoleInfoHeadNormal')
		HeadFrameCtrl:CurrentHeadFrame('MiniLobbyFrameTopRoleInfoHeadPushedBG')
	end
end

--获取玩家头像成就红点frame
function GetMiniLobbyRoleInfoHeadArchiveRedTagFrame()
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        return getglobal("MiniLobbyExTopRoleInfoHeadAchieveRedTag")
	else
		return getglobal("MiniLobbyFrameTopRoleInfoHeadAchieveRedTag")
	end
end

--刷新新Fgui主页头像红点
function RefreshFguiMainHeadReadTag(isShow)
	if IsShowFguiMain() then
		local node = GetInst("MiniUIManager"):GetUI("mainAutoGen")
		if node and node.ctrl then
			local redTag = node.ctrl.view.root:getChildByPath("personal_avatar_name_id.tips_reddot")
			if redTag then
				redTag:setVisible(isShow)
			end
		end
	end
end

--刷新新Fgui主页悦享卡红点
function RefreshFguiMainBattlePassReadTag(isShow)
	if IsShowFguiMain() then
		local node = GetInst("MiniUIManager"):GetUI("mainAutoGen")
		if node and node.ctrl then
			local redTag = node.ctrl.view.root:getChildByPath("btn_battlepass.tips_reddot")
			if redTag then
				redTag:setVisible(isShow)
			end
		end
	end
end

--刷新主页迷你币
function UpdateMinilobbyMiniCoin()
	if isEnableNewMiniLobby() then
		--TODO 新大厅
		local ctrl = GetInst("UIManager"):GetCtrl("MiniLobbyEx")
		if ctrl then
			ctrl:UpdateMiniBeanOrCoin("MiniLobbyExTopMiniCoin")
		end
	else
		NewUpdateMiniBeanOrCoin("MiniLobbyFrameTopMiniCoin")
	end
end

--刷新主页迷你豆
function UpdateMinilobbyMiniBean()
	if isEnableNewMiniLobby() then
		--TODO 新大厅
		local ctrl = GetInst("UIManager"):GetCtrl("MiniLobbyEx")
		if ctrl then
			ctrl:UpdateMiniBeanOrCoin("MiniLobbyExTopMiniBean")
		end
	else
		NewUpdateMiniBeanOrCoin("MiniLobbyFrameTopMiniBean")
	end
end

--隐藏主页的皮肤更新提示
function HideMiniLobbySkinUpdateTip()
	if isEnableNewMiniLobby() then
		--TODO 新大厅不需要？
	else
		getglobal("MiniLobbyFrameBottomSkinUpdateTip"):Hide()
	end
end

--布局排列7k7kTips
function LayoutMiniLobby7k7kTips()
	if isEnableNewMiniLobby() then
		--TODO 新大厅
	else
		getglobal("Vip7k7kBtnTipsPC"):SetPoint("topright", "MiniLobbyFrameTop7k7kBlueVipBtn", "center", 0, 0);
	end
end

--获取7k7kBlueVip红点
function GetMiniLobby7k7kBlueBipBtnRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        return getglobal("MiniLobbyExTop7k7kBlueVipBtnRedTag")
	else
		return getglobal("MiniLobbyFrameTop7k7kBlueVipBtnRedTag")
	end
end

--布局排列QQTips
function LayoutMiniLobbyQQTips()
	if isEnableNewMiniLobby() then
		--TODO 新大厅
	else
		getglobal("VipQQHelpTipsMobileCont"):SetPoint("topright", "MiniLobbyFrameTopQQBlueVipBtn", "center", 0, 0);
	end
end

--隐藏实名按钮
function HideMiniLobbyRoomBoxRealNameBtn()
	if isEnableNewMiniLobby() then
        -- 新版大厅不处理
	else
		getglobal("MiniLobbyFrameTopActivityRoomBoxRealNameBtn"):Hide()
	end
end

--隐藏Gift红点
function HideMiniLobbyGiftRedTag()
	if isEnableNewMiniLobby() then
        --TODO 新大厅
        getglobal("MiniLobbyExTopGiftRedTag"):Hide()
	else
		getglobal("MiniLobbyFrameTopGiftRedTag"):Hide()
	end
end

-- 设置密码按钮红点
function UpdateResetPasswordRedTag()
	local tsSetBtn = getglobal("MiniLobbyFrameTopSettingRedTag")
	if isEnableNewMiniLobby() then
        --TODO 新大厅
		tsSetBtn = getglobal("MiniLobbyExTopSettingRedTag")
	else
		tsSetBtn = getglobal("MiniLobbyFrameTopSettingRedTag")
	end
	
	local aSetBtn = getglobal("SetMenuFrameAccountSetBtnRedTag")
	if not getkv("reset_password_red") and not if_close_red_point_tips(1) then
		tsSetBtn:Show()
		aSetBtn:Show()
	else
		tsSetBtn:Hide()
		aSetBtn:Hide()
	end
end

function GetLobbyRoleView()
    if isEnableNewMiniLobby() then
        getglobal("MiniLobbyExRoleView")
    else
        getglobal("LobbyFrameRoleView")
    end
end

--[[-------------------------------------------------大厅按钮跳转接口---------------------------------------------]]
-- 跳转到迷你豆兑换
function JumpToBeanConvertFrame()
    if IsStandAloneMode() then return end
	if getglobal("BeanConvertFrame"):IsShown() then
		getglobal("BeanConvertFrame"):Hide()
	else
		getglobal("BeanConvertFrame"):Show()
	end
end

-- 跳转到迷你币[Desc2]（商城[Desc2]）
function JumpToMiniCoinRechargeFrame()
    if IsStandAloneMode() then return end

	if if_check_bind_email_recharge() and AccountManager.hasBindedEmail then
		local result = AccountManager:hasBindedEmail()
		if result == 0 then
			--未绑定邮箱
			-- getglobal("BindingPhoneEmailFrame"):Show();
			print("luoshun BindingPhoneEmailFrame hasBindedEmail: ", result)
			OpenNewAlertPhoneBindPanel("Email", "Bind")
		elseif result == -1 then
			--无法获取到信息
			print("BindingPhoneEmailFrame hasBindedEmail: ", result)
			-- Log("BindingPhoneEmailFrame 无法获取到信息");
		elseif result == 1 then
			--已绑定邮箱
			print("BindingPhoneEmailFrame hasBindedEmail: ", result)
			-- Log("BindingPhoneEmailFrame 已绑定邮箱");
		end
	end

	--无论是否新版大厅，前往[Desc2]均隐藏大厅
    -- if isEnableNewMiniLobby() then
        HideMiniLobby()
        --新商城
        ShopJumpTabView(7, 1)
    -- else
    --     ShopJumpTabView(7)
    -- end
end

-- 跳转到设置
function JumpToSettingFrame()
    getglobal("SetMenuFrame"):Show()
end

-- 跳转到邮箱
function JumpToMailFrame()
	JumpToMessageCenter()
end

function JumpToMessageCenter()
	if IsStandAloneMode() then return end

	if MiniUI_MessageCneter then
		MiniUI_MessageCneter.ShowUI()
	end
end

-- 跳转到活动
function JumpToActivityFrame()
    if IsStandAloneMode() then return end

	threadpool:work(function()
		-- 2022/03.30 codeby fym 获取活动场景使用到的广告数据
		ad_data_new.getAdInfoBySence(ad_data_new.allSenceIdList.activity)
	end)

	if IsShowFguiMain() then
		if getglobal("ActivityFrame"):IsShown() then
			--opened
		else
			if ActivityMainCtrl.def and ActivityMainCtrl.def.type then
				ActivityMainCtrl:Active(ActivityMainCtrl.def.type.activity,false)
			end
		end
	else
		local noticeFrame = getglobal("SiftFrame");
		if noticeFrame:IsShown() then
			--opened
		else
			if ActivityMainCtrl.def and ActivityMainCtrl.def.type then
				ActivityMainCtrl:Active(ActivityMainCtrl.def.type.sift,false)
			end 
		end
	end

    -- luoshun 从OPPO和VIVO游戏中心启动游戏时给予奖励
    if ClientMgr.getApiId then
        local apiId = ClientMgr:getApiId();
        if (apiId == 13 or apiId == 36 or apiId == 12) and SdkManager:isSdkToStartGame() or (apiId == 21 and openYybUrlToGetgift) then
            WWW_ma_start_game_out(apiId)
        end
    end
end

-- 跳转到礼包
function JumpToGiftFrame()
    if IsStandAloneMode() then return end
    --前往礼包页面
    ShopJumpTabView(9, 1)
end

-- 跳转到官方福利
function JumpToGuanBanFuliFrame()
    if IsStandAloneMode() then return end
	GetInst("UIManager"):Open("OfficialRewardCenter")
	standReportEvent("8", "PRIVILEGE_TOP", "-", "view")
end

-- 跳转到手Q
function JumpToShouQLink()
    local shouq_config = ns_version.qqvip
    if shouq_config and shouq_config.open == 1 then
        local url = shouq_config.action_url;
        open_http_link(url);
    end
end

-- 跳转到QQ会员
function JumpToQQVIPFrame()
    if not AccountManager:getNoviceGuideState("qqvip") then
		AccountManager:setNoviceGuideState("qqvip", true);
	end

	if next(vip.QQUserInfo) == nil then	--没有会员信息
		-- ShowLoadLoopFrame3(true,"auto");
        ShowLoadLoopFrame3(true, "file:minilobbyinterface -- func:JumpToQQVIPFrame")
		WaitQQUserInfo = true;
		WaitQQLoginResult = 0;
		WaitQQVipRewardState = true;
		local index = 0;
		if not SdkManager:checkQQLogin() then	--没登录	
			for i=1, 10 do
				index = i;
				if WaitQQLoginResult > 0 then
					if WaitQQLoginResult == 1 then		--登录失败
						Log("kekeke QQLogin is fail");
						ShowGameTips(GetS(1166), 3);
						ShowVipQQFrame();
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
		index = 0;
		for i=1, 10 do							--等用户信息
			index = i;
			if not WaitQQUserInfo then
				break;
			end
			threadpool:wait(0.5);
		end
	
		Log("kekeke QQUesrinfo success:"..index);

		if next(vip.QQUserInfo) == nil then	--还是没有会员信息
			ShowGameTips(GetS(1166), 3);
			Log("kekeke QQUesrinfo is nil");
		else
			Log("kekeke Vip is_qq_vip:"..vip.QQUserInfo.is_qq_vip);
			Log("kekeke Vip is_qq_year_vip:"..vip.QQUserInfo.is_qq_year_vip);
			Log("kekeke Vip is_svip:"..vip.QQUserInfo.is_svip);
	
			index = 0;
			if vip.isQQVip then 
				for i=1, 3 do					--等待奖励状态结果
					index = i;
					if not WaitQQVipRewardState then
						break;
					end
					threadpool:wait(1);
				end
			end
		end

		ShowVipQQFrame();
		-- HideLoadLoopFrame3();
        ShowLoadLoopFrame3(false)
	else
		ShowVipQQFrame();
	end
end

-- 跳转到4399登录
function JumpTo4399LoginFrame()
    if AccountManager:isBindTPAccount() or IsTPLogin() then
		getglobal("Login4399Frame"):Show();
	else
		TP4399LoginType = 1;
		SdkManager:sdkLogin();
	end
end

-- 跳转到应用宝
function JumpToYYBForumLink()
    local apiId = ClientMgr:getApiId()
	local forum_jump = ns_version.forum_jump
	-- local url = "https://imgcache.qq.com/club/themes/mobile/middle_page/index.html?url=https%3A%2F%2Fqzs.qq.com%2Fopen%2Fmobile%2Ftransfer-page%2Findex.html%3Fid%3D3%26dest%3Dtmast%253A%252F%252Fappdetails%253Fselflink%253D1%2526appid%253D42286397%2526extradata%253Dscene%253Aplayingcard%26via%3DFBI.ACT.H5.TRANSFER3_MARKET_YINGYONGBAO_COM.TENCENT.ANDROID.QQDOWNLOADER_5848_QDTQ";
	if forum_jump and check_apiid_ver_conditions(forum_jump) and forum_jump[apiId] then
		local url = forum_jump[apiId]
		http_openBrowserUrl(url, 1)
	else
		SdkManager:sdkForum();
	end
end

-- 跳转到QQ部落
function JumpToQQBuLuo()
	if SdkManager:openQQBuLuo() then
		WWW_ma_qq_member_action('nil', 'qq_member_buluo', 1, ns_ma.func.download_callback_empty)
	end
end

-- 跳转到渠道奖励
function JumpToChannelReward()
    if ClientMgr.getApiId then
		local apiId = ClientMgr:getApiId()
		if (apiId == 13 or apiId == 36 or apiId == 12) and SdkManager:isSdkToStartGame() or (apiId == 21 and openYybUrlToGetgift) then
			WWW_ma_start_game_out(apiId)
		end
	end

	getglobal("ChannelRewardFrame"):Show()
end

-- 跳转到游戏存档
function JumpToLocalMap()
    checkS2tAuth()

	if CreateMapGuideStep == 1 then
		CreateMapGuideStep = 2
	end
	--新手强制引导结束
	local guideStep = GetGuideStep()
	if guideStep == 7 then
		SetGuideStep(nil)
	end 
	if not IsUIStageEnable then
		HideMiniLobby() --UIStage 管理方式可以不用主动关闭大厅
	end
	ShowLobby();
end

-- 跳转到联机大厅
function JumpToMultiplayer(params)
    if IsStandAloneMode() then return end
	checkS2tAuth();
	RequestLoginRoomServer(params);
end

-- 跳转到迷你工坊
function JumpToMiniWorks()
    if IsStandAloneMode() then return end

	-- 如果联机房的倒计时还在，关闭它
	if HasUIFrame("RoomFrameTimer") then
		getglobal("RoomFrameTimer"):Hide()
	end
	
	local openOldMiniworks = function ()
		-- getglobal("MiniLobbyFrame"):Hide();
		HideMiniLobby() --mark by hfb for new minilobby
	
		if not getglobal("MiniWorksFrame"):IsShown() then
			getglobal("MiniWorksFrame"):Show();
			if WorksArchiveMsgCheck.isdetail then
				GetInst("UIManager"):Open("MiniWorksCommendDetail", {commendtype = WorksArchiveMsgCheck.CommendType})
				ShowMiniWorksMainDetail(true)
				WorksArchiveMsgCheck.isdetail = false
			elseif HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
				ShowMiniWorksMainDetail(true)
			end
		end
	end
	
	-- TODO：0427-改成原有接口直接进老的工坊
	-- if IsUserOuterChecker(AccountManager:getUin()) then
	-- 	openOldMiniworks()
	-- else
	-- 	GetInst("CreationCenterDataMgr"):ReqCreatorCenterCfg(
	-- 		function (isOpenNewCC)
	-- 			if isOpenNewCC then 
	-- 				GetInst("CreationCenterInterface"):OpenUI()
	-- 			else 
	-- 				openOldMiniworks()
	-- 			end 
	-- 		end
	-- 	)
	-- end
	
	openOldMiniworks()
end

-- TODO：0427-新增调整创作中心
-- 跳转创作中心
function JumpToCreationCenter(param)
    if IsStandAloneMode() then return end

	-- 如果联机房的倒计时还在，关闭它
	if HasUIFrame("RoomFrameTimer") then
		getglobal("RoomFrameTimer"):Hide()
	end
	
	local openOldMiniworks = function ()
		-- getglobal("MiniLobbyFrame"):Hide();
		HideMiniLobby() --mark by hfb for new minilobby
	
		if not getglobal("MiniWorksFrame"):IsShown() then
			getglobal("MiniWorksFrame"):Show();
			if WorksArchiveMsgCheck.isdetail then
				GetInst("UIManager"):Open("MiniWorksCommendDetail", {commendtype = WorksArchiveMsgCheck.CommendType})
				ShowMiniWorksMainDetail(true)
				WorksArchiveMsgCheck.isdetail = false
			elseif HasUIFrame("MiniWorksCommendDetail") and getglobal("MiniWorksCommendDetail"):IsShown() then
				ShowMiniWorksMainDetail(true)
			end
		end
	end
	
	if IsUserOuterChecker(AccountManager:getUin()) then
		openOldMiniworks()
	else
		GetInst("CreationCenterDataMgr"):ReqCreatorCenterCfg(
			function (isOpenNewCC)
				if isOpenNewCC then 
					GetInst("CreationCenterInterface"):OpenUI(param)
				else 
					openOldMiniworks()
				end 
			end
		)
	end
end

-- 跳转到家园
function JumpToHomeChest()
    if IsStandAloneMode() then return false; end

	if HasUIFrame("RoomFrameTimer") then
		getglobal("RoomFrameTimer"):Hide()
	end

	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3)
		return false;
	end
	if ClientMgr:getVersionParamInt("HomeChest", 1) ~= 1 then
		ShowGameTips(GetS(780), 3)
		return false;
	end
	if GetFcmRate() == 0 then
		ShowAntiAddictionMsg(GetS(3693))
		return false;
	end
	if ClientMgr:getApiId() == 54 then 
		ShowGameTips("请前往OPPO游戏中心下载", 3)
		MessageBox(5, "请前往OPPO游戏中心下载", JumpToOppoGameCenter)
		return false;
	end

	HomeChestFrameOpenTimeOut()
	HomeChestMgr:requestChestTreeReq(AccountManager:getUin())
	ShowLoadLoopFrame(true, "file:minilobbyinterface -- func:JumpToHomeChest")
	return true;
end

-- 跳转到商城
function JumpToShop(notHandleRedTag, type)
	if IsStandAloneMode() then return end
	
	if IsOverseasVer() then
		threadpool:work(SaveRegionCurrencyRate)
	end

	if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3)
		return;
	end
	-- getglobal("MiniLobbyFrame"):Hide();
	HideMiniLobby() --mark by hfb for new minilobby
	--LLTO:test:新商城
	IsResetTempSeta = true
	--商城重构
	ShopJumpTabView(1,type or 1)

    JsBridge:PopFunction()
end

--跳转到BattlePass
function JumpToBattlePass(isClick,param)
	if not check_apiid_ver_conditions(ns_shop_config2.battle_pass_sell) then
		return
	end
	local ShopCtrl = GetInst("UIManager"):GetCtrl("Shop");
	if ShopCtrl and ShopCtrl.view and ShopCtrl.view.root and ShopCtrl.view.root:IsShown() then
		ShopCtrl:CloseBtnClicked()
	end
	if not getglobal("NewBattlePass"):IsShown() then
		ShowLoadLoopFrame(true, "_JumpToBattlePass_")
		if NewBattlePass_IsCanOpenBP(isClick) then
			HideLoadLoopFrameByTag("_JumpToBattlePass_")
			if param and param.backLobbyMain and AccountManager:isLogin() and not ClientCurGame:isInGame() then
				xpcall(function()
					GetInst("UIManager"):HideAll()
					UIFrameMgr:hideAllFrame()
					GetInst("MiniUIManager"):removeAllUI()
					ShowMiniLobby()
				end,
				function(err)
					print(tostring(err))
					print("JumpToBattlePass error\n" .. debug.traceback())
					if get_game_env() == 1 and PlatformUtility:isDevBuild() then
						ShowGameTipsWithoutFilter("开发环境提示:JumpToBattlePass hideAll发生了错误")
					end
				end)
			end
			-- goIndex
			GetInst("UIManager"):Open("NewBattlePass",param)
			if param and param.from == 'mobpush_battlepass_interface' then
				standReportEvent("9923", "BACKFLOW", "Battlepass", "view",{standby1 = 1,standby2 = 0});
			end
		end
	end
end

-- 跳转到AR
function JumpToAR()
    if AccountManager:isFreeze() then
		ShowGameTips(GetS(762), 3)
		return;
	end

	if ARControl and ARControl.SetARInletTag then
		-- if getglobal("MiniLobbyFrame"):IsShown() then
		if IsMiniLobbyShown() then --mark by hfb for new minilobby
			ARControl:SetARInletTag(1)
			ARControl:SetSeatType(2)
			-- getglobal("MiniLobbyFrame"):Hide()
			HideMiniLobby() --mark by hfb for new minilobby
		end
	end

	InitAvatarStoreFrameUI(2)
end

-- 跳转到好友  该模块只存了数据，没有相应的UI
function JumpToChat()
    GetInst("UIManager"):Open("Chat")
end

-- 跳转到微信
function JumpToWeChat()
	local ret = false
    if ns_version.subscribe and ns_version.subscribe.option1 then
		local option = ns_version.subscribe.option1
		local apiId = ClientMgr:getApiId();
		if option then 
            local action = option.action
			local url = option.action_url
            if action and (action == 0) and url then
                g_openBrowserUrlAuth(url)
                ret = true
			elseif action then
				if ClientMgr and ClientMgr.openMiniProgramWithType then
					ret = ClientMgr:openMiniProgramWithType(action); --是否能成功打开小程序的标志位
                    if ret == false then
                        ShowGameTipsWithoutFilter("微信圈子名称复制成功，请打开微信搜索关注");
                        ClientMgr:clickCopy("迷你世界")
                    end
				end
			elseif action and (action == 1) then  --非安卓平台执行原函数
				if ClientMgr and ClientMgr.openMiniProgram then
                    ret = ClientMgr:openMiniProgram(); --是否能成功打开小程序的标志位
                    if ret == false then
                        ShowGameTipsWithoutFilter("微信圈子名称复制成功，请打开微信搜索关注");
                        ClientMgr:clickCopy("迷你世界")
                    end
                end
			end
        end
    end
    return ret
end

-- 跳转到微博
function JumpToWeibo()
	local ret = false
    if ns_version.subscribe and ns_version.subscribe.option2 then
		local option = ns_version.subscribe.option2
		local apiId = ClientMgr:getApiId();
        if option then 
            local action = option.action
            local url = option.action_url
            if action and (action == 0) and url then
                g_openBrowserUrlAuth(url)
				return true
			elseif action then
                if ClientMgr and ClientMgr.openMiniProgramWithType then
                    ret = ClientMgr:openMiniProgramWithType(action); --是否能成功打开小程序的标志位
                    if ret == false then
                        ShowGameTipsWithoutFilter("微信圈子名称复制成功，请打开微信搜索关注");
                        ClientMgr:clickCopy("迷你世界")
                    end
				end
            elseif action and (action == 1) then
                if ClientMgr and ClientMgr.openMiniProgram then
                    ret = ClientMgr:openMiniProgram(); --是否能成功打开小程序的标志位
                    if ret == false then
                        ShowGameTipsWithoutFilter("微信圈子名称复制成功，请打开微信搜索关注");
                        ClientMgr:clickCopy("迷你世界")
                    end
                end
            end
        end
    end
    return ret
end

-- 跳转到订阅
function JumpToSubscribe()
	standReportEvent("17", "SUBSCRIBE_TOP"	, "-", "view")
    getglobal("SubscribeFrame"):Show()
	-- 订阅号页面标题改为公众号
	if true then
		getglobal("SubscribeFrameTitleFrameTitle"):SetText(GetS(110102))
	end
    
	if isEnableNewMiniLobby() then
		if GetInst("UIManager"):GetCtrl("MiniLobbyEx") then --加个判断，没打开过就不要执行相应的逻辑
			GetInst("UIManager"):GetCtrl("MiniLobbyEx"):TopFiveButton_HandleRedTagClick("Subscribe")
			getglobal("MiniLobbyExTopSubscribeRedTag"):Hide()
		end
    else
        MiniLobbyFrameBottomButton_HandleRedTagClick("Subscribe")
        getglobal("MiniLobbyFrameBottomSubscribeRedTag"):Hide()
    end
	if ns_version.subscribe.option1.id then
		if getkv("SubscribeFrameWeChatBtn"..ns_version.subscribe.option1.id) then
			getglobal("SubscribeFrameWeChatBtnNewBkg"):Hide()
			getglobal("SubscribeFrameWeChatBtnReward"):Hide()
		else
			getglobal("SubscribeFrameWeChatBtnNewBkg"):Show()
			getglobal("SubscribeFrameWeChatBtnReward"):Show()
			setkv("SubscribeFrameWeChatBtn"..ns_version.subscribe.option1.id,true)
		end
	end
	if ns_version.subscribe.option2.id then
		if getkv("SubscribeFrameWeiboBtn"..ns_version.subscribe.option2.id) then
			getglobal("SubscribeFrameWeiboBtnNewBkg"):Hide()
			getglobal("SubscribeFrameWeiboBtnReward"):Hide()
		else
			getglobal("SubscribeFrameWeiboBtnNewBkg"):Show()
			getglobal("SubscribeFrameWeiboBtnReward"):Show()
			setkv("SubscribeFrameWeiboBtn"..ns_version.subscribe.option2.id,true)
		end
	end
end

-- 关闭订阅
function CloseSubscribe()
	standReportEvent("17", "SUBSCRIBE_TOP"	, "close", "click")
    getglobal("SubscribeFrame"):Hide()
end

-- 跳转到赛事
function JumpToMatch()
    if ns_version.match and ns_version.match.url then
		open_http_link( ns_version.match.url, "posting")
    end

    -- 新大厅
	if isEnableNewMiniLobby() then
		if GetInst("UIManager"):GetCtrl("MiniLobbyEx") then --加个判断，没打开过就不要执行相应的逻辑
			GetInst("UIManager"):GetCtrl("MiniLobbyEx"):TopFiveButton_HandleRedTagClick("Match")
			getglobal("MiniLobbyExTopMatchRedTag"):Hide()
		end
    else
        MiniLobbyFrameBottomButton_HandleRedTagClick("Match")
        getglobal("MiniLobbyFrameBottomMatchRedTag"):Hide()
    end
end

--跳转到反诈骗教学
function JumpToAntiFraud()
	-- if get_game_env() == 1 then
	-- 	open_http_link("s4_http://sso.mini.me/#/transit?url=http://activities-test.mini.me/fe/mini-school-fraud", nil)
	-- else
	-- 	open_http_link("s4_https://sso.mini1.cn/ssourl/#/transit?url=https://activities.mini1.cn/fe/mini-school-fraud", nil)
	-- end
	local url = ClientUrl:GetUrlString("HttpAntiFraud", "")
	open_http_link(url)
end

-- 跳转到社区
function JumpToCommunity()
    if  ns_version.shequ and ns_version.shequ.url then
    	local url = ns_version.shequ.url
    	--社区增加ios相册权限判断
    	if ClientMgr:isApple() and MINIW__CheckHasPermission then
			local b_ret = MINIW__CheckHasPermission(DevicePermission_WriteExternalStorage) or false
			url = url.."&hasAuthor="..tostring(b_ret)
		end
        open_http_link( url, "posting")
    end

    -- 新大厅
	if isEnableNewMiniLobby() then
		if GetInst("UIManager"):GetCtrl("MiniLobbyEx") then --加个判断，没打开过就不要执行相应的逻辑
			GetInst("UIManager"):GetCtrl("MiniLobbyEx"):TopFiveButton_HandleRedTagClick("Community")
			getglobal("MiniLobbyExTopCommunityRedTag"):Hide()
		end
    else
        MiniLobbyFrameBottomButton_HandleRedTagClick("Community")
        getglobal("MiniLobbyFrameBottomCommunityRedTag"):Hide()
    end
end

-- 跳转到直播
function JumpToVideoLive()
    local szSharePlatforms = ""
	ns_version.qq_share = ns_version.qq_share or {}
	if check_apiid_ver_conditions(ns_version.qq_share.qq) then
		szSharePlatforms = szSharePlatforms .. "fx_qq,"
	end
	if check_apiid_ver_conditions(ns_version.qq_share.wx) then
		szSharePlatforms = szSharePlatforms .. "fx_wx,"
	end
	if check_apiid_ver_conditions(ns_version.qq_share.wb) then
		szSharePlatforms = szSharePlatforms .. "fx_wb,"
	end
	if check_apiid_ver_conditions(ns_version.qq_share.wxfriends) then
		szSharePlatforms = szSharePlatforms .. "fx_pyq,"
	end
	if check_apiid_ver_conditions(ns_version.qq_share.qzone) then
		szSharePlatforms = szSharePlatforms .. "fx_qqkj,"
	end
	if check_apiid_ver_conditions(ns_version.qq_share.facebook) and ClientMgr:CheckAppInstall("fx_fb")  then
		szSharePlatforms = szSharePlatforms .. "fx_fb,"
	end
	if check_apiid_ver_conditions(ns_version.qq_share.twitter) and ClientMgr:CheckAppInstall("fx_tw") then
		szSharePlatforms = szSharePlatforms .. "fx_tw,"
	end
	if JavaMethodInvokerFactory.obtain then 
		JavaMethodInvokerFactory:obtain()
			:setClassName("org/appplay/lib/AbsMiniShare")
			:setMethodName("setSharePlatforms")
			:setSignature("(Ljava/lang/String;)V")
			:addString(szSharePlatforms)
			:call();
    end
    
    if ns_version.zhibo_btn then
		if ClientMgr.isPC and ClientMgr:isPC() and ns_version.zhibo_btn.url_pc then
			open_http_link(ns_version.zhibo_btn.url_pc)
		elseif ns_version.zhibo_btn.url_mb then
			open_http_link(ns_version.zhibo_btn.url_mb)
		end
    end

    -- 新大厅
	if isEnableNewMiniLobby() then
		if GetInst("UIManager"):GetCtrl("MiniLobbyEx") then --加个判断，没打开过就不要执行相应的逻辑
			GetInst("UIManager"):GetCtrl("MiniLobbyEx"):TopFiveButton_HandleRedTagClick("VideoLive")
			getglobal("MiniLobbyExTopVideoLiveRedTag"):Hide()
		end
    else
        MiniLobbyFrameBottomButton_HandleRedTagClick("VideoLive")
        getglobal("MiniLobbyFrameBottomVideoLiveRedTag"):Hide()
    end
end

-- 跳转到Facebook点赞
function JumpToFacebookThumbUp()
    if if_open_facebook_prize() then
		g_openBrowserUrlAuth( ns_version.facebook_prize.url )
    end

    -- 新大厅
	if isEnableNewMiniLobby() then
		if GetInst("UIManager"):GetCtrl("MiniLobbyEx") then --加个判断，没打开过就不要执行相应的逻辑
			GetInst("UIManager"):GetCtrl("MiniLobbyEx"):TopFiveButton_HandleRedTagClick("FacebookThumbUp")
			getglobal("MiniLobbyExTopFacebookThumbUpRedTag"):Hide()
		end
    else
        MiniLobbyFrameBottomButton_HandleRedTagClick("FacebookThumbUp")
        getglobal("MiniLobbyFrameBottomFacebookThumbUpRedTag"):Hide()
    end
end

-- 跳转到个人中心
function JumpToPlayerCenter(from)
    if IsStandAloneMode() then return end
    ReportTraceidMgr:setTraceid("personalcenter")
    -- 查看哪个玩家的资料
	PlayerCenterFrame_setTarget()

	OpenNewPlayerCenter(AccountManager:getUin(),from)
end

-- 跳转到回流
function JumpToComeBack(isNew, isClick)	
	if not GetInst("UIManager"):GetCtrl("Shop") then
        JumpToShop(true)
		GetInst("UIManager"):GetCtrl("Shop"):CloseBtnClicked()
	end

	if isNew then
		local NewComeBackMissionInfo = GetInst("UserTaskDataManager").NewComeBackMissions;
		if NewComeBackMissionInfo and NewComeBackMissionInfo.ret == 0 then
			if isClick then
				GetInst("UIManager"):Open("NewComeBackEntrance")
			else
				GetInst("ActivityPopupManager"):InsertActivity(1, function()
					GetInst("UIManager"):Open("NewComeBackEntrance")
				end)
			end
		else
			ShowGameTips(GetS(12603))
		end
	else
		if isClick then
			GetInst("UIManager"):Open("ComeBackEntrance")
		else
			GetInst("ActivityPopupManager"):InsertActivity(1, function()
				GetInst("UIManager"):Open("ComeBackEntrance")
			end)
		end
	end
end

-- 跳转到商城-交易行
function JumpToAuctionSystem()
	-- body
end

--[[-------------------------------------------------大厅UI统一处理接口---------------------------------------------]]
-- 刷新福利按钮新接口
function NewUpdateChannelRewardBtn()
    local apiId = ClientMgr:getApiId()
    local task = ns_ma.server_config_start_game_out
    local ChannelRewardBtn, ChannelRewardBtnNormal, ChannelRewardBtnPushedBG = nil, nil, nil
    if isEnableNewMiniLobby() then
        ChannelRewardBtn            = getglobal("MiniLobbyExTopChannelRewardBtn")
        ChannelRewardBtnNormal      = getglobal("MiniLobbyExTopChannelRewardBtnNormal")
        ChannelRewardBtnPushedBG    = getglobal("MiniLobbyExTopChannelRewardBtnPushedBG")
    else
        ChannelRewardBtn            = getglobal("MiniLobbyFrameTopChannelRewardBtn")
        ChannelRewardBtnNormal      = getglobal("MiniLobbyFrameTopChannelRewardBtnNormal")
        ChannelRewardBtnPushedBG    = getglobal("MiniLobbyFrameTopChannelRewardBtnPushedBG")
    end
	-- apiId = 21
	print("UpdateChannelRewardBtn(): task = ", task)
	if task.task_conditions and task.task_conditions.start_game_out and task.task_conditions.start_game_out == apiId then
		if apiId == 13 then --oppo
			ChannelRewardBtn:Show()
			ChannelRewardBtnNormal:SetTexUV("icon_oppo")
			ChannelRewardBtnPushedBG:SetTexUV("icon_oppo")
			--添加特权埋点
			MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Privilege", "view", {standby2 = 0})
		elseif apiId == 36 then --vivo
			ChannelRewardBtn:Show();
			ChannelRewardBtnNormal:SetTexUV("icon_vivo")
			ChannelRewardBtnPushedBG:SetTexUV("icon_vivo")
			--添加特权埋点
			MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Privilege", "view", {standby2 = 0})
		elseif apiId == 21 then --yyb
			ChannelRewardBtn:Show()
			ChannelRewardBtn:SetPoint("right", "MiniLobbyFrameTopYYBForumBtn", "left", -14, 0)
			ChannelRewardBtnNormal:SetTexUV("icon_tencentappvip")
			ChannelRewardBtnPushedBG:SetTexUV("icon_tencentappvip")
			--添加特权埋点
			MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Privilege", "view", {standby2 = 0})
		elseif apiId == 12 then --xiaomi
			ChannelRewardBtn:Show()
			ChannelRewardBtnNormal:SetTexUV("icon_xiaomi")
			ChannelRewardBtnPushedBG:SetTexUV("icon_xiaomi")
			--添加特权埋点
			MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Privilege", "view", {standby2 = 0})
		else
			return
		end
		ChannelRewardPresenter:requestShowChannelRewardFrame()
	end
end

-- 社区、订阅、赛事、直播、点赞统一红点处理接口
function CommunityAndSoOnButton_HandleRedTag(typeName, redTag, fguiRedTag)
    Log( "call CommunityAndSoOnButton_HandleRedTag : ".. typeName)
	
	local nameMap = { Community = "shequ", VideoLive = "live", Subscribe = "subsp", FacebookThumbUp = "prize",Match = "match" }
	if not nameMap[typeName] then
		--print("error typeName")
		return
	end

	local name = nameMap[typeName];
	ns_version.red_marks = ns_version.red_marks or {}
	local config = ns_version.red_marks[name]
	if not config or not check_apiid_ver_conditions(config) then
		--print("empty :", not config);
		--print(ns_version.red_marks);
		return
	end
	--print("config :", config)

	-- 检测ver配置是否变更
	local ver_ = "red_tag_ver_"..name
	local data_ = "red_tag_data_"..name
	local verIsShow = false -- ver方案显示开关
	local dataIsShow = false -- data方案显示开关
	if not getkv(ver_) then
		setkv(ver_, 888)
	end
	if config.ver and config.red_dot_toggle ~=0  then
		if getkv(ver_) and config.ver ~= getkv(ver_) then
			verIsShow = true
		end
	elseif config.red_dot_toggle ~=0 then -- 社区按钮分pc/mobile
		if ClientMgr.isPC and ClientMgr:isPC() and getkv(ver_) and
				config.pc_ver and config.pc_ver ~= getkv(ver_) then
			verIsShow = true
		elseif ClientMgr.isMobile and ClientMgr:isMobile() and getkv(ver_) and
				config.mb_ver and config.mb_ver ~= getkv(ver_) then
			verIsShow = true
		end
	end
	--print("ver_ :", verIsShow);

	if config.data then -- 本次登录已显示过 kv是缓存 重启游戏仍然存在 config中的是lua变量 重启游戏不存在
		--print("has showed :", config.data)
		dataIsShow = config.data.isShow
	else
		local now = getServerNow()+1600
		--data {
		--	long t; 周期
		--	int c; 计数
		--	bool isShow; 是否显示
		--}
		config.data = getkv(data_) or { t = 0, c = 0, isShow = false }
		--print("hasnot showed :", config.data, now)
		if typeName == "Subscribe" and config.red_dot_toggle then
			if config.red_dot_toggle ~=0 then
				dataIsShow = true
			end
		else
			if config.cd and config.data then
				if config.cd and now - config.data.t >= config.cd then
					--print("new t :", now, config.data)
					config.data.c = 0
					config.data.t = now
					config.data.isShow = not verIsShow
					setkv(data_, config.data)
				end
			end 
			
			if config.data and config.data.c and config.count then
				if tonumber(config.data.c) < tonumber(config.count) then
					--print("data can show :", config.data.c)
					config.data.isShow = true
					dataIsShow = true
				end
			end 
		end
	end

	if verIsShow and dataIsShow then
		-- 当运营配置红点与原有红点机制同时出现时，默认运营配置红点已生效完成，不再额外多次红点提示
		-- 即仅当前周期不再出现
		if  config.data then  
			config.data.c = config.count
			config.data.isShow = false
			setkv(data_, config.data)
		end 
		--print("same time : ", config.data);
	end

	--print("both : ", verIsShow, dataIsShow)
	if verIsShow or dataIsShow then
		-- MiniLobbyFrameBottomCommunityRedTag,MiniLobbyFrameBottomVideoLiveRedTag,
		-- MiniLobbyFrameBottomSubscribeRedTag,MiniLobbyFrameBottomFacebookThumbUpRedTag
		if redTag then
			redTag:Show()
		end
		if fguiRedTag then
			fguiRedTag:setVisible(true)
		end
	else
		if redTag then
			redTag:Hide()
		end
		if fguiRedTag then
			fguiRedTag:setVisible(false)
		end
	end
end

-- 社区、订阅、赛事、直播、点赞统一回调红点处理接口
function CommunityAndSoOnButton_HandleRedTagClick(typeName, redTag, fguiRedTag)
    Log( "call CommunityAndSoOnButton_HandleRedTagClick : ".. typeName)
    local nameMap = { Community = "shequ", VideoLive = "live", Subscribe = "subsp", FacebookThumbUp = "prize", Match = "match"}
	if not nameMap[typeName] then
		return
	end

	local name = nameMap[typeName]
	ns_version.red_marks = ns_version.red_marks or {}
	local config = ns_version.red_marks[name]
	if not config or not check_apiid_ver_conditions(config) then
		--print(not config);
		--print(ns_version.red_marks);
		return
	end

	local ver_ = "red_tag_ver_"..name
	local data_ = "red_tag_data_"..name

	if config and config.ver then
		setkv(ver_, config.ver)
	else
		if ClientMgr.isPC and ClientMgr:isPC() and config and config.pc_ver then
			setkv(ver_, config.pc_ver)
			--print("has set ver_ pc")
		elseif ClientMgr.isMobile and ClientMgr:isMobile() and config and config.mb_ver then
			setkv(ver_, config.mb_ver)
			--print("has set ver_ mb")
		end
	end


	if getkv(data_) then
		config.data = getkv(data_)
		--print("hava data_", config.data)
		if  config.data and config.data.c and config.count then  
			if tonumber(config.data.c) <  tonumber(config.count) and ((redTag and redTag:IsShown()) or (fguiRedTag and fguiRedTag:isVisible())) then
				--print("click data : ", config.data)
				config.data.c = config.data.c + 1
				config.data.isShow = false
				--print("click data after : ", config.data)
				setkv(data_, config.data)
			end
		end 
	end
end

--官版特权是否在新界面显示 --参考的SetGuanBanFuliBtnAndRedFlagsShown 
function IsGuanBanFuliBtnCanShowInFguiMain()
	if IsShowFguiMain() and IsGuanBanFuliBtnCanShow() then
		return true
	end
	
	return false
end

--检查官版特权福利是否可以显示 --参考的SetGuanBanFuliBtnAndRedFlagsShown
function IsGuanBanFuliBtnCanShow()
	if ns_ma.server_ma_apiid1 and ns_ma.server_ma_apiid1[1] and ns_ma.reward_list and type(ns_ma.reward_list) == "table" and next(ns_ma.reward_list) then
		if iOSShouQConfig(8, false) or (isAndroidShouQ() and ns_version.qqvip and ns_version.qqvip.open and ns_version.qqvip.open == 1) then
			return false
		else
			return true
		end
	end

	return false
end

-- 设置官版福利按钮和红点显示隐藏逻辑接口
function SetGuanBanFuliBtnAndRedFlagsShown()
    local btn, redTag, pointBtn
	pointBtn  = getglobal("MiniLobbyFrameTopMiniPointBtn")
    if isEnableNewMiniLobby() then
        btn     = getglobal("MiniLobbyExTopGuanBanFuliBtn")
        redTag  = getglobal("MiniLobbyExTopGuanBanFuliBtnRedTag")
    else
        btn     = getglobal("MiniLobbyFrameTopGuanBanFuliBtn")
        redTag  = getglobal("MiniLobbyFrameTopGuanBanFuliBtnRedTag")
    end

	--ns_ma.server_ma_apiid1 取值是根据官版渠道判断
	if ns_ma.server_ma_apiid1 and ns_ma.server_ma_apiid1[1] and ns_ma.reward_list and type(ns_ma.reward_list) == "table" and next(ns_ma.reward_list) then
		--这里面不包含 安卓手Q和iOS手Q渠道
		if iOSShouQConfig(8,false) or (isAndroidShouQ() and ns_version.qqvip and ns_version.qqvip.open and ns_version.qqvip.open == 1) then
			btn:Hide()
		else
			btn:Show()
			pointBtn:SetPoint("right", btn:GetName(), "left", -17, 0)
		end
		redTag:Hide()
		for k = 1,2 do
			local item_data = ns_ma.server_ma_apiid1[k]
			if item_data == nil then
				break
			end
			for kk = 1,#item_data do
				local r_item = ns_ma.reward_list[item_data[kk].id]
				if r_item and r_item.stat == 1 then
					redTag:Show()
					break
				end
			end
		end
		--添加特权埋点
		local eventTab = {standby2 = (redTag:IsShown() and 1 or 0)}
		MiniLobbyStandReportSingleEvent("MINI_HOMEPAGE_TOP_1", "Privilege", "view", eventTab)
	end
end

-- 设置是否显示广告快捷入口
function SetMiniPointBtnShow()
	local lang = get_game_lang()
	local pointBtn  = getglobal("MiniLobbyFrameTopMiniPointBtn")
	if GetInst("ShopConfig"):isShowMiniPoint() then
		pointBtn:Show()
	else
		pointBtn:Hide()
	end
end

--刷新新大厅动画
function RefreshMiniLobbyExRoleView()
	if isEnableNewMiniLobby() then
        if IsMiniLobbyShown() then
            GetInst("UIManager"):GetCtrl("MiniLobbyEx"):SetRoleView()
        end
    end
end

--刷新存档界面动画
function RefreshMapArchiveListRoleView()
    if getglobal("lobbyMapArchiveList"):IsShown() then
		GetInst("UIManager"):GetCtrl("lobbyMapArchiveList"):SetRoleView()
    end 

	if GetInst("MiniUIManager"):IsShown("activity_douluo_mainAutoGen") then 
		GetInst("MiniUIManager"):GetCtrl("activity_douluo_main").view:ShowBodyView()
	end
end

function ResetMapArchiveListRoleView()
    if getglobal("lobbyMapArchiveList"):IsShown() then
		GetInst("UIManager"):GetCtrl("lobbyMapArchiveList"):RoleViewReset()
    end 
end

--刷新BattlePass红点
function RefreshBattlePassRedPoint(ret)
	if not check_apiid_ver_conditions(ns_shop_config2.battle_pass_sell) then
		return
	end
	--[[
	Author: sundy
	EditTime: 2021-07-30
	Description: redpoint change to tip text
	
	ret format
	ret.redpoint  有等级奖励可领取
	ret.missionpoint  有任务奖励可领取
	--]]
    if ret and ret.ret and ret.ret == 0 then
		-- 主界面BP红点显示状态更新
		local nType = 0
		if ret.redpoint and ret.redpoint > 0 then
			nType = 1
		elseif ret.missionpoint and ret.missionpoint > 0 then
			nType = 2
		end
		-- SetBattlePassRedPointView(nType)
		GetInst("MinilobbyPupTextMgr"):CheckBattlePassTextTip(nType)

		if nType > 0 then
			RefreshFguiMainBattlePassReadTag(true)
		else
			RefreshFguiMainBattlePassReadTag(false)
		end
    else
        Log("LoadBattlePassSeasonInfo_error")
    end
end

-- BP可领取标记显示状态刷新刷新
--[[
Author: sundy
EditTime: 2021-08-02
Description: 修改isShow(bool类型)为nType(int类型)  0、不显示 1、有等级奖励 2、有任务奖励
--]]
function SetBattlePassRedPointView(nType)
	if isEnableNewMiniLobby() then 
		if nType > 0 then
			getglobal("MiniLobbyExRightBattlePass"):Show()
		else
			getglobal("MiniLobbyExRightBattlePass"):Hide()
		end		
	else
		local parentName = "MiniLobbyFrameBottomBattlePass"
		if nType == 0 then		
			getglobal(parentName.."RedTagTip"):Hide()
			getglobal(parentName.."RedTag"):Hide()
			-- getglobal(parentName.."TextTip"):Hide()
		elseif nType == 1 then		
			getglobal(parentName.."RedTagTip"):Show()
			getglobal(parentName.."RedTag"):Show()
			-- getglobal(parentName.."TextTip"):Show()
			-- getglobal(parentName.."TextTipContent"):SetText(GetS(32534))
		elseif nType == 2 then		
			getglobal(parentName.."RedTagTip"):Show()
			getglobal(parentName.."RedTag"):Show()
			-- getglobal(parentName.."TextTip"):Show()
			-- getglobal(parentName.."TextTipContent"):SetText(GetS(32534))
		end
	end		
end
-------------------------------------------------------UI改版相关接口------------------------------------2020/11/17
--更新好友气泡数据
function UpdateFriendBubbleInfo()
	--未读信息 好友 + 群聊
	UpdateFriendBubbleInfoForIM()

	--加好友申请 + 加群申请
	UpdateFriendBubbleInfoForAddMsg()
end

--更新好友气泡数据
function UpdateFriendBubbleInfoForPlayingGame()
	--好友正在游戏中
	friendservice.friendBubbleInfo[1] = 1 --有数量
	friendservice.friendBubbleDisplayFlag[1] = true --存在数量的话 就设置为没显示过
end

--更新好友气泡数据 
function UpdateFriendBubbleInfoForIM()
	--未读信息 好友 + 群聊
	local unreadMsgCnt = GetUnreadMsgCount()
	friendservice.friendBubbleInfo[2] = unreadMsgCnt
	--print("LwtaoP unreadMsgCnt = "..unreadMsgCnt)
	if unreadMsgCnt > 0 then
		friendservice.friendBubbleDisplayFlag[2] = true -- 存在数量的话 就设置为没显示过
	end
end

--更新好友气泡数据
function UpdateFriendBubbleInfoForAddMsg()
	--加好友申请 + 加群申请
	local unreadAskingAddMsgCnt = GetUnreadAskingAddMsgCount()
	friendservice.friendBubbleInfo[3] = unreadAskingAddMsgCnt
	--print("LwtaoP unreadAskingAddMsgCnt = "..unreadAskingAddMsgCnt)
	if unreadAskingAddMsgCnt > 0 then
		friendservice.friendBubbleDisplayFlag[3] = true -- 存在数量的话 就设置为没显示过
	end
end

--获取好友气泡类型
function GetFriendBubbleTypeJustForReport()
	--friendservice.friendBubbleInfo 对应 1 有好友正在玩游戏 2 有%s条新消息 3 有%s条新申请 
	friendservice.friendBubbleInfo = friendservice.friendBubbleInfo or {0,0,0}
	friendservice.friendBubbleDisplayFlag = friendservice.friendBubbleDisplayFlag or {false, false, false}
	
	local idx = 1
	for i, v in pairs(friendservice.friendBubbleInfo or {}) do
		if v > 0 and friendservice.friendBubbleDisplayFlag[i] then
			idx = i + 1
			break
		end
	end

	----view,click都要带参数standby1:1,常规入口；2，iM信息，3,好友在玩；4，申请好友 
	local indexTab = {1,3,2,4} --映射表 2 3对调了
	return indexTab[idx]
end

--检查好友气泡通知情况
function CheckFriendBubbleNotify()

	local show = false
	local index = 0
	for i, v in pairs(friendservice.friendBubbleInfo or {}) do
		if v > 0 and friendservice.friendBubbleDisplayFlag[i] then
			show = true
			index = i
			break
		end
	end

	--print("lwtaoP stack = ",debug.traceback())
	--print("lwtaoP CheckFriendBubbleNotify friendservice.friendBubbleInfo = ",friendservice.friendBubbleInfo or {})
	--print("lwtaoP CheckFriendBubbleNotify friendservice.friendBubbleDisplayFlag = ",friendservice.friendBubbleDisplayFlag or {})
		--不中ab
	if IsShowFguiMain() then 
		if show and index > 0 then
			PushTipsForFriendBubble()
		else
			RemoveTipsForFriendBubble()
		end
	else
		if show and index > 0 then
			PushTipsForOldFriendBubble()
		else
			RemoveTipsForOldFriendBubble()
		end
	end
end

--推送显示好友气泡
function PushTipsForOldFriendBubble()
	--社交 P2
	RemoveTipsForOldFriendBubble()	
	PushTips(handler(FriendMgr, FriendMgr.ShowFriendBubble), handler(FriendMgr, FriendMgr.HideFriendBubble), "p2", "FriendBubble")
end

--推送隐藏好友气泡
function RemoveTipsForOldFriendBubble()
	--社交 P2
	RemoveTips("p2", "FriendBubble")
end

--推送显示好友气泡
function PushTipsForFriendBubble()
	--社交 P2
	local mainCtrl = GetInst("MiniUIManager"):GetCtrl("main")
	if mainCtrl then
		RemoveTipsForFriendBubble()
		
		PushTips(handler(mainCtrl, mainCtrl.ShowFriendBubble), handler(mainCtrl, mainCtrl.HideFriendBubble), "p2", "FriendBubble")
	end
end

--推送隐藏好友气泡
function RemoveTipsForFriendBubble()
	--社交 P2
	RemoveTips("p2", "FriendBubble")
end

--
-- 上报已读时间点，desid: 好友uin或群id, destype: 好友聊天填"friend", 群聊填"group"
--BuddyManager:reportread(desid, destype)
function ReportReadMsgTimeForFriendAndGroup(desid, destype)
	--不中桶 就不请求吧 避免干扰原来的逻辑
	if not IsShowFguiMain() then
		return
	end

	if not desid or not destype then
		return
	end

	--筛选掉-1
	if desid == -1 then
		return
	end

	if not BuddyManager.reportread then
		return
	end

	threadpool:work(function() 
		local code, ret = BuddyManager:reportread(desid, destype)
		--print("lwtaoP BuddyManager:reportread code = "..tostring(code), ret or {})
	end)
end

--[[
	callBackShow：显示回调
	callBackHide：隐藏回调
	type：优先级，p0,p1
	key：业务关键字，自定义,key不可以重复，否则会覆盖
]]
function PushTips(callback_show,callback_hide,type,key)
	if ns_data and ns_data.business_def and ns_data.business_def.main_config and ns_data.business_def.main_config.tips then
		local tips_config = ns_data.business_def.main_config.tips;
		local pIndex = tips_config[type];
		if not pIndex then return end;
		if not TipsList then
			TipsList = {}
		end
		if not TipsList[pIndex] then
			TipsList[pIndex] = {}
		end

		table.insert(TipsList[pIndex],{
			callback_show=callback_show,
			callback_hide=callback_hide,
			type=type,
			key = key,
			isShowing = false,
		})

		ShowNextTips();
	end
end

function RemoveTips(type,key)
	if ns_data and ns_data.business_def and ns_data.business_def.main_config and ns_data.business_def.main_config.tips then
		local tips_config = ns_data.business_def.main_config.tips;
		local pIndex = tips_config[type];

		if not pIndex or not TipsList or not TipsList[pIndex] then
			return
		end

		for k,v in pairs(TipsList[pIndex]) do
			if v and v.type == type and v.key == key then
				if v.callback_hide then
					v.callback_hide();
				end

				if v.isShowing  then  
					IsShowingTips = false;
				end
				
				TipsList[pIndex][k] = false;
				threadpool:delay(1,ShowNextTips);
				break;
			end
		end
	end
end

function ShowNextTips()
	if --[[GetInst('MiniUIManager'):IsShown('mainAutoGen') and]] not IsShowingTips
		and	ns_data and ns_data.business_def and ns_data.business_def.main_config and ns_data.business_def.main_config.tips then
		
			local tips_config = ns_data.business_def.main_config.tips;
			local values = {}
			for key, value in pairs(tips_config) do
				table.insert(values,value)
			end

			table.sort(values, function (a,b)
				return a -b;
			end)

			for type,pIndex in pairs(values) do
				if  TipsList and TipsList[pIndex] then
					for k,v in ipairs(TipsList[pIndex]) do
						if v and v.callback_show then
							v.callback_show();
							IsShowingTips = true;
							v.isShowing = true;
							return;
						end
					end
				end
			end
	end
end

--获取气泡是不是正在显示
function GetTipsState(type,key)
	if ns_data and ns_data.business_def and ns_data.business_def.main_config and ns_data.business_def.main_config.tips then
		local tips_config = ns_data.business_def.main_config.tips;
		local pIndex = tips_config[type];

		if not pIndex or not TipsList or not TipsList[pIndex] then
			return false
		end

		for k,v in pairs(TipsList[pIndex]) do
			if v and v.type == type and v.key == key then
				return v.isShowing
			end
		end
	end
end

-- 会员续订拍脸图弹框逻辑处理
function ShowVipRenewActivity()
	local isCanShow = function()
		local FiveHour = 18000 -- 5小时
		local lastTime = getkv("activity_vipRenew_showTime")
		if lastTime and lastTime > 0 and os.date("%Y-%m-%d", lastTime-FiveHour) == os.date("%Y-%m-%d", os.time()-FiveHour) then
			return false
		end
		if getkv("activity_vipRenew_neverShowAgain") then
			return false
		end
		if GetInst("MiniUIManager"):IsShown("ActivityVipRenew") then
			return false
		end
		-- 使用的VIP数据不是同一个玩家的，说明切换了账号，要重新拉取VIP数据
		if CheckVipRenew_Uin ~= AccountManager:getUin() then
			return false
		end
		return true
	end

	local bVipTimeRemain = GetInst("MembersSysMgr"):GetMembersRepiredtime() or 0
	bVipTimeRemain = bVipTimeRemain - getServerTime()
	if bVipTimeRemain and bVipTimeRemain > 0 and isCanShow() then
		local DAY = 86400
		-- local random  = math.random(1, 7)
		-- bVipTimeRemain = random * DAY  -- fym test
		local showDay = nil
		if (bVipTimeRemain > 6*DAY and bVipTimeRemain <= 7*DAY) then
			showDay = 7  -- 距离会员到期7天
		elseif (bVipTimeRemain > 4*DAY and bVipTimeRemain <= 5*DAY) then
			showDay = 5  -- 距离会员到期5天
		elseif (bVipTimeRemain > 2*DAY and bVipTimeRemain <= 3*DAY) then
			showDay = 3  -- 距离会员到期3天
		elseif (bVipTimeRemain > DAY and bVipTimeRemain <= 2*DAY) then
			showDay = 2  -- 距离会员到期2天
		elseif (bVipTimeRemain >= 0 and bVipTimeRemain <= DAY) then
			showDay = 1  -- 距离会员到期最后一天
		end
		if showDay then
			GetInst("ActivityPopupManager"):InsertActivity(1, function(param)
				GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/activity_vip_renew_pailian"})
				GetInst("MiniUIManager"):OpenUI(
					"main", 
					"miniui/miniworld/activity_vip_renew_pailian", 
					"ActivityVipRenewAutoGen", 
					{ showDay = param.showDay }
				)
				GetInst("MiniUIManager"):PopupUI("ActivityVipRenewAutoGen")
			end, {showDay = showDay})
		end
	end
end
-- 根据key值获取应用安全防护配置
function GetAppSafeGuardCfg(key)
	local name = "AppSafeGuard"
	local cfg = GetInst("VisualCfgMgr"):GetCfg(name, true) or {}
    if not cfg[name] or not cfg[name][key] then
        return
    end
	cfg = copy_table(cfg[name][key])
	return cfg
end