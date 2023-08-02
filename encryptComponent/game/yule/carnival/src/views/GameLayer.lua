local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)
local module_pre = "game.yule.carnival.src";

local cmd = module_pre .. ".models.CMD_Game"
local CarnivalViewLayer = appdf.req(module_pre .. ".views.layer.CarnivalViewLayer")
local g_var = g_ExternalFun.req_var
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")

function GameLayer:ctor( frameEngine,scene )
    tlog("carnival_GameLayer:ctor")
    GameLayer.super.ctor(self,frameEngine,scene)
    g_ExternalFun.registerNodeEvent(self)
    self._gameFrame:QueryUserInfo(self:GetMeUserItem().wTableID,G_NetCmd.INVALID_CHAIR)
    self._bReceiveSceneMsg = false
end

function GameLayer:getGameKind()
    return g_var(cmd).KIND_ID
end

function GameLayer:getFrame()
    return self._gameFrame
end

--创建场景
function GameLayer:CreateView()
    tlog("carnival_GameLayer:CreateView")
    self._gameView = CarnivalViewLayer:create(self)
    self:addChild(self._gameView, 0, 2001)
    return self._gameView
end

function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)
    tlog("carnival_GameLayer:OnInitGameEngine")
    self._bReceiveSceneMsg      = false

    self.m_lScore               = 0     --玩家的游戏币
    self.m_bYafenIndex          = 0     --压分索引(数组索引)
    self.m_lBetScore            = {}    --压分存储数组
    self.m_lTotalYafen          = 0     --总压分
    self.m_lGetCoins            = 0     --一局中当前面板获得的金币数

    self.m_cbFreeTime           = 0     --剩余的free次数
    self.m_totalFreeTime        = 0     --免费期间总共的免费次数
    self.m_llFreeScore          = 0     --free期间获奖总数
    self.m_newFreeGot           = 0     --free期间是否获得free次数,不为0则是获得的次数

    self.m_bonusStartIndex      = 0     --开始bonus动画的列数

    self.m_cbItemInfo           = {}    --开奖面板格子信息
    self.m_cbJLineArray         = {}    --中奖元素个数，数组为0表示没有中奖
    self:ResetAction()
end

function GameLayer:ResetAction()
    tlog("carnival_GameLayer:ResetAction")
    --4*5的数组，1表示该位置有中奖
    self.m_broadRewardStatus = {}
    for i = 1, GameLogic.ITEM_Y_COUNT do
        self.m_broadRewardStatus[i] = {}
        for j = 1,GameLogic.ITEM_X_COUNT do
            self.m_broadRewardStatus[i][j] = 0
        end
    end
end

function GameLayer:onExit()
    GameLayer.super.onExit(self)
    
    self:KillGameClock()
end

function GameLayer:onExitTable()
    self:onExitRoom()
end

--离开房间
function GameLayer:onExitRoom()
    tlog('carnival_GameLayer:onExitRoom')
	self._gameFrame:StandUp(1)
	self._gameFrame:onCloseSocket()
	self:KillGameClock()
    G_event:NotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)
end

-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
    print("carnival_onEventGameScene 场景数据:" .. cbGameStatus)
    self:KillGameClock()
    --清空10S提示界面
    self:hideTipsExit()
	self:onEventGameSceneFree(dataBuffer)
    self._bReceiveSceneMsg = true
end

function GameLayer:onEventGameSceneFree(dataBuffer)
    local cmd_table = g_ExternalFun.readData(g_var(cmd).CMD_S_StatusFree, dataBuffer)
    tdump(cmd_table, "carnival_onEventGameSceneFree", 10)
    self.m_cbFreeTime = cmd_table.frees_count
    self.m_lGetCoins = cmd_table.winScore
    self.m_llFreeScore = cmd_table.freeWinScore
    self.m_cbItemInfo = clone(cmd_table.result_icons)
    self.m_cbJLineArray = clone(cmd_table.zJLineArray)
    self.m_lScore = cmd_table.lScore
    self.m_mysteryType = cmd_table.nMysteryNewType
    self.m_totalFreeTime = cmd_table.nTotalModeCounts
    self.m_newFreeGot = 0
    self.m_bonusStartIndex = 0
    GameLogic:setGameMode(GameLogic.gameState.state_wait)
    while(true) do
        if self._gameView then
            self._gameView:updateBroadIconShow(self.m_cbItemInfo)
            self._gameView:updateScore(true)
            self._gameView:updateBetNumShow()
            self._gameView:checkFreeStatus(true)
            self._gameView:updataBtnEnable()
            break
        end
    end
    self:printBoardShow()
end

-----------------------------------------------------------------------------------
-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)
    tlog("carnival_GameLayer:onEventGameMessage ", sub)
    if sub == g_var(cmd).SUB_S_GAME_CONFIG then 
        self:onGameConfig(dataBuffer)                      --游戏配置
    elseif sub == g_var(cmd).SUB_S_GAME_START then 
        self:onGameStart(dataBuffer)                       --游戏开始   
    else
        print("unknow gamemessage sub is "..sub)
    end
