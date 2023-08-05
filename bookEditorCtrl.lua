--编书页面控制器
BookEditorCtrl = {} 
BookEditorCtrl.Def = {}
BookEditorCtrl.Data = {}

--初始化编书页面的定义
BookEditorCtrl.InitDef = function()
	--书本配置ID
	BookEditorCtrl.Def.bookId = 11803
	--被写过的信纸配置ID，只用来做显示用
	BookEditorCtrl.Def.writedLetterId = 11804
	--信纸配置ID
	BookEditorCtrl.Def.letterId = 11806
	--最小可合成书本的信纸数
	BookEditorCtrl.Def.minEditLetterCount = 2
	--编书台容器的容量
	BookEditorCtrl.Def.gridMaxCount = 26
	BookEditorCtrl.Def.gridLetterStartIndex1 = 1
	BookEditorCtrl.Def.gridBookStartIndex1 = 13
	BookEditorCtrl.Def.gridLetterStartIndex2 = 14
	BookEditorCtrl.Def.gridBookStartIndex2 = 26
	--左边页签操作类型
	BookEditorCtrl.Def.handleType = 
	{
		edit = 1,
		split = 2,
	}
	--物品操作类型
	BookEditorCtrl.Def.handleItemType = 
	{
		click = 1,
		mouseEnter = 2,
		mouseLeave = 3,
	}
	--编辑框操作OBJ
	BookEditorCtrl.Def.handleEditBoxObj = 
	{
		name = 1,
		editor = 2,
		detail = 3,
	}
	--编辑框操作类型
	BookEditorCtrl.Def.handleEditBoxType = 
	{
		focusGained = 1,
		focusLost = 2,
		textSet = 3,
	}
	--定义物品的行列数
	BookEditorCtrl.Def.leftItemRow = 6
	BookEditorCtrl.Def.leftItemCol = 6
	BookEditorCtrl.Def.rightItemRow = 2
	BookEditorCtrl.Def.rightItemCol = 6
	--字段配置表
	BookEditorCtrl.Def.bookDefaultText = GetS(10646)
	BookEditorCtrl.Def.bookDefaultText2 = GetS(6984)
	BookEditorCtrl.Def.tips1 = GetS(7000)
	BookEditorCtrl.Def.tips2 = GetS(6997)
	BookEditorCtrl.Def.tips3 = GetS(6999)
	BookEditorCtrl.Def.tips4 = GetS(6998)
	BookEditorCtrl.Def.tips5 = GetS(6996)
	BookEditorCtrl.Def.tips6 = GetS(6995)
	BookEditorCtrl.Def.tips7 = GetS(21684)
	BookEditorCtrl.Def.tips8 = GetS(21685)
	BookEditorCtrl.Def.tips9 = GetS(6994)
	BookEditorCtrl.Def.tips10 = GetS(6993)
	BookEditorCtrl.Def.tips11 = GetS(21694)
	BookEditorCtrl.Def.tips12 = GetS(21695)
end 

--初始化编书页面的事件监听
BookEditorCtrl.InitListener = function() 
	this:RegisterEvent("GIE_LEAVE_WORLD")
	this:RegisterEvent("GE_BACKPACK_CHANGE")
	this:RegisterEvent("GE_BACKPACK_CHANGE_EDIT")
	BookEditorCtrl.AddGameEvent()
end
BookEditorCtrl.AddGameEvent = function()
    SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
        local paramData = context:GetParamData()
        local gridIndex = paramData.gridIndex
        if BookEditorFrame.frame and BookEditorFrame.frame:IsShown() and BookEditorCtrl.Data.isCreateData then
            --背包数据变更
            local index = 0

            if not ClientBackpack:isHomeLandGameMakerMode() and gridIndex >= BACKPACK_START_INDEX and gridIndex < SHORTCUT_START_INDEX + 1000 then
                --是背包和快捷栏数据
                BookEditorCtrl.UpdateItem(gridIndex,true)
            elseif ClientBackpack:isHomeLandGameMakerMode() and ((gridIndex >= BACKPACK_START_INDEX and gridIndex < SHORTCUT_START_INDEX) or (gridIndex >= SHORTCUTEX_START_INDEX and gridIndex < SHORTCUTEX_START_INDEX + 1000)) then
                --是背包和快捷栏数据
                BookEditorCtrl.UpdateItem(gridIndex,true)
            elseif gridIndex >= EDITBOOK_START_INDEX and gridIndex < EDITBOOK_START_INDEX + 1000 then
                --是编书台容器数据
                BookEditorCtrl.UpdateItem(gridIndex,false)
            end
        end
    end)
end
--加载
BookEditorCtrl.Load = function() 
	BookEditorCtrl.InitListener()
end 

--编书页面打开，激活编书页面控制器，触发页面显示时的逻辑
BookEditorCtrl.Active = function()
	--操作UI指针打开
	if ClientCurGame then
		ClientCurGame:setOperateUI(true)
	end 
	--初始化或更新数据
	if not BookEditorCtrl.Data.isCreateData then 
		BookEditorCtrl.InitDef()
		BookEditorFrame.Init()
		BookEditorCtrl.InitData(true)
	else
		BookEditorCtrl.InitData(false)
	end 
	--选择编书页签
	BookEditorCtrl.SelectHandleType(BookEditorCtrl.Def.handleType.edit)
end 

--编书页面关闭，反激活编书页面控制器，处理页面关闭时的逻辑
BookEditorCtrl.AntiActive = function() 
	--操作UI指针关闭
	if ClientCurGame then
		ClientCurGame:setOperateUI(false)
	end 
	--当前操作类型
	BookEditorCtrl.Data.curHandleType = 0
	--关闭TIPS
	BookEditorCtrl.HideItemTips()
	--关闭页面 
	BookEditorFrame.Close()
end 

