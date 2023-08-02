local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local ShareConfirm = class("ShareConfirm",BaseLayer)

function ShareConfirm:ctor(args)
    ShareConfirm.super.ctor(self)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self:loadLayer("ShareTurnTable/ShareConfirm.csb")
    self:init()
end

function ShareConfirm:init()
    self:initView()
    ShowCommonLayerAction(self.bg,self.content)
end

function ShareConfirm:initView()
    self.bg = self:getChildByName("bg")
    self.content = self:getChildByName("content")
    self.inviteBtn = self:getChildByName("inviteBtn")
    self.closeBtn = self:getChildByName("closeBtn")
    self.closeBtn:addTouchEventListener(handler(self,self.onTouch))
    self.inviteBtn:addTouchEventListener(handler(self,self.onTouch))
end

function ShareConfirm:onTouch(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        local name = sender:getName()
        if name == "closeBtn" then
            self:close()
        elseif name == "inviteBtn" then
           -- G_ServerMgr:S2C_UpdateShareCount()
           G_event:NotifyEvent(G_eventDef.UI_SHOW_SHARE,GlobalUserItem.MAIN_SCENE)
        end
    end
end

return ShareConfirm