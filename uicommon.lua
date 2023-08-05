
VK_LBUTTON = 0x01
VK_RBUTTON = 0x02
NewbieWorldId = 9999999;
NewbieWorldId2 = 9999901
-- NewbieWorldId2 = 55496520473434

MiniCoin_Star_Ratio = 1;
MiniCoin_Bean_Ratio = 6;
Max_Recycle_Get = 2;
InitModelViewAngle = 0;				--游戏界面模型的旋转角度
updateLetters = 0;
emptyframe = nil;

--是否显示格子的附魔或者符文 特效
function IsShowRuneOrEnchantGridEffect(gridindex,  itemid)
	if ClientBackpack:getRuneNum(gridindex) > 0 then 
		return true
	end
	return ClientBackpack:getGridEnchantNum(gridindex) > 0 or ItemDefCsv:get(itemid).IconEffect > 0
end


function IsEnableYouMeVoice()
	local yume_voice_option = check_apiid_ver_conditions(ns_version.yume_voice_option)
	return yume_voice_option;
end

function IsEnableYouMeVoiceForSecurity()
	-- body
	local is_developer = false
	if g_DeveloperInfo == nil then 
		is_developer = AccountManager and AccountManager:my_developerflag()
	else
		is_developer = true
	end
	is_developer = true
	return is_developer
end

--ignoreDynamicLoadFile 是否忽略动态加载UI的逻辑
function GetUIFrame(name, ignoreDynamicLoadFile)
	if not name then
		print("控件名为空")
		return nil  
	elseif not HasUIFrame(name) then 
		if EnableDynamicLoadFile and not ignoreDynamicLoadFile then
			local path = GetInst("UIManager"):GetPath(name)
      		if path then 
				ClientMgr:parseUIInXml(path)
				return GetUIFrame(name)
			else
				print("取不到控件: " .. name)
				return nil 
			end 
		else
			return nil 
		end 
	elseif UIFrameMgr and UIFrameMgr:SetLayoutFrameToGlobal(name) then
		--ToGlobal_TmpVar = UIFrameMgr:FindLayoutFrame(name)
		return ToGlobal_TmpVar
	else
		Log("Warning: frame '"..tostring(name).."' not exist");
		if emptyframe == nil and UIFrameMgr and UIFrameMgr:SetLayoutFrameToGlobal("EmptyFrame") then
			emptyframe = ToGlobal_TmpVar;
		end
		return emptyframe;
	end
end

function HasUIFrame(name)
	if not UIFrameMgr then return false end
	return UIFrameMgr:FindLayoutFrame(name)~=nil;
end

function IsUIFrameShown(name)
	if not HasUIFrame(name) then 
		return false
	else
		local frame = GetUIFrame(name)
		if frame and frame:IsShown() then 
			return true 
		else
			return false 
		end 
	end 
end

local getglobal = GetUIFrame
_G.getglobal = getglobal

function SetNullGrid(gridName)
	local icon = getglobal(gridName.."Icon");
	local count = getglobal(gridName.."Count");
	local check = getglobal(gridName.."Check");
	local durbkg = getglobal(gridName.."DurBkg");
	local dur = getglobal(gridName.."Duration");
	local redTag = getglobal(gridName.."RedTag")
	
	local enChantTexture1 = getglobal(icon:GetName().."FumoEffect1");
	local enChantTexture2 = getglobal(icon:GetName().."FumoEffect2");
	icon:SetTextureHuires(ClientMgr:getNullItemIcon());
	count:SetText("");
	durbkg:Hide();
	dur:Hide();
	enChantTexture1:Hide();	
	enChantTexture2:Hide();	

	if not string.find(gridName, "EquipGrid") then
		local ban = getglobal(gridName.."Ban");	
		if ban:IsShown() then
			ban:Hide();
		end
	end
	
	if check:IsShown() then
		check:Hide();
	end
	if redTag and redTag:IsShown() then
		redTag:Hide()
	end
end

function UpdateGridContent(iconbtn, numtext, durbkg, dur, grid_index, maxDuration)
	local enChantTexture1 = nil;
	local enChantTexture2 = nil;

	if HasUIFrame(iconbtn:GetName().."FumoEffect1") then
		enChantTexture1 = getglobal(iconbtn:GetName().."FumoEffect1");
	end
	if HasUIFrame(iconbtn:GetName().."FumoEffect2") then
		enChantTexture2 = getglobal(iconbtn:GetName().."FumoEffect2");
	end

	local itemid = ClientBackpack:getGridItem(grid_index);
	if itemid == 0 then
		iconbtn:SetTextureHuires(ClientMgr:getNullItemIcon());
		numtext:SetText("");
		durbkg:Hide();
		dur:Hide();
		if enChantTexture1 then
			enChantTexture1:Hide();	
		end
		if enChantTexture2 then
			enChantTexture2:Hide();	
		end
		return;
	end

	-- 信纸特别处理
	if itemid == ITEM_LETTERS then
	-- if updateLetters > 0 and (grid_index < BUILDBLUEPRINT_START_INDEX or grid_index > BUILDBLUEPRINT_START_INDEX + 1000) then
	-- 	--通过一次移动来刷新信纸内容
	-- 	CurMainPlayer:moveItem(grid_index, MOUSE_PICKITEM_INDEX, 1);
	-- 	CurMainPlayer:moveItem(MOUSE_PICKITEM_INDEX, grid_index, 1);
	-- 	updateLetters = updateLetters - 1;
	-- end
	
		if grid_index >= 0 and string.len(ClientBackpack:getGridUserdataStr(grid_index)) > 0 then
				itemid = ITEM_LETTERS_USED
		end
	end

	SetItemIcon(iconbtn, itemid, ClientBackpack:getGridUserdataStr(grid_index));
	if IsShowRuneOrEnchantGridEffect(grid_index, itemid) then
		iconbtn:setMask("particles/texture/item_light.png");
		iconbtn:SetMaskColor(ClientBackpack:getGridEnchantColor(grid_index));
		if enChantTexture1 then
			enChantTexture1:Show();	
		end
		--enChantTexture2:Show();
		--enChantTexture2:SetUVAnimation(40, true);	
		iconbtn:SetOverlay(true);
	else
		if enChantTexture1 then
			enChantTexture1:Hide();	
		end
		--enChantTexture2:Hide();	
		iconbtn:SetOverlay(false);
	end

	local count = ClientBackpack:getGridNum(grid_index);
	if count > 1 then
		numtext:SetText(count);
	else
		numtext:SetText("");
	end

	local fullWidth;
	if string.find(iconbtn:GetParent(),"MousePickItem") ~= nil then
		fullWidth = 50;
		if ClientMgr:isMobile() then
			fullWidth = 73;
		end
	else
		fullWidth = getglobal(iconbtn:GetParent()):GetWidth() * 0.9;
	end
	local maxdurVal = 0
	if IsInHomeLandMap and IsInHomeLandMap() then
		if maxDuration then
			--家园特别处理 --目前家园的道具耐久度没有在tool表里面 配置
			maxdurVal = maxDuration 
		end
	else
		maxdurVal = ClientBackpack:getGridMaxDuration(grid_index)
	end
	if maxdurVal > 0 then
		local durVal = ClientBackpack:getGridDuration(grid_index)

		if durVal < 0 then durVal = 0 end
		durVal = durVal/maxdurVal
		if durVal > 1 then durVal = 1 end
	--	durbar:SetTexUV(712, 164, durVal*59, 8)

		durbkg:SetWidth(fullWidth);
		durbkg:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
		durbkg:SetTexUV("img_progress_bar_du_dark.png")
		if grid_index == ENCHANT_START_INDEX+1 then
			dur:SetWidth(0.71 *fullWidth *durVal);
		elseif grid_index >= BACKPACK_START_INDEX and  grid_index < BACKPACK_START_INDEX+1000 then			
			dur:SetWidth(fullWidth*durVal);
		else
			dur:SetWidth(fullWidth*durVal);		
		end
		-- if durVal > 0.8 then dur:SetColor(0, 255, 0) --绿色
		-- elseif durVal > 0.6 then dur:SetColor(0, 128, 0) --深绿色
		-- elseif durVal > 0.4 then dur:SetColor(128, 128, 0) --棕色
		-- elseif durVal > 0.2 then dur:SetColor(255, 255, 0) --橙色
		-- else dur:SetColor(255, 0, 0) end --红色
		if durVal > 0.8 then  --绿色
			dur:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			dur:SetTexUV("img_progress_bar_du_green.png")
		elseif durVal > 0.6 then --深绿色
			dur:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			dur:SetTexUV("img_progress_bar_du_darkgreen.png")
		elseif durVal > 0.4 then --棕色
			dur:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			dur:SetTexUV("img_progress_bar_du_brown.png")
		elseif durVal > 0.2 then --橙色
			dur:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			dur:SetTexUV("img_progress_bar_du_orange.png")
		else
			dur:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			dur:SetTexUV("img_progress_bar_du_red.png")
		end --红色

		if durVal == 1.0 then
			durbkg:Hide();
			dur:Hide()
		else
			durbkg:Show();
			dur:Show()
		end
	else
		durbkg:Hide();
		dur:Hide();
	end
end

function UpdateItemIconCount(iconbtn, numtext, durbar, grid_index)
	local itemid = ClientBackpack:getGridItem(grid_index);
	local enChantTexture1 = getglobal(iconbtn:GetName().."FumoEffect1");
	local enChantTexture2 = getglobal(iconbtn:GetName().."FumoEffect2");

	if IsEduTouristMode() then--教育版游客模式
		itemid = 0;
	end

	if itemid == 0 then
		iconbtn:SetTextureHuires(ClientMgr:getNullItemIcon());
		numtext:SetText("");
		durbar:Hide();
		enChantTexture1:Hide();	
		enChantTexture2:Hide();	
		return;
	end

	SetItemIcon(iconbtn, itemid, ClientBackpack:getGridUserdataStr(grid_index));

	if IsShowRuneOrEnchantGridEffect(grid_index, itemid) then
		iconbtn:setMask("particles/texture/item_light.png");
		iconbtn:SetMaskColor(ClientBackpack:getGridEnchantColor(grid_index));
		enChantTexture1:Show();	
		--enChantTexture2:Show();	
		--enChantTexture2:SetUVAnimation(40, true);	
		iconbtn:SetOverlay(true);
	else
		enChantTexture1:Hide();	
		--enChantTexture2:Hide();	
		iconbtn:SetOverlay(false);
	end


	count = ClientBackpack:getGridNum(grid_index);
	if count > 1 then
		numtext:SetText(count);
	else
		numtext:SetText("");
	end

	maxdur = ClientBackpack:getGridMaxDuration(grid_index);
	if maxdur > 0 then
		dur = ClientBackpack:getGridDuration(grid_index)
		if dur < 0 then dur = 0 end
		dur = dur/maxdur
		--if dur > 1 then dur = 1 end
		durbar:SetTexUV(712, 164, dur*59, 8)
		if grid_index == ENCHANT_START_INDEX+1 then
			durbar:SetWidth(50*dur);
		elseif grid_index == HORSE_EQUIP_INDEX or grid_index == HORSE_EQUIP_INDEX+1 then
			durbar:SetWidth(112*dur);
		else
			durbar:SetWidth(72*dur);		
		end
		if dur > 0.8 then  --绿色
			durbar:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			durbar:SetTexUV("img_progress_bar_du_green.png")
		elseif dur > 0.6 then --深绿色
			durbar:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			durbar:SetTexUV("img_progress_bar_du_darkgreen.png")
		elseif dur > 0.4 then --棕色
			durbar:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			durbar:SetTexUV("img_progress_bar_du_brown.png")
		elseif dur > 0.2 then --橙色
			durbar:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			durbar:SetTexUV("img_progress_bar_du_orange.png")
		else
			durbar:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			durbar:SetTexUV("img_progress_bar_du_red.png")
		end --红色
		-- if dur > 0.8 then durbar:SetColor(0, 255, 0) --绿色
		-- elseif dur > 0.6 then durbar:SetColor(0, 128, 0) --深绿色
		-- elseif dur > 0.4 then durbar:SetColor(128, 128, 0) --棕色
		-- elseif dur > 0.2 then durbar:SetColor(255, 255, 0) --橙色
		-- else durbar:SetColor(255, 0, 0) end --红色

		if dur == 1.0 then durbar:Hide()
		else durbar:Show() end
	else
		durbar:Hide()
	end	
end

function UpdateCratingItemIconCountWithHomelandUnlock(iconbtn, numtext, durbar, grid_index, lack, name, desc, replaceID, unlock)
	UpdateCratingItemIconCount(iconbtn, numtext, durbar, grid_index, lack, name, desc, replaceID)
	unlock:Hide();
	local itemid = replaceID or ClientBackpack:getGridItem(grid_index);
	local itemDef = ItemDefCsv:get(itemid);
	if itemDef ~= nil and itemDef.UnlockFlag > 0 then
		if not isItemUnlockByItemId(itemDef.ID) then  --未解锁
			iconbtn:SetGray(true);
			lack:Hide();
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
	end
end

function UpdateCratingItemIconCount(iconbtn, numtext, durbar, grid_index, lack, name, desc, replaceID) --轮转的也处理了下 code_by:huangfubin
	local itemid = ClientBackpack:getGridItem(grid_index);

	if replaceID and ClientBackpack:getItemCountInNormalPack(replaceID)>0 then
		itemid = replaceID --只轮转有数量的资源
	end

	local itemDef = ItemDefCsv:get(itemid);
	if itemid == 0 or itemDef == nil then
		iconbtn:SetTextureHuires(ClientMgr:getNullItemIcon());
		lack:Hide();
		durbar:Hide();
		if grid_index >= PRODUCT_LIST_TWO_INDEX or grid_index == 2006 or grid_index == 4009 then
			if grid_index == 2006 or grid_index == 4009 then
				desc:SetText("", 101, 116, 118);
				name:SetText("");
			end
			numtext:SetText("");
		else
			desc:SetText("");
			name:SetText("");
			numtext:SetText("");
		end

		return;
	end

	SetItemIcon(iconbtn, itemid);

	local count = ClientBackpack:getGridNum(grid_index);

	--计算拥有的数量
	local isGroup = false;
	if grid_index >= MINICRAFT_START_INDEX and grid_index < MINICRAFT_START_INDEX + 6 and productSortId > 0 then
		local def = DefMgr:getCraftingDef(productSortId);
		if def and def.IsGroup then
			isGroup = true;
		end
	elseif grid_index >= CRAFT_START_INDEX and grid_index < CRAFT_START_INDEX + 6 and normalProductSortId > 0 then
		local def = DefMgr:getCraftingDef(normalProductSortId);
		if def and def.IsGroup then
				isGroup = true;
			end
		else
	end
	
	Log('UpdateCratingItemIconCount'..grid_index.."  group:"..tostring(isGroup));
	local hasNum = GetItemNum2Id(itemid, isGroup);

	local enough = ClientBackpack:getGridEnough(grid_index);
	Log("UpdateCratingItemIconCount enough:"..enough.."  grid_index:"..grid_index);

	local isStuff = true;
	if grid_index >= PRODUCT_LIST_TWO_INDEX or grid_index == 2006 or grid_index == 4009 then
		isStuff = false
	end

	
	if isStuff then
		name:SetText(itemDef.Name);
		if enough == 1 then
			numtext:SetText("#c01C210"..hasNum.."#n/"..count, 253, 253, 222);
			desc:SetText(itemDef.GetWay);
			desc:SetTextColor(101, 116, 118);
		elseif enough == 0 then
			numtext:SetText("#c01C210"..hasNum.."#n/"..count, 253, 253, 222);
			desc:SetText(GetS(3974));
			desc:SetTextColor(101, 116, 118);
		else
			numtext:SetText("#cf02011"..hasNum.."#n/"..count, 253, 253, 222);
			desc:SetText(itemDef.GetWay);
		end
	else
		if enough == 0 then
			iconbtn:SetGray(true);
			lack:Show();
			numtext:SetText("");
		else
			iconbtn:SetGray(false);
			lack:Hide();
			numtext:SetText(count);
		end
	end

	if grid_index == 2006 or grid_index == 4009 then
		name:SetText(itemDef.Name);
		desc:SetText(itemDef.Desc, 101,116,118);
	end

	durbar:Hide()
end

