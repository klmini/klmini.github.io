local MAX_ACTION_CUT_NUM = 8

local MAX_ACTION_LIBRARY_NUM = 10

local currentSelectActionShortBan = 0         --当前选择的动作栏
local currentSelectActionLibrary = 0     --当前选择的动作库栏

local isBeInvite = false 				--是不是被邀请列表
local isRefuseCurPlayer = false 		--是否拒绝了当前玩家3小时内邀请

local actorInviteTable = {}     		--互动装扮可邀请人列表
local beInviteTable = {}    			--互动装扮受邀请人列表
local briefInfos = {}					--联机房间玩家列表
local allTimerId = {}					--所有计时器

local transferCoolTime = 15 --变身动作冷却时间
local schedulerTransfer = nil
local bolTransfered = false --是否已触发变身
local recordTransferTime = 0
local haveDressNums = 0 --当前玩家拥有的装扮
local leastDressNums = 3 --最少拥有装扮套数
local actHappy2Def --高兴2的配置
local bolReportSpecial = false;

local schedulerTransferSpecUi = nil --变身特殊ui定时器
local countTime = 3600 --每个小时出现一次
local recordCountTime = 0 --记录时间
local countDismissTime = 20 --20秒显示特殊ui
local bolShowSpecUI = true

local transferIndex = 0 --变身后缓存下标标记

-- 玩家是否拥有该皮肤
local function AccountHasSkin(skinID)
	return AccountManager:getAccountData():getSkinTime(skinID) ~= 0
end

--被邀请目标玩家的指定动作是否拥有对应装扮
local function CheckOtherSkinIdByActId(targetUin,actId)
	local hasTargetSkin = false
	local targetSkinId = 0--目标玩家皮肤id
	local otherPlayer = CurWorld:getActorMgr():findPlayerByUin(targetUin)
	if otherPlayer ~= nil and otherPlayer.getSkinID then
		targetSkinId = otherPlayer:getSkinID()
	end
	local num = DefMgr:getPlayActDefNum();
	for i=1,num do
		local def = DefMgr:getPlayActDefByIndex(i-1);
		if def and def.ID == actId then
			--检测被邀请玩家装扮是否匹配 或为 通用装扮
			if def.SkinID2 == targetSkinId or def.SkinID2 == 1 then 
				hasTargetSkin = true
				break;
			end
		end
	end
	return hasTargetSkin;
end

--装扮互动邀请列表数据
local listConfig = {
	GoodCell_Rows = 1,
	GoodCell_Cols = 1,
	GoodCell_Width = 240,
	GoodCell_Height = 49,
	GoodCell_TemplateName = "ActorInviteItemTemplate",
	GoodList_Width = 718,
	GoodList_Height = 50,
	GoodList_Name = "PhraseLibraryFrameActorInviteList",
}

--动作快捷栏表
local ActionShortCutTable = {
	-- Id = {100102,100103,100131,100133,100140,100155,100157,100158}
}

--动作表情库表
local ActionLibraryTable = {
	-- Id = {100102,100103,100131,100133,100140,100155,100157,100158,100157,100159,100162,100163}
}

-- local test = {}

local UserActionSetData= {1,2,3,4,5,6,7,8};

--刷新表情库列表
function UpdataActionLibraryTable()
	ActionLibraryTable = nil
	ActionLibraryTable = {}

	local skinID = 0  --当前皮肤id
	if CurMainPlayer ~= nil and CurMainPlayer.getSkinID then
		skinID = CurMainPlayer:getSkinID()
	end

	local num = DefMgr:getPlayActDefNum();
	for i=1,num do
		local def = DefMgr:getPlayActDefByIndex(i-1);
		if def and def.InGame == 1 and ((def.SkinType and 0 == def.SkinType 
				and def.SkinID and 0 ~= def.SkinID and skinID == def.SkinID) 
				or 0 == def.SkinID) then
			if def.ID == 26 then 
				actHappy2Def = def;
			else--高兴2表情不需要加入
				table.insert(ActionLibraryTable,def);
			end
		end
		
	end
end

local function sortActionShortTableByWeight(bol)
	local arrTemp = {}
	for index, value in ipairs(ActionLibraryTable) do
		table.insert(arrTemp, value)
	end
	--从大到小排序
	table.sort(arrTemp, function(a,b)
		if a.SortWeight == b.SortWeight then
			return a.ID < b.ID 
		else
			return a.SortWeight < b.SortWeight
		end
	end)
	for i=1,MAX_ACTION_CUT_NUM do
		table.insert(ActionShortCutTable,arrTemp[i]);
	end
end

