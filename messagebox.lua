
--[[
--   	推荐使用uiconfig\messagebox.lua进行开发
--		文件只保留旧版本的功能
-- ]]
local t_type = {
		--1 删除 取消
		{
		 --: leftTexture: 左按钮背景, 红色.
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=3017, rightNameId = 3018--, leftTexture = "dtxx_button_quxiao"
		},
		--2 继续分享 取消
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=3047, rightNameId = 3018
		},
		--3 去升级 取消
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=3054, rightNameId = 3018
		},
		--4 确定
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 centerNameId=3010
		},
		--5 确定 取消
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=3010, rightNameId = 3018
		},
		--6 进入教学 跳过
		{
		 iconPath = "ui/mobile/ui4.png", uv={x=952,y=230,w=69,h=70},
		 leftNameId=428, rightNameId = 429, leftUvA = true,
		},
		--7 继续 取消
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=430, rightNameId = 3018
		},
		--8 继续游戏 退出游戏
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=431, rightNameId = 3053,
		},
		--9 去激活 取消
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=432, rightNameId = 3018
		},
		--10 重试
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 centerNameId=433
		},
		--11 继续下载 取消
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=434, rightNameId = 3018
		},
		--12 重试 [Desc2]帮助 
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=433, rightNameId = 723
		},
		--13 订单已取消 [Desc7]遇到问题 
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=787, rightNameId = 788
		},
		--14 (无按钮)
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		},
		--15 确定 取消
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=3861, rightNameId = 3862
		},
		--16 继续教学 退出
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=3761, rightNameId = 3762
		},
		--17 立即认证
		{
		iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		leftNameId=4836, rightNameId=4838
		},
		--18 加入 离开
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=4887, rightNameId = 4883
		},
		--19 前往 取消
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=5241, rightNameId = 3018
		},
		--20 联机玩 排队
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=1065, rightNameId = 1066
		},
		--21 直接开始 前往分享
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=9140, rightNameId = 9141
		},
		--22 取消 前往清理
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=3018, rightNameId = 7303
		},
		--23 去测评 直接退出
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=1287, rightNameId = 3862--, leftTexture = "szjm_btn_hdyx"
		},	
		--24 取消 保存
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=3018, rightNameId = 3934--, rightTexture = "szjm_btn_hdyx"
		},
		--25: 暂不下载 确定下载
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 	leftNameId=9171, rightNameId = 9172--, rightTexture = "szjm_btn_hdyx"
		},
		--26： 退出游戏
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 	centerNameId=9228,
		},

		--27: 退出  保存
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 	leftNameId=3862,rightNameId = 9192--, leftTexture = "szjm_btn_hdyx",rightTexture = "juese_anniu_huang"
		},
		--28: 确认分享  取消
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 	leftNameId=381, rightNameId = 3018--, leftTexture = "szjm_btn_hdyx",rightTexture = "juese_anniu_huang"
		},

        --29: 立即认证, 退出游戏
        {
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
            leftNameId=4836, rightNameId=3862,
        },
        --30: 稍等 , 退出游戏
        {
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
            leftNameId=20509, rightNameId=3862,
        },
		--31 取消 确定
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=3018, rightNameId = 3010--, leftTexture = "juese_anniu_huang",rightTexture = "szjm_btn_hdyx"
		},
	    --32 取消 前往认证
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=970, rightNameId = 21682--, leftTexture = "juese_anniu_huang",rightTexture = "szjm_btn_hdyx",rightUvA = false,
		},
		--33 支持一下 直接退出
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=21778, rightNameId = 3862--, leftTexture = "szjm_btn_hdyx"
		},	
		--34 解散 取消
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=20638, rightNameId = 3018--, leftTexture = "dtxx_button_quxiao"
		},
		--35 重试 退出
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=12606, rightNameId = 12611,
		},
		--36 稍后关闭 关闭并升级
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=9544, rightNameId = 9543,
		},
		--37 取消 前往查看
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=970, rightNameId = 9697,
		},
		--38 重新绑定身份证 确认
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=22026, rightNameId = 969,
		},
		--39 进行手机绑定 关闭
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=22027, rightNameId = 3536,
		},
		--40: 立即认证, 取消
        {
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
            leftNameId=4836, rightNameId=3018,
        },
        --41: 手机验证, 取消
        {
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
            leftNameId=100207, rightNameId=3018,
        },
        --42 确定 忽略
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=3010, rightNameId = 34000
		},
		--43 单机模式 重试
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=25831, rightNameId = 12606
		},
		--44 单机模式 取消
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=25831, rightNameId = 3018
		},
		--45 存档上传失败 确定
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 	centerNameId=969,
		},
		--46 保持现状 创建新号
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=35523, rightNameId = 35524
		},
		--47 创建新号
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 centerNameId = 35524,
		},
		--48 插件包导入 稍后再进 进入游戏
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=33154, rightNameId = 4102
		},
		--49 编辑插件包保存 不上传 上传
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=33160, rightNameId = 3922
		},
		--50 创建插件包 取消 创建
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=970, rightNameId = 33123
		},
		--51 插件包操作强制进入游戏
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			centerNameId=4102
		},
		--52 地图外插件包导入
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=4102, rightNameId = 970
		},
		--53 修改密码 确定
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=32121, rightNameId = 3010
		},
		--54 试穿皮肤问卷跳过
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=100715, rightNameId=100716
		},
		--55 不保存 保存
		{
		iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		leftNameId=41223, rightNameId = 3934
		},
		--56 返回 再洗一次
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=177, rightNameId = 101033
		},

		--57 忽略 回队伍
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=26042, rightNameId = 26043
		},

		--58 取消 清空
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=3018, rightNameId = 21852
		},

		--59 忽略 准备
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=26042, rightNameId = 26023
		},
		--60 取消 抢先试玩
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=3018, rightNameId = 110106
		},
		--61 下载地图 新建地图
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=9712, rightNameId = 3771
		},
		--62 关闭
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 centerNameId=3536
		},
		--63 使用推荐 认证开发者
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=21629, rightNameId = 21682
		},
		--64 返回设置
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			centerNameId=34271
		},
		--65 取消 复制密码
		{
		 iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
		 leftNameId=3018, rightNameId = 1000802
		},		
		--66 继续创作 去看看
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId = 1000711, rightNameId = 3481
		},
		--67 否 是
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=4500, rightNameId = 4501--, leftTexture = "juese_anniu_huang",rightTexture = "szjm_btn_hdyx"
		},
		--68 取消 确认
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=3018, rightNameId = 381
		},
		--69 自定义视角设定，取消 确定
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=3010, rightNameId = 3018
		},
		--70 取消 下架
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=3018, rightNameId = 23087
		},
		--71 取消 重置
		{
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=3018, rightNameId = 181106
		},
		--72 转换 取消
		{
			--: leftTexture: 左按钮背景, 红色.
			iconPath = "ui/mobile/ui2.png", uv={x=885,y=449,w=61,h=61},
			leftNameId=300370, rightNameId = 3018--, leftTexture = "dtxx_button_quxiao"
		},
	}
	
-- 定义 t_type 枚举，用来代替使用时直接写数字
MessageBoxType = {
	plugin = 48, --48 插件包导入 稍后再进 进入游戏
	pluginSave = 49, -- 49 编辑插件包保存 不上传 上传
	pluginCreat = 50, --50 创建插件包 取消 创建
	pluginForce = 51, --51 插件包操作强制进入游戏 进入游戏
	pluginOutMapImport = 52, -- 52 地图外插件包导入 进入游戏 取消
}

local MessageBox_Callback = nil;
local MessageBox_CallbackData = nil;
local ClickAnyWhereHide = false;
local t_MessageBoxBtnCD = {};		--倒计时响应按钮
IsFirstEnterNoviceGuide = false;
local MessageBox_closeCallback = nil;  -- 关闭按钮回调
local CameraViewMsgBoxRightBtnNotClicked = nil -- 视角设定界面右键是否被点击标志位，用于按下Esc后，调用右键取消事件。
											   -- 保证视角设定界面正确关闭

function MessageBox(type, note, callback, callback_data, anywhere_hide, countdown, isCanClose, closeCallback, desc1)
	if type > #t_type then return; end

	if type == 16 then
		standReportEvent("38", "NEWPLAYER_TEACHINGMAP_EXIT", "-", "view");
		standReportEvent("38", "NEWPLAYER_TEACHINGMAP_EXIT", "continue", "view");
		standReportEvent("38", "NEWPLAYER_TEACHINGMAP_EXIT", "exit", "view");
	end

	if anywhere_hide then
		ClickAnyWhereHide = anywhere_hide;
	end
	t_MessageBoxBtnCD.left = nil;
	t_MessageBoxBtnCD.center = nil;
	t_MessageBoxBtnCD.right = nil;

	MessageBox_closeCallback = closeCallback

	if countdown then
		if countdown.leftTime then
			t_MessageBoxBtnCD.left = {time=countdown.leftTime, text=""};
		end

		if countdown.centerTime then
			t_MessageBoxBtnCD.center = {time=countdown.centerTime, text=""};
		end

		if countdown.rightTime then
			t_MessageBoxBtnCD.right = {time=countdown.rightTime, text=""};
		end
	end

	local MessageBoxFrame = getglobal("MessageBoxFrame")
	local MessageBoxFrameDesc = getglobal("MessageBoxFrameDesc")
	local MessageBoxFrameDesc1 = getglobal("MessageBoxFrameDesc1")
	local MessageBoxFrameIcon = getglobal("MessageBoxFrameIcon")

	MessageBoxFrame:SetClientString("");
	MessageBoxFrameDesc:clearHistory();
	MessageBoxFrameDesc1:clearHistory();

	MessageBox_Callback = callback;
	MessageBox_CallbackData = callback_data;

	MessageBoxFrameIcon:SetTexture(t_type[type].iconPath);
	MessageBoxFrameIcon:SetTexUV(t_type[type].uv.x, t_type[type].uv.y, t_type[type].uv.w, t_type[type].uv.h);

	local MessageBoxFrameLeftBtn = getglobal("MessageBoxFrameLeftBtn")
	local MessageBoxFrameRightBtn = getglobal("MessageBoxFrameRightBtn")
	local MessageBoxFrameCenterBtn = getglobal("MessageBoxFrameCenterBtn")
	local MessageBoxFrameLeftBtnName = getglobal("MessageBoxFrameLeftBtnName")
	local MessageBoxFrameRightBtnName = getglobal("MessageBoxFrameRightBtnName")
	local MessageBoxFrameCenterBtnName = getglobal("MessageBoxFrameCenterBtnName")
	getglobal("MessageBoxFrameCenterBtn"):Hide()
	--:左按钮背景.
	local MessageBoxFrameLeftBtnNormal = getglobal("MessageBoxFrameLeftBtnNormal");
	local MessageBoxFrameLeftBtnPushedBG = getglobal("MessageBoxFrameLeftBtnPushedBG");
	--MessageBoxFrameLeftBtnNormal:SetTexUV("dljm_btn01");
	--MessageBoxFrameLeftBtnPushedBG:SetTexUV("dljm_btn01");

	--右按钮背景
	local MessageBoxFrameRightBtnNormal = getglobal("MessageBoxFrameRightBtnNormal");
	local MessageBoxFrameRightBtnPushedBG = getglobal("MessageBoxFrameRightBtnPushedBG");
	--MessageBoxFrameRightBtnNormal:SetTexUV("dljm_btn01");
	--MessageBoxFrameRightBtnPushedBG:SetTexUV("dljm_btn01");

	--中间按钮背景
	local MessageBoxFrameCenterBtnNormal = getglobal("MessageBoxFrameCenterBtnNormal");
	local MessageBoxFrameCenterBtnPushedBG = getglobal("MessageBoxFrameCenterBtnPushedBG");
	--MessageBoxFrameCenterBtnNormal:SetTexUV("dljm_btn01");
	--MessageBoxFrameCenterBtnPushedBG:SetTexUV("dljm_btn01");

	if t_type[type].leftNameId ~= nil then
		MessageBoxFrameLeftBtn:Show();
		local text = GetS(t_type[type].leftNameId)
		if t_MessageBoxBtnCD.left then	
			t_MessageBoxBtnCD.left.text = text;
		end
		MessageBoxFrameLeftBtnName:SetText(text);

		--:左按钮背景
		if t_type[type].leftTexture then
			MessageBoxFrameLeftBtnNormal:SetTexUV(t_type[type].leftTexture);
			MessageBoxFrameLeftBtnPushedBG:SetTexUV(t_type[type].leftTexture);
		end
	else
		MessageBoxFrameLeftBtn:Hide();
	end
	if t_type[type].rightNameId ~= nil then
		MessageBoxFrameRightBtn:Show();
		local text = GetS(t_type[type].rightNameId)
		if t_MessageBoxBtnCD.right then	
			t_MessageBoxBtnCD.right.text = text;
		end
		MessageBoxFrameRightBtnName:SetText(text);

		--:右按钮背景
		if t_type[type].rightTexture then
			MessageBoxFrameRightBtnNormal:SetTexUV(t_type[type].rightTexture);
			MessageBoxFrameRightBtnPushedBG:SetTexUV(t_type[type].rightTexture);
		end
	else
		MessageBoxFrameRightBtn:Hide();
	end

	if t_type[type].centerNameId ~= nil then
		MessageBoxFrameCenterBtn:Show();
		local text = GetS(t_type[type].centerNameId)
		if t_MessageBoxBtnCD.center then	
			t_MessageBoxBtnCD.center.text = text;
		end

		MessageBoxFrameCenterBtnName:SetText(text);
		if t_type[type].centerTexture then
			MessageBoxFrameCenterBtnNormal:SetTexUV(t_type[type].centerTexture);
			MessageBoxFrameCenterBtnPushedBG:SetTexUV(t_type[type].centerTexture);
		end
	else
		MessageBoxFrameCenterBtn:Hide();
	end

	local closeBtn = getglobal("MessageBoxFrameCloseBtn")
	if isCanClose then
		closeBtn:Show()
	else
		closeBtn:Hide()
	end

	--确定要永久删除此地图吗？  （删除后无法恢复）
	MessageBoxFrameDesc:SetText(note, 55, 54, 47);
	-- local lines = MessageBoxFrameDesc:GetTextLines();
	-- if lines == 1 then
	-- 	MessageBoxFrameDesc:SetPoint("top", "MessageBoxFrameChenDi2", "top", 0, 85);
	-- elseif lines == 2 then
	-- 	MessageBoxFrameDesc:SetPoint("top", "MessageBoxFrameChenDi2", "top", 0, 70);
	-- elseif lines == 3 then
	-- 	MessageBoxFrameDesc:SetPoint("top", "MessageBoxFrameChenDi2", "top", 0, 55);
	-- elseif lines == 4 then
	-- 	MessageBoxFrameDesc:SetPoint("top", "MessageBoxFrameChenDi2", "top", 0, 40);
	-- else
	-- 	MessageBoxFrameDesc:SetPoint("top", "MessageBoxFrameChenDi2", "top", 0, 25);
	-- end

	if desc1 then
		MessageBoxFrameDesc1:SetText(desc1, 55, 54, 47);
		MessageBoxFrameDesc1:Show();
	else
		MessageBoxFrameDesc1:Hide();
	end
	-- local lines = MessageBoxFrameDesc1:GetTextLines();
	-- if lines == 1 then
	-- 	MessageBoxFrameDesc1:SetPoint("top", "MessageBoxFrameChenDi2", "top", 0, 85);
	-- elseif lines == 2 then
	-- 	MessageBoxFrameDesc1:SetPoint("top", "MessageBoxFrameChenDi2", "top", 0, 70);
	-- elseif lines == 3 then
	-- 	MessageBoxFrameDesc1:SetPoint("top", "MessageBoxFrameChenDi2", "top", 0, 55);
	-- elseif lines == 4 then
	-- 	MessageBoxFrameDesc1:SetPoint("top", "MessageBoxFrameChenDi2", "top", 0, 40);
	-- else
	-- 	MessageBoxFrameDesc1:SetPoint("top", "MessageBoxFrameChenDi2", "top", 0, 25);
	-- end

	-- if not MessageBoxFrame:GetClientString() == "海外切换帐号二级确定" then
	-- 	-- if not MessageBoxFrameDesc:IsShown() then
	-- 		MessageBoxFrameDesc:Show();
	-- 	-- end
	-- 	-- if MessageBoxFrameDesc1:IsShown() then
	-- 		MessageBoxFrameDesc1:Hide();
	-- 	-- end
	-- else
	-- 	-- if MessageBoxFrameDesc:IsShown() then
	-- 		MessageBoxFrameDesc:Hide();
	-- 	-- end
	-- 	-- if not MessageBoxFrameDesc1:IsShown() then
	-- 		MessageBoxFrameDesc1:Show();
	-- 	-- end
	-- end

	MessageBoxFrameDesc:Show();

	
	if t_type[type].leftUvA then
		getglobal("MessageBoxFrameLeftBtnUvA"):Show();
		getglobal("MessageBoxFrameLeftBtnUvA"):SetUVAnimation(120, true);
	elseif t_type[type].rightUvA then
		getglobal("MessageBoxFrameRightBtnUvA"):Show();
		getglobal("MessageBoxFrameRightBtnUvA"):SetUVAnimation(120, true);
	else
		getglobal("MessageBoxFrameLeftBtnUvA"):Hide();
		getglobal("MessageBoxFrameRightBtnUvA"):Hide();
	end
	if not MessageBoxFrame:IsShown() then
		MessageBoxFrame:Show();
		print("MessageBoxFrame:Show()")
		if ClientCurGame and ClientCurGame:isInGame() then
			ClientCurGame:setOperateUI(true);
		end
		--防止弹框重叠-新老界面层级一样
		if GetInst("MiniUIManager") and GetInst("MiniUIManager"):IsShown("MessageBoxAutoGen") then
			GetInst("MiniUIManager"):CloseUI("MessageBoxAutoGen")
		end
	end

	if type == 69 then
		CameraViewMsgBoxRightBtnNotClicked = true
	end
