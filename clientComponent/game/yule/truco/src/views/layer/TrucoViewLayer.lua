local TrucoViewLayer = class("TrucoViewLayer",function(scene)
		local trucoViewLayer = display.newLayer()
    return trucoViewLayer
end)
local module_pre = "game.yule.truco.src"
local g_var = g_ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"
local TrucoHelpLayer = appdf.req(module_pre .. ".views.layer.TrucoHelpLayer")
local TrucoButtonNode = appdf.req(module_pre .. ".views.layer.TrucoButtonNode")
local TrucoBubbleLayer = appdf.req(module_pre .. ".views.layer.TrucoBubbleLayer")
local TrucoScoreNode = appdf.req(module_pre .. ".views.layer.TrucoScoreNode")
local TrucoPlayerLayer = appdf.req(module_pre .. ".views.layer.TrucoPlayerLayer")
local TrucoCardLayer = appdf.req(module_pre .. ".views.layer.TrucoCardLayer")
local TrucoWaterMaskNode = appdf.req(module_pre .. ".views.layer.TrucoWaterMaskNode")
local TrucoStartAniNode = appdf.req(module_pre .. ".views.layer.TrucoStartAniNode")
local TrucoResultNode = appdf.req(module_pre .. ".views.layer.TrucoResultNode")
local TrucoTrusteeNode = appdf.req(module_pre .. ".views.layer.TrucoTrusteeNode")
local TrucoChatLayer = appdf.req(module_pre .. ".views.layer.TrucoChatLayer")
local TrucoChatAnimNode = appdf.req(module_pre .. ".views.layer.TrucoChatAnimNode")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")
local g_scheduler = cc.Director:getInstance():getScheduler()

local enumTable = 
{
	"BT_EXIT",
	"BT_SOUND",			--音效
	"BT_HELP",
	"BT_EXCHANGE",
}
local TAG_ENUM = g_ExternalFun.declarEnumWithTable(100, enumTable)

function TrucoViewLayer:ctor(scene)
	tlog('TrucoViewLayer:ctor')
	--注册node事件
	g_ExternalFun.registerNodeEvent(self)
	
	self._scene = scene
	self:gameDataInit()

	--初始化csb界面
	self:initCsbRes()
	self:registerTouch()
	self:registerListenEvent()
end

function TrucoViewLayer:gameDataInit()
	tlog('TrucoViewLayer:gameDataInit')
    --背景音乐
    g_ExternalFun.playMusic("sound_res/truco_bg_music.mp3", true)
    --用户列表
	self:getDataMgr():initUserList(self:getParentNode():getUserList())
    --加载资源
	self:loadRes()
	self.m_isAnimationPlay = false 		--是否正在播放动画
	self.m_netQueueArray = {} 			--网络消息队列
	self.m_gameEndStatus = false 	 	--是否是结算时间，结算时间暂不处理玩家进出问题
end

function TrucoViewLayer:loadRes()
	tlog('TrucoViewLayer:loadRes')
	--加载卡牌纹理
	-- cc.Director:getInstance():getTextureCache():addImage("spritesheet/plist_hlssm_font.png")
	-- cc.Director:getInstance():getTextureCache():addImage("game/card.png")
end

---------------------------------------------------------------------------------------
--界面初始化
function TrucoViewLayer:initCsbRes()
	tlog('TrucoViewLayer:initCsbRes')
	local csbNode = cc.CSLoader:createNode("UI/TrucoGameLayer.csb")
	-- local csbNode = g_ExternalFun.loadCSB("UI/GameLayer.csb", self)
	tdump(display.size, "display.size")
	csbNode:setContentSize(display.size)
	ccui.Helper:doLayout(csbNode)
	csbNode:addTo(self)
	self.m_csbNode = csbNode:getChildByName("Panel_1")
	self.m_csbNode:setTouchEnabled(false)
	self.m_viewNetActNode = self.m_csbNode:getChildByName('Node_action')
	self.m_viewNetActNode:setVisible(false)

	self.m_viewNodeAction = cc.Node:create()
	self.m_viewNodeAction:addTo(self)
	self.m_viewNodeAction:setVisible(false)

	--初始化按钮
	self:initBtn()
	--初始化牌和玩家等节点
	self:initPlayerAndCardNode()
	--初始化玩家信息
	self:initSelfInfo()
end

--初始化按钮
function TrucoViewLayer:initBtn()
	tlog('TrucoViewLayer:initBtn')
	local node_top = self.m_csbNode:getChildByName("Node_top")
	self.m_btnList = node_top:getChildByName("Image_set")
	self.m_btnList:setVisible(false)
	local btn_more = node_top:getChildByName("Button_set")
	btn_more:addClickEventListener(function ()
		self.m_btnList:setVisible(not self.m_btnList:isVisible())
	end)

	--说明
    btn = self.m_btnList:getChildByName("Button_1")
	btn:setTag(TAG_ENUM.BT_HELP)
	btn:onClicked(handler(self, self.onButtonClickedEvent))

	--音效
	btn = self.m_btnList:getChildByName("Button_2")
	btn:setTag(TAG_ENUM.BT_SOUND)
	self:flushMusicResShow(btn, GlobalUserItem.bSoundAble)
	btn:onClicked(handler(self, self.onButtonClickedEvent), nil, 0.02)

	--换桌
    btn = self.m_btnList:getChildByName("Button_3")
	btn:setTag(TAG_ENUM.BT_EXCHANGE)
	btn:onClicked(handler(self, self.onButtonClickedEvent))

	--离开
	local btn = self.m_btnList:getChildByName("Button_4")
	btn:setTag(TAG_ENUM.BT_EXIT)
	btn:onClicked(handler(self, self.onButtonClickedEvent))

	local node_bottom = self.m_csbNode:getChildByName("Node_bottom")
	local down_btn = node_bottom:getChildByName("Node_down_btn")
	down_btn:setLocalZOrder(10) --在玩家和牌层之上
	local _trucoBtnNode = TrucoButtonNode:create(down_btn)
	self:addChild(_trucoBtnNode)
	self.m_trucoBtnNode = _trucoBtnNode

	--聊天
	local btn_chat = self.m_csbNode:getChildByName("Button_chat")
	btn_chat:addClickEventListener(function ()
		local chatLayer = TrucoChatLayer:create()
		chatLayer:addTo(self)
	end)
