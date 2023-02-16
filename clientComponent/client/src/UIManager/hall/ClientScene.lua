
local ClientScene = class("ClientScene", cc.load("mvc").ViewBase)

local director = cc.Director:getInstance()
local textureCache = director:getTextureCache()
local g_scheduler = director:getScheduler()

local GameFrameEngine = appdf.req(appdf.CLIENT_SRC.."NetProtocol.GameFrameEngine")
local GameUpdate = appdf.req(appdf.BASE_SRC.."app.controllers.ClientUpdate")  --游戏更新相关
local SubLayerJump = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.SubLayerJump")
local WWNodeEx = appdf.req(appdf.CLIENT_SRC.."Tools.WWNodeEx")
local delayShowActTag = 1111

ClientScene.EntryConfig = {
    {"HallActivity","UI/Hall/NodeActivity.csb"},--活动轮播图
    {"TypeJieji","UI/Hall/TypeJieji.csb"},    --街机类
    {"TypeBairen","UI/Hall/TypeBairen.csb"},    --百人类
    {"TypeBuyu","UI/Hall/TypeBuyu.csb"},    --捕鱼类
    {"HallTruco2","UI/Hall/HallTruco2.csb"},    --Truco
    {"HallCrash","UI/Hall/HallCrash.csb"},     --Crash    
    {"HallDouble","UI/Hall/HallDouble.csb"},    --Double
}

ClientScene.RightBottomEntry = {
    {704,"HallFrutas","shuiguo.json"},
    {525,"HallJXLW","777.json"},
    {532,"HallBXNW","bingxue.json"},
}

-- 进入场景而且过渡动画结束时候触发。
function ClientScene:onEnterTransitionFinish()
    g_ExternalFun.playPlazzBackgroudAudio()
    return self
end
-- 退出场景而且开始过渡动画时候触发。
function ClientScene:onExitTransitionStart()
    return self
end

function ClientScene:onEnter( ... )
	ClientScene.super.onEnter(self)
end

function ClientScene:onExit()
    G_ServerMgr:CloseToSocket()
	removebackgroundcallback()
    self:StopAllTimer()
    self:onRemoveListen()
    SubLayerJump:onRemoveListen()
    GlobalData.ReceiveRoomSuccess = false
	return self
