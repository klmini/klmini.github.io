
local CurShowStarIndex = 1;		--当前显示的第一个货物的Index;
local CurChooseIndex = 1;		--当前选择交易的货物的Index;

local MAX_TRADER_ITEMS = 6;

--点击货物
local IsLongPress = false;
function Goods_OnClick()
	if IsLongPress then 
		IsLongPress = false;
		return 
	end;
	local btnName = this:GetName();
	if string.find(btnName, "Goods1") then
		CurChooseIndex = CurShowStarIndex;
	elseif string.find(btnName, "Goods2") then
		CurChooseIndex = CurShowStarIndex + 1;
	elseif string.find(btnName, "Goods3") then
		CurChooseIndex = CurShowStarIndex + 2;
	end
	UpdateNpcTradeFrameInfo();
end

function Goods_OnMouseDownUpdate()
	if arg1 < 0.6 then return end

	local grid_index = 0;
	local index = CurShowStarIndex;
	local btnName = this:GetName();
	local offset = 0;
	local scale = UIFrameMgr:GetScreenScaleY();
	if string.find(btnName, "Goods1") then
		local obtain_index = NPCTRADE_START_INDEX + 2*index - 1;
		local tradeDef = DefMgr:getNpcTradeDef( ClientBackpack:getGridUserdata(obtain_index) );
		if tradeDef == nil then return end

		local type = tradeDef.TradeType;
		grid_index = obtain_index;
		if type == 0 then
			grid_index = NPCTRADE_START_INDEX + 2*(index-1);
		end
		if index == CurChooseIndex then
			offset = 15/scale;
		end
	elseif string.find(btnName, "Goods2") then
		local obtain_index = NPCTRADE_START_INDEX + 2*(index+1) - 1;
		local tradeDef = DefMgr:getNpcTradeDef( ClientBackpack:getGridUserdata(obtain_index) );
		if tradeDef == nil then return end

		local type = tradeDef.TradeType;
		grid_index = obtain_index;
		if type == 0 then
			grid_index = NPCTRADE_START_INDEX + 2*(index);
		end
		if index+1 == CurChooseIndex then
			offset = 15/scale;
		end
	elseif string.find(btnName, "Goods3") then
		local obtain_index = NPCTRADE_START_INDEX + 2*(index+2) - 1;
		local tradeDef = DefMgr:getNpcTradeDef( ClientBackpack:getGridUserdata(obtain_index) );
		if tradeDef == nil then return end

		local type = tradeDef.TradeType;
		grid_index = obtain_index;
		if type == 0 then
			grid_index = NPCTRADE_START_INDEX + 2*(index+1);
		end
		if index+2 == CurChooseIndex then
			offset = 15/scale;
		end
	end

	local itemId = ClientBackpack:getGridItem(grid_index);
	if grid_index > 0 and itemId ~= 14001 then	--星星不显示tips
		SetMTipsInfo(grid_index, btnName, true);
	end
end

function Goods_OnMouseUp()
	local MItemTipsFrame = getglobal("MItemTipsFrame");
	if MItemTipsFrame:IsShown() and IsLongPressTips then
		MItemTipsFrame:Hide();
	end
end

function Goods_OnMouseEnter_PC()
    arg1 = 1;
    Goods_OnMouseDownUpdate();
end

function NpcTradeFrame_OnLoad()
	this:RegisterEvent("GE_BACKPACK_CHANGE");
	this:RegisterEvent("GE_PLAYERATTR_CHANGE")
	NpcTradeFrame_AddGame()
end

function NpcTradeFrame_AddGame()
	SubscribeGameEvent(nil,GameEventType.BackPackChange,function(context)
		local paramData = context:GetParamData()
		local grid_index = paramData.gridIndex
		if grid_index and grid_index >= NPCTRADE_START_INDEX and grid_index < NPCTRADE_START_INDEX+1000 then
			UpdateNpcTradeFrameInfo();
			UpdateLeftRightBtnState();
		end
	end)
	SubscribeGameEvent(nil,GameEventType.PlayerAttrChange,function(context)
		if getglobal("NpcTradeFrame"):IsShown() then
			UpdateRefreshCost();
		end
	end)
end

function NpcTradeFrame_OnEvent()
	if arg1 == "GE_BACKPACK_CHANGE" then
		if getglobal("NpcTradeFrame"):IsShown() then
			local ge = GameEventQue:getCurEvent();
			local grid_index = ge.body.backpack.grid_index;
			if grid_index >= NPCTRADE_START_INDEX and grid_index < NPCTRADE_START_INDEX+1000 then
				UpdateNpcTradeFrameInfo();
				UpdateLeftRightBtnState();
			end
		end
	elseif arg1 == "GE_PLAYERATTR_CHANGE" then
		if getglobal("NpcTradeFrame"):IsShown() then
			UpdateRefreshCost();
		end
	end
end

