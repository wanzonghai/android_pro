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

function HallVIPLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_HALL_BET_SCORE_DATA)   
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
    self.mm_LoadingBar_2:setPercent(GlobalUserItem.VIPInfo.llBetCurrent*100/GlobalUserItem.VIPInfo.llBetRequire)
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

    self.mm_Right_1:onClicked(function () self:onRightClicked(1) end)
    self.mm_Right_2:onClicked(function () self:onRightClicked(2) end)
    self.mm_Right_3:onClicked(function () self:onRightClicked(3) end)
    self.mm_Right_1:getChildByName("ValueCurr"):setString("+"..GlobalUserItem.VIPInfo.wDailyAddition.."%")
    self.mm_Right_1:getChildByName("ValueNext"):setString("+"..GlobalUserItem.VIPInfo.wDailyAdditionNext.."%")
    self.mm_Right_2:getChildByName("ValueCurr"):setString("+"..GlobalUserItem.VIPInfo.wWeeklyAddition.."%")
    self.mm_Right_2:getChildByName("ValueNext"):setString("+"..GlobalUserItem.VIPInfo.wWeeklyAdditionNext.."%")
    self.mm_Right_3:getChildByName("ValueCurr"):setString("+"..GlobalUserItem.VIPInfo.wMonthlyAddition.."%")
    self.mm_Right_3:getChildByName("ValueNext"):setString("+"..GlobalUserItem.VIPInfo.wMonthlyAdditionNext.."%")

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
    
    --呼出动效
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
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
        G_ServerMgr:C2s_getTurnUserConfig(6)            --先请求数据再打开转盘
    end)
end

return HallVIPLayer