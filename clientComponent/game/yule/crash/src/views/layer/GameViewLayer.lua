local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
local module_pre = "game.yule.crash.src"
local g_var = g_ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"
local GameHelpLayer = appdf.req(module_pre .. ".views.layer.GameHelpLayer")
local CrashEnterWordNode = appdf.req(module_pre .. ".views.layer.CrashEnterWordNode")
local CrashChoosedNumNode = appdf.req(module_pre .. ".views.layer.CrashChoosedNumNode")
local CrashItemNode = appdf.req(module_pre .. ".views.layer.CrashItemNode")
local CrashBgNode = appdf.req(module_pre .. ".views.layer.CrashBgNode")
local g_scheduler = cc.Director:getInstance():getScheduler()
local HeadNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HeadNode")
local Total_Width = 1025 --展示时间总共的长度
local Total_Height = 520 --展示倍率总共的高度
local leftNodePosX = 1282 	--右侧节点的x坐标(每个都相同)
local leftOriginPosY = 85 	--右侧节点的y初始坐标
local downOriginPosX = 114 	--底下节点的x初始坐标
local downNodePosY = 39 	--底下节点的y坐标(每个都相同)
local rocketRotation = 25.5 --火箭需要旋转的角度，即线的角度
local enumTable = 
{
	"BT_EXIT",
	"BT_SOUND",			--音效
	"BT_HELP",
	"BT_HISTORY",
	"BT_AUTOBET",
	"BT_ADD_RATE",		--增加倍率按钮，一次加0.01
	"BT_MINUS_RATE", 	--减少倍率按钮，一次减0.01
	"BT_IMMEDIATE_STOP", 	--立刻停止
	"BT_CHOOSED_CRASH", --选择倍率
	"BT_EDIT_CRASH",	--输入倍率
	"BT_REMOVE_CRASH",	--移除倍率
	"BT_CHOOSED_MONEY",	--选择金额
	"BT_EDIT_MONEY",	--输入金额
	"BT_REMOVE_MONEY",	--移除金额
}
local TAG_ENUM = g_ExternalFun.declarEnumWithTable(100, enumTable)
local Total_History_Node = 8
-- local min_bet_money = 10000
-- local min_bet_rate = 1.01

function GameViewLayer:ctor(scene)
	tlog('GameViewLayer:ctor')
	--注册node事件
	g_ExternalFun.registerNodeEvent(self)
	
	self._scene = scene
	self:gameDataInit()

	--初始化csb界面
	self:initCsbRes()
	self:registerTouch()

	g_ExternalFun.playMusic("sound_res/bgm_crash.mp3", true)
end

function GameViewLayer:gameDataInit()
	tlog('GameViewLayer:gameDataInit')
    --无背景音乐
    g_ExternalFun.stopMusic()
    --用户列表
	self:getDataMgr():initUserList(self:getParentNode():getUserList())
    --加载资源
	self:loadRes()
	-- self:initRollData()
	self.m_totalBetTime = 0 			--下注状态总时间
    self.m_endIndex = -1 				--开奖的结果号码
	self.m_jettonBtn = nil				--筹码下注按钮
	self.m_scoreUser = 0 				--玩家金币数
	self.over_vip                       = 1         --限额阈值
    self.m_OverThreshold                = false     --玩家数高于阈值
	self.m_isInGameEndStatus = false	--是否结算状态
	self.m_gameEndActionTime = false 	--是否结算动画时间内,当前时间内不更新金币显示
	self.m_cbGameStatus = -1			--当前游戏状态
	self.m_curRoundSelfBetRate = -1	 	--当前轮自己的下注倍率，大于-1表示下注了,0可以表示不限倍率，按开奖最高倍率算
	self.m_curCurveNum = 0				--当前曲线进度值
	self.m_calculateFactory = 0 		--二次方程的计算因子，服务器下发
	self.m_betConfig = {}               --倍数配置表 服务器下发
	self.m_multipleConfig = {}          --下注配置表 服务器下发
	self.m_min_bet_money = 10000        --最低下注
	self.m_betArrayRate = {}
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
	tlog('GameViewLayer:initCsbRes')
	local csbNode = cc.CSLoader:createNode("UI/GameLayer.csb")
	-- local csbNode = g_ExternalFun.loadCSB("UI/GameLayer.csb", self)
	tdump(display.size, "display.size")
	csbNode:setContentSize(display.size)
	ccui.Helper:doLayout(csbNode)
	csbNode:addTo(self)
	self.m_csbNode = csbNode:getChildByName("Panel_2")
	self.m_csbNode:setTouchEnabled(false)
	self.m_bottomNodeParent = self.m_csbNode:getChildByName("Node_1")

	self.m_crashBgNode = CrashBgNode:create(self.m_csbNode:getChildByName("Node_bg"))
	self.m_crashBgNode:addTo(self)

	--初始化按钮
	self:initBtn()
	--初始化玩家信息
	self:initUserInfo()
	--初始化桌面下注
	self:initJetton()
	--初始化曲线节点
	self:initWithCurveRollItem()
	--初始化右侧玩家节点
	self:initPlayerView()

	self.m_actionNode = cc.Node:create()
	self.m_actionNode:addTo(self)
	self.m_actionNode_1 = cc.Node:create()
	self.m_actionNode_1:addTo(self)
end

--初始化按钮
function GameViewLayer:initBtn()
	tlog('GameViewLayer:initBtn')
	local panel_center = self.m_csbNode:getChildByName("Panel_center")
	self.m_btnList = panel_center:getChildByName("sp_btn_list")
	self.m_btnList:setVisible(false)
	local btn_more = panel_center:getChildByName("Button_more")
	btn_more:addClickEventListener(function ()
		self.m_btnList:setVisible(not self.m_btnList:isVisible())
	end)

	--音效
	local btn = self.m_btnList:getChildByName("voice_btn")
	btn:setTag(TAG_ENUM.BT_SOUND)
	self:flushMusicResShow(btn, GlobalUserItem.bSoundAble)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent), nil, 0.02)

	--离开
	btn = self.m_btnList:getChildByName("back_btn")
	btn:setTag(TAG_ENUM.BT_EXIT)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))

	--说明
    btn = self.m_btnList:getChildByName("rule_btn")
	btn:setTag(TAG_ENUM.BT_HELP)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))

	--历史记录
	local historyNode = panel_center:getChildByName("FileNode_lishijilu")
	historyNode:getChildByName("Panel_1"):setTouchEnabled(false)
	local historyBtn = historyNode:getChildByName("Button_1")
	historyBtn:setTag(TAG_ENUM.BT_HISTORY)
	self:registerBtnEvent(historyBtn, handler(self, self.onButtonClickedEvent))

	--倍率处理
	local panel_beilv = self.m_bottomNodeParent:getChildByName("Panel_beilv")
	panel_beilv:setTouchEnabled(false)
	-- panel_beilv:getChildByName("betInfo_tip"):setVisible(false)
	local btn_choosed = panel_beilv:getChildByName("Button_1")
	btn_choosed:addClickEventListener(handler(self, self.onRateMoneyChoosedBtnClick))
	btn_choosed:setTag(TAG_ENUM.BT_CHOOSED_CRASH)
	local panel_edit = panel_beilv:getChildByName("Panel_edit")
	panel_edit:addClickEventListener(handler(self, self.onRateMoneyChoosedBtnClick))
	panel_edit:setTag(TAG_ENUM.BT_EDIT_CRASH)
	local btn_remove = panel_edit:getChildByName("Button_remove")
	btn_remove:addClickEventListener(handler(self, self.onRateMoneyChoosedBtnClick))
	btn_remove:setTag(TAG_ENUM.BT_REMOVE_CRASH)
	btn_remove:setVisible(false)
	self.m_curChoosedRate = panel_edit:getChildByName("Text_1")
	self:updateCurRateShow(0)

	--金额处理
	local panel_xiazhu = self.m_bottomNodeParent:getChildByName("Panel_xiazhu")
	panel_xiazhu:setTouchEnabled(false)
	-- panel_xiazhu:getChildByName("betInfo_tip"):setVisible(false)
	btn_choosed = panel_xiazhu:getChildByName("Button_1")
	btn_choosed:addClickEventListener(handler(self, self.onRateMoneyChoosedBtnClick))
	btn_choosed:setTag(TAG_ENUM.BT_CHOOSED_MONEY)
	panel_edit = panel_xiazhu:getChildByName("Panel_edit")
	panel_edit:addClickEventListener(handler(self, self.onRateMoneyChoosedBtnClick))
	panel_edit:setTag(TAG_ENUM.BT_EDIT_MONEY)
	btn_remove = panel_edit:getChildByName("Button_remove")
	btn_remove:addClickEventListener(handler(self, self.onRateMoneyChoosedBtnClick))
	btn_remove:setTag(TAG_ENUM.BT_REMOVE_MONEY)
	btn_remove:setVisible(false)
end

--音效音乐设置资源
function GameViewLayer:flushMusicResShow(_node, _enabled)
	_node:getChildByName('Image_1'):setVisible(_enabled)
	_node:getChildByName('Image_2'):setVisible(not _enabled)
end

