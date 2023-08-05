-- 目前只用于海外版 2021/4/12

DevTranslation = {}

DevTranslation.define = {
    tabType = -- 插件分类，同ModsLibCtrl里定义的
	{
		none = 0,
		setting = 1, --插件包设置
		block = 2, --方块
		actor = 3, --生物
		item = 4, --道具
		recipe = 5, --配方
		smelting = 6, --熔炼
		plot = 7, --剧情
		status = 8, --状态
	}
}

function DevTranslation:GetMapList()
    local list = GetArchiveData()
    return list
end

function DevTranslation:GetMapOwid(mapdata)
    local info = mapdata.info
    
    if info then
        return info.worldid
    end
    return nil
end

function DevTranslation:GetTriggerItemText(itemData)
    if itemData == nil then
        return nil
    end
    local textTabList = nil
    for childIndex, childData in ipairs(itemData) do
        local textTab = nil
        local factor = childData.factor
        if factor and childData.param then
            
            local config = ScriptSupportFunc:GetCsvConfig(factor,"TriggerItem")
            for paramIndex, paramData in ipairs(childData.param) do
                local paramString = config and config["Param" .. paramIndex] or ''
                local paramStringTable = StringSplit(paramString,",")
                if paramStringTable then
                    local paramSetIndex = paramStringTable[1]
                    local paramReadOnly = paramStringTable[2]
                    local paramDef = DefMgr:getTriggerParamDef(tonumber(paramSetIndex))

                    local inputable = 0
                    local input = StringSplit(paramDef.UseInput,",")
                    if input then inputable = tonumber(input[1]) end

                    if inputable == 1 and type(paramData) == "string" then -- 输入值
                        if textTab == nil then
                            textTab = {}
                            textTab.param = {}
                            textTab.factor = factor
                        end
                        textTab.param[paramIndex] = paramData
                    end
                end
            end
        end
        if textTab then
            if textTabList == nil then
                textTabList = {}
            end
            table.insert(textTabList, childIndex, textTab)
        end
    end
    return textTabList
end

-- 地图全局触发器组列表需要翻译的文本数据
function DevTranslation:GetMapGlobalTriggerText(groupDataList)
    if groupDataList == nil then
        return nil
    end
    local TextGroupDataList = {}
    for gIdx, groupData in ipairs(groupDataList) do
        local TextGroupData = nil
        for triggerIdx, triggerData in ipairs(groupData) do
            local textEvent = self:GetTriggerItemText(triggerData.event)
            local textCondition = self:GetTriggerItemText(triggerData.condition)
            local textAction = self:GetTriggerItemText(triggerData.action)

            if textEvent or textCondition or textAction then
                local TextTrigger = {
                    file = triggerData.file,
                    event = textEvent,
                    condition = textCondition,
                    action = textAction,
                }
                if TextGroupData == nil then
                    TextGroupData = {}
                end
                table.insert(TextGroupData, triggerIdx, TextTrigger)
            end
        end
        if TextGroupData then
            table.insert(TextGroupDataList, gIdx, TextGroupData)
        end
    end
    return TextGroupDataList
end

function DevTranslation:LoadMapTriggerData(sstype, dirpath)
    local cfgpath = dirpath .. '/config.lua'

    local groups = ScriptSupportSetting:loadConfigFile(cfgpath, false, sstype)
    return groups
end

function DevTranslation:LoadMapTriggerDir(dirname, dirpath, sstype)
    sstype = sstype or ScriptSupportSetting:nameToType(dirname)
    if not sstype or not next(sstype) then
        return
    end
    if sstype.scripttype ~= 2 then
        -- 触发器才翻译
        return
    end
    return {
        sstype = sstype,
        dirpath = dirpath,
        typeName = ScriptSupportSetting:typeToName(sstype),
        groups = self:LoadMapTriggerData(sstype, dirpath)
    }
end

function DevTranslation:LoadTriggerConfigDataList(dirpath, findlist)
    local triggerConfigDataList = {}
    for _, findinfo in ipairs(findlist) do
        if findinfo.isdir then
            local dirname = findinfo.name
            local fullpath = dirpath .. dirname
            local data = self:LoadMapTriggerDir(dirname, fullpath)
            if data then
                table.insert(triggerConfigDataList, data)
            end
        end
    end
    return triggerConfigDataList
end

-- 扫描data\wxxxx\ss目录
function DevTranslation:LoadMapTrigger(owid)
    local dirpath = ScriptSupportSetting:getScriptDirPath(owid)
    local findlist = dirpath and ScriptSupportCtrl:findFromDir(dirpath)
    if not findlist then
        return
    end

    return self:LoadTriggerConfigDataList(dirpath, findlist)
