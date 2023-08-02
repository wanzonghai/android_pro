

--[[
    百人场选择房间类型 金币 or TC
]]

local selectEnterRoomLayer = class("selectEnterRoomLayer",ccui.Layout)

function selectEnterRoomLayer:ctor(args)
    -- self._scene = args.scene
    -- self.kindid = args.gameId
    local parent = cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    local csbNode = g_ExternalFun.loadCSB("Lobby/selectEnterRoomLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)

    self.skeletonNode = sp.SkeletonAnimation:create("client/res/spine/ruchangxuanzhe.json", "client/res/spine/ruchangxuanzhe.atlas", 1)
    self.skeletonNode:setAnimation(0, "daiji", true)
    self.skeletonNode:setSkin("moren")
    self.skeletonNode:setPosition(cc.p(0,0))
    self.mm_Node_spine:addChild(self.skeletonNode)

    self.mm_btn_close:onClicked(function() self:onExit() end)
    self:registerTouch()
    -- self.mm_btn_gold:onClicked(function() self:selectMoneyType(g_format.currencyType.GOLD) end)
    -- self.mm_btn_tc:onClicked(function() self:selectMoneyType(g_format.currencyType.TC) end)

    self:logicData(args.gameId)
end

function selectEnterRoomLayer:onExit()
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() self:removeSelf() end)
end

function selectEnterRoomLayer:logicData(gameKind)
    self.RoomListData = GlobalUserItem.GetServerRoomByGameKind(gameKind)
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
end

function selectEnterRoomLayer:getCurTypeRoomInfo(serverKind)
    if serverKind == g_format.currencyType.TC then
        return self.m_roomListTC
    else
        return self.m_roomListGOLD
    end
end

function selectEnterRoomLayer:selectMoneyType(serverKind)
    -- if self.lastSellectType and self.lastSellectType == serverKind then
    --     return  --
    -- end
    -- self.lastSellectType = serverKind
    local roomList = self:getCurTypeRoomInfo(serverKind)
    if roomList == nil then
        return 
    else
        showNetLoading()   --开始游戏
        local default_SortID = 1  --百人场默认进第一个场
        for i=1,#roomList do
            if roomList[i].bOnline == true then
                default_SortID = i
            end
        end
        G_event:NotifyEvent(G_eventDef.UI_START_GAME,{roomMark = roomList[default_SortID].roomMark,quickStart = false})   
        self:onExit()
    end
end

function selectEnterRoomLayer:registerTouch()
    -- self.mm_btn_gold:onClicked(function() self:selectMoneyType(g_format.currencyType.GOLD) end)
    -- self.mm_btn_tc:onClicked(function() self:selectMoneyType(g_format.currencyType.TC) end)

    
	local function onTouchBegan( touch, event )
        local pLocation = touch:getLocation()
        local pSize = self.mm_btn_gold:getContentSize()    
        local rec = cc.rect(0,0,pSize.width,pSize.height)
        local pos1 = self.mm_btn_gold:convertToNodeSpace(pLocation)
        local pos2 = self.mm_btn_tc:convertToNodeSpace(pLocation)
        
        local pSkin = "moren"
        if cc.rectContainsPoint(rec, pos1) then
            pSkin = "zuo"
            self.lastSellectType = g_format.currencyType.GOLD
        end
        if cc.rectContainsPoint(rec, pos2) then
            pSkin = "you"
            self.lastSellectType = g_format.currencyType.TC
        end
        self.skeletonNode:setSkin(pSkin)
		return true
	end

	local function onTouchEnded( touch, event )		
        local pLocation = touch:getLocation()
        local pSize = self.mm_btn_gold:getContentSize()    
        local rec = cc.rect(0,0,pSize.width,pSize.height)
        local pos1 = self.mm_btn_gold:convertToNodeSpace(pLocation)
        local pos2 = self.mm_btn_tc:convertToNodeSpace(pLocation)  
        local pSkin = "moren"      
        if cc.rectContainsPoint(rec, pos1) and self.lastSellectType == g_format.currencyType.GOLD then   
            pSkin = "zuo"
            self:selectMoneyType(g_format.currencyType.GOLD)
        end
        if cc.rectContainsPoint(rec, pos2) and self.lastSellectType == g_format.currencyType.TC then 
            pSkin = "you"
            self:selectMoneyType(g_format.currencyType.TC)           
        end
        self.skeletonNode:setSkin(pSkin)
        self.lastSellectType = nil
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.mm_btn_gold)

    local listener2 = cc.EventListenerTouchOneByOne:create()
	listener2:setSwallowTouches(false)
    listener2:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener2:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener2, self.mm_btn_tc)
end

return selectEnterRoomLayer