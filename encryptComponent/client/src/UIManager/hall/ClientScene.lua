
local ClientScene = class("ClientScene", cc.load("mvc").ViewBase)
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")

local director = cc.Director:getInstance()
local textureCache = director:getTextureCache()
local g_scheduler = director:getScheduler()

local GameFrameEngine = appdf.req(appdf.CLIENT_SRC.."NetProtocol.GameFrameEngine")
local GameUpdate = appdf.req(appdf.BASE_SRC.."app.controllers.ClientUpdate")  --游戏更新相关
local SubLayerJump = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.SubLayerJump")
local WWNodeEx = appdf.req(appdf.CLIENT_SRC.."Tools.WWNodeEx")
local TurnTableManager = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.subinterface.TurnTable.TurnTableManager")
local NodeUpdate = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.NodeUpdate")
local HeadNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HeadNode")

local SetGameIcon = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.SetGameIcon")
local HallTableViewUIConfig = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HallTableViewUIConfig")
local delayShowActTag = 1111

local m_last_vip_lv = nil --缓存VIP 等级

--大厅合图资源
local hallPlist = {
    "GUI/HallPlist",
    "GUI/RoomList1",
    "GameIconPlist",
    "GameIconPlist2"
}
-- 进入场景而且过渡动画结束时候触发。
function ClientScene:onEnterTransitionFinish()
    return self
end
-- 退出场景而且开始过渡动画时候触发。
function ClientScene:onExitTransitionStart()
    return self
end

function ClientScene:onEnter( ... )    
	ClientScene.super.onEnter(self)
    EventPost:addCommond(EventPost.eventType.PV,"进入大厅",5,nil)
end

function ClientScene:onExit()
    G_ServerMgr:CloseToSocket()
	removebackgroundcallback()
    SetGameIcon:onExit()
    self:StopAllTimer()
    self:onRemoveListen()
    SubLayerJump:onRemoveListen()
    GlobalData.ReceiveRoomSuccess = false
    -- GlobalData.ReceiveEGSuccess = false
    GlobalUserItem.MAIN_SCENE = nil
    cc.UserDefault:getInstance():flush()
	return self
end  
-- 初始化界面
function ClientScene:onCreate()
    GlobalUserItem.MAIN_SCENE = self
    -- GlobalUserItem.dwUserID = 18888
    -- GlobalUserItem.szDynamicPass = "F5FABAA7C8844BA0A7D1755D343216F4"
    -- GlobalData.MyIP = "111.111.111.111"
    --Spine动画节点列表
    self.AnimationList = {}
    --CSB 动作节点
    self.ActionList = {}

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

    local csbNode = g_ExternalFun.loadCSB("Lobby/SceneHall.csb")
    self._csbNode = csbNode
    self.SpineBg = csbNode:getChildByName("bg")
    g_ExternalFun.adapterScreen(self.SpineBg)
    self.SpineLeft = self.SpineBg:getChildByName("SpineLeft")
    self.SpineTop = self.SpineBg:getChildByName("SpineTop")
    self.SpineRight = self.SpineBg:getChildByName("SpineRight")

    self.content = csbNode:getChildByName("content")
    csbNode:setContentSize(display.width,display.height)
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)        
    self.clientLayer:addChild(csbNode)    
    self.scene = csbNode

    --左上
    self.PanelLeftTop = self.content:getChildByName("PanelLeftTop")
    --左中
    -- self.PanelLeftCenter = self.content:getChildByName("PanelLeftCenter")
    -- self.PanelLeftCenter2 = self.content:getChildByName("PanelLeftCenter2")
    --左下
    self.PanelLeftBottom = self.content:getChildByName("PanelLeftBottom")
    --右上
    self.PanelRightTop = self.content:getChildByName("PanelRightTop")
    --右中
    self.PanelRightCenter = self.content:getChildByName("PanelRightCenter")
    SetGameIcon:setParent(self.PanelRightCenter,self)
    --右下
    self.PanelRightBottom = self.content:getChildByName("PanelRightBottom")

    --左上 金币 附加货币币 进行区分        
    self.PanelUserInfo = self.PanelLeftTop:getChildByName("NodeUserInfo"):getChildByName("Panel_1")
    self.head_node = self.PanelUserInfo:getChildByName("head_node")
    self.contentBG = self.PanelUserInfo:getChildByName("contentBG")
    self.BtnHead = HeadNode:create()
    self.BtnHead:setName("BtnHead")
    self.head_node:addChild(self.BtnHead)
    self.BtnHead:setVipVisible(false)
 
    self.txtCoin = self.PanelUserInfo:getChildByName("goldValue")
    self.txtName = self.PanelUserInfo:getChildByName("nick")     
    self.txtExtra = self.PanelUserInfo:getChildByName("ExtraValue")
    self.BtnExtra = self.PanelUserInfo:getChildByName("BtnExtra")    
    self.BtnAddGold = self.PanelUserInfo:getChildByName("BtnAddGold")    
    self.PanelUserInfo:show()
 
    --礼包中心
    self.NodeGift = self.PanelLeftTop:getChildByName("NodeGift")
    self.NodeGiftPercentBg = self.NodeGift:getChildByName("wordBg")
    self.NodeGiftPercentBg:hide()
    self.NodeGiftPercent = self.NodeGiftPercentBg:getChildByName("libaorukou_6_3"):getChildByName("word_1")
    self.NodeGift:setVisible(GlobalData.GiftEnable)
    
    -- 左中
    --Avatar
    -- self.NodeAvatar = self.PanelLeftCenter:getChildByName("NodeAvatar")
    -- self.NodeAvatar:show()    

    
    --左下
    --2.提现
    self.btnWithdraw = self.PanelLeftBottom:getChildByName("btnWithdraw")   
    self.btnWithdraw:hide()
    --3.银行
    self.btnBank = self.PanelLeftBottom:getChildByName("btnBank")  
    self.btnBank:hide()
    --4.俱乐部
    self.btnClub = self.PanelLeftBottom:getChildByName("btnClub")
    self.btnClub:hide()
    --5.客服
    self.btnCustomer = self.PanelLeftBottom:getChildByName("btnCustomer")
    self.btnCustomer:hide()
    --6.邮件
    self.btnEmail = self.PanelLeftBottom:getChildByName("btnEmail")
    self.btnEmail:hide()
    --7.设置
    self.btnSetting = self.PanelLeftBottom:getChildByName("btnSetting")
    --8.排行榜
    self.btnRank = self.PanelLeftBottom:getChildByName("btnRank")    
    self.btnRank:hide()
    --1.商店
    self.NodeShop = self.PanelLeftBottom:getChildByName("NodeShop")        
    self.NodeShop:setScale(0.80)
    --self.NodeShop:hide()
    --1.转盘
    self.NodeTruntable = self.PanelLeftBottom:getChildByName("NodeTruntable")  
    --VIP
    self.NodeVIP = self.PanelLeftBottom:getChildByName("NodeVIP")

    self.NodeShareTurn = self.PanelLeftBottom:getChildByName("NodeShareTurn")

    --右上
    --1.破产补助
    self.NodeBankrupt = self.PanelRightTop:getChildByName("NodeBankrupt")
    self.NodeBankrupt:hide()    
    --2.每日签到
    self.NodeDaily = self.PanelRightTop:getChildByName("NodeDaily")        
    --3.任务
    self.NodeTask = self.PanelRightTop:getChildByName("NodeTask")
    -- self.NodeTask:hide()
    --4.手机绑定
    self.NodeBinding = self.PanelRightTop:getChildByName("NodeBinding")    
    self.NodeBinding:hide()
    --4.手机绑定 提示性文字
    self.NodeBindingValueBg = self.NodeBinding:getChildByName("wordBg")
    self.NodeBindingValueBg:hide()
    self.NodeBindingValue = self.NodeBindingValueBg:getChildByName("content"):getChildByName("word_1")
    --5.每日分享
    self.NodeShare = self.PanelRightTop:getChildByName("NodeShare")
    self.NodeShare:hide()
    --6.塔罗牌    
    self.NodeTarot = self.PanelRightTop:getChildByName("NodeTarot")
    -- self.NodeTarot:hide()    
    --7.激活码
    self.NodeGiftCode = self.PanelRightTop:getChildByName("NodeGiftCode")
    self.NodeGiftCode:hide()
    --激活码限时礼包
    self.NodeGiftCodeShop = self.PanelRightTop:getChildByName("NodeGiftCodeShop")
    self.NodeGiftCodeShop:hide()
    

    
    --右中         
    -- self.TypeSlots = self.PanelRightCenter:getChildByName("TypeSlots")
    -- self.TypeEspecial = self.PanelRightCenter:getChildByName("TypeEspecial")
    -- self.HallPinko = self.PanelRightCenter:getChildByName("HallPinko")
    -- self.HallCrash = self.PanelRightCenter:getChildByName("HallCrash")
    -- self.HallFrutas = self.PanelRightCenter:getChildByName("HallFrutas")
    -- self.RightCenterList = {
        -- self.TypeSlots,
        -- self.TypeEspecial,
        -- self.HallFrutas,
        -- self.HallPinko,
        -- self.HallCrash,
    -- }

    --右下  
    -- --1.商店
    -- self.NodeShop = self.PanelRightBottom:getChildByName("NodeShop")        
    -- self.NodeShop:setScale(0.84)
    -- --self.NodeShop:hide()
    -- --1.转盘
    -- self.NodeTruntable = self.PanelRightBottom:getChildByName("NodeTruntable")  
    -- local pCarrier = self.NodeTruntable:getChildByName("spine_1")
    -- pCarrier:setScale(0.68)
    -- --VIP
    -- self.NodeVIP = self.PanelRightBottom:getChildByName("NodeVIP")
    -- local pCarrier = self.NodeVIP:getChildByName("spine_1")
    -- pCarrier:setScale(0.68)
    -- self.HallLPD = self.PanelRightBottom:getChildByName("HallLPD")
    -- self.HallJXLW = self.PanelRightBottom:getChildByName("HallJXLW")
    -- self.HallBXNW = self.PanelRightBottom:getChildByName("HallBXNW")
    
    --适配性调整Panel大小
    self:adjustPanelSize()
    -- self.PanelLC2OrignX = self.PanelLeftCenter2:getPositionX()
    --根据项目自适应调整左下方按钮以及位置尺寸
    self:adjustLeftBottomByProject()    
    --根据项目自适应调整右上方按钮以及位置尺寸
    self:adjustRightTopByProject()
    ccui.Helper:doLayout(self.scene)
    
    self:onUpdateHallInfo()
    self:onAddEventListen()
    
    --添加动画
    self:AttachAnimation()
    --添加按钮响应
    self:AttachHandler()
    --添加红点
    self:AttachRedPoint()
    --添加更新进度条和在线人数
    self:AttachExtraInfo()
    --开始监听用户久置大厅
    -- self:StartCheckLevel()

    -- local caiJinNode = self.NodeAvatar:getChildByTag(101)
    -- if not caiJinNode then
    --     local caiJinNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.subinterface.caiJinNode"):create()
    --     caiJinNode:setPosition(0,500)
    --     caiJinNode:addTo(self.NodeAvatar,1,101)
    -- end

    --获取房间列表
    G_ServerMgr:C2S_RequestGameRoomInfo()
    --查询签到
    G_ServerMgr:C2S_QueryCheckIn()
    --获取商品列表
    G_ServerMgr:C2S_GetProductInfos()

    tickMgr:delayedCall(handler(self,self.CompatibleNewUI),500)
    local pCallback = function ()        
        self:ShowNextNotice()
    end
    self:EaseShow(pCallback)    
