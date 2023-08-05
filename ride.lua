
local Ride_Equips_Max_Num = 40
local Ride_Skill_Max_Num = 4;
local curShowRideOrPetIndex = 1

--是否是z坐骑装备
function IsRideEquip(index)
	local type = ClientBackpack:getGridToolType(index);
	if type == 19 or type == 20 then
		return true;
	end

	return false;
end

function RideSkillBtnTemplate_OnClidk()
	local id = this:GetClientID();
	if id == 1 then			--下蛋
		local time = math.ceil(OpenedContainerMob:getHorseCanAgeTick() /20);
		if time > 0 then
			local h = math.floor(time/3600);
			local remian = time - h*3600;
			local m = math.floor(remian/60);
			local s = remian - 60*m;
			
			local text = "";
			if h > 0 then
				text = h..GetS(558);
			end
			if m > 0 then
				text = text..m..GetS(437);
			end
			if s > 0 then
				text = text..s..GetS(559);
			end
			ShowGameTipsWithoutFilter(GetS(560)..":"..text, 3);
		else
			CurMainPlayer:accountHorseEgg();
			--[[
			local result = CurMainPlayer:accountHorseEgg();
			if result == -1 then
				ShowGameTips(StringDefCsv:get(386), 3);
			elseif result == -2 then
				ShowGameTips(StringDefCsv:get(391), 3);
			elseif result == 0 then
				ShowGameTips(StringDefCsv:get(392), 3);
			end]]
		end
	else
		getglobal("RideFrameSkillTips"):SetPoint("bottom", this:GetName(), "top", 0, -5)
		UpdateRideFrameSkillTips(id);
	end
end

function RideSkillBtnTemplate_OnMouseUp()
end

function RideSkillBtnTemplate_OnMouseDownUpdate()
end

function RideFrameCloseBtn_OnClick()
	getglobal("RideFrame"):Hide();
end

--坐鞍装备位
function RideFrame_CurEquip1_OnClick()
	local grid_index = this:GetClientID();
	local itemId = ClientBackpack:getGridItem(grid_index);
	if itemId == 0 then return; end

	if ClientMgr:isPC() then
		RideFrameEquipPlace(grid_index);
	else
		SetMTipsInfo(grid_index, this:GetName(), false);
		SetRideFrameBoxTexture(this:GetName());
	end
end

--铠甲装备位
function RideFrame_CurEquip2_OnClick()
	local grid_index = this:GetClientID();
	local itemId = ClientBackpack:getGridItem(grid_index);
	if itemId == 0 then return; end
	if ClientMgr:isPC() then
		RideFrameEquipPlace(grid_index);
	else
		SetMTipsInfo(grid_index, this:GetName(), false);
		SetRideFrameBoxTexture(this:GetName());
	end
end

function RideFrame_OnLoad()
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	RideFrame_AddGameEvent()
	for i=1, Ride_Equips_Max_Num do
		local item = getglobal("EquipRideBoxItem"..i);
		item:SetPoint("left", "EquipRideBoxPlane", "left", (i-1)*85, 0)
	end
end

function RideFrame_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local paramData = context:GetParamData()
		local grid_index = paramData.gridIndex
		if grid_index and grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX+2000 then
			RideFrameUpdateOneGrid(grid_index);
		elseif grid_index >= HORSE_EQUIP_INDEX and grid_index < HORSE_EQUIP_INDEX+1000 then
			UpdateRideCurEuqipOneGrid(grid_index);
		end
	end)
end

function RideFrame_OnEvent()
	if arg1 == "GE_BACKPACK_CHANGE" then
		local ge = GameEventQue:getCurEvent();
		local grid_index = ge.body.backpack.grid_index;
		if grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX+2000 then
			RideFrameUpdateOneGrid(grid_index);
		elseif grid_index >= HORSE_EQUIP_INDEX and grid_index < HORSE_EQUIP_INDEX+1000 then
			UpdateRideCurEuqipOneGrid(grid_index);
		end
	end
end

function RideFrame_OnShow()
	HideAllFrame("RideFrame", true);
	InitRideEquips();
	InitRideInfo();	
	if not getglobal("RideFrame"):IsReshow() then
	ClientCurGame:setOperateUI(true);
	end
end

function RideFrame_OnHide()
	ShowMainFrame();
	local mItemTipsFrame = getglobal("MItemTipsFrame");	
	if mItemTipsFrame:IsShown() then
		mItemTipsFrame:Hide();
	end
	if not getglobal("RideFrame"):IsRehide() then
	ClientCurGame:setOperateUI(false);
	end

	if OpenedContainerMob ~= nil then
		OpenedContainerMob:detachUIModelView();
	end
	CurMainPlayer:closeContainer();
	
	getglobal("RideFrameSkillTips"):Hide();
	if not getglobal("RideFrame"):IsRehide() then
	ClientCurGame:setOperateUI(false);
	end
end

