ENCHANT_GRID_MAX 		= 30;
ENCHANT_RANDOM_GRID_MAX 	= 40;
ENCHANT_ATTR_MAX	= 5;		--最大属性条数
Enchant_Type		= 1;  		--1对物品附魔，2对卷轴附魔
EnchantBoxType		= 0;		--0合并附魔上面的格子 1合并附魔下面的格子 2随机附魔格子
EnchantAttrBtnName	= nil;		--要显示tips的属性条控件名
IsExchange		= false;

local EnchantItemGridBlink = 6;		--放到格子的时候闪的次数;
local destGridIndex	= nil;		--目标格子的Index;
local fromGridIndex 	= nil;		--源格子的Index;

function getEnchantGridIndex(btnName)
	if string.find(btnName, "EnchantFrameEnchantItem1") then
		return destGridIndex;
	elseif string.find(btnName, "EnchantFrameEnchantItem2") then
		return fromGridIndex;
	end

	return -1;
end

function EnchantCloseBtn_OnMouseDown()
	local btnIcon = getglobal("EnchantFrameCloseBtnIcon");
	btnIcon:SetTexUV(396,226,33,33);
	btnIcon:SetSize(37,37);
end

function EnchantCloseBtn_OnMouseUp()
	local btnIcon = getglobal("EnchantFrameCloseBtnIcon");
	btnIcon:SetTexUV(351,222,42,43);
	btnIcon:SetSize(47,48);
end

function EnchantFrameCloseBtn_OnClick()
	getglobal("RoleAttrFrame"):Hide();
	getglobal("EnchantFrame"):Hide();
end

function EnchantFrame_OnLoad()
	this:setUpdateTime(0.05);
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	this:RegisterEvent("GE_PLAYERATTR_CHANGE")
	this:RegisterEvent("GE_ENCHANT_RESULT");
	EnchantFrame_AddGameEvent()
	for i=1,ENCHANT_GRID_MAX/6 do
		for j=1,6 do
			local itembtn = getglobal("EnchantTopBoxItem"..((i-1)*6+j));
			itembtn:SetPoint("topleft", "EnchantTopBoxPlane", "topleft", (j-1)*85, (i-1)*83);
		end
	end

	for i=1,ENCHANT_GRID_MAX/6 do
		for j=1,6 do
			local itembtn = getglobal("EnchantBottomBoxItem"..((i-1)*6+j));
			itembtn:SetPoint("topleft", "EnchantBottomBoxPlane", "topleft", (j-1)*85, (i-1)*83);
		end
	end

	for i=1,ENCHANT_RANDOM_GRID_MAX/6+1 do
		for j=1,6 do
			if (i-1)*6+j <= ENCHANT_RANDOM_GRID_MAX then
				local itembtn = getglobal("EnchantRandomBoxItem"..((i-1)*6+j));
				itembtn:SetPoint("topleft", "EnchantRandomBoxPlane", "topleft", (j-1)*82, (i-1)*82);
			end
		end
	end

	for i=1, ENCHANT_ATTR_MAX do	
		local attr 	= getglobal("EnchantFrameAttr"..i);
		attr:SetPoint("topright", "EnchantFrameBkg", "topright", -51, (i-1)*42+144);
	end 

	for i=1, 2 do
		local bkg = getglobal("EnchantFrameEnchantItem"..i.."BkgTexture");
		bkg:SetTextureHuiresXml("ui/mobile/texture2/common.xml");
		bkg:SetTexUV("img_icon_lignt.png");
	end
end

function EnchantFrame_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local enchantFrame = getglobal("EnchantFrame");
		if enchantFrame:IsShown() then
			local paramData = context:GetParamData()
			local grid_index = paramData.gridIndex
			--改
			if grid_index and grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX+1006 then
				UpdateEnchantBoxGrid();
			end

			if destGridIndex ~= nil and destGridIndex == grid_index then
				UpdateEnchantItemGrid();
			end
		end
	end)
	SubscribeGameEvent(nil,GameEventType.PlayerAttrChange,function(context)
		if enchantFrame:IsShown() then
			local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
			local enchantFrameStarText = getglobal("EnchantFrameStarText");
			enchantFrameStarText:SetText(starNum);
		end
	end)
end

function EnchantFrame_OnEvent()
	local enchantFrame = getglobal("EnchantFrame");
	if arg1 == "GE_BACKPACK_CHANGE" then		
		if enchantFrame:IsShown() then
			local ge = GameEventQue:getCurEvent();
			local grid_index = ge.body.backpack.grid_index;
			--改
			if grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX+1006 then
				UpdateEnchantBoxGrid();
			end

			if destGridIndex ~= nil and destGridIndex == grid_index then
				UpdateEnchantItemGrid();
			end
		end	
	elseif arg1 == "GE_PLAYERATTR_CHANGE" then
		if enchantFrame:IsShown() then
			local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
			local enchantFrameStarText = getglobal("EnchantFrameStarText");
			enchantFrameStarText:SetText(starNum);
		end
	elseif arg1 == "GE_ENCHANT_RESULT" then
		if enchantFrame:IsShown() then		
			if destGridIndex ~= nil then
				local itemId = ClientBackpack:getGridItem(destGridIndex);
				local itemDef = ItemDefCsv:get(itemId);
				local text = GetS(79, itemDef.Name);
				ShowGameTips(text, 1);

				local enchantFrameEnchantItem1UvAnimation = getglobal("EnchantFrameEnchantItem1UvAnimation");
				enchantFrameEnchantItem1UvAnimation:SetUVAnimation(120, false);	
			end
			
			local ge = GameEventQue:getCurEvent();
			destGridIndex = ge.body.backpack.grid_index;	
			fromGridIndex = nil;
			t_ChooseEnchantAttr = {};

			UpdateEnchantItemGrid();
			UpdateEnchantBoxGrid()
		end
	end
end

function UpdateEnchatAllBox(grid_index)
	SetEnchantGrid(EnchantBoxType, grid_index);
	if Enchant_Type == 1 then
		for i=1, ENCHANT_RANDOM_GRID_MAX do
			local randomItem 	= getglobal("EnchantRandomBoxItem"..i);
			local randomItemIcon 	= getglobal("EnchantRandomBoxItem"..i.."Icon");
			local randomItemNum 	= getglobal("EnchantRandomBoxItem"..i.."Count");
			local randomItemDurbar 	= getglobal("EnchantRandomBoxItem"..i.."Duration");

			local clientId = randomItem:GetClientID();		
			if clientId > 0 then
				grid_index = clientId - 1;
				if ClientBackpack:getGridItem(grid_index) == 0 then
					randomItem:SetClientID(0);
				end
				UpdateItemIconCount(randomItemIcon, randomItemNum, randomItemDurbar, grid_index);
			else
				randomItem:SetClientID(0);
				randomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
				randomItemNum:SetText("");
				randomItemDurbar:Hide();
				getglobal(randomItemIcon:GetName().."FumoEffect1").Hide();
				getglobal(randomItemIcon:GetName().."FumoEffect2").Hide();
			end
		end
	elseif Enchant_Type == 2 then
		for i=1, ENCHANT_GRID_MAX do
			local topItem 		= getglobal("EnchantTopBoxItem"..i);
			local topItemIcon 	= getglobal("EnchantTopBoxItem"..i.."Icon");
			local topItemNum 	= getglobal("EnchantTopBoxItem"..i.."Count");
			local topItemDurbar 	= getglobal("EnchantTopBoxItem"..i.."Duration");

			local clientId 		= topItem:GetClientID();		
			if clientId > 0 then
				grid_index = clientId - 1;
				if ClientBackpack:getGridItem(grid_index) == 0 then
					topItem:SetClientID(0);
				end
				UpdateItemIconCount(topItemIcon, topItemNum, topItemDurbar, grid_index);
			else
				topItem:SetClientID(0);
				topItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
				topItemNum:SetText("");
				topItemDurbar:Hide();
				getglobal(topItemIcon:GetName().."FumoEffect1").Hide();
				getglobal(topItemIcon:GetName().."FumoEffect2").Hide();
			end
		end

		for i=1, ENCHANT_GRID_MAX do
			local bottomItem 	= getglobal("EnchantBottomBoxItem"..i);
			local bottomItemIcon	= getglobal("EnchantBottomBoxItem"..i.."Icon");
			local bottomItemNum	= getglobal("EnchantBottomBoxItem"..i.."Count");
			local bottomItemDurbar  = getglobal("EnchantBottomBoxItem"..i.."Duration");

			local clientId 		= bottomItem:GetClientID();		
			if clientId > 0 then
				grid_index = clientId - 1;
				if ClientBackpack:getGridItem(grid_index) == 0 then
					bottomItem:SetClientID(0);
				end
				UpdateItemIconCount(bottomItemIcon, bottomItemNum, bottomItemDurbar, grid_index);
			else
				bottomItem:SetClientID(0);
				bottomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
				bottomItemNum:SetText("");
				bottomItemDurbar:Hide();
				getglobal(bottomItemIcon:GetName().."FumoEffect1").Hide();
				getglobal(bottomItemIcon:GetName().."FumoEffect2").Hide();
			end
		end
	end
end

function EnchantFrame_OnShow()
	HideEnchantAllBoxTexture();
	destGridIndex = nil;
	fromGridIndex = nil;

	if Enchant_Type == 1 then
		local enchantRandomBox = getglobal("EnchantRandomBox");
		enchantRandomBox:resetOffsetPos();
		getglobal("EnchantFrameMask"):Hide();
