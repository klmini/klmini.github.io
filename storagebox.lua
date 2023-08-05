STORAGEBOX_GRID_MAX = 60;     	--储物箱格子
FUNNEL_GRID_MAX = 5;		--漏斗格子
EMITTER_GRID_MAX = 10;		--发射器格子
SENSOR_GRID_MAX = 5;            --感应器格子
COLLIDER_GRID_MAX = 5;		--触碰方块格子
INTERPRETER_GRID_MAX = 8;

CurAttachedStorage = nil
MoveStorageItemIndex = -1;  	--移动储物箱的格子


function SetBoxContainerInfo(baseindex, blockId, blockpos)
	--Log("SetBoxContainerInfo"..baseindex..blockId);
	--blockpos = {posx, posy, posz};
	local boxFrame = getglobal("StorageBoxFrame");
	if baseindex == STORAGE_START_INDEX then	--打开的是储物箱子
		boxFrame:SetClientString("storage");
	elseif baseindex == FUNNEL_START_INDEX then	--打开的是漏斗
		boxFrame:SetClientString("funnel");
	elseif baseindex == EMITTER_START_INDEX then	--打开的是发射器
		boxFrame:SetClientString("emitter");
	elseif baseindex == SENSOR_START_INDEX then	--打开的是方块感应器
		boxFrame:SetClientString("sensor");
	elseif baseindex == INTERPRETER_START_INDEX then	--打开的是电路解析器
		boxFrame:SetClientString("rediointerpreter");
	elseif baseindex == COLLIDER_START_INDEX then	--打开的是触碰方块
		boxFrame:SetClientString("collider");
	end
	for i=1, STORAGEBOX_GRID_MAX do
		local itembtn = getglobal("StorageRightBoxStorageItem"..i);
		itembtn:SetClientID(baseindex+i);
	end

	boxFrame:SetClientUserData(0, blockId);
	UIFrameMgr:frameShow(boxFrame);
	--ClientCurGame:setOperateUI(true)

	------红外感应器的设置面板打开 
	if blockId == 1168 then 
		getglobal("SensorDistanceFrame"):Show()
	end 


	--打开地牢宝箱, 成就任务上报
	print("SetBoxContainerInfo: blockId = ", blockId);
	if baseindex == STORAGE_START_INDEX and CurWorld:isSurviveMode() and blockId == 734 then
		print("OpenDungeonChest:");
		print("blockpos:", blockpos);
		if blockpos and blockpos.x and blockpos.y and blockpos.z then
			local _pos = (blockpos.x * 1000 + blockpos.y * 100 + blockpos.z * 10) % 10000;
			local _param = {pos = _pos};
			if ArchievementGetInstance().func:canChestReport(_pos) then
				ArchievementGetInstance().func:Report2Server(1002, _param);
			end
		end
	end
end

function StorageBoxFrame_Onload()
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	this:RegisterEvent("GE_UPDATE_STORAGEBOX_POINT");
	StorageBoxFrame_AddGameEvent()
	for i=1,5 do
		for j=1,6 do
			local itembtn = getglobal("StorageLeftBoxItem"..((i-1)*6+j));
			itembtn:SetPoint("topleft", "StorageLeftBoxPlane", "topleft", (j-1)*85, (i-1)*83);
		end
	end

	for i=1,10 do
		for j=1,6 do
			local itembtn = getglobal("StorageRightBoxStorageItem"..((i-1)*6+j));
			itembtn:SetPoint("topleft", "StorageRightBoxPlane", "topleft", (j-1)*85, (i-1)*83);
		end
	end

	local leftTitle = getglobal("StorageBoxFrameLeftTitle");
	leftTitle:SetText(GetS(294)); --StringDef物品栏
	local rightTitle = getglobal("StorageBoxFrameRightTitle");
	rightTitle:SetText(GetS(3004)); --StringDef储物箱
end

function StorageBoxFrame_AddGameEvent()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		if getglobal("StorageBoxFrame"):IsShown() then
			local paramData = context:GetParamData()
			local grid_index = paramData.gridIndex
			if grid_index and grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX + 1000 then
				UpdateLeftBoxOneItem(grid_index);
			end
			local n = 0;
			if grid_index >= STORAGE_START_INDEX and grid_index < STORAGE_START_INDEX + 1000 then
				n = grid_index - STORAGE_START_INDEX + 1;
			elseif grid_index >= FUNNEL_START_INDEX and grid_index < FUNNEL_START_INDEX + 1000  then
				n = grid_index - FUNNEL_START_INDEX + 1;
			elseif grid_index >= EMITTER_START_INDEX and grid_index < EMITTER_START_INDEX + 1000 then
				n = grid_index - EMITTER_START_INDEX + 1;
			elseif grid_index >= SENSOR_START_INDEX and grid_index < SENSOR_START_INDEX + 1000 then
				n = grid_index - SENSOR_START_INDEX + 1;
			elseif grid_index >= COLLIDER_START_INDEX and grid_index < COLLIDER_START_INDEX + 1000 then
				n = grid_index - COLLIDER_START_INDEX + 1;
			end
			if n > 0 then
				UpdateRightBoxOneStorageItem(grid_index, n);
			end
		end
	end)
