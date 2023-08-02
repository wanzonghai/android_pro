local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
local module_pre = "game.yule.double.src"
local g_var = g_ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"
local GamePlayerBetView = appdf.req(module_pre .. ".views.layer.GamePlayerBetView")
local GameHelpLayer = appdf.req(module_pre .. ".views.layer.GameHelpLayer")
local GameResultShowNode = appdf.req(module_pre .. ".views.layer.GameResultShowNode")
local DoubleItemNode = appdf.req(module_pre .. ".views.layer.DoubleItemNode")
local DoublePlayerLayer = appdf.req(module_pre .. ".views.layer.DoublePlayerLayer")
local DoubleGoldLayer = appdf.req(module_pre .. ".views.layer.DoubleGoldLayer")
local DoubleEndTipNode = appdf.req(module_pre .. ".views.layer.DoubleEndTipNode")
local sortArray = {13, 3, 12, 4, 0, 11, 5, 10, 6, 9, 7, 8, 1, 14, 2} --滚动区域小球的排列顺序
local g_scheduler = cc.Director:getInstance():getScheduler()
local Item_Width = 120 --一个滚动的格子占据的宽度
local Panel_Height = 120 --容器的高度
local enumTable = 
{
	"BT_GREEN", 	--这三个要在最开始
	"BT_RED",
	"BT_PURPLE",
	"BT_EXIT",
	"BT_SOUND",			--音效
	-- "BT_VOICE",			--音乐
	"BT_HELP",
	"BT_HISTORY",
	"BT_TOTAL_GREEN",
	"BT_TOTAL_RED",
	"BT_TOTAL_PURPLE",
	"BT_AUTOBET",
}
local first_tag = 100
local TAG_ENUM = g_ExternalFun.declarEnumWithTable(first_tag, enumTable)
local DEFAULT_BET = 1
local Total_History_Node = 12

function GameViewLayer:ctor(scene)
	tlog('GameViewLayer:ctor')
	--注册node事件
	g_ExternalFun.registerNodeEvent(self)
	
	self._scene = scene
	self:gameDataInit()

	--初始化csb界面
	self:initCsbRes()
	self:dealWithScrollItem()
	self:registerTouch()

	g_ExternalFun.playMusic("sound_res/bgm_double.mp3", true)
end

function GameViewLayer:gameDataInit()
	tlog('GameViewLayer:gameDataInit')
    --无背景音乐
    g_ExternalFun.stopMusic()
    --用户列表
	self:getDataMgr():initUserList(self:getParentNode():getUserList())
    --加载资源
	self:loadRes()
	self:initRollData()
	self.m_totalBetTime = 0 			--下注状态总时间
    self.m_endIndex = -1 				--开奖的结果号码
	self.m_tableJettonBtn = {} 			--四个筹码下注按钮
	self.m_scoreUser = 0 				--玩家金币数
	self.over_vip                       = 1         --限额阈值
    self.m_OverThreshold                = false     --玩家数高于阈值
	self.m_curWinLoseMoney = 0 			--当前局在当前开奖号码区域的输赢
	self.m_isInGameEndStatus = false	--是否结算状态
	self.m_gameEndActionTime = false 	--是否结算动画时间内,当前时间内不更新金币显示
	self.m_selfBetIconArr = {} 			--自己下注区域图标
	self.m_selfBetLabelArr = {} 		--自己下注区域文本
	self.m_totalBetIconArr = {} 		--总下注区域图标，人数图标
	self.m_totalBetLabelArr = {} 		--总下注区域文本
	self.m_totalPlayerLabelArr = {}		--总下注区域下注玩家文本
	self.m_cbGameStatus = -1			--当前游戏状态
	self.m_curRoundIsSelfBet = false 	--当前轮自己是否下注了
	self.m_delayUserBetArray = {}		--玩家下注消息队列
	self.m_isBetMessagePlay = false		--当前是否有下注消息读取出来
end

function GameViewLayer:loadRes()
	tlog('GameViewLayer:loadRes')
	--加载卡牌纹理
	-- cc.Director:getInstance():getTextureCache():addImage("spritesheet/plist_hlssm_font.png")
	-- cc.Director:getInstance():getTextureCache():addImage("game/card.png")
end

---------------------------------------------------------------------------------------
--界面初始化
function GameViewLayer:initCsbRes()
	display.loadSpriteFrames('GUI/double_bet_icon.plist', 'GUI/double_bet_icon.png')

	tlog('GameViewLayer:initCsbRes')
	local csbNode = cc.CSLoader:createNode("UI/GameLayer.csb")
	csbNode:addTo(self)
	-- local csbNode = g_ExternalFun.loadCSB("UI/GameLayer.csb", self)
	csbNode:setContentSize(display.size)
	ccui.Helper:doLayout(csbNode)
	self.m_csbNode = csbNode:getChildByName("Panel_top")
	self.m_csbNode:setTouchEnabled(false)
	self.m_totalPeopleIcon = self.m_csbNode:getChildByName("Node_top"):getChildByName("Image_people")
	self.m_totalPeopleIcon.originPos = cc.p(self.m_totalPeopleIcon:getPosition())

	--初始化按钮
	self:initBtn()
	--初始化玩家信息
	self:initUserInfo()
	--初始化桌面下注
	self:initJetton()

	local _playerNode = DoublePlayerLayer:create(self.m_csbNode:getChildByName("PlayerNode"))
	self:addChild(_playerNode)
	self.m_doublePlayerNode = _playerNode
	local _goldNode = DoubleGoldLayer:create(self.m_csbNode:getChildByName("ScoreNode"))
	self:addChild(_goldNode)
	self.m_doubleGoldNode = _goldNode
	local _endTipNode = DoubleEndTipNode:create(self.m_csbNode:getChildByName("EndTipNode"))
	self:addChild(_endTipNode)
	self.m_doubleTipNode = _endTipNode

	self.m_autoBetActNode = cc.Node:create()
	self.m_autoBetActNode:addTo(self)
	self.m_betNetActNode = cc.Node:create()
	self.m_betNetActNode:addTo(self)
end

--初始化按钮
function GameViewLayer:initBtn()
	tlog('GameViewLayer:initBtn')
	self.m_btnList = self.m_csbNode:getChildByName("sp_btn_list")
	self.m_btnList:setVisible(false)
	local btn_more = self.m_csbNode:getChildByName("Button_more")
	btn_more:addClickEventListener(function ()
		self.m_btnList:setVisible(not self.m_btnList:isVisible())
	end)

	--音效
	local btn = self.m_btnList:getChildByName("voice_btn")
	btn:setTag(TAG_ENUM.BT_SOUND)
	self:flushMusicResShow(btn, GlobalUserItem.bSoundAble)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent), nil, 0.02)
	-- --音乐
	-- btn = self.m_btnList:getChildByName("music_btn")
	-- btn:setTag(TAG_ENUM.BT_VOICE)
	-- self:flushMusicResShow(btn, GlobalUserItem.bVoiceAble)
	-- self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent), nil, 0.02)

	--离开
	btn = self.m_btnList:getChildByName("back_btn")
	btn:setTag(TAG_ENUM.BT_EXIT)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))

	--说明
    btn = self.m_btnList:getChildByName("rule_btn")
	btn:setTag(TAG_ENUM.BT_HELP)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))

	--历史记录
	local historyNode = self.m_csbNode:getChildByName("FileNode_lishijilu")
	historyNode:getChildByName("Panel_1"):setTouchEnabled(false)
	local historyBtn = historyNode:getChildByName("Button_1")
	historyBtn:setTag(TAG_ENUM.BT_HISTORY)
	self:registerBtnEvent(historyBtn, handler(self, self.onButtonClickedEvent))

	local node_center = self.m_csbNode:getChildByName("Node_center")
	self.m_betAreaBtnArray = {}
	for i = 1, 3 do
		--中间下注按钮
		local betAreaBtn = node_center:getChildByName(string.format("Button_%d", i))
		betAreaBtn:getChildByName("Image_bg"):setVisible(false)
		betAreaBtn:setTag(first_tag + i - 1) --对应TAG_ENUM.BT_GREEN/RED/PURPLE
		betAreaBtn:addTouchEventListener(handler(self, self.onBetButtonClick))
		table.insert(self.m_betAreaBtnArray, betAreaBtn)
		--总下注按钮
		local totalbetBtn = node_center:getChildByName(string.format("Button_bet_%d", i))
		totalbetBtn:setTag(first_tag + i + 6) --对应TAG_ENUM.BT_TOTAL_GREEN/RED/PURPLE
		self:registerBtnEvent(totalbetBtn, handler(self, self.onButtonClickedEvent))
	end
