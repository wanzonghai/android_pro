-- truco游戏消息处理类
local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.truco.src"
local cmd = module_pre .. ".models.CMD_Game"
local TrucoViewLayer = appdf.req(module_pre .. ".views.layer.TrucoViewLayer")
local g_var = g_ExternalFun.req_var
local GameFrame = appdf.req(module_pre .. ".models.GameFrame")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")

local int64 = Integer64.new()
int64:retain()

function GameLayer:ctor(frameEngine,scene)
    tlog("truco_GameLayer:ctor")
    g_ExternalFun.registerNodeEvent(self)
    self.m_bLeaveGame = false
    self.m_bOnGame = false
    self._dataModle = GameFrame:create()    
    GameLayer.super.ctor(self,frameEngine,scene)
    self._roomRule = self._gameFrame._dwServerRule
end

--创建场景
function GameLayer:CreateView()
    return TrucoViewLayer:create(self)
        :addTo(self)
end

function GameLayer:getParentNode()
    return self._scene
end

function GameLayer:getFrame()
    return self._gameFrame
end

function GameLayer:getUserList()
    return self._gameFrame._UserList
end

function GameLayer:sendNetData(cmddata)
    return self:getFrame():sendSocketData(cmddata)
end

function GameLayer:getDataMgr()
    return self._dataModle
end

function GameLayer:logData(msg)
    if nil ~= self._scene.logData then
        self._scene:logData(msg)
    end
end

---------------------------------------------------------------------------------------
------继承函数

--获取gamekind
function GameLayer:getGameKind()
    return g_var(cmd).KIND_ID
end

function GameLayer:onExit()
    tlog("truco_GameLayer:onExit")
    self:KillGameClock()
    GameLayer.super.onExit(self)
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    tlog('truco_GameLayer:OnResetGameEngine')
    self.m_bOnGame = false
    self._dataModle:removeAllUser()
    self._dataModle:initUserList(self:getUserList())
    self._gameView:initSelfInfo()
end

--强行起立、退出(用户切换到后台断网处理)
function GameLayer:standUpAndQuit()
    tlog("truco_GameLayer:standUpAndQuit")
    self:sendCancelOccupy()
    GameLayer.super.standUpAndQuit(self)
end

function GameLayer:onEnterRoom()
    tlog("truco_GameLayer:onEnterRoom")
    self:onExitTable()
    showToast(g_language:getString("game_tip_exit_room"))
end

--退出桌子
function GameLayer:onExitTable(_type)
    tlog("truco_GameLayer:onExitTable ", _type)
    self:KillGameClock()
    if _type ~= 1 then --破产的退出在结算界面处理
        self:onExitRoom()
    else
        self._gameFrame.bDelayQuit = true
        GameLogic:setEnableContinueGame(false)
    end
end

--离开房间
function GameLayer:onExitRoom()
    tlog("truco_GameLayer:onExitRoom ", self.m_bOnGame)
    if not self.m_bOnGame then
        self._gameFrame:StandUp(1)
    end
    self:getFrame():onCloseSocket()
    G_event:NotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)

    --self._scene:onKeyBack()
end

--准备
function GameLayer:Ready()
    tlog("truco_GameLayer:Ready ", self.m_bOnGame)
    if not self.m_bOnGame then
        self:getFrame():SendUserReady()
    else
        showToast(g_language:getString("game_tip_exit_room_2"))
    end
end

--站起
function GameLayer:StandUp()
    tlog("truco_GameLayer:StandUp")
    self:getFrame():StandUp(1)
end

--换桌
function GameLayer:SwitchTable()
    tlog("truco_GameLayer:SwitchTable ", self.m_bOnGame)
    if not self.m_bOnGame then
        showNetLoading()
        self:getFrame():QueryChangeDesk()
    else
        showToast(g_language:getString("game_tip_exit_room_2"))
    end
end

-- 计时器响应
function GameLayer:OnEventGameClockInfo(chair,time,clockId)
    if nil ~= self._gameView and nil ~= self._gameView.updateClock then
        self._gameView:updateClock(clockId, time)
    end
end

-- 设置计时器
function GameLayer:SetGameClock(chair, id, time, _isReenter)
    GameLayer.super.SetGameClock(self,chair,id,time)
    if nil ~= self._gameView and nil ~= self._gameView.showTimerTip then
        self._gameView:showTimerTip(id, time, _isReenter)
    end
end

