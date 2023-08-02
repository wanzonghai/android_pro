-- jdob游戏消息处理类
local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.jdob.src"
local cmd = module_pre .. ".models.CMD_Game"
local WWNodeEx = appdf.req(appdf.CLIENT_SRC.."Tools.WWNodeEx")
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local QueryDialog = appdf.req("client.src.UIManager.QueryDialogNew")
local g_var = g_ExternalFun.req_var
local GameFrame = appdf.req(module_pre .. ".models.GameFrame")

local int64 = Integer64.new()
int64:retain()

function GameLayer:ctor(frameEngine,scene)
    g_ExternalFun.registerNodeEvent(self)
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("game/yule/jdob/res/UI/jdobGUIAnimPlist.plist", "game/yule/jdob/res/UI/jdobGUIAnimPlist.png")
    spriteFrameCache:addSpriteFrames("game/yule/jdob/res/UI/jdobGUIPlist.plist", "game/yule/jdob/res/UI/jdobGUIPlist.png")
    self._dataModle = GameFrame:create()    
    GameLayer.super.ctor(self,frameEngine,scene)
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
    display.removeSpriteFrames("game/yule/jdob/res/UI/jdobGUIAnimPlist.plist", "game/yule/jdob/res/UI/jdobGUIAnimPlist.png")
    display.removeSpriteFrames("game/yule/jdob/res/UI/jdobGUIPlist.plist", "game/yule/jdob/res/UI/jdobGUIPlist.png")
    display.removeUnusedSpriteFrames()
    cc.Director:getInstance():purgeCachedData()
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    tlog('GameLayer:OnResetGameEngine')
    self._dataModle:removeAllUser()
    self._dataModle:initUserList(self:getUserList())
    self._gameView:updateRoomUserNum()
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
end