end
-- 初始化界面
function ClientScene:onCreate()
	local this = self
	setbackgroundcallback(function (bEnter)
		if type(self.onBackgroundCallBack) == "function" then
			self:onBackgroundCallBack(bEnter)
		end
	end)
    self:onInitData()
    G_GameFrame:setViewFrame(self)
    G_GameFrame:setCallBack(function (code,result)
		this:onRoomCallBack(code,result)
	end)	
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。			
			self:onEnterTransitionFinish()			
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
		elseif eventType == "exit" then
			self:onExit()
        elseif eventType == "enter" then
			self:onEnter()   
		end
	end)
    self.clientLayer = display.newLayer()
    self:addChild(self.clientLayer)

    local csbNode = g_ExternalFun.loadCSB("UI/SceneHall.csb")
    
    --背景spine
    local spineBg = csbNode:getChildByName("spineBg")
    spineBg:show()
    local skeletonBg = sp.SkeletonAnimation:create("client/res/spine/datingchangjing.json", "client/res/spine/datingchangjing.atlas", 1)
    skeletonBg:addAnimation(0, "daiji", true)    
    skeletonBg:setPosition(0,0)
    spineBg:addChild(skeletonBg)

    self.content = csbNode:getChildByName("content")
    csbNode:setContentSize(display.width,display.height)
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)        
    self.clientLayer:addChild(csbNode)    
    self.scene = csbNode
    
    --水波纹 移除
    -- local rippleLayer = CCCreateRippleLayer("GUI/Hall/dating_beijingtu_bg.png",16)
    -- local panelBg = self.content:getChildByName("PanelBG")
    -- panelBg:setContentSize(display.size)
    -- panelBg:setSwallowTouches(false)
    -- panelBg:addChild(rippleLayer)

    --左上
    self.PanelLeftTop = self.content:getChildByName("PanelLeftTop")
    --左中
    self.PanelLeftCenter = self.content:getChildByName("PanelLeftCenter")
    --左下
    self.PanelLeftBottom = self.content:getChildByName("PanelLeftBottom")
    --右上
    self.PanelRightTop = self.content:getChildByName("PanelRightTop")
    --右中
    self.PanelRightCenter = self.content:getChildByName("PanelRightCenter")
    --右下
    self.PanelRightBottom = self.content:getChildByName("PanelRightBottom")

    --适配性调整Panel大小
    self:adjustPanelSize()

    --左中
    -- Avatar
    local NodeAvatar = self.PanelLeftCenter:getChildByName("NodeAvatar")
    NodeAvatar:show()
    local skeletonNode = sp.SkeletonAnimation:create("client/res/spine/juese.json", "client/res/spine/juese.atlas", 1)
    skeletonNode:addAnimation(0, "daiji", true)      
    skeletonNode:setPosition(0,0)
    NodeAvatar:addChild(skeletonNode)
    
    --左上 金币增加TC币 进行区分
    local pNodeUserInfo = self.PanelLeftTop:getChildByName("NodeUserInfo")
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        pNodeUserInfo = pNodeUserInfo:getChildByName("Panel_2")
    else
        pNodeUserInfo = pNodeUserInfo:getChildByName("Panel_1")
    end
    self.imgHead = pNodeUserInfo:getChildByName("imgHead")    
    self.imgHead:onClicked(function()        
        -- G_event:NotifyEvent(G_eventDef.UI_OPEN_USERINFOLAYER)  --头像
        G_event:NotifyEvent(G_eventDef.UI_OPEN_SETLAYER) --设置
    end)
    self.txtCoin = pNodeUserInfo:getChildByName("goldValue")
    self.txtName = pNodeUserInfo:getChildByName("nick")     
    self.txtTC = pNodeUserInfo:getChildByName("TCValue")
    self.btnTCBg = pNodeUserInfo:getChildByName("TCBg")
    if self.btnTCBg and not tolua.isnull(self.btnTCBg) then
        self.btnTCBg:onClicked(function ()
            if GlobalData.TCIndex > 0 then
                G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_ACTIVITY,{scene = self,Index=GlobalData.TCIndex})                
            end
        end)
    end
    pNodeUserInfo:getChildByName("goldAdd"):onClicked(function() 
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
    pNodeUserInfo:show()
 
    --礼包中心
    self.NodeGift = self.PanelLeftTop:getChildByName("NodeGift")
    local pAction = g_ExternalFun.loadTimeLine("UI/Hall/NodeGift.csb")
    pAction:gotoFrameAndPlay(0,true)
    self.NodeGift:runAction(pAction)    
    local pSpine = self.NodeGift:getChildByName("spine_1") 
    self.NodeGiftPercentBg = self.NodeGift:getChildByName("wordBg")
    self.NodeGiftPercentBg:hide()
    self.NodeGiftPercent = self.NodeGiftPercentBg:getChildByName("libaorukou_6_3"):getChildByName("word_1")
    
    local pSpineEffect = sp.SkeletonAnimation:create("spine/lingbaotubiao.json","spine/lingbaotubiao.atlas", 1)
    pSpineEffect:addTo(pSpine)
    pSpineEffect:setPosition(0, 0)
    pSpineEffect:setAnimation(0, "daiji", true)
    
    self.NodeGift:getChildByName("Button_1"):onClicked(function()  
        local pData = {
            ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
        }
        G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)        
    end)
    self.NodeGift:setVisible(GlobalData.GiftEnable)  
  
    --每日分享
    self.NodeShare = self.PanelLeftTop:getChildByName("NodeShare")
    self.NodeShare:getChildByName("Button_1"):onClicked(function() 
        G_ServerMgr:S2C_UpdateShareCount()
        G_event:NotifyEvent(G_eventDef.UI_SHOW_SHARE,self)   
    end)
    local pAction = g_ExternalFun.loadTimeLine("UI/Hall/NodeShare.csb")
    pAction:gotoFrameAndPlay(0, true)
    self.NodeShare:runAction(pAction)
    self.NodeShare:hide()

    --破产补助
    self.NodeBankrupt = self.PanelLeftTop:getChildByName("NodeBankrupt")
    self.NodeBankrupt:getChildByName("Button_1"):onClicked(function() 
        G_event:NotifyEvent(G_eventDef.UI_SHOW_BASEENSURE,self)   
    end)
    local pAction = g_ExternalFun.loadTimeLine("UI/Hall/NodeBankrupt.csb")
    pAction:gotoFrameAndPlay(0, true)
    self.NodeBankrupt:runAction(pAction)
	self.NodeBankrupt:hide()

    --手机绑定按钮
    self.NodeBinding = self.PanelLeftTop:getChildByName("NodeBinding")
    self.NodeBinding:getChildByName("Button_1"):onClicked(handler(self,self.onAuthClick))    
    self.NodeBinding:hide()
    local pSpine = self.NodeBinding:getChildByName("spine_1") 
    local pAction = sp.SkeletonAnimation:create("spine/renzheng_tubiao.json","spine/renzheng_tubiao.atlas", 1)
    pAction:addTo(pSpine)
    pAction:setAnimation(0, "daiji", true) 
    local pAction = g_ExternalFun.loadTimeLine("UI/Hall/NodeBinding.csb")
    pAction:gotoFrameAndPlay(0,true)
    self.NodeBinding:runAction(pAction)    
    
    self.NodeBindingValueBg = self.NodeBinding:getChildByName("wordBg")
    self.NodeBindingValueBg:hide()
    self.NodeBindingValue = self.NodeBindingValueBg:getChildByName("content"):getChildByName("word_1")
    
    --左下
    --商店
    local NodeShop = self.PanelLeftBottom:getChildByName("NodeShop")
    local NodeShopEffect = g_ExternalFun.loadTimeLine("UI/Hall/NodeShop.csb")
    NodeShopEffect:gotoFrameAndPlay(0, true)
    NodeShop:runAction(NodeShopEffect)
    self.NodeShop = NodeShop
    self.NodeShop:hide()
    self.btnShop = NodeShop:getChildByName("Button_1")
    self.btnShop:onClicked(function()
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

    --每日签到
    self.btnDaily = self.PanelLeftBottom:getChildByName("btnDaily")
    self.btnDailyTips = self.btnDaily:getChildByName("Tips")    
    self.btnDailyTips:show()
    self.btnDailyTips:setOpacity(0)
    self.btnDaily:onClicked(function()
        G_event:NotifyEvent(G_eventDef.UI_SHOW_HALLSIGNLAYER)
    end)
    self.btnDaily:hide()
    --银行
    self.btnBank = self.PanelLeftBottom:getChildByName("btnBank")  
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
    else
        g_redPoint:addRedPoint(g_redPoint.eventType.bank,self.btnBank,cc.p(-5,5))
    end  
    
    self.btnBank:onClicked(function()
        if GlobalData.FirstOpenBank == true then
            GlobalData.BankSelectType = 1
            if GlobalUserItem.cbInsureEnabled == 0 then
                G_event:NotifyEvent(G_eventDef.UI_OPEN_BANKLAYER)  --开通
            else
                G_event:NotifyEvent(G_eventDef.UI_LOGON_BANKLAYER)  --登录
            end
            return
        end
        -- G_event:NotifyEvent(G_eventDef.UI_SHOW_BANKLAYER)
        if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then 
            G_event:NotifyEvent(G_eventDef.UI_SHOW_BANKLAYER)
        else
            G_event:NotifyEvent(G_eventDef.UI_SHOW_BANKLAYER_NEW)            
        end
    end)
    self.btnBank:hide()
    --排行榜
    self.btnRank = self.PanelLeftBottom:getChildByName("btnRank")
    self.btnRank:onClicked(function()
        G_event:NotifyEvent(G_eventDef.UI_OPEN_RANKLAYER)
    end)
    self.btnRank:hide()
    --俱乐部
    self.btnClub = self.PanelLeftBottom:getChildByName("btnClub")
    g_redPoint:addRedPoint(g_redPoint.eventType.club,self.btnClub,cc.p(-2,5))
    self.btnClub:onClicked(function()
        G_ServerMgr:C2S_requestMemberOrder()
    end)
    self.btnClub:hide()
    --任务
    self.btnTask = self.PanelLeftBottom:getChildByName("btnTask")
    g_redPoint:addRedPoint(g_redPoint.eventType.task,self.btnTask,cc.p(5,5))
    self.btnTask:onClicked(function()        
        G_event:NotifyEvent(G_eventDef.UI_SHOW_HALLTASKLAYER,{scene = self})
    end)
    self.btnTask:hide()
    --提现
    self.btnWithdraw = self.PanelLeftBottom:getChildByName("btnWithdraw")    
    self.btnWithdraw:onClicked(function()
        G_event:NotifyEvent(G_eventDef.UI_OPEN_CASHOUTLAYER)
    end)
    self.btnWithdraw:hide()

    --邮件
    self.btnEmail = self.PanelLeftBottom:getChildByName("btnEmail")
    --邮件红点
    g_redPoint:addRedPoint(g_redPoint.eventType.mail,self.btnEmail,cc.p(-5,5))
    self.btnEmail:onClicked(function()        
        G_event:NotifyEvent(G_eventDef.UI_OPEN_EMAILLAYER)
    end)
    self.btnEmail:hide()

    --根据项目自适应调整左下方按钮以及位置尺寸
    self:adjustLeftBottomByProject()
    ccui.Helper:doLayout(self.scene)

    --右上
    --设置
    self.btnSetting = self.PanelRightTop:getChildByName("btnSetting")
    self.btnSetting:onClicked(function()
        G_event:NotifyEvent(G_eventDef.UI_OPEN_SETLAYER)          
    end)
    --客服
    self.btnCustomer = self.PanelRightTop:getChildByName("btnCustomer")
    self.btnCustomer:onClicked(function()
        G_event:NotifyEvent(G_eventDef.UI_OPEN_SERVICELAYER)
    end)

    --检测游戏更新状态
    self:CheckGameUpdataStatus()
        
    --右中
    --活动轮播节点
    self.HallActivity = self.PanelRightCenter:getChildByName("HallActivity")
    self.ActivityPageView = self.HallActivity:getChildByName("ActivityPageView")
    self.gameItem = {}
    --更新节点
    self.gameUpdateNode = {}
    for i, v in ipairs(self.EntryConfig) do
        local pNodeGame = self.PanelRightCenter:getChildByName(v[1])
        local pNodeGameEffect = g_ExternalFun.loadTimeLine(v[2])
        pNodeGameEffect:gotoFrameAndPlay(0, true)
        pNodeGame:runAction(pNodeGameEffect)
        table.insert(self.gameItem,pNodeGame)
        local pButton1 = pNodeGame:getChildByName("Button_1")
        pButton1:onClicked(function()
            self:onClickGame(i)
        end)

        if type(GlobalData.EntryConfig[i])=="number" then
            --属于游戏
            local pNU = pNodeGame:getChildByName("NodeUpdate")
            local NodeUpdate = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.NodeUpdate")
            local pWidthUpdate = pButton1:getContentSize().width-32
            if GlobalData.EntryConfig[i] == 901 then
                pWidthUpdate = pWidthUpdate - 33
            end
            local pNodeUpdate = NodeUpdate:create(pWidthUpdate)
            pNodeUpdate:addTo(pNodeGame)
            pNodeUpdate:setPosition(pNU:getPosition())
            pNodeUpdate:hide()         
            self.gameUpdateNode[GlobalData.EntryConfig[i]] = pNodeUpdate    
            local onlineNode = pNodeGame:getChildByName("FileNode_online")
            local panle = onlineNode:getChildByName("Panel_online")
            local onlineText = panle:getChildByName("text_onlineCount")
            g_onlineCount:regestOnline(GlobalData.EntryConfig[i],onlineText)

            --热门 新游
            local pStatus = GlobalData.StatusConfig[GlobalData.EntryConfig[i]]
            local pNodeStatus = pNodeGame:getChildByName("NodeStatus")
            if pStatus and pNodeStatus and not tolua.isnull(pNodeStatus) then
                local pNodeStatusHot = pNodeStatus:getChildByName("Hot")
                pNodeStatusHot:setVisible(pStatus==1)
                local pNodeStatusNew = pNodeStatus:getChildByName("New")    
                pNodeStatusNew:setVisible(pStatus==2)
            end
            
        -- else
        --     local onlineNode = pNodeGame:getChildByName("TextOnlineCount")  
        --     g_onlineCount:regestOnline(i-1,onlineNode)
        end        
    end

    --右下  
    for i, v in ipairs(self.RightBottomEntry) do
        local pNodeGame = self.PanelRightBottom:getChildByName(v[2])
        --spine
        local pAction = sp.SkeletonAnimation:create("spine/"..v[3],"spine/youxirukou.atlas",1)
        pAction:addTo(pNodeGame)
        pAction:setAnimation(0, "daiji", true) 
        --点击响应
        local pButton1 = pNodeGame:getChildByName("Button_1")
        pButton1:onClicked(function()            
            self:hall2RoomList(v[1])
        end)
        --热更进度条
        local pNU = pNodeGame:getChildByName("NodeUpdate")
        local NodeUpdate = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.NodeUpdate")
        local pWidthUpdate = pButton1:getContentSize().width        
        local pNodeUpdate = NodeUpdate:create(pWidthUpdate)
        pNodeUpdate:addTo(pNodeGame)
        pNodeUpdate:setPosition(pNU:getPosition())
        pNodeUpdate:hide()         
        self.gameUpdateNode[v[1]] = pNodeUpdate 
    end
    
    self:onUpdateHallInfo()
    self:onAddEventListen()
    tickMgr:delayedCall(handler(self,self.CompatibleNewUI),500)


    local pCallback = function ()
        self:ShowNextNotice(true)
        -- G_ServerMgr:C2S_RequestOnlineUserInfo()
    end
    self:EaseShow(pCallback)

end

--适配性调整Panel大小
function ClientScene:adjustPanelSize()
    --左中指导性尺寸
    self.LeftCenterMin = 720
    self.LeftCenterMax = 1025
    --右中指导性尺寸，最小支持
    self.RightCenterMin = 1200
    --右下指导性尺寸，最小支持
    self.RightBottomMin = 660
    --左中比例
    self.LeftCenterPercent = 720/1920

    --获取屏幕宽度
    local pWidth = display.width
    if pWidth <= 1920 then
        --屏幕宽度小于设计尺寸
        --左中走最小尺寸
        self.PanelLeftCenter:setContentSize(cc.size(self.LeftCenterMin,1000))
        --右中走最小尺寸
        self.PanelRightCenter:setContentSize(cc.size(self.RightCenterMin,620))
        --右下走最小尺寸
        self.PanelRightBottom:setContentSize(cc.size(self.RightBottomMin,210))
    else
        --屏幕宽度超过设计尺寸
        local pAbelLeftCenterWidth = math.min(pWidth*self.LeftCenterPercent,self.LeftCenterMax)        
        local pExtraRightCenterWidth = (pWidth - pAbelLeftCenterWidth - self.RightCenterMin)*0.7
        local pAbleRightCenterWidth = pExtraRightCenterWidth + self.RightCenterMin
        self.PanelLeftCenter:setContentSize(cc.size(pWidth-pAbleRightCenterWidth,1000))        
        self.PanelRightCenter:setContentSize(cc.size(pAbleRightCenterWidth,620))
        local pAbleRightBottomWidth = pExtraRightCenterWidth + self.RightBottomMin
        self.PanelRightBottom:setContentSize(cc.size(pAbleRightBottomWidth,210))        
    end    
end

--根据版本自适应左下方区域尺寸位置
function ClientScene:adjustLeftBottomByProject()
    local pDeltaSingle = 0
    --金币项目展示按钮
    local pLeftBottomBtns = {
        self.NodeShop,--商城
        self.btnDaily,--签到
        self.btnBank,--银行
        -- self.btnRank,--排行榜 先关闭
        self.btnClub,--俱乐部
        self.btnTask,--任务
        self.btnEmail,--邮件
    }
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then        
        pLeftBottomBtns = {
            self.NodeShop,--商城
            self.btnDaily,--签到
            self.btnBank,--银行            
            self.btnTask,--任务
            self.btnWithdraw,--提现
            self.btnEmail,--邮件
        }
    end
    local pWidth = 0
    local pHeight = self.PanelLeftBottom:getContentSize().height
    for i, v in ipairs(pLeftBottomBtns) do
        v:show()
        local pEachWidth = i==1 and 230 or v:getContentSize().width        
        v:setPositionX(pWidth + pEachWidth/2+(i-1)*pDeltaSingle)
        pWidth = pWidth + pEachWidth        
    end
    pWidth = pWidth + #pLeftBottomBtns*pDeltaSingle
    self.PanelLeftBottom:setContentSize(cc.size(pWidth,83))
end

--缓入
function ClientScene:EaseShow(callback)
    local func = function() 
        self:onEaseFinishCallback()
        if callback then
            callback()
        end
    end

    self:onEnterTransitionFinish()
    local pCostTime = 0.3
    local pDeltaTime = 0.07
    local pAllCost = pCostTime+7*pDeltaTime
    --左上
    self.PanelLeftTop:setPositionY(display.height+200)
    TweenLite.to(self.PanelLeftTop,pAllCost,{ y=display.height,ease = Cubic.easeInOut})
    --左中
    local pSize = self.PanelLeftCenter:getContentSize()
    self.PanelLeftCenter:setPositionX(0-pSize.width)
    -- self.PanelLeftCenter:setPositionX(0-200)
    TweenLite.to(self.PanelLeftCenter,pAllCost,{ x=0,ease = Cubic.easeInOut})

    --左下
    self.PanelLeftBottom:setPositionY(0-200)
    TweenLite.to(self.PanelLeftBottom,pAllCost,{ y=0,ease = Cubic.easeInOut})
    --右上
    self.PanelRightTop:setPositionY(display.height+150)
    TweenLite.to(self.PanelRightTop,pAllCost,{ y=display.height,ease = Cubic.easeInOut})
    --右中
    --单个节点操作
    local pItemX = {356.5,127,358.5,590,944,944,944}
    local pWidth  = self.PanelRightCenter:getContentSize().width
    for i, v in ipairs(self.gameItem) do
        v:setPositionX(pItemX[i]+pWidth)        
        TweenLite.to(v,pCostTime+(i-1)*pDeltaTime,{ x=pItemX[i],ease = Cubic.easeInOut,onComplete = (i==#self.gameItem) and func or nil})        
    end
    --右下
    self.PanelRightBottom:setPositionY(-210)
    TweenLite.to(self.PanelRightBottom,pAllCost,{ y=0,ease = Cubic.easeInOut})
    self.LastIndex = nil
end

--缓出
function ClientScene:EaseHide(callback)
    local pCostTime = 0.3
    local pDeltaTime = 0.07
    local pAllCost = pCostTime+7*pDeltaTime
    --左上    
    TweenLite.to(self.PanelLeftTop,pAllCost,{ y=display.height+200,ease = Cubic.easeInOut})
    --左中
    local pSize = self.PanelLeftCenter:getContentSize()    
    TweenLite.to(self.PanelLeftCenter,pAllCost,{ x=0-pSize.width-100,ease = Cubic.easeInOut})
    --左下    
    TweenLite.to(self.PanelLeftBottom,pAllCost,{ y=-200,ease = Cubic.easeInOut})
    --右上    
    TweenLite.to(self.PanelRightTop,pAllCost,{ y=display.height+150,ease = Cubic.easeInOut})
    --右中
    --单个节点操作
    -- local pItemX = {358.5,127,358.5,590,944,944,825,1060}
    local pItemX = {356.5,127,358.5,590,944,944,944}
    local pWidth  = self.PanelRightCenter:getContentSize().width
    local pItemIndex = 1
    for i=#self.gameItem,1,-1 do
        TweenLite.to(self.gameItem[i],pCostTime+(pItemIndex-1)*pDeltaTime,{ x=pItemX[i]+pWidth,ease = Cubic.easeInOut,onComplete = (i==1) and callback or nil})
        pItemIndex = pItemIndex + 1
    end    
    --右下
    TweenLite.to(self.PanelRightBottom,pAllCost,{ y=-210,ease = Cubic.easeInOut})
end
--缓入完成触发
--pFlag false 跟随上一个
--pFlag true 重新走一遍
function ClientScene:ShowNextNotice(pFlag)

    if pFlag then
        self.CurrentIndex = 1
    else
        if not self.CurrentIndex then
            self.CurrentIndex = 1
        else
            self.CurrentIndex = self.CurrentIndex + 1
        end 
    end

    if self.CurrentIndex==1 then
    else
        if self.CurrentIndex == #self.NoticeConfig then            
            if not GlobalData.NoticeGift then
                return
            end
        else
            local pFirst = self:isTodayFirstNotice(self.CurrentIndex)
            if not pFirst then
                return
            end        
        end        
    end
    local pFunc = self.NoticeConfig[self.CurrentIndex]
    if pFunc then
        pFunc()
    end    
end

--该项是否当日首次弹窗（本地记录，跨天重新计算）
function ClientScene:isTodayFirstNotice(pIndex)    
    --判断系统消息显示是否当天第一次
    local pKey = "LastNoticeTime_"..GlobalUserItem.dwUserID.."_"..pIndex
    local pLastNoticeTime = cc.UserDefault:getInstance():getIntegerForKey(pKey,0)
    local pDate = os.date("*t",pLastNoticeTime)
    local pToday = os.date("*t",os.time())
    --判定是否跨天
    if pToday.year ~= pDate.year or pToday.month ~= pDate.month or pToday.day ~= pDate.day then
        cc.UserDefault:getInstance():setIntegerForKey(pKey,os.time())
        cc.UserDefault:getInstance():flush()
        return true
    else
        G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)
        return false
    end
end

--1.检测卡场
function ClientScene:onCheckLockGame()
    if GlobalUserItem.dwLockKindID ~= 0 then  --处理锁游戏
        local scheduler = cc.Director:getInstance():getScheduler()
        -- 跳转到锁游戏中
        if GlobalData.ReceiveRoomSuccess then
            local localKindID = GlobalUserItem.dwLockKindID  --dwLockServerKindID
            GlobalUserItem.dwLockKindID = 0
            if self.schedulerID then
                scheduler:unscheduleScriptEntry(self.schedulerID)
                self.schedulerID = nil
            end
            G_event:NotifyEvent(G_eventDef.UI_START_GAME,{roomMark = GlobalUserItem.roomMark,quickStart = false})   
        else            
            self.schedulerID = nil
            self.schedulerID = scheduler:scheduleScriptFunc( function()
                self:onCheckLockGame()
                -- 定时器执行的函数
            end , 1, false)
        end
    else
        G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)    
    end
end

--2.引导弹框系统提示
function ClientScene:onGetSystemNoticeInfo()    
    G_ServerMgr:C2S_GetSystemNotice()
end

--3.绑定手机提示
function ClientScene:onCheckBinding()
    if GlobalUserItem.szSeatPhone and  string.len(GlobalUserItem.szSeatPhone) > 0 then
        G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)   
    else        
        self:onAuthClick(true)
    end 
    
end

--4.活动界面 新货币介绍
function ClientScene:onShowTCActivity()
    if GlobalData.TCIndex > 0 then
        G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_ACTIVITY,{scene = self,Index=GlobalData.TCIndex,NoticeNext = true})                
    end
