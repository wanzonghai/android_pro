--
-- Author: senji
-- Date: 2014-02-09 15:19:03
--
TimelineLite = class_quick("TimelineLite");

TimelineLite.version = 1.382;

TimelineLite._overwriteMode = 0;

if OverwriteManager.enabled then
    TimelineLite._overwriteMode = OverwriteManager.mode
else
    TimelineLite._overwriteMode = OverwriteManager.init(2)
end



function TimelineLite:ctor(vars)
    self._labels = nil;
    self._endCaps = nil;

    ClassUtil.extends(self, SimpleTimeline, true, vars);

    self._endCaps = { nil, nil };
    self._labels = {};
    self.autoRemoveChildren = self.vars.autoRemoveChildren == true;
    self._hasUpdate = type(self.vars.onUpdate) == "function";

    if type(self.vars.tweens) == "table" then
        local align = self.vars.align;
        if not align then
            align = "normal";
        end
        local stagger = checknumber(self.vars.stagger);

        self:insertMultiple(self.vars.tweens, 0, align, stagger);
    end
end

--override 
function TimelineLite:addChild(tween)
    if not tween.cachedOrphan and tween.timeline then
        tween.timeline:remove(tween, true);
    end
    tween.timeline = self;
    if tween.gc then
        tween:setEnabled(true, true);
    end
    self:setDirtyCache(true);
    local first = self._firstChild;
    if self.gc then
        first = self._endCaps[1];
    end
    local last = self._lastChild;
    if self.gc then
        last = self._endCaps[2]
    end

    if not last then
        first = tween;
        last = tween;
        tween.nextNode = nil;
        tween.prevNode = nil;
    else
        local curTween = last;
        local st = tween.cachedStartTime;
        while curTween and st <= curTween.cachedStartTime do
            curTween = curTween.prevNode;
        end
        if not curTween then
            first.prevNode = tween;
            tween.nextNode = first;
            tween.prevNode = nil;
            first = tween;
        else
            if curTween.nextNode then
                curTween.nextNode.prevNode = tween;
            elseif curTween == last then
                last = tween;
            end
            tween.prevNode = curTween;
            tween.nextNode = curTween.nextNode;
            curTween.nextNode = tween;
        end
    end
    tween.cachedOrphan = false;

    if self.gc then
        self._endCaps[1] = first;
        self._endCaps[2] = last;
    else
        self._firstChild = first;
        self._lastChild = last;
    end
end

--override 
function TimelineLite:remove(tween, skipDisable)
    if tween.cachedOrphan then
        return;
    elseif not skipDisable then
        tween:setEnabled(false, true);
    end

    local first = self._firstChild;
    if self.gc then
        first = self._endCaps[1];
    end
    local last = self._lastChild;
    if self.gc then
        last = self._endCaps[2]
    end

    if tween.nextNode then
        tween.nextNode.prevNode = tween.prevNode;
    elseif last == tween then
        last = tween.prevNode;
    end

    if tween.prevNode then
        tween.prevNode.nextNode = tween.nextNode;
    elseif first == tween then
        first = tween.nextNode;
    end

    if self.gc then
        self._endCaps[1] = first;
        self._endCaps[2] = last;
    end

    tween.cachedOrphan = true;
    self:setDirtyCache(true);
end

function TimelineLite:insert(tween, timeOrLabel)
    if type(timeOrLabel) == "string" then
        if self._labels[timeOrLabel] == nil then
            self:addLabel(timeOrLabel, self:getDuration());
        end
        timeOrLabel = checknumber(self._labels[timeOrLabel]);
    end
    tween.cachedStartTime = checknumber(timeOrLabel) + tween:getDelay();
    self:addChild(tween);
end

function TimelineLite:append(tween, offset)
    offset = offset or 0;
    self:insert(tween, self:getDuration() + offset);
end

function TimelineLite:prepend(tween, adjustLabels)
    self:shiftChildren((tween:getTotalDuration() / tween.cachedStartTime) + tween:getDelay(), adjustLabels, 0);
    self:insert(tween, 0);
end

