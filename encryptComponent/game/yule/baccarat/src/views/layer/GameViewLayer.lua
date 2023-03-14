local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer = display.newLayer()
    return gameViewLayer
end)
local perfix = "game/yule/baccarat/res/"
local FlyChipLayer = appdf.req("game.yule.baccarat.src.views.layer.FlyChipLayer")
local GameLogic = appdf.req("game.yule.baccarat.src.models.GameLogic")

local scheduler = cc.Director:getInstance():getScheduler()
function GameViewLayer:onExit()
    self:Stop()
end
local GameStateFree = 1  --空闲
local GameStateBet  = 2  --下注 
local GameStateEnd  = 3  --结算
function GameViewLayer:ctor(scene)
	self._scene = scene
    self:onInitData()
    self:onInitUI()
	self.m_flyChipLayer = FlyChipLayer:create()
	self.m_flyChipLayer.m_conf.chip_plist = nil
	self.m_flyChipLayer.m_conf.img_fly_ = "smallchip_bet_%d.png"
	self.m_flyChipLayer.m_conf.sound_fly = "sound/soundbethigh.mp3"
	self.m_flyChipLayer.m_conf.sound_gap = 1
    self.nodeDeskChip:addChild(self.m_flyChipLayer)
    for i=1,8 do
        self.m_flyChipLayer:addArea(i,self.betArea[i])
    end
    self.net_bet_data = {}
    self:Start()
    self:onInitUserInfo()
    g_ExternalFun.playMusic("sound/music_bg.mp3", true)
end
function GameViewLayer:onInitData()
    self.clockTxt = {"FreeTime","BetTime","Opening"}
    self.betConfig = {1000,10000,100000,500000,1000000,5000000}  --下注配置
    self.cbGameStatues = GameStateFree
    self.bankerScore   = 0   --上庄条件 
    self.hasBet        = false 
    self.isBanker      = false
    --筹码显示区域
    self.betArea       = {cc.rect(-700,-140,250,170 ),cc.rect(-173,0,330,106),cc.rect(434,-140,250,170),cc.rect(-270,-255,110,80),
                          cc.rect(150,-256,110,80),cc.rect(-54,-255,110,80),cc.rect(-474,116,122,90),cc.rect(353,116,122,90)} 
    self.sp_flash      = {}  --sp闪
    self.txt_allbet    = {}  --总下注
    self.txt_mybet     = {}  --自己下注
    self.btnChip       = {}  --6个筹码
    self.groupCards    = {}  --手牌
    self.curChipIndex  = 0   --筹码索引
    self.user_score    = 0   --自已分数 
    self.banker_score  = 0   --庄家当前分数 
    self.curCardPoint  = {0,0}              --庄闲点数
    self.desk_betScore = {0,0,0,0,0,0,0,0}  --桌面下注
    self.user_betScore = {0,0,0,0,0,0,0,0}  --自已下注
    self.last_betScore = {0,0,0,0,0,0,0,0}  --自已上次下注
    self.deskBetCount  = 0   --桌上总下注

    cc.SpriteFrameCache:getInstance():addSpriteFrames(perfix .. "picture/chip_bjl.plist") 
end
--初始化UI
function GameViewLayer:onInitUI()
    local csbNode = g_ExternalFun.loadCSB(perfix.."GameLayerBjl.csb",self)
    local nodeTop = csbNode:getChildByName("nodeTop")
    nodeTop:getChildByName("btnBack"):onClicked(handler(self,self.onClickBack),true)  --返回
    self.btnUpZhuang = nodeTop:getChildByName("btnUpZhuang")  
    self.btnDownZhuang = nodeTop:getChildByName("btnDownZhuang") 
    self.btnUpZhuang:onClicked(function() self:onClickApplyZhuang(1) end)
    self.btnDownZhuang:onClicked(function() self:onClickApplyZhuang(2) end)
    self.btnUpZhuang:setVisible(false) --隐藏上下庄按钮
    self.btnDownZhuang:setVisible(false)
    self.nodeZhaung = nodeTop:getChildByName("nodeZhuang")   --庄节点
    self.scrollview = nodeTop:getChildByName("scrollview")   --路子scrollview
    self.btnMenu = nodeTop:getChildByName("btnMenu")
    self.btnMenu:onClicked(handler(self,self.onClickMenu))

    local nodeCenter = csbNode:getChildByName("nodeCenter")
    local nodeBet = nodeCenter:getChildByName("nodeBet")
    local nodeFlash = nodeCenter:getChildByName("nodeFlash")
    local nodeChipTxt = nodeCenter:getChildByName("nodeChipTxt")
    for i=1,8 do   --8个区域下注
        if i ~= 6 then
            nodeBet:getChildByName( string.format("bet_area%d",i)):onClickEnd(function()
                self:onClickBet(i)
            end)
        end
        self.sp_flash[i] = nodeFlash:getChildByName( string.format("sp_flash%d",i))
        self.txt_allbet[i] = nodeChipTxt:getChildByName( string.format("txtAllbet%d",i))
        self.txt_mybet[i] = nodeChipTxt:getChildByName( string.format("txtMybet%d",i))
    end
    self.txtDeskAllBet = nodeChipTxt:getChildByName("txtDeskAllBet")   --桌上总下注
    nodeCenter:getChildByName("btnOnline"):onClicked(handler(self,self.onClickOnline))
    self.txtOnline = nodeCenter:getChildByName("btnOnline"):getChildByName("txtOnline")
    self.spClock = nodeCenter:getChildByName("spClock")
    self.txtState = self.spClock:getChildByName("txtState")
    self.txtClockTime = self.spClock:getChildByName("txtTime")
    local nodeBottom = csbNode:getChildByName("nodeBottom")
    self.nodeUser = nodeBottom:getChildByName("userNode")
    self.btnXuyan = nodeBottom:getChildByName("btnXuyan")
    self.btnXuyan:onClicked(handler(self,self.onClickXuYan))
    local nodeChip = nodeBottom:getChildByName("nodeChip")
    for i=1,6 do
        self.btnChip[i] = nodeChip:getChildByName( string.format("btnChip%d",i))
        self.btnChip[i]:onClicked(function()
            self:onClickChip(i)
        end)
    end
    self.nodeResult = csbNode:getChildByName("nodeResult")
    for i=1,2 do
        self.groupCards[i] = self.nodeResult:getChildByName( string.format("GroupCard%d",i))
		--保存原始坐标
		for j = 1, 3 do
			local card = self.groupCards[i]:getChildByName("Image_Card_" .. j)
			card.oript_ = cc.p(card:getPositionX(),card:getPositionY())
			card.orisx_ = card:getScaleX()
			card.orisy_ = card:getScaleY()
		end
    end
    self.spCardFly = self.nodeResult:getChildByName("spCardFly")
    self.nodeDeskChip = csbNode:getChildByName("nodeDeskChip")
    self.Panel_Effect = csbNode:getChildByName("Panel_Effect")
    self.spWaitNext = csbNode:getChildByName("spWaitNext")  --等待下一局提示
    self.nodeExpand = csbNode:getChildByName("nodeExpand")
    self.spExpand = self.nodeExpand:getChildByName("spExpand")
    self.nodeExpand:getChildByName("panel"):onClickEnd(function() 
        self.nodeExpand:setVisible(false) 
        self.btnMenu:setRotation(0)
    end,true)
    self.spExpand:getChildByName("btnRule"):onClicked(handler(self,self.onClickRule))
    self.btnMusic = self.spExpand:getChildByName("btnMusic")
    self.btnSound = self.spExpand:getChildByName("btnSound")
    self.btnMusic:onClicked(handler(self,self.onClickMusic))
    self.btnSound:onClicked(handler(self,self.onClickSound))
    self:onEnableSound()
