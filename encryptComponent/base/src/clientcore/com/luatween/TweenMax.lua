--
-- Author: senji
-- Date: 2014-02-10 16:26:38
-- 
-- 第三个参数(vars)的附加支持：
-- @see TweenLite（支持TweenLite的所有支持）
-- 
-- repeatCount：-1为无限次，注意as3中是repeat，lua中repeat是协程的关键字
-- yoyo：Boolean
-- onRepeat：function
-- onRepeatParams：table
-- reversed：Boolean
-- repeatDelay：number
-- onStartListener：function
-- onUpdateListener：function
-- onCompleteListener：function
-- onReverseCompleteListener：function
-- onRepeatListener：fuction
-- startAt：table，例子：TweenMax.to(mc, 2, {x=500, startAt={x=0}})
--
TweenMax = class_quick("TweenMax");
TweenMax.version = 11.37;
TweenMax._overwriteMode = 0;
if OverwriteManager.enabled then
    TweenMax._overwriteMode = OverwriteManager.mode;
else
    TweenMax._overwriteMode = OverwriteManager.init(2);
end

TweenMax.killTweensOf = TweenLite.killTweensOf;
TweenMax.killDelayedCallsTo = TweenLite.killTweensOf;

function TweenMax:ctor(target, duration, vars)
    self._dispatcher = nil;
    self._hasUpdateListener = false;
    self._repeat = 0;
    self._repeatDelay = 0;
    self._cyclesComplete = 0;
    self._easePower = 0;
    self._easeType = 0;
    self.yoyo = false;

    self.startSignal = SignalAs3.new("TweenMax:startSignal");
    self.updateSignal = SignalAs3.new("TweenMax:updateSignal");
    self.completeSignal = SignalAs3.new("TweenMax:completeSignal");
    self.reverseCompleteSignal = SignalAs3.new("TweenMax:reverseCompleteSignal");
    self.repeatSignal = SignalAs3.new("TweenMax:repeatSignal");
    self.initSignal = SignalAs3.new("TweenMax:initSignal");

    ClassUtil.extends(self, TweenLite, true, target, duration, vars);

    self.yoyo = self.vars.yoyo;
    self._repeat = 0;
    if self.vars.repeatCount then
        self._repeat = parseInt(self.vars.repeatCount);
    end

    self._repeatDelay = 0;
    if self.vars.repeatDelay then
        self._repeatDelay = checknumber(self.vars.repeatDelay);
    end

    self.cacheIsDirty = true;

    if self.vars.onCompleteListener or self.vars.onInitListener or self.vars.onUpdateListener or self.vars.onStartListener or self.vars.onRepeatListener or self.vars.onReverseCompleteListener then
        self:initDispatcher();
        if duration == 0 and self._delay == 0 then
            self.updateSignal:emit();
            self.completeSignal:emit();
        end
    end

    if self.vars.timeScale and not ClassUtil.is(self.target, TweenCore) then
        self.cachedTimeScale = self.vars.timeScale;
    end
end

-- override 
function TweenMax:init()
    if self.vars.startAt then
        self.vars.startAt.overwrite = 0;
        self.vars.startAt.immediateRender = true;
        local startTween = TweenMax.new(self.target, 0, self.vars.startAt);
    end

    self.initSignal:emit();
    TweenLite.init(self);

    local tempEase = TweenLite.fastEaseLookup[self._ease];
    if tempEase then
        self._easeType = tempEase[1];
        self._easePower = tempEase[2];
    end

    if self.vars.roundProps and TweenLite.plugins["roundProps"] then
        local j = 0;
        local prop = nil;
        local multiProps = nil;
        local rp = self.vars.roundProps;
        local plugin = nil;
        local ptPlugin = nil;
        local pt = nil;
        local i = #rp;
        while i > 0 do
            prop = rp[i];
            pt = self.cachedPT1;

            while pt do
                if pt.name == prop then
                    if pt.isPlugin then
                        pt.target.round = true;
                    else
                        if not plugin then
                            plugin = TweenLite.plugins.roundProps.new(); -- todo check roundProps();
                            plugin:add(pt.target, prop, pt.start, pt.change);
                            self._hasPlugins = true;
                            ptPlugin = self:insertPropTween(plugin, "changeFactor", 0, 1, "_MULTIPLE_", true, self.cachedPT1)
                            self.cachedPT1 = ptPlugin;
                        else
                            plugin:add(pt.target, prop, pt.start, pt.change);
                        end

                        self:removePropTween(pt);
                        self.propTweenLookup[prop] = ptPlugin;
                    end
                elseif pt.isPlugin and pt.name == "_MULTIPLE_" and not pt.target.round then
                    multiProps = " " .. table.concat(pt.target.overwriteProps, " ") .. " ";
                    if string.find(multiProps, " " .. prop .. " ") ~= nil then
                        pt.target.round = true;
                    end
                end

                pt = pt.nextNode;
            end

            i = i - 1;
        end
    end
