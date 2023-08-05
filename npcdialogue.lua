
local MaxInteractNum = 12;
local t_InteractListData = {};
local t_CurInteractData = nil;
local OpenDialogueByItemID = 0;
local t_OpenDialogueByItemPos = {x=0,y=0,z=0}
local t_NpcDialogueFunction = {};
local t_SpecialConvertDialogueStrFunc = nil;

function registeredNpcDialogueFunction(funcName, fun)
	if type(funcName) == "string" and type(fun) == "function" then
		t_NpcDialogueFunction[funcName] = fun
	end
end

function getNpcDialogueFunctionByName(funcName)
	if type(funcName) == "string" then
		return t_NpcDialogueFunction[funcName]
	end
end

function setNpcSpecialConvertDialogueStrFunc(fun)
	t_SpecialConvertDialogueStrFunc = fun
end

function SpecialConvertDialogueStr(str)
	if type(t_SpecialConvertDialogueStrFunc) == "function" then
		return t_SpecialConvertDialogueStrFunc(str)
	end
	return str
end

function ConvertDialogueStr(src)
	--需要特殊处理的字符串
	src = SpecialConvertDialogueStr(src)

	if string.sub(src, 1, 1) == "@" then --第一个字符是@
		local stringId = tonumber(string.sub(src,2, -1));
		if stringId and type(stringId) == 'number' then
			return GetS(stringId);
		end
	end

	return src;
end

function getCurDialogueIndexByID(id)
	if not t_CurInteractData then return 0; end

	for i=1, #t_CurInteractData.dialogues do
		if t_CurInteractData.dialogues[i].def.ID == id then
			return i;
		end
	end

	return 0;
end

function NpcDialogueFrameCloseBtn_OnClick()
	NpcDialogueFrame_StandReportEvent("PLOT_INTERACT_POPUP", "Close", "click")--新埋点

    getglobal("NpcDialogueFrame"):Hide();
    
    if getglobal("NpcDialogueFrame"):GetClientString() == "HOMELAND_NPC_HACIENDA" then
        standReportEvent("623", "MINI_MY_HOMELAND_FARM_NPC_CHAT", "Close", "click")   
    elseif getglobal("NpcDialogueFrame"):GetClientString() == "HOMELAND_NPC_RANCH" then
        standReportEvent("624", "MINI_MY_HOMELAND_RANCH_NPC_CHAT", "Close", "click")  
    elseif getglobal("NpcDialogueFrame"):GetClientString() == "HOMELAND_NPC_COOK" then
        standReportEvent("625", "MINI_MY_HOMELAND_COOKING_NPC_CHAT", "Close", "click")   
    elseif getglobal("NpcDialogueFrame"):GetClientString() == "HOMELAND_NPC_SMITH" then
        standReportEvent("632", "MINI_MY_HOMELAND_CRAFTMAN_NPC_CHAT", "Close", "click")
    end
end

function NpcDialogueFrameTextFrame_OnClick()
	if getglobal("NpcDialogueFrameTextFrameArrow"):IsShown() then
		t_CurInteractData.curDialogueIndex = t_CurInteractData.curDialogueIndex + 1;
		print("NpcInteractAnswerOnClick curDialogueIndex:", t_CurInteractData.curDialogueIndex);
		if t_CurInteractData.dialogues[t_CurInteractData.curDialogueIndex] then --继续还有对话
			UpdateInteractFrame();
		else
			getglobal("NpcDialogueFrame"):Hide();		
		end
	end
end

function NpcInteractAnswerOnClick(answerDef)
	print("NpcInteractAnswerOnClick FuncType:", answerDef.FuncType);
	if answerDef.FuncType == ANSWER_CONTINUE then
		t_CurInteractData.curDialogueIndex = t_CurInteractData.curDialogueIndex + 1;
		print("NpcInteractAnswerOnClick curDialogueIndex:", t_CurInteractData.curDialogueIndex);
		if t_CurInteractData.dialogues[t_CurInteractData.curDialogueIndex] then --继续还有对话
			UpdateInteractFrame();
		else
			getglobal("NpcDialogueFrame"):Hide();		
		end
	elseif answerDef.FuncType == ANSWER_SKIP then
		t_CurInteractData.curDialogueIndex = getCurDialogueIndexByID(answerDef.Val);
		if t_CurInteractData.dialogues[t_CurInteractData.curDialogueIndex] then --跳转到这个对话
			UpdateInteractFrame();
		else
			getglobal("NpcDialogueFrame"):Hide();		
		end
	elseif answerDef.FuncType == ANSWER_STOP then
		getglobal("NpcDialogueFrame"):Hide();
	elseif answerDef.FuncType == ANSWER_TASK then
		local taskDef = DefMgr:getNpcTaskDef(answerDef.Val);
		if taskDef and taskDef.UseInteract then
			NpcTaskFrame_AcceptTask(answerDef.Val, t_CurInteractData.def.ID);
		else
			AcceptTask(answerDef.Val, t_CurInteractData.def.ID);
		end
	elseif answerDef.FuncType == ANSWER_COMPLETE_TASK then	--交任务
		if t_CurInteractData.def.UseInteract then
			NpcTaskFrame_DeliverTask(t_CurInteractData.def.ID);
		else
			CompleteTask(t_CurInteractData.def.ID); --完成任务
		end
	elseif answerDef.FuncType == ANSWER_SCRIPT then --调用脚本函数
		local functionStr = answerDef.ScriptName or ""
		local fun =getNpcDialogueFunctionByName(functionStr)
		if fun and type(fun) == "function" then
			fun()
		end
	end
end

