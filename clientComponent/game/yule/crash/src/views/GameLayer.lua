-- double游戏消息处理类
local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.crash.src"
local cmd = module_pre .. ".models.CMD_Game"
local game_cmd = appdf.CLIENT_SRC .. "NetProtocol.CMD_GameServer"
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local GameHistoryLayer = appdf.req(module_pre .. ".views.layer.GameHistoryLayer")
local GameHistoryDetailLayer = appdf.req(module_pre .. ".views.layer.GameHistoryDetailLayer")
local QueryDialog = appdf.req("client.src.UIManager.QueryDialogNew")
local g_var = g_ExternalFun.req_var
local GameFrame = appdf.req(module_pre .. ".models.GameFrame")

local int64 = Integer64.new()
int64:retain()

function GameLayer:ctor(frameEngine,scene)
    g_ExternalFun.registerNodeEvent(self)
    self.m_bLeaveGame = false
    self.m_bOnGame = false
    self._dataModle = GameFrame:create()    
    GameLayer.super.ctor(self,frameEngine,scene)
    self._roomRule = self._gameFrame._dwServerRule
end

--创建场景
function GameLayer:CreateView()
    return GameViewLayer:create(self)
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
    self:KillGameClock()
    GameLayer.super.onExit(self)
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    tlog('GameLayer:OnResetGameEngine')
    self.m_bOnGame = false
    self._dataModle:removeAllUser()
    self._dataModle:initUserList(self:getUserList())
    self._gameView:updateTotalPeople()
end

--强行起立、退出(用户切换到后台断网处理)
function GameLayer:standUpAndQuit()
    self:sendCancelOccupy()
    GameLayer.super.standUpAndQuit(self)
end

function GameLayer:onEnterRoom()
    self:onExitTable()
    showToast(g_language:getString("game_tip_exit_room"))
end

--退出桌子
function GameLayer:onExitTable()
    self:KillGameClock()
    self:onExitRoom()
end

--离开房间
function GameLayer:onExitRoom()
    self._gameFrame:StandUp(1)
    self:getFrame():onCloseSocket()

    --self._scene:onKeyBack()    
    G_event:NotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)
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

------网络发送
--玩家下注
function GameLayer:sendUserBet(betCrash, lScore)
    local cmddata = g_ExternalFun.create_netdata(g_var(cmd).CMD_C_PlaceBet)
    local betNum1, betNum2 = math.modf(betCrash * 100) --发给服务器的乘100
    tlog('GameLayer:sendUserBet ', betCrash, lScore, betNum1, betNum2)
    if betNum2 >= 0.99999999 then --精度问题
        betNum1 = betNum1 + 1
    end
    cmddata:pushint(betNum1)
    cmddata:pushscore(lScore)

    self:SendData(g_var(cmd).SUB_C_PLACE_JETTON, cmddata)
end

--请求10条记录
function GameLayer:getGameRecordReq()
    tlog('GameLayer:getGameRecordReq')
    local cmddata = g_ExternalFun.create_netdata({})
    self:SendData(g_var(cmd).SUB_C_SEND_GAMERECORD, cmddata)
end

--请求某条详细记录
function GameLayer:getGameDetailRecordReq(_index, _startPage, _pageSize)
    tlog('GameLayer:getGameDetailRecordReq ', _index, _startPage, _pageSize)
    local cmddata = g_ExternalFun.create_netdata(g_var(cmd).CMD_C_GetRecordItem)
    cmddata:pushscore(_index)
    cmddata:pushint(_startPage)
    cmddata:pushint(_pageSize)

    self:SendData(g_var(cmd).SUB_C_SEND_ITEMRECORD, cmddata)
end

--开奖过程中用户停止额度，立即开奖
function GameLayer:stopBetCrashReq(_chairId, _betCrash)
    local cmddata = g_ExternalFun.create_netdata(g_var(cmd).CMD_C_End_BetCrash)
    local betNum1, betNum2 = math.modf(_betCrash * 100) --发给服务器的乘100
    tlog('GameLayer:stopBetCrashReq ', _chairId, _betCrash, betNum1, betNum2)
    if betNum2 >= 0.99999999 then --精度问题
        betNum1 = betNum1 + 1
    end
    cmddata:pushword(_chairId)
    cmddata:pushint(betNum1)

    self:SendData(g_var(cmd).SUB_C_END_BETCRASH, cmddata)
