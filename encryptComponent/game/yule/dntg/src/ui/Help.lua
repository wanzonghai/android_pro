
local HelpLayer = class("HelpLayer", function()
    return cc.LayerColor:create(cc.c4b(0,0,0,150))
end)

function HelpLayer:ctor( )
	local csb = ef.loadCSB("xyaoqianshu/Help.csb", self)
	csb:getChildByName("btn_close"):onClicked(function() --self.mgr:close(self)  
        self:setVisible(false)
    end)
    csb:setLocalZOrder(10)
	self.btns = {}
	self.views = {}

	for i = 1, 3 do
		self.btns[i] = csb:getChildByName("btn" .. i)
		self.btns[i]:addTouchEventListener(function (sender, type)
			if type == ccui.TouchEventType.ended then
				self:onBtn(sender)
			end
		end)

		self.views[i] = csb:getChildByName("ScrollView" .. i)
	end
end

function HelpLayer:onBtn(sender)
	for i = 1, 3 do
		self.btns[i]:setEnabled(self.btns[i] ~= sender)
		self.views[i]:setVisible(self.btns[i] == sender)
	end
end

return HelpLayer