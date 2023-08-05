--举报选项配置
local g_ReportOptionConfig = {
	minDescChar = 18,	--最少填写几个字符
	curClassIndex = 1,	--举报类型索引: 存档、个人中心...
	CurOptionIndex = 1, --举报条例索引: 外挂、谩骂...
	curUin = 0,
	curNickName = "",

	SetCurClass = function(self, classIndex, uin, nickname, wid)
		Log("SetCurClass:");
		self.curClassIndex = classIndex;
		self.curUin = uin or 0;
		self.curWid = wid or 0;
		self.curNickName = nickname or "";
	end,

	SetCurOption = function(self, optionIndex)
		Log("SetCurOption: optionIndex = " .. optionIndex);
		self.CurOptionIndex = optionIndex;
	end
};

--举报模块索引定义, 拉取的配置信息存在这里: ns_player_report.
local g_ReportModuleIndex = {
	map = 1, 		--1. 存档, map
	selfcenter = 2, --2. 个人中心, selfcenter
	game = 3, 		--3, 存档地图, game
	comment = 4, 	--4. 地图评论
	groupchat = 5,  --5		群组聊天
};


--个人信用值按钮
function PlayerCenterFrameCreditBtn_OnClick()
	getglobal("CreditFrame"):Show();
end

--------------------------------------------信用值面板------------------------------------------
--信用描述配置
g_CreditDesc = {
	{score = 49, rankStringId = 10513, color="#cff0000"},		--糟糕
	{score = 79, rankStringId = 10511, color="#cffb400"},		--良好
	{score = 100, rankStringId = 10512, color="#c1ec832"},		--优秀

	GetScore = function(self)
		local score = ns_playercenter.selfScore;
		Log("GetScore:score = " .. score);
		return score;
	end,

	GetRank = function(self)
		local score = self:GetScore();
		for i = 1, #self do
			if score <= self[i].score then
				return GetS(self[i].rankStringId);
			end
		end
	end,

	GetColor = function(self)
		local score = self:GetScore();
		for i = 1, #self do
			if score <= self[i].score then
				return self[i].color;
			end
		end
	end,
};

function CreditFrameOKBtn_OnClick()
	getglobal("CreditFrame"):Hide();
end

function CreditFrame_OnShow()
	getglobal("CreditFrameDesc"):SetText(GetS(10516), 255, 255, 255);
	getglobal("CreditFrameTitle"):SetText(GetS(10510) .. g_CreditDesc:GetRank(selfScore));
	getglobal("CreditFramePersonValue"):SetText(g_CreditDesc:GetColor(selfScore) .. g_CreditDesc:GetRank(selfScore));
end

function CreditFrameTipBtn_OnClick()
	getglobal("CreditScoreHelpFrame"):Show();
end


--------------------------------------------举报选择面板-----------------------------------------
--[[
	函数名: SetReportOptionFrame
	功  能: 设置举报选择面板类型, 并打开
	参  数: class: 输入参数, 举报类型: 1,2,3,4.
]]
function SetReportOptionFrame(class, uin, nickname, wid)
	local classIndex = g_ReportModuleIndex[class];
	Log("SetReportOptionFrame: class=" .. class .. ", uin=" .. uin .. ", nickname=" .. nickname  .. ", wid=" .. (wid or "") );

	if  classIndex then
		Log("classIndex = " .. classIndex);
		g_ReportOptionConfig:SetCurClass(classIndex, uin, nickname, wid);
		ShowReportFrames("ReportOptionFrame");
	end
end

function ShowReportFrames(uiname)
	local UIs = {"ReportOptionFrame", "ReportsystemFrame"};

	for i = 1, #UIs do
		if uiname == UIs[i] then
			getglobal(UIs[i]):Show();
		else
			getglobal(UIs[i]):Hide();
		end
	end

	if getglobal("ArchiveInfoFrameEx"):IsShown() then
		getglobal("MiniWorksMapCommentBox"):setDealMsg(false);
	end
end

function ReportOptionFrameCloseBtn_OnClick()
	getglobal("ReportOptionFrame"):Hide();
end