end

------网络接收
-- 进游戏或重连时的场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    print("crash_onEventGameScene 场景数据:" .. cbGameStatus)
    self.m_bOnGame = true
    self._gameView.m_cbGameStatus = cbGameStatus
    self._gameView.m_curRoundSelfBetRate = -1
	if cbGameStatus == g_var(cmd).GAME_SCENE_FREE then                        --空闲状态
        self:onEventGameSceneFree(dataBuffer)
	elseif cbGameStatus == g_var(cmd).GAME_JETTON then                        --下注状态
        self:onEventGameSceneJetton(dataBuffer)
	elseif cbGameStatus == g_var(cmd).GAME_END then                           --游戏结束状态
        self:onEventGameSceneEnd(dataBuffer)
	end
end

--没有free状态
function GameLayer:onEventGameSceneFree(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusFree, dataBuffer)
    tdump(cmd_table, "crash_GameLayer:onEventGameSceneFree", 10)
    self._gameView:onGameFree()
    --游戏倒计时
    -- self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEFREE_COUNTDOWN, cmd_table.cbTimeLeave / 1000, true)
end

--下注状态
function GameLayer:onEventGameSceneJetton(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusPlay, dataBuffer)
    tdump(cmd_table, "crash_GameLayer:onEventGameSceneJetton", 10)
    -- self._gameView:resetJettonBtnShow(cmd_table.dwBetScore[1])
    --游戏倒计时
    self._gameView.m_totalBetTime = cmd_table.cbAllTime / 1000
    self._gameView.m_calculateFactory = cmd_table.cbTimeStep      --根据倍数计算时间的方程的基数
    self._gameView.m_betConfig = cmd_table.dwBetScoreConfig[1]
    self._gameView.m_min_bet_money = cmd_table.dwBetScoreConfig[1][1]
    self._gameView:updateMyBetMoney(self._gameView.m_min_bet_money)
    for i,v in ipairs(cmd_table.dwMultipleConfig[1]) do
        cmd_table.dwMultipleConfig[1][i]=v/100
    end
    self._gameView.m_multipleConfig = cmd_table.dwMultipleConfig[1]
    --玩家下注信息
    --cmd_table.lPlayBet 和 cmd_table.lBetCrash 两个一个有值，另一个也会有，end状态同
    local curBet = cmd_table.lPlayBet
    local curRate = -1
    if cmd_table.lBetCrash >= 0 then
        curRate = cmd_table.lBetCrash / 100
    end
    self._gameView:reEnterUserBet(curBet, curRate)
    self._gameView:reEnterStart(curBet, curRate)
    --游戏下注状态也在这里设置了
    self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEPLAY_COUNTDOWN, cmd_table.cbTimeLeave / 1000, true)
end