end

--音效音乐设置资源
function GameViewLayer:flushMusicResShow(_node, _enabled)
	_node:getChildByName('Image_1'):setVisible(_enabled)
	_node:getChildByName('Image_2'):setVisible(not _enabled)
end

--初始化玩家信息
function GameViewLayer:initUserInfo()
	tlog('GameViewLayer:initUserInfo')
	--玩家游戏币
	local node_bottom = self.m_csbNode:getChildByName("Node_bottom")
	self.m_textUserCoint = node_bottom:getChildByName("Image_19"):getChildByName("coin_text")
	self.m_textUserCoint._lastNum = 0
	self.m_textUserCoint._curNum = 0
	self:reSetUserInfo()
	self:updateTotalPeople()
end

function GameViewLayer:reSetUserInfo(_reduceNum)
	tlog('GameViewLayer:reSetUserInfo ', _reduceNum)
	if _reduceNum == nil then
		_reduceNum = 0
	end
	self.m_scoreUser = 0
	local myUser = self:getMeUserItem()
	if nil ~= myUser then
		self.m_scoreUser = myUser.lScore
	end
	print("自己游戏币: " .. self.m_scoreUser)
	self:updateUserScore(_reduceNum)
end

--下注及恢复场景的时候需要手动减去自己已下注的游戏币
function GameViewLayer:updateUserScore(_reduceNum)
	self.m_scoreUser = self.m_scoreUser - _reduceNum
	tlog('GameViewLayer:updateUserScore ', self.m_scoreUser, _reduceNum)
	self.m_textUserCoint._lastNum = self.m_textUserCoint._curNum
	self.m_textUserCoint._curNum = self.m_scoreUser
	self.m_textUserCoint:stopAllActions()
	self:formatNumShow(self.m_textUserCoint, self.m_scoreUser)
	local length = self.m_textUserCoint:getContentSize().width
	local scale = math.min(375 / length, 1)
	self.m_textUserCoint:setScale(scale * 1.45) --默认放大1.45倍
	if _reduceNum ~= 0 then
		self:updateGoldShow(self.m_textUserCoint)
	end
end

--初始化桌面下注
function GameViewLayer:initJetton()
	tlog('GameViewLayer:initJetton')
	self:initJettonBtnInfo()
	self:initCurJettonNumInfo()
end

function GameViewLayer:resetJettonBtnShow(_jettonArray)
	tlog('GameViewLayer:resetJettonBtnShow')
	self.m_pJettonNumber = _jettonArray
	local node_chip = self.m_csbNode:getChildByName("Node_bottom"):getChildByName("Node_chip")
	for i = 1, #self.m_pJettonNumber do
		local btn = node_chip:getChildByName(string.format("btn_choose_chip_%d", i))
		local text_1 = btn:getChildByName("Text_1")
		local serverKind = G_GameFrame:getServerKind()
		text_1:setString(g_format:formatNumber(self.m_pJettonNumber[i],g_format.fType.abbreviation,serverKind))
		local size = text_1:getContentSize()
		local scale = 95 / size.width
		scale = math.min(1, scale)
		text_1:setScale(scale)
	end
	self.m_doubleGoldNode:recordCurBetIndex(_jettonArray)
	self.m_doubleGoldNode:reset()
	self:clearBetQueue()
end

--下注按钮
function GameViewLayer:initJettonBtnInfo()
	tlog('GameViewLayer:initJettonBtnInfo')
	local node_chip = self.m_csbNode:getChildByName("Node_bottom"):getChildByName("Node_chip")

	--当前选中的下注筹码的tag	
	self.m_pJettonNumber = {1000, 5000, 10000, 50000, 100000}
	for i = 1, #self.m_pJettonNumber do
		local btn = node_chip:getChildByName(string.format("btn_choose_chip_%d", i))
		btn:setTag(i)
		btn:setPressButtonMusicPath("") --去除默认音效
		self:registerBtnEvent(btn, handler(self, self.onJettonButtonClicked),false,0.1)
		btn:getChildByName("Image_1"):setVisible(i == 1)
		btn._originPosy_ = btn:getPositionY()
		self.m_tableJettonBtn[i] = btn
		if i == 1 then
			btn:setPositionY(btn._originPosy_ + 30)
		end
	end
	
	--自动下注按钮
	local betAreaBtn = node_chip:getChildByName("btn_auto")
	betAreaBtn:getChildByName("Image_1"):setVisible(false)
	betAreaBtn:setTag(TAG_ENUM.BT_AUTOBET)
	betAreaBtn:addClickEventListener(handler(self, self.onButtonClickedEvent))
	self.m_autoBetArray = {autoBtn = betAreaBtn, isAuto = false, autoArr = {0, 0, 0}}

	self.m_curChoosedTag = 1
	--下注门槛遮罩	
	self.m_PanelLimit = node_chip:getChildByName("Panel_limit")	
	self:checkJettonThreshold()
	self:resetJettonBtnEnabled(false)
end

--自己和全部下注金额
function GameViewLayer:initCurJettonNumInfo()
	tlog('GameViewLayer:initCurJettonNumInfo')
	local panel_center = self.m_csbNode:getChildByName("Node_center")
	for i = 1, 3 do
		local btnNode = panel_center:getChildByName(string.format("Button_%d", i))
		local textBet = btnNode:getChildByName("fnt_self_bet")
		textBet:setString(0)
		textBet._lastNum = 0
		textBet._curNum = 0
		table.insert(self.m_selfBetLabelArr, textBet)
		-- local iconBet = node_1:getChildByName(string.format("Sprite_%d", i))
		-- table.insert(self.m_selfBetIconArr, iconBet)

		--总下注区域 下注值
		local totalBet = btnNode:getChildByName("fnt_total_bet")
		totalBet._lastNum = 0
		totalBet._curNum = 0
		totalBet:setString(0)
		table.insert(self.m_totalBetLabelArr, totalBet)
		-- --总下注区域 下注人数
		-- local playerNumLabel = button:getChildByName("Text_3_1")
		-- playerNumLabel:setString(0)
		-- table.insert(self.m_totalPlayerLabelArr, playerNumLabel)
		-- --总下注区域 下注图标,下注人数图标
		-- local iconBet = button:getChildByName("Sprite_6")
		-- local iconPeople = button:getChildByName("Sprite_8_0")
		-- iconPeople.isAction = false
		-- local originPos = cc.p(iconPeople:getPosition())
		-- local data = {iconBet = iconBet, iconPeople = iconPeople, originPos = originPos}
		-- table.insert(self.m_totalBetIconArr, data)
	end
end

-- _bStart 是否开始游戏重设
function GameViewLayer:resetJettonNumInfo(_bStart)
	tlog('GameViewLayer:resetJettonNumInfo ', _bStart)
	for i, text in ipairs(self.m_selfBetLabelArr) do
		text:stopAllActions()
		local curNum = 0
		if _bStart then
			text._lastNum = 0
			text._curNum = 0
			text:setString(0)
		else
			curNum = text._curNum
			text._lastNum = curNum
			if curNum >= 10000 then
				local serverKind = G_GameFrame:getServerKind()
				text:setString(g_format:formatNumber(curNum,g_format.fType.abbreviation,serverKind))
			else
				self:formatNumShow(text, curNum)
			end
		end
	end
	for i, text in ipairs(self.m_totalBetLabelArr) do
		text:stopAllActions()
		local curNum = 0
		if _bStart then
			text._lastNum = 0
			text._curNum = 0
		else
			curNum = text._curNum
			text._lastNum = curNum
		end
		self:formatNumShow(text, curNum)
	end
	-- for i, text in ipairs(self.m_totalPlayerLabelArr) do
	-- 	text:stopAllActions()
	-- 	if _bStart then
	-- 		text:setString(0)
	-- 	end
	-- end