--选项条目布局
function ReportOptionLayout()
	Log("ReportOptionLayout:");
	local class = ns_player_report.content[g_ReportOptionConfig.curClassIndex];
	local hight = 90;

	for i = 1, 10 do
		local uiName = "ReportOptionBoxOp" .. i;

		if HasUIFrame(uiName) then
			local ui = getglobal(uiName);
			ui:Hide();

			if class then
				if i <= #class then
					ui:Show();
					ui:SetPoint("top", "ReportOptionBoxPlane", "top", 0, (i - 1) * hight);
					getglobal(uiName .. "Desc"):SetText(class[i].text);
				end
			end
		end
	end

	if class then
		local planeH = 90 * (#class);
		local boxH = getglobal("ReportOptionBox"):GetHeight();
		local plane = getglobal("ReportOptionBoxPlane");
		if planeH < boxH then planeH = boxH; end
		plane:SetHeight(planeH);
	end
end

function ReportOptionFrame_OnShow()
	local desc = GetS(10517) .. " #c15a815" .. g_ReportOptionConfig.curNickName .. "(" .. g_ReportOptionConfig.curUin .. ")";

	getglobal("ReportOptionFrameDesc"):SetText(desc);
	ReportOptionLayout();

	if getglobal("ArchiveInfoFrameEx"):IsShown() then
		getglobal("MiniWorksMapCommentBox"):setDealMsg(false);
	end
end

function ReportOptionFrame_OnHide()
	if getglobal("ArchiveInfoFrameEx"):IsShown() then
		getglobal("MiniWorksMapCommentBox"):setDealMsg(true);
	end
end

function ReportOptionTemplate_OnClick()
	local index = this:GetClientID();
	g_ReportOptionConfig:SetCurOption(index);
	ShowReportFrames("ReportsystemFrame");
end


--------------------------------------------举报面板---------------------------------------------
function ReportsystemFrameCloseBtn_OnClick()
	getglobal("ReportsystemFrame"):Hide();
end

function ReportsystemFrame_OnShow()
	getglobal("ReportsystemFrameLastStep"):SetText(GetS(10520), 161, 83, 27);
	DynamicPublishFrameTextEdit_OnFocusLost();

	if getglobal("ArchiveInfoFrameEx"):IsShown() then
		getglobal("MiniWorksMapCommentBox"):setDealMsg(false);
	end
end

function ReportsystemFrame_OnHide()
	if getglobal("ArchiveInfoFrameEx"):IsShown() then
		getglobal("MiniWorksMapCommentBox"):setDealMsg(true);
	end
end

--编辑框
function DynamicPublishFrameTextEdit_OnFocusLost()
	local text = getglobal("DynamicPublishFrameEditDefaultTxt"):GetText();
	if text == "" then
		getglobal("DynamicPublishFrameEditDefaultTxt"):Show();
	else
		getglobal("DynamicPublishFrameEditDefaultTxt"):Hide();
	end
end

function DynamicPublishFrameTextEdit_OnFocusGained()
	getglobal("DynamicPublishFrameEditDefaultTxt"):Hide();
end

function DynamicPublishFrameTextEdit_OnTabPressed()
end

--上一步
function ReportsystemFrameLastStep_OnClick()
	ShowReportFrames("ReportOptionFrame");
end

--提交按钮
function ReportsystemFrameCommitBtn_OnClick()
	Log("ReportsystemFrameCommitBtn_OnClick:");
	local text = getglobal("ReportsystemFrameTextEdit"):GetText();

	if nil == text or #text < g_ReportOptionConfig.minDescChar then
		ShowGameTips(GetS(20212));
		return;
	end

	local uin = g_ReportOptionConfig.curUin;
	local wid = g_ReportOptionConfig.curWid;
	local classIndex = g_ReportOptionConfig.curClassIndex;
	local class = ns_player_report.content[classIndex];
	local tid = class.tid;													--tid:类型.
	local id = class[g_ReportOptionConfig.CurOptionIndex].id;				--id:举报条目
	local msg = ns_http.func.base64_encode(text);							--msg:玩家填写的信息
	local url = g_http_root_map .. 'miniw/profile?act=player_report2'..
					'&op_uin='..uin..
					'&wid='..wid..
					'&tid=' .. tid ..
					'&id=' .. id ..
					'&msg=' .. msg ..
					'&'..http_getS1Map();

	Log("url = "..url);
	ShowLoadLoopFrame(true, "file:reportsystem -- func:ReportsystemFrameCommitBtn_OnClick");

	ns_http.func.rpc(url, function(ret)
		ShowLoadLoopFrame(false)
		getglobal("ReportsystemFrameTextEdit"):SetText("");
		getglobal("ReportsystemFrame"):Hide();

		if ret then
			if ret.ret == 0 then
				--举报成功
				ShowGameTips(GetS(4745), 3);
			elseif ret.ret == 103 then
				--重复举报
				ShowGameTips(GetS(10537), 3);
			else
				ShowGameTips(GetS(4729), 3);
			end
		else
			ShowGameTips(GetS(4729), 3);
		end
	end, nil, nil, true);

	getglobal("ReportsystemFrameTextEdit"):SetText("");
end


--------------------------------------------信用值说明面板---------------------------------------------
function CreditScoreHelpFrame_OnLoad()
	getglobal("CreditScoreHelpFrameBoxContent"):SetText(GetS(1354), 140, 103, 84);
	local height = getglobal("CreditScoreHelpFrameBoxContent"):GetTotalHeight();
	height = height>370 and height or 370;
	getglobal("CreditScoreHelpFrameBoxPlane"):SetHeight(height);
end

function CreditScoreHelpFrameClose_OnClick()
	getglobal("CreditScoreHelpFrame"):Hide();
end


