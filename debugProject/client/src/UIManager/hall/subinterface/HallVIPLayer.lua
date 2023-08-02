---------------------------------------------------
--Desc:VIP主界面
--Date:2023-02-15 14:37:40
--Author:A*
---------------------------------------------------
local HallVIPLayer = class("HallVIPLayer",function(args)
    local HallVIPLayer =  display.newLayer()
    return HallVIPLayer
end)

HallVIPLayer.ColorW = cc.c3b(91,31,5)
HallVIPLayer.ColorP = cc.c3b(63,17,121)
local TypeID = g_ExternalFun.enum{
    "Week = 1",   --周礼包
    "Month = 2",   --月礼包
    "Growth = 3",    --成长礼包
}

local Status = g_ExternalFun.enum{
    "Unactivated = 1",   --未激活
    "Unreceived = 2",    --未领取
    "Received = 3",   --已领取
    "WaitReceive = 4",   --已激活未到领取时间
}

function HallVIPLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_VIP_GIFT_STATUS)   
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_VIP_TAKE_GIFT_RESULT)  
end

function HallVIPLayer:ctor(args)
    --提前加载合图
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("client/res/VIP/VIPPlist.plist", "client/res/VIP/VIPPlist.png")

    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)    
    local csbNode = g_ExternalFun.loadCSB("VIP/VIPLayer.csb")
    self:addChild(csbNode)    
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    --
    -- dump(GlobalUserItem.VIPInfo,"GlobalUserItem.VIPInfo",5)
    --[[
        dump from: [string "client/src/UIManager/hall/subinterface/HallVI..."]:25: in function 'ctor'
        [LUA-print] - "GlobalUserItem.VIPInfo" = {
        [LUA-print] -     "cbGrowLevel"          = 1
        [LUA-print] -     "dwPayCurrent"         = 0
        [LUA-print] -     "dwPayRequire"         = 0
        [LUA-print] -     "llBetCurrent"         = 104000
        [LUA-print] -     "llBetRequire"         = 0
        [LUA-print] -     "wDailyAddition"       = 0
        [LUA-print] -     "wDailyAdditionNext"   = 0
        [LUA-print] -     "wMonthlyAddition"     = 0
        [LUA-print] -     "wMonthlyAdditionNext" = 0
        [LUA-print] -     "wWeeklyAddition"      = 0
        [LUA-print] -     "wWeeklyAdditionNext"  = 0
        [LUA-print] - }
    ]]
    --当前VIP
    self.mm_CurLevelValue:setString(GlobalUserItem.VIPInfo.cbGrowLevel)
    self.mm_CurLevel:loadTexture(string.format("client/res/VIP/GUI/%d.png",GlobalUserItem.VIPInfo.cbGrowLevel),UI_TEX_TYPE_PLIST)
    --下一级VIP
    self.mm_NextLevel:loadTexture(string.format("client/res/VIP/GUI/%d.png",GlobalUserItem.VIPInfo.cbGrowLevel+1),UI_TEX_TYPE_PLIST)
    --充值进度条    
    self.mm_LoadingBar_1:setPercent(GlobalUserItem.VIPInfo.dwPayCurrent*100/GlobalUserItem.VIPInfo.dwPayRequire)
    local listView = self.mm_LoadingBar_1:getChildByName("listview_1")
    listView:setBounceEnabled(false) 
    listView:setScrollBarEnabled(false)
    listView:setTouchEnabled(false)
    local pCurrProgress = listView:getChildByName("CurrProgress")
    local pNeedProgress = listView:getChildByName("NeedProgress")
    local CurProgress = GlobalUserItem.VIPInfo.dwPayCurrent
    local NeedProgress = GlobalUserItem.VIPInfo.dwPayRequire

    if CurProgress < NeedProgress then
        self.mm_Less_score:setVisible(true)
        local score = g_format:formatNumber(NeedProgress-CurProgress,g_format.fType.standard)
        self.mm_Less_score:setString("Faltando "..score)
    else
        self.mm_Less_score:setVisible(false)
    end
    self.mm_Button_Jump:onClicked(function () self:jumpGiftCenter() end)

    CurProgress = g_format:formatNumber(CurProgress,g_format.fType.standard)
    NeedProgress = g_format:formatNumber(NeedProgress,g_format.fType.standard)        
    pCurrProgress:setString(CurProgress)
    pNeedProgress:setString(NeedProgress)
    if CurProgress >= NeedProgress then
        pCurrProgress:setColor(cc.c3b(138,241,247))
    else
        pCurrProgress:setColor(cc.c3b(242,229,27))
    end
    performWithDelay(listView,function() listView:jumpToRight () end,0)

    
    --投注进度条
    if GlobalUserItem.VIPInfo.llBetRequire and tonumber(GlobalUserItem.VIPInfo.llBetRequire) == 0 then
        self.mm_LoadingBar_2:setPercent(100)
    else
        self.mm_LoadingBar_2:setPercent(GlobalUserItem.VIPInfo.llBetCurrent*100/GlobalUserItem.VIPInfo.llBetRequire)
    end
    
    local listView = self.mm_LoadingBar_2:getChildByName("listview_2")
    listView:setBounceEnabled(false) 
    listView:setScrollBarEnabled(false)
    listView:setTouchEnabled(false)
    local pCurrProgress = listView:getChildByName("CurrProgress")
    local pNeedProgress = listView:getChildByName("NeedProgress")
    local CurProgress = GlobalUserItem.VIPInfo.llBetCurrent
    local NeedProgress = GlobalUserItem.VIPInfo.llBetRequire
    CurProgress = g_format:formatNumber(CurProgress,g_format.fType.standard)
    NeedProgress = g_format:formatNumber(NeedProgress,g_format.fType.standard) 
    pCurrProgress:setString(CurProgress)
    pNeedProgress:setString(NeedProgress)
    if CurProgress >= NeedProgress then
        pCurrProgress:setColor(cc.c3b(138,241,247))
    else
        pCurrProgress:setColor(cc.c3b(242,229,27))
    end
    performWithDelay(listView,function() listView:jumpToRight () end,0)

    self.mm_Right_0:onClicked(function () self:onClickGiftLeft() end)
    self.mm_Right_1:onClicked(function () self:onWeekGiftClicked() end)
    self.mm_Right_2:onClicked(function () self:onMonthGiftClicked() end)
    self.mm_Right_3:onClicked(function () self:onRightClicked(1) end)
    self.mm_Right_3:getChildByName("ValueCurr_1"):setString("+"..GlobalUserItem.VIPInfo.wDailyAddition.."%")
    self.mm_Right_3:getChildByName("ValueNext_1"):setString("+"..GlobalUserItem.VIPInfo.wDailyAdditionNext.."%")
    self.mm_Right_3:getChildByName("ValueCurr_2"):setString("+"..GlobalUserItem.VIPInfo.wWeeklyAddition.."%")
    self.mm_Right_3:getChildByName("ValueNext_2"):setString("+"..GlobalUserItem.VIPInfo.wWeeklyAdditionNext.."%")
    self.mm_Right_3:getChildByName("ValueCurr_3"):setString("+"..GlobalUserItem.VIPInfo.wMonthlyAddition.."%")
    self.mm_Right_3:getChildByName("ValueNext_3"):setString("+"..GlobalUserItem.VIPInfo.wMonthlyAdditionNext.."%")
    self.mm_Right_0:getChildByName("Button_Reward"):onClicked(function () self:onClickGiftLeft() end)
    self.mm_Right_1:getChildByName("Button_Reward"):onClicked(function () self:onWeekGiftClicked() end)
    self.mm_Right_2:getChildByName("Button_Reward"):onClicked(function () self:onMonthGiftClicked() end)
    self.nextLevel = GlobalUserItem.VIPInfo.cbGrowLevel + 1 --下一个vip等级 最大20级目前
    if self.nextLevel > 20 then
        self.nextLevel = 20
    end
    local text_vip_level = self.mm_Right_3:getChildByName("ImageV1"):getChildByName("vip_level")
    text_vip_level:setString(self.nextLevel)
    local text_vip_level = self.mm_Right_3:getChildByName("ImageV2"):getChildByName("vip_level")
    text_vip_level:setString(self.nextLevel)
    local text_vip_level = self.mm_Right_3:getChildByName("ImageV3"):getChildByName("vip_level")
    text_vip_level:setString(self.nextLevel)

    --背景
    local bgSpine = sp.SkeletonAnimation:create("client/res/VIP/spine/VIP_2.json","client/res/VIP/spine/VIP_2.atlas", 1)
    bgSpine:addTo(self.mm_Spine_bg)
    bgSpine:setPosition(0, 0)
    bgSpine:setAnimation(0, "ruchang", false)
    bgSpine:registerSpineEventHandler( function( event )
        if event.type == "complete" then
            bgSpine:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    --光效
    local bgSpine2 = sp.SkeletonAnimation:create("client/res/VIP/spine/VIP_1.json","client/res/VIP/spine/VIP_1.atlas", 1)
    bgSpine2:addTo(self.mm_Spine_pre)
    bgSpine2:setPosition(0, 0)
    bgSpine2:setAnimation(0, "ruchang", false)
    bgSpine2:registerSpineEventHandler( function( event )
        if event.type == "complete" then
            bgSpine2:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnHelp:onClicked(handler(self,self.onClickHelp),true)
    --self.mm_btnHelp:setVisible(false)

    self.mm_Button_Left:onClicked(handler(self,self.onClickLeft),true)
    self.mm_Button_Right:onClicked(handler(self,self.onClickRight),true)

    -- self.mm_Button_Gift_Left:onClicked(handler(self,self.onClickGiftLeft),true)
    -- self.mm_Button_Gift_Right:onClicked(handler(self,self.onClickGiftRight),true)

    -- --左边礼包动画
    -- local vipwlq = sp.SkeletonAnimation:create("client/res/VIP/spine/vipwlq.json","client/res/VIP/spine/vipwlq.atlas", 1)
    -- vipwlq:addTo(self.mm_Button_Gift_Left)
    -- vipwlq:setPosition(80, 80)
    -- vipwlq:setAnimation(0, "daiji1", true)

    -- --右边礼包动画
    -- local vipwlq = sp.SkeletonAnimation:create("client/res/VIP/spine/vipwlq.json","client/res/VIP/spine/vipwlq.atlas", 1)
    -- vipwlq:addTo(self.mm_Button_Gift_Right)
    -- vipwlq:setPosition(80, 80)
    -- vipwlq:setAnimation(0, "daiji2", true)
    --第一个礼包
    local ImageTips2 = self.mm_Right_0:getChildByName("ImageTips2")
    self.vipwlq = sp.SkeletonAnimation:create("client/res/VIP/spine/vipwlq.json","client/res/VIP/spine/vipwlq.atlas", 1)
    self.vipwlq:addTo(ImageTips2)
    self.vipwlq:setPosition(30, 30)
    self.vipwlq:setAnimation(0, "daiji2", true)

    --呼出动效
    ShowCommonLayerAction(self.mm_bg,self.mm_content)

    G_event:AddNotifyEvent(G_eventDef.EVENT_VIP_GIFT_STATUS,handler(self,self.onGetGrowGiftStatusResult))   --获取成长等级界面礼包状态 返回
    G_event:AddNotifyEvent(G_eventDef.EVENT_VIP_TAKE_GIFT_RESULT,handler(self,self.onTakeGrowGiftResult))   --提取成长礼包 返回
    G_ServerMgr:C2S_GetGrowGiftStatus()            --先请求数据再打开转盘
end

-- 周六周日才能领取
-- 25号之后才能领取
-- Só é possível receber no sábado e domingo.
-- Só é possível receber após o dia 25.
function HallVIPLayer:onWeekGiftClicked()
    local cbStatus = self.GiftStatus.weekGift.cbStatus --当前奖励的状态：1未激活 2 可领取 3已领取
    if cbStatus == Status.Unactivated then
        showToast("Desbloqueie pacotes de presente com qualquer recarga esta semana") 
        self:showQueryDialog()
        --G_ServerMgr:C2S_TakeGrowGift(1)
    elseif cbStatus == Status.WaitReceive then
            showToast("Só é possível receber no sábado e domingo.") 
    elseif cbStatus == Status.Unreceived then
        G_ServerMgr:C2S_TakeGrowGift(TypeID.Week) --1表示周礼金，2表示月礼金, 3表示成长礼金
    end
end
function HallVIPLayer:onMonthGiftClicked()
    local cbStatus = self.GiftStatus.monthGift.cbStatus --当前奖励的状态：1未激活 2 可领取 3已领取
    if cbStatus == Status.Unactivated then
        showToast("Desbloqueie o pacote de presente com qualquer recarga este mês")
        self:showQueryDialog()
        --G_ServerMgr:C2S_TakeGrowGift(2) 
    elseif cbStatus == Status.WaitReceive then
        showToast("Só é possível receber após o dia 25.") 
    elseif cbStatus == Status.Unreceived then
        G_ServerMgr:C2S_TakeGrowGift(TypeID.Month) --1表示周礼金，2表示月礼金, 3表示成长礼金
    end
end
function HallVIPLayer:onClickGiftLeft()
    local cbStatus = self.GiftStatus.growGift.cbStatus --当前奖励的状态：1未激活 2 可领取 3已领取
    if cbStatus == Status.Unreceived then
        G_ServerMgr:C2S_TakeGrowGift(TypeID.Growth) --1表示周礼金，2表示月礼金, 3表示成长礼金
    elseif cbStatus == Status.Received then --升级VIP，继续免费领取
        local str = "Atualize para VIP e continue obtendo gratuitamente."
        self:showQueryDialog(str)
    else
        showToast("Você ainda não atingiu o V"..self.nextLevel..". Não pode reivindicar.") 
        self:showQueryDialog()
    end
end
function HallVIPLayer:onClickGiftRight()
    showToast("Você ainda não atingiu o V"..self.nextLevel..". Não pode reivindicar.") 
end

function HallVIPLayer:showQueryDialog(str)
    --local QueryDialog = appdf.req("client.src.UIManager.hall.subinterface.CommonDialog")
    local txt = str or "Recarregue para desbloquear, gostaria de ir para a recarga?"     --您的话费订单已提交,如您三日内未

    local pData = {
        msg = txt,
        callback = function(click)
            if click == "ok" then      
                self:jumpGiftCenter()
            end					
        end
    }
    G_event:NotifyEvent(G_eventDef.UI_OPEN_COMMON_DIALOG,pData)
end

function HallVIPLayer:jumpGiftCenter()
    if  GlobalData.ProductsOver and GlobalData.GiftEnable and GlobalData.PayInfoOver then            
        local pData = {
            ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
            NoticeNext = self.NoticeNext
        }
        G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
    end
    self:removeSelf()
end

function HallVIPLayer:onGetGrowGiftStatusResult(pData)
    dump(pData)
    self.GiftStatus = pData or {}
    self:updateGiftItem(self.mm_Right_1,self.GiftStatus.weekGift)
    self:updateGiftItem(self.mm_Right_2,self.GiftStatus.monthGift)
    self:updateGiftItem(self.mm_Right_0,self.GiftStatus.growGift)
    -- local growGift = self.GiftStatus.growGift --成长礼金
    -- local cbStatus = growGift.cbStatus --当前奖励的状态：1未激活 2 可领取 3已领取
    -- self:updateGiftBtnStatus(self.mm_Right_0,cbStatus)
end

--刷新成长礼包状态
function HallVIPLayer:updateGiftBtnStatus(cbStatus) --当前奖励的状态：1未激活 2 可领取 3已领取
    self.Gift_cbStatus = cbStatus

    local ImageLock = item:getChildByName("ImageLock")
    local ImageStatus = item:getChildByName("ImageStatus")
    local ImagePoint = item:getChildByName("ImagePoint")
    if self.Gift_cbStatus == Status.Unreceived then
        self.mm_Button_Gift_Left:setVisible(true)
        self.mm_Button_Gift_Right:setVisible(false)
    else
        self.mm_Button_Gift_Left:setVisible(false)
        self.mm_Button_Gift_Right:setVisible(true)
    end
    -- if cbStatus == Status.Unreceived then
    --     self.mm_Button_Gift_Left:setVisible(true)
    --     self.mm_Button_Gift_Right:setVisible(false)
    -- else
    --     self.mm_Button_Gift_Left:setVisible(false)
    --     self.mm_Button_Gift_Right:setVisible(true)
    -- end
end

function HallVIPLayer:updateGiftItem(item,data)
    local cbStatus = data.cbStatus --当前奖励的状态：s1未激活 2 可领取 3已领取
    
    self:updateGiftItemStatus(item,cbStatus)

    --local nextLevel = GlobalUserItem.VIPInfo.cbGrowLevel + 1 --self.GiftStatus.cbGrowLevel + 1
    local rewardScore = g_format:formatNumber(data.llRewardScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
    local score = g_format:formatNumber(data.llScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
    local nextScore = g_format:formatNumber(data.llNextScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
    local Text_ValueCurr = item:getChildByName("Text_ValueCurr")
    if GlobalUserItem.VIPInfo.cbGrowLevel <= 0 then
        Text_ValueCurr:setString(nextScore)
    else
        Text_ValueCurr:setString(rewardScore)
    end
    
    local text_vip_level = item:getChildByName("ImageV1"):getChildByName("vip_level")
    text_vip_level:setString(self.nextLevel)
    local ValueCurr = item:getChildByName("ValueCurr")
    --local score = g_format:formatNumber(data.llScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
    ValueCurr:setString(score)--当前等级可领取的奖励，真金服需要除以100
    local ValueNext = item:getChildByName("ValueNext")
    --local nextScore = g_format:formatNumber(data.llNextScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
    ValueNext:setString(nextScore)--下一级可领取到的奖励，真金服需要除以100

end

-- "Unactivated = 1",   --未激活
-- "Unreceived = 2",    --未领取
-- "Received = 3",   --已领取
-- "WaitReceive = 4",   --已激活未到领取时间
--刷新周月礼包状态
function HallVIPLayer:updateGiftItemStatus(item,cbStatus) --当前奖励的状态：1未激活 2 可领取 3已领取
    local ImageLock = item:getChildByName("ImageLock")
    local ImageStatus = item:getChildByName("ImageStatus")
    local ImagePoint = item:getChildByName("ImagePoint")
    local Button_Reward = item:getChildByName("Button_Reward")
    local ValueCurr = item:getChildByName("ValueCurr")
    local ValueNext = item:getChildByName("ValueNext")
    --cbStatus = Status.Received
    if cbStatus == Status.Unactivated then
        --ImageLock:setVisible(true)
        ImageStatus:setVisible(false)
        ImagePoint:setVisible(false)
        Button_Reward:setVisible(true)
        ValueCurr:setVisible(false)
        ValueNext:setVisible(false)
        self.vipwlq:setAnimation(0, "daiji2", true)
        ImageStatus:ignoreContentAdaptWithSize(true)
        ImageStatus:loadTexture("client/res/VIP/GUI/vip_suozhu.png",UI_TEX_TYPE_PLIST)
    elseif cbStatus == Status.Unreceived then
        --ImageLock:setVisible(false)
        ImageStatus:setVisible(false)
        ImagePoint:setVisible(true)
        Button_Reward:setVisible(true)
        ValueCurr:setVisible(false)
        ValueNext:setVisible(false)
        self.vipwlq:setAnimation(0, "daiji1", true)
    elseif cbStatus == Status.Received then
        --ImageLock:setVisible(false)
        ImageStatus:setVisible(true)
        ImagePoint:setVisible(false)
        Button_Reward:setVisible(false)
        ValueCurr:setVisible(true)
        ValueNext:setVisible(true)
        self.vipwlq:setAnimation(0, "daiji2", true)
        ImageStatus:ignoreContentAdaptWithSize(true)
        ImageStatus:loadTexture("client/res/VIP/GUI/vip_jlingqu.png",UI_TEX_TYPE_PLIST)
    elseif cbStatus == Status.WaitReceive then
        --ImageLock:setVisible(false)
        ImageStatus:setVisible(false)
        ImagePoint:setVisible(false)
        Button_Reward:setVisible(true)
        ValueCurr:setVisible(false)
        ValueNext:setVisible(false)
        self.vipwlq:setAnimation(0, "daiji2", true)
    end
    ImageLock:setVisible(false)
    --ImageStatus:setVisible(false)

    if GlobalUserItem.VIPInfo.cbGrowLevel <= 0 then
        Button_Reward:setVisible(false)
        ValueCurr:setVisible(true)
        ValueNext:setVisible(true)
    end
end

function HallVIPLayer:onTakeGrowGiftResult(pData)
    dump(pData)
    local wCount = pData.wCount or 0 --如果用户升级的时候跳级，则可能有多个成长礼金下发,但周月礼金只有1个
    if wCount > 0 then
        --刷新当前界面状态
        local cbTypeID = pData.cbTypeID --1表示周礼金，2表示月礼金，3表示成长礼金
        if cbTypeID == TypeID.Week then
            self:updateGiftItemStatus(self.mm_Right_1,Status.Received) --当前奖励的状态：1未激活 2 可领取 3已领取
        elseif cbTypeID == TypeID.Month then
            self:updateGiftItemStatus(self.mm_Right_2,Status.Received)
        elseif cbTypeID == TypeID.Growth then
            self:updateGiftItemStatus(self.mm_Right_0,Status.Received)
            --self:updateGiftBtnStatus(self.mm_Right_0,Status.Received)
        end
        --显示奖励界面
        G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_VIP_REWARD,pData)
        --刷新用户金币
        G_ServerMgr:C2S_RequestUserGold()
    end
end

function HallVIPLayer:onClickLeft()
    self.mm_ScrollView_1:scrollToLeft(0.05,false)
end

function HallVIPLayer:onClickRight()
    self.mm_ScrollView_1:scrollToRight(0.05,false)
end

function HallVIPLayer:onClickHelp()
    appdf.req("client.src.UIManager.hall.subinterface.HallVIPHelpLayer").new()
end

function HallVIPLayer:onClickClose()
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function()        
        self:removeSelf() 
    end)
end

function HallVIPLayer:onRightClicked(pIndex)
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function()        
        self:removeSelf()                 
        -- G_event:NotifyEvent(G_eventDef.UI_SHOW_TURNTABLE,{ShowType=pIndex}) --打开转盘
        local TurnTableManager = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.subinterface.TurnTable.TurnTableManager")
        TurnTableManager.setShowType(pIndex)
        if not TurnTableManager.getData() then
            G_ServerMgr:C2s_getTurnConfig() 
        end
        G_ServerMgr:C2s_getTurnUserConfig(6)            --先请求数据再打开转盘
    end)
end


return HallVIPLayer