end
--初始化自已信息
function GameViewLayer:onInitUserInfo()
    self.user_score = GlobalUserItem.lUserScore
    self.nodeUser:getChildByName("txtUserName"):setString(GlobalUserItem.szNickName)
    local score = string.formatNumberThousands(self.user_score,true,".")
    self.nodeUser:getChildByName("fntCoin"):setString(score)
end
--设置庄家信息
function GameViewLayer:onInitBankerInfo(wBanker,lBankerScore)
    local name = ""
    if G_NetCmd.INVALID_CHAIR == wBanker then  --系统坐庄
        name = "Sistema de base"
    else
        local useritem = self._scene:GetUserItem(wBanker)
        if useritem == nil then
            printInfo("获取庄家用户信息失败")
            name = "error user"
        else
            name = useritem.szNickName
        end
    end
    self.banker_score = lBankerScore
    self.nodeZhaung:getChildByName("txtName"):setString(name)
    local score = string.formatNumberThousands(lBankerScore,true,".")
    self.nodeZhaung:getChildByName("fntCoin"):setString(score)

    self.isBanker = (wBanker == self._scene:GetMeChairID()) and true or false
    self.btnDownZhuang:setVisible(wBanker == self._scene:GetMeChairID())
    self.btnDownZhuang:setVisible(false)
end
function GameViewLayer:Start()
    if self.net_event_timeId == nil then
        self.net_event_timeId = scheduler:scheduleScriptFunc(handler(self,self.onUpdateTime), 0, false)
    end
end
function GameViewLayer:Stop()
    if self.net_event_timeId ~= nil then
        scheduler:unscheduleScriptEntry(self.net_event_timeId)
    end
end
--返回大厅
function GameViewLayer:onClickBack()
     if self.hasBet == true or self.isBanker == true then
         showToast(g_language:getString("game_prohibit_leave"))
         return
     end
     self._scene:onExitTable()
end

function GameViewLayer:onClickApplyZhuang(cbType)
    if cbType == 1 then   --上庄
        if self.user_score < self.bankerScore then
            showToast( string.format(g_language:getString("game_banker_score"),self.bankerScore))
            return
        end
        self._scene:reqApplyBanker()
    else                  --下庄
       if self.cbGameStatues ~= GameStateFree then
           showToast( string.format(g_language:getString("gamebanker_no_time")))
           return
       end
       self._scene:reqCancelApply()
    end
end
function GameViewLayer:onClickMenu()
    self.btnMenu:setRotation(180)
    self.nodeExpand:setVisible(true)
    self.spExpand:setPosition(850,310)
    self.spExpand:setOpacity(0)
    local act1 = cc.EaseBackOut:create(cc.MoveTo:create(0.2, cc.p(850,270)))
    local act2 = cc.FadeIn:create(0.2)
    self.spExpand:runAction(cc.Sequence:create(cc.Spawn:create(act1, act2)))
end
function GameViewLayer:onClickBet(betIndex)
    if self.cbGameStatues ~= GameStateBet then
        showToast(g_language:getString("game_no_bet_time"))
        return        
    end
    if self.isBanker == true then
        showToast(g_language:getString("game_zhuang_no_bet"))
        return
    end
    if self.curChipIndex == 0 then
        showToast(g_language:getString("game_select_money"))
        return
    end
    if self.betConfig[self.curChipIndex] > self.user_score then
        showToast(g_language:getString("game_money_not_enough"))
        return
    end
    if betIndex == 4 then
        betIndex = 1
    elseif betIndex == 5 then
        betIndex = 3
    end
    self._scene:reqAddScore(betIndex,self.betConfig[self.curChipIndex])
