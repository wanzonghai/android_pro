local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.baccarat.src"
local game_cmd = appdf.CLIENT_SRC .. "NetProtocol.CMD_GameServer"
local cmd = appdf.req(module_pre..".models.CMD_Game")
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")

-- 初始化界面
function GameLayer:ctor(frameEngine,scene)
    GameLayer.super.ctor(self, frameEngine, scene)
    self.playlist = {} --玩家列表
end

--创建场景
function GameLayer:CreateView()
    return GameViewLayer:create(self):addTo(self)
end
-- 初始化游戏数据
function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)
end
-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    GameLayer.super.OnResetGameEngine(self)
end
--获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end
function GameLayer:GetMyItem()
    local myItem = self:GetMeUserItem()
    return myItem
end
function GameLayer:GetMyChairID()
    local chairID = self:GetMeChairID()
    return chairID
end

function GameLayer:GetMyTableID()
    local tableID = self._gameFrame:GetTableID()
    return tableID
end

function GameLayer:GetUserItem(chairID)
    local tableID =  self:GetMyTableID()
    return self._gameFrame:getTableUserItem(tableID, chairID)
end
function GameLayer:GetOtherUserItem(dwUserId)
    return self._gameFrame:GetOtherUserItem(dwUserId)
end
--退出桌子
function GameLayer:onExitTable()
    self:KillGameClock()
    self:onExitRoom()
end
function GameLayer:getFrame( )
    return self._gameFrame
end
--离开房间
function GameLayer:onExitRoom()
    self._gameFrame:StandUp(1)
    self:getFrame():onCloseSocket()
    G_event:NotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)
end
-- 场景信息 断线重连
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    if tolua.isnull(self) then return end
    self._myChairId = self:GetMyChairID()
    self._gameView:onClearData(false)
    if cbGameStatus == cmd.GAME_SCENE_FREE	then                        --空闲状态
        self:onEventGameSceneFree(dataBuffer);
	elseif cbGameStatus == cmd.GAME_JETTON	then                        --下注状态
        self:onEventGameSceneJetton(dataBuffer);
	elseif cbGameStatus == cmd.GAME_END	then                            --游戏状态
        self:onEventGameSceneEnd(dataBuffer);
	end
end
--空闲状态
function GameLayer:onEventGameSceneFree(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(cmd.CMD_S_StatusFree, dataBuffer);
    self._gameView:onSceneFree(cmd_table)
end
--下注状态
function GameLayer:onEventGameSceneJetton(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer)
    self._gameView:onSceneJetton(cmd_table)
end
--游戏状态
function GameLayer:onEventGameSceneEnd(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(cmd.CMD_S_StatusPlay, dataBuffer)
    self._gameView:onSceneGameEnd(cmd_table)
end
-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)
    if sub == cmd.SUB_S_GAME_FREE then  --空闲状态
        local cmd_table = g_ExternalFun.read_netdata(cmd.CMD_S_GameFree, dataBuffer)
        self._gameView:S2C_onGameFree(cmd_table)
    elseif sub == cmd.SUB_S_GAME_START then  --游戏开始
        local cmd_table = g_ExternalFun.read_netdata(cmd.CMD_S_GameStart, dataBuffer)
        self._gameView:S2C_onGameStart(cmd_table)
    elseif sub == cmd.SUB_S_PLACE_JETTON then   --下注返回
        local cmd_table = g_ExternalFun.read_netdata(cmd.CMD_S_PlaceBet, dataBuffer)
        self._gameView:S2C_onUserBet(cmd_table)
    elseif sub == cmd.SUB_S_PLACE_JETTON_FAIL then   --下注失败
        local cmd_table = g_ExternalFun.read_netdata(cmd.CMD_S_PlaceBetFail, dataBuffer)
        self._gameView:S2C_onUserBetFail(cmd_table)
    elseif sub == cmd.SUB_S_GAME_END then   --游戏结束 
        local cmd_table = g_ExternalFun.read_netdata(cmd.CMD_S_GameEnd, dataBuffer)
        self._gameView:S2C_onGameEnd(cmd_table)    
    elseif sub == cmd.SUB_S_APPLY_BANKER then  --申请庄家
        local cmd_table = g_ExternalFun.read_netdata(cmd.CMD_S_ApplyBanker, dataBuffer)
        self._gameView:S2C_onApplyBanker(cmd_table)
    elseif sub == cmd.SUB_S_CHANGE_BANKER then  --切换庄家
        local cmd_table = g_ExternalFun.read_netdata(cmd.CMD_S_ChangeBanker, dataBuffer)
        self._gameView:S2C_onChangeBanker(cmd_table)
    elseif sub == cmd.SUB_S_CANCEL_BANKER then  --取消上庄
        local cmd_table = g_ExternalFun.read_netdata(cmd.CMD_S_CancelBanker, dataBuffer)
        self._gameView:S2C_onCancelBanker(cmd_table)
    elseif sub == cmd.SUB_S_SEND_RECORD then  --路单 
        self:onReceiveRecord(dataBuffer)
    end
end
function GameLayer:onReceiveRecord(dataBuffer)
    local len = dataBuffer:getlen();
    local recordcount = math.floor(len / cmd.RECORD_LEN)
    if (len - recordcount * cmd.RECORD_LEN) ~= 0 then
        printInfo("bjl_record_len_error" .. len)
        return;
    end      
    --游戏记录
    local game_record = {};    
    --读取记录列表
    for i=1,recordcount do
        local data = {}
        data.cbKingWinner = dataBuffer:readbyte();
        data.bPlayerTwoPair = dataBuffer:readbool();
        data.bBankerTwoPair = dataBuffer:readbool();
        data.cbPlayerCount = dataBuffer:readbyte();
        data.cbBankerCount = dataBuffer:readbyte();
        if data.cbPlayerCount > data.cbBankerCount then
            data.cbType = 0
        elseif data.cbPlayerCount == data.cbBankerCount then
            data.cbType = 1
        else
            data.cbType = 2
        end
        if #game_record >= 20 then
            table.remove(game_record,1)
        end
        table.insert(game_record,data)
    end
    self._gameView:S2C_onUpdateRecord(game_record)
end
function GameLayer:onEventUserEnter( wTableID,wChairID,useritem)
    if useritem == nil then return end
    self:onUpdateUser(useritem)
end
function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)
    print("change user " .. useritem.wChairID .. "; nick " .. useritem.szNickName)
    if newstatus.cbUserStatus == G_NetCmd.US_FREE then
        self:onRemoveUser(useritem)
    else
        self:onUpdateUser(useritem)
    end
