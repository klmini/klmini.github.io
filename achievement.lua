local CurAchievementGroup = 0
local CurChooseAchievementId = 0
local LastChooseAchievementId = 0
local ACHIEVEMENT_NUM_MAX = 100

AchievementFrameType = 0 --0帐号成就  1存档成就
AchArryNum = 0
AchNeenNum = 0
ACHIEVEMENT_MAX_LIST = 1000 --总成就最大的数目

local t_ArrowInfo = {
    ["brown"] = {r = 116, g = 76, b = 39, uv = {x = 1015, y = 816, w = 8, h = 15}, uvname = "cj_jiantou01"},
    ["green"] = {r = 37, g = 155, b = 0, uv = {x = 1015, y = 835, w = 8, h = 15}, uvname = "cjjm_jiantou02"},
    ["black"] = {r = 0, g = 0, b = 0, uv = {x = 1015, y = 854, w = 8, h = 15}, uvname = "cjjm_jiantou03"}
}

local t_achievementLabelBtnInfo = {
    {name = "AchievementFrameXinShouBtn", rewardNum = 0},
    {name = "AchievementFrameMainBtn", rewardNum = 0},
    {name = "AchievementFrameProductionBtn", rewardNum = 0},
    {name = "AchievementFrameFightBtn", rewardNum = 0},
    {name = "AchievementFrameOtherBtn", rewardNum = 0},
    {name = "AchievementFrameExtremityBtn", rewardNum = 0}
}
local t_achivementBtn = {} --存储成就按钮。
local MaxSliderX = 0
local MaxSliderY = 0
local MaxSliderGridX = 0
local MaxSliderGridY = 0
local GroupDefCache = {}
--上线的时候调用一次
--[[
function UpdateRewardNum()
--	local num = AchievementMgr:getAchievementSize();
	local num = ACHIEVEMENT_MAX_LIST;
	for i=1,num do
		local achievementId = i + 1000 -1;
		local state = AchievementMgr:getAchievementState();
		if state == 2 then	
			local achievementDef = AchievementMgr:getAchievementDef(achievementId);
			if achievementDef ~= nil then
				local num = achievementDef.GoalNum;
				local arryNum = AchievementMgr:getAchievementArryNum(achievementId);
				if achievementDef ~= nil and arryNum >= num then	--可以领取奖励
					t_achievementLabelBtnInfo[achievementDef.Group].rewardNum = t_achievementLabelBtnInfo[achievementDef.Group].rewardNum + 1;
				end
			end
		end
	end
end
--]]

function ShowItemTips()
    SetMTipsInfo(-1, this:GetName(), false, itemId);
end


--每次进冒险地图应该重置一下奖励相关的红点
function UpdateAchievementRewardNum()
    for i = 1, #t_achievementLabelBtnInfo do
        t_achievementLabelBtnInfo[i].rewardNum = 0 --重置
        local strIDs = AchievementMgr:getAchievementIDsByGroup(i)
        local t_Task = StringSplit(strIDs, ",")

        if type(t_Task) ~= "table" then
        else
            for j = 1, #t_Task do
                local achievementId = tonumber(t_Task[j]) or 0
                local achievementDef = AchievementMgr:getAchievementDef(achievementId)
                if achievementDef ~= nil then
                    local achievementState = GetAchievementState(achievementDef)
                    if achievementState == 22 then --可以领取奖励
                        t_achievementLabelBtnInfo[achievementDef.Group].rewardNum =
                            t_achievementLabelBtnInfo[achievementDef.Group].rewardNum + 1 --累计
                    end
                end
            end
        end
    end
end

function AchievementFrame_OnLoad()
    this:RegisterEvent("GE_ACHIEVEMENT_CHANGE")
    this:RegisterEvent("GE_ACHIEVEMENT_REWARD")
    this:RegisterEvent("GE_CLIENT_ACHIEVEMENT_CHANGE")

    
end

function UpdateAchievementFrameById(achiId)
    local achievementDef = AchievementMgr:getAchievementDef(achiId)
    if achievementDef ~= nil then
        LastChooseAchievementId = CurChooseAchievementId
        CurChooseAchievementId = achiId
        UpdateOneAchievementInfo(achiId)
        UpdateAchievementDescShow(achiId)
        UpdateAchievementBtnHalo(achiId)
        CurAchievementGroup = achievementDef.Group
        UpdateAchievementState()
        UpdateTrackInfo()
        
    end
end

function UpdateClientAchievementFrameById(objid,achiId)
    threadpool:work(
    function ()
        local achievementDef = AchievementMgr:getAchievementDef(achiId)
        if achievementDef ~= nil then
            local t_info =  GetTypeAchievemntTable(achievementDef.Group)
            for k,v in pairs(t_info) do
                local lachievementDef = t_info[k]
                local frontState = AchievementMgr:getAchievementState(objid, lachievementDef.ID)
                local achievementState = GetAchievementOthenPlayState(objid,lachievementDef)
                if achievementState == 0 then 
                elseif achievementState == 22 then
                    achievementState = 2
                end
                if frontState ~= achievementState then
                    if achievementState ~= 0 then
                        AchievementMgr:setAchievementState(objid, t_info[k].ID, achievementState)
                    end
                end
            end
        end
    end
    )
    
end

--外部调用展示的接口
function ShowAchievementById(achiId)
    local achievementDef = AchievementMgr:getAchievementDef(achiId)
    if achievementDef ~= nil then
        UpdateAchievementLabelBtnState(t_achievementLabelBtnInfo[achievementDef.Group].name)
        CurAchievementGroup = achievementDef.Group
        UpdateAchievementInfo()
        UpdateAchievementFrameById(achiId)
        UpdateSlidingFrameSize()
        AutoJumpToAchievement(achiId)
    end
end

function standReportAchievementFinishEvent(achiId)
    local achievementDef = AchievementMgr:getAchievementDef(achiId)
    if achievementDef then
        local mapid = EnterSurviveGameInfo.StatisticsData.OWID
        local totaltime = EnterSurviveGameInfo.StatisticsData.EnterTime
        local isnew = 0
        if get_account_register_day() < 1 then
            isnew = 1
        end
        standReportEvent(
            404,
            "CLASSIC_ADVENTURE_TASK",
            "AdventureTask",
            "finish",
            {
                cid = mapid,
                standby1 = achiId .. "_" .. achievementDef.Goal,
                standby2 = totaltime,
                standby3 = isnew
            }
        )
    end
end