--刷新动作快捷栏表 bolShow是否显示聊天表情ui
function loadActionBarData(bolShow)
	local data = getkv("user_action_set");
	local skinID = 0
	if CurMainPlayer ~= nil and CurMainPlayer.getSkinID then
		skinID = CurMainPlayer:getSkinID()
	end

	ActionShortCutTable = nil
	ActionShortCutTable = {}
	
	print("loadActionBarData", skinID)
	if data == nil then
		sortActionShortTableByWeight(bolShow)
	else
		local uin = CurMainPlayer and CurMainPlayer:getUin() or 0
		if bolShow and getkv("user_action_transfer"..uin) == nil then
			data[1] = 25;
			setkv("user_action_transfer"..uin,1);
		end
		
		for i=1,MAX_ACTION_CUT_NUM do
			if i <= #data then
				local actDef = DefMgr:getPlayActDef(data[i])
				if actDef and ((actDef.SkinType and 0 == actDef.SkinType 
				and actDef.SkinID and 0 ~= actDef.SkinID and skinID == actDef.SkinID)
				or 0 == actDef.SkinID) then
					table.insert(ActionShortCutTable, actDef);
				end
			end
		end

		print("loadActionBarData", #ActionShortCutTable, MAX_ACTION_CUT_NUM)
		if #ActionShortCutTable < MAX_ACTION_CUT_NUM then
			local tempAc = {}
			for i=1,#ActionLibraryTable do
				local isHas = false
				for j=1, #ActionShortCutTable do
					if ActionShortCutTable[j].ActID == ActionLibraryTable[i].ActID then
						isHas = true
					end
				end

				if not isHas then
					table.insert(tempAc, ActionLibraryTable[i].ID)
				end
			end

			print("loadActionBarData2", tempAc, #ActionShortCutTable)
			if tempAc and #tempAc > 0 then
				for i=#ActionShortCutTable+1, MAX_ACTION_CUT_NUM do
					table.insert(ActionShortCutTable, DefMgr:getPlayActDef(tempAc[i - #ActionShortCutTable]));
				end
			end
		end

		if IsAccountLastTimeUsedSkin() then
			local index = 0
			--皮肤切换后，存在互动动作，则将互动动作替换至首位
			for k, v in ipairs(ActionLibraryTable) do
				if v.SkinID2 > 0 then
					index = index + 1
					table.remove(ActionShortCutTable,index)
					table.insert(ActionShortCutTable,index,v)
					break;
				end
			end
			for i=1,MAX_ACTION_CUT_NUM do
				UserActionSetData[i] = ActionShortCutTable[i].ID;
			end
			setkv("user_action_set",UserActionSetData);
		end
		
	end
end

function CharacterActionFrame_OnLoad()
	UpdataActionLibraryTable()

	for i=1,MAX_ACTION_CUT_NUM do
		local  shortAction = getglobal("ExpressionShortcut"..i);
		shortAction:SetPoint("left","CharacterActionFrame","left", (i - 1) * 76 + 68, -2)
		shortAction:SetSize(64,64);
	end
end

--变身后发送数据
function OnTransferSendData()
	local tblSkinList,lenSkin = GetSkins()
	local len = #tblSkinList;
	if len == 0 then
		return;
	end

	if transferIndex ~= 0 then
		local index =  transferIndex

		local skinDef;
		local aSkinSeatInfo;
		local avatrName;

		if lenSkin > 0 and index <= lenSkin then
			skinDef =  tblSkinList[index];
			avatrName = skinDef.Name;
			--GetInst("UIManager"):GetCtrl("Shop"):UseSkin(1,{isUsed = false,skinDef = skinDef, callback = callback });
			if AccountManager:useRoleSkinModel(skinDef.ID) then
				--刷新角色当前使用的定制皮肤坑位信息
				GetInst("ShopDataManager"):InitPlayerUsingSeatInfo()
				RefreshMapArchiveListRoleView()
			end
--[[			else
			aSkinSeatInfo = tblSkinList[index];
			avatrName = aSkinSeatInfo.def.name;
			if avatrName == nil or avatrName == "" then
				avatrName = GetS(15305);
			end
			GetInst("UIManager"):GetCtrl("Shop"):UseSkin(3,{skinSeatInfo = aSkinSeatInfo,noTips = nil, callback = callback});--]]
		end
		transferIndex = 0
	end
end

function CharacterActionFrame_OnShow()
	local isPC = ClientMgr:isPC() or false
	for i=1,MAX_ACTION_CUT_NUM do
		local shortTagNum = getglobal("ExpressionShortcut"..i.."Num");
		local shortAction = getglobal("ExpressionShortcut"..i);
		local shortBan =getglobal("ExpressionShortcut"..i.."Ban")

		if isPC then
			shortAction:SetPoint("left","CharacterActionFrame","left",(i - 1) * 58 + 52, -2)
			shortAction:SetSize(52,52);
		else
			shortAction:SetPoint("left","CharacterActionFrame","left",(i - 1) * 76 + 70, -2)
			shortAction:SetSize(64,64);
			getglobal("CharacterActionFrameBkgTriangle"):SetPoint("top","CharacterActionFrame","top",-320,74);
		end
		
		shortTagNum:Hide();
		shortBan:Hide();
	end

	for i=1,MAX_ACTION_CUT_NUM do
		getglobal("ExpressionShortcut"..i.."Check"):Hide();
	end

	-- 搭建模式快捷栏更大 需要往上偏移
	local caFrame = getglobal("CharacterActionFrame")
	if caFrame then
		if IsUGCEditing() and UGCModeMgr:GetGameType() == UGCGAMETYPE_BUILD and isPC then
			caFrame:SetPoint("bottom", "PlayShortcut", "top", -112, -26)
		else	
			caFrame:SetPoint("bottom", "PlayShortcut", "top", -22, -6)
		end
	end

	--刷新数据
	loadActionBarData(true)
	updataActionBarData();
	showActionBarReddot();


	displayActionBarHideViewUI();
	-- getglobal("PcGuideKeySightMode"):Hide();
	local riddlesUI = GetInst("MiniUIManager"):GetUI("MiniUIRiddlesMain");
	if not riddlesUI then
		getglobal("PhraseLibraryFrame"):Show();
		CharacteractionChangeSkin(false);
	end
	
	getglobal("PhraseLibraryFrameMask"):Show();

	--家园埋点
	Homeland_StandReportSingleEvent("PHRASE", "-", "view", {})
	Homeland_StandReportSingleEvent("PHRASE", "ExpressionArea", "view", {})
	Homeland_StandReportSingleEvent("PHRASE", "ExpressionSetting", "view", {})
	Homeland_StandReportSingleEvent("PHRASE", "ShortcutPhraseClose", "view", {})

	--打开地图游戏埋点
	standReportEvent(getReportSceneID(), "MINI_QUICK_WORD", "-", "view")
	standReportEvent(getReportSceneID(), "MINI_TOOL_BAR", "-", "view")
	standReportEvent(getReportSceneID(), "MINI_TOOL_BAR", "ExpressionButton", "view")

	CharacteractionStartScedelerTransfer();

	reportCharacteractionStandData("CharacterAction","view");
end

function CharacteractionStartScedelerTransfer()
	if schedulerTransfer == nil then
		schedulerTransfer = GetInst("MiniUIScheduler"):regGloabel(function()
			if bolTransfered == true then
				recordTransferTime = recordTransferTime + 1;
			end
		end, 1, nil, 0, false);
	end
end


function CharacterActionFrame_OnHide()
	currentSelectActionShortBan = 0;
	
	if CurMainPlayer:getCurToolID() == ITEM_COLORED_GUN or CurMainPlayer:getCurToolID() == ITEM_COLORED_EGG or CurMainPlayer:getCurToolID() == ITEM_COLORED_EGG_SMALL  then
		getglobal("GunMagazine"):Show();
	end
	for i=1,7 do
		if CurMainPlayer:getCurToolID() == 14999+i or CurMainPlayer:getCurToolID() == 12587 then
			getglobal("GunMagazine"):Show();
		end
	end

	getglobal("PhraseLibraryFrame"):Hide()
	getglobal("PhraseLibraryFrameMask"):Hide();
	getglobal("CharacterTipsFrame"):Hide();
end

function CharacterActionFrameExpandActionBtn_OnClick()
	reportCharacteractionStandData("EditCharacterAction","click");
	getglobal("ActionLibraryFrame"):Show();
	getglobal("PhraseLibraryFrame"):Hide();
	getglobal("CharacterTipsFrame"):Hide();
	--家园埋点
	Homeland_StandReportSingleEvent("PHRASE", "ExpressionSetting", "click", {})
	--打开地图游戏埋点
	local isFirst = getkv("ExpressionButton_click") and 1 or 0
	standReportEvent(getReportSceneID(), "MINI_TOOL_BAR", "ExpressionButton", "click",{standby1 = isFirst})
	setkv("ExpressionButton_click", true)
end

--跳转到商店定制库界面
function CharacterActionGotoShopBtn_OnClick()
	reportCharacteractionStandData("AvatarButton","click");
	ShopJumpTabView(3);
end

function displayActionLibraryViewUI()
	getglobal("CharacterActionFrameBkgTriangle"):Hide();
	getglobal("CharacterActionFrameExpandActionBtn"):Hide();
	getglobal("CharacterActionFrameBkg"):Hide();
end

function displayActionBarHideViewUI()
	getglobal("CharacterActionFrameBkgTriangle"):Show();
	getglobal("CharacterActionFrameExpandActionBtn"):Show();
	reportCharacteractionStandData("EditCharacterAction","view");
	getglobal("CharacterActionFrameBkg"):Show();

	getglobal("PcGuideKeySightMode"):Hide();

end






---------------------------------------------------动作表情库-----------------------------------------------------

local MAX_ACTION_NUM = 64;  --动作库格子最大数

function ActionLibraryFrame_OnLoad()

	-- if ClientMgr:isPC() then
	-- 	for i=1,MAX_ACTION_NUM/8 do
	-- 		for j=1,8 do
	-- 			local item = getglobal("ActionLibraryBoxItem"..((i-1)*8+j));
	-- 			-- local itemColor = getglobal("SignalParserBoxItem"..((i-1)*8+j).."Y");
	-- 			item:SetPoint("topleft", "ActionLibraryBoxPlane", "topleft", (j - 1) * 83 - 50, (i - 1) * 88 + 17);
	-- 			-- item:SetSize(73,73);
	-- 			-- item:Hide();
	-- 		end
	-- 	end
	-- else
	-- 	for i=1,MAX_ACTION_NUM/8 do
	-- 		for j=1,8 do
	-- 			local item = getglobal("ActionLibraryBoxItem"..((i-1)*8+j));
	-- 			-- local itemColor = getglobal("SignalParserBoxItem"..((i-1)*8+j).."Y");
	-- 			item:SetPoint("topleft", "ActionLibraryBoxPlane", "topleft", (j)*79-23, (i-1)*88+17);
	-- 			-- item:SetSize(71,71);
	-- 			-- item:Hide();
	-- 		end
	-- 	end
	-- end

	for i = 1, MAX_ACTION_NUM do
		local row = math.ceil(i / 8);
		local col = (i - 1) % 8 + 1;

		local item = getglobal("ActionLibraryBoxItem" .. i);
		item:SetPoint("topleft", "ActionLibraryBoxPlane", "topleft", 26 + (col - 1) * 94, 10 + (row - 1) * 96);
	end

	--标题栏
	getglobal("ActionLibraryFrameTitleName"):SetText(GetS(10541));
end

function ActionLibraryFrame_OnShow()
	local isPC = ClientMgr:isPC() or false
	for i=1,MAX_ACTION_CUT_NUM do
		local shortAction = getglobal("ExpressionShortcut"..i);
		local shortTagNum = getglobal("ExpressionShortcut"..i.."Num");
		local shortBan = getglobal("ExpressionShortcut"..i.."Ban")

		if isPC then 
			shortTagNum:Show();
			shortAction:SetPoint("bottomleft","ActionLibraryFrameBkg","bottomleft", (i - 1) * 93 + 46, -20)
			shortTagNum:SetText("ctrl+"..i);
			shortBan:Hide();
		else
			shortTagNum:Hide();
			shortAction:SetPoint("bottomleft","ActionLibraryFrame","bottomleft", (i - 1) * 93 + 46, -20)
		end
		
		shortAction:SetSize(83,83);
	end
	-- SetItemIcon(getglobal("ExpressionShortcut1Icon"),)
	
	--刷新数据
	UpdataActionShow()

	for i=1,#ActionLibraryTable do
		getglobal("ActionLibraryBoxItem"..i.."Check"):Hide();
	end
	--打勾
	for i=1,#ActionLibraryTable do
		getglobal("ActionLibraryBoxItem"..i.."Tick"):Hide();
	end

	for i=1,MAX_ACTION_CUT_NUM do
		for j=1,#ActionLibraryTable do
			local tick = getglobal("ActionLibraryBoxItem"..j.."Tick");
			-- if is_include(ActionLibraryTable[i].ID,ActionShortCutTable) then
			if ActionShortCutTable[i].ActID == ActionLibraryTable[j].ActID then
				tick:Show();
			end
		end
	end

	displayActionLibraryViewUI();
end

--刷新显示
function UpdataActionShow()
	UpdataActionDate()
	updataActionBarData();
	updataActionLibraryData();
end

function UpdataActionDate()
	UpdataActionLibraryTable()
	loadActionBarData(false)
end

function ActionLibraryFrame_OnHide()
	getglobal("CharacterActionFrame"):Show();

	currentSelectActionLibrary = 0;
end

function CharacterActionFrame_OnUpdate()
	--临时方案
	if getglobal("CharacterActionFrame"):IsShown() then
		-- getglobal("PlayerExpBar"):Hide(); --星星
		getglobal("GunMagazine"):Hide(); --子弹
	end
end

function ActionLibraryBox_OnMouseDown()
	UIEndDrag("MousePickItem");
end

function ActionLibraryFrame_OnClick()
	if ClientMgr:isPC() then
		UIEndDrag("MousePickItem");
		if currentSelectActionLibrary > 0 then
			getglobal("ActionLibraryBoxItem"..currentSelectActionLibrary.."Check"):Hide();
			currentSelectActionLibrary = 0;
		end
	end
end

--更新动作栏数据
function updataActionBarData()
	for i=1,MAX_ACTION_CUT_NUM do
		local icon = getglobal("ExpressionShortcut"..i.."Icon")
		icon:SetTexture("ui/animact/"..ActionShortCutTable[i].icon..".png")
	end
end

--更新动作库数据
function updataActionLibraryData()
	local locAlTab = ActionLibraryTable
	print("updataActionLibraryData4", locAlTab)
	for i=1, MAX_ACTION_NUM do
		local item = getglobal("ActionLibraryBoxItem"..i);
		item:Hide();
		if i<= #locAlTab then
			local icon = getglobal("ActionLibraryBoxItem"..i.."Icon")
			local check = getglobal("ActionLibraryBoxItem"..i.."Check")
			local tick = getglobal("ActionLibraryBoxItem"..i.."Tick")
			icon:SetTexture("ui/animact/"..locAlTab[i].icon..".png")
			item:Show()
		end
	end
end

--根据id返回ActionLibraryTable的项
local function getActionLibraryItem(id)
	local locAlTab = ActionLibraryTable
	for i=1, MAX_ACTION_NUM do
		if locAlTab[i].ID == id then
			return locAlTab[i]
		end
	end
	return nil
end

--搜索并显示邀请列表
local function checkAndShowInviteList(actIndex)
	--装扮互动冷却时间
	if isActorInviteBtnCoolingTime then
		return;
	end
	--互动范围内玩家列表
	CurMainPlayer:scanSkinActActorList()
	local playerNum = CurMainPlayer:getSkinActPlayerNum() or 0
	for k in pairs (actorInviteTable) do 
		actorInviteTable[k] = nil 
	end 
	for i = 1, playerNum do
		local targetUin = CurMainPlayer:getSkinActPlayerUinByIndex(i-1)
		local actId = ActionShortCutTable[actIndex].ID;
		--仅显示有对应副装扮的可邀请玩家
		if CheckOtherSkinIdByActId(targetUin,actId) then
			local temArr = {}
			temArr.targetUin = targetUin
			temArr.actId = actId
			table.insert(actorInviteTable,temArr)
		end
	end
	if #actorInviteTable > 0 then
		ShowActorInvite(false)
	else
		PhraseLibraryFrameShowPharse(false)
		ShowGameTips(GetS(15283), 3);
	end
	standReportEvent(getReportSceneID(), "MINI_QUICK_WORD", "interaction", "click",{standby1 = ActionShortCutTable[actIndex].ID})
end


function ActionButtonTemplate_OnClick()
	local num = tonumber(string.sub(this:GetName(),21,-1));

	for i=1,#ActionLibraryTable do
		getglobal("ActionLibraryBoxItem"..i.."Check"):Hide();
	end
	getglobal("ActionLibraryBoxItem"..num.."Check"):Show();

	currentSelectActionLibrary = num;

	if ClientMgr:isPC() then
		local iconbtn = getglobal("MousePickItemIcon");
		-- iconbtn:SetSize(54,54)；
		iconbtn:SetTexture("ui/animact/"..ActionLibraryTable[num].icon..".png", true) 
		UIBeginDrag("MousePickItem", -40, -40);
	end
end


function ActionShortCutButtonTemplate_OnClick()
	local num = tonumber(string.sub(this:GetName(),19,-1));

	for i=1,MAX_ACTION_CUT_NUM do
		getglobal("ExpressionShortcut"..i.."Check"):Hide();
	end
	getglobal("ExpressionShortcut"..num.."Check"):Show();
	local uin = CurMainPlayer and CurMainPlayer:getUin() or 0
	if getkv("user_action_transfer"..uin) == nil then
		setkv("user_action_transfer"..uin,1);
	end
	local beforeSelectActionShortBan = currentSelectActionShortBan;
	currentSelectActionShortBan = num;

	if currentSelectActionLibrary ~= 0 then
		if ClientMgr:isPC() then
			UIEndDrag("MousePickItem");
		end
		-- 如果有相同的
		for i=1,MAX_ACTION_CUT_NUM do
			if ActionLibraryTable[currentSelectActionLibrary].ActID == ActionShortCutTable[i].ActID then
				-- ShowGameTips("存在相同表情",3);
				swapAcyionFailure(i);
				return;
			end
		end

		ActionShortCutTable[num] = ActionLibraryTable[currentSelectActionLibrary];

		for i=1,MAX_ACTION_CUT_NUM do
			UserActionSetData[i] = ActionShortCutTable[i].ID;
		end

		--更新动作快捷栏
		updataActionBarData();
		swapActionSuccess();

		setkv("user_action_set",UserActionSetData);
		currentSelectActionLibrary = 0;
		currentSelectActionShortBan = 0;
		return;
	elseif beforeSelectActionShortBan ~= 0 and currentSelectActionShortBan ~= 0 and getglobal("ActionLibraryFrame"):IsShown() then
		--动作快捷栏互换位置
		local tempTable1 = ActionShortCutTable[currentSelectActionShortBan];
		local tempTable2 = ActionShortCutTable[beforeSelectActionShortBan];
		ActionShortCutTable[currentSelectActionShortBan] = tempTable2;
		ActionShortCutTable[beforeSelectActionShortBan] = tempTable1;

		updataActionBarData();

		if ClientMgr:isPC() then
			UIEndDrag("MousePickItem");
		end

		for i=1,MAX_ACTION_CUT_NUM do
			UserActionSetData[i] = ActionShortCutTable[i].ID;
		end

		setkv("user_action_set",UserActionSetData);
		beforeSelectActionShortBan = 0;
		currentSelectActionShortBan = 0;
	elseif not getglobal("ActionLibraryFrame"):IsShown() then
		--点击闪一下
		local shortCheck = getglobal("ExpressionShortcut"..currentSelectActionShortBan.."Check");
		local RedDot = getglobal("ExpressionShortcut"..currentSelectActionShortBan.."RedDot")
		RedDot:Hide()
		shortCheck:Hide();
		threadpool:wait(0.1);
		shortCheck:Show();
		threadpool:wait(0.1);
		shortCheck:Hide();
	end

	if CurMainPlayer ~= nil and not getglobal("ActionLibraryFrame"):IsShown() then
		--装扮互动
		if ActionShortCutTable[num].SkinID2 and ActionShortCutTable[num].SkinID2  > 0 then
			checkAndShowInviteList(num)
		else	
			if ActionShortCutTable[num].ID == 25 then  --变身动作 rice
				CharacteractionPlayTransferAct(num);
			else
				CurMainPlayer:playAct(ActionShortCutTable[num].ID);
			end
			PhraseLibraryFrameShowPharse(false) --避免点击埋点事件重复 非装扮互动标签始终隐藏互动邀请列表 
		end
		if CurWorld:isGameMakerRunMode() and ClientCurGame:getRuleOptionVal(9) == 3 then
			ShowGameTips(GetS(4897), 3);
		end
		--统计表情使用次数
		if bolReportSpecial == false then
			-- statisticsGameEvent(10100, '%d', ActionShortCutTable[num].ActID,'%d',AccountManager:getMultiPlayer())
			NewBattlePassEventOnTrigger("playact", ActionShortCutTable[num].ID);
		end
		standReportEvent(getReportSceneID(), "MINI_TOOL_BAR", "CharacterAction", "click", { standby1 =  ActionShortCutTable[num].ID})
	end
	--家园埋点
	Homeland_StandReportSingleEvent("PHRASE", "ExpressionArea", "click", {})
	--将快捷短语栏折叠
	-- PhraseLibraryFrameFoldArrow_OnClick();

end

function GetSkins()
	local skinModel = AccountManager:getRoleSkinModel();
	local seatInfoUsing = GetInst("ShopDataManager"):GetPlayerUsingSeatInfo()
	local skinDefs = GetInst("ShopDataManager"):GetSkinDefs()
	local tblSkinList = {}
	local lenSkin = 0;
	local bVip = GetInst('MembersSysMgr'):IsMember()
	for i = 1, #skinDefs do
		local skinDef = skinDefs[i]
		local skinTime = AccountManager:getAccountData():getSkinTime(skinDef.ID)
		if skinTime ~= 0 then 
			if skinModel > 0 then
				if skinDef.ID ~= skinModel then
					table.insert(tblSkinList, skinDef);
					lenSkin = lenSkin + 1;
				end
			else
				table.insert(tblSkinList, skinDef);
				lenSkin = lenSkin + 1;
			end
		end 
	end

	local seatInfos = GetInst("ShopDataManager"):GetSkinSeatInfos()
	for i = 1,#seatInfos do 
		local aTypeSeatInfos = seatInfos[i]
		for j = 1,#aTypeSeatInfos do 
			local aSeatInfo = aTypeSeatInfos[j]
			if aSeatInfo.isOpen and not aSeatInfo.isEmpty then 
				if seatInfoUsing then
					if seatInfoUsing.seatid ~= aSeatInfo.def.seatid then
						if aSeatInfo.vip then
							if bVip then
								table.insert(tblSkinList, aSeatInfo);
							end
						else
							table.insert(tblSkinList, aSeatInfo);
						end
					end
				else
					if aSeatInfo.vip then
						if bVip then
							table.insert(tblSkinList, aSeatInfo);
						end
					else
						table.insert(tblSkinList, aSeatInfo);
					end
				end
			end
		end 
	end 
	return tblSkinList,lenSkin;
end

function CharacteractionPlayTransferAct(n)
	CharacteractionStartScedelerTransfer();
	local actorbody = CurMainPlayer:getBody();
	local bolCanTransfer = false;
	if bolTransfered == false then
		bolTransfered = true;
		bolCanTransfer = true
	else
		if recordTransferTime > transferCoolTime then
			bolCanTransfer = true;
		end
	end
	if bolCanTransfer then
		recordTransferTime = 0;
		actorbody:setAnimSwitchIsCall(true)
		if actorbody:isAvatarModel() then
			CurMainPlayer:playAct(ActionShortCutTable[n].ID);
		else --不是avt 播放高兴动作
			if actHappy2Def ~= nil then
				bolReportSpecial = true;
				CurMainPlayer:playAct(actHappy2Def.ID);
				-- statisticsGameEvent(10100, '%d', actHappy2Def.ActID,'%d',AccountManager:getMultiPlayer())
				NewBattlePassEventOnTrigger("playact", actHappy2Def.ID);
			end
		end
		CurMainPlayer:playSound(ActionShortCutTable[n].Sound, 1.0, 1.0, 4);
	else
		local leftTime = transferCoolTime - recordTransferTime;
		if leftTime > 0  then
			bolTransfered = true;
			ShowGameTips(string.format(GetS(15306), leftTime));
		end
	end
end

--变身动作播放完成后换装
function CharacteractionChangeSkin(bolChange)
	local tblSkinList,lenSkin = GetSkins()
	local len = #tblSkinList;
	if len == 0 then
		return;
	end
	haveDressNums = len + 1;
	if bolChange then
		local index =  math.random(#tblSkinList);
		if not GetInst("UIManager"):GetCtrl("Shop") then
			ShopJumpTabView(1)
			GetInst("UIManager"):GetCtrl("Shop"):CloseBtnClicked()
		end
		local skinDef;
		local aSkinSeatInfo;
		local avatrName;
		local callback = function(ret)
			if ret == 0 then
				transferIndex = index --缓存下标，游戏退出发送账号服
				local player = MusicClubGetPlayer(AccountManager:getUin());
				if player then
					local aname = "&N&A&M&E$1"..avatrName;
					if #aname > 24 then
						aname = string.sub(aname,1,32)
					end
					player:tickNewChat(aname);
				end
				UpdataActionShow()--变身后刷新专属动作
			else
				ShowGameTips(GetS(15307));
			end
		end

		if lenSkin > 0 and index <= lenSkin then
			skinDef =  tblSkinList[index];
			avatrName = skinDef.Name;
			--GetInst("UIManager"):GetCtrl("Shop"):UseSkin(1,{isUsed = false,skinDef = skinDef, callback = callback });
			threadpool:work(function ()	
				threadpool:wait(0.01);  --动画播放完后需延迟一帧进行变身，防止野指针报错
				if ClientCurGame:isInGame() then
					local model = AccountManager:getRoleModel()
					local index = CurMainPlayer:composePlayerIndex(model,AccountManager:getAccountData():getGenuisLv(model),skinDef.ID)
					local player = ClientCurGame:getPlayerByUin(AccountManager:getUin())
					if player then
						CurMainPlayer:changePlayerModel(index,player:getBody():getMutateMob())
						callback(0);
					end
				end
			end)
		else
			aSkinSeatInfo = tblSkinList[index];
			avatrName = aSkinSeatInfo.def.name;
			if avatrName == nil or avatrName == "" then
				avatrName = GetS(15305);
			end
			GetInst("UIManager"):GetCtrl("Shop"):UseSkin(3,{skinSeatInfo = aSkinSeatInfo,noTips = nil, callback = callback});
--[[			if aSkinSeatInfo.def.seatid ~= nil then
				threadpool:work(function ()	
					local useSeatID = tostring(aSkinSeatInfo.def.seatid)
					local code = AccountManager:avatar_seat_use(aSkinSeatInfo.def.seatid)
					if code == 0 then
						GetInst("ShopDataManager"):InitPlayerUsingSeatInfo()
						GetInst("UIManager"):GetCtrl("Shop"):UseCustomSkinInWorld(useSeatID)

						--ClientGetRoleAvatarInfo(AccountManager:getUin(), AccountManager:avatar_seat_current());
						callback(0);
					end
				end)
			end--]]
		end
	else
		if haveDressNums <= leastDressNums then --在动作栏位置上方出现一条可交互引导文案，玩家点击按钮后，引导玩家前往Avatar定制页面。
			if bolShowSpecUI then
				ShowSpecialUI(true);
			else
				ShowSpecialUI(false);
			end
			if schedulerTransferSpecUi == nil then
				schedulerTransferSpecUi = GetInst("MiniUIScheduler"):regGloabel(function()
					recordCountTime = recordCountTime + 1;
					  
					if recordCountTime == countTime then
						recordCountTime = 0;
						local tblSkinList,lenSkin = GetSkins()
						local len = #tblSkinList;
						if len + 1 <= leastDressNums then
							bolShowSpecUI = true;
							ShowSpecialUI(true);
						end
					elseif recordCountTime == countDismissTime then
						bolShowSpecUI = false;
						ShowSpecialUI(false);
					elseif recordCountTime < countDismissTime then
						bolShowSpecUI = true;
					end
				end, 1, nil, 0, false);
			end
		else
			ShowSpecialUI(false);
		end
	end
end

function ShowSpecialUI(bolShow) 
	if bolShow then
		reportCharacteractionStandData("AvatarButton","view");
		getglobal("CharacterTipsFrame"):Show();
		if ClientMgr:isMobile() then
			getglobal("PhraseLibraryFrame"):SetSize(738,467);
			getglobal("PhraseLibraryFrameFold"):SetSize(738,175);
		else 
			getglobal("PhraseLibraryFrame"):SetSize(542,467);
			getglobal("PhraseLibraryFrameFold"):SetSize(542,175);
		end
		getglobal("PhraseLibraryFrameFoldLine"):SetPoint("bottom","CharacterTipsFrame","top",0,0);
		getglobal("PhraseLibraryFrameUnFoldLine"):SetPoint("bottom","CharacterTipsFrame","top",0,0);
		getglobal("PhraseLibraryFrameActorInviteLine"):SetPoint("bottom","CharacterTipsFrame","top",0,0);
	else
		getglobal("CharacterTipsFrame"):Hide();
		if ClientMgr:isMobile() then
			getglobal("PhraseLibraryFrame"):SetSize(738,417);
			getglobal("PhraseLibraryFrameFold"):SetSize(738,125);
		else
			getglobal("PhraseLibraryFrame"):SetSize(542,417);
			getglobal("PhraseLibraryFrameFold"):SetSize(542,125);
		end
		getglobal("PhraseLibraryFrameFoldLine"):SetPoint("bottom","CharacterActionFrame","top",0,0);
		getglobal("PhraseLibraryFrameUnFoldLine"):SetPoint("bottom","CharacterActionFrame","top",0,0);
		getglobal("PhraseLibraryFrameActorInviteLine"):SetPoint("bottom","CharacterActionFrame","top",0,0);
	end
end

function PlayActionExpression(n)
	if CurMainPlayer ~= nil then
		--装扮互动
		local uin = CurMainPlayer and CurMainPlayer:getUin() or 0
		if getkv("user_action_transfer"..uin) == nil then
			sortActionShortTableByWeight(true)
		end
		if ActionShortCutTable[n].SkinID2 and ActionShortCutTable[n].SkinID2  > 0 then
			if #actorInviteTable > 0 then
				getglobal("CharacterActionFrame"):Show();
			end
			checkAndShowInviteList(n)
		else
			if ActionShortCutTable[n].ID == 25 then 
				CharacteractionPlayTransferAct(n);
			else
				CurMainPlayer:playAct(ActionShortCutTable[n].ID);
			end
			if CurWorld:isGameMakerRunMode() and ClientCurGame:getRuleOptionVal(9) == 3 then
				ShowGameTips(GetS(4897), 3);
			end
		end
		--统计表情使用次数
		-- statisticsGameEvent(10100, '%d', ActionShortCutTable[n].ActID,'%d',AccountManager:getMultiPlayer())
	end
end




--替换动作成功
function swapActionSuccess()

	getglobal("ActionLibraryBoxItem"..currentSelectActionLibrary.."Check"):Hide();
	getglobal("ActionLibraryBoxItem"..currentSelectActionLibrary.."Tick"):Show();


	for i=1,#ActionLibraryTable do
		getglobal("ActionLibraryBoxItem"..i.."Tick"):Hide();
	end


	for i=1,MAX_ACTION_CUT_NUM do
		for j=1,#ActionLibraryTable do
			local tick = getglobal("ActionLibraryBoxItem"..j.."Tick");
			-- if is_include(ActionLibraryTable[i].ActID,ActionShortCutTable) then
			if ActionShortCutTable[i].ActID == ActionLibraryTable[j].ActID then
				tick:Show();
			end
		end
	end

	--闪烁两下
	local shortCheck = getglobal("ExpressionShortcut"..currentSelectActionShortBan.."Check");
	shortCheck:Hide();
	threadpool:wait(0.1);
	shortCheck:Show();
	threadpool:wait(0.1);
	shortCheck:Hide();
	threadpool:wait(0.1);
	shortCheck:Show();
	threadpool:wait(0.1);
	shortCheck:Hide();
end


--替换动作失败
function swapAcyionFailure(index)
	getglobal("ActionLibraryBoxItem"..currentSelectActionLibrary.."Check"):Hide();
	getglobal("ExpressionShortcut"..currentSelectActionShortBan.."Check"):Hide();

	local check = getglobal("ExpressionShortcut"..index.."Check")

    --闪烁两下
	check:Hide();
	threadpool:wait(0.1);
	check:Show();
	threadpool:wait(0.1);
	check:Hide();
	threadpool:wait(0.1);
	check:Show();
	threadpool:wait(0.1);
	check:Hide();

	currentSelectActionShortBan = 0;
	currentSelectActionLibrary = 0;

end





function ActionLibraryFrameCloseBtn_OnClick()
	getglobal("ActionLibraryFrame"):Hide();
	UIEndDrag("MousePickItem");

end


function is_include(value, tab)
    for k,v in ipairs(tab) do
      if v == value then
          return true
      end
    end
    return false
end

PhraseList = {15271,15272,15273,15274,15275,15276,15277,15278,15279,15280}
ShowTenPhrase = 15282
preTime = -1; -- 上次点击
intervalTime = 1; -- 间隔时间1s
maxPhraseNum = 10

function PhraseLibraryFrameUnFold_UseClientStr()
	if RoomInteractiveData and RoomInteractiveData:IsSocialHallRoom() then
		local customPhraseCnt = maxPhraseNum - 1 --快捷短语总数是10，第十个固定发坐标，所以是固定配9个
		if "table" == type(ns_data.social_phrase_list) and customPhraseCnt == #ns_data.social_phrase_list then
			return true, ns_data.social_phrase_list
		end
	end

	return false, PhraseList
end

function PhraseLibraryFrameUnFold_OnShow()
	-- getglobal("PhraseLibraryFrameMask"):Show();
	local yOffset = 56
	local useClientStr, phlist = PhraseLibraryFrameUnFold_UseClientStr()
	for i = 1,maxPhraseNum do 
		local aPhraseItem = getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i)
		if i % 2 ~= 0 then 
			aPhraseItem:SetPoint("topright","PhraseLibraryFrameUnFoldPanel","top", -5, yOffset)
		else
			aPhraseItem:SetPoint("topleft","PhraseLibraryFrameUnFoldPanel","top", 5, yOffset)
		end 
		local text = ""
		if i == 10 then 
			text = GetS(ShowTenPhrase)
		elseif useClientStr then
			text = phlist[i]
		else
			text = GetS(phlist[i])
		end 
		--将表情字符提取出来, eg:#A123fghj result: nameIcon=#A123,nameText=fghj
		--kkk#A123kkk 表情字符在中间这种没有考虑， 只认为表情字符在头部或末尾，并且之前或之后一定有普通字符。
		local pos = string.find(text, "#A");
		local nameText;
		local nameIcon;
		--默认文字在前，icon在后
		local reverse = false;
		if pos == nil then
			nameText = text;
			nameIcon = nil;
		elseif pos == 1 then
			local length = 0;
			string.gsub(text, "^#A[1-9].-[^%d]", function(str)
				length = #str;
				nameIcon = str;
			end)
			length = length -1;
			length = length > 5 and 5 or length;
			nameIcon = string.sub(nameIcon, 1, length);
			nameText = string.sub(text, length+1, -1);
			reverse = true;
		else
			nameText = string.sub(text, 1, pos-1);
			nameIcon = string.sub(text, pos, -1);
		end

		--文字要相对与表情居中， 并且表情紧跟文字后面
		local offest = getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "NameText"):GetTextExtentWidth(nameText);
		
		getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "NameText"):SetWidth(offest+2);
		getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "NameText"):SetText(nameText);
		local nameWidth = offest+2 + 53;
		if (nameIcon) then
			getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "NameIcon"):SetText(nameIcon);	
		else
			getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "NameIcon"):Hide();
			nameWidth = nameWidth - 53;
		end

		if reverse then
			getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "NameIcon"):SetPoint("left", "PhraseLibraryFrameUnFoldPanelItem" .. i .. "Name", "left",0,0);
			getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "NameText"):SetPoint("left", "PhraseLibraryFrameUnFoldPanelItem" .. i .. "NameIcon", "right",0,2);
		else
			getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "NameIcon"):SetPoint("left", "PhraseLibraryFrameUnFoldPanelItem" .. i.."Name", "left", offest + 1,0);
		end
		getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "Name"):SetWidth(nameWidth);
		--getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "NameIcon"):SetSelfScale(0.2);
		-- if string.find(text,"#") then 
		-- 	getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "Name"):SetPoint("left","PhraseLibraryFrameUnFoldPanelItem" .. i .. "Bkg","left", Offsets[i], 0)
		-- else
		-- 	getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "Name"):SetPoint("left","PhraseLibraryFrameUnFoldPanelItem" .. i .. "Bkg","left", Offsets[i],0)
		-- end 
		--getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "Name"):SetText(text,255,255,255)
		if ClientMgr:isPC() then
			getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "AcckeyTips"):Show()
			local altIndex = i 
			if altIndex == 10 then 
				altIndex = 0
			end 
			getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "AcckeyTips"):SetText("alt+" .. altIndex) 
		else
			getglobal("PhraseLibraryFrameUnFoldPanelItem" .. i .. "AcckeyTips"):Hide()
		end 
		yOffset = 56 + 57 * math.floor(i / 2)
	end
	preTime = -1;
	--家园埋点
	Homeland_StandReportSingleEvent("PHRASE", "ShortcutPhraseShow", "view", {})
