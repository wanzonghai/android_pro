-- truco游戏 结算界面

local TrucoDialogBase = appdf.req("game.yule.truco.src.views.layer.TrucoDialogBase")
local TrucoResultNode = class("TrucoResultNode", TrucoDialogBase)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")
local TrucoPlayerNode = appdf.req(appdf.GAME_SRC .. "yule.truco.src.views.layer.TrucoPlayerNode")

function TrucoResultNode:ctor(_playerItem)
	tlog('TrucoResultNode:ctor')
    TrucoResultNode.super.ctor(self, cc.c4b(0, 0, 0, 0))
    self.m_playerItem = _playerItem
    self.m_touchEnabled = false
	self:setTouchEndEnabled(false)

	self.m_actionNode = cc.Node:create()
	self.m_actionNode:addTo(self)
end

function TrucoResultNode:initView(_cmdData, _totalPlayerArr, _winChairId, _resultScore, _callBack, _endCall)
	tlog('TrucoResultNode:initView ', _winChairId)
	self:hideResultBroad()
	self:createColorLayer(cc.c4b(0, 0, 0, 0))
	self.m_touchEnabled = false
    self.m_winChairId = _winChairId
    self.m_totalPlayerArr = _totalPlayerArr
    self.m_winData = _cmdData
    self.m_resultScore = _resultScore

    if not self.m_coinFlyAniNode then
	    local coinNode = cc.CSLoader:createNode("UI/Node_feijinbidonghua.csb")
	    coinNode:addTo(self)
	    self.m_coinFlyAniNode = coinNode
	end
    local pos_index = GameLogic:getPositionByChairId(self.m_winChairId) + 1
    local otherChairId = GameLogic:getOtherPlayerChairId(self.m_winChairId, 2)
    local other_pos_index = GameLogic:getPositionByChairId(otherChairId) + 1
	self.m_coinFlyAniNode:setVisible(true)
	local nodeNameArr = {"Node_1", "Node_2", "Node_3", "Node_4"}
	for i, v in ipairs(nodeNameArr) do
		local node = self.m_coinFlyAniNode:getChildByName(v)
		if i == pos_index or i == other_pos_index then
			node:setVisible(false)
		else
			node:setVisible(true)
		end
	end
	--牌局结束，输家扔金币出去
    g_ExternalFun.playSoundEffect("truco_result_coin_loseOut.mp3")
    local csbAnimation = cc.CSLoader:createTimeline("UI/Node_feijinbidonghua.csb")
    csbAnimation:gotoFrameAndPlay(0, false)
    self.m_coinFlyAniNode:runAction(csbAnimation)
    csbAnimation:setFrameEventCallFunc( function(frame)
    	local eventName = frame:getEvent()
    	tlog('eventName is ', eventName)
        if eventName == "StartNodeEffect" then
            if _callBack then
            	_callBack(self.m_winChairId)
            end
        elseif eventName == "PlayCoinVoice" then
        	--牌局结束，金币飞向赢家
            g_ExternalFun.playSoundEffect("truco_result_coin_winIn.mp3")
        end
    end)
    csbAnimation:setLastFrameCallFunc(function()
    	self.m_coinFlyAniNode:setVisible(false)
    	if _endCall then
    		local broadCall = handler(self, self.showResultBroad)
    		_endCall(self.m_winData.lPlayAllScore[1], self.m_winChairId, broadCall, self.m_totalPlayerArr)
    	end
    end)
end

function TrucoResultNode:hideResultBroad()
	if self.m_winResultBroad then
		self.m_winResultBroad:stopAllActions()
		self.m_winResultBroad:setVisible(false)
	end
	if self.m_loseResultBroad then
		self.m_loseResultBroad:stopAllActions()
		self.m_loseResultBroad:setVisible(false)
	end
end

