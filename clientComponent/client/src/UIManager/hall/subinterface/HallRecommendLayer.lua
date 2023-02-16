---------------------------------------------------
--Desc:游戏推荐界面
--Date:2022-09-17 10:28:47
--Author:A*
---------------------------------------------------
local HallRecommendLayer = class("HallRecommendLayer",function(args)
    local HallRecommendLayer =  display.newLayer()
    return HallRecommendLayer
end)

HallRecommendLayer.EntryConfig = {
    [702] = "GameDouble",
    [704] = "GameTMFK",
    [803] = "GameTruco",
    [901] = "GamePlinko",
}

HallRecommendLayer.pCostTime = 0.3
HallRecommendLayer.pDeltaTime = 0.08   

HallRecommendLayer.PosXConfig = {
    {display.cx},
    {display.cx-208,display.cx+208},
    {display.cx-415,display.cx,display.cx+415},
    {display.cx-624,display.cx-208,display.cx+208,display.cx+624}
}

function HallRecommendLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT)
    G_event:RemoveNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_PROGRESS)
    G_event:RemoveNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_SUCCESS)
end

function HallRecommendLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    self._updateInfo = args.updateInfo or {}
    self._tabGameListInfo = args.gameInfo or {}

    local csbNode = g_ExternalFun.loadCSB("recommend/RecommendLayer.csb")
    csbNode:setContentSize(display.width,display.height)
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)
    self:addChild(csbNode)
    ccui.Helper:doLayout(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)    

    self.mm_bg:onClicked(handler(self,self.onClickClose),true)    


    local pList = self:getRecommendList()
    self.gameUpdateNode = {}
    self.EntryList = {}
    for i, v in ipairs(pList) do
        local pItem = self["mm_"..self.EntryConfig[v]]
        pItem:setTag(v)
        pItem.userData = {
            gameKind = v,
            serverKind = self.lastSellectType or 1,
            sortId = 1,
        }
        pItem:setVisible(i<=4)
        pItem:onClicked(handler(self,self.onClickGame),true)
        table.insert(self.EntryList,pItem)

        local pNU = pItem:getChildByName("NodeUpdate")
        local NodeUpdate = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.NodeUpdate")
        local pWidthUpdate = pItem:getContentSize().width-32
        local pNodeUpdate = NodeUpdate:create(pWidthUpdate)
        pNodeUpdate:addTo(pItem)
        pNodeUpdate:setPosition(pNU:getPosition())   
        pNodeUpdate:hide()         
        self.gameUpdateNode[v] = pNodeUpdate 

        local onlineNode = pItem:getChildByName("FileNode_online")
        local panle = onlineNode:getChildByName("Panel_online")
        local onlineText = panle:getChildByName("text_onlineCount")
        g_onlineCount:regestOnline(v,onlineText)

        -- 热门 新游
        local pStatus = GlobalData.StatusConfig[v]
        local pNodeStatus = pItem:getChildByName("NodeStatus")
        if pStatus and pNodeStatus and not tolua.isnull(pNodeStatus) then
            local pNodeStatusHot = pNodeStatus:getChildByName("Hot")
            pNodeStatusHot:setVisible(pStatus==1)
            local pNodeStatusNew = pNodeStatus:getChildByName("New")    
            pNodeStatusNew:setVisible(pStatus==2)
        end
        
    end
    self.mm_Image_Update:hide()
    self:EaseShow()
    G_event:AddNotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT,handler(self,self.onClickClose))
    G_event:AddNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_PROGRESS,handler(self,self.OnUpdateDownProgress))  --下载进度更新
    G_event:AddNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_SUCCESS,handler(self,self.OnUpdateDownSuccess))  --下载进度更新
end

