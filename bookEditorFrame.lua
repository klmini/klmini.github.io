--编书页面
BookEditorFrame = {}

--模拟将逻辑HOOK到BookEditorCtrl 
function BookEditorFrame_OnLoad()
	BookEditorCtrl.Load()
end
function BookEditorFrame_OnShow()
    BookEditorCtrl.Active()
end

function BookEditorFrame_OnEvent()
	local data = GameEventQue:getCurEvent()
	BookEditorCtrl.HandleEvent(arg1,data)
end

function BookEditorFrameCloseBtn_OnClick()
	BookEditorCtrl.AntiActive()
end

function BookEditorFrameTypeBtn_OnClick()
	local index = this:GetClientID()
	BookEditorCtrl.SelectHandleType(index)
end

function BookEditorFrameLeftPanelSortBtn_OnClick()
	BookEditorCtrl.SortItem()
end

function BookEditorFrameItem_OnClick()
	BookEditorCtrl.HandleItem(BookEditorCtrl.Def.handleItemType.click,this)
end

function BookEditorFrameItem_OnMouseEnter_PC()
	BookEditorCtrl.HandleItem(BookEditorCtrl.Def.handleItemType.mouseEnter,this)
end

function BookEditorFrameItem_OnMouseLeave_PC()
	BookEditorCtrl.HandleItem(BookEditorCtrl.Def.handleItemType.mouseLeave,this)
end

function BookEditorFrameBookNameEdit_OnFocusLost()
	BookEditorCtrl.HandleEditBox(BookEditorCtrl.Def.handleEditBoxType.focusLost,BookEditorCtrl.Def.handleEditBoxObj.name)
end

function BookEditorFrameBookEditorEdit_OnFocusLost()
	BookEditorCtrl.HandleEditBox(BookEditorCtrl.Def.handleEditBoxType.focusLost,BookEditorCtrl.Def.handleEditBoxObj.editor)
end

function BookEditorFrameBookDetailEdit_OnFocusGained()
	BookEditorCtrl.HandleEditBox(BookEditorCtrl.Def.handleEditBoxType.focusGained,BookEditorCtrl.Def.handleEditBoxObj.detail)
end

function BookEditorFrameBookDetailEdit_OnFocusLost()
	BookEditorCtrl.HandleEditBox(BookEditorCtrl.Def.handleEditBoxType.focusLost,BookEditorCtrl.Def.handleEditBoxObj.detail)
end

function BookEditorFrameBookDetailEdit_OnTextSet()
	BookEditorCtrl.HandleEditBox(BookEditorCtrl.Def.handleEditBoxType.textSet,BookEditorCtrl.Def.handleEditBoxObj.detail)
end

function BookEditorFrameRightPanel1MakeBtn_OnClick()
	BookEditorCtrl.EditLettersToBook()
end

function BookEditorFrameRightPanel2MakeBtn_OnClick()
	BookEditorCtrl.SplitBookToLetters()
end

function BookEditorFrameRightPanelRestoreBtn_OnClick()
	BookEditorCtrl.RestoreAllItem()
end
-------------------------------------------------------
--关闭页面
BookEditorFrame.Close = function()
	BookEditorFrame.frame:Hide()
end

