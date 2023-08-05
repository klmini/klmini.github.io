
g_IsShowVideMessageBox = false

------------------------------------LLDO:音乐new add:设置时间轴上的音乐标记------------------------------------
local t_Edit_music = {
	"sounds/music/bgm1.ogg",
	"sounds/music/bgm2.ogg",
	"sounds/music/bgm3.ogg",
	"sounds/music/bgm4.ogg",
	"sounds/music/bgm5.ogg",
	"sounds/music/bgm6.ogg",
	"sounds/music/bgm7.ogg",
	"sounds/music/bgm8.ogg",
}


local m_EditMusicParam = {
	sumTime = 0,
	sumMusicNum = 0,
	curBtnIndex = 1,
	frameUI = "MusicEditFrameEditParam",
	curPlayingIndex = 0,	--当前正在播放的音乐索引

	paramSet = {
		--[[结构示例
		[1] = {
			start_time = 1,
			continued_time = 5,
			
			},
		[2] = {},
		]]
	},

	Init = function(self)
		local num = RecordPkgMgr:getSoundNum()
		self.curBtnIndex = 1
		self.curPlayingIndex = 0
		self.sumMusicNum = num
		self.sumTime = RecordPkgMgr:getTotalTime()
		self.paramSet = nil
		self.paramSet = {}

		for i = 1, num do
			local node = RecordPkgMgr:getSoundByIndex(i - 1)

			table.insert(self.paramSet, {
					start_time = node.start_time,
					continued_time = node.continued_time,
					content = node.content,	--记录索引
					loop = node.loop,
				}
			)
		end
	end,

	update = function(self)
		--刷新左侧导航按钮
		ReplayLayoutTabBtns("MusicEditFrameEditorTabs", #self.paramSet, self.curBtnIndex)

		--根据时间排序
		table.sort( self.paramSet, function(first, second)
				return first.start_time < second.start_time
			end
		)

		getglobal(self.frameUI):Hide()
		if #self.paramSet > 0 then
			getglobal(self.frameUI):Show()

			local paramSet = self.paramSet[self.curBtnIndex]

			if paramSet then
				--1. 音乐名
				getglobal(self.frameUI .. "SelectMusicBtnName"):SetText(GetS(594) .. paramSet.content)

				--2. 时间
				getglobal(self.frameUI .. "Time1"):SetText(os.date("%M:%S", paramSet.start_time / 1000))
				getglobal(self.frameUI .. "Time2"):SetText(os.date("%M:%S", (paramSet.start_time + paramSet.continued_time) / 1000))

				--3. 循环开关
				SetSwitchBtnState("MusicEditFrameEditParamLoopSwitch", paramSet.loop)
			end
		end

		--音乐标记
		SetTimeScaleTips()
	end,

	AddMusic = function(self)
		local curTime = RecordPkgMgr:getCurrentTime()
		local needAdd = true

		--添加之前先load一次
		self:Init()

		for i = 1, #self.paramSet do
			if self.paramSet[i].start_time <= curTime and curTime <= (self.paramSet[i].start_time + self.paramSet[i].continued_time) then
				needAdd = false
				curBtnIndex = i
				break
			end
		end

		if needAdd then
			--添加新的
			local node = {}
			node.start_time = math.floor(curTime / 1000) * 1000
			node.continued_time = 5000
			node.content = "1"	--保存索引
			node.loop = 1					--默认循环
			table.insert(self.paramSet, {
					start_time = node.start_time,
					continued_time = node.continued_time,
					content = node.content,
					loop = node.loop,
				}
			)

			curBtnIndex = #self.paramSet
		end

		self:update()
	end,

	DeleteMusic = function(self)
		--只是在lua表里删除, 并没有在c++里删除. 只有点保存的时候才真正改变
		for i = 1, #self.paramSet do
			if i == self.curBtnIndex then
				table.remove(self.paramSet, i)
				self:update()
				break
			end
		end
	end,

	SaveMusic = function(self)
		--1. 先清空
		RecordPkgMgr:clearSound()

		--2. 再依次添加
		for i = 1, #self.paramSet do
			local node = self.paramSet[i]
			RecordPkgMgr:setSound(node.start_time, node.continued_time, node.content, node.loop)
		end
	end,

	CloseBtn = function(self)
		--重新load一遍.
		self:Init()
		self:update()
	end,

	SetMusicTime = function(self)
		local paramSet = self.paramSet[self.curBtnIndex]

		local time1Txt = getglobal(self.frameUI .. "Time1"):GetText()
		local time2Txt = getglobal(self.frameUI .. "Time2"):GetText()

		if time1Txt and #time1Txt > 0 and time2Txt and #time2Txt > 0 then
			local sumSecond = math.floor(self.sumTime / 1000)
			local time1 = ChangeString2Second(time1Txt)
			local time2 = ChangeString2Second(time2Txt)
			Log("good: sumSecond = " .. sumSecond)

			if time1 > sumSecond then
				return
			end

			if time2 > sumSecond then
				time2 = sumSecond
			end

			if time1 and time2 and time1 >= 0 and time2 >= time1 then
				Log("input OK!")
				Log("time1 = " .. time1 .. ", time2 = " .. time2)
				Log("paramSet.start_time = " .. paramSet.start_time)
				Log("paramSet.continued_time = " .. paramSet.continued_time)

				paramSet.start_time = time1 * 1000
				paramSet.continued_time = (time2 - time1) * 1000
				self:update()
			end
		end
	end,

	SetLoop = function(self, state)
		if #self.paramSet > 0 then
			if state then
				self.paramSet[self.curBtnIndex].loop = 1
			else
				self.paramSet[self.curBtnIndex].loop = 0
			end
		end
	end,

	--选择音乐
	SetContent = function(self, index)
		Log("SetContent: index = " .. index)
		local paramSet = self.paramSet[self.curBtnIndex]
		paramSet.content = tostring(index)
		local path = t_Edit_music[index]
		local loop = false

		if paramSet.loop == "1" then
			loop = true
		end

		ClientMgr:playMusic(path, loop)
		self:update()
	end,
}

function SetTimeScaleTips()
	Log("SetTimeScaleTips:")
	--m_EditMusicParam:Init()

	local firstUI = "TimeGridMusicTip"
	local infoList = m_EditMusicParam.paramSet
	local sumTime = m_EditMusicParam.sumTime

	for i = 1, 40 do
		local tipUI = firstUI .. i
		local tip = getglobal(tipUI)
		local bkg = getglobal(tipUI .. "Bkg")
		local txt1 = getglobal(tipUI .. "Txt1")
		local txt2 = getglobal(tipUI .. "Txt2")
		local bkgChecked=getglobal(tipUI .. "BkgChecked")
		local icon1Checked = getglobal(tipUI .. "Icon1Checked")
		local icon2Checked = getglobal(tipUI .. "Icon2Checked")

		if i <= #infoList then
			local paramSet = infoList[i]
			local x = math.floor(paramSet.start_time / 1000) * 1000 / sumTime * 996
			local width = math.floor(paramSet.continued_time / 1000) * 1000 / sumTime * 996
			Log("paramSet.start_time = " .. paramSet.start_time .. ", paramSet.continued_time = " .. paramSet.continued_time .. ", x = " .. x .. ", width = " .. width)
			tip:SetPoint("bottomleft", "TimerShaftFrameTimeScale", "bottomleft", x, -55)
			tip:Show()
			tip:SetWidth(width)
			bkg:SetWidth(width)
			txt1:SetText(i)
			txt2:SetText(i)

			--被选中的音乐在时间轴上高亮标记
			if i==m_EditMusicParam.curBtnIndex and getglobal("MusicEditFrame"):IsShown() then
				bkgChecked:SetWidth(width)
				icon1Checked:Show()
				icon2Checked:Show()
				bkgChecked:Show()
			else
				icon1Checked:Hide()
				icon2Checked:Hide()
				bkgChecked:Hide()
			end

		else
			tip:Hide()
		end
	end
end

function MusicEditFrame_OnShow()
	Log("MusicEditFrame_OnShow:")
	m_EditMusicParam:Init()
	m_EditMusicParam:AddMusic()

	ClientCurGame:setOperateUI(true)
end

function MusicEditFrame_OnHide( ... )
	ClientCurGame:setOperateUI(false)
	-- body
end
--保存音乐
function MusicEditFrameOkBtn_OnClick()
	m_EditMusicParam:SaveMusic()
	ShowGameTips(GetS(3940),1)
	getglobal("MusicEditFrame"):Hide()
	getglobal("TimeGridMusicTip"..m_EditMusicParam.curBtnIndex.."BkgChecked"):Hide()
	getglobal("TimeGridMusicTip"..m_EditMusicParam.curBtnIndex.."Icon1Checked"):Hide()
	getglobal("TimeGridMusicTip"..m_EditMusicParam.curBtnIndex.."Icon2Checked"):Hide()
end

--删除音乐
function MusicEditFrameDelBtn_OnClick()
	m_EditMusicParam:DeleteMusic()
end

function MusicEditFrameCloseBtn_OnClick()
	m_EditMusicParam:CloseBtn()
	getglobal("MusicEditFrame"):Hide()
	getglobal("TimeGridMusicTip"..m_EditMusicParam.curBtnIndex.."BkgChecked"):Hide()
	getglobal("TimeGridMusicTip"..m_EditMusicParam.curBtnIndex.."Icon1Checked"):Hide()
	getglobal("TimeGridMusicTip"..m_EditMusicParam.curBtnIndex.."Icon2Checked"):Hide()
end

function MusicEditFrame_OnLoad()
	--音乐选项
	local boxUI = "MusicEditFrameSelectMusicFrameMusicList"
	local planeUI = boxUI .. "Plane"
	local plane = getglobal(planeUI)
	local y = 20
	local n = #t_Edit_music
	for i = 1, n do
		local btnUI = boxUI .. "Btn" .. i
		if not HasUIFrame(btnUI) then
			break
		end

		local ruleId = 25
		local gameRuleDef = DefMgr:getGameRuleDef(ruleId)
		if gameRuleDef then
			local optionDef = DefMgr:getRuleOptionDef(gameRuleDef.OptionID[i])

			if optionDef then
				getglobal(btnUI .. "Item2Name"):SetText(optionDef.DefaultDesc)
			end
		end

		local btn = getglobal(btnUI)
		btn:Show()
		btn:SetPoint("top", planeUI, "top", 0, y)
		y = y + btn:GetHeight() + 15
		getglobal(btnUI):Show()
	end

	getglobal(planeUI):SetHeight(y)
end

function MusicEditFrameEditParamTime1_OnFocusLost()
	m_EditMusicParam:SetMusicTime()
end

function MusicEditFrameEditParamTime1_OnEnterPressed()
	m_EditMusicParam:SetMusicTime()
end

function MusicEditFrameEditParamTime2_OnFocusLost()
	m_EditMusicParam:SetMusicTime()
end

function MusicEditFrameEditParamTime2_OnEnterPressed()
	m_EditMusicParam:SetMusicTime()
end

--选择音乐
function RecordMusicSelectItemBtn_OnClick()
	local index = this:GetParentFrame():GetClientID()
	m_EditMusicParam:SetContent(index)
	MusicEditFrameSelectMusicFrameCloseBtn_OnClick()
end

function MusicEditFrameSelectMusicBtn_OnClick()
	getglobal("MusicEditFrameSelectMusicFrame"):Show()
end

function MusicEditFrameSelectMusicFrameCloseBtn_OnClick()
	getglobal("MusicEditFrameSelectMusicFrame"):Hide()
end

--选择试听音乐播放暂停
function StartAndPauseBtn_OnClick()
	Log("StartAndPauseBtn_OnClick:")
	local index = this:GetParentFrame():GetClientID()

	for i = 1, #t_Edit_music do
		local btnUI = "MusicEditFrameSelectMusicFrameMusicListBtn" .. i .. "Item1"
		local stop = getglobal(btnUI .. "Stop")
		local Normal = getglobal(btnUI .. "Normal")

		if index == i then
			Log("index = " .. i)
			local path = t_Edit_music[i]

			if stop:IsShown() then
				--关闭
				Log("stop:")
				ClientMgr:stopMusic()
				stop:Hide()
				Normal:Show()
			else
				--开启
				Log("start:")
				ClientMgr:playMusic(path, true)
				stop:Show()
				Normal:Hide()
			end
		else
			stop:Hide()
			Normal:Show()
		end
	end
end

--底部快捷栏按钮布局
function RecordBottomShortcutBtnLayout()
	local videoShortCut_Max_Num = 7
	local t_shortcut={"icon_play_white","icon_preview","icon_video_add","icon_video_edit","icon_Barrage","icon_sound_effect","icon_special_effects"}

	for i=1,videoShortCut_Max_Num do
		local pushedBG = getglobal("VideoShortcutItem"..i.."PushedBG")
		local normal =getglobal("VideoShortcutItem"..i.."Normal")
		local num = getglobal("VideoShortcutItem"..i.."Num")
		-- local item = getglobal("VideoShortcutItem"..i)
		if i == 1 then
			pushedBG:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml")
			normal:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml")
			pushedBG:SetSize(35,42)
			normal:SetSize(35,42)
		else
			pushedBG:SetTextureHuiresXml("ui/mobile/texture2/videotape.xml")
			normal:SetTextureHuiresXml("ui/mobile/texture2/videotape.xml")
			pushedBG:SetSize(55,55)
			normal:SetSize(55,55)
		end
		normal:SetTexUV(t_shortcut[i])
		pushedBG:SetTexUV(t_shortcut[i])
		num:SetText(i)
		-- item:SetSize(76,76)
	end
end

------------------------------------------------LLDO: new add------------------------------------------------
--通用函数
--1. 把00:00转化为时间戳秒数
function ChangeString2Second(in_str)
	Log("ChangeString2Second:")
	local flag = string.find(in_str, ":")
	local m = 0
	local s = 0

	if flag then
		--有冒号":"
		m = tonumber(string.sub(in_str, 1, flag - 1))
		s = tonumber(string.sub(in_str, flag + 1, -1))
	else
		return tonumber(in_str)
	end

	local sumSecond = 60 * m + s
	Log("m = " .. m .. ", s = " .. s .. ", sumSecond = " .. sumSecond)

	return sumSecond
end

--主界面参数
local m_MainParam = {
	sumTime = 0,	--录像总时长
	sumWidth = 960,
	bIsPreview = false,	--是否是从编辑模式进入的预览模式, 如果是, 退出预览的时候回到编辑模式
	nPreviewTime = 0,	--记住进入预览时, 当前的编辑模式的时间.
}

--1. 编辑镜头
local m_EditLensParam = {
	curLenNum = 0,	--当前镜头数
	curBtnIndex = 1,	--当前导航按钮索引
	bDirty = false,		--是否有修改

	paramSet = {
		--[[
		[1] = {
			slider = {
				{min = 0, max = 360, step = 1, nameId = 7528, },	--1. 朝向X
				{min = 0, max = 360, step = 1, nameId = 7528,},		--2. 朝向Y
				{min = 0, max = 2, step = 0.5, nameId = 7522, ValShowType="One_Decimal"},	--3. 播放速度
			},

			startTime = 5,		--开始时间
			bJTGL = 1,			--镜头关联
		},
		[2] = {},
		...
		]]
	},

	Init = function(self)
		Log("m_EditLensParam:Init:")
		self.curLenNum = RecordPkgMgr:getCameraNum()
		Log("curLenNum = " .. self.curLenNum)
		self:InitSet()
		self:update()
	end,

	InitSet = function(self)
		Log("m_EditLensParam: InitSet:")
		--1. 加载镜头信息
		self.paramSet = nil
		self.paramSet = {}
		for i = 1, self.curLenNum do
			local nodedata = RecordPkgMgr:getCameraNodeByIndex(i - 1)
			self:AddSet(nodedata, false)
		end

		self.bDirty = false
	end,

	--添加一个镜头设置
	AddSet = function(self, nodedata, _isNew)
		Log("AddSet:")
		Log("nodedata.start_time = " .. nodedata.start_time)
		table.insert(self.paramSet, 
			{
				slider = {
					{min = 0, max = 360, step = 1, nameId = 7528, curval = nodedata.yaw},		--1. 朝向X
					{min = 0, max = 360, step = 1, nameId = 7528, curval = nodedata.pitch},		--2. 朝向Y
					{min = 0.5, max = 2, step = 0.5, nameId = 7510, ValShowType="One_Decimal", curval = nodedata.speed},	--3. 播放速度
				},

				startTime = nodedata.start_time,
				bJTGL = nodedata.relatenext,
			}
		)

		if _isNew then
			--添加一个新的, 重新加载一次, 因为插在中间的话顺序就变了
			self:Init()
			self:update()
			self.bDirty = true
		end

		Log("speed = " .. nodedata.speed)
	end,

	DeleteOne = function(self)
		Log("m_EditLensParam: DeleteOne:")
		if self.curLenNum > 0 then
			for i = 1, #self.paramSet do
				if i == self.curBtnIndex then
					RecordPkgMgr:delCameraPos(self.paramSet[i].startTime)
					table.remove(self.paramSet, i)
					self.curLenNum = self.curLenNum - 1
					self.curBtnIndex = self.curBtnIndex - 1
					if self.curBtnIndex < 1 then self.curBtnIndex = 1 end
					self:update()
					self.bDirty = true
					break
				end
			end
		end
	end,

	update = function(self)
		Log("m_EditLensParam: update:")

		--刷新左侧导航按钮
		ReplayLayoutTabBtns("LensEditFrameLeftFrame", self.curLenNum, self.curBtnIndex)

		--刷新对应的参数
		getglobal("LensEditFrameRightFrame"):Hide()
		if self.curLenNum > 0 then
			getglobal("LensEditFrameRightFrame"):Show()

			--1. 滑动条
			local paramSet = self.paramSet[self.curBtnIndex]
			local slider = paramSet.slider
			local frameUI = "LensEditFrameRightFrame"
			for i = 1, #slider do
				local sliderUI = frameUI .. "Slider" .. i
				local name = getglobal(sliderUI .. "Name")
				local desc = getglobal(sliderUI .. "Desc")
				local bar = getglobal(sliderUI .. "Bar")

				if i == 1 then
					name:SetText(GetS(slider[i].nameId) .. "(X)")
					desc:SetText(GetS(7543))
				elseif i == 2 then
					name:SetText(GetS(slider[i].nameId) .. "(Y)")
					desc:SetText(GetS(7543))
				else
					name:SetText(GetS(slider[i].nameId))
					desc:SetText("X")
				end

				bar:SetMaxValue(slider[i].max)
				bar:SetMinValue(slider[i].min)
				bar:SetValueStep(slider[i].step)
				bar:SetValue(slider[i].curval)
			end

			--2. 时间, 镜头关联
			getglobal("LensEditFrameRightFrameTimeTxt"):SetText(os.date("%M:%S", paramSet.startTime / 1000))
			SetSwitchBtnState("LensEditFrameRightFrameJTGLSwitch", paramSet.bJTGL)
		end

		--3. 镜头在时间轴上的标记
		for i = 1, 40 do
			local tip = getglobal("TimeGridLenTip" .. i)
			local txt = getglobal("TimeGridLenTip" .. i .. "Txt")
			local bkg = getglobal("TimeGridLenTip" .. i .. "Bkg")
			local iconChecked = getglobal("TimeGridLenTip"..i.."IconChecked")

			if i <= self.curLenNum then
				local paramSet = self.paramSet[i]
				local x = paramSet.startTime / m_MainParam.sumTime * m_MainParam.sumWidth
				txt:SetText(i)
				tip:SetPoint("bottomleft", "TimerShaftFrameTimeScale", "bottomleft", x, -8)
				tip:Show()
				Log("ShowLenTip: startTime = " .. paramSet.startTime .. ", sumTime = " .. m_MainParam.sumTime .. ", x = " .. x)

				bkg:Hide()

				--被选中的当前镜头，标记高亮效果
				if i==self.curBtnIndex and getglobal("LensEditFrame"):IsShown() then
					iconChecked:Show()
				else
					iconChecked:Hide()
				end

				--设置两个镜头之间的连线
				if paramSet.bJTGL == 1 and i < self.curLenNum then
					--最后一个不用管
					bkg:Show()
					local timeOffset = self.paramSet[i + 1].startTime - self.paramSet[i].startTime
					local width = timeOffset / m_MainParam.sumTime * m_MainParam.sumWidth + 20
					bkg:SetWidth(width)
				end
			else
				tip:Hide()
			end
		end

		--4. 空白页
		if self.curLenNum <= 0 then
			getglobal("LensEditFrameEmptyFrame"):Show()
		else
			getglobal("LensEditFrameEmptyFrame"):Hide()
		end
	end,

	--设置镜头关联
	SetJTGL = function(self, state)
		Log("m_EditLensParam: SetJTGL:")
		if self.curLenNum > 0 then
			if state then
				self.paramSet[self.curBtnIndex].bJTGL = 1
			else
				self.paramSet[self.curBtnIndex].bJTGL = 0
			end

			self:update()
			self.bDirty = true
		end
	end,

	SaveSet = function(self)
		Log("m_EditLensParam: SaveSet:")
		for i = 1, #self.paramSet do
			local paramSet = self.paramSet[i]
			local slider = paramSet.slider

			local nodedata = RecordPkgMgr:getCameraNodeByStartTime(paramSet.startTime)
			nodedata.yaw = paramSet.slider[1].curval
			nodedata.pitch = paramSet.slider[2].curval
			nodedata.speed = paramSet.slider[3].curval
			nodedata.relatenext = paramSet.bJTGL
			RecordPkgMgr:setCameraPos(nodedata.start_time, nodedata.x, nodedata.y, nodedata.z, nodedata.yaw, nodedata.pitch, nodedata.speed, nodedata.relatenext)
		end

		self.bDirty = false
	end,
}

--2. 字幕编辑
local m_EditTextParam = {
	curBtnIndex = 1,	--当前导航按钮索引
	curStringNum = 0,	--字幕总数
	frameUI = "SubtitleEditFrameParam",

	paramSet = {
		--[[	--结构示例
		[1] = {
			slider = {
				{min = 1, max = 3, step = 1, curval = 1, nameId = 7573, desc = {7544, 7545, 7546}, },	--1. 位置
				{min = 1, max = 3, step = 1, curval = 1, nameId = 7575, desc = {7549, 7548, 7547}, },	--2. 字号
			},

			startTime = 1,		--开始时间
			continueTime = 5,	--持续时间
			content = "",		--文字信息
		},
		[2] = {},
		...
		]]
	},

	Init = function(self)
		Log("m_EditTextParam:Init:")
		self.curStringNum = RecordPkgMgr:getCharacterNum()
		Log("curStringNum = " .. self.curStringNum)
		self:InitSet()
		self:update()
	end,

	InitSet = function(self)
		Log("m_EditTextParam: InitSet:")
		--1. 加载字幕信息
		local oldNum = self.curStringNum
		self.paramSet = nil
		self.paramSet = {}
		for i = 1, self.curStringNum do
			local nodedata = RecordPkgMgr:getCharacterByIndex(i - 1)
			self:AddSet(nodedata, false)
		end

		self.curStringNum = oldNum
	end,

	--添加一个字幕设置
	AddSet = function(self, nodedata, _isNew)
		Log("m_EditTextParam: AddSet:")
		Log("nodedata.start_time = " .. nodedata.start_time)

		if _isNew and self.curStringNum > 0 then
			--如果是添加新的, 要判断下起始是否时间点和老的重合, 重合则表示打开老的而不插入新的
			Log("AddNewString: nodedata.start_time = " .. nodedata.start_time)
			for i = 1, self.curStringNum do
				local startTime = self.paramSet[i].startTime
				local stopTime = startTime + self.paramSet[i].continueTime
				if nodedata.start_time >= startTime and nodedata.start_time <= stopTime then
					Log("startTime = " .. startTime .. ", stopTime = " .. stopTime)
					Log("modifyIndex =" .. i)
					self.curBtnIndex = i
					return
				end
			end
		end

		table.insert(self.paramSet, 
			{
				slider = {
					{min = 1, max = 3, step = 1, curval = nodedata.pos, nameId = 7541, desc = {7544, 7545, 7546}, },	--1. 位置
					{min = 1, max = 3, step = 1, curval = nodedata.front, nameId = 7542, desc = {7549, 7548, 7547}, },	--2. 字号
				},

				startTime = math.floor(nodedata.start_time / 1000) * 1000,
				continueTime = math.floor(nodedata.continued_time / 1000) * 1000,
				content = nodedata.content,
				isNew = _isNew,	--是否是新增的
			}
		)

		if _isNew then
			RecordPkgMgr:setCharacter(nodedata.start_time, nodedata.continued_time, nodedata.content, nodedata.pos, nodedata.front)
			self:Init()
		else

		end

		--self.curStringNum = self.curStringNum + 1
		self.curBtnIndex = self.curStringNum
	end,

	update = function(self)
		Log("m_EditTextParam: update:")

		--刷新左侧导航按钮
		ReplayLayoutTabBtns("SubtitleEditFrameTabs", self.curStringNum, self.curBtnIndex)

		--刷新对应的参数
		getglobal("SubtitleEditFrameParam"):Hide()
		if self.curStringNum > 0 then
			getglobal("SubtitleEditFrameParam"):Show()

			local paramSet = self.paramSet[self.curBtnIndex]

			if paramSet then
				--1. 勾选区
				local slider = paramSet.slider
				for i = 1, #slider do
					local sliderUI = self.frameUI .. "Slider" .. i
					local name = getglobal(sliderUI .. "Name")
					--local desc = getglobal(sliderUI .. "Desc")

					name:SetText(GetS(slider[i].nameId))
					--desc:SetText(GetS(slider[i].desc[slider[i].curval]))

					for j = 1, 3 do
						local btnName = getglobal(sliderUI .. "Btn" .. j .. "Name")
						local btnTick = getglobal(sliderUI .. "Btn" ..j .. "Tick")
						btnName:SetText(GetS(slider[i].desc[j]))

						if slider[i].curval == j then
							btnTick:Show()
						else
							btnTick:Hide()
						end
					end
				end

				--2. 文字信息
				getglobal(self.frameUI .. "DescEdit"):SetText(paramSet.content)

				--3. 时间
				getglobal(self.frameUI .. "Time1"):SetText(os.date("%M:%S", paramSet.startTime / 1000))
				getglobal(self.frameUI .. "Time2"):SetText(os.date("%M:%S", (paramSet.startTime + paramSet.continueTime) / 1000))
			end
		end

		--3. 字幕在时间轴上的标记
		for i = 1, 40 do
			local tipUI = "TimeGridString" .. i
			local tip = getglobal(tipUI)
			local bkg = getglobal(tipUI .. "Bkg")
			local txt1 = getglobal(tipUI .. "Txt1")
			local txt2 = getglobal(tipUI .. "Txt2")
			local bkgChecked = getglobal(tipUI .. "BkgChecked")
			local icon1Checked = getglobal(tipUI.. "Icon1Checked")
			local icon2Checked = getglobal(tipUI.. "Icon2Checked")

			if i <= self.curStringNum then
				local paramSet = self.paramSet[i]
				local x = paramSet.startTime / m_MainParam.sumTime * m_MainParam.sumWidth
				local width = paramSet.continueTime / m_MainParam.sumTime * m_MainParam.sumWidth
				tip:SetPoint("bottomleft", "TimerShaftFrameTimeScale", "bottomleft", x, -30)
				tip:Show()
				tip:SetWidth(width)
				bkg:SetWidth(width)
				txt1:SetText(i)
				txt2:SetText(i)
				Log("ShowLenTip: startTime = " .. paramSet.startTime .. ", sumTime = " .. m_MainParam.sumTime .. ", x = " .. x)

				--被选中的字幕在时间轴上标记高亮
				if i==self.curBtnIndex and getglobal("SubtitleEditFrame"):IsShown() then
					bkgChecked:SetWidth(width)
					bkgChecked:Show()
					icon1Checked:Show()
					icon2Checked:Show()
				else
					bkgChecked:Hide()
					icon1Checked:Hide()
					icon2Checked:Hide()
				end

			else
				tip:Hide()
			end
		end

		--4. 空白页
		if self.curStringNum <= 0 then
			getglobal("SubtitleEditFrameEmptyFrame"):Show()
		else
			getglobal("SubtitleEditFrameEmptyFrame"):Hide()
		end
	end,

	updateSliderDesc = function(self)
		Log("updateSliderDesc:")
		if self.curStringNum > 0 then
			getglobal("SubtitleEditFrameParam"):Show()
			local paramSet = self.paramSet[self.curBtnIndex]

			--1. 勾选框
			local slider = paramSet.slider
			for i = 1, #slider do
				local sliderUI = self.frameUI .. "Slider" .. i
				--local desc = getglobal(sliderUI .. "Desc")

				--desc:SetText(GetS(slider[i].desc[slider[i].curval]))
			end
		end
	end,

	--设置时间
	SetTime = function(self)
		Log("SubtitleEditFrameParam: SetTime:")
		local paramSet = self.paramSet[self.curBtnIndex]

		local time1Txt = getglobal(self.frameUI .. "Time1"):GetText()
		local time2Txt = getglobal(self.frameUI .. "Time2"):GetText()

		if time1Txt and #time1Txt > 0 and time2Txt and #time2Txt > 0 then
			local sumSecond = math.floor(m_MainParam.sumTime / 1000)
			local time1 = ChangeString2Second(time1Txt)
			local time2 = ChangeString2Second(time2Txt)
			Log("good: sumSecond = " .. sumSecond)

			if time1 > sumSecond then
				return
			end

			if time2 > sumSecond then
				time2 = sumSecond
			end

			if time1 and time2 and time1 >= 0 and time2 >= time1 then
				Log("input OK!")
				Log("time1 = " .. time1 .. ", time2 = " .. time2)
				Log("paramSet.startTime = " .. paramSet.startTime)
				Log("paramSet.continueTime = " .. paramSet.continueTime)

				local bDirty = false
				if math.floor(paramSet.startTime / 1000) ~= time1 then
					--当值有变化的时候才设置
					Log("time1 Changed!")
					paramSet.startTime = time1 * 1000
					bDirty = true
				end

				if math.floor(paramSet.continueTime / 1000) ~= (time2 - time1) then
					Log("time2 Changed!")
					paramSet.continueTime = (time2 - time1) * 1000
					bDirty = true
				end

				if bDirty then
					self:update()
				end
			end
		end
	end,

	--设置文字
	SetContent = function(self)
		Log("SubtitleEditFrameParam: SetContent:")
		local content = getglobal(self.frameUI .. "DescEdit"):GetText()
		content = ReplaceFilterString(content)
		self.paramSet[self.curBtnIndex].content = content
	end,

	SaveSet = function(self)
		Log("SubtitleEditFrameParam: SaveSet:")
		for i = 1, #self.paramSet do
			Log("i = " .. i)
			local paramSet = self.paramSet[i]
			local nodedata = {}
			nodedata.start_time = paramSet.startTime
			nodedata.continued_time = paramSet.continueTime
			nodedata.content = paramSet.content
			nodedata.pos = paramSet.slider[1].curval
			nodedata.front = paramSet.slider[2].curval

			--if false and paramSet.isNew then
				--是新增的
				--RecordPkgMgr:setCharacter(nodedata.start_time, nodedata.continued_time, nodedata.content, nodedata.pos, nodedata.front)
			--else
				--是修改已有的
				RecordPkgMgr:setCharacterByIndex(i - 1, nodedata.start_time, nodedata.continued_time, nodedata.content, nodedata.pos, nodedata.front)
			--end
		end
	end,

	DeleteOne = function(self)
		Log("SubtitleEditFrameParam: DeleteOne:")
		if self.curStringNum > 0 then
			for i = 1, #self.paramSet do
				if i == self.curBtnIndex then
					RecordPkgMgr:delCharacter(self.paramSet[i].startTime)
					table.remove(self.paramSet, i)
					self.curStringNum = self.curStringNum - 1
					self.curBtnIndex = self.curBtnIndex - 1
					if self.curBtnIndex < 1 then self.curBtnIndex = 1 end
					self:update()
					break
				end
			end
		end
	end,
}


-------------------------------------------------------------编辑特效------------------------------------------------------

local SpecialEffectsList = {GetS(7578),GetS(7579),GetS(7580),GetS(7582)}
local SpecialEffectsListIcon = {"luzhi_bd_bubble","luzhi_bd_yunwu","luzhi_bd_star","luzhi_bd_flower"}

local m_EditSpecialEffectsParam = {
	sumTime = 0,
	sumSpecialEffectsNum = 0,
	curBtnIndex = 1,
	frameUI = "SpecialEffectsEditFrameParam",
	curPlayingIndex = 0,	--当前特效索引

	paramSet = {
		--[[结构示例
		[1] = {
			start_time = 1,
			continued_time = 5,
			
			},
		[2] = {},
		]]
	},

	Init = function(self)
		local num = RecordPkgMgr:getEffectNum()
		self.curBtnIndex = 1
		self.curPlayingIndex = 0
		self.sumSpecialEffectsNum = num
		self.sumTime = RecordPkgMgr:getTotalTime()
		self.paramSet = nil
		self.paramSet = {}

		for i = 1, num do
			local node = RecordPkgMgr:getEffectByIndex(i - 1) 

			table.insert(self.paramSet, {
					start_time = node.start_time,
					continued_time = node.continued_time,
					effectid = node.effectid,	--记录索引
					-- loop = node.loop,
				}
			)
		end

	end,

	update = function(self)
		--刷新左侧导航按钮
		ReplayLayoutTabBtns("SpecialEffectsEditFrameTabs", #self.paramSet, self.curBtnIndex)

		--根据时间排序
		table.sort( self.paramSet, function(first, second)
				return first.start_time < second.start_time
			end
		)

		getglobal(self.frameUI):Hide()
		if #self.paramSet > 0 then
			getglobal(self.frameUI):Show()

			local paramSet = self.paramSet[self.curBtnIndex]

			if paramSet then
				--1. 特效名

				for i=1,#SpecialEffectsList do
					if i == paramSet.effectid then
						getglobal("SpecialEffectsEditFrameParamBtn"..i.."Checked"):Show()
					else
						getglobal("SpecialEffectsEditFrameParamBtn"..i.."Checked"):Hide()
					end
				end

				--2. 时间
				getglobal(self.frameUI .. "Time1"):SetText(os.date("%M:%S", paramSet.start_time / 1000))
				getglobal(self.frameUI .. "Time2"):SetText(os.date("%M:%S", (paramSet.start_time + paramSet.continued_time) / 1000))

			end
		end

		--特效标记
		SetTimeSpecialEffectsTips()
	end,

	AddSpecialEffects = function(self)
		local curTime = RecordPkgMgr:getCurrentTime()
		local needAdd = true

		--添加之前先load一次
		self:Init()

		for i = 1, #self.paramSet do
			if self.paramSet[i].start_time <= curTime and curTime <= (self.paramSet[i].start_time + self.paramSet[i].continued_time) then
				needAdd = false
				self.curBtnIndex = i
				break
			end
		end

		if needAdd then
			--添加新的
			local node = {}
			node.start_time = math.floor(curTime / 1000) * 1000
			node.continued_time = 5000
			node.effectid = 1	--保存索引
			table.insert(self.paramSet, {
					start_time = node.start_time,
					continued_time = node.continued_time,
					effectid = node.effectid,
				}
			)

			--根据时间排序
			table.sort( self.paramSet, function(first, second)
					return first.start_time < second.start_time
				end
			)
			
			for i = 1, #self.paramSet do
				if self.paramSet[i].start_time <= curTime and curTime <= (self.paramSet[i].start_time + self.paramSet[i].continued_time) then
					self.curBtnIndex = i
					break
				end
			end
			
		end

		self:update()
	end,

	DeleteSpecialEffects = function(self)
		--只是在lua表里删除, 并没有在c++里删除. 只有点保存的时候才真正改变
		for i = 1, #self.paramSet do
			if i == self.curBtnIndex then
				table.remove(self.paramSet, i)
				self:update()
				break
			end
		end
	end,

	SaveSpecialEffects = function(self)
		--1. 先清空
		RecordPkgMgr:clearEffect()

		--2. 再依次添加
		for i = 1, #self.paramSet do
			local node = self.paramSet[i]
			RecordPkgMgr:setEffect(node.start_time, node.continued_time, node.effectid)
		end
	end,

	CloseBtn = function(self)
		--重新load一遍.
		self:Init()
		self:update()
	end,

	SetSpecialEffectsTime = function(self)
		local paramSet = self.paramSet[self.curBtnIndex]

		local time1Txt = getglobal(self.frameUI .. "Time1"):GetText()
		local time2Txt = getglobal(self.frameUI .. "Time2"):GetText()

		if time1Txt and #time1Txt > 0 and time2Txt and #time2Txt > 0 then
			local sumSecond = math.floor(self.sumTime / 1000)
			local time1 = ChangeString2Second(time1Txt)
			local time2 = ChangeString2Second(time2Txt)
			Log("good: sumSecond = " .. sumSecond)

			if time1 > sumSecond then
				return
			end

			if time2 > sumSecond then
				time2 = sumSecond
			end

			if time1 and time2 and time1 >= 0 and time2 >= time1 then
				Log("input OK!")
				Log("time1 = " .. time1 .. ", time2 = " .. time2)
				Log("paramSet.start_time = " .. paramSet.start_time)
				Log("paramSet.continued_time = " .. paramSet.continued_time)

				paramSet.start_time = time1 * 1000
				paramSet.continued_time = (time2 - time1) * 1000
				self:update()
			end
		end
	end,

	-- SetLoop = function(self, state)
	-- 	if #self.paramSet > 0 then
	-- 		if state then
	-- 			self.paramSet[self.curBtnIndex].loop = 1
	-- 		else
	-- 			self.paramSet[self.curBtnIndex].loop = 0
	-- 		end
	-- 	end
	-- end,

	--选择特效
	SetContent = function(self, index)
		Log("SetContent: index = " .. index)
		local paramSet = self.paramSet[self.curBtnIndex]
		paramSet.effectid = tonumber(index)



		self:update()
	end,
}


----------------------------------------------------------------主界面----------------------------------------------------
function ReplayTheaterFrame_OnLoad()
	this:setUpdateTime(0.1)

	RecordBottomShortcutBtnLayout()
end

function ReplayTheaterFrameCloseBtn_OnClick()
	MessageBox(5, GetS(7536), function(btn)
			if btn == "left" then
				--确定
				--退出存档
				MainMenuBtn_OnClick()
				getglobal("ReplayTheaterFrame"):Hide()
			end
		end
	)
end

function ReplayTheaterFrame_OnEvent()

end

function ReplayTheaterFrame_OnUpdate()
	if not RecordPkgMgr:isPause() then
		--播放中, 走进度条
		local curTime = RecordPkgMgr:getCurrentTime()
		local maxValue = getglobal("TimerShaftFrameTimePointerBar"):GetMaxValue()
		local curValue = curTime / m_MainParam.sumTime * maxValue

		getglobal("TimerShaftFrameTimePointerBar"):SetValue(curValue)
	end
	
	if PreviewVideo then
		press_btn("VideoShortcutItem2")
		PreviewVideo = false
	end
end

function ReplayTheaterFrame_OnShow()
	Log("ReplayTheaterFrame_OnShow:")
	--进入先暂停
	SetBottomParseBtnState(true)

	--设置时间刻度
	InitTimeScaleFrame()
end

function ReplayTheaterFrame_OnHide()

end

--1. 底部类别按钮点击
function ShortcutTemplate_OnClick()
	Log("ShortcutTemplate_OnClick:")
	local index=this:GetClientID()
	print(index)
	if index == 1 then
		--开始/暂停
		local btn = getglobal("VideoShortcutItem1")
		local userData = btn:GetClientUserData(0)
		if userData == 0 then
			--暂停
			SetBottomParseBtnState(true)
		else
			--开始播放
			SetBottomParseBtnState(false)
		end
	elseif index == 2 then 						--预览播放
		Record_EnterPreview(true)
	elseif index ==  3 then             		--插入镜头
		ShowGameTips(GetS(7524),3)
		AddNewLen()                 			
	elseif index == 4 then 						--编辑镜头
		RecordPkgMgr:setEdit(true)
		getglobal("LensEditFrame"):Show()		
	elseif index == 5 then
		getglobal("SubtitleEditFrame"):Show()	--编辑字幕
		AddString2VideoRecord()	--添加要放在show的后面
	elseif index == 6 then
		getglobal("MusicEditFrame"):Show() 	--编辑音乐
		SetBottomParseBtnState(true)
	elseif index == 7 then                      --编辑特效
		getglobal("SpecialEffectsEditFrame"):Show()
		SetBottomParseBtnState(true)
	end

	ShortcutTemp_HandleAccekey(index)

	if getglobal("ShortcutBtnTipsFrame"):IsShown() then
		getglobal("ShortcutBtnTipsFrame"):Hide()
	end
end

--1.1. 底部类别按钮点击pc
function ShortcutTemplate_OnClick_PC( ... )
	ShortcutTemplate_OnClick()
end

--1.2. 底部类别按钮点击mobile
function ShortcutTemplate_OnClick_Mobile( ... )
	local index=this:GetClientID()
	local btnTips={GetS(7572),GetS(7573),GetS(7574),GetS(7525),GetS(7540),GetS(7552),GetS(7575)}
	local btn = getglobal("VideoShortcutItem1")
	local userData = btn:GetClientUserData(0)
	if userData == 0 then
		--暂停
		btnTips[1]=GetS(4769)
	else
		--开始播放
		btnTips[1]=GetS(7572)
	end

	getglobal("TipsFrameType1Font"):SetText(btnTips[index])
	getglobal("TipsFrame"):Show()
	getglobal("TipsFrameType2"):Hide()
	getglobal("TipsFrameType1"):Show()
	getglobal("TipsFrameType1Search"):Hide()
	getglobal("TipsFrameBan"):Hide()
	tipsDisplayTime = 1.0	
	ShortcutTemplate_OnClick()
end

--2. 底部按钮快捷键, 只能显示一个窗口
function ShortcutTemp_HandleAccekey(key_number)
	Log("ShortcutTemp_HandleAccekey:")
	local frames = {
		"LensEditFrame",
		"SubtitleEditFrame",
		"MusicEditFrame",
		"SpecialEffectsEditFrame",
	}

	if key_number == 4 or key_number == 5 or key_number == 6 or key_number == 7 then
		local curIndex = key_number - 3

		for i = 1, #frames do
			local frame = getglobal(frames[i])

			if i == curIndex then
				--当前操作的页面
			else
				--其它的页面都关掉,并隐藏时间轴上对应的高亮效果
				if frame:IsShown() then
					if i==1 then
						getglobal("TimeGridLenTip"..m_EditLensParam.curBtnIndex.."IconChecked"):Hide()
					elseif i==2 then
						getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."BkgChecked"):Hide()
						getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."Icon1Checked"):Hide()
						getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."Icon2Checked"):Hide()
					elseif i==3 then
						getglobal("TimeGridMusicTip"..m_EditMusicParam.curBtnIndex.."BkgChecked"):Hide()
						getglobal("TimeGridMusicTip"..m_EditMusicParam.curBtnIndex.."Icon1Checked"):Hide()
						getglobal("TimeGridMusicTip"..m_EditMusicParam.curBtnIndex.."Icon2Checked"):Hide()
					elseif i==4 then
						getglobal("TimeGridSpecialEffectsTip"..m_EditSpecialEffectsParam.curBtnIndex.."BkgChecked"):Hide()
						getglobal("TimeGridSpecialEffectsTip"..m_EditSpecialEffectsParam.curBtnIndex.."Icon1Checked"):Hide()
						getglobal("TimeGridSpecialEffectsTip"..m_EditSpecialEffectsParam.curBtnIndex.."Icon2Checked"):Hide()
					end
					frame:Hide()
				end
			end
		end
	end
