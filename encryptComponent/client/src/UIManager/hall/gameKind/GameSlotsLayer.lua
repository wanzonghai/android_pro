---------------------------------------------------
--Desc:街机场选择界面
--Date:2022-09-06 14:57:56
--Author:A*
---------------------------------------------------
local GameSlotsLayer = class("GameSlotsLayer",function(args)
	local GameSlotsLayer =  display.newLayer()
    return GameSlotsLayer
end)

local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
function GameSlotsLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT)
    G_event:RemoveNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_PROGRESS)
    G_event:RemoveNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_SUCCESS)  
    G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_USER_SCORE_REFRESH)  
end

GameSlotsLayer.GameList = {
    --自有Slots游戏    
    {ID=704,	Name="GameTMFK",	Path="Lobby/Entry/GameTMFK.csb",	Type="OfficialGame",Desc="甜蜜富矿"},       --甜蜜富矿
    {ID=532,	Name="GameBXNW",	Path="Lobby/Entry/GameBXNW.csb",	Type="OfficialGame",Desc="冰雪女王"},       --冰雪女王
    {ID=529,	Name="GameCSD",	    Path="Lobby/Entry/GameCSD.csb",		Type="OfficialGame",Desc="财神到"},         --财神到
    {ID=531,	Name="GameJNH",	    Path="Lobby/Entry/GameJNH.csb",		Type="OfficialGame",Desc="嘉年华"},         --嘉年华
    {ID=528,	Name="GameEgito",	Path="Lobby/Entry/GameEgito.csb",	Type="OfficialGame",Desc="埃及拉霸"},       --埃及拉霸
    {ID=525,	Name="GameJXLW",	Path="Lobby/Entry/GameJXLW.csb",	Type="OfficialGame",Desc="九线拉王"},       --九线拉王
    {ID=527,	Name="GameBLCS",	Path="Lobby/Entry/GameBLCS.csb",	Type="OfficialGame",Desc="秘鲁传说"},       --秘鲁传说
    {ID=502,	Name="Game97QH",	Path="Lobby/Entry/Game97QH.csb",	Type="OfficialGame",Desc="97拳皇"},         --97拳皇
    {ID=516,	Name="GameSHZ",	    Path="Lobby/Entry/GameSHZ.csb",		Type="OfficialGame",Desc="水浒传"},         --水浒传  
    --游戏厂商Slots游戏
    --EasyGame
    {ID=4100,	Name="Game4100",	Path="Lobby/Entry/Game4100.csb",	Type="EasyGame",	Desc="水牛"},		    --水牛
    {ID=4400,	Name="Game4400",	Path="Lobby/Entry/Game4400.csb",	Type="EasyGame",	Desc="富贵熊猫"},		--富贵熊猫 
    {ID=4600,	Name="Game4600",	Path="Lobby/Entry/Game4600.csb",	Type="EasyGame",	Desc="咆哮荒野"},		--咆哮荒野 
    {ID=4700,	Name="Game4700",	Path="Lobby/Entry/Game4700.csb",	Type="EasyGame",	Desc="白狮"},		    --白狮
    {ID=5400,	Name="Game5400",	Path="Lobby/Entry/Game5400.csb",	Type="EasyGame",	Desc="海豚之夜"},		--海豚之夜 
    {ID=5900,	Name="Game5900",	Path="Lobby/Entry/Game5900.csb",	Type="EasyGame",	Desc="骑士"},		    --骑士 
    {ID=6100,	Name="Game6100",	Path="Lobby/Entry/Game6100.csb",	Type="EasyGame",	Desc="水果机"},		    --水果机 
    {ID=6400,	Name="Game6400",	Path="Lobby/Entry/Game6400.csb",	Type="EasyGame",	Desc="池塘"},		    --池塘 
    {ID=7700,	Name="Game7700",	Path="Lobby/Entry/Game7700.csb",	Type="EasyGame",	Desc="开心农场"},		--开心农场 
    {ID=8600,	Name="Game8600",	Path="Lobby/Entry/Game8600.csb",	Type="EasyGame",	Desc="花木兰"},		    --花木兰 
    {ID=8700,	Name="Game8700",	Path="Lobby/Entry/Game8700.csb",	Type="EasyGame",	Desc="森林舞会"},		--森林舞会 
}