--初始化页面
BookEditorFrame.Init = function()
	BookEditorFrame.frame = getglobal("BookEditorFrame")

	BookEditorFrame.typeBtn1NormalImg = getglobal("BookEditorFrameTypeBtn1Normal")
	BookEditorFrame.typeBtn2NormalImg = getglobal("BookEditorFrameTypeBtn2Normal")
	BookEditorFrame.typeBtn1PushedImg = getglobal("BookEditorFrameTypeBtn1PushedBG")
	BookEditorFrame.typeBtn2PushedImg = getglobal("BookEditorFrameTypeBtn2PushedBG")
	BookEditorFrame.typeBtn1Name = getglobal("BookEditorFrameTypeBtn1Name")
	BookEditorFrame.typeBtn2Name = getglobal("BookEditorFrameTypeBtn2Name")

	BookEditorFrame.nameEditBox = getglobal("BookEditorFrameLeftPanelBookNameEditBox")
	BookEditorFrame.editorEditBox = getglobal("BookEditorFrameLeftPanelBookEditorEditBox")
	BookEditorFrame.detailEditBox = getglobal("BookEditorFrameLeftPanelBookDetailEditBox")
	BookEditorFrame.nameEditBoxBg = getglobal("BookEditorFrameLeftPanelBookInfoNameBg")
	BookEditorFrame.editorEditBoxBg = getglobal("BookEditorFrameLeftPanelBookInfoEditorBg")
	BookEditorFrame.detailEditBoxBg = getglobal("BookEditorFrameLeftPanelBookInfoDetailBg")
	BookEditorFrame.nameEditBoxCoverBg = getglobal("BookEditorFrameLeftPanelBookInfoNameCoverBg")
	BookEditorFrame.editorEditBoxCoverBg = getglobal("BookEditorFrameLeftPanelBookInfoEditorCoverBg")
	BookEditorFrame.detailEditBoxCoverBg = getglobal("BookEditorFrameLeftPanelBookInfoDetailCoverBg")
	BookEditorFrame.nameEditBoxCoverText = getglobal("BookEditorFrameLeftPanelBookInfoNameCoverText")
	BookEditorFrame.editorEditBoxCoverText = getglobal("BookEditorFrameLeftPanelBookInfoEditorCoverText")
	BookEditorFrame.detailEditBoxCoverText = getglobal("BookEditorFrameLeftPanelBookInfoDetailCoverText")
	BookEditorFrame.bookInfoIcon = getglobal("BookEditorFrameLeftPanelBookInfoIcon")
	BookEditorFrame.itemTitle = getglobal("BookEditorFrameLeftPanelItemTitle")

	BookEditorFrame.rightPanel1 = getglobal("BookEditorFrameRightPanel1")
	BookEditorFrame.rightPanel2 = getglobal("BookEditorFrameRightPanel2")

	BookEditorFrame.nameTranslateBtn = getglobal("BookEditorFrameLeftPanelTranslateName")
	BookEditorFrame.editorTranslateBtn = getglobal("BookEditorFrameLeftPanelTranslateEditor")
	BookEditorFrame.detailTranslateBtn = getglobal("BookEditorFrameLeftPanelTranslateDetail")

	BookEditorFrame.InitItemPos()

	--右侧书本不显示底框
	getglobal("BookEditorRightPanel1Item13Bg"):Hide()
	getglobal("BookEditorRightPanel2Item13Bg"):Hide()
    getglobal("BookEditorRightPanel1Item13Name"):SetSize(400, 35);
    getglobal("BookEditorRightPanel2Item13Name"):SetSize(400, 35);
end

--初始化物品栏列表里物品的位置
BookEditorFrame.InitItemPos = function()
	local row = BookEditorCtrl.Def.leftItemRow
	local col = BookEditorCtrl.Def.leftItemCol
	for i = 1, row do
		for j = 1, col do
			local index = (i - 1) * col + j
			local item = getglobal("BookEditorLeftItem" .. index)
			item:SetPoint("topleft", "BookEditorFrameLeftPanelItemListPlane", "topleft", (j - 1) * 85, (i - 1) * 90 + 10)
		end
	end

	local row = BookEditorCtrl.Def.rightItemRow
	local col = BookEditorCtrl.Def.rightItemCol
	for i = 1, row do
		for j = 1, col do
			local index = (i - 1) * col + j
			local item1 = getglobal("BookEditorRightPanel1Item" .. index)
			local item2 = getglobal("BookEditorRightPanel2Item" .. index)
			item1:SetPoint("topleft", "BookEditorFrameRightPanel1ListBg", "topleft", (j - 1) * 85 + 10, (i - 1) * 90 + 10)
			item2:SetPoint("topleft", "BookEditorFrameRightPanel2ListBg", "topleft", (j - 1) * 85 + 10, (i - 1) * 90 + 10)
		end
	end
	local item1 = getglobal("BookEditorRightPanel1Item13")
	local item2 = getglobal("BookEditorRightPanel2Item13")
	item1:SetPoint("center", "BookEditorFrameRightPanel1BookBg", "center",0,0)
	item2:SetPoint("center", "BookEditorFrameRightPanel2BookBg", "center",0,0)

	getglobal("BookEditorFrameTypeBtn1Checked"):Checked()
	getglobal("BookEditorFrameTypeBtn2Checked"):Checked()
	-- getglobal("BookEditorFrameTypeBtn1Checked"):Disable(false);
	-- getglobal("BookEditorFrameTypeBtn2Checked"):Disable(false);
