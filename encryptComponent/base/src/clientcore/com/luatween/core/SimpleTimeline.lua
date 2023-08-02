--
-- Author: senji
-- Date: 2014-02-07 12:40:07
--
SimpleTimeline = class_quick("SimpleTimeline")


function SimpleTimeline:ctor(vars)
    self._firstChild = nil;
    self._lastChild = nil;
    self.autoRemoveChildren = false;
    ClassUtil.extends(self, TweenCore, true, 0, vars);
end

function SimpleTimeline:addChild(tween)
    if not tween.cachedOrphan and tween.timeline then
        tween.timeline:remove(tween, true);
    end

    tween.timeline = self;
    if tween.gc then
        tween:setEnabled(true, true);
    end

    if self._firstChild then
        self._firstChild.prevNode = tween;
    end
    tween.nextNode = self._firstChild;
    self._firstChild = tween;
    tween.prevNode = nil;
    tween.cachedOrphan = false;
end


function SimpleTimeline:remove(tween, skipDisable)
    if tween.cachedOrphan then
        return;
    elseif not skipDisable then
        tween:setEnabled(false, true);
    end

    if tween.nextNode then
        tween.nextNode.prevNode = tween.prevNode;
    elseif self._lastChild == tween then
        self._lastChild = tween.prevNode;
    end

    if tween.prevNode then
        tween.prevNode.nextNode = tween.nextNode;
    elseif self._firstChild == tween then
        self._firstChild = tween.nextNode;
    end
    tween.cachedOrphan = true;
end

function SimpleTimeline:renderTime(time, suppressEvents, force)
    local tween = self._firstChild;
    local dur = 0;
    local next = nil;
    self.cachedTotalTime = time;
    self.cachedTime = time;

    while tween do
        next = tween.nextNode;
        if tween.active or (time >= tween.cachedStartTime and not tween.cachedPaused and not tween.gc) then
            if not tween.cachedReversed then
                tween:renderTime((time - tween.cachedStartTime) * tween.cachedTimeScale, suppressEvents, false);
            else
                if tween.cacheIsDirty then
                    dur = tween:getTotalDuration();
                else
                    dur = tween.cachedTotalDuration
                end
                tween:renderTime(dur - (time - tween.cachedStartTime) * tween.cachedTimeScale, suppressEvents, false);
            end
        end

        tween = next;
    end
end

function SimpleTimeline:getRawTime()
    return self.cachedTotalTime;
end




