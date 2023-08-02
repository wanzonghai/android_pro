---------------------------------------------------
--Desc:激活码限时礼包界面
---------------------------------------------------
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
local GiftCodeShopLayer = class("GiftCodeShopLayer",function(args)
    local GiftCodeShopLayer =  display.newLayer()
    return GiftCodeShopLayer
end)

GiftCodeShopLayer.PrePath = "client/res/Gift/"

function GiftCodeShopLayer:onExit()    
    -- G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_PRODUCTS_STATE_RESULT)
    -- G_event:RemoveNotifyEventTwo(G_eventDef.NET_GET_PRODUCT_ACTIVE_STATE_RESULT)    
    -- G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_PAY_URL_RESULT)
    --查询充值信息
    G_ServerMgr:C2S_GetLastPayInfo()
end

function GiftCodeShopLayer:ctor(args)
    -- dump(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    self:setName("GiftCodeShopLayer")
    parent:addChild(self,ZORDER.POPUP)    
    local csbNode = g_ExternalFun.loadCSB(self.PrePath.."GiftLayer.csb")
    self.csbNode = csbNode
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
    self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)
    --礼包类别按钮
    for i = 1, 3 do
        self["mm_btnType"..i]:hide()
        self["mm_btnType"..i]:setEnabled(false)
        self["mm_btnType"..i]:setTouchEnabled(false)
    end

    --礼包项 模板
    self.mm_Template:hide()    

    --标题效果
    local pEffectTitleCsb = "EffectTitle.csb"    
    local pEffectTitle = g_ExternalFun.loadTimeLine(self.PrePath..pEffectTitleCsb)
    pEffectTitle:gotoFrameAndPlay(0, true)
    self.mm_EffectTitle:runAction(pEffectTitle)

    -- G_event:AddNotifyEventTwo(self,G_eventDef.NET_PAY_URL_RESULT,handler(self,self.onPayUrlResult))                  --支付URL返回

    self.ShowType = 4    

    self:refreshExtra()
    self:refreshGiftList()
end

function GiftCodeShopLayer:refreshExtra()
    --标题
    local pTitlePath = string.format(self.PrePath.."GUI/title_%d.png",self.ShowType)        
    local pTitleBg = self.mm_EffectTitle:getChildByName("titleBg")
    local pTitle1 = pTitleBg:getChildByName("titleImage1")
    pTitle1:loadTexture(pTitlePath,ccui.TextureResType.plistType)
    local pTitle2 = pTitleBg:getChildByName("titleImage2")
    pTitle2:loadTexture(pTitlePath,ccui.TextureResType.plistType)
    --顶部彩带
    local pTopCDPath = self.PrePath.."GUI/top_cd_%d.png"
    self.mm_topCD:loadTexture(string.format(pTopCDPath,self.ShowType),ccui.TextureResType.plistType)    
    --右部彩带
    local pRightCDPath = self.PrePath.."GUI/right_cd_%d.png"
    self.mm_rightCD:loadTexture(string.format(pRightCDPath,self.ShowType),ccui.TextureResType.plistType)
    ccui.Helper:doLayout(self.csbNode)  
    self.mm_bg:setContentSize(display.size)
    --底部文字提示
    self.mm_WordTips:setString("")
end