function UpdateVirtualItemIcon(iconbtn, numtext, durbar, grid_index, num, durbkg, btn, bForceHideEffect)
	local itemid = ClientBackpack:getGridItem(grid_index);
	local enChantTexture1 = getglobal(iconbtn:GetName().."FumoEffect1");
	local enChantTexture2 = getglobal(iconbtn:GetName().."FumoEffect2");
	if itemid == 0 then
		if btn ~= nil then
			btn:SetClientID(0);
		end
		iconbtn:SetTextureHuires(ClientMgr:getNullItemIcon());
		numtext:SetText("");
		durbar:Hide();
		durbkg:Hide();
		enChantTexture1:Hide();	
		enChantTexture2:Hide();	
		return;
	end
	if btn ~= nil then
		btn:SetClientID(itemid);
	end

	SetItemIcon(iconbtn, itemid);

	if (bForceHideEffect ~= true) and IsShowRuneOrEnchantGridEffect(grid_index, itemid) then
		iconbtn:setMask("particles/texture/item_light.png");
		iconbtn:SetMaskColor(ClientBackpack:getGridEnchantColor(grid_index));
		enChantTexture1:Show();	
		--enChantTexture2:Show();	
		--enChantTexture2:SetUVAnimation(40, true);	
		iconbtn:SetOverlay(true);
	else
		enChantTexture1:Hide();	
		--enChantTexture2:Hide();	
		iconbtn:SetOverlay(false);
	end

	if num > 1 then
		numtext:SetText(num);
	else
		numtext:SetText("");
	end

	maxdur = ClientBackpack:getGridMaxDuration(grid_index);
	if maxdur > 0 then
		durVal = ClientBackpack:getGridDuration(grid_index)
		if durVal < 0 then durVal = 0 end
		durVal = durVal/maxdur

		local fullWidth = 73;
		--[[
		if ClientMgr:isMobile() then
			fullWidth = 73;
		end
		]]

		local grid_width = iconbtn:GetRealRight() - iconbtn:GetRealLeft() - 4;
		durbar:SetWidth(fullWidth*durVal);

		if durVal > 0.8 then  --绿色
			durbar:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			durbar:SetTexUV("img_progress_bar_du_green.png")
		elseif durVal > 0.6 then --深绿色
			durbar:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			durbar:SetTexUV("img_progress_bar_du_darkgreen.png")
		elseif durVal > 0.4 then --棕色
			durbar:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			durbar:SetTexUV("img_progress_bar_du_brown.png")
		elseif durVal > 0.2 then --橙色
			durbar:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			durbar:SetTexUV("img_progress_bar_du_orange.png")
		else
			durbar:SetTextureHuiresXml("ui/mobile/texture0/operate.xml")
			durbar:SetTexUV("img_progress_bar_du_red.png")
		end --红色

		-- if durVal > 0.8 then durbar:SetColor(0, 255, 0) --绿色
		-- elseif durVal > 0.6 then durbar:SetColor(0, 128, 0) --深绿色
		-- elseif durVal > 0.4 then durbar:SetColor(128, 128, 0) --棕色
		-- elseif durVal > 0.2 then durbar:SetColor(255, 255, 0) --橙色
		-- else durbar:SetColor(255, 0, 0) end --红色

		if durVal == 1.0 then
			durbar:Hide()
			durbkg:Hide();
		else
			durbar:Show();
			durbkg:Show();
		end
	else
		durbar:Hide();
		durbkg:Hide();
	end
end

--把物品放到背包
--grid_index 	把这个格子放到到背包
--num		放置的数量
--priorityType	放置的优先级 1快捷栏 2是背包
function BackPackAddItem(grid_index, num, priorityType)
	CurMainPlayer:lootItem(grid_index, num);
--[[
	local itemId = ClientBackpack:getGridItem(grid_index);
	if itemId > 0 then
		local placeNum = ClientBackpack:addItem(grid_index, itemId, num, priorityType);
		local remainNum = num - placeNum;
		if remainNum > 0 then
			CurMainPlayer:discardItem(grid_index, remainNum);
		end

		ClientBackpack:removeItem(grid_index, num);
	end
]]
end

--从背包放物品到其它类型格子
function OtherAddItem(from_grid, to_grid, placeNum)
	local itemId = ClientBackpack:getGridItem(to_grid);
	if itemId > 0 then
		local num = ClientBackpack:getGridNum(to_grid);
		BackPackAddItem(to_grid, num, 1);
	end
	ClientBackpack:placeItem(from_grid, to_grid, placeNum);
end

--是否在使用网络
function CanUseNet()
	if ClientMgr:isSharingOWorld() then		
		ShowGameTips(GetS(8), 3);
		return false;
	end
	return true;
end

--游戏退到后台的相关处理
function GameStop()
	if ClientCurGame:isInGame() then
		if IsRoomOwner() then	--房主
			LeaveRoomType = 3;
			AccountManager:sendToClientKickInfo(3);	
			SendMsgWaitTime = 0.5;
		end
	end
end

--退出游戏的相关处理
function GameDestroy()
	local uin = AccountManager:getUin();
	if ClientMgr:getApiId() == 15 and uin > 1 then	--360
		local nickName = AccountManager:getNickName();
		local coinNum = AccountManager:getAccountData():getMiniCoin();
		SdkManager:setSdkRoleInfo(nickName, "exitServer", uin, coinNum);
	end
end

function GamePause()
	if ClientCurGame and ClientCurGame:isInGame() then
		if GetInst("QQMusicPlayerManager") then
			GetInst("QQMusicPlayerManager"):OnPause()
		end

		if GetInst("QQMusicTriggerManager") then
			GetInst("QQMusicTriggerManager"):OnPause()
		end
		
		if GetInst("MiniClubPlayerManager") then
			GetInst("MiniClubPlayerManager"):OnPause()
		end
	end
end

--回到游戏
function GameResume()
	Log("GameResume:"..tostring(ns_data.needRefreshMarketActivityUI));
	IsGamePause = false;
	if AccountManager:isLogin() and ns_data.needRefreshMarketActivityUI then
		ns_data.needRefreshMarketActivityUI = false;
		ActivityMainCtrl:RequestWelfareRewardData()
	end	
	GameEventQue:postGameResume();

	-- 音乐播放器
	if GetInst("QQMusicPlayerManager") and ClientCurGame and ClientCurGame:isInGame() then
		GetInst("QQMusicPlayerManager"):OnResume()
	end

	if GetInst("QQMusicTriggerManager") and ClientCurGame and ClientCurGame:isInGame() then
		GetInst("QQMusicTriggerManager"):OnResume()
	end
	
	if GetInst("MiniClubPlayerManager") and ClientCurGame and ClientCurGame:isInGame() then
		GetInst("MiniClubPlayerManager"):OnResume()
	end
	
	if GetInst("MusicNumShareManager") then
		GetInst("MusicNumShareManager"):OnResume()
	end

	if GetInst("ActivityMoneyGodManager") then
		GetInst("ActivityMoneyGodManager"):OnResume()
	end
	
	if GetInst("ActivityAwakenManager") then
		GetInst("ActivityAwakenManager"):OnResume()
	end
	
	if GetInst("SanrioActInterface") then
		GetInst("SanrioActInterface"):OnResume()
	end
	
	if GetInst("NationdayInterface") then
		GetInst("NationdayInterface"):OnResume()
	end
	
	if GetInst("AotuActInterface") then
		GetInst("AotuActInterface"):OnResume()
	end

	if GetInst("ActivityAddFriendsManager") then
		GetInst("ActivityAddFriendsManager"):OnResume()
	end
	if GetInst("BoatFestivalManager") then
		GetInst("BoatFestivalManager"):OnResume()
	end
	if GetInst("MapShareInterface") then
		GetInst("MapShareInterface"):OnResume()
	end
	
	if GetInst("TangDynastyDataManager") then
		GetInst("TangDynastyDataManager"):OnResume()
	end
	if g_community_enter_stamp and g_community_enter_stamp ~= 0 then
		--埋点上报停留社区时长
		local stayTime = os.time() - g_community_enter_stamp
		g_community_enter_stamp = 0
		standReportEvent("58", "MINI_COMMUNITY_CONTAINER", "Exit", "click", {standby1 = tostring(stayTime)})
	end
	if GetInst("MiniUIManager"):GetCtrl("Time_limited_gift") then
		GetInst("MiniUIManager"):GetCtrl("Time_limited_gift"):CheckPermission()
	end

	if ClientCurGame and ClientCurGame:isInGame() then
		if IsRoomClient() then --客机从后台切换到前天同步一次自己的属性，避免后台期间死亡，导致客机游戏不正常
			SandboxLuaMsg.sendToHost(SANDBOX_LUAMSG_NAME.GLOBAL.MULTII_GAME_MEMBER_ON_RESUME_TOHOST, {});
		end
	end
end



--判断是否为新手地图
function IsNewbieWorld(worldId)
	if worldId == NewbieWorldId or worldId == NewbieWorldId2 then
		return true;
	else
		return false;
	end	
end

--自动添加手持物品
function AutoAddCurShortCutItem(itemId)
	if ShortCut_SelectedIndex < 0 then return end

	local CurId = ClientBackpack:getGridItem(ShortCut_SelectedIndex+ClientBackpack:getShortcutStartIndex());
	if CurId ~= 0 then	--没用完或者耐久度还未为0
		return;
	end
	for i=1, 8 do
		local grid_index = ClientBackpack:getShortcutStartIndex()+i-1;
		local packItemId = ClientBackpack:getGridItem(grid_index);
		if itemId == packItemId then
			CurMainPlayer:swapItem(grid_index, ShortCut_SelectedIndex+ClientBackpack:getShortcutStartIndex());
			return;
		end
	end

	for i=1, BACK_PACK_GRID_MAX do
		if i <= 30 then
			local grid_index = BACKPACK_START_INDEX+i-1;
			local packItemId = ClientBackpack:getGridItem(grid_index);
			if itemId == packItemId then
				CurMainPlayer:swapItem(grid_index, ShortCut_SelectedIndex+ClientBackpack:getShortcutStartIndex());
				return;
			end
		end
	end
end

--获得物品提示
-- 这里加一个name参数用来标识是不是物理机械，物理机械直接使用name，不查询itemdef表
function GetItemTips(itemId, num, name)
	if num <= 0 then return end
	print("GetItemTips",itemId, num, name)
	if name == nil or name == "" then
		local itemDef = ItemDefCsv:get(itemId);
		if itemDef ~= nil then
			local text = GetS(650, itemDef.Name, num);
			UpdateTipsFrame(text, 0);
		end
	else
		local text = GetS(650, name, num);
		UpdateTipsFrame(text, 0);
	end
end

--是不是武器装扮Icon
function IsWeaponSkinIcon(itemDef)
	if itemDef and itemDef.Icon and itemDef.Icon ~= "" and string.sub( itemDef.Icon, 1, 3 ) == "gun" then
		return true
	end
	return false
end

-- 武器道具皮肤ICON
function SetItemSkinIcon(itemId)
	local weaponCellBg = {
		"img_icon_custom",
		"img_icon_custom_zs",
		"img_icon_custom_hs",
		"img_icon_custom_cs",
	}
	local icon = getglobal("MItemTipsFrameIcon2")
	local iconBoxBg = getglobal("MItemTipsFrameBoxTexture2")
	local iconBkg = getglobal("MItemTipsFrameBkgTexture2")
	local uin = AccountManager:getUin()
	local skinId = 0

	if icon then icon:Show() end
	if iconBkg then iconBkg:Show() end
	if iconBoxBg then iconBoxBg:Show() end
	
	if WeaponSkin_HelperModule then
		skinId = WeaponSkin_HelperModule:GetSkinID(AccountManager:getUin(), itemId)
		if skinId > 0 then
			local weaponDef = WeaponSkin_HelperModule:GetSkinDataById(skinId)
			if weaponDef and GetInst("ShopService") and GetInst("ShopService"):CheckSkinWeaponRes(skinId, icon) == 0 then 
				--资源已下载
				local path = string.format("ui/gunicons/%d.png",weaponDef.Photo)
				if icon then
					icon:SetTexture(path)
				end

				if iconBoxBg then
					iconBoxBg:SetTextureHuiresXml("ui/mobile/texture0/shop.xml")
					if weaponCellBg[weaponDef.Level] then
						iconBoxBg:SetTexUV(weaponCellBg[weaponDef.Level])
					else
						iconBoxBg:SetTexUV(weaponCellBg[1])
					end
				end
				return
			end 
		else
			if icon then icon:Hide() end
			if iconBkg then iconBkg:Hide() end
			if iconBoxBg then iconBoxBg:Hide() end
		end
	end
end

--根据Id设置Icon
function SetItemIcon(icon, itemId, userdatastr,defaultitem)

	if itemId and type(itemId) ~= "number" then
		itemId = tonumber(itemId)
	end

	local itemDef = nil
	local usedefault = false
	-- Block的Item
	local function getitemdef(Id)
		if not Id or Id <= 0 then return nil end
		local def = ModEditorMgr:getBlockItemDefById(Id)
		if def == nil then
			def = ModEditorMgr:getItemDefById(Id)
		end
		if def == nil then
			def = ItemDefCsv:get(Id)
		end
		return def
	end

	itemDef = getitemdef(itemId) 
	if itemDef == nil then
		itemDef =  getitemdef(defaultitem)
		if itemDef == nil then
			if IsInHomeLandMap and IsInHomeLandMap() then
				--家园高低版本兼容
				icon:SetTexture("items/unknown.png", true)
			end

			return
		end
		usedefault = true
	end
	
	--微雕模型图标
	if itemDef then
		if itemDef.Icon == "customblock" or itemDef.Icon == "fullycustomblock" or itemDef.Icon == "importcustomblock"  then
			local blockDef = ModEditorMgr:getBlockDefById(itemId);
			if blockDef == nil then
				blockDef = BlockDefCsv:get(itemId);
			end

			if blockDef then
				if itemDef.Icon == "fullycustomblock" then
					SetModelIcon(icon, blockDef.Texture2, FULLY_BLOCK_MODEL);
				elseif itemDef.Icon == "importcustomblock" then
					SetModelIcon(icon, blockDef.Texture2, IMPORT_BLOCK_MODEL);
				else
					SetModelIcon(icon, blockDef.Texture2);
				end
				return;
			end
		elseif itemDef.Icon == "customitem" then
			SetModelIcon(icon, itemDef.Model, WEAPON_MODEL);
			return;
		elseif itemDef.Icon == "fullycustomitem" then
			SetModelIcon(icon, itemDef.Model, FULLY_ITEM_MODEL);
			return;
		elseif itemDef.Icon == "fullycustompacking" then
			SetModelIcon(icon, itemDef.Model, FULLY_PACKING_CUSTOM_MODEL);
			return;
		elseif itemDef.Icon == "customegg" then
			SetModelIcon(icon, itemDef.Model, ACTOR_MODEL);
			return;
		elseif itemDef.Icon == "fullycustomegg" then
			SetModelIcon(icon, itemDef.Model, FULLY_ACTOR_MODEL);
			return;
		elseif itemDef.Icon == "vehicleitem" then
			local modelname = itemDef.Model
			-- local data = JSON:decode(userdatastr)
			-- if modelname == "" and data and data.filename and data.filename ~= "" then
			-- 	modelname = data.filename
			-- end

			if userdatastr ~= "" then
				local posF = string.find(userdatastr, "\"filename\"")
				if posF ~= nil then
					local pos1 = string.find(userdatastr, ":", posF)
					local pos2 = string.find(userdatastr, ",", posF)
					pos1 = string.find(userdatastr, "\"", pos1)
					pos2 = string.find(userdatastr, "\"", pos1 + 1)
					local filename = string.sub(userdatastr, pos1 + 1, pos2 - 1)
					if modelname == "" and filename ~= nil and filename ~= "" then
						modelname = filename
					end
				end
			end
			SetVehicleModelIcon(icon, itemDef.ID, modelname ,userdatastr, VEHICLE_MODEL);
			return
		elseif itemDef.Icon == "importcustommodel" then
			SetModelIcon(icon, itemDef.Model, IMPORT_ACTOR_MODEL);
			return;
		end
	end

	--添加武器皮肤相关Icon gun1 gun2
	if IsWeaponSkinIcon(itemDef) then
		local iconID = tonumber(string.sub(itemDef.Icon,4)) or 0
		icon:SetTexture("ui/gunicons/".. iconID ..".png", true)
		return 
	end

	--添加称号相关icon
	if itemDef.Type == 23 then
		--itemDef.ShowId
		GetInst("TitleSystemInterface"):SetTitleIconByTitleid(icon,itemDef.ShowId,itemId)
		return
	--添加头像相关icon
	elseif itemDef.Type == 25 then
		icon:SetTexture("ui/roleicons/".. itemDef.ShowId ..".png", true)
		return 
	end

	if itemDef and itemDef.Icon and itemDef.Icon ~= "" and string.find(itemDef.Icon, "%*") then
		itemId = tonumber(string.sub(itemDef.Icon,2, -1)) or 0;
	end
	if itemDef and itemDef.Icon and itemDef.Icon ~= "" and string.sub( itemDef.Icon, 1, 2 ) == "hf" then
		itemId = tonumber(string.sub(itemDef.Icon, 3)) or 0;
		local texture_path = HeadFrameCtrl:getTexPath( itemId )    --人物头像框
		icon:SetTexture(texture_path, true)
		return
	end	
	if itemDef and itemDef.Icon and itemDef.Icon ~= "" and string.sub(itemDef.Icon, 1, 5) == "icona" then 
		--Avatar头像，以"a"开头
		if itemDef.InvolvedID then 
			local avatarDef = ModMgr:tryGetMonsterDef(itemDef.InvolvedID)
			AvatarSetIconByID(avatarDef,icon)
			return 
		end 
	end 

	local u = 0;
	local v = 0;
	local width = 0;
	local height = 0;
	local r = 255;
	local g = 255;
	local b = 255;
	local h = nil;



	-- 生物蛋相关：设置过插件 显示就要按照monster的图标来显示 
	-- MobEgg_OnUse对应的itemid减10000就是对应的monsteid
	local actorMapDef
	if itemDef.UseScript == "MobEgg_OnUse" then
		local monsterId = g_EggToMonster[itemId]
		if monsterId == nil then monsterId = itemId-10000 end
		actorMapDef = ModMgr:tryGetMonsterDef(monsterId)
	end
	if actorMapDef then
		SetActorIcon(icon, itemId - 10000)
	else
		--可染色方块，根据userdata更换贴图颜色
		if userdatastr and userdatastr ~="" and IsDyeableBlockLua(itemId) then
			local defaultid = GetDefaultBlockId(itemId)
			if defaultid == -1 then
				defaultid = itemId
			end

			h = ClientMgr:getItemIcon(usedefault and defaultitem or defaultid , u, v, width, height, r, g, b);
			local tempr = r
			local tempg = g
			local tempb = b
			local color = GetColorFromBlockInfo(itemId,userdatastr)
			if color ~=-1 or color ~=0 then
				tempb = color % 256
				tempg = ((color)/256) % 256
				tempr = ((color)/(256*256)) % 256

			end

			if h then
				icon:SetTextureHuires(h);
				icon:SetTexUV(u, v, width, height);

				icon:SetColor(tempr, tempg, tempb);
			end
		else
			h = ClientMgr:getItemIcon(usedefault and defaultitem or itemId , u, v, width, height, r, g, b);
			if h then
				icon:SetTextureHuires(h);
				icon:SetTexUV(u, v, width, height);
				icon:SetColor(r, g, b);
			end
		end

	end
