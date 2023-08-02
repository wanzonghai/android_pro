-- truco 牌面层

local TrucoCardLayer = class("TrucoCardLayer", cc.Node)
local GameLogic = appdf.req(appdf.GAME_SRC .. "yule.truco.src.models.GameLogic")
local TrucoCardNode = appdf.req(appdf.GAME_SRC .. "yule.truco.src.views.layer.TrucoCardNode")
local cmd = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.CMD_Game")

local MAX_CARD_NUM = 3      --一个玩家最多的牌数
local ORIGIN_SCALE = 0.6    --中间位置牌的缩放

--牌的三种位置状态
local card_status = {
    status_origin = 1,      --在手牌内
    status_out = 2,         --被打出去了
    status_recovery = 3,    --打完一轮or一局被回收了 or 刚创建
}

function TrucoCardLayer:ctor()
    tlog('TrucoCardLayer:ctor')
    local csbNode = cc.CSLoader:createNode("UI/TrucoCardLayer.csb")
    csbNode:addTo(self)
    self.m_csbNode = csbNode

    local cardItem = cc.CSLoader:createNode("UI/TrucoCardNode.csb")
    cardItem:addTo(self):setVisible(false)
    self.m_cloneItem = cardItem:getChildByName("poker_bg"):hide()

    --中间的点
    self.m_centerNode = csbNode:getChildByName("Node_center")
    self.m_centerNode:setLocalZOrder(10) --它是高层级

    --有位置，缩放和x倾斜属性的需求
    --记录四个座位出牌的终点位置节点
    -- skewXNum 倾斜角度,设置之前要设置rotation为0
    self.m_dstCardNodeArray = {node = {}, skewXNum = {0, -8, 0, 8}}
    --四个座位手牌的三个位置节点
    self.m_originCardNodeArray = {}
    for i = 1, 4 do
        local dstNode = csbNode:getChildByName(string.format("Node_carddst_%d", i))
        table.insert(self.m_dstCardNodeArray.node, dstNode)

        local data = {}
        data.pos = {}
        data.card = {}
        for j = 1, 3 do
            local originNode = csbNode:getChildByName(string.format("Node_cardOrigin_%d_%d", i, j))
            table.insert(data.pos, originNode)
            local cardNode = TrucoCardNode:create(self.m_cloneItem:clone():show(), 0, true)
            cardNode:addTo(csbNode, 1)
            cardNode:setVisible(false)
            cardNode:setCurNodeStatus(card_status.status_recovery)
            table.insert(data.card, cardNode)
        end
        table.insert(self.m_originCardNodeArray, data)
    end
    self.m_trumpCardAction = {}
end

--重设牌层初始状态显示
function TrucoCardLayer:resetOriginCardLayer()
    for i, data in ipairs(self.m_originCardNodeArray) do
        for j, card in ipairs(data.card) do
            card:setCurNodeStatus(card_status.status_recovery)
            card:stopAllActions()
            card:setVisible(false)
        end
    end
    self:resetOtherCard()
    self:hideTrumpActNode()
end

function TrucoCardLayer:hideTrumpActNode()
    for i, v in ipairs(self.m_trumpCardAction) do
        v.actNode:setVisible(false)
    end
end

function TrucoCardLayer:resetOtherCard()
    self:hideOpenCard()
    if self.m_startAnimation then
        self.m_startAnimation:stopAllActions()
        self.m_startAnimation:setVisible(false)
    end
    self:stopAllActions()
end

--开始发牌前回收上一局剩余牌
function TrucoCardLayer:sendCardRecoveryLastCard(_callBack)
    local costTime = self:recoveryAllCard()
    tlog('TrucoCardLayer:sendCardRecoveryLastCard ', costTime)
    self:hideTrumpActNode()
    self:resetOtherCard()
    if costTime <= 0 then
        if _callBack then
            _callBack()
        end
    else
        self:runAction(cc.Sequence:create(cc.DelayTime:create(costTime), cc.CallFunc:create(function ()
            if _callBack then
                _callBack()
            end
        end)))
    end
