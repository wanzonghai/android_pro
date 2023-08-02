--[[
***
***选择验证方式页面  CPF or 短信验证
]]
local AuthenticatorLayer =
    class(
    "AuthenticatorLayer",
    function(args)
        local AuthenticatorLayer = display.newLayer()
        return AuthenticatorLayer
    end
)
function AuthenticatorLayer:onExit()
    
end
function AuthenticatorLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)

    local csbNode = g_ExternalFun.loadCSB("message/AuthenticatorLayer.csb")
    self:addChild(csbNode)

    self.bg = csbNode:getChildByName("bg")
    self.content = csbNode:getChildByName("content")
    ShowCommonLayerAction(self.bg, self.content)

    self.bg:onClicked(handler(self, self.onClickClose), true)
    self.content:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
   
    

    self.content:getChildByName("cpfBtn"):onClicked(
        function()
            G_event:NotifyEvent(G_eventDef.UI_SHOW_CPF)
        end,
        true
    )

    self.content:getChildByName("phoneBtn"):onClicked(
        function()
            G_event:NotifyEvent(G_eventDef.UI_SHOW_MESSAGE)
        end,
        true
    )

    
end




function AuthenticatorLayer:onClickClose()
    DoHideCommonLayerAction(
        self.bg,
        self.content,
        function()
            self:removeSelf()
        end
    )
end

return AuthenticatorLayer
