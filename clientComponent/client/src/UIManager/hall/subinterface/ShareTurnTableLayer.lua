local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local ShareTurnTableLayer = class("ShareTurnTableLayer",BaseLayer)
local HeadNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HeadNode")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
local Earthquake = appdf.req(appdf.CLIENT_SRC.."Tools.Earthquake")

function ShareTurnTableLayer:ctor(args)
    ShareTurnTableLayer.super.ctor(self)
    display.loadSpriteFrames("client/res/ShareTurnTable/ShareTurnTableGUI.plist","client/res/ShareTurnTable/ShareTurnTableGUI.png")
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    self._args = args
    self:loadLayer("ShareTurnTable/ShareTurnTableLayer.csb")
    self:init()
end

function ShareTurnTableLayer:initData()
    self._spineRunAction = nil
    self._nowRotation = 0
    self._spineZhiZhen = {}
    self._luckIndex = 1
    self._autoScrollSpeed = 40          --每秒40个像素滑动
    self._scrollTabItems = {}
end

function ShareTurnTableLayer:initView()
    self.bg = self:getChildByName("bg")
    g_ExternalFun.adapterScreen(self.bg)
    self.nowScoreAdd = self:getChildByName("nowScoreAdd")
    self.nowScoreAdd:hide()
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
    self.middleNode = self:getChildByName("middleNode")
    self.turnTableNode = self.middleNode:getChildByName("turnTableNode")
    self.turnTableBody = self.turnTableNode:getChildByName("turnTableBody")
    self.nowScoreText = self:getChildByName("nowScoreText")
    self.scoreText1 = self:getChildByName("scoreText1")
    self.scoreText2 = self:getChildByName("scoreText2")
    self.RecibirBtn = self:getChildByName("RecibirBtn")
    self.RecibirBtn:setBright(false)
    self.jianTou = self:getChildByName("jianTou")
end

function ShareTurnTableLayer:init()
    self:initData()
    self:initView()
    self:initListener()
 --   self:startAction()
    self:initMyHead()
  --  self:showAnimation()
    self:performWithDelay(handler(self,self.createBgSpine),1/50)
    self.llRequireScore = self._args.llRequireScore
    self.llCurrentScore = self._args.llCurrentScore 
    self:updateLeftGift()
    self:updateSpinBtnStatus()
    G_ServerMgr:requestTurnLuckHistory(self._luckIndex)
end

function ShareTurnTableLayer:onExit()
    ShareTurnTableLayer.super.onExit(self)
    self.clonePanel:release()
    G_event:RemoveNotifyEvent(G_eventDef.SHARE_TURN_RECEIVEGIFT)
    G_event:RemoveNotifyEvent(G_eventDef.SHARE_TURN_RESLOVE)
    G_event:RemoveNotifyEvent(G_eventDef.SHARE_TURN_LUCKHISTORY)
    display.removeSpriteFrames("client/res/ShareTurnTable/ShareTurnTableGUI.plist","client/res/ShareTurnTable/ShareTurnTableGUI.png")
end

function ShareTurnTableLayer:initListener()
    self.closeBtn:addTouchEventListener(handler(self,self.onTouch))
    self.howBtn:addTouchEventListener(handler(self,self.onTouch))
    self.historyBtn:addTouchEventListener(handler(self,self.onTouch))
    self.spinBtn:addTouchEventListener(handler(self,self.onTouch))
    self.RecibirBtn:addTouchEventListener(handler(self,self.onTouch))
    G_event:AddNotifyEvent(G_eventDef.SHARE_TURN_RECEIVEGIFT,handler(self,self.getGift))
    G_event:AddNotifyEvent(G_eventDef.SHARE_TURN_RESLOVE,handler(self,self.resolved))
    G_event:AddNotifyEvent(G_eventDef.SHARE_TURN_LUCKHISTORY,handler(self,self.luckList))
end


