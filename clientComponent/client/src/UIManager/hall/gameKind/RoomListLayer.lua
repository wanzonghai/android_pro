---------------------------------------------------
--Desc:场次选择界面
--Date:2022-09-06 16:57:56
--Author:A*
---------------------------------------------------
local RoomListLayer = class("RoomListLayer",function(args)
	local RoomListLayer =  display.newLayer()
    return RoomListLayer
end)

--玩法标题配置
RoomListLayer.TitleConfig = {
    [407] = "GUI/xuanchang/title_LKPY.png",
    [502] = "GUI/xuanchang/title_97QH.png",
    [516] = "GUI/xuanchang/title_SHZ.png",
    [520] = "GUI/xuanchang/title_DNTG.png",
    [525] = "GUI/xuanchang/title_JXLW.png",
    [527] = "GUI/xuanchang/title_BLCS.png",
    [528] = "GUI/xuanchang/title_Egito.png",
    [704] = "GUI/xuanchang/title_TMFK.png",
    [803] = "GUI/xuanchang/title_Truco.png",
    [901] = "GUI/xuanchang/title_Plinko.png",
    [532] = "GUI/xuanchang/title_BXNW.png",
    [529] = "GUI/xuanchang/title_CSD.png",
    [531] = "GUI/xuanchang/title_JNH.png",
}

RoomListLayer.pCostTime = 0.3
RoomListLayer.pDeltaTime = 0.08
-- 场次
RoomListLayer.pItemXList = {
    {960},
    {576,1344},
    {480,960,1440},
    {345,755,1165,1575}
}

function RoomListLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    if ylAll.ProjectSelect == 2 then
        self.lastSellectType = 1
    else
        self.lastSellectType = cc.UserDefault:getInstance():getIntegerForKey("LastRoomType",g_format.currencyType.GOLD)    
    end
    
    local csbNode = g_ExternalFun.loadCSB("UI/RoomListLayer.csb")
    self:addChild(csbNode)
    self.bg = csbNode:getChildByName("bg")
    self.content = csbNode:getChildByName("content")
    
    --TC币场背景
    self.contentTC = self.content:getChildByName("content_tc")    
    self.contentTC:setVisible(self.lastSellectType == g_format.currencyType.TC)

    --关闭按钮
    self.btnClose = self.content:getChildByName("btnClose")
    self.btnClose:hide()
    self.btnClose:onClicked(handler(self,self.onClickClose),true)
    --标题
    self.title = self.content:getChildByName("title")
    self.title:setTexture(self.TitleConfig[args.gameId])
    self.title:hide()

    self.btnGold = self.content:getChildByName("btn_gold")
    self.btnGold:onClicked(function() 
        self:selectMoneyType(g_format.currencyType.GOLD)
    end)
    self.btnTc = self.content:getChildByName("btn_tc")
    self.btnTc:onClicked(function() 
        self:selectMoneyType(g_format.currencyType.TC)
    end)
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        self.btnGold:hide()
        self.btnTc:hide()        
    else
        self.btnGold:show()
        self.btnTc:show()
    end

    --场次
    self.RoomList = {}
    self.RoomListTC = {}
    for i = 1,4 do
        local pRoom = self.content:getChildByName("Room_"..i)
        local pRoom_tc = self.content:getChildByName("Room_tc_"..i)
        pRoom:hide()
        pRoom_tc:hide()        
        table.insert(self.RoomList,pRoom)
        table.insert(self.RoomListTC,pRoom_tc)
    end    
    local callback = handler(self,self.EaseShow)
    ShowCommonLayerAction(self.bg,self.content,callback)
    
    self.RoomListData = GlobalUserItem.GetServerRoomByGameKind(args.gameId)
    if not self.RoomListData then 
        return 
    end
    self.m_roomListGOLD = nil
    self.m_roomListTC = nil
    for k,v in pairs(self.RoomListData) do
        if v.wServerKind == G_NetCmd.GAME_KIND_TC then
            if self.m_roomListTC == nil then
                self.m_roomListTC = {}
            end
            table.insert(self.m_roomListTC,v)
        elseif v.wServerKind == G_NetCmd.GAME_KIND_GOLD then
            if self.m_roomListGOLD == nil then
                self.m_roomListGOLD = {}
            end
            table.insert(self.m_roomListGOLD,v)
        end
    end
    if self.m_roomListGOLD then
        table.sort(self.m_roomListGOLD,function(a,b) 
            return a.wSortID < b.wSortID
        end)
    end

    if self.m_roomListTC then
        table.sort(self.m_roomListTC,function(a,b) 
            return a.wSortID < b.wSortID
        end)
    end

    G_event:AddNotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT_2,handler(self,self.onGameKindExit))