function AchievementFrame_OnEvent()
    if arg1 == "GE_ACHIEVEMENT_CHANGE" then
        local ge = GameEventQue:getCurEvent()
        local achiId = ge.body.achievementChange.achievementid
        UpdateAchievementFrameById(achiId)
    end
    if arg1 == "GE_CLIENT_ACHIEVEMENT_CHANGE" then
        local ge = GameEventQue:getCurEvent()
        local achiId = ge.body.clientAchievementChange.achievementid
        local objid = ge.body.clientAchievementChange.objid
        UpdateClientAchievementFrameById(objid,achiId)
    end
    if arg1 == "GE_ACHIEVEMENT_REWARD" then
        local ge = GameEventQue:getCurEvent()
        local group = ge.body.achievementReward.type
        local achiId = ge.body.achievementReward.achievementid
        local achievementDef = AchievementMgr:getAchievementDef(achiId)
        local hasReward = achievementDef and (achievementDef.RewardNum[0] > 0 or achievementDef.RewardNum[1] > 0)
        if achievementDef and t_achievementLabelBtnInfo[group] then
            t_achievementLabelBtnInfo[group].rewardNum = t_achievementLabelBtnInfo[group].rewardNum + 1
        end
        if this:IsShown() then
            UpdateRewardTag()
        else --没显示的时候也要更新一下状态
            if achievementDef ~= nil then
                CurAchievementGroup = achievementDef.Group
                if ClientCurGame:isInGame() then
                    AchievementFrameType = 1
                else
                    AchievementFrameType = 0
                end
                UpdateAchievementState()
            end
        end
        UpdateAchievementFinishTips(achiId)
        UpdateAdvantureRewardTag() --奖杯红点

        --如果没有奖励，主动走领取奖励的流程，这样就不会改动原来的逻辑，又默认把奖励状态等等流转到下一步 code_by:huangfubin
        if not hasReward or achievementDef.RewardDistributionType == 1 then
            ArchievementDecsGetOneTaskReward(achiId)
        end

        --埋点上报
        standReportAchievementFinishEvent(achiId)
    end
end

function UpdateAchievementState()
    local t_info = GetCurTypeAchievemntTable()

    for i = 1, ACHIEVEMENT_NUM_MAX do
        if i <= #(t_info) then
            local achievementDef = t_info[i]
            local frontState = AchievementMgr:getAchievementState(CurMainPlayer:getObjId(), achievementDef.ID)
            local achievementState = GetAchievementState(achievementDef)

            if achievementState == 0 then --判断一下其它存档这个成就的情况
                if 1 == achievementDef.Type and AccountManager:uniAchievementFinish(achievementDef.ID) then
                    achievementState = 1
                end
            elseif achievementState == 22 then
                achievementState = 2
            end

            if frontState ~= achievementState then
                --if AchievementFrameType ~= 0 or achievementDef.Type == 2 then --or not 他人存档
                    AchievementMgr:setAchievementState(CurMainPlayer:getObjId(), t_info[i].ID, achievementState)
                --end
            end
        end
    end
end

--tab按钮
local m_AchievementTabBtnInfo = {
    {uiName = "AchievementFrameExtremityBtn", nameID = 3187}, --极限
    {uiName = "AchievementFrameXinShouBtn", nameID = 3024}, --主线
    {uiName = "AchievementFrameMainBtn", nameID = 3024}, --主线
    {uiName = "AchievementFrameProductionBtn", nameID = 3025}, --生产
    {uiName = "AchievementFrameFightBtn", nameID = 3026}, --战斗
    {uiName = "AchievementFrameOtherBtn", nameID = 3027} --其他
}

function AchievementFrame_OnShow()
    HideAllFrame("AchievementFrame", true)

    if not CurWorld:isExtremityMode() then
        --初始化tab状态
        TemplateTabBtn2_SetState(m_AchievementTabBtnInfo, 3)
        for i = 2, #(t_achievementLabelBtnInfo) do
            local btn = getglobal(t_achievementLabelBtnInfo[i].name)
            btn:Show()
        end
        getglobal("AchievementFrameExtremityBtn"):Hide()
        local achievementFrameMainBtn = getglobal("AchievementFrameMainBtn")
        achievementFrameMainBtn:Checked()
        --UI图上没看见这个东西。不知道是啥。Hyy
        -- getglobal("AchievementFrameScoreBkg"):Hide()
        -- getglobal("AchievementFrameScore"):clearHistory()
        -- getglobal("AchievementFrameScore"):Clear()
        CurAchievementGroup = 2
        UpdateAchievementLabelBtnState("AchievementFrameMainBtn")
    else
        --初始化tab状态
        TemplateTabBtn2_SetState(m_AchievementTabBtnInfo, 1)
        for i = 2, #(t_achievementLabelBtnInfo) do
            local btn = getglobal(t_achievementLabelBtnInfo[i].name)
            btn:Hide()
        end
        getglobal("AchievementFrameExtremityBtn"):Show()
        --UI图上没看见这个东西。不知道是啥。Hyy
        -- getglobal("AchievementFrameScoreBkg"):Show()
        -- local score = AccountManager:getAccountData():getOWScore(CurWorld:getOWID())
        -- local szText = GetS(133) .. score
        -- getglobal("AchievementFrameScore"):SetText(szText, 98, 65, 48)
        CurAchievementGroup = 6
        UpdateAchievementLabelBtnState("AchievementFrameExtremityBtn")
    end
    UpdateRewardTag()
    UpdateAchievementInfo()
    SetDefaultAchievementShow()

    UpdateSlidingFrameSize()
    UpdateAchievementPoint()

    if not getglobal("AchievementFrame"):IsReshow() then
        ClientCurGame:setOperateUI(true)
    end
end

function UpdateRewardTag()
    for i = 1, #(t_achievementLabelBtnInfo) do
        if i > 1 then --新手类型的暂时没有
            local rewardTag = getglobal(t_achievementLabelBtnInfo[i].name .. "RewardTag")
            if t_achievementLabelBtnInfo[i].rewardNum > 0 then
                rewardTag:Show()
            else
                rewardTag:Hide()
            end
        end
    end
end


--冒险成就红点
function UpdateAdvantureRewardTag()
    local playAchievementBtnEffect = getglobal("PlayAchievementBtnEffect"); 
    local playAchievementBtnRewardTag = getglobal("PlayAchievementBtnRewardTag")
    if hasFinishAchievement() then
        playAchievementBtnRewardTag:Show()
        playAchievementBtnEffect:Show();
		playAchievementBtnEffect:SetUVAnimation(100, true)
		threadpool:work(function ()
			threadpool:wait(3)
			playAchievementBtnEffect:Hide()
		end)
    else
        playAchievementBtnRewardTag:Hide()
		playAchievementBtnEffect:Hide();
    end
end

function AchievementFrame_OnHide()
    ShowMainFrame()
    local achievementIconInfo = getglobal("AchievementIconInfo")
    achievementIconInfo:resetOffsetPos()
    if not getglobal("AchievementFrame"):IsRehide() then
        ClientCurGame:setOperateUI(false)
    end
