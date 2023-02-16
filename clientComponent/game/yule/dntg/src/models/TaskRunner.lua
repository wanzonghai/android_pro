local M = class('TaskRunner', cc.Node)

function M:ctor()
	self.tasks = {}
end

function M:start()

	local n = #self.tasks

	if self.progress_cb then
		self.progress_cb(0)
	end

	self:onUpdate(function(dt)

		if not self.cur then
			if #self.tasks <= 0 then return end

			self.cur = table.remove(self.tasks, 1) 

			if self.cur.start then
				self.cur.start()


			end
		else
			if self.cur.update(dt) then
				self.cur = nil
				if self.progress_cb then
					self.progress_cb((1-#self.tasks / n) * 100)
				end
			end
		end
	end)
end

function M:stop()
	self:unscheduleUpdate()
end

function M:addImage(image)

	local ready = false

	self:add({
		start = function()
		 	local cache = cc.Director:getInstance():getTextureCache()
    		cache:addImageAsync(image, function() ready = true end)
    	end,

		update = function()
			return ready	
		end,	
	})
end

function M:addAnimation(anima)
    self:add({
		update = function() 
			func()
			return true
		end
    })
end

function M:addFunc(func)
	self:add({
		update = function() 
			func()
			return true
		end
	})
end

function M:addDelay(delay)

	self:add({
		update = function(dt)
			delay = delay - dt		
			return delay <= 0
		end	
	})
end

function M:add(task)
	table.insert(self.tasks, task)
end

return M