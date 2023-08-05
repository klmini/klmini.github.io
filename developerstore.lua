DeveloperFromOwid = 0

g_IsFirstOpenDeveloperStore = true;   --是否在地图内第一次打开开发者商城
g_IsFirstOpenDeveloperstash = true;   --是否在地图内第一次打开开发者仓库
g_DeveloperConfig = _G.g_enum_comm
--print("-------------g_DeveloperConfig------------",g_DeveloperConfig)
local DeveloperMiniPointDataGuard = 0 --容灾模式 0:关 1:开
--容灾模式
--选择了迷你币+广告币的组合模式开发者，需将广告币选项位，覆盖替换为单次广告播放模式
--选择广告币+单次广告模式的开发者，需将广告币[Desc5]的按钮进行隐藏，仅保留单次播放广告模式；
local PropItemNumberMax = 200   --最大prop数量
local PropItemNumber = 5      --prop数量
local SwapBtnSwich = 0        --标识交换item开关
-- local UserClickPropNumber = 0  --标识用户点击的prop -- 改成GetInst("DevelopStoreDataManager"):GetUserClickPropNumber()
local UserClickStashItemNumber = 0 --标识用户点击的仓库Item
local DeveloperStashMaxNum = 128  --仓库商品最大数量

local  DeveloperMaxOriginalBlockNum = 603 --选择物品格子最大数
local CurSelectType = 1;
local CurEditorUIName = "DeveloperStoreItemSetFrameSelectItemBtn"

local CurSelectPropValue = 0       --当前选择的开发者道具价格
local CurSelectPropTag = g_DeveloperConfig.Developer.TagType.None         --当前选择的开发者道具标签           （1无 2热销 3新品 4推荐 5爆款 6限时 7折扣）
local CurSelectPropCurrencyType = g_DeveloperConfig.Developer.CurrencyType.Coin --当前选择的开发者货币类型   (Bean迷你豆 JEWEL迷你币)
local CurSelectADExchange = 0				--当前选择的广告模式，0表示关闭，1表示播放
local CurSelectPropTimeLimit = 0			--7天30天60天90天
local CurSelectPropDiscount = 999			--选中物品的折扣价格
local CurSelectPropMiniPointValue = 0       --当前选择的开发者道具迷你点价格

-- local IsSelectAddPropBtn = false   -- false 没选择 true 选择 改成GetInst("DevelopStoreDataManager"):GetIsSelectAddPropBtn()
local BuyPropIndex = 0             --玩家[Desc5]道具的索引

-- local UserLevel = 0; -- 改成GetInst("DevelopStoreDataManager"):GetUserLevel()


local isFirstClickMoneyLable = false;    --是否第一次点击货币标签
local isFirstClickItemLable = false;	--是否第一次点击商品标签

local CurInputNumberVal = 1;             --玩家输入的提取道具数量

local isExtract = false;				--是否自动提取

local isBagExtract = false; 

local t_SelectTypesId = {

		item={[1]=4800, [2]=4801, [3]=4802, [4]=4803, [5]=4544, [6]=3128},

}

local ItemGroupID2Name = {
	[1] = GetS(23047),
	[2] = GetS(23012),
	[3] = GetS(23013),
	[4] = GetS(23014),
	[5] = GetS(23015),
	[6] = GetS(23016),
	[7] = GetS(23017),
	[8] = GetS(23018),
	[9] = GetS(23019),
	[10] = GetS(23020),
}

local OldItemGroupID2Name = 
{
	[1] = GetS(427),
	[2] = GetS(23012),
	[3] = GetS(23013),
	[4] = GetS(23014),
	[5] = GetS(23015),
	[6] = GetS(23016),
	[7] = GetS(23017),
	[8] = GetS(23018),
	[9] = GetS(23019),
	[10] = GetS(23020),
}

--滑动组件上报(滑动组件导致不会一次性显示所有按钮，玩家滑动时将显示新按钮，则已上报不再上报，滑动导致显示新按钮则上报新按钮的view状态，这个table记录已经上报过的按钮)
--商品类型按钮的显示上报(已显示的不再重复上报)
local PropTypeStandReportState={}
--和ItemGroupID2Name对应，商品类型按钮，只是用来作为埋点上报的组件id，参考文档https://mini1.feishu.cn/sheets/shtcnANXtZdjfIfgr9p8bYpBtWA
local ItemGroupID2StandReportKey = {
	[1] = "AllContent",--综合
	[2] = "WeaponContent",
	[3] = "EquipmentContent",
	[4] = "FoodContent",
	[5] = "PropContent",
	[6] = "ConsumablesContent",
	[7] = "OtherContent",
	[8] = "MountContent",
	[9] = "ToolContent",
	[10] = "GiftContent",
}

--参考上面的的滑动组件上报，但商品项是分类的，故这是一个二级表。第一级是类型，第二级才是已上报过的商品项
local PropItemsStandReportState={}
--同样对应，只是用来标识商品类型面板id,参考文档https://mini1.feishu.cn/sheets/shtcnANXtZdjfIfgr9p8bYpBtWA
local ItemGroupID2StandReportKeyForContainer = {
	[1] = "DEVELOPER_SHOP_ALL",--综合
	[2] = "DEVELOPER_SHOP_WEAPON",
	[3] = "DEVELOPER_SHOP_EQUIPMENT",
	[4] = "DEVELOPER_SHOP_FOOD",
	[5] = "DEVELOPER_SHOP_PROP",
	[6] = "DEVELOPER_SHOP_CONSUMABLES",
	[7] = "DEVELOPER_SHOP_OTHER",
	[8] = "DEVELOPER_SHOP_MOUNT",
	[9] = "DEVELOPER_SHOP_TOOL",
	[10] = "DEVELOPER_SHOP_GIFT",
}

--开发者商店分组结构
-- local StoreGroupType = {
-- 	GroupID = 1,   --分组ID
-- 	Pos = 1,	   --位置
-- 	GroupName = "",--分组名称
-- }

--开发者的所有分组信息(此处是一个Map)
-- local StoreGroupTypeMap = {}--[GroupID, StoreGroupType] -- 改成GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMap()
-- local GroupType_MaxNum = 16 -- 改成GetInst("DevelopStoreDataManager"):GetGroupTypeMaxNum()
local CurGroupTypeID = 1
local IsNeedUpload = false

-- local DeveloperPropAttr = { -- 改成GetInst("DevelopStoreDataManager"):GetDeveloperPropAttr()
--  	Name = '', --物品名称
--  	Desc = '', --物品描述
-- 	ItemID = 12831,  -- 物品ID,
-- 	ItemGroup = 1, --物品GroupID,默认是综合分类
--   	CostType = g_DeveloperConfig.Developer.CurrencyType.Money, -- 货币类型 1 迷你币 2 迷你豆,
--   	CostNum = 999,  -- 物品价格, 单个加个
--   	Tag = g_DeveloperConfig.Developer.TagType.None,  -- 标签
-- 	ADExchange = 0, --ADExchange = 0 关闭广告 1 开启广告
-- 	LimitEnd = 9999,--道具设置的限时
-- 	LimitStart = 0,--道具开始限时时间
-- 	PropCurTime = 9999,
-- 	DiscountCostNum = 999,--折扣价格
-- 	RealPos = 1,--真实位置
-- }

-- local DeleteDeveloperPropListTemp = {} --存储需要删除商品的临时表 GetInst("DevelopStoreDataManager"):GetDeleteDeveloperPropListTemp()
local DeleteGruopTemp = {} --存储需要删除条目

-- local DeveloperPropList = {}  --这里是用来显示分类用的 -- 改成GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
-- local StoreSkuList = {} --玩家商城商品表 -- 改成GetInst("DevelopStoreDataManager"):GetStoreSkuList()
local DeveloperPropInfo = {
 	Name = '', --物品名称
 	Desc = '', --物品描述
	ItemID = 12831,  -- 物品ID,
	ItemGroup = 1, --物品GroupID,默认是综合分类
  	CostType = g_DeveloperConfig.Developer.CurrencyType.Money, -- 货币类型 1 迷你币 2 迷你豆,
  	CostNum = 999,  -- 物品价格, 单个加个
  	Tag = 'xxx',  -- 标签
	ADExchange = 0, --ADExchange = 0 关闭广告 1 开启广告
	LimitEnd = 9999,--道具设置的限时
	DiscountCostNum = 999,--折扣价格
} --玩家商城Info表


local DeveloperStashPropList = {}   --商城仓库prop表
local gPassPortInfo = {[1]=7, [2]=7, [3]=7, [4]=7}

local DeveloperOriginalInfo = {}     --插件Item表
local DeveloperItemsInfo = {}


local CheckedOBName = nil;

local DeveloperUserInfo = {}

local CurItemAuthUin = 0
local CurItemMapId = 0
local CurItemId = 0
local WelfareChoose = false

local DevConfig = loadwwwcache('res.Developer')
local NotEnoughCoinDataName = nil --记录不够迷你币[Desc5]物品所需的[Desc2]档位 埋点用
local rechargeAmount = 0 -- 记录充值金额

function NoNetworkEnterDeveloperStore()
	-- for i=1,PropItemNumberMax do
	-- 	getglobal("DeveloperStoreFramePropBoxPropItem"..i):Hide();
	-- end

	-- for i=1,128 do
	-- 	getglobal("DeveloperStashItem"..i):Hide();
	-- end
	local listview = getglobal("DeveloperStoreSkuFrameList")
	listview:Hide()

	getglobal("DeveloperStoreSkuFrameHead"):Show()
	getglobal("DeveloperStoreSkuFrameTxt"):Show()
	getglobal("DeveloperStoreSkuFrameStashBtn"):Disable()

	standReportEvent("60", "DEVELOPER_SHOP_CONTAINER", "Warehouse", "view", {standby1 = 2})
end

function DoUpateStoreItem(authorUin, mapId, ids, initData, callback)
	--先用本地数据 初始化
	if initData and type(initData) == "table" and next(initData) then
		local stockList = GetInst("DevelopStoreDataManager"):GetStoreSkuExtInfoListByMapId(mapId)
		for k, v in pairs(initData) do
			--没有缓存数据
			if v.LimitTimeSaleNum and v.LimitTimeSaleNum > 0 and not stockList[v.ItemID] then
				GetInst("DevelopStoreDataManager"):UpdateStoreSkuExtInfo(mapId, v.ItemID, v.LimitTimeSaleNum)
			end
		end
	end

	GetInst("CreationCenterHomeService"):ReqUpateStoreItem(authorUin, mapId, ids, function(ret) 
		print("lwtaoP ReqUpateStoreItem retData", ret)
		if ret then
			GetInst("DevelopStoreDataManager"):UpdateStoreSkuExtInfoList(ret.mapid, ret.data) --更新剩余数量
		end

		if callback then
			callback()
		end
	end)
end

function LoadDeveloperPropList(donotrefresh)
	local mapId = 0;
	local authorUin = 0;

	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		if wdesc then
			mapId = wdesc.fromowid;
			authorUin = getFromOwid(wdesc.fromowid);
			if wdesc.fromowid == 0 then
				mapId = wdesc.worldid;
				authorUin = AccountManager:getUin()
			end
		end
	else
		mapId = DeveloperFromOwid;
		authorUin = getFromOwid(mapId)
	end

	local code = 1;
	local list = {};

	if not donotrefresh then
		local skus = DeveloperStoreGetItemlist(authorUin, mapId)
		if skus then
			DoUpateStoreItem(authorUin, mapId, nil, skus)

			GetInst("DevelopStoreDataManager"):SetStoreSkuList(skus)
			code = ErrorCode.OK
		else
			GetInst("DevelopStoreDataManager"):SetStoreSkuList(list)
			code = ErrorCode.OK
		end
		--code, list = AccountManager:dev_mapstore_get_itemlist(authorUin, mapId, false)
		--if code == ErrorCode.OK then
		--	StoreSkuList = list
		--end
	end

	if code == ErrorCode.OK or donotrefresh then
		local StoreSkuList = GetInst("DevelopStoreDataManager"):GetStoreSkuList()
		if gDeveloperStoreType == 2 then
			--玩法模式
			--Visible = 0, 				--0隐藏 1显示
			--Updown = 1,				--0下架 1上架
			local filterList = {}
			local svrTime = getServerNow()
			for i, v in pairs(StoreSkuList) do
				--为了兼容 没有该字段数据 默认显示和上架 才这么判断 
				if not (v.Visible == 0 or v.Updown == 0) then
					if v.Tag == g_DeveloperConfig.Developer.TagType.Timelimit then
						v.PropCurTime = v.LimitEnd - utils.ts2day(svrTime)
						if v.PropCurTime > 0 then
							table.insert(filterList, v)
						end
					else
						table.insert(filterList, v)
					end
				end
			end
	
			GetInst("DevelopStoreDataManager"):SetStoreSkuList(filterList)
		end

		StoreSkuList = GetInst("DevelopStoreDataManager"):GetStoreSkuList()
		for i=1, #StoreSkuList do --重置RealPos
			StoreSkuList[i].RealPos = i
		end

		GetInst("DevelopStoreDataManager"):SetDeveloperPropList(deep_copy_table(StoreSkuList))
		local DeveloperPropList = GetInst("DevelopStoreDataManager"):GetDeveloperPropList()

		local bRemoved = false
		local GroupID = gStoreGroupTypList[gSelectPropType]
		if not GroupID then
			GroupID = 1
		end

		for i=#DeveloperPropList, 1, -1 do
			bRemoved = false
			local v = DeveloperPropList[i]
			if v.ItemID == nil then
				table.remove(DeveloperPropList, i)
			elseif GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMapByScreen() and #gStoreGroupTypList == 0 then -- 如果没有分类标签，则不显示内容
				table.remove(DeveloperPropList, i)
			else
				if v.ItemID == ITEM_PASSPORT then
					if v.PassPortInfo and #v.PassPortInfo > 0 then
						for i=1,#v.PassPortInfo do
							gPassPortInfo[i] = v.PassPortInfo[i]
						end
					end
				end

				if GroupID > 1 then--只有除综合以外的才需要过滤
					if v.ItemGroup ~= GroupID then
						table.remove(DeveloperPropList, i)
						bRemoved = true
					end
				end

				if not bRemoved and CurWorld and CurWorld:isGameMakerRunMode() and v.Tag == g_DeveloperConfig.Developer.TagType.Timelimit then
					v.PropCurTime = v.LimitEnd - utils.ts2day(getServerNow())
					if v.PropCurTime <= 0 then
						table.remove(DeveloperPropList, i)
					end
				end
			end
		end

		if CurWorld and CurWorld:isGameMakerMode() then
			AdjustDeveloperStoreAuthorPropItem()
			UpdateDeveloperAuthorStoreProp()
		end
	else
		if CurWorld and CurWorld:isGameMakerMode() then
			NoNetworkEnterStore()
		else
			NoNetworkEnterDeveloperStore()
		end
	end
end

-- 左边按钮点击
function DeveloperStoreFrameLeftBtnTemplate_OnClick()
	local checked = getglobal("DeveloperStoreFrameLeftFrameBtn1Checked");

	if not checked:IsShown() then
		checked:Show();
	end
	DeveloperStoreFrame_LeftBtnState(1)
end

-- 左侧按钮状态
function DeveloperStoreFrame_LeftBtnState(id)
	Log("DeveloperStoreFrame_LeftBtnState: id = " .. id);

	if not getglobal("DeveloperStoreFrame"):IsShown() then
		getglobal("DeveloperStoreFrame"):Show();
	end
	local itemPage = getglobal("DeveloperStoreFrameProp");
	local stashPage = getglobal("DeveloperStoreFrameStash");
	local checked = getglobal("DeveloperStoreFrameLeftFrameBtn1Checked");
	local labelName = getglobal("DeveloperStoreFrameLeftFrameBtn1Name")

     -- 隐藏仓库界面
	if id ~= 0 then
		DeveloperStoreFrame_HideStashPage();
		itemPage:Show();
		labelName:SetTextColor(255,137,32)
	elseif id ~= 1 then
		if  checked:IsShown() then
			checked:Hide();
			itemPage:Hide();
		end
		stashPage:Show();
		labelName:SetTextColor(158,225,231)
	end
end

-- 隐藏仓库界面
function DeveloperStoreFrame_HideStashPage()
	local check = getglobal("DeveloperStoreFrameStashBtnChecked");
	local stashPage = getglobal("DeveloperStoreFrameStash");
	if check:IsShown() then
		check:Hide();
		stashPage:Hide();
	end
end

function LoadDeveloperStashPropList()
	DeveloperStashPropList = {};

	local mapId = 0;
	local authorUin = 0;

	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		mapId = wdesc.fromowid;
		authorUin = getFromOwid(wdesc.fromowid);
		if wdesc.fromowid == 0 then
			mapId = wdesc.worldid;
			authorUin = AccountManager:getUin()
		end
	else
		mapId = DeveloperFromOwid;
		authorUin = getFromOwid(mapId)
	end

	local code = 1;
	local list = {};
	--别的地图第一次打开仓库
	if g_IsFirstOpenDeveloperstash then
		code, list = AccountManager:dev_mapbag_get_itemlist(authorUin, mapId, true)
		g_IsFirstOpenDeveloperstash = false;
	else
		code, list = AccountManager:dev_mapbag_get_itemlist(authorUin, mapId, true)
	end

	if code == ErrorCode.OK then
		DeveloperStashPropList = list;
	end

	local numIndex = {};
	for i=1,#DeveloperStashPropList do
		if DeveloperStashPropList[i].ItemID == 10005 or DeveloperStashPropList[i].ItemID == 10006 or DeveloperStashPropList[i].ItemID == 10007
		 	or DeveloperStashPropList[i].ItemID == 10008 or DeveloperStashPropList[i].ItemID == ITEM_PASSPORT then
			table.insert(numIndex,i);
		end
	end

	for i=1,#numIndex do
		table.remove(DeveloperStashPropList,numIndex[i]);
	end

	-- 上报开发者仓库内容
	if CurMainPlayer and CurMainPlayer.UploadCheckInfo2Host then
		CurMainPlayer:UploadCheckInfo2Host(2, table2json(DeveloperStashPropList))
	end
end

function DeveloperExtractPropFrame_OnShow()
	getglobal("DeveloperStoreSkuFrameList"):setDealMsg(false);
end

function DeveloperExtractPropFrame_OnHide()
	UserClickStashItemNumber = 0;
	getglobal("DeveloperStoreSkuFrameList"):setDealMsg(true);

end

function DeveloperStoreExtractProp_OnClick()
	local index = this:GetClientUserData(0) --tonumber(string.sub(this:GetName(),19,-1))
	-- local redTag = getglobal(this:GetName().."RedTag");
	UserClickStashItemNumber = index;
	CurInputNumberVal = 1;
	getglobal("DeveloperExtractPropFrameNumberNameEdit"):SetText(1);
	DeveloperUpdateExtractItemFrame(index);
	getglobal("DeveloperExtractPropFrame"):Show();
end

function DeveloperExtractPropFrameCloseBtn_OnClick()
	getglobal("DeveloperExtractPropFrame"):Hide();
	getglobal("DeveloperStoreBuyItemFrameContentFrame"):Hide()
end

function DeveloperExtractPropFrameNumberNameEdit_OnFocusLost()
	-- if ClientMgr:isMobile() then
	if getglobal("DeveloperExtractPropFrame"):IsShown() then
    	CurInputNumberVal = ReplaceFilterString(this:GetText())

	    if not tonumber(CurInputNumberVal) then
	    	ShowGameTips(GetS(21673), 3);
	    else 


	    	this:SetText(CurInputNumberVal)
	    end
    end
	-- end
end

function DeveloperExtractPropFrameNumberNameEdit_OnTabPressed()
	SetCurEditBox("DeveloperExtractPropFrameNumberNameEdit");
	CurInputNumberVal = getglobal("SingleEditorFrameBaseSetCommonNameEdit"):GetText();
end

function DeveloperExtractPropFrameNumberRightBtn_OnClick()
	if not tonumber(CurInputNumberVal) then
    	ShowGameTips(GetS(23003), 3)
    	return
    end 
	CurInputNumberVal = tonumber(CurInputNumberVal)+1;
	if tonumber(CurInputNumberVal) > tonumber(DeveloperStashPropList[ExtractItemIndex].ItemNum) then
		CurInputNumberVal = tonumber(DeveloperStashPropList[ExtractItemIndex].ItemNum);
	end
	getglobal("DeveloperExtractPropFrameNumberNameEdit"):SetText(tostring(CurInputNumberVal));
end

function DeveloperExtractPropFrameNumberLeftBtn_OnClick()
	if not tonumber(CurInputNumberVal) then
    	ShowGameTips(GetS(23003), 3)
    	return
    end 
	CurInputNumberVal = tonumber(CurInputNumberVal)-1;
	if CurInputNumberVal < 1 then
		CurInputNumberVal = 1;
	end

	getglobal("DeveloperExtractPropFrameNumberNameEdit"):SetText(tostring(CurInputNumberVal));
end

function DeveloperExtractPropFrameMaxNumBtn_OnClick()
	CurInputNumberVal = DeveloperStashPropList[ExtractItemIndex].ItemNum;
	getglobal("DeveloperExtractPropFrameNumberNameEdit"):SetText(tostring(CurInputNumberVal));
end

function DeveloperExtractPropFrameConfirmBtn_OnClick(itemID, isExtract)
	local ExtractItemIndexId = 0
	local itemNum = 0
	if itemID then
		ExtractItemIndexId = itemID
		itemNum = GetDeveloperStashPropNumByItemID(itemID)
	else
		ExtractItemIndexId = DeveloperStashPropList[UserClickStashItemNumber].ItemID
		itemNum = DeveloperStashPropList[ExtractItemIndex].ItemNum
	end

	local def = ModEditorMgr:getItemDefById(ExtractItemIndexId) or ModEditorMgr:getBlockItemDefById(ExtractItemIndexId) or ItemDefCsv:get(ExtractItemIndexId);
	if def == nil then
		ShowGameTips(GetS(23004), 3);
		return;
	elseif not tonumber(CurInputNumberVal) then
		ShowGameTips(GetS(21673), 3);
		return;
	elseif tonumber(CurInputNumberVal) > tonumber(itemNum) then
		ShowGameTips(GetS(21669), 3);
		return;
	end


	local mapId = 0;
	local authorUin = 0;

	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		mapId = wdesc.fromowid;
		authorUin = getFromOwid(wdesc.fromowid);
		if wdesc.fromowid == 0 then
			mapId = wdesc.worldid;
			authorUin = AccountManager:getUin()
		end
	else
		mapId = DeveloperFromOwid;
		authorUin = getFromOwid(mapId)
	end
	local uin =  AccountManager:getUin()


	if ClientBackpack:enoughGridForItem(ExtractItemIndexId, tonumber(CurInputNumberVal))  then
		ShowNoTransparentLoadLoop();
		isBagExtract =true;
		local code,ltype = DeveloperExtraStoreItem(uin,authorUin,mapId,ExtractItemIndexId, tonumber(CurInputNumberVal))
		if 1 == code then
			if ltype then
				LoadDeveloperStashPropList();
				buildStoreSkuList()

				if isExtract then
					ShowGameTipsWithoutFilter(GetS(25103, def.Name),3);
				else
					ShowGameTips(GetS(132),3);
				end
				AddExtractPropTag(ExtractItemIndexId);
			end
		end
		HideNoTransparentLoadLoop();
	else
		local num = ClientBackpack:enoughGridForItemMaxNum(ExtractItemIndexId, tonumber(CurInputNumberVal))
		if num and num > 0 then
			ShowNoTransparentLoadLoop();
			isBagExtract =false;
			local code,ltype = DeveloperExtraStoreItem(uin,authorUin,mapId,ExtractItemIndexId, num)

			if 1 == code then
				if ltype then
					LoadDeveloperStashPropList();
					buildStoreSkuList()
					ShowGameTips(GetS(21674,num), 3);
					AddExtractPropTag(ExtractItemIndexId);
				end
			end
			HideNoTransparentLoadLoop();
		else
			if isExtract then
				ShowGameTips(GetS(25102),3);
			else
				ShowGameTips(GetS(3678), 3);
			end
			SetItemCanBuyAgain(true)
		end
		
	end
	getglobal("DeveloperExtractPropFrame"):Hide();
end

function GetGameMapidAndAuthorUin()
	local mapId = 0;
	local authorUin = 0;
	
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		mapId = wdesc.fromowid;
		authorUin = getFromOwid(wdesc.fromowid);
		if wdesc.fromowid == 0 then
			mapId = wdesc.worldid;
			authorUin = AccountManager:getUin()
		end
	else
		mapId = DeveloperFromOwid;
		authorUin = getFromOwid(mapId)
	end
	return mapId ,authorUin
end


function DeveloperExtraStoreSuccess(itemID,itemnum)
	local mapid ,authorUin=GetGameMapidAndAuthorUin()
	--local code , bag = AccountManager.cluster.developer.mapbag_info(mapid)
	--if code == ErrorCode.OK then 
		--local code = AccountManager:dev_mapbag_consume_item(0, authorUin, mapid, itemID, itemnum)
		--bag:item_consume(itemID, itemnum)
	--end

	LoadDeveloperStashPropList();
	buildStoreSkuList()
	AddExtractPropTag(itemID);
	if isBagExtract then
		if isExtract then
			local def = ModEditorMgr:getItemDefById(itemID) or ModEditorMgr:getBlockItemDefById(itemID) or ItemDefCsv:get(itemID);
			if def then		
				ShowGameTips(GetS(25103, def.Name),3);
			end
		else
			ShowGameTips(GetS(132),3);
		end
	else
		ShowGameTips(GetS(21674,itemnum), 3);
	end
	--HideNoTransparentLoadLoop();
end

function DeveloperStoreResh(seq,reshtype,uin,authoruin,mapid,itemid,num,orderid)
		if reshtype == ErrorCode.DEV_MAPSTORE_NEED_REFRESH then 
			local synccode = AAccountManager.cluster.developer.mapstore_info(authoruin, mapid, true) 
			if synccode ~= ErrorCode.OK then 
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[synccode]), 3);
				return  
			end 
			
		end
		if reshtype == ErrorCode.DEV_MAPBAG_NEED_REFRESH then 
			local synccode = AccountManager.cluster.developer.mapbag_info(mapid, true) 
			if synccode ~= ErrorCode.OK then 
				ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[synccode]), 3);
				return  
			end 
		end 
		local code , bag = AccountManager.cluster.developer.mapbag_info(mapid)
							
		if code ~= ErrorCode.OK then 
			ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
			return  
		end
		local verSion= bag.Version
		
		SandboxLuaMsg.sendToHost(_G.SANDBOX_LUAMSG_NAME.GLOBAL.DEVELOPERSTORE_EXTRASTOREITEM_TOHOST, { 
			order_id = orderid,
			role_id = uin,
			mapid = mapid,
			itemid = itemid,
			itemnum = num,
			authoruin = authoruin,
			version = verSion,
			seq = seq+1
		})
end

--开发商店下发商品
function DeveloperExtraStoreItem( uin,authorUin, mapId,itemID,num)
	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then --单机或者房主
		local code = AccountManager:dev_mapbag_consume_item(0, authorUin, mapId, itemID, num)
		if code == ErrorCode.OK then
			if CurMainPlayer and ClientCurGame and ClientCurGame:isInGame()  then				
				CurMainPlayer:gainItems(itemID, num);
				SetItemCanBuyAgain(true)
				OnDeveloperBuyItemTriggerEventHost(itemID, CurMainPlayer:getUin())
				return 1,true;
			end
		else
			ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
			SetItemCanBuyAgain(true)
			return 1,false
		end
	else
		if CurMainPlayer and ClientCurGame and ClientCurGame:isInGame() then
			if ns_shop_config2 and ns_shop_config2.Shop_ExtractItem_Switch and check_apiid_ver_conditions(ns_shop_config2.Shop_ExtractItem_Switch) then
			--if true then
				if  AccountManager.cluster.developer.mapbag_info then
					local code,bag= AccountManager.cluster.developer.mapbag_info(mapId)
					if code == ErrorCode.OK then
						local luin=uin;
						local seq=1;
						local lauthorUin=authorUin;
						local lmapId=mapId;
						local litemID=itemID;
						local lnum=num
						local verSion= bag.Version
						local callFun = function(ret)
							if ret and ret.ret == 0 and ret.data and ret.data.token then							
								SandboxLuaMsg.sendToHost(_G.SANDBOX_LUAMSG_NAME.GLOBAL.DEVELOPERSTORE_EXTRASTOREITEM_TOHOST, { 
									order_id = ret.data.token,
									role_id = luin,
									mapid = lmapId,
									itemid = litemID,
									itemnum = lnum,
									authoruin = lauthorUin,
									version = verSion,
									seq = seq
								})
							end
						end
					local url = g_http_root.."miniw/mall?"
					local reqParams = { act = 'extract_bag_item', item_id = itemID, item_num = num, get_type = 1}
					local paramStr, md5 = http_getParamMD5(reqParams)
					url =  table.concat({url, paramStr, '&md5=', md5})
					ns_http.func.rpc(url, callFun, nil, nil, true, true);
					return 2,true;
					end
				end
			else
				local code = AccountManager:dev_mapbag_consume_item(0, authorUin, mapId, itemID, num)
				if code == ErrorCode.OK then
					if CurMainPlayer  and ClientCurGame and ClientCurGame:isInGame()  then 	
						CurMainPlayer:ExtraStoreItem(1, itemID, num)
						SetItemCanBuyAgain(true)
						return 1,true;
					end
				else
					SetItemCanBuyAgain(true)
					ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
					return 1,false
				end		

			end
		end
	end

	return 1,true;
end


function DeveloperUpdateExtractItemFrame(index)
	if index > 0 and index <= #(DeveloperStashPropList) then
		ExtractItemIndex = index;
		local stashDef = DeveloperStashPropList[ExtractItemIndex];
		ExtractItemIndexId = stashDef.ItemID;

		local itemDef = ModEditorMgr:getItemDefById(ExtractItemIndexId) or ModEditorMgr:getBlockItemDefById(ExtractItemIndexId) or ItemDefCsv:get(ExtractItemIndexId);
		local icon 	= getglobal("DeveloperExtractPropFrameIcon");
		local num 	= getglobal("DeveloperExtractPropFrameNum");
		local name 	= getglobal("DeveloperExtractPropFrameName");
		local chipIcon 	= getglobal("DeveloperExtractPropFrameChipIcon");
		local proTitle 	= getglobal("DeveloperExtractPropFrameProTitle");
		local proBkg 	= getglobal("DeveloperExtractPropFrameProBkg");
		local pro 	= getglobal("DeveloperExtractPropFramePro");
		local count 	= getglobal("DeveloperExtractPropFrameCount");
		local desc = getglobal("DeveloperExtractPropFrameDesc")

		if itemDef == nil then
			getglobal("DeveloperExtractPropFrameConfirmBtn"):Enable();
			getglobal("DeveloperExtractPropFrameConfirmBtnNormal"):SetGray(false);
			num:SetText(stashDef.ItemNum);
			name:SetText(GetS(23002));
			desc:SetText(GetS(21677));
			SetItemIcon(icon, 0);
		else

			getglobal("DeveloperExtractPropFrameConfirmBtn"):Enable();
			getglobal("DeveloperExtractPropFrameConfirmBtnNormal"):SetGray(false);
			SetItemIcon(icon, stashDef.ItemID);
			num:SetText(stashDef.ItemNum);
			name:SetText(itemDef.Name);

			chipIcon:Hide();
			proTitle:Hide();
			proBkg:Hide();
			pro:Hide();
			count:SetText("");
			desc:SetText(GetS(21675,itemDef.Name));
			local recycleDef = DefMgr:getRecycleDef(ExtractItemIndexId);

			local isUnLockItem = false;
			if itemDef.Chip == 1 then
				local involvedDef = ItemDefCsv:get(itemDef.InvolvedID);
				if involvedDef ~= nil and involvedDef.UnlockFlag > 0 
				   and not isItemUnlockByItemId(involvedDef.ID) then
					isUnLockItem = true;
				end
			end


		end
	end
end

-------------------------------------------------------开发者设置商品的商城---------------------------------------------------------------
function DeveloperStoreMapPurchaseFrame_OnLoad()
	--标题栏
	getglobal("DeveloperStoreMapPurchaseFrameTitleFrameName"):SetText(GetS(3745));
	getglobal("DeveloperStoreItemSetFrameTitleFrameName"):SetText(GetS(21663));
	getglobal("DeveloperChooseOriginalFrameTitleFrameName"):SetText(GetS(21613));

end

function DeveloperStoreMapPurchaseFrame_OnShow()
	if ns_minidian_config and ns_minidian_config.MiniPointDataGuard then
		DeveloperMiniPointDataGuard = ns_minidian_config.MiniPointDataGuard
	end
	DeveloperStoreDealButtonShow()
	for i=1,50 do
		getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i):Hide();
	end
	--没网络
	if ClientMgr:getNetworkState() == 0 then
		NoNetworkEnterStore()
	else
		buildPropTypeList(1, true) -- 先初始化gStoreGroupTypList防止LoadDeveloperPropList用到的数据异常
		LoadDeveloperPropList();
		UpdateDeveloperStoreBoxPlane()
		if gDeveloperStoreType == 1 then -- 编辑模式
			standReportEvent("6002", "PROP_WARES", "-", "view", {cid = G_GetFromMapid()})
		end
	end

	ClientCurGame:setOperateUI(true);
	DeveloperStoreSetBtnChecked(true);
	DeveloperStoreDealSubmintButton();
	if gDeveloperStoreType == 1 then -- 编辑模式
		standReportEvent("6002", "PROP", "-", "view", {cid = G_GetFromMapid()})
	end
end

function DeveloperStoreMapPurchaseFrame_OnHide()
	GetInst("DevelopStoreDataManager"):SetDeleteDeveloperPropListTemp({})
	DeleteGruopTemp = {}
	ClientCurGame:setOperateUI(false);
	local tipsFrame = getglobal("PropTypeTipsFrame")
	if tipsFrame:IsShown() then
		tipsFrame:Hide()
	end
	GetInst("NewDeveloperStoreInterface"):CloseAll()
end

function DeveloperStoreMapPurchaseFrameProp_OnLoad()
	for i=1, PropItemNumberMax/2 do
		for j=1, 2 do
			local prop = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..(i-1)*2+j);

			prop:SetPoint("topleft", "DeveloperStoreMapPurchaseFramePropBoxPlane", "topleft", 12+(j-1)*502, (i-1)*143);
			-- prop:SetSize();
		end
		local bkg = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Bkg");
		-- bkg:SetTextureHuiresXml("ui/mobile/texture2/ingame2.xml");
		-- bkg:SetTexUV("shop_bd_icon.png");
	end	

	NoNetworkEnterStore();
end

function cleanAllDeveloperSet()
	for i=1,#(GetInst("DevelopStoreDataManager"):GetDeveloperPropList()) do
		getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i):Hide();
	end
end
function DeveloperStoreMapPurchaseFrameProp_OnShow()
	cleanAllDeveloperSet()
end

function UpdateDeveloperStoreBoxPlane(brefreshoffset)
	-- local row = 2;
	-- local plane = nil;

	-- row = math.ceil(#(GetInst("DevelopStoreDataManager"):GetDeveloperPropList())/2);
	-- plane = getglobal("DeveloperStoreMapPurchaseFramePropBoxPlane");
	-- if row <= 2 then
	-- 	row = 3;
	-- end

	-- if  plane ~= nil then
	-- 	local listFrame = getglobal("DeveloperStoreMapPurchaseFramePropBox")
	-- 	local height = (133+10)*math.floor((#GetInst("DevelopStoreDataManager"):GetDeveloperPropList()+2)/2)
	-- 	if height < listFrame:GetHeight() then height = listFrame:GetHeight() end
	-- 	plane:SetSize(1012, height)
	-- end

	local listFrame = getglobal("DeveloperStoreMapPurchaseFramePropBox")
	local plane = getglobal("DeveloperStoreMapPurchaseFramePropBoxPlane")
	-- local addBtn = getglobal("DeveloperStoreMapPurchaseFramePropAddItem")
	local rownum = math.floor((#GetInst("DevelopStoreDataManager"):GetDeveloperPropList()+2)/2)
	-- if not addBtn:IsShown() then
	-- 	rownum = math.floor((#GetInst("DevelopStoreDataManager"):GetDeveloperPropList()+1)/2)
	-- end
	local height = (133+10)*rownum
	if height < listFrame:GetHeight() then height = listFrame:GetHeight() end
	plane:SetSize(1012, height)

	if brefreshoffset then
		listFrame:setCurOffsetY(0)
	end
end

function NoNetworkEnterStore()
	for i=1,PropItemNumberMax do
		getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i):Hide();
	end
	getglobal("DeveloperStoreMapPurchaseFramePropAddItem"):Hide();
	getglobal("DeveloperStoreMapPurchaseFrameHead"):Show();
	getglobal("DeveloperStoreMapPurchaseFrameTxt"):Show();
	getglobal("DeveloperStoreMapPurchaseFrameSaveDeveloperItem"):Disable();
	return
end

function AdjustDeveloperStoreAuthorPropItem()
	for i=1, PropItemNumberMax do
		local name = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Name");
		local icon = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Icon");
		--local miniIcon = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."MiniIcon");
		local rightNum = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."RightNum");
		local currencyIcon = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."CurrencyIcon");
		local cost = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Cost");
		local tag = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Tag");
		local tagName = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."TagName");
		local chip = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Chip");
		local redTag = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."RedTag");
		local hideIcon = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."HideIcon");

	--	name:SetTextColor(255, 255, 0)
		icon:Show();
		--miniIcon:Hide();
		chip:Hide();
		redTag:Hide();
		rightNum:Show();
		currencyIcon:Show();
		cost:Show();
		tag:Show();
		tagName:Show();

		hideIcon:Hide()
	end

