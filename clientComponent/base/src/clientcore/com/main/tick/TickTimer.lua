--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-5
-- Time: PM4:00
--

TickTimer = class_quick("TickTimer")

function TickTimer:ctor()
    self.timerScaleFactor = 1;
    self.elapsedTime = 0;
    self.curFrameTimeReal = 0;
    self.curFrameTime = 0;
    self.distanceTime = 0;
end

function TickTimer:isNextTime(gameTimer)
    local passTime = gameTimer.frameTime * self.timerScaleFactor;
    self.elapsedTime = self.elapsedTime + passTime;
    self.curFrameTimeReal = self.curFrameTimeReal + gameTimer.frameTime;
    self.curFrameTime = self.curFrameTime + passTime;
    if self.elapsedTime >= self.distanceTime and self.distanceTime ~= 0 then
        self.elapsedTime = self.elapsedTime % self.distanceTime;
        -- self.elapsedTime = 0;
        return true
    end
    return false;
end

function TickTimer:reset()
    self.timerScaleFactor = 1;
    self.elapsedTime = 0;
    self.curFrameTimeReal = 0;
    self.curFrameTime = 0;
    self.distanceTime = 0;
end

function TickTimer:resetSomeData()
    self.curFrameTimeReal = 0;
    self.curFrameTime = 0;
end

return TickTimer;