-- 下注金币层
local DoubleGoldLayer = class("DoubleGoldLayer", cc.Node)

local normalScale = 0.5
local offSetScale = 0.1
local randLengthX = 340  --所有可用区域为440*270
local randLengthY = 200
local max_bet_area = 3

function DoubleGoldLayer:ctor(_csbNode)
	tlog("DoubleGoldLayer:ctor")
	self.m_scoreNode = _csbNode
	self.m_betAreaUseGoldArray = {} --各区域已显示筹码,回收用
	self.m_goldMovePos = {}
	self.m_showGoldIndex = 0 --当前已显示筹码数量
	self.m_goldStaticNum = 500 --首批创建500个筹码备用
	self.m_goldZorderIndex = 0
	self.m_allGoldSpriteArray = {} --所有创建出来的筹码
	self.m_resultFntArray = {}  --输赢分数动画节点
    self:init()
end

function DoubleGoldLayer:init()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	self:initGold(self.m_goldStaticNum)

	--下注区域数量
	for i = 1, max_bet_area do
		table.insert(self.m_betAreaUseGoldArray, {})
	end
	--记录各个节点的位置
	for i = 1, 7 do
		if i <= 6 then
			--玩家座位
			local playerNode = self.m_scoreNode:getChildByName(string.format("playerPos_%d", i))
			local s_pos = cc.p(playerNode:getPosition())
			local keyStr = string.format("Player%d", i)
			self.m_goldMovePos[keyStr] = s_pos
			--下注区域
			if i <= max_bet_area then
				local dstNode = self.m_scoreNode:getChildByName(string.format("betPos_%d", i))
				s_pos = cc.p(dstNode:getPosition())
				keyStr = string.format("betPos%d", i)
				self.m_goldMovePos[keyStr] = s_pos
			end
		end
		local textFnt = self.m_scoreNode:getChildByName(string.format("fnt_bet_result_%d", i))
		textFnt:setVisible(false)
		textFnt.originPosY = textFnt:getPositionY()
		table.insert(self.m_resultFntArray, textFnt)
	end

	--所有玩家位置
	self.m_goldMovePos.Player0 = cc.p(self.m_scoreNode:getChildByName("totalPos"):getPosition())
	--自己位置
	self.m_goldMovePos.Player7 = cc.p(self.m_scoreNode:getChildByName("selfPos"):getPosition())
    self.m_otherBetIndex = {500000, 1000000, 5000000, 10000000, 50000000} --临时下注额度列表，用于统一处理其他玩家发放筹码 
end

--记录自己当前的下注列表，用于选择筹码
function DoubleGoldLayer:recordCurBetIndex(_betIndex)
	self.m_betDataIndex = clone(_betIndex)
end

function DoubleGoldLayer:initGold(goldNum)
	for j = 1, goldNum do
        local sp = cc.Sprite:createWithSpriteFrameName("double_bet_icon_1.png")
		sp:setVisible(false)
		self.m_scoreNode:addChild(sp)
		sp:setScale(normalScale)
		table.insert(self.m_allGoldSpriteArray, sp)
	end
end

--自己的筹码序号从下注列表获取
--不是自己的，随机取一个
function DoubleGoldLayer:getScoreSprite(betScore, _isSelf)
	if betScore <= 0 then
		return nil
	end
	local _betIndex = 1
	if _isSelf then
		for i, v in ipairs(self.m_betDataIndex) do
			if v == betScore then
				_betIndex = i
				break
			end
		end
	else
		_betIndex = math.random(1, 5)
	end
	-- tlog('DoubleGoldLayer:getScoreSprite ', betScore, _isSelf, _betIndex)
	local goldIndex = self.m_showGoldIndex + 1
	if goldIndex > self.m_goldStaticNum then
		-- print("金币数量不够，重新生成")
		self:initGold(200)
		self.m_goldStaticNum = self.m_goldStaticNum + 200
	end
	local coinSprite = self.m_allGoldSpriteArray[goldIndex]
	coinSprite:setVisible(true)
	--coinSprite:setTexture(string.format("double_bet_icon_%d.png", _betIndex))
	coinSprite:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("double_bet_icon_%d.png", _betIndex)))
	self.m_showGoldIndex = goldIndex
	return coinSprite
end

function DoubleGoldLayer:getBetDataArray(_isSelf)
	local betScoreData = nil
	if _isSelf then
		betScoreData = self.m_betDataIndex
	else
		betScoreData = self.m_otherBetIndex
	end
	return betScoreData