--游戏结束，开奖状态
function GameLayer:onEventGameSceneEnd(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusPlay, dataBuffer)
    tdump(cmd_table, "crash_GameLayer:onEventGameSceneEnd", 10)
    -- self._gameView:resetJettonBtnShow(cmd_table.dwBetScore[1])
    --在倒计时栏展示结果即可
    local _totalTime = cmd_table.cbAllTime / 1000
    self._gameView.m_calculateFactory = cmd_table.cbTimeStep
    --下注区域需要设置
    local curRate = -1
    if cmd_table.lBetCrash >= 0 then
        curRate = cmd_table.lBetCrash / 100
    end
    local timeLeft = 0
    if cmd_table.openNum ~= 0 then
        --已经出结果
        self._gameView.m_endIndex = cmd_table.openNum / 100
        timeLeft = 1
    end
    self._gameView.m_betConfig = cmd_table.dwBetScoreConfig[1]
    self._gameView.m_min_bet_money = cmd_table.dwBetScoreConfig[1][1]
    self._gameView:updateMyBetMoney(self._gameView.m_min_bet_money)
    for i,v in ipairs(cmd_table.dwMultipleConfig[1]) do
        cmd_table.dwMultipleConfig[1][i]=v/100
    end
    self._gameView.m_multipleConfig = cmd_table.dwMultipleConfig[1]
    self._gameView:reEnterUserBet(cmd_table.lPlayBet, curRate)
    self._gameView:reEnterEnd(cmd_table.isPressBetCrash == 0, curRate, timeLeft)
    --玩家下注信息
    self._gameView:startRoll(_totalTime)
    --游戏倒计时
    self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEOPEN_COUNTDOWN, timeLeft, true)
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub, dataBuffer)
    tlog('GameLayer:onEventGameMessage ', sub)
    if self.m_bLeaveGame or nil == self._gameView then
        return
    end
    local cmd_command = g_var(cmd)
	if sub == cmd_command.SUB_S_GAME_FREE then 
        self._gameView.m_cbGameStatus = cmd_command.GAME_SCENE_FREE
		self:onSubGameFree(dataBuffer)
	elseif sub == cmd_command.SUB_S_GAME_START then 
        self._gameView.m_cbGameStatus = cmd_command.GAME_START
		self:onSubGameStart(dataBuffer)
	elseif sub == cmd_command.SUB_S_PLACE_JETTON then 
        self._gameView.m_cbGameStatus = cmd_command.GAME_PLAY
		self:onUserJettonEvent(dataBuffer)
	elseif sub == cmd_command.SUB_S_GAME_END then 
        self._gameView.m_cbGameStatus = cmd_command.GAME_PLAY
		self:onSubGameEnd(dataBuffer)
    elseif sub == cmd_command.SUB_S_END_OPEN_NUM then 
        self._gameView.m_cbGameStatus = cmd_command.GAME_PLAY
        self:onSubGameOpenReward(dataBuffer)
	elseif sub == cmd_command.SUB_S_CHANGE_USER_SCORE then 
		self:onSubChangeUserScore(dataBuffer)
    elseif sub == cmd_command.SUB_S_SEND_RECORD then
        self:onSubSendRecord(dataBuffer)
    elseif sub == cmd_command.SUB_S_PLACE_JETTON_FAIL then
        self:onSubJettonFail(dataBuffer)
    elseif sub == cmd_command.SUB_S_AMDIN_COMMAND then
        self:onSubAdminCmd(dataBuffer)
    elseif sub == cmd_command.SUB_S_UPDATE_STORAGE then
        self:onSubUpdateStorage(dataBuffer)
    elseif sub == cmd_command.SUB_S_SEND_ITEMRECORD then
        self:onDetailRecordResp(dataBuffer)
    elseif sub == cmd_command.SUB_S_SEND_GAMERECORD then
        self:onRecordResp(dataBuffer)
    elseif sub == cmd_command.SUB_S_SEND_ADDBETRECORD then
        self:onServerPlayerBetInfoNotify(dataBuffer)
    elseif sub == cmd_command.SUB_S_END_BETCRASH then
        self:onEndBetCrashSuccessNotify(dataBuffer)
    elseif sub == cmd_command.SUB_S_END_BETCRASH_FAIL then
        self:onEndBetCrashFailed(dataBuffer)
	else
		print("unknow gamemessage sub is ==>"..sub)
	end
end

--游戏空闲
function GameLayer:onSubGameFree(dataBuffer)
    print("game free")
    local cmd_gamefree = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GameFree, dataBuffer)
    tdump(cmd_gamefree, "crash_GameLayer:onSubGameFree", 10)
    self._gameView:onGameFree()
    --游戏倒计时
    -- self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEFREE_COUNTDOWN, cmd_gamefree.cbTimeLeave / 1000, false)
end

--游戏开始
function GameLayer:onSubGameStart(dataBuffer)
    print("game start")
    local cmd_gamestart = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GameStart,dataBuffer)
    tdump(cmd_gamestart, "crash_GameLayer:onSubGameStart", 10)
    local _leaveTime = cmd_gamestart.cbTimeLeave / 1000
    self._gameView.m_totalBetTime = _leaveTime
    --游戏倒计时
    self._gameView:onGameStart()
    self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEPLAY_COUNTDOWN, _leaveTime, false)  
end