function GameSlotsLayer:ctor(args)
    --提前加载合图
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("client/res/Lobby/GUI/HallPlist.plist", "client/res/Lobby/GUI/HallPlist.png")
    -- spriteFrameCache:addSpriteFrames("client/res/Lobby/GUI/RoomList1.plist", "client/res/Lobby/GUI/RoomList1.png")
    spriteFrameCache:addSpriteFrames("client/res/Lobby/GUI/SceneSlots1.plist", "client/res/Lobby/GUI/SceneSlots1.png")
    -- spriteFrameCache:addSpriteFrames("client/res/Lobby/GUI/SubScenePlist1.plist", "client/res/Lobby/GUI/SubScenePlist1.png")
    -- spriteFrameCache:addSpriteFrames("client/res/Lobby/GUI/SubScenePlist2.plist", "client/res/Lobby/GUI/SubScenePlist2.png")
    -- spriteFrameCache:addSpriteFrames("client/res/Lobby/GUI/SubScenePlist3.plist", "client/res/Lobby/GUI/SubScenePlist3.png")
    -- spriteFrameCache:addSpriteFrames("client/res/Lobby/GUI/SubScenePlist4.plist", "client/res/Lobby/GUI/SubScenePlist4.png")
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    self.GiftStatus = args.GiftStatus
    self.quitCallback = args.quitCallback
    self._updateInfo = args.updateInfo or {}
    self._curGameIdTab = GlobalData.SubGameId[args.kind]
    self._tabGameListInfo = args.gameInfo or {}

    --默认进入游戏
    self.GameID = args.GameID

    self.csbNode = g_ExternalFun.loadCSB("Lobby/SceneSlots.csb")
    self.content = self.csbNode:getChildByName("content")
    self.csbNode:setContentSize(display.width,display.height)
    self.csbNode:setAnchorPoint(cc.p(0.5,0.5))
    self.csbNode:setPosition(display.cx,display.cy)
    self:addChild(self.csbNode)
    --左上
    self.PanelLeftTop = self.content:getChildByName("PanelLeftTop")
    --左中
    self.PanelRightCenter = self.content:getChildByName("PanelRightCenter")
    --右中
    self.PanelLeftCenter = self.content:getChildByName("PanelLeftCenter")
    -- local caiJinNode = self.PanelRightCenter:getChildByTag(101)
    -- if not caiJinNode then
    --     local caiJinNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.subinterface.caiJinNode"):create()
    --     caiJinNode:setPosition(1400,909)
    --     caiJinNode:addTo(self.PanelRightCenter,1,101)
    -- end

    --适配性调整Panel大小
    self:adjustPanelSize()
    ccui.Helper:doLayout(self.csbNode)
    
    --左上
    --返回
    self.btnBack = self.PanelLeftTop:getChildByName("btnBack")
    self.btnBack:onClicked(function()
        self:onClickClose()
    end)
    --左中
    -- Avatar
    local NodeAvatar = self.PanelLeftCenter:getChildByName("NodeAvatar")
    NodeAvatar:show()
    local skeletonNode = sp.SkeletonAnimation:create("client/res/spine/huodongjuese.json", "client/res/spine/huodongjuese.atlas", 1)
    skeletonNode:addAnimation(0, "daiji", true)    
    skeletonNode:setPosition(0,-300)
    local pSize = self.PanelLeftCenter:getContentSize()
    NodeAvatar:setPosition(cc.p(pSize.width/2,0))    
    NodeAvatar:addChild(skeletonNode)

    --右中
    --玩法列表
    self.ScrollView_1 = self.PanelRightCenter:getChildByName("ScrollView_1")  --游戏  
    self.ScrollView_1:setScrollBarEnabled(false)  
    self.txtCoin = self.PanelRightCenter:getChildByName("goldValue")
    self.PanelRightCenter:getChildByName("goldAdd"):onClicked(function() 
        --未拉取商品完成，则跳过响应
        if not GlobalData.ProductsOver then return end

        local quitCallback = function()
            self:EaseShow()
        end
        self:EaseHide(function()
            dismissNetLoading()
            local pData = {
                quitCallback = quitCallback
            }
            G_event:NotifyEvent(G_eventDef.UI_OPEN_RECHARGELAYER,pData)
        end)
    end)    

    --附加货币币 进行区分
    local pPanelExtra = self.PanelRightCenter:getChildByName("Panel_Extra")    
    pPanelExtra:onClicked(handler(self,self.onExtraClick))
    self.txtExtra = pPanelExtra:getChildByName("ExtraValue")    

    --设置玩家信息
    self:onUpdateUserInfo()
    
    self.gameItem = {}
    self.gameUpdateNode = {}
    local this = self
    for i, v in ipairs(self.GameList) do
        local item = self.ScrollView_1:getChildByName(v.Name)
        local itemEffect = g_ExternalFun.loadTimeLine(v.Path)
        itemEffect:gotoFrameAndPlay(0, true)
        item:runAction(itemEffect)
        table.insert(self.gameItem,item)
        local btn = item:getChildByName("Button_1")
        btn:setSwallowTouches(false)
        btn:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                this._touchMoveX = g_ExternalFun.ccpCopy(sender:getTouchBeganPosition()).x
            elseif eventType == ccui.TouchEventType.ended then
               local endPosX = g_ExternalFun.ccpCopy(sender:getTouchEndPosition()).x
               if math.abs(endPosX - this._touchMoveX) <= g_ExternalFun.touchLength then
                   self:onClickGame(v)
               end
            end
        end) 
        --NodeUpdate
        local pNU = item:getChildByName("NodeUpdate")
        local NodeUpdate = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.NodeUpdate")
        local pWidthUpdate = btn:getContentSize().width-87
        local pNodeUpdate = NodeUpdate:create(pWidthUpdate)
        pNodeUpdate:setMaskType(3)
        pNodeUpdate:addTo(item)
        pNodeUpdate:setPosition(pNU:getPosition())   
        pNodeUpdate:hide()         
        self.gameUpdateNode[v.ID] = pNodeUpdate

        --NodeOnline
        local onlineNode = item:getChildByName("FileNode_online")
        if v.Type == "EasyGame" then
            --[[
            item:setColor(cc.c3b(127,127,127))
            item:stopAllActions()
            --]]
            onlineNode:hide()
        elseif v.Type == "OfficialGame" then
            onlineNode:show()
            local panle = onlineNode:getChildByName("Panel_online")
            local onlineText = panle:getChildByName("text_onlineCount")
            g_onlineCount:regestOnline(v.ID,onlineText)
        end

        --热门 新游
        local pStatus = GlobalData.StatusConfig[v.ID]
        local pNodeStatus = item:getChildByName("NodeStatus")
        if pStatus and pNodeStatus and not tolua.isnull(pNodeStatus) then
            local pNodeStatusHot = pNodeStatus:getChildByName("Hot")
            pNodeStatusHot:setVisible(pStatus==1)
            local pNodeStatusNew = pNodeStatus:getChildByName("New")    
            pNodeStatusNew:setVisible(pStatus==2)
        end
    end
    showNetLoading()
    self:EaseShow(function ()
        dismissNetLoading()
        if self.GameID then
            for i, v in ipairs(self.GameList) do
                if v.ID == self.GameID then
                    self:onClickGame(v)
                    return
                end
            end
        end
        if  self.GiftStatus and GlobalData.ProductsOver and GlobalData.GiftEnable and GlobalData.PayInfoOver and not GlobalData.TodayPay and GlobalData.First3Times > 0 then            
            GlobalData.First3Times = GlobalData.First3Times - 1
            local pData = {
                ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
            }
            G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)            
        end
    end)
    g_ExternalFun.stopMusic()
    G_event:AddNotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT,handler(self,self.onGameKindExit))
    G_event:AddNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_PROGRESS,handler(self,self.OnUpdateDownProgress))  --下载进度更新
    G_event:AddNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_SUCCESS,handler(self,self.OnUpdateDownSuccess))  --下载进度更新
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_USER_SCORE_REFRESH,handler(self,self.onUpdateUserInfo))
end
--适配性调整Panel大小
function GameSlotsLayer:adjustPanelSize()
    --左中指导性尺寸
    self.LeftCenterMin = 446
    self.LeftCenterMax = 650
    
    --左中比例
    self.LeftCenterPercent = 446/1920
    
    --获取屏幕宽度
    local pWidth = display.width
    if pWidth <= 1920 then
        --屏幕宽度小于设计尺寸
        --左中走最小尺寸
        self.PanelLeftCenter:setContentSize(cc.size(self.LeftCenterMin,1080))
    else
        --屏幕宽度超过设计尺寸
        local pAbelLeftCenterWidth = math.min(pWidth*self.LeftCenterPercent,self.LeftCenterMax)
        self.PanelLeftCenter:setContentSize(cc.size(pAbelLeftCenterWidth,1080))
    end    