--处理事件
BookEditorCtrl.HandleEvent = function(eventName,data)
	if eventName == "GIE_LEAVE_WORLD" then 
		--离开世界
		BookEditorCtrl.Data.isCreateData = false
		--当前操作类型
		BookEditorCtrl.Data.curHandleType = 0
		--关闭页面 
		if BookEditorFrame and BookEditorFrame.frame then
			BookEditorFrame.frame:Hide()
		end 
	elseif eventName == "GE_BACKPACK_CHANGE" then
		if BookEditorFrame.frame and BookEditorFrame.frame:IsShown() and BookEditorCtrl.Data.isCreateData then
			--背包数据变更
			local gridIndex = data.body.backpack.grid_index
            local index = 0
            
			local shortcutStartIdx = ClientBackpack:getShortcutStartIndex()
            if (gridIndex >= BACKPACK_START_INDEX and gridIndex < SHORTCUT_START_INDEX) or (gridIndex >= shortcutStartIdx and gridIndex < shortcutStartIdx + 1000) then
				--是背包和快捷栏数据
                BookEditorCtrl.UpdateItem(gridIndex,true)
			elseif gridIndex >= EDITBOOK_START_INDEX and gridIndex < EDITBOOK_START_INDEX + 1000 then
				--是编书台容器数据
				BookEditorCtrl.UpdateItem(gridIndex,false)
            end 
		end 
	elseif eventName == "GE_BACKPACK_CHANGE_EDIT" then
		if BookEditorFrame.frame and BookEditorFrame.frame:IsShown() and BookEditorCtrl.Data.isCreateData then
			--背包数据变更
			local gridIndex = data.body.backpack.grid_index
            local index = 0
            
			local shortcutStartIdx = ClientBackpack:getShortcutStartIndex()
            if (gridIndex >= shortcutStartIdx and gridIndex < shortcutStartIdx + 1000) then
				--是背包和快捷栏数据
                BookEditorCtrl.UpdateItem(gridIndex,true)
            end 
		end
	end 
end  

--选择页签
BookEditorCtrl.SelectHandleType = function(handleType)
	if handleType ~= BookEditorCtrl.Data.curHandleType then 
		BookEditorCtrl.Data.curHandleType = handleType 
		BookEditorCtrl.CheckBookInfoEditState() 
		BookEditorFrame.UpdateHandleType(BookEditorCtrl.Data.curHandleType)
		BookEditorFrame.UpdateLeftPanel(BookEditorCtrl.Data.curHandleType,BookEditorCtrl.Data)
		BookEditorFrame.UpdateRightPanel(BookEditorCtrl.Data.curHandleType,BookEditorCtrl.Data)
	end 
end

--检查书籍信息当前是否可以被编辑
BookEditorCtrl.CheckBookInfoEditState = function()
	if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then
		-- if #BookEditorCtrl.Data.editData.rightLetterGrids >= BookEditorCtrl.Def.minEditLetterCount then 
		-- 	BookEditorCtrl.Data.isEditable = true
		-- else
		-- 	BookEditorCtrl.Data.isEditable = true
		-- end 
		--需求变更，不再做限制
		BookEditorCtrl.Data.isEditable = true
	else 
		BookEditorCtrl.Data.isEditable = false 
	end  
end 

--整理物品
BookEditorCtrl.SortItem = function() 
	--排序 1.快捷栏->背包 2.索引ID小->大
	local sortFuc = function(aItem,bItem) 
		local aWeight = 0 
		local bWeight = 0 
		if aItem:getIndex() < ClientBackpack:getShortcutStartIndex() then 
			aWeight = aWeight + ClientBackpack:getShortcutStartIndex()
		end 
		if bItem:getIndex() < ClientBackpack:getShortcutStartIndex() then 
			bWeight = bWeight + ClientBackpack:getShortcutStartIndex()
		end 
		aWeight = aWeight + aItem:getIndex() % ClientBackpack:getShortcutStartIndex() 
		bWeight = bWeight + bItem:getIndex() % ClientBackpack:getShortcutStartIndex() 
		if aWeight < bWeight then 
			return true 
		else
			return false 
		end 
	end 
	local sortGrids = nil 
	if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then 
		sortGrids = BookEditorCtrl.Data.editData.leftLetterGrids
	else
		sortGrids = BookEditorCtrl.Data.splitData.leftBookGrids
	end 
	table.sort(sortGrids,sortFuc)

	BookEditorFrame.UpdateLeftPanel(BookEditorCtrl.Data.curHandleType,BookEditorCtrl.Data)
end

--操作物品
BookEditorCtrl.HandleItem = function(handleType,obj)
	local index = obj:GetParentFrame():GetClientID()
	local name1 = obj:GetParentFrame():GetName()
	local name = getglobal(name1 .. "Name"):GetText()
	local base = math.floor(index / 100) 
	local mor = index % 100 
	if handleType == BookEditorCtrl.Def.handleItemType.click then 
		--点击
		if not ClientMgr:isPC() then
			BookEditorCtrl.ShowItemTips(name1,mor,base,name)
		end
		if base == 1 then 
			--是左边的物品
			BookEditorCtrl.AddItemToContainer(mor)
		elseif base == 2 then 
			--编书状态下右边的物品
			BookEditorCtrl.RemoveItemFromContainer(mor)
		elseif base == 3 then 
			--拆书状态下右边的物品
			BookEditorCtrl.RemoveItemFromContainer(mor)
		end  
	elseif handleType == BookEditorCtrl.Def.handleItemType.mouseEnter then 
		--鼠标移动到区域内
		BookEditorCtrl.ShowItemTips(name1,mor,base,name) 
	elseif handleType == BookEditorCtrl.Def.handleItemType.mouseLeave then 
		--鼠标移动到区域外
		BookEditorCtrl.HideItemTips()
	end 
end

--更新单个物品
BookEditorCtrl.UpdateItem = function(gridIndex,isLeft)
	-- local itemIndex = 0
	-- local grid = ClientBackpack:index2Grid(gridIndex)
	-- if isLeft then 
	-- 	itemIndex = 0
	-- 	if gridIndex >= ClientBackpack:getShortcutStartIndex() then 
	-- 		itemIndex = gridIndex - ClientBackpack:getShortcutStartIndex() + 1
	-- 	else
	-- 		local shortcutCount = 0
	-- 		for i = 1,MAX_SHORTCUT do 
	-- 			local index = i - 1 + ClientBackpack:getShortcutStartIndex() 
	-- 			local aGrid = ClientBackpack:index2Grid(index)
	-- 			if aGrid:getItemID() == grid:getItemID() then
	-- 				if grid:getItemID() == BookEditorCtrl.Def.letterId then 
	-- 					if BookEditorCtrl.IsWritedLetter(index) then 
	-- 						shortcutCount = shortcutCount + 1
	-- 					end
	-- 				else 
	-- 					shortcutCount = shortcutCount + 1
	-- 				end  
	-- 			end 
	-- 		end 
	-- 		itemIndex = gridIndex + shortcutCount + 1 
	-- 	end  
	-- else
	-- 	itemIndex = gridIndex - EDITBOOK_START_INDEX + 1
	-- end 
	-- BookEditorFrame.UpdateSingleItem(gridIndex,isLeft,itemIndex)
	if BookEditorCtrl.Data.resetCountMax > 0 then 
		BookEditorCtrl.Data.resetCount = BookEditorCtrl.Data.resetCount + 1
		if BookEditorCtrl.Data.resetCount >= BookEditorCtrl.Data.resetCountMax then
			BookEditorCtrl.UpdateGridData(BookEditorCtrl.Def.handleType.edit)
			BookEditorCtrl.UpdateGridData(BookEditorCtrl.Def.handleType.split)
			BookEditorCtrl.CheckBookInfoEditState()
			BookEditorFrame.UpdateLeftPanel(BookEditorCtrl.Data.curHandleType,BookEditorCtrl.Data)
			BookEditorFrame.UpdateRightPanel(BookEditorCtrl.Data.curHandleType,BookEditorCtrl.Data)
			BookEditorCtrl.Data.resetCountMax = 0 
			BookEditorCtrl.Data.resetCount = 0
		end
	else
		BookEditorCtrl.UpdateGridData(BookEditorCtrl.Def.handleType.edit)
		BookEditorCtrl.UpdateGridData(BookEditorCtrl.Def.handleType.split)
		BookEditorCtrl.CheckBookInfoEditState()
		BookEditorFrame.UpdateLeftPanel(BookEditorCtrl.Data.curHandleType,BookEditorCtrl.Data)
		BookEditorFrame.UpdateRightPanel(BookEditorCtrl.Data.curHandleType,BookEditorCtrl.Data) 
	end  