end
--续押
function GameViewLayer:onClickXuYan()
    if self.cbGameStatues ~= GameStateBet then
        showToast(g_language:getString("game_no_bet_time"))
        return        
    end
    if self.isBanker == true then
        showToast(g_language:getString("game_zhuang_no_bet"))
        return
    end
    for i,v in pairs(self.last_betScore) do
        if v > 0 then
            for k=6,1,-1 do
                while v >= self.betConfig[k] do
                    v = v - self.betConfig[k]
                    self._scene:reqAddScore(i,self.betConfig[k])
                end
            end
        end
    end
end
--选择筹码
function GameViewLayer:onClickChip(chipIndex)
    if self.cbGameStatues ~= GameStateBet then
        return
    end
    self.curChipIndex = chipIndex
    for i=1,6 do
        self.btnChip[i]:setPositionY(chipIndex == i and -407 or -437)
    end
end
--在线人数
function GameViewLayer:onClickOnline()
    local data = self._scene.playlist
    appdf.req("game.yule.baccarat.src.views.layer.GamePlayerList.lua").new(self,data)
end
function GameViewLayer:onUpdateOnlineCount(count)
    self.txtOnline:setString(count)
end
--规则
function GameViewLayer:onClickRule()
    appdf.req("game.yule.baccarat.src.views.layer.GameRuleLayer.lua").new(self)
    self.nodeExpand:setVisible(false) 
    self.btnMenu:setRotation(0)  
end
function GameViewLayer:onEnableSound(cbType)
    local bVoice = GlobalUserItem.bVoiceAble
    bVoice = bVoice and 1 or 0
    local bSound = GlobalUserItem.bSoundAble
    bSound = bSound and 1 or 0
    local musicBg = {[0]="picture/music_close.png","picture/music_open.png"}
    local soundBg = {[0]="picture/voice_close.png","picture/voice_open.png"}
    self.btnMusic:loadTextures(musicBg[bVoice],musicBg[bVoice])
    self.btnSound:loadTextures(soundBg[bSound],soundBg[bSound])
end
function GameViewLayer:onClickMusic()
    GlobalUserItem.setVoiceAble(not GlobalUserItem.bVoiceAble)
    g_ExternalFun.playMusic("sound/music_bg.mp3")
    self:onEnableSound()    
end
function GameViewLayer:onClickSound()
    GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble) 
    self:onEnableSound()
end
--------------------------------------------------
--清除数据
function GameViewLayer:onClearData()
    self.net_bet_data = {}
    self.hasBet = false
    self:onClearBetInfo()        --下注信息移除
    self:onHideFlash()
    self.m_flyChipLayer:reset()  --筹码移除
    self:onHideResultScore()
    self:onClearCard()
    self.Panel_Effect:removeAllChildren()
    self.spWaitNext:hide()
end
--下注清除
function GameViewLayer:onClearBetInfo()
    for i=1, 8 do
        self.txt_allbet[i]:setString("0")
        self.txt_mybet[i]:setString("0")
    end    
    self.txtDeskAllBet:setString("0")
    self.desk_betScore = {0,0,0,0,0,0,0,0}
    self.user_betScore = {0,0,0,0,0,0,0,0}
end
function GameViewLayer:onHideResultScore()
    self.nodeUser:getChildByName("txtWin"):setString("")
    self.nodeZhaung:getChildByName("txtWin"):setString("")
end
function GameViewLayer:onClearCard()
    self.nodeResult:setVisible(false)
    for i=1,2 do
	    for j = 1, 3 do
	    	self.groupCards[i]:getChildByName("Image_Card_" .. j):setVisible(false)
	    end
    end
end
--设置筹码
function GameViewLayer:setChipEnabled(isEnable)
    for i=1,6 do
        self.btnChip[i]:setEnabled(isEnable and (self.user_score > self.betConfig[i]))
    end    
end
--
function GameViewLayer:onHideClock()
    self.spClock:setVisible(false)
    self.spClock:stopAllActions()
end
function GameViewLayer:onHideFlash(area)
    for i,v in pairs(self.sp_flash) do
        v:stopAllActions()
        v:setVisible(false)
    end
end
--空闲状态
function GameViewLayer:onSceneFree(data)
    self.bankerScore = data.lApplyBankerCondition
    self:onInitBankerInfo(data.wBankerUser,data.lBankerScore)
    self:onShowClock(1,data.cbTimeLeave)
    self:setChipEnabled(false)
    self:setEnableXuYa(false)
    self.cbGameStatues = GameStateFree
end
--下注状态
function GameViewLayer:onSceneJetton(data)
    self.bankerScore = data.lApplyBankerCondition
    self:onInitBankerInfo(data.wBankerUser,data.lBankerCurScore)
    self:onInitDeskBetData(data)   --下注信息初始化
    self:onShowClock(2,data.cbTimeLeave)
    self:setChipEnabled(true)
    self.cbGameStatues = GameStateBet
end
--结算状态
function GameViewLayer:onSceneGameEnd(data)
    self.bankerScore = data.lApplyBankerCondition
    data.lBankerScore = 0
    self.game_result = data  --结算数据
    self:onInitBankerInfo(data.wBankerUser,data.lBankerCurScore)
    self:onShowClock(3,data.cbTimeLeave)
    self:setChipEnabled(false)
    self:setEnableXuYa(false)
    self.cbGameStatues = GameStateEnd
    if data.cbTimeLeave <= 3 then
        self.spWaitNext:show()
    else
        self:onInitDeskBetData(data)   --下注信息初始化
        self:onShowCardInfo(data)
    end
end
--游戏消息
function GameViewLayer:S2C_onGameFree(cmd_data)
    self:onClearData()
    self.cbGameStatues = GameStateFree
    self:onShowClock(1,cmd_data.cbTimeLeave)
    self:setChipEnabled(false)
    self:setEnableXuYa(false)
end
function GameViewLayer:S2C_onGameStart(cmd_data)
    self:onInitBankerInfo(cmd_data.wBankerUser,cmd_data.lBankerScore)
    self.cbGameStatues = GameStateBet
    self:onShowClock(2,cmd_data.cbTimeLeave-1)
    self:setChipEnabled(true)   
    self:onCheckXuYanStates()
    self:onPlayBetAni(1)