local t_NpcInfo = {
			[3010]={descid=118, iconid=21},
			[3011]={descid=119, iconid=20},
			[3012]={descid=120, iconid=22},
			[3013]={descid=3511, iconid=23},
			[3014]={descid=3512, iconid=24},
			[3015]={descid=3582, iconid=25},
			[3016]={descid=3829, iconid=26},
			[3017]={descid=960, iconid=27},
			[3018]={descid=264, iconid=28},
			[3019]={descid=86004, iconid=28},
			[3210]={descid=86022, iconid=28},
			[3211]={descid=86023, iconid=28},
			[3222]={descid=86030, iconid=28},
			[3223]={descid=86029, iconid=28},
			[3229]={descid=86028, iconid=28},
		}
function NpcTradeFrame_OnShow()
	HideAllFrame("NpcTradeFrame", true);
	UpdateLeftRightBtnState();
	UpdateNpcTradeFrameInfo(true);

	UpdateRefreshCost();

	if OpenedContainerMob ~= nil then
		local npcId = OpenedContainerMob:getDef().ID;
		getglobal("NpcTradeFrameMonologue"):SetText(GetS(t_NpcInfo[npcId].descid), 55, 54, 49);
		getglobal("NpcTradeFrameNpcHead"):SetTexture("ui/roleicons/"..npcId..".png");

		if npcId == 3229 then
			FisherManNpcTradeUseReport(1, 0, "", 0)
		elseif npcId == 3223 then
			NpcTradeUseReport(1, 0, "", 0,"ISLAND_BUSINESSMAN")
		elseif npcId == 3222 then
			NpcTradeUseReport(1, 0, "", 0,"PIRATE_BUSINESSMAN")
		end
	end
	if not getglobal("NpcTradeFrame"):IsReshow() then	
		ClientCurGame:setOperateUI(true);
	end
end

function UpdateADRefreshBtnState(ADisStatistics)
	local RefreshBtn      = getglobal("NpcTradeFrameRefreshBtn")
	local SmallRefreshBtn = getglobal("NpcTradeFrameSmallRefreshBtn")
	local ADRefreshBtn    = getglobal("NpcTradeFrameADRefreshBtn")
	local position_id = 3
	local npcId = 0;
	if OpenedContainerMob and CurWorld then
		npcId = OpenedContainerMob:getDef().ID;
	end
	if npcId and ((npcId >= 3210 and npcId <= 3213) or npcId == 3229 or npcId == 3222 or npcId == 3223) then
		SmallRefreshBtn:Hide();
		ADRefreshBtn:Hide();
		RefreshBtn:Show();
	elseif IsAdUseNewLogic(position_id) then	
		GetInst("AdService"):IsAdCanShow(position_id, function(result, ad_info)
			if result then
				if not ADRefreshBtn:IsShown() or ADisStatistics then
					StatisticsADNew('show', position_id, ad_info);
					if AccountManager.ad_show then
						AccountManager:ad_show(position_id);
					end
					GetInst("AdService"):Ad_Show(position_id)
				end
				RefreshBtn:Hide();
				SmallRefreshBtn:Show();
				ADRefreshBtn:Show();
			else
				SmallRefreshBtn:Hide();
				ADRefreshBtn:Hide();
				RefreshBtn:Show();
			end
		end)
	else
		if t_ad_data.canShow(3) then	--刷新广告
			if not ADRefreshBtn:IsShown() or ADisStatistics then
				StatisticsAD('show', 3);
				if AccountManager.ad_show then
					AccountManager:ad_show(3);
				end
			end
			RefreshBtn:Hide();
			SmallRefreshBtn:Show();
			ADRefreshBtn:Show();
		else
			SmallRefreshBtn:Hide();
			ADRefreshBtn:Hide();
			RefreshBtn:Show();
		end
	end
end

function GetCurRackLockNum()
	local lockNum = 0;
	for i=1, MAX_TRADER_ITEMS do
		local obtain_index = NPCTRADE_START_INDEX + 2*i - 1; 
		local itemId = ClientBackpack:getGridItem(obtain_index);
		local dur = ClientBackpack:getGridDuration(obtain_index);
		if itemId > 0 and dur <= 0 then
			lockNum = lockNum+1;
		end
	end
	return lockNum;
end

function UpdateRefreshCost()
	local lockNum = GetCurRackLockNum();

	local starNum 	= math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	local cost	= getglobal("NpcTradeFrameRefreshBtnCost");
	local needNum 	= 5-lockNum;
	if needNum < 1 then
		needNum = 1;
	end
	cost:SetText(needNum);
	if starNum >= (needNum) then
		cost:SetTextColor(26, 254, 31);
	else
		cost:SetTextColor(254, 85, 26);
	end	
end

function NpcTradeFrame_OnHide()
	ShowMainFrame();
	CurShowStarIndex = 1;
	CurChooseIndex = 1;
	CurMainPlayer:closeContainer();
	if not getglobal("NpcTradeFrame"):IsRehide() then	
	ClientCurGame:setOperateUI(false);
	end
end

function IsCurChoose2Index(index)
	return CurChooseIndex == (index+1)/2;
end