--初始化玩家信息
function GameViewLayer:initUserInfo()
	tlog('GameViewLayer:initUserInfo')
    local parentNode = self.m_csbNode:getChildByName("Panel_center"):getChildByName("Image_right")
	parentNode = parentNode:getChildByName("Node_player")
	local myUser = self:getMeUserItem()
    --头像
    local imgHead = parentNode:getChildByName("imgHead")
    imgHead:removeAllChildren()
    local faceId = myUser.wFaceID
	local node = HeadNode:create(faceId)
	imgHead:addChild(node)
	node:setContentSize(cc.size(100,100))
	node:loadBorderTexture("game/yule/crash/res/GUI/crash_player_broad.png")
	node:setTouched(false)

    -- local pPathHead = string.format("client/res/public/Face%d.jpg", faceId)
    -- local pPathClip = "GUI/crash_txjc.png"
    -- g_ExternalFun.ClipHead(imgHead, pPathHead, pPathClip)
    parentNode:getChildByName("userName"):setString(myUser.szNickName)

	--玩家游戏币
	self.m_textUserCoint = parentNode:getChildByName("Image_money_bg"):getChildByName("betInfo_mymoney")
	self.m_textUserCoint._lastNum = 0
	self.m_textUserCoint._curNum = 0
	self.m_virtualSum = 0
	self.m_curNum = 0
	self.m_lastNum = 0
	self.m_lastScore = 0
	self.m_currScore = 0
	self:reSetUserInfo()
	local icon = parentNode:getChildByName("Image_money_bg"):getChildByName("crash_jinbi_icon_31")
    local currencyType = G_GameFrame:getServerKind()
    g_ExternalFun.setIcon(icon,currencyType)
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
	self.m_textUserCoint._lastNum = self.m_textUserCoint._curNum
	self.m_textUserCoint._curNum = self.m_scoreUser
	if _reduceNum == 0 then
		self.m_textUserCoint:stopAllActions()
		self:formatNumShow(self.m_textUserCoint, self.m_scoreUser)
	else
		self:updateGoldShow(self.m_textUserCoint)
	end
end

function GameViewLayer:formatNumShow(_node, _nums,isNotFormat)
	-- tlog('GameViewLayer:formatNumShow ', _nums)
	local formatMoney = _nums
	if isNotFormat == nil then
		local serverKind = G_GameFrame:getServerKind()
		formatMoney = g_format:formatNumber(_nums,g_format.fType.standard,serverKind)
	end
	_node:setString(formatMoney)
end

--初始化桌面下注
function GameViewLayer:initJetton()
	tlog('GameViewLayer:initJetton')
	self:initCurJettonNumInfo()
	self:initJettonBtnInfo()
end

--下注按钮
function GameViewLayer:initJettonBtnInfo()
	tlog('GameViewLayer:initJettonBtnInfo')
	local panel_betBtn = self.m_bottomNodeParent:getChildByName("Panel_betBtn")
	panel_betBtn:setTouchEnabled(false)
	self.m_jettonBtn = panel_betBtn:getChildByName("Button_bet")
	self.m_jettonBtn:setPressButtonMusicPath("")
	self:registerBtnEvent(self.m_jettonBtn, handler(self, self.onJettonButtonClicked))

	self.m_immediateStopBtn = panel_betBtn:getChildByName("Button_jump")
	self.m_immediateStopBtn:setTag(TAG_ENUM.BT_IMMEDIATE_STOP)
	self.m_immediateStopBtn:setVisible(false)
	self:registerBtnEvent(self.m_immediateStopBtn, handler(self, self.onButtonClickedEvent))

	self:resetJettonBtnEnabled(true, false)

	--自动下注按钮
	local betAreaBtn = panel_betBtn:getChildByName("Button_autoBet")
	betAreaBtn:getChildByName("Image_3"):setVisible(false)
	betAreaBtn:setTag(TAG_ENUM.BT_AUTOBET)
	betAreaBtn:addClickEventListener(handler(self, self.onButtonClickedEvent))
	self.m_autoBetArray = {autoBtn = betAreaBtn, isAuto = false}

	--下注门槛遮罩
	self.m_PanelLimit = self.m_csbNode:getChildByName("Panel_limit")
	--检测下注门槛
	self:checkJettonThreshold()
end

--自己的下注金额
function GameViewLayer:initCurJettonNumInfo()
	tlog('GameViewLayer:initCurJettonNumInfo')
	local panel_xiazhu = self.m_bottomNodeParent:getChildByName("Panel_xiazhu")
	self.m_betMoney = panel_xiazhu:getChildByName("Panel_edit"):getChildByName("Text_1")
	self:updateMyBetMoney(self.m_min_bet_money)
end

-- _bStart 是否开始游戏重设
-- 设置下注值，停止下注动画
function GameViewLayer:resetJettonNumInfo(_bStart)
	tlog('GameViewLayer:resetJettonNumInfo ', _bStart)
	local textArray = {self.m_text_betPeople, self.m_text_betMoney}
	for i, text in ipairs(textArray) do
		text:stopAllActions()
		local curNum = 0
		if _bStart then
			text._lastNum = 0
			text._curNum = 0
			self.m_virtualSum = 0
			self.m_curNum = 0
			self.m_lastNum = 0
			self.m_lastScore = 0
			self.m_currScore = 0
		else
			curNum = text._curNum
			text._lastNum = curNum
			if i == 1 then
				curNum = self.m_curNum
			elseif i == 2 then
				curNum = self.m_currScore
			end
		end
		local isNotFormat = nil
		if i == 1 then isNotFormat = true end
		self:formatNumShow(text, curNum,isNotFormat)
	end
end

function GameViewLayer:resetJettonBtnEnabled(_bVisible, _bEnable)
	tlog('GameViewLayer:resetJettonBtnEnabled ', _bVisible, _bEnable)
	self.m_jettonBtn:setVisible(_bVisible)
	self.m_jettonBtn:setEnabled(_bEnable)
	local btn_image = self.m_jettonBtn:getChildByName("Image_1")
	if _bEnable then
		btn_image:loadTexture("GUI/crash_btn_apostas1.png")
	else
		if self.m_isInGameEndStatus then
			--未下注，已到开奖时间
			--下过注会显示停止按钮
			btn_image:loadTexture("GUI/crash_btn_apostas2.png")
		else
			--下过注，还未到开奖时间
			btn_image:loadTexture("GUI/crash_btn_apostado.png")
		end
	end

	--如果没有下注，则开奖期间也能点击
	local _touchEnabled = _bEnable
	if self.m_curRoundSelfBetRate < 0 then
		_touchEnabled = true
	end

	--倍率处理
	local panel_beilv = self.m_bottomNodeParent:getChildByName("Panel_beilv")
	local btn_choosed = panel_beilv:getChildByName("Button_1")
	btn_choosed:setEnabled(_touchEnabled)
	local panel_edit = panel_beilv:getChildByName("Panel_edit")
	panel_edit:setTouchEnabled(_touchEnabled)
	if _touchEnabled then
		panel_edit:getChildByName("Text_1"):setTextColor(cc.c4b(255, 214, 50, 255))
	else
		panel_edit:getChildByName("Text_1"):setTextColor(cc.c4b(110, 112, 151, 255))
	end
	local btn_remove = panel_edit:getChildByName("Button_remove")
	btn_remove:setVisible(_touchEnabled and (self.m_curChoosedRate._rate_ ~= 0))

	--金额处理
	local panel_xiazhu = self.m_bottomNodeParent:getChildByName("Panel_xiazhu")
	btn_choosed = panel_xiazhu:getChildByName("Button_1")
	btn_choosed:setEnabled(_touchEnabled)
	panel_edit = panel_xiazhu:getChildByName("Panel_edit")
	panel_edit:setTouchEnabled(_touchEnabled)
	if _touchEnabled then
		panel_edit:getChildByName("Text_1"):setTextColor(cc.c4b(255, 214, 50, 255))
	else
		panel_edit:getChildByName("Text_1"):setTextColor(cc.c4b(110, 112, 151, 255))
	end
	btn_remove = panel_edit:getChildByName("Button_remove")
	btn_remove:setVisible(_touchEnabled and (self.m_betMoney._curNum ~= 0))

	if not _touchEnabled then
		self:removeChoosedNode()
	end
end

function GameViewLayer:setStopBtnEnabled(_bVisible, _bEnable)
	tlog('GameViewLayer:setStopBtnEnabled ', _bVisible, _bEnable)
	self.m_immediateStopBtn:setVisible(_bVisible)
	self.m_immediateStopBtn:setEnabled(_bEnable)
	local curFile = "GUI/crash_btn_cashout_1.png"
	if not _bEnable then
		curFile = "GUI/crash_btn_cashout_2.png"
	end
	self.m_immediateStopBtn:getChildByName("Image_1"):loadTexture(curFile)

	local _parentNode = self.m_panel_curve:getParent()
	_parentNode:getChildByName("Image_selfbet"):setVisible(_bVisible)

	self:dealWithStopBtnShow(self:getPlayerResultWin(true))
end

