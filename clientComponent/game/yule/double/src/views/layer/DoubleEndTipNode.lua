-- double游戏 结算中提示

local DoubleEndTipNode = class("DoubleEndTipNode", cc.Node)

function DoubleEndTipNode:ctor(_node)
	tlog('DoubleEndTipNode:ctor')
	self.m_tipNode = _node:getChildByName("Image_1")
	self:setTipNodeVisible(false)
end

function DoubleEndTipNode:setTipNodeVisible(_bVisible)
	tlog("DoubleEndTipNode:setTipNodeVisible ", _bVisible)
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

function DoubleEndTipNode:playWaitAction()
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

function DoubleEndTipNode:getNodeVisible()
	return self.m_tipNode:isVisible()
end

return DoubleEndTipNode