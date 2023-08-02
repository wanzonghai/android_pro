-- truco游戏 顶部积分展示节点

local TrucoScoreNode = class("TrucoScoreNode", cc.Node)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")

-- _rewardScoreText 团队奖金节点
function TrucoScoreNode:ctor(_scoreNode, _rewardScoreText)
	tlog('TrucoScoreNode:ctor')
    local parentNode = _scoreNode:getChildByName("Image_truco_score")
    self.m_parentImage = parentNode
    self.m_scoreNode = _scoreNode
    self.m_imagePointArr = {} --三个结果的点
    for i = 1, 3 do
    	local pointNode = parentNode:getChildByName(string.format("Image_point_%d", i))
    	pointNode:setVisible(false)
    	table.insert(self.m_imagePointArr, pointNode)
    end

    self.m_baseScore = 0
    self.m_rewardScoreText = _rewardScoreText
    self:reflushCurPoint(0, true)
    self:reflushTrucoTimes(0)

    --分数展示文本,1是对方，2是己方
    self.m_scoreArray = {}
    for i = 1, 2 do
    	local scoreText = parentNode:getChildByName(string.format("Text_score_%d", i))
    	scoreText:setString("0")
    	table.insert(self.m_scoreArray, scoreText)
    end
end

function TrucoScoreNode:hideTurnWinPoint()
    for i = 1, 3 do
        self.m_imagePointArr[i]:setVisible(false)
    end
end

--重设面板初始状态显示
function TrucoScoreNode:resetPanelOriginShow()
    self:reenterResetPanelShow({}, 0, {0, 0}, 0)
    self:reflushTrucoTimes(0)
end

--重连回来正在游戏状态时重设面板显示
-- _winData 每轮的输赢数据
-- _curMaxTurn 当前是第几轮
-- _scoreData 两队的分数
-- _curPoint 当前局的叫分
function TrucoScoreNode:reenterResetPanelShow(_winData, _curMaxTurn, _scoreData, _curPoint)
    tlog('TrucoScoreNode:reenterResetPanelShow')
    local _newData = self:convertWinData(_winData)
    _scoreData = GameLogic:convertTeamScoreData(_scoreData)
    for i = 1, 3 do
        local bVisible = (_curMaxTurn >= i)
        self.m_imagePointArr[i]:setVisible(bVisible)
        if bVisible then
            self.m_imagePointArr[i]:loadTexture(string.format("GUI/truco_fsp_%d.png", _newData[i]))
        end
        if i <= 2 then
            self.m_scoreArray[i]:setString(_scoreData[i])
        end
    end
    self:reflushCurPoint(_curPoint, true)
end

--把服务器传过来的当局输赢数据转化为客户端需要的对应图片编号的格式
-- _winData 每轮的输赢数据,值为1奇数位置赢 2偶数位置赢 0一样大,与自己的chairId对比
-- 自己队用红色点2，对方用蓝色1,平局用黄色3
function TrucoScoreNode:convertWinData(_winData)
    local _newData = {}
    local isSelfEven = ((GameLogic:getSelfChairId() % 2) == 0)  --自己的座位号是不是偶数
    tlog("TrucoScoreNode:convertWinData ", isSelfEven)
    for i, v in ipairs(_winData) do
        if isSelfEven then
            if v == 1 then
                _newData[i] = 1
            elseif v == 2 then
                _newData[i] = 2
            else
                _newData[i] = 3
            end
        else
            if v == 1 then
                _newData[i] = 2
            elseif v == 2 then
                _newData[i] = 1
            else
                _newData[i] = 3
            end
        end
    end
    tdump(_newData, "TrucoScoreNode:convertWinData", 10)
    return _newData
end