------网络发送
--玩家下注(目前只支持单注)
function GameLayer:sendUserBet(betTb)
    tlog('GameLayer:sendUserBet ', betTb[1].betItemType, betTb[1].betType, betTb[1].betscore)
    local cmdData = CCmd_Data:create(1+#betTb*15)
    cmdData:pushbyte(#betTb)
    for i=1,#betTb do
        cmdData:pushbyte(betTb[i].betItemType)
        cmdData:pushbyte(betTb[i].betType)
        cmdData:pushscore(betTb[i].betscore)
        for j=1,g_var(cmd).ITEM_OPEN_COUNT do
            cmdData:pushbyte(betTb[i].betNumTb[j] or 0)
        end
    end
    
    self:SendData(g_var(cmd).SUB_C_BET, cmdData)
end

------网络接收
-- 进游戏或重连时的场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    tlog("场景数据:" .. cbGameStatus)
    local cmdData = g_ExternalFun.readData(g_var(cmd).CMD_S_SCENE_Data, dataBuffer)
    tdump(cmdData)
    local timestamp = tickMgr:getTime()
    cmdData.gameStateStamp = timestamp + cmdData.cbTimeLeave
    self._gameView:initGameOfScene(cmdData)
    self._gameView:updatePlayerShow(cmdData.showChairIDs, true)
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub, dataBuffer)
    tlog('GameLayer:onEventGameMessage ', sub)
    if nil == self._gameView then
        return
    end
    local cmd_command = g_var(cmd)
	if sub == cmd_command.SUB_S_PLACE_JETTON then 
		self:onUserPlaceBet(dataBuffer)
	elseif sub == cmd_command.SUB_S_PLACE_JETTON_FAIL then 
		self:onUserPlaceBetFail(dataBuffer)
    elseif sub == cmd_command.SUB_S_GAME_END then 
        self:onSubGameEndOpen(dataBuffer)
    elseif sub == cmd_command.SUB_S_USER_BET_DATA then
        self:onSubUserBetData(dataBuffer)
    elseif sub == cmd_command.SUB_S_SEND_ADDBETRECORD then
        self:onServerPlayerBetInfoNotify(dataBuffer)
    elseif sub == cmd_command.SUB_S_UPDATE_OCCUPYSEAT then
        self:onUpdatePlayerShow(dataBuffer)
    elseif sub == cmd_command.SUB_S_GAME_START then 
        self:onSubGameStart(dataBuffer)
    elseif sub == cmd_command.SUB_S_USER_DATA then
        self:onSubUserData(dataBuffer)
	else
		print("unknow gamemessage sub is ==>"..sub)
	end
end

--用户下注
function GameLayer:onUserPlaceBet(dataBuffer)
    tlog("game bet")
    local cmdData = g_ExternalFun.readData(g_var(cmd).CMD_S_PlaceBet, dataBuffer)
    --testcode
    tdump(cmdData, "jdob_GameLayer:onUserPlaceBet", 10)
    self._gameView:onUserPlaceBet(cmdData)
end
--下注失败
function GameLayer:onUserPlaceBetFail(dataBuffer)
    tlog("onUserPlaceBetFail")
    local cmdData = g_ExternalFun.readData(g_var(cmd).CMD_S_PlaceBetFail, dataBuffer)
    tdump(cmdData, "jdob_GameLayer:onUserPlaceBetFail", 10)
end

--开奖结果
function GameLayer:onSubGameEndOpen(dataBuffer)
    tlog("onSubGameEndOpen")
    local cmdData = g_ExternalFun.readData(g_var(cmd).CMD_S_GameEnd, dataBuffer)
    tdump(cmdData, "jdob_GameLayer:onSubGameEndOpen", 10)
    self._gameView:onSubGameEndOpen(cmdData)
end

--更新用户下注信息(下注记录)
function GameLayer:onSubUserBetData(dataBuffer)
    tlog("onSubUserBetData")
    local cmdData = g_ExternalFun.readData(g_var(cmd).CMD_S_SCENE_Bet_info, dataBuffer)
    tdump(cmdData, "jdob_GameLayer:onSubUserBetData", 10)
    self._gameView:onSubUserBetData(cmdData)
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
        local betScore = dataBuffer:readscore(int64):getvalue()
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
    self._gameView:updatePlayerShow(cmd_table.showChairIDs[1], false)
end
--游戏开始切到下注
function GameLayer:onSubGameStart(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GameStart, dataBuffer)
    tdump(cmd_table, "GameLayer:onSubGameStart", 10)
    self._gameView:onSubGameStart(cmd_table)
end

--用户赢分反馈（主要处理其他人，暂时未用到）
function GameLayer:onSubUserData(dataBuffer)
    tlog("onSubUserData")
    local cmdData = g_ExternalFun.readData(g_var(cmd).CMD_S_User_data, dataBuffer)
    tdump(cmdData, "jdob_GameLayer:onSubUserData", 10)
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
    print("jdob_GameLayer:onEventUserEnter add user ", wTableID, wChairID, useritem.szNickName)
    --缓存用户
    self._dataModle:addUser(useritem)
    self._gameView:updateRoomUserNum()
end

function GameLayer:onEventUserStatus(useritem, newstatus, oldstatus)
    local chairId = useritem.wChairID
    local tableId = useritem.wTableID
    local name = useritem.szNickName
    local newStatus = newstatus.cbUserStatus
    local oldStatus = oldstatus.cbUserStatus
    print("jdob_GameLayer:onEventUserStatus ", chairId, tableId, name, newStatus, oldStatus)
    if newStatus == G_NetCmd.US_FREE then
        print("删除")
        self._dataModle:removeUser(useritem)
    else
        --刷新用户信息
        self._dataModle:updateUser(useritem)
    end
    self._gameView:updateRoomUserNum()
end

function GameLayer:onEventUserScore(item)
    -- tdump(item, 'GameLayer:onEventUserScore', 10)
    tlog("jdob_GameLayer:onEventUserScore ", item.wChairID, item.szNickName)
    self._dataModle:updateUser(item)
    self._gameView:onGetUserScore(item)
end

---------------------------------------------------------------------------------------
return GameLayer