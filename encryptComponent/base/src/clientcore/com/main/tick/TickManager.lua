--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-5
-- Time: PM2:11
-- To change this template use File | Settings | File Templates.
--
requireClientCoreMain("tick.TickTimer");
requireClientCoreMain("tick.TickBase");
requireClientCoreMain("tick.TimerBase");

TickManager = class_quick("TickManager");
local m_ticks = {};
local m_timers = {};
local m_debugInfos = {};
local m_timerScaleFactors = {};
local m_ticksTotalNum = 0;
local m_tickHandler = nil;
local m_curLoopIndex = 1;
local gameTime = { totalTime = 0, frameTime = 0 };

function TickManager:ctor()
    self._tickTimerInS = nil;
    self._isDebug = false;
    self._tickTimersPool = {};
    self.systemStartTime = nil;
    self:initOsTime();
    self:startTick();
end

function TickManager:startTick()
    if not m_tickHandler then
        m_tickHandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.tick), 0, false);
    end
end

function TickManager:stopTick()
    if m_tickHandler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(m_tickHandler);
        m_tickHandler = nil;
    end
end

-- 钩子函数
function TickManager:tickHooker(dtInS, realTickIntervalInS)
end

function TickManager:tick(dtInS)
    --cocos2dx的tick触发很不稳定，下面是测试代码
    if dtInS > 1 then
        _t = _t or 0;
        local msg = string.format("异常瞬间fps:%f  tickmgr dt:%f  cocos dt: %f", 1.0 / dtInS, tickMgr:getTimer() - _t, dtInS)
        trace(HtmlUtil.createYellowTxt(msg));
        _t = tickMgr:getTimer();
        --异常帧的计时丢掉，目前以1秒作为判断，举例：ios上往下或者下往上拉菜单，是不会触发进入前后台的时间，cocos底层的计时器没有停止，所以切换回游戏后，返回的dtInS是一个贴近玩家菜单操作的时间，所以这一贞的计时我们要丢弃掉，否则timer会触发异常
        return
    end

    local t = self:getTime();
    local realTickIntervalInS = nil;
    if self._tickTimerInS then
        realTickIntervalInS = t - self._tickTimerInS;
    else
        realTickIntervalInS = dtInS;
    end
    self._tickTimerInS = t
    self:tickHooker(dtInS, realTickIntervalInS);
    -- print(#m_ticks, m_ticksTotalNum);

    gameTime.frameTime = dtInS * 1000;
    gameTime.totalTime = gameTime.totalTime + gameTime.frameTime;
    m_curLoopIndex = 1;
    while m_curLoopIndex <= m_ticksTotalNum do
        local timer = m_timers[m_curLoopIndex];
        local tick = m_ticks[m_curLoopIndex];
        local isTimer = false;
        if self._isDebug then
            isTimer = tick.__cname == "TimerBase"
        end
        if tick.isTicking and timer:isNextTime(gameTime) then
            self:markDebugInfo(tick, true)
            local b = tick:tick(timer.curFrameTime, timer.curFrameTimeReal);
            if isTimer then
                if b then
                    self:markDebugInfo(tick, false)
                end
            else
                self:markDebugInfo(tick, false)
            end
            timer:resetSomeData();
        end
        m_curLoopIndex = m_curLoopIndex + 1;
    end
    self:markMainTickDebug(t);
end

function TickManager:addTick(tick, cate)
    self:addCustomTick(tick, 0, 0, cate);
end

function TickManager:addCustomTick(tick, frequence, distanceTimeMs, cate)
    if not tick or table.indexof(m_ticks, tick) then
        return;
    else
        local timer = self:createTickTimer();
        cate = cate or 0;
        timer.cate = cate;
        if (not frequence or frequence == 0) and (not distanceTimeMs or distanceTimeMs == 0) then --没有设置时间
            distanceTimeMs = 1; --每一帧都触发
        elseif frequence ~= 0 and frequence ~= nil then
            distanceTimeMs = 1000 / frequence; --以frequence优先判断
        end
        timer.distanceTime = distanceTimeMs;

        if m_timerScaleFactors[cate] then
            timer.timerScaleFactor = m_timerScaleFactors[cate]
        else
            m_timerScaleFactors[cate] = timer.timerScaleFactor;
        end

        table.insert(m_ticks, tick);
        table.insert(m_timers, timer);
        m_ticksTotalNum = m_ticksTotalNum + 1;
    end
end

function TickManager:clearTickTimerPool()
    self._tickTimersPool = {}
end

function TickManager:putTickTimer2Pool(tickTimer)
    if tickTimer then
        tickTimer:reset()
        table.insert(self._tickTimersPool, tickTimer)
    end
end

function TickManager:createTickTimer()
    return TableUtil.pop(self._tickTimersPool) or TickTimer.new();
    -- return TickTimer.new();
end

function TickManager:removeTick(tick)
    local index = table.indexof(m_ticks, tick);
    if index then
        local timer = m_timers[index]
        table.remove(m_ticks, index);
        table.remove(m_timers, index);
        m_curLoopIndex = math.max(m_curLoopIndex - 1, 1);
        m_ticksTotalNum = m_ticksTotalNum - 1;
        self:putTickTimer2Pool(timer)
    end
end


function TickManager:setTicksTimeScaleByCate(cate, timeScale)
    for k, timer in pairs(m_timers) do
        if timer.cate == cate then
            timer.timerScaleFactor = timeScale;
        end
    end
    m_timerScaleFactors[cate] = timeScale;
end

function TickManager:delayedCall(callback, delayInMs, repeatCount, isStartTick, traceName, cate)
    cate = cate or 0;
    if isStartTick == nil then
        isStartTick = true;
    end
    repeatCount = repeatCount or 0;
    local timer = TimerBase.new(callback, delayInMs, repeatCount, traceName, cate);
    if isStartTick then
        timer:start();
    end

    return timer;
end

function TickManager:initOsTime()
    if not self.socket then
        self.scoket = require("socket");
        self.systemStartTime = self:getTime();
    end
end

-- 单位秒，自 1970 年 1 月 1 日午夜（通用时间）以来的秒数。
function TickManager:getTime()
    return self.scoket:gettime();  
end

-- 单位秒，返回初始化 TickManager 后经过的秒数，可使用它来计算相对时间。

-- 注意这个值是不受TickManager:startTick或者
-- TickManager:stopTick影响，是不间断非常准确的实际时间
function TickManager:getTimer()
    return self:getTime() - self.systemStartTime;
end

-- 单位毫秒，返回初始化 TickManager 后经过的毫秒数，可使用它来计算相对时间。
-- 注意这个值是不受TickManager:startTick或者
-- TickManager:stopTick影响，是不间断非常准确的实际时间
function TickManager:getTimerMS()
    return math.floor((self:getTime() - self.systemStartTime) * 1000);
end

-- 获取今天的秒数
function TickManager:getTodaySecond()
    local tab = os.date("*t", self:getTime());
    return tab.sec + (tab.min + tab.hour * 60) * 60
end


function TickManager:nextFrameCall(callback)
    local id = nil;
    local function call()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(id);
        applyFunction(callback)
    end

    id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(call, 0, false);
end

--同步服务器时间
function TickManager:setServerTime(serverStamp)
    local localStamp = self.scoket:gettime()
    self.timeDifference = serverStamp - localStamp
    return curStamp
end
--获取服务器时间
function TickManager:getServerTime()
    local localStamp = self.scoket:gettime()
    local curStamp = localStamp + (self.timeDifference or 0)
    return curStamp
end

-- 得到今天零点的时间戳
function TickManager:getTodayZeroTimestamp()
    local pastSec = self:getTodaySecond();
    local serverSec = self:getServerTime();
    local zeroSec = serverSec - pastSec;

    return zeroSec;
end

-- 传入一个时间戳，判断是不是属于当天的时间
function TickManager:isToday(timestamp)
    local zeroSec = self:getTodayZeroTimestamp();
    return ((timestamp >= zeroSec) and (timestamp < zeroSec + 24 * 60 * 60));
end





























----------------- debug 相关：
function TickManager:isDebug()
    return self._isDebug;
end

function TickManager:setDebug(b)
    if self._isDebug ~= b then
        self._isDebug = b;
        if b then
            m_debugInfos._printT = tickMgr:getTimer();
        else
            m_debugInfos = {};
        end
    end
end


function TickManager:getDebugKey(tick)
    return tostring(tick.traceName or tick.__cname) .. " - " .. tostring(tick);
end

function TickManager:markMainTickDebug(t)
    if self._isDebug then
        local cost = self:getTime() - t;
        m_debugInfos._mainCostTotal = (m_debugInfos._mainCostTotal or 0) + cost;
        m_debugInfos._mainCallTotal = (m_debugInfos._mainCallTotal or 0) + 1;
        m_debugInfos._mainMinCost = math.min(m_debugInfos._mainMinCost or 1000000000, cost);
        m_debugInfos._mainMaxCost = math.max(m_debugInfos._mainMaxCost or 0, cost);
    end
end

function TickManager:markDebugInfo(tick, isCallBegin)
    if self._isDebug then
        local key = self:getDebugKey(tick)
        local vo = m_debugInfos[key];
        if not vo then
            vo = {}
            vo.key = key
            local fps = tick._fps;
            if tick.delayInMs and tick.delayInMs ~= 0 then --timer
                fps = math.min(math.floor(1000 / math.max(tick.delayInMs, 1) * 100000) / 100000, 60)
            end
            vo.fps = fps;
            m_debugInfos[key] = vo;
        end

        if isCallBegin then
            vo.t1 = self:getTimer();
        elseif vo.t1 then
            local cost = tickMgr:getTimer() - vo.t1;
            vo.callTotal = (vo.callTotal or 0) + 1;
            vo.maxCost = math.max(vo.maxCost or 0, cost);
            vo.minCost = math.min(vo.minCost or 1000000000, cost);
            vo.costTotal = (vo.costTotal or 0) + cost;
            vo.t1 = nil;
        end
    end
end

function TickManager:printDebugInfo(force)
    if self._isDebug then
        local interval = tickMgr:getTimer() - m_debugInfos._printT;
        if interval > 10 or force then
            local floatBit = 7; --小数位多少位
            local mavg = fixFloat(m_debugInfos._mainCostTotal / m_debugInfos._mainCallTotal, floatBit);
            local green = HtmlUtil.createGreenTxt;
            local tickMgrInfo = HtmlUtil.createWhiteTxt(green(" avg:") .. mavg .. green(", max:") .. fixFloat(m_debugInfos._mainMaxCost, floatBit) .. green(", min:") .. fixFloat(m_debugInfos._mainMinCost, floatBit) .. green(", call:") .. m_debugInfos._mainCallTotal .. green(", cost:") .. fixFloat(m_debugInfos._mainCostTotal, floatBit));
            local content = "\ntickMgr:\n" .. tickMgrInfo;

            local count = 0;
            local printArr = {}
            for key, vo in pairs(m_debugInfos) do
                if type(vo) == "table" and vo.costTotal then
                    table.insert(printArr, vo)
                end
            end
            local function keySorter(a, b)
                return a.key < b.key;
            end

            table.sort(printArr, keySorter)
            for i, vo in ipairs(printArr) do
                content = content .. "\n" .. vo.key
                local avg = fixFloat(vo.costTotal / vo.callTotal, floatBit);
                local infoStr = green(" fps:") .. vo.fps .. green("\navg:") .. avg .. green(", max:") .. fixFloat(vo.maxCost, floatBit) .. green(", min:") .. fixFloat(vo.minCost, floatBit) .. green(", call:") .. vo.callTotal .. green(", cost:") .. fixFloat(vo.costTotal, floatBit);
                content = content .. HtmlUtil.createWhiteTxt(infoStr);
                count = count + 1;
            end

            if content ~= "" then
                traceLog("期间执行过tick()的详细列表 (" .. fixFloat(interval, floatBit) .. "s内, " .. count .. "个)：" .. HtmlUtil.createOrangeTxt(content) .. "\n")
            end

            m_debugInfos = {};
            m_debugInfos._printT = tickMgr:getTimer();
        end
    end
end


function TickManager:printInfo(printClassName)
    if printClassName then
        local content = ""
        for i, v in ipairs(m_ticks) do
            content = content .. "\n" .. tostring(v.traceName or v.__cname)
            local fps = v._fps;
            if v.delayInMs and v.delayInMs ~= 0 then --timer
                -- content = content .. HtmlUtil.createYellowTxt(" delayInMs:" .. v.delayInMs);
                fps = math.min(math.floor(1000 / math.max(v.delayInMs, 1) * 100000) / 100000, 60)
            end
            content = content .. HtmlUtil.createWhiteTxt(" fps:" .. fps);
        end
        if content ~= "" then
            traceLog("tick有下列：" .. #m_ticks .. HtmlUtil.createOrangeTxt(content))
        end
    end
end

-- 获取协调世界时标准时间（utc）的时间戳秒数（注意不是北京时间，北京的是utc+8，请用getChinaTime）
-- unixTime 如果空则是当前时间
function TickManager:getUTCTime(unixTime)
    local curTime = os.date("!*t", unixTime)
    local timeZone = math.floor(tonumber(os.date("%z", 0)) / 100)
    if timeZone >= 0 then
        curTime.isdst = false
    else
        if timeZone ~= -11 then
            curTime.isdst = true
        end
    end

    -- 转成时间戳
    return os.time(curTime)
end

-- 返回北京时间秒数
-- beijingUnix 如果空则是当前时间
function TickManager:getChinaTime(beijingUnix)
    local curTime = self:getUTCTime(beijingUnix)
    -- 增加东八区时差 得到北京时间
    curTime = curTime + 8 * 3600
    return curTime
end

tickMgr = TickManager.new();

return tickMgr;