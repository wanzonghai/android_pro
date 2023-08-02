local GameLogic = GameLogic or {}

--数目定义
GameLogic.CUR_CHAIRID				= -1			--当前自己的椅子id
GameLogic.CUR_TABLEID				= -1			--当前自己的桌子id
GameLogic.CUR_TRUMPCARD				= nil			--当前局王牌(公开牌下一张牌),牌的实际数值
GameLogic.MAX_PLAYER				= 4				--最大玩家数
GameLogic.SHOW_CARD_BTN_TIME		= nil			--亮牌按钮显示时间
GameLogic.IS_TRUSTEE_STATUS			= false			--是否托管状态
GameLogic.ENABLE_CONTINUE			= true			--是否可以继续游戏，破产，金币不足等不能继续

--事件消息
GameLogic.TRUCO_SHOW_WATERMASK               	= "truco_show_watermask"
GameLogic.TRUCO_DEAL_NET_QUEUE               	= "truco_deal_net_queue"
GameLogic.TRUCO_SEND_CARD						= "truco_send_card"
GameLogic.TRUCO_SHOW_CARD						= "truco_show_card"
GameLogic.TRUCO_START_TRUCO						= "truco_start_truco"
GameLogic.TRUCO_ANSWER_TRUCO					= "truco_answer_truco"
GameLogic.TRUCO_EXIT_REQ						= "truco_exit_req"
GameLogic.TRUCO_CHANGETABLE_REQ					= "truco_changetable_req"
GameLogic.TRUCO_READY_REQ						= "truco_ready_req"
GameLogic.TRUCO_FLUSH_PLAYER					= "truco_flush_player"
GameLogic.TRUCO_CONTINUE_CHOOSE					= "truco_continue_choose"
GameLogic.TRUCO_TRUSTEE_EVENT					= "truco_trustee_event"

--事件消息end


--原始牌大小
GameLogic.CARD_SORT =
{
	12,
	11,
	13,
	1,
	2,
	3
}


--拷贝表
function GameLogic:copyTab(st)
    local tab = {}
    for k, v in pairs(st) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
end

function GameLogic:updateGoldShow(_nodeText, _gapNums)
    tlog("GameLogic:updateGoldShow")
    _nodeText:stopAllActions()
    local lastNum = _nodeText._lastNum
    local curNum = _nodeText._curNum
    _nodeText:setString(lastNum)
    -- self:formatNumShow(_nodeText, lastNum)
    local loopNums = 30 -- math.ceil(4.8 / 0.1) --每0.05秒更新一次
    local gapNums = _gapNums and _gapNums or ((curNum - lastNum) / loopNums)
    self:addGoldNumsShowInterval(_nodeText, lastNum, curNum, gapNums)
end

function GameLogic:addGoldNumsShowInterval(_node, _srcNums, _dstNums, _addNums)
    -- tlog('GameLogic:addGoldNumsShowInterval')
    local nowNums = math.ceil(_srcNums + _addNums)
    if nowNums > _dstNums then
        nowNums = _dstNums
        _node:setString(nowNums)
        -- self:formatNumShow(_node, nowNums)
        return
    end
    _node:setString(nowNums)
    -- self:formatNumShow(_node, nowNums)
    _node:runAction(cc.Sequence:create(cc.DelayTime:create(0.03), cc.CallFunc:create(function (_target, _params)
        self:addGoldNumsShowInterval(_params.node, _params.srcNums, _params.dstNums, _params.addNums)
    end, {node = _node, srcNums = nowNums, dstNums = _dstNums, addNums = _addNums})))
end

--保存自己的chairId
function GameLogic:setSelfChairId(_chairId)
	tlog('GameLogic:setSelfChairId ', _chairId)
	GameLogic.CUR_CHAIRID = _chairId
end

function GameLogic:getSelfChairId()
	return GameLogic.CUR_CHAIRID
end

--保存自己的桌子ID
function GameLogic:setSelfTableId(_tableId)
	tlog('GameLogic:setSelfTableId ', _tableId)
	GameLogic.CUR_TABLEID = _tableId
end

function GameLogic:getSelfTableId()
	return GameLogic.CUR_TABLEID
end

--通过一个chairid获取其他座位的ID
function GameLogic:getOtherPlayerChairId(_chairId, _addIndex)
    local next_chair = _chairId + _addIndex
    local max_chairId = GameLogic.MAX_PLAYER - 1
    if next_chair > max_chairId then
    	next_chair = next_chair - GameLogic.MAX_PLAYER
    end
    return next_chair
end

--通过chairId获取在桌子上的位置，自己是0，逆时针加1
function GameLogic:getPositionByChairId(_chairId)
	return ((_chairId - GameLogic.CUR_CHAIRID) + GameLogic.MAX_PLAYER) % GameLogic.MAX_PLAYER
end

--是否跟自己同一组的
function GameLogic:getIsSameTeamWithMe(_chairId)
	return self:getPositionByChairId(_chairId) % 2 == 0
end

