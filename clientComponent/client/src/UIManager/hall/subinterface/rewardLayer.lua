--奖励动画
local rewardLayer = class("rewardLayer",function(args)
    local rewardLayer =  display.newLayer()
    return rewardLayer
end)

function rewardLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)    
    
    local csbNode = g_ExternalFun.loadCSB("award/awardNode.csb")    
    self:addChild(csbNode)
    csbNode:setPosition(display.center)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    self.mm_bg:setContentSize(display.size)
    self.mm_bg:onClicked(function()
        self:stopAllActions()
        self:removeSelf() 
    end)

    --背景
    self.SpineBg = sp.SkeletonAnimation:create("award/gognxihuode_2.json","award/gognxihuode_2.atlas", 1)
    self.SpineBg:addTo(self.mm_spine_1)
    self.SpineBg:setPosition(0, 0)
    self.SpineBg:setAnimation(0, "ruchang", false)        
    self.SpineBg:registerSpineEventHandler( function( event )
        if event.animation == "ruchang" then
            self.SpineBg:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    --光效
    self.SpineLight = sp.SkeletonAnimation:create("award/gognxihuode_1.json","award/gognxihuode_1.atlas", 1)
    self.SpineLight:addTo(self.mm_spine_2)
    self.SpineLight:setPosition(0, 0)
    self.SpineLight:setAnimation(0, "ruchang", false)        
    self.SpineLight:registerSpineEventHandler( function( event )
        if event.animation == "ruchang" then
            self.SpineLight:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    --按钮
    self.SpineButton = sp.SkeletonAnimation:create("award/anniu.json","award/anniu.atlas", 1)
    self.SpineButton:addTo(self.mm_spine_3)
    self.SpineButton:setPosition(0, 0)
    self.SpineButton:setAnimation(0, "ruchang", false)        
    self.SpineButton:registerSpineEventHandler( function( event )
        if event.animation == "ruchang" then
            self.SpineButton:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)
    self:loadContent(args.goldTxt,args.goldImg,args.type)

    self.nodeAction = g_ExternalFun.loadTimeLine("award/awardNode.csb")
    self.nodeAction:gotoFrameAndPlay(0, false)
    csbNode:runAction(self.nodeAction)
end

function rewardLayer:loadContent(goldStr,goldImg,type)
    if goldImg then
        self.mm_Sprite_content:setTexture(goldImg)
    end
    self.mm_Count_content:setString(goldStr)
end

return rewardLayer