-- 玩家收益展示提示

local GameDialogBase = appdf.req("game.yule.double.src.views.layer.GameDialogBase")
local GameResultShowNode = class("GameResultShowNode", GameDialogBase)
local g_scheduler = cc.Director:getInstance():getScheduler()

function GameResultShowNode:ctor(_winMoney, _endIndex)
    tlog('GameResultShowNode:ctor ', _winMoney, _endIndex)
    GameResultShowNode.super.ctor(self)

	local csbNode = g_ExternalFun.loadCSB("UI/GameResultNode.csb", self, false)
	self.m_spBg = csbNode:getChildByName("content")

    if _endIndex == 0 then
        strFile = "GUI/blaze_item_11.png"
    elseif _endIndex < 8 then
        strFile = "GUI/blaze_zuixindisexiaodede_bg.png"
    else
        strFile = "GUI/blaze_zuixindisexiao_bg.png"
    end
    local _winText = self.m_spBg:getChildByName("win_money")
    _winText:getChildByName("Image_icon"):loadTexture(strFile)

    _winMoney = g_format:formatNumber(_winMoney,g_format.fType.standard)
    _winText:setString(string.format("Win:+%s", _winMoney))

    csbNode:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function ()
        tlog("GameResultShowNode auto remove")
        self:removeFromParent()
    end)))
end

return GameResultShowNode