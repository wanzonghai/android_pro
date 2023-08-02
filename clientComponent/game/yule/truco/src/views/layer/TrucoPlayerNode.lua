-- truco游戏 头像节点

local TrucoPlayerNode = class("TrucoPlayerNode", cc.Node)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")
local g_scheduler = cc.Director:getInstance():getScheduler()
local HeadNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HeadNode")

-- _cloneCsb可以传入一个clone的csb，节省效率
function TrucoPlayerNode:ctor(_cloneCsb)
	tlog('TrucoPlayerNode:ctor')
	g_ExternalFun.registerNodeEvent(self)
	if not _cloneCsb then
	    local itemNode = cc.CSLoader:createNode("UI/TrucoPlayerNode.csb")
	  	_cloneCsb = itemNode:getChildByName("Panel_1")
	end
	_cloneCsb:addTo(self)
	_cloneCsb:setPosition(0, 0)
	_cloneCsb:setTouchEnabled(false)
	self.m_csbNode = _cloneCsb
    self.m_cloneCsb = _cloneCsb:getChildByName("Image_1")
    self.m_playerInfo = nil
    self:setFontNumVisible(false)
    self:setWinTipVisible(false)
    self:setBankruptcyVisible(1) --给个假的值
end

-- _playerInfo 玩家信息
-- _needProgress 是否需要创建进度条，开始动画等不需要
function TrucoPlayerNode:reFlushNodeShow(_playerInfo, _needProgress)
	tlog('TrucoPlayerNode:reFlushNodeShow ', _playerInfo.szNickName, _playerInfo.wChairID, _playerInfo.lScore, _needProgress)
	-- tdump(_playerInfo, "_playerInfo", 10)
    self.m_playerInfo = _playerInfo
    -- local nameStr,isShow = g_ExternalFun.GetFixLenOfString(_playerInfo.szNickName, 100, "arial", 24)
    -- self.txtName:setString(isShow and nameStr or nameStr.."...")
    self.m_cloneCsb:getChildByName("Text_name"):setString(_playerInfo.szNickName)
    local imgShade = self.m_cloneCsb:getChildByName("imgShade")
    --头像
    local imgHead = imgShade:getChildByName("imgHead")
	local vipImage = imgShade:getChildByName("vipImage")
	vipImage:setLocalZOrder(3)
    imgHead:removeAllChildren()
    local faceId = _playerInfo.wFaceID
	local dwUserID = _playerInfo.dwUserID
	local node = HeadNode:create(faceId)
	imgHead:addChild(node)
	node:setContentSize(cc.size(170,170))
	node:setVipVisible(false)
	if dwUserID ~= GlobalUserItem.dwUserID then
		vipImage:hide()
	else
		vipImage:show()
		vipImage:loadTexture(string.format("client/res/VIP/GUI/%s.png",GlobalUserItem.VIPLevel),1)
	end
    -- local pPathHead = string.format("client/res/public/Face%d.jpg", faceId)
    -- -- local pPathClip = "client/res/public/clip.png"
    -- local pPathClip = "GUI/truco_head_clip.png"
    -- g_ExternalFun.ClipHead(imgHead, pPathHead, pPathClip)

    --更新财富值
	local serverKind = G_GameFrame:getServerKind()
	local str = g_format:formatNumber(_playerInfo.lScore,g_format.fType.abbreviation,serverKind)
	self.m_cloneCsb:getChildByName("Text_money"):setString(str)
	self:setBankruptcyVisible(_playerInfo.lScore)
	local icon = self.m_cloneCsb:getChildByName("Text_money"):getChildByName("Image_jinbi") --角色头像下自身币节点
	local currencyType = G_GameFrame:getServerKind()
	g_ExternalFun.setIcon(icon,currencyType)

	local iconIndex = GameLogic:getIconIndexByChairId(_playerInfo.wChairID)
	self.m_cloneCsb:loadTexture(string.format("GUI/truco_head_bg_down_%d.png", iconIndex))
	imgShade:loadTexture(string.format("GUI/truco_head_bg_%d.png", iconIndex))
	node:loadBorderTexture(string.format("GUI/truco_head_broad_%d.png", iconIndex))
	self:dealWithProgress(_needProgress, imgShade)
	self:setShowPlayerInfo(true)

	--点击弹出互动表情页面
	if not self.hudongClickFuc then
		node:onClicked(function() 
			if _playerInfo.dwUserID ~= GlobalUserItem.dwUserID then 
				G_event:NotifyEvent(G_eventDef.UI_OPEN_HUDONG_LAYER, _playerInfo)  --打开互动表情事件
			end
		end)
		self.hudongClickFuc = true
	end
end

