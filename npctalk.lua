
local m_isOpenNpcTalkSetFrameFromTaskFrame = false;	--是否从任务设置面板打开对话设置.

----------通用----------
--设置剧情的图标
function NpcPlot_SetPlotIcon(icon, strIcon)
	print("NpcPlot_ParseIconIdandType:");
	local index = string.find(strIcon, "_");

	if index then
		local id = string.sub(strIcon, index + 1, -1);
		print("strIcon = " .. strIcon .. ", index = " .. index .. ", id = " .. id);

		if id then
			if string.find(strIcon, "mob") then
				--生物
				icon:SetTexture("ui/roleicons/"..id..".png", true);
			else
				--道具
		    	SetItemIcon(icon, id);
			end
		end
	else
		--没有图标用200代替
		SetItemIcon(icon, 200);
	end
end

--是否是剧情模板
function NpcPlot_IsTaskTemplate(id)
	print("NpcPlot_IsTaskTemplate: id = " .. id);
	return id == 4000;
end

-------------------------------------------------------------剧情-------------------------------------------------------------
--多语言
g_NpcTalk_CurMultiParam = {
	ContantText = "";	--对话内容
	AnswerText = "";	--回答内容
};

local m_NpcTalkFrameParam = {
	curTabBtnIndex = 1,	--当前选择的对话条目
	curAnswerIndex = 1,	--当前选择的回答条目
	curDialogType = 1,	--对话类型:1:剧情对话; 2:接任务后; 3:未完成; 4:已完成
	tabBoxUI = "NpcTalkSetFrameLeftBox",

	Dialogues = {		--对话
		--[[结构示例
		{	--对话1
			curAnswerIndex = 1,
			ID = 1,
			Text = "",
			Action = 1,
			Sound = "",
			Effect = "",
			MultiLangText = "",		--多语言支持
			Answers = {	--回答列表
				{	--回答1
					Text = "",		--回答内容
					FuncType = 1,	--触发功能
					Val = 0;		--跳转对话(任务)id
				},
				{	--回答2
					
				},
			},
		},
		{	--对话2

		},
		]]
	},

	Init = function(self, Dialogues)
		print("m_NpcTalkFrameParam: Init:");
		self.curTabBtnIndex = 1;
		self.curAnswerIndex = 1;
		self.Dialogues = Dialogues;	--不用从csv定义加载了, 直接引用
		self:Update();
	end,

	--设置对话内容
	SetContent = function(self)
		print("SetContent: index = " .. self.curTabBtnIndex);
		print(self.Dialogues);
		local curDialogues = self.Dialogues[self.curTabBtnIndex];
		if curDialogues then
			print("OK:");
			local content = getglobal("NpcTalkSetFrameRightContentEdit"):GetText();
			curDialogues.Text = content;

			--保存多语言
			local datastruct = SignManagerGetInstance():GetDataStructForSave("mod_dialog_content");
			curDialogues.MultiLangText = JSON:encode(datastruct);
			g_NpcTalk_CurMultiParam.ContantText = curDialogues.MultiLangText;

			--刷新ui编辑框文本
			local showText = getTextFrameDataStruct(datastruct);
			if datastruct and datastruct.originalID and showText then
				getglobal("NpcTalkSetFrameRightContentEdit"):SetText(showText);
				curDialogues.Text = showText;
			end
		end
	end,

	--打开回答设置页面
	AnswerOption_OnClick = function(self, id)
		--当前点击的第几个回答
		print("AnswerOption_OnClick: id = " .. id);
		if not next(self.Dialogues) then
			return
		end
		self.curAnswerIndex = id;
		local FuncType = self.Dialogues[self.curTabBtnIndex].Answers[id].FuncType;
		local Val = self.Dialogues[self.curTabBtnIndex].Answers[id].Val;
		local contentText = self.Dialogues[self.curTabBtnIndex].Answers[id].Text;
		g_NpcTalk_CurMultiParam.AnswerText = self.Dialogues[self.curTabBtnIndex].Answers[id].MultiLangText;	--多语言, 原始json

		ShowNpcTalkAnswerSetFrame(FuncType, Val, contentText);
	end,

	--设置回答
	SetAnswer = function(self)

	end,

	--分配一个对话id
	allocAnswerId = function(self)
		print("allocAnswerId:");
		local maxId = 0;
		for i = 1, #(self.Dialogues) do
			if maxId < self.Dialogues[i].ID then
				maxId = self.Dialogues[i].ID;
			end
		end

		maxId = maxId + 1;
		print("maxId = " .. maxId);
		return maxId;
	end,

	Add = function(self, bIsInsert)
		print("AddOneDialogues:");
		local insertPos = #self.Dialogues + 1;
		if bIsInsert then
			--插入
			insertPos = self.curTabBtnIndex;
		end

		--回答列表
		local AnswersList = {
			{Text = "", FuncType = 0,},
			{Text = "", FuncType = 0,},
			{Text = "", FuncType = 0,},
			{Text = "", FuncType = 0,},
		};

		--对话列表
		local newId = self:allocAnswerId();
		table.insert(self.Dialogues, insertPos, {
			ID = newId,
			Text = "",
			Action = 1,
			Sound = "misc.bow",
			Effect = "item_12002_2",
			Answers = AnswersList,
		});

		self.curTabBtnIndex = insertPos;
		self:Update();
	end,

	Delete = function(self)
		print("DeleteOneDialogues:");
		local sum = #(self.Dialogues);
		if self.curTabBtnIndex > 0 and self.curTabBtnIndex <= #self.Dialogues then
			table.remove(self.Dialogues, self.curTabBtnIndex);
			if self.curTabBtnIndex == sum then
				self.curTabBtnIndex = self.curTabBtnIndex - 1;
			end
			self:Update();
		end
	end,

	Update = function(self)	
		print("m_NpcTalkFrameParam:Update:");
		NpcTalk_LeftTabBtnLayout();

		--回答列表先隐藏
		--[[
		for i = 1, 4 do
			getglobal("NpcTalkSetFrameRightAnswer" .. i):Hide();
		end
		]]

		local curDialogues = self.Dialogues[self.curTabBtnIndex];
		if curDialogues then
			--1. 对话内容
			print("hasDialogues:");
			print("MultiLangText = ", curDialogues.MultiLangText);
			g_NpcTalk_CurMultiParam.ContantText = curDialogues.MultiLangText;	--多语言, 原始json
			getglobal("NpcTalkSetFrameRightContentEdit"):SetText(curDialogues.Text);

			if getglobal("NpcTalkSetFrameRightContentEdit"):GetText() == "" then
				getglobal("NpcTalkSetFrameRightContentDefaultTxt"):Show();
			else
				getglobal("NpcTalkSetFrameRightContentDefaultTxt"):Hide();
			end

			--2. 回答列表
			local Name_StringID = 11055;
			for i = 1, 4 do
				print("answer" .. i .. ":");
				
				local answer = getglobal("NpcTalkSetFrameRightAnswer" .. i);
				answer:Show();

				getglobal("NpcTalkSetFrameRightAnswer" .. i .. "Name"):SetText(GetS(Name_StringID));
				Name_StringID = Name_StringID + 1;

				local btnName = getglobal("NpcTalkSetFrameRightAnswer" .. i .. "BtnName");
				if i <= #(curDialogues.Answers) then
					btnName:SetText(curDialogues.Answers[i].Text);
				else
					btnName:SetText("");
				end

				if btnName:GetText() == "" then
					btnName:SetText(GetS(11096));
				end
			end

			if self.curDialogType == 4 then
				getglobal("NpcTalkSetFrameLeftBoxAddBtn"):Hide();
				getglobal("NpcTalkSetFrameRightAnswer2"):Hide();
				getglobal("NpcTalkSetFrameRightAnswer3"):Hide();
				getglobal("NpcTalkSetFrameRightAnswer4"):Hide();
				getglobal("NpcTalkSetFrameDeleteBtn"):Hide();
				getglobal("NpcTalkSetFrameInsertBtn"):Hide();
			else
				getglobal("NpcTalkSetFrameLeftBoxAddBtn"):Show();
				getglobal("NpcTalkSetFrameDeleteBtn"):Show();
				getglobal("NpcTalkSetFrameInsertBtn"):Show();
			end
		end
	end,

	TabBtn_OnClick = function(self, id)
		self.curTabBtnIndex = id;
		self:Update();
	end,

	--保存
	OkBtn_OnClick = function(self)
		print("OkBtn_OnClick:");
	end,
};

-------------------------------------------------------------任务-------------------------------------------------------------
local m_NpcTaskParam = {
	curTaskIndex = 1,	--当前选择的任务条目, 0表示新增.
	NpcTask = {--任务

	},

	curSelBtnIndex = 1,		--多选按钮当前点击的第几个
	curHandAttrIndex = 1,	--当前操作的控件索引, 例如操作"Option"时, 选择条目后知道是操作的哪一个.
	TaskAttr = {
		--任务属性
	},

	InitTask = function(self, NpcTask)
		self.curTaskIndex = 1;
		self.curHandAttrIndex = 1;
		self.curSelBtnIndex = 1;
		self.NpcTask = NpcTask; --modeditor.config.plot[2].TaskSet.NpcTask;
		self.TaskAttr = modeditor.config.plot[2].Attr;
	end,

	Update = function(self)
		print("m_NpcTaskParam:Update:");
		NpcTask_UpdateControlList(self.TaskAttr);
	end,

	SaveAttr2Task = function(self)
		--将编辑的属性, 保存到任务列表
		print("Save:SaveAttr2Task:");
		local curTask = self.NpcTask[self.curTaskIndex];
		for i = 1, #self.TaskAttr do
			if self.TaskAttr[i].SaveAttr2Task then
				self.TaskAttr[i]:SaveAttr2Task(curTask);
			end
		end

	end,
};
function GetNpcTaskParameters()
	return m_NpcTaskParam