end


--添加更新进度条和在线人数
function ClientScene:AttachExtraInfo()
    --更新节点
    self.gameUpdateNode = SetGameIcon:getGameUpdateNode()
    self._updateBtn = SetGameIcon:getUpdateBtn()
    --检测游戏更新状态
    self:CheckGameUpdataStatus()    
    -- local pGameList = {
    --     {901,self.HallPinko},
    --     {703,self.HallCrash},        
    --     {704,self.HallFrutas},
    --     {903,self.HallLPD},
    --     {525,self.HallJXLW},
    --     {532,self.HallBXNW},
    -- }

    -- for i, v in ipairs(pGameList) do
    --     local pNU = v[2]:getChildByName("NodeUpdate")
    --     local pBtn = v[2]:getChildByName("Button_1")
    --     local pWidthUpdate = pBtn:getContentSize().width-32            
    --     local pNodeUpdate = NodeUpdate:create(pWidthUpdate)
    --     pNodeUpdate:setMaskType(i<=3 and 1 or 2)
    --     pNodeUpdate:addTo(v[2])
    --     pNodeUpdate:setPosition(pNU:getPosition())
    --     pNodeUpdate:hide()
    --     self.gameUpdateNode[v[1]] = pNodeUpdate
    --     if i <= 3 then
    --         local panel = v[2]:getChildByName("FileNode_online")
    --         local onlineText = panel:getChildByName("text_onlineCount")
    --         local Image_icon = panel:getChildByName("Image_icon")
    --         g_onlineCount:regestOnline(v[1],onlineText,function() 
    --             Image_icon:setPositionX(onlineText:getPositionX() - onlineText:getContentSize().width - 2) 
    --         end)
    --     end
    -- end
    self:addTimeNode(self.NodeTarot)
    SetGameIcon:setGameIconEntrance()
end

--添加动画
function ClientScene:AttachAnimation()
    for k, v in pairs(HallTableViewUIConfig.AnimationConfig) do
        local pItem = self[k]
        if pItem and not tolua.isnull(pItem) then
            --spine添加
            if v.PathJson and v.PathAtlas and v.AnimationName then
                local pSpine = sp.SkeletonAnimation:create(v.PathJson,v.PathAtlas,1)
                pSpine:addAnimation(0,v.AnimationName,true)
                local pCarrier = pItem:getChildByName("spine_1")
                if pCarrier and not tolua.isnull(pCarrier) then
                    pCarrier:addChild(pSpine)
                else
                    pItem:addChild(pSpine)
                end
                table.insert(self.AnimationList,pSpine)
            end
            --csb 动画添加
            if v.PathCSB then
                local pAction = g_ExternalFun.loadTimeLine(v.PathCSB)
                pAction:gotoFrameAndPlay(0,true)                
                pItem:runAction(pAction)
                table.insert(self.AnimationList,pAction)
            end
        end
    end
end

