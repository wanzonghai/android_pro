-- 弹框基类，用于实现点击框外关闭效果

local GameDialogBase = class("GameDialogBase", cc.Layer)

function GameDialogBase:ctor()
    tlog('GameDialogBase:ctor')
	--注册事件
	local function onLayoutEvent( event )
		if event == "exit" then
			self:onExit()
        elseif event == "enterTransitionFinish" then
        	self:onEnterTransitionFinish()
        end
	end
	self:registerScriptHandler(onLayoutEvent)
	local layer = display.newLayer(cc.c4b(0, 0, 0, 216))
	layer:setContentSize(display.size)
	layer:setPosition(-display.width * 0.5, -display.height * 0.5)
	layer:addTo(self)
end

function GameDialogBase:onExit()
	self:getEventDispatcher():removeEventListener(self.listener)
end

function GameDialogBase:onEnterTransitionFinish()
	self:registerTouch()
end

function GameDialogBase:registerTouch()
	local function onTouchBegan( touch, event )
		return true
	end

	local function onTouchEnded( touch, event )
		tlog('function onTouchEnded ', self.m_spBg)
		local pos = touch:getLocation()
		if self.m_spBg then
	        pos = self.m_spBg:convertToNodeSpace(pos)
	        local rec = cc.rect(0, 0, self.m_spBg:getContentSize().width, self.m_spBg:getContentSize().height)
	        if not cc.rectContainsPoint(rec, pos) then
	            self:removeFromParent()
	        end
	    end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	self.listener = listener
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

return GameDialogBase