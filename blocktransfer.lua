local CurrentTransferDef;
local CurrentRuleDef;
local Max_TransferDefs = 50;
local Max_Destinations = Max_TransferDefs - 1;
local visualState = 1	--是否显示未激活传送目标点
local edit_dirty = 0
local t_transfer = {};	--所有传送点核心方块
local t_condition = {};		--所有已设置路线
local t_visualCondition = {};		--当前核心的所有可见传送目标点
local t_name = {
		'TeamColor',
		'PassItemID',
		'PassItemNum',
		'ForbidItemID',
		'IsExpendable',
	}
--传送规则设置
TransferRuleSetDef={
	ID = 0,
	Name = "",
	Attr = {
		TeamColor = {
			--队伍权限
			Name = 'TeamColor', JsonName = 'teamcolor', CurVal = 0,
			IsShown = false,
			GetInitVal = function(def) return def.TeamColor end,
			Save = function(def, t_attr,t_json)
				--def["TeamColor"] = t_attr.CurVal;
				t_json["teamcolor"] = t_attr.CurVal;
			end,
		},

		PassItemID = {
			Name = 'PassItemID', JsonName = 'passitemid', CurVal = 0,
			IsShown = false,
			GetInitVal = function(def) return def.PassItemID end,
			Save = function(def, t_attr,t_json)
				--def["PassItemID"] = t_attr.CurVal;
				t_json["passitemid"] = t_attr.CurVal;
			end,
		},

		PassItemNum = {
			Name = 'PassItemNum', JsonName = 'passitemnum', CurVal = 0,
			IsShown = false,
			GetInitVal = function(def) return def.PassItemNum end,
			Save = function(def, t_attr,t_json)
				--def["PassItemNum"] = t_attr.CurVal;
				t_json["passitemnum"] = t_attr.CurVal;
			end,
		},

		ForbidItemID = {
			Name = 'ForbidItemID', JsonName = 'forbiditemid', CurVal = 0,
			IsShown = false,
			GetInitVal = function(def) return def.ForbidItemID end,
			Save = function(def, t_attr,t_json)
				--def["ForbidItemID"] = t_attr.CurVal;
				t_json["forbiditemid"] = t_attr.CurVal;
			end,
		},

		IsExpendable = {
			Name = 'IsExpendable', JsonName = 'isexpendable', CurVal = false,
			IsShown = false,
			GetInitVal = function(def) return def.IsExpendable end,
			Save = function(def, t_attr,t_json)
				--def["IsExpendable"] = t_attr.CurVal;
				t_json["isexpendable"] = t_attr.CurVal;
			end,
		},
	},

	Init = function(def)
		local t_attr = TransferRuleSetDef.Attr;
		for i=1,#(t_name) do
			local name = t_name[i]
			if t_attr[name].GetInitVal(def) then
				t_attr[name].CurVal = t_attr[name].GetInitVal(def)
			end
		end
	end,

}


-------------------------------------------------1.总界面--------------------------------------------------------------
function setTransferBoxState(state)
	local t_box = {
					"TransferFrameMainDetailBox",
					"TransferFrameMainBriefBox",
					"TransferFrameTabsBox"
				}
	for i=1,#(t_box) do
		getglobal(t_box[i]):setDealMsg(state)
	end
end

--C++调用的函数，1. 右键点击，打开总界面； 2.欲传送时，打开传送目标点选择界面
function EditTransferCoreUI(id)
	--local worldDesc = AccountManager:getCurWorldDesc();
	if (not CurWorld) or not (CurWorld:isGameMakerMode()) then
		return;
	end 
	if CurWorld ~= nil and CurWorld:isGameMakerRunMode() then
		return;
	end
	local def = TransferMgr:getTransferDef(id)
	if def then
		Log("CurrentEditTransferCore: "..tostring(id));
		CurrentTransferDef = def;
	else
		Log("Transfer Core not exist: "..tostring(id))
		return;
	end

	UpdateAllTransferDefs()
	--UpdateTransferMain(CurrentTransferDef);

	if #(t_transfer) > 0 then
		UIFrameMgr:frameShow(getglobal("TransferFrame"))
		local idx;
		for i=1,#(t_transfer) do
			if id == t_transfer[i].id then
				idx = i;
				break;
			end
		end
		ChangeTransferBtn(idx,true)

	else
		return;
	end

	
end

function OpenTransferUI_C(id)
	if getglobal("ChooseTransferDestinationFrame"):IsShown() then
		return 
	end
	
	if (not CurWorld) or not (CurWorld:isGameMakerMode() or CurWorld:isGameMakerRunMode()) then
		return;
	end 
	if TransferMgr:getTransferDef(id) then
		Log("CurrentEditTransferCore: "..tostring(id));
		CurrentTransferDef = TransferMgr:getTransferDef(id)
		if CurrentTransferDef.TransferName=="" then
			TransferMgr:updateTransferCoreInfo(CurrentTransferDef.ID,GetS(21523)..tostring(id),CurrentTransferDef.TransferTip,CurrentTransferDef.ShowName)
		end
		if LuaInterface:band(CurrentTransferDef.Status,8) == 0 then
			--local worldDesc = AccountManager:getCurWorldDesc();
			if CurWorld:isGameMakerRunMode() then
				ShowGameTips(GetS(21490,CurrentTransferDef.TransferName))
				return
			end
			
		end
		if CurrentTransferDef:getConditionSize() <= 0 then
			ShowGameTips(GetS(21497))
			return
		end
		--一个传送目标点，直接传
		if CurrentTransferDef:getConditionSize() == 1 then
			local conditionDef = CurrentTransferDef:getConditionStruct(0)
			local targetDef = TransferMgr:getTransferDef(conditionDef.TransferID)
			if LuaInterface:band(targetDef.Status,8) == 0 then
				--local worldDesc = AccountManager:getCurWorldDesc();
				if CurWorld:isGameMakerRunMode() then
					ShowGameTips(GetS(21687,targetDef.TransferName))
					return
				end
				
			end
			local isTransfer = TransferRuleTips(conditionDef)
			if not isTransfer then
				return;
			else
				local success = TransferMgr:transferToTargetPos(CurrentTransferDef.ID, targetDef.ID)
				if not success then
					ShowGameTips(GetS(21494))
				else
					local text = targetDef.TransferTip
					if text == "" then
						text = GetS(21492,targetDef.TransferName)
					end
					ShowGameTips(text)
					if CurMainPlayer:getSpectatorMode() ~= 1 and CurMainPlayer:getSpectatorMode() ~= 2 then
						if conditionDef.PassItemID ~= 0 and conditionDef.PassItemNum > 0 then
							local itemDef = ItemDefCsv:get(conditionDef.PassItemID)
							if itemDef then
								ShowGameTips(GetS(21591, itemDef.Name, "X"..tostring(conditionDef.PassItemNum)))
							end
						end
					end				
				end
				return;
			end

		end

		
		
		getglobal("ChooseTransferDestinationFrameHeadTitle"):SetText(CurrentTransferDef.TransferName)
	else
		Log("Transfer Core not exist: "..tostring(id))
		return;
	end

	

	local plane = "ChooseTransferDestinationFrameBoxPlane"
	local btn = "ChooseTransferDestinationFrameBoxD"
	local num = CurrentTransferDef:getConditionSize()
	--if num <=0 then
	--	getglobal("ChooseTransferDestinationFrameBox"):Hide()
	--	getglobal("ChooseTransferDestinationFrameNoTitle"):Show()
	--	return
	--else
	--	getglobal("ChooseTransferDestinationFrameBox"):Show()
	--	getglobal("ChooseTransferDestinationFrameNoTitle"):Hide()
	--end

	
	
	t_condition = {};
	for i=1,num do
		local conditionDef = CurrentTransferDef:getConditionStruct(i-1)
		
		
		local EndDef = TransferMgr:getTransferDef(conditionDef.TransferID)
		if EndDef then
			table.insert(t_condition,conditionDef)
			if EndDef.TransferName == "" then
				TransferMgr:updateTransferCoreInfo(EndDef.ID,GetS(21523)..tostring(EndDef.ID),EndDef.TransferTip,EndDef.ShowName)
			end
			
			
		end
	end

	t_choosedes={}
	for i=1,#(t_condition) do
		if visualState == 1 then
			table.insert(t_choosedes,t_condition[i])
		else
			local EndDef = TransferMgr:getTransferDef(t_condition[i].TransferID)
			if EndDef and LuaInterface:band(EndDef.Status,8)==8 then
				table.insert(t_choosedes,t_condition[i])
			end
		end
	end
	if #(t_choosedes) == 0 then
		ShowGameTips(GetS(21497))
		return
	end
	--print("sjksksk")
	for i=1,#(t_choosedes) do
		local EndDef = TransferMgr:getTransferDef(t_choosedes[i].TransferID)
		getglobal(btn..i):SetPoint("top",plane,"top",0, (i-1)*(61+10))
		getglobal(btn..i):Show()
		getglobal(btn..i.."Title"):SetText(EndDef.TransferName)
		if LuaInterface:band(EndDef.Status,8) == 0 then
			getglobal(btn..i.."Icon"):SetTexUV("icon_activation_n.png")
		else
			getglobal(btn..i.."Icon"):SetTexUV("icon_activation_h.png")
		end
	end
	local height = #(t_choosedes)*(61+10)-10;
	if height <= 398 then
		height = 398
	end
	getglobal(plane):SetHeight(height)

	for i=#(t_choosedes)+1,Max_Destinations do
		getglobal(btn..i):Hide()
	end

	UIFrameMgr:frameShow(getglobal("ChooseTransferDestinationFrame"))
