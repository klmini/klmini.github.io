UseNew_BaseAttrFrame = true;
PlayerBaseAttrSetter = {};

BACK_PACK_GRID_MAX = BACK_PACK_GRID_MAX or 40
local t_ExtractPropTag = {}
local RoleFrame_NeedEndDrag = true;
local particles = "particles/hand2.ent"
function AddExtractPropTag(id)
	t_ExtractPropTag[id] = true;
	CheckBackpackBtnRedTag();
	print('kekeke AddExtractPropTag', t_ExtractPropTag);
end

function ClearExtractPropTag()
	t_ExtractPropTag = {}
end

function CheckItemIsBan(grid_index, ban, icon)
	local itemId = ClientBackpack:getGridItem(grid_index);
	ban:Hide();
	icon:SetGray(false);
	if itemId > 0 then
		if CheckAllServerBan(itemId) and AccountManager:getMultiPlayer() > 0 then
			ban:Show();
			icon:SetGray(true);
		end
	end
end
--检测是否可以禁用物品(云服务器和普通房间)
function CheckAllServerBan(itemId)
	if RentPermitCtrl:IsRentRoom() then
		--对于房主、超管来说 一切都不需要禁用
		local myAuthority = PermitsCallModuleScript("getCSAuthority",AccountManager:getUin())
		if myAuthority.Type == CS_AUTHORITY_ROOM_OWNER or myAuthority.Type == CS_AUTHORITY_SUPER_MANAGER then
			return false;
		end

		if PermitsCallModuleScript("getCSPlayerPermits",0, CS_PERMIT_DANGER) == 1 and PermitsCallModuleScript("isItemBan",itemId) then
			return true
		else
			return false
		end
	else
		if PermitsCallModuleScript("getPlayerPermits",0, CS_PERMIT_DANGER) == 1 and PermitsCallModuleScript("isItemBan",itemId) then
			return true
		else
			return false
		end
	--	return PermitsCallModuleScript("isItemBan",itemId)
	end
end

function CheckAllServerBanByIdNumber(itemId)
	if type(itemId) ~= "number" then
		return false
	end
	return CheckAllServerBan(itemId)
end

function CheckExtractPropTag(grid_index, redTag, type)
	local itemId = ClientBackpack:getGridItem(grid_index);
	if type == 'show' then
		if itemId > 0 and t_ExtractPropTag[itemId] then
			redTag:Show();
		else
			redTag:Hide();
		end
	elseif type == 'hide' then
		if itemId > 0 and t_ExtractPropTag[itemId] then
			t_ExtractPropTag[itemId] = nil;
			redTag:Hide();
		end
	end
end

function CheckBackpackBtnRedTag()
	for i=1, BACK_PACK_GRID_MAX do
		local grid_index = i+BACKPACK_START_INDEX-1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		if t_ExtractPropTag[itemId] then
			getglobal("PlayMainFrameBackpackRedTag"):Show();
			return;
		end
	end

	getglobal("PlayMainFrameBackpackRedTag"):Hide();
end
------------------------------------------------------------------
function RoleAttrFrameCloseBtn_OnClick()
	getglobal("RoleAttrFrame"):Hide();
	getglobal("RoleFrame"):Hide();
	getglobal("BackpackFrameMakeFrame"):Hide();
	--getglobal("EnchantFrame"):Hide();
end

function RoleAttrFrameStashBtn_OnClick()
	if IsStandAloneMode() then return end
	
	RoleAttrFrameCloseBtn_OnClick();
	--getglobal("NewStoreFrame"):Show();
	--新商城
	--商城重构
	GetInst("UIManager"):Open("Shop",{entryType = 0, tabType = 8,})

	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
		standReportEvent("1003", "MINI_TOOL_BAR_BAG", "StorageButton", "click") 
	else
		standReportEvent("1001", "MINI_TOOL_BAR_BAG", "StorageButton", "click") 
	end
end

function RoleAttrFrameCloseBtn_OnClick()
	getglobal("RoleAttrFrame"):Hide();
	--getglobal("EnchantFrame"):Hide();
end

--tab按钮
local m_RoleAttrTabBtnInfo = {
	preUIName = "RoleAttrFrameLabelBtn",
	{nameID = 16289, uiPage="RoleFrame", 	},					--人物
	{nameID = 808, uiPage="BackpackFrameMakeFrame", 	},		--合成
	--{nameID = 809, uiPage="EnchantFrame", 	},		--附魔
};

function RoleattrTabBtnTemplate_OnClick(id)
	print("RoleAttrFrameLabelBtn_OnClick:");

	id = id or this:GetClientID();

	print("id = ", id);

	--切换按钮状态
	TemplateTabBtn2_SetState(m_RoleAttrTabBtnInfo, id);

	if id == 0 then
		--初始化tab状态
		return;
	end

	--设置'附魔'类型
	--if id == 3 then
	--	Enchant_Type = 1;
	--end
	
	--切换页面
	for i = 1, #m_RoleAttrTabBtnInfo do
		local uiPage = m_RoleAttrTabBtnInfo[i].uiPage;

		if i == id then
			getglobal(uiPage):Show();
		else
			getglobal(uiPage):Hide();
		end
	end
end