function ClientScene:goToShop()
    local desc = "点击商城按钮"
    EventPost:addCommond(EventPost.eventType.CLICK,desc)     --点击商城按钮   
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
end
--响应按钮
function ClientScene:onButtonClicked(target)
    -- --任意点击均恢复场景中动画播放，场景动画未被打断情况下，重置暂停倒计时
    -- self.DeltaSecond = 120
    -- self:ResumeAction()

    local pName = target:getName()
    if pName == "Button_1" then
        pName = target:getParent():getName()
    end
    if pName == "content" then        
    elseif pName == "BtnHead" then
        G_event:NotifyEvent(G_eventDef.UI_OPEN_SETLAYER) --设置
    elseif pName == "BtnAddGold" then
        --未拉取商品完成，则跳过响应
        self:goToShop()   
    elseif pName == "NodeGift" then        
        --展示礼包类型：1.首充(默认) 2.每日 3.一次性
        G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,{ShowType = 1,})
    elseif pName == "NodeVIP" then
        G_ServerMgr:C2S_GetVIPInfo(1)
    elseif pName == "NodeTruntable" then
        -- G_event:NotifyEvent(G_eventDef.UI_SHOW_HALLSIGNLAYER,{NoticeNext = true})
        -- do return end
        local desc = "点击转盘入口"
        EventPost:addCommond(EventPost.eventType.CLICK,desc)
        self:onClickOpenTurnTable()   
    elseif pName == "NodeShareTurn" then
        G_ServerMgr:requestTurnTableUserStatus()
    elseif pName == "NodeShop" then
        --未拉取商品完成，则跳过响应    
        self:goToShop()
    elseif pName == "btnWithdraw" then
        G_event:NotifyEvent(G_eventDef.UI_OPEN_CASHOUTLAYER)
    elseif pName == "btnBank" then
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
    elseif pName == "btnClub" then
        EventPost:addCommond(EventPost.eventType.CLICK,"点击俱乐部!")  
        G_ServerMgr:C2S_requestMemberOrder()
    elseif pName == "btnCustomer" then
        G_event:NotifyEvent(G_eventDef.UI_OPEN_SERVICELAYER)
    elseif pName == "btnEmail" then
        G_event:NotifyEvent(G_eventDef.UI_OPEN_EMAILLAYER)
    elseif pName == "btnSetting" then
        G_event:NotifyEvent(G_eventDef.UI_OPEN_SETLAYER)
    elseif pName == "btnRank" then
        EventPost:addCommond(EventPost.eventType.RANK,"点击排行榜!")
        G_event:NotifyEvent(G_eventDef.UI_OPEN_RANKLAYER)
    elseif pName == "NodeGiftCodeShop" then
        G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CODE_SHOP)
    elseif pName == "NodeGiftCode" then
        G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CODE)
    elseif pName == "NodeTarot" then
        local desc = "点击塔罗牌入口"
        EventPost:addCommond(EventPost.eventType.CLICK,desc)
        G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_TAROT)
    elseif pName == "NodeBankrupt" then
        G_event:NotifyEvent(G_eventDef.UI_SHOW_BASEENSURE,self)
    elseif pName == "NodeDaily" then
        EventPost:addCommond(EventPost.eventType.CLICK,"点击了每日领奖！")
        G_event:NotifyEvent(G_eventDef.UI_SHOW_HALLSIGNLAYER)
    elseif pName == "NodeTask" then
        EventPost:addCommond(EventPost.eventType.CLICK,"点击任务!") 
        G_event:NotifyEvent(G_eventDef.UI_SHOW_HALLTASKLAYER,{scene = self})
    elseif pName == "NodeBinding" then  
        self:onAuthClick()
    elseif pName == "NodeShare" then  
       -- G_ServerMgr:S2C_UpdateShareCount()  
        G_event:NotifyEvent(G_eventDef.UI_SHOW_SHARE,self)
    elseif pName == "BtnExtra" then
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
            if GlobalData.TCIndex > 0 then
                G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_ACTIVITY,{scene = self,Index=GlobalData.TCIndex})                
            end
        end
    end
end

--添加按钮响应
function ClientScene:AttachHandler()
    self.ButtonList = {
        self.content,
        self.BtnHead,        
        self.BtnAddGold,
        self.NodeGift:getChildByName("Button_1"),
        self.NodeVIP:getChildByName("Button_1"),
        self.NodeTruntable:getChildByName("Button_1"),
        self.NodeShop:getChildByName("Button_1"),
        self.btnWithdraw,
        self.btnBank,
        self.btnClub,
        self.btnCustomer,        
        self.btnEmail,
        self.btnSetting,
        self.btnRank,
        self.NodeGiftCodeShop:getChildByName("Button_1"),
        self.NodeShareTurn:getChildByName("Button_1"),
        self.NodeGiftCode:getChildByName("Button_1"),
        self.NodeTarot:getChildByName("Button_1"),
        self.NodeBankrupt:getChildByName("Button_1"),
        self.NodeDaily:getChildByName("Button_1"),
        self.NodeTask:getChildByName("Button_1"),
        self.NodeBinding:getChildByName("Button_1"),
        self.NodeShare:getChildByName("Button_1"),
        -- self.TypeSlots:getChildByName("Button_1"),
        -- self.TypeEspecial:getChildByName("Button_1"),
        -- self.HallFrutas:getChildByName("Button_1"),
        -- self.HallPinko:getChildByName("Button_1"),
        -- self.HallCrash:getChildByName("Button_1"), 
        -- self.HallLPD:getChildByName("Button_1"),
        -- self.HallJXLW:getChildByName("Button_1"),
        -- self.HallBXNW:getChildByName("Button_1"),
        self.BtnExtra,        
    }
    for i, v in ipairs(self.ButtonList) do
        v:onClicked(handler(self,self.onButtonClicked))
    end    
end

--添加红点
function ClientScene:AttachRedPoint()    
    --银行 转账记录红点
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
    else
        g_redPoint:addRedPoint(g_redPoint.eventType.bank,self.btnBank,cc.p(-5,5))
    end
    --俱乐部红点
    g_redPoint:addRedPoint(g_redPoint.eventType.club,self.btnClub,cc.p(-2,5))
    --邮件红点
    g_redPoint:addRedPoint(g_redPoint.eventType.mail,self.btnEmail,cc.p(-5,5))
    
    --塔罗牌红点
    g_redPoint:addRedPoint(g_redPoint.eventType.tarot,self.NodeTarot:getChildByName("Button_1"),cc.p(60,30))  
    --转盘红点
    g_redPoint:addRedPoint(g_redPoint.eventType.turnTable,self.NodeTruntable:getChildByName("Button_1"),cc.p(50,30))
    --任务红点
    g_redPoint:addRedPoint(g_redPoint.eventType.task,self.NodeTask:getChildByName("Button_1"),cc.p(12,30))
    --
    g_redPoint:addRedPoint(g_redPoint.eventType.gift,self.NodeGift:getChildByName("Button_1"),cc.p(50,32))

    --分享转盘红点
    g_redPoint:addRedPoint(g_redPoint.eventType.shareTurn,self.NodeShareTurn:getChildByName("Button_1"),cc.p(50,30))
end

--开始监听用户久置大厅
function ClientScene:StartCheckLevel()
    -- self.DeltaSecond = 120
    -- self.CheckLevelTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.onCheckLevel), 1, false)
--     if self._processTotal < self._processIndex then
--         if self._processAllTotal < self._processIndex then
-- 		    if self._processTimer ~= nil then
-- 		       scheduler:unscheduleScriptEntry(self._processTimer)
-- 		       self._processTimer = nil
-- 		    end
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
        -- self.PanelLeftCenter:setContentSize(cc.size(self.LeftCenterMin,1000))
        --右中走最小尺寸
      --  self.PanelRightCenter:setContentSize(cc.size(self.RightCenterMin,620))
        --右下走最小尺寸
        -- self.PanelRightBottom:setContentSize(cc.size(self.RightBottomMin,210))

        --左上
        self.PanelLeftTop:setPositionX(20)
        --左中        
        -- self.PanelLeftCenter2:setPositionX(20)
        --左下
        -- self.PanelLeftBottom:setPositionX(20)
        --右上
        self.PanelRightTop:setPositionX(display.width-20)
    else
        --屏幕宽度超过设计尺寸
        -- local pAbelLeftCenterWidth = math.min(pWidth*self.LeftCenterPercent,self.LeftCenterMax)        
        -- local pExtraRightCenterWidth = (pWidth - pAbelLeftCenterWidth - self.RightCenterMin)*0.7
        -- local pAbleRightCenterWidth = pExtraRightCenterWidth + self.RightCenterMin
        -- self.PanelLeftCenter:setContentSize(cc.size(pWidth-pAbleRightCenterWidth,1000))        
      --  self.PanelRightCenter:setContentSize(cc.size(pAbleRightCenterWidth,620))
        -- local pAbleRightBottomWidth = pExtraRightCenterWidth + self.RightBottomMin
        -- self.PanelRightBottom:setContentSize(cc.size(pAbleRightBottomWidth,210))   
        
        --左上
        self.PanelLeftTop:setPositionX(70)
        --左中        
    --    self.PanelLeftCenter2:setPositionX(70)
        --左下
        -- self.PanelLeftBottom:setPositionX(70)
        --右上
        self.PanelRightTop:setPositionX(display.width-70)
    end    
end

--动态调整左上部入口
function ClientScene:adjustLeftTopByProject()
    local pStartX = 520
    local pDeltaX = 190

    local pNodes = {
        self.NodeGift,
    }
    local pIndex = 0
    for i, v in ipairs(pNodes) do
        if v:isVisible() then
            v:setPositionX(pStartX + pIndex*pDeltaX)
            pIndex = pIndex + 1
        end
    end
end