function UpdateNpcTradeFrameInfo(ADisStatistics)
	local index = 1; 
	for i=CurShowStarIndex, CurShowStarIndex+2 do
		local goods = getglobal("NpcTradeFrameRackGoods"..index);
		index = index + 1;	
	
		local obtain_index = NPCTRADE_START_INDEX + 2*i - 1;	--获得的物品
		--local type = ClientBackpack:getGridUserdata(obtain_index);--交易类型
		local Id = ClientBackpack:getGridUserdata(obtain_index);
		local tradeDef = DefMgr:getNpcTradeDef( ClientBackpack:getGridUserdata(obtain_index) );
		if tradeDef == nil then return end

		local type = tradeDef.TradeType;
		local dur = ClientBackpack:getGridDuration(obtain_index); --标记锁定	
		local payout_index = NPCTRADE_START_INDEX + 2*(i-1);	--付出的物品
		
		local grid_index = obtain_index;
		if type == 0 then
			grid_index = payout_index;
		end
		
		local itemId = ClientBackpack:getGridItem(grid_index);
		if itemId > 0 then			
			local num = ClientBackpack:getGridNum(grid_index);
			if type == 0 then
				hightNum = ClientBackpack:getGridUserdata(grid_index);
				num = num + hightNum * 256
			end			

			local normal  		= getglobal(goods:GetName().."Normal");
			local hightLight 	= getglobal(goods:GetName().."HightLight");
			local icon 		= getglobal(goods:GetName().."Icon");
			local numFont		= getglobal(goods:GetName().."Num");
			local lock		= getglobal(goods:GetName().."Lock");
			local name		= getglobal(goods:GetName().."Name");

			SetItemIcon(icon, itemId)
			
			if IsShowRuneOrEnchantGridEffect(grid_index, itemId) then
				icon:setMask("particles/texture/item_light.png");
				icon:SetMaskColor(ClientBackpack:getGridEnchantColor(grid_index));
				icon:SetOverlay(true);				
			else
				icon:SetOverlay(false);
			end

			local def = ItemDefCsv:get(itemId);
			local nameText = "";
			if def ~= nil then
				if type == 0 then
					nameText = GetS(535).."："..def.Name;
				else
					nameText = def.Name;
				end				
			end
			
			if dur == 0 then
				icon:SetGray(true);
				lock:Show();
			
				if type == 0 then
					nameText = def.Name..GetS(536);
				else
					nameText = def.Name..GetS(537);
				end
			else
				icon:SetGray(false);
				lock:Hide();
			end
			if IsCurChoose2Index(obtain_index-NPCTRADE_START_INDEX) then
				hightLight:Show();
			else
				hightLight:Hide();
			end
			numFont:SetText(num);

			name:SetText(nameText);
			if dur == 0 then
				name:SetTextColor(254, 85, 26);
			else
				if type == 0 then 
					name:SetTextColor(219, 129, 0);	
				else
					name:SetTextColor(0, 168, 8);
				end
			end
		end
	end
	UpdateChooseTradeInfo();
	UpdateADRefreshBtnState(ADisStatistics);
end