end

--1.刷新左侧传送点列表; 2.刷新右侧主界面
function UpdateAllTransferDefs()
	local TransferDef;
	t_transfer = {};
	for i=1, Max_TransferDefs do
		TransferDef = TransferMgr:getTransferDef(i-1, true);
		if TransferDef then
			if TransferDef.TransferName == "" then
				--GetS(25123)..tostring(TransferDef.ID)
				TransferMgr:updateTransferCoreInfo(TransferDef.ID,GetS(21523)..tostring(TransferDef.ID),TransferDef.TransferTip,TransferDef.ShowName)
				TransferDef.TransferName = GetS(21523)..tostring(TransferDef.ID)
			end
			table.insert(t_transfer,{def = TransferDef, id = TransferDef.ID, name = TransferDef.TransferName})
		else
			break;
		end
	end

	if #(t_transfer) == 0 then
		--ShowGameTips("当前存档没有传送点!")
		Log("TransferDef array is null")
		getglobal("TransferFrame"):Hide()
		return;
	end
	Log("transfer: ")

	UpdateTransferTabs()

	
end

function UpdateTransferTabs( ... )
	local btn = "TransferFrameTabsBoxBtn"
	local plane = "TransferFrameTabsBoxPlane"
	local height = #(t_transfer)*(11+61)-11
	if height < 444 then
		height = 444
	end
	getglobal(plane):SetHeight(height)
	for i=1, #(t_transfer) do
		local def = t_transfer[i].def;
		getglobal(btn..i):SetPoint("top",plane, "top", 0, (11+61)*(i-1));
		getglobal(btn..i):Show();
		DefMgr:filterStringDirect(t_transfer[i].name);
		getglobal(btn..i.."Name"):SetText(t_transfer[i].name);
		if LuaInterface:band(def.Status,8) == 0 then
			getglobal(btn..i.."Icon"):SetTexUV("icon_activation_n.png")
		else
			getglobal(btn..i.."Icon"):SetTexUV("icon_activation_h.png")
		end
	end

	if #(t_transfer) < Max_TransferDefs then
		for i = #(t_transfer)+1, Max_TransferDefs do
			getglobal(btn..i):Hide()
		end
	end
end

function UpdateTransferMain(def)
	UpdateTransferInfo(def);
	UpdateTransferBox(def)

end

function UpdateTransferInfo(def)
	local info 		= "TransferFrameMainInfo"
	getglobal(info.."NameEdit"):SetText(def.TransferName)
	getglobal(info.."TipsEdit"):SetText(def.TransferTip)
	Log("showname: "..tostring(def.ShowName))
	if def.ShowName then
		getglobal(info.."NameDisplayShowIcon"):Show()
		getglobal(info.."NameDisplayHideIcon"):Hide()
	else
		getglobal(info.."NameDisplayShowIcon"):Hide()
		getglobal(info.."NameDisplayHideIcon"):Show()
	end
end

function UpdateTransferBox(def)
	local detailBox = "TransferFrameMainDetailBox"
	local briefBox 	= "TransferFrameMainBriefBox"
	t_condition = {}
	local num = def:getConditionSize()
	
	for i=0,(num-1) do
		local conditionDef = def:getConditionStruct(i)
		if conditionDef then
			table.insert(t_condition,conditionDef)	
		end
	end
	Log("t_condition:")
	--t_condition = {};
	----t_condition = (def.Condition)[1];
	--if def.Condition[1] ~=nil then
	--	print("llll",(def.Condition)[1])
	--end
	local t_des 	= {}

	if #(t_condition)~=0 then
		for i=1,#(t_condition) do 
			local temp=TransferMgr:getTransferDef(t_condition[i].TransferID)
			if temp then
				table.insert(t_des,t_condition[i])
				table.insert(t_visualCondition,{idx=i,id=temp.ID,clientID=0})
				--if visualState == 0 then
				--	if LuaInterface:band(temp.Status,8) == 8 then
				--		table.insert(t_des,t_condition[i])
				--		table.insert(t_visualCondition,{idx=i,id=temp.ID, clientID=0})
				--	end
				--else
				--	table.insert(t_des,t_condition[i])
				--	table.insert(t_visualCondition,{idx=i,id=temp.ID,clientID=0})
				--end
			end
		end
	end

	local desNum 	= #(t_des)
	local detailboxHeight = (105+4)*desNum + 105;
	local briefboxHeight  = (68+4)*desNum + 68;


	if detailboxHeight < 330 then
		detailboxHeight = 330
	end
	if briefboxHeight < 330 then
		briefboxHeight = 330
	end
	getglobal(detailBox.."Plane"):SetHeight(detailboxHeight)
	getglobal(briefBox.."Plane"):SetHeight(briefboxHeight)
	for i = 1, desNum do 
		CurrentRuleDef = t_des[i];
		local EndDef = TransferMgr:getTransferDef(t_des[i].TransferID)
		getglobal(detailBox.."D"..i):SetPoint("top", detailBox.."Plane", "top", 0, (105+4)*(i-1))
		getglobal(briefBox.."B"..i):SetPoint("top", briefBox.."Plane", "top", 0, (68+4)*(i-1))
		getglobal(detailBox.."D"..i):Show()
		getglobal(briefBox.."B"..i):Show();
		t_visualCondition[i].clientID = getglobal(detailBox.."D"..i):GetClientID();

		local title 	= getglobal(detailBox.."D"..i.."ContentTitle")
		local title1 	= getglobal(briefBox.."B"..i.."Title")

		local ticket 	= getglobal(detailBox.."D"..i.."ContentTicketIcon")
		local ticketBkg = getglobal(detailBox.."D"..i.."ContentTicketBkg")
		local ticketDefault = getglobal(detailBox.."D"..i.."ContentTicketDefault")

		local price 	= getglobal(detailBox.."D"..i.."ContentPrice")
		local priceCount= getglobal(detailBox.."D"..i.."ContentPriceCount")

		local ban 		= getglobal(detailBox.."D"..i.."ContentBan")
		local banIcon 	= getglobal(detailBox.."D"..i.."ContentBanIcon")
		local banBkg 	= getglobal(detailBox.."D"..i.."ContentBanBkg")
		local banDefault= getglobal(detailBox.."D"..i.."ContentBanDefault")

		local team 		= {
							getglobal(detailBox.."D"..i.."ContentTeamIcon1"),
							getglobal(detailBox.."D"..i.."ContentTeamIcon2"),
							getglobal(detailBox.."D"..i.."ContentTeamIcon3"),
							getglobal(detailBox.."D"..i.."ContentTeamIcon4"),
							getglobal(detailBox.."D"..i.."ContentTeamIcon5"),
							getglobal(detailBox.."D"..i.."ContentTeamIcon6"),
						  }
		local teamDefault= getglobal(detailBox.."D"..i.."ContentTeamDefault")
		local status 	= getglobal(detailBox.."D"..i.."ContentStateStatus")

		title:SetText(EndDef.TransferName);
		title1:SetText(EndDef.TransferName);
		--1.通行物品
		if CurrentRuleDef.PassItemID ~= 0 then
			ticketBkg:Show();
			ticket:Show();
			ticketDefault:Hide()
			SetItemIcon(ticket, CurrentRuleDef.PassItemID)
		else
			ticket:Hide();
			ticketBkg:Hide()
			ticketDefault:Show()
		end
		--2.消耗数量
		if CurrentRuleDef.PassItemNum ~= 0 then
			price:Show()
			priceCount:SetText(tostring(CurrentRuleDef.PassItemNum))
			--ban:SetPoint("left",detailBox.."D"..i.."ContentPrice","right",10,0)
		else
			price:Hide()
			--ban:SetPoint("left",detailBox.."D"..i.."ContentPrice","right",10,0)
		end
		--3.禁止通行物品
		if CurrentRuleDef.ForbidItemID ~= 0 then
			banBkg:Show()
			banIcon:Show();
			banDefault:Hide()
			SetItemIcon(banIcon,CurrentRuleDef.ForbidItemID)
		else
			banBkg:Hide()
			banIcon:Hide()
			banDefault:Show()
		end
		--4.激活/未激活状态
		if LuaInterface:band(EndDef.Status,8) == 0 then
			status:SetText(GetS(8006))
			status:SetTextColor(101,116,118)
		else
			status:SetText(GetS(637))
			status:SetTextColor(1,194,16)		
		end
		--5.队伍权限
		if CurrentRuleDef.TeamColor ~= 63 then
			teamDefault:Hide()
			local t_word = {
							{b=1, tex = "icon_team_red"},
							{b=2, tex = "icon_team_blue"},
							{b=4, tex = "icon_team_green"},
							{b=8, tex = "icon_team_yellow"},
							{b=16, tex = "icon_team_orange"},
							{b=32, tex = "icon_team_purple"},
						}
			local WORD = CurrentRuleDef.TeamColor
			local count= 0;
			for p=1, 6 do
				if LuaInterface:band(WORD, t_word[p].b)==0 then
					count = count + 1
					team[count]:Show()
					team[count]:SetTexUV(t_word[p].tex);
				end
			end
			for q=count+1,6 do
				team[q]:Hide()
			end
		else
			for j=1,6 do
				team[j]:Hide()
			end
			teamDefault:Show()
		end
	end
	getglobal(detailBox.."AddBtn"):SetPoint("top", detailBox.."Plane", "top", 0, (105+4)*desNum)
	getglobal(briefBox.."AddBtn"):SetPoint("top", briefBox.."Plane", "top", 0, (68+4)*desNum)

	if desNum < Max_Destinations then
		for i = (desNum+1),Max_Destinations do
			getglobal(detailBox.."D"..i):Hide()
			getglobal(briefBox.."B"..i):Hide()
		end
	end