--动态调整右上部入口
function ClientScene:adjustRightTopByProject()
    self.NodeTask:show()
    self.NodeDaily:show()

    local pIndex = 0
    local pStartX = 1200
    local pPreHalfWidth = 0
    local pDeltaX = 20
    local pNodes = {
        self.NodeShare,
        self.NodeBinding,
        self.NodeTask,
        self.NodeDaily,
        self.NodeTarot,
        self.NodeGiftCode,
        self.NodeGiftCodeShop,
        self.NodeBankrupt,
    } 
    
    for i, v in ipairs(pNodes) do
        if v:isVisible() then
            local pSelfHalfWidth = v:getChildByName("Button_1"):getContentSize().width/2
            local pPosx = pStartX-(pDeltaX + pSelfHalfWidth + pPreHalfWidth)
            v:stopAllActions()
            v:runAction(cc.Sequence:create(cc.MoveTo:create(0.5-pIndex*0.1,cc.p(pPosx,75))))
            pIndex = pIndex + 1
            pStartX = pPosx
            pPreHalfWidth = pSelfHalfWidth
        end
    end
end

--根据版本自适应左下方区域尺寸位置
function ClientScene:adjustLeftBottomByProject()
    local pDeltaSingle = -20
    --金币项目展示按钮
    local pLeftBottomBtns = {
        --self.NodeShop,      --商城
        self.btnBank,       --银行        
        self.btnClub,       --俱乐部
        self.btnCustomer,   --客服
        self.btnEmail,      --邮件
        self.btnSetting,    --设置
        -- self.btnRank,    --排行榜 先关闭
    }
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then        
        pLeftBottomBtns = {            
            --self.NodeShop,      --商城
            self.btnWithdraw,   --提现
            self.btnBank,       --银行                    
            self.btnCustomer,   --客服
            self.btnEmail,      --邮件
            self.btnSetting,    --设置
        }
    end   
    local pWidth = 20    
    for i, v in ipairs(pLeftBottomBtns) do
        v:show()
        local pEachWidth = v:getContentSize().width     --i==1 and 230 or v:getContentSize().width        
        v:setPositionX(pWidth + pEachWidth/2+(i-1)*pDeltaSingle)
        pWidth = pWidth + pEachWidth        
    end
    -- pWidth = pWidth + #pLeftBottomBtns*pDeltaSingle
    -- self.PanelLeftBottom:setContentSize(cc.size(pWidth+10,83))
end

--缓入
function ClientScene:EaseShow(callback)
    local func = function() 
        self:onEaseFinishCallback()
        if callback then
            callback()
        end
    end
    self:ResumeAction()    
    local pCostTime = 0.5
    -- local pDeltaTime = 0.07
    -- local pAllCost = pCostTime+0*pDeltaTime
    --左上
    self.PanelLeftTop:setPositionY(display.height+200)
    TweenLite.to(self.PanelLeftTop,pCostTime,{ y=display.height,ease = Cubic.easeInOut})
    --左中
    -- local pSize = self.PanelLeftCenter:getContentSize()
    -- self.PanelLeftCenter:setPositionX(0-pSize.width)
    -- self.PanelLeftCenter:setPositionX(0-200)
    -- TweenLite.to(self.PanelLeftCenter,pAllCost,{ x=0,ease = Cubic.easeInOut})
    --左中2
    -- local pSize = self.PanelLeftCenter2:getContentSize()
    -- self.PanelLeftCenter2:setPositionX(0-pSize.width)
    -- TweenLite.to(self.PanelLeftCenter2,pAllCost,{ x=self.PanelLC2OrignX,ease = Cubic.easeInOut})

    --左下
    self.PanelLeftBottom:setPositionY(0-200)
    TweenLite.to(self.PanelLeftBottom,pCostTime,{ y=0,ease = Cubic.easeInOut})
    --右上
    self.PanelRightTop:setPositionY(display.height+150)
    TweenLite.to(self.PanelRightTop,pCostTime,{ y=display.height,ease = Cubic.easeInOut})
    --右中
    --单个节点操作
    -- local pItemX = {356.5,243,590,944,944,944}
    -- local pWidth  = self.PanelRightCenter:getContentSize().width
    -- if #self.RightCenterList > 0 then
    --     for i, v in ipairs(self.RightCenterList) do
    --         v:setPositionX(pItemX[i]+pWidth)        
    --         TweenLite.to(v,pCostTime+(i-1)*pDeltaTime,{ x=pItemX[i],ease = Cubic.easeInOut,onComplete = (i==#self.RightCenterList) and func or nil})        
    --     end
    -- else
        self.PanelRightCenter:setPositionX(display.width)
        TweenLite.to(self.PanelRightCenter,pCostTime,{ x=0,ease = Cubic.easeInOut,onComplete = func})
    -- end
    --右下
    -- self.PanelRightBottom:setPositionY(-210)
    -- TweenLite.to(self.PanelRightBottom,pAllCost,{ y=0,ease = Cubic.easeInOut})
    self.LastIndex = nil
end

--缓出
function ClientScene:EaseHide(callback)
    self:PauseAction()
    local pCostTime = 0.5
    -- local pDeltaTime = 0.07
    -- local pAllCost = pCostTime+7*pDeltaTime
    --左上    
    TweenLite.to(self.PanelLeftTop,pCostTime,{ y=display.height+200,ease = Cubic.easeInOut})
    --左中
    -- local pSize = self.PanelLeftCenter:getContentSize()    
    -- TweenLite.to(self.PanelLeftCenter,pAllCost,{ x=0-pSize.width-100,ease = Cubic.easeInOut})
    --左中2
    -- local pSize = self.PanelLeftCenter2:getContentSize()    
    -- TweenLite.to(self.PanelLeftCenter2,pAllCost,{ x=0-pSize.width-100,ease = Cubic.easeInOut})
    --左下    
    TweenLite.to(self.PanelLeftBottom,pCostTime,{ y=-200,ease = Cubic.easeInOut})
    --右上    
    TweenLite.to(self.PanelRightTop,pCostTime,{ y=display.height+150,ease = Cubic.easeInOut})
    --右中
    --单个节点操作
    -- local pItemX = {356.5,243,590,944,944,944}
    -- local pWidth  = self.PanelRightCenter:getContentSize().width
    -- local pItemIndex = 1
    -- if #self.RightCenterList > 0 then
    --     for i=#self.RightCenterList,1,-1 do
    --         TweenLite.to(self.RightCenterList[i],pCostTime+(pItemIndex-1)*pDeltaTime,{ x=pItemX[i]+pWidth,ease = Cubic.easeInOut,onComplete = (i==1) and callback or nil})
    --         pItemIndex = pItemIndex + 1
    --     end    
    -- else
        TweenLite.to(self.PanelRightCenter,pCostTime,{ x=display.width,ease = Cubic.easeInOut,onComplete = callback})
    -- end
    -- local pItemX = {356.5,243,590,944,944,944}
    -- local pWidth  = self.PanelRightCenter:getContentSize().width
    -- local pItemIndex = 1
    -- for i=#self.RightCenterList,1,-1 do
    --     TweenLite.to(self.RightCenterList[i],pCostTime+(pItemIndex-1)*pDeltaTime,{ x=pItemX[i]+pWidth,ease = Cubic.easeInOut,onComplete = (i==1) and callback or nil})
    --     pItemIndex = pItemIndex + 1
    -- end    
    --右下
    -- TweenLite.to(self.PanelRightBottom,pAllCost,{ y=-210,ease = Cubic.easeInOut})
end   
--缓入完成触发
--pFlag false 跟随上一个
--pFlag true 重新走一遍
function ClientScene:ShowNextNotice(args)

    if args and args.NoticeName then
        for i, v in ipairs(self.NoticeConfig) do
            if v.NoticeName == args.NoticeName then
                v.Status = args.Status or 1
                break
            end
        end
    end
    
    local pItem = nil
    for i, v in ipairs(self.NoticeConfig) do
        if v.Status== 0 then
            pItem = v
            break
        end
    end
    
    if pItem then
        if pItem.LastTime then
            local pFlag = self:isTodayFirstNotice(pItem.LastTime)
            if pFlag then
                cc.UserDefault:getInstance():setIntegerForKey(pItem.NoticeName,os.time())
                pItem.Func()
            else
                self:ShowNextNotice({NoticeName = pItem.NoticeName})
            end            
        else
            pItem.Func()
        end
    end
end

--该项是否当日首次弹窗（本地记录，跨天重新计算）
function ClientScene:isTodayFirstNotice(pTime)    
    local pDate = os.date("*t",pTime)
    local pToday = os.date("*t",os.time())
    --判定是否跨天
    if pToday.year ~= pDate.year or pToday.month ~= pDate.month or pToday.day ~= pDate.day then        
        return true
    end
end

--1.检测卡场
function ClientScene:onCheckLockGame()
    if GlobalUserItem.dwLockKindID ~= 0 then  --处理锁游戏
        local scheduler = cc.Director:getInstance():getScheduler()
        -- 跳转到锁游戏中
        if GlobalData.ReceiveRoomSuccess and GlobalData.ReceiveEGSuccess then
            -- local localKindID = GlobalUserItem.dwLockKindID  --dwLockServerKindID
            GlobalUserItem.dwLockKindID = 0
            if self.schedulerID then
                scheduler:unscheduleScriptEntry(self.schedulerID)
                self.schedulerID = nil
            end

            -- local kindID = g_ExternalFun.getKindID(GlobalUserItem.roomMark)
            -- local pKindName = g_ExternalFun.isEasyGame(kindID)
            -- if pKindName then
            --     local pFlag = 1
            --     if pKindName == "Mine" then
            --         pFlag = 2
            --     end
            --     SetGameIcon.EGGameID = kindID
            --     self:onClickGame(pFlag)
            -- else
            G_event:NotifyEvent(G_eventDef.UI_START_GAME,{roomMark = GlobalUserItem.roomMark,quickStart = false})
            -- end

        else            
            self.schedulerID = nil
            self.schedulerID = scheduler:scheduleScriptFunc( function()
                self:onCheckLockGame()
                -- 定时器执行的函数
            end , 1, false)
        end
    else
        G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="CheckLockGame"})    
    end
end

-- --点击进游戏
-- function ClientScene:onClickGame(index,pGift) 
--     local pConfig = GlobalData.EntryConfig[index]
--     if pConfig and type(pConfig)=="number" then
--         SetGameIcon:hall2RoomList(pConfig)      --房间分类
--     elseif pConfig and type(pConfig)=="table" then
--         SetGameIcon:hall2GameList(index,pGift)
--         self.LastIndex = index    
--     end
-- end

--2.引导弹框系统提示
function ClientScene:onGetSystemNoticeInfo()    
    G_ServerMgr:C2S_GetSystemNotice()
end

--3.绑定手机提示
function ClientScene:onCheckBinding()
    if GlobalUserItem.szSeatPhone and  string.len(GlobalUserItem.szSeatPhone) > 0 then
        G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="HallMessage"})   
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
    if  GlobalData.ProductsOver and GlobalData.GiftEnable and GlobalData.PayInfoOver and not GlobalData.TodayPay then            
        local pData = {
            ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
            NoticeNext = true
        }
        G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
    else
        local pDelay = 1000
        local pStatus = 0
        if GlobalData.ProductsOver and GlobalData.PayInfoOver and (not GlobalData.GiftEnable  or not GlobalData.TodayPay) then
            pDelay = 100
            pStatus = 1
        end
        tickMgr:delayedCall(function() 
            G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="HallGiftCenter",Status = pStatus})
        end,pDelay)
        
    end
