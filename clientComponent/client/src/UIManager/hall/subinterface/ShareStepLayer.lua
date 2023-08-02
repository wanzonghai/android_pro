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
    G_event:RemoveNotifyEvent(G_eventDef.RECEIVE_VIP_ANDGIFT2)
end

function ShareStepLayer:init()
    self.closeBtn = self:getChildByName("closeBtn")
    self.inviteBtn = self:getChildByName("inviteBtn")
    self.priceValue = self:getChildByName("priceValue")
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
    G_event:AddNotifyEvent(G_eventDef.RECEIVE_VIP_ANDGIFT2,handler(self,self.receiveVIPData))
    self:requestVip_And_GIFT()
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

function ShareStepLayer:requestVip_And_GIFT()
    if GlobalUserItem.VIPLevel == "0" then          --如果vip还没返回值，先请求一下
        G_ServerMgr:C2S_RequestUserGold()
    end

    if GlobalUserItem.share_vip_and_gift then
        self:setPriceValue()
    else
        showNetLoading()
        G_ServerMgr:receiveVIP_Gift()
    end
end

function ShareStepLayer:receiveVIPData(pData)   
    self:setPriceValue()
end

function ShareStepLayer:setPriceValue()
    local value = GlobalUserItem.share_vip_and_gift[2]
    value = g_format:formatNumber(value,g_format.fType.abbreviation,g_format.currencyType.GOLD)
    self.priceValue:setString(string.format("R$ %s",value))
end

return ShareStepLayer