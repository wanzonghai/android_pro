-- double游戏消息处理类
local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.double.src"
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
function GameLayer:sendUserBet(cbArea, lScore)
    tlog('GameLayer:sendUserBet ', cbArea, lScore)
    local cmddata = g_ExternalFun.create_netdata(g_var(cmd).CMD_C_PlaceBet)
    cmddata:pushbyte(cbArea)
    cmddata:pushscore(lScore)

    self:SendData(g_var(cmd).SUB_C_PLACE_JETTON, cmddata)
end

--请求10条记录,pFlag 是否刷新界面
function GameLayer:getGameRecordReq(pFlag)
    self.NeedRefresh = pFlag
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

------网络接收
-- 进游戏或重连时的场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    print("场景数据:" .. cbGameStatus)
    self.m_bOnGame = true
    self._gameView.m_cbGameStatus = cbGameStatus
    self._gameView.m_curRoundIsSelfBet = false
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
    tdump(cmd_table, "double_GameLayer:onEventGameSceneFree", 10)
    self._gameView:onGameFree()
    self._gameView:resetWithOriginPanel(0)
    --游戏倒计时
    self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEFREE_COUNTDOWN, cmd_table.cbTimeLeave, true)
end

--下注状态
function GameLayer:onEventGameSceneJetton(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusPlay, dataBuffer)
    tdump(cmd_table, "double_GameLayer:onEventGameSceneJetton", 10)
    self._gameView:resetJettonBtnShow(cmd_table.dwBetScore[1])
    --游戏倒计时
    self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEPLAY_COUNTDOWN, cmd_table.cbTimeLeave, true)
    self._gameView.m_totalBetTime = cmd_table.cbAllTime
    --下注信息
    local totalSelfBet = 0
    for i = 1, g_var(cmd).AREA_MAX do
        --界面总下注
        self._gameView:reEnterGameBet(i, cmd_table.lAllBet[1][i])

        --玩家下注
        local curBet = cmd_table.lPlayBet[1][i]
        self._gameView:reEnterUserBet(i, curBet)
        totalSelfBet = totalSelfBet + curBet
    end
    --游戏下注状态
    self._gameView:resetWithOriginPanel(0)
    self._gameView:reEnterStart(totalSelfBet)
    self._gameView:updatePlayerShow(cmd_table.wOccupySeatChairIDArray[1], true)
end

--游戏结束，开奖状态
function GameLayer:onEventGameSceneEnd(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusPlay, dataBuffer)
    tdump(cmd_table, "double_GameLayer:onEventGameSceneEnd", 10)
    self._gameView:resetJettonBtnShow(cmd_table.dwBetScore[1])
    --在倒计时栏展示结果即可
    self._gameView.m_endIndex = cmd_table.openNum
    self._gameView.m_totalBetTime = cmd_table.cbAllTime --结束状态时下发的时间是结束状态的总时间，暂时是没用到的
    --界面下注信息
    local curBet = 0
    for i = 1, g_var(cmd).AREA_MAX do
        --界面已下注
        curBet = cmd_table.lAllBet[1][i]
        self._gameView:reEnterGameBet(i, curBet)
        --玩家下注
        curBet = cmd_table.lPlayBet[1][i]
        self._gameView:reEnterUserBet(i, curBet)
    end
    self._gameView:resetWithOriginPanel(0)
    --下注区域需要设置
    self._gameView:reEnterEnd()
    --游戏倒计时
    self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEOVER_COUNTDOWN, cmd_table.cbTimeLeave, true)
    self._gameView:updatePlayerShow(cmd_table.wOccupySeatChairIDArray[1], true)
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
    elseif sub == cmd_command.SUB_S_UPDATE_OCCUPYSEAT then
        self:onUpdatePlayerShow(dataBuffer)
	else
		print("unknow gamemessage sub is ==>"..sub)
	end
end

--游戏空闲
function GameLayer:onSubGameFree(dataBuffer)
    print("game free")
    local cmd_gamefree = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GameFree, dataBuffer)
    tdump(cmd_gamefree, "double_GameLayer:onSubGameFree", 10)
    self._gameView:onGameFree()
    --游戏倒计时
    self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEFREE_COUNTDOWN, cmd_gamefree.cbTimeLeave, false)
end

--游戏开始
function GameLayer:onSubGameStart(dataBuffer)
    print("game start")
    local cmd_gamestart = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GameStart,dataBuffer)
    tdump(cmd_gamestart, "double_GameLayer:onSubGameStart", 10)
    self._gameView.m_totalBetTime = cmd_gamestart.cbTimeLeave
    --游戏倒计时
    self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEPLAY_COUNTDOWN, cmd_gamestart.cbTimeLeave, false)  
    self._gameView:onGameStart()
end

--游戏结束
function GameLayer:onSubGameEnd(dataBuffer)
    print("game end")
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GameEnd,dataBuffer)
    tdump(cmd_table, "double_GameLayer:onSubGameEnd", 10)
    --开始滚动动画
    self._gameView:startRoll(cmd_table.openNum)
    self._gameView:onGetGameEnd(cmd_table.lPlayScore)
    --游戏倒计时
    self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEOVER_COUNTDOWN, cmd_table.cbTimeLeave, false)
end