end

function StorageBoxFrame_OnEvent()
	local ge = GameEventQue:getCurEvent();
	local grid_index = ge.body.backpack.grid_index;

	if arg1 == "GE_BACKPACK_CHANGE" then
		if getglobal("StorageBoxFrame"):IsShown() then
			if grid_index >= BACKPACK_START_INDEX and grid_index < BACKPACK_START_INDEX + 1000 then
				UpdateLeftBoxOneItem(grid_index);
			end
			local n = 0;
			if grid_index >= STORAGE_START_INDEX and grid_index < STORAGE_START_INDEX + 1000 then
				n = grid_index - STORAGE_START_INDEX + 1;
			elseif grid_index >= FUNNEL_START_INDEX and grid_index < FUNNEL_START_INDEX + 1000  then
				n = grid_index - FUNNEL_START_INDEX + 1;
			elseif grid_index >= EMITTER_START_INDEX and grid_index < EMITTER_START_INDEX + 1000 then
			 	n = grid_index - EMITTER_START_INDEX + 1;
			elseif grid_index >= SENSOR_START_INDEX and grid_index < SENSOR_START_INDEX + 1000 then
			 	n = grid_index - SENSOR_START_INDEX + 1;
			elseif grid_index >= COLLIDER_START_INDEX and grid_index < COLLIDER_START_INDEX + 1000 then
				n = grid_index - COLLIDER_START_INDEX + 1;
			end
			if n > 0 then
				UpdateRightBoxOneStorageItem(grid_index, n);		
			end
		end
	end

	if arg1 == "GE_UPDATE_STORAGEBOX_POINT" then
		if getglobal("StorageBoxFrame"):IsShown() and not getglobal("SensorDistanceFrame"):IsShown() then
			UpdateRightBoxPoint(grid_index);
		end
	end
end

function UpdateLeftBoxAllItem()
	for i=1,BACK_PACK_GRID_MAX do
		if i <= 30 then
			UpdateLeftBoxOneItem(BACKPACK_START_INDEX+i-1);
		end
	end
end

function UpdateLeftBoxOneItem(grid_index)
	local n = grid_index+1;
	if grid_index >= BACKPACK_START_INDEX then
		n = n - BACKPACK_START_INDEX
	end

	local icon = getglobal("StorageLeftBoxItem"..n.."Icon");
	local num = getglobal("StorageLeftBoxItem"..n.."Count");
	local durbkg = getglobal("StorageLeftBoxItem"..n.."DurBkg");
	local durbar = getglobal("StorageLeftBoxItem"..n.."Duration");

	UpdateGridContent(icon, num, durbkg, durbar, grid_index);
end

function GetStorageBoxInfo( boxframe )
	local containerName = boxframe:GetClientString();
	local grid_num = 0;
	local baseindex = 0;
	
	if string.find(containerName, "storage") then
		grid_num = ClientBackpack:getGridCount(STORAGE_START_INDEX);
		baseindex = STORAGE_START_INDEX;
	elseif string.find(containerName, "funnel") then
		grid_num = FUNNEL_GRID_MAX;
		baseindex = FUNNEL_START_INDEX;
	elseif string.find(containerName, "emitter") then
		grid_num = EMITTER_GRID_MAX; 
		baseindex = EMITTER_START_INDEX
	elseif string.find(containerName, "sensor") then
		grid_num = SENSOR_GRID_MAX; 
		baseindex = SENSOR_START_INDEX
	elseif string.find(containerName, "rediointerpreter") then
		grid_num = INTERPRETER_GRID_MAX; 
		baseindex = INTERPRETER_START_INDEX	
	elseif string.find(containerName,"collider") then
		grid_num = COLLIDER_GRID_MAX;
		baseindex = COLLIDER_START_INDEX;
	end

	return baseindex,  grid_num;
end

local hasItemNum = 0;
function UpdateRightBoxAllStorageItem()
	local baseindex, grid_num  = GetStorageBoxInfo( getglobal("StorageBoxFrame") );

	for i=1, grid_num do
		UpdateRightBoxOneStorageItem(baseindex+i-1, i);
	end	
end

function UpdateRightBoxPoint(grid_index)
	Log("kekeke UpdateRightBoxPoint:"..grid_index);
	local grid_num 	= ClientBackpack:getGridCount(STORAGE_START_INDEX);
	local rows	= 5;
	if grid_num > 30 then
		rows		= 10;
	end
	
	if grid_index >= STORAGE_START_INDEX and grid_index < STORAGE_START_INDEX+grid_num then
		local index = grid_index - STORAGE_START_INDEX + 1;
		if index > 30 then
			offsetY = math.ceil((index - 30)/6) * 83;
		else
			offsetY = 0;
		end
		getglobal("StorageRightBoxPlane"):SetPoint("topleft", "StorageRightBox", "topleft", 0, -offsetY);
		getglobal("StorageRightBox"):setCurOffsetY(-offsetY);
	end
