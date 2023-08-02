---------------------------------------------------
--Desc:每日签到界面
--Date:2022-09-21 15:28:47
--Author:A*
---------------------------------------------------
local HallSignLayer = class("HallSignLayer",function(args)
    local HallSignLayer =  display.newLayer()
    return HallSignLayer
end)

function HallSignLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_CHECKIN_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.SIGN_CONTINUE_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.REFRESH_SEVENDAILY)
    
    for k = 1,7 do
        local effectAction = self["mm_EffectGetAction"..k]
        if effectAction then
            effectAction:release()
        end
    end
    -- G_event:RemoveNotifyEvent(G_eventDef.UI_GET_SERVER_TIME)
end

function HallSignLayer:ctor(args)
    self.NoticeNext = args and args.NoticeNext 
    self.HandlerSign = false
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("signin/SigninLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
    self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)
    local function touchCallBack(event)
        if event.name == "ended" then
            self:onClickContent()
        end
    end
    self.mm_content:setTouchEnabled(true)
    self.mm_content:onTouch(touchCallBack)

    local pDayPath = "client/res/signin/GUI/qd_Dia%d.png"
    local pCoinPath = "client/res/signin/GUI/mrdl_jb%d.png"

    for i=1,7 do
        self["mm_Day"..i]:onClicked(handler(self,self.onSignInClick),true) 
        local pDay = self["mm_EffectDay"..i]:getChildByName("Day")
        pDay:loadTexture(string.format(pDayPath,i),UI_TEX_TYPE_PLIST)  
        pDay:ignoreContentAdaptWithSize(true)
        if i ~= 7 then
            pDay:setPositionY(126 + (i - 1) * 12)
        end
        if not (i==7) then            
            local pCoin = self["mm_EffectDay"..i]:getChildByName("Coin")
            pCoin:ignoreContentAdaptWithSize(true)
            pCoin:loadTexture(string.format(pCoinPath,i),1) 
            pCoin:setAnchorPoint(0.5,0)
            pCoin:setPositionY(-80)
        end
    end  
    --标题效果
    local pEffectTitleCsb = "signin/EffectTitle.csb"    
    local pEffectTitle = g_ExternalFun.loadTimeLine(pEffectTitleCsb)
    pEffectTitle:gotoFrameAndPlay(0, true)
    self.mm_EffectTitle:runAction(pEffectTitle)
    --光效
    -- local pEffectLightCsb = "signin/EffectLight.csb"    
    -- local pEffectLight = g_ExternalFun.loadTimeLine(pEffectLightCsb)
    -- pEffectLight:gotoFrameAndPlay(0, true)
    -- self.mm_EffectLight:runAction(pEffectLight)
    
    G_event:AddNotifyEvent(G_eventDef.NET_CHECKIN_RESULT,handler(self,self.onCheckResult))   --签到返回结果
    G_event:AddNotifyEvent(G_eventDef.SIGN_CONTINUE_RESULT,handler(self,self.receiveContinue))   --连续签到返回结果
    -- G_event:AddNotifyEvent(G_eventDef.UI_GET_SERVER_TIME,handler(self,self.onGetServerTime))   --获取服务器时间
    G_event:AddNotifyEvent(G_eventDef.REFRESH_SEVENDAILY,handler(self,self.setSevenContinousInfo))   --连续签到得数据
    showNetLoading()
    --查询签到
    
    
    G_ServerMgr:C2S_QueryCheckIn()
    
    self:onQuerySignInData()
    self:addBackSpine()
end

function HallSignLayer:addBackSpine()
    local spine = self:addSpine(self.mm_spineNode,"client/res/spine/SignSevenDay/dengguang.json","client/res/spine/SignSevenDay/dengguang.atlas")
    spine:setAnimation(0, "daiji", true)
    spine:setPosition(cc.p(-10,-20))
end

function HallSignLayer:onSignInClick(target)
    if GlobalData.DailySign then
        G_ServerMgr:C2S_CheckinDone()        
    else
        --if GlobalUserItem.szSeatPhone and  string.len(GlobalUserItem.szSeatPhone) > 0 then
            --已绑定 打开礼包
            showToast(g_language:getString("sign_tips_2"))
            --local QueryDialog = appdf.req("client.src.UIManager.hall.subinterface.CommonDialog")
            local txt = "Recarregue para desbloquear, gostaria de ir para a recarga?"     --您的话费订单已提交,如您三日内未
            
            local pData = {
                msg = txt,
                callback = function(click)
                    if click == "ok" then     
                        if  GlobalData.ProductsOver and GlobalData.GiftEnable and GlobalData.PayInfoOver and not GlobalData.TodayPay then            
                            local pData = {
                                ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
                                NoticeNext = self.NoticeNext
                            }
                            G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
                        end
                        self:removeSelf()
                    end					
                end
            }
            G_event:NotifyEvent(G_eventDef.UI_OPEN_COMMON_DIALOG,pData)
        -- else
        --     --未绑定 打开绑定
        --     showToast(g_language:getString("sign_tips_1"))
        --     G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_AUTH,self.NoticeNext)
        --     self:removeSelf()
        --end
    end
