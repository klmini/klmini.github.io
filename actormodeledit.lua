
local getglobal = _G.getglobal;
ActorEditMgr = {
    m_funcGetglobal = getglobal,

    boneNumMax = 16,  --骨骼点最大数目
    avatarBindBoneMax = 80, --一个骨骼点能绑定的最大avatar数目
    avatarBindSumMax = 80, --一个模型能绑定的最大avatar数目

    motionMax = 8, --最大的动作数目

    curOperateBtnName = "", --当前操作的按钮
    curSelectBoneIdx = 0, --当前选中的骨骼下标
    curSelectAvatarIdx = 0, --当前选中的微雕模型下标
    curSelectOpetateType = "add", --add 增加绑定的模型 refresh 刷新绑定的模型

    curSelectMotionIdx = 0, --当前选中的动作

    t_actorModelData = {},  --模型数据

    t_MapModelClass = {}, --地图库微雕模型数据
    t_ResModelClass = {}, --资源库微雕模型数据
    curSelectTapsIndex = 0, --当前选中的微雕模型列表类型下标
    curActorEditSelModelUIName = nil;  --当前选中的微雕模型的格子控件名
    curYawAngle = 0,
    curPitchAngle = 0,
    curCameraX = 0,
    curCameraY = 0,
    curCameraZ = 0,
    cuRotateDir = "",   --当前模型旋转的方向
    VIEW_RADIUS = 5000,  --视图半径

    subModelSkinDisplay = true; --子模型是否显示

    ViewTypeENUM = {FREE_VIEW = 1, END_VIEW = 2, FRONT_VIEW = 3, VERTICAL_VIEW=4},
    curViewType,
    curModelScale = 0.7;

    CloseTypeENUM = {NO_CLOSE = -2, NORMAL_CLOSE = -1, EDIE_CLOSE = 0, SAVE_CLOSE = 1},
    curCloseType,

    editableActorModelMax = 144,  --可导入编辑的生物模型最大数目
    t_EditableActorModel = {}, --可编辑的生物模型
    curSelEditableType = "map", --当前选择的可编辑的生物模型类型 map地图库了的 res资源库里的
    curSelEditableModelIdx = 0, 

    curEditModelTemplateType = HUMAN_MODEL,
    curEditModelType = HUMAN_MODEL,
    symmetryOperate = false, 

    curCoordType = 0,   --1位置 2旋转 3缩放
    modelViewUI = nil;

    --初始化数据
    Init = function(self)
		local getglobal = self.m_funcGetglobal;
        if self.curOperateBtnName and self.curOperateBtnName ~= "" then
            getglobal(self.curOperateBtnName.."Check"):Hide();
        end
        if self.curSelectBoneIdx ~= 0 then
            getglobal("ActorEditFramePartFrameBoneBoxBone"..self.curSelectBoneIdx.."Check"):Hide();
            getglobal("ActorEditFramePartFrameBoneBoxBone"..self.curSelectBoneIdx.."Name"):SetTextColor(55,54,48);
        end
        if self.curSelectAvatarIdx > 0 then
            getglobal("ActorEditFramePartFrameAvatarBoxAvatar"..self.curSelectAvatarIdx.."Check"):Hide();
        end

        if self.curSelectMotionIdx ~= 0 then
            getglobal("ActorEditFrameMotionFrameBoxMotion"..self.curSelectMotionIdx.."Check"):Hide();
            getglobal("ActorEditFrameMotionFrameBoxMotion"..self.curSelectMotionIdx.."Name"):SetTextColor(55,54,48);
            getglobal("ActorEditFrameMotionFrameBoxMotion"..self.curSelectMotionIdx.."ID"):SetTextColor(55,54,48);
        end

        self.modelViewUI = getglobal("ActorEditFrameModelView");

        self.curOperateBtnName = "";
        self.curSelectBoneIdx = 0;
        self.curSelectAvatarIdx = 0;
        self.curSelectOpetateType = "add";
        self.curSelectMotionIdx = 0;
        self.curYawAngle = 0;
        self.curPitchAngle = 0;
        self.curCameraX = 0;
        self.curCameraY = 0;
        self.curCameraZ = 0;
        self.cuRotateDir = "";
        self.curViewType = self.ViewTypeENUM.FREE_VIEW;
        self.curModelScale = 0.7;
        self.curCloseType = self.CloseTypeENUM.NORMAL_CLOSE;
        self.curCoordType = 0;

        if self.curActorEditSelModelUIName then
            getglobal(self.curActorEditSelModelUIName.."Check"):Hide();
        end
        self.curActorEditSelModelUIName = nil;

        getglobal("ActorEditFrameOperateFrame"):Hide();
        getglobal("ActorEditFramePosBtn"):Hide();
        getglobal("ActorEditFrameRotateBtn"):Hide();
        getglobal("ActorEditFrameScaleBtn"):Hide();

        getglobal("ActorEditFramePartBtnCheck"):Hide();
        getglobal("ActorEditFrameMotionBtnCheck"):Hide();
        getglobal("ActorEditFramePartFrame"):Hide();
        getglobal("ActorEditFrameMotionFrame"):Hide();

        getglobal("ActorEditFramePartFrameDelBtn"):Disable();
        getglobal("ActorEditFramePartFrameDelBtnNormal"):SetGray(true);
        getglobal("ActorEditFramePartFrameDelBtnNormal"):SetBlendAlpha(0.5);
        getglobal("ActorEditFramePartFrameRefreshBtn"):Disable();
        getglobal("ActorEditFramePartFrameRefreshBtnNormal"):SetGray(true);
        getglobal("ActorEditFramePartFrameRefreshBtnNormal"):SetBlendAlpha(0.5);

        getglobal("ActorEditFrameViewBtnIcon"):SetTexUV("ico_model_free");

        self:InitActorModelData();

        self:LoadModelClass();

        self.subModelSkinDisplay = CustomModelMgr:getCurEditActorSkinDisplay();
        if self.subModelSkinDisplay then
            getglobal("ActorEditFrameSubModelDisPlayBtnIcon"):SetTexUV("ico_model_xianshi");
        else
            getglobal("ActorEditFrameSubModelDisPlayBtnIcon"):SetTexUV("ico_model_yincang");
        end

        self.symmetryOperate = false;
        getglobal("ActorEditFrameOperateFrameSymmetryBtnTick"):Hide();

        if self.curEditModelType == QUADRUPED_MODEL then
            local modelView = getglobal("ActorEditFrameModelView");
            local angleX = -45;
            modelView:setCameraAngle(angleX, 0, 0);

            local r = self.VIEW_RADIUS; --半径
            local tmpR = math.cos(math.rad(0))*r;
            local z = math.cos(math.rad(angleX))*tmpR;
            local x = math.sin(math.rad(angleX))*tmpR

            modelView:setCameraPosition(-x, 1000, -z);
        end
    end,

    --初始化模型数据
    InitActorModelData = function(self)
        self.curEditModelType = CustomModelMgr:getCurEditActorModelType();
        if self.curEditModelType == SINGLE_BONE_MODEL then
            self.avatarBindBoneMax = 80;
        else
            self.avatarBindBoneMax = 30;
            for i=31, 80 do
                local avatarUI = getglobal("ActorEditFramePartFrameAvatarBoxAvatar"..i);
                avatarUI:Hide();
            end
        end
        
        if self.curEditModelType == SINGLE_BONE_MODEL then
            self.t_actorModelData = {
                {boneName = "Body1", data = {}, nameStr=GetS(12507)},
            }
        else
            self.t_actorModelData = {
            {boneName = "Head", data = {}, nameStr=GetS(12506)},
            {boneName = "Body1", data = {}, nameStr=GetS(12507)..1},
            {boneName = "Body2", data = {}, nameStr=GetS(12507)..2},
            {boneName = "Body3", data = {}, nameStr=GetS(12507)..3},
            {boneName = "Arm_left1", data = {}, nameStr=GetS(12509)..1},
            {boneName = "Arm_left2", data = {}, nameStr=GetS(12509)..2},
            {boneName = "Arm_left3", data = {}, nameStr=GetS(12509)..3},
            {boneName = "Arm_right1", data = {}, nameStr=GetS(12508)..1},
            {boneName = "Arm_right2", data = {}, nameStr=GetS(12508)..2},
            {boneName = "Arm_right3", data = {}, nameStr=GetS(12508)..3},
            {boneName = "Leg_left1", data = {}, nameStr=GetS(12511)..1},
            {boneName = "Leg_left2", data = {}, nameStr=GetS(12511)..2},
            {boneName = "Leg_left3", data = {}, nameStr=GetS(12511)..3},
            {boneName = "Leg_right1", data = {}, nameStr=GetS(12510)..1},
            {boneName = "Leg_right2", data = {}, nameStr=GetS(12510)..2},
            {boneName = "Leg_right3", data = {}, nameStr=GetS(12510)..3},
        }
        end

        for i=1, ActorEditMgr.boneNumMax do
            local boneUI = getglobal("ActorEditFramePartFrameBoneBoxBone"..i);
            local nameUI = getglobal("ActorEditFramePartFrameBoneBoxBone"..i.."Name");

            if i <= #(self.t_actorModelData) then
                boneUI:Show();
                nameUI:SetText(self.t_actorModelData[i].nameStr);

                for j=1, self.avatarBindBoneMax do
                    local data = CustomModelMgr:getCustomAvatarModelData(self.t_actorModelData[i].boneName, j-1);
                    if data == nil then
                        break;
                    end

                    local t = {modelfilename=data.modelfilename, scale=data.scale, yaw=data.yaw, pitch=data.pitch, roll=data.roll, x=data.offset_x, y=data.offset_y, z=data.offset_z};
                    table.insert(self.t_actorModelData[i].data, t);
                end
            else
                boneUI:Hide();
            end
        end

        print("kekeke t_actorModelData", t_actorModelData);
    end,

    --加载微雕模型库数据
    LoadModelClass = function(self)
        self.t_MapModelClass = {};
        self.t_ResModelClass = {};
        local num = ResourceCenter:getResClassNum(MAP_LIB);
        for i=1, num do
            local classInfo = ResourceCenter:getClassInfo(PUBLIC_LIB, i-1);
            if classInfo then
                local t = GetOneClassAllModel(RES_MODEL_CLASS, classInfo, {[BLOCK_MODEL]=true, [WEAPON_MODEL]=true, [GUN_MODEL]=true, [PROJECTILE_MODEL]=true, [BOW_MODEL]=true});
                table.insert(self.t_ResModelClass, {classname=classInfo.classname, info=t});
            end
        end

        num = ResourceCenter:getResClassNum(MAP_LIB);
        for i=1, num do
            local classInfo = ResourceCenter:getClassInfo(MAP_LIB, i-1);
            if classInfo then
                local t = GetOneClassAllModel(MAP_MODEL_CLASS, classInfo, {[BLOCK_MODEL]=true, [WEAPON_MODEL]=true, [GUN_MODEL]=true, [PROJECTILE_MODEL]=true, [BOW_MODEL]=true});
                table.insert(self.t_MapModelClass, {classname=classInfo.classname, info=t});
            end
        end

        print("kekeke t_MapModelClass", self.t_MapModelClass);
        print("kekeke t_ResModelClass", self.t_ResModelClass);
    end,

    --刷新生物编辑操作面板
    UpdateActorEditOperateFrame = function(self, btnName, isforce)
        print("kekeke UpdateActorEditOperateFrame btnName", btnName, type(btnName))
        if not isforce and self.curOperateBtnName == btnName then
            return ;
        end

        if string.find(self.curOperateBtnName, "PosBtn") then
            getglobal("ActorEditFramePosBtnCheck"):Hide();
        elseif string.find(self.curOperateBtnName, "RotateBtn") then
            getglobal("ActorEditFrameRotateBtnCheck"):Hide();
        elseif string.find(self.curOperateBtnName, "ScaleBtn") then
            getglobal("ActorEditFrameScaleBtnCheck"):Hide();
        end

        local barUI = getglobal("ActorEditFrameOperateFrameSlider3Bar");
        local nameUI = getglobal("ActorEditFrameOperateFrameSlider3Name");
        local valUI = getglobal("ActorEditFrameOperateFrameSlider3Val");
        if string.find(btnName, "PosBtn") then  --调整位置
            getglobal("ActorEditFrameOperateFrameBkg"):SetSize(382, 196);
            getglobal("ActorEditFrameOperateFrameSlider1"):Show();
            getglobal("ActorEditFrameOperateFrameSlider2"):Show();
            getglobal("ActorEditFrameOperateFrameSlider3"):Show();

            getglobal("ActorEditFramePosBtnCheck"):Show();
            local data = self.t_actorModelData[self.curSelectBoneIdx].data[self.curSelectAvatarIdx];
            if data then
                barUI:SetMinValue(-100);
                barUI:SetMaxValue(100);
                barUI:SetValueStep(1);
                barUI:SetValue(data.z);
                nameUI:SetText("Z");
                valUI:SetText(math.floor(data.z));

                barUI = getglobal("ActorEditFrameOperateFrameSlider2Bar");
                nameUI = getglobal("ActorEditFrameOperateFrameSlider2Name");
                valUI = getglobal("ActorEditFrameOperateFrameSlider2Val");

                barUI:SetMinValue(-100);
                barUI:SetMaxValue(100);
                barUI:SetValueStep(1);
                barUI:SetValue(data.x);
                nameUI:SetText("Y");
                valUI:SetText(math.floor(data.x));

                barUI = getglobal("ActorEditFrameOperateFrameSlider1Bar");
                nameUI = getglobal("ActorEditFrameOperateFrameSlider1Name");
                valUI = getglobal("ActorEditFrameOperateFrameSlider1Val");

                barUI:SetMinValue(-100);
                barUI:SetMaxValue(100);
                barUI:SetValueStep(1);
                barUI:SetValue(data.y);
                nameUI:SetText("X");
                valUI:SetText(math.floor(data.y));
            end

            self.curCoordType = 1;
            getglobal("ActorEditFrameModelView"):setCoordType(self.curCoordType);
        elseif string.find(btnName, "RotateBtn") then --调整方向
            getglobal("ActorEditFrameOperateFrameBkg"):SetSize(382, 196);
            getglobal("ActorEditFrameOperateFrameSlider1"):Show();
            getglobal("ActorEditFrameOperateFrameSlider2"):Show();
            getglobal("ActorEditFrameOperateFrameSlider3"):Show();

            getglobal("ActorEditFrameRotateBtnCheck"):Show();

            local data = self.t_actorModelData[self.curSelectBoneIdx].data[self.curSelectAvatarIdx];
            if data then
                barUI:SetMinValue(-180);
                barUI:SetMaxValue(180);
                barUI:SetValueStep(1);
                barUI:SetValue(data.pitch);
                nameUI:SetText("P");
                valUI:SetText(math.floor(data.pitch));
                --valUI:SetText(data.pitch);

                barUI = getglobal("ActorEditFrameOperateFrameSlider2Bar");
                nameUI = getglobal("ActorEditFrameOperateFrameSlider2Name");
                valUI = getglobal("ActorEditFrameOperateFrameSlider2Val");

                barUI:SetMinValue(-180);
                barUI:SetMaxValue(180);
                barUI:SetValueStep(1);
                barUI:SetValue(data.yaw);
                nameUI:SetText("Y");
                valUI:SetText(math.floor(data.yaw));
                --valUI:SetText(data.yaw);

                barUI = getglobal("ActorEditFrameOperateFrameSlider1Bar");
                nameUI = getglobal("ActorEditFrameOperateFrameSlider1Name");
                valUI = getglobal("ActorEditFrameOperateFrameSlider1Val");

                barUI:SetMinValue(-180);
                barUI:SetMaxValue(180);
                barUI:SetValueStep(1);
                barUI:SetValue(data.roll);
                nameUI:SetText("R");
                valUI:SetText(math.floor(data.roll));
                --valUI:SetText(data.roll);
            end

            self.curCoordType = 2;
            getglobal("ActorEditFrameModelView"):setCoordType(self.curCoordType);
        elseif string.find(btnName, "ScaleBtn") then --调整大小
            getglobal("ActorEditFrameOperateFrameBkg"):SetSize(382, 94);
            getglobal("ActorEditFrameOperateFrameSlider1"):Hide();
            getglobal("ActorEditFrameOperateFrameSlider2"):Hide();
            getglobal("ActorEditFrameOperateFrameSlider3"):Show();

            getglobal("ActorEditFrameScaleBtnCheck"):Show();

            local data = self.t_actorModelData[self.curSelectBoneIdx].data[self.curSelectAvatarIdx];
            if data then
                barUI:SetMinValue(0.1);
                barUI:SetMaxValue(2);
                barUI:SetValueStep(0.1);
                barUI:SetValue(data.scale);
                nameUI:SetText("S");
                valUI:SetText(string.format("%.1f", data.scale));
            end

            self.curCoordType = 3;
            getglobal("ActorEditFrameModelView"):setCoordType(self.curCoordType);
        end

        self.curOperateBtnName = btnName;
        if not getglobal("ActorEditFrameOperateFrame"):IsShown() then
            getglobal("ActorEditFrameOperateFrame"):Show();
        end
    end,

    --获取部件总数
    GetEditModelAvatarSum = function(self)
        local sum = 0;
        for i=1, #(self.t_actorModelData) do
            sum = sum + #(self.t_actorModelData[i].data);
        end

        return sum;
    end,

    --刷新生物编辑部件面板
    UpdateActorEditPartFrame = function(self, boneIdx, forceUpdate)
        local getglobal = self.m_funcGetglobal;
        if not forceUpdate and self.curSelectBoneIdx == boneIdx then
            return;
        end

        if self.curSelectBoneIdx ~= 0 then
            getglobal("ActorEditFramePartFrameBoneBoxBone"..self.curSelectBoneIdx.."Check"):Hide();
            getglobal("ActorEditFramePartFrameBoneBoxBone"..self.curSelectBoneIdx.."Name"):SetTextColor(55,54,48);
            CustomModelMgr:setCurEditActorOverlayColor(self.t_actorModelData[self.curSelectBoneIdx].boneName, false);
        end

        local effectName = nil;
        if self.t_actorModelData[self.curSelectBoneIdx] then
            effectName = string.lower(self.t_actorModelData[self.curSelectBoneIdx].boneName);
        end
        if effectName then
            getglobal("ActorEditFrameModelView"):stopEffect(effectName, 0);
        end

        self.curSelectBoneIdx = boneIdx;
        CustomModelMgr:setCurEditActorOverlayColor(self.t_actorModelData[self.curSelectBoneIdx].boneName, true);

        if self.t_actorModelData[self.curSelectBoneIdx] then
            effectName = string.lower(self.t_actorModelData[self.curSelectBoneIdx].boneName);
        end
        if effectName then
            getglobal("ActorEditFrameModelView"):playEffect(effectName, 0);
        end

        getglobal("ActorEditFramePartFrameBoneBoxBone"..boneIdx.."Check"):Show();
        getglobal("ActorEditFramePartFrameBoneBoxBone"..boneIdx.."Name"):SetTextColor(55,54,49);

        local num = #(self.t_actorModelData[boneIdx].data);
        for i=1, self.avatarBindBoneMax do
            local avatarUI = getglobal("ActorEditFramePartFrameAvatarBoxAvatar"..i);
            if i <= num then
                avatarUI:Show();
                local icon = getglobal("ActorEditFramePartFrameAvatarBoxAvatar"..i.."Icon");
                SetModelIcon(icon, self.t_actorModelData[boneIdx].data[i].modelfilename, -1);
            else
                avatarUI:Hide();
            end
        end

        if num <= 5 then
            getglobal("ActorEditFramePartFrameAvatarBoxPlane"):SetSize(237, 440);
        else
            local row = math.ceil((num+1)/2);
            getglobal("ActorEditFramePartFrameAvatarBoxPlane"):SetSize(237, 127*row);
        end

        if num >= self.avatarBindBoneMax then
            getglobal("ActorEditFramePartFrameAvatarBoxAddBtn"):Hide();
        else
            getglobal("ActorEditFramePartFrameAvatarBoxAddBtn"):Show();
            local row = math.ceil((num+1)/2);
            local col = (num+1) - (row-1)*2;
            getglobal("ActorEditFramePartFrameAvatarBoxAddBtn"):SetPoint("topleft", "ActorEditFramePartFrameAvatarBoxPlane", "topleft", 8 + (col-1)*110, (row-1)*127);
        end  

        local text = GetS(12533);
        local sum = self:GetEditModelAvatarSum();
        if sum >= self.avatarBindSumMax then
            text = text..":".."#cfa1e1e"..sum.."#n/"..self.avatarBindSumMax;
        else
            text = text..":".."#c46c80a"..sum.."#n/"..self.avatarBindSumMax;
        end
        getglobal("ActorEditFrameAvatarNum"):SetText(text);

        local t_bone = self.t_actorModelData[self.curSelectBoneIdx];
        if t_bone and self.t_avatarRelevance[self.curEditModelType] and self.t_avatarRelevance[self.curEditModelType][t_bone.boneName] then
            getglobal("ActorEditFrameOperateFrameSymmetryBtn"):Show();
        else
            getglobal("ActorEditFrameOperateFrameSymmetryBtn"):Hide();
        end
    end,

    --刷新生物编辑动作面板
    UpdateActorEditMotionFrame = function(self, motionIdx)
        print("kekeke UpdateActorEditMotionFrame motionIdx", motionIdx)
        --[[
        if self.curSelectMotionIdx == motionIdx then
            return;
        end
        ]]

		local getglobal = self.m_funcGetglobal;
        local tmpIdx = self.curSelectMotionIdx;
        if self.curSelectMotionIdx ~= 0 then
            getglobal("ActorEditFrameMotionFrameBoxMotion"..self.curSelectMotionIdx.."Check"):Hide();
            getglobal("ActorEditFrameMotionFrameBoxMotion"..self.curSelectMotionIdx.."Name"):SetTextColor(55,54,48);
            getglobal("ActorEditFrameMotionFrameBoxMotion"..self.curSelectMotionIdx.."ID"):SetTextColor(55,54,48);
        end

        self.curSelectMotionIdx = motionIdx;

        local actorBody = CustomModelMgr:getActorBody();
        if actorBody then
            if tmpIdx > 0 then
                local oldId = getglobal("ActorEditFrameMotionFrameBoxMotion"..tmpIdx):GetClientID();
                actorBody:stopAnimBySeqId(oldId);
            end
            if motionIdx > 0 then
                getglobal("ActorEditFrameMotionFrameBoxMotion"..motionIdx.."Check"):Show();
                getglobal("ActorEditFrameMotionFrameBoxMotion"..motionIdx.."Name"):SetTextColor(55,54,49);
                getglobal("ActorEditFrameMotionFrameBoxMotion"..motionIdx.."ID"):SetTextColor(55,54,48);
                local motionId = getglobal("ActorEditFrameMotionFrameBoxMotion"..motionIdx):GetClientID();
                actorBody:playAnimBySeqId(motionId);
            end
        end
    end,

    --刷新生物编辑选择模型面板
    UpdateActorEditSelectModelFrame = function(self, tabIndex, operateType)
        for i=1, 2 do
            if tabIndex == i then
                getglobal("ActorEditSelectModelFrameTabs"..i.."Normal"):Hide();
                getglobal("ActorEditSelectModelFrameTabs"..i.."Checked"):Show();
                getglobal("ActorEditSelectModelFrameTabs"..i.."Name"):SetTextColor(55, 54, 49);
            else
                getglobal("ActorEditSelectModelFrameTabs"..i.."Normal"):Show();
                getglobal("ActorEditSelectModelFrameTabs"..i.."Checked"):Hide();
                getglobal("ActorEditSelectModelFrameTabs"..i.."Name"):SetTextColor(55, 54, 49);
            end
        end

        self.curSelectTapsIndex = tabIndex;
        self.curSelectOpetateType = operateType;
        self:UpdateActorEditSelectModelBox(tabIndex);

        if not getglobal("ActorEditSelectModelFrame"):IsShown() then
            getglobal("ActorEditSelectModelFrame"):Show();
        end
    end,

    --刷新生物编辑选择模型面板的微雕分类面板
    UpdateActorEditSelectModelBox = function(self, tabIndex)
        getglobal("ActorEditSelectModelClassBox"):Show();
        getglobal("ActorEditSelectModelListFrame"):Hide();

        local t = self.t_ResModelClass;
        local classType = RES_MODEL_CLASS;
        if tabIndex == 1 then
            t = self.t_MapModelClass;
        end

        local num = #(t);
        for i=1, num do
            local class = getglobal("ActorEditSelectModelClass"..i);
            class:Show();

            local list = getglobal("ActorEditSelectModelClass"..i.."List");
            local emptyIcon = getglobal("ActorEditSelectModelClass"..i.."EmptyIcon");
            local classNameUI = getglobal("ActorEditSelectModelClass"..i.."Name");

            classNameUI:SetText(GetRealClassName(t[i].classname));

            local num = #(t[i].info);
            if num > 0 then
                list:Show();
                emptyIcon:Hide();
                UpdateOneModelClassList(t[i].info, list, classType, -1);
            else
                list:Hide();
                emptyIcon:Show();
            end
        end

        for i=num+1, 48 do
            local class = getglobal("ActorEditSelectModelClass"..i);
            class:Hide();
        end

        if num <= 4 then
            getglobal("ActorEditSelectModelClassBoxPlane"):SetSize(710, 330);
        else
            local row = math.ceil(num/4);
            getglobal("ActorEditSelectModelClassBoxPlane"):SetSize(710, row*215);
        end
    end,

    --点击生物编辑选择模型面板的某类微雕模型
    ActorEditSelectModelClassClick = function(self, index)
        local t = self.t_ResModelClass;
        if self.curSelectTapsIndex == 1 then
            t = self.t_MapModelClass;
        end
        if t[index] then
            local className = t[index].classname;
            getglobal("ActorEditSelectModelListFrameName"):SetText(GetRealClassName(className));

            --UpdateModelList();
            self:UpdateActorEditSelectModelList(t[index], index);
            getglobal("ActorEditSelectModelClassBox"):Hide();
            if self.curActorEditSelModelUIName then
                getglobal(self.curActorEditSelModelUIName.."Check"):Hide();
            end
            getglobal("ActorEditSelectModelListFrame"):Show();
        end
    end,

    --刷新生物编辑选择模型面板的某类微雕模型列表
    UpdateActorEditSelectModelList = function(self, t_OneClassModelList, index)
        print("kekeke t_OneClassModelList", t_OneClassModelList);
        for i=1, 440 do
            local gridUI = getglobal("ActorEditSelectModelGrid"..i);
            if i <= #(t_OneClassModelList.info) then
                gridUI:Show();

                local icon = getglobal(gridUI:GetName().."Icon");
                SetModelIcon(icon, t_OneClassModelList.info[i].filename, -1);
                if t_OneClassModelList.info[i].canchoose then
                    icon:SetGray(false);
                else
                    icon:SetGray(true);
                end
                gridUI:SetClientString(t_OneClassModelList.info[i].filename);
                gridUI:SetClientUserData(0, index);

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
            getglobal("ActorEditSelectModelListBoxPlane"):SetHeight(270);
        else
            local addline = math.ceil((#(t_OneClassModelList.info)-24) /8);
            local height = addline*92 + 270;
            getglobal("ActorEditSelectModelListBoxPlane"):SetHeight(height);
        end
    end,

    --点击生物编辑选择模型面板的某个微雕模型
    ActorEditSelectModelGridClick = function(self, btnName, fileName, classIndex)
        if self.curActorEditSelModelUIName then
            getglobal(self.curActorEditSelModelUIName.."Check"):Hide();
        end

        self.curActorEditSelModelUIName = btnName;
        getglobal(self.curActorEditSelModelUIName.."Check"):Show();
        local index = getglobal(btnName):GetClientID();

        getglobal('ActorEditSelectModelFrameOkBtn'):SetClientString(fileName);	--ClientString记录了选择的微雕模型的文件名

        local t = self.t_ResModelClass;
        if self.curSelectTapsIndex == 1 then
            t = self.t_MapModelClass;
        end

        if t[classIndex] and t[classIndex].info[index] and t[classIndex].info[index].modelname and t[classIndex].info[index].modelname ~= "" then
            UpdateTipsFrame(t[classIndex].info[index].modelname, 0);
        else
            UpdateTipsFrame(GetS(12537), 0);
        end
    end,

    ActorEditAvatarClick = function(self, index)
        for i=1, self.avatarBindBoneMax do
            getglobal("ActorEditFramePartFrameAvatarBoxAvatar"..i.."Check"):Hide();
        end

        if self.t_actorModelData[self.curSelectBoneIdx] and #(self.t_actorModelData[self.curSelectBoneIdx].data) < index then
            return;
        end

        local oldOperateBtnName = nil;
        if self.curOperateBtnName and self.curOperateBtnName ~= "" then
            getglobal(self.curOperateBtnName.."Check"):Hide();
            oldOperateBtnName = self.curOperateBtnName;
        end
        --self.curOperateBtnName = "";

        local avatarModel = CustomModelMgr:getCustomAvatarModelData(self.t_actorModelData[self.curSelectBoneIdx].boneName, self.curSelectAvatarIdx-1);
        if avatarModel then
            avatarModel:setOverlayColor(false);
            getglobal("ActorEditFrameModelView"):unbindCoordInteract();
        end

        if ActorEditMgr.curSelectAvatarIdx == index then  --取消选中
            getglobal("ActorEditFramePosBtn"):Hide();
            getglobal("ActorEditFrameRotateBtn"):Hide();
            getglobal("ActorEditFrameScaleBtn"):Hide();
            getglobal("ActorEditFrameOperateFrame"):Hide();

            getglobal("ActorEditFramePartFrameDelBtn"):Disable();
            getglobal("ActorEditFramePartFrameDelBtnNormal"):SetGray(true);
            getglobal("ActorEditFramePartFrameDelBtnNormal"):SetBlendAlpha(0.5);
            getglobal("ActorEditFramePartFrameRefreshBtn"):Disable();
            getglobal("ActorEditFramePartFrameRefreshBtnNormal"):SetGray(true);
            getglobal("ActorEditFramePartFrameRefreshBtnNormal"):SetBlendAlpha(0.5);

            ActorEditMgr.curSelectAvatarIdx = 0;
            
        else                                                                --选中
            ActorEditMgr.curSelectAvatarIdx = index;
            getglobal("ActorEditFramePartFrameAvatarBoxAvatar"..self.curSelectAvatarIdx.."Check"):Show();

            getglobal("ActorEditFramePosBtn"):Show();
            getglobal("ActorEditFrameRotateBtn"):Show();
            getglobal("ActorEditFrameScaleBtn"):Show();

            getglobal("ActorEditFramePartFrameDelBtn"):Enable();
            getglobal("ActorEditFramePartFrameDelBtnNormal"):SetGray(false);
            getglobal("ActorEditFramePartFrameDelBtnNormal"):SetBlendAlpha(1);
            getglobal("ActorEditFramePartFrameRefreshBtn"):Enable();
            getglobal("ActorEditFramePartFrameRefreshBtnNormal"):SetGray(false);
            getglobal("ActorEditFramePartFrameRefreshBtnNormal"):SetBlendAlpha(1);

            
            avatarModel = CustomModelMgr:getCustomAvatarModelData(self.t_actorModelData[self.curSelectBoneIdx].boneName, self.curSelectAvatarIdx-1);
            if avatarModel then
                avatarModel:setOverlayColor(true);
                getglobal("ActorEditFrameModelView"):bindCoordInteract(0, self.t_actorModelData[self.curSelectBoneIdx].boneName);
                local data = self.t_actorModelData[self.curSelectBoneIdx].data[self.curSelectAvatarIdx];
                print("kekeke ActorEditFrameModelView data", self.curSelectAvatarIdx, data);
                getglobal("ActorEditFrameModelView"):setPosition(data.x, data.y, data.z);
                getglobal("ActorEditFrameModelView"):setRotationEuler(data.pitch, data.yaw, data.roll);
                getglobal("ActorEditFrameModelView"):setScale(data.scale, data.scale, data.scale);
            end

            if oldOperateBtnName then
                self:UpdateActorEditOperateFrame(oldOperateBtnName, true);
            else
                self:UpdateActorEditOperateFrame("ActorEditFramePosBtn", true);
            end
        end
    end,

    --获取绑定的骨骼默认参数
    getBindDefaultCfg = function(self, fileName, boneName)
        local t = {[HUMAN_MODEL] = "human_"..boneName, [QUADRUPED_MODEL] = "quadruped_"..boneName, [SINGLE_BONE_MODEL] = "single_"..boneName};
        local cfg = edit_actormodel_config[t[self.curEditModelType]];
        if cfg then
            return {modelfilename=fileName, scale=cfg.scale, yaw=cfg.yaw, pitch=cfg.pitch, roll=cfg.roll, x=cfg.offset_y, y=cfg.offset_x, z=cfg.offset_z}
        end

        return nil;
    end,

    --绑定相关联的骨骼
    ActorBindRelevance = function(self, boneName, fileName)
        local t_relbone = self.t_avatarRelevance[self.curEditModelType][boneName];
        for k, v in pairs(t_relbone.boneNames) do
            if #(self.t_actorModelData[k].data) == 0 then
                if CustomModelMgr:bindCustomAvatar(v, fileName) then
                    local t = self:getBindDefaultCfg(fileName, v);
                    if t then
                        table.insert(self.t_actorModelData[k].data, t);
                    end
                end
            end
        end
    end,

    --绑定骨骼模型
    ActorBindModel = function (self, fileName)
        if not self.t_actorModelData[self.curSelectBoneIdx] then
            return;
        end
        getglobal("ActorEditSelectModelFrame"):Hide();

        local t_bone = self.t_actorModelData[self.curSelectBoneIdx];
        if CustomModelMgr:bindCustomAvatar(t_bone.boneName, fileName) then
            local t = self:getBindDefaultCfg(fileName, t_bone.boneName);--{modelfilename=fileName, scale=1, yaw=0, pitch=0, roll=0, x=0, y=0, z=0};
            if t then
                table.insert(t_bone.data, t);
            end

            
            if self.t_avatarRelevance[self.curEditModelType] and self.t_avatarRelevance[self.curEditModelType][t_bone.boneName] then
                self:ActorBindRelevance(t_bone.boneName, fileName);
            end
            self:UpdateActorEditPartFrame(self.curSelectBoneIdx, true);
            self:ActorEditAvatarClick(#(self.t_actorModelData[self.curSelectBoneIdx].data));
        end
    end,

    --解绑骨骼模型
    DelBindModel = function(self)
        if not self.t_actorModelData[self.curSelectBoneIdx] then
            return;
        end

        if not self.t_actorModelData[self.curSelectBoneIdx].data[ActorEditMgr.curSelectAvatarIdx] then
            return;
        end

        local t = self.t_actorModelData[self.curSelectBoneIdx];
        if CustomModelMgr:delCustomAvatar(t.boneName, ActorEditMgr.curSelectAvatarIdx-1) then
            local selIdx = ActorEditMgr.curSelectAvatarIdx;
            self:ActorEditAvatarClick(selIdx);
            table.remove(t.data, selIdx);
            self:UpdateActorEditPartFrame(self.curSelectBoneIdx, true);
            getglobal("ActorEditFrameModelView"):unbindCoordInteract();
        end
    end,

    --更换绑定的骨骼
    UpdateBindModel = function(self, replaceName)
        if not self.t_actorModelData[self.curSelectBoneIdx] then
            return;
        end

        if not self.t_actorModelData[self.curSelectBoneIdx].data[ActorEditMgr.curSelectAvatarIdx] then
            return;
        end

        getglobal("ActorEditSelectModelFrame"):Hide();

        local t = self.t_actorModelData[self.curSelectBoneIdx];
        if CustomModelMgr:replaceCustomAvatar(t.boneName, ActorEditMgr.curSelectAvatarIdx-1, replaceName) then
            t.data[ActorEditMgr.curSelectAvatarIdx].modelfilename = replaceName;
            --[[
            t.data[ActorEditMgr.curSelectAvatarIdx].scale = 1;
            t.data[ActorEditMgr.curSelectAvatarIdx].yaw = 0;
            t.data[ActorEditMgr.curSelectAvatarIdx].pitch = 0;
            t.data[ActorEditMgr.curSelectAvatarIdx].x = 0;
            t.data[ActorEditMgr.curSelectAvatarIdx].y = 0;
            t.data[ActorEditMgr.curSelectAvatarIdx].z = 0;
            ]]
            self:UpdateActorEditPartFrame(self.curSelectBoneIdx, true);
        end
    end,

    --通过操作刷新模型
    UpdateActorEditModelByOperate = function(self, val, index)
        local avatarModel = CustomModelMgr:getCustomAvatarModelData(self.t_actorModelData[self.curSelectBoneIdx].boneName, self.curSelectAvatarIdx-1);
        local data = self.t_actorModelData[self.curSelectBoneIdx].data[self.curSelectAvatarIdx];
        print("kekeke UpdateActorEditModelByOperate data", val, data, index);
        if not avatarModel or not data then return end

        if string.find(self.curOperateBtnName, "PosBtn") then
            if index == 1 then  --x轴偏移
                avatarModel:setPosition(data.x, val, data.z);
                data.y = val;
                getglobal("ActorEditFrameModelView"):setPosition(data.x, val, data.z);
            elseif index == 2 then --y轴偏移
                avatarModel:setPosition(val, data.y, data.z);
                data.x = val;
                getglobal("ActorEditFrameModelView"):setPosition(val, data.y, data.z);
            elseif index == 3 then --z轴偏移
                avatarModel:setPosition(data.x, data.y, val);
                data.z = val;
                getglobal("ActorEditFrameModelView"):setPosition(data.x, data.y, val);
            elseif index == 0 and type(val) == 'table' then
                avatarModel:setPosition(val.x, val.y, val.z);
                data.x = val.x;
                data.y = val.y;
                data.z = val.z;
                self:UpdateActorEditOperateFrame(self.curOperateBtnName, true);
            end
        elseif string.find(self.curOperateBtnName, "RotateBtn") then
            if index == 1 then --roll旋转
                avatarModel:setRotation(data.yaw, data.pitch, val);
                data.roll = val;
                getglobal("ActorEditFrameModelView"):setRotationEuler(data.pitch, data.yaw, val);
            elseif index == 2 then --yaw旋转
                avatarModel:setRotation(val, data.pitch, data.roll);
                data.yaw = val;
                getglobal("ActorEditFrameModelView"):setRotationEuler(data.pitch, val, data.roll);

            elseif index == 3 then --pitch旋转
                avatarModel:setRotation(data.yaw, val, data.roll);
                data.pitch = val;
                getglobal("ActorEditFrameModelView"):setRotationEuler(val, data.yaw, data.roll);
            elseif index == 0 and type(val) == 'table' then
                avatarModel:setRotation(val.yaw, val.pitch, val.roll);
                data.pitch = val.pitch;
                data.yaw = val.yaw;
                data.roll = val.roll;
                self:UpdateActorEditOperateFrame(self.curOperateBtnName, true);
            end
        elseif string.find(self.curOperateBtnName, "ScaleBtn") then
            if index == 3 then --pitch旋转
                avatarModel:setModelScale(val);
                data.scale = val;
                getglobal("ActorEditFrameModelView"):setScale(val, val, val);
            elseif index == 0 then
                avatarModel:setModelScale(val);
                data.scale = val;
                getglobal("ActorEditFrameModelView"):setScale(val, val, val);
                self:UpdateActorEditOperateFrame(self.curOperateBtnName, true);
            end
        end
    end,

    InitLoadEditableActorModel = function(self)
        self.curSelEditableType = "map";
        self.curSelEditableModelIdx = 0;
        self:LoadEditableActorModel();
    end,

    --导入可编辑生物模型
    LoadEditableActorModel = function (self)
        self.t_EditableActorModel = {map={}, res={}};
        local num = CustomModelMgr:getCustomActorModelNum(MAP_MODEL_CLASS);
        for i=1, num do
            local data = CustomModelMgr:getCustomActorModelData(MAP_MODEL_CLASS, i-1);
            if data and not data.leaveworlddel and CustomModelMgr:getCustomItem(data.modelmark) then
                table.insert(self.t_EditableActorModel.map, {modelmark=data.modelmark, modelname=data.modelname});
            end
        end

        num = CustomModelMgr:getCustomActorModelNum(RES_MODEL_CLASS);
        for i=1, num do
            local data = CustomModelMgr:getCustomActorModelData(RES_MODEL_CLASS, i-1);
            if data then
                table.insert(self.t_EditableActorModel.res, {modelmark=data.modelmark, modelname=data.modelname});
            end
        end

        print("kekeke LoadEditableActorModel t_EditableActorModel map", self.t_EditableActorModel.map);
        print("kekeke LoadEditableActorModel t_EditableActorModel res", self.t_EditableActorModel.res);
    end,

    --更新可编辑生物模型界面
    UpdateLoadEditableActorModelFrame = function(self, type)
        local t = nil;
        local getglobal = self.m_funcGetglobal;
        if type == "map" then
            getglobal("LoadEditableActorModelFrameTypeFrameLocalBtnChecked"):Show();
            getglobal("LoadEditableActorModelFrameTypeFrameResBtnChecked"):Hide();
            getglobal("LoadEditableActorModelFrameTypeFrameLocalBtnNormal"):ChangeTextureTemplate("TemplateBkg7");
            getglobal("LoadEditableActorModelFrameTypeFrameResBtnNormal"):ChangeTextureTemplate("TemplateBkg6");
            t = self.t_EditableActorModel.map;
        elseif type == "res" then
            getglobal("LoadEditableActorModelFrameTypeFrameLocalBtnChecked"):Hide();
            getglobal("LoadEditableActorModelFrameTypeFrameResBtnChecked"):Show();
            getglobal("LoadEditableActorModelFrameTypeFrameLocalBtnNormal"):ChangeTextureTemplate("TemplateBkg6");
            getglobal("LoadEditableActorModelFrameTypeFrameResBtnNormal"):ChangeTextureTemplate("TemplateBkg7");
            t = self.t_EditableActorModel.res;
        end

        if t then
            local num = #(t);
            if num <= self.editableActorModelMax then for i=1, num do
                local slotUI = getglobal("LoadEditableActorModelSlot"..i);
                local iconUI = getglobal("LoadEditableActorModelSlot"..i.."Icon");
                local checkUI = getglobal("LoadEditableActorModelSlot"..i.."Checked");
                local nameUI = getglobal("LoadEditableActorModelSlot" .. i .. "Name");

                slotUI:Show();
                SetModelIcon(iconUI, t[i].modelmark, ACTOR_MODEL);
                checkUI:Hide();
                print("UpdateLoadEditableActorModelFrame(): i = ", i, ", modelname = ", t[i].modelname);
                nameUI:SetText(t[i].modelname or "???");
            end end

            for i=num+1, self.editableActorModelMax do
                local slotUI = getglobal("LoadEditableActorModelSlot"..i);
                slotUI:Hide();
            end
            if num <= 12 then
                getglobal("LoadEditableActorModelSlotBoxPlane"):SetSize(732, 394);
            else
                local row = math.ceil(num/6);
                getglobal("LoadEditableActorModelSlotBoxPlane"):SetSize(732, row*125);
            end

            if num > 0 then
                getglobal("LoadEditableActorModelFrameTipsFrame"):Hide();
            else
                getglobal("LoadEditableActorModelFrameTipsFrame"):Show();
            end
        end
    end,

    --更新选择编辑模型模板界面
    UpdateActorSelectEditFrame = function(self)
        local modelView = getglobal("ActorSelectEditFrameModelView");
        local actorBody = modelView:getActorbody();
        if actorBody then
            if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
                modelView:detachActorBody(actorBody)
            else
                actorBody:detachUIModelView(modelView);
            end
        end

        actorBody = CustomModelMgr:getOrCreateCurEditActorBody(self.curEditModelTemplateType);
        if actorBody then
            if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
                modelView:attachActorBody(actorBody)
            else
                actorBody:attachUIModelView(modelView);
            end
        end

        getglobal("ActorSelectEditFrameLeftBtn"):Show();
        getglobal("ActorSelectEditFrameRightBtn"):Show();
        if self.curEditModelTemplateType == HUMAN_MODEL then
            getglobal("ActorSelectEditFrameLeftBtn"):Hide();
            getglobal("ActorSelectEditFrameType"):SetText(GetS(12503));
        elseif self.curEditModelTemplateType == QUADRUPED_MODEL then
            getglobal("ActorSelectEditFrameType"):SetText(GetS(12531));
            modelView:setRotateAngle(45);
        elseif self.curEditModelTemplateType == SINGLE_BONE_MODEL then
            getglobal("ActorSelectEditFrameRightBtn"):Hide();
            getglobal("ActorSelectEditFrameType"):SetText(GetS(12532));
        end
    end,

    --avatar对称添加、调整
    t_avatarRelevance = {
        [HUMAN_MODEL] = {
            Arm_left1 = {
                boneNames={[8]="Arm_right1"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
            Arm_right1 = {
                boneNames={[5]="Arm_left1"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
            Arm_left2 = {
                boneNames={[9]="Arm_right2"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
            Arm_right2 = {
                boneNames={[6]="Arm_left2"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
            Arm_left3 = {
                boneNames={[10]="Arm_right3"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
            Arm_right3 = {
                boneNames={[7]="Arm_left3"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
            Leg_left1 = {
                boneNames={[14]="Leg_right1"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
            Leg_right1 = {
                boneNames={[11]="Leg_left1"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
            Leg_left2 = {
                boneNames={[15]="Leg_right2"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
            Leg_right2 = {
                boneNames={[12]="Leg_left2"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
            Leg_left3 = {
                boneNames={[16]="Leg_right3"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
            Leg_right3 = {
                boneNames={[13]="Leg_left3"}, ReverseX=true, ReverseRoll=true, ReverseYaw=true,
            },
        },
        [QUADRUPED_MODEL] = {
            Arm_left1 = {
                boneNames={[8]="Arm_right1",[11]="Leg_left1",[14]="Leg_right1"},
            },
            Arm_right1 = {
                boneNames={[5]="Arm_left1",[11]="Leg_left1",[14]="Leg_right1"},
            },
            Arm_left2 = {
                boneNames={[9]="Arm_right2",[12]="Leg_left2",[15]="Leg_right2"},
            },
            Arm_right2 = {
                boneNames={[6]="Arm_left2",[12]="Leg_left2",[15]="Leg_right2"},
            },
            Arm_left3 = {
                boneNames={[10]="Arm_right3",[13]="Leg_left3",[16]="Leg_right3"},
            },
            Arm_right3 = {
                boneNames={[7]="Arm_left3",[13]="Leg_left3",[16]="Leg_right3"},
            },
            Leg_left1 = {
                boneNames={[8]="Arm_right1",[5]="Arm_left1",[14]="Leg_right1"},
            },
            Leg_right1 = {
                boneNames={[8]="Arm_right1",[5]="Arm_left1",[11]="Leg_left1",},
            },
            Leg_left2 = {
                boneNames={[6]="Arm_left2",[9]="Arm_right2",[15]="Leg_right2"},
            },
            Leg_right2 = {
                boneNames={[6]="Arm_left2",[9]="Arm_right2",[12]="Leg_left2"},
            },
            Leg_left3 = {
                boneNames={[7]="Arm_left3",[10]="Arm_right3",[16]="Leg_right3"},
            },
            Leg_right3 = {
                boneNames={[7]="Arm_left3",[10]="Arm_right3",[13]="Leg_left3"},
            },
        },
    },

    convertValByRelevance = function(self, val, type, hasConvert)
        if not hasConvert then
            return val;
        end

        if type == "x" or type == "y" or type=="z" then
            val = -val;
        end

        return val;
    end,

    UpdateOneBySymmetryOperate = function(self, k, boneName, addVal, index, t_relbone)  
        print("kekeke UpdateOneBySymmetryOperate", addVal)       
        if #(self.t_actorModelData[k].data) < self.curSelectAvatarIdx then 
            return;
        end
            
        local avatarModel = CustomModelMgr:getCustomAvatarModelData(boneName, self.curSelectAvatarIdx-1);
        if not avatarModel then
            return;
        end

        local srcData = self.t_actorModelData[self.curSelectBoneIdx].data[self.curSelectAvatarIdx];
        local descData = self.t_actorModelData[k].data[self.curSelectAvatarIdx];

        if string.find(self.curOperateBtnName, "PosBtn") then
            if index == 1 then  --x轴偏移
                local val = descData.y + self:convertValByRelevance(addVal, "x", t_relbone.ReverseX);
                print("kekeke UpdateOneBySymmetryOperate val", val)   
                --if val > 100 then val = 100 end
                --if val < -100 then val = -100 end
                avatarModel:setPosition(descData.x, val, descData.z);
                descData.y = val;
            elseif index == 2 then --y轴偏移
                local val = descData.x + self:convertValByRelevance(addVal, "y", t_relbone.ReverseY);
                --if val > 100 then val = 100 end
                --if val < -100 then val = -100 end
                avatarModel:setPosition(val, descData.y, descData.z);
                descData.x= val;
            elseif index == 3 then --z轴偏移
                local val = descData.z + self:convertValByRelevance(addVal, "y", t_relbone.ReverseZ);
                --if val > 100 then val = 100 end
                --if val < -100 then val = -100 end
                avatarModel:setPosition(descData.x, descData.y, val);
                descData.z = val;
            end
        elseif string.find(self.curOperateBtnName, "RotateBtn") then
            if index == 1 then --roll旋转
                local val = descData.roll + addVal;
                if val > 180 then val = val - 360 end
                if val < -180 then val = val + 360 end
                avatarModel:setRotation(descData.yaw, descData.pitch, val);
                descData.roll = val;
            elseif index == 2 then --yaw旋转
                local val = descData.yaw + addVal;
                if val > 180 then val = val - 360 end
                if val < -180 then val = val + 360 end
                avatarModel:setRotation(val, descData.pitch, descData.roll);
                descData.yaw = val;
            elseif index == 3 then --pitch旋转
                local val = descData.pitch + addVal;
                if val > 180 then val = val - 360 end
                if val < -180 then val = val + 360 end
                avatarModel:setRotation(descData.yaw, val, descData.roll);
                descData.pitch = val;
            end
        elseif string.find(self.curOperateBtnName, "ScaleBtn") then
            if index == 3 then 
                local val = descData.scale + addVal;
                --if val > 2 then val = 2 end
                if val < 0.1 then val = 0.1 end
                
                avatarModel:setModelScale(val);
                descData.scale = val;
            end
        end
    end,

    --对称操作刷新数据
    UpdateBySymmetryOperate = function(self, addVal, index)
        if not self.t_actorModelData[self.curSelectBoneIdx] then
            return;
        end

        local boneName = self.t_actorModelData[self.curSelectBoneIdx].boneName;
        local t_relbone = self.t_avatarRelevance[self.curEditModelType][boneName];
        for k, v in pairs(t_relbone.boneNames) do
            self:UpdateOneBySymmetryOperate(k, v, addVal, index, t_relbone);
        end
    end,
}

function ActorSelectEditFrameCloseBtn_OnClick()
    if CurMainPlayer then
        if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
            getglobal("ActorSelectEditFrameModelView"):detachActorBody(nil) --释放前先解绑
        end
        CurMainPlayer:closeEditActorModel(0);
        ActorEditMgr.curCloseType = ActorEditMgr.CloseTypeENUM.EDIE_CLOSE;
    end
    getglobal("ActorSelectEditFrame"):Hide();
end

function ActorSelectEditFrameLeftBtn_OnClick()
    ActorEditMgr.curEditModelTemplateType = ActorEditMgr.curEditModelTemplateType - 1;
    ActorEditMgr:UpdateActorSelectEditFrame();
end

function ActorSelectEditFrameRightBtn_OnClick()
    ActorEditMgr.curEditModelTemplateType = ActorEditMgr.curEditModelTemplateType + 1;
    ActorEditMgr:UpdateActorSelectEditFrame();
end

function ActorSelectEditFrameCreateOrEditBtn_OnClick()
    ActorEditMgr.curCloseType = ActorEditMgr.CloseTypeENUM.NO_CLOSE;
    getglobal("ActorSelectEditFrame"):Hide();
    getglobal("ActorEditFrame"):Show();
end

function ActorSelectEditFrameLoadBtn_OnClick()
    getglobal("LoadEditableActorModelFrame"):Show();
end

function ActorSelectEditFrame_OnLoad()
    this:RegisterEvent("GE_OPEN_EDIT_ACTORMODEL");
    this:RegisterEvent("GE_CLOSE_EDIT_ACTORMODEL");
end

function ActorSelectEditFrame_OnEvent()
    if arg1 == "GE_OPEN_EDIT_ACTORMODEL" then
        getglobal("ActorSelectEditFrame"):Show();
    elseif arg1 == 'GE_CLOSE_EDIT_ACTORMODEL' then
        ActorEditMgr.curCloseType = ActorEditMgr.CloseTypeENUM.NO_CLOSE;
        if getglobal("ActorSelectEditFrame"):IsShown() then
            getglobal("ActorSelectEditFrame"):Hide();
        end

        if getglobal("ActorEditFrame"):IsShown() then
            getglobal("ActorEditFrame"):Hide();
        end
    end
end

function ActorSelectEditFrame_OnShow()
    if not getglobal("ActorSelectEditFrame"):IsReshow() then
        ClientCurGame:setOperateUI(true);
        ActorEditMgr.curCloseType = ActorEditMgr.CloseTypeENUM.NORMAL_CLOSE;
    end

    -- 高级创造编辑模式,层级往上抬一点
    -- 老编辑模式则还原会初始层级
    local selectEditFrame = getglobal("ActorSelectEditFrame")
    if selectEditFrame and IsUGCEditing() then
        selectEditFrame:SetFrameLevel(11)
    else
        selectEditFrame:SetFrameLevel(10)
    end

    local needSelect = true;
    local modelType = HUMAN_MODEL;
    needSelect, modelType = CustomModelMgr:getCurEditActorTemplateInfo(needSelect, modelType);  
    ActorEditMgr.curEditModelTemplateType = modelType;
    ActorEditMgr:UpdateActorSelectEditFrame();
    if needSelect then
        getglobal("ActorSelectEditFrameTitle"):SetText(GetS(12505));
        getglobal("ActorSelectEditFrameCreateOrEditBtnName"):SetText(GetS(12504));
        getglobal("ActorSelectEditFrameTypeBkg"):Show();
        getglobal("ActorSelectEditFrameLoadBtn"):Show(); --Show();
    else
        getglobal("ActorSelectEditFrameLeftBtn"):Hide();
        getglobal("ActorSelectEditFrameRightBtn"):Hide();
        getglobal("ActorSelectEditFrameTypeBkg"):Hide();
        getglobal("ActorSelectEditFrameType"):SetText("");
        getglobal("ActorSelectEditFrameLoadBtn"):Hide();
        getglobal("ActorSelectEditFrameTitle"):SetText(GetS(12500));
        getglobal("ActorSelectEditFrameCreateOrEditBtnName"):SetText(GetS(12501));
    end
end

function ActorSelectEditFrame_OnHide()
    local actorBody = CustomModelMgr:getActorBody();
    if actorBody then
        if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
            getglobal("ActorSelectEditFrameModelView"):detachActorBody(actorBody)
        else
            actorBody:detachUIModelView(getglobal("ActorSelectEditFrameModelView"));
        end
    end
    if not getglobal("ActorSelectEditFrame"):IsRehide() then
        ClientCurGame:setOperateUI(false);

        if CurMainPlayer and ActorEditMgr.curCloseType == ActorEditMgr.CloseTypeENUM.NORMAL_CLOSE then
            CurMainPlayer:closeEditActorModel(-1);
        end
    end
end

function ActorSelectEditFrameRotateView_OnMouseDown()
    InitModelViewAngle =  getglobal("ActorSelectEditFrameModelView"):getRotateAngle();
end

function ActorSelectEditFrameRotateView_OnMouseMove()
    local angle = (arg1 - arg3)*1;

    if angle > 360 then
        angle = angle - 360;
    end
    if angle < -360 then
        angle = angle + 360;
    end

    angle = angle + InitModelViewAngle; 
    getglobal("ActorSelectEditFrameModelView"):setRotateAngle(angle);
end

-------------------------------------ActorEditFrame--------------------------------------------------

function ActorEditOperateTemplate_OnClick()
    ActorEditMgr:UpdateActorEditOperateFrame(this:GetName());
end

function ActorEditFrameViewBtn_OnClick()
    local t_uvName = {"ico_model_free", "ico_model_right", "ico_model_front", "ico_model_top"};
    local t_tips = {GetS(12527), GetS(12528), GetS(12529), GetS(12530)};
    local index = ActorEditMgr.curViewType+1 > #(t_uvName) and 1 or ActorEditMgr.curViewType+1;

    getglobal("ActorEditFrameViewBtnIcon"):SetTexUV(t_uvName[index]);
    ShowGameTips(t_tips[index]);

    ActorEditMgr.curViewType = index;

    local yaw;
    local pitch;

    if ActorEditMgr.curViewType == ActorEditMgr.ViewTypeENUM.FRONT_VIEW or ActorEditMgr.curViewType == ActorEditMgr.ViewTypeENUM.FREE_VIEW then
        yaw = 0;
        pitch = 0;

    elseif ActorEditMgr.curViewType == ActorEditMgr.ViewTypeENUM.END_VIEW then
        yaw = -90;
        pitch = 0;
    elseif ActorEditMgr.curViewType == ActorEditMgr.ViewTypeENUM.VERTICAL_VIEW then
        yaw = 0;
        pitch = 90;
    end

    getglobal("ActorEditFrameModelView"):setCameraAngle(yaw, pitch, 0);

    local r = ActorEditMgr.VIEW_RADIUS; --半径
    local y = math.sin(math.rad(pitch))*r;

    local tmpR = math.cos(math.rad(pitch))*r;
    local z = math.cos(math.rad(yaw))*tmpR;
    local x = math.sin(math.rad(yaw))*tmpR

    getglobal("ActorEditFrameModelView"):setCameraPosition(-x, y+1000, -z);
end

function ActorEditFrameAmplifyBtn_OnClick()
    ActorEditMgr.curModelScale = ActorEditMgr.curModelScale + 0.1;
    if ActorEditMgr.curModelScale > 2 then
        ActorEditMgr.curModelScale = 2;
    end

    local actorBody = CustomModelMgr:getActorBody();
    if actorBody then
        actorBody:setScale(ActorEditMgr.curModelScale);
    end
end

function ActorEditFrameReduceBtn_OnClick()
    ActorEditMgr.curModelScale = ActorEditMgr.curModelScale - 0.1;
    if ActorEditMgr.curModelScale < 0.1 then
        ActorEditMgr.curModelScale = 0.1;
    end

    local actorBody = CustomModelMgr:getActorBody();
    if actorBody then
        actorBody:setScale(ActorEditMgr.curModelScale);
    end
end

function ActorEditFrameSubModelDisPlayBtn_OnClick()
    local getglobal = getglobal;
    ActorEditMgr.subModelSkinDisplay = not ActorEditMgr.subModelSkinDisplay;
    if ActorEditMgr.subModelSkinDisplay then
        getglobal("ActorEditFrameSubModelDisPlayBtnIcon"):SetTexUV("ico_model_xianshi");
        getglobal("ActorEditFrameSubModelDisPlayBtnIcon"):SetPoint("center", "ActorEditFrameSubModelDisPlayBtn", "center", 0, 0);
    else
        getglobal("ActorEditFrameSubModelDisPlayBtnIcon"):SetTexUV("ico_model_yincang");
        getglobal("ActorEditFrameSubModelDisPlayBtnIcon"):SetPoint("center", "ActorEditFrameSubModelDisPlayBtn", "center", 0, 10);
    end
    CustomModelMgr:setCurEditActorSkinDisplay(ActorEditMgr.subModelSkinDisplay);
end

function ActorEditFrameCloseBtn_OnClick()
    if CurMainPlayer then
        ActorEditFrameModelViewDetachActorBody() -- code_by:huangfubin 2021.10.12
        CurMainPlayer:closeEditActorModel(0);
        ActorEditMgr.curCloseType = ActorEditMgr.CloseTypeENUM.EDIE_CLOSE;
    end

    getglobal("ActorEditFrame"):Hide();
end

function ActorEditFrame_OnLoad()
    for i=1, ActorEditMgr.boneNumMax do
        local boneUI = getglobal("ActorEditFramePartFrameBoneBoxBone"..i);
        boneUI:SetPoint("top", "ActorEditFramePartFrameBoneBoxPlane", "top", 0, 13 + (i-1)*74);
    end

    t_name = {GetS(12515), GetS(12516), GetS(12517), GetS(12518), GetS(12519), GetS(12520), GetS(12521), GetS(12522)}
    for i=1, ActorEditMgr.motionMax do
        local boneUI = getglobal("ActorEditFrameMotionFrameBoxMotion"..i);
        local nameUI = getglobal("ActorEditFrameMotionFrameBoxMotion"..i.."Name");
        local idUI = getglobal("ActorEditFrameMotionFrameBoxMotion"..i.."ID");

        boneUI:SetPoint("top", "ActorEditFrameMotionFrameBoxPlane", "top", 0, (i-1)*70);
        nameUI:SetText(t_name[i]);
        idUI:SetText(boneUI:GetClientID());
    end

    for i=1, ActorEditMgr.avatarBindBoneMax do
        local avatarUI = getglobal("ActorEditFramePartFrameAvatarBoxAvatar"..i);

        local row = math.ceil(i/2);
        local col = i - (row-1)*2;
        avatarUI:SetPoint("topleft", "ActorEditFramePartFrameAvatarBoxPlane", "topleft", 8 + (col-1)*110, (row-1)*127);
    end

    t_name = {{text="X", r=237, g=27, b=36}, {text="Y", r=35, g=177, b=77}, {text="Z", r=54, g=103, b=193}};
    for i=1, 3 do
        local sliderName = getglobal("ActorEditFrameOperateFrameSlider"..i.."Name");
        sliderName:SetText(t_name[i].text);
        sliderName:SetTextColor(t_name[i].r, t_name[i].g, t_name[i].b);
    end

   --getglobal("ActorEditFrameModelView"):setCameraWidthFov(30);
    --getglobal("ActorEditFrameModelView"):setCameraLookAt(0, 220, -1200, 0, 128, 0);
    getglobal("ActorEditFrameModelView"):setActorPosition(0, 30, 0);
end

-- code_by:huangfubin 2021.10.12 解耦重构后，释放ActorBody前，先解除下绑定
function ActorEditFrameModelViewDetachActorBody()
    if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
        getglobal("ActorEditFrameModelView"):detachActorBody(nil)
    end
end

function ActorEditFrame_OnShow()
    if not getglobal("ActorEditFrame"):IsReshow() then
        ClientCurGame:setOperateUI(true);
    end

    -- 高级创造编辑模式,层级往上抬一点
    -- 老编辑模式则还原会初始层级
    local editFrame = getglobal("ActorEditFrame")
    if editFrame and IsUGCEditing() then
        editFrame:SetFrameLevel(11)
    else
        editFrame:SetFrameLevel(10)
    end

    local actorBody = CustomModelMgr:getOrCreateCurEditActorBody(DEFAUT_MODEL);
    if actorBody then
        if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
            getglobal("ActorEditFrameModelView"):attachActorBody(actorBody)
        else
            actorBody:attachUIModelView(getglobal("ActorEditFrameModelView"));
        end
        actorBody:setScale(0.7);
        actorBody:stopAnimBySeqId(100100);

        getglobal("ActorEditFrameModelView"):setCameraAngle(0, 0, 0);
        getglobal("ActorEditFrameModelView"):setCameraPosition(0, 1000, -5000);
    end

    ActorEditMgr:Init();
    ActorEditFramePartBtn_OnClick();
end

function ActorEditFrame_OnHide()
    local actorBody = CustomModelMgr:getActorBody();
    if actorBody then
        if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
            getglobal("ActorEditFrameModelView"):detachActorBody(actorBody)
        else
            actorBody:detachUIModelView(getglobal("ActorEditFrameModelView"));
        end
    end

    if not getglobal("ActorEditFrame"):IsRehide() then
        ClientCurGame:setOperateUI(false);

        if CurMainPlayer and ActorEditMgr.curCloseType == ActorEditMgr.CloseTypeENUM.NORMAL_CLOSE then
            CurMainPlayer:closeEditActorModel(-1);
        end
    end

    getglobal("ActorEditFrameConfirmMakeFrame"):Hide();
end

function ActorEditFrameMakeBtn_OnClick()
    getglobal("ActorEditFrameConfirmMakeFrameName"):Clear();
    getglobal("ActorEditFrameConfirmMakeFrame"):Show();
end

function ActorEditFrameMotionBtn_OnClick()
    local getglobal = getglobal;
    if getglobal("ActorEditFramePartFrame"):IsShown() then
        if ActorEditMgr.t_actorModelData[ActorEditMgr.curSelectBoneIdx] then
            local effectName = string.lower(ActorEditMgr.t_actorModelData[ActorEditMgr.curSelectBoneIdx].boneName);
            getglobal("ActorEditFrameModelView"):stopEffect(effectName, 0);
            CustomModelMgr:setCurEditActorOverlayColor(ActorEditMgr.t_actorModelData[ActorEditMgr.curSelectBoneIdx].boneName, false);
        end
        
        getglobal("ActorEditFramePartFrame"):Hide();
        if ActorEditMgr.curSelectAvatarIdx > 0 then
            ActorEditMgr:ActorEditAvatarClick(ActorEditMgr.curSelectAvatarIdx);  --取消选中
        end
    end

    if not getglobal("ActorEditFrameMotionFrame"):IsShown() then
        getglobal("ActorEditFramePartBtnCheck"):Hide();
        getglobal("ActorEditFramePartBtnName"):SetTextColor(142, 135, 120);
        getglobal("ActorEditFrameMotionBtnCheck"):Show();
        getglobal("ActorEditFrameMotionBtnName"):SetTextColor(255, 135, 26);

        --if ActorEditMgr.curSelectMotionIdxIdx <= 0 then
        getglobal("ActorEditFrameMotionFrameBox"):resetOffsetPos();
        ActorEditMgr:UpdateActorEditMotionFrame(0);
        --end
        getglobal("ActorEditFrameMotionFrame"):Show();
    else
        getglobal("ActorEditFrameMotionFrame"):Hide();
        getglobal("ActorEditFrameMotionBtnCheck"):Hide();
        getglobal("ActorEditFrameMotionBtnName"):SetTextColor(142, 135, 120);
    end
end

function ActorEditFramePartBtn_OnClick()
    local getglobal = getglobal;
    if getglobal("ActorEditFrameMotionFrame"):IsShown() then
        getglobal("ActorEditFrameMotionFrame"):Hide();
    end

    if not getglobal("ActorEditFramePartFrame"):IsShown() then
        getglobal("ActorEditFrameMotionBtnCheck"):Hide();
        getglobal("ActorEditFrameMotionBtnName"):SetTextColor(142, 135, 120);
        getglobal("ActorEditFramePartBtnCheck"):Show();
        getglobal("ActorEditFramePartBtnName"):SetTextColor(255,135,26);

        if ActorEditMgr.curSelectBoneIdx <= 0 then
            getglobal("ActorEditFramePartFrameBoneBox"):resetOffsetPos();
            ActorEditMgr:UpdateActorEditPartFrame(1);
        end
        getglobal("ActorEditFramePartFrame"):Show();

        if ActorEditMgr.t_actorModelData[ActorEditMgr.curSelectBoneIdx] then
            local effectName = string.lower(ActorEditMgr.t_actorModelData[ActorEditMgr.curSelectBoneIdx].boneName);
            getglobal("ActorEditFrameModelView"):playEffect(effectName, 0);
            CustomModelMgr:setCurEditActorOverlayColor(ActorEditMgr.t_actorModelData[ActorEditMgr.curSelectBoneIdx].boneName, true);
        end
    else
        if ActorEditMgr.t_actorModelData[ActorEditMgr.curSelectBoneIdx] then
            local effectName = string.lower(ActorEditMgr.t_actorModelData[ActorEditMgr.curSelectBoneIdx].boneName);
            getglobal("ActorEditFrameModelView"):stopEffect(effectName, 0);
            CustomModelMgr:setCurEditActorOverlayColor(ActorEditMgr.t_actorModelData[ActorEditMgr.curSelectBoneIdx].boneName, false);
        end

        getglobal("ActorEditFramePartFrame"):Hide();
        getglobal("ActorEditFramePartBtnCheck"):Hide();
        getglobal("ActorEditFramePartBtnName"):SetTextColor(142, 135, 120);
        if ActorEditMgr.curSelectAvatarIdx > 0 then
            ActorEditMgr:ActorEditAvatarClick(ActorEditMgr.curSelectAvatarIdx);  --取消选中
        end
    end
end

function ActorEditFrameRotateView_OnMouseDown()
    if ActorEditMgr.curViewType ~= ActorEditMgr.ViewTypeENUM.FREE_VIEW then
        ActorEditMgr.curViewType = ActorEditMgr.ViewTypeENUM.FREE_VIEW;

        getglobal("ActorEditFrameViewBtnIcon"):SetTexUV("ico_model_free");
        ShowGameTips(GetS(12527));
    end

    local viewUI = getglobal("ActorEditFrameModelView");
    ActorEditMgr.curYawAngle = viewUI:getCameraYaw();
    ActorEditMgr.curPitchAngle = viewUI:getCameraPitch();
    ActorEditMgr.curCameraX, ActorEditMgr.curCameraY, ActorEditMgr.curCameraZ = viewUI:getCameraPosition(ActorEditMgr.curCameraX, ActorEditMgr.curCameraY, ActorEditMgr.curCameraZ);
    ActorEditMgr.cuRotateDir = "";
    print("kekeke ActorEditFrameRotateView_OnMouseDown", ActorEditMgr.curCameraX, ActorEditMgr.curCameraY, ActorEditMgr.curCameraZ);
end

function ActorEditFrameRotateView_OnMouseMove()
    if ActorEditMgr.curViewType ~= ActorEditMgr.ViewTypeENUM.FREE_VIEW then
        return
    end

    local isVertical = true;
    if ActorEditMgr.cuRotateDir == "" then
        if math.abs(arg4 - arg2)>math.abs(arg3 - arg1) then
            ActorEditMgr.cuRotateDir = "vertical";
        elseif math.abs(arg4 - arg2)<math.abs(arg3 - arg1) then
            ActorEditMgr.cuRotateDir = "horizontal";
        end
    end

    if ActorEditMgr.cuRotateDir == "vertical" then
        local angleY = ActorEditMgr.curPitchAngle + (arg4 - arg2)/4;

        getglobal("ActorEditFrameModelView"):setCameraAngle(ActorEditMgr.curYawAngle, angleY, 0);

        local r = ActorEditMgr.VIEW_RADIUS; --半径
        local y = math.sin(math.rad(angleY))*r;

        local tmpR = math.cos(math.rad(angleY))*r;
        local z = math.cos(math.rad(ActorEditMgr.curYawAngle))*tmpR;
        local x = math.sin(math.rad(ActorEditMgr.curYawAngle))*tmpR

        --print("kekeke ActorEditFrameRotateView_OnMouseMove---------", ActorEditMgr.curCameraX, y+1000, -z);
        getglobal("ActorEditFrameModelView"):setCameraPosition(-x, y+1000, -z);
    elseif ActorEditMgr.cuRotateDir == "horizontal" then
        --local yaw = getglobal("ActorEditFrameModelView"):getCameraYaw();
        local angleX = ActorEditMgr.curYawAngle + (arg3 - arg1)/4;

        getglobal("ActorEditFrameModelView"):setCameraAngle(angleX, ActorEditMgr.curPitchAngle, 0);

        local r = ActorEditMgr.VIEW_RADIUS; --半径

        local tmpR = math.cos(math.rad(ActorEditMgr.curPitchAngle))*r;
        local z = math.cos(math.rad(angleX))*tmpR;
        local x = math.sin(math.rad(angleX))*tmpR

        --print("kekeke ActorEditFrameRotateView_OnMouseMove", -x, ActorEditMgr.curCameraY, -z);
        getglobal("ActorEditFrameModelView"):setCameraPosition(-x, ActorEditMgr.curCameraY, -z);
    end
end

function ActorEditFrameRotateView_OnMouseDownUpdate()

end

function ActorEditFrameRotateView_OnMouseUp()

end

function ActorEditFrameModelView_OnMouseDown()
    if ActorEditMgr.curViewType ~= ActorEditMgr.ViewTypeENUM.FREE_VIEW then
        ActorEditMgr.curViewType = ActorEditMgr.ViewTypeENUM.FREE_VIEW;

        getglobal("ActorEditFrameViewBtnIcon"):SetTexUV("ico_model_free");
        ShowGameTips(GetS(12527));
    end

    local viewUI = getglobal("ActorEditFrameModelView");
    ActorEditMgr.curYawAngle = viewUI:getCameraYaw();
    ActorEditMgr.curPitchAngle = viewUI:getCameraPitch();
    ActorEditMgr.curCameraX, ActorEditMgr.curCameraY, ActorEditMgr.curCameraZ = viewUI:getCameraPosition(ActorEditMgr.curCameraX, ActorEditMgr.curCameraY, ActorEditMgr.curCameraZ);
    ActorEditMgr.cuRotateDir = "";
    print("kekeke ActorEditFrameModelView_OnMouseDown", ActorEditMgr.curCameraX, ActorEditMgr.curCameraY, ActorEditMgr.curCameraZ);
end

function ActorEditFrameModelView_OnMouseMove()
    if arg5 == 0 then
        if ActorEditMgr.curViewType ~= ActorEditMgr.ViewTypeENUM.FREE_VIEW then
            return
        end

        local isVertical = true;
        if ActorEditMgr.cuRotateDir == "" then
            if math.abs(arg4 - arg2)>math.abs(arg3 - arg1) then
                ActorEditMgr.cuRotateDir = "vertical";
            elseif math.abs(arg4 - arg2)<math.abs(arg3 - arg1) then
                ActorEditMgr.cuRotateDir = "horizontal";
            end
        end

        if ActorEditMgr.cuRotateDir == "vertical" then
            local angleY = ActorEditMgr.curPitchAngle + (arg4 - arg2)/4;

            getglobal("ActorEditFrameModelView"):setCameraAngle(ActorEditMgr.curYawAngle, angleY, 0);

            local r = ActorEditMgr.VIEW_RADIUS; --半径
            local y = math.sin(math.rad(angleY))*r;

            local tmpR = math.cos(math.rad(angleY))*r;
            local z = math.cos(math.rad(ActorEditMgr.curYawAngle))*tmpR;
            local x = math.sin(math.rad(ActorEditMgr.curYawAngle))*tmpR

            --print("kekeke ActorEditFrameRotateView_OnMouseMove---------", ActorEditMgr.curCameraX, y+1000, -z);
            getglobal("ActorEditFrameModelView"):setCameraPosition(-x, y+1000, -z);
        elseif ActorEditMgr.cuRotateDir == "horizontal" then
            --local yaw = getglobal("ActorEditFrameModelView"):getCameraYaw();
            local angleX = ActorEditMgr.curYawAngle + (arg3 - arg1)/4;

            getglobal("ActorEditFrameModelView"):setCameraAngle(angleX, ActorEditMgr.curPitchAngle, 0);

            local r = ActorEditMgr.VIEW_RADIUS; --半径

            local tmpR = math.cos(math.rad(ActorEditMgr.curPitchAngle))*r;
            local z = math.cos(math.rad(angleX))*tmpR;
            local x = math.sin(math.rad(angleX))*tmpR

            --print("kekeke ActorEditFrameRotateView_OnMouseMove", -x, ActorEditMgr.curCameraY, -z);
            getglobal("ActorEditFrameModelView"):setCameraPosition(-x, ActorEditMgr.curCameraY, -z);
        end
    else
        local data = ActorEditMgr.t_actorModelData[ActorEditMgr.curSelectBoneIdx].data[ActorEditMgr.curSelectAvatarIdx];
        if ActorEditMgr.curCoordType == 1 then
            local x=0;
            local y=0;
            local z=0;
            x, y, z = ActorEditMgr.modelViewUI:getPosition(x, y, z);

            if ActorEditMgr.symmetryOperate then
                local addVal = x - data.x;
                ActorEditMgr:UpdateBySymmetryOperate(addVal, 2)
                addVal = y - data.y;
                ActorEditMgr:UpdateBySymmetryOperate(addVal, 1)
                addVal = z - data.z;
                ActorEditMgr:UpdateBySymmetryOperate(addVal, 3)
            end
            ActorEditMgr:UpdateActorEditModelByOperate({x=x, y=y, z=z}, 0);
        elseif ActorEditMgr.curCoordType == 2 then
            local pitch=0;
            local yaw=0;
            local roll=0;
            pitch, yaw, roll = ActorEditMgr.modelViewUI:getRotationEuler(pitch, yaw, roll);

            if ActorEditMgr.symmetryOperate then
                local addVal = pitch - data.pitch;
                ActorEditMgr:UpdateBySymmetryOperate(addVal, 3)
                addVal = yaw - data.yaw;
                ActorEditMgr:UpdateBySymmetryOperate(addVal, 2)
                addVal = roll - data.roll;
                ActorEditMgr:UpdateBySymmetryOperate(addVal, 1)
            end
            ActorEditMgr:UpdateActorEditModelByOperate({pitch=pitch, yaw=yaw, roll=roll}, 0);
        elseif ActorEditMgr.curCoordType == 3 then
            local curTran = ActorEditMgr.modelViewUI:getCurTran();

            local scaleX=1;
            local scaleY=1;
            local scaleZ=1;
            scaleX, scaleY, scaleZ = ActorEditMgr.modelViewUI:getScale(scaleX, scaleY, scaleZ);
            
            local addVal = 0;
            if curTran == 8 then
                addVal = scaleX - data.scale;
                ActorEditMgr:UpdateActorEditModelByOperate(scaleX, 0);
            elseif curTran == 9 then
                addVal = scaleY - data.scale;
                ActorEditMgr:UpdateActorEditModelByOperate(scaleY, 0);
            elseif curTran == 10 then
                addVal = scaleZ - data.scale;
                ActorEditMgr:UpdateActorEditModelByOperate(scaleZ, 0);
            end

            if ActorEditMgr.symmetryOperate then
                ActorEditMgr:UpdateBySymmetryOperate(addVal, 3)
            end
        end
    end
end

------------------------------ActorEditFramePartFrame-----------------------
function ActorEditAvatarBtnTemplate_OnClick()
    ActorEditMgr:ActorEditAvatarClick(this:GetClientID());
end

function ActorEditBoneBtnTemplate_OnClick()
    if ActorEditMgr.curSelectAvatarIdx > 0 then
        ActorEditMgr:ActorEditAvatarClick(ActorEditMgr.curSelectAvatarIdx);  --取消选中
    end

    getglobal("ActorEditFramePartFrameAvatarBox"):resetOffsetPos();
    ActorEditMgr:UpdateActorEditPartFrame(this:GetClientID());
    ActorEditMgr:ActorEditAvatarClick(1);  --默认选择第一个
end

function ActorEditFramePartFrameDelBtn_OnClick()
    MessageBox(1, GetS(12523),function(btn)
        if btn == 'left' then
            ActorEditMgr:DelBindModel();
        end
    end);
end

function ActorEditFramePartFrameRefreshBtn_OnClick()
    ActorEditMgr:UpdateActorEditSelectModelFrame(1, "refresh");
end

function ActorEditFramePartFrameAvatarBoxAddBtn_OnClick()
    if ActorEditMgr:GetEditModelAvatarSum() >= ActorEditMgr.avatarBindSumMax then
        ShowGameTips(GetS(12534));
        return;
    end
    ActorEditMgr:UpdateActorEditSelectModelFrame(1, "add");
end
-------------------------------ActorEditFrameMotionFrame-------------------------
function ActorEditMotionBtnTemplate_OnClick()
    ActorEditMgr:UpdateActorEditMotionFrame(this:GetClientID()-100099);
end

function ActorEditFrameMotionFrame_OnHide()
    print("kekeke ActorEditFrameMotionFrame_OnHide", ActorEditMgr.curSelectMotionIdx);
    local actorBody = CustomModelMgr:getActorBody();
    if actorBody and ActorEditMgr.curSelectMotionIdx > 0 then
        local oldId = getglobal("ActorEditFrameMotionFrameBoxMotion"..ActorEditMgr.curSelectMotionIdx):GetClientID();
        actorBody:stopAnimBySeqId(oldId);
    end
end
-------------------------------ActorEditFrameOperateFrame-------------------------
function ActorEditFrameOperateFrameSymmetryBtn_OnClick()
    local tickUI = getglobal("ActorEditFrameOperateFrameSymmetryBtnTick");
    if ActorEditMgr.symmetryOperate then
        ActorEditMgr.symmetryOperate = false;
        tickUI:Hide();
    else
        ActorEditMgr.symmetryOperate = true;
        tickUI:Show();
    end
end

function ActorEditOperateSliderTemplateLeftBtn_OnClick()
    local value = getglobal(this:GetParent().."Bar"):GetValue();
    local addVal = getglobal(this:GetParent().."Bar"):GetValueStep();
    value = value - addVal;
    getglobal(this:GetParent().."Bar"):SetValue(value);

    local index = this:GetParentFrame():GetClientID();
    ActorEditMgr:UpdateActorEditModelByOperate(value, index);
    if ActorEditMgr.symmetryOperate then
        ActorEditMgr:UpdateBySymmetryOperate(-addVal, index)
    end
end

function ActorEditOperateSliderTemplateRightBtn_OnClick()
    local value = getglobal(this:GetParent().."Bar"):GetValue();
    local addVal = getglobal(this:GetParent().."Bar"):GetValueStep();
    value = value + addVal
    getglobal(this:GetParent().."Bar"):SetValue(value);

    local index = this:GetParentFrame():GetClientID();
    ActorEditMgr:UpdateActorEditModelByOperate(value, index);
    if ActorEditMgr.symmetryOperate then
        ActorEditMgr:UpdateBySymmetryOperate(addVal, index)
    end
end

function ActorEditOperateSliderTemplateBar_OnValueChanged()
    local value = this:GetValue();
    local ratio = (value-this:GetMinValue())/(this:GetMaxValue()-this:GetMinValue());

    if ratio > 1 then ratio = 1 end
    if ratio < 0 then ratio = 0 end
    local width   = math.floor(204*ratio)
    getglobal(this:GetName().."Pro"):ChangeTexUVWidth(width);
    getglobal(this:GetName().."Pro"):SetWidth(width);

    local valFont = getglobal(this:GetParent().."Val");
    if ActorEditMgr.curOperateBtnName == "ActorEditFrameScaleBtn" then
        value = string.format("%.1f", value);
    end

    valFont:SetText(value);

    local index = this:GetParentFrame():GetClientID();
    if arg2 == 1 then
        ActorEditMgr:UpdateActorEditModelByOperate(value, index);
    end

    if arg2 == 1 and ActorEditMgr.symmetryOperate then
        local addVal = value - arg1;
        ActorEditMgr:UpdateBySymmetryOperate(addVal, index)
    end
end
--------------------------------ActorEditSelectModelFrame----------------------------
function ActorEditSelectModelFrameCloseBtn_OnClick()
    getglobal("ActorEditSelectModelFrame"):Hide();
end

function ActorEditSelectModelFrameOkBtn_OnClick()
    local filename = getglobal("ActorEditSelectModelFrameOkBtn"):GetClientString();--选中的微雕模型文件名
    print("kekeke ActorEditSelectModelFrameOkBtn_OnClick", filename);
    if filename ~= "" then
        if CustomModelMgr:isDownloadCM(filename) then
            MessageBox(5, GetS(16130), function(btn)
                    if btn == "left" then              --确定
                        ActorEditSelectModelHandle(filename);
                    elseif btn == "right" then
                    end
                end
            );
        else
            ActorEditSelectModelHandle(filename);
        end
    end
end

function ActorEditSelectModelHandle(filename)
     --选中资源库的微雕要把资源文件拷贝到地图库里
     if CurWorld and ActorEditMgr.curSelectTapsIndex == 2 then
        CustomModelMgr:copyModelFileByMod(CurWorld:getOWID(), filename);
    end
    if ActorEditMgr.curSelectOpetateType == "add" then
        ActorEditMgr:ActorBindModel(filename);
    else
        ActorEditMgr:UpdateBindModel(filename);
    end

    getglobal("ActorEditSelectModelFrameOkBtn"):SetClientString("");
end

function ActorEditSelectModelListFrameBackBtn_OnClick()
    getglobal("ActorEditSelectModelListFrame"):Hide();
    getglobal("ActorEditSelectModelClassBox"):Show();
end

function ActorEditSelectModelFrame_OnLoad()
    getglobal("ActorEditSelectModelFrameTabs1Name"):SetText(GetS(3698));
    getglobal("ActorEditSelectModelFrameTabs2Name"):SetText(GetS(3627));

    for i=1, 48/4 do
        for j=1, 4 do
            local index = (i-1)*4+j;
            local classUI = getglobal("ActorEditSelectModelClass"..index);
            classUI:SetPoint("topleft", "ActorEditSelectModelClassBoxPlane", "topleft", (j-1)*187, (i-1)*215);
        end
    end

    for i=1, 440/8 do
        for j=1, 8 do
            local index = (i-1)*8+j;
            local itemUI = getglobal("ActorEditSelectModelGrid"..((i-1)*8+j));
            itemUI:SetPoint("topleft", "ActorEditSelectModelListBoxPlane", "topleft", (j-1)*92, (i-1)*92);
        end
    end
end

---------------------------------ActorEditFrameConfirmMakeFrame----------------------------------------

function ActorEditFrameConfirmMakeFrameMakeBtn_OnClick()
    local name = getglobal("ActorEditFrameConfirmMakeFrameName"):GetText();
    if CheckFilterString(name) then	--敏感词
        ShowGameTips(GetS(121), 3);
        return;
    end

	if CustomModelMgr.isSecondaryCreationByEditActor and CustomModelMgr:isSecondaryCreationByEditActor() then
		MessageBox(5, GetS(16130), function(btn)
				if btn == "left" then              --确定
					if CurMainPlayer then
                        ActorEditFrameModelViewDetachActorBody() -- code_by:huangfubin 2021.10.12
                        CurMainPlayer:closeEditActorModel(1, name);
                        ActorEditMgr.curCloseType = ActorEditMgr.CloseTypeENUM.SAVE_CLOSE;
                    end
                    getglobal("ActorEditFrame"):Hide();
				elseif btn == "right" then
				end
			end
		);
	else
		if CurMainPlayer then
            ActorEditFrameModelViewDetachActorBody() -- code_by:huangfubin 2021.10.12
            CurMainPlayer:closeEditActorModel(1, name);
            ActorEditMgr.curCloseType = ActorEditMgr.CloseTypeENUM.SAVE_CLOSE;
        end
        getglobal("ActorEditFrame"):Hide();    
    end
    reLoadBackPackDevDef = true
    OnChangeResourceData()
end

function ActorEditFrameConfirmMakeFrameCancleBtn_OnClick()
    getglobal("ActorEditFrameConfirmMakeFrame"):Hide();
end

---------------------------LoadEditableActorModelFrame----------------------------------------------------------

function LoadEditableActorModelSlotTemplate_OnClick()
    if ActorEditMgr.curSelEditableModelIdx > 0 then
        getglobal("LoadEditableActorModelSlot"..ActorEditMgr.curSelEditableModelIdx.."Checked"):Hide();
    end

    getglobal(this:GetName().."Checked"):Show();
    ActorEditMgr.curSelEditableModelIdx = this:GetClientID();
end

function LoadEditableActorModelFrameLoadBtn_OnClick()
    print("kekeke LoadEditableActorModelFrameLoadBtn_OnClick", ActorEditMgr.t_EditableActorModel, ActorEditMgr.curSelEditableType, ActorEditMgr.curSelEditableModelIdx)
    if ActorEditMgr.t_EditableActorModel[ActorEditMgr.curSelEditableType][ActorEditMgr.curSelEditableModelIdx] then
        local modelMark = ActorEditMgr.t_EditableActorModel[ActorEditMgr.curSelEditableType][ActorEditMgr.curSelEditableModelIdx].modelmark;
        CustomModelMgr:loadEditableCustomActorModel(modelMark);

        local actorBody = CustomModelMgr:getActorBody();
        if actorBody then
            if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
                getglobal("ActorSelectEditFrameModelView"):detachActorBody(actorBody)
            else
                actorBody:detachUIModelView(getglobal("ActorSelectEditFrameModelView"));
            end
        end

        actorBody = CustomModelMgr:getOrCreateCurEditActorBody(DEFAUT_MODEL);
        if actorBody then
            if MODELVIEW_DECOUPLE_FROM_ACTORBODY then
                getglobal("ActorSelectEditFrameModelView"):attachActorBody(actorBody)
            else
                actorBody:attachUIModelView(getglobal("ActorSelectEditFrameModelView"));
            end
        end

        getglobal("LoadEditableActorModelFrame"):Hide();
        ActorSelectEditFrameCreateOrEditBtn_OnClick();
    end
end

function LoadEditableActorModelFrameCloseBtn_OnClick()
    getglobal("LoadEditableActorModelFrame"):Hide();
end

function LoadEditableActorModelFrameTypeFrameBtn_OnClick()
    local btnName = this:GetName();
    if string.find(btnName, "Local") and ActorEditMgr.curSelEditableType ~= "map" then
        ActorEditMgr.curSelEditableType = "map";
        ActorEditMgr:UpdateLoadEditableActorModelFrame("map");
    elseif string.find(btnName, "Res") and ActorEditMgr.curSelEditableType ~= "res" then
        if IsRoomClient() then
            ShowGameTips(GetS(3945, 3));
            return;
        end
        ActorEditMgr.curSelEditableType = "res";
        ActorEditMgr:UpdateLoadEditableActorModelFrame("res");
    end
end

function LoadEditableActorModelFrame_OnLoad()
    for i=1, ActorEditMgr.editableActorModelMax/6 do
        for j=1, 6 do
            local slotUI = getglobal("LoadEditableActorModelSlot"..(i-1)*6+j);

            slotUI:SetPoint("topleft", "LoadEditableActorModelSlotBoxPlane", "topleft", (j-1)*125, (i-1)*141+10);
        end
    end

    getglobal("LoadEditableActorModelFrameTypeFrameLocalBtnName"):SetText(GetS(3698));
    getglobal("LoadEditableActorModelFrameTypeFrameResBtnName"):SetText(GetS(3627));
end

function LoadEditableActorModelFrame_OnShow()
    ActorEditMgr:InitLoadEditableActorModel();
    ActorEditMgr:UpdateLoadEditableActorModelFrame("map");
end