end

function TrucoViewLayer:initPlayerAndCardNode()
	tlog('TrucoViewLayer:initPlayerAndCardNode')
	local node_bottom = self.m_csbNode:getChildByName("Node_bottom")

	--水印节点
	local _waterNode = TrucoWaterMaskNode:create(node_bottom:getChildByName("Node_waterMask"))
	self:addChild(_waterNode)
	self.m_waterMaskNode = _waterNode

	--创建玩家节点预备clone用的panel
    local playerItem = cc.CSLoader:createNode("UI/TrucoPlayerNode.csb")
    playerItem:addTo(self):setVisible(false)
    self.m_playerItem = playerItem:getChildByName("Panel_1"):hide()

    --层级：玩家层<牌层<气泡层
	--玩家层
	local _playerNode = TrucoPlayerLayer:create(self.m_playerItem)
	node_bottom:addChild(_playerNode)
	self.m_trucoPlayerNode = _playerNode

	--牌层
	local _cardNode = TrucoCardLayer:create()
	node_bottom:addChild(_cardNode)
	self.m_trucoCardNode = _cardNode

	--聊天互动表情层
	local chatAnimNode = TrucoChatAnimNode:create(self)
	node_bottom:addChild(chatAnimNode)
	self.m_chatAnimNode = chatAnimNode

	--气泡层
	local _bubbleNode = TrucoBubbleLayer:create()
	node_bottom:addChild(_bubbleNode)
	self.m_trucoBubbleNode = _bubbleNode

	--分数节点
	local _trucoBaseScore = node_bottom:getChildByName("Text_score")
	local _scoreNode = TrucoScoreNode:create(self.m_csbNode:getChildByName("Node_score"), _trucoBaseScore)
	self:addChild(_scoreNode)
	self.m_trucoScoreNode = _scoreNode
end

--音效音乐设置资源
function TrucoViewLayer:flushMusicResShow(_node, _enabled)
	_node:getChildByName('Image_1'):setVisible(_enabled)
	_node:getChildByName('Image_2'):setVisible(not _enabled)
end

--初始化玩家信息
function TrucoViewLayer:initSelfInfo()
	tlog('TrucoViewLayer:initSelfInfo ', self.m_gameEndStatus)

	if self.m_gameEndStatus then
		return
	end
	local myUser = self:getMeUserItem()
	if nil ~= myUser then
		if myUser.wChairID ~= G_NetCmd.INVALID_CHAIR then --非无效座位号
			GameLogic:setSelfChairId(myUser.wChairID)
			GameLogic:setSelfTableId(myUser.wTableID)

			self.m_trucoPlayerNode:setAllPlayerGray()

		    local userList = self:getDataMgr():getUserList()
			tlog('TrucoViewLayer:initSelfInfo--- ', #userList, myUser.wTableID)
			for i, v in ipairs(userList) do
				if v.wTableID == myUser.wTableID and v.cbUserStatus >= G_NetCmd.US_SIT then
					self.m_trucoPlayerNode:showPlayerNode(v)
				end
			end
			self.m_trucoPlayerNode:checkAllPlayerReady()
		else
			tlog("myUser.wChairID is invalid ", myUser.wChairID)
		end
	else
		tlog("TrucoViewLayer:initSelfInfo nil")
	end
end

--有玩家进入or状态改变，查看是否属于同一桌子
function TrucoViewLayer:updateSignelPeople(_userItem)
	if not self.m_gameEndStatus then
		local curTableId = GameLogic:getSelfTableId()
		tlog('TrucoViewLayer:updateSignelPeople is ', _userItem.wChairID, curTableId, _userItem.wTableID)
		if self:isMeChair(_userItem.wChairID) then
			tlog("self chair:updateSignelPeople")
			if GameLogic:getSelfChairId() ~= _userItem.wChairID or curTableId ~= _userItem.wTableID then
				self:initSelfInfo()
				return
			end
		end
		if _userItem.wTableID == curTableId then
			self.m_trucoPlayerNode:showPlayerNode(_userItem)
			self.m_trucoPlayerNode:checkAllPlayerReady()
			if _userItem.cbUserStatus == G_NetCmd.US_SIT then
				--玩家入座时音效
		        g_ExternalFun.playSoundEffect("truco_start_enter.mp3")
			end
		end
	end
end

function TrucoViewLayer:removeSignelPeople(_userItem)
	if not self.m_gameEndStatus then
		self.m_trucoPlayerNode:showGrayPlayerNode(_userItem)
	end
end

function TrucoViewLayer:onButtonClickedEvent(_sender)
	local tag = _sender:getTag()
	tlog('TrucoViewLayer:onButtonClickedEvent ', tag)
	if tag == TAG_ENUM.BT_EXIT then
		self.m_btnList:setVisible(false)
		self:gameExitReq()
	elseif tag == TAG_ENUM.BT_SOUND then --音效
		GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble)
		self:flushMusicResShow(_sender, GlobalUserItem.bSoundAble)
	elseif tag == TAG_ENUM.BT_HELP then
		tlog('TrucoViewLayer:createHelpLayer')
	    local _helpLayer = TrucoHelpLayer:create():addTo(self, 101)
	    _helpLayer:setPosition(display.width * 0.5, display.height * 0.5)
	    -- showToast("not have help content, please wait")
	    self.m_btnList:setVisible(false)
	elseif tag == TAG_ENUM.BT_EXCHANGE then
		self:gameChangeTableReq()
		self.m_btnList:setVisible(false)
	else
		showToast(g_language:getString("game_tip_no_function"))
	end
