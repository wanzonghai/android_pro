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
    G_event:RemoveNotifyEvent(G_eventDef.NET_GET_PRODUCT_EXTEND_FLAG)
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
    g_ExternalFun.adapterScreen(self.mm_bg)
    --左上
    self.PanelLeftTop = self.mm_PanelLeftTop
    --左中
    self.PanelLeftCenter = self.mm_PanelLeftCenter
    --右中
    self.PanelRightCenter = self.mm_PanelRightCenter  
    self.mm_Tips:hide()
    
    self._isLoading = false
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

    local skeletonNode = sp.SkeletonAnimation:create("client/res/spine/Recharge/renwu_1.json", "client/res/spine/Recharge/renwu_1.atlas", 1)
    skeletonNode:addAnimation(0, "ruchang", false)    
    self.mm_NodeAvatar:addChild(skeletonNode)
    skeletonNode:registerSpineEventHandler( function( event )
        if event.animation == "ruchang" then
            skeletonNode:addAnimation(0, "daiji", true)  
        end
    end, sp.EventType.ANIMATION_COMPLETE)   
    skeletonNode:setMix("ruchang","daiji",0.2)            --动画过渡

    local skeletonNode = sp.SkeletonAnimation:create("client/res/spine/Recharge/shagncheng_2.json", "client/res/spine/Recharge/shagncheng_2.atlas", 1)
    skeletonNode:addAnimation(0, "daiji", true)    
    self.mm_spineBackGround:addChild(skeletonNode)

    for i = 1,10 do
        local item = self["mm_item"..i]
        item:setOpacity(0)
    end
    --礼包中心
   -- local pAction = g_ExternalFun.loadTimeLine("Lobby/Entry/NodeGift.csb")
    -- local pSpine = self.mm_NodeGift:getChildByName("spine_1") 
    -- self.NodeGiftPercentBg = self.mm_NodeGift:getChildByName("wordBg")
    -- self.NodeGiftPercentBg:hide()
    -- self.NodeGiftPercent = self.NodeGiftPercentBg:getChildByName("libaorukou_6_3"):getChildByName("word_1")
    
    -- local pSpineEffect = sp.SkeletonAnimation:create("spine/lingbaotubiao.json","spine/lingbaotubiao.atlas", 1)
    -- pSpineEffect:addTo(pSpine)
    -- pSpineEffect:setPosition(0, 0)
    -- pSpineEffect:setAnimation(0, "daiji", true)
    -- pAction:gotoFrameAndPlay(0, true)
    -- self.mm_NodeGift:runAction(pAction)
    -- self.mm_NodeGift:getChildByName("Button_1"):onClicked(function()          
    --     self:EaseHide(function()
    --         if self.quitCallback then
    --             self.quitCallback()
    --             local pData = {
    --                 ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
    --             }
    --             G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
    --         end
    --         self:removeSelf()
    --     end)
    -- end)
    -- self.mm_NodeGift:setVisible(GlobalData.GiftEnable)

    self:EaseShow()   
        
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_PRODUCTS_STATE_RESULT,handler(self,self.onProductsStateResult))   --同步商品表状态结果
    -- G_event:AddNotifyEventTwo(self,G_eventDef.NET_PAY_URL_RESULT,handler(self,self.onPayUrlResult))                  --支付URL返回
    G_event:AddNotifyEventTwo(self,G_eventDef.EVENT_HALL_BET_SCORE_DATA,handler(self,self.onGetRechargeScoreResult))   --当日购买额返回监听
    G_event:AddNotifyEvent(G_eventDef.NET_GET_PRODUCT_EXTEND_FLAG,handler(self,self.onGetProductExtendFlagResult))   --获取商城商品扩展标识
    G_ServerMgr:C2S_GetProductTypeActiveState()

    --请求当日购买状态
    local pType = 2
    if ylAll.ProjectSelect and ylAll.ProjectSelect==2 then
        pType = 1
    end
    G_ServerMgr:C2S_GetBetScore(pType)
    --获取商城商品扩展标识
    G_ServerMgr:C2S_GetProductExtendFlag()

    showNetLoading()    
