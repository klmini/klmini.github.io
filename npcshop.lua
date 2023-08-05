local gListTotalSize = 30
local gCurrentClickSkuId = -1
local gNeedRefreshList = {}
local gCurNpcShopInfo = nil
local gListData = {}

-- for NpcShopFrame panel
function NpcShopFrame_OnLoad()
	-- body
	-- init()
	this:setUpdateTime(1);
	this:RegisterEvent("GE_NPCSHOP_OPEN");
	this:RegisterEvent("GE_NPCSHOP_REFRESHSHOP");
end

function NpcShopFrameCloseBtn_OnClick()
	getglobal("NpcShopFrame"):Hide();
end

-- function NpcShopListItem_OnClick()
-- 	-- body
-- 	local idx = this:GetClientID()+1
-- 	gCurrentClickSkuId = this:GetClientUserData(0)

-- 	-- 该商品已售罄
-- 	local parentstr = "NpcShopFrameShopBoxItem" .. idx
-- 	local listitem = getglobal(parentstr)
-- 	if listitem then
-- 		local bg = getglobal(parentstr .. "Bkg")
-- 		if bg and bg:IsGray() then
-- 			ShowGameTips(GetS(21720), 3);
-- 			return
-- 		end
-- 	end

-- 	getglobal("NpcShopBuyFrame"):Show()
-- end

function NpcShopFrame_OnShow()
	-- body
	loadPanelInfo()

	ClientCurGame:setOperateUI(true);
end

function NpcShopFrame_OnHide()
	-- body
	gNeedRefreshList = {}
	ClientCurGame:setOperateUI(false);
end

function NpcShopFrame_OnEvent()
	-- print("NpcShopFrame_OnEvent ".. arg1)
	if arg1 == "GE_NPCSHOP_OPEN" then
		if not IsUIFrameShown("NpcShopFrame") then
			getglobal("NpcShopFrame"):Show();
		end 
	elseif arg1 == "GE_NPCSHOP_REFRESHSHOP" then
		local ge = GameEventQue:getCurEvent();
		notifyBuyResult(ge.body.gameevent.result)
	end
end

function NpcShopFrame_OnUpdate()
	-- body
	for k,v in pairs(gNeedRefreshList) do
		if v then
			manageCountDown(k, v)
		end
	end
end

function setHeadIcon(icon, def)
	if not def then return end

    if tonumber(def.Icon) and tonumber(def.Icon) > 0 then
        icon:SetTexture("ui/roleicons/" .. def.Icon .. ".png", true)
    else
        icon:SetTexture("ui/roleicons/" .. def.ID .. ".png", true) -- 个别怪物没有填写icon列
    end 
    if type(def.Icon) == "string" then
        if (string.sub(def.Icon,1,1)) == "a" then 
            --avatar图标
            AvatarSetIconByID(def,icon)
        end 
    end
end

function loadPanelInfo()
 	-- body
 	if not CurMainPlayer then return end

 	gCurNpcShopInfo = CurMainPlayer:getCurShopInfo()
 	local titleLab = getglobal("NpcShopFrameTitle")
 	titleLab:SetText(gCurNpcShopInfo.sShopName)

 	local talkTipsLab = getglobal("NpcShopFrameTalkTips")
 	talkTipsLab:SetText(gCurNpcShopInfo.sShopDesc)

 	local npcid = math.floor(gCurNpcShopInfo.iShopID/100)
 	local headIcon = getglobal("NpcShopFrameHeadIcon")
 	local monsterDef = MonsterCsv:get(DefMgr:getNpcShopNpcInnerId(gCurNpcShopInfo.sInnerKey, npcid, npcid))
 	setHeadIcon(headIcon, monsterDef)

 	updateList(true)
end 

-- function updateList()
-- 	local size = gCurNpcShopInfo:getSkuSize()
-- 	local skuinfo;
-- 	local idx = 1
-- 	local lastloadnum = #gListData
-- 	local num, item;
-- 	gListData = {}

-- 	for i=1,size do
-- 		skuinfo = gCurNpcShopInfo:getNpcShopSkuDefByIdx(i-1)
-- 		if skuinfo.iLeftCount > 0 then
-- 			table.insert(gListData, skuinfo)
-- 		else
-- 			table.insert(gListData, idx, skuinfo)
-- 			idx = idx + 1
-- 		end
-- 	end

-- 	local listviewCallBack = function(idx, name)
-- 		local listitem = getglobal(name)
-- 		if idx > #gListData then
-- 			listitem:Hide()
-- 			return
-- 		end

-- 		local w, h, offsetx, offsety = -1, 10, 3, 5
-- 		local loadnum = idx-1
-- 		local itemheight = listitem:GetHeight()