--		getglobal("EnchantFrameCloseBtn"):Hide();
		getglobal("EnchantFrameBkg1"):Show();
		getglobal("EnchantFrameBkg2"):Show();
		getglobal("EnchantFrameBkg3"):Hide();
		getglobal("EnchantFrameBkg4"):Hide();
	elseif Enchant_Type == 2 then
		local enchantTopBox = getglobal("EnchantTopBox");
		enchantTopBox:resetOffsetPos();
		local enchantBottomBox = getglobal("EnchantBottomBox");
		enchantBottomBox:resetOffsetPos();
		getglobal("EnchantFrameMask"):Show();
		getglobal("EnchantFrameCloseBtn"):Show();
		getglobal("EnchantFrameBkg1"):Hide();
		getglobal("EnchantFrameBkg2"):Hide();
		getglobal("EnchantFrameBkg3"):Show();
		getglobal("EnchantFrameBkg4"):Show();
	end	
	for i=1, 5 do 
		local attr = getglobal("EnchantFrameAttr"..i);
		attr:Hide();
		local desc = getglobal("EnchantFrameAttr"..i.."Desc");
		desc:Clear();
	
		attr:SetClientUserData(0, 0);
		attr:SetClientUserData(1, 0);
		attr:SetClientUserData(2, 0);
	end

	local enchantFrameTitle1 = getglobal("EnchantFrameTitle1");
	local enchantFrameTitle2 = getglobal("EnchantFrameTitle2");
	local enchantFrameEnchantItem2 = getglobal("EnchantFrameEnchantItem2");
	local enchantFrameArrow2 = getglobal("EnchantFrameArrow2");
	local enchantFrameEnchantItem1Name = getglobal("EnchantFrameEnchantItem1Name");
	local enchantFrameEnchantItem2Name = getglobal("EnchantFrameEnchantItem2Name");

	if Enchant_Type ==  1 then
		enchantFrameTitle1:SetText(GetS(75));
		enchantFrameTitle2:Hide();
		enchantFrameEnchantItem2:Hide();
		enchantFrameArrow2:Hide();

		enchantFrameEnchantItem1Name:SetText(GetS(474));
		enchantFrameEnchantItem2Name:SetText("");
	elseif Enchant_Type == 2 then
		enchantFrameTitle1:SetText(GetS(76));
		enchantFrameTitle2:Show();
		enchantFrameTitle2:SetText(GetS(77));

		enchantFrameEnchantItem2:Show();
		enchantFrameArrow2:Show();

		enchantFrameEnchantItem1Name:SetText(GetS(475));
		enchantFrameEnchantItem2Name:SetText(GetS(476));
	end

	local enchantFrameEnchantBtn = getglobal("EnchantFrameEnchantBtn");
	enchantFrameEnchantBtn:Hide();
	local enchantFrameText = getglobal("EnchantFrameText");
	enchantFrameText:Hide();

	UpdateEnchantBoxGrid();
	UpdateEnchantItemGrid();

	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	local enchantFrameStarText = getglobal("EnchantFrameStarText");
	enchantFrameStarText:SetText(starNum);
	
	if not getglobal("EnchantFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end

	if gIsSingleGame then getglobal("EnchantFrameAddStar"):Hide() end
end

--type 0合并附魔上面格子 1合并附魔下面格子 2随机附魔格子
function SetEnchantGrid(type, grid_index)
	if type == 0 then
		for i=1, ENCHANT_GRID_MAX do
			local topItem 		= getglobal("EnchantTopBoxItem"..i);
			local topItemIcon 	= getglobal("EnchantTopBoxItem"..i.."Icon");
			local topItemNum 	= getglobal("EnchantTopBoxItem"..i.."Count");
			local topItemDurbar 	= getglobal("EnchantTopBoxItem"..i.."Duration");

			local clientId = topItem:GetClientID();
			if clientId ~= 0 and clientId == grid_index+1 then
				if ClientBackpack:getGridItem(grid_index) > 0 then
					UpdateItemIconCount(topItemIcon, topItemNum, topItemDurbar, grid_index);
				else
					topItem:SetClientID(0);
					topItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
					topItemNum:SetText("");
					topItemDurbar:Hide();
					getglobal(topItemIcon:GetName().."FumoEffect1").Hide();
					getglobal(topItemIcon:GetName().."FumoEffect2").Hide();
				end
				return;
			end
		end

		for i=1, ENCHANT_GRID_MAX do
			local topItem 		= getglobal("EnchantTopBoxItem"..i);
			local topItemIcon 	= getglobal("EnchantTopBoxItem"..i.."Icon");
			local topItemNum 	= getglobal("EnchantTopBoxItem"..i.."Count");
			local topItemDurbar 	= getglobal("EnchantTopBoxItem"..i.."Duration");

			if topItem:GetClientID() == 0 then
				if ClientBackpack:getGridItem(grid_index) > 0 then
					topItem:SetClientID(grid_index+1);
					UpdateItemIconCount(topItemIcon, topItemNum, topItemDurbar, grid_index);
					return;
				end
			end
		end
	elseif type == 1 then 
		local isPut = false;
		for i=1, ENCHANT_GRID_MAX do
			local bottomItem 	= getglobal("EnchantBottomBoxItem"..i);
			local bottomItemIcon	= getglobal("EnchantBottomBoxItem"..i.."Icon");
			local bottomItemNum	= getglobal("EnchantBottomBoxItem"..i.."Count");
			local bottomItemDurbar  = getglobal("EnchantBottomBoxItem"..i.."Duration");

			local clientId = bottomItem:GetClientID();
			if clientId ~= 0 and clientId == grid_index+1 then
				if ClientBackpack:getGridItem(grid_index) > 0 then
					UpdateItemIconCount(bottomItemIcon, bottomItemNum, bottomItemDurbar, grid_index);
				else
					bottomItem:SetClientID(0);
					bottomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
					bottomItemNum:SetText("");
					bottomItemDurbar:Hide();
					getglobal(bottomItemIcon:GetName().."FumoEffect1").Hide();
					getglobal(bottomItemIcon:GetName().."FumoEffect2").Hide();
				end
				isPut =  true;
				break;
			end
		end

		if not isPut then
			for i=1, ENCHANT_GRID_MAX do
				local bottomItem 	= getglobal("EnchantBottomBoxItem"..i);
				local bottomItemIcon	= getglobal("EnchantBottomBoxItem"..i.."Icon");
				local bottomItemNum	= getglobal("EnchantBottomBoxItem"..i.."Count");
				local bottomItemDurbar  = getglobal("EnchantBottomBoxItem"..i.."Duration");

				if bottomItem:GetClientID() == 0 then
					if ClientBackpack:getGridItem(grid_index) > 0 then
						bottomItem:SetClientID(grid_index+1);
						UpdateItemIconCount(bottomItemIcon, bottomItemNum, bottomItemDurbar, grid_index);
						return;
					end
				end
			end
		end

		local itemId = ClientBackpack:getGridItem(grid_index);
		if itemId > 0 and not IsExchange then
			for i=1, ENCHANT_GRID_MAX do
				local topItem 		= getglobal("EnchantTopBoxItem"..i);
				local topItemIcon 	= getglobal("EnchantTopBoxItem"..i.."Icon");
				local topItemNum 	= getglobal("EnchantTopBoxItem"..i.."Count");
				local topItemDurbar 	= getglobal("EnchantTopBoxItem"..i.."Duration");

				if topItem:GetClientID() == 0 then
					topItem:SetClientID(grid_index+1);
					UpdateItemIconCount(topItemIcon, topItemNum, topItemDurbar, grid_index);
					break;
				end
			end
		end
	elseif type == 2 then
		for i=1, ENCHANT_RANDOM_GRID_MAX do
			local randomItem 	= getglobal("EnchantRandomBoxItem"..i);
			local randomItemIcon 	= getglobal("EnchantRandomBoxItem"..i.."Icon");
			local randomItemNum 	= getglobal("EnchantRandomBoxItem"..i.."Count");
			local randomItemDurbar 	= getglobal("EnchantRandomBoxItem"..i.."Duration");

			local clientId = randomItem:GetClientID();		
			if clientId ~= 0 and clientId == grid_index+1 then
				if ClientBackpack:getGridItem(grid_index) > 0 then
					UpdateItemIconCount(randomItemIcon, randomItemNum, randomItemDurbar, grid_index);
				else
					randomItem:SetClientID(0);
					randomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
					randomItemNum:SetText("");
					randomItemDurbar:Hide();
					getglobal(randomItemIcon:GetName().."FumoEffect1").Hide();
					getglobal(randomItemIcon:GetName().."FumoEffect2").Hide();
				end
				return;
			end
		end

		for i=1, ENCHANT_RANDOM_GRID_MAX do
			local randomItem 	= getglobal("EnchantRandomBoxItem"..i);
			local randomItemIcon 	= getglobal("EnchantRandomBoxItem"..i.."Icon");
			local randomItemNum 	= getglobal("EnchantRandomBoxItem"..i.."Count");
			local randomItemDurbar 	= getglobal("EnchantRandomBoxItem"..i.."Duration");

			if randomItem:GetClientID() == 0 then
				if ClientBackpack:getGridItem(grid_index) > 0 then
					randomItem:SetClientID(grid_index+1);
					UpdateItemIconCount(randomItemIcon, randomItemNum, randomItemDurbar, grid_index);
					return;
				end
			end
		end
	end
end

local t_RandomBoxGrid = {};
local t_topBoxGrid = {};
--设置格子的物品
function SetEnchantBoxGrid()
	if Enchant_Type == 1 then		--随机附魔
		for i=1, ENCHANT_RANDOM_GRID_MAX do
			local randomItem 	= getglobal("EnchantRandomBoxItem"..i);
			local randomItemIcon 	= getglobal("EnchantRandomBoxItem"..i.."Icon");
			local randomItemNum 	= getglobal("EnchantRandomBoxItem"..i.."Count");
			local randomItemDurbkg 	= getglobal("EnchantRandomBoxItem"..i.."DurBkg");
			local randomItemDurbar 	= getglobal("EnchantRandomBoxItem"..i.."Duration");
			
			local grid_index = randomItem:GetClientID() - 1;
			if grid_index >= 0 then
				local num = ClientBackpack:getGridNum(grid_index);
				if destGridIndex ~= nil and grid_index == destGridIndex then
					num = num - 1;	
				end
				if num <= 0 then
					randomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
					randomItemNum:SetText("");
					randomItemDurbar:Hide();
					randomItemDurbkg:Hide();
					getglobal(randomItemIcon:GetName().."FumoEffect1").Hide();
					getglobal(randomItemIcon:GetName().."FumoEffect2").Hide();
				else
					UpdateVirtualItemIcon(randomItemIcon, randomItemNum, randomItemDurbar, grid_index, num, randomItemDurbkg);
				end
			else
				randomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
				randomItemNum:SetText("");
				randomItemDurbar:Hide();
				randomItemDurbkg:Hide();
				getglobal(randomItemIcon:GetName().."FumoEffect1").Hide();
				getglobal(randomItemIcon:GetName().."FumoEffect2").Hide();
			end
		end
		
	elseif Enchant_Type == 2 then		--合并附魔
		for i=1, ENCHANT_GRID_MAX do
			local topItem 		= getglobal("EnchantTopBoxItem"..i);
			local topItemIcon 	= getglobal("EnchantTopBoxItem"..i.."Icon");
			local topItemNum 	= getglobal("EnchantTopBoxItem"..i.."Count");
			local topItemDurbkg 	= getglobal("EnchantTopBoxItem"..i.."DurBkg");
			local topItemDurbar 	= getglobal("EnchantTopBoxItem"..i.."Duration");
			
			local grid_index = topItem:GetClientID() - 1;
			if grid_index >= 0 then
				local num = ClientBackpack:getGridNum(grid_index);
				if destGridIndex ~= nil and grid_index == destGridIndex then
					num = num - 1;	
				end
				if num <= 0 then
					topItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
					topItemNum:SetText("");
					topItemDurbar:Hide();
					topItemDurbkg:Hide();
					getglobal(topItemIcon:GetName().."FumoEffect1").Hide();
					getglobal(topItemIcon:GetName().."FumoEffect2").Hide();
				else
					UpdateVirtualItemIcon(topItemIcon, topItemNum, topItemDurbar, grid_index, num, topItemDurbkg);
				end
			else
				topItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
				topItemNum:SetText("");
				topItemDurbar:Hide();
				topItemDurbkg:Hide();
				getglobal(topItemIcon:GetName().."FumoEffect1").Hide();
				getglobal(topItemIcon:GetName().."FumoEffect2").Hide();
			end
		end
	end 
end

--背包变化， 重新更新格子
function UpdateEnchantBoxGrid()
	local enchantRandomBox = getglobal("EnchantRandomBox");
	local enchantTopBox = getglobal("EnchantTopBox");
	local enchantBottomBox = getglobal("EnchantBottomBox");

	if Enchant_Type == 1 then		--随机附魔
		t_RandomBoxGrid = {};
		enchantRandomBox:Show();
		enchantTopBox:Hide();
		enchantBottomBox:Hide();

		for i=1, BACK_PACK_GRID_MAX do
			local grid_index = BACKPACK_START_INDEX + i - 1;
			local itemId = ClientBackpack:getGridItem(grid_index);
			local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
			local itemDef = ItemDefCsv:get(itemId);	
			if itemDef ~= nil then
				if itemDef.EnchantTag > 0 then
					table.insert(t_RandomBoxGrid, {index=grid_index, num=enchantNum});
				end
			end
		end
		for i=1, MAX_SHORTCUT do
			local grid_index = ClientBackpack:getShortcutStartIndex() + i - 1;
			local itemId = ClientBackpack:getGridItem(grid_index);
			local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
			local itemDef = ItemDefCsv:get(itemId);
			if itemDef ~= nil then
				if itemDef.EnchantTag > 0 then
					table.insert(t_RandomBoxGrid, {index=grid_index, num=enchantNum});
				end
			end
		end
		for i=1, 5 do
			local grid_index = EQUIP_START_INDEX + i - 1;
			local itemId = ClientBackpack:getGridItem(grid_index);
			local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
			local itemDef = ItemDefCsv:get(itemId);
			if itemDef ~= nil then
				if itemDef.EnchantTag > 0 then
					table.insert(t_RandomBoxGrid, {index=grid_index, num=enchantNum});
				end
			end
		end

		if #(t_RandomBoxGrid) > 1 then
			table.sort(t_RandomBoxGrid,
				 function(a,b)
					if a.num > 0 and b.num == 0  then
						return true
					end
				 end
				);
		end
		
		--再改
		for i=1, ENCHANT_RANDOM_GRID_MAX do
			local randomItem 	= getglobal("EnchantRandomBoxItem"..i);
			local randomItemIcon 	= getglobal("EnchantRandomBoxItem"..i.."Icon");
			local randomItemNum 	= getglobal("EnchantRandomBoxItem"..i.."Count");
			local randomItemDurbkg 	= getglobal("EnchantRandomBoxItem"..i.."DurBkg");
			local randomItemDurbar 	= getglobal("EnchantRandomBoxItem"..i.."Duration");

			if i <= #(t_RandomBoxGrid) then
				randomItem:SetClientID(t_RandomBoxGrid[i].index+1);

				local canShow = true;
				local num = ClientBackpack:getGridNum(t_RandomBoxGrid[i].index);
				if destGridIndex ~= nil and t_RandomBoxGrid[i].index == destGridIndex then
					num = num - 1;
					if num <= 0 then
						canShow = false;		
					end
				end
				
				if canShow then
					UpdateVirtualItemIcon(randomItemIcon, randomItemNum, randomItemDurbar, t_RandomBoxGrid[i].index, num, randomItemDurbkg);
				else
					randomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
					randomItemNum:SetText("");
					randomItemDurbar:Hide();
					randomItemDurbkg:Hide();
					getglobal(randomItemIcon:GetName().."FumoEffect1"):Hide();
					getglobal(randomItemIcon:GetName().."FumoEffect2"):Hide();
				end
			else
				randomItem:SetClientID(0);
				randomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
				randomItemNum:SetText("");
				randomItemDurbar:Hide();
				randomItemDurbkg:Hide();
				getglobal(randomItemIcon:GetName().."FumoEffect1"):Hide();
				getglobal(randomItemIcon:GetName().."FumoEffect2"):Hide();
			end	
		end
	elseif Enchant_Type == 2 then		--合并附魔
		t_topBoxGrid = {};
		enchantRandomBox:Hide();
		enchantTopBox:Show();
		enchantBottomBox:Show();

		for i=1, BACK_PACK_GRID_MAX do
			local grid_index = BACKPACK_START_INDEX + i - 1;
			local itemId = ClientBackpack:getGridItem(grid_index);
			local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
			local itemDef = ItemDefCsv:get(itemId);	
			if itemDef ~= nil and itemDef.EnchantTag > 0 then
				table.insert(t_topBoxGrid, {index=grid_index, num=enchantNum});
			end
		end
		for i=1, MAX_SHORTCUT do
			local grid_index = ClientBackpack:getShortcutStartIndex() + i - 1;
			local itemId = ClientBackpack:getGridItem(grid_index);
			local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
			local itemDef = ItemDefCsv:get(itemId);
			if itemDef ~= nil and itemDef.EnchantTag > 0 then
				table.insert(t_topBoxGrid, {index=grid_index, num=enchantNum});
			end
		end
		for i=1, 5 do
			local grid_index = EQUIP_START_INDEX + i - 1;
			local itemId = ClientBackpack:getGridItem(grid_index);
			local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
			local itemDef = ItemDefCsv:get(itemId);
			if itemDef ~= nil and itemDef.EnchantTag > 0 then
				table.insert(t_topBoxGrid, {index=grid_index, num=enchantNum});
			end
		end

		if #(t_topBoxGrid) > 1 then
			table.sort(t_topBoxGrid,
				 function(a,b)
					if a.num > 0 and b.num == 0  then
						return true
					end
				 end
				);
		end

		--再改
		for i=1, ENCHANT_GRID_MAX do
			local topItem 		= getglobal("EnchantTopBoxItem"..i);
			local topItemIcon 	= getglobal("EnchantTopBoxItem"..i.."Icon");
			local topItemNum 	= getglobal("EnchantTopBoxItem"..i.."Count");
			local topItemDurbkg 	= getglobal("EnchantTopBoxItem"..i.."DurBkg");
			local topItemDurbar 	= getglobal("EnchantTopBoxItem"..i.."Duration");

			if i <= #(t_topBoxGrid) then
				topItem:SetClientID(t_topBoxGrid[i].index+1);

				local canShow = true;
				local num = ClientBackpack:getGridNum(t_topBoxGrid[i].index);
				if destGridIndex ~= nil and t_topBoxGrid[i].index == destGridIndex then
					num = num - 1;
					if num <= 0 then
						canShow = false;		
					end
				end
				if fromGridIndex ~= nil and t_topBoxGrid[i].index == fromGridIndex then
					num = num - 1;
					if num <= 0 then
						canShow = false;		
					end
				end
				
				if canShow then
					UpdateVirtualItemIcon(topItemIcon, topItemNum, topItemDurbar, t_topBoxGrid[i].index, num, topItemDurbkg);
				else
					topItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
					topItemNum:SetText("");
					topItemDurbar:Hide();
					topItemDurbkg:Hide();
					getglobal(topItemIcon:GetName().."FumoEffect1"):Hide();
					getglobal(topItemIcon:GetName().."FumoEffect2"):Hide();
				end
			else
				topItem:SetClientID(0);
				topItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
				topItemNum:SetText("");
				topItemDurbar:Hide();
				topItemDurbkg:Hide();
				getglobal(topItemIcon:GetName().."FumoEffect1"):Hide();
				getglobal(topItemIcon:GetName().."FumoEffect2"):Hide();
			end	
		end
	end

	if getglobal("MiniProductBox"):IsShown() then
		ShowGameTips("MiniProductBox show", 3);
	end
end

function UpdateEnchantBottomBoxGrid(itemId, type, stuffType)
	local t_bottomBoxGrid = {};
	for i=1, BACK_PACK_GRID_MAX do
		local grid_index = BACKPACK_START_INDEX + i - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		if itemId > 0 then
			local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
			local itemDef = ItemDefCsv:get(itemId);
			local toolDef = ToolDefCsv:get(itemDef.ID);
			if toolDef ~= nil and itemDef ~= nil then
				if enchantNum > 0 and ((toolDef.Type == type and stuffType == itemDef.StuffType) or itemId == 11807) then
					table.insert(t_bottomBoxGrid, grid_index);	
				end
			end
		end
	end
	for i=1, MAX_SHORTCUT do
		local grid_index = ClientBackpack:getShortcutStartIndex() + i - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		if itemId > 0 then
			local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
			local itemDef = ItemDefCsv:get(itemId);
			local toolDef = ToolDefCsv:get(itemDef.ID);
			if toolDef ~= nil and itemDef ~= nil then
				if enchantNum > 0 and ((toolDef.Type == type and stuffType == itemDef.StuffType) or itemId == 11807) then
					table.insert(t_bottomBoxGrid, grid_index);	
				end
			end
		end
	end
	for i=1, 5 do
		local grid_index = EQUIP_START_INDEX + i - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);
		if itemId > 0 then
			local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
			local itemDef = ItemDefCsv:get(itemId);
			local toolDef = ToolDefCsv:get(itemDef.ID);
			if toolDef ~= nil and itemDef ~= nil then
				if enchantNum > 0 and ((toolDef.Type == type and stuffType == itemDef.StuffType) or itemId == 11807) then
					table.insert(t_bottomBoxGrid, grid_index);	
				end
			end
		end
	end

	--改	
	local index = 0;
	local showNum = 0;
	for i=1, #(t_bottomBoxGrid) do
		local canShow = true;
		local num = ClientBackpack:getGridNum(t_bottomBoxGrid[i] );
		if destGridIndex ~= nil and t_bottomBoxGrid[i] == destGridIndex then
			num = num - 1;
			if num <= 0 then
				canShow = false;		
			end
		end
		if fromGridIndex ~= nil and t_bottomBoxGrid[i] == fromGridIndex then
			num = num - 1;
			if num <= 0 then
				canShow = false;		
			end
		end

		if canShow and i <= ENCHANT_GRID_MAX then
			index = index + 1;
			showNum = showNum + 1;
			local bottomItem 	= getglobal("EnchantBottomBoxItem"..index);
			local bottomItemIcon 	= getglobal("EnchantBottomBoxItem"..index.."Icon");
			local bottomItemNum 	= getglobal("EnchantBottomBoxItem"..index.."Count");
			local bottomItemDurbkg 	= getglobal("EnchantBottomBoxItem"..index.."DurBkg");
			local bottomItemDurbar 	= getglobal("EnchantBottomBoxItem"..index.."Duration");
			
			bottomItem:SetClientID(t_bottomBoxGrid[i]+1);
			UpdateVirtualItemIcon(bottomItemIcon, bottomItemNum, bottomItemDurbar, t_bottomBoxGrid[i], num, bottomItemDurbkg);
		end
	end
	for i=showNum+1, ENCHANT_GRID_MAX do
		local bottomItem 	= getglobal("EnchantBottomBoxItem"..i);
		local bottomItemIcon 	= getglobal("EnchantBottomBoxItem"..i.."Icon");
		local bottomItemNum 	= getglobal("EnchantBottomBoxItem"..i.."Count");
		local bottomItemDurbkg 	= getglobal("EnchantBottomBoxItem"..i.."DurBkg");
		local bottomItemDurbar 	= getglobal("EnchantBottomBoxItem"..i.."Duration");

		bottomItem:SetClientID(0);
		bottomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
		bottomItemNum:SetText("");
		bottomItemDurbar:Hide();
		bottomItemDurbkg:Hide();	
		getglobal(bottomItemIcon:GetName().."FumoEffect1"):Hide();
		getglobal(bottomItemIcon:GetName().."FumoEffect2"):Hide();
	end
