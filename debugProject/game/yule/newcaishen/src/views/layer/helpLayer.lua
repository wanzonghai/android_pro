
local helpLayer = class("helpLayer",ccui.Layout)

function helpLayer:ctor(callback)
    local csbNode = cc.CSLoader:createNode("UI/helpLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    self.m_csbNode = csbNode
    self.mm_btn_close:onClicked(function() self:onExit(callback) end)
    self.mm_PageView_1:setIndicatorEnabled(true)
    self.mm_PageView_1:setIndicatorIndexNodesTexture("GUI/help/jnh_rule_index.png")
    self.mm_PageView_1:setIndicatorSpaceBetweenIndexNodes(20)
    self.mm_PageView_1:setIndicatorPosition(cc.p(self.mm_PageView_1:getContentSize().width * 0.5, 0))
	self.mm_PageView_1:setIndicatorSelectedIndexColor(cc.c3b(255, 255, 255))

    local panelTb = {}
	for i = 1, 3 do
		local panel_item = self["mm_Panel_page"..i]
		panel_item:retain()
		table.insert(panelTb, panel_item)
	end
	self.mm_PageView_1:removeAllPages()
	for i = 1, 3 do
		local panel_item = panelTb[i]
		self.mm_PageView_1:insertPage(panel_item, i - 1)
		panel_item:release()
	end
end

function helpLayer:onExit(callback)
    if callback then
        callback()
    end
    self:removeSelf()
end

return helpLayer