end

--3.底部类别按钮文字提示显示(PC)
function ShortcutTemplate_OnMouseEnter_PC(...)
	local index=this:GetClientID()
	local btnName=this:GetName()
	local tips=getglobal("ShortcutBtnTipsFrame")
	local tipsBkg=getglobal("ShortcutBtnTipsFrameBkg")
	local tipsDesc=getglobal("ShortcutBtnTipsFrameDesc")
	local btnTips={GetS(7572),GetS(7573),GetS(7574),GetS(7525),GetS(7540),GetS(7552),GetS(7575)}

	local btn = getglobal("VideoShortcutItem1")
	local userData = btn:GetClientUserData(0)
	if userData == 0 then
		--暂停
		btnTips[1]=GetS(4769)
	else
		--开始播放
		btnTips[1]=GetS(7572)
	end

	if index==1 or index==2 then
		tipsDesc:SetWidth(90)
	else
		tipsDesc:SetWidth(150)
	end

	
	tipsDesc:SetText(btnTips[index])
	if not CurMainPlayer:isSightMode() then 
		tips:Show()
	else
		return
	end
	

end


--4.底部类别按钮文字提示隐藏(PC)
function ShortcutTemplate_OnMouseLeave_PC( ... )
	getglobal("ShortcutBtnTipsFrame"):Hide()