--刷新当前点数
-- _noAction 直接设置
function TrucoScoreNode:reflushCurPoint(_pointNum, _noAction, _isNewStart)
    tlog('TrucoScoreNode:reflushCurPoint ', _pointNum, _noAction, _isNewStart)
    if _isNewStart == nil then
        _isNewStart = false
    end
    local _nameImage = self.m_parentImage:getChildByName("Image_point")
    local _pointImage = _nameImage:getChildByName("Image_point_num")
    if _pointImage._nums_ and (_pointImage._nums_ >= _pointNum) and (not _isNewStart) then
        _noAction = true
    end
    _pointImage._nums_ = _pointNum
    _pointImage:loadTexture(string.format("GUI/truco_%d.png", _pointNum))
    _pointImage:setContentSize(_pointImage:getVirtualRendererSize())
    _nameImage:stopAllActions()
    _nameImage:setScale(1)
    if _pointNum >= 12 then
        _nameImage:setPositionX(178)
    else
        _nameImage:setPositionX(187)
    end

    local _tipImage = self.m_parentImage:getChildByName("Image_3")
    if not _noAction then
        _tipImage:setVisible(true)
        _nameImage:setScale(1.5)
        local delay = cc.DelayTime:create(1.2)
        local scale = cc.ScaleTo:create(0.1, 1)
        local call = cc.CallFunc:create(function ()
            _tipImage:setVisible(false)
        end)
        _nameImage:runAction(cc.Sequence:create(delay, scale, call))
    else
        _tipImage:setVisible(false)
    end
end

--一轮结束后如果不是直接认输的，则播放飞当前局点数的动画
-- 如果是前两轮，只飞当前局点数，不会更新积分
-- 最后一轮表示当前局结束，飞完点数更新积分
-- _srcPos 哪张牌最大从哪张牌飞
function TrucoScoreNode:pointFlyActionWhenTurnEnd(_srcPos, _cmdData, _index)
	tlog('TrucoScoreNode:pointFlyActionWhenTurnEnd ', _srcPos.x, _srcPos.y)
    local dstNode = self.m_imagePointArr[_cmdData.MaxRoundCount]
    if not dstNode then
        tlog("pointFlyActionWhenTurnEnd not dstNode")
        return
    end
    --飘点数动画
    local animationNode = cc.CSLoader:createNode("UI/Node_shangpiaofenshudian.csb")
    animationNode:addTo(self.m_parentImage)
    -- animationNode:getChildByName("Particle_1"):setPositionType(cc.POSITION_TYPE_FREE)

    local posx, posy = dstNode:getPosition()
    local position = self.m_parentImage:convertToNodeSpace(_srcPos)
    tlog('position is ', position.x, position.y)
    animationNode:setPosition(position)
    animationNode:setVisible(true)
    local csbAnimation = cc.CSLoader:createTimeline("UI/Node_shangpiaofenshudian.csb")
    csbAnimation:play("animation0", false)
    animationNode:runAction(csbAnimation)

    local _newData = self:convertWinData(_cmdData.WinRoundCount[1])
    local turnWinResult = _newData[_cmdData.MaxRoundCount]
    self:setAnimationPointShow(animationNode, turnWinResult)
    local move = cc.MoveTo:create(0.7, cc.p(posx, posy))
    local call = cc.CallFunc:create(function (t, p)
        tlog("fly over show result ", p.index)
        if p.index == 1 then
            local animation1 = cc.CSLoader:createTimeline("UI/Node_shangpiaofenshudian.csb")
            animation1:play("animation1", false)
            t:runAction(animation1)
            animation1:setLastFrameCallFunc(function()
                t:removeFromParent()
                G_event:NotifyEventTwo(GameLogic.TRUCO_DEAL_NET_QUEUE)
            end)

            p.dstNode:setVisible(true)
            p.dstNode:loadTexture(string.format("GUI/truco_fsp_%d.png", p.result))
            --记分牌展示牌局输赢打平的星星时音效
            g_ExternalFun.playSoundEffect("truco_score_changed.mp3")
        else
            t:setVisible(false)
        end
    end, {dstNode = dstNode, result = turnWinResult, index = _index})

    local call_1 = cc.CallFunc:create(function (t, p)
        if p.index == 1 then
            self:updateScoreShow(p.scoreData)
        else
            t:removeFromParent()
        end
    end, {scoreData = _cmdData.Score[1], index = _index})
    animationNode:runAction(cc.Sequence:create(move, call, call_1))