end

function GameViewLayer:resetJettonBtnEnabled(_bEnable)
	tlog('GameViewLayer:resetJettonBtnEnabled ', _bEnable, self.m_rollTimerId)
	self:adjustJettonBtn()
	if _bEnable then
		if not self.m_rollTimerId then
			--倒计时临界值时，本地已经禁用按钮了，此时下注消息回来不能启用按钮
			return
		end
	end

	--设置中间下注按钮是否可用
	for i, betBtn in ipairs(self.m_betAreaBtnArray) do
		betBtn:setEnabled(_bEnable)
	end
end

--根据金币判断下注按钮是否可点
function GameViewLayer:adjustJettonBtn()
	tlog('GameViewLayer:adjustJettonBtn')
	local outlineColor = {
		cc.c4b(136, 21, 13, 255),
		cc.c4b(96, 35, 167, 255),
		cc.c4b(27, 124, 12, 255),
		cc.c4b(12, 88, 142, 255),
		cc.c4b(212, 87, 27, 255),
		cc.c4b(77, 77, 77, 255),  --黑色
	}
	for i = 1, #self.m_tableJettonBtn do
		local enable = (self.m_OverThreshold and self.m_scoreUser >= self.m_pJettonNumber[i])
		local btnNode = self.m_tableJettonBtn[i]
		btnNode:setEnabled(enable)
		local colorIndex = enable and i or 6
		btnNode:getChildByName("Text_1"):enableOutline(outlineColor[colorIndex], 3)
		--重连回来如果筹码额度改变了会触发
		if i == self.m_curChoosedTag and (not enable) then
			btnNode:setPositionY(btnNode._originPosy_)
			btnNode:getChildByName("Image_1"):setVisible(false)
			local firstBtn = self.m_tableJettonBtn[1]
			if firstBtn:isEnabled() then
				self.m_curChoosedTag = 1
				firstBtn:setPositionY(firstBtn._originPosy_ + 30)
			else
				self.m_curChoosedTag = 0
			end
		end
	end
end


---------------------------------------------------------------------------------------

function GameViewLayer:onBetButtonClick(_sender, _eventType)
	local tag = _sender:getTag()
	tlog('GameViewLayer:onBetButtonClick ', tag)
    if _eventType == ccui.TouchEventType.began then
    	_sender:getChildByName("Image_bg"):setVisible(true)
    elseif _eventType == ccui.TouchEventType.canceled then
    	_sender:getChildByName("Image_bg"):setVisible(false)
    elseif _eventType == ccui.TouchEventType.ended then
    	_sender:getChildByName("Image_bg"):setVisible(false)
		if self.m_isInGameEndStatus then
			tlog('self.m_isInGameEndStatus is true, not enable click')
			return
		end
		local curArea = tag - first_tag --索引分别是0，1，2
		if self.m_curChoosedTag <= 0 or self.m_curChoosedTag > 5 then
			print("onBetButtonClick selector error ", self.m_curChoosedTag)
			return
		end
		local _jettonSelect = self.m_pJettonNumber[self.m_curChoosedTag]
		--下注
		self:getParentNode():sendUserBet(curArea, _jettonSelect)
    end
end

function GameViewLayer:onJettonButtonClicked(_sender)
	local tag = _sender:getTag()
	tlog('GameViewLayer:onJettonButtonClicked ', tag)
	self.m_curChoosedTag = tag

	for i, btn in ipairs(self.m_tableJettonBtn) do
		btn:setPositionY(btn._originPosy_ + (i == tag and 30 or 0))
		btn:getChildByName("Image_1"):setVisible(i == tag)
	end
	-- _sender:setPositionY(btn._originPosy_ + 30)
	-- _sender:getChildByName("Image_1"):setVisible(true)
end

function GameViewLayer:onButtonClickedEvent(_sender)
	local tag = _sender:getTag()
	tlog('GameViewLayer:onButtonClickedEvent ', tag)
	g_ExternalFun.playClickEffect()
	if tag == TAG_ENUM.BT_EXIT then
		self:getParentNode():onQueryExitGame()
	elseif tag == TAG_ENUM.BT_SOUND then --音效
		GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble)
		self:flushMusicResShow(_sender, GlobalUserItem.bSoundAble)
	-- elseif tag == TAG_ENUM.BT_VOICE then
	-- 	GlobalUserItem.setVoiceAble(not GlobalUserItem.bVoiceAble)
	-- 	self:flushMusicResShow(_sender, GlobalUserItem.bVoiceAble)
	elseif tag == TAG_ENUM.BT_HELP then
		-- tlog('GameViewLayer:createHelpLayer')
		self.m_btnList:setVisible(false)
	    local _helpLayer = GameHelpLayer:create():addTo(self, 10)
	    _helpLayer:setPosition(display.width * 0.5, display.height * 0.5)
	elseif tag == TAG_ENUM.BT_HISTORY then
		self:getParentNode():getGameRecordReq(true)
	elseif tag == TAG_ENUM.BT_TOTAL_GREEN then
		self:createPlayerBetViewLayer(1)
	elseif tag == TAG_ENUM.BT_TOTAL_RED then
		self:createPlayerBetViewLayer(2)
	elseif tag == TAG_ENUM.BT_TOTAL_PURPLE then
		self:createPlayerBetViewLayer(3)
	elseif tag == TAG_ENUM.BT_AUTOBET then
		local totalNUm = self:getTotalBetNums()
		if not self.m_autoBetArray.isAuto and totalNUm == 0 then
			self:resetAutoBet()
			showToast(g_language:getString("game_tip_not_bet"))
			return
		end

		--非自动投注状态，身上金币不够本轮自动投注, 取消自动投注
		if not self.m_autoBetArray.isAuto and (totalNUm > self.m_scoreUser) then
			self:resetAutoBet()
			showToast(g_language:getString("game_tip_no_money"))
			return
		end
		self.m_autoBetArray.isAuto = not self.m_autoBetArray.isAuto
		self.m_autoBetArray.autoBtn:getChildByName("Image_1"):setVisible(self.m_autoBetArray.isAuto)
		self:checkAutoBetImmediately()
	else
		showToast("Funcionalidade não disponível!")
	end
end

function GameViewLayer:resetAutoBet()
	self.m_autoBetArray.autoBtn:getChildByName("Image_1"):setVisible(false)
	self.m_autoBetArray.isAuto = false
end

--勾选自动投注时，如果在下注阶段，且本轮没有投注过，立马自动投注
function GameViewLayer:checkAutoBetImmediately()
	tlog('checkAutoBetImmediately ', self.m_autoBetArray.isAuto, self.m_isInGameEndStatus)
	if self.m_autoBetArray.isAuto and (not self.m_isInGameEndStatus) then
		--是否下过注
		local betNums = 0
		for i, v in ipairs(self.m_selfBetLabelArr)  do
			betNums = betNums + v._curNum
		end
		if betNums == 0 then
			self:autoBetEvent()
		end
	end
end

function GameViewLayer:autoBetEvent()
	tdump(self.m_autoBetArray.autoArr, 'GameViewLayer:autoBetEvent', 10)
	for i, v in ipairs(self.m_autoBetArray.autoArr) do
		if v > 0 then
			self:getParentNode():sendUserBet(i - 1, v)
		end
	end
end

function GameViewLayer:createPlayerBetViewLayer(_betArea)
	tlog('GameViewLayer:createPlayerBetViewLayer ', _betArea)
	local playerData = self:getDataMgr():getTopTenUserBetScore(_betArea)
    local playerBetNode = GamePlayerBetView:create(_betArea, playerData):addTo(self, 10)
    playerBetNode:setPosition(display.width * 0.5, display.height * 0.5)
