--
-- Author: senji
-- Date: 2014-03-04 11:14:47
--
AutoAlphaPlugin = class_quick("AutoAlphaPlugin");
AutoAlphaPlugin.API = 1.0;

function AutoAlphaPlugin:ctor()
    self._target = nil;
    self._ignoreVisible = false;

    ClassUtil.extends(self, TweenPlugin);
    self.propName = "autoAlpha";
    self.overwriteProps = { "alpha", "visible" };
end

function AutoAlphaPlugin:onInitTween(target, value, tween)
    self._target = target;
    self:addTween(target, "alpha", LuaTweenConfig.getTargetValue(target, "alpha"), value, "alpha");
    return true;
end

function AutoAlphaPlugin:killProps(lookup)
    TweenPlugin.killProps(self, lookup);
    self._ignoreVisible = lookup["visible"] or false;
end


function AutoAlphaPlugin:setChangeFactor(n)
    self:updateTweens(n);
    if not self._ignoreVisible then
        local alpha = LuaTweenConfig.getTargetValue(self._target, "alpha");
        LuaTweenConfig.setTargetValue(self._target, "visible", alpha ~= 0);
    end
end