end

--重连回来正在游戏状态时重设牌面显示
function TrucoCardLayer:reenterSetCardLayer(_cmdData, _allPlayerInfo)
    tlog("TrucoCardLayer:reenterSetCardLayer----")
    G_event:NotifyEventTwo(GameLogic.TRUCO_SHOW_WATERMASK)
    self:resetStartAnimationAndOpenCard(_cmdData.magicCard)

    --打出的牌
    local outCardArray = _cmdData.bRoundCard[1]
    local firstChairId = _cmdData.firstOutPlayer
    --恢复手牌
    local cardNumArr = _cmdData.HandleCount[1]
    local selfCardData = GameLogic:sortCardIndex(_cmdData.pokers[1])
    for j, player in ipairs(_allPlayerInfo) do
        local pos_index = GameLogic:getPositionByChairId(player.wChairID) + 1
        local cardNums = cardNumArr[player.wChairID + 1]
        local cardArray = self.m_originCardNodeArray[pos_index]
        for i = 1, cardNums do
            local cardNode = cardArray.card[i]
            if cardNode then
                cardNode:setCurNodeStatus(card_status.status_origin)
                cardNode:setVisible(true)
                local dstNode = cardArray.pos[i]
                cardNode:setPosition(dstNode:getPosition())
                cardNode:setScale(dstNode:getScale())
                cardNode:setRotation(dstNode:getRotation())
                if pos_index == 1 then
                    cardNode:showCardBack(false)
                    cardNode:setCardValue(selfCardData[i])
                else
                    cardNode:showCardBack(true)
                end
                cardNode:showCardGray(false)
                cardNode:showMaxEffect(false)
            else
                tlog("not cardNode, index overstep ", i)
            end
        end
        local outCardIndex = ((player.wChairID - firstChairId) + 4) % 4 + 1
        local outCardData = outCardArray[outCardIndex]
        if outCardData ~= 0 or (outCardData == 0 and outCardIndex <= _cmdData.bTrunCardCount) then
            local index = cardNums + 1
            local outCardNode = cardArray.card[index]
            if outCardNode then
                outCardNode:setCurNodeStatus(card_status.status_out)
                outCardNode:setVisible(true)
                local dstNode = self.m_dstCardNodeArray.node[pos_index]
                outCardNode:setPosition(dstNode:getPosition())
                outCardNode:setScale(dstNode:getScale())
                outCardNode:setRotation(0)
                outCardNode:setSkewX(self.m_dstCardNodeArray.skewXNum[pos_index])
                outCardNode:showCardBack(outCardData == 0)
                outCardNode:setCardValue(outCardData)
                outCardNode:showCardGray(false)
                outCardNode:showMaxEffect(false)
            else
                tlog("not outNode, index overstep ", index)
            end
        end
        tlog("TrucoCardLayer:reenterSetCardLayer ", pos_index, player.wChairID, cardNums, outCardIndex, outCardData)
    end
    self:setSelfCardEnableShowFlip()
end

--固定展示开始动画的最后一帧和公开牌
function TrucoCardLayer:resetStartAnimationAndOpenCard(_magicCard)
    tlog('TrucoCardLayer:resetStartAnimationAndOpenCard ', _magicCard)
    self:getStartAnimationNode()
    local csbAniTimeline = cc.CSLoader:createTimeline("UI/Node_xipaiqiepaidonghua.csb")
    csbAniTimeline:gotoFrameAndPlay(224, false)
    self.m_startAnimation:runAction(csbAniTimeline)
    --公开牌
    local cardNode = self:addOpenCard(_magicCard)
    cardNode:setPosition(-55, 0)
end

