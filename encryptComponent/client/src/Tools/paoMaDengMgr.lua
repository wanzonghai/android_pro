--[[
    跑马灯  marquee
]]

local paoMaDengMgr = class("paoMaDengMgr")

function paoMaDengMgr:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_MARQUEE_DATA)
end


local gameNameConfig = {
    [407] = "li kui divide o peixe",   --李逵
    [520] = "o cérebro de tiangong",       --dntg

    [502] = "King of fighters",  --拳皇
    [516] = "Margem da água",  --水浒
    [525] = "Clássico 777",  --jxlw
    [527] = "Gonzo's quest",  --mlcs
    [528] = "Egito slot",  --aiji
    [529] = "Deus da Fortuna",  --CSD
    [531] = "Carnava",  --JNH
    [532] = "Donzela da Neve",  --BXNW
    [704] = "Frutas",  --水果
    [901] = "Pinko",

    [702] = "Double",
    [703] = "Crash",
    [122] = "Baccarat",
    [803] = "Truco",
}

function paoMaDengMgr:ctor()
    -- self.m_notifyTable = {}
    self.rootNode = {}
    self.defaultPos = cc.p(378,-100) --默认位置
    self.offsetPos = self.defaultPos
    self.dwQueueIndex = 0
    G_event:AddNotifyEvent(G_eventDef.EVENT_MARQUEE_DATA,handler(self,self.onMarqueeDataCallback))
end

function paoMaDengMgr:onMarqueeDataCallback(data)
    if data.wCount == 0 then return end
    self.dwQueueIndex = data.lsItems[data.wCount].dwQueueIndex
    if self.m_notifyTable == nil then
        self.m_notifyTable = {}  --首次抛弃，服务器数据池子积累历史数据。不播放
        return
    end
    self.m_notifyTable = data.lsItems

    if not self.isRunAction then
        self:initNode()
        self.rootNode.csbNode:stopAllActions()
        --执行播放动作
        self:runAction()
        self.isRunAction = true
    end
end


function paoMaDengMgr:initNode()
    if not self.rootNode.csbNode or not tolua.cast(self.rootNode.csbNode,"cc.Node") then
        local csbNode = g_ExternalFun.loadCSB("client/res/Marquee/paoMaDengNode.csb")
        local parent = uiMgr:getTopLayerInAllScene():getParent()
        parent:addChild(csbNode,10000)  --loading 层级最高，在十万

        self.rootNode.csbNode = csbNode
        g_ExternalFun.loadChildrenHandler(self.rootNode,csbNode)
        local pmdAction = g_ExternalFun.loadTimeLine("client/res/Marquee/paoMaDengNode.csb")
        pmdAction:gotoFrameAndPlay(0, true)
        self.rootNode.mm_Panel_1:runAction(pmdAction)
        self:fitDesignResolution()
        self.rootNode.mm_ListView_1:setScrollBarEnabled(false)
        -- self.rootNode.mm_ListView_1:setBounceEnabled(true)
        self.rootNode.csbNode:setVisible(false)
        self.msgClipBoxWidth = self.rootNode.mm_Panel_content:getContentSize().width
    end
end

function paoMaDengMgr:getAllItemWidth()
    local sizeTab = {}
    table.insert(sizeTab,self.rootNode.mm_Text_userName:getContentSize())
    table.insert(sizeTab,self.rootNode.mm_Text_gameName:getContentSize())
    table.insert(sizeTab,self.rootNode.mm_Text_gold:getContentSize())
    table.insert(sizeTab,self.rootNode.mm_Text_1:getContentSize())
    table.insert(sizeTab,self.rootNode.mm_Text_2:getContentSize())
    table.insert(sizeTab,self.rootNode.mm_Text_3:getContentSize())
    table.insert(sizeTab,self.rootNode.mm_Image_1:getContentSize())
    local allWidth = 0
    for k,v in pairs(sizeTab) do
        allWidth = allWidth + v.width + 10  --10 是间距
    end
    return cc.size(allWidth,sizeTab[1].height)
end