end

function GameViewLayer:onExit()
	tlog('GameViewLayer:onExit')
	self:gameDataReset()
	self:stopUpdateCall()
	self:stopRollingCall()
	if self.listener ~= nil then
		self:getEventDispatcher():removeEventListener(self.listener)
	end
	g_ExternalFun.stopMusic()
end

---------------------------------------------------------------------------------------
--网络消息
--网络接收
function GameViewLayer:onGetUserScore(item)
	tlog('GameViewLayer:onGetUserScore ', item.dwUserID, GlobalUserItem.dwUserID)
	--自己
	if not self.m_gameEndActionTime then
		if item.dwUserID == GlobalUserItem.dwUserID then
	        self:reSetUserInfo()
	    end
	end
end

--游戏空闲时间
function GameViewLayer:onGameFree()
	tlog('GameViewLayer:onGameFree')
end

--重连回来游戏正在下注状态
function GameViewLayer:reEnterStart(_totalSelfBet)
	tlog('GameViewLayer:reEnterStart')
	--获取玩家携带游戏币
	self:reSetUserInfo(_totalSelfBet)
	self.m_curRoundIsSelfBet = _totalSelfBet > 0
	self.m_isInGameEndStatus = false
	self.m_gameEndActionTime = false
	self.m_curWinLoseMoney = 0
	--下注
	self:resetJettonBtnEnabled(true)
	if self.m_curRoundIsSelfBet then
		self:recordCurBetInfo()
	end
	--检测下注门槛
	self:checkJettonThreshold()
end

--重连回来游戏正在结算状态
function GameViewLayer:reEnterEnd()
	self:reSetUserInfo()
	self.m_isInGameEndStatus = true
	self.m_gameEndActionTime = false
	self.m_curWinLoseMoney = 0
	self:resetJettonBtnEnabled(false)
	self.m_doubleTipNode:setTipNodeVisible(true)
	--检测下注门槛
	self:checkJettonThreshold()
end

--断线重连更新界面总下注
function GameViewLayer:reEnterGameBet(cbArea, llScore)
	tlog("GameViewLayer:reEnterGameBet ", cbArea, llScore)
	local betText = self.m_totalBetLabelArr[cbArea]
	-- if not betText or llScore == 0 then
	if not betText then
		tlog("reEnterGameBet not need to reset")
		return
	end

	self:refreshJettonNode(betText, llScore, 2)
	self.m_doubleGoldNode:reenterShowBetCoin(cbArea, llScore)
	--检测下注门槛
	self:checkJettonThreshold()
end

--断线重连更新玩家已下注
function GameViewLayer:reEnterUserBet(cbArea, llScore)
	tlog('GameViewLayer:reEnterUserBet ', cbArea, llScore)
	local betText = self.m_selfBetLabelArr[cbArea]
	if not betText then
		tlog("reEnterUserBet not need to reset")
		return
	end
	self:refreshJettonNode(betText, llScore, 1)
	--检测下注门槛
	self:checkJettonThreshold()
end

--更新下注显示
--_type 1是自己，2是总共
function GameViewLayer:refreshJettonNode(node, total, _type)
	tlog("GameViewLayer:refreshJettonNode")
	node:stopAllActions()
	if _type == 2 or (_type == 1 and total < 10000) then
		self:formatNumShow(node, total)
	else
		local serverKind = G_GameFrame:getServerKind()
		node:setString(g_format:formatNumber(total,g_format.fType.abbreviation,serverKind))
	end
	node._lastNum = total
	node._curNum = total
end

--游戏开始
function GameViewLayer:onGameStart()
	tlog('GameViewLayer:onGameStart')
	self.m_doubleGoldNode:reset()
	--获取玩家携带游戏币
	self:reSetUserInfo()
	self.m_isInGameEndStatus = false
	self.m_gameEndActionTime = false
	self.m_curWinLoseMoney = 0

	--检测下注门槛
	self:checkJettonThreshold()

	--下注
	self:resetJettonBtnEnabled(true)
	self:resetJettonNumInfo(true)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	-- g_ExternalFun.playSoundEffect("START_W.mp3")
	self:getDataMgr():resetAllUserBetScore()
	if self._endActionId then
		--由于结算滚动过长等原因，在结算时间结束之后滚动模块还没有复位，此时需要手动停止滚动并复位
		tlog("GameViewLayer:onGameStart self._endActionId not nil")
		self:resetWithOriginPanel(0)
	end
	
	self.m_autoBetActNode:stopAllActions()
	self.m_autoBetActNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
		tlog("start game, self.m_autoBetArray.isAuto ", self.m_autoBetArray.isAuto)
		if self.m_autoBetArray.isAuto then
			local totalNUm = self:getTotalBetNums()
			if totalNUm <= self.m_scoreUser then
				--携带的金币大于自动投注额度 正常投注
				self:autoBetEvent()
			else 
				--携带的金币不够本次自动投注，重置自动投注
				self:resetAutoBet()
				showToast(g_language:getString("game_tip_no_money"))
			end
		end
	end)))

	if self.m_doubleTipNode:getNodeVisible() then
		self.m_doubleTipNode:setTipNodeVisible(false)
	end
end

--游戏结束
function GameViewLayer:onGetGameEnd(_curResult)
	tlog('GameViewLayer:onGetGameEnd')
	if not self.m_isInGameEndStatus then
		--本地定时器晚于网络消息，做个保护
		self:popAllUserBetInfo()
	end
	self.m_isInGameEndStatus = true
	self.m_curRoundIsSelfBet = false
	self:resetJettonBtnEnabled(false)
	self:resetJettonNumInfo(false)
	self.m_curWinLoseMoney = _curResult[1][self:getWinNumIndex()]
	self.m_gameEndActionTime = true
    -- g_ExternalFun.playSoundEffect("STOP_W.mp3")
end

