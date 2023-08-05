local PokedexType_Max_Num = 10;
local PokedexSeries_Max_Num = 25;
local Pokedex_Max_Num = 12;
local t_PokedexType = {};				--图鉴类
local t_Pokedex = {};					--所有的图鉴
local t_PokedexTypeRedTag = {};				--能解锁的图鉴大类
local CurPokedexType = 1;
local HightLightPokedexName = "";

function PokedexFrameCloseBtn_OnClick()
	getglobal("PokedexFrame"):Hide();
	if getglobal("MItemTipsFrame"):IsShown() then
		getglobal("MItemTipsFrame"):Hide();
	end
end

function HideAllPokedexTypeCheck()
	for i=1, PokedexType_Max_Num do
		local check = getglobal("PokedexType"..i.."CheckBkg");
		if check:IsShown() then
			check:Hide();
		end
	end
end

function UpdatePokedexFrame(InvolvedID)
	local type = CurPokedexType;
	local bookDef = DefMgr:getBookDefByItemID(InvolvedID);
	if type == bookDef.TypeID	then return end
	if type > 0 then
		HideHightLightPokedex();
		HideAllPokedexTypeCheck();
		if getglobal("MItemTipsFrame"):IsShown() then
			getglobal("MItemTipsFrame"):Hide();
		end

		getglobal(this:GetName().."CheckBkg"):Show();
		CurPokedexType = type;
		UpdatePokedexSeries(true);
	end
end

function PokedexTypeBtn_OnClick()
	local type = this:GetClientUserData(0);
	if type == CurPokedexType then return end
	if type > 0 then
		HideHightLightPokedex();
		HideAllPokedexTypeCheck();
		if getglobal("MItemTipsFrame"):IsShown() then
			getglobal("MItemTipsFrame"):Hide();
		end

		getglobal(this:GetName().."CheckBkg"):Show();
		CurPokedexType = type;
		UpdatePokedexSeries(true);
	end
end

function PokedexTemplate_OnClick()
	HideHightLightPokedex();
	local hightLight = getglobal(this:GetName().."HightLight");
	hightLight:Show();
	HightLightPokedexName = hightLight:GetName();

	local itemId = this:GetClientID();

	if itemId > 0 then	--星星不显示tips
		SetMTipsInfo(-1, this:GetName(), false, itemId);
	end
end

function HideHightLightPokedex()
	if HightLightPokedexName ~= "" then
		getglobal(HightLightPokedexName):Hide();
		HightLightPokedexName = "";
	end
end

--领取奖励
function PokedexSeriesRewardGetBtn_OnClick()
	local seriesId = this:GetClientUserData(0);
	local index = this:GetClientUserData(1);

	if AccountManager.itemlist_can_add and not AccountManager:itemlist_can_add({seriesId}) then
		StashIsFullTips();
		return;
	end

	if IsEnableHomeLand and IsEnableHomeLand() then
		--家园版的
		local function callback(ret, userdata)
			ShowGameTips(GetS(671), 3);
			UpdateOnePokedexSeries(seriesId, index);
			ClientMgr:playSound2D("sounds/ui/info/book_seriesunlock.ogg", 1);
		end

		-- 没上报客户端埋点 就清空上一次的log_id 和 scene_id
		resetLogIdAndSceneId()
		
		GetInst("HomeLandService"):ReqGetUnlockGroupReward(seriesId, callback)
	else
		local result = AccountManager:getAccountData():notifyServerOpUnlockAward(seriesId);
		if result == 0 then	--领取奖励成功
			ShowGameTips(GetS(671), 3);
			UpdateOnePokedexSeries(seriesId, index);
			ClientMgr:playSound2D("sounds/ui/info/book_seriesunlock.ogg", 1);
		else
			--ShowGameTips(GetS(282).."("..result..")", 3);
		end
	end
end

function PokedexSeriesBox_OnMouseMove()
	if getglobal("MItemTipsFrame"):IsShown() then
		getglobal("MItemTipsFrame"):Hide();
	end
end