function UpdateChooseTradeInfo()
	local type;
	for i=1, MAX_TRADER_ITEMS do
		if CurChooseIndex == i then
			local payout_index = NPCTRADE_START_INDEX + 2*(i-1);
			local payItemId = ClientBackpack:getGridItem(payout_index);

			local exchangeNormal 		=  getglobal("NpcTradeFrameTradeShowExchangeNormal");
			local smallExchangeNormal 	=  getglobal("NpcTradeFrameTradeShowSmallExchangeNormal");

			local extraInfo = {};

			local needGray = false;
			if payItemId > 0 then
				local payIcon	= getglobal("NpcTradeFrameTradeShowPayItemIcon");
				local payNum	= getglobal("NpcTradeFrameTradeShowPayItemNum");
                local name	= getglobal("NpcTradeFrameTradeShowPayItemName");
                local Lock	= getglobal("NpcTradeFrameTradeShowPayItemLock");
				local def = ItemDefCsv:get(payItemId);
				name:SetText(def.Name);
				SetItemIcon(payIcon, payItemId);
                Lock:Hide()

				if IsShowRuneOrEnchantGridEffect(payout_index, payItemId) then
					payIcon:setMask("particles/texture/item_light.png");
					payIcon:SetMaskColor(ClientBackpack:getGridEnchantColor(payout_index));
					payIcon:SetOverlay(true);
				else
					payIcon:SetOverlay(false);
				end

				local hightNum = ClientBackpack:getGridUserdata(payout_index)*256;
				local needNum = ClientBackpack:getGridNum(payout_index) + hightNum;
				local hasNum = GetItemNum2Id(payItemId);
			
				extraInfo.price = needNum;
			
				local text = ""
				if hasNum >= needNum then	--足够
					text = "#c1afe1f" .. hasNum .. "#n/"..needNum;
				else				--不足
					text = "#cfe551a" .. hasNum .. "#n/" ..needNum;
					needGray = true;
				end
				payNum:SetText(text);
			end
			
			local obtain_index = NPCTRADE_START_INDEX + 2*i - 1;
			local obtainItemId = ClientBackpack:getGridItem(obtain_index);
			--local type = ClientBackpack:getGridUserdata(obtain_index);
			local tradeDef = DefMgr:getNpcTradeDef( ClientBackpack:getGridUserdata(obtain_index) );
			if tradeDef == nil then return end

			type = tradeDef.TradeType;
			if obtainItemId > 0 then
				local getIcon	= getglobal("NpcTradeFrameTradeShowGetItemIcon");
				local getNum	= getglobal("NpcTradeFrameTradeShowGetItemNum");
				local name	= getglobal("NpcTradeFrameTradeShowGetItemName");
				local Lock	= getglobal("NpcTradeFrameTradeShowGetItemLock");
				local def = ItemDefCsv:get(obtainItemId);
				name:SetText(def.Name);
				SetItemIcon(getIcon, obtainItemId);
                Lock:Hide()
                
				if IsShowRuneOrEnchantGridEffect(obtain_index, obtainItemId) then
					getIcon:setMask("particles/texture/item_light.png");
					getIcon:SetMaskColor(ClientBackpack:getGridEnchantColor(obtain_index));
					getIcon:SetOverlay(true);
				else
					getIcon:SetOverlay(false);
				end
				getNum:SetText(ClientBackpack:getGridNum(obtain_index));

				if ClientBackpack:getGridDuration(obtain_index) == 0 or (needGray and type ~= 1) then
					exchangeNormal:SetGray(true);
					smallExchangeNormal:SetGray(true);
				else
					exchangeNormal:SetGray(false);
					smallExchangeNormal:SetGray(false);
				end

				if ClientBackpack:getGridDuration(obtain_index) == 0 then
					extraInfo.isLock = true;
				else
					extraInfo.isLock = false;
				end

				extraInfo.num = ClientBackpack:getGridNum(obtain_index);
				extraInfo.tradeType = type;
				
				print("kekeke UpdateChooseTradeInfo")	
				local position_id = 4
				local npcId = 0;
				if OpenedContainerMob and CurWorld then
					npcId = OpenedContainerMob:getDef().ID;
				end
				if (npcId >= 3210 and npcId <= 3213) or npcId == 3229 or npcId == 3222 or npcId == 3223 then
					getglobal("NpcTradeFrameTradeShowADExchange"):Hide();
					getglobal("NpcTradeFrameTradeShowSmallExchange"):Hide();
					getglobal("NpcTradeFrameTradeShowExchange"):Show();
				elseif IsAdUseNewLogic(position_id) then
					GetInst("AdService"):IsAdCanShow(position_id, function(result, ad_info)
						if result then
							getglobal("NpcTradeFrameTradeShowExchange"):Hide();
							getglobal("NpcTradeFrameTradeShowADExchange"):Show();
							getglobal("NpcTradeFrameTradeShowSmallExchange"):Show();
							StatisticsADNew('show', position_id, ad_info);
							if AccountManager.ad_show then
								AccountManager:ad_show(position_id);
							end
							GetInst("AdService"):Ad_Show(position_id)
						else
							getglobal("NpcTradeFrameTradeShowADExchange"):Hide();
							getglobal("NpcTradeFrameTradeShowSmallExchange"):Hide();
							getglobal("NpcTradeFrameTradeShowExchange"):Show();
						end
					end)
				else
					if t_ad_data.canShow(4, extraInfo) then
						getglobal("NpcTradeFrameTradeShowExchange"):Hide();
						getglobal("NpcTradeFrameTradeShowADExchange"):Show();
						getglobal("NpcTradeFrameTradeShowSmallExchange"):Show();
						StatisticsAD('show', 4);
						if AccountManager.ad_show then
							AccountManager:ad_show(4);
						end
					else
						getglobal("NpcTradeFrameTradeShowADExchange"):Hide();
						getglobal("NpcTradeFrameTradeShowSmallExchange"):Hide();
						getglobal("NpcTradeFrameTradeShowExchange"):Show();					
					end
				end
			end
		end
	end

	local grid_index = NPCTRADE_START_INDEX + 2*CurChooseIndex - 1;
	
	local name = getglobal("NpcTradeFrameTradeShowExchangeText");
	local exchangeNormal =  getglobal("NpcTradeFrameTradeShowExchangeNormal");

	if getglobal("NpcTradeFrameTradeShowSmallExchange"):IsShown() then	--广告
		name = getglobal("NpcTradeFrameTradeShowSmallExchangeText")
		exchangeNormal =  getglobal("NpcTradeFrameTradeShowSmallExchangeNormal");
	end
	if type == 0 then
		name:SetText(GetS(538));	
	elseif type == 1 then
		name:SetText(GetS(3059));
		exchangeNormal:SetGray(false);
	elseif type == 2 then
		name:SetText(GetS(539));
	end
end

function TradeShowPayItem_MouseDownUpdate()
	if arg1 < 0.6 then return end

	local payout_index = NPCTRADE_START_INDEX + 2*(CurChooseIndex-1);
	local payItemId = ClientBackpack:getGridItem(payout_index);

	if payout_index > 0 and payItemId ~= 14001 then	--星星不显示tips
		SetMTipsInfo(-1, this:GetName(), true, payItemId);
	end
end

function TradeShowPayItem_OnMouseUp()
	if arg1 < 0.6 then return end

	local MItemTipsFrame = getglobal("MItemTipsFrame");
	if MItemTipsFrame:IsShown() and IsLongPressTips then
		MItemTipsFrame:Hide();
	end
end

