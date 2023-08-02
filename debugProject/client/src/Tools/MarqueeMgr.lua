--[[
    跑马灯  MarqueeMgr
]]

local MarqueeMgr = class("MarqueeMgr")

function MarqueeMgr:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_MARQUEE_DATA)
end

local gameNameConfig = {
    [407] = "li kui divide o peixe",        --李逵
    [520] = "o cérebro de tiangong",        --dntg
    [502] = "King of fighters",             --拳皇
    [516] = "Margem da água",               --水浒
    [525] = "Clássico 777",                 --jxlw
    [527] = "Gonzo's quest",                --mlcs
    [528] = "Egito slot",                   --aiji
    [529] = "Deus da Fortuna",              --CSD
    [531] = "Carnava",                      --JNH
    [532] = "Donzela da Neve",              --BXNW
    [704] = "Sweet Bonanza",                --TMFK
    [901] = "Plinko",
    [702] = "Double",
    [703] = "Crash",
    [122] = "Baccarat",
    [803] = "Truco",
    [602] = "Bicho",
    [903] = "Mini Roulette",
}

function MarqueeMgr:ctor()    
    self.rootNode = {}
    self.defaultPos = cc.p(display.right,display.top*5/6-20) --默认位置    
    self.defaultScale = 1
    self.dwQueueIndex = 0
    G_event:AddNotifyEvent(G_eventDef.EVENT_MARQUEE_DATA,handler(self,self.onMarqueeDataCallback))
end

function MarqueeMgr:onMarqueeDataCallback(data)
    if data.wCount == 0 then return end
    self.dwQueueIndex = data.lsItems[data.wCount].dwQueueIndex
    if self.m_notifyTable == nil then
        self.m_notifyTable = {}  --首次抛弃，服务器数据池子积累历史数据。不播放
        return
    end
    self.m_notifyTable = data.lsItems

    if not self.isRunAction then
        self:initNode()
        --执行播放动作
        self:runAction()
        self.isRunAction = true
    end
end


function MarqueeMgr:initNode()
    if not self.rootNode.csbNode or not tolua.cast(self.rootNode.csbNode,"cc.Node") then
        local csbNode = g_ExternalFun.loadCSB("client/res/Marquee/MarqueeNode.csb")
        local parent = uiMgr:getTopLayerInAllScene():getParent()
        parent:addChild(csbNode,ZORDER.MARQUEE)  --loading 层级最高，在十万        
        csbNode:setPosition(self.defaultPos)
        self.rootNode.csbNode = csbNode                
        g_ExternalFun.loadChildrenHandler(self.rootNode,csbNode)
        --背景
        self.SpineBg = sp.SkeletonAnimation:create("Marquee/paomadeng_2.json","Marquee/paomadeng_2.atlas", 1)
        self.SpineBg:addTo(self.rootNode.mm_spine_1)
        self.SpineBg:setPosition(0, 0)
        --光
        self.SpineLight = sp.SkeletonAnimation:create("Marquee/paomadeng_1.json", "Marquee/paomadeng_1.atlas", 1)
        self.SpineLight:addTo(self.rootNode.mm_spine_2)
        self.SpineLight:setPosition(0, 0)
        --内容
        self.ActionDetail = g_ExternalFun.loadTimeLine("client/res/Marquee/MarqueeNode.csb")
        self.ActionDetail:retain()
        self.ActionDetail:play("ruchang",false)
        self.rootNode.mm_detail:runAction(self.ActionDetail)

        --金币和TC币 项目区分
        if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
            self.rootNode.mm_coin = self.rootNode.mm_ImageCoin
        else
            self.rootNode.mm_coin = self.rootNode.mm_ImageTC
        end
    end
end

--执行播放动作
function MarqueeMgr:runAction()
    if #self.m_notifyTable > 0 then
        self.rootNode.csbNode:show()        
        self.rootNode.csbNode:setScale(self.ScaleFlag and 0.7*self.defaultScale or 1*self.defaultScale)        
        self.rootNode.mm_nickname:setString(self.m_notifyTable[1].szNickName)
        self.rootNode.mm_gamekind:setString(gameNameConfig[self.m_notifyTable[1].wKindID])
        self.rootNode.mm_coin:show()
        local pStr = ""
        if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
            pStr = g_format:formatNumber(tonumber(self.m_notifyTable[1].lScore),g_format.fType.standard,g_format.currencyType.GOLD)
        else
            pStr = g_format:formatNumber(tonumber(self.m_notifyTable[1].lScore),g_format.fType.standard,g_format.currencyType.TC)
        end
        self.rootNode.mm_score:setString(pStr)         

        local pWidth = self.rootNode.mm_gamekind:getContentSize().width + 10
        self.rootNode.mm_coin:setPositionX(pWidth)
        pWidth = pWidth + self.rootNode.mm_coin:getContentSize().width*0.85 + 2
        self.rootNode.mm_score:setPositionX(pWidth)
        pWidth = pWidth + self.rootNode.mm_score:getContentSize().width + 10
        local pRemainWidth = (810-pWidth)
        pRemainWidth = self.ScaleFlag and 0.7*pRemainWidth or pRemainWidth
        local px = math.max(display.right,display.right+pRemainWidth)
        self.rootNode.csbNode:setPositionX(px)
        table.remove(self.m_notifyTable,1)

        self.SpineBg:show()
        self.SpineBg:setAnimation(0, "ruchang", false)        
        self.SpineBg:registerSpineEventHandler( function( event )
            if event.animation == "ruchang" then
                self.SpineBg:setAnimation(0, "daiji", true)
            end
        end, sp.EventType.ANIMATION_COMPLETE)

        self.SpineLight:show()
        self.SpineLight:setAnimation(0, "ruchang", true)        
        self.SpineLight:registerSpineEventHandler( function( event )
            if event.animation == "ruchang" then
                self.SpineLight:setAnimation(0, "daiji", true)
            end
        end, sp.EventType.ANIMATION_COMPLETE)
        
        self.ActionDetail:play("ruchang",false)
        
        performWithDelay(self.rootNode.csbNode,function()             
            local pMove = cc.MoveTo:create(0.2,cc.p(display.right+1200,display.top*5/6-20))
            local pDelay = cc.DelayTime:create(3)
            local pCall = cc.CallFunc:create(function()
                -- self.rootNode.mm_nickname:setString("")
                -- self.rootNode.mm_gamekind:setString("")
                -- self.rootNode.mm_score:setString("")
                self.rootNode.mm_coin:hide()
                self:runAction()
            end)
            self.rootNode.csbNode:runAction(cc.Sequence:create(pMove,pDelay,pCall))
        end,3)
    else
        self.isRunAction = false
        self.rootNode.csbNode:hide() 
        self.SpineBg:hide()
        self.SpineLight:hide()
    end
end

--立即结束当前跑马灯
function MarqueeMgr:fitDesignResolution(flag)  
    self.ScaleFlag = flag
    if self.rootNode.csbNode and not tolua.isnull(self.rootNode.csbNode) then
        self.rootNode.csbNode:hide()   
        self.SpineBg:hide()
        self.SpineLight:hide()
        self.rootNode.csbNode:setPositionY(display.top*5/6-20)
        self.rootNode.csbNode:setScale(flag and 0.7*self.defaultScale or 1*self.defaultScale)
    end
end

function MarqueeMgr:onRequestScrollMessage()
    if not self.isRunAction then
        G_ServerMgr:C2S_RequestScrollMessageInfo(self.dwQueueIndex)
    end
end

return MarqueeMgr