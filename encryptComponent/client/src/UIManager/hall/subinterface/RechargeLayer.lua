---------------------------------------------------
--Desc:商城界面
--Date:2022-09-23 16:01:47
--Author:A*
---------------------------------------------------
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
local RechargeLayer = class("RechargeLayer",function(args)
	local RechargeLayer =  display.newLayer()
    return RechargeLayer
end)
function RechargeLayer:onExit()
    -- G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_PRODUCTS_STATE_RESULT) 
    -- G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_PAY_URL_RESULT)   
    -- G_event:RemoveNotifyEventTwo(self,G_eventDef.EVENT_HALL_BET_SCORE_DATA)  
    --查询充值信息
    G_ServerMgr:C2S_GetLastPayInfo() 
end

function RechargeLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)    
    self.quitCallback = args.quitCallback
    local csbNode = g_ExternalFun.loadCSB("recharge/RechargeLayer.csb")
    csbNode:setContentSize(display.width,display.height)
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)
    self:addChild(csbNode)    
    g_ExternalFun.loadChildrenHandler(self,csbNode)

    --左上
    self.PanelLeftTop = self.mm_PanelLeftTop
    --左中
    self.PanelLeftCenter = self.mm_PanelLeftCenter
    --右中
    self.PanelRightCenter = self.mm_PanelRightCenter  
        
    --表皮
    self.PanelPre = self.mm_PanelPre
    if display.width>2560 then
        self.PanelRightCenter:setContentSize(cc.size(display.width,display.height))
        self.PanelPre:getChildByName("windowPre"):setContentSize(cc.size(display.width,205))
    end
    --适配性调整Panel大小
    self:adjustPanelSize()
    ccui.Helper:doLayout(csbNode)

    self.mm_btnBack:onClicked(function() 
        local callback = function()
            if self.quitCallback then
                self.quitCallback()
            end
            self:removeSelf()
        end
        self:EaseHide(callback)
    end,true)

    local skeletonNode = sp.SkeletonAnimation:create("client/res/spine/huodongjuese.json", "client/res/spine/huodongjuese.atlas", 1)
    skeletonNode:addAnimation(0, "daiji", true)    
    skeletonNode:setPosition(0,-300)
    self.mm_NodeAvatar:addChild(skeletonNode)

    --礼包中心
    local pAction = g_ExternalFun.loadTimeLine("Lobby/Entry/NodeGift.csb")
    local pSpine = self.mm_NodeGift:getChildByName("spine_1") 
    self.NodeGiftPercentBg = self.mm_NodeGift:getChildByName("wordBg")
    self.NodeGiftPercentBg:hide()
    self.NodeGiftPercent = self.NodeGiftPercentBg:getChildByName("libaorukou_6_3"):getChildByName("word_1")
    
    local pSpineEffect = sp.SkeletonAnimation:create("spine/lingbaotubiao.json","spine/lingbaotubiao.atlas", 1)
    pSpineEffect:addTo(pSpine)
    pSpineEffect:setPosition(0, 0)
    pSpineEffect:setAnimation(0, "daiji", true)
    pAction:gotoFrameAndPlay(0, true)
    self.mm_NodeGift:runAction(pAction)
    self.mm_NodeGift:getChildByName("Button_1"):onClicked(function()          
        self:EaseHide(function()
            if self.quitCallback then
                self.quitCallback()
                local pData = {
                    ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
                }
                G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
            end
            self:removeSelf()
        end)
    end)
    self.mm_NodeGift:setVisible(GlobalData.GiftEnable)

    self:EaseShow()   
        
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_PRODUCTS_STATE_RESULT,handler(self,self.onProductsStateResult))   --同步商品表状态结果
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_PAY_URL_RESULT,handler(self,self.onPayUrlResult))                  --支付URL返回
    G_event:AddNotifyEventTwo(self,G_eventDef.EVENT_HALL_BET_SCORE_DATA,handler(self,self.onGetRechargeScoreResult))   --当日购买额返回监听
    G_ServerMgr:C2S_GetProductTypeActiveState()

    --请求当日购买状态
    local pType = 2
    if ylAll.ProjectSelect and ylAll.ProjectSelect==2 then
        pType = 1
    end
    G_ServerMgr:C2S_GetBetScore(pType)

    showNetLoading()    
end