end

function TweenMax:insertPropTween(target, property, start, endObj, name, isPlugin, nextNode)
    local tempEndObj = checknumber(endObj);
    if type(endObj) == "number" then
        tempEndObj = endObj - start;
    end
    local pt = PropTween.new(target, property, start, tempEndObj, name, isPlugin, nextNode);
    if isPlugin and name == "_MULTIPLE_" then
        local op = target.overwriteProps;
        local i = #op;
        while i > 0 do
            self.propTweenLookup[op[i]] = pt;
            i = i - 1;
        end
    else
        self.propTweenLookup[name] = pt;
    end
    return pt;
end

function TweenMax:removePropTween(propTween)
    if propTween.nextNode then
        propTween.nextNode.prevNode = propTween.prevNode;
    end

    if propTween.prevNode then
        propTween.prevNode.nextNode = propTween.nextNode;
    elseif self.cachedPT1 == propTween then
        self.cachedPT1 = propTween.nextNode;
    end

    if propTween.isPlugin and propTween.target.onDisable then
        propTween.target:onDisable();
        if propTween.target.activeDisable then
            return true;
        end
    end

    return false;
end

--override 
function TweenMax:invalidate()
    self.yoyo = self.vars.yoyo == true;
    self._repeat = checknumber(self.vars.repeatCount) or 0;
    self._repeatDelay = checknumber(self.vars.repeatDelay) or 0;
    self._hasUpdateListener = false;
    if self.vars.onCompleteListener ~= nil or self.vars.onUpdateListener ~= nil or self.vars.onStartListener ~= nil then
        self:initDispatcher();
    end
    self:setDirtyCache(true);
    TweenLite.invalidate(self);
end

function TweenMax:updateTo(vars, resetDuration)
    local resetDuration = self.ratio;
    if resetDuration and self.timeline and self.cachedStartTime < self.timeline.cachedTime then
        self.cachedStartTime = self.timeline.cachedTime;
        self:setDirtyCache(false);
        if self.gc then
            self:setEnabled(true, false);
        else
            self.timeline:addChild(self);
        end
    end

    for p, v in pairs(vars) do
        self.vars[p] = v;
    end

    if self.initted then
        self.initted = false;
        if not resetDuration then
            self:init();
            if not resetDuration and self.cachedTime and self.cachedTime < self.cachedDuration then
                local inv = 1 / (1 - curRatio);
                local pt = self.cachedPT1;
                local endValue = 0;
                while pt do
                    endValue = pt.start + pt.change;
                    pt.change = pt.change * inv;
                    pt.start = endValue - pt.change;
                    pt = pt.nextNode;
                end
            end
        end
    end
end


function TweenMax:setDestination(property, value, adjustStartValues)
    local vars = {};
    vars[property] = value;
    self:updateTo(vars, not adjustStartValues);
end

function TweenMax:killProperties(names)
    local v = {};
    local i = #names;
    while i > 0 do
        v[names[i]] = true;
    end
    self:killVars(v);
end