end
--打开对话设置界面, 外部接口
--Type:1:剧情对话; 2:接任务后; 3:未完成; 4:已完成
function OpenNpcTakSetFrame(Dialogues, Type)
	-- 审核屏蔽
	if PluginInputDisabled('') then
		return
	end

	print("OpenNpcTakSetFrame:");
	print(Dialogues);
	--多语言
	if CurrentEditDef then
		--CurrentEditDef指向剧情的定义
		-- print(CurrentEditDef.)
	end

	local title = getglobal("NpcTalkSetFrameTitleFrameName");

	m_NpcTalkFrameParam.curDialogType = Type;
	m_NpcTalkFrameParam:Init(Dialogues);

	if Type == 4 then
		print("4444:");
		--已完成
		title:SetText(GetS(11081));
		-- getglobal("NpcTalkSetFrameLeftBoxAddBtn"):Hide();
		-- getglobal("NpcTalkSetFrameRightAnswer2"):Hide();
		-- getglobal("NpcTalkSetFrameRightAnswer3"):Hide();
		-- getglobal("NpcTalkSetFrameRightAnswer4"):Hide();
		-- getglobal("NpcTalkSetFrameDeleteBtn"):Hide();
		-- getglobal("NpcTalkSetFrameInsertBtn"):Hide();
	else
		print("123:");
		if Type == 2 then
			--接任务后
			title:SetText(GetS(11076));
		elseif Type == 3 then
			--未完成
			title:SetText(GetS(11080));
		else
			--剧情对话
			title:SetText(GetS(11053));
		end
		-- getglobal("NpcTalkSetFrameLeftBoxAddBtn"):Show();
		-- getglobal("NpcTalkSetFrameDeleteBtn"):Show();
		-- getglobal("NpcTalkSetFrameInsertBtn"):Show();
	end

	getglobal("NpcTalkSetFrame"):Show();
end

function NpcTalkSetFrame_OnShow()
	--标题名
	--getglobal("NpcTalkSetFrameTitleFrameName"):SetText(GetS(11053));
	
	if m_isOpenNpcTalkSetFrameFromTaskFrame then
		getglobal("NpcTalkTaskEditFrame"):Hide();
	end

	if Current_Edit_Mode == 4 then
		local wdesc = getCurArchiveDesc()
		if wdesc ~= nil then
			local worldid = wdesc.worldid;
			if ShowTranslateBtn("mod_dialog_content", worldid) then
				ShowTranslateTextState("mod_dialog_content",worldid)
			end
		end
	end

	--插件库帮助引导
	-- if not AccountManager:getNoviceGuideState("dialoguesguidhelp") then
	-- 	getglobal("NpcTalkSetFrameHelpBtnGuide"):Show();
	-- else
	-- 	getglobal("NpcTalkSetFrameHelpBtnGuide"):Hide();
	-- end
end

function NpcTalkSetFrame_OnHide()
	if m_isOpenNpcTalkSetFrameFromTaskFrame then
		m_isOpenNpcTalkSetFrameFromTaskFrame = false;
		getglobal("NpcTalkTaskEditFrame"):Show();
	end
end

function NpcTalkSetFrameCloseBtn_OnClick()
	getglobal("NpcTalkSetFrame"):Hide();
end

function NpcTalkSetFrameHelpBtn_OnClick()
	getglobal("MyModsEditorHelpFrameTitleName"):SetText(GetS(11098));
	getglobal("MyModsEditorHelpFrameBoxContent"):SetText(GetS(11099), 61, 69, 70);
	getglobal('MyModsEditorHelpFrame'):Show();

	-- if not AccountManager:getNoviceGuideState("dialoguesguidhelp") then
	-- 	AccountManager:setNoviceGuideState("dialoguesguidhelp", true);
	-- 	getglobal("NpcTalkSetFrameHelpBtnGuide"):Hide();
	-- end
end

function NpcTalkSetFrameHelpBtnGuide_OnClick()
	-- AccountManager:setNoviceGuideState("dialoguesguidhelp", true);
	-- getglobal("NpcTalkSetFrameHelpBtnGuide"):Hide();
end

----导航按钮
function NpcTalk_LeftTabBtnLayout()
	print("NpcTalk_LeftTabBtnLayout:");
	local num = #m_NpcTalkFrameParam.Dialogues;
	local Dialogues = m_NpcTalkFrameParam.Dialogues;
	local boxUI = m_NpcTalkFrameParam.tabBoxUI;
	local plane = getglobal(boxUI .. "Plane");
	local y = 0;
	local offsetH = 75;

	for i = 1, 20 do
		local btn = getglobal(boxUI .. "Btn" .. i);
		local name = getglobal(boxUI .. "Btn" .. i .. "Name");
		local checked = getglobal(boxUI .. "Btn" .. i .. "Checked");

		btn:Hide();
		if i <= num then
			btn:Show()
			btn:SetPoint("top", boxUI .. "Plane", "top", 0, y);
			name:SetText(string.sub(Dialogues[i].Text, 1, 21) .. "...");
			y = y + offsetH;

			if i == m_NpcTalkFrameParam.curTabBtnIndex then
				checked:Show();
				-- name:SetTextColor(121, 89, 58);
			else
				checked:Hide();
				-- name:SetTextColor(236, 204, 142);
			end
		end

	end

	--新增按钮
	getglobal(boxUI .. "AddBtn"):SetPoint("top", boxUI .. "Plane", "top", 0, y);
	y = y + offsetH;

	if y < 450 then y = 450; end
	plane:SetHeight(y);
end

function NpcTalkTabBtnTemplate_OnClick()
	local id = this:GetClientID();
	m_NpcTalkFrameParam:TabBtn_OnClick(id);
end

--新增对话按钮
function NpcTalkSetFrameLeftBoxAddBtn_OnClick()
	m_NpcTalkFrameParam:Add();
end

--回答选项按钮
function NpcTalkAnswerTemplate_OnClick()
	local id = this:GetParentFrame():GetClientID();

	m_NpcTalkFrameParam:AnswerOption_OnClick(id);
end

--删除
function NpcTalkSetFrameDeleteBtn_OnClick()
	m_NpcTalkFrameParam:Delete();
end

--插入
function NpcTalkSetFrameInsertBtn_OnClick()
	m_NpcTalkFrameParam:Add(true);
end

--确定
function NpcTalkSetFrameOkBtn_OnClick(dontClose)
	local txt = getglobal("NpcTalkSetFrameRightContentEdit"):GetText();
	if txt == "" then
		ShowGameTips(GetS(11090), 3);
		return;
	end

	if CheckFilterString(txt) then return end

	for i=1, 4 do
		text = getglobal("NpcTalkSetFrameRightAnswer"..i.."BtnName"):GetText();
		if CheckFilterString(txt) then return end
	end

	m_NpcTalkFrameParam:OkBtn_OnClick();

	if not dontClose then
		NpcTalkSetFrameCloseBtn_OnClick();
	end
end

--对话内容
function NpcTalkSetFrameRightContentEdit_OnFocusLost()
	local text = getglobal("NpcTalkSetFrameRightContentEdit"):GetText();
	if CheckFilterString(text) then
		getglobal("NpcTalkSetFrameRightContentEdit"):SetText("");
	end

	m_NpcTalkFrameParam:SetContent();

	if getglobal("NpcTalkSetFrameRightContentEdit"):GetText() == "" then
		getglobal("NpcTalkSetFrameRightContentDefaultTxt"):Show();
	else
		getglobal("NpcTalkSetFrameRightContentDefaultTxt"):Hide();
	end
end

function NpcTalkSetFrameRightContentEdit_OnFocusGained()
	getglobal("NpcTalkSetFrameRightContentDefaultTxt"):Hide();
end

--------cliark add------
function NpcTalkSetFrameEdit_OnFocusLost()
	m_NpcTalkFrameParam:SetContent();


end

function NpcTalkSetFrameEdit_OnFocusGained()

end

--打开前置任务选项面板:被调函数"NewSingleOptionBtnTemplate_OnClick"
function NpcTalk_OpenTaskSelectOptionFrame(t)
	print("NpcTalk_OpenTaskSelectOptionFrame:");
	--加载任务列表
	Condition_LoadTaskList(t);
	SetEditorOptionFrame(t.Options, GetS(t.Name_StringID), GetS(t.Desc_StringID), "PlotConditionTask");
end

--LLTODO:前置条件->前置任务, 加载任务:t:输出参数
function Condition_LoadTaskList(t)
	print("Condition_LoadTaskList:");
	local Options = {};
	local allTask = NpcTask_LoadAllTask();

	Options[1] = {Name_String = GetS(11045), Val = 0, Color = {r=54, g=51, b=49},};	--0:无

	for i = 2, #allTask do
		if allTask[i] and not NpcPlot_IsTaskTemplate(allTask[i].ID) then
			table.insert(Options, {
				Val = allTask[i].ID,
				Name_String = allTask[i].Name,
				Color = {r=54, g=51, b=49},
			});
		end
	end

	print("Options:");
	t.Options = Options;
end