function TradeShowGetItem_MouseDownUpdate()
	if arg1 < 0.6 then return end

	local obtain_index = NPCTRADE_START_INDEX + 2*CurChooseIndex - 1;
	local obtainItemId = ClientBackpack:getGridItem(obtain_index);

	if obtain_index > 0 and obtainItemId ~= 14001 then	--星星不显示tips
		SetMTipsInfo(-1, this:GetName(), true, obtainItemId);
	end
end

function TradeShowGetItem_OnMouseUp()
	local MItemTipsFrame = getglobal("MItemTipsFrame");
	if MItemTipsFrame:IsShown() and IsLongPressTips then
		MItemTipsFrame:Hide();
	end
end

--交换
function NpcTradeFrame_Exchange()
	if not NpcTradeIsGodModeShortcutHasSpace() then
		--是创造模式, 且快捷栏没有空位, 则不要交易
		if CurWorld:isCreativeMode() then
			ShowGameTips(GetS(8045), 3);
		elseif CurWorld:isGameMakerMode() then
			ShowGameTips(GetS(6995), 3);
		end
		return;
	end

	local grid_index = NPCTRADE_START_INDEX + 2*CurChooseIndex - 1;
	local payItemId = ClientBackpack:getGridItem(grid_index-1);
	local obtainItemId = ClientBackpack:getGridItem(grid_index);	
	if obtainItemId > 0 and payItemId > 0 then
		local hightNum = ClientBackpack:getGridUserdata(grid_index-1)*256;
		local needNum = ClientBackpack:getGridNum(grid_index-1) + hightNum;
		local hasNum = GetItemNum2Id(payItemId);
		--local type = ClientBackpack:getGridUserdata(grid_index);
		local tradeDef = DefMgr:getNpcTradeDef( ClientBackpack:getGridUserdata(grid_index) );
		if tradeDef == nil then return end

		local type = tradeDef.TradeType;
		local dur = ClientBackpack:getGridDuration(grid_index);
		if dur == 0 then	--锁定
			if type == 0 then
				ShowGameTips(GetS(540), 3);
			else
				ShowGameTips(GetS(541), 3);
			end
		else
			local npcId = OpenedContainerMob:getDef().ID;
			if OpenedContainerMob and CurWorld and type == 1 then				
				if npcId == 3229 then						
					FisherManNpcTradeUseReport(2, 0, "", 0)
				elseif npcId == 3223 then
					NpcTradeUseReport(2, 0, "", 0,"ISLAND_BUSINESSMAN")
				elseif npcId == 3222 then
					NpcTradeUseReport(2, 0, "", 0,"PIRATE_BUSINESSMAN")
				end
			end
			
			if hasNum >= needNum then
				CurMainPlayer:npcTrade(1, grid_index-1);
				UpdateRefreshCost();
				local text = "";
				if type == 0 then
					local def = ItemDefCsv:get(payItemId);	
					text = GetS(3594, def.Name, needNum);
				else	
					local def = ItemDefCsv:get(obtainItemId);
					local num = ClientBackpack:getGridNum(grid_index);
					if type == 1 then	--[Desc5]
						text = GetS(3595, def.Name, num);
					elseif type == 2 then
						text = GetS(3596, def.Name, num);
					end	
				end
				if OpenedContainerMob and CurWorld then
					local npcId = OpenedContainerMob:getDef().ID;
					--userTaskReportedGlobal(-1, UserTaskReportType_DEAL, npcId, obtainItemId);
					if CurWorld:isRemoteMode() then
						if npcId == 3210 or npcId == 3211 then
							local content = {};
							content.special = false;
							content.objId = OpenedContainerMob:getObjId();
							content.itemId = payItemId;
							SandboxLuaMsg.sendToHost(SANDBOX_LUAMSG_NAME.Survive.DESERT_BUSSINESSMAN_DEAL, content)
						end
					else
						if npcId == 3210 or npcId == 3211 then
							local mob = tolua.cast(OpenedContainerMob, "ActorDesertBusInessMan");
							if not mob then
								return;
							end
							mob:setShouldPlayDealAnim(payItemId);
						end
					end	
					
					if type == 1 then
						if npcId == 3229 then								
							FisherManNpcTradeUseReport(3, obtainItemId, "item", num)
						elseif npcId == 3223 then
							NpcTradeUseReport(3, obtainItemId, "item", num,"ISLAND_BUSINESSMAN")
						elseif npcId == 3222 then
							NpcTradeUseReport(3, obtainItemId, "item", num,"PIRATE_BUSINESSMAN")
						end
					end					
				end
				ShowGameTips(text, 1);
				local effect = getglobal("NpcTradeFrameTradeShowExchangeEffect");
				effect:SetUVAnimation(100, false);

				StatisticsNpcTrade(obtainItemId, payItemId, needNum);				
			else
				if type == 1 then	--[Desc5]
					local lackNum = math.ceil((needNum-hasNum)/MiniCoin_Star_Ratio)
					local text = GetS(466, needNum-hasNum, lackNum);
					StoreMsgBox(5, text, GetS(469), -2, lackNum, needNum);
					getglobal("StoreMsgboxFrame"):SetClientString( "购买货物星星不足" );
					
					local npcId = OpenedContainerMob:getDef().ID;
					if npcId == 3010	then
						local def = ItemDefCsv:get(obtainItemId);
						local str = obtainItemId;
						SetOpenStoreMsgBoxSrc(5000,str);
					end					
				else
					ShowGameTips(GetS(544), 3);
				end
			end
		end
	end