end

-- 插件包的触发器翻译文本提取
function DevTranslation:LoadMapTrigger_ModPacket(owid)
    local dirpath = "data/w" .. tostring(owid) .. "/modpkg/"
    local findlist = dirpath and ScriptSupportCtrl:findFromDir(dirpath)
    if not findlist then
        return
    end
    local modPacketConfigList = {}
    for _, findinfo in ipairs(findlist) do
        if findinfo.isdir then
            local packetConfigList = {}
            local dirname = findinfo.name
            local fullpath = dirpath .. dirname .. "/ss/trigger/"
            local triggerdirlist = ScriptSupportCtrl:findFromDir(fullpath)
            if triggerdirlist then
                packetConfigList.dirname = dirname
                packetConfigList.configList = self:LoadTriggerConfigDataList(fullpath, triggerdirlist)
                table.insert(modPacketConfigList, packetConfigList)
            end
        end
    end
    return modPacketConfigList
end

-- 提取需要翻译文本的接口(触发器)：获取地图的触发器要翻译的文本，包含局部和全局的
--[==[
返回数据样例：
game_type_2 里 多个触发器组
一个触发器组里有多个触发器
一个触发器里数据，可能有action, condition, event
action里面多个表，
{
    game_type_2 = {
        {
            {
                file = [[script_161864610401.lua]], 
                action = {
                    {
                        factor = 3160001, 
                        param = {
                            [2] = [[123]]
                        }
                    }, 
                    {
                        factor = 3160003, 
                        param = {
                            [3] = [[123123]]
                        }
                    }
                }
            }
        } 
    }, 
    itemlocal_itemid_4097_type_2 = {
        ...
    }
    owid = 29571849840767
} 
]==]
function DevTranslation:GetMapTriggerTextByOwid(owid)
    local mapConfigList = self:LoadMapTrigger(owid)
    local mapTriggerTextList = {
        owid = owid,
    }
    if mapConfigList then
        for k, v in ipairs(mapConfigList) do
            local configText = self:GetMapGlobalTriggerText(v.groups)
            if configText then
                mapTriggerTextList[v.typeName] = configText
            end
        end
    end
    local modpacketConfigList = self:LoadMapTrigger_ModPacket(owid)
    if modpacketConfigList then
        for _, modpacket in ipairs(modpacketConfigList) do
            for k, v in ipairs(modpacket) do
                local configText = self:GetMapGlobalTriggerText(v.groups)
                if configText then
                    mapTriggerTextList[v.typeName] = configText
                end
            end
        end
    end
    return mapTriggerTextList
end


function DevTranslation:GetTabModsDataByType(tabType)
    local list = {}
    if tabType == self.define.tabType.block then
		list = GetInst("ModsLibDataManager"):GetBlockList(true)
	elseif tabType == self.define.tabType.actor then
		list = GetInst("ModsLibDataManager"):GetActorList()
	elseif tabType == self.define.tabType.item then
		list = GetInst("ModsLibDataManager"):GetItemList()
	elseif tabType == self.define.tabType.recipe then
		list = GetInst("ModsLibDataManager"):GetRepiceList(true)
	elseif tabType == self.define.tabType.smelting then
		list = GetInst("ModsLibDataManager"):GetSmeltingList(true)
	elseif tabType == self.define.tabType.plot then
		list = GetInst("ModsLibDataManager"):GetPlotList()
	elseif tabType == self.define.tabType.status then
		list = GetInst("ModsLibDataManager"):GetStatusList()
	end
    return list
end