-- 		skuinfo = gListData[idx]
-- 		listitem:SetPoint("topleft", "NpcShopFrameShopBoxPlane", "topleft", offsetx+ (loadnum%2)*(w+listitem:GetWidth()), offsety+math.floor(loadnum/2)*(h+itemheight))
-- 		listitem:Show()
-- 		listitem:SetClientUserData(0, skuinfo.iSkuID)
-- 		setListItemData("NpcShopFrameShopBoxItem" .. idx, skuinfo)

-- 		if idx == #gListData then
-- 			local listFrame = getglobal("NpcShopFrameShopBox")
-- 			local listPanel = getglobal("NpcShopFrameShopBoxPlane")
-- 			local height = offsety+(itemheight+h)*math.floor((loadnum+2)/2)
-- 			if height < listFrame:GetHeight() then height = listFrame:GetHeight() end
-- 			listPanel:SetHeight(height)
-- 		end
-- 	end

-- 	lastloadnum = math.max(#gListData, lastloadnum)
-- 	for i=1,lastloadnum do
-- 		listviewMgr:createListItemAsync("NpcShopFrameShopBoxItem" .. i, "NpcShopListItemTemplate", "NpcShopFrameShopBox", i, i, listviewCallBack)
-- 	end
-- end

function updateList(bNeedRefresh)
	gListData = {}

	local idx, size = 1, gCurNpcShopInfo:getSkuSize()
	for i=1,size do
		skuinfo = gCurNpcShopInfo:getNpcShopSkuDefByIdx(i-1)
		if skuinfo.iLeftCount > 0 then
			table.insert(gListData, skuinfo)
		else
			table.insert(gListData, idx, skuinfo)
			idx = idx + 1
		end
	end

	local list = getglobal("NpcShopFrameShopBox")
	list:initData(1000, 400, 3, 2)
	if bNeedRefresh then list:setCurOffsetY(0) end
end

function NpcShopFrameShopBox_tableCellAtIndex(tableview, idx)
	local cell, uiidx = tableview:dequeueCell(0)

	local skuinfo = gListData[idx+1]
	if not cell then
		cell = UIFrameMgr:CreateFrameByTemplate("Button", "NpcShopFrameShopBoxItem" .. uiidx, "NpcShopListItemTemplate", "NpcShopFrameShopBox")
	else
		cell:Show()
	end

	cell:SetClientUserData(0, skuinfo.iSkuID)
	setListItemData(cell:GetName(), skuinfo)

	return cell
end

function NpcShopFrameShopBox_numberOfCellsInTableView(tableview)
	return #gListData
end

function NpcShopFrameShopBox_tableCellSizeForIndex(tableview, idx)
	local colidx = math.mod(idx, 2)

	return (494+10)*colidx, 10, 494, 160
end

function NpcShopFrameShopBox_tableCellTouched(tableview, cell)
	if not cell then return end
	gCurrentClickSkuId = cell:GetClientUserData(0)

	-- 该商品已售罄
	local parentstr = cell:GetName()
	if cell then
		local bg = getglobal(parentstr .. "Bkg")
		if bg and bg:IsGray() then
			ShowGameTips(GetS(21720), 3);
			return
		end
	end

	getglobal("NpcShopBuyFrame"):Show()
end

function NpcShopFrameShopBox_tableCellWillRecycle(tableview, cell)
	if cell then cell:Hide() end
end

function setListItemData(itemname, data)
	-- body
	local parentstr = itemname
	local itemDef = ItemDefCsv:getAutoUseForeignID(data.iItemID);
	if not itemDef then
		itemDef = ItemDefCsv:getAutoUseForeignID(101);
	end

	local isGray = (data.iLeftCount == 0)
	local bg = getglobal(parentstr .. "Bkg")
	bg:SetGray(isGray)

	local iconBg = getglobal(parentstr .. "IconBkg")
	iconBg:SetGray(isGray)

	local saleIcon = getglobal(parentstr .. "SaleIcon")
	SetItemIcon(saleIcon, itemDef.ID);
	saleIcon:SetGray(isGray)

	local itemName = getglobal(parentstr .. "SalenameLabel")
	local itemDesc = getglobal(parentstr .. "SaledescLabel")
	itemName:SetText(itemDef.Name.."*"..tostring(data.iOnceBuyNum))
	itemDesc:SetText(itemDef.Desc.."\n"..itemDef.GetWay, 152, 108, 85)
	itemDesc:setInputTransparent(true)

	local saleOutFlag = getglobal(parentstr .. "SaleOutFlag")
	local refreshCountDown = getglobal(parentstr .. "RefreshCountDown")
	local saleLeftNumLab = getglobal(parentstr .. "SaleleftnumLabel")
	local noBuyLimit = (data.iLeftCount > 300)
	if noBuyLimit then
		saleLeftNumLab:Hide()
	else
		saleLeftNumLab:Show()
		saleLeftNumLab:SetText(GetS(21719, data.iLeftCount));
	end

	saleOutFlag:Hide()
	refreshCountDown:Hide()

	local nowTime = getServerTime()
	if isGray then
		if data.iRefreshDuration == 0 then
			saleOutFlag:Show()
		elseif data.iRefreshDuration > 0 and data.iEndTime > nowTime and not noBuyLimit then
			gNeedRefreshList[data.iSkuID] = {key = parentstr, endTime = data.iEndTime}
			refreshCountDown:Show()
			manageCountDown(data.iSkuID, gNeedRefreshList[data.iSkuID])
		end
		saleLeftNumLab:SetTextColor(230, 47, 47)
	else
		if data.iRefreshDuration > 0 and data.iEndTime > nowTime and not noBuyLimit then
			gNeedRefreshList[data.iSkuID] = {key = parentstr, endTime = data.iEndTime}
			refreshCountDown:Show()
			manageCountDown(data.iSkuID, gNeedRefreshList[data.iSkuID])
		end
		saleLeftNumLab:SetTextColor(21, 168, 21)
	end

	local costItem
	local costnum = 0
	local costlist = {}
	if data.iStarNum > 0 then
		costnum = costnum + 1
		table.insert(costlist, {itemid = 0, itemnum = data.iStarNum})
	end

	if data.iCostItemInfo1 > 0 then
		costnum = costnum + 1
		table.insert(costlist, {itemid = math.floor(data.iCostItemInfo1/1000), itemnum = data.iCostItemInfo1%1000})
	end

	if data.iCostItemInfo2 > 0 then
		costnum = costnum + 1
		table.insert(costlist, {itemid = math.floor(data.iCostItemInfo2/1000), itemnum = data.iCostItemInfo2%1000})
	end

	local costidx = 1
	local width = 0
	local offsetx = -10
	for i=costnum,1,-1 do
		parentstr = itemname .. "CostItem" ..i
		costItem = setCostItemInfo(parentstr, false, costlist[i].itemid, costlist[i].itemnum, 1)
		if costItem then
			width = costItem:GetWidth()
			costItem:SetPoint("Bottomright", itemname.."Bkg", "Bottomright", offsetx, -10)
			offsetx = offsetx-width-5
		end
	end

	for i=costnum+1,3 do
		parentstr = itemname .. "CostItem" ..i
		setCostItemInfo(parentstr, true)
	end
end

function recoverShopSku(skuid, addnum, parentstr)
	-- body
	local skuinfo = gCurNpcShopInfo:getNpcShopSkuDef(skuid)
	if not skuinfo then return end
	local bNeedRefresh = (skuinfo.iLeftCount == 0)
	if skuinfo.iLeftCount + addnum > skuinfo.iMaxCanBuyCount then
		skuinfo.iLeftCount = skuinfo.iMaxCanBuyCount
		skuinfo.iEndTime = 0
	else
		if IsUIFrameShown("NpcShopBuyFrame") then
		else
			skuinfo.iLeftCount = skuinfo.iLeftCount + addnum
		end
		skuinfo.iEndTime = getServerTime()+skuinfo.iRefreshDuration
	end

	if gNeedRefreshList[skuid] ~= nil then
		if skuinfo.iEndTime == 0 then
			gNeedRefreshList[skuid] = nil
		else
			gNeedRefreshList[skuid].endTime = skuinfo.iEndTime
		end
	end

	local saleLeftNumLab = getglobal(parentstr .. "SaleleftnumLabel")
	saleLeftNumLab:SetText(GetS(21719, skuinfo.iLeftCount));
	saleLeftNumLab:SetTextColor(21, 168, 21)

	local countdownLab = getglobal(parentstr .. "RefreshCountDown")
	if skuinfo.iEndTime > 0 then
		countdownLab:Show()
	else
		countdownLab:Hide()
	end

	local bg = getglobal(parentstr .. "Bkg")
	bg:SetGray(false)

	local iconBg = getglobal(parentstr .. "IconBkg")
	iconBg:SetGray(false)

	local saleIcon = getglobal(parentstr .. "SaleIcon")
	saleIcon:SetGray(false)

	if bNeedRefresh then updateList() end

	return skuinfo.iEndTime
end

function manageCountDown(skuid, data)
	-- body
	local nowTime = getServerTime();
	if data == nil or nowTime > data.endTime then return end

	local isEnd, countdown = getCountDown(data.endTime)
	local countDownLabel = getglobal(data.key.."RefreshCountDownCountDown");
	countDownLabel:SetText(countdown);

	if isEnd then
		recoverShopSku(skuid, 1, data.key)
	end
end

-- listitemidx is NpcShopFrameShopBoxItem's idx; 
-- idx is cost item idx
function setCostItemInfo(parentstr, bHide, itemid, itemnum, selectnum)
	-- body
	local costItem = getglobal(parentstr)
	if not costItem then
		return nil
	elseif bHide then
		costItem:Hide()
		return nil
	end

	local ownnum = 0
	local neednum = itemnum
	selectnum = (selectnum == nil and 1 or selectnum)

	local itemIcon = getglobal(parentstr .. "ItemIcon")
	if itemid == 0 then
		ownnum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO)
		itemIcon:SetTexture("items/icon14001.png")
	else
		local def = ItemDefCsv:getAutoUseForeignID(itemid)
		itemid = def and def.ID or 101
		ownnum = ClientBackpack:getItemCountInNormalPack(itemid)
		SetItemIcon(itemIcon, itemid);
	end

	local maxcanbuynum = 0
	local color = "#c15a815"
	if neednum > ownnum then
		color = "#ce62f2f"
	else
		if itemnum ~= 0 then
			maxcanbuynum = math.floor(ownnum/itemnum)
		end
	end

	neednum = selectnum * neednum
	if ownnum > 999 then ownnum = "999+" end
	if neednum > 999 then neednum = "999+" end
	local numLab = getglobal(parentstr .. "IconNumLabel");
	numLab:SetText(color..ownnum.."#n".."/"..neednum, 152, 108, 85)

	local width = itemIcon:GetWidth()+numLab:GetTextExtentWidth(""..ownnum.."/"..neednum)+3
	costItem:SetWidth(width)
	costItem:Show()

	return costItem, maxcanbuynum
