local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)
local module_pre = "game.yule.bonanza.src";

local ExternalFun = g_ExternalFun --appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = module_pre .. ".models.CMD_Game"
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local g_var = ExternalFun.req_var
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")

local emGameState =
{
    "GAME_STATE_WAITTING",              --等待                    --0
    "GAME_STATE_WAITTING_RESPONSE",     --发送开始后等待服务器响应  --1
    "GAME_STATE_MOVING",                --收到开始消息，开始转动    --2
}

local GAME_STATE = ExternalFun.declarEnumWithTable(0, emGameState)

function GameLayer:ctor( frameEngine,scene )
    tlog("bonanza_GameLayer:ctor")
    GameLayer.super.ctor(self,frameEngine,scene)
    ExternalFun.registerNodeEvent(self)
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
    tlog("bonanza_GameLayer:CreateView")
    self._gameView = GameViewLayer:create(self)
    self._gameView:created()
    self:addChild(self._gameView, 0, 2001)
    return self._gameView
end

function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)
    tlog("bonanza_GameLayer:OnInitGameEngine")
    self.m_cbGameMode           = 0     --游戏模式
    self._bReceiveSceneMsg      = false

    self.m_lScore               = 0     --玩家的游戏币
    self.m_Times                = 0     --倍数
    self.m_bYafenIndex          = 0     --压分索引(数组索引)
    self.m_lBetScore            = {}    --压分存储数组
    self.m_lTotalYafen          = 0     --总压分
    self.m_lWinScore            = 0     --一局游戏的总赢分(如果有消除，则是多次消除之和，否则等同于self.m_lGetCoins)
    self.m_lGetCoins            = 0     --一局中当前面板获得的金币数

    self.m_cbFreeTime           = 0     --剩余的free次数
    self.m_totalFreeTime        = 0     --免费期间总共的免费次数
    self.m_llFreeScore          = 0     --free期间获奖总数
    self.m_extraTimes           = 0     --有炸弹元素产生的额外倍数
    self.m_totalExtraTimes      = 0     --免费期间所有炸弹元素产生的额外倍数

    self.m_cbItemInfo           = {}    --开奖面板格子信息
    self.m_cbJLineArray         = {}    --中奖元素个数，数组为0表示没有中奖
    self.m_cbIconType           = {}    --中奖元素类型，数组为0表示没有中奖
    self.m_curRewardItemArray   = {}    --当前面板中奖元素合集

    self.m_bIsItemMove          = false --动画是否滚动的标示
    self:ResetAction()
end

function GameLayer:ResetAction()
    tlog("bananza_GameLayer:ResetAction")
    --5*6的数组，true表示该位置有中奖
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
    tlog('bonanza_GameLayer:onExitRoom')
	self._gameFrame:StandUp(1)
	self._gameFrame:onCloseSocket()
	self:KillGameClock()
    G_event:NotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)
end

-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
    print("bonanza_onEventGameScene 场景数据:" .. cbGameStatus)
    self:KillGameClock()
	self:onEventGameSceneFree(dataBuffer)
    self._bReceiveSceneMsg = true
    --清空10S提示界面
    self:hideTipsExit()
end