end

--操作编辑框
BookEditorCtrl.HandleEditBox = function(handleType,index)
	if handleType == BookEditorCtrl.Def.handleEditBoxType.focusGained then 
	elseif handleType == BookEditorCtrl.Def.handleEditBoxType.focusLost then
		if not BookEditorCtrl.IsFilterString(index) then 
			if index == BookEditorCtrl.Def.handleEditBoxObj.name then 
				BookEditorCtrl.SetBookName()
			elseif index == BookEditorCtrl.Def.handleEditBoxObj.editor then 
				BookEditorCtrl.SetBookEditor()
			elseif index == BookEditorCtrl.Def.handleEditBoxObj.detail then 
				BookEditorCtrl.SetBookDetail()
			end
		end 
	elseif handleType == BookEditorCtrl.Def.handleEditBoxType.textSet then 
		if index == BookEditorCtrl.Def.handleEditBoxObj.detail then 
			if BookEditorFrame.GetBookDetailText() ~= "" then
				BookEditorFrame.DeleteDefaultBookDetailText()
			else
				BookEditorFrame.SetDefaultBookDetailText()
			end 
		end 
	end 
end 

--初始化编书页面的数据
BookEditorCtrl.InitData = function(isInitBookData)
	--当前操作类型
	BookEditorCtrl.Data.curHandleType = 0
	--书籍信息是否可编辑
	BookEditorCtrl.Data.isEditable = false  
	--重置个数
	BookEditorCtrl.Data.resetCountMax = 0
	BookEditorCtrl.Data.resetCount = 0

	--编书数据
	if isInitBookData then
		BookEditorCtrl.Data.editData = {}
	end 
	--当前书本
	if isInitBookData then 
		BookEditorCtrl.Data.editData.bookName = GetS(6984,AccountManager:getNickName())
		BookEditorCtrl.Data.editData.multiLangName = ""
		BookEditorCtrl.Data.editData.editorName = AccountManager:getNickName()
		BookEditorCtrl.Data.editData.multiLangEditor = ""
		BookEditorCtrl.Data.editData.details = ""
		BookEditorCtrl.Data.editData.multiLangDetails = ""
	end
	--格子数据
	BookEditorCtrl.UpdateGridData(BookEditorCtrl.Def.handleType.edit)

	--拆书数据
	if isInitBookData then 
		BookEditorCtrl.Data.splitData = {}
	end 
	--当前书本
	if isInitBookData then   
		BookEditorCtrl.Data.splitData.bookName = ""
		BookEditorCtrl.Data.editData.multiLangName = ""
		BookEditorCtrl.Data.splitData.editorName = ""
		BookEditorCtrl.Data.editData.multiLangEditor = ""
		BookEditorCtrl.Data.splitData.details = ""
		BookEditorCtrl.Data.editData.multiLangDetails = ""
	end
	--格子数据
	BookEditorCtrl.UpdateGridData(BookEditorCtrl.Def.handleType.split)

	--数据初始化完成
	BookEditorCtrl.Data.isCreateData = true 
end 