function RoleAttrFrame_OnShow()
	HideAllFrame("RoleAttrFrame", true);
	PlayerBaseAttrSetter:Close();
	
	if not getglobal("RoleAttrFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end

	getglobal("PlayMainFrameBackpackRedTag"):Hide();
	
	getglobal("RoleAttrFrameLabelBtn1"):Show();
	getglobal("RoleAttrFrameLabelBtn2"):Show();
	getglobal("RoleAttrFrameStashBtn"):Show()
	
	--默认打开角色背包
	RoleattrTabBtnTemplate_OnClick(0);
	press_btn("RoleAttrFrameLabelBtn1");

	if CurWorld:getOWID() == NewbieWorldId then
		getglobal("RoleAttrFrameLabelBtn2"):Hide();
		--getglobal("RoleAttrFrameLabelBtn3"):Hide();
	else
		getglobal("RoleAttrFrameLabelBtn2"):Show();
		--getglobal("RoleAttrFrameLabelBtn3"):Show();
	end

	if gIsSingleGame then
		getglobal("RoleAttrFrameStashBtn"):Hide()
	end

	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		getglobal("RoleAttrFrameLabelBtn1"):Hide();
		getglobal("RoleAttrFrameLabelBtn2"):Hide();
		getglobal("RoleAttrFrameStashBtn"):Hide()
		getglobal("RoleFrameArmor"):Hide()
	end

	--MiniBase迷你基地隐藏仓库入口按钮
	if MiniBaseManager:isMiniBaseGame() then
		getglobal("RoleAttrFrameStashBtn"):Hide()
	end

	if isEducationalVersion then
		HideWebView_Edu()
	end

	--角色界面打开
	if GetInst('SceneEditorMsgHandler') then
		GetInst('SceneEditorMsgHandler'):dispatcher(SceneEditorUIDef.frame.show, {name = "RoleAttrFrame"})
	end
	
	if not getkv("roleattrroleclick") and not (RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom()) then
		if gFunc_isFileExist(particles) then
			--'ent'类型
			getglobal("RoleFrameBkgEffect"):addBackgroundEffect(particles, 0, 150, 50,3)
		end
	end
end

function RoleAttrFrame_OnHide()
	if RoleFrame_NeedEndDrag then
		UIEndDrag("MousePickItem");
	else
		RoleFrame_NeedEndDrag = true;
	end

	ShowMainFrame();
	if not getglobal("RoleAttrFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end

	if isEducationalVersion then
		ShowWebView_Edu()
	end

	-- 关闭ui之后，将modelview对应detach掉
	if EquipViewCurActor ~= nil and MODELVIEW_DECOUPLE_FROM_ACTORBODY then
		EquipViewCurActor:detachUIModelView();
		EquipViewCurActor = nil;
	end

	if gFunc_isFileExist(particles) then
		getglobal("RoleFrameBkgEffect"):deleteBackgroundEffect(particles)
	end
	
	--角色界面隐藏
	if GetInst('SceneEditorMsgHandler') then
		GetInst('SceneEditorMsgHandler'):dispatcher(SceneEditorUIDef.frame.hide, {name = "RoleAttrFrame"})
	end
end

function RoleAttrFrame_OnMouseDown()
	UIEndDrag("MousePickItem");
end

-------------------------------------------------------RoleFrame---------------------------------------------------------
local EquipViewCurActor = nil;
local CurCategoryType = 0;	--0全部1装备2工具3方块4材料
local Max_Num_CategoryType = 5;
local Max_Num_Equip = 6;

function RoleFrame_OnLoad()
	this:setUpdateTime(0.05);

	--属性面板
	PlayerBaseAttrSetter:Init();

	--装备栏
	for i=1, Max_Num_Equip/3 do
		for j = 1, 3 do
			local index = 3 * (i - 1) + j;
			local grid = getglobal("RoleFrameEquipGrid"..index);
			grid:SetPoint("topleft", "RoleFrameEquip", "topleft", (i - 1) * 391 + 30, (j - 1) * 122 + 77);
		end
	end

	--背包格子
	for i=1, BACK_PACK_GRID_MAX/6 do
		for j=1, 6 do
			local index = 6*(i-1)+j;
			local grid = getglobal("RoleFrameBackpackGrid"..index);
			grid:SetPoint("topleft", "RoleFrameBackpackBkg", "topleft", (j - 1) * 83 + 9, (i - 1) * 83 + 8);
		end
	end

	--快捷栏
	for i=1, MAX_SHORTCUT do
		local grid = getglobal("RoleFrameShortcutGrid"..i);
		grid:SetPoint("topleft", "RoleFrameShortcut", "topleft", (i - 1) * 104 + 117, 8);
		getglobal("RoleFrameShortcutGrid"..i .. "Num"):SetText(i);
	end


	this:RegisterEvent("GE_BACKPACK_CHANGE");
	RoleFrame_AddGameEvent()
	UpdadeCategoryBtn();

	RoleFrame_GeniusSubscibeEvents()

end


--更新特长
function RoleFrame_UpdateGenius(doReport)
	local geniusBtn = getglobal("RoleFrameGeniusBtn")
	if not GetInst("GeniusMgr"):IsOpenGeniusSys() then
		geniusBtn:Hide()
		return
	end
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		geniusBtn:Hide()
		return
	end

	geniusBtn:Show()
	local geniusBtnNormalBkg = getglobal("RoleFrameGeniusBtnNormalBkg")
	local geniusBtnPushedBkg = getglobal("RoleFrameGeniusBtnPushedBkg")
	local iconPath = GetInst("GeniusMgr"):GetCurEquipGeniusIcon()
	geniusBtnNormalBkg:SetTexture(iconPath)
	geniusBtnPushedBkg:SetTexture(iconPath)

	--开发者禁用的话 就将icon 置灰
	local enable = GetInst("GeniusMgr"):IsEnableSpecialProp()
	geniusBtn:SetGray(not enable)

	if doReport then
		RoleFrame_ReportGeniusBtnRef("view")
	end
end

function RoleFrame_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)

		if getglobal("RoleFrame"):IsShown() then
			local paramData = context:GetParamData()
			local grid_index = paramData.gridIndex
			if grid_index and grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX+1000 then
				UpdateBackpackOneGrids(grid_index, 0);
			elseif grid_index < 0 then
				UpdateBackpackAllGrids();
			elseif grid_index and grid_index >= EQUIP_START_INDEX and grid_index<EQUIP_START_INDEX+1000 then		--更新装备栏
				UpdateOneEquipGrid(grid_index);
				UpdateRoleFrameDefenseBar();
			end
		end
	end)
end

function UpdadeCategoryBtn()
	local t_CategoryInfo = {
				{nameId=813, uvname="icon_sort_all.png", w=22, h=22},
				{nameId=814, uvname="icon_sort_equip.png", w=21, h=21},--TODO
				{nameId=815, uvname="icon_sort_tool.png", w=22, h=22},--TODO
				{nameId=816, uvname="icon_sort_block.png", w=22, h=22},--TODO
				{nameId=817, uvname="icon_sort_material.png", w=21, h=17},--TODO
				}
	for i=1, Max_Num_CategoryType do
		local type 	= getglobal("RoleFrameCategoryFrameType"..i);
		local icon1 	= getglobal(type:GetName().."Icon1");
		local icon2 	= getglobal(type:GetName().."Icon2");
		local name 	= getglobal(type:GetName().."Name");

		type:SetPoint("top", "RoleFrameCategoryFrameBkg", "top", 0, (i-1)*46);
		name:SetText(GetS(t_CategoryInfo[i].nameId));	

		if t_CategoryInfo[i].uvname == "" then
			icon1:Hide();
		else
			icon1:Show();
			icon1:SetTexUV(t_CategoryInfo[i].uvname);
			icon1:SetSize(t_CategoryInfo[i].w, t_CategoryInfo[i].h);
		end	
	end
end

function RoleFrame_OnEvent()
	local ge = GameEventQue:getCurEvent();
	if arg1 == "GE_BACKPACK_CHANGE" then
		if getglobal("RoleFrame"):IsShown() then
			local grid_index = ge.body.backpack.grid_index;
			if grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX+1000 then
				UpdateBackpackOneGrids(grid_index, 0);
			elseif grid_index < 0 then
				UpdateBackpackAllGrids();
			elseif grid_index >= EQUIP_START_INDEX and grid_index<EQUIP_START_INDEX+1000 then		--更新装备栏
				UpdateOneEquipGrid(grid_index);
				UpdateRoleFrameDefenseBar();
			end
		end
	end
end

SwapBlinkBtnName 	= nil;	--背包和快捷栏物品交换时闪烁的按钮
SwapBlinkTime		= 4;	--按钮闪烁次数
function RoleFrame_OnUpdate()
	if SwapBlinkBtnName ~= nil then
		local blinkTexture = getglobal(SwapBlinkBtnName.."Check");
		if SwapBlinkTime > 0 then
			SwapBlinkTime =  SwapBlinkTime - 1;
			if blinkTexture:IsShown() then
				blinkTexture:Hide();
			else
				blinkTexture:Show();
			end
		else
			if blinkTexture:IsShown() then
				blinkTexture:Hide();
			end
			SwapBlinkBtnName = nil;
			SwapBlinkTime = 4;
		end
	end