end

function UpdateRightBoxOneStorageItem(grid_index, n)
	local icon = getglobal("StorageRightBoxStorageItem"..n.."Icon");
	local num = getglobal("StorageRightBoxStorageItem"..n.."Count");
	local durbkg = getglobal("StorageRightBoxStorageItem"..n.."DurBkg");
	local durbar = getglobal("StorageRightBoxStorageItem"..n.."Duration");

	UpdateGridContent(icon, num, durbkg, durbar, grid_index);
end

function StorageBoxFrameUpdateBg(bigStyle)
	local bkg = getglobal("StorageBoxFrameBkg")
	local leftBkg = getglobal("StorageBoxFrameLeftBkg")
	local rightBkg = getglobal("StorageBoxFrameRightBkg")
	local divider = getglobal("StorageBoxFrameDivider")
	local slidingPlane = getglobal("StorageRightBox")
	if bigStyle then
		bkg:SetHeight(600)
		-- 搭建模式快捷栏更大 需要往上偏移
		if IsUGCEditing() and UGCModeMgr:GetGameType() == UGCGAMETYPE_BUILD and ClientMgr:isPC() then
			bkg:SetPoint("bottom", "PlayShortcut", "top", 0, -20)
		else
			bkg:SetPoint("bottom", "PlayShortcut", "top", 0, 0)
		end
		leftBkg:SetHeight(454)
		rightBkg:SetHeight(454)
		divider:SetHeight(535)
		slidingPlane:SetHeight( 434)
	else
		bkg:SetHeight(575)
		-- 搭建模式快捷栏更大 需要往上偏移
		if IsUGCEditing() and UGCModeMgr:GetGameType() == UGCGAMETYPE_BUILD and ClientMgr:isPC() then
			bkg:SetPoint("bottom", "PlayShortcut", "top", 0, -35)
		else
			bkg:SetPoint("bottom", "PlayShortcut", "top", 0, -15)
		end
		leftBkg:SetHeight(434)
		rightBkg:SetHeight(434)
		divider:SetHeight(515)
		slidingPlane:SetHeight( 414)
	end
end