--前置条件回调, 布局UI
function ConditionOptionCallbackUI()
	print("ConditionOptionCallbackUI:");
	Interact_SetModEditorType();
	local tBase = modeditor.config.plot[1];

	--页面布局
	print("LayoutFrames:");
	local frames = {
		{ ui = "SingleEditorFrameBaseSetNPCPlotTitle", bshow = true},
		{ ui = "SingleEditorFrameBaseSetNPCPlotNameEdit", bshow = true},
		{ ui = "SingleEditorFrameBaseSetNPCPlotIcon", bshow = true},
		{ ui = "SingleEditorFrameBaseSetNPCPlotCondition", bshow = true},
		{ ui = "ConditionParamTask", bshow = true},			--5. 前置条件:任务
		{ ui = "ConditionParamStartTime", bshow = true},	--6. 前置条件:开始时间
		{ ui = "ConditionParamEndTime", bshow = true},		--7. 前置条件:结束时间
		{ ui = "ConditionParamItem", bshow = true},			--8. 前置条件:拥有道具
		{ ui = "ConditionParamItemQuantity", bshow = true},	--9. 前置条件:拥有道具数量
		{ ui = "SingleEditorFrameBaseSetNPCPlotTalk", bshow = true},
		{ ui = "SingleEditorFrameBaseSetNPCPlotTarget", bshow = true},

		HandleShowState = function(self, indexList)
			for i = 5, 9 do
				self[i].bshow = false;
				for j = 1, #indexList do
					if i == indexList[j] then
						self[i].bshow = true;
					end
				end
			end
		end,
	};

	local planeUI = "SingleEditorFrameBaseSetNPCPlotPlane";

	local Attr = tBase.Attr;
	local Type = Attr[3].CurVal;
	if Type == 1 then
		--前置任务
		print("ConditionTask:");
		frames:HandleShowState({5});
		for i = 6, 8 do
			local index = i - 5;
			local CurVal = Attr[i].CurVal;
			local Options = Attr[i].Options;
			if Options then
				local option = Attr[i].GetOption(CurVal, Options);
				if option then
					getglobal("ConditionParamTask" .. index .. "BtnName"):SetText(option.Name_String);
				else
					getglobal("ConditionParamTask" .. index .. "BtnName"):SetText(GetS(11045));--无
				end
			else
				getglobal("ConditionParamTask" .. index .. "BtnName"):SetText(GetS(11045));--无
			end
		end
	elseif Type == 2 then
		--时间
		print("Time:");
		frames:HandleShowState({6, 7});
	elseif Type == 3 then
		--拥有道具
		print("Item:");
		frames:HandleShowState({8, 9});
	else
		frames:HandleShowState({0});
	end

	--UI
	--开始/结束时间
	local startBar = getglobal("ConditionParamStartTimeBar");
	local endBar = getglobal("ConditionParamEndTimeBar");
	local startTimeParam = Attr[9];
	local endTimeParam = Attr[10];
	getglobal("ConditionParamStartTimeVal"):SetPoint("left", "ConditionParamStartTimeName", "right", 505, 0)
	getglobal("ConditionParamStartTimeDesc"):SetPoint("left", "ConditionParamStartTimeVal", "right", -40, 0)
	getglobal("ConditionParamStartTimeName"):SetWidth(245)
	getglobal("ConditionParamStartTimeName"):SetText(GetS(startTimeParam.Name_StringID));
	startBar:SetMinValue(startTimeParam.Min);
	startBar:SetMaxValue(startTimeParam.Max);

	getglobal("ConditionParamEndTimeVal"):SetPoint("left", "ConditionParamEndTimeName", "right", 505, 0)
	getglobal("ConditionParamEndTimeDesc"):SetPoint("left", "ConditionParamEndTimeVal", "right", -40, 0)
	getglobal("ConditionParamEndTimeName"):SetWidth(245)
	getglobal("ConditionParamEndTimeName"):SetText(GetS(endTimeParam.Name_StringID));
	endBar:SetMinValue(endTimeParam.Min);
	endBar:SetMaxValue(endTimeParam.Max);
	if Type == 2 then
		startBar:SetValue(Attr[9].CurVal);
		endBar:SetValue(Attr[10].CurVal);
	end

	--拥有道具
	getglobal("ConditionParamItemBtn1Del"):Hide();
	getglobal("ConditionParamItemBtn1Name"):Hide();
	getglobal("ConditionParamItemBtn1Num"):Hide();
	local itemParam = Attr[12];
	local itemBar = getglobal("ConditionParamItemQuantityBar");
	itemBar:SetMinValue(itemParam.Min);
	itemBar:SetMaxValue(itemParam.Max);
	getglobal("ConditionParamItemQuantityVal"):SetPoint("left", "ConditionParamItemQuantityName", "right", 505, 0)
	getglobal("ConditionParamItemQuantityDesc"):SetPoint("left", "ConditionParamItemQuantityVal", "right", -40, 0)
	getglobal("ConditionParamItemQuantityName"):SetWidth(245)
	getglobal("ConditionParamItemQuantityName"):SetText(GetS(itemParam.Name_StringID));
	if Type == 3 then
		itemBar:SetValue(Attr[12].CurVal);
		local itemIcon = getglobal("ConditionParamItemBtn1Icon");
		SetItemIcon(itemIcon, Attr[11].CurVal.id);
	end


	local lastFrame = frames[1].ui;
	local y = getglobal(lastFrame):GetHeight();
	for i = 1, #frames do
		if i > 1 then
			local f = getglobal(frames[i].ui);

			if frames[i].bshow then
				f:Show();
				f:SetPoint("top", planeUI, "top", 0, y);
				y = y + f:GetHeight();
			else
				f:Hide();
			end
		end
	end
	print("y = " .. y);
	if y < 577 then y = 577; end
	getglobal(planeUI):SetHeight(y);
end

---------------------------------------------------------回答设置页面---------------------------------------------------------
local m_AnswersParam = {
	--触发功能, 选项列表
	funcBtn = {
		curFuncIndex = 0,	--触发功能类型
		gotoDialoguesId = 0,	--跳转对话(任务)id
		contentText = "",		--对话内容
		titleStrID = 11012,
		descStrID = 11013,
		Option = {	--触发功能选项
			{
				Name_StringID = 11014, 	--选项1
				Color = {r=54, g=51, b=49},
				Val = 0,
			},
			{
				Name_StringID = 11015, 	--选项2
				Color = {r=54, g=51, b=49},
				Val = 1,
			},
			{
				Name_StringID = 11016, 	--选项3
				Color = {r=54, g=51, b=49},
				Val = 2,
			},
			{
				Name_StringID = 11017, 	--选项4
				Color = {r=54, g=51, b=49},
				Val = 3,
			},
		},
	},

	--刷新回答页面
	UpdateAnswerFrame = function(self)
		print("UpdateAnswerFrame: curFuncIndex = " .. self.funcBtn.curFuncIndex);
		local curAnswerIndex = m_NpcTalkFrameParam.curAnswerIndex;
		local txt = self.funcBtn.contentText; --m_NpcTalkFrameParam.Dialogues[m_NpcTalkFrameParam.curTabBtnIndex].Answers[curAnswerIndex].Text;
		getglobal("NpcTalkAnswerSetFrameEdit"):SetText(txt);

		if self.funcBtn.curFuncIndex <= 4 then
			getglobal("NpcTalkAnswerSetFrameFuncBtnName"):SetText(GetS(self.funcBtn.Option[self.funcBtn.curFuncIndex].Name_StringID));
		end

		--刷新任务/对话选择按钮
		-- local FuncType = self.funcBtn.curFuncIndex - 1;
		-- if FuncType == 1 then
		-- 	--对话选择
		-- 	getglobal("NpcTalkAnswerSetFrameSelect"):Show();
		-- 	getglobal("NpcTalkAnswerSetFrameSelectTitle"):SetText(GetS(11064));
		-- 	getglobal("NpcTalkAnswerSetFrameTaskEditBtn"):Hide();
		-- 	getglobal("NpcTalkAnswerSetFrameSelectBtnName"):SetText(GetS(11085));
		-- 	for i = 1, #(m_NpcTalkFrameParam.Dialogues) do
		-- 		if self.funcBtn.gotoDialoguesId == m_NpcTalkFrameParam.Dialogues[i].ID then
		-- 			getglobal("NpcTalkAnswerSetFrameSelectBtnName"):SetText(string.sub(m_NpcTalkFrameParam.Dialogues[i].Text, 1, 30));
		-- 			break;
		-- 		end
		-- 	end
		-- elseif FuncType == 3 then
		-- 	--任务选择
		-- 	getglobal("NpcTalkAnswerSetFrameSelect"):Show();
		-- 	getglobal("NpcTalkAnswerSetFrameSelectTitle"):SetText(GetS(11065));
		-- 	getglobal("NpcTalkAnswerSetFrameTaskEditBtn"):Show();
		-- 	getglobal("NpcTalkAnswerSetFrameSelectBtnName"):SetText(GetS(11085));
		-- 	for i = 1, #(m_NpcTaskParam.NpcTask) do
		-- 		print("i = " .. i .. ", m_NpcTaskParam.NpcTask[i].ID = " .. m_NpcTaskParam.NpcTask[i].ID);
		-- 		if self.funcBtn.gotoDialoguesId == m_NpcTaskParam.NpcTask[i].ID then
		-- 			getglobal("NpcTalkAnswerSetFrameSelectBtnName"):SetText(string.sub(m_NpcTaskParam.NpcTask[i].Name, 1, 30));
		-- 			break;
		-- 		end
		-- 	end
		-- else
		-- 	getglobal("NpcTalkAnswerSetFrameSelect"):Hide();
		-- 	getglobal("NpcTalkAnswerSetFrameTaskEditBtn"):Hide();
		-- end
		self:UpdateSelectBtnName();
	end,

	--刷新任务选择按钮
	UpdateSelectBtnName = function(self)
		print("UpdateSelectBtnName:");
		local FuncType = self.funcBtn.curFuncIndex - 1;
		if FuncType == 1 then
			--对话选择
			getglobal("NpcTalkAnswerSetFrameSelect"):Show();
			getglobal("NpcTalkAnswerSetFrameSelectTitle"):SetText(GetS(11064));
			getglobal("NpcTalkAnswerSetFrameTaskEditBtn"):Hide();
			getglobal("NpcTalkAnswerSetFrameSelectBtnName"):SetText(GetS(11085));
			for i = 1, #(m_NpcTalkFrameParam.Dialogues) do
				if self.funcBtn.gotoDialoguesId == m_NpcTalkFrameParam.Dialogues[i].ID then
					getglobal("NpcTalkAnswerSetFrameSelectBtnName"):SetText(string.sub(m_NpcTalkFrameParam.Dialogues[i].Text, 1, 30));
					break;
				end
			end
		elseif FuncType == 3 then
			--任务选择
			getglobal("NpcTalkAnswerSetFrameSelect"):Show();
			getglobal("NpcTalkAnswerSetFrameSelectTitle"):SetText(GetS(11065));
			getglobal("NpcTalkAnswerSetFrameTaskEditBtn"):Show();
			getglobal("NpcTalkAnswerSetFrameSelectBtnName"):SetText(GetS(11085));
			for i = 1, #(m_NpcTaskParam.NpcTask) do
				print("i = " .. i .. ", m_NpcTaskParam.NpcTask[i].ID = " .. m_NpcTaskParam.NpcTask[i].ID);
				if self.funcBtn.gotoDialoguesId == m_NpcTaskParam.NpcTask[i].ID then
					getglobal("NpcTalkAnswerSetFrameSelectBtnName"):SetText(string.sub(m_NpcTaskParam.NpcTask[i].Name, 1, 30));
					break;
				end
			end
		else
			getglobal("NpcTalkAnswerSetFrameSelect"):Hide();
			getglobal("NpcTalkAnswerSetFrameTaskEditBtn"):Hide();
		end
	end,

	Save = function(self)
		print("Save:");
		local curAnswerIndex = m_NpcTalkFrameParam.curAnswerIndex;
		local datastruct = SignManagerGetInstance():GetDataStructForSave("mod_answer_content");	--多语言支持
		local jsonstr = JSON:encode(datastruct);
		g_NpcTalk_CurMultiParam.AnswerText = jsonstr;
		m_NpcTalkFrameParam.Dialogues[m_NpcTalkFrameParam.curTabBtnIndex].Answers[curAnswerIndex].MultiLangText = jsonstr;
		m_NpcTalkFrameParam.Dialogues[m_NpcTalkFrameParam.curTabBtnIndex].Answers[curAnswerIndex].Text = getglobal("NpcTalkAnswerSetFrameEdit"):GetText();
		m_NpcTalkFrameParam.Dialogues[m_NpcTalkFrameParam.curTabBtnIndex].Answers[curAnswerIndex].FuncType = self.funcBtn.curFuncIndex - 1;
		m_NpcTalkFrameParam.Dialogues[m_NpcTalkFrameParam.curTabBtnIndex].Answers[curAnswerIndex].Val = self.funcBtn.gotoDialoguesId;
		m_NpcTalkFrameParam:Update();
	end,
};