end

--6.请求每日签到
function ClientScene:onQueryDailySign()
    if GlobalData.DailySign then
        G_event:NotifyEvent(G_eventDef.UI_SHOW_HALLSIGNLAYER,{NoticeNext = true})
    else        
        local pDelay = 1000
        local pStatus = 0
        tickMgr:delayedCall(function() 
            G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="HallSign",Status = pStatus})
        end,pDelay)
    end
end

--7.俱乐部引导
function ClientScene:onShowClubGuide()
    --是否弹出clubguidelayer
    if GlobalUserItem.dwAgentID == 0 then
        G_event:NotifyEvent(G_eventDef.UI_OPEN_CLUBGUIDELAYER,{NoticeNext = true})
    else        
        G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="ClubGuider"})
    end
end


--每次进入大厅缓动完成执行
function ClientScene:onEaseFinishCallback()
    g_ExternalFun.playPlazzBackgroudAudio()
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
    self.check_bankrupt = false --是否需要弹框破产补助
    self._requestSugTimeId = g_scheduler:scheduleScriptFunc(function(dt) 
       self:onUpdate(dt)              
    end,3,false)  
    -- self.isNoticing = false
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
            {   
                NoticeName = "CheckLockGame",
                Status = 0,
                Func = handler(self,self.onCheckLockGame),
            },
            --2.检查系统提示信息
            -- handler(self,self.onGetSystemNoticeInfo),
            --3.每日签到
            {   
                NoticeName = "HallSign",
                Status = 0,
                LastTime = cc.UserDefault:getInstance():getIntegerForKey("HallSign",0),
                Func = handler(self,self.onQueryDailySign),  
            },
            -- --3.砸金蛋
            -- {   
            --     NoticeName = "EggBreak",
            --     Status = 0,
            --     LastTime = cc.UserDefault:getInstance():getIntegerForKey("EggBreak",0),
            --     Func = handler(self,self.onOpenEggLayer),  
            -- }, 
            --6.礼包推荐
            -- {   
            --     NoticeName = "HallGiftCenter",
            --     Status = 0,
            --     -- LastTime = cc.UserDefault:getInstance():getIntegerForKey("HallGiftCenter",0),
            --     Func = handler(self,self.onShowGiftCenter),  
            -- }, 
            -- --4.核对转盘
            -- {   
            --     NoticeName = "HallTurnTable",
            --     Status = 0,
            --     LastTime = cc.UserDefault:getInstance():getIntegerForKey("HallTurnTable",0),
            --     Func = handler(self,self.checkOpenTurnTable),  
            -- },           
            
            --5.邀请拉新提示  
            {   
                NoticeName = "ShareStepLayer",
                Status = 0,
                Func = handler(self,self.checkShareStep),  
            }
        }
    end

    local info = {
        url = "https://ifconfig.me/ip",
        callback = function(ok,response) 
            -- print("myIp = ",response)
            GlobalData.MyIP = response 
        end
    }
    http.get(info)
end

