-- truco游戏 玩家层

local TrucoPlayerLayer = class("TrucoPlayerLayer", cc.Node)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")
local TrucoPlayerNode = appdf.req(appdf.GAME_SRC .. "yule.truco.src.views.layer.TrucoPlayerNode")

function TrucoPlayerLayer:ctor(_playerItem)
	tlog('TrucoPlayerLayer:ctor')
	-- g_ExternalFun.registerNodeEvent(self)
    local csbNode = cc.CSLoader:createNode("UI/TrucoPlayerLayer.csb")
    csbNode:addTo(self)
    self.m_csbNode = csbNode

    self.m_playerItem = _playerItem

    --记录四个头像节点的初始位置pos, 庄家标识位置pePos, 玩家节点player,闪光特效节点 aniNode
    self.m_playerArray = {pos = {}, player = {}, pePos = {}, aniNode = {}}
    for i = 1, 4 do
    	local playerNode = csbNode:getChildByName(string.format("pNode_%d", i))
    	local pos = cc.p(playerNode:getPosition())
    	table.insert(self.m_playerArray.pos, pos)

        local curPlayerNode = TrucoPlayerNode:create(self.m_playerItem:clone():show())
        curPlayerNode:addTo(self.m_csbNode)
        curPlayerNode:setPosition(pos)
        self.m_playerArray.player[i] = curPlayerNode
        curPlayerNode:setShowPlayerInfo(false, i)

    	local peNode = csbNode:getChildByName(string.format("peNode_%d", i))
        pos = cc.p(peNode:getPosition())
    	table.insert(self.m_playerArray.pePos, pos)
    end

    --庄家标识
    self.m_peIcon = csbNode:getChildByName("Image_pe")
    self.m_peIcon.originPos = cc.p(0, 570) --初始点
    self.m_peIcon:setVisible(false)

    self.m_waitTip = csbNode:getChildByName("Node_wait"):hide()
    self.m_waitTip.waitNum = 0
end

--重设pe，倒计时显示等为初始状态
function TrucoPlayerLayer:resetOriginPlayerLayer()
    self.m_peIcon:setPosition(self.m_peIcon.originPos)
    self.m_peIcon:stopAllActions()
    self.m_peIcon:setVisible(false)

    for i, v in ipairs(self.m_playerArray.player) do
        v:endHideProgress()
    end
end

function TrucoPlayerLayer:getPlayerNode(_chairId)
    local pos_index = GameLogic:getPositionByChairId(_chairId) + 1
    local curPlayerNode = self.m_playerArray.player[pos_index]
    if not curPlayerNode then
        curPlayerNode = TrucoPlayerNode:create(self.m_playerItem:clone():show())
        curPlayerNode:addTo(self.m_csbNode)
        self.m_playerArray.player[pos_index] = curPlayerNode
    end
    curPlayerNode:setVisible(true)
    curPlayerNode:setPosition(self.m_playerArray.pos[pos_index])
    return curPlayerNode, pos_index
end

--显示头像
function TrucoPlayerLayer:showPlayerNode(_playerInfo)
    tlog('TrucoPlayerLayer:showPlayerNode')
    local curPlayerNode = self:getPlayerNode(_playerInfo.wChairID)
    curPlayerNode:reFlushNodeShow(_playerInfo, true)
end

--更新货币数量
function TrucoPlayerLayer:reFlushGoldNum(_playerInfo)
    tlog('TrucoPlayerLayer:reFlushGoldNum')
    local curPlayerNode = self:getPlayerNode(_playerInfo.wChairID)
    curPlayerNode:reFlushGoldNum(_playerInfo)
end

function TrucoPlayerLayer:setAllPlayerGray()
   for i, v in ipairs(self.m_playerArray.player) do
        v:setShowPlayerInfo(false, i)
    end 
end

-- 玩家离场，设置头像显示为黑色图标
function TrucoPlayerLayer:showGrayPlayerNode(_playerInfo)
    tlog("TrucoPlayerLayer:showGrayPlayerNode ", _playerInfo.dwUserID)
    for i, v in ipairs(self.m_playerArray.player) do
        local curInfo = v:getCurNodeInfo()
        if curInfo then
            if curInfo.dwUserID == _playerInfo.dwUserID then
                v:setShowPlayerInfo(false, i)
                self:checkAllPlayerReady()
                break
            end
        end
    end
end

--庄家标识飞的动画
function TrucoPlayerLayer:playPeFlyAction(_dstChairId, _withAction, _resetPos)
    tlog('TrucoPlayerLayer:playPeFlyAction ', _dstChairId, _withAction)
    self.m_peIcon:setVisible(true)
    self.m_peIcon:stopAllActions()
    local pos_index = GameLogic:getPositionByChairId(_dstChairId) + 1
    if _withAction then
        if _resetPos then
            self.m_peIcon:setPosition(self.m_peIcon.originPos)
        end
        local moveTo = cc.MoveTo:create(0.5, self.m_playerArray.pePos[pos_index])
        self.m_peIcon:runAction(moveTo)
        --牌局开始时，庄家标移动音效
        g_ExternalFun.playSoundEffect("truco_start_pemove.mp3")
    else
        self.m_peIcon:setPosition(self.m_playerArray.pePos[pos_index])
    end