--[[
    -- 提取需要翻译文本的接口(插件)：
    {
        owid = 123,
        mods = {
            {
                ID = 1,
                Type = 4,
                Text = {
                    Name = "",
                    Desc = ""
                }
            }
            {
                ID = 1,
                Type = 7,
                DialogTextList = {
                    {
                        ID = 对话id,
                        Text = ""
                        Answers = {"txt1", "txt2"} --有序
                    }
                },
                TaskTextList = {
                    {
                        ID = 任务ID,
                        Name = "",
                        TaskDialogTextList = {
                            {
                                ID = 剧情id,
                                Text = ""
                                Answers = {"txt1", "txt2"} --有序
                            }
                        }
                    }
                }
            }
        }
    }
    --返回：成功返回table，失败返回nil，和 失败原因
    1是owid是nil
    2是requestEditMod失败
    3是未找到默认插件目录
    4是加载失败
]]
function DevTranslation:GetMapModTextByOwid(owid)
    if owid == nil then
        return nil, 1
    end
    -- 先清理下
    ModEditorMgr:onleaveEditCurrentMod()

    if ModEditorMgr:ensureMapHasDefualtMod(owid) then
        if ModMgr:loadWorldMods(owid) then
            
            local uuid = ModMgr:getMapDefaultModUUID()
            local mod = ModMgr:getMapModByUUID(uuid)
            local moddesc = ModMgr:getMapModDescByUUID(uuid)
            if mod and moddesc then
                ModEditorMgr:requestEditMod(moddesc, mod)
            else
                return nil, 2
            end
            
            local tabType = self.define.tabType
            local mapText = {owid = owid, mods = {}}
            for tabkey, tabIndex in pairs(tabType) do
                if tabIndex > 1 then -- 从方块开始
                    local datalist = self:GetTabModsDataByType(tabIndex)
                    local def
                    local modText
                    for index, v in ipairs(datalist) do
                        modText = {}
                        def = datalist[index]
                        if tabIndex == tabType.block then
                            def = ModEditorMgr:getBlockDefById(def.ID)
                        elseif tabIndex == tabType.recipe then
                            def = ModEditorMgr:getCraftingDefById(def.realID)
                        elseif tabIndex == tabType.smelting then
                            def = ModEditorMgr:getFurnaceDefById(def.realID)
                        else
                            def = datalist[index]
                        end
                        if tabIndex == tabType.block
                        or tabIndex == tabType.actor
                        or tabIndex == tabType.item
                        or tabIndex == tabType.status then
                            modText.Name = def.Name
                            modText.Desc = def.Desc
                            if tabIndex == tabType.block then
                                local itemDef = ModEditorMgr:getBlockItemDefById(def.ID)
                                if itemDef == nil then
                                    itemDef = ModEditorMgr:getItemDefById(def.ID)
                                end
                                if itemDef == nil then
                                    itemDef = ItemDefCsv:get(def.ID)
                                end
                        
                                if itemDef then
                                    modText.Name = itemDef.Name;    --名字
                                    modText.Desc = itemDef.Desc;	--描述
                                end
                            end
                            table.insert(mapText.mods, {
                                ID = def.ID,
                                Type = tabIndex,
                                Text = modText
                            })
                        elseif tabIndex == tabType.plot then
                            -- 剧情
                            -- 对话
                            local dialogTextList = {}
                            local num = def:getDialogueNum();
                            for i = 1, num do
                                local dialoguesDef = def:getDialogueDef(i - 1);
                                if dialoguesDef then
                                    local AnswersList = {};
                                    -- local numAnswers = dialoguesDef:getAnswerNum();
                                    for j = 1, 4 do
                                        local answerDef = dialoguesDef:getAnswerDef(j - 1);
                                        if answerDef then
                                            table.insert(AnswersList, ConvertDialogueStr(answerDef.Text))
                                        else
                                            table.insert(AnswersList, "")
                                        end
                                    end
                                    table.insert(dialogTextList, {
                                        ID = dialoguesDef.ID,
                                        Text = ConvertDialogueStr(dialoguesDef.Text),
                                        Answers = AnswersList,
                                    })
                                end
                            end

                            -- 任务id
                            local num = def:getCreateTaskIDNum();
                            local TaskIDs = {};
                            if num > 0 then
                                for i = 1, num do
                                    local taskid = def:getCreateTaskID(i - 1);
                                    TaskIDs[taskid] = true
                                end
                            end
                            --重新扫描任务插件
                            ModEditorMgr:ReLoadNpcTaskMod();
                            local NpcTask = NpcTask_LoadAllTask();
                            local TaskNameList = {}
                            if NpcTask then
                                for i = 1, #NpcTask do
                                    if true == TaskIDs[NpcTask[i].ID] and (NpcTask[i].CopyID and NpcTask[i].CopyID > 0) then
                                        local tTask = NpcTask[i]
                                        
                                        local plots = tTask.Plots
                                        local taskDialogTextList = {}
                                        for pi = 1, #plots do
                                            local p = plots[pi]
                                            local AnswersList = {};
                                            for j = 1, #p.Answers do
                                                table.insert(AnswersList, p.Answers[j].Text)
                                            end
                                            table.insert(taskDialogTextList,{
                                                ID = p.ID,
                                                Text = p.Text,
                                                Answers = AnswersList,
                                            })
                                        end

                                        table.insert(TaskNameList, {
                                            ID = tTask.ID,
                                            Name = tTask.Name,
                                            TaskDialogTextList = taskDialogTextList
                                        })
                                    end
                                end
                            end

                            table.insert(mapText.mods, {
                                ID = def.ID,
                                Type = tabIndex,
                                DialogTextList = dialogTextList,
                                TaskTextList = TaskNameList,
                            })
                        end
                    end
                end
            end
            -- 完成后要清理
            ModMgr:unLoadCurMods(owid);
            ModEditorMgr:onleaveEditCurrentMod()
            return mapText
        else
            return nil, 4
        end
    end
    return nil, 3
