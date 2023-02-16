--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-5
-- Time: PM4:19
--
TickBase = class_quick("TickBase")

function TickBase:ctor(cate)
    self.isTicking = false;
    self.tickCate = cate or 0;
    self._fps = nil
end

function TickBase:startTick(frequence, distanceTimeMs)
    if (not frequence or frequence == 0) and (not distanceTimeMs or distanceTimeMs == 0) then
        self._fps = 60;
    else
        self._fps = frequence or math.round(1000 / distanceTimeMs)
    end
    if self.isTicking then
        self:stopTick();
    end
    tickMgr:addCustomTick(self, frequence, distanceTimeMs, self.tickCate);
    self.isTicking = true;
end

function TickBase:stopTick()
    if self.isTicking then
        tickMgr:removeTick(self);
        self.isTicking = false;
    end
end

function TickBase:getIsTicking()
    return self.isTicking
end

function TickBase:tick(dtInMs, dtInMsReal)
    print("you should implement tick function in className:" .. self.__cname .. "  " .. tostring(self));
end

function TickBase:destroy()
    if self.stopTick then
        self:stopTick();
    end
end

return TickBase