end

--[Desc5]货物时星星不足迷你币代替
function NpcTradeMiniCoinBuy()
	local grid_index = NPCTRADE_START_INDEX + 2*CurChooseIndex - 1;
	local payItemId = ClientBackpack:getGridItem(grid_index-1);
	local obtainItemId = ClientBackpack:getGridItem(grid_index)
	if obtainItemId > 0 and payItemId > 0 then
		local hightNum = ClientBackpack:getGridUserdata(grid_index-1)*256;
		local needNum = ClientBackpack:getGridNum(grid_index-1) + hightNum;
		local hasNum = GetItemNum2Id(payItemId);
		local def = ItemDefCsv:get(obtainItemId);
		local num = ClientBackpack:getGridNum(grid_index);
		if hasNum >= needNum then
			CurMainPlayer:npcTrade(1, grid_index-1);
			UpdateRefreshCost();						
			local text = GetS(545)..def.Name.."×"..num;					
			ShowGameTips(text, 1);
			local effect = getglobal("NpcTradeFrameTradeShowExchangeEffect");
			effect:SetUVAnimation(100, false);
			StatisticsNpcTrade(obtainItemId, payItemId, needNum);
			if OpenedContainerMob and CurWorld then
				local npcId = OpenedContainerMob:getDef().ID;
				--userTaskReportedGlobal(-1, UserTaskReportType_DEAL, npcId, obtainItemId);
				if CurWorld:isRemoteMode() then
					if npcId == 3210 or npcId == 3211 then
						local content = {};
						content.special = false;
						content.objId = OpenedContainerMob:getObjId();
						content.itemId = payItemId;
						SandboxLuaMsg.sendToHost(SANDBOX_LUAMSG_NAME.Survive.DESERT_BUSSINESSMAN_DEAL, content)
					end
				else
					if npcId == 3210 or npcId == 3211 then
						local mob = tolua.cast(OpenedContainerMob, "ActorDesertBusInessMan");
						if not mob then
							return;
						end
						mob:setShouldPlayDealAnim(payItemId);
					end
				end

				if npcId == 3229 then				
					FisherManNpcTradeUseReport(3, obtainItemId, "item", num)
				elseif npcId == 3223 then
					NpcTradeUseReport(3, obtainItemId, "item", num,"ISLAND_BUSINESSMAN")
				elseif npcId == 3222 then
					NpcTradeUseReport(3, obtainItemId, "item", num,"PIRATE_BUSINESSMAN")
				end
			end
		else
			local lackNum = needNum - hasNum;
			local needMini = math.ceil((lackNum)/MiniCoin_Star_Ratio);
			local hasMini = AccountManager:getAccountData():getMiniCoin();
			if needMini <= hasMini then 
				if AccountManager:getAccountData():notifyServerConsumeMiniCoin(needMini) ~= 0 then
					--ShowGameTips(StringDefCsv:get(282), 3);
					return;
				end

				ClientCurGame:getMainPlayer():starConvert(needMini*MiniCoin_Star_Ratio);
				CurMainPlayer:npcTrade(1, grid_index-1);
				UpdateRefreshCost();
				local text = GetS(545)..def.Name.."×"..num;					
				ShowGameTips(text, 1);
				local effect = getglobal("NpcTradeFrameTradeShowExchangeEffect");
				effect:SetUVAnimation(100, false);
				StatisticsNpcTrade(obtainItemId, payItemId, needNum);
				if OpenedContainerMob and CurWorld then
					local npcId = OpenedContainerMob:getDef().ID;
					--userTaskReportedGlobal(-1, UserTaskReportType_DEAL, npcId, obtainItemId); 
					if CurWorld:isRemoteMode() then
						if npcId == 3210 or npcId == 3211 then
							local content = {};
							content.special = false;
							content.objId = OpenedContainerMob:getObjId();
							content.itemId = payItemId;
							SandboxLuaMsg.sendToHost(SANDBOX_LUAMSG_NAME.Survive.DESERT_BUSSINESSMAN_DEAL, content)
						end
					else
						if npcId == 3210 or npcId == 3211 then
							local mob = tolua.cast(OpenedContainerMob, "ActorDesertBusInessMan");
							if not mob then
								return;
							end
							mob:setShouldPlayDealAnim(payItemId);
						end
					end
					if npcId == 3229 then											
						FisherManNpcTradeUseReport(3, obtainItemId, "item", num)
					elseif npcId == 3223 then
						NpcTradeUseReport(3, obtainItemId, "item", num,"ISLAND_BUSINESSMAN")
					elseif npcId == 3222 then
						NpcTradeUseReport(3, obtainItemId, "item", num,"PIRATE_BUSINESSMAN")
					end
				end
			else
				local lackMiniNum = needMini - hasMini;
				local cost, buyNum = GetPayRealCost(lackMiniNum);
				local text = GetS(453, cost, buyNum);
				StoreMsgBox(6, text, GetS(456), -1, lackNum, needMini, nil, NotEnoughMiniCoinCharge, cost);
			end
		end
	end