end

function AchievementFrameCloseBtn_OnClick()
    local achievementFrame = getglobal("AchievementFrame")
    achievementFrame:Hide()
end

function AchievementFrameExtremityBtn_OnClick()
end

function AchievementFrameMainBtn_OnClick()
    if CurAchievementGroup ~= 2 then
        CurAchievementGroup = 2
        UpdateAchievementLabelBtnState("AchievementFrameMainBtn")

        UpdateAchievementInfo()
        SetDefaultAchievementShow()
        UpdateSlidingFrameSize()
        AutoJumpToAchievement(CurChooseAchievementId)
    else
        this:SetChecked(false)
    end
end

function AchievementFrameProductionBtn_OnClick()
    if CurAchievementGroup ~= 3 then
        CurAchievementGroup = 3
        UpdateAchievementLabelBtnState("AchievementFrameProductionBtn")

        UpdateAchievementInfo()
        SetDefaultAchievementShow()
        UpdateSlidingFrameSize()
        AutoJumpToAchievement(CurChooseAchievementId)
    else
        this:SetChecked(false)
    end
end

function AchievementFrameFightBtn_OnClick()
    if CurAchievementGroup ~= 4 then
        CurAchievementGroup = 4
        UpdateAchievementLabelBtnState("AchievementFrameFightBtn")

        UpdateAchievementInfo()
        SetDefaultAchievementShow()
        UpdateSlidingFrameSize()
        AutoJumpToAchievement(CurChooseAchievementId)
    else
        this:SetChecked(false)
    end
end

function AchievementFrameOtherBtn_OnClick()
    if CurAchievementGroup ~= 5 then
        CurAchievementGroup = 5
        UpdateAchievementLabelBtnState("AchievementFrameOtherBtn")

        UpdateAchievementInfo()
        SetDefaultAchievementShow()
        UpdateSlidingFrameSize()
        AutoJumpToAchievement(CurChooseAchievementId)
    else
        this:SetChecked(false)
    end
end

function UpdateAchievementLabelBtnState(btnName)
    local achievementLine = getglobal("AchievementLine")
    achievementLine:clearLine()
    local achievementIconInfo = getglobal("AchievementIconInfo")
    achievementIconInfo:resetOffsetPos()
    TemplateTabBtn2_SetState(m_AchievementTabBtnInfo, getglobal(btnName):GetClientID())
end

function GetCurTypeAchievemntTable()
    local t_info = {}

    --	local num = AchievementMgr:getAchievementSize();
    -- local num = ACHIEVEMENT_MAX_LIST;
    -- for i=1,num do
    -- 	local achievementId = i + 1000 -1;
    -- 	local achievementDef = AchievementMgr:getAchievementDef(achievementId);
    -- 	if achievementDef ~= nil and CurAchievementGroup == achievementDef.Group then
    -- 		table.insert(t_info, achievementDef);
    -- 	end
    -- end

	--加一下缓存 by huanglin
    if GroupDefCache[CurAchievementGroup] then
        return GroupDefCache[CurAchievementGroup]
    end
    -- 按组查找 code_by:huangfubin
    if not AchievementMgr.getAchievementIDsByGroup then
        return {} --C++没合并的时候做个容错
    end
    local strIDs = AchievementMgr:getAchievementIDsByGroup(CurAchievementGroup)
    local t_Task = StringSplit(strIDs, ",")
    if type(t_Task) ~= "table" then
        return t_info
    end

    table.sort(
        t_Task,
        function(a, b)
            local numa = tonumber(a) or 999999999
            local numb = tonumber(b) or 999999999
            return numa < numb --主要考虑移动端顺序不是从小到大
        end
    )

    for i = 1, #t_Task do
        local achievementId = tonumber(t_Task[i]) or 0
        local achievementDef = AchievementMgr:getAchievementDef(achievementId)
        if achievementDef ~= nil and CurAchievementGroup == achievementDef.Group then
            table.insert(t_info, achievementDef)
        end
    end
    GroupDefCache[CurAchievementGroup] = t_info
    return t_info
end

function GetTypeAchievemntTable(Group)
    local t_info = {}
    if GroupDefCache[Group] then
        return GroupDefCache[Group]
    end
    local strIDs = AchievementMgr:getAchievementIDsByGroup(Group)
    local t_Task = StringSplit(strIDs, ",")
    if type(t_Task) ~= "table" then
        return t_info
    end

    table.sort(
        t_Task,
        function(a, b)
            local numa = tonumber(a) or 999999999
            local numb = tonumber(b) or 999999999
            return numa < numb --主要考虑移动端顺序不是从小到大
        end
    )

    for i = 1, #t_Task do
        local achievementId = tonumber(t_Task[i]) or 0
        local achievementDef = AchievementMgr:getAchievementDef(achievementId)
        if achievementDef ~= nil and Group == achievementDef.Group then
            table.insert(t_info, achievementDef)
        end
    end
    GroupDefCache[Group] = t_info
    return t_info
end


function UpdateSlidingFrameSize()
    local t_info = GetCurTypeAchievemntTable()
    local maxGridX = 0
    local maxGridY = 0
    for i = 1, #(t_info) do
        if t_info[i].GridX > maxGridX then
            maxGridX = t_info[i].GridX
        end
        if t_info[i].GridY > maxGridY then
            maxGridY = t_info[i].GridY
        end
    end
    local sizeX = 955
    local sizeY = 369
    if maxGridX * 81 + 17 > sizeX then
        sizeX = maxGridX * 81 + 25
    end
    if maxGridY * 81 + 17 > sizeY then
        sizeY = maxGridY * 81 + 25
    end

    local achievementIconInfoPlane = getglobal("AchievementIconInfoPlane")
    MaxSliderX = sizeX
    MaxSliderY = sizeY
    MaxSliderGridX = maxGridX
    MaxSliderGridY = maxGridY
    achievementIconInfoPlane:SetSize(sizeX, sizeY)
end

