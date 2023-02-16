--[[
***
***
]]
local HallSetLayer = class("HallSetLayer",function(args)
		local HallSetLayer =  display.newLayer()
    return HallSetLayer
end)

function HallSetLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    
    local csbNode = g_ExternalFun.loadCSB("set/SetLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)

    ShowCommonLayerAction(self.mm_bg,self.mm_content)

    --背景
    self.SpineBg = sp.SkeletonAnimation:create("set/gerenxinxi2.json","set/gerenxinxi2.atlas", 1)
    self.SpineBg:addTo(self.mm_Node_spine)
    self.SpineBg:setPosition(0, 0)
    self.SpineBg:setAnimation(0, "ruchang", false)        
    self.SpineBg:registerSpineEventHandler( function( event )
        if event.animation == "ruchang" then
            self.SpineBg:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)  

    self.SpineBg2 = sp.SkeletonAnimation:create("set/gerenxinxi1.json","set/gerenxinxi1.atlas", 1)
    self.SpineBg2:addTo(self.mm_Node_spine)
    self.SpineBg2:setPosition(0, 0)
    self.SpineBg2:setAnimation(0, "ruchang", false)        
    self.SpineBg2:registerSpineEventHandler( function( event )
        if event.animation == "ruchang" then
            self.SpineBg2:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)  

    --动效
    local pEffectCsb = "set/SetLayer.csb"    
    local pEffect = g_ExternalFun.loadTimeLine(pEffectCsb)
    pEffect:gotoFrameAndPlay(0, false)
    self.mm_content:runAction(pEffect)

    self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)
    self.mm_imgHead:setContentSize(cc.size(226,226))
    HeadSprite.loadHeadImg(self.mm_imgHead,GlobalUserItem.dwGameID,GlobalUserItem.wFaceID,true)
    self.mm_txtName:setString(g_ExternalFun.RejectChinese(GlobalUserItem.szNickName))    
    self.mm_txtID:setString("ID:"..GlobalUserItem.dwGameID)
    self.mm_btnCopy:onClicked(handler(self,self.onCopyID))
    self.mm_btnSwitch:onClicked(handler(self,self.onSwitchAccount))    
    self.mm_btnMusic:onClickEnd(function() self:onClickVoice(1) end,"click")
    self.mm_btnSound:onClickEnd(function() self:onClickVoice(2) end,"click")

    if GlobalUserItem.szSeatPhone and  string.len(GlobalUserItem.szSeatPhone) > 0 then
        self.mm_btnGo:setEnabled(false)
    else
        self.mm_btnGo:setEnabled(true)
    end 
    self.mm_btnGo:onClicked(handler(self,self.onAuthClick))
    self:onHandlerUI()
end
function HallSetLayer:onClickClose()
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() self:removeSelf() end)
end
--处理
function HallSetLayer:onHandlerUI(index)
    local bVoice = GlobalUserItem.bVoiceAble
    bVoice = bVoice and 1 or 0
    local bSound = GlobalUserItem.bSoundAble
    bSound = bSound and 1 or 0
    local posX = {[0]=90,248}
    local callVoice = function(_type)        
        local imgMusic = self.mm_btnMusic:getChildByName("imgIcon")        
        imgMusic:setPositionX(posX[_type])
    end
    local callSound = function(_type)        
        local imgSound = self.mm_btnSound:getChildByName("imgIcon") 
        imgSound:setPositionX(posX[_type])
    end
    if index == nil then  --全部
        callVoice(bVoice)
        callSound(bSound)
    end 
    if index == 1 then  --音乐
        callVoice(bVoice)
    end 
    if index == 2 then  --音效
       callSound(bSound)
    end 
end

--拷贝ID
function HallSetLayer:onCopyID()
    local res, msg = g_MultiPlatform:getInstance():copyToClipboard(tostring(GlobalUserItem.dwGameID))
    if res == true then
        showToast(g_language:getString("copy_success"))  
    end
end

--切换账号
function HallSetLayer:onSwitchAccount()
     DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() 
         self:removeSelf() 
         G_event:NotifyEvent(G_eventDef.UI_SWITCH_ACCOUNT)
     end)
end

--声音处理
function HallSetLayer:onClickVoice(index)
    if index == 1 then    --音乐 
 		 GlobalUserItem.setVoiceAble(not GlobalUserItem.bVoiceAble)
         g_ExternalFun.playPlazzBackgroudAudio()  
    end
    if index == 2 then    --音效
        GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble) 
    end
    self:onHandlerUI(index)
end

--点击验证
function HallSetLayer:onAuthClick()
    self:removeSelf() 
    G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_AUTH)
end

return HallSetLayer