end

--缓入
function RechargeLayer:EaseShow(callback)
    local pCostTime = 0.3
    local pDeltaTime = 0.08    
    --左中
    local pSize = self.PanelLeftCenter:getContentSize()
    self.PanelLeftCenter:setPositionX(-pSize.width)
    TweenLite.to(self.PanelLeftCenter,pCostTime,{ x=0,ease = Cubic.easeInOut,onComplete =callback})
    --右中
    --self.PanelRightCenter:setPositionX(display.width+2560/2)    
   -- TweenLite.to(self.PanelRightCenter,pCostTime/2,{ x=781,ease = Cubic.easeInOut,onComplete =callback})
end

--缓出
function RechargeLayer:EaseHide(callback)    
    local pCostTime = 0.3
    local pDeltaTime = 0.08    
   
    --左中
    local pSize = self.PanelLeftCenter:getContentSize()
    TweenLite.to(self.PanelLeftCenter,pCostTime,{ x=-pSize.width,ease = Cubic.easeInOut,onComplete =callback})
    for i = 1,10 do
        local item = self["mm_item"..i]
        local initPosition = cc.p(item:getPosition())
        local delayTime = (math.ceil(i / 2) - 1) * (2/30)
        local array = {
            cc.DelayTime:create(delayTime),
            cc.Spawn:create(
                cc.FadeOut:create(1/5),
                cc.EaseQuinticActionOut:create(cc.MoveTo:create(1/5,cc.p(initPosition.x + 1560,initPosition.y)))
            )
        }
        item:runAction(cc.Sequence:create(array))    
    end
    --右中
   -- TweenLite.to(self.PanelRightCenter,pCostTime,{ x=display.cx+2560,ease = Cubic.easeInOut,onComplete =callback})    
    --表皮
   -- TweenLite.to(self.PanelPre,pCostTime,{ x=display.cx+2560,ease = Cubic.easeInOut,onComplete =callback})    
end

function RechargeLayer:onGetRechargeScoreResult(pData)
    self.TodayRecharge = pData.TodayRechargeScore > 0
end

function RechargeLayer:onGetProductExtendFlagResult(pData)
    dump(pData)
    local configData = self:getShopList() 
    --0表示 没有角标，为1表示有
    for i = 1,10 do
        local item = self["mm_item"..i]
        local Image_hot = item:getChildByName("Image_hot")
        local extraGain = item:getChildByName("extraGain")
        local extraText = extraGain:getChildByName("extraText")
        local pItem = self.ListData.ProductInfos[i]
        local dwProductID = pItem.dwProductID
        if pData and pData.lsItems then
            local dwExtendFlag = pData.lsItems[dwProductID] or 0 --为0表示 没有角标，为1表示有
            if dwExtendFlag == 1 then
                Image_hot:setVisible(true)
            end
        end
        for m,p in pairs(configData) do
            if p and p.dwProductID == dwProductID then
                local byAttachType = p.byAttachType
                local lAttachValue = p.lAttachValue
                if tonumber(lAttachValue) ~= 0 then
                    extraGain:show()
                    if byAttachType == 1 then               --定值
                        local formatStr = g_format:formatNumber(lAttachValue,g_format.fType.abbreviation,g_format.currencyType.GOLD)
                        extraText:setString("+R$"..formatStr)
                    elseif byAttachType == 2 then           --百分比
                        lAttachValue = p.dwPrice*lAttachValue/100
                        if (lAttachValue % 100) ~= 0 then               --不能被100整除
                            local formatStr = g_format:formatNumber(lAttachValue,g_format.fType.abbreviation,g_format.currencyType.GOLD)
                            extraText:setString("+R$"..formatStr)
                        else
                            extraText:setString("+R$"..(lAttachValue / 100))
                        end
                    end
                end
                break
            end
        end
    end
