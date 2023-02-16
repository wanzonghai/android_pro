-- 帮助界面

local CarnivalDialogBase = appdf.req("game.yule.carnival.src.views.layer.CarnivalDialogBase")
local CarnivalHelpLayer = class("CarnivalHelpLayer", CarnivalDialogBase)

function CarnivalHelpLayer:ctor()
    tlog('CarnivalHelpLayer:ctor')
    CarnivalHelpLayer.super.ctor(self)
    local csbNode = g_ExternalFun.loadCSB("UI/CarnivalHelpLayer.csb", self, false)
    self.m_spBg = csbNode:getChildByName("Image_bg")
    --关闭按钮
    local btn = self.m_spBg:getChildByName("Button_1")
    btn:addClickEventListener(function ()
        self:removeFromParent()
    end)

    local pageView = self.m_spBg:getChildByName("PageView_1")
    pageView:setIndicatorEnabled(true)
    pageView:setBounceEnabled(true)
    pageView:setIndicatorIndexNodesTexture("GUI/jnh_rule_index.png")
    pageView:setIndicatorSpaceBetweenIndexNodes(20)
    pageView:setIndicatorPosition(cc.p(pageView:getContentSize().width * 0.5, 20))
	pageView:setIndicatorSelectedIndexColor(cc.c3b(255, 255, 255))
	for i = 1, 4 do
		local panel_item = self.m_spBg:getChildByName(string.format("Panel_%d", i))
		panel_item:retain()
		panel_item:removeFromParent()
		pageView:insertPage(panel_item, i - 1)
		panel_item:release()
	end
end

return CarnivalHelpLayer