function UpdateOneAchievementInfo(achiId)
    local achievementDef = AchievementMgr:getAchievementDef(achiId)
    local btn = t_achivementBtn[achievementDef.ID] ;
    if btn ~= nil then 
        local parentName = btn:GetName();

        local btnIcon = getglobal(parentName .. "Icon")
        local btnAward1 = getglobal(parentName .. "Award1")
        local unLock = getglobal(parentName .. "Unlock")
        local lockIcon = getglobal(parentName .. "Lock")
        -- local finishIcon = getglobal(parentName .. "Finish")
        local btnArrow = getglobal(parentName .. "Arrow")
        local bgNormal = getglobal(parentName .. "Normal")
        -- local eyeIcon = getglobal(parentName .. "Eye")
        local stateIcon = getglobal(parentName .. "State")
        local stateLabel = getglobal(parentName .. "StateLabel")
        local frontState = AchievementMgr:getAchievementState(CurMainPlayer:getObjId(), achievementDef.ID)
        local achievementState = GetAchievementState(achievementDef)

        local hasReward = false
        if achievementDef.RewardID[1] > 0 or achievementDef.RewardID[0] > 0 then
            hasReward = true --增加是否有奖励的判断
        end

        if achievementState == 0 then --判断一下其它存档这个成就的情况
            if 1 == achievementDef.Type and AccountManager:uniAchievementFinish(achievementDef.ID) then
                achievementState = 1
            end
        end
        SetDefaultAchievementItemState(btnIcon,bgNormal,lockIcon,stateIcon,stateLabel)

        --0未解锁 1解锁未激活 2激活未完成 22激活可领取奖励  3激活完成
        if achievementState == 0 or  achievementState == 1 then
            btnIcon:Show()
            btnIcon:SetGray(true)
            bgNormal:SetGray(true)
            lockIcon:Show()
            -- finishIcon:Hide()
            btnAward1:Hide()
        elseif achievementState == 2 then 
            btnIcon:Show()
            btnIcon:SetGray(true)
            bgNormal:SetGray(true)
            lockIcon:Hide()
            -- finishIcon:Hide()
            btnAward1:Hide()
        elseif achievementState == 22 then
            btnIcon:Show()
            btnIcon:SetGray(false)
            bgNormal:SetGray(false)
            lockIcon:Hide()
            -- finishIcon:Hide()
            btnAward1:SetUVAnimation(100, true)
            btnAward1:Show()
            if not hasReward then
                btnAward1:Hide() -- 当没有奖励的时候，奖励相关的效果就不播了code_by:huangfubin
                -- finishIcon:Show()
            end
        elseif achievementState == 3 then
            btnIcon:Show()
            btnIcon:SetGray(false)
            bgNormal:SetGray(false)
            lockIcon:Hide()
            -- finishIcon:Show()
            btnAward1:Hide()
        end
        if frontState < ACTIVATE_UNCOMPLETE and achievementState == 2 then --解锁特效
            unLock:SetUVAnimation(100, false)
        end

        if frontState ~= achievementState then
            --if AchievementFrameType ~= 0 or achievementDef.Type == 2 then --or not 他人存档
			if achievementState == 22 then
				AchievementMgr:setAchievementState(CurMainPlayer:getObjId(), achievementDef.ID, 2)
			else
                AchievementMgr:setAchievementState(CurMainPlayer:getObjId(), achievementDef.ID, achievementState)
			end
            --end
        end
        btnArrow:Hide()
        SetItemIcon(btnIcon, achievementDef.IconID)
        SetAchievementBtnLine(achievementDef, btnArrow, achievementState)
        btn:SetPoint(
            "topleft",
            "AchievementLine",
            "topleft",
            81 * (achievementDef.GridX - 1),
            81 * (achievementDef.GridY - 1)
        )
        btn:SetClientUserData(0, achievementDef.ID)
        btn:SetClientUserData(1,achievementState)
        UpdateOneAchievementItemState(btn,stateIcon,stateLabel)
        btn:Show()
    end
end

function SetDefaultAchievementItemState(btnIcon,bgNormal,lockIcon,stateIcon,stateLabel)
    btnIcon:Show()
    btnIcon:SetGray(false)
    bgNormal:SetGray(false)
    lockIcon:Hide()
    stateIcon:Hide()
    stateLabel:Hide()
end

function UpdateAchievementInfo()
    local t_info = GetCurTypeAchievemntTable()
    if t_achivementBtn ~= nil and next(t_achivementBtn) ~= nil then 
        if (t_achivementBtn[CurChooseAchievementId]~= nil) then 
            local Halo =  getglobal(t_achivementBtn[CurChooseAchievementId]:GetName() .. "Halo")
            Halo:Hide()
         end
         if (t_achivementBtn[LastChooseAchievementId]~= nil) then 
             local Halo = getglobal(t_achivementBtn[LastChooseAchievementId]:GetName().."Halo")
             Halo:Hide()
          end
    end
    local achievementIconInfoPlane = getglobal("AchievementIconInfo")
    local currentOffsetX = achievementIconInfoPlane:getCurOffsetX()
    local currentOffsexY = achievementIconInfoPlane:getCurOffsetY()
    t_achivementBtn = {}
    for i = 1, ACHIEVEMENT_NUM_MAX do
        local btn = getglobal("AchievementBtn" .. i)
        if i <= #(t_info) then
            local achievementDef = t_info[i]
            t_achivementBtn[achievementDef.ID] = btn
            UpdateOneAchievementInfo(achievementDef.ID);
        else
            btn:Hide()
        end
    end
end

--achievementState 0未解锁 1解锁未激活 2激活未完成 22激活可领取奖励  3激活完成
function GetAchievementState(achievementDef)
    for i = 1, 4 do
        local frontId = achievementDef.FrontID[i - 1]
        local frontDef = AchievementMgr:getAchievementDef(frontId) --DefMgr:getAchievementDef(frontId);
        if frontId > 0 and frontDef ~= nil then
            if GetAchievementState(frontDef) < 3 then --有前置条件为未完成(可领取奖励除外)，当前的成就状态为0
                return 0
            end
        end
    end

    if AchievementMgr:getAchievementArryNum(CurMainPlayer:getObjId(), achievementDef.ID) >= achievementDef.GoalNum then
        if AchievementMgr:getAchievementRewardState(CurMainPlayer:getObjId(), achievementDef.ID) == REWARD_RECEIVED then --领取了奖励，状态为3
			
            return 3
        else
            if AchievementMgr:getAchievementRewardState(CurMainPlayer:getObjId(), achievementDef.ID) ~= REWARD_CAN_RECEIVE then
                --if AchievementFrameType ~= 0 or achievementDef.Type == 2 then --or not 他人存档
                    AchievementMgr:setAchievementRewardState(CurMainPlayer:getObjId(), achievementDef.ID, 1) --奖励状态设置为可领取状态
                --end
            end
            return 22
        end
    else
        return 2
    end
end