function GameLayer:onEventGameSceneFree(buffer)
    tlog('bonanza_GameLayer:onEventGameSceneFree')
    local cmd_table = {}
    cmd_table.dwBetScore = {}
    for i = 1, g_var(cmd).BET_INDEX_NUM do
       cmd_table.dwBetScore[i] = buffer:readdword()
    end
    local int64 = Integer64.new()
    cmd_table.lGameTotalScores = buffer:readscore(int64):getvalue()
    cmd_table.lGameModeScores = buffer:readscore(int64):getvalue()
    cmd_table.lGameScores = buffer:readscore(int64):getvalue()
    cmd_table.lUserScore = buffer:readscore(int64):getvalue()
    cmd_table.cbFreeTimes = buffer:readbyte()
    cmd_table.nBoomMultiples = buffer:readint()
    cmd_table.nTotalModeCounts = buffer:readint()
    self.m_cbFreeTime = cmd_table.cbFreeTimes
    self.m_lWinScore = cmd_table.lGameScores
    if self.m_cbFreeTime > 0 then
        self.m_llFreeScore = cmd_table.lGameModeScores
    else
        self.m_llFreeScore = 0
    end
    self.m_lGetCoins = 0
    self.m_totalExtraTimes = cmd_table.nBoomMultiples
    self.m_totalFreeTime = cmd_table.nTotalModeCounts
    cmd_table.cbItemInfo = {}
    -- local newData = {}
    self.m_extraTimes = 0
    local _index = 1
    for i = 1, GameLogic.ITEM_Y_COUNT do
        cmd_table.cbItemInfo[i] = {}
        for j = 1, GameLogic.ITEM_X_COUNT do
            local curIconType = buffer:readint()
            if curIconType > GameLogic.ITEM_LIST.ITEM_BOMB then
                tlog("enter origin icon type is ", curIconType)
                self.m_extraTimes = self.m_extraTimes + math.floor(curIconType / GameLogic.ITEM_LIST.ITEM_BOMB)
            end
            cmd_table.cbItemInfo[i][j] = curIconType
            -- newData[_index] = cmd_table.cbItemInfo[i][j]
            -- _index = _index + 1
        end
    end
    GameLogic.Reward_Scope.small = buffer:readscore(int64):getvalue() or GameLogic.Reward_Scope.small
    GameLogic.Reward_Scope.middle = buffer:readscore(int64):getvalue() or GameLogic.Reward_Scope.middle
    GameLogic.Reward_Scope.big = buffer:readscore(int64):getvalue() or GameLogic.Reward_Scope.big
    tdump(GameLogic.Reward_Scope, "GameLogic.Reward_Scope", 10)

    local dwHashID = buffer:readdword()
    local dwCRC = buffer:readdword()
    --初始化数据
    tdump(cmd_table, "bonanza_onEventGameSceneFree", 10)
    self.m_lBetScore = cmd_table.dwBetScore
    self.m_bYafenIndex = self.m_bYafenIndex == 0 and 1 or self.m_bYafenIndex
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex]         --总压分
    self.m_lScore = cmd_table.lUserScore
    self:setGameMode(GAME_STATE.GAME_STATE_WAITTING)
    self.m_bIsItemMove = false
    if self._gameView then
        while(true) do
            if self._gameView._isCreated then
                self:SendUserReady()
                self._gameView:updateScore(true)
                self._gameView:updateBetNumShow()
                self._gameView:onAddFreeTime(true)
                self._gameView:updataBtnEnable()
                self._gameView.m_scrollLayer:setGameSceneData(cmd_table.cbItemInfo)
                -- if dwHashID and dwHashID > 0 and self._gameView._txtHashId then
                --     local _crcMark = 0
                --     if dwCRC and dwCRC > 0 then
                --         _crcMark = 1
                --         local newCRC = Calc_crc(0,newData,15)
                --         if newCRC ~= dwCRC then
                --             _crcMark = 2
                --         end
                --     end
                --     self._gameView._txtHashId:setString(dwHashID.._crcMark)
                -- end
                break
            end
        end 
    end
end

-----------------------------------------------------------------------------------
-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)
    tlog("bonanza_GameLayer:onEventGameMessage ", sub)
    if sub == g_var(cmd).SUB_S_GAME_START then 
        self:onGameStart(dataBuffer)                       --游戏开始   
        --清空10S提示界面
        self:hideTipsExit()
    else
        print("unknow gamemessage sub is "..sub)
    end
end