--更新物品格子数据
BookEditorCtrl.UpdateGridData = function(handleType)
	if handleType == BookEditorCtrl.Def.handleType.edit then 
		--左边信件（快捷栏容器+背包容器）
		BookEditorCtrl.Data.editData.leftLetterGrids = {}
		local maxCount = ClientBackpack:getShortcutGridCount()
		for i = 1,maxCount do 
			local index = i - 1 + ClientBackpack:getShortcutStartIndex() 
			local grid = ClientBackpack:index2Grid(index)
			local itemId = grid:getItemID()
			if itemId == BookEditorCtrl.Def.letterId and BookEditorCtrl.IsWritedLetter(index) then 
				table.insert(BookEditorCtrl.Data.editData.leftLetterGrids,grid)
			end 
		end 
		for i = 1,BACK_PACK_GRID_MAX do
			local index = i - 1 + BACKPACK_START_INDEX 
			local grid = ClientBackpack:index2Grid(index)
			local itemId = grid:getItemID()
			if itemId == BookEditorCtrl.Def.letterId and BookEditorCtrl.IsWritedLetter(index) then 
				table.insert(BookEditorCtrl.Data.editData.leftLetterGrids,grid)
			end 
		end
		--右边信件（编书台容器1）
		BookEditorCtrl.Data.editData.rightLetterGrids = {}
		for i = 1,BookEditorCtrl.Def.gridMaxCount do
			if i >= BookEditorCtrl.Def.gridLetterStartIndex1 and i < BookEditorCtrl.Def.gridBookStartIndex1 then
				local index = i - 1 + EDITBOOK_START_INDEX 
				local grid = ClientBackpack:index2Grid(index)
				local itemId = grid:getItemID()
				if itemId == BookEditorCtrl.Def.letterId then
					table.insert(BookEditorCtrl.Data.editData.rightLetterGrids,grid)
				end 
			end  
		end
		local bookIndex1 = BookEditorCtrl.Def.gridBookStartIndex1 - 1 + EDITBOOK_START_INDEX
		local grid1 = ClientBackpack:index2Grid(bookIndex1)
		local itemId = grid1:getItemID()
		if itemId == BookEditorCtrl.Def.bookId then
			BookEditorCtrl.Data.editData.bookGrid = grid1 
			-- BookEditorCtrl.ResetBookShow(BookEditorCtrl.Def.handleType.edit)
		elseif itemId == 0 then
			BookEditorCtrl.Data.editData.bookGrid = nil 
			-- BookEditorCtrl.ClearBookShow(handleType)
		end  
	else
		--左边书本（快捷栏容器+背包容器）
		local maxCount = ClientBackpack:getShortcutGridCount()
		BookEditorCtrl.Data.splitData.leftBookGrids = {}
		for i = 1,maxCount do 
			local index = i - 1 + ClientBackpack:getShortcutStartIndex() 
			local grid = ClientBackpack:index2Grid(index)
			local itemId = grid:getItemID()
			if itemId == BookEditorCtrl.Def.bookId then 
				table.insert(BookEditorCtrl.Data.splitData.leftBookGrids,grid)
			end 
		end
		for i = 1,BACK_PACK_GRID_MAX do
			local index = i - 1 + BACKPACK_START_INDEX 
			local grid = ClientBackpack:index2Grid(index)
			local itemId = grid:getItemID()
			if itemId == BookEditorCtrl.Def.bookId then 
				table.insert(BookEditorCtrl.Data.splitData.leftBookGrids,grid)
			end 
		end
		--右边信件（编书台容器2）
		BookEditorCtrl.Data.splitData.rightLetterGrids = {}
		for i = 1,BookEditorCtrl.Def.gridMaxCount do
			if i >= BookEditorCtrl.Def.gridLetterStartIndex2 and i < BookEditorCtrl.Def.gridBookStartIndex2 then
				local index = i - 1 + EDITBOOK_START_INDEX 
				local grid = ClientBackpack:index2Grid(index)
				local itemId = grid:getItemID()
				if itemId == BookEditorCtrl.Def.letterId then
					table.insert(BookEditorCtrl.Data.splitData.rightLetterGrids,grid)
				end 
			end  
		end
		local bookIndex2 = BookEditorCtrl.Def.gridBookStartIndex2 - 1 + EDITBOOK_START_INDEX
		local grid2 = ClientBackpack:index2Grid(bookIndex2)
		local itemId = grid2:getItemID()
		if itemId == BookEditorCtrl.Def.bookId then
			BookEditorCtrl.Data.splitData.bookGrid = grid2 
			BookEditorCtrl.ResetBookShow(BookEditorCtrl.Def.handleType.split)
		elseif itemId == 0 then
			BookEditorCtrl.Data.splitData.bookGrid = nil 
			BookEditorCtrl.ClearBookShow(handleType) 
		end 
	end 
end 

--更新编书页面的数据
BookEditorCtrl.UpdateData = function() 
	--剔除不存在的左边信件，左边书本（被使用掉了，被丢弃了）
	local newLeftLetterGrids = {}
	local newLeftBookGrids = {}
	for i = 1,#BookEditorCtrl.Data.editData.leftLetterGrids do
		local grid = BookEditorCtrl.Data.editData.leftLetterGrids[i]
		if grid and grid:getItemID() == BookEditorCtrl.Def.letterId then
			table.insert(newLeftLetterGrids,grid)
		end 
	end 
	for i = 1,#BookEditorCtrl.Data.splitData.leftBookGrids do
		local grid = BookEditorCtrl.Data.splitData.leftBookGrids[i]
		if grid and grid:getItemID() == BookEditorCtrl.Def.bookId then
			table.insert(newLeftBookGrids,grid)
		end 
	end 
	BookEditorCtrl.Data.editData.leftLetterGrids = newLeftLetterGrids
	BookEditorCtrl.Data.splitData.leftBookGrids = newLeftBookGrids
	--新增左边信件，左边书本
	local maxCount = ClientBackpack:getShortcutGridCount()
	for i = 1,maxCount do 
		local index = i - 1 + ClientBackpack:getShortcutStartIndex() 
		local grid = ClientBackpack:index2Grid(index)
		local itemId = grid:getItemID()
		if itemId == BookEditorCtrl.Def.letterId and BookEditorCtrl.IsWritedLetter(index) and BookEditorCtrl.IsNewLetter(grid:getIndex()) then
			table.insert(BookEditorCtrl.Data.editData.leftLetterGrids,grid)
		elseif itemId == BookEditorCtrl.Def.bookId and BookEditorCtrl.IsNewBook(grid:getIndex()) then
			 table.insert(BookEditorCtrl.Data.splitData.leftBookGrids,grid)
		end 
	end 
	for i = 1,BACK_PACK_GRID_MAX do
		local index = i - 1 + BACKPACK_START_INDEX 
		local grid = ClientBackpack:index2Grid(index)
		local itemId = grid:getItemID()
		if itemId == BookEditorCtrl.Def.letterId and BookEditorCtrl.IsWritedLetter(index) and BookEditorCtrl.IsNewLetter(grid:getIndex()) then
			table.insert(BookEditorCtrl.Data.editData.leftLetterGrids,grid)
		elseif itemId == BookEditorCtrl.Def.bookId and BookEditorCtrl.IsNewBook(grid:getIndex()) then
			 table.insert(BookEditorCtrl.Data.splitData.leftBookGrids,grid)
		end
	end 
end 

--显示物品TIPS
BookEditorCtrl.ShowItemTips = function(itemName,itemIndex,itemBase,textName)
	local gridIndex = 0 
	local itemId = 0
	if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then 
		if itemBase == 1 then
			gridIndex = BookEditorCtrl.Data.editData.leftLetterGrids[itemIndex]:getIndex()
			itemId = BookEditorCtrl.Def.letterId
		else
			if itemIndex == BookEditorCtrl.Def.gridBookStartIndex1 then
				gridIndex = BookEditorCtrl.Data.editData.bookGrid:getIndex()
				itemId = BookEditorCtrl.Def.bookId
			else
				gridIndex = BookEditorCtrl.Data.editData.rightLetterGrids[itemIndex]:getIndex()
				itemId = BookEditorCtrl.Def.letterId
			end 
		end  
	else
		if itemBase == 1 then
			gridIndex = BookEditorCtrl.Data.splitData.leftBookGrids[itemIndex]:getIndex()
			itemId = BookEditorCtrl.Def.bookId
		else
			if itemIndex == BookEditorCtrl.Def.gridBookStartIndex1 then
				gridIndex = BookEditorCtrl.Data.splitData.bookGrid:getIndex()
				itemId = BookEditorCtrl.Def.bookId
			else
				gridIndex = BookEditorCtrl.Data.splitData.rightLetterGrids[itemIndex]:getIndex()
				itemId = BookEditorCtrl.Def.letterId
			end
		end 
	end 
	if not ClientMgr:isPC() then
		UpdateTipsFrame(textName, 1, itemId, gridIndex)
	else
		SetMTipsInfo(gridIndex,itemName,true,itemId)
	end 
