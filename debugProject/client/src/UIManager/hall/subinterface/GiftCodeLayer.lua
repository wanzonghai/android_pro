---------------------------------------------------
--Desc:验证码界面
---------------------------------------------------
local GiftCodeLayer = class("GiftCodeLayer",function(args)
	local GiftCodeLayer =  display.newLayer()
    return GiftCodeLayer
end)

function GiftCodeLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_GIFT_CODE_ACTIVE_RESULT)
    G_event:RemoveNotifyEventTwo(self, G_eventDef.NET_GET_GIFT_CODE_STATUS_RESULT)
end
function GiftCodeLayer:ctor(args)
    tlog("GiftCodeLayer:ctor")
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)    

    local bgLayer = display.newLayer(cc.c4b(0, 0, 0, 200))
    bgLayer:addTo(self)
    bgLayer:enableClick()

    local csbNode = g_ExternalFun.loadCSB("giftCode/GiftCodeLayer.csb")
    csbNode:setContentSize(display.width,display.height)
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)
    self:addChild(csbNode)    
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    local bg = csbNode:getChildByName("bg")

    --中间
    self.Panel_content = csbNode:getChildByName("Panel_content")
    ccui.Helper:doLayout(csbNode)

    --返回
    self.mm_btn_close = self.Panel_content:getChildByName("btn_close")
    self.mm_btn_close:onClicked(function() 
        local callback = function()
            self:removeSelf()
        end
        callback()
    end,true)
    
    --验证码输入
    self.inputCode = self.Panel_content:getChildByName("inputPsd1"):convertToEditBox()
    self.inputCode:setPlaceholderFontColor(cc.c3b(190,89,121))
    self.inputCode:setFontColor(cc.c4b(251,225,170,255))
    self.inputCode:registerScriptEditBoxHandler(function(eventType, pObj)
        tlog("self.inputCode:registerScriptEditBoxHandler",eventType)
        if eventType == "return" or eventType == "ended" then
            --local text = self.inputCode:getString()
        elseif eventType == "began" then
        end
    end)
    --确认按钮
    self.lastClickTick = 0
    self.btnConfirm = self.Panel_content:getChildByName("btn_confirm")
    self.btnConfirm:addTouchEventListener(handler(self, self.onConfirmClickedEvent))
        
    G_event:AddNotifyEvent(G_eventDef.NET_GIFT_CODE_ACTIVE_RESULT,handler(self,self.onGiftCodeActiveResult))   --激活码邀请卡
    G_event:AddNotifyEventTwo(self, G_eventDef.NET_GET_GIFT_CODE_STATUS_RESULT, handler(self,self.onGetGiftCodeStatusResult)) --激活码限时礼包商品列表返回

    self:getMyIP()
end

--激活码邀请卡返回处理
function GiftCodeLayer:onGiftCodeActiveResult(cmdData)
    tlog("GiftCodeLayer:onGiftCodeActiveResult")
    dismissNetLoading()
    if cmdData.dwErrorCode == 0 then
        --货币类型 1金币 101 限时购买礼包
        if cmdData.cbCurrencyType == 1 then
            self:showCommonGetGoldDialog(cmdData)
        else
            G_ServerMgr:C2S_GetGiftCodeStatus()
        end
    else
        showToast(g_language:getString(cmdData.dwErrorCode))
    end
end
--获取激活码限时礼包商品列表返回
function GiftCodeLayer:onGetGiftCodeStatusResult()
    tlog("GiftCodeLayer:onGetGiftCodeStatusResult")
    --弹出激活码限时礼包界面
    if GlobalData.GiftCodeProducts and #GlobalData.GiftCodeProducts.lsItems > 0 then
        G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CODE_SHOP)
    end
end

--展示通用金币结果
function GiftCodeLayer:showCommonGetGoldDialog(cmdData)
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
    local datatable = {}
    datatable.goldImg = "client/res/public/coin_3_7.png"
    datatable.goldTxt = g_format:formatNumber(cmdData.llScore,g_format.fType.standard)
    datatable.type = 2
    appdf.req(path).new(datatable)
end

--确认按钮点击事件
function GiftCodeLayer:onConfirmClickedEvent(_sender, _eventType)
    tlog('GiftCodeLayer:onConfirmClickedEvent')
    if _eventType == ccui.TouchEventType.began then
        self.m_touchBegan = true
        --self.m_touchTick = tickMgr:getTime()
    elseif _eventType == ccui.TouchEventType.canceled then
        --_sender:stopAllActions()
    elseif _eventType == ccui.TouchEventType.ended then
        if self.m_touchBegan then
            self.m_touchBegan = false
            local curTick = tickMgr:getTime()
            if curTick - self.lastClickTick > 0.5 then
                self.lastClickTick = curTick
                self:btnConfirmClick()
            end
        end
    end
end

--确定按钮提交验证码
function GiftCodeLayer:btnConfirmClick()
    tlog("GiftCodeLayer:btnConfirmClick")
    local text = self.inputCode:getString()
    --local giftCode = tostring(text)
    G_ServerMgr:C2S_GiftCodeActive(text, self.myip)
    showNetLoading()
end

function GiftCodeLayer:getMyIP()
    self.myip = "127.0.0.1"
    local info = {
        url = "https://ifconfig.me/ip",
        callback = function(ok,response) 
            -- print("myIp = ",response)
            self.myip = response 
        end
    }
    http.get(info)
end

return GiftCodeLayer