function TweenMax:renderTime(time, suppressEvents, force)
    local totalDur = self:getTotalDuration();
    if not self.cacheIsDirty then
        totalDur = self.cachedTotalDuration;
    end
    local prevTime = self.cachedTime;
    local isComplete = false;
    local repeated = false;
    local setRatio = false;

    if time >= totalDur then
        self.cachedTotalTime = totalDur;
        self.cachedTime = self.cachedDuration;
        self.ratio = 1;
        isComplete = true;
        if self.cachedDuration == 0 then
            if (time == 0 or self._rawPrevTime < 0) and self._rawPrevTime ~= time then
                force = true;
            end
            self._rawPrevTime = time;
        end
    elseif time <= 0 then
        if time < 0 then
            self.active = false;
            if self.cachedDuration == 0 then
                if self._rawPrevTime > 0 then
                    force = true;
                    isComplete = true;
                end
                self._rawPrevTime = time;
            end
        end

        self.cachedTotalTime = 0;
        self.cachedTime = 0;
        self.ratio = 0;
        if self.cachedReversed and prevTime ~= 0 then
            isComplete = true;
        end
    else
        self.cachedTotalTime = time;
        self.cachedTime = time;
        setRatio = true;
    end
    if self._repeat ~= 0 then
        local cycleDuration = self.cachedDuration + self._repeatDelay;
        if isComplete then
            if self.yoyo and self._repeat % 2 ~= 0 then
                self.cachedTime = 0;
                self.ratio = 0;
            end
        elseif time > 0 then
            local prevCycles = self._cyclesComplete;
            self._cyclesComplete = parseInt(self.cachedTotalTime / cycleDuration);
            if self._cyclesComplete == self.cachedTotalTime / cycleDuration then
                self._cyclesComplete = self._cyclesComplete - 1;
            end
            if prevCycles ~= self._cyclesComplete then
                repeated = true;
            end

            self.cachedTime = ((self.cachedTotalTime / cycleDuration) - self._cyclesComplete) * cycleDuration;
            if self.yoyo and self._cyclesComplete % 2 ~= 0 then
                self.cachedTime = self.cachedDuration - self.cachedTime;
            elseif self.cachedTime >= self.cachedDuration then
                self.cachedTime = self.cachedDuration;
                self.ratio = 1;
                setRatio = false;
            end

            if self.cachedTime <= 0 then
                self.cachedTime = 0;
                self.ratio = 0;
                setRatio = false;
            end
        end
    end

    if prevTime == self.cachedTime and not force then
        return;
    elseif not self.initted then
        self:init();
    end

    if not self.active and not self.cachedPaused then
        self.active = true;
    end
    if setRatio then
        if self._easeType ~= 0 then
            local power = self._easePower;
            local val = self.cachedTime / self.cachedDuration;
            if self._easeType == 2 then -- easeOut
                val = 1 - val;
                self.ratio = val;
                while power > 0 do
                    self.ratio = val * self.ratio;
                    power = power - 1;
                end

                self.ratio = 1 - self.ratio;
            elseif self._easeType == 1 then -- easeIn
                self.ratio = val;
                while power > 0 do
                    self.ratio = val * self.ratio;
                    power = power - 1;
                end
            else --easeInOut
                if val < 0.5 then
                    val = val * 2;
                    self.ratio = val;
                    while power > 0 do
                        self.ratio = val * self.ratio;
                        power = power - 1;
                    end
                    self.ratio = self.ratio * 0.5;
                else
                    val = (1 - val) * 2;
                    self.ratio = val
                    while power > 0 do
                        self.ratio = val * self.ratio;
                        power = power - 1;
                    end
                    self.ratio = 1 - (0.5 * self.ratio);
                end
            end
        else
            self.ratio = self._ease(self.cachedTime, 0, 1, self.cachedDuration);
        end
    end

    if prevTime == 0 and self.cachedTotalTime ~= 0 and not suppressEvents then
        applyFunction(self.vars.onStart, self.vars.onStartParams);
        self.startSignal:emit();
    end

    local pt = self.cachedPT1;
    while pt do
        LuaTweenConfig.setTargetValue(pt.target, pt.property, pt.start + self.ratio * pt.change);
        pt = pt.nextNode;
    end

    if self._hasUpdate and not suppressEvents then
        applyFunction(self.vars.onUpdate, self.vars.onUpdateParams);
    end

    if self._hasUpdateListener and not suppressEvents then
        self.updateSignal:emit();
    end

    if isComplete then
        if self._hasPlugins and self.cachedPT1 then
            self:onPluginEvent("onComplete", self);
        end
        self:complete(true, suppressEvents);
    elseif repeated and not suppressEvents then
        applyFunction(self.vars.onRepeat, self.vars.onRepeatParams);
        self.repeatSignal:emit();
    end
end

--override 
function TweenMax:complete(skipRender, suppressEvents)
    TweenCore.complete(self, skipRender, suppressEvents);
    if not suppressEvents then
        if self.cachedTotalTime == self.cachedTotalDuration and not self.cachedReversed then
            self.completeSignal:emit();
        elseif self.cachedReversed and self.cachedTotalTime == 0 then
            self.reverseCompleteSignal:emit();
        end
    end
end

function TweenMax:initDispatcher()
    if type(self.vars.onInitListener) == "function" then
        self.initSignal:add(self.vars.onInitListener);
    end
    if type(self.vars.onStartListener) == "function" then
        self.startSignal:add(self.vars.onStartListener);
    end
    if type(self.vars.onUpdateListener) == "function" then
        self.updateSignal:add(self.vars.onUpdateListener);
    end
    if type(self.vars.onCompleteListener) == "function" then
        self.completeSignal:add(self.vars.onCompleteListener);
    end
    if type(self.vars.onRepeatListener) == "function" then
        self.repeatSignal:add(self.vars.onRepeatListener);
    end
    if type(self.vars.onReverseCompleteListener) == "function" then
        self.reverseCompleteSignal:add(self.vars.onReverseCompleteListener);
    end