end

function TrucoViewLayer:onExit()
	tlog('TrucoViewLayer:onExit')
	g_ExternalFun.stopMusic()
	self:releaseListenEvent()
	self:gameDataReset()
	self:stopUpdateCall()
	self:stopRollingCall()
	if self.listener ~= nil then
		self:getEventDispatcher():removeEventListener(self.listener)
	end
end

---------------------------------------------------------------------------------------
--发送消息
--出牌
function TrucoViewLayer:onSendCardReq(_params)
	self._scene:gameDiscardReq(_params.isHide, _params.cardData)
end

--按钮操作
--一局结束亮牌
function TrucoViewLayer:gameShowCardReq(_params)
	self._scene:gameShowCardReq()
end

--发起truco
function TrucoViewLayer:gameStartTrucoReq(_params)
	self._scene:gameStartTrucoReq(_params._type)
end

--应答truco
function TrucoViewLayer:gameAnswerTrucoReq(_params)
	self._scene:gameAnswerTrucoReq(_params._type)
end

--退出请求
function TrucoViewLayer:gameExitReq(_params)
	self._scene:onQueryExitGame()
end

--换桌请求
function TrucoViewLayer:gameChangeTableReq(_params)
	self._scene:SwitchTable()
end

--准备请求
function TrucoViewLayer:gameReadyReq(_params)
	self._scene:Ready()
end

--11分临界选择是否继续
function TrucoViewLayer:chooseContinueReq(_params)
	self._scene:chooseContinueReq(_params._type)
end

--托管/取消托管请求
function TrucoViewLayer:trusteeEnableReq(_params)
	self._scene:trusteeEnableReq(_params._type)
end
--发送消息 end
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
--自己的金币值变化
function TrucoViewLayer:onGetUserScore(item)
	tlog('TrucoViewLayer:onGetUserScore ', item.szNickName, item.lScore, item.wTableID, item.wChairID, item.dwUserID, GlobalUserItem.dwUserID)
	--自己
	if not self.m_gameEndActionTime then
		if item.dwUserID == GlobalUserItem.dwUserID then
	    end
	end
	--刷新金币数量
	local user = self:getDataMgr():getUidUserList()[item.dwUserID]
	local myUser = self:getMeUserItem()
	tlog('TrucoViewLayer:onGetUserScore2--- ', myUser.wTableID, user.wTableID, user.wChairID, user.lScore)
	if myUser.wTableID == user.wTableID then
		self.m_trucoPlayerNode:reFlushGoldNum(user)
	end
end

--初始化面板显示
function TrucoViewLayer:initFreeViewShow(_showTimes)
	GameLogic:setShowCardBtnTimes(_showTimes)
	GameLogic:setIsTrusteeStatus(false)
	GameLogic:setEnableContinueGame(true)
	self.m_trucoBtnNode:setNodeVisible(false)
	self.m_trucoBubbleNode:setBubbleNodeVisible(false)
	self.m_trucoCardNode:resetOriginCardLayer()
	self.m_trucoScoreNode:resetPanelOriginShow()
	self.m_waterMaskNode:setMaskNodeVisible(false)
	self.m_trucoPlayerNode:resetOriginPlayerLayer()
	self:removeChildByName('vsAnimationNode')

	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
end

--游戏空闲时间,此时应清空桌面
function TrucoViewLayer:reEnterFree(_cmdData)
	tlog('TrucoViewLayers:reEnterFree')
	self:initFreeViewShow(_cmdData.showCardBtnTime)
	self.m_trucoScoreNode:reflushTrucoTimes(0, _cmdData.lCellScore)
	self.m_gameEndStatus = false
end

--重连回来游戏正在下注状态
function TrucoViewLayer:reEnterStart(_cmdData)
	tlog('TrucoViewLayer:reEnterStart')
	self:initFreeViewShow(_cmdData.showCardBtnTime)
	GameLogic:storeTrumpCardData(_cmdData.magicCard)
    self.m_trucoCardNode:reenterSetCardLayer(_cmdData, self:getCurTableAllPlayers())
    self.m_trucoPlayerNode:playPeFlyAction(_cmdData.banker, false)
    self.m_trucoScoreNode:reenterResetPanelShow(_cmdData.WinRoundCount[1], _cmdData.MaxRoundCount, _cmdData.Score[1], _cmdData.curScore)
	self.m_trucoScoreNode:reflushTrucoTimes(_cmdData.trucoTimes, _cmdData.lCellScore)
	self.m_gameEndStatus = false
	local data = {}
	data.chairID = GameLogic:getSelfChairId()
	data.trustee = _cmdData.UserTrustee
	self:onShowTrusteeStatus(data)
