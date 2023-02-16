-- 把as3上面非常出名的gs缓动引擎移植了过来 http://www.greensock.com/
-- 并且做了一下quick-cocos2d-x的兼容
-- Author: senji
-- Date: 2014-02-07 11:51:32

-- @update 2014-04-01 10:10:37
-- 兼容了cocos2dx的引用计数，不再担心CCObject的引用数清零时被销毁，然后tween系统会执行出错。
-- 现在的处理方式是：
-- 对CCObject创建tween时自动加一次引用数，tween被销毁的时候同时减去引用数
-- 
requireClientCoreMain("tick.TickManager")

requireClientCoreLuaTween("core.PropTween")
requireClientCoreLuaTween("core.TweenCore")
requireClientCoreLuaTween("core.SimpleTimeline")

requireClientCoreLuaTween("OverwriteManager")

requireClientCoreLuaTween("TweenLite")
requireClientCoreLuaTween("TimelineLite")
requireClientCoreLuaTween("TweenMax")
requireClientCoreLuaTween("TimelineMax")

requireClientCoreLuaTween("easing.Ease")
requireClientCoreLuaTween("easing.CustomEase")

requireClientCoreLuaTween("plugins.TweenPlugin")

LuaTweenConfig = {};

LuaTweenConfig.cocos2dxPropertySetter = {
    -- x = "setPosition",
    -- y = "setPosition",
    x = "setPositionX",
    y = "setPositionY",
    alpha = "setOpacity", --alpha的范围是[0,1]，对应setOpacity的范围是[0,255]
    -- nodeAlpha = "setOpacity", --ccs1.4以上的版本，setOpacity不再适用多层opacity，取而代之的是自己写得setOpacity
    nodeAlpha = "setOpacity", --ccs1.4以上的版本，setOpacity不再适用多层opacity，取而代之的是自己写得setOpacity
    opacity = "setOpacity",
    -- nodeOpacity = "setOpacity",
    nodeOpacity = "setOpacity",
    scaleX = "setScaleX",
    scaleY = "setScaleY",
    scale = "setScale",
    rotation = "setRotation",
    visible = "setVisible",
    height = "setContentSize",
    width = "setContentSize",
    changeFactor = "setChangeFactor", --这个是TweenPlugin用的
}

LuaTweenConfig.cocos2dxPropertyGetter = {
    -- x = "getPosition",
    -- y = "getPosition",
    x = "getPositionX",
    y = "getPositionY",
    alpha = "getOpacity",
    -- nodeAlpha = "getNodeOpacity",
    nodeAlpha = "getOpacity",
    opacity = "getOpacity",
    -- nodeOpacity = "getNodeOpacity",
    nodeOpacity = "getOpacity",
    scaleX = "getScaleX",
    scaleY = "getScaleY",
    scale = "getScale",
    rotation = "getRotation",
    height = "getContentSize",
    width = "getContentSize",
    visible = "isVisible",
    changeFactor = "getChangeFactor", --这个是TweenPlugin用的
}

-- quick中的一些setter的兼容
function LuaTweenConfig.setTargetValue(target, propertyName, value)
    local ccSetterName = LuaTweenConfig.cocos2dxPropertySetter[propertyName];
    if ccSetterName and target[ccSetterName] ~= nil then
        if propertyName == "alpha" or propertyName == "nodeAlpha" then
            value = math.min(255, value * 255);--cocos2dx 3.x后 超过255会变成相反，成半透明。。。。很sb啊
        -- elseif propertyName == "x" then
        --     local y = LuaTweenConfig.getTargetValue(target, "y");
        --     target[ccSetterName](target, cc.p(value, y));
        --     return;
        -- elseif propertyName == "y" then
        --     local x = LuaTweenConfig.getTargetValue(target, "x");
        --     target[ccSetterName](target, cc.p(x, value));
        --     return;
        elseif propertyName == "height" then
            local size = target:getContentSize();
            -- local width = size.width;
            size.height = value
            target:setContentSize(size)
            return;
        elseif propertyName == "width" then
            local size = target:getContentSize();
            -- local height = size.value;
            size.width = value;
            target:setContentSize(size)
            return;
        end
        target[ccSetterName](target, value);
    else
        target[propertyName] = value;
    end
end

function LuaTweenConfig.checkCocos2dxRetain(cocos2dxObj, tl)
    if cocos2dxObj and type(cocos2dxObj) ~= "function" and cocos2dxObj.retain then
        cocos2dxObj:retain();
    end
end

function LuaTweenConfig.checkCocos2dxRelease(cocos2dxObj, tl)
    if tolua.cast(cocos2dxObj,"cc.Node") and cocos2dxObj and type(cocos2dxObj) ~= "function" and cocos2dxObj.release then
        cocos2dxObj:release();
    end
end

-- quick中的一些getter的兼容
function LuaTweenConfig.getTargetValue(target, propertyName)
    local ccGetterName = LuaTweenConfig.cocos2dxPropertyGetter[propertyName];
    local value, value2 = nil, nil;
    if ccGetterName and target[ccGetterName] ~= nil then
        value, value2 = target[ccGetterName](target);
        if propertyName == "alpha" or propertyName == "nodeAlpha" then
            value = value / 255;
        -- elseif propertyName == "x" then
        --     if not value2 then
        --         value = value.x;
        --     end
        -- elseif propertyName == "y" then
        --     if not value2 then
        --         value = value.y;
        --     else
        --         value = value2;
        --     end
        elseif propertyName == "height" then
            value = value.height;
        elseif propertyName == "width" then
            value = value.width;
        end
    else
        value = target[propertyName];
    end
    return value;
end