end

--播放/暂停按钮状态
function SetBottomParseBtnState(bIsParse)
	Log("SetBottomParseBtnState:")
	local pushedBG = getglobal("VideoShortcutItem1PushedBG")
	local normal = getglobal("VideoShortcutItem1Normal")
	local btn = getglobal("VideoShortcutItem1")
	if bIsParse then
		--暂停中
		Log("Parse...")
		RecordPkgMgr:setPause(true)
		pushedBG:SetTexUV("icon_play_white")
		normal:SetTexUV("icon_play_white")
		btn:SetClientUserData(0, 1)
	else
		--播放
		Log("Play...")
		RecordPkgMgr:setPause(false)
		pushedBG:SetTexUV("icon_pause_white")
		normal:SetTexUV("icon_pause_white")
		btn:SetClientUserData(0, 0)
	end
end

--时间刻度***********************
function InitTimeScaleFrame()
	Log("InitTimeScaleFrame:")

	--new
	local sumTime = m_MainParam.sumTime
	local sumSecond = sumTime / 1000
	local sumWidth = m_MainParam.sumWidth	--960
	local singleTime = 1
	if sumSecond <= 60 then
		singleTime = 1
	else
		singleTime = math.ceil(sumSecond / 60)
	end

	local sumScale = sumSecond / singleTime
	local singleWidth = sumWidth / sumScale

	Log("sumScale = " .. sumScale .. ", singleWidth = " .. singleWidth .. ", singleTime = " .. singleTime)

	for i = 1, 61 do
		local itemUI = "TimeGrid" .. i
		local item = getglobal(itemUI)
		local long = getglobal(itemUI .. "UV1")
		local short = getglobal(itemUI .. "UV2")
		local time2 = getglobal(itemUI .. "Time2")

		item:SetPoint("bottomleft", "TimerShaftFrameTimeScale", "bottomleft", (i - 1) * singleWidth, -75)

		if i <= sumScale + 1 then
			item:Show()

			if i % 5 == 1 then
				long:Show()
				short:Hide()
				time2:Show()
				time2:SetText(os.date("%M:%S", singleTime * (i - 1)))
				item:SetPoint("bottomleft", "TimerShaftFrameTimeScale", "bottomleft", (i - 1) * singleWidth, -64)
			else
				long:Hide()
				short:Show()
				time2:Hide()
			end
		else
			item:Hide()
		end

		
	end

	--设置时间拖动条
	local timeBar = getglobal("TimerShaftFrameTimePointerBar")
	timeBar:SetMinValue(0)
	timeBar:SetMaxValue(sumSecond)
	timeBar:SetValueStep(1)

	--设置初始值
	local curTime = RecordPkgMgr:getCurrentTime()
	local maxValue = getglobal("TimerShaftFrameTimePointerBar"):GetMaxValue()
	local curValue = curTime / m_MainParam.sumTime * maxValue
	timeBar:SetValue(curValue)
