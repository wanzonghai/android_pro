local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.egyptSlots.src";
local ExternalFun = g_ExternalFun
local cmd = module_pre .. ".models.CMD_Game"

local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local g_var = ExternalFun.req_var
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local QueryDialog = appdf.req("client.src.UIManager.QueryDialogNew")
local GameServer_CMD = appdf.req(appdf.CLIENT_SRC .. "NetProtocol.CMD_GameServer")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")

local emGameState =
{
    "GAME_STATE_WAITTING",              --等待
    "GAME_STATE_WAITTING_RESPONSE",     --等待服务器响应
    "GAME_STATE_MOVING",                --转动
    "GAME_STATE_RESULT",                --结算
    "GAME_STATE_WAITTING_GAME2",        --等待游戏2
    "GAME_STATE_END"                    --结束
}
local GAME_STATE = ExternalFun.declarEnumWithTable(0, emGameState)

local emGame2State = 
{
    "GAME2_STATE_WAITTING",
    "GAME2_STATE_WAVING",
    "GAME2_STATE_WAITTING_CHOICE",
    "GAME2_STATE_OPEN",
    "GAME2_STATE_RESULT"
}
local GAME2_STATE = ExternalFun.declarEnumWithTable(0, emGame2State)

function GameLayer:ctor( frameEngine,scene )
    ExternalFun.registerNodeEvent(self)
    GameLayer.super.ctor(self,frameEngine,scene)
    -- self:addAnimationEvent()  --监听加载完动画的事件
end

function GameLayer:getFrame( )
    return self._gameFrame
end
--创建场景
function GameLayer:CreateView()
     self._gameView = GameViewLayer[1]:create(self)
    --  g_ExternalFun.adapterWidescreen(self._gameView)
     self:addChild(self._gameView,0,2001)
     return self._gameView
end
function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)
    self.m_bIsPlayed            = false       --是否玩过游戏
    self.m_cbGameStatus         = 0         --游戏状态
    self.m_cbGameMode           = 0         --游戏模式
    --游戏逻辑操作
    self.m_bIsItemMove          = false     --动画是否滚动的标示
    self.m_lCoins               = 0         --游戏币
    self.m_lYaxian              = GameLogic.YAXIANNUM         --压线
    self.m_lYafen               = 0         --压分
    self.m_lTotalYafen          = 0         --总压分
    self.m_lGetCoins            = 0         --获得金钱
    self.m_lJiangjin            = 0         --奖金池
    self.m_bYafenIndex          = 1         --压分索引（数组索引）

    self.m_lBetScore            = {}

    self.m_UserActionYaxian     = {}           --用户压线的情况
    self.m_bIsAuto              = false        --控制自动开始按钮
    self.m_FreeTime=0;
    self.m_bReConnect1             = false

    self._bZhongJiang = {}
    for i=1, GameLogic.ITEM_Y_COUNT do
        self._bZhongJiang[i] = {}
        for j=1,GameLogic.ITEM_X_COUNT do
             self._bZhongJiang[i][j] = false
        end
    end
end

function GameLayer:ResetZhongJiang( )
    self._bZhongJiang = {}
    for i=1, GameLogic.ITEM_Y_COUNT do
        self._bZhongJiang[i] = {}
        for j=1,GameLogic.ITEM_X_COUNT do
             self._bZhongJiang[i][j] = false
        end
    end
end

function GameLayer:resetData()
    self.m_cbGameStatus         = 0         --游戏状态
    self.m_cbGameMode           = 0         --游戏模式
    --游戏逻辑操作
    self.m_bIsItemMove          = false     --动画是否滚动的标示
    self.m_lCoins               = 0         --游戏币
    self.m_lYaxian              = GameLogic.YAXIANNUM         --压线
    self.m_lYafen               = self.m_lBetScore[self.m_bYafenIndex]        --压分
    self.m_lTotalYafen          = self.m_lBetScore[self.m_bYafenIndex]*self.m_lYafen*self.m_lYaxian         --总压分
    self.m_lGetCoins            = 0         --获得金钱

    self.m_bEnterGame3          = false     --是否小玛丽
    self.m_bEnterGame2          = false     --是否比倍
    self.m_bYafenIndex          = 1         --压分索引（数组索引）
    --self.m_ptZhongJiang         = {{},{},{}}         
    --中奖位置
    self.m_bIsAuto                 = false        --控制自动开始按钮
    self.m_bReConnect1             = false
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    local useritem = self:GetMeUserItem()
    if (self.m_bIsAuto == true  and useritem.cbUserStatus == G_NetCmd.US_PLAYING and self.m_cbGameStatus == 101)then--g_var(cmd).SHZ_GAME_SCENE_FREE 
        print("游戏1断线重连")
        self.m_bReConnect1 = true
    end
