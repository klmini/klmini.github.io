local TimeOut = 0;
local IsStatistics = false;
IsStatisticsEnterGame = false;
StatisticsNewWorldType  = 0;	-- 1新手引导去冒险跳转 2新手引导去逛逛没网时跳转

local CurLoadingProgress = 0;
local RealLoadingProgress = 0;
educationLiteRotate = {180, 75, 1.0};
math.randomseed(tostring(os.time()):reverse():sub(1, 7))
local env = ClientMgr:getGameData("game_env")

LoadTexturePath={
	"ui/mobile/texture0/bigtex/jzjm_beijing1",
	"ui/mobile/texture0/bigtex/jzjm_beijing2",
	"ui/mobile/texture0/bigtex/jzjm_beijing3",
	"ui/mobile/texture0/bigtex/jzjm_beijing4",
	"ui/mobile/texture0/bigtex/jzjm_beijing5",
	"ui/mobile/texture0/bigtex/jzjm_beijing6",
}; --loading背景图路径

function LoadingFrame_OnLoad()
	this:RegisterEvent("GE_LOAD_PROGRESS");
	this:RegisterEvent("GE_LOAD_COMPLETE");	
	--this:RegisterEvent("GE_HTTP_DOWNLOAD_PROGRESS");

	this:setUpdateTime(0.05);
	SandboxLua.eventDispatcher:CreateEvent(nil, "LoadingFrame_Shown")
end

function LoadingFrame_OnUpdate()
	if TimeOut > 0 then
		TimeOut = TimeOut - arg1;
		if TimeOut <= 0 then
			getglobal("LoadingFrame"):Hide();
			if ClientCurGame:isInGame() then
				ClientMgr:gotoGame("MainMenuStage");
			end
		end
	end
end

