
local ReloadClass = {}
local uiManager = GetInst("UIManager")
local ls = nil

local function getV(modelName,isNew)
	
	if isNew then
		ls = GetInst("MiniUIManager"):GetUI(modelName).view
	else
		ls = uiManager:GetCtrl("HomeMain").view
	end
	return ls
end
local function getC(modelName)
	ls = uiManager:GetCtrl(modelName)
	return ls
end
local function getM(modelName)
	ls = uiManager:GetCtrl(modelName).model
	return ls
end
ose = function()
	os.execute("pause") 
end

local function show(name)
	getglobal(name):Show()
end
local function hide(name)
	getglobal(name):Hide()
end



function gb(name)
	return getglobal(name)
end

--单独刷新lua文件,填入路径即可   如"res/universe/miniui/module/guideu1/MiniUIGuideDataHandler.lua"
local function reloadLua(path)
	gFunc_reloadLUA(path)
end

local function reloadFile(filePath)
    local temp = {}
    local autoGenPath = ""
    for index, value in pairs(ClassList) do
        local path = value.___classPath___
        local str = path:gsub( value.className..".lua","")
        if str==filePath then
            if path:find("AutoGen.lua") then
                autoGenPath = path
            else
                table.insert(temp,path)
            end
        end
    end
    --因为autoGen类有一些会在当前类定义MVC的接口，所以对加载顺序有先后要求，必须把autogen放最后面加载代码。
    for index, value in ipairs(temp) do
        gFunc_reloadLUA(value)--刷新lua代码
    end
    if autoGenPath~="" then
        gFunc_reloadLUA(autoGenPath)--刷新autogen代码
    end
end 

function reloadOldMVCLua(modelName)
	local xmlList = GetInst("UIManager").uiXmlPathList
	if xmlList[modelName] then
		xmlList[modelName].isLoaded = false
	end
	local xmlPath = GetInst("UIManager"):GetPath(modelName)
	local luaPath = xmlPath:gsub(".xml","")
	-- local temp = getC(modelName) or {}
	-- local copy = {}
	-- copy = TableDeepCopy(temp)
	if  GetInst("UIManager") then
		GetInst("UIManager"):DelCtrl( modelName )
	end
	reloadFile(xmlPath)
	-- local t = {"View","Model","Ctrl"}
	-- for index, value in ipairs(t) do
	-- 	reloadLua(string.format("%s%s.lua",luaPath,value))
	-- end
	
	-- if xmlList[modelName] then
	-- 	xmlList[modelName].isLoaded = false
	-- end
	GetInst("UIManager"):Open(modelName)
end
-- local Super = Component:create()
-- local BaseComponent = ClassNative("BaseComponent",Super)
-- ClassList["BaseComponent"] = BaseComponent
-- function BaseComponent:init()
-- 	Super.init(Super)
-- end
-- function BaseComponent:onEnter()
	
-- end
-- function BaseComponent:onExit()
	
-- end
--lua_pcall error
local MiniUIManager = GetInst("MiniUIManager")
function MiniUIManager:reloadNewMvc(modelName,packagePath,luaFileName,param)
    
	local classPath = ClassList[luaFileName].___classPath___
	local preFilePath = classPath:gsub(luaFileName..".lua","")
    local ta = utils.split(preFilePath,"/")
	-- local z = ""
	-- for index, value in pairs(ta) do
	-- 	if index<#ta then
	-- 		z = z..value.."/"
	-- 	end
	-- end
    -- preFilePath = z
	local filePath = classPath:gsub("res/","")
	self:CloseUI(luaFileName)--先隐藏界面以免最新代码报错导致界面关闭不了
	--------------刷新代码跟重新加载package资源---------------
	local path = packagePath
    UIPackage:removePackage(path)
	UIPackage:removePackage("universe/"..path)--卸载内存中加载的package资源,因为海外有另一个目录，一起刷新也没问题。
    
	reloadFile(preFilePath)--刷新同级目录下所有lua代码
	--------------刷新代码跟重新加载package资源---------------
	return self:OpenUI(modelName,packagePath,luaFileName,param)
	--显示界面 
end


function getcactus_forcex()
	
end


local manager = GetInst("MiniUIManager")
-- local mapCtrl = manager["uilist"]["IndependentPageAutoGen"].code.ctrl
-- local MapCommentView = mapCtrl.view
-- local MapCommentCtrl = mapCtrl
-- local bbbb  = GetInst("CommentSystemInterface")
function getPositionY()
	return 500