end

function RechargeLayer:onProductsStateResult()
    dismissNetLoading()
    local configData = self:getShopList() 
    if configData == nil then 
        print("获取商城商品信息异常")
        return 
    end
    local goldTable = {}
    for i=1,10 do
        if configData[i] then
            goldTable[i] = {}
            goldTable[i].index = i
            goldTable[i].gold = configData[i].lAwardValue
            goldTable[i].price = configData[i].dwPrice
        end
    end
    -- table.sort(goldTable,function(a,b)
    --     return a.gold < b.gold
    -- end)

    local imageTable = {}
    for i=1,10 do
        if goldTable[i] then
            imageTable[goldTable[i].index] = "client/res/recharge/GUI2/xsc_jb"..i..".png"
        end
    end

    for i = 1,10 do
        if goldTable[i] then
            local item = self["mm_item"..i]
            local txtCoin_1 = item:getChildByName("txtCoin_1")
            local btnPay = item:getChildByName("btnPay")
            local txtMoney_1 = btnPay:getChildByName("txtMoney_1")
            local Image_gold_1 = item:getChildByName("Image_gold_1")
            local btnPay_1 = item:getChildByName("btnPay_1")

            txtCoin_1:setString(g_format:formatNumber(goldTable[i].gold,g_format.fType.abbreviation,g_format.currencyType.GOLD))
            local formatStr = string.format("R$ %.2f",goldTable[i].price/100)
            formatStr = string.gsub(formatStr,"%.",",")
            txtMoney_1:setString(formatStr)
            btnPay_1:setTag(goldTable[i].index)
            btnPay_1:onClickEnd(function() self:onGoodBuyClick(btnPay_1) end,true)
            btnPay:setTag(goldTable[i].index)
            btnPay:onClickEnd(function() self:onGoodBuyClick(btnPay_1) end,true)
            Image_gold_1:ignoreContentAdaptWithSize(true)
            Image_gold_1:loadTexture(imageTable[i],1)
            local initPosition = cc.p(item:getPosition())
            item:setPositionX(initPosition.x + 1560)
            item:setOpacity(0)
            local delayTime = (math.ceil(i / 2) - 1) * (2/30)
            local array = {
                cc.DelayTime:create(delayTime),
                cc.Spawn:create(
                    cc.FadeIn:create(1/5),
                    cc.EaseQuinticActionOut:create(cc.MoveTo:create(1/5,initPosition))
                )
            }
            item:runAction(cc.Sequence:create(array))
        end
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
    -- if pValue == 0 then
    --     self.NodeGiftPercentBg:hide()
    --     self.NodeGiftPercent:setString("")
    -- else
    --     self.NodeGiftPercentBg:show()
    --     self.NodeGiftPercent:setString("+"..pValue.."%")
    -- end
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

-- function RechargeLayer:onGoodBuyClick(target)
--     print("onGoodBuyClick click os.time() = ",os.time())
--     local pIndex = target:getTag()   
--     local pData = self.ListData.ProductInfos[pIndex]