function InitRideInfo()
	if OpenedContainerMob ~= nil then
		local name = OpenedContainerMob:getDef().Name;
		getglobal("RideFrameInfoName"):SetText(name);

		local hp = math.ceil(OpenedContainerMob:getMobAttrib():getHP());
		local maxhp = OpenedContainerMob:getMobAttrib():getMaxHP();
		--getglobal("RideFrameInfoHp"):SetSize(147*hp/maxhp, 25);
		getglobal("RideFrameInfoHpFont"):SetText(hp.."/"..maxhp);

		local speed = OpenedContainerMob:getRiddenLandSpeed();
		getglobal("RideFrameInfoSpeed"):SetText(speed);

		local jumpHeight = OpenedContainerMob:getMaxJumpHeight();
		getglobal("RideFrameInfoJump"):SetText(jumpHeight);

		local modelView = getglobal("RideFrameInfoView");
		OpenedContainerMob:attachUIModelView(modelView);
		local actorBody = OpenedContainerMob:getUIViewBody();
		if actorBody ~= nil then
			local houseUIScale = OpenedContainerMob:getHorseDef().UIScale;
			actorBody:setRealScale(houseUIScale);
		end
		
		modelView:setRotateAngle(30);

		--技能
		local t_SkillList = {0, 0, 0,0};
		t_SkillList[1], t_SkillList[2], t_SkillList[3],t_SkillList[4] = OpenedContainerMob:getHorseSkillList(t_SkillList[1], t_SkillList[2], t_SkillList[3],t_SkillList[4]);
		
		local skillIdx = 0;
		for i=1, #(t_SkillList) do
			if t_SkillList[i] > 0 then
				skillIdx = skillIdx + 1;
				local skill = getglobal("RideFrameSkill"..skillIdx);
				if skillIdx == 1 then
					if #(t_SkillList) == 4 then
						skill:SetPoint("left","RideFrameSkill","left",-20,0)
					else
						skill:SetPoint("left","RideFrameSkill","left",0,0)
					end
				else
					if #(t_SkillList) == 4 then
						skill:SetPoint("left","RideFrameSkill"..(skillIdx-1),"right",20,0)
					else
						skill:SetPoint("left","RideFrameSkill"..(skillIdx-1),"right",0,0)
					end
				end
				local normal = getglobal(skill:GetName().."Normal");
				local pushedBG = getglobal(skill:GetName().."PushedBG");
				
				skill:Show();
				skill:SetClientID(t_SkillList[i]);
				local horseAbilityDef = DefMgr:getHorseAbilityDef(t_SkillList[i]); 
				if horseAbilityDef ~= nil then
					normal:SetTexture("ui/rideskillicons/"..horseAbilityDef.Icon..".png");
					pushedBG:SetTexture("ui/rideskillicons/"..horseAbilityDef.Icon..".png");
				end
			end
		end

		for i=1, Ride_Skill_Max_Num do
			local skill = getglobal("RideFrameSkill"..i);
			if i > skillIdx then
				skill:Hide();
			end
		end
	end
end

function InitRideEquips()
	getglobal("EquipRideBox"):resetOffsetPos();
	--从背包物品栏中筛选出所有的坐骑装备
	local t_RideEquipsGridIndex = {};
	for i=1,BACK_PACK_GRID_MAX do
		local grid_index = i + BACKPACK_START_INDEX - 1;
		if IsRideEquip(grid_index) then
			table.insert(t_RideEquipsGridIndex, grid_index);	
		end
	end
	--从快捷栏中筛选出所有的坐骑装备
	for i=1,MAX_SHORTCUT do
		local grid_index = i + ClientBackpack:getShortcutStartIndex() - 1;
		if IsRideEquip(grid_index) then
			table.insert(t_RideEquipsGridIndex, grid_index);		
		end
	end
	--更新到坐骑信息面板的装备列表中
	for i=1, Ride_Equips_Max_Num do	
		local btn = getglobal("EquipRideBoxItem"..i);
		local icon = getglobal("EquipRideBoxItem"..i.."Icon");
		local num = getglobal("EquipRideBoxItem"..i.."Count");
		local durbkg = getglobal("EquipRideBoxItem"..i.."DurBkg");
		local durbar = getglobal("EquipRideBoxItem"..i.."Duration");
			
		if i <= #(t_RideEquipsGridIndex) then
			local grid_index = t_RideEquipsGridIndex[i];
			btn:SetClientID(grid_index+1);						--标识这个装备在背包栏中的Index;
			UpdateGridContent(icon, num, durbkg, durbar, grid_index);
		else
			icon:SetTextureHuires(ClientMgr:getNullItemIcon());
			num:SetText("");
			btn:SetClientID(0);
			durbar:Hide();
			durbkg:Hide();
		end
	end

	local plane = getglobal("EquipRideBoxPlane");
	local showRideEquipItemNum = 6;
	if #(t_RideEquipsGridIndex) <= 6 then
		plane:SetSize(503, 81);
	else
		showRideEquipItemNum = #(t_RideEquipsGridIndex);
		plane:SetSize((showRideEquipItemNum-6)*85+503, 81);
	end
	for i=1, Ride_Equips_Max_Num do	
		local btn = getglobal("EquipRideBoxItem"..i);
		if i <= showRideEquipItemNum then
			btn:Show();
		else
			btn:Hide();
		end
	end
	--更新装备栏
	for i=1, 2 do
		-- if i == 2 then			
		-- 	if OpenedContainerMob:armorSlotOpen() then
		-- 		getglobal("RideFrameCurEquip"..i):Show();
		-- 	else
		-- 		getglobal("RideFrameCurEquip"..i):Hide();
		-- 	end		
		-- end
		getglobal("RideFrameCurEquip"..i):Hide();
		local grid_index = HORSE_EQUIP_INDEX + i - 1;
		local iconbtn = getglobal("RideFrameCurEquip"..i.."Icon");
		local numtext = getglobal("RideFrameCurEquip"..i.."Count");
		local durbkg = getglobal("RideFrameCurEquip"..i.."DurBkg");
		local durbar = getglobal("RideFrameCurEquip"..i.."Duration");

		UpdateGridContent(iconbtn, numtext, durbar, durbkg, grid_index);
	end
end