--收到下注消息,入列
function GameViewLayer:pushBetQueue(_netData)
    if not _netData then
        return
    end
    self.m_delayUserBetArray[#self.m_delayUserBetArray + 1] = _netData
    self:betQueuePopEvent()
end

--出列
function GameViewLayer:popBetQueue()
    if #self.m_delayUserBetArray > 0 then
        return table.remove(self.m_delayUserBetArray, 1)
    else
    	return nil
    end
end

--清除队列
function GameViewLayer:clearBetQueue()
	self.m_delayUserBetArray = nil
    self.m_delayUserBetArray = {}
    self.m_isBetMessagePlay = false
    self.m_betNetActNode:stopAllActions()
end

--取下一条消息
function GameViewLayer:readNextBetMessage(_delayTime)
	self.m_betNetActNode:runAction(cc.Sequence:create(cc.DelayTime:create(_delayTime), cc.CallFunc:create(function ()
		self.m_isBetMessagePlay = false
		self:betQueuePopEvent()
	end)))
end

-- 游戏消息
function GameViewLayer:betQueuePopEvent()
	if self.m_isBetMessagePlay then
		tlog("------self.m_isBetMessagePlay true------")
		return
	end
	
	local netData = self:popBetQueue()
	if not netData then
	    tlog('---GameViewLayer:betQueuePopEvent not netData---')
		return
	end
	self.m_isBetMessagePlay = true
	self:showUserBetEvent(nil, netData)
	local totalNums = #self.m_delayUserBetArray
	local delayTime = 2 / totalNums
	delayTime = math.min(delayTime, 0.1)
	delayTime = math.max(delayTime, 1 / 60)
	-- tlog("delayTime is ", totalNums, delayTime)
	self:readNextBetMessage(delayTime)
end

--如果下注时间结束了，队列里还有消息，全部放出去
function GameViewLayer:popAllUserBetInfo()
	self.m_betNetActNode:stopAllActions()
	--0.5s内放完
	local totalNums = #self.m_delayUserBetArray
	tlog('GameViewLayer:popAllUserBetInfo ', totalNums)
	--最多分15次全部放完
	local circleNums = math.min(totalNums, 15)
	local addNums = math.ceil(totalNums / circleNums)
	local times = 0.5 / circleNums
	for i = 1, circleNums do
		for j = 1, addNums do
			local netData = self:popBetQueue()
			if netData then
				local delayTime = times * (i - 1)
				if delayTime <= 0 then
					self:showUserBetEvent(nil, netData)
				else
					local delay = cc.DelayTime:create(delayTime)
					self.m_betNetActNode:runAction(cc.Sequence:create(delay, cc.CallFunc:create(function (t, p)
						self:showUserBetEvent(nil, p.data)
					end, {data = netData})))
				end
			else
				break
			end
		end
	    if #self.m_delayUserBetArray <= 0 then
	    	break
	    end
	end
	--最后清除队列
	self:clearBetQueue()
end

--网络下注消息过来
function GameViewLayer:onGetUserBet(cmd_placebet)
	tlog("GameViewLayer:onGetUserBet")
	if not cmd_placebet then
		return
	end
	if self.m_isInGameEndStatus then
		--消息延迟等
		self:showUserBetEvent(nil, cmd_placebet)
	else
		local wUser = cmd_placebet.wChairID
		if self:isMeChair(wUser) then
			--自己的直接飞出，不走队列
			self:showUserBetEvent(true, cmd_placebet)
		else
			self:pushBetQueue(cmd_placebet)
		end
	end
end

--更新用户下注
function GameViewLayer:showUserBetEvent(_isSelf, cmd_placebet)
	tlog("GameViewLayer:showUserBetEvent ", _isSelf)
	local wUser = cmd_placebet.wChairID
	local area = cmd_placebet.cbBetArea + 1
	--播放一个数字跳动动画
	local isSelf = false
	if _isSelf or self:isMeChair(wUser) then
		isSelf = true
		g_ExternalFun.playSoundEffect("double_bet.mp3")
		local textSelf = self.m_selfBetLabelArr[area]
		textSelf._lastNum = textSelf._curNum
		textSelf._curNum = textSelf._curNum + cmd_placebet.lBetScore
		if textSelf._curNum >= 10000 then
			textSelf:stopAllActions()
			local serverKind = G_GameFrame:getServerKind()
			textSelf:setString(g_format:formatNumber(textSelf._curNum,g_format.fType.abbreviation,serverKind))
		else
			self:updateGoldShow(textSelf)
		end
		self:updateUserScore(cmd_placebet.lBetScore)
		self.m_curRoundIsSelfBet = true
		self:resetJettonBtnEnabled(true)
		self:recordCurBetInfo()
	end
	local totalSelf = self.m_totalBetLabelArr[area]
	totalSelf._lastNum = totalSelf._curNum
	totalSelf._curNum = totalSelf._curNum + cmd_placebet.lBetScore
	self:updateGoldShow(totalSelf)
	self:getDataMgr():updateUserBetScore(wUser, area, cmd_placebet.lBetScore)

	self.m_doublePlayerNode:updatePlayerBetCoinShow(wUser, cmd_placebet.lBetScore)
	local playerIndex = self.m_doublePlayerNode:checkPlayerInSeat(wUser)
	self.m_doubleGoldNode:playerBetEvent(playerIndex, area, cmd_placebet.lBetScore, isSelf)
	if playerIndex == 0 then
		self:sharkTotalPeopleIcon()
	else
		if not _isSelf then
			self.m_doublePlayerNode:sharkPlayerHeadIcon(playerIndex)
		end
	end
end

--总玩家处抖动效果
function GameViewLayer:sharkTotalPeopleIcon(ref)
	tlog('GameViewLayer:sharkTotalPeopleIcon ', self.m_totalPeopleIcon.isPlay)
	if self.m_totalPeopleIcon.isPlay then
		return
	end
	self.m_totalPeopleIcon.isPlay = true
	local pPosItem = self.m_totalPeopleIcon.originPos
	local pAction1 = cc.MoveTo:create(0.025, cc.p(pPosItem.x + 30, pPosItem.y + 30))
	local pAction2 = cc.MoveTo:create(0.025, cc.p(pPosItem.x, pPosItem.y))
	local call = cc.CallFunc:create(function ()
		self.m_totalPeopleIcon.isPlay = false
	end)
	local pSeq = cc.Sequence:create(pAction1, pAction2, pAction1, pAction2, call)
	self.m_totalPeopleIcon:runAction(pSeq)
end

--下注后记录下注信息，续压使用
function GameViewLayer:recordCurBetInfo()
	tlog('GameViewLayer:recordCurBetInfo')
	for i, v in ipairs(self.m_selfBetLabelArr) do
		tlog("GameViewLayer:recordCurBetInfo111 ", i, v._curNum)
		self.m_autoBetArray.autoArr[i] = v._curNum
	end
end

--获取续压的总下注额
function GameViewLayer:getTotalBetNums()
	local totalNum = 0
	for i, v in ipairs(self.m_autoBetArray.autoArr) do
		totalNum = totalNum + v
	end
	tlog('GameViewLayer:getTotalBetNums ', totalNum)
	return totalNum
end

--更新座位上玩家金币显示
function GameViewLayer:onUpdateBetPlayerCoin(_betInfoArray)
	tlog('GameViewLayer:onUpdateBetPlayerCoin')
	for i, v in ipairs(_betInfoArray) do
		local betTotalNum = 0
		for j, value in ipairs(v.betScore) do
			betTotalNum = betTotalNum + value
		end
		self.m_doublePlayerNode:updatePlayerBetCoinShow(v.chairId, betTotalNum)
	end
end

--更新用户下注失败，没调用到
function GameViewLayer:onGetUserBetFail(_cmdData)
	tlog('GameViewLayer:onGetUserBetFail')
	if nil == _cmdData then
		return
	end
	--播放一个提示？
end

--更新玩家信息
function GameViewLayer:updatePlayerShow(_cmdData, _totalUpdate)
	tlog('GameViewLayer:updatePlayerShow ', _totalUpdate)
	self.m_doublePlayerNode:flushPlayerNodeShow(self:getDataMgr():getChairUserList(), _cmdData, _totalUpdate)
end

---------------------------------------------------------------------------------------
function GameViewLayer:getParentNode()
	return self._scene
end

function GameViewLayer:getMeUserItem()
	if nil ~= GlobalUserItem.dwUserID then
		return self:getDataMgr():getUidUserList()[GlobalUserItem.dwUserID]
	end
	return nil
end

function GameViewLayer:isMeChair( wchair )
	local useritem = self:getDataMgr():getChairUserList()[wchair + 1]
	if nil == useritem then
		return false
	else 
		return useritem.dwUserID == GlobalUserItem.dwUserID
	end
end

function GameViewLayer:getDataMgr()
	return self:getParentNode():getDataMgr()
end

function GameViewLayer:logData(msg)
	local p = self:getParentNode()
	if nil ~= p.logData then
		p:logData(msg)
	end
end

function GameViewLayer:gameDataReset()
	tlog('GameViewLayer:gameDataReset')
	display.removeSpriteFrames('GUI/double_bet_icon.plist', 'GUI/double_bet_icon.png')
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	--播放大厅背景音乐
	g_ExternalFun.stopAllEffects()
	self:getDataMgr():removeAllUser()
end

function GameViewLayer:updateClock(tag, left)
	tlog('GameViewLayer:updateClock ', tag, left)
	local str = string.format("%02d", left)
    if tag == g_var(cmd).kGAMEPLAY_COUNTDOWN then --下注倒计时
        if left == 3 then
			g_ExternalFun.playSoundEffect("double_3_countdown.mp3")
        end
	end
end

--显示当前状态的倒计时提示文本
function GameViewLayer:showTimerTip(tag, time, _isReenter)
	tlog('GameViewLayer:showTimerTip ', tag, time, _isReenter, self.m_endIndex)
	tag = tag or -1
	local parentNode = self.m_csbNode:getChildByName("Node_top"):getChildByName("Sprite_10")
	parentNode:getChildByName("Text_1"):setVisible(false)
	parentNode:getChildByName("Text_2"):setVisible(false)
	local image_percent = parentNode:getChildByName("Image_percent")
	local image_tip = parentNode:getChildByName("Image_left_tip")
	if tag == g_var(cmd).kGAMEPLAY_COUNTDOWN then --下注状态
		image_percent:setVisible(true)
		image_tip:loadTexture("GUI/double_xzz_bg.png")
		--起一个定时器
		self.m_leftTime = time
		if self.m_rollTimerId == nil then
		    self.m_rollTimerId = g_scheduler:scheduleScriptFunc(function (dt)
		    	local curLeftTime = self.m_leftTime
		    	if curLeftTime < 0 then
		    		curLeftTime = 0
		    		self.m_isInGameEndStatus = true
		    		self:popAllUserBetInfo()
			    	self:stopRollingCall()
			    	self:resetJettonBtnEnabled(false)
		    	end
		    	-- text_1:setString(string.format("Contagem Decrescente do Jogo %.2f", curLeftTime))
		    	local curPercent = curLeftTime / self.m_totalBetTime
		    	-- tlog('curPercent is ', curPercent)
		    	local size_width = 670 * curPercent
		    	image_percent:setContentSize(cc.size(size_width, 22))
		    	self.m_leftTime = self.m_leftTime - dt
		    end, 0, false)
		end
	else
		--游戏结束状态
		if self.m_rollTimerId ~= nil then
	    	self:stopRollingCall()
	    end
		image_percent:setVisible(false)
		image_tip:loadTexture("GUI/double_ddz_bg.png")
		-- text_2:setVisible(true)
		-- if self.m_endIndex ~= -1 then
		-- 	if _isReenter then
		-- 		text_2:setString(string.format("Girado até %d!", self.m_endIndex))
		-- 	else
		-- 		text_2:setString("Girando...")
		-- 	end
		-- else
		-- 	text_2:setVisible(false)
		-- end
	end
end

--new
--滚动需要的数据
function GameViewLayer:initRollData()
	tlog("GameViewLayer:initRollData")
    self.m_curSpeedFactor = 0.1   	--使用math.sin来计算速度的因子
    self.m_lastMoveLength = 0	 	--准备开始停下之后移动了的距离
    self.m_lastNeedMovePosition = 0 --准备开始停下之后需要移动的距离
    self.m_totalMoveLength = 0 		--停下之后复位需要移动的距离
    self.m_sliceTime = 0 			--播放音效的切片时间
end

--处理中间的滚动模块
function GameViewLayer:dealWithScrollItem()
	tlog('GameViewLayer:dealWithScrollItem')
	self.m_scrollItem = {}
	local length = #sortArray
	local topNode = self.m_csbNode:getChildByName("Node_top")
	local panel_roll = topNode:getChildByName("Panel_roll")
	panel_roll:setTouchEnabled(false)
	panel_roll:retain()
	panel_roll:removeFromParent()
	self.m_panelSize = panel_roll:getContentSize()

	--panel加入裁剪节点中
	local clipSp = cc.Sprite:create("GUI/double_ytjx_bg.png")	
	local clip = cc.ClippingNode:create()
	clip:setStencil(clipSp)
	clip:setAlphaThreshold(0.05)
	clip:addChild(panel_roll)
	clip:setPosition(0, 0)
	clip:addTo(topNode:getChildByName("Node_clip"))
	local size = clip:getContentSize()
	-- clip:setContentSize(cc.size(size.width + ))
	panel_roll:setPosition(size.width * 0.5, size.height * 0.5)
	panel_roll:release()

	for i = 1, 2 do
		local panel = panel_roll:getChildByName(string.format("Panel_%d", i))
		panel:setTouchEnabled(false)
        table.insert(self.m_scrollItem, panel)
        local size_width = length * Item_Width
        panel:setContentSize(cc.size(size_width, Panel_Height))
        panel:setPosition((i - 1) * size_width, Panel_Height * 0.5)
        for k, j in ipairs(sortArray) do
        	local itemNode = DoubleItemNode:create(j)
        	local size_item = itemNode:getNodeSize()
        	itemNode:setPosition((k - 1) * Item_Width + size_item.width * 0.5, Panel_Height * 0.5)
        	itemNode:setTag(k)
        	panel:addChild(itemNode)
        end
    end
end

--进入或者重连的时候把第一个panel的0号置于中间
function GameViewLayer:resetWithOriginPanel(_initNum)
	tlog("GameViewLayer:resetWithOriginPanel ", _initNum)
	local length = #sortArray
    local size_width = length * Item_Width
	for i, v in ipairs(self.m_scrollItem) do
		v:stopAllActions()
		v:setPosition((i - 1) * size_width, Panel_Height * 0.5)
	end
	self:stopUpdateCall()
	local firstPanel = self.m_scrollItem[1]
	local showIndex = self:getRollIndexWithNum(_initNum)
	local size_item = firstPanel:getChildByTag(showIndex):getNodeSize()
	local curPosX = (showIndex - 1) * Item_Width + size_item.width * 0.5
	tlog('GameViewLayer:resetWithOriginPanel_1 ', curPosX)
	local totalWidth = self.m_panelSize.width * 0.5 --中点
	self:rollAction(curPosX - totalWidth)
	--重设两个panel的位置和序号
	local posX = firstPanel:getPositionX()
	if posX > 0 then
		local panelWidth = #sortArray * Item_Width
		local itemTwo = self.m_scrollItem[2]
		itemTwo:setPositionX(posX - panelWidth)
		self.m_scrollItem[2] = firstPanel
		self.m_scrollItem[1] = itemTwo
	end
end

function GameViewLayer:getWinNumIndex()
	local winRate = 2
	local winIndex = 1
	if self.m_endIndex == 0 then
		winIndex = 2
		winRate = 14
	elseif self.m_endIndex >= 8 then
		winIndex = 3
	end
	return winIndex, winRate
end

--开始滚动
function GameViewLayer:startRoll(_endIndex)
	tlog('GameViewLayer:startRoll ', _endIndex)
	self.m_endIndex = _endIndex
	--一共滚动大约8秒钟
	self:stopUpdateCall()
    self._rollActionId = g_scheduler:scheduleScriptFunc(handler(self,self.rollActionTimer), 0, false)
    self._rollTimeId = g_scheduler:scheduleScriptFunc(handler(self,self.onRollSpeedChanged), 0.15, false)
    self:rollAction()
end

--通过结果数字找出在列表中的序号
function GameViewLayer:getRollIndexWithNum(_curNum)
	tlog('GameViewLayer:getRollIndexWithNum ', _curNum)
	for i, v in ipairs(sortArray) do
		if v == _curNum then
			return i
		end
	end
end

--开启定时器改变速度因子
function GameViewLayer:onRollSpeedChanged(dt)
	if self.m_curSpeedFactor <= (math.pi - 0.4) then
		self.m_curSpeedFactor = self.m_curSpeedFactor + 0.05
		-- tlog('self.m_curSpeedFactor ', self.m_curSpeedFactor)
	else
		if self.m_curSpeedFactor <= (math.pi - 0.2) then
			self.m_curSpeedFactor = self.m_curSpeedFactor + 0.05
		else
			self:stopTimeCall()
		end
		if self.m_lastNeedMovePosition == 0 then
			local firstPanel = self.m_scrollItem[1]
			local curIndex = self:getRollIndexWithNum(self.m_endIndex) --当前停止的数字在panel中的序号
			local size_item = firstPanel:getChildByTag(curIndex):getNodeSize()
			local posX = firstPanel:getPositionX()
			local endItemPosX = posX + (curIndex - 1) * Item_Width + size_item.width * 0.5
			tlog("posX endItemPosX ", posX, endItemPosX)
			--判定是用当前的第一块panel停还是第二块panel停
			local totalWidth = self.m_panelSize.width * 0.5 --中点
			local needLength = 0
			if endItemPosX <= totalWidth then
				--第一块panel当前数字已经移动到中间靠左了，要继续移动使用第二块的数字
				needLength = #sortArray * Item_Width - (totalWidth - endItemPosX)
			else
				needLength = endItemPosX - totalWidth
			end
			--给个偏移值，在最终停止时造成修正的效果
			local offsetX = math.random(10, math.floor(size_item.width / 2) - 10)
			local plusOrMinus = math.random(2) == 1 and 1 or -1
			self.m_fixLength = offsetX * plusOrMinus
		    self.m_lastMoveLength = 0
		    self.m_lastNeedMovePosition = needLength + self.m_fixLength
			tlog('self.m_lastNeedMovePosition ', self.m_fixLength, self.m_lastNeedMovePosition)
		end
	end
end

--滚动事件
function GameViewLayer:rollActionTimer(dt)
	self.m_sliceTime = self.m_sliceTime + dt
	if self.m_sliceTime >= 1 then
		g_ExternalFun.playSoundEffect("double_rolling.mp3")
		self.m_sliceTime = self.m_sliceTime - 1
	end

	self:rollAction()
end

-- _curSpeed 修正值，没有使用速度因子的值
function GameViewLayer:rollAction(_curSpeed, _showTip)
	local curSpeed = _curSpeed or math.sin(self.m_curSpeedFactor) * 51
	-- tlog('curSpeed is ', curSpeed)
	--移动过程中通过设置保证左边的永远是itemArray的第一个(即在界面上显示的永远是序号1的panel)
	local firstPanel = self.m_scrollItem[1]
	local curPosx = firstPanel:getPositionX()
	local panelWidth = #sortArray * Item_Width
	if curSpeed > 0 then --向左滚动
		if curPosx < -1 * panelWidth then
			local nextPanel = self.m_scrollItem[2]
			firstPanel:setPositionX(curPosx + 2 * panelWidth)
			self.m_scrollItem[2] = firstPanel
			self.m_scrollItem[1] = nextPanel
		end
	else 	--向右滚动
		self.m_lastMoveLength = self.m_lastMoveLength - _curSpeed
		-- tlog('self.m_lastMoveLength is ', self.m_lastMoveLength)
		if self.m_lastMoveLength >= self.m_totalMoveLength then
			_curSpeed = _curSpeed + (self.m_lastMoveLength - self.m_totalMoveLength)
			self:stopEndActionCall()
			if _showTip then
				self.m_doubleTipNode:setTipNodeVisible(true)
				--检测下注门槛
				self:checkJettonThreshold()
				--下注
				self:resetJettonBtnEnabled(true)
			end
		end
		if curPosx > 0 then
			local nextPanel = self.m_scrollItem[2]
			nextPanel:setPositionX(curPosx - panelWidth)
			self.m_scrollItem[2] = firstPanel
			self.m_scrollItem[1] = nextPanel
		end
	end

	if self.m_lastNeedMovePosition ~= 0 then
		self.m_lastMoveLength = self.m_lastMoveLength + curSpeed
		if self.m_lastMoveLength >= self.m_lastNeedMovePosition then --移动到位置了
			curSpeed = curSpeed - (self.m_lastMoveLength - self.m_lastNeedMovePosition)
			self:stopUpdateCall()
			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
				for i, panel in ipairs(self.m_scrollItem) do
					panel:runAction(cc.MoveBy:create(0.2, cc.p(self.m_fixLength, 0)))
				end
				self:updateRollResult()
			end), cc.DelayTime:create(2.0), cc.CallFunc:create(function ()
				self:flushWhiteItemToCenter()
			end)))
		end
	end
	for i, panel in ipairs(self.m_scrollItem) do
		panel:setPositionX(panel:getPositionX() - curSpeed)
	end
