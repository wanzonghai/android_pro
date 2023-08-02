

--plinkoHelpLayer
local helpLayer = class("helpLayer",ccui.Layout)

function helpLayer:ctor(p_node)
    self.m_pNode = p_node
    local csbNode = cc.CSLoader:createNode("UI/plinkoHelpLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    self:init()
end

function helpLayer:init()
    self.mm_btn_close:onClicked(function() self:removeSelf() end)
    self.mm_Panel_1:addClickEventListener(function() self:removeSelf() end)
end

return helpLayer