function StorageBoxFrame_OnShow()
	--血条地图等UI界面的显示与否成为了自定义ui功能的一部分，避免这里的HideAllFrame中的操作写死其显隐性所以这里注释掉
	-- HideAllFrame("StorageBoxFrame", false);
	local StorageRightBoxPlane = getglobal("StorageRightBoxPlane")
	local gridNum = 0;
	local containerName = getglobal("StorageBoxFrame"):GetClientString();
	local title = getglobal("StorageBoxFrameHeadTitle");
	local rightTitle = getglobal("StorageBoxFrameRightTitle");
	getglobal("StorageBoxFrameDesc"):SetText("");
	StorageBoxFrameUpdateBg(false)
	if string.find(containerName, "storage") then
		-- 高级创造，搭建模式打开储物箱隐藏快捷栏的加号
		if IsUGCEditing() and UGCModeMgr:GetGameType() == UGCGAMETYPE_BUILD then
			GetInst('SceneEditorMsgHandler'):dispatcher(SceneEditorUIDef.shortcut.show_add_empty_item)
		end

		title:SetPoint("left","StorageBoxFrameHead","left",33,0);
		title:SetText(GetS(3004));
		local blockId = getglobal("StorageBoxFrame"):GetClientUserData(0);
		if blockId ~= nil then
			local itemdef = ItemDefCsv:get(blockId)
			if itemdef then
				rightTitle:SetText(itemdef.Name);
			end
		end
		if blockId == 998 then	--初始补给箱
			getglobal("StorageBoxFrameDesc"):SetText(GetS(744));
		elseif blockId == 999 then	--复活补给箱
			getglobal("StorageBoxFrameDesc"):SetText(GetS(745));
		end
		getglobal("StorageBoxFrameEncryptBtn"):Hide();
		if blockId == 801 or blockId == 974 or blockId == 979 or blockId == 1180 or blockId == 1181 then		--储物箱
			StorageBoxFrameUpdateBg(blockId == 1180 or blockId == 1181)
			rightTitle:SetText(GetS(3004));
		elseif blockId == 998 then	--初始补给箱
			rightTitle:SetText(GetS(742));
			getglobal("StorageBoxFrameDesc"):SetText(GetS(744));
		elseif blockId == 999 then	--复活补给箱
			rightTitle:SetText(GetS(743));
			getglobal("StorageBoxFrameDesc"):SetText(GetS(745));
		elseif blockId == 1035 then
			rightTitle:SetText(GetS(1241));
			getglobal("StorageBoxFrameDesc"):SetText(GetS(1242));
		elseif OpenContainer:needSetPassword() then  --密码箱
			rightTitle:SetText(GetS(3004));
			getglobal("StorageBoxFrameEncryptBtn"):Show();
		end
		getglobal("StorageBoxFrameTidyBtn"):Show();
		gridNum = ClientBackpack:getGridCount(STORAGE_START_INDEX);
		if CurWorld and CurWorld:getOWID() == NewbieWorldId2 then
			local num = ClientBackpack:getGridNum(3000)
			local name = ClientBackpack:getGridItemName(3000);
			if num == 1 and name == "黄铜斧" then
				LuaGameEventTb.event("RookieGuide",{param={msgStr="guide1"}})
			elseif num == 1 and name == "能量剑" then
				num = ClientBackpack:getGridNum(3001)
				name = ClientBackpack:getGridItemName(3001)
				if num == 1 and name == "蓝钻胸甲" then
					LuaGameEventTb.event("RookieGuide",{param={msgStr="guide2"}})
				end
			end
		end
	elseif string.find(containerName, "funnel") then	--StringDef漏斗
		title:SetPoint("left","StorageBoxFrameHead","left",33,0);
		title:SetText(GetS(3188));
		rightTitle:SetText(GetS(3188)); 
		getglobal("StorageBoxFrameTidyBtn"):Hide();
		gridNum = ClientBackpack:getGridCount(FUNNEL_START_INDEX);
		gridNum = FUNNEL_GRID_MAX;
	elseif string.find(containerName, "emitter") then
		title:SetPoint("left","StorageBoxFrameHead","left",33,0);
		title:SetText(GetS(3189));
		if bUpdateEmitterStorageBoxRightTitle == true  then			
			rightTitle:SetText(GetS(1349)); --StringDef			
		else			
			rightTitle:SetText(GetS(3189)); --StringDef储物箱			
		end 
		-----rightTitle:SetText(GetS(3189)); --StringDef发射器
		getglobal("StorageBoxFrameTidyBtn"):Hide();
		gridNum = ClientBackpack:getGridCount(EMITTER_START_INDEX);
		gridNum = EMITTER_GRID_MAX;
	elseif string.find(containerName, "sensor") then
		title:SetText(GetS(1067));
		rightTitle:SetText(GetS(1067)); --StringDef发射器
		title:SetPoint("left","StorageBoxFrameHead","left",33,0);
		getglobal("StorageBoxFrameTidyBtn"):Hide();
		gridNum = ClientBackpack:getGridCount(SENSOR_START_INDEX);
		gridNum = SENSOR_GRID_MAX;
	elseif string.find(containerName, "rediointerpreter") then
		title:SetText(GetS(1067));
		rightTitle:SetText(GetS(1067)); --StringDef发射器
		title:SetPoint("left","StorageBoxFrameHead","left",33,0);
		getglobal("StorageBoxFrameTidyBtn"):Hide();
		gridNum = ClientBackpack:getGridCount(INTERPRETER_START_INDEX);
		gridNum = INTERPRETER_GRID_MAX;
	elseif string.find(containerName,"collider") then
		title:SetText(GetS(6586));
		rightTitle:SetText(GetS(6586));	--StringDef发射器
		title:SetPoint("left","StorageBoxFrameHead","left",33,0);
		getglobal("StorageBoxFrameTidyBtn"):Hide();
		gridNum = ClientBackpack:getGridCount(COLLIDER_START_INDEX);
		gridNum = COLLIDER_GRID_MAX
	end
	if gridNum > 30 then
		local rows = math.ceil(gridNum/6);
		StorageRightBoxPlane:SetSize(503, rows*83);	
	else	
		StorageRightBoxPlane:SetSize(503, 414);
	end
	for i=1, STORAGEBOX_GRID_MAX do
		local itembtn = getglobal("StorageRightBoxStorageItem"..i);
		if i <= gridNum then
			itembtn:Show();
		else
			itembtn:Hide();
		end
	end

	UpdateLeftBoxAllItem();
	UpdateRightBoxAllStorageItem();

	if ShortCut_SelectedIndex >= 0 then		--打开背包时，把选中的快捷栏工具隐藏
		local selbox = getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."Check");
		selbox:Hide()
	end

	if CurWorld:getOWID() == NewbieWorldId then
		local taskId = AccountManager:getCurNoviceGuideTask();
		if taskId == 18 then
			HideGuideFingerFrame();
		end
	end
	if not getglobal("StorageBoxFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end

	if isEducationalVersion then
		getglobal("StorageBoxFrameStashBtn"):Hide();
	end
end

function StorageBoxFrame_OnHide()
	getglobal("StorageBoxFrame"):SetClientString("");
	CurAttachedStorage = nil
	getglobal("StorageRightBox"):resetOffsetPos();
	getglobal("StorageLeftBox"):resetOffsetPos();
	
	if not getglobal("StorageBoxFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
	------红外感应器的设置面板打开
	if getglobal("SensorDistanceFrame"):IsShown() then
		getglobal("SensorDistanceFrame"):Hide()
	end

	CurMainPlayer:closeContainer();	

	HideShortCutAllItemBoxTexture();
	
	if ShortCut_SelectedIndex >= 0 then		--关闭背包时，把选中的快捷栏工具显示
		-- CurMainPlayer:setCurShortcut(ShortCut_SelectedIndex);  -- 去掉储物箱关闭触发玩家选择快捷栏事件 
		local selbox = getglobal("ToolShortcut"..(ShortCut_SelectedIndex+1).."Check");
		selbox:Show()
	end

	if getglobal("MItemTipsFrame"):IsShown() then
		getglobal("MItemTipsFrame"):Hide();
		SetStorageBoxTexture(nil);
	end

	if CurWorld:getOWID() == NewbieWorldId then
		local taskId = AccountManager:getCurNoviceGuideTask();
		if taskId == 18 then
			ShowCurNoviceGuideTask();
		end
	end

	getglobal("MoveProgressBarFrame"):Hide()
	getglobal("StorageBoxFrameEncryptBtn"):Hide()
	-- ShowMainFrame()
end

bUpdateEmitterStorageBoxRightTitle = false
function updateStorageBoxFrameRightTitle(bflag)
	local rightTitle = getglobal("StorageBoxFrameRightTitle");
	if rightTitle ~= nil then 
		if tonumber(bflag) == 1  then		   
			bUpdateEmitterStorageBoxRightTitle = true
			----rightTitle:SetText('投掷器'); --StringDef
		else			
			bUpdateEmitterStorageBoxRightTitle = false
			---rightTitle:SetText(GetS(3004)); --StringDef储物箱
		end 
	end 
end 

function StorageBoxFrameCloseBtn_OnClick()	
	getglobal("StorageBoxFrame"):Hide();
	getglobal("StorageBoxFrameEncryptBtn"):Hide();
	if getglobal("EncryptFrame"):IsShown() then
		EncryptFrameCloseBtn_OnClick()
	end
end

function StorageBoxFrameStashBtn_OnClick()
	StorageBoxFrameCloseBtn_OnClick();
	ShopJumpTabView(8)
end

function StorageBoxFrameTidyBtn_OnClick()
	CurMainPlayer:sortStorageBox();
	UpdateRightBoxAllStorageItem();
end

function StorageBoxFrameEncryptBtn_OnClick()

	getglobal("EncryptFrame"):Show();
end


function SetMoveStorageItemIndex(grid_index)
	MoveStorageItemIndex = grid_index;
end

function StorageLeftBoxPlace(grid_index)
	local itemId = ClientBackpack:getGridItem(grid_index);
	if itemId > 0 then
		CurMainPlayer:storeItem(grid_index, 1);
		SetStorageBoxTexture(nil);
	end
end

function StorageRightBoxPlace(grid_index)
	local itemId = ClientBackpack:getGridItem(grid_index);
	if itemId > 0 then
		BackPackAddItem(grid_index, 1, 2);
		SetStorageBoxTexture(nil);
	end
end

function SetStorageBoxTexture(btnName)
	if ClientMgr:isMobile() then
		for i=1, BACK_PACK_GRID_MAX do
			if i<=30 then
				local texture = getglobal("StorageLeftBoxItem"..i.."BoxTexture");
				texture:Hide();
			end
		end

		for i=1,STORAGEBOX_GRID_MAX do
			local texture = getglobal("StorageRightBoxStorageItem"..i.."BoxTexture");
			texture:Hide();
		end
	
		if btnName ~= nil then
			local texture = getglobal(btnName.."BoxTexture");
			texture:Show();
		end
	end
end

---------------------------------------------------------MoveProgressBarFrame--------------------------------------------------------
function MoveProgressBarFrame_OnHide()
	if MoveStorageItemIndex < 0 then return end
	if not ClientCurGame:isInGame() then return end
	
	local num = math.floor(ClientBackpack:getGridNum(MoveStorageItemIndex) * getglobal("MoveProgressBar"):GetValue());
	local durable =	ClientBackpack:getGridDuration(MoveStorageItemIndex);	

	if FF_GetFurnaceBtnClickSign() then
		if getFurnaceGridIndex() == -1 then 
			GetInst("UIManager"):GetCtrl("Furnace"):FurnaceItemOnclick(MoveStorageItemIndex,num);
		elseif getFurnaceGridIndex()== 9001 then
			GetInst("UIManager"):GetCtrl("Furnace"):PutGridBeforeClearSameGrid(MoveStorageItemIndex, FURNACE_START_INDEX, num);
		elseif getFurnaceGridIndex() == 9002 then
			GetInst("UIManager"):GetCtrl("Furnace"):PutGridBeforeClearSameGrid(MoveStorageItemIndex, FURNACE_START_INDEX + 1, num);
		end

		setFurnaceGridIndex(-1);
		FF_SetFurnaceBtnClickSign(false);
	end

    if not ClientBackpack:isHomeLandGameMakerMode() and MoveStorageItemIndex >= BACKPACK_START_INDEX and MoveStorageItemIndex < SHORTCUT_START_INDEX + 1000 then
		if BF_GetDrawingBtnClickSign() then
			BF_PutinGridMobile(MoveStorageItemIndex, num);
			BF_SetDrawingBtnClickSign(false);
		else
			if CurWorld:isGodMode() then
				num = math.floor(ClientBackpack:getGridMaxStack(MoveStorageItemIndex) * getglobal("MoveProgressBar"):GetValue());
			end
			if num > 0 then
				CurMainPlayer:storeItem(MoveStorageItemIndex, num);
			end
		end          
    elseif ClientBackpack:isHomeLandGameMakerMode() and ((MoveStorageItemIndex >= BACKPACK_START_INDEX and MoveStorageItemIndex < SHORTCUT_START_INDEX) or (MoveStorageItemIndex >= SHORTCUTEX_START_INDEX and MoveStorageItemIndex < SHORTCUTEX_START_INDEX + 1000)) then
		if BF_GetDrawingBtnClickSign() then
			BF_PutinGridMobile(MoveStorageItemIndex, num);
			BF_SetDrawingBtnClickSign(false);
		else
			if CurWorld:isGodMode() then
				num = math.floor(ClientBackpack:getGridMaxStack(MoveStorageItemIndex) * getglobal("MoveProgressBar"):GetValue());
			end
			if num > 0 then
				CurMainPlayer:storeItem(MoveStorageItemIndex, num);
			end
		end
	elseif num > 0 then
		if (MoveStorageItemIndex >= STORAGE_START_INDEX and MoveStorageItemIndex < STORAGE_START_INDEX+1000)
		   or (MoveStorageItemIndex >= FUNNEL_START_INDEX and MoveStorageItemIndex < FUNNEL_START_INDEX+1000)
		   or (MoveStorageItemIndex >= EMITTER_START_INDEX and MoveStorageItemIndex < EMITTER_START_INDEX+1000)
		   or (MoveStorageItemIndex >= SENSOR_START_INDEX and MoveStorageItemIndex < SENSOR_START_INDEX+1000) 
		   or (MoveStorageItemIndex >= COLLIDER_START_INDEX and MoveStorageItemIndex < COLLIDER_START_INDEX+1000)  then

			if WorldMgr and WorldMgr:isGodMode() and MoveStorageItemIndex >= STORAGE_START_INDEX and MoveStorageItemIndex < CRAFT_START_INDEX then -- 编辑模式可以拿出储物箱的物品到背包
				local toindex = -1
				local start = ((ClientBackpack and ClientBackpack:getShortcutStartIndex()) or SHORTCUT_START_INDEX)
				for i = start,start + 7 do
					local num =  ClientBackpack:getGridNum(i)
					if num <= 0 then
						toindex = i
						break
					end
				end
				if toindex <= -1 then
					for i = 1, 30 do
						local num =  ClientBackpack:getGridNum(BACKPACK_START_INDEX + i - 1)
						if num <= 0 then
							toindex = BACKPACK_START_INDEX + i - 1
							break
						end
					end
				end
				if toindex > -1 then -- 背包已满
					CurMainPlayer:moveItem(MoveStorageItemIndex,toindex,num);
				else
					ShowGameTips(GetS(2119))
				end
			else
				BackPackAddItem(MoveStorageItemIndex, num, 2)
			end
			
		end
	end 

	MoveStorageItemIndex = -1;
	getglobal("MoveProgressBarFrameDesc"):SetText("");
	
	if getglobal("MItemTipsFrame"):IsShown() then
		getglobal("MItemTipsFrame"):Hide();
		SetStorageBoxTexture(nil);
		SetToolShortcutTexture(nil);
	end
end






---------------------------------------------------------EncryptFrame--------------------------------------------------------
-- 密码箱

-- isLockBoxPassword = 0      --   0 错 1 正确

local ismove = true;
local PasswordBoxState = 0;         --0 设置密码 1 二次确认密码   2 客机输入密码

local EncryptPassword = {99,99,99,99}
local ComparedPassword = {99,99,99,99}
local EnterPassword = {99,99,99,99}

local UesrPassword = {99,99,99,99}

function EncryptFrame_Load()
	for i =1,4 do
		for j=0,9 do 
			local item = getglobal("EncryptNumber"..i.."Item"..j);
			local number = getglobal("EncryptNumber"..i.."Item"..j.."N")
			number:SetTexUV("font_pd_"..j..".png");

			item:SetPoint("topleft","EncryptNumber"..i.."Plane","topleft",23,(j)*67+12);
			item:SetSize(54,54);
		end
	end



	ClearNumberBkg();
end


function EncryptFrameCloseBtn_OnClick()
	ClearNumberBkg();
	ClearPassword();
	if PasswordBoxState == 1 then
		PasswordBoxState = 0;
	elseif PasswordBoxState == 2 then
		PasswordBoxState = 2;
	else 
		PasswordBoxState = 0;
	end

	getglobal("EncryptFrame"):Hide();

end





function NumberOfDigits(number)
	if number == -1 then
		return number
	end

	local n = string.len(number);
	local password

	if n == 1 then
		password = "1".."000"..number;
	elseif n == 2 then
		password = "1".."00"..number;
	elseif n == 3 then
		password = "1".."0"..number;
	elseif n == 4 then
		password = "1"..number;
	end

	return password;
end

function AirlinerOpenPasswordBox(state)
	-- local value =  NumberOfDigits(OpenContainer:getPassword());

	if  state  == 0 then
		ShowGameTips(GetS(1048), 3);
		return
	elseif state == 1 then
		PasswordBoxState = 2;
		getglobal("EncryptFrame"):Show();
	elseif state == 2 then
		ShowGameTips(GetS(1049), 3);
	end

end



function EncryptFrame_OnShow()
	getglobal("EncryptFrameTitle"):SetText(GetS(1044));
	-- PasswordGridMoveUpdate();
	--客机输入密码
	if PasswordBoxState == 2 then
		getglobal("EncryptFrameTitle"):SetText(GetS(1046));

		if not getglobal("EncryptFrame"):IsReshow() then
			ClientCurGame:setOperateUI(true);
		end
		return
	end

	-- print("************************这是密码",OpenContainer:getPassword());


	local value =  NumberOfDigits(OpenContainer:getPassword());

	-- if string.len(OpenContainer:getPassword())  == 1 then
	if  tonumber(value)  == -1 then
		ClearNumberBkg();
		for i=1,4 do
			getglobal("EncryptNumber"..i):setCurOffsetY(0);
		end
	-- elseif string.len(OpenContainer:getPassword()) ~= 0 then
	elseif tonumber(value) >= 10000 then
		local password = StringSplit(OpenContainer:getPassword(),""); 
  		local _,_,a,one,two,three,four = string.find(value, "(%d)(%d)(%d)(%d)(%d)");
  		-- print("******************这是处理过的密码",one,two,three,four)
  		local password = {tonumber(one),tonumber(two),tonumber(three),tonumber(four) };
		if next(password) ~= nil then
			for i=1,4 do
				UesrPassword[i] = password[i]
			end
			-- print("**************mima",UesrPassword);
		end
		MoveNumBerBTN()
	end
end


function EncryptFrame_OnHide()
	if PasswordBoxState == 2 then
		if not getglobal("EncryptFrame"):IsRehide() then
	       if ClientCurGame then 
			  ClientCurGame:setOperateUI(false);
		   end 
	    end
	end
end



function EncryptLabelBtn_OnClick()
	local digit = tonumber(string.sub(this:GetName(),-6,-6));
	local number = tonumber(string.sub(this:GetName(),-1,-1));

    print(getglobal("EncryptNumber1"):getCurOffsetY())


	for i=0,9 do
		getglobal("EncryptNumber"..digit.."Item"..i.."D"):Hide();
		if i == number then
			getglobal("EncryptNumber"..digit.."Item"..i.."D"):Show();
			
		end
	end


	if PasswordBoxState == 0 then
		ComparedPassword[digit] = number;
	elseif PasswordBoxState == 1 then
		EncryptPassword[digit] = number;
	elseif PasswordBoxState == 2 then
		EnterPassword[digit] = number;
	end

	-- MoveNumBerBTN();
end

function EncryptFrameConfirmtBtn_OnClick()


	--设置密码
	if PasswordBoxState == 0 then
		for k,v in ipairs(ComparedPassword) do
			if v == 99 then
				ShowGameTips(GetS(1128), 3);
				return
			end
		end


		for i=1,4 do
			getglobal("EncryptNumber"..i):setCurOffsetY(0);
		end
		getglobal("EncryptFrameTitle"):SetText(GetS(1045));
		PasswordBoxState = 1;
		ClearNumberBkg();

		return
	elseif PasswordBoxState ==  1 then    			--二次确认密码
		for k,v in ipairs(EncryptPassword) do
			if v == 99 then
				ShowGameTips(GetS(1128), 3);
				return
			end
		end

		for i= 1,4 do
			if EncryptPassword[i] ~= ComparedPassword[i] then
				ShowGameTips(GetS(1126), 3);
				return
			end
		end

		for i=1,4 do
			getglobal("EncryptNumber"..i):setCurOffsetY(0);
		end
		-- print("保存密码",table.concat(EncryptPassword))
		OpenContainer:setPassword(table.concat(EncryptPassword));  --保存密码

		for i =1,4 do
			EncryptPassword[i] = 99;
		end

		PasswordBoxState = 0;
		ClearNumberBkg();
		getglobal("EncryptFrame"):Hide();


		return
		--清空密码
	elseif PasswordBoxState == 2 then                 	--客机输入密码
		-- print("***********客机输入密码",PasswordBoxState);

		for k,v in ipairs(EnterPassword) do
			if v == 99 then 
				ShowGameTips(GetS(1128), 3);
				return
			end
		end


		for i= 1,4 do
			getglobal("EncryptNumber"..i):setCurOffsetY(0);
		end

		OpenContainer:setPassword(table.concat(EnterPassword));
		ClearNumberBkg();
		PasswordBoxState = 0;
		getglobal("EncryptFrame"):Hide();
		if not getglobal("EncryptFrame"):IsRehide() then
	       ClientCurGame:setOperateUI(false);
	    end

		return
	end

	ConfirmPassword();

end


function MoveNumBerBTN()

	for k,v in ipairs(UesrPassword) do
		local move = getglobal("EncryptNumber"..k.."Item"..v.."D"):Show();
		getglobal("EncryptNumber"..k):setCurOffsetY(-(68*v-68));


		ComparedPassword[k] = UesrPassword[k];
	end


end






function ClearPassword()
	for i =1,4 do
		EncryptPassword[i] = 99;
		ComparedPassword[i] = 99;
		EnterPassword[i] = 99;
	end
end


function ClearNumberBkg()
	for i =1,4 do
		for j=0,9 do 
			getglobal("EncryptNumber"..i.."Item"..j.."D"):Hide();
		end
	end
end

function ConfirmPassword()

end

function EncryptFrameZeroBtn_OnClick()
	for i=1,4 do
		getglobal("EncryptNumber"..i):setCurOffsetY(0);
	end
	ClearNumberBkg();

	if PasswordBoxState == 1 then
		for i =1,4 do
			EncryptPassword[i] = 99;
			-- ComparedPassword[i] = 99;
			EnterPassword[i] = 99;
		end
		return
	end


	ClearPassword();

end


function EncryptFrame_OnEvent()

end

function EncryptFrame_OnUpdate()

end



---------------------------------------------------------------------------
------------------红外感应器的面板事件处理------------------------------------
function getSensorDistanceDefaultValue()
	return 8
end

function BuildSensorDistanceFrame(isShow)
	local rightBkg = getglobal("StorageBoxFrameRightBkg")
	local StorageRightBoxPlane = getglobal("StorageRightBoxPlane")
	local StorageRightBox = getglobal("StorageRightBox")
	if isShow then
		rightBkg:SetSize(512, 177)
		StorageRightBoxPlane:SetSize(503, 157)
		StorageRightBox:SetSize(503, 157)
		StorageRightBoxPlane:SetPoint("topleft", "StorageRightBox", "topleft", 0, 0);
	else
		rightBkg:SetSize(527, 434)
		StorageRightBox:SetSize(503, 414)
	end
end

function SensorDistanceFrame_OnShow()
	BuildSensorDistanceFrame(true)
	getglobal("SensorDistanceFrameBar"):SetMinValue(1);
	getglobal("SensorDistanceFrameBar"):SetMaxValue(32);
	getglobal("SensorDistanceFrameBar"):SetValueStep(1);
	
	getglobal("StorageBoxFrameRightTitle"):SetText(GetS(12315))
	getglobal("SensorDistanceFrameTitle"):SetText(GetS(12316))

	if OpenContainer and OpenContainer.getSensorValue then
		local curvalue = OpenContainer:getSensorValue();

		getglobal("SensorDistanceFrameBar"):SetValue(curvalue)
		getglobal("SensorDistanceFrameVal"):SetText(curvalue)
	end
end

function SensorDistanceFrame_OnHide()
	BuildSensorDistanceFrame(false)
	local curvalue = getglobal("SensorDistanceFrameBar"):GetValue();

	if OpenContainer and OpenContainer.setSensorValue then
		OpenContainer:setSensorValue(curvalue)
	end
end 

function SensorDistanceFrame_SingleSliderTemplateBarOnValueChanged()
	local barview = getglobal("SensorDistanceFrameBar")
	local value = barview:GetValue();
	local ratio = (value-barview:GetMinValue())/(barview:GetMaxValue()-barview:GetMinValue());

	if ratio > 1 then ratio = 1 end
	if ratio < 0 then ratio = 0 end
	local width   = math.floor(262*ratio)

    local valPro = getglobal("SensorDistanceFrameBarPro")
	local valFont = getglobal("SensorDistanceFrameVal");

    if valPro ~= nil then
        valPro:ChangeTexUVWidth(width);
	    valPro:SetWidth(width);
    end
    if valFont ~= nil then
	    valFont:SetText(string.format("%d", value));
    end
end 

function SensorDistanceFrame_SingleSliderTemplateBtnOnClick(leftOrRight)
	local bar = getglobal("SensorDistanceFrameBar")
	local curvalue = bar:GetValue();
	local maxvalue = bar:GetMaxValue();
	local minvalue = bar:GetMinValue();
	local valueStep = bar:GetValueStep();
	if leftOrRight == 0 then
		curvalue = curvalue - valueStep;
   else
	    curvalue = curvalue + valueStep
   end
	if curvalue > maxvalue or curvalue < minvalue then return end
	bar:SetValue(curvalue)
   getglobal("SensorDistanceFrameVal"):SetText(curvalue)	
end 