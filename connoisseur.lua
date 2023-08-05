function ConnoisseurHelpFrame_OnLoad()
	getglobal("ConnoisseurHelpFrameBoxContent"):SetText(GetS(1267), 61, 69, 70);
	local height = getglobal("ConnoisseurHelpFrameBoxContent"):GetTotalHeight();
	height = height>410 and height or 410;
	getglobal("ConnoisseurHelpFrameBoxPlane"):SetHeight(height);
end

-----------------------------------------QuestionnaireFrame-----------------------------------
local questionnaire = {
	max_answer = 3;

	questions = {},
	chooseIndexs = {},
	errQuestionIndexs = {};
	curQIndex = 1,
	curErrQIndex = 1,
	curType = "",
	finished = false,
};

function AnswerTemplate_OnClick()
	local index = this:GetClientID();
	
	if questionnaire.chooseIndexs[questionnaire.curQIndex] then
		local chooseIndex = questionnaire.chooseIndexs[questionnaire.curQIndex];
		getglobal("QuestionnaireFrameContentAnswer"..chooseIndex.."Tick"):Hide();
	end
	questionnaire.chooseIndexs[questionnaire.curQIndex] = index;
	getglobal(this:GetName().."Tick"):Show();
end

function QuestionnaireFrameCloseBtn_OnClick()
	MessageBox(5, GetS(1271), function(btn)
				if btn == 'left' then
					getglobal("QuestionnaireFrame"):Hide();
				end
			end);
	
end

function QuestionnaireFramePreQBtn_OnClick()
	if questionnaire.finished then
		questionnaire.curErrQIndex = questionnaire.curErrQIndex - 1;
		questionnaire.curQIndex = questionnaire.errQuestionIndexs[questionnaire.curErrQIndex];
	else
		questionnaire.curQIndex = questionnaire.curQIndex - 1;
	end
	UpdateQuestionnaireInfo();
	UpdateQuestionnaireContent();
end

function QuestionnaireFrameNextQBtn_OnClick()
	if not questionnaire.chooseIndexs[questionnaire.curQIndex] then
		ShowGameTipsWithoutFilter(GetS(1270), 3);
		return;
	end

	if questionnaire.finished then
		questionnaire.curErrQIndex = questionnaire.curErrQIndex + 1;
		questionnaire.curQIndex = questionnaire.errQuestionIndexs[questionnaire.curErrQIndex];
	else
		questionnaire.curQIndex = questionnaire.curQIndex + 1;
	end
	UpdateQuestionnaireInfo();
	UpdateQuestionnaireContent();
end

function InErrQuestion(index)
	for i=1, #questionnaire.errQuestionIndexs do
		if index == questionnaire.errQuestionIndexs[i] then return true end
	end

	return false;
end

function QuestionnaireFrameOkBtn_OnClick()

	local errNum = 0;
	local t_errQIndexs = {};
	
	questionnaire.curErrQIndex = 1;
	for i=1, #(questionnaire.questions) do
		if not questionnaire.finished or InErrQuestion(i) then
			if questionnaire.chooseIndexs[i] == nil or not questionnaire.questions[i].answer[questionnaire.chooseIndexs[i]].isRight then
				errNum = errNum + 1;
				table.insert(t_errQIndexs, i);
			end
		end
	end

	questionnaire.errQuestionIndexs = t_errQIndexs;

	questionnaire.finished = true;
	questionnaire.chooseIndexs = {};

	Log("QuestionnaireFrameOkBtn_OnClick:"..errNum);
	if errNum > 0 then  --答题失败
		if questionnaire.curType == 'connoisseur' then
			getglobal("ConnoisseurTestFailFrameDesc1"):SetText(GetS(1275, errNum));
			getglobal("ConnoisseurTestFailFrame"):Show();
		end
	else 				--答题通过
		if questionnaire.curType == 'connoisseur' then
			getglobal("QuestionnaireFrame"):Hide();
			NoticeSeverConnoisseurFQAFinish();
		end
	end
end

function UpdateQuestionnaireInfo()
	if questionnaire.curQIndex == 1 or (questionnaire.finished and questionnaire.curErrQIndex == 1) then
		getglobal("QuestionnaireFramePreQBtn"):Hide();
	elseif not getglobal("QuestionnaireFramePreQBtn"):IsShown() then
		getglobal("QuestionnaireFramePreQBtn"):Show();
	end

	if questionnaire.curQIndex == #(questionnaire.questions) or (questionnaire.finished and questionnaire.curErrQIndex == #questionnaire.errQuestionIndexs) then
		getglobal("QuestionnaireFrameNextQBtn"):Hide();
		getglobal("QuestionnaireFrameOkBtn"):Show();
	elseif not getglobal("QuestionnaireFrameNextQBtn"):IsShown() then
		getglobal("QuestionnaireFrameNextQBtn"):Show();
		getglobal("QuestionnaireFrameOkBtn"):Hide();
	end

	local curIndex = questionnaire.curQIndex;
	local maxIndex = #(questionnaire.questions);
	if questionnaire.finished then
		curIndex = questionnaire.curErrQIndex;
		maxIndex = #(questionnaire.errQuestionIndexs);
	end
	getglobal("QuestionnaireFramePage"):SetText(curIndex.."/"..maxIndex);
end

function QuestionnaireFrame_OnLoad()
	local lastUIName = nil
	for i=1, questionnaire.max_answer do
		local answer = getglobal("QuestionnaireFrameContentAnswer"..i);

		if i == 1 then
			answer:SetPoint("top", "QuestionnaireFrameContent", "top", 0, 57);
		elseif lastUIName then
			answer:SetPoint("top", lastUIName, "bottom", 0, -5);
		end

		lastUIName = answer:GetName();
	end