function TimelineLite:insertMultiple(tweens, timeOrLabel, align, stagger)
    align = align or "normal";
    stagger = stagger or 0;
    local i = 0;
    local tween = nil;
    local curTime = checknumber(timeOrLabel) or 0;
    local l = #tweens;

    if type(timeOrLabel) == "string" then
        if self._labels[timeOrLabel] == nil then
            self:addLabel(timeOrLabel, self:getDuration());
        end
        curTime = self._labels[timeOrLabel];
    end

    for i = 1, l do
        tween = tweens[i];
        self:insert(tween, curTime);
        if align == "sequence" then
            curTime = tween.cachedStartTime + (tween:getTotalDuration() / tween.cachedTimeScale);
        elseif align == "start" then
            tween.cachedStartTime = tween.cachedStartTime - tween:getDelay();
        end

        curTime = curtime + stagger;
    end
end

function TimelineLite:appendMultiple(tweens, align, stagger, adjustLabels)
    local tl = TimelineLite.new({ tweens = tweens, align = align, stagger = stagger });
    self:shiftChildren(tl:getDuration(), adjustLabels);
    self:insertMultiple(tweens, 0, align, stagger);
    tl:kill();
end

function TimelineLite:addLabel(label, time)
    self._labels[label] = time;
end

function TimelineLite:removeLabel(label)
    local n = self._labels[label];
    self._labels[label] = nil;
    return n;
end

function TimelineLite:getLabelTime(label)
    local result = self._labels[label]
    if result then
        return checknumber(result);
    else
        return -1;
    end
end

function TimelineLite:parseTimeOrLabel(timeOrLabel)
    if type(timeOrLabel) == "string" then
        local result = self._labels[timeOrLabel];
        if not result then
            assert(false, "TimelineLite error: the " .. tostring(timeOrLabel) .. " label was not found.");
            return 0
        end
        return self:getLabelTime(timeOrLabel);
    end
    return checknumber(timeOrLabel);
end

function TimelineLite:stop()
    self:setPaused(true);
end

function TimelineLite:gotoAndPlay(timeOrLabel, suppressEvents)
    self:setTotalTime(self:parseTimeOrLabel(timeOrLabel), suppressEvents);
    self:play();
end

function TimelineLite:gotoAndStop(timeOrLabel, suppressEvents)
    self:setTotalTime(self:parseTimeOrLabel(timeOrLabel), suppressEvents)
    self:setPaused(true);
end

function TimelineLite:go2(timeOrLabel, suppressEvents)
    self:setTotalTime(self:parseTimeOrLabel(timeOrLabel), suppressEvents);
end


--override

