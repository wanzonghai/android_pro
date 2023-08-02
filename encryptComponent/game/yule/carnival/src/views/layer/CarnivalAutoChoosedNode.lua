-- 嘉年华 自动选择次数框

local CarnivalDialogBase = appdf.req("game.yule.carnival.src.views.layer.CarnivalDialogBase")
local CarnivalAutoChoosedNode = class("CarnivalAutoChoosedNode", CarnivalDialogBase)

local auto_nums = {10, 30, 50, 100, 101} --101代表无限

function CarnivalAutoChoosedNode:ctor(_callBack, _adaptPos)
    tlog('CarnivalAutoChoosedNode:ctor')
    CarnivalAutoChoosedNode.super.ctor(self, _adaptPos, 0)
	local csbNode = g_ExternalFun.loadCSB("UI/CarnivalAutoNode.csb", self, false)
	local imageBg = csbNode:getChildByName("Image_1")
	self.m_clickCall = _callBack

	for i = 1, 5 do
		local btnNode = imageBg:getChildByName(string.format("Button_%d", i))
		-- btnNode:setPressButtonMusicPath("")
	    -- btnNode:addTouchEventListener(handler(self, self.onButtonClickedEvent))
	    btnNode:addClickEventListener(handler(self, self.onButtonClickedEvent))
		btnNode:setTag(i)
	end
end

function CarnivalAutoChoosedNode:onButtonClickedEvent(_sender, _eventType)
	local tag = _sender:getTag()
	tlog('CarnivalAutoChoosedNode:onButtonClickedEvent ', tag)
	if self.m_clickCall then
		self.m_clickCall(auto_nums[tag])
		self:removeNodeEvent()
	end
end

return CarnivalAutoChoosedNode