end

function SetActorIcon(icon, monsterId)
	local def = ModEditorMgr:getMonsterDefById(monsterId) or MonsterCsv:get(monsterId);
	if def then

		local _iconId = tonumber(def.Icon) or -1;

		if _iconId ~= -1 then
			local _isRideIcon = false;
			if DefMgr:getHorseDef(_iconId) then
				_isRideIcon = true;
			end
			if _isRideIcon and gFunc_isFileExist("ui/rideicons/".. def.Icon ..".png") then  -- 官方坐骑插件包 该目录中不存在该文件
				icon:SetTexture("ui/rideicons/".. def.Icon ..".png", true);
			else
				icon:SetTexture("ui/roleicons/".. def.Icon ..".png", true);
			end
		end
		
		if type(def.Icon) == "string" then
			if (string.sub(def.Icon,1,1)) == "a" then
				--avatar图标
				local pluginId = string.sub(def.Icon,2,string.len(def.Icon))
				local avatarPlugins = AvatarGetPlugins()
				local args = FrameStack.cur()
				if args.isMapMod then
					AvatarSetIconByID(def,icon)
				else
					--AvatarGetPlugins()这个方法里面没有插件包里面插件引用的avt信息
					--所以优先使用插件的avt，不行再走默认方法AvatarSetIconByIDEx
					-- local model = pluginId
					-- local id = def.ID;
					-- if def.gamemod then 
					-- 	local avatarJson = def.gamemod:getModAvatarInfo(def.ID)
					-- 	avatarJson = JSON:decode(avatarJson)
					-- 	HeadCtrl:SetAvatarHeadIcon(icon, avatarJson, id);
					-- else
					-- 	AvatarSetIconByIDEx(pluginId,icon)
					-- end
					AvatarSetIconByIDEx(pluginId,icon)
				end
			end
		end
	end
end

--按物品it设置对应的texture
function  g_SetItemTexture( item_, id_ )
	local itemDef = ItemDefCsv:get(id_);
	local texture_path;	
	if  itemDef and  itemDef.Icon then		
		local first_ = string.sub( itemDef.Icon, 1, 1 );
		if       first_ == '@' then  
			texture_path = "ui/rideicons/" .. string.sub(itemDef.Icon,2) .. ".png";   --坐骑
		elseif  first_ == '#' then
			texture_path = "ui/roleicons/" .. string.sub(itemDef.Icon,2) .. ".png";   --人物头像
		elseif  first_ == 'h' then
			if  string.sub( itemDef.Icon, 1, 2 ) == "hf" then
				texture_path = HeadFrameCtrl:getTexPath( tonumber(string.sub(itemDef.Icon,3)) )   --人物头像框
			end
		elseif  first_ == '$' or first_ == "["  or first_ == '<' then
			Log("call SetItemIcon =" .. id_ );
			SetItemIcon( item_, id_ );     --3d物品			
		else
			if IsWeaponSkinIcon(itemDef) then --武器皮肤
				local iconID = tonumber(string.sub(itemDef.Icon,4)) or 0
				texture_path = "ui/gunicons/".. iconID ..".png"
			else
				if not itemDef.Icon or #itemDef.Icon == 0 then
					SetItemIcon( item_, id_ );     --3d物品
				else
					texture_path = "items/" .. itemDef.Icon .. ".png";   --普通item
				end
			end
		end

		if  texture_path then
			if tolua.type(item_) == "miniui.GLoader" then
				item_:setIcon(texture_path);
			else
				item_:SetTexUV(0,0,0,0);
				item_:SetTexture(texture_path);
			end
		end
		
	end
end

--根据道具id获取道具配置信息
function Getitemdef(Id)
	if not Id or Id <= 0 then return nil end
	local def = ModEditorMgr:getBlockItemDefById(Id)
	if def == nil then
		def = ModEditorMgr:getItemDefById(Id)
	end
	if def == nil then
		def = ItemDefCsv:get(Id)
	end
	return def
end

--角色拥有的Item的数量
function GetItemNum2Id(itemId, group)
	local num = 0;
	if itemId == 14001 then
		num = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	else
		for i=1,BACK_PACK_GRID_MAX do
			local grid_index = i + BACKPACK_START_INDEX - 1;
			local id = ClientBackpack:getGridItem(grid_index);
			if id > 0 and id == itemId then
				num = num + ClientBackpack:getGridNum(grid_index);
			elseif group then
				local def = ItemDefCsv:get(id);
				if def and def.ItemGroup > 0 and def.ItemGroup == itemId then
					num = num + ClientBackpack:getGridNum(grid_index);
				end
			end
		end

		for i=1,MAX_SHORTCUT do
			local grid_index = i + ClientBackpack:getShortcutStartIndex() - 1;
			local id = ClientBackpack:getGridItem(grid_index);
			if id > 0 and id == itemId then
				num = num + ClientBackpack:getGridNum(grid_index);
			elseif group then
				local def = ItemDefCsv:get(id);
				if def and def.ItemGroup > 0 and def.ItemGroup == itemId then
					num = num + ClientBackpack:getGridNum(grid_index);
				end
			end
		end
	end

	return num;
end

--MD5测试
--[[
function Md5Test(md1, md2)
	local text = "md1:"..md1.."md2:"..md2;
	getglobal("RSConnectLostFrameDesc"):SetText(text, 255, 255, 255);
	getglobal("RSConnectLostFrame"):Show();
	getglobal("RSConnectLostFrame"):SetClientUserData(0, 1);
end
]]

-- 联机断开时给予广告奖励
local function ConnectLostWatchAdGetAward(position_id)
	Log("local ConnectLostWatchAdGetAward position_id = "..position_id);
	if IsAdUseNewLogic(position_id) then
		GetInst("AdService"):IsAdCanShow(position_id, function(result, ad_info)
			local adTips = getglobal("RSConnectLostFrameADTips");
			if 6 == position_id then
				adTips:SetText(GetS(4929));
			elseif 8 == position_id then
				adTips:SetText(GetS(4898));
			end
			if 0 == ad_data_new.lostConnectPosId then
				ad_data_new.lostConnectPosId = position_id;
			end
			adTips:Show();
			getglobal("RSConnectLostFrameWatchADBtn"):Show();
			getglobal("RSConnectLostFrameConfirmBtn"):SetPoint("bottom", "RSConnectLostFrameChenDi", "bottom", -125, -26);
			StatisticsADNew('show', position_id, ad_info);
			if AccountManager.ad_show then
				AccountManager:ad_show(position_id);
			end
			GetInst("AdService"):Ad_Show(position_id)
		end)
	else
		if t_ad_data.canShow(position_id) then
			local adTips = getglobal("RSConnectLostFrameADTips");
			if 6 == position_id then
				adTips:SetText(GetS(4929));
			elseif 8 == position_id then
				adTips:SetText(GetS(4898));
			end
			if 0 == t_ad_data.lostConnectPosId then
				t_ad_data.lostConnectPosId = position_id;
			end
			adTips:Show();
			getglobal("RSConnectLostFrameWatchADBtn"):Show();
			getglobal("RSConnectLostFrameConfirmBtn"):SetPoint("bottom", "RSConnectLostFrameChenDi", "bottom", -125, -26);
			StatisticsAD('show', position_id);
			if AccountManager.ad_show then
				AccountManager:ad_show(position_id);
			end
		end
	end
end

function QuickUpRentDebugRoomConnectLost(cause)
	if RentPermitCtrl:IsQuickUpRentDebugRoom() then
		SetExitReason(cause)
		GetInst("MessageBoxInterface"):SlgBtnBox(string.format("%s(%s)", GetS(1000156), tostring(cause)), nil, function()
			if ClientCurGame:isInGame() then
				HideAllFrame(nil, false);
				for i=1, #(t_BackMainMenuNeedHideFrame) do
					local frame = getglobal(t_BackMainMenuNeedHideFrame[i]);
					if frame:IsShown() then
						frame:Hide();
					end
				end
				ClientMgr:gotoGame("MainMenuStage");
			end
		end)
		return true
	end
	return false
end

--联机断开连接
function RSConnectLost(cause, kickertype)
	if QuickUpRentDebugRoomConnectLost(cause) then
		return
	end
	if cause == 3 then
		ShowGameTips(GetS(4985), 3)
		return
	end
	
	getglobal("RSConnectLostFrameADTips"):Hide();
	getglobal("RSConnectLostFrameWatchADBtn"):Hide();
	getglobal("RSConnectLostFrameConfirmBtn"):SetPoint("bottom", "RSConnectLostFrameChenDi", "bottom", 0, -26);
	if getglobal("RSConnectLostFrame"):IsShown() or getglobal("NRSConnectLost"):IsShown() then
		return
	end

	if IsCustomGameEnd or RecordPkgMgr:isRecordPlaying() then
		return
	end

	if ClientCurGame and ClientCurGame:isInGame() and not (IsInHomeLandMap and IsInHomeLandMap()) then
		pcall(
			function()
				if not PlatformUtility:isPureServer() then
					SafeCallFunc(GetInst("ArchiveLobbyRecordManager").CacheAddRecord, GetInst("ArchiveLobbyRecordManager"))
				end
			end
		)
	end

	-- 新版的弹窗 不能是在家园里
	local showNew = false
	if not (ClientCurGame and ClientCurGame:isInGame() and IsInHomeLandMap and IsInHomeLandMap()) then
		if GetInst("NRSConnectLostInterface"):CheckCondition(cause, RoomInteractiveData) then
			local hostUin = ""
			local reportTb = {}
			if ClientCurGame and ClientCurGame:isInGame() then
				if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then
					local roomId = ClientMgr:getCurrentRentRoomId();
					local room_uin = ClientMgr:getCurrentRentRoomUin();
					hostUin = "" .. room_uin.."_"..roomId
					reportTb.standby1 = "11"
				else
					hostUin = "" .. ClientCurGame:getHostUin()					
					local roomDesc = AccountManager:getCurHostRoom()
					if roomDesc then
						reportTb.standby1 = 0
						if "number" == type(roomDesc.connect_mode) then
							reportTb.standby1 = roomDesc.connect_mode + 1
						end
						reportTb.standby1 = reportTb.standby1 * 10
						-- PC大房间: 人数>6
						if roomDesc.maxplayers and roomDesc.maxplayers > 6 then
							reportTb.standby1 = reportTb.standby1 + 4
						elseif roomDesc.extraData then
							local t_extra = JSON:decode(roomDesc.extraData)
							if t_extra then
								if t_extra.platform then
									-- PC服务器
									if t_extra.platform == 1 then
										reportTb.standby1 = reportTb.standby1 + 3
									-- 手机服务器
									else
										reportTb.standby1 = reportTb.standby1 + 2
									end
								end
							end
						end
					end
				end

				reportTb.cid = RoomInteractiveData.curMapwid
				reportTb.standby2 = hostUin
				reportTb.standby3 = cause
			end
			local param = {
				cause = cause,
				kickertype = kickertype,
				mapwid = RoomInteractiveData.curMapwid,
				curHostUin = hostUin,
				showType = 0,
				reportTb = reportTb,
			}
			if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then
				if G_CheckABTestSwitchOfAllCloud() then
					param.showType = 2
				end
			end
			GetInst("UIManager"):Open("NRSConnectLost", param)
			showNew = true
		end
	end

	--print("unicommon_fps ==:"..map_fps)
	--ShowGameTips("马上掉线，上报fps "..map_fps)
	SetExitReason(cause)
	GetInst("ReportGameDataManager"):SetExitReaseon(cause)
	if not showNew then
		local text = GetInst("NRSConnectLostInterface"):GetConnectLostTip(cause, kickertype)
		if cause == 0 then	--踢出房间
			ConnectLostWatchAdGetAward(8);	--广告
		elseif cause == 1 then	--房间断连 	
			-- text = GetS("135");
			t_ad_data.onlineRoomFailNum = t_ad_data.onlineRoomFailNum + 1;
			ConnectLostWatchAdGetAward(6);	--广告
		end
		--家园特殊处理 
		if ClientCurGame and ClientCurGame:isInGame() and IsInHomeLandMap and IsInHomeLandMap() then			
			getglobal("RSConnectLostFrameConfirmBtnName"):SetText(GetS("41172"))
		end
		--MiniBase错误码提示界面显示游戏加载成功
		SandboxLua.eventDispatcher:Emit(nil, "MiniBase_GameLaunchFinish",  SandboxContext():SetData_Number("code", (50 + cause)))
		getglobal("RSConnectLostFrameDesc"):SetText(text, 61, 69, 70);
		getglobal("RSConnectLostFrame"):SetClientUserData(0, cause);
		getglobal("RSConnectLostFrame"):Show();
	end
	
	SpamPreventionPresenter:requestClearSpamHistoryMessages();
	ClosePreStartGameFrame() -- 联机断开后关闭开局介绍等界面

    -- 作弊相关单独上报
	if (cause > 2000 and cause < 3000) then
		RoomCheatReport(cause)
	end

	-- if GetNewGameReportHitABtest() == false then
		pcall(function()
			local rptInfo = {
				cid = RoomInteractiveData.curMapwid,
				standby1 = cause,
				standby2 = kickertype,
			}
			if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then
				if RentPermitCtrl:IsQuickUpRentRoom() then
					rptInfo.standby3=3
				else
					rptInfo.standby3=2
				end
			else
				rptInfo.standby3=1			
			end
			if ClientCurGame and ClientCurGame:isInGame() then
				standReportEvent("9921", "-", "IN_GAME", "room_link_error", rptInfo)
			else
				standReportEvent("9921", "-", "OUT_GAME", "room_link_error", rptInfo)
			end
		end)
	-- end
end


function getCloudRoomStandby2()
	local standby2 = 0
	if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then
		standby2 = 1   -- 云服
	end

	if RentPermitCtrl and RentPermitCtrl.GetRentRoomID then
		local roomid = RentPermitCtrl:GetRentRoomID()
		if roomid then
			if string.len(roomid) < 36 and standby2 == 1 then
				standby2 = 2   -- 租赁服
			end
		end
	end
	return standby2
end

function MpGameLoadErrReport(errCode, errMsg)
	local rptInfo = {
		standby1 = errCode,
		standby2 = 0,
		standby3 = errMsg or "",
	}
	SetExitReason(errCode)
	if RoomInteractiveData and RoomInteractiveData.curMapwid then
		rptInfo.cid = RoomInteractiveData.curMapwid
	end
	rptInfo.standby2 = getCloudRoomStandby2()

	if RentPermitCtrl and RentPermitCtrl.GetRentRoomID then
		local roomid = RentPermitCtrl:GetRentRoomID()
		if roomid then
			rptInfo.standby3 = rptInfo.standby3 .. " | " .. roomid
		end
	end
	standReportEvent("9921", "-", "IN_GAME", "load_room_error", rptInfo)
end

-- 本次缓存mod无下载上报 单位是kb
function MpGameIgnoreDownloadReport(fileType, fileSize)
	if not fileSize or fileSize <= 0 then
		return
	end
	local rptInfo = {
		standby1 = fileType,
		standby2 = 0,
		standby3 = fileSize,
	}
	if RoomInteractiveData and RoomInteractiveData.curMapwid then
		rptInfo.cid = RoomInteractiveData.curMapwid
	end
	rptInfo.standby2 = getCloudRoomStandby2()

	standReportEvent("9921", "-", "IN_GAME", "load_ignor_download", rptInfo)
end