--更新金币数量
function TrucoPlayerNode:reFlushGoldNum(_playerInfo)
	--更新财富值
	local serverKind = G_GameFrame:getServerKind()
	local str = g_format:formatNumber(_playerInfo.lScore,g_format.fType.abbreviation,serverKind)
	self.m_cloneCsb:getChildByName("Text_money"):setString(str)
end

function TrucoPlayerNode:dealWithProgress(_needProgress, _imgShade)
	if _needProgress then
		if not self.m_progressNode then
			local size = _imgShade:getContentSize()
			local progress = cc.ProgressTimer:create(display.newSprite("GUI/truco_djs.png"))
		    progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    	    progress:setPosition(size.width * 0.5, 93)
		    progress:addTo(_imgShade, 1)
		    progress:setReverseDirection(true)
		    progress:setPercentage(100)
			self.m_progressNode = progress
			progress:setLocalZOrder(2)
			--光圈提示点，跟着进度走
			local spriteTip = display.newSprite("GUI/truco_djs_gd.png")
			spriteTip:setAnchorPoint(cc.p(0.5, -1.23))
			spriteTip:setPosition(size.width * 0.5, 93)
			spriteTip:addTo(_imgShade, 2)
			spriteTip:setLocalZOrder(2)
			self.m_spriteTip = spriteTip

		    -- local _particle = cc.ParticleSystemQuad:create("client/res/GUI/particles/xingxing1.plist")
		    -- _particle:setPosition(26.5, 23.5)
		    -- _particle:setPositionType(cc.POSITION_TYPE_FREE)
		    -- spriteTip:addChild(_particle, 3)
		end
		self.m_progressNode:setVisible(false)
		self.m_spriteTip:setVisible(false)
	else
		if self.m_progressNode then
			self.m_progressNode:setVisible(false)
			self.m_spriteTip:setVisible(false)
		end
	end
end

--倒计时展示
function TrucoPlayerNode:startShowProgress(_totalTime, _curTimes, _bPlay)
	self:stopProgressCall()
	self.m_totalTime = _totalTime
	self.m_leftTime = _curTimes
	--最后四秒播放音效与否,只播自己的
	self.m_playVoiceArray = {}
	for i = 1, 4 do
		table.insert(self.m_playVoiceArray, (not _bPlay))
	end
	if self.m_progressNode then
		self.m_progressNode:setVisible(true)
		self.m_spriteTip:setVisible(true)
		if self.m_leftTime <= 0 then
			self.m_progressNode:setPercentage(0)
			self.m_spriteTip:setRotation(360)
		else
			self.m_spriteTip:setRotation(0)
		    self.m_progressTimer = g_scheduler:scheduleScriptFunc(function (dt)
		    	local curTime = math.ceil(self.m_leftTime)
		    	if curTime > 0 and curTime <= 4 then
		    		if not self.m_playVoiceArray[curTime] then
		    			self.m_playVoiceArray[curTime] = true
		    			--操作进度条最后四秒时的提示玩家赶紧操作音效(一秒一个，播四个)
			            g_ExternalFun.playSoundEffect("truco_time_down.mp3")
		    		end
		    	end
		    	local curPercent = self.m_leftTime / self.m_totalTime
	    		self.m_progressNode:setPercentage(curPercent * 100)
		    	self.m_leftTime = self.m_leftTime - dt
		    	self.m_spriteTip:setRotation((1 - curPercent) * 360)
		    	if self.m_leftTime < 0 then
		    		self.m_leftTime = 0
			    	self:stopProgressCall()
		    	end
		    end, 0, false)
		end
	else
		tlog("TrucoPlayerNode:startShowProgress has no progress")
	end
end

--隐藏倒计时
function TrucoPlayerNode:endHideProgress()
	self:stopProgressCall()
	if self.m_progressNode then
		self.m_progressNode:setVisible(false)
		self.m_progressNode:setPercentage(0)
		self.m_spriteTip:setVisible(false)
		self.m_spriteTip:setRotation(0)
	end
end

function TrucoPlayerNode:stopProgressCall()
	if self.m_progressTimer ~= nil then
		g_scheduler:unscheduleScriptEntry(self.m_progressTimer)
		self.m_progressTimer = nil
	end
	self.m_totalTime = 0
	self.m_leftTime = 0
	self.m_playVoiceArray = {false, false, false, false}
end