end

function GameLayer:addAnimationEvent()
   --通知监听
   local function eventListener(event)
        cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(g_var(cmd).Event_LoadingFinish)
        if self._gameView then
            self:SendUserReady()
        end
   end
   local listener = cc.EventListenerCustom:create(g_var(cmd).Event_LoadingFinish, eventListener)
   cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end
--------------------------------------------------------------------------------------
function GameLayer:onExit()
    self:KillGameClock()
end
--退出桌子
function GameLayer:onExitTable()
   self:onExitRoom()
end
--离开房间
function GameLayer:onExitRoom()
    self._gameFrame:StandUp(1)
    self:getFrame():onCloseSocket()
    G_event:NotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)
end
-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
    print("场景数据:" .. cbGameStatus)
    self:KillGameClock()
    self._gameView.m_cbGameStatus = cbGameStatus;
    self:onEventGameSceneFree(dataBuffer);
    --清空10S提示界面
    self:hideTipsExit()
end

function GameLayer:onEventGameSceneFree(buffer)    --空闲 
    local cmd_table = ExternalFun.read_netdata(g_var(cmd).JXLW_CMD_S_StatusFree, buffer)
    print("=====================onEventGameSceneFree 空闲")
    dump(cmd_table)
    --初始化数据
    self.m_bMaxNum = 9
    self.m_bYafenIndex = cmd_table.cbBetMultiple
    self.m_lYaxian = cmd_table.cbBetLineCount
    self.m_lYafen = cmd_table.lCellScore
    for i=1,9 do
        self.m_lBetScore[i] = self.m_lYafen*i
    end
    self.m_lCoins = cmd_table.lUserScore
    local max_line = self.m_lYaxian
    self.m_bYafenIndex = self:getBetIndex(self.m_lBetScore,max_line)
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex]*self.m_lYaxian
    self.m_lWinTotal = cmd_table.lWinTotal   --总赢分

    --总压分  Text_allyafen
    --self._gameView.m_textAllyafen:setString(string.formatNumberCoin(self.m_lTotalYafen))
    local serverKind = G_GameFrame:getServerKind()
    self._gameView.m_textAllyafen:setString(g_format:formatNumber(self.m_lTotalYafen,g_format.fType.abbreviation,serverKind))
    self.m_lJiangjin = cmd_table.lCaiJin
    self.m_FreeTime = cmd_table.cbFreeTime
    if self.m_FreeTime > 0 then  --免费
        self._gameView.sprFree:setVisible(self.m_FreeTime>0)
        self._gameView.sprFree:getChildByName("num"):setString("/" .. self.m_FreeTime)
        self._gameView.freebtn:setVisible(self.m_FreeTime>0)
        self._gameView.freebtnTxt:setString("/" .. self.m_FreeTime)
        self:onGameStart()
    end
    self._gameView:updateStartButtonState(true)
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)
    if sub == g_var(cmd).SUB_S_GAME_START then 
        print("watermargin 游戏开始")
        self:onGame1Start(dataBuffer)                       --游戏开始
        --清空10S提示界面
        self:hideTipsExit()
     elseif sub == g_var(cmd).SUB_S_UPDATE_ROOM_STORAGE then 
        print("watermargin 奖金池")
        self:onSubJiangjinchi(dataBuffer)                      --奖金池
     elseif sub == g_var(cmd).SUB_S_USER_DATA then 
        print("watermargin 奖金池")
        self:onSubUserData(dataBuffer)                      --更新用户积分
     else
        print("unknow gamemessage sub is "..sub)
     end
