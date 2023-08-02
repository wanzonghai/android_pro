--
-- Author: luo
-- Date: 2016年12月26日 20:24:43
--
local HelpLayer = class("HelpLayer", cc.Layer)

function HelpLayer:ctor( )
    local csbNode = g_ExternalFun.loadCSB("game/yule/watermargin/res/SHZ_Help.csb",nil,false)
    self:addChild(csbNode)
    self.curIndex = 0
    self.pageView = csbNode:getChildByName("pageview")
    self.pageView:addEventListener(function(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            self:onPageViewEvent()
        end
    end)
    csbNode:getChildByName("bntClose"):onClicked(handler(self,self.onClickClose),true)
    self.btnLeft = csbNode:getChildByName("btnLeft")
    self.btnLeft:onClicked(function() 
        self:onClickArrow(-1)
    end)
    self.btnRight = csbNode:getChildByName("btnRight")
    self.btnRight:onClicked(function() 
        self:onClickArrow(1)
    end)
    self:onEnableArrow()
end
function HelpLayer:onPageViewEvent()
    self.curIndex = self.pageView:getCurPageIndex()
    self:onEnableArrow()
end
function HelpLayer:onClickClose()
	self:removeSelf()
end
function HelpLayer:onClickArrow(index)
    self.curIndex = self.curIndex + index 
    if self.curIndex < 0 then self.curIndex = 0 end
    if self.curIndex > 3 then self.curIndex = 3 end
    self:onEnableArrow()
    self.pageView:setCurrentPageIndex(self.curIndex)
end

function HelpLayer:onEnableArrow()
	self.btnLeft:setEnabled(self.curIndex > 0)
    self.btnRight:setEnabled(self.curIndex < 3)
end

return HelpLayer