end

--更新页签UI
BookEditorFrame.UpdateHandleType = function(handleType)
	if handleType == BookEditorCtrl.Def.handleType.edit then
		getglobal("BookEditorFrameTypeBtn1Checked"):Show()
		getglobal("BookEditorFrameTypeBtn2Checked"):Hide()
		BookEditorFrame.typeBtn1Name:SetTextColor(255,135,28)
		BookEditorFrame.typeBtn2Name:SetTextColor(142,135,119)
		BookEditorFrame.itemTitle:SetText(GetS(21725))
	else
		getglobal("BookEditorFrameTypeBtn1Checked"):Hide()
		getglobal("BookEditorFrameTypeBtn2Checked"):Show()
		BookEditorFrame.typeBtn1Name:SetTextColor(142,135,119)
		BookEditorFrame.typeBtn2Name:SetTextColor(255,135,28)
		BookEditorFrame.itemTitle:SetText(GetS(21726))
	end
end 

--更新左边区域UI
BookEditorFrame.UpdateLeftPanel = function(handleType,data)
	BookEditorFrame.UpdateLeftPanelItemList(handleType,data)
	BookEditorFrame.UpdateLeftPanelBookInfo(handleType,data)
end 

--更新左边物品栏
BookEditorFrame.UpdateLeftPanelItemList = function(handleType,data)
	getglobal("BookEditorFrameLeftPanelItemList"):resetOffsetPos()
	local leftGrids = nil 
	if handleType == BookEditorCtrl.Def.handleType.edit then 
		leftGrids = data.editData.leftLetterGrids
	else
		leftGrids = data.splitData.leftBookGrids
	end 
	local itemMaxCount = BookEditorCtrl.Def.leftItemRow * BookEditorCtrl.Def.leftItemCol
	for i = 1,itemMaxCount do 
		local aItemIcon = getglobal("BookEditorLeftItem" .. i .. "Icon")
		local aItemIconNormal = getglobal("BookEditorLeftItem" .. i .. "IconNormal")
		local aItemIconPushed = getglobal("BookEditorLeftItem" .. i .. "IconPushedBG")
		local aItemIconName = getglobal("BookEditorLeftItem" .. i .. "Name")
		if i <= #leftGrids then 
			aItemIcon:Show()
			aItemIconName:Show()
			g_SetItemTexture(aItemIconNormal,BookEditorFrame.ConvertID(leftGrids[i]:getItemID()))
			g_SetItemTexture(aItemIconPushed,BookEditorFrame.ConvertID(leftGrids[i]:getItemID()))
			local nameText = BookEditorFrame.GetItemNameText(leftGrids[i],true)
			aItemIconName:SetText(ReplaceFilterString(nameText))
		else
			aItemIcon:Hide()
			aItemIconName:Hide()
		end 
	end  
end 