end

function SetEquipCheckGrid(gridName)
	for i=1, Max_Num_Equip do
		local check = getglobal("RoleFrameEquipGrid"..i.."Check");
		check:Hide();
	end
		
	if gridName ~= nil then
		local check = getglobal(gridName.."Check");
		check:Show();
	end
end

local mouseMove = false
local isclick = false
local rotateAngle = 0
function RoleFrameRotateView_OnMouseDown()
	InitModelViewAngle =  getglobal("RoleFrameEquipActorView"):getRotateAngle();	
	mouseMove = false
	local posX = getglobal("RoleFrameEquipActorView"):getActorPosX()
	local posY = getglobal("RoleFrameEquipActorView"):getActorPosY()

	if arg3 > posX-100 and arg3 < posX+100 then	--按下的位置是角色范围内
		isclick = true
	else
		isclick = false
	end

	rotateAngle = InitModelViewAngle
end

function RoleFrameRotateView_OnMouseMove()
	local angle = (arg1 - arg3)*1;

	if angle > 360 then
		angle = angle - 360;
	end
	if angle < -360 then
		angle = angle + 360;
	end

	angle = angle + InitModelViewAngle;	
	getglobal("RoleFrameEquipActorView"):setRotateAngle(angle);
	if angle ~= rotateAngle then
		mouseMove = true
	end
end

function RoleFrameRotateView_OnMouseUp()
	if not mouseMove and isclick then
		if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
			--社交大厅一期 屏蔽商城跳转逻辑
			return
		end
		if not getkv("roleattrroleclick") then
			if gFunc_isFileExist(particles) then
				getglobal("RoleFrameBkgEffect"):deleteBackgroundEffect(particles)
			end
		end
		--点击
		setkv("roleattrroleclick", true)

		GetPlayer2Model()
	
		local player = ClientCurGame:getMainPlayer();

		local skinid = player:getSkinID()

		local refreshFunc = function()
			if SingleEditorFrame_Switch_New then
				local btnState = GetInst("ModsLibEditorItemPartMgr"):getBtnState()
				--自定义装备:使用、禁用avator按钮
				-- GetInst("ModsLibEditorItemPartMgr"):InitAvatorBtnInfo(false)
				GetInst("ModsLibEditorItemPartMgr"):UpdateAvatorByState(btnState)
			end
		end
		local btnState = GetInst("ModsLibEditorItemPartMgr"):getBtnState()
		local standby1
		if lobbyIsAvtModel and btnState then
			ShopJumpTabView(3,nil,{tabType = 2,callback = refreshFunc})
			standby1 = 2
		elseif lobbyIsSkinModel or (skinid and skinid > 0) then
			ShopJumpTabView(2,nil,{tabType = 2,callback = refreshFunc})
			standby1 = 1
		else
			ShopJumpTabView(5,nil,{callback = refreshFunc})
			standby1 = 3
		end

		if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
			standReportEvent("1003", "MINI_TOOL_BAR_BAG", "RoleButton", "click",{standby1=tostring(standby1),standby2=tostring(WorldMgr:getGameMode())}) 
		else
			standReportEvent("1001", "MINI_TOOL_BAR_BAG", "RoleButton", "click",{standby1=tostring(standby1),standby2=tostring(WorldMgr:getGameMode())}) 
		end
	end
	
end

function UpdateRideGrid()
	local ride = CurMainPlayer:getRidingHorse();

	if ride ~= nil then
		local icon = getglobal("RoleFrameEquipGrid6Icon");
		local horseDef = ride:getHorseDef();
		
		if horseDef ~= nil and isShapeShiftHorse(horseDef.ID) ~= true then
			icon:SetTexture("ui/rideicons/"..horseDef.ID..".png");
		else
			SetNullGrid("RoleFrameEquipGrid6");
		end
	else
		SetNullGrid("RoleFrameEquipGrid6");
	end
end

--初始化所有装备栏
function UpdateEquipAllGrid()
	for i=1, 5 do
		local grid_index = EQUIP_START_INDEX + i - 1;
		UpdateOneEquipGrid(grid_index);	
	end
end

--更新一个装备栏
function UpdateOneEquipGrid(grid_index)
	local n = grid_index + 1 - EQUIP_START_INDEX;
	local icon = getglobal("RoleFrameEquipGrid"..n.."Icon");
	local num = getglobal("RoleFrameEquipGrid"..n.."Count");	
	local durBkg = getglobal("RoleFrameEquipGrid"..n.."DurBkg");
	local dur = getglobal("RoleFrameEquipGrid"..n.."Duration");
	UpdateGridContent(icon, num, durBkg, dur, grid_index);
end

function SetBackpackCheckGrid(gridName, frameName, gridNum)
	frameName = frameName or "RoleFrameBackpackGrid"
	gridNum = gridNum or BACK_PACK_GRID_MAX
	for i=1, gridNum do
		local check = getglobal(frameName..i.."Check");
		check:Hide();
	end

	if gridName ~= nil then
		local check = getglobal(gridName.."Check");
		check:Show();
	end
end

function UpdateBackpackAllGrids()
	if CurCategoryType == 0 then
		for i=1, BACK_PACK_GRID_MAX do
			local gridName = "RoleFrameBackpackGrid"..i;
			local grid_index = getglobal(gridName):GetClientID() - 1;
			local itemId = ClientBackpack:getGridItem(grid_index);
			if itemId == 0 then
				SetNullGrid(gridName);
			else
				UpdateBackpackOneGrids(grid_index, i);
			end
		end
		return;
	end

	local t_GridShowItemIdx = {};
	local t_GridNoShowItemIdx = {};
	for i=1, BACK_PACK_GRID_MAX do
		local grid_index = i+BACKPACK_START_INDEX-1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		local itemDef = ItemDefCsv:get(itemId);
		if itemId ~= 0 and itemDef ~= nil then			
			if CurCategoryType == 0 or itemDef.FilterType == CurCategoryType then
				table.insert(t_GridShowItemIdx, grid_index);
			else
				table.insert(t_GridNoShowItemIdx, grid_index);
			end
		else
			table.insert(t_GridNoShowItemIdx, grid_index);
		end
	end

	for i=1, #(t_GridShowItemIdx) do
		UpdateBackpackOneGrids(t_GridShowItemIdx[i], i);
	end

	local idx = 1;
	for i=#(t_GridShowItemIdx)+1, BACK_PACK_GRID_MAX do
		local gridName = "RoleFrameBackpackGrid"..i;
		SetNullGrid(gridName);
		local grid_index = t_GridNoShowItemIdx[idx];
		getglobal("RoleFrameBackpackGrid"..i):SetClientID(grid_index+1);	
		idx = idx + 1;
	end
end