end

function PhraseLibraryFrameUnFold_OnHide()
	-- getglobal("PhraseLibraryFrameMask"):Hide();
end

function SendPhraseBtnClicked(index,isPhrase)
	local curTime = os.time();
	if curTime - preTime < intervalTime then
		ShowGameTips(GetS(1129))
		return;
	end
	preTime = curTime;
	local curIndex
	if isPhrase then 
		curIndex = this:GetParentFrame():GetClientID()
	else
		curIndex = index or this:GetClientID()
	end 
	local useClientStr, phlist = PhraseLibraryFrameUnFold_UseClientStr()
	if useClientStr and phlist[curIndex] and not curIndex ~= 10 then --10位固定发坐标信息
		SpamPreventionPresenter:requestSendChat(phlist[curIndex]);
	else
		local key = "&"
		local text = key .. curIndex
		SpamPreventionPresenter:requestSendChat(text);
		--家园埋点
		Homeland_StandReportSingleEvent("PHRASE", "ShortcutPhraseShow", "click", {})
	end
end

function PhraseLibraryFrameMask_OnClick()
	CharacterActionBtn_OnClick();
end

function PhraseLibraryFrameShowPharse(bshow)
	if bshow then
		getglobal("PhraseLibraryFrameUnFold"):Show();
		getglobal("PhraseLibraryFrameFold"):Hide();
	else
		getglobal("PhraseLibraryFrameUnFold"):Hide();
		getglobal("PhraseLibraryFrameFold"):Show();
	end
	getglobal("PhraseLibraryFrameActorInvite"):Hide();