--是否显示玩家信息，false只显示一个黑色的图标
function TrucoPlayerNode:setShowPlayerInfo(_bShowInfo, _posIndex)
	local imageNoPeople = self.m_csbNode:getChildByName("imgnopeople")
	imageNoPeople:setVisible(not _bShowInfo)
	self.m_cloneCsb:setVisible(_bShowInfo)
	if not _bShowInfo then
		self.m_playerInfo = nil
		local iconIndex = GameLogic:getIconIndexByTableIndex(_posIndex)
		imageNoPeople:loadTexture(string.format("GUI/truco_head_bg_%d.png", iconIndex))
		imageNoPeople:getChildByName("Image_broad"):loadTexture(string.format("GUI/truco_head_broad_%d.png", iconIndex))
		self:setBankruptcyVisible(1) --没有玩家也给个假值
	end
end

function TrucoPlayerNode:getCurNodeInfo()
	return self.m_playerInfo
end

--当前节点是否有玩家数据
function TrucoPlayerNode:getCurNodeHasPlayer()
	return self.m_playerInfo ~= nil
end

function TrucoPlayerNode:setFontNumVisible(_bVisible)
	tlog('TrucoPlayerNode:setFontNumVisible ', _bVisible)
	local node = self.m_csbNode:getChildByName("Image_font")
	node:setVisible(_bVisible)
	return node
end

function TrucoPlayerNode:setWinTipVisible(_bVisible, _nums)
	tlog('TrucoPlayerNode:setWinTipVisible ', _bVisible)
	local node = self.m_csbNode:getChildByName("Text_win_tip")
	node:setVisible(_bVisible)
	local icon = node:getChildByName("Image_jinbi") --结算输赢币节点
	local currencyType = G_GameFrame:getServerKind()
	g_ExternalFun.setIcon(icon,currencyType)
	if _bVisible then
		local _tempNums = math.abs(_nums)
		local serverKind = G_GameFrame:getServerKind()
		local curNums = g_format:formatNumber(_tempNums,g_format.fType.standard,serverKind)
		local frontStr = ""
		if _nums > 0 then
			frontStr = "+"
			node:setTextColor(cc.c4b(255, 236, 74, 255))
		else
			frontStr = "-"
			node:setTextColor(cc.c4b(190, 190, 190, 255))
		end
		node:setString(string.format("%s%s", frontStr, curNums))
	end
	return node
end

--缩放的胜利特效
function TrucoPlayerNode:playTurnWinEffect()
    local scaleTo1 = cc.ScaleTo:create(0.17, 1.3)
    local scaleTo2 = cc.ScaleTo:create(0.08, 1.2)
    local delay = cc.DelayTime:create(0.5)
    local scaleTo3 = cc.ScaleTo:create(0.17, 1.3)
    local scaleTo4 = cc.ScaleTo:create(0.25, 1)
	self.m_cloneCsb:stopAllActions()
	self.m_cloneCsb:setScale(1)
	self.m_cloneCsb:runAction(cc.Sequence:create(scaleTo1, scaleTo2, delay, scaleTo3, scaleTo4))
end

--更新金币显示
function TrucoPlayerNode:updatePlayerCoinShow(_playerInfo)
	tlog('TrucoPlayerNode:updatePlayerCoinShow ', _playerInfo.szNickName, _playerInfo.wChairID, _playerInfo.lScore)
	self.m_playerInfo = _playerInfo
	local serverKind = G_GameFrame:getServerKind()
	local str = g_format:formatNumber(_playerInfo.lScore,g_format.fType.abbreviation,serverKind)
	self.m_cloneCsb:getChildByName("Text_money"):setString(str)
	self:setBankruptcyVisible(_playerInfo.lScore)
end

--文字上漂特效
function TrucoPlayerNode:nodePlayWinNumEffect(_winNums, _posIndex, _callBack)
	tlog('TrucoPlayerNode:nodePlayWinNumEffect ', _winNums)
	local imageFont = self:setFontNumVisible(true)
	if _posIndex == 3 then
		imageFont:setPosition(95, 175)
	else
		imageFont:setPosition(95, 230)
	end
	local serverKind = G_GameFrame:getServerKind()
	local winText = imageFont:getChildByName("WinFont")
	winText:setString(string.format("+%s", g_format:formatNumber(_winNums,g_format.fType.standard,serverKind)))
	local moveBy = cc.MoveBy:create(0.5, cc.p(0, 50))
	local delay = cc.DelayTime:create(1.0)
	local hide = cc.Hide:create()
	local call = cc.CallFunc:create(function ()
		if _callBack then
			_callBack()
		end
	end)
	imageFont:runAction(cc.Sequence:create(moveBy, delay, hide, call))
end

function TrucoPlayerNode:setBankruptcyVisible(_curMoney)
	self.m_csbNode:getChildByName('Image_bankruptcy'):setVisible(_curMoney <= 0)
end

function TrucoPlayerNode:onExit()
	self:stopProgressCall()
end

return TrucoPlayerNode