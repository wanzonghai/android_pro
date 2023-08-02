
local eventMgr = class("eventMgr")

function eventMgr:ctor()
    self.event_notify_list = {}
    self.event_notify_list_two = {}
end
--添加事件监听
function eventMgr:AddNotifyEvent(id,notify,args)
	local event = {}
	event.id = id
	event.notify = notify
	event.args = args        
	self.event_notify_list[id] = event
end

--事件通知,args 尽量以表传递
function eventMgr:NotifyEvent(id,args)
	local event = self.event_notify_list[id]
	if nil == event then
        -- printInfo("event_id ( "..id .. " ) not exist")
		return
	end
	local event_notify = event.notify
	if event_notify ~= nil then
		event_notify(args)
	end
end
--移除事件监听
function eventMgr:RemoveNotifyEvent(id)
    if self.event_notify_list and self.event_notify_list[id] then
        self.event_notify_list[id] = nil
    end
end
--接收node参数，可使用同个id
function eventMgr:AddNotifyEventTwo(node,id,notify,args)
	local event = {}
    event.node = node
	event.id = id
	event.notify = notify
	event.args = args       
    self.event_notify_list_two[id] = self.event_notify_list_two[id] or {}
	table.insert(self.event_notify_list_two[id],event)
end
function eventMgr:NotifyEventTwo(id,args)
	local event = self.event_notify_list_two[id]
	if nil == event then
        -- printInfo("event_id ( "..id .. " ) not exist")
		return
	end
    for i,v in pairs(self.event_notify_list_two[id]) do
	    local event_notify = v.notify
	    if tolua.cast(v.node,"cc.Node") and event_notify ~= nil then
	    	event_notify(args)
	    end        
    end
end
function eventMgr:RemoveNotifyEventTwo(node,id)
    if self.event_notify_list_two[id] == nil then
        -- printInfo("event_id ( "..id .. " ) not exist")
		return
    end
    for i,v in pairs(self.event_notify_list_two[id]) do
        if v.node == node then
            table.remove(self.event_notify_list_two[id],i)
            break
        end
    end
end
function eventMgr:RemoveNotifyEventTwoAll(id)
    if self.event_notify_list_two[id] == nil then
        -- printInfo("event_id ( "..id .. " ) not exist")
    end
    self.event_notify_list_two[id] = nil
end
return eventMgr

