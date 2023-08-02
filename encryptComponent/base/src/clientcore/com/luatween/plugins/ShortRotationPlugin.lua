--
-- Author: senji
-- Date: 2015-10-29 14:18:37
--
ShortRotationPlugin = class_quick("ShortRotationPlugin");
ShortRotationPlugin.API = 1.0;

function ShortRotationPlugin:ctor()
    self._target = nil;
    self._ignoreVisible = false;

    ClassUtil.extends(self, TweenPlugin);
    self.propName = "shortRotation";
    self.overwriteProps = {};
end

function ShortRotationPlugin:onInitTween(target, value, tween)
	if type(value) == "number" then
		return false;
	end
	for p,v in pairs(value) do
		local temp = v;
		local curValue = LuaTweenConfig.getTargetValue(target, p);
		if type(v) == "string" then
			temp = curValue + checknumber(v);
		end
		self:initRotation(target, p, curValue, temp);
	end
	return true;
end

function ShortRotationPlugin:initRotation(target, propName, start, endValue)
	local dif = (endValue - start) % 360;
	if dif ~= dif % 180 then
		if dif < 0 then
			dif = dif + 360;
		else
			dif = dif - 360;
		end
	end
	self:addTween(target, propName, start, start + dif, propName);
	self.overwriteProps[#self.overwriteProps + 1] = propName;
end	