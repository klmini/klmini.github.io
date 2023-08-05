-- 简版
_G.Lite = {

    m_funcGetGlobal = nil,

    m_funcEmpty = function()end,
    -- save c++ ui object in a map
    m_mUiNameToUiObject = {},

    -- 拦截以保存的全局函数
    m_aInterceptedGlobalFunctions = {},

    --[[
    拦截_G下面的类的函数，
    * 结构：
    * [类名]
    *  *  [函数名] - [函数体]
    ]]
    m_mInterceptedTableFunctions = {},

    --[[
    结构
    apiid
    *  HIDDEN_UI_NAMES
    *  *  [UI名字] - 配置开关
    *  GLOBAL_FUNC_NAMES
    *  *  [函数名] - 配置开关
    *  GLOBAL_FUNC_NAMES_NEED_RESTORING_IN_ONLINE_ROOM
    *  *  [函数名] - 配置开关
    *  CLASS_NAMES_TO_FUNC_NAMES
    *  *  [类名]
    *  *  *  [函数名] - 配置开关
    ]]
    API_ID_TO_MULTI_UI_NAMES_MAP = {
        -- PC教育版 start
        [610] = {
            -- 需要隐藏的UI名字
            HIDDEN_UI_NAMES = {
                -- 大厅顶部
                ["MiniLobbyFrameTopRoleInfoHeadPushedBG"] = true,
                ["MiniLobbyFrameTopMiniBean"] = true,
                ["MiniLobbyFrameTopMiniCoin"] = true,
                ["MiniLobbyFrameTopActivity"] = true,
                ["MiniLobbyFrameTopMail"] = true,

                -- 大厅主界面
                ["MiniLobbyFrameCenterHomeChest"] = true,

                -- 大厅底部
                ["MiniLobbyFrameBottomShrink"] = true,
                ["MiniLobbyFrameBottomShop"] = true,
                ["MiniLobbyFrameBottomBuddy"] = true,
                ["MiniLobbyFrameBottomFacebookThumbUp"] = true,
                ["MiniLobbyFrameBottomCommunity"] = true,
                ["MiniLobbyFrameBottomVideoLive"] = true,
                ["MiniLobbyFrameBottomSubscribe"] = true,
                ["MiniLobbyFrameBottomNotice"] = true,
                ["MiniLobbyFrameBottomNoticeBkg"] = true,
                ["MiniLobbyFrameBottomNoticeText"] = true,

                -- 右上角设置
                ["SetMenuFrameFAQBtn"] = true,
                ["SetMenuFrameFeedBackBtn"] = true,
                ["SetMenuFrameFeedBackBtn2"] = true,
                ["SetMenuFrameQueryData"] = true,
                ["SetMenuFrameQueryData2"] = true,
                ["SetMenuFrameGotoQQForum"] = true,
                ["SetMenuFrameGotoQQForum2"] = true,

                -- 基础设置
                ["GameSetFrameNoticeBtn"] = true,
                ["GameSetFrameOfficialWebBtn"] = true,
                ["GameSetFrameBaseLayersScrollMotifyName"] = true,

                -- 其它设置
                ["GameSetFrameOtherAgreement"] = true,
                ["GameSetFrameOtherAgreement2"] = true,

                -- 存档内游戏
                ["GongNengFrameScreenshotBtn"] = true,
                ["GongNengFrameMenuArrow"] = true,
                ["CreateBackpackFrameStashBtn"] = true,
            --    ["RoomUIFrameFuncOptionWatchInfoBtn"] = true,
                ["AccRideCallBtn"] = true,
            },

            -- 拦截_G的Lua函数
            GLOBAL_FUNC_NAMES = {
                -- 大厅左上角头像
                ["MiniLobbyFramePlayerCenter_OnClick"] = true,
                -- 开始游戏左侧旋转模型
                ["LobbyFrameViewJumpStore_OnClick"] = true,
                -- F键好友
                ["AccelKey_Friends"] = true,
                -- H键坐骑
                ["AccelKey_Mount"] = true,
                -- O键装扮
                ["AccelKey_StoreSkin"] = true,
                -- 商店
                ["AccelKey_Store"] = true,
                -- I键仓库
                ["AccelKey_StoreInventory"] = true, 
                -- P键[Desc2]
                ["AccelKey_StoreChargeMoney"] = true,
                -- 迷你工坊地图详情头像
                ["NewArchiveInfoFrameIntroduceLinkName_OnClick"] = true,
                -- 存档游戏内查看好友信息
        --        ["RoomUIFrameFuncOptionWatchInfoBtn_OnClick"] = true,
                -- 查看地图作者头像
                ["ArchiveInfoFrameHeadBtn_OnClick"] = true,
                -- 公告
                ["AdvertFrame_OnShow"] = true,
                -- 公告
                ["GongNengFrameActivityGNBtn_OnClick"] = true,
                -- 公告
                ["AdvertFrame_OnShow"] = true,

                ["MiniLobbyFrameCenterHomeChest_OnClick"] = true,
                ["MiniLobbyFrameTopActivity_OnClick"] = true,
                ["MiniLobbyFrameTopMail_OnClick"] = true,
                ["MiniLobbyFrameTopMiniCoin_OnClick"] = true,
                ["MiniLobbyFrameTopMiniBean_OnClick"] = true,
                ["MiniLobbyFrameBottomShop_OnClick"] = true,
                ["MiniLobbyFrameBottomBuddy_OnClick"] = true,
                ["MiniLobbyFrameBottomFacebookThumbUp_OnClick"] = true,
                ["MiniLobbyFrameBottomVideoLive_OnClick"] = true,
                ["MiniLobbyFrameBottomSubscribe_OnClick"] = true,
                ["GameSetOfficialWebBtn_OnClick"] = true,
                ["GameSetFrameNoticeBtn_OnClick"] = true,
                ["BaseMotifyName_OnClick"] = true,
                ["LoginScreenFrameAgreement_OnClick"] = true,
                ["LoginScreenFrameAgreement3_OnClick"] = true,
                ["AccRideCallBtn_OnClick"] = true,
            },

            GLOBAL_FUNC_NAMES_NEED_RESTORING_IN_ONLINE_ROOM = {
                -- F键好友
                ["AccelKey_Friends"] = true,
            },

            CLASS_NAMES_TO_FUNC_NAMES = {
                ["ActivityMainCtrl"] = {
                    ["Active"] = true,
                },
            },
        },
        -- PC教育版 start

        -- 移动端教育版 start
        [501] = {
            HIDDEN_UI_NAMES = {

            },
        },
        -- 移动端教育版 end

        -- 盒子简版 start
        [98] = {
            HIDDEN_UI_NAMES = {

            },
        },
        -- 盒子简版 end

        -- 海外简版 start
        [398] = {
            HIDDEN_UI_NAMES = {

            },
        },
        -- 海外简版 end
    },
}

