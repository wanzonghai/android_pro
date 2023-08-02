--[[
***
***
]]
local HallChatLayer = class("HallChatLayer",function(args)
		local HallChatLayer =  display.newLayer()
    return HallChatLayer
end)

function HallChatLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("chat/ChatLayer.csb")
    self:addChild(csbNode)
    self.nodeChat = csbNode:getChildByName("panel"):getChildByName("nodeChat")
    self.nodeChat:getChildByName("btnClose"):onClickEnd(function() self:onClickClose() end,1)
    self.scrollview = self.nodeChat:getChildByName("scrollview")
    self.scrollview:setScrollBarEnabled(false)
    self.inputChat = self.nodeChat:getChildByName("inputChat"):convertToEditBox()
    self.inputChat:setTouchEnabled(GlobalUserItem.chatAllow == true)
    local btnSend = self.nodeChat:getChildByName("btnSend")
    btnSend:onClicked(function() self:onClickSend() end)
    btnSend:setEnabled( GlobalUserItem.chatAllow == true)

    self.nodeChat:setPositionX(-550)
    TweenLite.to(self.nodeChat,0.2,{ x=0,ease = Sine.easeOut})
end
function HallChatLayer:onClickClose()
    local onComplete = function()
        self:removeSelf()
    end
    TweenLite.to(self.nodeChat,0.1,{ x=-550,ease = Sine.easeOut,onComplete = onComplete})
end

function HallChatLayer:onClickSend()
    local txt = self.inputChat:getString()
    if txt == "" then
        showToast(g_language:getString("chat_content_empty"))  
        return
    end
    --
end
--更新内容
function HallChatLayer:onUpdateContent()
    
end

return HallChatLayer