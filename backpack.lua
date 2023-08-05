BACK_PACK_GRID_MAX = 30;		--背包栏
EQUIP_GRID_MAX = 5;			--装备栏
BACK_PACK_GRID_EQUIP_MAX = 40;		--装备面板的背包栏
MINI_PRODUCT_GRID_MAX = 100;		--简易制作物列表栏
MINICRAFT_GRID_MAX = 7;			--简易合成栏

local getglobal = _G.getglobal;
--丢弃鼠标拾取的物品
function MousePickItem_OnHide()
	if ClientBackpack:getGridItem(MOUSE_PICKITEM_INDEX) > 0 then
		CurMainPlayer:discardItem(MOUSE_PICKITEM_INDEX, ClientBackpack:getGridNum(MOUSE_PICKITEM_INDEX));
	end
end
function MousePickItem_OnLoad()
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	MousePickItem_AddGameEvent()
end
function MousePickItem_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local paramData = context:GetParamData()
		local grid_index = paramData.gridIndex
		print("MousePickItem_AddGameEvent:",grid_index);
		if grid_index and grid_index == MOUSE_PICKITEM_INDEX then
			UpdatePickItemInfo();

			if ClientBackpack:getGridNum(MOUSE_PICKITEM_INDEX) == 0 then
				UIEndDrag("MousePickItem");
			else
				UIBeginDrag("MousePickItem", -40, -40);
			end
		end
	end)
end

function MousePickItem_OnEvent()
	local ge = GameEventQue:getCurEvent();

	if arg1 == "GE_BACKPACK_CHANGE" and ge.body.backpack.grid_index == MOUSE_PICKITEM_INDEX then
		UpdatePickItemInfo();

		if ClientBackpack:getGridNum(MOUSE_PICKITEM_INDEX) == 0 then
			UIEndDrag("MousePickItem");
		else
			UIBeginDrag("MousePickItem", -40, -40);
		end
	end
end


function BackpackFrame_OnShow()
	HideAllFrame("BackpackFrame");
	BackpackFramePackBtn_OnClick();
	local backpackFramePackBtn= getglobal("BackpackFramePackBtn");
	backpackFramePackBtn:Checked();

	if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 18 then
		HideGuideFingerFrame();
	end

	if isEducationalVersion or gIsSingleGame then
		getglobal("CreateBackpackFrameStashBtn"):Hide();
	end

	--MiniBase迷你基地隐藏仓库按钮入口
	if MiniBaseManager:isMiniBaseGame() then
		getglobal("CreateBackpackFrameStashBtn"):Hide();
	end
end

function BackpackFrameCloseBtn_OnMouseDown()
	local btnIcon = getglobal("BackpackFrameCloseBtnIcon");
	btnIcon:SetTexUV(396,226,33,33);
	btnIcon:SetSize(51,51);
end

function BackpackFrameCloseBtn_OnMouseUp()
	local btnIcon = getglobal("BackpackFrameCloseBtnIcon");
	btnIcon:SetTexUV(351,222,42,43);
	btnIcon:SetSize(66,67);
end

function BackpackFrameCloseBtn_OnClick()
	HidePackFrameAllItemBoxTexture();
	HideMakeFrameAllItemBoxTexture();
	selectBackpackGrid = -1;

	local backpackFrame = getglobal("BackpackFrame");	
	backpackFrame:Hide();
end

function BackpackFrame_OnHide()
	MakeFrame_OnHide();
--	RoleFrame_OnHide();
	PackFrame_OnHide();
	
	if not getglobal("BackpackFrame"):IsRehide() then
	  ClientCurGame:setOperateUI(false);
	end

	local taskId = AccountManager:getCurNoviceGuideTask();
	if CurWorld:getOWID() == NewbieWorldId then
		if taskId > 8 and taskId < 11 then
			HideGuideFingerFrame();
			AccountManager:setCurNoviceGuideTask(8);
			AccountManager:setNoviceGuideState("openBP", false);
			AccountManager:setNoviceGuideState("chooseBPmake", false);
			AccountManager:setNoviceGuideState("makeCT", false);
			ShowCurNoviceGuideTask();
		elseif taskId == 18 then
			ShowCurNoviceGuideTask();
		elseif taskId > 20 and taskId < 24 then
			HideGuideFingerFrame();
			AccountManager:setCurNoviceGuideTask(20);
			AccountManager:setNoviceGuideState("wearEP1", false);
			AccountManager:setNoviceGuideState("wearEP2", false);
			AccountManager:setNoviceGuideState("wearEP3", false);
			AccountManager:setNoviceGuideState("wearEP4", false);
			ShowCurNoviceGuideTask();
		elseif taskId == 24 then
			HideGuideFingerFrame();
			AccountManager:setCurNoviceGuideTask(25);
			AccountManager:setNoviceGuideState("wearEP5", true);
			ShowCurNoviceGuideTask();
		end
	end
end

function BackpackFramePackBtn_OnClick()
	BackPackDisCheckAllBtn();
	local name = this:GetName();
	local btnIcon = getglobal("BackpackFramePackBtnIcon");
	btnIcon:SetTexUV(800, 261, 50, 57);

	getglobal("BackpackFrameRoleFrame"):Hide();
	getglobal("BackpackFrameMakeFrame"):Hide();
	getglobal("BackpackFramePackFrame"):Show();		
end

function BackpackFramePackCover_OnClick()
end

function BackpackFrameMakeBtn_OnClick()
	BackPackDisCheckAllBtn();
	local btnIcon = getglobal("BackpackFrameMakeBtnIcon");
	btnIcon:SetTexUV(912, 264, 50, 57);	

	getglobal("BackpackFrameRoleFrame"):Hide();
	getglobal("BackpackFramePackFrame"):Hide();
	getglobal("BackpackFrameMakeFrame"):Show();		
end

function BackpackFrameMakeCoverBtn_OnClick()
end

function BackpackFrameRoleBtn_OnClick()
	if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 11 then
		return;
	end

	BackPackDisCheckAllBtn();
	local btnIcon = getglobal("BackpackFrameRoleBtnIcon");
	btnIcon:SetTexUV(802, 322, 55, 61);

	getglobal("BackpackFramePackFrame"):Hide();
	getglobal("BackpackFrameMakeFrame"):Hide();
	getglobal("BackpackFrameRoleFrame"):Show();
end

function BackpackFrameRoleCoverBtn_OnClick()
end

local t_backPackLeftBtn = {
	{ name = "BackpackFramePackBtn", x=738,y=261,w=50,h=57 },
	{ name = "BackpackFrameMakeBtn", x=859,y=264,w=50,h=57 },
	{ name = "BackpackFrameRoleBtn", x=735,y=323,w=55,h=61 },
}

function BackPackDisCheckAllBtn()
	for i=1, #(t_backPackLeftBtn) do
		local btn = getglobal(t_backPackLeftBtn[i].name);
		local btnIcon = getglobal(t_backPackLeftBtn[i].name.."Icon");
		btn:SetChecked(false);
		btnIcon:SetTexUV(t_backPackLeftBtn[i].x, t_backPackLeftBtn[i].y, t_backPackLeftBtn[i].w, t_backPackLeftBtn[i].h);
	end
end

-------------------------------------------------------PackFrame----------------------------------------------------------------------------
function PackFrame_OnLoad()
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	PackFrame_AddGameEvent()
	for i=1,BACK_PACK_GRID_MAX/10 do
		for j=1,10 do
			local n 	= (i-1)*10+j;
			local itembtn 	= getglobal("BackpackFramePackFrameItem"..n);
			itembtn:SetPoint("topleft", "BackpackFramePackFrame", "topleft", (j-1)*106+41, (i-1)*106+44);
			if n > 30 then
				local bkg = getglobal("BackpackFramePackFrameItem"..n.."BkgTexture");
				bkg:SetBlendAlpha(0.75);
			end
		end
	end

--	getglobal("BackpackFramePackFrameTestDesc"):SetText(GetS(280));
end

function PackFrame_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local paramData = context:GetParamData()
		local grid_index = paramData.gridIndex
		if grid_index and grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX+1000 then
			PackFrame_UpdateOneGrid(grid_index);
		elseif grid_index < 0 then
			PackFrame_UpdateAllGrids();
		end
		local canMakeNum = CraftHelper:GetPlayerCanCraftNum(CurMainPlayer, productSortId)
		local curNum = tonumber(getglobal("BackpackFrameMakeFrameEdit"):GetText())
		if curNum > canMakeNum then
			getglobal("BackpackFrameMakeFrameEdit"):SetText(canMakeNum)
		end
	end)
end

function PackFrame_OnShow()
	if ShortCut_SelectedIndex >= 0 then		--打开背包时，把选中的快捷栏工具隐藏
		local selbox = getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."BoxTexture1");
		selbox:Hide()
		local uv = getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."UVAnimationTex")
		uv:Hide();
	end
	SetGridEffectForNoviceGuide();
end

function PackFrameTidyBtn_OnClick()
	--CurMainPlayer:mergePack(BACKPACK_START_INDEX);
	CurMainPlayer:sortPack(BACKPACK_START_INDEX);
	PackFrame_UpdateAllGrids();

	--tips隐藏,选中取消
	local mItemTipsFrame = getglobal("MItemTipsFrame");	
	if mItemTipsFrame:IsShown() then
		mItemTipsFrame:Hide();
	end
	if selectBackpackGrid >= ClientBackpack:getShortcutStartIndex() and selectBackpackGrid < ClientBackpack:getShortcutStartIndex()+1000 then
		local index 		= selectBackpackGrid - ClientBackpack:getShortcutStartIndex() + 1;
		local boxTexture = getglobal("ToolShortcut"..index.."Check");
		boxTexture:Hide();
	elseif selectBackpackGrid >= BACKPACK_START_INDEX and selectBackpackGrid < BACKPACK_START_INDEX + 1000 then
		local index 		= selectBackpackGrid - BACKPACK_START_INDEX + 1;
		local boxTexture 	= getglobal("BackpackFramePackFrameItem"..index.."BoxTexture");
		boxTexture:Hide();
	end

	selectBackpackGrid = -1;
end

function PackFrame_UpdateOneGrid(grid_index)
	ClientBackpack:getGridItem(grid_index);
	local n = grid_index+1;
	if grid_index >= BACKPACK_START_INDEX then
		n = n - BACKPACK_START_INDEX
	end	

	if n <= 30 then
		local icon = getglobal("BackpackFramePackFrameItem"..n.."Icon");
		local num = getglobal("BackpackFramePackFrameItem"..n.."Count");
		local durbar = getglobal("BackpackFramePackFrameItem"..n.."Duration");	

		UpdateItemIconCount(icon, num, durbar, grid_index);
	end
end

function PackFrame_UpdateAllGrids()
	for i=1, BACK_PACK_GRID_MAX do
		PackFrame_UpdateOneGrid(BACKPACK_START_INDEX+i-1)
	end
end

function PackFrame_OnEvent()
	local ge = GameEventQue:getCurEvent();

	if arg1 == "GE_BACKPACK_CHANGE" then
		local grid_index = ge.body.backpack.grid_index;
		if grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX+1000 then
			PackFrame_UpdateOneGrid(grid_index);
		elseif grid_index < 0 then
				PackFrame_UpdateAllGrids();
			end
		end
		local canMakeNum = CraftHelper:GetPlayerCanCraftNum(CurMainPlayer, productSortId)
		local curNum = tonumber(getglobal("BackpackFrameMakeFrameEdit"):GetText())
		if curNum > canMakeNum then
			getglobal("BackpackFrameMakeFrameEdit"):SetText(canMakeNum)
		end
end

function HidePackFrameAllItemBoxTexture()
	for i=1,BACK_PACK_GRID_MAX do
		local boxTexture = getglobal("BackpackFramePackFrameItem"..i.."BoxTexture");
		boxTexture:Hide(); 
	end
end

function PackFrame_OnHide()
	HidePackFrameAllItemBoxTexture();
	HideShortCutAllItemBoxTexture();
	selectBackpackGrid = -1;
	
	if ShortCut_SelectedIndex >= 0 then		--关闭背包时，把选中的快捷栏工具显示
		CurMainPlayer:setCurShortcut(ShortCut_SelectedIndex);		
		local selbox = getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."BoxTexture1");
		selbox:Show()

		if CurWorld:getOWID() == NewbieWorldId then
			local taskId = AccountManager:getCurNoviceGuideTask();
			local itemId = ClientBackpack:getGridItem(ShortCut_SelectedIndex+ClientBackpack:getShortcutStartIndex());
			if taskId == 12 or taskId == 13 then
				local guideTipsFrame = getglobal("GuideTipsFrame");	
				if itemId == 800 then
					guideTipsFrame:Hide();
					HideAllFrame(nil, false);
					AccountManager:setNoviceGuideState("chooseCT", true);
					AccountManager:setCurNoviceGuideTask(13);
					ShowCurNoviceGuideTask();
				else
					guideTipsFrame:Hide();
					AccountManager:setNoviceGuideState("chooseCT", false);
					AccountManager:setCurNoviceGuideTask(12);
					ShowCurNoviceGuideTask();
				end
				SetGridEffectForNoviceGuide();
			elseif taskId == 17 or taskId == 18 then
				if itemId == 12502 then
					HideGuideFingerFrame();
					AccountManager:setNoviceGuideState("chooseBread", true);
					AccountManager:setCurNoviceGuideTask(18);
					ShowCurNoviceGuideTask();
				else	
					HideGuideFingerFrame();
					AccountManager:setNoviceGuideState("chooseBread", false);
					AccountManager:setCurNoviceGuideTask(17);
					ShowCurNoviceGuideTask();
				end
				SetGridEffectForNoviceGuide();
			end
		end
	end

	local mItemTipsFrame = getglobal("MItemTipsFrame");	
	if mItemTipsFrame:IsShown() then
		mItemTipsFrame:Hide();
	end

	if SwapBlinkBtnName ~= nil then
		local blinkTexture = getglobal(SwapBlinkBtnName.."Check");	
		blinkTexture:Hide();
		SwapBlinkBtnName = nil;
		SwapBlinkTime = 4;
	end
	
end

function GetPackFrameFristNullGridIndex()	
	for i=1,MAX_SHORTCUT do
		local grid_index = i + ClientBackpack:getShortcutStartIndex() - 1;
		local itemid = ClientBackpack:getGridItem(grid_index);
		if itemid == 0 then
			return grid_index;
		end
	end
	for i=1,BACK_PACK_GRID_MAX do
		local grid_index = i + BACKPACK_START_INDEX - 1;
		local itemid = ClientBackpack:getGridItem(grid_index);
		if itemid == 0 and i <= 30 then
			return grid_index;
		end
	end
	return -1;