-- 作弊提示上报
function RoomCheatReport(errcode, msg)
	local rptInfo = {
		standby1 = errcode,
		standby2 = 0,
	}
	if msg then 
		rptInfo.standby3 = msg 
	end

	if RoomInteractiveData and RoomInteractiveData.curMapwid then
		rptInfo.cid = RoomInteractiveData.curMapwid
	end
	rptInfo.standby2 = getCloudRoomStandby2()

	standReportEvent("9921", "-", "IN_GAME", "room_cheat_report", rptInfo)
end

function IsUseModDownloadCache()
	if ns_data and ns_data.use_mod_download_cache then
		return ns_data.use_mod_download_cache
	end
	return 0
end

--特殊物品使用随机
function RandomUseSpecialItem(itemid)
	local t_Chest = {};
	--找出所有符合itemid的chest项
	for i=1, 100 do
		local chestDef = DefMgr:getChestDef(itemid*100+i);
		if chestDef ~= nil then
			table.insert(t_Chest, chestDef);
		end
	end


	if #(t_Chest) <= 0 then
		return -1, 0;
	else						--随机出一条符合itemid的chest项
		local chestDef = nil;
		local t_Prob = {};
		local total = 0;
		for i=1, #(t_Chest) do
			total = total + t_Chest[i].GroupOdds;
			table.insert(t_Prob, total);
		end
		if total == 0 then
			total = 1;
		end
		local randomNum = math.random(0, total-1);
		for i=1, #(t_Prob) do
			if randomNum < t_Prob[i] then
				chestDef = t_Chest[i];
				break;
			end
		end

		if chestDef ~= nil then			--在chest项随机出一个物品
			local t_Prob = {};
			local total = 0;
			for i=1, 10 do
				if chestDef.ItemID[i-1] ~= 0 then
					total = total + chestDef.ItemOdds[i-1];
					table.insert(t_Prob, {Total=total, Index=i});
				end		
			end
			if total == 0 then
				total = 1;
			end
			local randomNum = math.random(0, total-1);
			local itemId = -1;
			local itemNum = 0;
			for i=1, #(t_Prob) do
				if randomNum < t_Prob[i].Total then
					itemId = chestDef.ItemID[t_Prob[i].Index-1];
					itemNum = chestDef.ItemNum[t_Prob[i].Index-1];
					break;
				end
			end
			return itemId, itemNum;
		else
			return -1, 0;
		end
	end	
end

--背包帐号物品直接使用
function AccountItemUse(grid_index, itemId, player)
	if itemId > 0 then
		local itemNum = 1;
		if itemId == 12949 then		--角色解锁道具使用			
			local randomNum = math.random(0, 99)
			if randomNum > 50 then
				itemId = RandomGetUnlockRoleItem();
				if itemId < 0 then
					itemId, itemNum = RandomUseSpecialItem(itemId)
				end
			else
				itemId, itemNum = RandomUseSpecialItem(itemId)
			end
		elseif itemId == 12857 then	-- 星星福袋
			itemId, itemNum = RandomUseSpecialItem(itemId)
		end
		if player ~= nil then
			player:useSpecialItem(grid_index, itemId, itemNum);
		else
			ShowGameTips("player is nil", 3)
		end
	end		
end

function genAccountItemUseResult(itemId)
	if itemId > 0 then
		local itemNum = 1;
		local newItemId = 0;
		if itemId == 12949 or	--角色解锁道具使用
				itemId == 12857	-- 星星福袋
		then
			newItemId, itemNum = RandomUseSpecialItem(itemId)
		end
		if newItemId ~= itemId and newItemId > 0 and itemNum > 0 then
			return newItemId, itemNum
		end
	end
	return 0, 0
end

--检查是否有敏感词并提示
--加个默认参数，当content是nil的时候作为默认返回值; content 是 nil 的话C++那边会崩
local G_NoFilterEditBoxNames = {}
local G_SaveOriStrEditBoxNames = {}
local G_FilterTipsEditBoxNames = {}
local G_DisableCheckNumBoxName = 
{
	["FriendFrameTabsSearchEdit"] = true,  
	["SearchFriendFrameSearchEdit"] = true,  
	["CloudServerPlayerTabsSearchEdit"] = true,  
	["ActivityFrameActivationCodeEdit"] = true,  
	["LoginScreenFrameInputUserNameEdit"] = true,  
	["Activity4399FrameEdit"] = true,  
	["NickModifyFrameContentNameEdit"] = true,  
	["FeedbackContextEdit"] = true,  
	["PetNickModifyFrameContentNameEdit"] = true,  
	["WorkSpaceInviteIDEdit"] = true,  
	["MoodPublishFrameMoodPageTextEdit"] = true,   --个人中心-发布心情
	["ExhibitionRecomendFrameTextEdit"] = true,   --个人中心-发布地图推荐语
	["DynamicPublishFrameTextEdit"] = true,   --个人中心-发布动态
	["FriendDynamicFrameEditTextEdit"] = true,   --个人中心-发布动态评论
	["WorkSpaceSearchBodyEdit"] = true,   --个人中心-工作室-查找
	["WorkSpaceSearchLobbyInputEdit"] = true,   --个人中心-工作室-查找工作室二级界面
	["WorkSpaceSetNameEdit"] = true,   --个人中心-工作室设置-信息
	["WorkSpaceSetDescBoxDescEdit"] = true,  --个人中心-工作室设置-介绍
	["WorkSpaceSetNoticeBoxNoticeEdit"] = true,  --个人中心-工作室设置-公共
	["WorkSpaceInviteContentBoxContentEdit"] = true,  --个人中心-成员管理-邀请玩家
	["ShareArchiveBoxLeftNameEdit"] = true,  --地图上传-名称
	["ShareArchiveBoxLeftDescBoxEdit"] = true,  --地图上传-介绍
	["CloudServerCreateRoomSetNameEdit"] = true,  --迷你云服-云服创建-名称 
	["CloudServerCreateRoomSetDescEdit"] = true,  --迷你云服-云服创建-介绍
	["CloudServerManagementRightPage1NameContent"] = true,  --迷你云服-云服管理-基础-名称
	["CloudServerManagementRightPage1IntroductionEdit"] = true,  --迷你云服-云服管理-基础-介绍
	["CloudServerNoticeTextEdit"] = true,  --迷你云服-云服管理-状态-云服公告
	["WorldBackupMsgBoxEdit1"] = true,  --迷你云服-云服管理-备份-创建云服备份
	["ChangGroupNameFrameContentNameEdit"] = true,  --好友-群组-新建群组-群组名称
	["ResourceCenterAddFolderContentNameEdit"] = true,  --资源中心-添加文件夹
	["ResourceCenterPluginPkgMgrTopSearchEdit"] = true,  --资源中心-插件包查询
	["ResourceCenterUIPkgMgrTopSearchEdit"] = true,  --资源中心-UI库查询
	["ResourceCenterSoundLibTopSearchEdit"] = true,  --资源中心-音频库查询
}
-- 不需要检查数字的输入框
g_IngoreNumberInput = 
{
	["WorldRuleBoxMapNameEdit"] = true, -- 创建地图的地图名称框
	["ShopWarehouseSearchEdit"] = true, -- 仓库搜索框
	["SingleEditorFrameBaseSetCommonNameEdit"] = true, --动作模型部件名称输入框
	["SingleEditorFrameBaseSetCommonDescEdit"] = true, --动作模型部件描述输入框
	["FullyCustomModelEditorNewFrameNameEdit"] = true,  -- 模型组件名称
	["FullyCustomModelEditorSaveFrameNameEdit"] = true,  -- 模型名称
	["FullyCustomModelEditorSaveFrameDescEdit"] = true,  -- 模型描述
	["ActorEditFrameConfirmMakeFrameName"] = true,  -- 生物模型名称
	["CustomModelFrameBottomSheetNameEdit"] = true,  -- 道具模型名称输入框
	["CustomModelFrameBottomDescEdit"] = true,  -- 道具模型描述输入框
	["PackingCMCreateNameEdit"] = true,  -- 微缩名称输入框
	["PackingCMCreateDescEdit"] = true,  -- 微缩描述输入框
	["CreateBackpackFrameSearchEdit"] = true,  -- 编辑模式搜索框
	["CreateWorldFrameParamFrame1NameEdit"] = true,  -- 创建地图普通模式选择游戏模式冒险模式地图名称输入框
	["CreateWorldFrameParamFrame2NameEdit"] = true,  -- 创建地图普通模式选择游戏模式创造模式地图名称输入框
}

function ReplaceFilterString(content,editboxName)
	content = content or ""
	pcall(function()
		if G_SaveOriStrEditBoxNames[editboxName] then
			local obj = getglobal(editboxName)
			if obj and obj.SetClientString then
				obj:SetClientString(content or "")
			end
		end
	end)

	--官网网址不需要屏蔽
	if IsIgnoreReplace(content, {CheckMiniUrl = true}) then
		return content
	end

	local function isEnable(editboxName)
		if G_DisableCheckNumBoxName[editboxName] then
			return false
		end
		return true
	end 

	local function isPureNumber(content)
		local lenInByte = #tostring(content)
	    local i = 1
	    local numberCount = 0
	    while (i <= lenInByte) do
	        local curByte = string.byte(content, i)
	        if curByte >= 48 and curByte <= 57 or curByte == 45 or curByte == 95 then
	        	--数字
	        	numberCount = numberCount + 1                                                 
	        end                                              
	        i = i + 1                                                            
	    end
	    if numberCount == lenInByte then 
	    	return true 
	    else
	    	return false 
	    end 
	end

	if not content then
		return ""
	end

	if editboxName == "GameSignEditFrameEdit" then
		GameSignEditFrameEdit_SetBeforeFilterStr(content);
	end
	local check_number = true  -- 是否检测数字
	if g_IngoreNumberInput[editboxName] then
		check_number = false
	end

	if editboxName and editboxName ~= "" then 
		if isEnable(editboxName) then 
			if editboxName == "MiniWorksFrameSearchInputEdit" or editboxName == "ResourceShopSearchBarEdit" or editboxName == "MaterialLibSearchSearchBarEdit" then
				--迷你工坊和资源工坊,创作中心素材库里的搜索框需要完全不屏蔽
				return content
			elseif G_NoFilterEditBoxNames[editboxName] then
				return content
			else
				local retStr = DefMgr:filterString(content, check_number);
				if content ~= retStr and G_FilterTipsEditBoxNames[editboxName] then
					ShowGameTipsWithoutFilter(G_FilterTipsEditBoxNames[editboxName],3)
				end
				return retStr
			end 
		else
			if editboxName == "ActivityFrameActivationCodeEdit" or editboxName == "Activity4399FrameEdit" or "NickModifyFrameContentNameEdit" then 
				--特殊处理一下，这个输入框需要完全不屏蔽
				return content
			else
				if isPureNumber(content) then 
					return content
				else
					local retStr = DefMgr:filterString(content, check_number);
					if content ~= retStr and G_FilterTipsEditBoxNames[editboxName] then
						ShowGameTipsWithoutFilter(G_FilterTipsEditBoxNames[editboxName],3)
					end
					return retStr
				end 
			end 
		end 
	else
		local retStr = DefMgr:filterString(content);
		if content ~= retStr and G_FilterTipsEditBoxNames[editboxName] then
			ShowGameTipsWithoutFilter(G_FilterTipsEditBoxNames[editboxName],3)
		end
		return retStr
	end 
end

function RegNotFilterEditBox(name)
	if type(name) == "string" then
		G_NoFilterEditBoxNames[name] = true
	end
end

function RegNeedSaveOriStrEditBox(name)
	if type(name) == "string" then
		G_SaveOriStrEditBoxNames[name] = true
	end
end

function RegFilterTipStrEditBox(name, tips)
	if type(name) == "string" and type(tips) == "string" then
		G_FilterTipsEditBoxNames[name] = tips
	end
end

function CheckFilterString(content, isShowTips)
	if isShowTips == nil then
		isShowTips = true
	end
	local ret = false
	-- if DefMgr:checkFilterString(content) then
	-- 	if isShowTips then
	-- 		ShowGameTips(GetS(121), 3);
	-- 	end
	-- 	ret = true
	-- end
	return ret;
end

function SafeEditBoxClick(content, editboxName)
	--背包相关输入禁用
	if BackpackInputDisabled(editboxName, content) then
		return false
	end
	--插件相关输入禁用
	if PluginInputDisabled(editboxName, content) then
		return false
	end
	--开发者工具相关输入禁用
	if DeveloperToolsInputDisabled(editboxName, content) then
		return false
	end
	--资源中心相关输入禁用
	if ResourceCenterInputDisabled(editboxName, content) then
		return false
	end
	--高级创造-玩法相关输入禁用
	if AdvancedCreationPlayInputDisabled(editboxName, content) then
		return false
	end

	return true
end

--是否为房主
function IsRoomOwner()
	if ClientCurGame and ClientCurGame:isInGame() then
		local gameType = AccountManager:getMultiPlayer();
		if gameType == 1 or gameType == 3 then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

-- 是否为客机（主机、客机、单机三种状态）
function IsRoomClient()
	if ClientCurGame and ClientCurGame:isInGame() then
		local gameType = AccountManager:getMultiPlayer();
		if gameType == 2 then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

--是否为云服服主
function IsCloudServerRoomOwner()
	if CurMainPlayer then
		return CurMainPlayer:isCloudRoomServerOwner();
	end

	return false;
end

lobbyIsAvtModel = false;
lobbyIsSkinModel = false;

function GetPlayer2Model()
	local skinModel = AccountManager:getRoleSkinModel();
	local model = AccountManager:getRoleModel();
	local myBool = true;
	if IsUIFrameShown("HomeChestFrame") then
		myBool = false;
	else
		myBool = true;
    end
    lobbyIsSkinModel = false
    local player = UIActorBodyManager:getRoleBody(model-1, myBool);
	if skinModel > 0 then
        player = UIActorBodyManager:getSkinBody(skinModel, myBool);
        lobbyIsSkinModel = true
	end
	lobbyIsAvtModel = false;
	local seatInfo = GetInst("ShopDataManager"):GetPlayerUsingSeatInfo()
	if seatInfo then
        lobbyIsAvtModel = true;
        lobbyIsSkinModel = false
		---player = UIActorBodyManager:getAvatarBody(97, myBool);
		---print("GetPlayer2Model1", seatInfo)
		SeatInfoSetCustomBody(97, seatInfo);
		
		if seatInfo and seatInfo.scale then
			player = UIActorBodyManager:getAvatarBody(97, myBool);
			player:setScale(seatInfo.scale)
		end
	end
	return player;
end


function GetPlayer2ModelByNum( model, skinModel )
	local myBool = true;
	if getglobal("HomeChestFrame"):IsShown() then
		myBool = false;
	else
		myBool = true;
	end

	local player = nil;
	local skinDef = RoleSkinCsv:get(skinModel);
	local bolSkin = false
	if skinModel > 0 and skinDef ~= nil then
		bolSkin = true
		player = UIActorBodyManager:getSkinBody(skinModel, myBool);
	end

	if not player then
		if skinModel > 0 then
			ShowGameTips(GetS(267), 3);
		end
		player = UIActorBodyManager:getRoleBody(model-1, myBool);
	end

	return player,bolSkin;
end



--type 1好友 2查看的玩家 3粉丝
function GetOtherPlayer2Uin(uin, type)
	local skinModel = 0;
	local model = 1;

	if type == 1 then
		local buddyDetail = BuddyManager:getBuddyDetailByUin(uin);
		if buddyDetail ~= nil then
			skinModel = buddyDetail.skinid;
			model = buddyDetail.model;
		end
	elseif type == 2 then
		local buddyInfo =  BuddyManager:getWatchBuddyInfo();
		if buddyInfo ~= nil then
			skinModel = buddyInfo:getSkinMode();
			model = buddyInfo:getModel();
		end
	elseif type == 3 then
		local fansInfo = AccountManager:getFansInfo(0, uin);
		if fansInfo ~= nil then
			skinModel = fansInfo.skin;
			model = fansInfo.model;
		end
	end


	local player = nil;
	if skinModel > 0 then
		player = UIActorBodyManager:getSkinBody(skinModel);
	end

	if not player then		
		if skinModel > 0 then
			ShowGameTips(GetS(267), 3);
		end
		player = UIActorBodyManager:getRoleBody(model-1);
	end


	return player;
end


function GetHeadIconIndex(model, skinid)

	local headIndex = model  or AccountManager:getRoleModel();
	local skinModel = skinid or AccountManager:getRoleSkinModel();
	if not model or not skinid then
		--TODO 待优化 改方法仅支持返回装扮头像对应的索引
		if GetInst("HeadInfoSysMgr") and GetInst("HeadInfoSysMgr"):IsPersonalHeadSeetingOpen() then
			local headInfo = GetInst("HeadInfoSysMgr"):GetPlayerHeadInfo()
			if headInfo and headInfo.type and headInfo.type == 1 then
				skinModel = headInfo.id
			end
		end
	end

	if skinModel > 0 then
		local skinDef = RoleSkinCsv:get(skinModel);
		if skinDef ~= nil then
			headIndex = skinDef.Head;
		end
	end

	return headIndex;
end