function GameViewLayer:dealWithStopBtnShow(_selfData)
	tlog("GameViewLayer:dealWithStopBtnShow", self.m_isInGameEndStatus, self.m_gameEndActionTime)
	local _parentNode = self.m_panel_curve:getParent()
	local image_selfbet = _parentNode:getChildByName("Image_selfbet")

	if self.m_immediateStopBtn:isVisible() and self.m_isInGameEndStatus then
		local curRate = -1
		if _selfData then
			curRate = _selfData.betCrash
		end
		if curRate == -1 then
			--刚进来是游戏结束的end状态，会触发这个
			curRate = self.m_curRoundSelfBetRate
		end
		if curRate == -1 then
			tlog("curRate is -1, it's an error value")
			return
		end
		local showWinMoney = function (_parentNode, _curRate)
			local winMoney = _parentNode:getChildByName("bet_winMoney")
			local winScore = math.floor(_curRate * self.m_betMoney._curNum + 0.5)
			local serverKind = G_GameFrame:getServerKind()
			winMoney:setString(g_format:formatNumber(winScore,g_format.fType.standard,serverKind))
		end
		local showWinTipNode = function (_parentNode, _curRate)
			_parentNode:getChildByName("bet_will_win"):setVisible(false)
			_parentNode:getChildByName("bet_wined_tip"):setVisible(true)
			local winTextNode = _parentNode:getChildByName("bet_wined_rate"):show()
			local rateText = g_ExternalFun.formatNumWithPeriod(_curRate, "X")
			winTextNode:setString(string.format("em %s", rateText))
		end
		if not self.m_gameEndActionTime then
			self.m_immediateStopBtn:setEnabled(false) --结算了就不能点了
			self.m_immediateStopBtn:getChildByName("Image_1"):loadTexture("GUI/crash_btn_cashout_2.png")
			--结算了
			if curRate == 0 then
				image_selfbet:setVisible(false)
			else
				if curRate > self.m_curCurveNum then
					image_selfbet:setVisible(false)
				else
					--已经开奖
					showWinTipNode(image_selfbet, curRate)
					showWinMoney(image_selfbet, curRate)
				end
			end
		else
			--开奖中
			if curRate == 0 or (curRate > self.m_curCurveNum) then
				--还未开奖
				image_selfbet:getChildByName("bet_will_win"):setVisible(true)
				image_selfbet:getChildByName("bet_wined_tip"):setVisible(false)
				image_selfbet:getChildByName("bet_wined_rate"):setVisible(false)
				showWinMoney(image_selfbet, self.m_curCurveNum)
			else
				self.m_immediateStopBtn:setEnabled(false)
				self.m_immediateStopBtn:getChildByName("Image_1"):loadTexture("GUI/crash_btn_cashout_2.png")
				--已经开奖
				showWinTipNode(image_selfbet, curRate)
				showWinMoney(image_selfbet, curRate)
			end
		end
	end
end

---------------------------------------------------------------------------------------
--倍率选择等按钮
function GameViewLayer:onRateMoneyChoosedBtnClick(_sender)
	tlog('GameViewLayer:onRateMoneyChoosedBtnClick')
	local tag = _sender:getTag()
	local pos = _sender:getParent():convertToWorldSpace(cc.p(_sender:getPosition()))
	if tag == TAG_ENUM.BT_CHOOSED_CRASH then
		local newPos = cc.p(pos.x + 3, pos.y + 40)
		local adaptPos = cc.p(-1 * newPos.x, -1 * newPos.y)
		local handler_1 = handler(self, self.updateTempRateShow)
		local handler_2 = handler(self, self.updateCurRateShow)
	    local _choosedNode = CrashChoosedNumNode:create(1, handler_1, self.m_scoreUser, adaptPos, handler_2,self.m_multipleConfig)
	    _choosedNode:addTo(self, 10)
	    _choosedNode:setName("ChoosedNode")
	    _choosedNode:setPosition(newPos)
	elseif tag == TAG_ENUM.BT_EDIT_CRASH then
		local newPos = cc.p(pos.x + _sender:getContentSize().width * 0.93, pos.y + 110)
		local adaptPos = cc.p(-1 * newPos.x, -1 * newPos.y)
		local handler_1 = handler(self, self.updateTempRateShow)
		local handler_2 = handler(self, self.updateCurRateShow)
	    local _editNode = CrashEnterWordNode:create(1, 1000, self.m_curChoosedRate._rate_, handler_1, adaptPos, handler_2)
	    _editNode:addTo(self, 10)
	    _editNode:setName("ChoosedNode")
	    _editNode:setPosition(newPos)
	elseif tag == TAG_ENUM.BT_REMOVE_CRASH then
		self:updateCurRateShow(0)
	elseif tag == TAG_ENUM.BT_CHOOSED_MONEY then
		local newPos = cc.p(pos.x + 3, pos.y + 40)
		local adaptPos = cc.p(-1 * newPos.x, -1 * newPos.y)
		local handler_1 = handler(self, self.updateTempMoneyShow)
		local handler_2 = handler(self, self.updateMyBetMoney)
	    local _choosedNode = CrashChoosedNumNode:create(2, handler_1, self.m_scoreUser, adaptPos, handler_2,self.m_betConfig)
	    _choosedNode:addTo(self, 10)
	    _choosedNode:setName("ChoosedNode")
	    _choosedNode:setPosition(newPos)
	elseif tag == TAG_ENUM.BT_EDIT_MONEY then
		local newPos = cc.p(pos.x + _sender:getContentSize().width * 0.63, pos.y + 110)
		local adaptPos = cc.p(-1 * newPos.x, -1 * newPos.y)
		local minNum = math.min(self.m_scoreUser, 99999999999999)
		local handler_1 = handler(self, self.updateTempMoneyShow)
		local handler_2 = handler(self, self.updateMyBetMoney)
	    local _editNode = CrashEnterWordNode:create(2, minNum, self.m_betMoney._curNum, handler_1, adaptPos, handler_2)
	    _editNode:addTo(self, 10)
	    _editNode:setName("ChoosedNode")
	    _editNode:setPosition(newPos)
	elseif tag == TAG_ENUM.BT_REMOVE_MONEY then
		self:updateMyBetMoney(0)
	end
end

--输入过程中修改倍率显示
function GameViewLayer:updateTempRateShow(_newRate, _str)
	self.m_curChoosedRate:setString(_str)
	self.m_curChoosedRate._rate_ = _newRate
end

--更新当前下注倍率
function GameViewLayer:updateCurRateShow(_newRate)
	if _newRate == nil then
		_newRate = self.m_curChoosedRate._rate_
	end
	local panel_edit = self.m_bottomNodeParent:getChildByName("Panel_beilv"):getChildByName("Panel_edit")
	local btn_remove = panel_edit:getChildByName("Button_remove")
	if _newRate ~= 0 then
		if _newRate < 1.01 then
			_newRate = 1.01
			showToast("O multiplicador mín de aposta é de 1,01 X")
		end
		self.m_curChoosedRate:setString(g_ExternalFun.formatNumWithPeriod(_newRate, "X"))
		btn_remove:setVisible(self.m_curRoundSelfBetRate < 0)
	else
		--倍率是0，不展示
		self.m_curChoosedRate:setString("")
		btn_remove:setVisible(false)
	end
	self.m_curChoosedRate._rate_ = _newRate
end

--更新我的下注额度
function GameViewLayer:updateTempMoneyShow(_betMoney)
	self:formatNumShow(self.m_betMoney, _betMoney)
	self.m_betMoney._curNum = _betMoney
end

function GameViewLayer:updateMyBetMoney(_betMoney)
	if _betMoney == nil then
		_betMoney = self.m_betMoney._curNum
	end
	if _betMoney ~= 0 and _betMoney < self.m_min_bet_money then
		_betMoney = self.m_min_bet_money
		showToast("A aposta mínima é de 1,00") --A aposta mín é de 10000 A aposta mínima é de
	end
	self:updateTempMoneyShow(_betMoney)
	local panel_edit = self.m_bottomNodeParent:getChildByName("Panel_xiazhu"):getChildByName("Panel_edit")
	local btn_remove = panel_edit:getChildByName("Button_remove")
	btn_remove:setVisible(_betMoney ~= 0 and self.m_curRoundSelfBetRate < 0)
end

function GameViewLayer:removeChoosedNode()
	local chooseNode = self:getChildByName("ChoosedNode")
	if chooseNode then
		chooseNode:removeEvent()
		chooseNode = nil
	end
end

--返回值代表自动投注按钮能不能打钩
-- _sender 有值代表要进行下注操作，没值代表仅进行判断
function GameViewLayer:onJettonButtonClicked(_sender)
	tlog('GameViewLayer:onJettonButtonClicked')
	if self.m_isInGameEndStatus then
		tlog('self.m_isInGameEndStatus is true, not enable click')
		return true
	end
	-- self:hideBetFailedTip()
	if self.m_scoreUser < self.m_betMoney._curNum then
		showToast(g_language:getString("game_tip_no_money"))
		return false
	end
	if self.m_betMoney._curNum < self.m_min_bet_money then
		tlog("onJettonButtonClicked selector error ", self.m_betMoney._curNum)
		showToast(g_language:getString("game_tip_bet_fail"))
		return false
	end
	if _sender then
		--下注
		self:getParentNode():sendUserBet(self.m_curChoosedRate._rate_, self.m_betMoney._curNum)
	end
	return true
end

--隐藏下注失败提示
function GameViewLayer:hideBetFailedTip()
	self.m_bottomNodeParent:getChildByName("Panel_beilv"):getChildByName("betInfo_tip"):setVisible(false)
	self.m_bottomNodeParent:getChildByName("Panel_xiazhu"):getChildByName("betInfo_tip"):setVisible(false)
end