--用户下注
function GameLayer:onUserJettonEvent(dataBuffer)
    print("game bet")
    local cmd_placebet = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_PlaceBet, dataBuffer)
    tdump(cmd_placebet, "double_GameLayer:onUserJettonEvent", 10)
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
    cmd_table.openNum = dataBuffer:readbyte()
    cmd_table.openTimer = math.floor(dataBuffer:readscore(int64):getvalue() / 1000)
    --游戏记录
    local game_record = {}
    --读取记录列表
    for i = 1, recordcount do
        local userName = dataBuffer:readstring(g_var(cmd).LEN_NICKNAME)
        -- tlog('userName ', userName)
        local betData = {}
        for j = 1, g_var(cmd).AREA_MAX do
            local betScore = dataBuffer:readscore(int64):getvalue()
            table.insert(betData, betScore)
        end
        -- tdump(betData, "betData", 10)
        local winData = {}
        for j = 1, g_var(cmd).AREA_MAX do
            local betWinScore = dataBuffer:readscore(int64):getvalue()
            table.insert(winData, betWinScore)
        end
        -- tdump(winData, "winData", 10)
        for j, v in ipairs(betData) do
            local data = {}
            if v ~= 0 then
                data.userName = userName
                data.betScore = v
                data.betWinScore = winData[j]
                data.colorIndex = j
                table.insert(game_record, data)
            end
        end
    end
    cmd_table.game_record = game_record
    tdump(cmd_table, "GameLayer:onDetailRecordResp", 10)
    local historyDetailNode = self:getChildByName("historyDetailNode")
    if not historyDetailNode then
        historyDetailNode = GameHistoryDetailLayer:create():addTo(self, 11)
        historyDetailNode:setPosition(display.width * 0.5, display.height * 0.5)
        historyDetailNode:setName("historyDetailNode")
    end
    historyDetailNode:initWithData(cmd_table)
end

--记录页面信息返回(10条那个)
function GameLayer:onRecordResp(dataBuffer)
    local recordcount = dataBuffer:readbyte()
    local curStamp = math.floor(dataBuffer:readscore(int64):getvalue() / 1000)
    tlog('recordcount is ', recordcount, curStamp)
    --游戏记录
    local game_record = {}
    --读取记录列表
    for i = 1, recordcount do
        local data = {}
        data.cbSeverSeed = dataBuffer:readstring(g_var(cmd).SERVER_SEEDLEN)
        data.openNum = dataBuffer:readbyte()
        data.openTimer = math.floor(dataBuffer:readscore(int64):getvalue() / 1000)
        data.itemIndex = dataBuffer:readscore(int64):getvalue()
        table.insert(game_record, data)
    end
    tdump(game_record, "GameLayer:onRecordResp", 10)
    tlog('self._gameView.m_gameEndActionTime ', self._gameView.m_gameEndActionTime)
    if self._gameView.m_gameEndActionTime then
        --动画期间删除最新的一个记录
        table.remove(game_record, #game_record)
    end
    if self.NeedRefresh then
        local historyNode = GameHistoryLayer:create(game_record, curStamp):addTo(self, 10)
        historyNode:setPosition(display.width * 0.5, display.height * 0.5)
    else
        self._gameView:responeHistoryRecord(game_record)
    end
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
        local betScore = {}
        for j = 1, g_var(cmd).AREA_MAX do
            local betWinScore = dataBuffer:readscore(int64):getvalue()
            table.insert(betScore, betWinScore)
        end
        data.betScore = betScore
        table.insert(player_count_array, data)
    end
    tdump(player_count_array, "GameLayer:onServerPlayerBetInfoNotify", 10)
    self._dataModle:storeAllUserBetScore(player_count_array)
    self._gameView:onUpdateBetPlayerCoin(player_count_array)
end

--更新玩家显示
function GameLayer:onUpdatePlayerShow(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_UpdateOccupySeat, dataBuffer)
    tdump(cmd_table, "GameLayer:onUpdatePlayerShow", 10)
    self._gameView:updatePlayerShow(cmd_table.wOccupySeatChairIDArray[1], false)
end

--退出询问
function GameLayer:onQueryExitGame()
    tlog('GameLayer:onQueryExitGame ', self._gameView.m_curRoundIsSelfBet)
    if PriRoom and true == GlobalUserItem.bPrivateRoom then
        PriRoom:getInstance():queryQuitGame(self._gameView.m_cbGameStatus)
    else
        if self._queryDialog then
           return
        end
        if not self._gameView.m_curRoundIsSelfBet then
            --退出防作弊
            self._gameFrame:setEnterAntiCheatRoom(false)
            print("**************************************3333")
            self:onExitTable()
        else
            showToast("You have bet in the game. Please wait for the end of the game before exiting!")
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
    print("double_GameLayer:onEventUserEnter add user ", wTableID, wChairID, useritem.szNickName)
    --缓存用户
    self._dataModle:addUser(useritem)
    -- self._gameView:updateTotalPeople()
end

function GameLayer:onEventUserStatus(useritem, newstatus, oldstatus)
    local chairId = useritem.wChairID
    local tableId = useritem.wTableID
    local name = useritem.szNickName
    local newStatus = newstatus.cbUserStatus
    local oldStatus = oldstatus.cbUserStatus
    print("double_GameLayer:onEventUserStatus ", chairId, tableId, name, newStatus, oldStatus)
    if newStatus == G_NetCmd.US_FREE then
        print("删除")
        self._dataModle:removeUser(useritem)
    else
        --刷新用户信息
        self._dataModle:updateUser(useritem)
    end
    -- self._gameView:updateTotalPeople()
end

function GameLayer:onEventUserScore(item)
    -- tdump(item, 'GameLayer:onEventUserScore', 10)
    tlog("double_GameLayer:onEventUserScore ", item.wChairID, item.szNickName)
    self._dataModle:updateUser(item)
    self._gameView:onGetUserScore(item)
end

---------------------------------------------------------------------------------------
return GameLayer