end

--出结果之后有个刷新，把0号白色刷新到中间
function GameViewLayer:flushWhiteItemToCenter()
	self:updateHistoryNode()	--更新历史记录
	self.m_lastMoveLength = 0
	local firstPanel = self.m_scrollItem[1]
	local curIndex = self:getRollIndexWithNum(self.m_endIndex) --当前停止的数字在panel中的序号
	local size_item = firstPanel:getChildByTag(curIndex):getNodeSize()

	self.m_totalMoveLength = (curIndex + 40) * Item_Width  --0位于序列的第五位，所以是45 - 5
	tlog('GameViewLayer:flushWhiteItemToCenter ', curIndex, self.m_totalMoveLength)
    self._endActionId = g_scheduler:scheduleScriptFunc(function ()
		self:rollAction(-1 * (Item_Width / 4), true)
    end, 0, false)
end

function GameViewLayer:updateRollResult()
	tlog('GameViewLayer:updateRollResult')
	g_ExternalFun.playSoundEffect("double_roll_end.mp3")

	local parentNode = self.m_csbNode:getChildByName("Node_top"):getChildByName("Sprite_10")
	parentNode:getChildByName("Image_percent"):setVisible(false)
	local image_tip = parentNode:getChildByName("Image_left_tip")
	image_tip:loadTexture("GUI/double_ddz_bg.png")

	self.m_gameEndActionTime = false
	--避免声音冲突
	image_tip:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
		self:checkRecoveryBetJetton()
	end)))
