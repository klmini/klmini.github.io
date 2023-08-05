local isShowPhysicsPart = false;	--是否进入了组装区域,显示物理机械部件tips


--type1 点击有详细的tips type2仅仅显示文字
function TipsFrame_OnLoad()
	this:setUpdateTime(0.05);
end

function TipsFrame_OnShow()
	getglobal("TipsFrameType1Font"):SetBlendAlpha(1.0);
	getglobal("TipsFrameType2Font"):SetBlendAlpha(1.0);
	getglobal("TipsFrameBkg"):SetBlendAlpha(1.0);
	getglobal("TipsFrameType1Search"):SetBlendAlpha(1.0);
end

local alpha = 1.0;
function TipsFrame_OnUpdate()
	tipsDisplayTime = tipsDisplayTime - arg1
	if tipsDisplayTime <= 0 then	
		alpha = alpha - 0.1;
		if alpha < 0 then
			alpha = 0;
		end	
		if getglobal("TipsFrameType1"):IsShown() then		
			getglobal("TipsFrameType1Font"):SetBlendAlpha(alpha);
			getglobal("TipsFrameType1Search"):SetBlendAlpha(alpha);
		elseif getglobal("TipsFrameType2"):IsShown() then
			getglobal("TipsFrameType2Font"):SetBlendAlpha(alpha);
		end

		getglobal("TipsFrameBkg"):SetBlendAlpha(alpha);
		
		if alpha == 0 then
			alpha = 1.0;
			this:Hide();			
		end
	end
end

function TipsFrameType1_OnClick()
    IsLongPressTips = false;
    local index = ((ClientBackpack and ClientBackpack:getShortcutStartIndex()) or SHORTCUT_START_INDEX)
	if tipsGridIndex >= index and tipsGridIndex < index+1000 then
		local i = tipsGridIndex - index + 1;
		local btnName = "ToolShortcut"..i;
		if index == SHORTCUT_START_INDEX_EDIT then
			btnName = "OldUITipsHackItem"
		end
		getglobal("MItemTipsFrame"):SetClientString(btnName);
	end
	UpdateMItemTipsFrameInfo();
end

function TipsFrameType2_OnClick()
	--设置彩蛋、彩蛋枪颜色
	if ClientCurGame:isInGame() and ClientMgr:isMobile() then
        local itemid = CurMainPlayer:getCurToolID()
        if itemid == ITEM_COLORED_GUN or itemid == ITEM_COLORED_EGG or itemid == ITEM_COLORED_EGG_SMALL then
            if CurWorld ~= nil and CurWorld:isGameMakerRunMode() ~= true and tipsColor ~= nil then
                CurMainPlayer:setSelectedColor(tipsColor)
                SetGunMagazine(0,0)
            end
        end
	end
    
end

function TipsFrameBan_OnClick()
	local itemId = this:GetClientID();
	local itemDef = ItemDefCsv:get(itemId);
	if itemId > 0 and IsRoomOwner() and itemDef ~= nil then
		BanItem(itemId);
	end
end

function BanItem(itemId)
	local itemDef = ItemDefCsv:get(itemId);
	if itemDef ~= nil then
		local state;
		if CheckAllServerBan(itemId) then
			PermitsCallModuleScript("banItem",itemId, false)
			ShowGameTips(GetS(879, itemDef.Name), 3);
			state = false;
		else
			if PermitsCallModuleScript("getIgnorePermit") then --重置模式不能禁用
				ShowGameTips(GetS(8044));
				return;
			end
			PermitsCallModuleScript("banItem",itemId, true)
			ShowGameTips(GetS(878, itemDef.Name), 3);
			state = true
		end
		PermitsCallModuleScript("sendPermitMsg",0)
		UpdateGrid2Ban(itemId, state);
		if GetInst('SceneEditorMsgHandler') and GetInst('SceneEditorMsgHandler').dispatcher and SceneEditorResourceDef and SceneEditorResourceDef.event then
			GetInst('SceneEditorMsgHandler'):dispatcher(SceneEditorResourceDef.event.refresh_itemview_banstate, itemId);
		end
	end
end

function MouseTipsFrame_OnLoad()
	this:setUpdateTime(0.05);
	Log("MouseTipsFrame_OnLoad");
end

function MouseTipsFrame_OnShow()
	Log("MouseTipsFrame_OnShow");
end

function MouseTipsFrame_OnUpdate()
	Log("MouseTipsFrame_OnUpdate");
end

function UpdateGrid2Ban(itemId, state)
	--创造模式背包栏
	if getglobal("CreateBackpackFrame"):IsShown() then
		local t_itemDef = GetItemDefTable2CreateType();
		local listview = getglobal("CreateBox")
		for i=1, CREATE_BACKPACK_MAX do
			if i <= #(t_itemDef) and t_itemDef[i].ID == itemId  then
				local cell = listview:cellAtIndex(i-1)
				if cell then
					local ban 	= getglobal(cell:GetName().."Ban");
					local icon 	= getglobal(cell:GetName().."Icon");
					if state then
						ban:Show();
						icon:SetGray(true);
					else
						if t_itemDef[i].UnlockFlag > 0 and not isItemUnlockByItemId(t_itemDef[i].ID) then--未解锁的物品
							icon:SetGray(true);
						else
							icon:SetGray(false);
						end
						ban:Hide();
					end
					break;
				end
			end
		end

		for i=1, MAX_SHORTCUT do
			local grid_index = ClientBackpack:getShortcutStartIndex()+i-1;
			local gridItemId = 	ClientBackpack:getGridItem(grid_index);
			if gridItemId == itemId then
				local ban 	= getglobal("CreateBackpackFrameShortcutGrid"..i.."Ban");
				local icon 	= getglobal("CreateBackpackFrameShortcutGrid"..i.."Icon");
				if state then
					ban:Show();
					icon:SetGray(true);
				else
					if t_itemDef[i].UnlockFlag > 0 and not isItemUnlockByItemId(t_itemDef[i].ID) then--未解锁的物品
						icon:SetGray(true);
					else
						icon:SetGray(false);
					end
					ban:Hide();
				end
				break;
			end
		end
	end
	--背包栏
	if getglobal("RoleFrame"):IsShown() then
		for i=1, BACK_PACK_GRID_MAX do
			local grid_index = i+BACKPACK_START_INDEX-1;
			local gridItemId = ClientBackpack:getGridItem(grid_index);
			if gridItemId == itemId then
				local ban 	= getglobal("RoleFrameBackpackGrid"..i.."Ban");
				local icon 	= getglobal("RoleFrameBackpackGrid"..i.."Icon");
				if state then
					ban:Show();
					icon:SetGray(true);
				else
					ban:Hide();
					icon:SetGray(false);
				end
			end
		end
		for i=1, MAX_SHORTCUT do
			local grid_index = i+ClientBackpack:getShortcutStartIndex()-1;
			local gridItemId = ClientBackpack:getGridItem(grid_index);

			if gridItemId == itemId then
				local ban 	= getglobal("RoleFrameShortcutGrid"..i.."Ban");
				local icon 	= getglobal("RoleFrameShortcutGrid"..i.."Icon");
				if state then
					ban:Show();
					icon:SetGray(true);
				else
					ban:Hide();
					icon:SetGray(false);
				end
			end
		end
	end

	--快捷栏
	for i=1, MAX_SHORTCUT do
		local grid_index = ClientBackpack:getShortcutStartIndex()+i-1;
		local gridItemId = 	ClientBackpack:getGridItem(grid_index);
		if gridItemId == itemId then
			local ban 	= getglobal("ToolShortcut"..i.."Ban");
			local icon 	= getglobal("ToolShortcut"..i.."Icon");
			if state then
				ban:Show();
				icon:SetGray(true);
			else
				ban:Hide();
				icon:SetGray(false);
			end
		end	
	end
end

function ItemTipsFrame_OnClick()
	tipsItemId = nil;
	tipsGridIndex = -1;
	this:Hide();
end

function ItemTipsBigFrame_OnClick()
	tipsItemId = nil;
	tipsGridIndex = -1
	this:Hide();
end

--------------------------------------------------MItemTipsFrame-----------------------------------------
PressItemTop = 0;
PressItemBottom = 0;
PressItemLeft = 0;
PressItemRight = 0;
PressItemBtnName = nil;
IsLongPressTips = false;		--标记是否为长按tips;

function SetMTipsInfo(grid_index, btnName, isLong, itemId,craftData)
	local btn = getglobal(btnName);

	local miniUIMgr = GetInst("MiniUIManager");
	if miniUIMgr and miniUIMgr:IsShown("MapCommentAutoGen") then
		return; --评论显示时取消Hover效果
	end

	IsLongPressTips	= isLong;
	if grid_index >= 0 then
		tipsItemId	= ClientBackpack:getGridItem(grid_index);
	else
		tipsItemId = itemId
	--	PressItemId = itemId;
	end
	
	if btn then
		PressItemTop	= btn:GetTop();			
		PressItemBottom = btn:GetBottom();
		PressItemLeft	= btn:GetLeft();
		PressItemRight	= btn:GetRight();
	end

	tipsGridIndex = grid_index;

	if tipsItemId and tipsItemId > 0 then
		getglobal("MItemTipsFrame"):SetClientString(btnName);
		if not getglobal("MItemTipsFrame"):IsShown() then
			getglobal("MItemTipsFrame"):SetClientID(0);
		end
		UpdateMItemTipsFrameInfo(craftData);
		if itemId == 12931 then -- 热更 不能出现国庆
			getglobal("MItemTipsFrameDesc"):SetText("可在节日商店兑换各种奖励哦")
		end
	end
end

function SetMTipsInfoInMap(btnName,isLong,mapItemData)
	--先用一个道具表内的道具转换下ui布局，整个弹窗代码太乱，不好改动
	SetMTipsInfo(-1, this:GetName(), true, 10005)

	local btn = getglobal(btnName)
	if btn then 
		PressItemTop	= btn:GetTop()		
		PressItemBottom = btn:GetBottom()
		PressItemLeft	= btn:GetLeft()
		PressItemRight	= btn:GetRight()
	end 
	getglobal("MItemTipsFrame"):SetClientString(btnName)
	if not getglobal("MItemTipsFrame"):IsShown() then
		getglobal("MItemTipsFrame"):SetClientID(0)
	end

	IsLongPressTips	= isLong

	if mapItemData then 
		tipsItemId = mapItemData.id
		DownloadPicAndSet(getglobal("MItemTipsFrameIcon"),mapItemData.iconUrl)
		DefMgr:filterStringDirect(mapItemData.name)
		getglobal("MItemTipsFrameName"):SetText(mapItemData.name)
		DefMgr:filterStringDirect(mapItemData.desc)
		getglobal("MItemTipsFrameDesc"):SetText(mapItemData.desc,224, 220, 202)
	end 

	getglobal("MItemTipsFrame"):Show()
end

function HideMTipsInfo()
	if ClientMgr:isPC() and CraftingTipsCloseWait then
		threadpool:work(function()
				threadpool:wait(2)
				getglobal("MItemTipsFrame"):Hide();
				CraftingTipsCloseWait = false
			end)
	else
		getglobal("MItemTipsFrame"):Hide();
	end
end

function GetCraftingInfo(craftingDef)
	t_info = {};
	for i=1, 9 do
		local stuffSum = craftingDef.GridX * craftingDef.GridY;
		if craftingDef.MaterialID[i-1] ~= 0 and i <= stuffSum then
			local hasItem = false;
			for j=1, #(t_info) do
				if craftingDef.MaterialID[i-1] == t_info[j].id then
					t_info[j].num = t_info[j].num + craftingDef.MaterialCount[i-1];
					hasItem = true;
					break;
				end
			end
			if not hasItem then
				table.insert(t_info, {id=craftingDef.MaterialID[i-1], num=craftingDef.MaterialCount[i-1],});
			end
		end
	end

	return t_info;
end

function SetTipsFramePos(frame, frameH)
	local realwidth = frame:GetRealWidth();
	local realheight = frameH * UIFrameMgr:GetScreenScale();
	local screenWidth = GetScreenWidth();
	local screenHeight = GetScreenHeight();

	local btnName = getglobal("MItemTipsFrame"):GetClientString();
	if btnName == "" then
		return;
	end

	if realheight <= GetScreenHeight() - PressItemBottom then	--下方
		local offsetX = PressItemLeft + (PressItemRight-PressItemLeft-realwidth)/2;
		if offsetX < 0 then
			frame:SetPoint("topleft", btnName, "bottomleft", 0, 0);
		elseif offsetX > (screenWidth - realwidth) then
			frame:SetPoint("topright", btnName, "bottomright", 0, 0);
		else
			frame:SetPoint("top", btnName, "bottom", 0, 0);		
		end	
	elseif realheight <= PressItemTop then 	--上方
		local offsetX = PressItemLeft + (PressItemRight-PressItemLeft-realwidth)/2;
		if offsetX < 0 then
			frame:SetPoint("bottomleft", btnName, "topleft", 0, 0);	
		elseif offsetX > (screenWidth - realwidth) then
			frame:SetPoint("bottomright", btnName, "topright", 0, 0);
		else
			frame:SetPoint("bottom", btnName, "top", 0, 0);
		end
	elseif realwidth <= PressItemLeft then --左边
		if (PressItemBottom + realheight) >= screenHeight then
			frame:SetPoint("right", btnName, "left", 0, -(PressItemBottom + realheight / 2 - screenHeight));
		else
			frame:SetPoint("right", btnName, "left", 0, 0);
		end
	else									--右边
		if (PressItemBottom + realheight) >= screenHeight then
			frame:SetPoint("left", btnName, "right", 0, -(PressItemBottom + realheight / 2 - screenHeight));
		else
			frame:SetPoint("left", btnName, "right", 0, 0);
		end
	end
end

function SetTipsFramePosForBtnFrame(frame)
	local btnName = getglobal("MItemTipsFrame"):GetClientString();

	if string.find(btnName, "EnchantTopBoxItem") then	--合并附魔的上面格子
		frame:SetPoint("topleft", "$parent", "topleft", 725, 127);
	elseif string.find(btnName, "EnchantBottomBox") then	--合并附魔的下面格子
		frame:SetPoint("bottomleft", "$parent", "topleft", 725, 570);
	elseif string.find(btnName, "EnchantRandomBox") then	--随机附魔的格子
		frame:SetPoint("topleft", "$parent", "topleft", 725, 127);
	elseif string.find(btnName, "RoleFrameBackpackGrid") then	--背包栏
		frame:SetPoint("right", "RoleFrameBackpack", "left", 0, -10);
	elseif string.find(btnName, "RoleFrameShortcutGrid") then
		frame:SetPoint("right", "RoleFrameBackpack", "left", 0, -10);
	elseif string.find(btnName, "ToolShortcut") then	--快捷栏
		if getglobal("StorageBoxFrame"):IsShown() then
			frame:SetPoint("topleft", "$parent", "topleft", 760, 115);
		else
			frame:SetPoint("center", "$parent", "center", 0, 0);
		end
	elseif string.find(btnName, "CreateBackpackFrameShortcutGrid") then	--创造模式背包快捷栏
		frame:SetPoint("center", "$parent", "center", 0, 0);
	elseif string.find(btnName, "HomelandBackpackShortcutGrid") then -- 家园背包快捷栏
		frame:SetPoint("center", "$parent", "center", 0, 0)
	elseif string.find(btnName, "StorageLeftBox") then	--箱子左边格子
		frame:SetPoint("topleft", "$parent", "topleft", 760, 115);
	elseif string.find(btnName, "StorageRightBox") then	--箱子右边格子
		frame:SetPoint("topright", "$parent", "topleft", 650, 115);
	elseif string.find(btnName, "Equip") then		--箱子右边格子
		frame:SetPoint("topleft", "$parent", "topleft", 785, 80);
	elseif string.find(btnName, "MiniProduct") then		--2*2制作栏边格子
		frame:SetPoint("bottom", "$parent", "bottom", 0, -50);
	elseif string.find(btnName, "NormalProduct") then	--3*3制作栏边格子
		frame:SetPoint("bottom", "$parent", "bottom", 0, -50);	
	elseif string.find(btnName, "Pokedex") then	--图鉴格子
		frame:SetPoint("bottom", "PokedexFrame", "bottom", 0, -20);
	elseif string.find(btnName,"RewardItemBtn") then --任务界面里奖励
		frame:SetPoint("center", "$parent", "center", 0, 0);
	elseif string.find(btnName, "AchievementDecsText") then --任务界面里的描述超链接
        frame:SetPoint("bottom", btnName, "top", 0, 0);
	elseif string.find(btnName,"TaskTrackFrameRewardBtn") then -- 主界面任务
		frame:SetPoint("right", btnName, "left", 0, 0);
	elseif string.find(btnName,"OldUITipsHackItem") then -- 新UI做的改进功能
		local inttype = getglobal("MItemTipsFrame"):GetClientUserData(0)
		if inttype == 1 then--快捷栏 "ToolShortcut"
			if getglobal("StorageBoxFrame"):IsShown() then
				frame:SetPoint("topleft", "$parent", "topleft", 760, 115);
			else
				frame:SetPoint("center", "$parent", "center", 0, 0);
			end
		end
	end