end



function UpdateDeveloperAuthorStoreProp()
	local DeveloperPropList = GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
	for i=1, PropItemNumberMax do
		local item = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i);
		if i <= #(DeveloperPropList) then
			item:Show();
			-- item:SetClientUserData(0, i);
			local bkg = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Bkg");
			local icon = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Icon");
			local rightNum = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."RightNum");
			local name = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Name");
			local currencyIcon = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."CurrencyIcon");
			local cost = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Cost");
			local desc = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Desc");
			local tag = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Tag");
			local tagName = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."TagName");
			--local iconBkg = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."IconBkg");
			--local discountIcon = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."DiscountIcon");
			local discountCost = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."DiscountCost");
			local discountLine = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."DiscountLine");
			local swapBtnBkg = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."SwapBkg");
            local miniPointIcon = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."MiniPointIcon");
			local miniPoint = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."MiniPoint");
			local hideIcon = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."HideIcon");
			local downTips = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."DownTips");

			miniPointIcon:Hide();
			miniPoint:Hide();
			icon:Show();
			rightNum:Show();
			name:Show();
			currencyIcon:Show();
			cost:Show();
			desc:Show();
			tag:Show();
			tagName:Show();
			--discountIcon:Hide();
			discountCost:Hide();
			discountLine:Hide();
		--	iconBkg:Show();
			swapBtnBkg:SetBlendAlpha(0.25);

			hideIcon:Hide()
			downTips:Hide()

			name:SetTextColor(255,255,255)
			rightNum:SetTextColor(255,253,232)
			tagName:SetTextColor(255,255,255)
			cost:SetTextColor(255,227,38)
			discountCost:SetTextColor(165, 163, 163)
			miniPoint:SetTextColor(255,227,38)

			local id = DeveloperPropList[i].ItemID
			local itemDef = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);
			-- local itemDef = ModEditorMgr:getItemDefById(DeveloperPropList[i].ItemID) or ModEditorMgr:getBlockItemDefById(DeveloperPropList[i].ItemID) or ItemDefCsv:get(DeveloperPropList[i].ItemID);
			-- local itemDef = ItemDefCsv:get(DeveloperPropList[i].ItemID);
			if itemDef == nil then
				SetItemIcon(icon, 0);
				name:SetText(GetS(23002));
				desc:SetText(GetS(23002), 228, 218, 207);
			else
				SetItemIcon(icon, DeveloperPropList[i].ItemID);
				name:SetText(itemDef.Name);
				desc:SetText(DeveloperPropList[i].Desc, 228, 218, 207);
			end
			
			-- rightNum:SetText("×"..DeveloperPropList[i].Num);
			rightNum:SetText("×1");
			cost:SetText(DeveloperPropList[i].CostNum);
			local scale = UIFrameMgr:GetScreenScaleY();
			local offsetX = name:GetTextExtentWidth(DeveloperPropList[i].CostNum)/scale + 3;
			-- currencyIcon:SetPoint("right", cost:GetName(), "right", -offsetX, 0);
			if DeveloperPropList[i].CostType == g_DeveloperConfig.Developer.CurrencyType.Money then
				currencyIcon:SetTextureHuiresXml("ui/mobile/texture2/common.xml");
				currencyIcon:SetTexUV("icon_coin");
				--discountIcon:SetTextureHuiresXml("ui/mobile/texture2/common.xml");
				--discountIcon:SetTexUV("icon_coin");
			elseif DeveloperPropList[i].CostType == g_DeveloperConfig.Developer.CurrencyType.Coin then
				currencyIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
				currencyIcon:SetTexUV("icon_bean");
				--discountIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
				--discountIcon:SetTexUV("icon_bean");
			elseif DeveloperPropList[i].CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then
				currencyIcon:SetTextureHuiresXml("ui/mobile/texture0/common_icon.xml");
				currencyIcon:SetTexUV("icon10009");
				--discountIcon:SetTextureHuiresXml("ui/mobile/texture0/common_icon.xml");
				--discountIcon:SetTexUV("icon10009");
				cost:SetText(DeveloperPropList[i].MiniPoint);
			elseif DeveloperPropList[i].CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
				currencyIcon:SetTextureHuiresXml("ui/mobile/texture2/common.xml");
				currencyIcon:SetTexUV("icon_coin");
				--discountIcon:SetTextureHuiresXml("ui/mobile/texture2/common.xml");
				--discountIcon:SetTexUV("icon_coin");
				miniPointIcon:Show();
				miniPoint:Show();
				miniPoint:SetText(DeveloperPropList[i].MiniPoint);
			end

			currencyIcon:SetPoint("right","DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Cost","left",-4,2)
			cost:SetPoint("bottomright","DeveloperStoreMapPurchaseFramePropBoxPropItem"..i,"bottomright",-5,-12)

			if DeveloperPropList[i].Tag > g_DeveloperConfig.Developer.TagType.None then
				tag:Show();
				if DeveloperPropList[i].Tag == g_DeveloperConfig.Developer.TagType.Hot then
					tagName:SetText(GetS(21670));
					-- tag:SetTextureHuiresXml("ui/mobile/texture2/ingame2.xml");
			    	tag:SetTexUV("label_shop_set_hot");
				elseif DeveloperPropList[i].Tag == g_DeveloperConfig.Developer.TagType.New then
					tagName:SetText(GetS(21671));
					-- tag:SetTextureHuiresXml("ui/mobile/texture2/ingame2.xml");
					tag:SetTexUV("label_shop_set_new");
				elseif DeveloperPropList[i].Tag == g_DeveloperConfig.Developer.TagType.Recommend then
			    	tagName:SetText(GetS(21629));
					--tag:SetTextureHuiresXml("ui/mobile/texture2/shop.xml");
			    	tag:SetTexUV("label_shop_set_commend");
			    elseif DeveloperPropList[i].Tag == g_DeveloperConfig.Developer.TagType.Popular then
			    	tagName:SetText(GetS(21630));
					--tag:SetTextureHuiresXml("ui/mobile/texture2/shop.xml");
			    	tag:SetTexUV("label_shop_set_rage");
				elseif DeveloperPropList[i].Tag == g_DeveloperConfig.Developer.TagType.Timelimit then --限时
					DeveloperPropList[i].PropCurTime = DeveloperPropList[i].LimitEnd - utils.ts2day(getServerNow())
					local str = "";
					if DeveloperPropList[i].PropCurTime <= 0 then
						str = GetS(23185)
					else
						--print("------------days-----------",DeveloperPropList[i].PropCurTime)
						--str = "剩余"..tostring(DeveloperPropList[i].PropCurTime).."天"
						str = GetS(23186, DeveloperPropList[i].PropCurTime)
					end
					tagName:SetText(str);
			    	tag:SetTexUV("label_shop_set_time");
				elseif DeveloperPropList[i].Tag == g_DeveloperConfig.Developer.TagType.Discount then --折扣
					if DeveloperPropList[i].LimitStart ~= DeveloperPropList[i].LimitEnd then
						DeveloperPropList[i].PropCurTime = DeveloperPropList[i].LimitEnd - utils.ts2day(getServerNow())
						local str = "";
						if DeveloperPropList[i].PropCurTime <= 0 then
							str = GetS(23187)
						else
							--print("------------days-----------",DeveloperPropList[i].PropCurTime)
							str = GetS(23188,DeveloperPropList[i].PropCurTime)
							--str = "剩余"..tostring(DeveloperPropList[i].PropCurTime).."天"
							--discountIcon:Show();
							discountCost:Show();
							discountLine:Show();
							--discountIcon:SetGray(true)
							discountCost:SetText(DeveloperPropList[i].CostNum);
							cost:SetText(DeveloperPropList[i].DiscountCostNum);

							--设置折扣 和 划线 和币种的位置
							--currencyIcon:SetPoint("right","DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."Cost","left",-4,2)
							--cost:SetPoint("bottomright","DeveloperStoreMapPurchaseFramePropBoxPropItem"..i,"bottomright",-5,-12)
							--cost x 40
							local discountCostWidth = discountCost:GetTextExtentWidth(DeveloperPropList[i].CostNum)
							discountLine:SetWidth(discountCostWidth + 10)

							discountCost:SetPoint("bottomright", "DeveloperStoreMapPurchaseFramePropBoxPropItem"..i, "bottomright", -52, -14)
							discountLine:SetPoint("bottomright", "DeveloperStoreMapPurchaseFramePropBoxPropItem"..i, "bottomright", -45, -22)
							currencyIcon:SetPoint("right","DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."DiscountCost","right", -discountCostWidth-10, 0)	
							
						end
						tagName:SetText(str);
					else
						tagName:SetText(GetS(23187));
					end
					--tag:SetTextureHuiresXml("ui/mobile/texture2/shop.xml");
			    	tag:SetTexUV("label_shop_set_sale")
				end
			else
				tag:Hide();
				tagName:SetText("");
			end

			if DeveloperPropList[i].Visible == 0 then
				--隐藏
				hideIcon:Show()
				local nameWidth = name:GetTextExtentWidth(itemDef and itemDef.Name or GetS(23002))
				hideIcon:SetPoint("left", name:GetName(), "left", nameWidth + 4, 0)
			end

			--已下架
			item:SetGray(DeveloperPropList[i].Updown == 0)
			if DeveloperPropList[i].Updown == 0 then
				downTips:Show()
				currencyIcon:Hide()
				cost:Hide()
				discountCost:Hide()
				discountLine:Hide()
				miniPointIcon:Hide()
				miniPoint:Hide()

				name:SetTextColor(255,255,255)
				rightNum:SetTextColor(255,253,232)
				tagName:SetTextColor(255,255,255)
				downTips:SetTextColor(255,255,255)
			end
		else
			item:Hide();
		end
	end

	-- local PropNumber = #(DeveloperPropList)

	local code = 1001;
	local info = nil;
	local cfg =nil;
	if g_DeveloperInfo then
		code = ErrorCode.OK
		cfg = g_DeveloperInfo;
	else
		code, info, cfg = AccountManager:dev_developer_info(AccountManager:getUin());
		if info and info.Level ~= nil then
			GetInst("DevelopStoreDataManager"):SetUserLevel(info.Level)
		end
	end

	-- local code, info, cfg = AccountManager:dev_developer_info(AccountManager:getUin())

	getglobal("DeveloperStoreMapPurchaseFrameSaveDeveloperItem"):Enable();
	-- getglobal("DeveloperStoreMapPurchaseFrameNumberTips"):SetText("货架容量："..#DeveloperPropList.."/30");
	getglobal("DeveloperStoreMapPurchaseFrameHead"):Hide();
	getglobal("DeveloperStoreMapPurchaseFrameTxt"):Hide();

	local addBtn = getglobal("DeveloperStoreMapPurchaseFramePropAddItem")
	addBtn:Show();
	--最多添加30个道具
	if code == ErrorCode.OK then
		local StoreSkuList = GetInst("DevelopStoreDataManager"):GetStoreSkuList()
		if #(StoreSkuList) >= (cfg and cfg.LimitMapStoreItem or 0) then
			addBtn:Hide();
		end
		getglobal("DeveloperStoreMapPurchaseFrameNumberTips"):SetText(GetS(21662)..#DeveloperPropList.."/"..(cfg and cfg.LimitMapStoreItem or 0));
	else
		addBtn:Hide();
		getglobal("DeveloperStoreMapPurchaseFrameNumberTips"):SetText(GetS(21662).."：30/30");
	end

	UpdateDeveloperStoreBoxPlane();
end

function DeveloperGetLimtStr()
	local code, cfg = GetInst("DevelopStoreDataManager"):GetDeveloperCfg()
	return GetS(21662)..#GetInst("DevelopStoreDataManager"):GetDeveloperPropList().."/"..(cfg and cfg.LimitMapStoreItem or 0)
end


function DeveloperPropAddGridTemplate_OnClick()
	GetInst("DevelopStoreDataManager"):SetIsSelectAddPropBtn(true)
	isFirstClickMoneyLable = true;
	isFirstClickItemLable = true;

	CurSelectPropTag = g_DeveloperConfig.Developer.TagType.None;
	CurSelectPropCurrencyType = g_DeveloperConfig.Developer.CurrencyType.Money;
	cancelLockStateOfMoveItem()
	if getglobal("DeveloperStoreMapPurchaseFrame"):IsShown() then
		standReportEvent("6002", "PROP_WARES", "WaresAdd", "click", {cid = G_GetFromMapid()})
		GetInst("DevelopStoreDataManager"):SetUserClickPropNumber(0)
		OpenDevelopStoreItemSet()
	end
	getglobal("DeveloperChooseOriginalFrameOkBtn"):SetClientID(0);
	standReportEvent("6002", "PROP_STOREBUY", "AddGoods", "click",{cid = G_GetFromMapid()})
end

function cancelLockStateOfMoveItem()
	if SwapBtnSwich ~= 0 then
		for i=1,#GetInst("DevelopStoreDataManager"):GetDeveloperPropList() do
			local bkg = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."TransparentBkg");
			local btn = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."SwapMoveBtn");
			bkg:Hide();
			btn:Hide();
			SwapBtnSwich = 0;
			getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i):Enable();
		end
	end
end

--交换Item开关
function ItemMoveOpenBtn_OnClick()

	local number = string.sub(this:GetName(),46,-9)
	local swapBkg = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..number.."TransparentBkg");
	local swapBtn = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..number.."SwapMoveBtn")
	local propList = GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
	if number == SwapBtnSwich then
		for i=1, #propList do
			local bkg = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."TransparentBkg");
			local btn = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."SwapMoveBtn");
			bkg:Hide();
			btn:Hide();
			SwapBtnSwich = 0;
			local item = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i)
			item:Enable() --enable 会将原来置灰的item 还原
			if propList[i].Updown == 0 then
				item:SetGray(true)
			end
		end
		return
	end

	for i=1, #propList do
		local bkg = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."TransparentBkg");
		local btn = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."SwapMoveBtn")
		local swapBtnBkg = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."SwapBkg");
		if SwapBtnSwich ~= number then
			bkg:Show();
			btn:Show();
			swapBtnBkg:Show();
			getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i):Disable();
		else
			bkg:Hide();
			btn:Hide();
			if i == #propList then
				SwapBtnSwich = 0;
				return
			end
		end
	end
	swapBkg:Hide();
	swapBtn:Hide();
	SwapBtnSwich = number;
end

-- 交换按钮
function ItemSwapBtn_OnClick()
	local strname = this:GetName()
	--local strnum = string.sub(strname,-12,-12)
	local number1 = GetDeveloperStoreItemSwapNum(strname)
	local number2 =tonumber(SwapBtnSwich)

	local DeveloperPropList = GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
	local data1, data2 = DeveloperPropList[number1], DeveloperPropList[number2]
	if not data1 or not data2 then
		ShowGameTips("数据错误，请重新打开商店")
		return
	end

	-- local DeveloperPropTemp1 = deep_copy_table(DeveloperPropList[number1]);
	-- local DeveloperPropTemp2 = deep_copy_table(DeveloperPropList[number2]);

	-- DeveloperPropList[number1] = DeveloperPropTemp2;
	-- DeveloperPropList[number2] = DeveloperPropTemp1;
	local StoreSkuList = GetInst("DevelopStoreDataManager"):GetStoreSkuList()
	StoreSkuList[data1.RealPos], StoreSkuList[data2.RealPos] = StoreSkuList[data2.RealPos], StoreSkuList[data1.RealPos]
	LoadDeveloperPropList(true)

	-- AdjustDeveloperStoreAuthorPropItem()
	-- UpdateDeveloperAuthorStoreProp()


	for i=1,#DeveloperPropList do
		local bkg = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."TransparentBkg");
		local btn = getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i.."SwapMoveBtn");
		bkg:Hide();
		btn:Hide();
		SwapBtnSwich = 0;
		getglobal("DeveloperStoreMapPurchaseFramePropBoxPropItem"..i):Enable();
	end
end

function GetDeveloperStoreItemSwapNum(strname)
	local strnum = string.gsub(strname,"DeveloperStoreMapPurchaseFramePropBoxPropItem","")
	 strnum =string.gsub(strnum,"SwapMoveBtn","")
	 return tonumber(strnum)
end

-- 保存
function DeveloperStoreSaveBtn_OnClick()
	standReportEvent("6002", "PROP", "Save", "click", {cid = G_GetFromMapid(), standby1 = GetInst("DevelopStoreDataManager"):GetCurShopType()})

	if isEducationalVersion then
		ShowWebView_Edu();
	end	

	local mapId = 0;
	local authorUin = 0;

	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		mapId = wdesc.fromowid;
		authorUin = getFromOwid(wdesc.fromowid);
		if wdesc.fromowid == 0 then
			mapId = wdesc.worldid;
			authorUin = AccountManager:getUin()
		end
	else
		mapId = DeveloperFromOwid;
		authorUin = getFromOwid(mapId)
	end
	cancelLockStateOfMoveItem()
	local delete_code = -1
	if #DeleteGruopTemp ~= 0 then
		for k,v in pairs(DeleteGruopTemp) do
			DeveloperStoreRmitemgroup(AccountManager:getUin(),mapId,v ,true)
		end
	end
	local DeleteDeveloperPropListTemp = GetInst("DevelopStoreDataManager"):GetDeleteDeveloperPropListTemp()
	if #DeleteDeveloperPropListTemp ~= 0 then
		if DeveloperStoreRmitemlist(AccountManager:getUin(),mapId,DeleteDeveloperPropListTemp) then
			delete_code=ErrorCode.OK
		end
		--delete_code = AccountManager:dev_mapstore_rm_iteminfo_list(AccountManager:getUin(), tostring(mapId), DeleteDeveloperPropListTemp)
	end
	-- print("--------------------AccountManager:getUin(),mapId,DeveloperPropList:-------------",AccountManager:getUin(),mapId,DeveloperPropList)

	--这里保存不用DeveloperPropList，要用StoreSkuList
	local StoreSkuList = GetInst("DevelopStoreDataManager"):GetStoreSkuList()
	local bShowTips = false
	if StoreSkuList and #StoreSkuList > 0 then
		--local add_code,msg = AccountManager:dev_mapstore_set_iteminfo_list(AccountManager:getUin(),mapId, StoreSkuList)
		
		--if add_code ==ErrorCode.OK then
		--	bShowTips = true
		--end
		if DeveloperStoreSetItemlist(AccountManager:getUin(),mapId, StoreSkuList) then
			bShowTips = true
		end
	else
		if not DeveloperStoreIsExit() then
			local mapId, authorUin = GetMapIdAndUin()
			if mapId  ~= 0 and authorUin ~= 0 then
				local StoreGroupTypeMap = GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMap()
				local list = {}
				for k,v in pairs(StoreGroupTypeMap) do
					table.insert(list, v)
				end
				if #list ~= 0 then
					if DeveloperStoreSetGroups(authorUin, mapId, list) then
						bShowTips = true
					end
				end
			end
		end
	end

	if delete_code == ErrorCode.OK then
		bShowTips = true
	end
	GetInst("NewDeveloperStoreInterface"):SaveInfo(function (code)
		getglobal("DeveloperStoreMapPurchaseFrame"):Hide();
		if bShowTips or code == 0 then
			if DeveloperStoreMapIsUpload(mapId) then
				ShowGameTips(GetS(21609),3)
			else
				ShowGameTipsWithoutFilter(GetS(23049), 3)
			end
		end
		if bShowTips  then
			-- 设置地图广告存档
			if type(StoreSkuList) == "table" then
				SSMgrAd:OnDeverloperStoreSave(deep_copy_table(StoreSkuList))
			end
		end

		local GroupID =  gStoreGroupTypList[gSelectPropType]
		if not GroupID then return end
		local standby1=getGroupTypeName(GroupID)
		standReportEvent("6002", "PROP_STOREBUY", "AddGoodsList", "click",{cid = G_GetFromMapid(),standby1=standby1})
		
		--GetInst("NewDeveloperStoreInterface"):CloseAll()
	end)
end

function DeveloperStoreMapPurchaseFrameCloseBtn_OnClick()
	cancelLockStateOfMoveItem()
	--GetInst("NewDeveloperStoreInterface"):CloseAll()
	getglobal("DeveloperStoreMapPurchaseFrame"):Hide();
	ShowWebView_Edu();	
end

function DeveloperStoreMapPurchaseFrameHelpBtn_OnClick()
	GetInst("UIManager"):Open("CommonHelp", {textTitle=GetS(23170), textContent=GetS(23169)})

	standReportEvent("6002", "PROP", "Help", "click", {cid = G_GetFromMapid()})
	standReportEvent("6002", "PROP_HELP", "-", "view", {cid = G_GetFromMapid()})
end

function UpdateDeveloperStoreBuyItemFrameActDesc(index)
	local frame = getglobal("DeveloperStoreBuyItemFrame")
	if not frame or not frame:IsShown() then
		return
	end

	local actDesc = getglobal("DeveloperStoreBuyItemFrameActDesc")
	if not actDesc then
		return
	end

	local DeveloperPropList = GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
	if index and index > 0 and index <= #(DeveloperPropList) then
		local propDef = DeveloperPropList[index]

		local actDescStr = ""
		if propDef.Tag == g_DeveloperConfig.Developer.TagType.Timelimit then
			--开启了限售
			if propDef.LimitTimeSaleNum and propDef.LimitTimeSaleNum > 0 then
				local mapId = G_GetFromMapid()
				local stock = GetInst("DevelopStoreDataManager"):GetStoreSkuItemStock(mapId, propDef.ItemID)
				actDescStr = string.format("%s#cFFE326%s#n%s", GetS(23191),stock,GetS(23190))
			end
		end

		if propDef.LimitBuyNum and propDef.LimitBuyNum > 0 then
			actDescStr = actDescStr .. string.format(" %s#cFFE326%s#n%s", GetS(23189), propDef.LimitBuyNum, GetS(23190))--string.format(" 每人限购#cFFE326%s#n件", propDef.LimitBuyNum)
		end

		--活动信息
		if actDescStr ~= "" then
			actDesc:Show()
			actDesc:SetText(actDescStr, 255, 255, 255)
		end
	end
end

function UpdateDeveloperStoreBuyItemFrame(index)
	local DeveloperPropList = GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
	local StoreSkuList = GetInst("DevelopStoreDataManager"):GetStoreSkuList()
	if index > 0 and index <= #(DeveloperPropList) then
		local propDef = DeveloperPropList[index];

		BuyItemIndex = index;

		local icon = getglobal("DeveloperStoreBuyItemFrameIcon");
		local num = getglobal("DeveloperStoreBuyItemFrameNum");
		local name = getglobal("DeveloperStoreBuyItemFrameName");
		--local currencyIcon = getglobal("DeveloperStoreBuyItemFrameCurrencyIcon");
		--local cost = getglobal("DeveloperStoreBuyItemFrameCost");
		--local discountIcon = getglobal("DeveloperStoreBuyItemFrameDiscountIcon");
		--local discountCost = getglobal("DeveloperStoreBuyItemFrameDiscountCost");
		--local discountLine = getglobal("DeveloperStoreBuyItemFrameDiscountLine");
		--local miniPointIcon = getglobal("DeveloperStoreBuyItemFrameMiniPointIcon");
		--local miniPoint = getglobal("DeveloperStoreBuyItemFrameMiniPoint");
		local desc = getglobal("DeveloperStoreBuyItemFrameDesc");
		local costtips1 = getglobal("DeveloperStoreBuyItemFrameCostTips1");
		local costtips = getglobal("DeveloperStoreBuyItemFrameCostTips");
		local costtipsContent = getglobal("DeveloperStoreBuyItemFrameContentFrameContent");

		-- tag 活动描述
		local tag = getglobal("DeveloperStoreBuyItemFrameTag")
		local tagName = getglobal("DeveloperStoreBuyItemFrameTagName")
		local actDesc = getglobal("DeveloperStoreBuyItemFrameActDesc")

		tag:Hide()
		tagName:Hide()
		actDesc:Hide()

		if IsOpenSavePlayerData() then
			costtips1:Show()
			costtips:Hide()
			costtips1:SetText(GetS(9312200), 253, 230, 66);
			costtipsContent:SetText(GetS(9312201), 224, 220, 202);
		else
			costtips1:Hide()
			costtips:Show()
		end
		-- discountIcon:Hide()
		-- discountCost:Hide()
		-- discountLine:Hide()
		-- miniPointIcon:Hide()
		-- miniPoint:Hide()
		SetItemIcon(icon, propDef.ItemID);
		num:SetText("x1");

		local buyBtn = getglobal("DeveloperStoreBuyItemFrameBuyBtn")
		local buyBtnIcon = getglobal("DeveloperStoreBuyItemFrameBuyBtnIcon")
		local buyBtnDisCost = getglobal("DeveloperStoreBuyItemFrameBuyBtnDiscountCost")
		local buyBtnDistLine = getglobal("DeveloperStoreBuyItemFrameBuyBtnDiscountLine")
		local buyBtnNum = getglobal("DeveloperStoreBuyItemFrameBuyBtnNum")

		local miniCoinBuyBtn = getglobal("DeveloperStoreBuyItemFrameMiniCoinBuyBtn")
		local miniCoinBuyBtnIcon = getglobal("DeveloperStoreBuyItemFrameMiniCoinBuyBtnIcon")
		local miniCoinBuyBtnDisCost = getglobal("DeveloperStoreBuyItemFrameMiniCoinBuyBtnDiscountCost")
		local miniCoinBuyBtnDisLine = getglobal("DeveloperStoreBuyItemFrameMiniCoinBuyBtnDiscountLine")
		local miniCoinBuyBtnNum = getglobal("DeveloperStoreBuyItemFrameMiniCoinBuyBtnNum")

		local miniPointBuyBtn = getglobal("DeveloperStoreBuyItemFrameMiniPointBuyBtn")

		buyBtn:Show()
		buyBtnDisCost:Hide()
		buyBtnDistLine:Hide()

		miniCoinBuyBtn:Hide()
		miniCoinBuyBtnDisCost:Hide()
		miniCoinBuyBtnDisLine:Hide()

		miniPointBuyBtn:Hide()

		buyBtnIcon:SetPoint("center", buyBtn:GetName(), "center", -15, 0)
		buyBtnNum:SetPoint("left", buyBtnIcon:GetName(), "right", 5, 0)

		if propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.Money then
			buyBtnIcon:SetTexUV("icon_coin")
		elseif propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.Coin then
			buyBtnIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml")
			buyBtnIcon:SetTexUV("icon_bean")
		elseif propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then
			buyBtnIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml")
			buyBtnIcon:SetTexUV("icon10009")
		elseif propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
			buyBtnIcon:SetTexUV("icon_coin")

			if DeveloperMiniPointDataGuard == 0 then
				buyBtn:Hide()
				miniCoinBuyBtn:Show()
				miniPointBuyBtn:Show()
				
				miniCoinBuyBtnNum:Show()
				miniCoinBuyBtnNum:SetText(propDef.CostNum)

				local miniPointNum = getglobal("DeveloperStoreBuyItemFrameMiniPointBuyBtnNum");
				miniPointNum:Show()
				miniPointNum:SetText(propDef.MiniPoint)
			end
		end

		local itemDef = ModEditorMgr:getItemDefById(propDef.ItemID) or ModEditorMgr:getBlockItemDefById(propDef.ItemID) or ItemDefCsv:get(propDef.ItemID);
		-- local itemDef = ItemDefCsv:get(propDef.ItemID);
		if itemDef == nil then
			name:SetText(GetS(23002));
			desc:SetText(GetS(23002), 255, 255, 255);
		else
			name:SetText(itemDef.Name);
			desc:SetText(itemDef.Desc, 255, 255, 255);

			--tag
			local nameWidth = name:GetTextExtentWidth(itemDef.Name)
			tag:SetPoint("left", "DeveloperStoreBuyItemFrameName", "left", nameWidth+4, 0 )

			if propDef.Tag == g_DeveloperConfig.Developer.TagType.Timelimit then
				tag:SetTexUV("frame_xianshi")
				if propDef.PropCurTime <= 0 then
					tagName:SetText(GetS(23185))
				else
					tagName:SetText(GetS(23186, propDef.PropCurTime))
				end

				tag:Show()
				tagName:Show()
			elseif propDef.Tag == g_DeveloperConfig.Developer.TagType.Discount then
				tag:SetTexUV("frame_youhui")
				if propDef.PropCurTime <= 0 then
					tagName:SetText(GetS(23187))
				else
					tagName:SetText(GetS(23188, propDef.PropCurTime))
				end

				tag:Show()
				tagName:Show()
			end

			--活动信息
			UpdateDeveloperStoreBuyItemFrameActDesc(index)
		end

		if itemDef and itemDef.Type == ITEM_TYPE_PACK then
			getglobal("DeveloperStoreBuyItemFrameCatInfo"):Show()
		else
			getglobal("DeveloperStoreBuyItemFrameCatInfo"):Hide()
		end

		buyBtnNum:SetText(propDef.CostNum);

		if propDef.Tag == g_DeveloperConfig.Developer.TagType.Discount and propDef.DiscountCostNum ~= propDef.CostNum  and propDef.PropCurTime > 0 then
			buyBtnDisCost:Show()
			buyBtnDistLine:Show()
			
			buyBtnNum:SetText(propDef.DiscountCostNum);
			buyBtnDisCost:SetText(propDef.CostNum);

			local disCostWidth = buyBtnDisCost:GetTextExtentWidth(propDef.CostNum)
			buyBtnDistLine:SetWidth(disCostWidth+10)

			buyBtnIcon:SetPoint("center", buyBtn:GetName(), "center", -30, 0)
			buyBtnDisCost:SetPoint("left", buyBtnIcon:GetName(), "right", 5, 0)
			buyBtnDistLine:SetPoint("left", buyBtnDisCost:GetName(), "left", -5, 0)
			buyBtnNum:SetPoint("left", buyBtnIcon:GetName(), "right", disCostWidth+12, 0)
		elseif propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then
			buyBtnNum:SetText(propDef.MiniPoint)
		elseif propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then


			-- currencyIcon:SetPoint("topleft","DeveloperStoreBuyItemFrameName","topleft",3,40)
			-- cost:SetPoint("left","DeveloperStoreBuyItemFrameCurrencyIcon","right",5,0)
			-- cost:SetText(propDef.CostNum);

			-- miniPointIcon:Show();
			-- miniPoint:Show();
			-- miniPoint:SetText(propDef.MiniPoint);
		else
			-- currencyIcon:SetPoint("topleft","DeveloperStoreBuyItemFrameName","topleft",3,40)
			-- cost:SetPoint("left","DeveloperStoreBuyItemFrameCurrencyIcon","right",5,0)
		end

		if propDef.ADExchange == 1 and IsDeveloperStoreAdCanShow(101) then
			getglobal("DeveloperStoreBuyItemFrameADBtn"):Show()
			getglobal("DeveloperStoreBuyItemFrameBuyBtn"):SetPoint("bottom", "DeveloperStoreBuyItemFrameChenDi", "bottom", -130, -7);
			getglobal("DeveloperStoreBuyItemFrameBuyBtn"):setAbsRect(0,0,182,61)
			local mapId = 0;
			local authorUin = 0;
			if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
				local wdesc = AccountManager:getCurWorldDesc();
				mapId = wdesc.fromowid;
				authorUin = getFromOwid(wdesc.fromowid);
				if wdesc.fromowid == 0 then
					mapId = wdesc.worldid;
					authorUin = AccountManager:getUin()
				end
			else
				mapId = DeveloperFromOwid;
				authorUin = getFromOwid(mapId)
			end
			setCurItemSimpleInfos(authorUin,mapId,propDef.ItemID)
			StatisticsAD('show', 101,nil,authorUin,mapId,propDef.ItemID);

		else
			getglobal("DeveloperStoreBuyItemFrameADBtn"):Hide()
			getglobal("DeveloperStoreBuyItemFrameBuyBtn"):SetPoint("bottom", "DeveloperStoreBuyItemFrameChenDi", "bottom", 0, -7);
		end
		--迷你点
		if DeveloperMiniPointDataGuard == 1 then
			if propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then
				buyBtn:Hide()
				getglobal("DeveloperStoreBuyItemFrameADBtn"):Show()
				getglobal("DeveloperStoreBuyItemFrameADBtn"):SetPoint("bottomright", "DeveloperStoreBuyItemFrameChenDi", "bottomright", -160, -7);
				getglobal("DeveloperStoreBuyItemFrameADBtn"):setAbsRect(0,0,182,61);
			elseif propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
				getglobal("DeveloperStoreBuyItemFrameADBtn"):Show()
				getglobal("DeveloperStoreBuyItemFrameADBtn"):SetPoint("bottomright", "DeveloperStoreBuyItemFrameChenDi", "bottomright", -28, -7);
				getglobal("DeveloperStoreBuyItemFrameADBtn"):setAbsRect(0,0,182,61)
				buyBtn:SetPoint("bottom", "DeveloperStoreBuyItemFrameChenDi", "bottom", -130, -7);
				buyBtn:setAbsRect(0,0,182,61)
				buyBtn:Show()
				miniCoinBuyBtn:Hide()
				miniPointBuyBtn:Hide()
			end
		else
			if propDef.ADExchange == 1 and IsDeveloperStoreAdCanShow(101) then
				getglobal("DeveloperStoreBuyItemFrameADBtn"):SetPoint("bottomright", "DeveloperStoreBuyItemFrameChenDi", "bottomright", -28, -7);
				getglobal("DeveloperStoreBuyItemFrameADBtn"):setAbsRect(0,0,182,61)
			end
		end 
	end
end


function DeveloperStoreItem_OnClick()

	isFirstClickMoneyLable = true;
	isFirstClickItemLable = true;
	local index = tonumber(string.sub(this:GetName(),-1,-1));
	if string.find(this:GetName(),"DeveloperStoreMapPurchaseFramePropBoxPropItem") then
		index = tonumber(string.sub(this:GetName(),46,-1))	
	elseif string.find(this:GetName(),"DeveloperStoreSkuFrameListItem") then
		-- index = tonumber(string.sub(this:GetName(),35,-1)) 
		index = this:GetClientUserData(0)
	end
	GetInst("DevelopStoreDataManager"):SetUserClickPropNumber(index)

	if getglobal("DeveloperStoreSkuFrame"):IsShown() then
		local GroupID = gStoreGroupTypList[gSelectPropType]
		if ItemGroupID2StandReportKeyForContainer[GroupID] then
			local DeveloperPropList = GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
			local Item=DeveloperPropList[index]
			local slot=index
			--通行证standby1为1，普通商品为2
			local standby1=(Item.ItemID == ITEM_PASSPORT and 1 or 2)
			local standby2
			--standby2-1：迷你币商品 2：迷你豆商品 3：迷你点商品 4：播放广告 5：迷你点+迷你币"
			if Item.CostType == g_DeveloperConfig.Developer.CurrencyType.Money then
				standby2=1
			elseif Item.CostType == g_DeveloperConfig.Developer.CurrencyType.Coin then
				standby2=2
			elseif Item.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then
				standby2=3
			elseif Item.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
				standby2=5
			else
				if Item.ADExchange==1 then
					standby2=4
				end
			end

			standReportEvent("60", ItemGroupID2StandReportKeyForContainer[GroupID], "Props", "click",{slot=slot,standby1=standby1,standby2=standby2})

			ReportStoreCardPpopDetails(true, slot)
		end
		-- 
		getglobal("DeveloperStoreBuyItemFrame"):Show();
		UpdateDeveloperStoreBuyItemFrame(index)
	elseif getglobal("DeveloperStoreMapPurchaseFrame"):IsShown() then
		OpenDevelopStoreItemSet()
	end
end

function DeveloperStoreBuyItemFrameCloseBtn_OnClick()
	getglobal("DeveloperStoreBuyItemFrame"):Hide();
	local mapid = G_GetFromMapid()
	standReportEvent("6001", "PROP_DETAILS", "Close", "click",{cid = tostring(mapid)})
end