function TrucoCardLayer:getStartAnimationNode()
    if not self.m_startAnimation then
        local actNode = cc.CSLoader:createNode("UI/Node_xipaiqiepaidonghua.csb")
        actNode:addTo(self.m_centerNode, 2)
        self.m_startAnimation = actNode
    end
    self.m_startAnimation:setVisible(true)
    self.m_startAnimation:stopAllActions()
end

--开始游戏发牌动画
--_openCardData 公开牌数据
--_cardData 其他牌的数据(不包括他人)
function TrucoCardLayer:startGameCardAction(_openCardData, _cardData, _banker)
    self.m_bankerPos = GameLogic:getPositionByChairId(_banker) + 1
    tlog('TrucoCardLayer:startGameCardAction ', _openCardData, self.m_bankerPos, _banker)
    self:setSelfCardEnableShowFlip(false)--开始的时候先全隐藏
    local _selfCardData = GameLogic:sortCardIndex(_cardData)
    self:getStartAnimationNode()
    local csbAniTimeline = cc.CSLoader:createTimeline("UI/Node_xipaiqiepaidonghua.csb")
    csbAniTimeline:gotoFrameAndPlay(0, false)
    self.m_startAnimation:runAction(csbAniTimeline)
    csbAniTimeline:setLastFrameCallFunc(function()
        --最后一帧牌从底部出来
        local openCardNode = self:addOpenCard(_openCardData)
        openCardNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(-55, 0)), cc.CallFunc:create(function ()
            G_event:NotifyEventTwo(GameLogic.TRUCO_SHOW_WATERMASK)
            self:resetCardData(_selfCardData)
        end)))
    end)
    --扑克牌洗牌
    g_ExternalFun.playSoundEffect("truco_start_flushcard.mp3")
end

function TrucoCardLayer:addOpenCard(_openCardData)
    local openCardNode = self.m_centerNode:getChildByName("OpenCard")
    if not openCardNode then
        openCardNode = TrucoCardNode:create(self.m_cloneItem:clone():show(), 0)
        openCardNode:addTo(self.m_centerNode)
        openCardNode:setName("OpenCard")
        openCardNode:setScale(ORIGIN_SCALE)
        openCardNode:setSkewX(3)
    end
    openCardNode:setVisible(true)
    openCardNode:stopAllActions()
    openCardNode:setPosition(0, 0)
    openCardNode:setCardValue(_openCardData)
    openCardNode:showCardGray(false)
    openCardNode:showMaxEffect(false)
    return openCardNode
end

--影藏公开牌
function TrucoCardLayer:hideOpenCard()
    tlog("TrucoCardLayer:hideOpenCard")
    local cardNode = self.m_centerNode:getChildByName("OpenCard")
    if cardNode then
        cardNode:setVisible(false)
    end
end

--重设所有牌的属性
--重设自己的牌面值
function TrucoCardLayer:resetCardData(_selfCardData)
    tlog('TrucoCardLayer:resetCardData')
    for i, data in ipairs(self.m_originCardNodeArray) do
        for j, cardNode in ipairs(data.card) do
            cardNode:initCardProperty(0, 0, ORIGIN_SCALE, true)
            cardNode:showCardGray(false)
            cardNode:showMaxEffect(false)
            if i == 1 then
                cardNode:setCardValue(_selfCardData[j] or 0)
            end
        end
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
        --开始发牌动画
        self:startCardFlyAction(1)
    end)))
end