end
-------------------------------------------------------RoleFrame----------------------------------------------------------------------------------
local EquipViewCurActor = nil;

function RoleFrame_OnLoad()
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	this:RegisterEvent("GE_BUFF_CHANGE")
	RoleFrame_AddGameEvent()
	for i=1,5 do
		local equipGrid = getglobal("BackpackFrameRoleFrameEquipGrid" .. i);
		equipGrid:SetPoint("topleft", "BackpackFrameRoleFrame", "topleft", (i-1)*106+55, 48);
	end

	for i=1,8 do
		for j=1,5 do
			local equipItem = getglobal("EquipBoxItem"..((i-1)*5+j));
			equipItem:SetPoint("topleft", "EquipBoxPlane", "topleft", (j-1)*106, (i-1)*106);	
		end
	end
end

function RoleFrame_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local paramData = context:GetParamData()
		local grid_index = paramData.gridIndex
		if grid_index and grid_index>=BACKPACK_START_INDEX and grid_index<BACKPACK_START_INDEX+1008 then
			RoleFrame_UpdateOneGrid(grid_index)
		end

		if grid_index >= EQUIP_START_INDEX and grid_index<EQUIP_START_INDEX+1000 then		--更新装备栏
			RoleFrameEquip_UpdateOneGrid(grid_index);
			UpdateRoleFrameArmorBar();
		end
	end)
end

function AttachEquipActorView()
	local player = ClientCurGame:getMainPlayer();

	g_ShowAvatarSeat_Table.playUseSeatIndex = AccountManager:avatar_seat_current();
	if g_ShowAvatarSeat_Table.playUseSeatIndex and g_ShowAvatarSeat_Table.playUseSeatIndex > 0 then
		local seatID = g_ShowAvatarSeat_Table.playUseSeatIndex;
		player = UIActorBodyManager:getAvatarBody(seatID, false);
		local seatSkinDef = g_ShowAvatarSeat_Table.seatInfo[seatID].seatDef;

		-- for i = 1, 10 do
		-- 	if seatSkinDef and seatSkinDef.skin and seatSkinDef.skin[i] then
		-- 	 	if seatSkinDef.skin[i].cfg.ModelID <= 5 or seatSkinDef.skin[i].skin then
		-- 			if i == 2 then
		-- 				player:exchangePartFace(seatSkinDef.skin[i].cfg.ModelID, seatSkinDef.skin[i].cfg.Part, true);
		-- 			else
		-- 				player:addAvatarPartModel(seatSkinDef.skin[i].cfg.ModelID, seatSkinDef.skin[i].cfg.Part);
		-- 			end

		-- 			if seatSkinDef.skin[i].skin.Data and seatSkinDef.skin[i].skin.Data.DyeInfo and next(seatSkinDef.skin[i].skin.Data.DyeInfo) then
		-- 				for p, q in pairs(seatSkinDef.skin[i].skin.Data.DyeInfo) do
		-- 					local blockInfo = q;
		-- 					if #blockInfo == 4 then
		-- 						player:alterAvatarPartColor(blockInfo[2], 
		-- 													blockInfo[3],
		-- 													blockInfo[4],
		-- 													seatSkinDef.skin[i].cfg.Part,
		-- 													seatSkinDef.skin[i].cfg.ModelID,
		-- 													blockInfo[1]);
		-- 					end
		-- 				end
		-- 			end
		-- 		end
		-- 	end
		-- end	
	end

	if EquipViewCurActor ~= player then
		local modelView = getglobal("BackpackFrameRoleFrameEquipActorView");
		EquipViewCurActor = player
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			modelView:attachActorBody(player)
		else
			player:attachUIModelView(modelView);
		end
		local name = AccountManager:getNickName();
		local backpackFrameRoleFramePlayerNick = getglobal("BackpackFrameRoleFramePlayerNick");
		backpackFrameRoleFramePlayerNick:SetText(name);
	end
end

function UpdateRoleFrameArmorBar()
	local point = MainPlayerAttrib:getArmorPointLua(0);
--[[
	local r1, r2 = math.modf(point,1);
	r2 = r2>=0.5 and 1 or 0;
	point = r1 + r2;
]]
	local value = (point/20) > 1 and 1 or (point/20);
	
	local backpackFrameRoleFrameArmorBar = getglobal("BackpackFrameRoleFrameArmorBar");
	backpackFrameRoleFrameArmorBar:SetCurValue(point/20, false);

	local backpackFrameRoleFrameArmorTips = getglobal("BackpackFrameRoleFrameArmorTips");
	if backpackFrameRoleFrameArmorTips:IsShown() then
		UpdateArmorTips();
	end
end

function RoleFrameArmor1_OnClick()
	local backpackFrameRoleFrameArmorTips = getglobal("BackpackFrameRoleFrameArmorTips");
	if not backpackFrameRoleFrameArmorTips:IsShown() then
		backpackFrameRoleFrameArmorTips:Show();
		UpdateArmorTips()
	else
		backpackFrameRoleFrameArmorTips:Hide();
		local backpackFrameRoleFrameArmorTipsDesc = getglobal("BackpackFrameRoleFrameArmorTipsDesc");
		backpackFrameRoleFrameArmorTipsDesc:Clear();
	end
end

function UpdateArmorTips()
	local point = string.format("%.1f", MainPlayerAttrib:getArmorPointLua(0));
	local subInjury = 5*point;
	local text = GetS(441, point, subInjury).."\n\n";
	text = text..GetS(444).."\n"..GetS(445);

	getglobal("BackpackFrameRoleFrameArmorTipsDesc"):SetText(text, 255, 255, 255);
end

function ArmorTips_OnClick()
	getglobal("BackpackFrameRoleFrameArmorTips"):Hide();
	getglobal("BackpackFrameRoleFrameArmorTipsDesc"):Clear();
end

function ClearRoleFrameAllItem()
	for i=1,BACK_PACK_GRID_EQUIP_MAX do
		local equipItem = getglobal("EquipBoxItem" .. i);
		local icon = getglobal("EquipBoxItem"..i.."Icon");
		local num = getglobal("EquipBoxItem"..i.."Count");
		local durbar = getglobal("EquipBoxItem"..i.."Duration");
		icon:SetTextureHuires(ClientMgr:getNullItemIcon());
		num:SetText("");
		equipItem:SetClientID(0)
		durbar:Hide();
	end
end

function ClearRoleFrameOneItem(btnIndex)
	local equipItem = getglobal("EquipBoxItem" .. btnIndex);
	local icon = getglobal("EquipBoxItem"..btnIndex.."Icon");
	local num = getglobal("EquipBoxItem"..btnIndex.."Count");
	local durbar = getglobal("EquipBoxItem"..btnIndex.."Duration");
	icon:SetTextureHuires(ClientMgr:getNullItemIcon());
	num:SetText("");
	equipItem:SetClientID(0)
	durbar:Hide();
end

--[[
function RoleFrame_OnHide()
	if EquipViewCurActor ~= nil then
		EquipViewCurActor:detachUIModelView();
		EquipViewCurActor = nil;
	end

	local mItemTipsFrame = getglobal("MItemTipsFrame");
	if mItemTipsFrame:IsShown() then
		mItemTipsFrame:Hide();
	end

	SetRoleFrameBoxTexture(nil);
	local backpackFrameRoleFrameArmorTips = getglobal("BackpackFrameRoleFrameArmorTips");
	backpackFrameRoleFrameArmorTips:Hide();	
	
	if CurWorld:getOWID() == NewbieWorldId then
		local taskId = AccountManager:getCurNoviceGuideTask();
		if taskId > 21 and taskId < 24 then
			HideGuideFingerFrame();
			AccountManager:setNoviceGuideState("wearEP2", false);
			AccountManager:setNoviceGuideState("wearEP3", false);
			AccountManager:setNoviceGuideState("wearEP4", false);
			AccountManager:setCurNoviceGuideTask(21);
			ShowCurNoviceGuideTask();
		end
	end
end
]]
--初始化所有装备栏
function InitEquipAllGrid()
	for i=1, 5 do
		local grid_index = EQUIP_START_INDEX + i - 1;
		local iconbtn = getglobal("BackpackFrameRoleFrameEquipGrid"..i.."Icon");
		local numtext = getglobal("BackpackFrameRoleFrameEquipGrid"..i.."Count");
		local durbar = getglobal("BackpackFrameRoleFrameEquipGrid"..i.."Duration");

		UpdateItemIconCount(iconbtn, numtext, durbar, grid_index);	
	end
end

--更新一个装备栏
function RoleFrameEquip_UpdateOneGrid(grid_index)
	local n = grid_index + 1 - EQUIP_START_INDEX;
	local name = "BackpackFrameRoleFrameEquipGrid"..n;
	local iconbtn = getglobal(name.."Icon");

	local numtext = getglobal(name.."Count");
	local durbar = getglobal(name.."Duration");
	
	UpdateItemIconCount(iconbtn, numtext, durbar, grid_index);
end

function GetRoleFrameItemIndex(grid_index)
	local id = grid_index - BACKPACK_START_INDEX + 1;
	for i=1,BACK_PACK_GRID_EQUIP_MAX do									-- 物品替换，替换后的物品放在原来的格子上
		local equipItem = getglobal("EquipBoxItem" .. i);
		if equipItem:GetClientID() == id then
			return true,i;
		end
	end
	for i=1,BACK_PACK_GRID_EQUIP_MAX do									-- 找一个空的格子放这个物品
		local equipItem = getglobal("EquipBoxItem" .. i);
		if equipItem:GetClientID() < 1 then
			return false,i;
		end
	end
	return false,-1;
end

function RoleFrame_UpdateOneGrid(grid_index)
	local isExsit,n = GetRoleFrameItemIndex(grid_index);
	if n < 1 then return end

	local id = grid_index - BACKPACK_START_INDEX +1;

	local btn = getglobal("EquipBoxItem"..n);

	local icon = getglobal("EquipBoxItem"..n.."Icon");
	local num = getglobal("EquipBoxItem"..n.."Count");
	local durbar = getglobal("EquipBoxItem"..n.."Duration");

	if not IsEquip(grid_index) then
		if isExsit then
			icon:SetTextureHuires(ClientMgr:getNullItemIcon());
			num:SetText("");
			btn:SetClientID(0);
			durbar:Hide();
			return;
		else
			return;
		end
	end

	btn:SetClientID(id);						--标识这个装备在背包栏中的Index;
	UpdateItemIconCount(icon, num, durbar, grid_index);
end

--从背包物品栏中筛选出所有的装备更新到装备面板的物品栏中
function RoleFrame_UpdateAllGrids()
	for i=1,BACK_PACK_GRID_MAX do
		local grid_index = i + BACKPACK_START_INDEX - 1;
		if IsEquip(grid_index) then
			RoleFrame_UpdateOneGrid(grid_index);		
		end
	end

	for i=1,MAX_SHORTCUT do
		local grid_index = i + ClientBackpack:getShortcutStartIndex() - 1;
		if IsEquip(grid_index) then
			RoleFrame_UpdateOneGrid(grid_index);		
		end
	end
end

function RoleFrame_OnEvent()
	local ge = GameEventQue:getCurEvent();

	if arg1 == "GE_BACKPACK_CHANGE" then
		local grid_index = ge.body.backpack.grid_index;

		if grid_index>=BACKPACK_START_INDEX and grid_index<BACKPACK_START_INDEX+1008 then
			RoleFrame_UpdateOneGrid(grid_index)
		end

		if grid_index >= EQUIP_START_INDEX and grid_index<EQUIP_START_INDEX+1000 then		--更新装备栏
			RoleFrameEquip_UpdateOneGrid(grid_index);
			UpdateRoleFrameArmorBar();
		end
	elseif arg1 == "GE_BUFF_CHANGE" then
		UpdateRoleFrameArmorBar();
	end
end

function EquipBoxItemPlace(grid_index)
	local equipSlot = ToolType2EquipSlot(ClientBackpack:getGridToolType(grid_index));
	if equipSlot > 0 then
		CurMainPlayer:swapItem(grid_index, equipSlot);
		SetRoleFrameBoxTexture(nil);

		if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 23 then
			HideGuideFingerFrame();
			AccountManager:setNoviceGuideState("wearEP4", true);
			AccountManager:setCurNoviceGuideTask(24);
			ShowCurNoviceGuideTask();
		end
	end
end

function RoleFrameEquipPlace(grid_index)
	local togrid_index = GetPackFrameFristNullGridIndex();
	if togrid_index ~= -1 then
		CurMainPlayer:swapItem(grid_index, togrid_index);
		SetRoleFrameBoxTexture(nil);
	end
end

function SetRoleFrameBoxTexture(btnName)
	for i=1,BACK_PACK_GRID_EQUIP_MAX do
		local boxTexture = getglobal("EquipBoxItem"..i.."BoxTexture");
		if boxTexture then
			boxTexture:Hide();
		end
	end

	for i=1, 5 do
		local boxTexture = getglobal("BackpackFrameRoleFrameEquipGrid"..i.."BoxTexture");
		if boxTexture then
			boxTexture:Hide();
		end
	end

	if btnName ~= nil then
		local boxTexture = getglobal(btnName.."BoxTexture");
		if boxTexture then
			boxTexture:Show();
		end
	end
end

function RoleFrameArmorBar_OnShow()
end

