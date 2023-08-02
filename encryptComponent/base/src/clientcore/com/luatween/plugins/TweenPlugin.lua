--
-- Author: senji
-- Date: 2014-02-10 16:30:02
--
TweenPlugin = class_quick("TweenPlugin");
TweenPlugin.VERSION = 1.31;
TweenPlugin.API = 1.0;

function TweenPlugin:ctor()
    self.propName = nil;
    self.overwriteProps = nil;
    self.round = false;
    self.priority = 0;
    self.activeDisable = false;
    self.onComplete = nil;
    self.onEnable = nil;
    self.onDisable = nil;
    self._tweens = {};
    self._changeFactor = 0;
end

function TweenPlugin:onInitTween(target, value, tween)
    self:addTween(target, self.propName, target[self.propName], value, self.propName);
    return true;
end

function TweenPlugin:addTween(object, propName, start, endObj, overwriteProp)
    if endObj ~= nil then
        local change = checknumber(endObj);
        if type(endObj) == "number" then
            change = change - start;
        end

        if change ~= 0 then
            table.insert(self._tweens, PropTween.new(object, propName, start, change, overwriteProp or propName, false));
        end
    end
end

function TweenPlugin:updateTweens(changeFactor)
    local i = #self._tweens;
    local pt = nil;
    if self.round then
        local val = 0;
        while i > 0 do
            pt = self._tweens[i];
            val = pt.start + (pt.change * changeFactor);
            local temp = 0;
            if val > 0 then
                temp = parseInt(val + 0.5)
            else
                temp = parseInt(val - 0.5)
            end
            LuaTweenConfig.setTargetValue(pt.target, pt.property, temp)
            i = i - 1;
        end
    else
        while i > 0 do
            pt = self._tweens[i];
            LuaTweenConfig.setTargetValue(pt.target, pt.property, pt.start + (pt.change * changeFactor));
            i = i - 1;
        end
    end
end

function TweenPlugin:setChangeFactor(n)
    self:updateTweens(n);
    self._changeFactor = n;
end

function TweenPlugin:getChangeFactor()
    return self._changeFactor;
end

function TweenPlugin:killProps(lookup)
    local i = #self.overwriteProps;
    while i > 0 do
        if lookup[self.overwriteProps[i]] ~= nil then
            table.remove(self.overwriteProps, i)
        end
        i = i - 1;
    end

    i = #self._tweens;

    while i > 0 do
        if lookup[self._tweens[i].name] ~= nil then
            table.remove(self._tweens, i);
        end
        i = i - 1;
    end
end


--static
function TweenPlugin.onTweenEvent(type, tween)
    local pt = tween.cachedPT1;
    local changed = false;
    if type == "onInit" then
        local tweens = {};
        while pt do
            table.insert(tweens, pt);
            pt = pt.nextNode;
        end
        table.sort(tweens, "priority", true) -- check
        local i = #tweens;
        while i > 1 do
            tweens[i].nextNode = tweens[i + 1];
            tweens[i].prevNode = tweens[i - 1];
            i = i - 1;
        end
        tween.cachedPT1 = tweens[1];
    else
        while pt do
            if pt.isPlugin and pt.target[type] then
                if pt.target.activeDisable then
                    changed = true;
                end
                pt.target[type]();
            end
            pt = pt.nextNode;
        end
    end

    return changed;
end

function TweenPlugin.activate(plugins)
    TweenLite.onPluginEvent = TweenPlugin.onTweenEvent;
    local i = #plugins;
    local instance = nil;
    while i > 0 do
        if plugins[i].API ~= nil then
            instance = plugins[i].new();
            TweenLite.plugins[instance.propName] = plugins[i];
        end
        i = i - 1;
    end

    return true;
end