end

--5.礼包推荐
function ClientScene:onShowGiftCenter()    
    if GlobalData.GiftEnable and GlobalData.PayInfoOver and not GlobalData.TodayPay then
        GlobalData.NoticeGift = false        
        local pData = {
            ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
            NoticeNext = true
        }
        G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
    else
        G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)
    end
end

--6.请求每日签到
-- pFlag true:同步签到开关 false:
function ClientScene:onQueryDailySign(pFlag)
    G_ServerMgr:C2S_QueryCheckIn()
end

--7.俱乐部引导
function ClientScene:onShowClubGuide()
    --是否弹出clubguidelayer
    if GlobalUserItem.dwAgentID == 0 then
        G_event:NotifyEvent(G_eventDef.UI_OPEN_CLUBGUIDELAYER,{NoticeNext = true})
    else
        G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)
    end
end

--8.推荐游戏引导
function ClientScene:onShowRecommend()    
    local gameInfo = {}
    local update = {}
    for i,v in pairs(GlobalData.RecommendGameID) do
        update[v] = {}
        update[v].down = self:GetSubGameStutes(v)
        update[v].downstatus = self:GetSubGameDownStutes(v)  --下载状态
        gameInfo[v] = GlobalUserItem.GetServerRoomByGameKind(v) or {}
    end
    
    local pData = {                
        gameInfo = gameInfo,
        updateInfo = update,
    }
    --引导玩家的 推荐玩法列表
    G_event:NotifyEvent(G_eventDef.UI_SHOW_HALLRECOMMENDLAYER,pData)
end

--每次进入大厅缓动完成执行
function ClientScene:onEaseFinishCallback()
    G_ServerMgr:C2S_RequestRedData()     --获取红点数据
    G_ServerMgr:C2S_GetMailCount()     --请求：邮件领取数量
end

function ClientScene:onInitData()
	--保存进入的游戏记录信息
	GlobalUserItem.m_tabEnterGame = nil
    self._switchCurTime = 0
    self._switchGameCount = 0
    self._timeCount = 0
    -- self._last_gameId = 0
    self._gameList = self:getApp()._gameList
    self._gameDownList = {}  --管理游戏下载列表
    self._gameReconnectFunc = nil  --重连回调
    self.m_timerEvent = {}
    self.onlineTime = 0
    self._requestSugTimeId = g_scheduler:scheduleScriptFunc(function(dt) 
       self:onUpdate(dt)              
    end,1,false)  
    self.CurrentIndex = 1
    self.NoticeConfig = {
        --1.检测卡场
        handler(self,self.onCheckLockGame),
        --2.检查系统提示信息
        handler(self,self.onGetSystemNoticeInfo),
        --3.绑定手机提示
        --handler(self,self.onCheckBinding),
        --4.活动界面 新货币介绍         
        handler(self,self.onShowTCActivity),
        --5.礼包推荐
        handler(self,self.onShowGiftCenter),        
    } 
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        self.NoticeConfig = {
            --1.检测卡场
            handler(self,self.onCheckLockGame),
            --2.检查系统提示信息
            handler(self,self.onGetSystemNoticeInfo),
            --3.绑定手机提示
            --handler(self,self.onCheckBinding),            
            --5.礼包推荐
            handler(self,self.onShowGiftCenter),
        }
    end

    local info = {
        url = "https://ifconfig.me/ip",
        callback = function(ok,response) 
            print("myIp = ",response)
            GlobalData.MyIP = response 
        end
    }
    http.get(info)
end


function ClientScene:onClickGame(index)     
    local pConfig = GlobalData.EntryConfig[index]
    
    if pConfig and type(pConfig)=="number" then
        self:hall2RoomList(pConfig)      --房间分类
    elseif pConfig and type(pConfig)=="table" then
        self:hall2GameList(index-1)
        self.LastIndex = index    
    end
end

--大厅直接进游戏或房间
function ClientScene:hall2RoomList(gameId)
    local args = {}
    args.subGameId = gameId
    local isUpdate = self:GetSubGameStutes(gameId)
    if isUpdate then
        self:OnUpdateDownProgress(gameId,0)
        self:SubGameUpdate(args)  --更新
    else
        if not self:onCheckRoomList() then return end   --没有收到房间列表
        GlobalData.HallClickGame = true
        if gameId == 704 or gameId == 803 or gameId == 525 or gameId == 532 then --甜蜜富矿,--Truco,--JXLW,--BXNW
            local pData = {
                gameId = gameId,
            }
            G_event:NotifyEvent(G_eventDef.UI_SHOW_ROOMLISTLAYER,pData)
        else  --百人
            if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
                showNetLoading()            
                self:onSubDuoRenEnterGame(args)
            else
                local pData = {
                    gameId = gameId,
                }
                G_event:NotifyEvent(G_eventDef.UI_SHOW_SELECTROOMLAYER,pData)
            end
        end
    end
end