--适配性调整Panel大小
function RechargeLayer:adjustPanelSize()
    --左中指导性尺寸
    self.LeftCenterMin = 446
    self.LeftCenterMax = 650
    
    --左中比例
    self.LeftCenterPercent = 446/1920
    
    --获取屏幕宽度
    local pWidth = display.width
    if pWidth <= 1920 then
        --屏幕宽度小于设计尺寸
        --左中走最小尺寸
        self.PanelLeftCenter:setContentSize(cc.size(self.LeftCenterMin,1080))
    else
        --屏幕宽度超过设计尺寸
        local pAbelLeftCenterWidth = math.min(pWidth*self.LeftCenterPercent,self.LeftCenterMax)
        self.PanelLeftCenter:setContentSize(cc.size(pAbelLeftCenterWidth,1080))
    end    
end

--缓入
function RechargeLayer:EaseShow(callback)
    local pCostTime = 0.3
    local pDeltaTime = 0.08    
    --左上
    self.PanelLeftTop:setPositionY(display.height+160)
    TweenLite.to(self.PanelLeftTop,pCostTime,{ y=display.height,ease = Cubic.easeInOut})
    --左中
    local pSize = self.PanelLeftCenter:getContentSize()
    self.PanelLeftCenter:setPositionX(-pSize.width)
    TweenLite.to(self.PanelLeftCenter,pCostTime,{ x=0,ease = Cubic.easeInOut})
    --右中
    self.PanelRightCenter:setPositionX(display.width+2560/2)    
    TweenLite.to(self.PanelRightCenter,pCostTime/2,{ x=display.cx,ease = Cubic.easeInOut})
    --表皮
    self.PanelPre:setPositionX(display.width+2560/2)    
    TweenLite.to(self.PanelPre,pCostTime/2,{ x=display.cx,ease = Cubic.easeInOut})
end

--缓出
function RechargeLayer:EaseHide(callback)    
    local pCostTime = 0.3
    local pDeltaTime = 0.08    
    --左上
    TweenLite.to(self.PanelLeftTop,pCostTime,{ y=display.height+160,ease = Cubic.easeInOut})    
    --左中
    local pSize = self.PanelLeftCenter:getContentSize()
    TweenLite.to(self.PanelLeftCenter,pCostTime,{ x=-pSize.width,ease = Cubic.easeInOut})
    --右中
    TweenLite.to(self.PanelRightCenter,pCostTime,{ x=display.cx+2560,ease = Cubic.easeInOut})    
    --表皮
    TweenLite.to(self.PanelPre,pCostTime,{ x=display.cx+2560,ease = Cubic.easeInOut,onComplete =callback})    
end

function RechargeLayer:onGetRechargeScoreResult(pData)
    self.TodayRecharge = pData.TodayRechargeScore > 0
end

function RechargeLayer:onProductsStateResult()
    dismissNetLoading()
    local configData = self:getShopList() 
    if configData == nil then 
        print("获取商城商品信息异常")
        return 
    end
    local goldTable = {}
    for i=1,6 do
        goldTable[i] = {}
        goldTable[i].index = i
        goldTable[i].gold = configData[i].lAwardValue
        goldTable[i].price = configData[i].dwPrice
    end
    table.sort(goldTable,function(a,b)
        return a.gold < b.gold
    end)

    local imageTable = {}
    for i=1,6 do
        imageTable[goldTable[i].index] = "client/res/recharge/sp_coin"..i..".png"
    end

    for i=1,6 do
        self["mm_txtCoin_"..i]:setString(g_format:formatNumber(goldTable[i].gold,g_format.fType.abbreviation,g_format.currencyType.GOLD))
        local formatStr = string.format("R$ %.2f",goldTable[i].price/100)
        formatStr = string.gsub(formatStr,"%.",",")
        self["mm_txtMoney_"..i]:setString(formatStr)
        self["mm_btnPay_"..i]:setTag(i)
        self["mm_btnPay_"..i]:onClickEnd(function() self:onGoodBuyClick(self["mm_btnPay_"..i]) end,true)
        self["mm_Image_gold_"..i]:loadTexture(imageTable[i])
    end

    local pValue = 0
    for i, v in ipairs(GlobalData.ProductInfos) do
        if v.byActive and v.szProductTypeName ~= "shop" then
            for i2, v2 in ipairs(v.ProductInfos) do
                if v2.byAttachType == 2 then
                    local pC = nil
                    if i==3 then
                        if GlobalData.ProductOnceState[i2] then
                            pC = v2
                        end
                    else
                        pC = v2
                    end
                    if pC and pC.lAttachValue > pValue then
                        pValue = pC.lAttachValue
                    end                    
                end
            end
        end
    end
    if pValue == 0 then
        self.NodeGiftPercentBg:hide()
        self.NodeGiftPercent:setString("")
    else
        self.NodeGiftPercentBg:show()
        self.NodeGiftPercent:setString("+"..pValue.."%")
    end
