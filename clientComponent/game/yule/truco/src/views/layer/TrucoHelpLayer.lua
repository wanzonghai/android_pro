-- 帮助界面

local GameDialogBase = appdf.req("game.yule.truco.src.views.layer.TrucoDialogBase")
local GameHelpLayer = class("GameHelpLayer", GameDialogBase)

function GameHelpLayer:ctor()
    tlog('GameHelpLayer:ctor')
    GameHelpLayer.super.ctor(self)
	local csbNode = g_ExternalFun.loadCSB("UI/TrucoHelpNode.csb", self, false)
	self.m_spBg = csbNode:getChildByName("TrusteeBg")
	--关闭按钮
	local btn = self.m_spBg:getChildByName("Button_cancel")
	btn:addClickEventListener(function ()
		self:removeFromParent()
	end)
	-- local pageView = self.m_spBg:getChildByName("PageView_1")
	-- pageView:setIndicatorEnabled(true)
	-- tdump(pageView:getIndicatorPosition())
	-- pageView:setIndicatorPosition(cc.p(pageView:getContentSize().width * 0.5, -20))
	
	-- local panel_item = self.m_spBg:getChildByName("Panel_1")
	-- panel_item:setTouchEnabled(false)

	-- for i = 1, 3 do
	-- 	local panel = panel_item:clone():show()
	-- 	local imageHelp = panel:getChildByName("Image_1")
	-- 	imageHelp:loadTexture(string.format("GUI/help/truco_gz_sm%d.png", i))
	-- 	-- imageHelp:setContentSize(imageHelp:getVirtualRendererSize())
	-- 	pageView:addPage(panel)
	-- end

end

return GameHelpLayer