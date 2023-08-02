local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local ShareStepLayer = class("ShareStepLayer",BaseLayer)

function ShareStepLayer:ctor(args)
    ShareStepLayer.super.ctor(self)
    display.loadSpriteFrames("client/res/ShareTurnTable/ShareTurnTableGUI.plist","client/res/ShareTurnTable/ShareTurnTableGUI.png")
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self.NoticeNext = args and args.NoticeNext
    self:loadLayer("ShareTurnTable/ShareStepLayer.csb")
    self:init()
    ShowCommonLayerAction(nil,self.content)
end

function ShareStepLayer:onExit()
    ShareStepLayer.super.onExit(self)
    if self.NoticeNext then
        G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="ShareStepLayer"})
    end
end

function ShareStepLayer:init()
    self.closeBtn = self:getChildByName("closeBtn")
    self.inviteBtn = self:getChildByName("inviteBtn")
    self.content = self:getChildByName("bg1")
    self.bg = self:getChildByName("bg")
    if self.NoticeNext then
        self.inviteBtn:show()
    else
        self.inviteBtn:hide()
    end
    self.closeBtn:addTouchEventListener(handler(self,self.onTouch))
    self.inviteBtn:addTouchEventListener(handler(self,self.onTouch))
    self.bg:addTouchEventListener(handler(self,self.onTouch))
end

function ShareStepLayer:onTouch(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        local name = sender:getName()
        if name == "bg" then
            self:close()
        elseif name == "closeBtn" then
            self:close()
        elseif name == "inviteBtn" then
            self:close()
            G_ServerMgr:requestTurnTableUserStatus()
        end
    end
end

return ShareStepLayer