function GetAchievementOthenPlayState(objid,achievementDef)
    for i = 1, 4 do
        local frontId = achievementDef.FrontID[i - 1]
        local frontDef = AchievementMgr:getAchievementDef(frontId) --DefMgr:getAchievementDef(frontId);
        if frontId > 0 and frontDef ~= nil then
            if GetAchievementOthenPlayState(objid,frontDef) < 3 then --有前置条件为未完成(可领取奖励除外)，当前的成就状态为0
                return 0
            end
        end
    end
    local ArryNum = AchievementMgr:getAchievementArryNum(objid, achievementDef.ID);
    if ArryNum >= achievementDef.GoalNum then
        if AchievementMgr:getAchievementRewardState(objid, achievementDef.ID) == REWARD_RECEIVED then --领取了奖励，状态为3
            return 3
        else
            if AchievementMgr:getAchievementRewardState(objid, achievementDef.ID) ~= REWARD_CAN_RECEIVE then
                --if AchievementFrameType ~= 0 or achievementDef.Type == 2 then --or not 他人存档
                    AchievementMgr:setAchievementRewardState(objid, achievementDef.ID, 1) --奖励状态设置为可领取状态
                --end
            end
            return 22
        end
    else
        return 2
    end

end

--画线、箭头
function SetAchievementBtnLine(achievementDef, btnArrow, achievementState)
    local color = "black"
    if achievementState == 2 then
        color = "green"
    elseif achievementState == 3 then
        color = "brown"
    elseif achievementState == 22 then
        color = "green"
    end

    btnArrow:SetTexUV(t_ArrowInfo[color].uvname)
    for i = 1, 4 do
        local frontId = achievementDef.FrontID[i - 1]
        local frontDef = AchievementMgr:getAchievementDef(frontId)
        if frontId > 0 and frontDef ~= nil then
            btnArrow:Show() --有前置条件就显示箭头
            local achievementLine = getglobal("AchievementLine")
            achievementLine:AddLine(
                frontDef.GridX,
                frontDef.GridY,
                achievementDef.GridX,
                achievementDef.GridY,
                t_ArrowInfo[color].r,
                t_ArrowInfo[color].g,
                t_ArrowInfo[color].b
            )
        end
    end
end

--追踪眼睛图标
function UpdateAchievementEye()
    for i = 1, ACHIEVEMENT_NUM_MAX do
        local btn = getglobal("AchievementBtn" .. i)
        local stateIcon = getglobal("AchievementBtn" .. i .."State")
        local stateLabel = getglobal("AchievementBtn" .. i .."StateLabel")
        UpdateOneAchievementItemState(btn,stateIcon,stateLabel)
        --[[
		if 他人地图存档 then
			btnEye:Hide();
		end
		]]
    end
end

function UpdateOneAchievementItemState(btn,stateIcon,stateLabel)
    local ID = btn:GetClientUserData(0)
    if
    AchievementMgr:getCurTrackID() == ID and AchievementMgr:getCurTrackID() > 0 and
        AchievementFrameType == 1
    then
        stateIcon:Show()
        stateLabel:Show()
        stateIcon:SetTextureHuiresXml("ui/mobile/texture0/common.xml")
        stateIcon:SetTexUV("img_tips_black.png");
        stateLabel:SetText(GetS(90012))
    else
        local achievementDef = AchievementMgr:getAchievementDef(ID)

        if achievementDef ~= nil then 
            local achievementState = GetAchievementState(achievementDef)
            if achievementState == 0 then --判断一下其它存档这个成就的情况
                if 1 == achievementDef.Type and AccountManager:uniAchievementFinish(achievementDef.ID) then
                    achievementState = 1
                end
            end
            if achievementState == 0 or  achievementState == 1 then
                stateIcon:Hide()
                stateLabel:Hide()
            elseif achievementState == 2 then 
                stateIcon:Hide()
                stateLabel:Hide()
            elseif achievementState == 22 then
                stateIcon:Show()
                stateLabel:Show()
                stateIcon:SetTextureHuiresXml("ui/mobile/texture0/common.xml")
                stateIcon:SetTexUV("img_num_tips.png");
                stateLabel:SetText(GetS(90011))
            elseif achievementState == 3 then
                stateIcon:Show()
                stateLabel:Show()
                stateIcon:SetTextureHuiresXml("ui/mobile/texture0/common.xml")
                stateIcon:SetTexUV("img_tips_green.png");
                stateLabel:SetText(GetS(90010))
            end
        end
    end
end

function SetDefaultAchievementShow()
    local t_info = GetCurTypeAchievemntTable()
    local achievementDef = AchievementMgr:getAchievementDef(AchievementMgr:getCurTrackID())
    if achievementDef ~= nil then 
        if (achievementDef.Group == CurAchievementGroup) then 
            ShowAchievementById(achievementDef.ID)
            return 
        end
    end
    local x,y,ID 
    for i = 1, #(t_info) do
        if AchievementMgr:getAchievementState(CurMainPlayer:getObjId(), t_info[i].ID) == ACTIVATE_UNCOMPLETE then
            if (x == nil or y == nil) or ( t_info[i].GridX < x or t_info[i].GridY < y ) then 
                x = t_info[i].GridX;
                y = t_info[i].GridY;
                ID = t_info[i].ID;
            end
        end
    end
    UpdateAchievementFrameById(ID)
end

function UpdateAchievementPoint()
    -- local szText = GetS(57) .. AccountManager:getAchievementPoints()
    -- local achievementFramePoint = getglobal("AchievementFramePoint")
    -- achievementFramePoint:SetText(szText, 77, 112, 117)
end

function AchievementBtn_OnClick()
    local achievementId = this:GetClientUserData(0)
    ChooseAchievement(achievementId)
end

function ChooseAchievement(achievementId)
    local btnAward4 = getglobal("AchievementDecsRewardBtnAward4")
    btnAward4:Hide()
    LastChooseAchievementId = CurChooseAchievementId
    CurChooseAchievementId = achievementId
    UpdateAchievementDescShow(achievementId)
    UpdateAchievementBtnHalo(achievementId)
end

function AutoJumpToAchievement(frontId)
    local frontDef = AchievementMgr:getAchievementDef(frontId) 
    if frontDef ~= nil then 
        local achievementIconInfoPlane = getglobal("AchievementIconInfo")
        local x = (955 - MaxSliderX) * UIFrameMgr:GetScreenScaleX()
        local y = (369 - MaxSliderY) * UIFrameMgr:GetScreenScaleY()
        local testx = x / MaxSliderGridX
        local testy = y / MaxSliderGridY - 10
        local disx = (testx * (frontDef.GridX - 1))
        local disy = (testy * (frontDef.GridY -1))
        achievementIconInfoPlane:setCurOffsetX(disx)
        achievementIconInfoPlane:setCurOffsetY(disy)
        ChooseAchievement(frontId)
    end
end

function UpdateAchievementBtnHalo(achievementId)
    local btn = t_achivementBtn[achievementId]
    local lastBtn = t_achivementBtn[LastChooseAchievementId]
    if lastBtn ~= nil then 
        local lastHalo = getglobal(lastBtn:GetName() .. "Halo")
        if(LastChooseAchievementId ~= CurChooseAchievementId) then 
            lastHalo:Hide()
        end
    end
    if btn ~= nil then 
        local halo = getglobal(btn:GetName() .. "Halo")
        if btn:GetClientUserData(0) == CurChooseAchievementId then
            halo:SetUVAnimation(50, true)
            halo:Show()
        else
            halo:Hide()
        end
    end