function RideFrameUpdateOneGrid(grid_index)
	for i=1, Ride_Equips_Max_Num do
		local btn = getglobal("EquipRideBoxItem"..i);
		if btn:GetClientID() == grid_index+1 then
			local icon = getglobal("EquipRideBoxItem"..i.."Icon");
			local num = getglobal("EquipRideBoxItem"..i.."Count");
			local durbkg = getglobal("EquipRideBoxItem"..i.."DurBkg");
			local durbar = getglobal("EquipRideBoxItem"..i.."Duration");
			if IsRideEquip(grid_index) then
				UpdateGridContent(icon, num, durbkg, durbar, grid_index);
			else
				icon:SetTextureHuires(ClientMgr:getNullItemIcon());
				num:SetText("");
				btn:SetClientID(0);
				durbar:Hide();
				durbkg:Hide();
			end
			return;
		end
	end

	for i=1,Ride_Equips_Max_Num do									-- 找一个空的格子放这个物品
		local btn = getglobal("EquipRideBoxItem" .. i);
		if btn:GetClientID() < 1 then
			local icon = getglobal("EquipRideBoxItem"..i.."Icon");
			local num = getglobal("EquipRideBoxItem"..i.."Count");
			local durbkg = getglobal("EquipRideBoxItem"..i.."DurBkg");
			local durbar = getglobal("EquipRideBoxItem"..i.."Duration");
			btn:SetClientID(grid_index+1);
			--标识这个装备在背包栏中的Index;
			UpdateGridContent(icon, num, durbkg, durbar, grid_index);
			return;
		end
	end
end

function UpdateRideCurEuqipOneGrid(grid_index)
	local n = grid_index + 1 - HORSE_EQUIP_INDEX;
	local iconbtn = getglobal("RideFrameCurEquip"..n.."Icon");
	local numtext = getglobal("RideFrameCurEquip"..n.."Count");
	local durbkg = getglobal("RideFrameCurEquip"..n.."DurBkg");
	local durbar = getglobal("RideFrameCurEquip"..n.."Duration");

	if iconbtn then
		UpdateGridContent(iconbtn, numtext, durbkg, durbar, grid_index);
	end
end

--设置格子的选中
function SetRideFrameBoxTexture(btnName)
	for i=1, Ride_Equips_Max_Num do
		local boxTexture = getglobal("EquipRideBoxItem"..i.."BoxTexture");
		boxTexture:Hide();
	end

	for i=1, 2 do
		local boxTexture = getglobal("RideFrameCurEquip"..i.."BoxTexture");
		boxTexture:Hide();
	end

	if btnName ~= nil then
		local boxTexture = getglobal(btnName.."BoxTexture");
		boxTexture:Show();
	end
end

--穿装备
function EquipRideBoxItemPlace(grid_index)
	local type = ClientBackpack:getGridToolType(grid_index);
	local rideEquipIndex = 0;
	if type == 19 or type == 20 then
		rideEquipIndex = HORSE_EQUIP_INDEX + type - 19;
	end
	if rideEquipIndex > 0 then
		CurMainPlayer:swapItem(grid_index, rideEquipIndex);
		SetRideFrameBoxTexture(nil);
	end
end

--脱装备
function RideFrameEquipPlace(grid_index)
	local togrid_index = GetPackFrameFristNullGridIndex();
	if togrid_index ~= -1 then
		CurMainPlayer:swapItem(grid_index, togrid_index);
		SetRideFrameBoxTexture(nil);
	end
end

function UpdateRideFrameSkillTips(skillId)	
	local horseAbilityDef = DefMgr:getHorseAbilityDef(skillId);
	if horseAbilityDef ~= nil then
		getglobal("RideFrameSkillTipsName"):SetText(horseAbilityDef.Name);
		getglobal("RideFrameSkillTipsDesc"):SetText(horseAbilityDef.Desc, 255, 255, 255);
		
		local lines = getglobal("RideFrameSkillTipsDesc"):GetTextLines();
		getglobal("RideFrameSkillTipsDesc"):resizeRichHeight(lines*32);
		getglobal("RideFrameSkillTips"):SetSize(440, 65+lines*31);

		getglobal("RideFrameSkillTips"):Show();
	end	
end

function RideFrameRideSkillTips_OnClick()
	getglobal("RideFrameSkillTips"):Hide();
end

function RideFrameInfoRotateView_OnMouseDown()
	InitModelViewAngle =  getglobal("RideFrameInfoView"):getRotateAngle();
end

function RideFrameInfoRotateView_OnMouseMove()
	local angle = (arg1 - arg3)*1;

	if angle > 360 then
		angle = angle - 360;
	end
	if angle < -360 then
		angle = angle + 360;
	end

	angle = angle + InitModelViewAngle;	
	getglobal("RideFrameInfoView"):setRotateAngle(angle);
end
--------------------------------------------------AccRideCallFrame----------------------------------------------
local Acc_Ride_Max = 128;
function AccRideCallFrameCloseBtn_OnClick()
	getglobal("AccRideCallFrame"):Hide();
	--家园埋点
	Homeland_StandReportSingleEvent("CALL", "Close", "click", {})
end

function AccRideCallFrame_OnLoad()
	for i=1, Acc_Ride_Max do
		local accRideCall = getglobal("AccRideCall"..i);
		if i == 1 then
			accRideCall:SetPoint("left", "AccRideCallBoxPlane", "left", 30, 0);
		else
			accRideCall:SetPoint("left", "AccRideCallBoxPlane", "left", ((i-1)*154)+30, 0);
		end
	end
	this:setUpdateTime(1.0);
end

