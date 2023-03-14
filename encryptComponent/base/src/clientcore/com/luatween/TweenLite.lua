--
-- Author: senji
-- Date: 2014-02-07 10:45:48
-- 
-- 第三个缓动参数(vars)的附加支持:
-- (常用)
-- delay：number 单位秒
-- onUpdate：function
-- onUpdateParams：table
-- onComplete：function
-- onCompleteParams：table
-- ease：function 参考Ease.lua
--
-- onInit：function
-- onInitParams：table
-- onStart：function
-- onStartParams：table
-- onReverseComplete：function
-- onReverseCompleteParams：table
-- timeScale：number
-- paused：boolean
-- overwrite：int
-- immediateRender：boolean
-- useFrames：boolean duration是否使用帧做单位，如果true，duration则为帧的意思，默认是false，duration为秒
-- 
-- 常用方法:
-- TweenLite.to()
-- TweenLite.from() 反过来缓动
-- TweenLite.killTweensOf() 删除所有Tween
--
TweenLite = class_quick("TweenLite");

TweenLite.tickCate = 19870720; --TickManager中的tick类型
TweenLite.version = 11.36;
TweenLite.tweenGcFrameCount = 60 * 1; --多少帧执行一次tweenlite内部的gc
if isAndroid then
    TweenLite.tickIntervalInS = 1 / 60;
else
    TweenLite.tickIntervalInS = 1 / 60;
end
TweenLite.tickIntervalMinInS = 1 / 30;

TweenLite.plugins = {};
TweenLite.fastEaseLookup = {};
TweenLite.onPluginEvent = nil; --function
TweenLite.overwriteManager = nil;
TweenLite.tweenSystemDeployInS = 0; --系统启动时刻，单位秒

TweenLite.driveTimer = nil;--驱动tweenlite系统的timer


--下面这个boolean值得重点说说
-- as3是没有这个属性的，
-- true ：as3方式
-- 这种情况下，缓动的duration是相对真实世界的时间，所以缓动是保证在duration下到达效果(如果cpu出现卡顿，则会表现出缓动跳跃)
-- false：
-- 这种情况下，缓动的duration是相对TickManager所缓存的时间
-- 两种情况的真实对比：
-- 情况：Tween要3秒内让x从0改变到150
-- 当执行1秒时，x是50，此时TickManager停止了，两种情况的表现都是相同的，会暂停，
-- 当暂停了两秒，TickManager再启动，true的情况会立刻让x变成150（出现缓动跳跃）
-- 而false的情况则会继续从50开始缓动，false的情况会比较顺滑一点
TweenLite.useRealTimerTicking = false;

TweenLite.rootFrame = nil; --0;
TweenLite.rootTimeline = nil;
TweenLite.rootFramesTimeline = nil;

TweenLite.masterList = {};
TweenLite._reservedProps = { ease = 1, delay = 1, overwrite = 1, onComplete = 1, onCompleteParams = 1, useFrames = 1, runBackwards = 1, startAt = 1, onUpdate = 1, onUpdateParams = 1, roundProps = 1, onStart = 1, onStartParams = 1, onInit = 1, onInitParams = 1, onReverseComplete = 1, onReverseCompleteParams = 1, onRepeat = 1, onRepeatParams = 1, proxiedEase = 1, easeParams = 1, yoyo = 1, onCompleteListener = 1, onUpdateListener = 1, onStartListener = 1, onReverseCompleteListener = 1, onRepeatListener = 1, orientToBezier = 1, timeScale = 1, immediateRender = 1, repeatCount = 1, repeatDelay = 1, timeline = 1, data = 1, paused = 1 };


function TweenLite:ctor(target, duration, vars)
    self.target = nil;
    self.propTweenLookup = nil;
    self.ratio = 0;
    self.cachedPT1 = nil;
    self._ease = nil;
    self._overwrite = 0;
    self._overwrittenProps = nil;
    self._hasPlugins = false;
    self._notifyPluginsOfEnabled = false;

    ClassUtil.extends(self, TweenCore, true, duration, vars);
    self.target = target;
    LuaTweenConfig.checkCocos2dxRetain(target, self);
    if ClassUtil.is(self.target, TweenCore) and self.vars.timeScale then
        self.cachedTimeScale = 1;
    end

    self.propTweenLookup = {};
    self._ease = TweenLite.defaultEase;
    -- vars.overwrite = vars.overwrite or 0;
    -- if not (vars.overwrite > -1) or not TweenLite.overwriteManager.enabled and vars.overwrite > 1 then
    --     self._overwrite = TweenLite.overwriteManager.mode;
    -- else
    --     self._overwrite = parseInt(vars.overwrite);
    -- end

    if not vars.overwrite or not (vars.overwrite > -1) or (not TweenLite.overwriteManager.enabled and vars.overwrite > 1) then
        self._overwrite = TweenLite.overwriteManager.mode;
    else
        self._overwrite = parseInt(vars.overwrite);
    end

    local masterList = TweenLite.masterList
    local a = masterList[target];
    if not a then
        masterList[target] = { self };
    else
        if self._overwrite == 1 then
            for k, sibling in pairs(a) do
                if not sibling.gc then
                    sibling:setEnabled(false, false);
                end
            end
            masterList[target] = { self };
        else
            table.insert(a, self);
        end
    end

    if self.active or self.vars.immediateRender then
        self:renderTime(0, false, true);
    end