---------------热更方法-----------------------
----function DeveloperStoreAdGetItem()
---------------热更方法-----------------------
function DeveloperStoreAdGetItem(ispassport,entryType)
	Log("----DeveloperStoreAdGetItem---")
	local propDef = nil
	local ishost = (IsRoomOwner() or AccountManager:getMultiPlayer() == 0)
	if ispassport and ishost then
		propDef = getPassPortDef()
	else
		propDef = GetInst("DevelopStoreDataManager"):GetCurClickPropDef()
	end
	if not propDef then return end

	local needNum = propDef.CostNum;
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
	local def = ModEditorMgr:getItemDefById(propDef.ItemID) or ModEditorMgr:getBlockItemDefById(propDef.ItemID) or ItemDefCsv:get(propDef.ItemID);
	if def == nil then
		ShowGameTips(GetS(23005), 3);
		return;
	end

	--给账号服传广告位，方便101和103分开统计
	local adPos = 101
	if ispassport and propDef.ItemID == ITEM_PASSPORT then
		adPos = 103
	end

	local extend_data = GetInst("ExternalRecommendMgr"):OrginazeDeveloperParam();
	local code = AccountManager:dev_mapbag_dev_ad_buy_item(0, authorUin, tostring(mapId), propDef.ItemID,1,propDef.Name, adPos, GetCurrentCSRoomId(), extend_data)
	if code == ErrorCode.OK then
		
		-- local finish_info = {
		-- 	map_Id  = mapId,
		-- 	map_version = mapversion,
		-- 	currency_id = propDef.CostType,
		-- 	currency_num = propDef.CostNum,
		-- 	item_Id = propDef.ItemID,
		-- 	item_name = propDef.Desc,
		-- 	item_num = 1,
		-- 	auth_uin = authorUin,
		-- }
		--print("=====================finish_info==================",finish_info)
		--AccountManager:ad_finish(101,finish_info);
		--if item is ITEM_PASSPORT, need to add passporttime
		SetPlayerPurchaseFlag(true, 4, 1);
		local b_report = false
		if propDef.ItemID == ITEM_PASSPORT then
			if propDef.PassPortInfo and #propDef.PassPortInfo == 4 and mapId > 0 then 
				local iEndTime = AccountManager:getCurWorldPassPortEndTime(mapId)
				if iEndTime >= -1 then
					local nowTime = AccountManager:getSvrTime()
					if iEndTime <= nowTime then
						iEndTime = AccountManager:getSvrTime() + propDef.PassPortInfo[1]*86400
					else
						iEndTime = iEndTime + propDef.PassPortInfo[1]*86400
					end
					AccountManager:setCurWorldPassPortEndTime(mapId, iEndTime)
					gPassPortEndTime = iEndTime
				end

				if getglobal("PassPortConfirmBuyFrame"):IsShown() then
					getglobal("PassPortConfirmBuyFrame"):Hide()
				end
				ShowGameTips(GetS(23010), 3)
				getglobal("PassPortBuySuccessFrame"):Show()
			end

			if not ispassport then
				b_report = true
			end
		else
			b_report = true
			DeveloperStoreBuyItemSuccess(propDef.ItemID, true)
		end
		if b_report then
			local entryType
			if IsAdUseNewLogic(101) then
				--StatisticsADNew('finish', 101,nil,authorUin,mapId, propDef.ItemID)
				entryType = ad_data_new.entryType
			else					
				StatisticsAD('finish', 101,nil,authorUin,mapId, propDef.ItemID)
				entryType = t_ad_data.entryType
			end
			--新埋点，根据不同来源做不同上报
			if mapId == nil or mapId == 0 then
				mapId = G_GetFromMapid()
			end
			local extra = {cid=tostring(mapId), standby3 = 101}
			if propDef then
				extra.standby1 = propDef.ItemID
				extra.standby2 = propDef.Name
			end
			if "DeveloperStore" == entryType then
				standReportEvent("6001", "PROP_DETAILS", "AdPurchaseButton", "ad_complete", extra)
			end
			if "TopPurchaseInMap" == entryType then
				standReportEvent("1003", "FAST_PURCHASE_POPUP", "AdPurchaseButton", "ad_complete", extra)
				standReportEvent("6001", "STORE_POPUP", "AdPurchaseButton", "ad_complete", extra)
			end
			if "TopPurchaseInMapOnline" == entryType then
				standReportEvent("1001", "FAST_PURCHASE_POPUP", "AdPurchaseButton", "ad_complete", extra)
				standReportEvent("6001", "STORE_POPUP", "AdPurchaseButton", "ad_complete", extra)
			end
		end
	elseif code == ErrorCode.DEV_MAPSTORE_CHEST_LEVEL_NOT_ENOUGH then 
		--{{{ 提示玩家家园多少级可以[Desc5]
		local lv = DevConfig and DevConfig.Config and DevConfig.Config.MinChestLevel 
		local sid = t_ErrorCodeToString[code]
		if sid and lv then 
			local s = GetS(sid, lv)
			if s and s ~= '' then ShowGameTips(s, 3) end
		end 
		--}}}
	else
		--提示了两次
		--ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
		return;
	end
end

function DeveloperStoreBuyItemSuccess(itemId, isExtract)
	if isExtract then
		--加载仓库
		LoadDeveloperStashPropList()
		--自动提取
		CurInputNumberVal = GetDeveloperStashPropNumByItemID(itemId)
		DeveloperExtractPropFrameConfirmBtn_OnClick(itemId, isExtract)
	else
		ShowGameTips(GetS(131), 3)
	end
end
--[Desc5]商品结果上报
function DeveloperStoreBuyItemStandReport(isSuccess,getItemType,entryType,propDef)
	local extra = {cid=tostring(G_GetFromMapid())}
	if propDef then
		extra.standby1 = propDef.ItemID
		extra.standby2 = propDef.Name
	end
	if isSuccess then
		if getItemType=="Buy" then--正常点击[Desc5]
			--新埋点，根据不同来源做不同上报
			if "DeveloperStore" == entryType then
				standReportEvent("6001", "PROP_DETAILS", "PurchaseButton", "purchase_succeed", extra)
			end
			if "TopPurchaseInMap" == entryType then
				standReportEvent("1003", "FAST_PURCHASE_POPUP", "PurchaseButton", "purchase_succeed", extra)
				standReportEvent("6001", "STORE_POPUP", "PurchaseButton", "purchase_succeed", extra)
			end
			if "TopPurchaseInMapOnline" == entryType then
				standReportEvent("1001", "FAST_PURCHASE_POPUP", "PurchaseButton", "purchase_succeed", extra)
				standReportEvent("6001", "STORE_POPUP", "PurchaseButton", "purchase_succeed", extra)
			end
		elseif  getItemType=="Ad" then--点击广告获取
		end
	else
		if getItemType=="Buy" then
			--新埋点，根据不同来源做不同上报
			if "DeveloperStore" == entryType then
				standReportEvent("6001", "PROP_DETAILS", "PurchaseButton", "purchase_failed", extra)
			end
			if "TopPurchaseInMap" == entryType then
				standReportEvent("1003", "FAST_PURCHASE_POPUP", "PurchaseButton", "purchase_failed", extra)
				standReportEvent("6001", "STORE_POPUP", "PurchaseButton", "purchase_failed", extra)
			end
			if "TopPurchaseInMapOnline" == entryType then
				standReportEvent("1001", "FAST_PURCHASE_POPUP", "PurchaseButton", "purchase_failed", extra)
				standReportEvent("6001", "STORE_POPUP", "PurchaseButton", "purchase_failed", extra)
			end
		elseif  getItemType=="Ad" then
		end
	end
end
function DeveloperStoreBuyItemFrameBuyBtn_OnClick()
	DeveloperStoreBuyItemFrameBuyBtn(nil,{isExtract = true, isClick = true})
end

--
function GetDeveloperStoreBuyItemMiniCoinCostNum(miniCoinData)
	if not miniCoinData then
		return 0
	end

	local costNum = 0
	if ClientMgr:getApiId() >= 300 then
		if ClientMgr:getApiId() == 307 and GetHuaweiLoginFlag()  then
			-- 只有当为海外华为渠道且已登录过华为账号，才能显示为本地货币
			-- 否则保持原来的美金显示，因为华为的接口默认返回人民币
			costNum = GetHuaweiPricesInfo();
		elseif ClientMgr:getApiId() == 336 then
			-- 如果为海外VIVO渠道，要乘以汇率并获取自己的货币符号
			local rate = vivoGetCurrencyRate();
			local code = vivoGetCurrencyCode();
			costNum = miniCoinData.Cost*rate
		else
			costNum = miniCoinData.Cost
		end
	else
		costNum = miniCoinData.Cost
	end

	local vipinfo = AccountManager:getAccountData():getVipInfo()
	if vipinfo then
		if isQQGame() then  --QQ大厅移动版/pc版 
			if isBlueVip(vipInfo) and vipInfo.vipLevel>=1 and vipInfo.vipLevel<=8 then
				costNum = miniCoinData.Cost * 0.8
			end
		elseif ClientMgr:getApiId() == 109 then --QQ空间
			if isYellowVip(vipInfo) and vipInfo.vipLevel>=1 and vipInfo.vipLevel<=8 then
				costNum = miniCoinData.Cost * 0.8
			end
		end
	end

	return costNum
end

function DeveloperStoreBuyItemForMoneyNotEnough(needNum, hasNum, itemID)
	local lackNum = needNum - hasNum

	local tCoinListDef = GetInst("ShopDataManager"):InitMiniCoinList()
	if tCoinListDef then
		local coinListDef = copy_table(tCoinListDef)
		--备注：用户首充赠送的迷你币不并入[Desc2]档位差值计算
		for k, v in pairs(coinListDef) do
			v.SrcNum = v.Num
			if v.MiniCoinWithLimit and v.MiniCoinWithLimit ~= 0 then
				v.SrcNum = v.MiniCoinWithLimit
			end
		end

		table.sort(coinListDef, function(a, b) return a.SrcNum < b.SrcNum end) -- 根据NUM排序

		local rechargeData = coinListDef[#coinListDef] --默认最大档
		for i=1, #coinListDef do
			print("lwtaoP coinListDef num = ", coinListDef[i].Num)
			if coinListDef[i].SrcNum >= lackNum then
				rechargeData = coinListDef[i]
				break
			end
		end

		local reportData = {standby1=itemID, standby2=rechargeData.Name, cid=tostring(G_GetFromMapid())}
		local function cb(btnName, data)
			if btnName == "right" and data then
				standReportEvent("6001", "PROP_DETAILS", "PROP_DETAILS_RECHARGE", "click", reportData)
				GetInst("DevelopStoreDataManager"):CreatePropRechargeEvent(reportData)
				-- getglobal("PayQrFrame"):Show() -- test
				-- getglobal("ChoosePayTypeFrame"):Show() -- test
				BuyMiniCoin(data)
			end
		end

		local costNum = GetDeveloperStoreBuyItemMiniCoinCostNum(rechargeData)
		rechargeAmount = costNum --需要充值的金额
		local text = GetS(453, costNum, rechargeData.Num);
		--加个参数过去 不让跳转
		local from = 1 --1开发者地图内[Desc5]
		StoreMsgBox(20, text, GetS(456), -1, lackNum, needNum, nil, cb, rechargeData, from)
		standReportEvent("6001", "PROP_DETAILS", "PROP_DETAILS_RECHARGE", "view", reportData)
		getglobal("StoreMsgboxFrame"):SetClientString("")
		-- getglobal("DeveloperStoreBuyItemFrame"):Hide();

		NotEnoughCoinDataName = rechargeData.Name
	end
end

local bItemCanBuy = false
local lastBuyTime = 0

function IsItemCanBuy()
	-- 距离上一次购买超过10s也给重新购买
	if os.time() - lastBuyTime >= 10 then
		return true
	end
	return bItemCanBuy
end

-- 道具是否被提取
function SetItemCanBuyAgain(bCan)
	bItemCanBuy = bCan
end

function DeveloperStoreBuyItemFrameBuyBtn(ispassport, param)
	-- 上一个可提取道具购买流程未完成
	if not IsItemCanBuy() then
		ShowGameTips(GetS(23206))
		return
	end
	
	NotEnoughCoinDataName = nil

	local ishost = (IsRoomOwner() or AccountManager:getMultiPlayer() == 0)
	local mapId = 0;
	if ishost then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		mapId = wdesc.fromowid;
		if wdesc.fromowid == 0 then
			mapId = wdesc.worldid;
		end
	else
		mapId = DeveloperFromOwid;
	end

	if not DeveloperStoreMapIsUpload(mapId) then
		ShowGameTipsWithoutFilter(GetS(23048))
		return
	end
	--是否自动提取
	isExtract = false
	if param and param.isExtract then
		isExtract = param.isExtract
	end

	-- 缓存当前选中索引和道具ID
	GetInst("DevelopStoreDataManager"):SetUserClickPropNumber(GetInst("DevelopStoreDataManager"):GetUserClickPropNumber(), param and param.propId)

	-- 可提取道具需要记录状态，等提取成功才算完成
	if isExtract then
		lastBuyTime = os.time() -- 记录当前购买时间
		SetItemCanBuyAgain(false)
	end
	
	local ishost = (IsRoomOwner() or AccountManager:getMultiPlayer() == 0)
	local propDef = GetDeveloperStorePropDef(ispassport, ishost, param)

	if not propDef then return end

	local needNum = propDef.CostNum;
	if propDef.Tag == g_DeveloperConfig.Developer.TagType.Discount then
		needNum = propDef.DiscountCostNum
	end

	local mapId = 0;
	local authorUin = 0;

	if ishost then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		mapId = wdesc.fromowid;
		authorUin = getFromOwid(wdesc.fromowid);
		if wdesc.fromowid == 0 then
			mapId = wdesc.worldid;
			authorUin = AccountManager:getUin()
		end
	else
		mapId = DeveloperFromOwid;
		authorUin = getFromOwid(mapId)
	end

	local entryType = "DeveloperStore";
	if param and param.entryType then
		entryType = param.entryType
	end

	local def = ModEditorMgr:getItemDefById(propDef.ItemID) or ModEditorMgr:getBlockItemDefById(propDef.ItemID) or ItemDefCsv:get(propDef.ItemID);
	if def == nil then
		ShowGameTips(GetS(23005), 3);
		DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
		return;
	end

	if param.isClick then
		standReportEvent("6001", "PROP_DETAILS", "PurchaseButton", "click",{cid = tostring(G_GetFromMapid()), standby1 = propDef.ItemID, standby2 = propDef.Name})
	end

	local buyBtn = getglobal("DeveloperStoreBuyItemFrameBuyBtn");
	buyBtn:Disable()

	local buy_ok = false
	if propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.Money then						
		local hasNum = AccountManager:getAccountData():getMiniCoin();
		if hasNum >= needNum then
			local wdesc = AccountManager:getCurWorldDesc();
			local extend_data = GetInst("ExternalRecommendMgr"):OrginazeDeveloperParam();

			local reportInfo = {
				scene_id = "6001",
				card_id = "PROP_DETAILS",
				comp_id = "PurchaseButton",
				trace_id = "",
			}
			local code = AccountManager:dev_mapbag_buy_item(0, authorUin, mapId, propDef.ItemID, 1, GetCurrentCSRoomId(), extend_data,reportInfo);

			if code == ErrorCode.OK then
				buy_ok = true
				-- 累计消费活动-金币购买物品任务上报
				local aggActInterface = GetInst("AggActInterface")
				if aggActInterface then
					aggActInterface:SetAggDevShopTaskFinish()
				end
				
				--if item is ITEM_PASSPORT, need to add passporttime
				SetPlayerPurchaseFlag(true, 1, needNum);
				if propDef.ItemID == ITEM_PASSPORT then
					if propDef.PassPortInfo and #propDef.PassPortInfo == 4 then
						local iEndTime = AccountManager:getCurWorldPassPortEndTime(mapId)
						if iEndTime >= -1 then
							local nowTime = AccountManager:getSvrTime()
							if iEndTime <= nowTime then
								iEndTime = AccountManager:getSvrTime() + propDef.PassPortInfo[1]*86400
							else
								iEndTime = iEndTime + propDef.PassPortInfo[1]*86400
							end
							AccountManager:setCurWorldPassPortEndTime(mapId, iEndTime)
							gPassPortEndTime = iEndTime
						end

						if getglobal("PassPortConfirmBuyFrame"):IsShown() then
							getglobal("PassPortConfirmBuyFrame"):Hide()
						end
					end
					ShowGameTips(GetS(23010), 3)
					getglobal("PassPortBuySuccessFrame"):Show()
				else
					DeveloperStoreBuyItemSuccess(propDef.ItemID, isExtract)
				end
				DeveloperStoreBuyItemStandReport(true,"Buy",entryType, propDef)
			elseif code == ErrorCode.DEV_MAPSTORE_CHEST_LEVEL_NOT_ENOUGH then
				--{{{ 提示玩家家园多少级可以[Desc5]
				local lv = other and DevConfig and DevConfig.Config and DevConfig.Config.MinChestLevel
				local sid = t_ErrorCodeToString[code]
				if sid and lv then
					local s = GetS(sid, lv)
					if s and s ~= '' then ShowGameTips(s, 3) end
				end
				--}}}
				DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
			else
				--ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
				DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
				SetItemCanBuyAgain(true)
				buyBtn:Enable()
				return;
			end
		else
			if propDef.ItemID == ITEM_PASSPORT then
				ShowGameTips(GetS(456), 3)
			else
				DeveloperStoreBuyItemForMoneyNotEnough(needNum, hasNum, propDef.ItemID)
			end
			DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
		end
	elseif propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.Coin then
		local hasNum = AccountManager:getAccountData():getMiniBean();
		if hasNum >= needNum then
			local extend_data = GetInst("ExternalRecommendMgr"):OrginazeDeveloperParam();
			local reportInfo = {
				scene_id = "6001",
				card_id = "PROP_DETAILS",
				comp_id = "PurchaseButton",
				trace_id = "",
			}
			local code = AccountManager:dev_mapbag_buy_item(0, authorUin, mapId, propDef.ItemID, 1, GetCurrentCSRoomId(), extend_data,reportInfo)
			if code == ErrorCode.OK then
				buy_ok = true
				SetPlayerPurchaseFlag(true, 2, needNum);
				DeveloperStoreBuyItemSuccess(propDef.ItemID, isExtract)
				DeveloperStoreBuyItemStandReport(true,"Buy",entryType, propDef)
			elseif code == ErrorCode.DEV_MAPSTORE_CHEST_LEVEL_NOT_ENOUGH then 
				--{{{ 提示玩家家园多少级可以[Desc5]
				local lv = DevConfig and DevConfig.Config and DevConfig.Config.MinChestLevel 
				local sid = t_ErrorCodeToString[code]
				if sid and lv then 
					local s = GetS(sid, lv)
					if s and s ~= '' then ShowGameTips(s, 3) end 
				end 
				--}}}
				DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
			else
				--ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
				DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
				SetItemCanBuyAgain(true)
				buyBtn:Enable()
				return;
			end
			--扣星星
		else
			ShowGameTipsWithoutFilter(GetS(23008), 3);
			DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
		end
	elseif propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then
		local miniPoint = AccountManager:getAccountData():getADPoint()
		if miniPoint >= needNum then
			local extend_data = GetInst("ExternalRecommendMgr"):OrginazeDeveloperParam();
			local reportInfo = {
				scene_id = "6001",
				card_id = "PROP_DETAILS",
				comp_id = "PurchaseButton",
				trace_id = "",
			}
			local code = AccountManager:dev_mapbag_dev_adpoint_buy_item(0, authorUin, mapId, propDef.ItemID, 1, propDef.Desc, GetCurrentCSRoomId(), extend_data,reportInfo)
			if code == ErrorCode.OK then
				buy_ok = true
				SetPlayerPurchaseFlag(true, 3, needNum);
				DeveloperStoreBuyItemSuccess(propDef.ItemID, isExtract)
				DeveloperStoreBuyItemStandReport(true,"Buy",entryType, propDef)
			else
				--ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
				DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
			end
		else
			if ClientMgr:isPC() then
				ShowGameTipsWithoutFilter(GetS(23045));
			else
				ShowGameTipsWithoutFilter(GetS(30113));
			end
			DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
		end
	elseif propDef.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
		local btnId = 0
		if param and param.tid then
			btnId = param.tid
		else
			btnId = this:GetClientID()
		end	
		if btnId == 2 then
			local hasNum = AccountManager:getAccountData():getMiniCoin();
			if hasNum >= needNum then
				local extend_data = GetInst("ExternalRecommendMgr"):OrginazeDeveloperParam();
				local reportInfo = {
					scene_id = "6001",
					card_id = "PROP_DETAILS",
					comp_id = "PurchaseButton",
					trace_id = "",
				}
				local code = AccountManager:dev_mapbag_buy_item(0, authorUin, mapId, propDef.ItemID, 1, GetCurrentCSRoomId(), extend_data,reportInfo)

				if code == ErrorCode.OK then
					buy_ok = true
					SetPlayerPurchaseFlag(true, 1, needNum);
					--if item is ITEM_PASSPORT, need to add passporttime
					if propDef.ItemID == ITEM_PASSPORT then
						if propDef.PassPortInfo and #propDef.PassPortInfo == 4 then
							local iEndTime = AccountManager:getCurWorldPassPortEndTime(mapId)
							if iEndTime >= -1 then
								local nowTime = AccountManager:getSvrTime()
								if iEndTime <= nowTime then
									iEndTime = AccountManager:getSvrTime() + propDef.PassPortInfo[1]*86400
								else
									iEndTime = iEndTime + propDef.PassPortInfo[1]*86400
								end
								AccountManager:setCurWorldPassPortEndTime(mapId, iEndTime)
								gPassPortEndTime = iEndTime
							end

							if getglobal("PassPortConfirmBuyFrame"):IsShown() then
								getglobal("PassPortConfirmBuyFrame"):Hide()
							end
						end
						ShowGameTips(GetS(23010), 3)
						getglobal("PassPortBuySuccessFrame"):Show()
					else
						DeveloperStoreBuyItemSuccess(propDef.ItemID, isExtract)
					end
					DeveloperStoreBuyItemStandReport(true,"Buy",entryType, propDef)
				elseif code == ErrorCode.DEV_MAPSTORE_CHEST_LEVEL_NOT_ENOUGH then
					--{{{ 提示玩家家园多少级可以[Desc5]
					local lv = other and DevConfig and DevConfig.Config and DevConfig.Config.MinChestLevel
					local sid = t_ErrorCodeToString[code]
					if sid and lv then
						local s = GetS(sid, lv)
						if s and s ~= '' then ShowGameTips(s, 3) end
					end
					--}}}
					DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
				else
					--ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
					DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
					SetItemCanBuyAgain(true)
					buyBtn:Enable()
					return;
				end
			else
				if propDef.ItemID == ITEM_PASSPORT then
					ShowGameTips(GetS(456), 3)
				else
					DeveloperStoreBuyItemForMoneyNotEnough(needNum, hasNum, propDef.ItemID)
				end
				DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
			end
		elseif btnId == 3 then
			local miniPoint = AccountManager:getAccountData():getADPoint()
			needNum = propDef.MiniPoint or 0
			if miniPoint >= needNum then
				local extend_data = GetInst("ExternalRecommendMgr"):OrginazeDeveloperParam();
				local reportInfo = {
					scene_id = "6001",
					card_id = "PROP_DETAILS",
					comp_id = "PurchaseButton",
					trace_id = "",
				}
				local code = AccountManager:dev_mapbag_dev_adpoint_buy_item(0, authorUin, mapId, propDef.ItemID, 1, propDef.Desc, GetCurrentCSRoomId(), extend_data,reportInfo)
				if code == ErrorCode.OK then
					buy_ok = true
					SetPlayerPurchaseFlag(true, 3, needNum);
					DeveloperStoreBuyItemSuccess(propDef.ItemID, isExtract)
					DeveloperStoreBuyItemStandReport(true,"Buy",entryType, propDef)
				else
					--ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
					DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
				end
			else
				if ClientMgr:isPC() then
					ShowGameTipsWithoutFilter(GetS(23045));
				else
					ShowGameTipsWithoutFilter(GetS(30113));
				end
				DeveloperStoreBuyItemStandReport(false,"Buy",entryType, propDef)
			end
		end
	end

	--购买成功 更新一下剩余量
	if buy_ok and ((propDef.LimitTimeSaleNum and propDef.LimitTimeSaleNum > 0) or (propDef.LimitBuyNum and propDef.LimitBuyNum > 0)) then
		DoUpateStoreItem(authorUin, mapId, propDef.ItemID, nil, function() 
			if (propDef.LimitTimeSaleNum and propDef.LimitTimeSaleNum > 0) then
				--更新购买面板
				UpdateDeveloperStoreBuyItemFrameActDesc(GetInst("DevelopStoreDataManager"):GetUserClickPropNumber())

				--更新购买列表的数据
				buildStoreSkuList()
			end
		end)
	end

	-- 可提取道具购买失败，恢复按钮可点击状态
	if (not buy_ok and isExtract) then
		SetItemCanBuyAgain(true)
	end

	buyBtn:Enable()
end

function DeveloperStoreBuyItemFrame_OnShow()
	-- getglobal("DeveloperStoreFramePropBox"):setDealMsg(false)
	getglobal("DeveloperStoreSkuFrameList"):setDealMsg(false)
	getglobal("DeveloperStoreSkuFramePropTypeList"):setDealMsg(false)
	standReportEvent("6001", "PROP_DETAILS", "-", "view",{slot=GetInst("DevelopStoreDataManager"):GetUserClickPropNumber(),cid = tostring(G_GetFromMapid())})
	standReportEvent("6001", "PROP_DETAILS", "Close", "view",{cid = tostring(G_GetFromMapid())})
	standReportEvent("6001", "PROP_DETAILS", "PurchaseButton", "view",{cid = tostring(G_GetFromMapid())})
	standReportEvent("6001", "PROP_DETAILS", "AdPurchaseButton", "view",{cid = tostring(G_GetFromMapid())})
end

function DeveloperStoreBuyItemFrame_OnHide()
	-- getglobal("DeveloperStoreFramePropBox"):setDealMsg(true)
	getglobal("DeveloperStoreSkuFrameList"):setDealMsg(true)
	getglobal("DeveloperStoreSkuFramePropTypeList"):setDealMsg(true)
end

------------------------------------------------商品设置页面----------------------------------------------------------------
function DeveloperStoreItemSetFrame_OnLoad()
	-- getglobal("SingleEditorSelection1"):Show();
	-- getglobal("SingleEditorSelection1"):SetPoint("topleft", "DeveloperStoreMapPurchaseFramePropBoxPlane", "topleft", 490, 135);
	-- getglobal("ChooseOriginalFrame"):Show();
	getglobal("DeveloperStoreItemSetFrameTitleName"):SetText(GetS(21641),61,69,70)
end

function DeveloperStoreItemSetFrame_OnShow()
	-- local itemDef = ItemDefCsv:get(DeveloperPropList[1].ID);

	getglobal("DeveloperStoreItemSetFrameSelectItemBtnDel"):Hide();
	getglobal("DeveloperStoreItemSetFrameSelectItemBtnAddIcon"):Hide()
	if GetInst("DevelopStoreDataManager"):GetIsSelectAddPropBtn()  then
		CurSelectADExchange = 0
		CurGroupTypeID = gStoreGroupTypList[gSelectPropType]
		if not CurGroupTypeID then CurGroupTypeID = 1 end
		CleanDeveloperStoreSetView()
	else
		UpdateCurSelectPropValue();
	end

	getglobal("DeveloperStoreMapPurchaseFramePropBox"):setDealMsg(false)
end
function DeveloperStoreItemSetFrame_OnHide()
	GetInst("DevelopStoreDataManager"):SetIsSelectAddPropBtn(false)
	getglobal("DeveloperStoreMapPurchaseFramePropBox"):setDealMsg(true)
end

local listItemInfo = 
{
	[1] = {name="MoneyType", x=230},
	[2] = {name="ItemLable", x=230},
	[3] = {name="PropType", x=230},
	[4] = {name="Value3", x=113},
	[5] = {name="Value", x=113},
	[6] = {name="Value1", x=113},
	[7] = {name="Value2", x=113},
	[8] = {name="SliderBar1", x=13},
	[9] = {name="SliderBar2", x=13},
	[10] = {name="SliderBar3", x=13},
	[11] = {name="SliderBar4", x=13},
	[12] = {name="Switch", x=113},
}
function loadDetailListItem(showlist)
	if not showlist then return end

	local totalsize, item = #listItemInfo, nil
	local height, h = 25, 30
	for i=1,totalsize do
		item = getglobal("DeveloperStoreItemSetFrame"..listItemInfo[i].name)
		if showlist[i] then
			item:Show()
			item:SetPoint("topleft", "DeveloperStoreItemSetFrameDetailListPlane", "topleft", listItemInfo[i].x, height)
			height = height + h + item:GetHeight()
		else
			item:Hide()
		end
	end

	local listPanel = getglobal("DeveloperStoreItemSetFrameDetailListPlane")
	listPanel:SetHeight(height)
end

function CleanDeveloperStoreSetView()
	getglobal("DeveloperStoreItemSetFrameSelectItemBtnIcon"):Hide();
	getglobal("DeveloperStoreItemSetFrameSelectItemBtnAddIcon"):Show()
	getglobal("DeveloperStoreItemSetFrameDescription"):SetText("");
	getglobal("DeveloperStoreItemSetFrameItemName"):SetText("");
	-- getglobal("DeveloperStoreItemSetFrameTitleName"):SetText(GetS(21641),61,69,70)
	-- getglobal("DeveloperStoreItemSetFrameValueVal"):SetText("1");
	local code = 1001;
	local info = nil;
	local cfg =nil;
	if g_DeveloperInfo then
		code = ErrorCode.OK
		cfg = g_DeveloperInfo;
	else
		code, info, cfg = AccountManager:dev_developer_info(AccountManager:getUin());
		if info and info.Level ~= nil then
			GetInst("DevelopStoreDataManager"):SetUserLevel(info.Level)
		end
	end
	if code == ErrorCode.OK then
		local maxMiniCoinPrice = cfg.LimitMapStoreItemMiniCoinPrice-1
		getglobal("DeveloperStoreItemSetFrameValueBar"):SetMaxValue(maxMiniCoinPrice);
		getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMaxValue(maxMiniCoinPrice);
	end
	getglobal("DeveloperStoreItemSetFrameValueBar"):SetValue(9)
	getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetValue(8);

	getglobal("DeveloperStoreItemSetFrameMoneyTypeName"):SetText(GetS(74));
	getglobal("DeveloperStoreItemSetFrameItemLableName"):SetText(GetS(21611));
	getglobal("DeveloperStoreItemSetFramePropTypeName"):SetText(getGroupTypeName(CurGroupTypeID))
	TemplateSwitchBtn_SetState("DeveloperStoreItemSetFrameAdSwitchBtn", 0, true);
	freshDeveloperStoreItemSetFrame(g_DeveloperConfig.Developer.TagType.None,true)
end

function resetSetFrame(bShow)
	local code = 1001;
	local info = nil;
	local cfg =nil;
	if g_DeveloperInfo then
		code = ErrorCode.OK
		cfg = g_DeveloperInfo;
	else
		code, info, cfg = AccountManager:dev_developer_info(AccountManager:getUin());
		if info and info.Level ~= nil then
			GetInst("DevelopStoreDataManager"):SetUserLevel(info.Level)
		end
	end
	if code == ErrorCode.OK then
		local maxMiniCoinPrice = cfg.LimitMapStoreItemMiniCoinPrice-1
		getglobal("DeveloperStoreItemSetFrameValueBar"):SetMaxValue(maxMiniCoinPrice);
		getglobal("DeveloperStoreItemSetFrameValueBar"):SetMinValue(0)
	end
	getglobal("DeveloperStoreItemSetFrameValueBar"):SetValue(9)
	CurSelectPropCurrencyType = g_DeveloperConfig.Developer.CurrencyType.Money
	CurSelectPropTag = 1
	-- CurGroupTypeID = gStoreGroupTypList[gSelectPropType]
	if not CurGroupTypeID then CurGroupTypeID = 1 end

	getglobal("DeveloperStoreItemSetFrameMoneyTypeName"):SetText(GetS(74))
	getglobal("DeveloperStoreItemSetFrameItemLableName"):SetText(GetS(58))
	getglobal("DeveloperStoreItemSetFramePropTypeName"):SetText(getGroupTypeName(CurGroupTypeID))
	TemplateSwitchBtn_SetState("DeveloperStoreItemSetFrameAdSwitchBtn", 0, true);
	freshDeveloperStoreItemSetFrame(g_DeveloperConfig.Developer.TagType.None,true, bShow)
end

function managePassPortView(bShow)
	if bShow then
		-- loadDetailListItem({[1]=1, [2]=2, [3]=3, [6]=6, [7]=7, [8]=8, [9]=9, [10]=10})
		loadDetailListItem({[1]=1, [2]=2, [3]=3, [5]=5,  [8]=8, [9]=9, [10]=10, [11]=11,[12]=12})
	end

	for i=1,4 do
		setSliderBar(i, bShow)
	end
end

local sliderMaxValue = {[1]={max_val=90, name=GetS(21621)}, [2]={min_val = 60, max_val=360, name=GetS(21620)}, [3]={max_val=365, name=GetS(21619)}, [4]={max_val=10, name=GetS(21618)}}
function setSliderBar(sliderIdx, bShow)
	local sliderBar = getglobal("DeveloperStoreItemSetFrameSliderBar"..sliderIdx)
	if not sliderBar or sliderIdx > #gPassPortInfo then return end

	if not bShow then
		sliderBar:Hide()
		return
	end

	local sliderName = getglobal(sliderBar:GetName().."Name")
	sliderName:SetText(sliderMaxValue[sliderIdx].name)

	local bar = getglobal(sliderBar:GetName().."Bar")
	bar:SetMinValue(sliderMaxValue[sliderIdx].min_val or 1)
	bar:SetMaxValue(sliderMaxValue[sliderIdx].max_val)
	bar:SetValue(gPassPortInfo[sliderIdx])

	sliderBar:Show()
end

function freshDeveloperStoreItemSetFrame(tag,isFirst, bShowPassport)
	local moneyItem = getglobal("DeveloperStoreItemSetFrameMoneyType")
	local labelItem = getglobal("DeveloperStoreItemSetFrameItemLable")
	local lable = getglobal("DeveloperStoreItemSetFrameItemLableName")
	local bar  = getglobal("DeveloperStoreItemSetFrameValue")
	local barName = getglobal("DeveloperStoreItemSetFrameValueName")
	local bar1 = getglobal("DeveloperStoreItemSetFrameValue1")
	local bar1Name = getglobal("DeveloperStoreItemSetFrameValue1Name")
	local bar2 = getglobal("DeveloperStoreItemSetFrameValue2")
	local bar2Name = getglobal("DeveloperStoreItemSetFrameValue2Name")
	local adItem = getglobal("DeveloperStoreItemSetFrameAdSwitchBtn")
	local adtext = getglobal("DeveloperStoreItemSetFrameTitleName")
	if tag == g_DeveloperConfig.Developer.TagType.None then
		lable:SetText(GetS(21611));
	elseif tag == g_DeveloperConfig.Developer.TagType.Hot then
		lable:SetText(GetS(21670));
	elseif tag == g_DeveloperConfig.Developer.TagType.New then
		lable:SetText(GetS(21671));
	elseif tag == g_DeveloperConfig.Developer.TagType.Recommend then
		lable:SetText(GetS(21629));
	elseif tag == g_DeveloperConfig.Developer.TagType.Popular then
		lable:SetText(GetS(21630));
	elseif tag == g_DeveloperConfig.Developer.TagType.Timelimit then
		lable:SetText(GetS(21631));
	elseif tag == g_DeveloperConfig.Developer.TagType.Discount then
		lable:SetText(GetS(21632));
	end
	if tag == g_DeveloperConfig.Developer.TagType.Timelimit then
		-- bar1:Show()
		-- bar2:Hide()
		-- adItem:Show()
		-- adtext:Show()
		-- loadDetailListItem({[1]=1, [2]=2, [3]=3, [4]=4, [10]=10})
		if CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
			loadDetailListItem({[1]=1, [2]=2, [3]=3, [4]=4, [5]=5,[6]=6})
			barName:SetText(GetS(23043));
			getglobal("DeveloperStoreItemSetFrameValue3Name"):SetText(GetS(23044));
			bar1Name:SetText(GetS(21623))
		else
			loadDetailListItem({[1]=1, [2]=2, [3]=3, [5]=5, [6]=6, [12]=12})
			barName:SetText(GetS(21666))
			bar1Name:SetText(GetS(21623))
		end


		if isFirst then
			getglobal("DeveloperStoreItemSetFrameValue1Bar"):SetValue(7);
		else
			getglobal("DeveloperStoreItemSetFrameValue1Bar"):SetValue(CurSelectPropTimeLimit);
		end
	elseif tag == g_DeveloperConfig.Developer.TagType.Discount then
		-- bar1:Show()
		-- bar2:Show()
		-- adItem:Hide()
		-- adtext:Hide()
		loadDetailListItem({[1]=1, [2]=2, [3]=3, [5]=5, [6]=6, [7]=7})

		barName:SetText(GetS(21627))
		bar1Name:SetText(GetS(21635))
		bar2Name:SetText(GetS(21633))
		bar2Name:resizeRect(81,24)
		if isFirst then
			getglobal("DeveloperStoreItemSetFrameValue1Bar"):SetValue(7);
			getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetValue(9);
		else
			getglobal("DeveloperStoreItemSetFrameValue1Bar"):SetValue(CurSelectPropTimeLimit);
			getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetValue(CurSelectPropDiscount);
		end
	else
		-- bar1:Hide()
		-- bar2:Hide()
		-- adItem:Show()
		-- adtext:Show()

		if CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
			managePassPortView(bShowPassport)
			if not bShowPassport then
				-- loadDetailListItem({[1]=1, [2]=2, [3]=3, [10]=10})
				loadDetailListItem({[1]=1, [2]=2, [3]=3, [4]=4,[5]=5})
			end
			barName:SetText(GetS(23043));
			getglobal("DeveloperStoreItemSetFrameValue3Name"):SetText(GetS(23044));
		else
			managePassPortView(bShowPassport)
			if not bShowPassport then
				-- loadDetailListItem({[1]=1, [2]=2, [3]=3, [10]=10})
				loadDetailListItem({[1]=1, [2]=2, [3]=3, [5]=5, [12]=12})
			end
			barName:SetText(GetS(21666))
		end
	end
	getglobal("DeveloperStoreItemSetFrameValue1Bar"):SetMaxValue(90);
	if get_game_env() == 1 then
		getglobal("DeveloperStoreItemSetFrameValue1Bar"):SetMinValue(1);
	else
		getglobal("DeveloperStoreItemSetFrameValue1Bar"):SetMinValue(7);
	end
	
end
 
function UpdateCurSelectPropValue()
	local icon = getglobal("DeveloperStoreItemSetFrameSelectItemBtnIcon")
	local moneyType = getglobal("DeveloperStoreItemSetFrameMoneyTypeName")
	local lable = getglobal("DeveloperStoreItemSetFrameItemLableName")
	local valFont = getglobal("DeveloperStoreItemSetFrameValueVal");
	local name = getglobal("DeveloperStoreItemSetFrameItemName")
	local desc = getglobal("DeveloperStoreItemSetFrameDescription")
	local propType = getglobal("DeveloperStoreItemSetFramePropTypeName")


	local moneyItem = getglobal("DeveloperStoreItemSetFrameMoneyType")
	local labelItem = getglobal("DeveloperStoreItemSetFrameItemLable")
	local bar  = getglobal("DeveloperStoreItemSetFrameValueBar")
	local bar1 = getglobal("DeveloperStoreItemSetFrameValue1")
	local bar2 = getglobal("DeveloperStoreItemSetFrameValue2")
	local adItem = getglobal("DeveloperStoreItemSetFrameAdSwitchBtn")
	local adtext = getglobal("DeveloperStoreItemSetFrameTitleName")

	local propInfo = GetInst("DevelopStoreDataManager"):GetCurClickPropDef()
	if not propInfo then return end

	local id = propInfo.ItemID
	local def = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);
	icon:Show();
	if def == nil then
		SetItemIcon(icon, 0);
		name:SetText(GetS(23002));
		desc:SetText(GetS(23002));
	else
		SetItemIcon(icon, id);
		name:SetText(def.Name);
		desc:SetText(def.Desc);
	end

	CurSelectPropCurrencyType = propInfo.CostType
	CurSelectPropTag = propInfo.Tag
	CurSelectPropValue = propInfo.CostNum
	CurSelectPropMiniPointValue = propInfo.MiniPoint

	local code = 1001;
	local info = nil;
	local cfg =nil;
	if g_DeveloperInfo then
		code = ErrorCode.OK
		cfg = g_DeveloperInfo;
	else
		code, info, cfg = AccountManager:dev_developer_info(AccountManager:getUin());
		if info and info.Level ~= nil then
			GetInst("DevelopStoreDataManager"):SetUserLevel(info.Level)
		end
	end
	if CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.Money then
		moneyType:SetText(GetS(74));
		if code == ErrorCode.OK then
			getglobal("DeveloperStoreItemSetFrameValueBar"):SetMaxValue(cfg.LimitMapStoreItemMiniCoinPrice-1);
			getglobal("DeveloperStoreItemSetFrameValueBar"):SetMinValue(0);
			getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMaxValue(cfg.LimitMapStoreItemMiniCoinPrice-1);
			getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMinValue(0);
		end
	elseif CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.Coin then 
		moneyType:SetText(GetS(372));
		if code == ErrorCode.OK then
			getglobal("DeveloperStoreItemSetFrameValueBar"):SetMaxValue(cfg.LimitMapStoreItemMiniBeanPrice-1);
			getglobal("DeveloperStoreItemSetFrameValueBar"):SetMinValue(4);
			getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMaxValue(cfg.LimitMapStoreItemMiniBeanPrice-1);
			getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMinValue(3);
		end
	elseif CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then
		moneyType:SetText(GetS(23042));
		if code == ErrorCode.OK then
			getglobal("DeveloperStoreItemSetFrameValueBar"):SetMaxValue(cfg.LimitMapStoreItemMiniPointPrice-1);
			getglobal("DeveloperStoreItemSetFrameValueBar"):SetMinValue(4);
			getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMaxValue(cfg.LimitMapStoreItemMiniPointPrice-1);
			getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMinValue(4);
		end
	elseif CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
		local text = GetS(23042).."+"..GetS(74);
		moneyType:SetText(text);
		if code == ErrorCode.OK then
			getglobal("DeveloperStoreItemSetFrameValueBar"):SetMaxValue(cfg.LimitMapStoreItemMiniCoinPrice-1);
			getglobal("DeveloperStoreItemSetFrameValueBar"):SetMinValue(0);
			getglobal("DeveloperStoreItemSetFrameValue3Bar"):SetMaxValue(cfg.LimitMapStoreItemMiniPointPrice-1);
			getglobal("DeveloperStoreItemSetFrameValue3Bar"):SetMinValue(4);
			if CurSelectPropMiniPointValue then
				getglobal("DeveloperStoreItemSetFrameValue3Bar"):SetValue(CurSelectPropMiniPointValue-0.7);
			else
				getglobal("DeveloperStoreItemSetFrameValue3Bar"):SetValue(9);
			end

		end
	end

	if propInfo.Tag == g_DeveloperConfig.Developer.TagType.None then
		lable:SetText(GetS(21611));
	elseif propInfo.Tag == g_DeveloperConfig.Developer.TagType.Hot then
		lable:SetText(GetS(21670));
	elseif propInfo.Tag == g_DeveloperConfig.Developer.TagType.New then
		lable:SetText(GetS(21671));
	elseif propInfo.Tag == g_DeveloperConfig.Developer.TagType.Recommend then
		lable:SetText(GetS(21629));
	elseif propInfo.Tag == g_DeveloperConfig.Developer.TagType.Popular then
		lable:SetText(GetS(21630));
	elseif propInfo.Tag == g_DeveloperConfig.Developer.TagType.Timelimit then
		propInfo.PropCurTime = propInfo.LimitEnd - utils.ts2day(getServerNow())
		local str = GetS(21610, propInfo.PropCurTime)
		lable:SetText(str);
	elseif propInfo.Tag == g_DeveloperConfig.Developer.TagType.Discount then
		if propInfo.LimitStart ~= propInfo.LimitEnd then
			propInfo.PropCurTime = propInfo.LimitEnd - utils.ts2day(getServerNow())
			local str = GetS(21610, propInfo.PropCurTime)
			lable:SetText(str);
		else
			lable:SetText(GetS(21632));
		end
	end

	CurGroupTypeID = propInfo.ItemGroup == nil and 1 or propInfo.ItemGroup
	propType:SetText(getGroupTypeName(CurGroupTypeID))
	adtext:SetText(GetS(21641))
	TemplateSwitchBtn_SetState("DeveloperStoreItemSetFrameAdSwitchBtn", propInfo.ADExchange, true);

	if propInfo.ADExchange then
		CurSelectADExchange = propInfo.ADExchange
	end
	if propInfo.LimitStart ~= propInfo.LimitEnd then
		CurSelectPropTimeLimit = propInfo.LimitEnd - propInfo.LimitStart
	end
	if propInfo.DiscountCostNum then
		CurSelectPropDiscount = propInfo.DiscountCostNum
	end
	getglobal("DeveloperStoreItemSetFrameValueBar"):SetValue(CurSelectPropValue-0.7);
	freshDeveloperStoreItemSetFrame(CurSelectPropTag, false, id == ITEM_PASSPORT)
	getglobal("DeveloperChooseOriginalFrameOkBtn"):SetClientID(id);
