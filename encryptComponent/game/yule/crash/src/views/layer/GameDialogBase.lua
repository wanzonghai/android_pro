-- 弹框基类，用于实现点击框外关闭效果

local GameDialogBase = class("GameDialogBase", cc.Layer)

function GameDialogBase:ctor(_pos, _opacity)
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

	if not _pos then
		_pos = cc.p(-display.width * 0.5 + g_offsetX, -display.height * 0.5)
	end

	if _opacity == nil then
		_opacity = 125
	end

	local layer = display.newLayer(cc.c4b(0, 0, 0, _opacity))
	layer:setContentSize(display.size)
	layer:setPosition(_pos)
	layer:addTo(self)
end

function GameDialogBase:onExit()
	self:getEventDispatcher():removeEventListener(self.listener)
end

function GameDialogBase:onEnterTransitionFinish()
	self:registerTouch()
end

function GameDialogBase:removeEvent()
    self:removeFromParent()
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
	            self:removeEvent()
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