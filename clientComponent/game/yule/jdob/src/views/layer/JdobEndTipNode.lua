-- jdob游戏 结算中提示

local JdobEndTipNode = class("JdobEndTipNode", cc.Node)

function JdobEndTipNode:ctor()
	tlog('JdobEndTipNode:ctor')
	local csbNode = cc.CSLoader:createNode("UI/DoubleEndTipNode_0.csb")
	csbNode:setPosition(display.width/2, display.height/2)
	csbNode:addTo(self)
	self.m_tipNode = csbNode:getChildByName("Image_1")
	self:setTipNodeVisible(false)
end

function JdobEndTipNode:setTipNodeVisible(_bVisible)
	tlog("JdobEndTipNode:setTipNodeVisible ", _bVisible)
	self.m_tipNode:setVisible(_bVisible)
	for i = 1, 3 do
		local image = self.m_tipNode:getChildByName(string.format("Image_%d", i))
		image:setVisible(false)
	end
	self.m_tipNode:stopAllActions()
	self.m_showIndex = 1
	if _bVisible then
		self:playWaitAction()
	end
end

function JdobEndTipNode:playWaitAction()
	for i = 1, 3 do
		local image = self.m_tipNode:getChildByName(string.format("Image_%d", i))
		image:setVisible(self.m_showIndex >= i)
	end
	local delayTime = 1.0
	if self.m_showIndex == 0 then
		delayTime = 0.5
	end
	self.m_showIndex = self.m_showIndex + 1
	if self.m_showIndex > 3 then
		self.m_showIndex = 0
	end
	self.m_tipNode:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function ()
		self:playWaitAction()
	end)))
end

function JdobEndTipNode:getNodeVisible()
	return self.m_tipNode:isVisible()
end

return JdobEndTipNode