end

function PhraseLibraryFrameFoldArrow_OnClick()
	PhraseLibraryFrameShowPharse(false)
	--家园埋点
	Homeland_StandReportSingleEvent("PHRASE", "ShortcutPhraseClose", "click", {})
end


function PhraseLibraryFrameUnFold_OnClick()
	PhraseLibraryFrameShowPharse(true)
	Homeland_StandReportSingleEvent("PHRASE", "ShortcutPhraseClose", "click", {})
end

function PhraseLibraryFrame_OnShow()
	-- PhraseLibraryFrameUnFold_OnClick();
	--家园埋点
	PhraseLibraryFrameShowPharse(true) --避免埋点重复
end

function PhraseLibraryFrame_OnHide()
	getglobal("PhraseLibraryFrameUnFold"):Hide();
	getglobal("PhraseLibraryFrameActorInvite"):Hide();
	getglobal("PhraseLibraryFrameFold"):Hide();
	--检测互动装扮动画仍显示
	if isPlayingactorInviteAni then
		getglobal("ActorInviteTipBtn"):Show()
	end
	StopComeBackTimer()
end

--刷新被邀请列表数据
function setActorInviteInfo(ge)
	table.insert(beInviteTable, ge)
	if getglobal("PhraseLibraryFrameActorInviteRefuseTips"):IsShown() then
		--仅当被邀请列表显示时，才会刷新列表
		ShowActorInvite(true)
	end