function ClientScene:onAuthClick(pNoticeNext)
    local callback = function() 
        -- self.NodeBinding:hide()
        -- self:adjustRightTopByProject()
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
    --获取活动列表
    G_ServerMgr:C2S_GetActivityConfig()
    --获取客服配置
    G_ServerMgr:C2S_GetCustomService()
    --获取每日分享配置
    G_ServerMgr:C2S_GetShareConfig()
    --拉取破产补助配置
    G_ServerMgr:C2S_QueryBaseEnsure()    
    --查询绑定手机状态
    G_ServerMgr:C2S_GetBindMobileStatus()        
    --获取塔罗牌数据          
    G_ServerMgr:C2S_RequestTarotData() 

    G_ServerMgr:requestRechargeBenefit()

    --拉取存钱罐配置
    --G_ServerMgr:C2s_getPiggInfo() 

    if m_last_vip_lv == nil then
        --登录成功首次先请求获取VIP信息
        G_ServerMgr:C2S_RequestUserGold()
    end
 
    --获取激活码限时礼包商品列表
    -- G_ServerMgr:C2S_GetGiftCodeStatus()
               
    self:addTimerEvent("MarqueeTimer",15,function() 
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

    self:addTimerEvent("redPoint",60,function() 
        --获取红点数据
        G_ServerMgr:C2S_RequestRedData() 
        G_ServerMgr:C2S_GetMailCount()     --请求：邮件领取数量
    end,false,true)

    self:addTimerEvent("getLastPayInfo",30,function() 
        --定时查询充值信息
        G_ServerMgr:C2S_GetLastPayInfo()
    end,true,true)

    --6秒检查一次是否有事件需要上传
    self:addTimerEvent("EventPost",6,function() 
        EventPost:pushEventList()
    end,false)

    -- -- --彩金池数据15秒拉取一次
    -- self:addTimerEvent("JackPot",15,function() 
    --     --获取api游戏彩金池状态
    --     G_ServerMgr:C2S_GetJackPotStatus()
    -- end,true,true)
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
    -- G_event:AddNotifyEvent(G_eventDef.NET_QUERY_CHECKIN,handler(self,self.onQuerySignInData))   --查询签到数据
    G_event:AddNotifyEvent(G_eventDef.NET_QUERY_ORDER_NO_RESULT,handler(self,self.onQueryOrdersNoData))   --历史充值成功订单信息返回
    G_event:AddNotifyEvent(G_eventDef.NET_CLUBMEMBERORDER,handler(self,self.onAgentMemberOrder))   --俱乐部身份
    G_event:AddNotifyEventTwo(self,G_eventDef.EVENT_FACE_URL_RESULT,handler(self,self.onGetUserUrl))   --个人头像信息
    G_event:AddNotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,handler(self,self.ShowNextNotice))     --下一个弹框事件
    G_event:AddNotifyEvent(G_eventDef.NET_PRODUCTS_RESULT,handler(self,self.ProductsResult))     --完成商品列表拉取事件
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_PRODUCTS_STATE_RESULT,handler(self,self.ProductsResult))   --同步商品表状态结果
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_GET_PRODUCT_ACTIVE_STATE_RESULT,handler(self,self.onProductActiveStateResult))   --同步一次性礼包状态结果
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_GET_GIFT_CODE_STATUS_RESULT,handler(self,self.onGetGiftCodeStatusResult))   --获取激活码限时礼包商品列表拉取完成事件
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
    G_event:AddNotifyEventTwo(self,G_eventDef.EVENT_TAROT_REQUEST,handler(self,self.onTarotResult))   --获取塔罗牌数据
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
    -- G_event:RemoveNotifyEvent(G_eventDef.NET_QUERY_CHECKIN)
    G_event:RemoveNotifyEvent(G_eventDef.NET_QUERY_ORDER_NO_RESULT)    
    G_event:RemoveNotifyEvent(G_eventDef.NET_CLUBMEMBERORDER)
    G_event:RemoveNotifyEventTwo(self,G_eventDef.EVENT_FACE_URL_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE)
    G_event:RemoveNotifyEvent(G_eventDef.NET_PRODUCTS_RESULT)
    G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_PRODUCTS_STATE_RESULT)
    G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_GET_PRODUCT_ACTIVE_STATE_RESULT)   
    G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_GET_GIFT_CODE_STATUS_RESULT) 
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
    G_event:RemoveNotifyEventTwo(self,G_eventDef.EVENT_TAROT_REQUEST) 
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
        -- if self._gameReconnectFunc and type(self._gameReconnectFunc) == "function" then  
        --     showNetLoading()
        --     self._gameReconnectFunc()
        --     self._gameReconnectFunc = nil
        --     self:stopAllActions()
        -- else            
        --     if tolua.cast(self._gamelayer,"cc.layer") then
        --         --10S内限定三次
        --         --超限则提示网络异常
        --         local pReconnectTimes = cc.UserDefault:getInstance():getIntegerForKey("ReConnectTimes",0)                
        --         local pLastTime = cc.UserDefault:getInstance():getIntegerForKey("ReConnectTime",0)
        --         local pCurrentTime = os.time()
        --         if pCurrentTime - pLastTime > 10 then                    
        --             pReconnectTimes = 0
        --         end
        --         pReconnectTimes = pReconnectTimes + 1
        --         if pReconnectTimes <=3 then
        --             cc.UserDefault:getInstance():setIntegerForKey("ReConnectTimes",pReconnectTimes)
        --             cc.UserDefault:getInstance():setIntegerForKey("ReConnectTime",pCurrentTime)
        --             cc.UserDefault:getInstance():flush()                    
        --             -- G_GameFrame:onCloseSocket()
        --             -- performWithDelay(self,function()
        --                 self:onShowLoading()                        
        --                 G_GameFrame:OnResetGameEngine()
        --                 self:onStartGame() 
        --             -- end,1)
        --         else
        --             dismissNetLoading()
        --             showToast(g_language:getString("network_timeout"))   
        --         end
        --     end        
        -- end

        if tolua.cast(self._gamelayer,"cc.layer")  then            
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
    if args.code == 3 then  --断开游戏，自动重连
        --延迟1.0s展示
        local action = cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function ()
            showNetLoading()
        end))
        action:setTag(delayShowActTag)
        self:runAction(action)
    end
    if args.code == 4 then  --收到0-6消息，客户端主动发起重连
        -- self:onShowLoading()
        -- G_GameFrame:OnResetGameEngine()
		-- self:onStartGame()

        if tolua.cast(self._gamelayer,"cc.layer")  then            
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
    local pLength = 80    
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

    if self.onlineTime % 150 == 0 or self.onlineTime == 0 then              --150秒上报一次在线时长
        EventPost:addCommond(EventPost.eventType.ONLINE_TIME,"玩家在线时长",nil,self.onlineTime)
    end
    self.onlineTime = self.onlineTime + dt
    
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
                v.curTime = v.curTime - dt
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
                v.curTime = v.curTime - dt
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

function ClientScene:checkVipUp()
    if GlobalUserItem.VIPLevel then
        self.BtnHead:setVipVisible(true)
        self:UpdateHead()
        if m_last_vip_lv == nil then
            m_last_vip_lv = GlobalUserItem.VIPLevel
        else
            if m_last_vip_lv < GlobalUserItem.VIPLevel then
                --暂不显示
                G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_VIP_UP,{last_vip_lv = m_last_vip_lv})
                m_last_vip_lv = GlobalUserItem.VIPLevel
            end
        end
    end
end

--全局货币更新
function ClientScene:onUpdateUserScore(args)
    self:UpdateMoney()
    self:checkVipUp()
    self:checkIsBankrupt()
    --通知到银行界面
    G_event:NotifyEvent(G_eventDef.UI_BANK_UPDATE_GOLD,args)
end

--货币回调
function ClientScene:UpdateMoney()
    --更新Gold值
    -- dump(GlobalUserItem.lUserScore)
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
function ClientScene:UpdateHead()    
    --self.headImg = HeadSprite.loadHeadImg(self.BtnHead,GlobalUserItem.dwGameID,GlobalUserItem.wFaceID,true)
    self.BtnHead:updateHeadInfo(GlobalUserItem.wFaceID,GlobalUserItem.dwGameID)
end

function ClientScene:onGetUserUrl(data)
    local items = data.userData
    if items[GlobalUserItem.dwGameID] then
        HeadSprite.loadHeadUrl(self.BtnHead,GlobalUserItem.dwGameID,items[GlobalUserItem.dwGameID])
    end
end

function ClientScene:UpdateNickName()
    local nameStr,isShow = g_ExternalFun.GetFixLenOfString(GlobalUserItem.szNickName,80,"arial",24)
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
    -- dump(entergame)
    -- tdump(entergame, 'ClientScene:onEnterTable', 10)
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
            --self:checkIsBankrupt()
        end
    end
    GlobalData.serverTime.llServerTime = data.llServerTime
    GlobalData.serverTime.dwZone = data.dwZone
    OSUtil.saveTable(GlobalData.serverTime,"serverTime")
    --记录后端时间和本地时间差值
    EventPost:setServerTime(data.llServerTime)
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

--获取激活码限时礼包商品列表拉取完成事件
function ClientScene:onGetGiftCodeStatusResult()
    self.NodeGiftCodeShop:hide()
    if GlobalData.GiftCodeProducts then
        if #GlobalData.GiftCodeProducts.lsItems > 0 then
            self.NodeGiftCodeShop:show()
        end
    end
    self:adjustRightTopByProject()
end

--分享配置拉取完成
function ClientScene:onShareConfigCallback(data)
    self.m_shareConfig = data
    if data.byShareEnable == 0 then
        self.NodeShare:hide()
    else
        self.NodeShare:show()
    end
    self:adjustRightTopByProject()
end


--手机绑定同步完成
function ClientScene:onBindingStatusCallback(data)    
    self:adjustRightTopByProject()
end

--更新本地数据
function ClientScene:updateLocalDB()
    G_ServerMgr:C2S_QueryBaseEnsure()  --拉取破产补助配置
end