end

function UpdateAchievementDescShow(achievementId)
    UpdateAchievementDesc(achievementId)
    UpdateAchievementFrontCondition(achievementId)
    UpdateAchievementReward(achievementId)
    UpdateUpdateAchievementTrackBtnShow()
end

function  Desc_OnClick()
    local achievementDef = AchievementMgr:getAchievementDef(CurChooseAchievementId)
    if achievementDef ~= nil then 
        local name = this:GetName()
        SetMTipsInfo(-1, name, false, achievementDef.GoalId);
    end
end

function  Condition_OnClick()
    local achievementDef = AchievementMgr:getAchievementDef(CurChooseAchievementId)
    if achievementDef ~= nil then 
        for i = 1, 4 do
            local frontId = achievementDef.FrontID[i - 1]
            local frontDef = AchievementMgr:getAchievementDef(frontId) 
            if frontId > 0 and frontDef ~= nil then
                if (arg1 == frontDef.Name) then 
                    AutoJumpToAchievement(frontId)
                end
            end
        end
    end
   
end

function UpdateAchievementFrontCondition(achievementId)
    local achievementDef = AchievementMgr:getAchievementDef(achievementId)
    if achievementDef ~= nil then 
        local desc = getglobal("AchievementDecsConditionTitle")
        local descStr = ""
        local totalId = 0
        for i = 1, 4 do
            local frontId = achievementDef.FrontID[i - 1]
            local frontDef = AchievementMgr:getAchievementDef(frontId) 
            if frontId > 0 and frontDef ~= nil then
                totalId = 1 + totalId
                if AchievementMgr:getAchievementState(CurMainPlayer:getObjId(), frontId) == ACTIVATE_COMPLETE then
                    descStr = descStr.."#L".."#cf5aa00"..frontDef.Name .."#n、"
                else
                    descStr = descStr.."#L".."#c626161"..frontDef.Name .."#n、"
                end
            end
        end
        if totalId ~= 0 then 
            local length = string.len(descStr) -3
            local Str = string.sub(descStr,1, length)
            Str = Str .. "#cff891f"
            descStr =  GetS(90004, Str)
        end
        desc:SetText(descStr,255,137,31)
    end
end


--描述
function UpdateAchievementDesc(achievementId)
    local achievementDef = AchievementMgr:getAchievementDef(achievementId) --DefMgr:getAchievementDef(achievementId);
    local btn = t_achivementBtn[achievementId]
    if achievementDef ~= nil and btn ~= nil then
        local achievementState = btn:GetClientUserData(1)
        local achievementStateStr  
        --0未解锁 1解锁未激活 2激活未完成 22激活可领取奖励  3激活完成
        if achievementState == 0 or achievementState == 1 then 
            achievementStateStr = GetS(90003)
        elseif achievementState == 22 or achievementState == 3 then
            achievementStateStr = GetS(90001)
        else
            achievementStateStr = GetS(90002)
        end
        local achievementDecsText = getglobal("AchievementDecsText")
        -- local szText = achievementDef.Name
        --	if AchievementFrameType == 1 or achievementDef.Type == 2 then --and not 他人地图存档		--存档成就或者成就类型为帐号成就的时候才显示进度
        local num = achievementDef.GoalNum
        local arryNum = AchievementMgr:getAchievementArryNum(CurMainPlayer:getObjId(), achievementDef.ID)
        -- szText = achievementDef.Name .. "#cf15200(" .. arryNum .. "/" .. num .. ")"
        --	end
        if arryNum > num then 
            arryNum = num
        end
        local str = "(" .. arryNum .. "/" .. num .. ")"
        str = HandleString(achievementDef.Desc,str)
        achievementDecsText:SetText(str, 151, 151, 151)
        local achievementDecsName = getglobal("AchievementDecsName")
        achievementDecsName:SetText(achievementDef.Name.."("..achievementStateStr..")", 61, 69, 70)
        local achievementDesc = getglobal("AchievementDecsConditionTitle")
        local achievementDesPicture = getglobal("AchievementDecsPicture")
        if achievementDef.GuidePicture ~= nil and achievementDef.GuidePicture ~= "" then 
            achievementDesPicture:Show()
            achievementDesPicture:SetTexture("ui/achievement/"..achievementDef.GuidePicture..".png");
            achievementDecsName:SetPoint("bottomleft","AchievementFrameBkg","bottomleft",280,-126)
            achievementDesc:SetSize(480,24)
        else
            achievementDecsName:SetPoint("bottomleft","AchievementFrameBkg","bottomleft",36,-126)
            achievementDesPicture:Hide()
            achievementDesc:SetSize(700,24)
        end
    end
end

