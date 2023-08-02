---------------------------------------------------
--Desc:礼包中心界面
--Date:2022-09-26 15:28:47
--Author:A*
---------------------------------------------------
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
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

HallGiftCenterLayer.PrePath = "client/res/Gift/"

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
    G_event:RemoveNotifyEvent(G_eventDef.RECHARGEBENEFIT)
    G_event:RemoveNotifyEvent(G_eventDef.RECHARGEBENEFIT_INFO)
end

function HallGiftCenterLayer:ctor(args)
    --提前加载合图
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("client/res/Gift/GiftPlist.plist", "client/res/Gift/GiftPlist.png")
    -- dump(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    self:setName("HallGiftCenterLayer")
    parent:addChild(self,ZORDER.POPUP)    
    local csbNode = g_ExternalFun.loadCSB(self.PrePath.."GiftLayer.csb")
    self.csbNode = csbNode
    self:addChild(csbNode)   
    local pEffectTitle = g_ExternalFun.loadTimeLine(self.PrePath.."GiftLayer.csb")
    pEffectTitle:gotoFrameAndPlay(0, true)
    csbNode:runAction(pEffectTitle)
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
    self.tipsPanel = self.mm_content:getChildByName("tipsPanel")
    self.tipsBtn = self.mm_content:getChildByName("tipsBtn")
    self.tipsPanel:hide()
    self.tipsBtn:onClicked(handler(self,self.onTouchTips))
    self.mm_rightPanel:hide()
    --礼包项 模板
    self.mm_Template:hide()    

    --标题效果
    local pEffectTitleCsb = "EffectTitle.csb"    
    local pEffectTitle = g_ExternalFun.loadTimeLine(self.PrePath..pEffectTitleCsb)
    pEffectTitle:gotoFrameAndPlay(0, true)
    self.mm_EffectTitle:runAction(pEffectTitle)
    
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_GET_PRODUCT_ACTIVE_STATE_RESULT,handler(self,self.onProductActiveStateResult))   --同步一次性礼包状态结果
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_PRODUCTS_STATE_RESULT,handler(self,self.onProductsStateResult))   --同步商品表状态结果
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_PAY_URL_RESULT,handler(self,self.onPayUrlResult))                  --支付URL返回
    G_event:AddNotifyEvent(G_eventDef.RECHARGEBENEFIT,handler(self,self.receiveGift))
    G_event:AddNotifyEvent(G_eventDef.RECHARGEBENEFIT_INFO,handler(self,self.setRightPanelInfo))
    self.ShowType = args.ShowType or 1    
    self.NoticeNext = args and args.NoticeNext 
    G_ServerMgr:C2S_GetProductTypeActiveState()
    G_ServerMgr:requestRechargeBenefit() 
end

function HallGiftCenterLayer:onProductsStateResult()
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
    if not self.GiftTypeConfig[self.ShowType][2] then
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
    local pTitlePath = string.format(self.PrePath.."GUI/title_%d.png",self.ShowType)        
    local pTitleBg = self.mm_EffectTitle:getChildByName("titleBg")
    local pTitle1 = pTitleBg:getChildByName("titleImage1")
    pTitle1:loadTexture(pTitlePath,ccui.TextureResType.plistType)
    local pTitle2 = pTitleBg:getChildByName("titleImage2")
    pTitle2:loadTexture(pTitlePath,ccui.TextureResType.plistType)
    --顶部彩带
    local pTopCDPath = self.PrePath.."GUI/top_cd_%d.png"
    self.mm_topCD:loadTexture(string.format(pTopCDPath,self.ShowType))    
    --右部彩带
    local pRightCDPath = self.PrePath.."GUI/right_cd_%d.png"
    self.mm_rightCD:loadTexture(string.format(pRightCDPath,self.ShowType),ccui.TextureResType.plistType)
    ccui.Helper:doLayout(self.csbNode)  

    self.mm_bg:setContentSize(display.size)
    --底部文字提示
    -- self.mm_WordTips:setString(self.GiftTipsConfig[self.ShowType])
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
    local pBgPath = self.PrePath.."GUI/itemBg_"..self.ShowType..".png"
    local pDiscountBgPath = self.PrePath.."GUI/saleBg_"..self.ShowType..".png"
    local pCoinPath = "client/res/public/coin_%d_%d.png"
    for i, v in ipairs(pListData.ProductInfos) do        
        local pItem = self.mm_Template:clone()
        pItem:show()
        --背景图
        pItem:setBackGroundImage(pBgPath,ccui.TextureResType.plistType)  
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
        local formatStr = string.format("%.2f",v.dwPrice/100)
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
    if self.ShowType == 1 then                  --首充礼包
        EventPost:addCommond(EventPost.eventType.CLICK,"点击首充礼包"..pIndex,pData.dwProductID)          --点击礼包
    elseif self.ShowType == 2 then              --每日特惠
        EventPost:addCommond(EventPost.eventType.CLICK,"点击每日特惠"..pIndex,pData.dwProductID)          --点击礼包
    elseif self.ShowType == 3 then              --一次礼包
        EventPost:addCommond(EventPost.eventType.CLICK,"点击一次礼包"..pIndex,pData.dwProductID)          --点击礼包
    end
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
    local imagePath = "client/res/public/coin_"..self.ShowType.."_"..pItemIndex..".png"
    
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

