local M = class('Profiler')

function M:ctor()
	self.stack = {}
	self.hash = {}
end

function M:push(name)
    local now = currentTime()

    local t = self.hash[name]
    if not t then
    	t = {}
    	t.total = 0
    	self.hash[name] = t
    end
	t.time = now
	t.name = name
	table.insert(self.stack, t)
end

function M:pop()
    local now = currentTime()

    local t = table.remove(self.stack, #self.stack)

    t.total = t.total + (now - t.time)
end

function M:print()
	for k, v in pairs(self.hash) do
		print(k, v.total)
	end
end

function M:clear()
	self.stack = {}
	self.hash = {}
end

return M