--游戏结束,给开奖号码过来
function GameLayer:onSubGameEnd(dataBuffer)
    -- print("game end")
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GameEnd,dataBuffer)
    tdump(cmd_table, "crash_GameLayer:onSubGameEnd", 10)
    self._gameView.m_endIndex = cmd_table.openNum / 100
    -- --游戏倒计时
    self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEEND_COUNTDOWN, cmd_table.cbTimeLeave / 1000, false)
    self._gameView:onGetGameEnd()
end

--游戏开奖
function GameLayer:onSubGameOpenReward(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_End_Open_Num,dataBuffer)
    tdump(cmd_table, "crash_GameLayer:onSubGameOpenReward", 10)
    --开始滚动动画
    self._gameView:startRoll()
    self._gameView:onGetGameOpen()
    --游戏倒计时
    self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEOPEN_COUNTDOWN, 0, false)
end

--用户下注
function GameLayer:onUserJettonEvent(dataBuffer)
    print("game bet")
    local cmd_placebet = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_PlaceBet, dataBuffer)
    cmd_placebet.cbBetCrash = cmd_placebet.cbBetCrash / 100
    tdump(cmd_placebet, "crash_GameLayer:onUserJettonEvent", 10)
    self._gameView:onGetUserBet(cmd_placebet)
end

--下注失败，未处理
function GameLayer:onSubJettonFail(dataBuffer)
    local cmd_jettonfail = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_PlaceBetFail, dataBuffer)
    self._gameView:onGetUserBetFail(cmd_jettonfail)
end

--更新积分
function GameLayer:onSubChangeUserScore(dataBuffer)
end

--游戏记录
function GameLayer:onSubSendRecord(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_ServerOpenGameRecord, dataBuffer)
    tdump(cmd_table, "GameLayer:onSubSendRecord", 10)
    self._gameView:initHistoryNode(cmd_table)
end

--管理员命令
function GameLayer:onSubAdminCmd(dataBuffer)
end

--更新库存
function GameLayer:onSubUpdateStorage(dataBuffer)
end

--详细记录信息返回
function GameLayer:onDetailRecordResp(dataBuffer)
    local cmd_table = {}
    cmd_table.itemIndex = dataBuffer:readbyte()
    cmd_table.startpage = dataBuffer:readint()
    cmd_table.pagesize = dataBuffer:readint()
    cmd_table.totalcount = dataBuffer:readint()
    local recordcount = dataBuffer:readint()
    cmd_table.recordcount = recordcount
    tlog("recordcount is ", recordcount)
    cmd_table.openNum = dataBuffer:readint() / 100
    cmd_table.openTimer = math.floor(dataBuffer:readscore(int64):getvalue() / 1000)
    --游戏记录
    local game_record = {}
    --读取记录列表
    for i = 1, recordcount do
        local betData = {}
        betData.userName = dataBuffer:readstring(g_var(cmd).LEN_NICKNAME)
        tlog('betData.userName ', betData.userName)
        betData.betScore = dataBuffer:readscore(int64):getvalue()
        betData.betCrash = dataBuffer:readint()
        betData.betWinScore = dataBuffer:readscore(int64):getvalue()
        table.insert(game_record, data)
    end
    cmd_table.game_record = game_record
    tdump(cmd_table, "GameLayer:onDetailRecordResp", 10)
    local historyDetailNode = self:getChildByName("historyDetailNode")
    if not historyDetailNode then
        historyDetailNode = GameHistoryDetailLayer:create():addTo(self, 11)
        historyDetailNode:setPosition(display.width * 0.5 - g_offsetX, display.height * 0.5)
    end
    historyDetailNode:initWithData(cmd_table)
end

--记录页面信息返回(10条那个)
function GameLayer:onRecordResp(dataBuffer)
    local recordcount = dataBuffer:readbyte()
    local curStamp = math.floor(dataBuffer:readscore(int64):getvalue() / 1000)
    tlog('recordcount is ', recordcount, curStamp, self._gameView.m_gameEndActionTime)
    --游戏记录
    local game_record = {}
    --读取记录列表
    for i = 1, recordcount do
        local data = {}
        data.winCount = dataBuffer:readint()
        data.openNum = dataBuffer:readint() / 100
        data.openTimer = math.floor(dataBuffer:readscore(int64):getvalue() / 1000)
        data.itemIndex = dataBuffer:readscore(int64):getvalue()
        table.insert(game_record, data)
    end
    tdump(game_record, "crash_GameLayer:onRecordResp", 10)
    local historyNode = GameHistoryLayer:create(game_record, curStamp):addTo(self, 10)
    historyNode:setPosition(display.width * 0.5 - g_offsetX, display.height * 0.5)