end
function GameViewLayer:S2C_onUserBet(cmd_data)
    self.deskBet = true
    if cmd_data.wChairID == self._scene._myChairId then  --下注
        self.hasBet = true
        if self.isXuYaType == true then
            self.isXuYaType = false
            self.last_betScore = {0,0,0,0,0,0,0,0}
        end
        local betMoney = cmd_data.lBetScore
        self.user_score = self.user_score - betMoney
        self:onFlyChip(cmd_data.wChairID,cmd_data.cbBetArea,betMoney,true)
        self:onUpdateDeskBet(cmd_data.cbBetArea,betMoney)  --更新桌上下注
        self:onUpdateMyBet(cmd_data.cbBetArea,betMoney)    --更新自已下注
        self:onUpdateUserInfo(self.user_score)             --更新自已分数
        self:onCheckChipStates(self.user_score)
        self:setEnableXuYa(false)
        g_ExternalFun.playEffect("sound/soundbethigh.mp3")
    else
        table.insert(self.net_bet_data,cmd_data)
    end
end
function GameViewLayer:S2C_onUserBetFail(cmd_data)
    printInfo( string.format("下注失败。 区域 %d  分数 %d   code: %d",(cmd_data.cbBetArea+1),cmd_data.lPlaceScore, cmd_data.cbCode))
    local errorMsg = ""
    if cmd_data.cbCode == 1 then
       errorMsg = g_language:getString("game_bet_error_area")
    elseif cmd_data.cbCode == 2 then 
       errorMsg = g_language:getString("game_no_bet_time")
    elseif cmd_data.cbCode == 3 then 
       errorMsg = g_language:getString("game_zhuang_no_bet")
    elseif cmd_data.cbCode == 4 then 
       errorMsg = g_language:getString("game_bet_error_nobanker")
    elseif cmd_data.cbCode == 5 or cmd_data.cbCode == 6 then 
       errorMsg = g_language:getString("game_bet_error_limit_self")
    elseif cmd_data.cbCode == 7 then 
       errorMsg = g_language:getString("game_bet_error_limit_banker")
    end
    showToast(errorMsg)
end
function GameViewLayer:S2C_onGameEnd(cmd_data)
    self.game_result = cmd_data  --结算数据
    self.cbGameStatues = GameStateEnd
    self:onShowClock(3,cmd_data.cbTimeLeave)
    self:setChipEnabled(false)   
    self:onSendCard(cmd_data)
end
--路单
function GameViewLayer:S2C_onUpdateRecord(record)
    self.historyRecord = record
    self:onUpdateHistory(true)
end

function GameViewLayer:S2C_onApplyBanker(cmd_data)
    if cmd_data.wApplyUser == self._scene._myChairId then
        showToast(g_language:getString("game_apply_banker"))
    end
end
function GameViewLayer:S2C_onChangeBanker(cmd_data)
    self:onInitBankerInfo(cmd_data.wBankerUser,cmd_data.lBankerScore)
end
function GameViewLayer:S2C_onCancelBanker(cmd_data)
    --self:onInitBankerInfo(cmd_data.wBankerUser,cmd_data.lBankerScore)
end
--发牌
function GameViewLayer:onSendCard(cmd_data)
	local userCard = { {}, {} }		--手牌数值
	local typeList = { 0, 0 }		--牌型点数
    local cbCardCount = cmd_data.cbCardCount[1]
    for k=1,2 do
        for i=1,cbCardCount[k] do
            table.insert(userCard[k], cmd_data.cbTableCardArray[k][i])
        end
    end
	for i = 1, 2 do
		for _, v in ipairs(userCard[i]) do
			typeList[i] = (GameLogic:pokerValue(v) + typeList[i]) % 10
		end
	end
    self.curCardPoint = typeList
	local function getCardNodes(idx)
		local cardNodes = {}
		if self.groupCards[idx] then
			for i = 1, 3 do  --最多3张牌
				table.insert(cardNodes, self.groupCards[idx]:getChildByName("Image_Card_" .. i))
			end
		end
		return cardNodes
	end
	local npc = {1, 2, 1, 2, 1, 2}
	local idx = 0
	local startPt = cc.p(1100,750)

	local function operate()
		idx = idx + 1
		local times = math.ceil(idx / 2)
		if npc[idx] and userCard[npc[idx]] then
			---可能没有第三张牌，跳过此轮
			if not userCard[npc[idx]][times] then
				return operate()
			end
			local flyCard = self.spCardFly:clone()
			self.Panel_Effect:addChild(flyCard)
			flyCard:setPosition(startPt)

			local cardNodes = getCardNodes(npc[idx])
			local curCard = cardNodes[times]
			local aimpt = curCard:getParent():convertToWorldSpace(cc.p(curCard.oript_))
			if times == 1 then
				aimpt.x = aimpt.x + 22
			elseif times == 2 then
				aimpt.x = aimpt.x + 28
			elseif times == 3 then
				for i = 1, 2 do
					cardNodes[i]:runAction(cc.MoveTo:create(0.3, cardNodes[i].oript_))
				end
			end

			local data = {
				aimpt = aimpt,
				times = times,
				cardValue = userCard[npc[idx]][times]
			}
			local function sendOver()
				self:showCard(true, operate, cardNodes, data)
			end
			self:sendCard(sendOver, flyCard, data)
		else
			self:showCardType(true, typeList)
		end
	end
    operate()
    self.nodeResult:setVisible(true)
