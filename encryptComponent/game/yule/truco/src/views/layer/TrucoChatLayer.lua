--truco聊天界面
local TrucoChatLayer = class("TrucoChatLayer", function(args)
    local TrucoChatLayer =  display.newLayer()
    return TrucoChatLayer
end)

function TrucoChatLayer:ctor()
    tlog('TrucoChatLayer:ctor')
    --TrucoChatLayer.super.ctor(self)

    self.tabIndex = 1

    local bgLayer = display.newLayer()
    bgLayer:addTo(self)
    bgLayer:enableClick(function()
        self:removeFromParent()
    end)

	local csbNode = g_ExternalFun.loadCSB("UI/TrucoExpressionLayer.csb", self, false)
	self.m_csbNode = csbNode
	local Panel_1 = csbNode:getChildByName("Panel_1")
	self.m_spBg = Panel_1:getChildByName("sp_bg")
	self.m_spBg:enableClick()
	csbNode:setPosition(cc.p(self.m_spBg:getContentSize().width/2, self.m_spBg:getContentSize().height/2))
    self.Panel_face = Panel_1:getChildByName("Panel_face")
    self.Panel_quick = Panel_1:getChildByName("Panel_quick")

	--表情页签按钮
	local btn_face = Panel_1:getChildByName("btn_face")
	btn_face:addClickEventListener(function ()
		self:changeTabOfIndex(1)
	end)
	--快捷聊天页签按钮
	local btn_quick = Panel_1:getChildByName("btn_quick")
	btn_quick:addClickEventListener(function ()
		self:changeTabOfIndex(2)
	end)
	self:changeTabOfIndex(1)

	--普通表情(100以内)
	local Panel_normal = self.Panel_face:getChildByName("Panel_normal")
	for i=1,12 do
		local btn_normal = Panel_normal:getChildByName("btn_normal"..i)
		btn_normal:addClickEventListener(function ()
			G_GameFrame:sendBrowChat( i, GlobalUserItem.dwUserID )
			self:removeFromParent()
		end)
	end
	--魔法表情(101-200)
	local Panel_magic = self.Panel_face:getChildByName("Panel_magic")
	for i=1,12 do
		local btn_magic = Panel_magic:getChildByName("btn_magic"..i)
		btn_magic:addClickEventListener(function ()
			G_GameFrame:sendBrowChat( 100+i, GlobalUserItem.dwUserID )
			self:removeFromParent()
		end)
	end
	--快捷聊天(201-300)
	local Panel_text = self.Panel_quick:getChildByName("Panel_text")
	for i=1,9 do
		local btn_quick = Panel_text:getChildByName("btn_quick"..i)
		btn_quick:addClickEventListener(function ()
			G_GameFrame:sendBrowChat( 200+i, GlobalUserItem.dwUserID )
			self:removeFromParent()
		end)
		local btntext = btn_quick:getChildByName("Text")
		btntext:setString(g_language:getString("truco_chat"..i))
	end
end

--切换标签页
function TrucoChatLayer:changeTabOfIndex(index)
	self.tabIndex = index
	self:updateTabStatus()
end

--刷新当前标签页
function TrucoChatLayer:updateTabStatus()
	local Panel_1 = self.m_csbNode:getChildByName("Panel_1")
	local btn_face = Panel_1:getChildByName("btn_face")
	local btn_face_light = Panel_1:getChildByName("btn_face_light")
	local btn_quick = Panel_1:getChildByName("btn_quick")
	local btn_quick_light = Panel_1:getChildByName("btn_quick_light")
	btn_face:setVisible(false)
	btn_face_light:setVisible(false)
	btn_quick:setVisible(false)
	btn_quick_light:setVisible(false)
	self.Panel_face:setVisible(false)
	self.Panel_quick:setVisible(false)
	if self.tabIndex == 1 then
		btn_face_light:setVisible(true)
		btn_quick:setVisible(true)
		self.Panel_face:setVisible(true)
	else
		btn_face:setVisible(true)
		btn_quick_light:setVisible(true)
		self.Panel_quick:setVisible(true)
	end
end

return TrucoChatLayer