end

--更新装扮互动邀请剩余时间
function updateActorInviteInfo(info)
	for index, value in ipairs(beInviteTable) do
		if info.targetUin == value.targetUin then
			value.lastTime = info.lastTime
			break
		end
	end
end

--更新倒计时
function UpdateCountDown(delta)
    if delta > 0 and #beInviteTable>0 then
        for key, value in pairs(beInviteTable) do
            local lefttime = value.lastTime - os.time()
            if lefttime > 0 then
                value.lastTime = lefttime + os.time()
			else
				ActorInviteBtnTimeout(value)
            end
        end
    end
end

--刷新装扮邀请列表
function UpdataActorInviteData()
	local InviteWidth = getglobal("PhraseLibraryFrameActorInvite"):GetWidth()
	local InviteListWidth = getglobal("PhraseLibraryFrameActorInviteList"):GetWidth()
	local len = isBeInvite and #beInviteTable or #actorInviteTable
	if len > 1 then
		getglobal("PhraseLibraryFrameActorInvite"):SetSize(InviteWidth,374)
		getglobal("PhraseLibraryFrameActorInviteList"):SetSize(InviteListWidth,240)
		listConfig.GoodList_Height = 300
	else
		listConfig.GoodList_Height = 100
		getglobal("PhraseLibraryFrameActorInvite"):SetSize(InviteWidth,224)
		getglobal("PhraseLibraryFrameActorInviteList"):SetSize(InviteListWidth,100)
	end
	getglobal("PhraseLibraryFrameActorInviteList"):initData(listConfig.GoodList_Width, listConfig.GoodList_Height, listConfig.GoodCell_Cols, listConfig.GoodCell_Rows)