--获取当前玩家头像所在路径
function GetHeadIconPath()
	local headPath = ""
	local headIndex = AccountManager:getRoleModel();
	local skinModel = AccountManager:getRoleSkinModel();
	--个人头像设置功能开放则使用设置的数据
	local headInfo = GetInst("HeadInfoSysMgr"):GetPlayerHeadInfo()
	local headData, HasAvater = GetInst("HeadInfoSysMgr"):GetPlayerHeadPath(headInfo)
	--仅支持返回不是定制装扮的路径
	if GetInst("HeadInfoSysMgr"):IsPersonalHeadSeetingOpen() and headData and not HasAvater then
		headPath = headData
	else
		if skinModel > 0 then
			local skinDef = RoleSkinCsv:get(skinModel);
			if skinDef ~= nil then
				headIndex = skinDef.Head;
			end
		end
		headPath = string.format("ui/roleicons/%d.png",headIndex)
	end
	return headPath;
end

function NoBindAccountPayMsgBox()
	MessageBox(9, GetS(3135));
	getglobal("MessageBoxFrame"):SetClientString( "没绑定帐号充值" );
end

function IsSameDay(t1, t2)
	local day1 = math.floor(t1/86400);
	local day2 = math.floor(t2/86400);

	if day1 == day2 then
		return true;
	else
		return false;
	end
end

--自己的Uin，这里取的海外的uin是减了10亿的，该方法最好只用于显示uin用，不要用于做两个uin的比较
function GetMyUin()
	local uin = AccountManager:getUin();
	if uin == 1 then
		uin = 123456789
	end
	uin = getShortUin(uin);	
	return uin;
end

function hasUpdate2ShareVersion(owid, version)
	local num = AccountManager:getMyWorldList():getNumWorld();
	for i=1, num do
		local worldInfo = AccountManager:getMyWorldList():getWorldDesc(i-1);
		if worldInfo.fromowid == owid and version > worldInfo.shareVersion then
			return true;
		end
	end

	return false;
end

--请求截图
function GameSnapshot(isInit)
	local gameType = AccountManager:getMultiPlayer();
	if ClientCurGame and ClientCurGame:isInGame() and gameType ~= 2 then
		if isInit then		--打开界面的时候
			if not Snapshot:loadMyWorldThumb(CurWorld:getOWID()) then	--没有截图
				Snapshot:requestSnapshot(512, 288, false);
				return "no_thumb";
			end
		else				--手动截图
			Snapshot:requestSnapshot(512, 288, false);
		end
		--[[
		if AccountManager:isOWSnapLocked(CurWorld:getOWID()) then			
			Snapshot:loadMyWorldThumb(CurWorld:getOWID())
		else
			Snapshot:requestSnapshot();
		end
		]]
	end
	
	return nil;
end	

--统计创建世界事件
function StatisticsWorldCreationEvent(worldType)
	if worldType == 0 then --冒险模式
		StatisticsTools:gameEvent("SurvivalWorld");
		StatisticsTools:gameEvent("EnterSurviveWNum");
	elseif worldType == 1 then --创造模式
		StatisticsTools:gameEvent("CreateWorld");
		StatisticsTools:gameEvent("EnterCreateWNum");
	elseif worldType == 2 then --极限模式
		StatisticsTools:gameEvent("ExtremityWorld");
		StatisticsTools:gameEvent("EnterExtremityWNum");
	elseif worldType == 4 then --玩法模式
		StatisticsTools:gameEvent("GameMakerWorld");
		StatisticsTools:gameEvent("EnterGameMakerWNum");
	end
	--首次创建地图
	if ClientMgr:getStatistics("createworlds") == 1 then
		StatisticsTools:gameEvent("CreateFirstWorld", "worldType", tostring(worldType));
	end
end

--迷你豆是否足够
function IsMiniBeanEnough(needNum)
	local hasBean = AccountManager:getAccountData():getMiniBean();
	if hasBean >= needNum then
		return true
	else
		ShowGameTips(GetS(385), 3);
		getglobal("BeanConvertFrame"):Show();
	end
end

function SetGameModelIcon(icon, type)
	if type == 0 then	--生存模式
		icon:SetTexUV(822, 84, 76, 76);
	elseif type == 1 then	--创造模式
		icon:SetTexUV(901, 84, 76, 76);
	elseif type == 2 then	--极限模式
		icon:SetTexUV(750, 1, 72, 73);
	elseif type == 3 then	--创造转生存
		icon:SetTexUV(901, 84, 76, 76);
	elseif type == 4 then	--编辑模式
		icon:SetTexUV(8, 155, 75, 75);
	elseif type == 5 then	--玩法模式
		icon:SetTexUV(8, 155, 75, 75);
	end
end
function SetVideoModeIcon(icon,Name,type)
	if type == 9 and RecordPkgMgr:canRecordVideo() then   --录像模式

		icon:SetTexUV("icon_video_white.png");
		Name:SetText(GetS(7590));
	else
		icon:SetTexUV("icon_backupandrestore_white.png");
		Name:SetText(GetS(4000));
	end
end
function GetLabel2Owtype(type)
	if type == 0 then	--生存
		return 2;
	elseif type == 1 then	--创造
		return 3;
	elseif type == 2 then	--极限生存
		return 2;
	elseif type == 3 then	--创造转生存
		return 2;
	elseif type == 4 then	--玩法编辑
		return 3;
	elseif type == 5 then	--玩法
		return 8;
	elseif type == 6 then	--高级生存
		return 2;
	elseif type == 9 then   --录像
		return 9;
	end
	
	return 2;
end

--获取地图类型
function GetMapLabel(mapinfo)
	local labels = mapinfo.gameLabel
	if labels == 0 then
		labels = GetLabel2Owtype(mapinfo.worldtype);
	end

	--自己创建的未上传的地图取默认分类标签
	if mapinfo.owneruin == mapinfo.realowneruin and mapinfo.open == 0 then
		labels = GetLabel2Owtype(mapinfo.worldtype);
	end
	return RoomGetCreateLabelIndexByGameLabel(labels)
end

-- 每种创建模式可选的分类标签
function GetOptionalLabels2Owtype(type)
	local labels = {}
	if type == 5 then
		labels = {4,5,6,7,8}
	else
		table.insert( labels, GetLabel2Owtype(type) )
	end
	return labels
end

function GetFuncState(funcname)
	local funcSwitchDef = DefMgr:getFuncSwitchDef(ClientMgr:getApiId());
	if funcSwitchDef ~= nil then
		if string.find(funcname, "Share") then 		--分享
			return funcSwitchDef.Share == 1;
		elseif string.find(funcname, "AccSwitch") then 	--帐号切换
			if IsEnableNewLogin and IsEnableNewLogin() then
				return NewAccountSwitchCfg:GetNewAccountSwtichStatus()
			else
				return funcSwitchDef.AccSwitch == 1;
			end
		elseif string.find(funcname, "AccEncode") then 	--帐号加密
			return funcSwitchDef.AccEncode == 1;
		elseif string.find(funcname, "SmsPay") then 	--短信[Desc2]
			return funcSwitchDef.SmsPay == 1;
		elseif string.find(funcname, "SdkPay") then 	--SDK[Desc2]
			return funcSwitchDef.SdkPay == 1;
		elseif string.find(funcname, "HomeChest") then 	--家园
			return funcSwitchDef.HomeChest == 1;
		elseif string.find(funcname, "FeedBack") then 	--问题反馈
			return funcSwitchDef.FeedBack == 1;
		elseif string.find(funcname, "Reservation") then --预约分享
			return funcSwitchDef.Reservation == 1;
		elseif string.find(funcname, "MobileBinding") then 	--绑定手机
			return funcSwitchDef.MobileBinding == 1;
		elseif string.find(funcname, "EmailBinding") then 	--绑定邮箱
			return funcSwitchDef.EmailBinding == 1;
		elseif string.find(funcname, "SecurityBinding") then 	--安全绑定
			return funcSwitchDef.SecurityBinding == 1;
		elseif string.find(funcname, "QQWalletPay") then 	--QQ钱包[Desc1]
			return funcSwitchDef.QQWalletPay == 1;
		end 
	end

	return true;
end


function ShowQQVipBtn()
	local apiid_ = ClientMgr:getApiId()
	return apiid_ == 47 or apiid_ == 101 or apiid_ == 116 or apiid_ == 109 or apiid_ == 117 or apiid_ == 118 or apiid_ == 119;  --QQ大厅移动版、QQ大厅PC版、QQ空间PC版
end

function isQQGame()       ---忽略109qq空间pc,文字有不同
	local apiid_ = ClientMgr:getApiId()
	return apiid_ == 47 or apiid_ == 101 or apiid_ == 116 or apiid_ == 117 or apiid_ == 118 or apiid_ == 119;  --QQ大厅
end

function isQQGamePc()     ---忽略109qq空间pc,文字有不同
	local apiid_ = ClientMgr:getApiId()
	return apiid_ == 101 or apiid_ == 116 or apiid_ == 117 or apiid_ == 118 or apiid_ == 119;   --QQ大厅
end

function isMaApiid1()
	local apiid_ = ClientMgr:getApiId()
	return (apiid_ == 50 or (apiid_>= 62 and apiid_<= 97) or apiid_ == 112 or apiid_ == 110 or apiid_ == 1 or apiid_ == 45 or apiid_ == 999)     --官方版本
end


function UpdateVipIcons(vipInfo, uiVipIcon1, uiVipIcon2)
	if vipInfo==nil then
		vipInfo = {vipType=0, vipLevel=0, vipExp=0};
	end
	local totalIcons = 0;

	local viptype = vipInfo.vipType;

	if isQQGame() then  --qq大厅渠道

		if isBlueVip(vipInfo) and vipInfo.vipLevel>=1 and vipInfo.vipLevel<=8 then  --显示qq蓝钻

			if viptype == VIP_QQ_BLUE or viptype == VIP_QQ_BLUE_YEARLY then
				uiVipIcon1:SetTexUV("vip_qq_blue_"..tostring(vipInfo.vipLevel));
			elseif viptype == VIP_QQ_BLUEDELUXE or viptype == VIP_QQ_BLUEDELUXE_YEARLY then
				uiVipIcon1:SetTexUV("vip_qq_blue2_"..tostring(vipInfo.vipLevel));
			end
			uiVipIcon1:Show();
			totalIcons = totalIcons + 1;

			if viptype==VIP_QQ_BLUE_YEARLY or viptype==VIP_QQ_BLUEDELUXE_YEARLY then
				uiVipIcon2:SetTexUV("vip_qq_blue_year");
				uiVipIcon2:Show();
				totalIcons = totalIcons + 1;
			else
				uiVipIcon2:Hide();
			end
		else  --非vip
			uiVipIcon1:Hide();
			uiVipIcon2:Hide();
		end

	elseif ClientMgr:getApiId()==109 then --qq空间渠道

		if isYellowVip(vipInfo) and vipInfo.vipLevel>=1 and vipInfo.vipLevel<=8 then  --显示qq黄钻

			if viptype == VIP_QQ_YELLOW or viptype == VIP_QQ_YELLOW_YEARLY then
				uiVipIcon1:SetTexUV("vip_qq_yellow_"..tostring(vipInfo.vipLevel));
			elseif viptype == VIP_QQ_YELLOWDELUXE or viptype == VIP_QQ_YELLOWDELUXE_YEARLY then
				uiVipIcon1:SetTexUV("vip_qq_yellow2_"..tostring(vipInfo.vipLevel));
			end
			uiVipIcon1:Show();
			totalIcons = totalIcons + 1;

			if viptype==VIP_QQ_YELLOW_YEARLY or viptype==VIP_QQ_YELLOWDELUXE_YEARLY then
				uiVipIcon2:SetTexUV("vip_qq_yellow_year");
				uiVipIcon2:Show();
				totalIcons = totalIcons + 1;
			else
				uiVipIcon2:Hide();
			end
		else  --非vip
			uiVipIcon1:Hide();
			uiVipIcon2:Hide();
		end

	else --其他渠道，不显示vip图标		
		uiVipIcon1:Hide();
		uiVipIcon2:Hide();
	end

	local offset = 0;
	if totalIcons > 0 then
		offset = totalIcons * 24 + 2;
	end

	return {iconNum=totalIcons, nextUiOffsetX=offset};
end

function UpdateAccountVipIcons(uiVipIcon1, uiVipIcon2)
	local vipinfo = AccountManager:getAccountData():getVipInfo();
	return UpdateVipIcons(vipinfo, uiVipIcon1, uiVipIcon2);
end

--通过名字获取房员uin,不靠谱（名字可以重）
function GetRoomPlayerUin2Name(name)
	if ClientCurGame.getNumPlayerBriefInfo then
		local num = ClientCurGame:getNumPlayerBriefInfo();
		for i=1, num do
			local briefInfo = ClientCurGame:getPlayerBriefInfo(i-1);

			if briefInfo.nickname == name then
				return briefInfo.uin;
			end
		end
	end

	return 0;
end

function debugBreak()
	ClientMgr:debugBreak();
end

function debugPrintStack()
	Log(debug.traceback());
end
function GetS(id, ...)
	if id ==  nil then
		return "id is nil";
	end
	--新服务器默认的错误码提示
	if type(id) == 'string' and string.sub(id, 1, 10) == "@ErrorCode" then
		local s_id = string.gsub(id, "@ErrorCode", "");
		if s_id then
			Log('GetS:'..s_id);
			local ida = tonumber(s_id) or 666666;
			local text
			-- t_ErrorCodeToString这里如果没加id对应值，会把@ErrorCode拼上去返回
			-- 4050：没有什么东西可以领取
			if string.find(t_ErrorCodeToString[ida],"@ErrorCode") then
				if tonumber(s_id) == 4050 then
					text = StringDefCsv:get(3401) --领取奖励成功
				else
					text = StringDefCsv:get(282).."("..ida..")"..tostring(id);
				end
			else
				text = StringDefCsv:get(t_ErrorCodeToString[ida])..","..tostring(id)
			end
			return text;
		else
			Log('GetS s_id is nil');
			--return StringDefCsv:get(282);
		end
	end

	if not tonumber(id) then print(' ========= 奇怪的string id ==========', id, debug.traceback()) end 
		
	local s = StringDefCsv:get(tonumber(id))
	s = HandleString(s,...)
	return s
end

function HandleString(str,...)
	local n = select('#', ...)
	for i=1, n do
		local tmpStr = select(i,...)
		local _, count = string.gsub(tmpStr, "%%", "")
		if count > 0 then
			local j, k = string.find(str, "@"..i)
			local startStr = string.sub(str, 1, j-1)
			local endStr = string.sub(str, k+1)
			str = startStr .. select(i,...) .. endStr
		else
			str = string.gsub(str, "@"..i, (select(i,...)))
		end
	end
	return str
end

--
-- layout functions
--
function DoLayout_ListV(layout_ui_names, spacing)
	local prev_ui = nil;

	local first_ui = getglobal(layout_ui_names[1]);
	
	for i = 1, #(layout_ui_names) do
		local obj = getglobal(layout_ui_names[i]);
		if obj and obj:IsShownSelf() then
			if prev_ui then
				obj:SetPoint("top", prev_ui:GetName(), "bottom", 0, spacing);
				obj:CalAbsRect();
			else
				if obj ~= first_ui then
					obj:SetPoint("top", first_ui:GetName(), "top", 0, 0);
				end
			end
			prev_ui = obj;
		end
	end
end

function DoLayout_ListV_InContainer(container_name, entry_names, padding_top, spacing)
	local first_ui = nil;
	local y = padding_top;
	
	for i = 1, #entry_names do
		local obj = getglobal(entry_names[i]);
		if obj and obj:IsShownSelf() then
			if first_ui == nil then
				first_ui = obj;
				obj:SetPoint("top", container_name, "top", 0, y);
			else
				obj:SetPoint("top", container_name, "top", 0, y);
			end
			obj:CalAbsRect();
			y = y + obj:GetHeight() + spacing;
		end
	end
end

function DoLayout_ListH(layout_ui_names, spacing)
	local prev_ui = nil;

	local first_ui = getglobal(layout_ui_names[1]);
	
	for i = 1, #(layout_ui_names) do
		local obj = getglobal(layout_ui_names[i]);
		if obj and obj:IsShownSelf() then
			if prev_ui then
				obj:SetPoint("left", prev_ui:GetName(), "right", spacing, 0);
				obj:CalAbsRect();
			else
				if obj ~= first_ui then
					obj:SetPoint("left", first_ui:GetName(), "left", 0, 0);
				end
			end
			prev_ui = obj;
		end
	end
end

function CountShownObjs(layout_ui_names)
	local c = 0;
	for i = 1, #(layout_ui_names) do
		local obj = getglobal(layout_ui_names[i]);
		if obj and obj:IsShownSelf() then
			c = c + 1;
		end
	end
	return c;
end

