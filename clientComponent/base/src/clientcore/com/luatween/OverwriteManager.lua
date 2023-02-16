--
-- Author: senji
-- Date: 2014-02-09 15:22:19
--

OverwriteManager = class_quick("OverwriteManager");

OverwriteManager.version = 6.02;
OverwriteManager.NONE = 0;
OverwriteManager.ALL_IMMEDIATE = 1;
OverwriteManager.AUTO = 2;
OverwriteManager.CONCURRENT = 3;
OverwriteManager.ALL_ONSTART = 4;
OverwriteManager.PREEXISTING = 5;
OverwriteManager.mode = nil;
OverwriteManager.enabled = false;

function OverwriteManager.init(defaultMode)
    defaultMode = defaultMode or 2;
    if TweenLite.version < 11.1 then
        assert(false, "Warning: Your TweenLite class needs to be updated to work with OverwriteManager (or you may need to clear your ASO files");
    end
    TweenLite.overwriteManager = OverwriteManager;
    OverwriteManager.mode = defaultMode;
    OverwriteManager.enabled = true;
    return OverwriteManager.mode;
end

function OverwriteManager.manageOverwrites(tween, props, targetTweens, mode)
    local i = 0;
    local changed = false;
    local curTween = nil;
    -- local mode = OverwriteManager.mode;
    if mode >= 4 then
        local l = #targetTweens;
        for i = 1, l do
            curTween = targetTweens[i];
            if curtween ~= tween then
                if curTween:setEnabled(false, false) then
                    changed = true;
                end
            elseif mode == 5 then
                break;
            end
        end
        return changed;
    end

    local startTime = tween.cachedStartTime + 0.0000000001;
    local overlaps = {};
    local cousins = {};
    local cCount = 0;
    local oCount = 0;

    i = #targetTweens;
    while i > 0 do
        curTween = targetTweens[i];
        if curTween == tween or curTween.gc then
            --ignore
        elseif curTween.timeline ~= tween.timeline then
            if not OverwriteManager.getGlobalPaused(curTween) then
                cousins[cCount + 1] = curTween;
                cCount = cCount + 1;
            end
        elseif curTween.cachedStartTime <= startTime and curTween.cachedStartTime + curTween:getTotalDuration() + 0.0000000001 > startTime and not OverwriteManager.getGlobalPaused(curTween) then
            overlaps[oCount + 1] = curTween;
            oCount = oCount + 1;
        end

        i = i - 1;
    end

    if cCount ~= 0 then
        local combinedTimeScale = tween.cachedTimeScale;
        local combinedStartTime = startTime;
        local cousin = nil;
        local cousinStartTime = 0;
        local timeline = nil;

        timeline = tween.timeline;
        while timeline do
            combinedTimeScale = combinedTimeScale * timeline.cachedTimeScale;
            combinedStartTime = combinedStartTime + timeline.cachedStartTime;
            timeline = timeline.timeline;
        end

        startTime = combinedTimeScale * combinedStartTime;
        i = cCount;
        while i > 0 do
            cousin = cousins[i];
            combinedTimeScale = cousin.cachedTimeScale;
            combinedStartTime = cousin.cachedStartTime;
            timeline = cousin.timeline;
            while timeline do
                combinedTimeScale = combinedTimeScale * timeline.cachedTimeScale;
                combinedStartTime = combinedStartTime + timeline.cachedStartTime;
                timeline = timeline.timeline;
            end
            cousinStartTime = combinedTimeScale * combinedStartTime;
            if cousinStartTime <= startTime and (cousinStartTime + cousin:getTotalDuration() * combinedTimeScale + 0.0000000001 > startTime or cousin.cachedDuration == 0) then
                overlaps[oCount + 1] = cousin;
                oCount = oCount + 1;
            end
            i = i - 1;
        end
    end

    if oCount == 0 then
        return changed;
    end

    i = oCount;
    if mode == 2 then
        while i > 0 do
            curTween = overlaps[i];
            if curTween:killVars(props) then
                changed = true;
            end

            if not curTween.cachedPT1 and curTween.initted then
                curTween:setEnabled(false, false);
            end

            i = i - 1;
        end
    else
        while i > 0 do
            if overlaps[i]:setEnabled(false, false) then
                changed = true;
            end
            i = i - 1;
        end
    end

    return changed;
end

function OverwriteManager.getGlobalPaused(tween)
    while tween do
        if tween.cachedPaused then
            return true;
        end
        tween = tween.timeline;
    end
    return false;
end