--大厅进入游戏分类
function ClientScene:hall2GameList(index)  
    GlobalData.HallClickGame = false  
    local gameInfo = {}
    local update = {}
    for i,v in pairs(GlobalData.SubGameId[index]) do
        update[v] = {}
        update[v].down = self:GetSubGameStutes(v)
        update[v].downstatus = self:GetSubGameDownStutes(v)  --下载状态
        gameInfo[v] = GlobalUserItem.GetServerRoomByGameKind(v) or {}
    end
    local quitCallback = function()
        self:EaseShow()
    end
    self:EaseHide(function()
        dismissNetLoading()
        local pData = {
            kind = index,
            gameInfo = gameInfo,
            updateInfo = update,
            quitCallback = quitCallback,
            enterGameFunc = self.onSubDuoRenEnterGame
        }
        G_event:NotifyEvent(G_eventDef.UI_ONCLICK_GAMEKIND,pData)
    end)
    showNetLoading()
end
function ClientScene:onCheckHallDownStatus()
    for i,v in pairs(GlobalData.HallGameId) do
        if self:GetSubGameDownStutes(v)[1] then
            self:OnUpdateDownProgress(v,self:GetSubGameDownStutes(v)[2] or 0)
        end
    end
end
function ClientScene:onCheckRoomList()
    if GlobalData.ReceiveRoomSuccess == false then
        G_ServerMgr:C2S_RequestGameRoomInfo(0,true)
        showToast(g_language:getString("get_room_info"))
        return false
    end
    return true
end

function ClientScene:onAuthClick(pNoticeNext)
    local callback = function() 
        -- self.NodeBinding:hide()
        -- self:adjustLeftTopByProject()
        --查询绑定手机状态
        G_ServerMgr:C2S_GetBindMobileStatus()
    end
    if GlobalData.BindingInfo.boBind==0 then
        --打开绑定
        G_event:NotifyEvent(G_eventDef.UI_SHOW_MESSAGE,{callback = callback,NoticeNext = pNoticeNext,ShowType = 1})
    else
        if GlobalData.BindingInfo.boReward==0 then
            --领取奖励
            G_ServerMgr:C2S_GetBindMobileReward(GlobalData.MyIP)
        else
            self.NodeBinding:hide()
        end
    end
end

function ClientScene:CompatibleNewUI()
    uiMgr:setCurScene(cc.Director:getInstance():getRunningScene(),"ClientScene")
    --获取房间列表
    G_ServerMgr:C2S_RequestGameRoomInfo()
    --获取活动列表
    G_ServerMgr:C2S_GetActivityConfig()    
    --获取推荐玩法
    G_ServerMgr:C2S_RequestRecommendList()
    --获取商品列表
    G_ServerMgr:C2S_GetProductInfos()
    --获取客服配置
    G_ServerMgr:C2S_GetCustomService()
    --获取每日分享配置
    G_ServerMgr:C2S_GetShareConfig()
    --拉取破产补助配置
    G_ServerMgr:C2S_QueryBaseEnsure()
    --查询签到
    G_ServerMgr:C2S_QueryCheckIn()
    --查询绑定手机状态
    G_ServerMgr:C2S_GetBindMobileStatus()

    self:addTimerEvent("MarqueeTimer",6,function() 
        --执行了回调，获取跑马灯数据
        g_MarqueeMgr:onRequestScrollMessage()
    end,false)

    self:addTimerEvent("onlineCount",67,function() 
        --执行了回调，刷新在线人数
        G_ServerMgr:C2S_RequestOnlineUserInfo()
    end,true,true)
    self:addTimerEvent("updateGold",30,function() 
        --执行了回调，刷新金币
        G_ServerMgr:C2S_RequestUserGold()
    end,true)

    self:addTimerEvent("serverTimer",600,function() 
        --获取服务器时间 时区跨天校验
        G_ServerMgr:C2S_requestServerTime()
    end,true,true)

    self:addTimerEvent("redPoint",30,function() 
        --获取红点数据
        G_ServerMgr:C2S_RequestRedData() 
        G_ServerMgr:C2S_GetMailCount()     --请求：邮件领取数量
    end,false,true)

    self:addTimerEvent("getLastPayInfo",30,function() 
        --定时查询充值信息
        G_ServerMgr:C2S_GetLastPayInfo()
    end,true,true)
    
end
function ClientScene:onAddEventListen()
    SubLayerJump:onAddEventListen()
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_NETWORK_ERROR,handler(self,self.NetworkError))
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_USER_SCORE_REFRESH,handler(self,self.onUpdateUserScore))
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_CONNECT_SUCCESS,handler(self,self.onNetConnectSuccess))
    G_event:AddNotifyEvent(G_eventDef.UI_SWITCH_ACCOUNT,handler(self,self.ExitClient))
    G_event:AddNotifyEvent(G_eventDef.NET_NEED_RELOGIN,handler(self,self.NeedLogin))
    G_event:AddNotifyEvent(G_eventDef.NET_LOGON_ROOM_FAILER,handler(self,self.LogonFailer))
    G_event:AddNotifyEvent(G_eventDef.NET_MODIFY_FACE_SUCCESS,handler(self,self.UpdateHead))
    G_event:AddNotifyEvent(G_eventDef.UI_GAME_UPDATE,handler(self,self.SubGameUpdate))  --游戏更新
    G_event:AddNotifyEvent(G_eventDef.UI_ENTER_GAME_INFO,handler(self,self.UpdateEnterGameInfo))   --保存进入的游戏信息
    G_event:AddNotifyEvent(G_eventDef.UI_START_GAME,handler(self,self.GoStartGame))
    G_event:AddNotifyEvent(G_eventDef.UI_EXIT_TABLE,handler(self,self.GameExitTable))
    G_event:AddNotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER,handler(self,self.RemoveGameLayer))
    G_event:AddNotifyEvent(G_eventDef.UI_ENTER_GAME_DUOREN,handler(self,self.onSubDuoRenEnterGame))
    G_event:AddNotifyEvent(G_eventDef.UI_CONNECT_SUCCESS,handler(self,self.onDismissReconnect))
    G_event:AddNotifyEvent(G_eventDef.NET_QUERY_CHECKIN,handler(self,self.onQuerySignInData))   --查询签到数据
    G_event:AddNotifyEvent(G_eventDef.NET_QUERY_ORDER_NO_RESULT,handler(self,self.onQueryOrdersNoData))   --历史充值成功订单信息返回
    G_event:AddNotifyEvent(G_eventDef.NET_CLUBMEMBERORDER,handler(self,self.onAgentMemberOrder))   --俱乐部身份
    G_event:AddNotifyEventTwo(self,G_eventDef.EVENT_FACE_URL_RESULT,handler(self,self.onGetUserUrl))   --个人头像信息
    G_event:AddNotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,handler(self,self.ShowNextNotice))     --下一个弹框事件
    G_event:AddNotifyEvent(G_eventDef.NET_PRODUCTS_RESULT,handler(self,self.ProductsResult))     --完成商品列表拉取事件
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_PRODUCTS_STATE_RESULT,handler(self,self.ProductsResult))   --同步商品表状态结果
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_GET_PRODUCT_ACTIVE_STATE_RESULT,handler(self,self.onProductActiveStateResult))   --同步一次性礼包状态结果
    G_event:AddNotifyEvent(G_eventDef.NET_QUERY_BASEENSURE,handler(self,self.onBaseEnsureCallback))     --低保配置参数返回 破产补助参数
    G_event:AddNotifyEvent(G_eventDef.UI_GET_SERVER_TIME,handler(self,self.onGetServerTime))   --获取服务器时间
    G_event:AddNotifyEvent(G_eventDef.EVENT_SHARE_CONFIG,handler(self,self.onShareConfigCallback))  --每日分享配置
    G_event:AddNotifyEvent(G_eventDef.EVENT_SCORE_LESS,handler(self,self.onUserScoreLess))  -- 金币不足处理
    G_event:AddNotifyEvent(G_eventDef.EVENT_SYSTEM_NOTICE_INFO,handler(self,self.onSystemNoticeInfo))  -- 系统提示信息
    G_event:AddNotifyEvent(G_eventDef.EVENT_HALL_ACTIVITY_DATA,handler(self,self.onHallActivityInfo))  -- 活动数据返回    
    G_event:AddNotifyEvent(G_eventDef.UI_CLIENT_SCENE_AUTH,handler(self,self.onAuthClick))     --响应绑定手机
    G_event:AddNotifyEvent(G_eventDef.EVENT_BIND_MOBILE_STATUS,handler(self,self.onBindPhoneStatus))  -- 绑定手机状态
    G_event:AddNotifyEvent(G_eventDef.EVENT_BIND_MOBILE_REWARD,handler(self,self.onBindPhoneResult))  -- 绑定手机结果        
    G_event:AddNotifyEvent(G_eventDef.EVENT_HALL_LAST_PAY_INFO_DATA,handler(self,self.onGetLastPayResult))   --查询最后一次充值订单信息返回数据
end
function ClientScene:onRemoveListen()
    G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_NETWORK_ERROR)
    G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_USER_SCORE_REFRESH)
    G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_CONNECT_SUCCESS)
    G_event:RemoveNotifyEvent(G_eventDef.UI_SWITCH_ACCOUNT)
    G_event:RemoveNotifyEvent(G_eventDef.NET_NEED_RELOGIN)
    G_event:RemoveNotifyEvent(G_eventDef.NET_LOGON_ROOM_FAILER)
    G_event:RemoveNotifyEvent(G_eventDef.NET_MODIFY_FACE_SUCCESS)
    G_event:RemoveNotifyEvent(G_eventDef.UI_GAME_UPDATE)
    G_event:RemoveNotifyEvent(G_eventDef.UI_ENTER_GAME_INFO)
    G_event:RemoveNotifyEvent(G_eventDef.UI_START_GAME)
    G_event:RemoveNotifyEvent(G_eventDef.UI_EXIT_TABLE)
    G_event:RemoveNotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)
    G_event:RemoveNotifyEvent(G_eventDef.UI_GAME_ROOM_BACK)
    G_event:RemoveNotifyEvent(G_eventDef.UI_ENTER_GAME_DUOREN)
    G_event:RemoveNotifyEvent(G_eventDef.UI_CONNECT_SUCCESS)
    G_event:RemoveNotifyEvent(G_eventDef.NET_QUERY_CHECKIN)
    G_event:RemoveNotifyEvent(G_eventDef.NET_QUERY_ORDER_NO_RESULT)    
    G_event:RemoveNotifyEvent(G_eventDef.NET_CLUBMEMBERORDER)
    G_event:RemoveNotifyEventTwo(self,G_eventDef.EVENT_FACE_URL_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)
    G_event:RemoveNotifyEvent(G_eventDef.NET_PRODUCTS_RESULT)
    G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_PRODUCTS_STATE_RESULT)
    G_event:RemoveNotifyEventTwo(G_eventDef.NET_GET_PRODUCT_ACTIVE_STATE_RESULT)    
    G_event:RemoveNotifyEvent(G_eventDef.NET_QUERY_BASEENSURE)
    G_event:RemoveNotifyEvent(G_eventDef.UI_GET_SERVER_TIME)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_SHARE_CONFIG)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_SCORE_LESS)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_SYSTEM_NOTICE_INFO)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_HALL_ACTIVITY_DATA)
    G_event:RemoveNotifyEvent(G_eventDef.UI_CLIENT_SCENE_AUTH)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_BIND_MOBILE_STATUS)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_BIND_MOBILE_REWARD)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_HALL_LAST_PAY_INFO_DATA) 