--破产补助配置回调
function ClientScene:onBaseEnsureCallback(data)
    -- dump(data,"baseEnsure")
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
function ClientScene:checkIsBankrupt()
    self:loadBaseEnsureConfig()
    if not GlobalData.baseEnsureData then 
        return 
    end
    if GlobalData.baseEnsureData.byRestTimes > 0 and (GlobalUserItem.lUserScore + GlobalUserItem.lUserInsure) < GlobalData.baseEnsureData.lScoreCondition then
        self.NodeBankrupt:show()
        if self.check_bankrupt then
            --游戏退出打开领取页面
            self.check_bankrupt = false
            G_event:NotifyEvent(G_eventDef.UI_SHOW_BASEENSURE,self) 
        end
    else        
        self.NodeBankrupt:hide()
    end
    self:adjustRightTopByProject()
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
                if ylAll.firstData.dwProductID then  
                    EventPost:addCommond(EventPost.eventType.BUY,"支付礼包",ylAll.firstData.dwProductID)          --充值礼包
                end
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
    local kindID = g_ExternalFun.getKindID(GlobalUserItem.roomMark)
    local serverKind = g_ExternalFun.getServerKind(GlobalUserItem.roomMark)
    
    if serverKind == 9 then -- 9 代表进入API游戏
        --进入api游戏先关闭背景音乐
        g_ExternalFun.stopMusic()
        G_GameFrame:setKindInfo(kindID, 101122049)
        G_GameFrame:onLogonAPIGame()
        return
    end
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
	G_GameFrame:setKindInfo(kindID, entergame._KindVersion)
	G_GameFrame:setViewFrame(self)
    G_GameFrame:onLogonRoom()    
end



function ClientScene:onShowLoading()
    showNetLoading(function()
	    -- G_GameFrame:onCloseSocket()
        -- showToast(g_language:getString("network_timeout"))
    end)
end

function ClientScene:showPopWait()
end

function ClientScene:ExitClient()
    --清理缓存vip信息
    m_last_vip_lv = nil
    --当日充值状态是否已经获取完毕
    GlobalData.PayInfoOver = false
    --当日是否已经充值
    GlobalData.TodayPay = false  
    --登录前3次礼包提示
    GlobalData.First3Times = 1  
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

--从游戏返回大厅再加载一次合图,隔帧加载，防止一帧内加载过多的合图内存爆炸
function ClientScene:preloadResources(index)
    local resourceName = hallPlist[index]
    if not resourceName then
        return
    end
    local plistName = string.format("client/res/Lobby/%s.plist",resourceName) 
    local plistPng = string.format("client/res/Lobby/%s.png",resourceName) 
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames(plistName,plistPng)    
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(1/30),
        cc.CallFunc:create(function() 
            self:preloadResources(index + 1)
        end)
    ))
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
    self.check_bankrupt = true --游戏中返回检测破产补助
    textureCache:removeUnusedTextures()
    self:preloadResources(1)             --预加载大厅资源,从第一个开始
    g_ExternalFun.stopAllEffects()
    self.scene:setVisible(true)    
    if GlobalData.HallClickGame then 
        local callback = function ()
            performWithDelay(self,function()
                if  GlobalData.ProductsOver and GlobalData.GiftEnable and GlobalData.PayInfoOver and not GlobalData.TodayPay and GlobalData.First3Times > 0 then            
                    GlobalData.First3Times = GlobalData.First3Times - 1
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
    -- if self.LastIndex then        
    --     self:onClickGame(self.LastIndex,true)
    -- end
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

        if (not version or (version and v._ServerResVersion > version)) then
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

function ClientScene:GetSubGameDownStutes(gameId)
    if self._gameDownList[gameId] then 
       return {true,self._gameDownList[gameId].percent}
    end
    return {false,0}
end

function ClientScene:GetGameInfoByGameId(gameId)
    local result = nil
    local pGameName = g_ExternalFun.isEasyGame(gameId)
    if pGameName then
        result = {
            _KindID = gameId,
            _KindName = pGameName,
            _KindType = "EasyGame"
        }
    else
        for i,v in pairs(self._gameList) do
            if tonumber(v._KindID) == gameId then
                result = v
                break
            end
        end
    end
    return result
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

    if gameinfo._KindType and gameinfo._KindType == "EasyGame" then
        g_EasyGameUpdater:StartFix(gameinfo._KindID,self)
    else
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
end

function ClientScene:updateProgress(sub, msg, mainpercent)
    local status = self._gameUpdateStutes[self._downgameid]
    if status and status.zip == true and status.res == true then
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
        if self._gameUpdateStutes and self._gameUpdateStutes[gameId] then
            self._gameUpdateStutes[gameId].zip = false    
            self._gameUpdateStutes[gameId].res = false  
            for k,v in pairs(self._gameList) do
                if v._KindID == self._downgameinfo._KindID then
                    self:getApp():getVersionMgr():setResVersion(v._ServerResVersion, v._KindID)
                    v._Active = true
                    break
                end
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
        node:dispatchEndCallBack(true)
     end
end
function ClientScene:OnUpdateDownSuccess(gameId)
    local node = self.gameUpdateNode[gameId] 
    if node then
        node:hide()
        node:dispatchEndCallBack(false)
    end
    local btn = self._updateBtn[gameId]
    if btn then
        btn:hide()
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
    for i=1,#roomInfo do
        if roomInfo[i].bOnline == true then
            _Index = i  --房间在线才能进
        end
    end
    local ext_json = {gameId = args.subGameId,roomId = roomInfo[_Index].roomMark}
    EventPost:addCommond(EventPost.eventType.PV,"点击进入小游戏",_Index - 1,nil,ext_json)
    self:GoStartGame({roomMark = roomInfo[_Index].roomMark,quickStart = true})
end

function ClientScene:onUserScoreLess(roomInfo)
    local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")
    local msg
    local dialog
    if roomInfo.ThresholdType and roomInfo.ThresholdType == "VIP" then        
        msg = g_language:getString("VIP_less")        
        msg = string.format(msg,roomInfo.lEnterScore)    
        dialog = QueryDialog:create(msg,function(ok)
            if ok then                     
                local pFlag = GlobalData.ProductsOver and GlobalData.GiftEnable
                if pFlag then
                    pFlag = GlobalData.ProductInfos[1].byActive or GlobalData.ProductInfos[2].byActive or GlobalData.ProductInfos[3].byActive
                end
                if pFlag then
                    local pData = {
                        ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
                    }
                    G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData) 
                    return
                else
                    G_event:NotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT)
                    G_event:NotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT_2)
                    --未拉取商品完成，则跳过响应
                    self:goToShop()
                end                
            end
        end)
    else            
        msg = g_language:getString("score_less_2")
        local str = g_format:formatNumber(roomInfo.lEnterScore,g_format.fType.standard,g_format.currencyType.GOLD)
        msg = string.format(msg,str)    
        dialog = QueryDialog:create(msg,function(ok)
            if ok then  
                if GlobalUserItem.lUserInsure + GlobalUserItem.lUserScore >= roomInfo.lEnterScore then
                    self:onButtonClicked(self.btnBank)
                else   
                    local pFlag = GlobalData.ProductsOver and GlobalData.GiftEnable
                    if pFlag then
                        pFlag = GlobalData.ProductInfos[1].byActive or GlobalData.ProductInfos[2].byActive or GlobalData.ProductInfos[3].byActive
                    end
                    if pFlag then
                        local pData = {
                            ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
                        }
                        G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData) 
                        return
                    else
                        G_event:NotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT)
                        G_event:NotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT_2)
                        --未拉取商品完成，则跳过响应
                        self:goToShop()
                    end
                end
            end
        end)
    end
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(dialog)    
    dialog:setPosition(cc.p(0,0))
end

function ClientScene:onSystemNoticeInfo(_cmdData)
    if _cmdData.pCount == 0 then
        G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="HallSystemNotice"})
    else
        G_event:NotifyEvent(G_eventDef.UI_OPEN_SYSTEM_NOTICE_LAYER, {cmdData = _cmdData, NoticeNext = true})
    end
end

