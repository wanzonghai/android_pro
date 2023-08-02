local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local ShareTurnTableLayer = class("ShareTurnTableLayer",BaseLayer)
local HeadNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HeadNode")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
local Earthquake = appdf.req(appdf.CLIENT_SRC.."Tools.Earthquake")

function ShareTurnTableLayer:ctor(args)
    ShareTurnTableLayer.super.ctor(self)
    display.loadSpriteFrames("client/res/ShareTurnTable/ShareTurnTableGUI.plist","client/res/ShareTurnTable/ShareTurnTableGUI.png")
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self._args = args
    self:loadLayer("ShareTurnTable/ShareTurnTableLayer.csb")
    self:init()
end

function ShareTurnTableLayer:initData()
    self._nowPageIndex = 1
    self._nowdwPageSize = 10
    self._nowwCount = 0
    self._requestTime = 0
    self._spineRunAction = nil
    self._nowRotation = 0
    self._spineZhiZhen = {}
    self._luckIndex = 1
    self._autoScrollSpeed = 40          --每秒40个像素滑动
    self._scrollTabItems = {}
    self._selectLevelData = nil
end

function ShareTurnTableLayer:initView()
    self.bg = self:getChildByName("bg")
    self.rightNodeOld = self:getChildByName("rightNodeOld")
    self.rightNodeOld:hide()
    self.showTipsLayer3 = self:getChildByName("showTipsLayer3")
    self.showTipsLayer3:hide()
    self.showVipBtn = self:getChildByName("showVipBtn")
    g_ExternalFun.adapterScreen(self.bg)
    self.nowScoreAdd = self:getChildByName("nowScoreAdd")  
    self.nowScoreAdd:hide()
    self.myScoreAdd = self:getChildByName("myScoreAdd")
    self.myScoreAdd:hide()
    self.spineBgNode = self:getChildByName("spineBgNode")
    self.HeadInfoNode = self:getChildByName("HeadInfoNode")
    self.goldLabel = self.HeadInfoNode:getChildByName("Panel_1"):getChildByName("goldLabel")
    self.ExtraLabel = self.HeadInfoNode:getChildByName("Panel_1"):getChildByName("ExtraLabel")
    self.closeBtn = self:getChildByName("closeBtn")
    self.howBtn = self:getChildByName("howBtn")
    self.historyBtn = self:getChildByName("historyBtn")
    self.historyPanel = self:getChildByName("historyPanel")
    self.clonePanel = self.historyPanel:getChildByName("clonePanel")
    self.clonePanel:retain()
    self.clonePanel:removeFromParent()
    self.turnTable = self:getChildByName("turnTable")
    self.spinBtn = self:getChildByName("spinBtn")
    self.spinText = self.spinBtn:getChildByName("spinText")
    self.spinTimesText = self.spinBtn:getChildByName("spinTimesText")
    self.spinTimesText:hide()
    self.spinTimesText = self:getCountTextByNode("client/res/ShareTurnTable/%sx.png")
    self.spinBtn:addChild(self.spinTimesText)
    self.content = self:getChildByName("content")
    self.leftTopNode = self:getChildByName("leftTopNode")
    self.rightTopNode = self:getChildByName("rightTopNode")
    self.middleNode2 = self:getChildByName("middleNode2")
    self.turnTableNode = self.middleNode2:getChildByName("turnTableNode")
    self.turnTableBody = self.turnTableNode:getChildByName("turnTableBody")  
    self.nowScoreText = self:getChildByName("nowScoreText")
    self.leftNode = self:getChildByName("leftNode")
    self.leftPanel = self.leftNode:getChildByName("leftPanel")
    self.leftBtn1 = self.leftPanel:getChildByName("leftBtn1")
    self.leftBtn2 = self.leftPanel:getChildByName("leftBtn2")
    self.leftBtn3 = self.leftPanel:getChildByName("leftBtn3")
    self.scoreText1 = self:getChildByName("scoreText1")
    self.percentText = self:getChildByName("percentText")
    self.scoreText2 = self:getChildByName("scoreText2")
    self.miaoshu1 = self:getChildByName("miaoshu1")
    self.miaoshu2 = self:getChildByName("miaoshu2")
    self.RecibirBtn = self:getChildByName("RecibirBtn")
    self.RecibirBtn:setBright(false)
    self.jianTou = self:getChildByName("jianTou")
    self.rightNode = self:getChildByName("rightNode")
    self.rightNode:hide()
    self.nowScoreText2 = self:getChildByName("nowScoreText2")
    self.rightTips1 = self:getChildByName("rightTips1")
    self.rightTips2 = self:getChildByName("rightTips2")
    self.RecibirBtn2 = self:getChildByName("RecibirBtn2")
    self.leftTopLoingBar = self:getChildByName("leftTopLoingBar")
    self.tudoBtn = self:getChildByName("tudoBtn")
    self.tudoText = self.tudoBtn:getChildByName("tudoText")
    self.tudoTimes = self.tudoBtn:getChildByName("tudoTimes")
    self.middleNode1 = self:getChildByName("middleNode1")
    self.middleNode3 = self:getChildByName("middleNode3")
    self.clonePanel3 = self.middleNode3:getChildByName("clonePanel3")
    self.clonePanel3:hide()
    self.middleNode1:hide()
    self.middleNode2:hide()
    self.middleNode3:hide()
    self.node1ListView = self:getChildByName("node1ListView")
    self.node1ListView:setScrollBarEnabled(false)
    self.recommendBtn = self:getChildByName("recommendBtn")
    self.enjoyBtn = self:getChildByName("enjoyBtn")
    self.peoPleNum = self:getChildByName("peoPleNum")
    self.youXiaoNum = self:getChildByName("youXiaoNum")
    self.priceText = self:getChildByName("priceText")
    self.recommendBtn3 = self:getChildByName("recommendBtn3")
    self.enjoyBtn3 = self:getChildByName("enjoyBtn3")
    self.priceText_0 = self:getChildByName("priceText_0")
    self.peoPleNum3 = self:getChildByName("peoPleNum3")
    self.priceText3 = self:getChildByName("priceText3")
    self.priceMiddle3Text = self:getChildByName("priceMiddle3Text")
    self.ReceBerMiddle3Btn = self:getChildByName("ReceBerMiddle3Btn")
    self.node3ListView = self:getChildByName("node3ListView")
    self.peoPleNum1 = self:getChildByName("peoPleNum1")
    self.youXiaoNum1 = self:getChildByName("youXiaoNum1")
    self.priceText1 = self:getChildByName("priceText1")
    self.nodeText1 = self:getChildByName("nodeText1")
    self.nodeText3 = self:getChildByName("nodeText3")
    self.noDataText = self:getChildByName("noDataText")
    local clonePanel1 = self.middleNode1:getChildByName("clonePanel1")
    clonePanel1:retain()
    clonePanel1:removeFromParent()
    self.clonePanel1 = clonePanel1
    local cloneGiftNode1 = clonePanel1:getChildByName("cloneGiftNode1")
    cloneGiftNode1:retain()
    cloneGiftNode1:removeFromParent()
    self.cloneGiftNode1 = cloneGiftNode1
end

function ShareTurnTableLayer:init()
    self:initData()
    self:initView()
    self:initListener()
   -- self:startAction()  
    self:initMyHead()
  --  self:showAnimation()
    self:performWithDelay(handler(self,self.createBgSpine),1/50)
    self.llRequireScore = self._args.llRequireScore
    self.llCurrentScore = self._args.llCurrentScore 
    self.dwWithdrawCount = self._args.dwWithdrawCount       --是否提现过（新用户）
    self.dwStageID = self._args.dwStageID                   --是否设置过挡位

    self:updateLeftGift()
    self:updateSpinBtnStatus()
    showNetLoading()
    G_ServerMgr:requestTurnLuckHistory(self._luckIndex)
   -- G_ServerMgr:getRecommendGiftInfo()

    G_ServerMgr:requestShare_Config()                --请求拉新配置信息
    G_ServerMgr:CMD_MB_SharePayRebateLoadConfig()                --请求充值返利配置信息
    self:doDisplay()
end

