--
-- 贝塞尔曲线
-- Author: senji
-- Date: 2014-03-03 00:54:06
--
requireClientCoreLuaTween("plugins.BezierPlugin");

BezierThroughPlugin = class_quick("BezierThroughPlugin")
BezierThroughPlugin.API = 1.0;

function BezierThroughPlugin:ctor()
    ClassUtil.extends(self, BezierPlugin);
    self.propName = "bezierThrough";
end

function BezierThroughPlugin:onInitTween(target, value, tween)
    if type(value) ~= "table" then
        return false;
    end

    self:init(tween, value, true)
    return true;
end