end

--通过下注额从筹码序列高到底获取每个档次筹码数量
function DoubleGoldLayer:getRandomScoreSprite(betScore, _isSelf)
	if betScore <= 0 then
		return {}, 0
	end
	local numArray = {0, 0, 0, 0, 0}
	local score = math.abs(betScore)
	local totalNum = 0
	local betScoreData = self:getBetDataArray(_isSelf)
	-- while do
	-- 	for i = 1, 5 do
			
	-- 	end
	-- end
	for i = 5, 1, -1 do
		local num = math.modf(score / betScoreData[i])
		if num > 0 then
			if num > 10 then
				num = 10 --避免太多
			end
			numArray[i] = num
			totalNum = totalNum + num
			score = score % betScoreData[i]
		end
	end
	if score ~= 0 then
		numArray[1] = numArray[1] + 1
		totalNum = totalNum + 1
	end
	-- tlog('DoubleGoldLayer:getRandomScoreSprite ', #numArray, totalNum, score, _isSelf)
	-- dump(numArray, "DoubleGoldLayer:getRandomScoreSprite")
	return numArray, totalNum, score
end

--玩家下注
function DoubleGoldLayer:playerBetEvent(_srcIndex, _destIndex, betScore, _isSelf)
	if _srcIndex < 0 or _srcIndex > 6 or _destIndex < 1 or _destIndex > max_bet_area then
		return
	end
	if _isSelf then
		_srcIndex = 7
	end
	-- tlog('DoubleGoldLayer:playerBetEvent ', _srcIndex, _destIndex, betScore, _isSelf, _srcIndex)
	local str = string.format("Player%d", _srcIndex)
	local srcPos = self.m_goldMovePos[str]
	str = string.format("betPos%d", _destIndex)
	local destPos = self.m_goldMovePos[str]
	--有续压，所以不直接用一个筹码
	local betScoreData = self:getBetDataArray(_isSelf)
	self:getCoinSpriteAndMove(betScore, _isSelf, betScoreData, srcPos, destPos, _destIndex, true)

	-- local goldSprite = self:getScoreSprite(betScore, _isSelf)
	-- if goldSprite then
	-- 	self:goleMoveAction(goldSprite, srcPos, self:setPosRand(destPos), 1, 0.05)
	-- 	table.insert(self.m_betAreaUseGoldArray[_destIndex], goldSprite)
	-- end
end

function DoubleGoldLayer:moveToWinArea(_winIndex)
	for i, v in ipairs(self.m_betAreaUseGoldArray) do
		if i ~= _winIndex then
			local cur_str = string.format("betPos%d", i)
			local areaCurPos = self.m_goldMovePos[cur_str]
			local new_str = string.format("betPos%d", _winIndex)
			local areaDstPos = self.m_goldMovePos[new_str]
			local offect_x = areaDstPos.x - areaDstPos.x
			local totalNum = #v
			if v ~= nil then
				for j, z in ipairs(v) do
					self:goleMoveAction(z, areaCurPos, self:setPosRand(areaDstPos), j, 0.5 / totalNum)
				end
				table.insertto(self.m_betAreaUseGoldArray[_winIndex], self.m_betAreaUseGoldArray[i])
				self.m_betAreaUseGoldArray[i] = {}
			end
		end
	end
	
end

--玩家收筹码
function DoubleGoldLayer:moveToPlayer(_dataArray, _winIndex, _callBack)
	local curUseItemNum = 1
	local allItemGoldNum = #self.m_betAreaUseGoldArray[_winIndex]
	tlog('DoubleGoldLayer:playerGetJetton ', allItemGoldNum, _winIndex)
	for i, data in ipairs(_dataArray) do
		if data.betMoney > 0 then --只有在开奖区域有下注的才处理
			local str = string.format("Player%d", data.seatIndex)
			local destPos = self.m_goldMovePos[str]
			local goldNumArray, totalNum, leftScore = self:getRandomScoreSprite(data.betMoney, data.isSelf)
			local _call = function (data)
				tlog("playerGetJetton _call fun")
				self:playWinResultFntAction(data.winMoney, data.seatIndex)
				if _callBack then
					_callBack(data.playerInfo, data.isSelf)
				end
			end
			local firstEnter = true
			for k, value in pairs(goldNumArray) do
				for j = 1, value do
					local call = nil
					if data.seatIndex ~= 0 and firstEnter then
						firstEnter = false
						call = cc.CallFunc:create(function (t, p)
							tlog("playerGetJetton call action")
							_call(p.data)
						end, {data = data})
					end
					if curUseItemNum <= allItemGoldNum then
						local spriteJetton = self.m_betAreaUseGoldArray[_winIndex][curUseItemNum]
						if spriteJetton then
							--spriteJetton:setTexture(string.format("double_bet_icon_%d.png", k))
							spriteJetton:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("double_bet_icon_%d.png", k)))
							self:goleMoveActionWithHide(spriteJetton, destPos, j, 0.5 / totalNum, call)
							curUseItemNum = curUseItemNum + 1
						end
					else
						--重新生成缺少的筹码数
						local needNum = value - j + 1
						local new_str = string.format("betPos%d", _winIndex)
						local areaDstPos = self.m_goldMovePos[new_str]
						for m = 1, needNum do
							local sprite = self:getScoreSprite(1, false)
							if sprite then
								--sprite:setTexture(string.format("double_bet_icon_%d.png", k))
								sprite:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("double_bet_icon_%d.png", k)))
								sprite:setPosition(self:setPosRand(areaDstPos))
								table.insert(self.m_betAreaUseGoldArray[_winIndex], sprite)
							end
						end
						allItemGoldNum = #self.m_betAreaUseGoldArray[_winIndex]
						local spriteJetton = self.m_betAreaUseGoldArray[_winIndex][curUseItemNum]
						if spriteJetton then
							--spriteJetton:setTexture(string.format("double_bet_icon_%d.png", k))
							spriteJetton:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("double_bet_icon_%d.png", k)))
							self:goleMoveActionWithHide(spriteJetton, destPos, j, 0.5 / totalNum, call)
							curUseItemNum = curUseItemNum + 1
						end
					end
				end
			end
		end
	end
	--筹码分配原因，最后会有剩下的，统一飞到总玩家处
	curUseItemNum = curUseItemNum - 1 --最后一次加没用上
	local leftNum = allItemGoldNum - curUseItemNum
	tlog("leftNum is ", leftNum, allItemGoldNum, curUseItemNum)
	for i = 1, leftNum do
		local destPos = self.m_goldMovePos.Player0
		local tempIndex = 0.5 / leftNum
		self:goleMoveActionWithHide(self.m_betAreaUseGoldArray[_winIndex][curUseItemNum + i], destPos, i, tempIndex)
	end