end

function cleanPropSetInfo()
	CurSelectPropValue = 0;
	CurSelectPropTag = g_DeveloperConfig.Developer.TagType.None;
end

function DeveloperStoreItemSetFrameDetermineBtn_OnClick()
	local id = getglobal("DeveloperChooseOriginalFrameOkBtn"):GetClientID();	--ClientID记录了选择的掉落物ID;
	local StoreSkuList = GetInst("DevelopStoreDataManager"):GetStoreSkuList()
	--存在相同商品
	if GetInst("DevelopStoreDataManager"):GetIsSelectAddPropBtn() then--新增
		for i=1,#StoreSkuList do
			if StoreSkuList[i].ItemID == id then
				ShowGameTips(GetS(23006), 3)
				return
			end
		end
	else--修改
		local skuinfo = GetInst("DevelopStoreDataManager"):GetCurClickPropDef()
		if not skuinfo then return end

		for i=1,#StoreSkuList do
			if skuinfo.RealPos ~= StoreSkuList[i].RealPos then
				if StoreSkuList[i].ItemID == id then
					ShowGameTips(GetS(23006), 3)
					return
				end
			end
		end
	end
	
	if CurSelectPropTag == g_DeveloperConfig.Developer.TagType.Discount and CurSelectPropDiscount >= CurSelectPropValue then
			ShowGameTips(GetS(21607), 3)
			return
	end
		

	local def = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);
	if not def then 
		-- ShowGameTips("请选择一个道具", 3)
		getglobal("DeveloperStoreItemSetFrame"):Hide();
		return 
	end
	-- DeveloperCurSelectUICallBack(id);

	if id == ITEM_PASSPORT then
		if #gPassPortInfo < 4 then return end

		if gPassPortInfo[1] > gPassPortInfo[3] then
			ShowGameTips(GetS(21603), 3)
			return
		end
	end
---------------------------------------------------------------------------------------------------------
	if GetInst("DevelopStoreDataManager"):GetIsSelectAddPropBtn()  then
		local DeveloperPropAttrTemp = GetInst("DevelopStoreDataManager"):GetDeveloperPropAttr()
		DeveloperPropAttrTemp.Name = def.Name;
		DeveloperPropAttrTemp.ItemID = id;
		DeveloperPropAttrTemp.Desc = def.Desc;
		if CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then
			DeveloperPropAttrTemp.ADExchange = CurSelectADExchange;
			DeveloperPropAttrTemp.CostNum = CurSelectPropValue;--实际服务器用CostNum这个字段
			DeveloperPropAttrTemp.MiniPoint = CurSelectPropValue;
		elseif CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
			DeveloperPropAttrTemp.ADExchange = 0;
			DeveloperPropAttrTemp.CostNum = CurSelectPropValue;
			DeveloperPropAttrTemp.MiniPoint = CurSelectPropMiniPointValue;
		else
			DeveloperPropAttrTemp.ADExchange = CurSelectADExchange;
			DeveloperPropAttrTemp.CostNum = CurSelectPropValue;
			DeveloperPropAttrTemp.MiniPoint = 0;
		end

		DeveloperPropAttrTemp.Tag =CurSelectPropTag;
		DeveloperPropAttrTemp.CostType =CurSelectPropCurrencyType;
		DeveloperPropAttrTemp.LimitEnd = utils.ts2day(getServerNow()+CurSelectPropTimeLimit*3600*24)
		DeveloperPropAttrTemp.DiscountCostNum = CurSelectPropDiscount
		DeveloperPropAttrTemp.LimitStart = utils.ts2day(getServerNow())
		DeveloperPropAttrTemp.ItemGroup = CurGroupTypeID
		DeveloperPropAttrTemp.RealPos = #StoreSkuList + 1
		if id == ITEM_PASSPORT then
			DeveloperPropAttrTemp.PassPortInfo = {}
			for i=1,4 do
				table.insert(DeveloperPropAttrTemp.PassPortInfo, gPassPortInfo[i])
			end
		elseif DeveloperPropAttrTemp.PassPortInfo then
			DeveloperPropAttrTemp.PassPortInfo = nil
		end

		-- table.insert(DeveloperPropList, DeveloperPropAttrTemp)
		table.insert(StoreSkuList, deep_copy_table(DeveloperPropAttrTemp))
	else
		local clickItemData = GetInst("DevelopStoreDataManager"):GetCurClickPropDef()
		if not clickItemData then
			ShowGameTips(GetS(23038), 3);
			return
		end

		-- local DeveloperPropAttrTemp = deep_copy_table(DeveloperPropAttr);
		clickItemData.Name = def.Name;
		clickItemData.ItemID = id;
		clickItemData.Desc = def.Desc;
        clickItemData.ADExchange = CurSelectADExchange
		if CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then
			clickItemData.CostNum = CurSelectPropValue;--实际服务器用CostNum这个字段
			clickItemData.MiniPoint = CurSelectPropValue;
		elseif CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
			clickItemData.ADExchange = 0
			clickItemData.CostNum = CurSelectPropValue;
			clickItemData.MiniPoint = CurSelectPropMiniPointValue;
		else
			clickItemData.CostNum = CurSelectPropValue;
			clickItemData.MiniPoint = 0;
		end
		clickItemData.Tag =CurSelectPropTag;
		clickItemData.CostType =CurSelectPropCurrencyType;
		clickItemData.LimitEnd = utils.ts2day(getServerNow()+CurSelectPropTimeLimit*3600*24)
		clickItemData.DiscountCostNum = CurSelectPropDiscount
		clickItemData.LimitStart = utils.ts2day(getServerNow())
		clickItemData.ItemGroup = CurGroupTypeID
		if id == ITEM_PASSPORT then
			clickItemData.PassPortInfo = {}
			for i=1,4 do
				table.insert(clickItemData.PassPortInfo, gPassPortInfo[i])
			end
		elseif clickItemData.PassPortInfo then
			clickItemData.PassPortInfo = nil
		end

		StoreSkuList[clickItemData.RealPos] = deep_copy_table(clickItemData)
	end
	DeveloperStoreDealSubmintButtonShow()
---------------------------------------------------------------------------------------------------------

	getglobal("DeveloperChooseOriginalFrameOkBtn"):SetClientID(0)
	getglobal("DeveloperStoreItemSetFrame"):Hide();

	LoadDeveloperPropList(true)
	-- AdjustDeveloperStoreAuthorPropItem()
	-- UpdateDeveloperAuthorStoreProp()
	local mapId = 0;
	local authorUin = 0;
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		mapId = wdesc.fromowid;
		authorUin = getFromOwid(wdesc.fromowid);
		if wdesc.fromowid == 0 then
			mapId = wdesc.worldid;
			authorUin = AccountManager:getUin()
		end
	else
		mapId = DeveloperFromOwid;
		authorUin = getFromOwid(mapId)
	end

	local mini_money = 0
	local mini_coin = 0
	local mini_point = 0
	if CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.Money then -- 迷你币
		mini_money = CurSelectPropValue
	elseif CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.Coin then -- 游戏豆
		mini_coin = CurSelectPropValue
	elseif CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then --迷你点
		mini_point = CurSelectPropValue
	elseif CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then --迷你点+迷你币
		mini_money = CurSelectPropValue
		mini_point = CurSelectPropMiniPointValue
	end
	statisticsGameEventNew(1350,mapId,id,CurSelectPropCurrencyType,CurSelectPropValue,CurSelectADExchange,mini_money,mini_coin,mini_point)
	print("------authorUin,mapId,id,CurSelectPropCurrencyType,CurSelectPropValue,mini_money,mini_coin,mini_point---------",authorUin,mapId,id,CurSelectPropCurrencyType,CurSelectPropValue,CurSelectADExchange,mini_money,mini_coin,mini_point)
end

function DeveloperStoreItemSetFrameCloseBtn_OnClick()
	getglobal("DeveloperStoreItemSetFrame"):Hide();
	GetInst("DevelopStoreDataManager"):SetUserClickPropNumber(0)
	CurSelectPropValue = 10
	CurSelectPropMiniPointValue = 10;
	CurSelectPropTag = g_DeveloperConfig.Developer.TagType.None         
	CurSelectPropCurrencyType = g_DeveloperConfig.Developer.CurrencyType.Money  
	getglobal("DeveloperChooseOriginalFrameOkBtn"):SetClientID(0);      	
end


--删除prop按钮
function DeveloperStoreItemSetFrameDelBtn_OnClick()
	if not GetInst("DevelopStoreDataManager"):GetIsSelectAddPropBtn()  then
		local propDef = GetInst("DevelopStoreDataManager"):GetCurClickPropDef()
		local StoreSkuList = GetInst("DevelopStoreDataManager"):GetStoreSkuList()
		if propDef and #StoreSkuList >= propDef.RealPos then
			local DeleteDeveloperPropListTemp = GetInst("DevelopStoreDataManager"):GetDeleteDeveloperPropListTemp()
			table.insert(DeleteDeveloperPropListTemp, propDef.ItemID)
			table.remove(StoreSkuList, propDef.RealPos)
			
			LoadDeveloperPropList(true)
		end
	end
	DeveloperStoreDealSubmintButtonShow()
	-- AdjustDeveloperStoreAuthorPropItem()
	-- UpdateDeveloperAuthorStoreProp()
	getglobal("DeveloperStoreItemSetFrame"):Hide();
end

function DeveloperAnalysisSpeedTemplateBar_OnValueChanged()
	-- print("DeveloperAnalysisSpeedTemplateBar_OnValueChanged:");
	local value = this:GetValue();
	local maxvalue = this:GetMaxValue();
	local minvalue = this:GetMinValue();
    local width = ((value - minvalue) / (maxvalue - minvalue)) * 300;
    -- print("maxvalue = ", maxvalue, ", minvalue = ", minvalue, ", value = ", value, ", width = ", width);
    getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
    getglobal(this:GetName().."Pro"):SetWidth(width);
    local valFont = getglobal(this:GetParent().."Val");
    local multiple = 1 +  string.format("%d", value);
	if multiple < 1 then
  		multiple = 1;
  	end
	local apiid = ClientMgr:getApiId();
	local env = ClientMgr:getGameData("game_env");
  	if multiple > 19999 and apiid ~= 999 and env ~= 1  then
  		multiple = 19999;
  	end
	valFont:SetText(multiple);

	CurSelectPropValue = multiple;

end

function DeveloperAnalysisSpeedTemplateBar1_OnMouseUp()
	local value = this:GetValue();
	if get_game_env() ~= 1 then
		if value > 7 and value < 30 then
			this:SetValue(30)
		elseif value > 30 and  value < 60 then
			this:SetValue(60)
		elseif value > 60 and  value < 90 then
			this:SetValue(90)
		end
	end
end

function DeveloperAnalysisSpeedTemplateBar1_OnValueChanged()
	print("DeveloperAnalysisSpeedTemplateBar1_OnValueChanged:");
	local value = this:GetValue();
	local maxvalue = this:GetMaxValue();
	local minvalue = this:GetMinValue();
	if value < minvalue or value > maxvalue then
		return
	end
    local width = ((value - minvalue) / (maxvalue - minvalue)) * 300;
    -- print("maxvalue = ", maxvalue, ", minvalue = ", minvalue, ", value = ", value, ", width = ", width);
    getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
    getglobal(this:GetName().."Pro"):SetWidth(width);
    local valFont = getglobal(this:GetParent().."Val");
    local multiple = 0 +  string.format("%d", value);
	if multiple < 1 then
  		multiple = 1;
  	end
	local apiid = ClientMgr:getApiId();
	local env = ClientMgr:getGameData("game_env");
  	if multiple > 19999 and apiid ~= 999 and env ~= 1  then
  		multiple = 19999;
	end
	multiple = GetS(21610,multiple);
  	valFont:SetText(multiple);
	CurSelectPropTimeLimit = value
end

function DeveloperAnalysisSpeedTemplateBar2_OnValueChanged()
		print("DeveloperAnalysisSpeedTemplateBar2_OnValueChanged:");
		local value = this:GetValue();
		local maxvalue = this:GetMaxValue();
		local minvalue = this:GetMinValue();
		local width = ((value - minvalue) / (maxvalue - minvalue)) * 300;
		-- print("maxvalue = ", maxvalue, ", minvalue = ", minvalue, ", value = ", value, ", width = ", width);
		getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
		getglobal(this:GetName().."Pro"):SetWidth(width);
		local valFont = getglobal(this:GetParent().."Val");
		local multiple = 0 + string.format("%d", value);
		if multiple < 1 then
			  multiple = 1;
		  end
		local apiid = ClientMgr:getApiId();
		local env = ClientMgr:getGameData("game_env");
		if multiple > 19999 and apiid ~= 999 and env ~= 1  then
			multiple = 19999;
		end
		valFont:SetText(multiple);
		CurSelectPropDiscount = multiple
end


function DeveloperAnalysisSpeedTemplateBar3_OnValueChanged()
	-- print("DeveloperAnalysisSpeedTemplateBar_OnValueChanged:");
	local value = this:GetValue();
	local maxvalue = this:GetMaxValue();
	local minvalue = this:GetMinValue();
	local width = ((value - minvalue) / (maxvalue - minvalue)) * 300;
	-- print("maxvalue = ", maxvalue, ", minvalue = ", minvalue, ", value = ", value, ", width = ", width);
	getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
	getglobal(this:GetName().."Pro"):SetWidth(width);
	local valFont = getglobal(this:GetParent().."Val");
	local multiple = 1 +  string.format("%d", value);
	if multiple < 1 then
		multiple = 1;
	end
	local apiid = ClientMgr:getApiId();
	local env = ClientMgr:getGameData("game_env");
	if multiple > 19999 and apiid ~= 999 and env ~= 1  then
		multiple = 19999;
	end
	valFont:SetText(multiple);
	CurSelectPropMiniPointValue = multiple;
end

function DeveloperAnalysisSpeedTemplateLeftBtn_OnClick()
	local value = getglobal(this:GetParent() .. "Bar"):GetValue();
	local ratio = 1;
	local minValue = getglobal(this:GetParent() .. "Bar"):GetMinValue();
	if value <= minValue then
		value = minValue
	else
		value = value - ratio;
	end
	getglobal(this:GetParent().."Bar"):SetValue(value);

end
function DeveloperAnalysisSpeedTemplateRightBtn_OnClick()
	local value = getglobal(this:GetParent() .. "Bar"):GetValue();
	local ratio = 1;
	local maxValue = getglobal(this:GetParent() .. "Bar"):GetMaxValue();
	if value >= maxValue then
		value = maxValue
	else
		value = value + ratio;
	end
	getglobal(this:GetParent().."Bar"):SetValue(value);
end

function DeveloperAnalysisSpeedTemplateLeftBtn1_OnClick()
	local value = getglobal(this:GetParent() .. "Bar"):GetValue();
	if value == 7 then
		return
	end
	local ratio = 1;
	if value == 30 then
		ratio = 23
	elseif value >= 30 then
		ratio = 30
	end
	value = value - ratio;
	getglobal(this:GetParent().."Bar"):SetValue(value);
	CurSelectPropTimeLimit = value
end

function DeveloperAnalysisSpeedTemplateRightBtn1_OnClick()
	local value = getglobal(this:GetParent() .. "Bar"):GetValue();
	if value == 90 then
		return
	end
	local ratio = 1;
	if value == 7 then
		ratio = 23
	elseif value >= 30 then
		ratio = 30
	end
	value = value + ratio;
	getglobal(this:GetParent().."Bar"):SetValue(value);
	CurSelectPropTimeLimit = value
end

function DeveloperAnalysisSpeedTemplateLeftBtn2_OnClick()
	local value = getglobal(this:GetParent() .. "Bar"):GetValue();
	local ratio = 1;
	local minValue = getglobal(this:GetParent() .. "Bar"):GetMinValue();
	if value <= minValue then
		value = minValue
	else
		value = value - ratio;
	end
	getglobal(this:GetParent().."Bar"):SetValue(value);
	CurSelectPropDiscount = value
end

function DeveloperAnalysisSpeedTemplateRightBtn2_OnClick()
	local value = getglobal(this:GetParent() .. "Bar"):GetValue();
	local ratio = 1;
	local maxValue = getglobal(this:GetParent() .. "Bar"):GetMaxValue();
	if value >= maxValue then
		value = maxValue
	else
		value = value + ratio;
	end
	getglobal(this:GetParent().."Bar"):SetValue(value);
	CurSelectPropDiscount = value
end

function SliderBarTemplateBar_OnValueChanged()
	local value = this:GetValue();
	local maxvalue = this:GetMaxValue();
	local minvalue = this:GetMinValue();
    local width = ((value - minvalue) / (maxvalue - minvalue)) * 300;
    getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
    getglobal(this:GetName().."Pro"):SetWidth(width);
    local valFont = getglobal(this:GetParent().."Val");
    local multiple = 0 + string.format("%d", value);
	if multiple < 1 then
  		multiple = 1;
  	end
	local apiid = ClientMgr:getApiId();
	local env = ClientMgr:getGameData("game_env");
  	if multiple > 19999 and apiid ~= 999 and env ~= 1  then
  		multiple = 19999;
  	end

	if not this:GetParentFrame() then return end
	local idx = this:GetParentFrame():GetClientID()-1007 + 1

  	local txt = ""
  	if idx == 2 then
  		txt = GetS(559)
  	elseif idx == 4 then
  		txt = GetS(502)
  	else
  		txt = GetS(3118)
  	end
	valFont:SetText(multiple..txt);

	if idx <= #gPassPortInfo then
		gPassPortInfo[idx] = value
	end
end

function SliderBarTemplateLeftBtn_OnClick()
	local value = getglobal(this:GetParent() .. "Bar"):GetValue();
	local ratio = 1;
	value = value - ratio;
	getglobal(this:GetParent().."Bar"):SetValue(value);
end

function SliderBarTemplateRightBtn_OnClick()
	local value = getglobal(this:GetParent() .. "Bar"):GetValue();
	local ratio = 1;
	value = value + ratio;
	getglobal(this:GetParent().."Bar"):SetValue(value);
end

local MoneyType = 2; --货币有几个
local ItemLable = 7; --标签有几个	

function MoneyTypeFrame_OnLoad()
	if ns_minidian_config and ns_minidian_config.DeveloperStoreMiniPoint then
		if ns_minidian_config.DeveloperStoreMiniPoint == 2 then
			if ns_minidian_config and ns_minidian_config.white_list then
				local temps = loadstring("return {" .. ns_minidian_config.white_list.."}")()
				--local temps = string.split(value.ApiId, ",")
				for _, value in ipairs(temps) do
					if tonumber(value) == AccountManager:getUin() then
						MoneyType = 4
					end
				end
			end
		end
		if ns_minidian_config.DeveloperStoreMiniPoint == 1 then
			MoneyType = 4
		end
	end

	--货币选项
	local boxUI = "DeveloperStoreItemSetFrameMoneyTypeFrameMoneyTypeList";
	local planeUI = boxUI .. "Plane";
	local plane = getglobal(planeUI);
	local y = 14;
	getglobal("DeveloperStoreItemSetFrameMoneyTypeFrameTitleBkgTitle"):SetText(GetS(21668));
	getglobal("DeveloperStoreItemSetFrameMoneyTypeFrameTitle2"):SetText(GetS(21614));
	for i = 1, MoneyType do --货币有几种
		local btnUI = boxUI .. "Btn" .. i;
		if not HasUIFrame(btnUI) then
			break;
		end

		local btn = getglobal(btnUI);
		local index = btn:GetClientID() or 0;
		btn:Show();
		if i == 1 then 
			getglobal(btnUI .. "Name"):SetText(GetS(74));
			getglobal("DeveloperStoreItemSetFrameItemLableFrameItemLableListBtn1Checked"):Show();
		elseif i== 2 then
			getglobal(btnUI .. "Name"):SetText(GetS(372));
		elseif i== 3 then
			getglobal(btnUI .. "Name"):SetText(GetS(23042));
		elseif i== 4 then
			getglobal(btnUI .. "Name"):SetText(GetS(23042).."+"..GetS(74));
		end
		btn:SetPoint("top", planeUI, "top", 0, y);
		y = y + btn:GetHeight() + 8;
		getglobal(btnUI):Show();
	end 

	-- getglobal(planeUI):SetHeight(y);
end

function MoneyTypeFrame_OnShow()

	getglobal("DeveloperStoreItemSetFrameDetailList"):setDealMsg(false)

	for i=1, MoneyType do
		local checked = "DeveloperStoreItemSetFrameMoneyTypeFrameMoneyTypeListBtn" .. i

		getglobal(checked .. "Checked"):Hide()
		if CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.Money and i == 1 then
			getglobal(checked .. "Checked"):Show()
		elseif CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.Coin and i == 2 then
			getglobal(checked .. "Checked"):Show()
		elseif CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint and i == 3 then
			getglobal(checked .. "Checked"):Show()
		elseif CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin and i == 4 then
			getglobal(checked .. "Checked"):Show()
		end
	end
end

function ItemLableFrame_OnShow()
	--标签选项
	getglobal("DeveloperStoreItemSetFrameDetailList"):setDealMsg(false)
	local id = getglobal("DeveloperChooseOriginalFrameOkBtn"):GetClientID()
	local showNum = 7
	if id == ITEM_PASSPORT then
		showNum = 5
	end
	if CurSelectPropCurrencyType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
		showNum = 6
	end
	local boxUI = "DeveloperStoreItemSetFrameItemLableFrameItemLableList";
	local planeUI = boxUI .. "Plane";
	local plane = getglobal(planeUI);
	local y = 14;
	getglobal("DeveloperStoreItemSetFrameItemLableFrameTitleBkgTitle"):SetText(GetS(21672));
	getglobal("DeveloperStoreItemSetFrameItemLableFrameTitle2"):SetText(GetS(21612));
	for i = 1, ItemLable do --标签有几种
		local btnUI = boxUI .. "Btn" .. i;
		if not HasUIFrame(btnUI) then
			break;
		end

		if showNum < i then
			getglobal(btnUI):Hide()
		else
		local btn = getglobal(btnUI);
		local index = btn:GetClientID() or 0;
		btn:Show();
			getglobal(btnUI .. "Checked"):Hide()
		if i== g_DeveloperConfig.Developer.TagType.None then
			getglobal(btnUI .. "Name"):SetText(GetS(21611));
			getglobal("DeveloperStoreItemSetFrameMoneyTypeFrameMoneyTypeListBtn1Checked"):Show();
		elseif i == g_DeveloperConfig.Developer.TagType.Hot then 
			getglobal(btnUI .. "Name"):SetText(GetS(21670));
		elseif i== g_DeveloperConfig.Developer.TagType.New then
			getglobal(btnUI .. "Name"):SetText(GetS(21671));
		elseif i==g_DeveloperConfig.Developer.TagType.Recommend then
			getglobal(btnUI .. "Name"):SetText(GetS(21629));
		elseif i==g_DeveloperConfig.Developer.TagType.Popular then
			getglobal(btnUI .. "Name"):SetText(GetS(21630));
		elseif i==g_DeveloperConfig.Developer.TagType.Timelimit then
			getglobal(btnUI .. "Name"):SetText(GetS(21631));
		elseif i==g_DeveloperConfig.Developer.TagType.Discount then
			getglobal(btnUI .. "Name"):SetText(GetS(21632));
		end
		btn:SetPoint("top", planeUI, "top", 0, y);
		y = y + btn:GetHeight() + 8;
		getglobal(btnUI):Show();

			if i == CurSelectPropTag then
				getglobal(btnUI .. "Checked"):Show()
			end
		end
	end 

	plane:SetHeight(y);
end

function PropTypeFrame_OnShow()
	--选择分类
	getglobal("DeveloperStoreItemSetFrameDetailList"):setDealMsg(false)

	buildSelectPropTypeList()
end

function buildSelectPropTypeList()
 	local boxUI = "DeveloperStoreItemSetFrameSelectPropTypeFrameList";
	local planeUI, data = boxUI .. "Plane";
	local plane, addBtn = getglobal(planeUI), getglobal(boxUI.."Btn100")
	local y, showNum, btnUI, btn = 14, #gStoreGroupTypList

	if showNum >= GetInst("DevelopStoreDataManager"):GetGroupTypeMaxNum() then
		addBtn:Hide()
	else
		addBtn:Show()
	end

	for i = 1, GetInst("DevelopStoreDataManager"):GetGroupTypeMaxNum() do
		btnUI = boxUI .. "Btn" .. i
		if not HasUIFrame(btnUI) then
			break
		end

		if showNum < i then
			getglobal(btnUI):Hide()
		else
			btn = getglobal(btnUI)
			btn:Show()
			getglobal(btnUI .. "Checked"):Hide()
			getglobal(btnUI .. "Name"):SetText(getGroupTypeName(gStoreGroupTypList[i]))
			btn:SetClientUserData(0, gStoreGroupTypList[i])
			btn:SetPoint("top", planeUI, "top", 0, y)
			y = y + btn:GetHeight() + 8

			-- if i == CurSelectPropTag then
			-- 	getglobal(btnUI .. "Checked"):Show()
			-- end
		end
	end 

	if addBtn:IsShown() and btn then
		addBtn:SetPoint("top", planeUI, "top", 0, y)
		y = y + addBtn:GetHeight() + 8
	end

	plane:SetHeight(y);
 end

function MoneyTypeFrame_OnHide()
	isFirstClickMoneyLable = false;
	getglobal("DeveloperStoreItemSetFrameDetailList"):setDealMsg(true)
end

function ItemLableFrame_OnHide()
	isFirstClickItemLable = false;
	getglobal("DeveloperStoreItemSetFrameDetailList"):setDealMsg(true)
end

function PropTypeFrame_OnHide()
	-- isFirstClickItemLable = false;
	getglobal("DeveloperStoreItemSetFrameDetailList"):setDealMsg(true)
end

function MoneyTypeFrameCloseBtn_OnClick()
	getglobal("DeveloperStoreItemSetFrameMoneyTypeFrame"):Hide();
	isFirstClickMoneyLable = true;
end

function ItemLableFrameCloseBtn_OnClick()
	getglobal("DeveloperStoreItemSetFrameItemLableFrame"):Hide();
	isFirstClickItemLable = true;
end

function PropTypeFrameCloseBtn_OnClick()
	getglobal("DeveloperStoreItemSetFrameSelectPropTypeFrame"):Hide();
end

function MoneyTypeFrameBtn_OnClick()
	local id = getglobal("DeveloperChooseOriginalFrameOkBtn"):GetClientID()
	if id == ITEM_PASSPORT then return end

	getglobal("DeveloperStoreItemSetFrameMoneyTypeFrame"):Show();

	--没有点击增加商品按钮
	if isFirstClickMoneyLable then
		if GetInst("DevelopStoreDataManager"):GetIsSelectAddPropBtn() then 
			CurSelectPropCurrencyType = g_DeveloperConfig.Developer.CurrencyType.Money;
		end
	end
end

function ItemLableFrameBtn_OnClick()
	getglobal("DeveloperStoreItemSetFrameItemLableFrame"):Show();
	--没有点击增加商品按钮
	if isFirstClickItemLable then
		if GetInst("DevelopStoreDataManager"):GetIsSelectAddPropBtn() then 
			CurSelectPropTag = g_DeveloperConfig.Developer.TagType.None;
		end
	end
end

function PropTypeFrameBtn_OnClick()
	getglobal("DeveloperStoreItemSetFrameSelectPropTypeFrame"):Show()
end

function GroupTypeAddItem_OnClick()
	OpenPropTypeConfirmFrame({type=1})
	standReportEvent("6002", "PROP_WARES", "WaresGroupAdd", "click", {cid = G_GetFromMapid()})
end

function DeveloperStoreItemSetFrameSelectItemBtn_OnClick()
	getglobal("DeveloperChooseOriginalFrame"):Show();
end

function WelfareChooseOriginal()
	WelfareChoose = true
	getglobal("DeveloperChooseOriginalFrame"):Show();
end

