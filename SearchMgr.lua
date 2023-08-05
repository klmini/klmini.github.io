SearchMgr = {} --游戏内搜索管理类
local getglobal = _G.getglobal;
SearchAlgorithm = {}; --搜索算法类
local BackPackData = {}; --背包搜索相关数据
local StashData = {}; --商店仓库搜索相关数据
local BackPackView = {}; --背包搜索界面
local StashView = {}; --商店仓库界面
local delegateDefine= {}; --委托的定义

local isTest = true;                --测试开关
local closeSearch = false;           --关闭搜索功能开关
local closePinyinSearch = true;     --关闭拼音搜索

delegateDefine = {
    CreateBackPackSearch = "CreateBackPackSearch",
    ShowCreateBackPackSearchPanel = "ShowCreateBackPackSearchPanel";

    StoreFrameStashSearch="StoreFrameStashSearch";
    ShowStoreFrameStashSearchPanel = "ShowStoreFrameStashSearchPanel";
    HideStoreFrameStashSearchPanel = "HideStoreFrameStashSearchPanel";
}

------------------------------背包-----------------------------
--背包搜索界面
BackPackView ={
    funcTable  = {};--委托
    itemdatalist = {};
    datasize = 0;

    --显示搜索背包内容
    showSearchContent = function(self,itemList)
        local print = Android:Localize();
        print(" BackPackView:showSearchContent(): itemList = ", itemList);
        -- if itemList ==nil or #itemList <=0 then
        --     self:layoutItem(0);
        --     return
        -- end

        -- local itemNum = #itemList
        -- self:layoutItem(itemNum);

        -- for i = 1,CREATE_BACKPACK_MAX do
        --     self:showOneItem(itemList[i], i);
        -- end

        local lastloadnum = self.datasize
        self.itemdatalist = itemList or {}
        self.datasize = #self.itemdatalist
        if self.datasize <= 0 then
            getglobal("CreateBackpackFrameSearchContentNull"):Show();
            getglobal("CreateBackpackFrameSearchContentNullTitle"):Show();
        else
            getglobal("CreateBackpackFrameSearchContentNull"):Hide();
            getglobal("CreateBackpackFrameSearchContentNullTitle"):Hide();
        end

        local listviewCallBack = function(idx, name)
            local listitem = getglobal(name)
            if idx > self.datasize then
                listitem:Hide()
                return
            end

            local w, h, offsetx, offsety = 8, 8, 8, 10
            local loadnum = idx-1
            local itemwidth, itemheight = listitem:GetWidth(), listitem:GetHeight()

            local itemdata = self.itemdatalist[idx]
            listitem:SetPoint("topleft", "BPSearchBoxPlane", "topleft", offsetx+(loadnum%12)*(itemwidth+w), offsety+math.floor(loadnum/12)*(itemheight+h))
            listitem:Show()
            self:showOneItem(itemdata, idx)
            listitem:SetClientID(itemdata.ID)
            -- listitem:SetClientUserData(0, math.floor(itemdata.iItemInfo/1000))

            if idx == self.datasize then
                local listFrame = getglobal("BPSearchBox")
                local listPanel = getglobal("BPSearchBoxPlane")
                local height = offsety+math.ceil(loadnum/12)*(itemheight+h)
                if height < listFrame:GetHeight() then height = listFrame:GetHeight() end
                listPanel:SetHeight(height)
                self.itemdatalist = {}
            end
        end

        lastloadnum = math.max(self.datasize, lastloadnum)
        local onceload, functab = 3, {}
        if lastloadnum > 50 then
            onceload = 12
        elseif lastloadnum > 20 then
            onceload = 6
        end

        for i=1,lastloadnum do
            table.insert(functab, {name="BPSearchBoxItem" .. i, tmpname="GridButtonTemplate2", 
                    parentname="BPSearchBox", clientid=i, idx=i, func=listviewCallBack})
            if i%onceload == 0 or i == lastloadnum then
                listviewMgr:createListItemsAsync(functab)
                functab = {}
            end
        end
    end,

    --排列并显示指定数量的格子
    -- layoutItem = function(self,num)
    --     print("BackPackView:layoutItem()",num);
    --     --判断没有item时候的ui显示状态
    --     if num <=0 then
    --         getglobal("CreateBackpackFrameSearchContentNull"):Show();
    --         getglobal("CreateBackpackFrameSearchContentNullTitle"):Show();
    --         for i=1, CREATE_BACKPACK_MAX do
    --             local createItem = getglobal("BPSearchBoxItem"..i);
    --             createItem:Hide();
    --         end
    --         return
    --     else
    --         getglobal("CreateBackpackFrameSearchContentNull"):Hide();
    --         getglobal("CreateBackpackFrameSearchContentNullTitle"):Hide();
    --     end

    --     --隐藏不需要显示的item
    --     for i=1, CREATE_BACKPACK_MAX do
    --         local createItem = getglobal("BPSearchBoxItem"..i);
    --         if i> num then
    --             createItem:Hide();
    --         else
    --             createItem:Show();
    --         end
    --     end

    --     --排列布局
    --     for i=1, CREATE_BACKPACK_MAX/12 do
    --         for j=1, 12 do
    --             local createItem = getglobal("BPSearchBoxItem"..((i-1)*12+j));
    --             createItem:SetPoint("topleft", "BPSearchBoxPlane", "topleft", (j-1)*85, (i-1)*85);
    --         end
    --     end

    --     --进行排版布局
    --     local n = math.ceil(num / 12);
    --     local plane = getglobal("BPSearchBoxPlane");
    --     if n > 4 then
    --         plane:SetSize(1055, n*85);
    --     else
    --         plane:SetSize(1055, 410);
    --     end

    -- end,

    --显示单个格子的信息 itemdef:格子信息 ，index：需要显示的ui索引
    showOneItem = function(self,itemDef,index)
        if itemDef == nil then return end

        local ui_itemGrid = getglobal("BPSearchBoxItem"..index);
        local ui_itemIcon 	= getglobal("BPSearchBoxItem"..index.."Icon");
        local ui_bkg = getglobal("BPSearchBoxItem"..index.."Bkg");
        local ui_unlock = getglobal("BPSearchBoxItem"..index.."Unlock");
        local ui_ban = getglobal("BPSearchBoxItem"..index.."Ban");
        local ui_newTag = getglobal("BPSearchBoxItem"..index.."NewTag")
        local ui_newTagBg = getglobal("BPSearchBoxItem"..index.."NewTagBG")
        local ui_redTag = getglobal("BPSearchBoxItem"..index.."RedTag");

        ui_itemGrid:Show();
        SetItemIcon(ui_itemIcon, itemDef.ID);

--        if itemDef.CopyID>0 then
--            ui_bkg:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
--            ui_bkg:SetTexUV("juese_gezi06");
--        elseif def then
--            ui_bkg:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
--            ui_bkg:SetTexUV("juese_gezi07");
--        else
--            ui_bkg:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
--            ui_bkg:SetTexUV("juese_gezi05.png");
--        end

        --判断物品有没有解锁
        ui_itemIcon:SetGray(false);
        ui_itemGrid:SetClientID(itemDef.ID);

        if itemDef.UnlockFlag > 0 then			--需解锁的物品
            if isItemUnlockByItemId(itemDef.ID) then  --已经解锁
                ui_unlock:Hide();
            else
                ui_itemIcon:SetGray(true);
                ui_unlock:Show();
                local proBkg 	= getglobal(ui_unlock:GetName().."ProBkg");
                local pro 	= getglobal(ui_unlock:GetName().."Pro");
                local lock 	= getglobal(ui_unlock:GetName().."Lock");
                local count 	= getglobal(ui_unlock:GetName().."Count");
                local hasNum = AccountManager:getAccountData():getAccountItemNum(itemDef.InvolvedID);
                if hasNum > 0 then
                    local needNum = itemDef.ChipNum;
                    local radio = hasNum/needNum;
                    if hasNum > needNum then
                        radio = 1.0;
                    end

                    pro:ChangeTexUVWidth(75*radio);
                    pro:SetSize(75*radio, 18);

                    lock:Hide();
                    proBkg:Show();
                    pro:Show();

                    local text = hasNum.."/"..needNum;
                    count:SetText(text);
                else
                    proBkg:Hide();
                    pro:Hide();
                    lock:Hide();
                    count:SetText("");
                end
            end
        else
            ui_unlock:Hide();
        end

        if itemDef.ID > 0 then
            if itemDef.ID == 11055 then
                local debug = 0;
            end
            if CheckAllServerBan(itemDef.ID)  and AccountManager:getMultiPlayer() > 0 then
                ui_ban:Show();
                ui_itemIcon:SetGray(true);
            else
                ui_ban:Hide();
            end
        end

        if itemDef.CopyID > 0 and not InCreateNewItemTag(itemDef.ID) and not AccountManager:getNoviceGuideState("guidenewitem")then
            table.insert(t_CreateNewItemTag, itemDef.ID);
            ui_redTag:Show();
        elseif not InClickItemVersionTag(itemDef.ID) and itemDef.Version ~= "" then
            if IsShowNewItemTag(tonumber(itemDef.Version)) then
                --显示版本新道具标签
                ui_newTag:Show();
                ui_newTagBg:Show();
                if get_game_lang() == 4 then
                    ui_newTagBg:SetSize(65,25)
                    ui_newTag:SetSize(50,19)
                end
            end
        else
            ui_newTagBg:Hide();
            ui_newTag:Hide();
            ui_redTag:Hide();
        end

    end,

    --搜索框输入完成
    searchFocusLost = function(self)
        if ClientMgr:isMobile() ==false then return end


        local text = self:getSearchEditInput();
        if text == "" then return end
        self:openSearchPanel()

        if self.funcTable and self.funcTable[delegateDefine.CreateBackPackSearch]~= nil then
            self.funcTable[delegateDefine.CreateBackPackSearch](text);
        end
    end,

    --搜索框按回车
    searchEnterPressed = function(self)
        local print = Android:Localize();
        print("BackPackView.searchEnterPressed():")
        UIFrameMgr:setCurEditBox(nil);
        BackpackTabBtnTemplate_OnClick(0);

        local text = self:getSearchEditInput();
        print("BackPackView.searchEnterPressed(): text = ", text);
        if text == "" or text == nil then return end

        self:openSearchPanel()
        if self.funcTable and self.funcTable[delegateDefine.CreateBackPackSearch]~= nil then
            self.funcTable[delegateDefine.CreateBackPackSearch](text);
        end
    end,

    --获取输入框的内容
    getSearchEditInput = function(self)
        print("BackPackView.getSearchEditInput()")
        local text = getglobal("CreateBackpackFrameSearchEdit"):GetText();
        if text == "" or text == nil  then
            ShowGameTips(GetS(21739));
            return
        end

        if string.len(text) > 45 then
            text = string.sub(text,1,45);
        end


        self:ShowSearchText(text);
        return text;
    end,

    --显示搜索内容
    ShowSearchText= function(self,inputText)
        local uiName = "CreateBackpackFrameSearchContent";
        local ui_title1 = getglobal(uiName.."Title1");
        local ui_title2 = getglobal(uiName.."Title2");
        local ui_content = getglobal(uiName.."SearchContent");

        PEC_Tools.SetUiTextSelfAdaptionWidth(ui_title1,GetS(21737,inputText));
        ui_title1:Show()
        ui_title2:Hide();
        ui_content:Hide()

    end,

    --打开搜索界面
    openSearchPanel = function()
        local ui_backpackContent = getglobal("CreateBackpackFrameContent");
        local ui_searchContent = getglobal("CreateBackpackFrameSearchContent");

        ui_backpackContent:Hide();
        ui_searchContent:Show();
        UpdateCreateBackpackLabelBtnState("")
    end,

    --关闭搜索界面
    closeSearchPanel = function()
        local ui_backpackContent = getglobal("CreateBackpackFrameContent");
        local ui_searchContent = getglobal("CreateBackpackFrameSearchContent");

        if ui_backpackContent:IsShown() ==false then
            ui_backpackContent:Show();
        end

        if ui_searchContent:IsShown() then
            ui_searchContent:Hide();
        end
    end,

    --创造背包的搜索界面显示
    Show= function()
        local this = BackPackView;
        if this.funcTable and this.funcTable[delegateDefine.ShowCreateBackPackSearchPanel]~= nil then
            this.funcTable[delegateDefine.ShowCreateBackPackSearchPanel]();
        end
    end,

}

