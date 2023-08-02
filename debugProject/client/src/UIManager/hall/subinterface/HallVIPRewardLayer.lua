---------------------------------------------------
--Desc:VIP奖励界面
--Date:2023-04-24 11:37:40
--Author:ty
---------------------------------------------------
local HallVIPRewardLayer = class("HallVIPRewardLayer",function(args)
    local HallVIPRewardLayer =  cc.LayerColor:create(cc.c4b(0,0,0,225))
    return HallVIPRewardLayer
end)

function HallVIPRewardLayer:onExit()
    
end

function HallVIPRewardLayer:ctor(args)
    --提前加载合图
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("client/res/VIP/VIPPlist.plist", "client/res/VIP/VIPPlist.png")

    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)    
    self.csbNode = g_ExternalFun.loadCSB("VIP/LayerVIPReward.csb")
    self.csbNode:setAnchorPoint(cc.p(0.5,0.5))
    self.csbNode:setPosition(display.cx,display.cy)
    self:addChild(self.csbNode,2)    
    g_ExternalFun.loadChildrenHandler(self,self.csbNode)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
        if self.isPlaying == false then
            self:showNextVIPGift()
        end
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    --
    self.data = args or {}
    --self.data = {dwErrorCode = 0,cbTypeID = 3,wCount = 3,lsItem = {{cbLevel = 1,llScore = 100},{cbLevel = 2,llScore = 200},{cbLevel = 3,llScore = 300}}}
    self.rewardIndex = 0 --成长礼金可领取多次
    self.isPlaying = false --是否播放动画中
    self.mm_TextScore:setVisible(false)

    self:showNextVIPGift()
end

function HallVIPRewardLayer:updateView()
    local wCount = self.data.wCount or 0
    local lsItem = self.data.lsItem or {}
    local tagLevelup = lsItem[self.rewardIndex] or {}
    local cbLevel = tagLevelup.cbLevel or GlobalUserItem.VIPInfo.cbGrowLevel
    local llScore = tagLevelup.llScore or 0
    self.mm_TextVipLevel:setString(cbLevel)
    
    local score = g_format:formatNumber(llScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
    self.mm_TextScore:setString("+"..score)
end

function HallVIPRewardLayer:showVIPGift()
    self.isPlaying = true
    --光效
    if self.bgSpine1 ~= nil then
        self.bgSpine1:removeFromParent(true)
        self.bgSpine1 = nil
    end
    self.bgSpine1 = sp.SkeletonAnimation:create("client/res/VIP/spine/VIPshengjilibao1.json","client/res/VIP/spine/VIPshengjilibao1.atlas", 1)
    self:addChild(self.bgSpine1,3)
    self.bgSpine1:setPosition(display.cx+25, display.cy)
    self.bgSpine1:setAnimation(0, "ruchang", false)

    if self.bgSpine2 ~= nil then
        self.bgSpine2:removeFromParent(true)
        self.bgSpine2 = nil
    end

    self.bgSpine2 = sp.SkeletonAnimation:create("client/res/VIP/spine/VIPshengjilibao2.json","client/res/VIP/spine/VIPshengjilibao2.atlas", 1)
    self:addChild(self.bgSpine2,1)
    self.bgSpine2:setPosition(display.cx+25, display.cy)
    self.bgSpine2:setAnimation(0, "ruchang", false)
    self.bgSpine2:registerSpineEventHandler( function( event )
        if event.type == "complete" then
            self.bgSpine2:setAnimation(0, "daiji", true)
            self.isPlaying = false
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    self.bgSpine2:registerSpineEventHandler( function( event )
        if event.type == "event" then
            if event.eventData and event.eventData.name == "jinbi" then
                self.mm_TextScore:setScale(0.1)
                local scale1 = cc.ScaleTo:create(0.11,1.2)
                local scale2 = cc.ScaleTo:create(0.11,1)
                self.mm_TextScore:runAction(cc.Sequence:create(scale1,scale2))
                self.mm_TextScore:setVisible(true)
                self.isPlaying = false
            end
        end
    end, sp.EventType.ANIMATION_EVENT)
end

function HallVIPRewardLayer:showNextVIPGift()
    local wCount = self.data.wCount or 0
    if self.rewardIndex < wCount then
        self.rewardIndex = self.rewardIndex + 1
        self:showVIPGift()
        self:updateView()
    else
        self:onClickClose()
    end
end

function HallVIPRewardLayer:onClickClose()
    DoHideCommonLayerAction(self,self.csbNode,function()        
        self:removeSelf() 
    end)
end

return HallVIPRewardLayer