function DeveloperStoreItemSetFrameAdSwitchBtn_OnMouseDown()
	-- body
	Log("DeveloperStoreItemSetFrameAdSwitchBtn_OnMouseDown");
	local switchName 	= this:GetName();
	local state		= 0;
	local bkg 		= getglobal(this:GetName().."Bkg");
	local point 		= getglobal(switchName.."Point");
	
	if point:GetRealLeft() - bkg:GetRealLeft() > 20  then			--先前状态：开
		state = 0;
	else								--先前状态：关
		state = 1;
	end
	--print("=======================switchName==========================: ",switchName)
    local name = getglobal(switchName.."Name");
	if state == 1 then			--开
        point:SetPoint("right", switchName, "right", 0, 0);
        bkg:Show()
		name:SetPoint("center", switchName .. "Point", "center", 0, 0);
		getglobal(switchName.."Name"):SetText(GetS(21742));  
	else									--关
        point:SetPoint("left", switchName, "left", -2, 0);
		bkg:Hide()
		name:SetPoint("center", switchName .. "Point", "center", 0, 0);
		getglobal(switchName.."Name"):SetText(GetS(21743));
	end

	--state = 0: 关, state = 1: 开
	Log("state = " .. state);
	CurSelectADExchange = state
end

function DeveloperStoreItemSetFrameTitleName_OnClick()
	--Log("DeveloperStoreItemSetFrameTitleName_OnClick");
	getglobal("DeveloperStoreItemSetFrameSafetyCheckTipsBkg"):SetPoint("top","DeveloperStoreItemSetFrameTitleName","bottomright",20,8)
	getglobal("DeveloperStoreItemSetFrameSafetyCheckTips"):Show()
end

function DeveloperStoreItemSetFrameBar2TitleName_OnClick()

	if CurSelectPropTag == g_DeveloperConfig.Developer.TagType.Timelimit then
		getglobal("DeveloperStoreItemSetFrameSafetyCheckTipsBkg"):SetPoint("top","DeveloperStoreItemSetFrameValue1Name","bottomright",20,8)
		getglobal("DeveloperStoreItemSetFrameSafetyCheckTipsText"):SetText(GetS(21624))
	end
	if CurSelectPropTag == g_DeveloperConfig.Developer.TagType.Discount then
		getglobal("DeveloperStoreItemSetFrameSafetyCheckTipsBkg"):SetPoint("top","DeveloperStoreItemSetFrameValue1Name","bottomright",20,8)
		getglobal("DeveloperStoreItemSetFrameSafetyCheckTipsText"):SetText(GetS(21636))
	end
	getglobal("DeveloperStoreItemSetFrameSafetyCheckTips"):Show()
end

function DeveloperStoreItemSetFrameBar3TitleName_OnClick()
	getglobal("DeveloperStoreItemSetFrameSafetyCheckTipsBkg"):SetPoint("top","DeveloperStoreItemSetFrameValue2Name","bottomright",20,8)
	getglobal("DeveloperStoreItemSetFrameSafetyCheckTipsText"):SetText(GetS(21634))
	getglobal("DeveloperStoreItemSetFrameSafetyCheckTips"):Show()
end

function DeveloperStoreItemSetFrameSafetyCheckTips_OnClick()
	--Log("DeveloperStoreItemSetFrameSafetyCheckTips_OnClick");
	getglobal("DeveloperStoreItemSetFrameSafetyCheckTips"):Hide()
end

function MoneyItemTypeBtn_OnClick()
	local btn = this:GetName();
	local name = btn .. "Name"
	local text = getglobal(name):GetText();

	local code = 1001;
	local info = nil;
	local cfg =nil;
	if g_DeveloperInfo then
		code = ErrorCode.OK
		cfg = g_DeveloperInfo;
	else
		code, info, cfg = AccountManager:dev_developer_info(AccountManager:getUin());
		if info and info.Level ~= nil then
			GetInst("DevelopStoreDataManager"):SetUserLevel(info.Level)
		end
	end

	if string.find(btn,"MoneyTypeFrame") then --货币
		getglobal("DeveloperStoreItemSetFrameMoneyTypeName"):SetText(text);
		getglobal("DeveloperStoreItemSetFrameMoneyTypeFrame"):Hide();
		if CurSelectPropTag  == g_DeveloperConfig.Developer.TagType.Timelimit then
			loadDetailListItem({[1]=1, [2]=2, [3]=3, [5]=5, [6]=6, [12]=12})
		elseif CurSelectPropTag  == g_DeveloperConfig.Developer.TagType.Discount then
			loadDetailListItem({[1]=1, [2]=2, [3]=3, [5]=5, [6]=6, [7]=7})
		else
			loadDetailListItem({[1]=1, [2]=2, [3]=3, [5]=5, [12]=12})
		end

		for i=1, MoneyType do
			local checked = "DeveloperStoreItemSetFrameMoneyTypeFrameMoneyTypeListBtn" .. i 
			if string.find(btn,checked) then
				getglobal(btn .. "Checked"):Show();
				getglobal("DeveloperStoreItemSetFrameValueName"):SetText(GetS(21666));
				if i == 1 then
					CurSelectPropCurrencyType = g_DeveloperConfig.Developer.CurrencyType.Money
					if code == ErrorCode.OK then
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetMaxValue(cfg.LimitMapStoreItemMiniCoinPrice-1);
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetMinValue(0);
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetValue(9);
						SliderUVChange("DeveloperStoreItemSetFrameValueBar");
						getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMaxValue(cfg.LimitMapStoreItemMiniCoinPrice-1);
						getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMinValue(4);
						getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetValue(9-1);
					end
				elseif i == 2 then
					CurSelectPropCurrencyType = g_DeveloperConfig.Developer.CurrencyType.Coin 
					if code == ErrorCode.OK then
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetMaxValue(cfg.LimitMapStoreItemMiniBeanPrice-1);
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetMinValue(4);
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetValue(9);
						SliderUVChange("DeveloperStoreItemSetFrameValueBar");
						getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMaxValue(cfg.LimitMapStoreItemMiniBeanPrice-1);
						getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMinValue(4);
						getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetValue(9-1);
					end
				elseif i == 3 then
					CurSelectPropCurrencyType = g_DeveloperConfig.Developer.CurrencyType.MiniPoint
					if code == ErrorCode.OK then
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetMaxValue(cfg.LimitMapStoreItemMiniPointPrice-1);
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetMinValue(4);
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetValue(9);
						SliderUVChange("DeveloperStoreItemSetFrameValueBar");
						getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMaxValue(cfg.LimitMapStoreItemMiniPointPrice-1);
						getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetMinValue(4);
						getglobal("DeveloperStoreItemSetFrameValue2Bar"):SetValue(9);


					end
				elseif i == 4 then
					CurSelectPropCurrencyType = g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin
					if CurSelectPropTag  == g_DeveloperConfig.Developer.TagType.Timelimit then
						loadDetailListItem({[1]=1, [2]=2, [3]=3, [5]=5, [6]=6})
					else
						loadDetailListItem({[1]=1, [2]=2, [3]=3, [4]=4,[5]=5})
					end
					if code == ErrorCode.OK then
						if CurSelectPropTag == g_DeveloperConfig.Developer.TagType.Discount then
							CurSelectPropTag = g_DeveloperConfig.Developer.TagType.None;
							getglobal("DeveloperStoreItemSetFrameItemLableName"):SetText(GetS(21611));
						end
						CurSelectPropMiniPointValue = 10
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetMaxValue(cfg.LimitMapStoreItemMiniCoinPrice-1);
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetMinValue(0);
						getglobal("DeveloperStoreItemSetFrameValueBar"):SetValue(9);
						SliderUVChange("DeveloperStoreItemSetFrameValueBar");
						getglobal("DeveloperStoreItemSetFrameValueName"):SetText(GetS(23043));
						getglobal("DeveloperStoreItemSetFrameValue3Bar"):SetMaxValue(cfg.LimitMapStoreItemMiniPointPrice-1);
						getglobal("DeveloperStoreItemSetFrameValue3Bar"):SetMinValue(4);
						getglobal("DeveloperStoreItemSetFrameValue3Bar"):SetValue(9);
						SliderUVChange("DeveloperStoreItemSetFrameValue3Bar");
						getglobal("DeveloperStoreItemSetFrameValue3Name"):SetText(GetS(23044));
					end
				end				
			else 
				if not getglobal(checked .. "Checked"):IsShown() then

					getglobal(checked .. "Checked"):Hide();
				end
			end
		end
	end

      	if string.find(btn,"ItemLableFrame") then --标签
		getglobal("DeveloperStoreItemSetFrameItemLableName"):SetText(text);
		getglobal("DeveloperStoreItemSetFrameItemLableFrame"):Hide();
		for i=1, ItemLable do
			local checked = "DeveloperStoreItemSetFrameItemLableFrameItemLableListBtn" .. i 
			if string.find(btn,checked) then
				getglobal(btn .. "Checked"):Show();
				CurSelectPropTag = i;
				freshDeveloperStoreItemSetFrame(CurSelectPropTag,true, getglobal("DeveloperChooseOriginalFrameOkBtn"):GetClientID() == ITEM_PASSPORT)
			else 
				if not getglobal(checked .. "Checked"):IsShown() then
					getglobal(checked .. "Checked"):Hide();
				end
			end
		end
	elseif string.find(btn,"SelectPropTypeFrame") then
		getglobal("DeveloperStoreItemSetFramePropTypeName"):SetText(text)
		getglobal("DeveloperStoreItemSetFrameSelectPropTypeFrame"):Hide()
		CurGroupTypeID = this:GetClientUserData(0)
	end 
end

--解決Slider 修改最大值和最小值同时设置值则change 没调用导致UV不同步
function SliderUVChange(SliderName)
	local slider = getglobal(SliderName);
	local value = slider:GetValue()+1;
	local maxvalue = slider:GetMaxValue();
	local minvalue = slider:GetMinValue();
	local width = ((value - minvalue) / (maxvalue - minvalue)) * 300;
	-- print("maxvalue = ", maxvalue, ", minvalue = ", minvalue, ", value = ", value, ", width = ", width);
	getglobal(slider:GetName().."Pro"):ChangeTexUVWidth(width);
	getglobal(slider:GetName().."Pro"):SetWidth(width);
end

function updatePropLableAndCurrencyType()

end

---------------------------------------------------------选择游戏道具---------------------------------------------------
function DeveloperChooseOriginalFrame_OnLoad()
	for i=1, DeveloperMaxOriginalBlockNum/9 do
		for j=1, 9 do
			local index = (i-1)*9+j;
			local grid = getglobal("DeveloperOriginalGrid"..index);
			grid:SetPoint("topleft", "DeveloperOriginalGridBoxPlane", "topleft", (j-1)*84, (i-1)*84);
		end
	end
end

function DeveloperChooseOriginalFrame_OnShow()

	getglobal("DeveloperStoreItemSetFrameDetailList"):setDealMsg(false)
	LoadDeveloperOriginalDef();
	DeveloperUpdateEditorOriginalBox(1);
	DeveloperSetChooseOriginalFrameTab(1)
	DeveloperUpdateUpDownStatus()
end



function LoadDeveloperOriginalDef()
	DeveloperOriginalInfo = {}
	DeveloperItemsInfo={}

	local t_originalitem, idx = {}, 1

	local iNum = ItemDefCsv:getNum();
    for i=1, iNum do
		local def = ItemDefCsv:get(i-1);		
		if def then
			if ModEditorMgr:getItemDefById(def.ID) then
	            def = ModEditorMgr:getItemDefById(def.ID)
	        end

	        if def then
          		table.insert(t_originalitem, {Type=def.DropType, Def = def});
          		if def.CopyID > 0 then
          			if def.Type ~= ITEM_TYPE_BLOCK then
          				table.insert(t_originalitem, idx, {Type=5, Def = def})
          				idx = idx + 1
          			else
          				table.insert(t_originalitem, {Type=5, Def = def})
          			end
          		end
          	end
		end
    end

	-- local blockCount = 0;
	-- local itemCount = 0;
	-- for i = 1, ModMgr:getMapModCount() do
	-- 	local moddesc = ModMgr:getMapModDescByIndex(i-1);
	-- 	if moddesc and moddesc.uuid == ModMgr:getMapDefaultModUUID() then
	-- 		local mod = ModMgr:getMapModByIndex(i-1);
	-- 		if mod then
	-- 			blockCount = blockCount + ModMgr:getGameModBlockCount(mod);
	-- 			itemCount = itemCount + ModMgr:getGameModItemCount(mod);
	-- 		end
	-- 	end
	-- end

 --    -- iNum = ModMgr:getCustomItemCount();
 --    -- print("自定义全部Item",iNum)
	-- for i=1, itemCount do
	-- 	local itemDef = ModMgr:tryGetItemDefByIndex(i-1);
	-- 	if itemDef ~= nil then
	-- 		local def = ModMgr:tryGetItemDef(itemDef.ID);

	-- 		if def and def.CopyID > 0 and def.Type ~= ITEM_TYPE_BLOCK then
	--             table.insert(t_originalitem, {Type=5, Def = def});
	-- 		end
	-- 	end
	-- end




 --    --自定义全部方块
	-- for i=1, blockCount do
	-- 	local blockdef = ModMgr:tryGetBlockDefByIndex(i-1);
	-- 	if blockdef then
	-- 		local def = ModMgr:tryGetBlockDef(blockdef.ID)

	-- 		if def and def.CopyID > 0 then
	--             table.insert(t_originalitem, {Type=5, Def = def});
	-- 		end
	-- 	end
	-- end

	iNum = #(t_originalitem);
	table.insert(DeveloperOriginalInfo, {EditType=5})

	for i=1, iNum do
		local def = nil;
		local type;

		def = t_originalitem[i].Def;
		type = t_originalitem[i].Type; 

		if def and type > 0 then
			if not def.gamemod or def.gamemod:getIsCCModType(CCModType_National) or def.gamemod:getIsCCModType(CCModType_MapPool) then
				local t = GetTableDeveloperItemType(type)
				if t == nil then
					if type ~= 5 then
						table.insert(DeveloperOriginalInfo, {EditType=type})
					end
					table.insert(DeveloperItemsInfo, {EditType=type, t={def}})
				else
					table.insert(t, def);
				end
			end
		end
	end
	if if_open_creator_password(GetInst("DevelopStoreDataManager"):GetUserLevel()) then
		local itemdef = ItemDefCsv:get(ITEM_PASSPORT)
		table.insert(DeveloperOriginalInfo, ({EditType=6}))
		table.insert(DeveloperItemsInfo, {EditType=6, t={itemdef}})
	end

	--table.sort(DeveloperOriginalInfo, function(a, b) return a.EditType < b.EditType end);
end

function DeveloperUpdateEditorOriginalBox(index) 
	CurSelectType = DeveloperOriginalInfo[index].EditType;
	if CheckedOBName then
		getglobal(CheckedOBName.."Checked"):Hide();
	end
	
	getglobal("DeveloperOriginalGridBox"):resetOffsetPos();

	local noItem = false
	local t = GetTableDeveloperItemType(CurSelectType);
	if t == nil then
		noItem = true
		for i=1, DeveloperMaxOriginalBlockNum do
			local grid = getglobal("DeveloperOriginalGrid"..i);
			grid:Hide()
		end

		local listFrame = getglobal("DeveloperOriginalGridBox")
		local listPanel = getglobal("DeveloperOriginalGridBoxPlane")
		local height = listFrame:GetHeight()
		listPanel:SetHeight(height)
	else
		local num = #(t);	
		for i=1, DeveloperMaxOriginalBlockNum do
			local grid = getglobal("DeveloperOriginalGrid"..i);
			if i <= num then
				grid:Show();
				local icon = getglobal(grid:GetName().."Icon");
				SetItemIcon(icon, t[i].ID);
				grid:SetClientID(t[i].ID);
			else
				grid:Hide()
			end
		end

		local listFrame = getglobal("DeveloperOriginalGridBox")
		local listPanel = getglobal("DeveloperOriginalGridBoxPlane")
		local height = 84*math.ceil(num/9)
		if height < listFrame:GetHeight() then height = listFrame:GetHeight() end
		listPanel:SetHeight(height)

		if num == 0 then
			noItem = true
		end
	end

	local emptyBkg = getglobal("DeveloperChooseOriginalFrameEmptyBkg")
	local noItemTips = getglobal("DeveloperChooseOriginalFrameNoItemTips")
	--自定义 并且没有数量的时候
	if noItem and CurSelectType == 5 then
		emptyBkg:Show()
		noItemTips:Show()
	else
		emptyBkg:Hide()
		noItemTips:Hide()
	end
	
	-- local height = 333+ math.ceil((num-36)/9)*84;
	-- if height < 333 then
	-- 	height = 333;
	-- end

	-- getglobal("DeveloperOriginalGridBoxPlane"):SetSize(755, height);
end

function GetTableDeveloperItemType(editType)
	for i=1, #(DeveloperItemsInfo) do
		if editType == DeveloperItemsInfo[i].EditType then
			return DeveloperItemsInfo[i].t;
		end
	end

	return nil
end


function DeveloperItemSelectTabTemplate_OnClick()
	local tabindex = this:GetClientID();
	local btnName = this:GetName();
	local checked = getglobal(btnName.."Checked");
	if string.find(btnName, "DeveloperChooseOriginalFrameTabs") then
		DeveloperUpdateEditorOriginalBox(tabindex);
		local startIndex = getglobal("DeveloperChooseOriginalFrameTabs1"):GetClientID();
		DeveloperSetChooseOriginalFrameTab(startIndex);
	end
end

function DeveloperSetChooseOriginalFrameTab(startIndex)
	Log("DeveloperSetChooseOriginalFrameTab startIndex:"..startIndex);
	local num = #(DeveloperOriginalInfo);
    local cur_num, max_num = 0, 5
    local info = GetTableDeveloperItemType(6)
    if info and #info > 0 then max_num = 6 end

	for i=1, 8 do
		local index = startIndex+i-1;
		local tab = getglobal("DeveloperChooseOriginalFrameTabs"..i);
		local name = getglobal("DeveloperChooseOriginalFrameTabs"..i.."Name");
		tab:SetClientID(index);
		
		local normal 	= getglobal("DeveloperChooseOriginalFrameTabs"..i.."Normal");
		local checked 	= getglobal("DeveloperChooseOriginalFrameTabs"..i.."Checked");
		if DeveloperOriginalInfo[index] and DeveloperOriginalInfo[index].EditType == CurSelectType then
			normal:Hide();
			checked:Show();
		else
			normal:Show();
			checked:Hide();
		end

		if index <= num and cur_num < max_num then
            cur_num = cur_num + 1
			tab:Show();
			local editType = DeveloperOriginalInfo[index].EditType;
			name:SetText(GetS(t_SelectTypesId.item[editType]));

		else
			tab:Hide();

		end
	end
end



function DeveloperOriginalGridTemplate_OnClick()
	local id = this:GetClientID();
	--print("-------------------------id---------",id)
	if CheckedOBName then
		getglobal(CheckedOBName.."Checked"):Hide();
	end
	
	CheckedOBName = this:GetName()
	getglobal(CheckedOBName.."Checked"):Show();



	getglobal('DeveloperChooseOriginalFrameOkBtn'):SetClientID(id);	--ClientID记录了选择的掉落物ID;
	local itemDef = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);
	if itemDef then
		--弹出提示框
		print("itemDef.Name:",itemDef.Name)
		UpdateTipsFrame(itemDef.Name,0);
	end
end


function DeveloperChooseOriginalFrameOkBtn_OnClick()
	if not WelfareChoose then
		getglobal("DeveloperStoreItemSetFrameSelectItemBtnIcon"):Show();
		getglobal("DeveloperStoreItemSetFrameSelectItemBtnAddIcon"):Hide()
	end
	

	local id = getglobal("DeveloperChooseOriginalFrameOkBtn"):GetClientID();	--ClientID记录了选择的掉落物ID;
	if id == 0 then
		ShowGameTips(GetS(4880));
		return;
	end
	local def = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);
	if not def then return end
	if not WelfareChoose then
		if IsUseFguiDevelopStoreItemSet() then
			if not GetInst("MiniUIManager"):IsShown("DeveloperStoreItemSet") then
				return
			end
			local ctrl = GetInst("MiniUIManager"):GetCtrl("DeveloperStoreItemSet")
			if ctrl and ctrl.SelectedItem then
				ctrl:SelectedItem(id)
			end
		else
			DeveloperCurSelectUICallBack(id)
		end
	else
		WelfareChoose = false
		SandboxLua.eventDispatcher:Emit(nil, "DEVELOPERICO_SELECT", SandboxContext():SetData_Number("itemid", id) )
		--DEVELOPERICO_SELECT
	end
---------------------------------------------------------------------------------------------------------

	getglobal("DeveloperChooseOriginalFrame"):Hide();
end


function DeveloperCurSelectUICallBack(val)
	print('OnCurEditorUICallBack',val, CurEditorUIName);
	if not CurEditorUIName then return end

	local icon = getglobal(CurEditorUIName.."Icon");
	resetSetFrame(val == ITEM_PASSPORT)
	
	local def = ItemDefCsv:get(val);
	local del = getglobal(CurEditorUIName.."Del");
	if del:IsShown() then
		del:Hide();
	end
	SetItemIcon(icon, val);

	getglobal("DeveloperStoreItemSetFrameItemName"):SetText(def.Name)
	getglobal("DeveloperStoreItemSetFrameDescription"):SetText(def.Desc)
end

function DeveloperChooseOriginalFrame_OnHide()
	getglobal("DeveloperStoreItemSetFrameDetailList"):setDealMsg(true)
end


function DeveloperChooseOriginalFrameClose_OnClick()
	getglobal("DeveloperChooseOriginalFrame"):Hide();
end


function DeveloperChooseOriginalFrameUpBtn_OnClick()
	local max_num, info = 5, GetTableDeveloperItemType(6)
    if info and #info > 0 then max_num = 6 end
	local startIndex = getglobal("DeveloperChooseOriginalFrameTabs1"):GetClientID() - max_num;
	DeveloperSetChooseOriginalFrameTab(startIndex);
	DeveloperUpdateUpDownStatus();
end

function DeveloperChooseOriginalFrameDownBtn_OnClick()
	local max_num, info = 5, GetTableDeveloperItemType(6)
    if info and #info > 0 then max_num = 5 end
	local startIndex = getglobal("DeveloperChooseOriginalFrameTabs1"):GetClientID() + max_num;
	DeveloperSetChooseOriginalFrameTab(startIndex);
	DeveloperUpdateUpDownStatus();
end

function DeveloperUpdateUpDownStatus()
	local num, max_num = #(DeveloperOriginalInfo), 5
	local id = getglobal("DeveloperChooseOriginalFrameTabs1"):GetClientID();
	local info = GetTableDeveloperItemType(6)
    if info and #info > 0 then max_num = 6 end

	if id > max_num then
		getglobal("DeveloperChooseOriginalFrameTabsUpBtn"):Show();
	else
		getglobal("DeveloperChooseOriginalFrameTabsUpBtn"):Hide();
	end

	if id < max_num then
		getglobal("DeveloperChooseOriginalFrameTabsDownBtn"):Show();
	else
		getglobal("DeveloperChooseOriginalFrameTabsDownBtn"):Hide();
	end 

	if num <= max_num then
		getglobal("DeveloperChooseOriginalFrameTabsDownBtn"):Hide()
	end
end

function IsOuNumber(num)
    local num1,num2=math.modf(num/2)--返回整数和小数部分
    if(num2==0)then
        return true
    else
        return false
    end
end

function getFromOwid(fromid)
	if fromid == nil or fromid == "" then
		return 0
	else
		return tonumber(fromid)%math.pow(2, 32)
	end
end

function ShowDeveloperStoreBtn()
	if isEducationalVersion then--for minicode
		return
	end

	if WorldMgr and WorldMgr.getFromWorldID then
		DeveloperFromOwid = WorldMgr:getFromWorldID()
	end
	getglobal("GongNengFrameDeveloperStoreBtn"):Hide()
	getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Hide()

	-- 不是编辑或者玩法模式就隐藏按钮
	if CurWorld and (CurWorld:isGameMakerMode() or CurWorld:isGameMakerRunMode()) and (if_open_creator_buy_inside() or if_open_creator_buy_config()) then
		local mapId, authorUin, uin = 0, 0, AccountManager:getUin()
		if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
			local wdesc = AccountManager:getCurWorldDesc()
			
			if wdesc == nil then return end

			mapId = wdesc.fromowid
			authorUin = getFromOwid(wdesc.fromowid)
			if wdesc.fromowid == 0 then
				mapId = wdesc.worldid
				authorUin = uin
			end
		else	
			mapId = DeveloperFromOwid
			authorUin = getFromOwid(mapId)
		end

		if UIEditorDef:isMainUICanShow(UIEditorDef.TREE_ITEM_TYPE.SHOP) then--xyang自定义UI
			getglobal("GongNengFrameDeveloperStoreBtn"):Show()
		end
		WolrdGameTopBtnLayout()
		if IsCanShowRedPoint(uin, mapId) then
			--显示红点
			--getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Show()
		end
		--新埋点
		if not(IsUGCEditMode() and CurWorld and CurWorld:isGameMakerMode()) then
			DeveloperStore_StandReportEvent("MINI_GAMEOPEN_GAME_1", "ShopEntranceButton", "view");
		end
	end

	-- if ClientCurGame:isInGame() and (if_open_creator_buy_inside() or if_open_creator_buy_config()) then
	-- 	if getglobal("GongNengFrameScreenshotBtn"):IsShown() then
	-- 		getglobal("GongNengFrameDeveloperStoreBtn"):SetPoint("right", "GongNengFrameScreenshotBtn", "left", -7, 0);
	-- 	elseif getglobal("GongNengFrameModelLibBtn"):IsShown() then
	-- 		getglobal("GongNengFrameDeveloperStoreBtn"):SetPoint("right", "GongNengFrameModelLibBtn", "left", -7, 0);
	-- 	elseif getglobal("GongNengFrameRuleSetGNBtn"):IsShown() then
	-- 		getglobal("GongNengFrameDeveloperStoreBtn"):SetPoint("right", "GongNengFrameRuleSetGNBtn", "left", -7, 0);
	-- 	else
	-- 		getglobal("GongNengFrameDeveloperStoreBtn"):SetPoint("right", "GongNengFrameRuleSetGNBtn", "right", -7, 0);
	-- 	end

	-- 	local mapId = 0;
	-- 	local authorUin = 0;
	-- 	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
	-- 		local wdesc = AccountManager:getCurWorldDesc();
	-- 		if wdesc == nil then return end
	-- 		mapId = wdesc.fromowid;
	-- 		authorUin = getFromOwid(wdesc.fromowid);
	-- 		if wdesc.fromowid == 0 then
	-- 			mapId = wdesc.worldid;
	-- 			authorUin = AccountManager:getUin()
	-- 		end
	-- 	else	
	-- 		mapId = DeveloperFromOwid;
	-- 		authorUin = getFromOwid(mapId)
	-- 	end

	-- 	local code, list = AccountManager:dev_mapstore_get_itemlist(authorUin, mapId,false);

	-- 	local isDeveloper = 1001;
	-- 	local info = nil;
	-- 	local cfg =nil;
	-- 	if g_DeveloperInfo then
	-- 		isDeveloper = ErrorCode.OK
	-- 		cfg = g_DeveloperInfo;
	-- 	else
	-- 		isDeveloper, info, cfg = AccountManager:dev_developer_info(authorUin);
	-- 		if info and info.Level ~= nil then
	-- 			UserLevel = info.Level
	-- 		end
	-- 	end
		
	-- 	local uin = AccountManager:getUin()
	-- 	if CurWorld and (CurWorld:isGameMakerRunMode() and not CurWorld:isGodMode()) and if_open_creator_buy_inside() then    --玩法模式

	-- 		--是开发者  
	-- 		if isDeveloper == ErrorCode.OK then      
	-- 			getglobal("GongNengFrameDeveloperStoreBtn"):Show();
	-- 			if IsCanShowRedPoint(uin,mapId) then
	-- 				--显示红点
	-- 				getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Show()
	-- 			else
	-- 				getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Hide()
	-- 			end
	-- 			 --不是自己的地图且没有设置商店
	-- 			if authorUin ~= uin and (code ~= ErrorCode.OK or next(list) ==nil) then
	-- 				getglobal("GongNengFrameDeveloperStoreBtn"):Hide();
	-- 			end
	-- 		else   
	-- 			-- 不是开发者
	-- 			getglobal("GongNengFrameDeveloperStoreBtn"):Hide();

	-- 			 --不是自己的地图且设置了商店
	-- 			if authorUin ~= uin and (code == ErrorCode.OK and next(list) ~=nil) then
	-- 				getglobal("GongNengFrameDeveloperStoreBtn"):Show();
	-- 				if IsCanShowRedPoint(uin,mapId) then
	-- 					--显示红点
	-- 					getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Show()
	-- 				else
	-- 					getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Hide()
	-- 				end
	-- 			end
	-- 		end

	-- 	elseif CurWorld and (CurWorld:isGameMakerMode() and  CurWorld:isGodMode()) and if_open_creator_buy_config() then    --编辑模式

	-- 		--是开发者  
	-- 		if isDeveloper == ErrorCode.OK then        
	-- 			getglobal("GongNengFrameDeveloperStoreBtn"):Show();
	-- 			if IsCanShowRedPoint(uin,mapId) then
	-- 				--显示红点
	-- 				getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Show()
	-- 			else
	-- 				getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Hide()
	-- 			end

	-- 			if authorUin ~= uin then
	-- 			    --不是自己的地图       
	-- 				-- getglobal("GongNengFrameDeveloperStoreBtn"):Hide();
	-- 			end
				
	-- 		else   
	-- 			-- 不是开发者
	-- 			getglobal("GongNengFrameDeveloperStoreBtn"):Show();
	-- 			if IsCanShowRedPoint(uin,mapId) then
	-- 				--显示红点
	-- 				getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Show()
	-- 			else
	-- 				getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Hide()
	-- 			end

	-- 			--不是自己的地图   
	-- 			if authorUin ~= uin then
	-- 				getglobal("GongNengFrameDeveloperStoreBtn"):Hide();
	-- 			end
	-- 		end
	-- 	else
	-- 		if getglobal("GongNengFrameDeveloperStoreBtn"):IsShown() then
	-- 			getglobal("GongNengFrameDeveloperStoreBtn"):Hide();
	-- 		end
	-- 	end

	-- 	if getglobal("GongNengFrameDeveloperStoreBtn"):IsShown() then 
	-- 		getglobal("GongNengFramePluginLibBtn"):SetPoint("right", "GongNengFrameDeveloperStoreBtn", "left", -7, 0);
	-- 	else
	-- 		getglobal("GongNengFramePluginLibBtn"):SetPoint("right", "GongNengFrameScreenshotBtn", "left", -7, 0);
	-- 	end 
	-- end
end


g_DeveloperInfo = nil;
function loadDeveloperInfo()
	--协程请求开发者信息
	threadpool:work(function ()
		local code, info, cfg = AccountManager:dev_developer_info(AccountManager:getUin());
		if code == ErrorCode.OK then
			g_DeveloperInfo = cfg;
			if info and info.Level ~= nil then
				GetInst("DevelopStoreDataManager"):SetUserLevel(info.Level)
				ns_data.my_creator_level = info.Level
			end
		else
			g_DeveloperInfo = nil;
			ns_data.my_creator_level = -1
		end
		
		-- 福利数据跟开发者等级挂钩, 获取开发者等级之后要重新拉去一遍福利数据
		ActivityMainCtrl:RequestWelfareRewardData()
		GetInst("WorkSpaceDataManager"):InitWorkInfo()
	end)

end

--同步方式请求开发者信息
function SynloadDeveloperInfo()
	local code, info, cfg = AccountManager:dev_developer_info(AccountManager:getUin());
	if code == ErrorCode.OK then
		g_DeveloperInfo = cfg;
		if info and info.Level ~= nil then
			GetInst("DevelopStoreDataManager"):SetUserLevel(info.Level)
			ns_data.my_creator_level = info.Level
		end
	else
		g_DeveloperInfo = nil;
		ns_data.my_creator_level = -1
	end
	return code
end

--开发者跳转盒子下载
function JumpDeveloperBoxDown()
	open_http_link( "https://www.miniworldbox.com/", "posting" );
end


function DeveloperStoreBuyItemFrameCatInfo_OnClick( )
	local propDef = GetInst("DevelopStoreDataManager"):GetCurClickPropDef()
	if not propDef then
		return
	end
	
	local def = ModEditorMgr:getItemDefById(propDef.ItemID) or ModEditorMgr:getBlockItemDefById(propDef.ItemID) or ItemDefCsv:get(propDef.ItemID);
	if def then
		ShowGiftPackFrame(0,def.ID);
	end
end

function setCurItemSimpleInfos(authorUin,mapId,itemId)
	-- body
 	CurItemAuthUin = authorUin
 	CurItemMapId = mapId
	CurItemId = itemId
end

function getCurItemSimpleInfos()
	return CurItemAuthUin,CurItemMapId,CurItemId
end

function DeveloperStoreItemADBtn_OnClick()
	--是否自动提取
	DeveloperStoreItemOrder(false, true)
end

function GetDeveloperStorePropDef(ispassport, ishost, params)
	local propDef = nil
	
	if ispassport and ishost then
		propDef = getPassPortDef()
	elseif params and params.propId then
		propDef = GetInst("DevelopStoreDataManager"):GetDeveloperStoreSkuByItemId(params and params.propId)
	else
		propDef = GetInst("DevelopStoreDataManager"):GetCurClickPropDef()
	end

	return propDef
end

function DeveloperStoreItemOrder(ispassport, isClick, params)
	local propDef = nil
	
	local ishost = (IsRoomOwner() or AccountManager:getMultiPlayer() == 0)
	local propDef = GetDeveloperStorePropDef(ispassport, ishost, params)

	if not propDef then return end

	local needNum = propDef.CostNum;
	local mapId = 0;
	local authorUin = 0;
	local mapversion = 0;

	if ishost then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		if not wdesc then return end
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
	local def = ModEditorMgr:getItemDefById(propDef.ItemID) or ModEditorMgr:getBlockItemDefById(propDef.ItemID) or ItemDefCsv:get(propDef.ItemID);
	if def == nil then
		ShowGameTipsWithoutFilter(GetS(23005), 3);
		return;
	end

	if isClick then
		standReportEvent("6001", "PROP_DETAILS", "AdPurchaseButton", "click",{cid = tostring(G_GetFromMapid()), standby1 = propDef.ItemID, standby2 = propDef.Name})
	end

	--给账号服传广告位，方便101和103分开统计
	local adPos = 101
	if ispassport and propDef.ItemID == ITEM_PASSPORT then
		adPos = 103
	end

	--判断是否够量
	--限时 判断限售
	if propDef.Tag == g_DeveloperConfig.Developer.TagType.Timelimit then
		--开启了限售
		if propDef.LimitTimeSaleNum and propDef.LimitTimeSaleNum > 0 then
			local stock = GetInst("DevelopStoreDataManager"):GetStoreSkuItemStock(mapId, propDef.ItemID)
			if stock <= 0 then
				ShowGameTipsWithoutFilter(GetS(23183))
				return
			end
		end
	end

	--限购 判断自己是否购买过量了
	if propDef.LimitBuyNum and propDef.LimitBuyNum > 0 then
		local buyNum = GetInst("DevelopStoreDataManager"):GetStoreSkuItemBuyNum(mapId, propDef.ItemID)
		if buyNum >= propDef.LimitBuyNum then
			ShowGameTipsWithoutFilter(GetS(23182))
			return
		end
	end

	local extend_data = GetInst("ExternalRecommendMgr"):OrginazeDeveloperParam();
	local code,orderInfo = AccountManager:dev_mapbag_ad_buy_item_order(0, authorUin, tostring(mapId), propDef.ItemID,1,propDef.Name, adPos, GetCurrentCSRoomId(), extend_data)
	if code == ErrorCode.OK then
		DeveloperStoreSetOrderId(orderInfo)
		--DeveloperStoreAddItemByOrder();
		DeveloperStoreItemADBtn(params or {isExtract = true});
		
	elseif code == ErrorCode.DEV_MAPSTORE_CHEST_LEVEL_NOT_ENOUGH then 
		--{{{ 提示玩家家园多少级可以[Desc5]
		local lv = DevConfig and DevConfig.Config and DevConfig.Config.MinChestLevel 
		local sid = t_ErrorCodeToString[code]
		if sid and lv then 
			local s = GetS(sid, lv)
			if s and s ~= '' then ShowGameTipsWithoutFilter(s, 3) end
		end 
		--}}}
	else
		ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
		return;
	end
end

local m_order_id = nil --物品订单id

--设置当前订单id
function DeveloperStoreSetOrderId(orderInfo)
	if orderInfo and orderInfo.order_id then
		m_order_id = orderInfo.order_id
	end
end

--获取当前订单id
function DeveloperStoreGetOrderId()
	return m_order_id
end

function RegisterDeveloperStoreServiceListeners()
	--ShowGameTips("添加监听", 3);
	if AccountManager and type(AccountManager.service) == "table" then
		AccountManager.service:listento('dev_ad_add_item_by_order_notify', DeveloperStoreOrderResult)
	end