end 

--隱藏物品TIPS
BookEditorCtrl.HideItemTips = function()
	HideMTipsInfo()
end 

--是否为敏感字
BookEditorCtrl.IsFilterString = function(index)
	local text = ""
	if index == BookEditorCtrl.Def.handleEditBoxObj.name then 
		text = BookEditorFrame.GetBookNameText()
		if CheckFilterString(text) then	
	 		--BookEditorFrame.SetDefaultBookNameText()
	 		BookEditorCtrl.SetBookName()
	 		return true
	 	end
	elseif index == BookEditorCtrl.Def.handleEditBoxObj.editor then 
		text = BookEditorFrame.GetBookEditorText()
		if CheckFilterString(text) then	
	 		--BookEditorFrame.SetDefaultBookEditorText()
	 		BookEditorCtrl.SetBookEditor()
	 		return true
	 	end
	elseif index == BookEditorCtrl.Def.handleEditBoxObj.detail then 
		text = BookEditorFrame.GetBookDetailText()
		if CheckFilterString(text) then
	 		--BookEditorFrame.SetDefaultBookDetailText(true)
	 		BookEditorCtrl.SetBookDetail()
	 		return true
	 	end
	end
	return false
end 

--是否为书写过的信件
BookEditorCtrl.IsWritedLetter = function(index)
	local letterData = ClientBackpack:getGridUserdataStr(index)
	if letterData == nil or string.len(letterData) == 0 then 
		return false 
	end 
	local uin,authorname,title,context = LettersParse(letterData)
	if title == "" and context == "" then
		return false 
	end 
    return true 
end  

--是否为新信件
BookEditorCtrl.IsNewLetter = function(index) 
	local isNew = true 
	for i = 1,#BookEditorCtrl.Data.editData.leftLetterGrids do 
		local aLetterGrid = BookEditorCtrl.Data.editData.leftLetterGrids[i]
		if aLetterGrid:getIndex() == index then 
			isNew = false 
			break 
		end 
	end 
	return isNew
end 

--是否为新书本
BookEditorCtrl.IsNewBook = function(index) 
	local isNew = true 
	for i = 1,#BookEditorCtrl.Data.splitData.leftBookGrids do 
		local aLetterGrid = BookEditorCtrl.Data.splitData.leftBookGrids[i]
		if aLetterGrid:getIndex() == index then 
			isNew = false 
			break 
		end 
	end 
	return isNew
end 

--书本数据组装
BookEditorCtrl.OrganizeBookData = function(grids) 
	local bookData = {}
	bookData.uin = CurMainPlayer:getUin()
	bookData.authorname = BookEditorCtrl.Data.editData.editorName
	bookData.title = BookEditorCtrl.Data.editData.bookName
	bookData.context = BookEditorCtrl.Data.editData.details
	bookData.multiLangName = BookEditorCtrl.Data.multiLangName
	bookData.multiLangEditor = BookEditorCtrl.Data.multiLangEditor
	bookData.multiLangDetails = BookEditorCtrl.Data.multiLangDetails
	bookData.letters = {}
	local rightGrids = grids or BookEditorCtrl.Data.editData.rightLetterGrids
	for i = 1,#rightGrids do 
		local aGridData = rightGrids[i]:getUserdataStr()
		local aLetter = {}
		aLetter.uin,aLetter.authorname,aLetter.title,aLetter.context,aLetter.ntype,_,aLetter.changetime,aLetter.oldtitle,aLetter.oldcontext,aLetter.key = LettersParse(aGridData)
		
		--信纸多语言翻译内容 也需要保存
		local t = JSON:decode(aGridData);
    	if t and type(t) == "table" and t.ntype and 1 == t.ntype then
			aLetter.titleMul = JSON:decode(t.title)
			aLetter.contextMul = JSON:decode(t.context)
    	end

		table.insert(bookData.letters,aLetter)
	end 
	bookData = JSON:encode(bookData)
	return bookData
end 

--书本数据解析
BookEditorCtrl.ParseBookData = function(grid)
	local bookData = JSON:decode(grid:getUserdataStr())
	return bookData
end 

--把信件组装成书本
BookEditorCtrl.EditLettersToBook = function()
	-- statisticsUIInGame(61012,EnterRoomType)
	if BookEditorCtrl.CanEditLettersToBook() then 
		--组装数据
		local bookId = BookEditorCtrl.Def.bookId 
		local bookData = BookEditorCtrl.OrganizeBookData()
		--背包数据变更
		CurMainPlayer:setItemWithoutLimit(bookId,EDITBOOK_START_INDEX + 12,1,bookData)
		for i = 1,#BookEditorCtrl.Data.editData.rightLetterGrids do 
			local aGrid = BookEditorCtrl.Data.editData.rightLetterGrids[i]
			CurMainPlayer:setItemWithoutLimit(0,aGrid:getIndex(),0,"")
		end 
		BookEditorCtrl.ClearBookShow(BookEditorCtrl.Def.handleType.edit)
		ShowGameTips(BookEditorCtrl.Def.tips11,3)
		-- statisticsUIInGame(61013,EnterRoomType)
	end 
end 

--信件組裝成书本的条件检测
BookEditorCtrl.CanEditLettersToBook = function() 
	local rightGrids = BookEditorCtrl.Data.editData.rightLetterGrids
	--放入合成界面的信纸不可少于两张
	if #rightGrids < BookEditorCtrl.Def.minEditLetterCount then 
		ShowGameTips(BookEditorCtrl.Def.tips1,3)
		return false 
	end 
	--书名和编者名不能为空
	if BookEditorCtrl.Data.editData.bookName == "" and BookEditorCtrl.Data.editData.editorName == "" then 
		ShowGameTips(BookEditorCtrl.Def.tips2,3)
		return false 
	end 
	if BookEditorCtrl.Data.editData.bookName == "" and BookEditorCtrl.Data.editData.editorName ~= "" then 
		ShowGameTips(BookEditorCtrl.Def.tips3,3)
		return false 
	end 
	if BookEditorCtrl.Data.editData.bookName ~= "" and BookEditorCtrl.Data.editData.editorName == "" then 
		ShowGameTips(BookEditorCtrl.Def.tips4,3)
		return false
	end 
	--书籍合成完成框被其他书籍占用
	if BookEditorCtrl.Data.editData.bookGrid then 
		ShowGameTips(BookEditorCtrl.Def.tips5,3)
		return false
	end 
	--书籍信息填写有敏感字
	if BookEditorCtrl.IsFilterString(BookEditorCtrl.Def.handleEditBoxObj.name) 
	or BookEditorCtrl.IsFilterString(BookEditorCtrl.Def.handleEditBoxObj.editor)
	or BookEditorCtrl.IsFilterString(BookEditorCtrl.Def.handleEditBoxObj.detail) then 
		ShowGameTips(GetS(121),3)
		return false 
	end 
	return true