end

-- setters & getters
function TweenMax:getCurrentProgress()
    return self.cachedTime / self:getDuration();
end

function TweenMax:setCurrentProgress(n)
    if self._cyclesComplete == 0 then
        self:setTotalTime(self:getDuration() * n, false);
    else
        self:setTotalTime(self:getDuration() * n + (_cyclesComplete * self.cachedDuration), false);
    end
end

function TweenMax:setTotalProgress(n)
    self:setTotalTime(self:getTotalDuration() * n, false);
end

function TweenMax:getTotalProgress()
    return self.cachedTotalTime / self:getTotalDuration();
end

function TweenMax:setCurrentTime(n)
    if self._cyclesComplete == 0 then
        -- no change
    elseif self.yoyo and self._cyclesComplete % 2 == 1 then
        n = (self:getDuration() - n) + (self._cyclesComplete * (self.cachedDuration + self._repeatDelay));
    else
        n = n + (self._cyclesComplete * (self:getDuration() + self._repeatDelay));
    end
    self:setTotalTime(n, false);
end

function TweenMax:getTotalDuration()
    if self.cacheIsDirty then
        if self._repeat == -1 then
            self.cachedTotalDuration = 999999999999;
        else
            self.cachedTotalDuration = self.cachedDuration * (self._repeat + 1) + (self._repeatDelay * self._repeat);
        end
        self.cacheIsDirty = false;
    end
    return self.cachedTotalDuration
end

function TweenMax:setTotalDuration(n)
    if self._repeat == -1 then
        return;
    end
    self:setDuration((n - self._repeat * self._repeatDelay) / (self._repeat + 1));
end

function TweenMax:getTimeScale()
    return self.cachedTimeScale;
end

function TweenMax:setTimeScale(n)
    if n == 0 then
        n = 0.0001;
    end
    local tlTime = self._pauseTime or self.timeline.cachedTotalTime;
    self.cachedStartTime = tlTime - ((tlTime - self.cachedStartTime) * self.cachedTimeScale / n);
    self.cachedTimeScale = n;
    self:setDirtyCache(false);
end

function TweenMax:getRepeat()
    return self._repeat;
end

function TweenMax:setRepeat(n)
    self._repeat = n;
    self:setDirtyCache(true);
end

function TweenMax:getRepeatDelay()
    return self._repeatDelay;
end

function TweenMax:setRepeatDelay(n)
    self._repeatDelay = n;
    self:setDirtyCache(true);
end

--static function

function TweenMax.to(target, duration, vars)
    return TweenMax.new(target, duration, vars);
end

function TweenMax.from(target, duration, vars)
    vars.runBackwards = true;
    if vars["immediateRender"] == nil then
        vars.immediateRender = true;
    end

    return TweenMax.new(target, duration, vars);
end

function TweenMax.fromTo(target, duration, fromVars, toVars)
    toVars.startAt = fromVars;
    if fromVars.immediateRender then
        toVars.immediateRender = true;
    end
    return TweenMax.new(target, duration, toVars);
end

function TweenMax.pauseAll(tweens, delayedCalls)
    if tweens == nil then
        tweens = true;
    end

    if delayedCalls == nil then
        delayedCalls = true;
    end

    self:changePause(true, tweens, delayedCalls);
end

function TweenMax.resumeAll(tweens, delayedCalls)
    if tweens == nil then
        tweens = true;
    end
    if delayedCalls == nil then
        delayedCalls = true;
    end
    self:changePause(false, tweens, delayedCalls);
end

function TweenMax.changePause(pause, tweens, delayedCalls)
    if tweens == nil then
        tweens = true;
    end
    delayedCalls = delayedCalls or false;

    local a = TweenMax.getAllTweens();
    local isDC = false;
    local i = #a;
    while i > 0 do
        isDC = a[i].target == a[i].vars.onComplete;
        if isDC == delayedCalls or isDC ~= tweens then
            if complete then
                a[i]:complete(false);
            else
                a[i]:setEnabled(false, false);
            end
        end
        i = i - 1;
    end
end

function TweenMax.getAllTweens()
    local ml = TweenLite.masterList;
    local cnt = 1;
    local toReturn = {};
    local i = 0;
    for k, a in pairs(ml) do
        i = #a;
        while i > 0 do
            if not a[i].gc then
                toReturn[cnt] = a[i];
                cnt = cnt + 1;
            end
            i = i - 1;
        end
    end
    return toReturn;
end