---------------------------------------------------------------------------------------
------网络发送
--出牌请求
function GameLayer:gameDiscardReq(_isHide, _cardData)
    tlog('truco_GameLayer:gameDiscardReq ', _isHide, _cardData)
    local cmddata = g_ExternalFun.create_netdata(g_var(cmd).CMD_C_GAME_DISCARD)
    cmddata:pushbyte(_isHide)
    cmddata:pushbyte(_cardData)
    self:SendData(g_var(cmd).SUB_C_CMD_DISCARD, cmddata)
end

--认输
function GameLayer:gameGiveUpReq()
    tlog('truco_GameLayer:gameGiveUpReq')
    local cmddata = g_ExternalFun.create_netdata({})
    self:SendData(g_var(cmd).SUB_C_CMD_GIVEUP, cmddata)
end

--一局结束亮牌
function GameLayer:gameShowCardReq()
    tlog('truco_GameLayer:gameShowCardReq')
    local cmddata = g_ExternalFun.create_netdata({})
    self:SendData(g_var(cmd).SUB_C_CMD_SHOW_CARD, cmddata)
end

--发起truco
function GameLayer:gameStartTrucoReq(_trucoIndex)
    tlog('truco_GameLayer:gameStartTrucoReq ', _trucoIndex)
    local cmddata = g_ExternalFun.create_netdata(g_var(cmd).CMD_C_Truco)
    cmddata:pushbyte(_trucoIndex)
    self:SendData(g_var(cmd).SUB_C_CMD_TRUCO, cmddata)
end

--应答truco
function GameLayer:gameAnswerTrucoReq(_trucoIndex)
    tlog('truco_GameLayer:gameAnswerTrucoReq ', _trucoIndex)
    local cmddata = g_ExternalFun.create_netdata(g_var(cmd).CMD_C_AnswerTruco)
    cmddata:pushbyte(_trucoIndex)
    self:SendData(g_var(cmd).SUB_C_CMD_ANSWERTRUCO, cmddata)
end

--11分临界选择是否继续
function GameLayer:chooseContinueReq(_chooseIndex)
    tlog('truco_GameLayer:chooseContinueReq ', _chooseIndex)
    local cmddata = g_ExternalFun.create_netdata(g_var(cmd).CMD_C_ContinueGame)
    cmddata:pushbyte(_chooseIndex)
    self:SendData(g_var(cmd).SUB_C_CMD_CONTINUE_GAME, cmddata)
end

--托管/取消托管请求
function GameLayer:trusteeEnableReq(_chooseIndex)
    tlog('truco_GameLayer:trusteeEnableReq ', _chooseIndex)
    local cmddata = g_ExternalFun.create_netdata(g_var(cmd).CMD_C_Usertrustee)
    cmddata:pushbyte(_chooseIndex)
    self:SendData(g_var(cmd).SUB_C_USERTRUSTEE, cmddata)
end
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
------网络接收
-- 进游戏或重连时的场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    print("truco_onEventGameScene 场景数据:" .. cbGameStatus)
    self.m_bOnGame = false
    self._gameView:clearNetQueue()
	if cbGameStatus == g_var(cmd).GAME_SCENE_FREE then                        --空闲状态
        self:onEventGameSceneFree(dataBuffer)
	elseif cbGameStatus == g_var(cmd).GAME_PLAY or cbGameStatus == g_var(cmd).GAME_CALL or
        cbGameStatus == g_var(cmd).GAME_WAIT or cbGameStatus == g_var(cmd).GAME_SHOW then--游戏状态
        self:onEventGameScenePlay(dataBuffer)
	elseif cbGameStatus == g_var(cmd).GAME_END then                           --游戏结束状态
        self:onEventGameSceneEnd(dataBuffer)
	end
end

--没有free状态
function GameLayer:onEventGameSceneFree(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusFree, dataBuffer)
    tdump(cmd_table, "truco_GameLayer:onEventGameSceneFree", 10)
    dismissNetLoading()
    self._gameView:reEnterFree(cmd_table)
    --游戏倒计时
    -- self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEFREE_COUNTDOWN, cmd_table.cbTimeLeave / 1000, true)
end

--下注状态
function GameLayer:onEventGameScenePlay(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusPlay, dataBuffer)
    tdump(cmd_table, "truco_GameLayer:onEventGameScenePlay", 10)
    self.m_bOnGame = true
    self._gameView:reEnterStart(cmd_table)
end

