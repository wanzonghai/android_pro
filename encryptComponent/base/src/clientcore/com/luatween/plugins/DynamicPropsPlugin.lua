--
-- Author: senji
-- Date: 2014-03-01 15:55:23
--
DynamicPropsPlugin = class_quick("DynamicPropsPlugin")

DynamicPropsPlugin.API = 1.0;

function DynamicPropsPlugin:ctor()
    ClassUtil.extends(self, TweenPlugin);
    self.propName = "dynamicProps";
    self.overwriteProps = {};
    self._props = {};
    self._target = nil;
    self._lastFactor = 0;
end

--override
function DynamicPropsPlugin:onInitTween(target, value, tween)
    self._target = tween.target;
    local params = value.params or {};
    self._lastFactor = 0;
    for p, v in pairs(value) do
        if p ~= "params" then
            table.insert(self._props, { name = p, getter = value[p], params = params[p] });
            table.insert(self.overwriteProps, p);
        end
    end

    return true;
end

--override
function DynamicPropsPlugin:killProps(lookup)
    local i = #self._props;
    while i > 0 do
        if lookup[self._props[i].name] ~= nil then
            table.remove(self._props, i);
        end
        i = i - 1;
    end

    TweenPlugin.killProps(self, lookup);
end

--override
function DynamicPropsPlugin:setChangeFactor(n)
    if n ~= self._lastFactor then
        local i = #self._props;
        local prop = nil;
        local endNum = 0;
        local ratio = 0;
        if not (n == 1 or self._lastFactor == 1) then
            ratio = 1 - ((n - self._lastFactor) / (1 - self._lastFactor));
        end

        while i > 0 do
            prop = self._props[i];
            if prop.params ~= nil then
                endNum = prop.getter(prop.params);
            else
                endNum = prop.getter();
            end
            local curVal = LuaTweenConfig.getTargetValue(self._target, prop.name);
            LuaTweenConfig.setTargetValue(self._target, prop.name, endNum - ((endNum - curVal) * ratio));

            i = i - 1;
        end
        self._lastFactor = n;
    end
end