--背包搜索相关数据
BackPackData = {
    ItemNum = 0,  --所有属性的数量，用来判断是否有新的道具以便重新加载
    ItemNameList = {}, --所有的本地保存的item名字
    ItemDescList= {}, --所有的本地保存item描述
    ItemGetWayList = {},--所有的本地保存item获取方式

    ItemNamePinyinList = {}, --所有的本地保存的item的拼音名字
    ItemDescPinyinList= {}, --所有的本地保存item的拼音描述

    ItemNamePinyinInitialsList = {}, --所有的本地保存的item拼音首字母名字
    ItemDescPinyinInitialsList= {}, --所有的本地保存Desc拼音首字母描述


    --从本地加载文件
    load = function()
        local this = BackPackData;

        if isTest then
            this:loadFromDef();
            return
        end

        local data = container:load_from_file("search_backpack_"..AccountManager:getUin());

        if data then
            print("测试加载数据")
            this.ItemNameList = data["ItemNameList"] or {};
            this.ItemDescList = data["ItemDescList"] or {};
            this.ItemGetWayList = data["ItemGetWayList"] or {};

            this.ItemNamePinyinList = data["ItemNamePinyinList"] or {};
            this.ItemDescPinyinList = data["ItemDescPinyinList"] or {};

            this.ItemNamePinyinInitialsList = data["ItemNamePinyinInitialsList"] or {};
            this.ItemDescPinyinInitialsList = data["ItemDescPinyinInitialsList"] or {};

            this.ItemNum = data["ItemNum"] or 0;

            this.loadIncrementDef(this.ItemNameList);
        else
            this:loadFromDef();
        end
    end,

    --保存到本地文件
    save  = function()
        local this = BackPackData;
        local data = {};
        data["ItemNameList"] = this.ItemNameList or {};
        data["ItemDescList"] = this.ItemDescList or {};
        data["ItemGetWayList"] = this.ItemGetWayList or {};

        data["ItemNamePinyinList"] = this.ItemNamePinyinList or {};
        data["ItemDescPinyinList"] = this.ItemDescPinyinList or {};

        data["ItemNamePinyinInitialsList"] = this.ItemNamePinyinInitialsList or {};
        data["ItemDescPinyinInitialsList"] = this.ItemDescPinyinInitialsList or {};

        data["ItemNum"] = this.ItemNum;

        return container:save_to_file("search_backpack_"..AccountManager:getUin(), data);
    end,

    --从defMgr里加载item信息
    loadFromDef = function(self)
        local descData = {}; --描述列表
        local this = BackPackData;

        local n = ItemDefCsv:getNum();
        for i=1, n do
            local itemDef = ItemDefCsv:get(i-1);

            if itemDef and string.find(itemDef.Name,"游戏版本过低") == nil and itemDef.CreateType > 0 and check_item_can_load(itemDef) then
                this.ItemNameList[itemDef.ID] = itemDef.Name;
                this.ItemDescList[itemDef.ID] = itemDef.Desc;
                this.ItemGetWayList[itemDef.ID] = itemDef.GetWay;

                if (get_game_lang() ==0 or get_game_lang() == 2)  and closePinyinSearch ==false then
                    this.ItemNamePinyinList[itemDef.ID],this.ItemNamePinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Name);
                    this.ItemDescPinyinList[itemDef.ID],this.ItemDescPinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Desc);
                end


                --if string.find(itemDef.ID,"116") or string.find(itemDef.Name,"落叶松树苗") then
                --    print("带有数字的",itemDef.Name)
                --    print(this.ItemNamePinyinList[itemDef.ID])
                --    print(this.ItemNamePinyinInitialsList[itemDef.ID])
                --    print(this.ItemDescPinyinList[itemDef.ID])
                --    print(this.ItemDescPinyinInitialsList[itemDef.ID])
                --end
            end
        end

        local foldersNum = ResourceCenter:getResClassNum(MAP_LIB, CUSTOM_MODEL_TYPE)
        for i=1,foldersNum do
            local data = ResourceCenter:getClassInfo(MAP_LIB, i-1, CUSTOM_MODEL_TYPE)
            local resNum = data:getModelNum()             
            for j=1,resNum do
                local fileName = data:getModelName(j-1)
                local ID = GetResourceModelGridClientID(fileName,MAP_MODEL_CLASS,CUSTOM_MODEL_TYPE,i-1,false)
                local itemDef = ItemDefCsv:get(ID);
                if itemDef then
                    this.ItemNameList[itemDef.ID] = itemDef.Name;
                    this.ItemDescList[itemDef.ID] = itemDef.Desc;
                    this.ItemGetWayList[itemDef.ID] = itemDef.GetWay;

                    this.ItemNamePinyinList[itemDef.ID],this.ItemNamePinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Name);
                    this.ItemDescPinyinList[itemDef.ID],this.ItemDescPinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Desc);  
                end
            end
        end

        self.ItemNum = n;
    end,

    --增量判断增加新的def
    loadIncrementDef = function(compareList)
        print("BackPackData.loadIncrementDef()");
        if compareList ==nil or next(compareList) == nil then return end;
        local this = BackPackData;

        local n = ItemDefCsv:getNum();
        for i=1, n do
            local itemDef = ItemDefCsv:get(i-1);
            if itemDef and string.find(itemDef.Name,"游戏版本过低") == nil and itemDef.CreateType > 0 then

                    this.ItemNameList[itemDef.ID] = itemDef.Name;
                    this.ItemDescList[itemDef.ID] = itemDef.Desc;
                    this.ItemGetWayList[itemDef.ID] = itemDef.GetWay;

                    this.ItemNamePinyinList[itemDef.ID],this.ItemNamePinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Name);
                    this.ItemDescPinyinList[itemDef.ID],this.ItemDescPinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Desc);
            end
        end

        local foldersNum = ResourceCenter:getResClassNum(MAP_MODEL_CLASS, CUSTOM_MODEL_TYPE)
        for i=1,foldersNum do
            local data = ResourceCenter:getClassInfo(MAP_LIB, i-1, CUSTOM_MODEL_TYPE)
            local resNum = data:getModelNum()             
            for j=1,resNum do
                local fileName = data:getModelName(j-1)
                local ID = GetResourceModelGridClientID(fileName,MAP_MODEL_CLASS,CUSTOM_MODEL_TYPE,i-1,false)
                local itemDef = ItemDefCsv:get(ID);
                
                this.ItemNameList[itemDef.ID] = itemDef.Name;
                this.ItemDescList[itemDef.ID] = itemDef.Desc;
                this.ItemGetWayList[itemDef.ID] = itemDef.GetWay;

                this.ItemNamePinyinList[itemDef.ID],this.ItemNamePinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Name);
                this.ItemDescPinyinList[itemDef.ID],this.ItemDescPinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Desc);             
            end
        end

    end,

    --清空数据
    reset = function()
        print("BackPackData.reset()")
        local this = BackPackData;

        this.ItemNum = 0;
        this.ItemNameList = {};
        this.ItemDescList= {};
        this.ItemGetWayList = {};

        this.ItemNamePinyinList = {};
        this.ItemDescPinyinList= {};

        this.ItemNamePinyinInitialsList = {};
        this.ItemDescPinyinInitialsList= {};

    end,

    --判断是否需要实时刷新数据
    NeedLoadDef = function()
        local this = BackPackData;

        if next(this.ItemNameList) == nil and  next(this.ItemDescList) ==nil and  next(this.ItemGetWayList) ==nil then
            return true;
        else
            return false;
        end
    end,

}

------------------------------商城仓库--------------------------------

--商店仓库界面
StashView = {
    funcTable  = {};--委托

    isShowNoItemTips = false;                   --仓库没有物品提示显示状态保存

    --创造背包的搜索界面显示
    Show= function()
        local this = StashView;
        if this.funcTable and this.funcTable[delegateDefine.ShowStoreFrameStashSearchPanel]~= nil then
            this.funcTable[delegateDefine.ShowStoreFrameStashSearchPanel]();
        end

        getglobal("StoreFrameStashSearchEdit"):Clear();
    end,

    --搜索框输入完成
    searchFocusLost = function()
        local this = StashView
        if ClientMgr:isMobile() ==false then return end


        local text = this.getSearchEditInput();
        if text == nil or text == "" then return end
        this.openSearchPanel()

        if this.funcTable and this.funcTable[delegateDefine.StoreFrameStashSearch]~= nil then
            this.funcTable[delegateDefine.StoreFrameStashSearch](text);
        end
    end,

    --搜索框按回车
    searchEnterPressed = function()
        local this = StashView
        UIFrameMgr:setCurEditBox(nil);


   
        local text = this.getSearchEditInput();
       
        if text == nil or text == "" then return end
       
        this.openSearchPanel()
        if this.funcTable and this.funcTable[delegateDefine.StoreFrameStashSearch]~= nil then
            this.funcTable[delegateDefine.StoreFrameStashSearch](text);
        end
    end,

    --获取输入框的内容
    getSearchEditInput = function()
        local this = StashView
        local text = getglobal("StoreFrameStashSearchEdit"):GetText();
    
        if text == nil or text == "" then
            ShowGameTips(GetS(21739));
            
            return
        end

        if string.len(text) > 45 then
            text = string.sub(text,1,45);
        end

        this.ShowSearchText(text);
        return text;
    end,

    --打开搜索界面
    openSearchPanel = function()
        local this = StashView;

        local uiName = "StoreFrameStash";
        local ui_searchContent = getglobal(uiName.."SearchContent");
        local ui_stashBox = getglobal("StashBox");
        local ui_noItemIcon = getglobal(uiName.."NoItemIcon")
        local ui_noItemTips = getglobal(uiName.."NoItemTips")

        if ui_noItemIcon:IsShown() and ui_noItemTips:IsShown() then
            this.isShowNoItemTips = true;
            ui_noItemTips:Hide();
            ui_noItemIcon:Hide();
        end

        ui_searchContent:Show();
        ui_stashBox:SetPoint("top", "StoreFrameStashChenDi", "top", 0, 47);
        ui_stashBox:SetHeight(385)

    end,

    --关闭搜索界面
    closeSearchPanel = function(isCloseBtn)
        local this = StashView;
        local uiName = "StoreFrameStash";
        local ui_searchContent = getglobal(uiName.."SearchContent");
        local ui_stashBox = getglobal("StashBox");
        local ui_noItemIcon = getglobal(uiName.."NoItemIcon")
        local ui_noItemTips = getglobal(uiName.."NoItemTips")

        ui_searchContent:Hide();
        ui_stashBox:SetPoint("top", "StoreFrameStashChenDi", "top", 0, 12);
        ui_stashBox:SetHeight(510)

        this.ShowNoneItem(false);

        if this.isShowNoItemTips == true then
            this.isShowNoItemTips = false;
            ui_noItemIcon:Show();
            ui_noItemTips:Show();
        end

        if isCloseBtn == nil or isCloseBtn ==false then return end

        if this.funcTable and this.funcTable[delegateDefine.HideStoreFrameStashSearchPanel]~= nil then
            this.funcTable[delegateDefine.HideStoreFrameStashSearchPanel]();
        end

    end,

    --显示搜索内容
    ShowSearchText= function(inputText)
        local uiName = "StoreFrameStashSearchContent";
        local ui_title1 = getglobal(uiName.."Title1");
        local ui_title2 = getglobal(uiName.."Title2");
        local ui_content = getglobal(uiName.."SearchContent");

        local text ;

        text = ui_title1:GetText();
        PEC_Tools.SetUiTextSelfAdaptionWidth(ui_title1,GetS(21737,inputText));

        ui_title2:Hide();
        ui_content:Hide();

    end,

    --没有搜索物品时显示的内容
    ShowNoneItem = function(isShow)
        local ui_StashBox = getglobal("StashBox");
        local ui_nullPic = getglobal("StoreFrameStashSearchContentNull");
        local ui_nullPicTitle = getglobal("StoreFrameStashSearchContentNullTitle");

        if isShow == false then
            ui_StashBox:Show();
            ui_nullPic:Hide();
            ui_nullPicTitle:Hide();
        else
            ui_StashBox:Hide();
            ui_nullPicTitle:Show();
            ui_nullPic:Show();
        end

    end,

    --通过物品的个数显示滑动框大小
    SetStashBoxPanelSizeByNum = function(num)
        local ui_panel = getglobal("StashBoxPlane");
        if num <=6 then
            ui_panel:SetHeight(380)
        else
            local row = math.ceil(num/2);
            ui_panel:SetHeight(133*row);
        end
    end,
}

