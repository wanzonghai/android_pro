--
-- Author: luo
-- Date: 2016年12月30日 17:50:01
--
--设置界面


local SettingLayer = class("SettingLayer", cc.Layer)

SettingLayer.BT_EFFECT = 1
SettingLayer.BT_MUSIC = 2
SettingLayer.BT_CLOSE = 3
--构造
function SettingLayer:ctor( verstr )
    --注册触摸事件
    g_ExternalFun.registerTouchEvent(self, true)
    --加载csb资源
    self._csbNode = g_ExternalFun.loadCSB("setLayer.csb", self,false)
    self._csbNode:setZOrder(10)
    local Panel = ccui.Layout:create()
    Panel:addTo(self,-1)
    Panel:setPosition(cc.p(0,0))
    Panel:setSize(cc.size(ylAll.WIDTH,ylAll.HEIGHT))
    Panel:setTouchEnabled(true)

    local img = self._csbNode:getChildByName("MengBan_5")
    img:setAnchorPoint(0.5,0.5)
    img:setPosition(667,375)
    img:setContentSize(1624,750)

    local text_2 = self._csbNode:getChildByName("Text_2")
    text_2:setString("Configurações")

    local ann1_12_0 = self._csbNode:getChildByName("ann1_12_0")
    local ann1_12 = self._csbNode:getChildByName("ann1_12")
    local ann1_11 = self._csbNode:getChildByName("ann1_11")
    ann1_12_0:setVisible(false)
    ann1_12:setVisible(false)
    ann1_11:setVisible(false)
    local cbtlistener = function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:OnButtonClickedEvent(sender:getTag(),sender,eventType)
        end
    end 

    --关闭按钮
    local btn = self._csbNode:getChildByName("closeBtn")
        btn:setTag(SettingLayer.BT_CLOSE)
        btn:addTouchEventListener(function (ref, eventType)
            if eventType == ccui.TouchEventType.ended then
                g_ExternalFun.playClickEffect()
                self:removeFromParent()
            end
    end)
    --音效
    self.m_btnEffect = self._csbNode:getChildByName("Button_4")
    self.m_btnEffect:setTag(SettingLayer.BT_EFFECT) 
    self.m_btnEffect:addTouchEventListener(cbtlistener)
    --音乐
    self.m_btnMusic = self._csbNode:getChildByName("Button_4_0")
    self.m_btnMusic:setTag(SettingLayer.BT_MUSIC) 
    self.m_btnMusic:addTouchEventListener(cbtlistener)
      
    self:refreshBtnState()

end
-- 

function SettingLayer:OnButtonClickedEvent( tag, sender , eventType )
    if SettingLayer.BT_MUSIC == tag then
		local music = not GlobalUserItem.bVoiceAble;
		GlobalUserItem.setVoiceAble(music)
		self:refreshMusicBtnState()
		if GlobalUserItem.bVoiceAble == true then
			g_ExternalFun.playBackgroudAudio("QUANHUANG.mp3")
		end
	elseif SettingLayer.BT_EFFECT == tag then
		local effect = not GlobalUserItem.bSoundAble
		GlobalUserItem.setSoundAble(effect)
		self:refreshEffectBtnState()
	end
end
 
 
function SettingLayer:refreshBtnState(  )
	self:refreshEffectBtnState()
	self:refreshMusicBtnState()
end
--lcs按钮状态
function SettingLayer:refreshEffectBtnState(  )
	local str = nil
	if GlobalUserItem.bSoundAble then
		self.m_btnEffect:setBright(true)
	else
		self.m_btnEffect:setBright(false)
	end
end
--lcs音效状态
function SettingLayer:refreshMusicBtnState(  )
	local str = nil
	if GlobalUserItem.bVoiceAble then
		self.m_btnMusic:setBright(true)
	else
		self.m_btnMusic:setBright(false)
	end
end
 

return SettingLayer