-- PC999渠道简版 start
-- Lite.API_ID_TO_MULTI_UI_NAMES_MAP[999] = Lite.API_ID_TO_MULTI_UI_NAMES_MAP[610];
-- 移动端教育版 start
Lite.API_ID_TO_MULTI_UI_NAMES_MAP[501] = Lite.API_ID_TO_MULTI_UI_NAMES_MAP[610];
-- 盒子简版 start
Lite.API_ID_TO_MULTI_UI_NAMES_MAP[98] = Lite.API_ID_TO_MULTI_UI_NAMES_MAP[610];
-- 海外简版 start
Lite.API_ID_TO_MULTI_UI_NAMES_MAP[398] = Lite.API_ID_TO_MULTI_UI_NAMES_MAP[610];

function Lite:NeedHiding()
    return self.API_ID_TO_MULTI_UI_NAMES_MAP[ClientMgr:getApiId()] 
    and self.API_ID_TO_MULTI_UI_NAMES_MAP[ClientMgr:getApiId()].HIDDEN_UI_NAMES 
    and true or false;
end

-- 隐藏简版所有UI
function Lite:HideAllUi()
    local funcSetAllUi = function()
        local apiIdToMultiUiNamesMap = self.API_ID_TO_MULTI_UI_NAMES_MAP[ClientMgr:getApiId()];
        if not apiIdToMultiUiNamesMap then return false end
        local hiddenUiNames = apiIdToMultiUiNamesMap.HIDDEN_UI_NAMES;
        if not hiddenUiNames then return false end
        for k, v in pairs(hiddenUiNames) do 
            self:HideUi(k);
        end
    end

    threadpool:work(funcSetAllUi)
end

-- 隐藏简版单个UI
function Lite:HideUi(szUiName)
    local apiIdToMultiUiNamesMap = self.API_ID_TO_MULTI_UI_NAMES_MAP[ClientMgr:getApiId()];
    if not apiIdToMultiUiNamesMap
        or not apiIdToMultiUiNamesMap.HIDDEN_UI_NAMES 
        or not apiIdToMultiUiNamesMap.HIDDEN_UI_NAMES[szUiName] then 
            return false 
    end

    if not self.m_funcGetGlobal then
        self.m_funcGetGlobal = _G.getglobal;
    end

    local uiNameToUiObjectMap = self.m_mUiNameToUiObject;
    if not uiNameToUiObjectMap then 
        uiNameToUiObjectMap = {}
        self.m_mUiNameToUiObject = uiNameToUiObjectMap;
    end

    local uiObject = uiNameToUiObjectMap[szUiName];
    if not uiObject then 
        uiObject = self.m_funcGetGlobal(szUiName);
        uiNameToUiObjectMap[szUiName] = uiObject;
    end

    uiObject:Hide();
    return true;