function FindIdx2GridIndex(grid_index)
	for i=1, BACK_PACK_GRID_MAX do
		local grid = getglobal("RoleFrameBackpackGrid"..i);
		if grid:GetClientID() == grid_index+1 then
			return i;
		end
	end

	return 0
end

function UpdateBackpackOneGrids(grid_index, idx)
	if idx == 0 then
		idx = FindIdx2GridIndex(grid_index);
	end
	if idx > 0 and idx <= BACK_PACK_GRID_MAX then 
		local grid = getglobal("RoleFrameBackpackGrid"..idx);
		grid:SetClientID(grid_index+1);

		local icon = getglobal("RoleFrameBackpackGrid"..idx.."Icon");
		local num = getglobal("RoleFrameBackpackGrid"..idx.."Count");	
		local durBkg = getglobal("RoleFrameBackpackGrid"..idx.."DurBkg");
		local dur = getglobal("RoleFrameBackpackGrid"..idx.."Duration");
		local redTag = getglobal("RoleFrameBackpackGrid"..idx.."RedTag");

		UpdateGridContent(icon, num, durBkg, dur, grid_index);

		local ban = getglobal("RoleFrameBackpackGrid"..idx.."Ban");
		CheckItemIsBan(grid_index, ban, icon);
		CheckExtractPropTag(grid_index, redTag, 'show');
	end
end

function SetShortcutCheckGrid(gridName, frameName)
	frameName = frameName or "RoleFrameShortcutGrid"
	for i=1, MAX_SHORTCUT do
		local check = getglobal(frameName..i.."Check");
		check:Hide();
	end

	if gridName ~= nil then
		local check = getglobal(gridName.."Check");
		check:Show();
	end
end

function UpdateRoleFrameShortcutAllGrid()
	for i=1, MAX_SHORTCUT do
		UpdateRoleFrameShortcutOneGrid(ClientBackpack:getShortcutStartIndex()+i-1)
	end
end

function UpdateRoleFrameShortcutOneGrid(grid_index)
	local idx = grid_index + 1 - ClientBackpack:getShortcutStartIndex();
	if idx > 0 and idx <= 8 then 
		local icon = getglobal("RoleFrameShortcutGrid"..idx.."Icon");
		local num = getglobal("RoleFrameShortcutGrid"..idx.."Count");	
		local durBkg = getglobal("RoleFrameShortcutGrid"..idx.."DurBkg");
		local dur = getglobal("RoleFrameShortcutGrid"..idx.."Duration");

		UpdateGridContent(icon, num, durBkg, dur, grid_index);

		local ban = getglobal("RoleFrameShortcutGrid"..idx.."Ban");
		CheckItemIsBan(grid_index, ban, icon);
	end
end

function RoleFrame_OnShow()	
	--模型
	local player = ClientCurGame:getMainPlayer();
	if EquipViewCurActor ~= player then
		local modelView = getglobal("RoleFrameEquipActorView");
		EquipViewCurActor = player
		player:attachUIModelView(modelView);
		local skinid = player:getSkinID()
		if skinid and skinid > 0 then
			local skindef = RoleSkinCsv:get(skinid)
			if skindef and skindef.Effect then
				modelView:playEffect(skindef.Effect, 0)
			end
		end

		if skinid == 90 or skinid == 96 then
			local body = modelView:getActorBody()
			if body then
				body:setRealScale(0.8)
			end
		end
		local playerCustomModel = CurMainPlayer:getCustomModel();
		if playerCustomModel and string.len(playerCustomModel) > 0 then
			--基础设置中使用了自定义模型
		else
			ClientGetRoleAvatarInfo(AccountManager:getUin(), AccountManager:avatar_seat_current());
		end

		modelView:setRotateAngle(-25)
		getglobal("RoleFrameName"):SetText(AccountManager:getNickName());

		local uiVipIcon1 = getglobal("RoleFrameVipIcon1");
		local uiVipIcon2 = getglobal("RoleFrameVipIcon2");
		UpdateAccountVipIcons(uiVipIcon1, uiVipIcon2);

		-- if uiVipIcon1:IsShown() and uiVipIcon2:IsShown() then
		-- 	getglobal("RoleFrameName"):SetPoint("topleft", "RoleFrame", "topleft", 36+48, 87);
		-- elseif uiVipIcon1:IsShown() or uiVipIcon2:IsShown() then
		-- 	getglobal("RoleFrameName"):SetPoint("topleft", "RoleFrame", "topleft", 36+24, 87);
		-- else
		-- 	getglobal("RoleFrameName"):SetPoint("topleft", "RoleFrame", "topleft", 36, 87);
		-- end
	end
	if EquipViewCurActor:isFishNeedUp() then
		getglobal("RoleFrameEquipActorView"):getActorBody():playAnim(SEQ_CARRYING)
	else
		getglobal("RoleFrameEquipActorView"):getActorBody():stopAnim(SEQ_CARRYING)
	end
	if IsEduTouristMode() then
		getglobal("RoleFrameName"):SetText("游客")
	end

	UpdateEquipAllGrid();
	UpdateRideGrid();
	UpdateRoleFrameDefenseBar();
	SetCurCategoryType(0);
	UpdateBackpackAllGrids();
	UpdateRoleFrameShortcutAllGrid();

	--LLTODO:星星颜色与地图中保持一致
	getglobal("RoleFrameStarBkg"):Show() --这里要加回去，不然切模式的时候一旦隐藏了，就再也显示不出来了
	getglobal("RoleFrameStarNum"):Show()
	getglobal("RoleFrameStarNumBkg"):Show()
	getglobal("RoleFrameStarNumPro"):Show()
	if CurWorld:isCreateRunMode() then
		getglobal("RoleFrameStarBkg"):SetTexUV("juese_xingxing03.png");
	elseif CurWorld:isExtremityMode() then
		getglobal("RoleFrameStarBkg"):SetTexUV("juese_xingxing02.png");
	elseif CurWorld:isFreeMode() then
		getglobal("RoleFrameStarBkg"):SetTexUV("juese_xingxing06.png");
	elseif CurWorld:isGameMakerRunMode() then
		getglobal("RoleFrameStarBkg"):SetTexUV("juese_xingxing04.png");
	elseif CurWorld:isSurviveMode() then 
		getglobal("RoleFrameStarBkg"):SetTexUV("juese_xingxing05.png");
	elseif CurWorld:isCreativeMode() or CurWorld:isGameMakerMode() then
		getglobal("RoleFrameStarBkg"):Hide();
		getglobal("RoleFrameStarNum"):Hide()
		getglobal("RoleFrameStarNumBkg"):Hide()
		getglobal("RoleFrameStarNumPro"):Hide()
	end

	getglobal("RoleFrameEquip"):Show()
	getglobal("RoleFrameHeadTitle"):SetText(GetS(16289))
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		getglobal("RoleFrameStarBkg"):Hide();
		getglobal("RoleFrameStarNum"):Hide()
		getglobal("RoleFrameStarNumBkg"):Hide()
		getglobal("RoleFrameStarNumPro"):Hide()
		getglobal("RoleFrameEquip"):Hide()
		getglobal("RoleFrameHeadTitle"):SetText(GetS(294))
	end

	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);	
	getglobal("RoleFrameStarNum"):SetText(starNum);

	if CurWorld:isGodMode() then
		getglobal("RoleFrameCreateBackPackBtn"):Show();
	else
		getglobal("RoleFrameCreateBackPackBtn"):Hide();
	end

	if SingleEditorFrame_Switch_New then
		--自定义装备:使用、禁用avator按钮
		GetInst("ModsLibEditorItemPartMgr"):InitAvatorBtnInfo(false);
	end
	
	-- if AccountManager:avatar_seat_current() > 0 then -- 有avatar装备的情况下
	-- 	getglobal("RoleFramePaintGrid"):SetPoint("left", "RoleFrameAvatorBtn", "right", 33, 0)
	-- else
	-- 	getglobal("RoleFramePaintGrid"):SetPoint("center", "RoleFrameEquip", "center", 198, 209)
	-- end	
	SetItemIcon(getglobal("RoleFramePaintGridIcon"), ITEM_PAINTTANK)
	SetBackpackCheckPaintGrid(false)
	Paint_ReportEvent("MINI_TOOL_BAR_BAG", "GraffitiTool", "view")
	local uin = AccountManager:getUin()
	if getkv("BackPackPaint_Onlick"..uin) then
		getglobal("RoleFramePaintGridRedTag"):Hide()
	else
		getglobal("RoleFramePaintGridRedTag"):Show()
	end

	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
		standReportEvent("1003", "MINI_TOOL_BAR_BAG", "-", "view")
	else
		standReportEvent("1001", "MINI_TOOL_BAR_BAG", "-", "view")
	end

	--特长
	RoleFrame_UpdateGenius(true)
