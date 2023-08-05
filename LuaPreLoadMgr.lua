--lua预加载的管理类
g_LuaPreLoadMgr = {
    --调试开关
    -- EnableLuaPreLoad = true, --正式启用，不再使用开关 2022.1.12
    --lua文件加载状态
    LoadStatus = {
        WaitToLoad = 1,
        Loaded = 2,
    },
    --标记已经加载过的文件，避免重复加载
    LoadedLuaFiles = {},
    --
    CurrentLoadingFile = "",
    IsLoadingNewUiLuaFile = false;
}


-- 必要的依赖，其中有些会影响client.lua的加载，例如FriendService和battle
g_LuaPreLoadMgr.MustLoadXmlLua = {
    "ui/mobile/homechest.xml",
    "ui/mobile/friend.xml",
    "ui/mobile/battle.xml",
    "ui/mobile/npcshop.xml",
    "ui/mobile/mvc/shop/Shop.xml",
    "ui/mobile/marketactivity.xml",
    "ui/mobile/playmain.xml",
    "ui/mobile/room.xml",
    "ui/mobile/lobby.xml",
    "ui/mobile/multiplayerlobby.xml",
    "ui/mobile/mvc/lobby/lobbyMapArchiveList/lobbyMapArchiveList.xml",
    "ui/mobile/mvc/WorkSpace/WorkSpaceDetail/WorkSpaceDetail.xml",
    "ui/mobile/mvc/account/Safety/IdentityName/IdentityNameAuth.xml",
    "ui/mobile/mvc/cloudserver/lobby/CloudServerLobby.xml",
    "ui/mobile/activity4399.xml",--需提前加载配置

    -- "ui/mobile/realnameauth.xml",
	-- "ui/mobile/selectrole.xml",
	-- "ui/mobile/room.xml",
	-- "ui/mobile/playercenter.xml",
	-- "ui/mobile/activity.xml",
	-- "ui/mobile/activityMain.xml",
	-- "ui/mobile/sift.xml",
	-- "ui/mobile/mvc/OfficialRewardCenterNew/OfficialRewardCenterNew.xml",
	-- "ui/mobile/homechest.xml",
	-- "ui/mobile/friendchat.xml",
	-- "ui/mobile/mvc/NewBattlePass/NewBattlePass.xml",
	-- "ui/mobile/mvc/NewbieGuide/NewbieCreateRole/NewbieCreateRole.xml",
	-- "ui/mobile/mail.xml",
	-- "ui/mobile/mvc/strongpopup/StrongPopup.xml",
	-- "ui/mobile/mvc/miniworks/MiniWorks.xml",
	-- "ui/mobile/miniworks.xml",
	-- "ui/mobile/mvc/comeBackSystem/HotMap/HotMap.xml",
	-- "ui/mobile/mvc/comeBackSystem/NewHotMap/NewHotMap.xml",
    -- "ui/mobile/vehicleassembly.xml",
}


--加载指定lua文件
g_LuaPreLoadMgr.LoadALuaFile = function (self, filePath)
    if not filePath then return end
    if self.LoadedLuaFiles[filePath] == self.LoadStatus.Loaded then
        print("LoadALuaFile try reload file", filePath)
        return
    end
    self.CurrentLoadingFile = filePath;
    GameUI:parseSingleTOCFile(0, filePath)

    self.LoadedLuaFiles[filePath] = self.LoadStatus.Loaded
end

g_LuaPreLoadMgr.GetCurrentLoadingLuaFile = function (self)
    return self.CurrentLoadingFile
end

g_LuaPreLoadMgr.SetCurrentLoadingNewUiLuaFileType = function (self,loadtype)
    self.IsLoadingNewUiLuaFile = loadtype
end

g_LuaPreLoadMgr.GetCurrentLoadingNewUILuaFileType =  function (self)
    return  self.IsLoadingNewUiLuaFile
end