function GameViewLayer:onButtonClickedEvent(_sender)
	local tag = _sender:getTag()
	tlog('GameViewLayer:onButtonClickedEvent ', tag)
	g_ExternalFun.playClickEffect()
	if tag == TAG_ENUM.BT_EXIT then
		self.m_btnList:setVisible(false)
		self:getParentNode():onQueryExitGame()
	elseif tag == TAG_ENUM.BT_SOUND then --音效
		GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble)
		self:flushMusicResShow(_sender, GlobalUserItem.bSoundAble)
	elseif tag == TAG_ENUM.BT_HELP then
		tlog('GameViewLayer:createHelpLayer')
		self.m_btnList:setVisible(false)
	    local _helpLayer = GameHelpLayer:create():addTo(self, 10)
	    _helpLayer:setPosition(display.width * 0.5 - g_offsetX, display.height * 0.5)
	elseif tag == TAG_ENUM.BT_HISTORY then
		self:getParentNode():getGameRecordReq()
	elseif tag == TAG_ENUM.BT_AUTOBET then
		print("自动下注：",self.m_autoBetArray.isAuto, self.m_curRoundSelfBetRate)
		if self.m_curRoundSelfBetRate <= -1 then --已经下注的就不判断状态了
			local retValue = self:onJettonButtonClicked() --取是否可以下注状态
			--非自动投注状态，身上金币不够本轮自动投注 or 身上金币不足最低投注筹码下限。取消自动投注
			if (not self.m_autoBetArray.isAuto) and (not retValue) then
				self:resetAutoBet()
				return
			end
		end
		self.m_autoBetArray.isAuto = not self.m_autoBetArray.isAuto
		self.m_autoBetArray.autoBtn:getChildByName("Image_3"):setVisible(self.m_autoBetArray.isAuto)
		self:checkAutoBetImmediately()
	elseif tag == TAG_ENUM.BT_IMMEDIATE_STOP then
		if self.m_curRoundSelfBetRate > -1 then
			local enableSend = false
			local myChairId = self:getMeUserItem().wChairID
			local curCurve = self.m_curCurveNum + 0.02
			if curCurve < 1.01 then
				curCurve = 1.01
			end
			for i, v in ipairs(self.m_playerArray or {}) do
				if v.chairId == myChairId then
					if v.betCrash == 0 or (v.betCrash > curCurve) then --没跑到当前刻度才可以停止
						enableSend = true
						self:getParentNode():stopBetCrashReq(myChairId, curCurve)
					end
				end
			end
		else
			-- showToast(g_language:getString("game_tip_not_bet1"))
		end
	else
		showToast(g_language:getString("game_tip_no_function"))
	end
end

function GameViewLayer:resetAutoBet()
	self.m_autoBetArray.autoBtn:getChildByName("Image_3"):setVisible(false)
	self.m_autoBetArray.isAuto = false
end

--勾选自动投注时，如果在下注阶段，且本轮没有投注过，立马自动投注
function GameViewLayer:checkAutoBetImmediately()
	tlog('checkAutoBetImmediately ', self.m_autoBetArray.isAuto, self.m_isInGameEndStatus)
	if self.m_autoBetArray.isAuto and (self.m_curRoundSelfBetRate <= -1) and (not self.m_isInGameEndStatus) then
		self:onJettonButtonClicked(true) --真正下注
	end
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
	tlog('GameViewLayer:onGetUserScore ', item.szNickName, item.lScore, item.wChairID, item.dwUserID, GlobalUserItem.dwUserID)
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
function GameViewLayer:reEnterStart(_totalSelfBet, _curSelfBetRate)
	tlog('GameViewLayer:reEnterStart ', _totalSelfBet, _curSelfBetRate)
	--获取玩家携带游戏币
	self:reSetUserInfo(_totalSelfBet)
	self.m_curRoundSelfBetRate = _curSelfBetRate
	self.m_isInGameEndStatus = false
	self.m_gameEndActionTime = false
	--下注
	self:resetJettonBtnEnabled(true, self.m_curRoundSelfBetRate <= -1)
	self:setStopBtnEnabled(false, false)
	self:removeWinNodeTip()
	self:showBombNodeAction(false, false)
end

--重连回来游戏正在结算状态
function GameViewLayer:reEnterEnd(_enabled, _curSelfBetRate, _timeLeft)
	tlog('GameViewLayer:reEnterEnd ', _enabled, _curSelfBetRate)
	self.m_curRoundSelfBetRate = _curSelfBetRate
	self:stopEndSoundEffect()
	self:reSetUserInfo()

	--检测下注门槛
	self:checkJettonThreshold()

	self.m_isInGameEndStatus = true
	self.m_gameEndActionTime = (_timeLeft == 0)
	local hasBet = self.m_curRoundSelfBetRate > -1
	self:resetJettonBtnEnabled(not hasBet, false)
	self:setStopBtnEnabled(hasBet, hasBet and _enabled and (_timeLeft == 0))
	if self.m_gameEndActionTime then
		self:showBombNodeAction(false, false)
	end
	self:playRocketFlyEffect(true)
end

--断线重连更新玩家已下注
function GameViewLayer:reEnterUserBet(llScore, _betCrash)
	tlog('GameViewLayer:reEnterUserBet ', llScore, _betCrash)
	self:removeChoosedNode()
	-- self:hideBetFailedTip()
	if llScore <= 0 then
		--小于0的时候不处理数值显示
		return
	end
	self:updateMyBetMoney(llScore)
	self:updateCurRateShow(_betCrash)
	self:stopRocketFlyEffect()
end

--游戏开始
function GameViewLayer:onGameStart()
	tlog('GameViewLayer:onGameStart')
	--获取玩家携带游戏币
	self.m_crashBgNode:resetNodeShow()
	self:removeWinNodeTip()
	self:stopUpdateCall()
	self:reSetUserInfo()
	-- self:hideBetFailedTip()
	self.m_isInGameEndStatus = false
	self.m_gameEndActionTime = false
	self.m_curRoundSelfBetRate = -1

	--检测下注门槛
	self:checkJettonThreshold()

	--下注
	self:resetJettonBtnEnabled(true, true)
	self:setStopBtnEnabled(false, false)
	self:resetJettonNumInfo(true)
	self:showBombNodeAction(false, false)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	-- g_ExternalFun.playSoundEffect("START_W.mp3")
	self:getDataMgr():resetAllUserBetScore()
	self.m_scrollView:jumpToTop()
	self:updatePlayerView(0, true, true)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
		tlog("start game, self.m_autoBetArray.isAuto ", self.m_autoBetArray.isAuto)
		if self.m_autoBetArray.isAuto then
			-- if self.m_scoreUser <= 0 then
			-- 	tlog("self.m_scoreUser <= 0, disable auto bet")
			-- 	self:onButtonClickedEvent(self.m_autoBetArray.autoBtn)
			-- else
			local curNum = self.m_betMoney._curNum
			if curNum <= self.m_scoreUser then
				--携带的金币大于自动投注额度 正常投注
				self:onJettonButtonClicked(true)
			else
				--携带的金币不够本次自动投注或者金币不足，重置自动投注
				showToast(g_language:getString("game_tip_no_money"))
				self:resetAutoBet()
			end
			-- end
		end
	end)))
	self:stopRocketFlyEffect()
end

--游戏开奖
function GameViewLayer:onGetGameOpen()
	tlog('GameViewLayer:onGetGameOpen')
	self:stopEndSoundEffect()
	self.m_isInGameEndStatus = true
	self.m_gameEndActionTime = true
	local hasBet = self.m_curRoundSelfBetRate > -1
	self:resetJettonBtnEnabled(not hasBet, false)
	self:setStopBtnEnabled(hasBet, true)
	self:resetJettonNumInfo(false)
	-- self:hideBetFailedTip()
	self:showBombNodeAction(false, false)
end

--游戏结束
function GameViewLayer:onGetGameEnd()
	self.m_gameEndActionTime = false
	local hasBet = self.m_curRoundSelfBetRate > -1
    self:setStopBtnEnabled(hasBet, false)
	self:resetJettonBtnEnabled(not hasBet, false) --下0注的时候会用到
	self.m_curRoundSelfBetRate = -1
    -- self:hideBetFailedTip()
    if not self._rollActionId then
    	--可能是开0导致结果来了还没启动
    	tlog('self._rollActionId here zero')
    	self.m_actionNode:stopAllActions()
    	self:delayStartRoll()
    end
end

--更新用户下注
function GameViewLayer:onGetUserBet(cmd_placebet )
	tlog("GameViewLayer:onGetUserBet")
	if not cmd_placebet then
		return
	end
	local wUser = cmd_placebet.wChairID
	--播放一个数字跳动动画
    if self:isMeChair(wUser) then
		self.m_curRoundSelfBetRate = cmd_placebet.cbBetCrash
		self:resetJettonBtnEnabled(true, false)
    	self:updateMyBetMoney(cmd_placebet.lBetScore)
    	self:updateCurRateShow(cmd_placebet.cbBetCrash)
		self:updateUserScore(cmd_placebet.lBetScore)
		g_ExternalFun.playSoundEffect("crash_player_bet.mp3")
	end
    self.m_text_betMoney._lastNum = self.m_text_betMoney._curNum
    self.m_text_betMoney._curNum = self.m_text_betMoney._curNum + cmd_placebet.lBetScore

	self.m_lastScore = self.m_currScore or 0
	self.m_currScore = self.m_text_betMoney._curNum + self.m_lastNum * 800
	self:getDataMgr():updateUserBetScore(cmd_placebet)

    self.m_text_betMoney:stopAllActions()
	self:formatNumShow(self.m_text_betMoney, self.m_lastScore)
    local loopNums = 20 -- math.ceil(4.8 / 0.1) --每0.05秒更新一次
    local gapNums = math.ceil((self.m_currScore - self.m_lastScore) / loopNums)
	self:addGoldNumsShowInterval(self.m_text_betMoney, self.m_lastScore, self.m_currScore, gapNums)
