-- 帮助界面

local GameDialogBase = appdf.req("game.yule.double.src.views.layer.GameDialogBase")
local GameHelpLayer = class("GameHelpLayer", GameDialogBase)

function GameHelpLayer:ctor()
    tlog('GameHelpLayer:ctor')
    GameHelpLayer.super.ctor(self)
	local csbNode = g_ExternalFun.loadCSB("UI/GameHelpLayer.csb", self, false)
	self.m_spBg = csbNode:getChildByName("Sprite_bg")
	--关闭按钮
	local btn = self.m_spBg:getChildByName("Button_1")
	btn:addClickEventListener(function ()
		self:removeFromParent()
	end)
end

return GameHelpLayer