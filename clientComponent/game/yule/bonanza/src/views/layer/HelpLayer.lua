-- 帮助界面

local BonanzaDialogBase = appdf.req("game.yule.bonanza.src.views.layer.BonanzaDialogBase")
local HelpLayer = class("HelpLayer", BonanzaDialogBase)

function HelpLayer:ctor()
    tlog('HelpLayer:ctor')
    HelpLayer.super.ctor(self)
    local csbNode = g_ExternalFun.loadCSB("UI/Node_helpLayer.csb", self, false)
    self.m_spBg = csbNode:getChildByName("Image_bg")
    --关闭按钮
    local btn = self.m_spBg:getChildByName("Button_1")
    btn:addClickEventListener(function ()
        self:removeFromParent()
    end)
end

return HelpLayer