end

--更新用户下注失败，没调用到
function GameViewLayer:onGetUserBetFail(_cmdData)
	tlog('GameViewLayer:onGetUserBetFail')
	if nil == _cmdData then
		return
	end
	--播放一个提示？
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
	--资源释放
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

	self:getDataMgr():removeAllUser()
end

function GameViewLayer:updateClock(tag, left)
	tlog('GameViewLayer:updateClock ', tag, left)
    if tag == g_var(cmd).kGAMEPLAY_COUNTDOWN then --下注倒计时
        if left == 5 then
			self.m_endSoundId = g_ExternalFun.playSoundEffect("crash_timedown_5.mp3")
			tlog('self.m_endSoundId is ', self.m_endSoundId)
        end
	end
end

function GameViewLayer:stopEndSoundEffect()
	tlog('GameViewLayer:stopEndSoundEffect ', self.m_endSoundId)
	if self.m_endSoundId then
		g_ExternalFun.stopEffect(self.m_endSoundId)
		self.m_endSoundId = nil
	end
end

function GameViewLayer:stopRocketFlyEffect()
	tlog('GameViewLayer:stopRocketFlyEffect ', m_flySoundId)
	if self.m_flySoundId then
		g_ExternalFun.stopEffect(self.m_flySoundId)
		self.m_flySoundId = nil
	end
	self.m_actionNode_1:stopAllActions()
end

--播放火箭飞行音效
function GameViewLayer:playRocketFlyEffect(_playFly)
	tlog('GameViewLayer:playRocketFlyEffect ', _playFly)
	self:stopRocketFlyEffect()
	if _playFly then
		--飞行音效只播一遍
		self.m_flySoundId = g_ExternalFun.playSoundEffect("crash_rocket_fly.mp3")
	else
		--播放开始继续播飞行
	    self.m_flySoundId = g_ExternalFun.playSoundEffect("crash_rocket_start.mp3")
		self.m_actionNode_1:runAction(cc.Sequence:create(cc.DelayTime:create(5.2), cc.CallFunc:create(function ()
			tlog('here start play')
			self:playRocketFlyEffect(true)
		end)))
	end
end

--显示当前状态的倒计时提示文本
function GameViewLayer:showTimerTip(tag, time, _isReenter)
	tlog('GameViewLayer:showTimerTip ', tag, time, _isReenter, self.m_endIndex)
	tag = tag or -1
	local _parentNode = self.m_panel_curve:getParent()
	_parentNode:getChildByName("Image_kaijiang"):setVisible(false) --开奖过程中展示的节点
	local jettonShowNode = _parentNode:getChildByName("Image_xiazhu"):hide() --下注时时展示的倒计时节点
	self.m_sliceTime = 0
	if tag == g_var(cmd).kGAMEPLAY_COUNTDOWN then --下注状态
		jettonShowNode:setVisible(true)
		local bgFile = jettonShowNode:getChildByName("FileNode_bg")
		bgFile:stopAllActions()
		-- bgFile:getChildByName("Particle_1"):start()
	    local actTimeLine = cc.CSLoader:createTimeline("UI/Node_daojishi.csb")
	    actTimeLine:gotoFrameAndPlay(0, true)
	    bgFile:runAction(actTimeLine)

		local text_1 = jettonShowNode:getChildByName("beilv_text")
		text_1:setAnchorPoint(cc.p(0.5,0.5))
		text_1:setPosition(cc.p(0,0))
		text_1.curText = 0
		self.m_leftTime = time
		if self.m_rollTimerId == nil then
		    self.m_rollTimerId = g_scheduler:scheduleScriptFunc(function (dt)
		    	local curLeftTime = self.m_leftTime
		    	if curLeftTime < 0 then
		    		curLeftTime = 0
				    self:playRocketFlyEffect(false)
			    	self:stopRollingCall()
			    	if self.m_curRoundSelfBetRate <= -1 then
			    		--时间到了，没下注的先不让下注
				    	self.m_isInGameEndStatus = true
				    	self:resetJettonBtnEnabled(true, false)
				    end
		    	end
		    	local showText = math.ceil(curLeftTime)
		    	text_1:setString(showText)
		    	if text_1.curText ~= showText then
		    		text_1.curText = showText
		    		text_1:stopAllActions()
		    		text_1:setScale(1.5)
		    		local scale = cc.ScaleTo:create(0.5, 1)
		    		text_1:runAction(scale)
		    	end
		    	self.m_leftTime = self.m_leftTime - dt
		    	self:updatePlayerView(dt, false, true)
		    end, 0, false)
		end
		self:setCurveRollShow(nil, nil, false)
		self:stopUpdateCall() --做个保险，停掉画线定时器
	else
		self:stopRollingCall()
	end
end

--new
--滚动需要的数据
function GameViewLayer:initRollData()
	tlog("GameViewLayer:initRollData")
	self.m_curCostTime = 0			--从结束消息到目前已经消耗的时间
	self.m_sliceTime = 0			--用于累计0.2s更新玩家列表
	self.m_curCurveNum = 0			--当前曲线进度值
end

--初始化中间的曲线展示模块
function GameViewLayer:initWithCurveRollItem()
	tlog('GameViewLayer:initWithCurveRollItem')
	local panel_center = self.m_csbNode:getChildByName("Panel_center")
	panel_center:setTouchEnabled(false)
	local image_left_bg = panel_center:getChildByName("Image_left_bg")
	self.m_timeItem = image_left_bg:getChildByName("Text_down_1"):hide()
	self.m_rateItem = image_left_bg:getChildByName("Image_1"):hide()
	local panel_1 = image_left_bg:getChildByName("Panel_1")
	self.m_panel_curve = panel_1
	panel_1:setTouchEnabled(false)
	panel_1:setClippingEnabled(true)
	local image_icon = panel_1:getChildByName("Image_icon"):show()
    local actTimeLine = cc.CSLoader:createTimeline("UI/crash_penhuo.csb")
    actTimeLine:gotoFrameAndPlay(0, true)
    image_icon:runAction(actTimeLine)
    self.m_image_icon = image_icon
    --预先计算好角度的sin和cos值
    self.m_image_icon.sinNum = math.sin(math.rad(rocketRotation))
    self.m_image_icon.cosNum = math.cos(math.rad(rocketRotation))

	self:setCurveRollShow(nil, nil, true)

	self.m_bombNode = image_left_bg:getChildByName('CrashNode')
	self.m_bombNode:setVisible(false)
	self:initProgressTimer(image_left_bg)
end

--爆炸节点展示
-- 是否完全播放动画
function GameViewLayer:showBombNodeAction(_visible, _totalPlay)
	self.m_bombNode:setVisible(_visible)
	if _visible then
	    local actTimeLine = cc.CSLoader:createTimeline("UI/crash_baozha.csb")
	    if _totalPlay then
		    actTimeLine:gotoFrameAndPlay(0, false)
		else
		    actTimeLine:gotoFrameAndPlay(61, 62, false)
		end
	    self.m_bombNode:runAction(actTimeLine)
	end
end

--初始化时间展示
function GameViewLayer:initProgressTimer(_parentNode)
	_parentNode:getChildByName("Image_kaijiang"):setVisible(false) --开奖过程中展示的节点
	_parentNode:getChildByName("Image_xiazhu"):setVisible(false) --下注时时展示的倒计时节点
	_parentNode:getChildByName("Image_selfbet"):setVisible(false) --自己下注信息节点
	self.m_tipPanel = _parentNode:getChildByName("Image_tip"):hide()
end