function NpcTalkAnswerSetFrameCloseBtn_OnClick()
	getglobal("NpcTalkAnswerSetFrame"):Hide();
end

function ShowNpcTalkAnswerSetFrame(FuncType, gotoId, contentText)
	print("ShowNpcTalkAnswerSetFrame:");
	print("FuncType = " .. FuncType);
	m_AnswersParam.funcBtn.curFuncIndex = FuncType + 1;
	m_AnswersParam.funcBtn.gotoDialoguesId = gotoId;
	m_AnswersParam.funcBtn.contentText = contentText;
	m_AnswersParam:UpdateAnswerFrame();

	if m_NpcTalkFrameParam.curDialogType == 4 then
		getglobal("NpcTalkAnswerSetFrameFuncBtnName"):SetText(GetS(11219));
		getglobal("NpcTalkAnswerSetFrameFuncBtnNormal"):SetGray(true);
		getglobal("NpcTalkAnswerSetFrameFuncBtnPushedBG"):SetGray(true);
		getglobal("NpcTalkAnswerSetFrameFuncBtn"):Disable();
	else
		getglobal("NpcTalkAnswerSetFrameFuncBtnNormal"):SetGray(false);
		getglobal("NpcTalkAnswerSetFrameFuncBtnPushedBG"):SetGray(false);
		getglobal("NpcTalkAnswerSetFrameFuncBtn"):Enable();
	end

	getglobal("NpcTalkAnswerSetFrame"):Show();
end

function NpcTalkAnswerSetFrame_OnShow()
	--标题栏
	getglobal("NpcTalkAnswerSetFrameTitleFrameName"):SetText(GetS(11062));

	if Current_Edit_Mode == 4 then
		local wdesc = getCurArchiveDesc()
		if wdesc ~= nil then
			local worldid = wdesc.worldid;
			if ShowTranslateBtn("mod_answer_content", worldid) then
				ShowTranslateTextState("mod_answer_content",worldid)
			end
		end
	end
end

--触发功能:选项按钮
local m_flag_AnswerSetOption = "func";	--选项类型, "func":触发功能, "dialogues":对话, "task":任务选择
local m_TempDialoguesOptions = {};
function NpcTalkSingleOptionTemplate_OnClick()
	print("NpcTalkSingleOptionTemplate_OnClick:");
	local btnname = this:GetName();

	if string.find(btnname, "FuncBtn") then
		--触发功能
		m_flag_AnswerSetOption = "func";
		SetEditorOptionFrame(m_AnswersParam.funcBtn.Option, GetS(m_AnswersParam.funcBtn.titleStrID), GetS(m_AnswersParam.funcBtn.descStrID));
		m_AnswersParam.funcBtn.contentText = getglobal("NpcTalkAnswerSetFrameEdit"):GetText();

		if m_isOpenNpcTalkSetFrameFromTaskFrame then
			--任务里面的对话, 没有接任务一项
			getglobal("EditorSingleOption4"):Hide();
		end
	elseif string.find(btnname, "SelectBtn") then
		--选择跳转对话/ 选择任务
		m_TempDialoguesOptions = {};
		if m_AnswersParam.funcBtn.curFuncIndex == 2 then
			--加载对话选项
			print("1:LoadDialogues:");
			m_flag_AnswerSetOption = "dialogues";
			local Dialogues = m_NpcTalkFrameParam.Dialogues;
			for i = 1, #Dialogues do
				m_TempDialoguesOptions[i] = {
					Val = Dialogues[i].ID,
					Name_String = string.sub(Dialogues[i].Text, 1, 40);-- Dialogues[i].Text,
				};
			end

			SetEditorOptionFrame(m_TempDialoguesOptions, GetS(11064), GetS(11066), "PlotConditionTask");
		elseif m_AnswersParam.funcBtn.curFuncIndex == 4 then
			--加载任务选项, 这里要做筛选, 只加载自己创建的任务.
			print("3:LoadTask:");
			m_flag_AnswerSetOption = "task";
			local NpcTask = m_NpcTaskParam.NpcTask;
			local TaskIDs = modeditor.config.plot[1].Attr[13].CurVal;
			local tempTaskIDs = {};

			--去掉重复的id
			for k, v in pairs(TaskIDs) do
				tempTaskIDs[v] = k;
			end
			TaskIDs = {};
			for k, v in pairs(tempTaskIDs) do
				table.insert(TaskIDs, k);
			end

			for i = 1, #NpcTask do
				print("task_id = " .. NpcTask[i].ID);
				for j = 1, #TaskIDs do
					if NpcTask[i].ID == TaskIDs[j] then
						table.insert(m_TempDialoguesOptions, {
							Val = NpcTask[i].ID,
							Name_String = string.sub(NpcTask[i].Name, 1, 40);--NpcTask[i].Name,
						});
					end
				end
			end

			--新增任务条目
			table.insert(m_TempDialoguesOptions, {Val = 0, Name_String = GetS(11068)});

			SetEditorOptionFrame(m_TempDialoguesOptions, GetS(11049), GetS(11067), "PlotConditionTask");
		end
	else

	end
end

--触发功能:选项条目点击, 外部接口, 被调函数:SingleOptionBtnTemplate_OnClick.
function NpcTalkSingleOptionItemClidk(id)
	print("NpcTalkSingleOptionItemClidk: id = " .. id);
	if m_flag_AnswerSetOption == "func" then
		print("func:");
		m_AnswersParam.funcBtn.curFuncIndex = id;
		m_AnswersParam.funcBtn.gotoDialoguesId = 1;
		m_AnswersParam:UpdateAnswerFrame();
	elseif m_flag_AnswerSetOption == "dialogues" or m_flag_AnswerSetOption == "task" then
		--选择跳转到的对话(任务)
		local Val = m_TempDialoguesOptions[id].Val;
		print("dialogues:");
		print("Val = " .. Val);
		if Val == 0 then
			--新增任务, 打开任务编辑界面
			print("AddTask:");
			NpcTalk_SetRestoreParam();
			NpcTask_OpenEditFrame(0);
		else
			print("SelectTask:");
			m_AnswersParam.funcBtn.gotoDialoguesId = Val;
			m_AnswersParam:UpdateAnswerFrame();
		end
	end
end

--确定按钮
function NpcTalkAnswerSetFrameOkBtn_OnClick(dontClose)
	local txt = getglobal("NpcTalkAnswerSetFrameEdit"):GetText();

	-- if txt == "" then
	-- 	ShowGameTips(GetS(11090), 3);
	-- 	return;
	-- end

	if CheckFilterString(txt) then return end

	m_AnswersParam:Save();

	if not dontClose then
		NpcTalkAnswerSetFrameCloseBtn_OnClick();
	end
end

--编辑任务
function NpcTalkAnswerSetFrameTaskEditBtn_OnClick()
	print("NpcTalkAnswerSetFrameTaskEditBtn_OnClick:");
	local curSelectedTaskId = m_AnswersParam.funcBtn.gotoDialoguesId;
	local index = 0;

	print("curSelectedTaskId = " .. curSelectedTaskId);
	if curSelectedTaskId > 0 then
		print("111:");
		for i = 1, #(m_NpcTaskParam.NpcTask) do
			if m_NpcTaskParam.NpcTask[i].ID == curSelectedTaskId then
				index = i;
				break;
			end
		end

		print("index = " .. index);
		if index > 0 then
			NpcTalk_SetRestoreParam();
			NpcTask_OpenEditFrame(index);
			m_AnswersParam.funcBtn.contentText = getglobal("NpcTalkAnswerSetFrameEdit"):GetText();
		end
	end
end

---------------------------------------------------------任务编辑---------------------------------------------------------
--将一组对话的结转化为json保存样式
function NpcTask_CreateDialoguesJsonTable(Dialogues)
	if not Dialogues then return end
	print("NpcTask_CreateDialoguesJsonTable:",Dialogues);
	local content = {};
	for i = 1, #Dialogues do
		print("i = " .. i);
		content[i] = {};
		content[i].id = Dialogues[i].ID;
		content[i].text = Dialogues[i].Text;
		content[i].multilangtext = Dialogues[i].MultiLangText;
		content[i].action = Dialogues[i].Action;
		content[i].sound = Dialogues[i].Sound;
		content[i].effect = Dialogues[i].Effect;
		content[i].answer = {};
		for j = 1, #Dialogues[i].Answers do
			print("j = " .. j);
			content[i].answer[j] = {};
			content[i].answer[j].text = Dialogues[i].Answers[j].Text;
			content[i].answer[j].func_type = Dialogues[i].Answers[j].FuncType;
			content[i].answer[j].val = Dialogues[i].Answers[j].Val;
		end
	end

	return content;
end

--创建一个对话的lua表, 从c++的定义
function NpcTask_CreateDialogueFromUserdata(dialoguesDef)
	print("NpcTask_CreateDialogueFromUserdata:");
	local Dialogue = {};

	if dialoguesDef then
		--回答列表
		local AnswersList = {};
		local numAnswers = dialoguesDef:getAnswerNum();
		-- print("333numAnswers = " .. numAnswers);
		for j = 1, 4 do
			local answerDef = dialoguesDef:getAnswerDef(j - 1);
			if answerDef then
				-- print("444answerDef, OK:");
				table.insert(AnswersList, {
					Text = ConvertDialogueStr(answerDef.Text),
					FuncType = answerDef.FuncType,
					Val = answerDef.Val,
				})
			else
				table.insert(AnswersList, {
					Text = "",
					FuncType = 0,
					Val = 0,
				})
			end
		end

		--对话列表
		-- print("555dialoguesDef, OK:");
		Dialogue = {
			ID = dialoguesDef.ID,
			Text = ConvertDialogueStr(dialoguesDef.Text),
			MultiLangText = dialoguesDef.MultiLangText;
			Action = dialoguesDef.Action,
			Sound = dialoguesDef.Sound,
			Effect = dialoguesDef.Effect,
			Answers = AnswersList,
		};
	end

	return Dialogue;