end
function GameLayer:onSubJiangjinchi(dataBuffer) --奖金池
    local int64 = Integer64:new()
    self.m_lJiangjin = dataBuffer:readscore(int64):getvalue() --奖金池
end
--更新分数
function GameLayer:onSubUserData(dataBuffer)
    local cmd_table = ExternalFun.read_netdata(g_var(cmd).JXLW_CMD_S_User_data, dataBuffer)
    self._lUserScore = cmd_table.lUserScore  --用户金币
    self._allGold = cmd_table.lWinTotal

end

function GameLayer:onGame1Start(dataBuffer) --游戏开始

    local cmd_table = ExternalFun.read_netdata(g_var(cmd).JXLW_CMD_S_GameStart, dataBuffer)

    dump(cmd_table)
    self.m_cbItemInfo = cmd_table.cbItemInfo--GameLogic.copyTab(cmd_table.cbItemInfo)
    
    self.m_FreeTime = self.m_FreeTime + cmd_table.cbFreeTime

    self._gameView.sprFree:setVisible(self.m_FreeTime>0)
    self._gameView.sprFree:getChildByName("num"):setString("/" .. self.m_FreeTime)
    self._gameView.freebtn:setVisible(self.m_FreeTime>0)
    self._gameView.freebtnTxt:setString("/" .. self.m_FreeTime)
    self._gameView.m_textGetScore:setString(0)

    self.m_lGetCoins = cmd_table.lScore --中奖得数

    self.m_dwHashID = cmd_table.dwHashID or "" 

    self:ResetZhongJiang()
    --改变状态
    self.m_cbGameStatus = g_var(cmd).JXLW_GAME_SCENE_ONE
    if self.m_FreeTime~= 0 or self.m_lGetCoins > 0 then
        --清空数组
        -- dump(cmd_table)
        self.m_UserActionYaxian = {}
        for i=1,self.m_lYaxian do
            if cmd_table.nMultiple[1][i] ~= 0 then   --倍数不为0 说明中奖
                local pActionOneYaXian = {}
                pActionOneYaXian.cbDrawCount = {}
                pActionOneYaXian.nZhongJiangXian = i
                pActionOneYaXian.lXianScore = cmd_table.nMultiple[1][i]  --倍数
                pActionOneYaXian.ptXian = GameLogic.m_ptXian[i]
                pActionOneYaXian.Xian = cmd_table.cbItemType[1][i] --中奖的图标
                pActionOneYaXian.cbDrawCount[i] = cmd_table.cbLineCount[1][i]
                for j=1,cmd_table.cbLineCount[1][i] do
                    local x,y = GameLogic.m_ptXian[i][j].x,GameLogic.m_ptXian[i][j].y
                    self._bZhongJiang[x][y] = true 
                end
                self.m_UserActionYaxian[#self.m_UserActionYaxian+1] = pActionOneYaXian
            end
        end

    end
    self.m_bIsItemMove = true
    --开始游戏
    self._gameView:game1Begin()
    if self.m_bIsAuto == false then
        self._gameView:updateStartButtonState(true)
    else
        self._gameView:updateStartButtonState(false)
    end
end

function GameLayer:setGameMode( state )
    if state == 0 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_WAITTING  --等待
    elseif state == 1 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_WAITTING_RESPONSE --等待服务器响应
    elseif state == 2 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_MOVING --转动
    elseif state == 3 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_RESULT --结算
    elseif state == 4 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_WAITTING_GAME2 --等待游戏2
    elseif state == 5 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_END  --结束
    else
        print("未知状态")
    end
end
--获取游戏状态
function GameLayer:getGameMode()
    if self.m_cbGameMode then
        return self.m_cbGameMode
    end
end

function GameLayer:changeUserScore( changeScore )
    self.m_lCoins = self.m_lCoins + changeScore
    local serverKind = G_GameFrame:getServerKind()
    self._gameView.m_textScore:setString(g_format:formatNumber(self.m_lCoins,g_format.fType.standard,serverKind))
end

--游戏开始
function GameLayer:onGameStart()
    self._gameView:updateStartButtonState(false)
    local useritem = self:GetMeUserItem()
    self._gameView:onHideTopMenu()
    --自动开始
    if self.m_bIsAuto == true or self.m_FreeTime > 0 then
        if self:getGameMode() == GAME_STATE.GAME_STATE_MOVING then
            self._gameView:game1End()
        elseif self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING_GAME2 or self:getGameMode() == GAME_STATE.GAME_STATE_END  then
            self.m_bIsPlayed = true
            self._gameView:stopAllActions()
            --祝您好运！
            self._gameView.m_textTips:setString("Boa sorte!")
             if self.m_lTotalYafen > self.m_lCoins + self.m_lGetCoins then
                showToast("Você atualmente está com pouco saldo!")
                self._gameView:setAutoStart(false)
                self.m_bIsAuto = false
                self._gameView:updateStartButtonState(true)
                return
            end
            self:SendUserReady()
            --发送准备消息
            self:sendReadyMsg()
            self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
            self:setGameMode(1)
        end
    end
    if self:getGameMode() == GAME_STATE.GAME_STATE_MOVING then
        self._gameView:game1End()
    elseif  (self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING) or (self:getGameMode() == GAME_STATE.GAME_STATE_END) then
        if self.m_lTotalYafen > self.m_lCoins + self.m_lGetCoins then
            showToast("Você atualmente está com pouco saldo!")
            self._gameView:updateStartButtonState(true)
            return
        end
        self.m_bIsPlayed = true
        self._gameView:stopAllActions()
        --游戏2按钮不可用
        self:SendUserReady()
        --发送准备消息
        self:sendReadyMsg()
        self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
        self:setGameMode(1)
    end
end

--自动游戏
function GameLayer:onAutoStart( )
    self._gameView:onHideTopMenu()
    if self.m_bIsAuto == true then
        self.m_bIsAuto = false
        self._gameView:setAutoStart(false)
    else
        self.m_bIsAuto = true
        if self.m_lTotalYafen > self.m_lCoins + self.m_lGetCoins then
            showToast("Aviso: Moedas de jogo insuficientes")
            self.m_bIsAuto = false
            self._gameView:setAutoStart(false)
            return
        end
        self._gameView:setAutoStart(true) 
        if self.m_bIsItemMove == false then
            self._gameView:stopAllActions()
            self.m_bIsPlayed = true
            local useritem = self:GetMeUserItem()
            if useritem.cbUserStatus ~= G_NetCmd.US_READY then
                self:SendUserReady()
            end
            --发送准备消息
            self:sendReadyMsg()
            self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
            self:setGameMode(1) 
        end
    end
end
--最大加注
function GameLayer:onAddMaxScore()
    self._gameView:onHideTopMenu()
    self.m_bYafenIndex = self.m_bMaxNum 
    self.m_lYaxian = 9
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex]*self.m_lYaxian
    --总压分
    --self._gameView.m_textAllyafen:setString(string.formatNumberCoin(self.m_lTotalYafen))
    local serverKind = G_GameFrame:getServerKind()
    self._gameView.m_textAllyafen:setString(g_format:formatNumber(self.m_lTotalYafen,g_format.fType.abbreviation,serverKind))
