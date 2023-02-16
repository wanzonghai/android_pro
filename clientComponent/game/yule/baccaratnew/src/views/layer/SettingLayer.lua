--
-- Author: zhong
-- Date: 2016-07-08 17:16:26
--
--设置界面


local SettingLayer = class("SettingLayer", cc.Layer)

SettingLayer.BT_EFFECT = 1
SettingLayer.BT_MUSIC = 2
SettingLayer.BT_CLOSE = 3
--构造
function SettingLayer:ctor( parent )
	self.m_parent = parent
	--加载csb资源
	local csbNode = g_ExternalFun.loadCSB("setting/SettingLayer.csb", self)

	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onBtnClick(sender:getTag(), sender)
		end
	end
	local sp_bg = csbNode:getChildByName("setting_bg")

	--关闭按钮
	local btn = sp_bg:getChildByName("close_btn")
	btn:setTag(SettingLayer.BT_CLOSE)
	btn:addTouchEventListener(btnEvent)

	--switch
    --音效
    self.m_btnEffect = sp_bg:getChildByName("effect_btn")
    self.m_btnEffect:setTag(SettingLayer.BT_EFFECT)
    self.m_btnEffect:addTouchEventListener(btnEvent)
    --音乐
    self.m_btnMusic = sp_bg:getChildByName("music_btn")
    self.m_btnMusic:setTag(SettingLayer.BT_MUSIC)
    self.m_btnMusic:addTouchEventListener(btnEvent)

	self:refreshBtnState()

	-- 版本号
    local mgr = self.m_parent:getParentNode():getParentNode():getApp():getVersionMgr()
    local verstr = mgr:getResVersion(122) or "0"
    verstr = "Versão do jogo:" .. appdf.BASE_C_VERSION .. "." .. verstr
    local txt_ver = sp_bg:getChildByName("txt_ver")
    txt_ver:setString(verstr)
end

--
function SettingLayer:showLayer( var )
	self:setVisible(var)
end

function SettingLayer:onBtnClick( tag, sender )
	if SettingLayer.BT_CLOSE == tag then
		g_ExternalFun.playClickEffect()
		self:removeFromParent()
	elseif SettingLayer.BT_MUSIC == tag then
		local music = not GlobalUserItem.bVoiceAble;
		GlobalUserItem.setVoiceAble(music)
		self:refreshMusicBtnState()
		if GlobalUserItem.bVoiceAble == true then
			g_ExternalFun.playBackgroudAudio("BACK_GROUND.mp3")
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

function SettingLayer:refreshEffectBtnState(  )
	local str = nil
	if GlobalUserItem.bSoundAble then
		str = "ui/common/bt_set_open.png"
	else
		str = "ui/common/bt_set_close.png"
	end

	if nil ~= str then
		self.m_btnEffect:loadTextureDisabled(str)
		self.m_btnEffect:loadTextureNormal(str)
		self.m_btnEffect:loadTexturePressed(str)
	end
end

function SettingLayer:refreshMusicBtnState(  )
	local str = nil
	if GlobalUserItem.bVoiceAble then
		str = "ui/common/bt_set_open.png"
	else
		str = "ui/common/bt_set_close.png"
	end
	if nil ~= str then
		self.m_btnMusic:loadTextureDisabled(str)
		self.m_btnMusic:loadTextureNormal(str)
		self.m_btnMusic:loadTexturePressed(str)
	end
end

return SettingLayer