--开始发牌
function TrucoCardLayer:startCardFlyAction(_index)
    tlog("TrucoCardLayer:startCardFlyAction ", _index)
    if _index > MAX_CARD_NUM then
        tlog("card fly over")
        --发牌结束后读取下一个消息
        G_event:NotifyEventTwo(GameLogic.TRUCO_DEAL_NET_QUEUE, {time = 0.5})
        self:setSelfCardEnableShowFlip()
    else
        --发牌音效（连播4个，接着洗牌后音效播放）
        g_ExternalFun.playSoundEffect("truco_start_sendcard.mp3")
        local posx, posy = self.m_centerNode:getPosition()
        for i = 1, 4 do
            local curIndex = self.m_bankerPos + i
            curIndex = curIndex % 4
            if curIndex == 0 then
                curIndex = 4
            end
            tlog("curIndex is ", _index, curIndex)
            local data = self.m_originCardNodeArray[curIndex]

            local cardNode = data.card[_index]
            cardNode:setVisible(true)
            cardNode:setPosition(posx, posy)
            cardNode:setCurNodeStatus(card_status.status_origin)
            local dstNode = data.pos[_index]
            local posX = dstNode:getPositionX()
            local posY = dstNode:getPositionY()
            local delay = cc.DelayTime:create(0.02 * (curIndex - 1))
            local moveTo = cc.MoveTo:create(0.2, cc.p(posX, posY))
            local rotation = cc.RotateBy:create(0.2, 360)
            local scaleTo = cc.ScaleTo:create(0.2, dstNode:getScale())
            local spawn = cc.Spawn:create(moveTo, rotation, scaleTo)
            cardNode:runAction(cc.Sequence:create(delay, spawn, cc.CallFunc:create(function (t, p)
                if p.index == 1 then
                    t:cardBackFrontFlipAction(false, p.dstNode:getScale())
                else
                    t:setRotation(p.dstNode:getRotation())
                end
            end, {index = curIndex, dstNode = dstNode})))
        end
        _index = _index + 1
        --继续发各个座位的第二张牌
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function (t, p)
            --开始发牌动画
            self:startCardFlyAction(p.index)
        end, {index = _index})))
    end
end

