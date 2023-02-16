
TimerBase = class_quick("TimerBase")

--[[
-- 参数：
-- 1.callback,
-- 2.延时间隔(ms),
--3.repeatCount：除了第一次之外的重复次数，-1则无限循环， 也就是0：只调用一次
--4.tick的分类，详细参看TickBase的分类
-- ]]
function TimerBase:ctor(callback, delayInMs, repeatCount, traceName, tickCate)
    self.callback = callback;
    self.delayInMs = delayInMs;
    self.repeatCount = repeatCount or 0;
    self.tickCate = tickCate or 0;
    self.curTickCount = 0;
    self.traceName = traceName;--跟踪用的名字
    self.autoDispose = true;
    self.elapsedTime = 0;
    self.tickIntervalInMs = 0; --触发tick的时间间隔
    self.tickIntervalRealInMs = 0; --触发tick的真实时间间隔（变速时和tickIntervalInMs不同）

    ClassUtil.extends(self, TickBase);
end

function TimerBase:doTick(dtInMs, dtInMsReal)
    self.curTickCount = self.curTickCount + 1;
    local shouldStop = self.repeatCount >= 0 and self.curTickCount >= self.repeatCount + 1;
    local shouldDispose = shouldStop and self.autoDispose;
    if shouldStop then
        self:stop();
    end
    self.callback(dtInMs, dtInMsReal);
    if shouldDispose then
        self:destroy();
    end
end

function TimerBase:tick(dtInMs, dtInMsReal)
    self.elapsedTime = self.elapsedTime + dtInMs;
    self.tickIntervalInMs = self.tickIntervalInMs + dtInMs;
    self.tickIntervalRealInMs = self.tickIntervalRealInMs + dtInMsReal;
    if self.elapsedTime > self.delayInMs then
        self.elapsedTime = self.elapsedTime - self.delayInMs;
        self:doTick(self.tickIntervalInMs, self.tickIntervalRealInMs);
        self.tickIntervalInMs = 0;
        self.tickIntervalRealInMs = 0;
        return true;
    end

    return false
end

function TimerBase:changeTraceName(traceName)
    self.traceName = traceName
    return self;
end

function TimerBase:reset()
    self.elapsedTime = 0;
    self.curTickCount = 0;
    self.tickIntervalInMs = 0;
    self.tickIntervalRealInMs = 0;
    self:stop();
end

function TimerBase:setAutoDispose(b)
    self.autoDispose = b;
end

function TimerBase:stop()
    self:stopTick();
end

function TimerBase:getIsRunning()
    return self:getIsTicking();
end

function TimerBase:start()
    self:startTick();--这里是fps60执行，但是tick的时候会做时间过滤
end

function TimerBase:destroy()
    TickBase.destroy(self);
    self.callback = nil;
end

return TimerBase;
