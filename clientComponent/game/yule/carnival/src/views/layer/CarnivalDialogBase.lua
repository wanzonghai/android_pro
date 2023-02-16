-- 弹框基类，用于实现点击框外关闭效果
local CarnivalDialogBase = class("CarnivalDialogBase", cc.Layer)

function CarnivalDialogBase:ctor(_pos, _opacity, _callBack)
    tlog('CarnivalDialogBase:ctor')
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
	self:createColorLayer(_pos, _opacity)
end

function CarnivalDialogBase:createColorLayer(_pos, _opacity)
	self:removeChildByName("ColorLayer")
	_pos = _pos or cc.p(-display.width * 0.5, -display.height * 0.5)
	_opacity = _opacity or 125

	local layer = display.newLayer(cc.c4b(0, 0, 0, _opacity))
	layer:setContentSize(display.size)
	layer:setPosition(_pos)
	layer:addTo(self)
	layer:setName("ColorLayer")
end

function CarnivalDialogBase:onExit()
	self:getEventDispatcher():removeEventListener(self.listener)
end

function CarnivalDialogBase:onEnterTransitionFinish()
	self:registerTouch()
end

function CarnivalDialogBase:removeNodeEvent()
	tlog('CarnivalDialogBase:removeNodeEvent')
	if self.m_callBack then
		self.m_callBack()
	end
    self:removeFromParent()
end

function CarnivalDialogBase:setTouchRetEnabled(_bEnable)
	self.m_touchRet = _bEnable
end

function CarnivalDialogBase:registerTouch()
	local function onTouchBegan( touch, event )
		return self.m_touchRet
	end

	local function onTouchEnded( touch, event )
		tlog('function onTouchEnded ', self.m_spBg)
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

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	self.listener = listener
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

return CarnivalDialogBase