end

--下单推送结果
function DeveloperStoreOrderResult(param)--这个参数是给外部调用传入的，自己界面取自己的参数
	if ClientCurGame and (not ClientCurGame:isInGame()) then
		return
	end	
	--ShowGameTips("测试下单推送结果", 3);
	if not param then
		return
	end
	local ispassport = false
	local entryType = "DeveloperStore"
	local propInfo = param.content.info
	--是否自动提取
	local isExtract = true

	local propDef = nil
	local ishost = (IsRoomOwner() or AccountManager:getMultiPlayer() == 0)
	if ispassport and ishost then
		propDef = getPassPortDef()
	else
		propDef = GetInst("DevelopStoreDataManager"):GetCurClickPropDef()
	end
	if not propDef then return end
	
	local needNum = propDef.CostNum;
	local mapId = 0;
	local authorUin = 0;
	local mapversion = 0;
	if ishost then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		if not wdesc then return end
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
	local def = ModEditorMgr:getItemDefById(propDef.ItemID) or ModEditorMgr:getBlockItemDefById(propDef.ItemID) or ItemDefCsv:get(propDef.ItemID);
	if def == nil then
		ShowGameTipsWithoutFilter(GetS(23005), 3);
		return;
	end

	local code = param.content and param.content.code
	if propDef.ItemID ~= propInfo.ItemID then
		return
	end
	if code == ErrorCode.OK then
		--if item is ITEM_PASSPORT, need to add passporttime
		SetPlayerPurchaseFlag(true, 4, 1);
		local b_report = false
		if propDef.ItemID == ITEM_PASSPORT then
			if propDef.PassPortInfo and #propDef.PassPortInfo == 4 and mapId > 0 then 
				local iEndTime = AccountManager:getCurWorldPassPortEndTime(mapId)
				--if return < -1 means free map, return == -1 means no data need req data, return >= 0 means payment map
				if iEndTime >= -1 then
					local nowTime = AccountManager:getSvrTime()
					if iEndTime <= nowTime then
						iEndTime = AccountManager:getSvrTime() + propDef.PassPortInfo[1]*86400
					else
						iEndTime = iEndTime + propDef.PassPortInfo[1]*86400
					end
					AccountManager:setCurWorldPassPortEndTime(mapId, iEndTime)
					gPassPortEndTime = iEndTime
				end

				if getglobal("PassPortConfirmBuyFrame"):IsShown() then
					getglobal("PassPortConfirmBuyFrame"):Hide()
				end
				ShowGameTips(GetS(23010), 3)
				getglobal("PassPortBuySuccessFrame"):Show()
			end

			if not ispassport then
				b_report = true
			end
		else
			b_report = true
			DeveloperStoreBuyItemSuccess(propDef.ItemID, true)
		end
		if b_report then
			--数据上报
			DeveloperStoreStandReport(authorUin,propDef,mapId)
		end

		if (propDef.LimitTimeSaleNum and propDef.LimitTimeSaleNum > 0) or (propDef.LimitBuyNum and propDef.LimitBuyNum > 0) then
			DoUpateStoreItem(authorUin, mapId, propDef.ItemID, nil, function() 
				--限售 会显示数量 才需要更新界面
				if (propDef.LimitTimeSaleNum and propDef.LimitTimeSaleNum > 0) then
					--更新购买面板
					UpdateDeveloperStoreBuyItemFrameActDesc(GetInst("DevelopStoreDataManager"):GetUserClickPropNumber())
		
					--更新购买列表的数据
					local DeveloperStoreSkuFrameList = getglobal("DeveloperStoreSkuFrameList")
					if DeveloperStoreSkuFrameList and DeveloperStoreSkuFrameList:IsShown() then
						buildStoreSkuList()
					end
				end
			end)
		end
	elseif code == ErrorCode.DEV_MAPSTORE_CHEST_LEVEL_NOT_ENOUGH then 
		--{{{ 提示玩家家园多少级可以[Desc5]
		local lv = DevConfig and DevConfig.Config and DevConfig.Config.MinChestLevel 
		local sid = t_ErrorCodeToString[code]
		if sid and lv then 
			local s = GetS(sid, lv)
			if s and s ~= '' then ShowGameTipsWithoutFilter(s, 3) end
		end 
		--}}}
	else
		ShowGameTipsWithoutFilter(GetS(t_ErrorCodeToString[code]), 3);
		return;
	end
end

--数据上报
function DeveloperStoreStandReport(authorUin,propDef,mapId)
	local entryType
	if IsAdUseNewLogic(101) then
		--StatisticsADNew('finish', 101,nil,authorUin,mapId, propDef.ItemID)
		entryType = ad_data_new.entryType
	else					
		StatisticsAD('finish', 101,nil,authorUin,mapId, propDef.ItemID)
		entryType = t_ad_data.entryType
	end
	--新埋点，根据不同来源做不同上报
	if mapId == nil or mapId == 0 then
		mapId = G_GetFromMapid()
	end
	local extra = {cid=tostring(mapId)}
	if propDef then
		extra.standby1 = propDef.ItemID
		extra.standby2 = propDef.Name
	end
	if "DeveloperStore" == entryType then
		standReportEvent("6001", "PROP_DETAILS", "AdPurchaseButton", "ad_complete", extra)
	end
	if "TopPurchaseInMap" == entryType then
		standReportEvent("1003", "FAST_PURCHASE_POPUP", "AdPurchaseButton", "ad_complete", extra)
		standReportEvent("6001", "STORE_POPUP", "AdPurchaseButton", "ad_complete", extra)
	end
	if "TopPurchaseInMapOnline" == entryType then
		standReportEvent("1001", "FAST_PURCHASE_POPUP", "AdPurchaseButton", "ad_complete", extra)
		standReportEvent("6001", "STORE_POPUP", "AdPurchaseButton", "ad_complete", extra)
	end
end

function DeveloperStoreItemADBtn(param)--这个参数是给外部调用传入的，自己界面取自己的参数
	local ishost = (IsRoomOwner() or AccountManager:getMultiPlayer() == 0)
	local mapId = 0;
	if ishost then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		mapId = wdesc.fromowid;
		if wdesc.fromowid == 0 then
			mapId = wdesc.worldid;
		end
	else
		mapId = DeveloperFromOwid;
	end

	if not DeveloperStoreMapIsUpload(mapId) then
		ShowGameTipsWithoutFilter(GetS(23048))
		return
	end

	isExtract = false
	if param and param.isExtract then
		isExtract = param.isExtract
	end

	GetInst("DevelopStoreDataManager"):SetUserClickPropNumber(GetInst("DevelopStoreDataManager"):GetUserClickPropNumber(), param and param.propId)

	if ClientMgr:isPC() and not ClientMgr:getApiId() == 999 then
		ShowGameTips(GetS(32004), 3);
	    return
	end
	-- 鸿蒙渠道
	if ClientMgr and ClientMgr:getApiId() == 5 then
		ShowGameTips(GetS(100512), 3)
		return
	end

	local position_id = 101
	if IsAdUseNewLogic(position_id) then	
		GetInst("AdService"):IsAdCanShow(position_id, function(result)
			if result then
				local authUin, mapId, itemId = getCurItemSimpleInfos()
				StatisticsADNew('onclick', position_id, nil, authUin, mapId, itemId);
				if WatchADNetworkTips(OnReqWatchADDeveloperShop) then
					local entryType = "DeveloperStore";
					if param and param.entryType then
						entryType = param.entryType
					end
					OnReqWatchADDeveloperShop(nil, nil, entryType);  -- 传入来源UI，用于溯源
				end
			else
				ShowGameTips(GetS(4980))
			end
		end)
	else
		if t_ad_data.canShow(position_id) then			
			local authUin,mapId,itemId = getCurItemSimpleInfos()
			StatisticsAD('onclick', position_id, nil, authUin, mapId, itemId);
			if WatchADNetworkTips(OnReqWatchADDeveloperShop) then
				local entryType = "DeveloperStore";
				if param and param.entryType then
					entryType = param.entryType
				end
				OnReqWatchADDeveloperShop(nil, nil, entryType);  -- 传入来源UI，用于溯源
			end
		else
			ShowGameTips(GetS(4980))
		end
	end
end

function DeveloperStoreItemADBtnNew(param)--直接发放道具
	isExtract = false
	if param and param.isExtract then
		isExtract = param.isExtract
	end
	
	GetInst("DevelopStoreDataManager"):SetUserClickPropNumber(GetInst("DevelopStoreDataManager"):GetUserClickPropNumber(), param and param.propId)
	local entryType = "";
	if param and param.entryType then
		entryType = param.entryType
	end
	if ClientMgr:isPC() then
		OnReqWatchADDeveloperShop(nil,nil,entryType);--传入来源UI，用于溯源
	else
		threadpool:work(function ()
			DeveloperStoreAdGetItem(false,"")
		end)
	end
end

-------------------------通行证[Desc5]提示--------------------------
gPassPortPropDef = {}
function setPassPortDef(owid, iteminfo)
	gPassPortPropDef[owid] = iteminfo
end

function getPassPortDef()
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then
		local wdesc = AccountManager:getCurWorldDesc()
		if wdesc then
			local mapId = (wdesc.fromowid == 0) and wdesc.worldid or wdesc.fromowid
			return gPassPortPropDef[mapId]
		end
	end

	return nil
end

function PassPortConfirmBuyFrame_OnShow()

	--新埋点
	local mapId, authorUin = GetMapIdAndUin()
	if mapId == 0 or authorUin == 0 then return end
	local extra = {cid = tostring(mapId), standby3 = 103}
	DeveloperStore_StandReportEvent("MAP_PASS_POPUP", "-", "view", extra);
	DeveloperStore_StandReportEvent("MAP_PASS_POPUP", "Close", "view", extra);

	local propDef = getPassPortDef()

	ClientCurGame:setOperateUI(true)
	if propDef then
		getglobal("PassPortConfirmBuyFrameLeftBtnName"):SetPoint("center", "PassPortConfirmBuyFrameLeftBtn", "center", 0, -13)

		local price = propDef.CostNum or "1"
		getglobal("PassPortConfirmBuyFrameLeftBtnCost"):SetText(tostring(price))
		getglobal("PassPortConfirmBuyFrameLeftBtnIcon"):Show()
		getglobal("PassPortConfirmBuyFrameLeftBtnCost"):Show()

		if propDef.ADExchange == 1 and IsDeveloperStoreAdCanShow(103) then
			getglobal("PassPortConfirmBuyFrameText"):SetText(GetS(21617), 55, 54, 47)
			getglobal("PassPortConfirmBuyFrameLeftBtn"):SetPoint("bottomleft", "PassPortConfirmBuyFrameChenDi", "bottomleft", 67, -35)
			getglobal("PassPortConfirmBuyFrameRightBtn"):Show()

			local mapId = 0;
			local authorUin = 0;
			if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
				local wdesc = AccountManager:getCurWorldDesc();
				mapId = wdesc.fromowid;
				authorUin = getFromOwid(wdesc.fromowid);
				if wdesc.fromowid == 0 then
					mapId = wdesc.worldid;
					authorUin = AccountManager:getUin()
				end
			end

			if mapId == 0 or authorUin == 0 then return end
			setCurItemSimpleInfos(authorUin,mapId,propDef.ItemID)
			if IsAdUseNewLogic(103) then
				StatisticsADNew('show', 103, nil, authorUin, mapId, propDef.ItemID)				
			else
				StatisticsAD('show', 103, nil, authorUin, mapId, propDef.ItemID)				
			end
			
			DeveloperStore_StandReportEvent("MAP_PASS_POPUP", "AdPlayPurchase", "view", extra);--新埋点
			DeveloperStore_StandReportEvent("MAP_PASS_POPUP", "MiniCoinPurchase", "view", extra);--新埋点
		else
			getglobal("PassPortConfirmBuyFrameText"):SetText(GetS(21606), 55, 54, 47)
			getglobal("PassPortConfirmBuyFrameLeftBtn"):SetPoint("bottomleft", "PassPortConfirmBuyFrameChenDi", "bottomleft", 220, -35)
			getglobal("PassPortConfirmBuyFrameRightBtn"):Hide()
			
			DeveloperStore_StandReportEvent("MAP_PASS_POPUP", "AdPlayPurchase", "view", extra);--新埋点
			DeveloperStore_StandReportEvent("MAP_PASS_POPUP", "MiniCoinPurchase", "view", extra);--新埋点
		end
	else
		getglobal("PassPortConfirmBuyFrameText"):SetText(GetS(21606), 55, 54, 47)
		getglobal("PassPortConfirmBuyFrameLeftBtn"):SetPoint("bottomleft", "PassPortConfirmBuyFrameChenDi", "bottomleft", 220, -35)
		getglobal("PassPortConfirmBuyFrameRightBtn"):Hide()

		getglobal("PassPortConfirmBuyFrameLeftBtnName"):SetPoint("center", "PassPortConfirmBuyFrameLeftBtn", "center", 0, 0)
		getglobal("PassPortConfirmBuyFrameLeftBtnIcon"):Hide()
		getglobal("PassPortConfirmBuyFrameLeftBtnCost"):Hide()
		DeveloperStore_StandReportEvent("MAP_PASS_POPUP", "AdPlayPurchase", "view", extra);--新埋点
		DeveloperStore_StandReportEvent("MAP_PASS_POPUP", "MiniCoinPurchase", "view", extra);--新埋点
	end
end

function PassPortConfirmBuyFrame_OnHide()
	if ClientCurGame then
		ClientCurGame:setOperateUI(false)
	end
end

function PassPortConfirmBuyFrameLeftBtn_OnClick()
	local mapId, authorUin = GetMapIdAndUin()
	if mapId == 0 or authorUin == 0 then return end
	local extra = {cid = tostring(mapId), standby3 = 103}

	DeveloperStore_StandReportEvent("MAP_PASS_POPUP", "MiniCoinPurchase", "click", extra);--新埋点
	if IsStandAloneMode() then return end
	DeveloperStoreBuyItemFrameBuyBtn(true)
end

function PassPortConfirmBuyFrameRightBtn_OnClick()
	local mapId, authorUin = GetMapIdAndUin()
	if mapId == 0 or authorUin == 0 then return end

	local position_id = 103
	local extra = {cid = tostring(mapId), standby3 = position_id}

	DeveloperStore_StandReportEvent("MAP_PASS_POPUP", "AdPlayPurchase", "click", extra);--新埋点
	local authUin, mapId, itemId = getCurItemSimpleInfos()
	if not authUin or not mapId or itemId ~= ITEM_PASSPORT then return end
	if IsAdUseNewLogic(position_id) then
		StatisticsADNew('onclick', position_id, nil, authUin, mapId, itemId)
	else
		StatisticsAD('onclick', position_id, nil, authUin, mapId, itemId)
	end
	if WatchADNetworkTips(OnReqWatchADGetPassPort) then
		OnReqWatchADGetPassPort()
	end
end

function PassPortConfirmBuyFrameCloseBtn_OnClick()
	local mapId, authorUin = GetMapIdAndUin()
	if mapId == 0 or authorUin == 0 then return end
	local extra = {cid = tostring(mapId), standby3 = 103}

	DeveloperStore_StandReportEvent("MAP_PASS_POPUP", "Close", "click", extra);--新埋点
	if ClientCurGame then
		ClientCurGame:setOperateUI(false)
	end
	getglobal("PassPortConfirmBuyFrame"):Hide()
	if getglobal("CreateRoomFrame"):IsShown() then
		getglobal("CreateRoomFrame"):Hide()
	end

	--here will stop player play in this world
	GoToMainMenu()
end

-----------------------------通行证[Desc5]成功后的面板----------------------------------------
function PassPortBuySuccessFrame_OnShow()
	local propDef = getPassPortDef() or GetInst("DevelopStoreDataManager"):GetCurClickPropDef()

	if not propDef or not propDef.PassPortInfo or #propDef.PassPortInfo ~= 4 or propDef.ItemID ~= ITEM_PASSPORT then return end

	if ClientCurGame then
		ClientCurGame:setOperateUI(true)
	end

	local itemdef = ItemDefCsv:get(ITEM_PASSPORT)
	local name = itemdef and itemdef.Name or propDef.Name
	getglobal("PassPortBuySuccessFrameName"):SetText(name or "")
	getglobal("PassPortBuySuccessFrameTime"):SetText(GetS(4086)..propDef.PassPortInfo[1]..GetS(4087))
end

function PassPortBuySuccessFrame_OnHide()
	if ClientCurGame then
		ClientCurGame:setOperateUI(false)
	end
end

function PassPortBuySuccessFrameCloseBtn_OnClick()
	getglobal("PassPortBuySuccessFrame"):Hide()
end

-----------------------------选择道具类型：1:创建新分类 2:重命名，3:删除类型，-----------------------------------
gCorfirmData = {}
function PropTypeConfirmFrame_OnShow()
	local titlelab = getglobal("PropTypeConfirmFrameTitleBkgTitle")
	local contentlab = getglobal("PropTypeConfirmFrameContent")
	local editor = getglobal("PropTypeConfirmFrameEdit")
	local editorbg = getglobal("PropTypeConfirmFrameEditBkg")
	local leftbtn = getglobal("PropTypeConfirmFrameLeftBtn")
	local rightbtn = getglobal("PropTypeConfirmFrameRightBtn")

	if gCorfirmData.type == 1 then --创建新分类
		contentlab:Hide()
		editor:Show()
		editorbg:Show()
		leftbtn:Hide()

		titlelab:SetText(GetS(23036))
		editor:SetDefaultText(GetS(23035))
		editor:SetText("")
		rightbtn:SetPoint("bottom", "PropTypeConfirmFrameChenDi", "bottom", 0, -26)
	elseif gCorfirmData.type == 2 then --重命名
		contentlab:Hide()
		editor:Show()
		editorbg:Show()
		leftbtn:Hide()

		titlelab:SetText(GetS(23025))
		editor:SetDefaultText(GetS(3642))
		editor:SetText("")
		rightbtn:SetPoint("bottom", "PropTypeConfirmFrameChenDi", "bottom", 0, -26)
	elseif gCorfirmData.type == 3 then --删除类型
		contentlab:Show()
		editor:Hide()
		editorbg:Hide()
		leftbtn:Show()

		titlelab:SetText(GetS(4022))
		rightbtn:SetPoint("bottom", "PropTypeConfirmFrameChenDi", "bottom", 150, -26)
	end
end

function PropTypeConfirmFrame_OnHide()
	-- body
end

function PropTypeConfirmFrameCloseBtn_OnClick()
	getglobal("PropTypeConfirmFrame"):Hide()
end

function PropTypeConfirmFrameLeftBtn_OnClick()
	PropTypeConfirmFrameCloseBtn_OnClick()
end

function  EditCharSize(ch)
    if not ch then return 0
    elseif ch >=252 then return 6
    elseif ch >= 248 and ch < 252 then return 5
    elseif ch >= 240 and ch < 248 then return 4
    elseif ch >= 224 and ch < 240 then return 3
    elseif ch >= 192 and ch < 224 then return 2
    elseif ch < 192 then return 1
    end
end

function  EditUtf8Len(s)
	local str = tostring(s)
    if not str then
      return 0
    end
    local len = 0
    local aNum = 0
    local hNum = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        local cs = EditCharSize(char)
        currentIndex = currentIndex + cs
        len = len +1
        if cs == 1 then
            aNum = aNum + 1
        elseif cs >= 2 then
            hNum = hNum + 1
        end
    end
    return len, aNum, hNum
end

function PropTypeConfirmFrameEdit_textChange()
	local editor = getglobal("PropTypeConfirmFrameEdit")
	local name = editor:GetText()
	if name then
		local lenth, aNum, hNum = EditUtf8Len(name)--字符数
		local len = string.len(name) --字节数
		if lenth then
			if lenth > 10 or len > 15 then
				-- name = EditSubString(name,10)
				-- editor:SetText(name)
				getglobal("PropTypeConfirmFrameTips"):Show();
			else
				getglobal("PropTypeConfirmFrameTips"):Hide();
			end
		end
	end
end

function EditSubString(s,lenth)
	local str = tostring(s)
    if not str then
      return "";
    end
	
    local len = 0
    local currentIndex = 1
	local result = "";
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        local cs = EditCharSize(char)
        currentIndex = currentIndex + cs
        len = len +1
		if len == lenth then
			result =string.sub(str, 1, currentIndex-1)
			break
		end
    end
	
    return result

end


--分类操作确认点击
function PropTypeConfirmFrameRightBtn_OnClick()
	local StoreSkuList = GetInst("DevelopStoreDataManager"):GetStoreSkuList()
	local StoreGroupTypeMap = GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMap()
	local mapId, authorUin = GetMapIdAndUin()
	if mapId == 0 or authorUin == 0 then return end
	if gCorfirmData.type == 1 then
		local editor = getglobal("PropTypeConfirmFrameEdit")
		local name = editor:GetText()
		local lenth, aNum, hNum = EditUtf8Len(name)--字符数
		local len = string.len(name) --字节数
		if name == "" then
			ShowGameTips(GetS(23035))
			return
		elseif len > 15 or lenth > 10 then --五个中文或10个英文
			ShowGameTips(GetS(23031))
			getglobal("PropTypeConfirmFrameTips"):Show();
			return
		elseif CheckFilterString(name) then	--敏感词
			editor:SetText("")
			ShowGameTips(GetS(23032))
			return
		end

		local StoreGroupType = {}
		StoreGroupType.GroupID = GenStoreGroupID()
		if StoreGroupType.GroupID == 0 then
			ShowGameTips(GetS(23037))
			return
		end

		if not uploadStoreGroupInfo() then return end
		StoreGroupType.GroupName = name
		StoreGroupType.Pos = #gStoreGroupTypList == 0 and 11 or #gStoreGroupTypList+1
		--local code = AccountManager:dev_mapstore_add_itemgroup(authorUin, mapId, StoreGroupType)
		--if code == ErrorCode.OK then
		if DeveloperStoreAdditemgroup(authorUin, mapId, StoreGroupType) then
			table.insert(gStoreGroupTypList, StoreGroupType.GroupID)
			StoreGroupTypeMap[StoreGroupType.GroupID] = deep_copy_table(StoreGroupType)
			ShowGameTips(GetS(4079))
			buildPropTypeList(1, false, true)
			buildSelectPropTypeList()
			PropTypeConfirmFrameCloseBtn_OnClick()
		end
	elseif gCorfirmData.type == 2 and gCorfirmData.Pos and #gStoreGroupTypList >= gCorfirmData.Pos then
		--if gStoreGroupTypList[gCorfirmData.Pos] <= 10 then return end

		local StoreGroupType = StoreGroupTypeMap[gStoreGroupTypList[gCorfirmData.Pos]]
		if StoreGroupType then
			local editor = getglobal("PropTypeConfirmFrameEdit")
			local name = editor:GetText()
			local lenth, aNum, hNum = EditUtf8Len(name)--字符数
			local len = string.len(name) --字节数
			if name == "" then
				ShowGameTips(GetS(3642))
				return
			elseif len > 15 or lenth > 10  then --五个中文或10个英文
				ShowGameTips(GetS(23031))
				getglobal("PropTypeConfirmFrameTips"):Show();
				return
			elseif CheckFilterString(name) then	--敏感词
				editor:SetText("")
				ShowGameTips(GetS(23032))
				return
			end

			if not uploadStoreGroupInfo() then return end

			StoreGroupType.GroupName = name
			--local code = AccountManager:dev_mapstore_set_itemgroup_list(authorUin, mapId, {StoreGroupType})
			--if code == ErrorCode.OK then
			if DeveloperStoreGroupsRame(authorUin, mapId, StoreGroupType) then 
				ShowGameTips(GetS(23028))
				StoreGroupType.GroupName = name
				local listview = getglobal("DeveloperStoreMapPurchaseFramePropTypeList")
				local cell = listview:cellAtIndex(gCorfirmData.Pos-1)
				if cell then
					local lab = getglobal(cell:GetName().."BtnName")
					if lab then
						lab:SetText(StoreGroupType.GroupName)
					end
				end
				PropTypeConfirmFrameCloseBtn_OnClick()
			end
		end
	elseif gCorfirmData.type == 3 and gCorfirmData.Pos and #gStoreGroupTypList >= gCorfirmData.Pos then
		local GroupID = gStoreGroupTypList[gCorfirmData.Pos]
		--if GroupID <= 10 then return end
		if not uploadStoreGroupInfo() then return end

		--local code = AccountManager:dev_mapstore_rm_itemgroup(authorUin, mapId, GroupID)
		--if code == ErrorCode.OK then
		if DeveloperStoreRmitemgroup(authorUin, mapId, GroupID) then
			ShowGameTips(GetS(3992))
			StoreGroupTypeMap[GroupID] = nil --删除掉Map里的
			table.remove(gStoreGroupTypList, gCorfirmData.Pos) --删除掉列表数据
			--重新给定Pos
			for i=1,#gStoreGroupTypList do
				local StoreGroupType = StoreGroupTypeMap[gStoreGroupTypList[i]]
				if StoreGroupType then
					StoreGroupType.Pos = i
				end
			end

			if gSelectPropType == gCorfirmData.Pos then
				gSelectPropType = 1
				buildPropTypeList(1)
			else
				buildPropTypeList(1, false, true)
			end

			--商品类型变更
			local bChanged = false
			local indexs={}
			for i=1,#StoreSkuList do
				local StoreSkuInfo = StoreSkuList[i]
				if GroupID == StoreSkuInfo.ItemGroup then
					--StoreSkuInfo.ItemGroup = 7--放到其他类型里
					table.insert(indexs,i)
					bChanged = true

				end
			end

			if bChanged then
				ReMoveStoreInfo(indexs)
				LoadDeveloperPropList(true)
			end
			PropTypeConfirmFrameCloseBtn_OnClick()
		end
	end
end
function ReMoveStoreInfo(indexs)
	local StoreSkuList = GetInst("DevelopStoreDataManager"):GetStoreSkuList()
	table.sort(indexs, sortNumber)
	for i=1,#indexs do
		local StoreSkuInfo = StoreSkuList[indexs[i]]
		local DeleteDeveloperPropListTemp = GetInst("DevelopStoreDataManager"):GetDeleteDeveloperPropListTemp()
		table.insert(DeleteDeveloperPropListTemp, StoreSkuInfo.ItemID)
		table.remove(StoreSkuList, indexs[i])
	end
	-- body
end

function sortNumber(a, b)
    return a > b
end

function OpenPropTypeConfirmFrame(data)
	if not data and not data.type then return end

	gCorfirmData = data
	getglobal("PropTypeConfirmFrame"):Show()
end

--自定义分类GroupID生成
function GenStoreGroupID()
	if #gStoreGroupTypList == GetInst("DevelopStoreDataManager"):GetGroupTypeMaxNum() then return 0 end
	local StoreGroupTypeMap = GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMap()
	for i=2,16 do
		if not StoreGroupTypeMap[i] then
			return i
		end
	end

	return 0
end

-----------------------------菜单分类--------------------------------
gSelectPropType = 1
gStoreGroupTypList = {}
gSwapTypeInfo = {bSwap=false}
function GetMapIdAndUin()
	local mapId = 0
	local authorUin = 0

	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc()
		if wdesc then
			mapId = wdesc.fromowid
			authorUin = getFromOwid(wdesc.fromowid)
			if wdesc.fromowid == 0 then
				mapId = wdesc.worldid
				authorUin = AccountManager:getUin()
			end
		end
	else
		mapId = DeveloperFromOwid
		authorUin = getFromOwid(mapId)
	end

	return mapId, authorUin
end

--分类数据处理
function LoadStoreGroupInfo(bneedfresh)
	local mapId, authorUin = GetMapIdAndUin()
	gStoreGroupTypList = {}
	if mapId == 0 or authorUin == 0 then return end
	local tmplist = {}
	local StoreGroupTypeMap = GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMap()
	if bneedfresh  or not StoreGroupTypeMap[1] then
		GetInst("DevelopStoreDataManager"):SetStoreGroupTypeMap({})
		StoreGroupTypeMap = GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMap()
		local code, list, needaddGroup =DeveloperStoreGetItemgrouplist(authorUin, mapId)
		if code and type(list) == 'table' then
			local maxnum, baselist = #ItemGroupID2Name, {}
			local haveall = false;
			for k,v in pairs(list) do --此处list已经是做过深度拷贝的
				if type(v) == 'table' and v.GroupID and v.Pos then
					table.insert(tmplist, v)
					StoreGroupTypeMap[v.GroupID] = v
					if 1 == v.GroupID then
						haveall = true
					end
					if v.GroupID <= maxnum then
						baselist[v.GroupID] = 1
					end
				end
			end
			if #baselist < 1 then --服务器的数据里  基础的10个不全  需要补上
				if needaddGroup then
					maxnum = #OldItemGroupID2Name
					for i=1,maxnum do
						if not baselist[i] then
							local StoreGroupType = {}
							StoreGroupType.GroupID = i
							StoreGroupType.Pos = i
							StoreGroupType.GroupName = OldItemGroupID2Name[i]
							StoreGroupTypeMap[i] = StoreGroupType
							table.insert(tmplist, StoreGroupType)
							IsNeedUpload = true
						end
					end
				else
					for i=1,1 do
						if not baselist[i] then
							local StoreGroupType = {}
							StoreGroupType.GroupID = i
							StoreGroupType.Pos = i
							StoreGroupType.GroupName = ItemGroupID2Name[i]
							StoreGroupTypeMap[i] = StoreGroupType
							table.insert(tmplist, StoreGroupType)
							IsNeedUpload = true
						end
					end
				end
			else --检测是不是有综合和全部 没有则补齐
				-- body
				if not haveall then
					local StoreGroupType = {}
					StoreGroupType.GroupID = 1
					StoreGroupType.Pos = 1
					StoreGroupType.GroupName = ItemGroupID2Name[1]
					StoreGroupTypeMap[1] = StoreGroupType
					table.insert(tmplist, StoreGroupType)
				end
			end
		else
			local maxnum, baselist = #ItemGroupID2Name, {}
			if #baselist < 1 then --服务器的数据里  基础的10个不全  需要补上
				for i=1,1 do
					if not baselist[i] then
						local StoreGroupType = {}
						StoreGroupType.GroupID = i
						StoreGroupType.Pos = i
						StoreGroupType.GroupName = ItemGroupID2Name[i]
						StoreGroupTypeMap[i] = StoreGroupType
						table.insert(tmplist, StoreGroupType)
						IsNeedUpload = true
					end
				end
			end
		end
	else --用本地数据
		for k,v in pairs(StoreGroupTypeMap) do
			table.insert(tmplist, StoreGroupTypeMap[k])
		end
	end

	if not CurWorld:isGameMakerMode() then	-- 不是编辑模式
		if tmplist and #tmplist > 1 then
			local screenData = GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMapByScreen()
			local function isScreenData(groupID)
				for m,n in pairs(screenData) do
					if groupID == n.GroupID then
						return true
					end
				end
				return false
			end

			local skus = DeveloperStoreGetItemlist(authorUin, mapId)
			local itemGroupKey = {}
			itemGroupKey[1] = true -- 综合
			for k, v in pairs(skus or {}) do
				local itemGroup = v.ItemGroup or 1 -- 如果itemgroup为nil则默认为1
				--不隐藏 并且上架的商品 才显示分组
				--为了兼容 没有该字段数据 默认显示和上架 才这么判断
				if not (v.Visible == 0 or v.Updown == 0) then
					if v.Tag == g_DeveloperConfig.Developer.TagType.Timelimit then
						v.PropCurTime = v.LimitEnd - utils.ts2day(getServerNow())
						if (v.PropCurTime and v.PropCurTime > 0) then
							itemGroupKey[itemGroup] = true
						end
					else
						itemGroupKey[itemGroup] = true
					end
				end
			end
			for i=#tmplist, 1, -1 do
				local bRemove = false
				local groupID = tmplist[i].GroupID
				if groupID and not itemGroupKey[groupID] then -- 数量大于1的标签才显示
					bRemove = true
				end
				if screenData and not isScreenData(groupID) then -- 如果有筛选数据且不在筛选范围内
					bRemove = true
				end
				if bRemove then
					table.remove(tmplist, i)
				end
			end
		end
	end

	table.sort(tmplist, function(a, b) return a.Pos < b.Pos end)
	for i=1,#tmplist do
		gStoreGroupTypList[i] = tmplist[i].GroupID
		tmplist[i].Pos = i
	end
end

--上传如果服务器没有初始化基础类型，就需要同步给服务器
function uploadStoreGroupInfo()
	if IsNeedUpload then
		local mapId, authorUin = GetMapIdAndUin()
		if mapId == 0 or authorUin == 0 then return false end

		local StoreGroupTypeMap = GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMap()
		local list = {}
		for k,v in pairs(StoreGroupTypeMap) do
			table.insert(list, v)
		end
		if #list == 0 then return true end

		--local code = AccountManager:dev_mapstore_set_itemgroup_list(authorUin, mapId, list)
		--if code == ErrorCode.OK then
		if DeveloperStoreSetGroups(authorUin, mapId, list) then
			IsNeedUpload = false
			return true
		else
			return false
		end
	end

	return true
end

function getGroupTypeName(groupID)
	if not groupID then
		return ItemGroupID2Name[1]
	elseif groupID <= 10 then
		--return ItemGroupID2Name[groupID]
	end

	local StoreGroupTypeMap = GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMap()
	local data = StoreGroupTypeMap[groupID]
	if data then
		return data.GroupName
	elseif ItemGroupID2Name[groupID] then
		return ItemGroupID2Name[groupID]
	end
	return ItemGroupID2Name[1]
end

function DeveloperStoreTabList_tableCellAtIndex(tableview, idx)
	local bEditorModel, listname = true, tableview:GetName()
	if string.find(listname, "DeveloperStoreSkuFrame") then
		bEditorModel = false
	end

	local cell, uiidx = tableview:dequeueCell(0)
	if not cell then
		if bEditorModel then
			cell = UIFrameMgr:CreateFrameByTemplate("Frame", listname .. "Item" .. uiidx, "DeveloperStorePropTypeTemplate", listname)
		else
			cell = UIFrameMgr:CreateFrameByTemplate("Button", listname .. "Item" .. uiidx, "DeveloperStorePropTypeBtnTemplate", listname)
		end
	else
		cell:Show()
	end

	local index = idx+1
	cell:SetClientUserData(0, index)
	setPropTypeInfo(cell:GetName(), index, bEditorModel)

	local cellname=cell:GetName()
	--cellname来区分模式,(滑动组件不断刷新按钮的显示状态，所以会有重复，故使用PropTypeStandReportState记录已经view过的)
	local GroupID =  gStoreGroupTypList[index]
	if string.find(cellname,"DeveloperStoreSkuFramePropTypeList") and not PropTypeStandReportState[GroupID] then
		if ItemGroupID2StandReportKey[GroupID] then
			standReportEvent("60", "DEVELOPER_SHOP_CONTAINER", ItemGroupID2StandReportKey[GroupID], "view")
			PropTypeStandReportState[GroupID]=true
		end
	end
	return cell
end

function DeveloperStoreTabList_numberOfCellsInTableView(tableview)
	-- local bEditorModel, listname = true, tableview:GetName()
	-- if string.find(listname, "DeveloperStoreSkuFrame") then
	-- 	bEditorModel = false
	-- end
	-- if bEditorModel then
	-- 	--小于最大数量
	-- 	if #gStoreGroupTypList < GetInst("DevelopStoreDataManager"):GetGroupTypeMaxNum() then
	-- 		return #gStoreGroupTypList + 1
	-- 	else
	-- 		return #gStoreGroupTypList
	-- 	end
	-- else
		return #gStoreGroupTypList
	-- end
end

function DeveloperStoreTabList_tableCellSizeForIndex(tableview, idx)
	return (idx+1)*13+idx*128, 11, 128, 40
end

function DeveloperStoreTabList_tableCellWillRecycle(tableview, cell)
	if cell then cell:Hide() end
end

function buildPropTypeList(type, bneedfresh, notRefreshOffset)
	if bneedfresh then gSwapTypeInfo = {} end
	LoadStoreGroupInfo(bneedfresh)
	standReportEvent("60", "DEVELOPER_SHOP_TOP", "-", "view")
	local listview_name = type == 1 and "DeveloperStoreMapPurchaseFramePropTypeList" or "DeveloperStoreSkuFramePropTypeList"
	local listview = getglobal(listview_name)
	if type==2 then--条件应当是listview是DeveloperStoreSkuFramePropTypeList，type==2只是因为目前参数只有这个会设置listview为
		PropTypeStandReportState={}
		PropItemsStandReportState={}
		standReportEvent("60", "DEVELOPER_SHOP_CONTAINER", "Warehouse", "view", {standby1 = 1})
	end

	--1012:显示面板宽度，128：item宽度，13：item间隔
	local width = 1012
	local addTypeBtn = getglobal("DeveloperStoreMapPurchaseFramePropAddTypeBtn")
	if type == 1 then 
		width = 1012-128-13*2
		setAddTypeBtnEnable()
	end

	if gStoreGroupTypList and #gStoreGroupTypList == 1 then -- 只有一个选项的时候防止滑动到屏幕外
		width = 128+13
	end
	listview:SetWidth(width)
	if notRefreshOffset then
		listview:initData(width, 40, 1, GetInst("DevelopStoreDataManager"):GetGroupTypeMaxNum(), true)
	else
		listview:initData(width, 40, 1, GetInst("DevelopStoreDataManager"):GetGroupTypeMaxNum())
	end
	local plane_width = #gStoreGroupTypList*141+13;
	if plane_width < width then  plane_width = width end;
	getglobal(listview_name.."Plane"):SetWidth(plane_width)
