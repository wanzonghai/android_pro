---------------------------------------------------
--Desc:礼包中心界面
--Date:2022-09-26 15:28:47
--Author:A*
---------------------------------------------------
local HallGiftCenterLayer = class("HallGiftCenterLayer",function(args)
    local HallGiftCenterLayer =  display.newLayer()
    return HallGiftCenterLayer
end)

HallGiftCenterLayer.GiftTypeConfig = {
    {"first",false},--首充礼包
    {"daily",false},--每日礼包
    {"once",false},--一次性礼包
}

HallGiftCenterLayer.GiftTypePosConfig = {
    cc.p(-54,550),
    cc.p(-44,416),
    cc.p(-34,283),
}

HallGiftCenterLayer.GiftTipsConfig = {
    "Após realizar qualquer recarga, esta modalidade de presentes desaparece permanentemente.",    
    "Após realizar qualquer recarga, esta modalidade de presentes desaparece hoje.",
    "Cada pacote de presente só pode ser comprado uma vez.",
}

HallGiftCenterLayer.GiftItemCoinPos = {
    {cc.p(185,355),cc.p(190,345),cc.p(170,370)},
    {cc.p(180,355),cc.p(175,360),cc.p(175,360)},
    {cc.p(180,355),cc.p(175,350),cc.p(175,360)},
}

function HallGiftCenterLayer:onExit()    
    -- G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_PRODUCTS_STATE_RESULT)
    -- G_event:RemoveNotifyEventTwo(G_eventDef.NET_GET_PRODUCT_ACTIVE_STATE_RESULT)    
    -- G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_PAY_URL_RESULT)
    --查询充值信息
    G_ServerMgr:C2S_GetLastPayInfo()
end

function HallGiftCenterLayer:ctor(args)
    dump(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    self:setName("HallGiftCenterLayer")
    parent:addChild(self)    
    local csbNode = g_ExternalFun.loadCSB("Gift/GiftLayer.csb")
    self.csbNode = csbNode
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
    self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)
    --礼包类别按钮
    for i = 1, 3 do
        self["mm_btnType"..i]:setTag(i)
        self["mm_btnType"..i]:onClicked(handler(self,self.onGiftTypeClick),true)
        self["mm_btnType"..i]:hide()
    end

    --礼包项 模板
    self.mm_Template:hide()    

    --标题效果
    local pEffectTitleCsb = "Gift/EffectTitle.csb"    
    local pEffectTitle = g_ExternalFun.loadTimeLine(pEffectTitleCsb)
    pEffectTitle:gotoFrameAndPlay(0, true)
    self.mm_EffectTitle:runAction(pEffectTitle)
    
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_GET_PRODUCT_ACTIVE_STATE_RESULT,handler(self,self.onProductActiveStateResult))   --同步一次性礼包状态结果
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_PRODUCTS_STATE_RESULT,handler(self,self.onProductsStateResult))   --同步商品表状态结果
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_PAY_URL_RESULT,handler(self,self.onPayUrlResult))                  --支付URL返回

    self.ShowType = args.ShowType or 1    
    self.NoticeNext = args and args.NoticeNext 
    G_ServerMgr:C2S_GetProductTypeActiveState()
    showNetLoading()
end

function HallGiftCenterLayer:onProductsStateResult()
    dismissNetLoading()
    for i, v in ipairs(self.GiftTypeConfig) do
        for i2, v2 in ipairs(GlobalData.ProductInfos) do
            if v2 and v2.szProductTypeName and v2.szProductTypeName == v[1] then
                v[2] = v2.byActive                
            end
        end    
    end
    local pIndex = 0
    local pShowType = nil
    for i = 1, 3 do
        if self.GiftTypeConfig[i][2] then
            pIndex = pIndex + 1
            self["mm_btnType"..i]:setPosition(self.GiftTypePosConfig[pIndex])
            if pIndex == 1 then
                pShowType = i
            end
        end
        self["mm_btnType"..i]:setVisible(self.GiftTypeConfig[i][2])
    end
    if pShowType then
       self.ShowType = pShowType 
    end
    self:switchGiftType(self.ShowType)
end

--同步一次性商品列表状态结果
function HallGiftCenterLayer:onProductActiveStateResult()
    dismissNetLoading()
    self:refreshGiftList()
end


function HallGiftCenterLayer:onGiftTypeClick(target)
    local pType = target:getTag()    
    self:switchGiftType(pType)