end

function TweenLite:init()
    if self.vars.onInit then
        applyFunction(self.vars.onInit, self.vars.onInitParams);
    end
    local i = 0;
    local plugin = nil;
    local prioritize = false;
    local siblings = nil;

    if type(self.vars.ease) == "function" then
        self._ease = self.vars.ease;
    end

    if self.vars.easeParams then
        self.vars.proxiedEase = _ease;
        self._ease = easeProxy;
    end

    self.cachedPT1 = nil;
    self.propTweenLookup = {};
    for p, v in pairs(self.vars) do
        if TweenLite._reservedProps[p] ~= nil and not (p == "timeScale" and ClassUtil.is(self.target, TweenCore)) then
            --ignore
        else
            local hasPluginClazz = TweenLite.plugins[p] ~= nil;
            plugin = nil;
            if hasPluginClazz then
                plugin = TweenLite.plugins[p].new();
            end
            if hasPluginClazz and plugin:onInitTween(self.target, self.vars[p], self) then
                local tempName = "_MULTIPLE_";
                if #plugin.overwriteProps == 1 then
                    tempName = plugin.overwriteProps[1];
                end
                self.cachedPT1 = PropTween.new(plugin, "changeFactor", 0, 1, tempName, true, self.cachedPT1);

                if self.cachedPT1.name == "_MULTIPLE_" then
                    i = #plugin.overwriteProps;
                    while i > 0 do
                        self.propTweenLookup[plugin.overwriteProps[i]] = self.cachedPT1;
                        i = i - 1;
                    end
                else
                    self.propTweenLookup[self.cachedPT1.name] = self.cachedPT1;
                end
            else
                local targetValue = LuaTweenConfig.getTargetValue(self.target, p);
                local toValue = 0;
                if type(self.vars[p]) == "string" then
                    toValue = checknumber(self.vars[p]);
                else
                    toValue = self.vars[p] - targetValue;
                end
                self.cachedPT1 = PropTween.new(self.target, p, targetValue, toValue, p, false, self.cachedPT1);
                self.propTweenLookup[p] = self.cachedPT1;
            end
        end
    end
    if prioritize then
        self:onPluginEvent("onInit", self);
    end

    if self.vars.runBackwards then
        local pt = self.cachedPT1;
        while pt do
            pt.start = pt.change + pt.start;
            pt.change = -pt.change;
            pt = pt.nextNode;
        end
    end

    self._hasUpdate = self.vars.onUpdate ~= nil;
    if self._overwrittenProps then
        self:killVars(self._overwrittenProps);
        if self.cachedPT1 == nil then
            self:setEnabled(false, false);
        end
    end

    if self._overwrite > 1 and self.cachedPT1 then
        siblings = TweenLite.masterList[self.target];
        if #siblings > 1 then
            if TweenLite.overwriteManager.manageOverwrites(self, self.propTweenLookup, siblings, self._overwrite) then
                self:init();
            end
        end
    end

    self.initted = true;
end