function PokedexFrame_OnLoad()
	for i=1, PokedexType_Max_Num do
		local type = getglobal("PokedexType"..i);
		type:SetPoint("top", "PokedexTypeBoxPlane", "top", 0, (i - 1) * 97 + 10);
	end

	--右侧区块布局
	for i=1, PokedexSeries_Max_Num do
		local series = getglobal("PokedexSeries"..i);
		if i == 1 then
			series:SetPoint("top", "PokedexSeriesBoxPlane", "top", 0, 0);
		else
			local index = i-1;
			local preSeriesUI = "PokedexSeries"..index;
			local preSeries = getglobal(preSeriesUI);
			series:SetPoint("top", preSeriesUI, "bottom", 0, 8);

			--每一个区块中的格子布局
			for j = 1, Pokedex_Max_Num do
				local itemUI = preSeriesUI .. "Item" .. j;
				local item = getglobal(itemUI);

				local row = math.ceil(j / 8);
				local col = (j - 1) % 8 + 1;
				item:SetPoint("topleft", preSeriesUI, "topleft", 19 + (col - 1) * 91, 64 + (row - 1) * 90);
			end
		end		
	end

	LoadPokedex();
--	UpdatePokedexRedTag();

	this:RegisterEvent("GIE_POKEDEX_CHANGE");
end

function PokedexFrame_OnEvent()
	if arg1 == "GIE_POKEDEX_CHANGE" then
		UpdatePokedexRedTag();
		if getglobal("PokedexFrame"):IsShown() then
			UpdatePokedexSeries(false);
		end
	end
end

function GetPokedexType(id)
	for i=1, #(t_PokedexType) do
		if id == t_PokedexType[i].ID then
			return i, true;
		end
	end

	return 0, false;
end

function HasPokedexSeries(index, id)
	for i=1, #(t_PokedexType[index].Series) do
		if id == t_PokedexType[index].Series[i] then
			return true;
		end
	end

	return false;
end

function LoadPokedexType(bookDef)
	local index, hasType = GetPokedexType(bookDef.TypeID);
	if not hasType then
		table.insert(t_PokedexType, {ID=bookDef.TypeID, Name=bookDef.TypeName, Series={bookDef.SeriesID}} )
	else
		if not HasPokedexSeries(index, bookDef.SeriesID) then
			table.insert(t_PokedexType[index].Series, bookDef.SeriesID);
		end
	end
end

function LoadPokedex()
	t_PokedexType = {};
	t_Pokedex = {};
	local bookNum = DefMgr:getBookNum();
	for i=1, bookNum do
		local bookDef = DefMgr:getBookDefByID(i-1);
		if bookDef ~= nil then
			LoadPokedexType(bookDef);
			table.insert(t_Pokedex, bookDef);
		end
	end
end

function hasTypeTbRedTag(type)
	for i=1, #(t_PokedexTypeRedTag) do
		if t_PokedexTypeRedTag[i] == type then
			return true;
		end
	end
	
	return false;
end

function InitPokedexRedTag()
	if #(t_PokedexTypeRedTag) == 0 then
		UpdatePokedexRedTag();
	end
end

--获取已就锁的图鉴的总数
function getUnlockedBookSum()
	print("getUnlockedBookSum:");
	local sum = 0;

	--LoadPokedex();

	if t_Pokedex then
		print("111:");
		for i = 1, #t_Pokedex do
			print("i = ", i);
			local itemDef = ItemDefCsv:get(t_Pokedex[i].ItemID);

			if itemDef ~= nil then
				print("itemDef ok:");
				if itemDef.UnlockType == 0 then		--不用解锁
					--UnlockType = 0: 不用解锁; UnlockType = 4:迷你豆; UnlockType = 3, 5: 碎片
					print("0:");
				else
					print("else:");
					if isItemUnlockByItemId(itemDef.ID) then
						print("unlocked:");
						sum = sum + 1;
					end
				end
			end
		end
	end

	return sum;
end

function UpdatePokedexRedTag()
	t_PokedexTypeRedTag = {};
	for i=1, #(t_Pokedex) do
		local itemDef = ItemDefCsv:get(t_Pokedex[i].ItemID);
		if itemDef ~= nil and (itemDef.UnlockType == 3 or itemDef.UnlockType == 5) then
			if itemDef.UnlockFlag > 0 then
				local hasNum = AccountManager:getAccountData():getAccountItemNum(itemDef.InvolvedID);
				local needNum = itemDef.ChipNum;
				if not isItemUnlockByItemId(itemDef.ID) then --未解锁
					if hasNum >= needNum and not hasTypeTbRedTag(t_Pokedex[i].TypeID) then
						table.insert(t_PokedexTypeRedTag, t_Pokedex[i].TypeID);
					end
				else
					if hasNum > 0 and not hasTypeTbRedTag(t_Pokedex[i].TypeID) then
						table.insert(t_PokedexTypeRedTag, t_Pokedex[i].TypeID);
					end
				end
			end
		end		
	end

	if getglobal("HomeChestFramePokedexBtn"):IsShown() then
		UpdateHomeChestFramePokedexBtnRedTag();
	end	

	if getglobal("PokedexFrame"):IsShown() then
		UpdatePokedexFrameTypeRedTag();
	end