end

-- for NpcShopBuyFrame panel
local gSelectNum = 1
local gMaxNum = 1
local gMaxCanBuyNum = 0
local gCurBuyItemNum = 0
local gEndTime = 0
local gCurCostList = {}
local gIsNormalClose = false
function NpcShopBuyFrame_OnLoad()
	-- body
	this:setUpdateTime(1);
	local btnNameLab = getglobal("NpcShopBuyFrameBuyBtnText")
	btnNameLab:SetText(GetS(3045));

	local titleLab = getglobal("NpcShopBuyFrameTitle")
	titleLab:SetText(GetS(21712))

	local tipsLab = getglobal("NpcShopBuyFrameBuyTips")
	tipsLab:SetText(GetS(21722))

	local refreshLab = getglobal("NpcShopBuyFrameRefreshtipsLabel")
	refreshLab:SetText(GetS(578)..":")
	refreshLab:SetWidth(refreshLab:GetTextExtentWidth(GetS(578)..":")+2)

	local countdown = getglobal("NpcShopBuyFrameRefreshCountLabel")
	countdown:SetPoint("left", "NpcShopBuyFrameRefreshtipsLabel", "right", 5, 0)
end

function NpcShopBuyFrameCloseBtn_OnClick()
	gIsNormalClose = true
	gCurrentClickSkuId = -1
	getglobal("NpcShopBuyFrame"):Hide();