end

--前进/后退
function RecordGoForwardOrBack(gotoTime)
	Log("RecordGoForwardOrBack:")
	local sumTime = m_MainParam.sumTime
	local curTime = RecordPkgMgr:getCurrentTime()
	Log("sumTime = " .. sumTime .. ", curTime = " .. curTime .. ", gotoTime = " .. gotoTime)

	if gotoTime > curTime then
		--前
		Log("go forward...")

		if RecordPkgMgr:isPause() then
			SetBottomParseBtnState(false)
		end
		RecordPkgMgr:executePkgToTick(gotoTime)
	elseif gotoTime < curTime then
		--后
		Log("go back...")
		local worldDesc = AccountManager:getCurWorldDesc()
		ClientMgr:gotoGame("none")
		RequestEnterWorld(worldDesc.worldid, false, function(succeed)
			if succeed then
			  RecordPkgMgr:setEdit(true)
			  ShowLoadingFrame()
			  HideLobby()
  			  RecordPkgMgr:executePkgToTick(gotoTime) 	
			end
		end)
	end
end

function TimePointBar_OnValueChanged( ... )
	local  value = this:GetValue()
end

function TimePointBar_OnMouseUp()
	local value = this:GetValue()
	Log("TimePointBar_OnMouseUp: value = " .. value)

	RecordGoForwardOrBack(value * 1000)
end

function TimePointBar_OnMouseDown()
	--按下的时候先暂停, 一面一边跑进度, 一遍又拖动进度, 时间点冲突
	if not RecordPkgMgr:isPause() then
		SetBottomParseBtnState(true)
	end
end

--进入预览/退出预览
function Record_EnterPreview(bEnter)
	Log("Record_EnterPreview:")
	-- if bEnter then
	-- 	--进入预览
	-- 	Log("Enter:")
	-- 	local worldDesc = AccountManager:getCurWorldDesc()
	-- 	CSMgr:stopGameRecord()
	-- 	ClientMgr:gotoGame("none")
	-- 	RequestEnterWorld(worldDesc.worldid, false, function(succeed)
	-- 		if succeed then
	-- 			m_MainParam.bIsPreview = true
	-- 		  	RecordPkgMgr:setEdit(false)	--设为预览模式
	-- 		  	ShowLoadingFrame()
	-- 		  	HideLobby()
 --  			  	RecordPkgMgr:executePkgToTick(500) 	
	-- 		end
	-- 	end)
	-- else
	-- 	--退出预览
	-- 	Log("Quit:")
	-- end

	local worldDesc = AccountManager:getCurWorldDesc()
	ClientMgr:gotoGame("none")
	RequestEnterWorld(worldDesc.worldid, false, function(succeed)
		if succeed then
			if bEnter then
				--进入预览
				Log("Enter:")
				m_MainParam.bIsPreview = true
				m_MainParam.nPreviewTime = RecordPkgMgr:getCurrentTime()
			  	RecordPkgMgr:setEdit(false)	--设为预览模式
			  	ShowLoadingFrame()
			  	HideLobby()
				RecordPkgMgr:executePkgToTick(500)
			else
				--退出预览到编辑模式
				Log("Quit")
				m_MainParam.bIsPreview = false
			  	RecordPkgMgr:setEdit(true)	--设为预览模式
			  	ShowLoadingFrame()
			  	HideLobby()
			  	local gotoTime = m_MainParam.nPreviewTime
			  	if gotoTime <= 0 then
			  		gotoTime = 500
			  	end

			  	Log("gotoTime = " .. gotoTime)
				RecordPkgMgr:executePkgToTick(gotoTime)
			end
		end
	end)
	getglobal("VideoHandleFramePlayBtnTipsTime"):Hide()

