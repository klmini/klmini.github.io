
local Grade_Level = 0; --默认评分等级0分
local CommentText = ""; 
local Push_Up_Max = 10;
local Push_Up_Count = 0;
IsCommended = true


local ns_commented_cache = {}  --已被评论列表


function RequestCheckMapsComment(owid)
	local ret_, wid_ = check_wid2( owid )
	if  ret_ then		
		if  ns_commented_cache[ wid_ ] then
			--已经评论了
			Log( "find commented cache for " .. wid_  )
			getglobal("ArchiveGradeBtn"):Hide();
			getglobal("ArchiveGradeFinishBtn"):Show();
			IsCommended = true;			
			return
		else
			ns_commented_cache.now_wid = wid_  --后面保存使用
		end

		local url = mapservice.getserver().."/miniw/map/?act=is_map_commented";
		--owid
		url = url.."&fn=w"..wid_;
		--stat
		local stat = getExpert().stat;
		url = url.."&push_stat="..stat;
		--auth
		url = UrlAddAuth(url);

		ns_http.func.rpc(url, RespCheckMapsComment, nil, nil, ns_http.SecurityTypeHigh);  --map
	end
end

function RespCheckMapsComment(t_ret)
	if type(t_ret) ~= 'table' then
		return;
	end

	if t_ret["ret"] == 0 then
		if t_ret["star"] > 0 then
			getglobal("ArchiveGradeBtn"):Hide();
			getglobal("ArchiveGradeFinishBtn"):Show();
			IsCommended = true;
			if  ns_commented_cache.now_wid then
				ns_commented_cache[ ns_commented_cache.now_wid ] = 1
			end
		else		
			if IsInHomeLandMap and IsInHomeLandMap() then
				getglobal("ArchiveGradeBtn"):Hide();
				IsCommended = true;
			else
				-- getglobal("ArchiveGradeBtn"):Show();
				IsCommended = false;
			end 
		end	
		
		Push_Up_Max = t_ret.puch_up_max;
		Push_Up_Count = t_ret.push_up_count;
	end
end

function GradeBtnTemplate_OnClick()
	Grade_Level = this:GetClientID();
	SetArvhiveGrade();
end

--LLDO:地图内举报
function ArchiveGradeFrameReportBtn_OnClick()
	-- body
	local wdesc = AccountManager:getCurWorldDesc();
	if wdesc == nil then return end

	--MiniWorksArchiveInfoFrameTopReportBtn_OnClick();
	SetReportOptionFrame("map", wdesc.realowneruin, wdesc.realNickName, wdesc.fromowid );
end

function ArchiveGradeFrameCloseBtn_OnClick()
	getglobal("ArchiveGradeFrame"):Hide();
end

function ArchiveGradeFrameLeaveBtn_OnClick()
	getglobal("ArchiveGradeFrame"):Hide();
	GoToMainMenu();
end

--顶一下或者推荐
function ArchiveGradeFrameLikeBtn_OnClick()
	-- body
	if getglobal("ArchiveGradeFrameLikeBtnTick"):IsShown() then
		getglobal("ArchiveGradeFrameLikeBtnTick"):Hide();
	else
		if Push_Up_Count >= Push_Up_Max then
			if getExpert().stat == 2 then
				ShowGameTips(GetS(1298), 3);
			else
				ShowGameTips(GetS(1297), 3);
			end
			return;
		end
		getglobal("ArchiveGradeFrameLikeBtnTick"):Show();
	end
end

function ArchiveGradeFrame_OnLoad()
	for i=1, 5 do
		local grade = getglobal("ArchiveGradeFrameGrade"..i);
		grade:SetPoint("left", "ArchiveGradeFrameGradeText", "right", (i-1)*68+23, -7);
	end
end