--     dump(pData)
--     -- --现在商城的最小面额是50了，点商城不用提示他去买礼包
--     -- if false then--GlobalData.GiftEnable and not self.TodayRecharge and pData.dwPrice and pData.dwPrice< GlobalData.ShopThreshold then
--     --     local pFisrtTips = self:isTodayFirstThreshold()
--     --     if pFisrtTips then
--     --         local RechargeTips = appdf.req("client.src.UIManager.hall.subinterface.RechargeTips")
--     --         local tips = RechargeTips:create(g_language:getString("shop_threshold"),function(ok)            
--     --             if ok then                 
--     --                 self:EaseHide(function()
--     --                     if self.quitCallback then
--     --                         self.quitCallback()
--     --                         local pData = {
--     --                             ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
--     --                         }
--     --                         G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
--     --                     end
--     --                     self:removeSelf()
--     --                 end)  
--     --             else
--     --                 print("onGoodBuyClick send C2S_GetPayUrl 1 os.time() = ",os.time())
--     --                 G_ServerMgr:C2S_GetPayUrl(pData.dwProductID)
--     --                 self:showNetLoading()
--     --             end                 
--     --         end)
--     --         local scene = cc.Director:getInstance():getRunningScene()
--     --         scene:addChild(tips)
--     --         tips:setPosition(cc.p(0,0))
--     --     else
--     --         print("onGoodBuyClick send C2S_GetPayUrl 2 os.time() = ",os.time())
--     --         G_ServerMgr:C2S_GetPayUrl(pData.dwProductID)
--     --         self:showNetLoading()
--     --     end
--     -- else
--     --     print("onGoodBuyClick send C2S_GetPayUrl 3 os.time() = ",os.time())
--     --     G_ServerMgr:C2S_GetPayUrl(pData.dwProductID)
--     --     self:showNetLoading()
--     -- end     
--     EventPost:addCommond(EventPost.eventType.CLICK,"点击商城商品",pData.dwProductID)          --点击礼包      --点击礼包 
-- end

-- --充值URL
-- function RechargeLayer:onPayUrlResult(data)  
--     print("onGoodBuyClick recv onPayUrlResult os.time() = ",os.time())  
--     local pItemIndex
--     local pItem
--     for i, v in ipairs(self.ListData.ProductInfos) do
--         if v and data.dwProductID and v.dwProductID == data.dwProductID then
--             pItemIndex = i
--             pItem = v
--             break
--         end
--     end
--     local pValue = pItem.lAwardValue
--     if pItem.byAttachType == 1 then
--         --附加定值
--         pValue = pValue + pItem.lAttachValue
--     elseif pItem.byAttachType == 2 then
--         --附加百分比
--         pValue = pValue*(1 + pItem.lAttachValue)
--     end
--     self.PayUrl = data.szPayUrl
    
--     -- local URL = string.format("%s?price=%d&userId=%d&productId=%d&name=%s",self.PayUrl,pItem.dwPrice,GlobalUserItem.dwUserID,pItem.dwProductID,encodeURI(GlobalUserItem.szNickName))
--     local imagePath = "client/res/recharge/GUI2/xsc_jb"..pItemIndex..".png"
--     -- local info = {}
--     -- info.url = URL  --"http://pay.abc.com/pay//epay/?price=10000&userId=7156709&productId=18&name=Leonardo%20Ole"
--     local params = {}
--     params.price = pItem.dwPrice
--     params.userId = GlobalUserItem.dwUserID
--     params.productId = pItem.dwProductID
--     params.name = encodeURI(GlobalUserItem.szNickName)
--     params.EventToken = FunctionADLogName("ad_revenue")
--     params.EventTokenFirstPay = FunctionADLogName("ad_firstRevenue")
--     params.AppToken = g_MultiPlatform:getInstance():getAdjustKey() 
--     params.DevType = "gps_adid"
--     params.DevID = g_MultiPlatform:getInstance():getAdjustGoogleAdId() 
--     params.Currency = "BRL"
--     params.mode = 0
--     dump(params,"=========url")
--     local callback = function(ok,jsonData) 
--         if ok then
--             if jsonData.code == 0 then
--                 -- dump(jsonData)
--                 print("openURL os.time() = ",os.time())
                