end

--左侧导航按钮布局
function ReplayLayoutTabBtns(boxUI, btnNum, selectIndex)
	Log(debug.traceback())
	Log("ReplayLayoutTabBtns: boxUI = " .. boxUI .. ", btnNum = " .. btnNum .. ",selectIndex=" .. selectIndex)
	local planeUI = boxUI .. "Plane"
	local plane = getglobal(planeUI)
	local y = 20

	for i = 1, 99 do
		local btnUI = boxUI .. "Btn" .. i
		if not HasUIFrame(btnUI) then
			break
		end

		local btn = getglobal(btnUI)
		local index = btn:GetClientID() or 0

		if i <= btnNum then
			btn:Show()
			getglobal(btnUI .. "Num"):SetText(index)
			btn:SetPoint("top", planeUI, "top", 0, y)
			y = y + btn:GetHeight() + 15

			local checked = getglobal(btnUI .. "Checked")
			local num = getglobal(btnUI .. "Num")
			checked:Hide()
			--num:SetTextColor(236,204,142)
			if i == selectIndex then
				checked:Show()
				--num:SetTextColor(121, 89, 58)
			end
		else
			btn:Hide()
		end
	end

	if y < 370 then 
		y = 370 
	end
	
	getglobal(planeUI):SetHeight(y)
end

function LensEditFrame_OnLoad()

end

function LensEditFrame_OnShow()
	m_EditLensParam:Init()
	m_EditLensParam:update()

	--游戏中调出界面时，显示鼠标
	ClientCurGame:setOperateUI(true)
end

function LensEditFrame_OnHide()
	ClientCurGame:setOperateUI(false)
end

function LensEditFrameCloseBtn_OnClick()
	if m_EditLensParam.bDirty then
		MessageBox(5, GetS(7511), function(btn)
				if btn == "left" then
					--确定
					getglobal("LensEditFrame"):Hide()
					getglobal("TimeGridLenTip"..m_EditLensParam.curBtnIndex.."IconChecked"):Hide()
				end
			end
		)
	else
		getglobal("LensEditFrame"):Hide()
		getglobal("TimeGridLenTip"..m_EditLensParam.curBtnIndex.."IconChecked"):Hide()
	end
end

--左侧tab按钮点击
function EditTabTemplate_OnClick()
	local index = this:GetClientID()
	local frame = this:GetName()
	print("frameTable:",frame," index:",index)
	if string.find(frame,"SubtitleEdit")  then
		--字幕编辑
		m_EditTextParam.curBtnIndex = index
		m_EditTextParam:update()
	elseif string.find(frame,"MusicEdit") then
		m_EditMusicParam.curBtnIndex = index
		m_EditMusicParam:update()
	elseif string.find(frame,"SpecialEffectsEdit") then
		m_EditSpecialEffectsParam.curBtnIndex = index
		m_EditSpecialEffectsParam:update()
	else
		--镜头编辑导航按钮点击
		m_EditLensParam.curBtnIndex = index
		m_EditLensParam:update()
	end
end

--添加镜头
function AddNewLen()
	Log("AddNewLen:")
	m_EditLensParam.curLenNum = m_EditLensParam.curLenNum + 1
	Log("m_EditLensParam.curLenNum = " .. m_EditLensParam.curLenNum)

	SetBottomParseBtnState(true)

	--添加镜头
	local nodedata = RecordPkgMgr:getCameraCurrentNode()
	nodedata.relatenext = 1
	RecordPkgMgr:setCameraPos(nodedata.start_time, nodedata.x, nodedata.y, nodedata.z, nodedata.yaw, nodedata.pitch, nodedata.speed, nodedata.relatenext)
	m_EditLensParam:AddSet(nodedata, true)

	local num = RecordPkgMgr:getCameraNum()
	Log("num = " .. num)
end

--添加/编辑字幕
function AddString2VideoRecord()
	Log("AddString2VideoRecord:")
	-- if not RecordPkgMgr:isPause() then
	-- 	--先暂停
	-- 	RecordPkgMgr:setPause(true)
	-- end
	SetBottomParseBtnState(true)

	local nodedata = {}
	nodedata.start_time = math.floor(RecordPkgMgr:getCurrentTime() / 1000) * 1000
	nodedata.continued_time = 1000
	nodedata.content = ""
	nodedata.pos = 1
	nodedata.front = 1
	m_EditTextParam:AddSet(nodedata, true)
	m_EditTextParam:update()
end

function LensEditFrameDelBtn_OnClick()
	m_EditLensParam:DeleteOne()
end

--确定按钮:保存镜头设置
function LensEditFrameOkBtn_OnClick()
	m_EditLensParam:SaveSet()
	ShowGameTips(GetS(3940), 1)
	getglobal("LensEditFrame"):Hide()
	getglobal("TimeGridLenTip"..m_EditLensParam.curBtnIndex.."IconChecked"):Hide()
end

--滑动条
function ReplaySliderTemplateBar_OnValueChanged()
	local value = this:GetValue()
	local ratio = (value-this:GetMinValue())/(this:GetMaxValue()-this:GetMinValue())

	if ratio > 1 then ratio = 1 end
	if ratio < 0 then ratio = 0 end
	local width   = math.floor(327*ratio)

	getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width)
	getglobal(this:GetName().."Pro"):SetWidth(width)

	local index = this:GetParentFrame():GetClientID()
	local paramIndex = m_EditLensParam.curBtnIndex

	if m_EditLensParam.curLenNum > 0 then
		local t = m_EditLensParam.paramSet[paramIndex].slider[index]

		if t.ValShowType then
			if t.ValShowType == 'One_Decimal' then
				value = string.format("%.1f", value)
			elseif t.ValShowType == 'Percent' then
				value = string.format("%d", math.ceil(value))
			end
		end

		t.curval = value
		local valFont = getglobal(this:GetParent().."Val")
		local desc = getglobal(this:GetParent().."Desc")
		
		if t.ValShowType == 'Percent' then
			valFont:SetText(value.."%")
		else
			valFont:SetText(value)
		end
		
		if t.GetDesc then
			desc:SetText(t.GetDesc(tonumber(value)))
		end
	end
end

function ReplaySliderTemplateLeftBtn_OnClick()
	local bar = getglobal(this:GetParent().."Bar")
	local value = bar:GetValue()
	local index = this:GetParentFrame():GetClientID()
	local step = bar:GetValueStep()

	value = value - step
	bar:SetValue(value)

	--有修改
	m_EditLensParam.bDirty = true
end

function ReplaySliderTemplateRightBtn_OnClick()
	local bar = getglobal(this:GetParent().."Bar")
	local value = bar:GetValue()
	local index = this:GetParentFrame():GetClientID()
	local step = bar:GetValueStep()

	value = value + step
	bar:SetValue(value)

	--有修改
	m_EditLensParam.bDirty = true
end

function ReplaySliderTemplateBar_OnMouseUp()
	--有修改
	m_EditLensParam.bDirty = true
end

--勾选区域
function  ReplaySliderTemplate2_OnClick()
	local value = this:GetClientID()
	local index = this:GetParentFrame():GetClientID()
	if m_EditTextParam.curStringNum > 0 then
		local t = m_EditTextParam.paramSet[m_EditTextParam.curBtnIndex].slider[index]
		if value ~= t.curval then
			getglobal(this:GetName() .. "Tick"):Show()
			getglobal(this:GetParent() .."Btn" ..t.curval .. "Tick"):Hide()
		end
		t.curval = value
	end

	--刷新单位描述
	m_EditTextParam:updateSliderDesc()
end

--开关
function ReplaySwitchTemplate_OnMouseDown()
	local switchName 	= this:GetName()
	local state			= false
	local bkg 			= getglobal(this:GetName().."Bkg")
	local point 		= getglobal(switchName.."Point")
	if point:GetRealLeft() - bkg:GetRealLeft() > 33  then			--先前状态：开
		point:SetPoint("left", this:GetName(), "left", 0, 0)
		state = false
	else									--先前状态：关
		point:SetPoint("right", this:GetName(), "right", 0, 0)
		state = true
	end

	if string.find(switchName, "JTGLSwitch") then
		--镜头关联
		m_EditLensParam:SetJTGL(state)
	elseif string.find(switchName, "LoopSwitch") then
		--音乐循环
		m_EditMusicParam:SetLoop(state)
	end
end

------------------------------------编辑字幕------------------------------------
function SubtitleEditFrame_OnLoad()
	-- ReplayLayoutTabBtns("SubtitleEditFrameEditorTabs", 1, 1)
	-- m_EditTextParam.slider:Init()
end

function SubtitleEditFrame_OnShow()
	m_EditTextParam:Init()
	
	--游戏中调出界面时，显示鼠标
	ClientCurGame:setOperateUI(true)
end

function SubtitleEditFrame_OnHide()
	ClientCurGame:setOperateUI(false)
end

--设置字幕
function SubtitleEditFrameEditParamDescEdit_OnFocusLost()
	m_EditTextParam:SetContent()
end

function SubtitleEditFrameEditParamDescEdit_OnEnterPressed()
	SubtitleEditFrameEditParamDescEdit_OnFocusLost()
end

--设置时间
function SubtitleEditFrameEditParamTime1_OnFocusLost()
	m_EditTextParam:SetTime()
end

function SubtitleEditFrameEditParamTime1_OnEnterPressed()
	SubtitleEditFrameEditParamTime1_OnFocusLost()
end

function SubtitleEditFrameEditParamTime2_OnFocusLost()
	m_EditTextParam:SetTime()
end

function SubtitleEditFrameEditParamTime2_OnEnterPressed()
	SubtitleEditFrameEditParamTime2_OnFocusLost()
end

--保存字幕
function SubtitleEditFrameOkBtn_OnClick()
	m_EditTextParam:SaveSet()
	ShowGameTips(GetS(3940), 1)
	getglobal("SubtitleEditFrame"):Hide()
	getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."BkgChecked"):Hide()
	getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."Icon1Checked"):Hide()
	getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."Icon2Checked"):Hide()
end

--删除字幕
function SubtitleEditFrameDelBtn_OnClick()
	m_EditTextParam:DeleteOne()
end

function SubtitleEditFrameCloseBtn_OnClick()
	MessageBox(5, GetS(7512), function(btn)
			if btn == "left" then
				--确定
				getglobal("SubtitleEditFrame"):Hide()
				getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."BkgChecked"):Hide()
				getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."Icon1Checked"):Hide()
				getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."Icon2Checked"):Hide()

			end
		end
	)
end

--------------------------------------字幕显示界面--------------------------------------
local m_VideoRecordStringParam = {
	curSpeed = 1.0,

	Init = function(self)
		self.curSpeed = 1.0
	end,
}


function VideoRecordStringFrame_OnLoad()
	this:setUpdateTime(1)
end

function VideoRecordStringFrame_OnShow()
	m_VideoRecordStringParam:Init()

	--进入先暂停

	--音乐打点
	SetTimeScaleTips()
	--特效
	SetTimeSpecialEffectsTips()
end

