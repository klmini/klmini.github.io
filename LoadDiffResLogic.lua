local country = get_game_country();
local land = get_game_lang();

g_LoadDiffResMgr = {
    t_LangKey = {
        get_game_lang().."";
        "common",
    },
    t_countryKey = {
        get_game_country().."";
        "country_common",
    },
}

------------------------------------------------------游戏进度条加载UI--------------------------------------------------------
---
-- 获取差异化加载xml的替换路径
-- 用于替换主toc文件里的xml文件的加载
-- oldPath 为toc文件里的xml文件路径
-- 仅用于海外版本
g_LoadDiffResMgr.GetReplaceUIXMLPath = function(self, oldPath)
    print("kgq GetReplaceUIXMLPath", oldPath, g_tUI_DIFF)
    if not isAbroadEvn() or oldPath == "" or not g_tUI_DIFF then
        return "";
    end

    local path = self:GetReplaceCfg(oldPath, g_tUI_DIFF)
    if path then
        return path;
    end
    
    return "";
end

-- 获取差异化xml的配置
-- oldPath：原xml文件路径 t_src：差异配置
g_LoadDiffResMgr.GetReplaceCfg = function(self, oldPath, t_src)
    print("kgq GetReplaceCfg", key, oldPath)
    
    for i=1, #(self.t_LangKey) do
        local langCfg = t_src[self.t_LangKey[i]];
        if langCfg then
            for j=1,#(self.t_countryKey) do
                local countryCfg = langCfg[self.t_countryKey[j]];
                if countryCfg and countryCfg["replacexml"] and countryCfg["replacexml"][oldPath] then
                    return countryCfg["replacexml"][oldPath];
                end
            end
        end
    end

    return nil;
end

--在游戏加载进度条时加载差异化新增文件
g_LoadDiffResMgr.LoadDiffUIByGameLoading = function(self)
    print("kgq LoadDiffUIByGameLoading")
    if not isAbroadEvn() or not g_tUI_DIFF then
        return;
    end

    local t_loadedXmlList = {

    }

    local t_loadedLuaList = {

    }


    for i=1, #(self.t_LangKey) do
        local langCfg = g_tUI_DIFF[self.t_LangKey[i]];
        if langCfg then
            for j=1,#(self.t_countryKey) do
                local countryCfg = langCfg[self.t_countryKey[j]];
                if countryCfg and countryCfg.newxml and type(countryCfg.newxml) == 'table' then
                    self:LoadDiffUIFile(countryCfg.newxml, t_loadedXmlList);
                end

                if countryCfg and countryCfg.lua and type(countryCfg.lua) == 'table' then
                    self:LoadDiffUIFile(countryCfg.lua, t_loadedLuaList);
                end
            end
        end
    end
end

--把新增差异化文件添加到游戏加载进度条的toc里
--t_files：差异化文件 t_loadedList：已记录加载的文件列表
g_LoadDiffResMgr.LoadDiffUIFile = function(self, t_files, t_loadedList)
    for i=1, #(t_files) do
        if not self:isLoaded(t_loadedList, t_files[i]) and GameUI.addLuaTocFileList then  --记录过的就不要再加载了
            GameUI:addLuaTocFileList(t_files[i]);
        end
    end
end

--判断文件是否记录到加载列表里了
--t_loadedList：已记录加载的文件列表 path:需要判断是否记录的文件路径
g_LoadDiffResMgr.isLoaded = function(self, t_loadedList, path)
    if not t_loadedList then
        return false;
    end

    local aReversePath = string.reverse(path)
    local slashPos = string.find(aReversePath,"/")
    local reverseKey = string.sub(aReversePath,5,slashPos - 1)
    local aKey = string.reverse(reverseKey)
    if not t_loadedList[aKey] then
        t_loadedList[aKey] = true;
        return false;
    end

    return true;
end

g_LoadDiffResMgr.LoadFirstLuas = function(self)
    print("kgq LoadFirstLuas")
    if not isAbroadEvn() or not g_tUI_DIFF then
        return;
    end
    local t_loadedLuaList = {

    }

    for i=1, #(self.t_LangKey) do
        local langCfg = g_tUI_DIFF[self.t_LangKey[i]];
        if langCfg then
            for j=1,#(self.t_countryKey) do
                local countryCfg = langCfg[self.t_countryKey[j]];
                if countryCfg and countryCfg.firstluas and type(countryCfg.firstluas) == 'table' then
                    self:LoadFirstLuasFile(countryCfg.firstluas, t_loadedLuaList);
                end
            end
        end
    end
end

g_LoadDiffResMgr.LoadFirstLuasFile = function(self, t_files, t_loadedList)
    for i=1, #(t_files) do
        if not self:isLoaded(t_loadedList, t_files[i]) and GameUI.LoadLuaFile then  --记录过的就不要再加载了
            GameUI:LoadLuaFile(t_files[i]);
        end
    end
end


------------------------------------------------------游戏进度条加载UI end--------------------------------------------------------



------------------------------------------------------动态加载UI-----------------------------------------------------------------
--新增的差异化文件添加到动态加载列表里
--dynamicUILis 动态加载列表
g_LoadDiffResMgr.AddDynamicUIList = function(self, dynamicUILis)
    print("kgq AddDynamicUIList")
    if not isAbroadEvn() or not g_tUI_DIFF_DYNAMIC then
        return;
    end

    local t_loadedXmlList = {

    }

    for i=1, #(self.t_LangKey) do
        local langCfg = g_tUI_DIFF_DYNAMIC[self.t_LangKey[i]];
        if langCfg then
            for j=1,#(self.t_countryKey) do
                local countryCfg = langCfg[self.t_countryKey[j]];
                if countryCfg and countryCfg.newxml then
                    self:AddDynamicUIListBuCfg(countryCfg.newxml, dynamicUILis, t_loadedXmlList);
                end
            end
        end
    end
end

--单个配置里的新增差异化文件添加到动态加载列表里
--已经记录在加载的文件列表里的就不在添加了
--cfg：单个动态加载的配置文件列表 dynamicUILis：动态加载列表 t_loadedList：已记录加载的文件列表
g_LoadDiffResMgr.AddDynamicUIListBuCfg = function(self, cfg, dynamicUILis, t_loadedList)
    for i=1, #(cfg) do
        if not self:isLoaded(t_loadedList, cfg[i].path) then  --加载过的就不要再加载了
            table.insert(dynamicUILis, cfg[i])
        end
    end
end

--更新替换差异化文件信息到动态加载列表里
--aPathTable 动态加载列表里的单个数据
g_LoadDiffResMgr.UpdateDynamicUIList = function(self, aPathTable)
    --print("kgq UpdateDynamicUIList")
    if not isAbroadEvn() or not g_tUI_DIFF_DYNAMIC then
        return;
    end

    local cfg = self:GetReplaceCfg(aPathTable.path, g_tUI_DIFF_DYNAMIC)
    if cfg then
        aPathTable.path = cfg.path;
        if cfg.name then
            aPathTable.name = cfg.name;
        end
    end
end

------------------------------------------------------动态加载UI end-----------------------------------------------------------------