end
function GameViewLayer:sendCard(callback, cardNode, data)
	if cardNode and data then
		callback = callback or function() end
		local aimpt = data.aimpt or cc.p(0, 0)    --目标点
		local aimsx = data.aimsx or 1    --目标缩放值
		local aimsy = data.aimsy or 1
		local times = data.times or 1    --第几次

		local function fanpai(node)
			node:removeFromParent()
			if times ~= 1 and data.cardValue then
				---@type SkeletonNode
				local node = self.Panel_Effect:getChildByName("ANIM_FANPAI")
				if not node then
					node = cc.CSLoader:createNode("effect/huanle30s_fanpai/huanle30s_fanpai.csb")
					node:setName("ANIM_FANPAI")
                    node:setScale(1.44)
					self.Panel_Effect:addChild(node)
				end
				if node then
					node:setVisible(false)
					node:setPosition(aimpt.x-g_offsetX, aimpt.y)
					local action = cc.CSLoader:createTimeline("effect/huanle30s_fanpai/huanle30s_fanpai.csb")
					node:runAction(action)
                    
					action:play("Animation1", false)

					local huase, n1, n2 = GameLogic:getCardChar(data.cardValue)
					---@type BoneNode
					local huaNode = node:getBoneNode("heitao")
					local charNode = node:getBoneNode("A")
					---@type Sprite
					local hua = huaNode:getChildByName("heitao")
					local char = charNode:getChildByName("A")
					local huaFName = string.format("picture/card/cardcolor-%d.png", huase)
					local charFName = string.format("picture/card/cardchar_value-%d-%d.png", n1, n2)

					local huaFrame = cc.SpriteFrame:create(huaFName,cc.rect(0,0,31,31))
					local charFrame = cc.SpriteFrame:create(charFName,cc.rect(0,0,31,45))
					if huaFrame and charFrame then
						hua:setSpriteFrame(huaFrame)
						char:setSpriteFrame(charFrame)
						node:setVisible(true)
					end
				end
                performWithDelay(self,function()
					if not tolua.isnull(node)  then
						node:setVisible(false)
					end
					callback()
				end, 46 / 60)
			else
				callback()
			end
		end
		g_ExternalFun.playEffect("sound/send_card.mp3")
		cardNode:setVisible(true)
		cardNode:stopAllActions()
		cardNode:runAction(cc.Sequence:create(
				cc.Spawn:create(
						cc.MoveTo:create(0.3, cc.p(aimpt.x-g_offsetX, aimpt.y)),
						cc.ScaleTo:create(0.3, aimsx, aimsy),
						cc.RotateTo:create(0.3, 200)
				),
				cc.CallFunc:create(fanpai)
		))
	end
end
function GameViewLayer:showCard(motion, callback, cardNodes, data)
	if cardNodes and data and cardNodes[data.times] then
		callback = callback or function() end
		local times = data.times or 1    --第几次
		local cardNode = cardNodes[times]
		local aimpt = data.aimpt or cc.p(0, 0)    --目标点
		local aimsx = data.aimsx or cardNode.orisx_ or 1    --目标缩放值
		local aimsy = data.aimsy or cardNode.orisy_ or 1
		local cardValue = data.cardValue or 0

		if aimpt == true then
			cardNode:setPosition(cardNode.oript_ or cc.p(0, 0))
		else
			cardNode:setPosition(cardNode:getParent():convertToNodeSpace(aimpt))
		end

		cardNode:stopAllActions()
		cardNode:setRotation(0)
		cardNode:loadTexture( string.format("picture/card/%d.png", 0))
		cardNode:setVisible(true)
		local function changeCard()
			cardNode:loadTexture( string.format("picture/card/%d.png",cardValue))
		end

		if not motion then
			changeCard()
			callback()
		else
			if times == 1 then
				cardNode:runAction(cc.Sequence:create(
						cc.DelayTime:create(0.05),
						cc.ScaleTo:create(0.1, 0, aimsy),
						cc.CallFunc:create(changeCard),
						cc.ScaleTo:create(0.1, aimsx, aimsy),
						cc.CallFunc:create(callback)
				))
			else
				changeCard()
				cardNode:setScale(1.2)
				cardNode:setRotation(-40)
				cardNode:runAction(cc.Sequence:create(
						cc.Spawn:create(
								cc.EaseSineOut:create(cc.RotateTo:create(0.12, 0)),
								cc.ScaleTo:create(0.06, aimsx, aimsy)
						),
						--cc.EaseBounceOut:create(cc.RotateTo:create(0.05, 0)),
						cc.CallFunc:create(callback)
				))
			end
		end
	end
end