function AccRideCallFrame_OnUpdate()
	for i=1, Acc_Ride_Max do
		local rideCall = getglobal("AccRideCall"..i);
		local head = getglobal(rideCall:GetName().."Head");
		if rideCall:IsShown() and head:IsGray() then			
			if CurMainPlayer:getAccountHorseLiveAge(rideCall:GetClientID()) >= 0 then
				head:SetGray(false);
			end
		end
	end
end


local t_CanSummonPetInfo = {}
function AccRideCallFrame_OnShow()
	--家园埋点
	Homeland_StandReportSingleEvent("CALL", "-", "view", {})
	Homeland_StandReportSingleEvent("CALL", "Close", "view", {})

	InitCanSummonPetInfo()
	ClientCurGame:setOperateUI(true);
	HideAllFrame("AccRideCallFrame", false);
	UpdateAccRideCall();
	if IsEnableHomeLand and IsEnableHomeLand() then
		--宠物数量
		local petNum = table.getn(t_CanSummonPetInfo)
		--坐骑数量
		local rideNum = AccountManager:getAccountData():getHorseNum()
		if AccountManager:getAccountData().getHorseRealNum then
			rideNum = AccountManager:getAccountData():getHorseRealNum()
		end
		local allhorse, isnew = GetAllHorse()
		local horsenum =  0
		if isnew then
			for k,v in pairs(allhorse) do
				horsenum = horsenum +1
			end
		else
			horsenum = AccountManager:getAccountData():getHorseRealNum();
		end
		rideNum = horsenum
		if rideNum == 0 or petNum == 0  then
			-- getglobal("AccRideCallFrameRideBtn1"):Show()
			-- getglobal("AccRideCallFrameRideBtn2"):Show()
			getglobal("AccRideCallFrameChenDi"):SetPoint("top", "AccRideCallFrameBkg", "bottom", 0, -240)
			if rideNum == 0 then
				AccRideFrame_ShowRideOrPet(2)
			end
			if petNum == 0 then
				AccRideFrame_ShowRideOrPet(1)
			end
		else
			-- getglobal("AccRideCallFrameRideBtn1"):Show()
			-- getglobal("AccRideCallFrameRideBtn2"):Show()
			getglobal("AccRideCallFrameChenDi"):SetPoint("top", "AccRideCallFrameBkg", "bottom", 0, -240)
			--家园埋点
			Homeland_StandReportSingleEvent("CALL", "MountPage", "view", {})
			Homeland_StandReportSingleEvent("CALL", "PetPage", "view", {})
			--AccRideFrame_RideBtnOnClick()
        end
	else--旧版家园版本显示坐骑
		-- getglobal("AccRideCallFrameRideBtn1"):Show()
		-- getglobal("AccRideCallFrameRideBtn2"):Show()
		AccRideFrame_ShowRideOrPet(1)
		getglobal("AccRideCallFrameChenDi"):SetPoint("top", "AccRideCallFrameBkg", "bottom", 0, -240)
    end
    
    AccRideFrame_RideBtnOnClick()
end

function AccRideCallFrame_OnHide()
	ClientCurGame:setOperateUI(false);
	ShowHomeMainUI()

	-- UGC内容重新显示
	GetInst("UGCCommon"):AfterHideAllUI()	
end

function isShapeShiftHorse(horseId)
	-- local t = {[3449]= true, [3451] =true, [3453]=true, [3464]=true, [3466]=true, [3468]=true, [3473]=true, [3475]=true, [3477]=true,[3482]=true,[3494]=true}
	-- return t[horseId];
	local horseDef = DefMgr:getHorseDef(horseId)
	if horseDef and horseDef.HorseType == 1 then
		return true
	end
	return false
end

