---------------------------------------------------
--Desc:百人场+捕鱼场选择界面
--Date:2022-09-06 14:57:56
--Author:A*
---------------------------------------------------
local GameEspecialLayer = class("GameEspecialLayer",function(args)
	local GameEspecialLayer =  display.newLayer()
    return GameEspecialLayer
end)
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")

function GameEspecialLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT)
    G_event:RemoveNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_PROGRESS)
    G_event:RemoveNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_SUCCESS)
    G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_USER_SCORE_REFRESH)
end

GameEspecialLayer.GameList = {
    --自有游戏  
    {ID=702,	Name="GameDouble",	Path="Lobby/Entry/GameDouble.csb",	Type="OfficialGame",Desc="Double"},         --Double
    {ID=703,	Name="GameCrash",	Path="Lobby/Entry/GameCrash.csb",	Type="OfficialGame",Desc="Crash"},          --Crash
    {ID=803,	Name="GameTruco",	Path="Lobby/Entry/GameTruco.csb",	Type="OfficialGame",Desc="Truco"},          --Truco
    {ID=901,	Name="GamePlinko",	Path="Lobby/Entry/GamePlinko.csb",	Type="OfficialGame",Desc="Plinko"},          --Plinko
    {ID=602,	Name="GameBicho",	Path="Lobby/Entry/GameBicho.csb",	Type="OfficialGame",Desc="Bicho"},          --Bicho
    {ID=903,	Name="GameLPD",	    Path="Lobby/Entry/GameLPD.csb",		Type="OfficialGame",Desc="LPD"},            --LPD
    {ID=520,	Name="GameDNTG",	Path="Lobby/Entry/GameDNTG.csb",	Type="OfficialGame",Desc="大闹天宫"},        --大闹天宫
    {ID=407,	Name="GameLKPY",	Path="Lobby/Entry/GameLKPY.csb",	Type="OfficialGame",Desc="李逵劈鱼"},        --李逵劈鱼
    {ID=122,	Name="GameBJL",	    Path="Lobby/Entry/GameBJL.csb",	    Type="OfficialGame",Desc="百家乐"},          --百家乐
    --游戏厂商游戏
    --EasyGame
    {ID=23600,	Name="Game23600",	Path="Lobby/Entry/Game23600.csb",	Type="EasyGame",	Desc="扫雷"},		    --扫雷
    --自有游戏
    {ID=0,	Name="GameBCBM",	Path="Lobby/Entry/GameBCBM.csb",	Type="OfficialGame",Desc="奔驰宝马"},        --奔驰宝马    
}



function GameEspecialLayer:ctor(args)
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("client/res/Lobby/GUI/HallPlist.plist", "client/res/Lobby/GUI/HallPlist.png")
    -- spriteFrameCache:addSpriteFrames("client/res/Lobby/GUI/RoomList1.plist", "client/res/Lobby/GUI/RoomList1.png")
    spriteFrameCache:addSpriteFrames("client/res/Lobby/GUI/SceneEspecial1.plist", "client/res/Lobby/GUI/SceneEspecial1.png")
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

    self._enterGameFunc = args.enterGameFunc
    self.csbNode = g_ExternalFun.loadCSB("Lobby/SceneEspecial.csb")
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
        table.insert(self.gameItem,item)
        if v.Name== "GameBCBM" then   
            local btn = item:getChildByName("Button_1")
            btn:setSwallowTouches(false)
            btn:addTouchEventListener(function(sender,eventType)
                if eventType == ccui.TouchEventType.began then
                    this._touchMoveX = g_ExternalFun.ccpCopy(sender:getTouchBeganPosition()).x
                elseif eventType == ccui.TouchEventType.ended then
                local endPosX = g_ExternalFun.ccpCopy(sender:getTouchEndPosition()).x
                    if math.abs(endPosX - this._touchMoveX) <= g_ExternalFun.touchLength then
                        -- self:onClickGame(self._curGameIdTab[i])
                        showToast(g_language:getString("game_not_open"))                        
                    end
                end
            end)
        else
            local itemEffect = g_ExternalFun.loadTimeLine(v.Path)
            itemEffect:gotoFrameAndPlay(0, true)
            item:runAction(itemEffect)
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
            local pNU = item:getChildByName("NodeUpdate")
            local NodeUpdate = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.NodeUpdate")
            local pWidthUpdate = btn:getContentSize().width-28
            local pNodeUpdate = NodeUpdate:create(pWidthUpdate)
            pNodeUpdate:setMaskType(4)
            pNodeUpdate:addTo(item)
            pNodeUpdate:setPosition(pNU:getPosition())   
            pNodeUpdate:hide()         
            self.gameUpdateNode[v.ID] = pNodeUpdate

            local onlineNode = item:getChildByName("FileNode_online")
            if v.Type == "EasyGame" then
                --[[
                item:setColor(cc.c3b(127,127,127))
                item:stopAllActions()
                --]]
                onlineNode:hide()
            else
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
function GameEspecialLayer:adjustPanelSize()
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
function GameEspecialLayer:EaseShow(callback)
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

    local callback = callback
    if  self.GiftStatus and GlobalData.ProductsOver and GlobalData.GiftEnable and GlobalData.PayInfoOver and not GlobalData.TodayPay and GlobalData.First3Times>0 then                    
        callback = function ()
            GlobalData.First3Times = GlobalData.First3Times - 1
            local pData = {
                ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
            }
            G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
        end
    end
    
    --游戏列表
    --单个节点操作 370 
    local pItemX = {230,600,970,1340,1710,2080,2450,2820,3190,3560,3930}    
    local pWidth = display.width    
    local pWidth  = self.ScrollView_1:getContentSize().width
    for i, v in ipairs(self.gameItem) do
        v:setPositionX(pItemX[i]+pWidth)        
        TweenLite.to(v,pCostTime+(i-1)*pDeltaTime,{ x=pItemX[i],ease = Cubic.easeInOut,onComplete = (i==5) and callback or nil})        
    end