--显示结算框
function TrucoResultNode:showResultBroad()
	tlog('TrucoResultNode:showResultBroad')
	self:createColorLayer(cc.c4b(0, 0, 0, 200))
	--是否自己赢
	self.m_touchEnabled = false
    self.m_totalTime = self.m_winData.cbTimeLeave

	local isSelfWin = GameLogic:getIsSameTeamWithMe(self.m_winChairId)
	local curNode = nil
	local csbPath = ""
	if isSelfWin then
		--自己赢牌局时的音效
        g_ExternalFun.playSoundEffect("truco_result_win.mp3")
		csbPath = "UI/Node_jiesuandonghua_shengli.csb"
	    if not self.m_winResultBroad then
		    local csbNode = cc.CSLoader:createNode(csbPath)
		    csbNode:addTo(self, 10)
		    self.m_winResultBroad = csbNode
		end
		curNode = self.m_winResultBroad
		-- curNode:getChildByName("Particle_3"):start()
		-- curNode:getChildByName("Particle_4"):start()
	else
		--自己输牌局时的音效
        g_ExternalFun.playSoundEffect("truco_result_lose.mp3")
		csbPath = "UI/Node_jiesuandonghua_shibai.csb"
	    if not self.m_loseResultBroad then
		    local csbNode = cc.CSLoader:createNode(csbPath)
		    csbNode:addTo(self, 10)
		    self.m_loseResultBroad = csbNode
		end
		curNode = self.m_loseResultBroad
	end
	curNode:setVisible(true)
    self.m_curNode = curNode
    self:initResultNodeShow()
    self:initResultBtnShow()
    self:initResultTextShow()
    self:initProgressShow()
    local csbAnimation = cc.CSLoader:createTimeline(csbPath)
    csbAnimation:gotoFrameAndPlay(0, false)
    curNode:runAction(csbAnimation)
    csbAnimation:setLastFrameCallFunc(function()
    	self.m_touchEnabled = true
	    self:timeClockEvent()
    end)
end

--结算头像
function TrucoResultNode:initResultNodeShow()
	tlog("TrucoResultNode:initResultNodeShow")
	local nodeNameArr = {"Node_1", "Node_3", "Node_2", "Node_4"}
    for i, v in ipairs(self.m_totalPlayerArr) do
        local pos_index = GameLogic:getPositionByChairId(v.wChairID) + 1
    	local parentNode = self.m_curNode:getChildByName(nodeNameArr[pos_index])
        parentNode:removeAllChildren()
        local curPlayerNode = TrucoPlayerNode:create(self.m_playerItem:clone():show())
        curPlayerNode:addTo(parentNode)
        curPlayerNode:setPosition(0, 0)
        curPlayerNode:setVisible(true)
        curPlayerNode:reFlushNodeShow(v, false)
        curPlayerNode:setWinTipVisible(true, self.m_winData.lPlayAllScore[1][v.wChairID + 1])
    end
end

--结算按钮
function TrucoResultNode:initResultBtnShow()
	tlog('TrucoResultNode:initResultBtnShow')
    for i = 1, 3 do
    	local btn = self.m_curNode:getChildByName(string.format("Button_%d", i))
    	btn:setTag(i)
    	btn:onClicked(handler(self, self.onButtonClickEvent))
    	if i == 3 then
    		btn:setPositionX(93 - display.width * 0.5)
    	end
    end
end

--结算文本
function TrucoResultNode:initResultTextShow()
	local textTime = self.m_curNode:getChildByName("Node_time"):getChildByName("AtlasLabel_2")
	textTime:stopAllActions()
	textTime:setString(self.m_totalTime)

	local textTrucoTimes = self.m_curNode:getChildByName("truco_xx1_8"):getChildByName("AtlasLabel_1")
	textTrucoTimes:setString(string.format("x%d", self.m_resultScore.trucoTimes))

	local textBaseScore = self.m_curNode:getChildByName("Text_1")
	textBaseScore:setString(string.format("APOSTA:  %s", g_format:formatNumber(self.m_resultScore.baseScore,g_format.fType.abbreviation)))
	--判断自己输赢
	if GameLogic:getIsSameTeamWithMe(self.m_winChairId) then
		textBaseScore:setTextColor(cc.c4b(254, 232, 68, 255))
	else
		textBaseScore:setTextColor(cc.c4b(198, 217, 250, 255))
	end

	local textSelfScore = self.m_curNode:getChildByName("Text_2")
	local textOtherScore = self.m_curNode:getChildByName("Text_4")
	textSelfScore:setString(self.m_resultScore.selfScore)
	textOtherScore:setString(self.m_resultScore.otherScore)