function UpdateAccRideCall()
	getglobal("AccRideCallBox"):resetOffsetPos();
	local num = AccountManager:getAccountData():getHorseNum();
	if AccountManager:getAccountData().getHorseRealNum then
		num = AccountManager:getAccountData():getHorseRealNum();
	end
	local horsetab, isnew = GetAllHorse()
	local rRideHorseTagList = GetAllHorseQua()
	
	local selectLevels = getkv("player_mounts_select") or {};
	local index = 1;
	if not isnew then
		for i=1, 50 do
			if i <= num then
				local accHorse = AccountManager:getAccountData():getHorse(i-1);
				if not isShapeShiftHorse(accHorse.horseId) and accHorse.horseId > 0 and index <= Acc_Ride_Max then --非变形坐骑
					local rideCall = getglobal("AccRideCall"..index);
					rideCall:Show();
					local head = getglobal(rideCall:GetName().."Head");
					local tagBkg = getglobal(rideCall:GetName().."TagBkg");
					local tag = getglobal(rideCall:GetName().."Tag");
					local name = getglobal(rideCall:GetName().."Name");
					local quaBg = getglobal(rideCall:GetName().."QuaBg");
					local qua = getglobal(rideCall:GetName().."Qua");

					local level = selectLevels[accHorse.horseId] or accHorse.level;
					local realId = accHorse.horseId+level;
					local storeHorseDef = DefMgr:getStoreHorseByID(realId);
					local monsterDef = MonsterCsv:get(realId);
					if storeHorseDef ~= nil and monsterDef ~= nil then
						head:SetTexture("ui/rideicons/"..storeHorseDef.HeadID..".png");
						name:SetText(monsterDef.Name);
						if CurMainPlayer:getAccountHorseLiveAge(realId) < 0 then
							head:SetGray(true);
							tagBkg:SetGray(true);
							tag:SetText(GetS(3505));
						else
							head:SetGray(false);
							tagBkg:SetGray(false);	
							tag:SetText(GetS(3506));
						end
						local HorseTag =  storeHorseDef.HorseTag or nil
						UpdateHorseQua(quaBg,qua,realId,rRideHorseTagList,HorseTag)
					end
					rideCall:SetClientID(realId);

					index = index + 1;
				end
			end
		end
	else
		for k, v in pairs(horsetab) do	
			local key = v.RiderID
			local value = v.RiderLevel
			if not isShapeShiftHorse(key) and key > 0 and index <= Acc_Ride_Max then --非变形坐骑
				local rideCall = getglobal("AccRideCall"..index);
				rideCall:Show();
				local head = getglobal(rideCall:GetName().."Head");
				local tagBkg = getglobal(rideCall:GetName().."TagBkg");
				local tag = getglobal(rideCall:GetName().."Tag");
				local name = getglobal(rideCall:GetName().."Name");
				local quaBg = getglobal(rideCall:GetName().."QuaBg");
				local qua = getglobal(rideCall:GetName().."Qua");

				local level = value;
				if selectLevels[key] and selectLevels[key] < value then
					level = selectLevels[key];
				end

				local realId = key+level;
				local storeHorseDef = DefMgr:getStoreHorseByID(realId);
				local monsterDef = MonsterCsv:get(realId);
				if storeHorseDef ~= nil and monsterDef ~= nil then
					head:SetTexture("ui/rideicons/"..storeHorseDef.HeadID..".png");
					name:SetText(monsterDef.Name);
					if CurMainPlayer:getAccountHorseLiveAge(realId) < 0 then
						head:SetGray(true);
						tagBkg:SetGray(true);
						tag:SetText(GetS(3505));
					else
						head:SetGray(false);
						tagBkg:SetGray(false);	
						tag:SetText(GetS(3506));
					end
					local HorseTag =  storeHorseDef.HorseTag or nil
					UpdateHorseQua(quaBg,qua,realId,rRideHorseTagList,HorseTag)
				end
				rideCall:SetClientID(realId);
				

				index = index + 1;
			end
		end
	end
			

	for i=index, Acc_Ride_Max do
		local rideCall = getglobal("AccRideCall"..i);
		rideCall:Hide();
	end
	
	if index-1 <= 5 then
		getglobal("AccRideCallBoxPlane"):SetSize(800, 220);
	else
		getglobal("AccRideCallBoxPlane"):SetSize(800+30+(index-4)*154, 220);
	end
end

function GetAllHorse()
	local allHorse ={}
	local newFunction = false;
	if AccountManager:getAccountData().getHorse_all then
		local horsetab = AccountManager:getAccountData():getHorse_all()
		SortHorseIdBigToSmall(horsetab)
		local i = 1
		while horsetab[i] do
			if horsetab[i+1] and horsetab[i].RiderID == horsetab[i+1].RiderID then	--移除坐骑id相同的坐骑中等级较小的坐骑
				if horsetab[i].RiderLevel <= horsetab[i+1].RiderLevel then
					table.remove(horsetab,i)
				else
					table.remove(horsetab,i+1)
				end
				i = i - 1 --存在相同id时，需要继续从当前id往后比较
			end
			i = i + 1
		end
		newFunction = true;
		return horsetab, newFunction
	end
	return allHorse, newFunction
end

function SortHorseIdBigToSmall(horsetab)
	table.sort(horsetab,function(a,b)
		return a.RiderID > b.RiderID
	end)
end

--召唤坐骑
function AccRideCallBtnTemplate_OnClick()
	local rideId = this:GetClientID();
	--家园埋点
	Homeland_StandReportSingleEvent("CALL", "MountCard", "click", {standby1=tostring(rideId)})
	local time =  CurMainPlayer:getAccountHorseLiveAge(rideId)/20;
	if time < 0 then
		time = math.ceil(0-time);
		ShowGameTips(GetS(561, time), 3);	
	else
		PlayMainFrameRideBtn_OnClick();
		CurMainPlayer:summonAccountHorse(this:GetClientID());
		getglobal("AccRideCallFrame"):Hide();
	end	
end
--初始化坐骑界面
function AccRideFrame_InitRideFrame(index)
	local tab = {
		{index = 1,name =  GetS(215),nColor = {191,228,227},cColor ={76,76,76}},
		{index = 2,name =  GetS(6571),nColor = {191,228,227},cColor ={76,76,76}},
	}

	for i = 1, #tab do
		local TabType = tab[i]
		local TabBtnName = getglobal("AccRideCallFrameRideBtn"..i.."Name")
		local TabBtnCheck  =  getglobal("AccRideCallFrameRideBtn"..i.."Checked")
		local TabBtnNormal  =  getglobal("AccRideCallFrameRideBtn"..i.."Normal")
		TabBtnName:SetText(TabType.name)
		if i == index then
			TabBtnCheck:Show()
			TabBtnNormal:Hide()
			TabBtnName:SetTextColor(tab[i].cColor[1],tab[i].cColor[2],tab[i].cColor[3])
		else
			TabBtnCheck:Hide()
			TabBtnNormal:Show()
			TabBtnName:SetTextColor(tab[i].nColor[1],tab[i].nColor[2],tab[i].nColor[3])
		end
	end
end

--点击坐骑按钮
function AccRideFrame_RideBtnOnClick()
	--家园埋点
	Homeland_StandReportSingleEvent("CALL", "MountPage", "click", {})
	AccRideFrame_InitRideFrame(1)
    AccRideFrame_ShowRideOrPet(1)
end

--点击宠物按钮
function AccRideFrame_PetBtnOnClick()
	--家园埋点
	Homeland_StandReportSingleEvent("CALL", "PetPage", "click", {})
	AccRideFrame_InitRideFrame(2)
    AccRideFrame_ShowRideOrPet(2)