function GameViewLayer:showCardType(motion, typeList)
	typeList = typeList or {}
	if #typeList < 2 then
		self:showResult()
		return
	end
	local function showWinAnime(idx)
		local pt = self.groupCards[idx]:getParent():convertToWorldSpace(cc.p(self.groupCards[idx]:getPosition()))
		local node = cc.CSLoader:createNode("effect/jiesuan_ying/jiesuan_ying.csb")
		local action = cc.CSLoader:createTimeline("effect/jiesuan_ying/jiesuan_ying.csb")
		self.Panel_Effect:addChild(node, 4)
		node:setPosition(pt.x-g_offsetX, pt.y + 80)
		node:runAction(action)
		action:play("Animation1", false)
		performWithDelay(self,function()
			if not tolua.isnull(node) then
				action:play("Animation2", true)
			end
		end, 40 / 60)
	end
	local function showAnime(idx, callback)
		local pt = self.groupCards[idx]:getParent():convertToWorldSpace(cc.p(self.groupCards[idx]:getPosition()))
		local point = typeList[idx]

		local node = cc.CSLoader:createNode("effect/huanle30s_kaipai/huanle30s_kaipai.csb")
		local action = cc.CSLoader:createTimeline("effect/huanle30s_kaipai/huanle30s_kaipai.csb")
		self.Panel_Effect:addChild(node, 3)
		node:setVisible(false)
		node:setPosition(pt.x-g_offsetX, pt.y - 80)
		node:runAction(action)

		local pointSprite
		if point >= 8 then
			action:play("Animation6", false)
			pointSprite = node:getBoneNode("huanle30s_8dian"):getChildByName("huanle30s_8dian")
			if point == 9 then
                g_ExternalFun.playEffect("sound/tianwang.mp3")
			end
		else
			action:play("Animation5", false)
			pointSprite = node:getBoneNode("huanle30s_4dian"):getChildByName("huanle30s_4dian")
		end
		local frame = cc.SpriteFrame:create( string.format("picture/card/huanle30s_%ddian.png", point),cc.rect(0,0,63,41))
		if frame then
			pointSprite:setSpriteFrame(frame)
			node:setVisible(true)
		end
		---播报点数音效
		if idx == 2 then
            g_ExternalFun.playEffect( string.format("sound/point/xpoint-%d.mp3", typeList[1]))
			performWithDelay(self,function()
				g_ExternalFun.playEffect( string.format("sound/point/zpoint-%d.mp3", typeList[2]))
				performWithDelay(self,function()
					if typeList[1] < typeList[2] then
						g_ExternalFun.playEffect("sound/zhuangwin.mp3")
						showWinAnime(2)
					elseif typeList[1] > typeList[2] then
						g_ExternalFun.playEffect("sound/xianwin.mp3")
						showWinAnime(1)
					else
						g_ExternalFun.playEffect("sound/ping.mp3")
					end
					performWithDelay(self,callback, 0.5)
				end, 1.2)
			end, 1.2)
		end
	end
	showAnime(1)
	showAnime(2, handler(self, self.showResult))
end

--展示中奖结果
function GameViewLayer:showResult()
	local winArea = GameLogic:getWinArea(self.game_result)
    local blink = function(fDuration, times)
        local a1 = cc.FadeIn:create(0.1);
        local a2 = cc.DelayTime:create(fDuration);
    	local a3 = cc.FadeOut:create(0.1);
    	return cc.Repeat:create(cc.Sequence:create(a1, a2, a3), times);
    end
	--展示中奖区域
	local function blinkWinArea()
		for i, v in ipairs(self.sp_flash) do
            --屏蔽三个开奖结果
			if winArea[i] > 0 and (i ~= 4 and i ~= 5 and i ~= 6) then
				v:setVisible(true)
				v:stopAllActions()
				v:runAction(cc.Sequence:create(
						blink(0.5, 3),
						cc.CallFunc:create(function()
							v:setVisible(true)
							v:setOpacity(255)
						end)
				))
			end
		end
        self:onInsertRecord()
	end
	--飞筹码给庄家
	local function flyToBanker()
		local moveEndPos = cc.p(217,460)
        local isFly = false
		for i = 1, 8 do
			if winArea[i] <= 0 then
				local chips = self.m_flyChipLayer:getChipsByAreaKey(i)
				if #chips > 0 then
					for _, chip in pairs(chips) do
                        isFly = true
						self.m_flyChipLayer:flyToPoint(chip, moveEndPos)
					end
				end
			end
		end
        if isFly then
	    	g_ExternalFun.playEffect("sound/fly_gold.mp3")
        end
	end
	--庄家输的钱飞回赢的区域
	local function flyToWinArea()
		local moveBeganPos = cc.p(217,460)
        local isFly = false
		for i = 1, 8 do
			if winArea[i] > 0 then
				local chips = self.m_flyChipLayer:getChipsByAreaKey(i)
				if #chips > 0 then
					for _, v in pairs(chips) do
                        isFly = true
						local chip = self.m_flyChipLayer:getFlyChip(v:getTag(), v:getDeskStation())
						chip:setPosition(moveBeganPos)
						self.m_flyChipLayer:toArea(true, chip, i,1.44,1.44)
					end
				end
			end
		end
        if isFly then
	    	g_ExternalFun.playEffect("sound/fly_gold.mp3")
        end
	end
    --展示金币飞入玩家部分
	local function flyToWinPlayer()
		local moveBeganPos = cc.p(217,460)
        local isFly = false
		for i = 1, 8 do
			if winArea[i] > 0 then
				local chips = self.m_flyChipLayer:getChipsByAreaKey(i)
				if #chips > 0 then
					for _, v in pairs(chips) do
                        isFly = true
                        if v:getDeskStation() == self._scene._myChairId then
						    self.m_flyChipLayer:flyToPoint(v, cc.p(-770,-460),1.44,1.44)
                        else
                            self.m_flyChipLayer:flyToPoint(v, cc.p(-870,180) ,1.44,1.44)
                        end
					end
				end
			end
		end
        if isFly then
	    	g_ExternalFun.playEffect("sound/fly_gold.mp3")
        end
	end
	blinkWinArea()
    local delaytime1 = cc.DelayTime:create(0.8)
    local callback1 = cc.CallFunc:create(function()
         flyToBanker()
    end)
    local delaytime2 = cc.DelayTime:create(0.8)
    local callback2 = cc.CallFunc:create(function()
         flyToWinArea()
    end)
    local delaytime3 = cc.DelayTime:create(0.8)
    local callback3 = cc.CallFunc:create(function()
         flyToWinPlayer()
         self:onShowBankerResult()
         self:onShowMyselfResult()
    end)
	self:runAction(cc.Sequence:create(delaytime1,callback1,delaytime2,callback2,delaytime3,callback3))
end
--展示结算
function GameViewLayer:onShowBankerResult()
    self.banker_score = self.banker_score + self.game_result.lBankerScore
    local score = string.formatNumberThousands(self.banker_score,true,".")  --庄家分
    self.nodeZhaung:getChildByName("fntCoin"):setString(score)
    local txtWin = self.nodeZhaung:getChildByName("txtWin")
    if self.game_result.lBankerScore < 0 then
        txtWin:setFntFile(perfix.."font/num_result_lose.fnt")
        txtWin:setString(self.game_result.lBankerScore)
    elseif self.game_result.lBankerScore > 0 then
        txtWin:setFntFile(perfix.."font/num_result_win.fnt")
        txtWin:setString("+"..self.game_result.lBankerScore)        
    end
    local pos = txtWin:getPositionY()
    txtWin:setPositionY(pos - 30)
    TweenLite.to(txtWin, 0.15, { y = pos, ease = Sine.easeOut})
    performWithDelay(txtWin,function()
        txtWin:setString("")
    end,2)