--通过chairId获取头像背景的index，跟自己一队的为红色2，对手为蓝色1
function GameLogic:getIconIndexByChairId(_chairId)
	if self:getIsSameTeamWithMe(_chairId) then
		return 2
	else
		return 1
	end
end

--通过座位序号获取头像背景的index
function GameLogic:getIconIndexByTableIndex(_index)
	if _index % 2 == 0 then
		return 1
	else
		return 2
	end
end

--保存王牌
function GameLogic:storeTrumpCardData(_cardData)
	if _cardData == 0 then
		tlog("open card should not be 0")
		GameLogic.CUR_TRUMPCARD = nil
		return
	end
	local cardValue = ylAll.POKER_VALUE[_cardData]
	local newIndex = 0
	local totalLength = #GameLogic.CARD_SORT
	for i, v in ipairs(GameLogic.CARD_SORT) do
		if v == cardValue then
			newIndex = i + 1
			if newIndex > totalLength then
				newIndex = 1
			end
			break
		end
	end
	GameLogic.CUR_TRUMPCARD = GameLogic.CARD_SORT[newIndex]
	tlog('GameLogic:storeTrumpCardData ', _cardData, GameLogic.CUR_TRUMPCARD)
end

--返回王牌
function GameLogic:getTrumpCard()
	tlog('GameLogic:getTrumpCard ', GameLogic.CUR_TRUMPCARD)
	return GameLogic.CUR_TRUMPCARD
end

--当前牌是否是王牌
-- _realCardValue  1 - 13
function GameLogic:isCurCardTrumpCard(_realCardValue)
	return _realCardValue == GameLogic.CUR_TRUMPCARD
end

--从小到大排序牌
-- 原始牌大小：Q < J < K < A < 2 < 3
-- 王牌是公开牌的下一个，如公开牌为J，王牌则为K，3的下一个为Q
-- 王牌才有的花色大小：方块 黑桃 红桃 梅花
-- 原始(映射之后)大小：A(11)-2(12)-3(13)-4(1)-5(2)-6(3)-7(4)-8(5)-9(6)-10(7)-J(9)-Q(8)-K(10)
function GameLogic:sortCardIndex(_cardData)
	--先剔除掉0值
	local filterData = {}
	for i, v in ipairs(_cardData) do
		if v ~= 0 then
			table.insert(filterData, v)
		end
	end
	local changeArray = {11, 12, 13, 1, 2, 3, 4, 5, 6, 7, 9, 8, 10}
	local colorArray = {0, 3, 2, 1} --颜色值映射大小数组,下发下来的排序是：方块 梅花 红桃 黑桃
	local newData = {}
	for i, v in ipairs(filterData) do
		local color = colorArray[ylAll.CARD_COLOR[v] + 1]
		local realValue = ylAll.POKER_VALUE[v]
		local newValue = changeArray[realValue]
		if GameLogic:isCurCardTrumpCard(realValue) then
			--公开牌
			newValue = 14
		end
		local data = {}
		data.value = newValue
		data.index = i
		data.color = color
		table.insert(newData, data)
	end
	table.sort(newData, function (a, b)
		if a.value == b.value then
			return a.color < b.color
		else
			return a.value < b.value
		end
	end)
	local _finalCardData = {}
	for i, v in ipairs(newData) do
		local curValue = filterData[v.index]
		table.insert(_finalCardData, curValue)
	end
	return _finalCardData
end

--转化服务器传过来的两队分数数据
-- _scoreData 两队的分数,序号0偶数队分数 1 奇数队分数,与自己的chairId对比
function GameLogic:convertTeamScoreData(_scoreData)
    local isSelfEven = ((self:getSelfChairId() % 2) == 0)
    local _newData = {0, 0}
    _newData[1] = (not isSelfEven) and _scoreData[1] or _scoreData[2] --对方分数
    _newData[2] = isSelfEven and _scoreData[1] or _scoreData[2] --自己分数
    tdump(_newData, "GameLogic:convertTeamScoreData", 10)
    return _newData
end

--保存亮牌按钮展示时间
function GameLogic:setShowCardBtnTimes(_showTimes)
	tlog('GameLogic:setShowCardBtnTimes ', _showTimes)
	GameLogic.SHOW_CARD_BTN_TIME = _showTimes
end

function GameLogic:getShowCardBtnTimes()
	return GameLogic.SHOW_CARD_BTN_TIME
end

--保存托管状态
function GameLogic:setIsTrusteeStatus(_isTrusteeStatus)
	tlog('GameLogic:setIsTrusteeStatus ', _isTrusteeStatus)
	GameLogic.IS_TRUSTEE_STATUS = _isTrusteeStatus
end

function GameLogic:getIsTrusteeStatus()
	return GameLogic.IS_TRUSTEE_STATUS
end

--保存破产状态
function GameLogic:setEnableContinueGame(_isContinue)
	tlog('GameLogic:setEnableContinueGame ', _isContinue)
	GameLogic.ENABLE_CONTINUE = _isContinue
end

function GameLogic:getEnableContinueGame()
	return GameLogic.ENABLE_CONTINUE
end

return GameLogic