function ShareTurnTableLayer:onExit()
    ShareTurnTableLayer.super.onExit(self)
    self.clonePanel:release()
    self.clonePanel1:release()
    self.cloneGiftNode1:release()
    
    G_event:RemoveNotifyEvent(G_eventDef.CMD_MB_SharePayRebateTakeReward)
    G_event:RemoveNotifyEvent(G_eventDef.CMD_MB_SharePayRebateGetRecord)
    G_event:RemoveNotifyEvent(G_eventDef.CMD_MB_SharePayRebateGetStatus)
    G_event:RemoveNotifyEvent(G_eventDef.ShareGetNewBenefitConfig)
    G_event:RemoveNotifyEvent(G_eventDef.ShareGift_Config)
    G_event:RemoveNotifyEvent(G_eventDef.SET_TIXIAN_LEVEL_RECEIVE)
    G_event:RemoveNotifyEvent(G_eventDef.TUDO_DENTRO_DATA)
    G_event:RemoveNotifyEvent(G_eventDef.RECEIVE_VIP_ANDGIFT)
    G_event:RemoveNotifyEvent(G_eventDef.TIXIAN_LEVEL_DATA)
    G_event:RemoveNotifyEvent(G_eventDef.SHARE_TURN_RECEIVEGIFT)
    G_event:RemoveNotifyEvent(G_eventDef.SHARE_TURN_RESLOVE)
    G_event:RemoveNotifyEvent(G_eventDef.SHARE_TURN_LUCKHISTORY)
    G_event:RemoveNotifyEvent(G_eventDef.ShareTurnreceiveInfosReceive)
    G_event:RemoveNotifyEvent(G_eventDef.ShareTurnreceiveInfosReceiveGet)
    display.removeSpriteFrames("client/res/ShareTurnTable/ShareTurnTableGUI.plist","client/res/ShareTurnTable/ShareTurnTableGUI.png")
end

function ShareTurnTableLayer:initListener()
    self.ReceBerMiddle3Btn:addTouchEventListener(handler(self,self.onTouch))
    self.showTipsLayer3:addTouchEventListener(handler(self,self.onTouch))
    self.closeBtn:addTouchEventListener(handler(self,self.onTouch))
    self.howBtn:addTouchEventListener(handler(self,self.onTouch))
    self.historyBtn:addTouchEventListener(handler(self,self.onTouch))
    self.spinBtn:addTouchEventListener(handler(self,self.onTouch))
    self.RecibirBtn:addTouchEventListener(handler(self,self.onTouch))
    self.RecibirBtn2:addTouchEventListener(handler(self,self.onTouch))
    self.showVipBtn:addTouchEventListener(handler(self,self.onTouch))
    self.tudoBtn:addTouchEventListener(handler(self,self.onTouch))
    self.recommendBtn:addTouchEventListener(handler(self,self.onTouch))
    self.recommendBtn3:addTouchEventListener(handler(self,self.onTouch))
    self.enjoyBtn:addTouchEventListener(handler(self,self.onTouch))
    self.enjoyBtn3:addTouchEventListener(handler(self,self.onTouch))
    self.node3ListView:addScrollViewEventListener(handler(self,self.scrollViewEvent))
    self.node3ListView:setScrollBarEnabled(false)
    
    G_event:AddNotifyEvent(G_eventDef.CMD_MB_SharePayRebateTakeReward,handler(self,self.CMD_MB_SharePayRebateTakeReward))
    G_event:AddNotifyEvent(G_eventDef.CMD_MB_SharePayRebateGetRecord,handler(self,self.CMD_MB_SharePayRebateGetRecord))
    G_event:AddNotifyEvent(G_eventDef.CMD_MB_SharePayRebateGetStatus,handler(self,self.CMD_MB_SharePayRebateGetStatus))
    G_event:AddNotifyEvent(G_eventDef.ShareGetNewBenefitConfig,handler(self,self.shareGetNewBenefitConfg))
    G_event:AddNotifyEvent(G_eventDef.ShareGift_Config,handler(self,self.shareGift_config))
    G_event:AddNotifyEvent(G_eventDef.SET_TIXIAN_LEVEL_RECEIVE,handler(self,self.setReceive))
    G_event:AddNotifyEvent(G_eventDef.TUDO_DENTRO_DATA,handler(self,self.autoGiftData))
    G_event:AddNotifyEvent(G_eventDef.SHARE_TURN_RECEIVEGIFT,handler(self,self.getGift))
    G_event:AddNotifyEvent(G_eventDef.SHARE_TURN_RESLOVE,handler(self,self.resolved))
    G_event:AddNotifyEvent(G_eventDef.SHARE_TURN_LUCKHISTORY,handler(self,self.luckList))
    G_event:AddNotifyEvent(G_eventDef.ShareTurnreceiveInfosReceive,handler(self,self.receiveInfo))              --奖励数据消息
    G_event:AddNotifyEvent(G_eventDef.RECEIVE_VIP_ANDGIFT,handler(self,self.receiveVIPData))
    G_event:AddNotifyEvent(G_eventDef.TIXIAN_LEVEL_DATA,handler(self,self.receiveTiXianData))                                    --获取提现挡位数据
    G_event:AddNotifyEvent(G_eventDef.ShareTurnreceiveInfosReceiveGet,handler(self,self.goToreceiveInfo))       --领奖返回
    G_event:AddNotifyEvent(G_eventDef.ShareGiftBoxInfo,handler(self,self.GiftBoxInfo))                      --分享宝箱信息
    G_event:AddNotifyEvent(G_eventDef.ShareGiftBoxReceive,handler(self,self.receiveBoxGift))              --领取宝箱奖励数据消息
end


