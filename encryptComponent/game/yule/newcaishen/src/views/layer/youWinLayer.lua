
local youWinLayer = class("youWinLayer",ccui.Layout)
local module_pre = "game.yule.newcaishen.src"
local logic = appdf.req(module_pre .. ".models.GameLogic")

function youWinLayer:ctor(p_node,callback)
    self.m_pNode = p_node
    self.callback = callback
    local csbNode = cc.CSLoader:createNode("UI/youWinLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    self.m_csbNode = csbNode
    local serverKind = G_GameFrame:getServerKind()
    self.mm_BitmapFontLabel_1:setString(g_format:formatNumber(self.m_pNode.winScore,g_format.fType.standard,serverKind))
    self.mm_btn_continue:onClicked(function() self:onExit() end)
    local size = self.mm_Image_bg:getContentSize()
    local pos = cc.p(size.width/2,size.height/2)
    self.m_pNode:playSpine(self.mm_Image_bg,logic.iconAnimName["total_idle"][1],logic.iconAnimName["total_idle"][2],pos)
    self.m_pNode:playSpine(self.mm_Node_anim,logic.iconAnimName["total_appear"][1],logic.iconAnimName["total_appear"][2])

    performWithDelay(self,function() self:onExit() end,5)
end

function youWinLayer:onExit()
    if self.callback then
        self.callback()
    end
    self:removeSelf()
end

return youWinLayer