-- 这个lua文件过于庞大，写点注释方便以后修改和扩展功能

-- 1.填写需要展示元素的分组 typeid和对应的名字stringid
-- t_EditorTypesId  
-- 2.设置数据模型类别标记，UI标题等
-- SetChooseOriginalFrame
-- 3.初始化数据模型
-- LoadOriginalDef
-- 4.初始化tab
-- SetChooseOriginalFrameTab
-- 5.更新右边选择框
-- UpdateEditorOriginalBox
--6.点击按钮回调
--OriginalGridTemplate_OnClick
-- 7.确定按钮回调
-- OnCurEditorUICallBack

local IconPath = "";
local IsCreateNewMod = false;
local ModEditable = true;
local ModLoadOnly = false;
local Max_Slot_Num = 256;
local Current_Page_Index = 1;
local MyModsEditorType; 
local Current_Edit_BlockDef;
local Current_Edit_ActorDef;
local Current_Edit_ItemDef;
local Current_Edit_CraftDef;
local Current_Edit_FurnaceDef;
local Current_Edit_AiItem;
local Current_Edit_ItemSkill;
--local Current_Edit_NpcPlot;  todo_delete
local t_EditorTypesId = {
		block={[1]=3961, [2]=3962, [3]=292, [4]=3963, [5]=16100, [6]=3627},
		actor={[1]=3964, [2]=3965, [3]=3966, [5]=16100, [6]=3627},
		item={[1]=3755, [2]=3756, [3]=3757, [4]=100006, [5]=16100, [6]=3627},
		craft={[1]=291, [2]=4487, [3]=292, [4]=293},
		furnace={[1]=9060, [2]=9061, [3]=9062, [4]=9063},
		dropitem={[1]=4800, [2]=4801, [3]=4802, [4]=4803, [5]=4544},
		craftresult={[1]=4800, [2]=4801, [3]=4802, [4]=4803, [5]=4544},
		craftmaterial={[1]=4800, [2]=4801, [3]=4802, [4]=4803, [5]=4544},
		furnaceresult={[1]=4800, [2]=4801, [3]=4802, [4]=4803, [5]=4544},
		furnacematerial={[1]=4800, [2]=4801, [3]=4802, [4]=4803, [5]=4544},
		projectile={[1]=4543, [2]=4544},
		bullet={[1]=4546, [2]=4547},
        ai_block={6325,6326,6327,8624,4544},
        ai_food={4515,4544,3525,3526,3527,3528,4544},
        ai_actor={3932,4544},
        ai_container={4685},	--LLDO:new add:箱子: tab按钮名
        ai_craft={[1]=291, [2]=4487, [3]=292, [4]=293, [5]=4544},
        ai_targetblock={4687},
        ai_useitem={4631},
        PlotIcon={3932, 3128},	--剧情:图标: "生物" , "道具"
        PlotItemID={3128, 3128},	--剧情, 拥有道具
        transfer={[1]=4800, [2]=4801, [3]=4802, [4]=4803, [5]=4544}, --传送点
        craft_tool = {1554,1555},
}
--t_EditorTypesId 映射表
local t_EditorTypesName = {
	block={total = 1, color = 2, build = 3, others = 4, curmap = 5, resLib = 6},
	actor={animal = 1, monster = 2, others = 3, curmap = 5, resLib = 6},
	item={tool = 1, weapon = 2, food = 3, equip = 4, curmap = 5, resLib = 6},
	-- craft={common = 1, equip = 2, build = 3, machine = 4},
	-- furnace={crop = 1, tool = 2, sundries = 3, block = 4},
	-- dropitem={crop = 1, tool = 2, sundries = 3, block = 4, custom = 5},
	-- craftresult={crop = 1, tool = 2, sundries = 3, block = 4, custom = 5},
	-- craftmaterial={crop = 1, tool = 2, sundries = 3, block = 4, custom = 5},
	-- furnaceresult={crop = 1, tool = 2, sundries = 3, block = 4, custom = 5},
	-- furnacematerial={crop = 1, tool = 2, sundries = 3, block = 4, custom = 5},	
};

local t_OriginalInfo = {};
local CurEditorType = 1;
local Max_OriginalBlock_Num = 603;

local lastBlockPage = nil;
local lastActorPage = nil;
local lastItemPage = nil;
local lastPlotPage = nil;

--当前等待被修改的Texture，用于移动端导入logo，贴图
local CurrentEditTexture;
local CurrenEditBody;

local Max_CustomComponent_Num = 300;

--编辑模式：
-- 1=插件编辑：普通插件(不是我的默认库也不是地图的默认库)的编辑界面
-- 2=插件库：我的默认库的编辑界面
-- 3=选择插件：地图的默认库 创建地图时弹出
-- 4=本地图插件：地图的默认库-编辑界面，创建地图后进入
-- 5=从库中添加：从我的默认库选择组件,复制到地图默认库中
Current_Edit_Mode = 0;
Current_Edit_MapOwid = nil;