end

function MessageBoxFrame_OnLoad()
	this:setUpdateTime(1.0);
end

function MessageBoxFrame_OnUpdate()
	if t_MessageBoxBtnCD.left and t_MessageBoxBtnCD.left.text ~= "" then
		t_MessageBoxBtnCD.left.time = math.floor(t_MessageBoxBtnCD.left.time -arg1);
		if t_MessageBoxBtnCD.left.time <= 0 then
			MessageBoxFrameLeftBtn_OnClick();
		else
			local text = t_MessageBoxBtnCD.left.text.."("..t_MessageBoxBtnCD.left.time..")";
			getglobal("MessageBoxFrameLeftBtnName"):SetText(text);
		end
	end

	if t_MessageBoxBtnCD.center and t_MessageBoxBtnCD.center.text ~= "" then
		t_MessageBoxBtnCD.center.time = math.floor(t_MessageBoxBtnCD.center.time -arg1);
		if t_MessageBoxBtnCD.center.time <= 0 then
			MessageBoxFrameCenterBtn_OnClick();
		else
			local text = t_MessageBoxBtnCD.center.text.."("..t_MessageBoxBtnCD.center.time..")";
			getglobal("MessageBoxFrameCenterBtnName"):SetText(text);
		end
	end

	if t_MessageBoxBtnCD.right and t_MessageBoxBtnCD.right.text ~= "" then
		t_MessageBoxBtnCD.right.time = math.floor(t_MessageBoxBtnCD.right.time -arg1);
		if t_MessageBoxBtnCD.right.time <= 0 then
			MessageBoxFrameRightBtn_OnClick();
		else
			local text = t_MessageBoxBtnCD.right.text.."("..t_MessageBoxBtnCD.right.time..")";
			getglobal("MessageBoxFrameRightBtnName"):SetText(text);
		end
	end
end

local isOnclik = false;