end

--缓入
function GameSlotsLayer:EaseShow(callback)
    local pCostTime = 0.3
    local pDeltaTime = 0.08    
    --左上
    self.PanelLeftTop:setPositionY(display.height+160)
    TweenLite.to(self.PanelLeftTop,pCostTime,{ y=display.height,ease = Cubic.easeInOut})
    --左中
    local pSize = self.PanelLeftCenter:getContentSize()
    self.PanelLeftCenter:setPositionX(-pSize.width)
    TweenLite.to(self.PanelLeftCenter,pCostTime,{ x=0,ease = Cubic.easeInOut})
    --右中
    self.PanelRightCenter:setPositionX(display.width+2560/2)    
    TweenLite.to(self.PanelRightCenter,pCostTime/2,{ x=display.cx,ease = Cubic.easeInOut})
    
    --游戏列表
    --单个节点操作
    local pItemX = {
        230,590,950,1310,1670,2030,2390,2750,3110,3470,
        3830,4190,4550,4910,5270,5630,5990,6350,6710,7070,7430,
    }    
    local pWidth = display.width    
    local pWidth  = self.ScrollView_1:getContentSize().width
    for i, v in ipairs(self.gameItem) do
        v:setPositionX(pItemX[i]+pWidth)        
        TweenLite.to(v,pCostTime+(i-1)*pDeltaTime,{ x=pItemX[i],ease = Cubic.easeInOut,onComplete = (i==5) and callback or nil})        
    end
