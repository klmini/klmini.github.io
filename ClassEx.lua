--生成类的方法
ClassList = {}
function Class(className,super)
    CheckMiniUiLuaLoading(className)
    local curClass = {}
    curClass.className = className
    curClass.type = "class"
    curClass.super = super

    if ClientMgr:isPC() and ClientMgr:getApiId() == 999 then
        local _path = debug.getinfo(2, "S").source;
        local __pre = string.sub(_path,1,4);
        if __pre == "@res" then
            _path = string.sub(_path,2,-1);
        elseif __pre == "res/" then

        else
            _path = "res/".._path;
        end
        curClass.___classPath___ = _path;
    end

    local function getInstance(param)
        local instance = {}
        setmetatable(instance,{__index = curClass})

        local function create(tempClass,param)
            if tempClass.super then 
                tempClass.super = tempClass.super.new(param)
                tempClass.super.className = className
                setmetatable(tempClass,{__index = tempClass.super})
                create(tempClass.super,param)
            end 
            if tempClass.Init then 
                tempClass:Init(param)
            end 
        end 

        create(curClass,param)

        return instance
    end

    curClass.new = function(param)
        if curClass.GetInst then
            --单例类不能通过NEW的方式创建
            print("单例类不能通过NEW的方式创建")
            return nil
        end 
        return getInstance(param)
    end

    curClass.instance = function(param)
        return getInstance(param)
    end

    ClassList[curClass.className] = curClass

    return curClass
end

--原实现在实例化init的时候传入的是类并非对象
--新实现在实例化init的时候传入的是对象
--主要改动是 getInstance 函数的实现
function ClassEx(className,super)
    CheckMiniUiLuaLoading(className)
    local curClass = {}
    curClass.className = className
    curClass.type = "class"
    curClass.super = super

    if ClientMgr:isPC() and ClientMgr:getApiId() == 999 then
         local _path = debug.getinfo(2, "S").source;
        local __pre = string.sub(_path,1,4);
        if __pre == "@res" then
            _path = string.sub(_path,2,-1);
        elseif __pre == "res/" then

        else
            _path = "res/".._path;
        end
        curClass.___classPath___ = _path;
    end

    local function getInstance(param)
        local instance = {}
        setmetatable(instance,{__index = curClass})

        local function create(tempClass,param)
            if tempClass.super then 
                setmetatable(tempClass,{__index = tempClass.super})
                create(tempClass.super,param)
            end 
            if tempClass.Init then 
                tempClass.Init(instance,param)
            end 
        end 

        create(curClass,param)

        return instance
    end

    curClass.new = function(param)
        if curClass.GetInst then
            --单例类不能通过NEW的方式创建
            print("单例类不能通过NEW的方式创建")
            return nil
        end 
        return getInstance(param)
    end

    curClass.instance = function(param)
        return getInstance(param)
    end

    ClassList[curClass.className] = curClass

    return curClass
end

--获取单例类实例
function GetInst(name)   
    if name == nil or  ClassList[name] == nil then
        Log('======GetInst'..name..' is nil =======')
        return  nil
    end     
    return ClassList[name]:GetInst()
end

--检测fgui 相关配置文件加载时候
function CheckMiniUiLuaLoading(className)
    if ClientMgr:isPureServer() then
        return
    end
    if g_LuaPreLoadMgr:GetCurrentLoadingNewUILuaFileType() then
        if ClassList[className] then
            --只有pc官版本和内网进行检测提示
            if ClientMgr:isPC() and ClientMgr:getApiId() == 999 and get_game_env() == 1 then
                local filepath = "res/"..g_LuaPreLoadMgr:GetCurrentLoadingLuaFile();
                if filepath ~=ClassList[className].___classPath___ then
                    local tipstr= filepath.."中"..className.."类重复"
                    ShowGameTipsWithoutFilter(tipstr)
                    print("加载 lua.toc 时 "..tipstr);
                else
                    local tipstr= filepath.."中"..className.."类重复加载"
                    ShowGameTipsWithoutFilter(tipstr)
                    print("加载 lua.toc 时 "..tipstr);
                end
            end
           
        end
    end
end
