
local getglobal = _G.getglobal;
function StarConvertFrameCloseBtn_OnClick()
	getglobal("StarConvertFrame"):Hide();
	-- UGC内容重新显示
	GetInst("UGCCommon"):AfterHideAllUI();
end

function StarConvertFrameConvertBtn_OnClick()
	local minicoinNum = AccountManager:getAccountData():getMiniCoin();
	local starNum = 10;
	local needMini = starNum/MiniCoin_Star_Ratio;
	if minicoinNum >= needMini then
		if AccountManager:getAccountData():notifyServerConsumeMiniCoin(needMini) ~= 0 then
			--ShowGameTips(StringDefCsv:get(282), 3);
			return;
		end
		--统计消耗迷你币
		local name = "兑换星星".."×"..starNum;
		StatisticsTools:expenseMiniCoin(name, 1, needMini);

		ClientCurGame:getMainPlayer():starConvert(starNum);
		ShowGameTips(GetS(452).."×"..starNum, 4);
		StatisticsTools:gameEvent("ConvertStarNum");
	else
		local lackNum = needMini - minicoinNum;
		local cost, buyNum = GetPayRealCost(lackNum);
		local text = GetS(453, cost, buyNum);
		StoreMsgBox(6, text, GetS(456), -1, lackNum, needMini, nil, NotEnoughMiniCoinCharge, cost);
		SetOpenStoreMsgBoxSrc(5001,"StarConvert");
	end
end

function StarConvertFrame_OnLoad()
	this:RegisterEvent("GIE_MINICOIN_CHANGE");
	getglobal("StarConvertFrameTitleName"):SetText(GetS(3161));
end

function StarConvertFrame_OnEvent()
	if arg1 == "GIE_MINICOIN_CHANGE" then
		if getglobal("StarConvertFrame"):IsShown() then
			local num = AccountManager:getAccountData():getMiniCoin();
			getglobal("StarConvertFrameHasMiniNum"):SetText(num);
		end
	end
end

function StarConvertFrame_OnShow()
	HideAllFrame("StarConvertFrame", false);
	getglobal("StarConvertFrameHasMiniNum"):SetText(AccountManager:getAccountData():getMiniCoin());
	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	
