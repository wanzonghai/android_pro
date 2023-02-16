--
-- Author: senji
-- Date: 2014-03-04 11:14:47
--
TintPlugin = class_quick("TintPlugin");
TintPlugin.API = 1.0;

function TintPlugin:ctor()
    self._target = nil;
    self._ignoreVisible = false;

    ClassUtil.extends(self, TweenPlugin);
    self.propName = "tint";
    self._props = { "r", "g", "b"};
    self.overwriteProps = {"tint"};
    self._tweenColor = {}
end

function TintPlugin:onInitTween(target, value, tween)
    self._target = target;
    if target and target.getColor then
        local beginColor = target:getColor()
        self._tweenColor.r = beginColor.r
        self._tweenColor.g = beginColor.g
        self._tweenColor.b = beginColor.b
        self._tweenColor.a = target:getOpacity()
        local endColor = {}
        if tween.vars.removeTint ~= true then
            endColor.r = bit.band(bit.rshift(value, 16), 0xff)
            endColor.g = bit.band(bit.rshift(value, 8), 0xff)
            endColor.b = bit.band(value, 0xff)
        else
            endColor.r = 0;
            endColor.g = 0;
            endColor.b = 0;
        end
        for i,v in ipairs(self._props) do
            self._tweens[i] = PropTween.new(self._tweenColor, v, beginColor[v], endColor[v] - beginColor[v], self.propName, false)
        end
        return true;
    else
        return false;
    end
end


function TintPlugin:setChangeFactor(n)
    self:updateTweens(n);
    self._target:setColor(self._tweenColor)
end
