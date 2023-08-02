--
-- Author: luo
-- Date: 2016年12月26日 20:24:43
--
local HelpLayer = class("HelpLayer", cc.Layer)
local ExternalFun = g_ExternalFun

function HelpLayer:ctor( )
	self.csbNode = ExternalFun.loadCSB("SHZ_GameHelp.csb",self)
    --self.csbNode:setPosition(display.cx,display.cy)
    appdf.getNodeByName(self.csbNode,"ListView_1"):setScrollBarEnabled(false)
	ExternalFun.openLayerAction(self)

    function callback(sender)
        ExternalFun.closeLayerAction(self,function()
			self:removeSelf()
		end)
    end
    appdf.getNodeByName(self.csbNode,"btnClose")
	:addClickEventListener(callback)
	appdf.getNodeByName(self.csbNode,"btnMask")
    :addClickEventListener(callback)
end

return HelpLayer