--根据总时间和总倍数显示曲线面板
--_isInit 初始化的时候创建第一条线和第一个0s，后续不会变动
function GameViewLayer:setCurveRollShow(_totalTime, _totalRate, _isInit)
	-- tlog('GameViewLayer:setCurveRollShow ', _totalTime, _totalRate)
	if _totalTime == nil then
		--火箭停止时在左下方展示
		self.m_image_icon:setVisible(true)
		self.m_image_icon:setPosition(180, 125)
		self.m_image_icon:setRotation(0)

		local line = self.m_panel_curve:getChildByName("Image_line")
		self:setLineContentSize(line, 60)
		line:setVisible(false)
	end
    if  _totalTime == nil or _totalTime < 5 then
        _totalTime = 5
    end
    if  _totalRate == nil or _totalRate < 1.4 then
        _totalRate = 1.4
    end
	local timeArr, timeFactor = self:getDataMgr():getNeedShowTimeNums(_totalTime)
	local rateArr, rateFactor = self:getDataMgr():getNeedShowRateNums(_totalRate)
	for i, v in ipairs(self.m_panel_curve:getChildren()) do
		local name = v:getName()
		if name ~= "Image_line" and name ~= "Image_icon" and name ~= "Image_line_1" and name ~= "Time_1" then
			v:setVisible(false)
		end
	end
	for i, v in ipairs(timeArr) do
		if (i == 1 and _isInit) or (i ~= 1) then
			local textName = string.format("TimeText%d", i)
			local timeText = self.m_panel_curve:getChildByName(textName)
			if not timeText then
				timeText = self.m_timeItem:clone():show()
				timeText:addTo(self.m_panel_curve)
				timeText:setName(textName)
			end
			timeText:setVisible(true)
			timeText:setPosition(downOriginPosX + (Total_Width / _totalTime) * v, downNodePosY)
			timeText:setString(string.format("%ds", v))
			if i == 1 then
				timeText:setName("Time_1")
			end
		end
	end
	for i, v in ipairs(rateArr) do
		if (i == 1 and _isInit) or (i ~= 1) then
			local textName = string.format("RateText%d", i)
			local rateImage = self.m_panel_curve:getChildByName(textName)
			if not rateImage then
				rateImage = self.m_rateItem:clone():show()
				rateImage:addTo(self.m_panel_curve)
				rateImage:setName(textName)
			end
			rateImage:setVisible(true)
			rateImage:setPosition(leftNodePosX, leftOriginPosY + (Total_Height / (_totalRate - 1)) * (v - 1))
			local text_1 = rateImage:getChildByName("Text_1")
			local v1, v2 = math.modf(v)
			if v2 == 0 then
				text_1:setString(string.format("x%d", v))
			else
				text_1:setString(string.format("x%.2f", v))
			end
			if i == 1 then
				rateImage:setName("Image_line_1")
			end
		end
	end
end

--开始滚动
-- _useTime 使用掉的时间，重连使用
function GameViewLayer:startRoll(_useTime)
	tlog('GameViewLayer:startRoll ', _useTime)
	self.m_endIndex = 100000000 --赋一个超大的值，真正的值等end消息过来重设
	--一共滚动大约8秒钟
	self:stopUpdateCall()
	if _useTime then
		self.m_curCostTime = _useTime
	end
	self.m_actionNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function ()
		self:delayStartRoll()
	end)))
end

--由于改了机制，从服务器发开奖到end阶段可能会存在误差，所以每次开奖滚动延迟0.2s
function GameViewLayer:delayStartRoll()
	self:removeWinNodeTip()
	self.m_betArrayRate = self:getDataMgr():getAllUserBetByRate() or {}
	if self.m_curCostTime ~= 0 then
		--重连除去已经飘过的
		local _curNum = math.pow((self.m_curCostTime / self.m_calculateFactory), 2) + 1
		local length = #self.m_betArrayRate
		tlog('delayStartRoll origin length = ', length)
		for i = length, 1, -1 do
			local data = self.m_betArrayRate[i]
			if data.betCrash < _curNum and data.betCrash ~= 0 then
				table.remove(self.m_betArrayRate, i)
			end
		end
		if _curNum >= self.m_endIndex then
			--重连进来已经结算了
			self:showBombNodeAction(true, false)
		end
	end
	tdump(self.m_betArrayRate, "self.m_betArrayRate", 10)
	self.m_image_icon:setVisible(true)
	self.m_image_icon:setRotation(-1 * rocketRotation)
	self.m_panel_curve:getChildByName("Image_line"):setVisible(true)
    self._rollActionId = g_scheduler:scheduleScriptFunc(handler(self,self.rollActionTimer), 0, false)
    self:rollActionTimer(0)
end

--滚动事件
function GameViewLayer:rollActionTimer(dt)
	--timerount = sqrt(m_openNum - 1)* m_StepTime --计算公式
	self.m_curCostTime = self.m_curCostTime + dt
	local _curNum = math.pow((self.m_curCostTime / self.m_calculateFactory), 2) + 1
	-- local _curNum = math.pow((self.m_curCostTime / 8), 2) + 1
	local _endStatus = false
	if _curNum >= self.m_endIndex then
		tlog("self.m_curCostTime ", self.m_curCostTime, _curNum, self.m_endIndex)
		_curNum = self.m_endIndex
		self.m_curCurveNum = _curNum
		-- self.m_curCostTime = self.m_totalBetTime
		self:stopActionCall()
		self:updateRollResult()
		_endStatus = true
		if dt ~= 0 or (dt == 0 and self.m_endIndex == 1) then --非首次进来结算了，完整播放动画
			self:showBombNodeAction(true, true)
		end
	end
	self.m_curCurveNum = _curNum
	self:setCurveRollShow(self.m_curCostTime, _curNum, false)
	self:drawCurveLine(self.m_curCostTime, _curNum, _endStatus)
	self:updateCurNumShow(_curNum)
	self:updatePlayerView(dt, _endStatus, false) --结束后要直接刷新一次
	self.m_crashBgNode:moveBgAction()
end

--直接使用直线的
function GameViewLayer:drawCurveLine(_curCostTime, _curNum, _endStatus)
	if _curCostTime > 5 then
		_curCostTime = 5 --计算最大长度使用
	end
    local p1 = {x = downOriginPosX, y = leftOriginPosY}
	local posx = downOriginPosX + ((Total_Width - 20) / 5) * _curCostTime
	local posy = leftOriginPosY + ((Total_Height - 75) / 5) * _curCostTime
	local p2 = {x = posx, y = posy}
	local lineLength = cc.pGetDistance(p1, p2)
	local lineNode = self.m_panel_curve:getChildByName("Image_line")
	self:setLineContentSize(lineNode, lineLength)

	--计算线另外一端的位置
	local newPosx = 100 + self.m_image_icon.cosNum * lineLength
	local newPosy = 45 + self.m_image_icon.sinNum * lineLength
	-- tlog('newPosy ', newPosx, newPosy, lineLength)
	self.m_image_icon:setPosition(newPosx, newPosy)
	if _endStatus then
		-- self.m_bombNode:setPosition(p2.x, p2.y + 40)
		self.m_bombNode:setPosition(newPosx, newPosy + 40)
		self.m_image_icon:setVisible(false)
		g_ExternalFun.playSoundEffect("crash_rocket_crash.mp3")
		self:stopRocketFlyEffect()
	end
end

function GameViewLayer:setLineContentSize(_lineNode, _sizeLength)
	_lineNode:setContentSize(cc.size(_sizeLength, 53))
	local length = math.max(_sizeLength - 20, 0)
	_lineNode:getChildByName("Image_point"):setPositionX(length)
end

--画bezier曲线的
function GameViewLayer:drawCurveLine_old(_curCostTime, _curNum)
	self.m_panel_curve:removeChildByName("DrawNode") 	--每次绘制都得重新创建
    local p1 = {x = downOriginPosX, y = leftOriginPosY}
    local p2,p3
    local lineNums = 0
	if _curCostTime <= 5 then
		local posx = downOriginPosX + (Total_Width / 5) * _curCostTime
		local posy = leftOriginPosY + ((Total_Height - 30) / 5) * _curCostTime
		p2 = {x = posx, y = posy}
		p3 = p2
		lineNums = 1
	elseif _curCostTime <= 6 then
		local posx = downOriginPosX + Total_Width
		local posy = leftOriginPosY + (Total_Height - 30) + (_curCostTime - 5) * 30
		p2 = {x = posx, y = posy}
		p3 = p2
		lineNums = 1
	else
		local posx = downOriginPosX + Total_Width
		local posy = leftOriginPosY
		local curLine = self.m_centerBottomLine - ((_curCostTime - 6) * 5)
		-- tlog('curLine is ', curLine, ((_curCostTime - 6)), posx, posy)
		if curLine <= 0 then
			p2 = {x = posx, y = posy}
		else
			local newPosx = posx - math.cos(self.m_lineAngle) * curLine
			local newPosy = posy + math.sin(self.m_lineAngle) * curLine
			-- tlog("newPosx, newPosy ", newPosx, newPosy)
			p2 = {x = newPosx, y = newPosy}
		end
		p3 = {x = posx, y = posy + Total_Height}
		lineNums = 200
	end
	self.m_image_icon:setPosition(p3)
	local node = cc.DrawNode:create(5)
    node:setName("DrawNode")
    self.m_panel_curve:addChild(node, 10)
    node:drawQuadBezier(p1, p2, p3, lineNums, cc.c4f(1, 0, 0, 1))

	--依据贝塞尔曲线,算出向量角度，就是火球的角度
	local angle_new =  cc.pGetAngle(p3,p2)
	local rotate_new = angle_new*180/math.pi
	self.m_image_icon:setRotation(rotate_new * 2 + 15)
end