end

function NpcShopBuyFrameBuyBtn_OnClick()
	-- body
	local pSucceed = false
	if checkIfCanBuySku(gSelectNum) then
		local skuinfo = gCurNpcShopInfo:getNpcShopSkuDef(gCurrentClickSkuId)
		if not skuinfo then return end

		gCurBuyItemNum = skuinfo.iOnceBuyNum*gSelectNum
		local itemid = skuinfo.iItemID
		local def = ItemDefCsv:getAutoUseForeignID(itemid)
		itemid = def and def.ID or 101
		local maxnum = ClientBackpack:enoughGridForItemMaxNum(itemid, gCurBuyItemNum)
		if maxnum > 0 then
			if maxnum < skuinfo.iOnceBuyNum*gSelectNum then
				gCurBuyItemNum = maxnum
			end

			CurMainPlayer:reqBuyNpcShopSku(gCurNpcShopInfo.iShopID, gCurrentClickSkuId, math.floor(gCurBuyItemNum/skuinfo.iOnceBuyNum))
			pSucceed = true
		else
			ShowGameTips(GetS(21733), 3);
		end
	else
		ShowGameTips(GetS(21723), 3);
	end
	--新埋点
	local s2 = nil
	local index = 0
	for i,v in ipairs(gCurCostList) do
		local itemid = v.itemid
		local def = ItemDefCsv:getAutoUseForeignID(itemid)
		itemid = def and def.ID or 101
		if (0 == index) then 
			s2 = tostring(itemid)
		else
			s2 = "_" .. tostring(itemid)
		end
	end
	local mapId = G_GetFromMapid()
	standReportEvent("1011", "PROP_DETAILS", "PurchaseButton", "click", { cid = tostring(mapId), standby1 = tostring(gSelectNum), standby2 = s2})
	if pSucceed then
		standReportEvent("1011", "PROP_DETAILS", "PurchaseButton", "purchase_succeed", { cid = tostring(mapId), standby1 = tostring(gSelectNum), standby2 = s2})
	else
		standReportEvent("1011", "PROP_DETAILS", "PurchaseButton", "purchase_failed", { cid = tostring(mapId), standby1 = tostring(gSelectNum), standby2 = s2})
	end
