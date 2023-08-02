

local freeShowLayer = class("freeShowLayer",ccui.Layout)

function freeShowLayer:ctor(pNode,callback)
    self.m_pNode = pNode
    self.callback = callback    

    local csbNode = cc.CSLoader:createNode("UI/freeShowLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    self.m_csbNode = csbNode
    performWithDelay(self,function()  
        self:onExit()
    end,2)
end

function freeShowLayer:onExit()
    if self.callback then
        self.callback()
    end
    self:removeSelf()
end


return freeShowLayer