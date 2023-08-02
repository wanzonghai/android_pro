--
-- Author: senji
-- Date: 2014-02-07 00:24:27
--

TweenCore = class_quick("TweenCore");

TweenCore._classInitted = false;
TweenCore.version = 1.382;

function TweenCore:ctor(duration, vars)
    self._delay = 0;
    self._hasUpdate = false;
    self._rawPrevTime = 0;
    self._pauseTime = 0;

    self.vars = nil;
    self.active = false;
    self.gc = false;
    self.initted = false;
    self.timeline = nil;
    self.cachedStartTime = 0;
    self.cachedTime = 0;
    self.cachedTotalTime = 0;
    self.cachedDuration = 0;
    self.cachedTotalDuration = 0;
    self.cachedTimeScale = 0;
    self.cachedReversed = false;
    self.nextNode = nil;
    self.prevNode = nil;
    self.cachedOrphan = false;
    self.cacheIsDirty = false;
    self.cachedPaused = false;
    self.data = nil;


    self.vars = vars or {};
    self.cachedDuration = duration;
    self.cachedTotalDuration = duration;
    self._delay = self.vars.delay or 0;
    self.cachedTimeScale = self.vars.timeScale or 1;
    self.active = duration == 0 and self._delay == 0 and self.vars.immediateRender ~= false;
    self.cachedTotalTime = 0;
    self.cachedTime = 0;
    self.data = self.vars.data;

    if not TweenCore._classInitted then
        if TweenLite.rootFrame == nil then
            TweenLite.initClass();
            TweenCore._classInitted = true;
        else
            return;
        end
    end

    local tl = nil;
    if ClassUtil.is(self.vars.timeline, SimpleTimeLine) then
        tl = self.vars.timeline;
    elseif self.vars.useFrames then
        tl = TweenLite.rootFramesTimeline;
    else
        tl = TweenLite.rootTimeline;
    end

    self.cachedStartTime = tl.cachedTotalTime + self._delay;
    tl:addChild(self);
    if self.vars.reversed then
        self.cachedReversed = true;
    end

    if self.vars.paused then
        self:setPaused(true);
    end
end

function TweenCore:setTotalTime(time, suppressEvents)
    if self.timeline then
        local tlTime = self._pauseTime;
        if self._pauseTime == nil then
            tlTime = self.timeline.cachedTotalTime;
        end

        if self.cachedReversed then
            local dur = self:getTotalDuration();
            if not self.cacheIsDirty then
                dur = self.cachedTotalDuration;
            end
            self.cachedStartTime = tlTime - (dur - time) / self.cachedTimeScale;
        else
            self.cachedStartTime = tlTime - (time / self.cachedTimeScale);
        end

        if not self.timeline.cacheIsDirty then
            self:setDirtyCache(false);
        end

        if self.cachedTotalTime ~= time then
            self:renderTime(time, suppressEvents, false);
        end
    end
end

function TweenCore:setTotalDuration(value)
    self:setDuration(value);
end

function TweenCore:getTotalDuration()
    return self.cachedTotalDuration;
end

function TweenCore:setDuration(value)
    self.cachedDuration = value;
    self.cachedTotalDuration = value;
    self:setDirtyCache(false);
end

function TweenCore:getDuration()
    return self.cachedDuration;
end

function TweenCore:setDirtyCache(includeSelf)
    local tween = self;
    if not includeSelf then
        tween = self.timeline;
    end

    while tween do
        tween.cacheIsDirty = true;
        tween = tween.timeline;
    end
end

function TweenCore:complete(skipRender, suppressEvents)
    if not skipRender then
        self:renderTime(self:getTotalDuration(), suppressEvents, false);
        return;
    end

    if self.timeline.autoRemoveChildren then
        self:setEnabled(false, false);
    else
        self.active = false;
    end

    if not suppressEvents then
        if self.vars.onComplete and self.cachedTotalTime == self.cachedTotalDuration and not self.cachedReversed then
            applyFunction(self.vars.onComplete, self.vars.onCompleteParams);
        elseif self.cachedReversed and self.cachedTotalTime == 0 and self.vars.onReverseComplete then
            applyFunction(self.vars.onReverseComplete, self.vars.onReverseCompleteParams);
        end
    end
end

function TweenCore:setEnabled(enabled, ignoreTimeline)
    self.gc = not enabled;
    if enabled then
        self.active = not self.cachedPaused and self.cachedTotalTime > 0 and self.cachedTotalTime < self.cachedTotalDuration;
        if not ignoreTimeline and self.cachedOrphan then
            self.timeline:addChild(self);
        end
    else
        self.active = false;
        if self.timeline and not ignoreTimeline and not self.cachedOrphan then
            self.timeline:remove(self, true);
        end
    end
    return false;
end

function TweenCore:kill()
    self:setEnabled(false, false);
end

--hook
function TweenCore:invalidate()
end

function TweenCore:getDelay()
    return self._delay;
end

function TweenCore:setDelay(n)
    self:setStartTime(self:getStartTime() + n - self._delay);
    self._delay = n;
end

function TweenCore:setStartTime(n)
    local adjust = self.timeline and (n ~= self.cachedStartTime or self.gc);
    self.cachedStartTime = n;
    if adjust then
        self.timeline:addChild(self);
    end
end

function TweenCore:getStartTime()
    return self.cachedStartTime;
end

function TweenCore:setPaused(b)
    if self.cachedPaused ~= b and self.timeline then
        if b then
            self._pauseTime = self.timeline:getRawTime();
        else
            self.cachedStartTime = self.cachedStartTime + self.timeline:getRawTime() - self._pauseTime;
            self._pauseTime = nil;
            self:setDirtyCache(false);
        end

        self.cachedPaused = b;
        self.active = not self.cachedPaused and self.cachedTotalTime > 0 and self.cachedTotalTime < self.cachedTotalDuration;
    end
    if not b and self.gc then
        self:setTotalTime(self.cachedTotalTime, false);
        self:setEnabled(true, false);
    end
end

function TweenCore:getPaused()
    return self.cachedPaused;
end

function TweenCore:getReversed()
    return self.cachedReversed;
end

function TweenCore:setReversed(b)
    if b ~= self.cachedReversed then
        self.cachedReversed = b;
        self:setTotalTime(self.cachedTotalTime, true);
    end
end

function TweenCore:getCurrentTime()
    return self.cachedTime;
end

function TweenCore:setCurrentTime(n)
    self:setTotalTime(n, false);
end

function TweenCore:play()
    self:setReversed(false);
    self:setPaused(false);
end

function TweenCore:pause()
    self:setPaused(true);
end

function TweenCore:resume()
    self:setPaused(false);
end

function TweenCore:gotoAndPlay(time, suppressEvents)
    self:setTotalTime(time, suppressEvents);
    self:play();
end

function TweenCore:gotoAndStop(time, suppressEvents)
    self:setTotalTime(time, suppressEvents)
    self:setPaused(true);
end

function TweenCore:restart(includeDelay, suppressEvents)
    self:setReversed(false);
    self:setPaused(false);
    local t = 0;
    if includeDelay then
        t = includeDelay;
    end
    self:setTotalTime(t, suppressEvents)
end

function TweenCore:reverse(forceResume)
    if forceResume == nil then
        forceResume = true;
    end
    self:setReversed(true);
    if forceResume then
        self:setPaused(false);
    elseif self.gc then
        self:setEnabled(true, false);
    end
end