end

function NpcShopBuyFrameMinusBtn_OnClick()
	-- body
	if gSelectNum <= 1 then return end

	gSelectNum = gSelectNum - 1
	loadInfo(false)
end

function NpcShopBuyFramePlusBtn_OnClick()
	-- body
	if gSelectNum >= gMaxNum then return end
	
	gSelectNum = gSelectNum + 1
	loadInfo(false)
end

function NpcShopBuyFrameMaxBtn_OnClick()
	-- body
	gSelectNum = gMaxNum
	loadInfo(false)
end

function NpcShopBuyFrame_OnShow()
	-- body
	getglobal("NpcShopFrameShopBox"):setDealMsg(false)
	gSelectNum = 1
	
	loadInfo(true)
end

function NpcShopBuyFrame_OnHide()
	-- body
	gEndTime = 0
	getglobal("NpcShopFrameShopBox"):setDealMsg(true)

	if not gIsNormalClose then
		updateList()
	end
	gIsNormalClose = false

	--新埋点
	local mapId = G_GetFromMapid()
	standReportEvent("1011", "PROP_DETAILS", "Close", "click",{ cid = tostring(mapId)})
end

function NpcShopBuyFrame_OnUpdate()
	-- body
	local nowTime = getServerTime();
	if nowTime > gEndTime then return end

	local isEnd, countdown = getCountDown(gEndTime)
	local countDownLabel = getglobal("NpcShopBuyFrameRefreshCountLabel");
	countDownLabel:SetText(countdown);

	if isEnd then
		recoverSku(1)
	end
end

function getCountDown(endTime)
	-- body
	local leftTime = endTime - getServerTime();
	if leftTime <= 0 then
		return true, "00:00:00"
	end

	local countdown = ""
	local hour = math.floor(leftTime/3600)
	if hour < 10 then
		countdown = countdown.."0"..hour
	else
		countdown = countdown..hour
	end

	leftTime = leftTime - hour*3600
	if leftTime == 0 then
		return false, countdown..":00:00"
	end

	minute = math.floor(leftTime/60)
	if minute < 10 then
		countdown = countdown..":0"..minute
	else
		countdown = countdown..":"..minute
	end

	local seconds = leftTime - minute*60
	if seconds == 0 then
		return false, countdown..":00"
	end

	if seconds < 10 then
		countdown = countdown..":0"..seconds
	else
		countdown = countdown..":"..seconds
	end

	return false, countdown
end