end

--npc交易时, godmode下检查快捷栏是否有空位
function NpcTradeIsGodModeShortcutHasSpace()
	if CurWorld and CurWorld:isGodMode() then
		if ClientBackpack then
			local emptyNum = ClientBackpack:getShorCutEmptyGridNum();
			if emptyNum > 0 then
				return true;
			end
		end

		return false;
	end

	return true;
end

function NpcTradeFrame_ADExchange()
	local grid_index = NPCTRADE_START_INDEX + 2*CurChooseIndex - 1;
	local payItemId = ClientBackpack:getGridItem(grid_index-1);
	local obtainItemId = ClientBackpack:getGridItem(grid_index);
	
	if obtainItemId > 0 and payItemId > 0 then
		local hightNum = ClientBackpack:getGridUserdata(grid_index-1)*256;
		local gridNum = ClientBackpack:getGridNum(grid_index-1);
		local totalPay = gridNum + hightNum;
		local totalNum = ClientBackpack:getGridNum(grid_index);

		local tradeDef = DefMgr:getNpcTradeDef( ClientBackpack:getGridUserdata(grid_index) );
		if tradeDef == nil then return end

		local type = tradeDef.TradeType;
		local dur = ClientBackpack:getGridDuration(grid_index);
		if dur == 0 then	--锁定
			if type == 0 then
				ShowGameTips(GetS(540), 3);
			else
				ShowGameTips(GetS(541), 3);
			end
		elseif type == 1 then	--用星星[Desc5]的, 才能用广告奖励
			local position_id = 4
			if IsAdUseNewLogic(position_id) then	
				GetInst("AdService"):GetAdInfo(position_id, function (ad_info)
					local rewardValue = 5;	--默认奖励5个星星
					if ad_info.extra and ad_info.extra.type == 1 then
						rewardValue = ad_info.extra.value or 0
					end
	
					print("kekeke ADExchange", rewardValue, totalPay, totalNum);
					local getNum = math.floor(rewardValue/(totalPay/totalNum));
					print("kekeke ADExchange", totalPay, totalNum, getNum);
					if getNum > totalNum then
						getNum = totalNum;
					end
	
					local callback_data = {index = grid_index, num = getNum};
					StatisticsADNew('onclick', position_id, ad_info);
					if WatchADNetworkTips(OnReqWatchADExchangeNpcTrade, callback_data) then
						OnReqWatchADExchangeNpcTrade(callback_data);
					end
				end)
			else
				local ad_info = AccountManager:ad_position_info(4);
				local rewardValue = 5;	--默认奖励5个星星
				if ad_info.extra and ad_info.extra.type == 1 then
					rewardValue = ad_info.extra.value
				end
	
				print("kekeke ADExchange", rewardValue, totalPay, totalNum);
				local getNum = math.floor(rewardValue/(totalPay/totalNum));
				print("kekeke ADExchange", totalPay, totalNum, getNum);
				if getNum > totalNum then
					getNum = totalNum;
				end
	
				local callback_data = {index = grid_index, num = getNum};
				StatisticsAD('onclick', 4);
				if WatchADNetworkTips(OnReqWatchADExchangeNpcTrade, callback_data) then
					OnReqWatchADExchangeNpcTrade(callback_data);
				end
			end
		end
	end
end

function StatisticsNpcTrade(obtainItemId, payItemId, payNum)
	local def = ItemDefCsv:get(obtainItemId);
	local payDef = ItemDefCsv:get(payItemId);
	if def == nil and payDef ~= nil then return end

	local npcId = OpenedContainerMob:getDef().ID;
	local eventName = nil;
	if npcId == 3013 then		--圣诞
		eventName = "圣诞商人-"..def.Name;
	elseif npcId == 3014 then	--元旦
		eventName = "元旦商人-"..def.Name;
	elseif npcId == 3015 then	--春节
		eventName = "春节商人-"..def.Name;
	elseif npcId == 3016 then	--周年商人
		eventName = "周年商人-"..def.Name;
	elseif npcId == 3017 then	--61商人
		eventName = "六一商人-"..def.Name;
	elseif npcId == 3018 then	--外星商人
		eventName = "外星商人-"..def.Name;
	else
		return;
	end

	StatisticsTools:gameEvent(eventName, payDef.Name, payNum);
end

function GetNum2Rack()
	local num = 0;
	for i=1, MAX_TRADER_ITEMS do
		local grid_index = NPCTRADE_START_INDEX + 2*i - 1;--获得的物品
		local itemId = ClientBackpack:getGridItem(grid_index);
		if itemId > 0 then
			num = num + 1;
		end
	end

	return num;
end

function UpdateLeftRightBtnState()
	local num = GetNum2Rack();

	local leftBtn 		= getglobal("NpcTradeFrameRackLeftBtn");
	local rightBtn 		= getglobal("NpcTradeFrameRackRightBtn");
	if CurShowStarIndex == 1 then
		leftBtn:Hide();
		if num > 3 then
			if not rightBtn:IsShown() then
				rightBtn:Show();
			end
		else
			rightBtn:Hide();
		end
	elseif CurShowStarIndex > 1 then
		if not leftBtn:IsShown() then
			leftBtn:Show();
		end
		if CurShowStarIndex+2 == num then
			rightBtn:Hide();
		elseif not rightBtn:IsShown() then
			rightBtn:Show();
		end
	end