--奖励
function UpdateAchievementReward(achievementId)
    local achievementDef = AchievementMgr:getAchievementDef(achievementId)
    if achievementDef == nil then
        return
    end

    local hasReward = false --没有奖励的时候，领取奖励按钮
    for i = 1, 2 do
        local rewardIcon = getglobal("AchievementDecsReward" .. i)
        local numFont = getglobal("AchievementDecsRewardNum" .. i)
        local rewardItemBtn = getglobal("AchievementDecsRewardItemBtn" .. i)
        if achievementDef.RewardID[i - 1] > 0 then
            hasReward = true
            if achievementDef.RewardType[i - 1] == 0 then
                SetItemIcon(rewardIcon, achievementDef.RewardID[i - 1])
                rewardItemBtn:SetClientUserData(0, achievementDef.RewardID[i - 1]) --用来标记奖励物品的itemID;
            elseif achievementDef.RewardType[i - 1] == 1 then
                rewardIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml")
                rewardIcon:SetTexUV("icon_xingxing.png")
                rewardItemBtn:SetClientUserData(0, -1) --用来标记星星;
            elseif achievementDef.RewardType[i - 1] == 2 then
                rewardIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml")
                rewardIcon:SetTexUV("icon_coin")
                rewardItemBtn:SetClientUserData(0, -2) --用来标记迷你币;
            end
            numFont:SetText("×" .. achievementDef.RewardNum[i - 1])
        else
            rewardIcon:SetTextureHuires(ClientMgr:getNullItemIcon())
            numFont:SetText("")
            rewardItemBtn:SetClientUserData(0, 0)
        end
    end

    ShowAchievementDecsReward(hasReward) --有配置奖励才显示 code_by:huangfubin

    local btn = getglobal("AchievementDecsRewardBtn")
    local btnNormal = getglobal("AchievementDecsRewardBtnNormal")
    local btnName = getglobal("AchievementDecsRewardBtnName")

    local btnAward4 = getglobal("AchievementDecsRewardBtnAward4")
    btnAward4:Hide()
    local state = AchievementMgr:getAchievementRewardState(CurMainPlayer:getObjId(), achievementId)
	local receiveFrame = getglobal("AchievementDecsReceive")
    if state == REWARD_UNRECEIVE then
        --	btnName:SetTexUV(802, 992, 120, 30);
        --	btnName:SetSize(135, 34);
        btn:Disable()
        btnNormal:SetGray(true)
		btn:Show()
		receiveFrame:Hide()
    elseif state == REWARD_CAN_RECEIVE then
        btn:Enable()
        btnNormal:SetGray(false)
        btnName:SetTextColor(55, 54, 51)
        --	btnName:SetTexUV(802, 992, 120, 30);
        --	btnName:SetSize(135, 34);
        local btnAward4 = getglobal("AchievementDecsRewardBtnAward4")
        btnAward4:SetUVAnimation(100, true)
		btn:Show()
		receiveFrame:Hide()
    elseif state == REWARD_RECEIVED then
        btn:Disable()
        btnNormal:SetGray(true)
    --	btnName:SetTexUV(933, 992, 89, 30);
    --	btnName:SetSize(100, 34);
		btn:Hide()
		receiveFrame:Show()
    end

    if AchievementFrameType == 0 and achievementDef.Type == 1 then --or 他人地图存档 --如果是帐号成就，类型为普通的成就 不可领取奖励
        btn:Disable()
        btnNormal:SetGray(true)
        local btnAward4 = getglobal("AchievementDecsRewardBtnAward4")
        btnAward4:Hide()
    end

	local dateText = getglobal("AchievementDecsRewardDate")
	local dateJson = AchievementMgr:getAchievementCompleteDate(CurMainPlayer:getObjId(), achievementId)
	local dateTab = JSON:decode(dateJson)
	if not dateTab or dateTab.year == 0 then
		dateText:SetText("")
	else
		local str = string.format("%d/%02d/%02d", dateTab.year, dateTab.mon, dateTab.day)
		dateText:SetText(str)
	end
end

--显示或者隐藏成就任务奖励 code_by:huangfubin
function ShowAchievementDecsReward(bshow)
    local framenames = {
        "RewardTitle",
        "Reward1",
        "RewardNum1",
        "RewardItemBtn1",
        "Reward2",
        "RewardNum2",
        "RewardItemBtn2",
        "RewardBtn"
    }
    for i = 1, #framenames do
        if bshow then
            getglobal("AchievementDecs" .. framenames[i]):Show()
        else
            getglobal("AchievementDecs" .. framenames[i]):Hide()
        end
    end
end

function AchievementDecsRewardItemBtn_Onclick()
    local itemId = this:GetClientUserData(0)
    local name = this:GetName()
    SetMTipsInfo(-1, name, false, itemId);
end

function UpdateUpdateAchievementTrackBtnShow()
    -- if CurChooseAchievementId == Achi
    local btn = t_achivementBtn[CurChooseAchievementId]
    if btn ~= nil then 
        local trackBtn = getglobal("AchievementDecsTrackBtn")
        if btn:GetClientUserData(1) == 2 then 
            trackBtn:Show()
            UpdateAchievementTrackTag()
        else
            trackBtn:Hide()
        end
    end
end

--追踪标记
function UpdateAchievementTrackTag()
    local AchievementDecsTrackBtnTrackTag = getglobal("AchievementDecsTrackBtnTrackTag")
    if AchievementFrameType == 0 then -- or 他人地图存档				--帐号成就不允许追踪
        AchievementDecsTrackBtnTrackTag:Hide()
        return
    end
    if AchievementMgr:getCurTrackID() == CurChooseAchievementId then
        AchievementDecsTrackBtnTrackTag:Show()
    else
        AchievementDecsTrackBtnTrackTag:Hide()
    end
end

--追踪
function AchievementDecsTrackBtn_OnClick()
    --[[
		if 他人地图存档 then
			return;
		end
	]]
    if AchievementMgr:getAchievementState(CurMainPlayer:getObjId(), CurChooseAchievementId) == ACTIVATE_UNCOMPLETE and AchievementFrameType == 1 then --存档成就才可以点击追踪
        local achievementDecsTrackBtnTrackTag = getglobal("AchievementDecsTrackBtnTrackTag")
        if achievementDecsTrackBtnTrackTag:IsShown() then
            achievementDecsTrackBtnTrackTag:Hide()
            AchievementMgr:setCurTrackID(0)
            IsOpenTrack = false
        else
            achievementDecsTrackBtnTrackTag:Show()
            AchievementMgr:setCurTrackID(CurChooseAchievementId)
            IsOpenTrack = true
        end
        UpdateAchievementEye()
        UpdateTaskTrackFrame()
    end
end

function UpdateTrackInfo()
    if AchievementFrameType == 0 then --or 他人地图存档	--帐号成就不更新追踪面板
        return
    end
    if AchievementMgr:getAchievementState(CurMainPlayer:getObjId(), AchievementMgr:getCurTrackID()) == ACTIVATE_UNCOMPLETE then
        local achievementDef = AchievementMgr:getAchievementDef(AchievementMgr:getCurTrackID())
        if achievementDef == nil then
            AchievementMgr:setCurTrackID(0)
        else
            local num = achievementDef.GoalNum
            local arryNum = AchievementMgr:getAchievementArryNum(CurMainPlayer:getObjId(), achievementDef.ID)
            if arryNum >= num then
                local achievementDecsTrackBtnTrackTag = getglobal("AchievementDecsTrackBtnTrackTag")
                achievementDecsTrackBtnTrackTag:Hide()
                if IsOpenTrack then
                    AchievementMgr:setCurTrackID(GetCurMainTaskId())
                else
                    AchievementMgr:setCurTrackID(0)
                end

                -- 1111埋点
                local worldDesc = AccountManager:getCurWorldDesc()
                if worldDesc then
                    local since_create = AccountManager:get_time_since_create() or 0
                    local playType = "0" --1.当天新增玩家、0.老玩家
                    if since_create < 86400 then
                        playType = "1"
                    end
                    local mapid = 0
                    if worldDesc.worldid then
                        mapid = worldDesc.worldid
                    end
                    local fromowid = 0
                    if worldDesc.fromowid and worldDesc.fromowid > 0 then
                        fromowid = worldDesc.fromowid
                    end
                    local isOwnMap = 0
                     --是否自己的地图 （1自己的地图 0别人的地图）
                    if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
                        if worldDesc.realowneruin == AccountManager:getUin() then
                            isOwnMap = 1
                        end
                    end
                    if isOwnMap == 1 and worldDesc.open > 0 and fromowid == 0 then
                        fromowid = mapid
                    end
                    statisticsGameEventNew(
                        1111,
                        achievementDef.ID,
                        achievementDef.Group,
                        mapid,
                        fromowid,
                        playType,
                        isOwnMap
                    )
                end
            end
        end
    end
    UpdateAchievementEye()
    UpdateTaskTrackFrame()