function HallRecommendLayer:EaseShow()
    -- local pCostTime = 0.3
    -- local pDeltaTime = 0.08   
    --标题
    self.mm_title:setPositionY(838+50)
    TweenLite.to(self.mm_title,self.pCostTime+self.pDeltaTime*2,{ y=838,ease = Cubic.easeInOut})    
    --游戏入口
    local pXConfig = self.PosXConfig[#self.EntryList]--{display.cx-415,display.cx,display.cx+415} 
    for i, v in ipairs(self.EntryList) do
        v:setPositionX(pXConfig[i]+display.width)
        TweenLite.to(v,self.pCostTime+(i-1)*self.pDeltaTime,{ x=pXConfig[i],ease = Cubic.easeInOut})    
    end
    -- local pXConfig = {display.cx-415,display.cx,display.cx+415} 
    -- for i = 1,3 do
    --     if self.EntryList[i] then
    --         self.EntryList[i]:setPositionX(pXConfig[i]+display.width)
    --         TweenLite.to(self.EntryList[i],self.pCostTime+(i-1)*self.pDeltaTime,{ x=pXConfig[i],ease = Cubic.easeInOut})    
    --     end
    -- end
end

function HallRecommendLayer:EaseHide(callback)
    -- local pCostTime = 0.3
    -- local pDeltaTime = 0.08    
    --标题
    TweenLite.to(self.mm_title,self.pCostTime+self.pDeltaTime*2,{ y=888,ease = Cubic.easeInOut})    
    --游戏入口
    local pXConfig = self.PosXConfig[#self.EntryList]--{display.cx-415,display.cx,display.cx+415} 
    for i, v in ipairs(self.EntryList) do        
        TweenLite.to(v,self.pCostTime+(i-1)*self.pDeltaTime,{ x=pXConfig[i]-display.width,ease = Cubic.easeInOut,onComplete = i==#self.EntryList and callback or nil})      
    end
    -- local pXConfig = {display.cx-415,display.cx,display.cx+415} 
    -- for i = 1,3 do 
    --     if self.EntryList[i] then
    --         TweenLite.to(self.EntryList[i],self.pCostTime+(i-1)*self.pDeltaTime,{ x=pXConfig[i]-display.width,ease = Cubic.easeInOut,onComplete = i==3 and callback or nil})    
    --     end
    -- end    
end

function HallRecommendLayer:onClickClose()    
    local callback = function()
        self:removeSelf()
    end
    self:EaseHide(callback)
    self:uploadClick(0)
end

function HallRecommendLayer:onClickGame(target)
    if self.mm_Image_Update:isVisible() then
        return
    end
    local gameKind = target.userData.gameKind  
    local serverKind = target.userData.serverKind
    local sortId = target.userData.sortId
    local roomMark = g_ExternalFun.getRoomMark(gameKind,serverKind,sortId)
    if self._updateInfo[gameKind].down == true then   --需要下载
        self:OnUpdateDownProgress({gameId = gameKind,percent=0})
        G_event:NotifyEvent(G_eventDef.UI_GAME_UPDATE,{subGameId = gameKind})        
    else  
        GlobalData.HallClickGame = true
        if gameKind == 702 then
            if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
                showNetLoading()   --点击游戏
                G_event:NotifyEvent(G_eventDef.UI_START_GAME,{roomMark = roomMark,quickStart = false})   
            else
                local pData = {
                    gameId = gameKind,
                }
                G_event:NotifyEvent(G_eventDef.UI_SHOW_SELECTROOMLAYER,pData)
            end
        else
            local pData = {
                gameId = gameKind,
            }
            G_event:NotifyEvent(G_eventDef.UI_SHOW_ROOMLISTLAYER,pData)
        end
        self:uploadClick(gameKind)
        self:removeSelf()
    end
end

function HallRecommendLayer:OnUpdateDownSuccess(args)
    local node = self.gameUpdateNode[args.gameId] 
    if node then
        node:hide()
    end
    if self._updateInfo[args.gameId] then
        self._updateInfo[args.gameId].down = false
    end
    self.mm_Image_Update:hide()
end

function HallRecommendLayer:OnUpdateDownProgress(args)
   local node = self.gameUpdateNode[args.gameId]
   if not node then return end
   node:show()
   node:setUpdatePercent(args.percent)
   self.mm_Image_Update:show()
   self.mm_Text_progress:setString(args.percent.."%")
end

function HallRecommendLayer:uploadClick(pKindID)
    G_ServerMgr:C2S_UploadRecommendClick(pKindID)
end

function HallRecommendLayer:getRecommendList()
    local pList = {}
    for i, v in ipairs(GlobalUserItem.RecommendList) do
        if v.wKindID == 702 or
           v.wKindID == 704 or
           v.wKindID == 803 or
           v.wKindID == 901 then
            table.insert(pList,v.wKindID)
        end
    end
    if #pList<3 then
        pList = {901,803,702,}
    end
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        pList = {803,}
    end
    return pList
end

function HallRecommendLayer:selectMoneyType(serverKind)

    if self.lastSellectType and self.lastSellectType == serverKind then
        return
    end
    self.lastSellectType = serverKind

    for k,v in ipairs(self.EntryList) do
        local _userData = clone(v.userData)
        v.userData = {
            gameKind = _userData.gameKind,
            serverKind = self.lastSellectType or 1,
            sortId = 1,
        }
        v:hide()
    end

    local pXConfig = {display.cx-415,display.cx,display.cx+415} 
    for i = 1,3 do
        if self.EntryList[i] then
            self.EntryList[i]:setPositionX(pXConfig[i]+display.width)
            
            TweenLite.to(self.EntryList[i],self.pCostTime,{ autoAlpha = 1 })
            TweenLite.to(self.EntryList[i],self.pCostTime+(i-1)*self.pDeltaTime,{ x=pXConfig[i],ease = Cubic.easeInOut})    
        end
    end
end


return HallRecommendLayer