end

-- 重写_G的部分函数
function Lite:InitInterceptedFunctions()
    local apiIdToMultiUiNamesMap = self.API_ID_TO_MULTI_UI_NAMES_MAP[ClientMgr:getApiId()];
    if not apiIdToMultiUiNamesMap then return false end
    local aFuncNames = apiIdToMultiUiNamesMap.GLOBAL_FUNC_NAMES;
    if not aFuncNames then return end

    local aInterceptedFunctions = self.m_aInterceptedGlobalFunctions;
    if not aInterceptedFunctions then 
        aInterceptedFunctions = {}
        self.m_aInterceptedGlobalFunctions = aInterceptedFunctions;
    end

    -- 拦截全局函数
    local tClass = _G;
    for szFuncName, func in pairs(tClass) do 
        if type(func) == "function" and func ~= self.m_funcEmpty and aFuncNames[szFuncName] then 
            self.m_aInterceptedGlobalFunctions[szFuncName] = func;
            tClass[szFuncName] = self.m_funcEmpty;
        end
    end

    -- 拦截_G里面类的函数，仅拦截一层
    local mClassNamesToFuncNames = apiIdToMultiUiNamesMap.CLASS_NAMES_TO_FUNC_NAMES;
    if not mClassNamesToFuncNames then return end
    for szClassName, mInterceptedFunctions in pairs(mClassNamesToFuncNames) do 
        if _G[szClassName] and type(_G[szClassName]) == "table" then for szFuncName, func in pairs(_G[szClassName]) do 
            local tInterceptedClass = self.m_mInterceptedTableFunctions[szClassName];
            if mInterceptedFunctions[szFuncName] and _G[szClassName][szFuncName] and type(func) == "function" then 
                if not tInterceptedClass then 
                    tInterceptedClass = {}
                    self.m_mInterceptedTableFunctions[szClassName] = tInterceptedClass;
                end
                tInterceptedClass[szFuncName] = func;
                _G[szClassName][szFuncName] = self.m_funcEmpty;
            end
        end end
    end
end

-- 重写单个函数
function Lite:InterceptFunction(szFuncName, tClass)
    local apiIdToMultiUiNamesMap = self.API_ID_TO_MULTI_UI_NAMES_MAP[ClientMgr:getApiId()];
    if not apiIdToMultiUiNamesMap then return false end
    local aFuncNames = apiIdToMultiUiNamesMap.GLOBAL_FUNC_NAMES;
    if not aFuncNames then return end
    if not tClass then 
        tClass = _G;
    end
    if type(tClass[szFuncName]) == "function" and tClass[szFuncName] ~= self.m_funcEmpty and aFuncNames[szFuncName] then 
        self.m_aInterceptedGlobalFunctions[szFuncName] = func;
        tClass[szFuncName] = self.m_funcEmpty;
    end
end

-- 恢复函数
function Lite:RestoreFunction(szFuncName, tClass)
    if not self.m_aInterceptedGlobalFunctions then return end
    if not tClass then 
        tClass = _G;
    end
    if tClass[szFuncName] ~= self.m_funcEmpty then return end
    tClass[szFuncName] = self.m_aInterceptedGlobalFunctions[szFuncName];
end

-- 恢复在联机房间内可调用的函数
function Lite:RestoreFunctionsInOnlineRoom()
    local apiIdToMultiUiNamesMap = self.API_ID_TO_MULTI_UI_NAMES_MAP[ClientMgr:getApiId()];
    if not apiIdToMultiUiNamesMap then return false end
    local aFuncNamesNeedStoring = apiIdToMultiUiNamesMap.GLOBAL_FUNC_NAMES_NEED_RESTORING_IN_ONLINE_ROOM;
    for szFuncName, ignored in pairs(aFuncNamesNeedStoring) do 
        self:RestoreFunction(szFuncName);
    end
end

-- 联机房间退出后，屏蔽联机房间内可调用的函数
function Lite:InterceptFunctionsOutsideOnlineRoom()
    local apiIdToMultiUiNamesMap = self.API_ID_TO_MULTI_UI_NAMES_MAP[ClientMgr:getApiId()];
    if not apiIdToMultiUiNamesMap then return false end
    local aFuncNamesNeedStoring = apiIdToMultiUiNamesMap.GLOBAL_FUNC_NAMES_NEED_RESTORING_IN_ONLINE_ROOM;
    for szFuncName, ignored in pairs(aFuncNamesNeedStoring) do 
        self:InterceptFunction(szFuncName);
    end
end


--是否是教育版 
isEducationalVersion = false;