end

function ClearEnchantStuff()
	local itemId = ClientBackpack:getGridItem(16000);
	local stuffId = ClientBackpack:getGridItem(16001);
	if stuffId > 0 and itemId > 0 then
		local itemToolDef = ToolDefCsv:get(itemId);
		local stuffToolDef = ToolDefCsv:get(stuffId);
		if stuffToolDef.Type == itemToolDef.Type or stuffId == 11807 then
			return
		end
	end

	local icon = getglobal("EnchantFrameEnchantItem2Icon");
	local num = getglobal("EnchantFrameEnchantItem2Count");
	local durbar = getglobal("EnchantFrameEnchantItem2Duration");

	icon:SetTextureHuires(ClientMgr:getNullItemIcon());
	num:SetText("");
	durbar:Hide();

	local stuffIndex = ENCHANT_START_INDEX+1;
	if ClientBackpack:getGridItem(stuffIndex) > 0 then	--清掉右边附魔材料格子
		local enchantNum = ClientBackpack:getGridEnchantNum(stuffIndex);
		if enchantNum  > 0 then							--附魔的物品, 不可叠加
			local togrid_index = GetPackFrameFristNullGridIndex();
			if togrid_index ~= -1 then
				CurMainPlayer:swapItem(stuffIndex, togrid_index);
			else
				CurMainPlayer:throwBackpackItem(stuffIndex, 1);
			end
		else
			BackPackAddItem(16000, 1, 1);
		end

		EnchantBoxType = 0;
	end

	--清掉左边附魔材料格子
	for i=1, ENCHANT_GRID_MAX do
		local bottomItem 	= getglobal("EnchantBottomBoxItem"..i);
		local bottomItemIcon	= getglobal("EnchantBottomBoxItem"..i.."Icon");
		local bottomItemNum	= getglobal("EnchantBottomBoxItem"..i.."Count");
		local bottomItemDurbar  = getglobal("EnchantBottomBoxItem"..i.."Duration");

		bottomItem:SetClientID(0);
		bottomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
		bottomItemNum:SetText("");
		bottomItemDurbar:Hide();
		getglobal(bottomItemIcon:GetName().."FumoEffect1"):Hide();
		getglobal(bottomItemIcon:GetName().."FumoEffect2"):Hide();
	end

	local mItemTipsFrame = getglobal("MItemTipsFrame");
	if mItemTipsFrame:IsShown() then
		mItemTipsFrame:Hide();
		HideEnchantAllBoxTexture();
	end