function TweenLite:renderTime(time, suppressEvents, force)
    local isComplete = false;
    local prevTime = self.cachedTime;
    if time >= self.cachedDuration then
        self.cachedTotalTime = self.cachedDuration;
        self.cachedTime = self.cachedDuration;
        self.ratio = 1;
        isComplete = true;
        if self.cachedDuration == 0 then
            if (time == 0 or self._rawPrevTime < 0) and self._rawPrevTime ~= time then
                force = true;
            end
            self._rawPrevTime = time;
        end
    elseif time < 0 then
        self.ratio = 0;
        self.cachedTotalTime = 0;
        self.cachedTime = 0;
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

        if self.cachedReversed and prevTime ~= 0 then
            isComplete = true;
        end
    else
        self.cachedTime = time;
        self.cachedTotalTime = time;
        self.ratio = self._ease(self.cachedTime, 0, 1, self.cachedDuration);
    end
    if self.cachedTime == prevTime and not force then
        return;
    elseif not self.initted then
        self:init();
        if not isComplete and self.cachedTime then
            self.ratio = self._ease(self.cachedTime, 0, 1, self.cachedDuration);
        end
    end

    if not self.active and not self.cachedPaused then
        self.active = true;
    end

    if prevTime == 0 and self.vars.onStart and self.cachedTime ~= 0 and not suppressEvents then
        applyFunction(self.vars.onStart, self.vars.onStartParams);
    end

    local pt = self.cachedPT1;
    while pt do
        --pt.target[pt.property] = pt.start + self.ratio * self.change; --这里就是改变值的
        LuaTweenConfig.setTargetValue(pt.target, pt.property, pt.start + self.ratio * pt.change);
        pt = pt.nextNode;
    end

    if self._hasUpdate and not suppressEvents then
        applyFunction(self.vars.onUpdate, self.vars.onUpdateParams);
    end
    if isComplete then
        if self._hasPlugins and self.cachedPT1 then
            self.onPluginEvent("onComplete", self);
        end
        self:complete(true, suppressEvents);
    end
end

function TweenLite:easeProxy(t, b, c, d)
    if self.vars.easeParams then
        return self.vars.proxiedEase(t, b, c, d, unpack(self.vars.easeParams));
    else
        return self.vars.proxiedEase(t, b, c, d)
    end
end

function TweenLite:setEnabled(enabled, ignoreTimeline)
    if enabled then
        local a = TweenLite.masterList[self.target];
        if not a then
            TweenLite.masterList[self.target] = { self };
        else
            table.insert(a, self);
        end
    end

    TweenCore.setEnabled(self, enabled, ignoreTimeline);
    if self._notifyPluginsOfEnabled and self.cachedPT1 then
        local eventType = "onEnable";
        if not enabled then
            eventType = "onDisable";
        end
        return self.onPluginEvent(eventType, self); -- todo 注意onPluginEvent是有返回值的！
    end
    return false;
end

function TweenLite:killVars(vars, permanent)
    if permanent == nil then
        permanent = true;
    end
    local changed = false;
    if not self._overwrittenProps then
        self._overwrittenProps = {};
    end

    for p, v in pairs(vars) do
        local pt = self.propTweenLookup[p];
        if pt then
            if pt.isPlugin and pt.name == "_MULTIPLE_" then
                pt.target:killProps(vars);
                if #pt.target.overwriteProps == 0 then
                    pt.name = "";
                end
            end

            if pt.name ~= "_MULTIPLE_" then
                if pt.nextNode then
                    pt.nextNode.prevNode = pt.prevNode;
                end
                if pt.prevNode then
                    pt.prevNode.nextNode = pt.nextNode;
                elseif self.cachedPT1 == pt then
                    self.cachedPT1 = pt.nextNode;
                end

                if pt.isPlugin and pt.target.onDisable then
                    pt.target:onDisable();
                    if pt.target.activeDisable then
                        changed = true;
                    end
                end

                self.propTweenLookup[p] = nil;
            end
        end

        if permanent and vars ~= self._overwrittenProps then
            self._overwrittenProps[p] = 1;
        end
    end

    return changed;
end

function TweenLite:invalidate()
    if self._notifyPluginsOfEnabled and self.cachedPT1 then
        self:onPluginEvent("onDisable", self);
    end

    self.cachedPT1 = nil;
    self._overwrittenProps = nil;
    self._hasUpdate = false;
    self.initted = false;
    self.active = false;
    self._notifyPluginsOfEnabled = false;
    self.propTweenLookup = {};
end

--静态
function TweenLite.updateAll(dtInMs, dtInMsReal)
    local rootTimeline = TweenLite.rootTimeline;
    if TweenLite.useRealTimerTicking then
        TweenLite.tweenSystemDeployInS = tickMgr:getTimer() - rootTimeline.cachedStartTime;
    else
        local curTime = tickMgr:getTimer();
        local frameTime = curTime - TweenLite.systemDeployInS;
        TweenLite.systemDeployInS = curTime;
        frameTime = math.min(frameTime, TweenLite.tickIntervalMinInS)
        -- TweenLite.tweenSystemDeployInS = TweenLite.tweenSystemDeployInS + TweenLite.tickIntervalInS;
        TweenLite.tweenSystemDeployInS = TweenLite.tweenSystemDeployInS + frameTime;
    end
    rootTimeline:renderTime(TweenLite.tweenSystemDeployInS * rootTimeline.cachedTimeScale, false, false);

    TweenLite.rootFrame = TweenLite.rootFrame + 1;
    local rootFramesTimeline = TweenLite.rootFramesTimeline;
    rootFramesTimeline:renderTime((TweenLite.rootFrame - rootFramesTimeline.cachedStartTime) * rootFramesTimeline.cachedTimeScale, false, false);

    TweenLite.checkGc();