end

function RoomListLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT_2)
end

function RoomListLayer:EaseShow() 
    --关闭按钮
    self.btnClose:setPositionY(display.height+151)
    TweenLite.to(self.btnClose, self.pCostTime, { autoAlpha = 1 })
    TweenLite.to(self.btnClose, self.pCostTime, {delay=0.7,y=display.height})
    --title
    TweenLite.to(self.title, 0.3, { delay=0.1,autoAlpha = 1 })
    self:selectMoneyType(self.lastSellectType)
end

function RoomListLayer:getCurTypeRoomInfo(currencyType)
    if currencyType == g_format.currencyType.TC then
        return self.m_roomListTC
    else
        return self.m_roomListGOLD
    end
end

function RoomListLayer:selectMoneyType(currencyType)   
    self.lastSellectType = currencyType
    self.contentTC:setVisible(self.lastSellectType == g_format.currencyType.TC)
    cc.UserDefault:getInstance():setIntegerForKey("LastRoomType",currencyType)    
    cc.UserDefault:getInstance():flush()
    self.btnGold:setEnabled(self.lastSellectType~=g_format.currencyType.GOLD)
    self.btnTc:setEnabled(self.lastSellectType~=g_format.currencyType.TC)
    
    self:hideItem()
    local roomList = self:getCurTypeRoomInfo(currencyType)
    if roomList == nil then return end
    local pItemX = self.pItemXList[math.min(#roomList,4)]
    local pWidth = display.width
    for i, v in ipairs(pItemX) do
        local item = currencyType==g_format.currencyType.TC and self.RoomListTC[i] or self.RoomList[i]
        local data = roomList[i]
        item:setColor(data.bOnline and cc.c3b(255,255,255) or cc.c3b(127,127,127))
        local txtEnter = item:getChildByName("EnterScore")
        local score = g_format:formatNumber(data.lEnterScore,g_format.fType.abbreviation,currencyType)
        txtEnter:setString(score)
        local pScoreIcon = item:getChildByName("ScoreIcon")
        pScoreIcon:setPositionX(txtEnter:getPositionX()-txtEnter:getContentSize().width)
        local btn = item:getChildByName("Button_1")        
        btn:onClicked(function ()
            if data.bOnline then
                self:onClickRoom(data.roomMark)
            else

            end
        end)
        item:setPositionX(pItemX[i]+pWidth/2)
        TweenLite.to(item,self.pCostTime,{ delay=(i-1)*self.pDeltaTime,autoAlpha = 1 })
        TweenLite.to(item,self.pCostTime+(i-1)*self.pDeltaTime,{ x=pItemX[i],ease = Cubic.easeInOut})
        local onlineNode = item:getChildByName("FileNode_online")
        local panle = onlineNode:getChildByName("Panel_online")
        local onlineText = panle:getChildByName("text_onlineCount") 
        g_onlineCount:regestOnline(data.roomMark,onlineText)
    end
    
end

function RoomListLayer:hideItem()
    -- for k,v in pairs(self.RoomList) do
    --     v:hide()
    -- end
    for i = 1, 4 do
        self.RoomList[i]:hide()
        self.RoomListTC[i]:hide()
    end
end

-- function GameJieJiLayer:onInitGameRoom()
--     for i=1,4 do 
--        local iteminfo = self._tabGameListInfo[self._curGameId][i]
--        local node = self.roomItem[i]
--        if iteminfo then
--            node:setVisible(true)
--            local txtEnter = node:getChildByName("Text_mingzi_0")
--            local score = g_format:formatNumber(iteminfo.lEnterScore,g_format.fType.abbreviation)
--            txtEnter:setString(score)
--        else
--            node:setVisible(false)
--        end
--     end
    
--     local callback = function()
--         self:EaseShow(2)
--     end
--     self:EaseHide(callback,true)
-- end

function RoomListLayer:onClickRoom(_roomMark)
    -- local enterScore = self.RoomListData[index].lEnterScore
    --币不足统一游戏登录拦截 GameFrameEngine:onLogonRoom
    showNetLoading()   --开始游戏
    G_event:NotifyEvent(G_eventDef.UI_START_GAME,{roomMark = _roomMark,quickStart = false})   
end

function RoomListLayer:onGameKindExit()
    self:removeSelf()
end

function RoomListLayer:onClickClose()
    DoHideCommonLayerAction(self.bg,self.content,function() self:removeSelf() end)
end
return RoomListLayer