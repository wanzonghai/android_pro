-- 帮助界面

local GameDialogBase = appdf.req("game.yule.snowwomen.src.views.layer.GameDialogBase")
local GameHelpLayer = class("GameHelpLayer", GameDialogBase)

function GameHelpLayer:ctor()
    tlog('GameHelpLayer:ctor')
    GameHelpLayer.super.ctor(self)
	local csbNode = g_ExternalFun.loadCSB("UI/GameHelpLayer.csb", self, false)
	self.m_spBg = csbNode:getChildByName("bgrule_frame_1")
	--关闭按钮
	local btn = csbNode:getChildByName("Button_1")
	btn:addClickEventListener(function ()
		self:removeFromParent()
	end)

	local pageView = csbNode:getChildByName("PageView_1")
    pageView:setIndicatorEnabled(true)
    pageView:setBounceEnabled(true)
    pageView:setIndicatorIndexNodesTexture("GUI/jnh_rule_index.png")
    pageView:setIndicatorSpaceBetweenIndexNodes(20)
    pageView:setIndicatorPosition(cc.p(pageView:getContentSize().width * 0.5, 0))
	pageView:setIndicatorSelectedIndexColor(cc.c3b(255, 255, 255))
	local panelTb = {}
	for i = 1, 2 do
		local panel_item = pageView:getChildByName(string.format("Panel_content%d", i))
		panel_item:retain()
		table.insert(panelTb, panel_item)
	end
	pageView:removeAllPages()
	for i = 1, 2 do
		local panel_item = panelTb[i]
		pageView:insertPage(panel_item, i - 1)
		panel_item:release()
	end
end

return GameHelpLayer