function ClientScene:onHallActivityInfo()
    if not self.HallActivity then
        return
    end    
    self.HallActivity:removeAllPages()
    self.HallActivity:setDirection(ccui.PageViewDirection.HORIZONTAL)
     self.HallActivity:setBounceEnabled(false)
    self.HallActivity:setTouchEnabled(true)
    self.HallActivity:setSwallowTouches(true)
    self.HallActivity:setClippingEnabled(true)
    local pSize = self.HallActivity:getContentSize()
    local pActivitySize = #GlobalData.ActivityInfos
    local dian = self.HallActivity._dian
    local content = dian:getParent()
    local dianTab = {}
    local curLong = 30           --点之间的间距
    for i = 1,pActivitySize do        
        local imageView = ccui.ImageView:create(GlobalData.ActivityInfos[i].pathSmall or "client/res/BigImage/Bg_Hall_Activity.png")
        -- imageView:setContentSize(pSize)
        local panel = ccui.Layout:create()
        panel:setContentSize(cc.size(728,295))
        panel:addChild(imageView)
        imageView:ignoreContentAdaptWithSize(false)
        imageView:setName("imageView")
        imageView:setAnchorPoint(0,0)
        imageView:setPosition(cc.p(0,0))
        imageView:setContentSize(cc.size(728,295))
        panel:setTag(i)
        panel:setTouchEnabled(true)
        panel:onClicked(handler(self,self.onPageClicked))  
        self.HallActivity:addPage(panel)
        local dianNode = dian:clone()
        dianNode:show()
        dianNode:setAnchorPoint(0.5,0.5)
        content:addChild(dianNode)
        dianTab[#dianTab + 1] =  dianNode
        dianNode:setPosition(cc.p(58 + (i - 1) * curLong,62))
    end  
    self:loadActivityPic()    
    self:removeTimerEvent("ActivityTimer")
    self:addTimerEvent("ActivityTimer",6,function() 
        --执行了回调，轮播活动
        local curPageIndex = self.HallActivity:getCurrentPageIndex()
        local nextPageIndex = (curPageIndex + 1) % pActivitySize
        self.HallActivity:scrollToPage(nextPageIndex)
    end,false)
    self.HallActivity:scrollToPage(0)
    local function pageViewEvent(sender,eventType)
        if eventType == ccui.PageViewEventType.turning then
            local curPageIndex = self.HallActivity:getCurrentPageIndex() + 1
            for k = 1,#dianTab do
                local dian = dianTab[k]
                if k == curPageIndex then
                    dian:loadTexture("client/res/Lobby/GameIcon/dating_guanggao_dian2.png",1)
                else
                    dian:loadTexture("client/res/Lobby/GameIcon/dating_guanggao_dian1.png",1)
                end
            end
        end
    end

    self.HallActivity:addEventListener(pageViewEvent)
end

function ClientScene:loadActivityPic()
    local pActivitySize = #GlobalData.ActivityInfos
    for i = 1,pActivitySize do
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
    local pItems = self.HallActivity:getItems()
    for i, v in ipairs(pItems) do
        if v:getTag() == pIndex then
            v:getChildByName("imageView"):loadTexture(GlobalData.ActivityInfos[pIndex].pathSmall)
        end
    end
end

function ClientScene:onPageClicked()
    local pIndex = self.HallActivity:getCurrentPageIndex()+1
    G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_ACTIVITY,{scene = self,Index=pIndex})
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
    self:adjustRightTopByProject()
end

--绑定手机奖励领取返回
function ClientScene:onBindPhoneResult(pData)
    if pData.dwErrorCode == 0 then
        self:showAward(pData.lRewardScore, "client/res/public/mrrw_jb_3.png")        
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
    G_event:NotifyEvent(G_eventDef.CASH_CHECKRETURN,pData.tmDateTime) 
end

--核对转盘
function ClientScene:checkOpenTurnTable()
    self:onClickOpenTurnTable(true)
end

--弹出分享步骤
function ClientScene:checkShareStep()
    G_event:NotifyEvent(G_eventDef.UI_SHARESTEP,{NoticeNext=true})
end

--砸金蛋界面
function ClientScene:onOpenEggLayer()
    --G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_EGG,{NoticeName="EggBreak"})
    G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_EGG,{NoticeNext=true})
end

--点击打开转盘,先请求用户信息
function ClientScene:onClickOpenTurnTable(isShowNext)
    --    G_event:NotifyEvent(G_eventDef.UI_SHOW_TURNTABLE,turnData) --转盘
    --    do return end
    --获取转盘配置
    if not TurnTableManager.getData() then
        G_ServerMgr:C2s_getTurnConfig() 
    end
    TurnTableManager.setIsShowNext(isShowNext)
    G_ServerMgr:C2s_getTurnUserConfig(6)
end
    
function ClientScene:onTarotResult(data)
    -- self.NodeTarot:setVisible(data.cbEnable > 0)
    -- if data.cbEnable == 3 then
    --     self.NodeTarot:hide()        
    -- elseif data.cbEnable == 2 then
    --     self:startCountdown(data)
    -- end
    -- self:adjustRightTopByProject()

    if data.cbEnable == 2 then
        self:startCountdown(data)
    end
end

--检测用户无响应
function ClientScene:onCheckLevel()    
    self.DeltaSecond = self.DeltaSecond - 1
    if self.DeltaSecond <= 0 then
        -- return
    -- elseif self.DeltaSecond == 0 then        
        self:PauseAction()
    end
end

function ClientScene:PauseAction()
    for i, v in ipairs(self.AnimationList) do
        if v and not tolua.isnull(v) then
            v:pause()
        end
    end
end

function ClientScene:ResumeAction()
    for i, v in ipairs(self.AnimationList) do
        if v and not tolua.isnull(v) then
            v:resume()
        end
    end
end

--挂倒计时节点
function ClientScene:addTimeNode(pNode)
    self.m_timeNodeBG = ccui.ImageView:create("client/res/public/tarot_time_bg.png")
    :addTo(pNode)
    :setPosition(cc.p(2,-44))
    :setZOrder(1)
    :hide()
    :setScale9Enabled(true)
    :setContentSize(cc.size(194,35))
    self.m_TextTarotTime = ccui.Text:create("", "base/res/fonts/arial.ttf",26)
    :addTo(pNode)
    :setPosition(cc.p(2,-44))
    :setTextColor(cc.c3b(255,218,45))
    :enableOutline({r = 255, g = 218, b = 45, a = 255}, 1)
    :setZOrder(2)
    :hide() 
end
--开始倒计时
function ClientScene:startCountdown(args)
    self.m_TextTarotTime:stopAllActions()
    self.m_nTimeLeave = args.nTimeLeave
    local updateTime = function() 
        self.m_timeNodeBG:show()
        self.m_TextTarotTime:show()
        self.m_nTimeLeave = self.m_nTimeLeave - 1
        if self.m_nTimeLeave < 0 then
            self.m_timeNodeBG:hide()
            self.m_TextTarotTime:stopAllActions()
            self.m_TextTarotTime:hide()
            G_ServerMgr:C2S_RequestRedData()  --请求刷新红点数据
            return
        end
        local tempText = string.format("%.2d:%.2d:%.2d", self.m_nTimeLeave/(60*60), self.m_nTimeLeave/60%60, self.m_nTimeLeave%60)
        self.m_TextTarotTime:setString(tempText)
        if math.modf(self.m_nTimeLeave/(60*60)) > 72 then
            self.m_timeNodeBG:hide()
            self.m_TextTarotTime:hide()   --大厅入口超过3天的倒计时不显示
        end
    end
    updateTime()
    schedule(self.m_TextTarotTime,updateTime,1)
end

--检测是否要更新
function ClientScene:GetSubGameStutes(gameId,type)
    if type == HallTableViewUIConfig.GAME_TYPE.API then                 --如果是API游戏
        return not g_EasyGameUpdater:CheckFix(gameId)
    elseif type == HallTableViewUIConfig.GAME_TYPE.SLOCAL then          --否则如果是本地游戏
        local isWin32 = (g_TargetPlatform == cc.PLATFORM_OS_WINDOWS)
        if ylAll.UPDATE_OPEN == false or isWin32 then 
            return false 
        end
        if self._gameUpdateStutes[gameId] then
            return self._gameUpdateStutes[gameId].res or self._gameUpdateStutes[gameId].zip
        end
    end
    
    return false 
end

return ClientScene