local GameRuleLayer = class("GameRuleLayer", function(parent)
		local GameRuleLayer = display.newLayer()
    return GameRuleLayer
end)

function GameRuleLayer:ctor(parent)
    parent = parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,10)
    local csbNode = g_ExternalFun.loadCSB("game/yule/baccarat/res/UI/RuleLayer.csb")
    self:addChild(csbNode)
    self.node = csbNode:getChildByName("nodeRule")
    ShowCommonLayerAction(nil,self.node)
    csbNode:getChildByName("btnPanel"):onClickEnd(handler(self,self.onClickClose),true)
    self.node:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
end
function GameRuleLayer:onClickClose()
    DoHideCommonLayerAction(nil,self.node,function() self:removeSelf() end)
end

return GameRuleLayer