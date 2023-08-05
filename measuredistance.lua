
local m_MeasureDistanceParam = {
	nDistanceList = {},
	sustainTime = 0,		--持续显示时间
};

function MeasureDistanceFrame_OnLoad()
	this:setUpdateTime(1);
	this:RegisterEvent("GIE_OPEN_MEASURE_DISTANCE");
	this:RegisterEvent("GIE_CLOSE_MEASURE_DISTANCE");
end

function MeasureDistanceFrame_OnEvent()
	if arg1 == "GIE_OPEN_MEASURE_DISTANCE" then
		--打开测量距离窗口
		Log("1:GIE_OPEN_MEASURE_DISTANCE:");
		local ge = GameEventQue:getCurEvent();
		m_MeasureDistanceParam.sustainTime = 3;
		m_MeasureDistanceParam.nDistanceList[1] = ge.body.measuredistanceinfo.nDist1;
		m_MeasureDistanceParam.nDistanceList[2] = ge.body.measuredistanceinfo.nDist2;
		m_MeasureDistanceParam.nDistanceList[3] = ge.body.measuredistanceinfo.nDist3;
		m_MeasureDistanceParam.nDistanceList[4] = ge.body.measuredistanceinfo.nDist4;
		m_MeasureDistanceParam.nDistanceList[5] = ge.body.measuredistanceinfo.nDist5;
		m_MeasureDistanceParam.nDistanceList[6] = ge.body.measuredistanceinfo.nDist6;
		getglobal("MeasureDistanceFrame"):Show();
	elseif arg1 == "GIE_CLOSE_MEASURE_DISTANCE" then
		Log("2:GIE_CLOSE_MEASURE_DISTANCE:");
		m_MeasureDistanceParam.sustainTime = 0;
	end
end

function MeasureDistanceFrame_OnUpdate()
	if m_MeasureDistanceParam.sustainTime > 0 then
		m_MeasureDistanceParam.sustainTime = m_MeasureDistanceParam.sustainTime - 1;
	else
		if getglobal("MeasureDistanceFrame"):IsShown() then
			getglobal("MeasureDistanceFrame"):Hide();
		end
	end
end

function MeasureDistanceFrame_OnShow()
	Log("MeasureDistanceFrame_OnShow:");
	if not getglobal("MeasureDistanceFrame"):IsReshow() then
	    --ClientCurGame:setOperateUI(true);
	end

	local x = 0;
	local w = 60;
	local desc = getglobal("MeasureDistanceFrameDesc");
	local txt = "";
	-- local dirstr = {"前", "后" , "左", "右", "上", "下"};
	local dirstr = {9293, 9294, 9295, 9296, 9297, 9298};

	for i = 1, 6 do
		--前后左右上下
		Log("i = " .. i);
		if m_MeasureDistanceParam.nDistanceList[i] and m_MeasureDistanceParam.nDistanceList[i] > 0 then
			local nDist = m_MeasureDistanceParam.nDistanceList[i] + 1;	--距离都+1, 显示格子数

			txt = txt .. GetS(dirstr[i]) .. nDist .. "\t";
		end
	end

	desc:SetText(txt);
end

function MeasureDistanceFrame_OnHide()
	if not getglobal("MeasureDistanceFrame"):IsRehide() then
	    --ClientCurGame:setOperateUI(false);
	end
end

function MeasureDistanceFrame_OnClick()
	getglobal("MeasureDistanceFrame"):Hide();
end