--return table: {m_nLeft=123,m_nTop=456,m_nRight=789,m_nBottom=123}
function GetBounding(layout_ui_names)
	local xmin = 99999;
	local ymin = 99999;
	local xmax = -99999;
	local ymax = -99999;
	for i = 1, #(layout_ui_names) do
		local obj = getglobal(layout_ui_names[i]);
		if obj and obj:IsShown() then
			obj:CalAbsRect();
			local r = obj:getAbsRect();
			if r.m_nLeft < xmin then
				xmin = r.m_nLeft;
			end
			if r.m_nRight > xmax then
				xmax = r.m_nRight;
			end
			if r.m_nTop < ymin then
				ymin = r.m_nTop;
			end
			if r.m_nBottom > ymax then
				ymax = r.m_nBottom;
			end
		end
	end
	return {m_nLeft=xmin, m_nTop=ymin, m_nRight=xmax, m_nBottom=ymax};
end

function GetBoundingHeight(layout_ui_names)
	local r = GetBounding(layout_ui_names);
	if r.m_nBottom - r.m_nTop >= 0 then
		return r.m_nBottom - r.m_nTop;
	else
		return 0;
	end
end

--
-- lua bit operations, see http://lua-users.org/wiki/BitwiseOperators
--

-- p >= 1
function bit(p)
	return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
function hasbit(x, p)
	return x % (p + p) >= p       
end

function setbit(x, p)
	return hasbit(x, p) and x or x + p
end

function clearbit(x, p)
	return hasbit(x, p) and x - p or x
end

function IsBuddy(uin)
	if uin == 1000 then
		return true;
	end

	return BuddyManager:isBuddy(uin);
end

function SetCurEditBox(editboxName)
	if ClientMgr:isPC() then
		local edit = getglobal(editboxName);
		if edit ~= nil then
			UIFrameMgr:setCurEditBox(edit);
		end
	end
end

--[[
function escape(w)
	if w then
		pattern="[^%w%d%._%-%* ]"
		s=string.gsub(w,pattern,function(c)
			local c=string.format("%%%02X",string.byte(c))
			return c
		end)
		return s
	end

	return w;
end
--]]


--gFunc_urlEscape 在c++中，性能更快
function escape(w)
	return gFunc_urlEscape(w)
end


function unescape(w)
	if w then
		s=string.gsub(w,"+"," ")
		s,n = string.gsub(s,"%%(%x%x)",function(c)
			return string.char(tonumber(c,16))
		end)
		return s
	end

	return "";
end

function bool_to_number(b)
	if b == true then
		return 1;
	else
		return 0;
	end
end

function number_to_bool(n)
	if n ~= 0 then
		return true;
	else
		return false;
	end
end

-- return true_value if condition
function iif(condition, true_value, false_value)
	if condition then
		return true_value;
	else
		return false_value;
	end
end

function string.startswith(String,Start)
	 return string.sub(String,1,string.len(Start))==Start
end

function string.endswith(String,End)
	 return End=='' or string.sub(String,-string.len(End))==End
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
	
	if (delimiter == '') then 
		return false 
	end

	local ret = {}
	local pos = 0
    for st, sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(ret, string.sub(input, pos, st - 1))
        pos = sp + 1
	end
	
    table.insert(ret, string.sub(input, pos))
    return ret
end

function clamp(value, min, max)
	if min~=nil and value < min then
		return min;
	elseif max~=nil and value > max then
		return max;
	else
		return value;
	end
end

function table.num_pairs(t)
	local count = 0;
	for k,v in pairs(t) do
		count = count + 1;
	end
	return count;
end

function GVoiceApplyMsgKeySuc()
	if ClientCurGame:isInGame() then
		if AccountManager:getMultiPlayer() > 0 then
			SetGVoiceBtnState();
		end
	end
end

function IsAndroidBlockark()
	return Android:IsBlockArt();
end

--苹果平台
function IsIosPlatform()
	local apiId = ClientMgr:getApiId();
	-- 345:IOS com.minitech.miniworld
	-- 346:IOS com.miniwan.miniworld
	-- 45:IOS/苹果
	return apiId == 345 or apiId == 346 or apiId == 45;
end

--苹果分包审核
function IsInIosSpecialReview()
	if Ogre__GetSpecialReviewMode then
		return Ogre__GetSpecialReviewMode() > 0;
	end
	--if ClientMgr:getApiId() == 52 then
	--	return false;
	--elseif ClientMgr:getApiId() == 53 then
	--	return os.time() < os.time({year=2017,month=6,day=4,hour=10,minute=0});
	--end
	return false;
end

--由于apiId登录失败的提示
function ShowTipsLoginFailByApiId(apiId)
	local index = 5000+apiId;
	local str = GetS(5000, GetS(index));
	if str and str ~= "" then
		ShowGameTipsWithoutFilter(str);
	else
		ShowGameTipsWithoutFilter("此迷你号所属平台为"..apiId);
	end
end


--e.g. CheckVersionMatch("0.14.6", ">=0.15.0") -> false
--e.g. CheckVersionMatch("0.14.6", "==0.15.0") -> false
function CheckVersionMatch(version, versionMatchStr)
	local cond, condverion = string.match(versionMatchStr, "([<=>]+)(.+)");
	if cond and condverion and version then
		condverion = ClientMgr:clientVersionFromStr(condverion);
		version = ClientMgr:clientVersionFromStr(version);
		if cond=='<' then
			return version < condverion;
		elseif cond=='<=' then
			return version <= condverion;
		elseif cond=='>' then
			return version > condverion;
		elseif cond=='>=' then
			return version >= condverion;
		elseif cond=='=' or cond=='==' then
			return version == condverion;
		end
	end

	return false;
end


function IsBetaEnv()
	local env = ClientMgr:getGameData("game_env");
	if env == 2 or env == 12 or env == 399 then
		return true
	else
		return false;
	end
end

function IsDecimal(x)
	if type(x) == 'number' then
		if math.floor(x)<x then
			return true;
		end
	end

	return false;
end

function IsOverseasVer()
	local env = get_game_env();
	return env >= 10 ;
end

function WatchADNetworkTips(callback, callback_data)
	if ClientMgr:getNetworkState() == 2 then
		SetLongMsgboxFrame({title=GetS(4934), content=GetS(4935), leftname=GetS(4838), rightname=GetS(4059)}, callback, callback_data);

		return false;
	end

	return true;
end

local t_cpsApiId = {[10] = true, [33] = true, [49] = true, [50]=true, [62]=true, [63]=true, [64]=true, [65]=true, [66]=true, [67]=true, [68]=true, [69]=true, [70]=true, [71]=true, [72]=true, [73]=true, [74]=true, [75]=true, [76]=true, [77]=true, [78]=true, [79]=true, [80]=true, [81]=true, [82]=true, [83]=true, [84]=true, [88]=true, [90]=true, [91]=true, [92]=true, [93]=true, [94]=true, [95]=true, [96]=true, [97]=true}
function IsMiniCps(apiId)
	return t_cpsApiId[apiId];
end

function IsShouQChannel(apiId)
	return ClientMgr:getVersionParamInt("ShouQSDKEnabled", 0) == 1;
end

function SecondTransforDesc(sec)
	local text="";
	
	local hour = math.floor( sec/3600 );
	if hour > 0 then
		text = hour..GetS(4088);
	end

	local remain = sec-hour*3600;
	local min = math.floor( remain/60 );
	if min > 0 then
		text = text..min..GetS(4975);
	end

	local s = remain-min*60;
	if s > 0 then
		text = text..s..GetS(4975);
	end

	return text;
end

function ResetScreenSize(screenWidth, screenHeight)
	local scale = UIFrameMgr:GetScreenScale();	
	
	local wScale = screenWidth/1280;
	local hScale = screenHeight/720;

	local texScale = wScale > hScale and wScale or hScale;

	local w = math.ceil(1280*texScale/scale);
	local h= math.ceil(720*texScale/scale);
	getglobal("LoginScreenFrameBkgAnim"):SetSize(w, h);

	local wScaleBkg = screenWidth/1560;
	local hScaleBkg = screenHeight/1170;

	local texScaleBkg = wScaleBkg > hScaleBkg and wScaleBkg or hScaleBkg;

	local wbkg = math.ceil(1560*texScaleBkg/scale);
	local hbkg = math.ceil(1170*texScaleBkg/scale);

	getglobal("LoginScreenFrameBkg"):SetSize(wbkg, hbkg); -- 注意：如果海外需要同步这一修改，需要同时修改xml配置尺寸、login_bg.jpg尺寸，目前约定尺寸是1560 * 1170的底图尺寸， codeby chenwei
	


	local ARMotionCaptureCtrl = GetInst("UIManager"):GetCtrl("ARMotionCapture");
	if ARMotionCaptureCtrl then
		ARMotionCaptureCtrl:onResetScreenSize();
	end
	local UIEditorMsgHandler = GetInst("UIEditorMsgHandler")
	if UIEditorMsgHandler then
		UIEditorMsgHandler:delayDispatcher(UIEditorDef.UIEDITOR_MSG.change_pc_screensize,screenWidth,screenHeight)
	end
	if GetInst("MiniUIManager") then
		local MidiMusicCtrl = GetInst("MiniUIManager"):GetUI("MidiMusicAutoGen")
		if MidiMusicCtrl then
			MidiMusicCtrl.ctrl:ResetScreenSize()
		end
	end

	SandboxLua.eventDispatcher:Emit(nil, "RESET_SCREENSIZE",  SandboxContext():SetData_Number("screenWidth", screenWidth):SetData_Number("screenHeight", screenHeight))
	if GetInst("UGCCommon") then
		GetInst("UGCCommon"):ResetScreenSize(screenWidth, screenHeight)
	end
end

function CheckPlayerInfo2EnterWorld(uin, model, geniusLv, skinId)
	Log("kekeke CheckPlayerInfo2EnterWorld");
	if IsLanRoom then return end

	if threadpool ~= nil then
		threadpool:work(function()
			if AccountManager.baseinfo_check then
				local t = {RoleInfo = {SkinID=skinId, Model=model, GenuisLv=geniusLv}};
				print("kekeke CheckPlayerInfo2EnterWorld", uin, t);
				if not AccountManager:baseinfo_check(uin, t) then
					AccountManager:requestRoomKickPlayer(uin);
				end
			end
		end);
	end
end

function CheckPlayerRideInfo2Summon(uin, horseId, isshapeshift)
	Log("kekeke CheckPlayerRideInfo2Summon");
	if IsLanRoom then
		if ClientCurGame:isInGame() then
			ClientCurGame:summonAccountHorse(uin, horseId, isshapeshift);
		end
		return
	end
	--暂时官服不检测坐骑数据
	if ClientMgr:isPureServer() and ClientCurGame:isInGame() then
		ClientCurGame:summonAccountHorse(uin, horseId, isshapeshift);
		return;
	end

	if horseId == 4568 or horseId == 4570 then --这个坐骑由于配置没更新到服务器，暂时不检查
		if ClientCurGame:isInGame() then
			ClientCurGame:summonAccountHorse(uin, horseId, isshapeshift);
		end
		return;
	end
	
	threadpool:work(function()
		if AccountManager.baseinfo_check then
			local t = nil;
			if isshapeshift then
				t = {Riders = {{RiderID=horseId}}};
			else
				local storehorseDef = DefMgr:getStoreHorseByID(horseId);
				if not storehorseDef then
					AccountManager:requestRoomKickPlayer(uin);
					return;
				end

				t = {
						Riders_lv = {{RiderID=storehorseDef.BaseHorseID, RiderLevel=storehorseDef.Level}}
					};
			end
			print("kekeke CheckPlayerRideInfo2Summon", uin, t);
			if t and not AccountManager:baseinfo_check(uin, t) then
				AccountManager:requestRoomKickPlayer(uin);
			elseif ClientCurGame:isInGame() then
				ClientCurGame:summonAccountHorse(uin, horseId, isshapeshift);
			end
		end
	end);
end

function CheckAccountHorseExpireTime(sObjId, horseId, uin)
	if not WorldMgr then
		return;
	end

	threadpool:work(function()
		if AccountManager.baseinfo_check then
			local storehorseDef = DefMgr:getStoreHorseByID(horseId);
			if not storehorseDef then
				return;
			end

			local t = {
					Riders_lv = {{RiderID=storehorseDef.BaseHorseID, RiderLevel=storehorseDef.Level}}
				};

			local objId = tonumber(sObjId);
			print("kekeke CheckAccountHorseExpireTime objId", objId);
			if not objId then
				return;
			end
			print("kekeke CheckAccountHorseExpireTime", uin, t);
			if not AccountManager:baseinfo_check(uin, t) then
				--ShowGameTips("CheckAccountHorseExpireTime not ok")

				local ActorMgr = CurWorld and CurWorld:getActorMgr()
				if ActorMgr and WorldMgr then
					local actorhorse = ActorMgr:findActorHorsebByWID(objId)
					local player = WorldMgr:getPlayerByUin(uin)
					local monsterDef = MonsterCsv:get(horseId);
					if actorhorse then
						local tips = GetS(71031);
						if player and monsterDef then
							tips = GetS(71031, player:getNickname(), monsterDef.Name)
						end
						actorhorse:onCheckAccountHorseExpireTime(tips)
					end
				end
			else
				print("CheckAccountHorseExpireTime ok")
			end
		end
	end);
end

function ClientStarConvertSuccess()
	if StarConvertByRevive then
		StarConvertByRevive = false;
		if ClientCurGame:getMainPlayer():revive(1) then
			local deathFrame = getglobal("DeathFrame");
			deathFrame:Hide();
		end
	end
end

--[[
	TODO	
	Created on 2020-01-14 at 15:44:24
]]
function SetTextureMainlandOrOverseas(szTextureName, szMainlandPath, szOverseasPath)
	if not szTextureName or #szTextureName <= 0 then return end
	local uiTexture = getglobal(szTextureName)
	if not uiTexture then return end
	local apiId = ClientMgr:getApiId();
	if apiId == 999 then
		local env =  ClientMgr:getGameData("game_env");
		if env == 10 or env == 12 then
			uiTexture:SetTexture(szOverseasPath)
		else
			uiTexture:SetTexture(szMainlandPath)
		end
	else
		if apiId >= 300  then
			uiTexture:SetTexture(szOverseasPath)
		else
			uiTexture:SetTexture(szMainlandPath)
		end
	end
end

---------------------手Q-iOS 相关----------------
---
isIOSShouQLogin = false; --判断手Q登录只针对iOS

function setIsShouQLogin(isShouQ)
	
	if 45 == ClientMgr:getApiId() then
		if isShouQ == false and isIOSShouQLogin == true then
			isIOSShouQLogin = isShouQ
			if getglobal("MiniLobbyFrame"):IsShown() then
				MiniLobbyFrame_OnShow()
			end
		end
		isIOSShouQLogin = isShouQ
	end
end
function setShouQNickName(nickName)
	local ShouQNickName = ""..nickName;
	setkv("ShouQNickName",ShouQNickName,nil,102)
end

function getShouQNickName()
	local nickName = getkv("ShouQNickName",nil,102)
	return nickName;
end

function isIOSShouQ()
	--Log("isIOSShouQ");
	if ClientMgr:getApiId() == 45 then
		return true
	end
	return false
end

local isIOSShouQVersion = nil --是否符合版本

function iOSShouQCtrVer()
	isIOSShouQVersion = false
	if isIOSShouQ() then
		if ns_version.ios_qq_ver and ns_version.ios_qq_ver.version_min then
			--Log("ios_qq_ver");
			--Log(ns_version.ios_qq_ver.version_min);
			local clientVersion = ClientMgr:clientVersion();
			local ver_min =	ClientMgr:clientVersionFromStr(ns_version.ios_qq_ver.version_min)
			--Log("ver_min:"..ver_min);
			--Log("clientVersion:"..clientVersion);
			if clientVersion >= ver_min then
				isIOSShouQVersion = true
			end
			if ns_version.ios_qq_ver and ns_version.ios_qq_ver.version_max then
				local ver_max =	ClientMgr:clientVersionFromStr(ns_version.ios_qq_ver.version_max)
				if clientVersion <= ver_max then
					isIOSShouQVersion = true
				else
					isIOSShouQVersion = false
				end
			end
		end
	end
	return isIOSShouQVersion
end

--1 PullQQFriendData    拉取列表好友数据
--2 QQFriendList       手Q同玩好友列表
--3 mainQQFriend       主界面侧边好友栏
--4 roomInviteQQFriends   房间内邀请手Q好友按钮
--5 homeQQFriend         家园手Q同玩好友列表
--6 QQSharePic           分享图片
--7 QQWaterSharingEntrance  浇水分享入口
--8 mainQQMembershipIcon   主界面会员图标
--9 QQMembershipIcon       个人中心会员图标
-- nun: 相应配置开关判断
-- androidSQ:安卓手Q渠道方法 return true
function iOSShouQConfig(num,androidSQ)
	if androidSQ and isAndroidShouQ() then
		return true
	end

	if not iOSShouQCtrVer() then
		return false
	end

	if isIOSShouQLogin == false then
		return false;
	end
	if  isIOSShouQ() and ns_version and ns_version.ios_qq_login then
		local config = ns_version.ios_qq_login;
		if num == 1 then
			if config.PullQQFriendData and config.PullQQFriendData == 1 then
                return true;
			end
		elseif num == 2 then
			if config.QQFriendList and config.QQFriendList == 1 then
				return true;
			end
		elseif num == 3 then
			if config.mainQQFriend and config.mainQQFriend == 1 then
				return true;
			end
		elseif num == 4 then
			if config.roomInviteQQFriends and config.roomInviteQQFriends == 1 then
				return true;
			end
		elseif num == 5 then
			if config.homeQQFriend and config.homeQQFriend == 1 then
				return true;
			end
		elseif num == 6 then
			if config.QQSharePic and config.QQSharePic == 1 then
				return true;
			end
		elseif num == 7 then
			if config.QQWaterSharingEntrance and config.QQWaterSharingEntrance == 1 then
				return true;
			end
		elseif num == 8 then
			if config.mainQQMembershipIcon and config.mainQQMembershipIcon == 1 then
				return true;
			end
		elseif num == 9 then
			if config.QQMembershipIcon and config.QQMembershipIcon == 1 then
				return true;
			end
		end
	end
	return false;