--[[
ROTATE_ACTOR_SPEED = 180.0
function RoleFrameLeftBtn_OnMouseDown()
	local modelView = getglobal("BackpackFrameRoleFrameEquipActorView");
	modelView:setRotateSpeed(ROTATE_ACTOR_SPEED);
end

function RoleFrameLeftBtn_OnMouseUp()
	local modelView = getglobal("BackpackFrameRoleFrameEquipActorView");
	modelView:setRotateSpeed(0);
end

function RoleFrameRightBtn_OnMouseDown()
	local modelView = getglobal("BackpackFrameRoleFrameEquipActorView");
	modelView:setRotateSpeed(-ROTATE_ACTOR_SPEED);
end

function RoleFrameRightBtn_OnMouseUp()
	local modelView = getglobal("BackpackFrameRoleFrameEquipActorView");
	modelView:setRotateSpeed(0);
end
--]]
---------------------------------------------MakeFrame--------------------------------------------------------------------------------
local Making = false;
local IsMakeLongPress = false;	--标记制作按钮为长按按钮状态
function MakeFrame_OnLoad()
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	MakeFrame_AddGameEvent()
	--for i=1,20 do
		--for j=1,5 do
			--local item = getglobal("MiniProductBoxItem"..((i-1)*5+j));
			--item:SetPoint("topleft", "MiniProductBoxPlane", "topleft", (j-1)*106, (i-1)*106);	
		--end
	--end


	for i=1,20 do
		for j=1,6 do		
			if (i-1)*6+j <= 100 then		
				local item = getglobal("MiniProductBoxItem"..((i-1)*6+j));
				item:SetPoint("topleft", "MiniProductBoxPlane", "topleft", (j-1)*82, (i-1)*82);	
			end			
		end
	end	
	
	local leftTips = getglobal("BackpackFrameMakeFrameLeftTips");
	local rightTips = getglobal("BackpackFrameMakeFrameRightTips");
	leftTips:SetText(GetS(3007));	--StringDef当前材料可制作：
--	rightTips:SetText(GetS(3008));	--StringDef物品
end

function MakeFrame_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local canMakeCT = false;
		if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 10 then
			local indexCT = CheckProductId(800, 0);
			if indexCT > 0 then
				if ClientBackpack:getGridEnough(indexCT) == 0 then
					canMakeCT = false;
				else
					canMakeCT = true;
				end
			else
				canMakeCT = false;
			end
		end

		local backpackFrameMakeFrame = getglobal("BackpackFrameMakeFrame");
		if not backpackFrameMakeFrame:IsShown() then return; end
		ClientBackpack:updateProductContainer(PRODUCT_LIST_TWO_INDEX);

		MakeFrame_UpdateAllGrid(index);
		--更新合成制作台的新手引导
		if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 10 then
			UpdateNoviceForMakeCT(canMakeCT);
		end
	end)
end

function MakeFrame_OnShow()
	selectProductId = 0
	productSortId = 0;

	ClientBackpack:updateProductContainer(PRODUCT_LIST_TWO_INDEX);
	MakeFrame_UpdateAllGrid();

	if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 9 then
		HideGuideFingerFrame();
		AccountManager:setNoviceGuideState("chooseBPmake", true);
		AccountManager:setCurNoviceGuideTask(10);
		ShowCurNoviceGuideTask();
	end 
	
	-- if not getglobal("BackpackFrameMakeFrame"):IsReshow() then
	-- 	ClientCurGame:setOperateUI(true);
	-- end
end

function MakeFrame_UpdateAllGrid(index)
	for i=1,MINI_PRODUCT_GRID_MAX do	
		local icon 	= getglobal("MiniProductBoxItem"..i.."Icon");
		local num 	= getglobal("MiniProductBoxItem"..i.."Count");
		local durbar 	= getglobal("MiniProductBoxItem"..i.."Duration");
		local lack 	= getglobal("MiniProductBoxItem"..i.."Lack");
		local grid_index = i + PRODUCT_LIST_TWO_INDEX - 1;
		local id = ClientBackpack:getGridItem(grid_index);
		UpdateCratingItemIconCount(icon, num, durbar, grid_index, lack);
		local boxTexture = getglobal("MiniProductBoxItem"..i.."BoxTexture");

		if productSortId == ClientBackpack:getGridSortId(grid_index) and productSortId ~= 0 then
			boxTexture:Show();	
		else
			boxTexture:Hide();	
		end
	end
	--and index == -1
	if true then		-- index为-1的时候，表示制作要消耗的材料已经消耗了，这个时候更新面板
		local grid_index = CheckProductId(selectProductId, productSortId)
		local enough = 0;
		if grid_index > 0 then		--制作物列表里还有这个物品
			local btnName = GetCurProductIdGridName(grid_index);
			SetOnclikItemBoxTexture( btnName );
			enough = ClientBackpack:getGridEnough(grid_index);
		else				
			HideMakeFrameAllItemBoxTexture();
			selectProductId = 0;
			productSortId = 0;
		end
		local num = ClientBackpack:updateCraftContainer(productSortId, MINICRAFT_START_INDEX, enough);

		UpdateMakeFrameRight(grid_index, num);
		Making = false;
	end
end

function GetCurProductIdGridName(index)
	for i=1,MINI_PRODUCT_GRID_MAX do
		local grid_index = PRODUCT_LIST_TWO_INDEX + i - 1;
		if index == grid_index then
			local btn = getglobal("MiniProductBoxItem"..i);
			return btn:GetName();
		end	
	end
	return "";
end

function CheckProductId(productId, sortId)
	for i=1,MINI_PRODUCT_GRID_MAX do
		local grid_index = PRODUCT_LIST_TWO_INDEX + i - 1;
		if ClientBackpack:getGridItem(grid_index) ~= 0 and ClientBackpack:getGridItem(grid_index) == productId then
			if sortId <= 0 then
				return grid_index;
			elseif ClientBackpack:getGridSortId(grid_index) == sortId then
				return grid_index;
			end
		end	
	end
	return -1;
end

function MakeFrame_OnEvent()
	local ge = GameEventQue:getCurEvent();
	local index = ge.body.backpack.grid_index;

	if arg1 == "GE_BACKPACK_CHANGE" then
		local canMakeCT = false;
		if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 10 then
			local indexCT = CheckProductId(800, 0);
			if indexCT > 0 then
				if ClientBackpack:getGridEnough(indexCT) == 0 then
					canMakeCT = false;
				else
					canMakeCT = true;
				end
			else
				canMakeCT = false;
			end
		end

		local backpackFrameMakeFrame = getglobal("BackpackFrameMakeFrame");
		if not backpackFrameMakeFrame:IsShown() then return; end
		ClientBackpack:updateProductContainer(PRODUCT_LIST_TWO_INDEX);	
		
		MakeFrame_UpdateAllGrid(index);
		--更新合成制作台的新手引导
		if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 10 then
			UpdateNoviceForMakeCT(canMakeCT);
		end		
	end
end

function HideMakeFrameAllItemBoxTexture()
	for i=1,MINI_PRODUCT_GRID_MAX do
		local boxTexture = getglobal("MiniProductBoxItem"..i.."BoxTexture");
		boxTexture:Hide(); 
	end
end

function UpdateMakeFrameAllStuffGrid(stuffNum)
	local icon 	= getglobal("BackpackFrameMakeFrameMakeResultIcon");
	local num 	= getglobal("BackpackFrameMakeFrameMakeResultCount");
	local durbar 	= getglobal("BackpackFrameMakeFrameMakeResultDuration");
	local lack 	= getglobal("BackpackFrameMakeFrameMakeResultLack");
	local name 	= getglobal("BackpackFrameMakeFrameMakeResultName");
	local desc 	= getglobal("BackpackFrameMakeFrameResultDescText");
	local grid_index = MINICRAFT_START_INDEX + MINICRAFT_GRID_MAX - 1;
	local id = ClientBackpack:getGridItem(grid_index);
	UpdateCratingItemIconCount(icon, num, durbar, grid_index, lack, name, desc);

	if id ~= 0 then
		local backpackFrameMakeFrameMakeBtnNormal 	= getglobal("BackpackFrameMakeFrameMakeBtnNormal");
		if ClientBackpack:getGridEnough(grid_index) == -1 then
			backpackFrameMakeFrameMakeBtnNormal:SetGray(true);
		else
			backpackFrameMakeFrameMakeBtnNormal:SetGray(false);
		end
	end

	if stuffNum > 0 then
		getglobal("BackpackFrameMakeFrameRightTips"):SetText(GetS(3972, stuffNum), 98, 65, 48);
	else
		getglobal("BackpackFrameMakeFrameRightTips"):SetText("", 98, 65, 48);
	end

	for i=1,MINICRAFT_GRID_MAX-1 do
		icon 	= getglobal("BackpackFrameMakeFrameStuffGrid"..i.."Icon");
		num 	= getglobal("BackpackFrameMakeFrameStuffGrid"..i.."Count1");
		durbar 	= getglobal("BackpackFrameMakeFrameStuffGrid"..i.."Duration");
		lack	= getglobal("BackpackFrameMakeFrameStuffGrid"..i.."Lack");
		name	= getglobal("BackpackFrameMakeFrameStuffGrid"..i.."Name");
		desc	= getglobal("BackpackFrameMakeFrameStuffGrid"..i.."Desc");
		grid_index = MINICRAFT_START_INDEX + i - 1;
		id = ClientBackpack:getGridItem(grid_index);
		UpdateCratingItemIconCount(icon, num, durbar, grid_index, lack, name, desc);

	end	
end

function UpdateProductTips(grid_index)	
	local backpackFrameMakeFrameName 	= getglobal("BackpackFrameMakeFrameName");
	local backpackFrameMakeFrameItemDesc 	= getglobal("BackpackFrameMakeFrameItemDesc");
	if grid_index < 0 or ClientBackpack:getGridItem(grid_index) <= 0 then		
		backpackFrameMakeFrameName:SetText("");
		backpackFrameMakeFrameItemDesc:Clear();
	else
		local name 	= ClientBackpack:getGridItemName(grid_index);
		local itemId 	= ClientBackpack:getGridItem(grid_index);
		local itemDef 	= ItemDefCsv:get(itemId)
		if itemDef ~= nil then
		--	backpackFrameMakeFrameName:SetText(name);
		--	backpackFrameMakeFrameItemDesc:SetText(itemDef.Desc, 118, 67, 0);
		end
	end	
end

function UpdateMakeFrameRight(grid_index, stuffNum)
	UpdateMakeFrameAllStuffGrid(stuffNum);
	UpdateProductTips(grid_index);
end

function MakeFrame_OnHide()
	HideMakeFrameAllItemBoxTexture();
	ClientBackpack:updateCraftContainer(0, MINICRAFT_START_INDEX, 1);		--关闭的时候传ID为零，清除craftContainer里的内容
	UpdateMakeFrameAllStuffGrid(0);

	local backpackFrameMakeFrameName 	= getglobal("BackpackFrameMakeFrameName");
	backpackFrameMakeFrameName:SetText("");
	local backpackFrameMakeFrameItemDesc 	= getglobal("BackpackFrameMakeFrameItemDesc");
	backpackFrameMakeFrameItemDesc:Clear();

	local mItemTipsFrame 	= getglobal("MItemTipsFrame");
	if mItemTipsFrame:IsShown() then
		mItemTipsFrame:Hide();
	end

	if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 10 then
		HideGuideFingerFrame();
		AccountManager:setNoviceGuideState("chooseBPmake", false);
		AccountManager:setCurNoviceGuideTask(9);
		ShowCurNoviceGuideTask();
	end
	
	-- if not getglobal("BackpackFrameMakeFrame"):IsRehide() then
	-- 	ClientCurGame:setOperateUI(false);
	-- end
end

function CheckIsLackItem()
	for i=1,MINICRAFT_GRID_MAX - 1 do
		local grid_index = MINICRAFT_START_INDEX + i - 1;
		if ClientBackpack:getGridEnough(grid_index) == -1 then
			local name = ClientBackpack:getGridItemName(grid_index)
			return true,name;
		end	
	end
	return false,"";
end

local frontTime = 0;
function PackFrameMakeBtn_OnMouseDownUpdate()		
	if arg1 - frontTime > 0.2 then  	--长按0.2秒制作一次
		frontTime = arg1;
		IsMakeLongPress = true;
		MakeProduct();
	end
end

function PackFrameMakeBtn_OnClick()
	frontTime = 0;
	if IsMakeLongPress then
		IsMakeLongPress = false;
		return;
	end
	MakeProduct()
end

function MakeProduct()
	if Making then return; end

	local mItemTipsFrame 	= getglobal("MItemTipsFrame");
	if mItemTipsFrame:IsShown() then
		mItemTipsFrame:Hide();
	end
	local num = tonumber(getglobal("BackpackFrameMakeFrameEdit"):GetText())
	if num == 0 then
		return
	end
--	Making = true;
	local grid_index = CheckProductId(selectProductId, productSortId);
	if grid_index < 0 then
		ShowGameTips(GetS(35), 3);
		Making = false;
		return;
	end

	local result_index = getglobal("BackpackFrameMakeFrameMakeResult"):GetClientID() - 1;
	if ClientBackpack:getGridItem(grid_index) > 0 then
		
		local resultId = ClientBackpack:getGridItem(result_index);
		local resultDef = ItemDefCsv:get(resultId);
		if resultDef.UnlockFlag > 0 then
			local unlock, hasUnlockInfo = isItemUnlockByItemId(resultDef.ID)
			if not unlock then
				ShowItemUnLockTips(hasUnlockInfo)
				return
			end
		end

		local isLack,itemName = CheckIsLackItem();
		if isLack then
			local text = GetS(61, itemName);
			ShowGameTips(text, 2);
			Making = false;
			ClientMgr:playSound2D("sounds/ui/info/crafting_error.ogg", 1);
		else
			--[[local num = ClientBackpack:getCurCraftIdsNum()
			for i=1, num do
				local id = ClientBackpack:getCurCraftId(i-1);
				local def = DefMgr:getCraftingDef(id)
				local itemDef = ItemDefCsv:get(def.ResultID);
				if def and itemDef then
					CurMainPlayer:craftItem(id);
					local text = GetS(62, itemDef.Name, def.ResultCount);
					ShowGameTips(text, 1);
				end
			end	]]
			CurMainPlayer:craftItem(productSortId, num);				
			itemName = ClientBackpack:getGridItemName(result_index);
			local itemNum = ClientBackpack:getGridNum(result_index) ;

			local text = GetS(62, itemName, itemNum );
			ShowGameTips(text, 1);

			local effect = getglobal("BackpackFrameMakeFrameEffect");
			effect:SetUVAnimation(100, false);
			ClientMgr:playSound2D("sounds/ui/info/crafting_success.ogg", 1);

			--新手引导合成制作台
			if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 10 then
				if ClientBackpack:getGridItem(grid_index) == 800 then
					AddGuideTaskCurNum(8, 1);
					HideGuideFingerFrame();
					AccountManager:setNoviceGuideState("makeCT", true);
					AccountManager:setCurNoviceGuideTask(11);
					ShowCurNoviceGuideTask();
				end			
			end				
		end
	end
end