--出牌
function TrucoCardLayer:playCardWithChairId(_chairId, _cardData, _isHide)
    local chairIndex = GameLogic:getPositionByChairId(_chairId)
    tlog('TrucoCardLayer:playCardWithChairId ', _chairId, _cardData, _isHide, chairIndex)
    function getOutCardNode(_cardData, _playerIndex)
        -- 获取自己出牌的序列
        local cardArr = self.m_originCardNodeArray[_playerIndex].card
        local length = #cardArr
        for i = length, 1, -1 do
            local card = cardArr[i]
            if _playerIndex == 1 then
                if card:getCurNodeStatus() == card_status.status_origin and card:getCardData() == _cardData then
                    return card
                end
            else
                if card:getCurNodeStatus() == card_status.status_origin then
                    return card
                end
            end
        end
        return nil
    end
    local cardNode = getOutCardNode(_cardData, chairIndex + 1)
    if cardNode then
        cardNode:stopAllActions()
        cardNode:setCurNodeStatus(card_status.status_out)
        cardNode:setCardValue(_cardData)
        local dstNode = self.m_dstCardNodeArray.node[chairIndex + 1]
        local finalPos = cc.p(dstNode:getPosition())
        local dstScale = dstNode:getScale()
        local skewX = self.m_dstCardNodeArray.skewXNum[chairIndex + 1]

        local rePosCall = cc.CallFunc:create(function (t, p)
            --自己的三张牌，如果中间的被出了，右边的左移
            local cardArr = self.m_originCardNodeArray[1]
            local index = 1
            for i, card in ipairs(cardArr.card) do
                if card:getCurNodeStatus() == card_status.status_origin then
                    local posX, posY = cardArr.pos[index]:getPosition()
                    if card:getPositionX() ~= posX then
                        local move = cc.MoveTo:create(0.1, cc.p(posX, posY))
                        card:runAction(move)
                    end
                    index = index + 1
                end
            end
        end)
        local lastCall = cc.CallFunc:create(function (t, p)
            self:hideTrumpActNode()
            G_event:NotifyEventTwo(GameLogic.TRUCO_DEAL_NET_QUEUE)
        end)
        local cardValue = ylAll.POKER_VALUE[_cardData]
        if GameLogic:isCurCardTrumpCard(cardValue) and (_isHide == 0) then
            --王牌的出牌要先有个变大再飞到出牌区的操作
            tlog("max card out")
            local delay = cc.DelayTime:create(0.8)
            local callfunc = cc.CallFunc:create(function (t, p)
                self:hideTrumpActNode()
                t:setPosition(p.pos)
                t:initCardProperty(0, p.skewX, p.scale + 0.2, _isHide == 1)
                self:playOutTrumpCardEffect(2, p.pos)
            end, {skewX = skewX, scale = dstScale, pos = finalPos}) --其他玩家的牌先初始化
            local scale_1 = cc.ScaleTo:create(0.2, dstScale)
            local delay1 = cc.DelayTime:create(0.8)
            if chairIndex == 0 then
                --自己
                local firstPosX, firstPosY = self.m_originCardNodeArray[1].pos[1]:getPosition()
                local endPos = cc.p(firstPosX - 50, firstPosY + 255)
                local moveTo = cc.MoveTo:create(0.15, endPos)
                local rotate = cc.RotateBy:create(0.15, 360)
                local scale = cc.ScaleTo:create(0.15, 1.2)
                local trumpAct = cc.Spawn:create(moveTo, rotate, scale)
                local actCall = cc.CallFunc:create(function (t, p)
                    self:playOutTrumpCardEffect(1, p.pos)
                end, {pos = endPos})
                cardNode:runAction(cc.Sequence:create(trumpAct, actCall, rePosCall, delay, callfunc, scale_1, delay1, lastCall))
            else
                cardNode:showCardBack(false) --提前显示正面
                local rotate = cc.RotateBy:create(0.15, 360)
                local scale = cc.ScaleTo:create(0.15, 1)
                local trumpAct = cc.Spawn:create(rotate, scale)
                local actCall = cc.CallFunc:create(function (t, p)
                    self:playOutTrumpCardEffect(1, cc.p(t:getPosition()))
                end)
                cardNode:runAction(cc.Sequence:create(trumpAct, actCall, delay, callfunc, scale_1, delay1, lastCall))
            end
        else
            local s_move = cc.MoveTo:create(0.15, finalPos)
            local s_scale = cc.ScaleTo:create(0.15, dstScale)
            local s_spawn = cc.Spawn:create(s_move, s_scale)
            --出普通牌
            g_ExternalFun.playSoundEffect("truco_out_card.mp3")
            tlog("normal card out")
            if chairIndex == 0 then
                cardNode:runAction(cc.Sequence:create(s_spawn, rePosCall, lastCall))
            else
                cardNode:initCardProperty(0, skewX, 1, _isHide == 1)
                cardNode:runAction(cc.Sequence:create(s_spawn, lastCall))
            end
        end
    else
        tlog("has no out card node")
    end
    if chairIndex == 0 then
        self:setSelfCardEnableShowFlip()
    end
end

--王牌特效
-- _type 第一阶段还是第二阶段
function TrucoCardLayer:playOutTrumpCardEffect(_type, _pos)
    tlog('TrucoCardLayer:playOutTrumpCardEffect ', _type)
    if not self.m_trumpCardAction[_type] then
        local data = {}
        local csbStr = string.format("UI/Node_zuidapaidachutexiao_%d.csb", _type - 1)
        local actNode = cc.CSLoader:createNode(csbStr)
        self.m_csbNode:addChild(actNode)
        data.actNode = actNode

        local actAnimation = cc.CSLoader:createTimeline(csbStr)
        actNode:runAction(actAnimation)
        data.actAnimation = actAnimation
        self.m_trumpCardAction[_type] = data
    end
    self.m_trumpCardAction[_type].actNode:setVisible(true)
    self.m_trumpCardAction[_type].actNode:setPosition(_pos)
    self.m_trumpCardAction[_type].actAnimation:gotoFrameAndPlay(0, false)
    --出王牌音效
    if _type == 1 then
        g_ExternalFun.playSoundEffect("truco_out_trump_card.mp3")
        -- self.m_trumpCardAction[_type].actNode:getChildByName("Particle_1"):start()
    elseif _type == 2 then
        g_ExternalFun.playSoundEffect("truco_out_trump_card_1.mp3")
    end