--游戏开始
function GameLayer:onGameStart(dataBuffer) --游戏开始
    tlog("bonanza_GameLayer:onGameStart")
    local bNeedGameOption = false
    local int64 = Integer64.new()
    local cmd_table = {}
    self.m_extraTimes = 0
    cmd_table.lAllWinScore = dataBuffer:readscore(int64):getvalue()
    cmd_table.lUserScore = dataBuffer:readscore(int64):getvalue()
    cmd_table.cbAllFreeTimes = dataBuffer:readbyte()  --总的免费次数，此字段说明有新的免费模式次数。
    local curTotalFreeTimes = cmd_table.cbAllFreeTimes
    if self.m_cbFreeTime > 0 and curTotalFreeTimes > self.m_cbFreeTime then
        --免费中又中了免费，先刷新当局显示，再加上这些免费次数
        self.m_cbFreeTime = self.m_cbFreeTime - 1
        self._gameView:updateFreeTimeShow()
        self.m_cbFreeTime = curTotalFreeTimes
    else
        --正常刷新
        self.m_cbFreeTime = curTotalFreeTimes
        self._gameView:updateFreeTimeShow()
    end
    cmd_table.cbGameMode = dataBuffer:readbyte()
    cmd_table.dwHashID = dataBuffer:readdword()
    cmd_table.cbDataCount = dataBuffer:readbyte()
    cmd_table.cbItemInfo = {}
    cmd_table.childcount = cmd_table.cbDataCount - 1
    local _crcMark = 0
    if cmd_table.cbDataCount >= 1 then
        cmd_table.cbFreeTimes = dataBuffer:readbyte()
        self.m_totalFreeTime = self.m_totalFreeTime + cmd_table.cbFreeTimes
        cmd_table.lScore = dataBuffer:readscore(int64):getvalue()
        cmd_table.cbJLineArray = {}
        for i = 1, GameLogic.YAXIANNUM do
            cmd_table.cbJLineArray[i] = dataBuffer:readbyte()
        end
        cmd_table.cbIconType = {}
        for i = 1, GameLogic.YAXIANNUM do
            cmd_table.cbIconType[i] = dataBuffer:readbyte()
        end
        for i = 1, GameLogic.ITEM_Y_COUNT do
            cmd_table.cbItemInfo[i] = {}
            for j = 1, GameLogic.ITEM_X_COUNT do
                local curIconType = dataBuffer:readint()
                if curIconType > GameLogic.ITEM_LIST.ITEM_BOMB then
                    tlog("start origin icon type is ", curIconType)
                    self.m_extraTimes = self.m_extraTimes + math.floor(curIconType / GameLogic.ITEM_LIST.ITEM_BOMB)
                end
                cmd_table.cbItemInfo[i][j] = curIconType
            end
        end
        local dwCRC = dataBuffer:readdword()
        -- _crcMark = 1
        -- if dwCRC and dwCRC > 0 then
        --     local newData = {}
        --     for i=1,15 do
        --         local x = math.ceil(i/5)
        --         local y = i%5
        --         y = y>0 and y or 5
        --         newData[i] =  cmd_table.cbItemInfo[x][y]
        --     end
        --     local newCRC = Calc_crc(0,newData,15)
        --     if newCRC ~= dwCRC then
        --         bNeedGameOption = true
        --         _crcMark = 2
        --     end
        -- end
    end
    self.m_totalExtraTimes = self.m_totalExtraTimes + self.m_extraTimes
    cmd_table.childitem = {}
    if cmd_table.childcount > 0 then
        for k = 1, cmd_table.childcount do
            cmd_table.childitem[k] = { }
            cmd_table.childitem[k].cbItemInfo = {}
            local freeTimes = dataBuffer:readbyte()
            cmd_table.childitem[k].cbFreeTime = freeTimes
            self.m_totalFreeTime = self.m_totalFreeTime + freeTimes
            cmd_table.childitem[k].lScore = dataBuffer:readscore(int64):getvalue()
            cmd_table.childitem[k].cbJLineArray = {}
            for i = 1, GameLogic.YAXIANNUM do
               cmd_table.childitem[k].cbJLineArray[i] = dataBuffer:readbyte()
            end
            cmd_table.childitem[k].cbIconType = {}
            for i = 1, GameLogic.YAXIANNUM do
               cmd_table.childitem[k].cbIconType[i] = dataBuffer:readbyte()
            end
            for i = 1, GameLogic.ITEM_Y_COUNT do
                cmd_table.childitem[k].cbItemInfo[i] = {}
                for j = 1, GameLogic.ITEM_X_COUNT do
                    cmd_table.childitem[k].cbItemInfo[i][j] = dataBuffer:readint()
                end
            end
            local dwCRC = dataBuffer:readdword()
            -- if bNeedGameOption == false and dwCRC and dwCRC > 0 then
            --     local newData = {}
            --     for i=1,15 do
            --         local x = math.ceil(i/5)
            --         local y = i%5
            --         y = y>0 and y or 5
            --         newData[i] =   cmd_table.childitem[k].cbItemInfo[x][y]
            --     end
            --     local newCRC = Calc_crc(0,newData,15)
            --     if newCRC ~= dwCRC then
            --         bNeedGameOption = true
            --         _crcMark = 2
            --     end
            -- end
        end
    end
    -- if cmd_table.dwHashID and  cmd_table.dwHashID>0 and self._gameView._txtHashId then
    --     self._gameView._txtHashId:setString(cmd_table.dwHashID.._crcMark)
    -- end
    if bNeedGameOption == true then   --需要发送场景 消息
        self:setGameMode(GAME_STATE.GAME_STATE_WAITTING)
        self._gameFrame:SendGameOption()
        self._gameView:updataBtnEnable()
        return
    end
    self:setGameMode(GAME_STATE.GAME_STATE_MOVING)
    self._gameView:updataBtnEnable()
    tdump(cmd_table, "bonanza_onGameStart", 10)
    self.m_tStartDate = cmd_table

    self.m_cbDeleteTime = 0
    self.m_lWinScore = 0 --更新使用
    self.m_Times = 0

    -- self._gameView:onAddFreeTime(self.m_cbFreeTime) 

    self.m_lGetCoins = cmd_table.lScore
    if cmd_table.cbGameMode == g_var(cmd).GM_NULL then
        self.m_lScore = self.m_lScore - self.m_lTotalYafen
        self.m_llFreeScore = 0
        self._gameView:updateScore(true) --此时只有总金币需要更新
    elseif cmd_table.cbGameMode == g_var(cmd).GM_FREE then
        self._gameView:updateScore(true) --在总的赢金币值之前更新
        self.m_llFreeScore = self.m_llFreeScore + self.m_lGetCoins
    else
        self.m_llFreeScore = 0
    end

    self.m_lScore = self.m_lScore + self.m_lGetCoins
    self.m_lWinScore = self.m_lWinScore +self.m_lGetCoins
    self.m_cbItemInfo = GameLogic:copyTab(cmd_table.cbItemInfo)
    self.m_cbJLineArray = cmd_table.cbJLineArray
    self.m_cbIconType = cmd_table.cbIconType

    self:calculateResult()
    --开始游戏
    self.m_bIsItemMove = true
    self._gameView:gameBegin()