function CompleteTask(taskid)
	CurMainPlayer:completeTask(t_CurInteractData.def.ID); --完成任务
	getglobal("NpcDialogueFrame"):Hide();
end

function AcceptTask(taskid, plotid)
	CurMainPlayer:addTask(taskid, plotid);	--接任务
	local def = DefMgr:getNpcTaskDef(taskid);
	if def then
		if def.ShowInNote then
			ShowGameTips(GetS(11205), 3);
		end
		UpdateCurInteractData(TASK_INTERACT, def, 0); --接任务后的对话
		UpdateInteractFrame();
	else
		getglobal("NpcDialogueFrame"):Hide();
	end
end

function UpdateCurInteractData(type, def, taskstate)
	print("kekeke UpdateCurInteractData", type, taskstate, def.ID);

	t_CurInteractData = {};

	local dialogueNum = 0;
	if type == PLOT_INTERACT or type == DIRECT_INTERACT then
		dialogueNum = DefMgr:getDialogueNum(type, def.ID);
	elseif type == TASK_INTERACT then
		dialogueNum = DefMgr:getDialogueNum(type, def.ID, taskstate);
	end
	local t_dialogue = {};
	for i=1, dialogueNum do
		local dialogueDef = DefMgr:getDialogueDef(type, def.ID, i-1, taskstate);
		if dialogueDef then
			local t_answer = {};
			for j=1, 4 do
				local answerDef = DefMgr:getAnswerDefByDialogue(dialogueDef, j-1);
				if answerDef and answerDef.Text and answerDef.Text ~= "" then
					table.insert(t_answer, answerDef);
				end
			end	
			table.insert(t_dialogue, {answers=t_answer, def=dialogueDef});
		end
	end

	t_CurInteractData = {curDialogueIndex=1, type=type, def=def, dialogues=t_dialogue};

	print("kekeke t_CurInteractData", t_CurInteractData);
end

function NpcInteractBtnTemplate_OnClick()
	if not CurMainPlayer then return end

	if not t_CurInteractData then	--选择交互的选项
		print("NpcInteractBtnTemplate_OnClick Interact")
		local index = this:GetClientID();
		if t_InteractListData[index] then
			print("NpcInteractBtnTemplate_OnClick Interact InteractionType", t_InteractListData[index].InteractionType);
			if t_InteractListData[index].InteractionType == PLOT_INTERACT then	--剧情
				local type = TASK_INTERACT;
				local taskId = 0;
				local def=nil;
				def,taskId = CurMainPlayer:getTaskInfoByPlot(t_InteractListData[index].ID, taskId);

				if def then
					def = DefMgr:getNpcTaskDef(taskId);
				end
				if not def then
					def = DefMgr:getNpcPlotDef(t_InteractListData[index].ID);
					type = PLOT_INTERACT;
				end
				if def then
					UpdateCurInteractData(type, def, 0);
					UpdateInteractFrame();
				end
			elseif t_InteractListData[index].InteractionType == TASK_INTERACT then	--交任务
				if CurMainPlayer then
					--CurMainPlayer:updateTask(COMPLETE_TASK, t_InteractListData[index].ID, 0);
					local def = DefMgr:getNpcTaskDef(t_InteractListData[index].ID);
					if def then
						local state = CurMainPlayer:getTaskState(t_InteractListData[index].ID) == 1 and 2 or 1;
						UpdateCurInteractData(TASK_INTERACT, def, state);	--已完成的任务对话
						UpdateInteractFrame();	
					end
				end
			elseif t_InteractListData[index].InteractionType == EXIT_INTERACT then	--离开
				getglobal("NpcDialogueFrame"):Hide();
				NpcDialogueFrame_StandReportEvent("PLOT_INTERACT_POPUP", "LeaveOption", "click")--新埋点
			elseif t_InteractListData[index].InteractionType == STORE_INTERACT then --商店
				CurMainPlayer:reqGetNpcShopInfo(t_InteractListData[index].ID);
			elseif t_InteractListData[index].InteractionType == DSTORE_INTERACT then
				if not CurWorld:isGameMakerMode() then
					if OpenedDialogueMob then
						local monsterDef = OpenedDialogueMob:getMonsterDef();
						if monsterDef then
							local config = monsterDef.OpenStoreConfig or ""
							ShowDeveloperStoreTab(config)
						else
							ShowDeveloperStore() --打开开发者商店
						end
					else
						ShowDeveloperStore() --打开开发者商店
					end
					-- ShowDeveloperStore() --打开开发者商店
					NpcDialogueFrame_StandReportEvent("PLOT_INTERACT_POPUP", "DevShopOption", "click")--新埋点
				else
					ShowGameTips(GetS(301119), 3)
				end
			elseif t_InteractListData[index].InteractionType == DIRECT_INTERACT then --表格配置直接生效的对话
				local def = t_InteractListData[index].def;
				if def then
					UpdateCurInteractData(DIRECT_INTERACT, def, 0);
					UpdateInteractFrame();
				end
			end
		end
	else 						--选择回答对话的选项
		print("NpcInteractBtnTemplate_OnClick Answer")
		local index = this:GetClientID();
		
		local t_answer = t_CurInteractData.dialogues[t_CurInteractData.curDialogueIndex].answers;
		if t_answer[index] then
			NpcInteractAnswerOnClick(t_answer[index]);
		end
	end
end