end

--签完返回  
function HallSignLayer:onCheckResult()
    dismissNetLoading()
    if GlobalUserItem.bSuccessed ~= true then
        showToast(g_language:getString(104))
        self:onClickClose(self.mm_btnClose)
        return 
    end
    local reword = GlobalUserItem.lRewardGold[GlobalUserItem.wSeriesDate] or 0    
    self["mm_Day"..GlobalUserItem.wSeriesDate]:setTouchEnabled(false)
    local canReceive = self["mm_Day"..GlobalUserItem.wSeriesDate]:getChildByName("canReceive")  
    canReceive:hide()
    if self.canlingQuSpine then
        self.canlingQuSpine:hide()
    end
    self.HandlerSign = false
    -- self["mm_Light_"..GlobalUserItem.wSeriesDate]:hide()  
    -- self["mm_Got_"..GlobalUserItem.wSeriesDate]:show()
    self["mm_EffectGetAction"..GlobalUserItem.wSeriesDate]:play("animation0",false)
    self["mm_EffectGet"..GlobalUserItem.wSeriesDate]:runAction(self["mm_EffectGetAction"..GlobalUserItem.wSeriesDate])
    self["mm_EffectDayAction"..GlobalUserItem.wSeriesDate]:play("animation0",true)

    local imagePath = "client/res/signin/GUI/mrdl_jb"..GlobalUserItem.wSeriesDate..".png"
    self:showAward(reword,imagePath)

    G_ServerMgr:C2S_QueryCheckIn()                  --再获取一下签到信息
end

function HallSignLayer:onClickClose(target)
    local flag = target == self.mm_btnClose
    if not flag and self.HandlerSign then
        self:onSignInClick()
        return
    end
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function()         
        if self.NoticeNext then
            G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="HallSign"})
        end
        self:removeSelf() 
    end)
end

function HallSignLayer:onClickContent()
    if self.HandlerSign then
        self:onSignInClick()
        return
    end
end

function HallSignLayer:onQuerySignInData()
    local series = GlobalUserItem.wSeriesDate  --连续日期
	local today = GlobalUserItem.bTodayChecked 	--今日签到
    -- dump(GlobalUserItem.lRewardGold,"GlobalUserItem.lRewardGold",5)
    for i,v in ipairs(GlobalUserItem.lRewardGold) do
        local formatMoney = g_format:formatNumber(v,g_format.fType.standard,g_format.currencyType.GOLD)
        self["mm_EffectDay"..i]:getChildByName("Value"):setString(formatMoney)
        self["mm_Day"..i]:setTouchEnabled(false) 
        local canReceive = self["mm_Day"..i]:getChildByName("canReceive")     
        canReceive:hide()  
        self["mm_EffectGetAction"..i] = g_ExternalFun.loadTimeLine("signin/EffectGet.csb")
        self["mm_EffectGetAction"..i]:retain()
        self["mm_EffectGetAction"..i]:play("animation1",true)
        if i < (series+1) then
            --历史前面签过的             
            self["mm_EffectGet"..i]:runAction(self["mm_EffectGetAction"..i])
        end

        -- if i==7 then
        --     self["mm_EffectGet"..i]:getChildByName("Mask"):setContentSize(cc.size(301,633))
        -- end

        local pFlag = false
        if (today == false) and (i == series+1) then     
            --没签  and  今天
            self["mm_Day"..i]:setTouchEnabled(true) 
            self.HandlerSign = true           
            pFlag = true
            local size = self["mm_Day"..i]:getContentSize()
            self.canlingQuSpine = self:addSpine(self["mm_Day"..i],"client/res/spine/SignSevenDay/xuanzhekuan.json","client/res/spine/SignSevenDay/xuanzhekuan.atlas")          
            self.canlingQuSpine:setAnimation(0,tostring(i), true)
            self.canlingQuSpine:setPosition(cc.p(size.width/2,size.height/2))
            canReceive:show()
        end
        
        
        self["mm_EffectDayAction"..i] = nil
        if (i==3 or i==7) then
            self["mm_EffectDayAction"..i] = g_ExternalFun.loadTimeLine(string.format("signin/EffectDay%d.csb",i))            
        else
            self["mm_EffectDayAction"..i] = g_ExternalFun.loadTimeLine("signin/EffectDayNormal.csb")            
        end
        if pFlag then
            self["mm_EffectDayAction"..i]:play("animation1",true)
         --   self["mm_Day"..i]:setLocalZOrder(100)
        else
            self["mm_EffectDayAction"..i]:play("animation0",true)
          --  self["mm_Day"..i]:setLocalZOrder(1)
        end
        self["mm_EffectDay"..i]:runAction(self["mm_EffectDayAction"..i])
    end
end

