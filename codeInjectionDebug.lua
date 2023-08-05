package.loaded["res/ui/mobile/codeInjectionDebugHelp/codeInjectionDebugHelp"] = nil;
local DH = require("res/ui/mobile/codeInjectionDebugHelp/codeInjectionDebugHelp");
-- DH:Print("xxxxxxxxxxxxxxxxxxxxxxx");
-- DH:HotFixMvc("TempMapTrace",true);
-- DH:HotFixMvcClass("TempMapTraceCtrl",true);
print("ddddddddddddddddddd")


-- local __private = ClassList.main_minimapView.__private;
-- local main_minimapView	=  ClassList.main_minimapView;

local __private = ClassList.PixelMapShowLogic.__private;
-- local PixelMapShowLogic	=  ClassList.PixelMapShowLogic;

-- -- ClassList.main_mapCtrl
-- local __private = ClassList.PixelMapMarkerLogic.__private;
-- local PixelMapMarkerLogic =  ClassList.PixelMapMarkerLogic;
-- function __private.initUI(self)
--     __private.initMarkerInfoItem(self);

--     --初始化 标记
--     for k,v in pairs(self.m_officialMaker) do
--          __private.createMarkerNode(self,v);
--     end

--     for k,v in pairs(self.m_localDataChunk.markData) do
--          __private.createMarkerNode(self,v);
--     end

--     __private.refreshTraceNode(self);
--     __private.refreshMarkerCounterNode(self);
-- end

function __private.getOrCreateLoader(self,x,y)
    local isNew = false;
    local nodeName = __private.getNodeMapUnitName(self,x,y);
    local parentNode = self.view.mm_map_window;
    local loader = self.view.mm_map_window:getChild(nodeName);
    if not loader then
        __private.checkAndDelFarNode(self);
        loader = tolua.cast(GLoader:create(),'miniui.GLoader');
        loader:setSize(self.UNIT_MAP_DIM, self.UNIT_MAP_DIM);
        loader:setName(nodeName);
        parentNode:addChild(loader);
        loader:addRelation(parentNode, Left_Left_RelationType, true);
        loader:addRelation(parentNode, Top_Top_RelationType, true);
        loader:addRelation(parentNode, Size_RelationType, false);
        loader:setFill(5);
        local posx, posy= __private.getUIPosByMapUnitPos(self,x,y)
        loader:setPosition(posx, posy);
        self.m_allMapUnits[#self.m_allMapUnits+1] = {x = x,y = y,node = loader};
        isNew = true;
    end
    return loader,isNew;
end

function __private.AdjustMap(self)
    --父节点大小位置调整
    self.view.mm_map_window:setSize(__private.float2Int(self,self.view.mm_map_window:getWidth()),__private.float2Int(self,self.view.mm_map_window:getHeight()));
    self.view.mm_map_window:setPosition(__private.float2Int(self,self.view.mm_map_window:getX()),__private.float2Int(self,self.view.mm_map_window:getY()));
    --子节点位置大小调整
    local size = self.view.mm_map_window:getSize();
    for k,v in pairs(self.m_allMapUnits) do
        local node = v.node;
        node:setSize(size.width,size.height);
        node:setPosition(__private.float2Int(self,node:getX()),__private.float2Int(self,node:getY()));
    end
end

local main_mapCtrl = ClassList.main_mapCtrl;
-- local __private = ClassList.main_mapCtrl.__private;
function main_mapCtrl:Btn_closeClick(obj, context)
	-- __private.PrintPosAndSize(self.m_pixmapLogic,self.view.mm_map_window,true)
    __private.AdjustMap(self.m_pixmapLogic);
end