end

function GameLayer:onDeleteGameStart()
    tlog("bananza_GameLayer:onDeleteGameStart ", self.m_cbDeleteTime)
    self._gameView:updateScore()
    self.m_cbDeleteTime = self.m_cbDeleteTime + 1
    local curDataInfo = self.m_tStartDate.childitem[self.m_cbDeleteTime]
    if not curDataInfo then
        showToast(g_language:getString("game_tip_no_sub_item"))
        return
    end
    dump(curDataInfo, "curDataInfo_onDeleteGameStart", 10)

    self.m_lGetCoins = curDataInfo.lScore
    self.m_cbItemInfo = curDataInfo.cbItemInfo
    --叠加特殊元素炸弹的倍数
    for i = 1, GameLogic.ITEM_Y_COUNT do
        for j = 1, GameLogic.ITEM_X_COUNT do
            local curIconType = self.m_cbItemInfo[i][j]
            if curIconType > GameLogic.ITEM_LIST.ITEM_BOMB then
                tlog("origin icon type is ", curIconType)
                self.m_extraTimes = self.m_extraTimes + math.floor(curIconType / GameLogic.ITEM_LIST.ITEM_BOMB)
            end
        end
    end
    self.m_totalExtraTimes = self.m_totalExtraTimes + self.m_extraTimes
    self.m_cbJLineArray = curDataInfo.cbJLineArray
    self.m_cbIconType = curDataInfo.cbIconType

    self.m_lScore = self.m_lScore + self.m_lGetCoins
    self.m_lWinScore = self.m_lWinScore + self.m_lGetCoins
    self.m_llFreeScore = self.m_llFreeScore + self.m_lGetCoins

    self:calculateResult()
    self._gameView:DeleteGame()