function LoadingFrame_OnEvent()
	local ge = GameEventQue:getCurEvent();
	if this:IsShown() then
		if arg1 == "GE_LOAD_PROGRESS" and getglobal("LoadingFrame"):IsShown() then
			RealLoadingProgress = ge.body.loadprogress.progress;

			local value = ge.body.loadprogress.progress/100;
			
			if value > 1 then  
				value = 1;
			end
			
			if ge.body.loadprogress.progress == -2 then
				getglobal("LoadingFrame"):Hide();
				return
			end
			
			if StatisticsNewWorldType > 0 and not IsStatistics then
				if StatisticsNewWorldType == 1 then
					-- statisticsGameEvent(901, "%s", "G000028","save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
				elseif StatisticsNewWorldType == 2 then
					StatisticsTools:gameEvent("G000032");
				end 
				IsStatistics = true;
			end

			if value < 0 then
				getglobal("LoadingFrameProgressBar"):SetValue(1);
				getglobal("LoadingFrameProgressBarCursorTex"):SetPoint("left", "LoadingFrameProgressBar", "left", 1280-2, 0);

				getglobal("LoadingFrame"):Hide();
				--ShowLobby();
				MainMenuGame_Enter();		
				return;
			else
				getglobal("LoadingFrameProgressBar"):SetValue(value);
				getglobal("LoadingFrameProgressBarCursorTex"):SetPoint("left", "LoadingFrameProgressBar", "left", 1280*value-2, 0);
			end
		end
	end
end

--将设置loading背景图的逻辑抽离出来，家园loading等也可以用
function SetLoadingImg(uiTexture)
	if not uiTexture then return end
	-- 存储目录
	local loadingDir = "data/http/loading/"	
	if not gFunc_isStdioDirExist(loadingDir) then
		gFunc_makeStdioDir(loadingDir)
	end

	local loadingCache = getkv("loadingCache") or {}
	local isLoaded = false
	--家园的loading地图也使用了这里的背景，想做下特殊处理，家远的loading从开始到结束，使用的都是一样的背景
	if EnterHomeLandInfo and EnterHomeLandInfo.step and EnterHomeLandInfo.step ~= HomeLandInterativeStep.DONE then
		if EnterHomeLandInfo.loadTexturePath then
			isLoaded = true
			uiTexture:SetTexture(EnterHomeLandInfo.loadTexturePath)
		end
	end

	-- 从缓存中获取随机图片
	if not isLoaded and loadingCache and #loadingCache > 0 then
		local random = math.random(1, #loadingCache)
		-- 文件被玩家删除
		if not gFunc_isStdioFileExist(loadingCache[random].path) then
			table.remove(loadingCache, random)
		-- 检测文件内容是否发生变化（防止用户故意修改文件）
		elseif gFunc_getSmallFileMd5(loadingCache[random].path) ~= loadingCache[random].md5 then
			gFunc_deleteStdioFile(loadingCache[random].path)
			table.remove(loadingCache, random)
		else
			isLoaded = true
			uiTexture:SetTexture(loadingCache[random].path)
			
			--记录家园使用的背景图
			if EnterHomeLandInfo and EnterHomeLandInfo.step and EnterHomeLandInfo.step ~= HomeLandInterativeStep.DONE then
				if not EnterHomeLandInfo.loadTexturePath then
					EnterHomeLandInfo.loadTexturePath = loadingCache[random].path
				end
			end
		end
	end

	-- 随机显示本地图片
	if not isLoaded then
		local textureCount = #LoadTexturePath
		local random = math.random(1, textureCount)
		local szMainlandPath = LoadTexturePath[1].."_chn.png";
		local szOverseasPath = LoadTexturePath[1]..".png";

		local index = random + 1
		index = (index - 1) % textureCount + 1
		local canSetTexture = false
		while index ~= random do
			szMainlandPath = LoadTexturePath[index].."_chn.png";
			szOverseasPath = LoadTexturePath[index]..".png";
			if env >= 10 then
				if uiTexture:SetTextureMainlandOrOverseas(szOverseasPath,szOverseasPath) then
					canSetTexture = true;
					break;
				end
			else
				if uiTexture:SetTextureMainlandOrOverseas(szMainlandPath,szOverseasPath) then
					canSetTexture = true;
					break;
				else
					if uiTexture:SetTextureMainlandOrOverseas(szOverseasPath,szOverseasPath) then
						canSetTexture = true;
						break;
					end
				end
			end 

			index = index + 1
			index = (index - 1) % textureCount + 1
		end

		if isEducationalVersion then
			szMainlandPath = "ui/mobile/texture0/bigtex/edu_loading.png";
			szOverseasPath = "ui/mobile/texture0/bigtex/edu_loading.png";
		end
		
		if not canSetTexture then
			for i=1,6 do
				szMainlandPath = LoadTexturePath[i]..".png";
				szOverseasPath = LoadTexturePath[i]..".png";
				if uiTexture:SetTextureMainlandOrOverseas(szMainlandPath, szOverseasPath) then
					break;
				end
			end
		end
	end

	-- 检测是否还有未下载的图片
	for i = 1, #ns_loading_list do
		-- 避免重复下载一张图片
		if ns_loading_state[ns_loading_list[i].md5] then
			if not gFunc_isStdioFileExist(ns_loading_state[ns_loading_list[i].md5].path) then
				ns_loading_state[ns_loading_list[i].md5] = nil
				setkv("ns_loading_state", ns_loading_state)
			else
				-- 避免重复下载，该图下载完成才会下载另外一张图
				break
			end
		end

		local isExist = -1
		for j = 1, #loadingCache do
			if ns_loading_list[i].md5 == loadingCache[j].md5 then
				isExist = i
				break
			end
		end

		if isExist < 0 and ns_loading_state[ns_loading_list[i].md5] == nil then
			local filePath = string.format("data/http/loading/%s.png_", ns_loading_list[i].md5)	--加上"_"后缀
			local Md5 = ns_loading_list[i].md5

			-- 此回调无法作为下载完成的标志（下载失败或者没有完成下载也会执行此回调）
			local function downloadFinish()
				if loadingCache and filePath and Md5 then
					if gFunc_isStdioFileExist(filePath)  then
						-- 校验文件大小和Md5码
						local fsize = gFunc_getStdioFileSize(filePath)/1000
						local realMd5Str = gFunc_getSmallFileMd5(filePath)
						if fsize > 0 and Md5 == realMd5Str then
							table.insert(loadingCache, #loadingCache + 1, {path = filePath, md5 = Md5})
							setkv("loadingCache", loadingCache)
							
							ns_loading_state[Md5] = nil -- 下载完成
							setkv("ns_loading_state", ns_loading_state)
						else							
							gFunc_deleteStdioFile(filePath)
							ns_loading_state[Md5] = nil -- 清除下载状态
							setkv("ns_loading_state", ns_loading_state)

						end
					else
						ns_loading_state[Md5] = nil -- 清除下载状态
						setkv("ns_loading_state", ns_loading_state)
					end
				end
			end

			ns_loading_state[Md5] = {path = filePath, state = "loading"} -- 标记正在下载中
			setkv("ns_loading_state", ns_loading_state)

			if gFunc_isStdioFileExist(filePath)  then
				gFunc_deleteStdioFile(filePath)
			end

			ns_http.func.downloadPng(ns_loading_list[i].path, filePath, nil, nil, downloadFinish)
			break
		end
	end
end
--获得随机loading提示字符串
function GetLoadingRandomTip()
    -- 随机字符串id起始结束配置表
    local TipsStringIdList = {
        {
            start = 3202,
            over = 3239,
        },
        {
            start = 21057,
            over = 21077,
        }
    }

    local listPos = math.random(1, #TipsStringIdList)
	local stringId = math.random(TipsStringIdList[listPos].start, TipsStringIdList[listPos].over);
	return GetS(stringId);
end

function ShowLoadingFrame(tips, timeout)	
	gStartLoadingTime = os.time()
	
	pcall(function() if LobbyMusicPlayer then LobbyMusicPlayer:PausePlayingMusic() end end)
	GetInst("RoomMatchingManager"):StopMatch(true, true)
	pcall(function() AllRoomManager:CleanReqConnectRSRoom() end);
	pcall(function() GetInst("NSearchPlatformService"):HideSearchPlatform(true) end);	
	pcall(function()
		CloseRoomFrame()
		GetInst("MiniUIManager"):CloseUI("ArchiveInfoDetailAutoGen")
	end)
	pcall(function()
		GetInst("MapBindTagsInterface"):CloseTagMapsUI()
	end)

	pcall(function()
		local cInterface = GetInst("CreationCenterInterface")
		if cInterface and cInterface.EnterGameCloseCreationCenterFrames then
			cInterface:EnterGameCloseCreationCenterFrames()
		end
	end)
	
	pcall(function ()
		local ndHallCtrl = GetInst("MiniUIManager"):GetCtrl("NationdayHall")
		if ndHallCtrl then 
			ndHallCtrl:ContentcmpBtn_closeClick()
		end 
		
		local ndRandCtrl = GetInst("MiniUIManager"):GetCtrl("NationdayRank")
		if ndRandCtrl then 
			ndRandCtrl:Close_btnClick()
		end
	end)

	pcall(function()
		GetInst("PlayerInfoCardMgr"):CloseUI()
	end)

	
	local matchTeamupService = GetInst("MatchTeamupService")
	pcall(function()
		if matchTeamupService then
			matchTeamupService:CloseAllUI()
		end
	end)
	local isHaveShow = matchTeamupService and matchTeamupService.haveShowLoadingFrame

	CurLoadingProgress = 0;
	RealLoadingProgress = 0;
	getglobal("LoadingFrameProgressBar"):SetValue(0.01);
	getglobal("LoadingFrameProgressBarCursorTex"):SetPoint("left", "LoadingFrameProgressBar", "left", 1280*0.01-2, 0);

	if not isHaveShow then
		local uiTexture = getglobal("LoadingFrameBkg");
		SetLoadingImg(uiTexture)
	end

	if not getglobal("LoadingFrame"):IsShown() then
		getglobal("LoadingFrame"):Show();
	end
	
	--随机提示
	local randTips = ""
	if tips then
		randTips = tips;
	else
		randTips = GetLoadingRandomTip();
	end
	
	if timeout then
		TimeOut = timeout;
	else
		TimeOut = 0;
	end

	if not isHaveShow then
		--随机提示
		if randTips and #randTips>0 then
			getglobal("LoadingFrameTips"):SetText(randTips);
		end
	end
	
	if matchTeamupService and matchTeamupService.haveShowLoadingFrame then
		matchTeamupService.haveShowLoadingFrame = nil
	end

	--微缩加载、插件包加载tips初始化
	getglobal("LoadingFrameResourceTips"):SetText("")
	getglobal("LoadingFrameAudioResourceTips"):SetText("")
	getglobal("LoadingFrameModPkgResourceTips"):SetText("")
	--加载的插件数
	local blockCount = 0;
	local actorCount = 0;
	local itemCount = 0;
	local craftCount = 0;
	local modCount = 0;
	local furnaceCount = 0;
	local plotCount = 0;
	local taskCount = 0;
	local statusCount = 0
	Log("*** modCount = 0");
	for i = 1, ModMgr:getMapModCount() do
		local moddesc = ModMgr:getMapModDescByIndex(i-1);
		Log("*** mod "..moddesc.uuid);
		if moddesc.uuid == ModMgr:getMapDefaultModUUID() then
			local mod = ModMgr:getMapModByIndex(i-1);
			blockCount = blockCount + ModMgr:getGameModBlockCount(mod);
			actorCount = actorCount + ModMgr:getGameModActorCount(mod);
			itemCount = itemCount + ModMgr:getGameModItemCount(mod);
			craftCount = craftCount + ModMgr:getGameModCraftCount(mod);

			furnaceCount = furnaceCount + ModMgr:getGameModFurnaceCount(mod);
			plotCount = plotCount + ModMgr:getGameModNpcPlotCount(mod);
			taskCount = taskCount + ModMgr:getGameModNpcTaskCount(mod);
			if UseNewModsLib then
				statusCount = statusCount + ModMgr:getGameModStatusCount(mod)
			end
		elseif moddesc.modtype == 0 then
			modCount = modCount + 1;
		elseif moddesc.modtype == 1 then
			--material mods doesn't count
		end
	end
	local componentCount = blockCount + actorCount + itemCount + craftCount + furnaceCount + plotCount + taskCount + statusCount
	local modTips = getglobal("LoadingFrameModTips");
	if componentCount > 0 or modCount > 0 then
		if AccountManager:getCurWorldId() ~= 0 then
			local worldDesc = AccountManager:findWorldDesc(AccountManager:getCurWorldId());
			if worldDesc.owneruin == AccountManager:getUin() then
				modTips:SetText(GetS(4101));
				modTips:Show();
			else
				modTips:Hide();
			end
		else
			modTips:Hide();
		end
		--modTips:SetText(GetS(4101, componentCount, modCount));
		-- statisticsGameEvent(510, '%d', modCount, '%d', blockCount, '%d', actorCount, '%d', itemCount, '%d', craftCount, '%d', furnaceCount, '%d', plotCount, '%d', taskCount);
	else
		modTips:Hide();
	end

	GetInst("MiniUIManager"):CloseUI("countryTreasureAutoGen") 
	GetInst("MiniUIManager"):CloseUI("MiNiMusicFestivalAutoGen") 
	GetInst("MiniUIManager"):CloseUI("skin_try_onAutoGen") 


	
	SafeCallFunc(function() SandboxLua.eventDispatcher:Emit(nil, "LoadingFrame_Shown", SandboxContext()) end)
end

function LoadingFrame_OnShow()
	Log( "call LoadingFrame_OnShow" );
	-- print(EnterMapReport)
	-- 事件上报
	if EnterMapReport then
		InsertStandReportGameJoinParamArg(EnterMapReport)
		EnterMapReport = nil
	end
end


function LoadingFrame_OnHide()
	
end

--------------------------------------------------------LoadLoopFrame--------------------------------------------------
function LoadLoopFrame_OnLoad()
	this:setUpdateTime(0.05);
end

function LoadLoopFrame_OnUpdate()
	local LoadLoopFrameTex = getglobal("LoadLoopFrameTex")
	local angle = LoadLoopFrameTex:GetAngle();
	angle = angle + 10;

	if angle > 360 then
		angle = 0;
	end

	LoadLoopFrameTex:SetAngle(angle);
end

--------------------------------------------------------LoadLoopFrame2--------------------------------------------------
function LoadLoopFrame2_OnLoad()
	this:setUpdateTime(0.05);
end

function LoadLoopFrame2_OnUpdate()
	local tex = getglobal("LoadLoopFrame2Tex")
	local angle = tex:GetAngle();
	angle = angle + 10;

	if angle > 360 then
		angle = 0;
	end

	tex:SetAngle(angle);
end

function LoadLoopFrame2_OnHide()
	getglobal("LoadLoopFrame2Bkg"):Hide()
	getglobal("LoadLoopFrame2TexBg"):Hide()
	getglobal("LoadLoopFrame2Tex"):SetAnchorOffset(0,0)

end

function ShowNoTransparentLoadLoop()
	if isEducationalVersion then
		return;
	end
	
	if gIsSingleGame then return end
	if ns_data.login_alone_tips_show == true then return end
	if IsStandAloneMode("") then return end
	
	ShowLoadLoopFrame2(true,"auto")
end

function HideNoTransparentLoadLoop()
	if isEducationalVersion then
		return;
	end
	HideLoadLoopFrame2();
end


--------------------------------------------------------LoadLoopFrame3--------------------------------------------------
function LoadLoopFrame3_OnLoad()
	this:setUpdateTime(0.05);
end

function LoadLoopFrame3_OnUpdate()
	local tex = getglobal("LoadLoopFrame3Tex")
	local angle = tex:GetAngle();
	angle = angle + 10;

	if angle > 360 then
		angle = 0;
	end

	tex:SetAngle(angle);

	--暂时没用
	if EnterMainMenuInfo.ReopenRoomInfo and EnterMainMenuInfo.ReopenRoomInfo.ReOpen then	--再来一局
		ReOpenRoom();
		EnterMainMenuInfo.ReopenRoomInfo.ReOpen = false;
		HideLoadLoopFrame3();
	end
end

function ShowLoadingIndicator(title)
	ShowLoadLoopFrame3(true,"auto");
	if title ~= nil and title ~= "" then
		getglobal("LoadLoopFrame3Title"):SetText(title);
		getglobal("LoadLoopFrame3Title"):Show();
	else
		getglobal("LoadLoopFrame3Title"):Hide();
	end
end

function HideLoadingIndicator()
	HideLoadLoopFrame3();
end

local currentCustomModelNumber = -1
function FullyCustomModelProgress(number,maxNumber)
	print("FullyCustomModelProgress",number,maxNumber)
	local resourceTips = getglobal("LoadingFrameResourceTips")
	if 0 == maxNumber then
		resourceTips:SetText("")
	else
		if currentCustomModelNumber ~= number then
			currentCustomModelNumber = number
			if number >= maxNumber then
				resourceTips:SetText(GetS(33352))
			else
				resourceTips:SetText(GetS(33351)..number.."/"..maxNumber)
			end
		else
			resourceTips:SetText(GetS(33352))
		end
	end
end

local currentCustomAudioNumber = 0
function FullyCustomAudioProgress(number,maxNumber)
	print("FullyCustomAudioProgress",number,maxNumber)
	local resourceTips = getglobal("LoadingFrameAudioResourceTips")
	if 0 == maxNumber then
		resourceTips:SetText("")
	else
		if currentCustomAudioNumber ~= number then
			currentCustomAudioNumber = number
			if number >= maxNumber then
				resourceTips:SetText(GetS(33356))
			else
				resourceTips:SetText(GetS(33355)..number.."/"..maxNumber)
			end
		else
			resourceTips:SetText(GetS(33356))
		end
	end
end

local currentCustomPicNumber = 0
function FullyCustomPicProgress(number,maxNumber)
	print("FullyCustomPicProgress",number,maxNumber)
	local resourceTips = getglobal("LoadingFramePicResourceTips")
	if 0 == maxNumber then
		resourceTips:SetText("")
	else
		if currentCustomPicNumber ~= number then
			currentCustomPicNumber = number
			if number >= maxNumber then
				resourceTips:SetText(GetS(33358))
			else
				resourceTips:SetText(GetS(33357)..number.."/"..maxNumber)
			end
		else
			resourceTips:SetText(GetS(33358))
		end
	end
end

local currentModPkgCustomModelNumber = 0
function FullyModPkgCustomModelProgress(number,maxNumber)
	print("FullyModPkgCustomModelProgress",number,maxNumber)
	local resourceTips = getglobal("LoadingFrameModPkgResourceTips")
	if 0 == maxNumber then
		resourceTips:SetText("")
	else
		if currentModPkgCustomModelNumber ~= number then
			currentModPkgCustomModelNumber = number
			if number >= maxNumber then
				resourceTips:SetText(GetS(33354))
			else
				resourceTips:SetText(GetS(33353)..number.."/"..maxNumber)
			end
		else
			resourceTips:SetText(GetS(33354))
		end
	end
end
--------------------------------------------------------LoadLoopFrame4--------------------------------------------------
function LoadLoopFrame4_OnLoad()
	this:setUpdateTime(0.05);
end

function LoadLoopFrame4_OnUpdate()
	local tex = getglobal("LoadLoopFrame4Tex")
	local angle = tex:GetAngle();
	angle = angle + 10;

	if angle > 360 then
		angle = 0;
	end

	tex:SetAngle(angle);	
end

function ShowLoadingMiniBase(title)
	getglobal("LoadLoopFrame4"):Show();
	if title ~= nil and title ~= "" then
		getglobal("LoadLoopFrame4Title"):SetText(title);
		getglobal("LoadLoopFrame4Title"):Show();
	else
		getglobal("LoadLoopFrame4Title"):Hide();
	end
	local uiTexture = getglobal("LoadLoopFrame4Bkg");	
	SetLoadingImg(uiTexture)
	uiTexture:Show()
end

function HideLoadingMiniBase()
	getglobal("LoadLoopFrame4"):Hide();
end

function ShowMaskLoadingFrame()
	--用于预先显示LoadingFrame，但未拉起房间数据（其实未真正进入loading），用于没有tips, timeout参数情况
	CurLoadingProgress = 0;
	RealLoadingProgress = 0;
	getglobal("LoadingFrameProgressBar"):SetValue(0.01);
	getglobal("LoadingFrameProgressBarCursorTex"):SetPoint("left", "LoadingFrameProgressBar", "left", 1280*0.01-2, 0);
	
	local uiTexture = getglobal("LoadingFrameBkg");
	SetLoadingImg(uiTexture)

	if not getglobal("LoadingFrame"):IsShown() then
		getglobal("LoadingFrame"):Show();
	end
	
	--随机提示
	local randTips = GetLoadingRandomTip();
	--随机提示
	if randTips and #randTips>0 then
		getglobal("LoadingFrameTips"):SetText(randTips);
	end

	--微缩加载、插件包加载tips初始化
	if getglobal("LoadingFrameResourceTips") then
		getglobal("LoadingFrameResourceTips"):SetText("")
	end
	if getglobal("LoadingFrameAudioResourceTips") then
		getglobal("LoadingFrameAudioResourceTips"):SetText("")
	end
	if getglobal("LoadingFrameModPkgResourceTips") then
		getglobal("LoadingFrameModPkgResourceTips"):SetText("")
	end
	GetInst("MatchTeamupService").haveShowLoadingFrame = true
end