end
function F3621_SetAILua(actor, AITask, AITaskTarget)    
	-- actor:setCanRideByPlayer(false);
	-- actor:addAiTaskSwimming(1) --游泳
	-- actor:addAiTaskFollowDirection(1, 1.1)--寻找路径方块
	-- local AITargetAngry = AILuaTargetAngry:new(actor,1,1,1,30)
    -- AITask:addTask(AITargetAngry)
	local AIAngryAtkBack = AILuaCrabAttack:new(actor,2,1,1,50,5)
    AITask:addTask(AIAngryAtkBack)
	actor:addAiTaskWander(10, 1.4, 10)
	local AIHideInBlock = AILuaCrabHideInBlock:new(actor, 4, 1, 110, 6,20)--躲藏进方块中
    AITask:addTask(AIHideInBlock)
	-- local AIHideInBlock = AILuaCrabHideInBlock:new(actor, 4, 1, 110, 10,20)--躲藏进方块中
    -- AITask:addTask(AIHideInBlock)
	-- local AISitNearBlock = AILuaSitNearBlock:new(actor,4,1,1600,207,100)
    -- AITask:addTask(AISitNearBlock)
	-- local AIIdleSit = AILuaIdleSit:new(actor,7,1,3000,3000,30)
    -- AITask:addTask(AIIdleSit)
	-- actor:addAiLeapAtTarget(4, 40.0, 200, 400) --跳跃攻击
	-- actor:addAiTaskAtk(4, 0, true, 1.5) --近战攻击
	-- -- actor:addAiMate(2, 1.0, 1, 1, 822) --繁殖
	-- actor:addAiTaskBeg(7, 11302, 800) --喜欢食物
	-- actor:addAiTaskWatchClosest(9, 600) --看附近的玩家
	-- actor:addAiTaskWander(10, 1.0, 60) --闲逛
    -- actor:addAiTaskLookIdle(10, 60) --左右看看
	-- actor:addAiTaskTempt(3, 1.0, 11535, false)--被饲料吸引

    -- actor:addAITargetFollowingPlayer(3, 2, false, 1) --第二个参数是每tick首次查找玩家的概率, 第三个是是否可视当遮挡的时候就不跟踪了，第四个是跟随的速度    
    
end
isReturn = true
function ReloadClass.init()
	-- CurWorld:getActorMgr():findPlayerByUin
	local manager = GetInst("MiniUIManager")
	local index = _G.reloadIndex
	-- CurMainPlayer:getLivingAttrib():addBuff(230,1)
	-- ActorComponentCallModule(CurMainPlayer,"CarryComponent","setCarryItem",13621)
	-- ActorComponentCallModule(CurMainPlayer,"RiddenComponent","setRidingActor",target)
		-- ShowGameTips(DefMgr:getStringDef(158))          
	--_G.reloadIndex为上次刷新模块的下标，具体为shift+f4对应模块后面的数字，如果没手动刷新过默认取最 后一个调用OpenUI的新UI界面。
	--即便是shift+f4已经移除的界面,也可通过输入对应的下标刷新。
	local newUI = _G.chooseItem
	local path = "sandboxengine/gameAI/Task/"
	local ttt = {"AILuaTargetAngry","AILuaCrabAttack","AILuaCrabHideInBlock"}
	for index, value in ipairs(ttt) do
		gFunc_reloadLUA(path..value..".lua")	
	end
	if isReturn then
		do return end
	end
	-- addNewUI()
	
	local list = {"res/miniui/module/compose/craft/MiniUICraftMain.lua","res/miniui/module/compose/craft/MiniUICraftMainView.lua","res/miniui/module/compose/repair/MiniUIItemRepairMain.lua"}
	for index, value in ipairs(list) do
		gFunc_reloadLUA(value)
	end
	
	_G.refreshNode = manager:refreshModel(index)
end
function addNewUI(pkgPath,layerName)
	
	pkgpath = "miniui/miniworld/login"
	name = "main_register"
	if pkgPath then
		pkgpath = pkgPath
	end
	if layerName then
		name = layerName
	end
	UIPackage:removePackage(pkgpath)
	UIPackage:addPackage(pkgpath)
    local packagename = MiniUIGetPackageNameByPath(pkgpath)
    local node = UIPackage:createObject(packagename, name)
    if not node then
        return
    end
	local root = GetInst("MiniUISceneMgr"):getCurrentSceneRootNode()
	
	if rrNode then
		rrNode:removeFromParent()
	end
	
    -- 挂载到场景中
	node:setName(name)
    root:addChild(node)
	rrNode = node

	node:center(true)
	

	return node
end




return ReloadClass