end 

--把书本拆分成信件
BookEditorCtrl.SplitBookToLetters = function() 
	if BookEditorCtrl.CanSplitBookToLetters() then 
		--背包数据变更
		local bookGrid = BookEditorCtrl.Data.splitData.bookGrid
		local bookData = BookEditorCtrl.ParseBookData(bookGrid)
		local letterId = BookEditorCtrl.Def.letterId 
		if bookData then
			local letterCount = #bookData.letters
			local lettersData = bookData.letters
			local findIndex = BookEditorCtrl.Def.gridLetterStartIndex2
			for i = 1,letterCount do 
				local gridIndex = BookEditorCtrl.FindEmptyGridIndexInRight(findIndex,BookEditorCtrl.Def.gridBookStartIndex2 - 1)
				local temp = lettersData[i]
				if temp.titleMul then
					temp.title = JSON:encode(temp.titleMul)
					temp.titleMul = nil
					temp.ntyp = 1
				end

				if temp.contextMul then
					temp.context = JSON:encode(temp.contextMul)
					temp.contextMul = nil
					temp.ntyp = 1
				end
				print("BookEditorCtrl.SplitBookToLetters", temp)
				CurMainPlayer:setItemWithoutLimit(letterId,gridIndex,1,JSON:encode(temp))
				findIndex = gridIndex - EDITBOOK_START_INDEX + 2
			end 
			CurMainPlayer:setItemWithoutLimit(0,EDITBOOK_START_INDEX + 25,0,"")
			-- 创造模式拆书，才清掉审核文本
			if bookData and bookData.key then
				CurMainPlayer:removeWorldStringByKey(bookData.key, BOOK)
			end
			ShowGameTips(BookEditorCtrl.Def.tips12,3)
			-- statisticsUIInGame(61014,EnterRoomType)
		end				
	end 
end 

--书本拆分成信件的条件检测
BookEditorCtrl.CanSplitBookToLetters = function() 
	local bookGrid = BookEditorCtrl.Data.splitData.bookGrid
	if bookGrid == nil then 
		ShowGameTips(BookEditorCtrl.Def.tips9,3)
		return false 
	end 

	local bookData = BookEditorCtrl.ParseBookData(bookGrid)
	if bookData and #bookData.letters > BookEditorCtrl.GetEmptyGridCountInRight(BookEditorCtrl.Def.gridLetterStartIndex2,
	BookEditorCtrl.Def.gridBookStartIndex2 - 1) then 
		ShowGameTips(BookEditorCtrl.Def.tips10,3)
		return false 
	end 
	return true 
end 

--设置当前书本信息
BookEditorCtrl.SetBookName = function() 
	local bookName = BookEditorFrame.GetBookNameText()
	if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then 
		BookEditorCtrl.Data.editData.bookName = bookName
	else
		BookEditorCtrl.Data.splitData.bookName = bookName
	end 
end 

BookEditorCtrl.SetBookEditor = function() 
	local bookEditor = BookEditorFrame.GetBookEditorText()
	if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then 
		BookEditorCtrl.Data.editData.editorName = bookEditor
	else
		BookEditorCtrl.Data.splitData.editorName = bookEditor
	end 
end

BookEditorCtrl.SetBookDetail = function() 
	local bookDetail = BookEditorFrame.GetBookDetailText()
	if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then 
		BookEditorCtrl.Data.editData.details = bookDetail
	else
		BookEditorCtrl.Data.splitData.details = bookDetail
	end 
end

--向编书台容器内添加物品
BookEditorCtrl.AddItemToContainer = function(itemIndex)
	local grid = nil 
	if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then
		local leftGrids = BookEditorCtrl.Data.editData.leftLetterGrids
		local rightGrids = BookEditorCtrl.Data.editData.rightLetterGrids
		local errorTips = BookEditorCtrl.Def.tips7
		grid = leftGrids[itemIndex]
		--容器物品转移
		local fromIndex = grid:getIndex()
		local toIndex = BookEditorCtrl.FindEmptyGridIndexInRight(1,BookEditorCtrl.Def.gridBookStartIndex1 - 1)
		if toIndex ~= - 1 then 
			CurMainPlayer:moveItem(fromIndex,toIndex,1)
			-- statisticsUIInGame(61011,EnterRoomType)
		else
			--没有空位
			ShowGameTips(errorTips,3)
		end 
	else
		local leftGrids = BookEditorCtrl.Data.splitData.leftBookGrids
		local errorTips = BookEditorCtrl.Def.tips8
		grid = leftGrids[itemIndex]
		--容器物品转移
		local fromIndex = grid:getIndex()
		local toIndex = BookEditorCtrl.FindEmptyGridIndexInRight(BookEditorCtrl.Def.gridBookStartIndex2,BookEditorCtrl.Def.gridBookStartIndex2)
		if toIndex ~= - 1 then 
			CurMainPlayer:moveItem(fromIndex,toIndex,1)
		else
			--没有空位
			ShowGameTips(errorTips,3)
		end 
	end 
end 

