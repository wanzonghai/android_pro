--
-- Author: luo
-- Date: 2016年12月26日 20:24:43
--
local HelpLayer = class("HelpLayer", function(scene)
    local layer = display.newLayer()
    return layer
end )
local ExternalFun = g_ExternalFun--require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
HelpLayer.BT_BACK = 0
HelpLayer.BT_UP = 1
HelpLayer.BT_DOWN = 2
function HelpLayer:ctor(scene)
    --注册触摸事件
    self._scene = scene
    self.m_isShow = false;
    g_ExternalFun.registerNodeEvent(self)
    local cbtlistener = function(ref, type)
        if type == ccui.TouchEventType.ended then
			self:OnButtonClickedEvent(ref:getTag(),ref)
        end
    end


    local _csbNode = ExternalFun.loadCSB("game_csb/HelpLayer.csb", self,false)

    local Panel_bg = _csbNode:getChildByName("Panel_bg")
    Panel_bg:setTag(HelpLayer.BT_BACK)
    Panel_bg:addTouchEventListener(cbtlistener)
    local sp_bg = _csbNode:getChildByName("Help_bg")
    self.m_spBg = sp_bg
    local level = self.m_spBg:getChildByName("level_2")
    if level then
        level:setVisible(false)
    end
    level = self.m_spBg:getChildByName("level_3")
    if level then
        level:setVisible(false)
    end

    local PageView = sp_bg:getChildByName("PageView")
    self.m_pPageView = PageView
    self.m_pPageView:scrollToPage(0)

    local btn = sp_bg:getChildByName("btn_back")
    btn:setTag(HelpLayer.BT_BACK)
    btn:addTouchEventListener(cbtlistener)
    btn = sp_bg:getChildByName("btn_up")
    btn:setTag(HelpLayer.BT_UP)
    btn:addTouchEventListener(cbtlistener)
    btn = sp_bg:getChildByName("btn_down")
    btn:setTag(HelpLayer.BT_DOWN)
    btn:addTouchEventListener(cbtlistener)

    self.m_cbPage = 0


    

end

function HelpLayer:OnButtonClickedEvent( tag, sender )
    print("help",tag)
    --ExternalFun.playSoundEffect("sound_click.mp3")
    if HelpLayer.BT_BACK == tag then 
        self:onShowLayer(false)
    elseif HelpLayer.BT_UP == tag then 
        local idx = self.m_pPageView:getCurrentPageIndex()
        if idx>0 then
            idx = idx - 1
        end
        print(idx)
        self.m_pPageView:scrollToPage(idx)
    elseif HelpLayer.BT_DOWN == tag  then 
        local idx = self.m_pPageView:getCurrentPageIndex()
        if idx<2 then
            idx = idx + 1       
        end
        print(idx)
        self.m_pPageView:scrollToPage(idx)
    end
end

function HelpLayer:onShowLayer(bVisible)
    if self.m_isShow == bVisible then
        return 
    end
    if bVisible then
        self:setVisible(bVisible)
        self:setOpacity(100)
        self.m_spBg:setScaleY(0.7)
        self.m_spBg:runAction(cc.ScaleTo:create(0.1, 1))
        self:Update()
    else
        self.m_spBg:runAction(
            cc.Sequence:create(
            cc.ScaleTo:create(0.1, 1.0,0.7),
            cc.CallFunc:create( function()
                self:setVisible(bVisible)
            end )))
        self:runAction(cc.FadeOut:create(0.1))
        self:unUpdate()
    end
    self.m_isShow = bVisible;
end

function HelpLayer:onExit()
    self:unUpdate()
end

function HelpLayer:unUpdate()
    if nil ~= self.m_scheduleUpdate then
        scheduler:unscheduleScriptEntry(self.m_scheduleUpdate)
        self.m_scheduleUpdate = nil
    end
end

function HelpLayer:Update()
    local function update(dt)
        local idx = self.m_pPageView:getCurrentPageIndex()
        if idx~= self.m_cbPage then 
            self.m_cbPage = idx

            for i=1,3 do 
                local level = self.m_spBg:getChildByName("level_"..i)
                if level then 
                    level:setVisible(i==idx+1) 
                end
            end
        end
    end
    if nil == self.m_scheduleUpdate then
        self.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0.01, false)
    end
end

return HelpLayer