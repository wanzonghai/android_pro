-------------------------------------------------------------------------
-- Desc:     对cc.Node进行了扩展
-- Content:  添加了一些方便实用的方法，用法如下：
--------------------------------------------------------------------------
local WWNodeEx = cc.Node

-- 返回node缩放后的宽度
function WWNodeEx:width(countScale)
    local scaleX =(countScale == true) and self:getScaleX() or 1
    return self:getContentSize().width * scaleX
end

-- 返回node的高度
function WWNodeEx:height(countScale)
    local scaleY =(countScale == true) and self:getScaleY() or 1
    return self:getContentSize().height * scaleY
end

function WWNodeEx:rect()
    local ret = { }
    ret.x = 0.0
    ret.y = 0.0
    ret.width = self:width()
    ret.height = self:height()
    return ret
end

function WWNodeEx:playActionDelay(action, delay)
    delay = checknumber(delay)
    if action and type(delay) == "number" then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(delay), action))
    end
    return self
end

function WWNodeEx:executeDelay(callback, delay)
    if callback and type(delay) == "number" then
        self:playActionDelay(cc.CallFunc:create(callback), delay)
    end
    return self
end

function WWNodeEx:addTouch(onTouchBegan, onTouchMoved, onTouchEnded, onTouchCancelled, swallow)
    self:cancelTouch()
    local listener = cc.EventListenerTouchOneByOne:create()
    self.WWNodeEx_Node_Single_Touch_Listener = listener
    listener:setSwallowTouches(swallow == nil and true or swallow)
    if onTouchBegan then
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    end
    if onTouchMoved then
        listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    end
    if onTouchEnded then
        listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    end
    if onTouchCancelled then
        listener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)
    end
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    return listener
end

-- 取消单点触摸，只对用addTouch或addTouches添加的方式有效 removeTouch和LayerEx中的同名，不能用
function WWNodeEx:cancelTouch()
    if self.WWNodeEx_Node_Single_Touch_Listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.WWNodeEx_Node_Single_Touch_Listener)
        self.WWNodeEx_Node_Single_Touch_Listener = nil
    end
    return self
end

function WWNodeEx:getNodePos(pos)
    local ret = nil
    if pos then
        ret = self:convertToNodeSpace(pos)
    end
    return ret
end

function WWNodeEx:swallowTouch()
    return self:addTouch( function(touch, event) return true end)
end

function WWNodeEx:enableClick(callback ,isSwallowTouches)
    local function onTouchBegan(touch, event)
        if cc.rectContainsPoint(self:rect(), self:convertToNodeSpace(touch:getLocation())) then
            return true
        end
        return false
    end
    local function onTouchEnded(touch, event)
        if callback then
            callback(self, touch)
        end
    end
    
    if isSwallowTouches == nil then
        isSwallowTouches = true
    end

    self:addTouch(onTouchBegan, nil, onTouchEnded, nil, isSwallowTouches)
    return self
end

return WWNodeEx