end
function GameViewLayer:onShowMyselfResult()
    if not (self.hasBet == true or self.isBanker == true) then return end 
    local winSocre = self.game_result.lPlayAllScore  --得分
    if self.isBanker == true then  --自已是庄家
        winSocre = self.game_result.lBankerScore
    end
    local betScore = 0
    for i=1,8 do
        betScore = betScore + self.user_betScore[i]
    end
    self.user_score = self.user_score + winSocre + betScore
    local score = string.formatNumberThousands(self.user_score,true,".") 
    self.nodeUser:getChildByName("fntCoin"):setString(score)
    local txtWin = self.nodeUser:getChildByName("txtWin")
    if winSocre < 0 then
        txtWin:setFntFile(perfix.."font/num_result_lose.fnt")
        txtWin:setString(winSocre)
    elseif winSocre > 0 then
        txtWin:setFntFile(perfix.."font/num_result_win.fnt")
        txtWin:setString("+"..winSocre)        
    end
    local pos = txtWin:getPositionY()
    txtWin:setPositionY(pos - 30)
    TweenLite.to(txtWin, 0.15, { y = pos, ease = Sine.easeOut})
    performWithDelay(txtWin,function()
        txtWin:setString("")
    end,2)
end

function GameViewLayer:onInsertRecord()
    local data = {}
    if self.curCardPoint[1] > self.curCardPoint[2] then     --闲嬴
        data.cbType = 0
    elseif self.curCardPoint[1] == self.curCardPoint[2] then    --和
        data.cbType = 1
    else  -- 庄嬴
        data.cbType = 2
    end
    if #self.historyRecord >= 20 then
        table.remove(self.historyRecord,1)
    end
    table.insert(self.historyRecord,data)
    self:onUpdateHistory()
end

--cbType =1,空闲， =2 下注，3 结束
function GameViewLayer:onShowClock(cbType,time)
    self.spClock:setVisible(true)
    self.spClock:stopAllActions()
    local curTimeIndex = time
    self.txtClockTime:setString(curTimeIndex)
    local fileName = string.format("picture/sp_tip%d.png",cbType)
    self.txtState:setString(self.clockTxt[cbType])
    local delay = cc.DelayTime:create(1)
    local callback = cc.CallFunc:create(function()
        curTimeIndex = curTimeIndex -1
        self.txtClockTime:setString(curTimeIndex)
        if cbType == 2 and curTimeIndex <= 3 and curTimeIndex > 0 then
            g_ExternalFun.playEffect("sound/clockring.mp3")
        end
        if cbType == 2 and curTimeIndex == 3 then  --下注倒计时
            self:onPlayBetDaojishi()
        end
        if curTimeIndex == 0 then
            --self:onHideClock()
            if cbType == 2 then
                self:setChipEnabled(false)
                self:onPlayBetAni(2)
            end
        end
    end)
    local seq = cc.Sequence:create(delay,callback)
    self.spClock:runAction(cc.Repeat:create(seq,time))
end
function GameViewLayer:onPlayBetDaojishi()
	local daojishiNode = self.Panel_Effect:getChildByName("ANIM_DAOJISHI")
	if not daojishiNode then
		daojishiNode = cc.CSLoader:createNode("effect/daojishi/daojishi.csb")
		daojishiNode:setName("ANIM_DAOJISHI")
		daojishiNode:setPosition(960,540)
		self.Panel_Effect:addChild(daojishiNode, 1)
	end
	local action = cc.CSLoader:createTimeline("effect/daojishi/daojishi.csb")
	daojishiNode:runAction(action)
	action:play("Animation1", false)
end
--nType =1,开始下注，2 停止下注
function GameViewLayer:onPlayBetAni(nType)
	local kaijiangNode = self.Panel_Effect:getChildByName("ANIM_KAIJIANG")
	if not kaijiangNode then
		kaijiangNode = cc.CSLoader:createNode("effect/kaishixiazhu_kaijiang/kaishixiazhu_kaijiang.csb")
		kaijiangNode:setName("ANIM_KAIJIANG")
		kaijiangNode:setPosition(960,540)
		self.Panel_Effect:addChild(kaijiangNode, 2)
	end
	local action = cc.CSLoader:createTimeline("effect/kaishixiazhu_kaijiang/kaishixiazhu_kaijiang.csb")
	kaijiangNode:runAction(action)
    local anime = string.format("Animation%d",nType)
    local soundName = (nType == 1) and "sound/beganBet.mp3" or "sound/stopBet.mp3"
	action:play(anime, false)
    g_ExternalFun.playEffect(soundName)
end
--初始化桌上下注
function GameViewLayer:onInitDeskBetData(cmd_data)
    local allBet = cmd_data.lAllBet[1]
    local selfBet = cmd_data.lPlayBet[1]
    for i=1,8 do
        self.deskBetCount = self.deskBetCount + allBet[i]
        self.txt_allbet[i]:setString(allBet[i])
        self.txt_mybet[i]:setString(selfBet[i])
        self:onInitDeskChip(i,allBet[i])   --初始化筹码
    end
    self.txtDeskAllBet:setString(self.deskBetCount)
end
--初始化桌面筹码,
function GameViewLayer:onInitDeskChip(area,betScore)
    if betScore <= 0 then return end
    for i=6,1,-1 do
        local curChip = self.betConfig[i]
        while betScore >= curChip do
            betScore = betScore - curChip
	        local chip = self.m_flyChipLayer:getFlyChip(i, -1)
            self.m_flyChipLayer:toArea(false, chip, area, 1.44,1.44)
        end
    end