--更新左边书籍信息
BookEditorFrame.UpdateLeftPanelBookInfo = function(handleType,data)
	local bookName = ""
	local editorName = ""
	local details = ""
	local bookId = BookEditorCtrl.Def.bookId
	if handleType == BookEditorCtrl.Def.handleType.edit then
		bookName = data.editData.bookName
		editorName = data.editData.editorName
		details = data.editData.details
		BookEditorFrame.ChangeEditState(data.isEditable)
		if bookName == "" then
			BookEditorFrame.nameEditBox:SetDefaultText(BookEditorCtrl.Def.bookDefaultText)
			BookEditorFrame.nameEditBox:SetText("")
		else
			BookEditorFrame.nameEditBox:SetText(ReplaceFilterString(bookName))
		end 
		if editorName == "" then
			BookEditorFrame.editorEditBox:SetDefaultText(BookEditorCtrl.Def.bookDefaultText)
			BookEditorFrame.editorEditBox:SetText("")
		else
			BookEditorFrame.editorEditBox:SetText(ReplaceFilterString(editorName))
		end 
		if details == "" then
			BookEditorFrame.detailEditBox:SetText("")
			getglobal("BookEditorFrameLeftPanelBookDetailEditBoxDefault"):SetText(BookEditorCtrl.Def.bookDefaultText)
		else
			BookEditorFrame.detailEditBox:SetText(ReplaceFilterString(details))
		end 
		BookEditorFrame.nameEditBoxCoverText:SetText("")
		BookEditorFrame.editorEditBoxCoverText:SetText("")
		BookEditorFrame.detailEditBoxCoverText:SetText("")
		local worldid = AccountManager:getCurWorldId();
        if ShowTranslateBtn("bookEdit_name", worldid) then
            ShowTranslateTextState("bookEdit_name",worldid)
        end
        if ShowTranslateBtn("bookEdit_editor", worldid) then
            ShowTranslateTextState("bookEdit_editor",worldid)
        end
        if ShowTranslateBtn("bookEdit_detail", worldid) then
            ShowTranslateTextState("bookEdit_detail",worldid)
        end
	else
		bookName = data.splitData.bookName
		editorName = data.splitData.editorName
		details = data.splitData.details
		BookEditorFrame.ChangeEditState(data.isEditable)
		if bookName == "" then
			BookEditorFrame.nameEditBoxCoverText:SetText("")
		else
			BookEditorFrame.nameEditBoxCoverText:SetText(ReplaceFilterString(bookName))
		end 
		if editorName == "" then
			BookEditorFrame.editorEditBoxCoverText:SetText("")
		else
			BookEditorFrame.editorEditBoxCoverText:SetText(ReplaceFilterString(editorName))
		end 
		if details == "" then
			BookEditorFrame.detailEditBoxCoverText:SetText("")
		else
			BookEditorFrame.detailEditBoxCoverText:SetText(ReplaceFilterString(details))
		end
		BookEditorFrame.nameTranslateBtn:Hide()
		BookEditorFrame.editorTranslateBtn:Hide()
		BookEditorFrame.detailTranslateBtn:Hide() 
	end 
	g_SetItemTexture(BookEditorFrame.bookInfoIcon,bookId)
end 

--书籍信息编辑状态切换
BookEditorFrame.ChangeEditState = function(isEditable) 
	if isEditable then 
		BookEditorFrame.nameEditBox:Show()
		BookEditorFrame.editorEditBox:Show()
		BookEditorFrame.detailEditBox:Show()
		BookEditorFrame.nameEditBoxCoverBg:Hide()
		BookEditorFrame.editorEditBoxCoverBg:Hide()
		BookEditorFrame.detailEditBoxCoverBg:Hide()
		BookEditorFrame.nameEditBoxCoverText:Hide()
		BookEditorFrame.editorEditBoxCoverText:Hide()
		BookEditorFrame.detailEditBoxCoverText:Hide()
	else
		BookEditorFrame.nameEditBox:Hide()
		BookEditorFrame.editorEditBox:Hide()
		BookEditorFrame.detailEditBox:Hide()
		BookEditorFrame.nameEditBoxCoverBg:Show()
		BookEditorFrame.editorEditBoxCoverBg:Show()
		BookEditorFrame.detailEditBoxCoverBg:Show()
		BookEditorFrame.nameEditBoxCoverText:Show()
		BookEditorFrame.editorEditBoxCoverText:Show()
		BookEditorFrame.detailEditBoxCoverText:Show()
	end 
end 

--更新右边区域UI
BookEditorFrame.UpdateRightPanel = function(handleType,data)
	BookEditorFrame.UpdateRightPanelShow(handleType)
	BookEditorFrame.UpdateRightPanelItemList(handleType,data)
end  