end
--加载所有任务
function NpcTask_LoadAllTask()
	print("NpcTask_LoadAllTask:");
	local outTaskList = {};
	local num = DefMgr:getNpcTaskDefNum();
	--local num = ModEditorMgr:getCustomNpcTaskCount();
	print("num1 = " .. num);
	for i = 1, num do
		print(" i = " .. i);
		--local def = DefMgr:getNpcTaskDefByIndex(i - 1);
		local def = DefMgr:getNpcTaskDefByIndexAnyway(i - 1);
		--local def = ModEditorMgr:getNpcTaskDef(i - 1);
		if def then
			print("OK: ID = " .. def.ID);
			--任务类型
			local contentNum = def:getTaskContentDeNum();
			local content = {};
			content[1] = {Type = 0, ID = 0, Num = 0};
			content[2] = {Type = 0, ID = 0, Num = 0};
			content[3] = {Type = 0, ID = 0, Num = 0};
			for j = 1, contentNum do
				local contentDef = def:getTaskContentDef(j - 1);
				if contentDef then
					content[j] = {};
					content[j].Type = contentDef.Type;
					content[j].ID = contentDef.ID;
					content[j].Num = contentDef.Num;
				end
			end

			--任务奖励
			local rewordNum = def:getTaskRewardDeNum() + 1 --  getTaskRewardDeNum 返回Vector.size()
			local reword = {};
			reword[1] = {Type = 0, ID = 0, Num = 0};
			reword[2] = {Type = 0, ID = 0, Num = 0};
			reword[3] = {Type = 0, ID = 0, Num = 0};
			reword[4] = {Type = 0, ID = 0, Num = 0};
			-- for i = 1, rewordNum do
			-- 	local rewordDef = def:getTaskRewardDef(i - 1);
			-- 	if rewordDef then
			-- 		reword[i] = {};
			-- 		reword[i].Type = rewordDef.Type;
			-- 		reword[i].ID = rewordDef.ID;
			-- 		reword[i].Num = rewordDef.Num;
			-- 	end
			-- end
			local rewordIndex = 1;
			for j = 1, rewordNum do
				local rewordDef = def:getTaskRewardDef(j - 1);
				if rewordDef then
					if rewordDef.Type == 0 then
						--前三个:奖励道具
						reword[rewordIndex].Type = rewordDef.Type;
						reword[rewordIndex].ID = rewordDef.ID;
						reword[rewordIndex].Num = rewordDef.Num;
						rewordIndex = rewordIndex + 1;
					else
						--第四个:经验
						reword[4].Type = rewordDef.Type;
						reword[4].ID = rewordDef.ID;
						reword[4].Num = rewordDef.Num;
					end
				end
			end

			--剧情对话-接任务后
			--交付对话-任务未完成
			--交付对话-任务已完成
			local _Plots = {};
			for Type = 0, 2 do
				local num = def:getDialogueNum(Type);
				local temp = {};
				if num > 0 then
					for i = 1, num do
						local dialoguesDef = def:getDialogueDef(Type, i - 1)
						local Dialogue = NpcTask_CreateDialogueFromUserdata(dialoguesDef);
						table.insert(temp, Dialogue);
					end

					table.insert(_Plots, temp);
				end
			end
			print("_Plots:");

			--if def.ID ~= 4000 then
				table.insert(outTaskList, {
					ID = def.ID,
					CopyID = def.CopyID,
					Name = ConvertDialogueStr(def.Name);				--"砍树100棵",
					MultiLangText = def.MultiLangText;					--多语言, 任务名
					IsDeliver = def.IsDeliver,		--是否要交付
					ShowInNote = def.ShowInNote,	--在冒险笔记显示
					InteractID = def.InteractID,	--交付目标
					IsRepeat = def.IsRepeat,
					EnglishName = def.EnglishName,
					UseInteract = def.UseInteract,

					--待定----------------------------------------
					TaskContents = content,			--任务类型


					TaskRewards = reword,				--奖励类型
					Plots = _Plots[1],					--对话:接任务之后
					UnCompleteds = _Plots[2],			--对话:未完成
					Completeds = _Plots[3],			--对话:已完成
				});
			--end
		else
			print("error: ");
		end
	end

	return outTaskList;
end

--初始化:外部接口, 被调函数:"NpcPlotBaseParamSet"
function NpcTaskParam_Init(NpcTask)
	print("NpcTaskParam_Init:");
	m_NpcTaskParam:InitTask(NpcTask);
end

--设置任务描述
function NpcTask_SetSingleDesc(objDesc, tTask)
	print("NpcTask_SetSingleDesc:");
	--1.任务名
	local descStr = tTask.Name .. ": ";

	--2. 交付对象名
	print("actorName:");
	local actorName = "";
	if tTask.InteractID and tTask.InteractID > 0 then
		print("tTask.InteractID = " .. tTask.InteractID);
		local def = ModEditorMgr:getMonsterDefById(tTask.InteractID) or MonsterCsv:get(tTask.InteractID);
		if def then
			actorName = def.Name;
		end
	end

	--3. 任务目标
	print("content:");
	local content = "";
	local contentType = 0
	if tTask.TaskContents then
		for i = 1, #(tTask.TaskContents) do
			print("i = " .. i);
			local num = tTask.TaskContents[i].Num;
			local id = tTask.TaskContents[i].ID;
			local def = nil;
			contentType = tTask.TaskContents[i].Type;

			if id and id > 0 then
				print("id = " .. id);
				if tTask.TaskContents[i].Type == 1 then
					def = ModEditorMgr:getMonsterDefById(id) or MonsterCsv:get(id);
				elseif tTask.TaskContents[i].Type == 2 then
					def = ModEditorMgr:getItemDefById(id) or ItemDefCsv:get(id);
				end

				if def then
					content = content .. def.Name .. "x" .. num .. "，";

					print("content = " .. content);
				end
			end
		end

		if string.len(content) > 0 then
			content = string.sub(content, 1, -4);
			print("content = " .. content);
		end
	end

	print("End: contentType = " .. contentType);
	if tTask.IsDeliver then
		if contentType == 0 then
			descStr = descStr .. GetS(11209, actorName);
		elseif contentType == 1 then
			descStr = descStr .. GetS(11215) .. content .. GetS(11213, actorName);
		elseif contentType == 2 then
			descStr = descStr .. GetS(11216) .. content .. GetS(11214, actorName);
		end
	else
		--不需要交付
		if contentType == 1 then
			descStr = descStr .. GetS(11215) .. content .. GetS(11100);
		elseif contentType == 2 then
			descStr = descStr .. GetS(11216) .. content .. GetS(11100);
		end
	end

	descStr = DefMgr:filterString(descStr);
	objDesc:SetText(descStr);
end

--更新任务列表:参考"UpdateNewSingleEditorActorFeature"
function NpcTask_UpdateTaskList()
	print("NpcTask_UpdateTaskList:");
	getglobal("NewEditorFeatureItemAdd"):Hide();

	local NpcTask = m_NpcTaskParam.NpcTask;
	local num = #NpcTask;
	local height = getglobal("SingleEditorFeatureLine"):GetHeight() + 50;
	local TaskIDs = modeditor.config.plot[1].Attr[13].CurVal;

	--标题
    -- getglobal("SingleEditorFeatureLineLineZheZhao"):Show()
    getglobal("SingleEditorFeatureLineTitle"):Show()
    getglobal("SingleEditorFeatureLineTitle"):SetWidth(400)
	getglobal("SingleEditorFeatureLineTitle"):SetText(GetS(11071))
	if getglobal("SingleEditorFrameRightTopTitle"):IsShown() then
		getglobal("SingleEditorFrameRightTopTitle"):Hide();
	end

    for i=1, 99 do
    	local uiName = "SingleEditorFeatureItem" .. i;
    	if not HasUIFrame(uiName) then
    		break;
    	end

        ui_frame = getglobal(uiName);
        if i <= num then
        	print("i = " .. i .. ", Name = " .. NpcTask[i].Name);

        	local hasFinded = false;
			for j = 1, #TaskIDs do
				if NpcTask[i].ID == TaskIDs[j] and (NpcTask[i].CopyID and NpcTask[i].CopyID > 0) then
					--筛选出本剧情创建的任务
					hasFinded = true;
					break;
				end
			end

			if hasFinded then
	            local ui_frame_icon = getglobal("SingleEditorFeatureItem"..i.."Icon")
	            local ui_frame_desc = getglobal("SingleEditorFeatureItem"..i.."Desc")

				--任务图标
				print("SetTaskIcon:");
				if NpcTask[i].TaskContents and NpcTask[i].TaskContents[1] then
					local Type = NpcTask[i].TaskContents[1].Type;
					ui_frame_icon:SetTextureHuiresXml("ui/mobile/texture2/modlib.xml");
					print("OK!:");
					print("Type = " .. Type);

					if Type == 0 then
						ui_frame_icon:SetTexUV("npchat_icon_chat");
					elseif Type == 1 then
						ui_frame_icon:SetTexUV("npchat_icon_attack");
					else
						ui_frame_icon:SetTexUV("npchat_icon_collect");
					end
				end

	            --ui_frame_desc:SetText(NpcTask[i].Name);
	            NpcTask_SetSingleDesc(ui_frame_desc, NpcTask[i]);
	            -- if NpcTask[i].IsDeliver then
	            -- 	NpcTask_SetSingleDesc(ui_frame_desc, NpcTask[i]);
	            -- else
	            -- 	ui_frame_desc:SetText(NpcTask[i].Name .. ": " .. GetS(11100));
	            -- end

				ui_frame:SetClientID(i)
	            ui_frame:SetPoint("top", "SingleEditorFeaturePlane", "top", 0, height);
	            ui_frame:Show()

	            height = height + ui_frame:GetHeight() + 5
	            ui_frame:Show()
	        else
	        	ui_frame:Hide()	
	        end
        else
            ui_frame:Hide()
        end
    end

    if height < 548 then height = 548; end
    getglobal("SingleEditorFeaturePlane"):SetHeight(height);

end

