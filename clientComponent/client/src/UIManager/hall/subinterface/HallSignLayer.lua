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
    -- G_event:RemoveNotifyEvent(G_eventDef.UI_GET_SERVER_TIME)
end

function HallSignLayer:ctor(args)
    self.NoticeNext = args and args.NoticeNext 
    self.HandlerSign = false
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    
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

    local pDayPath = "signin/qd_Dia%d.png"
    local pCoinPath = "signin/qd_jb%d.png"
    for i=1,7 do
        self["mm_Day"..i]:onClicked(handler(self,self.onSignInClick),true) 
        self["mm_EffectDay"..i]:getChildByName("Day"):setTexture(string.format(pDayPath,i))  
        if not (i==3 or i==7) then            
            self["mm_EffectDay"..i]:getChildByName("Coin"):loadTexture(string.format(pCoinPath,i)) 
        end
    end
    --标题效果
    local pEffectTitleCsb = "signin/EffectTitle.csb"    
    local pEffectTitle = g_ExternalFun.loadTimeLine(pEffectTitleCsb)
    pEffectTitle:gotoFrameAndPlay(0, true)
    self.mm_EffectTitle:runAction(pEffectTitle)
    --光效
    local pEffectLightCsb = "signin/EffectLight.csb"    
    local pEffectLight = g_ExternalFun.loadTimeLine(pEffectLightCsb)
    pEffectLight:gotoFrameAndPlay(0, true)
    self.mm_EffectLight:runAction(pEffectLight)
    
    G_event:AddNotifyEvent(G_eventDef.NET_CHECKIN_RESULT,handler(self,self.onCheckResult))   --签到返回结果
    -- G_event:AddNotifyEvent(G_eventDef.UI_GET_SERVER_TIME,handler(self,self.onGetServerTime))   --获取服务器时间
    --查询签到
    G_ServerMgr:C2S_QueryCheckIn()
    
    self:onQuerySignInData()
end

function HallSignLayer:onSignInClick(target)
    if GlobalData.DailySign then
        G_ServerMgr:C2S_CheckinDone()
        showNetLoading()
    else
        if GlobalUserItem.szSeatPhone and  string.len(GlobalUserItem.szSeatPhone) > 0 then
            --已绑定 打开礼包
            showToast(g_language:getString("sign_tips_2"))
            if GlobalData.GiftEnable then
                local pData = {
                    ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
                    NoticeNext = false
                }
                G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
            end
            self:removeSelf()
        else
            --未绑定 打开绑定
            showToast(g_language:getString("sign_tips_1"))
            G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_AUTH,false)
            self:removeSelf()
        end
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
    self.HandlerSign = false
    -- self["mm_Light_"..GlobalUserItem.wSeriesDate]:hide()  
    -- self["mm_Got_"..GlobalUserItem.wSeriesDate]:show()
    self["mm_EffectGetAction"..GlobalUserItem.wSeriesDate]:play("animation0",false)
    self["mm_EffectGet"..GlobalUserItem.wSeriesDate]:runAction(self["mm_EffectGetAction"..GlobalUserItem.wSeriesDate])
    self["mm_EffectDayAction"..GlobalUserItem.wSeriesDate]:play("animation0",true)

    local imagePath = "client/res/signin/qd_jb"..GlobalUserItem.wSeriesDate..".png"
    self:showAward(reword,imagePath)
end

function HallSignLayer:onClickClose(target)
    local flag = target == self.mm_btnClose
    if not flag and self.HandlerSign then
        self:onSignInClick()
        return
    end
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function()         
        if self.NoticeNext then
            G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)
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
        self["mm_EffectGetAction"..i] = g_ExternalFun.loadTimeLine("signin/EffectGet.csb")
        self["mm_EffectGetAction"..i]:retain()
        self["mm_EffectGetAction"..i]:play("animation1",true)
        if i < (series+1) then
            --历史前面签过的             
            self["mm_EffectGet"..i]:runAction(self["mm_EffectGetAction"..i])
        end

        if i==7 then
            self["mm_EffectGet"..i]:getChildByName("Mask"):setContentSize(cc.size(301,633))
        end

        local pFlag = false
        if (today == false) and (i == series+1) then     
            --没签  and  今天
            self["mm_Day"..i]:setTouchEnabled(true) 
            self.HandlerSign = true           
            pFlag = true          
        end
        
        
        self["mm_EffectDayAction"..i] = nil
        if (i==3 or i==7) then
            self["mm_EffectDayAction"..i] = g_ExternalFun.loadTimeLine(string.format("signin/EffectDay%d.csb",i))            
        else
            self["mm_EffectDayAction"..i] = g_ExternalFun.loadTimeLine("signin/EffectDayNormal.csb")            
        end
        if pFlag then
            self["mm_EffectDayAction"..i]:play("animation1",true)
            self["mm_Day"..i]:setLocalZOrder(100)
        else
            self["mm_EffectDayAction"..i]:play("animation0",true)
            self["mm_Day"..i]:setLocalZOrder(1)
        end
        self["mm_EffectDay"..i]:runAction(self["mm_EffectDayAction"..i])
    end
end

function HallSignLayer:showAward(goldTxt,imagePath)
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
    local data = {}
    data.goldImg = imagePath
    data.goldTxt = g_format:formatNumber(goldTxt,g_format.fType.standard)
    data.type = 1
    appdf.req(path).new(data)
end

return HallSignLayer