end

function UpdateHomeChestFramePokedexBtnRedTag()
	if #(t_PokedexTypeRedTag) > 0 then
		getglobal("HomeChestFramePokedexBtnRedTag"):Show();
	else
		getglobal("HomeChestFramePokedexBtnRedTag"):Hide();
	end
end

function UpdatePokedexFrameTypeRedTag()
	for i=1, PokedexType_Max_Num do
		local type = getglobal("PokedexType"..i);
		if type:IsShown() and hasTypeTbRedTag(type:GetClientUserData(0)) then
			getglobal(type:GetName().."RedTag"):Show();
		else
			getglobal(type:GetName().."RedTag"):Hide();
		end
	end
end

function PokedexFrame_OnShow()
	--标题栏
	getglobal("PokedexFrameTitleFrameName"):SetText(GetS(417));

	HideHightLightPokedex();
	HideAllPokedexTypeCheck();

	UpdatePokedexTypeFrame();
	getglobal("PokedexSeriesBox"):setDealMsg(true);

	--print("WWW_get_building_bag_unlock_info PokedexFrame_OnShow = "..os.time())
	WWW_get_building_bag_unlock_info() --获取解锁信息
end

function UpdatePokedexTypeFrame()
	getglobal("PokedexTypeBox"):resetOffsetPos();
	local typeNum = #(t_PokedexType);
	for i=1, PokedexType_Max_Num do
		local type = getglobal("PokedexType"..i);
		if i <= typeNum then
			type:Show();
			local text = getglobal(type:GetName().."Text");

			text:SetText(t_PokedexType[i].Name);
			--text:SetText(GetS(4082));

			type:SetClientUserData(0, t_PokedexType[i].ID);
		else
			type:SetClientUserData(0, 0);
			type:Hide();
		end
	end

	UpdatePokedexFrameTypeRedTag();

	local planeH = typeNum * 97 > 485 or 485;
	getglobal("PokedexTypeBoxPlane"):SetHeight(planeH);

	if typeNum >= 1 then
		CurPokedexType = t_PokedexType[1].ID;
		getglobal("PokedexType1CheckBkg"):Show();
		UpdatePokedexSeries(true);
	end
end

function GetPokedexSeries(type)
	for i=1, #(t_PokedexType) do
		if t_PokedexType[i].ID == type then
			return t_PokedexType[i].Series;
		end
	end

	return nil
end

function UpdatePokedexSeries(isReset)
	local t_series = GetPokedexSeries(CurPokedexType)
	if t_series == nil then return end

	if isReset then
		getglobal("PokedexSeriesBox"):resetOffsetPos();
	end
	local height = 0;
	for i=1, PokedexSeries_Max_Num do
		local series = getglobal("PokedexSeries"..i);
		if i <= #(t_series) then
			series:Show();
			height = height + UpdateOnePokedexSeries(t_series[i], i);
		else
			series:Hide();
		end
	end
	if height < 500 then
		height = 500;
	end
	getglobal("PokedexSeriesBoxPlane"):SetHeight(height);
end

function GetPokedex(type, seriesId)
	local t_pokedex = {};
	for i=1, #(t_Pokedex) do
		if t_Pokedex[i].SeriesID == seriesId and t_Pokedex[i].TypeID == type then
			table.insert(t_pokedex, t_Pokedex[i]);
		end
	end

	return t_pokedex;
end