end

--游戏空闲
function GameLayer:onGameConfig(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_GameConfig, dataBuffer)
    tdump(cmd_table, "carnival_GameLayer:onGameConfig", 10)
    self.m_lBetScore = cmd_table.betArray[1]
    self.m_bYafenIndex = self.m_bYafenIndex == 0 and 1 or self.m_bYafenIndex
    local max_line = GameLogic.TOTAL_LINE
    self.m_bYafenIndex = self:getBetIndex(self.m_lBetScore,max_line)
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * GameLogic.TOTAL_LINE --总压分

    GameLogic.Reward_Scope.small = cmd_table.small
    GameLogic.Reward_Scope.middle = cmd_table.middle
    GameLogic.Reward_Scope.big = cmd_table.big
end

--游戏开始
function GameLayer:onGameStart(dataBuffer) --游戏开始
    local cmd_table = g_ExternalFun.readData(g_var(cmd).CMD_S_GameStart, dataBuffer)
    tdump(cmd_table, "carnival_GameLayer:onGameStart", 10)

    local curTotalFreeTimes = cmd_table.zsGameCount --总的免费次数，此字段说明有新的免费模式次数。
    local oldFreeTimes = self.m_cbFreeTime - 1 --开局后剩余的旧的免费次数
    if self.m_cbFreeTime > 0 and curTotalFreeTimes > self.m_cbFreeTime then
        --免费中又中了免费，先刷新当局显示，再加上这些免费次数
        self.m_cbFreeTime = oldFreeTimes
        self._gameView:updateFreeTimeShow()
        self.m_cbFreeTime = curTotalFreeTimes
    else
        --正常刷新
        self.m_cbFreeTime = curTotalFreeTimes
        self._gameView:updateFreeTimeShow()
    end
    if oldFreeTimes < 0 then
        oldFreeTimes = 0
    end
    local newFreeTimes = curTotalFreeTimes - oldFreeTimes
    self.m_newFreeGot = newFreeTimes
    tlog('self.m_newFreeGot ', self.m_newFreeGot)
    self.m_totalFreeTime = self.m_totalFreeTime + newFreeTimes
    GameLogic:setGameMode(GameLogic.gameState.state_playAni)

    self.m_lGetCoins = 0
    if cmd_table.game_mode == g_var(cmd).GM_NULL then
        self.m_lScore = self.m_lScore - self.m_lTotalYafen
        self.m_llFreeScore = 0
        self._gameView:updateScore(true) --此时只有总金币需要更新
    elseif cmd_table.game_mode == g_var(cmd).GM_FREE then
        self._gameView:updateScore(true) --在总的赢金币值之前更新
        self.m_llFreeScore = self.m_llFreeScore + cmd_table.lWinScore
    else
        self.m_llFreeScore = 0
    end

    self.m_lGetCoins = cmd_table.lWinScore
    self.m_lScore = cmd_table.lScore
    self.m_cbItemInfo = clone(cmd_table.result_icons)
    self.m_cbJLineArray = clone(cmd_table.zJLineArray)
    self.m_mysteryType = cmd_table.nMysteryNewType
    self:printBoardShow()
    self:calculateResult()
    --开始游戏
    self._gameView:gameBegin()
    --清空10S提示界面
    self:hideTipsExit()
end

function GameLayer:printBoardShow()
    for i = 1, GameLogic.ITEM_Y_COUNT do
        local itemInfo = self.m_cbItemInfo[i]
        tlog("GameLayer:printBoardShow --- ", itemInfo[1], itemInfo[2], itemInfo[3], itemInfo[4], itemInfo[5])
    end
end

--换算一下结果
--一个4*5的数组，有中奖的为1,没中奖的为0
function GameLayer:calculateResult()
    tlog("carnival_GameLayer:calculateResult")
    -- self.m_testArray = {}
    self:ResetAction()
    for i, rewardNum in ipairs(self.m_cbJLineArray) do
        if rewardNum > 0 then
            local data = {}
            data.line = i
            data.nums = rewardNum
            -- table.insert(self.m_testArray, data)
            tlog("i is ", i, rewardNum)
            -- tdump(GameLogic.gameLineDef, "GameLogic.gameLineDef", 10)
            local lineArray = GameLogic.gameLineDef[i]
            for j = 1, rewardNum do
                local gridPos = lineArray[j]
                self.m_broadRewardStatus[gridPos[1] + 1][gridPos[2] + 1] = 1
            end
        end
    end
    local bonusCountArray = {0, 0, 0, 0, 0}
    self.m_bonusStartIndex = 0

    --bonus动画
    for i = 1, GameLogic.ITEM_Y_COUNT do
        for j = 1, GameLogic.ITEM_X_COUNT do
            local itemType = self.m_cbItemInfo[i][j]
            -- tlog('itemType ', itemType)
            if itemType == GameLogic.ITEM_LIST.ITEM_FREE or
            (itemType == GameLogic.ITEM_LIST.ITEM_MYSTERY and self.m_mysteryType == GameLogic.ITEM_LIST.ITEM_FREE) then
                if self.m_newFreeGot > 0 then
                    self.m_broadRewardStatus[i][j] = 1
                end
                if itemType == GameLogic.ITEM_LIST.ITEM_FREE then
                    bonusCountArray[j] = bonusCountArray[j] + 1
                end
            end
        end
    end

    tdump(bonusCountArray, "bonusCountArray", 10)
    local bonusCount = 0
    for i, v in ipairs(bonusCountArray) do
        bonusCount = bonusCount + v
        if bonusCount >= 4 then
            self.m_bonusStartIndex = i + 1
            break
        end
    end
    for i = 1, GameLogic.ITEM_Y_COUNT do
        local status = self.m_broadRewardStatus[i]
        tlog("rewardStatus ", status[1], status[2], status[3], status[4], status[5])
    end