end

function RoleFrame_OnHide()
	if EquipViewCurActor ~= nil then
		-- local seatInfo = GetInst("ShopDataManager"):GetPlayerUsingSeatInfo()
		-- if seatInfo then		
		-- 	--这里有坑 分离？view
		-- else
		-- 	EquipViewCurActor:detachUIModelView();
		-- 	EquipViewCurActor = nil;
		-- end

		EquipViewCurActor:detachUIModelView();
		EquipViewCurActor = nil;
	end
	getglobal("RoleFrameCategoryFrame"):Hide();
	SetEquipCheckGrid(nil);
	SetShortcutCheckGrid(nil);
	SetBackpackCheckGrid(nil);
	selectBackpackGrid = -1;
	getglobal("RoleFrameArmorTips"):Hide();

	if SwapBlinkBtnName ~= nil then
		local blinkTexture = getglobal(SwapBlinkBtnName.."Check");
		blinkTexture:Hide();
		SwapBlinkBtnName = nil;
		SwapBlinkTime = 4;
	end
	
end

function RoleFrameBackpack_OnMouseDown()
	UIEndDrag("MousePickItem");
end

function RoleFrameBackpackSortBtn_OnClick()
	CurMainPlayer:sortPack(BACKPACK_START_INDEX);
	SetBackpackCheckGrid(nil);
end

function GetNullGridIndex()	
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

function GetGridBtnName2GridIndex(grid_index)
	for i=1,MAX_SHORTCUT do
		local grid = getglobal("RoleFrameShortcutGrid"..i);
		if grid:GetClientID() == grid_index+1 then
			return grid:GetName();
		end
	end
	for i=1,BACK_PACK_GRID_MAX do
		local grid = getglobal("RoleFrameBackpackGrid"..i);
		if grid:GetClientID() == grid_index+1 then
			return grid:GetName();
		end
	end
	return nil;
end

function WearEquip2Grid(grid_index)
	local equipSlot = ToolType2EquipSlot(ClientBackpack:getGridToolType(grid_index));
	if equipSlot > 0 then
		CurMainPlayer:swapItem(grid_index, equipSlot);
		local index = equipSlot-EQUIP_START_INDEX+1;
		SwapBlinkBtnName = "RoleFrameEquipGrid"..index;
		HideCurSelectGridCheck();
		selectBackpackGrid = -1;
	end
end

function DeEquip2Grid(grid_index)
	local togrid_index = GetNullGridIndex();
	if togrid_index ~= -1 then
		CurMainPlayer:swapItem(grid_index, togrid_index);
		SwapBlinkBtnName = GetGridBtnName2GridIndex(togrid_index);
		SetEquipCheckGrid(nil);
	end
end


function CategoryBtnTemplate_OnClick()
	getglobal("RoleFrameCategoryFrame"):Hide();
	SetCurCategoryType(this:GetClientID()-1);
	UpdateBackpackAllGrids();	
	SetGategoryBtnNameColor();
	getglobal("RoleFrameBackpackCategoryBtnArrow"):MirrorVertically();
end

function RoleFrameBackpackCategoryBtn_OnClick()
	local ui = getglobal("RoleFrameCategoryFrame");
	if ui:IsShown() then
		ui:Hide();
	else
		ui:Show();
	end
	getglobal("RoleFrameBackpackCategoryBtnArrow"):MirrorVertically();
end

function RoleFrameCategoryFrameBtn_OnClick()
	getglobal("RoleFrameCategoryFrame"):Hide();
end

function RoleFrameCategoryFrame_OnShow()
	SetGategoryBtnNameColor()
end


function SetCurCategoryType(type)
	CurCategoryType = type;
	local t_TypeNameId = {813, 814, 815, 816, 817};
	getglobal("RoleFrameBackpackCategoryBtnName"):SetText(GetS(t_TypeNameId[type+1]));
end

function SetGategoryBtnNameColor()
	for i=1, Max_Num_CategoryType do
		local type = getglobal("RoleFrameCategoryFrameType"..i);
		local name = getglobal("RoleFrameCategoryFrameType"..i.."Name");
		local bkg = getglobal("RoleFrameCategoryFrameType"..i.."Bkg")
		if CurCategoryType > 0 and type:GetClientID()-1 == CurCategoryType then
			name:SetTextColor(255, 255, 255);
			bkg:Show()
		else
			name:SetTextColor(185, 185, 185);
			bkg:Hide()
		end
	end
end

function RoleFrameCategoryFrame_OnClick()
	getglobal("RoleFrameCategoryFrame"):Hide();
end

function RoleFrameCreateBackPackBtn_OnClick()
	RoleFrame_NeedEndDrag = false;
	RoleAttrFrameCloseBtn_OnClick();
	if selectBackpackGrid ~= -1 then
		local index = 0;
		local boxTexture = nil;
		if selectBackpackGrid >= ClientBackpack:getShortcutStartIndex() and selectBackpackGrid < ClientBackpack:getShortcutStartIndex() + 1000 then
			index 		= selectBackpackGrid - ClientBackpack:getShortcutStartIndex() + 1;
			boxTexture = getglobal("RoleFrameShortcutGrid"..index.."Check");
		else
			index 		= selectBackpackGrid - BACKPACK_START_INDEX + 1;
			boxTexture 	= getglobal("RoleFrameBackpackGrid"..index.."Check");
		end

		if boxTexture ~= nil then
			boxTexture:Hide();
		end

		selectBackpackGrid = -1;
	end

	-- 地图新编辑模式
	if UGCModeMgr and UGCModeMgr:IsEditing() then  -- 编辑地图
		GetInst('SceneEditorMsgHandler'):dispatcher(SceneEditorUIDef.common.open_resource_bag)
	else
		getglobal("CreateBackpackFrame"):Show();
	end