end

--显示1:显示绑定QQ图标 2:显示绑定QQ红点
function iOSBindingQQIcon(num)
	if not iOSShouQCtrVer() then
		return false
	end
	if  isIOSShouQ() and  ns_version and ns_version.ios_qq_bind then
		local config = ns_version.ios_qq_bind;
		if config.onshow and config.onshow == 1 and num == 1 then
			return true;
		end
		if config.red_marks and config.red_marks == 1 and num == 2 then
			return true;
		end
	end
	return false;
end

---------------------手Q相关----------------
local shouqChannelId = nil; --手Q子渠道号

function getShouQChannelId()
	if shouqChannelId == nil then
		shouqChannelId = JavaMethodInvokerFactory:obtain()
                                         :setClassName("org/appplay/platformsdk/MobileSDK")
                                         :setMethodName("GetShouqChannelId")
                                         :setSignature("()Ljava/lang/String;")
                                         :call()
                                         :getString();
	end
	return shouqChannelId;
end

function isAndroidShouQ()
	if ClientMgr:getApiId() == 56 then
		return true
	end
	return false
end

function isShouQPlatform()
	local apiId = ClientMgr:getApiId();
	local isShouQ = false
	if apiId == 56  then
		isShouQ = true;
	elseif isIOSShouQLogin and apiId == 45 then
		isShouQ = true;
	end
	return isShouQ;
end

function isDouyinCloudPlatform()
	local apiId = ClientMgr:getApiId();
	local isDouyinCloud = false
	if apiId == 60  then
		isDouyinCloud=true
	end
	return isDouyinCloud;
end

function isShouQAuthorize()
    local result = false
    if isShouQPlatform() then
        result = JavaMethodInvokerFactory:obtain()
                                         :setClassName("org/appplay/platformsdk/MobileSDK")
                                         :setMethodName("ShouQTencentAuth")
                                         :setSignature("()Z")
                                         :call()
                                         :getBoolean();
    end
    return result
end

--是不是腾讯会员
function isShouQTencentVip(uin, ret_callback)
	local selfUin = AccountManager:getUin();
	if not uin or selfUin ~= tonumber(uin) then return false end
	local result = ReqShouQvip({callback = function (ret) ret_callback(uin) end})
	if type(result) == "number" then
		if (LuaInterface:band(result, 1) ~= 0) or (LuaInterface:band(result, LuaInterface:lshift(1, 1)) ~= 0) then
			return true
		end
	end
	return false
end

--绑定手Q_openId
function BindOpenId(openId)
	Log("kekeke BindOpenId");
	threadpool:work(function()
		if openId == "" then	--登录失败、取消登录
			WaitQQLoginResult = 1;
			return;
		else
			WaitQQLoginResult = 2;
		end
		OpenId = openId;
		local needUpdate = true;
		if AccountManager.other_baseinfo then
			local ret, baseInfo = AccountManager:other_baseinfo(AccountManager:getUin());
			print("kekeke BindOpenId baseInfo", baseInfo);

			if ret == ErrorCode.OK and baseInfo.extra.openid and baseInfo.extra.openid == openId then
				needUpdate = false;
			end
		end

		if AccountManager.update_openid and needUpdate then
			--Log("kekeke update_openid:"..openId);
			AccountManager:update_openid(openId);
		end

		if getglobal("FriendFrame"):IsShown() then
			UpdateQQAuthorizeBtnState();
		end
	end);
end

function UserInfoResult(userinfo)
	--Log("kekeke UserInfoResult userinfo"..userinfo);	
	WaitQQUserInfo = false;
	if userinfo and userinfo ~= "" then
		local info = JSON:decode(userinfo);
		vip.QQUserInfo = info.data;
		print("kekeke QQUserInfo", vip.QQUserInfo)
		local curIsVip = vip.isQQVip;

		if vip.QQUserInfo.is_svip > 0 then
			vip.isQQVip = true;
		else
			vip.isQQVip = false;
		end

		if curIsVip ~= vip.isQQVip then
			RemindOpenVipRedTag(); --更新一下提醒开通会员的红点
		end

		--通知服务器
		if vip.isQQVip then	
			WWW_ma_qq_member_action(OpenId, "is_qq_member_vip", 1, OnQQVipRewardState);
		end
	end
end

function OnQQVipRewardState(data)
	--Log("OnQQVipRewardState");
	WaitQQVipRewardState = false;

	local hasReward = false;
	for k, v in pairs(data) do
		if ns_ma.reward_list[k] then
			ns_ma.reward_list[k].stat = v.stat;
		else
			ns_ma.reward_list[k] = v;
		end

		if v.stat == 1 then		--有奖励
			hasReward = true;
		end
	end

	if getglobal("VipQQFrame"):IsShown() then
		--Log("OnQQVipRewardState UpdateVipRewards");
		UpdateVipRewards();
	else
		-- getglobal("MiniLobbyFrameTopQQVipBtnRedTag"):Show();
		ShowMiniLobbyQQVipBtnRedTag() --mark by hfb for new minilobby
	end
end

function GetOwnOpenId()
	local openId = "";
	if AccountManager.other_baseinfo then
		local ret, baseInfo = AccountManager:other_baseinfo(AccountManager:getUin());
		if ret == ErrorCode.OK and baseInfo.extra.openid then
			openId = baseInfo.extra.openid;
		end
	end

	return openId;
end

---------------------手Q相关 end----------------

function GetGameMapDesc()
	if not CurWorld then return "" end

	if CurWorld:isFreeMode() then
		return "free";
	elseif CurWorld:isSurviveMode() then
		return "survive";
	elseif CurWorld:isCreativeMode() or CurWorld:isCreateRunMode() then
		return "creative";
	elseif CurWorld:isExtremityMode() then
		return "extremity";
	elseif CurWorld:isGameMakerMode() then
		return "maker";
	elseif CurWorld:isGameMakerRunMode() then
		return "makerRun";
	end
end