end

--出掉的牌回收到中间
function TrucoCardLayer:recoveryOutCard()
    tlog("TrucoCardLayer:recoveryOutCard")
    g_ExternalFun.playSoundEffect("truco_recovery_card.mp3")
    local dstPos = cc.p(self.m_centerNode:getPosition())
    for i, data in ipairs(self.m_originCardNodeArray) do
        for j, cardNode in ipairs(data.card) do
            if cardNode:getCurNodeStatus() == card_status.status_out then
                local delay = cc.DelayTime:create(0.05 * (i - 1))
                local moveTo = cc.MoveTo:create(0.15, dstPos)
                local scaleTo = cc.ScaleTo:create(0.15, ORIGIN_SCALE)
                local spawn = cc.Spawn:create(moveTo, scaleTo)
                local hide = cc.Hide:create()
                cardNode:runAction(cc.Sequence:create(delay, spawn, hide))
                cardNode:setCurNodeStatus(card_status.status_recovery)
            end
        end
    end
end

-- 牌全部回收至中间
function TrucoCardLayer:recoveryAllCard(_callBack)
    local dstPos = cc.p(self.m_centerNode:getPosition())
    local totalNums = 0 --总共有多少家有剩余牌
    for i, data in ipairs(self.m_originCardNodeArray) do
        local curNums = 0
        for j, cardNode in ipairs(data.card) do
            if cardNode:getCurNodeStatus() ~= card_status.status_recovery then --没被回收的才要回收
                curNums = 1
                local delay = cc.DelayTime:create(0.05 * (i - 1) + 0.025 * (j - 1))
                local moveTo = cc.MoveTo:create(0.2, dstPos)
                local scaleTo = cc.ScaleTo:create(0.2, ORIGIN_SCALE)
                local spawn = cc.Spawn:create(moveTo, scaleTo)
                local hide = cc.Hide:create()
                cardNode:runAction(cc.Sequence:create(delay, spawn, hide))
                cardNode:setCurNodeStatus(card_status.status_recovery)
                if totalNums == 0 then
                    g_ExternalFun.playSoundEffect("truco_recovery_card.mp3")
                end
            end
        end
        totalNums = totalNums + curNums
    end
    if costTimes == 0 then
        return 0
    else
        return 0.5 + 0.05 * totalNums --稍微延迟了一点
    end
end

--亮牌
function TrucoCardLayer:showCardWhenTurnOver(_cmdData)
    local pos_index = GameLogic:getPositionByChairId(_cmdData.chairID) + 1
    local cardData = GameLogic:sortCardIndex(_cmdData.HandleCard[1])
    local showNums = 0
    for i, v in ipairs(cardData) do
        if v ~= 0 then
            showNums = showNums + 1
        end
    end
    tlog('TrucoCardLayer:showCardWhenTurnOver ', showNums)
    local cardNodeArr = self.m_originCardNodeArray[pos_index]
    local centerPosX, centerPosY = cardNodeArr.pos[2]:getPosition() --中间的点
    for j, card in ipairs(cardNodeArr.card) do
        if j > showNums then
            card:setCurNodeStatus(card_status.status_recovery)
            card:setVisible(false)
        else
            card:setCurNodeStatus(card_status.status_out)
            card:setVisible(true)
            card:initCardProperty(0, 0, ORIGIN_SCALE, false)
            card:setCardValue(cardData[j])
            card:showCardGray(false)
            -- card:setPosition(centerPos.x + (110 * (j - 2)), centerPos.y)
            card:setPosition(centerPosX - 55 * (showNums - 1) + 110 * (j - 1), centerPosY) --自适应数量展示位置
            local scale1 = cc.ScaleTo:create(0.1, 0.01, ORIGIN_SCALE)
            local scale2 = cc.ScaleTo:create(0.1, ORIGIN_SCALE)
            card:runAction(cc.Sequence:create(scale1, scale2))
        end
    end