end

function OpenQuestionnaireFrame(type, q_num)
	Log("OpenQuestionnaireFrame type:"..type);
	math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)))
	questionnaire.questions = nil;
	if type == "connoisseur" then
		questionnaire.questions = RandFetchTable(q_num, t_connoisseur_Q);
	end
	if questionnaire.questions then
		questionnaire.chooseIndexs = {};
		questionnaire.errQuestionIndexs = {};
		questionnaire.curQIndex = 1;
		questionnaire.curErrQIndex = 1;
		questionnaire.curType = type;
		questionnaire.finished = false;
		UpdateQuestionnaireInfo();
		UpdateQuestionnaireContent();
		getglobal("QuestionnaireFrame"):Show();
	end
end

function UpdateQuestionnaireContent()	
	local t = questionnaire.questions[questionnaire.curQIndex];


	--题目
	local title = questionnaire.curQIndex.."."..t.question;
	getglobal("QuestionnaireFrameContentTitle"):SetText(title);

	--答案
	local t_answer = nil;
	if questionnaire.finished then
		t_answer = t.answer;
	else
		t_answer = RandFetchTable(#(t.answer), t.answer);
	end

	if t_answer == nil then return end

	local t_optionTitle = {"A","B","C"};
	for i=1, questionnaire.max_answer do
		local answerUI = getglobal("QuestionnaireFrameContentAnswer"..i);
		if i <= #(t_answer) then
			answerUI:Show();

			local tick 			= getglobal(answerUI:GetName().."Tick");
			local answerRich	= getglobal(answerUI:GetName().."Content");
			local hightLight	= getglobal(answerUI:GetName().."HightLight");

			if not questionnaire.finished and questionnaire.chooseIndexs[questionnaire.curQIndex] and questionnaire.chooseIndexs[questionnaire.curQIndex] == i then
				tick:Show();
			else
				tick:Hide();
			end

			if questionnaire.finished and t_answer[i].isRight then
				hightLight:Show();
			else
				hightLight:Hide();
			end

			local answer = t_optionTitle[i].."."..t_answer[i].text;
			answerRich:SetText(answer, 77, 112, 117);

			local height = answerRich:GetTotalHeight() + 36;
			if height > 130 then
				answerUI:SetHeight(height);
			end
		else
			answerUI:Hide();
		end
	end
end

---------------------------------------ConnoisseurTestFailFrame-------------------------------------
function ConnoisseurTestFailFrameGiveUpBtn_OnClick()
	MessageBox(5, GetS(1271), function(btn)
				if btn == 'left' then
					getglobal("QuestionnaireFrame"):Hide();
					getglobal("ConnoisseurTestFailFrame"):Hide();
				end
			end);
end

function ConnoisseurTestFailFrameModifyBtn_OnClick()
	getglobal("ConnoisseurTestFailFrame"):Hide();
	questionnaire.curQIndex = questionnaire.errQuestionIndexs[1];
	UpdateQuestionnaireInfo();
	UpdateQuestionnaireContent();
end

---------------------------------------ConnoisseurTestPassFrame--------------------------------------
function ConnoisseurTestPassFrameOkBtn_OnClick()
	getglobal("ConnoisseurTestPassFrame"):Hide();
end

function ConnoisseurTestPassFrameIns_OnClick()
	
end

function ConnoisseurTestPassFrameHelpBtn_OnClick()
	getglobal("ConnoisseurHelpFrame"):Show();
end

function ConnoisseurTestPassFrame_OnLoad()
	local text = "#L"..GetS(1266).."#n";
	getglobal("ConnoisseurTestPassFrameIns"):SetText(text, 215, 75, 32);
	local width = getglobal("ConnoisseurTestPassFrameIns"):GetLineWidth(1);
	local offsetX = 0-(width/2+16);
	getglobal("ConnoisseurTestPassFrameIns"):SetPoint("topleft", "ConnoisseurTestPassFrameBkg2", "top", offsetX, 258)
	offsetX = width+10;
	getglobal("ConnoisseurTestPassFrameHelpBtn"):SetPoint("left", "ConnoisseurTestPassFrameIns", "left", offsetX, -2);
end

---------------------------------------ConnoisseurInfoFrame----------------------------------------------
function ConnoisseurInfoFrameOkBtn_OnClick()
	getglobal("ConnoisseurInfoFrame"):Hide();
end

function ConnoisseurInfoFrame_OnLoad()
	local text = "#L"..GetS(1266).."#n";
	getglobal("ConnoisseurInfoFrameIns"):SetText(text, 255, 109, 37);
	local width = getglobal("ConnoisseurInfoFrameIns"):GetLineWidth(1);
	--local offsetX = 200+(width/2+16);
	--getglobal("ConnoisseurInfoFrameIns"):SetPoint("topleft", "ConnoisseurInfoFrameBkg2", "topleft", offsetX, 179)
	local offsetX = width+10;
	getglobal("ConnoisseurInfoFrameHelpBtn"):SetPoint("left", "ConnoisseurInfoFrameIns", "left", offsetX, -6);
end

function ConnoisseurInfoFrame_OnShow()
	local title 		= getglobal("ConnoisseurInfoFrameTitleName");
	local growthVal 	= getglobal("ConnoisseurInfoFrameGrowthVal");
	local prestigeVal 	= getglobal("ConnoisseurInfoFramePrestigeVal");

	local t_expert = getExpert();
	growthVal:SetText(t_expert.score);
	prestigeVal:SetText(t_expert.points);

	if t_expert.level == 0 then
		title:SetText(GetS(1273));
	else
		title:SetText(GetS(1315, t_expert.level));
	end
end