local MsgTimeMgr = class("MsgTimeMgr")

local scheduler = cc.Director:getInstance():getScheduler()

local isStart = false

local _coolTime = 180

function MsgTimeMgr:startScheduler()
    if self.schedulerID == nil then
        self.schedulerID = scheduler:scheduleScriptFunc(handler(self, self.onUpdate), 1, false)
    end
end

function MsgTimeMgr:closeScheduler()
    if self.schedulerID then
        scheduler:unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end
end

function MsgTimeMgr:onUpdate(dt)
    --print("定时器", dt)
    if isStart then
        _coolTime = _coolTime - dt
        if _coolTime <= 0 then
            _coolTime = 180
            isStart = false
            self:closeScheduler()
        end
        G_event:NotifyEvent(G_eventDef.UPDATE_MSG_TIME, _coolTime)
    end
end

function MsgTimeMgr:setStart(boo)
    isStart = boo
end

function MsgTimeMgr:getStart()
    return isStart
end

function MsgTimeMgr:setRemainTime(pTime)
    _coolTime = pTime
end

return MsgTimeMgr