end

--刷新
function NpcTradeFrameRefreshBtn_OnClick()
	local lockNum = GetCurRackLockNum();
	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	local needNum = 5-lockNum;
	if needNum < 1 then
		needNum = 1;
	end
	if starNum >= needNum then
		CurMainPlayer:npcTrade(0, needNum);
		ShowGameTips(GetS(546), 3);
	else
		local lackNum = needNum - starNum;
		local lackMiniNum = math.ceil(lackNum/MiniCoin_Star_Ratio);
		local text = GetS(466, lackNum, lackMiniNum);
		StoreMsgBox(5, text, GetS(469), -2, lackMiniNum, needNum);
		getglobal("StoreMsgboxFrame"):SetClientString( "刷新货物星星不足" );
		SetOpenStoreMsgBoxSrc(5002,"RefreshGoods");
	end
end

--刷新时星星不足迷你币代替
function NpcTradeMiniCoinRefresh()
	local lockNum = GetCurRackLockNum();
	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	local needNum = 5-lockNum;
	if starNum < needNum then
		local needMini = math.ceil((needNum-starNum)/MiniCoin_Star_Ratio);
		local hasMini = AccountManager:getAccountData():getMiniCoin();
		if needMini <= hasMini then
			if AccountManager:getAccountData():notifyServerConsumeMiniCoin(needMini) ~= 0 then
				--ShowGameTips(StringDefCsv:get(282), 3);
				return;
			end
			ClientCurGame:getMainPlayer():starConvert(needMini*MiniCoin_Star_Ratio);
			CurMainPlayer:npcTrade(0, needNum);
			ShowGameTips(GetS(546), 3);
		else
			local lackNum = needNum - starNum;
			local cost, buyNum = GetPayRealCost(needMini-hasMini);
			local text = GetS(453, cost, buyNum);
			StoreMsgBox(6, text, GetS(456), -1, lackNum, needMini, nil, NotEnoughMiniCoinCharge, cost);
		end
	else
		CurMainPlayer:npcTrade(0, needNum);
		ShowGameTips(GetS(546), 3);
	end
end

function NpcTradeFrameADRefreshBtn_OnClick()
	if IsAdUseNewLogic(3) then
		StatisticsADNew('onclick', 3);	
	else
		StatisticsAD('onclick', 3);	
	end
	
	if WatchADNetworkTips(OnReqWatchADRefreshNpcTrade) then
		OnReqWatchADRefreshNpcTrade();
	end
end

function NpcTradeFrameRackLeft_OnClick()
	CurShowStarIndex = CurShowStarIndex - 1;
	CurChooseIndex = CurChooseIndex - 1;
	UpdateLeftRightBtnState();
	UpdateNpcTradeFrameInfo();
end

function NpcTradeFrameRackRight_OnClick()
	CurShowStarIndex = CurShowStarIndex + 1;
	CurChooseIndex = CurChooseIndex + 1;
	UpdateLeftRightBtnState();
	UpdateNpcTradeFrameInfo();
end

function NpcTradeFrameCloseBtn_OnClick()
	getglobal("NpcTradeFrame"):Hide();	
end

--传奇钓手埋点上报
function FisherManNpcTradeUseReport(type, extra_id, extra_type, count)
	local param = {}
	local ret, standby1, standby2, standby3 = userTaskReportGetWorldParam2(nil, param)
	local tb = {}
	tb.standby1 = standby1
	tb.standby2 = standby2
	tb.standby3 = standby3
	tb.game_session_id = get_game_session_id()
	tb.cid = param.tureWorldId
	tb.ctype = param.ctype

	if type == 1 then
		standReportEvent("1003", "LEGEND_FISHERMAN", "-", "view", tb)
	elseif type == 2 then
		standReportEvent("1003", "LEGEND_FISHERMAN", "Buy", "click", tb)
	elseif type == 3 then
		tb.extra_id = extra_id
		tb.extra_type = extra_type
		tb.standby4 = count
		standReportEvent("1003", "LEGEND_FISHERMAN", "Buy", "success", tb)
	end	
end

--商人通用埋点上报
function NpcTradeUseReport(type, extra_id, extra_type, count,CID)
	local param = {}
	local ret, standby1, standby2, standby3 = userTaskReportGetWorldParam2(nil, param)
	local tb = {}
	tb.standby1 = standby1
	tb.standby2 = standby2
	tb.standby3 = standby3
	tb.game_session_id = get_game_session_id()
	tb.cid = param.tureWorldId
	tb.ctype = param.ctype

	if type == 1 then
		standReportEvent("1003", CID, "-", "view", tb)
	elseif type == 2 then
		standReportEvent("1003", CID, "Buy", "click", tb)
	elseif type == 3 then
		tb.extra_id = extra_id
		tb.extra_type = extra_type
		tb.standby4 = count
		standReportEvent("1003", CID, "Buy", "success", tb)
	end	
end