end

function hasFinishAchievement()
    for i = 1, #(t_achievementLabelBtnInfo) do
        if i > 1 then --新手类型的暂时没有
            local rewardTag = getglobal(t_achievementLabelBtnInfo[i].name .. "RewardTag")
            if t_achievementLabelBtnInfo[i].rewardNum > 0 then
                return true
            end
        end
    end

    return false
end

--领取某个成就任务的奖励
function ArchievementDecsGetOneTaskReward(taskId)
	if AchievementMgr:getAchievementRewardState(CurMainPlayer:getObjId(), taskId) == REWARD_RECEIVED then
		return
	end
    local achievementDef = AchievementMgr:getAchievementDef(taskId) --DefMgr:getAchievementDef(taskId);
    if achievementDef ~= nil then
        CurAchievementGroup = achievementDef.Group --主要处理领取奖励的时候刷新的问题
        for i = 1, 2 do
            local type = achievementDef.RewardType[i - 1]
            local itemId = achievementDef.RewardID[i - 1]
            local num = achievementDef.RewardNum[i - 1]
            if type == 0 then
                if itemId > 0 and CurMainPlayer and ClientCurGame and ClientCurGame:isInGame() then
                    local itemdef = DefMgr:getItemDef(itemId)
					local itemName = itemdef.Name.."*"..num
					ShowGameTips(GetS(90009, itemName), 5, itemId, num)
                end
            else
                if type == 1 then
                elseif type == 2 then
                end
            end
        end
        -- 逻辑发放
        CurMainPlayer:getAchievementAward(taskId)

        AchievementMgr:setAchievementState(CurMainPlayer:getObjId(), taskId, 3)
        AchievementMgr:setAchievementRewardState(CurMainPlayer:getObjId(), taskId, 2)
		if not t_achievementLabelBtnInfo[CurAchievementGroup] then
			--assert("t_achievementLabelBtnInfo[CurAchievementGroup] ", CurAchievementGroup)
		else
			t_achievementLabelBtnInfo[CurAchievementGroup].rewardNum = t_achievementLabelBtnInfo[CurAchievementGroup].rewardNum - 1
		end


        UpdateAchievementState() --这里应该先更新整体状态
        UpdateAchievementInfo()
        UpdateAchievementDescShow(taskId)
        UpdateTrackInfo()
        UpdateRewardTag()
        UpdateAchievementPoint()

        UpdateAdvantureRewardTag() --更新奖杯的红点

        local btnName = GetCurSelectAchievementBtn()
        if btnName ~= nil then
            local btnAward2 = getglobal(btnName .. "Award2")
            btnAward2:SetUVAnimation(100, false)

            local btnAward3 = getglobal("AchievementDecsRewardBtnAward3")
            btnAward3:SetUVAnimation(100, false)
            local btnAward4 = getglobal("AchievementDecsRewardBtnAward4")
            btnAward4:Hide()
        end

        ClientMgr:playSound2D("sounds/ui/info/achievement_complete.ogg", 1)

        StatisticsTools:gameEvent("AchievementTakeReward", "AchievementID", taskId)
        if taskId == 1010 then
            TamedAnimal_RequestReview = 1
        elseif taskId == 1012 then
            TamedAnimal_RequestReview = 2
        end
    end
end

--领取奖励
function AchievementDecsRewardBtn_OnClick()
    ArchievementDecsGetOneTaskReward(CurChooseAchievementId) -- 封装领取奖励的逻辑，其他地方调用 code_by:huangfubin
end

function GetCurSelectAchievementBtn()
    -- local t_info = GetCurTypeAchievemntTable()
    -- for i = 1, ACHIEVEMENT_NUM_MAX do
    --     if i < #(t_info) then
    --         local btn = getglobal("AchievementBtn" .. i)
    --         if btn:GetClientUserData(0) == CurChooseAchievementId then
    --             return btn:GetName()
    --         end
    --     end
    -- end
    -- return nil
    if t_achivementBtn[CurChooseAchievementId] ~= nil then 
        return t_achivementBtn[CurChooseAchievementId]:GetName()
    else
        return nil
    end
end

function AchievementFrameArrow_OnLoad()
    this:setUpdateTime(0.05)
end

--更新箭头
local changeSpeed = 2
local changeOffset = changeSpeed
local curOffset = 0
function AchievementFrameArrow_OnUpdate()
    curOffset = curOffset + changeOffset
    if curOffset > 15 then
        curOffset = 15
        changeOffset = -changeSpeed * 0.5
    elseif curOffset <= 0 then
        curOffset = 0
        changeOffset = changeSpeed
    end

    local achievementIconInfo = getglobal("AchievementIconInfo")
    local achievementFrameArrowTop = getglobal("AchievementFrameArrowTop")
    if achievementIconInfo:getCanMoveTopDistance() > 0 then
        achievementFrameArrowTop:Show()
    else
        achievementFrameArrowTop:Hide()
    end

    local achievementFrameArrowLeft = getglobal("AchievementFrameArrowLeft")
    if achievementIconInfo:getCanMoveLeftDistance() > 0 then
        achievementFrameArrowLeft:Show()
    else
        achievementFrameArrowLeft:Hide()
    end

    local achievementFrameArrowBottom = getglobal("AchievementFrameArrowBottom")
    if achievementIconInfo:getCanMoveBottomDistance() > 0 then
        achievementFrameArrowBottom:Show()
    else
        achievementFrameArrowBottom:Hide()
    end

    local achievementFrameArrowRight = getglobal("AchievementFrameArrowRight")
    if achievementIconInfo:getCanMoveRightDistance() > 0 then
        achievementFrameArrowRight:Show()
    else
        achievementFrameArrowRight:Hide()
    end

    if achievementFrameArrowTop:IsShown() then
        achievementFrameArrowTop:SetPoint("bottom", "AchievementFrameIconBox", "top", 0, 20 - curOffset)
    end
    if achievementFrameArrowLeft:IsShown() then
        achievementFrameArrowLeft:SetPoint("right", "AchievementFrameIconBox", "left", 20 - curOffset, 0)
    end
    if achievementFrameArrowBottom:IsShown() then
        achievementFrameArrowBottom:SetPoint("bottom", "AchievementFrameIconBox", "bottom", 0, 10 + curOffset)
    end
    if achievementFrameArrowRight:IsShown() then
        achievementFrameArrowRight:SetPoint("right", "AchievementFrameIconBox", "right", 10 + curOffset, 0)
    end
end