--商店仓库搜索相关数据
StashData = {
    ItemNum = 0,  --所有属性的数量，用来判断是否有新的道具以便重新加载
    ItemNameList = {}, --所有的本地保存的item名字
    ItemDescList= {}, --所有的本地保存item描述

    ItemNamePinyinList = {}, --所有的本地保存的item的拼音名字
    ItemDescPinyinList= {}, --所有的本地保存item的拼音描述

    ItemNamePinyinInitialsList = {}, --所有的本地保存的item拼音首字母名字
    ItemDescPinyinInitialsList= {}, --所有的本地保存Desc拼音首字母描述

    AccountItemList = {}, --账户物品列表

    --从defMgr里加载item信息
    loadFromDef = function()
        local this = StashData;
        local num = AccountManager:getAccountData():getBagSize();

        for i=1, num do
            local accountItem = AccountManager:getAccountData():getAccountItem(i-1);
            if accountItem ~= nil then
                local itemDef = ItemDefCsv:get(accountItem.itemId);
                if itemDef ~= nil and accountItem.num > 0 and itemDef.ID ~= 10001 and check_item_can_load(itemDef) then
                    this.AccountItemList[accountItem.itemId] = accountItem;
                    this.ItemNameList[itemDef.ID] = itemDef.Name;
                    this.ItemDescList[itemDef.ID] = itemDef.Desc;
                    if (get_game_lang() ==0 or get_game_lang() == 2) and closePinyinSearch ==false then
                        this.ItemNamePinyinList[itemDef.ID],this.ItemNamePinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Name);
                        this.ItemDescPinyinList[itemDef.ID],this.ItemDescPinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Desc);
                    end
                end

            end
        end

    end,


    UseStashItem = function(item_def)
        local this = StashData;
        this.reset();
        this.loadFromDef();

        --local num = AccountManager:getAccountData():getBagSize();
        --for i=1, num do
        --    local accountItem = AccountManager:getAccountData():getAccountItem(i-1);
        --
        --    if accountItem ~= nil then
        --        local itemDef = ItemDefCsv:get(accountItem.itemId);
        --        if itemDef ~= nil and accountItem.num > 0  and itemDef.ID ~= 10001 then
        --            print("回收物品2")
        --            --if  accountItem.num > 0 then
        --            --    this.AccountItemList[accountItem.itemId] = accountItem;
        --            --    this.ItemNameList[itemDef.ID] = itemDef.Name;
        --            --    this.ItemDescList[itemDef.ID] = itemDef.Desc;
        --            --    this.ItemNamePinyinList[itemDef.ID],this.ItemNamePinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Name);
        --            --    this.ItemDescPinyinList[itemDef.ID],this.ItemDescPinyinInitialsList[itemDef.ID] = SearchAlgorithm.chineseToPinyin(itemDef.Desc);
        --            --    this.ItemEnglishList[itemDef.ID] = itemDef.EnglishName;
        --            --else
        --            --    print("回收物品1")
        --            --    this.AccountItemList[accountItem.itemId] = {};
        --            --    this.ItemNameList[itemDef.ID] = {};
        --            --    this.ItemDescList[itemDef.ID] = {};
        --            --    this.ItemNamePinyinList[itemDef.ID]={};
        --            --    this.ItemNamePinyinInitialsList[itemDef.ID]= {};
        --            --    this.ItemDescPinyinList[itemDef.ID] ={}
        --            --    this.ItemDescPinyinInitialsList[itemDef.ID] = {};
        --            --    this.ItemEnglishList[itemDef.ID] = {};
        --            --end
        --        end
        --
        --    end
        --end

    end,

    --通过物品id列表获取账号物品列表
    getAccountItemByIdList = function(idList)
        local this = StashData;
        if idList ==nil or type(idList)~= "table" or next(idList) == nil then return end

        local accountItemList = {};
        for k,v in pairs(idList) do
            local accountItem = this.AccountItemList[v];
            if accountItem then
                table.insert(accountItemList,accountItem);
            end
        end
        return accountItemList ;
    end,

    --清空数据
    reset = function()
        local this = StashData;

        this.ItemNum = 0;
        this.ItemNameList = {};
        this.ItemDescList= {};

        this.ItemNamePinyinList = {};
        this.ItemDescPinyinList= {};

        this.ItemNamePinyinInitialsList = {};
        this.ItemDescPinyinInitialsList= {};

        this.AccountItemList = {};

        getglobal("StoreFrameStashSearchEdit"):Clear();
    end,

    --判断是否需要实时刷新数据
    NeedLoadDef = function()
        local  this = StashData;
        if next(this.ItemNameList) == nil and  next(this.ItemDescList) ==nil then
            return true;
        else
            return false;
        end
    end,
}