end

--根据下注情况回收筹码
function GameViewLayer:checkRecoveryBetJetton()
	local allUseBetInfo = self:getDataMgr():getAllUserBetScore()
	local allSeatPlayer = self.m_doublePlayerNode:getAllSeatPlayerChairId()
	local callBack = function (_playerInfo, _isSelf)
		self.m_doublePlayerNode:updatePlayerTotalCoinShow(_playerInfo)
		if _isSelf then
			--更新玩家金币
			self:reSetUserInfo()
		end
	end
	--构造输赢数据
	local winPlayerArray = {}
	local winIndex, winRate = self:getWinNumIndex()
	for i, v in ipairs(allUseBetInfo) do
		local data = {}
		data.chairId = v.chairId
		data.winMoney = 0 --总的输赢
		for j, value in ipairs(v.betScore) do
			if j == winIndex then
				data.betMoney = value --在开奖区域的输赢
				data.winMoney = data.winMoney + value * (winRate - 1)
			else
				data.winMoney = data.winMoney - value
			end
		end
		data.isSelf = self:isMeChair(v.chairId)
		data.seatIndex = data.isSelf and 7 or 0
		for j, seatId in ipairs(allSeatPlayer) do
			if v.chairId == seatId and (not data.isSelf) then
				data.seatIndex = j
			end
		end
		local playerMoney = self:getDataMgr():getChairUserList()[v.chairId + 1].lScore
		data.playerInfo = {chairId = v.chairId, lScore = playerMoney}
		table.insert(winPlayerArray, data)
	end
	tdump(winPlayerArray, "winPlayerArray", 10)
	self:showBlinkEffect(winIndex)
	self.m_doubleGoldNode:playerGetJetton(winPlayerArray, winIndex, callBack)
end

--中奖区域闪动效果
function GameViewLayer:showBlinkEffect(winIndex)
	for k, v in pairs(self.m_betAreaBtnArray) do
		if k == winIndex then
			local Image_bg = v:getChildByName("Image_bg")
			Image_bg:runAction(
				cc.Sequence:create(
                    cc.Show:create(),
                    cc.Blink:create(3,3),
                    cc.Hide:create()
                    )
                )
			break
		end
	end
end

--滚动停止之后回退定时器
function GameViewLayer:stopEndActionCall()
	if self._endActionId ~= nil then
		g_scheduler:unscheduleScriptEntry(self._endActionId)
		self._endActionId = nil
	end
end

--游戏结束滚动定时器
function GameViewLayer:stopActionCall()
	if self._rollActionId ~= nil then
		g_scheduler:unscheduleScriptEntry(self._rollActionId)
		self._rollActionId = nil
	end
end

--速度因子改变定时器
function GameViewLayer:stopTimeCall()
	if self._rollTimeId ~= nil then
		g_scheduler:unscheduleScriptEntry(self._rollTimeId)
		self._rollTimeId = nil
	end
end

--游戏下注状态倒计时定时器
function GameViewLayer:stopRollingCall()
	if self.m_rollTimerId ~= nil then
		g_scheduler:unscheduleScriptEntry(self.m_rollTimerId)
		self.m_rollTimerId = nil
	end