function NpcDialogueFrame_OnLoad()
	for i=1, MaxInteractNum do
		local interact = getglobal("NpcInteractBoxInteract"..i);
		interact:SetPoint("top", "NpcInteractBoxPlane", "top", 0, (i-1)*63);
	end

	for i=1, 4 do
		local answer = getglobal("NpcDialogueFrameInteractFrameBtn"..i);
		answer:SetPoint("top", "NpcDialogueFrameInteractFrame", "top", 0, (i-1)*63+8);

		local desc = getglobal("NpcDialogueFrameInteractFrameBtn"..i.."Desc");
		desc:SetPoint("left", "NpcDialogueFrameInteractFrameBtn"..i.."Icon", "left", 0, 0);
	end

	this:RegisterEvent("GIE_OPEN_DIALOGUE");
	this:RegisterEvent("GIE_CLOSE_DIALOGUE");

	registeredNpcDialogueFunction("openStarDescView", function ()
		OnBlockStarStationConsoleTrigger(true)
		local  answerDef = {FuncType = ANSWER_STOP}
		NpcInteractAnswerOnClick(answerDef)    
	end)

    registeredNpcDialogueFunction("ResetRevivePoint", function (callBack)
        local res = ClientCurGame:getMainPlayer():IsInteractSpBlockValid()
        if res then
            local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO)
            if starNum < Revive_Need_Star then
                if CurWorld and CurWorld:isGameMakerMode() then
                    ClientCurGame:getMainPlayer():ResetRevivePoint() 
                    local  answerDef = {FuncType = ANSWER_CONTINUE}
                    NpcInteractAnswerOnClick(answerDef)            
                else
                    local needNum = Revive_Need_Star - starNum;
                    local lackNum = math.ceil(needNum/MiniCoin_Star_Ratio)
                    local text = GetS(466, needNum, lackNum);
                    StoreMsgBox(5, text, GetS(469), -2, lackNum, Revive_Need_Star);
                    getglobal("StoreMsgboxFrame"):SetClientString( "设置复活点星星不足" );
                end
            else
                ClientCurGame:getMainPlayer():ResetRevivePoint() 
                local  answerDef = {FuncType = ANSWER_CONTINUE}
                NpcInteractAnswerOnClick(answerDef)
            end
        else
            ShowGameTipsWithoutFilter(GetS(85007), 3)
        end
	end)
	registeredNpcDialogueFunction("switchStarstationSignPoint", SwitchStarstationSignPoint);
    registeredNpcDialogueFunction("starStationSendChatMsg", StarStationSendChatMsg)
    RegisterHomeLandNpcDialogueFunc();
  
end

function RegisterHomeLandNpcDialogueFunc()
	--农场
	registeredNpcDialogueFunction("openFarmStore",OpenFarmStore)
	registeredNpcDialogueFunction("openProcessingManure",OpenProcessingManure)
	registeredNpcDialogueFunction("openExpandFarm", OpenExpandFarm)
	--牧场
	registeredNpcDialogueFunction("openRanchStore", OpenRanchStore)
	registeredNpcDialogueFunction("openExpandRanch", OpenExpandRanch)
	registeredNpcDialogueFunction("openProcessingFodder", OpenProcessingFodder)
	
	--厨房
	registeredNpcDialogueFunction("openCookStore", OpenCookStore)
	registeredNpcDialogueFunction("openCooking", OpenCooking)
	registeredNpcDialogueFunction("openMenuStore", OpenMenuStore)
    --工匠
    registeredNpcDialogueFunction("openMaking", OpenMaking)
    registeredNpcDialogueFunction("openMaterialStore", openMaterialStore)
    registeredNpcDialogueFunction("openDismantle", openDismantle)
    registeredNpcDialogueFunction("openGratiaFurniture", openGratiaFurniture)
end

--打开农场商店
function OpenFarmStore()
	local ctr = GetInst("UIManager"):GetCtrl("HomeMain")
	ctr:OpenFarmStore()
    getglobal("NpcDialogueFrame"):Hide();

    standReportEvent("623", "MINI_MY_HOMELAND_FARM_NPC_CHAT", "FarmShop", "click")   
end

--肥料
function OpenProcessingManure()
	local ctr = GetInst("UIManager"):GetCtrl("HomeMain")
	ctr:OpenProcessingManure()
    getglobal("NpcDialogueFrame"):Hide();
    
    standReportEvent("623", "MINI_MY_HOMELAND_FARM_NPC_CHAT", "ManureMaking", "click")   
end
--肥料
function OpenProcessingFodder()
	local ctr = GetInst("UIManager"):GetCtrl("HomeMain")
	ctr:OpenProcessingFodder()
    getglobal("NpcDialogueFrame"):Hide();
    
    standReportEvent("624", "MINI_MY_HOMELAND_RANCH_NPC_CHAT", "FodderMaking", "click")   
end

--开垦耕地
function OpenExpandFarm()
	HomeLandFarmOpen()
    getglobal("NpcDialogueFrame"):Hide();
    
    standReportEvent("623", "MINI_MY_HOMELAND_FARM_NPC_CHAT", "FarmAmountUp", "click")   
end

--牧场商店
function OpenRanchStore()
	local ctr = GetInst("UIManager"):GetCtrl("HomeMain")
	ctr:OpenRanchStore();
    getglobal("NpcDialogueFrame"):Hide();
    
    standReportEvent("624", "MINI_MY_HOMELAND_RANCH_NPC_CHAT", "RanchShop", "click")   
end

--扩建牧场
function OpenExpandRanch()
	HomeLandRanchOpen()
    getglobal("NpcDialogueFrame"):Hide();
    
    standReportEvent("624", "MINI_MY_HOMELAND_RANCH_NPC_CHAT", "BreedingLevelUp", "click")   
end

--打开厨房
function OpenCookStore()
	local ctr = GetInst("UIManager"):GetCtrl("HomeMain")
    ctr:OpenCookStore();
    getglobal("NpcDialogueFrame"):Hide();
    standReportEvent("625", "MINI_MY_HOMELAND_COOKING_NPC_CHAT", "CookingShop", "click")   