--                 ylAll.firstData = {}
--                 ylAll.firstData.isopen = true
--                 ylAll.firstData.bankMoney = GlobalUserItem.lUserInsure
--                 ylAll.firstData.curPayMoney = pValue
--                 ylAll.firstData.imagePath = imagePath
--                 ylAll.firstData.OrderNo = jsonData.result.orderNo
--                 ylAll.firstData.dwProductID = pItem.dwProductID
--                 --OSUtil.openURL(jsonData.result.payUrl)
--                 if device.platform == "ios" then
--                     OSUtil.openURL(jsonData.result.payUrl)
--                 else
--                     self:openWebView(jsonData.result.payUrl,pItem.dwPrice)
--                 end
--             else
--                 print(string.format("code = %s,error:%s",jsonData.code,jsonData.msg))
--                 -- showToast(jsonData.msg)
--                 showToast("System error:result content error! (Code:"..jsonData.code.."-Msg:"..jsonData.msg..")")
--             end
--         else
--             showToast(jsonData or "System error happen!")
--             -- print("HTTP GET ERROR:",jsonData)
--         end
--     end
--     g_ExternalFun.onHttpJsionTable(self.PayUrl,"POST",cjson.encode(params),callback)
--     self:showNetLoading()
-- end

function RechargeLayer:onGoodBuyClick(target)    
    print("clickGood os.time() = ",os.time())
    local pIndex = target:getTag()   
    local pItem = self.ListData.ProductInfos[pIndex]

    local pValue = pItem.lAwardValue
    if pItem.byAttachType == 1 then
        --附加定值
        pValue = pValue + pItem.lAttachValue
    elseif pItem.byAttachType == 2 then
        --附加百分比
        pValue = pValue*(1 + pItem.lAttachValue)
    end
    self.PayUrl = GlobalData.PayURL
    local imagePath = "client/res/recharge/GUI2/xsc_jb"..pIndex..".png"

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
        if ok then
            if jsonData.code == 0 then
                print("response os.time() = ",os.time())
                dump(jsonData)             
                ylAll.firstData = {}
                ylAll.firstData.isopen = true
                ylAll.firstData.bankMoney = GlobalUserItem.lUserInsure
                ylAll.firstData.curPayMoney = pValue
                ylAll.firstData.imagePath = imagePath
                ylAll.firstData.OrderNo = jsonData.result.orderNo
                ylAll.firstData.dwProductID = pItem.dwProductID
                
                if jsonData.result.qrCode == ""  then
                    local scene = cc.Director:getInstance():getRunningScene()
                    local RechargeQrCodeLayer = scene:getChildByName("RechargeQrCodeLayer")
                    if RechargeQrCodeLayer then
                        RechargeQrCodeLayer:removeFromParent()
                    end
                    OSUtil.openURL(jsonData.result.payUrl)
                else
                    self:showRechargeQrCodeLayer(jsonData.result.timestamp,jsonData.result.orderNo,jsonData.result.qrCode,pItem.dwPrice)
                end
            else
                showToast("System error:result content error! (Code:"..jsonData.code.."-Msg:"..jsonData.msg..")")
            end
        else
            showToast(jsonData or "System error happen!")
        end
    end
    g_ExternalFun.onHttpJsionTable(self.PayUrl,"POST",cjson.encode(params),callback)
    self:showNetLoading()
    EventPost:addCommond(EventPost.eventType.CLICK,"点击商城商品",pItem.dwProductID)          --点击礼包      --点击礼包 
end