end

--重连回来游戏正在结算状态
function TrucoViewLayer:reEnterEnd()
end

--收到系统消息，消息队列
--入列
function TrucoViewLayer:pushNetQueue(_netData)
    if not _netData then
        return
    end
    self.m_netQueueArray[#self.m_netQueueArray + 1] = _netData
    self:netQueuePopEvent()
end

--出列
function TrucoViewLayer:popNetQueue()
    if #self.m_netQueueArray > 0 then
        return table.remove(self.m_netQueueArray, 1)
    else
    	return nil
    end
end

--清除队列
function TrucoViewLayer:clearNetQueue()
	self.m_netQueueArray = nil
    self.m_netQueueArray = {}
    self.m_isAnimationPlay = false
    self.m_viewNetActNode:stopAllActions()
    self.m_viewNodeAction:stopAllActions()
end

--动画完毕后取吓一条消息
function TrucoViewLayer:delayReadNextMsg(_params)
	local _delayTime = 0
	if _params then
		_delayTime = _params.time or 0
	end
	tlog('TrucoViewLayer:delayReadNextMsg ', _delayTime)
	if _delayTime <= 0 then
		self.m_isAnimationPlay = false		
		self:netQueuePopEvent()
	else
		self.m_viewNetActNode:runAction(cc.Sequence:create(cc.DelayTime:create(_delayTime), cc.CallFunc:create(function ()
			self.m_isAnimationPlay = false
			self:netQueuePopEvent()
		end)))
	end
end

-- 游戏消息
function TrucoViewLayer:netQueuePopEvent()
	if self.m_isAnimationPlay then
		tlog("------self.m_isAnimationPlay true------")
		return
	end
	
	local netData = self:popNetQueue()
	if not netData then
	    tlog('---TrucoViewLayer:netQueuePopEvent not netData---')
		return
	end
	--temp
	-- self:onSendCardEvent()
	-- if true then
	-- 	return
	-- end

	local subId = netData.subId
	local netData = netData.netData
    tlog('TrucoViewLayer:netQueuePopEvent ', subId)
    local cmd_command = g_var(cmd)
	if subId == cmd_command.SUB_S_GAME_START then 
		self:onSubGameStart(netData)
	elseif subId == cmd_command.SUB_S_GAME_END then 
		self:onSubGameEnd(netData)
    elseif subId == cmd_command.SUB_S_GAME_DEAL then
        self:onSendCardEvent(netData)
    elseif subId == cmd_command.SUB_S_GAME_OP_FAILD then
    	tlog("cmd_command.SUB_S_GAME_OP_FAILD")
    elseif subId == cmd_command.SUB_S_GAME_UPDATE_ACTION then
        self:onFlushActionBtnEvent(netData)
    elseif subId == cmd_command.SUB_S_CMD_TRUCO then
        self:onTrucoEvent(netData)
    elseif subId == cmd_command.SUB_S_CMD_ANSWERTRUCO then
        self:onAnswerTrucoEvent(netData)
    elseif subId == cmd_command.SUB_S_CMD_SHOW_CARD then
        self:onShowCardEvent(netData)
    elseif subId == cmd_command.SUB_S_CMD_DISCARD then
        self:onOutCardEvent(netData)
    elseif subId == cmd_command.SUB_S_GAME_TURN_END then
        self:onShowTurnResultEvent(netData)
    elseif subId == cmd_command.SUB_S_CMD_CONTINUE_GAME then
        self:onContinueResultEvent(netData)
    elseif subId == cmd_command.SUB_S_SHOW_FRIEND_CARD then
        self:onShowFriendCardEvent(netData)
    elseif subId == cmd_command.SUB_S_GAME_CALLTRUCO_STATUS then
        self:onShowEnterTrucoStatus(netData)
    elseif subId == cmd_command.SUB_S_USERTRUSTEE then
        self:onShowTrusteeStatus(netData)
	else
		print("unknow gamemessage sub is ==> ", subId)
	end
	self:netQueuePopEvent()
end

--游戏开始
function TrucoViewLayer:onSubGameStart()
	tlog('TrucoViewLayer:onGameStart')
end

--游戏结束
function TrucoViewLayer:onSubGameEnd(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onSubGameEnd", 10)
	self.m_gameEndStatus = true
	-- self.m_isAnimationPlay = true
    local totalPlayerArr = clone(self:getCurTableAllPlayers())
    local winArray = _cmdData.lPlayAllScore[1]

    local winChairId = 0
    for i, player in ipairs(totalPlayerArr) do
    	if winArray[player.wChairID + 1] > 0 then
    		self.m_trucoPlayerNode:playFinialWinEffect(player.wChairID)
    		winChairId = player.wChairID
    	end
    end

    local resultScore = self.m_trucoScoreNode:getResultScoreValue()
    --金币飞完之后头像闪光动画
    local playerEffectCall = function (_winChairId)
    	self.m_trucoPlayerNode:showTurnWinEffectByChairId(_winChairId)
    end
    --飘数字动画
    local playerEndCall = function (_winArray, _winChairId, _resultShowCall, _playerArray)
    	self.m_trucoPlayerNode:playWinNumEffect(_winArray, _winChairId, _resultShowCall, _playerArray)
    end
    if not self.m_trucoResultNode then
    	local resultNode = TrucoResultNode:create(self.m_playerItem)
	    resultNode:setPosition(display.width * 0.5, display.height * 0.5)
		self:addChild(resultNode, 100)
		self.m_trucoResultNode = resultNode
	end
	self.m_trucoResultNode:setSelfVisible(true)
	self.m_trucoResultNode:initView(_cmdData, totalPlayerArr, winChairId, resultScore, playerEffectCall, playerEndCall)
	self.m_trucoBtnNode:setNodeVisible(false)
	self.m_trucoBubbleNode:setBubbleNodeVisible(false)
end

--获取当前桌子的所有玩家
function TrucoViewLayer:getCurTableAllPlayers()
	local curTableId = GameLogic:getSelfTableId()
    local userList = self:getDataMgr():getUserList()
    local totalPlayerArr = {}
	for i, v in ipairs(userList) do
		if v.wTableID == curTableId and v.cbUserStatus >= G_NetCmd.US_SIT then
			table.insert(totalPlayerArr, v)
		end
	end
	return totalPlayerArr
end

--发牌
function TrucoViewLayer:onSendCardEvent(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onSendCardEvent", 10)
	self.m_gameEndStatus = false
	self.m_isAnimationPlay = true
	-- _cmdData = {
	--     IsCanCall      = 0,
	--     banker         = 0,
	--     currentChairID = 1,
	--     dealCount      = 7,
	--     isNext         = 0,
	--     magicCard      = 11,
	--     playerCount    = 4,
	--     pokers = {
	--         {1, 2, 3},
	--     },
	--     restCardsCount = 0
	-- }

	GameLogic:storeTrumpCardData(_cmdData.magicCard)
	local dealCardCallBack = function () --发牌动画
		self.m_trucoCardNode:startGameCardAction(_cmdData.magicCard, _cmdData.pokers[1], _cmdData.banker)
	end
	if _cmdData.isNext == 0 then --首局开始，播放vs
		local playerNodeFlyCall = function (_posArr)
			self.m_trucoPlayerNode:playPeFlyAction(_cmdData.banker, true, true)
			self.m_trucoPlayerNode:playAfterVsAction(_posArr, dealCardCallBack)
		end
		local startVsActCall = function ()
			self.m_trucoPlayerNode:setPlayerNodeVisible(false)

		    local totalPlayerArr = clone(self:getCurTableAllPlayers())
			local vsAnimationNode = TrucoStartAniNode:create(totalPlayerArr, self.m_playerItem, playerNodeFlyCall)
		    vsAnimationNode:setPosition(display.width * 0.5, display.height * 0.5)
		    vsAnimationNode:setName('vsAnimationNode')
			self:addChild(vsAnimationNode, 100)
		end
		self.m_viewNodeAction:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function ()
			startVsActCall()
		end)))
		self.m_trucoScoreNode:resetPanelOriginShow()
		self.m_trucoCardNode:sendCardRecoveryLastCard()
		if self.m_trucoResultNode then
			self.m_trucoResultNode:setSelfVisible(false)
		end
	else
		self.m_trucoPlayerNode:playPeFlyAction(_cmdData.banker, true, false)
		self.m_trucoCardNode:sendCardRecoveryLastCard(dealCardCallBack)
	end
	self.m_trucoScoreNode:reflushCurPoint(1, false, true)
	self.m_trucoScoreNode:hideTurnWinPoint()
	self.m_trucoBtnNode:setNodeVisible(false) --亮牌后发牌会触发
	self.m_trucoBubbleNode:setBubbleNodeVisible(false) --truco认输，牌局结束会触发