end

--一轮结束后展示最大的出牌
function TrucoCardLayer:showMaxValueCard(_cmdData, _callBack)
    local posArray = {}
    local allWin = false --true 都是隐藏牌
    if _cmdData.bBigCard == 255 then
        allWin = true
    end
    local winResult = _cmdData.WinRoundCount[1][_cmdData.MaxRoundCount]
    local _cardValue = nil
    if winResult == 0 then
        _cardValue = ylAll.POKER_VALUE[_cmdData.bBigCard]
    else
        _cardValue = _cmdData.bBigCard
    end
    tlog('TrucoCardLayer:showMaxValueCard ', _cardValue, allWin, winResult)
    for i, data in ipairs(self.m_originCardNodeArray) do
        for j, cardNode in ipairs(data.card) do
            if cardNode:getCurNodeStatus() == card_status.status_out then
                local cardData = cardNode:getCardData()
                local curData = nil
                if winResult == 0 then
                    curData = ylAll.POKER_VALUE[cardData]
                else
                    curData = cardData
                end
                if (curData == _cardValue) or allWin then
                    tlog("showMaxValueCard same value ", i, j)
                    local scaleTo = cc.ScaleTo:create(0.05, ORIGIN_SCALE + 0.1)
                    local srcPos = cardNode:getParent():convertToWorldSpace(cc.p(cardNode:getPosition()))
                    table.insert(posArray, srcPos)
                    cardNode:runAction(scaleTo)
                    cardNode:showMaxEffect(true)
                else
                    cardNode:showCardGray(true)
                end
            end
        end
    end

    local delaytime = cc.DelayTime:create(1.2)
    local callfunc = cc.CallFunc:create(function (t, p)
        self:recoveryOutCard()
        for i, v in ipairs(p.posArr) do
            if p.callBack then
                p.callBack(v, p.data, i)
            end
        end
    end, {posArr = posArray, callBack = _callBack, data = _cmdData})
    self.m_centerNode:runAction(cc.Sequence:create(delaytime, callfunc))
end

--自己的手牌是否置灰
function TrucoCardLayer:setSelfCardShowGray(_showGray)
    tlog('TrucoCardLayer:setSelfCardShowGray ', _showGray)
    local cardNodeArr = self.m_originCardNodeArray[1]
    for j, card in ipairs(cardNodeArr.card) do
        if card:getCurNodeStatus() == card_status.status_origin then
            card:showCardGray(_showGray)
        else
            card:showCardGray(false)
        end
    end
end

--自己的手牌是否可以点击
function TrucoCardLayer:setSelfCardTouchEnabled(_enabled)
    tlog('TrucoCardLayer:setSelfCardTouchEnabled ', _enabled, _showGray)
    local cardNodeArr = self.m_originCardNodeArray[1]
    for j, card in ipairs(cardNodeArr.card) do
        if card:getCurNodeStatus() == card_status.status_origin then
            card:setCardTouchEnabled(_enabled)
        else
            card:setCardTouchEnabled(false)
        end
    end
end