function ShareTurnTableLayer:onTouch(sender,eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.ended then
        if name == "closeBtn" then
            self:close()
        elseif name == "showTipsLayer3" then
            self.showTipsLayer3:hide()
        elseif name == "howBtn" then
            if self._lastLeftIndex == 2 then
                G_event:NotifyEvent(G_eventDef.UI_SHARESTEP)
            elseif self._lastLeftIndex == 3 then
                self.showTipsLayer3:show()
            elseif self._lastLeftIndex == 1 then
                G_event:NotifyEvent(G_eventDef.UI_SHARESTEP)
            end
        elseif name == "historyBtn" then
            G_ServerMgr:requestTurnTableUserInvited(1)               --获取邀请记录
            G_event:NotifyEvent(G_eventDef.UI_SHARETURNTABLEHISTORY,GlobalUserItem.share_vip_and_gift)
        elseif name == "spinBtn" then               --点击旋转
            if self.dwStageID == 0 then             --如果没设置过挡位
                showToast("Nível de saque não definido.")            --提现等级未设置
                if self._selectLevelData then       --如果已经有挡位数据
                    G_event:NotifyEvent(G_eventDef.UI_SHOW_SELECTLAYER,{result = self._selectLevelData,dwWithdrawCount = self.dwWithdrawCount
                    })
                else
                    showNetLoading()
                    G_ServerMgr:requestTiXianLevel()
                end
                return
            end
            if self._args.dwRestCount <= 0 then
                G_event:NotifyEvent(G_eventDef.UI_SHAREINVITED)
                return
            end
            local llRequireScore = self.llRequireScore
            local llCurrentScore = self.llCurrentScore
            if llCurrentScore >= llRequireScore then            --如果可领取积分满了，就不能点击转盘抽奖。先领完后才能转盘抽奖
                showToast("Por favor, reivindique sua recompensa primeiro.")
                self:shakeNode(self.RecibirBtn)
                return
            end  
            self:setSpinBtnTouchEnabled(false)
            G_ServerMgr:requestTurnTableSolved()
        elseif name == "BtnAddGold" then
            if not GlobalData.ProductsOver then return end
            if G_GameFrame  and G_GameFrame._viewFrame and G_GameFrame._viewFrame.goToShop then
                self:close()
                G_GameFrame._viewFrame:goToShop()
            end  
        elseif name == "RecibirBtn" then
            G_ServerMgr:requestTurnTableGetGift()              -- 领取奖励 发送： 1710
        elseif name == "RecibirBtn2" then
            G_ServerMgr:receiveRecommendGift()
        elseif name == "showVipBtn" then
            -- if GlobalUserItem.share_vip_and_gift then
            --     G_event:NotifyEvent(G_eventDef.shareVipDescrible,GlobalUserItem.share_vip_and_gift)
            -- else
            --     showNetLoading()
            --     G_ServerMgr:receiveVIP_Gift() 
            -- end  
        elseif name == "tudoBtn" then           --自动旋转
            if self.dwStageID == 0 then             --如果没设置过挡位
                showToast("Nível de saque não definido.")            --提现等级未设置
                if self._selectLevelData then       --如果已经有挡位数据
                    G_event:NotifyEvent(G_eventDef.UI_SHOW_SELECTLAYER,{result = self._selectLevelData,dwWithdrawCount = self.dwWithdrawCount
                    })
                else
                    showNetLoading()
                    G_ServerMgr:requestTiXianLevel()
                end
                return
            end
            if self._args.dwRestCount <= 0 then
                G_event:NotifyEvent(G_eventDef.UI_SHAREINVITED)
                return
            end
            local llRequireScore = self.llRequireScore
            local llCurrentScore = self.llCurrentScore
            if llCurrentScore >= llRequireScore then            --如果可领取积分满了，就不能点击转盘抽奖。先领完后才能转盘抽奖
                showToast("Por favor, reivindique sua recompensa primeiro.")
                self:shakeNode(self.RecibirBtn)
                return
            end 
            showNetLoading()
            G_ServerMgr:TudoDentroBtn(self.llRequireScore)
        elseif name == "recommendBtn" or name == "recommendBtn3" then
            G_event:NotifyEvent(G_eventDef.UI_SHOW_SHARE,GlobalUserItem.MAIN_SCENE)
        elseif name == "enjoyBtn" or name == "enjoyBtn3" then
            G_event:NotifyEvent(G_eventDef.showSHAREPHONEDATA)
        elseif name == "ReceBerMiddle3Btn" then             --领取拉新记录奖励
            showNetLoading()
            G_ServerMgr:CMD_MB_SharePayRebateTakeReward(self._laXinScore)
        end
    end
end

function ShareTurnTableLayer:doDisplay()
    self._lastLeftIndex = nil
    for k = 1,3 do
        local btn = self["leftBtn"..k]
        local animationNode = btn:getChildByName("animationNode")
        local animation = self:addSpine(animationNode,"anniu")
        animation:setAnimation(0,"anniu",true)
        btn._animation = animation
        animation:hide()
        local btnIcon = btn:getChildByName("btnIcon")
        btnIcon:ignoreContentAdaptWithSize(true)
        btn._btnIcon = btnIcon
        if k == 2 then
            btnIcon:setPositionX(btnIcon:getPositionX() + 3)
        end
        btnIcon:setPositionY(btnIcon:getPositionY() + 7)
        btn:addTouchEventListener(function(sender,eventType) 
            if eventType == ccui.TouchEventType.began then
                if btn == self._lastLeftIndex then
                    return
                end
                btn._animation:show()
                btnIcon:loadTexture(string.format("client/res/ShareTurnTable/bt_font00%s.png",k),1)
            elseif eventType == ccui.TouchEventType.ended then
                self:selectLeftIndex(k)
            elseif eventType == ccui.TouchEventType.canceled then
                btnIcon:loadTexture(string.format("client/res/ShareTurnTable/bt_font000%s.png",k),1)
                btn._animation:hide()
            end
        end)
    end
    self:setRichText()
    self:setRichText2()
end

function ShareTurnTableLayer:selectLeftIndex(index)
    if index == self._lastLeftIndex then return end
    self._lastLeftIndex = index
    for k = 1,3 do
        local btn = self["leftBtn"..k]
        if k ~= index then
            btn._animation:hide()
            btn._btnIcon:loadTexture(string.format("client/res/ShareTurnTable/bt_font000%s.png",k),1)
            btn:setTouchEnabled(true)
        else
            btn._animation:show()
            btn._btnIcon:loadTexture(string.format("client/res/ShareTurnTable/bt_font00%s.png",k),1)
            btn:setTouchEnabled(false)
        end
    end
    if index == 1 then
        if self._middle1 then
            self:showMiddleNode(1)
        else
            showNetLoading()
            G_ServerMgr:requestGiftBoxInfo()                --请求宝箱信息
        end
    elseif index == 2 then
        if self.dwStageID == 0 then             --没设置过挡位，要请求以下
            showNetLoading()
            G_ServerMgr:requestTiXianLevel()
        end
        self:showMiddleNode(2)
    elseif index == 3 then
        if self._middle3 then
            self:showMiddleNode(3)
        else
            showNetLoading()
            G_ServerMgr:CMD_MB_SharePayRebateGetStatus()
        end
        
    end
end

function ShareTurnTableLayer:showMiddleNode(index)
    if index == 1 then
        self.middleNode1:show()
        self.middleNode2:hide()
        self.middleNode3:hide()
        self.rightNode:hide()
    elseif index == 2 then
        self.middleNode1:hide()
        self.middleNode2:show()
        self.middleNode3:hide()
        self.rightNode:show()
    elseif index == 3 then
        self.middleNode1:hide()
        self.middleNode2:hide()
        self.middleNode3:show()
        self.rightNode:hide()
    end
end

--vip对应关系数据返回
function ShareTurnTableLayer:receiveVIPData(pData)   
   -- G_event:NotifyEvent(G_eventDef.shareVipDescrible,GlobalUserItem.share_vip_and_gift)
    
end

--领取奖励返回
function ShareTurnTableLayer:getGift(pData)
    local dwErrorCode = pData.dwErrorCode
    if dwErrorCode~=0 then return end
    local llScore = pData.llScore                   --当前收到的分数，炸花专用
    local llRequireScore = pData.llRequireScore or 200     --下一次的需求分数，当前累积的会被清0
    self.llRequireScore = llRequireScore
    self.llCurrentScore = 0
    self:updateLeftGift()
    self:updateSpinBtnStatus()
    self:showRewardLayer(llScore)
    self:addMyDataToScroll({
        wFaceID = GlobalUserItem.wFaceID,
        szNickName = GlobalUserItem.szNickName,
        llScore = llScore,
        tmRewardDate = GlobalData.serverTime.llServerTime + GlobalData.serverTime.dwZone * 3600
    })
    self:updateMyScore(llScore)
    self.dwWithdrawCount = 1                --不再是新用户,已经提现过
    self.dwStageID = 0                      --要重新设置提现挡位，所以数值设置为0
    self._selectLevelData = nil             --挡位数据要重新请求
    GlobalUserItem.hasShareWithdraw = true
    showNetLoading()
    G_ServerMgr:requestTiXianLevel()
end

--点击全部领奖返回
function ShareTurnTableLayer:autoGiftData(pData)
    dismissNetLoading()
    local int64 = Integer64:new()
    local result = {
        dwErrorCode  = pData:readdword(),
        wRestCount   = pData:readword(),                    -- 剩余的次数
        llTotalCash = pData:readscore(int64):getvalue(),    -- 抽到的现金总和
        llTotalScore = pData:readscore(int64):getvalue(),   -- 抽到的金币总和
        wTotalFreeCount = pData:readword(),                 -- 抽到的免费次数总和
        wCount = pData:readword(),                          -- 抽奖的次数
        lsItems = {}                                        -- 抽奖的结果明细
    }
    dump(result)
    if result.dwErrorCode ~= 0 then
        if result.dwErrorCode == 1500 then
            print("剩余次数不足")
        elseif result.dwErrorCode == 1504 then
            print("已达到提现标准，无法抽奖")
        elseif result.dwErrorCode == 1509 then
            print("没有设置提现档位，无法抽奖")
        else
            print("未知错误")
        end
    else
        self._args.dwRestCount = result.wRestCount
        self:showRewardLayer2(result)
    end 
end

--点击旋转返回
function ShareTurnTableLayer:resolved(pData)
    local dwErrorCode = pData.dwErrorCode
    if dwErrorCode~=0 then 
        return 
    end
    local cbItemIndex = pData.cbItemIndex
    local cbItemType = pData.cbItemType         --格子类型
    local llReward = pData.llReward
    self._args.dwRestCount = self._args.dwRestCount - 1
    self._llReward = llReward           --返回的数值

    self:updateSpinTimes()
    self:goTurnTable(cbItemIndex + 1)
   
end

--更新次数
function ShareTurnTableLayer:updateSpinTimes()
    self.spinTimesText:setString(self._args.dwRestCount)
    self.spinTimesText:setPosition(cc.p(145.50 - self.spinTimesText:getContentSize().width/2,100))
    if self._args.dwRestCount > 100 then
        self.tudoTimes:setString("100 SPIN")
    else
        self.tudoTimes:setString(self._args.dwRestCount.." SPIN")
    end
end

--更新spin按钮状态
function ShareTurnTableLayer:updateSpinBtnStatus()
    self:updateSpinTimes()
    local llRequireScore = self.llRequireScore
    local llCurrentScore = self.llCurrentScore
    if llCurrentScore >= llRequireScore then            --如果可领取积分满了，就不能点击转盘抽奖。先领完后才能转盘抽奖
        self:setSpinBtnTouchEnabled(false)
    else
        self:setSpinBtnTouchEnabled(true)
    end
end

function ShareTurnTableLayer:setSpinBtnTouchEnabled(bool)
    self.tudoBtn:setTouchEnabled(bool)
    self.tudoBtn:setBright(bool)
    self.spinBtn:setTouchEnabled(bool)
    self.spinText:setBright(bool)
    self.spinBtn:setBright(bool)
    self.spinTimesText:setColor(bool and cc.c3b(255,255,255) or cc.c3b(190,190,190))
end

--设置挡位
function ShareTurnTableLayer:setDwData(stageScore)
    self.llRequireScore = stageScore
    self:updateLeftGift()
    self:updateSpinBtnStatus()
end

function ShareTurnTableLayer:updateLeftGift()
    local llRequireScore = self.llRequireScore
    local llCurrentScore = self.llCurrentScore
    if self.llCurrentScore >= self.llRequireScore then
        self.llCurrentScore = self.llRequireScore
    end  
    local llCurrentScore = self.llCurrentScore
    self.scoreText2:setString(string.format("R$ %s",g_format:formatNumber(llRequireScore,g_format.fType.standard)))
    self.nowScoreText:setString(string.format("R$:%s",g_format:formatNumber(llCurrentScore,g_format.fType.standard)))
    local cha = llRequireScore - llCurrentScore
    self.scoreText1:setString(string.format("R$:%s",g_format:formatNumber(cha >=0 and cha or 0,g_format.fType.standard)))
    if llCurrentScore>=llRequireScore then
        self.RecibirBtn:setBright(true)
        self.RecibirBtn:setTouchEnabled(true)
    else
        self.RecibirBtn:setBright(false)
        self.RecibirBtn:setTouchEnabled(false)
    end
    
    local percent = llCurrentScore / llRequireScore * 100
    if llRequireScore == 0 then
        self.percentText:setString("0 %")
        self.RecibirBtn:setBright(false)
        self.RecibirBtn:setTouchEnabled(false)
    else
        self.percentText:setString(string.format("%.2f",percent).." %")
    end
    if percent >= 99 and percent < 100 then
        percent = 98.5
    end  
    self.leftTopLoingBar:setPercent(percent)
    local size = self.scoreText2:getContentSize()
    local x = self.scoreText2:getPositionX()
    self.miaoshu1:setPositionX(x - size.width/2 - 2)
    self.miaoshu2:setPositionX(x + size.width/2 + 2)
end

function ShareTurnTableLayer:initMyHead()
    local Panel_1 = self.HeadInfoNode:getChildByName("Panel_1")
    local head_node = Panel_1:getChildByName("head_node")
    local BtnAddGold = Panel_1:getChildByName("BtnAddGold")
    local nick = Panel_1:getChildByName("nick")
    self.goldValue = Panel_1:getChildByName("goldValue")  
    local ExtraValue = Panel_1:getChildByName("ExtraValue")
    head_node:removeAllChildren()
    head_node:addChild(HeadNode:create())
    BtnAddGold:addTouchEventListener(handler(self,self.onTouch))
    nick:setString(GlobalUserItem.szNickName)
    local str = g_format:formatNumber(GlobalUserItem.lUserScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
    self.goldValue:setString(str)
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        --更新银行值
        local strBank = g_format:formatNumber(GlobalUserItem.lUserInsure,g_format.fType.abbreviation,g_format.currencyType.GOLD)
        ExtraValue:setString(strBank)
    else
        --更新TC值            
        local strTC = g_format:formatNumber(GlobalUserItem.lTCCoin,g_format.fType.abbreviation,g_format.currencyType.TC)
        ExtraValue:setString(strTC)
    end
end

--旋转转盘
function ShareTurnTableLayer:goTurnTable(index)
    local initRotate = (6 - index) * 60 + math.random(2,57)
    local needRotate = initRotate + math.ceil((self._nowRotation - initRotate) / 360) * 360 + 360 * 4
    
    self._nowRotation = needRotate
    local rotate = math.random(1,10)
    local time = self:clock()
    self:playSolveAnimation(4)
    if GlobalUserItem.bSoundAble then
		self._turnEffect = AudioEngine.playEffect("sound/turnSolve.mp3", false)
	end
    self.closeBtn:setTouchEnabled(false)
    self.closeBtn:setEnabled(false)
    TweenLite.to(self.turnTable,4,{ rotation = self._nowRotation,ease = Cubic.easeOut,
        onComplete = function() 
            if GlobalUserItem.bSoundAble then
                g_ExternalFun.stopEffect(self._turnEffect)
                self._turnEffect = nil
            end
            self:playGetGiaveAnimation(index)                    --播放获得奖励动画
        end
    })
end

function ShareTurnTableLayer:startAction()
    self.leftTopNode:setOpacity(0)
    self.leftTopNode:setPositionX(-500)
    self.rightTopNode:setOpacity(0)
    self.rightTopNode:setPositionX(display.width + 500)
    self.turnTableNode:setOpacity(0)
    self.turnTableNode:setPositionY(-238)
    self.rightNode:hide()
    self.rightNode:setPositionX(2420)
    self.leftTopNode:runAction(cc.Sequence:create(
        cc.Spawn:create(
        cc.EaseBackInOut:create(cc.MoveBy:create(0.3,cc.p(500,0)))
    )))
    self.rightNode:runAction(cc.Sequence:create(
        cc.Spawn:create(
        cc.EaseBackInOut:create(cc.MoveTo:create(0.3,cc.p(1314,1080))),
        cc.FadeIn:create(0.18)
    )))
    self.rightTopNode:runAction(cc.Sequence:create(
        cc.Spawn:create(
        cc.EaseBackInOut:create(cc.MoveBy:create(0.3,cc.p(-500,0))),
        cc.FadeIn:create(0.18)
    )))
    self.turnTableNode:runAction(cc.Sequence:create(
        cc.Spawn:create(
        cc.MoveTo:create(0.5,cc.p(0,-158)),
        cc.FadeIn:create(0.25)
    )))
end

function ShareTurnTableLayer:clock()
    if socket then
        return socket.gettime()
    end
    --可能返回负值
    return os.clock()
end

function ShareTurnTableLayer:createBgSpine()
    self._bgSpine = self:addSpine(self.spineBgNode,"beijing")
    self._bgSpine:setAnimation(0,"ruchang",false)
    self._bgSpine:registerSpineEventHandler( function( event )
        if event.animation == "ruchang" then
            self._bgSpine:setAnimation(0,"daiji",true)
        elseif event.animation == "daiji" then
           
        end
    end, sp.EventType.ANIMATION_COMPLETE)   
    self._bgSpine:setMix("ruchang","daiji",0.2)            --动画过渡
end

--播放旋转转圈动画
function ShareTurnTableLayer:playSolveAnimation(delayTime)
    if self._choujiangquanSpine then
        self._choujiangquanSpine:show()
    else
        self._choujiangquanSpine = self:addSpine(self.turnTableBody,"choujiangquan")
        self._choujiangquanSpine:setAnimation(0,"zhuanquan",true)
        self._choujiangquanSpine:setPosition(cc.p(self.turnTableBody:getContentSize().width/2,self.turnTableBody:getContentSize().height/2))
    end
    self._choujiangquanSpine:resume()
    local array = {
        cc.DelayTime:create(delayTime),
        cc.CallFunc:create(function() 
            self._choujiangquanSpine:hide() 
            self._choujiangquanSpine:pause()
        end)
    }
    self._choujiangquanSpine:runAction(cc.Sequence:create(array))
end

function ShareTurnTableLayer:playGetGiaveAnimation(index)
    local spineNode = self.turnTable:getChildByName("spineTurnNode"..index)
    spineNode:removeAllChildren()
    local nodeWorldPosition = spineNode:convertToWorldSpace(cc.p(0,50))
    local spineBoom = self._spineBoom
    if not spineBoom then
        spineBoom = self:addSpine(self._rootNode,"zhongjiangguang")
    end
    spineBoom:setPosition(nodeWorldPosition)
    local spine = self:addSpine(spineNode,"jinbi_zhizhen")
    spine:setPosition(cc.p(-4,-4))
    spine:setScale(0.9)
    spine:registerSpineEventHandler(function( event )
        if event.animation == "zhizhen" then
            self.closeBtn:setTouchEnabled(true)
            self.closeBtn:setEnabled(true)
            spine:hide()
            spineBoom:setAnimation(0,"zhongjiang",false)   
            g_ExternalFun.playEffect("sound/turnBoom.mp3", false)
            if index == 2 or index == 5 then                --金币
                self:flyJinBiToHead(nodeWorldPosition)                       --飞金币去头上
            elseif index == 1 or index == 3 then            --叶子 
                local finishPosition = self.spinBtn:convertToWorldSpace(cc.p(186,186))
                self:flyOthersToHead(nodeWorldPosition,self._llReward,finishPosition)
            else                                            --Money
                self:flyOthersToHead(nodeWorldPosition,3)
            end
        end
    end, sp.EventType.ANIMATION_COMPLETE)   
 
    spine:setAnimation(0,"zhizhen",false)           
    self._spineBoom = spineBoom
end

--飞金币去头顶
function ShareTurnTableLayer:flyJinBiToHead(nodeWorldPosition)
    local zorder = 10
    local sumTotal = 6
    local function createJinBi(index)
        local spine = nil
        if self._spineZhiZhen[index] then
            spine = self._spineZhiZhen[index]
        else
            spine = self:addSpine(self._rootNode,"jinbi_zhizhen")
            spine:setLocalZOrder(zorder)
            zorder = zorder - 1
            spine:registerSpineEventHandler( function( event )
                if event.animation == "guang" then
                    spine:hide()
                end
            end, sp.EventType.ANIMATION_COMPLETE)   
            self._spineZhiZhen[index] = spine
        end
        spine:show()
        spine:setAnimation(0,"jinbi",true)           
        spine:setScale(0.5)
        local iconWorldPosition = self.goldLabel:convertToWorldSpace(cc.p(27.5,28.5))
        local controlP1 = cc.p((nodeWorldPosition.x + iconWorldPosition.x  + math.random(1,200))*(math.random(1,2))/3,(nodeWorldPosition.y + iconWorldPosition.y  - math.random(1,200))*2/3)
        local controlP2 = controlP1
        local moveTo = cc.MoveTo:create(0.6,iconWorldPosition)
        local delayTime = (index == 1 or index == 3 or index == 5) and (5/40) or (8/40)
        local array = {
            cc.Spawn:create(
                cc.JumpBy:create(0.33,cc.p(math.random(0,200) -100,math.random(0,200) - 100),80,1),
                cc.ScaleTo:create(0.33,1)
            ),
            cc.DelayTime:create(delayTime),
            cc.Spawn:create(
                cc.EaseQuinticActionInOut:create(moveTo),
                cc.ScaleTo:create(0.6,0.6)
            ),
            cc.CallFunc:create(function() 
                if index == 1 or index == 3 or index == 5 then
                    spine:setAnimation(0,"guang",false) 
                    spine:setPosition(cc.p(iconWorldPosition.x + math.random(-25,25),iconWorldPosition.y + math.random(-25,25)))
                else
                    spine:hide()
                end
                self:shakeNode(self.goldLabel)
                if index == sumTotal then
                    if self._llReward then
                        self:updateMyScore(self._llReward)
                    end
                end
            end)
        }
        spine:setPosition(nodeWorldPosition)
        spine:runAction(cc.Sequence:create(array))
    end

    for k = 1,sumTotal do
        local array = {
            cc.DelayTime:create((k - 1) * (1/60)),
            cc.CallFunc:create(function() 
                createJinBi(k)
            end)
        }
        self:runAction(cc.Sequence:create(array))
    end
end

--飞Money去目的地
function ShareTurnTableLayer:flyOthersToHead(nodeWorldPosition,sumTotal,finishPosition)
    if sumTotal > 6 then
        sumTotal = 6
    end
    local function createYeZi(index)
        local spine = nil
        if self._spineZhiZhen[index] then
            spine = self._spineZhiZhen[index]
        else
            spine = self:addSpine(self._rootNode,"jinbi_zhizhen")
            spine:registerSpineEventHandler( function( event )
                if event.animation == "guang" then
                    spine:hide()
                end
            end, sp.EventType.ANIMATION_COMPLETE)   
            self._spineZhiZhen[index] = spine
        end
        spine:hide()       
        --finishPosition有值就是叶子
        local iconWorldPosition = finishPosition or self.nowScoreText:convertToWorldSpace(cc.p(27.5,28.5))
        local moneyIcon = display.newSprite(finishPosition and "#client/res/ShareTurnTable/lucklefe.png" or "#client/res/ShareTurnTable/money.png")
        self._rootNode:addChild(moneyIcon,1)
        local controlP1 = cc.p((nodeWorldPosition.x + iconWorldPosition.x)*2/3,(nodeWorldPosition.y + iconWorldPosition.y + math.random(1,200))*2/3)
        local controlP2 = controlP1
        local moveTo = cc.BezierTo:create(0.6,{controlP1,controlP2,iconWorldPosition})
        moneyIcon:setScale(0.5)
        local array = {
            cc.Spawn:create(
                cc.JumpBy:create(0.6,cc.p(math.random(0,80) - 40,math.random(0,40)),80,2),
                cc.ScaleTo:create(0.6,1.0)
            ),
            cc.DelayTime:create(0.4),
            cc.Spawn:create(
                cc.EaseQuinticActionIn:create(finishPosition and cc.MoveTo:create(0.6,iconWorldPosition) or moveTo),
                cc.ScaleTo:create(0.6,finishPosition and 0.9 or 0.6)
            ),
            cc.CallFunc:create(function() 
                moneyIcon:removeFromParent()
                self:shakeNode(finishPosition and self.spinBtn or self.nowScoreText)
                if index == 1 or index == 3 or index == 5 then
                    spine:setScale(1)
                    spine:show()
                    spine:setAnimation(0,"guang",false) 
                    spine:setPosition(cc.p(iconWorldPosition.x + math.random(-25,25),iconWorldPosition.y + math.random(-25,25)))
                else
                    spine:hide()
                end
                if index == sumTotal then
                    self:updateMyTimes(finishPosition)
                end
            end)
        }
        spine:setPosition(iconWorldPosition)
        spine:setLocalZOrder(2)
        moneyIcon:setPosition(nodeWorldPosition)
        moneyIcon:runAction(cc.Sequence:create(array))
    end

    for k = 1,sumTotal do
        local array = {
            cc.DelayTime:create((k - 1) * 0.1),
            cc.CallFunc:create(function() 
                createYeZi(k)
            end)
        }
        self:runAction(cc.Sequence:create(array))
    end
end

function ShareTurnTableLayer:shakeNode(node)
    Earthquake:create(node, 5, 0.2,Earthquake.DIRECT.LEFT_RIGHT_UP_DOWN)
end

function ShareTurnTableLayer:addSpine(parentNode,fileName)
    local spine = sp.SkeletonAnimation:createWithJsonFile("client/res/spine/enjoyTurnTable/"..fileName..".json","client/res/spine/enjoyTurnTable/"..fileName..".atlas", 1)        
    spine:addTo(parentNode)
    return spine
end

--通过图片数字创建文本
--spriteFrameName图片纹理名
function ShareTurnTableLayer:getCountTextByNode(spriteFrameName)
    local node = cc.Node:create()
    local curLong = 2           --字体之间的间距
    local width = 0             --字体的宽度
    local strTab = {}
    node.setString = function(sender,str) 
        str = str or ""
        str = tostring(str)
        width = 0
        for k = 1,#strTab do
            strTab[k]:hide()
        end
        for k = 1,#str do
            local st = string.sub(str,k,k)
            if tonumber(st) ~= nil then
                local sprite = strTab[k]
                if not sprite then
                    sprite = display.newSprite()
                    node:addChild(sprite)
                    strTab[#strTab + 1] = sprite
                    sprite:setAnchorPoint(cc.p(0,0.5))
                end
                sprite:show()
                local imagePath = string.format(spriteFrameName,st)
                sprite:setSpriteFrame(imagePath)
                sprite:setPosition(cc.p(width,0))
                width = width + sprite:getContentSize().width + curLong
            end
        end
        if width ~= 0 then width = width - curLong end
    end
    node.getContentSize = function(sender) 
        return cc.size(width,18)
    end

    node.setBright = function(sender,bool) 
        for k = 1,#strTab do
            strTab[k]:setBright(bool)
        end
    end

    node.setColor = function(sender,color)
        for k = 1,#strTab do
            strTab[k]:setColor(color)
        end
    end
    return node
end

--更新我的头像金币
function ShareTurnTableLayer:updateMyScore(llReward)
    GlobalUserItem.lUserScore = GlobalUserItem.lUserScore + llReward
    local str = g_format:formatNumber(GlobalUserItem.lUserScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
    self.goldValue:setString(str)
    G_event:NotifyEventTwo(G_eventDef.NET_USER_SCORE_REFRESH)   --全局货币更新
    self:updateSpinBtnStatus()
    local array = {
        cc.Spawn:create(
            cc.FadeIn:create(0.2),
            cc.MoveBy:create(0.8,cc.p(0,20))
        ),
        cc.Spawn:create(
            cc.FadeOut:create(0.2),
            cc.MoveBy:create(0.2,cc.p(0,10))
        ),
        cc.CallFunc:create(function() 
            self.myScoreAdd:hide()
        end)
    }
    self.myScoreAdd:setString("+"..g_format:formatNumber(llReward,g_format.fType.standard))
    self.myScoreAdd:show()
    self.myScoreAdd:setOpacity(0)
    self.myScoreAdd:setPosition(cc.p(440,-86))
    self.myScoreAdd:runAction(cc.Sequence:create(array))
end

--更新我的次数
function ShareTurnTableLayer:updateMyTimes(isYezi)
    if isYezi then
        self._args.dwRestCount = self._args.dwRestCount + self._llReward
    else
        --钱
        self.llCurrentScore = self.llCurrentScore + self._llReward
        local array = {
            cc.Spawn:create(
                cc.FadeIn:create(0.3),
                cc.MoveBy:create(0.8,cc.p(0,20))
            ),
            cc.Spawn:create(
                cc.FadeOut:create(0.3),
                cc.MoveBy:create(0.3,cc.p(0,10))
            ),
            cc.CallFunc:create(function() 
                self.nowScoreAdd:hide()
            end)
        }
        self.nowScoreAdd:setString("+"..g_format:formatNumber(self._llReward,g_format.fType.standard))
        self.nowScoreAdd:show()
        self.nowScoreAdd:setOpacity(0)
        self.nowScoreAdd:setPosition(cc.p(484.4,285.87))
        self.nowScoreAdd:runAction(cc.Sequence:create(array))
        self:updateLeftGift()
    end
    self:updateSpinBtnStatus()
end

--幸运玩家列表
function  ShareTurnTableLayer:luckList(pData)
    local lsItems = pData.lsItems
    if not lsItems or #lsItems <=0 then
        self:startScroll()
        return
    end
    self._luckIndex = self._luckIndex + 1
    for k = 1,#lsItems do
        local data = lsItems[k]
        self:addMyDataToScroll(data)
    end
    G_ServerMgr:requestTurnLuckHistory(self._luckIndex)
end

function ShareTurnTableLayer:addMyDataToScroll(data)
    local item = self.clonePanel:clone()
    self.historyPanel:addChild(item)
    local headNodeCell = item:getChildByName("headNodeCell")
    local userName = item:getChildByName("userName")
    local CellItemText = item:getChildByName("CellItemText")
    local dateText = item:getChildByName("dateText")
    headNodeCell:removeAllChildren()
    local node = HeadNode:create(data.wFaceID)
    headNodeCell:addChild(node)
    headNodeCell:setScale(0.4)
    node:setVipVisible(false)
    userName:setString(data.szNickName)
    CellItemText:setString(string.format("R$:%s",g_format:formatNumber(data.llScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)))
    dateText:setString(os.date("%d.%m.%Y %H:%M:%S",data.tmRewardDate))
    item:setAnchorPoint(0.5,1)
    table.insert(self._scrollTabItems,1,item)
    item:hide()
    item._headNode = node
    node:setCascadeOpacityEnabled(true)
end

--开始滑动
function ShareTurnTableLayer:startScroll()
    local speed = 30
    local sumCount = #self._scrollTabItems
    for k = 1,sumCount do
        local item = self._scrollTabItems[k]
        local initPosition = cc.p(325,-(k - 1) * 74)
        item:setPosition(initPosition)
        local time = (0 - item:getPositionY()) / speed
        local time1 = (74) / speed
        local time2 = (311 - 148) / speed
        local time3 = 74 / speed
        local array = {
            cc.MoveTo:create(time,cc.p(325,0)),
            cc.CallFunc:create(function() 
                item:show()
            end),  
            cc.Spawn:create(
                cc.MoveTo:create(time1,cc.p(325,74)),
                cc.FadeIn:create(time1)
            ),
            cc.MoveTo:create(time2,cc.p(325,234)),
            cc.Spawn:create(
                cc.MoveTo:create(time3,cc.p(325,308)),
                cc.FadeOut:create(time3)
            ),
            cc.CallFunc:create(function() 
                item:setPosition(cc.p(325,-(k - 1) * 74))
                item:hide()
                if k == sumCount then
                    self:startScroll()
                end
            end)
        }
        item:setOpacity(0)
        item:hide()
        item:runAction(cc.Sequence:create(array))
    end
end

function ShareTurnTableLayer:showAnimation()
    if self._spineRunAction then
        self._spineRunAction:show()
        self._rootNode:runAction(self._spineRunAction)  
        return
    end
    local pAction = g_ExternalFun.loadTimeLine("ShareTurnTable/ShareTurnTableLayer.csb")
    pAction:gotoFrameAndPlay(0,true)
    self._rootNode:runAction(pAction)  
    pAction:setTag(0x0010)
    self._spineRunAction = pAction
end

function ShareTurnTableLayer:hideSpineAnimation()
    if self._spineRunAction then
        self._spineRunAction:stop()
    end
end

--奖励消息
function ShareTurnTableLayer:receiveInfo(pdata)
   -- self.nowScoreText2:setString(string.format("R$:%s",g_format:formatNumber(pdata.llCurrentSpreadScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)))
    self.rightTips1:setString(string.format("%s",pdata.dwPayUserCount))
    self.rightTips2:setString(string.format("R$:%s!",g_format:formatNumber(pdata.llMaxSpreadScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)))  
    if pdata.llCurrentSpreadScore > 0 then
        self.RecibirBtn2:setBright(true)
        self.RecibirBtn2:setTouchEnabled(true)
    else
        self.RecibirBtn2:setBright(false)
        self.RecibirBtn2:setTouchEnabled(false)
    end
end

--点击领取奖励返回
function ShareTurnTableLayer:goToreceiveInfo(pdata)
    local llScore = pdata.llScore
    self:showRewardLayer(llScore)
   -- self.RecibirBtn2:setBright(false)
    --self.RecibirBtn2:setTouchEnabled(false)
    --self.nowScoreText2:setString("R$:0")
end

--获取提现挡位数据
function ShareTurnTableLayer:receiveTiXianData(pData)
    dismissNetLoading()
    local int64 = Integer64:new()
    local wCount = pData:readword()
    local result = {}
    for i=1,wCount do
        table.insert(result, {
            -- 档位ID
            dwStageID = pData:readdword(), 
            -- 档位积分
            dwStageScore = pData:readscore(int64):getvalue(),
            -- 新用户可否使用
            cbNewUserEnable = pData:readbyte()
        })
    end
    dump(result)
    self._selectLevelData = result
    local count = 0
    local lastStageID = nil
    local dwStageScore = nil

    for k = 1,#result do
        local data = result[k]
        local cbNewUserEnable = data.cbNewUserEnable
        local isNewPlayer = (self.dwWithdrawCount == 0 and 1 or 0)         --是否是新用户
        if cbNewUserEnable == isNewPlayer then                         
            count = count + 1
            lastStageID = data.dwStageID
            dwStageScore = data.dwStageScore
        end
    end  
    if count > 1 then               --如果有多个选项
        G_event:NotifyEvent(G_eventDef.UI_SHOW_SELECTLAYER,{result = result,dwWithdrawCount = self.dwWithdrawCount
            })
    else                            --如果只有一个选项
        showNetLoading()
        G_ServerMgr:setTiXianLevel(lastStageID,dwStageScore)
    end
end

function ShareTurnTableLayer:showRewardLayer(score)
    local name = "mrrw_jb_1"
    local imagePath = string.format("client/res/public/%s.png",name)
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
    local data = {}
    data.goldImg = imagePath
    data.goldTxt = g_format:formatNumber(score,g_format.fType.standard)
    data.type = 1
    local layer = appdf.req(path).new(data)
end

function ShareTurnTableLayer:showRewardLayer2(result)
    local llTotalCash = result.llTotalCash or 0         --抽到的现金总和
    local llTotalScore = result.llTotalScore or 0       --抽到的金币总和
    local wTotalFreeCount = result.wTotalFreeCount      --抽到的免费次数总和
    local datas = {}
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
 
    if llTotalCash > 0 then             --现金
        local name = "money"
        local imagePath = string.format("client/res/ShareTurnTable/%s.png",name)
        local data = {}
        data.goldImg = imagePath
        data.goldTxt = g_format:formatNumber(llTotalCash,g_format.fType.standard)
        data.type = 1
        datas[#datas + 1] = data
    end

    if llTotalScore > 0 then                --金币
        local name = "mrrw_jb_1"
        local imagePath = string.format("client/res/public/%s.png",name)
        local data = {}
        data.goldImg = imagePath
        data.goldTxt = g_format:formatNumber(llTotalScore,g_format.fType.standard)
        data.type = 1
        datas[#datas + 1] = data
    end
    
    if wTotalFreeCount > 0 then             --免费次数
        local name = "lucklefe"
        local imagePath = string.format("client/res/ShareTurnTable/%s.png",name)
        local data = {}
        data.goldImg = imagePath
        data.goldTxt = wTotalFreeCount
        data.type = 1
        datas[#datas + 1] = data
    end

    if #datas > 0 then
        local callback = function() 
            if llTotalCash > 0 then
                self._llReward = llTotalCash
                self:updateMyTimes()
            end
            if llTotalScore > 0 then
                self:updateMyScore(llTotalScore)
            end
        end
        datas.callback =  callback
        local layer = appdf.req(path).new(datas)
    end
end


function ShareTurnTableLayer:setReceive(pData)
    dismissNetLoading()
    local int64 = Integer64:new()
    local result = {
        errorCode  = pData:readdword(),
        stageID    = pData:readdword(),
        stageScore = pData:readscore(int64):getvalue()
    }
    dump(result)
    if result.errorCode ~= 0 then
        if result.errorCode == 1505 then
            -- 引发原因：
            -- 后台【在线】修改了档位积分配置(极小概率)，而前端没有重新拉取配置(即停留在此页面，或者做了缓存)
            printInfo("档位ID与分值不匹配")
        elseif result.errorCode == 1506 then
            -- 引发原因：
            -- 上行了错误的 stageID
            printInfo("档位不存在")
        elseif result.errorCode == 1507 then
            -- 引发原因：
            -- 即用户当前已经选定了档位，所以不能再度选择档位
            -- 即用户状态当前的 stageID ~= 0 ，而客户端强制调用此协议
            printInfo("无法设置提现档位")
        elseif result.errorCode == 1508 then
            -- 引发原因：
            -- 后台【在线】修改了配置(极小概率)，而前端没有重新拉取配置(即停留在此页面，或者做了缓存)
            -- 1718协议返回的字段中有一个cbNewUserEnable字段，标识【新用户】是否能够使用此档位
            -- 名词解释：
            --      新用户：指提现次数为0的用户 1703协议返回的字段有一个dwWithdrawCount字段,标识当前提现次数
            printInfo("新用户不允许使用此档位")
        else
            printInfo("未知错误")
        end

    else
        self.dwStageID = 1                      --设置了挡位
        showToast("Configuração concluída com sucesso.")            --设置成功
        self:setDwData(result.stageScore)                   --设置挡位数据  
        local scene = cc.Director:getInstance():getRunningScene()
        local layer = scene:getChildByName("ShareSelectLayer")
        if layer then layer:close() end
    end 
end


--拉新配置返回
function ShareTurnTableLayer:shareGift_config(pData)
    local packLen = pData:getlen()
    if packLen ~= (4+8)*8 then
        printf("协议变更")
        return
    end
    local int64 = Integer64:new()
    local result2 = {}

    for i=1, 8 do
        local config = {
            dwFriendsRequire = pData:readdword(),                   -- 需要的好友人数
            llScore          = pData:readscore(int64):getvalue()    -- 奖励的分数
        }
        table.insert(result2,config)
    end
    dump(result2, '分享宝箱-配置结果:' .. pData:getlen() .. 'bytes')

    self._giftBoxConfig = result2
    self:selectLeftIndex(1)
end

--宝箱信息返回，返回后再初始化
function ShareTurnTableLayer:GiftBoxInfo(pData)
    self._middle1 = true
    dismissNetLoading()
    self:showMiddleNode(1)
    function parseChestStatus(llStatus)
        -- 说明：20230717
        -- 每个箱子的状态为4个bit(半个字节)，第1位标识是否可领取，第2位标识是否已领取,第3、4位保留
        -- 后端为一个int64长整型(最大支持16个箱子)；lua端只支持53位（最大只支持13个箱子）；如后续功能需要扩展箱子个数，lua需要用2个整型存储
        -- 此例用于将状态值分解为一个数字数组
        local lsStatus = {}
        for i=1, 8 do
            table.insert(lsStatus, llStatus % 0x10)
            llStatus = math.floor(llStatus / 0x10)
        end
        return lsStatus
    end  
    local boxConfig = self._giftBoxConfig
    local int64 = Integer64:new()
    local result = {                
        lsStatus = parseChestStatus(pData:readscore(int64):getvalue()),    -- 宝箱状态值
        llScore  = pData:readscore(int64):getvalue(),                      -- 当前轮可领取的积分
        llTotalScore = pData:readscore(int64):getvalue(),                  -- 历史总积分(可领取+未领取)
        dwCurrentFriendCount = pData:readdword(),                          -- 当前轮有效用户数量
        dwTotalFriendCount = pData:readdword(),                            -- 总拉新人数(含无效用户数量)
    }
    self._leftItemInfoData2 = result
    self.peoPleNum1:setString(tostring(result.dwTotalFriendCount))
    local dwCurrentFriendCount = result.dwCurrentFriendCount
    self.youXiaoNum1:setString(tostring(dwCurrentFriendCount))
    self.priceText1:setString(string.format("R$:%s",g_format:formatNumber(result.llTotalScore,g_format.fType.standard)))
    local nowSum = 0
    for k = 1,8 do
        local config = boxConfig[k]
        if (dwCurrentFriendCount - nowSum) >= config.dwFriendsRequire then      --如果大于需求的人数，就是够了
            config.nowFriendCount = config.dwFriendsRequire
            nowSum = nowSum + config.dwFriendsRequire
        else
            local nowFriendCount = dwCurrentFriendCount - nowSum
            config.nowFriendCount = nowFriendCount > 0 and nowFriendCount or 0
            nowSum = nowSum + config.nowFriendCount
        end
    end
    
    dump(result, '分享充值返利-用户状态结果:' .. pData:getlen() .. 'bytes')
    self:initNode1ListView(result)
end

function ShareTurnTableLayer:initNode1ListView(result)
    self.node1ListView:removeAllChildren()
    local boxConfig = self._giftBoxConfig
    local clonePanel = self.clonePanel1:clone()
    local width = self.node1ListView:getContentSize().width / 4 + 4
    local sumWidth = 1
    self.node1ListView:pushBackCustomItem(clonePanel)

    local index = 1
    for k, val in ipairs(result.lsStatus) do
        local giftNode = self.cloneGiftNode1:clone()
        clonePanel:addChild(giftNode)
        giftNode:setPosition(cc.p(sumWidth,13.4))
        sumWidth = index * width
        index = index + 1
        if k == 4 then
            clonePanel = self.clonePanel1:clone()
            sumWidth = 1
            index = 1
            self.node1ListView:pushBackCustomItem(clonePanel)
        end
        self:setGiftBoxItemInfo(giftNode,val,k,boxConfig[k])
    end
end

function ShareTurnTableLayer:setGiftBoxItemInfo(item,value,index,scoreConfig)
    local cloneIcon = item:getChildByName("cloneIcon")
    local cloneReceBtn = item:getChildByName("cloneReceBtn")
    local peopleText = item:getChildByName("peopleText")
    local cloneGiftPriceText = item:getChildByName("cloneGiftPriceText")
    local peopleIcon = item:getChildByName("peopleIcon")
    local cloneLoadBar = item:getChildByName("cloneLoadBar")
    local textBody = item:getChildByName("textBody")
    cloneGiftPriceText:setString("R$:"..g_format:formatNumber(scoreConfig.llScore,g_format.fType.standard))
    local dwFriendsRequire = scoreConfig.dwFriendsRequire               --需求的总人数
    local nowFriendCount = scoreConfig.nowFriendCount
    peopleText:setString(string.format("%s/%s",nowFriendCount,dwFriendsRequire))
    cloneLoadBar:setPercent(nowFriendCount / dwFriendsRequire * 100)
    -- 出现状态为2为异常
    cloneReceBtn:show()
    cloneIcon:setEnabled(true)
    cloneIcon:ignoreContentAdaptWithSize(true)
    cloneIcon:loadTextureNormal(string.format("client/res/ShareTurnTable/box0%s.png",index),1)
    cloneIcon:loadTexturePressed(string.format("client/res/ShareTurnTable/box0%s.png",index),1)
    peopleIcon:show()
    cloneLoadBar:show()
    peopleText:show()
    textBody:loadTexture("client/res/ShareTurnTable/lin001.png",1)
    textBody:ignoreContentAdaptWithSize(true) 
    textBody:setPositionY(98)
    cloneGiftPriceText:setTextColor(cc.c3b(192,35,624))
    peopleIcon:loadTexture("client/res/ShareTurnTable/peopel3.png",1)
    cloneLoadBar:loadTexture("client/res/ShareTurnTable/line002.png",1)
    if value == 0 then
        printf("不可领取")
        if cloneIcon._spine then
            cloneIcon._spine:hide()
        end
        cloneReceBtn:onClicked(function() 
            local pData = {
                dialogType = DialogType.ShareNewPlayer,
                msg = g_language:getString("shareLaxin_tips"),
                callback = function(click)
                    if click == "ok" then     
                        G_event:NotifyEvent(G_eventDef.UI_SHOW_SHARE,GlobalUserItem.MAIN_SCENE)
                    elseif click == "cancel" then
                        G_event:NotifyEvent(G_eventDef.showSHAREPHONEDATA)
                    end
                end
            }
            G_event:NotifyEvent(G_eventDef.UI_OPEN_COMMON_DIALOG,pData)
        end)  
    elseif value == 1 then
        printf("可领取") -- 1
        if not cloneIcon._spine then
            local spine = self:addSpine(cloneIcon,"lihe")
            spine:setAnimation(0,"daiji"..index,true)
            cloneIcon._spine = spine
            spine:setPosition(cc.p(cloneIcon:getContentSize().width/2,cloneIcon:getContentSize().height/2))
        else
            cloneIcon._spine:show()  
        end
        cloneLoadBar:loadTexture("client/res/ShareTurnTable/line01.png",1)
        peopleIcon:loadTexture("client/res/ShareTurnTable/icon_pep01.png",1)
        local llScore = self._giftBoxConfig[index].llScore
        cloneReceBtn:onClicked(function() 
            self._onClickBoxIndex = index
            showNetLoading()
            G_ServerMgr:ShareTreasureChestTakeReward(index,llScore)
        end)
    else
        if cloneIcon._spine then
            cloneIcon._spine:hide()
        end
        cloneReceBtn:hide()
        textBody:loadTexture("client/res/ShareTurnTable/lybel.png",1)
        cloneLoadBar:hide()
        peopleIcon:hide()
        peopleText:hide()
        textBody:setPositionY(68)
        printf("已领取") -- 3
    end
end

--接受礼物宝箱奖励
function ShareTurnTableLayer:receiveBoxGift(pData)
    dismissNetLoading()
    local int64 = Integer64:new()
    local result = {
        dwErrorCode = pData:readdword(),                            -- 错误码 1510 分享宝箱状态不正确(理论上得不到此错误)
        llTakeScore = pData:readscore(int64):getvalue(),            -- 这一次操作领取到的奖励(炸化专用)
        llStatus = pData:readscore(int64):getvalue(),               -- 宝箱状态(更新界面数据)
        llScore = pData:readscore(int64):getvalue(),                -- 当前轮可领取的积分(更新界面数据)
        llTotalScore = pData:readscore(int64):getvalue()            -- 历史总积分(可领取+未领取)(更新界面数据)
    }
    if result.dwErrorCode == 0 then
        self.priceText1:setString(string.format("R$:%s",g_format:formatNumber(result.llScore,g_format.fType.standard)))
        local lsStatus = self._leftItemInfoData2.lsStatus
        lsStatus[self._onClickBoxIndex] = result.llStatus
        self:initNode1ListView(self._leftItemInfoData2)
        self._onClickBoxIndex = nil
        self:showRewardLayer(result.llTakeScore)
    end
    dump(result, '分享充值返利-领取箱子结果:' .. pData:getlen() .. 'bytes')
end

--拉新奖励配置返回
function ShareTurnTableLayer:shareGetNewBenefitConfg(pData)
    local result = {
        dwPercent1 = pData:readdword(),   -- 1
        dwPercent2 = pData:readdword()    -- 2
    }
    dump(result, '分享充值返利-配置:' .. pData:getlen() .. 'bytes')
    self._laXinGiftConfig = result 
end

--拉新奖励用户状态
function ShareTurnTableLayer:CMD_MB_SharePayRebateGetStatus(pData)
    local int64 = Integer64:new()
    local result = {
        llScore = pData:readscore(int64):getvalue(),         -- 可领取的收益
        llTotalScore = pData:readscore(int64):getvalue(),    -- 总收益
        dwTotalFriendsCount =  pData:readdword()             -- 总注册的下家人数
    }
    self:showMiddleNode(3)
    if tonumber(result.llScore) > 0 then           --可领取的奖励为0
        self.ReceBerMiddle3Btn:setTouchEnabled(true)
        self.ReceBerMiddle3Btn:setEnabled(true)
    else
        self.ReceBerMiddle3Btn:setTouchEnabled(false)
        self.ReceBerMiddle3Btn:setEnabled(false)
    end
    self._laXinScore = result.llScore
    self.priceMiddle3Text:setString(string.format("R$:%s",g_format:formatNumber(result.llScore,g_format.fType.standard)))
    self.priceText3:setString(string.format("R$:%s",g_format:formatNumber(result.llTotalScore,g_format.fType.standard)))
    self.peoPleNum3:setString(result.dwTotalFriendsCount)
    G_ServerMgr:CMD_MB_SharePayRebateGetRecord(1)
    self.node3ListView:removeAllChildren()
end

--拉新奖励记录
function ShareTurnTableLayer:CMD_MB_SharePayRebateGetRecord(pData)
    dismissNetLoading()
    self._middle3 = true
    local int64 = Integer64:new()
    local result = {
        dwPageIndex = pData:readdword(),                     -- 页号:从1开始
        dwPageSize = pData:readdword(),                      -- 每页数量(最大不能超过50)
        dwTotalRecordCount =  pData:readdword(),             -- 总记录数量
        wCount = pData:readword(),                           -- 当前页记录数量
        lsItem = {}                                          -- 记录列表
    }  
    self._nowPageIndex = result.dwPageIndex
    self._nowdwPageSize = result.dwPageSize
    self._nowwCount = result.wCount
    self._dwTotalRecordCount = result.dwTotalRecordCount
    if  tonumber(result.dwTotalRecordCount) <= 0 then
        self.noDataText:show()
    else
        self.noDataText:hide()  
    end

    if ((result.dwPageIndex - 1) * self._nowdwPageSize + result.wCount) < tonumber(result.dwTotalRecordCount) then
        self.priceText_0:show()
    else
        self.priceText_0:hide()
    end
    -- 解析记录列表
    for i=1, result.wCount do
        local dwGameID = pData:readdword()
        local llPayCash = pData:readscore(int64):getvalue()
        local llRebateScore = pData:readscore(int64):getvalue()
        local cbSpan  = pData:readbyte()
        local szNickName = pData:readstring(32)

        local clonePanel = self.clonePanel3:clone()
        clonePanel:show()
        self.node3ListView:pushBackCustomItem(clonePanel)
        local cloneGiftNode3 = clonePanel:getChildByName("cloneGiftNode3")
        local playerName = cloneGiftNode3:getChildByName("playerName")
        local priceText = cloneGiftNode3:getChildByName("priceText")
        local priceText2 = cloneGiftNode3:getChildByName("priceText2")
        priceText:setString(string.format("R$:%s",g_format:formatNumber(llPayCash,g_format.fType.standard)))
        priceText2:setString(string.format("%sR$",g_format:formatNumber(llRebateScore,g_format.fType.standard)))
        playerName:setString(szNickName)
    end  
    dump(result, '分享充值返利-返利记录:' .. pData:getlen() .. 'bytes')    
end


function ShareTurnTableLayer:scrollViewEvent(sender,evenType)
    if evenType == 1 then                                        --滚动到底部
        if (os.time() - self._requestTime) > 1.5 and ((self._nowPageIndex - 1) * self._nowdwPageSize + self._nowwCount) < self._dwTotalRecordCount then
            self._requestTime = os.time()
            showNetLoading()
            G_ServerMgr:CMD_MB_SharePayRebateGetRecord(self._nowPageIndex + 1)
        end
    else                                                         --滚动到顶部
        
    end
end

--领取拉新奖励返回
function ShareTurnTableLayer:CMD_MB_SharePayRebateTakeReward(pData)
    dismissNetLoading()
    local int64 = Integer64:new()
    local result = {
        dwErrorCode = pData:readdword(),                     -- 错误码
        llScore = pData:readscore(int64):getvalue(),         -- 炸花的分
    }
    -- 不一定 result.llScore  == llScore
    if result.dwErrorCode == 0 and result.llScore ~= 0 then
        self:showRewardLayer(result.llScore)
        self.priceMiddle3Text:setString("R$:0")
        self._laXinScore = 0
        self.ReceBerMiddle3Btn:setTouchEnabled(false)
        self.ReceBerMiddle3Btn:setEnabled(false)
    else
        -- 错误日志 --
    end
    dump(result, '分享充值返利-领取返利:' .. pData:getlen() .. 'bytes')
end

function ShareTurnTableLayer:setRichText()
    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(true)
    richText:setAnchorPoint(cc.p(0,0.5))
    local re1 = ccui.RichElementText:create(1,cc.c3b(255,255,255),255,"Quando você convida amigos, se eles alcançarem o","Helvetica",30) 
    local re2 = ccui.RichElementText:create(1,cc.c3b(246,19,249),255," VIP1 ","Helvetica",30) 
    local re3 = ccui.RichElementText:create(1,cc.c3b(255,255,255),255,"ao recarregar,o número de pessoas ativas aumentará em","Helvetica",30) 
    local re4 = ccui.RichElementText:create(1,cc.c3b(246,183,17),255," +1","Helvetica",30) 
    local re5 = ccui.RichElementText:create(1,cc.c3b(255,255,255),255,".","Helvetica",30) 
    richText:pushBackElement(re1)
    richText:pushBackElement(re2)
    richText:pushBackElement(re3)
    richText:pushBackElement(re4)
    richText:pushBackElement(re5)
    self.nodeText1:addChild(richText)
    richText:setPosition(cc.p(0,0))
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(cc.size(868,400))
    richText:setVerticalSpace(4)
end

function ShareTurnTableLayer:setRichText2()
    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(true)
    richText:setAnchorPoint(cc.p(0,0.5))
    local re1 = ccui.RichElementText:create(1,cc.c3b(255,255,255),255,"1. Seu amigo recarregar, você receberá um","Helvetica",30) 
    local re2 = ccui.RichElementText:create(1,cc.c3b(248,195,13),255," reembolso de 2% do valor recarregado.","Helvetica",30) 
    richText:pushBackElement(re1)
    richText:pushBackElement(re2)
    self.nodeText3:addChild(richText)
    richText:setPosition(cc.p(0,0))
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(cc.size(868,400))
    richText:setVerticalSpace(4)

    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(true)
    richText:setAnchorPoint(cc.p(0,0.5))
    local re1 = ccui.RichElementText:create(1,cc.c3b(255,255,255),255,"2.  Os iogadores C e D convidados pelos seus amigos.  se eles fizerem uma recarga,","Helvetica",30) 
    local re2 = ccui.RichElementText:create(1,cc.c3b(3,247,187),255,"você receberá um lucro de 1%.","Helvetica",30) 
    richText:pushBackElement(re1)
    richText:pushBackElement(re2)
    self.nodeText3:addChild(richText)
    richText:setPosition(cc.p(0,0))
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(cc.size(868,400))
    richText:setVerticalSpace(4)
    richText:setPositionY(-80)
end
return ShareTurnTableLayer