end

function OpenMenuStore()
	local ctr = GetInst("UIManager"):GetCtrl("HomeMain")
    ctr:OpenMenuStore();
    getglobal("NpcDialogueFrame"):Hide();
	standReportEvent("625", "MINI_MY_HOMELAND_COOKING_NPC_CHAT", "DailyMenu", "click")  
end

--食材合成
function OpenCooking()
	local ctr = GetInst("UIManager"):GetCtrl("HomeMain")
	ctr:OpenCooking();
	getglobal("NpcDialogueFrame"):Hide();
end

--工匠制作
function  OpenMaking()
	local ctr = GetInst("UIManager"):GetCtrl("HomeMain")
	ctr:OpenMaking();
	getglobal("NpcDialogueFrame"):Hide();
end

--工匠商店
function openMaterialStore()
	local ctr = GetInst("UIManager"):GetCtrl("HomeMain")
	ctr:openMaterialStore();
    getglobal("NpcDialogueFrame"):Hide();
    standReportEvent("632", "MINI_MY_HOMELAND_CRAFTMAN_NPC_CHAT", "CraftShop", "click")
end

--家具拆解
function openDismantle()
    GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/common_comp", "miniui/miniworld/c_miniwork", "miniui/miniworld/c_shop"})

    GetInst("MiniUIManager"):OpenUI("main_disassemble", "miniui/miniworld/homechest", "MiniUIFurnitureMain", {})
    getglobal("NpcDialogueFrame"):Hide()
    standReportEvent("632", "MINI_MY_HOMELAND_CRAFTMAN_NPC_CHAT", "Dismantle", "click")
end

--特惠家具
function openGratiaFurniture()
    GetInst("MiniUIManager"):AddPackage({"miniui/miniworld/common", "miniui/miniworld/common_comp", "miniui/miniworld/c_miniwork", "miniui/miniworld/c_shop"})

    GetInst("MiniUIManager"):OpenUI("main_spcialfurniture", "miniui/miniworld/homechest", "MiniUISpecialFurnitureMain", {})
    getglobal("NpcDialogueFrame"):Hide()
    standReportEvent("632", "MINI_MY_HOMELAND_CRAFTMAN_NPC_CHAT", "GratiaFurniture", "click")
end

function NpcDialogueFrame_OnEvent()
	if arg1 == "GIE_OPEN_DIALOGUE" then
		local ge = GameEventQue:getCurEvent();
		OpenDialogueByItemID = ge.body.opendialogueinfo.itemid;
		t_OpenDialogueByItemPos.x = ge.body.opendialogueinfo.x;
		t_OpenDialogueByItemPos.y = ge.body.opendialogueinfo.y;
		t_OpenDialogueByItemPos.z = ge.body.opendialogueinfo.z;

		--星站控制台特殊处理文字
		if OpenDialogueByItemID == 594 then
			setNpcSpecialConvertDialogueStrFunc(StarStationConvertDialogueStr)
		end
		UpdateNpcDialogueFrame();
	elseif arg1 == "GIE_CLOSE_DIALOGUE" then
		getglobal("NpcDialogueFrame"):Hide();
	end
end

function HomeLandShowNpcDialogueFrame(id)
	OpenDialogueByItemID = id
	CurMainPlayer:setCurInteractPlotType(1)
	UpdateNpcDialogueFrame()
end

function GetOpenDialogueByItemID()
	return OpenDialogueByItemID
end

function SetOpenDialogueByItemID(id)
	OpenDialogueByItemID = id
end

function UpdateNpcDialogueFrame()
	if not OpenedDialogueMob and OpenDialogueByItemID == 0 then 
		getglobal("NpcDialogueFrame"):Hide();
		return
	end

	if not InitNpcDialogueFrame() then
		getglobal("NpcDialogueFrame"):Hide();
	else
		getglobal("NpcDialogueFrame"):Show();
	end
 
end

function ShowNpcFrame(bShow)
    if CurWorld and CurWorld:getActorMgr() then
        --判断OpenedDialogueHomeNpc是否析构
        if OpenedDialogueHomeNpc and CurWorld:getActorMgr():isActorExist(OpenedDialogueHomeNpc) and OpenedDialogueHomeNpc.getDefID and OpenedDialogueHomeNpc:getDefID() == OpenDialogueByItemID
        and OpenedDialogueHomeNpc.setShowNpcFrame then
            OpenedDialogueHomeNpc:setShowNpcFrame(bShow)
            
            if not bShow then
                OpenedDialogueHomeNpc = nil
            end
        end
    end
end