end

function TrucoPlayerLayer:setPlayerNodeVisible(_bVisible)
    for i, v in ipairs(self.m_playerArray.player) do
        v:setVisible(_bVisible)
    end
end

--检查是否四个玩家已经满员了
function TrucoPlayerLayer:checkAllPlayerReady()
    local curReadyNum = 0
    local allHasReday = true
    for i, v in ipairs(self.m_playerArray.player) do
        local playerInfo = v:getCurNodeInfo()
        if playerInfo then
            curReadyNum = curReadyNum + 1
            tlog('playerInfo.cbUserStatus ', playerInfo.cbUserStatus, playerInfo.szNickName)
            if playerInfo.cbUserStatus == G_NetCmd.US_SIT then
                allHasReday = false
            end
        end
    end
    tlog('TrucoPlayerLayer:checkAllPlayerReady ', curReadyNum, allHasReday)
    local actCall = function ()
        if self.m_waitTip.waitNum == 0 then
            --非动画过程中启动动画，否则不重复启动
            local csbAniTimeline = cc.CSLoader:createTimeline("UI/Node_waitTip.csb")
            csbAniTimeline:gotoFrameAndPlay(0, true)
            self.m_waitTip:runAction(csbAniTimeline)
            self:showWaitPeopleAction()
        end
    end
    if curReadyNum >= GameLogic.MAX_PLAYER then
        if allHasReday then
            self:stopWaitAction()
        else
            self.m_waitTip.strTip = "Esperando que outros jogadores determinem "
            actCall()
        end
    else
        self.m_waitTip.strTip = "Esperando outros jogadores se sentarem "
        actCall()
    end
end

function TrucoPlayerLayer:stopWaitAction()
    tlog('TrucoPlayerLayer:stopWaitAction')
    self.m_waitTip:stopAllActions()
    self.m_waitTip:setVisible(false)
    self.m_waitTip.waitNum = 0
end

--Esperando outros jogadores se sentarem    等待其他玩家入座
--Esperando que outros jogadores determinem    等待其他玩家确定
--不满4个人的时候展示等待动画
function TrucoPlayerLayer:showWaitPeopleAction()
    -- tlog('TrucoPlayerLayer:showWaitPeopleAction')
    self.m_waitTip.waitNum = self.m_waitTip.waitNum + 1
    if self.m_waitTip.waitNum > 4 then
        self.m_waitTip.waitNum = 1
    end
    local pointStr = ""
    for i = 1, self.m_waitTip.waitNum do
        pointStr = pointStr .. "."
    end
    pointStr = self.m_waitTip.strTip .. pointStr
    self.m_waitTip:setVisible(true)
    self.m_waitTip:getChildByName("Text_wait_tip"):setString(pointStr)
    self.m_waitTip:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
        self:showWaitPeopleAction()
    end)))
end

--vs动画完了之后头像移动到相应位置
function TrucoPlayerLayer:playAfterVsAction(_posArr, _callBack)
    tdump(_posArr, "TrucoPlayerLayer:playAfterVsAction", 10)
    self:setPlayerNodeVisible(true)
    for i, v in ipairs(self.m_playerArray.player) do
        local curPos = _posArr[i]
        curPos = self.m_csbNode:convertToNodeSpace(curPos)
        tlog('curPos is ', curPos.x, curPos.y)
        v:setPosition(curPos)
        local moveTo = cc.MoveTo:create(0.5, self.m_playerArray.pos[i])
        if i == GameLogic.MAX_PLAYER then
            v:runAction(cc.Sequence:create(moveTo, cc.CallFunc:create(function ()
                if _callBack then
                    _callBack()
                end
            end)))
        else
            v:runAction(moveTo)
        end
    end
end

--倒计时
-- _enableOutCard 是否可以出牌，是就要取消其他所有的倒计时，否取消对家倒计时
function TrucoPlayerLayer:startPlayerProgress(_chairId, _totalTime, _curTimes, _enableOutCard)
    tlog('TrucoPlayerLayer:startPlayerProgress ', _chairId, _totalTime, _curTimes, _enableOutCard)
    local pos_index = GameLogic:getPositionByChairId(_chairId) + 1
    local same_team = GameLogic:getIsSameTeamWithMe(_chairId)
    for i, v in ipairs(self.m_playerArray.player) do
        if _enableOutCard then
            v:endHideProgress()
        else
            if (same_team and (i == 2 or i == 4)) or (not same_team and (i == 1 or i == 3)) then
                v:endHideProgress()
            end
        end
        if i == pos_index then
            v:startShowProgress(_totalTime, _curTimes, i == 1)
        end
    end