function VideoRecordStringFrame_OnUpdate()
	local string1 = getglobal("VideoRecordStringFrameContent1")
	local string2 = getglobal("VideoRecordStringFrameContent2")
	local string3 = getglobal("VideoRecordStringFrameContent3")

	--1. 刷新字幕
	local nFont = 0

	if m_EditTextParam.curStringNum > 0 then
		local paramSet = m_EditTextParam.paramSet
		local curTime = RecordPkgMgr:getCurrentTime()

		if paramSet then
			Log("VideoRecordStringFrame_OnUpdate: ")

			for i = 1, #paramSet do
				if paramSet[i] then
					local startTime = paramSet[i].startTime
					local stopTime = startTime + paramSet[i].continueTime

					if startTime <= curTime and curTime < stopTime then
						Log("showString: i = " .. i)
						Log("curTime = " .. curTime .. ", startTime = " .. startTime .. ", stopTime = " .. stopTime)
						local content = paramSet[i].content
						local pos = paramSet[i].slider[1].curval
						local front = paramSet[i].slider[2].curval

						--字号
						nFont = front
						local stringUI = "VideoRecordStringFrameContent" .. front
						local string = getglobal(stringUI)

						Log("stringUI =" .. stringUI)

						if front == 1 then
							string2:SetText("")
							string3:SetText("")
						elseif front == 2 then
							string1:SetText("")
							string3:SetText("")
						else
							string1:SetText("")
							string2:SetText("")
						end

						--位置
						if pos == 1 then
							string:SetPoint("top", "VideoRecordStringFrame", "top", 0, 50)
						elseif pos == 2 then
							string:SetPoint("center", "VideoRecordStringFrame", "center", 0, 0)
						else
							string:SetPoint("bottom", "VideoRecordStringFrame", "bottom", 0, -50)
						end

						string:SetText(content)
						break
						-- return
					end
				end
			end
		end
	end

	if nFont <= 0 then
		string3:SetText("")
		string1:SetText("")
		string2:SetText("")
	end

	--音乐播放
	if not getglobal("MusicEditFrame"):IsShown() then
		local pauseState = RecordPkgMgr:isPause()
		if pauseState then  --是否为暂停
			ClientMgr:stopMusic()
		else
			local curtime = RecordPkgMgr:getCurrentTime()
			local paramSet = m_EditMusicParam.paramSet
			local bIsPlay = false

			for i = 1, #paramSet do
				if paramSet[i].start_time <= curtime and curtime <= (paramSet[i].start_time + paramSet[i].continued_time) then
					local index = tonumber(paramSet[i].content)
					bIsPlay = true

					if index ~= m_EditMusicParam.curPlayingIndex then
						local path = t_Edit_music[index]
						local loop = false
						if paramSet[i].loop == "1" then
							loop = true
						end

						ClientMgr:playMusic(path, loop)
						m_EditMusicParam.curPlayingIndex = index
						break
					end
				end
			end

			if not bIsPlay then
				m_EditMusicParam.curPlayingIndex = 0
				ClientMgr:stopMusic()
			end
		end
	end	
end

------------------------------------开始录像:lobby.xml中------------------------------------
local isRecordComplete = false
local m_VideoRecodParam = {
	bIsRecording = false,	--正在录制吗
	recordingTime = 0,		--录制时长, 单位秒
	curSpeed = 1.0,			--播放速度

	Init = function(self)
		self.bIsRecording = RecordPkgMgr:isRecordStarted()
		self.recordingTime = 0	--ms
		self.curSpeed = 1.0
	end,

	Start = function(self)
		self:Init()
		self.bIsRecording = true
	end,

	Stop = function(self)
		self.bIsRecording = false
	end,
}

function GongNengFrameVideoRecordBtn_OnClick()
	Log("GongNengFrameVideoRecordBtn_OnClick:")
	local stopTexture = getglobal("GongNengFrameStartRecordBtnStop")
	local startTexture = getglobal("GongNengFrameStartRecordBtnStart")
	local bkgTexture=getglobal("GongNengFrameStartRecordBtnBk")
	local timeRecord=getglobal("GongNengFrameStartRecordBtnRecordTime")

	isRecordComplete = false

	if startTexture:IsShown() then
		local worldDesc = AccountManager:getCurWorldDesc()
		if worldDesc.canrecord == 0 and worldDesc.owneruin ~= worldDesc.realowneruin then 
			ShowGameTips(GetS(7566), 3)
			return
		end

		--存档是否已满
		local curNum = GetCreateArchiveNum() --AccountManager:getMyWorldList():getMyCreateRecordNum()
		local sumNum = CreateArchiveMaxNum() --GetCreateRecordMapMax()
		Log("curNum = " .. curNum .. ", sumNum = " .. sumNum)
		if curNum >= sumNum then
			--可以[Desc5]则先弹[Desc5]的窗口
			if CanShowNotEnoughArchiveWithOperate(function () GongNengFrameVideoRecordBtn_OnClick() end) then
				return
			end
			
			ShowGameTips(GetS(7504), 3)
			return
		end

		if AccountManager:getMultiPlayer() == 0 or IsRoomOwner() then	--单机或者房主
			--开始
			ShowGameTips(GetS(7522), 3)
			startTexture:Hide()
			stopTexture:Show()
			bkgTexture:Show()
			timeRecord:Show()
			CSMgr:createWorldRecord()
			m_VideoRecodParam:Start()
			-- statisticsGameEvent(40001, "%lld", worldDesc.worldid)--开始录像埋点
		else
			ShowGameTips(GetS(7501), 3)
			return
		end

	else
		--停止
		MessageBox(5, GetS(7523), function(btn)
				if btn == "left" then
					--确定
					getglobal("GongNengFrameStartRecordBtnRecordTime"):SetText("00:00")
					ShowGameTips(GetS(7503), 3)
					CSMgr:stopGameRecord()
					m_VideoRecodParam:Stop()
					startTexture:Show()
					stopTexture:Hide()
					timeRecord:Hide()
					bkgTexture:Hide()
				else
					--取消
				end
			end
		)
	end
end

--隐藏录像按钮时调用
function VideoRecordStop()
	local stopTexture = getglobal("GongNengFrameStartRecordBtnStop")
	local startTexture = getglobal("GongNengFrameStartRecordBtnStart")
	local bkgTexture=getglobal("GongNengFrameStartRecordBtnBk")
	local timeRecord=getglobal("GongNengFrameStartRecordBtnRecordTime")

	getglobal("GongNengFrameStartRecordBtnRecordTime"):SetText("00:00")
	--ShowGameTips(GetS(7503), 3)
	CSMgr:stopGameRecord()
	m_VideoRecodParam:Stop()
	startTexture:Show()
	stopTexture:Hide()
	timeRecord:Hide()
	bkgTexture:Hide()
end

--是否显示录制按钮, 给lobby.lua中调用.
function ShowVideoRecordBtn()
	local isRecording = RecordPkgMgr:isRecordStarted()
	m_VideoRecodParam:Init()
	m_VideoRecodParam.bIsRecording = isRecording

	local roomType = AccountManager:getMultiPlayer()
	local recordState=AccountManager:getCurWorldRecordButton()
	if recordState==true and (2 ~= roomType) then	--房主才可以录制视频
		if isRecording then
			getglobal("GongNengFrameStartRecordBtn"):Show()
			getglobal("GongNengFrameStartRecordBtnStop"):Show()
			getglobal("GongNengFrameStartRecordBtnStart"):Hide()
			getglobal("GongNengFrameStartRecordBtnBk"):Show()
			getglobal("GongNengFrameStartRecordBtnRecordTime"):Show()
		else
			getglobal("GongNengFrameStartRecordBtn"):Show()
			getglobal("GongNengFrameStartRecordBtnStop"):Hide()
			getglobal("GongNengFrameStartRecordBtnStart"):Show()
			getglobal("GongNengFrameStartRecordBtnBk"):Hide()
			getglobal("GongNengFrameStartRecordBtnRecordTime"):Hide()
			getglobal("GongNengFrameStartRecordBtnRecordTime"):SetText("00:00")
		end
	else
		Log("recordingInterface_state = false" )
		Log("multi = " .. AccountManager:getMultiPlayer())
		getglobal("GongNengFrameStartRecordBtn"):Hide()
	end
end

--是否正在录
function IsVideoRecording()
	if ClientCurGame and ClientCurGame:isInGame() and m_VideoRecodParam.bIsRecording then
		return true
	else
		return false
	end
end

--更细录像时间
function UpdateVideoRecordTime()
	--0.1s进来一次
	m_VideoRecodParam.recordingTime = RecordPkgMgr:getCurrentTime()
	local time = m_VideoRecodParam.recordingTime
	local timeUI = getglobal("GongNengFrameStartRecordBtnRecordTime")
	local text = os.date("%M:%S", time / 1000)

	timeUI:SetText(text)
	if time >= 900000 and not isRecordComplete then
		ShowGameTips(GetS(7535),3)
		isRecordComplete = true
	end
end

--进入录像存档, 参考"SurviveGame_Enter", 都是在c++中调用
function GameSurviveRecord_Enter()
	Log("GameSurviveRecord_Enter:")

	--初始化移到这里, 免得编辑和预览要写两次
	----------------------------------------------
	--总时长
	m_MainParam.sumTime = RecordPkgMgr:getTotalTime()
	Log("sumTime = " .. m_MainParam.sumTime)

	--初始化
	m_EditLensParam:Init()
	m_EditTextParam:Init()
	m_EditMusicParam:Init()
	m_EditSpecialEffectsParam:Init()
	----------------------------------------------

	--字幕界面
	getglobal("VideoRecordStringFrame"):Show()

	if RecordPkgMgr:isEdit() then
		--编辑模式
		--RecordPkgMgr:setEdit(true)
		RecordUpdateSpeedUI(1.0)
		getglobal("ReplayTheaterFrame"):Show()
		getglobal("VideoHandleFrame"):Hide()
		getglobal("VideoHandleReplayTheaterFrame"):Hide()
	else
		--播放模式
		--1. 打开操作界面
		--RecordPkgMgr:setEdit(false)
		if IsUserOuterChecker(AccountManager:getUin()) then
			getglobal("VideoHandleReplayTheaterFrame"):Show()
		else
			getglobal("VideoHandleReplayTheaterFrame"):Hide()
		end
		
		getglobal("VideoHandleFrame"):Show()
		getglobal("ReplayTheaterFrame"):Hide()
		-- ClientMgr:setGameData("hideui", 1)

		--2. 打开功能界面(只保存设置按钮)
		-- getglobal("GongNengFrame"):Show()
		-- InteractiveBtn_ShowOrHide(false)
		-- getglobal("GongNengFrameMenu"):Hide()
		-- getglobal("GongNengFrameMenuArrow"):Hide()
		-- getglobal("GongNengFrameRuleSetGNBtn"):Hide()
		-- getglobal("GongNengFrameScreenshotBtn"):Hide()
		-- getglobal("GongNengFrameStartRecordBtn"):Hide()
	end

	if RecordPkgMgr:canRecordVideo() and not m_MainParam.bIsPreview then           --只有pc端能导出视频,编辑页面进入预览隐藏导出按钮
		getglobal("VideoHandleFrameExportBtn"):Show() 
		getglobal("VideoHandleFramePlayBtn"):Show()
	else
		getglobal("VideoHandleFrameExportBtn"):Hide() 
	end

	--导出时间提示
	local tipsTime = getglobal("LoadingFrameTips")
	if RecordPkgMgr:isRecordVideo() then
		getglobal("VideoHandleFrameExportBtn"):Hide()
		getglobal("VideoHandleFramePlayBtn"):Hide()
		tipsTime:SetText(GetS(7587,formatTime(m_MainParam.sumTime/1000)))
		tipsTime:Show()

	else
		tipsTime:Hide()
	end


	--导出按钮隐藏
	getglobal("GameVideoConversionFrame"):Hide()
	
end

function GameSurviveRecord_Quit()
	Log("GameSurviveRecord_Quit:")
	getglobal("VideoHandleFrame"):Hide()
	--getglobal("GongNengFrame"):Hide()
	getglobal("VideoRecordStringFrame"):Hide()

	--VideoRecordEscCloseFrame()
	local frames = {
		"LensEditFrame",
		"SubtitleEditFrame",
		"MusicEditFrame",
	}

	for i = 1, #frames do
		if getglobal(frames[i]):IsShown() then
			getglobal(frames[i]):Hide()
		end
	end
	getglobal("ReplayTheaterFrame"):Hide()
	getglobal("VideoHandleReplayTheaterFrame"):Hide()
end

--esc快捷键关闭相关窗口
function VideoRecordEscCloseFrame()
	Log("VideoRecordEscCloseFrame:")

	local frames = {
		"LensEditFrame",
		"SubtitleEditFrame",
		"MusicEditFrame",
	}

	--for i = 1, #frames do
	--	if getglobal(frames[i]):IsShown() then
	--		getglobal(frames[i]):Hide()
	--	end
	--end
	if IsUIFrameShown("GameVideoConversionFrame") then
		getglobal("GameVideoConversionFrame"):Hide()
	elseif IsUIFrameShown("VideoHandleFrame") then
		VideoHandleFramePlayCloseBtn_OnClick()
		return
	end
	
	if IsUIFrameShown("LensEditFrame") then
		LensEditFrameCloseBtn_OnClick()
	elseif IsUIFrameShown("SubtitleEditFrame") then
		SubtitleEditFrameCloseBtn_OnClick()
	elseif IsUIFrameShown("MusicEditFrame") then
		MusicEditFrameCloseBtn_OnClick()
	elseif IsUIFrameShown("SpecialEffectsEditFrame") then
		SpecialEffectsEditFrameCloseBtn_OnClick()
	elseif IsUIFrameShown("ReplayTheaterFrame") then
		ReplayTheaterFrameCloseBtn_OnClick()
	end


end

