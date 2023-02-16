---------------------------------------------------
--Desc:街机场选择界面
--Date:2022-09-06 14:57:56
--Author:A*
---------------------------------------------------
local GameJieJiLayer = class("GameJieJiLayer",function(args)
	local GameJieJiLayer =  display.newLayer()
    return GameJieJiLayer
end)

function GameJieJiLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT)
    G_event:RemoveNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_PROGRESS)
    G_event:RemoveNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_SUCCESS)
end

function GameJieJiLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    
    self.quitCallback = args.quitCallback
    self._updateInfo = args.updateInfo or {}
    self._curGameIdTab = GlobalData.SubGameId[args.kind]
    self._tabGameListInfo = args.gameInfo or {}

    self.csbNode = g_ExternalFun.loadCSB("UI/SceneJieJi.csb")
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

    --TC币
    self.PanelTC = self.PanelRightCenter:getChildByName("Panel_TC")    
    self.txtTC = self.PanelTC:getChildByName("TCValue")
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        self.PanelTC:hide()
    else
        self.PanelTC:show()
    end

    --设置玩家信息
    self:onUpdateUserInfo()
    local GameList = {
        {"GamePlinko","UI/Game/GamePlinko.csb"},      --Plinko
        {"GameTMFK","UI/Game/GameTMFK.csb"},      --甜蜜富矿
        {"GameBXNW","UI/Game/GameBXNW.csb"},      --冰雪女王
        {"GameCSD","UI/Game/GameCSD.csb"},      --财神到
        {"GameJNH","UI/Game/GameJNH.csb"},      --嘉年华
        {"GameEgito","UI/Game/GameEgito.csb"},      --埃及拉霸
        {"GameJXLW","UI/Game/GameJXLW.csb"},      --九线拉王
        {"GameBLCS","UI/Game/GameBLCS.csb"},      --秘鲁传说
        {"Game97QH","UI/Game/Game97QH.csb"},      --97拳皇
        {"GameSHZ","UI/Game/GameSHZ.csb"},         --水浒传        
    }
    self.gameItem = {}
    self.gameUpdateNode = {}
    local this = self
    for i, v in ipairs(GameList) do
        local item = self.ScrollView_1:getChildByName(v[1])
        local itemEffect = g_ExternalFun.loadTimeLine(v[2])
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
                   self:onClickGame(self._curGameIdTab[i])
               end
            end
        end) 
        local pNU = item:getChildByName("NodeUpdate")
        local NodeUpdate = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.NodeUpdate")
        local pWidthUpdate = btn:getContentSize().width-87
        local pNodeUpdate = NodeUpdate:create(pWidthUpdate)
        pNodeUpdate:addTo(item)
        pNodeUpdate:setPosition(pNU:getPosition())   
        pNodeUpdate:hide()         
        self.gameUpdateNode[self._curGameIdTab[i]] = pNodeUpdate
        local onlineNode = item:getChildByName("FileNode_online")
        local panle = onlineNode:getChildByName("Panel_online")
        local onlineText = panle:getChildByName("text_onlineCount")
        g_onlineCount:regestOnline(self._curGameIdTab[i],onlineText)

        --热门 新游
        local pStatus = GlobalData.StatusConfig[self._curGameIdTab[i]]
        local pNodeStatus = item:getChildByName("NodeStatus")
        if pStatus and pNodeStatus and not tolua.isnull(pNodeStatus) then
            local pNodeStatusHot = pNodeStatus:getChildByName("Hot")
            pNodeStatusHot:setVisible(pStatus==1)
            local pNodeStatusNew = pNodeStatus:getChildByName("New")    
            pNodeStatusNew:setVisible(pStatus==2)
        end
    end
    self:EaseShow()
    g_ExternalFun.stopMusic()
    G_event:AddNotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT,handler(self,self.onGameKindExit))
    G_event:AddNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_PROGRESS,handler(self,self.OnUpdateDownProgress))  --下载进度更新
    G_event:AddNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_SUCCESS,handler(self,self.OnUpdateDownSuccess))  --下载进度更新
end
--适配性调整Panel大小
function GameJieJiLayer:adjustPanelSize()
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
function GameJieJiLayer:EaseShow(callback)
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

    local callback
    if GlobalData.NoticeGift and GlobalData.PayInfoOver and not GlobalData.TodayPay then
        callback = function ()
            GlobalData.NoticeGift = false
            local pData = {
                ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
            }
            G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
        end
    end
    
    --游戏列表
    --单个节点操作
    local pItemX = {230,590,950,1310,1670,2030,2390,2750,3110,3470}    
    local pWidth = display.width    
    local pWidth  = self.ScrollView_1:getContentSize().width
    for i, v in ipairs(self.gameItem) do
        v:setPositionX(pItemX[i]+pWidth)        
        TweenLite.to(v,pCostTime+(i-1)*pDeltaTime,{ x=pItemX[i],ease = Cubic.easeInOut,onComplete = (i==#self.gameItem) and callback or nil})        
    end
end

--缓出
function GameJieJiLayer:EaseHide(callback)    
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

function GameJieJiLayer:onUpdateUserInfo()    
    --更新财富值
	local str = g_format:formatNumber(GlobalUserItem.lUserScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
	self.txtCoin:setString(str)

    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        return
    end
    --更新TC值    
    if self.txtTC and not tolua.isnull(self.txtTC) then
        local strTC = g_format:formatNumber(GlobalUserItem.lTCCoin,g_format.fType.abbreviation,g_format.currencyType.TC)
        self.txtTC:setString(strTC)
    end
end

function GameJieJiLayer:onClickClose()
    local callback = function()
        if self.quitCallback then
            self.quitCallback()
        end
        self:removeSelf()
    end
    self:EaseHide(callback)
end

function GameJieJiLayer:onClickGame(gameKind)
    self._curGameId = gameKind
    if self._updateInfo[self._curGameId].down == true then   --需要下载
        G_event:NotifyEvent(G_eventDef.UI_GAME_UPDATE,{subGameId = self._curGameId})
        self:OnUpdateDownProgress({gameId = self._curGameId,percent=0})
    else        
        local pData = {
            gameId = gameKind,
        }
        G_event:NotifyEvent(G_eventDef.UI_SHOW_ROOMLISTLAYER,pData)
    end
end

function GameJieJiLayer:onGameKindExit()
    self:removeSelf()
end
function GameJieJiLayer:OnUpdateDownSuccess(args)
     local node = self.gameUpdateNode[args.gameId] 
     if node then
         node:hide()
     end
     if self._updateInfo[args.gameId] then
         self._updateInfo[args.gameId].down = false
     end
end
function GameJieJiLayer:OnUpdateDownProgress(args)
    local node = self.gameUpdateNode[args.gameId]
    if not node then return end
    node:show()
    node:setUpdatePercent(args.percent)
end

return GameJieJiLayer