--打开任务编辑页面, 外部接口, 被调函数:"SingleEditorFrameItemEditBtn_OnClick".
function NpcTask_OpenEditFrame(index)
	-- 审核屏蔽
	if PluginInputDisabled('') then
		return
	end

	print("NpcTask_OpenEditFrame:index = " .. index);
	getglobal("NpcTaskSetParam"):resetOffsetPos();

	if 0 == index then
		--新建任务
		print("AddTask:");
		local flag = false;
		local newTask = {};
		for i = 1, #m_NpcTaskParam.NpcTask do
			if m_NpcTaskParam.NpcTask[i].ID == 4000 then
				newTask = copy_table(m_NpcTaskParam.NpcTask[i]);
				flag = true;
				break;
			end
		end

		if flag then
			print("CreateFrom4000:");
			table.insert(m_NpcTaskParam.NpcTask, newTask);
		else
			table.insert(m_NpcTaskParam.NpcTask, {
			ID = 4000,	--LLTODO:这里应该给一个模板ID, 专门又来新增用.暂时用1代替.
			Name = "";						--"砍树100棵",
			IsDeliver = false,				--是否要交付
			ShowInNote = false,				--在冒险笔记显示
			InteractID = 0,					--交付目标
			IsRepeat = false,
			EnglishName = "",

			--待定----------------------------------------
			TaskContents = { --任务类型
				{Type = 0, ID = 0, Num = 0},
				{Type = 0, ID = 0, Num = 0},
				{Type = 0, ID = 0, Num = 0},
			},
			TaskRewards = { --奖励类型
				{Type = 0, ID = 0, Num = 0},
				{Type = 0, ID = 0, Num = 0},
				{Type = 0, ID = 0, Num = 0},
			},
			Plots = {},					--对话:接任务之后
			UnCompleteds = {},			--对话:未完成
			Completeds = {},			--对话:已完成
		});
		end
		
		m_NpcTaskParam.curTaskIndex = #m_NpcTaskParam.NpcTask;
	else
		print("OpenTask:");
		m_NpcTaskParam.curTaskIndex = index;
	end

	--getglobal("NpcTalkAnswerSetFrame"):Hide();
	getglobal("NpcTaskSetParamOption2BtnName"):SetText(GetS(11027));
	getglobal("NpcTaskSetParamOption3BtnName"):SetText(GetS(11027));
	getglobal("NpcTaskSetParamOption4BtnName"):SetText(GetS(11027));
	
	local taskDef = m_NpcTaskParam.NpcTask[m_NpcTaskParam.curTaskIndex];
	m_NpcTaskParam.TaskAttr:Init(taskDef);
	m_NpcTaskParam:Update();
	getglobal("NpcTalkTaskEditFrame"):Show();

	--多语言, 存放原始json
	g_Mod_Task_MultiLangText = taskDef.MultiLangText;
end

function NpcTalkTaskEditFrameCloseBtn_OnClick()
	getglobal("NpcTalkTaskEditFrame"):Hide();
end

--是否从回答设置面板打开任务面板, 如果是, 则在关闭的时候还原到回答页面
local m_restore2AnswerSetFrameParam = {
	bIsOpenTalkFrameInTask = false,	--是否在任务界面打开对话
	bIsNeedRestore = false,			--是否需要恢复
	curDialoguesIndex = 1,
	curAnswerIndex = 1,
	contentText = "",
};

function NpcTalk_SetRestoreFlag(bFlag)
	print("NpcTalk_SetRestoreFlag:");
	m_restore2AnswerSetFrameParam.bIsOpenTalkFrameInTask = bFlag;

	if bFlag then
		print("111:");
		m_restore2AnswerSetFrameParam.bIsNeedRestore = true;
	end
end

function NpcTalk_SetRestoreParam()
	print("NpcTalk_SetRestoreParam:");
	if getglobal("NpcTalkAnswerSetFrame"):IsShown() then
		print("SaveRestoryParam:");
		--m_restore2AnswerSetFrameParam.bIsNeedRestore = true;
		m_restore2AnswerSetFrameParam.curDialoguesIndex = m_NpcTalkFrameParam.curTabBtnIndex;
		m_restore2AnswerSetFrameParam.curAnswerIndex = m_NpcTalkFrameParam.curAnswerIndex;
		m_restore2AnswerSetFrameParam.contentText = getglobal("NpcTalkAnswerSetFrameEdit"):GetText();
	else
		m_restore2AnswerSetFrameParam.bIsNeedRestore = false;
	end
end

function NpcTalk_Restore2AnswerFrame()
	if m_restore2AnswerSetFrameParam.bIsNeedRestore then
		--还原到回答设置界面
		print("NeedRestoreAnswerSetFrame:");
		m_restore2AnswerSetFrameParam.bIsNeedRestore = false;
		local t = modeditor.config.plot[1].Attr[4].Dialogues;

		OpenNpcTakSetFrame(t, 1);
		m_NpcTalkFrameParam:TabBtn_OnClick(m_restore2AnswerSetFrameParam.curDialoguesIndex);
		m_NpcTalkFrameParam:AnswerOption_OnClick(m_restore2AnswerSetFrameParam.curAnswerIndex);
		getglobal("NpcTalkAnswerSetFrameEdit"):SetText(m_restore2AnswerSetFrameParam.contentText);
	end
end

function NpcTalkTaskEditFrame_OnShow()
	--标题栏
	getglobal("NpcTalkTaskEditFrameTitleFrameName"):SetText(GetS(11071));
	getglobal("NpcTaskSetParamEdit1TranslateName"):Hide();
	getglobal("NpcTaskSetParamEdit1BkgYellow"):Hide();
	if Current_Edit_Mode == 4 and ArchiveWorldDesc ~= nil then
		if ShowTranslateBtn("mod_task_name", ArchiveWorldDesc.worldid) then
    		ShowTranslateTextState("mod_task_name",ArchiveWorldDesc.worldid)
    	end
    end
end

function NpcTalkTaskEditFrame_OnHide()
	print("NpcTalkTaskEditFrame_OnHide:");
	if m_restore2AnswerSetFrameParam.bIsOpenTalkFrameInTask then
		print('111:');
		-- m_restore2AnswerSetFrameParam.bIsOpenTalkFrameInTask = false;
	else
		print('222:');
		if m_restore2AnswerSetFrameParam.bIsNeedRestore then
			print('333:');
			NpcTalk_Restore2AnswerFrame();
		end
	end
end

function NpcTalkTaskEditFrameHelpBtn_OnClick()
	getglobal("MyModsEditorHelpFrameTitleName"):SetText(GetS(11102));
	getglobal("MyModsEditorHelpFrameBoxContent"):SetText(GetS(11103), 61, 69, 70);
	getglobal('MyModsEditorHelpFrame'):Show();
end

--删除任务
function NpcTalkTaskEditFrameDeleteBtn_OnClick()
	print("NpcTalkTaskEditFrameDeleteBtn_OnClick:");
	local NpcTask = m_NpcTaskParam.NpcTask;
	local index = m_NpcTaskParam.curTaskIndex;

	if index > 0 then
		print("Delete:");
		local TaskDef = NpcTask[index];
		local mapowid = 0;
		if Current_Edit_MapOwid then
			mapowid = Current_Edit_MapOwid
		end
		ModEditorMgr:delModSlotFileById(TASK_MOD,TaskDef.ID,mapowid);
		--重新加载任务
		NpcTask_ReflashTask();

		--刷新
		NpcTask_UpdateTaskList();

		NpcTalkTaskEditFrameCloseBtn_OnClick();

		NpcTalkTask_AfterDeleteTask(TaskDef.ID);
	end
end

--删除任务后续处理: 将剧情中的接收任务改为继续对话
local m_bIsSavePlotWhenDeleteTask = false;
function NpcTalkTask_AfterDeleteTask(TaskId)
	print("NpcTalkTask_AfterDeleteTask:");
	print("TaskId = " .. TaskId);

	local num = #m_NpcTalkFrameParam.Dialogues;
	local Dialogues = m_NpcTalkFrameParam.Dialogues;

	if getglobal("NpcTalkSetFrame"):IsShown() then
		Dialogues = m_NpcTalkFrameParam.Dialogues;
	else		
		Dialogues = modeditor.config.plot[1].Attr[4].Dialogues;
	end

	if Dialogues then
		for i = 1, #Dialogues do
			print("Dialogues: i = " .. i);
			local Answers = Dialogues[i].Answers;

			if Answers then
				for j = 1, #Answers do
					print('Answers: j = ' .. j);
					if Answers[j].FuncType == 3 then
						if Answers[j].Val == TaskId then
							--该对话中有被删除的任务, 将类型设为继续对话.
							print("Enter:");
							Answers[j].FuncType = 0;
						end
					end
				end
			end
		end
	end

	m_bIsSavePlotWhenDeleteTask = true;

	print("111:");
	if getglobal("NpcTalkSetFrame"):IsShown() then
		print("222:");
		m_flag_AnswerSetOption = "func";
		NpcTalkSingleOptionItemClidk(1);
		m_AnswersParam:Save();
	end

	SingleEditorFrameSaveBtn_OnClick();
end

--是否在删除任务时保存剧情
function NpcTalk_IsSavePlotWhenDeleteTask()
	print("NpcTalk_IsSavePlotWhenDeleteTask:");
	return m_bIsSavePlotWhenDeleteTask;
end

function NpcTalk_InitIsSavePlotWhenDeleteTaskFlag()
	m_bIsSavePlotWhenDeleteTask = false;
end

--确认保存任务
function NpcTalkTaskEditFrameOkBtn_OnClick()
	print("NpcTalkTaskEditFrameOkBtn_OnClick:");

	local txt = getglobal("NpcTaskSetParamEdit1Edit"):GetText();
	if txt == "" then
		ShowGameTips(GetS(3642), 3);
		return;
	end

	if CheckFilterString(txt) then return end

	NpcTalkTaskEditFrameCloseBtn_OnClick();
	m_NpcTaskParam:SaveAttr2Task();
	NpcTask_UpdateTaskList();
	NpcTask_Save2Json();
end

--保存任务
function NpcTask_Save2Json()
	print("NpcTask_Save2Json:");
	--保存: 剧情任务
	local isCreate = false;
	--local NpcTask = modeditor.config.plot[2].TaskSet.NpcTask;
	local NpcTask = m_NpcTaskParam.NpcTask;
	local index = m_NpcTaskParam.curTaskIndex;
	local TaskDef = NpcTask[index];

	local def = ModEditorMgr:getNpcTaskDefById(TaskDef.ID);
	isCreate = (def == nil);
	if isCreate then
		print("isCreate:");
		local fileName = tostring(os.time());
		def = ModEditorMgr:addNpcTaskDef(TaskDef.ID, true, fileName);
		def.EnglishName = fileName;
		def.ModDescInfo.filename = def.EnglishName
	end
	
	if def == nil then return; end

	--添加任务成功, 保存当前任务ID到剧情.
	if isCreate then
		print("Save TaskId to Cur Plot:");
		print("ID = " .. def.ID);
		table.insert(modeditor.config.plot[1].Attr[13].CurVal, def.ID);
	end
	
	modeditor.config.plot[2].Attr:Init(TaskDef);
	local dataStr = NewSingleEditorSave(def, true);
	local result = ModEditorMgr:requestCreateTask(dataStr, def.EnglishName);

	print("kekeke Current_Edit_Mode:", Current_Edit_Mode);
	if Current_Edit_Mode == 3 or Current_Edit_Mode == 4 then
		local srcmod = ModEditorMgr:getCurrentEditMod();
		local srcmoddesc = ModEditorMgr:getCurrentEditModDesc();
		local dstmoddesc = ModMgr:getMapModDescByUUID(ModMgr:getMapDefaultModUUID());
		ModEditorMgr:copyTask(def.EnglishName, srcmoddesc, srcmod, dstmoddesc);
	end

	--重新加载任务
	NpcTask_ReflashTask();

	--新建任务, 刷新回答设置页面
	--或者编辑任务，但是创建了新任务的情况也设置成新的
	if getglobal("NpcTalkAnswerSetFrame"):IsShown() or isCreate then
		print("ChangeTaskId:");
		m_AnswersParam.funcBtn.curFuncIndex = 4;
		m_AnswersParam.funcBtn.gotoDialoguesId = def.ID;
		-- m_AnswersParam:UpdateAnswerFrame();
		m_AnswersParam:UpdateAnswerFrame();	--只刷新选择按钮名字
	end