--播放速度调整+-
function TimerShaftFrameAddSpeed_OnClick(id)
	Log("m_VideoRecodParam.curSpeed = " .. m_VideoRecodParam.curSpeed)

	if id and id == 1 then
		--减
		m_VideoRecodParam.curSpeed = m_VideoRecodParam.curSpeed - 0.5
	else
		--加
		m_VideoRecodParam.curSpeed = m_VideoRecodParam.curSpeed + 0.5
	end

	if m_VideoRecodParam.curSpeed < 0.5 then
		m_VideoRecodParam.curSpeed = 0.5
	end

	if m_VideoRecodParam.curSpeed > 2.0 then
		m_VideoRecodParam.curSpeed = 2.0
	end

	RecordPkgMgr:setSpeed(m_VideoRecodParam.curSpeed)
	RecordUpdateSpeedUI(m_VideoRecodParam.curSpeed)
end

--更新速度显示
function RecordUpdateSpeedUI(_speed)
	if _speed then
		local speed = tonumber(_speed)
		Log("RecordUpdateSpeedUI: speed = " .. speed)

		m_VideoRecodParam.curSpeed = speed
		getglobal("TimerShaftFrameSpeedDesc"):SetText(GetS(7510) .. " X" .. m_VideoRecodParam.curSpeed)
	end
end



--录像导出显示logo
local isLoadingFrameShow = false 
function VideoFrameScreenShow()
	local worldDesc = AccountManager:getCurWorldDesc()
	if worldDesc then
		getglobal("VideoExportLogoFrameVideoAuthor"):SetText(GetS(7563)..ReplaceFilterString(AccountManager:getNickName()))--"视频作者："
		getglobal("VideoExportLogoFrameUin1"):SetText(GetS(359).. GetMyUin())--"迷你号:"
		getglobal("VideoExportLogoFrameMapAuthor"):SetText(GetS(7564).. worldDesc.realNickName)--"地图作者："
		getglobal("VideoExportLogoFrameUin2"):SetText(GetS(359).. worldDesc.realowneruin)--"迷你号:"
	else
		Log("VideoFrameScreenShow worldDesc is nil")
	end

	if g_IsShowVideMessageBox then
		getglobal("MessageBoxFrame"):Hide()
	end


	getglobal("VideoHandleFrame"):Hide()
	getglobal("VideoExportLogoFrame"):Show()
	if getglobal("LoadingFrame"):IsShown() then
		getglobal("LoadingFrame"):Hide()
		isLoadingFrameShow = true
	end
end

-- 隐藏logo
function VideoFrameScreenHide()
	if g_IsShowVideMessageBox then
		getglobal("MessageBoxFrame"):Show()
	end

	getglobal("VideoHandleFrame"):Show()
	getglobal("VideoExportLogoFrame"):Hide()
	if isLoadingFrameShow and RecordPkgMgr:isRecordVideo() then
		getglobal("LoadingFrame"):Show()
		isLoadingFrameShow = false
	end
end

------------------------------------录像操作界面:VideoHandleFrame------------------------------------
local m_VideoHandleParam = {
	bIsPlaying = true,
	sumTime = 0,
	curTime = 0,

	Init = function(self)
		Log("m_VideoHandleParam:Init:")
		self.sumTime = RecordPkgMgr:getTotalTime()
		self.curTime = 0
		self.bIsPlaying = true
	end,

	SetTimeView = function(self, _curTime)
		local curTime = os.date("%M:%S", _curTime / 1000)
		local sumTime = os.date("%M:%S", self.sumTime / 1000)
		local text = curTime .. "/" .. sumTime

		getglobal("VideoHandleFramePlayBtnTime"):SetText(text)
	end,
}

function VideoHandleFrame_OnLoad()
	this:setUpdateTime(1)
end

function VideoHandleFrame_OnShow()
	Log("VideoHandleFrame_OnShow:")
	m_VideoHandleParam:Init()

	--初始化时间显示
	m_VideoHandleParam:SetTimeView(0)

	--展示时默认播放
	VideoHandleFrame_SetPlayBtnState(false)

	--检查是否评论过
	local worldDesc = AccountManager:getCurWorldDesc()
	if worldDesc.realowneruin > 1 and worldDesc.owneruin ~= worldDesc.realowneruin then
		RequestCheckMapsComment(worldDesc.fromowid)	
	end

	--[[设置打赏状态]]
	MapRewardClass:SetMapsReward(worldDesc.fromowid, worldDesc.realowneruin, worldDesc.RealNickName,worldDesc.ownerIconFrame)
end

--暂停, 开始播放
function VideoHandleFramePlayBtn_OnClick()
	local startBkg = getglobal("VideoHandleFramePlayBtnStart")

	if startBkg:IsShown() then
		--暂停-->播放
		VideoHandleFrame_SetPlayBtnState(false)
	else
		--播放-->暂停
		VideoHandleFrame_SetPlayBtnState(true)
	end
end

--导出
function VideoHandleFrameExportBtn_OnClick()
	if getglobal("GameVideoConversionFrame"):IsShown() then
		getglobal("GameVideoConversionFrame"):Hide()
	else
		getglobal("GameVideoConversionFrame"):Show()
	end
end

function VideoHandleFrame_SetPlayBtnState(bIsPause)
	Log("VideoHandleFrame_SetPlayBtnState:")
	local startBkg = getglobal("VideoHandleFramePlayBtnStart")
	local stopBkg = getglobal("VideoHandleFramePlayBtnStop")

	if bIsPause then
		startBkg:Show()
		stopBkg:Hide()
		RecordPkgMgr:setPause(true)
		m_VideoHandleParam.bIsPlaying = false
	else
		startBkg:Hide()
		stopBkg:Show()
		RecordPkgMgr:setPause(false)
		m_VideoHandleParam.bIsPlaying = true
	end
end


function VideoHandleFrame_OnUpdate()
	if isEducationalVersion then
		return
	end
		
	if m_VideoHandleParam.bIsPlaying or RecordPkgMgr:isRecordVideo() then
		local sumTime = os.date("%M:%S", m_VideoHandleParam.sumTime / 1000)
		local nCurTime = RecordPkgMgr:getCurrentTime()

		Log("VideoHandleFrame_OnUpdate = nCurTime = " .. nCurTime)
		if nCurTime > m_VideoHandleParam.sumTime then nCurTime = m_VideoHandleParam.sumTime end
		local curTime = os.date("%M:%S", nCurTime / 1000)
		local text = curTime .. "/" .. sumTime

		getglobal("VideoHandleFramePlayBtnTime"):SetText(text)

		if nCurTime >= m_VideoHandleParam.sumTime then
			VideoHandleFrame_SetPlayBtnState(true)
			--重新播放
			if not m_MainParam.bIsPreview then 
				if  RecordPkgMgr:isRecordVideo() then
					if RecordPkgMgr:getEncodeVideoRate() == 100 then
						g_IsShowVideMessageBox = false
						MessageBox(4, GetS(7588) , function(btn)
							MainMenuBtn_OnClick()
						end)
					end
				else
					MessageBox(5, GetS(7560) , function(btn)
						if btn=='left' then
							local worldDesc = AccountManager:getCurWorldDesc()
							ClientMgr:gotoGame("none")
							RequestEnterWorld(worldDesc.worldid, false, function(succeed)
								if succeed then
								  RecordPkgMgr:setEdit(false)
								  ShowLoadingFrame()
								  HideLobby()
	  							  RecordPkgMgr:executePkgToTick(0) 	
								end
							end)
		
						elseif btn == 'right' then
							MainMenuBtn_OnClick()
						end
					end)
				end
			end


		end
	end
end

function VideoHandleFramePlayCloseBtn_OnClick()
	Log("VideoHandleFramePlayCloseBtn_OnClick:")

	local text = GetS(7555)
	if  RecordPkgMgr:isRecordVideo() then
		text = GetS(7586)
	end

	g_IsShowVideMessageBox =true

	if m_MainParam.bIsPreview then
		--退回编辑模式
		Log("go out preview")
		--Record_EnterPreview(false)
		MessageBox(5, text, function(btn)
				if btn == "left" then              --确定
					g_IsShowVideMessageBox = false
					-- MainMenuBtn_OnClick()
					if RecordPkgMgr:isRecordVideo() then
						--导出视频中，退出存档
						MainMenuBtn_OnClick()
					else
						--退回到编辑模式
						Record_EnterPreview(false)
					end
				elseif btn == "right" then
					g_IsShowVideMessageBox = false
				end
			end
		)
	else
		local worldDesc = AccountManager:getCurWorldDesc()
		if worldDesc.realowneruin > 1 and worldDesc.owneruin ~= worldDesc.realowneruin then
			--别人的地图, 判断是否评论
			Log("other")
			--MainMenuBtn_OnClick()
			RecordQuitOtherMapShowCommentFrame()
		else
			--自己的地图
			--退出存档
			Log("myself")
			MessageBox(5, text, function(btn)
					if btn == "left" then           --确定
						local nCurTime = RecordPkgMgr:getCurrentTime()

						--没录制完成
						if nCurTime < m_VideoHandleParam.sumTime then
							--中途退出，停止录制
							RecordPkgMgr:stopRecordVedio(true)
						else 
							RecordPkgMgr:stopRecordVedio(false)
						end
						
						g_IsShowVideMessageBox = false


						--退出存档
						MainMenuBtn_OnClick()
						getglobal("LoadingFrame"):SetFrameStrataInt(9)
						getglobal("LoadingFrame"):Hide()

					elseif btn == "right" then
						g_IsShowVideMessageBox = false
					end
				end
			)
		end
	end
end


--确定导出
function GameVideoConversionFrameAgreeBtn_OnClick()
	local worldDesc = AccountManager:getCurWorldDesc()
	
	if RecordPkgMgr:getLeftSize() > 0 and RecordPkgMgr:getLeftSize()<200 + (RecordPkgMgr:getTotalTime()/1000) then		
		MessageBox(4, GetS(7505) , function(btn)
			MainMenuBtn_OnClick()
		end)
	elseif not RecordPkgMgr:isNewRecordVedioExist(worldDesc.worldid) then    --导出录像
		--回退重播
		ClientMgr:gotoGame("none")
		RequestEnterWorld(worldDesc.worldid, false, function(succeed)
			if succeed then
				RecordPkgMgr:setEdit(false)
				ShowLoadingFrame()
				HideLobby()
				RecordPkgMgr:executePkgToTick(0)
				--录制
				RecordPkgMgr:startRecordVedio(worldDesc.worldid)
				getglobal("LoadingFrame"):SetFrameStrataInt(5)
				getglobal("LoadingFrame"):Show()
			end
		end)
		
	else
		ShowGameTips(GetS(7589),3)
	end

	getglobal("GameVideoConversionFrame"):Hide()
end

--取消
function GameVideoConversionFrameRefuseBtn_OnClick()
	getglobal("GameVideoConversionFrame"):Hide()
end

function GameVideoConversionFrame_OnShow()
	local worldDesc = AccountManager:getCurWorldDesc()
	local time = RecordPkgMgr:getTotalTime()/1000
	getglobal("GameVideoConversionFrameContentText"):SetText(GetS(7584,worldDesc.worldname,string.format("%d",time).."M",formatTime(time),RecordPkgMgr:getVedioPath()))
end

--退出下载录像, 弹出评测框
function RecordQuitOtherMapShowCommentFrame()
	Log("RecordQuitOtherMapShowCommentFrame:")
	local worldDesc = AccountManager:getCurWorldDesc()
	if RecordPkgMgr:isRecordVideo() then
		MessageBox(5, GetS(7586), function(btn)
				if btn == "left" then              --确定
					--导出视频中，退出存档
					g_IsShowVideMessageBox = false
					RecordPkgMgr:stopRecordVedio(true)
					MainMenuBtn_OnClick()

					getglobal("LoadingFrame"):SetFrameStrataInt(9)
					getglobal("LoadingFrame"):Hide()
				elseif btn == "right" then
					g_IsShowVideMessageBox = false
				end
			end
		)
	elseif not IsCommended then
		getglobal("SetMenuFrame"):Hide()
		MessageBox(23, GetS(3860), nil, nil, true, nil, true)
		getglobal("MessageBoxFrame"):SetClientString( "离开地图时评分" )
	elseif MapRewardClass:IsOpen() and worldDesc and worldDesc.fromowid and MapRewardClass:GetRewardState(worldDesc.fromowid) == 0 then
		getglobal("SetMenuFrame"):Hide()
		MessageBox(33, GetS(21786), nil, nil, true, nil, true)
		getglobal("MessageBoxFrame"):SetClientString( "支持一下" )
	else
		GoToMainMenu()
	end
end


-----------------------------------------------------编辑特效界面----------------------------------------------------------------------
local SPECIAL_EFFECTS_NUM_MAX = 4





