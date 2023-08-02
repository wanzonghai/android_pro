local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local RechargeQrCodeLayer = class("RechargeQrCodeLayer",BaseLayer)

function RechargeQrCodeLayer:ctor(args)
    RechargeQrCodeLayer.super.ctor(self)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self._args = args
    self:setName("RechargeQrCodeLayer")
    self:loadLayer("recharge/RechargeQrCodeLayer.csb")
    self:init()
end

function RechargeQrCodeLayer:init()
    self._countDown = 5 * 60
    self:initView()
    self:initListener()
end

function RechargeQrCodeLayer:initView()
    self.bg = self:getChildByName("bg")
    self.content = self:getChildByName("content")
    self.content1 = self:getChildByName("content1")
    self.circle = self.content1:getChildByName("circle")
    self.btnBack = self:getChildByName("btnBack")
    self.copyBtn = self:getChildByName("copyBtn")
    self.time1Text = self:getChildByName("time1Text")
    self.time2Text = self:getChildByName("time2Text")
    self.orderText = self:getChildByName("orderText")
    self.qrcodeText = self:getChildByName("qrcodeText")
    self.qrCodeImage = self:getChildByName("qrCodeImage")
    self.priceText = self:getChildByName("priceText")
    if not self._args then
        ShowCommonLayerAction(self.bg,self.content1)
        self.content:hide()
        self.circle:runAction(cc.RepeatForever:create(cc.RotateBy:create(2,360)))
        self.circle:runAction(cc.Sequence:create(
            cc.DelayTime:create(10),
            cc.CallFunc:create(function() 
                self:close()
            end)
        ))
    else
        self.content1:hide()
        self:doDisplay(self._args.timestamp,self._args.orderNo,self._args.qrCode,self._args.price)
    end
end

function RechargeQrCodeLayer:initListener()
    self.btnBack:addTouchEventListener(handler(self,self.onTouch))
    self.copyBtn:addTouchEventListener(handler(self,self.onTouch))
end

function RechargeQrCodeLayer:doDisplay(timestamp,orderNo,qrCode,price)
    ShowCommonLayerAction(self.bg,self.content)
    self.content1:hide()
    self.circle:stopAllActions()
    self.content:show()
    self.orderText:setString(orderNo)
    self.qrCode = qrCode
    self.qrcodeText:setString(self.qrCode)
    local node = QrNode:createQrNode(self.qrCode,300)
    self.qrCodeImage:addChild(node)
    -- if (not GlobalData.serverTime) or (not GlobalData.serverTime.llServerTime) then 
    --     self.time1Text:setString(os.date("%Y-%m-%d %H:%M:%S",os.time()))
    -- else
    --     self.time1Text:setString(os.date("%Y-%m-%d %H:%M:%S",GlobalData.serverTime.llServerTime  + GlobalData.serverTime.dwZone*3600))
    -- end
    self.time1Text:setString(os.date("%Y-%m-%d %H:%M:%S",timestamp))
    self.time2Text:setString(os.date("%H:%M:%S",self._countDown))
    self.priceText:setString(""..math.floor(price / 100))
    self:startCountdown()
end

function RechargeQrCodeLayer:onTouch(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        local name = sender:getName()
        if name == "btnBack" then
            self:close()
        elseif name == "copyBtn" then
            local res, msg = g_MultiPlatform:getInstance():copyToClipboard(self.qrCode)
            showToast("Copiar com sucesso,por favor abra PIX")  
        end
    end
end

function RechargeQrCodeLayer:startCountdown()
    local array = {
        cc.CallFunc:create(function() 
            self._countDown = self._countDown - 1
            if self._countDown < 0 then
                self:close()
                return
            end
            self.time2Text:setString(os.date("%M:%S",self._countDown))
        end),
        cc.DelayTime:create(1)
    }
    self:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))
end

return RechargeQrCodeLayer