end

--保存创建的任务ID到剧情"createid"
function NpcTask_SaveCreateTaskId2Plot(createTaskId)
	print("NpcTask_SaveCreateTaskId2Plot: createTaskId = " .. createTaskId);
	local plotCreateIds = modeditor.config.plot[1].Attr[13].CurVal;
	if plotCreateIds then
		print("111:");
		for i = 1, #plotCreateIds do
			if plotCreateIds[i] == createTaskId then
				--已经存在
				print("222");
				return;
			end
		end		

		print("333");
		table.insert(plotCreateIds, createTaskId);
	end
end

------------------------------------------控件模板------------------------------------------
--编辑框
function NpcTalkEditTemplate_OnFocusLost()
	local index = this:GetParentFrame():GetClientID();
	local t = m_NpcTaskParam.TaskAttr[index];
	m_NpcTaskParam.curHandAttrIndex = index;
	local txt = this:GetText();

	print("OnFocusLost:txt = " .. txt .. ", index = " .. index);
	t.CurVal = txt;

	--多语言:任务名
	if this:GetName() == "NpcTaskSetParamEdit1Edit" then
		local datastruct = SignManagerGetInstance():GetDataStructForSave("mod_task_name");
		print("NpcTalkEditTemplate_OnFocusLost:");
		print("datastruct:", datastruct);
		t.MultiLangText = JSON:encode(datastruct);

		--保存后刷新ui编辑框文本
		if datastruct and datastruct.originalID and t.MultiLangText then
			local showText = getTextFrameDataStruct(datastruct);
			this:SetText(showText);
			t.CurVal = showText;
		end
	end
end

--滑动条
function NpcTaskSliderTemplateBar_OnValueChanged()
	local index = this:GetParentFrame():GetClientID();
	m_NpcTaskParam.curHandAttrIndex = index;

	local value = this:GetValue();
	local ratio = (value-this:GetMinValue())/(this:GetMaxValue()-this:GetMinValue());

	if ratio > 1 then ratio = 1 end
	if ratio < 0 then ratio = 0 end
	local width   = math.floor(250*ratio)
	getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
	getglobal(this:GetName().."Pro"):SetWidth(width);

    local t = m_NpcTaskParam.TaskAttr[index];
    t.CurVal = value;

    local desc = getglobal(this:GetParentFrame():GetName() .. "Desc");
    desc:SetText(value);
end

function NpcTaskSliderTemplateLeftBtn_OnClick(isAdd)
	print("NpcTaskSliderTemplateLeftBtn_OnClick:");
	local bar = getglobal(this:GetParentFrame():GetName() .. "Bar");
	local value = bar:GetValue();
	local min = bar:GetMinValue();
	local max = bar:GetMaxValue();
	local step = bar:GetValueStep();

	if isAdd then
		--加
		if value >= max then return; end
		value = value + step;
	else
		--减
		if value <= min then return; end
		value = value - step;
	end

	bar:SetValue(value);
end

function NpcTaskSliderTemplateRightBtn_OnClick()
	print("NpcTaskSliderTemplateRightBtn_OnClick:");
	NpcTaskSliderTemplateLeftBtn_OnClick(true);
end

--选项
function NpcTaskOptionTemplateBtn_OnClick()
	local index = this:GetParentFrame():GetClientID();
	print("NpcTaskOptionTemplateBtn_OnClick, index = " .. index);

	m_NpcTaskParam.curHandAttrIndex = index;
	local t = m_NpcTaskParam.TaskAttr[index];

	if t.Def == "TaskType" then
		--任务类型
		print("TaskType:");
		SetEditorOptionFrame(t.Options, GetS(t.Name_StringID), GetS(t.Desc_StringID));
	elseif t.Def == "AfterTask" then
		--剧情对话-接任务后:
		print("AfterTask:");
		if m_NpcTaskParam.NpcTask then
			print("m_NpcTaskParam.curTaskIndex = " .. m_NpcTaskParam.curTaskIndex);
			getglobal("NpcTalkAnswerSetFrame"):Hide();
			local taskDef = m_NpcTaskParam.NpcTask[m_NpcTaskParam.curTaskIndex];
			m_isOpenNpcTalkSetFrameFromTaskFrame = true;
			NpcTalk_SetRestoreFlag(true);
			OpenNpcTakSetFrame(taskDef.Plots, 2);
		end
	elseif t.Def == "NotCompleted" then
		--对话-任务未完成
		print("NotCompleted:");
		if m_NpcTaskParam.NpcTask then
			getglobal("NpcTalkAnswerSetFrame"):Hide();
			local taskDef = m_NpcTaskParam.NpcTask[m_NpcTaskParam.curTaskIndex];
			m_isOpenNpcTalkSetFrameFromTaskFrame = true;
			NpcTalk_SetRestoreFlag(true);
			OpenNpcTakSetFrame(taskDef.UnCompleteds, 3);
		end
	elseif t.Def == "Completed" then
		--对话-任务已完成
		print("Completed:");
		if m_NpcTaskParam.NpcTask then
			getglobal("NpcTalkAnswerSetFrame"):Hide();
			local taskDef = m_NpcTaskParam.NpcTask[m_NpcTaskParam.curTaskIndex];
			m_isOpenNpcTalkSetFrameFromTaskFrame = true;
			NpcTalk_SetRestoreFlag(true);
			OpenNpcTakSetFrame(taskDef.Completeds, 4);
		end
	end
end

--选项条目选择, 被调函数:"SingleOptionBtnTemplate_OnClick".
function NpcTask_SingleOptionItemClick(id)
	local t = m_NpcTaskParam.TaskAttr[m_NpcTaskParam.curHandAttrIndex];
	print("NpcTaskSingleOptionItemClidk: id = " .. id);

	if m_NpcTaskParam.curHandAttrIndex == 2 then
		print("ChangeTaskType:");
		if t.Options[id].Val ~= t.CurVal then
			--切换任务类型, 清空任务目标
			for i = 1, #(m_NpcTaskParam.TaskAttr[3].CurVal) do
				if m_NpcTaskParam.TaskAttr[3].CurVal[i] then
					m_NpcTaskParam.TaskAttr[3].CurVal[i].id = 0;
					m_NpcTaskParam.TaskAttr[3].CurVal[i].num = 0;
				end
			end
		end
	end

	t.CurVal = t.Options[id].Val;
	m_NpcTaskParam:Update();
end

--选择器:"SingleSelBtnTemplate_OnClick();"
function NpcTaskSingleSelBtnTemplate_OnClick()
	local index = this:GetParentFrame():GetClientID();
	local btnIndex = this:GetClientID();
	print("NpcTaskSingleSelBtnTemplate_OnClick, index = " .. index .. ", btnIndex = " .. btnIndex);

	m_NpcTaskParam.curHandAttrIndex = index;
	m_NpcTaskParam.curSelBtnIndex = btnIndex;
	local t = m_NpcTaskParam.TaskAttr[index];

	print("t.ENName = " .. t.ENName);
	if t.ENName == "TaskContents" then
		--1. 任务目标选择
		print("1.TaskContents:");
		if m_NpcTaskParam.TaskAttr[index - 1].CurVal == 1 then
			--生物
			print("Monster:");
			SetChooseOriginalFrame('TaskContents_Monster');
		elseif m_NpcTaskParam.TaskAttr[index - 1].CurVal == 2 then
			--道具
			print("Item:");
			SetChooseOriginalFrame('TaskContents_Item');
		end
	elseif t.ENName == "TaskRewards" then	--奖励: 道具类型, 和道具是一样的
		SetChooseOriginalFrame('TaskContents_Item');
	elseif t.ENName == "InteractID" then	--交付目标: 生物类型
		SetChooseOriginalFrame('TaskContents_Monster');
	end
end

--选择器, 确定按钮回调, 被调函数"ChooseOriginalFrameOkBtn_OnClick"
function NpcTask_SelectionOkBtnClick_CallBack(monsterId)
	print("NpcTask_SelectionOkBtnClick_CallBack: monsterId = " .. monsterId);
	local t = m_NpcTaskParam.TaskAttr[m_NpcTaskParam.curHandAttrIndex];
	t.CurVal[m_NpcTaskParam.curSelBtnIndex] = {};
	local CurVal = t.CurVal[m_NpcTaskParam.curSelBtnIndex];
	CurVal.id = monsterId;
	CurVal.num = 1;
	m_NpcTaskParam:Update();
end

function NpcTaskSingleSelBtnTemplateDel_OnClick()
	print("NpcTaskSingleSelBtnTemplateDel_OnClick:");
	local index = this:GetParentFrame():GetParentFrame():GetClientID();
	local btnIndex = this:GetParentFrame():GetClientID();
	local t = m_NpcTaskParam.TaskAttr[index];

	t.CurVal[btnIndex].id = 0;
	t.CurVal[btnIndex].num = 0;
	m_NpcTaskParam:Update();
end

function NpcTaskSingleSelBtnTemplateNumLeftBtn_OnClick(isAdd, index)
	print("NpcTaskSingleSelBtnTemplateNumLeftBtn_OnClick:");
	if index then
		index = index;
	else
		index = this:GetParentFrame():GetParentFrame():GetParentFrame():GetClientID();
	end

	local t = m_NpcTaskParam.TaskAttr[index];
	local btnIndex = this:GetParentFrame():GetParentFrame():GetClientID();
	local num = t.CurVal[btnIndex].num;

	if isAdd then
		--加
		print("Add:");
		if num >= t.Max then return; end
		num = num + t.Step;
	else
		--减
		print("Sub:");
		if num <= t.Min then return; end
		num = num - t.Step;
	end

	t.CurVal[btnIndex].num = num;
	m_NpcTaskParam:Update();
end