end

--关闭某个玩家的进度条显示
function TrucoPlayerLayer:stopSinglePlayerProgress(_chairId)
    tlog('TrucoPlayerLayer:stopSinglePlayerProgress ', _chairId)
    local pos_index = GameLogic:getPositionByChairId(_chairId) + 1
    local playerNode = self.m_playerArray.player[pos_index]
    if playerNode then
        playerNode:endHideProgress()
    end
end

--一局结束，显示赢的闪光
function TrucoPlayerLayer:showTurnWinEffect(_isSelfWin)
    local selfChairId = GameLogic:getSelfChairId()
    tlog('TrucoPlayerLayer:showTurnWinEffect ', selfChairId, _isSelfWin)
    local chairIdArray = {} --胜利者id合集
    if _isSelfWin then
        table.insert(chairIdArray, selfChairId)
        table.insert(chairIdArray, GameLogic:getOtherPlayerChairId(selfChairId, 2))
    else
        table.insert(chairIdArray, GameLogic:getOtherPlayerChairId(selfChairId, 1))
        table.insert(chairIdArray, GameLogic:getOtherPlayerChairId(selfChairId, 3))        
    end
    self:playFlashWinEffect(chairIdArray)
end

--一轮结束，显示赢的闪光,通过赢家id播放
function TrucoPlayerLayer:showTurnWinEffectByChairId(_winChairId)
    tlog('TrucoPlayerLayer:showTurnWinEffectByChairId ', _winChairId)
    local chairIdArray = {}
    table.insert(chairIdArray, _winChairId)
    table.insert(chairIdArray, GameLogic:getOtherPlayerChairId(_winChairId, 2))
    self:playFlashWinEffect(chairIdArray)
end

--获取一个可用的闪光特效节点
function TrucoPlayerLayer:getUseableFlashNodeAndPlay()
    local flashNode = nil
    for i, v in ipairs(self.m_playerArray.aniNode) do
        if not v:isVisible() then
            flashNode = v
        end
    end
    if not flashNode then
        flashNode = cc.CSLoader:createNode("UI/Node_touxiangtiexiao.csb")
        flashNode:addTo(self, 10)
        table.insert(self.m_playerArray.aniNode, flashNode)
    end
    flashNode:setVisible(true)
    local csbAnimation = cc.CSLoader:createTimeline("UI/Node_touxiangtiexiao.csb")
    csbAnimation:gotoFrameAndPlay(0, false)
    flashNode:runAction(csbAnimation)
    csbAnimation:setLastFrameCallFunc( function(frame)
        flashNode:setVisible(false)
    end)

    return flashNode
end

--闪光特效
function TrucoPlayerLayer:playFlashWinEffect(_chairIdArray)
    tlog('TrucoPlayerLayer:playFlashWinEffect')
    --赢家头像播放闪光动效音效
    g_ExternalFun.playSoundEffect("truco_round_win_effect.mp3")
    for i, v in ipairs(_chairIdArray) do
        local pos_index = GameLogic:getPositionByChairId(v) + 1
        local playerNode = self.m_playerArray.player[pos_index]
        if playerNode then
            playerNode:playTurnWinEffect()
        end
        local flashNode = self:getUseableFlashNodeAndPlay()
        local curPos = self.m_playerArray.pos[pos_index]
        flashNode:setPosition(curPos.x, curPos.y + 35)
    end
end

--分数上漂动画
--_resultShowCall 飘完金币后展示结算框
function TrucoPlayerLayer:playWinNumEffect(_winArray, _chairId, _resultShowCall, _playerArray)
    tlog('TrucoPlayerLayer:playWinNumEffect ', _chairId)
    local chairIdArray = {}
    table.insert(chairIdArray, _chairId)
    table.insert(chairIdArray, GameLogic:getOtherPlayerChairId(_chairId, 2))
    for i, v in ipairs(chairIdArray) do
        local pos_index = GameLogic:getPositionByChairId(v) + 1
        local playerNode = self.m_playerArray.player[pos_index]
        if playerNode then
            local call = ((i == 2) and _resultShowCall or nil)
            playerNode:nodePlayWinNumEffect(_winArray[v + 1], pos_index, call)
        end
    end

    for i, _playerInfo in ipairs(_playerArray) do
        local curPlayerNode = self:getPlayerNode(_playerInfo.wChairID)
        curPlayerNode:updatePlayerCoinShow(_playerInfo, true)
    end
end

--12分达成，游戏结束，显示赢光圈
function TrucoPlayerLayer:playFinialWinEffect(_chairId)

end

return TrucoPlayerLayer