end

function ClientScene:onNetConnectSuccess()
    self:stopActionByTag(delayShowActTag)
end

--网络错误
function ClientScene:NetworkError(args)
    -- dump(args, "ClientScene:NetworkError", 10)
    print("ClientScene:NetworkError args.code = ",args.code)
    if not args or not args.code then return end
    if args.code == 1 then  --断开大厅
        self:NeedLogin()
    end
    if args.code == 2 then  --断开游戏
        if self._gameReconnectFunc and type(self._gameReconnectFunc) == "function" then  
            showNetLoading()
            self._gameReconnectFunc()
            self._gameReconnectFunc = nil
            self:stopAllActions()
        else            
            if tolua.cast(self._gamelayer,"cc.layer") then
                --10S内限定三次
                --超限则提示网络异常
                local pReconnectTimes = cc.UserDefault:getInstance():getIntegerForKey("ReConnectTimes",0)                
                local pLastTime = cc.UserDefault:getInstance():getIntegerForKey("ReConnectTime",0)
                local pCurrentTime = os.time()
                if pCurrentTime - pLastTime > 10 then                    
                    pReconnectTimes = 0
                end
                pReconnectTimes = pReconnectTimes + 1
                if pReconnectTimes <=3 then
                    cc.UserDefault:getInstance():setIntegerForKey("ReConnectTimes",pReconnectTimes)
                    cc.UserDefault:getInstance():setIntegerForKey("ReConnectTime",pCurrentTime)
                    cc.UserDefault:getInstance():flush()                    
                    -- G_GameFrame:onCloseSocket()
                    -- performWithDelay(self,function()
                        self:onShowLoading()                        
                        G_GameFrame:OnResetGameEngine()
                        self:onStartGame() 
                    -- end,1)
                else
                    dismissNetLoading()
                    showToast(g_language:getString("network_timeout"))   
                end
            end        
        end
    end
    if args.code == 3 then  --断开游戏，自动重连
        --延迟1.0s展示
        local action = cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function ()
            showNetLoading()
        end))
        action:setTag(delayShowActTag)
        self:runAction(action)
    end
    if args.code == 4 then  --收到0-6消息，客户端主动发起重连
        self:onShowLoading()
        G_GameFrame:OnResetGameEngine()
		self:onStartGame()
    end
end

--需要重新登录
function ClientScene:NeedLogin()
    performWithDelay(self,function()self:ExitClient()end,2)
    showToast(g_language:getString("game_disconnect"))
end
--登录失败
function ClientScene:LogonFailer(args)
    dismissNetLoading()
    if args.errorCode == 1 then  
        showToast(g_language:getString("system_kicktout")) 
        performWithDelay(self,function()self:ExitClient()end,2)      
    end
    if args.errorCode == 3 then  --账号在其他地方登录
        showToast(g_language:getString("account_already_login")) 
        performWithDelay(self,function()self:ExitClient()end,2)      
    end
    if args.errorCode == 20 then  --体验场时间到
         showToast(g_language:getString("game_free_time")) 
    end
end
function ClientScene:onDismissReconnect()
    dismissNetLoading()
    onDismissReconnect()
    self:stopAllActions()
end
function ClientScene:StopAllTimer()
    if self._requestSugTimeId then
         g_scheduler:unscheduleScriptEntry(self._requestSugTimeId)
    end
    self._requestSugTimeId = nil
end
function ClientScene:onUpdateHallInfo()
    if GlobalUserItem.wFaceID == 0 and false then
        if not HeadSprite.isFileNamePath(GlobalUserItem.dwUserID .. ".png") then
            G_ServerMgr:C2S_requestHeadUrl({GlobalUserItem.dwUserID})
        else
            self:UpdateHead(nil,nil,GlobalUserItem.dwUserID .. ".png")
        end
    else
        self:UpdateHead()
    end
    local pLength = 90
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        pLength = 160
    end
    local nameStr,isShow = g_ExternalFun.GetFixLenOfString(GlobalUserItem.szNickName,pLength,"arial",24)
    self.txtName:setString(isShow and nameStr or nameStr.."...")
	self:UpdateMoney()  
end
function ClientScene:onUpdate(dt)

    local isGame = false
    if tolua.cast(self._gamelayer,"cc.layer") then
        isGame = true
    else
        isGame = false    
    end

    
    for k,v in pairs(self.m_timerEvent) do
        if isGame == false then
            -- print("在大厅中")
            if self.isLastGame == true and v.isGamePause == true then
                --设置了游戏不轮询，从游戏出来马上执行一次
                -- print("从游戏出来的，执行回调")
                v.curTime = v.delayTime
                if v.callback then
                    v.callback()
                end
            else
                -- print("大厅正常轮询")
                v.curTime = v.curTime - 1
                if v.curTime <= 0 then
                    v.curTime = v.delayTime
                    if v.callback then
                        v.callback()
                    end
                end
            end
        else
            -- print("在游戏中")
            if v.isGamePause == false then
                -- print("设置了游戏开启了轮询，游戏中正常轮询")
                v.curTime = v.curTime - 1
                if v.curTime <= 0 then
                    v.curTime = v.delayTime
                    if v.callback then
                        v.callback()
                    end
                end
            end
        end
    end
    self.isLastGame = isGame
end
--
function ClientScene:addTimerEvent(eventName,delayTime,callback,isGamePause,isInstant)
    self.m_timerEvent[eventName] = {}
    self.m_timerEvent[eventName].eventName = eventName                   --轮询事件名
    self.m_timerEvent[eventName].delayTime = delayTime or 1              --轮询时间
    self.m_timerEvent[eventName].callback = callback                    --回调
    self.m_timerEvent[eventName].curTime = delayTime                     --轮询时间进度
    self.m_timerEvent[eventName].isGamePause = isGamePause or false      --进游戏了是否暂停轮询
    if isInstant then
        callback()
    end
end

function ClientScene:removeTimerEvent(eventName)
    self.m_timerEvent[eventName] = {}
end

--全局货币更新
function ClientScene:onUpdateUserScore(args)
    self:UpdateMoney()
    --通知到银行界面
    G_event:NotifyEvent(G_eventDef.UI_BANK_UPDATE_GOLD,args)
end
--货币回调
function ClientScene:UpdateMoney()
    --更新Gold值
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
function ClientScene:UpdateHead()    
    self.headImg = HeadSprite.loadHeadImg(self.imgHead,GlobalUserItem.dwGameID,GlobalUserItem.wFaceID,true)
end

function ClientScene:onGetUserUrl(data)
    local items = data.userData
    if items[GlobalUserItem.dwGameID] then
        HeadSprite.loadHeadUrl(self.headImg,GlobalUserItem.dwGameID,items[GlobalUserItem.dwGameID])
    end
end

function ClientScene:UpdateNickName()
    local nameStr,isShow = g_ExternalFun.GetFixLenOfString(GlobalUserItem.szNickName,160,"arial",24)
    self.txtName:setString(isShow and nameStr or nameStr.."...")
end

function ClientScene:onBackgroundCallBack(bEnter)
	if not bEnter then
        if g_TargetPlatform == cc.PLATFORM_OS_WINDOWS then
             g_ExternalFun.pauseMusic()
        end
		print("onBackgroundCallBack not bEnter")
        if tolua.cast(self._gamelayer,"cc.layer") then
            if self._gamelayer.enterBackground then
                self._gamelayer:enterBackground()
            end
        	G_GameFrame:onCloseSocket()
            self._switchCurTime = os.time()
            self._switchGameCount = self._switchGameCount + 1
        end
        self._gameReconnectFunc = nil
	else
		print("onBackgroundCallBack  bEnter")
        if g_TargetPlatform == cc.PLATFORM_OS_WINDOWS and GlobalUserItem.bVoiceAble then
             g_ExternalFun.resumeMusic()
        end
        local callback = function()
            showToast(g_language:getString("system_kicktout"))
            if self._gamelayer.onExitRoom then
                self._gamelayer:onExitRoom()
            else
                self:RemoveGameLayer()
            end
        end
        if tolua.cast(self._gamelayer,"cc.layer")  then
            if self._switchGameCount >= 5 or (self._switchCurTime ~= 0 and os.time() - self._switchCurTime > 30) then
                callback()
            else
                if self._gamelayer.enterForeground then
                    self._gamelayer:enterForeground() --进入前台	
                end
                self._gameReconnectFunc = function()
                    G_GameFrame:OnResetGameEngine()
			        self:onStartGame()
                end
                performWithDelay(self,function()
                    if self._gameReconnectFunc and type(self._gameReconnectFunc) == "function" then
                       self._gameReconnectFunc()
                       self._gameReconnectFunc = nil
                    end
                end,1)
            end
        end       
       G_ServerMgr:C2S_RequestUserGold()
	end
end

--触发重连的处理
function ClientScene:onRoomCallBack(code,message)
    if code ~= -5 then
        dismissNetLoading()
    else   
        message = ""
    end
	if message then
        if code == -1 and message == "登录房间失败:请退出大厅重新登录" then
            message = g_language:getString("game_disconnect")
            performWithDelay(self,function()self:ExitClient()end,2)
        end
        showToast(message)
	end
    if code == -1 then
        self:onDismissReconnect()
    end
end
function ClientScene:onReQueryFailure(code, msg)
	if nil ~= msg and type(msg) == "string" then
		showToast(msg)
	end
    dismissNetLoading()
end

function ClientScene:onEnterRoom()
	--如果是快速游戏
	local entergame = self:getEnterGameInfo()
    if self.m_bQuickStart == false and nil ~= entergame then
        self.m_bQuickStart = true
    end
	if self.m_bQuickStart and nil ~= entergame then
		self.m_bQuickStart = false
		local t,c = G_NetCmd.INVALID_TABLE,G_NetCmd.INVALID_CHAIR
		-- 找桌
		local bGet = false
		for k,v in pairs(G_GameFrame._tableStatus) do
			if v.cbTableLock == 0 and v.cbPlayStatus == 0 then
				local st = k - 1
				local chaircount =G_GameFrame._wChairCount
				for i = 2, chaircount  do					
					local sc = i - 1
					if nil == G_GameFrame:getTableUserItem(st, sc) then
						t = st
						c = sc
						bGet = true
						break
					end
				end
			end
			if bGet then
				break
			end
		end
		print( " fast enter " .. t .. " ## " .. c.."  "..entergame._KindID)
        if not (entergame._KindID == 100) then
		    if G_GameFrame:SitDown(t,c) then
		    end
        end
	else
        self:RemoveGameLayer()  --移除游戏界面，关闭socket
        if G_GameFrame then
           G_GameFrame:onCloseSocket()
        end
        if self._layer_loading then
           self._layer_loading:setVisible(false)
           if self._loadNode then 
              self._loadNode:stopAllActions()
           end
        end
	end