function PackFrameMake_IncreaseOnClick()
	if not productSortId then
		print(" productSortId nil ")
		return
	end
	local num = tonumber(getglobal("BackpackFrameMakeFrameEdit"):GetText())
	num = num + 1
	local canMakeNum = CraftHelper:GetPlayerCanCraftNum(CurMainPlayer, productSortId)
	if num > canMakeNum then
		num = canMakeNum
	end
	local matNum = ClientBackpack:updateCraftContainer(productSortId, MINICRAFT_START_INDEX, 1, num);
	getglobal("BackpackFrameMakeFrameEdit"):SetText(num)
	UpdateMakeFrameAllStuffGrid(matNum)
end

function PackFrameMake_DecreaseOnClick()
	if not productSortId then
		print(" productSortId nil ")
		return
	end
	local num = tonumber(getglobal("BackpackFrameMakeFrameEdit"):GetText())
	if num ==  1 then
		return
	end
	num = num - 1
	if num > 0 then
		getglobal("BackpackFrameMakeFrameEdit"):SetText(num)
	end
	local matNum = ClientBackpack:updateCraftContainer(productSortId, MINICRAFT_START_INDEX, 1, num);
	UpdateMakeFrameAllStuffGrid(matNum)
end

function PackFrameMake_MakeNumLostFocus()
	local num = getglobal("BackpackFrameMakeFrameEdit"):GetText()
	if  tonumber(num) <= 0 then
		num = 1
		getglobal("BackpackFrameMakeFrameEdit"):SetText(num)
	end
	local matNum = ClientBackpack:updateCraftContainer(productSortId, MINICRAFT_START_INDEX, 1, tonumber(num));
	UpdateMakeFrameAllStuffGrid(matNum)
end

function PackFrameMake_MaxMakeNumClick()
	if not productSortId then
		print(" productSortId nil ")
		return
	end
	local canMakeNum = CraftHelper:GetPlayerCanCraftNum(CurMainPlayer, productSortId)
	getglobal("BackpackFrameMakeFrameEdit"):SetText(canMakeNum)
	local matNum = ClientBackpack:updateCraftContainer(productSortId, MINICRAFT_START_INDEX, 1, canMakeNum);
	UpdateMakeFrameAllStuffGrid(matNum)
end

function PackFrameMake_OnProductClick()
	getglobal("BackpackFrameMakeFrameEdit"):SetText(1)
end

function UpdateNoviceForMakeCT(canMakeCT)
	local grid_index = CheckProductId(800, 0);
	if grid_index > 0 then
		if ClientBackpack:getGridEnough(grid_index) == 0 then
			if canMakeCT then
				HideGuideFingerFrame();
				SetGuideTipsInfo(-260, 65, 1, GetS(300));
			end
		else
			if not canMakeCT then
				HideGuideFingerFrame();
				SetGuideTipsInfo(-260, 30, 1, GetS(301), 9);
				local index = grid_index+1-PRODUCT_LIST_TWO_INDEX;
				local indexX = index - math.floor((index-1)/5)*5;
				local indexY = math.floor((index-1)/5);
				x = 200 + (indexX-1)*106;
				y = 150 + indexY*106;	
				SetGuideFingerInfo(x, y, 0, 5, true, 100);
			end
		end
	else
		if canMakeCT then
			HideGuideFingerFrame();
			SetGuideTipsInfo(-260, 65, 1, GetS(300));
		end
	end				
end

--------------------------------------------------------------------创造模式背包---------------------------------------------------------------------------------------------
CREATE_BACKPACK_MAX = 360;
t_CreateNewItemTag = {};		--新建物品显示红点
t_CreateBackPackNewItemVersionTag = {}; --根据版本号显示新增道具标识 --改为存ID 不存C++对象了 code-by:liwentao
t_ClickItemVersionTag = {};             --用户已点击过的版本新道具
local CreateBackPack_Need_EndDrag = true;
local CurSelectCreateType = 1;		--当前选择的创造模式的背包类型，
local CurSelectCreateSubtype = 1; --点钱选择的背包类型的子类
local CurSelectTabIndex = 1;   --当前打开背包所选择的标签页的下标
local t_createBackpackLabelInfo = 
	{
		{ name="CreateBackpackFrameCropBtn", nameId=3525, uvname="juese_zhuowu", loadindex=1},
		{ name="CreateBackpackFrameMachineBtn", nameId=3526, uvname="juese_gongju", loadindex=1},
		{ name="CreateBackpackFrameCommonBtn", nameId=3527, uvname="juese_zawu", loadindex=1},
		{ name="CreateBackpackFrameMineralBtn", nameId=3528, uvname="juese_fangkuai", loadindex=1 },
		{ name="CreateBackpackFrameEditBtn", nameId=3529, uvname="juese_bianji", loadindex=1},
	}

local t_subTypeLabelInfo = {
    { {title ="3820", iconName = "236"},
      {title ="9117", iconName = "230"},
      {title ="3757", iconName = "12543"},
      {title ="21214", iconName = "1020"},
      {title ="3963", iconName = "1019"},
    },
    { {title ="3820", iconName = "11014"},
      {title ="3128", iconName = "1063"},
	  {title ="4705", iconName = "1182"}, --{title ="421", iconName = "701"}, 电路图标修改
      {title ="3932", iconName = "13400"},
      {title ="3013", iconName = "15002"},
    },
    { {title ="3820", iconName = "839"},
      {title ="21215", iconName = "556"},
      {title ="21216", iconName = "977"},
      {title ="21217", iconName = "748"},
      {title ="21218", iconName = "11075"},
    },
    { {title ="3820", iconName = "11213"},
	  {title ="21219", iconName = "101"},--{title ="21219", iconName = "100"},
      {title ="21220", iconName = "404"},
      {title ="21218", iconName = "132"},
      {title ="292", iconName = "518"},
    },
    { {title ="3820", iconName = "997"},
      {title ="3806", iconName = "1039"},
      {title ="4709", iconName = "1150"},
      {title ="32072", iconName = "840"},
      --{title ="3932", iconName = "1039"},
    }
}

local t_CreateBackpackDef = nil;
local t_CreateBackpackSubTypeDef = { };
local t_CreateBackpackChangeItem = {};
local t_CreateBackpackDeveloperItem = {
	[1138] = true,
	[1142] = true,
	[1150] = true,
	[1151] = true,
	[10500] = true,
	[10501] = true,
}; --有部分道具需移到开发者。这里添加一个列表映射

local CreateBackpackIndex=1;
local t_CreateTypeRedTag = {
	num1 = 0,
	num2 = 0,
	num3 = 0,
	num4 = 0,
    num5 = 0,
}
t_AvatarPluginDef = {}

function InitGodModeItemIconLoadState()
	for k, v in pairs(t_createBackpackLabelInfo) do
		v.loadindex = 1;
	end
end

--tab按钮点击
function CreateBackpackFrameCropBtn_OnClick(subtype)
	print("CreateBackpackFrameCropBtn_OnClick:");
	HideCreateBoxItemBoxTexture();
	CurSelectCreateType = 1;
	CreateBackpackIndex = 1;
    CurSelectCreateSubtype = subtype or 1;
    BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,CurSelectCreateSubtype);
	UpdateCreateItem();
end

function CreateBackpackFrameMachineBtn_OnClick(subtype)
	print("CreateBackpackFrameMachineBtn_OnClick:");
	HideCreateBoxItemBoxTexture();
	CurSelectCreateType = 2;
	CreateBackpackIndex = 1;
    CurSelectCreateSubtype = subtype or 1;
    BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,CurSelectCreateSubtype);
	UpdateCreateItem();
end

function CreateBackpackFrameCommonBtn_OnClick(subtype)
	print("CreateBackpackFrameCommonBtn_OnClick:");
	HideCreateBoxItemBoxTexture();
	CurSelectCreateType = 3;
	CreateBackpackIndex = 1;
    CurSelectCreateSubtype = subtype or 1;
    BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,CurSelectCreateSubtype);
	UpdateCreateItem();
end

function CreateBackpackFrameMineralBtn_OnClick(subtype)
	print("CreateBackpackFrameMineralBtn_OnClick:");
	HideCreateBoxItemBoxTexture();
	CurSelectCreateType = 4;
	CreateBackpackIndex = 1;
    CurSelectCreateSubtype = subtype or 1;
    BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,CurSelectCreateSubtype);
	UpdateCreateItem();
end

function CreateBackpackFrameEditBtn_OnClick(subtype)
	print("CreateBackpackFrameEditBtn_OnClick:");
	HideCreateBoxItemBoxTexture();
	CurSelectCreateType = 5;
	CreateBackpackIndex = 1;
    CurSelectCreateSubtype = subtype or 1;
    BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,CurSelectCreateSubtype);
	UpdateCreateItem();
	RemoveCreateNewItemTag("edittab");
	if not AccountManager:getNoviceGuideState("guideedittab") then
		AccountManager:setNoviceGuideState("guideedittab", true);
	end
	if getglobal(this:GetName().."RedTag") then
		getglobal(this:GetName().."RedTag"):Hide();
	end
	getglobal("CreateBackpackFrameWiki"):Show();
end

function CreateBackpackFrame_OnLoad()
	this:RegisterEvent("GIE_LEAVE_WORLD");

	-- --动态创建格子
	-- BackpackCreateGird();

	-- --格子布局
	-- local leftOffset = 9;
	-- local topOffset = 11;
	-- for i=1, CREATE_BACKPACK_MAX/11 do
	-- 	for j=1, 11 do
	-- 		local createItem = getglobal("CreateBoxItem"..((i - 1) * 11 + j));
	-- 		createItem:SetPoint("topleft", "CreateBoxPlane", "topleft", (j - 1) * 84 + leftOffset, (i - 1) * 83 +topOffset);
	-- 	end
	-- end

	--快捷栏布局
	for i=1, MAX_SHORTCUT do
		local grid = getglobal("CreateBackpackFrameShortcutGrid"..i);
		grid:SetPoint("topleft", "CreateBackpackFrameShortcut", "topleft", (i - 1) * 104 + 117, 8);
		getglobal("CreateBackpackFrameShortcutGrid"..i .. "Num"):SetText(i);
	end

	this:setUpdateTime(0.05);

	--关闭按钮
	UITemplateBaseFuncMgr:registerFunc("CreateBackpackFrameBodyCloseBtn", CreateBackpackFrameCloseBtn_OnClick, "背包页面关闭按钮");
	getglobal("CreateBackpackFrameBodyTitleName"):SetText(GetS(294));
end

--动态创建格子
function BackpackCreateGird()
	print("BackpackCreateGird:");
	local createCount = 360;
	local type_name = "Button"
	local template_name = "GridButtonTemplate2"
	local parent_name = "CreateBox";

	for i = 1, createCount do
		local name = "CreateBoxItem" .. i;
		local item = UIFrameMgr:CreateFrameByTemplate(type_name, name, template_name, parent_name);

		if item then
			item:Hide();
			-- item:SetClientID(i);
		end
	end
end

-----------------------------------listview-------------------------------------------
local gBackPackList = {}
function updateBackPackList()
    if CurSelectCreateType>0 and CurSelectCreateSubtype>0 then
        local index = CurSelectCreateType*10 + (CurSelectCreateSubtype-1);
        if index == CurSelectCreateType*10 then
            gBackPackList = GetItemDefTable2CreateType();
        else
            local t_subTypeDef = t_CreateBackpackSubTypeDef[CurSelectCreateType];
            gBackPackList = t_subTypeDef[index];
        end
    end

	if gBackPackList == nil or #gBackPackList == 0 then
		gBackPackList = {}
		getglobal("CreateBackpackFrameContentNull"):Show();
		getglobal("CreateBackpackFrameContentNullTitle"):Show();
	else
		getglobal("CreateBackpackFrameContentNull"):Hide();
		getglobal("CreateBackpackFrameContentNullTitle"):Hide();
	end

	selectCreateItemId = -1
	local list = getglobal("CreateBox")
	list:initData(938, 470, 5, 11)
	list:setCurOffsetY(0)

	loadNewItemInfo()
	SetSubTypeRedTag()
	SetCreateTypeRedTag()
end

function CreateBox_tableCellAtIndex(tableview, idx)
	local cell, uiidx = tableview:dequeueCell(0)

	local info = gBackPackList[idx+1]
	if not cell then
		cell = UIFrameMgr:CreateFrameByTemplate("Button", "CreateBoxItem" .. uiidx, "GridButtonTemplate2", "CreateBox")
	else
		cell:Show()
	end
	
	local id = info.ID
	cell:SetClientUserData(0, id)
	if id<0 then
		cell:SetClientUserData(1,info.folderIndex)
		cell:SetClientString(info.itemName)
	end
	setBackPackListItemData(cell:GetName(), info)

	return cell
end

function CreateBox_numberOfCellsInTableView(tableview)
	return #gBackPackList
end

function CreateBox_tableCellSizeForIndex(tableview, idx)
	local colidx = math.mod(idx, 11)

	return 10+84*colidx, 2, 84, 84
end

function CreateBox_tableCellWillRecycle(tableview, cell)
	if cell then cell:Hide() end
end