end

--移除传入的邀请列表
function removeActorInviteInfo(info)
	local needRefsh = false
	for index, value in ipairs(beInviteTable) do
		if info.targetUin == value.targetUin then
			table.remove(beInviteTable,index)
			needRefsh = true
			break
		end
	end
	if needRefsh then
		--列表为空关闭邀请界面
		StopComeBackTimer()
		if #beInviteTable == 0 then
			isPlayingactorInviteAni = false
			PhraseLibraryFrameShowPharse(false)
		else
			UpdataActorInviteData()
		end
		
	end
end

--显示邀请/被邀请列表
function ShowActorInvite(isInvite)
	isBeInvite = isInvite
	getglobal("PhraseLibraryFrameActorInvite"):Show();
	getglobal("PhraseLibraryFrameUnFold"):Hide();
	getglobal("PhraseLibraryFrameFold"):Hide();
	
	--获取取联机房间所有玩家信息
	local num = ClientCurGame:getNumPlayerBriefInfo();
	briefInfos = {}
	for i=0, num-1 do
		table.insert(briefInfos, ClientCurGame:getPlayerBriefInfo(i))
	end

	--被邀请提示显示
	local inviteTitle = getglobal("PhraseLibraryFrameActorInviteTitle")
	local inviteTitleShadow = getglobal("PhraseLibraryFrameActorInviteTitleShadow")
	
	if isBeInvite then
		inviteTitle:SetText(GetS(15292))
		inviteTitleShadow:SetText(GetS(15292))
		getglobal("PhraseLibraryFrameActorInviteRefuseTips"):Show()

		standReportEvent(getReportSceneID(), "MINI_INVITE_START", "-", "view")
		standReportEvent(getReportSceneID(), "MINI_INVITE_START", "InviteButton", "view")
		StopComeBackTimer()
	else
		inviteTitle:SetText(GetS(15293))
		inviteTitleShadow:SetText(GetS(15293))
		getglobal("PhraseLibraryFrameActorInviteRefuseTips"):Hide()

		standReportEvent(getReportSceneID(), "MINI_INVITE_RECEIVE", "-", "view")
		standReportEvent(getReportSceneID(), "MINI_INVITE_RECEIVE", "Receive", "view")
		standReportEvent(getReportSceneID(), "MINI_INVITE_RECEIVE", "Reject", "view")
	end
	UpdataActorInviteData()
end

--取消拒绝指定玩家邀请三小时
function UnCheckActorInviteRefuse()
	isRefuseCurPlayer = false
	getglobal("PhraseLibraryFrameActorInviteRefuseTipsUnCheckBt"):Show();
	getglobal("PhraseLibraryFrameActorInviteRefuseTipsCheckBt"):Hide();
end