end

--前往家园
function AccRideCallFrameGotoHomeLandBtn_OnClick()
    --单机或者客机
    if AccountManager:getMultiPlayer() == 0 then
        MessageBox(19, GetS(41856), function(btn)
            if btn == 'left' then
                if IsEnableHomeLand and IsEnableHomeLand() then
                    GoToMainMenu()
					HideLobby()
                    EnterOwnHomeLand()
                end
            end
        end)
    elseif AccountManager:getMultiPlayer() > 0 then
        if IsRoomClient() then
            MessageBox(19, GetS(41856), function(btn)
                if btn == 'left' then
                    if IsEnableHomeLand and IsEnableHomeLand() then
                        GoToMainMenu();
						HideLobby()
                        EnterOwnHomeLand()
                    end
                end
            end)
        elseif IsRoomOwner() then
            MessageBox(19, GetS(41860), function(btn)
                if btn == 'left' then
                    if IsEnableHomeLand and IsEnableHomeLand() then
                        GoToMainMenu();
						HideLobby()
                        EnterOwnHomeLand()
                    end
                end
            end)
        end
    end
end

--前往商店
function AccRideCallFrameGotoShopBtn_OnClick()
    getglobal("AccRideCallFrame"):Hide()     
    if curShowRideOrPetIndex == 2 then         
        GetInst("UIManager"):Open("HomelandShop", {selectType = 5})
    elseif curShowRideOrPetIndex == 1 then
        ShopJumpTabView(4)
    end
end

--显示坐骑或宠物 1 坐骑 2 宠物
function AccRideFrame_ShowRideOrPet(index)
    curShowRideOrPetIndex = index

	if index == 1 then
		getglobal("AccRideCallBox"):Show()
        getglobal("AccRideCallFramePetListView"):Hide()
        getglobal("AccRideCallFrameGotoShopBtn"):Hide()
        getglobal("AccRideCallFrameGotoHomeLandBtn"):Hide()
        getglobal("AccRideCallFramePetTipBkg"):Hide()
        getglobal("AccRideCallFramePetTipStr"):Hide()

        local allhorse, isnew = GetAllHorse()
        local rideNum =  0
		if isnew then
			for k,v in pairs(allhorse) do
				rideNum = rideNum +1
			end
		else
			rideNum = AccountManager:getAccountData():getHorseRealNum();
		end
        
		--MiniBase屏蔽无坐骑跳商店按钮
        if rideNum == 0 and not MiniBaseManager:isMiniBaseGame() then
            getglobal("AccRideCallFrameGotoShopBtn"):Show()
            getglobal("AccRideCallFrameGotoHomeLandBtn"):Hide()
            
            getglobal("AccRideCallFramePetTipBkg"):Show()
            getglobal("AccRideCallFramePetTipStr"):Show()
            getglobal("AccRideCallFramePetTipStr"):SetText(GetS(41859))
        end

		--家园埋点
		Homeland_StandReportSingleEvent("CALL", "MountCard", "view", {})
	else
		getglobal("AccRideCallBox"):Hide()
        getglobal("AccRideCallFramePetListView"):Show()
        getglobal("AccRideCallFrameGotoShopBtn"):Hide()
        getglobal("AccRideCallFrameGotoHomeLandBtn"):Hide()
        getglobal("AccRideCallFramePetTipBkg"):Hide()
        getglobal("AccRideCallFramePetTipStr"):Hide()
        
        local petNum = table.getn(t_CanSummonPetInfo)

		--MiniBase屏蔽无宠物跳家园按钮
        if petNum == 0 and not MiniBaseManager:isMiniBaseGame() then
            if HomelandCallModuleScript("HomelandCommonModule","IsHomeLandWorld") then
                getglobal("AccRideCallFrameGotoShopBtn"):Show()
            else
                getglobal("AccRideCallFrameGotoHomeLandBtn"):Show()
            end

            getglobal("AccRideCallFramePetTipBkg"):Show()
            getglobal("AccRideCallFramePetTipStr"):Show()
            getglobal("AccRideCallFramePetTipStr"):SetText(GetS(41851))
        end

		--家园埋点
		Homeland_StandReportSingleEvent("CALL", "PetCard", "view", {})
        AccRideFrame_RefreshPetList()
	end
end

function InitCanSummonPetInfo()
	t_CanSummonPetInfo = {}
	local allpet = GetInst("HomeLandDataManager"):GetAllPetData()
	for _, v in ipairs(allpet) do
		local state = GetStateByServerId(v.pet_server_id, v)
		--if state == 0 then
			table.insert(t_CanSummonPetInfo, v)
		--end
    end
    
    -- 宠物状态排序：已召唤 > 可召唤 > 不可召唤
    -- 宠物品质排序：传说 > 珍贵 > 稀有 > 普通
    -- 状态排序 > 品质排序
    --state = 0可召唤
    --state = 1/2不可召唤
    --state = 3已召唤
    table.sort(t_CanSummonPetInfo, function(a, b) 
        local stateA = GetStateByServerId(a.pet_server_id, a)
        local stateB = GetStateByServerId(b.pet_server_id, b)

        --品质索引
        local qualityIndexA = a.pet_quality + 1
        local qualityIndexB = b.pet_quality + 1

        if stateA == stateB then
            return qualityIndexA > qualityIndexB
        else
            if stateA == 3 or stateB == 3 then
                return stateA > stateB
            elseif stateA == 0 or stateB == 0 then
                return stateA < stateB
            else
                return stateA > stateB
            end   
        end

        return true
    end)