function loadInfo(b_show)
	-- body
	local skuinfo = gCurNpcShopInfo:getNpcShopSkuDef(gCurrentClickSkuId)
	if not skuinfo then return end

	local itemDef = ItemDefCsv:getAutoUseForeignID(skuinfo.iItemID);
	if not itemDef then
		itemDef = ItemDefCsv:getAutoUseForeignID(101);
	end

	local itemIcon = getglobal("NpcShopBuyFrameSaleIcon")
	SetItemIcon(itemIcon, itemDef.ID)

	local itemName = getglobal("NpcShopBuyFrameSalenameLabel")
	itemName:SetText(itemDef.Name.."*"..tostring(skuinfo.iOnceBuyNum))

	local itemDesc = getglobal("NpcShopBuyFrameSaledescLabel")
	itemDesc:SetText(itemDef.Desc)

	local noBuyLimit = (skuinfo.iLeftCount > 300)
	local leftNumLab = getglobal("NpcShopBuyFrameSaleleftnumLabel")
	if noBuyLimit then
		leftNumLab:Hide()
	else
		local str = "#c15a815"..skuinfo.iLeftCount.."#n"
		leftNumLab:SetText(GetS(21719, str), 152, 108, 85);
		leftNumLab:Show()
	end

	local buyNumLab = getglobal("NpcShopBuyFrameBuyNumLabel")
	buyNumLab:SetText(""..gSelectNum)

	local countdownLab = getglobal("NpcShopBuyFrameRefreshCountLabel")
	gEndTime = skuinfo.iEndTime
	local nowTime = getServerTime()
	if gEndTime > nowTime and not noBuyLimit then
		countdownLab:Show()
		getglobal("NpcShopBuyFrameRefreshtipsLabel"):Show()
		NpcShopBuyFrame_OnUpdate()
	else
		countdownLab:Hide()
		getglobal("NpcShopBuyFrameRefreshtipsLabel"):Hide()
	end

	local costItem, parentstr;
	local x, y, align;
	local costnum = 0
	gCurCostList = {}
	if skuinfo.iStarNum > 0 then
		costnum = costnum + 1
		table.insert(gCurCostList, {itemid = 0, itemnum = skuinfo.iStarNum})
	end

	if skuinfo.iCostItemInfo1 > 0 then
		costnum = costnum + 1
		table.insert(gCurCostList, {itemid = math.floor(skuinfo.iCostItemInfo1/1000), itemnum = skuinfo.iCostItemInfo1%1000})
	end

	if skuinfo.iCostItemInfo2 > 0 then
		costnum = costnum + 1
		table.insert(gCurCostList, {itemid = math.floor(skuinfo.iCostItemInfo2/1000), itemnum = skuinfo.iCostItemInfo2%1000})
	end

	gMaxCanBuyNum = 1
	local maxcanbuynum = 0
	local costidx = 1
	for i,v in ipairs(gCurCostList) do
		parentstr = "NpcShopBuyFrameCostItem" .. costidx
		costItem, maxcanbuynum = setCostItemInfo(parentstr, false, v.itemid, v.itemnum, gSelectNum)
		align, y, x = getPosAndAlign(costnum, costidx)
		if costItem then
			costItem:SetPoint(align, "NpcShopBuyFrameBuyBkg", "center", x, y)
		end
		costidx = costidx + 1
		if i == 1 then
			gMaxCanBuyNum = maxcanbuynum
		elseif maxcanbuynum < gMaxCanBuyNum then
			gMaxCanBuyNum = maxcanbuynum
		end
	end
	if isBuyItemSame() then
		local ownnum = ClientBackpack:getItemCountInNormalPack(gCurCostList[1].itemid)
		local num1 = getCurCostListNum(1)
		local num2 = getCurCostListNum(2)
		local itemnum = (num1*gSelectNum + num2*gSelectNum)
		gMaxCanBuyNum = math.floor(ownnum/itemnum)
	end

	for i=costidx,3 do
		parentstr = "NpcShopBuyFrameCostItem" ..i
		setCostItemInfo(parentstr, true)
	end

	local leftCount = skuinfo.iLeftCount
	if costidx == 1 then
		local num = skuinfo.iOnceBuyNum
		if noBuyLimit then
			if num == 0 then num = 1 end
			maxcanbuynum = ClientBackpack:enoughGridForItemMaxNum(itemDef.ID, itemDef.StackMax*38)
			gMaxCanBuyNum = math.floor(maxcanbuynum/num)
			leftCount = gMaxCanBuyNum
		else
			local maxnum = skuinfo.iMaxCanBuyCount <= 0 and 1 or skuinfo.iMaxCanBuyCount
			maxcanbuynum = ClientBackpack:enoughGridForItemMaxNum(itemDef.ID, itemDef.StackMax*38)
			gMaxCanBuyNum = math.min(maxnum, math.floor(maxcanbuynum/num))
		end
	end

	if leftCount <= 0 then leftCount = 1 end
	gMaxCanBuyNum = math.max(gMaxCanBuyNum, 1)
	gMaxNum = math.min(leftCount, gMaxCanBuyNum)
	gEndTime = noBuyLimit and 0 or skuinfo.iEndTime

	local buyBtn = getglobal("NpcShopBuyFrameBuyBtn")
	local adBtn = getglobal("NpcShopBuyFrameADBtn")
	local isShowAD = false
	if skuinfo.iShowAD and skuinfo.iShowAD == 1 then
		isShowAD = true
	end
	if isShowAD and check_apiid_ver_conditions(ns_version.npcShopShowSwitch) and ClientMgr:getApiId() ~= 110 then--官包PC也不能显示
		adBtn:Show()
		buyBtn:SetPoint("Bottom", "NpcShopBuyFrameBkg", "Bottom", -127, -18)
	else
		adBtn:Hide()
		buyBtn:SetPoint("Bottom", "NpcShopBuyFrameBkg", "Bottom", 0, -18)
	end

	if b_show then--是否是打开界面(false为刷新界面)
		--新埋点
		local worldDesc = AccountManager:getCurWorldDesc()
		local mapId = G_GetFromMapid()
		local param = nil
		local isOwnMap = 2--是否自己的地图 （1自己的地图 2别人的地图）
   		if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
			if worldDesc.realowneruin == AccountManager:getUin() then
				isOwnMap = 1
			end
   		end
		local s1 = tostring(isOwnMap)
		local stanby1_2 = 0
		if AccountManager:getMultiPlayer() == 0 then
			-- 单机
			stanby1_2 = 1
		else				
			if IsArchiveMapCollaborationMode() then					
				-- 好友协作模式
				stanby1_2 = 3
			else
				-- 普通联机
				stanby1_2 = 2
			end
		end
		standReportEvent("1011", "PROP_DETAILS", "-", "view",{ standby1 = s1..tostring(stanby1_2)})
		standReportEvent("1011", "PROP_DETAILS", "Close", "view",{ cid = tostring(mapId)})
		standReportEvent("1011", "PROP_DETAILS", "PurchaseButton", "view",{ cid = tostring(mapId), standby1 = gSelectNum, standby2 = gSelectNum})
		if isShowAD then
			standReportEvent("1011", "PROP_DETAILS", "AdPurchaseButton", "view",{ cid = tostring(mapId), standby1 = 109})
			StatisticsAD('show', 109);
		end
	end