--设置七天签到信息
function HallSignLayer:setSevenContinousInfo()
    local continuousSevenSign = GlobalUserItem.continuousSevenSign
    local wSeriesDays = continuousSevenSign.wSeriesDays         --连续签到天数
    local cbSeriesAllow = continuousSevenSign.cbSeriesAllow     --是否有可领取连续签到的奖励
    local lSerialCheckInReward = continuousSevenSign.lSerialCheckInReward   --连续签到奖励
    local barWidth = self.mm_labarBg:getContentSize().width
    local icon1 = self.mm_labarBg:getChildByName("icon1")
    local maxValue1 = (icon1:getPositionX() / barWidth) * 100
    local icon2 = self.mm_labarBg:getChildByName("icon2")
    local maxValue2 = (icon2:getPositionX() / barWidth) * 100
    local icon3 = self.mm_labarBg:getChildByName("icon3")
    local maxValue3 = (icon3:getPositionX() / barWidth) * 100
    local icon4 = self.mm_labarBg:getChildByName("icon4")
    local maxValue4 = 100
    local day1 = 10
    local day2 = 15
    local day3 = 20
    local day4 = 30
    if wSeriesDays <= day1 then
        self.mm_dayLoadBar:setPercent(wSeriesDays / day1 * maxValue1)
    elseif wSeriesDays <= day2 then
        self.mm_dayLoadBar:setPercent((wSeriesDays - day1) / (day2 - day1) * (maxValue2 - maxValue1) + maxValue1)
    elseif wSeriesDays <= day3 then
        self.mm_dayLoadBar:setPercent((wSeriesDays - day2) / (day3 - day2) * (maxValue3 - maxValue2) + maxValue2)
    elseif wSeriesDays <= day4 then
        self.mm_dayLoadBar:setPercent((wSeriesDays - day3) / (day4 - day3) * (maxValue4 - maxValue3) + maxValue3)
    end

    self.mm_dayText:setString(wSeriesDays)
    if self.receivedSpineNode then 
        self.receivedSpineNode:hide() 
    end

    for k = 1,#lSerialCheckInReward do
        local info = lSerialCheckInReward[k]
        local llScore = info.llScore
        local wDays = info.wDays
        local text = self.mm_textNode:getChildByName("textDay"..k)
        local icon = self.mm_labarBg:getChildByName("icon"..k)
        text:setString(g_format:formatNumber(llScore,g_format.fType.standard,g_format.currencyType.GOLD))
        icon._index = k
        icon:onClicked(nil)
        if icon._spine then
            icon._spine:hide()
        end
        if wSeriesDays >= wDays then                 --如果签到超过了当前天
            if cbSeriesAllow[k] then                --如果还没领取
                icon:setTouchEnabled(true)
                icon:setColor(cc.c3b(255,255,255))
                self:addIconSpine(icon)
            else
                icon:setTouchEnabled(false)
                icon:setColor(cc.c3b(159,159,159))
            end
        else                                    
            if cbSeriesAllow[k] then                --如果可以领取
                self:addIconSpine(icon)
            end
            icon:setTouchEnabled(true)
            icon:setColor(cc.c3b(255,255,255))
        end
    end
end

function HallSignLayer:addIconSpine(icon)
    if icon._spine then
        icon._spine:show()
        return
    end
    icon._spine = self:addSpine(icon,"client/res/spine/SignSevenDay/kelingqu.json","client/res/spine/SignSevenDay/kelingqu.atlas")
    icon._spine:setAnimation(0,"daiji", true)
    icon._spine:setPosition(cc.p(icon:getContentSize().width/2,icon:getContentSize().height/2))
    icon:onClicked(function() 
        showNetLoading()
        G_ServerMgr:requestContinueSign(icon._index)           --点击领奖
        self._onClickIndex = icon._index
    end)
end

--连续签到领奖返回结果
function HallSignLayer:receiveContinue(pData)
    dismissNetLoading()
    local dwErrorCode = pData.dwErrorCode
    local llScore = pData.llScore
    if dwErrorCode ~= 0 then
        return
    end
    local imagePath = "client/res/signin/GUI/mrdl_jd"..(self._onClickIndex + 2)..".png"
    self:showAward(llScore,imagePath)
    local continuousSevenSign = GlobalUserItem.continuousSevenSign
    continuousSevenSign.cbSeriesAllow[self._onClickIndex] = false     --是否有可领取连续签到的奖励
    self:setSevenContinousInfo()
end

function HallSignLayer:showAward(goldTxt,imagePath)
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
    local data = {}
    data.goldImg = imagePath
    data.goldImgPlistType = 1
    data.goldTxt = g_format:formatNumber(goldTxt,g_format.fType.standard)
    data.type = 1
    appdf.req(path).new(data)
end

function HallSignLayer:addSpine(parentNode,jsonPath,atlasPath)
    local spine = sp.SkeletonAnimation:createWithJsonFile(jsonPath,atlasPath, 1)        
    spine:addTo(parentNode)
    return spine
end

return HallSignLayer

