local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local cashOutTipsLayer = class("cashOutTipsLayer",BaseLayer)


function cashOutTipsLayer:ctor()
    cashOutTipsLayer.super.ctor(self)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self:loadLayer("cashOut/cashOutTips.csb")
    self:init()
    ShowCommonLayerAction(self.bg,self.content)
end     

function cashOutTipsLayer:init()
    self:initView()
    self:initListener()
end

function cashOutTipsLayer:initView()
    self.bg = self:getChildByName("bg")
    self.content = self:getChildByName("content")
    self.closeBtn = self:getChildByName("closeBtn")
    self.rechargeBtn = self:getChildByName("rechargeBtn")
end

function cashOutTipsLayer:initListener()
    self.closeBtn:addTouchEventListener(handler(self,self.onTouch))
    self.rechargeBtn:addTouchEventListener(handler(self,self.onTouch))
end

function cashOutTipsLayer:onTouch(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        local name = sender:getName()
        if name == "closeBtn" then
            self:close()
        elseif name == "rechargeBtn"  then
            local scene = cc.Director:getInstance():getRunningScene()
            local CashOutLayer = scene:getChildByName("CashOutLayer")
            if CashOutLayer then
                local callback = function()
                    if CashOutLayer.quitCallback then
                        CashOutLayer.quitCallback()
                    end
                    CashOutLayer:removeSelf()
                end
                callback()
            end
            G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,{ShowType = 1})
            self:close()
        end
    end
end

return cashOutTipsLayer