end

--最小加注
function GameLayer:onAddMinScore( )
    self._gameView:onHideTopMenu()
    self.m_bYafenIndex = 1
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex]*self.m_lYaxian
    --总压分
    --self._gameView.m_textAllyafen:setString(string.formatNumberCoin(self.m_lTotalYafen))
    local serverKind = G_GameFrame:getServerKind()
    self._gameView.m_textAllyafen:setString(g_format:formatNumber(self.m_lTotalYafen,g_format.fType.abbreviation,serverKind))
end
--加线
function GameLayer:onAddLine()
    self._gameView:onHideTopMenu()
    if self.m_lYaxian < 9 then
        self.m_lYaxian = self.m_lYaxian + 1
    else
        self.m_lYaxian = 1 --self.m_bMaxNum
    end
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex]*self.m_lYaxian
    --总压分
    --self._gameView.m_textAllyafen:setString(string.formatNumberCoin(self.m_lTotalYafen))
    local serverKind = G_GameFrame:getServerKind()
    self._gameView.m_textAllyafen:setString(g_format:formatNumber(self.m_lTotalYafen,g_format.fType.abbreviation,serverKind))
end
--加注
function GameLayer:onAddScore()
    self._gameView:onHideTopMenu()
    if self.m_bYafenIndex < #self.m_lBetScore then--self.m_bMaxNum then
        self.m_bYafenIndex = self.m_bYafenIndex + 1
    else
        -- self.m_bYafenIndex = 1 --self.m_bMaxNum
    end
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex]*self.m_lYaxian
    --总压分
    --self._gameView.m_textAllyafen:setString(string.formatNumberCoin(self.m_lTotalYafen))
    local serverKind = G_GameFrame:getServerKind()
    self._gameView.m_textAllyafen:setString(g_format:formatNumber(self.m_lTotalYafen,g_format.fType.abbreviation,serverKind))
