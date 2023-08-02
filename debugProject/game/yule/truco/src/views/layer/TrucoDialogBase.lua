-- 弹框基类，用于实现点击框外关闭效果
local TrucoDialogBase = class("TrucoDialogBase", cc.Layer)

function TrucoDialogBase:ctor(_color, _callBack)
    tlog('TrucoDialogBase:ctor')
	--注册事件
	local function onLayoutEvent( event )
		if event == "exit" then
			self:onExit()
        elseif event == "enterTransitionFinish" then
        	self:onEnterTransitionFinish()
        end
	end
	self:registerScriptHandler(onLayoutEvent)

	self.m_touchRet = true
	self.m_callBack = _callBack
	self:createColorLayer(_color)
end

function TrucoDialogBase:createColorLayer(_color)
	self:removeChildByName("ColorLayer")
	_color = _color or cc.c4b(0, 0, 0, 125)
	local layer = display.newLayer(_color)
	layer:setContentSize(display.size)
	layer:setPosition(-display.width * 0.5, -display.height * 0.5)
	layer:addTo(self)
	layer:setName("ColorLayer")
end

function TrucoDialogBase:onExit()
	self:getEventDispatcher():removeEventListener(self.listener)
end

function TrucoDialogBase:onEnterTransitionFinish()
	self:registerTouch()
end

function TrucoDialogBase:removeNodeEvent()
	tlog('TrucoDialogBase:removeNodeEvent')
	if self.m_callBack then
		self.m_callBack()
	end
    self:removeFromParent()
end

function TrucoDialogBase:setTouchEndEnabled(_bEnable)
	self.m_touchRet = _bEnable
end

function TrucoDialogBase:registerTouch()
	local function onTouchBegan( touch, event )
		return true
	end

	local function onTouchEnded( touch, event )
		tlog('function onTouchEnded ', self.m_touchRet, self.m_spBg)
		if self.m_touchRet then
			local pos = touch:getLocation()
			if self.m_spBg then
		        pos = self.m_spBg:convertToNodeSpace(pos)
		        local rec = cc.rect(0, 0, self.m_spBg:getContentSize().width, self.m_spBg:getContentSize().height)
		        if not cc.rectContainsPoint(rec, pos) then
		        	self:removeNodeEvent()
		        end
		    else
	        	self:removeNodeEvent()
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

return TrucoDialogBase