function GiftCodeShopLayer:refreshGiftList()
    self.mm_GiftList:removeAllItems()
    self.mm_GiftList:setScrollBarEnabled(false)
    
    local pListData = GlobalData.GiftCodeProducts
    local pBgPath = self.PrePath.."GUI/itemBg_"..self.ShowType..".png"
    local pDiscountBgPath = self.PrePath.."GUI/saleBg_"..self.ShowType..".png"
    local pCoinPath = "client/res/public/coin_1_2.png"

    for i, v in ipairs(pListData.lsItems) do        
        local pItem = self.mm_Template:clone()
        pItem:show()
        --背景图
        pItem:setBackGroundImage(pBgPath,ccui.TextureResType.plistType)  
        --礼包内容图
        local pIconImage = pItem:getChildByName("IconImage")
        pIconImage:loadTexture(pCoinPath)
        pIconImage:ignoreContentAdaptWithSize(true)
        --原价
        local pAbandonValue = pItem:getChildByName("AbandonValue")
        local pAbandonLine = pItem:getChildByName("AbandonLine")
        pAbandonValue:setString(g_format:formatNumber(v.lAwardValue,g_format.fType.standard,g_format.currencyType.GOLD))        
        pAbandonValue:setVisible(v.lAttachValue>0)
        pAbandonLine:setVisible(v.lAttachValue>0) 
        pAbandonLine:setContentSize(cc.size(pAbandonValue:getContentSize().width*0.6,3))
        --现价
        local pValue = v.lAwardValue
        if v.byAttachType == 1 then
            --附加定值
            pValue = pValue + v.lAttachValue
        elseif v.byAttachType == 2 then
            --附加百分比
            pValue = pValue*(100 + v.lAttachValue)/100
        end
        local pIconValue = pItem:getChildByName("IconValue")
        pIconValue:setString(g_format:formatNumber(pValue,g_format.fType.standard,g_format.currencyType.GOLD))
        --额外
        local pDiscountBg = pItem:getChildByName("DiscountBg")
        pDiscountBg:loadTexture(pDiscountBgPath,ccui.TextureResType.plistType)
        pDiscountBg:setVisible(v.lAttachValue>0)
        local pDiscountValue = pDiscountBg:getChildByName("DiscountValue")
        pDiscountValue:setString(v.lAttachValue)
        local pDiscountPercent = pDiscountValue:getChildByName("DiscountPercent")
        pDiscountPercent:setVisible(v.byAttachType==2)
        pDiscountPercent:setPositionX(pDiscountValue:getContentSize().width)
        --购买按钮 
        local pButtonPay = pItem:getChildByName("ButtonPay")
        pButtonPay:setTag(i)
        pButtonPay:onClicked(handler(self,self.onGiftBuyClick),true)
        --按钮金额
        local pPriceValue = pButtonPay:getChildByName("PriceValue")
        local formatStr = string.format(" %.2f",v.dwPrice/100)
        formatStr = string.gsub(formatStr,"%.",",")
        pPriceValue:setString(formatStr)
        --过期时间
        local timeBg = display.newSprite("#client/res/Gift/GUI/timeStampBg.png")
        timeBg:setPosition(pItem:getContentSize().width/2, 252)
        timeBg:addTo(pItem)
        local remainTime = v.tmExpireTime - EventPost:getServerTime()
        if remainTime < 0 then
            remainTime = 0
        end
        local timeStr = DateUtil.getTimeString(remainTime, 1)
        local timeText = ccui.Text:create("0","base/res/fonts/arialBold.ttf",32)
        --local timeText = cc.LabelBMFont:create("0", "GUI/num_pic/shuijingfenshu.fnt")
        timeText:setTextColor(cc.c3b(255,255,255))
        timeText:setPosition(timeBg:getContentSize().width/2+20, timeBg:getContentSize().height/2+5)
        timeText:addTo(timeBg)
        timeText:setString(timeStr)
        local actTick = cc.RepeatForever:create(
            cc.Sequence:create(
                cc.DelayTime:create(1.0),
                cc.CallFunc:create(function (  )
                    local remainTime = v.tmExpireTime - EventPost:getServerTime()
                    if remainTime < 0 then
                        remainTime = 0
                    end
                    local timeStr = DateUtil.getTimeString(remainTime, 1)
                    timeText:setString(timeStr)
                end)
        ))
        timeText:stopAllActions()
        timeText:runAction(actTick)
        
        self.mm_GiftList:pushBackCustomItem(pItem)
    end
    local pChildren = self.mm_GiftList:getItems()
    local pCount = #pChildren
    
    if pChildren and pCount and pCount>0 then
        if pCount > 3 then
            self.mm_GiftList:setTouchEnabled(true)
            self.mm_LeftTips:show()
            self.mm_RightTips:show()
        else
            self.mm_GiftList:setTouchEnabled(false)
            self.mm_LeftTips:hide()
            self.mm_RightTips:hide()
        end
        pCount = pCount > 3 and 3 or pCount
        self.mm_GiftList:setContentSize(cc.size((pCount*354+(pCount-1)*5),565))
    end 
    self.ListData = pListData
    self.mm_GiftList:show()
end

function GiftCodeShopLayer:onGiftBuyClick(target)
    local pIndex = target:getTag()   
    local pData = self.ListData.lsItems[pIndex]
    EventPost:addCommond(EventPost.eventType.CLICK,"点击购买礼包",pData.dwProductID)          --点击礼包
    G_ServerMgr:C2S_GetPayUrl(pData.dwProductID)
    showNetLoading()
end

--充值URL
function GiftCodeShopLayer:onPayUrlResult(data)    
    local pItemIndex
    local pItem 
    for i, v in ipairs(self.ListData.lsItems) do
        if v and data.dwProductID and v.dwProductID == data.dwProductID then
            pItemIndex = i
            pItem = v
            break
        end
    end
    local pValue = pItem.lAwardValue
    if pItem.byAttachType == 1 then
        --附加定值
        pValue = pValue + pItem.lAttachValue
    elseif pItem.byAttachType == 2 then
        --附加百分比
        pValue = pValue*(100 + pItem.lAttachValue)/100
    end
    self.PayUrl = data.szPayUrl    
    local imagePath = "client/res/public/coin_1_2.png"
    
    local params = {}
    params.price = pItem.dwPrice
    params.userId = GlobalUserItem.dwUserID
    params.productId = pItem.dwProductID
    params.name = encodeURI(GlobalUserItem.szNickName)
    params.EventToken = FunctionADLogName("ad_revenue")
    params.EventTokenFirstPay = FunctionADLogName("ad_firstRevenue")
    params.AppToken = g_MultiPlatform:getInstance():getAdjustKey() 
    params.DevType = "gps_adid"
    params.DevID = g_MultiPlatform:getInstance():getAdjustGoogleAdId() 
    params.Currency = "BRL"
    
    local callback = function(ok,jsonData) 
        dismissNetLoading()
        if ok then
            if jsonData.code == 0 then
                ylAll.firstData = {}
                ylAll.firstData.isopen = true
                ylAll.firstData.bankMoney = GlobalUserItem.lUserInsure
                ylAll.firstData.curPayMoney = pValue
                ylAll.firstData.imagePath = imagePath
                ylAll.firstData.OrderNo = jsonData.result.orderNo
                ylAll.firstData.dwProductID = pItem.dwProductID
                --关闭礼包页面
                self:onClickClose()
                --打开支付外跳
                OSUtil.openURL(jsonData.result.payUrl)
            else
                print(string.format("code = %s,error:%s",jsonData.code,jsonData.msg))
                showToast(jsonData.msg)
            end
        else
            print("HTTP GET ERROR:",jsonData)
        end
    end
    g_ExternalFun.onHttpJsionTable(self.PayUrl,"POST",cjson.encode(params),callback)
    showNetLoading()
end

function GiftCodeShopLayer:onClickClose()
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() 
        self:removeSelf() 
    end)
end

return GiftCodeShopLayer