end

function IsShowPlaceBtn(btnName)
	if btnName ~= nil and btnName ~= "" then
		local placeBtnName = getglobal("MItemTipsFramePlaceBtnName")
		if string.find(btnName, "Enchant") and not ClientMgr:isPC() then
			placeBtnName:SetText(GetS(640));
			return true;
		elseif string.find(btnName, "RoleFrameEquipGrid") and not ClientMgr:isPC() then
			placeBtnName:SetText(GetS(643));
			return true
		elseif string.find(btnName, "RoleFrameBackpackGrid") then
			if tipsGridIndex >= 0 and IsEquip(tipsGridIndex) and not ClientMgr:isPC() then
				placeBtnName:SetText(GetS(814));
				return true
			end
		elseif string.find(btnName, "RoleFrameShortcutGrid") then
			if tipsGridIndex >= 0 and  IsEquip(tipsGridIndex) and not ClientMgr:isPC() then
				placeBtnName:SetText(GetS(814));
				return true
			end
		elseif string.find(btnName, "Storage") and not ClientMgr:isPC() then
			if string.find(btnName, "StorageLeft") then
				placeBtnName:SetText(GetS(641));
			elseif string.find(btnName, "StorageRight") then
				placeBtnName:SetText(GetS(642));
			end
			return true;
		elseif string.find(btnName, "ToolShortcut") then
			if getglobal("StorageBoxFrame"):IsShown() and not ClientMgr:isPC() then
				placeBtnName:SetText(GetS(641));
				return true;
			else
				--[[
				if tipsItemId > 0 then
					local itemDef = ItemDefCsv:get(tipsItemId);
					if itemDef ~= nil and itemDef.UseTarget == 10 then
						placeBtnName:SetText(GetS(186));
						return true;
					end
				end
				]]
			end
		elseif string.find(btnName, "Ride") then
			if string.find(btnName, "RideBox") then
				placeBtnName:SetText(GetS(3013));
			elseif string.find(btnName, "CurEquip") then
				placeBtnName:SetText(GetS(643));
			end
			return true;
		elseif string.find(btnName, "Equip") and not ClientMgr:isPC() then
			if string.find(btnName, "EquipBox") then
				placeBtnName:SetText(GetS(3013));
			elseif string.find(btnName, "EquipGrid") then
				placeBtnName:SetText(GetS(643));
			end
			return true;		
		elseif string.find(btnName, "PackFrameItem") then
			--[[
			if tipsItemId > 0 then
				local itemDef = ItemDefCsv:get(tipsItemId);
				if itemDef ~= nil and itemDef.UseTarget == 10 then
					placeBtnName:SetText(GetS(186));
					return true;
				end
			end
			]]
		end

		
	end
	return false
end

function IsShowTipsBkgFrame(btnName)
	if btnName ~= nil and btnName ~= "" then
		if string.find(btnName, "Enchant") then
			return false;
		elseif string.find(btnName, "PackFrame") then
			return false;
		elseif string.find(btnName, "RoleFrame") then
			return false;
		elseif string.find(btnName, "ToolShortcut") then
			return false;
		elseif string.find(btnName, "Storage") then
			return false;
		elseif string.find(btnName, "Equip") then
			return false;
		elseif string.find(btnName, "Ride") then
			return false;
		elseif string.find(btnName, "MiniProduct") then
			return false;
		elseif string.find(btnName, "NormalProduct") then
			return false;
		elseif string.find(btnName, "Pokedex") then
			return false;
		end
	end

	return true;
end


local function GetRuneItemDisplayName(runeid, runeval1, runeval2)
	if not runeid or not runeval1 or not runeval2 then 
		return nil
	end
	local runeDef = DefMgr:getRuneDef(runeid)--val0--val1--itemid
	if runeDef then 
		print("GetRuneItemDisplayName: runeid = ", runeid, runeval1, runeDef.DisplayType)
		local trueId = math.floor(runeid / 100);
		if trueId == 10 or trueId == 11 or trueId == 32 then
			runeval2 = math.floor(runeval2 + 0.5);
			runeval1 = math.floor(runeval1 + 0.5);
		end
		if runeDef.DisplayType == 0 then --使用数值1
			--print("GetRuneItemDisplayName: ret:",string.format("%s%d",runeDef.AttrDesc, runeval1))
			return string.format("%s%d",runeDef.AttrDesc, runeval1)
		elseif runeDef.DisplayType == 1 then --使用数值2
			--print("GetRuneItemDisplayName: ret:",string.format("%s%d",runeDef.AttrDesc, runeval2))
			return string.format("%s%d",runeDef.AttrDesc, runeval2)
		elseif runeDef.DisplayType == 2 then --使用数值1  * 100  %
			--print("GetRuneItemDisplayName: ret:",string.format("%s%d%%",runeDef.AttrDesc, runeval1*100))
			return string.format("%s%d%%",runeDef.AttrDesc, runeval1*100)
		elseif runeDef.DisplayType == 4 then -- 只使用描述字段
			return runeDef.AttrDesc
		else --使用数值1   %
			--print("GetRuneItemDisplayName: ret:",string.format("%s%d%%",runeDef.AttrDesc, runeval1))
			return string.format("%s%d%%",runeDef.AttrDesc, runeval1)
		end
	end 
	return nil
end


function GetRuneDisplayName(grid_index, backpack_)
	local ret = {}	
	if not grid_index or grid_index < 0 then 
		return ret
	end
	local backpack = backpack_ or ClientBackpack
	if not backpack then
		return ret
	end
	local itemId = backpack:getGridItem(grid_index)
	if isRuneStoneAuthed(itemId) then --已经鉴定的符文石
		local details = backpack:getGridUserdataStr(grid_index)
		local attrs = JSON:decode(details)
		if attrs then 
			local itemDesc = GetRuneItemDisplayName(attrs.runeid, attrs.val0, attrs.val1)
			if itemDesc then 
				print("runestone:",grid_index,itemDesc)
				table.insert(ret, itemDesc)
			end 
		end 
	else--符文处理--string.format
		local runeNum = backpack:getRuneNum(grid_index)
		if runeNum > 0 then 
			for i = 0,runeNum-1 do
				local gridRuneItemData = backpack:getRuneItem(grid_index, i)
				if gridRuneItemData then 
					local itemDesc = GetRuneItemDisplayName(gridRuneItemData:getRuneId(),gridRuneItemData:getRuneVal0(),gridRuneItemData:getRuneVal1())
					if itemDesc then
						print("rune:",grid_index,itemDesc)
						table.insert(ret, itemDesc)
					end
				end 
			end
		end 
	end 
	return ret	
end


local function _UpdateRuneAndEnchant(tipsGridIndex)
	local runeDesces = GetRuneDisplayName(tipsGridIndex)
	local num = #runeDesces
	print("grid runenum:", num, tipsGridIndex)
	if num == 0 then--附魔
		if ClientCurGame:isInGame() then
			if not CurWorld:isGodMode() and tipsGridIndex ~= -1 then
				num = ClientBackpack:getGridEnchantNum(tipsGridIndex); --附魔属性数量
			end
		end	
		for i = 0,num-1 do 
			local id = ClientBackpack:getGridEnchantId(tipsGridIndex, i);
			local enchantDef = DefMgr:getEnchantDef(id);
			if enchantDef then 
				table.insert(runeDesces, enchantDef.Name..enchantDef.EnchantLevel)
			end 
		end 
	end
	num = #runeDesces
	for i=1, 5 do
		local enchant = getglobal("MItemTipsFrameEnchant"..i);
		if i <= num then
			enchant:Show();
			print("show index:", i, " content:",runeDesces[i])
			enchant:SetText(runeDesces[i]);
		else
			enchant:Hide();
			enchant:SetText("");
		end
	end		
	return num
end

--村民生物蛋名称 需特殊处理 code-by:lizb
function getEggItemName(itemId, gridIdx)
	local itemDef = ItemDefCsv:get(itemId)
	local itemName = itemDef and itemDef.Name or "";

	if g_VillageEggs[itemId] and gridIdx >= 0 then 
		local jsonStr	= ClientBackpack:getGridUserdataStr(gridIdx);
		local itemData = JSON:decode(jsonStr);
		if itemData and itemData['Base_Name'] then
			local baseName = itemData['Base_Name']
			itemName = string.gsub(itemName, "-.+", '-'..baseName)
		end
	end
	return itemName
end