end

function UpdateRoleFrameDefenseBar()
	local point = MainPlayerAttrib:getArmorPointLua(0);

	local value = (point/100) > 1 and 1 or (point/100); -- modify by null, 防御值从20->100了
	
	if UseNew_BaseAttrFrame then
		UpdateRoleFrameArmorTips();
	else
		-- getglobal("RoleFrameArmorBar"):SetCurValue(point/100, false);
		getglobal("RoleFrameArmorVal"):SetText("×"..math.floor(point + 0.5));	

		local tips = getglobal("RoleFrameArmorTips");
		if tips:IsShown() then
			UpdateRoleFrameArmorTips();
		end
	end
end

--获取当前装备的防御值
function GetCurEquipArmorPoint(type)
	local point = 0;
	for i=1, 5 do
		local grid_index = EQUIP_START_INDEX + i - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		local dur = ClientBackpack:getGridDuration(grid_index);
		local toolDef = ToolDefCsv:get(itemId);
		if toolDef then
			local maxDur = toolDef.Duration;
			if type == 'armorrange' then
				point = point + toolDef.Armors[1] * (dur/maxDur);
			elseif type == 'armormagic' then
				point = point + toolDef.Armors[2] * (dur/maxDur);
			end
		end
	end 

	return point;
end

-----------------------------------基础设置: 玩家基础属性-----------------------------------
PlayerBaseAttrSetter = {
	Init = function(self)
		self.rootui = "RoleFrameBaseAttr";
		self.groupHeight = 110;
		self.itemHeight = 36;

		self.curGroupIndex = 0;
		self.curItemIndex = 0;

		self.GroupList = {
			{
				--1. 攻击
				titleName = GetS(34179),--"攻击",
				itemList = {
					{
						--1. 物理攻击
						PATTR = PATTR_ATTACKPHY,
						icon = {uvName = "icon_atk", w="17", h="17"},
						title = GetS(34180),--"物理攻击",
						basePoint = 100,
						detailList = {
							{title = GetS(34233), basePoint = 100, increment = 10, nAttackType = ATTACK_PUNCH, 	},	--"近战攻击"
							{title = GetS(34234), basePoint = 100, increment = 10, nAttackType = ATTACK_RANGE, 	},	--"远程攻击"
							{title = GetS(34235), basePoint = 100, increment = 10, nAttackType = ATTACK_EXPLODE, },	--"爆炸攻击"
						},
					},
					{
						--2. 元素攻击
						PATTR = PATTR_ATTACKELEM,
						icon = {uvName = "icon_matk", w="12", h="17"},
						title = GetS(34181),--"元素攻击",
						basePoint = 50,
						detailList = {
							{title = GetS(34236), basePoint = 50, increment = 5, nAttackType = ATTACK_FIRE, 	},	--"火焰"
							{title = GetS(34237), basePoint = 50, increment = 5, nAttackType = ATTACK_POISON, 	},	--"毒素"
							{title = GetS(34238), basePoint = 50, increment = 5, nAttackType = ATTACK_WITHER, 	},	--"凋零"
						},
					},
				},
			},
			{
				--2. 防御
				titleName = GetS(34182),-- "防御",
				itemList = {
					{
						--1. 物理防御
						PATTR = PATTR_DEFPHY,
						icon = {uvName = "icon_def", w="15", h="17"},
						title = GetS(34183),--"物理防御",
						basePoint = 100,
						detailList = {
							{title = GetS(34239), basePoint = 100, increment = 10, nDefenseType = ATTACK_PUNCH, },	--"近战防御"
							{title = GetS(34240), basePoint = 100, increment = 10, nDefenseType = ATTACK_RANGE, },	--"远程防御"
							{title = GetS(34241), basePoint = 100, increment = 10, nDefenseType = ATTACK_EXPLODE,},	--"爆炸防御"
						},
					},
					{
						--2. 元素防御
						PATTR = PATTR_DEFELEM,
						icon = {uvName = "icon_mdef", w="15", h="17"},
						title = GetS(34184),--"元素防御",
						basePoint = 40,
						detailList = {
							{title = GetS(34242), basePoint = 40, increment = 8, nDefenseType = ATTACK_FIRE, 	},	--"火焰防御"
							{title = GetS(34243), basePoint = 40, increment = 8, nDefenseType = ATTACK_POISON,},	--"毒素防御"
							{title = GetS(34244), basePoint = 40, increment = 8, nDefenseType = ATTACK_WITHER,},	--"凋零防御"
						},
					},
				},
			},
			{
				--3. 移动
				titleName = GetS(34185),--"移动",
				itemList = {
					{
						--1. 移动速度
						PATTR = PATTR_SPEED,
						icon = {uvName = "icon_dex", w="14", h="14"},
						title = GetS(34186),--"移动速度",
						basePoint = 10,
					},
				},
			},
		}
	end,

	EntryBtnClick = function(self)
		local frame = getglobal(self.rootui);
		if frame:IsShown() then
			self:Close();
		else
			self:Open();
		end
	end,

	Open = function(self)
		local frame = getglobal(self.rootui);
		if frame:IsShown() then
			frame:Hide();
		else
			frame:Show();
			self:Update();
		end
	end,

	Close = function(self)
		local frame = getglobal(self.rootui);
		if frame:IsShown() then
			frame:Hide();
		end
	end,

	Update = function(self)
		self:load();
		self:updateView();
	end,

	load = function(self)
		for i = 1, #self.GroupList do
			for j = 1, #self.GroupList[i].itemList do
				local itemCfg = self.GroupList[i].itemList[j];
				local basePoint = 0;

				if itemCfg.PATTR then
					basePoint = self:GetBaseAttr(itemCfg.PATTR);
				end

				itemCfg.basePoint = basePoint;

				if itemCfg.detailList then
					for k = 1, #itemCfg.detailList do
						itemCfg.detailList[k].basePoint = basePoint;
						--basePoint = self:GetBaseAttr(itemCfg.PATTR, itemCfg.detailList[k].nDefenseType);
						--itemCfg.detailList[k].basePoint = basePoint;

						local increment = 0;

						if itemCfg.detailList[k].nAttackType then
							--攻击
							increment = self:GetAttactIncrement(itemCfg.detailList[k].nAttackType, basePoint);
						elseif itemCfg.detailList[k].nDefenseType then
							--防御
							increment = self:GetDefenseIncrement(itemCfg.detailList[k].nDefenseType, basePoint);
						end

						increment = string.format("%.1f", increment);
						increment = tonumber(increment);

						itemCfg.detailList[k].increment = increment;
					end
				end
			end
		end
	end,

	GetPlayerAttr = function(self)
		if CurMainPlayer then
			local playerAttr = CurMainPlayer:getPlayerAttrib();
			if playerAttr then
				return playerAttr;
			end
		end

		return nil;
	end,

	--玩家基础属性: 攻击力、防御力
	--PATTR:
	--物理攻击:PATTR_ATTACKPHY
	--元素攻击:PATTR_ATTACKELEM
	--物理防御:PATTR_DEFPHY
	--元素防御:PATTR_DEFELEM
	--速度:PATTR_SPEED
	GetBaseAttr = function(self, PATTR, DefenseType)
		local point = 0;

		local playerAttr = self:GetPlayerAttr();
		if playerAttr then
			if PATTR == PATTR_DEFPHY then
				if DefenseType then
					--近战、远程、爆炸防御
					point = playerAttr:getArmorPoint(DefenseType);
				else
					--物理防御
					point = playerAttr:getArmorPoint(PHYSICS_ATTACK);
				end
			elseif PATTR == PATTR_DEFELEM then
				if DefenseType then
					--火焰、毒素、凋零
					point = playerAttr:getArmorPoint(DefenseType);
				else
					--元素防御
					point = playerAttr:getArmorPoint(MAX_MAGIC_ATTACK);
				end
			else
				point = playerAttr:getPlayerBaseAttr(PATTR);
			end
		end

		--计算总速度
		if PATTR == PATTR_SPEED then
			point = playerAttr:getMoveSpeed();
			point = string.format("%.1f", point);
		end

		point = string.format("%.1f", point);

		return point;
	end,

	--获取玩家攻击力加成: 来源: 1.手持武器 2.效果(buff、装备)
	--nType
	--近程:ATTACK_PUNCH
	--远程:ATTACK_RANGE
	--爆炸:ATTACK_EXPLODE
	--火:ATTACK_FIRE
	--毒素:ATTACK_POISON
	--凋零:ATTACK_WITHER
	GetAttactIncrement = function(self, nType, basePoint)
		local sumPoint = 0;		--总攻击
		local increment = 0;	--增量

		-- local basePoint = self:GetBaseAttr(nType);

		--1. 手持武器都是近战攻击
		-- if nType == ATTACK_PUNCH then
		-- 	local itemId = ClientBackpack:getGridItem(EQUIP_WEAPON);
		-- 	local dur = ClientBackpack:getGridDuration(EQUIP_WEAPON);
		-- 	local toolDef = ToolDefCsv:get(itemId);
		-- 	if toolDef then
		-- 		local maxDur = toolDef.Duration;

		-- 		sumPoint = basePoint + toolDef.AttackType * dur / maxDur;
		-- 	end
		-- end

		local playerAttr = self:GetPlayerAttr();
		if playerAttr then
			--1. 基础伤害 + 手持武器
			sumPoint = playerAttr:getAttackPoint(nType);

			--2. buff:对应伤害类型
			sumPoint = playerAttr:getAttackPointWithStatus(nType, sumPoint);
		end

		increment = sumPoint - basePoint;
		return increment;
	end,

	--获取玩家防御力加成
	--nType:同上
	GetDefenseIncrement = function(self, nType, basePoint)
		local sumPoint = 0;
		local increment = 0;
		local playerAttr = self:GetPlayerAttr();

		if playerAttr then
			--1. 基础防御 + 装备
			sumPoint = playerAttr:getArmorPoint(nType);
			--sumPoint = basePoint;

			--2. buff
			sumPoint = playerAttr:getAromrPointWithStatus(nType, sumPoint);
		end

		increment = sumPoint - basePoint;
		return increment;
	end,

	updateView = function(self)
		local y = 0;

		for i = 1, #self.GroupList do
			local groupUI = self.rootui .. "Group" .. i;
			local group = getglobal(groupUI);
			local itemY = 30;

			group:SetPoint("top", self.rootui, "top", 0, y);
			group:SetClientID(i);
			getglobal(groupUI .. "Title"):SetText(self.GroupList[i].titleName);
			y = y + self.groupHeight;

			for j = 1, 3 do
				local itemUI = self.rootui .. "Group" .. i .. "Item" .. j;
				local item = getglobal(itemUI);

				if j <= #self.GroupList[i].itemList then
					local itemCfg = self.GroupList[i].itemList[j];
					local icon = getglobal(itemUI .. "Icon");
					local title = getglobal(itemUI .. "Title");
					local value = getglobal(itemUI .. "Value");
					local itemChecked = getglobal(itemUI .. "Checked");
					local ArrayIcon = getglobal(itemUI .. "ArrayIcon");

					item:Show();
					item:SetPoint("top", groupUI, "top", 0, itemY);
					item:SetClientID(j);
					icon:SetTexUV(itemCfg.icon.uvName);
					icon:SetSize(itemCfg.icon.w, itemCfg.icon.h);
					title:SetText(itemCfg.title);
					value:SetText(itemCfg.basePoint);
					itemY = itemY + self.itemHeight;

					if itemCfg.detailList and #(itemCfg.detailList) > 0 then
						ArrayIcon:Show();
					else
						ArrayIcon:Hide();
					end

					if self.curGroupIndex == i and self.curItemIndex == j then
						itemChecked:Show();
					else
						itemChecked:Hide();
					end
				else
					item:Hide();
				end
			end
		end

		if getglobal(self.rootui .. "DetailFrame"):IsShown() then
			self:updateDetailView();
		end
	end,

	updateItemChecked = function(self)
		for i = 1, #self.GroupList do
			local groupUI = self.rootui .. "Group" .. i;

			for j = 1, 3 do
				local itemUI = self.rootui .. "Group" .. i .. "Item" .. j;

				if j <= #self.GroupList[i].itemList then
					local itemChecked = getglobal(itemUI .. "Checked");

					if self.curGroupIndex == i and self.curItemIndex == j then
						itemChecked:Show();
					else
						itemChecked:Hide();
					end
				end
			end
		end
	end,

	updateDetailView = function(self)
		local curGroupIndex = self.curGroupIndex;
		local curItemIndex = self.curItemIndex;

		if curGroupIndex <= 0 or curItemIndex <= 0 then
			return;
		end

		local detailList = self.GroupList[curGroupIndex].itemList[curItemIndex].detailList;
		local detailFrameUI = self.rootui .. "DetailFrame";
		local parentItemUI = self.rootui .. "Group" .. curGroupIndex .. "Item" .. curItemIndex;
		local y = 30;
		local itemHeight = 36;

		getglobal(detailFrameUI):SetPoint("left", parentItemUI, "right", 8, 0);
		getglobal(detailFrameUI .. "Title"):SetText("详情");

		for i = 1, 3 do
			if i <= #detailList then
				local itemUI = detailFrameUI .. "Item" .. i;
				local item = getglobal(itemUI);
				local title = getglobal(itemUI .. "Title");
				local icon = getglobal(itemUI .. "Icon");
				local arrayIcon = getglobal(itemUI .. "ArrayIcon");
				local value = getglobal(itemUI .. "Value");
				-- local txtValue = "#cdfdbc9" .. detailList[i].basePoint .. "#n" .. "#c01c10f+" .. detailList[i].increment .. "#n";
				local txtValue = "#cdfdbc9" .. detailList[i].basePoint .. "#n" .. "#c01c10f"

				if detailList[i].increment >= 0 then
					txtValue = txtValue .. " +" .. detailList[i].increment .. "#n";
				else
					txtValue = txtValue .. " " .. detailList[i].increment .. "#n";
				end

				item:Show();
				item:SetPoint("topleft", detailFrameUI, "topleft", 0, y);
				title:SetText(detailList[i].title);
				title:SetAnchorOffset(8, 0);
				value:SetText(txtValue);
				icon:Hide();
				arrayIcon:Hide();
				y = y + itemHeight;
			else
				item:Hide();
			end
		end
	end,

	OnItemClick = function(self)
		local detailFrameUI = self.rootui .. "DetailFrame";
		local detailFrame = getglobal(detailFrameUI);
		local itemIndex = this:GetClientID();
		local groupIndex = this:GetParentFrame():GetClientID();

		if itemIndex <= 0 or groupIndex <= 0 then
			--点击的详情页的条目
			return;
		end

		if detailFrame:IsShown() and groupIndex == self.curGroupIndex and itemIndex == self.curItemIndex then
			detailFrame:Hide();
			self.curGroupIndex = 0;
			self.curItemIndex = 0;
		else
			if self.GroupList[groupIndex].itemList[itemIndex].detailList then
				detailFrame:Show();
				self.curGroupIndex = groupIndex;
				self.curItemIndex = itemIndex;
				self:updateItemChecked();
				self:updateDetailView();
			end
		end
	end,
};

