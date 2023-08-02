--[[
	游戏通用，用户踢出提示倒计时界面
]]
local TipsExit = class("TipsExit", function()
	return display.newLayer(cc.c4b(0, 0, 0, 0))    
end)

local m_default_time = 10
function TipsExit:ctor(text)
	
	if width == nil or height == nil then
		self:setContentSize(display.width,display.height)
	else
		self:setContentSize(width,height)
	end
	
	
	local function onTouch(eventType, x, y)
        return true
    end
	self:setTouchEnabled(false)
	self:registerScriptTouchHandler(onTouch)

	self.bg = cc.Sprite:create("public/tongyong_bg1.png")
	self:addChild(self.bg) 
	-- self:setPosition(appdf.WIDTH/2,appdf.HEIGHT/2)
	self:setPosition(display.width/2,display.height/2)

	--您一直未下注，即将被请出房间
	self.text = text or "Você não está participando do jogo, e será convidado a ser removido da sala"
	self.label_text = ccui.Text:create(self.text, "Arial", 42)
	self.label_text:setAnchorPoint(cc.p(0.5,0.5))
	self.label_text:setPosition(self.bg:getContentSize().width/2,self.bg:getContentSize().height/2+15)
	self.label_text:setColor(cc.c3b(255,162,0))
	self.label_text:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.label_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.label_text:setTextAreaSize(cc.size(800,160))
	self.bg:addChild(self.label_text) 

	self.time = m_default_time
	self.label_time = ccui.Text:create(string.format('%dS',self.time), "Arial", 48)
	self.label_time:setAnchorPoint(cc.p(0.5,0.5))
	self.label_time:setPosition(self.bg:getContentSize().width/2,35)
	self.label_time:setColor(cc.c3b(12,255,0))
	self.bg:addChild(self.label_time) 

	local scale1 = cc.ScaleTo:create(0.11,1.1)
	local scale2 = cc.ScaleTo:create(0.11,1)
	self.bg:runAction(cc.Sequence:create(scale1,scale2))

	local function onNodeEvent(event)
        if event == "enter" then
        elseif event == "exit" then
            if self.timerHandle ~= nil then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timerHandle)
                self.timerHandle = nil
            end
        end
    end

    self:registerScriptHandler(onNodeEvent)

	self:start(self.time)
end

function TipsExit:start(timeNum)
	self.time = timeNum or m_default_time
	self.label_time:setString(string.format('%dS',self.time))
  
	self:stop()
	self.timerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.step), 1, false)
  
  end
  
function TipsExit:step()
	self.time = self.time - 1
	self.label_time:setString(string.format('%dS',self.time))

	if self.time == 0 then
		self:stop()
	end
end

function TipsExit:stop()
	if self.timerHandle ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timerHandle)
		self.timerHandle = nil
	end
end

return TipsExit