function NpcDialogueFrame_OnShow()
    PlayMainFrameUIHide()
	--HideAllFrame("NpcDialogueFrame", true);
	
	if not getglobal("NpcDialogueFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
		--新埋点
		NpcDialogueFrame_StandReportEvent("PLOT_INTERACT_POPUP", "-", "view")
		NpcDialogueFrame_StandReportEvent("PLOT_INTERACT_POPUP", "Close", "view")
    end
    ShowNpcFrame(true)
end

function JoinOnlyInteract()
	print("kekeke JoinOnlyInteract InteractionType:", t_InteractListData[1].InteractionType);
	if not CurMainPlayer then return; end

	if t_InteractListData[1].InteractionType == PLOT_INTERACT then	--剧情
		local type = TASK_INTERACT;
		local taskId = 0;
		local def=nil;
		def,taskId = CurMainPlayer:getTaskInfoByPlot(t_InteractListData[1].ID, taskId);
	
		if def then
			def = DefMgr:getNpcTaskDef(taskId);
		end
		
		if not def then
			def = DefMgr:getNpcPlotDef(t_InteractListData[1].ID);
			type = PLOT_INTERACT;
		end
		if def then
			UpdateCurInteractData(type, def, 0);
			UpdateInteractFrame();
		end
	elseif t_InteractListData[1].InteractionType == TASK_INTERACT then	--交任务
		local def = DefMgr:getNpcTaskDef(t_InteractListData[1].ID);
		if def then
			local state = CurMainPlayer:getTaskState(t_InteractListData[1].ID) == 1 and 2 or 1;
			UpdateCurInteractData(TASK_INTERACT, def, state);	--已完成的任务对话
			UpdateInteractFrame();	
		end

	elseif t_InteractListData[1] and t_InteractListData[1].InteractionType == DIRECT_INTERACT then --表格配置直接生效的对话
		local def = t_InteractListData[1].def;
		if def then
			UpdateCurInteractData(DIRECT_INTERACT, def, 0);
			UpdateInteractFrame();
		end
	end
end

function InitNpcDialogueFrame()
	t_CurInteractData = nil;

	getglobal("NpcInteractBox"):resetOffsetPos();

	if OpenedDialogueMob then
		local monsterDef = OpenedDialogueMob:getMonsterDef();
		if monsterDef then
			--getglobal("NpcDialogueFrameTextFrameTitle"):SetText(monsterDef.Name);
			local filteredMonsterName = DefMgr:filterString(monsterDef.Name)
			getglobal("NpcDialogueFrameTextFrameTitle"):SetText(filteredMonsterName)
		end
	else
        local itemDef = ItemDefCsv:get(OpenDialogueByItemID) or MonsterCsv:get(OpenDialogueByItemID);
    
		if itemDef then
			--getglobal("NpcDialogueFrameTextFrameTitle"):SetText(itemDef.Name);
			local filteredItemName = DefMgr:filterString(itemDef.Name)
			getglobal("NpcDialogueFrameTextFrameTitle"):SetText(filteredItemName)
		end
	end

	LoadNpcInteractData();
	if #t_InteractListData > 2 then	--包括离开选项有两个以上的互动 打开选择互动列表
		UpdateInteractListFrame();
	elseif #t_InteractListData == 2 then --直接进入仅有的互动项
		JoinOnlyInteract();
		if t_InteractListData[1].InteractionType == STORE_INTERACT then   --商店
			--只有一个商店，需要关闭NPC对话框
			CurMainPlayer:reqGetNpcShopInfo(t_InteractListData[1].ID);
			UpdateInteractFrame();
			return false;
		elseif t_InteractListData[1].InteractionType == DSTORE_INTERACT then   --开发者商店
			--打开开发者商店，需要关闭NPC对话框
			if not CurWorld:isGameMakerMode() then
				if OpenedDialogueMob then
					local monsterDef = OpenedDialogueMob:getMonsterDef();
					if monsterDef then
						local config = monsterDef.OpenStoreConfig or ""
						ShowDeveloperStoreTab(config)
					else
						ShowDeveloperStore() --打开开发者商店
					end
				else
					ShowDeveloperStore() --打开开发者商店
				end
			end
			return false;
		end
	else
		return false;
	end

	return true;
end

function NpcDialogueFrame_OnHide()
	ShowMainFrame();
	CurMainPlayer:closePlotDialogue();
	if not getglobal("NpcDialogueFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
    setNpcSpecialConvertDialogueStrFunc(nil)
    ShowNpcFrame(false)
end

function AddInteractByItemSkill(skillfuncDef, t, index)
	if not CurMainPlayer then return end

	local funcDef = skillfuncDef:getSkillFunction(index);
	if funcDef then
		if funcDef.oper_id == 10 then
			table.insert(t, {InteractionType=funcDef.func.interactfun.type, ID=funcDef.func.interactfun.id})
			--[[
			if CurMainPlayer:canShowInteract(funcDef.function.interactfun.type, funcDef.function.interactfun.id, true) then
				table.insert(t, {InteractionType=funcDef.function.interactfun.type, ID=funcDef.function.interactfun.id})
			elseif funcDef.interactfun.type == PLOT_INTERACT then
				ShowGameTips(GetS(1355), 3);
			end
			]]
		end
	end
end

function LoadNpcInteractData()
	t_InteractListData = {};
	if not LoadNpcInteractDefData() then
		if OpenedDialogueMob then
			local interactNum = 0 --剧情交互的数量
			local num = OpenedDialogueMob:getInteractNum();
			for i=1, num do
				local interactDef = OpenedDialogueMob:getInteractDef(i-1);
				if interactDef and interactDef.Show then
					table.insert(t_InteractListData, interactDef);
 					if interactDef.InteractionType == PLOT_INTERACT then
						interactNum = interactNum + 1
					end
				end
			end

			local can_opendev = OpenedDialogueMob:getCanOpenDevStore()
			if can_opendev then --开发者商店选项
				table.insert(t_InteractListData, 1, {InteractionType=DSTORE_INTERACT})
			end
		else
			local itemDef = ItemDefCsv:get(OpenDialogueByItemID) or MonsterCsv:get(OpenDialogueByItemID);
			if not itemDef then return end

			local skillidNum = itemDef.getSkinIDNum and itemDef:getSkinIDNum() or 0;
			for i=1, skillidNum do
				local skillfuncDef = ItemSkillDefCsv:get(itemDef:getSkinID(i-1));
				if skillfuncDef then
					local funcNum = skillfuncDef:getSkillFunctionNum();
					for j=1, funcNum do
						AddInteractByItemSkill(skillfuncDef, t_InteractListData, j-1);
					end
				end
			end
		end
	end

	table.insert(t_InteractListData, {InteractionType=EXIT_INTERACT}) --离开交互

	local height = 264;
	if #t_InteractListData > 4 then
		height = 264 + (#t_InteractListData - 4) *63;
	end

	getglobal("NpcInteractBoxPlane"):SetHeight(height);

	print("kekeke LoadNpcInteractListData:", t_InteractListData, #t_InteractListData);
end

--npcplotdef.csv直接配置的对话
function LoadNpcInteractDefData()
	if not CurMainPlayer then return false end

	local interactPlotType = CurMainPlayer:getCurInteractPlotType()
	local num = DefMgr:getNpcPlotConfigurableDefNum()

	for i = 1, num do
		local curdef = DefMgr:getNpcPlotConfigurableDefByIndex(i-1)
		if curdef and curdef.InteractID == OpenDialogueByItemID and curdef.InteractType == interactPlotType then
			table.insert(t_InteractListData,{InteractionType=DIRECT_INTERACT, ID=OpenDialogueByItemID, def=curdef})
		end
	end
	return false
end

function UpdateInteractListFrame()
	getglobal("NpcDialogueFrameInteractListFrame"):Show();
	getglobal("NpcDialogueFrameInteractFrame"):Hide();


	getglobal("NpcDialogueFrameTextFrameText"):SetText("");
	if OpenedDialogueMob then
		local monsterDef = OpenedDialogueMob:getMonsterDef();
		if monsterDef then
			local text = ConvertDialogueStr(monsterDef.Dialogue);
			text = DefMgr:filterString(text);
			getglobal("NpcDialogueFrameTextFrameText"):SetText(text);
		end
	end

	getglobal("NpcDialogueFrameTextFrameArrow"):Hide();

	local index = 1;
	local num = #t_InteractListData;
	for i=1, MaxInteractNum do
		if not HasUIFrame("NpcInteractBoxInteract"..index) then
			break;
		end

		if i <= num then
			local interact 	= getglobal("NpcInteractBoxInteract"..index);
			local icon 		= getglobal("NpcInteractBoxInteract"..index.."Icon");
			local desc 		= getglobal("NpcInteractBoxInteract"..index.."Desc");

			interact:Show();
			icon:Show();
			icon:SetTextureHuiresXml("ui/mobile/texture0/operate.xml");
			--desc:SetPoint("left", icon:GetName(), "right", 10, 0);
			if t_InteractListData[i].InteractionType == PLOT_INTERACT then --剧情
				local taskId = 0;
				local def = CurMainPlayer:getTaskInfoByPlot(t_InteractListData[i].ID, taskId);
				if def then	--已经接了任务
					icon:SetTexUV("npchat_icon_juqing_d");
				else
					icon:SetTexUV("npchat_icon_juqing");
				end
				local plotDef = DefMgr:getNpcPlotDef(t_InteractListData[i].ID);
				if plotDef then
					print("kekeke Name:", plotDef.Icon, plotDef.ID, plotDef.Name);
					local text = ConvertDialogueStr(plotDef.Name);
					desc:SetText(text);
				end
			elseif t_InteractListData[i].InteractionType == TASK_INTERACT then --任务
				local def = CurMainPlayer:getTaskInfo(t_InteractListData[i].ID);
				if def and def.state == TASK_CAN_COMPLETE then --任务可完成
					icon:SetTexUV("npchat_icon_jrw");
				else
					icon:SetTexUV("npchat_icon_jrw_d");
				end
				local taskDef = DefMgr:getNpcTaskDef(t_InteractListData[i].ID);
				if taskDef then
					local text = ConvertDialogueStr(taskDef.Name);
					text = DefMgr:filterString(text);
					desc:SetText(text);
				end
			elseif t_InteractListData[i].InteractionType == STORE_INTERACT then --商店
				local def = DefMgr:getNpcShopDef(t_InteractListData[i].ID);
				desc:SetText(def.sShopName);
				icon:SetTexUV("npcshop_icon");
			elseif t_InteractListData[i].InteractionType == DSTORE_INTERACT then --开发者商店
				local nickname = nil
				if IsRoomClient() then --客机
					-- 判断g_ScreenshotShareRoomDesc为空的情况 客户端连云服的情况 by huanglin
					if g_ScreenshotShareRoomDesc and g_ScreenshotShareRoomDesc.realNickName then
						nickname = g_ScreenshotShareRoomDesc.realNickName
					else
						local map = mapservice.mapInfoCache[G_GetFromMapid()];
						if map then
							nickname = map.author_name
						else
							nickname = nil
						end
					end
				else --主机或者单机
					nickname = AccountManager:getCurWorldDesc().realNickName
				end
				if not nickname then nickname = GetS(23001) end
				
				desc:SetText(GetS(21658, nickname));
				icon:SetTextureHuiresXml("ui/mobile/texture2/minilobby.xml");
				icon:SetTexUV("icon_shop_hall.png");
   				NpcDialogueFrame_StandReportEvent("PLOT_INTERACT_POPUP", "DevShopOption", "view")--新埋点
			elseif t_InteractListData[i].InteractionType == DIRECT_INTERACT then --表格配置直接生效的对话
				local plotDef = t_InteractListData[i].def;
				if plotDef then
					print("kekeke Name:", plotDef.Icon, plotDef.ID, plotDef.Name);
					local text = ConvertDialogueStr(plotDef.Name);
					desc:SetText(text);
				end
			else 												--离开
				--icon:Hide();
				icon:SetTexUV("icon_track");
				--desc:SetPoint("left", icon:GetName(), "left", 0, 0);
				desc:SetText(GetS(8041));
				NpcDialogueFrame_StandReportEvent("PLOT_INTERACT_POPUP", "LeaveOption", "view")--新埋点
			end


			index = index + 1;
		end
	end

	for i=index, MaxInteractNum do
		getglobal("NpcInteractBoxInteract"..i):Hide();
	end

	if num <= 4 then
		getglobal("NpcInteractBox"):setDealMsg(false);
		getglobal("NpcDialogueFrameInteractListFrame"):SetHeight(11+num*63);
	else
		getglobal("NpcInteractBox"):setDealMsg(true);
		getglobal("NpcDialogueFrameInteractListFrame"):SetHeight(280);
	end
end

function UpdateInteractFrame()	
	getglobal("NpcDialogueFrameInteractListFrame"):Hide();

	if not t_CurInteractData then
		getglobal("NpcDialogueFrameInteractFrame"):Hide();
		return
	end	

	local curIndex = t_CurInteractData.curDialogueIndex;
	print("kekeke UpdateInteractFrame curIndex:", curIndex);
	if t_CurInteractData.dialogues[curIndex] and t_CurInteractData.dialogues[curIndex].def then
		local text = ConvertDialogueStr(t_CurInteractData.dialogues[curIndex].def.Text);
		text = DefMgr:filterString(text);
		getglobal("NpcDialogueFrameTextFrameText"):SetText(text);
	else
		getglobal("NpcDialogueFrameTextFrameText"):SetText("");
	end

	if t_CurInteractData.dialogues[curIndex] and #t_CurInteractData.dialogues[curIndex].answers > 0 then --剧情有对话
		getglobal("NpcDialogueFrameTextFrameArrow"):Hide();
		getglobal("NpcDialogueFrameInteractFrame"):Show();		

		

		print("kekeke t_CurInteractData.dialogues:", t_CurInteractData.dialogues[curIndex])

		local num = #t_CurInteractData.dialogues[curIndex].answers 
		for i=1, 4 do
			local answer = getglobal("NpcDialogueFrameInteractFrameBtn"..i);
			if i <= num then
				local t = t_CurInteractData.dialogues[curIndex].answers[i];
				print("kekeke t_CurInteractData.dialogues answers t:", t, i);
				answer:Show();
				local icon 		= getglobal("NpcDialogueFrameInteractFrameBtn"..i.."Icon");
				local desc 		= getglobal("NpcDialogueFrameInteractFrameBtn"..i.."Desc");

				icon:Hide();
				local text = ConvertDialogueStr(t.Text);
				text = DefMgr:filterString(text);
				desc:SetText(text);
			else
				answer:Hide();
			end
		end

		num = num <= 4 and num or 4;
		getglobal("NpcDialogueFrameInteractFrame"):SetHeight(11+num*63);
	else
		getglobal("NpcDialogueFrameTextFrameArrow"):Show();
		getglobal("NpcDialogueFrameInteractFrame"):Hide();
	end
end

--事件上报代理，推荐页的上报都走这,方便统一管理(埋点)
function NpcDialogueFrame_StandReportEvent(cID,oID,event,eventTb)
	local sceneID = "";--统一ID
	if IsRoomOwner() or AccountManager:getMultiPlayer() == 0 then--主机
		sceneID = "1003";
	else--客机
		sceneID = "1001";
	end
	standReportEvent(sceneID,cID,oID,event,eventTb)
end

--星站控制台特殊处理文字
function StarStationConvertDialogueStr(str)
	if not (StarStationTransferMgr.getStarStationID and StarStationTransferMgr.getStarStationDef) then
		return str;
	end
	local convertStrTab = nil;
	local stringId = 0;
	local id = StarStationTransferMgr:getStarStationID(t_OpenDialogueByItemPos.x, t_OpenDialogueByItemPos.y, t_OpenDialogueByItemPos.z);
	local def = StarStationTransferMgr:getStarStationDef(id);
	if def then
		convertStrTab = {
			[1] = {id=85015, arry={}},
			[2] = {id=85020, arry={}},
			[3] = {id=85022, arry={}},
		};

		if def.isActive then
			table.insert(convertStrTab[1].arry, "@85016");
		else
			table.insert(convertStrTab[1].arry, "@85017");
		end
		if def.getCabinCount then
			local num = def:getCabinCount();
			table.insert(convertStrTab[1].arry, num);
		end

		if def.isSign then
			table.insert(convertStrTab[1].arry, "@85018");
			table.insert(convertStrTab[2].arry, "@85019");
			table.insert(convertStrTab[3].arry, "@85018");
		else
			table.insert(convertStrTab[1].arry, "@85019");
			table.insert(convertStrTab[2].arry, "@85018");
			table.insert(convertStrTab[3].arry, "@85019");
		end


		if string.sub(str, 1, 1) == "@" then --第一个字符是@
			stringId = tonumber(string.sub(str,2, -1));
			if not (stringId and type(stringId) == 'number') then
				stringId = 0 return GetS(stringId);
			end
		end

		for k, v in pairs(convertStrTab) do
			if v.id == stringId then
				str = GetS(stringId);
				for i = 1, #v.arry do
					local tmpStr = "";
					if type(v.arry[i]) == "string" and string.sub(v.arry[i], 1, 1) == "@" then
						tmpStr = GetS(tonumber(string.sub(v.arry[i],2, -1))) or "";
					else
						tmpStr = tostring(v.arry[i]) or "";
					end
					str = string.gsub(str, "@"..i, tmpStr);
				end
			end
		end
	end
	return str;
end

--切换星站小地图标记开关状态
function SwitchStarstationSignPoint()
	if StarStationTransferMgr.getStarStationID and StarStationTransferMgr.switchConsoleSignPoint then
		local id = StarStationTransferMgr:getStarStationID(t_OpenDialogueByItemPos.x, t_OpenDialogueByItemPos.y, t_OpenDialogueByItemPos.z);
		StarStationTransferMgr:switchConsoleSignPoint(id);
		local  answerDef = {FuncType = ANSWER_CONTINUE}
		NpcInteractAnswerOnClick(answerDef)
	end
end

--星站控制台发送快捷短语
function StarStationSendChatMsg()
	if StarStationTransferMgr and ClientCurGame then
		local id = StarStationTransferMgr:getStarStationID(t_OpenDialogueByItemPos.x, t_OpenDialogueByItemPos.y, t_OpenDialogueByItemPos.z);
		local def = StarStationTransferMgr:getStarStationDef(id);
		if def and def.starStationName then
			local x,y,z = 0, 0, 0;
			if CurMainPlayer then
				x,y,z = CurMainPlayer:getPosition(0,0,0);
				x, y, z = CoordDivBlock(x, y, z);
			end
			local msg = GetS(85027, def.starStationName, x .. "," .. z, y);
			SpamPreventionPresenter:requestSendChat(msg);
		end
	end
end

function CheckHomeLandGuideTaskCall(type)
    if not IsMyHomeMap() then
        return false
    end
     
    if type == HOMELAND_NPC_HACIENDA then
        standReportEvent("6", "MINI_MY_HOMELAND_CONTAINER", "FarmBusinessman", "click")   
        
        local res = HomeLandGuideTaskCall("CheckShowTaskDialog", 2)
        if not res then
            standReportEvent("623", "MINI_MY_HOMELAND_FARM_NPC_CHAT", "-", "view")   
            standReportEvent("623", "MINI_MY_HOMELAND_FARM_NPC_CHAT", "Close", "view")   
            standReportEvent("623", "MINI_MY_HOMELAND_FARM_NPC_CHAT", "FarmShop", "view")   
            standReportEvent("623", "MINI_MY_HOMELAND_FARM_NPC_CHAT", "ManureMaking", "view")   
            standReportEvent("623", "MINI_MY_HOMELAND_FARM_NPC_CHAT", "FarmAmountUp", "view")   

            getglobal("NpcDialogueFrame"):SetClientString("HOMELAND_NPC_HACIENDA");
        end

        return res
    elseif type == HOMELAND_NPC_RANCH then
        standReportEvent("6", "MINI_MY_HOMELAND_CONTAINER", "RanchBusinessman", "click")    

        local res =  HomeLandGuideTaskCall("CheckShowTaskDialog", 6) 
        if not res then
            standReportEvent("624", "MINI_MY_HOMELAND_RANCH_NPC_CHAT", "-", "view")   
            standReportEvent("624", "MINI_MY_HOMELAND_RANCH_NPC_CHAT", "Close", "view")   
            standReportEvent("624", "MINI_MY_HOMELAND_RANCH_NPC_CHAT", "RanchShop", "view")   
            standReportEvent("624", "MINI_MY_HOMELAND_RANCH_NPC_CHAT", "FodderMaking", "view")   
            standReportEvent("624", "MINI_MY_HOMELAND_RANCH_NPC_CHAT", "BreedingLevelUp", "view")   

            getglobal("NpcDialogueFrame"):SetClientString("HOMELAND_NPC_RANCH");
        end

        return res
    elseif type == HOMELAND_NPC_PETEXPEDITION then
        return HomeLandGuideTaskCall("CheckShowTaskDialog", 8)
    elseif type == HOMELAND_NPC_SMITH then
        standReportEvent("6", "MINI_MY_HOMELAND_CONTAINER", "ProductionNPC", "click")   

        local res = HomeLandGuideTaskCall("CheckShowTaskDialog", 14)
        if not res then
            standReportEvent("632", "MINI_MY_HOMELAND_CRAFTMAN_NPC_CHAT", "-", "view")
            standReportEvent("632", "MINI_MY_HOMELAND_CRAFTMAN_NPC_CHAT", "Close", "view")
            standReportEvent("632", "MINI_MY_HOMELAND_CRAFTMAN_NPC_CHAT", "CraftShop", "view")
            standReportEvent("632", "MINI_MY_HOMELAND_CRAFTMAN_NPC_CHAT", "Dismantle", "view")
            standReportEvent("632", "MINI_MY_HOMELAND_CRAFTMAN_NPC_CHAT", "GratiaFurniture", "view")
            getglobal("NpcDialogueFrame"):SetClientString("HOMELAND_NPC_SMITH");
        end

        return res
    elseif type == HOMELAND_NPC_COOK then
        standReportEvent("6", "MINI_MY_HOMELAND_CONTAINER", "CookingNPC", "click")   

        local res =  HomeLandGuideTaskCall("CheckShowTaskDialog", 12)
        if not res then
            standReportEvent("625", "MINI_MY_HOMELAND_COOKING_NPC_CHAT", "-","view")   
            standReportEvent("625", "MINI_MY_HOMELAND_COOKING_NPC_CHAT", "Close", "view")   
            standReportEvent("625", "MINI_MY_HOMELAND_COOKING_NPC_CHAT", "CookingShop", "view")   
			standReportEvent("625", "MINI_MY_HOMELAND_COOKING_NPC_CHAT", "DailyMenu", "view")   
            getglobal("NpcDialogueFrame"):SetClientString("HOMELAND_NPC_COOK");
        end

        return res
    end
    
    return false
end
