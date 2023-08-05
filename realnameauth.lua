RealNameAuth = {
	TypeOption = {
		{
			Description = "身份证认证",
			NameID = 22032,
		},
		{
			Description = "军人证",
			NameID = 22028,
		},
		{
			Description = "港澳通行证",
			NameID = 22029,
		},
		{
			Description = "外国护照",
			NameID = 22030,
		},
		{
			Description = "其他证件",
			NameID = 22031, 
		}
	},

	TypeIndex = 1,
}

function RealNameAuthFrameCloseBtn_OnClick()
	-- standReportEvent("47", "ID_CERTIFICATION_POPUP1", "SubmitInformation", "Close")
	HideIdentityNameAuthFrame()
	ShowPhtoneBindingAwardFrame()
end

function RealNameAuthFrameNameEdit_OnTabPressed()
	SetCurEditBox("RealNameAuthFrameCertificateEdit");
end

function RealNameAuthFrameCertificateEdit_OnTabPressed()
	SetCurEditBox("RealNameAuthFrameNameEdit");
end

function CheckIDCodeValid(code)
	if string.match(code,"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d") == code
		or string.match(code, "%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d[0-9X]") then
		return true;
	end

	return false;
end

function RealNameAuthFrameCheckBtn_OnClick()
	getglobal("RealNameAuthFrameTypeOption"):Hide()

	local name = getglobal("RealNameAuthFrameNameEdit"):GetText();
	if name == nil or name == "" or CheckIsInclueSymbol(name) then
		ShowGameTipsWithoutFilter(GetS(4992), 3);
		return;
	end

	local certificateCode = getglobal("RealNameAuthFrameCertificateEdit"):GetText();
	if certificateCode == nil or certificateCode == "" or CheckIsInclueSymbol(certificateCode) then
		ShowGameTipsWithoutFilter(GetS(4993), 3);
		return;
	end

	local ret = AccountManager:idcard_auth(tostring(certificateCode), tostring(name), RealNameAuth.TypeIndex);
	
	if ret == ErrorCode.OK then
		--实名认证成功打点(HideIdentityNameAuthFrame会把埋点场景清理，所以埋点要放在前面)
		standReportEvent("47", "ID_CERTIFICATION_POPUP1", "SubmitInformation", "click",{standby1=1})
		IdentityNameAuthClass:IdentityNameAuthStatistics(2, {showType = 1})
		BpReportEventOnHold("authid")

		HideIdentityNameAuthFrame()
		UpdateAdultState();
		CountFcmRate();
		
		local idCardInfo = AccountManager:idcard_info();
		if idCardInfo then
			if idCardInfo.age >= 18 then	--认证满18岁了
				MessageBox(4, GetS(5994));
			else
				MessageBox(4, GetS(5995));
			end
		end

		if AccountManager.data_update then
			AccountManager:data_update();
		end
	else
		standReportEvent("47", "ID_CERTIFICATION_POPUP1", "SubmitInformation", "click",{standby1=0})
		if t_ErrorCodeToString then
			local count = AccountManager:get_idcard_auth_count_for_today();
			MessageBox(4, GetS(t_ErrorCodeToString[ret], count));
		end
	end
	print("kekeke RealNameAuthFrameCheckBtn_OnClick", ret);

	local count = AccountManager:get_idcard_auth_count_for_today();
	getglobal("RealNameAuthFrameRemainNum"):SetText(GetS(1055, count));
	ShowPhtoneBindingAwardFrame()
end

function RealNameAuthFrame_OnShow()
	--标题栏
	getglobal("RealNameAuthFrameTitleFrameName"):SetText(GetS(4986));
	
	if ForceRealNameAuthSwitch then	--强制认证
		getglobal("RealNameAuthFrameCloseBtn"):Hide();
	else
		getglobal("RealNameAuthFrameCloseBtn"):Show();
	end

	local count = AccountManager:get_idcard_auth_count_for_today();
	getglobal("RealNameAuthFrameRemainNum"):SetText(GetS(1055, count));

	IdentityNameAuthClass.IsAutoAward = false
	RealNameAuth.TypeIndex = 1
	local rnautype = getglobal("RealNameAuthFrameTypeOptionBtnMarkIcon")
	if not IdentityNameAuthClass:GetCanOptionType() then
		rnautype:Hide()
	else
		rnautype:Show()
	end
end

function RealNameAuthFrame_OnHide()
	getglobal("RealNameAuthFrameTypeOption"):Hide()
	if IsLobbyShown() then
		UpdateArchive()
	end
end

function RealNameAuthFrameTypeOptionBtn_OnClick()
	if not IdentityNameAuthClass:GetCanOptionType() then
		return
	end

	getglobal("RealNameAuthFrameTypeOption"):Show()
end

function RealNameAuthFrameTypeOption_OnShow()
	RealNameAuthUpdateTypeOption(RealNameAuth.TypeIndex, RealNameAuth.TypeIndex)
end

function RealNameAuthUpdateTypeOption(newindex, oldindex)
	if newindex == nil then
		newindex = g_enum_comm.identityauth.idtype.idcard
	end

	if oldindex == nil then
		oldindex = g_enum_comm.identityauth.idtype.idcard
	end

	local btnName = "RealNameAuthFrameTypeOptionBtn"
	getglobal(btnName .. "1Name"):SetText(GetS(RealNameAuth.TypeOption[oldindex].NameID))

	for i=1, #RealNameAuth.TypeOption do
		local btnUI = getglobal(btnName .. i+1)
		local bkg = getglobal(btnName  .. i+1 .. "Bkg")
		local icon = getglobal(btnName  .. i+1 .. "MarkIcon")
		local name = getglobal(btnName  .. i+1 .. "Name")

		icon:Hide()
		name:SetText(GetS(RealNameAuth.TypeOption[i].NameID))

		if i == newindex then
			bkg:Show()
			name:SetTextColor(255, 255, 255)
		else
			bkg:Hide()	
			name:SetTextColor(185, 185, 185)
		end
	end
end

function RealnameAuthTypeOptionTemplate_OnClick()
	local index = this:GetClientID()
	local switch = {
		[0] = RealNameAuth.TypeIndex,
		[1] = g_enum_comm.identityauth.idtype.idcard,
		[2] = g_enum_comm.identityauth.idtype.armyman,
		[3] = g_enum_comm.identityauth.idtype.hkmopermit,
		[4] = g_enum_comm.identityauth.idtype.passport,
		[5] = g_enum_comm.identityauth.idtype.other,
	}

	if index ~= 0 then
		RealNameAuth.TypeIndex = switch[index]
		getglobal("RealNameAuthFrameTypeName"):SetText(GetS(RealNameAuth.TypeOption[index].NameID))
	end

	getglobal("RealNameAuthFrameTypeOption"):Hide()
end