end
--减注
function GameLayer:onSubScore()
    self._gameView:onHideTopMenu()
    if self.m_bYafenIndex > 1  then
        self.m_bYafenIndex = self.m_bYafenIndex - 1
    else
        self.m_bYafenIndex = 1
    end
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex]*self.m_lYaxian
    --总压分
    --self._gameView.m_textAllyafen:setString(string.formatNumberCoin(self.m_lTotalYafen))
    -- print("self.m_lTotalYafen = ",self.m_lTotalYafen)
    local serverKind = G_GameFrame:getServerKind()
    self._gameView.m_textAllyafen:setString(g_format:formatNumber(self.m_lTotalYafen,g_format.fType.abbreviation,serverKind))
end
--发送准备消息
function GameLayer:sendReadyMsg()
    if(self.m_FreeTime==0)then
        self:changeUserScore(-self.m_lTotalYafen)
    end
    --免费次数减少
    if (self.m_FreeTime > 0) then self.m_FreeTime = self.m_FreeTime - 1 end
    self._gameView.sprFree:setVisible(self.m_FreeTime>0)
    self._gameView.sprFree:getChildByName("num"):setString("/" .. self.m_FreeTime)
    self._gameView.freebtn:setVisible(self.m_FreeTime>0)
    self._gameView.freebtnTxt:setString("/" .. self.m_FreeTime)

    print("=============self.m_lTotalYafen:",self.m_lTotalYafen)
    local  dataBuffer= CCmd_Data:create(10)
    dataBuffer:pushscore(self.m_lTotalYafen)  --总押分
    dataBuffer:pushbyte(self.m_lYaxian)  --押线 
    dataBuffer:pushbyte(self.m_bYafenIndex)  --倍数    
    self:SendData(g_var(cmd).JXLW_SUB_C_ONE_START, dataBuffer)
    EventPost:addCommond(EventPost.eventType.SPIN,"slot每次spin",1,nil,{gameId = cmd.KIND_ID,
        roomId = GlobalUserItem.roomMark,betPrice = self.m_lTotalYafen
    })  
    if self.m_lGetCoins and self.m_lGetCoins > 0 then
        self.m_lCoins = self.m_lCoins + self.m_lGetCoins
        self.m_lGetCoins = 0
        local serverKind = G_GameFrame:getServerKind()
        self._gameView.m_textScore:setString(g_format:formatNumber(self.m_lCoins,g_format.fType.standard,serverKind))
    else
        local serverKind = G_GameFrame:getServerKind()
        self._gameView.m_textScore:setString(g_format:formatNumber(self.m_lCoins,g_format.fType.standard,serverKind))
    end
end

function GameLayer:sendNetData( cmddata )
    return self._gameFrame:sendSocketData(cmddata)
end

--请求银行信息
function GameLayer:sendRequestBankInfo()
    local cmddata = CCmd_Data:create(67)
    cmddata:setcmdinfo(GameServer_CMD.MDM_GR_INSURE,GameServer_CMD.SUB_GR_QUERY_INSURE_INFO)
    cmddata:pushbyte(GameServer_CMD.SUB_GR_QUERY_INSURE_INFO)
    cmddata:pushstring(md5(GlobalUserItem.szPassword),G_NetLength.LEN_PASSWORD)

    self:sendNetData(cmddata)
end

--踢出消息10S 提示
function GameLayer:onOutGameTips()
    self:showTipsExit()
end

return GameLayer