--奖励动画
local rewardLayer = class("rewardLayer",function(args)
    local rewardLayer =  display.newLayer()
    return rewardLayer
end)
local NumberScrollHelper = appdf.req(appdf.CLIENT_SRC.."Tools.NumberScrollHelper")

function rewardLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.REWARD)    
    
    local csbNode = g_ExternalFun.loadCSB("award/awardNode.csb")    
    self:addChild(csbNode)
    csbNode:setPosition(display.center)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    self.mm_bg:setContentSize(display.size)
    self.mm_bg:onClicked(function()
        self:stopAllActions()
        if args and args.callback then
            args.callback()
        end
        self:removeSelf() 
        G_event:NotifyEvent(G_eventDef.UPDATE_TURNTABLE)   --货币更新
    end)

    --背景
    self.SpineBg = sp.SkeletonAnimation:create("award/gognxihuode_2.json","award/gognxihuode_2.atlas", 1)
    self.SpineBg:addTo(self.mm_spine_1)
    self.mm_spine_1:setLocalZOrder(1)
    self.SpineBg:setPosition(0, 0)
    self.SpineBg:setAnimation(0, "ruchang", false)        
    self.SpineBg:registerSpineEventHandler( function( event )
        if event.animation == "ruchang" then
            self.SpineBg:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    self.mm_content:setLocalZOrder(2)
    --光效
    self.SpineLight = sp.SkeletonAnimation:create("award/gognxihuode_1.json","award/gognxihuode_1.atlas", 1)
    self.SpineLight:addTo(self.mm_spine_2)
    self.mm_spine_2:setLocalZOrder(3)
    self.SpineLight:setPosition(0, 0)
    self.SpineLight:setAnimation(0, "ruchang", false)        
    self.SpineLight:registerSpineEventHandler( function( event )
        if event.animation == "ruchang" then
            self.SpineLight:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    --按钮
    self.SpineButton = sp.SkeletonAnimation:create("award/anniu.json","award/anniu.atlas", 1)
    self.SpineButton:setSkin("aceitar")
    self.SpineButton:addTo(self.mm_spine_3)
    self.mm_spine_3:setLocalZOrder(4)
    self.SpineButton:setPosition(0, 0)
    self.SpineButton:setAnimation(0, "ruchang", false)        
    self.SpineButton:registerSpineEventHandler( function( event )
        if event.animation == "ruchang" then
            self.SpineButton:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)
    if #args >= 1 then   --有多个奖励
        self:loadContents(args)
    else
        self:loadContent(args.goldTxt,args.goldImg,args.goldImgPlistType)
    end
    

    self.nodeAction = g_ExternalFun.loadTimeLine("award/awardNode.csb")
    self.nodeAction:gotoFrameAndPlay(0, false)
    csbNode:runAction(self.nodeAction)
end

function rewardLayer:loadContent(goldStr,goldImg,goldImgPlistType)
    print("goldImage = ",goldImg)
    if goldImg then
        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(goldImg)           --如果精灵帧里有
        if spriteFrame then
            self.mm_Image_content:loadTexture(goldImg,1)
        else
            self.mm_Image_content:loadTexture(goldImg,goldImgPlistType or 0)
        end
        
        self.mm_Image_content:ignoreContentAdaptWithSize(true)
    end
    self.mm_Count_content:setString(goldStr)
end

function rewardLayer:loadContents(args)
    local parent = self.mm_content:getParent()
    self.mm_content:retain()
    self.mm_content:removeFromParent()
    local items = {}
    local curLong = 140
    local width = 0
    for k = 1,#args do
        local data = args[k]
        local goldTxt = data.goldTxt
        local goldImg = data.goldImg
        local item = self.mm_content:clone()
        local Image_content = item:getChildByName("Image_content")
        local Count_content = item:getChildByName("Count_content")
        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(goldImg)           --如果精灵帧里有
        Image_content:ignoreContentAdaptWithSize(true)
        Image_content:setAnchorPoint(0,0.5)
        if spriteFrame then
            Image_content:loadTexture(goldImg,1)
        else
            Image_content:loadTexture(goldImg)
        end       
        Image_content:setPosition(cc.p(0,0))
        if Image_content:getContentSize().width <= 200 then
            Image_content:setScale(200 / Image_content:getContentSize().width)
        end
        local scale = Image_content:getScale()
        Count_content:setString(goldTxt)
        Count_content:setPosition(cc.p(Image_content:getContentSize().width * scale/2,-155))
        parent:addChild(item)
        item:setLocalZOrder(2)
        items[#items + 1] = item
        item:setPosition(cc.p(width,0))
        item:setScale(1)
        width = width + Image_content:getContentSize().width * scale + curLong
        
    end
    width = width - curLong
    for k = 1,#items do
        local item = items[k]
        item:setPositionX(item:getPositionX() - width/2)
    end
    self.mm_content:release()
end

--设置转盘
function rewardLayer:setTurnTableInfo(textTab,llAdditionValue,llCurrencyValue)
    if not textTab then
        return
    end

    local scrollText = NumberScrollHelper:create(self.mm_Count_content,nil,nil,3,true)
    local worldPosition = self:convertToNodeSpace(self.mm_Count_content:getParent():convertToWorldSpace(cc.p(self.mm_Count_content:getPosition())))
    local delayTime = 0.5
    local isAdd = false
    for k = 1,2 do
        local tab = textTab[k]
        if tab then
            isAdd = true
            local text = self:createFont()
            text:setPosition(self:convertToNodeSpace(tab.position))
            text:setString("+"..tab.value.."%")
            text:setScale(0.5)
            text:setOpacity(0)
            local array = {
                cc.DelayTime:create(delayTime),
                cc.FadeIn:create(0.3),
                cc.CallFunc:create(function() 
                    g_ExternalFun.playEffect("sound/numberScroll.mp3", false)
                end),
                cc.Spawn:create(
                    cc.MoveTo:create(0.5,cc.p(worldPosition.x - 10,worldPosition.y-80)),
                    cc.ScaleTo:create(0.5,0.8)
                ),
                cc.CallFunc:create(function()                                       --bofangdonghua
                    self:showLightAnimation(worldPosition)         --闪光动画
                    self.mm_Count_content:runAction(cc.Sequence:create(
                        cc.EaseBackInOut:create(cc.ScaleTo:create(0.2,1.2)),
                        cc.ScaleTo:create(0.2,0.95),
                        cc.EaseBackInOut:create(cc.ScaleTo:create(0.2,1))
                    ))  
                    if k == 1  then
                        if textTab[2] then
                            scrollText:setToTarget(llCurrencyValue + llCurrencyValue * (tonumber(tab.value) / 100),0.5) 
                        else
                            scrollText:setToTarget(llCurrencyValue + llAdditionValue,0.5) 
                        end
                    else
                        scrollText:setToTarget(llCurrencyValue + llAdditionValue,0.5) 
                    end

                end),
                cc.Spawn:create(
                    cc.MoveBy:create(1.3,cc.p(0,30)),
                    cc.CallFunc:create(function() 
                        text:runAction(cc.Sequence:create(
                            cc.DelayTime:create(1.2),
                            cc.FadeOut:create(0.6)
                        ))
                    end)
                ),
                cc.RemoveSelf:create()
            }
            text:runAction(cc.Sequence:create(array))
            delayTime = delayTime + 2.4
        end
    end
    if not isAdd then
        g_ExternalFun.playEffect("sound/turnNumberScroll.mp3", false)
        performWithDelay(self,function() 
            scrollText:setToTarget(llCurrencyValue + llAdditionValue,0.5)
        end,0.3) 
    end
    
end

--展示闪光动画
function rewardLayer:showLightAnimation(worldPosition)
    if self._lightAnimation then
        self._lightAnimation:show()
        self._lightAnimation:setAnimation(0,"animation",false)
        return
    end
    local spine = self:addSpine(self,"client/res/spine/piaofenguang.json","client/res/spine/piaofenguang.atlas")
    spine:setPosition(cc.p(worldPosition.x,worldPosition.y - 120)) 
    spine:registerSpineEventHandler( function( event )
        if event.animation == "animation" then
            spine:hide()
        end
    end, sp.EventType.ANIMATION_COMPLETE)   
    spine:setAnimation(0,"animation",false)
    self._lightAnimation = spine
end

function rewardLayer:addSpine(parentNode,jsonPath,atlasPath)
    local spine = sp.SkeletonAnimation:createWithJsonFile(jsonPath,atlasPath, 1)        
    spine:addTo(parentNode)
    return spine
end

function rewardLayer:createFont(path)
    local text = ccui.TextBMFont:create()
    text:setFntFile(path or "font/jc_shuzi.fnt")
    text:setAnchorPoint(0.5,0.5)
    text:addTo(self)
    return text
end

return rewardLayer