--更新右边显示或隐藏
BookEditorFrame.UpdateRightPanelShow = function(handleType)
	if handleType == BookEditorCtrl.Def.handleType.edit then 
		BookEditorFrame.rightPanel1:Show()
		BookEditorFrame.rightPanel2:Hide()
	else
		BookEditorFrame.rightPanel1:Hide()
		BookEditorFrame.rightPanel2:Show()
	end
end 

--更新右边物品栏
BookEditorFrame.UpdateRightPanelItemList = function(handleType,data)
	local rightLetterGrids = nil 
	local rightBookGrid = nil 
	if handleType == BookEditorCtrl.Def.handleType.edit then 
		rightLetterGrids = data.editData.rightLetterGrids
		rightBookGrid = data.editData.bookGrid 
	else
		rightLetterGrids = data.splitData.rightLetterGrids
		rightBookGrid = data.splitData.bookGrid
	end

	local function showItem(isShow,isLimitLength,gird,itemIcon,itemIconName,itemIconNormal,itemIconPushed)
		if isShow then 
			itemIcon:Show()
			itemIconName:Show()
			g_SetItemTexture(itemIconNormal,BookEditorFrame.ConvertID(gird:getItemID()))
			g_SetItemTexture(itemIconPushed,BookEditorFrame.ConvertID(gird:getItemID()))
			local nameText = BookEditorFrame.GetItemNameText(gird,isLimitLength)
			itemIconName:SetText(ReplaceFilterString(nameText))
		else
			itemIcon:Hide()
			itemIconName:Hide()
		end 
	end 

	local itemMaxCount = BookEditorCtrl.Def.rightItemRow * BookEditorCtrl.Def.rightItemCol + 1
	for i = 1,itemMaxCount do 
		local aItemIcon = getglobal("BookEditorRightPanel" .. handleType .. "Item" .. i .. "Icon")
		local aItemIconNormal = getglobal("BookEditorRightPanel" .. handleType .. "Item" .. i .. "IconNormal")
		local aItemIconPushed = getglobal("BookEditorRightPanel" .. handleType .. "Item" .. i .. "IconPushedBG")
		local aItemIconName = getglobal("BookEditorRightPanel" .. handleType .. "Item" .. i .. "Name")
		if i ~= itemMaxCount then
			--1 ~ itemMaxCount - 1的格位为信件
			if i <= #rightLetterGrids then 
				showItem(true,true,rightLetterGrids[i],aItemIcon,aItemIconName,aItemIconNormal,aItemIconPushed)
			else
				showItem(false,true,rightLetterGrids[i],aItemIcon,aItemIconName,aItemIconNormal,aItemIconPushed)
			end 
		else 
			--最后格位固定为书本
			if rightBookGrid then 
				showItem(true,false,rightBookGrid,aItemIcon,aItemIconName,aItemIconNormal,aItemIconPushed)
			else
				showItem(false,false,rightBookGrid,aItemIcon,aItemIconName,aItemIconNormal,aItemIconPushed)
			end 
		end 
	end  
end 

--获取物品栏中物品的名字
BookEditorFrame.GetItemNameText = function(grid,isLimitLength) 
	local itemId = grid:getItemID()
	local itemData = grid:getUserdataStr()
	local uin,author,title,context,changetime,oldtitle,oldcontext
	if itemId == BookEditorCtrl.Def.bookId then
		local bookData = BookEditorCtrl.ParseBookData(grid)
	    if bookData and type(bookData) == "table" then
	        if bookData.title then
	            title = bookData.title
	        end
	    end 
	elseif itemId == BookEditorCtrl.Def.letterId then 
		uin,author,title,context,_,__,changetime,oldtitle,oldcontext = LettersParse(itemData)
		if not CheckEnableShow(changetime) then
			if oldtitle ~= ""then
				title = oldtitle;
			else
				title = "";
			end
		end
	end 
	--isLimitLength = true 书本名字不缩写
	if isLimitLength then
		local maxLen = 12
		if title and string.len(title) > maxLen then 
			title = string.sub(title,1,maxLen) .. "..."
		end 
	end
	return title
end 

--获取当前书本信息
BookEditorFrame.GetBookNameText = function() 
	return BookEditorFrame.nameEditBox:GetText()
end 

BookEditorFrame.GetBookEditorText = function() 
	return BookEditorFrame.editorEditBox:GetText()