function ShareTurnTableLayer:onTouch(sender,eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.ended then
        if name == "closeBtn" then
            self:close()
        elseif name == "howBtn" then
            G_event:NotifyEvent(G_eventDef.UI_SHARESTEP)
        elseif name == "historyBtn" then
            G_ServerMgr:requestTurnTableUserInvited(1)               --获取邀请记录
            G_event:NotifyEvent(G_eventDef.UI_SHARETURNTABLEHISTORY)
        elseif name == "spinBtn" then               --点击旋转
            if self._args.dwRestCount <= 0 then
                G_event:NotifyEvent(G_eventDef.UI_SHAREINVITED)
                return
            end
            local llRequireScore = self.llRequireScore
            local llCurrentScore = self.llCurrentScore
            if llCurrentScore >= llRequireScore then            --如果可领取积分满了，就不能点击转盘抽奖。先领完后才能转盘抽奖
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
        end
    end
end

--领取奖励返回
function ShareTurnTableLayer:getGift(pData)
    local dwErrorCode = pData.dwErrorCode
    if dwErrorCode~=0 then return end
    local llScore = pData.llScore                   --当前收到的分数，炸花专用
    local llRequireScore = pData.llRequireScore     --下一次的需求分数，当前累积的会被清0
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
end

--点击旋转返回
function ShareTurnTableLayer:resolved(pData)
    dump(pData)
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
    self.spinTimesText:setPosition(cc.p(186 - self.spinTimesText:getContentSize().width/2,141))
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
    self.spinBtn:setTouchEnabled(bool)
    self.spinText:setBright(bool)
    self.spinBtn:setBright(bool)
    self.spinTimesText:setColor(bool and cc.c3b(255,255,255) or cc.c3b(190,190,190))
end

function ShareTurnTableLayer:updateLeftGift()
    local llRequireScore = self.llRequireScore
    local llCurrentScore = self.llCurrentScore
    if self.llCurrentScore >= self.llRequireScore then
        self.llCurrentScore = self.llRequireScore
    end  
    local llCurrentScore = self.llCurrentScore
    self.scoreText2:setString(string.format("É possível sacar quando a quantia for maior ou igual a  R$ %s",g_format:formatNumber(llRequireScore,g_format.fType.standard)))
    self.nowScoreText:setString(string.format("R$:%s",g_format:formatNumber(llCurrentScore,g_format.fType.standard)))
    local cha = llRequireScore - llCurrentScore
    self.scoreText1:setString(string.format("Quantidade mínima para realizar extração a distância R$ %s",g_format:formatNumber(cha >=0 and cha or 0,g_format.fType.standard)))
    if llCurrentScore>=llRequireScore then
        self.RecibirBtn:setBright(true)
        self.RecibirBtn:setTouchEnabled(true)
    else
        self.RecibirBtn:setBright(false)
        self.RecibirBtn:setTouchEnabled(false)
    end
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
    local initRotate = (6 - index) * 60 + math.random(1,59) - 1.5
    local needRotate = initRotate + math.ceil((self._nowRotation - initRotate) / 360) * 360 + 360 * 4
    
    self._nowRotation = needRotate
    local rotate = math.random(1,10)
    local time = self:clock()
    self:playSolveAnimation(4)
    self._turnEffect = AudioEngine.playEffect("sound/turnSolve.mp3", false)
    self.closeBtn:setTouchEnabled(false)
    self.closeBtn:setEnabled(false)
    TweenLite.to(self.turnTable,4,{ rotation = self._nowRotation,ease = Cubic.easeOut,
        onComplete = function() 
            g_ExternalFun.stopEffect(self._turnEffect)
                self._turnEffect = nil
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
    self.leftTopNode:runAction(cc.Sequence:create(
        cc.Spawn:create(
        cc.EaseBackInOut:create(cc.MoveBy:create(0.3,cc.p(500,0))),
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
    local nodeWorldPosition = spineNode:convertToWorldSpace(cc.p(0,300))
    local spineBoom = self._spineBoom
    if not spineBoom then
        spineBoom = self:addSpine(self._rootNode,"zhongjiangguang")
    end
    spineBoom:setPosition(nodeWorldPosition)
    local spine = self:addSpine(spineNode,"jinbi_zhizhen")
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

--更新我的头像金币
function ShareTurnTableLayer:updateMyScore(llReward)
    GlobalUserItem.lUserScore = GlobalUserItem.lUserScore + llReward
    local str = g_format:formatNumber(GlobalUserItem.lUserScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
    self.goldValue:setString(str)
    G_event:NotifyEventTwo(G_eventDef.NET_USER_SCORE_REFRESH)   --全局货币更新
    self:updateSpinBtnStatus()
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
                cc.FadeIn:create(0.2),
                cc.MoveBy:create(0.8,cc.p(0,20))
            ),
            cc.Spawn:create(
                cc.FadeOut:create(0.2),
                cc.MoveBy:create(0.2,cc.p(0,10))
            ),
            cc.CallFunc:create(function() 
                self.nowScoreAdd:hide()
            end)
        }
        self.nowScoreAdd:setString("+"..g_format:formatNumber(self._llReward,g_format.fType.standard))
        self.nowScoreAdd:show()
        self.nowScoreAdd:setOpacity(0)
        self.nowScoreAdd:setPosition(cc.p(388.2,283.22))
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
        local initPosition = cc.p(282,-(k - 1) * 74)
        item:setPosition(initPosition)

        local time = (0 - item:getPositionY()) / speed
        local time1 = (74) / speed
        local time2 = (321 - 74) / speed
        local time3 = 74 / speed
        local array = {
            cc.MoveTo:create(time,cc.p(282,0)),
            cc.CallFunc:create(function() 
                item:show()
            end),
            cc.Spawn:create(
                cc.MoveTo:create(time1,cc.p(282,74)),
                cc.FadeIn:create(time1)
            ),
            cc.MoveTo:create(time2,cc.p(282,321)),
            cc.Spawn:create(
                cc.MoveTo:create(time3,cc.p(282,395)),
                cc.FadeOut:create(time3)
            ),
            cc.CallFunc:create(function() 
                item:setPosition(cc.p(282,-(k - 1) * 74))
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

return ShareTurnTableLayer