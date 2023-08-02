--
-- Author: luo
-- Date: 2016年12月26日 20:24:43
--
local GameRule = class("GameRule", cc.Layer)
local ExternalFun = g_ExternalFun

function GameRule:ctor( )
	self.csbNode = ExternalFun.loadCSB("EGLB_GameRule.csb",self,true)
    self.csbNode:setPosition(0,0)
    -- self.csbNode:getChildByName("btnMask"):setScale(g_offsetX)

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

    self.panel_1 = self.csbNode:getChildByName("panel_1"):setVisible(false)
    self.panel_2 = self.csbNode:getChildByName("panel_2"):setVisible(false)

    --按钮回调方法
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onClickTypeCallback(sender:getTag(), sender)
        end
    end

    self.btn_type1 = self.csbNode:getChildByName("btn_type1")
    self.btn_type1:setEnabled(false)
    self.btn_type1:setTag(1)
    self.btn_type1:addTouchEventListener(btnEvent)
    self.btn_type2 = self.csbNode:getChildByName("btn_type2")
    self.btn_type2:setEnabled(true)
    self.btn_type2:setTag(2)
    self.btn_type2:addTouchEventListener(btnEvent)
    self:refreshPanel(true)
end

function GameRule:onClickTypeCallback(tag,ref)
    if tag == 1 then
        ExternalFun.playClickEffect()
        self:refreshPanel(true)
        self.btn_type1:setEnabled(false)
        self.btn_type2:setEnabled(true)
    elseif tag == 2 then
        ExternalFun.playClickEffect()
        self:refreshPanel(false)
        self.btn_type1:setEnabled(true)
        self.btn_type2:setEnabled(false)   
    end
end

function GameRule:refreshPanel(panelT)
    self.panel_1:setVisible(panelT)
    self.panel_2:setVisible(not panelT)
end

return GameRule