end

--自动游戏
function GameLayer:autoStartEvent()
    tlog("carnival_GameLayer:autoStartEvent")
    if self.m_lTotalYafen > self.m_lScore then
        showToast(g_language:getString('game_tip_no_money'))
        --处理auto按钮回退显示成开始按钮
        self._gameView:reflushBtnStatusByStopAuto()
        return
    end
    self:gameStart()
end

--游戏开始
function GameLayer:gameStart()
    tlog("carnival_GameLayer:gameStart")
    if self._bReceiveSceneMsg == false then
        return
    end

    if GameLogic:getGameMode() == GameLogic.gameState.state_wait then
        if self.m_lTotalYafen > self.m_lScore and self.m_cbFreeTime <= 0 then
            --提示游戏币不足
            showToast(g_language:getString('game_tip_no_money'))
            return
        end
        self._gameView:stopAllAnimation()
        self:sendStartMsg()--发送准备消息
        print("carnival_GameLayer:gameStart over ---")
    end
end

--发送准备消息
function GameLayer:sendStartMsg()
    tlog("carnival_GameLayer:sendStartMsg ", self.m_lTotalYafen)
    if self.m_lTotalYafen <= 0 then
        return false
    end
    local  dataBuffer = CCmd_Data:create(1)
    dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME, g_var(cmd).SUB_C_ONE_START)   
    -- dataBuffer:pushint(self.m_lTotalYafen) 
    dataBuffer:pushbyte(self.m_bYafenIndex) 
    local ref = self._gameFrame:sendSocketData(dataBuffer) 
    if ref then
        print("发送开始游戏1消息")
    end
    EventPost:addCommond(EventPost.eventType.SPIN,"slot每次spin",1,nil,{gameId = self:getGameKind(),
        roomId = GlobalUserItem.roomMark,betPrice = self.m_lTotalYafen
    })  
    return ref
end

--最大加注
function GameLayer:onAddMaxScore()
    tlog("carnival_GameLayer:onAddMaxScore")
    self.m_bYafenIndex = #self.m_lBetScore
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * GameLogic.TOTAL_LINE --总压分
    self._gameView:updateBetNumShow()
end

--最小加注
function GameLayer:onAddMinScore()
    tlog("carnival_GameLayer:onAddMinScore")
    self.m_bYafenIndex = 1
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * GameLogic.TOTAL_LINE--总压分
    self._gameView:updateBetNumShow()
end

--加注
function GameLayer:onAddScore()
    tlog("carnival_GameLayer:onAddScore")

    self.m_bYafenIndex = self.m_bYafenIndex + 1
    if self.m_bYafenIndex > #self.m_lBetScore then
        self.m_bYafenIndex = 1
    end
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * GameLogic.TOTAL_LINE--总压分
    self._gameView:updateBetNumShow()
end

--减注
function GameLayer:onSubScore()
    tlog("carnival_GameLayer:onSubScore")
    self.m_bYafenIndex = self.m_bYafenIndex - 1 
    if self.m_bYafenIndex < 1 then
        self.m_bYafenIndex = #self.m_lBetScore
    end
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * GameLogic.TOTAL_LINE--总压分
    self._gameView:updateBetNumShow()
end

--踢出消息10S 提示
function GameLayer:onOutGameTips()
    self:showTipsExit()
end

--退出询问
function GameLayer:onQueryExitGame()
    tlog('GameLayer:onQueryExitGame')
    if GameLogic:getGameMode() == GameLogic.gameState.state_wait and self._gameView:getBtnStatusIsNormal() then
        --退出防作弊
        self._gameFrame:setEnterAntiCheatRoom(false)
        -- print("**************************************3333")
        self:onExitTable()
    else
        showToast(g_language:getString("game_tip_exit_room_1"))
    end
end

return GameLayer