--从编书台容器内移除物品
BookEditorCtrl.RemoveItemFromContainer = function(itemIndex,isArray)
	local grid = nil 
	if itemIndex ~= BookEditorCtrl.Def.gridBookStartIndex1 and itemIndex ~= BookEditorCtrl.Def.gridBookStartIndex2 then
		local leftGrids = nil
		local rightGrids = nil
		BookEditorCtrl.Data.resetCountMax = 0
		BookEditorCtrl.Data.resetCount = 0
		if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then
			leftGrids = BookEditorCtrl.Data.editData.leftLetterGrids
			rightGrids = BookEditorCtrl.Data.editData.rightLetterGrids
		else
			leftGrids = BookEditorCtrl.Data.editData.leftLetterGrids
			rightGrids = BookEditorCtrl.Data.splitData.rightLetterGrids
		end 
		grid = rightGrids[itemIndex]
		--容器物品转移
		local fromIndex = grid:getIndex()
		local toIndex = BookEditorCtrl.FindEmptyGridIndexInLeft(ClientBackpack:getShortcutStartIndex(),BACKPACK_START_INDEX)
		if toIndex ~= -1 then 
			CurMainPlayer:moveItem(fromIndex,toIndex,1)
			SandboxLua.eventDispatcher:Emit(CurMainPlayer, "AddItem_SceneEditor", 
			SandboxContext():SetData_Number("index", toIndex))

			BookEditorCtrl.Data.resetCountMax = BookEditorCtrl.Data.resetCountMax + 2
			for i = fromIndex,fromIndex + BookEditorCtrl.Def.rightItemRow * BookEditorCtrl.Def.rightItemCol do 
				if i ~= EDITBOOK_START_INDEX + BookEditorCtrl.Def.gridBookStartIndex1 - 1 and 
				i ~= EDITBOOK_START_INDEX + BookEditorCtrl.Def.gridBookStartIndex2 - 1 then
					local checkGrid = ClientBackpack:index2Grid(i)
					if checkGrid and checkGrid:getItemID() ~= 0 then
						BookEditorCtrl.Data.resetCountMax = BookEditorCtrl.Data.resetCountMax + 2 
					end 
					CurMainPlayer:moveItem(i,i - 1,1)
				else
					break
				end 
			end 
		else
			--没有空位
			ShowGameTips(BookEditorCtrl.Def.tips6,3)
			return toIndex
		end 
	else 
		local leftGrids = BookEditorCtrl.Data.splitData.leftBookGrids
		local bookGrid = nil 
		if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then
			bookGrid = BookEditorCtrl.Data.editData.bookGrid
		else
			bookGrid = BookEditorCtrl.Data.splitData.bookGrid
		end 
		--容器物品转移
		local fromIndex = bookGrid:getIndex()
		local toIndex = BookEditorCtrl.FindEmptyGridIndexInLeft(ClientBackpack:getShortcutStartIndex(),BACKPACK_START_INDEX)
		if toIndex ~= -1 then 
			CurMainPlayer:moveItem(fromIndex,toIndex,1)
			SandboxLua.eventDispatcher:Emit(CurMainPlayer, "AddItem_SceneEditor", 
			SandboxContext():SetData_Number("index", toIndex))
		else
			--没有空位
			ShowGameTips(BookEditorCtrl.Def.tips6,3)
			return toIndex
		end 
	end  
end

--清理书本显示
function BookEditorCtrl.ClearBookShow(curHandleType)
	local curHandleType = curHandleType or BookEditorCtrl.Data.curHandleType
	if curHandleType == BookEditorCtrl.Def.handleType.edit then	
		BookEditorCtrl.Data.editData.bookGrid = nil 
		BookEditorCtrl.Data.editData.bookName = GetS(6984,AccountManager:getNickName())
		BookEditorCtrl.Data.editData.editorName = AccountManager:getNickName()
		BookEditorCtrl.Data.editData.details = ""
	else
		BookEditorCtrl.Data.splitData.bookGrid = nil 
		BookEditorCtrl.Data.splitData.bookName = ""
		BookEditorCtrl.Data.splitData.editorName = ""
		BookEditorCtrl.Data.splitData.details = ""
	end 
end

--重置书本显示
function BookEditorCtrl.ResetBookShow(curHandleType)
	local bookGrid = nil
	local bookData = nil 
	local curHandleType = curHandleType or BookEditorCtrl.Data.curHandleType
	if curHandleType == BookEditorCtrl.Def.handleType.edit then	
		bookGrid = BookEditorCtrl.Data.editData.bookGrid
		bookData = BookEditorCtrl.ParseBookData(bookGrid)
		if bookData then
			BookEditorCtrl.Data.editData.bookName = bookData.title
			BookEditorCtrl.Data.editData.editorName = bookData.authorname
			BookEditorCtrl.Data.editData.details = bookData.context
		end
	else
		bookGrid = BookEditorCtrl.Data.splitData.bookGrid
		bookData = BookEditorCtrl.ParseBookData(bookGrid)
		if bookData then
			BookEditorCtrl.Data.splitData.bookName = bookData.title
			BookEditorCtrl.Data.splitData.editorName = bookData.authorname
			BookEditorCtrl.Data.splitData.details = bookData.context
		end		
	end 
end

--是否有效空位
function BookEditorCtrl.IsValidGridIndex(index,isLeft) 
	local isValid = false 
	if isLeft then
		if index >= 0 then 
			isValid = true 
		end 
	else
		local maxSize = BookEditorCtrl.Def.rightItemRow * BookEditorCtrl.Def.rightItemCol * 2 + 2
		if index >= 0 and index < EDITBOOK_START_INDEX + maxSize then 
			isValid = true 
		end 
	end 
	return isValid
end

--从编书台容器中找一个空位
function BookEditorCtrl.FindEmptyGridIndexInRight(startIndex,endIndex)
	local toIndex = -1
	for i = startIndex,endIndex do 
		local index = i - 1 + EDITBOOK_START_INDEX 
		local grid = ClientBackpack:index2Grid(index)
		local itemId = grid:getItemID()
		if itemId == 0 then
			toIndex = index 
			break 
		end 
	end 
	if not BookEditorCtrl.IsValidGridIndex(toIndex,false) then 
		toIndex = - 1
	end 
	return toIndex 
end 

--获取编书台容器空位数量
function BookEditorCtrl.GetEmptyGridCountInRight(startIndex,endIndex)
	local count = 0 
	for i = startIndex,endIndex do 
		local index = i - 1 + EDITBOOK_START_INDEX 
		local grid = ClientBackpack:index2Grid(index)
		local itemId = grid:getItemID()
		if itemId == 0 and BookEditorCtrl.IsValidGridIndex(index,false) then
			count = count + 1 
		end 
	end  
	return count
end

--从快捷栏或者背包中找一个空位
function BookEditorCtrl.FindEmptyGridIndexInLeft(startIndex1,startIndex2)
	local toIndex = ClientBackpack:getEmptyShortcutIndex() 
	if toIndex == -1 then
		toIndex = ClientBackpack:getEmptyBagIndex()
	end
	if not BookEditorCtrl.IsValidGridIndex(toIndex,true) then 
		toIndex = - 1
	end
	return toIndex 
end