end

--换算一下结果
--一个6*5的数组，有消除的为true，没消除的为false
function GameLayer:calculateResult()
    tlog("bananza_GameLayer:calculateResult")
    self:ResetAction()
    local rewardItemArray = {} --中奖的物品元素合集
    for i, rewardNum in ipairs(self.m_cbJLineArray) do
        if rewardNum > 0 then
            local iconType = self.m_cbIconType[i]
            if iconType > GameLogic.ITEM_LIST.ITEM_BOMB then
                iconType = GameLogic.ITEM_LIST.ITEM_BOMB
            end
            -- --普通元素最少8个，12个以上相同
            -- if iconType <= 8 then
            --     if rewardNum > 12 then
            --         rewardNum = 12
            --     end
            --     rewardNum = rewardNum - 7
            -- elseif iconType == 9 then
            --     --免费元素最少4个，6个以上相同
            --     if rewardNum > 6 then
            --         rewardNum = 6
            --     end
            --     rewardNum = rewardNum - 3
            -- end
            -- tlog("iconType rewardNum ", iconType, rewardNum)
            -- local curRateInfo = GameLogic.ITEM_REWARD_RATE_INFO[iconType + 1]
            -- if curRateInfo then --炸弹没有
            --     local curRate = curRateInfo[rewardNum]
            --     self.m_Times = self.m_Times + curRate
            -- end

            table.insert(rewardItemArray, iconType)
        end
    end
    if #rewardItemArray > 0 then
        for i = 1, GameLogic.ITEM_X_COUNT  do
            local tab = {}
            for j = 1, GameLogic.ITEM_Y_COUNT do
                local curIcon = self.m_cbItemInfo[j][i]
                if curIcon > GameLogic.ITEM_LIST.ITEM_BOMB then
                    curIcon = GameLogic.ITEM_LIST.ITEM_BOMB
                end
                --isRewardIcon 0表示没有奖励，1表示普通物品奖励，2表示免费，3表示炸弹
                local isRewardIcon = 0
                for k, v in ipairs(rewardItemArray) do
                    if curIcon == v then
                        if curIcon < GameLogic.ITEM_LIST.ITEM_FREE then
                            isRewardIcon = 1
                        elseif curIcon == GameLogic.ITEM_LIST.ITEM_FREE then
                            isRewardIcon = 2
                        elseif curIcon >= GameLogic.ITEM_LIST.ITEM_BOMB then
                            isRewardIcon = 3
                        end
                        break
                    end
                end
                self.m_broadRewardStatus[j][i] = isRewardIcon
            end
        end
    end
    tdump(self.m_broadRewardStatus, "self.m_broadRewardStatus", 10)
    self.m_curRewardItemArray = rewardItemArray
    tdump(self.m_curRewardItemArray, "self.m_curRewardItemArray", 10)
end

--获取当前面板上的元素是否有可消除元素
--当面板上可消除元素只有free和爆炸的时候不消除
function GameLayer:checkCurBoardEnableRemove()
    local enableRemove = false
    for i, v in ipairs(self.m_curRewardItemArray) do
        if v ~= GameLogic.ITEM_LIST.ITEM_FREE and v ~= GameLogic.ITEM_LIST.ITEM_BOMB then
            enableRemove = true
            break
        end
    end
    tlog("GameLayer:checkCurBoardEnableRemove ", enableRemove)
    return enableRemove
end

function GameLayer:setGameMode(state)
    tlog("bananza_GameLayer:setGameMode ", state)
    self.m_cbGameMode = state
end

--获取游戏状态
function GameLayer:getGameMode()
    tlog("bananza_GameLayer:getGameMode ", self.m_cbGameMode)
    if self.m_cbGameMode then
        return self.m_cbGameMode
    end
end