end

function UpdateEnchantItemGrid()
	--改
	for i=1, 2 do		
		local grid_index = destGridIndex;
		if i > 1 then
			grid_index = fromGridIndex;
		end

		local btn = getglobal("EnchantFrameEnchantItem"..i);
		local icon = getglobal("EnchantFrameEnchantItem"..i.."Icon");
		local num = getglobal("EnchantFrameEnchantItem"..i.."Count");
		local durbkg = getglobal("EnchantFrameEnchantItem"..i.."DurBkg");
		local durbar = getglobal("EnchantFrameEnchantItem"..i.."Duration");

		local enchantFrameArrow3 = getglobal("EnchantFrameArrow3");
		if grid_index ~= nil then
			UpdateVirtualItemIcon(icon, num, durbar, grid_index, 1, durbkg, btn);
			if destGridIndex and destGridIndex >= 0 and Enchant_Type == 2 then
				enchantFrameArrow3:Show();
			else
				enchantFrameArrow3:Hide();
			end
		else
			icon:SetTextureHuires(ClientMgr:getNullItemIcon());
			num:SetText("");
			durbar:Hide();
			durbkg:Hide();
			enchantFrameArrow3:Hide();
			btn:SetClientID(0);
			getglobal(icon:GetName().."FumoEffect1"):Hide();
			getglobal(icon:GetName().."FumoEffect2"):Hide();
		end
	end
	UpdateEnchatAttr();
end

t_EnchantAttrList = {};
local t_ChooseEnchantAttr = {};
function UpdateEnchatAttr()
	local enchantFrameEnchantBtnNormal = getglobal("EnchantFrameEnchantBtnNormal");
	enchantFrameEnchantBtnNormal:SetGray(false);
	local enchantFrameEnchantBtn = getglobal("EnchantFrameEnchantBtn");
	enchantFrameEnchantBtn:Enable();

	local enchantFrameText = getglobal("EnchantFrameText");
	local enchantFrameEnchantItem1Name = getglobal("EnchantFrameEnchantItem1Name");
	local enchantFrameEnchantBtnNormal = getglobal("EnchantFrameEnchantBtnNormal");
	local enchantFrameEnchantBtnName = getglobal("EnchantFrameEnchantBtnName");
	local enchantFrameEnchantBtnText = getglobal("EnchantFrameEnchantBtnText");
	local enchantFrameEnchantItem2Name = getglobal("EnchantFrameEnchantItem2Name");

	t_ChooseEnchantAttr = {};
	local itemId = destGridIndex ~= nil and ClientBackpack:getGridItem(destGridIndex) or 0;
	if itemId > 0 then
		for i=1, 5 do 
			local attr = getglobal("EnchantFrameAttr"..i);		
			attr:Show();
		end
		enchantFrameEnchantBtn:Show();		
		enchantFrameText:Show();

		local itemDef = ItemDefCsv:get(itemId);
		enchantFrameEnchantItem1Name:SetText(itemDef.Name);
		local stuffType = itemDef.StuffType;
		local enchantMentDef = DefMgr:getEnchantMentDef(stuffType);
		if enchantMentDef == NULL then return end;

		local toolDef = ToolDefCsv:get(itemDef.ID);
		if toolDef == NULL then return end;

		local itemEnchantNum = ClientBackpack:getGridEnchantNum(destGridIndex);

		if Enchant_Type == 1 then
			enchantFrameEnchantBtnName:SetText(GetS(3001));
			if itemEnchantNum ==  0 then	--随机附魔
				RandomEnchant(enchantMentDef, toolDef.Type);	
				for i=1, 5 do 
					local attr = getglobal("EnchantFrameAttr"..i);
					local desc = getglobal("EnchantFrameAttr"..i.."Desc");
					local arrow = getglobal("EnchantFrameAttr"..i.."UpArrow");
					
					if i == 1 then
						desc:SetText(GetS(67), 36, 180, 254);
					else
						desc:Clear();
					end
					arrow:Hide();
					attr:SetClientUserData(0, 0);
					attr:SetClientUserData(1, 0);
					attr:SetClientUserData(2, 0);
				end
				enchantFrameText:SetText(GetS(68));
				enchantFrameText:SetTextColor(247, 119, 15);
			else				
				enchantFrameEnchantBtnNormal:SetGray(true);
				enchantFrameEnchantBtn:Disable();
				enchantFrameText:SetText(GetS(69));
				enchantFrameText:SetTextColor(247, 119, 15);
				enchantFrameEnchantBtnText:SetText(0);
				enchantFrameEnchantBtnText:SetTextColor(255, 246, 0);	

				for i=1, 5 do 
					local attr = getglobal("EnchantFrameAttr"..i);
					local desc = getglobal("EnchantFrameAttr"..i.."Desc");
					local arrow = getglobal("EnchantFrameAttr"..i.."UpArrow");
					
					local text = "";
					if i <= itemEnchantNum then
						local id = ClientBackpack:getGridEnchantId(destGridIndex, i-1);
						local enchantDef = DefMgr:getEnchantDef(id);
						if enchantDef ~= nil then
							text = enchantDef.Name..enchantDef.EnchantLevel;
							desc:SetText(text, 36, 180, 254);

							attr:SetClientUserData(0, id);
							attr:SetClientUserData(1, 0);
							attr:SetClientUserData(2, 0);
						end
					else
						desc:Clear();
						attr:SetClientUserData(0, 0);
						attr:SetClientUserData(1, 0);
						attr:SetClientUserData(2, 0);
					end
					arrow:Hide();
				end		
			end
		elseif Enchant_Type == 2 then
			local stuffId = fromGridIndex ~= nil and ClientBackpack:getGridItem(fromGridIndex) or 0;
			UpdateEnchantBottomBoxGrid(itemId, toolDef.Type, stuffType);
			enchantFrameEnchantBtnName:SetText(GetS(477));
			if stuffId > 0 then	--合并附魔
				enchantFrameText:SetText(GetS(70));
				enchantFrameText:SetTextColor(255, 0, 0);
				MergeEnchant(enchantMentDef, toolDef.Type);			
				
				local stuffDef = ItemDefCsv:get(stuffId);
				enchantFrameEnchantItem2Name:SetText(stuffDef.Name);	
			else
				enchantFrameText:SetText(GetS(71));
				enchantFrameText:SetTextColor(247, 119, 15);
				for i=1, 5 do 
					local attr = getglobal("EnchantFrameAttr"..i);
					local desc = getglobal("EnchantFrameAttr"..i.."Desc");
					local arrow = getglobal("EnchantFrameAttr"..i.."UpArrow");
					
					local text = "";
					if i <= itemEnchantNum then
						local id = ClientBackpack:getGridEnchantId(destGridIndex, i-1);
						local enchantDef = DefMgr:getEnchantDef(id);
						if enchantDef ~= nil then
							text = enchantDef.Name..enchantDef.EnchantLevel;
							desc:SetText(text, 36, 180, 254);

							attr:SetClientUserData(0, id);
							attr:SetClientUserData(1, 0);
							attr:SetClientUserData(2, 0);
						end
					else
						if i == 1 then
							desc:SetText(GetS(67), 36, 180, 254);
						else
							desc:Clear();
						end
						attr:SetClientUserData(0, 0);
						attr:SetClientUserData(1, 0);
						attr:SetClientUserData(2, 0);
					end
					arrow:Hide();
				end

				enchantFrameEnchantItem2Name:SetText(GetS(476));
				enchantFrameEnchantBtnNormal:SetGray(true);
				enchantFrameEnchantBtn:Disable();
				enchantFrameEnchantBtnText:SetText(0);
			end
		end
	else
		for i=1, 5 do 
			local attr = getglobal("EnchantFrameAttr"..i);
			local desc = getglobal("EnchantFrameAttr"..i.."Desc");
			local arrow = getglobal("EnchantFrameAttr"..i.."UpArrow");
		
			attr:Hide();
			arrow:Hide();
			desc:Clear();
			attr:SetClientUserData(0, 0);
			attr:SetClientUserData(1, 0);
			attr:SetClientUserData(2, 0);
		end
		enchantFrameEnchantBtn:Hide();
		enchantFrameText:Hide();

		
		enchantFrameEnchantBtnText:SetText(0);
		if Enchant_Type == 1 then
			enchantFrameEnchantItem1Name:SetText(GetS(474));
			enchantFrameEnchantItem2Name:SetText("");
		elseif Enchant_Type == 2 then
			enchantFrameEnchantItem1Name:SetText(GetS(475));
			enchantFrameEnchantItem2Name:SetText(GetS(476));

			--clear EnchantBottomBox
			for i=1, ENCHANT_GRID_MAX do
				local bottomItem 	= getglobal("EnchantBottomBoxItem"..i);
				local bottomItemIcon 	= getglobal("EnchantBottomBoxItem"..i.."Icon");
				local bottomItemNum 	= getglobal("EnchantBottomBoxItem"..i.."Count");
				local bottomItemDurbkg 	= getglobal("EnchantBottomBoxItem"..i.."DurBkg");
				local bottomItemDurbar 	= getglobal("EnchantBottomBoxItem"..i.."Duration");

				bottomItem:SetClientID(0);
				bottomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
				bottomItemNum:SetText("");
				bottomItemDurbar:Hide();
				bottomItemDurbkg:Hide();
				getglobal(bottomItemIcon:GetName().."FumoEffect1"):Hide();
				getglobal(bottomItemIcon:GetName().."FumoEffect2"):Hide();
			end
		end
	end