FrameStack = {
	
	stack = {
		--LLTODO:换成:ArchiveInfoFrame
		--{_name="LobbyFrame"},
		{_name="ArchiveInfoFrame"},
	},
	lastGoBackFrame = nil,
	fromFrame = nil;

	reset = function(baseFrameName)
		if baseFrameName then
			FrameStack.stack = { {_name=baseFrameName} };
		else
			FrameStack.stack = {};
		end
	end,

	cur = function(offset)
		offset = offset or 0;
		if offset <= 0 then
			return FrameStack.stack[#FrameStack.stack + offset];
		elseif offset == 1 then
			return lastGoBackFrame;
		else
			return nil;
		end
	end,

	remove = function(frame)
		Log("FrameStack.remove");

		local leaveFunc = _G[frame._name.."_OnLeave"];
		if leaveFunc then
			leaveFunc();
		elseif HasUIFrame(frame._name) then
			if frame._name == "LobbyFrame" or frame._name == "lobbyMapArchiveList" then
				HideLobby() --code_by:huangfubin 2021.9.22 关闭/隐藏存档界面使用统一的接口
			else
				getglobal(frame._name):Hide();
			end
		end

		for i = #FrameStack.stack, 1, -1 do
			if FrameStack.stack[i] == frame then
				table.remove(FrameStack.stack, i);
			end
		end
	end,

	enterNewFrame = function(name, args, callback, userdata)
		local new = {
			_name = name,
			_callback = callback,
			_userdata = userdata,
		};
		if args then
			for k,v in pairs(args) do
				new[k] = v;
			end
		end

		FrameStack.lastGoBackFrame = nil;

		local old = FrameStack.stack[#FrameStack.stack];

		Log("FrameStack.enterNewFrame new=");

		if old then
			Log("  old="..old._name);
			local leaveFunc = _G[old._name.."_OnLeave"];
			if leaveFunc then
				leaveFunc();
			elseif HasUIFrame(old._name) then
				if old._name == "LobbyFrame" or old._name == "lobbyMapArchiveList" then
					HideLobby() --code_by:huangfubin 2021.9.22 关闭/隐藏存档界面使用统一的接口
				else
					getglobal(old._name):Hide();
				end
			end
		end

		table.insert(FrameStack.stack, new);

		local enterFunc = _G[new._name.."_OnEnter"];
		if enterFunc then
			enterFunc();
		elseif EnableDynamicLoadFile or HasUIFrame(new._name) then
			if args and args.isnew then
				GetInst("UIManager"):Open(new._name)
			else
				getglobal(new._name):Show();
			end
		end
	end,

	goBack = function()
		if #FrameStack.stack >= 1 then

			local cur = FrameStack.stack[#FrameStack.stack];
			local prev = FrameStack.stack[#FrameStack.stack - 1];

			Log("FrameStack.goBack cur=");

			local leaveFunc = _G[cur._name.."_OnLeave"];
			if leaveFunc then
				leaveFunc();
			elseif HasUIFrame(cur._name) then
				if cur._name == "LobbyFrame" or cur._name == "lobbyMapArchiveList" then
					HideLobby() --code_by:huangfubin 2021.9.22 关闭/隐藏存档界面使用统一的接口
				elseif cur.isnew then
					GetInst("UIManager"):Close(cur._name)
				else
					getglobal(cur._name):Hide();
				end
			end

			FrameStack.lastGoBackFrame = cur;

			table.remove(FrameStack.stack, #FrameStack.stack);
			
			if cur._callback then
				cur._callback(cur, cur._userdata);
			end

			if prev then
				Log("  prev=");
				local enterFunc = _G[prev._name.."_OnEnter"];
				if enterFunc then
					enterFunc();
				elseif HasUIFrame(prev._name) then
					if prev._name == "LobbyFrame" or prev._name == "lobbyMapArchiveList" then
						ShowLobby() --code_by:huangfubin 2021.9.22 打开存档界面使用统一的接口
					elseif prev.isnew then
						GetInst("UIManager"):Open(prev._name)
					else
						if prev._name == "ArchiveInfoFrame" then
							if not GetInst("mainDataMgr"):AB_NewArchiveLobbyMain() then
								ShowMapDetailInfo()
							end
						else
							getglobal(prev._name):Show();
						end
					end
				end
			end
		end
	end,

	findLastFrame = function(name)
		for i = #FrameStack.stack, 1, -1 do
			if FrameStack.stack[i]._name == name then
				return FrameStack.stack[i];
			end
		end
		return nil;
	end,

	findLastFrameBefore = function(name, beforeWhat)
		local index = nil;
		for i = #FrameStack.stack, 1, -1 do
			if FrameStack.stack[i] == beforeWhat then
				index = i;
				break;
			end
		end

		if index then
			for i = index - 1, 1, -1 do
				if FrameStack.stack[i]._name == name then
					return FrameStack.stack[i];
				end
			end
		end

		return nil;
	end,
}

AnimMgr = {

	playing = {},

	playBlink = function(self, uiname, duration, interval)
		Log("AnimMgr playBlink");
		local data = {
			uiname = uiname,
			duration = duration,
			interval = interval,
			livingtime = 0,
			isshown = getglobal(uiname):IsShownSelf(),
		};
		data.update = function(self, deltatime)
			self.livingtime = self.livingtime + deltatime;
			if self.livingtime < self.duration then
				local percent = math.fmod(self.livingtime, self.interval) / self.interval;
				if percent < 0.5 then
					getglobal(self.uiname):Show();
				else
					getglobal(self.uiname):Hide();
				end
				return true;
			else
				return false;
			end
		end;
		data.onstop = function(self)
			if self.isshown then
				getglobal(self.uiname):Show();
			else
				getglobal(self.uiname):Hide();
			end
		end;
		table.insert(self.playing, data);
	end,

	update = function(self, deltatime)
		local dying = {};
		for i, data in ipairs(self.playing) do
			local ret = data:update(deltatime);
			if ret == false then
				table.insert(dying, i);
			end
		end
		for j = #dying, 1, -1 do
			local index = dying[j];
			local data = self.playing[index];
			if data.onstop then
				data:onstop();
			end
			table.remove(self.playing, index);
		end
	end,

	stopAll = function(self)
		Log("AnimMgr stopAll");
		for i, data in ipairs(self.playing) do
			if data.onstop then
				data:onstop();
			end
		end
		self.playing = {};
	end,

	stopByName = function(self,uiname)
		Log("AnimMgr stopByName");
		for i, data in ipairs(self.playing) do
			if data.uiname == uiname and data.onstop then
				data:onstop();
				table.remove(self.playing, i);
			end
		end
	end,
}

function MyModsEditorFrameCloseBtn_OnClick()

	local modName = getglobal("TabSettingFrameModNameEdit"):GetText();
	local modDesc = getglobal("TabSettingFrameModDescEdit"):GetText();

	if IsCreateNewMod then
		if modName ~= '' or modDesc ~= '' then 
			MessageBox(5, GetS(3937));
			getglobal("MessageBoxFrame"):SetClientString("确认退出编辑器");
			return;
		end
	end

	if FrameStack.cur().editmode == 1 then
		if FrameStack.cur().haveModified==true then
			local moddesc = ModEditorMgr:getCurrentEditModDesc();
			statisticsGameEvent(511, '%lls', moddesc.uuid);
		end
	end

    ModEditorMgr:requestSaveUserModAllocatedId()

	if CurWorld and CurWorld.isGodMode and CurWorld:isGodMode() then 
    	--如果是在地图中打开的插件库，关闭的时候无需返回ArchiveInfoFrame和LobbyFrame
    	local cur = FrameStack.stack[#FrameStack.stack]
		local prev = FrameStack.stack[#FrameStack.stack - 1]

		if cur._name == "MyModsEditorFrame" and prev and (prev._name == "ArchiveInfoFrame" or prev._name == "LobbyFrame" or prev._name == "lobbyMapArchiveList") then 
    		MyModsEditorFrame_OnLeave()
    		table.remove(FrameStack.stack, #FrameStack.stack);
			--游戏内 cur和prev对应的ui都不显示的话，要变成准星模式，并且隐藏屏幕下方的关于esc的提示
			if not getglobal("MyModsEditorFrame"):IsShown() and not getglobal(prev._name):IsShown() then
				if CurMainPlayer and not CurMainPlayer:isSightMode() then
					CurMainPlayer:setSightMode(true);
					if getglobal("PcGuideKeySightMode"):IsShown() then
						getglobal("PcGuideKeySightMode"):Hide()
					end
				end
			end
    	else
    		FrameStack.goBack()
			if cur._name == "MyModsEditorFrame" and getglobal("MyModsEditorFrame"):IsShown() then
				if CurMainPlayer and CurMainPlayer:isSightMode() then
					CurMainPlayer:setSightMode(false)
				end
			end
    	end 
    else
    	FrameStack.goBack()
    end
end

function MyModsEditorFrameShowMyModsBtn_OnClick()
	-- statisticsGameEvent(502);
	FrameStack.enterNewFrame("MyModsFrame");
end

function ModDescEdit_OnFocusLost()
	local text = ReplaceFilterString(this:GetText());
	this:SetText(text);
	if text == "" then
		getglobal("TabSettingFrameModDescTip"):Show();
	else
		getglobal("TabSettingFrameModDescTip"):Hide();
	end
end

function ModDescEdit_OnFocusGained()
	getglobal("TabSettingFrameModDescTip"):Hide();
end

function TabSettingFrame_OnLoad()
	getglobal("TabSettingFrameModDescTip"):SetText(GetS(178), 195, 178, 136);
end


function SettingEditableChecker_OnClick()
	local btnName = this:GetName();
	local tick = getglobal(this:GetName().."Tick");

	if tick:IsShown() then
		ModEditable = false;
		tick:Hide();
	else
		ModEditable = true;
		tick:Show();
	end
end

function SettingLoadOnlyOneChecker_OnClick()
	local tick = getglobal(this:GetName().."Tick");

	if tick:IsShown() then
		ModLoadOnly = false;
		tick:Hide();
	else
		ModLoadOnly = true;
		tick:Show();
	end
end

local t_ModTabNameId ={3929, 3930, 3931, 3932, 3933, 1231, 1230, 11006};

function ModEditorTabs_OnLoad()
	Log("----------------------------------ModEditorTabs_OnLoad------------------------------------");
	
end

function OnImagePicked(path)
	if CurEditorType == 1 then
			CurrentEditTexture:SetTexture(path, true);
	elseif CurEditorType == 2 then
			CurrenEditBody:setCustomDiffuseTexture(path);
	end
end

function SetCurrentEditTexture(texture)
	CurrentEditTexture = texture;
end

function SetCurrentEditBody(body)
	CurrenEditBody = body;
end

--设置modlogo点击
function CreateModSetLogoBtn_OnClick()
	CurrentEditTexture = getglobal("ModThumbFrameLogo");
	if IsCreateNewMod then
		IconPath = ModEditorMgr:requestChooseModIcon();
	 	Log("IconPath"..IconPath);
	 	if IconPath ~= "" then
			getglobal("ModThumbFrameLogo"):SetTexture(IconPath, true);
		end
	else
		IconPath = ModEditorMgr:requestReplaceModIcon();
	 	if IconPath ~= "" then
	 		Log("IconPath "..IconPath);
			--因为名字相同，所以需要ResouceManager先释放原来的资源
			--ResouceMgr:release(IconPath);
			getglobal("ModThumbFrameLogo"):SetTexture(IconPath, true);
		end
	end
end

--侧边栏点击
function EditorTabTemplate_OnClick(target)
	if target then 
		this = target
	end
	local tabindex = this:GetClientID();
	local btnName = this:GetName();
	local checked = getglobal(btnName.."Checked");
	getglobal("ChooseOriginalFrameOkBtn"):SetClientID(0);
	getglobal("ChooseOriginalFrameOkBtn"):SetClientString("");
	if checked:IsShown() then return end
	
	Log("EditorTabTemplate_OnClick:"..btnName);
	if string.find(btnName, "ModEditorTab") then
		UpdateMyModsEditorFrame(tabindex);
	elseif string.find(btnName, "ChooseOriginalFrameTabs") then
		-- 插件审核屏蔽
		if CheckChooseOriginalFrameTabsDisabled(tabindex) then
			return
		end

		if UpdateEditorOriginalBox(tabindex) then
			local startIndex = getglobal("ChooseOriginalFrameTabs1"):GetClientID();
			SetChooseOriginalFrameTab(startIndex);
		end
	elseif string.find(btnName, "ActorEditSelectModelFrameTabs") then
		if AccountManager:getMultiPlayer() == 2 then --客机不能用资源库
			ShowGameTips(GetS(3945, 3));
			return;
		end
		ActorEditMgr:UpdateActorEditSelectModelFrame(tabindex, ActorEditMgr.curSelectOpetateType);
	elseif string.find(btnName, "FullyCustomModelEditorSelectModelFrameTabs") then
		if AccountManager:getMultiPlayer() == 2 then --客机不能用资源库
			ShowGameTips(GetS(3945, 3));
			return;
		end
		GetInst("UIManager"):GetCtrl("FullyCustomModelEditor"):UpdateSelectModelFrame(tabindex);
	elseif string.find(btnName, "FullyCustomModelImportTabs") then
		if AccountManager:getMultiPlayer() == 2 then --客机不能用资源库
			ShowGameTips(GetS(3945, 3));
			return;
		end
		GetInst("UIManager"):GetCtrl("FullyCustomModelImport"):UpdateFrame(tabindex);
	end
end

function UpdateMyModsEditorFrame(tabindex)
	if IsCreateNewMod and tabindex ~= 1 then
	 --	MessageBox(4, GetS(3938));
	 	return;
	end

	for i=1, 8 do
		if IsCreateNewMod then
			getglobal("ModEditorTab"..i.."Normal"):SetGray(true);
		else
			getglobal("ModEditorTab"..i.."Normal"):SetGray(false);
		end


		if tabindex == i then
			getglobal("ModEditorTab"..i.."Normal"):Hide();
			getglobal("ModEditorTab"..i.."Checked"):Show();
			getglobal("ModEditorTab"..i.."Name"):SetTextColor(255, 153, 63);
		else
			getglobal("ModEditorTab"..i.."Normal"):Show();
			getglobal("ModEditorTab"..i.."Checked"):Hide();
			getglobal("ModEditorTab"..i.."Name"):SetTextColor(158, 225, 231);
		end
	end

	Log("EditorTabTemplate_OnClick "..tabindex);
	UpdateEditorSomeFrameStatus(tabindex);
end

--logo
function CreateModSetLogo_OnClick()
	-- ShowEditAttrTipsFrame(GetS(3986), GetS(3987));
end

function ModEditorSaveModBtn_OnClick()
	local settingFrame =  getglobal("TabSettingFrame");
	if settingFrame:IsShown() then
			--名字不能为空
		--local text = getglobal("TabSettingFrameModNameEdit"):GetText();
		--if text == "" then
		--	MessageBox(4, GetS(3936));
		--	return;
		--end

		local modname = getglobal("TabSettingFrameModNameEdit"):GetText();
		if modname == "" then
			modname = AccountManager:getNickName()..GetS(4057);
		else
			if CheckFilterString(modname) then return end
		end

		local description = getglobal("TabSettingFrameModDescEdit"):GetText();
		if description == "" then
			description = GetS(178);
		end

		local roleHeadIndex = GetHeadIconIndex();

		if IsCreateNewMod then

			ModEditorMgr:requestCreateMod(modname, description, IconPath, ModEditable, ModLoadOnly, roleHeadIndex);
			IsCreateNewMod = false;
			local text = getglobal(this:GetName().."Font");
			Log("ModEditorSaveModBtn_OnClick "..this:GetName().."Font")
			getglobal("TabSettingFrameSaveModBtnFont"):SetText(GetS(3934));
			ShowGameTips(GetS(3984), 3);
			StatisticsTools:gameEvent("ModEvent", "创建Mod成功");

			--自动跳转到修改块的页面
			MyModsEditorType = 'block';
			
			--点击的块gallery
			getglobal("TabSettingFrame"):Hide();
			getglobal("BlockGalleryFrame"):Show();
			getglobal("EditorSlotBox"):Show();
			getglobal("ActorGalleryFrame"):Hide();

			for i=1, 8 do
				getglobal("ModEditorTab"..i.."Normal"):SetGray(false);

				if i == 1 then
					getglobal("ModEditorTab"..i.."Normal"):Show();
					getglobal("ModEditorTab"..i.."Checked"):Hide();
				end

				if i == 3 then
					getglobal("ModEditorTab"..i.."Normal"):Hide();
					getglobal("ModEditorTab"..i.."Checked"):Show();
				end
			end

			--getglobal(text):SetText(GetS(3934));
			--ModMgr:updateModList(true);
		else
			FrameStack.cur().haveModified = true;
			if ModEditorMgr:requestSaveModSetting(modname, description, IconPath, ModEditable, ModLoadOnly, roleHeadIndex) then
				ShowGameTips(GetS(3940));
				MyModsEditorFrameCloseBtn_OnClick();
			end
		end
	end
end

--左侧导航按钮
local m_mymods_editor_leftframeInfo = {
	{id = 1, bHide = true, nameID = 3929,},
	{id = 2, bHide = true, nameID = 3930,},
	{id = 3, bHide = false, nameID = 3931,},
	{id = 4, bHide = false, nameID = 3932,},
	{id = 5, bHide = false, nameID = 3933,},
	{id = 6, bHide = false, nameID = 1231,},
	{id = 7, bHide = false, nameID = 1230,},
	{id = 8, bHide = false, nameID = 11006,},
};

function MyModsEditorFrame_OnLoad()
	this:setUpdateTime(0.0001);  --update every frame

	--动态创建格子
	MyModsEditorFrame_CreateSlotUI();

	--标题栏
	UITemplateBaseFuncMgr:registerFunc("MyModsEditorFrameCloseBtn", MyModsEditorFrameCloseBtn_OnClick, "插件库关闭按钮");
	getglobal("MyModsEditorFrameTitleName"):SetText(GetS(3923));

	--帮助按钮
	UITemplateBaseFuncMgr:registerFunc("MyModsEditorFrameHelpBtn", MyModsEditorFrameHelpBtn_OnClick, "插件库帮助按钮");
	--帮助页面关闭按钮
	UITemplateBaseFuncMgr:registerFunc("MyModsEditorHelpFrameCloseBtn", MyModsEditorHelpFrameClose_OnClick, "插件库帮助页面关闭按钮");

	--左侧导航按钮
	TemplateTabBtn_Init("ModEditorTab", m_mymods_editor_leftframeInfo, "MyModsEditorFrameEditorTabs", "topleft", 22, false);
end

--动态创建格子
function MyModsEditorFrame_CreateSlotUI()
	local planeUI = "EditorSlotBoxPlane";
	local plane = getglobal(planeUI);
	local createCount = Max_Slot_Num; --256;
	local type_name ="Button";
	local template_name = "EditorSlotTemplate";
	local parent_name = "EditorSlotBox";

	for i = 1, createCount do
		local name = "EditorSlot" .. i;
		local slot = UIFrameMgr:CreateFrameByTemplate(type_name, name, template_name, parent_name);

		if slot then
			slot:Hide();
			slot:SetClientID(i - 1);	--从0开始
			
			local col = (i-1) % 8 + 1;					--第几列(第一行第一列是'新建按鈕', 故从2开始)-->创建按钮放最后.
			local row = math.ceil(i / 8);		--第几行

			slot:SetPoint("topleft", "EditorSlotBoxPlane", "topleft", (col - 1) * 130 + 17, (row - 1) * 161 + 17);
		end
	end
end

--界面隐藏的时候清理掉内容
function MyModsEditorFrame_OnHide()
	AnimMgr:stopAll();
	getglobal("TabSettingFrameEditableCheckerTick"):Hide();
	getglobal("TabSettingFrameLoadOnlyOneCheckerTick"):Hide();
	getglobal("TabSettingFrameModNameEdit"):SetText("");
	getglobal("TabSettingFrameModDescEdit"):SetText("");
	getglobal("TabSettingFrameModDescTip"):Show();
	--getglobal("TabSettingFrameModThumb"):SetTexture("ui/login_bg.png");
	ModLoadOnly = false;
	ModEditable = false;
	IconPath = "";

	SetArchiveDealMsg(true);
	getglobal("WorldRuleBox"):setDealMsg(true);
end

function _MyModsEditorFrame_Show()
	SetAllSlotTemplateDelState("hide");

	--插件库帮助引导
	--[[OLD
	if not AccountManager:getNoviceGuideState("guideeditorhelp") then
		getglobal("MyModsEditorFrameHelpBtnGuide"):Show();
	else
		getglobal("MyModsEditorFrameHelpBtnGuide"):Hide();
	end
	]]

	--刚刚添加的组件图标开始闪烁
	Log("MyModsEditorFrame_OnShow");

	if FrameStack.cur().blinkOnShow then
		Log("got blinkOnShow");

		local data = FrameStack.cur().blinkOnShow;

		FrameStack.cur().blinkOnShow = nil;
		
		MyModsEditorFrame_BlinkSlotsByIds(data.blockFileNames, data.actorFileNames, data.itemFileNames, data.plotFileNames);
	end

	SetArchiveDealMsg(false);
	getglobal("WorldRuleBox"):setDealMsg(false);
	getglobal("EditorSlotBox"):setDealMsg(true);
end

function MyModsEditorFrame_OnShow()
	--加载一个模型用来生成avatar头像
	local model = UIActorBodyManager:getAvatarHeadBody();
	model:setBodyType(3)
	model:addAvatarPartModel(2, 1)
	model:addAvatarPartModel(3, 4)
	model:addAvatarPartModel(4, 6)

	_MyModsEditorFrame_Show()

	--清理Avatar头像缓存信息
	if FrameStack.cur().isMapMod then 
		MyModsEditorFrameClearAvatarIconCache()
	end 
	--将索引定位到block
	MyModsEditorType = "block"

	--这里纯粹是为了拉取服务器下发数据
	if ResourceCenterNewVersionSwitch then
		local ctrl = GetInst("UIManager"):GetCtrl("ResourceCenter")
		if not ctrl then
			GetInst("UIManager"):Open("ResourceCenter",{ UpdateView=false })
			GetInst("UIManager"):Close("ResourceCenter")
		end
	end
end

function MyModsEditorFrame_ToShow()
	_MyModsEditorFrame_Show()
end

function MyModsEditorFrame_OnEnter()
	Log("MyModsEditorFrame_OnEnter");
	local args = FrameStack.cur();

	local uuid = args.uuid;

	local mod, moddesc;

	if args.isMapMod then
		mod = ModMgr:getMapModByUUID(uuid);
		moddesc = ModMgr:getMapModDescByUUID(uuid);
	else
		mod = ModMgr:findModFromLibrary(uuid);
		moddesc = ModMgr:getModDescByUUID(uuid);
	end

	if mod and moddesc then
		ModEditorMgr:requestEditMod(moddesc, mod);
		
		getglobal("MyModsEditorFrame"):Show();

		_OpenEditorToEditMod(moddesc);
	else
		if FrameStack.fromFrame then
			getglobal(FrameStack.fromFrame):Show();
		end

		ShowGameTips(GetS(3248), 3);
		return false;
	end
end

function MyModsEditorFrame_OnLeave()
	Log("MyModsEditorFrame_OnLeave");
	getglobal("MyModsEditorFrame"):Hide();
	ModEditorMgr:onleaveEditCurrentMod();
end

function MyModsEditorFrame_OnUpdate()
	--[[
	local deltatime = ClientMgr:frameDeltaTime();
	AnimMgr:update(deltatime);
	]]
end

function OpenEditorToCreateNewMod()
	Log("OpenEditorToCreateNewMod");
	getglobal("TabSettingFrameSaveModBtnFont"):SetText(GetS(3935));
	getglobal("ModThumbFrameLogo"):SetTexture("ui/mobile/texture2/bigtex/cjk_tydt02.png", true);

	local nickName = AccountManager:getNickName();
	local modNameEdit= getglobal("TabSettingFrameModNameEdit");
	local modDescEdit= getglobal("TabSettingFrameModDescEdit");
	----------StringBuilder-----
	modNameEdit:SetDefaultText(nickName..GetS(4057));

	IsCreateNewMod = true;

	for i=2, 8 do
		getglobal("ModEditorTab"..i.."Normal"):SetGray(true);
	end
	
	UpdateMyModsEditorFrame(1);  --默认打开设置界面

end

function _OpenEditorToEditMod(moddesc)
	IsCreateNewMod = false;
	getglobal("TabSettingFrameSaveModBtnFont"):SetText(GetS(3934));

	local args = FrameStack.cur();
	if args.tabindex then
		Log("_OpenEditorToEditMod args.tabindex:"..args.tabindex);
	end

	Current_Edit_Mode = args.editmode;
	Current_Edit_MapOwid = args.owid;
	args.componentCount = 0;
	args.modCount = 0;
	args.haveModified = false;
	args.CustomComponentCount = 0;

	ModEditable = moddesc.openedit;
	ModLoadOnly = moddesc.standalone;

	if moddesc.openedit then
		getglobal("TabSettingFrameEditableCheckerTick"):Show();
	else
		getglobal("TabSettingFrameEditableCheckerTick"):Hide();
	end

	if moddesc.standalone then
		getglobal("TabSettingFrameLoadOnlyOneCheckerTick"):Show();
	else
		getglobal("TabSettingFrameLoadOnlyOneCheckerTick"):Hide();
	end

	lastBlockPage = nil;
	lastActorPage = nil;
	lastItemPage = nil;
	lastPlotPage = nil;

	--Log("moddesc.name" ..moddesc.name);
	--Log(moddesc.standalone);
	--Log(moddesc.openedit);

	getglobal("TabSettingFrameModNameEdit"):SetText(moddesc.name);
	getglobal("TabSettingFrameModDescEdit"):SetText(moddesc.description);

 	local text = ReplaceFilterString(getglobal("TabSettingFrameModDescEdit"):GetText());
	if text == "" then
		getglobal("TabSettingFrameModDescTip"):Show(); 
	else
		getglobal("TabSettingFrameModDescTip"):Hide();
	end

	if ModEditorMgr:checkFileExist(moddesc.rootDir.."/icon.png") then
		getglobal("ModThumbFrameLogo"):SetTexture(moddesc.rootDir.."/icon.png", true);
	else
		getglobal("ModThumbFrameLogo"):SetTexture("ui/mobile/texture2/bigtex/cjk_tydt02.png", true);
	end

	for i=2, 8 do
		getglobal("ModEditorTab"..i.."Normal"):SetGray(false);
	end

	LeaveSelMode();

	local frameTitleText = "";
	local isMapMod = false;

	local newBtnMode = 1;
	local delBtnMode = 1;

	-- 1=插件编辑：普通插件(不是我的默认库也不是地图的默认库)的编辑界面
	-- 2=插件库：我的默认库的编辑界面
	-- 3=选择插件：地图的默认库 创建地图时弹出
	-- 4=本地图插件：地图的默认库-编辑界面，游戏中弹出
	-- 5=从库中添加：从我的默认库选择组件,复制到地图默认库中
	getglobal("MyModsEditorFrameShowMyModsBtn"):Hide();
	getglobal("MyModsEditorFrameSelectMapModsBtn"):Hide();
	getglobal("MyModsEditorFrameAddComponentBtn"):Hide();
	getglobal("MyModsEditorFrameConfirmAddBtn"):Hide();
	getglobal("MyModsEditorFrameMapModStateFrame"):Hide();
	getglobal("MyModsEditorFrameConfirmMapModsBtn"):Hide();
	getglobal("MyModsEditorFrameStartGameBtn"):Hide();
	getglobal("MyModsEditorFrameAddComponentTip"):Hide();
	if Current_Edit_Mode == 1 then
		frameTitleText = GetS(4063);
	elseif Current_Edit_Mode == 2 then
		frameTitleText = GetS(4064);
		getglobal("MyModsEditorFrameShowMyModsBtn"):Show();
	elseif Current_Edit_Mode == 3 then
		isMapMod = true;
		frameTitleText = GetS(4065);
		getglobal("MyModsEditorFrameSelectMapModsBtn"):Show();
		getglobal("MyModsEditorFrameMapModStateFrame"):Show();
		getglobal("MyModsEditorFrameConfirmMapModsBtn"):Show();
		newBtnMode = 0;
	elseif Current_Edit_Mode == 4 then
		isMapMod = true;
		frameTitleText = GetS(4066);
		getglobal("MyModsEditorFrameSelectMapModsBtn"):Show();
		getglobal("MyModsEditorFrameMapModStateFrame"):Show();
		getglobal("MyModsEditorFrameStartGameBtn"):Show();
		newBtnMode = 0;
	elseif Current_Edit_Mode == 5 then
		frameTitleText = GetS(4067);
		getglobal("MyModsEditorFrameConfirmAddBtn"):Show();
		getglobal("MyModsEditorFrameAddComponentTip"):Show();
		newBtnMode = 2;
		delBtnMode = 0;
		EnterSelMode('sel', args.seldata);
	end

	getglobal("BlockGalleryFrameNewBlockBtn"):Hide();
	getglobal("ActorGalleryFrameNewBlockBtn"):Hide();
	getglobal("ItemGalleryFrameNewBlockBtn"):Hide();

	if delBtnMode == 0 then
		getglobal("MyModsEditorFrameDelBtn"):Hide();
	else
		getglobal("MyModsEditorFrameDelBtn"):Show();
	end
	getglobal("MyModsEditorFrameCancelDelBtn"):Hide();
	getglobal("MyModsEditorFrameConfirmDelBtn"):Hide();

	if isMapMod then
		-- getglobal("MyModsEditorFrameTitleBkg2"):Show();
		-- getglobal("MyModsEditorFrameTitleBkg1"):Hide();
	else
		-- getglobal("MyModsEditorFrameTitleBkg1"):Show();
		-- getglobal("MyModsEditorFrameTitleBkg2"):Hide();
	end

	getglobal("MyModsEditorFrameTitleName"):SetText(frameTitleText);

	--
	-- 左侧ModEditorTab
	--
	local isinternal = moddesc.uuid == ModMgr:getUserDefaultModUUID()
						 or moddesc.uuid == ModMgr:getMapDefaultModUUID();
	if not isinternal then
		getglobal("ModEditorTab1"):Show();
	else
		getglobal("ModEditorTab1"):Hide();
	end

	if args.tabindex then
		UpdateMyModsEditorFrame(args.tabindex);  --打开指定的界面
	else
		if not isinternal then
			UpdateMyModsEditorFrame(1);  --默认打开设置界面
		else
			UpdateMyModsEditorFrame(3);  --默认打开方块界面
		end
	end

	--刷新左侧tab按钮布局
	TemplateTabBtn_UpdateLayout("ModEditorTab", m_mymods_editor_leftframeInfo, "MyModsEditorFrameEditorTabs", "topleft", 22);
end

function MyModsEditorFrame_BlinkSlotsByIds(blockFileNames, actorFileNames, itemFileNames, plotFileNames)
	Log("MyModsEditorFrame_BlinkSlotsByIds:");

	local duration = 0.3;
	local interval = 0.15;

	if FrameStack.cur().tabindex == 3 and blockFileNames then  --blocks
		
		local totalEntries = ModEditorMgr:getCustomBlockCount();
		for i=1, Max_Slot_Num do
			local slot = getglobal("EditorSlot"..i);
			local defindex = slot:GetClientID();
			if slot:IsShown() and defindex < totalEntries then
				local def = ModEditorMgr:getBlockDef(defindex);
				if def and blockFileNames[def.EnglishName] then
					AnimMgr:playBlink(slot:GetName().."Icon", duration, interval);
				end
			end
		end

	elseif FrameStack.cur().tabindex == 4 and actorFileNames then  --actors
		
		local totalEntries = ModEditorMgr:getCustomMonsterCount();
		for i=1, Max_Slot_Num do
			local slot = getglobal("EditorSlot"..i);
			local defindex = slot:GetClientID();
			if slot:IsShown() and defindex < totalEntries then
				local def = ModEditorMgr:getMonsterDef(defindex);
				if def and actorFileNames[def.EnglishName] then
					AnimMgr:playBlink(slot:GetName().."Icon", duration, interval);
				end
			end
		end

	elseif FrameStack.cur().tabindex == 5 and itemFileNames then  --items

		local totalEntries = ModEditorMgr:getCustomItemCount();
		for i=1, Max_Slot_Num do
			local slot = getglobal("EditorSlot"..i);
			local defindex = slot:GetClientID();
			if slot:IsShown() and defindex < totalEntries then
				local def = ModEditorMgr:getItemDef(defindex);
				if def and itemFileNames[def.EnglishName] then
					AnimMgr:playBlink(slot:GetName().."Icon", duration, interval);
				end
			end
		end

	elseif FrameStack.cur().tabindex == 8 and plotFileNames then  --items
		Log("blinkplot:");
		local totalEntries = ModEditorMgr:getCustomNpcPlotCount();
		Log("totalEntries = " .. totalEntries);
		for i=1, Max_Slot_Num do
			local slot = getglobal("EditorSlot"..i);
			local defindex = slot:GetClientID();
			if slot:IsShown() and defindex < totalEntries then
				Log("defindex = " .. defindex);
				local def = ModEditorMgr:getNpcPlotDef(defindex);
				if def and plotFileNames[def.EnglishName] then
					AnimMgr:playBlink(slot:GetName().."Icon", duration, interval);
				end
			end
		end
	end
end

function UpdateMapModStateFrame()
    local diff = (ModEditorMgr:getCustomBlockCount() > 0 and ModEditorMgr:getCustomBlockCount()) or 0
	FrameStack.cur().componentCount = ModEditorMgr:getCustomBlockCount() + ModEditorMgr:getCustomMonsterCount() + ModEditorMgr:getCustomItemCount() + ModEditorMgr:getCustomCraftingCount() + ModEditorMgr:getCustomFurnaceCount() + ModEditorMgr:getCustomNpcPlotCount();
	
	local modCount = 0;
	for i = 1, #MapLoadedMods do
		local uuid = MapLoadedMods[i];
		local moddesc = ModMgr:getModDescByUUID(uuid);
		if moddesc and uuid ~= ModMgr:getUserDefaultModUUID() and uuid ~= ModMgr:getMapDefaultModUUID() and moddesc.modtype == 0 then
			modCount = modCount + 1;
		end
	end

	FrameStack.cur().modCount = clamp(modCount, 0, nil);

	local totalActorCount =  ModEditorMgr:getCustomMonsterCount();
	local totalBlockCount =  ModEditorMgr:getCustomBlockCount();
	local totalItemCount = ModEditorMgr:getCustomItemCount();
	local CustomActorCount,CustomBlockCount,CustomItemCount=0,0,0


	for page=1,GetActorPageCount() do
		for i=1, Max_Slot_Num do
			local startIndex = Max_Slot_Num * (page - 1)
			if startIndex + i <= totalActorCount then
				local actorDef = ModEditorMgr:getMonsterDef(startIndex + i -1);
				if actorDef.CopyID > 0 then
					CustomActorCount=CustomActorCount+1
				end
			end
		end
	end

	for page=1,GetBlockPageCount() do
		for i=1, Max_Slot_Num do
			local startIndex = Max_Slot_Num * (page - 1)
			if startIndex + i <= totalBlockCount then
				local blockDef = ModEditorMgr:getBlockDef(startIndex + i -1);
				if blockDef.CopyID > 0 then
					CustomBlockCount=CustomBlockCount+1
				end
			end
		end
	end

	local t_Item = {}
	for i=1,totalItemCount do
		local def = ModEditorMgr:getItemDef(i-1);
		if def and def.Type ~= ITEM_TYPE_BLOCK then
		    table.insert(t_Item, def)
		end
	end
	totalItemCount = #(t_Item)
	for page=1,GetItemPageCount() do
		for i=1, Max_Slot_Num do
			local startIndex = Max_Slot_Num * (page - 1)
			if startIndex + i <= totalItemCount then
			    local itemDef = t_Item[startIndex + i];
			    if itemDef.CopyID>0 then
			    	CustomItemCount=CustomItemCount+1
			    end
			end
		end
	end

	Log("01"..tostring(CustomActorCount).."02"..tostring(CustomBlockCount).."03"..tostring(CustomItemCount))

	FrameStack.cur().CustomComponentCount=CustomItemCount+CustomBlockCount+CustomActorCount

	local text = GetS(4096, tostring(FrameStack.cur().componentCount),tostring(FrameStack.cur().modCount));
	getglobal("MyModsEditorFrameMapModStateFrameLine1"):SetText(text);
end

function MyModsEditorFrameSelectMapModsBtn_OnClick()
	FrameStack.enterNewFrame("ChooseModsFrame", {mode=Current_Edit_Mode}, MyModsEditorFrame_OnMapModsSelected);
end

function updateMapModCount(owid)
	if ModMgr:getMapModCount() ~= 0 and not ClientCurGame:isInGame() then
		ModMgr:unLoadCurMods(owid);
		if ModEditorMgr:ensureMapHasDefualtMod(owid) then
			if ModMgr:loadWorldMods(owid) then
			end
		end
	end
end
function MyModsEditorFrame_OnMapModsSelected(leavingframe, userdata)

	Log("MyModsEditorFrame_OnMapModsSelected owid="..tostring(Current_Edit_MapOwid));

	if Current_Edit_Mode == 3 then

	elseif Current_Edit_Mode == 4 then

		if Current_Edit_MapOwid then
			updateMapModCount(Current_Edit_MapOwid);--刷新一下c++缓存拿到的ModMgr:getMapModCount()比较准确
			local selectedModUuids = leavingframe.selectedModUuids;

			for i = 1, ModMgr:getMapModCount() do
				local alreadyDeldte = true;
				local deletemoddesc = ModMgr:getMapModDescByIndex(i-1);
				for j = 1, #selectedModUuids do
					if deletemoddesc.uuid == selectedModUuids[j] then
						alreadyDeldte = false;
						break;
					end
				end
				if alreadyDeldte then --delete mod from map
					ModMgr:requestDeleteModByPath(deletemoddesc.rootDir);
				end
			end
			for i = 1, #selectedModUuids do
				local uuid = selectedModUuids[i];
				local moddesc_inlib = ModMgr:getModDescByUUID(uuid);

				Log(" for "..uuid);

				local alreadyAdded = false;

				for j = 1, ModMgr:getMapModCount() do
					local moddesc = ModMgr:getMapModDescByIndex(j-1);
					if moddesc.uuid == uuid then
						alreadyAdded = true;
						break;
					end
				end

				if not alreadyAdded then --add new mod to map
					Log(" adding...");
					ModMgr:copyModFromLibraryToWorld(uuid, Current_Edit_MapOwid);
				end
			end

			for i,uuid in ipairs(selectedModUuids) do
				-- statisticsGameEvent(506, '%lls', uuid, '%d', Current_Edit_Mode);
			end
		end
	end
end

function MyModsEditorFrameAddComponentBtn_OnClick()
	Log("MyModsEditorFrameAddComponentBtn_OnClick MyModsEditorType:"..MyModsEditorType);
	local curmoduuid = ModEditorMgr:getCurrentEditModUuid();

	local seldata = {
		selectedBlockFileNames = {},
		selectedActorFileNames = {},
		selectedItemFileNames = {},
		selectedCraftFileNames = {},
		selectedFurnaceFileNames = {},
		disabledBlockFileNames = {},
		disabledActorFileNames = {},
		disabledItemFileNames = {},
		disabledCraftFileNames = {},
		disabledFurnaceFileNames = {},

		disabledPlotFileNames = {},
		selectedPlotFileNames = {},

		disabledTaskFileNames = {},
		selectedTaskFileNames = {},

		disabledStoreFileNames = {},
		selectedStoreFileNames = {},
	};

	for i = 1, ModEditorMgr:getCustomBlockCount() do
		local def = ModEditorMgr:getBlockDef(i-1);
		seldata.disabledBlockFileNames[def.EnglishName] = def.ID;
	end
	for i = 1, ModEditorMgr:getCustomMonsterCount() do
		local def = ModEditorMgr:getMonsterDef(i-1);
		seldata.disabledActorFileNames[def.EnglishName] = def.ID;
	end
	for i = 1, ModEditorMgr:getCustomItemCount() do
		local def = ModEditorMgr:getItemDef(i-1);
		seldata.disabledItemFileNames[def.EnglishName] = def.ID;
	end
	for i = 1, ModEditorMgr:getCustomCraftingCount() do
		local def = ModEditorMgr:getCraftingDef(i-1);
		seldata.disabledCraftFileNames[def.EnglishName] = def.ID;
	end
	for i = 1, ModEditorMgr:getCustomFurnaceCount() do
		local def = ModEditorMgr:getFurnaceDef(i-1);
		seldata.disabledFurnaceFileNames[def.EnglishName] = def.ID;
	end
	for i = 1, ModEditorMgr:getCustomNpcPlotCount() do
		local def = ModEditorMgr:getNpcPlotDef(i-1);
		seldata.disabledPlotFileNames[def.EnglishName] = def.ID;
	end

	for i=1,ModEditorMgr:getCustomNpcShopCount() do
		local def = ModEditorMgr:getNpcShopDef(i-1)
		seldata.disabledStoreFileNames[def.EnglishName] = def.ID;
	end

	Log("seldata.disabledPlotFileNames:");

	local tabindexMapping = {
		setting = 1,
		block = 3,
		actor = 4,
		item = 5,
		craft = 6,
		furnace = 7,
		plot = 8,
	};

	local args = {
		editmode = 5,
		uuid = ModMgr:getUserDefaultModUUID(),
		isMapMod = false,
		tabindex = tabindexMapping[MyModsEditorType],
		seldata = seldata,
	};
	FrameStack.enterNewFrame("MyModsEditorFrame", args);
end

function MyModsEditorFrameClearAvatarIconCache()
	--清除掉上次地图插件avtar头像的缓存信息
	for i = 1,Current_Page_Index do  
		for j = 1, Max_Slot_Num do
			local index = j + (i - 1) * Max_Slot_Num
			local saveId = "a" .. index
			UIActorBodyManager:releaseAvatarIconBySaveId(saveId)
		end
	end
end

function MyModsEditorFrameConfirmAddBtn_OnClick()
	Log("ConfirmAdd");

	local seldata = FrameStack.cur().CurrentSel;
	LeaveSelMode();

	local lastEditorInfo = FrameStack.findLastFrameBefore("MyModsEditorFrame", FrameStack.cur());
	if lastEditorInfo then

		local srcmod = ModEditorMgr:getCurrentEditMod();
		local srcmoddesc = ModEditorMgr:getCurrentEditModDesc();

		Log("srcmoduuid = "..srcmoddesc.uuid);

		local uuid = lastEditorInfo.uuid;

		local dstmoddesc;
		if lastEditorInfo.isMapMod then
			dstmoddesc = ModMgr:getMapModDescByUUID(uuid);
			Log("dstmoduuid = "..dstmoddesc.uuid.." (map mod)");
		else
			dstmoddesc = ModMgr:getModDescByUUID(uuid);
			Log("dstmoduuid = "..dstmoddesc.uuid);
		end

		local selBlocks = 0;
		local selActors = 0;
		local selItems = 0;
		local selCrafts = 0;
		local selFurnaces = 0;

		for fileName,t in pairs(seldata.selectedBlockFileNames) do
			selBlocks = selBlocks + 1;
			ModEditorMgr:copyBlock(fileName, srcmoddesc, srcmod, dstmoddesc);
			
			if t.modelfilename and lastEditorInfo.owid then --微雕文件
				if t.modeltype and t.modeltype == FULLY_BLOCK_MODEL then
					FullyCustomModelMgr:copyModelFileByMod(lastEditorInfo.owid, t.modelfilename)
				elseif t.modeltype and t.modeltype == IMPORT_BLOCK_MODEL then
					ImportCustomModelMgr:copyModelFileByMod(lastEditorInfo.owid, t.modelfilename)
				else
					CustomModelMgr:copyModelFileByMod(lastEditorInfo.owid, t.modelfilename)
				end
			end
		end

		MyModsEditorFrameClearAvatarIconCache()

		for fileName,t in pairs(seldata.selectedActorFileNames) do
			selActors = selActors + 1;
			ModEditorMgr:copyActor(fileName, srcmoddesc, srcmod, dstmoddesc);

			if t.modelfilename and lastEditorInfo.owid then --微雕文件
				if t.modeltype and t.modeltype == MONSTER_FULLY_CUSTOM_MODEL then
					FullyCustomModelMgr:copyModelFileByMod(lastEditorInfo.owid, t.modelfilename)
				elseif t.modeltype and t.modeltype == MONSTER_IMPORT_MODEL then
					ImportCustomModelMgr:copyModelFileByMod(lastEditorInfo.owid, t.modelfilename)
				else
					CustomModelMgr:copyModelFileByMod(lastEditorInfo.owid, t.modelfilename, true)
				end
			end
		end
		for fileName,t in pairs(seldata.selectedItemFileNames) do
			selItems = selItems + 1;
			ModEditorMgr:copyItem(fileName, srcmoddesc, srcmod, dstmoddesc);
			--复制物理材质
			local PhysxMatID;
			if t.id > 0 then
				local PhysicsActorDef = PhysicsActorCsv:get(t.id);
				if PhysicsActorDef then
					PhysxMatID = PhysicsActorDef.MaterialID;
					ModEditorMgr:copyPhyMaterial(PhysxMatID,srcmoddesc,srcmod,dstmoddesc);
				end
			end
			--微雕文件
			if t.modelfilename then --微雕文件
			   --- print("copyModelFileByMod:",lastEditorInfo,lastEditorInfo.owid)
				if lastEditorInfo.owid then 
					if t.modeltype and t.modeltype == FULLY_ITEM_MODEL then
						FullyCustomModelMgr:copyModelFileByMod(lastEditorInfo.owid, t.modelfilename)
					elseif t.modeltype and t.modeltype == IMPORT_ITEM_MODEL then
						ImportCustomModelMgr:copyModelFileByMod(lastEditorInfo.owid, t.modelfilename)
					else
						CustomModelMgr:copyModelFileByMod(lastEditorInfo.owid, t.modelfilename)
					end
				end
			end
		end
		for fileName,_ in pairs(seldata.selectedCraftFileNames) do
			selCrafts = selCrafts + 1;
			ModEditorMgr:copyCrafting(fileName, srcmoddesc, srcmod, dstmoddesc);
		end
		for fileName,_ in pairs(seldata.selectedFurnaceFileNames) do
			selFurnaces = selFurnaces + 1;
			ModEditorMgr:copyFurnace(fileName, srcmoddesc, srcmod, dstmoddesc);
		end

		--从插件库添加剧情插件到游戏存档
		local selPlots = 0;
		Log("copyPlot:");
		for fileName,_ in pairs(seldata.selectedPlotFileNames) do
			Log("fileName = " .. fileName);
			selPlots = selPlots + 1;
			ModEditorMgr:copyPlot(fileName, srcmoddesc, srcmod, dstmoddesc);
		end

		for fileName,_ in pairs(seldata.selectedTaskFileNames) do
			ModEditorMgr:copyTask(fileName, srcmoddesc, srcmod, dstmoddesc);
		end

		--npc商店
		for fileName,_ in pairs(seldata.selectedStoreFileNames ) do
			ModEditorMgr:copyShop(fileName, srcmoddesc, srcmod, dstmoddesc);
		end

		Log("ConfirmAdd succeed");
print("MyModsEditorFrameConfirmAddBtn_OnClick", selBlocks, selActors, selItems)
		ShowGameTips(GetS(4079), 3);

		local editmode = lastEditorInfo.editmode;
		-- if selBlocks > 0 then
		-- 	statisticsGameEvent(505, '%s', 'block', '%d', editmode, '%d', selBlocks);
		-- end
		-- if selActors > 0 then
		-- 	statisticsGameEvent(505, '%s', 'actor', '%d', editmode, '%d', selActors);
		-- end
		-- if selItems > 0 then
		-- 	statisticsGameEvent(505, '%s', 'item', '%d', editmode, '%d', selItems);
		-- end
		-- if selCrafts > 0 then
		-- 	statisticsGameEvent(505, '%s', 'craft', '%d', editmode, '%d', selCrafts);
		-- end
		-- if selFurnaces > 0 then
		-- 	statisticsGameEvent(505, '%s', 'furnace', '%d', editmode, '%d', selFurnaces);
		-- end
		-- if selPlots > 0 then
		-- 	statisticsGameEvent(505, '%s', 'plot', '%d', editmode, '%d', selPlots);
		-- end

		--要返回的编辑界面的标签，设成跟当前标签一样
		lastEditorInfo.tabindex = FrameStack.cur().tabindex;
		lastEditorInfo.blinkOnShow = {
			blockFileNames = seldata.selectedBlockFileNames,
			actorFileNames = seldata.selectedActorFileNames,
			itemFileNames = seldata.selectedItemFileNames,
			craftFileNames = seldata.selectedCraftFileNames,
			furnaceFileNames = seldata.selectedFurnaceFileNames,
		};
		lastEditorInfo.haveModified = true;
	else
		Log("error lastEditorInfo not found");
	end

	FrameStack.goBack();
end

function MyModsEditorFrameConfirmMapModsBtn_OnClick()
	if FrameStack.cur().CustomComponentCount > Max_CustomComponent_Num then
		ShowGameTips(GetS(6584))
		Log("CustomComponentCount out of limit:"..tostring(FrameStack.cur().CustomComponentCount))
		return;
	end

	FrameStack.goBack();
end

function MyModsEditorFrameStartGameBtn_OnClick()
	if FrameStack.cur().CustomComponentCount > Max_CustomComponent_Num then
		ShowGameTips(GetS(6584))
		Log("CustomComponentCount out of limit:"..tostring(FrameStack.cur().CustomComponentCount))
		return;
	end

	if ClientCurGame:isInGame() then
		-- ShowGameTips(GetS(1204), 3);
		MyModsEditorFrameCloseBtn_OnClick();
		EnterMainMenuInfo.ReLoadGame = {}
		EnterMainMenuInfo.ReLoadGame.owid = CurWorld:getOWID()
		HideUI2GoMainMenu();
		ClientMgr:gotoGame("MainMenuStage");
		return;
	end
	local owid = FrameStack.cur().owid;
	print("MyModsEditorFrameStartGameBtn_OnClick", FrameStack.cur())
	local mapIsBreakLaw = BreakLawMapControl:VerifyMapID(owid);
	if mapIsBreakLaw == 1 then
		ShowGameTips(GetS(3632), 3);
		return;
	elseif mapIsBreakLaw == 2 then
		ShowGameTips(GetS(10561), 3);
		return;
	end

	FrameStack.goBack();

	Log("Enter game: owid = "..tostring(owid));
	RequestEnterWorld(owid, false, function(succeed)
		if succeed then
			HideLobby();	
			ShowLoadingFrame();
		end
	end);
end

function MyModsEditorFrameHelpBtn_OnClick()
	local helpText = "";
	if Current_Edit_Mode == 1 then
		helpText = GetS(4068);
	elseif Current_Edit_Mode == 2 then
		helpText = GetS(4069);
	elseif Current_Edit_Mode == 3 then
		helpText = GetS(4070);
	elseif Current_Edit_Mode == 4 then
		helpText = GetS(4071);
	elseif Current_Edit_Mode == 5 then
		helpText = GetS(4072);
	end

	getglobal("MyModsEditorHelpFrameTitleName"):SetText(GetS(3983));

	getglobal("MyModsEditorHelpFrameBoxContent"):SetText(helpText, 61, 69, 70);
	getglobal("MyModsEditorHelpFrame"):Show();
	if not AccountManager:getNoviceGuideState("guideeditorhelp") then
		AccountManager:setNoviceGuideState("guideeditorhelp", true);
		-- getglobal("MyModsEditorFrameHelpBtnGuide"):Hide();	--OLD
	end
end

function MyModsEditorFrameHelpBtnGuide_OnClick()
	AccountManager:setNoviceGuideState("guideeditorhelp", true);
	-- getglobal("MyModsEditorFrameHelpBtnGuide"):Hide();	--OLD
end
----------------------------------------------MyModsEditorHelpFrame--------------------------------------

function MyModsEditorHelpFrame_OnLoad()
	getglobal("MyModsEditorHelpFrameBoxContent"):SetText(GetS(3981), 61, 69, 70);
end

function MyModsEditorHelpFrame_OnShow()
	SetModBoxsDeals(false);
end


function MyModsEditorHelpFrame_OnHide()
end

function MyModsEditorHelpFrameClose_OnClick()
	SetModBoxsDeals(true);
	getglobal("MyModsEditorHelpFrame"):Hide();
end

function SetModBoxsDeals(isDeal)
	if getglobal("NewSingleEditorFrame"):IsShown() then
		getglobal("NewSingleEditBox"):setDealMsg(isDeal);
	elseif getglobal("SingleEditorFrame"):IsShown() then
		getglobal("SingleEditorAttrBox"):setDealMsg(isDeal);
	else
		if getglobal("EditorSlotBox") then
			getglobal("EditorSlotBox"):setDealMsg(isDeal);
		end
	end

end

------------------------------------------------MyModsEditorFramePageFrame-----------------------------------
function UpdateEditorTypeByPkg(tabIndex)
	if tabIndex == 2 then		
		MyModsEditorType = 'block'
	elseif tabIndex == 3 then 	
		MyModsEditorType = 'actor'
	elseif tabIndex == 4 then	
		MyModsEditorType = "item"
	elseif tabIndex == 5 then	
		MyModsEditorType = "craft"
	elseif tabIndex == 6 then	
		MyModsEditorType = "furnace"
	elseif tabIndex == 7 then
		MyModsEditorType = "plot"
	end
end

function UpdateEditorSomeFrameStatus(tabindex)
	Log("UpdateEditorSomeFrameStatus "..tabindex);

	if FrameStack and FrameStack.cur and FrameStack.cur() and FrameStack.cur().tabindex ~= tabindex then
		AnimMgr:stopAll();
		FrameStack.cur().tabindex = tabindex;
	end

	if tabindex== 1 then
		MyModsEditorType = 'setting';

		getglobal("EditorSlotBox"):Hide();
		getglobal("MyModsEditorFrameBkgTips"):Hide();
	elseif tabindex== 3 then		--点击的块gallery
		MyModsEditorType = 'block';

		getglobal("EditorSlotBox"):Show();
	elseif tabindex == 4 then 	--点击的Actor gallery
		MyModsEditorType = 'actor';

		getglobal("EditorSlotBox"):Show();
	elseif tabindex == 5 then	--点击的道具 gallery
		MyModsEditorType = "item";

		getglobal("EditorSlotBox"):Show();
	elseif tabindex == 6 then	--点击的配方 gallery
		MyModsEditorType = "craft";

		getglobal("EditorSlotBox"):Show();
	elseif tabindex == 7 then	--点击的熔炼 gallery
		MyModsEditorType = "furnace";

		getglobal("EditorSlotBox"):Show();
	elseif tabindex == 8 then	--点击的剧情
		MyModsEditorType = "plot";
		getglobal("EditorSlotBox"):Show();
		-- statisticsGameEvent(40100, '%d', 1);
	end

	local t_FrameName = {"TabSettingFrame", "", "BlockGalleryFrame", "ActorGalleryFrame", "ItemGalleryFrame", "CraftGalleryFrame", "FurnaceGalleryFrame", "PlotEditFrame"}
	for i=1, #(t_FrameName) do
		if HasUIFrame(t_FrameName[i]) then
			if i == tabindex then
				print("UpdateEditorSomeFrameStatus ", t_FrameName[i])
				getglobal(t_FrameName[i]):Show();
			else
				getglobal(t_FrameName[i]):Hide();
			end
		end
	end
end

function Interact_SetModEditorType()
	MyModsEditorType = "plot";
end

function SetMyModsEditorType(sType)
	MyModsEditorType = sType;
end

function EnterSelMode(mode, seldata)
	FrameStack.cur().CurrentSelMode = mode;

	seldata = seldata or {};
	seldata.selectedBlockFileNames = seldata.selectedBlockFileNames or {};
	seldata.selectedActorFileNames = seldata.selectedActorFileNames or {};
	seldata.selectedItemFileNames = seldata.selectedItemFileNames or {};
	seldata.selectedCraftFileNames = seldata.selectedCraftFileNames or {};
	seldata.selectedFurnaceFileNames = seldata.selectedFurnaceFileNames or {};
	seldata.disabledBlockFileNames = seldata.disabledBlockFileNames or {};
	seldata.disabledActorFileNames = seldata.disabledActorFileNames or {};
	seldata.disabledItemFileNames = seldata.disabledItemFileNames or {};
	seldata.disabledCraftFileNames = seldata.disabledCraftFileNames or {};
	seldata.disabledFurnaceFileNames = seldata.disabledFurnaceFileNames or {};

	seldata.disabledPlotFileNames = seldata.disabledPlotFileNames or {};
	seldata.selectedPlotFileNames = seldata.selectedPlotFileNames or {};

	seldata.disabledTaskFileNames = seldata.disabledTaskFileNames or {};
	seldata.selectedTaskFileNames = seldata.selectedTaskFileNames or {};

	seldata.disabledStoreFileNames  = seldata.disabledStoreFileNames  or {};
	seldata.selectedStoreFileNames  = seldata.selectedStoreFileNames  or {};

	FrameStack.cur().CurrentSel = seldata;

	if not UseNewModsLib then
		UpdateEditorSlot();
	end
end
function LeaveSelMode()
	FrameStack.cur().CurrentSelMode = nil;
	FrameStack.cur().CurrentSel = {
		selectedBlockFileNames = {},
		selectedActorFileNames = {},
		selectedItemFileNames = {},
		selectedCraftFileNames = {},
		selectedFurnaceFileNames = {},
		disabledBlockFileNames = {},
		disabledActorFileNames = {},
		disabledItemFileNames = {},
		disabledCraftFileNames = {},
		disabledFurnaceFileNames = {},

		selectedPlotFileNames = {},
		disabledPlotFileNames = {},
		selectedTaskFileNames = {},
		disabledTaskFileNames = {},

		disabledStoreFileNames = {},
		selectedStoreFileNames = {},
	};
	if not UseNewModsLib then
		UpdateEditorSlot();
	end
end

function UpdateSlotSelBtn(slotname, fileName, selectedFileNames, disabledFileNames)	
	Log("UpdateSlotSelBtn:");
	Log("fileName = " .. fileName);
	if FrameStack.cur().CurrentSelMode~=nil then
		local slotbtn = getglobal(slotname.."SelBtn");
		local normal = getglobal(slotname.."SelBtnNormal");
		local pushed = getglobal(slotname.."SelBtnPushedBG");

		normal:SetGray(false);
		pushed:SetGray(false);

		if disabledFileNames and disabledFileNames[fileName] then
			--灰色勾, 已有的
			slotbtn:Show();
			slotbtn:Disable();
			
			normal:SetTexUV("btn_circle_yellow_tick");
			pushed:SetTexUV("btn_circle_yellow_tick");
			normal:SetGray(true);
			pushed:SetGray(true);
		elseif selectedFileNames and selectedFileNames[fileName] then
			--蓝色勾, 当前选中的
			slotbtn:Show();
			slotbtn:Enable();
			normal:SetTexUV("btn_circle_yellow_tick");
			pushed:SetTexUV("btn_circle_yellow_tick");
		else
			--待定状态, 无勾
			slotbtn:Show();
			slotbtn:Enable();
			normal:SetTexUV("btn_circle_yellow");
			pushed:SetTexUV("btn_circle_yellow");
		end
	else
		getglobal(slotname.."SelBtn"):Hide();
	end
end

function UpdateBlockSlot(slot, blockdef)
	local slotname = slot:GetName();
	if blockdef then
		if blockdef.CopyID > 0 then
			getglobal(slotname.."Checked"):Show();
		else
			getglobal(slotname.."Checked"):Hide();
		end
		
		local def = BlockDefCsv:get(blockdef.ID, false);
		local def_item = ModEditorMgr:getBlockItemDefById(blockdef.ID)
		local name, id
		
		if def_item then
			name = def_item.Name
			id = def_item.ID
		elseif def then
			name = def.Name
			id = def.ID
		end
		
		if id then
			getglobal(slotname.."Name"):SetText(name);
			SetItemIcon(getglobal(slotname.."Icon"), id);
		else	--DefMgr找不到 说明是新增的东东 用默认的icon
			getglobal(slotname.."Icon"):SetTexture("items/netherbrick.png", true);
		end

		UpdateSlotSelBtn(slotname, blockdef.EnglishName, FrameStack.cur().CurrentSel.selectedBlockFileNames, FrameStack.cur().CurrentSel.disabledBlockFileNames);
	end
end

function UpdateActorSlot(slot, actorDef)
	local slotname = slot:GetName();
	if actorDef then
		getglobal(slotname.."Name"):SetText(actorDef.Name);
		local icon = getglobal(slotname.."Icon");
		if tonumber(actorDef.ModelType) == 3 then
			--如果是Avatar定制模型，取图片的方式不一样
			local model = string.sub(actorDef.Model,2,string.len(actorDef.Model))
			local args = FrameStack.cur()
			if args.isMapMod then 
				AvatarSetIconByID(actorDef,icon)
			else
				AvatarSetIconByIDEx(model,icon)
			end 
		elseif tonumber(actorDef.ModelType) == MONSTER_CUSTOM_MODEL then
			SetModelIcon(icon, actorDef.Model, ACTOR_MODEL);
		elseif tonumber(actorDef.ModelType) == MONSTER_FULLY_CUSTOM_MODEL then
			SetModelIcon(icon, actorDef.Model, FULLY_ACTOR_MODEL);
		elseif tonumber(actorDef.ModelType) == MONSTER_IMPORT_MODEL then
			SetModelIcon(icon, actorDef.Model, IMPORT_ACTOR_MODEL);
		else
			SetActorIcon(icon, actorDef.ID);
		end
		if actorDef.CopyID > 0 then
			getglobal(slotname.."Checked"):Show();
		else
			getglobal(slotname.."Checked"):Hide();
		end
		--[[
		local def = MonsterCsv:get(actorDef.ID);
		if def then
			getglobal(slotname.."Icon"):SetTexture("ui/roleicons/"..actorDef.ID..".png", true);
		else	--DefMgr找不到 说明是新增的东东 用默认的icon
			getglobal(slotname.."Icon"):SetTexture("ui/roleicons/109.png", true);
		end
		]]
		UpdateSlotSelBtn(slotname, actorDef.EnglishName, FrameStack.cur().CurrentSel.selectedActorFileNames, FrameStack.cur().CurrentSel.disabledActorFileNames);
	end
end

function UpdateItemSlot(slot, itemDef)
	local slotname = slot:GetName();
	if itemDef then
		getglobal(slotname.."Name"):SetText(itemDef.Name);
		if itemDef.CopyID > 0 then
			getglobal(slotname.."Checked"):Show();
		else
			getglobal(slotname.."Checked"):Hide();
		end
		if itemDef then
		   --- print("UpdateItemSlot slotname:",slotname)
			SetItemIcon(getglobal(slotname.."Icon"), itemDef.ID);
			---print("UpdateItemSlot:",itemDef.ID)
		else	--DefMgr找不到 说明是新增的东东 用默认的icon
			getglobal(slotname.."Icon"):SetTexture("items/netherbrick.png", true);
			---print("UpdateItemSlot:default")
		end

		UpdateSlotSelBtn(slotname, itemDef.EnglishName, FrameStack.cur().CurrentSel.selectedItemFileNames, FrameStack.cur().CurrentSel.disabledItemFileNames);
	end
end

function UpdateCraftSlot(slot, craftDef)
	local slotname = slot:GetName();
	if craftDef then
		local itemDef = ModEditorMgr:getItemDefById(craftDef.ResultID);
		if not itemDef then
			itemDef = ItemDefCsv:get(craftDef.ResultID);
		end
		if itemDef then
			getglobal(slotname.."Name"):SetText(itemDef.Name);
		end

		if craftDef.CopyID > 0 then
			getglobal(slotname.."Checked"):Show();
		else
			getglobal(slotname.."Checked"):Hide();
		end

		if itemDef then
			SetItemIcon(getglobal(slotname.."Icon"), itemDef.ID);
		else	--DefMgr找不到 说明是新增的东东 用默认的icon
			getglobal(slotname.."Icon"):SetTexture("items/netherbrick.png", true);
		end

		UpdateSlotSelBtn(slotname, craftDef.EnglishName, FrameStack.cur().CurrentSel.selectedCraftFileNames, FrameStack.cur().CurrentSel.disabledCraftFileNames);
	end
end

function UpdatePlotSlot(slot, plotDef)
	Log("UpdatePlotSlot:");
	local slotname = slot:GetName();
	if plotDef then
		if plotDef then
			getglobal(slotname.."Name"):SetText(plotDef.Name);
		end

		if plotDef.CopyID > 0 then
			getglobal(slotname.."Checked"):Show();
		else
			getglobal(slotname.."Checked"):Hide();
		end

		if plotDef then
			--图标暂时用200代替
			NpcPlot_SetPlotIcon(getglobal(slotname.."Icon"), plotDef.Icon);
		else	--DefMgr找不到 说明是新增的东东 用默认的icon
			getglobal(slotname.."Icon"):SetTexture("items/netherbrick.png", true);
		end

		UpdateSlotSelBtn(slotname, plotDef.EnglishName, FrameStack.cur().CurrentSel.selectedPlotFileNames, FrameStack.cur().CurrentSel.disabledPlotFileNames);
	end
end

function UpdateFurnaceSlot(slot, furnaceDef)
	local slotname = slot:GetName();
	if furnaceDef then
		local itemDef = ModEditorMgr:getItemDefById(furnaceDef.MaterialID);
		if not itemDef then
			itemDef = ItemDefCsv:get(furnaceDef.MaterialID);
		end
		if itemDef then
			getglobal(slotname.."Name"):SetText(itemDef.Name);
		end

		if furnaceDef.CopyID > 0 then
			getglobal(slotname.."Checked"):Show();
		else
			getglobal(slotname.."Checked"):Hide();
		end

		if itemDef then
			SetItemIcon(getglobal(slotname.."Icon"), itemDef.ID);
		else	--DefMgr找不到 说明是新增的东东 用默认的icon
			getglobal(slotname.."Icon"):SetTexture("items/netherbrick.png", true);
		end

		UpdateSlotSelBtn(slotname, furnaceDef.EnglishName, FrameStack.cur().CurrentSel.selectedFurnaceFileNames, FrameStack.cur().CurrentSel.disabledFurnaceFileNames);
	end
end

function UpdateNPCPlotSlot(slot, plotDef)
	Log("UpdateNPCPlotSlot:");
	local slotname = slot:GetName();
	if plotDef then
		-- local def = ModEditorMgr:getNpcPlotDefById(plotDef.ID);
		-- if not def then
		-- 	def = DefMgr:getNpcPlotDef(plotDef.ID);
		-- end
		local def = plotDef;
		if def then
			getglobal(slotname.."Name"):SetText(def.Name);
		end

		if plotDef.CopyID > 0 then
			getglobal(slotname.."Checked"):Show();
		else
			getglobal(slotname.."Checked"):Hide();
		end

		if def then
			--LLTODO:图标待定, 暂时用200代替
			NpcPlot_SetPlotIcon(getglobal(slotname.."Icon"), def.Icon);
		else	--DefMgr找不到 说明是新增的东东 用默认的icon
			getglobal(slotname.."Icon"):SetTexture("items/netherbrick.png", true);
		end

		UpdateSlotSelBtn(slotname, plotDef.EnglishName, FrameStack.cur().CurrentSel.selectedPlotFileNames, FrameStack.cur().CurrentSel.disabledPlotFileNames);
	end
end

------------------------------------------------EditorSlotTemplate-------------------------------------

function EditorSlotTemplateSelBtn_OnClick()
	local index = this:GetParentFrame():GetClientID();

	local seldata = FrameStack.cur().CurrentSel;

	if MyModsEditorType == "block" then
		local def = ModEditorMgr:getBlockDef(index);
		if def then
			local id = def.ID;
			if seldata.disabledBlockFileNames[def.EnglishName] or seldata.selectedBlockFileNames[def.EnglishName] then
				seldata.selectedBlockFileNames[def.EnglishName] = nil;
			else
				if tonumber(def.Texture2) then
					local modelType = BLOCK_MODEL;
					if def.Type == "fullycustomblock" then
						modelType = FULLY_BLOCK_MODEL;
					elseif def.Type == "importmodel" then
						modelType = IMPORT_BLOCK_MODEL;
					end
					seldata.selectedBlockFileNames[def.EnglishName] = {id = id, modelfilename=def.Texture2, modeltype = modelType};
				else
					seldata.selectedBlockFileNames[def.EnglishName] = {id = id};
				end
			end
			UpdateBlockSlot(this:GetParentFrame(), def);
		end

	elseif MyModsEditorType == "actor" then
		local def = ModEditorMgr:getMonsterDef(index);

		if def then
			local id = def.ID;
			if seldata.disabledActorFileNames[def.EnglishName] or seldata.selectedActorFileNames[def.EnglishName] then
				seldata.selectedActorFileNames[def.EnglishName] = nil;
			else
				if def.ModelType == MONSTER_CUSTOM_MODEL or def.ModelType == MONSTER_FULLY_CUSTOM_MODEL or def.ModelType == MONSTER_IMPORT_MODEL then --生物微雕
					seldata.selectedActorFileNames[def.EnglishName] = {id = id, modelfilename=def.Model, modeltype=def.ModelType};
				else
					seldata.selectedActorFileNames[def.EnglishName] = {id = id};
				end
				-- FrameStack.cur().CurrentSel.selectedTaskFileNames = {};

				AddSelStoreBySelActor(id)
			end
			
			UpdateActorSlot(this:GetParentFrame(), def);
		end

	elseif MyModsEditorType == 'item' then
        -- 过滤item中的方块
        local items = {}
        for i=1, ModEditorMgr:getCustomItemCount() do
            local def = ModEditorMgr:getItemDef(i-1);
            if def and def.Type ~= ITEM_TYPE_BLOCK then
                table.insert(items, def)
            end
        end

		local def = items[index+1];
		if def then
			local id = def.ID;
			if seldata.disabledItemFileNames[def.EnglishName] or seldata.selectedItemFileNames[def.EnglishName] then
				seldata.selectedItemFileNames[def.EnglishName] = nil;
			else
				if def.Icon == "customitem" then
					seldata.selectedItemFileNames[def.EnglishName] = {id = id, modelfilename=def.Model};
				elseif def.Icon == "fullycustomitem" then
					seldata.selectedItemFileNames[def.EnglishName] = {id = id, modelfilename=def.Model, modeltype=FULLY_ITEM_MODEL};
				else
					seldata.selectedItemFileNames[def.EnglishName] = {id = id};
				end
			end
			UpdateItemSlot(this:GetParentFrame(), def);
		end
	elseif MyModsEditorType == 'craft' then
		local def = ModEditorMgr:getCraftingDef(index);
		if def then
			local id = def.ID;
			if seldata.disabledCraftFileNames[def.EnglishName] or seldata.selectedCraftFileNames[def.EnglishName] then
				seldata.selectedCraftFileNames[def.EnglishName] = nil;
			else
				seldata.selectedCraftFileNames[def.EnglishName] = id;
			end
			UpdateCraftSlot(this:GetParentFrame(), def);
		end
	elseif MyModsEditorType == 'furnace' then
		local def = ModEditorMgr:getFurnaceDef(index);
		if def then
			local id = def.ID;
			if seldata.disabledFurnaceFileNames[def.EnglishName] or seldata.selectedFurnaceFileNames[def.EnglishName] then
				seldata.selectedFurnaceFileNames[def.EnglishName] = nil;
			else
				seldata.selectedFurnaceFileNames[def.EnglishName] = id;
			end
			UpdateFurnaceSlot(this:GetParentFrame(), def);
		end
	elseif MyModsEditorType == 'plot' then
		Log("DeleteLibrary:plot:");
		local def = ModEditorMgr:getNpcPlotDef(index);
		if def then
			local id = def.ID;
			if seldata.disabledPlotFileNames[def.EnglishName] or seldata.selectedPlotFileNames[def.EnglishName] then
				seldata.selectedPlotFileNames[def.EnglishName] = nil;
			else
				seldata.selectedPlotFileNames[def.EnglishName] = id;
				AddSelTaskBySelPlot(id);
			end
			UpdatePlotSlot(this:GetParentFrame(), def);
		end
	end
end

function AddSelStoreBySelActor(id)
	local num = 0;

	if id < 1000 then
		local sum = DefMgr:getNpcShopDefNum();
		for i=0,sum-1 do
			local def =DefMgr:getNpcShopDefByIndex(i);
			if def and DefMgr:getNpcShopNpcInnerId(def.sInnerKey,def.iShopID/100,def.iShopID/100) == id then
				FrameStack.cur().CurrentSel.selectedStoreFileNames[def.EnglishName] = def.iShopID;
				num = num+1;
			end
		end

	else

		local keys = ModEditorMgr:getNpcShopKeys(id)
		print("string.len(keys):",string.len(keys),id);
		local keylist = split(keys, "|")
		
		local interactNum = interactData.GetAllNum();
		if string.len(keys) > 0 then
			for k,v in ipairs(keylist) do
				num = num+1;
			end
		else
			num = 0;
		end

		-- local num = ModEditorMgr:getCustomNpcShopCount(id);
		for i = 1, num do
			-- local shopDef = ModEditorMgr:getNpcShopDef(i);
			local NpcShopDef = ModEditorMgr:getNpcShopDefById(keylist[i])
			if NpcShopDef then
				FrameStack.cur().CurrentSel.selectedStoreFileNames[NpcShopDef.EnglishName] = NpcShopDef.iShopID;
			end
		end
	end
end

function AddSelTaskBySelPlot(plotId)
	local plotDef = ModEditorMgr:getNpcPlotDefById(plotId);
	if not plotDef then return end

	-- FrameStack.cur().CurrentSel.selectedTaskFileNames = {};
	local num = plotDef:getCreateTaskIDNum();
	for i = 1, num do
		local taskid = plotDef:getCreateTaskID(i - 1);
		local taskDef = ModEditorMgr:getNpcTaskDefById(taskid);

		if taskDef then
			FrameStack.cur().CurrentSel.selectedTaskFileNames[taskDef.EnglishName] = taskid;
		end
	end
end

function EditorSlotTemplate_OnClick()
	if FrameStack.cur().CurrentSelMode then return end

	local index = this:GetClientID();

	if MyModsEditorType == 'block' then
		local blockDef = ModEditorMgr:getBlockDef(index);
		--local blockDef = ModEditorMgr:getItemDef(index);		--LLDO
		if blockDef then
			--UpdateTipsFrame(blockDef.Name,0);
			Current_Edit_BlockDef = blockDef;
		end
	elseif MyModsEditorType == 'actor' then
		local monsterDef = ModEditorMgr:getMonsterDef(index);
		if monsterDef then
			--UpdateTipsFrame(monsterDef.Name,0);
			Current_Edit_ActorDef = monsterDef;
		end
	elseif MyModsEditorType == 'item' then
		local itemDef = ModEditorMgr:getItemDef(index);
		if itemDef then
			--UpdateTipsFrame(itemDef.Name, 0);
			Current_Edit_ItemDef = itemDef;
		end
	elseif MyModsEditorType == 'craft' then
		local craftDef = ModEditorMgr:getCraftingDef(index);
		if craftDef then
			Current_Edit_CraftDef = craftDef;
		end
	elseif MyModsEditorType == 'furnace' then
		local furnaceDef = ModEditorMgr:getFurnaceDef(index);
		if furnaceDef then
			Current_Edit_FurnaceDef = furnaceDef;
		end
	elseif MyModsEditorType == 'plot' then
		--打开剧情插件编辑页面
		local plotDef = ModEditorMgr:getNpcPlotDef(index);
		if plotDef then
			Current_Edit_NpcPlot = plotDef;
		end
		SetSingleEditorFrame('plot', Current_Edit_NpcPlot);
	end

	if MyModsEditorType == 'block' then
		--LLDO:方块
		SetSingleEditorFrame('block', Current_Edit_BlockDef);				--新
		--SetNewSingleEditorFrame('block', Current_Edit_BlockDef, false);	--旧
	elseif MyModsEditorType == 'actor' then
		SetSingleEditorFrame('actor', Current_Edit_ActorDef);
	--	SetNewSingleEditorFrame('actor', Current_Edit_ActorDef, false);
	elseif MyModsEditorType == 'item' then
		SetSingleEditorFrame('item', Current_Edit_ItemDef);
	--	SetNewSingleEditorFrame('item', Current_Edit_ItemDef, false);
	elseif MyModsEditorType == 'craft' then
		SetSingleEditorFrame('craft', Current_Edit_CraftDef);
	elseif MyModsEditorType == 'furnace' then 
		SetSingleEditorFrame('furnace', Current_Edit_FurnaceDef);
	end
end

function SetAllSlotTemplateDelState(state)
	Log("SetAllSlotTemplateDelState:"..state);
	for i=1, Max_Slot_Num do
		local slot = getglobal("EditorSlot"..i);
		--local delBtn = getglobal("EditorSlot"..i.."DelBtn");
		--local selBtn = getglobal("EditorSlot"..i.."SelBtn");
		
		if state == "show" then
			if slot:IsShown() then
				--delBtn:Show();
				--selBtn:Hide();
			end
		else
			--delBtn:Hide();
		end
	end

	--if state == "show" then
	--	getglobal("BlockGalleryFrameDelBtnName"):SetText(GetS(3969));
	--	getglobal("ActorGalleryFrameDelBtnName"):SetText(GetS(3969));
	--	getglobal("ItemGalleryFrameDelBtnName"):SetText(GetS(3969));
	--else
	--	getglobal("BlockGalleryFrameDelBtnName"):SetText(GetS(3753));
	--	getglobal("ActorGalleryFrameDelBtnName"):SetText(GetS(3967));
	--	getglobal("ItemGalleryFrameDelBtnName"):SetText(GetS(3753));
	--end
end

----------------------------------------------------删除组件--------------------------------------------

function MyModsEditorFrameDelBtn_OnClick()
	getglobal("MyModsEditorFrameDelBtn"):Hide();
	getglobal("MyModsEditorFrameCancelDelBtn"):Show();
	getglobal("MyModsEditorFrameConfirmDelBtn"):Show();
	EnterSelMode('del');
end

function MyModsEditorFrameCancelDelBtn_OnClick()
	getglobal("MyModsEditorFrameDelBtn"):Show();
	getglobal("MyModsEditorFrameCancelDelBtn"):Hide();
	getglobal("MyModsEditorFrameConfirmDelBtn"):Hide();
	LeaveSelMode();
end

function MyModsEditorFrameConfirmDelBtn_OnClick()

	local seldata = FrameStack.cur().CurrentSel;

	if table.num_pairs(seldata.selectedBlockFileNames)==0 and
		table.num_pairs(seldata.selectedActorFileNames)==0 and 
		table.num_pairs(seldata.selectedItemFileNames)==0 and
		table.num_pairs(seldata.selectedCraftFileNames)==0 and
		table.num_pairs(seldata.selectedFurnaceFileNames)==0 and
		table.num_pairs(seldata.selectedPlotFileNames)==0 then

		getglobal("MyModsEditorFrameDelBtn"):Show();
		getglobal("MyModsEditorFrameCancelDelBtn"):Hide();
		getglobal("MyModsEditorFrameConfirmDelBtn"):Hide();
		LeaveSelMode();
	else
		MessageBox(5, GetS(4700));
		getglobal("MessageBoxFrame"):SetClientString("删除插件项目");	
	end
end

function MyModsEditorFrame_DeleteSelComponents()
	getglobal("MyModsEditorFrameDelBtn"):Show();
	getglobal("MyModsEditorFrameCancelDelBtn"):Hide();
	getglobal("MyModsEditorFrameConfirmDelBtn"):Hide();

	local seldata = FrameStack.cur().CurrentSel;
	--local t_mat = {};
	--Log("Seldata")
	local blockCount = 0;
	local actorCount = 0;
	local itemCount = 0;
	local craftCount = 0;
	local furnaceCount = 0;
	local mapowid = 0;
	if Current_Edit_MapOwid then
		mapowid = Current_Edit_MapOwid
	end
	for fileName,t in pairs(seldata.selectedBlockFileNames) do
		ModEditorMgr:delModSlotFileById(BLOCK_MOD, t.id,mapowid);
		blockCount = blockCount + 1;

		--删除脚本和触发器
		local curType1 = PluginDeveloperGetHandleType(t.id,1)
		ScriptSupportCtrl:delScriptConfig(curType1,FrameStack.cur().owid)
		local curType2 = PluginDeveloperGetHandleType(t.id,2)
		ScriptSupportCtrl:delScriptConfig(curType2,FrameStack.cur().owid)
	end
	for fileName,t in pairs(seldata.selectedActorFileNames) do
		ModEditorMgr:delModSlotFileById(ACTOR_MOD, t.id,mapowid);
		actorCount = actorCount + 1;

		--删除脚本和触发器
		local curType1 = PluginDeveloperGetHandleType(t.id,1)
		ScriptSupportCtrl:delScriptConfig(curType1,FrameStack.cur().owid)
		local curType2 = PluginDeveloperGetHandleType(t.id,2)
		ScriptSupportCtrl:delScriptConfig(curType2,FrameStack.cur().owid)
	end
	for fileName,t in pairs(seldata.selectedItemFileNames) do
		ModEditorMgr:delModSlotFileById(ITEM_MOD, t.id,mapowid);
		----删除加载进地图中对应的物理材质
		--if Current_Edit_Mode == 4 then
		--	local state = 0;
		--	local PhysxMatID = 0;
		--	local PhysicsActorDef = PhysicsActorCsv:get(id)
		--	if PhysicsActorDef then
		--		PhysxMatID = PhysicsActorDef.MaterialID;
		--	end
		--	ModEditorMgr:delModSlotFileById(PHYSICS_MATERIAL_MOD, PhysxMatID);
		--	for i=1,#(t_mat) do
		--		if PhysxMatID == t_mat[i] then
		--			state = 1;
		--			break;
		--		end
		--	end
		--	if state == 0 then table.insert(t_mat,PhysxMatID) end
		--end
		itemCount = itemCount + 1;
	end
	
	for fileName, id in pairs(seldata.selectedCraftFileNames) do
		ModEditorMgr:delModSlotFileById(CRAFT_MOD, id);
		craftCount = craftCount + 1;
	end
	for fileName, id in pairs(seldata.selectedFurnaceFileNames) do
		ModEditorMgr:delModSlotFileById(FURNACE_MOD, id);
		furnaceCount = furnaceCount + 1;
	end

	local plotCount = 0;
	for fileName, id in pairs(seldata.selectedPlotFileNames) do
		ModEditorMgr:delModSlotFileById(PLOT_MOD, id,mapowid);
		plotCount = plotCount + 1;
	end

	for fileName, id in pairs(seldata.selectedTaskFileNames) do
		ModEditorMgr:delModSlotFileById(TASK_MOD, id,mapowid);
	end

	for fileName, id in pairs(seldata.selectedStoreFileNames ) do
		ModEditorMgr:delModSlotFileById(SHOP_MOD, id,mapowid);
	end

	local preveditmode = 0;
	local f0 = FrameStack.findLastFrameBefore('MyModsEditorFrame', FrameStack.cur());
	if f0 then
		preveditmode = f0.editmode;
	end

	-- if blockCount > 0 then
	-- 	statisticsGameEvent(504, '%s', 'block', '%d', Current_Edit_Mode, '%d', blockCount, '%d', preveditmode);
	-- end
	-- if actorCount > 0 then
	-- 	statisticsGameEvent(504, '%s', 'actor', '%d', Current_Edit_Mode, '%d', actorCount, '%d', preveditmode);
	-- end
	-- if itemCount > 0 then
	-- 	statisticsGameEvent(504, '%s', 'item', '%d', Current_Edit_Mode, '%d', itemCount, '%d', preveditmode);
	-- end	
	-- if craftCount > 0 then
	-- 	statisticsGameEvent(504, '%s', 'craft', '%d', Current_Edit_Mode, '%d', craftCount, '%d', preveditmode);
	-- end	
	-- if furnaceCount > 0 then
	-- 	statisticsGameEvent(504, '%s', 'furnace', '%d', Current_Edit_Mode, '%d', furnaceCount, '%d', preveditmode);
	-- end
	-- if plotCount > 0 then
	-- 	statisticsGameEvent(504, '%s', 'furnace', '%d', Current_Edit_Mode, '%d', plotCount, '%d', preveditmode);
	-- end

	FrameStack.cur().haveModified = true;

	ShowGameTips(GetS(3992), 3);
	LeaveSelMode();
end

-------------------------------------------------BlockGalleryFrame------------------------------------

function BlockGalleryFrameNewBtn_OnClick()
	SetChooseModifyAndNewFrame();
end

function BlockGalleryFrame_OnShow()
	SetAllSlotTemplateDelState("hide");
	if lastBlockPage then
		Current_Page_Index = clamp(lastBlockPage, 1, GetBlockPageCount());
	else
		Current_Page_Index = GetBlockPageCount();
	end
	UpdateEditorSlot();
end

function BlockGalleryFrame_OnHide()
end
---------------------------------------------ActorGalleryFrame--------------------------------------

function ActorGalleryFrameNewBtn_OnClick()
	SetChooseModifyAndNewFrame();
end

function ActorGalleryFrame_OnShow()
	SetAllSlotTemplateDelState("hide");	
	if lastActorPage then
		Current_Page_Index = clamp(lastActorPage, 1, GetActorPageCount());
	else
		Current_Page_Index = GetActorPageCount();
	end
	UpdateEditorSlot();
end

function ActorGalleryFrame_OnHide()
end
-------------------------------------------ItemGalleryFrame----------------------------------------

function ItemGalleryFrameNewBtn_OnClick()
	SetChooseModifyAndNewFrame();
end

function ItemGalleryFrame_OnShow()
	SetAllSlotTemplateDelState("hide");	
	if lastItemPage then
		Current_Page_Index = clamp(lastItemPage, 1, GetItemPageCount());
	else
		Current_Page_Index = GetItemPageCount();
	end
	UpdateEditorSlot();
end

------------------------------------------CraftGalleryFrame----------------------------------------------
function CraftGalleryFrameNewBtn_OnClick()
	SetChooseModifyAndNewFrame();
end

function CraftGalleryFrame_OnShow()
	SetAllSlotTemplateDelState("hide");	
	if lastItemPage then
		Current_Page_Index = clamp(lastItemPage, 1, GetCraftPageCount());
	else
		Current_Page_Index = GetCraftPageCount();
	end
	UpdateEditorSlot();
end

------------------------------------------FurnaceGalleryFrame----------------------------------------------
function FurnaceGalleryFrameNewBtn_OnClick()
	SetChooseModifyAndNewFrame();
end

function FurnaceGalleryFrame_OnShow()
	SetAllSlotTemplateDelState("hide");	
	if lastItemPage then
		Current_Page_Index = clamp(lastItemPage, 1, GetFurnacePageCount());
	else
		Current_Page_Index = GetFurnacePageCount();
	end
	UpdateEditorSlot();
end
-------------------------------------------ChooseComponentFrame----------------------------------------

function ChooseComponentFrame_OnShow()

end

--------------------------------------------EditorSlotBox-------------------------------------------

function GetBlockPageCount()
	local totalBlockCount = ModEditorMgr:getCustomBlockCount();

	local count = math.ceil(totalBlockCount / Max_Slot_Num);
	if totalBlockCount % Max_Slot_Num == 0 then  --要多加一页容纳新建按钮
		count = count + 1;
	end

	return count;
end

function GetActorPageCount()
	local totalActorCount = ModEditorMgr:getCustomMonsterCount();

	local count = math.ceil(totalActorCount / Max_Slot_Num);
	if totalActorCount % Max_Slot_Num == 0 then  --要多加一页容纳新建按钮
		count = count + 1;
	end

	return count;
end

function GetItemPageCount()
	local totalItemCount = ModEditorMgr:getCustomItemCount();

	local count = math.ceil(totalItemCount / Max_Slot_Num);
	if totalItemCount % Max_Slot_Num == 0 then  --要多加一页容纳新建按钮
		count = count + 1;
	end

	return count;
end

function GetCraftPageCount()
	local totalCraftCount = ModEditorMgr:getCustomCraftingCount();

	local count = math.ceil(totalCraftCount / Max_Slot_Num);
	if totalCraftCount % Max_Slot_Num == 0 then  --要多加一页容纳新建按钮
		count = count + 1;
	end

	return count;
end

function GetFurnacePageCount()
	local totalFurnaceCount = ModEditorMgr:getCustomFurnaceCount();

	local count = math.ceil(totalFurnaceCount / Max_Slot_Num);
	if totalFurnaceCount % Max_Slot_Num == 0 then  --要多加一页容纳新建按钮
		count = count + 1;
	end

	return count;
end

function GetNpcPlotPageCount()
	local totalplotCount =  ModEditorMgr:getCustomNpcPlotCount();

	local count = math.ceil(totalplotCount / Max_Slot_Num);
	if totalplotCount % Max_Slot_Num == 0 then  --要多加一页容纳新建按钮
		count = count + 1;
	end

	return count;
end

function UpdateBkgTips(count)
	if count <= 0 then
		getglobal("MyModsEditorFrameBkgTips"):Show();

		local bkgTipsFontStrId = iif(Current_Edit_Mode==3 or Current_Edit_Mode==4, 4077, 3996);

		if MyModsEditorType == 'block' then
			getglobal("MyModsEditorFrameBkgTipsFont"):SetText(GetS(bkgTipsFontStrId, GetS(3931), GetS(3931)));
		elseif MyModsEditorType == 'actor' then
			getglobal("MyModsEditorFrameBkgTipsFont"):SetText(GetS(bkgTipsFontStrId, GetS(3932), GetS(3932)));
		elseif MyModsEditorType == 'item' then
			getglobal("MyModsEditorFrameBkgTipsFont"):SetText(GetS(bkgTipsFontStrId, GetS(3933), GetS(3933)));
		end

		--if AccountManager:getNoviceGuideState("modcreatecomponent") then
		--	getglobal("MyModsEditorFrameBkgTipsGuide"):Hide();
		--else
		--	getglobal("MyModsEditorFrameBkgTipsGuide"):Show();
		--end
	else
		getglobal("MyModsEditorFrameBkgTips"):Hide();
		--getglobal("MyModsEditorFrameBkgTipsGuide"):Hide();
	end
end

function UpdateEditorSlot()
	print("UpdateEditorSlot11111 ",Current_Edit_Mode, MyModsEditorType);

	if Current_Edit_Mode==3 or Current_Edit_Mode==4 then
		getglobal("EditorSlotCreateBtnName"):SetText(GetS(4094));
	else
		getglobal("EditorSlotCreateBtnName"):SetText(GetS(4093));
	end

	local createBtnPos = 0;  	--创建按钮始终是第一个
	local totalSlotCount = 0;	--格子总数

	if MyModsEditorType == 'block' then
		local totalBlockCount =  ModEditorMgr:getCustomBlockCount();
		UpdateBkgTips(totalBlockCount);
		totalSlotCount = totalBlockCount;

		for i=1, Max_Slot_Num do
			local slot = getglobal("EditorSlot"..i);
			if i <= totalBlockCount then
				slot:Show();
				local blockDef = ModEditorMgr:getBlockDef(i -1);
				UpdateBlockSlot(slot, blockDef);	
			else
				slot:Hide();
			end
		end
		
	elseif MyModsEditorType == 'actor' then
		local totalActorCount =  ModEditorMgr:getCustomMonsterCount();
		UpdateBkgTips(totalActorCount);
		totalSlotCount = totalActorCount;

		for i=1, Max_Slot_Num do
			local slot = getglobal("EditorSlot"..i);
			if i <= totalActorCount then
				slot:Show();
				local actorDef = ModEditorMgr:getMonsterDef(i -1);
				UpdateActorSlot(slot, actorDef);
			else
				slot:Hide();
			end
		end

	elseif MyModsEditorType == 'item' then
        local t_Item = {}
		local totalItemCount = ModEditorMgr:getCustomItemCount();

        --因为block部分的Item和道具一起存放，所以需要先过滤数据
        for i=1,totalItemCount do
            local def = ModEditorMgr:getItemDef(i-1);
            if def and def.Type ~= ITEM_TYPE_BLOCK then
                table.insert(t_Item, def)
            end
        end
		totalItemCount = #(t_Item);
		totalSlotCount = totalItemCount;

		UpdateBkgTips(totalItemCount);

		for i=1, Max_Slot_Num do
			local slot = getglobal("EditorSlot"..i);
			if i <= totalItemCount then
			    local itemDef = t_Item[i];

				slot:Show();
				UpdateItemSlot(slot, itemDef);
			else
				slot:Hide();
			end
		end

		lastItemPage = Current_Page_Index;
	elseif MyModsEditorType == 'craft' then
		local totalCraftCount =  ModEditorMgr:getCustomCraftingCount();
		UpdateBkgTips(totalCraftCount);
		totalSlotCount = totalCraftCount;

		for i = 1, Max_Slot_Num do
			local slot = getglobal("EditorSlot"..i);
			if i <= totalCraftCount then
				slot:Show();
				local craftDef = ModEditorMgr:getCraftingDef(i -1);
				UpdateCraftSlot(slot, craftDef);
			else
				slot:Hide();
			end
		end

	elseif MyModsEditorType == 'furnace' then
		local totalFurnaceCount =  ModEditorMgr:getCustomFurnaceCount();
		UpdateBkgTips(totalFurnaceCount);
		totalSlotCount = totalFurnaceCount;

		for i=1, Max_Slot_Num do
			local slot = getglobal("EditorSlot"..i);
			if i <= totalFurnaceCount then
				slot:Show();
				local furnaceDef = ModEditorMgr:getFurnaceDef(i -1);
				UpdateFurnaceSlot(slot, furnaceDef);
			else
				slot:Hide();
			end
		end
	elseif MyModsEditorType == 'plot' then
		--LLTODO:加载自定义的剧情数量
		Log("LoadCustomPlot: plot:");
		local totalplotCount =  ModEditorMgr:getCustomNpcPlotCount();
		UpdateBkgTips(totalplotCount);
		totalSlotCount = totalplotCount;

		for i = 1, Max_Slot_Num do
			local slot = getglobal("EditorSlot"..i);
			if i <= totalplotCount then
				Log("i = " .. i);
				slot:Show();
				local plotdef = ModEditorMgr:getNpcPlotDef(i -1);
				UpdateNPCPlotSlot(slot, plotdef);	
			else
				slot:Hide();
			end
		end
	end

	--调整滑动框高度
	local totalHeight = math.ceil((totalSlotCount + 1) / 8) * 161 + 17;
	if totalHeight < 554 then totalHeight = 554; end
	getglobal("EditorSlotBoxPlane"):SetHeight(totalHeight);

	--创建按钮位置(始终第一个-->放最后面)
	createBtnPos = totalSlotCount;
	if createBtnPos >= 0 then
		getglobal("EditorSlotCreateBtn"):Show();

		local row = math.floor(createBtnPos / 8);
		local col = createBtnPos % 8;

		local slot = getglobal("EditorSlotCreateBtn");
		slot:SetPoint("topleft", "EditorSlotBoxPlane", "topleft", col * 130 + 17, row * 161 + 17);
	else
		getglobal("EditorSlotCreateBtn"):Hide();
	end

	if Current_Edit_Mode==3 or Current_Edit_Mode==4 then
		UpdateMapModStateFrame();
	end
end

function EditorSlotCreateBtn_OnClick()
	if Current_Edit_Mode==3 or Current_Edit_Mode==4 then
		MyModsEditorFrameAddComponentBtn_OnClick();
	else
		SetChooseModifyAndNewFrame();
	end

	--AvtPartInfo:UpPartBuyInfo("all");
	
	-- if MyModsEditorType == "plot" then
	-- 	statisticsGameEvent(40100, '%d', 2);
	-- end
end

function MyModsEditorFrameBkgTipsGuide_OnClick()
	AccountManager:setNoviceGuideState("modcreatecomponent", true);
	getglobal("MyModsEditorFrameBkgTipsGuide"):Hide();
end

------------------------------------------------ChooseModifyAndNewFrame-----------------------------------
function SetChooseModifyAndNewFrame()
	--local modifyBtnName = getglobal("ChooseModifyAndNewFrameModifyBtnName");
	--local newBtnName = getglobal("ChooseModifyAndNewFrameNewBtnName");
	local modifyBtnText1 = getglobal("ChooseModifyAndNewFrameModifyBtnText1");
	local modifyBtnText2 = getglobal("ChooseModifyAndNewFrameModifyBtnText2");
	local newBtnText1 = getglobal("ChooseModifyAndNewFrameNewBtnText1");
	local newBtnText2 = getglobal("ChooseModifyAndNewFrameNewBtnText2");
	local strID = { block = 3931, actor = 3932, item = 3933, craft = 1231, furnace = 1230, plot = 11006};
	modifyBtnText1:SetText(GetS(3952));
	newBtnText1:SetText(GetS(3958));
	modifyBtnText2:SetText(GetS(3955, GetS(strID[MyModsEditorType])))
	newBtnText2:SetText(GetS(3956, GetS(strID[MyModsEditorType])))
	--if MyModsEditorType == 'block' then
	--	modifyBtnText2:SetText(GetS(3955, GetS(strID[MyModsEditorType])));
	--	modifyBtnName:SetText(GetS(3955, GetS(3931)));
	--	newBtnName:SetText(GetS(3956, GetS(3931)));
	--elseif MyModsEditorType == 'actor' then
	--	modifyBtnText2:SetText(GetS(3955, GetS(3932)))
	--	modifyBtnName:SetText(GetS(3955, GetS(3932)));
	--	newBtnName:SetText(GetS(3956, GetS(3932)));
	--elseif MyModsEditorType == 'item' then
	--	modifyBtnText2:SetText(GetS(3955, GetS(3933)))
	--	modifyBtnName:SetText(GetS(3955, GetS(3933)));
	--	newBtnName:SetText(GetS(3956, GetS(3933)));
	--elseif MyModsEditorType == 'craft' then
	--	modifyBtnName:SetText(GetS(3955, GetS(1231)));
	--	newBtnName:SetText(GetS(3956, GetS(1231)));
	--elseif MyModsEditorType == 'furnace' then
	--	modifyBtnName:SetText(GetS(3955, GetS(1230)));
	--	newBtnName:SetText(GetS(3956, GetS(1230)));
	--elseif MyModsEditorType == 'plot' then
	--	modifyBtnName:SetText(GetS(3955, GetS(11006)));
	--	newBtnName:SetText(GetS(3956, GetS(11006)));
	--end
	
	getglobal("ChooseModifyAndNewFrame"):Show();
end

function ChooseModifyAndNewFrame_OnLoad()
	--标题名:新建/修改
	getglobal("ChooseModifyAndNewFrameTitleFrameName"):SetText(GetS(3954));
end

-- 修改已有的XXX
function ChooseModifyAndNewFrameModifyBtn_OnClick()
	getglobal("ChooseModifyAndNewFrame"):Hide();
	SetChooseOriginalFrame();

	-- if MyModsEditorType == "plot" then
	-- 	statisticsGameEvent(40100, '%d', 3);
	-- end
end

--selectTemplate:创建新的XXX
function ChooseModifyAndNewFrameNewBtn_OnClick()
	if MyModsEditorType == 'block' then
		SetSelTemplateEditorInfo(MyModsEditorType, false);
	elseif MyModsEditorType == 'actor' then
		SetSelTemplateEditorInfo(MyModsEditorType, false);
	else
		SetSelTemplateEditorInfo(MyModsEditorType, false);
	end

	-- if MyModsEditorType == "plot" then
	-- 	statisticsGameEvent(40100, '%d', 4);
	-- end
end
---------------------------------------OriginalGridTemplate----------------------------------
local CheckedOBName = nil;
local ChooseOriginalType = nil;
function OriginalGridTemplate_OnClick()
	local id = this:GetClientID();

	if CheckedOBName then
		getglobal(CheckedOBName.."Checked"):Hide();
	end
	
	CheckedOBName = this:GetName()
	getglobal(CheckedOBName.."Checked"):Show();

	if ChooseOriginalType == 'blockmodel' then
		getglobal('ChooseOriginalFrameOkBtn'):SetClientID(id);	--ClientID记录了选择的模型表ID;
		local itemDef = ItemDefCsv:get(id, false);
		--弹出提示框
		if itemDef then
			UpdateTipsFrame(itemDef.Name,0);
		end
	elseif ChooseOriginalType == 'itemmodel' and CurEditorType == 4 then
		--预设装备自定义模型:将自定义模型文件名放在'ok'按钮中存着
		local pModelName = this:GetClientString();
		local index = this:GetClientID();
		getglobal('ChooseOriginalFrameOkBtn'):SetClientString(pModelName);
		getglobal('ChooseOriginalFrameOkBtn'):SetClientID(index);
		if GetInst("ModsLibEditorItemPartMgr") then
			local OfficialEquipInfo = GetInst("ModsLibEditorItemPartMgr"):GetOfficialEquipInfoByIndex(index);
			if OfficialEquipInfo and OfficialEquipInfo.name then
				UpdateTipsFrame(OfficialEquipInfo.name,0);
			end
		end
	elseif ChooseOriginalType == 'itemmodel' then
		getglobal('ChooseOriginalFrameOkBtn'):SetClientID(id);	--ClientID记录了选择的模型表ID;
		local def = ModEditorMgr:getModModelDef(id);
		if def then
			local itemDef = ItemDefCsv:get(def.RelevantID);
			--弹出提示框
			if itemDef then
				if itemDef.gamemod and itemDef.gamemod:isExportMod() then
					UpdateTipsFrame(itemDef.Name .."-#cFFFFFF" .. itemDef.gamemod:getName() ,0);
				else
					UpdateTipsFrame(itemDef.Name,0);
				end
			end
		end
	elseif ChooseOriginalType == 'actormodel' then
		getglobal('ChooseOriginalFrameOkBtn'):SetClientID(id);	--ClientID记录了选择的模型表ID;
		local def = ModEditorMgr:getModModelDef(id);
		if def then
			local chooseDef = nil;
			if CurEditorType == 2 then --角色
				chooseDef = DefMgr:getRoleDef(def.RelevantID, 0);
			elseif CurEditorType == 3 then --皮肤
				chooseDef = RoleSkinCsv:get(id);
			elseif CurEditorType == 4 then --定制装扮
				local avatarInfoTable = GetTable2EditType(CurEditorType)
				for i = 1,#avatarInfoTable do 
					if avatarInfoTable[i].id == id then 
						local avatarInfo = avatarInfoTable[i]
						chooseDef = {} 
						chooseDef.Name = avatarInfo.name 
					end 
				end 
			elseif CurEditorType == 7 then -- 坐骑
			else
				chooseDef = MonsterCsv:get(def.RelevantID);
			end
			--弹出提示框
			if chooseDef then
				if chooseDef.gamemod and chooseDef.gamemod:isExportMod() then
					UpdateTipsFrame(chooseDef.Name .."-#cFFFFFF" .. chooseDef.gamemod:getName() ,0);
				else
					UpdateTipsFrame(chooseDef.Name,0);
				end
			end
		end
	elseif ChooseOriginalType == 'dropitem' or ChooseOriginalType == 'craftresult' or ChooseOriginalType == 'craftmaterial' or  ChooseOriginalType == 'craft_tool' or 
			ChooseOriginalType == 'furnaceresult' or ChooseOriginalType == 'furnacematerial' or ChooseOriginalType == "PlotItemID" or 
			ChooseOriginalType == "TaskContents_Item" or ChooseOriginalType == "StoreItem"  or ChooseOriginalType == "StoreAddItem" or ChooseOriginalType == "PackAddItem" then

		getglobal('ChooseOriginalFrameOkBtn'):SetClientID(id);	--ClientID记录了选择的掉落物ID;
		local itemDef = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);
		if itemDef then
			--弹出提示框
			if itemDef.gamemod and itemDef.gamemod:isExportMod() then
				UpdateTipsFrame(itemDef.Name .."-#cFFFFFF" .. itemDef.gamemod:getName() ,0);
			else
				UpdateTipsFrame(itemDef.Name,0);
			end
		end
	elseif ChooseOriginalType == 'transferticket' or ChooseOriginalType == 'transferban' then
		getglobal('ChooseOriginalFrameOkBtn'):SetClientID(id);	--ClientID记录了选择的掉落物ID;
		local itemDef = ModMgr:tryGetItemDef(id) or ItemDefCsv:get(id);
		if itemDef then
			--弹出提示框
			if itemDef.gamemod and itemDef.gamemod:isExportMod() then
				UpdateTipsFrame(itemDef.Name .."-#cFFFFFF" .. itemDef.gamemod:getName() ,0);
			else
				UpdateTipsFrame(itemDef.Name,0);
			end
		end
	elseif ChooseOriginalType == 'projectilemodel' then
		getglobal('ChooseOriginalFrameOkBtn'):SetClientID(id);	--ClientID记录了选择的模型表ID;
		local def = ModEditorMgr:getModModelDef(id);
		if def then
			local itemDef = ItemDefCsv:get(def.RelevantID);
			--弹出提示框
			if itemDef then
				if itemDef.gamemod and itemDef.gamemod:isExportMod() then
					UpdateTipsFrame(itemDef.Name .."-#cFFFFFF" .. itemDef.gamemod:getName() ,0);
				else
					UpdateTipsFrame(itemDef.Name,0);
				end
			end
		end
	elseif ChooseOriginalType == 'projectile' or ChooseOriginalType == 'bullet' then
		getglobal('ChooseOriginalFrameOkBtn'):SetClientID(id);	--ClientID记录了选择的投射物ID;
		local itemDef = ModEditorMgr:getItemDefById(id);
		if itemDef == nil then itemDef = ItemDefCsv:get(id); end

		if itemDef then
			--弹出提示框
			if itemDef.gamemod and itemDef.gamemod:isExportMod() then
				UpdateTipsFrame(itemDef.Name .."-#cFFFFFF" .. itemDef.gamemod:getName() ,0);
			else
				UpdateTipsFrame(itemDef.Name,0);
			end
		end
	elseif ChooseOriginalType == 'atkbuff' then
		getglobal('ChooseOriginalFrameOkBtn'):SetClientID(id);	--ClientID记录了选择的buffID;
--		local buffDef = DefMgr:getBuffDef(math.floor(id/1000), id%1000);
		local buffDef
		if UseNewModsLib then
			buffDef = DefMgr:getStatusDef(id);
		else
			buffDef = DefMgr:getBuffDef(id);
		end

		if buffDef then
			--弹出提示框
			UpdateTipsFrame(buffDef.Name,0);
		end
    elseif ChooseOriginalType == 'featureai' then
        Current_Edit_AiItem = t_OriginalInfo[1].t[id]
        UpdateTipsFrame(GetS(Current_Edit_AiItem.NameStringId), 0);
        --print("---------------Current_Edit_AiItem")
        --print(Current_Edit_AiItem)
	elseif  ChooseOriginalType == 'featureitemskill' then
        Current_Edit_ItemSkill = t_OriginalInfo[1].t[id]
        UpdateTipsFrame(GetS(Current_Edit_ItemSkill.NameStringId), 0);
        --print("---------------Current_Edit_AiItem")
        --print(Current_Edit_AiItem)   
	elseif ChooseOriginalType == 'ai_projectile' then
		Current_Edit_AiItem = id
		local itemDef = ModEditorMgr:getItemDefById(id);
		if itemDef == nil then itemDef = ItemDefCsv:get(id); end

		if itemDef then
			--弹出提示框
			if itemDef.gamemod and itemDef.gamemod:isExportMod() then
				UpdateTipsFrame(itemDef.Name .."-#cFFFFFF" .. itemDef.gamemod:getName() ,0);
			else
				UpdateTipsFrame(itemDef.Name,0);
			end
		end
    elseif ChooseOriginalType == 'ai_block' then
        Current_Edit_AiItem = id
		local def = ModEditorMgr:getBlockItemDefById(id);
		if def == nil then
			def = ItemDefCsv:get(id);
		end

		if def then
			if def.gamemod and def.gamemod:isExportMod() then
				UpdateTipsFrame(def.Name .."-#cFFFFFF" .. def.gamemod:getName() ,0);
			else
				UpdateTipsFrame(def.Name,0);
			end
		end
    elseif ChooseOriginalType == 'ai_buff' then
        Current_Edit_AiItem = id
		local buffDef
		if UseNewModsLib then
			buffDef = DefMgr:getStatusDef(id);
		else
			buffDef = DefMgr:getBuffDef(id);
		end

		if buffDef then
			--弹出提示框
			UpdateTipsFrame(buffDef.Name,0);
		end
    elseif ChooseOriginalType == 'ai_food' then
        Current_Edit_AiItem = id
        local def
        if CurEditorType ~= 2 then
            def = ItemDefCsv:get(id);
        else
            def = ModEditorMgr:getItemDefById(id);
            if not def then
                def = ModEditorMgr:getBlockItemDefById(id);
                if not def then
					def = ModEditorMgr:getBlockItemDefById(id);
					if not def then
						def = ItemDefCsv:get(id)
					end
                end
            end
		end
		if def then
			UpdateTipsFrame(def.Name, 0);
		end
    elseif ChooseOriginalType == 'ai_actor' then
        Current_Edit_AiItem = id

        local def = ModEditorMgr:getMonsterDefById(id);
        if not def then
            def = MonsterCsv:get(id);
		end
		
		if def then
			UpdateTipsFrame(def.Name, 0);
		end
    elseif ChooseOriginalType == 'ai_container' or ChooseOriginalType == 'ai_targetblock' or ChooseOriginalType == 'ai_useitem' or ChooseOriginalType == 'ai_dropitem' then
    	--LLDO:new add:箱子
    	Current_Edit_AiItem = id
    	local itemDef = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);
		if itemDef then
			--弹出提示框
			UpdateTipsFrame(itemDef.Name,0);
		end
    elseif ChooseOriginalType == 'ai_craft' then
    	--LLDO:new add:配方
    	Current_Edit_AiItem = id
        local craftDef = ModEditorMgr:getCraftingDefById(id);
		if not craftDef then
			craftDef = DefMgr:getCraftingDef(id);
		end
		--弹出提示框
		if craftDef then
			local itemDef = ModEditorMgr:getItemDefById(craftDef.ResultID);
			if not itemDef then
				itemDef = ItemDefCsv:get(craftDef.ResultID);
			end

			if itemDef then
				UpdateTipsFrame(itemDef.Name,0);
			end
		end
	elseif ChooseOriginalType == "PlotIcon" then		--剧情图标
		Log("LLTODO:clickCeil: CurEditorType = " .. CurEditorType);
		if CurEditorType == 1 then
			--生物
			-- Current_Edit_ActorDef = nil;
			-- local monsterDef = ModEditorMgr:getMonsterDefById(id);
			-- if not monsterDef then
			-- 	monsterDef = MonsterCsv:get(id);
			-- end
			-- --弹出提示框
			-- if monsterDef then
			-- 	UpdateTipsFrame(monsterDef.Name,0);
			-- 	Current_Edit_ActorDef = monsterDef;
			-- end
			local def = ModEditorMgr:getModModelDef(id);
			if def then
				local monsterDef = nil;
				monsterDef = MonsterCsv:get(def.RelevantID);
				--弹出提示框
				if monsterDef then
					getglobal('ChooseOriginalFrameOkBtn'):SetClientID(def.RelevantID);	--ClientID记录了ID;
					Current_Edit_ActorDef = monsterDef;
					UpdateTipsFrame(monsterDef.Name,0);
				end
			end
		elseif CurEditorType == 2 then
			--道具
			Log("id = " .. id);
        	Current_Edit_ItemDef = nil;
			local itemDef = ModEditorMgr:getItemDefById(id);
			if not itemDef then
				itemDef = ItemDefCsv:get(id);
			end
			--弹出提示框
			if itemDef then
				getglobal('ChooseOriginalFrameOkBtn'):SetClientID(itemDef.ID);	--ClientID记录了ID;
				UpdateTipsFrame(itemDef.Name,0);
				Current_Edit_ItemDef = itemDef;
			end
		end
	elseif ChooseOriginalType == "PlotInteractID" or ChooseOriginalType == "TaskContents_Monster" then	--剧情触发目标
		Log("LLTODO:clickCeil: CurEditorType = " .. CurEditorType);
		getglobal('ChooseOriginalFrameOkBtn'):SetClientID(id);	--ClientID记录了ID;
		Current_Edit_ActorDef = nil;
		local monsterDef = ModEditorMgr:getMonsterDefById(id);
		if not monsterDef then
			monsterDef = MonsterCsv:get(id);
		end
		--弹出提示框
		if monsterDef then
			UpdateTipsFrame(monsterDef.Name,0);
			Current_Edit_ActorDef = monsterDef;
		end
	-- elseif ChooseOriginalType == "TaskContents_Item" then	--剧情拥有道具
	-- 	Log("LLTODO:clickCeil: CurEditorType = " .. CurEditorType);
	-- 	getglobal('ChooseOriginalFrameOkBtn'):SetClientID(id);	--ClientID记录了ID;
	-- 	Current_Edit_ItemDef = nil;
	-- 	local itemDef = ModEditorMgr:getItemDefById(id);
	-- 	if not itemDef then
	-- 		itemDef = ItemDefCsv:get(id);
	-- 	end
	-- 	--弹出提示框
	-- 	if itemDef then
	-- 		UpdateTipsFrame(itemDef.Name,0);
	-- 		Current_Edit_ItemDef = itemDef;
	-- 	end
	else
		if MyModsEditorType == 'block' then
			Current_Edit_BlockDef = nil;
			local itemDef = ModEditorMgr:getBlockItemDefById(id);
			local blockDef = ModEditorMgr:getBlockDefById(id);
			if not itemDef then
				itemDef = ModEditorMgr:getItemDefById(id);
			end
			if not itemDef then
				itemDef = ItemDefCsv:get(id);
			end
			if not blockDef then
				blockDef = BlockDefCsv:get(id, false);
			end
			--弹出提示框
			if blockDef and itemDef then
				UpdateTipsFrame(itemDef.Name,0);
				Current_Edit_BlockDef = blockDef;
			end
		elseif MyModsEditorType == 'actor' then
			Current_Edit_ActorDef = nil;
			local monsterDef = ModEditorMgr:getMonsterDefById(id);
			if not monsterDef then
				monsterDef = MonsterCsv:get(id);
			end
			--弹出提示框
			if monsterDef then
				UpdateTipsFrame(monsterDef.Name,0);
				Current_Edit_ActorDef = monsterDef;
			end
		elseif MyModsEditorType == 'item' then
			Current_Edit_ItemDef = nil;
			local itemDef = ModEditorMgr:getItemDefById(id);
			if not itemDef then
				itemDef = ItemDefCsv:get(id);
			end
			--弹出提示框
			if itemDef then
				UpdateTipsFrame(itemDef.Name,0);
				Current_Edit_ItemDef = itemDef;
			end
		elseif MyModsEditorType == 'craft' then
			Current_Edit_CraftDef = nil;
			local craftDef = ModEditorMgr:getCraftingDefById(id);
			if not craftDef then
				craftDef = DefMgr:getCraftingDef(id);
			end
			--弹出提示框
			if craftDef then
				local itemDef = ModEditorMgr:getItemDefById(craftDef.ResultID);
				if not itemDef then
					itemDef = ItemDefCsv:get(craftDef.ResultID);
				end

				if itemDef then
					UpdateTipsFrame(itemDef.Name,0);
				end

				Current_Edit_CraftDef = craftDef;
			end
		elseif MyModsEditorType == 'furnace' then
			Current_Edit_FurnaceDef = nil;
			local furnaceDef = ModEditorMgr:getFurnaceDefById(id);
			if not furnaceDef then
				furnaceDef = DefMgr:getFurnaceDef(id);
			end
			--弹出提示框
			if furnaceDef then
				local itemDef = ModEditorMgr:getItemDefById(furnaceDef.MaterialID);
				if not itemDef then
					itemDef = ItemDefCsv:get(furnaceDef.MaterialID);
				end

				if itemDef then
					UpdateTipsFrame(itemDef.Name,0);
				end

				Current_Edit_FurnaceDef = furnaceDef;
			end
		elseif MyModsEditorType == 'plot' then
			--点击剧情,飘字:剧情的名字
			Current_Edit_FurnaceDef = nil;
			local plotDef = ModEditorMgr:getNpcPlotDefById(id);
			if not plotDef then
				plotDef = DefMgr:getNpcPlotDef(id);
			end
			--弹出提示框
			if plotDef then
				UpdateTipsFrame(ConvertDialogueStr(plotDef.Name),0);
				Current_Edit_NpcPlot = plotDef;
			end
		end
	end
end

------------------------------------------------ChooseOriginalFrame-------------------------------------------
function ChooseOriginalFrameClose_OnClick()
	getglobal("ChooseOriginalFrame"):Hide();
end

-- selecttion:格子选择器, 确认按钮
function ChooseOriginalFrameOkBtn_OnClick()
	if ChooseOriginalType == 'blockmodel' then
		local filename = getglobal("ChooseOriginalFrameOkBtn"):GetClientString();
		if filename ~= "" then --选中微雕模型
			local modelType = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();  --ClientID记录了选择的微雕模型类型;
			if modelType >= FULLY_BLOCK_MODEL then
				modelType = "fullycustommodel"
			elseif modelType >= IMPORT_BLOCK_MODEL and modelType <= IMPORT_MODEL_MAX then
				modelType = "importcustommodel"
			else
				modelType = "custommodel";
			end
			OnCurEditorUICallBack('blockmodel', filename, modelType);
		else
			local id = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();
			if id == 0 then
				ShowGameTips(GetS(4880));
				return;
			end
			local def = BlockDefCsv:get(id, false);
			if not def then return end

			--SetModelRelevantID(def.ID)
			OnCurEditorUICallBack('blockmodel', def.ID);	--LLDO:改变模型外观
		end
	elseif ChooseOriginalType == 'itemmodel' or ChooseOriginalType == 'actormodel' then
		local filename = getglobal("ChooseOriginalFrameOkBtn"):GetClientString();
		if filename and filename ~= ""  then --选中微雕模型
			local modelType = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();
			if modelType >= FULLY_BLOCK_MODEL then
				modelType = "fullycustommodel"
			elseif modelType >= IMPORT_BLOCK_MODEL and modelType <= IMPORT_MODEL_MAX then
				modelType = "importcustommodel"
			else
				modelType = "custommodel";
			end

			if ChooseOriginalType == 'itemmodel' then
				local resClass = RES_MODEL_CLASS;
				if CurEditorType == 4 then
					--预设装备自定义模型
					resClass = EQUIP_MODEL_CLASS;

					local index = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();
					local OfficialEquipInfo = GetInst("ModsLibEditorItemPartMgr"):GetOfficialEquipInfoByIndex(index);
					if OfficialEquipInfo then
						modelType = OfficialEquipInfo.model;
					end
				end

				if HasUIFrame("ModsLibEditorItemPart") and getglobal("ModsLibEditorItemPart"):IsShown() then
					GetInst("UIManager"):GetCtrl("ModsLibEditorItemPart"):SelectModeOnCallback(0, filename, modelType, resClass);
				else
					OnCurEditorUICallBack('itemmodel', filename, modelType);
				end
			elseif ChooseOriginalType == 'actormodel' then
				OnCurEditorUICallBack('actormodel', filename, modelType);
			end
		else
			local id = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();	--ClientID记录了选择的模型表ID;
			if id == 0 then
				ShowGameTips(GetS(4880));
				return;
			end

			if HasUIFrame("ModsLibEditorItemPart") and getglobal("ModsLibEditorItemPart"):IsShown() then
				GetInst("UIManager"):GetCtrl("ModsLibEditorItemPart"):SelectModeOnCallback(id);
				getglobal("ChooseOriginalFrame"):Hide();
				return;
			end

			local def = nil
			if ChooseOriginalType == 'itemmodel' then
				def = ModEditorMgr:getModModelDef(id);
				if not def then return end
				OnCurEditorUICallBack('itemmodel', def);
			else
				if CurEditorType == MONSTER_HORSE_MODEL then -- 坐骑模型 chenweiTODO 选择指定模型，点击确认按钮
					local val = 700000 + id
					OnCurEditorUICallBack('actormodel', val);
				elseif CurEditorType == 4 then  --Avatar模型
					local val = 30000 + id
					OnCurEditorUICallBack('actormodel', val);
				else
					local val = 0;
					if CurEditorType == 3 then --皮肤模型
						local roleId = Genius_Helper:GetOldRoleID(id) -- 特殊冒险皮肤：老角色转成的皮肤依旧按照角色来ID索引对应模型
						if roleId > 0 then
							local def = DefMgr:getRoleDef(roleId)
							if not def then return end
							val = 10000 + def.Model;
						else
							def = RoleSkinCsv:get(id);
							if not def then return end
							val = 20000 + def.ID;
						end
					else
						def = ModEditorMgr:getModModelDef(id);
						val = def.RelevantID;
					 	if CurEditorType == 2 then --角色模型
							val = 10000 + def.RelevantID;
						end
					end
					OnCurEditorUICallBack('actormodel', val);
				end
			end
		end
	elseif ChooseOriginalType == 'dropitem' or ChooseOriginalType == 'craftresult' or ChooseOriginalType == 'craftmaterial' or ChooseOriginalType == 'craft_tool' or
			ChooseOriginalType == 'furnaceresult' or ChooseOriginalType == 'furnacematerial' or ChooseOriginalType == 'StoreItem' or
			 ChooseOriginalType == "StoreAddItem" or ChooseOriginalType == "PackAddItem" then

		local id = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();	--ClientID记录了选择的掉落物ID;
		if id == 0 then
			ShowGameTips(GetS(4880));
			return;
		end
		local def = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);
		if not def then return end

		OnCurEditorUICallBack(ChooseOriginalType, id);
	elseif ChooseOriginalType == 'projectilemodel' then
		local id = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();	--ClientID记录了选择的模型表ID;
		if id == 0 then
			ShowGameTips(GetS(4880));
			return;
		end
		local def = ModEditorMgr:getModModelDef(id);
		if not def then return end

		OnCurEditorUICallBack('projectilemodel', def.RelevantID);
	elseif ChooseOriginalType == 'projectile' or ChooseOriginalType == 'bullet' then
		local id = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();	--ClientID记录了选择的投射物ID;
		if id == 0 then
			ShowGameTips(GetS(4880));
			return;
		end
		local def = ModEditorMgr:getItemDefById(id);
		if def == nil then def = ItemDefCsv:get(id) end
		if not def then return end

		OnCurEditorUICallBack(ChooseOriginalType, def.ID);
	elseif ChooseOriginalType == 'atkbuff' then
		local id = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();	--ClientID记录了选择的buffID;
		if id == 0 then
			ShowGameTips(GetS(4880));
			return;
		end

		OnCurEditorUICallBack(ChooseOriginalType, id);
    elseif ChooseOriginalType == 'featureai' then
        OnCurEditorUICallBack_Feature_Add(Current_Edit_AiItem, 'actor');
	elseif ChooseOriginalType == 'featureitemskill' then
        OnCurEditorUICallBack_Feature_Add(Current_Edit_ItemSkill, 'item');
    elseif (ChooseOriginalType == 'ai_block' or ChooseOriginalType == 'ai_actor' or ChooseOriginalType == 'ai_food' or ChooseOriginalType == 'ai_buff' or ChooseOriginalType == 'ai_projectile' or 
    		ChooseOriginalType == 'ai_container' or ChooseOriginalType == 'ai_craft' or ChooseOriginalType == 'ai_targetblock' or ChooseOriginalType == 'ai_useitem' or ChooseOriginalType == 'ai_dropitem') then
        OnCurEditorUICallBack_Feature_SelectIcon(Current_Edit_AiItem)
    elseif ChooseOriginalType == "PlotIcon" then		--剧情图标
		Log("LLTODO:CeilOKClick: PlotIcon: CurEditorType = " .. CurEditorType);
		local id = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();	--ClientID记录了选择的生物/道具ID;
		Log("id = " .. id);
		if id == 0 then
			ShowGameTips(GetS(4880));
			return;
		end
		local val = id;
		if CurEditorType == 1 then
			--生物
			val = 100000 + id;
		elseif CurEditorType == 2 then
			--道具
			val = 200000 + id;
		end
    	OnCurEditorUICallBack('PlotIcon', val);
	elseif ChooseOriginalType == "PlotInteractID" then	--剧情触发目标
		Log("LLTODO:CeilOKClick: PlotInteractID: CurEditorType = " .. CurEditorType);
		local id = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();	--ClientID记录了选择的生物ID;
		if id == 0 then
			ShowGameTips(GetS(4880));
			return;
		end
		Log("id = " .. id);
		OnCurEditorUICallBack('PlotInteractID', id);
	elseif ChooseOriginalType == "PlotItemID" then	--剧情拥有道具
		Log("LLTODO:CeilOKClick: PlotItemID: CurEditorType = " .. CurEditorType);
		local id = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();	--ClientID记录了选择的生物ID;
		if id == 0 then
			ShowGameTips(GetS(4880));
			return;
		end
		Log("id = " .. id);
		OnCurEditorUICallBack('PlotItemID', id);
	elseif ChooseOriginalType == "TaskContents_Item" or ChooseOriginalType == "TaskContents_Monster" then	--任务类型:生物, 道具.
		local id = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();	--记录了生物或道具ID
		if id == 0 then
			ShowGameTips(GetS(4880));
			return;
		end
		NpcTask_SelectionOkBtnClick_CallBack(id);
	elseif ChooseOriginalType == 'transferban' or ChooseOriginalType == 'transferticket' then

		local id = getglobal("ChooseOriginalFrameOkBtn"):GetClientID();	--ClientID记录了选择的掉落物ID;
		if id == 0 then
			ShowGameTips(GetS(4880));
			return;
		end
		local def = ModMgr:tryGetItemDef(id) or ItemDefCsv:get(id);
		if not def then return end

		TransferItemSelectCallBack(ChooseOriginalType, id);
	else
		local def = nil;
		local text;

		if MyModsEditorType == 'block' then
			if not Current_Edit_BlockDef then return; end
		
			def = ModEditorMgr:getBlockDefById(Current_Edit_BlockDef.ID);
			if def then text = GetS(3931) end
		elseif MyModsEditorType == 'actor' then
			if not Current_Edit_ActorDef then return; end

			def = ModEditorMgr:getMonsterDefById(Current_Edit_ActorDef.ID);
			if def then text = GetS(3932) end
		elseif MyModsEditorType == 'item' then
			if not Current_Edit_ItemDef then return; end
			
			def = ModEditorMgr:getItemDefById(Current_Edit_ItemDef.ID);
			if def then text = GetS(3933) end
		elseif MyModsEditorType == 'craft' then
			if not Current_Edit_CraftDef then return; end
			
		--	def = ModEditorMgr:getCraftDefById(Current_Edit_CraftDef.ID);
		--	if def then text = GetS(1231) end
		elseif MyModsEditorType == 'furnace' then
			if not Current_Edit_FurnaceDef then return; end
		end
		--[[
		if def then
			ShowGameTips(GetS(3990, text), 3);
			return;
		end	
		]]
		if MyModsEditorType == 'block' then
			--LLDO:
			SetSingleEditorFrame('block', Current_Edit_BlockDef);				--新
			--SetNewSingleEditorFrame('block', Current_Edit_BlockDef, false);		--旧
		elseif MyModsEditorType == 'actor' then
			--SetNewSingleEditorFrame('actor', Current_Edit_ActorDef, false);
			SetSingleEditorFrame('actor', Current_Edit_ActorDef, false);
		elseif MyModsEditorType == 'item' then
			--SetNewSingleEditorFrame('item', Current_Edit_ItemDef, false);
            SetSingleEditorFrame('item', Current_Edit_ItemDef, false);
		elseif MyModsEditorType == 'craft' then
            SetSingleEditorFrame('craft', Current_Edit_CraftDef, false);
        elseif MyModsEditorType == 'furnace' then
            SetSingleEditorFrame('furnace', Current_Edit_FurnaceDef, false);
        elseif MyModsEditorType == 'plot' then
        	if not Current_Edit_NpcPlot then return; end
        	SetSingleEditorFrame('plot', Current_Edit_NpcPlot, false);
		end
	end

	getglobal("ChooseOriginalFrame"):Hide();
end

function ChooseOriginalFrameUpBtn_OnClick()
	local startIndex = getglobal("ChooseOriginalFrameTabs1"):GetClientID() - 4;
	SetChooseOriginalFrameTab(startIndex);
	UpdateUpDownStatus();
end

function ChooseOriginalFrameDownBtn_OnClick()
	local startIndex = getglobal("ChooseOriginalFrameTabs1"):GetClientID() + 4;
	SetChooseOriginalFrameTab(startIndex);
	UpdateUpDownStatus();

end

--selecttion:设置格子选择器
function SetChooseOriginalFrame(type)
	ChooseOriginalType = type;
	LoadOriginalDef();
	-- GetInst("ModsLibPkgManager"):FilterPkgDefs(t_OriginalInfo,3,ChooseOriginalType)

	local title = getglobal("ChooseOriginalFrameTitleFrameName");
	if ChooseOriginalType == 'itemmodel' then	--选择游戏原有的道具模型
		title:SetText(GetS(3759));
	elseif ChooseOriginalType == 'blockmodel' then
		title:SetText(GetS(4549));
	elseif ChooseOriginalType == 'actormodel' then
		title:SetText(GetS(3658));
	elseif ChooseOriginalType == 'dropitem' then
		title:SetText(GetS(3659));
	elseif ChooseOriginalType == 'craftresult' then
		title:SetText(GetS(3659));
	elseif ChooseOriginalType == 'craftmaterial' then
		title:SetText(GetS(3659));
	elseif ChooseOriginalType == 'furnaceresult' then
		title:SetText(GetS(3659));
	elseif ChooseOriginalType == 'furnacematerial' then
		title:SetText(GetS(3659));
	elseif ChooseOriginalType == 'projectilemodel' then
		title:SetText(GetS(3680));
	elseif ChooseOriginalType == 'projectile' then
		title:SetText(GetS(4542));
	elseif ChooseOriginalType == 'bullet' then
		title:SetText(GetS(4545));
	elseif ChooseOriginalType == 'craft_tool' then
		title:SetText(GetS(1553));	
	elseif ChooseOriginalType == 'atkbuff' then
		if SingleEditorFrame_Switch_New then
			local strType, id = GetInst("ModsLibSelectorMgr"):OpenSelector(7+1000, false);
			if strType == 'ok' then
				local index = getglobal(CurEditorUIName):GetParentFrame():GetClientID();
				local btnIdx = getglobal(CurEditorUIName):GetClientID();

				local t = modeditor.config[CurEditorClass][CurTabIndex].Attr[index];
				local icon = getglobal(CurEditorUIName.."Icon");
				local addIcon   = getglobal(CurEditorUIName.."AddIcon");
				local delBtn   = getglobal(CurEditorUIName.."Del");
				if not icon:IsShown() then
					icon:Show();
					addIcon:Hide();
					delBtn:Show();
				end

				local path = GetInst("ModsLibDataManager"):GetStatusIconPath(id);
				if path ~= "" then
					icon:SetTexture(path, true)
				end
				t.CurVal[btnIdx] = id;
			end
			return;
		else
			title:SetText(GetS(1142));
		end
	elseif ChooseOriginalType == 'featureai' then
		title:SetText(GetS(6300));
	elseif ChooseOriginalType == 'featureitemskill' then
		title:SetText(GetS(8506));
	elseif ChooseOriginalType == 'ai_actor' then
		title:SetText(GetS(6317));
	elseif ChooseOriginalType == 'ai_block' then
		title:SetText(GetS(6316));
	elseif ChooseOriginalType == 'ai_food' then
		if MyModsEditorType == 'actor' then
			title:SetText(GetS(6318));   
		elseif MyModsEditorType == 'item' then
			title:SetText(GetS(8625));   
		end
	elseif ChooseOriginalType == 'ai_buff' then
		if SingleEditorFrame_Switch_New then
			local isEditModLIb = false  -- 当前编辑的是否是地图插件库内插件
			local CurEditMod = ModEditorMgr:getCurrentEditMod()
			if CurEditMod then
				isEditModLIb = not CurEditMod:isExportMod() -- 当前编辑的插件包是否是导入的插件包
			end
			local strType, id = GetInst("ModsLibSelectorMgr"):OpenSelector(7+1000, false,nil,nil,isEditModLIb);
			if strType == 'ok' then
				local feature_item_data = CurEditFeatureItemData
				local feature_item_uidata = GetFeatureTableItem(feature_item_data.name)
				local param_uidata = feature_item_uidata.Parameters[CurEditFeatureParamIndex]

				param_uidata.Save(feature_item_data, param_uidata.Name, id)
				if GetInst("UIManager"):GetCtrl("ModsLibFeatureEdit") then
					GetInst("UIManager"):GetCtrl("ModsLibFeatureEdit"):RefreshByParam();
				end
			end
			return;
		else
			title:SetText(GetS(1142));
		end
    elseif ChooseOriginalType == 'ai_projectile' then	
		title:SetText(GetS(8613));	
	elseif ChooseOriginalType == 'ai_container' then
		title:SetText(GetS(4684));
	elseif ChooseOriginalType == 'ai_craft' then
		title:SetText(GetS(4691));
	elseif ChooseOriginalType == 'ai_targetblock' then
		title:SetText(GetS(4686));
	elseif ChooseOriginalType == 'ai_useitem' then
		title:SetText(GetS(4630));
	elseif ChooseOriginalType == 'ai_dropitem' then
		title:SetText(GetS(3659));
	elseif ChooseOriginalType == "PlotIcon" then
		--标题:请选择图标
		title:SetText(GetS(11041));
	elseif ChooseOriginalType == "PlotItemID" then
		--标题:请选择道具
		title:SetText(GetS(8625));
	elseif ChooseOriginalType == "PlotInteractID" then
		title:SetText(GetS(4676));
	elseif ChooseOriginalType == "TaskContents_Monster" then
		title:SetText(GetS(6317));
	elseif ChooseOriginalType == "TaskContents_Item" then
		title:SetText(GetS(3659));
	elseif ChooseOriginalType == 'transferticket' then
		title:SetText(GetS(3659));
	elseif ChooseOriginalType == 'transferban' then
		title:SetText(GetS(3659));
	elseif ChooseOriginalType == 'StoreItem' then
		title:SetText(GetS(3659));
	elseif ChooseOriginalType == "StoreAddItem" then
		title:SetText(GetS(3659));
	elseif ChooseOriginalType == "PackAddItem" then
		title:SetText(GetS(3659));
	else
		if MyModsEditorType == 'block' then
			title:SetText(GetS(3960, GetS(3931)));
		elseif MyModsEditorType == 'actor' then
			title:SetText(GetS(3960, GetS(3932)));
		elseif MyModsEditorType == 'item' then
			title:SetText(GetS(3960, GetS(3933)));
		elseif MyModsEditorType == 'craft' then
			title:SetText(GetS(3960, GetS(1231)));
		elseif MyModsEditorType == 'furnace' then
			title:SetText(GetS(3960, GetS(1230)));
		elseif MyModsEditorType == 'plot' then
			--标题:请选择一个剧情进行修改
			title:SetText(GetS(3960, GetS(11006)));
		end
	end

	if next(t_OriginalInfo) == nil then 
		ShowGameTips(GetS(3758), 3);
		return 
	else
		CurEditorType = t_OriginalInfo[1].EditType;
	end
	SetChooseOriginalFrameTab(1);
	UpdateUpDownStatus();
	getglobal("ChooseOriginalFrame"):Show();
end

function SetChooseOriginalFrameTab(startIndex)
	Log("SetChooseOriginalFrameTab startIndex:"..startIndex);
	local num = #(t_OriginalInfo);
    local cur_num = 0;

	for i=1, 8 do
		local index = startIndex+i-1;
		local tab = getglobal("ChooseOriginalFrameTabs"..i);
		local name = getglobal("ChooseOriginalFrameTabs"..i.."Name");
		tab:SetClientID(index);

		local normal 	= getglobal("ChooseOriginalFrameTabs"..i.."Normal");
		local checked 	= getglobal("ChooseOriginalFrameTabs"..i.."Checked");

		if t_OriginalInfo[index] and t_OriginalInfo[index].EditType == CurEditorType then
			name:SetTextColor(76, 76, 76);
			normal:Hide();
			checked:Show();
		else
			name:SetTextColor(55, 54, 48);
			normal:Show();
			checked:Hide();
		end

		if gIsSingleGame and i == 4 then
			if ChooseOriginalType == 'actormodel' then
				tab = getglobal("ChooseOriginalFrameTabs4")
				if tab then
					tab:SetPoint("top", "ChooseOriginalFrameTabs3", "top", 0, 0)
				end
			else
				tab = getglobal("ChooseOriginalFrameTabs4")
				if tab then
					tab:SetPoint("top", "ChooseOriginalFrameTabs3", "top", 0, 72)
				end
			end
		end

		if index <= num and cur_num < 5 then
            cur_num = cur_num + 1
			tab:Show();
			local editType = t_OriginalInfo[index].EditType;
			if ChooseOriginalType == 'itemmodel' or ChooseOriginalType == 'actormodel' or ChooseOriginalType == 'projectilemodel' then	--选择游戏原有的道具模型
				if IsAvatarTab(editType) then
					--如果是定制装扮页签，设置页签名为定制装扮
					name:SetText(GetS(9246))
					if gIsSingleGame then
						tab:Hide()
					end
				elseif ChooseOriginalType == 'itemmodel' and editType >= 4  then
					--装备
					name:SetText(GetS(t_EditorTypesId.item[editType]));
				elseif ChooseOriginalType == 'actormodel' and (editType == 5 or editType == 6) then
					name:SetText(GetS(t_EditorTypesId.actor[editType]));
				else
					name:SetText(GetS(t_OriginalInfo[index].t[1].ClassNameID))
				end 
			elseif ChooseOriginalType == 'dropitem' or ChooseOriginalType == 'ai_dropitem' or ChooseOriginalType == "PlotItemID" or ChooseOriginalType == "TaskContents_Item" or ChooseOriginalType =="StoreItem" or ChooseOriginalType == "StoreAddItem" or ChooseOriginalType == "PackAddItem" then
				name:SetText(GetS(t_EditorTypesId.dropitem[editType]));
			elseif ChooseOriginalType == 'transferticket' or ChooseOriginalType == 'transferban' then
				name:SetText(GetS(t_EditorTypesId.transfer[editType]));
			elseif ChooseOriginalType == 'craftresult' then
				name:SetText(GetS(t_EditorTypesId.craftresult[editType]));
			elseif ChooseOriginalType == 'craftmaterial' then
				name:SetText(GetS(t_EditorTypesId.craftmaterial[editType]));
			elseif ChooseOriginalType == 'furnaceresult' then
				name:SetText(GetS(t_EditorTypesId.furnaceresult[editType]));
			elseif ChooseOriginalType == 'furnacematerial' then
				name:SetText(GetS(t_EditorTypesId.furnacematerial[editType]));
			elseif ChooseOriginalType == 'projectile' then
				name:SetText(GetS(t_EditorTypesId.projectile[editType]));
			elseif ChooseOriginalType == 'bullet' then
				name:SetText(GetS(t_EditorTypesId.bullet[editType]));
			elseif ChooseOriginalType == 'atkbuff' then
				name:SetText(GetS(t_OriginalInfo[index].t[1].AtkEffectTypeSID));
			elseif ChooseOriginalType == 'featureai' then
				name:SetText(GetS(6301));
			elseif ChooseOriginalType == 'featureitemskill' then
				if editType == 1 then
 				   name:SetText(GetS(8507));
				elseif editType == 2 then
				   name:SetText(GetS(8508));
				end
			elseif ChooseOriginalType == 'ai_block' then                
				name:SetText(GetS(t_EditorTypesId.ai_block[editType]));
			elseif ChooseOriginalType == 'ai_actor' or ChooseOriginalType == "PlotInteractID" or ChooseOriginalType == "TaskContents_Monster" then                
				name:SetText(GetS(t_EditorTypesId.ai_actor[editType]));
			elseif ChooseOriginalType == 'ai_food' then
				name:SetText(GetS(t_EditorTypesId.ai_food[editType]));
			elseif ChooseOriginalType == 'ai_buff' then
				name:SetText(GetS(t_OriginalInfo[index].t[1].AtkEffectTypeSID));
			elseif ChooseOriginalType == 'ai_projectile' then
				name:SetText(GetS(t_EditorTypesId.projectile[editType]));
			elseif ChooseOriginalType == 'ai_container' then
				--:new add:箱子tab按钮标题
				name:SetText(GetS(t_EditorTypesId.ai_container[editType]));
			elseif ChooseOriginalType == 'ai_craft' then
				--:new add:配方tab按钮标题
				name:SetText(GetS(t_EditorTypesId.ai_craft[editType]));
			elseif ChooseOriginalType == 'ai_targetblock' then
				name:SetText(GetS(t_EditorTypesId.ai_targetblock[editType]));
			elseif ChooseOriginalType == 'ai_useitem' then
				name:SetText(GetS(t_EditorTypesId.ai_useitem[editType]));
			elseif ChooseOriginalType == "PlotIcon" then		--剧情图标
				Log("plot: 222: PlotIcon:");
				name:SetText(GetS(t_EditorTypesId.PlotIcon[editType]));
			-- elseif ChooseOriginalType == "TaskContents_Monster" then	--剧情触发目标
			-- 	name:SetText(GetS(t_EditorTypesId.PlotIcon[editType]));
			-- elseif ChooseOriginalType == "TaskContents_Item" then			--拥有道具 / 任务目标_道具
			-- 	Log("Tab:PlotItemID:editType = " .. editType);
			-- 	name:SetText(GetS(t_EditorTypesId.PlotItemID[editType]));
			elseif ChooseOriginalType == "craft_tool" then		--剧情图标
				name:SetText(GetS(t_EditorTypesId.craft_tool[editType]));
			else
				if MyModsEditorType == 'block' then
					name:SetText(GetS(t_EditorTypesId.block[editType]));
				elseif MyModsEditorType == 'actor' then
					name:SetText(GetS(t_EditorTypesId.actor[editType]));
				elseif MyModsEditorType == 'item' then
					name:SetText(GetS(t_EditorTypesId.item[editType]));
				elseif MyModsEditorType == 'craft' then
					name:SetText(GetS(t_EditorTypesId.craft[editType]));
				elseif MyModsEditorType == 'furnace' then
					name:SetText(GetS(t_EditorTypesId.furnace[editType]));
				elseif MyModsEditorType == 'plot' then
					--预设
					name:SetText(GetS(11021));
				end	
			end
		else
			tab:Hide();
		end
	end
end

function UpdateUpDownStatus()
	local num = #(t_OriginalInfo);
	local id = getglobal("ChooseOriginalFrameTabs1"):GetClientID();
	Log("UpdateUpDownStatus id"..id);
	if id >= 5 then
		getglobal("ChooseOriginalFrameTabsUpBtn"):Show();
	else
		getglobal("ChooseOriginalFrameTabsUpBtn"):Hide();
	end

	if (id+5) <= num then
		getglobal("ChooseOriginalFrameTabsDownBtn"):Show();
	else
		getglobal("ChooseOriginalFrameTabsDownBtn"):Hide();
	end 
end

function ChooseOriginalFrame_OnLoad()
	for i=1, Max_OriginalBlock_Num/9 do
		for j=1, 9 do
			local index = (i-1)*9+j;
			local grid = getglobal("OriginalGrid"..index);
			grid:SetPoint("topleft", "OriginalGridBoxPlane", "topleft", (j-1)*84, (i-1)*84);
		end
	end

	for i=1, 48/4 do
		for j=1, 4 do
			local index = (i-1)*4+j;
			local classUI = getglobal("ModCustomModelClassBoxClass"..index);
			classUI:SetPoint("topleft", "ModCustomModelClassBoxPlane", "topleft", (j-1)*187, (i-1)*225);
		end
	end

	for i=1, 440/8 do
		for j=1, 8 do
			local index = (i-1)*8+j;
			local itemUI = getglobal("ModCustomModelListBoxGrid"..((i-1)*8+j));
			itemUI:SetPoint("topleft", "ModCustomModelListBoxPlane", "topleft", (j-1)*92, (i-1)*92);
		end
	end

	--标题栏

end

--selecttion:展示格子
function ChooseOriginalFrame_OnShow()
	UpdateEditorOriginalBox(1); 
	SetModBoxsDeals(false);
	getglobal("ChooseOriginalFrameOkBtn"):SetClientID(0);
	getglobal("ChooseOriginalFrameOkBtn"):SetClientString("");
end

function ChooseOriginalFrame_OnHide()
	SetModBoxsDeals(true);
end

function GetTable2EditType(editType)
	for i=1, #(t_OriginalInfo) do
		if editType == t_OriginalInfo[i].EditType then
			return t_OriginalInfo[i].t;
		end
	end

	return nil
end

function SetTable2EditType(editType,t)
	for i=1, #(t_OriginalInfo) do
		if editType == t_OriginalInfo[i].EditType then
			t_OriginalInfo[i].t = t
			break 
		end
	end
end

function CanShowActorModel(def)
	print("kekeke CanShowActorModel RelevantID", def.RelevantID);

	if def.Class == 2 then --角色模型
		if GetInst("GeniusMgr"):IsOpenGeniusSys() then -- 新角色特长系统把角色换成了皮肤，没有角色
			return false
		end

		if AccountManager:getAccountData():getGenuisLv(def.RelevantID) > -1 then
			return true;
		end
		return false;
	elseif def.Class == 3 then --皮肤模型
		if AccountManager:getAccountData():getSkinTime(def.RelevantID) == -1 then --永久皮肤
			return true;
		end
		return false;
	else
		return true;
	end
end

--selecttion:加载选择器中格子定义
function LoadOriginalDef()
	Log("LoadOriginalDef:");
	t_OriginalInfo = {};	

	local t_Projectile = {};
    local t_ai_block = {}
    local t_ai_food = {}
    local t_ai_actor = {}
    local t_ai_container = {};
    local t_ai_targetblock = {};
    local t_dropitem = {}
    local t_ai_useitem = {};
    local t_ai_craft = {};
    local t_plot_icon = {};
    local t_plot_InteractID = {};
    local t_plot_ItemID = {};

    local t_transferitem = {};
	local num = 0;
	local needFilter = GetInst("ModsLibPkgManager"):IsNeedFilterCustomItem();
	local isEditModLIb = true  -- 当前编辑的是否是地图插件库内插件
	if ClientCurGame:isInGame() then
		local CurEditMod = ModEditorMgr:getCurrentEditMod()
		if CurEditMod then
			isEditModLIb = CurEditMod:isExportMod() -- 当前编辑的插件包是否是导入的插件包
		end
	end
	if ChooseOriginalType == 'itemmodel' or ChooseOriginalType == 'actormodel' or ChooseOriginalType == 'projectilemodel' then	--选择游戏原有的道具模型
		num = ModEditorMgr:getModModelDefCount();
	elseif ChooseOriginalType == 'dropitem' or ChooseOriginalType == 'ai_dropitem' or ChooseOriginalType == 'craftresult' or ChooseOriginalType == 'craftmaterial' or 
			ChooseOriginalType == 'furnaceresult' or ChooseOriginalType == 'furnacematerial' or ChooseOriginalType  == "PlotItemID" or ChooseOriginalType == "TaskContents_Item"  or 
			ChooseOriginalType == "StoreItem" or ChooseOriginalType == "StoreAddItem" or ChooseOriginalType == "PackAddItem" then
				
			local iNum = ItemDefCsv:getNum();
			for i=1, iNum do
				local def = ItemDefCsv:get(i-1);
				if def  then
					if def.CopyID <= 0 then
						if ModEditorMgr:getItemDefById(def.ID) then
							def = ModEditorMgr:getItemDefById(def.ID)
						end
						table.insert(t_dropitem, {Type=def.DropType, Def = def});
					end
				end
			end
	
			if needFilter then
				local list = GetInst("ModsLibPkgManager"):SelectCustomBlockPlugins();
				for index, value in ipairs(list) do
					local def = ModEditorMgr:getBlockItemDefById(value.ID);
					if def and def.CopyID > 0 then
						table.insert(t_dropitem, {Type=5, Def = def});
					end
				end
				list = GetInst("ModsLibPkgManager"):SelectCustomItemPlugins();
				for index, value in ipairs(list) do
					local def = ModEditorMgr:getItemDefById(value.ID);
					if def and def.CopyID > 0 then
						table.insert(t_dropitem, {Type=5, Def = def});
					end
				end
			else
				 --自定义全部道具
				iNum = isEditModLIb and ModEditorMgr:getCustomItemCount() or ModMgr:getItemCountEx()
				for i=1, iNum do
					local def = isEditModLIb and ModEditorMgr:getItemDef(i-1) or ModMgr:tryGetItemDefByIndexEx(i-1)
					if def and def.CopyID > 0 and def.Type ~= ITEM_TYPE_BLOCK then
						table.insert(t_dropitem, {Type=5, Def = def});
					end
				end
				--自定义全部方块
				iNum = isEditModLIb and ModEditorMgr:getCustomBlockCount() or ModMgr:getBlockCountEx()
				for i=1, iNum do
					local def = isEditModLIb and ModEditorMgr:getBlockDef(i-1) or ModMgr:tryGetBlockDefByIndexEx(i-1)
					if def and def.CopyID > 0 then
						table.insert(t_dropitem, {Type=5, Def = def});
					end
				end
			end
			num = #(t_dropitem);
	elseif ChooseOriginalType == 'transferticket' or ChooseOriginalType == 'transferban' then
		local iNum = ItemDefCsv:getNum();
        for i=1, iNum do
			local def = ItemDefCsv:get(i-1);
			if def then
                table.insert(t_transferitem, {Type=def.DropType, Def = def});
			end
        end

		local iNum = ModMgr:getItemCount();
        for i=1, iNum do
        	local def = ModMgr:tryGetItemDefByIndex(i-1)
			if def then
                if ModMgr:tryGetItemDef(def.ID) then
                    def = ModMgr:tryGetItemDef(def.ID)
                    if def.CopyID > 0 then	--排除生物蛋item
                    	table.insert(t_transferitem, {Type=5, Def = def});
                    end
                end 
			end
        end
		num = #(t_transferitem);
	elseif ChooseOriginalType == 'projectile' or ChooseOriginalType == 'bullet' or ChooseOriginalType == 'ai_projectile' then
		local iNum = ProjectileDefCsv:getNum();
		for i=1, iNum do
			local def = ProjectileDefCsv:getByIndex(i-1);
			if def and def.BeAmmunition == 1 then
				table.insert(t_Projectile, {Type=1, Def = def});
			end
        end
        if needFilter then
            local list = GetInst("ModsLibPkgManager"):SelectCustomItemPlugins();
			for index, value in ipairs(list) do
				local itemDef = ModEditorMgr:getItemDefById(value.ID);
                if itemDef and (itemDef.Type == ITEM_TYPE_PROJECTILE or itemDef.Type == ITEM_TYPE_TOOL_PROJECTILE) then
                    local def = ModEditorMgr:getProjectileDefById(itemDef.ID);
                    if def and itemDef.CopyID > 0 then
                        table.insert(t_Projectile, {Type=2, Def = def});
                    end
                end
			end
		else
			local iNum = isEditModLIb and ModEditorMgr:getCustomItemCount() or ModMgr:getItemCountEx()
			for i=1, iNum do
				local itemDef = isEditModLIb and ModEditorMgr:getItemDef(i-1) or ModMgr:tryGetItemDefByIndexEx(i-1)
                if itemDef and (itemDef.Type == ITEM_TYPE_PROJECTILE or itemDef.Type == ITEM_TYPE_TOOL_PROJECTILE) then
                    local def = ModEditorMgr:getProjectileDefById(itemDef.ID);
                    if def and itemDef.CopyID > 0 then
                        table.insert(t_Projectile, {Type=2, Def = def});
                    end
                end
            end
        end
		num = #(t_Projectile);
	elseif ChooseOriginalType == 'atkbuff' or ChooseOriginalType == 'ai_buff' then
		-- if UseNewModsLib then
		-- 	num = DefMgr:getStatusNum();
		-- else
		-- 	num = DefMgr:getBuffDefNum();
		-- end
		num = 0
	elseif ChooseOriginalType == 'featureai' then
        --特性AI数据不是从def表中获取，而是从lua配置中获取
		table.insert(t_OriginalInfo, {EditType=3, t=OpenAiTable.GetSortOpenFeature2Class(3)});
        --print("---------------------------dodo")
        --print(t_OriginalInfo[1].t)
        return
	elseif ChooseOriginalType == 'featureitemskill' then
		if GetCurrentEditDef().Type == 8 or GetCurrentEditDef().Type == 12 then
			table.insert(t_OriginalInfo, {EditType=2, t=ItemSkillTable.GetSortOpenFeature2Class(2)});--?????
		else 
			table.insert(t_OriginalInfo, {EditType=1, t=ItemSkillTable.GetSortOpenFeature2Class(1)});--???????
		end
		return
	elseif ChooseOriginalType == 'ai_actor' or ChooseOriginalType == "PlotInteractID" or ChooseOriginalType == "TaskContents_Monster" then
		Log("LoadOriginalDef:ai_actor:111:");
        --系统生物
		if MyModsEditorType == 'actor' or MyModsEditorType == 'plot' then
			for i=1, #(AiParameterActors) do
				for j=1, #(AiParameterActors[i].t) do
					local def = ModEditorMgr:getMonsterDefById(AiParameterActors[i].t[j]) or MonsterCsv:get(AiParameterActors[i].t[j])
					if def then
						table.insert(t_ai_actor, {Type=AiParameterActors[i].EditType, Def = def});
					end
				end
			end
		elseif MyModsEditorType == 'item' then
			for i=1, #(ItemSkillParameterActors) do
				for j=1, #(ItemSkillParameterActors[i].t) do
					local def = ModEditorMgr:getMonsterDefById(ItemSkillParameterActors[i].t[j]) or MonsterCsv:get(ItemSkillParameterActors[i].t[j])
					if def then
						table.insert(t_ai_actor, {Type=ItemSkillParameterActors[i].EditType, Def = def});
					end
				end
			end
		end
		if needFilter then
			local list = GetInst("ModsLibPkgManager"):SelectCustomActorPlugins();
			for index, value in ipairs(list) do
				local def = ModEditorMgr:getMonsterDefById(value.ID);
				if def and def.CopyID > 0 then
					table.insert(t_ai_actor, {Type=2, Def = def});
				end
			end
		else
			--自定义生物
			local iNum = isEditModLIb and ModEditorMgr:getCustomMonsterCount() or ModMgr:getMonsterCountEx()
			for i=1, iNum do
				local def = isEditModLIb and ModEditorMgr:getMonsterDef(i-1) or ModMgr:tryGetMonsterDefByIndexEx(i-1)
				if def and def.CopyID > 0 then
					table.insert(t_ai_actor, {Type=2, Def = def});
				end
			end
		end
		num = #(t_ai_actor);
	elseif ChooseOriginalType == 'ai_block' then
		--系统方块
		if MyModsEditorType == 'actor' then
			for i=1, #(AiParameterBlocks) do
				for j=1, #(AiParameterBlocks[i].t) do
					local def = BlockDefCsv:get(AiParameterBlocks[i].t[j])
					if def then
						if ModEditorMgr:getBlockDefById(def.ID) then
							def = ModEditorMgr:getBlockDefById(def.ID)
						end
						table.insert(t_ai_block, {Type=AiParameterBlocks[i].EditType, Def = def});
					end
				end
			end
		elseif MyModsEditorType == 'item' then
			for i=1, #(ItemSkillParameterBlocks) do
				for j=1, #(ItemSkillParameterBlocks[i].t) do
					local def = BlockDefCsv:get(ItemSkillParameterBlocks[i].t[j])
					if def then
						if ModEditorMgr:getBlockDefById(def.ID) then
							def = ModEditorMgr:getBlockDefById(def.ID)
						end
						table.insert(t_ai_block, {Type=ItemSkillParameterBlocks[i].EditType, Def = def});
					end
				end
			end
		end
		if needFilter then
			local list = GetInst("ModsLibPkgManager"):SelectCustomBlockPlugins();
			for index, value in ipairs(list) do
				local def = ModEditorMgr:getBlockItemDefById(value.ID);
				if def and def.CopyID > 0 then
					table.insert(t_ai_block, {Type=5, Def = def});
				end
			end
		else
			 --自定义方块
			local iNum = isEditModLIb and ModEditorMgr:getCustomBlockCount() or ModMgr:getBlockCountEx()
			for i=1, iNum do
				local def = isEditModLIb and ModEditorMgr:getBlockDef(i-1) or ModMgr:tryGetBlockDefByIndexEx(i-1)
				if def and def.CopyID > 0 then
					table.insert(t_ai_block, {Type=5, Def = def});
				end
			end
		end
		num = #(t_ai_block);
	elseif ChooseOriginalType == 'ai_food' then
		local TypeHaveSet = 1;
		if MyModsEditorType == 'actor' then
		    --系统食物
			for i=1, #(AiParameterFoods) do
				for j=1, #(AiParameterFoods[i].t) do
					local def = ModEditorMgr:getItemDefById(AiParameterFoods[i].t[j]) or ItemDefCsv:get(AiParameterFoods[i].t[j])
					if def then
						table.insert(t_ai_food, {Type=AiParameterFoods[i].EditType, Def = def});
					end
				end
				TypeHaveSet = AiParameterFoods[i].EditType + 1
			end
            if needFilter then
                local list = GetInst("ModsLibPkgManager"):SelectCustomItemPlugins();
                for index, value in ipairs(list) do
                    local def = ModEditorMgr:getItemDefById(value.ID);
                    if def and def.CopyID > 0 and def.Type == ITEM_TYPE_FOOD then
                        table.insert(t_ai_food, {Type=TypeHaveSet, Def = def});
                    end
                end
			else
				local iNum = isEditModLIb and ModEditorMgr:getCustomItemCount() or ModMgr:getItemCountEx()
                for i=1, iNum do
                    local def = isEditModLIb and ModEditorMgr:getItemDef(i-1) or ModMgr:tryGetItemDefByIndexEx(i-1)
                    if def and def.CopyID > 0 and def.Type == ITEM_TYPE_FOOD then
                        table.insert(t_ai_food, {Type=TypeHaveSet, Def = def});
                    end
                end
            end
		elseif MyModsEditorType == 'item' then
			--系统食物
			for i=1, #(ItemSkillParameterFoods) do
				for j=1, #(ItemSkillParameterFoods[i].t) do
					local def = ModEditorMgr:getItemDefById(ItemSkillParameterFoods[i].t[j]) or ItemDefCsv:get(ItemSkillParameterFoods[i].t[j])
					if def then
						table.insert(t_ai_food, {Type=ItemSkillParameterFoods[i].EditType, Def = def});
					end
				end
				TypeHaveSet = ItemSkillParameterFoods[i].EditType + 1
			end
			--自定义全部物品
            if needFilter then
                local list = GetInst("ModsLibPkgManager"):SelectCustomItemPlugins();
                for index, value in ipairs(list) do
                    local def = ModEditorMgr:getItemDefById(value.ID);
                    if def and def.CopyID > 0 then
                        table.insert(t_ai_food, {Type=TypeHaveSet, Def = def});
                    end
                end
            else
                local iNum = isEditModLIb and ModEditorMgr:getCustomItemCount() or ModMgr:getItemCountEx()
                for i=1, iNum do
                    local def = isEditModLIb and ModEditorMgr:getItemDef(i-1) or ModMgr:tryGetItemDefByIndexEx(i-1)
                    if def and def.CopyID > 0 then
                        table.insert(t_ai_food, {Type=TypeHaveSet, Def = def});
                    end
                end
            end
		end

		num = #(t_ai_food);
	elseif ChooseOriginalType == 'ai_container' then
		--LLDO:new add:箱子
		local TypeHaveSet = 1;
		if MyModsEditorType == 'actor' then
		    --系统食物
			for i=1, #(AiParameterContainer) do
				for j=1, #(AiParameterContainer[i].t) do
					local def = ModEditorMgr:getItemDefById(AiParameterContainer[i].t[j]) or ItemDefCsv:get(AiParameterContainer[i].t[j])
					if def then
						table.insert(t_ai_container, {Type=AiParameterContainer[i].EditType, Def = def});
					end
				end
				TypeHaveSet = AiParameterContainer[i].EditType + 1
			end
		end

		num = #(t_ai_container);
	elseif ChooseOriginalType == 'ai_craft' then
		--LLDO:new add:配方
		if MyModsEditorType == 'actor' then
		    num = DefMgr:getCraftingDefNum();
		    for i = 1, num do
				local def = DefMgr:getCraftingDefByIndex(i-1);
				if def then
					local EditType = 0
					if def.getTypeSize and def.getTypeValue then
						if def:getTypeSize() > 0 then
							EditType = def:getTypeValue(0)
						end
					elseif type(def.Type) == 'number' then
						EditType = def.Type
					end
					table.insert(t_ai_craft, {Type = EditType, Def = def});
				end
			end

			--自定义
			if  needFilter then
				local list = GetInst("ModsLibPkgManager"):SelectCustomCraftingPlugins();
				for index, value in ipairs(list) do
					local def = ModEditorMgr:getCraftingDefById(value.ID);
					if def and def.CopyID > 0 then
						table.insert(t_ai_craft, {Type=5, Def = def});
					end
				end
			else
				local num =  ModEditorMgr:getCustomCraftingCount();
				for i = 1, num do
					local def = ModEditorMgr:getCraftingDef(i -1);
					if def then
						table.insert(t_ai_craft, {Type = 5, Def = def});
					end
				end
			end
		end
		num = #(t_ai_craft);
	elseif ChooseOriginalType == 'ai_targetblock' then
		for i=1, #(AiParameterTargetBlock) do
			for j=1, #(AiParameterTargetBlock[i].t) do
				local def = BlockDefCsv:get(AiParameterTargetBlock[i].t[j])
				if def then
					if ModEditorMgr:getBlockDefById(def.ID) then
						def = ModEditorMgr:getBlockDefById(def.ID)
					end
					table.insert(t_ai_targetblock, {Type=AiParameterTargetBlock[i].EditType, Def = def});
				end
			end
		end
		num = #(t_ai_targetblock);
	elseif ChooseOriginalType == 'ai_useitem' then
		for i=1, #(AiParameterUseItem) do
			for j=1, #(AiParameterUseItem[i].t) do
				local id = AiParameterUseItem[i].t[j];
				local def = ModEditorMgr:getItemDefById(id) or ModEditorMgr:getBlockItemDefById(id) or ItemDefCsv:get(id);
				if def then
					table.insert(t_ai_useitem, {Type=AiParameterUseItem[i].EditType, Def = def});
				end
			end
		end
		num = #(t_ai_useitem);
	elseif ChooseOriginalType == 'craft_tool' then
		local toolNum = ToolDefCsv:getNum()
		local toolType2tabType = {[27] = 1,[28] = 2};
		for i = 1, toolNum do
			local def = ToolDefCsv:getByIndex(i - 1);
			if def and (def.Type == 27 or def.Type == 28) then
				local itemDef = ItemDefCsv:get(def.ID)
				if itemDef then
					table.insert(t_dropitem,{Type = toolType2tabType[def.Type],Def = def})
				end
			end
		end
		num = #t_dropitem;		
	else										--选择游戏原有的东东进行修改
		if MyModsEditorType == 'block' then
			num = BlockDefCsv:getNum();
		elseif MyModsEditorType == 'actor' then
			num = MonsterCsv:getNum();
		elseif MyModsEditorType == 'item' then
			num = ItemDefCsv:getNum();
		elseif MyModsEditorType == 'craft' then
			num = DefMgr:getCraftingDefNum();
		elseif MyModsEditorType == 'furnace' then
			num = DefMgr:getFurnaceDefNum();
		elseif MyModsEditorType == 'plot' then
			--LLTODO:剧情相关格子选择
			Log("plot: 111")
			num = 0;
			if ChooseOriginalType == "PlotIcon" then				--图标
				Log("PlotIcon:");
				num = ModEditorMgr:getModModelDefCount();
				for i = 1, num do
					def = ModEditorMgr:getModModelDef(i - 1);
					if def and def.Type == 2 and def.Class == 1 then
						table.insert(t_plot_icon, {Def = def, Type = 1});
					end
				end

				num = ItemDefCsv:getNum();			--2.道具
				for i = 1, num do
					def = ItemDefCsv:get(i-1);
					if def and def.EditType > 0 then
						table.insert(t_plot_icon, {Def = def, Type = 2});
					end
				end

				num = #(t_plot_icon);
				Log("num = " .. num);
			else
				--修改原版剧情
				num = DefMgr:getNpcPlotDefNum();
			end
		end
	end

	for i=1, num do
		local def = nil;
		local type;
		if ChooseOriginalType == 'itemmodel' then
			def = ModEditorMgr:getModModelDef(i);
			if def and def.Type == 1 then
				type = def.Class;
			else
				def = nil;
			end
		elseif ChooseOriginalType == 'actormodel' then
			def = ModEditorMgr:getModModelDef(i);
			if def and def.Type == 2 and CanShowActorModel(def) then
				type = def.Class;
			else
				def = nil;
			end
		elseif ChooseOriginalType == 'dropitem' or ChooseOriginalType == 'ai_dropitem' or ChooseOriginalType == 'craftresult' or ChooseOriginalType == 'craftmaterial' or 
				ChooseOriginalType == 'furnaceresult' or ChooseOriginalType == 'furnacematerial' or ChooseOriginalType  == "PlotItemID" or ChooseOriginalType == "TaskContents_Item" or 
				ChooseOriginalType == "StoreItem" or ChooseOriginalType =="StoreAddItem" or ChooseOriginalType == "PackAddItem"  or ChooseOriginalType == "craft_tool" then

			def = t_dropitem[i].Def;
			type = t_dropitem[i].Type;  
		elseif ChooseOriginalType == 'transferticket' or ChooseOriginalType == 'transferban' then
			def = t_transferitem[i].Def;
			type = t_transferitem[i].Type;      
		elseif ChooseOriginalType == 'projectilemodel' then
			def = ModEditorMgr:getModModelDef(i);
			if def and def.Type == 3 then
				type = def.Class;
			else
				def = nil;
			end
		elseif ChooseOriginalType == 'projectile' or ChooseOriginalType == 'bullet' or ChooseOriginalType == 'ai_projectile' then
			def = t_Projectile[i].Def;
			type = t_Projectile[i].Type;
		elseif ChooseOriginalType == 'atkbuff' or ChooseOriginalType == 'ai_buff' then
			if UseNewModsLib then
				def = DefMgr:getStatusDefByIndex(i-1)
			else
				def = DefMgr:getBuffDefByIndex(i-1);
			end
			if def and def.AtkEffectTypeSID > 0 then
				type = def.AtkEffectTypeSID;
			else
				def = nil;
			end
        elseif ChooseOriginalType == 'ai_actor' or ChooseOriginalType == "PlotInteractID"  or ChooseOriginalType == "TaskContents_Monster" then        
        	Log("LoadOriginalDef: ai_actor:");
			def = t_ai_actor[i].Def;
			type = t_ai_actor[i].Type;
        elseif ChooseOriginalType == 'ai_block' then
			def = t_ai_block[i].Def;
			type = t_ai_block[i].Type;
        elseif ChooseOriginalType == 'ai_food' then
			def = t_ai_food[i].Def;
			type = t_ai_food[i].Type;
		elseif ChooseOriginalType == 'ai_container' then
			def = t_ai_container[i].Def;
			type = t_ai_container[i].Type;
		elseif ChooseOriginalType == 'ai_craft' then
			Log("LoadOriginalDef: ai_craft");
			-- def = DefMgr:getCraftingDefByIndex(i-1);
			-- if def then
			-- 	type = def.EditType;
			-- end
			def = t_ai_craft[i].Def;
			type = t_ai_craft[i].Type;
		elseif ChooseOriginalType == 'ai_targetblock' then
			def = t_ai_targetblock[i].Def;
			type = t_ai_targetblock[i].Type;
		elseif ChooseOriginalType == 'ai_useitem' then
			def = t_ai_useitem[i].Def;
			type = t_ai_useitem[i].Type;
		elseif ChooseOriginalType == "PlotIcon" then		--剧情图标
			Log("plot: 222: PlotIcon:");
			def = t_plot_icon[i].Def;
			type = t_plot_icon[i].Type;
		-- elseif ChooseOriginalType == "TaskContents_Monster" then	--剧情触发目标
		-- 	def = t_plot_InteractID[i].Def;
		-- 	type = t_plot_InteractID[i].Type;
		-- elseif ChooseOriginalType == "TaskContents_Item" then	--剧情拥有道具, ->改成和dropitem一样
		-- 	def = t_plot_ItemID[i].Def;
		-- 	type = t_plot_ItemID[i].Type;
		else
			if MyModsEditorType == 'block' then
				def = BlockDefCsv:get(i-1, false);
			elseif MyModsEditorType == 'actor' then
				def = MonsterCsv:getByIndex(i-1)
			elseif MyModsEditorType == 'item' then
				def = ItemDefCsv:get(i-1);
                if def and ((def.UnlockFlag > 0 and not isItemUnlockByItemId(def.ID)) or def.Type == ITEM_TYPE_BLOCK) then
                    def = nil
                end
			elseif MyModsEditorType == 'craft' then
				def = DefMgr:getCraftingDefByIndex(i-1)
			elseif MyModsEditorType == 'furnace' then
				def = DefMgr:getFurnaceDefByIndex(i-1)
			elseif MyModsEditorType == 'plot' then
				def = DefMgr:getNpcPlotDefByIndex(i - 1);
				Log("LoadNpcPlotDef:");
				Log("id = " .. def.ID);
				Log("EditType = " .. def.EditType);
				if (not def.IsTemplate) or def.CopyID > 0 then
					def = nil;
				end
			end
			if def then
				type = def.EditType;
			end
		end
		if def and type > 0 then
			Log("LoadOriginalDef ID"..def.ID);
			local t = GetTable2EditType(type)
			if t == nil then
				table.insert(t_OriginalInfo, {EditType=type, t={def}});
			else
				table.insert(t, def);
			end
		end
	end

	local greaterNum = 0;
    if ChooseOriginalType == 'blockmodel' then
        -- 游戏内显示当前地图库
        if ClientCurGame:isInGame() then
        	if not GetInst("ModsLibPkgManager"):CheckIsEditPluginInPkg() then
	        	table.insert(t_OriginalInfo, {EditType=t_EditorTypesName.block.curmap, t="currentmapblockmodel"});
	        elseif GetInst("ModsLibPkgManager"):GetIsEditPluginInMapModPkg() then
	        	table.insert(t_OriginalInfo, {EditType=t_EditorTypesName.block.curmap, t="currentmapblockmodel"});
	        end 
        end
        table.insert(t_OriginalInfo, {EditType=t_EditorTypesName.block.resLib, t="customblockmodel"});
	elseif ChooseOriginalType == 'itemmodel' then
		-- 这里需要开关控制下
		if SingleEditorFrame_Switch_New then
			--TODO:预设装备自定义模型
			table.insert(t_OriginalInfo, {EditType=t_EditorTypesName.item.equip, t="custommodel_equip"});
		end
        -- 游戏内显示当前地图库
        if ClientCurGame:isInGame() then
        	if not GetInst("ModsLibPkgManager"):CheckIsEditPluginInPkg() then
	        	table.insert(t_OriginalInfo, {EditType=t_EditorTypesName.item.curmap, t="currentmapitemmodel"});
	        elseif GetInst("ModsLibPkgManager"):GetIsEditPluginInMapModPkg() then
	        	table.insert(t_OriginalInfo, {EditType=t_EditorTypesName.item.curmap, t="currentmapitemmodel"});
	        end 
        end
        table.insert(t_OriginalInfo, {EditType=t_EditorTypesName.item.resLib, t="customitemmodel"});
    elseif ChooseOriginalType == 'actormodel' then
		local num = RoleSkinCsv:getNum();
		for i=1, num do
			local skinDef = RoleSkinCsv:getByIndex(i-1);
			if skinDef and AccountManager:getAccountData():getSkinTime(skinDef.ID) == -1 then
				local t = GetTable2EditType(3)
				if t == nil then
					table.insert(t_OriginalInfo, {EditType=t_EditorTypesName.actor.others, t={{ID=skinDef.ID, RelevantID=skinDef.ID, ClassNameID=4787}}});
				else
					table.insert(t, {ID=skinDef.ID, RelevantID=skinDef.ID, ClassNameID=4787});
				end
			end
		end

		-- 坐骑 chenweiTODO 新增坐骑模型
		local horseInfos = AccountManager:getAccountData():getHorse_all();
		for i=1, #horseInfos do
			local horseInfo = horseInfos[i]
			local editType = MONSTER_HORSE_MODEL -- 生物类型
			local horseID = horseInfo.RiderID -- 基础坐骑ID
			local stringID = 4788
			local level = horseInfo.RiderLevel -- 坐骑等级
			
			for curLv = 1, level do -- 升级前的坐骑模型也算进去
				local realHorseId = horseID + curLv
				local horseDef = DefMgr:getHorseDef(realHorseId)
				local t = GetTable2EditType(editType)

				local mobdef = DefMgr:getMonsterDef(realHorseId)
				if horseDef.HorseType ~= 1 and mobdef and mobdef.TriggerType ~= 0 then -- 判定坐骑不是变形坐骑
					if t == nil then
						table.insert(t_OriginalInfo, {EditType = editType,
													  t={{ID = realHorseId, RelevantID = realHorseId, ClassNameID = stringID}}
						});
					else
						table.insert(t, {ID = realHorseId, RelevantID = realHorseId, ClassNameID = stringID});
					end
				end
			end
		end

		-- 游戏内显示当前地图库
        if ClientCurGame:isInGame() then
        	if not GetInst("ModsLibPkgManager"):CheckIsEditPluginInPkg() then
	        	table.insert(t_OriginalInfo, {EditType=t_EditorTypesName.actor.curmap, t="currentmapactormodel"});
        		greaterNum = greaterNum+1;
	        elseif GetInst("ModsLibPkgManager"):GetIsEditPluginInMapModPkg() then
	        	table.insert(t_OriginalInfo, {EditType=t_EditorTypesName.actor.curmap, t="currentmapactormodel"});
        		greaterNum = greaterNum+1;
	        end 
        end
		table.insert(t_OriginalInfo, {EditType=t_EditorTypesName.actor.resLib, t="customactormodel"});
		greaterNum = greaterNum+1;
    end

	--检查是否需要增加定制装扮的TAB
	CheckAvatarExtraTab(greaterNum)

	table.sort(t_OriginalInfo, function(a, b) return a.EditType < b.EditType end);

	Log("LoadOriginalDef");
end

--selecttion:格子展示
local t_ResModelClass = {};
local CurModSelModelUIName = nil; --当前选中的微雕模型的格子控件名
function UpdateEditorOriginalBox(index) 
	CurEditorType = t_OriginalInfo[index].EditType;
	if CheckedOBName then
		getglobal(CheckedOBName.."Checked"):Hide();
	end
	getglobal("OriginalGridBox"):resetOffsetPos();

	local t = GetTable2EditType(CurEditorType);
	if t == nil then
		ShowGameTips(GetS(3758), 3);
		getglobal("ChooseOriginalFrame"):Hide();
		return false;
	end

	if t == "customblockmodel" or t == "customitemmodel" or t == "customactormodel" or 
		t == "currentmapblockmodel" or t == "currentmapitemmodel" or t == "currentmapactormodel" then
		if (t == "customblockmodel" or t == "currentmapblockmodel") and  CurrentEditDef and CurrentEditDef.ID <= 200 and not CurEditorIsCopied then
			ShowGameTips(GetS(4846), 3);
			return false;
		end

		getglobal("OriginalGridBox"):Hide();
		getglobal("ChooseOriginalFrameCustomModel"):Show();
		getglobal("ModCustomModelClassBox"):Show();
		getglobal("ChooseOriginalFrameCustomModelListFrame"):Hide();
		--隐藏定制装扮页签的按钮
		HideBtnByAvatar()

		t_ResModelClass = {};
		local model_class = PUBLIC_LIB
		if t == "currentmapblockmodel" or t == "currentmapitemmodel" or t == "currentmapactormodel" then
			model_class = MAP_LIB
		end

		local num = ResourceCenter:getResClassNum(model_class);
		num = num > 48 and 48 or num --只有48个控件。。
		for i=1, num do
			local classInfo = ResourceCenter:getClassInfo(model_class, i-1);
			if classInfo then
				local t_modelType = {};
				if t == "customblockmodel" or t=="currentmapblockmodel" then
					t_modelType = {[BLOCK_MODEL]=true, fcm=true, icm = true};
				elseif t == "customitemmodel" or t=="currentmapitemmodel" then
					t_modelType = {[BLOCK_MODEL]=true,[WEAPON_MODEL]=true, [GUN_MODEL]=true, [PROJECTILE_MODEL]=true, [BOW_MODEL]=true, fcm=true, icm = true};
				elseif t == "customactormodel" or t=="currentmapactormodel" then
					t_modelType = {[ACTOR_MODEL]=true, fcm=true, icm = true};
				end


				local t = GetOneClassAllModel(model_class, classInfo, t_modelType);
				table.insert(t_ResModelClass, {classname=classInfo.classname, info=t});

				local class = getglobal("ModCustomModelClassBoxClass"..i);
				class:Show();

				-- local nameBkg = getglobal("ModCustomModelClassBoxClass"..i.."NameBkg");
				local list = getglobal("ModCustomModelClassBoxClass"..i.."List");
				local emptyIcon = getglobal("ModCustomModelClassBoxClass"..i.."EmptyIcon");
				local classNameUI = getglobal("ModCustomModelClassBoxClass"..i.."Name");

				classNameUI:SetText(GetRealClassName(t_ResModelClass[i].classname));

				-- nameBkg:SetTextureTemplate("TexTemplate_zyk_tab_y");

				local num = #(t_ResModelClass[i].info);
				if num > 0 then
					list:Show();
					emptyIcon:Hide();
					local modelType = BLOCK_MODEL;
					if t == "customitemmodel" then
						modelType = WEAPON_MODEL;
					elseif t == "customactormodel" then
						modelType = ACTOR_MODEL;
					end
					UpdateOneModelClassList(t_ResModelClass[i].info, list, model_class, modelType);
				else
					list:Hide();
					emptyIcon:Show();
				end
			end
		end

		for i=num+1, 48 do
			local class = getglobal("ModCustomModelClassBoxClass"..i);
			class:Hide();
		end
		getglobal("ModCustomModelClassBox"):Show();

		if num <= 4 then
			getglobal("ModCustomModelClassBoxPlane"):SetSize(710, 333);
		else
			local row = math.ceil(num/4);
			getglobal("ModCustomModelClassBoxPlane"):SetSize(710, row*225);
		end
	elseif t == "custommodel_equip" then
		--TODO:预设装备自定义模型
		getglobal("ChooseOriginalFrameCustomModel"):Hide();
		getglobal("OriginalGridBox"):Show();
		local OfficialEquipModels = GetInst("ModsLibEditorItemPartMgr"):LoadOfficialEquipModelList();
		local num = #OfficialEquipModels;

		for i=1, Max_OriginalBlock_Num do
			local grid = getglobal("OriginalGrid"..i);
			local icon = getglobal("OriginalGrid"..i .. "Icon");

			if i <= num then
				local mode_filename = OfficialEquipModels[i].filename;
				local modeltype = OfficialEquipModels[i].modeltype;
				grid:Show();

				SetModelIcon(icon, mode_filename, modeltype);

				grid:SetClientString(mode_filename);	--ClientString记录了选择的微雕模型key;
				grid:SetClientID(i);					--记录索引
			else
				grid:Hide();
			end
		end

		local height = 333 + math.ceil((num - 36) / 9) * 84;
		if height < 333 then
			height = 333;
		end

		getglobal("OriginalGridBoxPlane"):SetSize(755, height);
	else
		getglobal("ChooseOriginalFrameCustomModel"):Hide();
		getglobal("OriginalGridBox"):Show();

		local num = #(t);
		for i=1, Max_OriginalBlock_Num do
			local grid = getglobal("OriginalGrid"..i);
			if i <= num then
				grid:Show();
				local icon = getglobal(grid:GetName().."Icon");
				--icon:SetSize(75, 75);
				if ChooseOriginalType == 'itemmodel' then
					SetItemIcon(icon, t[i].RelevantID);
				elseif ChooseOriginalType == 'actormodel' then
					local index = t[i].RelevantID;
					if CurEditorType == 3 then	--皮肤模型
						local skinDef = RoleSkinCsv:get(t[i].RelevantID);
						if skinDef then
							icon:SetTexture("ui/roleicons/"..skinDef.Head..".png", true);
						end
					elseif CurEditorType == MONSTER_HORSE_MODEL then	--坐骑模型 chenweiTODO 设置选择模型列表头像
						local storeHorseDef = DefMgr:getStoreHorseByID(t[i].RelevantID);
						if storeHorseDef then
							icon:SetTexture("ui/rideicons/"..storeHorseDef.HeadID..".png", true);
						end
					else
						if IsAvatarTab() then
							--如果是定制装扮
							local avatarPlugins = AvatarGetPlugins()
							AvatarSetIconByIDEx(avatarPlugins[i].id,icon)
						else
							icon:SetTexture("ui/roleicons/"..t[i].RelevantID..".png", true);
						end
					end

				elseif ChooseOriginalType == 'dropitem' or ChooseOriginalType == 'ai_dropitem' or ChooseOriginalType == 'craftresult' or ChooseOriginalType == 'craftmaterial' or ChooseOriginalType == 'craft_tool' or
						ChooseOriginalType == 'furnaceresult' or ChooseOriginalType == 'furnacematerial' or ChooseOriginalType == 'StoreItem' or ChooseOriginalType == 'StoreAddItem' or ChooseOriginalType == "PackAddItem" then
					SetItemIcon(icon, t[i].ID);
				elseif ChooseOriginalType == 'transferban' or ChooseOriginalType == 'transferticket' then
					SetItemIcon(icon, t[i].ID);
				elseif ChooseOriginalType == 'projectilemodel' then
					SetItemIcon(icon, t[i].RelevantID);
				elseif ChooseOriginalType == 'projectile' or ChooseOriginalType == 'bullet' then
					SetItemIcon(icon, t[i].ID);
				elseif ChooseOriginalType == 'atkbuff' then
					icon:SetSize(65, 65);
					icon:SetTexture("ui/bufficons/"..t[i].IconName..".png", true);
				elseif ChooseOriginalType == 'featureai' then
					icon:SetSize(65, 65);
					icon:SetTexture("ui/aiicons/"..t[i].Icon..".png", true);
				elseif ChooseOriginalType == 'featureitemskill' then
					icon:SetSize(65, 65);
					icon:SetTexture("ui/itemskillicons/"..t[i].Icon..".png", true);
				elseif ChooseOriginalType == 'ai_block' then
					icon:SetSize(65, 65);
					SetItemIcon(icon, t[i].ID);
				elseif ChooseOriginalType == 'ai_food' then
					icon:SetSize(65, 65);
					SetItemIcon(icon, t[i].ID);
				elseif ChooseOriginalType == 'ai_actor' then
					if t[i] and t[i].Icon and t[i].Icon ~= "" and string.sub(t[i].Icon, 1, 1) == "a" then 
						--Avatar头像，以"a"开头
						local id = string.sub(t[i].Icon, 2, #t[i].Icon)
						if id then 
							local avatarDef = ModMgr:tryGetMonsterDef(tonumber(id))
							local args = FrameStack.cur()
							if args.isMapMod then 
								AvatarSetIconByID(avatarDef,icon)
							else
								AvatarSetIconByIDEx(t[i].Icon,icon)
							end
						end
					else
						icon:SetTexture("ui/roleicons/"..t[i].Icon..".png", true)
						local def = ModEditorMgr:getMonsterDefById(t[i].ID);
						if not def then
							def = MonsterCsv:get(t[i].ID);
						end
						if def then
							if def.ModelType == MONSTER_CUSTOM_MODEL then
								SetModelIcon(icon, def.Model, ACTOR_MODEL);
							elseif def.ModelType == MONSTER_FULLY_CUSTOM_MODEL then
								SetModelIcon(icon, def.Model, FULLY_ACTOR_MODEL);
							elseif def.ModelType == MONSTER_IMPORT_MODEL then
								SetModelIcon(icon, def.Model, IMPORT_ACTOR_MODEL);
							end
						end
					end 
				elseif ChooseOriginalType == 'ai_buff' then
					icon:SetSize(65, 65);
					icon:SetTexture("ui/bufficons/"..t[i].IconName..".png", true);
				elseif ChooseOriginalType == 'ai_container' or ChooseOriginalType == 'ai_targetblock' or ChooseOriginalType == 'ai_useitem' then
					--LLDO:new add:箱子
					icon:SetSize(65, 65);
					SetItemIcon(icon, t[i].ID);
				elseif ChooseOriginalType == 'ai_craft' then
					--LLDO:new add:配方
					icon:SetSize(65, 65);
					SetItemIcon(icon, t[i].ResultID);
				elseif ChooseOriginalType == "PlotIcon" then		--剧情图标
					Log("plot: Show: PlotIcon:");
					getglobal('ChooseOriginalFrameOkBtn'):SetClientID(0);	--切换tab的时候, 将id清掉, 因为生物和道具类型不同.
					icon:SetSize(65, 65);
					if CurEditorType == 1 then
						--生物
						Log("111: actor")
						--icon:SetTexture("ui/roleicons/"..t[i].ID..".png", true);
						icon:SetTexture("ui/roleicons/"..t[i].RelevantID..".png", true);
					else
						--道具
						Log("222: item")
						SetItemIcon(icon, t[i].ID);
					end
				elseif ChooseOriginalType == "PlotInteractID" or ChooseOriginalType == "TaskContents_Monster" then
					--剧情:触发目标
					icon:SetSize(65, 65); 
					icon:SetTexture("ui/roleicons/"..t[i].Icon..".png", true);
						if type(t[i].Icon) == "string" then
							if (string.sub(t[i].Icon,1,1)) == "a" then 
								--avatar图标
								local pluginId = string.sub(t[i].Icon,2,string.len(t[i].Icon))
								local avatarPlugins = AvatarGetPlugins()
								local args = FrameStack.cur()
								if args.isMapMod then
									AvatarSetIconByID(t[i],icon)
								else
									AvatarSetIconByIDEx(pluginId,icon)
								end 
							end 
						end

					local def = ModEditorMgr:getMonsterDefById(t[i].ID);
					if not def then
						def = MonsterCsv:get(t[i].ID);
					end
					if def then
						if def.ModelType == MONSTER_CUSTOM_MODEL then
							SetModelIcon(icon, def.Model, ACTOR_MODEL);
						elseif def.ModelType == MONSTER_FULLY_CUSTOM_MODEL then
							SetModelIcon(icon, def.Model, FULLY_ACTOR_MODEL);
						elseif def.ModelType == MONSTER_IMPORT_MODEL then
							SetModelIcon(icon, def.Model, IMPORT_ACTOR_MODEL);
						end
					end
				elseif ChooseOriginalType == "PlotItemID" or ChooseOriginalType == "TaskContents_Item" then	--拥有道具
					icon:SetSize(65, 65);
					SetItemIcon(icon, t[i].ID);
				else
					if MyModsEditorType == 'block' then
						SetItemIcon(icon, t[i].ID);
					elseif MyModsEditorType == 'actor' then
						icon:SetTexture("ui/roleicons/"..t[i].ID..".png", true);
					elseif MyModsEditorType == 'item' then
						SetItemIcon(icon, t[i].ID);
					elseif MyModsEditorType == 'craft' then
						SetItemIcon(icon, t[i].ResultID);
					elseif MyModsEditorType == 'furnace' then
						SetItemIcon(icon, t[i].MaterialID);
					elseif MyModsEditorType == 'plot' then
						--剧情展示, 暂时图标用200代替
						NpcPlot_SetPlotIcon(icon, t[i].Icon);
					end
				end
				if ChooseOriginalType == 'featureai' or ChooseOriginalType == 'featureitemskill' then
					grid:SetClientID(i);
				else
					if IsAvatarTab() then
						--如果是定制装扮，设置格子ID信息为索引值
						local avatarPlugins = AvatarGetPlugins()
						grid:SetClientID(avatarPlugins[i].id);
					else
						grid:SetClientID(t[i].ID);
					end
				end
			else
				grid:Hide()
			end
		end

		if IsAvatarTab() then
			--显示定制装扮页签的按钮
			ShowBtnByAvatar()
		else
			--隐藏定制装扮页签的按钮
			HideBtnByAvatar()
		end

		local height = 333+ math.ceil((num-36)/9)*84;
		if height < 333 then
			height = 333;
		end

		getglobal("OriginalGridBoxPlane"):SetSize(755, height);
	end

    return true;
end

function ModCustomModelClassClick(index)
	if t_ResModelClass[index] then
		CurModelClassIndex = index;

		local className = t_ResModelClass[index].classname;
		getglobal("ChooseOriginalFrameCustomModelListFrameName"):SetText(GetRealClassName(className));

		--UpdateModelList();
		UpdateModCustomModelList(t_ResModelClass[index]);
		getglobal("ModCustomModelClassBox"):Hide();
		if CurModSelModelUIName then
			getglobal(CurModSelModelUIName.."Check"):Hide();
		end
		getglobal("ChooseOriginalFrameCustomModelListFrame"):Show();
	end
end

function UpdateModCustomModelList(t_OneClassModelList)
	for i=1, 440 do
		local gridUI = getglobal("ModCustomModelListBoxGrid"..i);
		if i <= #(t_OneClassModelList.info) then
			gridUI:Show();

			local icon = getglobal(gridUI:GetName().."Icon");
			print("kekeke t_OneClassModelList info", t_OneClassModelList.info);
			local modelType = t_OneClassModelList.info[i].modeltype and t_OneClassModelList.info[i].modeltype or -1;
			--[[
			if t == "itemmodel" then
				modelType = WEAPON_MODEL;
			elseif t == "actormodel" then
				modelType = ACTOR_MODEL;
			end
			]]

			SetModelIcon(icon, t_OneClassModelList.info[i].filename, modelType);
			if t_OneClassModelList.info[i].canchoose then
				icon:SetGray(false);
			else
				icon:SetGray(true);
			end
			gridUI:SetClientString(t_OneClassModelList.info[i].filename);
			gridUI:SetClientUserData(0, modelType)

			local bkg = getglobal(gridUI:GetName().."Bkg")
			if t_OneClassModelList.info[i].status == DOWNLOAD_STATUS then
				bkg:SetTexUV("img_icon_lignt_y")
			else
				bkg:SetTexUV("img_icon_lignt")
			end
			local ui_state = getglobal(gridUI:GetName().."State")
			local isInBanResList = IsResourceInBanResList(t_OneClassModelList.info[i].resId)
			if ui_state then
				if isInBanResList then --违规资源
					ui_state:SetAngle(0)
					ui_state:Show()
					ui_state:SetTexUV("icon_report")
					ui_state:SetWidth(17)
					ui_state:SetHeight(14)
				elseif t_OneClassModelList.info[i].status == DOWNLOAD_STATUS then
					ui_state:SetAngle(180)
					ui_state:Show()
					ui_state:SetTexUV("icon_top_b")
					ui_state:SetWidth(14)
					ui_state:SetHeight(16)
				else
					ui_state:Hide()
				end
			end
		else
			gridUI:Hide();
		end
	end

	if #(t_OneClassModelList.info) <= 24 then
		getglobal("ModCustomModelListBoxPlane"):SetHeight(270);
	else
		local addline = math.ceil((#(t_OneClassModelList.info)-24) /8);
		local height = addline*92 + 270;
		getglobal("ModCustomModelListBoxPlane"):SetHeight(height);
	end
end

function ModCustomModelGridTemplate_OnClick()
	local btnName = this:GetName();
	local iconUI = getglobal(btnName.."Icon");
	local iconState = getglobal(btnName.."State")
	if iconState and iconState:IsShown() and iconState:GetAngle()<1 then
		--这里用了取巧的处理，违规的图片不做旋转，小心有坑！！
		ShowGameTips(GetS(16359));
		return;
	end

	if iconUI and iconUI:IsGray() then
		ShowGameTips(GetS(12538));
		return;
	end
	if string.find(btnName, "ActorEditSelectModelGrid") then
		ActorEditMgr:ActorEditSelectModelGridClick(btnName, this:GetClientString(), this:GetClientUserData(0));
	elseif string.find(btnName, "FullyCustomModelEditorSelectModelGrid") then
		GetInst("UIManager"):GetCtrl("FullyCustomModelEditor"):SelectModelFrameModelGridClicked(this:GetClientID(), this:GetClientString(), this:GetClientUserData(0))
	elseif string.find(btnName, "FullyCustomModelImportModelGrid") then
		GetInst("UIManager"):GetCtrl("FullyCustomModelImport"):GridBtnClicked(this:GetClientID(), this:GetClientString(), this:GetClientUserData(0))
	else
		if CurModSelModelUIName then
			getglobal(CurModSelModelUIName.."Check"):Hide();
		end

		CurModSelModelUIName = this:GetName();
		getglobal(CurModSelModelUIName.."Check"):Show();

		getglobal('ChooseOriginalFrameOkBtn'):SetClientString(this:GetClientString());	--ClientString记录了选择的微雕模型key;
		getglobal('ChooseOriginalFrameOkBtn'):SetClientID(this:GetClientUserData(0));	--ClientID记录了选择的微雕模型类型;

		--飘字显示名字
		local modeltype = this:GetClientUserData(0);
		local filename = this:GetClientString();
		if modeltype >= FULLY_BLOCK_MODEL or modeltype == -1 then
			local fullyCustomModel = FullyCustomModelMgr:findFullyCustomModel(RES_MODEL_CLASS, filename, true);
			if nil == fullyCustomModel then
				fullyCustomModel = FullyCustomModelMgr:findFullyCustomModel(MAP_MODEL_CLASS, filename, true);
			end
			if fullyCustomModel then
				local name = fullyCustomModel:getName();
				UpdateTipsFrame(name, 0);
			end
		end

		if modeltype < FULLY_BLOCK_MODEL then
			local customModel = CustomModelMgr:getCustomModel(RES_MODEL_CLASS, filename);
			if nil == customModel then
				CustomModelMgr:getCustomModel(MAP_MODEL_CLASS, filename);
			end
			if customModel then
				local name = customModel:getModelName();
				UpdateTipsFrame(name, 0);
			end
		end
	end
end

function ChooseOriginalCustomModelListBackBtn_OnClick()
	getglobal("ChooseOriginalFrameCustomModelListFrame"):Hide();
	getglobal("ModCustomModelClassBox"):Show();
end

-------------------------------------------------new add: plotEdit-------------------------------------------------
function PlotEditFrameNewBtn_OnClick()

end

function PlotEditFrame_OnShow()
	SetAllSlotTemplateDelState("hide");
	if lastPlotPage then
		Current_Page_Index = clamp(lastPlotPage, 1, GetNpcPlotPageCount());
	else
		Current_Page_Index = GetNpcPlotPageCount();
	end

	if not UseNewModsLib then
		UpdateEditorSlot();
	end
end

-----------------------定制装扮相关代码--------------------------

--定制装扮的选择状态
AvatarSelectTable = nil 
AvatarTabIndex = 0

--检查是否需要增加定制装扮的TAB
function CheckAvatarExtraTab(greaterNum)
	if ChooseOriginalType == "actormodel" then 
		local extraOriginalInfo = {}
		extraOriginalInfo.EditType = 4 
		extraOriginalInfo.t = {}

		local avatarPlugins = AvatarGetPlugins()
		if avatarPlugins and #avatarPlugins > 0 then
			for i = 1,#avatarPlugins do
				local aAvatarPlugin = avatarPlugins[i]
				table.insert(extraOriginalInfo.t,aAvatarPlugin) 
			end  
		end 
		AvatarTabIndex = #t_OriginalInfo - greaterNum;
		table.insert(t_OriginalInfo,extraOriginalInfo)
	
		--定制装扮被选择的集合
		ResetAvatarSelectTable() 
	end 
end

--打开Avatar定制页面
function AddAvatarBtnOnClick()
	GetInst("UIManager"):Open("ShopCustomSkinEdit",{editType = 4})
end

--Avatar定制页面点击保存回调
function SaveAvatarCallback()
	--将最后一个保存的数据加到临时显示数据中
	local avatarInfoTable = GetTable2EditType(CurEditorType)
	local extraOriginalInfo = {}
	extraOriginalInfo.EditType = 4 
	extraOriginalInfo.t = {}
	local avatarPlugins = AvatarGetPlugins()
	if avatarPlugins and #avatarPlugins > 0 then
		local aAvatarPlugin = avatarPlugins[#avatarPlugins]
		table.insert(avatarInfoTable,aAvatarPlugin) 
	end
	SetTable2EditType(CurEditorType, avatarInfoTable)
	ResetAvatarSelectTable()
	--更新显示
	UpdateEditorOriginalBox(CurEditorType)
	ShowAvatarSelBtn(false)
end

--点击删除定制装扮的按钮（垃圾箱）
function DeleteAvatarBtnOnClick()
	getglobal('ChooseOriginalFrameDelBtn'):Hide()
	getglobal('ChooseOriginalFrameCancelDelBtn'):Show()
	getglobal('ChooseOriginalFrameConfirmDelBtn'):Show()
	ShowAvatarSelBtn(true) 
end

--点击取消删除定制装扮的按钮（垃圾箱）
function CancelDeleteAvatarBtnOnClick()
	getglobal('ChooseOriginalFrameDelBtn'):Show()
	getglobal('ChooseOriginalFrameCancelDelBtn'):Hide()
	getglobal('ChooseOriginalFrameConfirmDelBtn'):Hide()
	ShowAvatarSelBtn(false)
	ResetAvatarSelectTable()
end

--点击定制装扮的选择按钮
function AvatarSelectBtnOnClick()
	local id = this:GetParentFrame():GetClientID()
	local avatarPlugins = AvatarGetPlugins()
	local index = nil 
	if avatarPlugins then 
		for i = 1,#avatarPlugins do 
			if avatarPlugins[i].id == id then 
				index = i 
				break 
			end 
		end 
	end 
	local gridSelBtnNormal = getglobal("OriginalGrid"..index .. "SelBtnNormal")
	local gridSelBtnPushedBG = getglobal("OriginalGrid"..index .. "SelBtnPushedBG") 
	if not AvatarSelectTable[index] then 
		AvatarSelectTable[index] = true
		gridSelBtnNormal:SetTexUV("bjjm_anniu01")
		gridSelBtnPushedBG:SetTexUV("bjjm_anniu01")
	else
		AvatarSelectTable[index] = false 
		gridSelBtnNormal:SetTexUV("bjjm_anniudi")
		gridSelBtnPushedBG:SetTexUV("bjjm_anniudi")
	end 
end 

--点击确认删除定制装扮的按钮
function ConfirmDelAvatarBtnOnClick()
	local haveSelected = false 
	for k,v in pairs(AvatarSelectTable) do 
		if v then
			haveSelected = true  
			break
		end  
	end
	if not haveSelected then
		CancelDeleteAvatarBtnOnClick()
	else
		MessageBox(5, GetS(21229))
		getglobal("MessageBoxFrame"):SetClientString("删除定制装扮")
	end
end

--点击确认删除定制装扮的按钮回调
function ConfirmDelAvatarBtnOnClickCallback()
	--先删除本地文件数据
	local avatarPlugins = AvatarGetPlugins()
	local newAvatarPlugins = {} 
	if avatarPlugins and #avatarPlugins > 0 then
		for k,v in pairs(AvatarSelectTable) do 
			if not v then 
				table.insert(newAvatarPlugins,avatarPlugins[k])
			else
				--删除ICON
				--AvatarRemoveIcon(avatarPlugins[k].id)
				local saveId = "a" .. (30000 + avatarPlugins[k].id)
				UIActorBodyManager:releaseAvatarIconBySaveId(saveId)
			end 
		end 
	end  
	AvatarSetPlugins(newAvatarPlugins)
	--再删除显示数据
	local avatarInfoTable = GetTable2EditType(CurEditorType)
	local newAvatarInfoTable = {}
	for k,v in pairs(AvatarSelectTable) do
		if not v then
			table.insert(newAvatarInfoTable,avatarInfoTable[k]) 
		end 
	end 
	SetTable2EditType(4,newAvatarInfoTable)
	ResetAvatarSelectTable()
	ShowAvatarSelBtn(false) 
	UpdateEditorOriginalBox(CurEditorType)

	ShowGameTips(GetS(3992), 3)
end

--重置定制装扮选择状态
function ResetAvatarSelectTable()
	AvatarSelectTable = {}
	local avatarInfoTable = GetTable2EditType(4)
	for i = 1,#avatarInfoTable do 
		AvatarSelectTable[i] = false 
	end 
end

--当前是否选中的是定制装扮的TAB
function IsAvatarTab(showType)
	local showType = showType or CurEditorType
	if ChooseOriginalType == 'actormodel' and showType == 4 then
		return true 
	else
		return false 
	end 
end

--显示定制装扮的额外按钮
function ShowBtnByAvatar()
	local avatarInfoTable = GetTable2EditType(CurEditorType)
	local addBtnIndex = #avatarInfoTable
	local row = math.floor(addBtnIndex / 9)
	local mor = addBtnIndex % 9
	if mor ~= 0 then 
		getglobal("OriginalGridAdd"):SetPoint("topleft", "OriginalGrid"..addBtnIndex, "topleft", 86, 1)
	else
		getglobal("OriginalGridAdd"):SetPoint("topleft", "OriginalGrid1", "topleft", 1, row * 86 + 1)
	end 
	getglobal("OriginalGridAdd"):Show()

	getglobal('ChooseOriginalFrameDelBtn'):Show()

	getglobal('ChooseOriginalFrameCancelDelBtn'):Hide()

	getglobal('ChooseOriginalFrameConfirmDelBtn'):Hide()
end

--隐藏定制装扮的额外按钮
function HideBtnByAvatar()
	getglobal("OriginalGridAdd"):Hide()
	getglobal('ChooseOriginalFrameDelBtn'):Hide()
	getglobal('ChooseOriginalFrameCancelDelBtn'):Hide()
	getglobal('ChooseOriginalFrameConfirmDelBtn'):Hide()
	ShowAvatarSelBtn(false)
end

--显示定制装扮的选择按钮
function ShowAvatarSelBtn(isShow)
	local avatarInfoTable = GetTable2EditType(CurEditorType)	
	for i = 1, Max_OriginalBlock_Num do
		local gridSelBtn = getglobal("OriginalGrid"..i .. "SelBtn")
		local gridSelBtnNormal = getglobal("OriginalGrid"..i .. "SelBtnNormal")
		local gridSelBtnPushedBG = getglobal("OriginalGrid"..i .. "SelBtnPushedBG") 
		if i <= #avatarInfoTable then
			if isShow then
				gridSelBtn:Show()
				if AvatarSelectTable[i] then 
					gridSelBtnNormal:SetTexUV("bjjm_anniu01")
					gridSelBtnPushedBG:SetTexUV("bjjm_anniu01")
				else
					gridSelBtnNormal:SetTexUV("bjjm_anniudi")
					gridSelBtnPushedBG:SetTexUV("bjjm_anniudi")
				end 
			else
				gridSelBtn:Hide()
			end 
		end 
	end 
end

------------------------------------------NPC商店-----------------------------------------------------------
function CreateNewNPCStoreFrameNewBtn_OnClick( )
	NpcStoreTable.itemList = {};
	NpcStore.iShopID = 0;
	--清理生物模型
	local modelView = getglobal("NewEditorModelView");
	local body = modelView:getActorbody();
	if body then
		if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
			modelView:detachActorBody(body)
		else
			body:detachUIModelView(modelView);
		end
	end
	SetSingleEditorFrame('store', GetCurrentEditDef());
	ResetNpcStoreTable();

	if SingleEditorFrame_Switch_New then
		GetInst("UIManager"):GetCtrl("SingleEditorFrame"):ChangeSingleEditor2Tab_Ctrl(1)
	else
		ChangeSingleEditor2Tab(1);
		CurEditorClass = "store"
	end

	-- getglobal("SingleEditorFrameDelBtn"):Show();
	getglobal("SingleEditorFrameBaseSetStoreDescEditDescTip"):SetText(GetS(3959), 185, 185, 185);
	-- getglobal("SingleEditorFrameSortBtn"):Show();
	getglobal("SingleEditorInteraction"):Hide();
	getglobal("CreateNewNPCStoreFrame"):Hide();
end

function ShowSingleEditorNPCStoreItemSet(CurEditFeatureIndex,shopID)  
	if CurEditFeatureIndex > 100 then

		--清理生物模型
		local modelView = getglobal("NewEditorModelView");
		local body = modelView:getActorbody();
		if body then
			if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
				modelView:detachActorBody(body)
			else
				body:detachUIModelView(modelView);
			end
		end


		local interactNum = interactData.GetAllNum();
		local num = CurEditFeatureIndex-100-interactNum-1;
		-- local def = ModEditorMgr:getNpcShopDef(num);
		print("NPCStoreItemSet shopID:",shopID)
		local def = ModEditorMgr:getNpcShopDefById(shopID)
		NpcStoreTable.itemList = {};
		NpcStore.iShopID = def.iShopID;
		NpcStore.sShopName = def.sShopName;
		NpcStore.sShopDesc = def.sShopDesc;
		NpcStore.EnglishName = def.EnglishName;
		NpcStore.sInnerKey = def.sInnerKey;

		NpcStoreTable.config.Name = NpcStore.sShopName;
		NpcStoreTable.config.Desc = NpcStore.sShopDesc;

		getglobal("SingleEditorFrameBaseSetStoreNameEditEdit"):SetText(NpcStore.sShopName)
		getglobal("SingleEditorFrameBaseSetStoreDescEditEdit"):SetText(NpcStore.sShopDesc)
		getglobal("SingleEditorFrameSortBtn"):Hide();
		-- local NpcShopDef = ModEditorMgr:getNpcShopDefById(def.iShopID)
		-- local keys = def:getSkuAllKeys()
		local num = def:getSkuSize();
		if num > 0 then
			for i=0,num-1 do

				local skuDef = def:getNpcShopSkuDefByIdx(i)
				local itemID = skuDef.iItemID;
				local iItemInfo1 = skuDef.iCostItemInfo1;
				local iItemInfo2 = skuDef.iCostItemInfo2;
				-- if ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getMapDefaultModUUID() 
				-- and ModEditorMgr:getCurrentEditModUuid() ~= ModMgr:getUserDefaultModUUID() then
				-- 	if itemID > CUSTOM_MOD_QUOTE then
				-- 		itemID = itemID - CUSTOM_MOD_QUOTE
				-- 	end
				-- 	if iItemInfo1 > CUSTOM_MOD_QUOTE then
				-- 		iItemInfo1 = iItemInfo1 - CUSTOM_MOD_QUOTE
				-- 	end
				-- 	if iItemInfo2 > CUSTOM_MOD_QUOTE then
				-- 		iItemInfo2 = iItemInfo2 - CUSTOM_MOD_QUOTE
				-- 	end
				-- end
				NpcStoreTable.config.ItemID = itemID;
				NpcStoreTable.config.Attr[1].CurVal = math.modf(iItemInfo1/1000);
				NpcStoreTable.config.Attr[1].CurNum = iItemInfo1%1000;
				NpcStoreTable.config.Attr[2].CurVal = math.modf(iItemInfo2/1000);
				NpcStoreTable.config.Attr[2].CurNum = iItemInfo2%1000;
				NpcStoreTable.config.Attr[3].CurVal = skuDef.iStarNum;
				NpcStoreTable.config.Attr[4].CurVal = skuDef.iOnceBuyNum;
				NpcStoreTable.config.Attr[5].CurVal = skuDef.iMaxCanBuyCount;
				NpcStoreTable.config.Attr[6].CurVal = skuDef.iRefreshDuration;
				if skuDef.iRefreshDuration == 0 then
					NpcStoreTable.config.Attr[7].CurVal = 0;
				else
					NpcStoreTable.config.Attr[7].CurVal = 1;
				end
				NpcStoreTable.config.Attr[8].CurVal = skuDef.iShowAD;
				table.insert(NpcStoreTable.itemList,deep_copy_table(NpcStoreTable.config));
			end
			SaveNpcStoreItemList(def.EnglishName);
		else
			NpcStoreTable.itemList = {};
			NpcStore.shopItemMap = {}
		end

		SetSingleEditorFrame('store', GetCurrentEditDef());
		ChangeSingleEditor2Tab(1);
		-- SetModBoxsDeals(true);
		-- getglobal("SingleEditorFrameSortBtn"):Show();
		getglobal("SingleEditorFrameDelBtn"):Show();
		getglobal("SingleEditorInteraction"):Hide();
		getglobal("CreateNewNPCStoreFrame"):Hide();
		-- SetSingleEditorDealMsg(true);
		return;
		
	end
end

function CheckChooseOriginalFrameTabsDisabled(tabindex)
	if not tabindex then
		return false
	end

	-- 插件审核屏蔽
	local tempCurEditorType = t_OriginalInfo[tabindex] and t_OriginalInfo[tabindex].EditType or -1

	-- 方块，生物，道具的自定义外观面板
	if ChooseOriginalType == 'blockmodel' and (tempCurEditorType == 5 or tempCurEditorType == 6) or
	   ChooseOriginalType == 'itemmodel' and (tempCurEditorType == 5 or tempCurEditorType == 6) or
	   ChooseOriginalType == 'actormodel' and (tempCurEditorType == 5 or tempCurEditorType == 6) then

		if PluginInputDisabled('') then
			return true
		end
	end

	return false
end