end
function GameLayer:onRemoveUser(useritem)
    local exist,index = self:isExistUser(useritem.dwUserID)
    if exist then
        table.remove(self.playlist,index)
    end
end
function GameLayer:onUpdateUser(useritem)
    local data = {}
    data.dwUserID = useritem.dwUserID
    data.wFaceID = useritem.wFaceID
    if data.wFaceID <=0 then data.wFaceID = 0 end
    if data.wFaceID >=10 then data.wFaceID = 10 end
    data.szNickName = useritem.szNickName
    data.lScore = g_format:formatNumber(useritem.lScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)--string.formatNumberThousands(useritem.lScore,true,".")
    local exist,index = self:isExistUser(useritem.dwUserID)
    if exist then
        self.playlist[index] = data
    else
        table.insert(self.playlist,data)
    end
    self._gameView:onUpdateOnlineCount(#self.playlist)
end
function GameLayer:isExistUser(dwUserID)
    for i,v in pairs(self.playlist) do
        if v.dwUserID == dwUserID then
            return true,i
        end
    end
    return false
end
------------------------------------------------------------------------
--********************   发送消息     *********************--
--发送下注
function GameLayer:reqAddScore(areaID, nScore)
    local dataBuffer = CCmd_Data:create(9)
    dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME, cmd.SUB_C_PLACE_JETTON)
    dataBuffer:pushbyte(areaID - 1)
    dataBuffer:pushscore(nScore)
    EventPost:addCommond(EventPost.eventType.SPIN,"百人场，下注一次一局",4,nil,{gameId = cmd.KIND_ID,
        roomId = GlobalUserItem.roomMark,betPrice = nScore
    }) 
    return self._gameFrame:sendSocketData(dataBuffer)
end
-- 申请上庄
function GameLayer:reqApplyBanker()
    local dataBuffer = CCmd_Data:create(0)
    dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME, cmd.SUB_C_APPLY_BANKER)
    return self._gameFrame:sendSocketData(dataBuffer)
end
-- 申请下庄
function GameLayer:reqCancelApply()
    local dataBuffer = CCmd_Data:create(0)
    dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME, cmd.SUB_C_CANCEL_BANKER)
    return self._gameFrame:sendSocketData(dataBuffer)
end

return GameLayer