end

function TransferBlockSwitch_OnClick(switchName, state)
	--是否显示未激活传送点
	if string.find(switchName, "VisualSwitch") then
		visualState = state;
		UpdateTransferBox(CurrentTransferDef);
		return;
	end

	edit_dirty = 1;

	local name 			= "TransferRuleSetFrameBox"
	local nameConsume 	= name.."Switch3"
	local box 			= getglobal("TransferRuleSetFrameBox")

	local switch1 		= getglobal(name.."Switch1")
	local switch2 		= getglobal(name.."Switch2")
	local switch3 		= getglobal(name.."Switch3")
	local switch4 		= getglobal(name.."Switch4")

	local title2 		= getglobal(name.."Title2")

	local select1 		= getglobal(name.."Ticket")
	local select2 		= getglobal(name.."BanItem")

	local slider1 		= getglobal(name.."SliderPrice")

	local team 			= getglobal(name.."TeamAccess")

	local ticketIcon = getglobal("TransferRuleSetFrameBoxTicketSelectIcon");
	local banIcon 	 = getglobal("TransferRuleSetFrameBoxBanItemSelectIcon");
	local ticketDel  = getglobal("TransferRuleSetFrameBoxTicketSelectDel");
	local banDel 	 = getglobal("TransferRuleSetFrameBoxBanItemSelectDel")

	local t_attr = TransferRuleSetDef.Attr;

	if string.find(switchName, "Switch1") then
		if state == 1 then
			team:Show()
			t_attr["TeamColor"].IsShown = true;
			t_attr["TeamColor"].CurVal = 63;
			for i=1,6 do
				getglobal("TransferRuleSetFrameBoxTeamAccessT"..i.."BtnClick"):Hide()
				getglobal("TransferRuleSetFrameBoxTeamAccessT"..i.."Bkg"):SetTexUV("btn_blackboard_orange");
			end
		else
			team:Hide()
			t_attr["TeamColor"].IsShown = false;
			t_attr["TeamColor"].CurVal = 0;
		end
	elseif string.find(switchName, "Switch2") then
		if state == 1 then
			select1:Show()
			ticketIcon:Hide()
			ticketDel:Hide()
			t_attr["PassItemID"].IsShown = true; 
			t_attr["PassItemID"].CurVal = 0;
		else
			TransferBlockSwitch_OnClick(nameConsume, 0)
			getglobal(nameConsume.."BtnPoint"):SetPoint("left", nameConsume.."Btn", "left", 4, -3)
			select1:Hide()
			switch3:Hide()
			t_attr["PassItemID"].IsShown = false;
			t_attr["PassItemID"].CurVal = 0;
			t_attr["PassItemNum"].IsShown = false;
			t_attr["PassItemNum"].CurVal = 0;
		end
	elseif string.find(switchName, "Switch3") then
		if state == 1 then
			slider1:Show()
			t_attr["PassItemNum"].IsShown = true;
			t_attr["PassItemNum"].CurVal = 1;
			t_attr["IsExpendable"].CurVal = true;
			getglobal("TransferRuleSetFrameBoxSliderPriceBar"):SetValue(1)
		else
			slider1:Hide()
			t_attr["PassItemNum"].IsShown = false;
			t_attr["PassItemNum"].CurVal = 0;
			t_attr["IsExpendable"].CurVal = false;
		end
	elseif string.find(switchName, "Switch4") then
		if state == 1 then
			select2:Show()
			banIcon:Hide()
			banDel:Hide()
			t_attr["ForbidItemID"].IsShown = true;
		else
			select2:Hide()
			t_attr["ForbidItemID"].IsShown = false;
			t_attr["ForbidItemID"].CurVal = 0
		end
	end

	UpdateTransferRuleSetBox()

end

function TransferFrame_OnLoad( ... )
	for i=1,Max_Destinations do
		getglobal("TransferFrameMainDetailBoxD"..i.."ContentLine"):SetBlendAlpha(0.50)
		getglobal("TransferFrameMainDetailBoxD"..i.."ContentLine"):SetAngle(90)
	end

	--if get_game_lang()~=0 and get_game_lang()~=2 then
	--	getglobal("TransferFrameMainDetailBoxD1ContentTicketTitle"):SetWidth(100)
	--	getglobal("TransferFrameMainDetailBoxD1ContentTeamTitle"):SetWidth(100)
	--	getglobal("TransferFrameMainDetailBoxD1ContentPriceTitle"):SetWidth(100)
	--end
	
	-- for idx = 1, Max_Destinations do
	-- 	local t_text = {
	-- 	"TransferFrameMainDetailBoxD"..idx.."ContentTicketTitle",
	-- 	"TransferFrameMainDetailBoxD"..idx.."ContentPriceTitle",
	-- 	"TransferFrameMainDetailBoxD"..idx.."ContentBanTitle",
	-- 	"TransferFrameMainDetailBoxD"..idx.."ContentTeamTitle",
	-- 	"TransferFrameMainDetailBoxD"..idx.."ContentStateTitle",
	-- }
	-- 	for i=1,#(t_text) do
	-- 		local width = getglobal(t_text[i]):GetTextExtentWidth(getglobal(t_text[i]):GetText())
	-- 		getglobal(t_text[i]):SetWidth(width);
	-- 		local content_width = 0
	-- 		if i == 4 then
	-- 			content_width = 80
	-- 		elseif i == 5 then
	-- 			content_width = 48
	-- 		elseif i == 2 then
	-- 			content_width = 80
	-- 		else
	-- 			local default_str = getglobal(getglobal(t_text[i]):GetParent().."Default")
	-- 			content_width = default_str:GetTextExtentWidth(default_str:GetText())
	-- 		end
	-- 		getglobal(t_text[i]):GetParentFrame():SetWidth(width + 8 + content_width)
	-- 	end
	-- end

end

function TransferFrame_OnShow( ... )
	getglobal("TransferFrameMainInfoTipsTitleName"):SetText(GetS(21501),61,69,70)
	getglobal("TransferFrameMainInfoVisualSwitchTitleName"):SetText(GetS(21502),61,69,70)

	--getglobal("TransferFrameMainTransferDetailChangeBtnDesc1"):SetText(GetS(21510));
	--getglobal("TransferFrameMainTransferDetailChangeBtnDesc2"):SetText(GetS(21511));
	local detailSwitchPoint = getglobal("TransferFrameMainTransferDetailChangeBtnPoint");
	local detailSwitchBkg = getglobal("TransferFrameMainTransferDetailChangeBtnBkg");
	if detailSwitchPoint:GetRealLeft() - detailSwitchBkg:GetRealLeft() < 76 then
		getglobal("TransferFrameMainTransferDetailChangeBtnName"):SetText(GetS(21510));
	else
		getglobal("TransferFrameMainTransferDetailChangeBtnName"):SetText(GetS(21511));
	end
	HideAllFrame("TransferFrame", true);

	if not getglobal("TransferFrame"):IsReshow() then
        ClientCurGame:setOperateUI(true)
    end

    local t_richtext = {
		"TransferFrameMainInfoTips",
		"TransferFrameMainInfoVisualSwitch",
	}

    -- for i=1, #(t_richtext) do
	-- 	local width = getglobal(t_richtext[i].."TitleName"):GetLineWidth(1);
	-- 	if width > 0 then
			-- getglobal(t_richtext[i].."TitleName"):SetWidth(width)
			-- getglobal(t_richtext[i].."Title"):SetWidth(width)