end

function RechargeLayer:getShopList()
    for k,v in pairs(GlobalData.ProductInfos) do
        if v.szProductTypeName == "shop" then
            self.ListData = v
            return v.ProductInfos
        end
    end
    return nil
end

function RechargeLayer:isTodayFirstThreshold()
    --判断系统消息显示是否当天第一次
    local pKey = "TodayFirstThreshold_"..GlobalUserItem.dwUserID
    local pLastThresholdTime = cc.UserDefault:getInstance():getIntegerForKey(pKey,0)
    local pDate = os.date("*t",pLastThresholdTime)
    local pToday = os.date("*t",os.time())
    --判定是否跨天
    if pToday.year ~= pDate.year or pToday.month ~= pDate.month or pToday.day ~= pDate.day then
        cc.UserDefault:getInstance():setIntegerForKey(pKey,os.time())
        cc.UserDefault:getInstance():flush()
        return true
    else
        return false
    end
end

function RechargeLayer:onGoodBuyClick(target)
    print("onGoodBuyClick click os.time() = ",os.time())
    local pIndex = target:getTag()   
    local pData = self.ListData.ProductInfos[pIndex]
    --现在商城的最小面额是50了，点商城不用提示他去买礼包
    if false then--GlobalData.GiftEnable and not self.TodayRecharge and pData.dwPrice and pData.dwPrice< GlobalData.ShopThreshold then
        local pFisrtTips = self:isTodayFirstThreshold()
        if pFisrtTips then
            local RechargeTips = appdf.req("client.src.UIManager.hall.subinterface.RechargeTips")
            local tips = RechargeTips:create(g_language:getString("shop_threshold"),function(ok)            
                if ok then                 
                    self:EaseHide(function()
                        if self.quitCallback then
                            self.quitCallback()
                            local pData = {
                                ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
                            }
                            G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
                        end
                        self:removeSelf()
                    end)  
                else
                    print("onGoodBuyClick send C2S_GetPayUrl 1 os.time() = ",os.time())
                    G_ServerMgr:C2S_GetPayUrl(pData.dwProductID)
                    showNetLoading()
                end                 
            end)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(tips)
            tips:setPosition(cc.p(0,0))
        else
            print("onGoodBuyClick send C2S_GetPayUrl 2 os.time() = ",os.time())
            G_ServerMgr:C2S_GetPayUrl(pData.dwProductID)
            showNetLoading()
        end
    else
        print("onGoodBuyClick send C2S_GetPayUrl 3 os.time() = ",os.time())
        G_ServerMgr:C2S_GetPayUrl(pData.dwProductID)
        showNetLoading()
    end   
    EventPost:addCommond(EventPost.eventType.CLICK,"点击商城商品",pData.dwProductID)          --点击礼包      --点击礼包 
end

--充值URL
function RechargeLayer:onPayUrlResult(data)  
    print("onGoodBuyClick recv onPayUrlResult os.time() = ",os.time())  
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
        pValue = pValue*(1 + pItem.lAttachValue)
    end
    self.PayUrl = data.szPayUrl
    -- local URL = string.format("%s?price=%d&userId=%d&productId=%d&name=%s",self.PayUrl,pItem.dwPrice,GlobalUserItem.dwUserID,pItem.dwProductID,encodeURI(GlobalUserItem.szNickName))
    local imagePath = "client/res/recharge/GUI/sp_coin"..pItemIndex..".png"
    -- local info = {}
    -- info.url = URL  --"http://pay.abc.com/pay//epay/?price=10000&userId=7156709&productId=18&name=Leonardo%20Ole"
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
    params.mode = 0
    dump(params,"=========url")
    local callback = function(ok,jsonData) 
        dismissNetLoading()
        if ok then
            if jsonData.code == 0 then
                -- dump(jsonData)
                print("openURL os.time() = ",os.time())
                OSUtil.openURL(jsonData.result.payUrl)
                ylAll.firstData = {}
                ylAll.firstData.isopen = true
                ylAll.firstData.bankMoney = GlobalUserItem.lUserInsure
                ylAll.firstData.curPayMoney = pValue
                ylAll.firstData.imagePath = imagePath
                ylAll.firstData.OrderNo = jsonData.result.orderNo
                ylAll.firstData.dwProductID = pItem.dwProductID
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

return RechargeLayer