function setBackPackListItemData(cellname, info)
	local createItem = getglobal(cellname)
	if not createItem then return end

	local itemIcon = getglobal(cellname.."Icon")
	local unlock = getglobal(cellname.."Unlock")
	local ui_bkg = getglobal(cellname.."Bkg")
	local ban = getglobal(cellname.."Ban");
	if info.resType then
		unlock:Hide()
		ban:Hide()
		getglobal(cellname.."NewTag"):Hide();
		getglobal(cellname.."NewTagBG"):Hide();
		getglobal(cellname.."RedTag"):Hide();
		getglobal(cellname.."Check"):Hide();
		ui_bkg:SetTexUV("img_icon_lignt");
		ResourceCenterSetResIcon(info.resClass, itemIcon, info.itemName, info.resType)
	else
	
		SetItemIcon(itemIcon, info.ID)
		itemIcon:SetGray(false)
		if selectCreateItemId == info.ID then
			getglobal(cellname.."Check"):Show()
		else
			getglobal(cellname.."Check"):Hide()
		end
	
		local def = t_CreateBackpackChangeItem[info.ID]
	
		-- 生物蛋相关：设置过插件 显示就要按照已经修改过的规则显示  背景加深
		-- MobEgg_OnUse对应的itemid减10000就是对应的monsterid
		local itemDef = ItemDefCsv:get(info.ID);
		local actorMapDef
		if itemDef.UseScript == "MobEgg_OnUse" then
			local monsterId = g_EggToMonster[info.ID]
			if monsterId == nil then monsterId = info.ID-10000 end
			actorMapDef = ModMgr:tryGetMonsterDef(monsterId)
		end
		
		if info.CopyID > 0 then
			ui_bkg:SetTexUV("img_icon_lignt_y")
		elseif def or actorMapDef then
			ui_bkg:SetTexUV("img_icon_lignt_dark")
		else
			ui_bkg:SetTexUV("img_icon_lignt")
		end
	
	
		if info.UnlockFlag > 0 then			--需解锁的物品
			if isItemUnlockByItemId(info.ID) then  --已经解锁
				unlock:Hide()
			else
				itemIcon:SetGray(true)
	
				unlock:Show();
				local proBkg 	= getglobal(unlock:GetName().."ProBkg");
				local pro 	= getglobal(unlock:GetName().."Pro");
				local lock 	= getglobal(unlock:GetName().."Lock");
				local count 	= getglobal(unlock:GetName().."Count");
				local hasNum = AccountManager:getAccountData():getAccountItemNum(info.InvolvedID);
				if hasNum > 0 then
					local needNum = info.ChipNum;
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
			unlock:Hide()
		end
	
		if info.ID > 0 then
			if info.ID == 11055 then
				local debug = 0;
			end
	
			if CheckAllServerBan(info.ID)  and AccountManager:getMultiPlayer() > 0 then
				ban:Show();
				itemIcon:SetGray(true);
			else
				ban:Hide();
			end
		end
	
		getglobal(cellname.."NewTag"):Hide();
		getglobal(cellname.."NewTagBG"):Hide();
		getglobal(cellname.."RedTag"):Hide();

		if info.CopyID > 0 and not InCreateNewItemTag(info.ID) and not AccountManager:getNoviceGuideState("guidenewitem")then
			table.insert(t_CreateNewItemTag, info.ID);
			getglobal(cellname.."RedTag"):Show();
		elseif not InClickItemVersionTag(info.ID) and info.Version ~= "" then
			if IsShowNewItemTag(tonumber(info.Version)) then
				--显示版本新道具标签
				getglobal(cellname.."NewTag"):Show();
				getglobal(cellname.."NewTagBG"):Show();
				if get_game_lang() == 4 then
					getglobal(cellname.."NewTagBG"):SetSize(65,25)
					getglobal(cellname.."NewTag"):SetSize(50,19)
				end
			end
		end
	end
end

-----------------------------------listview-------------------------------------------

--tab按钮
local m_SetFrameTabBtnInfo = {
	{nameID = 296, uiName="CreateBackpackFrameCropBtn", onClick=CreateBackpackFrameCropBtn_OnClick, },				--作物
	{nameID = 295, uiName="CreateBackpackFrameMachineBtn", onClick=CreateBackpackFrameMachineBtn_OnClick, },		--工具
	{nameID = 297, uiName="CreateBackpackFrameCommonBtn", onClick=CreateBackpackFrameCommonBtn_OnClick, },	--杂物
	{nameID = 298, uiName="CreateBackpackFrameMineralBtn", onClick=CreateBackpackFrameMineralBtn_OnClick, },			--方块
	{nameID = 20112, uiName="CreateBackpackFrameEditBtn", onClick=CreateBackpackFrameEditBtn_OnClick, },			--编辑方块 --改为开发者
};

function BackpackTabBtnTemplate_OnClick(id)
	local ui_backpackContent = getglobal("CreateBackpackFrameContent");
	local ui_searchContent = getglobal("CreateBackpackFrameSearchContent");

	if ui_backpackContent:IsShown() ==false then
		ui_backpackContent:Show();
	end

	if ui_searchContent:IsShown() then
		ui_searchContent:Hide();
	end
	if id then
		id = id;
	else
		id = this:GetClientID();
		CurSelectTabIndex = id;
		CurSelectCreateSubtype = 1;
	end
	if AccountManager and AccountManager:getCurWorldDesc() then
		--地图类型（冒险0 创造1 极限冒险2 创造转生存3 编辑4 编辑转玩法5 高级冒险6）
		local mapType = AccountManager:getCurWorldDesc().worldtype or 0
		-- statisticsGameEventNew(31033,id,mapType)
	end
	print("id = ", id);

	--切换按钮状态
	TemplateTabBtn2_SetState(m_SetFrameTabBtnInfo, id);

	-- 隐藏跳转wiki按钮
	getglobal("CreateBackpackFrameWiki"):Hide();

	if id == 0 then
		--初始化tab状态
		return;
	end

	--点击事件
	if m_SetFrameTabBtnInfo[id] then
		print("ok:", m_SetFrameTabBtnInfo[id].uiName);
		local onClick = m_SetFrameTabBtnInfo[id].onClick;

		if onClick then
			print("call onClick:");
			onClick(CurSelectCreateSubtype);
		else
			print("error: do not have onClick:");
		end
	end
end

function CreateBackpackFrame_OnUpdate()
	-- if CreateBackpackIndex > 0 then
	-- 	UpdateCreateItem();
	-- end
end

reLoadBackPackDevDef = false
function LoadCreateBackpackDef()
	t_CreateBackpackDef = {};
	t_CreateBackpackSubTypeDef ={};
	t_CreateBackpackChangeItem ={};

	t_AvatarPluginDef = {}
	local n = ItemDefCsv:getNum();

	local pluginIndex = 0
	for i=1, n do
		local itemDef = ItemDefCsv:get(i-1);
		if itemDef and itemDef.CreateType > 0 and check_item_can_load(itemDef) then --and (itemDef.CondUnlcokType == 0 or CurWorld:isUnlockItem(itemDef.CondUnlcokType))
			if gIsSingleGame and itemDef.UnlockFlag > 0 then
			else
				if t_CreateBackpackDef[itemDef.CreateType] == nil then t_CreateBackpackDef[itemDef.CreateType] = {} end
				--背包子分类数据单独保存
				local num = itemDef:getClassificationTypeNum();
				if num >0 then
					for i=0,(num -1) do
						if t_CreateBackpackSubTypeDef[itemDef.CreateType] == nil then t_CreateBackpackSubTypeDef[itemDef.CreateType]={} end
						local t_subTypeDef = t_CreateBackpackSubTypeDef[itemDef.CreateType];
						if t_subTypeDef[itemDef:getClassificationType(i)] ==nil then t_subTypeDef[itemDef:getClassificationType(i)] ={} end

						table.insert(t_subTypeDef[itemDef:getClassificationType(i)],itemDef);
					end
				end

				--修改原版插件单独保存
				if itemDef.CreateType ~= 5 then
					local def = ModMgr:tryGetItemDef(itemDef.ID);
					if def then  --区分材质包
						if AccountManager:getUin() == tonumber(def.ModDescInfo.author) then
							t_CreateBackpackChangeItem[itemDef.ID] = def;
						end
					end
				end	

				--自定义插件单独处理
				if itemDef.CopyID > 0 and itemDef.CreateType == 5 then
					if t_CreateBackpackSubTypeDef[itemDef.CreateType] == nil then t_CreateBackpackSubTypeDef[itemDef.CreateType]={} end
					local t_subTypeDef = t_CreateBackpackSubTypeDef[itemDef.CreateType];
					--Log("测试插件："..itemDef.Name.."，"..itemDef.Type..","..itemDef.CopyID)
					--local num = itemDef:getClassificationTypeNum();
					--if num >0 then
					--	for i =0,num-1 do
					--		Log(itemDef:getClassificationType(i))
					--	end
					--end

					--这里原来是有三个分类，但是现在不需要了
				-- 	if itemDef.Type ==1 or (itemDef.Type ==2 and (itemDef.CopyID <10100 or itemDef.CopyID >10110))then
				-- 		if t_subTypeDef[52] ==nil then t_subTypeDef[52] = {}; end
				-- 		table.insert(t_subTypeDef[52],itemDef)
				-- 	elseif itemDef.Type == 5 then
				--         local def = ModMgr:tryGetMonsterDef(itemDef.InvolvedID)
				--         if def and def.CopyID > 0 then
				--         	t_AvatarPluginDef[itemDef.ID] = def 
				--         end

				-- 		if t_subTypeDef[54] ==nil then t_subTypeDef[54] = {}; end
				-- 		table.insert(t_subTypeDef[54],itemDef)
				-- 	else
				-- 		if t_subTypeDef[53] ==nil then t_subTypeDef[53] = {}; end
				-- 		table.insert(t_subTypeDef[53],itemDef)
				-- 	end
					if itemDef.Type == 5 then
						local def = ModMgr:tryGetMonsterDef(itemDef.InvolvedID)
				        if def and def.CopyID > 0 then
				        	t_AvatarPluginDef[itemDef.ID] = def 
				        end
					end
					if t_subTypeDef[53] ==nil then t_subTypeDef[53] = {}; end
					table.insert(t_subTypeDef[53],itemDef)
				end
				table.insert(t_CreateBackpackDef[itemDef.CreateType], itemDef);
	
				--开发者工具映射
				if itemDef.ID and t_CreateBackpackDeveloperItem[itemDef.ID] then 
					local createType = 5
					if t_CreateBackpackSubTypeDef[createType] == nil then t_CreateBackpackSubTypeDef[createType]={} end
					local t_subTypeDef = t_CreateBackpackSubTypeDef[createType];
					if t_subTypeDef[51]==nil then t_subTypeDef[51] = {} end
					table.insert(t_subTypeDef[51],itemDef)
					table.insert(t_CreateBackpackDef[createType], itemDef);
				end
			end
		end
	end

	for k, v in pairs(t_CreateBackpackDef) do
		if #(v) > 1 then
			table.sort(v,function(a,b)
					if k==5 then
						if a.CopyID ~= b.CopyID then
							return a.CopyID < b.CopyID;
						end
					end
					if a.SortId == b.SortId then
						return a.ID < b.ID;
					else
				 		return a.SortId < b.SortId 
					end
				 end
				);
		end
	end

	for i= 1,5 do
		for k, v in pairs(t_CreateBackpackSubTypeDef[i]) do
			if #(v) > 1 then
				table.sort(v,
						function(a,b)
							if a.SortId == b.SortId then
								return a.ID < b.ID;
							else
								return a.SortId < b.SortId
							end
						end
				);
			end
		end
	end

	LoadCreateBackpackResourceDef()
	reLoadBackPackDevDef = false
	print("kekeke LoadCreateBackpackDef");
end

--资源模型
function LoadCreateBackpackResourceDef()
	local resClass = { MAP_MODEL_CLASS, RES_MODEL_CLASS }
	local resType = CUSTOM_MODEL_TYPE 
	local resTable = {}
	for k, v in pairs(resClass) do
		local foldersNum = ResourceCenter:getResClassNum(v, resType)
		if t_CreateBackpackSubTypeDef[5] == nil then t_CreateBackpackSubTypeDef[5]={} end
		local t_subTypeDef = t_CreateBackpackSubTypeDef[5];
		if t_subTypeDef[52] ==nil then t_subTypeDef[52] = {}; end
		--根据对应文件夹加载文件
		for i=1,foldersNum do
			local data = ResourceCenter:getClassInfo(v, i-1, resType)
			if data then
				local resNum = data:getModelNum()
				for j=1,resNum do
					--检测是否违规
					local resID = data:getNetIdentifier(j-1)
					--资源模型文件名总库和当前地图一样，用来做排重
					local fileName = data:getModelName(j-1)  
					if (not IsResourceInBanResList(resID)) and fileName ~= "" then
						local id =0
						id = GetResourceModelGridClientID(fileName,v,resType,i-1,false)
						if v==MAP_MODEL_CLASS then
							--folderIndex是模型所在文件夹的下标，modelIndex是模型在文件中的下标
							table.insert(t_subTypeDef[52],{ID = id, resType=CUSTOM_MODEL_TYPE, resClass=v, itemName=fileName, folderIndex=i-1, modelIndex=j-1})
							table.insert(t_CreateBackpackDef[5],{ID = id, resType=CUSTOM_MODEL_TYPE, resClass=v, itemName=fileName, folderIndex=i-1, modelIndex=j-1})
							resTable[fileName] = true
						elseif not resTable[fileName] then
							table.insert(t_subTypeDef[52],{ID = id, resType=CUSTOM_MODEL_TYPE, resClass=v, itemName=fileName, folderIndex=i-1, modelIndex=j-1})
							table.insert(t_CreateBackpackDef[5],{ID = id, resType=CUSTOM_MODEL_TYPE, resClass=v, itemName=fileName, folderIndex=i-1, modelIndex=j-1})
						end					
					end
				end
			end
		end
	end	
	
end

--获取资源ID 
function GetResourceModelGridClientID(fileName,resClass,resType,folderIndex,isCopy)
	--如果当前地图没有，就拷贝一份到当前地图
	if resClass == RES_MODEL_CLASS and isCopy then
		if fileName ~= "" and ResourceCenter:checkUploadedResLocalStatus(RES_MODEL_CLASS, fileName, resType) and not CustomModelMgr:getCustomItem(fileName) then
			ResourceCenter:moveResToClass( RES_MODEL_CLASS, MAP_MODEL_CLASS, folderIndex, 0, fileName, resType)
		end
	end

	local customModel = nil;
	local id = -1;
	local customItem = CustomModelMgr:getCustomItem(fileName)
	if customItem then  -- modelType -2除生物模型之外
		if customItem.type >= FULLY_BLOCK_MODEL then
			if customItem.type == FULLY_ACTOR_MODEL then
				id=customItem.involvedid
			else	
				id=customItem.itemid
			end
		elseif customItem.type <= IMPORT_MODEL_MAX and customItem.type >= IMPORT_BLOCK_MODEL then -- 高比例模型
			if customItem.type == IMPORT_ACTOR_MODEL then
				id=customItem.involvedid
			else	
				id=customItem.itemid
			end
		else
			if customItem.type == ACTOR_MODEL then
				local actorModelData = CustomModelMgr:findCustomActorModelData(MAP_MODEL_CLASS, fileName);
				if IsRoomClient() or actorModelData then
					id=customItem.involvedid
				end
			else
				customModel = CustomModelMgr:getCustomModel(MAP_MODEL_CLASS, fileName);
				if IsRoomClient() then
					id=customItem.itemid
				elseif customModel and customModel:getItemID() > 0 then
					id=customItem.itemid
				end
			end
		end
	end
	return id;
end

