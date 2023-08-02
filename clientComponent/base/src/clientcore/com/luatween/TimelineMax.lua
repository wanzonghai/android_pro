--
-- Author: senji
-- Date: 2014-02-11 19:09:42
--
TimelineMax = class_quick("TimelineMax");
TimelineMax.version = 1.381;


function TimelineMax:ctor(vars)
    self._repeat = 0;
    self._repeatDelay = 0;
    self._cyclesComplete = 0;
    self._hasUpdateListener = 0;
    self.yoyo = false;

    self.startSignal = SignalAs3.new("TimelineMax:startSignal");
    self.updateSignal = SignalAs3.new("TimelineMax:updateSignal");
    self.completeSignal = SignalAs3.new("TimelineMax:completeSignal");
    self.reverseCompleteSignal = SignalAs3.new("TimelineMax:reverseCompleteSignal");
    self.repeatSignal = SignalAs3.new("TimelineMax:repeatSignal");
    self.initSignal = SignalAs3.new("TimelineMax:initSignal");

    ClassUtil.extends(self, TimelineLite, true, vars);

    self._repeat = checknumber(self.vars.repeatCount) or 0;
    self._repeatDelay = checknumber(self.vars.repeatDelay) or 0;
    self._cyclesComplete = 0;
    self.yoyo = self.vars.yoyo == true;
    self.cacheIsDirty = true;

    if self.vars.onCompleteListener or self.vars.onInitListener or self.vars.onUpdateListener or self.vars.onStartListener or self.vars.onRepeatListener or self.vars.onReverseCompleteListener then
        self:initDispatcher();
    end
end

function TimelineMax:addCallback(callback, timeOrLabel, params)
    local cb = TweenLite.new(callback, 0, {
        onComplete = callback,
        onCompleteParams = params,
        overwrite = 0,
        immediateRender = false
    });
    self:insert(cb, timeOrLabel);
    return cb;
end

function TimelineMax:removeCallback(callback, timeOrLabel)
    if timeOrLabel == nil then
        return self:killTweensOf(callback, false);
    else
        if type(timeOrLabel) == "string" then
            if self._labels[timeOrLabel] == nil then
                return false;
            end
            timeOrLabel = self._labels[timeOrLabel];
        end

        local a = self:getTweensOf(callback, false);
        local success = false;
        local i = #a;
        while i > 0 do
            if a[i].cachedStartTime == timeOrLabel then
                self:remove(a[i]);
                success = true;
            end
        end

        return success;
    end
end


function TimelineMax:tweenTo(timeOrLabel, vars)
    local varsCopy = { ease = TimelineMax.easeNone, overwrite = 2, useFrames = self.useFrames, immediateRender = false }
    for k, v in pairs(vars) do
        varsCopy[k] = v;
    end

    varsCopy.onInit = TimelineMax.onInitTweenTo;
    varsCopy.onInitParams = { nil, self, nil };
    varsCopy.currentTime = self:parseTimeOrLabel(timeOrLabel);

    local tempDur = (math.abs(checknumber(varsCopy.currentTime) - self.cachedTime) / self.cachedTimeScale);
    if tempDur == 0 then
        tempDur = 0.001;
    end
    local tl = TweenLite.new(self, tempDur, varsCopy);
    tl.vars.onInitParams[1] = tl;
    return tl;
end

function TimelineMax:tweenFromTo(fromTimeOrLabel, toTimeOrLabel, vars)
    local tl = self:tweenTo(timeOrLabel, vars);
    tl.vars.onInitParams[3] = self:parseTimeOrLabel(fromTimeOrLabel);
    tl:setDuration(math.abs(checknumber(tl.vars.currentTime) - tl.vars.onInitParams[3]) / self.cachedTimeScale);
    return tl;
end

function TimelineMax:initDispatcher()
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