--游戏结束，开奖状态
function GameLayer:onEventGameSceneEnd(dataBuffer)
    -- local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusPlay, dataBuffer)
    -- tdump(cmd_table, "truco_GameLayer:onEventGameSceneEnd", 10)
    -- self._gameView:reEnterEnd()
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub, dataBuffer)
    tlog('truco_GameLayer:onEventGameMessage ', sub)
    if self.m_bLeaveGame or nil == self._gameView then
        return
    end
    local cmd_command = g_var(cmd)
	if sub == cmd_command.SUB_S_GAME_START then 
		self:onSubGameStart(dataBuffer)
	elseif sub == cmd_command.SUB_S_GAME_END then 
		self:onSubGameEnd(dataBuffer)
    elseif sub == cmd_command.SUB_S_GAME_DEAL then
        self:onSendCardEvent(dataBuffer)
    elseif sub == cmd_command.SUB_S_GAME_OP_FAILD then

    elseif sub == cmd_command.SUB_S_GAME_UPDATE_ACTION then
        self:onFlushActionBtnEvent(dataBuffer)
    elseif sub == cmd_command.SUB_S_CMD_TRUCO then
        self:onTrucoEvent(dataBuffer)
    elseif sub == cmd_command.SUB_S_CMD_ANSWERTRUCO then
        self:onAnswerTrucoEvent(dataBuffer)
    elseif sub == cmd_command.SUB_S_CMD_SHOW_CARD then
        self:onShowCardEvent(dataBuffer)
    elseif sub == cmd_command.SUB_S_CMD_DISCARD then
        self:onOutCardEvent(dataBuffer)
    elseif sub == cmd_command.SUB_S_GAME_TURN_END then
        self:onShowTurnResultEvent(dataBuffer)
    elseif sub == cmd_command.SUB_S_CMD_CONTINUE_GAME then
        self:onContinueResultEvent(dataBuffer)
    elseif sub == cmd_command.SUB_S_SHOW_FRIEND_CARD then
        self:onShowFriendCardEvent(dataBuffer)
    elseif sub == cmd_command.SUB_S_GAME_CALLTRUCO_STATUS then
        self:onShowEnterTrucoStatus(dataBuffer)
    elseif sub == cmd_command.SUB_S_USERTRUSTEE then
        self:onShowTrusteeStatus(dataBuffer)
	else
		print("unknow gamemessage sub is ==>"..sub)
	end
end

--入列
function GameLayer:enterNetQueue(_subId, _netData)
    local data = {}
    data.subId = _subId
    data.netData = _netData
    self._gameView:pushNetQueue(data)
end

--游戏开始
function GameLayer:onSubGameStart(dataBuffer)
    -- local cmd_gamestart = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GameStart,dataBuffer)
    -- tdump(cmd_gamestart, "truco_GameLayer:onSubGameStart", 10)
end

--游戏结束
function GameLayer:onSubGameEnd(dataBuffer)
    tlog('truco_GameLayer:onSubGameEnd')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GameEnd, dataBuffer)
    -- tdump(cmd_table, "truco_GameLayer:onSubGameEnd", 10)
    self.m_bOnGame = false
    self:enterNetQueue(g_var(cmd).SUB_S_GAME_END, cmd_table)
end

--发牌
function GameLayer:onSendCardEvent(dataBuffer)
    tlog('truco_GameLayer:onSendCardEvent')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GAME_DEAL, dataBuffer)
    -- tdump(cmd_table, "truco_GameLayer:onSendCardEvent", 10)
    self.m_bOnGame = true
    self:enterNetQueue(g_var(cmd).SUB_S_GAME_DEAL, cmd_table)
end

--操作按钮消息
function GameLayer:onFlushActionBtnEvent(dataBuffer)
    tlog('truco_GameLayer:onFlushActionBtnEvent')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_DummePlayerAction, dataBuffer)
    -- tdump(cmd_table, "truco_GameLayer:onFlushActionBtnEvent", 10)
    self:enterNetQueue(g_var(cmd).SUB_S_GAME_UPDATE_ACTION, cmd_table)
end

--truco消息，按钮操作会另外发信息，这里只展示truco图标
function GameLayer:onTrucoEvent(dataBuffer)
    tlog('truco_GameLayer:onTrucoEvent')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_Truco, dataBuffer)
    -- tdump(cmd_table, "truco_GameLayer:onTrucoEvent", 10)
    self:enterNetQueue(g_var(cmd).SUB_S_CMD_TRUCO, cmd_table)
end

--truco应答消息
function GameLayer:onAnswerTrucoEvent(dataBuffer)
    tlog('truco_GameLayer:onAnswerTrucoEvent')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_AnswerTruco, dataBuffer)
    -- tdump(cmd_table, "truco_GameLayer:onAnswerTrucoEvent", 10)
    self:enterNetQueue(g_var(cmd).SUB_S_CMD_ANSWERTRUCO, cmd_table)
end