--			if i == 1 then
--				getglobal(t_richtext[i]):SetWidth(width + 15 + 312)
--			else
--				getglobal(t_richtext[i]):SetWidth(width + 15 + 111)
--			end
	-- 	end
	-- end

end

function TransferFrame_OnHide( ... )
	if not getglobal("TransferFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
	getglobal("AttribTipsFrame"):Hide() --解决手机上提示不隐藏的问题 code_by:huangfubin
	ShowMainFrame()
end

--切换按钮
function TransferFrameDetailChangeBtn_OnClick()
	local switchName 	= this:GetName();
	local bkg 		= getglobal(switchName.."Bkg");
	local point 	= getglobal(switchName.."Point");
	local name 		= getglobal(switchName.."Name");
	if point:GetRealLeft() - bkg:GetRealLeft() >= 34 then			--先前状态：开
		point:SetPoint("left", this:GetName(), "left", 0, 0);
		name:SetText(GetS(21510))
		getglobal("TransferFrameMainDetailBox"):Show()
		getglobal("TransferFrameMainBriefBox"):Hide()
		--getglobal(switchName .. "Desc2"):SetText(GetS(21511));
	else									--先前状态：关
		point:SetPoint("right", this:GetName(), "right", 0, 0);
		name:SetText(GetS(21511))
		getglobal("TransferFrameMainDetailBox"):Hide()
		getglobal("TransferFrameMainBriefBox"):Show()
		--getglobal(switchName .. "Desc1"):SetText(GetS(21510));
		
	end
end

--关闭按钮
function TransferFrameCloseBtn_OnClick( ... )
	TransferFrameConfirmBtn_OnClick()
end

function TransferFrameConfirmBtn_OnClick( ... )
	local teleport_id = -1;
	if CurrentTransferDef and CurrentTransferDef.ID then
		teleport_id = CurrentTransferDef.ID
	elseif  #(t_transfer) > 0 then
		teleport_id = t_transfer[1].def.ID
	end
	local success = TransferMgr:writeToJsonFile(teleport_id,false)
	if not success then
		Log("write to json file failed!!!")
		ShowGameTips(GetS(3941))
		UpdateAllTransferDefs()
		if not TransferMgr:getTransferDef(CurrentTransferDef.ID) then
			if #(t_transfer) > 0 then
				CurrentTransferDef = t_transfer[1].def
				ChangeTransferBtn(1,true)
			else
				Log("no transfer block exist!!!")
			end
		end
		UpdateTransferMain(CurrentTransferDef)
		
	end
	getglobal("TransferFrame"):Hide()
	
end

--左侧标签列表按钮模板
local prebtn_idx;
function TransferBtnTemplate_OnClick()
	local idx = this:GetClientID()
	UpdateAllTransferDefs()
	UpdateTransferTabs()
	ChangeTransferBtn(idx)
	
end

function ChangeTransferBtn(idx,isopen)
	local btn = "TransferFrameTabsBoxBtn"
	if t_transfer[idx] then
		getglobal(btn..idx.."Normal"):Hide()
		getglobal(btn..idx.."Checked"):Show()
		getglobal(btn..idx.."Name"):SetTextColor(55, 54, 49);

		if prebtn_idx~=nil and prebtn_idx~=idx then
			getglobal(btn..prebtn_idx.."Normal"):Show()
			getglobal(btn..prebtn_idx.."Checked"):Hide()
			getglobal(btn..idx.."Name"):SetTextColor(61, 69, 70);
		end

		CurrentTransferDef = TransferMgr:getTransferDef(t_transfer[idx].id)
		prebtn_idx = idx;
		UpdateTransferMain(CurrentTransferDef)

		if isopen==true then
			local ratio = (idx-1)/(#t_transfer-1)
			if ratio > 1 then ratio = 1 end
			if ratio < 0 then ratio = 0 end
			local offsetY = getglobal("TransferFrameTabsBoxPlane"):GetHeight()-getglobal("TransferFrameTabsBox"):GetHeight()
			print("offsetY:",offsetY,ratio)
			getglobal("TransferFrameTabsBox"):setCurOffsetY(0-offsetY*ratio)
		end
	end
end

--右側上方信息欄
function TransferFrameMainNameEdit_OnEnterPressed( ... )
	UIFrameMgr:setCurEditBox(nil);
end

function TransferFrameMainNameEdit_OnFocusLost( ... )
	local text = getglobal("TransferFrameMainInfoNameEdit");
	if text:GetText() == "" then
		text:SetText(CurrentTransferDef.TransferName);
	end
	if CheckFilterString(text:GetText()) then
		text:SetText(CurrentTransferDef.TransferName)
		return;
	end
	for i=1,#(t_transfer) do
		if CurrentTransferDef.ID ~= t_transfer[i].id then
			if t_transfer[i]["def"].TransferName == text:GetText() then
				ShowGameTips(GetS(21499))
				text:SetText(CurrentTransferDef.TransferName)
				return;
			end
		end
	end
	TransferMgr:updateTransferCoreInfo(CurrentTransferDef.ID,text:GetText(),CurrentTransferDef.TransferTip,CurrentTransferDef.ShowName)
	UpdateAllTransferDefs()
end

function TransferFrameMainNameDisplay_OnClick( ... )
	local showicon = getglobal("TransferFrameMainInfoNameDisplayShowIcon")
	local hideicon = getglobal("TransferFrameMainInfoNameDisplayHideIcon")
	if showicon:IsShown() then
		showicon:Hide()
		hideicon:Show()
	else
		hideicon:Hide()
		showicon:Show()
	end
	TransferMgr:updateTransferCoreInfo(CurrentTransferDef.ID,CurrentTransferDef.TransferName,CurrentTransferDef.TransferTip,showicon:IsShown())
end

function TransferFrameMainTipsEdit_OnFocusLost( ... )
	local text = getglobal("TransferFrameMainInfoTipsEdit");
	if CheckFilterString(text:GetText()) then
		text:SetText(CurrentTransferDef.TransferTip)
		return;
	end
	TransferMgr:updateTransferCoreInfo(CurrentTransferDef.ID,CurrentTransferDef.TransferName,text:GetText(),CurrentTransferDef.ShowName)
end

function TransferFrameMainTipsEdit_OnEnterPressed( ... )
	UIFrameMgr:setCurEditBox(nil);
end

--传送规则编辑按钮
function TransferLabelTemplateEditBtn_OnClick( ... )
	local idx = this:GetParentFrame():GetClientID()
	getglobal("TransferRuleSetFrame"):Show()
	OpenRuleSetBox(idx)
	UpdateTransferRuleSetBox()
end

--新增传送目标点按钮
function TransferFrameMainAddBtn_OnClick( ... )
	
	UpdateAddTransferBox()
	getglobal("AddTransferDestinationFrame"):Show()
end

-----------------------------------------------2.新增传送目标点界面-----------------------------------------------------
--刷新可选择目标点列表
local t_add = {}
function UpdateAddTransferBox( ... )
	if not TransferMgr:getTransferDef(CurrentTransferDef.ID) then
		--ShowGameTips("当前传送点不存在")
		return
	end
	t_add = {};
	local count = #(t_transfer);
	local frame = "AddTransferDestinationFrame"
	Log("condition size: "..tostring(CurrentTransferDef:getConditionSize()))
	if count<2 or (count-CurrentTransferDef:getConditionSize())<2 then
		getglobal(frame.."NoTitle"):Show()
		getglobal(frame.."EmptyIcon"):Show()
		getglobal(frame.."Box"):Hide()
		return;
	else
		getglobal(frame.."NoTitle"):Hide()
		getglobal(frame.."EmptyIcon"):Hide()
		getglobal(frame.."Box"):Show()
	end
	Log("t_transfer:")
	Log("t_condition:")
	if #(t_condition)>0 then
		print("condition id ",t_condition[1].TransferID)
	end
	for i=1,#(t_transfer) do
		local state = 1;
		if t_transfer[i].id == CurrentTransferDef.ID then
			state = 0;
		else
			for j=1,#(t_condition) do
				print("compare :",t_transfer[i].id, CurrentTransferDef.ID)
				if t_transfer[i].id == t_condition[j].TransferID then
					state = 0;
					break;
				else
					state = 1;
				end
				
			end
		end
		if state == 1 then
			table.insert(t_add,{def =t_transfer[i].def, id = t_transfer[i].id, name = t_transfer[i].name})
		end
	end
	Log("t_add:")


	local btn = "AddTransferDestinationFrameBoxD"
	local plane = "AddTransferDestinationFrameBoxPlane"
	local height = 71*#(t_add) - 10;
	if height < 444 then
		height = 444;
	end
	getglobal(plane):SetHeight(height)
	for i=1,#(t_add) do
		if LuaInterface:band(t_add[i]["def"].Status,8) == 0 then
			getglobal(btn..i.."Icon"):SetTexUV("icon_activation_n.png")
		else
			getglobal(btn..i.."Icon"):SetTexUV("icon_activation_h.png")
		end
		getglobal(btn..i):SetPoint("top",plane,"top",0, i*71-71)
		getglobal(btn..i.."Title"):SetText(t_add[i].name)
		getglobal(btn..i):Show()
	end
	for i=#(t_add)+1,Max_Destinations do
		getglobal(btn..i):Hide();
	end
end

local t_multides = {}
local pretransfer_idx;
function DestinationSelectBtnTemplate_OnClick( ... )
	local name = this:GetName()
	local idx = this:GetClientID()
	--新增传送点 多选
	if string.find(name,"AddTransferDestinationFrame") then
		if getglobal(name.."Checked"):IsShown() then
			for i=1,#(t_multides) do
				if t_add[idx].id == t_multides[i].id then
					table.remove(t_multides,i)
					break;
				end
			end
			getglobal(name.."Checked"):Hide()
		else
			getglobal(name.."Checked"):Show()
			table.insert(t_multides,{id = t_add[idx].id, name = t_add[idx].name})
		end
	--选择传送目标
	elseif string.find(name,"ChooseTransferDestinationFrame") then
		getglobal(name.."Checked"):Show()
		getglobal("ChooseTransferDestinationFrameConfirmBtn"):SetClientID(t_choosedes[idx].TransferID)
		if pretransfer_idx~=nil and pretransfer_idx~=idx then
			getglobal("ChooseTransferDestinationFrameBoxD"..pretransfer_idx.."Checked"):Hide()
		end
		
		UpdateRuleDisplay(idx)
		pretransfer_idx = idx
	end
end

function UpdateRuleDisplay(idx)
	local isfree = true;
	local info = "ChooseTransferDestinationFrameBoxInfo"
	local teamDefault = getglobal("ChooseTransferDestinationFrameBoxInfoNoTeam")
	local team = {
					getglobal("ChooseTransferDestinationFrameBoxInfoIcon1"),
					getglobal("ChooseTransferDestinationFrameBoxInfoIcon2"),
					getglobal("ChooseTransferDestinationFrameBoxInfoIcon3"),
					getglobal("ChooseTransferDestinationFrameBoxInfoIcon4"),
					getglobal("ChooseTransferDestinationFrameBoxInfoIcon5"),
					getglobal("ChooseTransferDestinationFrameBoxInfoIcon6")
				}
	local conditionDef = t_condition[idx]
	--通行队伍
	if conditionDef.TeamColor ~= 63 then
		if conditionDef.TeamColor ~= 0 then isfree = false; end
		teamDefault:Hide()
		local t_word = {
						{b=1, tex = "icon_team_red"},
						{b=2, tex = "icon_team_blue"},
						{b=4, tex = "icon_team_green"},
						{b=8, tex = "icon_team_yellow"},
						{b=16, tex = "icon_team_orange"},
						{b=32, tex = "icon_team_purple"},
					}
		local WORD = conditionDef.TeamColor
		local count= 0;
		for p=1, 6 do
			if LuaInterface:band(WORD, t_word[p].b)==0 then
				count = count + 1
				team[count]:Show()
				team[count]:SetTexUV(t_word[p].tex);
			end
		end
		for q=count+1,6 do
			team[q]:Hide()
		end
	else
		isfree = false
		for j=1,6 do
			team[j]:Hide()
		end
		teamDefault:Show()
	end
	--通行道具
	local ticketDefault = getglobal("ChooseTransferDestinationFrameBoxInfoNoTicket")
	local ticketBkg = getglobal("ChooseTransferDestinationFrameBoxInfoItemBkg1")
	local ticketIcon = getglobal("ChooseTransferDestinationFrameBoxInfoItem1")
	if conditionDef.PassItemID ==0 then
		ticketBkg:Hide()
		ticketIcon:Hide()
		ticketDefault:Show()
	else
		isfree = false
		ticketBkg:Show()
		ticketIcon:Show()
		ticketDefault:Hide()
		SetItemIcon(ticketIcon,conditionDef.PassItemID)
	end
	--消耗数量
	local fsOwned = getglobal("ChooseTransferDestinationFrameBoxInfoOwned");
	local fsPrice = getglobal("ChooseTransferDestinationFrameBoxInfoPrice");
	if conditionDef.PassItemNum == 0 then
		fsOwned:Hide();
		fsPrice:Hide();
	else
		isfree = false;
		local _,_,_,ticketOwn,ticketNeed = TransferRuleSetDetect(conditionDef)
		fsOwned:Show();
		fsPrice:Show();
		fsOwned:SetText(tostring(ticketOwn));
		fsPrice:SetText("/".. tostring(ticketNeed));
--		getglobal("ChooseTransferDestinationFrameBoxInfoPrice"):SetText(tostring(ticketOwn).."/"..tostring(ticketNeed))
		if ticketOwn < ticketNeed then
			fsOwned:SetTextColor(233,21,21);
		else
			fsOwned:SetTextColor(1,194,16);
		end
	end
	--禁止通行
	local banBkg = getglobal("ChooseTransferDestinationFrameBoxInfoItemBkg2")
	local banIcon = getglobal("ChooseTransferDestinationFrameBoxInfoItem2")
	local banDefault = getglobal("ChooseTransferDestinationFrameBoxInfoNoBan")
	if conditionDef.ForbidItemID == 0 then
		banBkg:Hide()
		banIcon:Hide()
		banDefault:Show()
	else
		isfree = false;
		banBkg:Show()
		banIcon:Show()
		banDefault:Hide()
		SetItemIcon(banIcon,conditionDef.ForbidItemID)
	end

	local info_height = 176;
	if isfree == true then
		info_height = 0;
		getglobal("ChooseTransferDestinationFrameBoxInfo"):Hide()
	else
		getglobal("ChooseTransferDestinationFrameBoxInfo"):Show()
	end

	for i=1, idx do
		getglobal("ChooseTransferDestinationFrameBoxD"..i):SetPoint("top","ChooseTransferDestinationFrameBoxPlane","top", 0, (i-1)*(61+10))
	end
	for i=idx+1,#(t_condition) do
		getglobal("ChooseTransferDestinationFrameBoxD"..i):SetPoint("top","ChooseTransferDestinationFrameBoxPlane","top",0, (i-1)*(61+10)+info_height)
	end
	getglobal("ChooseTransferDestinationFrameBoxInfo"):SetPoint("top","ChooseTransferDestinationFrameBoxPlane","top",0, idx*(61+10))
	--getglobal("ChooseTransferDestinationFrameBoxInfo"):Show()

	local iPlaneHeight = #(t_condition)*(61+10)+info_height;
	iPlaneHeight = iPlaneHeight > 398 and iPlaneHeight or 398;
	getglobal("ChooseTransferDestinationFrameBoxPlane"):SetHeight(iPlaneHeight);
	getglobal("ChooseTransferDestinationFrameBoxPlane"):SetPoint("top", "ChooseTransferDestinationFrameBox", "top", 0, 0);
end

function AddTransferDestinationFrame_OnLoad( ... )

end

function AddTransferDestinationFrame_OnShow( ... )
	setTransferBoxState(false)


end

function AddTransferDestinationFrame_OnHide( ... )
	setTransferBoxState(true)
	t_multides = {}
	for i=1, Max_Destinations do
		getglobal("AddTransferDestinationFrameBoxD"..i.."Checked"):Hide()
	end
end

function AddTransferDestinationFrameCloseBtn_OnClick( ... )
	getglobal("AddTransferDestinationFrame"):Hide()
end
--jsonstr格式：
--｛
--	"id":xxx,					-- transfer start place
--	"name":xxx,					-- transfer start name
--	"desid":xxx,				-- transfer destination
--	"teamcolor":xxx,			-- destination teamcolor
--	"passitemid":xxx,			
--	"passitemnum":xxx,
--	"forbiditemid":xxx,
--	"isexpendable":xxx,
--｝
function AddTransferDestinationFrameConfirmBtn_OnClick( ... )
	if #(t_multides)==0 then
		ShowGameTips(GetS(21491))
		return
	end
	local state = 0
	local t_json = {}
	t_json["id"] 			= CurrentTransferDef.ID
	t_json["name"]			= CurrentTransferDef.TransferName
	t_json["desid"]			= 0
	t_json["teamcolor"] 	= 0
	t_json["passitemid"]	= 0
	t_json["passitemnum"]	= 0
	t_json["forbiditemid"]	= 0
	t_json["isexpendable"] 	= false

	Log("t_multides:")

	for i=1,#(t_multides) do
		if not TransferMgr:getTransferDef(t_multides[i].id) then
			ShowGameTips(GetS(21486,t_multides[i].name))
		else
			t_json["desid"]	= t_multides[i].id
		end

		local dataStr = JSON:encode(t_json);
		local success = TransferMgr:updateTransferRecord(dataStr)
		if success then
			state = 1
		else
			ShowGameTips(GetS(21496))
		end
	end

	
	if state == 0 then	--全部添加失败
		UpdateAllTransferDefs()
		UpdateAddTransferBox()
	else
		ShowGameTips(GetS(21495))
		getglobal("AddTransferDestinationFrame"):Hide()
		UpdateTransferBox(CurrentTransferDef);
	end
	
end



----------------------------------------------3.传送规则编辑界面------------------------------------------------------

function TransferRuleSetFrame_OnLoad( ... )
	local point="TransferRuleSetFrameBoxTeamAccess"

	local aTextureUV = {
		"icon_team_red",
		"icon_team_blue",
		"icon_team_green",
		"icon_team_yellow",
		"icon_team_orange",
		"icon_team_purple",
	}
	for i=1,6 do
		getglobal(point.."T"..i.."Flag"):SetTexUV(aTextureUV[i])
		getglobal(point.."T"..i):SetPoint("left", point, "left", 132+(i-1)*54, 0)
	end
	
	local name = getglobal("TransferRuleSetFrameBoxSwitch3Name")
	
	if name:GetTextExtentWidth(name:GetText()) > 220 then
		name:SetAutoWrap(true)
		name:SetHeight(80)
	end
	--print("ooooo",get_game_lang())
	--if get_game_lang() ~= 0 and get_game_lang() ~= 2 then
	--	getglobal("TransferRuleSetFrameBoxSwitch1Name"):SetPoint("topright","TransferRuleSetFrameBoxSwitch1","topright",-445,3)
	--	getglobal("TransferRuleSetFrameBoxSwitch2Name"):SetPoint("topright","TransferRuleSetFrameBoxSwitch2","topright",-451,3)
	--	getglobal("TransferRuleSetFrameBoxSwitch4Name"):SetPoint("topright","TransferRuleSetFrameBoxSwitch4","topright",-445,3)
	--	getglobal("TransferFrameMainInfoTipsTitleName"):SetPoint("left","TransferFrameMainInfoTipsTitle","left",-17,0)
	--	getglobal("TransferFrameMainInfoVisualSwitchTitleName"):SetPoint("left","TransferFrameMainInfoVisualSwitchTitle","left",-17,0)
	--end
end

function TransferRuleSetFrame_OnShow( ... )
	--local h = getglobal("TransferRuleSetFrameBoxSwitch1NameName"):GetTextExtentHeight()
	setTransferBoxState(false)
	getglobal("TransferRuleSetFrameBoxTitle1Title"):SetText(GetS(21516))
	getglobal("TransferRuleSetFrameBoxTitle2Title"):SetText(GetS(21519))

	getglobal("TransferRuleSetFrameBoxSwitch1NameName"):SetText(GetS(21517),255,255,255)
	getglobal("TransferRuleSetFrameBoxSwitch2NameName"):SetText(GetS(21520),61,69,70)
	getglobal("TransferRuleSetFrameBoxSwitch4NameName"):SetText(GetS(21521),61,69,70)
	getglobal("TransferRuleSetFrameBoxSwitch1NameName"):SetText(GetS(21517),98,65,48)
	getglobal("TransferRuleSetFrameBoxSwitch2NameName"):SetText(GetS(21520),98,65,48)
	getglobal("TransferRuleSetFrameBoxSwitch4NameName"):SetText(GetS(21521),98,65,48)

	local t_richtext = {
		"TransferRuleSetFrameBoxSwitch1NameName",
		"TransferRuleSetFrameBoxSwitch2NameName",
		"TransferRuleSetFrameBoxSwitch4NameName",
		"TransferRuleSetFrameBoxTitle1Title",
		"TransferRuleSetFrameBoxTitle2Title"
	}
	for i=1,#(t_richtext) do
		local width;
		if string.find(t_richtext[i],"Title") then
			width = getglobal(t_richtext[i]):GetTextExtentWidth(getglobal(t_richtext[i]):GetText())
		else
			width = getglobal(t_richtext[i]):GetLineWidth(1)
		end
		if width > 0 then
			getglobal(t_richtext[i]):SetWidth(width)
		end
	end
end

function TransferRuleSetFrame_OnHide( ... )
	setTransferBoxState(true)
	getglobal("AttribTipsFrame"):Hide() --解决手机上提示不隐藏的问题 code_by:huangfubin
end

--刷新规则设置界面UI
function UpdateTransferRuleSetBox( ... )
	local count = 0;
	local plane = "TransferRuleSetFrameBoxPlane"
	local boxUI = {
				{frame = getglobal("TransferRuleSetFrameBoxTitle1"), height = 0},
				{frame = getglobal("TransferRuleSetFrameBoxSwitch1"), height = 0},
				{frame = getglobal("TransferRuleSetFrameBoxTeamAccess"), height = 0},
				{frame = getglobal("TransferRuleSetFrameBoxTitle2"), height = 0},
				{frame = getglobal("TransferRuleSetFrameBoxSwitch2"), height = 0},
				{frame = getglobal("TransferRuleSetFrameBoxTicket"), height = 0},
				{frame = getglobal("TransferRuleSetFrameBoxSwitch3"), height = 0},
				{frame = getglobal("TransferRuleSetFrameBoxSliderPrice"), height = 0},
				{frame = getglobal("TransferRuleSetFrameBoxSwitch4"), height = 0},
				{frame = getglobal("TransferRuleSetFrameBoxBanItem"), height = 0}
			}

	for i=1,#(boxUI) do
		boxUI[i].height = boxUI[i].frame:GetHeight();
	end

	for i=1,#(boxUI) do
		if boxUI[i].frame:IsShown() then
			boxUI[i].frame:SetPoint("top",plane,"top",0, count);
			count = count + boxUI[i].height + 30;
		end
	end
	getglobal(plane):SetHeight(count);
end


function OpenRuleSetBox( idx )
	local conditionDef = CurrentTransferDef:getConditionStruct(idx-1)
	local EndDef;
	if not conditionDef then
		getglobal("TransferRuleSetFrame"):Hide()
		return
	else
		EndDef = TransferMgr:getTransferDef(conditionDef.TransferID)
		if not EndDef then
			getglobal("TransferRuleSetFrame"):Hide()
			return
		end
	end
	getglobal("TransferRuleSetFrameDelBtn"):SetClientID(EndDef.ID)
	getglobal("TransferRuleSetFrameConfirmBtn"):SetClientID(EndDef.ID)

	local name 			= "TransferRuleSetFrameBox"
	local nameConsume 	= name.."Switch3"
	local box 			= getglobal("TransferRuleSetFrameBox")

	local switch1 		= getglobal(name.."Switch1")
	local switch2 		= getglobal(name.."Switch2")
	local switch3 		= getglobal(name.."Switch3")
	local switch4 		= getglobal(name.."Switch4")

	local title2 		= getglobal(name.."Title2")

	local select1 		= getglobal(name.."Ticket")
	local select2 		= getglobal(name.."BanItem")
	local slider1 		= getglobal(name.."SliderPrice")

	local team 			= getglobal(name.."TeamAccess")

	TransferRuleSetDef.ID = EndDef.ID;
	TransferRuleSetDef.Name = EndDef.TransferName;
	TransferRuleSetDef.Init(conditionDef)
	getglobal("TransferRuleSetFrameInfoStart"):SetText(CurrentTransferDef.TransferName)
	getglobal("TransferRuleSetFrameInfoEnd"):SetText(EndDef.TransferName)
	local t_attr = TransferRuleSetDef.Attr;
	--队伍设置
	if t_attr["TeamColor"].CurVal == 0 then
		team:Hide()
		SetSwitchBtnState("TransferRuleSetFrameBoxSwitch1Btn",0)
	else
		SetSwitchBtnState("TransferRuleSetFrameBoxSwitch1Btn",1)
		team:Show()
		local t_flagword = {
							{b=1, tex = "icon_team_red"},
							{b=2, tex = "icon_team_blue"},
							{b=4, tex = "icon_team_green"},
							{b=8, tex = "icon_team_yellow"},
							{b=16, tex = "icon_team_orange"},
							{b=32, tex = "icon_team_purple"},
						}
		for p=1, 6 do
			if LuaInterface:band(t_attr["TeamColor"].CurVal, t_flagword[p].b)==0 then
				getglobal("TransferRuleSetFrameBoxTeamAccessT"..p.."BtnClick"):Show()
				getglobal("TransferRuleSetFrameBoxTeamAccessT"..p.. "Bkg"):SetTexUV("btn_circle_yellow");
			else
				getglobal("TransferRuleSetFrameBoxTeamAccessT"..p.."BtnClick"):Hide()
				getglobal("TransferRuleSetFrameBoxTeamAccessT"..p.. "Bkg"):SetTexUV("btn_blackboard_orange");
			end
		end
	end
	local ticketIcon = getglobal("TransferRuleSetFrameBoxTicketSelectIcon");
	local banIcon 	 = getglobal("TransferRuleSetFrameBoxBanItemSelectIcon");
	local ticketDel 	 = getglobal("TransferRuleSetFrameBoxTicketSelectDel")
	local banDel 		= getglobal("TransferRuleSetFrameBoxBanItemSelectDel")
	--通行物品
	if t_attr["PassItemID"].CurVal == 0 then
		SetSwitchBtnState("TransferRuleSetFrameBoxSwitch2Btn",0)
		select1:Hide()
		ticketIcon:Hide()
		switch3:Hide()
	else
		ticketDel:Show()
		SetSwitchBtnState("TransferRuleSetFrameBoxSwitch2Btn",1)
		select1:Show()
		ticketIcon:Show()
		SetItemIcon(ticketIcon,t_attr["PassItemID"].CurVal)
		switch3:Show()
	end
	--消耗数量
	if t_attr["PassItemNum"].CurVal <= 0 then
		SetSwitchBtnState("TransferRuleSetFrameBoxSwitch3Btn",0)
		slider1:Hide()
	else
		SetSwitchBtnState("TransferRuleSetFrameBoxSwitch3Btn",1)
		slider1:Show()
		getglobal("TransferRuleSetFrameBoxSliderPriceBar"):SetValue(t_attr["PassItemNum"].CurVal);
		getglobal("TransferRuleSetFrameBoxSliderPriceVal"):SetText(tostring(t_attr["PassItemNum"].CurVal));
	end
	--禁止通行
	if t_attr["ForbidItemID"].CurVal == 0 then
		SetSwitchBtnState("TransferRuleSetFrameBoxSwitch4Btn",0)
		select2:Hide()
		banIcon:Hide()
	else
		banDel:Show()
		SetSwitchBtnState("TransferRuleSetFrameBoxSwitch4Btn",1)
		select2:Show()
		banIcon:Show()
		SetItemIcon(banIcon,t_attr["ForbidItemID"].CurVal)
	end

	UpdateTransferRuleSetBox()
end

function ChooseTeamBtnTemplate_OnClick( ... )
	local t_team = {1, 2, 4, 8, 16, 32}
	local name = this:GetName()
	local t_attr = TransferRuleSetDef.Attr;
	local idx = this:GetParentFrame():GetClientID();
	if getglobal(name.."Click"):IsShown() then
		getglobal(name.."Click"):Hide()
		getglobal(this:GetParent() .. "Bkg"):SetTexUV("btn_blackboard_orange");
		t_attr["TeamColor"].CurVal = t_attr["TeamColor"].CurVal + t_team[idx]
	else
		getglobal(name.."Click"):Show()
		getglobal(this:GetParent() .. "Bkg"):SetTexUV("btn_circle_yellow");
		t_attr["TeamColor"].CurVal = t_attr["TeamColor"].CurVal - t_team[idx]
	end

end

function ItemSelectBtnTemplate_OnClick( ... )
	local name = this:GetName();
	if string.find(name, "TicketSelect") then
		SetChooseOriginalFrame('transferticket');
	elseif string.find(name, "BanItemSelect") then
		SetChooseOriginalFrame('transferban');
	end
end

function ItemSelectBtnTemplateDel_OnClick( ... )
	local btnIdx = this:GetParentFrame():GetClientID();
	local icon = getglobal(this:GetParent().."Icon");
	local t_attr = TransferRuleSetDef.Attr;
	icon:Hide();
	this:Hide();
	if string.find(this:GetName(),"TicketSelect") then
		t_attr["PassItemID"].CurVal = 0;
		t_attr["PassItemNum"].CurVal = 0;
		getglobal("TransferRuleSetFrameBoxSwitch3"):Hide()
		getglobal("TransferRuleSetFrameBoxSliderPrice"):Hide()
		SetSwitchBtnState("TransferRuleSetFrameBoxSwitch3Btn", 0)
		UpdateTransferRuleSetBox()
	elseif  string.find(this:GetName(),"BanItem") then
		t_attr["ForbidItemID"].CurVal = 0;
	end

end

function TransferRuleSetFrameClose( ... )
	TransferRuleSetFrameCloseBtn_OnClick()
end
function TransferRuleSetFrameCloseBtn_OnClick( ... )
	if edit_dirty == 1 then
		
		MessageBox(5, GetS(21493), function(btn)
			if btn == 'left' then
				getglobal("TransferRuleSetFrame"):Hide()
				edit_dirty = 0
			else
			end
		end)
	else
		getglobal("TransferRuleSetFrame"):Hide()
	end
	
end

function TransferRuleSetFrameConfirmBtn_OnClick( ... )
	local desid = this:GetClientID()
	local t_attr = TransferRuleSetDef.Attr;
	local t_json = {}
	for i=1,#(t_name) do
		local name = t_name[i]
		if t_attr[name].Save then
			print("nnnn",t_attr[name].Name, t_attr[name].CurVal)
			t_attr[name].Save(0,t_attr[name],t_json)
		end
		t_json["id"] = CurrentTransferDef.ID
		t_json["desid"] = desid
		t_json["name"] = CurrentTransferDef.TransferName
	end

	local dataStr = JSON:encode(t_json);
	Log("t_json:")
	print("kekeke dataStr", dataStr);
	local success = TransferMgr:updateTransferRecord(dataStr)
	if success then
		ShowGameTips(GetS(9251))
		getglobal("TransferRuleSetFrame"):Hide()
		UpdateTransferBox(CurrentTransferDef)
		edit_dirty = 0
	else
		ShowGameTips(GetS(3941))
	end


end

function TransferFrameSliderLeftBtn_OnClick( ... )
	edit_dirty = 1;
 	local value = getglobal(this:GetParent().."Bar"):GetValue();
 	value = value - 1;
 	getglobal(this:GetParent().."Bar"):SetValue(value);
 	local t_attr = TransferRuleSetDef.Attr;
	t_attr["PassItemNum"].CurVal = value
end

function TransferFrameSliderBar_OnValueChanged( ... )
	local t_attr = TransferRuleSetDef.Attr;
	local value = this:GetValue();
	if t_attr["PassItemNum"].CurVal ~= value then
		edit_dirty = 1;
	end
	local ratio = (value-this:GetMinValue())/(this:GetMaxValue()-this:GetMinValue());
	if ratio > 1 then ratio = 1 end
	if ratio < 0 then ratio = 0 end
	local width   = math.floor(276*ratio)

	getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
	getglobal(this:GetName().."Pro"):SetWidth(width);
	local desc = this:GetParent().."Val"
	getglobal(desc):SetText(tonumber(value))
	
	t_attr["PassItemNum"].CurVal = value
end

function TransferFrameSliderRightBtn_OnClick( ... )
	edit_dirty = 1;
	local value = getglobal(this:GetParent().."Bar"):GetValue();
 	value = value + 1;
 	getglobal(this:GetParent().."Bar"):SetValue(value);
 	local t_attr = TransferRuleSetDef.Attr;
	t_attr["PassItemNum"].CurVal = value
end

function TransferItemSelectCallBack(type, id)
	edit_dirty = 1;
	local ticketIcon = getglobal("TransferRuleSetFrameBoxTicketSelectIcon");
	local banIcon 	 = getglobal("TransferRuleSetFrameBoxBanItemSelectIcon");
	local t_attr = TransferRuleSetDef.Attr
	if type == 'transferticket' then
		SetItemIcon(ticketIcon, id)
		ticketIcon:Show()
		getglobal("TransferRuleSetFrameBoxSwitch3"):Show()
		getglobal("TransferRuleSetFrameBoxTicketSelectDel"):Show()
		t_attr["PassItemID"].CurVal = id
		--t_attr["PassItemNum"].CurVal = 1
		UpdateTransferRuleSetBox()
	elseif type == 'transferban' then
		SetItemIcon(banIcon, id)
		banIcon:Show()
		getglobal("TransferRuleSetFrameBoxBanItemSelectDel"):Show()
		t_attr["ForbidItemID"].CurVal = id
	else
		return
	end

end

--删除
function TransferRuleSetFrameDelBtn_OnClick( ... )
	local desid = this:GetClientID()
	MessageBox(5, GetS(21522), function(btn)
		if btn == 'left' then
			TransferMgr:deleteTransferRecord(CurrentTransferDef.ID,desid)
			ShowGameTips(GetS(3992))
			getglobal("TransferRuleSetFrame"):Hide()
			UpdateTransferBox(CurrentTransferDef)
		else
		end
		end)
end

-------------------------------------------4.选择目标传送点-------------------------------------------------------
function ChooseTransferDestinationFrame_OnLoad( ... )
--	getglobal("ChooseTransferDestinationFrameBoxInfoIcon"..i):SetTexUV("fjxx_icon0"..(18+i))
	for i=1,6 do
		getglobal("ChooseTransferDestinationFrameBoxInfoIcon"..i):SetPoint("left", "ChooseTransferDestinationFrameBoxInfoTeam", "right", 12+40*(i-1),0)
	end
	getglobal("ChooseTransferDestinationFrameConfirmBtnText"):SetText(GetS(21527))
end

function ChooseTransferDestinationFrame_OnShow( ... )
	HideAllFrame("ChooseTransferDestinationFrame", true);

	if not getglobal("ChooseTransferDestinationFrame"):IsReshow() then
        ClientCurGame:setOperateUI(true)
    end

    local t_title = {
    	"ChooseTransferDestinationFrameBoxInfoTeam",
    	"ChooseTransferDestinationFrameBoxInfoTicket",
    	"ChooseTransferDestinationFrameBoxInfoBan",
    	"ChooseTransferDestinationFrameBoxInfoNoTicket",
    	"ChooseTransferDestinationFrameBoxInfoNoBan",
    }

    for i=1,#(t_title) do
   		local width = getglobal(t_title[i]):GetTextExtentWidth(getglobal(t_title[i]):GetText())
   		getglobal(t_title[i]):SetWidth(width)
   	end

	local iPlaneHeight = #(t_condition)*(61+10);
	iPlaneHeight = iPlaneHeight > 398 and iPlaneHeight or 398;
	getglobal("ChooseTransferDestinationFrameBoxPlane"):SetHeight(iPlaneHeight);
	getglobal("ChooseTransferDestinationFrameBoxPlane"):SetPoint("top", "ChooseTransferDestinationFrameBox", "top", 0, 0);
end

function ChooseTransferDestinationFrame_OnHide( ... )
	if not getglobal("ChooseTransferDestinationFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
	if pretransfer_idx ~=nil then
		getglobal("ChooseTransferDestinationFrameBoxD"..pretransfer_idx.."Checked"):Hide()
		pretransfer_idx = nil
	end
	getglobal("ChooseTransferDestinationFrameConfirmBtn"):SetClientID(0)
	getglobal("ChooseTransferDestinationFrameBoxInfo"):Hide()
	ShowMainFrame()
end

function ChooseTransferDestinationFrameCloseBtn_OnClick( ... )
	getglobal("ChooseTransferDestinationFrame"):Hide()
end

function TransferRuleTips( conditionDef )
	local istransfer = true
	Log("isgodmode:"..tostring(CurWorld:isGodMode()))
	if not CurWorld:isGodMode() then
		local passState,forbidState,teamState,ticketOwn,ticketNeed = TransferRuleSetDetect(conditionDef)
		local t_state = {passState,forbidState,teamState}
		Log("t_state:")
		if CurMainPlayer:getSpectatorMode() == 1 or CurMainPlayer:getSpectatorMode() == 2 then
			return true
		else
			if teamState == false then
				ShowGameTips(GetS(21489))
				istransfer = false;
				return istransfer
			end
			if passState == false then
				local itemDef = ItemDefCsv:get(conditionDef.PassItemID)
				local name = itemDef.Name
				if ticketNeed == 0 then
					ShowGameTips(GetS(21488,name,""))
				else
					ShowGameTips(GetS(21488,name,"("..ticketOwn.."/"..ticketNeed..")"))
				end
				istransfer = false
			end
			if forbidState == false then
			 	local itemDef = ItemDefCsv:get(conditionDef.ForbidItemID)
				local name = itemDef.Name
				ShowGameTips(GetS(21487,name))
				istransfer = false;
			end
		end
		
	end
	return istransfer
end

function ChooseTransferDestinationFrameConfirmBtn_OnClick( ... )
	
	local id = this:GetClientID()
	local EndDef = TransferMgr:getTransferDef(id)
	if id == nil or id == 0 then
		ShowGameTips(GetS(21491))
		return
	end
	local conditionDef = t_choosedes[pretransfer_idx]
	
	if not TransferMgr:getTransferDef(id) then
		ShowGameTips(GetS(21494))
		this:SetClientID(0)
		getglobal("ChooseTransferDestinationFrame"):Hide()
		--OpenTransferUI_C(CurrentTransferDef.ID)
		return
	end
	Log("destination id: "..tostring(id))
	if LuaInterface:band(EndDef.Status,8) == 0 then
		--local worldDesc = AccountManager:getCurWorldDesc();
		if CurWorld:isGameMakerRunMode() then
			ShowGameTips(GetS(21687,EndDef.TransferName))
			return
		end
		
	end
	

	if not TransferRuleTips(conditionDef) then
		return;
	end

	local success = TransferMgr:transferToTargetPos(CurrentTransferDef.ID, id)
	if not success then
		ShowGameTips(GetS(21494))
	else
		local text = EndDef.TransferTip
		if text == "" then
			text = GetS(21492,EndDef.TransferName)
		end
		ShowGameTips(text)
		if CurMainPlayer:getSpectatorMode() ~= 1 and CurMainPlayer:getSpectatorMode() ~= 2 then
			if conditionDef.PassItemID ~= 0 and conditionDef.PassItemNum > 0 then
				local itemDef = ItemDefCsv:get(conditionDef.PassItemID)
				if itemDef then
					ShowGameTips(GetS(21591, itemDef.Name, "X"..tostring(conditionDef.PassItemNum)))
				end
			end
		end
		
		getglobal("ChooseTransferDestinationFrame"):Hide()
	end

end

function TransferRuleSetDetect(conditionDef)
	local t_item = {}
	local passState = false
	local forbidState= true
	local teamState = true
	--local EndDef = TransferMgr:getTransferDef(id)
	--背包
	for i=1,BACK_PACK_GRID_MAX do
		local grid_index = i+BACKPACK_START_INDEX-1;
		local grid_num	 = ClientBackpack:getGridNum(grid_index)
		local itemId = ClientBackpack:getGridItem(grid_index);
		local isnew = true
		for j=1,#(t_item) do
			if t_item[j].id and t_item[j].id == itemId then
				t_item[j].num = t_item[j].num + grid_num
				isnew = false
				break;
			end
		end
		if isnew and grid_num~=0 and itemId~=0 then
			table.insert(t_item,{id=itemId,num=grid_num})
		end
	end
	--快捷栏
	for i=1,MAX_SHORTCUT do
		local grid_index = i+ClientBackpack:getShortcutStartIndex()-1;
		local grid_num	 = ClientBackpack:getGridNum(grid_index)
		local itemId = ClientBackpack:getGridItem(grid_index);
		local isnew = true
		for j=1,#(t_item) do
			if t_item[j].id and t_item[j].id == itemId then
				t_item[j].num = t_item[j].num + grid_num
				isnew = false
				break;
			end
		end
		if isnew and grid_num~=0 and itemId~=0 then
			table.insert(t_item,{id=itemId,num=grid_num})
		end
	end
	--装备
	for i=1, EQUIP_GRID_MAX do
		local grid_index = i+EQUIP_START_INDEX-1;
		local grid_num	 = ClientBackpack:getGridNum(grid_index)
		local itemId = ClientBackpack:getGridItem(grid_index);
		local isnew = true
		for j=1,#(t_item) do
			if t_item[j].id and t_item[j].id == itemId then
				t_item[j].num = t_item[j].num + grid_num
				isnew = false
				break;
			end
		end
		if isnew and grid_num~=0 and itemId~=0 then
			table.insert(t_item,{id=itemId,num=grid_num})
		end
	end

	Log("t_item....")

	local ticketOwn=0;
	local ticketNeed=conditionDef.PassItemNum;
	
	--通行物品
	if conditionDef.PassItemID ~= 0 then
		for i=1,#(t_item) do
			if t_item[i].id == conditionDef.PassItemID then
				ticketOwn = t_item[i].num;
				if conditionDef.PassItemNum == 0 or conditionDef.PassItemNum <= t_item[i].num then
					passState = true;
				end
				break;
			end
		end
	else
		passState = true
	end
	--禁止通行
	if conditionDef.ForbidItemID ~=0 then
		for i=1,#(t_item) do
			if t_item[i].id == conditionDef.ForbidItemID then
				forbidState = false;
				break;
			end
		end
	end

	--队伍
	if conditionDef.TeamColor ~= 0 then
		local myBriefInfo = ClientCurGame:getPlayerBriefInfo(-1)
		local myTeam = myBriefInfo.teamid;
		local t_team = {1,2,4,8,16,32}
		if CurMainPlayer:getSpectatorMode() == 1 or CurMainPlayer:getSpectatorMode() == 2 then
			return true,true,true,ticketOwn,ticketNeed
		elseif myBriefInfo.teamid ~= 0 and LuaInterface:band(t_team[myTeam], conditionDef.TeamColor) ~= 0 then
			teamState = false;
		end
		
	end


	return passState,forbidState,teamState,ticketOwn,ticketNeed

end

function AddAllDestination_OnClick( ... )
	local isAll = false
	if #(t_multides) < #(t_add) then
		isAll = true
	else
		isAll = false
	end


	if isAll == true then
		for i = 1, #(t_add) do
			getglobal("AddTransferDestinationFrameBoxD"..i.."Checked"):Show()
			local idx = getglobal("AddTransferDestinationFrameBoxD"..i):GetClientID()
			table.insert(t_multides,{id = t_add[idx].id, name = t_add[idx].name})
		end
	else
		t_multides = {}
		for i = 1, #(t_add) do
			getglobal("AddTransferDestinationFrameBoxD"..i.."Checked"):Hide()
		end
	end
end