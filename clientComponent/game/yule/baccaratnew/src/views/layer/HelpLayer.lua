--
-- Author: luo
-- Date: 2016年12月30日 15:18:32
--
--设置界面


--local TransitionLayer = appdf.req(appdf.EXTERNAL_SRC .. "TransitionLayer")
local HelpLayer = class("HelpLayer", cc.Layer)

HelpLayer.RES_PATH 				= "game/yule/baccaratnew/res/"

HelpLayer.BT_EFFECT = 1
HelpLayer.BT_MUSIC = 2
HelpLayer.BT_CLOSE = 3
--构造
function HelpLayer:onExit()
	
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end
function HelpLayer:ctor(scene, param, level  )
    --注册触摸事件
    HelpLayer.super.ctor( self, scene, param, level )
    g_ExternalFun.registerTouchEvent(self, true)
    --加载csb资源
   -- self._csbNode = g_ExternalFun.loadCSB(HelpLayer.RES_PATH.."help_res/IntroduceLayer.csb", self)

      local rootLayer, csbNode = g_ExternalFun.loadRootCSB(HelpLayer.RES_PATH.."help/HelpLayer.csb", self)
    self.m_rootLayer = rootLayer
    --回调方法
    local cbtlistener = function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:OnButtonClickedEvent(sender:getTag(),sender)
        end
    end

    local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			 self:removeFromParent()
		end
	end	
	--关闭按钮
	local btn = csbNode:getChildByName("back_btn")
	btn:setTag(HelpLayer.BT_CLOSE)
	btn:addTouchEventListener(btnEvent)
    

end

--
function HelpLayer:showLayer( var )
    self:setVisible(var)
end
--按钮回调方法
function HelpLayer:OnButtonClickedEvent( tag, sender )
    
end
--触摸回调
function HelpLayer:onTouchBegan(touch, event)
    return self:isVisible()
end

function HelpLayer:onTouchEnded(touch, event)
    local pos = touch:getLocation() 
    local m_spBg = self.m_spBg
    pos = m_spBg:convertToNodeSpace(pos)
    local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
    if false == cc.rectContainsPoint(rec, pos) then
        self:setVisible(false)
    end
end

return HelpLayer