function CreateBackpackFrame_OnEvent()
	if arg1 == "GIE_LEAVE_WORLD" then
		CurSelectCreateType = 1;
		CurSelectCreateSubtype = 1;
		CurSelectTabIndex = 1;
		CurSelectCreateSubtype = 1;
		reLoadBackPackDevDef = false
	elseif arg1 == "GIE_ENTER_WORLD" then
		reLoadBackPackDevDef = false
	end
end

function loadUserClientNewItemPro()
	local itemList = getkv("bp_new_item") or {};
	if itemList ~= nil then
		t_ClickItemVersionTag = itemList;
	end
end

function CreateBackpackFrame_OnShow()
	if reLoadBackPackDevDef and CurWorld and CurWorld:isGameMakerMode() then
		LoadCreateBackpackDef()
	end
	HideAllFrame("CreateBackpackFrame", true);
	
	--记住上次打开的页签，离开地图时恢复默认
	BackpackTabBtnTemplate_OnClick(CurSelectTabIndex);

	--press_btn(m_SetFrameTabBtnInfo[CurSelectTabIndex].uiName);

	--Wiki   ---暂时屏蔽
	getglobal("CreateBackpackFrameWikiRich"):SetText("#L" .. GetS(1000405))

	SetCreateShortcutCheckGrid(nil);
	CreateBackpackIndex = 1;
	HideCreateBoxItemBoxTexture();
	BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,CurSelectCreateSubtype);
	--读取新版本道具
	loadUserClientNewItemPro() 
	-- UpdateCreateItem();
	SetSubTypeRedTag();
	SetCreateTypeRedTag();

	SetEditTabRedTag()

	UpdateCreateBackpackFrameShortcutAllGrid();
	if CurWorld and CurWorld:isGameMakerMode() and (AccountManager:getMultiPlayer() == 0 or IsRoomOwner() or UpdateCSBackPackFrameEditBtn())then
		getglobal("CreateBackpackFrameEditBtn"):Show();
	else
		getglobal("CreateBackpackFrameEditBtn"):Hide();
	end
	if CurWorld and CurWorld:isGodMode() then
		getglobal("CreateBackpackFrameSurvivalPackBtn"):Show();
		--喷漆道具未点击时，SurvivalPackBtn显示红点
		local uin = AccountManager:getUin()
		if getkv("BackPackPaint_Onlick"..uin) then
			getglobal("CreateBackpackFrameSurvivalPackBtnRedTag"):Hide();
		else
			getglobal("CreateBackpackFrameSurvivalPackBtnRedTag"):Show();
		end
	else
		getglobal("CreateBackpackFrameSurvivalPackBtn"):Hide();
	end

	if not getglobal("CreateBackpackFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end

	searchMgrBackpackInit();

	if isEducationalVersion or gIsSingleGame then
		getglobal("CreateBackpackFrameStashBtn"):Hide();
	end

	--MiniBase迷你基地隐藏仓库按钮入口
	if MiniBaseManager:isMiniBaseGame() then
		getglobal("CreateBackpackFrameStashBtn"):Hide();
	end

	if isEducationalVersion then
		HideWebView_Edu();
	end
end

-- 租赁服 判断是否是房主、超管、管理员
function UpdateCSBackPackFrameEditBtn()
	if ROOM_SERVER_RENT ~= ClientMgr:getRoomHostType() then
		return false
	end

	local myAuthority = PermitsCallModuleScript("getCSAuthority",AccountManager:getUin())
	if myAuthority.Type > CS_AUTHORITY_NULL and myAuthority.Type < CS_AUTHORITY_NORMAL_MEMBER then
		return true;
	end
	return false;
end

function UpdateCreateBackpackFrameShortcutAllGrid()
	for i=1, MAX_SHORTCUT do
		UpdateCreateBackpackFrameShortcutOneGrid(ClientBackpack:getShortcutStartIndex()+i-1)
	end
end

function UpdateCreateBackpackFrameShortcutOneGrid(grid_index)
	local idx = grid_index + 1 - ClientBackpack:getShortcutStartIndex();
	if idx > 0 and idx <= 8 then 
		local icon = getglobal("CreateBackpackFrameShortcutGrid"..idx.."Icon");
		local num = getglobal("CreateBackpackFrameShortcutGrid"..idx.."Count");	
		local durBkg = getglobal("CreateBackpackFrameShortcutGrid"..idx.."DurBkg");
		local dur = getglobal("CreateBackpackFrameShortcutGrid"..idx.."Duration");

		UpdateGridContent(icon, num, durBkg, dur, grid_index);

		local ban = getglobal("CreateBackpackFrameShortcutGrid"..idx.."Ban");
		CheckItemIsBan(grid_index, ban, icon);
	end
end

function GetItemDefTable2CreateType(type)
	local createType = CurSelectCreateType;
	if type then
		createType = type;
	end

	if t_CreateBackpackDef == nil then
		print('kekeke t_CreateBackpackDef is nil');
		LoadCreateBackpackDef();
	end
	
	print('kekeke GetItemDefTable2CreateType', createType);
	return t_CreateBackpackDef[createType];

	--[[
	local t_itemDef = {};
	local n = ItemDefCsv:getNum();

	local createType = CurSelectCreateType;
	if type then
		createType = type;
	end
	for i=1, n do
		local itemDef = ItemDefCsv:get(i-1);
		if itemDef ~= nil and itemDef.CreateType == createType 
		   and (itemDef.CondUnlcokType == 0 or CurWorld:isUnlockItem(itemDef.CondUnlcokType)) then 
			table.insert(t_itemDef, itemDef);
		end
	end

	if #(t_itemDef) > 1 then
		table.sort(t_itemDef,
			 function(a,b)
				if a.SortId == b.SortId then
					return a.ID < b.ID;
				else
			 		return a.SortId < b.SortId 
				end
			 end
			);
	end

	return t_itemDef;
	]]
end

function InCreateNewItemTag(key)
	for i=1, #(t_CreateNewItemTag) do
		if t_CreateNewItemTag[i] == key then
			return true;
		end
	end

	return false;
end

function RemoveCreateNewItemTag(key)
	for i=1, #(t_CreateNewItemTag) do
		if t_CreateNewItemTag[i] == key then
			table.remove(t_CreateNewItemTag, i);
			return;
		end
	end
end

function InCreateBackPackNewItemVersionTag(key)
	for i=1, #(t_CreateBackPackNewItemVersionTag) do
		if t_CreateBackPackNewItemVersionTag[i] == key then
			return true;
		end
	end

	return false;
end

function RemoveCreateBackPackNewItemVersionTag(key)
	for i=1, #(t_CreateBackPackNewItemVersionTag) do
		if t_CreateBackPackNewItemVersionTag[i] == key then
			if not InClickItemVersionTag(t_CreateBackPackNewItemVersionTag[i]) then
				table.insert(t_ClickItemVersionTag,t_CreateBackPackNewItemVersionTag[i]);
			end
			table.remove(t_CreateBackPackNewItemVersionTag, i);
			return;
		end
	end
end

function InClickItemVersionTag(key)
	for i=1, #(t_ClickItemVersionTag) do
		if t_ClickItemVersionTag[i] == key then
			return true;
		end
	end

	return false;
end

function IsShowNewItemTag(version)
	--只显示最近3个版本
	local bit = require("bit");
	local myVer = bit.band(bit.rshift(ClientMgr:clientVersion(), 8), 0xff)
	if myVer - version <= 2 and myVer - version >=0 then
		return true;
	else
		return false;
	end
end

function SetSubTypeRedTag()

	for i=1,5 do
		getglobal("CreateBackpackFrameContentSubtype"..i.."RedTag"):Hide();
	end

	for i = 1, #t_CreateBackPackNewItemVersionTag do
		local def = DefMgr:getItemDef(t_CreateBackPackNewItemVersionTag[i])
		if def == nil then return end 
		local num = def:getClassificationTypeNum();
		for j = 0, (num-1) do
			local subType = def:getClassificationType(j);
			local beforeNum = tonumber(string.sub(subType,1,1));
			local lastNum = tonumber(string.sub(subType,-1,-1));

			if beforeNum == 1 and CurSelectCreateType == 1 then
				getglobal("CreateBackpackFrameContentSubtype"..(lastNum+1).."RedTag"):Show();
				getglobal("CreateBackpackFrameContentSubtype1RedTag"):Show();
			elseif beforeNum == 2 and CurSelectCreateType == 2 then
				getglobal("CreateBackpackFrameContentSubtype"..(lastNum+1).."RedTag"):Show();
				getglobal("CreateBackpackFrameContentSubtype1RedTag"):Show();
			elseif beforeNum == 3 and CurSelectCreateType == 3 then
				getglobal("CreateBackpackFrameContentSubtype"..(lastNum+1).."RedTag"):Show();
				getglobal("CreateBackpackFrameContentSubtype1RedTag"):Show();
			elseif  beforeNum == 4 and CurSelectCreateType == 4 then
				getglobal("CreateBackpackFrameContentSubtype"..(lastNum+1).."RedTag"):Show();
				getglobal("CreateBackpackFrameContentSubtype1RedTag"):Show();
            elseif  beforeNum == 5 and CurSelectCreateType == 5 then
                getglobal("CreateBackpackFrameContentSubtype"..(lastNum+1).."RedTag"):Show();
                getglobal("CreateBackpackFrameContentSubtype1RedTag"):Show();
			end
		end
	end
end

function SetCreateTypeRedTag()
	t_CreateTypeRedTag.num1 =0;
	t_CreateTypeRedTag.num2 =0;
	t_CreateTypeRedTag.num3 =0;
	t_CreateTypeRedTag.num4 =0;
    t_CreateTypeRedTag.num5 =0;
	
	for i = 1, #t_CreateBackPackNewItemVersionTag do
		local def = DefMgr:getItemDef(t_CreateBackPackNewItemVersionTag[i])
		if def then
			local type = def.CreateType;
			if type == 1 then
				t_CreateTypeRedTag.num1 = t_CreateTypeRedTag.num1+1;
			elseif type == 2 then
				t_CreateTypeRedTag.num2 = t_CreateTypeRedTag.num2+1;
			elseif type == 3 then
				t_CreateTypeRedTag.num3 = t_CreateTypeRedTag.num3+1;
			elseif type == 4 then
				t_CreateTypeRedTag.num4 = t_CreateTypeRedTag.num4+1;
			elseif type == 5 then
				t_CreateTypeRedTag.num5 = t_CreateTypeRedTag.num5+1;
			end
		end
	end

	if t_CreateTypeRedTag.num1 > 0 then
		getglobal("CreateBackpackFrameCropBtnBigRedTag"):Show();
		getglobal("CreateBackpackFrameCropBtnNewNumberTag"):Show();
		getglobal("CreateBackpackFrameCropBtnNewNumberTag"):SetText(t_CreateTypeRedTag.num1);
	else
		getglobal("CreateBackpackFrameCropBtnBigRedTag"):Hide();
		getglobal("CreateBackpackFrameCropBtnNewNumberTag"):Hide();
	end
	if t_CreateTypeRedTag.num2 > 0 then
		getglobal("CreateBackpackFrameMachineBtnBigRedTag"):Show();
		getglobal("CreateBackpackFrameMachineBtnNewNumberTag"):Show();
		getglobal("CreateBackpackFrameMachineBtnNewNumberTag"):SetText(t_CreateTypeRedTag.num2);
	else
		getglobal("CreateBackpackFrameMachineBtnBigRedTag"):Hide();
		getglobal("CreateBackpackFrameMachineBtnNewNumberTag"):Hide();
	end

	if t_CreateTypeRedTag.num3 > 0 then
		getglobal("CreateBackpackFrameCommonBtnBigRedTag"):Show();
		getglobal("CreateBackpackFrameCommonBtnNewNumberTag"):Show();
		getglobal("CreateBackpackFrameCommonBtnNewNumberTag"):SetText(t_CreateTypeRedTag.num3);
	else
		getglobal("CreateBackpackFrameCommonBtnBigRedTag"):Hide();
		getglobal("CreateBackpackFrameCommonBtnNewNumberTag"):Hide();
	end
	if t_CreateTypeRedTag.num4 > 0 then
		getglobal("CreateBackpackFrameMineralBtnBigRedTag"):Show();
		getglobal("CreateBackpackFrameMineralBtnNewNumberTag"):Show();
		getglobal("CreateBackpackFrameMineralBtnNewNumberTag"):SetText(t_CreateTypeRedTag.num4);
	else
		getglobal("CreateBackpackFrameMineralBtnBigRedTag"):Hide();
		getglobal("CreateBackpackFrameMineralBtnNewNumberTag"):Hide();
	end
    if t_CreateTypeRedTag.num5 > 0 then
        getglobal("CreateBackpackFrameEditBtnBigRedTag"):Show();
        getglobal("CreateBackpackFrameEditBtnNewNumberTag"):Show();
        getglobal("CreateBackpackFrameEditBtnNewNumberTag"):SetText(t_CreateTypeRedTag.num5);
    else
        getglobal("CreateBackpackFrameEditBtnBigRedTag"):Hide();
        getglobal("CreateBackpackFrameEditBtnNewNumberTag"):Hide();
    end

end

function SetEditTabRedTag()
	local hasNew = false;
	local t_itemDef = GetItemDefTable2CreateType(5);
	for i=1, #(t_itemDef) do
		if t_itemDef[i].CopyID and t_itemDef[i].CopyID > 0 then
			hasNew = true;
			break;
		end
	end

	if hasNew and not InCreateNewItemTag("edittab") and not AccountManager:getNoviceGuideState("guideedittab") then
		table.insert(t_CreateNewItemTag, "edittab");
		getglobal("CreateBackpackFrameEditBtnRedTag"):Show();
	else
		getglobal("CreateBackpackFrameEditBtnRedTag"):Hide();
	end
end

function UpdateCreateItem()
	updateBackPackList()
 --    local t_itemDef;
 --    if CurSelectCreateType>0 and CurSelectCreateSubtype>0 then
 --        local index = CurSelectCreateType*10 + (CurSelectCreateSubtype-1);
 --        if index == CurSelectCreateType*10 then
 --            t_itemDef = GetItemDefTable2CreateType();
 --        else
 --            local t_subTypeDef = t_CreateBackpackSubTypeDef[CurSelectCreateType];
 --            t_itemDef = t_subTypeDef[index];
 --        end
 --    end

	-- --local t_itemDef = GetItemDefTable2CreateType();
	-- if t_itemDef == nil then
	-- 	for i=CreateBackpackIndex, CREATE_BACKPACK_MAX do
	-- 		local createItem = getglobal("CreateBoxItem"..i);
	-- 		createItem:Hide();
	-- 	end
	-- 	getglobal("CreateBackpackFrameContentNull"):Show();
	-- 	getglobal("CreateBackpackFrameContentNullTitle"):Show();
	-- 	return
	-- else
	-- 	getglobal("CreateBackpackFrameContentNull"):Hide();
	-- 	getglobal("CreateBackpackFrameContentNullTitle"):Hide();
	-- end

	-- print('kekeke', t_createBackpackLabelInfo[CurSelectCreateType].loadindex);
	-- print("UpdateCreateItem(): t_CreateBackpackChangeItem = ", t_CreateBackpackChangeItem);
	-- for i=CreateBackpackIndex, CREATE_BACKPACK_MAX do
	-- 	local createItem = getglobal("CreateBoxItem"..i);
	-- 	local isload = true;
	-- 	if t_createBackpackLabelInfo[CurSelectCreateType].loadindex > 0 and i >= t_createBackpackLabelInfo[CurSelectCreateType].loadindex + 12 then
	-- 		isload = false;
	-- 	end
	-- 	if i <= #(t_itemDef) and isload then
	-- 		-- print("UpdateCreateItem(): i = ", i);
	-- 		-- print("UpdateCreateItem(): t_itemDef[i] = ", t_itemDef[i]);
	-- 		-- print("UpdateCreateItem(): ", t_itemDef[i].Name, t_itemDef[i].ID, t_itemDef[i].CopyID);
	-- 		createItem:Show();
	-- 		local itemIcon 	= getglobal("CreateBoxItem"..i.."Icon");
	-- 		SetItemIcon(itemIcon, t_itemDef[i].ID);

	-- 		local def = t_CreateBackpackChangeItem[t_itemDef[i].ID];
	-- 		local ui_bkg = getglobal("CreateBoxItem"..i.."Bkg");
	-- 		if t_itemDef[i].CopyID>0 then
	-- 			ui_bkg:SetTexUV("img_icon_lignt_y");
	-- 		elseif def then
	-- 			ui_bkg:SetTexUV("img_icon_lignt_dark");
	-- 		else
	-- 			ui_bkg:SetTexUV("img_icon_lignt");
	-- 		end
			
	-- 		itemIcon:SetGray(false);
	-- 		createItem:SetClientID(t_itemDef[i].ID);			--记录下物品的ID

	-- 		local unlock = getglobal("CreateBoxItem"..i.."Unlock");
	-- 		if t_itemDef[i].UnlockFlag > 0 then			--需解锁的物品
	-- 			if AccountManager:getAccountData():isItemUnlock(t_itemDef[i].UnlockFlag) then  --已经解锁
	-- 				unlock:Hide();
	-- 			else
	-- 				itemIcon:SetGray(true);

	-- 				unlock:Show();
	-- 				local proBkg 	= getglobal(unlock:GetName().."ProBkg");
	-- 				local pro 	= getglobal(unlock:GetName().."Pro");
	-- 				local lock 	= getglobal(unlock:GetName().."Lock");
	-- 				local count 	= getglobal(unlock:GetName().."Count");
	-- 				local hasNum = AccountManager:getAccountData():getAccountItemNum(t_itemDef[i].InvolvedID);
	-- 				if hasNum > 0 then
	-- 					local needNum = t_itemDef[i].ChipNum;
	-- 					local radio = hasNum/needNum;
	-- 					if hasNum > needNum then
	-- 						radio = 1.0;
	-- 					end
						
	-- 					pro:ChangeTexUVWidth(75*radio);
	-- 					pro:SetSize(75*radio, 18);

	-- 					lock:Hide();
	-- 					proBkg:Show();
	-- 					pro:Show();

	-- 					local text = hasNum.."/"..needNum;
	-- 					count:SetText(text);
	-- 				else
	-- 					proBkg:Hide();
	-- 					pro:Hide();
	-- 					lock:Hide();
	-- 					count:SetText("");
	-- 				end
	-- 			end			
	-- 		else
	-- 			unlock:Hide();
	-- 		end

	-- 		if t_itemDef[i].ID > 0 then
	-- 			local ban = getglobal("CreateBoxItem"..i.."Ban");
	-- 			if t_itemDef[i].ID == 11055 then
	-- 				local debug = 0;
	-- 			end
	-- 			if CheckAllServerBan(t_itemDef[i].ID)  and AccountManager:getMultiPlayer() > 0 then
	-- 				ban:Show();
	-- 				itemIcon:SetGray(true);
	-- 			else
	-- 				ban:Hide();
	-- 			end
	-- 		end

	-- 		if t_itemDef[i].CopyID > 0 and not InCreateNewItemTag(t_itemDef[i].ID) and not AccountManager:getNoviceGuideState("guidenewitem")then
	-- 			table.insert(t_CreateNewItemTag, t_itemDef[i].ID);
	-- 			getglobal("CreateBoxItem"..i.."RedTag"):Show();
	-- 		elseif not InClickItemVersionTag(t_itemDef[i].ID) and t_itemDef[i].Version ~= "" then
	-- 			if IsShowNewItemTag(tonumber(t_itemDef[i].Version)) then
	-- 				--显示版本新道具标签
	-- 				getglobal("CreateBoxItem"..i.."NewTag"):Show();
	-- 				getglobal("CreateBoxItem"..i.."NewTagBG"):Show();
	-- 				if get_game_lang() == 4 then
	-- 					getglobal("CreateBoxItem"..i.."NewTagBG"):SetSize(65,25)
	-- 					getglobal("CreateBoxItem"..i.."NewTag"):SetSize(50,19)
	-- 				end
	-- 			end
	-- 		else
	-- 			getglobal("CreateBoxItem"..i.."NewTag"):Hide();
	-- 			getglobal("CreateBoxItem"..i.."NewTagBG"):Hide();
	-- 			getglobal("CreateBoxItem"..i.."RedTag"):Hide();

	-- 		end

	-- 	else			
	-- 		createItem:Hide();
	-- 	end
	-- end

	-- loadNewItemInfo();

	-- SetSubTypeRedTag();
	-- SetCreateTypeRedTag();

	-- if t_createBackpackLabelInfo[CurSelectCreateType].loadindex > 0 then
	-- 	CreateBackpackIndex = t_createBackpackLabelInfo[CurSelectCreateType].loadindex + 12;
	-- 	t_createBackpackLabelInfo[CurSelectCreateType].loadindex = CreateBackpackIndex;
	-- 	if CreateBackpackIndex > #(t_itemDef) then
	-- 		CreateBackpackIndex = 0;
	-- 		t_createBackpackLabelInfo[CurSelectCreateType].loadindex = 0;
	-- 	end
	-- else
	-- 	CreateBackpackIndex = 0;
	-- end

	-- local n = math.ceil(#(t_itemDef) / 11);
	-- local plane 	= getglobal("CreateBoxPlane");
	-- if n > 5 then
	-- 	plane:SetSize(960, n*85);
	-- else
	-- 	plane:SetSize(960, 460);
	-- end
end

function loadNewItemInfo()
	local num = ItemDefCsv:getNum();
	for i = 1, num do
		local tempItem = ItemDefCsv:get(i-1);
		if tempItem and tempItem.CreateType > 0 then
			if not InClickItemVersionTag(tempItem.ID)  and not InCreateBackPackNewItemVersionTag(tempItem.ID) and tempItem.Version ~= ""  and check_item_can_load(tempItem) then
				if IsShowNewItemTag(tonumber(tempItem.Version))  then
					table.insert(t_CreateBackPackNewItemVersionTag, tempItem.ID);
				end
			end
		end
	end
end

function UpdateCreateItem2UnLock(itemId)
	local itemDef = ItemDefCsv:get(itemId);
	if itemDef == nil then return end

	local listview = getglobal("CreateBox")
	for i=1, CREATE_BACKPACK_MAX do
		local createItem = listview:cellAtIndex(i-1)--getglobal("CreateBoxItem"..i);
		-- if itemId == createItem:GetClientID() then
		if createItem and itemId == createItem:GetClientUserData(0) then
			local itemIcon 	= getglobal(createItem:GetName().."Icon");
			itemIcon:SetGray(false);
			local unlock = getglobal(createItem:GetName().."Unlock");
			if itemDef.UnlockFlag > 0 then			--需解锁的物品
				if isItemUnlockByItemId(itemDef.ID) then  --已经解锁
					unlock:Hide();
				else
					itemIcon:SetGray(true);

					unlock:Show();
					local proBkg 	= getglobal(unlock:GetName().."ProBkg");
					local pro 	= getglobal(unlock:GetName().."Pro");
					local lock 	= getglobal(unlock:GetName().."Lock");
					local count 	= getglobal(unlock:GetName().."Count");
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
						lock:Show();
						count:SetText("");
					end
				end			
			else
				unlock:Hide();
			end
		end
	end		
end

function UpdateCreateBackpackLabelBtnState(btnName)
	local createBox 	= getglobal("CreateBox");
	createBox:resetOffsetPos();
	for i=1, #(t_createBackpackLabelInfo) do
		local info = t_createBackpackLabelInfo[i];
		local btn = getglobal(info.name);
		btn:SetChecked(false);
		local nameFont = getglobal(info.name.."Name");		
		if info.name == btnName then
			btn:Disable();
			nameFont:SetTextColor(98, 65, 48);
			nameFont:SetShadowColor(0, 0, 0);
			
			--getglobal("CreateBackpackFrameTitle"):SetText(GetS(info.nameId));
			--getglobal("CreateBackpackFrameTitleIcon"):SetTexUV(info.uvname);
		else
			btn:Enable();
			nameFont:SetTextColor(142, 135, 119);
			nameFont:SetShadowColor(98, 65, 48);
		end
	end

	if getglobal("MItemTipsFrame"):IsShown() then
		getglobal("MItemTipsFrame"):Hide();
	end
end

function HideCreateBoxItemBoxTexture(gridName)
	local cell = nil
	local listview = getglobal("CreateBox")
	for i=1, CREATE_BACKPACK_MAX do 
		cell = listview:cellAtIndex(i-1)
		if cell then
			local boxTexture = getglobal(cell:GetName().."Check");
			boxTexture:Hide();		
		end
	end
	selectCreateItemId = -1;

	if gridName ~= nil then
		local check = getglobal(gridName.."Check");
		check:Show();

		selectCreateItemId = getglobal(gridName):GetClientUserData(0)
	end
end

function HideBPSearchBoxItemBoxTexture(gridName)
	for i=1, SearchMgr.GetSearchNum() do
		local boxTexture = getglobal("BPSearchBoxItem"..i.."Check");
		boxTexture:Hide();
	end
	selectCreateItemId = -1;

	if gridName ~= nil then
		local check = getglobal(gridName.."Check");
		check:Show();
	end
end

function SetCreateShortcutCheckGrid(gridName)
	for i=1, MAX_SHORTCUT do
		local check = getglobal("CreateBackpackFrameShortcutGrid"..i.."Check");
		check:Hide();
	end

	if gridName ~= nil then
		local check = getglobal(gridName.."Check");
		check:Show();
	end
end

function CreateBackpackFrame_OnHide()
	if CreateBackPack_Need_EndDrag then
		UIEndDrag("MousePickItem");
	else
		CreateBackPack_Need_EndDrag = true;
	end
	ShowMainFrame();
	if not getglobal("CreateBackpackFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
	if getglobal("MItemTipsFrame"):IsShown() then
		getglobal("MItemTipsFrame"):Hide();
	end
	setkv("bp_new_item",t_ClickItemVersionTag);

	if isEducationalVersion then
		ShowWebView_Edu()
	end
end

function CreateBackpackFrame_OnMouseDown()
	UIEndDrag("MousePickItem");
end

function CreateBackpackFrameCloseBtn_OnClick()
	getglobal("CreateBackpackFrame"):Hide();
end

function CreateBackpackFrameStashBtn_OnClick()
	SearchMgr.CloseCreateBackPack();

	ShopJumpTabView(8)

	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
		standReportEvent("1003", "MINI_TOOL_BAR_BAG", "StorageButton", "click") 
	else
		standReportEvent("1001", "MINI_TOOL_BAR_BAG", "StorageButton", "click") 
	end

	
end

function CreateBackpackFrameSurvivalPackBtn_OnClick()
	CreateBackPack_Need_EndDrag = false;
	CreateBackpackFrameCloseBtn_OnClick();
	getglobal("RoleAttrFrame"):Show();
end

function CreateBackpackFrameCropBtn_OnClick()
	CurSelectCreateType = 1;
	CreateBackpackIndex = 1;
	CurSelectCreateSubtype = 1;
	threadpool:work(
			SearchMgr.CloseCreateBackPack(),
			HideCreateBoxItemBoxTexture(),
			UpdateCreateBackpackLabelBtnState("CreateBackpackFrameCropBtn"),
			BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,CurSelectCreateSubtype),
			UpdateCreateItem()
	)

end

function CreateBackpackFrameMachineBtn_OnClick()
	CurSelectCreateType = 2;
	CreateBackpackIndex = 1;
	CurSelectCreateSubtype=1
	threadpool:work(
			SearchMgr.CloseCreateBackPack(),
			HideCreateBoxItemBoxTexture(),
			UpdateCreateBackpackLabelBtnState("CreateBackpackFrameMachineBtn"),
			BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,CurSelectCreateSubtype),
			UpdateCreateItem()
	)

end

function CreateBackpackFrameCommonBtn_OnClick()
	CurSelectCreateType = 3;
	CreateBackpackIndex = 1;
	CurSelectCreateSubtype=1;

	threadpool:work(
			SearchMgr.CloseCreateBackPack(),
			HideCreateBoxItemBoxTexture(),
			UpdateCreateBackpackLabelBtnState("CreateBackpackFrameCommonBtn"),
			BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,CurSelectCreateSubtype),
			UpdateCreateItem()
	)