function ArchiveGradeFrame_OnShow()
	ArchiveGradeFrameInit();
	

	--SetCurEditBox("ArchiveGradeFrameCommentEdit");

	if not getglobal("ArchiveGradeFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end
end

function ArchiveGradeFrameInit()
	Grade_Level = 0;	--默认没有分
	SetArvhiveGrade();

	CommentText = "";
	getglobal("ArchiveGradeFrameCommentRich"):Show();
	getglobal("ArchiveGradeFrameCommentEdit"):Clear();

	getglobal("ArchiveGradeFrameLikeBtnTick"):Hide(); --默认不勾选

	if getExpert().stat == 2 then --鉴赏家
		getglobal("ArchiveGradeFrameLikeBtnName"):SetText(GetS(21795));
		--getglobal("ArchiveGradeFrameLikeBtnTips"):SetText(GetS(1294, Push_Up_Count, Push_Up_Max));
		--getglobal("ArchiveGradeFrameDesc"):SetText(GetS(1290));
	else
		getglobal("ArchiveGradeFrameLikeBtnName"):SetText(GetS(21794));
		--getglobal("ArchiveGradeFrameLikeBtnTips"):SetText(GetS(1293, Push_Up_Count, Push_Up_Max));
		--getglobal("ArchiveGradeFrameDesc"):SetText(GetS(1289));
	end

	getglobal("ArchiveGradeFrameCommentRich"):SetText(GetS(767)  .. "#r#n" ..  GetS(10647), 83, 95, 97);

	local wdesc = AccountManager:getCurWorldDesc();
	if MapRewardClass:IsOpen() and wdesc and wdesc.fromowid then
		local rs = MapRewardClass:GetRewardState(wdesc.fromowid);
		if rs == 1 then
			getglobal("ArchiveGradeFrameRewardBtn"):Hide();
			getglobal("ArchiveGradeFrameRewardedTex"):Show();
			getglobal("ArchiveGradeFrameRewardedTxt"):Show();
		elseif rs == 0 then
			getglobal("ArchiveGradeFrameRewardBtn"):Show();
			getglobal("ArchiveGradeFrameRewardedTex"):Hide();
			getglobal("ArchiveGradeFrameRewardedTxt"):Hide();
		else
			getglobal("ArchiveGradeFrameRewardBtn"):Hide();
			getglobal("ArchiveGradeFrameRewardedTex"):Hide();
			getglobal("ArchiveGradeFrameRewardedTxt"):Hide();
		end

		local renicon = getglobal("ArchiveGradeFrameRewardedNumIcon");
		local renNum = getglobal("ArchiveGradeFrameRewardedNumNum");
		local score = MapRewardClass:GetMapTotlaScore();
		if score and tonumber(score) >= 0 then
			renicon:Show();
			renNum:Show();
			renNum:SetText(score);
		else
			renicon:Hide();
			renNum:Hide();
		end
	else
		getglobal("ArchiveGradeFrameRewardBtn"):Hide();
		getglobal("ArchiveGradeFrameRewardedTex"):Hide();
		getglobal("ArchiveGradeFrameRewardedTxt"):Hide();
		getglobal("ArchiveGradeFrameRewardedNumIcon"):Hide();
		getglobal("ArchiveGradeFrameRewardedNumNum"):Hide();
	end
end

function ArchiveGradeFrame_OnHide()
	if not getglobal("ArchiveGradeFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end
end

function SetArvhiveGrade()
	for i=1, 5 do
		local check = getglobal("ArchiveGradeFrameGrade"..i.."Checked");
		if i <= Grade_Level then
			check:Show();
		else
			check:Hide();
		end
	end
end

function ArchiveGradeFrameCommentEdit_OnFocusGained()
	getglobal("ArchiveGradeFrameCommentRich"):Hide();
end

function ArchiveGradeFrameCommentEdit_OnFocusLost()
	local text = ReplaceFilterString(this:GetText());
	this:SetText(text);

	if text ~= "" then
		getglobal("ArchiveGradeFrameCommentRich"):Hide();					
		local len = string.len(text);
		if len > 330 then
			text = string.sub(text, 1, 330).."...";
			this:SetText(text);
		end
	else
		getglobal("ArchiveGradeFrameCommentRich"):Show();
	end	
end

--[[
	“发表评论”按钮
]]
function ArchiveGradeFrameConfirmBtn_OnClick()
    -- 限制地图评论: ShowGameTips('因您不符合政策要求，暂时无法使用此功能', 3);
    if FunctionLimitCtrl:IsNormalBtnClick(FunctionType.RSET_MAPNAME) then
    	--常规
    else
    	--限制
        return;
    end

    if false == AccountSafetyCheck:FunCheck(AccountSafetyCheck.FunType.MAP_COMMENT, ArchiveGradeFrameConfirmBtn_OnClick) then
		return
	end


	if ns_data.IsGameFunctionProhibited("mc", 10583, 10584) then 
		return; 
	end
	local wdesc = AccountManager:getCurWorldDesc();
	if wdesc == nil then return end
	
	local text = getglobal("ArchiveGradeFrameCommentEdit"):GetText();

	--LLDO:校验评论是否有#号
	if true == ArchiveGradeFrame_CheckComment(text) then
		Log("LLXXXX");
		return;
	end

	local verify = BreakLawMapControl:VerifyMapID(wdesc.fromowid);
	if verify == 1 then
		ShowGameTipsWithoutFilter(GetS(10570), 3);
		return;
	elseif verify == 2 then
		ShowGameTipsWithoutFilter(GetS(10570), 3);
		return;
	end

	RequestOwCommentHttp(wdesc.fromowid, text);	

	if getglobal("ArchiveGradeFrameGrade5Checked"):IsShown()	then
		TamedAnimal_RequestReview = 0;
	end
end

--LLDO:提交评论的时候过滤, 不能有闪烁和颜色.
function ArchiveGradeFrame_CheckComment(coment)
	Log("ArchiveGradeFrame_CheckComment");
	Log("coment = " .. coment);

	local formatString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	local cChar = "";
	local cRep = "";

	for i = 1, #formatString do
		cChar = string.sub(formatString, i, i);
		cRep = "#" .. cChar;

		if string.find(coment, cRep) then
			--含有#, 不让提交.
			MessageBox(4, GetS(6364));
			return true;
		end
	end

	return false;
end

local lastCommentTime = 0;

function RequestOwCommentHttp(owid, text)
	if Grade_Level <= 0 then
		ShowGameTips(GetS(1295), 3);
		return;
	end

	local pushUP = nil;
	if getglobal("ArchiveGradeFrameLikeBtnTick"):IsShown() then
		pushUP = getExpert().stat == 2 and 3 or 1;
	end

	if getExpert().stat == 2 then
		if pushUP == 3 and (text == nil  or #text<72) then
			ShowGameTips(GetS(1296), 3);
			return;
		end
	end		


	local time = os.time();
	if time - lastCommentTime <= 1 then
		return;
	else
		lastCommentTime = time;
	end

	ns_commented_cache.now_wid = tonumber(owid) or 0

	local url = mapservice.getserver().."/miniw/map/?act=set_map_comment";
	--owid
	url = url.."&fn=w"..owid;
	--nickname
	url = url.."&nickname="..gFunc_urlEscape(AccountManager:getNickName());
	--star
	url = url.."&star="..Grade_Level;
	--headIcon
	url = url.."&uin_icon="..GetHeadIconIndex();
	--frameId
	--url = url.."&head_frame_id="..HeadFrameCtrl:GetFrameId();
	--msg
	url = url.."&msg="..gFunc_urlEscape(text);
	--pushUP
	if pushUP then
		url = url.."&push_up="..pushUP;
	end

	local all_txt_ = (AccountManager:getNickName() or "") .. '_' .. (text or "")
	url = url.."&" .. http_getRealNameMobileSum( all_txt_ )

	--stat是否是鉴赏家
	local stat = getExpert().stat;
	url = url.."&push_stat="..stat;
	--auth
	url = UrlAddAuth(url);

	ns_http.func.rpc(url, RespCommentMaps, nil, nil, ns_http.SecurityTypeHigh);   --map
	ShowLoadLoopFrame(true, "file:archivegrade -- func:RequestOwCommentHttp")
end

function RespCommentMaps(ret)
	if getglobal("LoadLoopFrame"):IsShown() then
		ShowLoadLoopFrame(false)
	end

	if type(ret) ~= 'table' then
		ShowGameTips(GetS(768), 3);
		return;
	end

	if ret["ret"] == 0 then
		if ret.open_svr and ret.open_svr == 3 then
			ShowGameTipsWithoutFilter(GetS(10659), 3)
		else
			if IsOverseasVer() or isAbroadEvn() then 
				ShowGameTips(GetS(20667), 3)
			else
				ShowGameTips(GetS(20665), 3);
			end
		end
		StatisticsTools:gameEvent("Like");
		getglobal("ArchiveGradeFrame"):Hide();
		getglobal("ArchiveGradeBtn"):Hide();
		getglobal("ArchiveGradeFinishBtn"):Show();
		IsCommended = true;
		if  ns_commented_cache.now_wid then
			ns_commented_cache[ ns_commented_cache.now_wid ] = 1
		end
	elseif ret["ret"] == 8 then
		ShowGameTips(GetS(3867), 3);
	elseif ret["ret"] == 9 then
		ShowGameTips(GetS(3868), 3);
	elseif ret["ret"] == 11 then 	--手机号 验证码 校验失败 TODO
		if ret_.flag == "00" then
			ShowGameTipsWithoutFilter(GetS(22037), 3)	--手机 身份证 校验失败
		elseif ret_.flag == "01" then
			ShowGameTipsWithoutFilter(GetS(10643), 3)	--手机号 校验失败
		elseif ret_.flag == "10" then
			ShowGameTipsWithoutFilter(GetS(100218), 3)	--身份证 校验失败
		end
	elseif ret["ret"] == 12 then	--内容违规
		ShowGameTips(GetS(121), 3);
	else
		ShowGameTips(GetS(768), 3);
	end

	if IsOverseasVer() or isAbroadEvn() then 
		ShowGameTips(GetS(20667), 3)
	else
		ShowGameTips(GetS(20665), 3);
	end
	--如果是鉴赏家的评论，要从邀请评测列表中移除此地图
	local stat = getExpert().stat;
	if stat == 2 then
		local wdesc = AccountManager:getCurWorldDesc();
		if wdesc then		
			RemoveExpertTaskMapsById(wdesc.fromowid);
		end
	end

	if ClientCurGame:isInGame() then 
		threadpool:work(function()
			threadpool:wait(1);
			GoToMainMenu();
		end);
	end
end

--设置存档的评分ui显示
function SetArchiveGradeUI(font, point)
	local score = string.format("%0.1f", point);
	font:SetText(score);
	-- local num = tonumber(score);
	-- if num < 3 then
	-- 	font:SetTextColor(5, 155, 12);
	-- elseif num < 4 then
	-- 	font:SetTextColor(32, 113, 195);
	-- elseif num < 5 then
	-- 	font:SetTextColor(202, 124, 0);
	-- else
	-- 	font:SetTextColor(215, 56, 0);
	-- end
end