end

--玩家收筹码
function DoubleGoldLayer:playerGetJetton(_dataArray, _winIndex, _callBack)	
	self:moveToWinArea(_winIndex)
	local delay = cc.DelayTime:create(1.3)
	local seq = cc.Sequence:create(delay,cc.CallFunc:create(function()
		self:moveToPlayer(_dataArray, _winIndex, _callBack)
	end)
	)
self:runAction(seq)	
end

--文字上漂
function DoubleGoldLayer:playWinResultFntAction(_winNums, _posIndex)
	tlog('DoubleGoldLayer:playWinResultFntAction ', _winNums)
	local _tempNums = math.abs(_winNums)
	if _tempNums > 0 then
		local serverKind = G_GameFrame:getServerKind()
		local curNums = g_format:formatNumber(_tempNums,g_format.fType.standard,serverKind)
		local frontStr = ""
		local fntFile = ""
		if _winNums > 0 then
			frontStr = "+"
			fntFile = "GUI/num_pic/double_win_font.fnt"
		else
			frontStr = "-"
			fntFile = "GUI/num_pic/double_lose_font.fnt"
		end
		local winText = self.m_resultFntArray[_posIndex]
		winText:setFntFile(fntFile)
		winText:setVisible(true)
		winText:setString(string.format("%s%s", frontStr, curNums))
		winText:stopAllActions()
		winText:setPositionY(winText.originPosY)
		local moveBy = cc.MoveBy:create(0.5, cc.p(0, 50))
		local delay = cc.DelayTime:create(1.0)
		local hide = cc.Hide:create()
		winText:runAction(cc.Sequence:create(moveBy, delay, hide))
	end
end

--重置
function DoubleGoldLayer:reset()
	tlog('DoubleGoldLayer:reset')
	for i = 1, max_bet_area do
		self.m_betAreaUseGoldArray[i] = nil
		self.m_betAreaUseGoldArray[i] = {}
	end

	for i = 1, self.m_showGoldIndex do
		if self.m_allGoldSpriteArray[i] then
			self.m_allGoldSpriteArray[i]:setVisible(false)
			self.m_allGoldSpriteArray[i]:stopAllActions()
		end
	end
    self.m_showGoldIndex = 0
    self.m_goldZorderIndex = 0