function NpcTaskSingleSelBtnTemplateNumRightBtn_OnClick()
	local index = this:GetParentFrame():GetParentFrame():GetParentFrame():GetClientID();
	NpcTaskSingleSelBtnTemplateNumLeftBtn_OnClick(true, index);
end

--开关
function NpcTask_SwitchBtn_OnClick()
	local switchName = this:GetName();
	local state = 0;
	local bkg = getglobal(this:GetName().."Bkg");
	local point = getglobal(switchName.."Point");
	local val = false;

	if point:GetRealLeft() - bkg:GetRealLeft() > 20  then			--先前状态：开
		point:SetPoint("left", this:GetName(), "left", 4, -3);
		state = 0;
		val = false;
	else								--先前状态：关
		point:SetPoint("right", this:GetName(), "right", -6, -3);
		state = 1;
		val = true;
	end

	SetSwitchBtnState(switchName, state);

	local index = this:GetParentFrame():GetClientID();
	local t = m_NpcTaskParam.TaskAttr[index];
	t.CurVal = val;
	m_NpcTaskParam:Update();
end


--刷新控件列表**--参考:"UpdateNewEditorFeatureParamEditFrame", "UpdateSingleEditorAttr".
function NpcTask_UpdateControlList(AttrList, firstUI)
	print("NpcTask_UpdateControlList:");
	local firstUI = "NpcTaskSetParam";
	local t = AttrList;

	local t_Index = {
			sliderIndex = 0,
			--lineIndex = 0,
			switchIndex = 0,
			selectionIndex = 0,
			optionIndex = 0,
			--multioptionIndex = 0,
			editindex = 0,
		}
	local height = 0;
	local pointY = 0;

	for i=1, #(t) do
		if not t[i].CanShow or t[i].CanShow(nil) then
			local uiFrame = nil;
			if t[i].Type == 'Slider' then			--滑动条
				t_Index.sliderIndex = t_Index.sliderIndex+1;
				uiFrame = getglobal(firstUI .. "Slider"..t_Index.sliderIndex);
				height = height + 80;
				
				
				local name 		= getglobal(firstUI .. "Slider" .. t_Index.sliderIndex.."Name");
				local desc 		= getglobal(firstUI .. "Slider" .. t_Index.sliderIndex.."Desc");
				local bar 		= getglobal(firstUI .. "Slider" .. t_Index.sliderIndex.."Bar");

				bar:SetMinValue(t[i].Min);
				bar:SetMaxValue(t[i].Max);
				bar:SetValueStep(t[i].Step);
				local curVal = t[i].CurVal;
				print('Slider SetCurVal', t_Index.sliderIndex, t[i].ENName, curVal);
				bar:SetValue(curVal);
				name:SetText(GetS(t[i].Name_StringID));
				desc:SetText(curVal);
			elseif t[i].Type == 'Switch' then		--开关
				t_Index.switchIndex = t_Index.switchIndex+1;
				uiFrame = getglobal(firstUI .. "Switch"..t_Index.switchIndex);
				height = height + 80;

				local name 		= getglobal(firstUI .. "Switch"..t_Index.switchIndex.."Name");
				local switchBtn = getglobal(firstUI .. "Switch"..t_Index.switchIndex.."Btn");

				name:SetText(GetS(t[i].Name_StringID));
				local state = t[i].CurVal and 1 or 0;
				SetSwitchBtnState(switchBtn:GetName(), state);
			elseif t[i].Type == 'Selection' then		--可选择的
				t_Index.selectionIndex = t_Index.selectionIndex+1;
				uiFrame = getglobal(firstUI .. "Selection"..t_Index.selectionIndex);
				height = height + 130;

				local name = getglobal(firstUI .. "Selection"..t_Index.selectionIndex.."Name");
				name:SetText(GetS(t[i].Name_StringID));
				local t_curVal = t[i].CurVal;
				print("kekeke Selection", t[i].Name_StringID, t_curVal, t[i].Boxes);
				for j=1, 3 do
					local btn = getglobal(firstUI .. "Selection"..t_Index.selectionIndex.."Btn"..j);
					if j <= #(t[i].Boxes) then
						btn:Show();
						local del = getglobal(btn:GetName().."Del");
						local icon = getglobal(btn:GetName().."Icon");
						local addIcon = getglobal(btn:GetName().."AddIcon");
						local numBtn = getglobal(btn:GetName().."Num");
						local btnName = getglobal(btn:GetName().."Name");
						btnName:Hide();
						numBtn:Hide();
						if t_curVal[j] and t_curVal[j].id and t_curVal[j].id > 0 then
							del:Show();
							icon:Show();
							addIcon:Hide();
							local id = t_curVal[j].id;
							if t[i].Def == "TaskContentsType" then
								if t[i - 1].CurVal == 1 then
									--生物
									local def = ModEditorMgr:getMonsterDefById(id) or MonsterCsv:get(id);
									if def then
										if def.ModelType == MONSTER_CUSTOM_MODEL then
											SetModelIcon(icon, def.Model , ACTOR_MODEL);
										else
											icon:SetTexture("ui/roleicons/".. def.Icon ..".png", true);
										end
									end
								elseif t[i - 1].CurVal == 2 then
									--道具
									SetItemIcon(icon, id,nil,101);
								end
							elseif t[i].Def == "MonsterDef" then
								--交付目标, 是生物
								local def = ModEditorMgr:getMonsterDefById(id) or MonsterCsv:get(id);
								if def then									
									if def.ModelType == MONSTER_CUSTOM_MODEL then
										SetModelIcon(icon, def.Model, ACTOR_MODEL);
									elseif def.ModelType == MONSTER_FULLY_CUSTOM_MODEL then --微雕   
										SetModelIcon(icon, def.Model, FULLY_ACTOR_MODEL);
									elseif def.ModelType == MONSTER_IMPORT_MODEL then --导入
										SetModelIcon(icon, def.Model, IMPORT_ACTOR_MODEL);
									else
										icon:SetTexture("ui/roleicons/".. def.Icon ..".png", true);
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
												AvatarSetIconByIDEx(pluginId,icon)
											end
										end
									end
								end
							else
								SetItemIcon(icon, id,nil,101);
							end

							if t[i].HasNumBtn and t[i].HasNumBtn() then
								numBtn:Show();
								local numVal = getglobal(btn:GetName().."NumVal");
								numVal:SetText(t_curVal[j].num);
							end
						else
							del:Hide();
							icon:Hide();
							addIcon:Show();
						end

						if t[i].Boxes[j].NotShowDel then
							del:Hide();
						end
					else
						btn:Hide();
					end
				end 
			elseif t[i].Type == 'Option' or t[i].Type == 'OptionReadOnly' then		--选项
				t_Index.optionIndex = t_Index.optionIndex+1;
				uiFrame = getglobal(firstUI .. "Option"..t_Index.optionIndex);
				height = height + 85;

				local name = getglobal(firstUI .. "Option"..t_Index.optionIndex.."Name");
				name:SetText(GetS(t[i].Name_StringID));
			
				local option = t[i].GetOption(t[i].CurVal, t[i].Options);
                if not option and t[i].DefaultVal then
                    option = t[i].GetOption(t[i].DefaultVal, t[i].Options);
                end
                if not option then
				    print("kekeke option", t[i], option, t[i].CurVal, t[i].Options);
                end
				if option then
					local btnName 	= getglobal(firstUI .. "Option"..t_Index.optionIndex.."BtnName");
                    local btnNormalBkg= getglobal(firstUI .. "Option"..t_Index.optionIndex.."BtnNormal");
                    local btnPushBkg  = getglobal(firstUI .. "Option"..t_Index.optionIndex.."BtnPushedBG");
                    local is_gray = false
                    
                    if t[i].Type == 'OptionReadOnly' then
                        is_gray = true
                    end
                    btnNormalBkg:SetGray(is_gray)
                    btnPushBkg:SetGray(is_gray)

					btnName:SetText(GetS(option.Name_StringID));
					-- 用默认的主题颜色切换就好
					-- if option.Color then
					-- 	btnName:SetTextColor(option.Color.r, option.Color.g, option.Color.b);
					-- else
					-- 	btnName:SetTextColor(171, 84, 13);
					-- end
				end
			elseif t[i].Type == 'MultiOption' then		--多选项
				t_Index.multioptionIndex = t_Index.multioptionIndex+1;
				uiFrame = getglobal(firstUI .. "MultiOption"..t_Index.multioptionIndex);
				height = height + 85;

				local name = getglobal(firstUI .. "MultiOption"..t_Index.multioptionIndex.."Name");
				name:SetText(GetS(t[i].Name_StringID));

				local btnName 	= getglobal(firstUI .. "MultiOption"..t_Index.multioptionIndex.."BtnName");
				btnName:SetText(GetS(3529));
			elseif t[i].Type == 'EditBox' then	--编辑框
				t_Index.editindex = t_Index.editindex + 1;
				uiFrame = getglobal(firstUI .. "Edit"..t_Index.editindex);
				height = height + 85;
				local name = getglobal(firstUI .. "Edit"..t_Index.editindex .. "Name");
				name:SetText(GetS(t[i].Name_StringID));

				local edit 	= getglobal(firstUI .. "Edit"..t_Index.editindex .. "Edit");
				edit:SetText(t[i].CurVal);
			end

			if uiFrame then
				uiFrame:SetClientID(i);		--记录Index

				--设置位置
				uiFrame:SetPoint("top", firstUI .. "Plane", "top", 0, pointY);
				pointY = height;

				if t[i].SetShowType then
					t[i]:SetShowType();
				end
			end
		end
	end

	if height < 430 then
		height = 430;
	end
	getglobal(firstUI .. "Plane"):SetHeight(height);

	--print("t_Index:");
	for i=1, 9 do
		for k,v in pairs(t_Index) do
			local uiFrame = nil;
			print("i = " .. i .. ", k = " .. k .. ", v = " .. v);

			if k == 'sliderIndex' then
				uiFrame = getglobal(firstUI .. "Slider"..i);
			elseif k == 'switchIndex' then
				uiFrame = getglobal(firstUI .. "Switch"..i);
			elseif k == 'selectionIndex' then
				uiFrame = getglobal(firstUI .. "Selection"..i);
			elseif k == 'optionIndex' then
				uiFrame = getglobal(firstUI .. "Option"..i);
			elseif k == 'multioptionIndex' then
				uiFrame = getglobal(firstUI .. "MultiOption"..i);
			elseif k == 'editindex' then
				uiFrame = getglobal(firstUI .. "Edit"..i);
			end

			if i <= v then
				uiFrame:Show();
			else
				uiFrame:Hide();
			end
		end
	end
end