end

-- 提取需要翻译的地图配置的接口：包含队伍名字，地图介绍
--[[返回结果：
    {
        teamName = {
        [teamId] = teamName,
        }
        introTab = {
            [idx] = introText
        }
    }
]]
function DevTranslation:GetMapSettingText(owid)
    local settingText = {owid = owid}
    if ArchiveMgr and ArchiveMgr.GetBaseSettingData and WorldBaseSettingTranslateText then
        local text = WorldBaseSettingTranslateText()
        local isOk = ArchiveMgr:GetBaseSettingData(owid, text)
        if isOk then
            -- 队伍名
            local teamName = {}
            for i = 0, text.teamSize-1 do
                local id = text.teamId[i]
                local tn = text.teamName[i]
                if tn and string.len(tn) > 0 then
                    teamName[id] = tn
                end
            end
            settingText.teamName = teamName

            -- 介绍
            local introTab = {}
            local introSize = text:getIntroSize()
            for i = 0, introSize-1 do
                local introText = text:getIntroText(i)
                if introText and string.len(introText) > 0 then
                    introTab[i] = introText
                end
            end
            settingText.teamName = teamName
            settingText.introTab = introTab
        end
    end
    return settingText
end

---------------------------------------------------------------------------
-- 获取当前地图的翻译内容
-- 返回数据，触发器的同GetMapTriggerTextByOwid，其他类推。
-- 调用者只需要传第一个参数
--[[
    local FunctionEnum = {
    BOOK = 1,    --书
    LETTER = 2,        --信纸
    BLACKBOARD = 3,        --黑板
    PLUG_IN    = 4,    --插件库
    MAP_NAME = 5,    --地图名称
    MAP_DESC = 6,    --地图描述
    MAP_START_INTR = 7,        --地图启动介绍
    TEAM_NAME = 8,    --队伍名称
    TRIGGER = 9,    --触发器
}
]]
function DevTranslation:GetTranslate(type, ...)
    -- 调用海外的接口
    if MultilanguageTranslateMgr and MultilanguageTranslateMgr.GetTranslate then
        return MultilanguageTranslateMgr:GetTranslate(type, ...)
    end
    return nil
end

-- 海外接口：目前只有海外有MultilanguageTranslateMgr，2021/4/13
function DevTranslation:isDoTranslate()
    if MultilanguageTranslateMgr and MultilanguageTranslateMgr.GetTranslate then
        return true
    end
    return false
end

-- 内部方法
function DevTranslation:translateTriggerItemText(translateItem, infoItem)
    if translateItem == nil or infoItem == nil then
        return
    end
    for childIdx, translateChild in pairs(translateItem) do
        local infoChild = infoItem[childIdx]
        if infoChild 
        and translateChild.factor == infoChild.factor
        and infoChild.param and translateChild.param then
            for paramIndex, paramData in pairs(translateChild.param) do
                if infoChild.param[paramIndex] then
                    infoChild.param[paramIndex] = paramData
                end
            end
        end
    end
end

-- 翻译接口(触发器)：对触发器结构的文本进行翻译
function DevTranslation:translateTriggerData(sstype, info)
    if sstype == nil or info == nil then
        return
    end
    local mapTriggerTranslateData = self:GetTranslate(9)
    if mapTriggerTranslateData then
        local keyName = ScriptSupportSetting:typeToName(sstype)
        local triggerTranslateData = mapTriggerTranslateData[keyName]
        if triggerTranslateData then
            for _, group in pairs(triggerTranslateData) do
                for _, trigger in pairs(group) do
                    if trigger.file == info.file then
                        self:translateTriggerItemText(trigger.event, info.event)
                        self:translateTriggerItemText(trigger.condition, info.condition)
                        self:translateTriggerItemText(trigger.action, info.action)
                    end
                end
            end
        end
    end
end

-- 翻译接口（队伍）:teamid 队伍id
function DevTranslation:translateTeamName(teamid)
    if teamid == nil then
        return
    end
    local data = self:GetTranslate(8)
    if data and data.teamName then
        return data.teamName[teamid]
    end
end

-- 翻译接口（介绍）:index 从0开始
function DevTranslation:translateMapIntro(index)
    if type(index) ~= 'number' then
        return
    end
    local data = self:GetTranslate(7)
    if data and data.introTab then
        return data.introTab[index]
    end
end

--todo 翻译接口（插件）:modId插件id C++版