function MessageBoxFrameLeftBtn_OnClick()
	if isOnclik then return end;

	isOnclik = true;
	local MessageBoxFrame = getglobal("MessageBoxFrame")
	print("MessageBoxFrameLeftBtn_OnClick",MessageBoxFrame:GetClientString())
	if MessageBox_Callback ~= nil and MessageBoxFrame:GetClientString() == "" then
		CameraViewMsgBoxRightBtnNotClicked = nil;
		MessageBoxFrame:Hide();
		local callback, callback_data = MessageBox_Callback, MessageBox_CallbackData;
		MessageBox_Callback, MessageBox_CallbackData = nil, nil;
		if callback then
			callback('left', callback_data);
		end
		return
	elseif MessageBoxFrame:GetClientString() == "删除地图" then
		if isEnableNewLobby and isEnableNewLobby() then
			local worldid = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
			local worldInfo = AccountManager:findWorldDesc(worldid)
			if worldInfo == nil then return end 
			DeleteMapIndex = n;
			DeleteMapFormWid = worldInfo.fromowid;
			print("kekeke del map DeleteMapFormWid", DeleteMapFormWid);
			if ArchiveWorldDesc ~= nil and ArchiveWorldDesc.worldid == worldid then
				if IsMapDetailInfoShown() then
					HideMapDetailInfo();
				end
				-- statisticsGameEvent(8004,"%d",ArchiveWorldDesc.worldtype);
			end
			local owid = worldInfo.worldid
            AccountManager:requestDeleteWorld(owid);
			if DeleteMapFormWid > 0 then
				GetInst("lobbyService"):RemoveLocalMyHistoryMap(DeleteMapFormWid)
			else
				GetInst("lobbyService"):RemoveLocalMyHistoryMap(owid)
			end
            local ctrl = GetInst("UIManager"):GetCtrl("lobbyMapArchiveList","uiCtrlOpenList")
			if ctrl then
				if ctrl:isHistroyList() then
					local callback, callback_data = MessageBox_Callback, MessageBox_CallbackData;
					MessageBox_Callback, MessageBox_CallbackData = nil, nil;
					if callback then
						callback('left', callback_data);
					end
				else
					ctrl:RefreshArchiveMapList()
				end
            end
		else
			local n = MessageBoxFrame:GetClientUserData(0);
			if n >= 0 then
				--调用删除存档接口
				local archiveData = GetOneArchiveData(n);
				if archiveData == nil then return end
				local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)
				if worldInfo == nil then return end 
				DeleteMapIndex = n;
				DeleteMapFormWid = worldInfo.fromowid;
				print("kekeke del map DeleteMapFormWid", DeleteMapFormWid);
				local worldId = worldInfo.worldid;
				if ArchiveWorldDesc ~= nil and ArchiveWorldDesc.worldid == worldId then
					if IsMapDetailInfoShown() then
						HideMapDetailInfo();
					end
					-- statisticsGameEvent(8004,"%d",ArchiveWorldDesc.worldtype);
				end
				local isSuccess = AccountManager:requestDeleteWorld(worldId);	
				if isSuccess then
					ArchiveWorldDesc = nil;
				end		
			end
		end
	elseif MessageBoxFrame:GetClientString() == "删除未下载完成地图" then
		if isEnableNewLobby and isEnableNewLobby() then
			local worldid = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
			local worldInfo = AccountManager:findWorldDesc(worldid)
			if worldInfo == nil then return end 
			DeleteMapIndex = n
			DeleteMapFormWid = worldInfo.fromowid;
			if worldInfo.openpushtype == 4 then
				AccountManager:pauseDownloadWorld(worldid);
			end
			
			if ArchiveWorldDesc ~= nil and ArchiveWorldDesc.worldid == worldid then
				if IsMapDetailInfoShown() then
					HideMapDetailInfo();
				end
			end

			local owid = worldInfo.worldid
			AccountManager:requestDeleteWorld(owid);

			local ctrl = GetInst("UIManager"):GetCtrl("lobbyMapArchiveList","uiCtrlOpenList")
			if ctrl then
				if ctrl:isHistroyList() then
					local callback, callback_data = MessageBox_Callback, MessageBox_CallbackData;
					MessageBox_Callback, MessageBox_CallbackData = nil, nil;
					if callback then
						callback('left', callback_data);
					end
				else
					ctrl:RefreshArchiveMapList()
				end
            end			
		else
			local n = MessageBoxFrame:GetClientUserData(0);
			if n >= 0 then
				--调用删除存档接口
				local archiveData = GetOneArchiveData(n);
				if archiveData == nil then return end

				local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1)
				if worldInfo == nil then return end 
				DeleteMapIndex = n
				DeleteMapFormWid = worldInfo.fromowid;
				local worldId = worldInfo.worldid;
				if worldInfo.openpushtype == 4 then
					AccountManager:pauseDownloadWorld(worldId);
				end
				if ArchiveWorldDesc ~= nil and ArchiveWorldDesc.worldid == worldId then
					if IsMapDetailInfoShown() then
						HideMapDetailInfo();
					end
				end
				AccountManager:requestDeleteWorld(worldId);				
			end
		end
	elseif MessageBoxFrame:GetClientString() == "删除好友" then
		local uin = MessageBoxFrame:GetClientUserData(0);
		local player = GetOtherPlayer2Uin(uin, 1);
		table.insert(t_DelAttentionInfo, {Uin = uin, Player = player});	

		--[[
		if uin == CurSelectAttentionUin then
			Del_Player = GetOtherPlayer2Uin(uin, 1);
		end
		]]
		if BuddyManager:requestBuddyAttentionDel(uin) then
			ShowLoadLoopFrame(true, "file:messagebox -- func:MessageBoxFrameLeftBtn_OnClick");		
		end
	elseif MessageBoxFrame:GetClientString() == "下载存档满" then
		IsNeedReset = true;
		ShowLobby();		
		getglobal("LobbyFrameArchiveFrame"):Show();
	elseif MessageBoxFrame:GetClientString() == "网络提示" then
		local n = MessageBoxFrame:GetClientUserData(0);
		if n >= 0 then
			--调用上传分享存档接口
			if isEnableNewLobby() then
				local worldId = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
				ShareMap(n,worldId);
			else
				ShareMap(n, getglobal("ShareArchiveInfoFrame"):GetClientUserData(0));
			end
		end
	elseif MessageBoxFrame:GetClientString() == "下载地图网络提示" then
		AttentionDownAchive();
	elseif MessageBoxFrame:GetClientString() == "确认退出编辑器" then
		--if getglobal("MyModsEditorFrame"):IsShown() then
		--	getglobal("MyModsEditorFrame"):Hide();
		--end		
		--getglobal("MyModsFrame"):Show();
		FrameStack.goBack();
	elseif MessageBoxFrame:GetClientString() == "恢复下载地图网络提示" then
		local owid = MessageBoxFrame:GetClientUserDataLL(0);
		if owid > 0 then
			AccountManager:continueDownloadWorld(owid);
		end
	elseif MessageBoxFrame:GetClientString() == "取消分享" then
		if isEnableNewLobby() then
			local worldId = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
			local worldInfo = AccountManager:findWorldDesc(worldId)
			IsNeedReset = false;
			if worldInfo ~= nil then
				if AccountManager:requestOpenOWorld(worldId, 0) then
					ShowGameTips(GetS(515), 3);
					ShareArchive_MapUploadFailed();
				end
			end
		else
			local n = MessageBoxFrame:GetClientUserData(0);
			if n >= 0 then
				local archiveData = GetOneArchiveData(n);
				if archiveData == nil then return end

				local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
				IsNeedReset = false;
				if worldInfo ~= nil then
					if AccountManager:requestOpenOWorld(worldInfo.worldid, 0) then
						ShowGameTips(GetS(515), 3);
						ShareArchive_MapUploadFailed();
					end
				end
			end
		end
	elseif MessageBoxFrame:GetClientString() == "撤销审核" then
		if isEnableNewLobby() then
			local worldid = GetInst("lobbyDataManager"):GetCurSelectedArchiveData()
			local worldInfo = AccountManager:findWorldDesc(worldid)
			if worldInfo ~= nil then
				AccountManager:requestOpenOWorld(worldInfo.worldid,0,0,0,0,-1,0,0,0,1)
			end
		else
			local n = MessageBoxFrame:GetClientUserData(0);
			if n >= 0 then
				local archiveData = GetOneArchiveData(n);
				if archiveData == nil then return end
				local worldInfo = AccountManager:getMyWorldList():getWorldDesc(archiveData.index-1);
				IsNeedReset = false;
				if worldInfo ~= nil then
					AccountManager:requestOpenOWorld(worldInfo.worldid,0,0,0,0,-1,0,0,0,1)
				end
			end
		end
	elseif MessageBoxFrame:GetClientString() == "继续分享" then
		if isEnableNewLobby() then
			ContunueShare(n);
		else
			local n = MessageBoxFrame:GetClientUserData(0);
			if n >= 0 then
				--调用上传分享存档接口
				ContunueShare(n);
			end
		end
	elseif MessageBoxFrame:GetClientString() == "进入教学" then
		getglobal("GuideTipsFrame"):Hide();
		SelectRoleFrameSkipNextBtn_OnClick();
		-- statisticsGameEvent(901, "%s", "EnterNoviceMap","save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
		local GoogleAnalytics = _G.GoogleAnalytics;
		GoogleAnalytics:CreatePostBuilder()
			:SetAction(GoogleAnalytics.Actions.ENTER_NOVICE_MAP)
			:Post();
		--第一次进入新手引导
		IsFirstEnterNoviceGuide = true;
		if ClientMgr:getApiId() == 345 or ClientMgr:getApiId() == 346 or Android:IsBlockArt() then
			StatisticsTools:appsFlyer("tutorial");
		end
		--UI引导
		GameUIGuideStep = 1;
		HideIdentityNameAuthFrame()
	elseif MessageBoxFrame:GetClientString() == "主机断连" then
		
	elseif MessageBoxFrame:GetClientString() == "主机关闭房间" then
		-- 主机关闭房间：退出地图时上报 by fym
		ExistGameReport("click")
		threadpool:work(function ()
			AccountManager:sendToClientKickInfo(2);
			if not PlatformUtility:isPureServer() then
				SafeCallFunc(GetInst("ArchiveLobbyRecordManager").CacheAddRecord, GetInst("ArchiveLobbyRecordManager"))
			end
			threadpool:wait(0.5)
			GoToMainMenu()
		end)
	elseif MessageBoxFrame:GetClientString() == "主机退出游戏" then 
		LeaveRoomType = 2;	
		SendMsgWaitTime = 0.5;		
		AccountManager:sendToClientKickInfo(2);
		if not PlatformUtility:isPureServer() then
			SafeCallFunc(GetInst("ArchiveLobbyRecordManager").CacheAddRecord, GetInst("ArchiveLobbyRecordManager"))
		end
		UnhideAllUI();
	elseif MessageBoxFrame:GetClientString() == "房间踢人" then 
		local uin = MessageBoxFrame:GetClientUserData(0);
		local kickertype = MessageBoxFrame:GetClientUserData(1);
		local fps =  getAverageFps()
		--ShowGameTips("当前fps是:"..fps)
		local extra = {standby1 = uin, cid=tostring(G_GetFromMapid())}
		standReportEvent("1003", "KICK_OUT_WARNNING", "ConfirmButton", "click", extra)
		--ShowGameTips("踢人上报成功")
		ConfirmKickPlayer(uin,kickertype);
	elseif MessageBoxFrame:GetClientString() == "没绑定帐号充值" then
		-- SetAccountLoginFrame(1)
		NewAccountHelper:IntergateSetAccountLoginFrame({
			setType = NewAccountHelper.PASSWORD_SET,
		})		
	elseif MessageBoxFrame:GetClientString() == "切换帐号分享下载地图" then
		if IsStandAloneMode("") then
			MessageBoxFrame:Hide();
			MessageBox(4, GetS(15));
			return
		end
		local owid = MessageBoxFrame:GetClientUserDataLL(0);
		local worldInfo = nil
		if owid > 0 then
			worldInfo = AccountManager:findWorldDesc(owid)
		end
		if isEnableNewLobby and isEnableNewLobby() then
			newlobby_DownMyWorld2Net(worldInfo)
		else
			local n = MessageBoxFrame:GetClientUserData(0);
			if n >= 0 then
				DownMyWorld2Net(n, worldInfo);
			end
		end
	elseif MessageBoxFrame:GetClientString() == "切换帐号二级确定" then
		MessageBoxFrame:Hide();
		-- 旧版账号管理，确认切换账号弹框确认回调
		if IsEnableNewAccountSystem() then
			NewLoginSystem_LoginImpl()
		else
			LoginAccount();
		end
	elseif MessageBoxFrame:GetClientString() == "充值客户端收不到回调" then
		AccountManager:getAccountData():notifyServerClearCharge();
	elseif MessageBoxFrame:GetClientString() == "进房间使用流量" then
		--JoinRoom();
		AllRoomManager:EnterRoom(nil, true)
	elseif MessageBoxFrame:GetClientString() == "离开地图时评分" then
		if ns_data.IsGameFunctionProhibited("mc", 10583, 10584) then 
			isOnclik = false;
			return; 
		end
		getglobal("ArchiveGradeFrame"):Show();
	elseif MessageBoxFrame:GetClientString() == "删除插件项目" then
		if UseNewModsLib and getglobal("ModsLib"):IsShown() then
			GetInst("UIManager"):GetCtrl('ModsLib'):DeleteSlot()
		else
			MyModsEditorFrame_DeleteSelComponents();
		end
	elseif MessageBoxFrame:GetClientString() == "ReloadMap" then
		getglobal("SetMenuFrame"):Hide();
		MessageBoxFrame:SetFrameLevel(5000);
		Log("SetMenuFrame=Hide");

		if AccountManager:getMultiPlayer() > 0 then
			-- --联机
			-- ns_ma.ma_play_map_set_enter( { where="ReloadMap_multi" } )
			-- ClientMgr:gotoGame("MainMenuStage", MULTI_RELOAD);
		else
			for i=1, #(t_UIName) do
				local frame = getglobal(t_UIName[i]);
				frame:Hide();
			end

			--重新加载地图
			HideUI2GoMainMenu();
			
			--单机
			ns_ma.ma_play_map_set_enter( { where="ReloadMap_single" } )
			ClientMgr:gotoGame("MainMenuStage", SINGLE_RELOAD);
			ShowLoadingFrame();
		end
	elseif MessageBoxFrame:GetClientString() == "海外切换帐号二级确定" then
		MessageBoxFrame:Hide();
		SdkManager:sdkAccountBinding(2);  				-- 1 FaceBook绑定  2 FaceBook登陆
	end
	Log("MessageBoxFrame:GetClientString()=" .. MessageBoxFrame:GetClientString());
	if MessageBoxFrame:GetClientString() == "充值成功网络原因失败" then
		MessageBoxFrame:Hide();
		RequestOneServerCharge();
	elseif MessageBoxFrame:GetClientString() == "充值服务器收不到回调" then
		MessageBoxFrame:Hide();		
		RequestOneServerCharge();
	elseif MessageBoxFrame:GetClientString() == "应用宝支付收不到回调" then
		MessageBoxFrame:Hide();		
		RequestOneServerCharge();
	elseif MessageBoxFrame:GetClientString() == "新手引导退出" then
		--统计
		-- statisticsGameEvent(901, "%s", "HideNoviceGuideExitTips");
		if CurWorld and CurWorld:getOWID() == NewbieWorldId2 then
			standReportEvent("3801", "NEWPLAYER_MAP_SKIP", "OK", "click")
		else
			standReportEvent("38", "NEWPLAYER_TEACHINGMAP_EXIT", "continue", "click" , {
				standby1 = GetGuideComponent(),
			});
		end
		MessageBoxFrame:Hide();	
	elseif MessageBoxFrame:GetClientString() == "立即认证" then
		--打开认证连接
		if isQQGamePc() then
			SdkManager:BrowserShowWebpage("http://jkyx.qq.com/web2010/authoriz.htm#");
		elseif ClientMgr:getApiId() == 121 then
			SdkManager:BrowserShowWebpage("http://u.4399.com/user/realname");
		elseif ClientMgr:getApiId() == 122 then
			SdkManager:BrowserShowWebpage("http://web.7k7k.com/user/index.php");
		elseif ClientMgr:getApiId() == 124 then		
			SdkManager:BrowserShowWebpage("http://www.feihuo.com/service/fcm");
		elseif ClientMgr:getApiId() == 125 then
			SdkManager:BrowserShowWebpage("http://youxi.xunlei.com/fcm/");
		elseif ClientMgr:getApiId() == 126 then
			SdkManager:BrowserShowWebpage("http://wan.360.cn/reg_fcm/");
		elseif ClientMgr:getApiId() == 129 then
			SdkManager:BrowserShowWebpage("http://u.4399.com/user/realname");
		end
		MessageBoxFrame:Hide();
	elseif MessageBoxFrame:GetClientString() == "开房间使用流量" then
		MessageBoxFrame:Hide()
		if not IsArchiveMapCollaborationMode() then
			if not CheckCreateRoomBackupTips() then
				Log("OpenRoom3") 
				OpenRoom()
			end
		else
			Log("OpenRoom3") 
			OpenRoom()
		end 
	elseif MessageBoxFrame:GetClientString() == "是否恢复默认设置" then
		CurWorld:resetGameRuleOptions(0);
		if GetInst("ShareArchiveInterface") then
			GetInst("ShareArchiveInterface"):socialWDescReset()
		end
		--getglobal("NewRuleSetFrame"):Hide();
		MessageBoxFrame:Hide();
		--恢复默认后，队伍人数设置变成系统推荐
		if GetInst("UIManager"):GetCtrl("MapRuleTeamEdit") then
			GetInst("UIManager"):GetCtrl("MapRuleTeamEdit"):CheckSetClick(1)
		end
		--getglobal("NewRuleSetFrame"):Show();	--先关闭再开启, 简单实现窗口刷新
		GetInst("UIManager"):GetCtrl("BasicSetting"):Refresh()
	elseif MessageBoxFrame:GetClientString() == "保存密码到本地" then
		getglobal("ActivateAccountFrame"):Hide();	-- (老版修改密码界面)截完图在关闭密码框, 不然就截不到密码了.
		GetInst("UIManager"):GetCtrl("ActivateAccount"):CloseBtn_OnClick()  -- (新版修改密码界面) 点击取消保存，关闭修改密码界面
		MessageBoxFrame:Hide();

	elseif MessageBoxFrame:GetClientString() == "Avatar保存" then
		MessageBoxFrame:Hide();
	elseif MessageBoxFrame:GetClientString() == "指令集重置" then
		InstructionSetReset();
		MessageBoxFrame:Hide();
	elseif  MessageBoxFrame:GetClientString() == "音乐设置有改动未保存"  then
		MusicEditFrameCloseBtn();
		MessageBoxFrame:Hide();
	elseif  MessageBoxFrame:GetClientString() == "一键领取所有附件"  then
		MessageBoxFrame:Hide();
		MailFrameMailOneKeyTakeBtn_OnClickCallback();
--[[	elseif  MessageBoxFrame:GetClientString() == "删除已读邮件"  then
		MessageBoxFrame:Hide();
		MailFrameMailOneKeyDeleteBtn_OnClickCallback();--]]
	elseif  MessageBoxFrame:GetClientString() == "删除定制装扮" then
		MessageBoxFrame:Hide();
		ConfirmDelAvatarBtnOnClickCallback();
	elseif  MessageBoxFrame:GetClientString() == "支持一下" then
		MessageBoxFrame:Hide();
		ArchiveGradeFrameRewardBtnClicked();
	elseif  MessageBoxFrame:GetClientString() == "离开结算界面时评分" then
		if ns_data.IsGameFunctionProhibited("mc", 10583, 10584) then 
			isOnclik = false;
			return; 
		end
		getglobal("ArchiveGradeFrame"):Show();
		MessageBoxFrame:Hide();
	elseif  MessageBoxFrame:GetClientString() == "CloudServerReset" then
		-- 云服重置
		GetInst("UIManager"):GetCtrl("CloudServerLobby"):CloudServerResetCancel()
		MessageBoxFrame:Hide();
	elseif MessageBoxFrame:GetClientString() == "重新上传" then
		MessageBoxFrame:Hide()
		GetInst("UIManager"):GetCtrl("ShopCustomSkinEdit"):MessageBoxCallBack("left")
	elseif MessageBoxFrame:GetClientString() == "确定要删除此账号的登录记录" then
		MessageBoxFrame:Hide()
		SwitchAccountUI_EnsuredDeletedItemCallBack()
	else
		MessageBoxFrame:Hide();
	end
end

function MessageBoxFrame_OnClick()
	print("kekeke MessageBoxFrame_OnClick", ClickAnyWhereHide);
	if ClickAnyWhereHide then
		getglobal("MessageBoxFrame"):Hide();
	end
end

function MessageBoxFrame_OnHide()
	isOnclik = false;
	ClickAnyWhereHide = false;

	local MessageBoxFrame = getglobal("MessageBoxFrame")
	MessageBoxFrame:SetClientUserData(0, 0);
	MessageBoxFrame:SetClientUserData(1, 0);
	MessageBoxFrame:SetClientUserData(2, 0);

	MessageBoxFrame:SetClientUserDataLL(0, 0);

	-- 如果是走Esc关闭消息框，保证视角界面调到右键取消事件
	if CameraViewMsgBoxRightBtnNotClicked and MessageBox_Callback then
		CameraViewMsgBoxRightBtnNotClicked = nil
		MessageBox_Callback('right', MessageBox_CallbackData)
	end

	if ClientCurGame and ClientCurGame:isInGame() then
		if not getglobal("MessageBoxFrame"):IsRehide() then
			ClientCurGame:setOperateUI(false);
		end
	end
	if MessageBoxFrame:GetFrameLevel() ~= 7000 then
		MessageBoxFrame:SetFrameLevel(7000);
	end
end

function MessageBoxFrame_OnShow()
	--if ClientCurGame:isInGame() then
	--	if not getglobal("MessageBoxFrame"):IsReshow() then
	--		ClientCurGame:setOperateUI(true);
	--	end
	--end
end

function MessageBoxFrameRightBtn_OnClick()
	local MessageBoxFrame = getglobal("MessageBoxFrame")
		
	if MessageBox_Callback ~= nil and MessageBoxFrame:GetClientString() == "" then
		CameraViewMsgBoxRightBtnNotClicked = nil
		MessageBoxFrame:Hide();
		local callback, callback_data = MessageBox_Callback, MessageBox_CallbackData;
		MessageBox_Callback, MessageBox_CallbackData = nil, nil;
		if callback then
			-- 右键事件已调用，重置标志位
			callback('right', callback_data);
		end
	elseif MessageBoxFrame:GetClientString() == "充值成功网络原因失败" then
		getglobal("ShopRechargeHelpFrame"):Show();
	elseif MessageBoxFrame:GetClientString() == "充值服务器收不到回调" then
		getglobal("ShopRechargeHelpFrame"):Show();
	else	
		MessageBoxFrame:Hide();
	end
	if MessageBoxFrame:GetClientString() == "删除地图" then
	elseif MessageBoxFrame:GetClientString() == "进入教学" then
		getglobal("GuideTipsFrame"):Hide();
		EnterLobby();
		-- statisticsGameEvent(901, "%s", "SkipNoviceMap","save",true,"%s",os.date("%Y%m%d%H%M%S",os.time()));
		GuideLobby = 4;
	elseif MessageBoxFrame:GetClientString() == "主机断连" then
		--MiniBase主机断连切换到APP
		SandboxLua.eventDispatcher:Emit(nil, "MiniBase_LeaveGame",  SandboxContext():SetData_Number("code", 0))
		HideAllFrame(nil, false);
		ClientMgr:gotoGame("MainMenuStage");
	elseif MessageBoxFrame:GetClientString() == "主机关闭房间" then
		friendservice.msgBoxExitGame = 1
	elseif MessageBoxFrame:GetClientString() == "主机退出游戏" then
	elseif MessageBoxFrame:GetClientString() == "没绑定帐号充值" then 
	elseif MessageBoxFrame:GetClientString() == "充值客户端收不到回调" then
		AccountManager:getAccountData():notifyServerClearCharge();
		getglobal("ShopRechargeHelpFrame"):Show();
	elseif MessageBoxFrame:GetClientString() == "离开地图时评分" then
		-- 离开地图时评分: 点击"直接关闭"按钮时上报  by fym
		ExistGameReport("click")
		GoToMainMenu();
	elseif MessageBoxFrame:GetClientString() == "新手引导退出" then
		if CurWorld and CurWorld:getOWID() == NewbieWorldId2 then
			standReportEvent("3801", "NEWPLAYER_MAP_SKIP", "Quite", "click")
		else
			standReportEvent("38", "NEWPLAYER_TEACHINGMAP_EXIT", "exit", "click", {
				standby1 = GetGuideComponent(),
			});
		end
		
		-- 标识已经完成了走过了新手教学
		if NewbieGuideManager and NewbieGuideManager:IsSwitch() then
			NewbieGuideManager:SetGuideFinishFlag(NewbieGuideManager.GUIDE_FLAG_GO_ALONE, true)
			NewbieGuideManager:SetGuideFlagByPos(NewbieGuideManager.GUIDE_FLAG_GO_ALONE)
		end
		
		if isEducationalVersion then  --教育版退出新手引导
			GuideSkip_Edu(0);
		else
			GuideSkip();
			GuideLobby = 3;
		end
		SetGuideStep(3)

	elseif MessageBoxFrame:GetClientString() == "立即认证" then
		MessageBoxFrame:Hide();	
	elseif MessageBoxFrame:GetClientString() == "仓库已满" then
		if getglobal('ActivityMainFrame'):IsShown() then
			if ActivityMainCtrl then
				ActivityMainCtrl:AntiActive()
			end
		end
		--[[ 邮件已改版 此处会lua错误
		if getglobal('MailFrame'):IsShown() then
			getglobal('MailFrame'):Hide();
		end
		--]]
		if getglobal('ShopGiftLotteryGiftFrame'):IsShown() then
			GetInst("UIManager"):GetCtrl("ShopGift"):OnShopGiftBuyGiftFrameCloseBtnClicked()
		end
		AccelKey_StoreInventory();	--打开仓库界面
	elseif MessageBoxFrame:GetClientString() == "保存密码到本地" then
		SavePassword2File();  -- 老版设置密码界面保存密码到本地
		GetInst("UIManager"):GetCtrl("ActivateAccount"):SavePassword2File() -- 新版设置密码界面保存密码到本地
	elseif MessageBoxFrame:GetClientString() =="Avatar保存" then
		AvatarStoreSaveFrameRightBtn_OnClick();
		MessageBoxFrame:Hide();
	elseif MessageBoxFrame:GetClientString() =="支持一下" then
		-- 打赏作者功能（支持一下）: 点击"直接关闭"按钮时上报  by fym
		ExistGameReport("click")
		GoToMainMenu();
		SetExitReason(10)
		GetInst("ReportGameDataManager"):SetExitReaseon(10)
	elseif MessageBoxFrame:GetClientString() == "离开结算界面时评分" then
		BattleFrameBackMenu_OnClick();

	elseif MessageBoxFrame:GetClientString() == "CloudServerReset" then
		-- 云服重置
		GetInst("UIManager"):GetCtrl("CloudServerLobby"):CloudServerResetConfirm()
		MessageBoxFrame:Hide();		
	elseif MessageBoxFrame:GetClientString() == "主机关闭房间Right" then
		-- 主机关闭房间：退出地图时上报 by fym
		friendservice.msgBoxExitGame = 1
		ExistGameReport("click")
		threadpool:work(function ()
			AccountManager:sendToClientKickInfo(2);
			if not PlatformUtility:isPureServer() then
				SafeCallFunc(GetInst("ArchiveLobbyRecordManager").CacheAddRecord, GetInst("ArchiveLobbyRecordManager"))
			end
			GetInst("BestPartnerManager"):LeaveGame()
			threadpool:wait(0.5)
			GoToMainMenu()
		end)
	end
end

function MessageBoxFrameCenterBtn_OnClick()
	local MessageBoxFrame = getglobal("MessageBoxFrame")
	if MessageBox_Callback ~= nil and MessageBoxFrame:GetClientString() == "" then
		MessageBoxFrame:Hide();
		local callback, callback_data = MessageBox_Callback, MessageBox_CallbackData;
		MessageBox_Callback, MessageBox_CallbackData = nil, nil;
		if callback then
			callback('center', callback_data);
		end
	elseif MessageBoxFrame:GetClientString() == "" then 
			MessageBoxFrame:Hide();
	end

	if MessageBoxFrame:GetClientString() == "创建地图上限" then
		MessageBoxFrame:Hide();
	elseif MessageBoxFrame:GetClientString() == "切换帐号未分享地图" then
		MessageBoxFrame:Hide();
	elseif MessageBoxFrame:GetClientString() == "存储空间不够" then
		MessageBoxFrame:Hide();
		--EnterGame();
	elseif MessageBoxFrame:GetClientString() == "充值服务器验证失败" then
		MessageBoxFrame:Hide();
	elseif MessageBoxFrame:GetClientString() == "充值MD5验证失败" then
		MessageBoxFrame:Hide();
	elseif MessageBoxFrame:GetClientString() == "数据转移完成" then
		GameExit();
	elseif MessageBoxFrame:GetClientString() == "丢失窗口焦点" then
		MessageBoxFrame:Hide();
		g_IsShowVideMessageBox = false;
	end
end

function MessageBoxFrameDesc_OnClick()
	local MessageBoxFrame = getglobal("MessageBoxFrame")
	if MessageBoxFrame:GetClientString() == "重新上传" then
		MessageBoxFrame:Hide()
		GetInst("UIManager"):GetCtrl("ShopCustomSkinEdit"):MessageBoxCallBack("desc")
	end
end

-----------------------------简单封装一下,同步方式调用'MessageBoxFrame'----------------------------
--调用方法: ret = StoreMessageBoxCtrl:Open(type, note, title, titleId, costNum, needNum, replaceId);
--返回值: ret: 'cancel', 'ok'

StoreMessageBoxCtrl = {
	hooklist = {};
	container = nil,
	activate = false,
	seq = nil,
	hookBtnType = {
		left 	= {sType = 'cancel',},
		right 	= {sType = 'ok',},
		center 	= {sType = 'ok',},
	},

	Open = function(self, type, note, title, titleId, costNum, needNum, replaceId)
		print('StoreMessageBoxCtrl:Open:');
		self:OnInit();
		
		self.activate = true;
		self.seq = gen_gid();
		StoreMsgBox(type, note, title, titleId, costNum, needNum, replaceId);

		--等待
		local _timeout = 99999999;
        local code, ret = threadpool:wait(self.seq, _timeout);
        print('StoreMessageBoxCtrl:Over:code = ', code, ', ret = ', ret);

        self:Close();
        return ret;
	end,

	IsActivate = function(self, btnType)
		print('StoreMessageBoxCtrl:IsActivate:btnType = ', btnType);
		if self.activate then
			if self.hookBtnType[btnType] then
				print('activate:');
				return true;
			end
		end

		print('not activate:');
		return false;
	end,

	Close = function(self)
		self.activate = false;
		self:OnDestroy();
		getglobal("StoreMsgboxFrame"):Hide();
	end,

	OnInit = function(self)
		self.container = _G.container;
		self.hooklist = {};
		self:hook('StoreMsgboxFrameLeftBtn_OnClick();', 'LeftBtnOnClick');
		self:hook('StoreMsgboxFrameRightBtn_OnClick();', 'RightBtnOnClick');
		self:hook('StoreMsgboxFrameCenterBtn_OnClick();', 'CenterBtnOnClick');
	end,

	OnDestroy = function(self)
		for i = 1, #self.hooklist do
			self.container.hook[self.hooklist[i]] = nil;
		end
	end,

	hook = function(self, s, f)
		self.container.hook[s] = {
			method = f,
            obj = self,
		};

		table.insert(self.hooklist, s);
	end,

	LeftBtnOnClick = function(self)
		print("StoreMessageBoxCtrl:LeftBtnOnClick:")
		self:Execute('left');
	end,

	RightBtnOnClick = function(self)
		print("StoreMessageBoxCtrl:RightBtnOnClick:")
		self:Execute('right');
	end,

	CenterBtnOnClick = function(self)
		print("StoreMessageBoxCtrl:CenterBtnOnClick:")
		self:Execute('center');
	end,

	Execute = function(self, btnType)
		print('StoreMessageBoxCtrl:Execute:btnType = ', btnType);
		local ret = 'cancel';

		if btnType then
			ret = self.hookBtnType[btnType] and self.hookBtnType[btnType].sType;
		end

		if self.seq then
            threadpool:notify(self.seq, ErrorCode.OK, ret);
        end
	end,
};

----------------------------------StoreMsgboxFrame-----------------------------------
local t_storeMsgType = {
		{
		 leftNameId = 3018,
		 rightNameId = 435,
		 needIcon = false;
		},--1前往[Desc5] 取消
		{
		 leftNameId = 3018,
		 rightNameId = 3033,
		 needIcon = true;
		 iconPath = "ui/mobile/texture0/common_icon.xml", uv="icon_coin.png",
		}, --2 迷你币图标 2解锁 取消
		{
		 leftNameId = 3018,
		 rightNameId = 436,
		 needIcon = true;
		 iconPath = "ui/mobile/texture0/common_icon.xml", uv="icon_coin.png",
		}, --3 迷你币图标 3激活 取消
		{
		 leftNameId = 3018,
		 rightNameId = 187,
		 needIcon = true;
		 iconPath = "ui/mobile/texture0/common_icon.xml", uv="icon_coin.png",
		}, --4 迷你币图标 4升级 	取消
		{
		 leftNameId = 3018,
		 rightNameId = 3010,
		 needIcon = true;
		 iconPath = "ui/mobile/texture0/common_icon.xml", uv="icon_coin.png",
		}, --5 迷你币图标 5确定 取消
		{
		 leftNameId = 3018,
		 rightNameId = 3010,
		 needIcon = false;
		},--6 确定 取消
		{
		 leftNameId = 3018,
		 rightNameId = 3033,
		 needIcon = true;
		 iconPath = "ui/mobile/texture0/common_icon.xml", uv="icon_bean.png",
		}, -- 迷你豆图标 7解锁 取消
		{
		 leftNameId = 3018,
		 rightNameId = 881,
		 needIcon = false;
		}, -- 8前往家园 取消
		{
		 centerId = 3010,
		 needIcon = false;
		}, --9确定
		{
		 leftNameId = 3018,
		 rightNameId = 3010,
		 needIcon = true,
		 iconPath = "ui/mobile/texture2/common_icon.xml", uv="icon_coin.png",
		}, --10:迷你币图标取消, 图标,确定
		{
		 leftNameId = 3018,
		 rightNameId = 3010,
		 needIcon = true;
		 iconPath = "ui/mobile/texture2/common_icon.xml", uv="icon_bean.png",
		}, --11:迷你豆图标 确定 取消
		{
			leftNameId = 3018,
			rightNameId = 3010,
			needIcon = true;
			iconPath = "ui/mobile/texture2/common_icon.xml", uv="icon10009.png",
		}, --12:迷你点图标 确定 取消
		{
			leftNameId = 3018,
			rightNameId = 30122,
			needIcon = false;
		}, --13:观看广告
		{
		 	centerId = 70643,
		 	needIcon = false;
		}, --14立即续订
		{
		 leftNameId = 3018,
		 rightNameId = 110088,
		 needIcon = false;
		}, -- 15前往商店礼包 取消
		{
		 leftNameId = 3018,
		 rightNameId = 110089,
		 needIcon = false;
		}, -- 16前往商店福利 取消
		{
		 leftNameId = 3018,
		 rightNameId = 110090,
		 needIcon = false;
		}, -- 17前往商店扭蛋 取消
		{
		 leftNameId = 3018,
		 rightNameId = 4879,
		 needIcon = false;
		}, -- 18前往商店坐骑扭蛋 取消
		{
			leftNameId = 3033,
			rightNameId = 3033,
			needIcon = true,
		}, -- 19图鉴解锁 迷你豆 迷你点
		{
			leftNameId = 3018,
			rightNameId = 3010,
			needIcon = false,
			iconPath = "ui/mobile/texture2/common_icon.xml", uv="icon_coin.png",
		}, --20:迷你币图标取消, 图标,确定
	}

t_MiniCoinId = {						
		{cost=5, id=15, num=55},
		{cost=25, id=16, num=280},
		{cost=50, id=17, num=580},			
		}

t_MiniCoinId_en = {						
		{cost=0.99, id=1, num=50},
		{cost=4.99, id=2, num=250},
		{cost=9.99, id=3, num=525},	
		{cost=19.99, id=4, num=1100},
		{cost=49.99, id=5, num=3000},
		{cost=99.99, id=6, num=6500},		
		}

t_MiniCoinId_ios = {						
		{cost=6, id=4, num=66},
		{cost=25, id=5, num=280},
		{cost=50, id=6, num=580},			
		{cost=98, id=7, num=1160},
		}

t_MiniCoinId_ios_en = {						
		{cost=0.99, id=1, num=50},
		{cost=4.99, id=2, num=250},
		{cost=9.99, id=3, num=525},	
		{cost=19.99, id=4, num=1100},
		{cost=49.99, id=5, num=3000},
		{cost=99.99, id=6, num=6500},
		}

-- return 1:[Desc1]上限为25元的渠道， 2：[Desc1]上限是50元的渠道, 0：有TPPay的渠道
local function SmsPayLimit()
	local apiId = ClientMgr:getApiId()
	local t_SmsLimitApiid1 = {4, 16, 30, 31, 33, 37, 50} --[Desc1]上限是25元
	local t_SmsLimitApiid2 = {5, 6} -- [Desc1]上限是50元

	for i=1, #(t_SmsLimitApiid1) do
		if apiId == t_SmsLimitApiid1[i] then
			return 1
		end
	end

	for j=1, #(t_SmsLimitApiid2) do 
		if apiId == t_SmsLimitApiid2[j] then
			return 2
		end
	end

	return 0
end
	
function GetPayRealCost(num)
	miniCoinIds = t_MiniCoinId;
	local apiId = ClientMgr:getApiId();
	if apiId == 45 or apiId == 52 or apiId == 53 then
		miniCoinIds = t_MiniCoinId_ios;
	elseif apiId == 345 or apiId == 346 then
		miniCoinIds = t_MiniCoinId_ios_en;
	elseif apiId >= 300 and apiId ~= 999 then
		miniCoinIds = t_MiniCoinId_en;
	end

	for i=1, #(miniCoinIds) do
		local miniDef = DefMgr:getMiniCoinDef(miniCoinIds[i].id);

		if miniDef ~= nil and num <= miniDef.Num then
			if miniDef.Cost > 30 and not SdkManager:hasTPPay() then	--大于30元并且没有第三方[Desc1]
				if SmsPayLimit() == 2 then
					miniDef = DefMgr:getMiniCoinDef(17);
				else
					miniDef = DefMgr:getMiniCoinDef(16);
				end
				return string.format("%.2f",miniDef.Cost), miniDef.Num;
			else
				return string.format("%.2f",miniDef.Cost), miniDef.Num;
			end
		end	
	end

	--找不到合适的[Desc2]选项，取最高消费选项
	local miniDef = DefMgr:getMiniCoinDef(17);
	if apiId == 45 or apiId == 52 or apiId == 53 then
		miniDef = DefMgr:getMiniCoinDef(7);
	elseif apiId == 345 or apiId == 346 then
		miniDef = DefMgr:getMiniCoinDef(6);
	elseif apiId >= 300 and apiId ~= 999 then
		miniDef = DefMgr:getMiniCoinDef(6);
	elseif SmsPayLimit() == 1 then
		miniDef = DefMgr:getMiniCoinDef(16);
	end

	return string.format("%.2f",miniDef.Cost), miniDef.Num;
end

function GetPayCostId(cost)
	cost = tonumber(cost);
	miniCoinIds = t_MiniCoinId;
	local apiId = ClientMgr:getApiId();
	if apiId == 45 or apiId == 52 or apiId == 53 then
		miniCoinIds = t_MiniCoinId_ios;
	elseif apiId == 345 or apiId == 346 then
		miniCoinIds = t_MiniCoinId_ios_en;
	elseif apiId >= 300 and apiId ~= 999 then
		miniCoinIds = t_MiniCoinId_en;
	end

	for i=1, #(miniCoinIds) do
		local miniDef = DefMgr:getMiniCoinDef(miniCoinIds[i].id);
		local miniDefCost = tonumber(string.format("%.2f",miniDef.Cost))
		if miniDef ~= nil and cost <= miniDefCost then
			if cost > 30 and not SdkManager:hasTPPay() then	--大于30元并且没有第三方[Desc1]
				if SmsPayLimit() == 2 then
					return 17;
				else
					return 16;
				end
			else
				return miniCoinIds[i].id;
			end
		end	
	end

	--找不到合适的[Desc2]选项，取最高消费选项
	if apiId == 45 or apiId == 52 or apiId == 53 then
		return 7;
	elseif apiId == 345 or apiId == 346 then
		return 6;
	elseif apiId >= 300 and apiId ~= 999 then
		return 6;
	elseif SmsPayLimit() == 1 then
		return 16;
	else
		return 17;
	end
end

statisticID = nil;
statisticStr = nil;

function SetOpenStoreMsgBoxSrc(statisticid,str)
	statisticID = statisticid;
	statisticStr = str;
end

local StoreMsgBox_Callback = nil;
local StoreMsgBox_CallbackData = nil;
local StoreMsgBox_replaceId = nil;
function ShowQRCodePay(cost)
	local frameQRCodeTips = getglobal("StoreMsgboxFrameQRCodeTips")
	if frameQRCodeTips then
		frameQRCodeTips:SetText("扫一扫充值，" .. "#cFA7A0F" ..  "点击分享", 51,55,55)
	end

	-- 清除老二维码
	local payQRCodeBkg = getglobal("StoreMsgboxFrameQRCodePayBkg")
	if payQRCodeBkg then
		payQRCodeBkg:SetTexture("ui/white.png")
	end
	GetInst("ShopAskForPay"):QueryMiniCoinAskForLimit(0,function()
		-- 第二个参数，索要道具类型：1 迷你币，2 皮肤 3 悦享卡
		GetInst("ShopAskForPay"):ReqMiniCoinAskForUrl(cost, 1, function(url) 
			local filename = "AskForPayQrTarget2.png"
			if gFunc_isStdioFileExist(filename) then
				gFunc_deleteStdioFile(filename)
			end

			local bSucc = QRCode:EncodeStringToPngFile(url,filename,8, LuaColorRGBA(0, 0, 0, 255), LuaColorRGBA(255, 255, 255, 255))
			if bSucc then
				local icon = getglobal("StoreMsgboxFrameQRCodePayBkg")
				if icon then
					icon:ReleaseTexture(filename)
					icon:SetTexture(filename);
				end
			end
		end)
	end)
end

--titleId -1为迷你币 -2为星星 -3迷你币兑换迷你豆, -6 迷你点， -7 赠送功能只显示真币
--from 1 开发者地图内
function StoreMsgBox(type, note, title, titleId, costNum, needNum, replaceId, callback, callback_data, from)
	if gIsSingleGame and type and type == 5 then
		ShowGameTips(GetS(555), 3)
		return
	end

    print('StoreMsgBox', type, note, title, titleId, costNum, needNum, replaceId, callback, callback_data);

	if type > #t_storeMsgType then return; end

	StoreMsgBox_Callback = callback;
	StoreMsgBox_CallbackData = callback_data;
	StoreMsgBox_replaceId = replaceId

	local frame = getglobal("StoreMsgboxFrame")
	local frameText = getglobal("StoreMsgboxFrameText")
	local frameTitle = getglobal("StoreMsgboxFrameHeadTitle");
	local frameTitle2 = getglobal("StoreMsgboxFrameHeadTitle2");
	local frameTitleIcon = getglobal("StoreMsgboxFrameHeadTitleIcon");
	local frameTitleIconText = getglobal("StoreMsgboxFrameHeadTitleIconText")

	local frameBkg = getglobal("StoreMsgboxFrameChenDi1")
	frameBkg:SetSize(653, 358) -- 默认尺寸
	frame:SetClientString("");
	frameText:clearHistory();

	if titleId == -4 then
		frameTitleIcon:Hide();
		frameTitleIconText:Hide();
		frameTitle:SetText("");
		frameTitle2:SetText(title);
	else
		local hnum = 0
		frameTitleIcon:Show();
		frameTitleIconText:Show();
		frameTitle:SetText(title);
		frameTitle2:SetText("");
		if titleId == -1 or titleId == -3 then
			frameTitleIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
			frameTitleIcon:SetTexUV("icon_coin.png");
			local minicoinNum = AccountManager:getAccountData():getMiniCoin();
			frameTitleIconText:SetText(minicoinNum.."/"..needNum, 233, 21, 21);
			hnum = minicoinNum
		elseif titleId == -2 then
			frameTitleIcon:SetTextureHuiresXml("ui/mobile/texture2/outgame.xml");
			frameTitleIcon:SetTexUV("juese_xingxing05.png");
			local starNum = math.floor(MainPlayerAttrib:getExp()/EXP_STAR_RATIO);
			frameTitleIconText:SetText(starNum.."/"..needNum, 233, 21, 21);
			hnum = starNum
		elseif titleId == -5 then
			frameTitleIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
			frameTitleIcon:SetTexUV("icon_coin.png");
			local minicoinNum = AccountManager:getAccountData():getMiniCoin();
			frameTitleIconText:SetText(minicoinNum.."/"..needNum, 77, 112, 117);
			hnum = minicoinNum
		elseif titleId == - 6 then
			frameTitleIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
			frameTitleIcon:SetTexUV("icon10009.png");
			local pointNum = AccountManager:getAccountData():getADPoint() or 0;
			if pointNum < 0 then pointNum = 0 end
			frameTitleIconText:SetText(pointNum.."/"..needNum, 77, 112, 117);
			hnum = pointNum
		elseif titleId == - 7 then
			frameTitleIcon:SetTextureHuiresXml("ui/mobile/texture2/common_icon.xml");
			frameTitleIcon:SetTexUV("icon_coin.png");
			local minicoinNum = AccountManager:getAccountData():getMiniCoinT();
			frameTitleIconText:SetText(minicoinNum.."/"..needNum, 233, 21, 21);
			hnum = minicoinNum
		else
			SetItemIcon(frameTitleIcon, titleId);	
			local hasNum = AccountManager:getAccountData():getAccountItemNum(titleId);
			frameTitleIconText:SetText(hasNum.."/"..needNum, 233, 21, 21);
			hnum = hasNum
		end
	end

	frameText:SetText(note, 55, 54, 47);

	if type == 9 or type == 14 then
		getglobal("StoreMsgboxFrameLeftBtn"):Hide();
		getglobal("StoreMsgboxFrameRightBtn"):Hide();
		getglobal("StoreMsgboxFrameCenterBtn"):Show();
		getglobal("StoreMsgboxFrameCenterBtnName1"):SetText(GetS(t_storeMsgType[type].centerId));
	elseif type == 19 then
		getglobal("StoreMsgboxFrameCenterBtn"):Hide();
		getglobal("StoreMsgboxFrameLeftBtn"):Show();
		getglobal("StoreMsgboxFrameRightBtn"):Show();
		getglobal("StoreMsgboxFrameLeftBtnName2"):Show()
		getglobal("StoreMsgboxFrameLeftBtnIcon"):Show()
		getglobal("StoreMsgboxFrameLeftBtnName"):Hide()
		getglobal("StoreMsgboxFrameRightBtnName1"):Hide()
		getglobal("StoreMsgboxFrameRightBtnName2"):Show()
		getglobal("StoreMsgboxFrameRightBtnIcon"):Show()

		getglobal("StoreMsgboxFrameRightBtnName2"):SetText("×"..costNum.." "..GetS(t_storeMsgType[type].rightNameId))
		getglobal("StoreMsgboxFrameLeftBtnName2"):SetText("×"..costNum.." "..GetS(t_storeMsgType[type].leftNameId))
		SetItemIcon(getglobal("StoreMsgboxFrameRightBtnIcon"), 10000)
		SetItemIcon(getglobal("StoreMsgboxFrameLeftBtnIcon"), 10009)

		if isEducationalVersion then
			getglobal("StoreMsgboxFrameRightBtn"):Hide();
			getglobal("StoreMsgboxFrameLeftBtn"):Hide();
		end
	else
		getglobal("StoreMsgboxFrameCenterBtn"):Hide();
		getglobal("StoreMsgboxFrameLeftBtn"):Show();
		getglobal("StoreMsgboxFrameRightBtn"):Show();

		getglobal("StoreMsgboxFrameLeftBtnName"):SetText(GetS(t_storeMsgType[type].leftNameId));
		getglobal("StoreMsgboxFrameLeftBtnName"):Show()
		getglobal("StoreMsgboxFrameLeftBtnName2"):Hide()
		getglobal("StoreMsgboxFrameLeftBtnIcon"):Hide()
		local rightBtnName1 = getglobal("StoreMsgboxFrameRightBtnName1")
		local rightBtnName2 = getglobal("StoreMsgboxFrameRightBtnName2")
		local rightBtnIcon = getglobal("StoreMsgboxFrameRightBtnIcon")
		if t_storeMsgType[type].needIcon then
			rightBtnName1:Hide();
			rightBtnName2:Show();
			rightBtnName2:SetText("×"..costNum.." "..GetS(t_storeMsgType[type].rightNameId));
			rightBtnIcon:Show();
			if replaceId == nil or replaceId == 10002 then
				rightBtnIcon:SetTextureHuiresXml(t_storeMsgType[type].iconPath);
				rightBtnIcon:SetTexUV(t_storeMsgType[type].uv);
			else
				SetItemIcon(rightBtnIcon, replaceId);
			end
		else
			rightBtnName1:Show();
			rightBtnName1:SetText(GetS(t_storeMsgType[type].rightNameId));
			rightBtnName2:Hide();
			rightBtnIcon:Hide();
		end

		if isEducationalVersion then
			getglobal("StoreMsgboxFrameRightBtn"):Hide();
		end
	end

	frame:Show();
	--开发者地图内 [Desc5] 就不跳转到商城去 from = 1 代表开发者地图内
	if titleId == -1 and not NoHideLockMiniCoinHideFrame() and (not from or from ~= 1)then
		frame:Hide();
		ShowGameTips(GetS(456), 3);
		
		ShopJumpTabView(7)
	end
end

function NoHideLockMiniCoinHideFrame()
	local t_frame = {"DeathFrame", "StarConvertFrame", "NpcTradeFrame", "EnchantFrame", "NickModifyFrame", "BeanConvertFrame","Shop", "BuyAndGifts","NewSkinShop","NewNewSkinShop", "HomelandShop","noviceWelfare","ShopSkinDisplay"}
	for i=1, #(t_frame) do
		local frame = getglobal(t_frame[i]);
		if frame:IsShown() then
			return true;
		end
	end

	if GetInst('MiniUIManager'):GetCtrl('activity_douluo_main') then return true end
	--皮肤售卖活动金币不足直接显示购买，不跳转到商城购买金币
	if GetInst('MiniUIManager'):GetCtrl('main_pifushoumai') then return true end
	if GetInst('MiniUIManager'):GetCtrl('main_personalImage_setting') then return true end

	return false;
end

function StoreMsgboxFrameLeftBtn_OnClick()
	if StoreMsgBox_Callback ~= nil and getglobal("StoreMsgboxFrame"):GetClientString() == "" then
		getglobal("StoreMsgboxFrame"):Hide();
		local callback, callback_data = StoreMsgBox_Callback, StoreMsgBox_CallbackData;
		StoreMsgBox_Callback, StoreMsgBox_CallbackData = nil, nil;
		StoreMsgBox_replaceId = nil;
		if callback then
			callback('left', callback_data);
		end
	else
		getglobal("StoreMsgboxFrame"):Hide();	
	end

end

function StoreMsgboxFrameCloseBtn_OnClick()
	getglobal("StoreMsgboxFrame"):Hide()
	local callback, callback_data = StoreMsgBox_Callback, StoreMsgBox_CallbackData;
	StoreMsgBox_Callback, StoreMsgBox_CallbackData = nil, nil;
	if callback then
		callback('close', callback_data);
	end
end

function AvatarStoreMsgboxFrameLeftBtn_OnClick()
	local AvatarStoreMsgboxFrame = getglobal("AvatarStoreMsgboxFrame");
	AvatarStoreMsgboxFrame:Hide();

	local callback, callback_data = StoreMsgBox_Callback, StoreMsgBox_CallbackData;
	StoreMsgBox_Callback, StoreMsgBox_CallbackData = nil, nil;
	StoreMsgBox_replaceId = nil;
	if callback then
		callback('left', callback_data);
	end

	if getglobal("Shop"):IsShown() or getglobal("NewSkinShop"):IsShown() or getglobal("NewNewSkinShop"):IsShown() or getglobal("HomelandCloset"):IsShown() then 
		return;
	end
	UpdateWishListData();

	if t_AvatarStoreWishListSeat.allSeatNum <= t_AvatarStoreWishListSeat.usedSeatNum then
		ShowGameTips(GetS(9272), 3)
	else
		 if Whetherhaspart(t_AvatarStoreTempBuy["ModelID"][1]) then
		 	ShowGameTips(GetS(9281), 3);
		 else		
			getglobal("NewStoreFrameSkinPage3WishList"):SetSize(55,55);
			WishAddPart(t_AvatarStoreTempBuy["ModelID"][1]);	
			ShowGameTips(GetS(9282), 3)
			getglobal("NewStoreFrameSkinPage3WishList"):SetSize(60,63);
		 end
	end

end

function AvatarStoreMsgBox(type, note, title, titleId, costNum, needNum, replaceId, callback, callback_data, TextHeight)
    print('AvatarStoreMsgBox', type, note, title, titleId, costNum, needNum, replaceId, callback, callback_data);

	if type > #t_storeMsgType then return; end

	StoreMsgBox_Callback = callback;
	StoreMsgBox_CallbackData = callback_data;
	StoreMsgBox_replaceId = replaceId
	
	local frame = getglobal("AvatarStoreMsgboxFrame")
	local frameText = getglobal("AvatarStoreMsgboxFrameText")
	local frameTitle = getglobal("AvatarStoreMsgboxFrameTitle");
	local frameTitle2 = getglobal("AvatarStoreMsgboxFrameTitle2");
	local frameTitleIcon = getglobal("AvatarStoreMsgboxFrameTitleIcon");
	local frameTitleIconText = getglobal("AvatarStoreMsgboxFrameTitleIconText")

	frame:SetClientString("");
	frameText:clearHistory();
	
	frameTitleIcon:Hide();
	frameTitleIconText:Hide();
	frameTitle:SetText("");
	frameTitle2:SetText(title);
	frameText:SetText(note, 55, 54, 47);
	if TextHeight and TextHeight > 0 then
		frameText:SetHeight(TextHeight)
	end

	getglobal("AvatarStoreMsgboxFrameCenterBtn"):Hide();
	getglobal("AvatarStoreMsgboxFrameLeftBtn"):Show();
	getglobal("AvatarStoreMsgboxFrameRightBtn"):Show();

	if GetInst("UIManager"):GetCtrl("ShopWishList","uiCtrlOpenList") or
		GetInst("UIManager"):GetCtrl("ShopCommend","uiCtrlOpenList") or
		GetInst("UIManager"):GetCtrl("ShopCustomSkinSave","uiCtrlOpenList") or
		GetInst("UIManager"):GetCtrl("ShopFriendGift","uiCtrlOpenList") or
		GetInst("UIManager"):GetCtrl("NewSkinShop","uiCtrlOpenList") or
		GetInst("UIManager"):GetCtrl("NewNewSkinShop","uiCtrlOpenList") or
		GetInst("UIManager"):GetCtrl("HomelandCloset","uiCtrlOpenList")
	 then
		getglobal("AvatarStoreMsgboxFrameLeftBtnName"):SetText(GetS(t_storeMsgType[type].leftNameId));
	else
		getglobal("AvatarStoreMsgboxFrameLeftBtnName"):SetText(GetS(9275));
	end
	local rightBtnName1 = getglobal("AvatarStoreMsgboxFrameRightBtnName1")
	local rightBtnName2 = getglobal("AvatarStoreMsgboxFrameRightBtnName2")
	local rightBtnIcon = getglobal("AvatarStoreMsgboxFrameRightBtnIcon")
	if t_storeMsgType[type].needIcon then
		rightBtnName1:Hide();
		rightBtnName2:Show();
		rightBtnName2:SetText("×"..costNum.." "..GetS(t_storeMsgType[type].rightNameId));
		rightBtnIcon:Show();
		if replaceId == nil or type == 5 then
			rightBtnIcon:SetTextureHuiresXml(t_storeMsgType[type].iconPath);
			rightBtnIcon:SetTexUV(t_storeMsgType[type].uv);
		else
			SetItemIcon(rightBtnIcon, replaceId);
		end
	else
		rightBtnName1:Show();
		rightBtnName1:SetText(GetS(t_storeMsgType[type].rightNameId),55,54,51);
		rightBtnName2:Hide();
		rightBtnIcon:Hide();
	end

	frame:Show();
	if titleId == -1 and not NoHideLockMiniCoinHideFrame() then
		frame:Hide();
		ShowGameTips(GetS(456), 3);

		ShopJumpTabView(7)
	end
end

function AvatarStoreMsgboxFrameRightBtn_OnClick()
	local AvatarStoreMsgboxFrame = getglobal("AvatarStoreMsgboxFrame") 
	AvatarStoreMsgboxFrame:Hide();

	local callback, callback_data = StoreMsgBox_Callback, StoreMsgBox_CallbackData;
	StoreMsgBox_Callback, StoreMsgBox_CallbackData = nil, nil;
	StoreMsgBox_replaceId = nil;
	if callback then
		callback('right', callback_data);
	end

	if AvatarStoreMsgboxFrame:GetClientString() == "确认购买部件"then
		AvtPartInfo:UpPartBuyInfo(t_AvatarStoreTempBuy["ModelID"][1]);
		local avatarPartDef = GetServerAvatarPartInfo(t_AvatarStoreTempBuy["PartID"][1], t_AvatarStoreTempBuy["ModelID"][1]);
		if not avatarPartDef then
			return;
		end
		if getglobal("AvatarStoreMsgboxFrame"):IsShown() then
			getglobal("AvatarStoreMsgboxFrame"):Hide();
		end
		local state;
		local needNum = avatarPartDef.cfg.Num;
		if avatarPartDef.cfg.CostType == 2 then
			state = CheckMiniCoin(needNum);
		elseif avatarPartDef.cfg.CostType == 4 then
			state = CheckMiniBean(needNum)
		else
			state = 1;
		end
		-- print("state",state);
		-- if avatarPartDef.cfg.CostType ~= 2 then
		-- 	state = 1;
		-- end

		-- local state = CheckMiniBean(needNum);
		-- if avatarPartDef.cfg.CostType ~= 4 then
		-- 	state = 1;
		-- end
		if state == 0 then						
			if getglobal("AvatarStoreMsgboxFrame"):IsShown() then
				getglobal("AvatarStoreMsgboxFrame"):Hide();
			end
			if avatarPartDef.cfg.CostType == 2 then 	--迷你币不足
				local needNum = avatarPartDef.cfg.Num;
				local hasNum = 	AccountManager:getAccountData():getMiniCoin(); 
				local lackMiniNum = needNum - hasNum;
				local cost, buyNum = GetPayRealCost(lackMiniNum);
				local text = GetS(453, cost, buyNum);
				StoreMsgBox(6, text, GetS(456), -1, lackMiniNum, needNum, nil, NotEnoughMiniCoinCharge, cost);
				return;	
			else 									--迷你豆不足
				getglobal("BeanConvertFrame"):Show(); 	
				ShowGameTips(GetS(4775), 3);
				return;	
			end									
		elseif state > 1 then	
			return;
		elseif state == 1 then
			local code, cfg, skin = AccountManager:avatar_skin_buy(t_AvatarStoreTempBuy["Uin"][1], t_AvatarStoreTempBuy["ModelID"][1]);
			print("AvatarStoreMsgboxFrameRightBtn_OnClick3", t_AvatarStoreTempBuy["ModelID"][1], code, cfg, skin)
			AvtPartInfo:UpPartBuyInfo2(t_AvatarStoreTempBuy["ModelID"][1]);
			UpdateSingleAvatarPartState(t_AvatarStoreTempBuy["ModelID"][1]);
			if code == 0 then
				ShowGameTips(GetS(627), 3);
				--刷新avatar 部件内容
				WishDelPart(t_AvatarStoreTempBuy["ModelID"][1]);
			else
				if code == 17000 then
					ShowGameTips(GetS(9287));
				elseif code == 4103 then					
					ShowGameTips(GetS(9288));
				else
					ShowGameTips(GetS(9286));
				end
			end
			--刷新avatar
			updateAvatarPartInfoLayout(code, cfg, skin);
			print("AvatarStoreMsgboxFrameRightBtn_OnClick-->updateAvatarPartInfoLayout", code, cfg, skin)
			--:[Desc5]成功展示界面
			t_AvatarStoreTempBuy["Code"][1] = code;
		end
	end

	if AvatarStoreMsgboxFrame:GetClientString() == "一键购买部件" then
		local needcoin = 0;
		local needbean = 0;
		local uinNum = #t_AvatarStoreTempBuy.Uin
		local modelIDNum = #t_AvatarStoreTempBuy.ModelID
		local buy_success = false

		needcoin,needbean = CountMininum();
		print("AvatarStoreMsgboxFrameRightBtn_OnClick 一键购买部件 CostType 2", needcoin)
		if CheckMiniCoin(needcoin) == 0 then
			local hasNum = 	AccountManager:getAccountData():getMiniCoin(); 
			local lackMiniNum = needcoin - hasNum;
			local cost, buyNum = GetPayRealCost(lackMiniNum);
			local text = GetS(453, cost, buyNum);
			StoreMsgBox(6, text, GetS(456), -1, lackMiniNum, needcoin, nil, NotEnoughMiniCoinCharge, cost);
			return;	
		elseif CheckMiniBean(needbean) == 0 then						
			getglobal("BeanConvertFrame"):Show(); 	--迷你豆不足
			ShowGameTips(GetS(4775), 3);
			return;	
		else	
			if uinNum == modelIDNum then
				for i = 1, uinNum do
					local code, cfg, skin = AccountManager:avatar_skin_buy(t_AvatarStoreTempBuy["Uin"][i], t_AvatarStoreTempBuy["ModelID"][i]);
					AvtPartInfo:UpPartBuyInfo(t_AvatarStoreTempBuy["ModelID"][i])
					if code == 0 then
						buy_success = true;
						WishDelPart(t_AvatarStoreTempBuy["ModelID"][i]);
					else
						if code == 17000 then
							ShowGameTips(GetS(9287));
						elseif code == 4103 then
							ShowGameTips(GetS(9288));
						else
							ShowGameTips(GetS(9286));
						end
					end
					t_AvatarStoreTempBuy["Code"][i] = code;
				end
			end
			
			if buy_success then	
			end
		end	
	end
end

function AvatarStoreMsgboxFrameCloseBtn_OnClick()
	getglobal("AvatarStoreMsgboxFrame"):Hide();
	local callback, callback_data = StoreMsgBox_Callback, StoreMsgBox_CallbackData;
	StoreMsgBox_Callback, StoreMsgBox_CallbackData = nil, nil;
	StoreMsgBox_replaceId = nil;
	if callback then
		callback('close', callback_data);
	end
end

function StoreMsgboxFrameRightBtn_OnClick()
	local StoreMsgboxFrame = getglobal("StoreMsgboxFrame") 
	StoreMsgboxFrame:Hide();
	print("StoreMsgboxFrameRightBtn_OnClick1", StoreMsgBox_Callback, "--", StoreMsgBox_CallbackData);
	print("StoreMsgboxFrameRightBtn_OnClick2", StoreMsgboxFrame:GetClientString())
	if StoreMsgBox_Callback ~= nil and getglobal("StoreMsgboxFrame"):GetClientString() == "" then
		getglobal("StoreMsgboxFrame"):Hide();
		local callback, callback_data = StoreMsgBox_Callback, StoreMsgBox_CallbackData;
		StoreMsgBox_Callback, StoreMsgBox_CallbackData = nil, nil;
		StoreMsgBox_replaceId = nil;
		if callback then
			callback('right', callback_data);
		end

		if HasUIFrame("ArchiveRewardFrame") and getglobal("ArchiveRewardFrame"):IsShown() then
			getglobal("ArchiveRewardFrame"):Hide();
			GetInst("UIManager"):GetCtrl("MapReward"):RewardSelectFrameConfirmBtnClicked();
		end
		
		if HasUIFrame("NickModifyFrame") and getglobal("NickModifyFrame"):IsShown() then
			getglobal("NickModifyFrame"):Hide()
		end
	elseif StoreMsgboxFrame:GetClientString() == "道具不足解锁角色" then 
		MiniCoinReplaceUnlockRole();
	elseif StoreMsgboxFrame:GetClientString() == "道具不足解锁或升级坐骑" then
		MiniCoinReplaceBuyRide();
	elseif StoreMsgboxFrame:GetClientString() == "迷你币不足" then
        if getglobal("BeanConvertFrame"):IsShown() then
			getglobal("BeanConvertFrame"):Hide();
        end
        if getglobal("BuyAndGifts"):IsShown() then
			GetInst("UIManager"):Close("BuyAndGifts")
		end
        if GetInst("MiniUIManager"):IsShown("buyActivityTicketAutoGen") then
			GetInst("MiniUIManager"):CloseUI("buyActivityTicketAutoGen")
		end
		local entryType = 0
		-- if getglobal("MiniLobbyFrame"):IsShown() then
		if GetInst("MiniUIManager"):IsShown("CreationCenterMain") then
			local ctrl = GetInst("MiniUIManager"):GetCtrl("CreationCenterMain")
			if ctrl and ctrl.ReturnBtnClick then
				ctrl:ReturnBtnClick(nil, nil, true)
				entryType = 12
			end
		elseif getglobal("PlayerExhibitionCenter"):IsShown() then
			entryType = 6
		elseif IsMiniLobbyShown() then --mark by hfb for new minilobby
			entryType = 1
		elseif getglobal("HomeChestFrame"):IsShown() then
			entryType = 2
		elseif GetInst("UIManager"):GetCtrl("ResourceShop", "uiCtrlOpenList") then
			entryType = 5
			if GetInst("UIManager"):GetCtrl("ResourceShopItemDetail", "uiCtrlOpenList") then
				GetInst("UIManager"):GetCtrl("ResourceShopItemDetail"):CloseBtnClicked()
			end
		end

		local param
		if GetInst("MiniUIManager"):IsShown("Specialty_main") then
			local curOpIdx = GetInst("MiniUIManager"):GetCtrl("Specialty_main"):GetCurOperateIdx()
			GetInst("MiniUIManager"):CloseUI("Specialty_mainAutoGen", true)

			param = {}
			param.callback = function()
				GetInst("GeniusMgr"):OpenGenius({curOperateIdx = curOpIdx})
			end
		end

		ShopJumpTabView(7, entryType, param)
	elseif StoreMsgboxFrame:GetClientString() == "道具不足升级角色天赋" then
		MiniCoinReplaceUpgradeGenuisLv();
	elseif StoreMsgboxFrame:GetClientString() == "复活星星不足" then
		if	RechargeSrc ~= nil	and RechargeStr ~= nil then
			SetOpenStoreMsgBoxSrc(RechargeSrc,RechargeStr);
			RechargeSrc = nil;
			RechargeStr = nil;
		end
		DeathMiniCoinConvertStar();
	elseif StoreMsgboxFrame:GetClientString() == "设置复活点星星不足" then
		if	RechargeSrc ~= nil	and RechargeStr ~= nil then
			SetOpenStoreMsgBoxSrc(RechargeSrc,RechargeStr);
			RechargeSrc = nil;
			RechargeStr = nil;
		end
        RevivePointMiniCoinConvertStar();
	elseif StoreMsgboxFrame:GetClientString() == "刷新货物星星不足" then
		NpcTradeMiniCoinRefresh();
	elseif StoreMsgboxFrame:GetClientString() == "附魔星星不足" then	 
		EnchantMinicoin();
	elseif StoreMsgboxFrame:GetClientString() == "选择附魔星星不足" then
		ChooseEnchantMinicoin();
	elseif StoreMsgboxFrame:GetClientString() == "购买货物星星不足" then
		NpcTradeMiniCoinBuy();
	elseif StoreMsgboxFrame:GetClientString() == "迷你币不足去充值" then
		if AccountManager:getAccountData():isPaying() then
			ShowGameTips(GetS(534), 3);
		else
			local cost = StoreMsgboxFrame:GetClientUserData(0);
			local payId = tostring(GetPayCostId(cost));
			local miniDef = DefMgr:getMiniCoinDef(payId);
			print("kekeke charge", cost, payId, miniDef);
			if miniDef ~= nil then
				ChargeMiniCoins(miniDef.Name, cost, payId, miniDef.Num);
			end	
		end
		StoreMsgboxFrame:SetClientUserData(0, 0);
	--	ShowGameTips("打开SDK[Desc2]界面"..cost.."playId:"..payId, 3);
	elseif StoreMsgboxFrame:GetClientString() == "道具不足前往家园获取" then
		Log("go_to_homechest !!!");
		HomeChestMgr:requestChestTreeReq(AccountManager:getUin())
		ShowLoadLoopFrame(true, "file:messagebox -- func:StoreMsgboxFrameRightBtn_OnClick");
	elseif StoreMsgboxFrame:GetClientString() == "道具不足解锁方块" then
		if getglobal("ShopWareInfo"):IsShown() then
			MiniBeanReplaceUnlockItemStash();    -- 怎么这个方法找不到了 ??
		else
			MiniBeanReplaceUnlockItem();
		end
	elseif StoreMsgboxFrame:GetClientString() == "新家园道具不足解锁方块" then
		if IsEnableHomeLand and IsEnableHomeLand() then
			if IsUIFrameShown("HomelandBackpack") then
				GetInst("UIManager"):GetCtrl("HomelandBackpack"):DoReplaceReqBuildingBagUnlock()
			elseif IsUIFrameShown("HomeProducer") then 
				GetInst("UIManager"):GetCtrl("HomeProducer"):DoReplaceReqBuildingBagUnlock()
			elseif IsUIFrameShown("HomelandShopBlock") then
				GetInst("UIManager"):GetCtrl("HomelandShopBlock"):DoReplaceReqBuildingBagUnlock()
			elseif IsUIFrameShown("HomelandShopFurniture") then
				GetInst("UIManager"):GetCtrl("HomelandShopFurniture"):DoReplaceReqBuildingBagUnlock()
			end
		end
	elseif StoreMsgboxFrame:GetClientString() == "确认解锁材质包" then
		ConfirmBuyMaterialMod();
	elseif StoreMsgboxFrame:GetClientString() == "确认解锁或升级坐骑" then
		ConfirmBuyRide();
	elseif StoreMsgboxFrame:GetClientString() == "确认购买皮肤" then
		local type = StoreMsgboxFrame:GetClientUserData(0);
		ConfirmBuySkin(type);
		StoreMsgboxFrame:SetClientUserData(0, 0);
	elseif StoreMsgboxFrame:GetClientString() == "确认升级天赋" then
		ConfirmUpGenuisLv();
	elseif StoreMsgboxFrame:GetClientString() == "确认解锁角色" then
		ConfirmUnlockRole();
	elseif StoreMsgboxFrame:GetClientString() == "确认回收" then
		local itemId = StoreMsgboxFrame:GetClientUserData(0);
		RecycleItem(itemId);
		StoreMsgboxFrame:SetClientUserData(0, 0);
	elseif StoreMsgboxFrame:GetClientString() == "坑位不足" then
		NewStoreFrameSkinTabBtn_OnClick(2);
	elseif StoreMsgboxFrame:GetClientString() == "打赏购买" then
		MapRewardClass:RewardMap();
	elseif StoreMsgboxFrame:GetClientString() == "CloudServerBuy" then
		-- 云服[Desc5]确认
		GetInst("UIManager"):GetCtrl("CloudServerBuy"):BuyCloudServerConfirm()
	end
end

function StoreMsgboxFrameCenterBtn_OnClick()
	if StoreMsgBox_Callback ~= nil and getglobal("StoreMsgboxFrame"):GetClientString() == "" then
		getglobal("StoreMsgboxFrame"):Hide();
		local callback, callback_data = StoreMsgBox_Callback, StoreMsgBox_CallbackData;
		StoreMsgBox_Callback, StoreMsgBox_CallbackData = nil, nil;
		StoreMsgBox_replaceId = nil;
		if callback then
			callback('center', callback_data);
		end
	else
		getglobal("StoreMsgboxFrame"):Hide();	
	end
end

function StoreMsgboxFrame_OnHide()
	local StoreMsgboxFrame = getglobal("StoreMsgboxFrame");

	if  IsUIFrameShown("PokedexSeriesBox") then
		getglobal("PokedexSeriesBox"):setDealMsg(true);
	end
end

-----------------------------------------LongMsgboxFrame---------------------------------------
local t_LongMsgboxFrameData = {
	callback = nil,
	callback_data = nil,
}

function SetLongMsgboxFrame(data, callback, callback_data)

	getglobal("LongMsgboxFrameTitleFrameName"):SetText(data.title);
	getglobal("LongMsgboxFrameText"):SetText(data.content, 143, 90, 54);
	getglobal("LongMsgboxFrameLeftBtn"):Hide();
	getglobal("LongMsgboxFrameCenterBtn"):Hide();
	getglobal("LongMsgboxFrameRightBtn"):Hide();

	if data.leftname then
		getglobal("LongMsgboxFrameLeftBtn"):Show();
		getglobal("LongMsgboxFrameLeftBtnName"):SetText(data.leftname);
	end
	if data.centername then
		getglobal("LongMsgboxFrameCenterBtn"):Show();
		getglobal("LongMsgboxFrameCenterBtnName"):SetText(data.centername);
	end
	if data.rightname then
		getglobal("LongMsgboxFrameRightBtn"):Show();
		getglobal("LongMsgboxFrameRightBtnName"):SetText(data.rightname);
	end

	t_LongMsgboxFrameData.callback = callback;
	t_LongMsgboxFrameData.callback_data = callback_data;

	getglobal("LongMsgboxFrame"):Show();
end

function LongMsgboxFrameLeftBtn_OnClick()
	getglobal("LongMsgboxFrame"):Hide();

	if t_LongMsgboxFrameData.callback then
		local callback, callback_data = t_LongMsgboxFrameData.callback, t_LongMsgboxFrameData.callback_data;
		t_LongMsgboxFrameData.callback, t_LongMsgboxFrameData.callback_data = nil, nil;
		callback(callback_data, 'left');
	end
end

function LongMsgboxFrameRightBtn_OnClick()
	getglobal("LongMsgboxFrame"):Hide();

	if t_LongMsgboxFrameData.callback then
		local callback, callback_data = t_LongMsgboxFrameData.callback, t_LongMsgboxFrameData.callback_data;
		t_LongMsgboxFrameData.callback, t_LongMsgboxFrameData.callback_data = nil, nil;
		callback(callback_data, 'right');
	end
end

function LongMsgboxFrameCenterBtn_OnClick()
	getglobal("LongMsgboxFrame"):Hide();

	if t_LongMsgboxFrameData.callback then
		local callback, callback_data = t_LongMsgboxFrameData.callback, t_LongMsgboxFrameData.callback_data;
		t_LongMsgboxFrameData.callback, t_LongMsgboxFrameData.callback_data = nil, nil;
		callback('center', callback_data);
	end
end

--------------------------------------ChoosePayTypeFrame-----------------------------------
local PayItemName = "" --商品名字
local PayCost = 0;     --金额
local TradeId = 0;     --tradeid
local buyType = 0      --[Desc5]类型
local PayData = {}     --商品的配置信息 (id,num)
--buyType参数代表[Desc2][Desc5]的类型（默认为[Desc2]迷你币，1为BattlePass直购 2为Money直购）
function SetPayInfo(name, cost, tradeid, buyT,payData)
	buyType = buyT
	PayItemName = name;
	PayCost = cost;
	TradeId = tradeid;
	PayData = payData or {}
	-- 重置隐藏显示状态
	-- getglobal("ChoosePayTypeFrameSMSPayBtnName"):Show();
	-- getglobal("ChoosePayTypeFrameTPPayBtnName"):Show();
	getglobal("ChoosePayTypeFrameSMSPayBtn"):Hide();
	getglobal("ChoosePayTypeFrameTPPayBtn"):Hide();
	getglobal("ChoosePayTypeFrameQQWalletPayBtn"):Hide();
	getglobal("ChoosePayTypeFrameWeChatPayBtn"):Hide();
	getglobal("ChoosePayTypeFrameAlipayPayBtn"):Hide();
	getglobal("ChoosePayTypeFrameFriendPayBtn"):Hide();

	local apiId = ClientMgr:getApiId();
	if apiId == 1 or IsMiniCps(apiId) or apiId == 12 or apiId == 49 then --官方	--三星、小米[Desc1]没有整个各种[Desc1]方式，套用官包的[Desc1]选择界面
		getglobal("ChoosePayTypeFrameSMSPayBtnName"):SetText(GetS(783)); -- 微信[Desc1]
		getglobal("ChoosePayTypeFrameTPPayBtnName"):SetText(GetS(784)); -- [Desc1]宝[Desc1]
		getglobal("ChoosePayTypeFrameSMSPayBtn"):Show();
		getglobal("ChoosePayTypeFrameTPPayBtn"):Show();
		if apiId ~= 49 and apiId ~= 69 and apiId ~= 10 then  --摸摸鱼渠道的QQ[Desc1]屏蔽掉 联想渠道QQ[Desc1]屏蔽
			getglobal("ChoosePayTypeFrameQQWalletPayBtn"):Show();
		end
		if apiId == 49 or apiId == 10 then
			getglobal("ChoosePayTypeFrameChenDi1"):SetHeight(409);
		end
	elseif apiId == 36 then
		if cost > 30 or ClientMgr:getImsi() < 2 then
			getglobal("ChoosePayTypeFrameChenDi1"):SetHeight(532);
			getglobal("ChoosePayTypeFrameTPPayBtn"):SetPoint("top", "ChoosePayTypeFrameChenDi1", "top", 0, 76);
			getglobal("ChoosePayTypeFrameTPPayBtnName"):SetText(GetS(3186));
			getglobal("ChoosePayTypeFrameTPPayBtn"):Show();
			getglobal("ChoosePayTypeFrameWeChatPayBtn"):Show();
			getglobal("ChoosePayTypeFrameAlipayPayBtn"):Show();
		else
			getglobal("ChoosePayTypeFrameChenDi1"):SetHeight(532);
			getglobal("ChoosePayTypeFrameSMSPayBtnName"):SetText(GetS(3185)); -- 短信[Desc1]
			getglobal("ChoosePayTypeFrameTPPayBtnName"):SetText(GetS(3186)); -- 其他[Desc1]
			getglobal("ChoosePayTypeFrameSMSPayBtn"):Show();
			getglobal("ChoosePayTypeFrameTPPayBtn"):Show();
			getglobal("ChoosePayTypeFrameWeChatPayBtn"):Show();
			getglobal("ChoosePayTypeFrameAlipayPayBtn"):Show();
		end
	elseif apiId == 310 then -- 海外官包，显示微信、[Desc1]宝[Desc2]
		getglobal("ChoosePayTypeFrameChenDi1"):SetHeight(409);
		getglobal("ChoosePayTypeFrameWeChatPayBtn"):SetPoint("top", "ChoosePayTypeFrameChenDi1", "top", 0, 76);
		getglobal("ChoosePayTypeFrameWeChatPayBtn"):Show();
		getglobal("ChoosePayTypeFrameAlipayPayBtn"):Show();
	else
		getglobal("ChoosePayTypeFrameSMSPayBtnName"):SetText(GetS(3185)); -- 短信[Desc1]
		getglobal("ChoosePayTypeFrameTPPayBtnName"):SetText(GetS(3186)); -- 其他[Desc1]
		getglobal("ChoosePayTypeFrameChenDi1"):SetHeight(409);
		getglobal("ChoosePayTypeFrameSMSPayBtn"):Show();
		getglobal("ChoosePayTypeFrameTPPayBtn"):Show();
	end
end

function ChoosePayTypeFrameSMSPayBtn_OnClick()
	local apiId = ClientMgr:getApiId()
	if apiId == 1 then
		--功能限制
		if not FunctionLimitCtrl:IsNormalBtnClick(FunctionType.PAY) then
			ChoosePayTypeFrameCancelBtn_OnClick();
			return;
		end
	end
	if buyType == g_enum_payType.battalPass then--bp
		GetInst("NewBattlePassPay"):BattlePassSdkPay(PayItemName, PayCost, TradeId, 0)
	elseif buyType == g_enum_payType.vip then--会员
		GetInst('MembersSysMgr'):CreatetVipOrder(PayData,0)
	elseif buyType == g_enum_payType.gift then -- 商城-礼包直购 
		GetInst('ShopService'):CreateGiftRechargeOrder(PayCost, TradeId, 0, PayData.itemId)
	else
		SdkPay(PayItemName, PayCost, TradeId, 0);
	end
	getglobal("ChoosePayTypeFrame"):Hide();
end

function ChoosePayTypeFrameTPPayBtn_OnClick()
	local apiId = ClientMgr:getApiId()
	if apiId == 1 then
		--功能限制
		if not FunctionLimitCtrl:IsNormalBtnClick(FunctionType.PAY) then
			ChoosePayTypeFrameCancelBtn_OnClick();
			return;
		end
	end
	if buyType ==  g_enum_payType.battalPass then--bp
		GetInst("NewBattlePassPay"):BattlePassSdkPay(PayItemName, PayCost, TradeId, 1)
	elseif buyType == g_enum_payType.vip then--会员
		GetInst('MembersSysMgr'):CreatetVipOrder(PayData,1)
	elseif buyType == g_enum_payType.gift then -- 商城-礼包直购 
		GetInst('ShopService'):CreateGiftRechargeOrder(PayCost, TradeId, 1, PayData.itemId)
	else
		SdkPay(PayItemName, PayCost, TradeId, 1)
	end
	getglobal("ChoosePayTypeFrame"):Hide();
end

function ChoosePayTypeFrameQQWalletPayBtn_OnClick()
	local apiId = ClientMgr:getApiId()
	if apiId == 1 then
		--功能限制
		if not FunctionLimitCtrl:IsNormalBtnClick(FunctionType.PAY) then
			ChoosePayTypeFrameCancelBtn_OnClick();
			return;
		end
	end
	SandboxLua.eventDispatcher:Emit(nil, "ChoosePayTypeFrame_QQ_OnClick", SandboxContext():SetData_String("ret", ""))
	if buyType ==  g_enum_payType.battalPass then--bp
		GetInst("NewBattlePassPay"):BattlePassSdkPay(PayItemName, PayCost, TradeId, 2)
	elseif buyType == g_enum_payType.vip then--会员
		GetInst('MembersSysMgr'):CreatetVipOrder(PayData,2)
	elseif buyType == g_enum_payType.gift then -- 商城-礼包直购 
		GetInst('ShopService'):CreateGiftRechargeOrder(PayCost, TradeId, 2, PayData.itemId)
	else
		SdkPay(PayItemName, PayCost, TradeId, 2)
	end
	getglobal("ChoosePayTypeFrame"):Hide();
end

function ChoosePayTypeFrameWeChatPayBtn_OnClick()
	SandboxLua.eventDispatcher:Emit(nil, "ChoosePayTypeFrame_WeChat_OnClick", SandboxContext():SetData_String("ret", ""))
	if buyType ==  g_enum_payType.battalPass then--bp
		GetInst("NewBattlePassPay"):BattlePassSdkPay(PayItemName, PayCost, TradeId, 3)
	elseif buyType == g_enum_payType.vip then--会员
		GetInst('MembersSysMgr'):CreatetVipOrder(PayData,3)
	elseif buyType == g_enum_payType.gift then -- 商城-礼包直购 
		GetInst('ShopService'):CreateGiftRechargeOrder(PayCost, TradeId, 3, PayData.itemId)
	else
		SdkPay(PayItemName, PayCost, TradeId, 3)
	end
	getglobal("ChoosePayTypeFrame"):Hide();
end

function ChoosePayTypeFrameAlipayPayBtn_OnClick()
	SandboxLua.eventDispatcher:Emit(nil, "ChoosePayTypeFrame_Alipay_OnClick", SandboxContext():SetData_String("ret", ""))
	if buyType ==  g_enum_payType.battalPass then--bp
		GetInst("NewBattlePassPay"):BattlePassSdkPay(PayItemName, PayCost, TradeId, 4)
	elseif buyType == g_enum_payType.vip then--会员
		GetInst('MembersSysMgr'):CreatetVipOrder(PayData,4)
	elseif buyType == g_enum_payType.gift then -- 商城-礼包直购 
		GetInst('ShopService'):CreateGiftRechargeOrder(PayCost, TradeId, 4, PayData.itemId)
	else
		SdkPay(PayItemName, PayCost, TradeId, 4)
	end
	getglobal("ChoosePayTypeFrame"):Hide();
end

function ChoosePayTypeFrameCancelBtn_OnClick()
	getglobal("ChoosePayTypeFrame"):Hide();
end

--朋友[Desc4]按钮
function ChoosePayTypeFrameFriendpayPayBtn_OnClick()
	local apiId = ClientMgr:getApiId()
	if apiId == 1 then
		--功能限制
		if not FunctionLimitCtrl:IsNormalBtnClick(FunctionType.PAY) then
			ChoosePayTypeFrameCancelBtn_OnClick();
			return;
		end
	end

	--[Desc5]次数
	local miniCoinTab = DefMgr:getMiniCoinDef(TradeId) -- minicoin.csv
	local buynum = miniCoinTab and miniCoinTab.BuyNum
	if buynum == 1 then
		ShowGameTipsWithoutFilter(GetS(9909))
	else
		GetInst("UIManager"):Open("FriendPayFrame",{minicoinid=TradeId});
		getglobal("ChoosePayTypeFrame"):Hide();
	end
end

function ChoosePayTypeFrame_OnShow()
	SandboxLua.eventDispatcher:Emit(nil, "ChoosePayTypeFrame_OnShow", SandboxContext():SetData_String("ret", ""))
end

function ChoosePayTypeFrame_OnHide()
	PayItemName = ""
 	PayCost = 0;
 	TradeId = 0;
	PayData = {}
end


----------------------------------------------------RSConnectLostFrame-----------------------------------------------
--与主机断开后关闭ui
function RSConnectLostCloseUI()
	if getglobal("LettersFrame"):IsShown() then
		getglobal("LettersFrame"):Hide();
	elseif getglobal("BookFrame"):IsShown() then
		getglobal("BookFrame"):Hide();
	elseif getglobal("ResourceShopItemDetail"):IsShown() then 
		GetInst("UIManager"):GetCtrl("ResourceShopItemDetail"):CloseBtnClicked()
	elseif getglobal("ResourceShop"):IsShown() then 
		GetInst("UIManager"):GetCtrl("ResourceShop"):CloseBtnClicked()
	end
end

function RSConnectLostFrame_OnLoad()
	this:RegisterEvent("GE_CUSTOMGAME_STAGE");
end

function RSConnectLostFrame_OnEvent()
	if arg1 == "GE_CUSTOMGAME_STAGE" then
		local ge = GameEventQue:getCurEvent();
		local stage = ge.body.cgstage.stage;
		if stage == 4 then
			if getglobal("RSConnectLostFrame"):IsShown() then
				getglobal("RSConnectLostFrame"):Hide();
			end
		end
	end
end

-- 不允许中途加入/房主关闭房间弹框显示时上报 by fym
function RSConnectLostFrame_ShowReport()
	if getglobal("RSConnectLostFrame") then
		local cause = getglobal("RSConnectLostFrame"):GetClientUserData(0)
		if cause == 2 or cause == 6 then
			local eventType = "MidExit"  -- 麻麻叫房主吃饭了，关闭了房间
			if cause == 6 then
				eventType = "MidjoinBan"  -- 该房间不允许中途加入游戏，请尝试别的房间
			end
			if ROOM_SERVER_RENT == ClientMgr:getRoomHostType() then  -- 云服
				-- standReportEvent("1002", "MINI_CLOUDROOM_GAME_1", eventType, "view")
				standReportEvent("1001", "MINI_GAMEROOM_GAME_1", eventType, "view")
			elseif not IsStandAloneMode() then  -- 普通房间				
				standReportEvent("1001", "MINI_GAMEROOM_GAME_1", eventType, "view")
			end
		end
	end
end

-- 好友家园好友断开连接自己被踢出上报
function RSConnectLostFrame_FriendReport()
	local friendUin = GetInst("HomeLandDataManager"):GetCurVisiteHomeMapUin()

	if friendUin and friendUin > 0 then
		StopCalcFriendHomelandTime()
		local d = GetInst("HomeLandDataManager"):GetAllEnterFriendHomelandTime()
		local t = 0
		for k, v in pairs(d) do
			t = t + v
		end
		standReportEvent("602", "MINI_MY_HOMELAND_FRIEND_HOMEOWERS_LEFT", "Back2", "click", {
			standby1 = tostring(GetInst("HomeLandDataManager"):GetEnterFriendHomelandTime(friendUin)),  --当前好友家园逗留时长
			standby2 = tostring(t), --所有好友家园逗留总时长
		})
	end
end

function RSConnectLostFrame_OnShow()
	
	if ClientCurGame:isInGame() then
		ClientCurGame:setOperateUI(true);
		local teamupSer = GetInst("TeamupService")
		if teamupSer and teamupSer:IsInTeam(AccountManager:getUin()) then
			getglobal("RSConnectLostFrame"):Hide()
			MessageBox(4, GetS(26077) ,function(btn)
				if btn == 'center' then
					GetInst("TeamVocieManage"):GameExitReport()
					RSConnectLostFrameConfirmBtn_OnClick()
					threadpool:wait(gen_gid(),0.2,{tick=function()
						threadpool:notify("teamup.checkMinBtn")
					end})
				end
			end)
			return
		end
		-- 不允许中途加入/房主关闭房间弹框显示时上报 by fym
		RSConnectLostFrame_ShowReport()

		if IsInHomeLandMap and IsInHomeLandMap() then
			standReportEvent("602", "MINI_MY_HOMELAND_FRIEND_HOMEOWERS_LEFT", "Back2", "view")
		end		
		--MiniBaseUDP丢失界面显示游戏加载成功           
		SandboxLua.eventDispatcher:Emit(nil, "MiniBase_GameLaunchFinish",  SandboxContext():SetData_Number("code", 1))	
	end
	
	RSConnectLostCloseUI();
end

function RSConnectLostFrame_OnHide()
	if ClientCurGame:isInGame() then
		ClientCurGame:setOperateUI(false);
	end
	--如果家园会改变这个字符串，所以隐藏式重置下
	getglobal("RSConnectLostFrameConfirmBtnName"):SetText(GetS("3677"))
end

function RSConnectLostFrameConfirmBtn_OnClick()	
	if ClientCurGame:isInGame() then
		if IsInHomeLandMap and IsInHomeLandMap() then
			RSConnectLostFrame_FriendReport()
			getglobal("RSConnectLostFrame"):Hide()
			EnterHomeLandInfo= { step = HomeLandInterativeStep.RELOAD_OWN_HOME_LAND }
			ExitHomeLandAndTurnToNextOperate()
			return
		end

		HideAllFrame(nil, false);
		for i=1, #(t_BackMainMenuNeedHideFrame) do
			local frame = getglobal(t_BackMainMenuNeedHideFrame[i]);
			if frame:IsShown() then
				frame:Hide();
			end
		end

		
		EnterMainMenuInfo.LoginRoomServer = true;
		--MiniBase主机断连切换到APP
		SandboxLua.eventDispatcher:Emit(nil, "MiniBase_LeaveGame",  SandboxContext():SetData_Number("code", 0))
		ClientMgr:gotoGame("MainMenuStage");
	else
		local cause = getglobal("RSConnectLostFrame"):GetClientUserData(0);
		if cause ~= 99 then
			getglobal("RSConnectLostFrame"):SetClientUserData(0, 0);
			LobbyFrameRoomBtn_OnClick(true);
		end
	end
	getglobal("RSConnectLostFrame"):Hide();	
end

function RSConnectLostFrameWatchADBtn_OnClick()
	local positionId = ad_data_new.lostConnectPosId;
	if IsAdUseNewLogic(position_id) then	
		StatisticsADNew('onclick', positionId);
	else
		StatisticsAD('onclick', positionId);
	end
	if WatchADNetworkTips(OnReqWatchADRSConnectLost, positionId) then
		OnReqWatchADRSConnectLost(positionId);
	else
		RSConnectLostFrameConfirmBtn_OnClick();
	end
end

-- 获取当前UI的上下文
function GetUIContextOfMessageBox()
    return {
        t_storeMsgType = t_storeMsgType,
    }
end 



------------------------------------------------------------------messagebox2----------------------------------------------
--[[
messagebox2 有标题栏版本
]]
MessageBoxFrame2 = {
	UIType = {
		-- 左蓝保存存档 右黄实名认证
		{
			lBtnText = GetS(100253), rBtnText = GetS(4986)
		},
		-- 左蓝取消 右黄确认
		{
			lBtnText = GetS(7302), rBtnText = GetS(13049),closeHide = true
		},
		-- 中间黄实名认证
		{
			cBtnText = GetS(4986)
		},
		-- 浇水提醒弹窗（左蓝下次吧，右黄通知到QQ）
		{
			lBtnText = GetS(7302), rBtnText = GetS(13049),
			rIconFile="ui/mobile/texture0/common_icon.xml", rIconName = "icon_qq_black.png",
			rBtnTextOffsetX = 16, rBtnTextOffsetY = 0
		},
		--中间确定
		{
			cBtnText = GetS(13049)
		},
		--中间确定, 隐藏关闭按钮
		{
			cBtnText = GetS(13049), closeHide = true
		},
		{
			lBtnText = GetS(7302), rBtnText = "更换房间",closeHide = true
		},
		--中间确定
		{
			cBtnText = GetS(111400)
		},
	},

	CallBack = nil,
}

-- typeID  8:信用分类型
function MessageBoxFrame2:Open(typeID, titleName, centerText, callback)
	if type(typeID) ~= "number" or typeID > #MessageBoxFrame2.UIType then 
		return
	end

	local msgBoxFrameObj = getglobal("MessageBoxFrame2")
	local msgBoxLBtnObj = getglobal("MessageBoxFrame2LeftBtn")
	local msgBoxLBtnNameObj = getglobal("MessageBoxFrame2LeftBtnName")
	local msgBoxRBtnObj = getglobal("MessageBoxFrame2RightBtn")
	local msgBoxRBtnNameObj = getglobal("MessageBoxFrame2RightBtnName")
	local msgBoxCBtnObj = getglobal("MessageBoxFrame2CenterBtn")
	local msgBoxCBtnNameObj = getglobal("MessageBoxFrame2CenterBtnName")
	local closeBtnObj = getglobal("MessageBoxFrame2CloseBtn")
	local msgBoxTitleNameObj = getglobal("MessageBoxFrame2TitleName")
	local centerTextObj = getglobal("MessageBoxFrame2Desc")
	local msgBoxRBtnIcon = getglobal("MessageBoxFrame2RightBtnIcon") --右边按钮icon

	local typeData = MessageBoxFrame2.UIType[typeID]
	if not typeData then
		return
	end

	if titleName then
		msgBoxTitleNameObj:SetText(titleName)
	end

	if centerText then
		centerTextObj:SetText(centerText, 555, 54, 49)
	end

	if not typeData.closeHide then
		closeBtnObj:Show()
	else
		closeBtnObj:Hide()
	end

	if typeData.lBtnText then
		msgBoxLBtnNameObj:SetText(typeData.lBtnText)
	end

	if typeData.rBtnText then
		msgBoxRBtnNameObj:SetText(typeData.rBtnText)
	end

	if typeData.rIconFile then
		msgBoxRBtnIcon:Show();
		msgBoxRBtnIcon:SetTextureHuiresXml(typeData.rIconFile);
		msgBoxRBtnIcon:SetTexUV(typeData.rIconName);
	else
		msgBoxRBtnIcon:Hide();
	end

	if typeData.rBtnTextOffsetX then
		msgBoxRBtnNameObj:SetAnchorOffset(typeData.rBtnTextOffsetX, typeData.rBtnTextOffsetY);
	else
		msgBoxRBtnNameObj:SetAnchorOffset(0, 0);
	end

	if typeData.cBtnText then
		msgBoxLBtnObj:Hide()
		msgBoxRBtnObj:Hide() 
		msgBoxCBtnObj:Show()
		msgBoxCBtnNameObj:SetText(typeData.cBtnText)
	else
		msgBoxLBtnObj:Show()
		msgBoxRBtnObj:Show() 
		msgBoxCBtnObj:Hide()
	end 

	if callback then
		MessageBoxFrame2.CallBack = callback
	else
		MessageBoxFrame2.CallBack = nil
	end

	-- 游戏内弹窗查询信用分栏目
	if typeID == 8 then
		msgBoxCBtnObj:SetSize(230,61)
	end

	msgBoxFrameObj:Show()
end

function MessageBoxFrame2LeftBtn_OnClick()
	local msgBoxFrameObj = getglobal("MessageBoxFrame2")
	msgBoxFrameObj:Hide()

	if MessageBoxFrame2.CallBack then
		MessageBoxFrame2.CallBack("left")
	end
end

function MessageBoxFrame2RightBtn_OnClick()
	local msgBoxFrameObj = getglobal("MessageBoxFrame2")
	msgBoxFrameObj:Hide()

	if MessageBoxFrame2.CallBack then
		MessageBoxFrame2.CallBack("right")
	end
end

function MessageBoxFrame2CenterBtn_OnClick()
	local msgBoxFrameObj = getglobal("MessageBoxFrame2")
	msgBoxFrameObj:Hide()

	if MessageBoxFrame2.CallBack then
		MessageBoxFrame2.CallBack("left")
	end
end

function MessageBoxFrame2_OnHide()
	if ClientCurGame and ClientCurGame:isInGame() then
		if not getglobal("MessageBoxFrame"):IsRehide() then
			ClientCurGame:setOperateUI(false);
		end
	end
end

function MessageBoxFrame2_OnShow()
	if ClientCurGame and ClientCurGame:isInGame() then
		if not getglobal("MessageBoxFrame"):IsReshow() then
			ClientCurGame:setOperateUI(true);
		end
	end
end



----------------------------------------------GetMoreExpMsgBox----------------------------------------------
local GetMoreExpMsgBox_Cmd = nil
function GetMoreExpMsgBox(cmd)
	local leftNameId = 3028
	local rightNameId = 30122

	GetMoreExpMsgBox_Cmd = cmd

	local title = cmd.title
	local note = cmd.note

	local frame = getglobal("GetMoreExpMsgBoxFrame")
	local frameText = getglobal("GetMoreExpMsgBoxFrameText")
	local frameTitle = getglobal("GetMoreExpMsgBoxFrameHeadTitle")
	local frameTitle2 = getglobal("GetMoreExpMsgBoxFrameHeadTitle2")
								
	local switchBtn = getglobal("GetMoreExpMsgBoxFrameHeadSwitchBtn")
	local checkImg = getglobal("GetMoreExpMsgBoxFrameHeadSwitchBtnCheck")
	checkImg:Hide()

	frame:SetClientString("")
	frameText:clearHistory()

	frameTitle:SetText(title)
	frameTitle2:SetText("")

	frameText:SetText(note, 55, 54, 47);

	getglobal("GetMoreExpMsgBoxFrameCenterBtn"):Hide();
	getglobal("GetMoreExpMsgBoxFrameLeftBtn"):Show();
	getglobal("GetMoreExpMsgBoxFrameRightBtn"):Show();

	getglobal("GetMoreExpMsgBoxFrameLeftBtnName"):SetText(GetS(leftNameId))
	local rightBtnName1 = getglobal("GetMoreExpMsgBoxFrameRightBtnName1")
	local rightBtnName2 = getglobal("GetMoreExpMsgBoxFrameRightBtnName2")
	local rightBtnIcon = getglobal("GetMoreExpMsgBoxFrameRightBtnIcon")

	rightBtnName1:Show();
	rightBtnName1:SetText(GetS(rightNameId));
	rightBtnName2:Hide();
	rightBtnIcon:Hide();

	if isEducationalVersion then
		getglobal("GetMoreExpMsgBoxFrameRightBtn"):Hide();
	end
	
	frame:Show()
end

function GetMoreExpMsgBoxFrameLeftBtn_OnClick()
	getglobal("GetMoreExpMsgBoxFrame"):Hide()
	local callback = GetMoreExpMsgBox_Cmd.callback
	GetMoreExpMsgBox_Cmd = nil
	if callback then
		callback('left')
	end
end

function GetMoreExpMsgBoxFrameRightBtn_OnClick()
	if GetMoreExpMsgBox_Cmd ~= nil and getglobal("GetMoreExpMsgBoxFrame"):GetClientString() == "" then
		getglobal("GetMoreExpMsgBoxFrame"):Hide()
		local callback = GetMoreExpMsgBox_Cmd.callback
		GetMoreExpMsgBox_Cmd = nil
		if callback then
			callback('right')
		end
	else
		getglobal("GetMoreExpMsgBoxFrame"):Hide()
	end
end

function GetMoreExpMsgBoxFrameCloseBtn_OnClick()
	local callback = GetMoreExpMsgBox_Cmd.callback
	GetMoreExpMsgBox_Cmd = nil
	if callback then
		callback('left')
	end
	getglobal("GetMoreExpMsgBoxFrame"):Hide()
end

function GetMoreExpMsgBoxFrame_OnHide()

end

function GetMoreExpMsgBoxFrame_TickOnClick()
	local switchBtn = getglobal("GetMoreExpMsgBoxFrameHeadSwitchBtn")
	if switchBtn then
		local checkImg = getglobal("GetMoreExpMsgBoxFrameHeadSwitchBtnCheck")
		local bShow = checkImg:IsShown()
		if bShow then
			checkImg:Hide()
			bShow = false
		else
			checkImg:Show()
			bShow = true
		end
		if GetMoreExpMsgBox_Cmd and GetMoreExpMsgBox_Cmd.checkBoxCallBack then
			GetMoreExpMsgBox_Cmd.checkBoxCallBack(bShow)
		end
	end
end
------------------------------------------------------------------------------------------------------------

----------------------------------------------StrengthNotEnoughMsgBox----------------------------------------------
local StrengthNotEnoughMsgBox_Cmd = nil
function StrengthNotEnoughMsgBox(cmd)
	-- local leftNameId = 3028
	local rightNameId = 3536

	StrengthNotEnoughMsgBox_Cmd = cmd

	local title = cmd.title
	local note = cmd.note
	local btnString = cmd.btnString

	local frame = getglobal("StrengthNotEnoughMsgBoxFrame")
	local frameText = getglobal("StrengthNotEnoughMsgBoxFrameText")
	local frameTitle = getglobal("StrengthNotEnoughMsgBoxFrameHeadTitle")
	local frameTitle2 = getglobal("StrengthNotEnoughMsgBoxFrameHeadTitle2")
								
	frame:SetClientString("")
	frameText:clearHistory()

	frameTitle:SetText(title)
	frameTitle2:SetText("")

	frameText:SetText(note, 55, 54, 47);

	getglobal("StrengthNotEnoughMsgBoxFrameCenterBtn"):Hide();
	getglobal("StrengthNotEnoughMsgBoxFrameLeftBtn"):Show();
	getglobal("StrengthNotEnoughMsgBoxFrameRightBtn"):Show();

	getglobal("StrengthNotEnoughMsgBoxFrameLeftBtnName"):SetText(btnString)
	local rightBtnName1 = getglobal("StrengthNotEnoughMsgBoxFrameRightBtnName1")
	local rightBtnName2 = getglobal("StrengthNotEnoughMsgBoxFrameRightBtnName2")
	local rightBtnIcon = getglobal("StrengthNotEnoughMsgBoxFrameRightBtnIcon")

	rightBtnName1:Show();
	rightBtnName1:SetText(GetS(3536));
	rightBtnName2:Hide();
	rightBtnIcon:Hide();

	if isEducationalVersion then
		getglobal("StrengthNotEnoughMsgBoxFrameRightBtn"):Hide();
	end
	
	frame:Show()
end

function StrengthNotEnoughMsgBoxFrameLeftBtn_OnClick()
	getglobal("StrengthNotEnoughMsgBoxFrame"):Hide()
	local callback = StrengthNotEnoughMsgBox_Cmd.callback
	StrengthNotEnoughMsgBox_Cmd = nil
	if callback then
		callback('left')
	end
end

function StrengthNotEnoughMsgBoxFrameRightBtn_OnClick()
	if StrengthNotEnoughMsgBox_Cmd ~= nil and getglobal("StrengthNotEnoughMsgBoxFrame"):GetClientString() == "" then
		getglobal("StrengthNotEnoughMsgBoxFrame"):Hide()
		local callback = StrengthNotEnoughMsgBox_Cmd.callback
		StrengthNotEnoughMsgBox_Cmd = nil
		if callback then
			callback('right')
		end
	else
		getglobal("StrengthNotEnoughMsgBoxFrame"):Hide()
	end
end

function StrengthNotEnoughMsgBoxFrameCloseBtn_OnClick()
	local callback = StrengthNotEnoughMsgBox_Cmd.callback
	StrengthNotEnoughMsgBox_Cmd = nil
	if callback then
		callback('right')
	end
	getglobal("StrengthNotEnoughMsgBoxFrame"):Hide()
end

function StrengthNotEnoughMsgBoxFrame_OnHide()

end
------------------------------------------------------------------------------------------------------------