end

function NpcShopBuyFrameADBtn_OnClick()
	--是否自动提取
	local mapId = G_GetFromMapid()
	StatisticsAD('onclick', 109);
	standReportEvent("1011", "PROP_DETAILS", "AdPurchaseButton", "click",{ cid = tostring(mapId), standby1 = 109})
	NpcShopItemADBtn();
end

function NpcShopItemADBtn()--这个参数是给外部调用传入的，自己界面取自己的参数
	-- 鸿蒙渠道
	if ClientMgr and ClientMgr:getApiId() == 5 then
		ShowGameTips(GetS(100512), 3)
		return
	end
	local skuinfo = gCurNpcShopInfo:getNpcShopSkuDef(gCurrentClickSkuId)
	if not skuinfo then return end
	local isShowAD = false
	if skuinfo.iShowAD and skuinfo.iShowAD == 1 then
		isShowAD = true
	end
	if isShowAD and check_apiid_ver_conditions(ns_version.npcShopShowSwitch) and ClientMgr:getApiId() ~= 110 then--官包PC也不能显示

	else
		return
	end

	if WatchADNetworkTips(OnReqWatchADNpcShop) then
		OnReqWatchADNpcShop(nil,nil);
	end
end

function NpcShopAdGetItem()
	local skuinfo = gCurNpcShopInfo:getNpcShopSkuDef(gCurrentClickSkuId)
	if not skuinfo then return end
	local isShowAD = false
	if skuinfo.iShowAD and skuinfo.iShowAD == 1 then
		isShowAD = true
	end
	if isShowAD and check_apiid_ver_conditions(ns_version.npcShopShowSwitch) and ClientMgr:getApiId() ~= 110 then--官包PC也不能显示

	else
		return
	end
	local itemID = skuinfo.iItemID
	local itemNum = skuinfo.iOnceBuyNum*gSelectNum
	local itemDef = ItemDefCsv:getAutoUseForeignID(itemID);
	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then	--单机或者房主				
		if CurMainPlayer and ClientCurGame and ClientCurGame:isInGame() then
			CurMainPlayer:gainItems(itemID, itemNum);
			if not itemDef then return end
			ShowGameTips(GetS(21732, itemDef.Name, itemNum), 3);
		end 
	else
		print('new extract player');
		if CurMainPlayer  and ClientCurGame and ClientCurGame:isInGame() then 
			local playerid = CurMainPlayer and CurMainPlayer:getUin()
			DoSSTaskNpcShopGoodsGet(playerid,itemID);
			if not itemDef then return end
			ShowGameTips(GetS(21732, itemDef.Name, itemNum), 3);
		end
	end

	
	local mapId = 0;
	local authorUin = 0;
	local mapversion = 0;
	if ishost then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		mapId = wdesc.fromowid;
		authorUin = getFromOwid(wdesc.fromowid);
		mapversion = wdesc.shareVersion
		if wdesc.fromowid == 0 then
			mapId = wdesc.worldid;
			authorUin = AccountManager:getUin()
		end
	else
		mapId = DeveloperFromOwid;
		authorUin = getFromOwid(mapId)
	end
	StatisticsAD('finish', 109,nil,authorUin,mapId, itemID)			
	local finish_info = {
		map_Id  = mapId,
		map_version = mapversion,
		item_Id = itemID,
		item_name = itemDef.Name,
		item_num = itemNum,
		auth_uin = authorUin,
	}
	AccountManager:ad_finish(109,finish_info);