--重置所有物品
-- function BookEditorCtrl.RestoreAllItem()
-- 	local rightGrids = nil
-- 	local bookGrid = nil 
-- 	if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then
-- 		rightGrids = BookEditorCtrl.Data.editData.rightLetterGrids
-- 		local result = 0
-- 		local endIndex = 0
-- 		for i = 1,#rightGrids do
-- 			local curIndex = rightGrids[i]:getIndex() - EDITBOOK_START_INDEX + 1
-- 			local result = BookEditorCtrl.RemoveItemFromContainer(curIndex,true)
-- 			if result == -1 then 
-- 				endIndex = i
-- 				break
-- 			end 
-- 		end 
-- 		if result == 0 then 
-- 			BookEditorCtrl.Data.editData.rightLetterGrids = {}
-- 		else
-- 			local newGrids = {}
-- 			for i = 1,rightGrids do 
-- 				if i >= endIndex then 
-- 					table.insert(newGrids,rightGrids[i])
-- 				end 
-- 			end 
-- 			BookEditorCtrl.Data.editData.rightLetterGrids = newGrids
-- 		end 
-- 		bookGrid = BookEditorCtrl.Data.editData.bookGrid
-- 		if bookGrid then 
-- 			BookEditorCtrl.RemoveItemFromContainer(bookGrid:getIndex() - EDITBOOK_START_INDEX + 1)
-- 		end 
-- 	else
-- 		rightGrids = BookEditorCtrl.Data.splitData.rightLetterGrids
-- 		local result = 0
-- 		local endIndex = 0
-- 		for i = 1,#rightGrids do
-- 			local curIndex = rightGrids[i]:getIndex() - EDITBOOK_START_INDEX + 1 - BookEditorCtrl.Def.gridBookStartIndex1
-- 			local result = BookEditorCtrl.RemoveItemFromContainer(curIndex,true)
-- 			if result == -1 then 
-- 				endIndex = i
-- 				break
-- 			end 
-- 		end
-- 		if result == 0 then
-- 			BookEditorCtrl.Data.splitData.rightLetterGrids = {}
-- 		else
-- 			local newGrids = {}
-- 			for i = 1,rightGrids do 
-- 				if i >= endIndex then 
-- 					table.insert(newGrids,rightGrids[i])
-- 				end 
-- 			end 
-- 			BookEditorCtrl.Data.splitData.rightLetterGrids = newGrids
-- 		end 
-- 		bookGrid = BookEditorCtrl.Data.splitData.bookGrid
-- 		if bookGrid then 
-- 			BookEditorCtrl.RemoveItemFromContainer(bookGrid:getIndex() - EDITBOOK_START_INDEX + 1)
-- 		end 
-- 	end 
-- 	BookEditorFrame.UpdateLeftPanelItemList(BookEditorCtrl.Data.curHandleType,BookEditorCtrl.Data)
-- 	BookEditorFrame.UpdateRightPanelItemList(BookEditorCtrl.Data.curHandleType,BookEditorCtrl.Data)
-- end

--重置所有物品
function BookEditorCtrl.RestoreAllItem()
	BookEditorCtrl.Data.resetCountMax = 0
	BookEditorCtrl.Data.resetCount = 0
	local rightGrids = nil
	local bookGrid = nil 
	local endIndex = 0
	local moveCount = 0
	local shortcutStartIdx = ClientBackpack:getShortcutStartIndex()
	local shortcutCount = ClientBackpack:getShortcutGridCount()
	local findIndex1 = shortcutStartIdx
	local findIndex2 = BACKPACK_START_INDEX
	if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then
		rightGrids = BookEditorCtrl.Data.editData.rightLetterGrids
		bookGrid = BookEditorCtrl.Data.editData.bookGrid  
	else
		rightGrids = BookEditorCtrl.Data.splitData.rightLetterGrids
		bookGrid = BookEditorCtrl.Data.splitData.bookGrid
	end 
	for i = 1,#rightGrids do
		local fromIndex = rightGrids[i]:getIndex()
		local toIndex = BookEditorCtrl.FindEmptyGridIndexInLeft(findIndex1,findIndex2)
		if toIndex ~= -1 then 
			CurMainPlayer:moveItem(fromIndex,toIndex,1)
			BookEditorCtrl.Data.resetCountMax = BookEditorCtrl.Data.resetCountMax + 1
			moveCount = moveCount + 1
			if findIndex1 <= shortcutStartIdx + shortcutCount - 1 then 
				findIndex1 = toIndex + 1
			else
				findIndex2 = toIndex + 1
			end 
		else
			endIndex = i 
			break 
		end 
	end
	if endIndex ~= 0 and endIndex ~= #rightGrids then 
		ShowGameTips(BookEditorCtrl.Def.tips6,3)
	end 
	if moveCount == 0 then 
		ShowGameTips(BookEditorCtrl.Def.tips6,3)
	end 
	local newGrids = {}
	for i = 1,#rightGrids do 
		if i >= endIndex then 
			local aIndex = rightGrids[i]:getIndex()
			CurMainPlayer:moveItem(aIndex,aIndex - endIndex + 1,1)
			BookEditorCtrl.Data.resetCountMax = BookEditorCtrl.Data.resetCountMax + 1
			table.insert(newGrids,rightGrids[i])
		end 
	end
	if BookEditorCtrl.Data.curHandleType == BookEditorCtrl.Def.handleType.edit then
		BookEditorCtrl.Data.editData.rightLetterGrids = newGrids 
	else
		BookEditorCtrl.Data.splitData.rightLetterGrids = newGrids
	end 
	if bookGrid then 
		BookEditorCtrl.RemoveItemFromContainer(bookGrid:getIndex() - EDITBOOK_START_INDEX + 1)
		BookEditorCtrl.Data.resetCountMax = BookEditorCtrl.Data.resetCountMax + 1
	end
end

--去掉文字中的换行符
function BookEditorFrameRemoveLineBreak()
	local text = this:GetText();
	if (text and #text >= 1) then
		local hasBreak = false;
		text = string.gsub(text, "\n", function(str)
			hasBreak = true;
			return "";
		end);
		if (hasBreak) then
			this:SetText(text);
		end
	end
end

--获取多语言内容
function BookEditorCtrl.SetMultiLangName(langs)
	BookEditorCtrl.Data.multiLangName = langs
end

function BookEditorCtrl.GetMultiLangName()
	return BookEditorCtrl.Data.multiLangName
end

function BookEditorCtrl.SetMultiLangEditor(langs)
	BookEditorCtrl.Data.multiLangEditor = langs
end

function BookEditorCtrl.GetMultiLangEditor()
	return BookEditorCtrl.Data.multiLangEditor
end

function BookEditorCtrl.SetMultiLangDetails(langs)
	BookEditorCtrl.Data.multiLangDetails = langs
end

function BookEditorCtrl.GetMultiLangDetails()
	return BookEditorCtrl.Data.multiLangDetails
end