--override
function TimelineMax:renderTime(time, suppressEvents, force)
    if self.gc then
        self:setEnabled(true, false);
    elseif not self.active and not self.cachedPaused then
        self.active = true;
    end

    local totalDur = self:getTotalDuration();
    if not self.cacheIsDirty then
        totalDur = self.cachedTotalDuration;
    end

    local prevTime = self.cachedTime;
    local prevStart = self.cachedStartTime;
    local prevTimeScale = self.cachedTimeScale;
    local isComplete = false;
    local rendered = false;
    local repeated = false;
    local next = nil;
    local dur = 0;
    local prevPaused = self.cachedPaused;
    if time >= totalDur then

        if self._rawPrevTime <= totalDur and self._rawPrevTime ~= tiem then
            if not self.cachedReversed and self.yoyo and self._repeat % 2 ~= 0 then
                self:forceChildrenToBeginning(0, suppressEvents);
                self.cachedTime = 0;
            else
                self:forceChildrenToEnd(self.cachedDuration, suppressEvents);
                self.cachedTime = self.cachedDuration;
            end
            self.cachedTotalTime = totalDur;
            isComplete = not self:hasPausedChild();
            rendered = true;
            if self.cachedDuration == 0 and isComplete and (time == 0 or self._rawPrevTime < 0) then
                force = true;
            end
        end
    elseif time <= 0 then
        if time < 0 then
            self.active = false;
            if self.cachedDuration == 0 and self._rawPrevTime > 0 then
                force = true;
                isComplete = true;
            end
        end

        if self._rawPrevTime >= 0 and self._rawPrevTime ~= time then
            self.cachedTotalTime = 0;
            self:forceChildrenToBeginning(0, suppressEvents);
            self.cachedTime = 0;
            rendered = true;
            if self.cachedReversed then
                isComplete = true;
            end
        end
    else
        self.cachedTotalTime = time;
        self.cachedTime = time
    end

    self._rawPrevTime = time;

    local prevCycles = 0;
    if self._repeat ~= 0 then
        local cycleDuration = self.cachedDuration + self._repeatDelay;
        if isComplete then
            if self.yoyo and self._repeat % 2 ~= 0 then
                self.cachedTime = 0;
            end
        elseif time > 0 then
            prevCycles = self._cyclesComplete;
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
            end

            if self.cachedTime < 0 then
                self.cachedTime = 0;
            end
        end
        if repeated and not isComplete and (self.cachedTime ~= prevTime or force) then
            local forward = (not self.yoyo) or (self._cyclesComplete % 2 == 0);
            local prevForward = not self.yoyo or (prevCycles % 2 == 0)
            local wrap = forward == prevForward;
            if prevCycles > self._cyclesComplete then
                prevForward = not prevForward;
            end

            if prevForward then
                prevTime = self:forceChildrenToEnd(self.cachedDuration, suppressEvents);
                if wrap then
                    prevTime = self:forceChildrenToBeginning(0, true);
                end
            else
                prevTime = self:forceChildrenToBeginning(0, suppressEvents);
                if wrap then
                    prevTime = self:forceChildrenToEnd(self.cachedDuration, true);
                end
            end

            rendered = false;
        end
    end

    if self.cachedTime == prevTime and not force then
        return;
    elseif not self.initted then
        self.initted = true;
    end

    if prevTime == 0 and self.cachedTotalTime ~= 0 and not suppressEvents then
        applyFunction(self.vars.onStart, self.vars.onStartParams);
        self.startSignal:emit();
    end

    if rendered then
        --ignore
    elseif self.cachedTime - prevTime > 0 then
        tween = self._firstChild;
        while tween do
            next = tween.nextNode;
            if self.cachedPaused and not prevPaused then
                break;
            elseif tween.active or (not tween.cachedPaused and tween.cachedStartTime <= self.cachedTime and not tween.gc) then
                if not tween.cachedReversed then
                    tween:renderTime((self.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale, suppressEvents, false);
                else
                    if tween.cacheIsDirty then
                        dur = tween:getTotalDuration();
                    else
                        dur = tween.cachedTotalDuration;
                    end
                    tween:renderTime(dur - ((self.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale), suppressEvents, false);
                end
            end
            tween = next;
        end
    else
        tween = self._lastChild;
        while tween do
            next = tween.prevNode;
            if self.cachedPaused and not prevPaused then
                break;
            elseif tween.active or (not tween.cachedPaused and tween.cachedStartTime <= prevTime and not tween.gc) then
                if not tween.cachedReversed then
                    tween:renderTime((self.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale, suppressEvents, false);
                else
                    if tween.cacheIsDirty then
                        dur = tween:getTotalDuration();
                    else
                        dur = tween.cachedTotalDuration;
                    end
                    tween:renderTime(dur - ((self.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale), suppressEvents, false);
                end
            end

            tween = next;
        end
    end

    if self._hasUpdate and not suppressEvents then
        applyFunction(self.vars.onUpdate, self.vars.onUpdateParams);
    end

    if self._hasUpdateListener and not suppressEvents then
        self.updateSignal:emit();
    end

    if isComplete and (prevStart == self.cachedStartTime or prevTimeScale ~= self.cachedTimeScale) and (totalDur >= self:getTotalDuration() or self.cachedTime == 0) then
        self:complete(true, suppressEvents);
    elseif repeated and not suppressEvents then
        applyFunction(self.vars.onRepeat, self.vars.onRepeatParams);
        self.repeatSignal:emit();
    end
end

--override 

function TimelineMax:complete(skipRender, suppressEvents)
    TweenCore.complete(self, skipRender, suppressEvents);
    if not suppressEvents then
        if self.cachedReversed and self.cachedTotalTime == 0 and self.cachedDuration ~= 0 then
            self.reverseCompleteSignal:emit();
        else
            self.completeSignal:emit();
        end
    end
end

function TimelineMax:getActive(nested, tweens, timelines)
    if nested == nil then
        nested = true
    end

    if tweens == nil then
        tweens = true
    end

    local a = {};
    local all = self:getChildren(nested, tweens, timelines);
    local i = 0;

    local l = #all;
    local cnt = 0;
    for i = 1, l do
        if all[i].active then
            a[cnt] = all[i];
            cnt = cnt + 1;
        end
    end

    return a;
end


--override 
function TimelineMax:invalidate()
    self._repeat = checknumber(self.vars.repeatCount) or 0;
    self._repeatDelay = checknumber(self.vars.repeatDelay) or 0;
    self.yoyo = self.vars.yoyo == true;

    if self.vars.onCompleteListener ~= nil or self.vars.onUpdateListener ~= nil or self.vars.onStartListener ~= nil then
        self:initDispatcher();
    end
    self:setDirtyCache(true);
    TimelineLite.invalidate(self);
end

function TimelineMax:getLabelAfter(time)
    if not time and time ~= 0 then
        time = self.cachedTime;
    end

    local labels = self:getLabelsArray();
    local l = #labels;
    for i = 1, l do
        if labels[i].time > time then
            return labels[i].name;
        end
    end

    return nil;
end

function TimelineMax:getLabelBefore(time)
    if not time and time ~= 0 then
        time = self.cachedTime;
    end

    local labels = self:getLabelsArray();
    local l = #labels;
    for i = 1, l do
        if labels[i].time < time then
            return labels[i].name;
        end
    end

    return nil;
end

function TimelineMax:getLabelsArray()
    local a = {};
    for p, v in pairs(self._labels) do
        table.insert(a, { time = self._labels[p], name = p });
    end

    TableUtil.sortOn(a, "time", false);

    return a;
end

function TimelineMax:initDispatcher()
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



-- gettes and setters

function TimelineMax:getTotalProgress()
    return self.cachedTotalTime / self:getTotalDuration();
end

function TimelineMax:setTotalProgress(n)
    self:setTotalTime(self:getTotalDuration() * n, false);
end

function TimelineMax:getTotalDuration()
    if self.cacheIsDirty then
        local temp = TimelineLite.getTotalDuration(self); --just forces refresh
        if self._repeat == -1 then
            self.cachedTotalDuration = 999999999999;
        else
            self.cachedTotalDuration = self.cachedDuration * (self._repeat + 1) + (self._repeatDelay * self._repeat);
        end
    end

    return self.cachedTotalDuration;
end

function TimelineMax:setCurrentTime(n)
    if self._cyclesComplete == 0 then
        self:setTotalTime(n, false);
    elseif self.yoyo and self._cyclesComplete % 2 == 1 then
        self:setTotalTime((self:getDuration() - n) + (self._cyclesComplete * (self.cachedDuration + self._repeatDelay)), false);
    else
        self:setTotalTime(n + (self._cyclesComplete * (self.duration + self._repeatDelay)), false);
    end
end

function TimelineMax:getRepeat()
    return self._repeat;
end

function TimelineMax:setRepeat(n)
    self._repeat = n;
    self:setDirtyCache(true);
end

function TimelineMax:getRepeatDelay()
    return self._repeatDelay;
end

function TimelineMax:setRepeatDelay(n)
    self._repeatDelay = n;
    self:setDirtyCache(true);
end

function TimelineMax:getCurrentLabel()
    return self:getLabelBefore(self.cachedTime + 0.00000001);
end

-- static

function TimelineMax.easeNone(t, b, c, d)
    return t / d;
end

function TimelineMax.onInitTweenTo(tween, timeline, fromTime)
    timeline.paused = true;

    if fromTime ~= nil then
        timeline:setCurrentTime(fromTime);
    end

    if tween.vars.currentTime ~= timeline:getCurrentTime() then
        local t = math.abs(checknumber(tween.vars.currentTime) - timeline:getCurrentTime()) / timeline.cachedTimeScale;
        tween:setDuration(t);
    end
end