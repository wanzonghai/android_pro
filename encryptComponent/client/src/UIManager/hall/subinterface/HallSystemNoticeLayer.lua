--[[
    系统通知页面
]]
local HallSystemNoticeLayer = class("HallSystemNoticeLayer", ccui.Layout)

function HallSystemNoticeLayer:ctor(args)
    self.m_totalTime = args.cmdData.strInfo[1].totalTime or 10
    self.m_showNextNotice = args.NoticeNext
    local parent = cc.Director:getInstance():getRunningScene()
    parent:addChild(self, 9999)
    local csbNode = g_ExternalFun.loadCSB("systemNotice/SystemNoticeLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self, csbNode)

    local actTimeLine = cc.CSLoader:createTimeline("systemNotice/SystemNoticeLayer.csb")
    actTimeLine:gotoFrameAndPlay(0, false)
    csbNode:runAction(actTimeLine)

    local jsonFile = "systemNotice/wenxintishi.json"
    local atlasFile = "systemNotice/wenxintishi.atlas"
    local animateAct = sp.SkeletonAnimation:create(jsonFile, atlasFile, 1)
    animateAct:addTo(self.mm_Node_spine)
    animateAct:setAnimation(0, "ruchang", false)
    animateAct:setPosition(0, 0)
    animateAct:registerSpineEventHandler( function( event )
        if event.animation == "ruchang" then
            animateAct:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    self.mm_Text_title:setString(args.cmdData.strInfo[1].title or "Dicas Gentis")
    self.mm_bg:setContentSize(cc.size(display.width, display.height))
    self.mm_bg:addClickEventListener(function()
        self:onCloseEvent()
    end)
    self.mm_Button_get:setVisible(false)
    self.mm_Button_get:onClicked(function ()
        self:onCloseEvent()
    end)
    self.mm_Image_1:setVisible(true)
    self:updateContentShow(args.cmdData.strInfo[1].content)
    self:updateTimeShow()
end

function HallSystemNoticeLayer:updateContentShow(_strContent)
    tlog('HallSystemNoticeLayer:updateContentShow')
    local text = cc.Label:createWithTTF(_strContent, "base/res/fonts/arial.ttf", 32)
    text:setColor(cc.c3b(125, 64, 23))
    text:setLineHeight(40)
    text:setMaxLineWidth(900)
    text:setAnchorPoint(cc.p(0, 1))
    local sizeHeight = text:getContentSize().height + 10
    text:addTo(self.mm_ScrollView_1)
    local scrollSize = self.mm_ScrollView_1:getContentSize()
    local finialHeight = math.max(sizeHeight, scrollSize.height)
    self.mm_ScrollView_1:setInnerContainerSize(cc.size(scrollSize.width, finialHeight))
    text:setPosition(15, finialHeight - 10)
    self.mm_ScrollView_1:setScrollBarEnabled(false)
end

function HallSystemNoticeLayer:updateTimeShow()
    tlog('HallSystemNoticeLayer:updateTimeShow ', self.m_totalTime)
    local curTimes = self.m_totalTime
    if curTimes < 0 then
        curTimes = 0
    end
    self.mm_Text_1:setString(string.format("%ds", curTimes))
    self.m_totalTime = self.m_totalTime - 1
    if self.m_totalTime >= 0 then
        self.mm_Text_1:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function ()
            self:updateTimeShow()
        end)))
    else
        self.mm_Button_get:setVisible(true)
        self.mm_Image_1:setVisible(false)
    end
end

function HallSystemNoticeLayer:onCloseEvent()
    if self.m_totalTime < 0 then
        DoHideCommonLayerAction(self.mm_bg, self.mm_content, function()            
            if self.m_showNextNotice then
                G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="HallSystemNotice"})
            end            
            self:removeFromParent() 
        end)
    end
end

return HallSystemNoticeLayer