----------------------------------------------------------------------
--搜索算法类
SearchAlgorithm ={

    --转换表
    t_pyValue={"a", "ai", "an", "ang", "ao", "ba", "bai", "ban", "bang", "bao", "bei", "ben", "beng", "bi", "bian", "biao", "bie", "bin", "bing", "bo", "bu", "ca", "cai", "can", "cang", "cao", "ce", "cen", "ceng", "cha", "chai", "chan", "chang", "chao", "che", "chen", "cheng", "chi", "chong", "chou", "chu", "chuai", "chuan", "chuang", "chui", "chun", "chuo", "ci", "cong", "cou", "cu", "cuan", "cui", "cun", "cuo", "da", "dai", "dan", "dang", "dao", "de", "dei", "deng", "di", "dia", "dian", "diao", "die", "ding", "diu", "dong", "dou", "du", "duan", "dui", "dun", "duo", "e", "ei", "en", "er", "fa", "fan", "fang", "fei", "fen", "feng", "fo", "fou", "fu", "ga", "gai", "gan", "gang", "gao", "ge", "gei", "gen", "geng", "gong", "gou", "gu", "gua", "guai", "guan", "guang", "gui", "gun", "guo", "ha", "hai", "han", "hang", "hao", "he", "hei", "hen", "heng", "hng", "hong", "hou", "hu", "hua", "huai", "huan", "huang", "hui", "hun", "huo", "ji", "jia", "jian", "jiang", "jiao", "jie", "jin", "jing", "jiong", "jiu", "ju", "juan", "jue", "jun", "ka", "kai", "kan", "kang", "kao", "ke", "ken", "keng", "kong", "kou", "ku", "kua", "kuai", "kuan", "kuang", "kui", "kun", "kuo", "la", "lai", "lan", "lang", "lao", "le", "lei", "leng", "li", "lia", "lian", "liang", "liao", "lie", "lin", "ling", "liu", "lo", "long", "lou", "lu", "luan", "lun", "luo", "lue", "lv", "m", "ma", "mai", "man", "mang", "mao", "me", "mei", "men", "meng", "mi", "mian", "miao", "mie", "min", "ming", "miu", "mo", "mou", "mu", "n", "na", "nai", "nan", "nang", "nao", "ne", "nei", "nen", "neng", "ng", "ni", "nian", "niang", "niao", "nie", "nin", "ning", "niu", "nong", "nou", "nu", "nuan", "nuo", "nue", "nv", "o", "ou", "pa", "pai", "pan", "pang", "pao", "pei", "pen", "peng", "pi", "pian", "piao", "pie", "pin", "ping", "po", "pou", "pu", "qi", "qia", "qian", "qiang", "qiao", "qie", "qin", "qing", "qiong", "qiu", "qu", "quan", "que", "qun", "ran", "rang", "rao", "re", "ren", "reng", "ri", "rong", "rou", "ru", "ruan", "rui", "run", "ruo", "sa", "sai", "san", "sang", "sao", "se", "sen", "seng", "sha", "shai", "shan", "shang", "shao", "she", "shei", "shen", "sheng", "shi", "shou", "shu", "shua", "shuai", "shuan", "shuang", "shui", "shun", "shuo", "si", "song", "sou", "su", "suan", "sui", "sun", "suo", "ta", "tai", "tan", "tang", "tao", "te", "tei", "teng", "ti", "tian", "tiao", "tie", "ting", "tong", "tou", "tu", "tuan", "tui", "tun", "tuo", "wa", "wai", "wan", "wang", "wei", "wen", "weng", "wo", "wu", "xi", "xia", "xian", "xiang", "xiao", "xie", "xin", "xing", "xiong", "xiu", "xu", "xuan", "xue", "xun", "ya", "yan", "yang", "yao", "ye", "yi", "yin", "ying", "yo", "yong", "you", "yu", "yuan", "yue", "yun", "za", "zai", "zan", "zang", "zao", "ze", "zei", "zen", "zeng", "zha", "zhai", "zhan", "zhang", "zhao", "zhe", "zhei", "zhen", "zheng", "zhi", "zhong", "zhou", "zhu", "zhua", "zhuai", "zhuan", "zhuang", "zhui", "zhun", "zhuo", "zi", "zong", "zou", "zu", "zuan", "zui", "zun", "zuo"},
    t_pyStr = {"阿啊呵腌吖锕啊呵嗄啊呵啊呵阿啊呵", "哀挨埃唉哎捱锿挨癌皑捱矮哎蔼霭嗳爱碍艾唉哎隘暧嗳瑷嗌嫒砹", "安谙鞍氨庵桉鹌广厂俺铵揞埯案按暗岸黯胺犴", "肮昂盎", "熬凹熬敖嚣嗷鏖鳌翱獒聱螯廒遨袄拗媪奥澳傲懊坳拗骜岙鏊", "八吧巴叭芭扒疤笆粑岜捌八拔跋茇菝魃把靶钯把爸罢霸坝耙灞鲅吧罢", "掰白百摆伯柏佰捭败拜呗稗", "般班搬斑颁扳瘢癍版板阪坂钣舨办半伴扮瓣拌绊", "帮邦浜梆膀榜绑棒膀傍磅谤镑蚌蒡", "包胞炮剥褒苞孢煲龅薄雹保宝饱堡葆褓鸨报暴抱爆鲍曝刨瀑豹趵", "背悲杯碑卑陂埤萆鹎北被备背辈倍贝蓓惫悖狈焙邶钡孛碚褙鐾鞴臂呗", "奔贲锛本苯畚奔笨夯坌", "崩绷嘣甭绷绷蹦迸甏泵蚌", "逼鼻荸比笔彼鄙匕俾妣吡秕舭必毕币秘避闭壁臂弊辟碧拂毙蔽庇璧敝泌陛弼篦婢愎痹铋裨濞髀庳毖滗蓖埤芘嬖荜贲畀萆薜筚箅哔襞跸狴", "编边鞭砭煸蝙笾鳊贬扁匾碥窆褊便变遍辩辨辫卞苄汴忭弁缏边", "标彪勺镖膘骠镳杓飚飑飙瘭髟表裱婊鳔", "憋瘪鳖别蹩瘪别", "宾滨彬斌缤濒槟傧玢豳镔鬓殡摈膑髌", "并兵冰槟饼屏丙柄秉炳禀邴并病摒", "般波播拨剥玻饽菠钵趵百博伯勃薄泊柏驳魄脖搏膊舶礴帛铂箔渤钹孛亳鹁踣簸跛薄柏簸掰擘檗卜啵", "逋晡钸不醭补捕堡卜哺卟不部布步怖簿埔埠瓿钚", "擦拆嚓礤", "猜才财材裁采彩踩睬采菜蔡", "参餐骖残惭蚕惨黪惨灿掺璨孱粲", "苍仓沧舱伧藏", "操糙曹槽嘈漕螬艚草", "策测侧厕册恻", "参岑涔", "噌层蹭", "差插叉碴喳嚓杈馇锸查察茶叉茬碴楂猹搽槎檫叉衩镲差刹叉诧岔衩杈汊姹", "差拆钗柴豺侪虿瘥", "搀掺觇单缠禅蝉馋潺蟾婵谗廛孱镡澶躔产铲阐谄冁蒇骣颤忏羼", "昌娼猖伥阊菖鲳长场常尝肠偿倘裳嫦徜苌场厂敞氅昶惝唱畅倡怅鬯", "超抄吵钞绰剿焯怊朝潮嘲巢晁炒吵耖", "车砗尺扯彻撤澈掣坼", "郴琛嗔抻陈沉晨沈尘臣辰橙忱谌宸碜称趁衬秤谶榇龀伧", "称撑秤瞠噌铛柽蛏成城程承诚盛乘呈惩澄橙丞埕枨塍铖裎酲逞骋裎称秤", "吃痴哧嗤蚩笞鸱媸螭眵魑持迟池驰匙弛踟墀茌篪坻尺齿耻侈褫豉赤斥翅啻炽敕叱饬傺彳瘛", "冲充涌憧忡艟舂茺崇虫宠冲铳", "抽瘳愁仇筹酬绸踌惆畴稠帱俦雠丑瞅臭", "出初樗除厨躇橱雏锄蜍刍滁蹰处楚储础杵褚楮处触畜矗怵搐绌黜亍憷", "揣搋揣揣啜踹嘬膪", "穿川巛氚传船遄椽舡喘舛串钏", "创窗疮床幢闯创怆", "吹炊垂锤捶陲椎槌棰", "春椿蝽纯唇醇淳鹑莼蠢", "戳踔绰啜辍龊", "差刺疵呲词辞慈磁瓷兹茨雌祠茈鹚糍此次刺赐伺", "从匆聪葱囱苁骢璁枞从丛琮淙", "凑楱辏腠", "粗徂殂促簇醋卒猝蹴蹙蔟酢", "蹿撺汆镩攒窜篡爨", "衰催摧崔隹榱璀脆粹萃翠瘁悴淬毳啐", "村皴存蹲忖寸", "搓撮磋蹉嵯矬痤瘥鹾撮脞错措挫厝锉", "答搭嗒耷褡哒打达答瘩沓鞑怛笪靼妲打大塔疸", "待呆呔逮歹傣大代带待戴袋贷逮殆黛怠玳岱迨骀绐埭甙", "单担丹耽眈殚箪儋瘅聃郸担胆掸赕疸瘅但担弹淡旦蛋诞惮啖澹氮萏瘅", "当裆铛党挡谠当荡档挡宕菪凼砀", "刀叨忉氘叨导倒岛蹈捣祷到道倒悼盗稻焘帱纛", "得德锝的得底", "得", "登灯蹬噔簦等戥邓凳瞪澄蹬磴镫嶝", "提低滴堤嘀氐镝羝的敌迪笛涤嘀狄嫡翟荻籴觌镝底抵诋邸砥坻柢氐骶的地第帝弟递蒂缔谛睇棣娣碲绨", "嗲", "颠滇掂癫巅点典碘踮丶电店甸淀垫殿奠惦佃玷簟坫靛钿癜阽", "雕刁凋叼貂碉鲷鸟调掉吊钓铫铞", "爹跌踮叠迭碟谍蝶喋佚牒耋蹀堞瓞揲垤鲽", "丁盯钉叮町酊疔仃耵玎顶鼎酊定订钉铤腚锭碇啶", "丢铥", "东冬咚岽氡鸫懂董硐动洞冻栋恫侗垌峒胨胴硐", "都兜蔸篼斗抖陡蚪读斗豆逗窦痘", "都督嘟读独顿毒渎牍犊黩髑椟肚睹堵赌笃度渡肚杜妒镀芏蠹", "端短断段锻缎煅椴簖", "堆对队兑敦碓憝怼镦", "吨敦蹲墩礅镦盹趸顿盾钝炖遁沌囤砘", "多咄哆掇裰度夺踱铎朵躲垛哚缍舵堕跺剁惰垛驮沲柁", "阿婀屙额俄哦鹅娥峨蛾讹莪锇恶恶饿扼愕遏噩呃厄鄂轭颚鳄谔锷萼腭垩鹗苊阏呃", "诶诶诶", "恩蒽摁", "而儿鸸鲕尔耳迩饵洱珥铒二贰佴", "发罚乏伐阀筏垡法砝发珐", "翻番帆藩幡蕃凡烦繁泛樊蕃燔矾蘩钒蹯反返饭犯范贩泛梵畈", "方芳妨坊邡枋钫房防妨坊肪鲂访仿纺彷舫放", "非飞啡菲扉霏妃绯蜚鲱肥腓淝菲匪诽斐蜚翡悱篚榧费废沸肺吠痱狒镄芾", "分纷氛芬吩酚玢坟焚汾棼鼢粉分份奋愤粪忿偾瀵鲼", "风封丰峰疯锋蜂枫烽酆葑沣砜逢缝冯讽唪奉缝凤俸葑", "佛", "否缶", "夫肤敷孵呋稃麸趺跗夫服福佛幅伏符浮扶弗拂袱俘芙孚匐辐涪氟桴蜉苻茯莩菔幞怫艴郛绂绋凫祓砩黻罘稃蚨芾蝠府父腐抚辅甫俯斧脯釜腑拊滏黼服复父负副富付妇附赴腹覆赋傅缚咐阜讣驸赙馥蝮鲋鳆咐", "夹咖嘎胳伽旮嘎噶轧尜钆嘎尕尬", "该赅垓陔改概盖丐钙芥溉戤", "干甘肝杆尴乾竿坩苷柑泔矸疳酐感敢赶杆橄秆擀澉干赣淦绀旰", "刚钢纲缸扛杠冈肛罡港岗钢杠戆筻", "高糕膏皋羔睾篙槔稿搞藁槁缟镐杲告膏诰郜锆", "歌格哥戈割胳搁疙咯鸽屹仡圪纥袼革格隔葛阁胳搁蛤嗝骼颌搿膈镉塥鬲个各合盖葛哿舸个各铬硌虼", "给", "根跟哏艮亘艮茛", "更耕庚羹赓耿颈梗哽鲠埂绠更", "工公共供功攻宫恭躬龚弓肱蚣觥巩拱汞珙共供贡", "句沟勾钩篝佝枸缑鞲狗苟岣枸笱够购构勾觏垢诟媾遘彀", "姑骨孤估辜咕呱箍沽菇轱鸪毂菰蛄酤觚骨古股鼓骨谷贾汩蛊毂鹄牯臌诂瞽罟钴嘏蛄鹘故顾固估雇锢梏牿崮痼鲴", "括瓜刮呱栝胍鸹寡呱剐挂褂卦诖", "乖掴拐怪", "关观官冠棺矜莞倌纶鳏管馆莞观惯冠贯罐灌掼盥涫鹳", "光咣胱桄广犷逛桄", "规归瑰龟硅闺皈傀圭妫鲑鬼轨诡癸匦庋宄晷簋贵桂跪柜刽炔刿桧炅鳜", "滚鲧衮绲磙辊棍", "过锅郭涡聒蝈崞埚呙国帼掴馘虢果裹猓椁蜾过", "哈铪虾蛤哈哈", "嘿咳嗨还孩骸海胲醢害亥骇氦", "酣憨顸鼾蚶含寒汗韩涵函晗焓邯邗喊罕阚汉汗憾翰撼旱捍悍瀚焊颔菡撖", "夯航吭杭绗珩颃巷沆", "蒿薅嚆号毫豪嚎壕貉嗥濠蚝好郝好号浩耗皓昊灏镐颢", "喝呵诃嗬和何合河核盒禾荷阂涸阖貉曷颌劾菏盍纥蚵翮和何喝赫吓贺荷鹤壑褐", "黑嘿嗨", "痕很狠恨", "哼亨横衡恒蘅珩桁横", "哼", "轰哄烘薨訇红洪鸿宏虹弘泓闳蕻黉荭哄哄讧蕻", "侯喉猴瘊篌糇骺吼后候後厚侯逅堠鲎", "乎呼忽糊惚唿滹轷烀和胡湖糊核壶狐葫弧蝴囫瑚斛鹄醐猢槲鹕觳煳鹘虎浒唬琥护户互糊虎沪祜扈戽笏岵怙瓠鹱冱", "华化花哗砉华划滑哗豁猾骅铧话华化划画桦", "怀徊淮槐踝坏划", "欢獾还环寰鬟桓圜洹郇缳锾萑缓换患幻唤宦焕痪涣浣奂擐豢漶逭鲩", "荒慌肓黄皇煌惶徨璜簧凰潢蝗蟥遑隍磺癀湟篁鳇晃恍谎幌晃", "挥辉灰恢徽堕诙晖麾珲咴虺隳回徊蛔茴洄毁悔虺会汇惠慧溃绘讳贿晦秽诲彗烩荟卉喙恚浍哕缋桧蕙蟪", "婚昏荤阍混魂浑馄珲混诨溷", "豁劐攉锪耠和活火伙夥钬和或获货祸惑霍豁藿嚯镬蠖", "其几期机基击奇激积鸡迹绩饥缉圾姬矶肌讥叽稽畸跻羁嵇唧畿齑箕屐剞玑赍犄墼芨丌咭笄乩革及即辑级极集急籍吉疾嫉藉脊棘汲岌笈瘠诘亟楫蒺殛佶戢嵴蕺几给己革济纪挤脊戟虮掎麂记系计济寄际技纪继既齐季寂祭忌剂冀妓骥蓟悸伎暨霁稷偈鲫髻觊荠跽哜鲚洎芰", "家加佳夹嘉茄挟枷珈迦伽浃痂笳葭镓袈跏夹颊戛荚郏恝铗袷蛱假甲搅贾缴绞饺矫佼狡剿侥皎胛铰挢岬徼湫敫钾嘏瘕价假架驾嫁稼家", "间坚监渐兼艰肩浅尖奸溅煎歼缄笺菅蒹搛湔缣戋犍鹣鲣鞯简减检剪捡拣俭碱茧柬蹇謇硷睑锏枧戬谫囝裥笕翦趼见间件建监渐健剑键荐鉴践舰箭贱溅槛谏僭涧饯毽锏楗腱牮踺", "将江疆姜浆僵缰茳礓豇讲奖蒋桨耩将降酱浆虹匠犟绛洚糨", "教交焦骄郊胶椒娇浇姣跤蕉礁鲛僬鹪蛟艽茭嚼矫峤角脚搅缴绞饺矫佼狡剿侥皎挢徼湫敫铰教觉校叫较轿嚼窖酵噍峤徼醮", "接结节街阶皆揭楷嗟秸疖喈结节杰捷截洁劫竭睫桔拮孑诘桀碣偈颉讦婕羯鲒解姐界解价介借戒届藉诫芥疥蚧骱家价", "今金禁津斤筋巾襟矜衿尽仅紧谨锦瑾馑卺廑堇槿进近尽仅禁劲晋浸靳缙烬噤觐荩赆妗", "经京精惊睛晶荆兢鲸泾旌茎腈菁粳警景井颈憬阱儆刭肼经境竟静敬镜劲竞净径靖痉迳胫弪婧獍靓", "扃窘炯迥炅", "究纠揪鸠赳啾阄鬏九酒久韭灸玖就旧救疚舅咎臼鹫僦厩桕柩", "车据且居俱拘驹鞠锯趄掬疽裾苴椐锔狙琚雎鞫局菊桔橘锔举柜矩咀沮踽龃榉莒枸据句具剧巨聚拒距俱惧沮瞿锯炬趄飓踞遽倨钜犋屦榘窭讵醵苣", "捐圈娟鹃涓镌蠲卷锩圈卷俊倦眷隽绢狷桊鄄", "嗟撅噘觉绝决脚嚼掘诀崛爵抉倔獗厥蹶攫谲矍孓橛噱珏桷劂爝镢蕨觖蹶倔", "军均君钧筠龟菌皲麇俊峻隽菌郡骏竣捃浚", "咖喀咔卡咯咔佧胩", "开揩锎慨凯铠楷恺蒈剀垲锴忾", "看刊堪勘龛戡侃砍坎槛阚莰看嵌瞰阚", "康慷糠闶扛抗炕亢伉闶钪", "尻考烤拷栲靠铐犒", "科颗柯呵棵苛磕坷嗑瞌轲稞疴蝌钶窠颏珂髁咳壳颏可渴坷轲岢可克客刻课恪嗑溘骒缂氪锞蚵", "肯恳啃垦龈裉", "坑吭铿", "空倥崆箜恐孔倥空控", "抠芤眍口扣寇叩蔻筘", "哭枯窟骷刳堀苦库裤酷喾绔", "夸垮侉跨挎胯", "蒯会快块筷脍哙侩狯浍郐", "宽髋款", "框筐匡哐诓狂诳夼况矿框旷眶邝圹纩贶", "亏窥盔岿悝魁睽逵葵奎馗夔喹隗暌揆蝰傀跬愧溃馈匮喟聩篑蒉愦", "昆坤鲲锟醌琨髡捆悃阃困", "括适阔扩廓栝蛞", "拉啦喇垃邋拉喇旯砬拉喇辣腊蜡剌瘌啦", "来莱徕涞崃铼赖睐癞籁赉濑", "兰蓝栏拦篮澜婪岚斓阑褴镧谰懒览揽榄缆漤罱烂滥", "啷狼郎廊琅螂榔锒稂阆朗浪郎莨蒗阆", "捞劳牢唠崂铹痨醪老姥佬潦栳铑络唠烙酪涝耢", "肋乐勒仂叻泐鳓了", "勒擂累雷擂羸镭嫘缧檑累蕾垒磊儡诔耒类泪累擂肋酹嘞", "棱楞棱塄冷愣", "哩离丽黎璃漓狸梨篱犁厘罹藜骊蜊黧缡喱鹂嫠蠡鲡蓠里理李礼哩鲤俚逦娌悝澧锂蠡醴鳢力利立历例丽励厉莉笠粒俐栗隶吏沥雳莅戾俪砺痢郦詈荔枥呖唳猁溧砾栎轹傈坜苈疠疬蛎鬲篥粝跞藓璃哩", "俩", "联连怜莲廉帘涟镰裢濂臁奁蠊鲢脸敛琏蔹裣练恋炼链殓楝潋", "量良梁凉粮粱踉莨椋墚两俩魉量亮辆凉谅晾踉靓", "撩撂聊疗辽僚寥撩撂缭寮燎嘹獠鹩了潦燎蓼钌了料廖镣撩撂尥钌", "咧裂咧列烈裂劣猎趔冽洌捩埒躐鬣咧", "林临秘邻琳淋霖麟鳞磷嶙辚粼遴啉瞵凛懔檩廪淋吝躏赁蔺膦", "拎令灵零龄凌玲铃陵伶聆囹棱菱苓翎棂瓴绫酃泠羚蛉柃鲮领令岭令另呤", "溜熘留流刘瘤榴浏硫琉遛馏镏旒骝鎏柳绺锍六陆溜碌遛馏镏鹨", "咯", "隆龙隆笼胧咙聋珑窿茏栊泷砻癃笼拢垄陇垅弄", "搂楼喽偻娄髅蝼蒌耧搂篓嵝露陋漏镂瘘喽", "噜撸卢炉庐芦颅泸轳鲈垆胪鸬舻栌鲁芦卤虏掳橹镥六路陆录露绿鹿碌禄辘麓赂漉戮簏鹭潞璐辂渌蓼逯轳氇", "峦挛孪栾銮滦鸾娈脔卵乱", "抡论轮伦沦仑抡囵纶论", "落罗捋罗逻萝螺锣箩骡猡椤脶镙裸倮蠃瘰络洛骆咯摞烙珞泺漯荦硌雒罗", "略掠锊", "旅履屡侣缕吕捋铝偻褛膂稆律绿率虑滤氯驴榈闾", "呒", "妈麻摩抹蚂嬷吗麻蟆马吗码玛蚂犸骂蚂唛杩么吗嘛", "埋霾买荬卖麦迈脉劢", "颟埋蛮馒瞒蔓谩鳗鞔满螨慢漫曼蔓谩墁幔缦熳镘", "忙茫盲芒氓邙硭莽蟒漭", "猫毛猫矛茅髦锚牦旄蝥蟊茆卯铆峁泖昴冒贸帽貌茂耄瑁懋袤瞀", "么麽", "没眉梅媒枚煤霉玫糜酶莓嵋湄楣猸镅鹛美每镁浼妹魅昧谜媚寐袂", "闷门扪钔闷懑焖们", "蒙蒙盟朦氓萌檬瞢甍礞虻艨蒙猛勐懵蠓蜢锰艋梦孟", "眯咪迷弥谜靡糜醚麋猕祢縻蘼米眯靡弭敉脒芈密秘觅蜜谧泌汨宓幂嘧糸", "棉眠绵免缅勉腼冕娩渑湎沔眄黾面", "喵描苗瞄鹋秒渺藐缈淼杪邈眇妙庙缪", "乜咩灭蔑篾蠛", "民珉岷缗玟苠敏悯闽泯皿抿闵愍黾鳘", "名明鸣盟铭冥茗溟瞑暝螟酩命", "谬缪", "摸无模麽磨摸摩魔膜蘑馍摹谟嫫抹没万默莫末冒磨寞漠墨抹陌脉嘿沫蓦茉貉秣镆殁瘼耱貊貘", "哞谋牟眸缪鍪蛑侔某", "模毪母姆姥亩拇牡目木幕慕牧墓募暮牟穆睦沐坶苜仫钼", "嗯唔嗯唔嗯", "那拿镎那哪那呢纳娜呐捺钠肭衲哪呐", "哪乃奶氖艿奈耐鼐佴萘柰", "囝囡难南男楠喃腩蝻赧难", "囊囔囊馕馕攮曩", "孬努挠呶猱铙硇蛲脑恼瑙垴闹淖", "哪呢呐讷呢呐", "哪馁那内", "嫩恁", "能", "嗯唔嗯唔嗯", "妮呢尼泥倪霓坭猊怩铌鲵你拟旎祢泥尿逆匿腻昵溺睨慝伲", "蔫拈年粘黏鲇鲶碾捻撵辇念廿酿埝", "娘酿酿", "鸟袅嬲茑尿溺脲", "捏涅聂孽蹑嗫啮镊镍乜陧颞臬蘖", "您恁", "宁凝拧咛狞柠苎甯聍拧宁拧泞佞", "妞牛纽扭钮狃忸拗", "农浓侬哝脓弄", "耨", "奴孥驽努弩胬怒", "暖", "娜挪傩诺懦糯喏搦锘", "虐疟", "女钕恧衄", "噢喔哦哦", "欧殴鸥讴瓯沤偶呕藕耦呕沤怄", "派扒趴啪葩爬扒耙杷钯筢怕帕琶", "拍排牌徘俳排迫派湃蒎哌", "番攀潘扳般盘胖磐蹒爿蟠判盼叛畔拚襻袢泮", "乓膀滂旁庞膀磅彷螃逄耪胖", "炮抛泡脬跑炮袍刨咆狍匏庖跑炮泡疱", "呸胚醅陪培赔裴锫配佩沛辔帔旆霈", "喷盆湓喷", "烹抨砰澎怦嘭朋鹏彭棚蓬膨篷澎硼堋蟛捧碰", "批坏披辟劈坯霹噼丕纰砒邳铍皮疲啤脾琵毗郫鼙裨埤陴芘枇罴铍陂蚍蜱貔否匹劈痞癖圮擗吡庀仳疋屁辟僻譬媲淠甓睥", "片篇偏翩扁犏便蹁缏胼骈谝片骗", "漂飘剽缥螵朴瓢嫖漂瞟缥殍莩票漂骠嘌", "撇瞥氕撇丿苤", "拼拚姘贫频苹嫔颦品榀聘牝", "乒娉俜平评瓶凭萍屏冯苹坪枰鲆", "颇坡泊朴泼陂泺攴钋繁婆鄱皤叵钷笸破迫朴魄粕珀", "剖裒掊掊", "铺扑仆噗葡蒲仆脯菩匍璞濮莆镤普堡朴谱浦溥埔圃氆镨蹼暴铺堡曝瀑", "期七妻欺缉戚凄漆栖沏蹊嘁萋槭柒欹桤其奇棋齐旗骑歧琪祈脐祺祁崎琦淇岐荠俟耆芪颀圻骐畦亓萁蕲畦蛴蜞綦鳍麒起企启岂乞稽绮杞芑屺綮气妻器汽齐弃泣契迄砌憩汔亟讫葺碛", "掐伽葜袷卡恰洽髂", "千签牵迁谦铅骞悭芊愆阡仟岍扦佥搴褰钎前钱潜乾虔钳掮黔荨钤犍箝鬈浅遣谴缱肷欠歉纤嵌倩堑茜芡慊椠", "将枪抢腔呛锵跄羌戕戗镪蜣锖墙蔷樯嫱强抢襁镪羟呛跄炝戗", "悄敲雀锹跷橇缲硗劁桥乔侨瞧翘蕉憔樵峤谯荞鞒悄巧雀愀翘俏窍壳峭撬鞘诮谯", "切茄伽且切窃怯趄妾砌惬锲挈郄箧慊", "亲钦侵衾琴秦勤芹擒矜覃禽噙廑溱檎锓嗪芩螓寝沁揿吣", "青清轻倾卿氢蜻圊鲭情晴擎氰檠黥请顷謦苘亲庆罄磬箐綮", "穷琼穹茕邛蛩筇跫銎", "秋邱丘龟蚯鳅楸湫求球仇囚酋裘虬俅遒赇泅逑犰蝤巯鼽糗", "区曲屈趋驱躯觑岖蛐祛蛆麴诎黢渠瞿衢癯劬璩氍朐磲鸲蕖蠼蘧取曲娶龋苣去趣觑阒戌", "圈悛全权泉拳诠颧蜷荃铨痊醛辁筌鬈犬绻畎劝券", "缺阙炔瘸却确雀榷鹊阕阙悫", "逡群裙麇", "然燃髯蚺染冉苒", "嚷瓤禳穰嚷攘壤禳让", "饶娆桡荛扰绕娆绕", "若惹喏热", "人任仁壬忍稔荏任认韧刃纫饪仞葚妊轫衽", "扔仍", "日", "容荣融蓉溶绒熔榕戎嵘茸狨肜蝾冗", "柔揉蹂糅鞣肉", "如儒茹嚅濡孺蠕薷铷襦颥辱乳汝入褥缛洳溽蓐", "软阮朊", "蕤蕊瑞锐芮睿枘蚋", "润闰", "若弱偌箬", "撒仨挲洒撒萨卅飒脎", "思塞腮鳃噻赛塞", "三叁毵散伞馓糁霰散", "丧桑嗓搡磉颡丧", "骚搔臊缲缫鳋扫嫂扫梢臊埽瘙", "色塞涩瑟啬铯穑", "森", "僧", "杀沙刹纱杉莎煞砂挲鲨痧裟铩傻沙啥厦煞霎嗄歃唼", "筛酾色晒", "山衫删煽扇珊杉栅跚姗潸膻芟埏钐舢苫髟闪陕掺掸单善扇禅擅膳讪汕赡缮嬗掸骟剡苫鄯钐疝蟮鳝", "商伤汤殇觞熵墒上赏晌垧上尚绱裳", "烧稍梢捎鞘蛸筲艄勺韶苕杓芍少少绍召稍哨邵捎潲劭", "奢赊猞畲折舌蛇佘舍社设舍涉射摄赦慑麝滠歙厍", "谁", "身深参申伸绅呻莘娠诜砷糁什神甚审沈婶谂哂渖矧甚慎渗肾蜃葚胂椹", "生声胜升牲甥笙绳渑省眚胜圣盛乘剩嵊晟", "师诗失施尸湿狮嘘虱蓍酾鲺时十实什识食石拾蚀埘莳炻鲥使始史驶屎矢豕是事世市士式视似示室势试释适氏饰逝誓嗜侍峙仕恃柿轼拭噬弑谥莳贳铈螫舐筮殖匙", "收熟手首守艏受授售瘦寿兽狩绶", "书输殊舒叔疏抒淑梳枢蔬倏菽摅姝纾毹殳疋熟孰赎塾秫数属署鼠薯暑蜀黍曙数术树述束竖恕墅漱戍庶澍沭丨腧", "刷唰耍刷", "衰摔甩率帅蟀", "栓拴闩涮", "双霜孀泷爽", "谁水说税睡", "吮顺舜瞬", "说数朔硕烁铄妁蒴槊搠", "思斯司私丝撕厮嘶鸶咝澌缌锶厶蛳死四似食寺肆伺饲嗣巳祀驷泗俟汜兕姒耜笥厕", "松忪淞崧嵩凇菘耸悚怂竦送宋诵颂讼", "搜艘馊嗖溲飕锼螋擞叟薮嗾瞍嗽擞", "苏稣酥俗诉速素肃宿缩塑溯粟簌夙嗉谡僳愫涑蔌觫", "酸狻算蒜", "虽尿荽睢眭濉随遂隋绥髓岁碎遂祟隧邃穗燧谇", "孙荪狲飧损笋榫隼", "缩莎梭嗦唆挲娑睃桫嗍蓑羧所索锁琐唢", "他她它踏塌遢溻铊趿塔鳎獭踏拓榻嗒蹋沓挞闼漯", "台胎苔台抬苔邰薹骀炱跆鲐呔太态泰汰酞肽钛", "摊贪滩瘫坍谈弹坛谭潭覃痰澹檀昙锬镡郯坦毯忐袒钽探叹炭碳", "汤趟铴镗耥羰堂唐糖膛塘棠搪溏螳瑭樘镗螗饧醣躺倘淌傥帑趟烫", "涛掏滔叨焘韬饕绦逃陶桃淘萄啕洮鼗讨套", "特忑忒慝铽", "忒", "腾疼藤誊滕", "体踢梯剔锑提题啼蹄醍绨缇鹈荑体替涕剃惕屉嚏悌倜逖绨裼", "天添田填甜恬佃阗畋钿腆舔忝殄掭", "挑佻祧条调迢鲦苕髫龆蜩笤挑窕跳眺粜", "贴帖萜铁帖帖餮", "听厅汀烃停庭亭婷廷霆蜓葶莛挺艇町铤梃梃", "通恫嗵同童彤铜桐瞳佟酮侗仝垌茼峒潼砼统筒桶捅侗同通痛恸", "偷头投骰钭透", "突秃凸图途徒屠涂荼菟酴土吐钍吐兔堍菟", "湍团抟疃彖", "推忒颓腿退褪蜕煺", "吞暾屯饨臀囤豚氽褪", "托脱拖乇陀舵驼砣驮沱跎坨鸵橐佗铊酡柁鼍妥椭庹魄拓唾柝箨", "挖哇凹娲蛙洼娃瓦佤瓦袜腽哇", "歪崴外", "湾弯蜿剜豌完玩顽丸纨芄烷晚碗挽婉惋宛莞娩畹皖绾琬脘菀万腕蔓", "汪尢王忘亡芒往网枉惘罔辋魍望王往忘旺妄", "委威微危巍萎偎薇逶煨崴葳隈为维围唯违韦惟帷帏圩囗潍桅嵬闱沩涠委伟唯尾玮伪炜纬萎娓苇猥痿韪洧隗诿艉鲔为位未味卫谓遗慰魏蔚畏胃喂尉渭猬軎", "温瘟文闻纹蚊雯璺阌稳吻紊刎问纹汶璺", "翁嗡蓊瓮蕹", "窝涡蜗喔倭挝莴哦我握卧哦渥沃斡幄肟硪龌", "於恶屋污乌巫呜诬兀钨邬圬无亡吴吾捂毋梧唔芜浯蜈鼯五武午舞伍侮捂妩忤鹉牾迕庑怃仵物务误恶悟乌雾勿坞戊兀晤鹜痦寤骛芴杌焐阢婺鋈", "西息希吸惜稀悉析夕牺腊昔熙兮溪嘻锡晰樨熄膝栖郗犀曦奚羲唏蹊淅皙汐嬉茜熹烯翕蟋歙浠僖穸蜥螅菥舾矽粞硒醯欷鼷席习袭媳檄隰觋喜洗禧徙玺屣葸蓰铣系细戏隙饩阋禊舄", "瞎虾呷峡侠狭霞暇辖遐匣黠瑕狎硖瘕柙下夏吓厦唬罅", "先鲜仙掀纤暹莶锨氙祆籼酰跹闲贤嫌咸弦娴衔涎舷鹇痫显险鲜洗跣猃藓铣燹蚬筅冼现见线限县献宪陷羡馅腺岘苋霰", "相香乡箱厢湘镶襄骧葙芗缃降详祥翔庠想响享飨饷鲞相向象像项巷橡蟓", "消销潇肖萧宵削嚣逍硝霄哮枭骁箫枵哓蛸绡魈淆崤小晓筱笑校效肖孝啸", "些歇楔蝎协鞋携斜胁谐邪挟偕撷勰颉缬写血写解谢泄契械屑卸懈泻亵蟹邂榭瀣薤燮躞廨绁渫榍獬", "心新欣辛薪馨鑫芯昕忻歆锌寻镡信芯衅囟", "兴星腥惺猩行形型刑邢陉荥饧硎省醒擤性兴姓幸杏悻荇", "兄胸凶匈汹芎雄熊", "修休羞咻馐庥鸺貅髹宿朽秀袖宿臭绣锈嗅岫溴", "需须虚吁嘘墟戌胥砉圩盱顼徐许浒栩诩糈醑续序绪蓄叙畜恤絮旭婿酗煦洫溆勖蓿", "宣喧轩萱暄谖揎儇煊旋悬玄漩璇痃选癣旋券炫渲绚眩铉泫碹楦镟", "削靴薛学穴噱踅泶雪鳕血谑", "熏勋荤醺薰埙曛窨獯寻询巡循旬驯荀峋洵恂郇浔鲟训迅讯逊熏殉巽徇汛蕈浚", "压雅呀押鸦哑鸭丫垭桠牙涯崖芽衙睚伢岈琊蚜雅瞧匹痖疋亚压讶轧娅迓揠氩砑呀", "烟燕咽殷焉淹阉腌嫣胭湮阏鄢菸崦恹言严研延沿颜炎阎盐岩铅蜒檐妍筵芫闫阽眼演掩衍奄俨偃魇鼹兖郾琰罨厣剡鼽研验沿厌燕宴咽雁焰艳谚彦焱晏唁砚堰赝餍滟酽谳", "央泱秧鸯殃鞅洋阳杨扬羊疡佯烊徉炀蛘养仰痒氧样漾恙烊怏鞅", "要约邀腰夭妖吆幺摇遥姚陶尧谣瑶窑肴侥铫珧轺爻徭繇鳐咬杳窈舀崾要药耀钥鹞曜疟", "耶噎椰掖爷耶邪揶铘也野冶业夜叶页液咽哗曳拽烨掖腋谒邺靥晔", "一医衣依椅伊漪咿揖噫猗壹铱欹黟移疑遗宜仪蛇姨夷怡颐彝咦贻迤痍胰沂饴圯荑诒眙嶷以已衣尾椅矣乙蚁倚迤蛾旖苡钇舣酏意义议易衣艺译异益亦亿忆谊抑翼役艾溢毅裔逸轶弈翌疫绎佚奕熠诣弋驿懿呓屹薏噫镒缢邑臆刈羿仡峄怿悒肄佾殪挹埸劓镱瘗癔翊蜴嗌翳", "因音烟阴姻殷茵荫喑湮氤堙洇铟银吟寅淫垠鄞霪狺夤圻龈引隐饮瘾殷尹蚓吲印饮荫胤茚窨", "应英鹰婴樱膺莺罂鹦缨瑛璎撄嘤营迎赢盈蝇莹荧萤萦瀛楹嬴茔滢潆荥蓥影颖颍瘿郢应硬映媵", "育哟唷哟", "拥庸佣雍臃邕镛墉慵痈壅鳙饔喁永勇涌踊泳咏俑恿甬蛹用佣", "优幽忧悠攸呦由游油邮尤犹柚鱿莸尢铀猷疣蚰蝣蝤繇莜有友黝酉莠牖铕卣有又右幼诱佑柚囿鼬宥侑蚴釉", "於吁迂淤纡瘀于与余予鱼愚舆娱俞愉馀逾渔渝俞萸瑜隅揄榆虞禺谀腴竽妤臾欤觎盂窬蝓嵛狳舁雩与语雨予宇羽禹圄屿龉伛圉庾瘐窳俣与语育遇狱雨欲预玉愈谷域誉吁蔚寓豫粥郁喻裕浴御驭尉谕毓妪峪芋昱煜熨燠菀蓣饫阈鬻聿钰鹆鹬蜮", "冤渊鸳眢鸢箢员元原园源圆缘援袁猿垣辕沅媛芫橼圜塬爰螈鼋远院愿怨苑媛掾垸瑗", "约曰说月乐越阅跃悦岳粤钥刖瀹栎樾龠钺", "晕氲员云匀筠芸耘纭昀郧允陨殒狁员运均韵晕孕蕴酝愠熨郓韫恽", "扎咂匝拶杂咱砸咋", "灾哉栽甾载仔宰崽在再载", "簪糌咱攒拶昝趱赞暂瓒錾咱", "赃臧锗驵藏脏葬奘", "遭糟凿早澡枣蚤藻缲造灶躁噪皂燥唣", "则责泽择咋啧迮帻赜笮箦舴侧仄昃", "贼", "怎谮", "曾增憎缯罾赠综缯甑锃", "查扎咋渣喳揸楂哳吒齄炸扎札喋轧闸铡眨砟炸咋诈乍蜡栅榨柞吒咤痄蚱", "摘侧斋择宅翟窄债祭寨砦瘵", "占沾粘瞻詹毡谵旃展斩辗盏崭搌战站占颤绽湛蘸栈", "张章彰璋蟑樟漳嫜鄣獐长掌涨仉丈涨帐障账胀仗杖瘴嶂幛", "着招朝嘲昭钊啁着找爪沼照赵召罩兆肇诏棹笊", "折遮蜇折哲辙辄谪蛰摺磔蜇者褶锗赭这浙蔗鹧柘着", "这", "真针珍斟贞侦甄臻箴砧桢溱蓁椹榛胗祯浈诊枕疹缜畛轸稹阵镇震圳振赈朕鸩", "正争征丁挣症睁徵蒸怔筝铮峥狰钲鲭整拯政正证挣郑症怔铮诤帧", "之只知指支织氏枝汁掷芝吱肢脂蜘栀卮胝祗直指职值执植殖侄踯摭絷跖埴只指纸止址旨徵趾咫芷枳祉轵黹酯知至制识治志致质智置秩滞帜稚挚掷峙窒炙痔栉桎帙轾贽痣豸陟忮彘膣雉鸷骘蛭踬郅觯", "中终钟忠衷锺盅忪螽舯种肿踵冢中重众仲", "周州洲粥舟诌啁轴妯碡肘帚皱骤轴宙咒昼胄纣绉荮籀繇酎", "诸朱珠猪株蛛洙诛铢茱邾潴槠橥侏术逐筑竹烛躅竺舳瘃主属煮嘱瞩拄褚渚麈住注助著驻祝筑柱铸伫贮箸炷蛀杼翥苎疰", "抓挝爪", "拽转曳拽嘬", "专砖颛转传转赚撰沌篆啭馔", "装庄妆桩奘状壮撞幢僮戆", "追锥隹椎骓坠缀赘惴缒", "屯谆肫窀准", "桌捉卓拙涿焯倬着著琢缴灼酌浊濯茁啄斫镯诼禚擢浞", "资咨滋仔姿吱兹孜谘呲龇锱辎淄髭赀孳粢趑觜訾缁鲻嵫子紫仔梓姊籽滓秭笫耔茈訾自字渍恣眦", "宗踪综棕鬃枞腙总偬纵粽", "邹诹陬鄹驺鲰走奏揍", "租菹足族卒镞组祖阻诅俎", "钻躜纂缵赚钻攥", "堆嘴咀觜最罪醉蕞", "尊遵樽鳟撙", "作嘬作昨琢笮左佐撮作做坐座凿柞怍胙阼唑祚酢"},

    --string.find() "."是 任意字符； *： 匹配前面指定的 0 或多个同类字符， 尽可能匹配更长的符合条件的字串
    --先留在这里，如果打开拼音搜索 或者 英文搜索时， 搜索. **这些会触发模式匹配，搜索到全部内容
    isPattern = function(text) 
        if text == "." then
            return
        end
    end,

    --搜索算法的总入口
    Search = function(text,sourceTable,isSearchPinyin)
        local print = Android:Localize();
        print("SearchAlgorithm.Search(): text = ", text)
        print("SearchAlgorithm.Search(): sourceTable = ", sourceTable)

        if text == "" then
            ShowGameTips(GetS(21739));
            return
        end


        local this = SearchAlgorithm;
        local searchResult = {};

        local isChinese = true;             --判断是否包含汉字
        isChinese = this.judgeChinese(text);
        print("SearchAlgorithm.Search(): isChinese = ", isChinese)
        print("SearchAlgorithm.Search(): #text = ", #text)
        if isChinese then
            print("SearchAlgorithm.Search(): 中文搜索")
            print(string.len(text))
            if string.len(text) > 45 then
                text = string.sub(text,1,45);
            end
        else
            print("SearchAlgorithm.Search(): 英文搜索")
            print(string.len(text))
            if string.len(text) > 45 then
                text = string.sub(text,1,45);
            end
        end
        print("SearchAlgorithm.Search(): text = ", text)

        local language = get_game_lang();
        print("SearchAlgorithm.Search(): language = ", language);
        print("SearchAlgorithm.Search(): type(language) = ", type(language));

        print("SearchAlgorithm.Search(): closePinyinSearch = ", closePinyinSearch);
        if get_game_lang() ~= 0 and get_game_lang() ~= 2 then                                               -- 海外版本
            searchResult = this.searchEnglish(text,sourceTable);
        else                                                                -- 国内

            if isChinese or tonumber(text) ~= nil then
                searchResult = this.searchChinese(text,sourceTable);
            elseif isSearchPinyin == true or closePinyinSearch == false then
                --这里判断text是否包含特殊字符 拼音只包含 26个字母，空格也不包含
                if string.match(text, "%a+") then
                    searchResult = this.searchPinyin(text,sourceTable);
                end
            end
        end

        print("SearchAlgorithm.Search(): searchResult = ", searchResult)
        return searchResult;
    end,

    --搜索算法的总入口,逻辑编辑器特化版,
	--改动：输入英文时，调用searchEnglish。
    SearchForVisualCode = function(text,sourceTable)
        local print = Android:Localize();
        print("SearchAlgorithm.SearchForVisualCode(): text = ", text)
        print("SearchAlgorithm.SearchForVisualCode(): sourceTable = ", sourceTable)

        if text == "" then
            ShowGameTips(GetS(21739));
            return
        end

        --替换掉字符串中的特殊字符
        text = string.gsub(text, "%%", "")

        local this = SearchAlgorithm;
        local searchResult = {};

        local isChinese = true;             --判断是否包含汉字
        isChinese = this.judgeChinese(text);
        print("SearchAlgorithm.SearchForVisualCode(): isChinese = ", isChinese)
        print("SearchAlgorithm.SearchForVisualCode(): #text = ", #text)
        if isChinese then
            print("SearchAlgorithm.SearchForVisualCode(): 中文搜索")
            print(string.len(text))
            if string.len(text) > 45 then
                text = string.sub(text,1,45);
            end
        else
            print("SearchAlgorithm.SearchForVisualCode(): 英文搜索")
            print(string.len(text))
            if string.len(text) > 45 then
                text = string.sub(text,1,45);
            end
        end
        print("SearchAlgorithm.SearchForVisualCode(): text = ", text)

        local language = get_game_lang();
        print("SearchAlgorithm.SearchForVisualCode(): language = ", language);
        print("SearchAlgorithm.SearchForVisualCode(): type(language) = ", type(language));

        print("SearchAlgorithm.SearchForVisualCode(): closePinyinSearch = ", closePinyinSearch);
        if (get_game_lang() ~= 0 and get_game_lang() ~= 2) or not isChinese then-- 海外版本
            searchResult = this.searchEnglish(text,sourceTable);
        else                                                                -- 国内
            if isChinese or tonumber(text) ~= nil then
                searchResult = this.searchChinese(text,sourceTable);
            end
        end

        print("SearchAlgorithm.SearchForVisualCode(): searchResult = ", searchResult)
        return searchResult;
    end,

    --精准匹配中文
    searchChinese = function(text,sourceTable)
        local print = Android:Localize();
        print("SearchAlgorithm.searchChinese(): text = ", text)
        print("SearchAlgorithm.searchChinese(): sourceTable = ", sourceTable)
        local idList = {};

        local ItemNameList = sourceTable.ItemNameList;
        local ItemDescList = sourceTable.ItemDescList;
        print("SearchAlgorithm.searchChinese(): ItemNameList = ", ItemNameList)
        print("SearchAlgorithm.searchChinese(): ItemDescList = ", ItemDescList)

        local ItemGetWayList = {};
        if sourceTable.ItemGetWayList then
            ItemGetWayList = sourceTable.ItemGetWayList
        end

        if text ==nil or sourceTable == nil then return end

        if ItemNameList and next(ItemNameList)~= nil then
            for k,v in pairs(ItemNameList) do
                if  string.find(v,text)~= nil then          -- 判断名字列表
                    table.insert(idList,1,k);
                elseif ItemDescList then
                    local desc = ItemDescList[k];
                    if desc ~= nil then 
                        if  string.find(desc,text)~= nil then   --判断描述列表
                            table.insert(idList,k);
                        else
                            if ItemGetWayList then
                                local getway = ItemGetWayList[k];
                                if getway ~= nil then 
                                    if  string.find(getway,text)~= nil then   --判断获取方式列表
                                        table.insert(idList,k);
                                    end
                                end
                            end                            
                        end  
                    else
                        if ItemGetWayList then
                            local getway = ItemGetWayList[k];
                            if getway ~= nil then 
                                if  string.find(getway,text)~= nil then   --判断获取方式列表
                                    table.insert(idList,k);
                                end
                            end
                        end                              
                    end
                end
            end
        end

        print("SearchAlgorithm.searchChinese(): idList = ", idList)
        return idList;
    end,

    --搜索英文
    searchEnglish = function(text,sourceTable)
        print("SearchAlgorithm.searchEnglish()",text,sourceTable)

        local idList = {};

        local ItemNameList = sourceTable.ItemNameList;
        local ItemDescList = sourceTable.ItemDescList;

        if text ==nil or sourceTable == nil then return end

        text = string.lower(text)
        if ItemNameList and next(ItemNameList)~= nil then
            for k,v in pairs(ItemNameList) do
                if  string.find(string.lower(v),text)~= nil then          -- 判断名字列表
                    table.insert(idList,1,k);
                elseif ItemDescList then
                    local desc = ItemDescList[k];
                    if desc == nil then break;end

                    if  string.find(string.lower(desc),text)~= nil then   --判断描述列表
                        table.insert(idList,k);
                    end
                end
            end
        end

        return idList;
    end,

    --搜索拼音
    searchPinyin = function(text,sourceTable)
        print("SearchAlgorithm.searchPinyin()",text);
        local idList = {};
        local this = SearchAlgorithm;

        local ItemNamePinyinList = sourceTable.ItemNamePinyinList;
        local ItemDescPinyinList = sourceTable.ItemDescPinyinList;
        local ItemNamePinyinInitialsList = sourceTable.ItemNamePinyinInitialsList
        local ItemDescPinyinInitialsList= sourceTable.ItemDescPinyinInitialsList;

        if text ==nil or ItemNamePinyinList == nil then return end

        text = string.lower(text)

        if ItemNamePinyinList and next(ItemNamePinyinList)~= nil then
            for k,v in pairs(ItemNamePinyinList) do
                if  string.find(v,text)~= nil then                      --判断拼音名字列表
                    table.insert(idList,1,k);
                elseif this.matchingText(text,ItemNamePinyinInitialsList,k) then --判断拼音名字首字母是否匹配
                    table.insert(idList,1,k);
                elseif this.matchingText(text,ItemDescPinyinList,k) then --判断拼音描述是否匹配
                    table.insert(idList,k);
                elseif this.matchingText(text,ItemDescPinyinInitialsList,k) then --判断拼音描述首字母是否匹配
                    table.insert(idList,k);
                end
            end
        end

        return idList;
    end,

    --判断list中索引为itemid的项，是否包含Text
    matchingText = function(Text,List,ItemId)
        if List == nil or next(List) == nil then return false end

        local  matchText = List[ItemId];
        if matchText == nil then return false end

        if  string.find(matchText,Text)~= nil then
            return true;
        else
            return false;
        end
    end,

    --判断输入的是否是中文
    judgeChinese = function(str)
        print("SearchAlgorithm.judgeChinese()",str)
        if str == nil then return end
        local str = str;

        for ch in string.gmatch(str, "[\\0-\127\194-\244][\128-\191]*") do
            if #ch~=1 then
                return true;
            end
            print(ch,#ch~=1);
        end

        return false
    end,

    --中文转化成拼音和首字母
    chineseToPinyin = function(text)
        print("SearchAlgorithm.chineseToPinyin()",text)
        local this = SearchAlgorithm;

        if text == nil then return end
        local str = text;
        local pinyinStr ="";                --转换成拼音字符串
        local pinyinInitials="";            --转换成搜字母字符串
        for ch in string.gmatch(str, "[\\0-\127\194-\244][\128-\191]*") do
            if #ch~=1 then
                local changeStr = this.charactersToPinyin(ch);
                if changeStr~= nil then
                    pinyinStr = pinyinStr..changeStr;
                    pinyinInitials = pinyinInitials..string.sub(changeStr,1,1);
                end
            end
        end
        return pinyinStr,pinyinInitials;

    end,

    --单个中文文字转化成拼音
    charactersToPinyin = function(word)
        local this = SearchAlgorithm;
        for i =1,#this.t_pyStr do
            if string.find(this.t_pyStr[i],word) ~= nil then
                local pinyin = this.t_pyValue[i];
                if pinyin ~=nil then
                    return pinyin
                end
            end
        end

        return nil ;
    end,

}

--游戏内搜索管理类
SearchMgr = {
    searchText = nil,               --搜索词语单独保存
    isUseSearchBackpack = false,    --背包搜索后道具使用上报标志
    isUseSearchStash = false,       --仓库搜索后道具使用上报标志

    --注册委托
    RegisterDelegate = function()
        local this = SearchMgr;
        BackPackView.funcTable[delegateDefine.CreateBackPackSearch] = this.SearchCreateBackpack;
        BackPackView.funcTable[delegateDefine.ShowCreateBackPackSearchPanel] = this.ShowCreateBackPackSearchPanel;

        StashView.funcTable[delegateDefine.StoreFrameStashSearch] = this.StoreFrameStashSearch;
        StashView.funcTable[delegateDefine.ShowStoreFrameStashSearchPanel] = this.ShowStoreFrameStashSearchPanel;
        StashView.funcTable[delegateDefine.HideStoreFrameStashSearchPanel] = this.HideStoreFrameStashSearchPanel;
    end,

    Init = function()
        local this = SearchMgr;
        this.RegisterDelegate();
    end,

    --搜索创造背包回调
    SearchCreateBackpack = function(text)
        local print = Android:Localize();
        print("SearchMgr.SearchCreateBackpack(): text = ", text)
        local this = SearchMgr;

        local data = {};
        data.ItemNameList  = BackPackData.ItemNameList;
        data.ItemDescList= BackPackData.ItemDescList;
        data.ItemNamePinyinList = BackPackData.ItemNamePinyinList;
        data.ItemDescPinyinList= BackPackData.ItemDescPinyinList;
        data.ItemNamePinyinInitialsList = BackPackData.ItemNamePinyinInitialsList
        data.ItemDescPinyinInitialsList= BackPackData.ItemDescPinyinInitialsList;
        data.ItemGetWayList = BackPackData.ItemGetWayList;

        local itemIdList = SearchAlgorithm.Search(text,data);
        print("SearchMgr.SearchCreateBackpack(): itemIdList = ", itemIdList)
        if itemIdList == nil or (itemIdList and next(itemIdList) == nil) then
            local inputText = string.gsub(text, "|", "")
            -- statisticsGameEvent(61031,"%d",1)
            -- statisticsGameEvent(61034, "%lls", inputText,"%d",1)
        else
            -- statisticsGameEvent(61030,"%d",1)
        end

        --埋点
        if this.isUseSearchBackpack == false and this.searchText ~= nil then
            --print("背包道具没使用")
            -- statisticsGameEvent(61033, "%d",1) --搜索结果没有点击的上报
        end
        this.isUseSearchBackpack = false

        this.searchText = text;
        if text ==nil or text == "" then return end;
        local itemList = this.GetItemList(itemIdList);

        BackPackView:showSearchContent(itemList);

    end,

    --创造背包搜索界面显示
    ShowCreateBackPackSearchPanel = function()
        print("ShowCreateBackPackSearchPanel")
        if BackPackData.NeedLoadDef() then
            --threadpool:work(BackPackData:loadFromDef());
        end
    end,

    --通过itemid的列表获取item列表
    GetItemList= function(itemIdList)
        print("SearchMgr.GetItemList()",itemIdList)
        if itemIdList ==nil or next(itemIdList)== nil then return  end

        local itemList = {};
        for k,v in pairs(itemIdList) do

            local item  = ItemDefCsv:get(v);
            if item  then
                if not (CurWorld:isGameMakerMode() ==false and item.CreateType and item.CreateType==5) then
                    table.insert(itemList,item);
                end
            end
        end
        return itemList
    end,

    --商城仓库搜索回调
    StoreFrameStashSearch = function(text)
        print("SearchMgr.StoreFrameStashSearch()",text);
        local this = SearchMgr;
        local data = {};
        data.ItemNameList  = StashData.ItemNameList;
        data.ItemDescList= StashData.ItemDescList;
        data.ItemNamePinyinList = StashData.ItemNamePinyinList;
        data.ItemDescPinyinList= StashData.ItemDescPinyinList;
        data.ItemNamePinyinInitialsList = StashData.ItemNamePinyinInitialsList
        data.ItemDescPinyinInitialsList= StashData.ItemDescPinyinInitialsList;

        local idList = {};                                  --搜索出来的结果，id列表
        local accountItemList = {};                         --获取到的账号部分需要的账号物品列表

        if data == nil or next(data) == nil then return end

        idList = SearchAlgorithm.Search(text,data);

        --埋点
        if this.isUseSearchStash == false and this.searchText ~= nil then
            --print("仓库道具没使用")
            -- statisticsGameEvent(61033, "%d",2) --搜索结果没有点击的上报
        end
        this.isUseSearchStash = false

        accountItemList = StashData.getAccountItemByIdList(idList);
        this.searchText = text;

        if accountItemList== nil or (accountItemList and next(accountItemList) == nil ) then
            StashView.ShowNoneItem(true);

            local inputText = string.gsub(text, "|", "")
            -- statisticsGameEvent(61031,"%d",2)
            -- statisticsGameEvent(61034, "%lls", inputText,"%d",2)

            return
        else
            -- statisticsGameEvent(61030,"%d",2)

            StashView.ShowNoneItem(false)
        end

        SetStashProp(accountItemList);                      --设置要显示的账号物品缓存列表
        UpdateStashProp();                                  --刷新显示物品列表

        StashView.SetStashBoxPanelSizeByNum(#accountItemList);

    end,

    --商城仓库搜索界面显示
    ShowStoreFrameStashSearchPanel = function()
        --StashData.loadFromDef();
    end,

    --关闭商城仓库搜索界面外部调用
    CloseStoreFrameStashSearch = function()
        local this = SearchMgr;
        if this.isUseSearchStash == false and getglobal("StoreFrameStashSearchContent"):IsShown() then
            --print("仓库道具没使用")
            -- statisticsGameEvent(61033, "%d",2) --搜索结果没有点击的上报
        end

        StashView.closeSearchPanel();

        this.isUseSearchStash = false;
        this.searchText = nil;
    end,

    --关闭商城仓库搜索界面回调
    HideStoreFrameStashSearchPanel = function()
        LoadStashPropList();
        UpdateStashProp();
    end,

    --关闭背包搜索页面
    CloseCreateBackPack = function()
        local this = SearchMgr;

        if this.isUseSearchBackpack == false and getglobal("CreateBackpackFrameSearchContent"):IsShown() then
            --print("背包道具没使用")
            -- statisticsGameEvent(61033, "%d",1) --搜索结果没有点击的上报
        end
        BackPackView.closeSearchPanel();

        this.isUseSearchBackpack = false;
        this.searchText = nil
    end,

    --重置商城背包数据
    ResetStoreStashData = function()
        StashData.reset();
        StashView.closeSearchPanel(true);
    end,

    --使用仓库物品
    UseStashItem = function(itemDef)
        local this = SearchMgr;
        if next(StashData.ItemNameList) == nil and  next(StashData.ItemDescList) ==nil then
            return
        end

        StashData.UseStashItem(itemDef);
        this.StoreFrameStashSearch(this.searchText);

    end,

    --背包搜索结果使用道具上报
    UseSearchBackpackStat = function()
        local this = SearchMgr;
        if this.isUseSearchBackpack == true then return end

        if getglobal("CreateBackpackFrameSearchContent"):IsShown() then
            --print("背包道具使用")
            this.isUseSearchBackpack =true;
            -- statisticsGameEvent(61032, "%d",1) --搜索结果没有点击的上报
        end

    end,

    --仓库搜索结果使用道具上报
    UseSearchStashStat = function()
        local this = SearchMgr;
        if this.isUseSearchStash == true then return end

        if getglobal("StoreFrameStashSearchContent"):IsShown() then
            --print("仓库道具使用")
            this.isUseSearchStash = true;
            -- statisticsGameEvent(61032, "%d",2) --搜索结果没有点击的上报
        end

    end,

    GetSearchNum = function()
        return BackPackView.datasize
    end
}

function searchMgrBackpackInit()
    SearchMgr.CloseCreateBackPack();
    SearchMgr.Init();
end

function searchMgrStashInit()
    SearchMgr.CloseStoreFrameStashSearch();
    SearchMgr.Init();
    StashView.Show();
end

------------------------------------界面回调-----------------------------------------------------
function CreateBackpackFrameSearchEdit_OnFocusLost()
    BackPackView:searchFocusLost();
end

function CreateBackpackFrameSearchEdit_OnFocusGained()
    if BackPackData.NeedLoadDef() then
        threadpool:work(BackPackData.load)
    end
end

function CreateBackpackFrameSearchEdit_OnEnterPressed()
    BackPackView:searchEnterPressed();
end

function CreateBackpackFrameSearchBtn_OnClick()
    BackPackView:searchEnterPressed();
    local text = getglobal("CreateBackpackFrameSearchEdit"):GetText();
    if AccountManager and AccountManager:getCurWorldDesc() then
        --地图类型（冒险0 创造1 极限冒险2 创造转生存3 编辑4 编辑转玩法5 高级冒险6）
        local mapType = AccountManager:getCurWorldDesc().worldtype or 0
        -- statisticsGameEventNew(31036,text,mapType)
    end
end

function CreateBackpackFrameSearch_OnShow()
    print("CreateBackpackFrameSearch_OnShow()")
    BackPackView.Show();
end

function CreateBackpackFrameSearch_OnLoad()
    this:RegisterEvent("GIE_ENTER_WORLD");
    this:RegisterEvent("GIE_LEAVE_WORLD");
end

function CreateBackpackFrameSearch_OnEvent()
    local ge = GameEventQue:getCurEvent();
    if arg1 == "GIE_ENTER_WORLD" then
        BackPackData.reset();
        getglobal("CreateBackpackFrameSearchEdit"):Clear();
    elseif arg1 == "GIE_LEAVE_WORLD" then
        print("CreateBackpackFrameSearch_OnEvent()")
       threadpool:work( BackPackData.save);
    end
end

--------------------------------------------------------------------
function StoreFrameStashSearchEdit_OnFocusLost()
    StashView.searchFocusLost();
end

function StoreFrameStashSearchEdit_OnEnterPressed()
    StashView.searchEnterPressed();
end

function StoreFrameStashSearchEdit_OnFocusGained()
    if StashData.NeedLoadDef() then
        StashData.loadFromDef();
    end
end

function StoreFrameStashSearchBtn_OnClick()
    StashView.searchEnterPressed();
end

function StoreFrameStashSearch_OnShow()
    StashView.Show();
end

function StoreFrameStashSearchContentCloseBtn_OnClick()
    StashView.closeSearchPanel(true);
end