end

function GetEnchantMaxLevelForId(enchantId)
	for i=1, 5 do
		local id = enchantId*100 + i;
		local enchantDef = DefMgr:getEnchantDef(id);
		if enchantDef == nil then
			return i-1;
		end
	end

	return 5;
end

--合并附魔
function MergeEnchant(enchantMentDef, toolType)
	t_ChooseEnchantAttr = {};
	local itemEnchantNum = ClientBackpack:getGridEnchantNum(destGridIndex);
	local itemId = ClientBackpack:getGridItem(destGridIndex);
	for i=1, itemEnchantNum do
		local enchantId = ClientBackpack:getGridEnchantId(destGridIndex, i-1);
		local id = math.floor(enchantId/100);
		local level = enchantId - 100*id;

		local enchantDef = DefMgr:getEnchantDef(enchantId);
		if enchantDef then
			table.insert(t_ChooseEnchantAttr, {ID=id, EnchantLevel=level, ownLevel=level, isOwn=true, isChoose=false, canChoose=true, conflictID=enchantDef.ConflictID});
		end
	end

	local stuffEnchantNum = ClientBackpack:getGridEnchantNum(fromGridIndex);
	for i=1, stuffEnchantNum do
		local enchantId = ClientBackpack:getGridEnchantId(fromGridIndex, i-1);
		local id = math.floor(enchantId/100);
		local level = enchantId - 100*id;

		local hasSameAttr = false;
		for j=1, #(t_ChooseEnchantAttr) do		
			if id == t_ChooseEnchantAttr[j].ID then
				hasSameAttr = true;
				if level == t_ChooseEnchantAttr[j].EnchantLevel and level < GetEnchantMaxLevelForId(id) then
					t_ChooseEnchantAttr[j].EnchantLevel = t_ChooseEnchantAttr[j].EnchantLevel + 1;
				elseif level > t_ChooseEnchantAttr[j].EnchantLevel then
					t_ChooseEnchantAttr[j].EnchantLevel = level;
				end
			end
		end
		if not hasSameAttr then
			local choose = true;
			local enchantDef = DefMgr:getEnchantDef(enchantId);
			if enchantDef ~= nil then
				if not CanChooseForToolType(enchantDef, toolType) then --or EnchantConflict(enchantDef.ConflictID)
					choose = false;
				end
				if itemId == 11807 then	--附魔书特殊处理
					choose = true;
				end
			end
			table.insert(t_ChooseEnchantAttr, {ID=id, EnchantLevel=level, ownLevel=level, isOwn=false, isChoose=false, canChoose=choose, conflictID=enchantDef.ConflictID});
		end
	end

	local mergeAttrNum = #(t_ChooseEnchantAttr);

	local isGray = true
	for i=1, mergeAttrNum do
		if t_ChooseEnchantAttr[i].isOwn and t_ChooseEnchantAttr[i].EnchantLevel ~= t_ChooseEnchantAttr[i].ownLevel then
			isGray = false;
			break;
		elseif not t_ChooseEnchantAttr[i].isOwn and t_ChooseEnchantAttr[i].canChoose then
			isGray = false;
			break;
		end
	end

	local EnchantFrameEnchantBtnNormal = getglobal("EnchantFrameEnchantBtnNormal");
	local EnchantFrameEnchantBtn = getglobal("EnchantFrameEnchantBtn");
	local EnchantFrameText = getglobal("EnchantFrameText");
	local EnchantFrameEnchantBtnText = getglobal("EnchantFrameEnchantBtnText");
	if isGray then
		EnchantFrameEnchantBtnNormal:SetGray(true);
		EnchantFrameEnchantBtn:Disable();
		EnchantFrameText:SetText(GetS(78));
		EnchantFrameText:SetTextColor(217, 108, 0);
		EnchantFrameEnchantBtnText:SetText(0);
	end

	if GetCanChooseNum() > 5 then
		if not isGray then
			EnchantFrameEnchantBtnText:SetText("?");
		end
	else						--计算花费
		local isGray = true
		for i=1, mergeAttrNum do
			if t_ChooseEnchantAttr[i].isOwn and t_ChooseEnchantAttr[i].EnchantLevel ~= t_ChooseEnchantAttr[i].ownLevel then
				isGray = false;
				break;
			elseif t_ChooseEnchantAttr[i].canChoose then
				isGray = false;
				break;
			end
		end

		if not isGray then
			local cost = 0;
			for i=1, mergeAttrNum do
				if t_ChooseEnchantAttr[i].isOwn then
					if t_ChooseEnchantAttr[i].EnchantLevel > t_ChooseEnchantAttr[i].ownLevel then
						local cost1 = GetMergeCostForLevel(enchantMentDef, t_ChooseEnchantAttr[i].EnchantLevel);
						local cost2 = GetMergeCostForLevel(enchantMentDef, t_ChooseEnchantAttr[i].ownLevel);
						cost = cost + cost1 - cost2;
					end
				else
					cost = cost + GetMergeCostForLevel(enchantMentDef, t_ChooseEnchantAttr[i].EnchantLevel);
				end
			end
			EnchantFrameEnchantBtnText:SetText(cost);
			local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
			if starNum < cost then
				EnchantFrameEnchantBtnText:SetTextColor(255, 0, 0);
			else
				EnchantFrameEnchantBtnText:SetTextColor(255, 246, 0);
			end
		end
	end

	local attrIndex = 1;
	for i=1, mergeAttrNum do 
		if attrIndex > 5 then break; end

		local attr = getglobal("EnchantFrameAttr"..attrIndex);
		local desc = getglobal("EnchantFrameAttr"..attrIndex.."Desc");
		local arrow = getglobal("EnchantFrameAttr"..attrIndex.."UpArrow");
		local text = "";		
		if t_ChooseEnchantAttr[i].canChoose then
			attrIndex = attrIndex + 1;
			local id = t_ChooseEnchantAttr[i].ID*100 + t_ChooseEnchantAttr[i].EnchantLevel;
			local enchantDef = DefMgr:getEnchantDef(id);
			if t_ChooseEnchantAttr[i].isOwn then
				text = "#c00b0f0"..enchantDef.Name..t_ChooseEnchantAttr[i].ownLevel.."#n";
				local ownId = t_ChooseEnchantAttr[i].ID*100 + t_ChooseEnchantAttr[i].ownLevel;
				if GetCanChooseNum() > 5 then
					if t_ChooseEnchantAttr[i].ownLevel ~= t_ChooseEnchantAttr[i].EnchantLevel then 
						text = text.."#cfff600".."→ ?";					
						attr:SetClientUserData(0, ownId);
						attr:SetClientUserData(1, 0);
						attr:SetClientUserData(2, 1);
						arrow:Show();
					else
						arrow:Hide();
					end
				else
					if t_ChooseEnchantAttr[i].ownLevel ~= t_ChooseEnchantAttr[i].EnchantLevel then
						text = text.."#cfff600".."→"..t_ChooseEnchantAttr[i].EnchantLevel.."#n";

						attr:SetClientUserData(0, ownId);
						attr:SetClientUserData(1, t_ChooseEnchantAttr[i].EnchantLevel);
						attr:SetClientUserData(2, 0);
						arrow:Show();
					else
						arrow:Hide();
					end
				end
			else
				if GetCanChooseNum() > 5 then
					text = "#cfff600".."?#n";
					attr:SetClientUserData(0, 0);
					attr:SetClientUserData(1, 0);
					attr:SetClientUserData(2, 1);
					arrow:Show();
				else
					text = "#cfff600"..enchantDef.Name..t_ChooseEnchantAttr[i].EnchantLevel.."#n";

					attr:SetClientUserData(0, id);
					attr:SetClientUserData(1, 0);
					attr:SetClientUserData(2, 0);
					arrow:Show();
				end	
			end
			desc:SetText(text, 255, 255, 255);	
		end		
	end

	Log('MergeEnchant------------:'..attrIndex);
	for i=1, 5 do
		if i >= attrIndex then
			local attr = getglobal("EnchantFrameAttr"..i);
			local desc = getglobal("EnchantFrameAttr"..i.."Desc");
			local arrow = getglobal("EnchantFrameAttr"..i.."UpArrow");

			arrow:Hide();
			desc:Clear();
			attr:SetClientUserData(0, 0);
			attr:SetClientUserData(1, 0);
			attr:SetClientUserData(2, 0);
		end
	end
end