end

function HallGiftCenterLayer:switchGiftType(pType)
    self.ShowType = pType
    for i = 1, 3 do
        self["mm_btnType"..i]:setEnabled(i~=pType)
    end
    self:refreshExtra()
    if self.ShowType and self.ShowType==3 then
        local pTypeName = self.GiftTypeConfig[self.ShowType][1]
        local pID
        for i, v in ipairs(GlobalData.ProductInfos) do
            if v and v.szProductTypeName and v.szProductTypeName == pTypeName then
                pID = v.dwProductTypeID
                break
            end
        end
        if pID then
            G_ServerMgr:C2S_GetProductActiveState(pID)
            showNetLoading()
        end
    else
        self:refreshGiftList()
    end
end

function HallGiftCenterLayer:refreshExtra()
    --标题
    local pTitlePath = "Gift/title_%d.png"    
    local pTitleBg = self.mm_EffectTitle:getChildByName("titleBg")
    local pTitle1 = pTitleBg:getChildByName("titleImage1")
    pTitle1:setTexture(string.format(pTitlePath,self.ShowType))
    local pTitle2 = pTitleBg:getChildByName("titleImage2")
    pTitle2:setTexture(string.format(pTitlePath,self.ShowType))
    --顶部彩带
    local pTopCDPath = "Gift/top_cd_%d.png"
    self.mm_topCD:loadTexture(string.format(pTopCDPath,self.ShowType))
    --右部彩带
    local pRightCDPath = "Gift/right_cd_%d.png"
    self.mm_rightCD:loadTexture(string.format(pRightCDPath,self.ShowType))
    ccui.Helper:doLayout(self.csbNode)  
    self.mm_bg:setContentSize(display.size)
    --底部文字提示
    self.mm_WordTips:setString(self.GiftTipsConfig[self.ShowType])
end

function HallGiftCenterLayer:refreshGiftList()
    -- dump(GlobalData.ProductInfos,"GlobalData.ProductInfos",5)
    self.mm_GiftList:removeAllItems()
    self.mm_GiftList:setScrollBarEnabled(false)
    
    local pListData
    local pTypeName = self.GiftTypeConfig[self.ShowType][1]
    for i, v in ipairs(GlobalData.ProductInfos) do
        if v and v.szProductTypeName and v.szProductTypeName == pTypeName then
            pListData = v
            break
        end
    end
    local pBgPath = "Gift/itemBg_"..self.ShowType..".png"
    local pDiscountBgPath = "Gift/saleBg_"..self.ShowType..".png"
    local pCoinPath = "Gift/coin_%d_%d.png"
    for i, v in ipairs(pListData.ProductInfos) do        
        local pItem = self.mm_Template:clone()
        pItem:show()
        --背景图
        pItem:setBackGroundImage(pBgPath,ccui.TextureResType.localType)  
        --礼包内容图
        local pIconImage = pItem:getChildByName("IconImage")
        pIconImage:loadTexture(string.format(pCoinPath,self.ShowType,i))
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
        pDiscountBg:loadTexture(pDiscountBgPath)
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
        if self.ShowType==3 then
            local pFlag = GlobalData.ProductOnceState[i]== 1
            local pColor = pFlag and cc.c3b(255,255,255) or cc.c3b(191,191,191)
            pItem:setColor(pColor)
            pButtonPay:setTouchEnabled(pFlag)
            if pFlag then
                self.mm_GiftList:pushBackCustomItem(pItem)
            end
        else
            self.mm_GiftList:pushBackCustomItem(pItem)    
        end
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

function HallGiftCenterLayer:onGiftBuyClick(target)
    local pIndex = target:getTag()   
    local pData = self.ListData.ProductInfos[pIndex]
    G_ServerMgr:C2S_GetPayUrl(pData.dwProductID)
    showNetLoading()
end


--充值URL
function HallGiftCenterLayer:onPayUrlResult(data)    
    local pItemIndex
    local pItem
    for i, v in ipairs(self.ListData.ProductInfos) do
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
    local imagePath = "client/res/Gift/coin_"..self.ShowType.."_"..pItemIndex..".png"
    
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

function HallGiftCenterLayer:onClickClose()
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() 
        if self.NoticeNext then
            G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)
        end
        self:removeSelf() 
    end)
end

return HallGiftCenterLayer