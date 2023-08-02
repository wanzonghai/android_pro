---------------------------------------------------
--Desc:VIP升级界面
--Date:2023-03-20 14:37:40
--Author:ty
---------------------------------------------------
local HallVIPUpLayer = class("HallVIPUpLayer",function(args)
    local HallVIPUpLayer =  cc.LayerColor:create(cc.c4b(0,0,0,225))
    return HallVIPUpLayer
end)

function HallVIPUpLayer:onExit()

end

function HallVIPUpLayer:ctor(args)
    --提前加载合图
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("client/res/VIP/VIPPlist.plist", "client/res/VIP/VIPPlist.png")

    
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    local child = parent:getChildByName("VIPUp")
    if child then
        child:removeFromParent(true)
    end

    parent:addChild(self,ZORDER.POPUP+1)    
    self:setName("VIPUp")
    local csbNode = g_ExternalFun.loadCSB("VIP/VIPUpLayer.csb")
    self:addChild(csbNode)    
    g_ExternalFun.loadChildrenHandler(self,csbNode)

    self.m_timeline = cc.CSLoader:createTimeline("VIP/VIPUpLayer.csb");	
    self.m_timeline:clearFrameEndCallFuncs()
    self.m_timeline:play("shengji",false)
    self:runAction(self.m_timeline)
    self.m_timeline:setLastFrameCallFunc(function() 
        self.m_timeline:play("daiji",true)
    end)

    local last_vip_lv = GlobalUserItem.VIPLevel - 1--GlobalUserItem.VIPLevel - 1
    if args and args.last_vip_lv then
        last_vip_lv = args.last_vip_lv
    end
    if last_vip_lv < 0 then
        last_vip_lv = 0
    end
    
    self.mm_Sprite_1:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("client/res/VIP/GUI/%d.png",last_vip_lv)))
    self.m_timeline:setFrameEventCallFunc(function(frameEventName)
        if(frameEventName:getEvent()=="shengji") then
            local level = GlobalUserItem.VIPLevel
		    self.mm_Sprite_1:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("client/res/VIP/GUI/%d.png",level)))
		end
    end)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
        self:onClickClose()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    --光效
    local bgSpine = sp.SkeletonAnimation:create("client/res/VIP/spine/VIPsj_1.json","client/res/VIP/spine/VIPsj_1.atlas", 1)
    bgSpine:addTo(self.mm_Node_spine_2)
    bgSpine:setPosition(0, 0)
    bgSpine:setAnimation(0, "shengji", false)
    bgSpine:registerSpineEventHandler( function( event )
        if event.type == "complete" then
            bgSpine:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    --背景
    local bgSpine2 = sp.SkeletonAnimation:create("client/res/VIP/spine/VIPsj_2.json","client/res/VIP/spine/VIPsj_2.atlas", 1)
    bgSpine2:addTo(self.mm_Node_spine_1)
    bgSpine2:setPosition(0, 0)
    bgSpine2:setAnimation(0, "shengji", false)
    bgSpine2:registerSpineEventHandler( function( event )
        if event.type == "complete" then
            bgSpine2:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)
end

function HallVIPUpLayer:onClickClose()
    DoHideCommonLayerAction(self.mm_Image_1,self.mm_Node_spine_1,function() 
        if not tolua.isnull(self) then
            self:removeSelf() 
        end
    end)
end


return HallVIPUpLayer