function GetCanChooseNum()
	local canChooseNum = 0;
	for i=1, #(t_ChooseEnchantAttr) do
		if t_ChooseEnchantAttr[i].canChoose then
			canChooseNum = canChooseNum + 1;
		end
	end

	return canChooseNum;
end

--计算这条属性是否能被合并
function CanChooseForToolType(enchantDef, toolType)
	local canChoose = false;
	for i=1, MAX_TOOL_TYPE do
		if toolType ~= 0 and toolType == enchantDef.ToolType[i-1] then
			canChoose = true;
		end
	end
	return canChoose;	
end

--计算这条属性是否与其它属性冲突
function EnchantConflict(conflictID)
	for i=1, #(t_ChooseEnchantAttr) do
		if conflictID ~=0 and conflictID == t_ChooseEnchantAttr[i].conflictID then
			return true;
		end
	end

	return false;
end

--计算合并附魔的等级花费
function GetMergeCostForLevel(enchantMentDef, level)
	local cost = 0;
	for i=1, level do
		if i <= 5 then
			cost = cost + enchantMentDef.MergeCost[i-1];
		else
			local index = level;
			if level == 100 then
			end
		end
	end
	return cost;
end

--随机附魔
function RandomEnchant(enchantMentDef, toolType)
	--找到随机的附魔属性条数
	local t_AttrNumProb = {};
	local prob = 0;
	local total = 0;
	for i=1, 5 do
		total = total + enchantMentDef.AttrWeight[i-1];
		if enchantMentDef.AttrWeight[i-1] ~= 0 then
			prob = prob + enchantMentDef.AttrWeight[i-1];
			table.insert(t_AttrNumProb, prob);
		end
	end
	if total == 0 then
		total = 1;
	end
	local randomNum = math.random(0, total-1);
	local attrNum = 0;
	for i=1, #(t_AttrNumProb) do 
		if randomNum < t_AttrNumProb[i] then
			attrNum = i;
			break;
		end
	end

	--找到符合条件的附魔属性
	local t_AccordAttr = {};
	DefMgr:setCurAccordEnchants(toolType);
	local curAccordNum = DefMgr:getCurAccordEnchantsNum();
	for i=1, curAccordNum do
		local enchantDef = DefMgr:getCurAccordEnchantDef(i-1);
		table.insert(t_AccordAttr, enchantDef);
	end

	--选择的附魔属性
	t_ChooseEnchantAttr = {};
	t_ChooseEnchantAttr = GetChooseEnchantDef(attrNum, t_AccordAttr, enchantMentDef);

	--计算花费
	local cost = enchantMentDef.Cost;
	local EnchantFrameEnchantBtnText = getglobal("EnchantFrameEnchantBtnText");
	EnchantFrameEnchantBtnText:SetText(cost);
	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	if starNum < cost then
		EnchantFrameEnchantBtnText:SetTextColor(255, 0, 0);
	else
		EnchantFrameEnchantBtnText:SetTextColor(255, 246, 0);
	end
end

function GetChooseEnchantDef(attrNum, t_AccordAttr, enchantMentDef)
	local t_AttrInfo = {}
	for i=1, attrNum do
		local t_ChooseAttrProb = {};
		local total = 0;
		for j=1, #(t_AccordAttr) do
			total = total + t_AccordAttr[j].Weight;
			table.insert(t_ChooseAttrProb, total);
		end
		if total == 0 then
			total = 1;
		end
		local randomNum = math.random(0, total-1);
		for k=1, #(t_AccordAttr) do 
			if randomNum < t_ChooseAttrProb[k] then
				local isConflict = false;
				for n=1, #(t_AttrInfo) do
					if t_AccordAttr[k].ConflictID ~= 0 and t_AccordAttr[k].ConflictID == t_AttrInfo[n].ConflictID then
						isConflict = true;
					end
				end
				if not isConflict then
					table.insert(t_AttrInfo, t_AccordAttr[k]);
					break;
				end
			end
		end
	end

	local t_RandomAttr = {};
	for i=1, #(t_AttrInfo) do
		local level = RandomLevel(enchantMentDef);
		local id = t_AttrInfo[i].ID * 100 + level;			
		local enchantDef = DefMgr:getEnchantDef(id);
		if enchantDef == nil then
			enchantDef = DefMgr:getEnchantDef(t_AttrInfo[i].ID * 100 + 1);
		end
		table.insert(t_RandomAttr, enchantDef);
		t_RandomAttr[i].canChoose = true;
	end

	return t_RandomAttr;
end

--随机等级
function RandomLevel(enchantMentDef)
	local level = 1;
	local t_LevelProb = {}
	local prob = 0;
	local total = 0;
	for i=1, 5 do
		total = total + enchantMentDef.LevelWeight[i-1];
		if enchantMentDef.LevelWeight[i-1] ~= 0 then
			prob = prob + enchantMentDef.LevelWeight[i-1];
			table.insert(t_LevelProb, prob);
		end
	end
	if total == 0 then
		total = 1;
	end
	local randomNum = math.random(0, total-1);
	local attrNum = 0;
	for i=1, #(t_LevelProb) do 
		if randomNum < t_LevelProb[i] then
			level = i;
			break;
		end
	end

	return level;
end

--点击附魔属性条
function EnchantAttrBtn_OnClick()
	EnchantAttrBtnName = this:GetName();
	if this:GetClientUserData(0) > 0 then
		local EnchantAttrTipsFrame = getglobal("EnchantAttrTipsFrame");
		EnchantAttrTipsFrame:Show();
	end
end

