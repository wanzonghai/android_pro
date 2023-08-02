---------------------------------------------------
--Desc:砸金蛋界面
--Date:2023-03-21 17:37:40
--Author:ty
---------------------------------------------------
local HallEggBreakLayer = class("HallEggBreakLayer",function(args)
    local HallEggBreakLayer =  display.newLayer(cc.c4b(0,0,0,225))
    return HallEggBreakLayer
end)

function HallEggBreakLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_EGG_BREAK)
end

function HallEggBreakLayer:ctor(args)
    self.llscore = 0 --奖励数值
    self.isBreak = false --是否已经敲蛋

    self.NoticeNext = args and args.NoticeNext 
    --提前加载合图    
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    local child = parent:getChildByName("Egg")
    if child then
        child:removeFromParent(true)
    end

    parent:addChild(self,ZORDER.POPUP)    
    self:setName("Egg")
    
    self.touchBtn = ccui.Button:create()--("public/clip.png", "", "", 0)
    self.touchBtn:ignoreContentAdaptWithSize(false)
    self.touchBtn:setContentSize(cc.size(500,800))
    self.touchBtn:setPosition(display.cx, display.cy-80)
    self.touchBtn:addTouchEventListener(function(psender,type)
        if type == ccui.TouchEventType.ended then
            self:reqEggBreak()
        end
    end)
    self:addChild(self.touchBtn,1)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
        --self:onClickClose()
        --self:reqEggBreak()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    --蛋
    self.bgSpine = sp.SkeletonAnimation:create("client/res/egg/spine/zhajindan.json","client/res/egg/spine/zhajindan.atlas", 1)
    self.bgSpine:addTo(self)
    self.bgSpine:setPosition(display.cx, display.cy)
    self.bgSpine:setAnimation(0, "ruchang", false) --zhadan
    self.bgSpine:addAnimation(0, "daiji", true)
    self.bgSpine:registerSpineEventHandler( function( event )
        if event.animation == "zhadan" and event.type == "complete" then
            self:showAward()
            self:onClickClose()
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    local function onNodeEvent(event)
        if event == "enter" then
        elseif event == "exit" then
            self:onExit()
        end
    end

    self:registerScriptHandler(onNodeEvent)
    G_event:AddNotifyEvent(G_eventDef.EVENT_EGG_BREAK,handler(self,self.OnEggBreakResult))  --下载进度更新 OnUpdateDownProgress
end

function HallEggBreakLayer:reqEggBreak()
    if not self.isBreak then
        self.isBreak = true
        G_ServerMgr:C2s_getEggBreakResult()                            --获取砸金蛋奖励
    end
end

function HallEggBreakLayer:OnEggBreakResult(data)
    dump(data)
    self.llscore = data.llscore or 0
    self.bgSpine:setAnimation(0, "zhadan", false)
end

--展示奖励界面
function HallEggBreakLayer:showAward()
    if self.llscore > 0 then
        self:showAwardLayer(self.llscore,"client/res/public/mrrw_jb_3.png")
    else
        if self.NoticeNext then
            G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="EggBreak"})
        end
    end
end

function HallEggBreakLayer:showAwardLayer(goldTxt,goldImg)
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
    local data = {}
    data.goldTxt = g_format:formatNumber(goldTxt,g_format.fType.standard)
    data.goldImg = goldImg
    data.type = 1
    if self.NoticeNext then
        data.callback = function()
            G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="EggBreak"})
        end
    end
    appdf.req(path).new(data)
end

function HallEggBreakLayer:onClickClose()
    --local delay = cc.DelayTime:create(0.2)
    local delay = CCFadeTo:create(0.1,0)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
        if not tolua.isnull(self) then
            self:removeSelf() 
        end
    end))
    self.bgSpine:runAction(sequence)
end


return HallEggBreakLayer