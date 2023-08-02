
local M = class("SettingLayer", function()
    return cc.LayerColor:create(cc.c4b(0,0,0,150))
end)
function M:ctor(scene)
    local close = function () self:setVisible(false) end

    self:setTouchEnabled(true)  
    --self:onClicked(close)
    
    local setNode = ef.loadCSB("xyaoqianshu/Set.csb"):addTo(self)
    
    setNode:getChildByName("btn_close"):onClickEnd(close)

    local on = "xyaoqianshu/shezhi/on.png"
    local off = "xyaoqianshu/shezhi/off.png"
    
    --音效按钮
    setNode:getChildByName("btn_sound"):asSwitch(GlobalUserItem.bSoundAble, on, off, GlobalUserItem.setSoundAble)
    --音乐按钮
    setNode:getChildByName("btn_music"):asSwitch(GlobalUserItem.bVoiceAble, on, off, function(able)
       GlobalUserItem.setVoiceAble(able)
       if GlobalUserItem.bVoiceAble==true then
          AudioEngine.playMusic("sound_res/buyuBgMusic1.mp3",true)
       end
    end)

end

return M