function EnchantFrame_OnHide()
	t_RandomBoxGrid = {};
	t_topBoxGrid = {};
	destGridIndex = nil;
	fromGridIndex = nil;

	local MItemTipsFrame = getglobal("MItemTipsFrame");
	if MItemTipsFrame:IsShown() then
		MItemTipsFrame:Hide();
	end

	local EnchantAttrTipsFrame = getglobal("EnchantAttrTipsFrame");
	if EnchantAttrTipsFrame:IsShown() then
		EnchantAttrTipsFrame:Hide();
	end

	for i=1, ENCHANT_GRID_MAX do
		local bottomItem 	= getglobal("EnchantBottomBoxItem"..i);
		local bottomItemIcon	= getglobal("EnchantBottomBoxItem"..i.."Icon");
		local bottomItemNum	= getglobal("EnchantBottomBoxItem"..i.."Count");
		local bottomItemDurbar  = getglobal("EnchantBottomBoxItem"..i.."Duration");

		bottomItem:SetClientID(0);
		bottomItemIcon:SetTextureHuires(ClientMgr:getNullItemIcon());
		bottomItemNum:SetText("");
		bottomItemDurbar:Hide();
		getglobal(bottomItemIcon:GetName().."FumoEffect1"):Hide();
		getglobal(bottomItemIcon:GetName().."FumoEffect2"):Hide();
	end

	if not getglobal("EnchantFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
end

function EnchantItemBtn_OnMouseDownUpdate()
end

function EnchantFrameAddStar_OnClick()
	if gIsSingleGame then return end
	getglobal("StarConvertFrame"):Show();
end

function IsConflict()	
	if ClientBackpack:getGridItem(destGridIndex) == 11807 then	--附魔书不判断冲突
		return false
	end
 	for i=1, #(t_ChooseEnchantAttr) do
		local id1 = t_ChooseEnchantAttr[i].ID*100 + t_ChooseEnchantAttr[i].EnchantLevel;
		local enchantDef1 = DefMgr:getEnchantDef(id1);
		local n = i+1;
		for j=n, #(t_ChooseEnchantAttr) do
			local id2 = t_ChooseEnchantAttr[j].ID*100 + t_ChooseEnchantAttr[j].EnchantLevel;
			local enchantDef2 = DefMgr:getEnchantDef(id2);
			if enchantDef1.ConflictID > 0 and enchantDef1.ConflictID  == enchantDef2.ConflictID then
				return true;
			end
		end
	end
	return false;
end

--目标格子的附魔是否有改变
function DescGridEnchantIsChange()
	if #(t_ChooseEnchantAttr) == 0 then
		return false;
	end

	local hasChange = false;
	local num = #(t_ChooseEnchantAttr);
	for i=1, num do		
		local enchantId = t_ChooseEnchantAttr[i].ID*100 + t_ChooseEnchantAttr[i].EnchantLevel; 

		local hasSame = false;
		for j=1, ClientBackpack:getGridEnchantNum(destGridIndex) do
			if ClientBackpack:getGridEnchantId(destGridIndex, j-1) == enchantId then
				hasSame = true;
			end				
		end
		if not hasSame then
			hasChange = true;
		end
	end

	return hasChange;
end

function EnchantFrameEnchantBtn_OnClick()
	if destGridIndex ~= nil then
		--多于5条属性，跳到选择属性面板
		if Enchant_Type == 2 then
			local ChooseEnchantFrame = getglobal("ChooseEnchantFrame");
			if GetCanChooseNum() > 5 then
				ChooseEnchantFrame:Show();
				return;
			elseif IsConflict() then
				ChooseEnchantFrame:Show();
				return;
			end
		end

		--星星不足
		local EnchantFrameEnchantBtnText = getglobal("EnchantFrameEnchantBtnText");
		local cost = tonumber(EnchantFrameEnchantBtnText:GetText());
		local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
		if cost > starNum then
			local needNum = cost - starNum;
			local lackNum = math.ceil(needNum/MiniCoin_Star_Ratio)
			local text = GetS(466, needNum, lackNum);
			StoreMsgBox(5, text, GetS(469), -2, lackNum, cost);
			getglobal("StoreMsgboxFrame"):SetClientString( "附魔星星不足" );
			return;
		end
		Enchant();
	else
		--没有放入要附魔物品
		local text = GetS(80);
		ShowGameTips(text, 2);
	end
end

function EnchantMinicoin()
	local cost = tonumber(getglobal("EnchantFrameEnchantBtnText"):GetText());
	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	if starNum >= cost then
		Enchant();
	else
		local needMini = math.ceil((cost - starNum)/MiniCoin_Star_Ratio);
		local hasMini = AccountManager:getAccountData():getMiniCoin();
		if needMini <= hasMini then
			if AccountManager:getAccountData():notifyServerConsumeMiniCoin(needMini) ~= 0 then
				--ShowGameTips(StringDefCsv:get(282), 3);
				return;
			end
			ClientCurGame:getMainPlayer():starConvert(needMini*MiniCoin_Star_Ratio);
			Enchant();
		else	
			local lackMiniNum = needMini - hasMini;
			local cost, buyNum = GetPayRealCost(lackMiniNum);
			local text = GetS(453, cost, buyNum);
			StoreMsgBox(6, text, GetS(456), -1, lackNum, needMini, nil, NotEnoughMiniCoinCharge, cost);
		end
	end
end

function Enchant()
	--附魔
	if Enchant_Type == 1 then
		CurMainPlayer:enchantRandom(destGridIndex);
	else
		if DescGridEnchantIsChange() then
			local t_enchants = {};
			local enchantIndex = 0;
			for i=1, 5 do
				table.insert(t_enchants, 0);
			end
			for i=1, #(t_ChooseEnchantAttr) do		
				if t_ChooseEnchantAttr[i].canChoose then
					enchantIndex = enchantIndex + 1;
					local id = t_ChooseEnchantAttr[i].ID;
					local level = t_ChooseEnchantAttr[i].EnchantLevel;
					t_enchants[i] = (id * 100 + level);
				end
			end
			
			CurMainPlayer:enchant(destGridIndex, fromGridIndex, t_enchants);
		else
			ShowGameTips(GetS(78), 3);
		end
	end
end
------------------------------------------------EnchantAttrTipsFrame------------------------------------------------------
--UserData  0属性表Id 1升级后等级 2是否超过5条
function EnchantAttrTipsFrame_OnShow()
	if EnchantAttrBtnName == nil or EnchantAttrBtnName == "" then return end

	local btn = getglobal(EnchantAttrBtnName);
	local id = btn:GetClientUserData(0);
	local level = btn:GetClientUserData(1);
	local more = btn:GetClientUserData(2);
	local text = ""
	local bkgH = 0;	
	
	local EnchantAttrTipsFrameName = getglobal("EnchantAttrTipsFrameName");
	if id > 0 then
		bkgH = bkgH + 100;
		local enchantDef = DefMgr:getEnchantDef(id);		
		if enchantDef ~= nil then
			EnchantAttrTipsFrameName:SetText(enchantDef.Name..enchantDef.EnchantLevel);
			text = text..enchantDef.AttrDesc.."\n";
		end
	else
		EnchantAttrTipsFrameName:Hide();
	end
	if level > 0 then
		bkgH = bkgH + 30;
		text = text.."\n"..GetS(478, level).."\n";
	end
	if more > 0 then
		bkgH = bkgH + 30;
		text = text.."\n"..GetS(480).."\n";
	end

	local EnchantAttrTipsFrameDesc = getglobal("EnchantAttrTipsFrameDesc");
	EnchantAttrTipsFrameDesc:SetText(text, 255, 255, 255);
	bkgH = bkgH + (EnchantAttrTipsFrameDesc:GetTextLines()-1) * 18;


	local EnchantAttrTipsFrame = getglobal("EnchantAttrTipsFrame");
	EnchantAttrTipsFrame:SetSize(325, bkgH);
	EnchantAttrTipsFrame:SetPoint("topright", EnchantAttrBtnName, "topleft", 0, 0);

	if id > 0 then
		EnchantAttrTipsFrameDesc:SetPoint("topleft", "EnchantAttrTipsFrame", "topleft", 15, 60);
	else
		EnchantAttrTipsFrameDesc:SetPoint("topleft", "EnchantAttrTipsFrame", "topleft", 15, 10);
	end
	
end

function EnchantAttrTipsFrame_OnClick()
	local EnchantAttrTipsFrame = getglobal("EnchantAttrTipsFrame");
	EnchantAttrTipsFrame:Hide();
end
-------------------------------------------------EnchantItemBtn-----------------------------------------------------------
function HideEnchantAllBoxTexture()
	if Enchant_Type == 1 then
		for i=1,ENCHANT_RANDOM_GRID_MAX do
			local boxTexture = getglobal("EnchantRandomBoxItem"..i.."BoxTexture");
			if boxTexture:IsShown() then
				boxTexture:Hide();
			end
		end
	else
		for i=1,ENCHANT_GRID_MAX do
			local boxTexture1 = getglobal("EnchantTopBoxItem"..i.."BoxTexture");
			local boxTexture2 = getglobal("EnchantBottomBoxItem"..i.."BoxTexture");
			if boxTexture1:IsShown() then
				boxTexture1:Hide();
			end
			if boxTexture2:IsShown() then
				boxTexture2:Hide();
			end
		end
	end
end

function EnchantItemBtn_OnClick()
	--改
	local btnName = this:GetName();
	if string.find(btnName, "EnchantItem") then			
		if Enchant_Type == 1 then
			destGridIndex = nil;
		elseif string.find(btnName, "EnchantItem1") then
			destGridIndex = nil;
			fromGridIndex = nil;		
		elseif string.find(btnName, "EnchantItem2") then
			fromGridIndex = nil;
		end
		UpdateEnchantItemGrid();
		UpdateEnchantBoxGrid();
	else
		local clientId = this:GetClientID();
		if clientId == 0 then return end

		
		local grid_index = clientId - 1;
		local itemId = ClientBackpack:getGridItem(grid_index);		
		if itemId < 1 then return end
		local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
		if enchantNum > 0 and not ClientMgr:isPC() then
			HideEnchantAllBoxTexture();
			local boxTexture = getglobal(btnName.."BoxTexture");
			boxTexture:Show();

			SetMTipsInfo(grid_index, btnName, false);
		else
			local MItemTipsFrame = getglobal("MItemTipsFrame");
			if MItemTipsFrame:IsShown() then
				MItemTipsFrame:Hide();
			end
			EnchantItemPlace(btnName, grid_index);
		end
	end
end

local EnchantItemGridBlinkType = 0;
function EnchantFrame_OnUpdate()
	if EnchantItemGridBlinkType > 0 then
		local icon = getglobal("EnchantFrameEnchantItem"..EnchantItemGridBlinkType.."Icon");
		if EnchantItemGridBlink > 0 then
			EnchantItemGridBlink = EnchantItemGridBlink - 1;
			if icon:IsShown() then
				icon:Hide();
			else
				icon:Show();
			end
		else
			EnchantItemGridBlinkType = 0;
			if not icon:IsShown() then
				icon:Show();
			end
		end
	end
end

--附魔面板的物品放置逻辑
function EnchantItemPlace(btnName, grid_index)
	--改
	HideEnchantAllBoxTexture();
	local enchantNum = ClientBackpack:getGridEnchantNum(grid_index);
	if string.find(btnName, "EnchantRandomBoxItem") then
		destGridIndex = grid_index;
		EnchantItemGridBlink = 6;
		EnchantItemGridBlinkType = 1;	
	elseif string.find(btnName, "EnchantTopBoxItem") then
		destGridIndex = grid_index;
		fromGridIndex = nil;
		EnchantItemGridBlink = 6;
		EnchantItemGridBlinkType = 1;
	elseif string.find(btnName, "EnchantBottomBoxItem") then
		fromGridIndex = grid_index;
		EnchantItemGridBlink = 6;
		EnchantItemGridBlinkType = 2;
	end
--	SetEnchantBoxGrid();
	UpdateEnchantItemGrid();
	UpdateEnchantBoxGrid();
end

function EnchantItemChange(grid_index, togrid_index)
	local itemId = ClientBackpack:getGridItem(togrid_index);
	if itemId > 0 then
		local enchantNum = ClientBackpack:getGridEnchantNum(togrid_index);
		if enchantNum > 0 then
			local null_index = GetPackFrameFristNullGridIndex();
			ClientBackpack:placeItem(togrid_index, null_index);	--16000放到空格子
			ClientBackpack:placeItem(grid_index, togrid_index);	--附魔物品放到16000
		else
			ClientBackpack:addItem(itemId, 1);				--16000放到背包
			ClientBackpack:placeItem(grid_index, togrid_index);	--附魔物品放到16000
		end
	else
		ClientBackpack:placeItem(grid_index, togrid_index);		--附魔物品放到16000		
	end	
end

function EnchantItemBtn_OnMouseDownUpdate()
	if arg1 < 0.6 then return end

	local btnName = this:GetName();
	if string.find(btnName, "EnchantTopBox") or string.find(btnName, "EnchantBottomBox") 
	   or string.find(btnName, "EnchantRandomBox") then
		return;
	end

	local grid_index = this:GetClientID() - 1;
	local itemId = ClientBackpack:getGridItem(grid_index)
	if itemId <= 0 then return end

	SetMTipsInfo(-1, btnName, true, itemId);
end

function EnchantItemBtn_OnMouseUp()
	local MItemTipsFrame = getglobal("MItemTipsFrame");
	if MItemTipsFrame:IsShown() and IsLongPressTips then
		MItemTipsFrame:Hide();
	end
end

--------------------------------------------------ChooseEnchantFrame---------------------------------------
function SetAttrBtnGray(clientId)
	for i=1, 10 do 
		local attrBtn = getglobal("ChooseEnchantFrameAttrBtn"..i);
		if attrBtn:GetClientID() > 0 and attrBtn:GetClientID() == clientId then
			local normal = getglobal("ChooseEnchantFrameAttrBtn"..i.."Normal");
			normal:SetGray(true);
		end
	end
end

function UpdateAttrBtnForConflict()	
	for i=1, 10 do 
		local normal = getglobal("ChooseEnchantFrameAttrBtn"..i.."Normal");
		normal:SetGray(false);
	end

 	for i=1, #(t_ChooseEnchantAttr) do
		if t_ChooseEnchantAttr[i].isChoose then
			local id1 = t_ChooseEnchantAttr[i].ID*100 + t_ChooseEnchantAttr[i].EnchantLevel;
			local enchantDef1 = DefMgr:getEnchantDef(id1);
			if enchantDef1 == nil then return end

			for j=1, #(t_ChooseEnchantAttr) do
				local id2 = t_ChooseEnchantAttr[j].ID*100 + t_ChooseEnchantAttr[j].EnchantLevel;
				if id1 ~= id2 then
					local enchantDef2 = DefMgr:getEnchantDef(id2);
					if enchantDef2 == nil then return end

					if enchantDef1.ConflictID > 0 and enchantDef1.ConflictID  == enchantDef2.ConflictID then
						SetAttrBtnGray(j);				
					end
				end
			end
		end
	end
end

function GetCanChooseAttrBtnMaxNum()
	local itemId = destGridIndex ~= nil and ClientBackpack:getGridItem(destGridIndex) or 0;
	if itemId == 11807 then
		return 5;
	end
	local t_conflictId = {};
	for i=1, #(t_ChooseEnchantAttr) do
		local id = t_ChooseEnchantAttr[i].ID*100 + t_ChooseEnchantAttr[i].EnchantLevel;
		local enchantDef = DefMgr:getEnchantDef(id);
		if enchantDef ~= nil then
			local hasConflictId = false;
			for j=1, #(t_conflictId) do
				if t_conflictId[j] > 0 and t_conflictId[j] == enchantDef.ConflictID then
					hasConflictId = true;
				end
			end
			if not hasConflictId then
				table.insert(t_conflictId, enchantDef.ConflictID);
			end
		end
	end
	
	local num = #(t_conflictId);
	if num > 5 then 
		num = 5;
	end
	return num;
end

function ChooseEnchantAttrBtn_OnClick()
	local normal = getglobal(this:GetName().."Normal");
	local check = getglobal(this:GetName().."CheckedBG");
	local clientId = this:GetClientID();

	local chooseNum = 0;
	for i=1, #(t_ChooseEnchantAttr) do
		if t_ChooseEnchantAttr[i].isChoose then
			chooseNum = chooseNum + 1;
		end
	end

	local canChooseNum = GetCanChooseAttrBtnMaxNum();
	if normal:IsShown() then
		if normal:IsGray() then
			ShowGameTips(GetS(481), 3);
			return;
		end
		if chooseNum >= canChooseNum then
			ShowGameTips(GetS(482)..canChooseNum..GetS(483), 3);
			return;
		end	

		normal:Hide();
		check:Show();
		if clientId <= #(t_ChooseEnchantAttr) then
			t_ChooseEnchantAttr[clientId].isChoose = true;
		end
	else
		check:Hide();
		normal:Show();
		if clientId <= #(t_ChooseEnchantAttr) then
			t_ChooseEnchantAttr[clientId].isChoose = false;
		end
	end
	
	UpdateAttrBtnForConflict();
	
	ChooseCost();
end

function ChooseEnchantFrame_OnLoad()
	for i=1, 2 do
		for j=1, 5 do
			local attr = getglobal("ChooseEnchantFrameAttrBtn"..(i-1)*5+j);
			attr:SetPoint("topleft", "ChooseEnchantFrameChenDi", "topleft", 63+(i-1)*279, 99+(j-1)*52);
		end
	end
end

function ResetChooseAttrBtn()
	for i=1, 10 do
		local normal = getglobal("ChooseEnchantFrameAttrBtn"..i.."Normal");
		local check = getglobal("ChooseEnchantFrameAttrBtn"..i.."CheckedBG"); 
		normal:Show();
		normal:SetGray(false);
		check:Hide();
	end
end

function ChooseEnchantFrame_OnShow()
	ResetChooseAttrBtn();
	getglobal("ChooseEnchantFrameConfirmBtnText"):SetText(0);
	local t_selfAttr = {};
	local t_addAttr = {};
	for i=1, #(t_ChooseEnchantAttr) do
		if t_ChooseEnchantAttr[i].isOwn then
			table.insert(t_selfAttr, {attrInfo=t_ChooseEnchantAttr[i], clientId=i});
		elseif t_ChooseEnchantAttr[i].canChoose then
			table.insert(t_addAttr, {attrInfo=t_ChooseEnchantAttr[i], clientId=i});
		end
	end
	for i=1, 5 do
		local attr = getglobal("ChooseEnchantFrameAttrBtn"..i);
		local desc = getglobal("ChooseEnchantFrameAttrBtn"..i.."Desc");
		if i <= #(t_selfAttr) then
			attr:Show();
			attr:SetClientID(t_selfAttr[i].clientId);
			local id = t_selfAttr[i].attrInfo.ID *100 + t_selfAttr[i].attrInfo.EnchantLevel;
			local enchantDef = DefMgr:getEnchantDef(id);
			if enchantDef ~= nil then
				local text = enchantDef.Name..t_selfAttr[i].attrInfo.EnchantLevel;
				desc:SetText(text, 255, 216, 0);
			end
		else
			attr:Hide();
			attr:SetClientID(0);
		end
	end

	for i=6, 10 do
		local attr = getglobal("ChooseEnchantFrameAttrBtn"..i);
		local normal = getglobal("ChooseEnchantFrameAttrBtn"..i.."Normal");
		local desc = getglobal("ChooseEnchantFrameAttrBtn"..i.."Desc");
		local index = i-5;
		if index <= #(t_addAttr) then
			attr:Show();
			attr:SetClientID(t_addAttr[index].clientId);
			local id = t_addAttr[index].attrInfo.ID *100 + t_addAttr[index].attrInfo.EnchantLevel;
			local enchantDef = DefMgr:getEnchantDef(id);
			if enchantDef ~= nil then
				local text = enchantDef.Name..t_addAttr[index].attrInfo.EnchantLevel;
				desc:SetText(text, 255, 216, 0);
			end
			--[[
			if Enchant_Type == 2 or t_addAttr[index].attrInfo.canChoose then
				normal:SetGray(false);
			else
				normal:SetGray(true);
			end
			]]
		else
			attr:Hide();
			attr:SetClientID(0);
		end
	end

	local num = GetCanChooseAttrBtnMaxNum();
	local ChooseEnchantFrameTips = getglobal("ChooseEnchantFrameTips");
	ChooseEnchantFrameTips:SetText(GetS(484, num));
end

function ChooseCost()
	--计算花费
	local itemId = destGridIndex ~= nil and ClientBackpack:getGridItem(destGridIndex) or 0;
	local enchantMentDef = nil;
	if itemId > 0 then
		local itemDef = ItemDefCsv:get(itemId);
		local stuffType = itemDef.StuffType;
		enchantMentDef = DefMgr:getEnchantMentDef(stuffType);
	end
	if enchantMentDef == nil then return end

	local cost = 0;
	for i=1, #(t_ChooseEnchantAttr) do
		if t_ChooseEnchantAttr[i].isChoose then
			if t_ChooseEnchantAttr[i].isOwn then
				if t_ChooseEnchantAttr[i].EnchantLevel > t_ChooseEnchantAttr[i].ownLevel then
					local cost1 = GetMergeCostForLevel(enchantMentDef, t_ChooseEnchantAttr[i].EnchantLevel);
					local cost2 = GetMergeCostForLevel(enchantMentDef, t_ChooseEnchantAttr[i].ownLevel);
					cost = cost + cost1 - cost2;
				end
			else
				cost = cost + GetMergeCostForLevel(enchantMentDef, t_ChooseEnchantAttr[i].EnchantLevel);
			end
		end
	end

	local ChooseEnchantFrameConfirmBtnText = getglobal("ChooseEnchantFrameConfirmBtnText");
	ChooseEnchantFrameConfirmBtnText:SetText(cost);
	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	if starNum < cost then
		ChooseEnchantFrameConfirmBtnText:SetTextColor(255, 0, 0);
	else
		ChooseEnchantFrameConfirmBtnText:SetTextColor(53, 162, 24);
	end
end

--确定
function ChooseEnchantFrameConfirmBtn_OnClick()
	local itemId = destGridIndex ~= nil and ClientBackpack:getGridItem(destGridIndex) or 0;
	local enchantMentDef = nil;
	if itemId > 0 then
		local itemDef = ItemDefCsv:get(itemId);
		local stuffType = itemDef.StuffType;
		enchantMentDef = DefMgr:getEnchantMentDef(stuffType);
	end
	--计算花费
	local chooseNum = 0;		--已选择的数量
	local canChooseNum = GetCanChooseAttrBtnMaxNum();		--可以选择的数量

	local ChooseEnchantFrameConfirmBtnText = getglobal("ChooseEnchantFrameConfirmBtnText");
	local cost = tonumber(ChooseEnchantFrameConfirmBtnText:GetText());
	for i=1, #(t_ChooseEnchantAttr) do
		if t_ChooseEnchantAttr[i].isChoose then
			chooseNum = chooseNum + 1;
		end
	end

	--属性条选择不足
	if chooseNum < canChooseNum then
		ShowGameTips(GetS(486, canChooseNum));
		return;
	end
	
	--星星不足
	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	if cost > starNum then
		local needNum = cost - starNum;
		local lackNum = math.ceil(needNum/MiniCoin_Star_Ratio)
		local text = GetS(466, needNum, lackNum);
		StoreMsgBox(5, text, GetS(469), -2, lackNum, cost);
		getglobal("StoreMsgboxFrame"):SetClientString( "选择附魔星星不足" );
		return;
	end
	ChooseEnchant()
end

function ChooseEnchantMinicoin()
	local cost = tonumber(getglobal("ChooseEnchantFrameConfirmBtnText"):GetText());
	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	if starNum >= cost then
		ChooseEnchant();
	else
		local needMini = math.ceil((cost - starNum)/MiniCoin_Star_Ratio);
		local hasMini = AccountManager:getAccountData():getMiniCoin();
		if needMini <= hasMini then
			if AccountManager:getAccountData():notifyServerConsumeMiniCoin(needMini) ~= 0 then
				--ShowGameTips(StringDefCsv:get(282), 3);
				return;
			end

			ClientCurGame:getMainPlayer():starConvert(needMini*MiniCoin_Star_Ratio);
			ChooseEnchant();
		else	
			local lackMiniNum = needMini - hasMini;
			--[[
			local cost = math.ceil(lackMiniNum/10);
			local buyNum = cost * 10;
			cost,buyNum = GetPayRealCost(cost);
			]]
			local cost, buyNum = GetPayRealCost(lackMiniNum);
			local text = GetS(453, cost, buyNum);
			StoreMsgBox(6, text, GetS(456), -1, lackNum, needMini, nil, NotEnoughMiniCoinCharge, cost);
		end
	end
end

function ChooseEnchant()
	local t_enchants = {};
	local enchantIndex = 0;
	for i=1, 5 do
		table.insert(t_enchants, 0);
	end

	local curIdx = 1;
	for i=1, #(t_ChooseEnchantAttr) do			
		if t_ChooseEnchantAttr[i].isChoose then
			enchantIndex = enchantIndex + 1;
			local id = t_ChooseEnchantAttr[i].ID;
			local level = t_ChooseEnchantAttr[i].EnchantLevel;
			t_enchants[curIdx] = (id * 100 + level);
			curIdx = curIdx + 1
		end
	end
	
	if ChooseDescGridEnchantIsChange(t_enchants) then		
		CurMainPlayer:enchant(destGridIndex, fromGridIndex, t_enchants);
		local ChooseEnchantFrame = getglobal("ChooseEnchantFrame");
		ChooseEnchantFrame:Hide();
	else
		ShowGameTips(GetS(78), 3);
	end
end

function ChooseDescGridEnchantIsChange(t)
	if #(t) == 0 then
		return false;
	end

	local hasChange = false;
	local num = #(t);
	for i=1, num do		
		local enchantId = t[i]; 

		local hasSame = false;
		for j=1, ClientBackpack:getGridEnchantNum(destGridIndex) do
			if ClientBackpack:getGridEnchantId(destGridIndex, j-1) == enchantId then
				hasSame = true;
			end				
		end
		if not hasSame then
			hasChange = true;
		end
	end

	return hasChange;
end

--取消
function ChooseEnchantFrameCancelBtn_OnClick()
	for i=1, #(t_ChooseEnchantAttr) do
		t_ChooseEnchantAttr[i].isChoose = false;
	end

	local ChooseEnchantFrame = getglobal("ChooseEnchantFrame");
	ChooseEnchantFrame:Hide();
end