-- function RechargeLayer:openWebView(url,price)
--     if string.find(url,"pix.goopago.com") then
--         -- local start,end2 = string.find(url,"param=")
--         -- local param = string.sub(url,end2 + 1,#url)
--         -- local newUrl = "https://pix.goopago.com/api/common/unified/collection/queryUserPayPage/"..param
--         -- local xhr = cc.XMLHttpRequest:new()
--         -- xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
--         -- xhr:open("GET",newUrl)
--         -- print("step1---------------"..newUrl)
--         -- xhr:registerScriptHandler(function()
--         --     dismissNetLoading()
--         --     print("step2---------------")
--         --     local ok, str, err
--         --     if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
--         --         ok, str = true, xhr.response
--         --     else
--         --         err = "http fail readyState:"..xhr.readyState.."#status:"..xhr.status
--         --         print(err)
--                  OSUtil.openURL(url)
--         --         return
--         --     end

--         --     print("step3---------------")
--         --     str = json.decode(str)
--         --     local code = str.code
--         --     print("step4---------------")
--         --     if code ~= 200 then
--         --         OSUtil.openURL(url)
--         --         return
--         --     end
--         --     print("step5---------------")
--         --     local data = str.data
--         --     local scene = cc.Director:getInstance():getRunningScene()
--         --     local RechargeQrCodeLayer = scene:getChildByName("RechargeQrCodeLayer")
--         --     if RechargeQrCodeLayer then
--         --         RechargeQrCodeLayer:doDisplay(data.orderId,data.plain,price)
--         --     else
--         --         G_event:NotifyEvent(G_eventDef.UI_OPEN_RECHARGECODE,{
--         --             orderNo = data.orderId,
--         --             httpUrl = data.plain,
--         --             price = price
--         --         })
--         --     end
--         -- end)
--         -- xhr:send()
--     else

--         local xhr = cc.XMLHttpRequest:new()
--         xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
--         xhr:open("GET",url)
--         xhr:registerScriptHandler(function()
--             dismissNetLoading()

--             local ok, str, err
--             if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
--                    ok, str = true, xhr.response
--             else
--                 err = "http fail readyState:"..xhr.readyState.."#status:"..xhr.status
--                 OSUtil.openURL(url)
--                 return
--             end
--             print("step3---------------")
--             local start1,orderNoStart = string.find(str, "orderNo = \"")
--             local start2,httpUrlStart = string.find(str, "httpUrl = \"")
    
--             if not orderNoStart or not httpUrlStart  then
--                 OSUtil.openURL(url)
--                 return
--             end
--             print("step4---------------")
--             local orderNo = ""
--             local httpUrl = ""
--             orderNoStart = orderNoStart + 1
--             httpUrlStart = httpUrlStart + 1
--             for k = orderNoStart,orderNoStart + 40 do
--                 local str = string.sub(str,k,k)
--                 if str ~= "\"" then
--                     orderNo = orderNo .. str
--                 else
--                     break
--                 end
--             end
--             print("step5---------------")
--             for k = httpUrlStart,httpUrlStart + 300 do
--                 local str = string.sub(str,k,k)
--                 if str ~= "\"" then
--                     httpUrl = httpUrl .. str
--                 else
--                     break
--                 end
--             end
--             if orderNo == "" or httpUrl == "" then
--                 OSUtil.openURL(url)
--                 return
--             end
            
--             print("step6---------------")
--             local scene = cc.Director:getInstance():getRunningScene()
--             local RechargeQrCodeLayer = scene:getChildByName("RechargeQrCodeLayer")
--             if RechargeQrCodeLayer then
--                 RechargeQrCodeLayer:doDisplay(orderNo,httpUrl,price)
--             else
--                 G_event:NotifyEvent(G_eventDef.UI_OPEN_RECHARGECODE,{
--                     orderNo = orderNo,
--                     httpUrl = httpUrl,
--                     price = price
--                 })
--             end
--         end)
--         xhr:send()
--     end    
-- end

--展示最终界面
function RechargeLayer:showRechargeQrCodeLayer(timestamp,orderNo,qrCode,price)
    local scene = cc.Director:getInstance():getRunningScene()
    local RechargeQrCodeLayer = scene:getChildByName("RechargeQrCodeLayer")
    if RechargeQrCodeLayer then
        RechargeQrCodeLayer:doDisplay(timestamp,orderNo,qrCode,price)
    else
        G_event:NotifyEvent(G_eventDef.UI_OPEN_RECHARGECODE,{
            timestamp = timestamp,
            orderNo = orderNo,
            qrCode = qrCode,
            price = price
        })
    end
end

--展示加载界面
function RechargeLayer:showNetLoading()
    local scene = cc.Director:getInstance():getRunningScene()
    local RechargeQrCodeLayer = scene:getChildByName("RechargeQrCodeLayer")
    if RechargeQrCodeLayer then
        return
    end
    G_event:NotifyEvent(G_eventDef.UI_OPEN_RECHARGECODE)
end

return RechargeLayer