function SpecialEffectsEditFrame_OnLoad()
	for i=1,SPECIAL_EFFECTS_NUM_MAX/2 do

		for j=1,2 do
			local item = getglobal("SpecialEffectsEditFrameParamBtn"..((i-1)*2+j))
			local name = getglobal("SpecialEffectsEditFrameParamBtn"..((i-1)*2+j).."Name")
			local Icon = getglobal("SpecialEffectsEditFrameParamBtn"..((i-1)*2+j).."Normal")
			item:SetPoint("bottomleft", "SpecialEffectsEditFrameParamSpecialEffect", "bottomleft", (j-1)*270+113, (i-1)*150+55)
			name:SetText(SpecialEffectsList[((i-1)*2+j)])
			Icon:SetTexUV(SpecialEffectsListIcon[((i-1)*2+j)])
		end
	end
end

function SpecialEffectsEditFrame_OnShow()

	m_EditSpecialEffectsParam:Init()
	m_EditSpecialEffectsParam:AddSpecialEffects()
	--游戏中调出界面时，显示鼠标
	ClientCurGame:setOperateUI(true)
end

function SpecialEffectsEditFrame_OnHide()
	
	ClientCurGame:setOperateUI(false)
end

function SpecialEffectsEditFrameCloseBtn_OnClick()

	MessageBox(5, GetS(7583), function(btn)
			if btn == "left" then
				--确定
				m_EditSpecialEffectsParam:CloseBtn()
				getglobal("SpecialEffectsEditFrame"):Hide()
				getglobal("TimeGridSpecialEffectsTip"..m_EditSpecialEffectsParam.curBtnIndex.."BkgChecked"):Hide()
				getglobal("TimeGridSpecialEffectsTip"..m_EditSpecialEffectsParam.curBtnIndex.."Icon1Checked"):Hide()
				getglobal("TimeGridSpecialEffectsTip"..m_EditSpecialEffectsParam.curBtnIndex.."Icon2Checked"):Hide()

			end
		end
	)


end




function SpecialEffectsBtnTemplate_OnClick()
	local num = this:GetClientID()
	for i=1,#SpecialEffectsList do
		if i == num then
			getglobal("SpecialEffectsEditFrameParamBtn"..num.."Checked"):Show()
		else
			getglobal("SpecialEffectsEditFrameParamBtn"..i.."Checked"):Hide()
		end
	end
	m_EditSpecialEffectsParam:SetContent(num)
end



function SpecialEffectsEditFrameEditParamTime1_OnFocusLost()
	m_EditSpecialEffectsParam:SetSpecialEffectsTime()
end

function SpecialEffectsEditFrameEditParamTime1_OnEnterPressed()
	SpecialEffectsEditFrameEditParamTime1_OnFocusLost()
end

function SpecialEffectsEditFrameEditParamTime2_OnFocusLost()
	m_EditSpecialEffectsParam:SetSpecialEffectsTime()
end

function SpecialEffectsEditFrameEditParamTime2_OnEnterPressed()
	SpecialEffectsEditFrameEditParamTime2_OnFocusLost()
end


--保存特效
function SpecialEffectsEditFrameOkBtn_OnClick()
	m_EditSpecialEffectsParam:SaveSpecialEffects()
	ShowGameTips(GetS(3940), 1)
	getglobal("SpecialEffectsEditFrame"):Hide()
	-- getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."BkgChecked"):Hide()
	-- getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."Icon1Checked"):Hide()
	-- getglobal("TimeGridString"..m_EditTextParam.curBtnIndex.."Icon2Checked"):Hide()
end


function SpecialEffectsEditFrameDelBtn_OnClick()
	m_EditSpecialEffectsParam:DeleteSpecialEffects()
end


function SetTimeSpecialEffectsTips()

	Log("SetTimeScaleTips:")
	--m_EditMusicParam:Init()

	local firstUI = "TimeGridSpecialEffectsTip"
	local infoList = m_EditSpecialEffectsParam.paramSet
	local sumTime = m_EditSpecialEffectsParam.sumTime
	local curTime = RecordPkgMgr:getCurrentTime()

	for i = 1, 40 do
		local tipUI = firstUI .. i
		local tip = getglobal(tipUI)
		local bkg = getglobal(tipUI .. "Bkg")
		local txt1 = getglobal(tipUI .. "Txt1")
		local txt2 = getglobal(tipUI .. "Txt2")
		local bkgChecked=getglobal(tipUI .. "BkgChecked")
		local icon1Checked = getglobal(tipUI .. "Icon1Checked")
		local icon2Checked = getglobal(tipUI .. "Icon2Checked")

		if i <= #infoList then
			local paramSet = infoList[i]
			local x = math.floor(paramSet.start_time / 1000) * 1000 / sumTime * 996
			local width = math.floor(paramSet.continued_time / 1000) * 1000 / sumTime * 996
			if paramSet.start_time + paramSet.continued_time >= sumTime then
				if curTime <= sumTime then
					width = math.floor((sumTime - paramSet.start_time) / 1000) * 1000 / sumTime * 996
				else
					width = math.floor((curTime - sumTime+1000) / 1000) * 1000 / sumTime * 996
				end
			end
			Log("paramSet.start_time = " .. paramSet.start_time .. ", paramSet.continued_time = " .. paramSet.continued_time .. ", x = " .. x .. ", width = " .. width)
			tip:SetPoint("bottomleft", "TimerShaftFrameTimeScale", "bottomleft", x, 20)
			tip:Show()
			tip:SetWidth(width)
			bkg:SetWidth(width)
			txt1:SetText(i)
			txt2:SetText(i)

			--被选中的音乐在时间轴上高亮标记
			if i==m_EditSpecialEffectsParam.curBtnIndex and getglobal("SpecialEffectsEditFrame"):IsShown() then
				bkgChecked:SetWidth(width)
				icon1Checked:Show()
				icon2Checked:Show()
				bkgChecked:Show()
			else
				icon1Checked:Hide()
				icon2Checked:Hide()
				bkgChecked:Hide()
			end

		else
			tip:Hide()
		end
	end
end

function formatTime(time)
    local minute = math.fmod(math.floor(time/60), 60)
    local second = math.fmod(time, 60)
    local rtTime = string.format("%d:%d",minute, second)
    return rtTime
end



function VideoHandleReplayTheaterFrame_OnLoad()
	this:setUpdateTime(0.1)
end

function VideoHandleReplayTheaterFrameCloseBtn_OnClick()
	MessageBox(5, GetS(7536), function(btn)
			if btn == "left" then
				--确定
				--退出存档
				MainMenuBtn_OnClick()
				getglobal("VideoHandleReplayTheaterFrame"):Hide()
			end
		end
	)
end

function VideoHandleReplayTheaterFrame_OnEvent()

end

function VideoHandleReplayTheaterFrame_OnUpdate()
	if not RecordPkgMgr:isPause() then
		--播放中, 走进度条
		local curTime = RecordPkgMgr:getCurrentTime()
		local maxValue = getglobal("VideoHandleTimerShaftFrameTimePointerBar"):GetMaxValue()
		local curValue = curTime / m_MainParam.sumTime * maxValue

		getglobal("VideoHandleTimerShaftFrameTimePointerBar"):SetValue(curValue)
	end
end

function VideoHandleReplayTheaterFrame_OnShow()
	Log("VideoHandleReplayTheaterFrame_OnShow:")
	
	RecordPkgMgr:setSpeed(m_VideoRecodParam.curSpeed)
	VideoHandle_RecordUpdateSpeedUI(m_VideoRecodParam.curSpeed)

	--展示时默认播放
	VideoHandleFrame_SetPlayBtnState(false)

	--设置时间刻度
	VideoHandle_InitTimeScaleFrame()
end

function VideoHandleReplayTheaterFrame_OnHide()

end

--时间刻度***********************
function VideoHandle_InitTimeScaleFrame()
	Log("VideoHandle_InitTimeScaleFrame:")

	--new
	local sumTime = m_MainParam.sumTime
	local sumSecond = sumTime / 1000
	local sumWidth = m_MainParam.sumWidth	--960
	local singleTime = 1
	if sumSecond <= 60 then
		singleTime = 1
	else
		singleTime = math.ceil(sumSecond / 60)
	end

	local sumScale = sumSecond / singleTime
	local singleWidth = sumWidth / sumScale

	Log("sumScale = " .. sumScale .. ", singleWidth = " .. singleWidth .. ", singleTime = " .. singleTime)

	for i = 1, 61 do
		local itemUI = "VideoHandleTimerShaftFrameTimeScaleTimeGrid" .. i
		local item = getglobal(itemUI)
		local long = getglobal(itemUI .. "UV1")
		local short = getglobal(itemUI .. "UV2")
		local time2 = getglobal(itemUI .. "Time2")

		item:SetPoint("bottomleft", "VideoHandleTimerShaftFrameTimeScale", "bottomleft", (i - 1) * singleWidth, -75)

		if i <= sumScale + 1 then
			item:Show()

			if i % 5 == 1 then
				long:Show()
				short:Hide()
				time2:Show()
				time2:SetText(os.date("%M:%S", singleTime * (i - 1)))
				item:SetPoint("bottomleft", "VideoHandleTimerShaftFrameTimeScale", "bottomleft", (i - 1) * singleWidth, -64)
			else
				long:Hide()
				short:Show()
				time2:Hide()
			end
		else
			item:Hide()
		end

		
	end

	--设置时间拖动条
	local timeBar = getglobal("VideoHandleTimerShaftFrameTimePointerBar")
	timeBar:SetMinValue(0)
	timeBar:SetMaxValue(sumSecond)
	timeBar:SetValueStep(1)

	--设置初始值
	local curTime = RecordPkgMgr:getCurrentTime()
	local maxValue = getglobal("VideoHandleTimerShaftFrameTimePointerBar"):GetMaxValue()
	local curValue = curTime / m_MainParam.sumTime * maxValue
	timeBar:SetValue(curValue)
end

function VideoHandleTimerShaftFrameTimePointBar_OnValueChanged( ... )
	local  value = this:GetValue()
end

function VideoHandleTimerShaftFrameTimePointBar_OnMouseUp()
	local value = this:GetValue()
	Log("TimePointBar_OnMouseUp: value = " .. value)

	VideoHandle_RecordGoForwardOrBack(value * 1000)
end

function VideoHandleTimerShaftFrameTimePointBar_OnMouseDown()
	--按下的时候先暂停, 一面一边跑进度, 一遍又拖动进度, 时间点冲突
	if not RecordPkgMgr:isPause() then
		VideoHandleFrame_SetPlayBtnState(true)
	end
end

--播放速度调整+-
function VideoHandleTimerShaftFrameAddSpeed_OnClick(id)
	Log("m_VideoRecodParam.curSpeed = " .. m_VideoRecodParam.curSpeed)

	if id and id == 1 then
		--减
		m_VideoRecodParam.curSpeed = m_VideoRecodParam.curSpeed - 1
	else
		--加
		m_VideoRecodParam.curSpeed = m_VideoRecodParam.curSpeed + 1
	end

	if m_VideoRecodParam.curSpeed < 1 then
		m_VideoRecodParam.curSpeed = 1
	end

	if m_VideoRecodParam.curSpeed > 4 then
		m_VideoRecodParam.curSpeed = 4
	end

	RecordPkgMgr:setSpeed(m_VideoRecodParam.curSpeed)
	VideoHandle_RecordUpdateSpeedUI(m_VideoRecodParam.curSpeed)
end

--更新速度显示
function VideoHandle_RecordUpdateSpeedUI(_speed)
	if _speed then
		local speed = tonumber(_speed)
		Log("RecordUpdateSpeedUI: speed = " .. speed)

		m_VideoRecodParam.curSpeed = speed
		getglobal("VideoHandleTimerShaftFrameSpeedDesc"):SetText(GetS(7510) .. " X" .. m_VideoRecodParam.curSpeed)
	end
end

--前进/后退
function VideoHandle_RecordGoForwardOrBack(gotoTime)
	Log("VideoHandle_RecordGoForwardOrBack:")
	local sumTime = m_MainParam.sumTime
	local curTime = RecordPkgMgr:getCurrentTime()
	Log("sumTime = " .. sumTime .. ", curTime = " .. curTime .. ", gotoTime = " .. gotoTime)

	if gotoTime > curTime then
		--前
		Log("go forward...")

		if RecordPkgMgr:isPause() then
			VideoHandleFrame_SetPlayBtnState(false)
		end
		RecordPkgMgr:executePkgToTick(gotoTime)
	elseif gotoTime < curTime then
		--后
		Log("go back...")

		local worldDesc = AccountManager:getCurWorldDesc()
		ClientMgr:gotoGame("none")
		RequestEnterWorld(worldDesc.worldid, false, function(succeed)
			if succeed then
			  RecordPkgMgr:setEdit(false)
			  ShowLoadingFrame()
			  HideLobby()
  			  RecordPkgMgr:executePkgToTick(gotoTime) 	
			end
		end)
	end
end