--自己的牌是否可以显示翻转按钮
-- _visiblePortiry 为false直接隐藏
function TrucoCardLayer:setSelfCardEnableShowFlip(_visiblePortiry)
    if _visiblePortiry == nil then
        _visiblePortiry = true
    end
    local cardNodeArr = self.m_originCardNodeArray[1]
    local thumbCardNums = 0 --手牌数量
    for j, card in ipairs(cardNodeArr.card) do
        if card:getCurNodeStatus() == card_status.status_origin then
            thumbCardNums = thumbCardNums + 1
        end
    end
    tlog('TrucoCardLayer:setSelfCardEnableShowFlip ', thumbCardNums, _visiblePortiry)
    for j, card in ipairs(cardNodeArr.card) do
        if card:getCurNodeStatus() == card_status.status_origin then
            card:showFlipBtnVisible(thumbCardNums < 3 and _visiblePortiry)
        else
            card:showFlipBtnVisible(false)
        end
    end
end

--11分临界情况 展示队友手牌
function TrucoCardLayer:showFriendCardWhenScoreEleven(_cmdData)
    local pos_index = GameLogic:getPositionByChairId(_cmdData.chairID) + 1
    local _index1 = GameLogic:getPositionByChairId(GameLogic:getOtherPlayerChairId(_cmdData.chairID, 2)) + 1
    tlog('TrucoCardLayer:showFriendCardWhenScoreEleven ', pos_index)
    local isShowFront = _cmdData.HandleCard[1][1] ~= 0
    local cardData = {}
    if isShowFront then
        cardData = GameLogic:sortCardIndex(_cmdData.HandleCard[1])
    end
    local posArray = {_index1, pos_index}
    for i, index in ipairs(posArray) do
        local centerPosX, centerPosY = self.m_dstCardNodeArray.node[index]:getPosition() --中间的点
        local cardArray = self.m_originCardNodeArray[index]
        for j, card in ipairs(cardArray.card) do
            card:setVisible(true)
            local isOther = (index % 2 == 0)
            card:setRotation(0)
            card:setSkewX(0)
            card:showCardBack(isOther)
            local delay = cc.DelayTime:create(0.02 * (j - 1))
            local scale = cc.ScaleTo:create(0.2, ORIGIN_SCALE)
            local addLength = isOther and 90 or 110
            local move = cc.MoveTo:create(0.2, cc.p(centerPosX + (addLength * (j - 2)), centerPosY))
            card:runAction(cc.Sequence:create(delay, cc.Spawn:create(scale, move)))
            if index == 3 and isShowFront then
                card:setCardValue(cardData[j])
            end
            card:showCardGray(false)
        end
    end
end

--11分操作结束，恢复牌正常显示
function TrucoCardLayer:reshowCardAfterEleven(_chairId)
    local _index = GameLogic:getPositionByChairId(_chairId) + 1
    local _index1 = GameLogic:getPositionByChairId(GameLogic:getOtherPlayerChairId(_chairId, 2)) + 1
    tlog('TrucoCardLayer:reshowCardAfterEleven ', _chairId, _index, _index1)
    local posArray = {_index, _index1}
    for j, pos_index in ipairs(posArray) do
        local cardArray = self.m_originCardNodeArray[pos_index]
        for i = 1, 3 do
            local cardNode = cardArray.card[i]
            if cardNode then
                cardNode:setCurNodeStatus(card_status.status_origin)
                cardNode:setVisible(true)
                cardNode:setSkewX(0)
                cardNode:showCardBack(pos_index ~= 1)
                local dstNode = cardArray.pos[i]
                local delay = cc.DelayTime:create(0.02 * (i - 1))
                local rotation = cc.RotateTo:create(0.2, dstNode:getRotation())
                local scale = cc.ScaleTo:create(0.2, dstNode:getScale())
                local addLength = isOther and 90 or 110
                local move = cc.MoveTo:create(0.2, cc.p(dstNode:getPosition()))
                cardNode:runAction(cc.Sequence:create(delay, cc.Spawn:create(rotation, scale, move)))
                cardNode:showCardGray(false)
                cardNode:showMaxEffect(false)
            else
                tlog("not cardNode, index overstep ", i)
            end
        end
    end
    if _index == 1 or _index1 == 1 then
        self:setSelfCardEnableShowFlip()
    end
end

return TrucoCardLayer