--游戏开始
function GameLayer:GameStart()
    tlog("bananza_GameLayer:GameStart")
    if self._bReceiveSceneMsg == false or self.m_bIsItemMove == true then
        return
    end

    if self.m_cbGameMode == GAME_STATE.GAME_STATE_WAITTING then
        if self.m_lTotalYafen > self.m_lScore and self.m_cbFreeTime <= 0 then
            --提示游戏币不足
            showToast(g_language:getString('game_tip_no_money'))
            return
        end
        self:sendStartMsg()--发送准备消息
        print("goldvase============gamestart")
    end
end

function GameLayer:onNormalStartBtnClick()
    tlog('GameLayer:onNormalStartBtnClick ', self.m_cbGameMode)
    --等待状态
    if self.m_cbGameMode == GAME_STATE.GAME_STATE_WAITTING then
        self:GameStart()
    else
        tlog("not enable game mode for roll")
    end
end

--自动游戏
function GameLayer:onAutoStart()
    tlog("bananza_GameLayer:onAutoStart")
    if self.m_lTotalYafen > self.m_lScore then
        showToast(g_language:getString('game_tip_no_money'))
        --处理auto按钮回退显示成开始按钮
        self._gameView:reflushBtnStatusByStopAuto()
        return
    end
    self:GameStart()
end

--最大加注
function GameLayer:onAddMaxScore()
    tlog("bananza_GameLayer:onAddMaxScore")
    self.m_bYafenIndex = #self.m_lBetScore
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] --总压分
    self._gameView:updateBetNumShow()
end

--最小加注
function GameLayer:onAddMinScore()
    tlog("bananza_GameLayer:onAddMinScore")
    self.m_bYafenIndex = 1
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex]--总压分
    self._gameView:updateBetNumShow()
end

--加注
function GameLayer:onAddScore()
    tlog("bananza_GameLayer:onAddScore")

    self.m_bYafenIndex = self.m_bYafenIndex + 1
    if self.m_bYafenIndex > #self.m_lBetScore then
        self.m_bYafenIndex = 1
    end
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex]--总压分
    self._gameView:updateBetNumShow()
end

--减注
function GameLayer:onSubScore()
    tlog("bananza_GameLayer:onSubScore")
    self.m_bYafenIndex = self.m_bYafenIndex - 1 
    if self.m_bYafenIndex < 1 then
        self.m_bYafenIndex = #self.m_lBetScore
    end
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex]--总压分
    self._gameView:updateBetNumShow()
end

--发送准备消息
function GameLayer:sendStartMsg()
    tlog("bananza_GameLayer:sendStartMsg ", self.m_lTotalYafen)
    if self.m_lTotalYafen <= 0 then
        return false
    end
    self.m_bIsItemMove = true
    local  dataBuffer = CCmd_Data:create(1)
    dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME, g_var(cmd).SUB_C_ONE_START)   
    dataBuffer:pushbyte(self.m_bYafenIndex-1) 
    EventPost:addCommond(EventPost.eventType.SPIN,"slot每次spin",1,nil,{gameId = self:getGameKind(),
        roomId = GlobalUserItem.roomMark,betPrice = self.m_lTotalYafen
    })
    local ref=self._gameFrame:sendSocketData(dataBuffer) 
    if ref then
        print("发送开始游戏1消息")
    end
    return ref
end

function GameLayer:sendNetData( cmddata )
    return self._gameFrame:sendSocketData(cmddata)
end

--踢出消息10S 提示
function GameLayer:onOutGameTips()
    self:showTipsExit()
end

--退出询问
function GameLayer:onQueryExitGame()
    tlog('GameLayer:onQueryExitGame')
    if self._queryDialog then
       return
    end
    if self.m_cbGameMode == GAME_STATE.GAME_STATE_WAITTING and self._gameView:getBtnStatusIsNormal() then
        --退出防作弊
        self._gameFrame:setEnterAntiCheatRoom(false)
        -- print("**************************************3333")
        self:onExitTable()
        -- self._queryDialog = QueryDialog:create({g_language:getString("exit_game_tip")}, function(ok)
        --     if ok == true then
        --     end
        --     self._queryDialog = nil
        -- end,2)
        -- self:addChild(self._queryDialog)
    else
        showToast(g_language:getString("game_tip_exit_room_1"))
    end
end

return GameLayer