end 

BookEditorFrame.GetBookDetailText = function() 
	return BookEditorFrame.detailEditBox:GetText()
end 

--设置默认的书本信息
BookEditorFrame.SetDefaultBookNameText = function() 
	BookEditorFrame.nameEditBox:SetDefaultText(BookEditorCtrl.Def.bookDefaultText)
	BookEditorFrame.nameEditBox:SetText("")
end 

BookEditorFrame.SetDefaultBookEditorText = function() 
	BookEditorFrame.editorEditBox:SetDefaultText(BookEditorCtrl.Def.bookDefaultText)
	BookEditorFrame.editorEditBox:SetText("")
end 

BookEditorFrame.SetDefaultBookDetailText = function(isSetRealText)
	if isSetRealText then 
		BookEditorFrame.detailEditBox:SetText("")
	end  
	getglobal("BookEditorFrameLeftPanelBookDetailEditBoxDefault"):SetText(BookEditorCtrl.Def.bookDefaultText)
end 

BookEditorFrame.DeleteDefaultBookDetailText = function()
	getglobal("BookEditorFrameLeftPanelBookDetailEditBoxDefault"):SetText("")
end

--更新单个ITEM
BookEditorFrame.UpdateSingleItem = function(gridIndex,isLeft,itemIndex)
	local aItemIcon
	local aItemIconNormal
	local aItemIconPushed
	local aItemIconName
	local aGrid = ClientBackpack:index2Grid(gridIndex)
	if isLeft then 
		aItemIcon = getglobal("BookEditorLeftItem" .. itemIndex .. "Icon")
		aItemIconNormal = getglobal("BookEditorLeftItem" .. itemIndex .. "IconNormal")
		aItemIconPushed = getglobal("BookEditorLeftItem" .. itemIndex .. "IconPushedBG")
		aItemIconName = getglobal("BookEditorLeftItem" .. itemIndex .. "Name")
	else
		local handleType = BookEditorCtrl.Def.handleType.edit 
		if itemIndex > BookEditorCtrl.Def.gridBookStartIndex1 then 
			itemIndex = itemIndex -  BookEditorCtrl.Def.gridBookStartIndex1
			handleType = BookEditorCtrl.Def.handleType.split 
		end 
		aItemIcon = getglobal("BookEditorRightPanel" .. handleType .. "Item" .. itemIndex .. "Icon")
		aItemIconNormal = getglobal("BookEditorRightPanel" .. handleType .. "Item" .. itemIndex .. "IconNormal")
		aItemIconPushed = getglobal("BookEditorRightPanel" .. handleType .. "Item" .. itemIndex .. "IconPushedBG")
		aItemIconName = getglobal("BookEditorRightPanel" .. handleType .. "Item" .. itemIndex .. "Name")
	end 
	if aGrid:getItemID() == 0 then
		--无数据
		aItemIcon:Hide()
		aItemIconName:Hide()
	else
		--有数据
		aItemIcon:Show()
		aItemIconName:Show()
		g_SetItemTexture(aItemIconNormal,BookEditorFrame.ConvertID(aGrid:getItemID()))
		g_SetItemTexture(aItemIconPushed,BookEditorFrame.ConvertID(aGrid:getItemID()))
		local isLimitNameLength = true 
		if gridIndex == EDITBOOK_START_INDEX + BookEditorCtrl.Def.gridBookStartIndex1 - 1 or 
		gridIndex == EDITBOOK_START_INDEX + BookEditorCtrl.Def.gridBookStartIndex2 - 1 then
			isLimitNameLength = false
		end 
		local nameText = BookEditorFrame.GetItemNameText(aGrid,isLimitNameLength)
		aItemIconName:SetText(ReplaceFilterString(nameText))
	end 
end

--写过的信纸ID显示上特殊处理
BookEditorFrame.ConvertID = function(itemID)
	local convertedItemID = 0
	if itemID == BookEditorCtrl.Def.letterId then
		convertedItemID = BookEditorCtrl.Def.writedLetterId
	else
		convertedItemID = itemID
	end 
	return convertedItemID
end 