end

function setAddTypeBtnEnable()
	local enable = true;
	local addTypeBtn = getglobal("DeveloperStoreMapPurchaseFramePropAddTypeBtn")
	if #gStoreGroupTypList >= GetInst("DevelopStoreDataManager"):GetGroupTypeMaxNum() or gSwapTypeInfo.bSwap then
		enable = false;
	end
	if addTypeBtn and  enable then 
		addTypeBtn:Enable()
	elseif addTypeBtn then
		addTypeBtn:Disable()
	end
end

--设置分类列表item信息
function setPropTypeInfo(cellname, idx, bEditorModel)
	local name = bEditorModel and "Btn" or ""
	local lab = getglobal(cellname..name.."Name")
	local normal = getglobal(cellname.."BtnNormal")
	local operateBtn = getglobal(cellname.."OperateBtn")
	local swapBtn = getglobal(cellname.."SwapMoveBtn")
	
	local GroupID =  gStoreGroupTypList[idx]
	if not GroupID then return end
	local StoreGroupTypeMap = GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMap()
	local data = StoreGroupTypeMap[GroupID]
	if not data then return end
	lab:SetText(getGroupTypeName(GroupID))
	if bEditorModel then
		if gSwapTypeInfo.bSwap then
			operateBtn:Hide()
			local selectId = gStoreGroupTypList[gSwapTypeInfo.selectIdx]
			if GroupID == 1 or GroupID == selectId then
				normal:SetGray(true)
				swapBtn:Hide()
			else
				normal:SetGray(false)
				swapBtn:Show()
			end
		else
			normal:SetGray(false)
			swapBtn:Hide()
			if GroupID == 1 then
				operateBtn:Hide()
			else
				operateBtn:Show()
			end
		end
	end

	managePropTypeTab(cellname..name, idx, gSwapTypeInfo.bSwap)
end

function managePropTypeTab(cellname, idx, bSwap)
	local normal = getglobal(cellname.."Normal")
	local check = getglobal(cellname.."Check")

	if not (normal and check) then
		return
	end

	if idx == gSelectPropType and not bSwap then
		normal:Hide()
		check:Show()
	else
		normal:Show()
		check:Hide()
	end
end

--玩法模式
function DeveloperStorePropTypeBtnTemplate_OnClick(index,cellName)
	Other_OnClick()
	local data = index or this:GetClientUserData(0)
	if gSelectPropType == data then return end

	local listview = getglobal("DeveloperStoreSkuFramePropTypeList")
	local setCell = function (index)
		local cell = listview:cellAtIndex(index)
		if cell then
			managePropTypeTab(cell:GetName(), data)
		end
	end

	if gSelectPropType > 0 then
		setCell(gSelectPropType-1)
	else
		for i = 1,#gStoreGroupTypList do
			setCell(i)
		end
	end

	gSelectPropType = data
	managePropTypeTab(cellName or this:GetName(), data)

	--if gDeveloperStoreType ~= 2 then
		gDeveloperStoreType = 2
		manageStoreType()
	--end
	LoadDeveloperPropList()
	buildStoreSkuList()

	--点击了商品类型按钮
	if ItemGroupID2StandReportKey[data] then
		standReportEvent("60", "DEVELOPER_SHOP_CONTAINER", ItemGroupID2StandReportKey[data] , "click")
	end
	--展示此类商品面板
	if ItemGroupID2StandReportKeyForContainer[data] then
		standReportEvent("60", ItemGroupID2StandReportKeyForContainer[data],"-", "view")
	end

	ReportStoreCardPpopDetails()
end

--编辑模式
function DeveloperStorePropTypeTemplateBtn_OnClick()
	Other_OnClick()
	local data = this:GetParentFrame():GetClientUserData(0)
	if data == #gStoreGroupTypList + 1 then
		GroupTypeAddItem_OnClick()
	else
		if gSwapTypeInfo.bSwap then
			if data ~= gSwapTypeInfo.selectIdx then
				return
			else
				gSwapTypeInfo.bSwap = false
				gSelectPropType = gSwapTypeInfo.selectIdx
				buildPropTypeList(1, false, true)
			end
		end
		if gSelectPropType == data then return end
	
		local listview = getglobal("DeveloperStoreMapPurchaseFramePropTypeList")
		local cell = listview:cellAtIndex(gSelectPropType-1)
		if cell then
			managePropTypeTab(cell:GetName().."Btn", data)
		end
		gSelectPropType = data
		managePropTypeTab(this:GetName(), data)
		
		LoadDeveloperPropList(true)
		UpdateDeveloperStoreBoxPlane(true)
	end
end

function DeveloperStorePropTypeTemplateOperateBtn_OnClick()
	local index = this:GetParentFrame():GetClientUserData(0)
	openPropTypeTips(index)
end

--调序点击
function DeveloperStorePropTypeTemplateSwapMoveBtn_OnClick()
	local index = this:GetParentFrame():GetClientUserData(0)
	if gSwapTypeInfo and gSwapTypeInfo.bSwap then
		local mapId, authorUin = GetMapIdAndUin()
		if mapId == 0 or authorUin == 0 then return end
		if not uploadStoreGroupInfo() then return end

		local id1, id2 = gStoreGroupTypList[gSwapTypeInfo.selectIdx], gStoreGroupTypList[index]
		if not id1 or not id2 then return end
		local StoreGroupTypeMap = GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMap()
		local tab1, tab2 = StoreGroupTypeMap[id1], StoreGroupTypeMap[id2]
		if not tab1 or not tab2 then return end
		local tmp1, tmp2 = deep_copy_table(tab1), deep_copy_table(tab2)
		tmp2.Pos, tmp1.Pos = gSwapTypeInfo.selectIdx, index

		local swaplist = {}
		table.insert(swaplist, tmp1)
		table.insert(swaplist, tmp2)
		--local code = AccountManager:dev_mapstore_set_itemgroup_list(authorUin, mapId, swaplist)
		--if code == ErrorCode.OK then
		if DeveloperStoreswapGroups(authorUin, mapId, swaplist) then
			gSwapTypeInfo.bSwap = false
			StoreGroupTypeMap[id2].Pos, StoreGroupTypeMap[id1].Pos = gSwapTypeInfo.selectIdx, index
			gStoreGroupTypList[index], gStoreGroupTypList[gSwapTypeInfo.selectIdx] = gStoreGroupTypList[gSwapTypeInfo.selectIdx], gStoreGroupTypList[index]
			gSelectPropType = index
			buildPropTypeList(1, false, true)
			ShowGameTips(GetS(23029))
		end
	end
end

-----------------------------玩法模式改版(包括商店和仓库) start------------------------------------
local gBeanNum, gCoinNum = 1, 1
local isShowPoint = false
local gPointNum = 0

function DeveloperStoreSkuFrame_OnLoad()
	RegisterDeveloperStoreServiceListeners()
end

function DeveloperStoreSkuFrame_OnShow()
	standReportEvent("60", "DEVELOPER_SHOP_TOP", "-", "view")
	standReportEvent("60", "DEVELOPER_SHOP_TOP", "Close", "view")
	standReportEvent("60", "DEVELOPER_SHOP_TOP", "MiniBeanRecharge", "view")
	standReportEvent("60", "DEVELOPER_SHOP_TOP", "MiniCoinRecharge", "view")

	standReportEvent("6001", "PROP", "-", "view",{cid = G_GetFromMapid()});
	
	DeveloperStoreDealButtonShow()

	ClientCurGame:setOperateUI(true)
		--1. 迷你币,迷你豆
	gBeanNum, gCoinNum = AccountManager:getAccountData():getMiniBean(), AccountManager:getAccountData():getMiniCoin()
	getglobal("DeveloperStoreSkuFrameMyMiniBeanFont"):SetText(gBeanNum)
	getglobal("DeveloperStoreSkuFrameMyMiniCoinFont"):SetText(gCoinNum)
	manageStoreType()

	gPointNum = AccountManager:getAccountData():getADPoint() or 0
	if gPointNum < 0 then gPointNum = 0 end
	getglobal("DeveloperStoreSkuFrameMyMiniPointFont"):SetText(gPointNum)
	local advertCfg = GetInst("ShopConfig"):GetCfgByKey("advertCfg")
	-- if advertCfg and advertCfg.advert and advertCfg.advert == 1 then
		DeveloperStoreSkuFrameCheckMiniPoint(true)
	-- else
	-- 	DeveloperStoreSkuFrameCheckMiniPoint(false)
	-- end
	if IsOpenSavePlayerData() then
		getglobal("DeveloperStoreSkuFrameCostTips"):Show()
		getglobal("DeveloperStoreSkuFrameCostTips"):SetText(GetS(9312202), 250, 122, 15)
	else
		getglobal("DeveloperStoreSkuFrameCostTips"):Hide()
	end

	standReportEvent("6001", "PROP_DETAILS", "Explain", "view",{cid=G_GetFromMapid()}) 
	getglobal("DeveloperStoreSkuFrameContentFrameContent"):SetText(GetS(9312201), 224, 220, 202)
	
	if ClientMgr:getNetworkState() == 0 then
 		NoNetworkEnterDeveloperStore()
 	else
		buildPropTypeList(2,true) -- 先初始化gStoreGroupTypList防止LoadDeveloperPropList用到的数据异常
 		LoadDeveloperPropList()
		buildStoreSkuList()
		--默认展示综合面板
		if ItemGroupID2StandReportKeyForContainer[1] then
			standReportEvent("60", ItemGroupID2StandReportKeyForContainer[1],"-", "view")
		end
		local name = 'XXX'
		-- 客机
		if IsRoomClient() then
			-- 判断g_ScreenshotShareRoomDesc为空的情况 客户端连云服的情况 by huanglin
			if g_ScreenshotShareRoomDesc and g_ScreenshotShareRoomDesc.worldname then
				name = g_ScreenshotShareRoomDesc.worldname
			else
				local map = mapservice.mapInfoCache[G_GetFromMapid()];
				if map then
					name = map.name
				else
					name = nil
				end
			end
		else
			-- 主机或者单机
			name = AccountManager:getCurWorldDesc().worldname
		end

		if name == nil then
			getglobal("DeveloperStoreSkuFrameTitleFrameName"):SetText(GetS(3745))
		else
			getglobal("DeveloperStoreSkuFrameTitleFrameName"):SetText(GetS(23153, name))
		end
		if GetInst("DevelopStoreDataManager"):GetStoreShopName() then
			getglobal("DeveloperStoreSkuFrameTitleFrameName"):SetText(GetInst("DevelopStoreDataManager"):GetStoreShopName())
		end
		ReportStoreCardPpopDetails()
	end

	NotEnoughCoinDataName = nil
	if this then
		this:RegisterEvent("GIE_PAY_RESULT")
	end
	getglobal("DeveloperStoreSkuFramePropTypeList"):Show() -- 修复切换仓库，再重新进入商店会导致分类标签被隐藏的bug
	DeveloperStoreSetBtnChecked(true);
end

function DeveloperStoreSkuFrame_OnHide()
	ClientCurGame:setOperateUI(false)
	NotEnoughCoinDataName = nil
	if this then
		this:UnRegisterEvent("GIE_PAY_RESULT")
	end
	GetInst("NewDeveloperStoreInterface"):CloseAll()
	GetInst("DevelopStoreDataManager"):RemovePropRechargeEvent()
end

function DeveloperStoreSkuFrame_OnUpdate()
	if gBeanNum ~= AccountManager:getAccountData():getMiniBean() then
		gBeanNum = AccountManager:getAccountData():getMiniBean()
		getglobal("DeveloperStoreSkuFrameMyMiniBeanFont"):SetText(gBeanNum)
	end

	if gCoinNum ~= AccountManager:getAccountData():getMiniCoin() then
		--关闭二维码界面
		if gCoinNum < AccountManager:getAccountData():getMiniCoin() then
			if getglobal("PayQrFrame"):IsShown() then
				getglobal("PayQrFrame"):Hide()
				--显示积分获得弹窗
				print("mreci rechargeAmount ",rechargeAmount)
				if GetInst("IntegralMallManager") then
					GetInst("IntegralMallManager"):ShowPointsGetTips(rechargeAmount * 10)
				end
				rechargeAmount = 0
			end
			ShowGameTips(GetS(604))
		end

		gCoinNum = AccountManager:getAccountData():getMiniCoin()
		getglobal("DeveloperStoreSkuFrameMyMiniCoinFont"):SetText(gCoinNum)
	end

	if gPointNum ~= AccountManager:getAccountData():getADPoint() then
		gPointNum = AccountManager:getAccountData():getADPoint() or 0
		if gPointNum < 0 then gPointNum = 0 end
		getglobal("DeveloperStoreSkuFrameMyMiniPointFont"):SetText(gPointNum)
	end
end

function DeveloperStoreSkuFrame_HandleEvent()
	if arg1 == "GIE_PAY_RESULT" then
		local eventData = GameEventQue:getCurEvent()
		local result = eventData.body.paydata.result --返回结果

		if NotEnoughCoinDataName then
			--[Desc1]成功
			if result == 1 then
				standReportEvent("6001", "PROP_DETAILS", "Accomplish", "purchase_succeed",{standby1=NotEnoughCoinDataName}) 
			else	
				standReportEvent("6001", "PROP_DETAILS", "Accomplish", "purchase_failed",{standby1=NotEnoughCoinDataName})
			end

			GetInst("DevelopStoreDataManager"):HandlePropRechargeEvent(result)

			NotEnoughCoinDataName = nil
		end
	end
end

function DeveloperStoreSkuFrameCloseBtn_OnClick()
	standReportEvent("60", "DEVELOPER_SHOP_TOP", "Close", "click")
	getglobal("DeveloperStoreSkuFrame"):Hide()
	getglobal("DeveloperStoreSkuFrameContentFrame"):Hide()
end



function DeveloperStoreOpenBeanConvertFrame_OnClick()
	standReportEvent("60", "DEVELOPER_SHOP_TOP", "MiniBeanRecharge", "click")
	OpenBeanConvertFrame();
end

function DeveloperStoreOpenCoinConvertFrame_OnClick()
	standReportEvent("60", "DEVELOPER_SHOP_TOP", "MiniCoinRecharge", "click")
	--ShopJumpTabView(7);

	if GetInst("ShopService"):IsRechargeNewOpen() then
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/ShopRecharge", "miniui/miniworld/common", "miniui/miniworld/common_comp"})
		GetInst("MiniUIManager"):OpenUI("ShopRechargeNew", "miniui/miniworld/ShopRecharge", "ShopRechargeNewAutoGen", {tabTag = "ShopRechargeNew", shopRechargeType = 2, fullScreen = { Type = 'Normal' }})
	else
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/c_Mini_Recharge", "miniui/miniworld/C_QQVIP_icon"})
    	GetInst("MiniUIManager"):OpenUI("main_Recharge","miniui/miniworld/c_Mini_Recharge","main_RechargeAutoGen")
	end
	
end

-- 检查迷你点是否显示
function DeveloperStoreSkuFrameCheckMiniPoint(bool)
	if bool and isShowPoint == false then
		isShowPoint = true
		getglobal("DeveloperStoreSkuFrameMyMiniPoint"):Show()
		-- getglobal("DeveloperStoreSkuFrameMyMiniBean"):SetPoint("left","ShopTopPanel","topleft",470,30)
		getglobal("DeveloperStoreSkuFrameMyMiniCoin"):SetPoint("left","DeveloperStoreSkuFrameMyMiniBean","right",32,0)
		getglobal("DeveloperStoreSkuFrameMyMiniBean"):SetSize(160,32)
		getglobal("DeveloperStoreSkuFrameMyMiniCoin"):SetSize(160,32)
		getglobal("DeveloperStoreSkuFrameMyMiniBeanAddIcon"):SetSize(38,39)
		getglobal("DeveloperStoreSkuFrameMyMiniCoinAddIcon"):SetSize(38,39)
		getglobal("DeveloperStoreSkuFrameMyMiniBeanAddIcon"):SetTextureHuiresXml("ui/mobile/texture2/minilobby.xml")
		getglobal("DeveloperStoreSkuFrameMyMiniBeanAddIcon"):SetTexUV("icon_add_btn_money_s.png")
		getglobal("DeveloperStoreSkuFrameMyMiniCoinAddIcon"):SetTextureHuiresXml("ui/mobile/texture2/minilobby.xml")
		getglobal("DeveloperStoreSkuFrameMyMiniCoinAddIcon"):SetTexUV("icon_add_btn_money_s.png")
		getglobal("DeveloperStoreSkuFrameMyMiniBeanFont"):SetFontSize(18)
		getglobal("DeveloperStoreSkuFrameMyMiniCoinFont"):SetFontSize(18)
	elseif not bool and isShowPoint == true then
		isShowPoint = false
		getglobal("DeveloperStoreSkuFrameMyMiniPoint"):Hide()
		getglobal("DeveloperStoreSkuFrameMyMiniCoin"):SetPoint("left","DeveloperStoreSkuFrameMyMiniBean","right",80,0)
		getglobal("DeveloperStoreSkuFrameMyMiniBean"):SetSize(203,36)
		getglobal("DeveloperStoreSkuFrameMyMiniCoin"):SetSize(203,36)
		getglobal("DeveloperStoreSkuFrameMyMiniBeanAddIcon"):SetSize(40,43)
		getglobal("DeveloperStoreSkuFrameMyMiniCoinAddIcon"):SetSize(40,43)
		getglobal("DeveloperStoreSkuFrameMyMiniBeanAddIcon"):SetTextureHuiresXml("ui/mobile/texture2/shop.xml")
		getglobal("DeveloperStoreSkuFrameMyMiniBeanAddIcon"):SetTexUV("icon_add_btn_money.png")
		getglobal("DeveloperStoreSkuFrameMyMiniCoinAddIcon"):SetTextureHuiresXml("ui/mobile/texture2/shop.xml")
		getglobal("DeveloperStoreSkuFrameMyMiniCoinAddIcon"):SetTexUV("icon_add_btn_money.png")
		getglobal("DeveloperStoreSkuFrameMyMiniBeanFont"):SetFontSize(20)
		getglobal("DeveloperStoreSkuFrameMyMiniCoinFont"):SetFontSize(20)	
	end
end

--仓库按钮
function DeveloperStoreSkuFrameStashBtn_OnClick()
	standReportEvent("60", "DEVELOPER_SHOP_CONTAINER", "Warehouse", "click")
	Other_OnClick()
	DeveloperStoreSetBtnChecked();

	local checked = getglobal("DeveloperStoreSkuFrameStashBtnChecked")
	if checked:IsShown() or gSelectPropType == 0 then return end

	getglobal("DeveloperStoreSkuFramePropTypeList"):Hide();

	gSelectPropType = 0
	gDeveloperStoreType = 3

	LoadDeveloperStashPropList()
	buildStoreSkuList()
	manageStoreType()
end

-- type: 1、编辑模式下的商店，2、玩法模式下的商店，3、仓库
-- groupData筛选显示标签的数据
-- shopName 商店的名字
gDeveloperStoreType = 1
function openDeveloperStore(storetype, groupData, shopName)
	if ClientCurGame and (not ClientCurGame:isInGame()) then
		return
	end	
	GetInst("NewDeveloperStoreInterface"):InitInfo(function ()
		gDeveloperStoreType = storetype
		gSelectPropType = 1
		if storetype == 1 then
			GetInst("DevelopStoreDataManager"):SetStoreGroupTypeMapByScreen(nil)
			GetInst("DevelopStoreDataManager"):SetStoreShopName(nil)
			if getglobal("DeveloperStoreMapPurchaseFrame"):IsShown() then return end
			getglobal("DeveloperStoreMapPurchaseFrame"):Show()
		else
			-- groupData = {{GroupID=2,Pos=2},{GroupID=3,Pos=3}} -- test
			GetInst("DevelopStoreDataManager"):SetStoreGroupTypeMapByScreen(groupData)
			GetInst("DevelopStoreDataManager"):SetStoreShopName(shopName)
			if getglobal("DeveloperStoreSkuFrame"):IsShown() then return end
		
			getglobal("DeveloperStoreSkuFrame"):Show()
		end
	end
	)
end

function manageStoreType()
	local checked = getglobal("DeveloperStoreSkuFrameStashBtnChecked")
	local desc = getglobal("DeveloperStoreSkuFrameDescTips")
	local desc1 = getglobal("DeveloperStoreSkuFrameDescTips1")
	local desc2 = getglobal("DeveloperStoreSkuFrameDescTips2")
	local namelab = getglobal("DeveloperStoreSkuFrameStashBtnName")
	if gDeveloperStoreType == 3 then
		checked:Show()
		desc:Show()
		desc1:Hide()
		desc2:Hide()
		namelab:SetTextColor(54,53,53)
	else
		checked:Hide()
		desc:Hide()
		desc1:Show()
		desc2:Show()
		namelab:SetTextColor(55,52,51)
	end
end

function DeveloperStoreSkuFrameList_tableCellAtIndex(tableview, idx)
	local listname = tableview:GetName()

	local tmpname = "DeveloperStoreItemTemplate"
	local typename = "Frame"
	if gDeveloperStoreType == 3 then
		tmpname = "DeveloperItemTemplate"
		typename = "Button"
	end
	local cell, uiidx = tableview:dequeueCell(0, tmpname)
	if not cell then
		cell = UIFrameMgr:CreateFrameByTemplate(typename, listname .. "Item" .. uiidx, tmpname, listname)
	else
		cell:Show()
	end

	local index = idx+1
	cell:SetClientUserData(0, index)

	if gDeveloperStoreType == 2 then
		local DeveloperPropList = GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
		setStoreSkuInfo(cell:GetName(), DeveloperPropList[index])


		--当前选中的商品类型
		local GroupID = gStoreGroupTypList[gSelectPropType]
		if not PropItemsStandReportState[GroupID] then
			if ItemGroupID2StandReportKeyForContainer[GroupID] then
				PropItemsStandReportState[GroupID]={}
			end
		end
		if PropItemsStandReportState[GroupID] then
			--没上报过的才上报，已经上报了则不重新上报
			if not PropItemsStandReportState[GroupID][index] then
				if ItemGroupID2StandReportKeyForContainer[GroupID] then
					local Item = DeveloperPropList[index]
					local slot=index
					--通行证standby1为1，普通商品为2
					local standby1=(Item.ItemID == ITEM_PASSPORT and 1 or 2)
					local standby2
					--standby2-1：迷你币商品 2：迷你豆商品 3：迷你点商品 4：播放广告 5：迷你点+迷你币"
					if Item.CostType == g_DeveloperConfig.Developer.CurrencyType.Money then
						standby2=1
					elseif Item.CostType == g_DeveloperConfig.Developer.CurrencyType.Coin then
						standby2=2
					elseif Item.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then
						standby2=3
					elseif Item.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
						standby2=5
					else
						if Item.ADExchange==1 then
							standby2=4
						end
					end

					standReportEvent("60", ItemGroupID2StandReportKeyForContainer[GroupID], "Props", "view",{slot=slot,standby1=standby1,standby2=standby2})

					--view的时候没有档位
					standReportEvent("6001", "PROP_DETAILS", "Pulluprecharge", "view", {standby1=Item.ItemID, standby2=""})

					PropItemsStandReportState[GroupID][index]=true
				end
			end
		end
		
	else
		setStashStoreInfo(cell:GetName(), DeveloperStashPropList[index])
	end

	return cell
end

function DeveloperStoreSkuFrameList_numberOfCellsInTableView(tableview)
	if gDeveloperStoreType == 2 then
		return #GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
	end

	return #DeveloperStashPropList
end

function DeveloperStoreSkuFrameList_tableCellSizeForIndex(tableview, idx)
	local colidx = math.mod(idx, 2)

	return 13+498*colidx, 10, 487, 133
end

function DeveloperStoreSkuFrameList_tableCellWillRecycle(tableview, cell)
	if cell then cell:Hide() end
end

--创建列表
function buildStoreSkuList()
	local listview = getglobal("DeveloperStoreSkuFrameList")
	if not listview:IsShown() then
		listview:Show()
		getglobal("DeveloperStoreSkuFrameHead"):Hide()
		getglobal("DeveloperStoreSkuFrameTxt"):Hide()
		getglobal("DeveloperStoreSkuFrameStashBtn"):Enable()
	end

	listview:initData(1012, 465, 3, 2)

	if gDeveloperStoreType == 3 and #DeveloperStashPropList == 0 then
		getglobal("DeveloperStoreSkuFrameHead"):Show()
		getglobal("DeveloperStoreSkuFrameNoItemTips"):Show()
	else
		getglobal("DeveloperStoreSkuFrameHead"):Hide()
		getglobal("DeveloperStoreSkuFrameNoItemTips"):Hide()
	end
end

--设置玩法模式下商店列表Item信息
function setStoreSkuInfo(cellname, data)
	local bkg = getglobal(cellname.."Bkg");
	local icon = getglobal(cellname.."Icon");
	local rightNum = getglobal(cellname.."RightNum");
	local name = getglobal(cellname.."Name");
	local currencyIcon = getglobal(cellname.."CurrencyIcon");
	local cost = getglobal(cellname.."Cost");
	local desc = getglobal(cellname.."Desc");
	local tag = getglobal(cellname.."Tag");
	local tagName = getglobal(cellname.."TagName");
	--local discountIcon = getglobal(cellname.."DiscountIcon");
	local discountCost = getglobal(cellname.."DiscountCost");
	local discountLine = getglobal(cellname.."DiscountLine");
	local miniPointIcon = getglobal(cellname.."MiniPointIcon");
	local miniPoint = getglobal(cellname.."MiniPoint");
	local swapBkg = getglobal(cellname.."SwapBkg")
	local shopMove = getglobal(cellname.."ShopMove")
	local hideIcon = getglobal(cellname.."HideIcon")
	local actDesc = getglobal(cellname.."ActDesc")

	icon:Show();
	rightNum:Show();
	name:Show();
	currencyIcon:Show();
	cost:Show();
	desc:Show();
	tag:Show();
	tagName:Show();
	--discountIcon:Hide();
	discountCost:Hide();
	discountLine:Hide();
	miniPointIcon:Hide();
	miniPoint:Hide();
	swapBkg:Hide();
	shopMove:Hide();
	hideIcon:Hide()
	actDesc:Hide()

	if not data then return end
	local itemDef = ModEditorMgr:getItemDefById(data.ItemID) or ModEditorMgr:getBlockItemDefById(data.ItemID) or ItemDefCsv:get(data.ItemID)
	if itemDef ==nil then
		SetItemIcon(icon, 0);
		name:SetText(GetS(23002));
		desc:SetText(GetS(23002), 228, 218, 207);
	else
		SetItemIcon(icon, data.ItemID);
		name:SetText(itemDef.Name);
		desc:SetText(data.Desc, 228, 218, 207);

		--活动信息
		local actDescStr = ""
		if data.Tag == g_DeveloperConfig.Developer.TagType.Timelimit then
			--开启了限售
			if data.LimitTimeSaleNum and data.LimitTimeSaleNum > 0 then
				local mapId = G_GetFromMapid()
				local stock = GetInst("DevelopStoreDataManager"):GetStoreSkuItemStock(mapId, data.ItemID)

				actDescStr = string.format("%s#cFFE326%s#n%s", GetS(23191),stock,GetS(23190))
			end
		end

		if data.LimitBuyNum and data.LimitBuyNum > 0 then
			actDescStr = actDescStr .. string.format(" %s#cFFE326%s#n%s", GetS(23189), data.LimitBuyNum, GetS(23190))--string.format(" 每人限购#cFFE326%s#n件", data.LimitBuyNum)
		end

		--活动信息
		if actDescStr ~= "" then
			actDesc:Show()
			actDesc:SetText(actDescStr, 255, 255, 255)
		end
	end
	
	rightNum:SetText("×1");
	cost:SetText(data.CostNum);
	if data.CostType == g_DeveloperConfig.Developer.CurrencyType.Money then
		currencyIcon:SetTextureHuiresXml("ui/mobile/texture2/common.xml");
		currencyIcon:SetTexUV("icon_coin");
		--discountIcon:SetTextureHuiresXml("ui/mobile/texture2/common.xml");
		--discountIcon:SetTexUV("icon_coin");
	elseif data.CostType == g_DeveloperConfig.Developer.CurrencyType.Coin then
		currencyIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
		currencyIcon:SetTexUV("icon_bean");
		--discountIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
		--discountIcon:SetTexUV("icon_bean");
	elseif data.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPoint then
		currencyIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
		currencyIcon:SetTexUV("icon10009");
		--discountIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
		--discountIcon:SetTexUV("icon10009");
		cost:SetText(data.MiniPoint);
	elseif data.CostType == g_DeveloperConfig.Developer.CurrencyType.MiniPointAndMiniCoin then
		currencyIcon:SetTextureHuiresXml("ui/mobile/texture2/common.xml");
		currencyIcon:SetTexUV("icon_coin");
		--discountIcon:SetTextureHuiresXml("ui/mobile/texture2/common.xml");
		--discountIcon:SetTexUV("icon_coin");
		miniPointIcon:Show();
		miniPoint:Show();
		miniPoint:SetText(data.MiniPoint);
	end

	currencyIcon:SetPoint("right",cellname.."Cost","left",-4,2)
	cost:SetPoint("bottomright",cellname,"bottomright",-5,-12)
	
	if data.Tag > g_DeveloperConfig.Developer.TagType.None then
		tag:Show();
		if data.Tag == g_DeveloperConfig.Developer.TagType.Hot then
			tagName:SetText(GetS(21670));
			tag:SetTextureHuiresXml("ui/mobile/texture2/shop.xml");
			tag:SetTexUV("label_shop_set_hot");
		elseif data.Tag == g_DeveloperConfig.Developer.TagType.New then
			tagName:SetText(GetS(21671));
			tag:SetTextureHuiresXml("ui/mobile/texture2/shop.xml");
	    	tag:SetTexUV("label_shop_set_new");
	    elseif data.Tag == g_DeveloperConfig.Developer.TagType.Recommend then
	    	tagName:SetText(GetS(21629));
			tag:SetTextureHuiresXml("ui/mobile/texture2/shop.xml");
	    	tag:SetTexUV("label_shop_set_commend");
	    elseif data.Tag == g_DeveloperConfig.Developer.TagType.Popular then
	    	tagName:SetText(GetS(21630));
			tag:SetTextureHuiresXml("ui/mobile/texture2/shop.xml");
	    	tag:SetTexUV("label_shop_set_rage");
		elseif data.Tag == g_DeveloperConfig.Developer.TagType.Timelimit then --限时
			data.PropCurTime = data.LimitEnd - utils.ts2day(getServerNow())
			local str = ""
			if data.PropCurTime < 0 then
				data.PropCurTime = 0
				str = GetS(23185)--"限时售卖结束"
			else
				str = GetS(23186,data.PropCurTime)
			end
			tagName:SetText(str);
			tag:SetTextureHuiresXml("ui/mobile/texture2/shop.xml");
			tag:SetTexUV("label_shop_set_time");
		elseif data.Tag == g_DeveloperConfig.Developer.TagType.Discount then --折扣
			if data.LimitStart ~= data.LimitEnd then
				data.PropCurTime = data.LimitEnd - utils.ts2day(getServerNow())
				if data.PropCurTime > 0 then
					local str = GetS(23188, data.PropCurTime)
					--discountIcon:Show();
					discountCost:Show();
					discountLine:Show();
					--discountIcon:SetGray(true)
					discountCost:SetText(data.CostNum);
					cost:SetText(data.DiscountCostNum);
					-- currencyIcon:SetPoint("right",cellname.."Cost","left",-4,0)
					-- cost:SetPoint("bottomright",cellname,"bottomright",-16,-36)
					tagName:SetText(str);

					local discountCostWidth = discountCost:GetTextExtentWidth(data.CostNum)
					discountLine:SetWidth(discountCostWidth + 10)

					discountCost:SetPoint("bottomright", cellname, "bottomright", -52, -14)
					discountLine:SetPoint("bottomright", cellname, "bottomright", -45, -22)

					currencyIcon:SetPoint("bottomright", cellname, "bottomright", -discountCostWidth-58, -10)
				else
					tagName:SetText("")
					tag:Hide();
				end
			else
				tagName:SetText(GetS(23188));
			end
			tag:SetTextureHuiresXml("ui/mobile/texture2/shop.xml");
	    	tag:SetTexUV("label_shop_set_sale");
		end				
	else
		tag:Hide();
		tagName:SetText("");
	end
end

--设置仓库列表Item信息
function setStashStoreInfo(cellname, data)
	local icon = getglobal(cellname.."Icon");
	local num = getglobal(cellname.."Num");
	local name = getglobal(cellname.."Name");
	local desc = getglobal(cellname.."Desc");
	local chip = getglobal(cellname.."Chip");
	local redTag = getglobal(cellname.."RedTag");

	icon:Show();
	num:Show();
	name:Show();
	desc:Show();
	chip:Hide()
	redTag:Hide()
	if not data then return end

	local id = data.ItemID
	local itemDef = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);
	if itemDef == nil then
		name:SetText(GetS(23002));
		desc:SetText(GetS(23002), 101, 116, 118);
		SetItemIcon(icon, 0);
	else
		name:SetText(itemDef.Name);
		if itemDef.Chip == 1 then
			chip:Show();
		end
		desc:SetText(itemDef.Desc, 101, 116, 118);
		SetItemIcon(icon, id);
	end
	num:SetText("×"..data.ItemNum);
end
-----------------------------玩法模式改版(包括商店和仓库) end------------------------------------

----------------------------PropTypeTipsFrame start---------------------------------
local selectTypeIdx = 0
--打开分类操作界面
function openPropTypeTips(index)
	local tipsFrame = getglobal("PropTypeTipsFrame")
	if selectTypeIdx == index then
		tipsFrame:Hide()
		return
	end

	local listview = getglobal("DeveloperStoreMapPurchaseFramePropTypeList")
	local cell = listview:cellAtIndex(index-1)
	if not cell then return end

	selectTypeIdx = index
	if not tipsFrame:IsShown() then
		tipsFrame:Show()
	end
	getglobal("PropTypeTipsFrameOperate"):SetPoint("topleft", cell:GetName(), "right", 12, -30)
	listview:setDealMsg(false)
	getglobal("DeveloperStoreMapPurchaseFramePropBox"):setDealMsg(false)
end

function PropTypeTipsFrame_OnShow()
	local GroupID = gStoreGroupTypList[selectTypeIdx]
	if not GroupID then return end

	local reNameBtn = getglobal("PropTypeTipsFrameOperateReNameBtn")
	local deleteBtn = getglobal("PropTypeTipsFrameOperateDeleteBtn")
	local exchangeRangeBtn = getglobal("PropTypeTipsFrameOperateExchangeRangeBtn")
	--if GroupID > 10 then
		reNameBtn:Show()
		deleteBtn:Show()
		if  #gStoreGroupTypList >2 then
			exchangeRangeBtn:SetPoint("top", "PropTypeTipsFrameOperateBkg", "top", 0, 120)
			exchangeRangeBtn:Show()
		else
			exchangeRangeBtn:Hide()
		end
	--else
	--	reNameBtn:Hide()
	--	deleteBtn:Hide()
	--	exchangeRangeBtn:SetPoint("top", "PropTypeTipsFrameOperateBkg", "top", 0, 0)
	--end
end

function PropTypeTipsFrame_OnHide()
	local listview = getglobal("DeveloperStoreMapPurchaseFramePropTypeList")
	listview:setDealMsg(true)
	getglobal("DeveloperStoreMapPurchaseFramePropBox"):setDealMsg(true)
	selectTypeIdx = 0
end

--重命名
function PropTypeTipsFrameReNameBtn_OnClick()
	OpenPropTypeConfirmFrame({type=2, Pos=selectTypeIdx})
	getglobal("PropTypeTipsFrame"):Hide()
end

--删除
function PropTypeTipsFrameDeleteBtn_OnClick()
	OpenPropTypeConfirmFrame({type=3, Pos=selectTypeIdx})
	getglobal("PropTypeTipsFrame"):Hide()
end