end

--底部按钮操作消息
function TrucoViewLayer:onFlushActionBtnEvent(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onFlushActionBtnEvent", 10)
	local _chairId = _cmdData.chairID
	--只要不是应答truco和11分的临界消息，就要延迟取下一个消息
	local isTrucoAnswer = _cmdData.CanAumentar
	if _cmdData.CanWaitContinue or 
		(not _cmdData.CanTruco and not _cmdData.CanAumentar and not _cmdData.CanShowCard and not _cmdData.CanOutCard) then
		isTrucoAnswer = true  --12分的truco应答
	end
	self.m_isAnimationPlay = (not isTrucoAnswer) and (not _cmdData.CanShowCard) --亮牌也不延迟
	if self.m_isAnimationPlay then
		tlog("isTrucoAnswer--- ", isTrucoAnswer, self.m_isAnimationPlay)
		--让机器人有个操作的时间感(进度条)
		G_event:NotifyEventTwo(GameLogic.TRUCO_DEAL_NET_QUEUE, {time = 1})
	end

	local isSelf = GameLogic:getPositionByChairId(_chairId) == 0
	if not _cmdData.CanShowCard then --亮牌不需要倒计时
		self.m_trucoPlayerNode:startPlayerProgress(_chairId, _cmdData.cbAllTime, _cmdData.seconds, _cmdData.CanOutCard)
		if isSelf then
			--轮到玩家自己操作时的提示操作音效
	        g_ExternalFun.playSoundEffect("truco_self_operation.mp3")
		end
	else
		if isSelf then
			self.m_trucoCardNode:setSelfCardEnableShowFlip(false)
		end
	end
	if isSelf then --是自己
		self.m_trucoCardNode:setSelfCardTouchEnabled(_cmdData.CanOutCard)
		self.m_trucoCardNode:setSelfCardShowGray((not _cmdData.CanOutCard) and (not _cmdData.CanWaitContinue))
		self.m_trucoBtnNode:resetButtonShow(_cmdData)
		if isTrucoAnswer then
			self.m_trucoCardNode:setSelfCardEnableShowFlip(false)
		else
			if not _cmdData.CanShowCard then
				self.m_trucoCardNode:setSelfCardEnableShowFlip()
			end
		end
	else
		if isTrucoAnswer and GameLogic:getIsSameTeamWithMe(_cmdData.chairID) then
		else
			self.m_trucoBtnNode:setNodeVisible(false)
		end
		self.m_trucoCardNode:setSelfCardTouchEnabled(false)
	end
	if _cmdData.CanOutCard then
		--可以出牌，要把truco应答的那些bubble隐藏
		self.m_trucoBubbleNode:setBubbleNodeVisible(false)
	end
end

--truco消息
function TrucoViewLayer:onTrucoEvent(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onTrucoEvent", 10)
	self.m_isAnimationPlay = true
	if _cmdData.TrucoScore == 1 then
		self.m_trucoBubbleNode:showBubbleTrucoTips(_cmdData.chairID, _cmdData.CurrentTrucoScore or 3)
		--玩家发起truco时的音效
        g_ExternalFun.playSoundEffect(string.format("truco_action_truco_%d.mp3", math.random(4)))
	else
		--认输
		self.m_trucoBubbleNode:showBubbleGiveUpTips(_cmdData.chairID)
		self.m_trucoCardNode:setSelfCardEnableShowFlip(false)
        self:playAcceptGvieupEffect(2)
	end
	--自己隐藏按钮
	if GameLogic:getPositionByChairId(_cmdData.chairID) == 0 then
		self.m_trucoBtnNode:setNodeVisible(false)
	end
	self.m_trucoPlayerNode:stopSinglePlayerProgress(_cmdData.chairID)
	--动画时间
	G_event:NotifyEventTwo(GameLogic.TRUCO_DEAL_NET_QUEUE, {time = 1})
end

--truco应答消息
function TrucoViewLayer:onAnswerTrucoEvent(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onAnswerTrucoEvent", 10)
	if GameLogic:getIsSameTeamWithMe(_cmdData.chairID) then
		tlog("my team answer truco ", _cmdData.chairID)
		self.m_trucoBtnNode:showTrucoAnswerOrContinueTips(_cmdData.TrucoScore, _cmdData.chairID)
	else
		tlog("other team answer truco")
	end
	if _cmdData.IsAnswerTrucoFinish == 1 then --两个个人都应答完
		self.m_isAnimationPlay = true
		--两个人都完成了应答
		if GameLogic:getIsSameTeamWithMe(_cmdData.chairID) then
			-- self.m_trucoBtnNode:setTrucoBtnEnabled(false)
			self.m_trucoCardNode:setSelfCardEnableShowFlip()
		end
		self.m_trucoBubbleNode:showBubbleAnswerTrucoTips(_cmdData)
		self.m_trucoScoreNode:reflushCurPoint(_cmdData.CurrentScore, false)
		--给气泡一个展示的时间
		G_event:NotifyEventTwo(GameLogic.TRUCO_DEAL_NET_QUEUE, {time = 1.5})
		--停止两个应答玩家的计时器
		self.m_trucoPlayerNode:stopSinglePlayerProgress(_cmdData.chairID)
		self.m_trucoPlayerNode:stopSinglePlayerProgress(GameLogic:getOtherPlayerChairId(_cmdData.chairID, 2))
		self.m_trucoScoreNode:reflushTrucoTimes(_cmdData.trucoTimes)
		local trucoScore = math.max(_cmdData.TrucoScore, _cmdData.TeamTrucoScore)
		if trucoScore == 3 then --加注，对方显示 ...
			self.m_trucoBubbleNode:otherSideWaitTip(_cmdData.chairID)
			--被truco时：玩家加注
	        g_ExternalFun.playSoundEffect(string.format("truco_action_truco_%d.mp3", math.random(4)))
	    elseif trucoScore == 2 then
	        self:playAcceptGvieupEffect(1)
	    elseif trucoScore == 1 then
	        self:playAcceptGvieupEffect(2)
		end
		self.m_trucoCardNode:setSelfCardShowGray(false)
	end
end

--亮牌
function TrucoViewLayer:onShowCardEvent(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onShowCardEvent", 10)
	-- self.m_isAnimationPlay = true
	self.m_trucoCardNode:showCardWhenTurnOver(_cmdData)
	if GameLogic:getPositionByChairId(_cmdData.chairID) == 0 then
		self.m_trucoBtnNode:setNodeVisible(false)
	end
	-- 亮牌展示时间
	-- G_event:NotifyEventTwo(GameLogic.TRUCO_DEAL_NET_QUEUE, {time = 1.5})
end

--出牌
function TrucoViewLayer:onOutCardEvent(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onOutCardEvent", 10)
	--给牌飞的时间
	self.m_isAnimationPlay = true
	self.m_trucoCardNode:playCardWithChairId(_cmdData.chairID, _cmdData.card, _cmdData.isHide)
	self.m_trucoCardNode:setSelfCardTouchEnabled(false)
	self.m_trucoBubbleNode:setBubbleNodeVisible(false)
	self.m_trucoBtnNode:setNodeVisible(false)
	self.m_trucoPlayerNode:stopSinglePlayerProgress(_cmdData.chairID)
	if GameLogic:getPositionByChairId(_cmdData.chairID) == 0 then
		self.m_trucoCardNode:setSelfCardEnableShowFlip()
	end
end

--一轮结束,展示最大的牌
-- 如果_cmdData.bBigCard == 0,表示认输后结束，非0表示4张牌出完比牌结束
function TrucoViewLayer:onShowTurnResultEvent(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onShowTurnResultEvent", 10)
	if _cmdData.IsCurRoundOver == 1 then
		--在前处理，turnEndSetPointShow会重设分数显示
		self.m_trucoPlayerNode:showTurnWinEffect(self.m_trucoScoreNode:getCurRoundWinResult(_cmdData))
		self.m_waterMaskNode:setMaskNodeVisible(false)
	end
    if _cmdData.bBigCard ~= 0 then
		self.m_isAnimationPlay = true
		local scoreCall = function (_scrPos, cmdData, _index)
			self.m_trucoScoreNode:pointFlyActionWhenTurnEnd(_scrPos, cmdData, _index)
		end
		self.m_trucoCardNode:showMaxValueCard(_cmdData, scoreCall)
	else
		self.m_trucoScoreNode:turnEndSetPointShow(_cmdData)
	end
end

--11分临界情况是否继续
function TrucoViewLayer:onContinueResultEvent(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onContinueResultEvent", 10)
	if _cmdData.isFinish == 0 then --只有一个人应答完
		if GameLogic:getIsSameTeamWithMe(_cmdData.chairID) then
			self.m_trucoBtnNode:showTrucoAnswerOrContinueTips(_cmdData.ContinueGameStatus, _cmdData.chairID)
		else
			tlog("onContinueResultEvent other team")
		end
	else
		self.m_isAnimationPlay = true
		--给气泡一个展示的时间
		G_event:NotifyEventTwo(GameLogic.TRUCO_DEAL_NET_QUEUE, {time = 1})
		--两个人都完成了选择
		if GameLogic:getIsSameTeamWithMe(_cmdData.chairID) then
			self.m_trucoBtnNode:setNodeVisible(false)
		end
		self.m_trucoBubbleNode:showBubbleContinueTips(_cmdData)
		--停止两个应答玩家的计时器
		self.m_trucoPlayerNode:stopSinglePlayerProgress(_cmdData.chairID)
		self.m_trucoPlayerNode:stopSinglePlayerProgress(GameLogic:getOtherPlayerChairId(_cmdData.chairID, 2))
		local continueIndex = math.max(_cmdData.ContinueGameStatus, _cmdData.FriendContinueGameStatus)
		if continueIndex == 2 then
	        self:playAcceptGvieupEffect(1)
	    elseif continueIndex == 1 then
	        self:playAcceptGvieupEffect(2)
		end
		self.m_trucoCardNode:reshowCardAfterEleven(_cmdData.chairID)
	end
end

--播放接受/认输音效
--_type 1接受 2认输
function TrucoViewLayer:playAcceptGvieupEffect(_type)
	local random = math.random(2)
	local musicStr = ""
	if _type == 1 then
		musicStr = string.format("truco_action_accept_%d.mp3", random)
	elseif _type == 2 then
		musicStr = string.format("truco_action_giveup_%d.mp3", random)
	end
    g_ExternalFun.playSoundEffect(musicStr)
end

--11分临界情况 展示队友手牌
function TrucoViewLayer:onShowFriendCardEvent(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onShowFriendCardEvent", 10)
	self.m_trucoCardNode:showFriendCardWhenScoreEleven(_cmdData)
end

--重连的时候已做的更新动作,在action消息之后
function TrucoViewLayer:onShowEnterTrucoStatus(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onShowEnterTrucoStatus", 10)
    --按钮展示回调
    local btnShowCall = function (_index, _chairId)
    	self.m_trucoBtnNode:showTrucoAnswerOrContinueTips(_index, _chairId)
    end
	self.m_trucoBubbleNode:showEnterBubbleTips(_cmdData, btnShowCall)
end

--托管消息广播
function TrucoViewLayer:onShowTrusteeStatus(_cmdData)
    tdump(_cmdData, "TrucoViewLayer:onShowTrusteeStatus", 10)
    --只处理自己的
    if GameLogic:getPositionByChairId(_cmdData.chairID) == 0 then
    	if _cmdData.trustee == 1 then
		    if not self.m_trucoTrusteeNode then
				local node_bottom = self.m_csbNode:getChildByName("Node_bottom")
				local _trusteeNode = TrucoTrusteeNode:create()
				node_bottom:addChild(_trusteeNode, 20) --在button层之上
				self.m_trucoTrusteeNode = _trusteeNode
			end
			self.m_trucoTrusteeNode:setTrusteeNodeVisible(true)
		else
			if self.m_trucoTrusteeNode then
				self.m_trucoTrusteeNode:setTrusteeNodeVisible(false)
			end
		end
	end
end

---------------------------------------------------------------------------------------
function TrucoViewLayer:getParentNode()
	return self._scene
end

function TrucoViewLayer:getMeUserItem()
	if nil ~= GlobalUserItem.dwUserID then
		return self:getDataMgr():getUidUserList()[GlobalUserItem.dwUserID]
	end
	return nil
end

function TrucoViewLayer:isMeChair( wchair )
	local useritem = self:getDataMgr():getChairUserList()[wchair + 1]
	tlog('TrucoViewLayer:isMeChair is ', useritem)
	if nil == useritem then
		return false
	else
		tlog("useritem.dwUserID ", useritem.dwUserID, GlobalUserItem.dwUserID)
		return useritem.dwUserID == GlobalUserItem.dwUserID
	end
end

function TrucoViewLayer:getDataMgr()
	return self:getParentNode():getDataMgr()
end

function TrucoViewLayer:logData(msg)
	local p = self:getParentNode()
	if nil ~= p.logData then
		p:logData(msg)
	end	
end

function TrucoViewLayer:gameDataReset()
	tlog('TrucoViewLayer:gameDataReset')
	--资源释放
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	self:getDataMgr():removeAllUser()
end

function TrucoViewLayer:updateClock(tag, left)
	tlog('TrucoViewLayer:updateClock ', tag, left)
	local str = string.format("%02d", left)
    if tag == g_var(cmd).kGAMEPLAY_COUNTDOWN then --下注倒计时
        if left == 4 then
			-- g_ExternalFun.playSoundEffect("TIME_WARIMG.mp3")
        end
	end
end

--显示当前状态的倒计时提示文本
function TrucoViewLayer:showTimerTip(tag, time, _isReenter)
	tlog('TrucoViewLayer:showTimerTip ', tag, time, _isReenter)
	tag = tag or -1
	if tag == g_var(cmd).kGAMEPLAY_COUNTDOWN then --下注状态
		if not _isReenter then

		else

		end
		self:stopUpdateCall() --做个保险，停掉画线定时器
	else
		self:stopRollingCall()
		if time <= 2 then
			self.m_gameEndActionTime = false
		else
			self.m_gameEndActionTime = true
		end
	end
end

--游戏结束曲线刷新定时器
function TrucoViewLayer:stopActionCall()
	if self._rollActionId ~= nil then
		g_scheduler:unscheduleScriptEntry(self._rollActionId)
		self._rollActionId = nil
	end
end

--游戏下注状态倒计时定时器
function TrucoViewLayer:stopRollingCall()
	if self.m_rollTimerId ~= nil then
		g_scheduler:unscheduleScriptEntry(self.m_rollTimerId)
		self.m_rollTimerId = nil
	end
end

function TrucoViewLayer:stopUpdateCall()
	tlog('TrucoViewLayer:stopUpdateCall')
	self:stopActionCall()
end

function TrucoViewLayer:isLuaNodeValid(node)
    return(node and not tolua.isnull(node))
end

function TrucoViewLayer:registerTouch()
	tlog('TrucoViewLayer:registerTouch')
	local function onTouchBegan( touch, event )
		return true
	end

	local function onTouchEnded( touch, event )
		tlog('TrucoViewLayer:onTouchEnded')
		if self.m_btnList:isVisible() then
			local pos = self.m_btnList:convertToNodeSpace(touch:getLocation())
			tlog('pos is ', pos.x, pos.y)
	        local rec = cc.rect(0, 0, self.m_btnList:getContentSize().width, self.m_btnList:getContentSize().height)
	        tdump(rec, "rec")
	        if not cc.rectContainsPoint(rec, pos) then
	            self.m_btnList:setVisible(false)
	        end
	    end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	self.listener = listener
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function TrucoViewLayer:closeResultLayerFlush()
	tlog('TrucoViewLayer:closeResultLayerFlush')
	--先回收牌
	self.m_gameEndStatus = false
	self.m_trucoCardNode:sendCardRecoveryLastCard()
	self.m_trucoScoreNode:resetPanelOriginShow()
	self.m_trucoBubbleNode:setBubbleNodeVisible(false)
	if self.m_trucoTrusteeNode then
		self.m_trucoTrusteeNode:setTrusteeNodeVisible(false)
	end
	self:initSelfInfo()
end

--打开互动表情界面
function TrucoViewLayer:openHuDongLayer(_playerInfo)
	tlog('TrucoViewLayer:openHuDongLayer')
	local TrucoHuDongLayer = appdf.req(module_pre .. ".views.layer.TrucoHuDongLayer")
	local hudongLayer = TrucoHuDongLayer:create(_playerInfo)
	hudongLayer:addTo(self)
end

function TrucoViewLayer:registerListenEvent()
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_DEAL_NET_QUEUE, handler(self,self.delayReadNextMsg))
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_SEND_CARD, handler(self,self.onSendCardReq))
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_SHOW_CARD, handler(self,self.gameShowCardReq))
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_START_TRUCO, handler(self,self.gameStartTrucoReq))
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_ANSWER_TRUCO, handler(self,self.gameAnswerTrucoReq))
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_EXIT_REQ, handler(self,self.gameExitReq))
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_CHANGETABLE_REQ, handler(self,self.gameChangeTableReq))
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_READY_REQ, handler(self,self.gameReadyReq))
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_FLUSH_PLAYER, handler(self,self.closeResultLayerFlush))
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_CONTINUE_CHOOSE, handler(self,self.chooseContinueReq))
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_TRUSTEE_EVENT, handler(self,self.trusteeEnableReq))
    -- G_event:NotifyEventTwo(GameLogic.TRUCO_DEAL_NET_QUEUE, {time = 0})
    G_event:AddNotifyEvent(G_eventDef.UI_OPEN_HUDONG_LAYER, handler(self,self.openHuDongLayer))
end

function TrucoViewLayer:releaseListenEvent()
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_DEAL_NET_QUEUE)
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_SEND_CARD)
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_SHOW_CARD)
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_START_TRUCO)
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_ANSWER_TRUCO)
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_EXIT_REQ)
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_CHANGETABLE_REQ)
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_READY_REQ)
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_FLUSH_PLAYER)
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_CONTINUE_CHOOSE)
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_TRUSTEE_EVENT)
    G_event:RemoveNotifyEvent(G_eventDef.UI_OPEN_HUDONG_LAYER)
end

return TrucoViewLayer