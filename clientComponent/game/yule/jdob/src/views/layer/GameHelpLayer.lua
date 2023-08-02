-- 帮助界面

local GameDialogBase = appdf.req("game.yule.jdob.src.views.layer.GameDialogBase")
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
end

return GameHelpLayer