end

function TrucoResultNode:initProgressShow()
	local node_time = self.m_curNode:getChildByName("Node_time")
	local node = node_time:getChildByName("Node_1")
	local progressNode = node:getChildByName("ResultProgress")
	if not progressNode then
		progressNode = cc.ProgressTimer:create(display.newSprite("GUI/animation/truco_result_dk.png"))
	    progressNode:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	    progressNode:setPosition(0, 0)
	    progressNode:addTo(node, 1)
	    progressNode:setReverseDirection(true)
	    progressNode:setName("ResultProgress")
	end
	progressNode:setVisible(false)
    progressNode:setPercentage(100)
    progressNode.curTotal = self.m_totalTime
end

function TrucoResultNode:onButtonClickEvent(_sender)
	local tag = _sender:getTag()
	tlog('TrucoResultNode:onButtonClickEvent ', tag, self.m_touchEnabled)
	if not self.m_touchEnabled then
		return
	end
    if self:removeNodeEvent(1) then
		if tag == 1 then
		    G_event:NotifyEventTwo(GameLogic.TRUCO_CHANGETABLE_REQ)
		elseif tag == 2 then
		    G_event:NotifyEventTwo(GameLogic.TRUCO_READY_REQ)
		elseif tag == 3 then
		    G_event:NotifyEventTwo(GameLogic.TRUCO_EXIT_REQ)
		else
			tlog("TrucoResultNode: error tag")
		end
	end
end

--倒计时
function TrucoResultNode:timeClockEvent()
	local node_time = self.m_curNode:getChildByName("Node_time")
	local textTime = node_time:getChildByName("AtlasLabel_2")
	local showStr = self.m_totalTime
	if showStr < 0 then
		showStr = 0
	end
	textTime:setString(math.ceil(showStr))
	local progressNode = node_time:getChildByName("Node_1"):getChildByName("ResultProgress")
	local costTime = 0
	if progressNode then
		progressNode:setVisible(true)
    	local curPercent = self.m_totalTime / progressNode.curTotal
		progressNode:setPercentage(curPercent * 100)
		costTime = progressNode.curTotal - self.m_totalTime
	end

	if self.m_totalTime > -1 then
		self.m_actionNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.03), cc.CallFunc:create(function ()
			self:timeClockEvent()
		end)))

		self.m_totalTime = self.m_totalTime - 0.03
		if costTime and costTime >= 6 then
			if not self:checkBankruptcyTrusteeStatus(2) then
				self:removeNodeEvent(2)
			end
		end
	else
	    if self:removeNodeEvent(2) then
		    G_event:NotifyEventTwo(GameLogic.TRUCO_READY_REQ)
		end
	end
end

function TrucoResultNode:setSelfVisible(_bVisible)
	tlog('TrucoResultNode:setSelfVisible ', _bVisible)
	self:setVisible(_bVisible)
	if self.listener then
		self.listener:setSwallowTouches(_bVisible)
	end
    self.m_actionNode:stopAllActions()
end

function TrucoResultNode:removeNodeEvent(_type)
	local normalProcess = self:checkBankruptcyTrusteeStatus(_type)
	tlog('TrucoResultNode:removeNodeEvent ', _type, normalProcess)
	if self.m_callBack then
		self.m_callBack()
	end
    self:setSelfVisible(false)
    if normalProcess then
	    G_event:NotifyEventTwo(GameLogic.TRUCO_FLUSH_PLAYER)
	else
		G_event:NotifyEventTwo(GameLogic.TRUCO_EXIT_REQ)
	end
    return normalProcess
end

--检查是否破产，是否处于托管状态等
--破产时 手动点击和倒计时结束都要退出
--托管时 倒计时结束退出
-- _type 1点击 2倒计时结束
-- return 是否正常进行流程
function TrucoResultNode:checkBankruptcyTrusteeStatus(_type)
	if not GameLogic:getEnableContinueGame() then
		return false
	else
		if _type == 2 and GameLogic:getIsTrusteeStatus() then
			return false
		end
	end
	return true
end

return TrucoResultNode