function RoleFrameArmor_OnClick()
	if UseNew_BaseAttrFrame then
		PlayerBaseAttrSetter:EntryBtnClick();
	else
		local tips = getglobal("RoleFrameArmorTips");
		if not tips:IsShown() then
			tips:Show();
			UpdateRoleFrameArmorTips()
		else
			tips:Hide();
			getglobal("RoleFrameArmorTipsDesc"):Clear();
		end
	end
end

function UpdateRoleFrameArmorTips()
	if UseNew_BaseAttrFrame then
		if PlayerBaseAttrSetter then
			PlayerBaseAttrSetter:Update();
			return;
		end
	else
		--老的废弃
		local point = string.format("%.1f", MainPlayerAttrib:getArmorPointLua(0));
		local subInjury = string.format("%.1f", point/(point+20)*100); -- modify by null, 防御值从20->100了
		local text = GetS(441, point, subInjury).."\n";

		point = string.format("%.1f", GetCurEquipArmorPoint('armorrange'));
		subInjury = string.format("%.1f", point/(point+20)*100);
		text = text..GetS(4894, point, subInjury).."\n";

		point = string.format("%.1f", GetCurEquipArmorPoint('armormagic'));
		subInjury = string.format("%.1f", point/(point+20)*100);
		text = text..GetS(4895, point, subInjury).."\n\n";

		text = text..GetS(444).."\n"..GetS(445);

		getglobal("RoleFrameArmorTipsDesc"):SetText(text, 255, 255, 255);
	end