--执行播放动作
function paoMaDengMgr:runAction()
    if #self.m_notifyTable > 0 then
        self.rootNode.mm_Panel_box:show()
        self.rootNode.mm_Text_userName:setString(self.m_notifyTable[1].szNickName)
        self.rootNode.mm_Text_gameName:setString(gameNameConfig[self.m_notifyTable[1].wKindID])
        self.rootNode.mm_Text_gold:setString(g_format:formatNumber(tonumber(self.m_notifyTable[1].lScore),g_format.fType.standard,g_format.currencyType.GOLD)) 
        table.remove(self.m_notifyTable,1)
        -- ccui.Helper:doLayout(self.rootNode.mm_Panel_box)

        self.rootNode.mm_ListView_1:setContentSize(self:getAllItemWidth())
        self.rootNode.mm_ListView_1:setPosition(cc.p(0,0))
        ccui.Helper:doLayout(self.rootNode.mm_ListView_1)
        self.rootNode.csbNode:setVisible(true)

        performWithDelay(self.rootNode.csbNode,function()  
            --默认下来停顿时间，如果超框会移动，
            local stopTime = 2.5
            local TimeRate = 0.5  --滚动速率 1正常值。10非常慢
            local textWidth = self.rootNode.mm_ListView_1:getContentSize().width
            if textWidth < self.msgClipBoxWidth then
                local w = self.msgClipBoxWidth - textWidth
                self.rootNode.mm_ListView_1:setPositionX(w/2)
            else
                --超过长度滚动
                -- self.rootNode.mm_ListView_1:setPosition(cc.p(0,27.5))
                local w = textWidth - self.msgClipBoxWidth
                local zishu = textWidth/self.msgClipBoxWidth
                local fTime = zishu * TimeRate + TimeRate
                local beginStopTime = stopTime
                local endStopTime = 1
                stopTime = stopTime + fTime + endStopTime
                local action1 = cc.Sequence:create(cc.DelayTime:create(beginStopTime),cc.MoveTo:create(fTime,cc.p(-(w+100),0)))
                -- cc.DelayTime:create(endStopTime)
                self.rootNode.mm_ListView_1:runAction(action1)
            end
            
            -- local beginFunc = cc.CallFunc:create(function() self.rootNode.csbNode:show() end)
            local fi = cc.FadeIn:create(1.0)
            local detime = cc.DelayTime:create(stopTime)
            local fo = cc.FadeOut:create(1.0)
            local endFunc = cc.CallFunc:create(function() self:runAction() end)
            self.rootNode.mm_Panel_content:runAction(cc.Sequence:create(fi,detime,fo,endFunc ))
        end,0)

        -- TweenLite.to(self.rootNode.csbNode,0,{autoAlpha = 0})

        -- local onComplete = function() 
        --     self:runAction()
        -- end

        -- local tlline = TimelineLite.new();
        -- tlline:append(TweenLite.to(self.rootNode.csbNode,0.5,{autoAlpha = 1}))
        -- tlline:append(TweenLite.to(self.rootNode.csbNode,5,{}))
        -- tlline:append(TweenLite.to(self.rootNode.csbNode,0.5,{autoAlpha = 0,onComplete = onComplete}))

    else
        self.isRunAction = false
        self.rootNode.mm_Panel_box:hide()
    end
end

function paoMaDengMgr:onRequestScrollMessage()
    if not self.isRunAction then
        G_ServerMgr:C2S_RequestScrollMessageInfo(self.dwQueueIndex)
    end
end

--适配
function paoMaDengMgr:fitDesignResolution()
    if self.rootNode.csbNode and not tolua.isnull(self.rootNode.csbNode) then
        local winSize = cc.Director:getInstance():getWinSize();
        self.rootNode.pos = cc.p(winSize.width/2,winSize.height-50)
        self.rootNode.csbNode:setPosition(cc.p(self.rootNode.pos.x + self.offsetPos.x,self.rootNode.pos.y + self.offsetPos.y))
    end
end

--设置跑马灯位置，相对于顶部中间位置。
function paoMaDengMgr:setPMDOffset(pos)
    self.offsetPos = pos or self.defaultPos
    self:fitDesignResolution()
end

function paoMaDengMgr:getOffset()
    return self.offsetPos
end


return paoMaDengMgr