--拒绝指定玩家邀请三小时
function CheckActorInviteRefuse()
	isRefuseCurPlayer = true
	getglobal("PhraseLibraryFrameActorInviteRefuseTipsUnCheckBt"):Hide();
	getglobal("PhraseLibraryFrameActorInviteRefuseTipsCheckBt"):Show();
end

local function SetComeBackTimerId(TimerId)
	table.insert(allTimerId,TimerId)
end

function StopComeBackTimer()
	for k, timerId in pairs(allTimerId) do
		if timerId and timerId > 0 then
			threadpool:kick(timerId)
		end
	end
end

function PhraseLibraryFrameActorInviteList_tableCellAtIndex(tableView, idx)
	local view_name = listConfig.GoodList_Name
	local cell_tmpl = listConfig.GoodCell_TemplateName
	local cell, uiidx = tableView:dequeueCell(0)

	if not cell then
		local cell_name = view_name .. "Item" .. uiidx
		cell = UIFrameMgr:CreateFrameByTemplate("Frame", cell_name, cell_tmpl, view_name)
	else
		cell:Show()
	end
	local info = isBeInvite and beInviteTable[idx + 1] or actorInviteTable[idx + 1]
	if info then
		ActorInviteList_ResetCellItemData(cell, info, idx)
	end

	return cell
end

function PhraseLibraryFrameActorInviteList_numberOfCellsInTableView(tableView)
	local len = isBeInvite and #beInviteTable or #actorInviteTable
	return len
end

function PhraseLibraryFrameActorInviteList_tableCellSizeForIndex(tableView, idx)
	local colidx = math.mod(idx, listConfig.GoodCell_Rows)
	local posX = colidx * (listConfig.GoodCell_Width + 15)
	local isPC = ClientMgr:isPC() or false
	local posY = isPC and 18 or 25 
	return posX, posY, listConfig.GoodCell_Width, listConfig.GoodCell_Height
end

function PhraseLibraryFrameActorInviteList_tableCellWillRecycle(tableView, cell)
	if cell then cell:Hide() end
end

function ActorInviteList_ResetCellItemData(cell, InviteInfo, index)
	local isPC = ClientMgr:isPC() or false
	local scale = isPC and 0.8 or 1 
	local head = getglobal(cell:GetName().."Icon")
	local headFrame = getglobal(cell:GetName().."Frame")
	local NickName = getglobal(cell:GetName().."NickName")
	local PlayerUin = getglobal(cell:GetName().."PlayerUin")
	local actorIcon = getglobal(cell:GetName().."ActorIcon")
	local InviteBtn = getglobal(cell:GetName().."InviteBtn")
	local RefuseinviteBtn = getglobal(cell:GetName().."RefuseinviteBtn")
	local AcceptInviteBtn = getglobal(cell:GetName().."AcceptInviteBtn")
	local InviteBtnTitle = getglobal(InviteBtn:GetName().."Title")
	local RefuseinviteBtnTitle = getglobal(RefuseinviteBtn:GetName().."Title")
	local AcceptInviteBtnTitle = getglobal(AcceptInviteBtn:GetName().."Title")
	local refuseTime = getglobal(AcceptInviteBtn:GetName().."Time")

	NickName:SetSelfScale(scale)
	PlayerUin:SetSelfScale(scale)
	InviteBtnTitle:SetSelfScale(scale)
	RefuseinviteBtnTitle:SetSelfScale(scale)
	AcceptInviteBtnTitle:SetSelfScale(scale)
	refuseTime:SetSelfScale(scale)

	for index, value in ipairs(ActionShortCutTable) do
		if value.ID == InviteInfo.actId then
			actorIcon:SetTexture("ui/animact/icon"..value.ActID..".png")
			break;
		end
	end
	
	if isBeInvite then
		--显示被邀请按钮
		InviteBtn:Hide()
		RefuseinviteBtn:Show()
		AcceptInviteBtn:Show()
		refuseTime:SetText(InviteInfo.lastTime - os.time().."s")
		local reastTime = InviteInfo.lastTime - os.time()
		local timerId = threadpool:timer(reastTime, 1, function ()
			reastTime = reastTime - 1;
			refuseTime:SetText(reastTime.."s")
		end)
		SetComeBackTimerId(timerId)
	else
		--显示邀请按钮
		InviteBtn:Show()
		RefuseinviteBtn:Hide()
		AcceptInviteBtn:Hide()
	end

	--列表玩家头像昵称显示
	for i, briefInfo in ipairs(briefInfos) do
		--联机房间存在被邀请玩家Uin
		if briefInfo.uin == InviteInfo.targetUin then
			local isHeadAvt = 0;
			if briefInfo.customjson ~= nil and  #briefInfo.customjson > 0 then
				isHeadAvt = tonumber(briefInfo.customjson);
			end
			HeadCtrl:SetPlayerHeadByUin(head:GetName(),briefInfo.uin,briefInfo.model,briefInfo.accountSkinID,isHeadAvt);
			HeadFrameCtrl:SetPlayerheadFrameName(headFrame:GetName(),briefInfo.frameid);
			local filteredName = DefMgr:filterString(briefInfo.nickname)
			NickName:SetText(filteredName);
		end
	end
	PlayerUin:SetText(GetS(359)..InviteInfo.targetUin)
end

local function checkActorInviteState(info)
	if not CurMainPlayer then
		return false
	end
	local otherPlayer = CurWorld:getActorMgr():findPlayerByUin(info.targetUin)
	local checkOtherPlayer = otherPlayer and otherPlayer:checkCanPlaySkinAct() or nil
	--玩家状态检测
	local checkCurPlayer = CurMainPlayer.checkCanPlaySkinAct and CurMainPlayer:checkCanPlaySkinAct() or nil
	if not checkCurPlayer or not checkOtherPlayer then
		ShowGameTips(GetS(15285),3)
		return false
	end

	--空间检测
	if CurMainPlayer.checkHasEnoughSpace2SkinAct and not CurMainPlayer:checkHasEnoughSpace2SkinAct(info.actId) then
		ShowGameTips(GetS(15286),3)
		return false
	end

	--物体阻挡检测
	local otherIsDivide = otherPlayer.checkIsDivideByBlock and otherPlayer:checkIsDivideByBlock(CurMainPlayer:getUin()) or false
	local selfIsDivide = CurMainPlayer.checkIsDivideByBlock and CurMainPlayer:checkIsDivideByBlock(info.targetUin) or false
	if selfIsDivide or otherIsDivide then
		ShowGameTips(GetS(15288),3)
		return false
	end

	--玩家距离检测
	if CurMainPlayer.checkNearEnough2SkinAct and not CurMainPlayer:checkNearEnough2SkinAct(info.targetUin) then
		ShowGameTips(GetS(15287),3)
		return false
	end
	return true
end

--显示装扮互动邀请剩余时间进度条
local function ShowInviteCoolingTime(barVal)
	for i=1,MAX_ACTION_CUT_NUM do
		local CoolingBkg = getglobal("ExpressionShortcut"..i.."CoolingBkg");
		local CoolingTime = getglobal("ExpressionShortcut"..i.."CoolingTime");
		if ActionShortCutTable[i].SkinID2 and ActionShortCutTable[i].SkinID2  > 0 then
			CoolingBkg:Show()
			CoolingTime:Show()
			CoolingTime:SetWidth(48*barVal);
			if barVal == 0 then
				CoolingBkg:Hide()
				CoolingTime:Hide()
			end
		end
	end
end

--发起邀请
function ActorInviteBtn_OnClick()
	local index = getglobal(this:GetParent()):GetClientID()+1
	local info =  actorInviteTable[index]
	if info and CurMainPlayer and CurMainPlayer.sendActorInvite then
		standReportEvent(getReportSceneID(), "MINI_INVITE_START", "InviteButton", "click")
		standReportEvent(getReportSceneID(), "MINI_INVITE_START", "InviteButton", "invite")
		local canInvite = checkActorInviteState(info)
		if not canInvite then
			standReportEvent(getReportSceneID(), "MINI_INVITE_START", "InviteButton", "invite_failed")
			return;
		end
		standReportEvent(getReportSceneID(), "MINI_INVITE_START", "InviteButton", "invite_successed")
		CurMainPlayer:sendActorInvite(0,info.targetUin, info.actId)
		isActorInviteBtnCoolingTime = true
		threadpool:work(function ()
			local tryTime = MAX_ACTION_INVITE_TIME;
			while tryTime > 0 do
				threadpool:wait(1);
				tryTime = tryTime - 1;
				ShowInviteCoolingTime(tryTime/MAX_ACTION_INVITE_TIME)
			end
			isActorInviteBtnCoolingTime = false
		end)
		ShowGameTips(GetS(15284))
	else
		ShowGameTips(GetS(15283))
	end
	getglobal("CharacterActionFrame"):Hide();