--	getglobal("PlayerExpBarStarBkg"):SetSize(170, 72);
	getglobal("PlayerExpBarStarText"):SetText(starNum);

	if not getglobal("StarConvertFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end
end

function StarConvertFrame_OnHide()
--	getglobal("PlayerExpBarStarBkg"):SetSize(106, 45);

	local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
	getglobal("PlayerExpBarStarText"):SetText(starNum);
	if starNum >= 1000 then
		getglobal("PlayerExpBarStarText"):SetText("999+");
	end

	if not getglobal("StarConvertFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
end

---------------------------------------------------BeanConvertFrame-----------------------------------------------------------
function BeanConvertFrameCloseBtn_OnClick()
	standReportEvent("9", "MINI_BEAN_RECHARGE_TOP", "close", "click")
	getglobal("BeanConvertFrame"):Hide();
end

function BeanConvertFrameHappyFirework_OnClick()

end

function BeanConvertFrameConvertBtn_OnClick()
	local minicoinNum = AccountManager:getAccountData():getMiniCoin();
	local beanNum = 300;
	local needMini = beanNum/MiniCoin_Bean_Ratio;
	if minicoinNum >= needMini then
		if AccountManager:getAccountData():notifyServerConvertMiniBean(needMini) == 0 then
			--统计消耗迷你币
			local name = "兑换迷你豆".."×"..beanNum;
			StatisticsTools:expenseMiniCoin(name, 1, needMini);

			ShowGameTips(GetS(458).."×"..beanNum, 3);
		end
	else
		local lackNum = needMini - minicoinNum;
		local cost, buyNum = GetPayRealCost(lackNum);
		local text = GetS(3597, lackNum);

		local frameType = nil
		local extParam = nil 

        -- 从家园商城跳转过来的
		if IsUIFrameShown("HomelandShop") and GetInst("UIManager"):GetCtrl("HomelandShop") then
			frameType = 7 --家园商店
			extParam = GetInst("UIManager"):GetCtrl("HomelandShop").model:GetCurTabType()
            
		elseif IsUIFrameShown("HomelandBackpack") and GetInst("UIManager"):GetCtrl("HomelandBackpack") then
			frameType = 8 --家园背包
			extParam = GetHomeLandMode()
		end

		if frameType then
			--迷你币不足
			local callBack = function(btnName, extendparam)
                if btnName == "right" then
                    getglobal("BeanConvertFrame"):Hide()
					--跳转到[Desc2]界面
					ShopJumpTabView(7, frameType, nil, extendparam);
				end
			end
    
			StoreMsgBox(1, text, GetS(456), -1, lackNum, needMini, nil, callBack, extParam)
        else
            StoreMsgBox(1, text, GetS(456), -1, lackNum, needMini)
            getglobal("StoreMsgboxFrame"):SetClientString( "迷你币不足" )
        end

        		
		if	RechargeSrc ~= nil and RechargeStr ~= nil	then
			SetOpenStoreMsgBoxSrc(RechargeSrc,RechargeStr);
			RechargeSrc = nil;
			RechargeStr = nil;
		end
		getglobal("StoreMsgboxFrame"):SetClientUserData(0, cost);
	end
end

function BeanConvertFrameConvertTenBtn_OnClick()
	local minicoinNum = AccountManager:getAccountData():getMiniCoin();
	local beanNum = 3000;
	local needMini = beanNum/MiniCoin_Bean_Ratio;
	if minicoinNum >= needMini then
		if AccountManager:getAccountData():notifyServerConvertMiniBean(needMini) == 0 then
			--统计消耗迷你币
			local name = "兑换迷你豆".."×"..beanNum;
			StatisticsTools:expenseMiniCoin(name, 1, needMini);

			ShowGameTips(GetS(458).."×"..beanNum, 3);	
		end
	else
		local lackNum = needMini - minicoinNum;
		local cost, buyNum = GetPayRealCost(lackNum);
		local text = GetS(3597, lackNum);

		local frameType = nil
		local extParam = nil 

        -- 从家园商城跳转过来的
		if IsUIFrameShown("HomelandShop") and GetInst("UIManager"):GetCtrl("HomelandShop") then
			frameType = 7 --家园商店
			extParam = GetInst("UIManager"):GetCtrl("HomelandShop").model:GetCurTabType()
            
		elseif IsUIFrameShown("HomelandBackpack") and GetInst("UIManager"):GetCtrl("HomelandBackpack") then
			frameType = 8 --家园背包
			extParam = GetHomeLandMode()
		end

		if frameType then
			--迷你币不足
			local callBack = function(btnName, extendparam)
                if btnName == "right" then
                    getglobal("BeanConvertFrame"):Hide()
					--跳转到[Desc2]界面
					ShopJumpTabView(7, frameType, nil, extendparam);
				end
			end
    
			StoreMsgBox(1, text, GetS(456), -1, lackNum, needMini, nil, callBack, extParam)
        else
            StoreMsgBox(1, text, GetS(456), -1, lackNum, needMini);
            getglobal("StoreMsgboxFrame"):SetClientString( "迷你币不足" );
        end
        		
		if	RechargeSrc ~= nil and RechargeStr ~=nil	then
			SetOpenStoreMsgBoxSrc(RechargeSrc,RechargeStr);
			RechargeSrc = nil;
			RechargeStr = nil;
		end
		getglobal("StoreMsgboxFrame"):SetClientUserData(0, cost);
	end	
end

local t_BeanConvertShowFrame = {
	{panel = "OpenFruitFrame", fgui = false, clearRes = false,},
	{panel = "PurchaseItem", fgui = false, clearRes = false,},
	{panel = "PlayerExhibitionCenter", fgui = false, clearRes = false,},
	{panel = "ShopSkinDisplay", fgui = false, clearRes = false,},
	{panel = "Specialty_main", fgui = true, clearRes = true,},
	{panel = "SkinCollect_Topic", fgui = true, clearRes = true,},
	{panel = "SkinCollect_Main", fgui = true, clearRes = true,},
}

--从兑换迷你豆界面跳转
function JumpByConvert()
	getglobal("BeanConvertFrame"):Hide()

	for k, v in pairs(t_BeanConvertShowFrame) do
		if v.fgui then
			GetInst("MiniUIManager"):CloseUI(v.panel .. "AutoGen", v.clearRes)
		else
			local frame = getglobal(v.panel)
			if frame:IsShown() then
				frame:Hide()
			end
		end
	end
end

function BeanConvertFrameHomeChestBtn_OnClick()
	JumpByConvert();
	if not getglobal("HomeChestFrame"):IsShown() then
		HomeChestMgr:requestChestTreeReq(AccountManager:getUin());	--打开家园
		-- getglobal("HomeChestFrame"):Show();
	end
end

function BeanConvertFramePokedexBtn_OnClick()
	JumpByConvert();
	if not getglobal("HomeChestFrame"):IsShown() then
		HomeChestMgr:requestChestTreeReq(AccountManager:getUin());	--打开家园
		-- getglobal("HomeChestFrame"):Show();
	end
	HomeChestFramePokedexBtn_OnClick();
end

function BeanConvertFrame_OnLoad()
	this:RegisterEvent("GIE_MINICOIN_CHANGE");

	local tick = getglobal("AutoUseCoinSwitchTick");
	-- if ClientMgr:getGameData("autousecoin") == 1 then
	if getkv("autousecoin") == 1 then
		tick:Show();
	else
		tick:Hide();
	end

	getglobal("BeanConvertFrameHappyFireworkMiniIcon"):SetTexture("items/icon12750.png");
	getglobal("BeanConvertFrameHappyFireworkName"):SetText(GetS(1215));
	getglobal("BeanConvertFrameHappyFireworkTips"):SetText(GetS(1216, "#c46D00A"));
	getglobal("BeanConvertFrameHappyFireworkDesc1"):SetText(GetS(1217), 255, 253, 233);
	getglobal("BeanConvertFrameHappyFireworkName"):SetPoint("topleft","BeanConvertFrameHappyFirework","top",-195,20)
	getglobal("BeanConvertFrameHappyFireworkIcon"):Hide();
	getglobal("BeanConvertFrameHappyFireworkTag"):Hide();
	getglobal("BeanConvertFrameHappyFireworkTagName"):Hide();
	getglobal("BeanConvertFrameHappyFireworkCurrencyIcon"):Hide();
	getglobal("BeanConvertFrameHappyFireworkCost"):Hide();
end

function BeanConvertFrame_OnEvent()
	if arg1 == "GIE_MINICOIN_CHANGE" then
		if getglobal("BeanConvertFrame"):IsShown() then
			local num = AccountManager:getAccountData():getMiniCoin();
			getglobal("BeanConvertFrameHasMiniNum"):SetText("×"..num);
		end
	end
end

--result 0迷你豆不足 1迷你豆足 2兑换迷你豆出错
function CheckMiniBean(needNum)
	local hasNum = AccountManager:getAccountData():getMiniBean();
	if hasNum >= needNum then
		return 1;
	end

	-- if ClientMgr:getGameData("autousecoin") == 1 then
	if getkv("autousecoin") == 1 then
		return AutoConverBean(needNum);
	else
		return 0;
	end
end

function CheckMiniCoin(needNum)
	local hasNum = AccountManager:getAccountData():getMiniCoin();
	if hasNum >= needNum then
		return 1;
	else
		return 0;
	end
end

function AutoConverBean(beanNum)
	local minicoinNum = AccountManager:getAccountData():getMiniCoin();
	beanNum = math.ceil(beanNum/300)*300;

	local needMini = beanNum/MiniCoin_Bean_Ratio;
	if minicoinNum >= needMini then
		if AccountManager:getAccountData():notifyServerConvertMiniBean(needMini) ~= 0 then
			--ShowGameTips(StringDefCsv:get(282), 3);
			return 2;
		end
		--统计消耗迷你币
		local name = "兑换迷你豆".."×"..beanNum;
		StatisticsTools:expenseMiniCoin(name, 1, needMini);
		return 1;	
	else
		local lackNum = needMini - minicoinNum;
		local cost, buyNum = GetPayRealCost(lackNum);
		local text = GetS(453, cost, buyNum);
		StoreMsgBox(6, text, GetS(456), -3, lackNum, needMini, nil, NotEnoughMiniCoinCharge, cost);

		return 2;
	end
end

function BeanConvertFrame_OnShow()
	standReportEvent("9", "MINI_BEAN_RECHARGE_TOP", "-", "view")
	standReportEvent("9", "MINI_BEAN_RECHARGE_TOP", "close", "view")
	local getglobal = getglobal;
	getglobal("BeanConvertFrameHasMiniNum"):SetText("×"..AccountManager:getAccountData():getMiniCoin());
	if ClientCurGame:isInGame() then
		getglobal("BeanConvertFrameTips"):Hide();
		getglobal("BeanConvertFrameHomeChestBtn"):Hide();
		getglobal("BeanConvertFramePokedexBtn"):Hide();
	else
		getglobal("BeanConvertFrameTips"):Show();
		getglobal("BeanConvertFrameHomeChestBtn"):Show();
		getglobal("BeanConvertFramePokedexBtn"):Show();	
	end
end

function BeanConvertFrame_OnHide()
	if HasUIFrame("ArchiveRewardFrame") and getglobal("ArchiveRewardFrame"):IsShown() then
		getglobal("ArchiveRewardFrame"):Hide();
		GetInst("UIManager"):GetCtrl("MapReward"):RewardSelectFrameConfirmBtnClicked();
	end
end