end

function ClientScene:onGetTableInfo()
    local entergame = self:getEnterGameInfo()
    tdump(entergame, "ClientScene:onGetTableInfo", 10)
    if not entergame or entergame._KindID ~= 100 then return end
	local t,c = G_NetCmd.INVALID_TABLE,G_NetCmd.INVALID_CHAIR
	-- 找桌
	local bGet = false
	for k,v in pairs(G_GameFrame._tableStatus) do
		-- 未锁 未玩		
		if v.cbTableLock == 0 then
			local st = k - 1
			local chaircount = G_GameFrame._wChairCount
			for i = 3, chaircount  do					
				local sc = i - 1
				if nil == G_GameFrame:getTableUserItem(st, sc) then
					t = st
					c = sc
					bGet = true
					break
				end
			end
		end
		if bGet then
			break
		end
	end
    if G_GameFrame:SitDown(t,c) then
    end
end

function ClientScene:onEnterTable()
	--进入游戏
	local entergame = self:getEnterGameInfo()
    tdump(entergame, 'ClientScene:onEnterTable', 10)
	if nil ~= entergame then
        if self._layer_loading then 
           self._layer_loading:setVisible(false)
        end
        if self._loadNode then 
           self._loadNode:stopAllActions()
        end
        dismissNetLoading()
        self.scene:setVisible(false)
        self:onEnterGameLayer(entergame._KindID)
        if not tolua.cast(self._gamelayer,"cc.layer") then
		    local modulestr = entergame._Module.."."
		    local gameScene = appdf.req(appdf.GAME_SRC.. modulestr .. "src.views.GameLayer")
		    if gameScene then
		         self._gamelayer = gameScene:create(G_GameFrame,self)
                 print(self)
                 self:addChild(self._gamelayer,3)	
                 G_GameFrame:setViewFrame(self._gamelayer)	
		    end
        else
            G_GameFrame:setViewFrame(self._gamelayer)	
        end
        if G_GameFrame._roomInfo.wSortID ==0 then   --体验场 
            if self._freeGameTimeId ~= nil then
                g_scheduler:unscheduleScriptEntry(self._freeGameTimeId)
            end
            self._freeGameTimeId = nil
            self._freeGameTimeId = g_scheduler:scheduleScriptFunc(function()
                if G_GameFrame and G_GameFrame:isSocketServer() then
                    G_GameFrame:StandUp(1)
                    G_GameFrame:onCloseSocket()
	            end
                self:RemoveGameLayer()
                self:LogonFailer({errorCode = 20})
            end,1200,false)            
        end
        GlobalData.CurEnterTableId = G_GameFrame:GetTableID()
        GlobalData.CurEnterChairId = G_GameFrame:GetChairID()
    else
        showToast(g_language:getString("game_info_null"))
    end
end

function ClientScene:onEnterGameLayer(GameKindID)
    G_event:NotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT)
    G_event:NotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT_2)
    local isOldGame = false
    for i,v in pairs(GlobalData.OldGameID) do
        if GameKindID == v then
            isOldGame = true
            break
        end
    end
    if isOldGame then   --老游戏
         self:onOldDesignResolution()
    else
         self:onDesignResolution()    
    end

end

function ClientScene:onOldDesignResolution()
    g_MarqueeMgr:fitDesignResolution(true)
    tlog('ClientScene:onOldDesignResolution')
      ylAll.WIDTH								= 1334
      ylAll.HEIGHT								= 750
      appdf.WIDTH							    = 1334
      appdf.HEIGHT								= 750
      g_offsetX = 0
      local resoultion = {
          width = 1334,
          height = 750,
          autoscale = "EXACT_FIT",
      }
     display.setAutoScale(resoultion)   
    --游戏中退出需要重置一次挂件位置
    if cc.exports.msgBoxNode and not tolua.isnull(cc.exports.msgBoxNode) and cc.exports.msgBoxNode.fitDesignResolution then
        cc.exports.msgBoxNode:fitDesignResolution()
    end
end
function ClientScene:onDesignResolution()    
    tlog('ClientScene:onDesignResolution')
    ylAll.WIDTH								= 1920
    ylAll.HEIGHT							= 1080
    appdf.WIDTH							    = 1920
    appdf.HEIGHT							= 1080
    local scaleY = g_FrameSize.height / appdf.HEIGHT
    local acWidth = math.floor(g_FrameSize.width / scaleY)
    if acWidth > appdf.WIDTH then
        g_offsetX = (acWidth - appdf.WIDTH)/2
    end  
    local resoultion = {
        width = 2340,
        height = 1080,
        autoscale = "FIXED_HEIGHT",
    }
    display.setAutoScale(resoultion)
    --游戏中退出需要重置一次挂件位置
    if cc.exports.msgBoxNode and not tolua.isnull(cc.exports.msgBoxNode) and cc.exports.msgBoxNode.fitDesignResolution then
        cc.exports.msgBoxNode:fitDesignResolution()
    end
    g_MarqueeMgr:fitDesignResolution(false)
end

function ClientScene:onQuerySignInData()
    -- if not GlobalData.DailySign then
    --     G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)
    --     return
    -- end
    -- if GlobalUserItem.bTodayChecked == false then
    --     G_event:NotifyEvent(G_eventDef.UI_SHOW_HALLSIGNLAYER,{NoticeNext = true})
    -- else
    --     G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)
    -- end
end
--服务器时间戳
function ClientScene:onGetServerTime(data)
    -- dump(data)
    self.serverTime = data
    local UTCtime = os.date("!*t",self.serverTime.llServerTime)
    -- dump(UTCtime,"UTCtime")
    local _serverTime = self.serverTime.llServerTime + self.serverTime.dwZone*3600   --服务器时间戳 + 时区偏移 = 当前服务器所在位置的正确时间
    local localTime = os.date("!*t",_serverTime)
    -- dump(localTime,"localTime")
    GlobalData.serverTime = OSUtil.readFiles("serverTime")
    if GlobalData.serverTime == nil then
        GlobalData.serverTime = {}
        GlobalData.serverTime.today = localTime.year * 10000 + localTime.month * 100 + localTime.day
        GlobalData.serverTime.yesterday = GlobalData.serverTime.today
        self:updateLocalDB()
    else
        GlobalData.serverTime.today = localTime.year * 10000 + localTime.month * 100 + localTime.day
        if GlobalData.serverTime.yesterday < GlobalData.serverTime.today then
            --跨天了
            GlobalData.serverTime.yesterday = GlobalData.serverTime.today
            self:updateLocalDB()
        else
            --没跨天
            self:checkIsBankrupt()
        end
    end
    GlobalData.serverTime.llServerTime = data.llServerTime
    GlobalData.serverTime.dwZone = data.dwZone
    OSUtil.saveTable(GlobalData.serverTime,"serverTime")
end

--商品列表拉取完成事件
function ClientScene:ProductsResult()
    for i, v in ipairs(GlobalData.ProductInfos) do
        if v.byActive and v.szProductTypeName == "once" then
            G_ServerMgr:C2S_GetProductActiveState(v.dwProductTypeID)
            -- showNetLoading()
        end
    end

    if self and self.NodeGift and not tolua.isnull(self.NodeGift) then        
        self.NodeGift:setVisible(GlobalData.GiftEnable)
        if #self.NoticeConfig < self.CurrentIndex then
            if GlobalData.PayInfoOver then
                if GlobalData.NoticeGift and not GlobalData.TodayPay then
                    self:onShowGiftCenter()
                end
            end
        end
    end
    self:adjustLeftTopByProject()
end

--同步一次性商品列表状态结果
function ClientScene:onProductActiveStateResult()
    local pValue = 0
    for i, v in ipairs(GlobalData.ProductInfos) do
        if v.byActive and v.szProductTypeName ~= "shop" then
            for i2, v2 in ipairs(v.ProductInfos) do
                if v2.byAttachType == 2 then
                    local pC = nil
                    if v.szProductTypeName=="once" then
                        if GlobalData.ProductOnceState[i2]>0 then
                            pC = v2
                        end
                    else
                        pC = v2
                    end
                    if pC and pC.lAttachValue > pValue then
                        pValue = pC.lAttachValue
                    end                    
                end
            end
        end
    end
    if pValue == 0 then
        self.NodeGiftPercentBg:hide()
        self.NodeGiftPercent:setString("")
    else
        self.NodeGiftPercentBg:show()
        self.NodeGiftPercent:setString("+"..pValue.."%")
    end
end

--分享配置拉取完成
function ClientScene:onShareConfigCallback(data)
    self.m_shareConfig = data
    if data.byShareEnable == 0 then
        self.NodeShare:hide()
    else
        self.NodeShare:show()
    end
    self:adjustLeftTopByProject()
end


--手机绑定同步完成
function ClientScene:onBindingStatusCallback(data)
    --TODO    
    self:adjustLeftTopByProject()
end

--更新本地数据
function ClientScene:updateLocalDB()
    G_ServerMgr:C2S_QueryBaseEnsure()  --拉取破产补助配置
end

--破产补助配置回调
function ClientScene:onBaseEnsureCallback(data)
    dump(data,"baseEnsure")
    GlobalData.baseEnsureData = data
    GlobalData.baseEnsureData.MaxNumber = GlobalData.baseEnsureData.byRestTimes
    OSUtil.saveTable(GlobalData.baseEnsureData,"baseEnsure")
    self:checkIsBankrupt()
end

--读取本地破产补助配置
function ClientScene:loadBaseEnsureConfig()
    if not GlobalData.baseEnsureData then
        GlobalData.baseEnsureData = OSUtil.readFiles("baseEnsure")
    end
end

--检查是否破产
function ClientScene:checkIsBankrupt(isGame)
    self:loadBaseEnsureConfig()
    if not GlobalData.baseEnsureData then 
        return 
    end
    if GlobalData.baseEnsureData.byRestTimes > 0 and (GlobalUserItem.lUserScore + GlobalUserItem.lUserInsure) < GlobalData.baseEnsureData.lScoreCondition then
        self.NodeBankrupt:show()
        if isGame then
            --游戏退出打开领取页面
            G_event:NotifyEvent(G_eventDef.UI_SHOW_BASEENSURE,self) 
        end
    else        
        self.NodeBankrupt:hide()
    end
    self:adjustLeftTopByProject()
end

--动态调整左上部入口
function ClientScene:adjustLeftTopByProject()
    local pStartX = 520
    local pDeltaX = 190

    local pNodes = {
        self.NodeGift,
        self.NodeShare,
        self.NodeBinding,
        self.NodeBankrupt,
    }
    local pIndex = 0
    for i, v in ipairs(pNodes) do
        if v:isVisible() then
            v:setPositionX(pStartX + pIndex*pDeltaX)
            pIndex = pIndex + 1
        end
    end