--调序
function PropTypeTipsFrameExchangeRangeBtn_OnClick()
	gSwapTypeInfo = {}
	gSwapTypeInfo.selectIdx = selectTypeIdx
	gSwapTypeInfo.bSwap = true

	getglobal("PropTypeTipsFrame"):Hide()
	buildPropTypeList(1, false, true)
end

function PropTypeTipsFrameBtn_OnClick()
	getglobal("PropTypeTipsFrame"):Hide()
end
----------------------------PropTypeTipsFrame end---------------------------------

--打开开发者商品[Desc5]弹框
function OpenDevGoodsBuyDialog(itemid, customDesc, msg)
	-- ShowGameTips("开发者商店商品[Desc5]弹框:" .. customDesc, 3);
	local param = {disableOperateUI = true, itemId = itemid, recommend = customDesc, fromid = msg};

	threadpool:work(function(param)
			--threadpool:wait(0.1)
			local offsetY = 12;
			local durationTime = 0.3;
			-- TriggerAdInMap 和 TopPurchaseInMap 不同时显示
			if GetInst("MiniUIManager"):IsShown("TriggerAdInMapAutoGen") then
				GetInst("MiniUIManager"):CloseUI("TriggerAdInMapAutoGen")
			end
			-- if IsUIFrameShown("TriggerAdInMap") then
			-- 	GetInst("UIManager"):GetCtrl("TriggerAdInMap"):CloseBtnClicked()
			-- end
			--GetInst("UIManager"):Close("TopPurchaseInMap");
			--GetInst("UIManager"):FadeIn("TopPurchaseInMap", param, durationTime, offsetY);
			--if GetInst("MiniUIManager"):IsShown("TopPurchaseInMapAutoGen") then
			--	GetInst("MiniUIManager"):CloseUI("TopPurchaseInMapAutoGen")
			--end
			if GetInst("MiniUIManager"):GetCtrl("TopPurchaseInMap") then
				GetInst("MiniUIManager"):GetCtrl("TopPurchaseInMap"):ResetGoodInfo(param)
			else
				SceneEditorUIInterface:OpenUI("TopPurchaseInMap", "miniui/miniworld/ugc_topPurchaseInMap", "TopPurchaseInMapAutoGen", param)
			end

			-- 处理第一次可能重叠的情况(无效代码)
			-- if IsUIFrameShown("TopPurchaseInMap") and IsUIFrameShown("TriggerAdInMap") then
			-- 	GetInst("UIManager"):GetCtrl("TriggerAdInMap"):CloseBtnClicked()
			-- end
		end, param
	)
end

function isGetDeveloperPropList(lastFromOwid)
	if lastFromOwid and lastFromOwid == DeveloperFromOwid then
		local DeveloperPropList = GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
		if DeveloperPropList and #DeveloperPropList > 0 then
			return true
		end
	end

	return false
end


function GetDeveloperStorePropByItemID(itemID)
	local DeveloperPropList = GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
	for i, v in pairs(DeveloperPropList) do
		if v.ItemID == itemID then
			return i, v
		end
	end

	return 0, nil
end

function GetDeveloperStashPropNumByItemID(itemID)
	for i, v in pairs(DeveloperStashPropList) do
		if v.ItemID == itemID then
			return v.ItemNum, i
		end
	end

	return 0, 0
end

--事件上报代理，推荐页的上报都走这,方便统一管理(埋点)
function DeveloperStore_StandReportEvent(cID,oID,event,eventTb)
	local sceneID = "";--统一ID
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
		sceneID = "1003";
	else--客机
		sceneID = "1001";
	end
	eventTb = eventTb or {}
	if not eventTb.cid then
		eventTb.cid = tostring(G_GetFromMapid())
	end
	standReportEvent(sceneID,cID,oID,event,eventTb)
end

--hx 获取路径
function DeveloperStoreGetCurDir(owid)
    owid = owid or DeveloperStoreGetCurOwid()
    if not owid then
        return nil
    end
    if AccountManager and AccountManager.getSpecialType and 1 == AccountManager:getSpecialType() then
		return 'data/homegarden/homegarden_map/w' .. tostring(owid) .. '/'
	end
	return 'data/w' .. tostring(owid) .. '/'
end

--hx 获取当前地图id
function DeveloperStoreGetCurOwid()
	local wdesc = AccountManager:getCurWorldDesc()
	if wdesc then
		return wdesc.worldid
	end
end

function DeveloperStoreGetPath(owid) 
	local dir= DeveloperStoreGetCurDir(owid);
	if dir then
		return dir.. "storeInfo"
	else
		return nil
	end
end

-- hx 判断地图是否上传
function DeveloperStoreMapIsUpload(mapid)
	local worldDesc = AccountManager:findWorldDesc(mapid)
	if worldDesc then
		local worldopen = worldDesc.open
		if worldopen ~= 0 then --判断本地数据是否已经上传
			return true
		elseif worldDesc.realowneruin and worldDesc.realowneruin ~= AccountManager:getUin() then --创作者不是自己的都重远端拉数据
			return true
		end
	else
		if  AccountManager:getMultiPlayer() > 0 and not IsRoomOwner()  then --客机地图必然上传
			return true;
		end
	end
	return false
end

--hx 上传成功后设置数据
function DeveloperStoreSetting(ouruin,owid)
	threadpool:work(function()
		local isUpload =DeveloperStoreMapIsUpload(owid)
	   if isUpload then
		   local worldDesc = AccountManager:findWorldDesc(owid)
		   if worldDesc and worldDesc.realowneruin and worldDesc.realowneruin ~= AccountManager:getUin() then
			   --不是自己地图不用请求
			   return;
		   end
		   local mapId = worldDesc.fromowid;
		   local authorUin = getFromOwid(worldDesc.fromowid);
		   if worldDesc.fromowid == 0 then
			   mapId = worldDesc.worldid;
			   authorUin = AccountManager:getUin()
		   end
		   print("hx DeveloperStoreSetting")
		   -- local code, list = AccountManager:dev_mapstore_get_itemlist(ouruin, mapId, false)
		   local code, list = GetInst("DevelopStoreDataManager"):SyncGetMapStoreItemList(ouruin, mapId, false)
		   if code == ErrorCode.OK then
			   if not list or #list == 0 then
				   local path =DeveloperStoreGetPath(owid)
				   if path then
					   if  gFunc_isFileExist(path) then
						   local readtype,data = DeveloperStoreRead(owid);
						   if readtype then
							   local groupItems=data["Groups"];
							   local skuItems=data["Sku"];
							   if groupItems and #groupItems >0 then
								   
							   else
								   groupItems = {};
								   local StoreGroupType = {}
								   StoreGroupType.GroupID = 1
								   StoreGroupType.Pos = 1
								   StoreGroupType.GroupName = ItemGroupID2Name[1]
								   table.insert(groupItems, StoreGroupType)
							   end
							   local code = AccountManager:dev_mapstore_set_itemgroup_list(ouruin, mapId, groupItems)
							   if code ~= ErrorCode.OK then
								   print("hx upload   DeveloperStore  group err")
							   end
							   if skuItems and #skuItems >0 then
								   -- local code = AccountManager:dev_mapstore_set_iteminfo_list(ouruin, mapId, skuItems)
								   local code = GetInst("DevelopStoreDataManager"):SyncSetMapStoreItemList(ouruin, mapId, skuItems)
								   if code ~= ErrorCode.OK then
									   print("hx upload   DeveloperStore  skuItems err")
								   end
							   end
							   GetInst("NewDeveloperStoreInterface"):ReadUpload(owid,mapId)
							   return;
						   end
					   end
				   end
				   
			   end
		   end
	   end
	end)
end


--hx 读取账号服或者本地文件的sku数据
function DeveloperStoreGetItemlist(authorUin,mapId)
	local isUpload = DeveloperStoreMapIsUpload(mapId)
	local code = -1;
	local list ={};
	if isUpload then
		-- code, list = AccountManager:dev_mapstore_get_itemlist(authorUin, mapId, false)
		code, list = GetInst("DevelopStoreDataManager"):SyncGetMapStoreItemList(authorUin, mapId, false)
		if code == ErrorCode.OK then
			print("hx skudata ",list)
			return  list;
		end
	else
		local path =DeveloperStoreGetPath(mapId)
		if path then
			if  gFunc_isFileExist(path) then
				local readtype,data = DeveloperStoreRead(mapId);
				if readtype then
					list=data["Sku"];
					if list then
						return list;
					end
				end
			end
		end
	end
	return nil;
end

--hx 读取本地或者账号服中groups数据
function DeveloperStoreGetItemgrouplist(authorUin,mapId)
	local isUpload = DeveloperStoreMapIsUpload(mapId)
	if isUpload then
		local code, grouplist =AccountManager:dev_mapstore_get_itemgroup_list(authorUin, mapId, false)
		if code == ErrorCode.OK and type(grouplist) == 'table' then
			local needaddNum = false;
			if #grouplist == 0 then
				local skulist 
				-- code, skulist = AccountManager:dev_mapstore_get_itemlist(authorUin, mapId, false)
				local code, skulist = GetInst("DevelopStoreDataManager"):SyncGetMapStoreItemList(authorUin, mapId, false)
				if code == ErrorCode.OK then
					if #skulist > 0 then
						needaddNum = true;
					end 
				end
			end

			return true,  grouplist, needaddNum
		end 
	else
		local list={}
		local path =DeveloperStoreGetPath(mapId)
		if path then
			if  gFunc_isFileExist(path) then
				local readtype,data = DeveloperStoreRead(mapId);
				if readtype then
					list=data["Groups"];
					if list then
						return true, list, false;
					end
				end
			end
		end
	end
	return false, nil, false
end

-- hx 保存本地和账号服的sku和Group数据
function DeveloperStoreSetItemlistAndGroup(authorUin,mapId,skudata,groupdata)
	local isUpload = DeveloperStoreMapIsUpload(mapId)
	if isUpload then
		if groupdata and #groupdata > 0 then
			local code = AccountManager:dev_mapstore_set_itemgroup_list(authorUin,mapId,groupdata)
			if code ~= ErrorCode.OK then
				print("hx DeveloperStoreSetItemlist groupdata err")
			end
		end
		if skudata and #skudata >0 then
			-- local code = AccountManager:dev_mapstore_set_iteminfo_list(authorUin, mapId, skudata)
			local code = GetInst("DevelopStoreDataManager"):SyncSetMapStoreItemList(authorUin, mapId, skudata)
			if code ~= ErrorCode.OK then
				print("hx DeveloperStoreSetItemlist  skuItems err")
			end
		end
	else
		if skudata and #skudata > 0 and groupdata and #groupdata > 0 then
			local ldata={};
			ldata["Sku"]=skudata;
			ldata["Groups"]=groupdata;
			DeveloperStoreSave(ldata,mapId)
		end
	end
end

-- hx 保存本地或者账号服的sku 数据
function DeveloperStoreSetItemlist(authorUin,mapId,skudata)
	local isUpload= DeveloperStoreMapIsUpload(mapId)
	if isUpload then
		if skudata and #skudata >0 then
			-- local code = AccountManager:dev_mapstore_set_iteminfo_list(authorUin, mapId, skudata)
			local code = GetInst("DevelopStoreDataManager"):SyncSetMapStoreItemList(authorUin, mapId, skudata)
			if code ~= ErrorCode.OK then
				print("hx DeveloperStoreSetItemlist  skuItems err")
			else
				return true;
			end
		end
	else
		local path =DeveloperStoreGetPath(mapId)
		if path then
			if  gFunc_isFileExist(path) then
				local readtype,data = DeveloperStoreRead(mapId);
				if readtype then
					data["Sku"]=skudata;
					DeveloperStoreSave(data,mapId)
					return true;
				end
			end
			local ldata={};
			ldata["Sku"]=skudata
			DeveloperStoreSave(ldata,mapId)
			return true;
		end
	end
	return false;
end

-- hx 保存本地或者账号服groups数据
function DeveloperStoreSetGroups(authorUin,mapId,groupdata)
	local isUpload= DeveloperStoreMapIsUpload(mapId)
	if isUpload then
		if groupdata and #groupdata >0 then
			local code = AccountManager:dev_mapstore_set_itemgroup_list(authorUin, mapId, {groupdata})
			if code ~= ErrorCode.OK then
				print("hx DeveloperStoreSetItemlist  skuItems err")
			else
				return true
			end
		end
	else
		local path =DeveloperStoreGetPath(mapId)
		if path then
			if  gFunc_isFileExist(path) then
				local readtype,data = DeveloperStoreRead(mapId);
				if readtype then
					data["Groups"]=groupdata;
					return DeveloperStoreSave(data,mapId)
				end
			end
			local ldata={};
			ldata["Groups"]=groupdata
			return DeveloperStoreSave(ldata,mapId)
		end
	end
	return false;
end
-- hx Groups重新命名
function DeveloperStoreGroupsRame(authorUin,mapId,groupdata)
	local isUpload= DeveloperStoreMapIsUpload(mapId)
	if isUpload then
		if groupdata then
			local code = AccountManager:dev_mapstore_set_itemgroup_list(authorUin, mapId, {groupdata})
			if code ~= ErrorCode.OK then
				print("hx DeveloperStoreSetItemlist  skuItems err")
			else
				return true
			end
		end
	else
		local path =DeveloperStoreGetPath(mapId)
		if path then
			if  gFunc_isFileExist(path) then
				local readtype,data = DeveloperStoreRead(mapId);
				if readtype then
					local groups= data["Groups"];
					if groups then
						for k,v in pairs(groups) do
							if v.GroupID == groupdata.GroupID then
								v.GroupName=groupdata.GroupName
							end
						end
						data["Groups"]=groups;
						return DeveloperStoreSave(data,mapId)
					end
					
				end
			end
		end
	end
	return false;
end

--hx 添加一个item
function DeveloperStoreAdditemgroup(authorUin,mapId,StoreGroupType)

	if #DeleteGruopTemp ~= 0 then
		cancelLockStateOfMoveItem()
		for k,v in pairs(DeleteGruopTemp) do
			DeveloperStoreRmitemgroup(AccountManager:getUin(),mapId,v ,true)
		end
		DeleteGruopTemp = {}
	end

	local DeleteDeveloperPropListTemp = GetInst("DevelopStoreDataManager"):GetDeleteDeveloperPropListTemp()
	if #DeleteDeveloperPropListTemp ~= 0 then
		DeveloperStoreRmitemlist(AccountManager:getUin(),mapId,DeleteDeveloperPropListTemp) 
		GetInst("DevelopStoreDataManager"):SetDeleteDeveloperPropListTemp({})
	end

	local isUpload= DeveloperStoreMapIsUpload(mapId)
	if isUpload then
		local code = AccountManager:dev_mapstore_add_itemgroup(authorUin, mapId, StoreGroupType)
		if code ~= ErrorCode.OK then
			print("hx DeveloperStoreAdditemgroup  group err")
		else
			return true
		end
	else
		local path =DeveloperStoreGetPath(mapId)
		if path then
			if  gFunc_isFileExist(path) then
				local readtype,data = DeveloperStoreRead(mapId);
				if readtype then
					local groups= data["Groups"];
					if groups then
						table.insert(groups, StoreGroupType)
						data["Groups"]=groups
						return DeveloperStoreSave(data,mapId)
					end 
				end
			end
		end
	end
	return false
end
-- hx swap
function DeveloperStoreswapGroups(authorUin,mapId,groupdata)
	local isUpload= DeveloperStoreMapIsUpload(mapId)
	if isUpload then
		if groupdata and #groupdata >0 then
			local code = AccountManager:dev_mapstore_set_itemgroup_list(authorUin, mapId, groupdata)
			if code ~= ErrorCode.OK then
				print("hx DeveloperStoreswapGroups  skuItems err")
			else
				return true
			end
		end
	else
		local path =DeveloperStoreGetPath(mapId)
		if path then
			if  gFunc_isFileExist(path) then
				local readtype,data = DeveloperStoreRead(mapId);
				if readtype then
					local groups= data["Groups"];
					if groups then
						print("hx groups",groups)
						local pos1,pos2=groupdata[1].Pos,groupdata[2].Pos
						if groups[pos1] and groups[pos2] then
							groups[pos1], groups[pos2] = groups[pos2], groups[pos1]
							groups[pos1].Pos=pos1
							groups[pos2].Pos=pos2
							print("hx groups2",groups)
							data["Groups"]=groups
							return DeveloperStoreSave(data,mapId)
						end
					end
				end
			end
		end
	end
	return false;
end

-- hx 移除本地或者账号服中一个id的groups
function DeveloperStoreRmitemgroup(authorUin,mapId,GroupID,IsRm)
	if IsRm then
		local isUpload= DeveloperStoreMapIsUpload(mapId)
		if isUpload then
			local code = AccountManager:dev_mapstore_rm_itemgroup(authorUin, mapId, GroupID)
			if code ~= ErrorCode.OK then
				print("hx DeveloperStoreRmitemgroup  group err")
			else
				return true;
			end
		else
			local path =DeveloperStoreGetPath(mapId)
			if path then
				if  gFunc_isFileExist(path) then
					local readtype,data = DeveloperStoreRead(mapId);
					if readtype then
						--data["Groups"]=skudata;
						local groups= data["Groups"];
						if groups then
							for k,v in pairs(groups) do
								if v.GroupID == GroupID then
									table.remove(groups, k);
									break;
								end
							end
							data["Groups"]=groups
							return DeveloperStoreSave(data,mapId)
						end 
					end
				end
			end
		end
		return false
	else
		table.insert(DeleteGruopTemp, GroupID)
		return true
	end
	
end
--if #DeleteDeveloperPropListTemp ~= 0 then
--	delete_code = AccountManager:dev_mapstore_rm_iteminfo_list(AccountManager:getUin(), tostring(mapId), DeleteDeveloperPropListTemp)
--end
--删除list
function DeveloperStoreRmitemlist(authorUin,mapId,deleteItems)
	local isUpload= DeveloperStoreMapIsUpload(mapId)
	if isUpload then
		local code = AccountManager:dev_mapstore_rm_iteminfo_list(authorUin,tostring(mapId), deleteItems)
		if code ~= ErrorCode.OK then
			print("hx DeveloperStoreRmitemlist  itemlis err")
		else
			return true;
		end
	else
		local readtype,data = DeveloperStoreRead(mapId);
		if readtype then
			local skus= data["Sku"];
			if skus then
				local indes={}
				for k,v in ipairs(deleteItems) do
					for i,val in ipairs(skus) do
						if val.ItemID == v then
							table.insert(indes,i)
						end
					end
				end
				table.sort(indes, sortNumber)
				for i=1,#indes do
					table.remove(skus, indes[i])
				end
				data["Sku"]=skus
				DeveloperStoreSave(data,mapId)
				return true;
			end
		end
	end
	return false;
end

-- hx 判断文件是否存在呢
function DeveloperStoreIsExit()
	local wid =DeveloperStoreGetCurOwid();
	local path =DeveloperStoreGetPath(wid)
	if path then
		return gFunc_isFileExist(path)
	else
		return false;
	end
end

function DeveloperStoreGetPack()
	local mp = gPackages['MessagePack'];
	if mp then
		mp.set_number("float")
		mp.set_array("without_hole")
		-- 设置打包为10进值打包,避免存档出错
		if mp.setPackerDecimal then
			mp.setPackerDecimal(mp)
			return mp
		end
	end
	return nil
end

-- hx 保存文件
function DeveloperStoreSave(tabledata,wid)
	--if gDeveloperStoreType == 2 then
	--	return false
	--end
	local filepath = DeveloperStoreGetPath(wid)
    if filepath == nil or tabledata == nil then
        return false
    end
	local ok, jsonstr = pcall(JSON.encode, JSON, tabledata)
	if ok and jsonstr then 
		local mp = DeveloperStoreGetPack();
		if mp then
			jsonstr = jsonstr and mp.pack(jsonstr)
			if xxtea then 
				local b64string = xxtea.encrypt(jsonstr, string.len(jsonstr), 'b64')
				gFunc_deleteStdioFile(filepath)
				return gFunc_writeTxtFile(filepath, b64string)
			end
		end
	end
	return false
end

-- hx 读取文件
function DeveloperStoreRead(wid)
	--if gDeveloperStoreType == 2 then
	--	return false,nil
	--else
		local filepath = DeveloperStoreGetPath(wid)
		if filepath then
    		local b64string = gFunc_readTxtFile(filepath)

	 		if xxtea  and b64string ~= "" then 
				local Str =	xxtea.decrypt(b64string, string.len(b64string), 'b64')
				local mp = DeveloperStoreGetPack();
				local jsonStr= Str
				if mp then
					jsonStr = mp.unpack(Str)
				end
				local ret, data = pcall(JSON.decode, JSON, jsonStr)
    			return ret, data
			end
		end
    	return false, nil
	--end

end

function IsDeveloperStoreAdCanShow(position_id, extraInfo, bIgnoreAdLoad)
	if IsAdUseNewLogic(position_id) then	
		local ad_info = GetInst("AdService"):GetAdInfoByPosId(position_id)
		if ad_info then
			return ad_data_new.canShow(position_id, ad_info, extraInfo, bIgnoreAdLoad)
		else
			GetInst("AdService"):GetAdInfo(position_id)
			return false
		end
	else
		return t_ad_data.canShow(position_id, extraInfo, bIgnoreAdLoad)
	end
end

--处理商店在某些情况下还能显示问题
function DealDeveloperStoreBtn()

	if not CurWorld then
		return
	end
	local ishost = (IsRoomOwner() or AccountManager:getMultiPlayer() == 0)
	local mapId = 0;
	local authorUin = 0;
	if ishost then   --单机或房主
		local wdesc = AccountManager:getCurWorldDesc();
		if wdesc then
			mapId = wdesc.fromowid;
			authorUin = getFromOwid(wdesc.fromowid);
			if wdesc.fromowid == 0 then
				mapId = wdesc.worldid;
				authorUin = AccountManager:getUin()
			end
		end
	else
		mapId = DeveloperFromOwid;
		authorUin = getFromOwid(mapId)
	end
	local skus = DeveloperStoreGetItemlist(authorUin, mapId)
	if skus and #skus>0 then
		getglobal("GongNengFrameDeveloperStoreBtn"):Show()
	
	else
		--单机编辑模式
		if AccountManager:getMultiPlayer() == 0 and CurWorld and CurWorld:isGameMakerMode() and AccountManager:getUin() == authorUin then
				getglobal("GongNengFrameDeveloperStoreBtn"):Show()
		else
			getglobal("GongNengFrameDeveloperStoreBtn"):Hide();

				GetInst("NewDeveloperStoreInterface"):InitInfo(function ()
					if GetInst("NewDeveloperStoreInterface"):VipInfoIsNull() and GetInst("NewDeveloperStoreInterface"):AdAndWelfareIsNull() then
						getglobal("GongNengFrameDeveloperStoreBtn"):Hide();
					else
						getglobal("GongNengFrameDeveloperStoreBtn"):Show()
						WolrdGameTopBtnLayout()
					end
				end)
				
				
		end
	end
	
end

--购买界面
function DeveloperStoreMapPurchaseFramePropTypeFrameBuy_OnClick()
	DeveloperStoreSetBtnChecked(true,false,false,false);
	local listview = nil

	if gDeveloperStoreType == 1 then
		DeveloperStorePropTypeTemplateBtn_OnClick()
		listview = getglobal("DeveloperStoreMapPurchaseFramePropTypeList")
		gSelectPropType = 1;
		for index = 0,#gStoreGroupTypList-1 do
			local cell = listview:cellAtIndex(index)
			if cell and cell:GetClientUserData(0) == 1 then 
				managePropTypeTab(cell:GetName().."Btn", 1)
			end
		end
	else
		getglobal("DeveloperStoreSkuFramePropTypeList"):Show();
		getglobal("DeveloperStoreSkuFrameStashBtnChecked"):Hide();
		listview = getglobal("DeveloperStoreSkuFramePropTypeList")
		local cell_name = ""
		for index = 0,#gStoreGroupTypList-1 do
			local cell = listview:cellAtIndex(index)
			if cell and cell:GetClientUserData(0) == 1 then
				cell_name = cell:GetName()
			end
		end
		DeveloperStorePropTypeBtnTemplate_OnClick(1,cell_name)
	end
end

--兑换界面
function DeveloperStoreMapPurchaseFramePropTypeFrameExchange_OnClick()
	getCtrl = function ()
		local page =  GetInst("NewDeveloperStoreInterface").pageInfo[2]
		if page and page.code then
			return page.code.ctrl
		end
		return nil
	end
	local ctrl = getCtrl();
	
	if GetInst("NewDeveloperStoreInterface"):IndexFromIsShow(2) and ctrl and ctrl:GetSelctTab() == 1 then
		return
	end

	DeveloperStoreSetBtnChecked(false,true,false,false);
	OtherButtonsChange()
	GetInst("NewDeveloperStoreInterface"):OPenFrom(2)
	ctrl = getCtrl();
	if ctrl then ctrl:SetSelctTab(1) end

	standReportEvent("6002", "PROP_ADAWARD", "AdWard", "click",{cid = G_GetFromMapid()});
end

--vip点击界面
function DeveloperStoreMapPurchaseFramePropTypeFrameVip_OnClick()
	if GetInst("NewDeveloperStoreInterface"):IndexFromIsShow(1)  then
		return
	end
	DeveloperStoreSetBtnChecked(false,false,false,true);
	OtherButtonsChange()
	GetInst("NewDeveloperStoreInterface"):OPenFrom(1) 
	SandboxLua.eventDispatcher:Emit(nil, "DEV_NUMRESH", SandboxContext():SetData_Number("fromtype", 0))
end

function OtherButtonsChange()
	local listview = nil
	if gDeveloperStoreType == 1 then
		getglobal("DeveloperStoreMapPurchaseFramePropBox"):Hide()
		listview = getglobal("DeveloperStoreMapPurchaseFramePropTypeList")
		local cell = listview:cellAtIndex(gSelectPropType-1)
		if cell then
			managePropTypeTab(cell:GetName().."Btn", 0)
		end
		
	else
		getglobal("DeveloperStoreSkuFrameList"):Hide()
		listview = getglobal("DeveloperStoreSkuFramePropTypeList")
		local checked = getglobal("DeveloperStoreSkuFrameStashBtnChecked")
		local desc = getglobal("DeveloperStoreSkuFrameDescTips")
		local desc1 = getglobal("DeveloperStoreSkuFrameDescTips1")
		local desc2 = getglobal("DeveloperStoreSkuFrameDescTips2")
		local namelab = getglobal("DeveloperStoreSkuFrameStashBtnName")
		checked:Hide()
		desc:Hide()
		desc1:Hide()
		desc2:Hide()
		namelab:SetTextColor(55,52,51)
		local cell = listview:cellAtIndex(gSelectPropType-1)
		if cell then
			managePropTypeTab(cell:GetName(), 0)
		end
	end
end

function ButtonTabChange(cellname, idex)
	local normal = getglobal(cellname.."Normal")
	local check = getglobal(cellname.."Check")

	if idex == 1 then
		normal:Hide()
		check:Show()
	else
		normal:Show()
		check:Hide()
	end
end

function Other_OnClick()
	if GetInst("NewDeveloperStoreInterface"):FromIsShow() then
		gSelectPropType = -1
		DeveloperStoreSetBtnChecked(true);
		--隐藏当前界面
		GetInst("NewDeveloperStoreInterface"):HideCurrentFrom()
		SandboxLua.eventDispatcher:Emit(nil, "DEV_NUMRESH", SandboxContext():SetData_Number("fromtype", 0) )
	end
end

function DeveloperStoreSetBtnChecked(buy,exchange,welfare,vip)
	if gDeveloperStoreType == 1 then -- 编辑模式
		if buy then
			GetInst("DevelopStoreDataManager"):SetCurShopType(GetInst("DevelopStoreDataManager"):GetShopTypeTbl().buy)
			standReportEvent("6002", "PROP_WARES", "WARES", "click", {cid = G_GetFromMapid()})
		elseif exchange then
			GetInst("DevelopStoreDataManager"):SetCurShopType(GetInst("DevelopStoreDataManager"):GetShopTypeTbl().exchange)
		elseif welfare then
			GetInst("DevelopStoreDataManager"):SetCurShopType(GetInst("DevelopStoreDataManager"):GetShopTypeTbl().welfare)
		elseif vip then
			GetInst("DevelopStoreDataManager"):SetCurShopType(GetInst("DevelopStoreDataManager"):GetShopTypeTbl().vip)
		end
		getglobal("DeveloperStoreMapPurchaseFramePropBox"):Show()
		ButtonTabChange("DeveloperStoreMapPurchaseFramePropTypeFrameBuy", buy and 1 or 0)
		ButtonTabChange("DeveloperStoreMapPurchaseFramePropTypeFrameExchange",  exchange and 1 or 0)
		ButtonTabChange("DeveloperStoreMapPurchaseFramePropTypeFrameWelfare",  welfare and 1 or 0)
		ButtonTabChange("DeveloperStoreMapPurchaseFramePropTypeFrameVip",  vip and 1 or 0)
	else
		getglobal("DeveloperStoreSkuFrameList"):Show()
		ButtonTabChange("DeveloperStoreSkuFramePropTypeFrameBuy",  buy and 1 or 0)
		ButtonTabChange("DeveloperStoreSkuFramePropTypeFrameExchange",  exchange and 1 or 0)
		ButtonTabChange("DeveloperStoreSkuFramePropTypeFrameWelfare",  welfare and 1 or 0)
		ButtonTabChange("DeveloperStoreSkuFramePropTypeFrameVip",  vip and 1 or 0)
	end
end

function DeveloperStoreMapPurchaseFramePropTypeFrameWelfare_OnClick()
	getCtrl = function ()
		local page =  GetInst("NewDeveloperStoreInterface").pageInfo[2]
		if page and page.code then
			return page.code.ctrl
		end
		return nil
	end
	local ctrl = getCtrl();
	if GetInst("NewDeveloperStoreInterface"):IndexFromIsShow(2) and ctrl and ctrl:GetSelctTab() == 2 then
		return
	end
	DeveloperStoreSetBtnChecked(false,false,true,false)
	OtherButtonsChange()
	GetInst("NewDeveloperStoreInterface"):OPenFrom(2)
	ctrl = getCtrl();
	if ctrl then ctrl:SetSelctTab(2) end
end

function DeveloperStoreDealButtonShow()
	GetInst("NewDeveloperStoreInterface"):GetShowType(gDeveloperStoreType)
	local framname ="";
	local isEdit = gDeveloperStoreType == 1
	local iswhite = GetInst("NewDeveloperStoreInterface"):GetOpenType()

	local isShowExchangebutton = GetInst("NewDeveloperStoreInterface"):CheckExchange(isEdit)
	local isShowWelfarebutton = GetInst("NewDeveloperStoreInterface"):CheckWelfare(isEdit)
	local isShowVipbutton = GetInst("NewDeveloperStoreInterface"):CheckVip(isEdit)

	if isEdit then
		framname="DeveloperStoreMapPurchaseFramePropTypeFrame"
		if iswhite then 
			isShowExchangebutton = true
			isShowWelfarebutton = true
			isShowVipbutton = true
		end
	else
		framname="DeveloperStoreSkuFramePropTypeFrame"
	end
	local anchorNodeName = framname.."Buy"
	local exchangebutton = getglobal(framname.."Exchange")
	local welfarebutton = getglobal(framname.."Welfare")
	local vipbutton = getglobal(framname.."Vip")

	exchangebutton:Hide()
	welfarebutton:Hide()
	vipbutton:Hide()

	if isShowExchangebutton then 
		exchangebutton:Show()
		exchangebutton:SetPoint("top",anchorNodeName,"top",0,72)
		anchorNodeName = framname.."Exchange"
	end

	if isShowWelfarebutton then 
		welfarebutton:Show()
		welfarebutton:SetPoint("top",anchorNodeName,"top",0,72)
		anchorNodeName = framname.."Welfare"
	end

	if isShowVipbutton then 
		vipbutton:Show()
		vipbutton:SetPoint("top",anchorNodeName,"top",0,72)
	end

	if not isEdit and GetInst("DevelopStoreDataManager"):GetStoreGroupTypeMapByScreen() then -- 在玩法模式下设置了商品标签筛选数据则隐藏其它按钮
		exchangebutton:Hide()
		welfarebutton:Hide()
		vipbutton:Hide()
	end
end

function DeveloperStoreGetSkuNum()
	local StoreSkuList = GetInst("DevelopStoreDataManager"):GetStoreSkuList()
	local skus = StoreSkuList
	if skus then
		return #skus
	else
		return 0
	end
end

function DeveloperStoreDealSubmintButton()
	local SaveDeveloperItem = getglobal("DeveloperStoreMapPurchaseFrameSaveDeveloperItem")
	local skusnum = DeveloperStoreGetSkuNum()
	local adnum = GetInst("NewDeveloperStoreInterface"):GetAdNum();
	local welfarenum = GetInst("NewDeveloperStoreInterface"):GetWelfareNum();
	local vipnum = GetInst("NewDeveloperStoreInterface"):GetVipNum();
	if skusnum > 0 or adnum > 0 or  welfarenum > 0 or  vipnum > 0 then

		SaveDeveloperItem:Show()
	else
		SaveDeveloperItem:Hide()
	end
end

function DeveloperStoreDealSubmintButtonShow()
	local SaveDeveloperItem = getglobal("DeveloperStoreMapPurchaseFrameSaveDeveloperItem")
	SaveDeveloperItem:Show()
end

function DeveloperStoreMiniPointBtn_OnClick()
	if not ClientMgr:isPC() then
		ShopJumpTabView(11)
	else
		ShowGameTips(GetS(23168))
	end
end

function ReportStoreCardPpopDetails(isClick, slot)
	if gDeveloperStoreType == 2 then -- 玩法模式
		local list = GetInst("DevelopStoreDataManager"):GetDeveloperPropList()
		local idStr = ""
		for i, v in ipairs(list) do
			local id = v.ItemID
			local def = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id)
			if def and def.Name then
				local connectStr = ""
				if i ~= #list then
					connectStr = ","
				end
				idStr = string.format("%s%d_%s%s", idStr, id, def.Name, connectStr)
			end
		end
		local GroupID =  gStoreGroupTypList[gSelectPropType]
		if not GroupID then return end
		local standby1 = idStr
		local standby2 = GroupID .. "_" .. getGroupTypeName(GroupID)
		if isClick then
			standReportEvent("6001", "PROP_DETAILS", "StoreCard", "click", {cid = G_GetFromMapid(), slot = slot, standby1 = standby1, standby2 = standby2})
		else
			standReportEvent("6001", "PROP_DETAILS", "StoreCard", "view", {cid = G_GetFromMapid(), standby1 = standby1, standby2 = standby2})
		end
	end
end

function DeveloperStoreCostTipsOnClick(frametype)
	if frametype == 1 then
		local content = getglobal("DeveloperStoreBuyItemFrameContentFrame")
		if content:IsShown() then
			content:Hide()
		else
			content:Show()
		end
	else
		local content = getglobal("DeveloperStoreSkuFrameContentFrame")
		if content:IsShown() then
			content:Hide()
		else
			content:Show()
		end
		standReportEvent("6001", "PROP_DETAILS", "Explain", "click",{cid=G_GetFromMapid()}) 
	end
end

--开发者商店福利红点
function DeveloperStoreBtn_OnShow()
	--防止多次显示导致多次请求
	local wdesc = AccountManager:getCurWorldDesc()
	if ClientCurGame and ClientCurGame:isInGame() and CurWorld and CurWorld:isGameMakerMode() and AccountManager:getMultiPlayer() == 0 
		and (wdesc and wdesc.realowneruin == AccountManager:getUin() and wdesc.worldtype ~= 9) then
		return
	end
	if not GetInst("NewDeveloperStoreInterface"):IsFristReqDeveloperStoreRedPoint() then
		GetInst("NewDeveloperStoreInterface"):SetFristReqDeveloperStoreRedPoint(true)
		getglobal("GongNengFrameDeveloperStoreBtnRedTag"):Hide()
		getglobal("DeveloperStoreSkuFramePropTypeFrameWelfareRedTag"):Hide()
		local mapId = GetMapIdAndUin()
		local isUpload = DeveloperStoreMapIsUpload(mapId)
		if isUpload then
			ReqMapLikeStateByOwid(mapId)
		end
	end
end 

--开发者地图内是否保存玩家数据
function IsOpenSavePlayerData()
	if not WorldMgr then
		return false
	end
	local gameRule = WorldMgr:getGameMakerManager()
	if gameRule then
		local state1 = gameRule:getPlayerAttrState(1) --背包道具
		local state2 = gameRule:getPlayerAttrState(2) --快捷栏道具
		local state3 = gameRule:getPlayerAttrState(4) --装备栏
		local curOpId = 0
		local val  =0
		curOpId, val = CurWorld:getRuleOptionID(GMRULE_PLAYERATTR_SAVE, curOpId, val)
		if val == 1 and state1 and state2 and state3 then --保存玩家数据开关 0 关闭 1 开启
			return true
		end
	end
	return false
end