end
function AccRideCallFramePetListView_tableCellAtIndex(tableView, idx)
	local templateName = "AccPetCallBtnTemplate"
	local tableViewName = "AccRideCallFramePetListView"
	local typeName = "Button"
	local cell, uiidx = tableView:dequeueCell(0,templateName)
	if not cell then
		local itemName = table.concat({tableViewName,"Item",uiidx})--组合防止全局重名
		cell = UIFrameMgr:CreateFrameByTemplate(typeName,itemName,templateName,tableViewName)
	end
	cell:Show()
	cell:SetClientID(idx)

	local petCount = table.getn(t_CanSummonPetInfo)
    local head = getglobal(cell:GetName().."Head")
    local headBkg = getglobal(cell:GetName().."HeadBkg")
	local name = getglobal(cell:GetName().."Name")
    local tag = getglobal(cell:GetName().."Tag")
    local tagBkg = getglobal(cell:GetName().."TagBkg")
    local CancelCallPetBtn = getglobal(cell:GetName().."CancelCallPetBtn")
    local nameBkg = getglobal(cell:GetName().."NameBkg")
    local grayHeadBkg = getglobal(cell:GetName().."GrayHeadBkg")
    CancelCallPetBtn:SetClientID(idx)

	if petCount > 0 then
		local petData = t_CanSummonPetInfo[idx+1]
        if petData then
            local state = GetStateByServerId(petData.pet_server_id, petData)
            local index = idx+1

            --品质索引
            local qualityIndex = petData.pet_quality + 1

            --普通
            if qualityIndex == 1 then
                nameBkg:SetTextureHuiresXml("ui/mobile/texture0/room.xml")
                nameBkg:SetTexUV("img_board_load")  
            --稀有
            elseif qualityIndex == 2 then
                nameBkg:SetTextureHuiresXml("ui/mobile/texture0/common.xml")
                nameBkg:SetTexUV("img_board_load_blue")  
            --珍贵
            elseif qualityIndex == 3 then
                nameBkg:SetTextureHuiresXml("ui/mobile/texture0/common.xml")
                nameBkg:SetTexUV("img_board_load_purple")          
            --传说
            elseif qualityIndex == 4 then
                nameBkg:SetTextureHuiresXml("ui/mobile/texture0/common.xml")
                nameBkg:SetTexUV("img_board_load_orange")    
            end

            --可召换
            if state == 0 then
                tag:SetText(GetS(3506))

                tagBkg:SetTextureHuiresXml("ui/mobile/texture2/shop.xml")
                tagBkg:SetTexUV("label_shop_time")

                --隐藏取消召唤按钮
                getglobal("AccRideCallFramePetListViewItem"..index.."CancelCallPetBtn"):Hide()
            --探险中
            elseif state == 1 or state == 2 then
                tag:SetText(GetS(41855))

                tagBkg:SetTextureHuiresXml("ui/mobile/texture2/shop.xml")
                tagBkg:SetTexUV("label_shop_time")
                -- headBkg:SetGray(true)
                -- head:SetGray(true)
                tagBkg:SetGray(true)
                grayHeadBkg:Show()

                nameBkg:SetTextureHuiresXml("ui/mobile/texture0/common.xml")
                nameBkg:SetTexUV("img_board_load_disable")    

                --隐藏取消召唤按钮
                getglobal("AccRideCallFramePetListViewItem"..index.."CancelCallPetBtn"):Hide()
            --已召唤
            elseif state == 3 then
                tag:SetText(GetS(41854))

                tagBkg:SetTextureHuiresXml("ui/mobile/texture2/shop.xml")
                tagBkg:SetTexUV("label_shop_green")

                --显示取消召唤按钮
                getglobal("AccRideCallFramePetListViewItem"..index.."CancelCallPetBtn"):Show()
            end


			local petDef = DefMgr:getPetDef(petData.pet_id,petData.pet_state,petData.pet_quality)
			local monsterDef = MonsterCsv:get(petDef.MonsterID)
			if petDef and monsterDef then
				name:SetText(petData.examine_state and petData.pet_name or monsterDef.Name)
				local path = split(petDef.HeadIcon,".")
				if path and #path > 0 and path[1] and path[2] then
					head:SetTexture("ui/"..path[1].."/"..path[2]..".png")
				end
			end
		end	
	end
	return cell
end

function AccRideCallFramePetListView_numberOfCellsInTableView(tableView)
	local count = table.getn(t_CanSummonPetInfo)
	return count
end

function AccRideCallFramePetListView_tableCellSizeForIndex(tableView, index)
	local count = table.getn(t_CanSummonPetInfo)
	local colidx = math.mod(index, count)
	return (30+154 *colidx),0,132,180
end

function AccRideCallFramePetListView_tableCellWillRecycle(tableView, cell)
	if cell then cell:Hide() end
end

function AccRideFrame_RefreshPetList()
	local listview =  getglobal("AccRideCallFramePetListView")
	local listviewPlane =  getglobal("AccRideCallFramePetListViewPlane")
	local listWidth = listview:GetRealWidth2()
	local listHeight = listview:GetRealHeight2()
	local count = table.getn(t_CanSummonPetInfo)
	listview:initData(listWidth,listHeight,1,count,false)
	local Width = 158 * count
	listviewPlane:SetWidth(math.max(Width,listWidth))
	listviewPlane:SetPoint("left", "AccRideCallFramePetListView", "left", 0, 0)
end