end

function TweenLite.checkGc(force)
    if force or TweenLite.rootFrame % TweenLite.tweenGcFrameCount == 0 then -- 检查gc
        local deleteKeys = {};
        local ml = TweenLite.masterList;
        for tgt, a in pairs(ml) do
            local len = #a;
            local i = 1;
            while i <= len do
                local tl = a[i]
                if tl.gc then
                    LuaTweenConfig.checkCocos2dxRelease(tgt, tl);
                    table.remove(a, i);
                    i = i - 1;
                    len = len - 1;
                end

                i = i + 1;
            end
            if len == 0 then
                table.insert(deleteKeys, tgt);
            end
        end

        for k, tgt in pairs(deleteKeys) do
            ml[tgt] = nil;
        end
    end
end

function TweenLite.to(target, duration, vars)
    return TweenLite.new(target, duration, vars);
end

function TweenLite.from(target, duration, vars)
    vars.runBackwards = true;
    if vars.immediateRender == nil then
        vars.immediateRender = true;
    end
    return TweenLite.new(target, duration, vars);
end


function TweenLite.killTweensOf(target, complete, vars)
    local arr = TweenLite.masterList[target];
    if arr then
        for i = #arr, 1, -1 do
            local tween = arr[i];
            if not tween.gc then
                if complete then
                    tween:complete(false, false);
                end
                if vars then
                    tween:killVars(vars);
                end
                if not vars or (not tween.cachedPT1 and tween.initted) then
                    tween:setEnabled(false, false);
                end

                -- 下面这个是我自己加上去的，官方没有这样的用法，是希望killtweensof时候把timeline也kill掉
                -- 注意，如果执行下面代码，会出现各种timeline莫名其妙停掉的问题！慎用
                -- if tween.timeline then
                --     tween.timeline:kill()
                -- end
            end

            if not vars then
                --shengsmark 这里不走gc流程的，所以要小心这里要移除引用
                LuaTweenConfig.checkCocos2dxRelease(target, nil);
            end
        end

        if not vars then
            TweenLite.masterList[target] = nil;
        end
    end
end

function TweenLite.initClass()
    TweenLite.rootFrame = 0;
    local rootTimeline = SimpleTimeline.new();
    TweenLite.tweenSystemDeployInS = 0;
    if TweenLite.useRealTimerTicking then
        TweenLite.tweenSystemDeployInS = tickMgr:getTimer();
    else
        TweenLite.systemDeployInS = tickMgr:getTimer();
    end
    rootTimeline.cachedStartTime = TweenLite.tweenSystemDeployInS;
    rootTimeline.autoRemoveChildren = true;

    local rootFramesTimeline = SimpleTimeline.new();
    rootFramesTimeline.cachedStartTime = TweenLite.rootFrame;
    rootFramesTimeline.autoRemoveChildren = true;

    TweenLite.rootTimeline = rootTimeline;
    TweenLite.rootFramesTimeline = rootFramesTimeline;

    TweenLite.driveTimer = tickMgr:delayedCall(TweenLite.updateAll, TweenLite.tickIntervalInS * 1000, -1, true, TweenLite.tickCate):changeTraceName("TweenLite.updateAll");

    if not TweenLite.overwriteManager then
        TweenLite.overwriteManager = { mode = 1, enabled = false };
    end
end

function TweenLite.easeOut(t, b, c, d)
    t = 1 - (t / d);
    return 1 - t * t;
end

function TweenLite.delayedCall(onComplete, delayInS, onCompleteParams, useFrames)
    return TweenLite.new(onComplete, delayInS, { onComplete = onComplete, onCompleteParams = onCompleteParams, immediateRender = false, useFrames = useFrames, overwrite = 0 });
    -- return TweenLite.new(target, duration, vars);
end

function TweenLite.printInfo()
    traceLog("tween masterlist count:", table.nums(TweenLite.masterList));
    -- for k,v in pairs(TweenLite.masterList) do
    --     local name = "";
    --     if k.getName then
    --         name = k:getName();
    --     end
    --     print("缓存着的tween:", tolua.type(k), name)
    -- end
end

TweenLite.defaultEase = TweenLite.easeOut;
TweenLite.killDelayedCallsTo = TweenLite.killTweensOf;