end

function recoverSku(addnum)
	-- body
	local skuinfo = gCurNpcShopInfo:getNpcShopSkuDef(gCurrentClickSkuId)
	if not skuinfo then return end

	if skuinfo.iLeftCount + addnum > skuinfo.iMaxCanBuyCount then
		skuinfo.iLeftCount = skuinfo.iMaxCanBuyCount
		skuinfo.iEndTime = 0
	else
		skuinfo.iLeftCount = skuinfo.iLeftCount + addnum
		skuinfo.iEndTime = getServerTime()+skuinfo.iRefreshDuration
	end

	gMaxNum = math.min(skuinfo.iLeftCount, gMaxCanBuyNum)
	gEndTime = skuinfo.iEndTime

	local leftNumLab = getglobal("NpcShopBuyFrameSaleleftnumLabel")
	-- leftNumLab:SetText(""..skuinfo.iLeftCount)
	local str = "#c15a815"..skuinfo.iLeftCount.."#n"
	leftNumLab:SetText(GetS(21719, str), 152, 108, 85);

	local countdownLab = getglobal("NpcShopBuyFrameRefreshCountLabel")
	if gEndTime > 0 then
		countdownLab:Show()
		getglobal("NpcShopBuyFrameRefreshtipsLabel"):Show()
	else
		countdownLab:Hide()
		getglobal("NpcShopBuyFrameRefreshtipsLabel"):Hide()
	end

end

function getPosAndAlign(size, idx)
	-- body
	local align = "right"
	local x = 0
	local y = 50
	if size == 1 then
		align = "center"
	elseif size == 2 then
		if idx == 2 then
			align = "left"
			x = 10
		else
			x = -10
		end
	else
		if idx == 1 then
			x = -10
		elseif idx == 2 then
			align = "left"
			x = 10
		elseif idx == 3 then
			align = "center"
			y = 90
		end
	end

	return align, y, x
end

function isBuyItemSame()
	if #gCurCostList > 1 then
		if gCurCostList[1].itemid == gCurCostList[2].itemid and gCurCostList[1].itemid > 0 then
			return true
		end
	end
	return false
end

function getCurCostListNum(index)
	if index <= #gCurCostList then
		local itemid = gCurCostList[index].itemid
		local def = ItemDefCsv:getAutoUseForeignID(itemid)
		itemid = def and def.ID or 101
		return gCurCostList[index].itemnum
	end
	return 0
end

function checkIfCanBuySku(selectnum)
	-- body
	local isCanBuy = true
	local ownnum = 0
	for i,v in ipairs(gCurCostList) do
		if v.itemid == 0 then
			ownnum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO)
		else
			local itemid = v.itemid
			local def = ItemDefCsv:getAutoUseForeignID(itemid)
			itemid = def and def.ID or 101
			ownnum = ClientBackpack:getItemCountInNormalPack(itemid)
		end

		if v.itemnum*selectnum > ownnum then
			isCanBuy = false
			break
		end
	end
	if #gCurCostList > 1 then
		if isBuyItemSame() and isCanBuy then
			ownnum = ClientBackpack:getItemCountInNormalPack(gCurCostList[1].itemid)
			local num1 = getCurCostListNum(1)
			local num2 = getCurCostListNum(2)
			if (num1*selectnum + num2*selectnum) > ownnum then
				isCanBuy = false
			end
		end
	end
	return isCanBuy
end

function notifyBuyResult(ret)
	-- body
	if ret == 0 then
		local skuinfo = gCurNpcShopInfo:getNpcShopSkuDef(gCurrentClickSkuId)
		if not skuinfo then return end
		local itemDef = ItemDefCsv:getAutoUseForeignID(skuinfo.iItemID);
		if not itemDef then return end

		if gCurBuyItemNum == skuinfo.iOnceBuyNum*gSelectNum then
			ShowGameTips(GetS(21732, itemDef.Name, gCurBuyItemNum), 3);
		else
			ShowGameTips(GetS(21731, itemDef.Name, gCurBuyItemNum), 3);
		end
		getglobal("NpcShopBuyFrame"):Hide();
	else
		loadInfo(false)
		ShowGameTips(GetS(9286), 3);
	end
end