--展示手牌
function GameLayer:onShowCardEvent(dataBuffer)
    tlog('truco_GameLayer:onShowCardEvent')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_ShowCard, dataBuffer)
    -- tdump(cmd_table, "truco_GameLayer:onShowCardEvent", 10)
    self:enterNetQueue(g_var(cmd).SUB_S_CMD_SHOW_CARD, cmd_table)
end

--出牌返回
function GameLayer:onOutCardEvent(dataBuffer)
    tlog('truco_GameLayer:onOutCardEvent')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GAME_DISCARD, dataBuffer)
    -- tdump(cmd_table, "truco_GameLayer:onOutCardEvent", 10)
    self:enterNetQueue(g_var(cmd).SUB_S_CMD_DISCARD, cmd_table)
end

--一轮结束
function GameLayer:onShowTurnResultEvent(dataBuffer)
    tlog('truco_GameLayer:onShowTurnResultEvent')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_RoundGameEnd, dataBuffer)
    -- tdump(cmd_table, "truco_GameLayer:onShowTurnResultEvent", 10)
    self:enterNetQueue(g_var(cmd).SUB_S_GAME_TURN_END, cmd_table)
    EventPost:addCommond(EventPost.eventType.SPIN,"棋牌，truco，局次",3,nil,{gameId = cmd.KIND_ID,
        roomId = GlobalUserItem.roomMark
    })  
end

--11分临界情况是否继续
function GameLayer:onContinueResultEvent(dataBuffer)
    tlog('truco_GameLayer:onContinueResultEvent')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_ContinueGame, dataBuffer)
    self:enterNetQueue(g_var(cmd).SUB_S_CMD_CONTINUE_GAME, cmd_table)
end

--11分临界情况 展示队友手牌
function GameLayer:onShowFriendCardEvent(dataBuffer)
    tlog('truco_GameLayer:onShowFriendCardEvent')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_FriendShowCard, dataBuffer)
    self:enterNetQueue(g_var(cmd).SUB_S_SHOW_FRIEND_CARD, cmd_table)
end

--重连的时候已做的更新动作
function GameLayer:onShowEnterTrucoStatus(dataBuffer)
    tlog('truco_GameLayer:onShowEnterTrucoStatus')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_PlayerCallScoreAction, dataBuffer)
    self:enterNetQueue(g_var(cmd).SUB_S_GAME_CALLTRUCO_STATUS, cmd_table)
end

--托管消息广播
function GameLayer:onShowTrusteeStatus(dataBuffer)
    tlog('truco_GameLayer:onShowTrusteeStatus')
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_Usertrustee, dataBuffer)
    self:enterNetQueue(g_var(cmd).SUB_S_USERTRUSTEE, cmd_table)
end

--退出询问
function GameLayer:onQueryExitGame()
    tlog('truco_GameLayer:onQueryExitGame ', self.m_bOnGame)
    if not self.m_bOnGame then
        --退出防作弊
        self._gameFrame:setEnterAntiCheatRoom(false)
        print("**************************************3333")
        self:onExitTable()
    else
        showToast(g_language:getString("game_tip_exit_room_2"))
    end
end

function GameLayer:onEventUserEnter(wTableID, wChairID, useritem)
    print("truco_GameLayer:onEventUserEnter ", wTableID, wChairID, useritem.szNickName)
    --缓存用户
    self._dataModle:addUser(useritem)
    --有玩家加入，最终状态改变会走到onEventUserStatus
    -- self._gameView:updateSignelPeople(useritem)
end

function GameLayer:onEventUserStatus(useritem, newstatus, oldstatus)
    local chairId = useritem.wChairID
    local tableId = useritem.wTableID
    local name = useritem.szNickName
    local newStatus = newstatus.cbUserStatus
    local oldStatus = oldstatus.cbUserStatus
    print("truco_GameLayer:onEventUserStatus ", chairId, tableId, name, newStatus, oldStatus)
    if newstatus.cbUserStatus == G_NetCmd.US_FREE then
        print("删除")
        self._dataModle:removeUser(useritem)
        self._gameView:removeSignelPeople(useritem)
    else
        --刷新用户信息
        self._dataModle:updateUser(useritem)
        if newstatus.cbUserStatus >= G_NetCmd.US_SIT then
            self._gameView:updateSignelPeople(useritem)
        end
    end
end

function GameLayer:onEventUserScore(item)
    -- tdump(item, 'GameLayer:onEventUserScore', 10)
    self._dataModle:updateUser(item)
    self._gameView:onGetUserScore(item)
end

---------------------------------------------------------------------------------------
return GameLayer