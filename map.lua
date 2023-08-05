
function MapFrame_OnLoad()
	this:setUpdateTime(0.05);
	this:RegisterEvent("GIE_MINIMAP_CHANGE");
end

function MapFrame_OnEvent()
	if arg1 == "GIE_MINIMAP_CHANGE" then
		if getglobal("MapFrame"):IsShown() then
			local ge = GameEventQue:getCurEvent();
			local mapData = ge.body.minimap;
			UpdateMapIcon(mapData);
		end
	end
end

function MapFrame_OnShow()
	local getglobal = _G.getglobal;
	if getglobal("FriendFrame"):IsShown() then
		getglobal("FriendFrame"):Hide();
	end
	local headIndex = AccountManager:getRoleModel();
	local skinModel = AccountManager:getRoleSkinModel();
	if skinModel > 0 then
		local skinDef = RoleSkinCsv:get(skinModel);
		if skinDef ~= nil then
			headIndex = skinDef.Head;
		end
	end

	local roleIcon 	= getglobal("MapFrameRoleIcon");
	roleIcon:SetTexture("ui/roleicons/"..headIndex..".png");

	if CurWorld:isExtremityMode() then
		getglobal("MapFrameExtremityScoreTitle"):SetText(GetS(3192));		
		local score = AccountManager:getAccountData():getOWScore(CurWorld:getOWID());
		getglobal("MapFrameExtremityScore"):SetText(score);
		getglobal("MapFrameBkg2"):Show();
	else
		getglobal("MapFrameExtremityScoreTitle"):SetText("");
		getglobal("MapFrameExtremityScore"):SetText("");
		getglobal("MapFrameBkg2"):Hide();
	end
	--如果是外星世界，显示生存时间
	if(CurWorld:getCurMapID() == 2) then
		MapFrameSurviveShow();
		getglobal("MapFrameBirthplace"):Hide();
	else
		MapFrameSurviveHide();
		getglobal("MapFrameBirthplace"):Show();
	end
	
	
	if not getglobal("MapFrame"):IsReshow() then
		ClientCurGame:setOperateUI(true);
	end

	--隐藏工具模式界面
	GetInst("UIManager"):Push2HiddenFrame("ToolModeFrame");
	--隐藏音乐跳舞界面
	if GetInst("MiniUIManager"):GetCtrl("clubMain") then
		GetInst("MiniUIManager"):GetCtrl("clubMain"):SetShow(false)
	end
end

function MapFrame_OnHide()
	ShowMainFrame();
	ClientCurGame:enableMinimap(false);
	for i=1, #(t_UIName) do
		local frame = getglobal(t_UIName[i]);
		if t_UIName[i] == 'PlayMainFrame' then
			PlayMainFrameUIShow();
		else
			frame:Show();
		end
	end

	if ClientMgr:getGameData("hideui") == 1 then 
        PixelMapInterface:HideCompass();
    end
	
	CurMainPlayer:setUIHide(false);
		
	if not getglobal("MapFrame"):IsRehide() then
		ClientCurGame:setOperateUI(false);
	end

	--还原工具模式界面
	GetInst("UIManager"):PopLastFrame();
	if CurMainPlayer and CurMainPlayer:isSittingInStarStationCabin() then
		local mvcFrame = GetInst("UIManager"):GetCtrl("StarStationInfo");
		local param = mvcFrame.model:GetIncomingParam()
		GetInst("UIManager"):Open("StarStationInfo",param)
	end
	--显示音乐跳舞界面
	if GetInst("MiniUIManager"):GetCtrl("clubMain") then
		GetInst("MiniUIManager"):GetCtrl("clubMain"):SetShow(true)
	end

	if PixelMapInterface:UseNewSmallMap() then
		return GetInst("MiniUIManager"):ShowUI("main_mapAutoGen");
	end
end

local changeSpeed = 2;
local changeOffset = changeSpeed
local curOffset = 0;
function MapFrame_OnUpdate()
	local MapFrameDeathUv = getglobal("MapFrameDeathUv")
	if MapFrameDeathUv:IsShown() then
		local size = MapFrameDeathUv:GetWidth();
		size = size - 5;
		if size <= 0 then
			size = 113;
		end
		MapFrameDeathUv:SetSize(size, size);
	end

end