end

function GameViewLayer:stopUpdateCall()
	tlog('GameViewLayer:stopUpdateCall')
	self:initRollData()
	self:stopEndActionCall()
	self:stopActionCall()
	self:stopTimeCall()
end

function GameViewLayer:formatNumShow(_node, _nums)
	local serverKind = G_GameFrame:getServerKind()
	local formatMoney = g_format:formatNumber(_nums,g_format.fType.standard,serverKind)
	_node:setString(formatMoney)
end

function GameViewLayer:updateGoldShow(_nodeText)
    tlog("GameViewLayer:updateGoldShow")
    local newValue = _newValue
    _nodeText:stopAllActions()
    local lastNum = _nodeText._lastNum
    local curNum = _nodeText._curNum
    self:formatNumShow(_nodeText, lastNum)
    local loopNums = 20 -- math.ceil(4.8 / 0.1) --每0.05秒更新一次
    local gapNums = math.ceil((curNum - lastNum) / loopNums)
	self:addGoldNumsShowInterval(_nodeText, lastNum, curNum, gapNums)
end

function GameViewLayer:addGoldNumsShowInterval(_node, _srcNums, _dstNums, _addNums)
	-- tlog('GameViewLayer:addGoldNumsShowInterval')
    local nowNums = _srcNums + _addNums
    if nowNums > _dstNums then
        nowNums = _dstNums
        self:formatNumShow(_node, nowNums)
        return
    end
    self:formatNumShow(_node, nowNums)
    _node:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function (_target, _params)
        self:addGoldNumsShowInterval(_params.node, _params.srcNums, _params.dstNums, _params.addNums)
    end, {node = _node, srcNums = nowNums, dstNums = _dstNums, addNums = _addNums})))
end

function GameViewLayer:isLuaNodeValid(node)
    return(node and not tolua.isnull(node))
end

--注册按钮监听
function GameViewLayer:registerBtnEvent(_btnNode, _callBack, _pressAct, _delayTime)
    if _pressAct == nil then
        _pressAct = true
    end
    if _delayTime == nil then
    	_delayTime = 0.5
    end
    tlog("_pressAct is ", _pressAct)
    _btnNode.isTouch = 1
    _btnNode:setPressedActionEnabled(_pressAct)
    _btnNode:addClickEventListener(function(_sender)
        if _btnNode.isTouch == 1 then
            _btnNode.isTouch = 2
            _btnNode:runAction(
                cc.Sequence:create(
                cc.CallFunc:create(function ( ... )
                    if _callBack then
                        _callBack(_sender)
                    end
                end),
                cc.DelayTime:create(_delayTime),
                cc.CallFunc:create(function ( ... )
                    _btnNode.isTouch  = 1
                end)
            ))
        end
    end)
end

--服务器消息回来之后显示记录信息(最多15个)
function GameViewLayer:initHistoryNode(_cmdData)
	tlog("GameViewLayer:initHistoryNode")
	local historyNode = self.m_csbNode:getChildByName("FileNode_lishijilu")
	local panel = historyNode:getChildByName("Panel_1")
	panel:removeAllChildren()
	local count = 0
	if _cmdData.openNumCount > 0 then
		local minNum = _cmdData.openNumCount - (Total_History_Node - 1)
		if minNum < 1 then
			minNum = 1
		end
		local firstTag = _cmdData.openNumCount --初始tag值，越新的记录值越大(在右边)
		if firstTag > Total_History_Node then
			firstTag = Total_History_Node
		end
		for i = _cmdData.openNumCount, minNum, -1 do
	    	local itemNode = DoubleItemNode:create(_cmdData.openNum[1][i])
			itemNode:showFlagNew(i == _cmdData.openNumCount)
	    	itemNode:setScale(0.65)
	    	itemNode:setPosition(915 - (_cmdData.openNumCount - i) * 80, 42.5)
	    	panel:addChild(itemNode)
	    	itemNode:setTag(firstTag - count)
			itemNode:registerClickFunc(self)
	    	count = count + 1
		end
	end
	panel._curCount_ = count
	--请求历史记录
	self:requestHistoryRecord(_cmdData)
end

function GameViewLayer:updateHistoryNode()
	local historyNode = self.m_csbNode:getChildByName("FileNode_lishijilu")
	local panel = historyNode:getChildByName("Panel_1")
	--新增一个
	local itemNode = DoubleItemNode:create(self.m_endIndex)
	itemNode:setScale(0.65)
	itemNode:setPosition(995, 42.5)
	panel:addChild(itemNode)
	panel._curCount_ = panel._curCount_ + 1
	if panel._curItemIndex_ then
		panel._curItemIndex_ = panel._curItemIndex_ + 1
	end
	itemNode:setTag(panel._curCount_)
	itemNode:registerClickFunc(self)
	for i, v in ipairs(panel:getChildren()) do
		v:showFlagNew(i == panel._curCount_)
		v:runAction(cc.MoveBy:create(0.5, cc.p(-80, 0)))
	end
	if panel:getChildrenCount() >= (Total_History_Node + 1) then
		--删除最左边出界的一个
		panel:removeChildByTag(panel._curCount_ - Total_History_Node)
	end
end

function GameViewLayer:registerTouch()
	tlog('GameViewLayer:registerTouch')
	local function onTouchBegan( touch, event )
		return true
	end

	local function onTouchEnded( touch, event )
		tlog('onTouchEnded')
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

function GameViewLayer:requestHistoryRecord(_cmdData)
	self.HistoryInfo = _cmdData
	self.TopHistoryClickEnabled = false
	self:getParentNode():getGameRecordReq()
end

function GameViewLayer:responeHistoryRecord(_historyInfo)
	-- dump(_historyInfo)
	-- dump(self.HistoryInfo)
	local historyNode = self.m_csbNode:getChildByName("FileNode_lishijilu")
	local panel = historyNode:getChildByName("Panel_1")
	local pCount = panel._curCount_
	local pLastNum = nil
	local pChildren = panel:getChildren()
	for i,v in ipairs(pChildren) do
		if pCount and pCount == v:getTag() then
			pLastNum = v:getCurrentIndex()
			break
		end
	end
	local pInfoIndex = nil
	for i=#_historyInfo,1,-1 do
		if _historyInfo[i].openNum == pLastNum then
			pInfoIndex = i
			panel._curItemIndex_ = _historyInfo[i].itemIndex
			break
		end
	end
	local pFlag = true
	local pSize = math.min(pCount,5)
	for i=1,pSize do
		local pCompareIndex = pCount - i + 1
		local pCompareIndex2 = pInfoIndex -i + 1
		if panel:getChildByTag(pCompareIndex):getCurrentIndex() ~= _historyInfo[pCompareIndex2].openNum then
			pFlag = false
		end
	end
	self.TopHistoryClickEnabled = pFlag
end

function GameViewLayer:onHistoryItemClick(pTag)
	print("pTag = ",pTag)
	if not self.TopHistoryClickEnabled then
		return
	end
	local historyNode = self.m_csbNode:getChildByName("FileNode_lishijilu")
	local panel = historyNode:getChildByName("Panel_1")	
	local pItemIndex = panel._curItemIndex_ + pTag - panel._curCount_
	self:getParent():getGameDetailRecordReq(pItemIndex, 0, 10)
end

function GameViewLayer:updateTotalPeople()
    local text_online = self.m_totalPeopleIcon:getChildByName("Text_1")
	--使用大厅显示的数据
    g_onlineCount:regestOnline(GlobalUserItem.roomMark, text_online)
end

--检测下注门槛
function GameViewLayer:checkJettonThreshold()
	if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
		self.m_OverThreshold = GlobalUserItem.VIPLevel and GlobalUserItem.VIPLevel >= self.over_vip
		--门槛遮罩显示
		self.m_PanelLimit:setVisible(not self.m_OverThreshold)		
		if not self.m_OverThreshold then
			--重置自动下注
			self:resetAutoBet()
		end		
	else
		self.m_OverThreshold = true
		self.m_PanelLimit:hide()
	end
end

return GameViewLayer