function RandFetchTable(num,t) -- num 筛取个数，t 筛取源
		--pool = pool or {}
		--math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)))
		local size = tonumber(#t);
		if num > size then
		--Log("RandFetchTable num greater than #t")
		return nil;
	end

	local t_extract = {};
		for i=1,num do
				local rand = math.random(i,size)
				local tmp = t[rand] or rand -- 对于第二个池子，序号跟id号是一致的
				t[rand] = t[i] or i
				t[i] = tmp

				table.insert(t_extract, tmp)
		end

		return t_extract;
end

--字符串分割函数
--传入字符串和分隔符，返回分割后的table
function StringSplit(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	
	local result = {}
	for match in (str..delimiter):gmatch("(.-)"..delimiter) do
			table.insert(result, match)
	end
	return result;
end


--- 按钮、文字自适应相关1 开启 2不开启 ---
FontStringAdaptiveSwitch = 1;

function GetFontStringAdaptiveSwitch()
	return FontStringAdaptiveSwitch;
end
--- 按钮、文字自适应相关 end ---

--界面水印相关
local gCltVerStr = ClientMgr:clientVersionToStr(ClientMgr:clientVersion()) .. getPatchVerStr()
function UpdateUI_WaterMark(font)
	local time = AccountManager:getSvrTime();
	local timeText = "N/A";
	if time > 0 then
		timeText ="["..os.date("%m", time).."/"..os.date("%d", time).."]" .. os.date("%H", time)..":"..os.date("%M", time).."#n";
	end
	local isOversea = get_game_env() >= 10
	local text = GetMyUin() .. "    "..timeText.." "..get_game_env().."  ["..ClientMgr:getApiId().."]" .. gCltVerStr .."#n"
	if isOversea then
		text = GetMyUin() .. "    "..timeText.." "..get_game_env().."  [" .."Global" .. "]" .."["..ClientMgr:getApiId().."]"..gCltVerStr.."#n"	
	end
	
	if type(font) == 'string' then -- 旧ui
		getglobal(font):SetText(text)
	else -- fgui
		local time = AccountManager:getSvrTime();
		local timeText = "N/A";
		if time > 0 then
			timeText ="["..os.date("%m", time).."/"..os.date("%d", time).."]" .. os.date("%H", time)..":"..os.date("%M", time);
		end
		local isOversea = get_game_env() >= 10
		local text = GetMyUin() .. "    "..timeText.." "..get_game_env().."  ["..ClientMgr:getApiId().."]" .. gCltVerStr
		if isOversea then
			text = GetMyUin() .. "    "..timeText.." "..get_game_env().."  [" .."Global" .. "]" .."["..ClientMgr:getApiId().."]"..gCltVerStr
		end
		font:setText(text)
	end
end

-- 增加fromTag参数，表明是哪里在调用这个接口（格式：file:文件名（如friendservice） -- func:函数名（如ReqKickChatGroup）），否则不予显示
function ShowLoadLoopFrame(isShow, fromTag)
	if isShow then
        -- 单机模式下不显示
        if IsStandAloneMode("") then return end

		if fromTag and type(fromTag) == "string" then
			getglobal("LoadLoopFrame"):Show()
			getglobal("LoadLoopFrame"):SetClientString(fromTag)
            -- debug模式下显示标签
            if LuaInterface and LuaInterface:isdebug() then
                getglobal("LoadLoopFrameTag"):SetText(fromTag)
            end
        else
            -- debug模式下给与提示
            if LuaInterface and LuaInterface:isdebug() then
                ShowGameTips("ShowLoadLoopFrame fromTag参数缺少或类型不对")
            end
		end
	else
		getglobal("LoadLoopFrame"):Hide()
	end
end

function HideLoadLoopFrameByTag(fromTag)
	if fromTag and type(fromTag) == "string" then
		if getglobal("LoadLoopFrame"):GetClientString() == fromTag then
			getglobal("LoadLoopFrame"):Hide()
		else
			if LuaInterface and LuaInterface:isdebug() then
				-- ShowGameTips("HideLoadLoopFrameByTag fromTag 未匹配上")
			end
		end
	else
		-- debug模式下给与提示
		if LuaInterface and LuaInterface:isdebug() then
			ShowGameTips("HideLoadLoopFrameByTag fromTag参数缺少或类型不对")
		end
	end
end

local L_LoadLoopFrame2_AutoTime_Seq = nil
function ShowLoadLoopFrame2(isShow, fromTag, timeout, loopDesc, bkgName)
	loopDesc = loopDesc or ""
	if bkgName and bkgName ~= "" then
		getglobal(bkgName):Show()
		getglobal("LoadLoopFrame2Tex"):SetAnchorOffset(0,-28)
		if bkgName == "LoadLoopFrame2Bkg" then
			getglobal("LoadLoopFrame2Desc"):SetTextColor(0,0,0)
		else
			getglobal("LoadLoopFrame2Desc"):SetTextColor(117,53,153)
		end
	end
	getglobal("LoadLoopFrame2Desc"):SetText(loopDesc)
	local loopFrameObj = getglobal("LoadLoopFrame2")
	if not loopFrameObj then 
		if LuaInterface and LuaInterface:isdebug() then
			ShowGameTips("ShowLoadLoopFrame2 getglobal 返回nil")
		end
		return
	end

	if L_LoadLoopFrame2_AutoTime_Seq then
		threadpool:kick(L_LoadLoopFrame2_AutoTime_Seq)
		L_LoadLoopFrame2_AutoTime_Seq = nil
	end

	if isShow then
		if fromTag and type(fromTag) == "string" then
			loopFrameObj:Show()
            -- debug模式下显示标签
            if LuaInterface and LuaInterface:isdebug() then
                getglobal("LoadLoopFrame2Tag"):SetText(fromTag)
            end

			timeout = timeout or 30

			if "number" == type(timeout) and timeout > 0 then
				L_LoadLoopFrame2_AutoTime_Seq = threadpool:delay(timeout, function()
					HideLoadLoopFrame2()
				end)
			end
        else
            -- debug模式下给与提示
            if LuaInterface and LuaInterface:isdebug() then
                ShowGameTips("ShowLoadLoopFrame2 fromTag参数缺少或类型不对")
            end
		end
	else
		loopFrameObj:Hide()
	end
end

function HideLoadLoopFrame2(fromTag)
	if L_LoadLoopFrame2_AutoTime_Seq then
		threadpool:kick(L_LoadLoopFrame2_AutoTime_Seq)
		L_LoadLoopFrame2_AutoTime_Seq = nil
	end
	if getglobal("LoadLoopFrame2") and getglobal("LoadLoopFrame2"):IsShown() then
		getglobal("LoadLoopFrame2"):Hide()
	end
	if fromTag and "string" == type(fromTag) and LuaInterface and LuaInterface:isdebug() then
		ShowGameTips("HideLoadLoopFrame2 fromTag="..fromTag)
	end
end

local L_LoadLoopFrame3_AutoTime_Seq = nil
function ShowLoadLoopFrame3(isShow, fromTag, forbiddenAutoHide)
	if isShow then
		if fromTag and type(fromTag) == "string" then
			getglobal("LoadLoopFrame3"):Show()
            -- debug模式下显示标签
            if LuaInterface and LuaInterface:isdebug() then
                getglobal("LoadLoopFrame3Tag"):SetText(fromTag)
            end
        else
            -- debug模式下给与提示
            if LuaInterface and LuaInterface:isdebug() then
                ShowGameTips("ShowLoadLoopFrame3 fromTag参数缺少或类型不对")
            end
		end
		getglobal("LoadLoopFrame3"):SetClientString(tostring(fromTag))

		if L_LoadLoopFrame3_AutoTime_Seq then
			threadpool:kick(L_LoadLoopFrame3_AutoTime_Seq)
			L_LoadLoopFrame3_AutoTime_Seq = nil
		end
		if not forbiddenAutoHide then
			L_LoadLoopFrame3_AutoTime_Seq = threadpool:delay(30, function()
				HideLoadLoopFrame3()
			end)
		end
	else
		HideLoadLoopFrame3()
	end
	getglobal("LoadLoopFrame3Title"):SetText("")
end

function HideLoadLoopFrame3(fromTag)
	if L_LoadLoopFrame3_AutoTime_Seq then
		threadpool:kick(L_LoadLoopFrame3_AutoTime_Seq)
		L_LoadLoopFrame3_AutoTime_Seq = nil
	end
	if getglobal("LoadLoopFrame3") and getglobal("LoadLoopFrame3"):IsShown() then
		getglobal("LoadLoopFrame3"):Hide()
	end
	if fromTag and "string" == type(fromTag) and LuaInterface and LuaInterface:isdebug() then
		ShowGameTips("HideLoadLoopFrame3 fromTag="..fromTag)
	end
	getglobal("LoadLoopFrame3Title"):SetText("")
	getglobal("LoadLoopFrame3"):SetClientString("")
end

function UpdateLoadLoopFrame3Desc(fromTag, desc)
	if getglobal("LoadLoopFrame3"):IsShown() and getglobal("LoadLoopFrame3"):GetClientString() == fromTag then
		getglobal("LoadLoopFrame3Title"):SetText(tostring(desc))
	end
end
---------------------------------------------------------------UI事件---------------------------------------------------------------
--[[
	根据不同的为优化的onEvent函数的实际情况，会有延迟、卡顿等缺陷	
	Created on 2019-11-26 at 11:24:12
]]
_G.UIEvent = {

}
local UIEvent = _G.UIEvent

function UIEvent.postOnClick()
	GameEventQue:postOnClick(this:GetName());
	if this:GetName() == "RoomUIFrameSetOptionSpamPreventionSelectMinutes" then 
		SelectMinutes_OnClick()
	end
end
--[[
	右为开	
	Created on 2019-09-05 at 10:10:32
]]
function UIEvent.postOnCheck()
	local szUIName 	= this:GetName();
	-- print("postOnCheck(): szUIName = ", szUIName);
	local checked		= 0;
	local bkg 		= getglobal(szUIName.."Bkg");
	local point 		= getglobal(szUIName.."Point");	
	local name = getglobal(szUIName .. "Name")
	if point:GetRealLeft() - bkg:GetRealLeft() > 20  then --设为关
		checked = false;
		point:SetPoint("left", szUIName, "left", 0, 0);
		this:SetText(GetS(21743))
	else --设为开
		checked = true;
		point:SetPoint("right", szUIName, "right", 0, 0);
		this:SetText(GetS(21742))
	end
	-- print("postOnCheck(): checked = ", checked);
	GameEventQue:postOnCheck(szUIName, checked);
end

function UIEvent.postOnFocusLost()
	GameEventQue:postOnFocusLost(this:GetName());
end

function UIEvent.postOnEnterPressed()
	GameEventQue:postOnEnterPressed(this:GetName());
end

function UIEvent.postOnMouseEnter(...)
	GameEventQue:postOnMouseEnter(this:GetName());
end

function UIEvent.postOnMouseLeave(...)
	GameEventQue:postOnMouseLeave(this:GetName());
end

function UIEvent.postOnMouseDownUpdate()
	if arg1 < 0.5 then return end
	GameEventQue:postOnMouseDownUpdate(this:GetName());
end

function UIEvent.postOnMouseUp()
	if ClientMgr:isMobile() then
		GameEventQue:postOnMouseUp(this:GetName());
	end
end
function UIEvent.postOnMouseDown()
	GameEventQue:postOnMouseDown(this:GetName());
end

function getServerTime()
	-- body
	if not container or not container.conn then
		return AccountManager:getSvrTime()
	end

	local nowTime = container.conn.svrtime
	return nowTime
end

function CppOpenUI(name, param)
	local ok, t_param = pcall(JSON.decode, JSON, param)
	if name == "MiniUIRiddlesMain" then
		GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/ingame"})
		GetInst("MiniUIManager"):OpenUI("main_lanternriddle","miniui/miniworld/ingame","MiniUIRiddlesMain", t_param)	
	elseif  name == "spittingShelter" then
		getglobal("spittingShelter"):Show()
	else
		GetInst("UIManager"):Open(name, t_param)
	end
end

function PlayerCloseUI(player, name, param)
	local ok, t_param = pcall(JSON.decode, JSON, param)
	if name == "MiniUIRiddlesMain" then
		if g_F3897TempFlag[t_param.objId] then
			g_F3897TempFlag[t_param.objId].objId = 0
		end
	end
	-- body
end

--是否忽略屏蔽
function IsIgnoreReplace(str, ignoreTable)
	if not str  then
		return false
	end
	ignoreTable = ignoreTable or {}
	--如果名字是迷你号则不屏蔽
	if ignoreTable.CheckMiniAccountNick then
		local subStr = string.match(str, "[0-9]+") or ""
		return subStr == tostring(GetMyUin())
	end

	if ignoreTable.CheckMiniUrl == true then
		local url1 = ClientUrl:GetUrlString("HttpMini1Check1", "")--"https://www.mini1.cn",
		local url2 = ClientUrl:GetUrlString("HttpMini1Check2", "")--"https://www.mini1.cn",
		local url3 = ClientUrl:GetUrlString("HttpMini1Check3", "")--"www.mini1.cn",
		local url4 = ClientUrl:GetUrlString("HttpMini1Check4", "")--"mini1.cn",
		if url1 == "" then url1 = nil end
		if url2 == "" then url2 = nil end
		if url3 == "" then url3 = nil end
		if url4 == "" then url4 = nil end
		local miniList = { url1, url2, url3, url4 }
		for key, value in pairs(miniList) do
			if string.match(str, value) then--str == value then
				return true
			end
		end
		return false
	end

	return false
end

CommonNewPlayerGuide = {
	IsClick  = false,
	CallBack = nil
}

-- 通用新手引导界面-重置UI和数据
function CommonNewPlayerGuide_ResetUI(isShow, isShowArrow, isShowSkipBtn)
	if isShow then
		getglobal("CommonNewPlayerGuide"):Show()
		if isShowArrow then
			getglobal("CommonNewPlayerGuideTipBkg"):Show()
			getglobal("CommonNewPlayerGuideTipArrow"):Show()
			getglobal("CommonNewPlayerGuideTipInfo"):Show()
		end
		if isShowSkipBtn then
			getglobal("CommonNewPlayerGuideGuideSkip"):Show()
		end
	else
		getglobal("CommonNewPlayerGuide"):Hide()
		getglobal("CommonNewPlayerGuideTipBkg"):Hide()
		getglobal("CommonNewPlayerGuideTipArrow"):Hide()
		getglobal("CommonNewPlayerGuideTipInfo"):Hide()
		getglobal("CommonNewPlayerGuideGuideSkip"):Hide()
	end	
end

function CommonNewPlayerGuide_ResetData(isClick, callBack)
	CommonNewPlayerGuide.IsClick = isClick or false
	CommonNewPlayerGuide.CallBack = callBack
end

-- 通用新手引导界面-退出引导按钮回调
function CommonNewPlayerGuide_ExitBtnClick()
	if CommonNewPlayerGuide.IsClick then
		CommonNewPlayerGuide.CallBack()
		CommonNewPlayerGuide_ResetUI()
		CommonNewPlayerGuide_ResetData()
	end
end

-- 表转字符串，一般用于[1,2,3,4] => "1, 2, 3, 4"，埋点常用
function CommonArrToString(arr)
	local strIDs = ""
	for index = 1, #arr do
		local id = arr[index]
		strIDs = strIDs .. string.format("%d", id)
		if arr[index + 1] then strIDs = strIDs .. "," end
	end
	return strIDs
end

-- 获取以当前时间为基础 未来或过去的 _futureDays 天，第 _hour 小时的时间戳
-- 如参数 _futureDays = 0，则是获取当天的 第 _hour 小时的时间戳
-- 如参数 _futureDays = 1，则是获取 明天 的 第 _hour 小时的时间戳
-- 如参数 _futureDays = -1，则是获取 昨天 的 第 _hour 小时的时间戳
function GetFutureTime(_futureDays, _hour)
	local curTimestamp = getServerTime()
	local dayTimestamp = 24 * 60 * 60
	local newTime = curTimestamp + dayTimestamp * _futureDays
	local newDate = os.date("*t", newTime)
	--这里返回的是你指定的时间点的时间戳
	return os.time({ year = newDate.year, month = newDate.month, day = newDate.day, hour = _hour, minute = newDate.minute, second = newDate.second })
end

-- 领取商品、额外奖励等道具的逻辑处理
--[[
	propDef = {
		ItemId,
		ItemNum,
		IsWareHouse
	}
	nJump 跳转界面
	reportId 上报id
	reportKey 上报key
]]
function ReceiveItemLogic(propDef, nJump, reportId, reportKey)
	if propDef and propDef.ItemId then
		-- 定制avatar：跳转到定制界面
		if propDef.IsWareHouse == 2 then			
			-- 领取奖励逻辑处理
			local list = { {id = propDef.ItemId, num = propDef.ItemNum} }
			SetGameRewardFrameInfo(GetS(3160), list, GetS(70592), function()
				standReportEvent(reportId, reportKey, "Sure", "click")
			end, {GetS(4756), function()
				standReportEvent(reportId, reportKey, "Details", "click")
				-- 跳转至商城-定制
				ShopJumpTabView(3, nJump)
			end})

			standReportEvent(reportId, reportKey, "-", "view", {standby1 = propDef.ItemId, standby2 = propDef.ItemNum})
			standReportEvent(reportId, reportKey, "Sure", "view")
			standReportEvent(reportId, reportKey, "Details", "view")

		-- 普通道具：跳转到仓库界面
		elseif propDef.IsWareHouse == 1 then
			if AccountManager.itemlist_can_add and not AccountManager:itemlist_can_add({DefMgr:getItemDef(propDef.ItemId).ID}) then
				StashIsFullTips();
				return;
			else
				-- 领取奖励逻辑处理
				local list = { {id = propDef.ItemId, num = propDef.ItemNum} }
				SetGameRewardFrameInfo(GetS(3160), list, GetS(3401), function()
					standReportEvent(reportId, reportKey, "Sure", "click")
				end, {GetS(3056), function()
					standReportEvent(reportId, reportKey, "ToStoreHouse", "click")
					-- 跳转至商城-仓库
					ShopJumpTabView(8, nJump)
				end})

				standReportEvent(reportId, reportKey, "-", "view", {standby1 = propDef.ItemId, standby2 = propDef.ItemNum})
				standReportEvent(reportId, reportKey, "Sure", "view")
				standReportEvent(reportId, reportKey, "ToStoreHouse", "view")
			end

		-- 游戏内使用的道具：直接发放到背包
		elseif propDef.IsWareHouse == 0 then
			local list = { {id = propDef.ItemId, num = propDef.ItemNum} }
			SetGameRewardFrameInfo(GetS(3160), list, "", function()
				standReportEvent(reportId, reportKey, "Sure", "click")
			end)

			standReportEvent(reportId, reportKey, "-", "view", {standby1 = propDef.ItemId, standby2 = propDef.ItemNum})
			standReportEvent(reportId, reportKey, "Sure", "view")
			
			if ClientCurGame and ClientCurGame.getMainPlayer and ClientCurGame:getMainPlayer() then
				-- 如果是游戏内部直接使用的道具，则直接放入玩家背包
				ClientCurGame:getMainPlayer():gainItems(propDef.ItemId, propDef.ItemNum)
			end
		end
	end
end

function DeliverCalendarEvent(type, code) -- 订阅统一回调
	-- ShowGameTips("type:" .. type .. "code:" .. code)
	if type == 4 then
		GetInst("MiniUIManager"):GetCtrl("main_birthday_party_countdown"):SubscribeCallBack(code)
	elseif type == 5 then --端午节
		if GetInst("MiniUIManager"):GetCtrl("activity_douluo_subscribe") then
			GetInst("MiniUIManager"):GetCtrl("activity_douluo_subscribe"):SubscribeCallBack(code)
		end
	elseif type == 6 then 
		if GetInst("MiniUIManager"):GetCtrl("main_rivalry") then
			GetInst("MiniUIManager"):GetCtrl("main_rivalry"):SubscribeCallBack(code)
		end
	end
end

-- 播放角色音效时关闭背景音乐
function PlayStoreSound2DCloseBGMusic(path)
	if path and path ~= "" then
		local isStopBgMusic = ClientMgr:getGameDataPath("GameData.Settinig", "soundopen")
		ClientMgr:playStoreSound2D(path, isStopBgMusic == 1)
	end
end

--显示安全合规充值限制弹窗
--11003 年龄充值限制 stringid  22041
--11002 月累计充值限制 stringid  22009
--11001 单次充值限制  stringid  22008
--11005 强渠道月充值限制(未获取到实名认证) stringid  9908
function ShowSecurityComplianceFrame(code,data)
	if (code == 11001 or code == 11002) and data.id and data.money then--每次充值限额
		MessageBox(4, GetS(tonumber(data.id),data.money))
	elseif (code == 11003 or code == 11005) and data.id then--未满8周岁 或 强渠道月充值限制
		MessageBox(4, GetS(tonumber(data.id)))
	end
end

-- 设置武器皮肤图标
function SetPlayerWeaponSkinIcon(uin, msg, gui, isFui)
	if not CurWorld then
		return
	end
	local player = CurWorld:getActorMgr():findActorByWID(uin)

	if player then
		local itemid = player:getCurToolID()
		local skinid =  WeaponSkin_HelperModule:GetSkinID(uin, itemid)
		if  msg.skinid then
			skinid =  msg.skinid
		end
		local config = ns_shop_all_skinid_weaponskin_config[skinid] and ns_shop_all_skinid_weaponskin_config[skinid][1] or {}
		msg.skinid = skinid
		if config and config.EffectBtn ~= 0 then
			local weaponloader = gui
			for key, value in pairs(ns_shop_forever_weaponskin_config) do
				if value.SkinID == skinid then

					if GetInst("ShopService"):CheckSkinWeaponRes(skinid) == 0 then 
						--资源已下载
						if isFui then
							gui:setURL(string.format("ui/gunicons/%d.png", value.Photo))
							gui:setVisible(true)
						else
							gui:SetTexture(string.format("ui/gunicons/%d.png", value.Photo))
						end
					else
						--资源未下载
						if isFui then
							gui:setURL("ui/gunicons/weapon_default.png")
						else
							gui:SetTexture("ui/gunicons/weapon_default.png")
						end
					end 
					break
				end
			end
		end
	end
end

-- 获取字符个数
function GetStringByLength(inputstr, maxLength)
	if not inputstr or (inputstr and inputstr == "") then
		return "", 0
	end

    local length = 0  -- 字符的个数
    local i = 0
    while true do
        local curByte = string.byte(inputstr, i + 1)
        local byteCount = 1
        if curByte > 239 then
            byteCount = 4  -- 4字节字符
        elseif curByte > 223 then
            byteCount = 3  -- 汉字
        elseif curByte > 128 then
            byteCount = 2  -- 双字节字符
        else
            byteCount = 1  -- 单字节字符
        end

		if length >= maxLength then
        	break
        end

        i = i + byteCount
        length = length + 1

        if i + 1 > #inputstr then
            break
        end
    end
    return string.sub(inputstr, 1, i), length
end

---------------------------------------------------------解析table成字符串--------------------
local tabCode = "\t"
local deep = 1

function ReadTable(tableData, deep)
    local function StrAddTab(str, deep)
        for i = 1, deep do
            str = str .. tabCode
        end
        return str
    end

    local function StrTabKey(key)
        if type(key) == "string" then
            return key
        else
            return "[" .. key .. "]"
        end
    end
    
	local str = "{\n"
	for key, val in pairs(tableData) do
		if type(val) == "boolean" then
			str = StrAddTab(str, deep)
			if val then
				str = str .. StrTabKey(key) .. " = " .. "true" .. ",\n"
			else
				str = str .. StrTabKey(key) .. " = " .. "false" .. ",\n"
			end
		elseif type(val) == "table" then
			str = StrAddTab(str, deep)
			deep = deep + 1
			str = str .. StrTabKey(key) .. " = " ..  ReadTable(val, deep)
			deep = deep - 1
			str = StrAddTab(str, deep)
			str = str .. "},\n"
		elseif type(val) == "userdata" then
			str = StrAddTab(str, deep)
			str = str .. StrTabKey(key) .. " = 'userdata',\n"
		else
			str = StrAddTab(str, deep)
			if type(val) == 'string' then
				str = str .. StrTabKey(key) .. " = [[" .. val .. "]],\n"
			else
				str = str .. StrTabKey(key) .. " = " .. val .. ",\n"
			end
		end
	end
	
	return str
end

-------------------------------------------把表数据写到磁盘
function WriteDataToDisk(filename, data)

	local dir = "data/temp/http_cachefile"

	if AccountManager and AccountManager.getUin then
		dir = dir .. "_" .. AccountManager:getUin() .. "/"
	end

	if not gFunc_isStdioDirExist(dir) then
		gFunc_makeStdioDir(dir)
	end

	filename = dir .. filename
	local str = "local val = \n"
	if type(data) == "table" then
		str = str .. ReadTable(data, deep)
		str = str .. "}\n"
	elseif type(data) == "string" then
		str = str .. data .. "\n"
	end

	local file = io.open(filename, "w+")
	file:write(str)
	file:close()
end

-----CommonJustEvtFrame evt---game事件分发依赖UI节点，纯数据类需要监听game事件只能搞一个节点来弄---
function CommonJustEvtFrame_OnLoad()
	GetInst("RoomService"):RegisterEvents();
	GetInst("ArchiveLobbyDataManager"):RegisterEvents();
	GetInst("ArchiveLobbyRecordManager"):RegisterEvents();
	GetInst("CloudStorageUploadMgr"):RegisterEvents();
	GetInst("ArchiveServerBackupMgr"):RegisterEvents();
end

function CommonJustEvtFrame_OnEvent()
	GetInst("RoomService"):OnEvent();
	GetInst("ArchiveLobbyDataManager"):OnEvent();
	GetInst("ArchiveLobbyRecordManager"):OnEvent();
	GetInst("CloudStorageUploadMgr"):OnEvent();
	GetInst("ArchiveServerBackupMgr"):OnEvent();
end
------------------------------------------------------------------------------------------


function SetSkinQualityBg(skinDef, ui)
	local quality = 1
	if skinDef then
		quality = ItemUseSkinDefTools:getSkinQuality(skinDef.ID)
	end
	ui:SetTexture("ui/mobile/texture2/bigtex/img_block0"..quality..".png")
end

function SetAvatarQualityBg(modelid, ui)
	local quality = 1
	quality = ItemUseSkinDefTools:getAvatarQuality(modelid)
	ui:SetTexUV("img_prop0"..quality)
end

function SetItemQualityBg(itemid, ui)
	local quality = 1
	quality = ItemUseSkinDefTools:getItemQuality(itemid)
	ui:SetTexUV("img_small_prop0"..quality)
end

function SetAvatarListQualityBg(modelIDList, ui)
	-- body
	local quality = 1
	for index, value in pairs(modelIDList) do
		-- body
		quality = math.max(quality, ItemUseSkinDefTools:getAvatarQuality(value.ModelID))
	end
	ui:SetTexture("ui/mobile/texture2/bigtex/img_block0"..quality..".png")

end

function SetSeatInfoQualityBg(seatInfo, ui)
	-- body
	local quality = 1
	if seatInfo then
		for key, value in pairs(seatInfo) do
			if value.cfg then
				quality = math.max(quality, ItemUseSkinDefTools:getAvatarQuality(value.cfg.ModelID))
			end
		end
	end
	ui:SetTexture("ui/mobile/texture2/bigtex/img_block0"..quality..".png")

end