function GameViewLayer:updateCurNumShow(_curNum)
	local _parentNode = self.m_panel_curve:getParent()
	local kaijiangNode = _parentNode:getChildByName("Image_kaijiang")
	kaijiangNode:setVisible(true)
	local textNode = kaijiangNode:getChildByName("beilv_text")
	textNode:setString(g_ExternalFun.formatNumWithPeriod(_curNum, "X"))
	local ciseWidth = math.max(textNode:getContentSize().width + 135, 490)
	if kaijiangNode:getContentSize().width <= ciseWidth then
		kaijiangNode:setContentSize(cc.size(ciseWidth, 109))
	end

	local index = 0
	local length = #self.m_betArrayRate
	for i = length, 1, -1 do
		local data = self.m_betArrayRate[i]
		if data.betCrash <= _curNum and data.betCrash ~= 0 then
			local itemNode = self.m_tipPanel:clone():show()
			local strFile = "GUI/crash_hjsk_zdk.png"
			if data.betCrash >= 2 then
				strFile = "GUI/crash_hjsk_ldk.png"
			end
			itemNode:loadTexture(strFile)
			itemNode:setName("itemNode")
			itemNode:addTo(_parentNode, 10)
			-- local imageIcon = self.m_panel_curve:getChildByName("Image_icon")
			-- local pos = imageIcon:getParent():convertToWorldSpace(cc.p(imageIcon:getPosition()))
			-- self.m_btnList:convertToNodeSpace(touch:getLocation())
			local posx, posy = self.m_image_icon:getPosition()
			itemNode:setPosition(posx + math.random(-20, 20), posy + math.random(-20, 20))
	        local formatName, isShow = g_ExternalFun.GetFixLenOfString(data.userName, 150, "arial", 24)
	        if formatName == nil then
	        	formatName = ""
	        end
	        itemNode:getChildByName("text_name"):setString(isShow and formatName or (formatName .. "..."))
			itemNode:getChildByName("text_rate"):setString(g_ExternalFun.formatNumWithPeriod(data.betCrash, "X"))
			itemNode:setVisible(false)
			local delay = cc.DelayTime:create(index * 0.1)
			local delay1 = cc.DelayTime:create(0.3)
			local moveBy = cc.MoveBy:create(0.8, cc.p(-50, -200))
			local fadeout = cc.FadeOut:create(0.8)
			local spawn = cc.Spawn:create(moveBy, fadeout)
			itemNode:runAction(cc.Sequence:create(delay, cc.Show:create(), delay1, spawn, cc.RemoveSelf:create()))
			table.remove(self.m_betArrayRate, i)
			index = index + 1
			if self:isMeChair(data.chairId) then
				local image_selfbet = _parentNode:getChildByName("Image_selfbet")
				local bet_winMoney = image_selfbet:getChildByName("bet_winMoney")
				local originPos = bet_winMoney:getParent():convertToWorldSpace(cc.p(bet_winMoney:getPosition()))
				originPos = cc.p(originPos.x + bet_winMoney:getContentSize().width * 0.5, originPos.y)
				local dstPos = cc.p(self.m_textUserCoint:getPosition())
				dstPos = self.m_textUserCoint:getParent():convertToWorldSpace(cc.p(dstPos))
				dstPos = cc.p(dstPos.x + self.m_textUserCoint:getContentSize().width * 0.5, dstPos.y)

				if not self.m_coinNodeArray then
					self:getCoinNode()
				end
				local coinArrLength = #self.m_coinNodeArray
				for i, v in ipairs(self.m_coinNodeArray) do
					v:setPosition(originPos)
					local delay_coin = cc.DelayTime:create(i * 0.018)
				    local bezierPoint = {
				        cc.p(originPos.x, originPos.y),
				        cc.p(originPos.x + 500, originPos.y + 300),
				        cc.p(dstPos.x, dstPos.y)
				    }
				    local move = cc.EaseInOut:create(cc.BezierTo:create(1.0, bezierPoint), 1)
					local show = cc.Show:create()
					local hide = cc.Hide:create()
					v:runAction(cc.Sequence:create(delay_coin, show, move, hide, cc.CallFunc:create(function (t, p)
						t:setPosition(p.originPos)
						if p.index == p.coinArrLength then
							local winMoney = math.floor(p.data.betScore * p.data.betCrash + 0.5)
							self:updateUserScore(-1 * winMoney)
						elseif p.index == 1 then
							self.m_addCoinNode:setVisible(true)
						    local actTimeLine = cc.CSLoader:createTimeline("UI/Node_gerenxinxikuangdonghua.csb")
						    actTimeLine:gotoFrameAndPlay(0, false)
					        actTimeLine:setLastFrameCallFunc(function()
					        	self.m_addCoinNode:stopAllActions()
					        	self.m_addCoinNode:setVisible(false)
						    end)
						    self.m_addCoinNode:runAction(actTimeLine)								
						end
					end, {data = data, originPos = originPos, index = i, coinArrLength = coinArrLength})))
				end
				g_ExternalFun.playSoundEffect("crash_win_coin.mp3")

				local winTip = image_selfbet:getChildByName("bet_wined_tip")
				local scale1 = cc.ScaleTo:create(0.1, 1.2)
				local scale2 = cc.ScaleTo:create(0.1, 0.9)
				local scale3 = cc.ScaleTo:create(0.1, 1.1)
				local scale4 = cc.ScaleTo:create(0.1, 1.0)
				winTip:runAction(cc.Sequence:create(scale1, scale2, scale3, scale4))
			end
		end
	end
end

--获取金币
function GameViewLayer:getCoinNode()
	self.m_coinNodeArray = {}
	for i = 1, 8 do
		local coinImage = ccui.ImageView:create("GUI/crash_jinbi.png")
		self:addChild(coinImage)
		coinImage:setVisible(false)
		table.insert(self.m_coinNodeArray, coinImage)
	end
end

function GameViewLayer:removeWinNodeTip()
	local _parentNode = self.m_panel_curve:getParent()
	for i, v in ipairs(_parentNode:getChildren()) do
		if v:getName() == "itemNode" then
			v:removeFromParent()
		end
	end
	self.m_betArrayRate = {}
end

--画线结束后更新结果展示
function GameViewLayer:updateRollResult()
	tlog('GameViewLayer:updateRollResult ', self.m_curCurveNum)
	self.m_gameEndActionTime = false
	self:updateHistoryNode()
	--更新玩家金币
	-- self:reSetUserInfo()
end

--获取此时玩家当局下注结果是否赢了
-- _dirGet 获取玩家下注信息，不管输赢
function GameViewLayer:getPlayerResultWin(_dirGet)
	if _dirGet == nil then
		_dirGet = false
	end
	for i, data in ipairs(self.m_playerArray) do
		--找到自己
		if self:isMeChair(data.chairId) then
			if (self.m_curCurveNum >= data.betCrash and data.betCrash ~= 0) or _dirGet then
				return data
			end
			break
		end
	end
	return nil
end

--游戏结束曲线刷新定时器
function GameViewLayer:stopActionCall()
	if self._rollActionId ~= nil then
		g_scheduler:unscheduleScriptEntry(self._rollActionId)
		self._rollActionId = nil
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
	self:stopActionCall()
	if self.m_actionNode then
		self.m_actionNode:stopAllActions()
	end
end
--
function GameViewLayer:getOnline()
	--获取在线人数
	local onlineCount = g_onlineCount:getOnlineCount(GlobalUserItem.roomMark)
	self.m_onlineCount = math.modf(onlineCount/2)
	return self.m_onlineCount
end

function GameViewLayer:updateGoldShow(_nodeText, _gapNums,isNotFormat,isVirtual)
    _nodeText:stopAllActions()
    local lastNum = _nodeText._lastNum
    local curNum = _nodeText._curNum
	self:formatNumShow(_nodeText, lastNum,isNotFormat)
    local loopNums = 20 -- math.ceil(4.8 / 0.1) --每0.05秒更新一次
    local gapNums = _gapNums and _gapNums or math.ceil((curNum - lastNum) / loopNums)
    tlog('GameViewLayer:updateGoldShow ', lastNum, curNum, gapNums)
	if isVirtual and curNum > 15 then
		self.m_virtualSum = self.m_virtualSum + 1
		if self.m_virtualSum >= 20 then 
			self.m_virtualSum = 20 
		end
		local onlineCount = self:getOnline()
		print(curNum,onlineCount)

		self.m_curNum = self.m_curNum or 0
		self.m_lastNum = self.m_curNum
		if self.m_curNum < 15 then
			self.m_lastNum = 15
		end
		self.m_curNum = curNum + math.modf((onlineCount/20)*self.m_virtualSum)
		print(self.m_curNum)
		if self.m_curNum < self.m_lastNum then
			return
		end
		lastNum = self.m_lastNum
		curNum = self.m_curNum
	end
	print(self.m_lastNum,curNum,self.m_virtualSum)
	self:addGoldNumsShowInterval(_nodeText, lastNum, curNum, gapNums,isNotFormat)
end

function GameViewLayer:addGoldNumsShowInterval(_node, _srcNums, _dstNums, _addNums,isNotFormat)
	-- tlog('GameViewLayer:addGoldNumsShowInterval')
    local nowNums = _srcNums + _addNums
    if nowNums > _dstNums then
        nowNums = _dstNums
		self:formatNumShow(_node, nowNums,isNotFormat)
        return
    end
	self:formatNumShow(_node, nowNums,isNotFormat)
    _node:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function (_target, _params)
        self:addGoldNumsShowInterval(_params.node, _params.srcNums, _params.dstNums, _params.addNums,_params.isNotFormat)
    end, {node = _node, srcNums = nowNums, dstNums = _dstNums, addNums = _addNums,isNotFormat = isNotFormat})))
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
	local historyNode = self.m_csbNode:getChildByName("Panel_center"):getChildByName("FileNode_lishijilu")
	local panel = historyNode:getChildByName("Panel_1")
	panel:removeAllChildren()
	local count = 0
	local totalCount = _cmdData.openNumCount
	if totalCount > 0 then
		local minNum = totalCount - (Total_History_Node - 1)
		if minNum < 1 then
			minNum = 1
		end
		local firstTag = totalCount --初始tag值，越新的记录值越大(在右边)
		if firstTag > Total_History_Node then
			firstTag = Total_History_Node
		end
		for i = totalCount, minNum, -1 do
	    	local itemNode = CrashItemNode:create(_cmdData.openNum[1][i] / 100)
	    	itemNode:setPosition(970 - (totalCount - i) * 130, 40)
	    	panel:addChild(itemNode)
			itemNode:showFlagNew(i==totalCount)
	    	itemNode:setTag(firstTag - count)
	    	count = count + 1
		end
	end
	panel._curCount_ = count