end

function RoleFrameArmorTips_OnClick()
	getglobal("RoleFrameArmorTips"):Hide();
	getglobal("RoleFrameArmorTipsDesc"):Clear();
end

--天赋特长入口
function RoleFrame_GeniusBtn_OnClick()
	if not GetInst("GeniusMgr"):IsOpenGeniusSys() then
		return
	end

	RoleFrame_ReportGeniusBtnRef("click")

	if not GetInst("GeniusMgr"):IsEnableSpecialProp() then
		ShowGameTipsWithoutFilter(GetS(111349))--"当前地图作者禁止使用特长"
		return
	end

	--1.个人中心、2.开始游戏 3.游戏内背包 4.仓库使用
	GetInst("GeniusMgr"):OpenGenius({from = 3})
end

--上报天赋特长按钮相关埋点
function RoleFrame_ReportGeniusBtnRef(eventName)
	local enableSpecialProp = GetInst("GeniusMgr"):IsEnableSpecialProp()
	--standby1: 特长类型_等级（未装备特长时显示0）
	--standby2:1.禁用 2.使用

	local stb1 = 0
	local gType = GetInst("GeniusMgr"):GetCurGeniusType()
	if gType then
		local gLv = GetInst("GeniusMgr"):GetGeniusLvByType(gType)
		stb1 = gType.."_"..gLv
	end

	local stb2 = enableSpecialProp and 2 or 1
	if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then
		standReportEvent("1003", "MINI_TOOL_BAR_BAG", "Skill", eventName, {standby1=stb1, standby2=stb2}) 
	else
		standReportEvent("1001", "MINI_TOOL_BAR_BAG", "Skill", eventName, {standby1=stb1, standby2=stb2}) 
	end
end

function SetBackpackCheckPaintGrid(bl)
	bSelectPaintGrid = bl
	if bl then
		getglobal("RoleFramePaintGridCheck"):Show()
	else
		getglobal("RoleFramePaintGridCheck"):Hide()
		if getglobal("MItemTipsFrame"):IsShown() then
			getglobal("MItemTipsFrame"):Hide();
		end
	end
end

-------------------------------------------------------ComposeFrame---------------------------------------------------------

--特长相关事件注册
function RoleFrame_GeniusSubscibeEvents()
	local eventsTab = {
		{name = "RespUpgradeGenius", 		callback = RoleFrame_GeniusEquipCallback},     		--激活、升级天赋
		{name = "RespEquipGenius", 			callback = RoleFrame_GeniusDemoutCallback},     		--装备天赋
		{name = "RespDemountGenius", 		callback = RoleFrame_GeniusUpgradeCallback},     		--卸下天赋
	}

	for _, eventInfo in pairs(eventsTab) do
        local eventName = eventInfo.name
        local callback = eventInfo.callback

        if not eventName or not callback then
            return
        end

        SandboxLua.eventDispatcher:CreateEvent(nil, eventName)
        SandboxLua.eventDispatcher:SubscribeEvent (nil, eventName,
            function(context)
                local param = context:GetParamData()
                if not param then
                    return
                end

				--因为该事件目前处理的都是ui更新，所以如果该页面没显示的话，就直接丢弃了
				--后期如果有需要的话 就可以放开
				if not getglobal("RoleFrame"):IsShown() then
					return
				end

                return callback(param)
            end
        )
    end
end

--天赋装备回调
function RoleFrame_GeniusEquipCallback(param)
	local code = param.code
	if code == ErrorCode.OK then
		RoleFrame_UpdateGenius()
	end
end

--天赋卸下回调
function RoleFrame_GeniusDemoutCallback(param)
	local code = param.code
	if code == ErrorCode.OK then
		RoleFrame_UpdateGenius()
	end
end

--天赋激活\升级回调
function RoleFrame_GeniusUpgradeCallback(param)
	local code = param.code
	if code == ErrorCode.OK then
		RoleFrame_UpdateGenius()
	end
end