end
--显示牌结果 
function GameViewLayer:onShowCardInfo(cmd_data)
    self.nodeResult:setVisible(true)
	local userCard = { {}, {} }		--手牌数值
	local typeList = { 0, 0 }		--牌型点数
    local cbCardCount = cmd_data.cbCardCount[1]
    for k=1,2 do
        for i=1,cbCardCount[k] do
            table.insert(userCard[k], cmd_data.cbTableCardArray[k][i])
            local card = self.groupCards[k]:getChildByName("Image_Card_" .. i)
            card:setVisible(true)
            card:loadTexture( string.format("picture/card/%d.png", cmd_data.cbTableCardArray[k][i]))
        end
    end
	for i = 1, 2 do
		for _, v in ipairs(userCard[i]) do
			typeList[i] = (GameLogic:pokerValue(v) + typeList[i]) % 10
		end
	end
    self:showCardType(true, typeList)
end
function GameViewLayer:onFlyChip(wChairID,area,lScore,isSelf)
    local chipPosBegin = isSelf and cc.p(-770,-460) or cc.p(-870,180) 
    local chipIndex = 1
    for i=6,1,-1 do
        if lScore == self.betConfig[i] then
            chipIndex = i
        end
    end
	local chip = self.m_flyChipLayer:getFlyChip(chipIndex, wChairID)
	chip:setPosition(chipPosBegin)
	self.m_flyChipLayer:toArea(true, chip, area + 1, 1.44,1.44)
end

function GameViewLayer:onUpdateDeskBet(area,lScore)
    self.desk_betScore[area + 1] = self.desk_betScore[area + 1] + lScore
    local score = string.formatNumberThousands(self.desk_betScore[area + 1],true,".")
    self.txt_allbet[area + 1]:setString(score)
end
function GameViewLayer:onUpdateMyBet(area,lScore)
    self.user_betScore[area + 1] = self.user_betScore[area + 1] + lScore 
    self.last_betScore[area + 1] = self.last_betScore[area + 1] + lScore
    local score = string.formatNumberThousands(self.user_betScore[area + 1],true,".")
    self.txt_mybet[area + 1]:setString(score)
end

function GameViewLayer:onUpdateUserInfo(lScore)
    local score = string.formatNumberThousands(lScore,true,",")
    self.nodeUser:getChildByName("fntCoin"):setString(score)
end

function GameViewLayer:onUpdateHistory(clear)
    if clear then
        self.scrollview:removeAllChildren()
    else 
        self.scrollview:removeChildByTag(1)
    end
    local count = #self.historyRecord
    local width = count*60
    if width < 490 then
        width = 490
    end
    for i=1,count do
        local csbNode = self.scrollview:getChildByTag(i+1)
        if not csbNode then
            csbNode = g_ExternalFun.loadCSB(perfix.."LuDanUI.csb",nil,false)
            self.scrollview:addChild(csbNode)
        end
        csbNode:setPosition(34 + (i-1)*60,92)
        csbNode:setScale(1.44)
        csbNode:setTag(i)
        local cbType = self.historyRecord[i].cbType
        csbNode:getChildByName( string.format("sp%d",(cbType+1))):setVisible(true)
        if i == count then
            csbNode:getChildByName("spNew"):show()
        else
            csbNode:getChildByName("spNew"):hide()
        end
    end
    self.scrollview:setInnerContainerSize(cc.size(width,182))
    self.scrollview:jumpToRight()
end

function GameViewLayer:onUpdateTime()
    if self.cbGameStatues ~= GameStateBet then return end
    if #self.net_bet_data <= 0 then return end
    local cmd = table.remove(self.net_bet_data,1)   
    self:onUpdateUserBet(cmd)
end
function GameViewLayer:onUpdateUserBet(cmd_data)
    g_ExternalFun.playEffect("sound/soundbethigh.mp3")
    self:onUpdateDeskBet(cmd_data.cbBetArea,cmd_data.lBetScore)
    self:onFlyChip(cmd_data.wChairID,cmd_data.cbBetArea,cmd_data.lBetScore)
end
function GameViewLayer:onCheckUserBet(chair_id,bet_money)
    for i,v in pairs(self.bigBetChairId) do
        if v.chairID == chair_id then
            self.bigBet_BetScore[i] = self.bigBet_BetScore[i] + bet_money
            return
        end
    end
    for i,v in pairs(self.bigWinCountChairId) do
        if v.chairID == chair_id then
            self.bigWin_BetScore[i] = self.bigWin_BetScore[i] + bet_money
            return
        end
    end
end

function GameViewLayer:onCheckChipStates(money)
    if self.curChipIndex <=0 or money >= self.betConfig[self.curChipIndex] then
        for i=6,1,-1 do
            if money < self.betConfig[i] then
                self.btnChip[i]:setEnabled(false)
            end
        end
        return
    end
    for i=6,1,-1 do
        if money > self.betConfig[i] then
            self:onClickChip(i)
            self.btnChip[i]:setEnabled(true)
            return
        else
            self.btnChip[i]:setEnabled(false)
        end
    end
    self:onClickChip(1)
end

function GameViewLayer:onCheckXuYanStates()
    if self.isXuYaType == true then
        self.last_betScore = {0,0,0,0,0,0,0,0}
    end
    local allBet = 0
    for i,v in pairs(self.last_betScore) do
        allBet = allBet + v
    end
    self.isXuYaType = true
    self:setEnableXuYa(allBet>0 and allBet <= self.user_score)
end
function GameViewLayer:setEnableXuYa(enable)
    if self.btnXuyan then
        self.btnXuyan:setEnabled(enable)
    end
end

return GameViewLayer