end

function GameViewLayer:updateHistoryNode()
	local historyNode = self.m_csbNode:getChildByName("Panel_center"):getChildByName("FileNode_lishijilu")
	local panel = historyNode:getChildByName("Panel_1")
	--新增一个
	if panel._curCount_ then --刚进入为end状态，剩余时间为0(实际还有2秒的结果展示时间)会触发这个nil判断
		local itemNode = CrashItemNode:create(self.m_endIndex)
		itemNode:setPosition(1100, 40)  --970+130
		panel:addChild(itemNode)
		panel._curCount_ = panel._curCount_ + 1
		itemNode:setTag(panel._curCount_)
		for i, v in ipairs(panel:getChildren()) do
			v:showFlagNew(i==panel._curCount_)
			v:runAction(cc.MoveBy:create(0.5, cc.p(-130, 0)))
		end
		if panel:getChildrenCount() >= Total_History_Node + 1 then
			--删除最左边出界的一个
			panel:removeChildByTag(panel._curCount_ - Total_History_Node)
		end
	end
end

--初始化右侧玩家节点
function GameViewLayer:initPlayerView()
	tlog('GameViewLayer:initPlayerView')
    local parentNode = self.m_csbNode:getChildByName("Panel_center"):getChildByName("Image_right")
	self.m_scrollView = parentNode:getChildByName("ScrollView_1")
	self.m_scrollView:setSwallowTouches(false)
	self.m_scrollView:setScrollBarEnabled(false)
    self.m_itemPre = parentNode:getChildByName("Panel_23"):hide()
    self.m_itemPre:setTouchEnabled(false)

    local innerSize = self.m_scrollView:getInnerContainerSize()
    --展示前15个
    for i = 1, 15 do
    	local itemNode = self.m_itemPre:clone()
    	itemNode:setTag(i)
    	itemNode:setPosition(0, innerSize.height - i * 90)
    	itemNode:addTo(self.m_scrollView)
    end

    self.m_playerArray = {}

    local text_betMoney = parentNode:getChildByName("Text_totalMoney")
    text_betMoney._lastNum = 0
    text_betMoney._curNum = 0
    text_betMoney:setString(0)
    self.m_text_betMoney = text_betMoney
    local text_betPeople = parentNode:getChildByName("Text_bet_people")
    text_betPeople._lastNum = 0
    text_betPeople._curNum = 0
    text_betPeople:setString(0)
    self.m_text_betPeople = text_betPeople
    self:updateTotalPeople()

    self.m_addCoinNode = parentNode:getChildByName("AddCoinNode")
    self.m_addCoinNode:setVisible(false)
end

function GameViewLayer:updateTotalPeople()
	tlog('GameViewLayer:updateTotalPeople')
 --    local userList = self:getDataMgr():getUserList()
 --    local text_online = self.m_csbNode:getChildByName("Panel_center"):getChildByName("Text_online")
	-- self:formatNumShow(text_online, #userList)
end

--重连的时候先更新一下下注玩家列表，主要是给结算重连用
--更新一下总下注金币
function GameViewLayer:enterUpdatePlayerList()
	tlog('GameViewLayer:enterUpdatePlayerList')
	self.m_playerArray = self:getDataMgr():getAllUserBetScore()
	local totalMoney = 0
	for i, v in ipairs(self.m_playerArray) do
		totalMoney = totalMoney + v.betScore
	end
    self.m_text_betMoney._lastNum = totalMoney
    self.m_text_betMoney._curNum = totalMoney
	self:updateGoldShow(self.m_text_betMoney)
	self:updatePlayerView(0, true, false)
end

--每0.2s更新一次玩家下注列表
--_isBetStatus 是否下注阶段，非下注阶段不更新玩家列表
function GameViewLayer:updatePlayerView(dt, _dirUpdate, _isBetStatus)
	if not self.m_sliceTime then
		self.m_sliceTime = 0
	end
	self.m_sliceTime = self.m_sliceTime + dt
	if self.m_sliceTime >= 0.2 or _dirUpdate then
		tlog("GameViewLayer:updatePlayerView ", dt, _dirUpdate, _isBetStatus, self.m_curCurveNum)
		if _isBetStatus then
			--下注阶段下的多的排前面
			self.m_playerArray = self:getDataMgr():getAllUserBetScore()
		else
			--开奖阶段中的多的排前面
			self.m_playerArray = self:getDataMgr():getAllUserBetByRateEx(self.m_curCurveNum)
		end

		local selfData = nil
		for i, data in ipairs(self.m_playerArray) do
			local isSelf = self:isMeChair(data.chairId)
			--找到自己
			if isSelf then
				selfData = data
			end
			if i <= 15 then
				local itemNode = self.m_scrollView:getChildByTag(i)
				itemNode:setVisible(true)
				self:updateItem(itemNode, data, self.m_curCurveNum, isSelf)
			end
		end
	    local curLength = #self.m_playerArray
		if curLength < 15 then
			for i = curLength + 1, 15 do
				local itemNode = self.m_scrollView:getChildByTag(i)
				itemNode:setVisible(true)
				self:updateItem(itemNode, nil)
			end
		end
	    if curLength >= self.m_text_betPeople._curNum then
		    self.m_text_betPeople._lastNum = self.m_text_betPeople._curNum
		    self.m_text_betPeople._curNum = curLength
		    self:updateGoldShow(self.m_text_betPeople, 1,true,true)
		end
		self.m_sliceTime = self.m_sliceTime - 0.2
		--自动投注状态，本轮投注完，身上金币不够下轮投注，自动投注按钮取消
		-- if self.m_autoBetArray.isAuto then
		-- 	if self.m_scoreUser < self.m_betMoney._curNum then
		-- 		self:resetAutoBet()
		-- 	end
		-- end
		self:dealWithStopBtnShow(selfData)
	end
end

--更新item
function GameViewLayer:updateItem(itemNode, data, _curNum, _selfChair)
	local text_name = itemNode:getChildByName("Text_name")
	text_name:setTextColor(cc.c4b(255, 255, 255, 255))
	local text_bet = itemNode:getChildByName("Text_bet")
	local text_crash = itemNode:getChildByName("Text_crash")
	text_crash:setTextColor(cc.c4b(255, 255, 255, 255))
	local text_win = itemNode:getChildByName("Text_win")
	text_win:setTextColor(cc.c4b(0, 255, 0, 255))
	if data then
        local formatName, isShow = g_ExternalFun.GetFixLenOfString(data.userName, 160, "arial", 26)
        if formatName == nil then
        	formatName = ""
        	tlog("formatName is nil ", data.userName)
        end
        text_name:setString(isShow and formatName or (formatName .. "..."))

		local serverKind = G_GameFrame:getServerKind()
		text_bet:setString(g_format:formatNumber(data.betScore,g_format.fType.abbreviation,serverKind))
		if not self.m_isInGameEndStatus then
			text_crash:setString("—")
			text_win:setString("—")
		else
			if _curNum >= data.betCrash and data.betCrash ~= 0 then
				text_crash:setString(g_ExternalFun.formatNumWithPeriod(data.betCrash, "X"))
				local winMoney = math.floor((data.betCrash - 1) * data.betScore + 0.5)
				local serverKind = G_GameFrame:getServerKind()
				text_win:setString(g_format:formatNumber(winMoney,g_format.fType.abbreviation,serverKind))
			else
				text_crash:setString("—")
				text_win:setString("—")
				if not self.m_gameEndActionTime then
					text_crash:setTextColor(cc.c4b(198, 24, 52, 255))
					text_win:setTextColor(cc.c4b(198, 24, 52, 255))
				end
			end
		end
		if _selfChair then
			text_name:setTextColor(cc.c4b(95, 207, 133, 255))
			if data.betCrash == 0 then
				text_crash:setString("—")
			else
				text_crash:setString(g_ExternalFun.formatNumWithPeriod(data.betCrash, "X"))
			end
		end
	else
		text_name:setString("—")
		text_bet:setString("—")
		text_crash:setString("—")
		text_win:setString("—")
	end
end

function GameViewLayer:onEndBetCrashSuccessNotify(_cmdData)
    self:getDataMgr():updateUserBetCrash(_cmdData)
    if self:isMeChair(_cmdData.wChairID) then
    	tlog("self stop immediate")
    	self.m_curRoundSelfBetRate = _cmdData.lBetCrash / 100
	    self:setStopBtnEnabled(true, false)
	end
	for i, v in ipairs(self.m_betArrayRate) do
        if v.chairId == _cmdData.wChairID then
            v.betCrash = _cmdData.lBetCrash / 100
        end
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