end

--查询成功订单信息
function ClientScene:onQueryOrdersNoData(data)
    if data.info.len > 0 then
        if ylAll.firstData and ylAll.firstData.isopen then
            if ylAll.firstData.OrderNo == data.info.OrderNo and data.info.Status == 1 then
                local path = "client.src.UIManager.hall.subinterface.rewardLayer"
                local datatable = {}
                datatable.goldImg = ylAll.firstData.imagePath
                datatable.goldTxt = g_format:formatNumber(ylAll.firstData.curPayMoney,g_format.fType.standard)
                datatable.type = 2
                appdf.req(path).new(datatable)
            end
        end
        ylAll.firstData = nil
    else
        if self.ordersNoIndex >= 15 then
            --超过15次。终止
            return 
        end
        --回来没有数据，1秒后再请求一次
        performWithDelay(self,function()
            G_ServerMgr:C2S_RequestOrderNo(GlobalUserItem.dwUserID,GlobalUserItem.szDynamicPass,ylAll.firstData.OrderNo)
        end,1)
    end

    self.ordersNoIndex = self.ordersNoIndex + 1
end

function ClientScene:onAgentMemberOrder(data)
    --data.wMemberOrder   --身份：0普通，1会长，2.3 用于扩展
    GlobalUserItem.wInAgent = data.wInAgent
    local pData = {ShowType = 0}
    if data.wInAgent and data.wInAgent == 1 then
        pData.ShowType = 1
    else
        pData.ShowType = 0
    end
    G_event:NotifyEvent(G_eventDef.UI_OPEN_CLUBCENTERLAYER,pData)

    g_redPoint:dispatch(g_redPoint.eventType.clubSub_2,false)
end

--启动游戏
function ClientScene:onStartGame()
    printInfo("ClientScene:onStartGame ")
	local app = self:getApp()
	local entergame = self:getEnterGameInfo()
	if nil == entergame then
		showToast(g_language:getString("game_info_null"))
        dismissNetLoading()
		return
	end
    -- GlobalUserItem.nCurGameKind = tonumber(entergame._KindID)
	-- self:getEnterGameInfo().nEnterRoomIndex = GlobalUserItem.nCurRoomIndex
	G_GameFrame:onInitData()
    local kindID = g_ExternalFun.getKindID(GlobalUserItem.roomMark)
	G_GameFrame:setKindInfo(kindID, entergame._KindVersion)

	G_GameFrame:setViewFrame(self)
    G_GameFrame:onLogonRoom()
end

function ClientScene:onShowLoading()
    showNetLoading(function()
	    G_GameFrame:onCloseSocket()
        showToast(g_language:getString("network_timeout"))
    end)
end

--跑马灯更新
function ClientScene:onChangeNotify(msg)

end

function ClientScene:showPopWait()
end

function ClientScene:ExitClient()
    --当日充值状态是否已经获取完毕
    GlobalData.PayInfoOver = false
    --当日是否已经充值
    GlobalData.TodayPay = false
    --当前登录是否已经弹出礼包
    GlobalData.NoticeGiftYet = false
    --当前登录礼包是否可弹出
    GlobalData.NoticeGift = true
    --清理登录信息
    GlobalUserItem.SetLocalization()
    
	-- GlobalUserItem.nCurRoomIndex = -1
	self:UpdateEnterGameInfo(nil)
	self:getApp():enterSceneEx(appdf.BASE_SRC.."app.views.WelcomeScene","FADE",0)

	GlobalUserItem.reSetData()
	--读取配置
	GlobalUserItem.LoadData()    
end

--更新进入游戏记录
function ClientScene:UpdateEnterGameInfo(info)
    if info and type(info) == "table" then
        local gameId = info.gameId
        GlobalUserItem.m_tabEnterGame = self:GetGameInfoByGameId(gameId)
    else
	    GlobalUserItem.m_tabEnterGame = info
    end
end

function ClientScene:getEnterGameInfo(  )
	return GlobalUserItem.m_tabEnterGame
end

function ClientScene:SetCurClickGameInfo(info)
    self.curClickGameInfo = info
end

function ClientScene:SetGamePageIndex(index)
    GlobalUserItem.m_gamePageIndex = index
end

function ClientScene:GetGamePageIndex()
    return GlobalUserItem.m_gamePageIndex
end

--获取游戏信息
function ClientScene:getGameInfo(wKindID)
	for k,v in pairs(self:getApp()._gameList) do
		if tonumber(v._KindID) == tonumber(wKindID) then
			return v
		end
	end
	return nil
end
function ClientScene:GameExitTable()
    if tolua.cast(self._gamelayer,"cc.layer") then
       self._gamelayer:removeSelf()
       self._gamelayer = nil
    end 
	self:RemoveGameLayer()
end

function ClientScene:RemoveGameLayer()
    GlobalData.CurEnterTableId = G_NetCmd.INVALID_TABLE
    GlobalData.CurEnterChairId = G_NetCmd.INVALID_CHAIR
    -- local gameInfo = self:getEnterGameInfo()
    -- G_ServerMgr:C2S_RequestUserGold()
    if tolua.cast(self._gamelayer,"cc.layer") then
       self._gamelayer:removeSelf()
       self._gamelayer = nil
    end 
    self:onDesignResolution()
    self:checkIsBankrupt(true)
    textureCache:removeUnusedTextures()
    g_ExternalFun.stopAllEffects()
    self.scene:setVisible(true)    
    GlobalData.NoticeGift = true
    if GlobalData.HallClickGame then 
        local callback = function ()
            performWithDelay(self,function()
                GlobalData.NoticeGift = false
                if GlobalData.PayInfoOver and not GlobalData.TodayPay then            
                    local pData = {
                        ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
                    }
                    G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
                end
            end,0.5)
        end        
        self:EaseShow(callback)
        return  
    end
    if self.LastIndex then        
        self:onClickGame(self.LastIndex)
    end
end

function ClientScene:GoStartGame(args)
    GlobalUserItem.roomMark = args.roomMark
    local _gameId = g_ExternalFun.getKindID(args.roomMark)
    self:UpdateEnterGameInfo({gameId = _gameId})
    -- local roomIndex = args.roomIndex    
    -- if roomIndex then
    --     cc.UserDefault:getInstance():setIntegerForKey("LastRoomIndex",roomIndex)
    --     cc.UserDefault:getInstance():flush()
    --     GlobalUserItem.nCurRoomIndex = roomIndex
    -- end
    self.m_bQuickStart = args.quickStart
    self:onShowLoading()
    self._switchGameCount = 0
	self:onStartGame()
end

function ClientScene:roomEnterCheck()
	return true  --密码房，比赛房已去掉
end

--游戏更新相关
function ClientScene:CheckGameUpdataStatus()
    self._gameUpdateStutes = {}
    local resMgr = self:getApp():getVersionMgr()
    for i,v in pairs(self._gameList) do
	     local version = tonumber(resMgr:getResVersion(v._KindID))     
         local update = {}
         update.res = false
         update.zip = false
	     if not version or (version and v._ServerResVersion > version) then
             update.res = true
         end
         local len1 = string.find(v._Module,'/')
         local moduleName = string.sub(v._Module,len1+1, string.len(v._Module))
         local curModuleVersion = resMgr:getZipVersion(moduleName)
         local serverModuleVersion = ylAll.SERVER_UPDATE_DATA[moduleName.."_zip"] or 0
         if curModuleVersion ==nil or (curModuleVersion and serverModuleVersion and serverModuleVersion > curModuleVersion) then
             update.zip = true
         end
         self._gameUpdateStutes[v._KindID] = update
    end
end
function ClientScene:GetSubGameStutes(gameId)
    local isWin32 = (g_TargetPlatform == cc.PLATFORM_OS_WINDOWS)
    if ylAll.UPDATE_OPEN == false or isWin32 then 
        return false 
    end
    if self._gameUpdateStutes[gameId] then
        return self._gameUpdateStutes[gameId].res or self._gameUpdateStutes[gameId].zip
    end
    return false 
end

function ClientScene:GetSubGameDownStutes(gameId)
    if self._gameDownList[gameId] then 
       return {true,self._gameDownList[gameId].percent}
    end
    return {false,0}
end

function ClientScene:GetGameInfoByGameId(gameId)
    for i,v in pairs(self._gameList) do
       if tonumber(v._KindID) == gameId then
          return v
       end
    end 
    return nil
end

function ClientScene:UpperFirst(pString)
    return (pString:gsub("^%l",string.upper))
end

--更新
function ClientScene:SubGameUpdate(args)
    local gameId = args.subGameId
    if self._downgameinfo and self._downgameinfo._KindID == gameId then
        local pKingName = self:UpperFirst(self._downgameinfo._KindName)
        showToast("["..pKingName.."] "..g_language:getString("game_is_updating"))
    end
    if not self._gameDownList[gameId] then
        self._gameDownList[gameId] = self:GetGameInfoByGameId(gameId)
    end
    if self._downgameinfo ~= nil and self._downgameinfo._KindID ~= gameId then
        local pKingName = self:UpperFirst(self._gameDownList[gameId]._KindName)
        showToast("["..pKingName.."] "..g_language:getString("game_update_in"))
    end
    if self._downgameinfo == nil then  --当前末有下载任务
       self:StartUpdate(self._gameDownList[gameId])
    end
end
--检测下一个下载
function ClientScene:CheckNextGameDown()
    for i,v in pairs(self._gameDownList) do
        self:StartUpdate(v)
        return
    end
end
function ClientScene:StartUpdate(gameinfo)
    self._downgameinfo = gameinfo
    self._downgameid = gameinfo._KindID
	--更新参数
	local newfileurl = self:getApp()._updateUrl.."/game/"..self._downgameinfo._Module.."/res/filemd5List.json"
	local dst = device.writablePath .. "game/" .. "yule" .. "/"

	local src = device.writablePath.."game/"..self._downgameinfo._Module.."/res/filemd5List.json"
	local downurl = self:getApp()._updateUrl .. "/game/" .. "yule" .. "/"
	--创建更新
    local len1 = string.find(self._downgameinfo._Module,'/')
    local moduleName = string.sub(self._downgameinfo._Module,len1+1, string.len(self._downgameinfo._Module))
    local curModuleVersion = self:getApp()._version:getZipVersion(moduleName)
	self._update = GameUpdate:create(newfileurl,dst,src,downurl, moduleName,curModuleVersion)
	self._update:upDateClient(self)
end
function ClientScene:updateProgress(sub, msg, mainpercent)
    local status = self._gameUpdateStutes[self._downgameid]
    if status.zip == true and status.res == true then
        if mainpercent > 90 then
            mainpercent = 90
        end
    end
    if self.m_recordProgress and self.m_recordProgress >0 then  --记录zip的进度条
        mainpercent = self.m_recordProgress + mainpercent/10
    end
    if self._gameDownList[self._downgameid] then
        self._gameDownList[self._downgameid].percent = mainpercent
    end
    self:OnUpdateDownProgress(self._downgameid,mainpercent)
    G_event:NotifyEvent(G_eventDef.UI_RESOURCE_DOWN_PROGRESS,{gameId = self._downgameid,percent = mainpercent})