end

function CreateBackpackFrameMineralBtn_OnClick()
	CurSelectCreateType = 4;
	CreateBackpackIndex = 1;
	CurSelectCreateSubtype=1;
	threadpool:work(
			SearchMgr.CloseCreateBackPack(),
			HideCreateBoxItemBoxTexture(),
			UpdateCreateBackpackLabelBtnState("CreateBackpackFrameMineralBtn"),
			BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,CurSelectCreateSubtype),
			UpdateCreateItem()
	)

end

function CreateBackpackFrameEditBtn_OnClick()
	CurSelectCreateType = 5;
	CreateBackpackIndex = 1;
	CurSelectCreateSubtype=1;
	threadpool:work(
			SearchMgr.CloseCreateBackPack(),
			HideCreateBoxItemBoxTexture(),
			UpdateCreateBackpackLabelBtnState("CreateBackpackFrameEditBtn"),
			BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,CurSelectCreateSubtype),
			UpdateCreateItem(),
			RemoveCreateNewItemTag("edittab")
	)
	if not AccountManager:getNoviceGuideState("guideedittab") then
		AccountManager:setNoviceGuideState("guideedittab", true);
	end
	getglobal(this:GetName().."RedTag"):Hide();
end

function GetShortcutItem(itemId, btnName)
	for i=1, MAX_SHORTCUT do
		local grid_index 	= ClientBackpack:getShortcutStartIndex() + i - 1;
		local shortcutItemId	= ClientBackpack:getGridItem(grid_index);
		if itemId == shortcutItemId then
			CurMainPlayer:setCurShortcut(i-1);
			local btn = getglobal("CreateBackpackFrameShortcutGrid"..i);
			if btnName and string.find(btnName, "MapModelLibFrameShortcut") then
				btn = getglobal("MapModelLibFrameShortcutGrid"..i);
			elseif btnName and string.find(btnName, "ResourceCenterShortcut") then
				btn = getglobal("ResourceCenterShortcutGrid"..i);
			end
			return btn:GetName();
		end 
	end
	return nil;
