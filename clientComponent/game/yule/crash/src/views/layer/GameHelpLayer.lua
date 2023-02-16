-- 帮助界面

local GameDialogBase = appdf.req("game.yule.crash.src.views.layer.GameDialogBase")
local GameHelpLayer = class("GameHelpLayer", GameDialogBase)

function GameHelpLayer:ctor()
    tlog('GameHelpLayer:ctor')
    GameHelpLayer.super.ctor(self)
	local csbNode = g_ExternalFun.loadCSB("UI/GameHelpLayer.csb", self)
	self.m_spBg = csbNode:getChildByName("Image_1")
	--关闭按钮
	local btn = self.m_spBg:getChildByName("Button_cancel")
	btn:addClickEventListener(function ()
		self:removeFromParent()
	end)
	-- self.m_spBg:getChildByName("ScrollView_1"):setScrollBarEnabled(false)
end

return GameHelpLayer