end

--根据结果设置飘飞的点动画的图片展示
function TrucoScoreNode:setAnimationPointShow(_node, _curResult)
    for i = 1, 3 do
        for j = 1, 2 do
            local node = _node:getChildByName(string.format("truco_fsp_point_%d_%d", i, j))
            node:setVisible(i == _curResult)
        end
    end
end

--直接设置当轮分数
function TrucoScoreNode:turnEndSetPointShow(_cmdData)
    tlog('TrucoScoreNode:turnEndSetPointShow')
    self:updateScoreShow(_cmdData.Score[1])
end

function TrucoScoreNode:updateScoreShow(_cmdScore)
    local _scoreData = GameLogic:convertTeamScoreData(_cmdScore)
    tlog('TrucoScoreNode:updateScoreShow')
    for i = 1, 2 do
        local curText = self.m_scoreArray[i]
        local lastNum = tonumber(curText:getString())
        local curNum = _scoreData[i]
        if curNum > lastNum then
            local aniName = ""
            if i == 1 then
                aniName = "animation1" --对方队
            else
                aniName = "animation0"
            end
            local animation = cc.CSLoader:createTimeline("UI/TrucoScoreNode.csb")
            animation:play(aniName, false)
            self.m_scoreNode:runAction(animation)
        end
        curText:setString(curNum)
    end
end

--刷新当前12分之内所有truco/加注的次数
function TrucoScoreNode:reflushTrucoTimes(_nums, _baseScore)
    local timeNode = self.m_parentImage:getChildByName("Image_star"):getChildByName("text_nums")
    timeNode:setString(string.format("/%d", _nums))
    timeNode.times = _nums
    if _baseScore ~= nil then
        self.m_baseScore = _baseScore
    else
        if _nums ~= 0 then
            timeNode:stopAllActions()
            timeNode:setScale(1)
            timeNode:setScale(1.5)
            local delay = cc.DelayTime:create(1.0)
            local scale = cc.ScaleTo:create(0.1, 1)
            timeNode:runAction(cc.Sequence:create(delay, scale))
        end
    end
    local serverKind = G_GameFrame:getServerKind()
    local curRewardNum = (_nums + 1) * (self.m_baseScore * 2)
    if curRewardNum > 99999 then
        curRewardNum = g_format:formatNumber(curRewardNum,g_format.fType.abbreviation,serverKind)
    else
        curRewardNum = g_format:formatNumber(curRewardNum,g_format.fType.Custom_k,serverKind)
    end

    self.m_rewardScoreText:setString(string.format("Bônus de equipe %s", curRewardNum))
end

--获取底分，当前truco次数，比分等
function TrucoScoreNode:getResultScoreValue()
    local timeNode = self.m_parentImage:getChildByName("Image_star"):getChildByName("text_nums")

    local data = {}
    data.baseScore = self.m_baseScore
    data.trucoTimes = timeNode.times
    data.selfScore = tonumber(self.m_scoreArray[2]:getString())
    data.otherScore = tonumber(self.m_scoreArray[1]:getString())
    tdump(data, "TrucoScoreNode:getResultScoreValue", 10)
    return data
end

--通过面板旧分数及最新结果获取哪队赢了
function TrucoScoreNode:getCurRoundWinResult(_cmdData)
    local _scoreData = GameLogic:convertTeamScoreData(_cmdData.Score[1])
    tlog('TrucoScoreNode:getCurRoundWinResult')
    local winIndex = nil
    for i = 1, 2 do
        local curText = self.m_scoreArray[i]
        local lastNum = tonumber(curText:getString())
        if _scoreData[i] > lastNum then
            winIndex = i
            break
        end
    end
    return winIndex == 2    --2是己方序号
end

return TrucoScoreNode