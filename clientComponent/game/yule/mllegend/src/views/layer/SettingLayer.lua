--
-- Author: luo
-- Date: 2016年12月30日 17:50:01
--
--设置界面
local ExternalFun = g_ExternalFun--require(appdf.EXTERNAL_SRC .. "ExternalFun")

local SettingLayer = class("SettingLayer", function(scene)
    local layer = display.newLayer()
    return layer
end )

SettingLayer.BT_SOUND = 1
SettingLayer.BT_MUSIC = 2
SettingLayer.BT_BACK = 3

--构造
function SettingLayer:ctor(scene)
   
    --加载csb资源
    self._scene = scene;
    self.m_isShow = false;

    local _csbNode = ExternalFun.loadCSB("game_csb/SettingLayer.csb", self)

    local  cbtlistener = function(ref, type)
        if type == ccui.TouchEventType.ended then
			self:OnButtonClickedEvent(ref:getTag(),ref)
        end
    end
    local Panel_bg = _csbNode:getChildByName("Panel_bg")
    Panel_bg:setTag(SettingLayer.BT_BACK)
    Panel_bg:addTouchEventListener(cbtlistener)
    local sp_bg = _csbNode:getChildByName("Set_bg")
    sp_bg:setTag(SettingLayer.BT_BACK)
    sp_bg:addTouchEventListener(cbtlistener)
    self.m_spBg = sp_bg
    --关闭按钮
    local btn = sp_bg:getChildByName("btn_back")
    btn:setTag(SettingLayer.BT_BACK)
    btn:addTouchEventListener(cbtlistener)
    --音效
    btn = sp_bg:getChildByName("btn_effect")
    btn:setTag(SettingLayer.BT_SOUND)
    btn:addTouchEventListener(cbtlistener)
    --音乐
    btn = sp_bg:getChildByName("btn_music")
    btn:setTag(SettingLayer.BT_MUSIC)
    btn:addTouchEventListener(cbtlistener)
    local nicknode = sp_bg:getChildByName("txt_nickname")
    local nickname = cc.Label:create()
    nickname:setAnchorPoint(0,0.5)
    nickname:setString(self._scene:GetMeUserItem().szNickName)
    nickname:setSystemFontSize(30)
    nickname:addTo(nicknode)

    self.m_pMusicTag = sp_bg:getChildByName("music")
    self.m_pMusicTag:setVisible(GlobalUserItem.bVoiceAble)
    
    self.m_pEffcctTag = sp_bg:getChildByName("effect")
    self.m_pEffcctTag:setVisible(GlobalUserItem.bSoundAble)

end
--
function SettingLayer:onShowLayer(bVisible)
    if self.m_isShow == bVisible then
        return 
    end

    if bVisible then
        self:setVisible(bVisible)
        self:setOpacity(255)
        self.m_spBg:setScaleY(0.7)        
        self.m_spBg:runAction(cc.ScaleTo:create(0.1,1))
    else 
        self.m_spBg:runAction(
            cc.Sequence:create(
            cc.ScaleTo:create(0.1,1.0,0.7),
            cc.CallFunc:create(function()
                   self:setVisible(bVisible)
                end)))
        self:runAction(cc.FadeOut:create(0.1))
    end
 
    self.m_isShow = bVisible
end

function SettingLayer:OnButtonClickedEvent( tag, sender )
    print("set",tag)    
    if SettingLayer.BT_MUSIC == tag then
        local music = not GlobalUserItem.bVoiceAble
        GlobalUserItem.setVoiceAble(music)
        self.m_pMusicTag:setVisible(GlobalUserItem.bVoiceAble)
        if GlobalUserItem.bVoiceAble  then 
            AudioEngine.resumeMusic()
            ExternalFun.playBackgroudAudio("bg.mp3")                 
        else
            AudioEngine.pauseMusic()        
        end
    elseif SettingLayer.BT_SOUND == tag then
        local effect = not GlobalUserItem.bSoundAble
        GlobalUserItem.setSoundAble(effect)
        self.m_pEffcctTag:setVisible(GlobalUserItem.bSoundAble)
    elseif SettingLayer.BT_BACK == tag then 
        self:onShowLayer(false)
    end
end

return SettingLayer