end

--缓出
function GameSlotsLayer:EaseHide(callback)    
    local pCostTime = 0.3
    local pDeltaTime = 0.08    
    --左上
    TweenLite.to(self.PanelLeftTop,pCostTime,{ y=display.height+160,ease = Cubic.easeInOut})    
    --左中
    local pSize = self.PanelLeftCenter:getContentSize()
    TweenLite.to(self.PanelLeftCenter,pCostTime,{ x=-pSize.width,ease = Cubic.easeInOut})
    --右中
    TweenLite.to(self.PanelRightCenter,pCostTime,{ x=display.cx+2560,ease = Cubic.easeInOut,onComplete =callback})    
end

function GameSlotsLayer:onUpdateUserInfo()    
    --更新财富值
	local str = g_format:formatNumber(GlobalUserItem.lUserScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
	self.txtCoin:setString(str)

    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        --更新银行值
        local strBank = g_format:formatNumber(GlobalUserItem.lUserInsure,g_format.fType.abbreviation,g_format.currencyType.GOLD)
        self.txtExtra:setString(strBank)
    else
        --更新TC值            
        local strTC = g_format:formatNumber(GlobalUserItem.lTCCoin,g_format.fType.abbreviation,g_format.currencyType.TC)
        self.txtExtra:setString(strTC)
    end
end

function GameSlotsLayer:onClickClose()
    local callback = function()
        if self.quitCallback then
            self.quitCallback()
        end
        self:removeSelf()
    end
    self:EaseHide(callback)
end

function GameSlotsLayer:onClickGame(pData)
    self._curGameId = pData.ID
    --EasyGame
    if pData.Type == "EasyGame" then   
        --[[
        showToast(g_language:getString("game_not_open"))
        return
        --]]  
        ---[[
        if GlobalData.ReceiveEGSuccess then
            if ylAll.SERVER_UPDATE_DATA.easy_game_threshold and  GlobalUserItem.lUserScore >= ylAll.SERVER_UPDATE_DATA.easy_game_threshold then
                local pFlag = g_EasyGameUpdater:CheckFix(pData.ID)
                if pFlag then
                    G_event:NotifyEvent(G_eventDef.UI_START_GAME,{roomMark = pData.ID*100+90,quickStart = false})
                else
                    --加入下载队列
                    G_event:NotifyEvent(G_eventDef.UI_GAME_UPDATE,{subGameId = self._curGameId})
                    self:OnUpdateDownProgress({gameId = self._curGameId,percent=0})    
                end
            else
                G_event:NotifyEvent(G_eventDef.EVENT_SCORE_LESS,{lEnterScore = ylAll.SERVER_UPDATE_DATA.easy_game_threshold})  --金币不足
            end
        else
            showToast(g_language:getString("game_not_open"))
        end
        return 
        --]]
    end

    if self._updateInfo[self._curGameId].down == true then   --需要下载
        G_event:NotifyEvent(G_eventDef.UI_GAME_UPDATE,{subGameId = self._curGameId})
        self:OnUpdateDownProgress({gameId = self._curGameId,percent=0})
    else
        local pData = {gameId = self._curGameId,}
        G_event:NotifyEvent(G_eventDef.UI_SHOW_ROOMLISTLAYER,pData)
    end
end

function GameSlotsLayer:onGameKindExit()
    self:removeSelf()
end
function GameSlotsLayer:OnUpdateDownSuccess(args)
     local node = self.gameUpdateNode[args.gameId] 
     if node then
         node:hide()
     end
     if self._updateInfo[args.gameId] then
         self._updateInfo[args.gameId].down = false
     end
end
function GameSlotsLayer:OnUpdateDownProgress(args)
    local node = self.gameUpdateNode[args.gameId]
    if not node then return end
    node:show()
    node:setUpdatePercent(args.percent)
end


function GameSlotsLayer:onExtraClick()
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        if GlobalData.FirstOpenBank == true then
            GlobalData.BankSelectType = 1
            if GlobalUserItem.cbInsureEnabled == 0 then
                G_event:NotifyEvent(G_eventDef.UI_OPEN_BANKLAYER)  --开通
            else
                G_event:NotifyEvent(G_eventDef.UI_LOGON_BANKLAYER)  --登录
            end
            return
        end
        G_event:NotifyEvent(G_eventDef.UI_SHOW_BANKLAYER_NEW)
    else
        -- if GlobalData.TCIndex > 0 then
        --     G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_ACTIVITY,{scene = self,Index=GlobalData.TCIndex})                
        -- end
    end
end

return GameSlotsLayer