end

--缓出
function GameEspecialLayer:EaseHide(callback)    
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

function GameEspecialLayer:onUpdateUserInfo()    
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

function GameEspecialLayer:onClickClose()
    local callback = function()
        if self.quitCallback then
            self.quitCallback()
        end
        self:removeSelf()
    end
    self:EaseHide(callback)
end

function GameEspecialLayer:onClickGame(pData)
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
        if self._curGameId == 520 or self._curGameId == 407 or self._curGameId == 803 or self._curGameId == 901 then
            local desc = self._curGameId == 520 and "大闹天宫" or "李逵劈鱼"
            local pData = {
                gameId = self._curGameId
            }
            G_event:NotifyEvent(G_eventDef.UI_SHOW_ROOMLISTLAYER,pData)
            return
        end

        if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
            showNetLoading()   --点击游戏
            local _Index = 1  --默认选第一个房间    
            local roomInfo = GlobalUserItem.GetServerRoomByGameKind(self._curGameId)
            if roomInfo == nil or roomInfo[_Index] == nil then
                showToast(g_language:getString("game_not_open"))  --服务端游戏末启动
                return
            end
            for i=1,#roomInfo do
                if roomInfo[i].bOnline == true then
                    _Index = i  --房间在线才能进
                end
            end
            local ext_json = {gameId = self._curGameId,roomId = roomInfo[_Index].roomMark}
            EventPost:addCommond(EventPost.eventType.PV,"点击进入小游戏",_Index - 1,nil,ext_json)
            G_event:NotifyEvent(G_eventDef.UI_START_GAME,{roomMark = roomInfo[_Index].roomMark,quickStart = false})   
        else
            -- showNetLoading() 
            local pData = {
                gameId = self._curGameId,
            }
            G_event:NotifyEvent(G_eventDef.UI_SHOW_SELECTROOMLAYER,pData)
            -- G_event:NotifyEvent(G_eventDef.UI_ENTER_GAME_DUOREN,{subGameId = self._curGameId})
        end
    end
end
function GameEspecialLayer:onGameKindExit()
    self:removeSelf()
end
function GameEspecialLayer:OnUpdateDownProgress(args)
    local node = self.gameUpdateNode[args.gameId]
    if not node then return end
    node:show()
    node:setUpdatePercent(args.percent)
end
function GameEspecialLayer:OnUpdateDownSuccess(args)
     local node = self.gameUpdateNode[args.gameId] 
     if node then
         node:hide()
     end
     if self._updateInfo[args.gameId] then
         self._updateInfo[args.gameId].down = false
     end
end

function GameEspecialLayer:onExtraClick()
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

return GameEspecialLayer