end

--进游戏或重连时推送当前所有玩家下注消息
function GameLayer:onServerPlayerBetInfoNotify(dataBuffer)
    local playerCount = dataBuffer:readint()
    tlog('playerCount is ', playerCount)
    --所有玩家下注列表
    local player_count_array = {}
    --读取记录列表
    for i = 1, playerCount do
        local data = {}
        data.chairId = dataBuffer:readint()
        data.betCrash = dataBuffer:readint() / 100
        data.betScore = dataBuffer:readscore(int64):getvalue()
        table.insert(player_count_array, data)
    end
    tdump(player_count_array, "GameLayer:onServerPlayerBetInfoNotify", 10)
    self._dataModle:storeAllUserBetScore(player_count_array)
    self._gameView:enterUpdatePlayerList()
end

--停止倍数成功
function GameLayer:onEndBetCrashSuccessNotify(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_End_BetCrash, dataBuffer)
    tdump(cmd_table, "GameLayer:onEndBetCrashSuccessNotify", 10)
    self._gameView:onEndBetCrashSuccessNotify(cmd_table)
end

--停止倍数失败(一般在非开奖阶段停止会失败)
function GameLayer:onEndBetCrashFailed(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_End_BetCrashFail, dataBuffer)
    tdump(cmd_table, "GameLayer:onEndBetCrashFailed", 10)
    -- self._gameView:initHistoryNode(cmd_table)
    showToast(g_language:getString("crash_stop_failed"))
end

--退出询问
function GameLayer:onQueryExitGame()
    tlog('GameLayer:onQueryExitGame ', self._gameView.m_curRoundSelfBetRate)
    if PriRoom and true == GlobalUserItem.bPrivateRoom then
        PriRoom:getInstance():queryQuitGame(self._gameView.m_cbGameStatus)
    else
        if self._queryDialog then
           return
        end
        if self._gameView.m_curRoundSelfBetRate <= -1 then
            --退出防作弊
            self._gameFrame:setEnterAntiCheatRoom(false)
            print("**************************************3333")
            self:onExitTable()
        else
            showToast(g_language:getString("game_tip_exit_room_1"))
        end
        -- self._queryDialog = QueryDialog:create({"Game already started, if you have bet, the system will deduct","Certain happy beans, are you sure to quit this game?"}, function(ok)
        --     if ok == true then
        --         --退出防作弊
        --         self._gameFrame:setEnterAntiCheatRoom(false)
        --         print("**************************************3333")
        --         self:onExitTable()
        --     end
        --     self._queryDialog = nil
        -- end,2)
        -- self._queryDialog:setPosition(display.width * 0.5 - 1334 / 2, display.height * 0.5 - 750 / 2)
        -- self:addChild(self._queryDialog)
    end
end

function GameLayer:onEventUserEnter(wTableID,wChairID,useritem)
    print("GameLayer:onEventUserEnter add user " .. useritem.wChairID .. "; nick " .. useritem.szNickName)
    --缓存用户
    self._dataModle:addUser(useritem)
    self._gameView:updateTotalPeople()
end

function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)
    print("GameLayer:onEventUserStatus change user " .. useritem.wChairID .. "; nick " .. useritem.szNickName)
    if newstatus.cbUserStatus == G_NetCmd.US_FREE then
        print("删除")
        self._dataModle:removeUser(useritem)
    else
        --刷新用户信息
        self._dataModle:updateUser(useritem)
    end
    self._gameView:updateTotalPeople()
end

function GameLayer:onEventUserScore(item)
    -- tdump(item, 'GameLayer:onEventUserScore', 10)
    self._dataModle:updateUser(item)
    self._gameView:onGetUserScore(item)
end

---------------------------------------------------------------------------------------
return GameLayer