function UpdateMapIcon(mapData)
	local roleBkg  	= getglobal("MapFrameRoleBkg");
	local roleIcon  	= getglobal("MapFrameRoleIcon");
	local boss 		= getglobal("MapFrameBoss");
	local birthplace	= getglobal("MapFrameBirthplace");
	local deathplace	= getglobal("MapFrameDeathplace");
	local deathUv		= getglobal("MapFrameDeathUv");
	local time 		= getglobal("MapFrameTime");
	local coord		= getglobal("MapFrameCoord");
	local height		= getglobal("MapFrameHeight");
	local light		= getglobal("MapFrameLight");
	local day		= getglobal("MapFrameDay");
	local night		= getglobal("MapFrameNight");
	local surviveday 	= getglobal("MapFrameSurviveDay");
	local spacesurviveday 	= getglobal("MapFrameSpaceSurviveDay");

	roleBkg:SetPoint("top", "$parent", "topleft", mapData.posx, mapData.posy);
	if mapData.mode == 1 then
		roleBkg:SetAngle(mapData.angle, 2);
		roleIcon:Hide();
	else
		roleBkg:SetAngle(0);
		roleIcon:Show();
	end

	if mapData.guidex < 0 then
		boss:Hide();
	else
		boss:Show();
		boss:SetPoint("topleft", "$parent", "topleft", mapData.guidex, mapData.guidey);
		if mapData.hasboss then
			boss:SetTexUV("lzy_09")
		else
			boss:SetTexUV("lzy_altar")
		end
	end
	
	birthplace:SetPoint("topleft", "$parent", "topleft", mapData.spawnx, mapData.spawny);

	if mapData.deadx < 0 then
		deathplace:Hide();
		deathUv:Hide();
	else
		deathplace:Show();
		deathplace:SetPoint("topleft", "$parent", "topleft", mapData.deadx, mapData.deady);
		deathUv:Show();
	end

	local hour = ClientCurGame:getGameTimeHour();
	time:SetText(hour..":"..ClientCurGame:getGameTimeMinute());

	if hour >=6 and hour < 20 then
		day:Show();
		night:Hide();
	else
		day:Hide();
		night:Show();
	end 

	local text = "("..CurMainPlayer:getBlockX()..","..CurMainPlayer:getBlockZ()..")";
	coord:SetText(text);
	height:SetText(CurMainPlayer:getBlockY());
	if CurMainPlayer then
		local lightText = CurMainPlayer:getBlockLight();
		light:SetText(lightText)
	end

	local dayTitle = getglobal("MapFrameSurviveDayTitle")
	local dayIcon = getglobal("MapFrameSurviveIcon")
	--dayIcon:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml")
	if CurWorld ~= nil and CurWorld:isCreativeMode() then
		--创建天数
		dayIcon:SetTexUV("icon_create_days")
		dayTitle:SetText(GetS(529).."：");
	elseif CurWorld ~= nil and CurWorld:isGameMakerMode() then
		--编辑天数
		dayIcon:SetTexUV("icon_edit_days")
		dayTitle:SetText(GetS(746).."：");
	elseif CurWorld ~= nil and CurWorld:isGameMakerRunMode() then
		-- 玩法天数
		dayIcon:SetTexUV("icon_htp_days")
		dayTitle:SetText(GetS(747).."：");
	else
		--生存天数
		dayIcon:SetTexUV("icon_survive_days")
		dayTitle:SetText(GetS(530).."：");
	end
	local dayText = CurMainPlayer:getSurviveDay();
	local SpaceDayText = CurMainPlayer:getSurviveDay(2);
	surviveday:SetText("#cfed700"..dayText.."#n"..GetS(3118), 255, 253, 233);
	spacesurviveday:SetText("#cfed700"..SpaceDayText.."#n"..GetS(3118), 255, 253, 233);
	for i=1, MAX_TOTEM_NUM do
		local totem = getglobal("MapFrameTotem"..i);
		local totempos = mapData.totempos[i-1];
		if totempos.px < 0 then
			totem:Hide();
		else
			totem:Show();
			totem:SetPoint("topleft", "$parent", "topleft",totempos.px, totempos.py);
		end
	end
	for i=1, MAX_TRANSFER_NUM do
		local transfer = getglobal("MapFrameTransfer"..i);
		local transferpos = mapData.transferpos[i-1];
		if transferpos.px < 0 then
			transfer:Hide();
		else
			transfer:Show();
			transfer:SetPoint("topleft", "$parent", "topleft", transferpos.px, transferpos.py);
		end
	end

	if MAX_STARTSTATION_MAEKPOINT_NUM then
		for i=1, MAX_STARTSTATION_MAEKPOINT_NUM do
			local starStation = getglobal("MapFrameStarStation"..i);
			local pos = mapData.starstationpos[i-1];
			if pos.px < 0 then
				starStation:Hide();
			else
				starStation:Show();
				starStation:SetSize(52,36)
				starStation:SetPoint("topleft", "$parent", "topleft",pos.px, pos.py);
			end
		end
	end
end

function MapFrameBackBtn_OnClick()
    getglobal("MapFrame"):Hide();
	local mapframestate = getglobal("MapFrame"):IsShown()	
    if mapframestate == false then
		if GetInst("MiniUIManager"):GetCtrl("main_map") then
			local mapctrl = GetInst("MiniUIManager"):GetCtrl("main_map")
			mapctrl:StandbyReport('SCREEN_MAP_3D','Close','click',nil)
		end
	end
    if getkv("Sleep_Notice_Frame_Show") then
        getglobal("SleepNoticeFrame"):Show()
        setkv("Sleep_Notice_Frame_Show", false)
    end
end
function MapFrameSurviveHide()
	getglobal("MapFrameBkg2"):Hide();
	getglobal("MapFrameSpaceSurviveDayTitle"):Hide();
	getglobal("MapFrameSpaceSurviveIcon"):Hide();
	getglobal("MapFrameSpaceSurviveDay"):Hide();
end

function MapFrameSurviveShow()
	getglobal("MapFrameBkg2"):Show();
	getglobal("MapFrameSpaceSurviveDayTitle"):Show();
	getglobal("MapFrameSpaceSurviveIcon"):Show();
	getglobal("MapFrameSpaceSurviveDay"):Show();
end