-- 新的更改  插件中修改生物 对应的生物蛋的Name和Desc要改用MonsterDef的(规则：itemid-10000)  否则继续显示原来的ItemDef表
function UpdateMItemTipsFrameInfo(replaceCraftData)
	local MItemTipsFrame = getglobal("MItemTipsFrame");
	if tipsItemId == nil or tipsItemId == 0 then
		MItemTipsFrame:Hide();
		return;
	end
	local itemDef = ItemDefCsv:get(tipsItemId)
	if itemDef == nil then
		MItemTipsFrame:Hide();
		return;
	end

	local actorMapDef
	if itemDef.UseScript == "MobEgg_OnUse" or itemDef.UseScript == "AquaticEgg_OnUse" then
		local monsterId = g_EggToMonster[tipsItemId]
		if monsterId == nil then monsterId = tipsItemId-10000 end
		actorMapDef = ModMgr:tryGetMonsterDef(monsterId)
	end

	local needFilter = false;
	if itemDef.gamemod then  --插件库
		needFilter = true;
	elseif string.find(itemDef.Icon, "custom") then --微缩相关
		needFilter = true;
	else
		local blockDef = BlockDefCsv:get(tipsItemId);
		if blockDef and blockDef.Type == "custombasic" then
			needFilter = true;
		end
	end

	--特长界面打开时不展示，否则界面层级错乱
	local specialtyIsShow = false
	if GetInst("MiniUIManager"):IsShown("Specialty_main") then
		specialtyIsShow = true
	end
	if (not specialtyIsShow) and (not MItemTipsFrame:IsShown()) then
		MItemTipsFrame:Show();
	end
    local itemName = actorMapDef == nil and itemDef.Name or actorMapDef.Name
    local itemDesc = actorMapDef == nil and itemDef.Desc or actorMapDef.Desc


	--richTextQuality是家园的ui非家园不显示
	local richTextQuality = getglobal("MItemTipsFrameQuality") 
	richTextQuality:Hide()

    local gird_userdatastr = ""
    --if ClientBackpack then
    --	gird_userdatastr = ClientBackpack:getGridUserdataStr(tipsGridIndex) or "";
    --end

    --村民对应的生物蛋 特殊处理
    if g_VillageEggs[tipsItemId] then
		itemName = getEggItemName(tipsItemId, tipsGridIndex)
	end

    --机械胶囊，特殊处理
    if itemDef.Type == ITEM_TYPE_VEHICLE and tipsGridIndex >= 0 then
    	local def = ItemDefCsv:get(10112)
    	local userdata_str = ClientBackpack:getGridUserdataStr(tipsGridIndex) or "";
    	gird_userdatastr = userdata_str
    	local data = JSON:decode(userdata_str)
    	if data and data.itemname and data.itemname ~= "" then
    		itemName = data.itemname
    	else
    		itemName = def.Name
    	end
    	if data and data.itemdesc and data.itemdesc ~= "" then
    		itemDesc = data.itemdesc
    	else
    		itemDesc = def.Desc
		end
		
		needFilter = true;
    end


    -- 信纸特别处理
    if tipsItemId == ITEM_LETTERS and tipsGridIndex >= 0 then
        local userdata_str = ClientBackpack:getGridUserdataStr(tipsGridIndex);
        if string.len(userdata_str) ~= 0 then
            local uin, author, title, context, _, LetterCanSave,LetterChangeTime,OldLettersTitle,OldLettersContext = LettersParse(userdata_str)
			itemDef = ItemDefCsv:get(tipsItemId);
			if not CheckEnableShow(LetterChangeTime) then
				if OldLettersTitle and OldLettersTitle ~= "" then
					if Utf8StringLen(OldLettersTitle) > 6 then
						itemName = Utf8StringSub(OldLettersTitle, 6).."..."
					else
						itemName = OldLettersTitle;
					end
				
				else
					itemName = "";
				end
				if OldLettersContext and OldLettersContext ~= "" then
					if Utf8StringLen(OldLettersContext) > 40 then
						itemDesc = Utf8StringSub(OldLettersContext, 40).."..."
					else
						itemDesc = OldLettersContext;
					end
				
				else
					itemDesc = GetS(321000)
				end
			else
				if Utf8StringLen(title) > 6 then
					itemName = Utf8StringSub(title, 6).."..."
				else
					itemName = title
				end
				if Utf8StringLen(context) > 40 then
					itemDesc = Utf8StringSub(context, 40).."..."
				else
					itemDesc = context
				end
			end
           

            tipsItemId = ITEM_LETTERS_USED
			
		end
		
		needFilter = true;
    end

	-- 乐谱特别处理
	-- local tab = {name = "xxx",des = "aaa"}
	if tipsItemId == ITEM_MUSIC_PU and tipsGridIndex >= 0 then
        local userdata_str = ClientBackpack:getGridUserdataStr(tipsGridIndex);
        if string.len(userdata_str) ~= 0 then
			local tabs = JSON:decode(userdata_str)
			itemName = tabs.name
			itemDesc = tabs.des

            -- local uin, author, title, context = LettersParse(userdata_str)
            if Utf8StringLen(itemName) > 6 then
                itemName = Utf8StringSub(itemName, 6).."..."
            end
            if Utf8StringLen(itemDesc) > 40 then
                itemDesc = Utf8StringSub(itemDesc, 40).."..."
            end

			itemDef = ItemDefCsv:get(tipsItemId);
		end
		
		needFilter = true;
	end

    --书做特殊处理
    if tipsItemId == ITEM_BOOK and tipsGridIndex >= 0 then
        local userdata_str = ClientBackpack:getGridUserdataStr(tipsGridIndex);
        if string.len(userdata_str) ~= 0 then
        	local bookTab = JSON:decode(userdata_str);
        	print("UpdateMItemTipsFrameInfo", bookTab)
        	--书 增加多语言
        	local lang = get_game_lang()
			if bookTab and bookTab.multiLangName and bookTab.multiLangName ~= "" then
				bookTab.multiLangName = JSON:decode(bookTab.multiLangName)
				if bookTab.multiLangName.originalID and lang ~= bookTab.multiLangName.originalID and bookTab.multiLangName.textList[tostring(lang)] then
					bookTab.title = bookTab.multiLangName.textList[tostring(lang)]
				end
			end
			
			if bookTab and bookTab.multiLangDetails and bookTab.multiLangDetails ~= "" then
				bookTab.multiLangDetails = JSON:decode(bookTab.multiLangDetails)
				if bookTab.multiLangDetails.originalID and lang ~= bookTab.multiLangDetails.originalID and bookTab.multiLangDetails.textList[tostring(lang)] then
					bookTab.context = bookTab.multiLangDetails.textList[tostring(lang)]
				end
        	end

            if Utf8StringLen(bookTab.title) > 6 then
                itemName = Utf8StringSub(bookTab.title, 6).."..."
            else
                itemName = bookTab.title
            end

            if Utf8StringLen(bookTab.context) > 40 then
                itemDesc = Utf8StringSub(bookTab.context, 40).."..."
            else
                itemDesc = bookTab.context
            end

			itemDef = ItemDefCsv:get(tipsItemId);
		end
		
		needFilter = true;
    end

    -- 指令集特别处理
    if tipsItemId == ITEM_INSTRUCTION and tipsGridIndex >= 0 then
        local userdata_str = ClientBackpack:getGridUserdataStr(tipsGridIndex);
        if string.len(userdata_str) ~= 0 then
            local InstructionTitle, InstructionValue,InstructionTable,InstructionSwitchTable= InstructionParse(userdata_str);

            if Utf8StringLen(InstructionTitle) > 6 then
                itemName = Utf8StringSub(InstructionTitle, 6).."...";
            elseif Utf8StringLen(InstructionTitle) ~= 0 then
                itemName = InstructionTitle;
            end
		end
		
		needFilter = true;
    end

    --蓝图图纸特别处理
    if tipsItemId == ITEM_BLUEPRINT and tipsGridIndex >= 0 then
    	Log("UpdateMItemTipsFrameInfo: BluePrint:");
        local userdata_str = ClientBackpack:getGridUserdataStr(tipsGridIndex);

        Log("tipsGridIndex = " .. tipsGridIndex);
        Log("userdata_str = " .. userdata_str);

        if string.len(userdata_str) ~= 0 then
            local uin, author, title, context, filename, dimX, dimY, dimZ = BlueprintStringParse(userdata_str);

            Log("uin = " .. uin);
            Log("author = " .. author);
            Log("title = " .. title);
            Log("context = " .. context);
            Log("filename = " .. filename);
            Log("dimX = " .. dimX);
            Log("dimY = " .. dimY);
            Log("dimZ = " .. dimZ);
            
            if dimX then
            	dimX = tonumber(dimX);
            	if dimX < 0 then
            		dimX = 0 - dimX;
            	end
            end

            if dimY then
            	dimY = tonumber(dimY);
            	if dimY < 0 then
            		dimY = 0 - dimY;
            	end
            end

            if dimZ then
            	dimZ = tonumber(dimZ);
            	if dimZ < 0 then
            		dimZ = 0 - dimZ;
            	end
            end

            if Utf8StringLen(title) > 6 then
                itemName = Utf8StringSub(title, 6).."..."
            else
                itemName = title
            end

            local desc = GetS(352) .. "：" .. author .. "\n" .. GetS(9188) .. "：" .. "x = " .. dimX .. ", y = " .. dimY .. ", z = " .. dimZ;
            itemDesc = desc;
		end
		
		needFilter = true;
    end

    --可染色方块，特殊处理 by:Jeff
    if IsDyeableBlockLua(tipsItemId)and tipsGridIndex >= 0 then
    	local userdata_str = ClientBackpack:getGridUserdataStr(tipsGridIndex) or "";
    	gird_userdatastr = userdata_str
    end

	local isShowBtn = not ClientMgr:isPC() or MItemTipsFrame:GetClientID() > 0;
	local btnName = MItemTipsFrame:GetClientString();

	--背景蒙板是否显示
	if not IsLongPressTips then
		if IsShowTipsBkgFrame(btnName) then
			getglobal("TipsBkgFrame"):Show();
		end
	end		
	local frameH = 118;
	local frameW = 797;
	local enchantH = 28;
	--附魔/符文相关
	local num = _UpdateRuneAndEnchant(tipsGridIndex);
	frameH = frameH + num * enchantH;
	--名字
	if needFilter then
		DefMgr:filterStringDirect(itemName);
	end
	getglobal("MItemTipsFrameName"):SetText(itemName);

	--描述
    local MItemTipsFrameDesc = getglobal("MItemTipsFrameDesc");
	local descLines = 1;
	local textH = 28;
	local lineOffsetY = 0;
	local itemGetWay = itemDef.GetWay;

	if needFilter then
		DefMgr:filterStringDirect(itemDesc);
	end


	MItemTipsFrameDesc:SetText(itemDesc.."\n"..itemGetWay, 224, 220, 202)
	--食品tips后添加探险相关属性描述
	if (IsInHomeLandMap and IsInHomeLandMap()) then
		--只处理家园
		itemDesc = Homeland_GetExpeditionDesc(itemDef)
		local qualityDesc = Homeland_GetQualityDesc(itemDef)
		if qualityDesc then
			--getglobal("MItemTipsFrameTypeDesc"):
			richTextQuality:Show()
			richTextQuality:SetText(qualityDesc)
		end
		local ReplaceString = nil
		local homeDef = GetInst("HomeLandDataManager"):GetHomeLandDefinition("HomeItemDef", itemDef.ID)--DefMgr:getHomeItemDef(itemDef.ID)
		if homeDef then
			ReplaceString = homeDef.ReplaceString
		end
		--如果有ReplaceString这字段需要替换描述
		if type(ReplaceString) == "string" and string.len(ReplaceString) > 0 then
			local strId = tonumber(ReplaceString)
			if strId then
				local text = GetS(strId)
				if text then
					MItemTipsFrameDesc:SetText(text)
				end
			end
		end
	end
	descLines = MItemTipsFrameDesc:GetTextLines();
	if descLines > 10 then -- 自适应 3至10行
		descLines = 10;
	end

	MItemTipsFrameDesc:SetHeight(textH * descLines+1)
	MItemTipsFrameDesc:SetPoint("topleft", "MItemTipsFrame", "topleft", 30, frameH)
	if descLines <= 3 and num == 0 then --无附魔的情况下
		--descLines = 0; -- 三行以内无需加入后续计算
	end
	frameH = frameH + descLines * textH;

	if frameH < 185 then
		frameH = 185; -- 无下列任何附属说明时的大小
	end
	lineOffsetY = frameH + 2;
	if lineOffsetY < 140 then
		lineOffsetY = 140;
	end

	-- 图标
	SetItemIcon(getglobal("MItemTipsFrameIcon"), tipsItemId, gird_userdatastr);
	SetItemSkinIcon(tipsItemId)

	local packType = getglobal("MItemTipsFramePackType")
	local packDesc = getglobal("MItemTipsFramePackDesc")
	local packTitle = getglobal("MItemTipsFramePackTitle")
	local packNeed = getglobal("MItemTipsFramePackNeed1")

	--包裹
	local isPack = false;   --包裹详情
	if itemDef.Type == ITEM_TYPE_PACK then
		local packDef = DefMgr:getPackGiftDefByItemID(itemDef.ID)

		getglobal("MItemTipsFrameTypeDesc"):Show();
		packType:Show();
		packDesc:Show();
		packTitle:Show();
		packNeed:Show();


		if packDef then

			lineOffsetY = lineOffsetY + 14;

			packType:SetPoint("topleft", "MItemTipsFrame", "topleft", 30, lineOffsetY);
			if packDef.iPackType == 0 then
				packType:SetText(GetS(21806,GetS(21757)))
				packDesc:SetText(GetS(21808,packDef:getPackItemListSize()))
			elseif packDef.iPackType == 1 then
				packType:SetText(GetS(21806,GetS(21760)))
				local pNum = packDef:getPackItemListSize();
				packDesc:SetText(GetS(21807,pNum,packDef.iMaxOpenNum))
			end
			
			lineOffsetY = lineOffsetY + 25;

			packDesc:SetPoint("topleft", "MItemTipsFrame", "topleft", 30, lineOffsetY);
			lineOffsetY = lineOffsetY + 25;
			if packDef.iNeedCostItem == 0 then
				packTitle:Hide();
				packNeed:Hide();
			else
				packTitle:SetPoint("topleft", "MItemTipsFrame", "topleft", 30, lineOffsetY);
				packTitle:SetText(GetS(21809));
				packTitle:Show();
				lineOffsetY = lineOffsetY + 25;

				packNeed:SetPoint("topleft", "MItemTipsFrame", "topleft", 30, lineOffsetY);
				local packIcon = getglobal("MItemTipsFramePackNeed1Icon")


				local itemid = math.floor(packDef.iCostItemInfo/1000)
				local def = ItemDefCsv:get(itemid)
				itemid = def and def.ID or 101
				local pItem = ItemDefCsv:get(itemid)

				getglobal("MItemTipsFramePackNeed1Name"):SetText(pItem.Name.." x "..(packDef.iCostItemInfo%1000));
				SetItemIcon(packIcon, pItem.ID);

			end

			isPack = true;
			itemDef.TypeDesc = GetS(21754)
			
			lineOffsetY = lineOffsetY + 39;


			-- lineOffsetY = lineOffsetY + 14;

			frameH = frameH + 142;



		end
	else
		packType:Hide();
		packDesc:Hide();
		packTitle:Hide();
		packNeed:Hide();
	end

	local t_craftingInfo = {};
	local craftingDef = replaceCraftData or DefMgr:findCrafting(tipsItemId);
	if ClientBackpack and tipsGridIndex > 0 then
		local crafID = ClientBackpack:getGridSortId(tipsGridIndex)
		craftingDef = DefMgr:getCraftingDef(crafID, false, false) or craftingDef
	end
	local MItemTipsFrameGetTitle = getglobal("MItemTipsFrameGetTitle");
	local MItemTipsFrameGetDesc = getglobal("MItemTipsFrameGetDesc");
	if craftingDef ~= nil then
		t_craftingInfo = GetCraftingInfo(craftingDef);
	end

	-- 有配方则显示之
	if #t_craftingInfo > 0  and not (IsInHomeLandMap and IsInHomeLandMap())then--不是家园
		local GetDescLines = 1;
		--MItemTipsFrameGetDesc:Show();
		lineOffsetY = lineOffsetY;
		 MItemTipsFrameGetTitle:SetPoint("topleft", "MItemTipsFrame", "topleft", 30, lineOffsetY);
		-- 原版物品 或 需要工具箱的插件
		if itemDef.CopyID == 0 or craftingDef and not (craftingDef.CraftingItemID == DefMgr:getCraftEmptyHandID())then
			--getglobal("MItemTipsFrameCraftingNeed1"):SetPoint("topleft", "MItemTipsFrameGetDesc", "bottomleft", 0, 0);
			if itemDef.CopyID == 0 then -- 原版物品
				--MItemTipsFrameGetDesc:SetText(itemDef.GetWay, 208, 212, 224);
				--GetDescLines = MItemTipsFrameGetDesc:GetTextLines();
				--if GetDescLines == 0 then
				--	GetDescLines = 1;
				--end
				--MItemTipsFrameGetDesc:SetSize(320, textH * GetDescLines)
			else -- 插件 限定显示“在工具箱合成以下材料”
				--MItemTipsFrameGetDesc:SetText(GetS(4694), 208, 212, 224);
			end
		elseif itemDef.CopyID ~= 0 and craftingDef and (craftingDef.CraftingItemID == DefMgr:getCraftEmptyHandID()) then -- 不需要工具箱的插件
			--GetDescLines = 0;
			--MItemTipsFrameGetTitle:Hide();
			--MItemTipsFrameGetDesc:Hide();
		end

		frameH = frameH;
		for i=1, 9 do
			local needBtn 	= getglobal("MItemTipsFrameCraftingNeed"..i);
			local icon 	= getglobal("MItemTipsFrameCraftingNeed"..i.."Icon");
			local name 	= getglobal("MItemTipsFrameCraftingNeed"..i.."Name");
			if i <= #(t_craftingInfo) then
				needBtn:Show();
				local itemid 	= t_craftingInfo[i].id;
				local num 	= t_craftingInfo[i].num;
				local text	= GetS(644).."×"..num;
				if ItemDefCsv:get(itemid) ~= nil then
					text = ItemDefCsv:get(itemid).Name.."×"..num;
				end
				SetItemIcon(icon, itemid);
				name:SetText(text);
			else
				needBtn:Hide();
			end
		end
		--上一条分割线与文本框的间隔 文本框的高度 下一条分割线与文本框的间隔 所需物品块的高度（-第一个所需物品控件无偏移8）
		frameH = frameH + textH * GetDescLines + 14 + math.ceil( #(t_craftingInfo)/2 ) * 40;
		lineOffsetY = frameH;
		MItemTipsFrameGetTitle:Show();
	else
		for i=1, 9 do
			local needBtn 	= getglobal("MItemTipsFrameCraftingNeed"..i);
			needBtn:Hide();
		end
		MItemTipsFrameGetTitle:Hide();
		MItemTipsFrameGetDesc:Hide();
	end



	--关闭按钮
	if isShowBtn then
		getglobal("MItemTipsFrameCloseBtn"):Show();
	else
		getglobal("MItemTipsFrameCloseBtn"):Hide();
	end 

	--类型描述
	local  typeDesc = getglobal("MItemTipsFrameTypeDesc")
	typeDesc:SetText(itemDef.TypeDesc);
	
	--插件包
	if itemDef.gamemod and not itemDef.gamemod:getIsCCModType(CCModType_National) then
		local modname = itemDef.gamemod:getName()
		getglobal("MItemTipsFrameModName"):SetText(GetS(4058).."-"..modname);

		getglobal("MItemTipsFrameModName"):Show();
		typeDesc:SetPoint("topleft", "MItemTipsFrameName", "bottomleft", 0, 10);
	else
		getglobal("MItemTipsFrameModName"):Hide();
		typeDesc:SetPoint("topleft", "MItemTipsFrameName", "bottomleft", 0, 19);
	end

	--禁用和解禁
	local canShowBan = false;
	local MItemTipsFrameBanBtn = getglobal("MItemTipsFrameBanBtn");

	if ClientMgr:isPC() and IsRoomOwner() and (not btnName or not string.find(btnName, "Pokedex")) and (not btnName or not string.find(btnName, "PetNestAttributesPlane")) then
		canShowBan = true;
		if isShowBtn then
			MItemTipsFrameBanBtn:Show();
			if CheckAllServerBan(tipsItemId) then
				getglobal("MItemTipsFrameBanBtnName"):SetText(GetS(3547));
			else
				getglobal("MItemTipsFrameBanBtnName"):SetText(GetS(3546));
			end
		else
			MItemTipsFrameBanBtn:Hide();
		end
	else
		MItemTipsFrameBanBtn:Hide();
	end

	--物品回收和解锁Begin
	local MItemTipsFrameUnlockDesc = getglobal("MItemTipsFrameUnlockDesc");
	local MItemTipsFrameUnLockBtn = getglobal("MItemTipsFrameUnLockBtn");
	local MItemTipsFrameUnlockTitle = getglobal("MItemTipsFrameUnlockTitle");
	local MItemTipsFrameUnlockNeed1 = getglobal("MItemTipsFrameUnlockNeed1");
	MItemTipsFrameUnLockBtn:Hide();
	MItemTipsFrameUnlockTitle:Hide();
	MItemTipsFrameUnlockDesc:Hide();
	for i=1, Max_Recycle_Get do
		local need = getglobal("MItemTipsFrameUnlockNeed"..i);
		need:Hide();
	end

	local itemUnlockWay = itemDef.UnlockWay;
	local canRecycle = false;
	local isLock = false;
	local canUnLock = false;
	local recycleDef = DefMgr:getRecycleDef(itemDef.InvolvedID);

	if recycleDef ~= nil then
		if AccountManager:getAccountData():getAccountItemNum(recycleDef.ID) > 0 then
			canRecycle = true;
		end
	end
	if itemDef.UnlockFlag > 0 then
		if isItemUnlockByItemId(itemDef.ID) then	--已经解锁	
			isLock = false;
			canUnLock = false;
		else		
			isLock = true;
			if itemDef.UnlockType == 3 or itemDef.UnlockType == 5 then	--碎片解锁
				local hasNum = AccountManager:getAccountData():getAccountItemNum(itemDef.InvolvedID);
				local needNum = itemDef.ChipNum;
				if hasNum >= needNum or itemDef.UnlockType == 5 then
					canUnLock = true;
				else
					canUnLock = false;
				end
			elseif itemDef.UnlockType == 4 then -- 迷你豆解锁
				canUnLock = true;
			end
		end			
	end

	--家园里的tips不执行回收、解锁
	if btnName and (string.find(btnName, "HomeProducerTabInfo") or string.find(btnName, "HomelandBackpack") or string.find(btnName, "PetNestAttributesPlane")) then
		canRecycle = false;
		canUnLock = false;
		isLock = false;
		itemUnlockWay = "";
	end

	--按钮相关
	local MItemTipsFramePlaceBtn = getglobal("MItemTipsFramePlaceBtn");

	if btnName ~= nil and btnName ~= "" then
		if string.find(btnName, "Pokedex") then
			isShowBtn = true;
		end
		if isShowBtn and IsShowPlaceBtn(btnName) then
			if not (isLock or canRecycle) then
				frameH = frameH + 61;
			end
			MItemTipsFramePlaceBtn:Show();
		else
			MItemTipsFramePlaceBtn:Hide();
		end
	else
		MItemTipsFramePlaceBtn:Hide();
	end
	
	local hasMoreInfo = false;	--有更多信息的才显示Alt
	if itemDef.UnlockFlag == 0 then -- 无需解锁的道具
		if canShowBan then
			hasMoreInfo = true;
			if isShowBtn then
				hasMoreInfo = true;
				frameH = frameH + 67;
			end
		end
		MItemTipsFrameBanBtn:SetPoint("bottom", "MItemTipsFrame", "bottom", 0, -10);
	elseif isLock or canRecycle then -- 需要解锁的道具且未解锁 或 需要解锁的道具且已解锁还有碎片
		-- 解锁和回收的共同配置 Begin
		hasMoreInfo = true;
		MItemTipsFrameUnlockTitle:Show();
		MItemTipsFrameUnlockNeed1:Show();
		frameH = frameH + 47 + 23;
		-- 是回收而非解锁
		if not isLock and recycleDef.GetID[1] > 0 then
			frameH = frameH + 45;
		end

		if isShowBtn and not gIsSingleGame then
			MItemTipsFrameUnLockBtn:Show();

			if canShowBan then
				 MItemTipsFrameUnLockBtn:SetPoint("bottom", "MItemTipsFrameBkg", "bottom", -143, -4);
				MItemTipsFrameBanBtn:SetPoint("bottom", "MItemTipsFrameBkg", "bottom", 143, -4);
			else
				 MItemTipsFrameUnLockBtn:SetPoint("bottom", "MItemTipsFrameBkg", "bottom", 0, -4);
			end
			frameH = frameH + 67;

			if isEducationalVersion then
				MItemTipsFrameUnLockBtn:Hide();
			end
		end

		local icon = getglobal("MItemTipsFrameUnlockNeed1Icon");
		local name = getglobal("MItemTipsFrameUnlockNeed1Name");
		local chip = getglobal("MItemTipsFrameUnlockNeed1Chip");

		getglobal("MItemTipsFrameUnLockBtnNormal"):SetGray(false);
		getglobal("MItemTipsFrameUnLockBtnPushedBG"):SetGray(false);
		-- 解锁和回收的共同配置 End
		if isLock then -- 解锁
			MItemTipsFrameUnLockBtn:SetClientUserData(0, tipsItemId);
			MItemTipsFrameUnlockTitle:SetText("#cEC8F16"..GetS(667).."#cD0D4E0"..itemUnlockWay);

			if ClientMgr:isPC() and MItemTipsFrame:GetClientID() == 0 and hasMoreInfo and not MItemTipsFrameUnLockBtn:IsShown() then	--在没按Alt描述情况
				MItemTipsFrameUnlockTitle:SetPoint("bottomleft", "MItemTipsFrameBodyBkg", "bottomleft", 11, -80);
			else
				MItemTipsFrameUnlockTitle:SetPoint("bottomleft", "MItemTipsFrameBodyBkg", "bottomleft", 11, -45);
			end

			--MItemTipsFrameUnlockTitle:SetTextColor(236, 143, 22);
			--MItemTipsFrameUnlockNeed1:SetPoint("topleft", "MItemTipsFrameUnlockTitle", "bottomleft", 0, 0);
			MItemTipsFrameUnlockDesc:SetText(itemUnlockWay, 208, 212, 224);
			getglobal("MItemTipsFrameUnlockNeed1Name"):SetSize(370, 17);
			local lines = MItemTipsFrameUnlockDesc:GetTextLines();
			if lines == 0 then
				lines = 1;
			end
			MItemTipsFrameUnlockDesc:SetSize(330, textH * lines);
			-- 文本框的高度
			frameH = frameH + textH * (lines - 1);
			lineOffsetY = lineOffsetY + 16 + textH * lines + 47 - 8 + 14;
			SetItemIcon(icon, itemDef.InvolvedID);
			local unlockItemDef = ItemDefCsv:get(itemDef.InvolvedID);
			if unlockItemDef ~= nil then
				name:SetText(unlockItemDef.Name.."×"..itemDef.ChipNum);
			end

			getglobal("MItemTipsFrameUnLockBtnName"):SetText(GetS(3033));

			if not canUnLock then
				getglobal("MItemTipsFrameUnLockBtnNormal"):SetGray(true);
				getglobal("MItemTipsFrameUnLockBtnPushedBG"):SetGray(true);
			end

			--MItemTipsFrameUnlockDesc:Show();
			MItemTipsFrameUnlockNeed1:Show();
			chip:Show();
		elseif canRecycle then
			-- 回收
			MItemTipsFrameUnLockBtn:SetClientUserData(0, itemDef.InvolvedID);
			MItemTipsFrameUnlockTitle:SetText("#c46DC0A"..GetS(668));
			if MItemTipsFrameUnLockBtn:IsShown() then
				MItemTipsFrameUnlockTitle:SetPoint("bottomleft", "MItemTipsFrameBodyBkg", "bottomleft", 11, -80);
			else
				MItemTipsFrameUnlockTitle:SetPoint("bottomleft", "MItemTipsFrameBodyBkg", "bottomleft", 11, -120);
			end

			--MItemTipsFrameUnlockTitle:SetTextColor(70, 220, 10);
			--MItemTipsFrameUnlockNeed1:SetPoint("topleft", "MItemTipsFrameUnlockTitle", "topleft", 95, -2);
			getglobal("MItemTipsFrameUnlockNeed1Name"):SetSize(370, 17);
			MItemTipsFrameUnlockDesc:Hide();
			frameH = frameH - 10;
			lineOffsetY = lineOffsetY + 16 + 47 * 2 + 14;
			for i=1, Max_Recycle_Get do
				if i > 1 then
					icon = getglobal("MItemTipsFrameUnlockNeed"..i.."Icon");
					name = getglobal("MItemTipsFrameUnlockNeed"..i.."Name");
					chip = getglobal("MItemTipsFrameUnlockNeed"..i.."Chip");
				end
				if recycleDef.GetID[i-1] > 0 then
					getglobal("MItemTipsFrameUnlockNeed"..i):Show();

					SetItemIcon(icon, recycleDef.GetID[i-1]);
					local getRecycleItemDef = ItemDefCsv:get(recycleDef.GetID[i-1]);
					if getRecycleItemDef then
						local price = recycleDef.GetNum[i-1];
						local total = AccountManager:getAccountData():getAccountItemNum(itemDef.InvolvedID);
						local num = total*recycleDef.GetNum[i-1];
						local text = getRecycleItemDef.Name.."×"..num;
						if i == 1 then
							local total = AccountManager:getAccountData():getAccountItemNum(itemDef.InvolvedID);
							text = text.."   ("..GetS(728).."×"..total..")";
						end
						name:SetText(text);
					end
				else
					getglobal("MItemTipsFrameUnlockNeed"..i):Hide();
				end
			end
			getglobal("MItemTipsFrameUnLockBtnName"):SetText(GetS(669));
			chip:Hide();
		end
	else -- 需要解锁的道具且已解锁但无碎片
		getglobal("MItemTipsFrameUnlockNeed1Name"):SetSize(370, 17);
		if canShowBan then
			hasMoreInfo = true;
			if isShowBtn then
				hasMoreInfo = true;
				MItemTipsFrameBanBtn:SetPoint("bottom", "MItemTipsFrame", "bottom", 0, -10);
				frameH = frameH + 67;
			end
		end

		if string.len(itemUnlockWay) > 0 then
			MItemTipsFrameUnlockTitle:SetText("#cEC8F16"..GetS(667).."#cD0D4E0" ..itemUnlockWay);
			if ClientMgr:isPC() and MItemTipsFrame:GetClientID() == 0 and hasMoreInfo then	--在有Alt键描述情况
				MItemTipsFrameUnlockTitle:SetPoint("bottomleft", "MItemTipsFrameBodyBkg", "bottomleft", 11, -50);
			else
				MItemTipsFrameUnlockTitle:SetPoint("bottomleft", "MItemTipsFrameBodyBkg", "bottomleft", 11, -10);
			end

			--MItemTipsFrameUnlockTitle:SetTextColor(236, 143, 22);
			--MItemTipsFrameUnlockDesc:SetText(itemUnlockWay, 208, 212, 224);

			local lines = MItemTipsFrameUnlockDesc:GetTextLines();
			if lines == 0 then
				lines = 1;
			end
			-- line1的高度 文本框与line1的距离 文本框的高度
			MItemTipsFrameUnlockDesc:SetSize(330, textH * lines);
			frameH = frameH + textH * lines;

			--MItemTipsFrameUnlockDesc:Show();
			MItemTipsFrameUnlockTitle:Show();
		else
			MItemTipsFrameUnlockTitle:Hide();
			MItemTipsFrameUnlockDesc:Hide();
		end
	end

	--包裹显示详情
	if isPack and MItemTipsFrame:GetClientID() > 0 then
		if #t_craftingInfo > 0 then  --有配方
			frameH = frameH - 25
		end

		MItemTipsFrameUnLockBtn:Show();
		-- MItemTipsFrameUnLockBtn:SetPoint("top", "MItemTipsFrameLine2", "top", 100, 6);
		getglobal("MItemTipsFrameUnLockBtnName"):SetText(GetS(4756));

		if canShowBan then
			MItemTipsFrameUnLockBtn:SetPoint("bottom", "MItemTipsFrameBkg", "bottom", -143, -4);
			MItemTipsFrameBanBtn:SetPoint("bottom", "MItemTipsFrameBkg", "bottom", 143, -4);
		else
			MItemTipsFrameUnLockBtn:SetPoint("bottom", "MItemTipsFrameBkg", "bottom", 0, -4);
		end
		frameH = frameH + 67;

		if isEducationalVersion then
			MItemTipsFrameUnLockBtn:Hide();
		end		
	end

	--是否显示Alt提示
	if btnName and string.find(btnName, "Pokedex") then
		hasMoreInfo = false;
	elseif (IsInHomeLandMap and IsInHomeLandMap()) then --在家园里面不需要显示alt
			hasMoreInfo = false;
	elseif itemDef.Type == ITEM_TYPE_PACK  then
		hasMoreInfo = true;
	end

	if ClientMgr:isPC() and MItemTipsFrame:GetClientID() == 0 and hasMoreInfo then	--还没按了Alt键	
		getglobal("MItemTipsFrameAltTitle"):Show();
		getglobal("MItemTipsFrameAltTitle"):SetPoint("topleft", "MItemTipsFrame", "topleft", 30, frameH);
		frameH = frameH + 40;
	else
		getglobal("MItemTipsFrameAltTitle"):Hide();
	end
	--物品回收和解锁End
	MItemTipsFrame:SetHeight(frameH);

	if IsLongPressTips then
		SetTipsFramePos(MItemTipsFrame, frameH);
	elseif btnName ~= nil and btnName ~= "" then
		SetTipsFramePosForBtnFrame(MItemTipsFrame);
	else
		MItemTipsFrame:SetPoint("center", "$parent", "center", 0, 0);
	end

	--调整背景高度
	local bodyBkg = getglobal("MItemTipsFrameBodyBkg");
	bodyBkg:SetHeight(frameH - 118);
	if MItemTipsFrameUnLockBtn:IsShown() or MItemTipsFramePlaceBtn:IsShown() or MItemTipsFrameBanBtn:IsShown() then
		bodyBkg:SetHeight(frameH - 179);
	end

	--print("isShowPhysicsPart",isShowPhysicsPart)
	if isShowPhysicsPart and MItemTipsFrame:IsShown() then
		if setPhysicsPartTipsInfo() == true then
			setPhysicsPartTipsPos(MItemTipsFrame,getglobal("PhysicsPartTipsFrame"))

		else
			getglobal("PhysicsPartTipsFrame"):Hide()
		end
		
	else	
		getglobal("PhysicsPartTipsFrame"):Hide()
	end

end

function MItemTipsFrame_OnShow()
	
end

function MItemTipsFrameCloseBtn_OnClick()
	getglobal("MItemTipsFrame"):Hide();
end

--解锁、回收
function MItemTipsFrameUnLockBtn_OnClick()
	if IsStandAloneMode() then return end
	
	local itemId = tipsItemId;
	local itemDef = ItemDefCsv:get(itemId);
	if itemDef == nil then return end

	local btnName = getglobal(this:GetName().."Name"):GetText();

	if string.find(btnName, GetS(3033)) then	-- 解锁
		local hasNum = 0;
		local needNum = itemDef.ChipNum;
		if itemDef.UnlockType == 3 or itemDef.UnlockType == 5 then
			hasNum = AccountManager:getAccountData():getAccountItemNum(itemDef.InvolvedID);
		elseif itemDef.UnlockType == 4 then
			hasNum = AccountManager:getAccountData():getMiniBean();
		end

		print(itemDef.UnlockType);
		local canUnlock = false;
		if hasNum >= needNum then
			canUnlock = true;
		elseif itemDef.UnlockType == 4 then	--迷你豆解锁
			local state = CheckMiniBean(needNum);
			if state == 1 then
				canUnlock = true;
			elseif state > 1 then
				return;
			end
		end
		if itemDef.UnlockType == 3 and not canUnlock then	--仅碎片解锁
			ShowGameTips(GetS(4893), 3);
			return;
		end

		if canUnlock then
			-- 成功解锁后回调
			local function sucUnlockItemCallback()
				getglobal("MItemTipsFrame"):Hide();
				if getglobal("CreateBackpackFrame"):IsShown() then
					UpdateCreateItem2UnLock(itemId);
				elseif getglobal("CraftingTableFrame"):IsShown() then
					CraftingFrame_UpdateAllGrid();
				--elseif getglobal("PokedexFrame"):IsShown() then
				elseif getglobal("Craft"):IsShown() then
					GetInst("UIManager"):GetCtrl("Craft"):RefreshCraftGrid()
				end
				local t_GetItems = {{id=itemDef.ID}};
				SetGameRewardFrameInfo(GetS(4892), t_GetItems, GetS(4891));
				getglobal("MItemTipsFrame"):Hide();
				ClientMgr:playSound2D("sounds/ui/info/book_unlock.ogg", 1);
				--统计图鉴解锁事件
				local tips = "道具";
				if itemDef.UnlockType == 4 then --迷你豆
					tips = "迷你豆";
				end
				StatisticsTools:gameEvent("ItemUnlockEvent", "图鉴解锁", itemDef.Name, "解锁消耗", tips);	

				--成就系统:图鉴解锁(这里去掉, 通过检查的方式上报)
				-- local sum = getUnlockedBookSum();
				-- local _param = {count = sum};
				-- ArchievementGetInstance().func:Report2Server(1013, _param);
				if GetInst("ResourceLibDataManager") and GetInst("ResourceLibDataManager").UpdateNeedUnlockVar then
					GetInst("ResourceLibDataManager"):UpdateNeedUnlockVar(itemDef.ID);
				end
			end

			if IsEnableHomeLand and IsEnableHomeLand() then
				local id = itemId
				local isMiniBean = false
				local itemplace = 1 --老图鉴的东西都在账号服
				local costItemList = {}
				table.insert(costItemList, {sid=0,itemId=itemDef.InvolvedID, num=needNum}) 

				-- 没上报客户端埋点 就清空上一次的log_id 和 scene_id
				resetLogIdAndSceneId()

				GetInst("HomeLandService"):ReqBuildingBagUnlock(id, isMiniBean, itemplace, costItemList, sucUnlockItemCallback)
			else
				if AccountManager:getAccountData():notifyServerUnlockItem(itemDef.InvolvedID, itemDef.ID) == 0 then
					sucUnlockItemCallback()
				end
			end
		else
			if itemDef.UnlockType == 4 then
				ShowGameTips(GetS(385), 3);
				getglobal("BeanConvertFrame"):Show();
			elseif itemDef.UnlockType == 5 then
				local lackNum = 0
				local needItemDef = ItemDefCsv:get(itemDef.InvolvedID);
				local miniPointPrice = MiniPointUnlockPokedex(itemId)
				if miniPointPrice then
					lackNum = (needNum-hasNum)*miniPointPrice;
				
					local lackItemNum = (needNum-hasNum)
					local text = GetS(70831, needItemDef.Name, lackItemNum);
					StoreMsgBox(19, text, GetS(609), itemDef.InvolvedID, lackNum, needNum, itemDef.ReplaceID,function (btn)
						if btn == 'left' then 	--迷你点解锁
							standReportEvent("614", "NOT_ENOUGH_PROPS", "Minipoint_Unlock_Button", "click")
							local miniPoint = AccountManager:getAccountData():getADPoint()
							if lackNum <= miniPoint then
								local function sucUnlockItemCallback()
									getglobal("MItemTipsFrame"):Hide();
									if getglobal("CreateBackpackFrame"):IsShown() then
										UpdateCreateItem2UnLock(itemId);
									elseif getglobal("CraftingTableFrame"):IsShown() then
										CraftingFrame_UpdateAllGrid();
									elseif getglobal("Craft"):IsShown() then
										GetInst("UIManager"):GetCtrl("Craft"):RefreshCraftGrid()
									end
									local t_GetItems = {{id=itemDef.ID}};
									SetGameRewardFrameInfo(GetS(4892), t_GetItems, GetS(4891));
									getglobal("MItemTipsFrame"):Hide();
									ClientMgr:playSound2D("sounds/ui/info/book_unlock.ogg", 1);
									if GetInst("ResourceLibDataManager") and GetInst("ResourceLibDataManager").UpdateNeedUnlockVar then
										GetInst("ResourceLibDataManager"):UpdateNeedUnlockVar(itemDef.ID);
									end
								end
								local isMiniDian = 1
								local itemplace = 1 --老图鉴的东西都在账号服
								local costItemList = {}
								if hasNum > 0 then
									table.insert(costItemList, {sid=0,itemId=itemDef.InvolvedID, num=hasNum})
								end
								table.insert(costItemList, {sid=0,itemId=10009, num=lackNum}) 
				
								-- 没上报客户端埋点 就清空上一次的log_id 和 scene_id
								resetLogIdAndSceneId()
				
								GetInst("HomeLandService"):ReqPokedexUnlock(itemId, isMiniDian, itemplace, costItemList, sucUnlockItemCallback)
							else
								StoreMsgBox(13,GetS(30113),GetS(30123),-6,0,lackNum,nil,function(btn)
									if btn == "right" then
										standReportEvent("614", "NOT_ENOUGH_MINIPOINT", "Ad_Button", "click")
										if not GetInst("UIManager"):GetCtrl("ShopAdvert") then
											GetInst("UIManager"):Open("ShopAdvert")
											GetInst("UIManager"):Hide("ShopAdvert")
										end
										GetInst("UIManager"):GetCtrl("ShopAdvert"):PlayAdBtnClicked(nil, nil,nil,50)
									end
								end)
								local curWatchADType, id = t_ad_data.getWatchADIDAndType(26)
								statisticsGameEventNew(1300, id or "", 50, "", "", "", GetCurrentCSRoomId())
								standReportEvent("614", "NOT_ENOUGH_MINIPOINT", "-", "view")
								standReportEvent("614", "NOT_ENOUGH_MINIPOINT", "Ad_Button", "view")
							end				
						elseif btn == 'right' then 	--迷你豆解锁
							MiniBeanReplaceUnlockItem()
							standReportEvent("614", "NOT_ENOUGH_PROPS", "Minibean_Unlock_Button", "click")
						end
					end);
					getglobal("PokedexSeriesBox"):setDealMsg(false)
					standReportEvent("614", "NOT_ENOUGH_PROPS", "Minibean_Unlock_Button", "view")
					standReportEvent("614", "NOT_ENOUGH_PROPS", "Minipoint_Unlock_Button", "view")
				else
					lackNum = (needNum-hasNum)*itemDef.ChipPrice;		
					local replaceDef = ItemDefCsv:get(itemDef.ReplaceID);
					if replaceDef ~= nil then
						local lackItemNum = (needNum-hasNum);
						local text = GetS(670, needItemDef.Name, lackItemNum, replaceDef.Name);
						StoreMsgBox(7, text, GetS(609), itemDef.InvolvedID, lackNum, needNum, itemDef.ReplaceID);
						getglobal("StoreMsgboxFrame"):SetClientString( "道具不足解锁方块" );
						local str = itemDef.ID;
						--SetStatisticRechargeSrc(4800,str);
						getglobal("PokedexSeriesBox"):setDealMsg(false);
						standReportEvent("614", "NOT_ENOUGH_PROPS", "Minibean_Unlock_Button", "view")
					end
				end
				standReportEvent("614", "NOT_ENOUGH_PROPS", "-", "view")
			end
		end
		if getglobal("MItemTipsFrame"):IsShown() then
			getglobal("MItemTipsFrame"):Hide();			
		end
	elseif string.find(btnName, GetS(669)) then	--回收
		local recycleDef = DefMgr:getRecycleDef(itemDef.InvolvedID);
		if recycleDef == nil then return end

		local hasNum = AccountManager:getAccountData():getAccountItemNum(recycleDef.ID);
		if AccountManager:getAccountData():notifyServerOpItemReclaim(recycleDef.ID, hasNum) == 0 then
			local hasExp = false;
			for i=1, Max_Recycle_Get do
				local GetItemDef = ItemDefCsv:get(recycleDef.GetID[i-1]);
				if GetItemDef ~= nil then
					local num = recycleDef.GetNum[i-1] * hasNum;
					ShowGameTips(GetS(3800, GetItemDef.Name, num), 3);
					
					if recycleDef.GetID[i-1] == 10001 then	
						hasExp = true;
					end
				end
			end

			getglobal("MItemTipsFrame"):Hide();
			if hasExp and getglobal("HomeChestFrame"):IsShown() then
				if getglobal("HomeChestFrameFriendRoleInfo"):IsShown() then
					press_btn("HomeChestFrameBackBtn");	--如果在好友界面, 则先退出, 相当于:HomeChestFrameBackBtn_OnClick();
				end

				HomeChestMgr:requestChestTreeReq(AccountManager:getUin());
			end
		else
			--ShowGameTips(GetS(282));
		end
	elseif string.find(btnName, GetS(4756)) then	--包裹详情
		ShowGiftPackFrame(0,itemDef.ID);
		getglobal("MItemTipsFrame"):Hide();
	end
end

--迷你点解锁图鉴
function MiniPointUnlockPokedex(itemid)
	if manor_config.unlock_item and manor_config.unlock_item.id and check_apiid_ver_conditions(manor_config.unlock_item) then
		for key, value in pairs(manor_config.unlock_item.id) do
			if key == itemid then
				return value.num
			end
		end
	end
	return nil
end

--迷你豆代替道具解锁
function MiniBeanReplaceUnlockItem()
	local itemId = tipsItemId;--getglobal("MItemTipsFrameUnLockBtn"):GetClientUserData(0);
	local itemDef = ItemDefCsv:get(itemId);
	if itemDef == nil then return end

	local needNum = itemDef.ChipNum;
	local hasNum = AccountManager:getAccountData():getAccountItemNum(itemDef.InvolvedID);
	local lackNum = (needNum-hasNum)*itemDef.ChipPrice;

	local hasReplace = AccountManager:getAccountData():getAccountItemNum(itemDef.ReplaceID);
	if itemDef.ReplaceID == 10000 then
		hasReplace = AccountManager:getAccountData():getMiniBean();
	end

	local canUnlock = false;
	if hasReplace >= lackNum then
		canUnlock = true;
	elseif itemDef.ReplaceID == 10000 then
		local state = CheckMiniBean(lackNum);
		if state == 1 then
			canUnlock = true;
		elseif state > 1 then
			return;
		end
	end

	if canUnlock then
		local function sucUnlockItemCallback()
			local context = SandboxContext():SetData_Number("result", 1)
			SandboxLua.eventDispatcher:Emit(nil, GameEventType.RefreshCraftView,context)
			if getglobal("CreateBackpackFrame"):IsShown() then
				UpdateCreateItem2UnLock(itemId);
			elseif getglobal("CraftingTableFrame"):IsShown() then
				CraftingFrame_UpdateAllGrid();
			--elseif getglobal("PokedexFrame"):IsShown() then
			elseif getglobal("Craft"):IsShown() then
				GetInst("UIManager"):GetCtrl("Craft"):RefreshCraftGrid()
			end
			local t_GetItems = {{id=itemDef.ID}};
			SetGameRewardFrameInfo(GetS(4892), t_GetItems, GetS(4891));
			if getglobal("MItemTipsFrame"):IsShown() then
				getglobal("MItemTipsFrame"):Hide();
			end
			ClientMgr:playSound2D("sounds/ui/info/book_unlock.ogg", 1);
			--统计图鉴解锁事件
			StatisticsTools:gameEvent("ItemUnlockEvent", "图鉴解锁", itemDef.Name, "解锁消耗", "道具加迷你豆");

			--成就系统:图鉴解锁
			-- local sum = getUnlockedBookSum();
			-- local _param = {count = sum};
			-- ArchievementGetInstance().func:Report2Server(1013, _param);
			if GetInst("ResourceLibDataManager") and GetInst("ResourceLibDataManager").UpdateNeedUnlockVar then
				GetInst("ResourceLibDataManager"):UpdateNeedUnlockVar(itemDef.ID);
			end
			--刷新侧边栏资源item
			if GetInst("MiniUIManager") and GetInst("SceneEditorMsgHandler") and GetInst("MiniUIManager"):IsShown("ResourceSidebar") then
				OnChangeResourceData()
				GetInst("SceneEditorMsgHandler"):dispatcher(SceneEditorUIDef.common.update_sidebar_item)
			end
			--刷新资源背包item
			if GetInst("MiniUIManager") and GetInst("SceneEditorMsgHandler") and GetInst("MiniUIManager"):IsShown("ResourceBagMain") then
				OnChangeResourceData()
				GetInst("SceneEditorMsgHandler"):dispatcher(SceneEditorUIDef.common.update_resource_bag_item)
			end
		end

		if IsEnableHomeLand and IsEnableHomeLand() then
			local id = itemId
			local isMiniBean = true
			local itemplace = 1 --老图鉴的东西都在账号服
			local costItemList = {}
			if hasNum > 0 then
				table.insert(costItemList, {sid=0,itemId=itemDef.InvolvedID, num=hasNum})
			end

			table.insert(costItemList, {sid=0,itemId=itemDef.ReplaceID, num=lackNum})

			-- 没上报客户端埋点 就清空上一次的log_id 和 scene_id
			resetLogIdAndSceneId()
			GetInst("HomeLandService"):ReqBuildingBagUnlock(id, isMiniBean, itemplace, costItemList, sucUnlockItemCallback)
		else
			if AccountManager:getAccountData():notifyServerUnlockItem(itemDef.InvolvedID, itemDef.ID) == 0 then
				sucUnlockItemCallback()
			else
				--ShowGameTips(StringDefCsv:get(282), 3);
			end
		end
	else
		local replaceDef = ItemDefCsv:get(itemDef.ReplaceID);
		local text = GetS(703);
		if replaceDef ~= nil then
			text = string.gsub(GetS(702), "@ItemName", replaceDef.Name);
		end
		ShowGameTips(text, 3);
		if itemDef.ReplaceID == 10000 then --迷你豆
			getglobal("BeanConvertFrame"):Show();
		end
	end
end

--解禁、禁用物品
function MItemTipsFrameBanBtn_OnClick()
	local itemId = tipsItemId;--getglobal("MItemTipsFrameUnLockBtn"):GetClientUserData(0);
	BanItem(itemId);
	getglobal("MItemTipsFrame"):Hide();
end

--放置、装备
function MItemTipsFramePlaceBtn_OnClick()
	if tipsGridIndex == -1 then return end

	local btnName = getglobal("MItemTipsFrame"):GetClientString();
	local placeResult = false;

	if string.find(btnName, "Enchant") then			--附魔物品放置
		EnchantItemPlace(btnName, tipsGridIndex);
	elseif string.find(btnName, "StorageLeftBox") then	--箱子左边格子放置
		StorageLeftBoxPlace(tipsGridIndex);
	elseif string.find(btnName, "StorageRightBox") then	--箱子右边格子放置
		StorageRightBoxPlace(tipsGridIndex);
	elseif string.find(btnName, "RoleFrameBackpackGrid") or string.find(btnName, "RoleFrameShortcutGrid") then	--背包栏
		WearEquip2Grid(tipsGridIndex);
	elseif string.find(btnName, "RoleFrameEquipGrid") then	--脱下装备
		DeEquip2Grid(tipsGridIndex);	
	elseif string.find(btnName, "ToolShortcut") then	--快捷栏
		if getglobal("StorageBoxFrame"):IsShown() then
			ToolShortcutPlace(tipsGridIndex);
		else
			--[[
			if tipsItemId > 0 then
				local itemDef = ItemDefCsv:get(tipsItemId);
				if itemDef ~= nil and itemDef.UseTarget == 10 then
					AccountItemUse(tipsGridIndex, tipsItemId, CurMainPlayer);
				end
			end
			]]
		end	
	elseif string.find(btnName, "EquipBoxItem") then 	--装备面板的装备列表
		EquipBoxItemPlace(tipsGridIndex);
	elseif  string.find(btnName, "RoleFrameEquip") then	--装备栏
		RoleFrameEquipPlace(tipsGridIndex);
	elseif string.find(btnName, "EquipRideBoxItem") then	--坐骑面板的装备列表
		EquipRideBoxItemPlace(tipsGridIndex);
	elseif string.find(btnName, "RideFrameCurEquip") then	--坐骑装备栏
		RideFrameEquipPlace(tipsGridIndex);
	elseif string.find(btnName, "PackFrameItem") then
		--[[
		if tipsItemId > 0 then
			local itemDef = ItemDefCsv:get(tipsItemId);
			if itemDef ~= nil and itemDef.UseTarget == 10 then
				AccountItemUse(tipsGridIndex, tipsItemId, CurMainPlayer);
			end
		end
		]]
	elseif string.find(btnName,"OldUITipsHackItem") then -- 新UI做的改进功能
		local inttype = getglobal("MItemTipsFrame"):GetClientUserData(0)
		if inttype == 1 then--快捷栏 "ToolShortcut"
			if getglobal("StorageBoxFrame"):IsShown() then
				ToolShortcutPlace(tipsGridIndex);
			end
		end
	end

	getglobal("MItemTipsFrame"):Hide();
	getglobal("TipsBkgFrame"):Hide();	
end

function MItemTipsFrame_OnClick()
	local btnName = getglobal("MItemTipsFrame"):GetClientString();

	if btnName ~= nil then
		if string.find(btnName, "Enchant") then
			HideEnchantAllBoxTexture();
		elseif string.find(btnName, "Storage") then
			SetStorageBoxTexture(nil);
		elseif string.find(btnName, "ToolShortcut") and getglobal("StorageBoxFrame"):IsShown() then
			SetToolShortcutTexture(nil);
		elseif string.find(btnName, "Equip") then
			SetRoleFrameBoxTexture(nil);
		elseif string.find(btnName,"OldUITipsHackItem") then -- 新UI做的改进功能
			local inttype = getglobal("MItemTipsFrame"):GetClientUserData(0)
			if inttype == 1 then--快捷栏 "ToolShortcut"
				if getglobal("StorageBoxFrame"):IsShown() then
					SetToolShortcutTexture(nil);--TODO：这里是否新快捷栏也要同步操作
				end
			end
		end
	end
	getglobal("MItemTipsFrame"):Hide();
end

function MItemTipsFrame_OnHide()
	-- tipsItemId = nil--鼠标点击物品详情解锁按钮会弹出对话框，此时鼠标移动到其他地方时置空这个id会导致获取物品id的地方报错，所以此处改为不置空。
	tipsGridIndex = -1;
	getglobal("MItemTipsFrame"):SetClientUserData(0, 0);
	getglobal("MItemTipsFrame"):SetClientString("");
	getglobal("MItemTipsFrame"):SetClientID(0);

	if getglobal("TipsBkgFrame"):IsShown() then
		getglobal("TipsBkgFrame"):Hide();
	end

	if ClientCurGame:isInGame() and CurWorld:getOWID() == NewbieWorldId then
		local taskId = AccountManager:getCurNoviceGuideTask();
		if taskId == 23 then
			AccountManager:setNoviceGuideState("wearEP3", false);
			AccountManager:setCurNoviceGuideTask(22);
			ShowCurNoviceGuideTask();
		end
	end

	if not this:IsRehide() then
		getglobal("PhysicsPartTipsFrame"):Hide()
	end
end

function TipsBkgFrame_OnClick()
	if getglobal("MItemTipsFrame"):IsShown() then		
		getglobal("MItemTipsFrame"):Hide();	
	end
end
------------------------------------------------------------AchievementFinishTipsFrame--------------------------------------------------
local AchievementFinishDefTime = 5
local AchievementFinishTipsShowTime = AchievementFinishDefTime; -- - 提示窗口悬停显示时间改为5s
local TipsAchiType = 0;
function UpdateAchievementFinishTips(achiId)
	local achievementDef = AchievementMgr:getAchievementDef(achiId);
	if achievementDef ~= nil then
		local num = achievementDef.GoalNum;
		local arryNum = AchievementMgr:getAchievementArryNum(CurMainPlayer:getObjId(), achiId);
		if AchievementMgr:getAchievementState(CurMainPlayer:getObjId(), achiId) ==  ACTIVATE_UNCOMPLETE and arryNum >= num then
			local AchievementFinishTipsFrame = getglobal("AchievementFinishTipsFrame")
			AchievementFinishTipsFrame:SetPoint("bottom", "$parent", "top", 0, 0);
			AchievementFinishTipsShowTime = AchievementFinishDefTime;
			if achievementDef.Type == 1 then
				TipsAchiType = 1;
			else
				TipsAchiType = 0;
			end

			ClientMgr:playSound2D("sounds/ui/info/achievement_reach.ogg", 1);
			AchievementFinishTipsFrame:Show();
			getglobal("AchievementFinishTipsFrame"):SetClientID(achiId);
			local icon =  getglobal("AchievementFinishTipsFrameIcon");
			SetItemIcon(icon, achievementDef.IconID);
			getglobal("AchievementFinishTipsFrameName"):SetText(achievementDef.Name);
			if achievementDef.RewardDistributionType == 1 then
				getglobal("AchievementFinishTipsFrameRewardTips"):SetText(GetS(90008))
			else
				getglobal("AchievementFinishTipsFrameRewardTips"):SetText(GetS(90007))
			end
		end
	end
end

function AchievementFinishTipsFrame_OnLoad()
	this:setUpdateTime(0.05);
end

function AchievementFinishTipsFrame_OnShow()
	curOffset = 0;
end

function AchievementFinishTipsFrame_OnHide()
	getglobal("AchievementFinishTipsFrame"):SetPoint("bottom", "$parent", "top", 0, 0);
end

function AchievementFinishTipsFrame_OnClick()
	local AchievementFrame = getglobal("AchievementFrame")
	if not AchievementFrame:IsShown() then
		AchievementFrameType = TipsAchiType;
		AchievementFrame:Show();
		local id = getglobal("AchievementFinishTipsFrame"):GetClientID();
		ShowAchievementById(id);
	end
end

local changeOffset = 20;
local curOffset = 0;

function AchievementFinishTipsFrame_OnUpdate()
	AchievementFinishTipsShowTime = AchievementFinishTipsShowTime - arg1;

	local AchievementFinishTipsFrame = getglobal("AchievementFinishTipsFrame")
	if not CurWorld then
		AchievementFinishTipsFrame:Hide();
		return;
	end

	if AchievementFinishTipsShowTime < 0 then
		if CurWorld:getOWID() == NewbieWorldId and AccountManager:getCurNoviceGuideTask() == 9 then
			return;
		end
		curOffset = curOffset - changeOffset;
		if curOffset < 0 then				
			AchievementFinishTipsFrame:Hide();
		end		
	else
		curOffset = curOffset + changeOffset;
		if curOffset > 150 then
			curOffset = 150;
		end
	end

	AchievementFinishTipsFrame:SetPoint("bottom", "$parent", "top", 0, curOffset);
end
--------------------------------------------------------GameTipsFrame---------------------------------------------------
t_gametip = {};
--type 1√ 2× 3无 4☆ 5物品图标
function ShowGameTips(text, type, itemId, num, bNoLimit,withoutFilter)
	if text == nil or text == "" then return end

	--[[游客模式下限制使用迷你币 由于使用迷你币入口太多
	特殊处理下 限制改成服务端处理 游客模式下 返回PRECHECK_MINICOIN_NOT_ENOUGH为被限制
	提示要改成 22011
	]]
	if AccountGameModeClass:IsVisitorMode() and text == GetS(456) then
		text = GetS(22011)
	end

	--for minicode
	if isEducationalVersion and IsTipTextForbiddenByEdu(text) then
		return 
	end

	if not withoutFilter then 
		text = DefMgr:filterString(text);
	end

	if type == nil then type = 3; end	--没有类型的，默认用3
	if not getglobal("GameTipsFrame"):IsShown() then
		getglobal("GameTipsFrame"):Show();
	end
	if not bNoLimit then --当bNoLimit为true时，解除限制
		if #(t_gametip) >= 3 then	--tips缓存不超过3条
			table.remove(t_gametip, 1);
		end
	end
	table.insert(t_gametip, {Text = text, Type = type, ItemId = itemId, Num = 0});
end

function ShowGameTipsWithoutFilter(text, type, itemId, num, bNoLimit)
	ShowGameTips(text, type, itemId, num, bNoLimit,true)
end

function ShowGameTipsStrID(strid)
	ShowGameTips(GetS(strid))
end

--图鉴没解锁提示
--hasUnlockInfo --是否已经从家园服务器拉到了解锁数据了
function ShowItemUnLockTips(hasUnlockInfo)
	local stringId = 390
	if not hasUnlockInfo then
		stringId = 3252 --正在尝试连接网络，请稍后再试(zh)
	end
	
	ShowGameTips(GetS(stringId), 3)
end

function GameTipsFrame_OnLoad()
	this:setUpdateTime(0.05);

	for i=1, 3 do
		local tips = getglobal("GameTipsFrameTips"..i);
		tips:SetPoint("top", "GameTipsFrame", "top", 0, 0);
	end
end

function GameTipsFrame_OnShow()
	
end

function GameTipsFrame_OnHide()
	t_gametip = {};
end

function GameTipsFrame_OnUpdate()
	if t_gametip[1] ~= nil then
		local tips = GetNullTipsFrame();
		if tips ~= nil then
			tips:Show();
			local text	= getglobal(tips:GetName().."Text");
			local bkg	= getglobal(tips:GetName().."Bkg");
			local tick  	= getglobal(tips:GetName().."Tick");
			local cross 	= getglobal(tips:GetName().."Cross");
			local star 	= getglobal(tips:GetName().."Star");
			local icon 	= getglobal(tips:GetName().."Icon");
			
			--数量
			local tipsText = t_gametip[1].Text;
			if t_gametip[1].Num > 0 then
				tipsText = t_gametip[1].Text.."×"..t_gametip[1].Num;
			end
			--背景板大小
			local scale = UIFrameMgr:GetScreenScale();
			bkg:SetSize(text:GetTextExtentWidth(tipsText)/scale+80, 49);
			--文字相关
			if t_gametip[1].Type == 3 or t_gametip[1].Type == nil then
				text:SetPoint("center", bkg:GetName(), "center", 0, 1);
			else
				text:SetPoint("left", bkg:GetName(), "left", 50, 1);
			end
			text:SetSize(text:GetTextExtentWidth(tipsText)/scale+30, 35);
			text:SetText(tipsText);
			
			--图标相关
			local offsetX = (text:GetWidth() - text:GetTextExtentWidth(tipsText)/scale)/2 - 10;
			if t_gametip[1].Type == 1 then
				tick:SetPoint("right", text:GetName(), "left", offsetX, -3);
				tick:Show();
				cross:Hide();
				star:Hide();
				icon:Hide();
			elseif t_gametip[1].Type == 2 then
				cross:SetPoint("right", text:GetName(), "left", offsetX, -3);				
				tick:Hide();
				star:Hide();
				cross:Show();
				icon:Hide();
			elseif t_gametip[1].Type == 3 then
				tick:Hide();
				cross:Hide();
				star:Hide();
				icon:Hide();
			elseif t_gametip[1].Type == 4 then
				star:SetPoint("right", text:GetName(), "left", offsetX, -3);
				star:Show();				
				tick:Hide();
				cross:Hide();
				icon:Hide();
			elseif t_gametip[1].Type == 5 then
				icon:SetPoint("right", text:GetName(), "left", offsetX, -3);
				if t_gametip[1].ItemId ~= nil then
					SetItemIcon(icon, t_gametip[1].ItemId);
				end
				icon:Show();				
				tick:Hide();
				cross:Hide();
				star:Hide();
			end

			table.remove(t_gametip, 1);
		end
	elseif not IsHasShowTipsFrame() then
		getglobal("GameTipsFrame"):Hide();
	end
end

function IsHasShowTipsFrame()
	for i=1, 3 do
		local tips = getglobal("GameTipsFrameTips"..i);
		if tips:IsShown() then
			return true;
		end
	end
	return false;
end

function GetNullTipsFrame()
	for i=1, 3 do
		local tips = getglobal("GameTipsFrameTips"..i);
		if not tips:IsShown() then
			if not IsHasShowTipsFrame() then
				return tips;
			else
				local fontIndex = i-1;
				if fontIndex == 0 then
					fontIndex = 3;
				end
				local frontTips = getglobal("GameTipsFrameTips"..fontIndex);
				local intervalY = tips:GetRealTop() - frontTips:GetRealTop();
			
				if intervalY > 45 then
					return tips;
				end
			end
		end
	end
	return nil;
end

function GameTipsTemplate_OnLoad()
	this:setUpdateTime(0.04);
end

local t_alpha = {1.0, 1.0, 1.0};
local t_offsetY = {0, 0, 0};
local t_time	= {0.4, 0.4, 0.4};	--tips显示的时间	
function GameTipsTemplate_OnUpdate()
	local index = this:GetClientID();
	t_time[index] = t_time[index] - arg1;

	if t_time[index] < 0 then
		t_alpha[index] = t_alpha[index] - 0.04;
		t_offsetY[index] = t_offsetY[index] - 6;

		this:SetPoint("top", "GameTipsFrame", "top", 0, t_offsetY[index])
		local bkg = getglobal(this:GetName().."Bkg");
		local text = getglobal(this:GetName().."Text");
		local tick = getglobal(this:GetName().."Tick");
		local cross = getglobal(this:GetName().."Cross");
		
		if t_alpha[index] < 0 then
			t_alpha[index] = 1.0;
			t_offsetY[index] = 0
			bkg:SetBlendAlpha(1.0);
			text:SetBlendAlpha(1.0);
			tick:SetBlendAlpha(1.0);
			cross:SetBlendAlpha(1.0);
			this:SetPoint("top", "GameTipsFrame", "top", 0, 0)
			t_time[index] = 0.4;
			this:Hide();
		else
			bkg:SetBlendAlpha(t_alpha[index]);
			text:SetBlendAlpha(t_alpha[index]);
			if tick:IsShown() then
				tick:SetBlendAlpha(t_alpha[index]);
			end
			if cross:IsShown() then
				cross:SetBlendAlpha(t_alpha[index]);
			end
		end
	end
end

function ClearGameTips()
	for i=1, 3 do
		local tips = getglobal("GameTipsFrameTips"..i);
		tips:SetPoint("top", "GameTipsFrame", "top", 0, 0);
		if tips:IsShown() then
			local bkg	= getglobal(tips:GetName().."Bkg");
			local text	= getglobal(tips:GetName().."Text");
			local tick  = getglobal(tips:GetName().."Tick");
			local cross = getglobal(tips:GetName().."Cross");
			bkg:SetBlendAlpha(1.0);
			text:SetBlendAlpha(1.0);
			tick:SetBlendAlpha(1.0);
			cross:SetBlendAlpha(1.0);
			t_alpha = {1.0, 1.0, 1.0};
			t_offsetY = {0, 0, 0};
			t_time	= {0.4, 0.4, 0.4};
			tips:Hide();
		end
	end
	t_gametip = {}
end

-----------------------------GamePopUpsFrame--------------------------------------
--[[===========================================新埋点=============================================]]
--mark by liya for GamePopUpsFrame
--新版埋点, view 统一处理
local GamePopUpsFrame_StandReportEventTable = {
	MINI_POPUP_FRIENDSINVITE_1  = {
        Accept  = "GamePopUpsFrameOkBtn",
        Reject  = "GamePopUpsFrameCancelBtn",
        NoShow  = "GamePopUpsFrameHookBtn",
    },
}
--统一埋点view
function GamePopUpsFrame_StandReportViewEvent()
    local event = "view"
    local cid = nil
    GamePopUpsFrame_StandReportSingleEvent("MINI_POPUP_FRIENDSINVITE_1", "-", event)
    
	for cID, oTable in pairs(GamePopUpsFrame_StandReportEventTable) do
		for oID, frameName in pairs(oTable) do
            if IsUIFrameShown(frameName) then
                if frameName == "GamePopUpsFrameOkBtn" then
                    cid = "0"
                    local msgInfo = g_PopUpsData.msg[g_PopUpsData.curIndex];
                    if msgInfo then
                        if msgInfo.type == 'InviteJoinRoom' then
                            local data 		= msgInfo.data
                            local worldID   = data.WorldID or 0
                            cid             = tostring(worldID)
                        end
                    end
                end
                if cid then
                    GamePopUpsFrame_StandReportSingleEvent(cID, oID, event, {cid = cid})
                else
                    GamePopUpsFrame_StandReportSingleEvent(cID, oID, event)
                end
			end
		end
	end
end

--上报单个地图详情界面埋点
function GamePopUpsFrame_StandReportSingleEvent(cID, oID, event, eventTb)
	local sID = "28"
	standReportEvent(sID, cID, oID, event, eventTb)
end
--[[===========================================新埋点=============================================]]

_G.g_PopUpsData = {
	curOffsetY = 0,
	showTime = 12,
	curIndex = 0,
	msg = {},
	notNotify_startTime = 0,	--五分钟内不再提醒的起始时间
}

function CheckIngorExtendMsg(extend_data)
	-- if extend_data then
	-- 	local url_decode_jsonStr = ns_http.func.url_decode(extend_data);
	-- 	local base64_decode_jsonStr = ns_http.func.base64_decode(url_decode_jsonStr);
	-- 	local t_extend = JSON:decode(base64_decode_jsonStr);	
	-- 	if t_extend and (t_extend.Type == 'InviteJoinRoom' or t_extend.Type == "InviteJoinRoomA") then --是邀请加入消息
	-- 		local data 		= t_extend;
	-- 		local uin 		= data.RoomUin;
	-- 		local room_id 	= data.RoomId or -1
	-- 		local worldID   = data.WorldID or 1
	-- 		local pwd = data.Password

	-- 		local homeWorldId = gFunc_GetHomeGardenWorldIDByUin(uin or 0)
	-- 		local idpw = safe_string2table(pwd)
	-- 		if homeWorldId ~= worldID and not idpw.actk then
	-- 			if G_CheckABTestSwitchOfAllCloud() then
	-- 				if not RentPermitCtrl:CheckIsRentRoomInvite(uin, room_id) then
	-- 					return true
	-- 				end
	-- 			elseif G_CheckABTestSwitchOfAllCloudCompare() then
	-- 				if 2 == RentPermitCtrl:CheckIsRentRoomInvite(uin, room_id) then
	-- 					return true
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end

	return false
end

--判定是否来自于迷你基地群云服的游戏内邀请格式
function checkGroupRentInviteFormat(t_extend)
    if t_extend then
        local proto = {
            src_user_version = 2,
            tipMsg = "",
            Standby1 = 0,
        }
        if t_extend.src_user_version ~= proto.src_user_version then return false end
        for k,v in pairs(proto) do
            if type(v) ~= type(t_extend[k]) then return false end
        end
        for k,v in pairs(t_extend) do
            if type(v) ~= type(proto[k]) then return false end
        end
        return true
    end
    return false
end

function ParseExtendMsg(msgData)
	if ClientMgr:getGameData("popups") == 0 then return end

	--五分钟内不再提醒
	print("g_PopUpsData.notNotify_startTime:", g_PopUpsData.notNotify_startTime);
	if g_PopUpsData.notNotify_startTime > 0 and (os.time() - g_PopUpsData.notNotify_startTime) < 5 * 60 then
		print("设置了5分钟内不再提醒:");
		print(os.time() - g_PopUpsData.notNotify_startTime);
		return;
	end

	print("kekeke ParseExtendMsg", msgData);
	local url_decode_jsonStr = ns_http.func.url_decode(msgData.extend_data);
	local base64_decode_jsonStr = ns_http.func.base64_decode(url_decode_jsonStr);
	local t_extend = JSON:decode(base64_decode_jsonStr);

	local isGroupRentInvite = checkGroupRentInviteFormat(t_extend)
	if t_extend and (t_extend.Type == 'InviteJoinRoom' or t_extend.Type == "InviteJoinRoomA" or isGroupRentInvite) then --是邀请加入消息
		if ClientCurGame:isInGame() and CurWorld:isGameMakerMode() then -- 游戏内且开发者模式屏蔽弹窗
			return
		end
		
		local inviterNmae = DefMgr:filterString(t_extend.InviterName);
		t_extend.InviterName = inviterNmae;

		if #(g_PopUpsData.msg) < 3 then
			t_extend.uin = msgData.uin;
			print("kekeke t_extend", t_extend);
			if isGroupRentInvite then
				table.insert(g_PopUpsData.msg, {type="GroupRentInvite", data=t_extend, send_time = msgData.time});
			else
				table.insert(g_PopUpsData.msg, {type="InviteJoinRoom", data=t_extend, send_time = msgData.time});
			end
			if not ClientCurGame:isInGame() and not getglobal("GamePopUpsFrame"):IsShown() then
				g_PopUpsData.curIndex = 1;
				UpdateGamePopUpsFrame();
			end

			local kv = getkv("in_game_invite_notice") or 0
			if IsSameDay(kv, os.time()) then
				return
			end
			if ClientCurGame:isInGame() then
				GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common_comp", "miniui/miniworld/common", "iniui/miniworld/userInfoInteract"})
				GetInst("MiniUIManager"):OpenUI("main_invite", "miniui/miniworld/userInfoInteract", "main_inviteAutoGen", {disableOperateUI=true})
			end
		end
	end
end

function CliearGamePopUps()
	g_PopUpsData.msg = {};
	g_PopUpsData.curIndex = 0;
	g_PopUpsData.showTime = 12;
	g_PopUpsData.curOffsetY = 0;
	if getglobal("GamePopUpsFrame"):IsShown() then
		getglobal("GamePopUpsFrame"):Hide();
	end
end

function UpdateGamePopUpsFrame()
	--设置界面邀请弹框开关
	if ClientMgr:getGameData("popups") == 0 then 
		return 
	end

	g_PopUpsData.curOffsetY = 0;
	g_PopUpsData.showTime = 12;
	getglobal("GamePopUpsFrame"):SetPoint("bottom", "$parent", "top", 0, 0);

	local msgInfo = g_PopUpsData.msg[g_PopUpsData.curIndex];
	print(" UpdateGamePopUpsFrame ", msgInfo)
	if msgInfo then
		if msgInfo.type == 'InviteJoinRoom' then

			getglobal("GamePopUpsFrameIcon"):Show()
			getglobal("GamePopUpsFrameNum"):Show()
			getglobal("GamePopUpsFrameContent"):Show()
			getglobal("GamePopUpsFrameCancelBtn"):Show()
			getglobal("GamePopUpsFrameOkBtn"):Show()
			getglobal("GamePopUpsFrameHookBtn"):Show()
			getglobal("GamePopUpsFrameTipMsg"):Hide()
			getglobal("GamePopUpsFrameCheckBtn"):Hide()

			local data = msgInfo.data;

			local headName = "GamePopUpsFrameHead";

			local fridData = GetFriendDataByUin(data.uin, true);
			
			if fridData then
				HeadCtrl:SetPlayerHeadByUin(headName,fridData.uin,fridData.headmodel,fridData.headskin);
				--头像和头像框
				if fridData.headurl and fridData.headurl ~= "" then
					HeadCtrl:SetPlayerHead(headName,1,fridData.headurl);
				else
					HeadCtrl:SetPlayerHeadByUin(headName,fridData.uin,fridData.headmodel,fridData.headskin,fridData.HasAvatar);
				end
                HeadFrameCtrl:SetPlayerheadFrameName("GamePopUpsFrameHeadFrame",fridData.headframe);
				--print("kekeke headframe", fridData.headframe);
				if fridData.headframe and fridData.headframe > 0 then
					changeHeadFrameTxtPic(fridData.headframe, "GamePopUpsFrameHeadBkg");
				else
					changeHeadFrameTxtPic(1, "GamePopUpsFrameHeadBkg");
				end

				--title
				local friendName = DefMgr:filterString(fridData.name);
				getglobal("GamePopUpsFrameTitle"):SetText(friendName);

				--content 
				getglobal("GamePopUpsFrameContent"):SetText(GetS(1323, data.RoomName));

				--人数
				getglobal("GamePopUpsFrameNum"):SetText( GetS(1324, data.PlayerNum, data.PlayerMaxNum) );
			else
				HeadCtrl:SetPlayerHead(headName,2,2);

				getglobal("GamePopUpsFrameTitle"):SetText(data.InviterName);
				getglobal("GamePopUpsFrameContent"):SetText(GetS(1323, data.RoomName));
				getglobal("GamePopUpsFrameNum"):SetText( GetS(1324, data.PlayerNum, data.PlayerMaxNum) );
			end

		elseif msgInfo.type == 'GroupRentInvite' then
			getglobal("GamePopUpsFrameIcon"):Hide()
			getglobal("GamePopUpsFrameNum"):Hide()
			getglobal("GamePopUpsFrameContent"):Hide()
			getglobal("GamePopUpsFrameCancelBtn"):Hide()
			getglobal("GamePopUpsFrameOkBtn"):Hide()
			getglobal("GamePopUpsFrameHookBtn"):Hide()
			getglobal("GamePopUpsFrameTipMsg"):Show()
			getglobal("GamePopUpsFrameCheckBtn"):Show()

			local data = msgInfo.data;
			local headName = "GamePopUpsFrameHead";
			local fridData = GetFriendDataByUin(data.uin, true);

			if fridData then
				HeadCtrl:SetPlayerHeadByUin(headName,fridData.uin,fridData.headmodel,fridData.headskin);
				--头像和头像框
				if fridData.headurl and fridData.headurl ~= "" then
					HeadCtrl:SetPlayerHead(headName,1,fridData.headurl);
				else
					HeadCtrl:SetPlayerHeadByUin(headName,fridData.uin,fridData.headmodel,fridData.headskin,fridData.HasAvatar);
				end
                HeadFrameCtrl:SetPlayerheadFrameName("GamePopUpsFrameHeadFrame",fridData.headframe);
				--print("kekeke headframe", fridData.headframe);
				if fridData.headframe and fridData.headframe > 0 then
					changeHeadFrameTxtPic(fridData.headframe, "GamePopUpsFrameHeadBkg");
				else
					changeHeadFrameTxtPic(1, "GamePopUpsFrameHeadBkg");
				end

				--title
				local friendName = DefMgr:filterString(fridData.name);
				getglobal("GamePopUpsFrameTitle"):SetText(friendName);

				--tipMsg
				getglobal("GamePopUpsFrameTipMsg"):SetText(tostring(msgInfo.data.tipMsg or ""));
			else
				getglobal("GamePopUpsFrameHead"):SetTexture("items/hand.png");
				changeHeadFrameTxtPic(1, "GamePopUpsFrameHeadBkg");
				getglobal("GamePopUpsFrameTitle"):SetText("");
				getglobal("GamePopUpsFrameTipMsg"):SetText("");
			end
		end
	end

	if not getglobal("GamePopUpsFrame"):IsShown() then
		getglobal("GamePopUpsFrameHookBtnTick"):Hide();
        getglobal("GamePopUpsFrame"):Show();
        GamePopUpsFrame_StandReportViewEvent()
	end
end

function GamePopUpsFrame_OnLoad()
	this:setUpdateTime(0.05);
end

function GamePopUpsFrame_OnUpdate()
	local maxOffsetY = 200;
	if g_PopUpsData.curOffsetY < maxOffsetY then
		g_PopUpsData.curOffsetY = g_PopUpsData.curOffsetY + 20;
		g_PopUpsData.curOffsetY = g_PopUpsData.curOffsetY > maxOffsetY and maxOffsetY or g_PopUpsData.curOffsetY;

		getglobal("GamePopUpsFrame"):SetPoint("bottom", "$parent", "top", 0, g_PopUpsData.curOffsetY);
	end


	g_PopUpsData.showTime = g_PopUpsData.showTime - arg1;
	if g_PopUpsData.showTime < 0 then
		NextPopUps();
	end
end

function GamePopUpsFrameCancelBtn_OnClick()
	local isHomeLandInviteJoinRoom = false
	local msgInfo = g_PopUpsData.msg[g_PopUpsData.curIndex];
	if msgInfo then
		if msgInfo.type == 'InviteJoinRoom' then
			local data 		= msgInfo.data;

			local showType = friendservice.MSG_SHOW_TYPE and friendservice.MSG_SHOW_TYPE.except_self or 1;
			ReqSendChatMessage(AccountManager:getUin(), data.uin, GetS(1325), showType);
		end
		local data 		= msgInfo.data;
		if data then
			local uin 		= data.RoomUin;
			local homeWorldId = gFunc_GetHomeGardenWorldIDByUin(uin)
			local worldID   = data.WorldID or 1
			isHomeLandInviteJoinRoom = (homeWorldId == worldID)
		end

	end

	GamePopUpsFrame_NotNotifySet();
	--家园特殊处理
	NextPopUps(isHomeLandInviteJoinRoom);
    
    GamePopUpsFrame_StandReportSingleEvent("MINI_POPUP_FRIENDSINVITE_1", "Reject", "click") --mark by liya 新埋点
end

--顶部弹框查看按钮点击事件
function GamePopUpsFrameCheckBtn_OnClick()
	GotoDownloadNewVersionGame()
	NextPopUps()
end

function GamePopUpsFrameOkBtn_OnClick(sid, cardid)
	sid = sid or "28"
	cardid = cardid or "MINI_POPUP_FRIENDSINVITE_1"
    -- 埋点数据提前处理
    local msgInfo   = g_PopUpsData.msg[g_PopUpsData.curIndex]
    local cid       = "0"
    local standby1  = "0"
    if msgInfo then
        if msgInfo.type == 'InviteJoinRoom' then
            local data 		= msgInfo.data
            local worldID   = data.WorldID or 0
            local standby1_ = data.Standby1 or 0
            cid             = tostring(worldID)
            standby1        = tostring(standby1_)
        end
    end
	ReportTraceidMgr:setTraceid("friend#accept")
    if sid == "28" then
    	GamePopUpsFrame_StandReportSingleEvent(cardid, "Accept", "click", {cid = cid}) --mark by liya 新埋点
	end
    InsertStandReportGameJoinParamArg({
		sceneid=sid,
		cardid= cardid,
		compid="Accept",
        cid         = cid,
        standby1    = standby1,
		trace_id = "friend#accept"
    })

	GetInst("ReportGameDataManager"):NewGameJoinParam(sid,cardid,"Accept","friend#accept")
	GetInst("ReportGameDataManager"):SetCId(cid)

	--新增审核账号禁止联机功能，但审核开发者广告的仍可联机
	local checker_uin = AccountManager:getUin()
	if IsUserOuterChecker(checker_uin) and not DeveloperAdCheckerUser(checker_uin) then
		ShowGameTips(GetS(100300), 3);
		return;
	end
	local teamupSer = GetInst("TeamupService")
	if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
		ShowGameTips(GetS(26045))
		return
	end
	local isEnterGame = false;
	local msgInfo = g_PopUpsData.msg[g_PopUpsData.curIndex];
	if msgInfo then
		if msgInfo.type == 'InviteJoinRoom' then
			local data 		= msgInfo.data;
			local uin 		= data.RoomUin;
			local roomVer 	= data.RoomVer;
			local pw 		= data.Password;
			local room_id 	= data.RoomId or -1
			local worldID   = data.WorldID or 1
			local myVer     = math.floor(ClientMgr:clientVersion()/256);
			local roomVer   = math.floor(roomVer/256);

			if data.RoomType == "Onekey_Rent_Room" then
				room_id = -2
			end

			if myVer ~= roomVer then	--版本号不匹配
				ShowGameTips(GetS(572), 3);
				return;
			end

			local homeWorldId = gFunc_GetHomeGardenWorldIDByUin(uin)
			if ClientCurGame:isInGame() and homeWorldId~=worldID then	--已经在非家园存档内了
				ShowGameTips(GetS(1204), 3);
				return;
			end
			--租赁服邀请玩家逻辑
			if room_id and room_id > 0 then
				AllRoomManager.CSExtraRoom = {
					authorUin = tonumber(uin),
					password = pw,
					csroomid = tonumber(room_id),
					clientVer = roomVer
				}
			end
			--租赁服邀请玩家逻辑
			local rtb = {
				sceneid=sid,
				cardid=cardid,
				compid="Accept",
				cid = cid,
			}
			
			if RentPermitCtrl:EnterInviteRoom(uin,room_id,pw,roomVer,rtb) then
				-- AccountManager:loginRoomServer(false) --RentPermitCtrl:EnterInviteRoom中会调用loginRoomServer请求
			else
				if data.GuestInCollaborationMode then
					local curSvrTime = AccountManager:getSvrTime()
					if curSvrTime - msgInfo.send_time > 60 then
						ShowGameTips("该邀请消息已过期", 3)
						return
					end

					local addTime = GetAddFriendTime(uin)
					if not IsMyFriend(uin) or not addTime then
						MessageBox(4, GetS(25822))
						return
					end
					
					local day = 7  --加好友时间默认最低限制为7天
					if ns_version and ns_version.mapRoomInviteFriend and ns_version.mapRoomInviteFriend.day then
						day = ns_version.mapRoomInviteFriend.day
					end
					
					print("GamePopUpsFrameOkBtn_OnClick curSvrTime=", curSvrTime, ", addTime=", addTime)
					local timeDay= math.floor((curSvrTime - addTime)/ (24*3600))
					if timeDay < 1 then
						timeDay = 1
					end
			
					if timeDay < day then
						local msg = GetS(25827, day, timeDay)
						MessageBox(4, msg)
						return
					end
				end


				if homeWorldId == worldID then
					-- 家园邀请
					EnterFriendHomeMap(uin, pw)
				else
					-- ShowLoadLoopFrame3(true,"auto");
                    ShowLoadLoopFrame3(true, "file:tips -- func:GamePopUpsFrameOkBtn_OnClick")
					ShowGameTips(GetS(1205), 3);
					t_autojump_service.play_together.worldId = worldID
					t_autojump_service.play_together.GuestInCollaborationModeArr[worldID] = data.GuestInCollaborationMode
					t_autojump_service.play_together.anchorUin = uin;
					t_autojump_service.play_together.password = pw;
					t_autojump_service.play_together.type = "inviteroom";
					t_autojump_service.play_together.LoginRoomServer();
				end
			end

			friendservice.myfriendsUnreadUinSet[data.uin] = nil;
			UpdateRedTags();

			isEnterGame = true;
			RoomInteractiveData.curRoomPW = pw;
		end
	end

	GamePopUpsFrame_NotNotifySet();
	NextPopUps(isEnterGame);

	-- 关掉商店
	if isEnterGame then
		if getglobal("Shop"):IsShown() then
			GetInst("UIManager"):GetCtrl("Shop"):CloseBtnClicked()
		end
	end
end

--勾选按钮
function GamePopUpsFrameHookBtn_OnClick()
	local tick = getglobal("GamePopUpsFrameHookBtnTick");

	if tick:IsShown() then
		tick:Hide();
	else
		tick:Show();
    end
    
    GamePopUpsFrame_StandReportSingleEvent("MINI_POPUP_FRIENDSINVITE_1", "NoShow", "click") --mark by liya 新埋点
end

--记录时间
function GamePopUpsFrame_NotNotifySet()
	print("GamePopUpsFrame_NotNotifySet:");
	local tick = getglobal("GamePopUpsFrameHookBtnTick");

	if tick:IsShown() then
		g_PopUpsData.notNotify_startTime = os.time();
	else
		g_PopUpsData.notNotify_startTime = 0;
	end

	getglobal("GamePopUpsFrameHookBtnTick"):Hide();
end

function NextPopUps(isEnterGame)
	getglobal("GamePopUpsFrame"):Hide();

	if g_PopUpsData.curIndex == #(g_PopUpsData.msg) then
		g_PopUpsData.curIndex = 0;
		g_PopUpsData.msg = {};
	else
		if isEnterGame then
			g_PopUpsData.curIndex = g_PopUpsData.curIndex + 1;
		elseif not ClientCurGame:isInGame() then
			g_PopUpsData.curIndex = g_PopUpsData.curIndex + 1;
			UpdateGamePopUpsFrame();
		end
	end
end 


--通用弹窗数据
_G.g_CommonInviteData = {
	showTime = 12,
	msg = {},
	--五分钟内不再提醒的起始时间
	roomInivite_notNotify_startTime = 0,
	homelandInvite_notNotify_startTime = 0,
	teamInvite_notNotify_startTime = 0,
	applyFriend_notNotify_startTime = 0,
}

--解析房间邀请弹窗逻辑
function CommonInvite_ParseExtendMsg(msgData)
	if ClientMgr:getGameData("popups") == 0 then return end
	print("CommonInvite_ParseExtendMsg", msgData)
	local url_decode_jsonStr = ns_http.func.url_decode(msgData.extend_data)
	local base64_decode_jsonStr = ns_http.func.base64_decode(url_decode_jsonStr)
	local t_extend = JSON:decode(base64_decode_jsonStr)

	--五分钟内不再提醒
	if t_extend.Type == 'InviteJoinRoom' or t_extend.Type == "InviteJoinRoomA" then
		if g_CommonInviteData.roomInivite_notNotify_startTime > 0 and (getServerTime() - g_CommonInviteData.roomInivite_notNotify_startTime) < 5 * 60 then
			return
		end
	elseif t_extend.Type == "InviteJoinHomeland" then
		if g_CommonInviteData.homelandInvite_notNotify_startTime > 0 and (getServerTime() - g_CommonInviteData.homelandInvite_notNotify_startTime) < 5 * 60 then
			return
		end
	end
	


	if t_extend and (t_extend.Type == 'InviteJoinRoom' or t_extend.Type == "InviteJoinRoomA" or t_extend.Type == "InviteJoinHomeland") then
		-- 游戏内且开发者模式屏蔽弹窗
		if ClientCurGame:isInGame() and CurWorld:isGameMakerMode() then 
			return
		end

		--组队中屏蔽弹窗
		if IsUIFrameShown("TeamupMain") then
			return
		end

		--邀请者昵称
		t_extend.InviterName = DefMgr:filterString(t_extend.InviterName)
		--邀请者uin
		t_extend.uin = msgData.uin
		--添加房间邀请信息,分游戏内和游戏外邀请
		if t_extend.Type == 'InviteJoinRoom' or t_extend.Type == "InviteJoinRoomA" then
			table.insert(g_CommonInviteData.msg, {type = "InviteJoinRoom", data = t_extend})
		elseif t_extend.Type == "InviteJoinHomeland" then
			table.insert(g_CommonInviteData.msg, {type = "InviteJoinHomeland", data = t_extend})
		end

		if not GetInst("MiniUIManager"):IsShown("common_invite") then
			local abelshow = true
			if t_extend.WorldID and  GetInst("MatchTeamupService"):IsMatchTeamupMapId(t_extend.WorldID) then
				abelshow = false
			end
			if ClientCurGame and ClientCurGame:isInGame() then
				local fromId  = G_GetFromMapid();
				if GetInst("MatchTeamupService"):IsMatchTeamupMapId(fromId) then
					abelshow = false
				end
			end
			if abelshow then
				GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/c_miniwork","miniui/miniworld/common_comp", "miniui/miniworld/common"})
				GetInst("MiniUIManager"):OpenUI("common_invite", "miniui/miniworld/common_invite", "common_inviteAutoGen")
			end
		end
	end
end

--房间邀请
function CommonInviteFrame_RoomInvite(msg)	
	--新增审核账号禁止联机功能，但审核开发者广告的仍可联机
	if IsUserOuterChecker(AccountManager:getUin()) and not DeveloperAdCheckerUser(AccountManager:getUin()) then
		ShowGameTips(GetS(100300), 3);
		return;
	end
	--组队中，不能进入游戏
	local teamupSer = GetInst("TeamupService")
	if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
		ShowGameTips(GetS(26045))
		return
	end
	local data 		= msg.data;
	local uin 		= data.RoomUin;
	local roomVer 	= data.RoomVer;
	local pw 		= data.Password;
	local room_id 	= data.RoomId or -1
	local worldID   = data.WorldID or 1
	local myVer     = math.floor(ClientMgr:clientVersion()/256);
	local roomVer   = math.floor(roomVer/256);
	local playerNum = data.PlayerNum or 0;
	local playerMaxNum = data.PlayerMaxNum or 0;
	local bolSettlement = data.bolSettlement or 0;
	local bolJoinWhenPlaying = data.bolJoinWhenPlaying or 1;

	if data.RoomType == "Onekey_Rent_Room" then
		room_id = -2
	end

	local diffResult = FriendMgr:DiffTwoVersionFunc(myVer,roomVer)
	if diffResult ~= 0 then
		ShowGameTips(GetS(diffResult), 3);
		return
	end	

	if bolJoinWhenPlaying == 0 then --房间不允许中途加入
		ShowGameTips(GetS(111355), 3);
		return;
	end
	
	if bolSettlement == 1 then --对局已结束
		ShowGameTips(GetS(111354), 3);
		return;
	end

	if playerMaxNum > 0 and playerNum == playerMaxNum then --房间人满
		ShowGameTips(GetS(111353), 3);
		return;
	end

	if ClientCurGame:isInGame() then	--已经在非家园存档内了
		ShowGameTips(GetS(1204), 3);
		return;
	end
	
	local traceId = "friend#accept"
	InsertStandReportGameJoinParamArg({
		sceneid = 2801,
		cardid = "INVITE_POP_UP",
		compid = "Accept",
        cid = worldID,
		trace_id = traceId,
    })
	ReportTraceidMgr:setTraceid("")
	GetInst("ReportGameDataManager"):NewGameJoinParam(2801,"INVITE_POP_UP","Accept", traceId)
	GetInst("ReportGameDataManager"):SetCId(worldID)
	GetInst("ReportGameDataManager"):ReSetStandEnterRoomSceneID()

	--租赁服邀请玩家逻辑
	if room_id and room_id > 0 then
		AllRoomManager.CSExtraRoom = {
			authorUin = tonumber(uin),
			password = pw,
			csroomid = tonumber(room_id),
			clientVer = roomVer
		}
	end
	
	if RentPermitCtrl:EnterInviteRoom(uin,room_id,pw,roomVer,{}) then
		-- AccountManager:loginRoomServer(false) --RentPermitCtrl:EnterInviteRoom中会调用loginRoomServer请求
	else
		if data.GuestInCollaborationMode then
			local curSvrTime = AccountManager:getSvrTime()
			
			local addTime = GetAddFriendTime(uin)
			if not IsMyFriend(uin) or not addTime then
				MessageBox(4, GetS(25822))
				return
			end
			
			local day = 7  --加好友时间默认最低限制为7天
			if ns_version and ns_version.mapRoomInviteFriend and ns_version.mapRoomInviteFriend.day then
				day = ns_version.mapRoomInviteFriend.day
			end
			

			local timeDay= math.floor((curSvrTime - addTime)/ (24*3600))
			if timeDay < 1 then
				timeDay = 1
			end
	
			if timeDay < day then
				local msg = GetS(25827, day, timeDay)
				MessageBox(4, msg)
				return
			end
		end

		ShowLoadLoopFrame3(true, "file:tips -- func:CommonInviteFrame_RoomInvite")
		ShowGameTips(GetS(1205), 3);
		t_autojump_service.play_together.worldId = worldID
		t_autojump_service.play_together.GuestInCollaborationModeArr[worldID] = data.GuestInCollaborationMode
		t_autojump_service.play_together.anchorUin = uin;
		t_autojump_service.play_together.password = pw;
		t_autojump_service.play_together.type = "inviteroom";
		t_autojump_service.play_together.LoginRoomServer();
	end

	friendservice.myfriendsUnreadUinSet[data.uin] = nil;
	UpdateRedTags();
	RoomInteractiveData.curRoomPW = pw;

	if getglobal("Shop"):IsShown() then
		GetInst("UIManager"):GetCtrl("Shop"):CloseBtnClicked()
	end
end

 function setAttribTips(frameName)
 	
 	local t_title = {
 		--传送点相关
 		TransferFrameMainInfoTipsTitleName 				= GetS(21528),
 		TransferFrameMainInfoVisualSwitchTitleName 		= GetS(21529),
 		TransferRuleSetFrameBoxSwitch1NameName			= GetS(21530),
 		TransferRuleSetFrameBoxSwitch2NameName 			= GetS(21531),
 		TransferRuleSetFrameBoxSwitch4NameName			= GetS(21532),

 		--插件物理属性相关
 		PhysxSingleEditorSwitch1NameTitle 				= GetS(11505),
 		PhysxSingleEditorOption1NameTitle 				= GetS(11507),
 		PhysxSingleEditorSlider1NameTitle 				= GetS(11509),
 		PhysxSingleEditorSlider2NameTitle 				= GetS(11511),
 		PhysxSingleEditorSlider3NameTitle 				= GetS(11513),
 		PhysxSingleEditorSwitch2NameTitle 				= GetS(11515),

 		--插件物理材质相关
 		PhysxMaterialOptionSelectNameTitle 				= GetS(11519),
 		PhysxMatSlider1NameTitle 						= GetS(11526),
 		PhysxMatSlider2NameTitle 						= GetS(11528),
 		PhysxMatSlider3NameTitle 						= GetS(11530),

 		PackSingleEditorSlider1NameTitle                = GetS(21804),
 		PackSingleEditorSwitch1NameTitle                = GetS(21805),

		--家园宠物冒险
		PetExploreContentSkillTip                = GetS(41634),
 	}

 	local tipsFrame = "AttribTipsFrame"
	local Bkg 		 = getglobal(tipsFrame.."Bkg")
	local Content 	 = getglobal(tipsFrame.."Content")
	local t_Arrow    = {w=28, h=43}
	local t_Bkg 	 = {w=270,h=100}

	getglobal(tipsFrame):SetPoint("left",frameName,"right",0,0)

	--Content:SetWidth(t_Bkg.w - 20)
	Content:SetHeight(t_Bkg.h - 20)
	Bkg:SetWidth(t_Bkg.w)
	Bkg:SetHeight(t_Bkg.h)

	Content:SetText(t_title[frameName],255,255,255)
	local lineNum = Content:GetViewLines()
	local height = Content:GetTotalHeight()
	local width  = Content:getLineRealWidth(1)
	for i=0,lineNum-1 do
		local temp = Content:getLineRealWidth(i)
		if temp > width then
			width = temp
		end
	end
	--ShowGameTips(tostring(width))
	local ratio = (height/t_Bkg.h <= 1) and (height/t_Bkg.h) or 1
	--Content:SetWidth(width)
	Content:SetHeight(height)
	Bkg:SetWidth(width+14)
	Bkg:SetHeight(height + 20)
	--tipsFrame:Show()
 end

 --------------------------------------------物理部件tips-------------------------------------------------------------------------------
function PhysicsPartTipsFrame_OnLoad( ... )
 	this:setUpdateTime(0.5)
 	this:RegisterEvent("GE_PHYSICS_INOUT_NOTIFY");
end

function PhysicsPartTipsFrame_OnEvent( ... )
 	if arg1 == "GE_PHYSICS_INOUT_NOTIFY" then
		local ge = GameEventQue:getCurEvent();
		if ge.body.gameevent.result == 1 then
			isShowPhysicsPart = true
		elseif ge.body.gameevent.result == 0 then
			isShowPhysicsPart = false
			--if getglobal("PhysicsPartTipsFrame"):IsShown() then
			--	getglobal("PhysicsPartTipsFrame"):Hide()
			--end
		end

	end
end

local UpdatePhysicsPartTips_flag = true
function setPhysicsPartTipsInfo()
 	local PartsTipsFrame 	= getglobal("PhysicsPartTipsFrame")
 	local typeIcon 		= getglobal("PhysicsPartTipsFrameTypeIcon")
 	local partDef 		= DefMgr:getPhysicsPartsDef(tipsItemId)
 	if not partDef then return end

 	local BlockNum 		= partDef.BlockNum
 	local majorType 	= partDef.PartsType
 	local pPartsTypeDef = DefMgr:getPhysicsPartsTypeDef(majorType, 0)
 	local PartsTypeDef	= DefMgr:getPhysicsPartsTypeDefWithPartsId(tipsItemId)
 	if (not PartsTypeDef) or (not pPartsTypeDef) then return false end

 	local name = GetS(pPartsTypeDef.iStringId)
 	local uv   = pPartsTypeDef.sPicUrl
 	if PartsTypeDef.iSubType ~= 0 then
 		name = name.."·"..GetS(PartsTypeDef.iStringId)
 		uv = PartsTypeDef.sPicUrl and PartsTypeDef.sPicUrl or uv
 	end
 	
 	local hp 			= tostring(partDef.Life)
 	local power 		= tostring(partDef.UsePower)
 	local mass 			= 0
 	local PhysicsActorDef = PhysicsActorCsv:get(tipsItemId)
 	if PhysicsActorDef then
 		mass = tostring(PhysicsActorDef.Mass * BlockNum * _G.vehicle_config.mass_display_ratio)
 	end

 	--if subTypeName == "" then
 	--typeIcon:SetTextureHuiresXml("ui/mobile/texture/uitex2.xml");
 	if uv~="" then
 		local uvList = split(uv, "/")
 		typeIcon:SetTextureHuiresXml("ui/mobile/texture2/"..uvList[1]..".xml")
 		typeIcon:SetTexUV(uvList[2]);
 		getglobal("PhysicsPartTipsFrameTypeIconBkg"):Show()
 		typeIcon:Show()
 	else
 		typeIcon:Hide()
 		getglobal("PhysicsPartTipsFrameTypeIconBkg"):Hide()
 	end
 	getglobal("PhysicsPartTipsFrameTypeDesc"):SetText(name)

 	getglobal("PhysicsPartTipsFrameHp"):SetText(hp)
 	getglobal("PhysicsPartTipsFramePower"):SetText(power)
 	getglobal("PhysicsPartTipsFrameMass"):SetText(mass..GetS(12016))
		
 	if not PartsTipsFrame:IsShown() then
 		PartsTipsFrame:Show()
 	end
 	return true

end

function PhysicsPartTipsFrame_OnUpdate( ... )
 	--if isShowPhysicsPart == false or (not getglobal("MItemTipsFrame"):IsShown()) then
 	--	UpdatePhysicsPartTips_flag = true
 	--	this:Hide()
 	if UpdatePhysicsPartTips_flag then
 		setPhysicsPartTipsPos(getglobal("MItemTipsFrame"),getglobal("PhysicsPartTipsFrame"))
 		--print("ssssssol")
 		UpdatePhysicsPartTips_flag = false
 	end
end

function setPhysicsPartTipsPos(baseFrame, tipsFrame)
 	local baseTop = baseFrame:GetTop()
 	local baseBottom = baseFrame:GetBottom()
 	local baseLeft = baseFrame:GetLeft()
 	local baseRight = baseFrame:GetRight()

 	local height = tipsFrame:GetRealHeight()
 	local width = tipsFrame:GetRealWidth()
 	
 	local screenWidth = GetScreenWidth();
	local screenHeight = GetScreenHeight();

	local horizontal = true;
	local vertical = true;

	if screenWidth - baseRight >= width then
		horizontal = true
	else
		horizontal = false
	end

	if screenHeight - baseTop >= height then
		vertical = true
	else
		vertical = false
	end

	if horizontal then
		if vertical then
			tipsFrame:SetPoint("topleft",baseFrame:GetName(),"topright",-2,0)
		else
			tipsFrame:SetPoint("bottomleft",baseFrame:GetName(),"bottomright",-2,0)
		end
	else
		if vertical then
			tipsFrame:SetPoint("topright",baseFrame:GetName(),"topleft",2,0)
		else
			tipsFrame:SetPoint("bottomright",baseFrame:GetName(),"bottomleft",2,0)
		end
	end
end

function PhysicsPartTipsFrame_OnHide( ... )
	if not this:IsRehide() then
		--print("12222111")
		UpdatePhysicsPartTips_flag = true
	end
end


function ParamTipsFrame_OnLoad()
	this:setUpdateTime(0.05);
end

function ParamTipsFrame_OnShow()
	getglobal("ParamTipsFrame"):SetBlendAlpha(1.0);
	getglobal("ParamTipsFrameBkg"):SetBlendAlpha(1.0);
	getglobal("ParamTipsFrameTitle"):SetBlendAlpha(1.0);
end

local alpha = 1.0;
function ParamTipsFrame_OnUpdate()
	displayTime = displayTime - arg1
	if displayTime <= 0 then	
		alpha = alpha - 0.1;
		if alpha < 0 then
			alpha = 0;
		end

		getglobal("ParamTipsFrameTitle"):SetBlendAlpha(alpha);
		getglobal("ParamTipsFrameBkg"):SetBlendAlpha(alpha);
		getglobal("ParamTipsFrame"):SetBlendAlpha(alpha);

		if alpha == 0 then
			alpha = 1.0;
			displayTime = 2.0;
			this:Hide();			
		end
	end
end

function PopParamTips(content,fontsize ,time)
	displayTime = time or 2
	getglobal("ParamTipsFrame"):Show()
	getglobal("ParamTipsFrameTitle"):SetText(content)
	local width = string.len(content)*7+100
    local screenWidth = GetScreenWidth()
	if width > screenWidth then --超出屏幕
		getglobal("ParamTipsFrame"):SetWidth(screenWidth)
		getglobal("ParamTipsFrameTitle"):SetFontSize(fontsize or 24)
		getglobal("ParamTipsFrameTitle"):SetWidth(screenWidth)
	else
		getglobal("ParamTipsFrame"):SetWidth(width)
		getglobal("ParamTipsFrameTitle"):SetFontSize(fontsize or 26)
		getglobal("ParamTipsFrameTitle"):SetWidth(width)
	end
end
--------------------------------------------------------GameHUDFrame---------------------------------------------------
--渐隐的弹框
local t_gameHUD = {
	updateTime = 0.3,
    alpha = 1.0,
}
function ShowGameHUD(text)
	if text == nil then return end
	text = DefMgr:filterString(text);
	t_gameHUD.alpha = 1.0

	local textObj = getglobal("GameHUDFrameText")
    local gameHUDFrame = getglobal("GameHUDFrame")

	textObj:SetText(text)
	if not gameHUDFrame:IsShown() then
		gameHUDFrame:Show();
	else
		gameHUDFrame:Hide();
		gameHUDFrame:Show();
	end
end

function GameHUDFrame_OnLoad()
	this:setUpdateTime(t_gameHUD.updateTime)
end

function GameHUDFrame_OnShow()
    local text = getglobal(this:GetName() .. "Text")
	local bkg = getglobal("GameHUDFrameBkg")
	text:SetBlendAlpha(1.0)
	bkg:SetBlendAlpha(1.0)
end

function GameHUDFrame_OnUpdate()

	local alpha = t_gameHUD.alpha
	alpha = alpha - 0.1;

	if alpha < 0 then
		alpha = 0;
	end

	if alpha >= 0 then
		local text = getglobal("GameHUDFrameText")
		local bkg = getglobal("GameHUDFrameBkg")
		text:SetBlendAlpha(alpha)
		bkg:SetBlendAlpha(alpha)

        if alpha <= 0.3 then
			alpha = 1.0;
            this:Hide();
        end
		t_gameHUD.alpha = alpha
    end
end

--function OpenItemInfoFrameNoUse(itemId, num)
--功能：由于缺乏一个不带功能（使用/解锁）的物品详情展示公共接口，之前在BP中做了一个，这个接口是把BP中物品格子信息页公开
--      给其他页面用，具体用法请全局搜索这个接口，接口效果可以到BP中点击不可领取的奖励查看
--参数：
--itemid：物品ID
--num：数量
function OpenItemInfoFrameNoUse(itemId, num)

    local itemDef = ItemDefCsv:get(itemId)
    getglobal("NotFuncItemTipsNum"):SetText(num)
    SetItemIcon(getglobal("NotFuncItemTipsIcon"), itemId)
    getglobal("NotFuncItemTipsName"):SetText(itemDef.Name)
    getglobal("NotFuncItemTipsDesc"):SetText(itemDef.Desc)
    getglobal("NotFuncItemTips"):Show()
end

--关闭物品信息页按钮处理
function CloseItemInfoFrameNoUse()
    getglobal("NotFuncItemTips"):Hide()
end