function AccPetCallBtnTemplate_OnClick()
	local petIndex = this:GetClientID() + 1
	local data = t_CanSummonPetInfo[petIndex]
	if data == nil then
		return
    end
    
    local state = GetStateByServerId(data.pet_server_id, data)

    --探险中
    if state == 1 or state == 2 then
        ShowGameTipsWithoutFilter(GetS(41555), 3)

        return
    --已召唤
    elseif state == 3 then
        return
    end

	--根据宠物表对于的MonsterID
	local petDef = DefMgr:getPetDef(data.pet_id,data.pet_state,data.pet_quality)
	local monsterDef = MonsterCsv:get(petDef.MonsterID)
	if petDef and monsterDef then
		local userdata = {
			MonsterID = petDef.MonsterID,
			Serverid = data.pet_server_id,
			CarryState = 3,
			Petid = data.pet_id,
			PetState = data.pet_state,
            PetQuality = data.pet_quality,
			PetName = data.examine_state and data.pet_name or monsterDef.Name
		}
		GetInst("HomeLandService"):ReqSummonPet(data.pet_server_id,3,nil,userdata)
	end
	getglobal("AccRideCallFrame"):Hide()
	--家园埋点
    Homeland_StandReportSingleEvent("CALL", "PetCard", "click", {standby1=tostring(data.pet_id)})
    
    --显示取消召唤按钮
    getglobal("AccRideCallFramePetListViewItem"..petIndex.."CancelCallPetBtn"):Show()

    local tag = getglobal("AccRideCallFramePetListViewItem"..petIndex.."Tag")
    local tagBkg = getglobal("AccRideCallFramePetListViewItem"..petIndex.."TagBkg")

    tag:SetText(GetS(41854))
    tagBkg:SetTextureHuiresXml("ui/mobile/texture2/shop.xml")
    tagBkg:SetTexUV("label_shop_green")

    InitCanSummonPetInfo()
end

--取消召唤
function AccRideCallFrameCancelCallPetBtn_OnClick()
	local petIndex = this:GetClientID() + 1
	local curPetData = t_CanSummonPetInfo[petIndex]
	if curPetData == nil then
		return
    end
    
    local state = GetStateByServerId(curPetData.pet_server_id, curPetData)

    --已召唤state为3
    if state ~= 3 then
        --提示
        --ShowGameTipsWithoutFilter(GetS(41555), 3)
        return
    end

	if curPetData and next(curPetData) then
        local function summonpetCallBack(data)
            if data then
                getglobal("AccRideCallFrame"):Hide()
                ShowGameTipsWithoutFilter(GetS(41857), 3)

                --隐藏取消召唤按钮
                getglobal("AccRideCallFramePetListViewItem"..petIndex.."CancelCallPetBtn"):Hide()
                GetInst("HomeLandDataManager"):UpdatePetData(data)
                
                local tag = getglobal("AccRideCallFramePetListViewItem"..petIndex.."Tag")
                local tagBkg = getglobal("AccRideCallFramePetListViewItem"..petIndex.."TagBkg")
                tag:SetText(GetS(3506))
                tagBkg:SetTextureHuiresXml("ui/mobile/texture2/shop.xml")
                tagBkg:SetTexUV("label_shop_time")

                InitCanSummonPetInfo()
            end
        end

		local petDef = DefMgr:getPetDef(curPetData.pet_id,curPetData.pet_state,curPetData.pet_quality)
		if petDef then
			local userdata = {
				MonsterID = 0,
				Serverid = "",
				CarryState = 0,
				Petid = curPetData.pet_id,
				PetState = curPetData.pet_state,
				PetQuality = curPetData.pet_quality
			}
			GetInst("HomeLandService"):ReqSummonPet(curPetData.pet_server_id,0,summonpetCallBack,userdata)
		end
	end
end

--读取配置表获取坐骑品质
function GetAllHorseQua()
	local rRideHorseTagList = {}
	local int_version = ClientMgr:clientVersionFromStr(ClientMgr:clientVersion()) --当前版本号 int类型
	if ns_version.rider_setting and next(ns_version.rider_setting) then
		for i = 1, #ns_version.rider_setting do
			local version_tabel = ns_version.rider_setting[i]
			local int_version_tag = ClientMgr:clientVersionFromStr(version_tabel.version_tag)	
			if int_version >= int_version_tag then
				table.insert(rRideHorseTagList, version_tabel)
			end
		end	
	end
	return rRideHorseTagList
end

--寻找指定坐骑品质并更新
function FindHorseQua(horseIdAndLv,rideHorseTagList)
	local qua = 0
	for i=1, #(rideHorseTagList) do
		if rideHorseTagList[i].horseid == horseIdAndLv then
			qua = rideHorseTagList[i].horseTag
			break;
		end
	end
	return qua
end

--更新坐骑稀有度标签
function UpdateHorseQua(quaBg, qua, horseIdAndLv, rideHorseTagList,HorseTag)
	local configTag = FindHorseQua(horseIdAndLv, rideHorseTagList)
	local tag = configTag ~= 0 and configTag or HorseTag
	local horseQua = {
        [1] = {name = "稀有", uvName = "label_quality_blue"}, --稀有
        [2] = {name = "珍贵", uvName = "label_quality_purple"}, --珍贵
        [3] = {name = "传说", uvName = "label_quality_orange"}, --传说
        [4] = {name = "典藏", uvName = "label_quality_colourful"} --典藏
    }
	if not tag or tag < 1 or tag > 4 then
		quaBg:Hide()
		qua:Hide()
	else
		quaBg:Show()
		qua:Show()
		quaBg:SetTexUV(horseQua[tag].uvName)
		qua:SetText(horseQua[tag].name)
	end
	
end