end

--设置下注区域位置随机
function DoubleGoldLayer:setPosRand(_pos)
	local xx = randLengthX * (0.5 - math.random())
	local yy = randLengthY * (0.5 - math.random())
	local ppos = {}
	ppos.x = _pos.x + xx
	ppos.y = _pos.y + yy
	return ppos
end

function DoubleGoldLayer:goleMoveActionWithHide(_targetNode, _desPos, _delayIndex, _timeRate, _callAction)
  	local srcPos = cc.p(_targetNode:getPosition())
  	self:goleMoveAction(_targetNode, srcPos, _desPos, _delayIndex, _timeRate, true, _callAction)
end

function DoubleGoldLayer:goleMoveAction(_targetNode, _srcPos, _desPos, _delayIndex, _timeRate, _bHide, _callAction)
	-- tlog('DoubleGoldLayer:goleMoveAction ', _delayIndex, _timeRate, _bHide)
	-- tlog('_srcPos, _desPos ', _srcPos.x, _srcPos.y, _desPos.x, _desPos.y)
	_targetNode:setLocalZOrder(self.m_goldZorderIndex)
	self.m_goldZorderIndex = self.m_goldZorderIndex + 1

	_targetNode:stopAllActions()
	_targetNode:setPosition(_srcPos)
	_targetNode:setVisible(true)
	_targetNode:setScale(normalScale)
	local bezier = {
		_srcPos,
    	cc.p((_srcPos.x + _desPos.x) * 0.5, (_srcPos.y + _desPos.y) * 0.5 + 100),
    	_desPos,
  	}
  	local useTime = 0.4 + (_delayIndex - 1) * _timeRate
  	-- local bezierForward = cc.BezierTo:create(useTime, bezier)
  	local bezierForward = cc.EaseInOut:create(cc.BezierTo:create(useTime, bezier), 1)
    -- if bezierForward.setAutoRotate then
    --     bezierForward:setAutoRotate(false)
    -- end
    if not _callAction then
    	_callAction = cc.CallFunc:create(function ()
    	end)
    end
  	if _bHide then
	  	local seq = cc.Sequence:create(bezierForward, cc.Hide:create(), _callAction)
	  	_targetNode:runAction(seq)
	else
		local rotate = cc.RotateTo:create(useTime, math.random(2, 5) * math.random(300, 380))
		-- local scale = cc.ScaleTo:create(0.1, normalScale + offSetScale)
		-- local scale1 = cc.ScaleTo:create(0.1, normalScale)
	  	-- local seq = cc.Sequence:create(cc.Spawn:create(bezierForward, rotate), scale, scale1, _callAction)
	  	local seq = cc.Sequence:create(cc.Spawn:create(bezierForward, rotate), _callAction)
	  	-- local seq = cc.Sequence:create(bezierForward, scale, scale1)
	    _targetNode:runAction(seq)
	end
end

--重连时玩家总下注显示筹码
function DoubleGoldLayer:reenterShowBetCoin(_index, _betScore)
	tlog('DoubleGoldLayer:reenterShowBetCoin ', _index, _betScore)
	if _betScore <= 0 then
		return
	end
	local str = string.format("betPos%d", _index)
	local destPos = self.m_goldMovePos[str]
	self:getCoinSpriteAndMove(_betScore, false, self.m_otherBetIndex, nil, destPos, _index, false)
end

function DoubleGoldLayer:getCoinSpriteAndMove(betScore, isSelf, betDataArray, srcPos, destPos, index, isMove)
	-- tlog('DoubleGoldLayer:getCoinSpriteAndMove ', betScore, isSelf, index, isMove)
	if isMove == nil then
		isMove = true
	end
	local goldNumArray, totalNum, leftScore = self:getRandomScoreSprite(betScore, isSelf)
	for k, value in pairs(goldNumArray) do
		for j = 1, value do
			local betScore = betDataArray[k]
			-- if k == 1 and j == value and leftScore ~= 0 then
			-- 	betScore = leftScore
			-- end
			local sprite = self:getScoreSprite(betScore, isSelf)
			if sprite then
				if isMove then
					self:goleMoveAction(sprite, srcPos, self:setPosRand(destPos), j, 0.5 / totalNum)
				else
					sprite:setPosition(self:setPosRand(destPos))
				end
				table.insert(self.m_betAreaUseGoldArray[index], sprite)
			end
		end
	end
end

return DoubleGoldLayer