function HallGiftCenterLayer:setRightPanelInfo(rechargeBenefitDatas)
    self.rechargeBenefitDatas = rechargeBenefitDatas
    if not rechargeBenefitDatas or rechargeBenefitDatas.wCount <=0 then
        self.mm_rightPanel:hide()
        return
    end
    self.mm_rightPanel:show()
    self.mm_rightPanel:setOpacity(0)
    self.mm_rightPanel:runAction(cc.FadeIn:create(0.2))
    local llRebateScores = rechargeBenefitDatas.llRebateScores              --奖励列表
    local wCount = rechargeBenefitDatas.wCount                              --数量
    local rightListView = self.mm_rightPanel:getChildByName("rightListView")
    local fntNode = self.mm_rightPanel:getChildByName("fntNode")
    
    local pChildren = rightListView:getItems()
    for k = 1,7 do
        self["rightBtn"..k] = self["rightBtn"..k] or pChildren[k]
        self["rightFnt"..k] = self["rightFnt"..k] or fntNode:getChildByName("dayGiftNumFnt_"..k)
        self["gray_"..k] = self["gray_"..k] or fntNode:getChildByName("gray_"..k)
        self["gray_"..k]:hide()
    end

    local sum = 0
    for p = 7,1,-1 do
        local score = llRebateScores[wCount - sum]
        local btn = self["rightBtn"..p]
        local fnt = self["rightFnt"..p]
        local gray = self["gray_"..p]
        local ani = fnt._ani
        btn:onClicked(nil)
        if ani then ani:hide() end
        if score ~= nil then
            fnt:setString(g_format:formatNumber(score,g_format.fType.standard))
            self["gray_"..p]:hide()
            if (wCount - sum) == 1 then                     --今天的奖励
                if score == 0 then                   --已经领取
                    self["gray_"..p]:show()
                    btn:setColor(cc.c3b(127,127,127))
                    fnt:setColor(cc.c3b(127,127,127))
                else                                    --未领取
                    self:addSpineAnimation(fnt)
                    btn:setColor(cc.c3b(255,255,255))
                    fnt:setColor(cc.c3b(255,255,255))
                    btn:onClicked(function() 
                        G_ServerMgr:receiveRechargeBenefit() 
                    end)
                end
            else                                            --非今天的奖励
                btn:onClicked(function() 
                    showToast("Por favor, continue a buscá-lo amanhã")          --请第二天继续来领取
                end)
            end
        else
            self["gray_"..p]:show()
            btn:setColor(cc.c3b(127,127,127))
            fnt:setColor(cc.c3b(127,127,127))
        end
        sum = sum + 1
    end
end

function HallGiftCenterLayer:receiveGift(pData)
    local dwErrorCode = pData.dwErrorCode;
    local llRebateScore = pData.llRebateScore;
    local rechargeBenefitDatas = self.rechargeBenefitDatas
    if rechargeBenefitDatas and rechargeBenefitDatas.llRebateScores and #rechargeBenefitDatas.llRebateScores > 0 then
        rechargeBenefitDatas.llRebateScores[1] = 0                  --已经领取过
    end
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
    local imagePath = string.format("client/res/public/%s.png","mrrw_jb_1")
    local data = {}
    data.goldImg = imagePath
    data.goldTxt = g_format:formatNumber(llRebateScore,g_format.fType.standard)
    data.type = 1
    local layer = appdf.req(path).new(data)

    self:setRightPanelInfo(rechargeBenefitDatas)
end

--点击提示按钮
function HallGiftCenterLayer:onTouchTips()
    if self.tipsPanel:isVisible() then
        self.tipsPanel:hide()
        self:removeTipsListener()
    else
        self.tipsPanel:show()
        self:addTipsListener()
    end
end

function HallGiftCenterLayer:addTipsListener()
    local function onTouchBegan(event,params)
        return true
    end

    local function onTouchEvent(event,params)
        local position = event:getLocation()
        local nodePosition = self.tipsPanel:convertToNodeSpace(position)
        local x = nodePosition.x
        local y = nodePosition.y

        if x < 0 or x > self.tipsPanel:getContentSize().width or y < 0 or y > self.tipsPanel:getContentSize().height then
            self:onTouchTips()
        end
    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEvent, cc.Handler.EVENT_TOUCH_ENDED)
    self.listener = listener
    local eventDispatcher =self.tipsPanel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self.tipsPanel)
end

function HallGiftCenterLayer:removeTipsListener()
    local eventDispatcher = self.tipsPanel:getEventDispatcher()
	eventDispatcher:removeEventListener(self.listener)
end

function HallGiftCenterLayer:addSpineAnimation(parent)
    local ani = parent._ani
    if ani then
        ani:show()
        return
    else
        ani  = sp.SkeletonAnimation:createWithJsonFile("client/res/spine/shouchong.json","client/res/spine/shouchong.atlas", 1)        
        ani:addTo(parent)
        ani:setAnimation(0,"animation",true)
        ani:setScale(1.42)
        ani:setPosition(cc.p(24,40))
    end
    parent._ani = ani
end

function HallGiftCenterLayer:onClickClose()
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() 
        if self.NoticeNext then
            G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="HallGiftCenter"})
        end
        self:removeSelf() 
    end)
end

return HallGiftCenterLayer