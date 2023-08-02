
--showToast 顶部弹出条幅

local topWidget = class("topWidget", function() return display.newNode(); end)

function topWidget:ctor()
    local parent = uiMgr:getTopLayerInAllScene():getParent()
    parent:addChild(self,10000)  --loading 层级最高，在十万
    local csbNode = g_ExternalFun.loadCSB("ToastCommon.csb",nil,false)
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    self.msgClipBoxWidth = self.mm_Panel_ClipBox:getContentSize().width
    
    self:fitDesignResolution()
end

--适配设计分辨率
function topWidget:fitDesignResolution()
    
	local winSize = cc.Director:getInstance():getWinSize();
    self:setPosition(cc.p(winSize.width/2,winSize.height))
    --显示位置
    self.showPos = cc.p(self:getPosition())
    self.rootPanelHeight = self.mm_Panel_root:getContentSize().height
    --藏入屏幕顶部上面
    self:setPositionY(self.showPos.y + self.rootPanelHeight)
    --隐藏位置
    self.hidePos = cc.p(self:getPosition())
    self:hide()
end

--复位
function topWidget:restpose()
    self:stopAllActions()
    self.mm_Text_content:stopAllActions()
    -- self:setPosition(self.hidePos)
end

function topWidget:showMsg(msg)
    print("msg = ",msg)
    self:restpose()
    self:fitDesignResolution()
    self.mm_Text_content:setString(msg)
    performWithDelay(self,function()  
        --默认下来停顿时间，如果超框会移动，
        local stopTime = 2.5
        local TimeRate = 0.5  --滚动速率 1正常值。10非常慢
        local textWidth = self.mm_Text_content:getContentSize().width
        if textWidth < self.msgClipBoxWidth then
            local w = self.msgClipBoxWidth - textWidth
            self.mm_Text_content:setPositionX(w/2)
        else
            --超过长度滚动
            self.mm_Text_content:setPosition(cc.p(0,27.5))
            local w = textWidth - self.msgClipBoxWidth
            local zishu = textWidth/self.msgClipBoxWidth
            local fTime = zishu * TimeRate + TimeRate
            local beginStopTime = stopTime
            local endStopTime = 1
            stopTime = stopTime + fTime + endStopTime
            local action1 = cc.Sequence:create(cc.DelayTime:create(beginStopTime),cc.MoveTo:create(fTime,cc.p(-w,27.5)))
            -- cc.DelayTime:create(endStopTime)
            self.mm_Text_content:runAction(action1)
        end
        
        local beginFunc = cc.CallFunc:create(function() self:show() end)
        local moveShow = cc.MoveTo:create(0.25,self.showPos)
        local detime = cc.DelayTime:create(stopTime)
        local moveHide = cc.MoveTo:create(0.25,self.hidePos)
        local endFunc = cc.CallFunc:create(function() self:hide() end)
        self:runAction(cc.Sequence:create(beginFunc,moveShow,detime, moveHide,endFunc ))
    end,0)
end

return topWidget