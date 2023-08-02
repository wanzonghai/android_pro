local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)
local module_pre = "game.yule.newcaishen.src"
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")


function GameLayer:ctor(frameEngine,scene)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    GameLayer.super.ctor(self,frameEngine,scene)
end

--创建场景
function GameLayer:CreateView()
    g_ExternalFun:stopMusic()
    self._gameView = GameViewLayer:create(self)
    self:addChild(self._gameView, 0, 2001)
    return self._gameView
end


-- function GameLayer:getParentNode()
--     return self._scene
-- end
function GameLayer:getFrame()
    return self._gameFrame
end
function GameLayer:onUiExitTable()
    performWithDelay(self._gameView,function() 
        self:onExitTable()
    end,2)
    self:KillGameClock()  --关闭计时器
    self:getFrame():StandUp(1)
end
--退出桌子
function GameLayer:onExitTable()
    self._gameView:removeSprite()
    self:getFrame():onCloseSocket()
    G_event:NotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)
end

--离开房间
function GameLayer:onExitRoom()
end

--强行起立、退出(用户切换到后台断网处理)
function GameLayer:standUpAndQuit()
    self:sendCancelOccupy()
    GameLayer.super.standUpAndQuit(self)
end

--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end
-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    tlog('GameLayer:OnResetGameEngine')
    self.m_bOnGame = false
    -- self.userManager:removeAllUser()
    -- self.userManager:initUserList(self:getUserList())
    -- self._gameView:updateTotalPeople()
end
--下注
function GameLayer:sendStart(betIndex)
    local data = {
        betIndex = betIndex,
    }
    local dataBuffer = g_ExternalFun.writeData(G_NetCmd.MAIN_GAME,cmd.SUB_C_SCENE1_START,cmd.CMD_C_StartBet,data)
    self._gameFrame:sendSocketData(dataBuffer) 
end
--开罐子
function GameLayer:openEgg(index)
    local data = {
        nHitPos = index,
    }
    local dataBuffer = g_ExternalFun.writeData(G_NetCmd.MAIN_GAME,cmd.SUB_C_HIT_GOLDEGG,cmd.CMD_C_HitGoldEgg,data)
    self._gameFrame:sendSocketData(dataBuffer) 
end


function GameLayer:onEventGameMessage(sub,dataBuffer)
    if sub == cmd.SUB_S_SCENE1_START then
        self:gameData(dataBuffer)
        --清空10S提示界面
        self:hideTipsExit()
    elseif sub == cmd.SUB_GAME_CONFIG then
        self:gameConfig(dataBuffer)
    elseif sub == cmd.SUB_S_SCENE3_RESULT then
        self:miniGameData(dataBuffer)
    elseif sub == cmd.SUB_S_USER_DATA then
        self:userData(dataBuffer)
    elseif sub == cmd.SUB_S_HIT_GOLDEGG_RES then
        self:onOpenEggResult(dataBuffer)
    elseif sub == cmd.SUB_S_GOLDEGG_DETAIL then
        self:onGoldEggDetailResult(dataBuffer)
    end
end

function GameLayer:gameData(dataBuffer)
    local cmd_table = g_ExternalFun.readData(cmd.CMD_S_Scene1Start,dataBuffer)
    dump(cmd_table,"gameData")
    if cmd_table.frees_count == 0 and self.m_userData.bScatter then

    end
    self._gameView:betResult(cmd_table)
end

function GameLayer:gameConfig(dataBuffer)
    local cmd_table = g_ExternalFun.readData(cmd.CMD_S_GameConfig,dataBuffer)
    dump(cmd_table,"gameConfig")
    self._gameView:setBetArray(cmd_table)
end

function GameLayer:miniGameData(dataBuffer)
    local cmd_table = g_ExternalFun.readData(cmd.CMD_S_Scene3Result,dataBuffer)
    dump(cmd_table,"miniGameData")
    -- self._gameView:onRouteResult(cmd_table)
end

function GameLayer:userData(dataBuffer)
    local cmd_table = g_ExternalFun.readData(cmd.CMD_S_User_data,dataBuffer)
    dump(cmd_table,"userData")
    self.m_userData = cmd_table
    self._gameView:onUserDataResult(cmd_table)
end

function GameLayer:onOpenEggResult(dataBuffer)
    local cmd_table = g_ExternalFun.readData(cmd.Cmd_S_HitGoldEggRes,dataBuffer)
    dump(cmd_table,"onOpenEggResult")
    if cmd_table.nResult == 1 then
        print("已被点击过")
    end
    if cmd_table.nResult == 2 then
        print("位置不对")
    end
    if cmd_table.nResult ~= 0 then return end
    self._gameView:onOpenEggResult(cmd_table)
end

function GameLayer:onGoldEggDetailResult(dataBuffer)
    local cmd_table = g_ExternalFun.readData(cmd.Cmd_S_GoldEggDetail,dataBuffer)
    dump(cmd_table,"onGoldEggDetailResult")
    self._gameView:onGoldEggDetailResult(cmd_table)
end

--场景消息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)

    local cmd_table = g_ExternalFun.readData(cmd.CMD_S_SCENE_Data,dataBuffer)
    self._gameView:onEventGameScene(cmd_table)
    --清空10S提示界面
    self:hideTipsExit()
end

function GameLayer:onEventUserEnter(wTableID,wChairID,userItem)
    
end

--踢出消息10S 提示
function GameLayer:onOutGameTips()
    self:showTipsExit()
end

return GameLayer