end

function BP_SubTypeBtnTemplate_OnClick()
    local id = this:GetClientID();
    CurSelectCreateSubtype =id ;
    CreateBackpackIndex = 1;
    UpdateCreateItem();
	BP_SetCreateBackpackSubtypeBtnState(CurSelectCreateType,id);
	if CurSelectCreateType==5 then
		if AccountManager and AccountManager:getCurWorldDesc() then
			--地图类型（冒险0 创造1 极限冒险2 创造转生存3 编辑4 编辑转玩法5 高级冒险6）
			local mapType = AccountManager:getCurWorldDesc().worldtype or 0
			-- statisticsGameEventNew(31034,id,mapType)
		end
	end
end

function BP_SetCreateBackpackSubtypeBtnState(type,subtype)
    local ui_name = "CreateBackpackFrameContentSubtype";
    local t_subTypeInfo = t_subTypeLabelInfo[type];
    for i = 1,5 do
        local btn_checkPic = getglobal(ui_name..i.."CheckedBG")
        local btn_pushedPic = getglobal(ui_name..i.."PushedBG")
        local text_title = getglobal(ui_name..i.."Title")
        local tex_Icon = getglobal(ui_name..i.."Icon")

		if t_subTypeInfo and t_subTypeInfo[i] then
			getglobal(ui_name..i):Show()
            text_title:SetText(GetS(t_subTypeInfo[i].title));

			if type ==4  and i == 2 then
				-- tex_Icon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
				-- tex_Icon:SetTexUV("ico_dixing");
				SetItemIcon(tex_Icon, t_subTypeInfo[i].iconName);
			elseif type ==4  and i == 3 then
				tex_Icon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
				tex_Icon:SetTexUV("ico_ziyuan");
			elseif type ==2  and i == 1 then
				tex_Icon:SetTexture("items/icon11014.png", true)
			elseif type ==2  and i == 5 then
				tex_Icon:SetTexture("items/icon15002.png", true)
			else
				SetItemIcon(tex_Icon, t_subTypeInfo[i].iconName);
			end
		else
			getglobal(ui_name..i):Hide()
        end
        if subtype == i then
            btn_checkPic:Show();
            btn_pushedPic:Hide();
        else
            btn_checkPic:Hide();
            btn_pushedPic:Show();
        end
    end

end


--for GiftPackFrame 
local selectIdx = 0
local gItemID = 0
local gPackDef = nil
local gOpenType = 0 --0 is just look , 1 is open
local gPackShorCutIdx = 0
local gPackListData = {}
function GiftPackFrame_OnLoad()
	-- body
end
function GiftPackFrame_OnHide()
	if not getglobal("GiftPackFrame"):IsRehide() then
       ClientCurGame:setOperateUI(false);
    end

end
function GiftPackFrame_OnShow()
	-- body
	local color = "#c15a815"
	local costdescLab = getglobal("GiftPackFrameCostDesc");
	local str = ""
	if gPackDef.iNeedCostItem ~= 0 then
		local def = ItemDefCsv:getAutoUseForeignID(math.floor(gPackDef.iCostItemInfo/1000))
		local costname = def and def.Name or "土块"
		local costnum = gPackDef.iCostItemInfo%1000
		local costinfo = color..costname.."*"..costnum.."#n"

		if gPackDef.iPackType == 0 then
			str = GetS(21771, costinfo)
		else
			str = GetS(21773, costinfo, gPackDef.iMaxOpenNum)
		end
	else
		if gPackDef.iPackType == 0 then
			str = GetS(21770)
		else
			str = GetS(21772, gPackDef.iMaxOpenNum)
		end
	end
	costdescLab:setCenterLine(true)
	costdescLab:SetText(str, 152, 108, 85)

	--开启包裹界面的标题读包裹的名称
	local itemDef = ItemDefCsv:getAutoUseForeignID(gItemID)
	if itemDef then
		getglobal("GiftPackFrameTitle"):SetText(itemDef.Name);
	end

	local openbtnlab = getglobal("GiftPackFrameOpenBtnName")
	if gOpenType == 0 then
		openbtnlab:SetText(GetS(969))
	else
		openbtnlab:SetText(GetS(21774))
	end

	if selectIdx > 0 then
		showCheckEff(selectIdx, false)
	end

	updatePackItemList()
end

function GiftPackFrameCloseBtn_OnClick()
	-- body
	getglobal("GiftPackFrame"):Hide();
	ClientCurGame:setOperateUI(false);
end

function GiftPackFrameOpenBtn_OnClick()
	-- body
	if gOpenType == 0 then
		GiftPackFrameCloseBtn_OnClick();
		return
	end

	if not CurMainPlayer or not gPackDef then return end
	
	local ret = 1
	local addlist = ""
	ret, addlist = CurMainPlayer:openPackGift(gItemID, gPackShorCutIdx, gPackDef.iPackID, addlist)
	--if ret == 0 and addlist ~= nil and string.len(addlist) > 0 then
	if ret == 0 then
		--local list = split(addlist, "|")
		--for k,v in ipairs(list) do
		--	local itemDef = ItemDefCsv:getAutoUseForeignID(math.floor(v/1000));
		--	if itemDef then
		--		ShowGameTips(GetS(21801)..itemDef.Name.."*"..v%1000, 3, nil, nil, true);
		--	end
		--end

		GiftPackFrameCloseBtn_OnClick();
		ClientMgr:playSound2D("sounds/ui/info/book_seriesunlock.ogg", 1);
	else
		local str = ""
		if ret == 1 then
			str = GetS(21799)
		elseif ret == 3 then
			str = GetS(21800)
		else
			str = GetS(21798)
		end
		ShowGameTips(str, 3);
		ClientMgr:playSound2D("sounds/ui/info/crafting_error.ogg", 1);
	end
end

function GiftPackItemBtn_OnClick()
	-- body
	local idx = this:GetClientID();
	if idx == selectIdx then return end

	local checkEff;
	if selectIdx > 0 then
		showCheckEff(selectIdx, false)
	end

	selectIdx = idx
	showCheckEff(selectIdx, true)
	GiftPackItemBtn_OnMouseEnter_PC();
end

function GiftPackItemBtn_OnMouseEnter_PC()
	-- body
	local idx = this:GetClientID();
	local itemid = this:GetClientUserData(0)
	local def = ItemDefCsv:getAutoUseForeignID(itemid)
	itemid = def and def.ID or 101
	SetMTipsInfo(-1, "GiftPackFrameItemListItem" .. idx, true, itemid);
end

function GiftPackItemBtn_OnMouseLeave_PC()
	-- body
	HideMTipsInfo()
end

function PackItem_OnUse(player, world, x, y, z, dir)
	if player:isPlayerControl() then
		ShowGiftPackFrame(1, player:getCurToolID(), player:getCurShortcut() + ClientBackpack:getShortcutStartIndex())
	end
	return true, 2;
end

function ShowGiftPackFrame(type, itemid, shortcutidx)
	-- body
	gOpenType = type

	gItemID = itemid
	gPackShorCutIdx = shortcutidx
	local def = DefMgr:getPackGiftDefByItemID(gItemID)
	if def then
		gPackDef = def
		getglobal("GiftPackFrame"):Show()
		ClientCurGame:setOperateUI(true);
	end
end

function hideGiftPackFrame()
	local uiframe = getglobal("GiftPackFrame")
	if uiframe and uiframe:IsShown() then
		uiframe:Hide()
		ClientCurGame:setOperateUI(false)
	end
end

-- function updatePackItemList()
-- 	-- body
-- 	local listitem, itemwidth, itemheight, itemdata;
-- 	local listsize = gPackDef:getPackItemListSize()
-- 	local loadnum = 0
-- 	local offsetx = 4
-- 	local offsety = 0
-- 	local w = 8
-- 	local h = 10
-- 	local parent = getglobal("GiftPackFrameItemList")
-- 	for i = 1, 20 do
-- 		-- listitem = getglobal("GiftPackFrameItemListItem" .. i)
-- 		listitem = UIFrameMgr:FindFrame("GiftPackFrameItemListItem" .. i)
-- 		if not listitem then
-- 			listitem = Button:cloneButton("GiftPackFrameItemListItem" .. i, "GiftPackItemBtnTemplate")
-- 			parent:AddChild(listitem)
-- 			listitem:SetClientID(i)
-- 		end

-- 		if i == 1 then
-- 			itemwidth = listitem:GetWidth()
-- 			itemheight = listitem:GetHeight()
-- 		end

-- 		if i <= listsize then
-- 			itemdata = gPackDef:getNpcShopSkuDefByIdx(i-1)
-- 			listitem:SetPoint("topleft", "GiftPackFrameItemListPlane", "topleft", offsetx+ (loadnum%8)*(w+itemwidth), offsety+math.floor(loadnum/8)*(h+itemheight))
-- 			listitem:Show()
-- 			setPackListItemData(i, itemdata)
-- 			listitem:SetClientUserData(0, math.floor(itemdata.iItemInfo/1000))
-- 			loadnum = loadnum + 1
-- 		else
-- 			listitem:Hide()
-- 		end
-- 	end

-- 	if loadnum <= 0 then
-- 		return
-- 	end

-- 	local listFrame = getglobal("GiftPackFrameItemList")
-- 	local listPanel = getglobal("GiftPackFrameItemListPlane")
-- 	local height = offsety+(itemheight+h)*math.floor((loadnum+1)/8)+85
-- 	if height < listFrame:GetHeight() then height = listFrame:GetHeight() end
-- 	listPanel:SetHeight(height)
-- end

function updatePackItemList()
	local iMaxNum = 20
	local lastloadnum = #gPackListData
	gPackListData = {}

	local listsize = gPackDef:getPackItemListSize()
	for i=1,listsize do
		if i < iMaxNum then
			table.insert(gPackListData, gPackDef:getPackItemDefByIdx(i-1))
		end
	end

	local listviewCallBack = function(idx, name)
		local listitem = getglobal(name)
		if idx > #gPackListData then
			listitem:Hide()
			return
		end

		local w, h, offsetx, offsety = 8, 10, 4, 0
		local loadnum = idx-1
		local itemwidth, itemheight = listitem:GetWidth(), listitem:GetHeight()

		local itemdata = gPackListData[idx]
		listitem:SetPoint("topleft", "GiftPackFrameItemListPlane", "topleft", offsetx+ (loadnum%8)*(w+itemwidth), offsety+math.floor(loadnum/8)*(h+itemheight))
		listitem:Show()
		setPackListItemData(idx, itemdata)
		listitem:SetClientUserData(0, math.floor(itemdata.iItemInfo/1000))

		if idx == #gPackListData then
			local listFrame = getglobal("GiftPackFrameItemList")
			local listPanel = getglobal("GiftPackFrameItemListPlane")
			local height = offsety+(itemheight+h)*math.floor((loadnum+1)/8)+85
			if height < listFrame:GetHeight() then height = listFrame:GetHeight() end
			listPanel:SetHeight(height)
		end
	end

	lastloadnum = math.max(#gPackListData, lastloadnum)
	local onceload, functab = 3, {}
	for i=1,lastloadnum do
		table.insert(functab, {name="GiftPackFrameItemListItem" .. i, tmpname="GiftPackItemBtnTemplate", 
				parentname="GiftPackFrameItemList", clientid=i, idx=i, func=listviewCallBack})
		if i%onceload == 0 or i == lastloadnum then
			listviewMgr:createListItemsAsync(functab)
			functab = {}
		end
	end
	-- for i=1,lastloadnum do
	-- 	listviewMgr:createListItemAsync("GiftPackFrameItemListItem" .. i, "GiftPackItemBtnTemplate", "GiftPackFrameItemList", i, i, listviewCallBack)
	-- end
end

function setPackListItemData(idx, data)
	-- body
	local icon = getglobal("GiftPackFrameItemListItem"..idx.."Icon")

	local itemid = math.floor(data.iItemInfo/1000)
	local def = ItemDefCsv:getAutoUseForeignID(itemid)
	itemid = def and def.ID or 101
	SetItemIcon(icon, itemid);
	itemnum = data.iItemInfo%1000 or 1

	local lab = getglobal("GiftPackFrameItemListItem"..idx.."Count")
	if itemnum < 2 then
		lab:Hide();
	else
		lab:SetText(""..itemnum)
		lab:Show();
	end
end

function showCheckEff(idx, bShow)
	-- body
	checkEff = getglobal("GiftPackFrameItemListItem"..idx.."Checked")
	if checkEff then
		if bShow then
			checkEff:Show();
		else
			checkEff:Hide();
		end
	end
end

function CreateBackpackFrameOpenCreatorWikiBtn_OnClick()
	local defaultUrl = ClientUrl:GetUrlString("HttpDeveloperCollege","/cyclopdeia?wikiMenuId=1")
	local url = ns_version.Dev_wiki_link and ns_version.Dev_wiki_link.kaifazhedaojuWiki or defaultUrl
	if url then
		url = url .. "&portrait=1"
		open_http_link(url, "posting")
	end
end