function UpdateOnePokedexSeries(seriesId, index)
	local series = getglobal("PokedexSeries"..index); 
	local t_pokedex = GetPokedex(CurPokedexType, seriesId);
	
	local isCollect = true;
	for i=1, Pokedex_Max_Num do
		local pokedexItem = getglobal(series:GetName().."Item"..i)
		if i <= #(t_pokedex) then
			pokedexItem:Show();
			pokedexItem:SetClientID(t_pokedex[i].ItemID);
			local icon 		= getglobal(pokedexItem:GetName().."Icon");
			local lockIcon 		= getglobal(pokedexItem:GetName().."LockIcon");
			local name 		= getglobal(pokedexItem:GetName().."Name");
			local redTag 		= getglobal(pokedexItem:GetName().."RedTag");
			local unlock		= getglobal(pokedexItem:GetName().."Unlock");

			SetItemIcon(icon, t_pokedex[i].ItemID);
			local itemDef = ItemDefCsv:get(t_pokedex[i].ItemID);
			if itemDef then
				name:SetText(itemDef.Name);
			end
			redTag:Hide();

			local itemDef = ItemDefCsv:get(t_pokedex[i].ItemID);
			if itemDef ~= nil then
				if itemDef.UnlockType == 0 then		--不用解锁
					unlock:Hide();
					lockIcon:Hide();
				--	name:Show();
					icon:SetGray(false);
				elseif itemDef.UnlockType == 4 then	--迷你豆
					unlock:Hide();
				--	name:Show();
				
					if isItemUnlockByItemId(itemDef.ID) then
						lockIcon:Hide();
						icon:SetGray(false);
					else
						lockIcon:Show();
						isCollect = false;
						icon:SetGray(true);
					end
				elseif itemDef.UnlockType == 3 or itemDef.UnlockType == 5 then	--碎片
					local hasNum = AccountManager:getAccountData():getAccountItemNum(itemDef.InvolvedID);
					local needNum = itemDef.ChipNum;

					if isItemUnlockByItemId(itemDef.ID) then
						unlock:Hide();
						lockIcon:Hide();
					--	name:Show();
						if hasNum > 0 then
							redTag:Show();
						end
						icon:SetGray(false);
					else
						isCollect = false;
						
						--if hasNum > 0 then
						if true then
						--	name:Hide();
							unlock:Show();
							lockIcon:Hide();
							local pro 	= getglobal(unlock:GetName().."Pro");
							local count 	= getglobal(unlock:GetName().."Count");

							local radio = hasNum/needNum;
						
							if hasNum >= needNum then
								redTag:Show();
								radio = 1;
							end
							pro:ChangeTexUVWidth(72 * radio);
							pro:SetSize(72 * radio, 13);
							local text = hasNum.."/"..needNum;
							count:SetText(text);
						else
							unlock:Hide();
							lockIcon:Show();
						--	name:Show();
						end	

						icon:SetGray(true);					
					end
				end
			else
				pokedexItem:Hide();
			end
		else
			pokedexItem:Hide();
			pokedexItem:SetClientID(0);
		end
	end

	local seriesDef = DefMgr:getBookSeriesDef(seriesId);
	if seriesDef ~= nil then
		local reward 	= getglobal(series:GetName().."Reward");
		local name	= getglobal(series:GetName().."Name");
		
		name:SetText(seriesDef.Name);

		if seriesDef.RewardType == 0 then
			reward:Hide();
		else
			reward:Show();
			local rewardIcon 	= getglobal(reward:GetName().."Icon");
			local rewardNum		= getglobal(reward:GetName().."Num");
			local rewardGet		= getglobal(reward:GetName().."GetBtn");
			local rewardGetName	= getglobal(reward:GetName().."GetBtnName");
			local rewardGetNormal	= getglobal(reward:GetName().."GetBtnNormal");
			
			SetItemIcon(rewardIcon, seriesDef.RewardID);
			rewardNum:SetText("×"..seriesDef.RewardNum);
			rewardGet:SetClientUserData(0, seriesId);
			rewardGet:SetClientUserData(1, index);

			rewardGetName:SetTextColor(255, 255, 255);
			if isCollect then
				if getItemUnlockInfoGroupRewardById(seriesId) == 2 then	--已领取
					rewardGet:Disable();
					rewardGetNormal:SetGray(true);
					rewardGetName:SetText(GetS(3029));
					rewardGetName:SetTextColor(96, 96, 96);
				else								--可领取
					rewardGet:Enable();
					rewardGetNormal:SetGray(false);
					rewardGetName:SetText(GetS(492));
					rewardGetName:SetTextColor(55, 54, 51);
				end
			else									--不可领取
				rewardGet:Disable();
				rewardGetNormal:SetGray(true);
				rewardGetName:SetText(GetS(492));
			end
		end
	end

	local height = 165;
	if #(t_pokedex) > 8 then
		height = 256;
	end

	series:SetHeight(height);

	return height + 10;
end