end

--接受邀请
function AcceptActorInviteBtn_OnClick()
	local index = getglobal(this:GetParent()):GetClientID()+1
	local info =  beInviteTable[index]
	if info and CurMainPlayer and CurMainPlayer.sendActorInvite then
		standReportEvent(getReportSceneID(), "MINI_INVITE_RECEIVE", "Receive", "click")
		local canInvite = checkActorInviteState(info)
		if not canInvite then
			return;
		end
		CurMainPlayer:sendActorInvite(1,info.targetUin, info.actId)
		table.remove(beInviteTable,index)
		if #beInviteTable == 0 then
			isPlayingactorInviteAni = false
		end
	else
		ShowGameTips(GetS(15285))
	end
	getglobal("CharacterActionFrame"):Hide();
end

--拒绝邀请
function RefuseActorInviteBtn_OnClick()
	local index = getglobal(this:GetParent()):GetClientID()+1
	local info =  beInviteTable[index]
	if info and CurMainPlayer and CurMainPlayer.sendActorInvite then
		standReportEvent(getReportSceneID(), "MINI_INVITE_RECEIVE", "Reject", "click")
		CurMainPlayer:sendActorInvite(2,info.targetUin, info.actId)
		if isRefuseCurPlayer then
			local time = getServerTime()
			local uin = info.targetUin
			setkv("ActorInviteRefuseTime"..uin,time)
		end
	else
		ShowGameTips(GetS(15285))
	end
	removeActorInviteInfo(info)
end

--接受邀请超时
function ActorInviteBtnTimeout(info)
	for index, value in ipairs(beInviteTable) do
		if info.targetUin == value.targetUin then
			if CurMainPlayer and CurMainPlayer.sendActorInvite then
				CurMainPlayer:sendActorInvite(3,info.targetUin, info.actId)
			end
			--移除列表数据
			removeActorInviteInfo(info)
			break
		end
	end
end

local function SetActionTipsInfo(info,id)
	if not info or not info.Desc or info.Desc == "" then
		return
	end
	local actionTips = getglobal("characteractionTipsFrame"); 
	local Icon = getglobal("characteractionTipsFrameIcon")
	local Name = getglobal("characteractionTipsFrameName")
	local Desc = getglobal("characteractionTipsFrameDesc")
	local row = math.ceil(id / 8);
	local col = (id - 1) % 8 + 1;
	actionTips:SetPoint("topleft", "ActionLibraryFrame", "topleft", -170 + (col - 1) * 94, 180 + (row - 1) * 96);
	actionTips:Show()
	Icon:SetTexture("ui/animact/"..info.icon..".png")
	Name:SetText(info.Name)
	Desc:SetText(info.Desc)
end

--鼠标进入
function OnMouseEnter_PCShowActionTips()
	local id = this:GetClientID()
	if ActionLibraryTable and ActionLibraryTable[id] and ActionLibraryTable[id].Desc then
		SetActionTipsInfo(ActionLibraryTable[id],id)
	end
end

--鼠标离开
function OnMouseLeave_PCShowActionTips()
	getglobal("characteractionTipsFrame"):Hide()
end

--手机长按
function ShowActionTipsMobile_MouseDownUpdate()
	if arg1 >= 0.5 then 
        if ClientMgr:isMobile() then
			local id = this:GetClientID()
			if ActionLibraryTable and ActionLibraryTable[id] and ActionLibraryTable[id].Desc then
				SetActionTipsInfo(ActionLibraryTable,id)
			end
		end
	end
end

--手机放开
function ShowActionTipsMobile_MouseUp()
	if ClientMgr:isMobile() then
		getglobal("characteractionTipsFrame"):Hide()
	end
end

-- 玩家当前是否使用该皮肤
local function AccountIsUsingSkin(skinID)
	return AccountManager:getRoleSkinModel() == skinID
end

local KEY_SKIN_FIRST_USE_INGAME = "KEY_SKIN_FIRST_USE_INGAME"
local KEY_SKIN_LAST_USE_INGAME = "KEY_SKIN_LAST_USE_INGAME"
-- 是否第一次游戏内使用该皮肤
local function AccountIsFirstTimeUseSkinInGame(skinID)
	local uin = CurMainPlayer and CurMainPlayer:getUin() or 0
	return getkv(KEY_SKIN_FIRST_USE_INGAME .. uin .. skinID)
end

-- 不是上一次游戏内使用的皮肤
function IsAccountLastTimeUsedSkin()
	local curSkinID = 0  --当前玩家皮肤id
	local uin = CurMainPlayer and CurMainPlayer:getUin() or 0
	local lastSkinID = getkv(KEY_SKIN_LAST_USE_INGAME .. uin) or 0
	if CurMainPlayer ~= nil and CurMainPlayer.getSkinID then
		curSkinID = CurMainPlayer:getSkinID()
	end
	setAccountLastTimeUsedSkin(curSkinID)
	return tonumber(curSkinID) ~= tonumber(lastSkinID)
end

-- 设置非第一次携带该皮肤进入游戏标记
function AccountSetUnFirstTimeUseSkinInGame(skinID)
	local uin = CurMainPlayer and CurMainPlayer:getUin() or 0
	setkv(KEY_SKIN_FIRST_USE_INGAME .. uin .. skinID, true)
end

-- 设置当前进入游戏该皮肤
function setAccountLastTimeUsedSkin(skinID)
	local uin = CurMainPlayer and CurMainPlayer:getUin() or 0
	setkv(KEY_SKIN_LAST_USE_INGAME..uin, skinID)
end

--更新动作栏内红点（未处理拥有即解锁动作的装扮）
function showActionBarReddot()
	local isShow = false
	local skinID = 0  --当前皮肤id
	if CurMainPlayer ~= nil and CurMainPlayer.getSkinID then
		skinID = CurMainPlayer:getSkinID()
	end
	for i=1,MAX_ACTION_CUT_NUM do
		local RedDot = getglobal("ExpressionShortcut"..i.."RedDot")
		RedDot:Hide()
		--存在互动装扮，并且需要穿在身上
		if ActionShortCutTable[i].SkinID2 > 0 and skinID == ActionShortCutTable[i].SkinID then
			--判断是否第一次穿
			if not AccountIsFirstTimeUseSkinInGame(skinID) then
				RedDot:Show()
			end
			--打开存在互动装扮的表情栏时进行埋点
			standReportEvent(getReportSceneID(), "MINI_QUICK_WORD", "interaction", "view",{standby1 = ActionShortCutTable[i].ID})
		end
	end
	AccountSetUnFirstTimeUseSkinInGame(skinID)
end

-- 游戏内显示装扮互动红点（首次拥有互动装扮进入游戏）
function showActorInviteReddot()
	local isShow = false
	local skinID = 0  --当前皮肤id
	if CurMainPlayer ~= nil and CurMainPlayer.getSkinID then
		skinID = CurMainPlayer:getSkinID()
	end
	local num = DefMgr:getPlayActDefNum();
	for i=1,num do
		local def = DefMgr:getPlayActDefByIndex(i-1);
		--存在互动装扮，并且需要穿在身上
		if def and def.SkinID2 > 0 and def.SkinID == skinID then
			--判断是否第一次穿
			if not AccountIsFirstTimeUseSkinInGame(skinID) then
				isShow = true;
				break;
			end
		end
		
	end
	return isShow
end

--根据ID获取动作id
function getActInviteDefById(Id)
	local actInviteDef = nil
	local num = DefMgr:getPlayActDefNum();
	for i=1,num do
		local def = DefMgr:getPlayActDefByIndex(i-1);
		--穿戴装扮为互动装扮中的主装扮
		if def and def.ID == Id then
			actInviteDef = def
			break;
		end
	end
	return actInviteDef;
end

function getReportSceneID()
	local sceneID = ""
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
		sceneID = "1003"
	else--客机
		sceneID = "1001"
	end
	return sceneID
end

function getShedulerTransfer()
	return schedulerTransfer;
end

-- 上报
function reportCharacteractionStandData(oID, evCode)
    standReportEvent(getReportSceneID(), "MINI_TOOL_BAR", oID, evCode)
end