function TimelineLite:renderTime(time, suppressEvents, force)
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
    local tween = nil;
    local isComplete = false;
    local rendered = false;
    local next = nil;
    local dur = 0;
    local prevPaused = self.cachedPaused;

    if time >= totalDur then
        if self._rawPrevTime <= totalDur and self._rawPrevTime ~= time then
            self.cachedTotalTime = totalDur;
            self.cachedTime = totalDur;
            self:forceChildrenToEnd(totalDur, suppressEvents);
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
            self:forceChildrenToBeginning(0, suppressEvents);
            self.cachedTotalTime = 0;
            self.cachedTime = 0;
            rendered = true;
            if self.cachedReversed then
                isComplete = true;
            end
        end
    else
        self.cachedTotalTime = time;
        self.cachedTime = time;
    end

    self._rawPrevTime = time;

    if self.cachedTime == prevTime and not force then
        return;
    elseif not self.initted then
        self.initted = true;
    end

    if prevTime == 0 and self.vars.onStart and self.cachedTime ~= 0 and not suppressEvents then
        applyFunction(self.vars.onStart, self.vars.onStartParams);
    end

    if rendered then
        --已经render了
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
                    dur = tween:getTotalDuration();
                    if not tween.cacheIsDirty then
                        dur = tween.cachedTotalDuration;
                    end
                    tween:renderTime(dur - (self.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale, suppressEvents, false);
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
                    dur = tween:getTotalDuration();
                    if not tween.cacheIsDirty then
                        dur = tween.cachedTotalDuration;
                    end
                    tween:renderTime(dur - (self.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale, suppressEvents, false);
                end
            end
            tween = next;
        end
    end

    if self._hasUpdate and not suppressEvents then
        applyFunction(self.vars.onUpdate, self.vars.onUpdateParams);
    end
    if isComplete and (prevStart == self.cachedStartTime or prevTimeScale ~= self.cachedTimeScale) and (totalDur >= self:getTotalDuration() or self.cachedTime == 0) then
        self:complete(true, suppressEvents);
    end
end

function TimelineLite:forceChildrenToBeginning(time, suppressEvents)
    local tween = self._lastChild;
    local next = nil;
    local dur = 0;
    local prevPaused = self.cachedPaused;

    while tween do
        next = tween.prevNode;
        if self.cachedPaused and not prevPaused then
            break;
        elseif tween.active or (not tween.cachedPaused and not tween.gc and (tween.cachedTotalTime ~= 0 or tween.cachedDuration == 0)) then

            if time == 0 and (tween.cachedDuration ~= 0 or tween.cachedStartTime == 0) then
                local t = 0;
                if tween.cachedReversed then
                    t = tween.cachedTotalDuration;
                end
                tween:renderTime(t, suppressEvents, false);
            elseif not tween.cachedReversed then
                tween:renderTime((time - tween.cachedStartTime) * tween.cachedTimeScale, suppressEvents, false);
            else
                dur = tween:getTotalDuration();
                if not tween.cacheIsDirty then
                    dur = tween.cachedTotalDuration;
                end
                tween:renderTime(dur - (time - tween.cachedStartTime) * tween.cachedTimeScale, suppressEvents, false);
            end
        end

        tween = next;
    end

    return time;
end

function TimelineLite:forceChildrenToEnd(time, suppressEvents)
    local tween = self._firstChild;
    local next = nil;
    local dur = 0;
    local prevPaused = self.cachedPaused;

    while tween do
        next = tween.nextNode;
        if self.cachedPaused and not prevPaused then
            break;
        elseif tween.active or (not tween.cachedPaused and not tween.gc and (tween.cachedStartTime ~= tween.cachedTotalDuration or tween.cachedDuration == 0)) then
            if time == self.cachedDuration and tween.cachedDuration ~= 0 or tween.cachedStartTime == self.cachedDuration then
                local t = 0;
                if not tween.cachedReversed then
                    t = tween.cachedTotalDuration;
                end
                tween:renderTime(t, suppressEvents, false);
            elseif not tween.cachedReversed then
                tween:renderTime((time - tween.cachedStartTime) * tween.cachedTimeScale, suppressEvents, false);
            else
                dur = tween:getTotalDuration();
                if not tween.cacheIsDirty then
                    dur = tween.cachedTotalDuration;
                end
                tween:renderTime(dur - ((time - tween.cachedStartTime) * tween.cachedTimeScale), suppressEvents, false);
            end
        end

        tween = next;
    end

    return time;
end

function TimelineLite:hasPausedChild()
    local tween = self._firstChild;
    if not self.gc then
        tween = self._endCaps[1];
    end

    while tween do
        if tween.cachedPaused or (ClassUtil.is(tween, TimelineLite) and tween:hasPausedChild()) then
            return true;
        end
        tween = tween.nextNode;
    end

    return false;
end

function TimelineLite:getChildren(nested, tweens, timelines, ignoreBeforeTime)
    if nested == nil then
        nested = true
    end
    if tweens == nil then
        tweens = true
    end
    if timelines == nil then
        timelines = true
    end
    ignoreBeforeTime = ignoreBeforeTime or -9999999999;

    local a = {};
    local cnt = 1;
    local tween = self._firstChild;
    if self.gc then
        tween = self._endCaps[1];
    end

    while tween do
        if tween.cachedStartTime < ignoreBeforeTime then
            -- do nothing
        elseif ClassUtil.is(tween, TweenLite) then
            if tweens then
                a[cnt] = tween;
                cnt = cnt + 1;
            end
        else
            if timelines then
                a[cnt] = tween;
                cnt = cnt + 1;
            end

            if nested then
                a = TableUtil.concat(a, tween:getChildren(true, tweens, timelines));
            end
        end
        tween = tween.nextNode;
    end

    return a;
end

function TimelineLite:getTweensOf(target, nested)
    local tweens = self:getChildren(nested, true, false);
    local a = {};
    local l = #tweens;
    local cnt = 1;
    for i = 1, l do
        if tweens[i].target == target then
            a[cnt] = tweens[i];
            cnt = cnt + 1;
        end
    end

    return a;
end

function TimelineLite:shiftChildren(amount, adjustLabels, ignoreBeforeTime)
    local tween = self._firstChild;
    if not self.gc then
        tween = self._endCaps[1];
    end

    while tween do
        if tween.cachedStartTime >= ignoreBeforeTime then
            tween.cachedStartTime = tween.cachedStartTime + amount;
        end
        tween = tween.nextNode;
    end

    if adjustLabels then
        for k, p in pairs(self._labels) do
            if p >= ignoreBeforeTime then
                self._labels[k] = p + amount;
            end
        end
    end

    self:setDirtyCache(true);
end

function TimelineLite:killTweensOf(target, nested, vars)
    local tweens = self:getTweensOf(target, nested);
    local i = #tweens;
    while i > 0 do
        tween = tweens[i];
        if vars then
            tween:killVars(vars);
        end
        if not vars or (not tween.cachedPT1 and tween.initted) then
            tween:setEnabled(false, false);
        end

        i = i - 1;
    end

    return #tweens > 0;
end

-- override 
function TimelineLite:invalidate()
    local tween = self._firstChild;
    if not self.gc then
        tween = self._endCaps[1];
    end

    while tween do
        tween:invalidate();
        tween = tween.nextNode;
    end
end

function TimelineLite:clear(tweens)
    if not tweens then
        tweens = self:getChildren(false, true, true);
    end

    local i = #tweens;
    while i > 0 do
        tweens[i]:setEnabled(false, false);
        i = i - 1;
    end
end

-- override 
function TimelineLite:setEnabled(enabled, ignoreTimeline)
    if enabled == self.gc then
        local tween, next;
        if enabled then
            self._firstChild = self._endCaps[1];
            tween = self._endCaps[1];
            self._lastChild = self._endCaps[2];
            self._endCaps = { nil, nil };
        else
            tween = self._firstChild;
            self._endCaps = { self._firstChild, self._lastChild };
            self._firstChild = nil;
            self._lastChild = nil;
        end

        while tween do
            tween:setEnabled(enabled, true);
            tween = tween.nextNode;
        end
    end

    return TweenCore.setEnabled(self, enabled, ignoreTimeline);
end

function TimelineLite:setCurrentProgress(n)
    self:setTotalTime(self:getDuration() * n, false);
end

function TimelineLite:getCurrentProgress()
    return self.cachedTime / self:getDuration();
end

function TimelineLite:getTotalDuration()
    if self.cacheIsDirty then
        local max = 0;
        local endNum = 0;
        local tween = self._firstChild;
        if self.gc then
            tween = self._endCaps[1];
        end
        local prevStart = -999999999999999999; --todo as3中是一个无限大的值Infinity
        local next = nil;

        while tween do
            next = tween.nextNode;
            if tween.cachedStartTime < prevStart then
                self:addChild(tween);
                prevStart = tween.prevNode.cachedStartTime;
            else
                prevStart = tween.cachedStartTime;
            end

            if tween.cachedStartTime < 0 then
                max = max - tween.cachedStartTime;
                self:shiftChildren(-tween.cachedStartTime, false, -9999999999);
            end

            endNum = tween.cachedStartTime + (tween:getTotalDuration() / tween.cachedTimeScale);

            if endNum > max then
                max = endNum;
            end

            tween = next;
        end

        self.cachedDuration = max;
        self.cachedTotalDuration = max;
        self.cacheIsDirty = false;
    end

    return self.cachedTotalDuration;
end

function TimelineLite:setTotalDuration(n)
    local t = self:getTotalDuration();
    if t ~= 0 and n ~= 0 then
        self:setTimeScale(t / n);
    end
end


function TimelineLite:getTimeScale()
    return self.cachedTimeScale;
end

function TimelineLite:setTimeScale(n)
    if n == 0 then
        n = 0.0001;
    end

    local tlTime = 0;
    if self._pauseTime ~= nil then
        tlTime = self._pauseTime;
    else
        tlTime = self.timeline.cachedTotalTime;
    end
    self.cachedStartTime = tlTime - (tlTime - self.cachedStartTime) * self.cachedTimeScale / n;
    self.cachedTimeScale = n;
    self:setDirtyCache(false);
end

-- override 
function TimelineLite:setDuration(n)
    local d = self:getDuration();
    if d ~= 0 and n ~= 0 then
        self:setTimeScale(d / n);
    end
end

function TimelineLite:getDuration()
    if self.cacheIsDirty then
        --just triggers recalculation
        local d = self:getTotalDuration();
    end

    return self.cachedDuration;
end

function TimelineLite:isUseFrames()
    local tl = self.timeline;
    while tl.timeline do
        tl = tl.timeline;
    end

    return tl == TweenLite.rootFramesTimeline;
end

-- override 
function TimelineLite:getRawTime()
    if self.cachedTotalTime ~= 0 and self.cachedTotalTime ~= self.cachedTotalDuration then
        return self.cachedTotalTime;
    else
        return (self.timeline:getRawTime() - self.cachedStartTime) * self.cachedTimeScale;
    end
end