end
function ClientScene:upDateSuccessToUnzip(fileName,dst,moduleName,version)
    unZipAsync(cc.FileUtils:getInstance():fullPathForFilename(fileName),dst,function(result)
    		cc.FileUtils:getInstance():removeFile(fileName)
            version = version or 0
            self:getApp()._version:setZipVersion(version,moduleName)
            local gameId = self._downgameinfo._KindID
            self._gameUpdateStutes[gameId].zip = false
            if self._gameUpdateStutes[gameId].res == true then
                self.m_recordProgress = 90
                self:StartUpdate(self._downgameinfo)
            else
                self:updateResult(true,"")
            end
    	end)    
end

function ClientScene:updateResult(result,msg)
    local gameId = self._downgameinfo._KindID
	if result == true then
        self._gameUpdateStutes[gameId].zip = false    
        self._gameUpdateStutes[gameId].res = false  
		for k,v in pairs(self._gameList) do
			if v._KindID == self._downgameinfo._KindID then
				self:getApp():getVersionMgr():setResVersion(v._ServerResVersion, v._KindID)
				v._Active = true
				break
			end
		end
        local pKingName = self:UpperFirst(self._downgameinfo._KindName)
        showToast("["..pKingName.."] "..g_language:getString("game_install_success"))
        self:OnUpdateDownSuccess(gameId)
        G_event:NotifyEvent(G_eventDef.UI_RESOURCE_DOWN_SUCCESS,{gameId = gameId})
    else
        local pKingName = self:UpperFirst(self._downgameinfo._KindName)
        showToast("["..pKingName.."] "..g_language:getString("game_install_failed"))
    end
    self._gameDownList[gameId] = nil
    self._downgameinfo = nil
    self.m_recordProgress = nil
    self:CheckNextGameDown()  --检查是否有等待下载的
end

function ClientScene:OnUpdateDownProgress(gameId,percent)
     local node = self.gameUpdateNode[gameId] 
     if node then        
        node:show()
        node:setUpdatePercent(percent)
     end
end
function ClientScene:OnUpdateDownSuccess(gameId)
    local node = self.gameUpdateNode[gameId] 
    if node then
        node:hide()
    end
end

--多人类游戏
function ClientScene:onSubDuoRenEnterGame(args)
    dismissNetLoading()
    local _Index = 1  --默认选第一个房间    
    local roomInfo = GlobalUserItem.GetServerRoomByGameKind(args.subGameId)
    if roomInfo == nil or roomInfo[_Index] == nil then
        showToast(g_language:getString("game_not_open"))  --服务端游戏末启动
        return
    end
    self:GoStartGame({roomMark = roomInfo[_Index].roomMark,quickStart = true})
end

function ClientScene:onUserScoreLess(roomInfo)
    -- dump(roomInfo)
    -- local QueryDialog = appdf.req("client.src.UIManager.QueryDialogNew")
    local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")
    local dialog = QueryDialog:create(g_language:getString("score_less"),function(ok)
        dump(GlobalData.ProductInfos)
        --首充礼包还在
        if GlobalData.ProductInfos[1].byActive == true then
            local pData = {
                ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
            }
            G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData) 
            return
        end
        --没有首充礼包了
        if GlobalData.ProductInfos[2].byActive == true then
            if roomInfo.wSortID == 1 or roomInfo.wSortID == 3 then
                local pData = {
                    ShowType = 2,--展示礼包类型：1.首充 2.每日 3.一次性
                }
                G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData) 
                return
            end
        end
        
        if GlobalData.ProductInfos[3].byActive == true then
            if roomInfo.wSortID == 4 or roomInfo.wSortID == 5 then
                local pData = {
                    ShowType = 3,--展示礼包类型：1.首充 2.每日 3.一次性
                }
                G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData) 
                return
            end
        end
        
        G_event:NotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT)
        G_event:NotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT_2)
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
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(dialog)
    -- local size = cc.Director:getInstance():getWinSize()
    dialog:setPosition(cc.p(0,0))
end

function ClientScene:onSystemNoticeInfo(_cmdData)
    if _cmdData.pCount == 0 then
        G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)
    else
        G_event:NotifyEvent(G_eventDef.UI_OPEN_SYSTEM_NOTICE_LAYER, {cmdData = _cmdData, NoticeNext = true})
    end
end

function ClientScene:onHallActivityInfo()
    local Template = self.HallActivity:getChildByName("Template")
    Template:show()

    local TemplateIndex = self.HallActivity:getChildByName("TemplateIndex")
    TemplateIndex:hide()

    self.ActivityIndexList = self.HallActivity:getChildByName("ActivityIndexList")
    self.ActivityIndexList:removeAllItems()
    

    self.ActivityPageView:removeAllPages()
    if GlobalData.ActivityInfos then
        if #GlobalData.ActivityInfos==0 then        
        elseif #GlobalData.ActivityInfos==1 then
            Template:hide()
            for i, v in ipairs(GlobalData.ActivityInfos) do
                local pItem = Template:clone()
                pItem:show()                
                pItem:setTag(i)
                pItem:onClicked(handler(self,self.onPageClicked))                
                self.ActivityPageView:addPage(pItem)
            end
        elseif #GlobalData.ActivityInfos>1 then
            Template:hide()
            for i = 0, #GlobalData.ActivityInfos+1 do
                local pItem = Template:clone()
                pItem:show()
                if i == 0 then
                    pItem:setTag(#GlobalData.ActivityInfos)
                elseif i == #GlobalData.ActivityInfos+1 then                    
                    pItem:setTag(1)
                else
                    pItem:setTag(i)
                end    
                pItem:onClicked(handler(self,self.onPageClicked))                
                self.ActivityPageView:addPage(pItem)
            end
            self.ActivityIndexList:setContentSize(cc.size(#GlobalData.ActivityInfos*43-30,20))
            for i = 1, #GlobalData.ActivityInfos do
                local pItemIndex = TemplateIndex:clone()
                pItemIndex:setTag(i)
                pItemIndex:show()
                self.ActivityIndexList:pushBackCustomItem(pItemIndex)
            end
            self:onPageIndexClicked(1)
            self.ActivityPageView:setCurrentPageIndex(1)            
        end
        self.ActivityPageView:onEvent(function (event)
            local target = event.target
            local pIndex = target:getCurrentPageIndex()
            if pIndex==0 then
                pIndex = #GlobalData.ActivityInfos
                target:scrollToItem(#GlobalData.ActivityInfos,0.01) 
            elseif pIndex == #GlobalData.ActivityInfos+1 then
                pIndex = 1
                target:scrollToItem(1,0.01)
            end
            self:onPageIndexClicked(pIndex)
        end)
        self:removeTimerEvent("ActivityTimer")
        self:addTimerEvent("ActivityTimer",6,function() 
            --执行了回调，轮播活动
            local pIndex = self.ActivityPageView:getCurrentPageIndex()
            self.ActivityPageView:scrollToItem(pIndex+1,2)            
        end,false)
    end
    self:loadActivityPic()
end

function ClientScene:loadActivityPic()
    for i = 1,#GlobalData.ActivityInfos do
        local pSingle = GlobalData.ActivityInfos[i]
        DownloadPic:downloadNetPic(pSingle.szImgUrlContent,md5(pSingle.szImgUrlContent),function (result,path)
            if result then
                GlobalData.ActivityInfos[i].pathSmall = path 
                self:refreshNodeActivityTexture(i)            
            end
        end,true)
    end
end

function ClientScene:refreshNodeActivityTexture(pIndex)
    local pItems = self.ActivityPageView:getItems()
    for i, v in ipairs(pItems) do
        if v:getTag() == pIndex then
            v:getChildByName("content"):loadTexture(GlobalData.ActivityInfos[pIndex].pathSmall)
        end
    end
end

function ClientScene:onPageClicked(target)
    local pIndex = target:getTag()
    G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_ACTIVITY,{scene = self,Index=pIndex})
end

function ClientScene:onPageIndexClicked(pIndex)    
    local pItems = self.ActivityIndexList:getItems()
    for i, v in ipairs(pItems) do
        if v:getTag() == pIndex then
            v:loadTexture("GUI/Hall/dating_huodongtu_dian1.png")
        else
            v:loadTexture("GUI/Hall/dating_huodongtu_dian2.png")
        end
    end
end

--绑定手机状态返回
function ClientScene:onBindPhoneStatus()
    local pStatus = false
    if GlobalData.BindingInfo.boBind==0 then
        pStatus = true
    else
        if GlobalData.BindingInfo.boReward==0 then
            pStatus = true
        end
    end
    if pStatus then
        self.NodeBindingValueBg:show()
        local pValue = g_format:formatNumber(GlobalData.BindingInfo.lRewardScore, g_format.fType.Custom_1)
        self.NodeBindingValue:setString("+"..pValue)
    end
    self.NodeBinding:setVisible(pStatus)    
    self:adjustLeftTopByProject()
end

--绑定手机奖励领取返回
function ClientScene:onBindPhoneResult(pData)
    print("dwErrorCode=====", pData.dwErrorCode)
    print("cbCurrencyType=====", pData.cbCurrencyType)
    print("lRewardScore=====", pData.lRewardScore)
    if pData.dwErrorCode == 0 then
        self:showAward(pData.lRewardScore, "client/res/task/imageNew/mrrw_jb_3.png")        
        --查询绑定手机状态
        G_ServerMgr:C2S_GetBindMobileStatus()
    elseif pData.dwErrorCode > 1000 then  --1004 ~ 1007
        showToast(g_language:getString(pData.dwErrorCode))
    end
end

function ClientScene:showAward(goldTxt, goldImg)
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
    local data = {}
    data.goldTxt = g_format:formatNumber(goldTxt, g_format.fType.standard)
    data.goldImg = goldImg
    data.type = 1
    appdf.req(path).new(data)
end

--绑定手机奖励领取返回
function ClientScene:onGetLastPayResult(pData)    
    GlobalData.PayInfoOver = true
    local pDate = os.date("*t",pData.tmDateTime)
    local pToday = os.date("*t",os.time())
    --判定是否跨天
    if pToday.year ~= pDate.year or pToday.month ~= pDate.month or pToday.day ~= pDate.day then        
        GlobalData.TodayPay = false
    else        
        GlobalData.TodayPay = true
    end
    if #self.NoticeConfig < self.CurrentIndex and not GlobalData.NoticeGiftYet then
        GlobalData.NoticeGiftYet = true
        if GlobalData.PayInfoOver then
            if GlobalData.NoticeGift and not GlobalData.TodayPay then
                self:onShowGiftCenter()
            end
        end
    end
end


return ClientScene