local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)
local module_pre = "game.yule.mllegend.src";

local ExternalFun = g_ExternalFun --appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = module_pre .. ".models.CMD_Game"
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local g_var = ExternalFun.req_var
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local QueryDialog = appdf.req("client.src.UIManager.QueryDialogNew")
local GameServer_CMD = appdf.CLIENT_SRC .. "NetProtocol.CMD_GameServer"
local PRELOAD = require(module_pre .. ".views.layer.PreLoading")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
local emGameState =
{
    "GAME_STATE_WAITTING",              --等待            --0
    "GAME_STATE_WAITTING_RESPONSE",     --等待服务器响应  --1
    "GAME_STATE_MOVING",                --转动            --2
    "GAME_STATE_RESULT",                --结算            --3
    "GAME_STATE_WAITTING_GAME2",        --等待游戏2       --4
    "GAME_STATE_END"                    --结束            --5
}
local GAME_STATE = ExternalFun.declarEnumWithTable(0, emGameState)

local isTestMllegend = false

local ICON_TIME = {
[0]={3,10,45},
[1]={4,15,60},
[2]={5,20,80},
[3]={8,25,100},
[4]={10,35,150},
[5]={20,65,300},
[6]={30,100,500},
[7]={0,0,0},
[8]={0,0,0},
}

function GameLayer:ctor( frameEngine,scene )
 
    GameLayer.super.ctor(self,frameEngine,scene)

    self.originalFPS=cc.Director:getInstance():getAnimationInterval()

    ExternalFun.registerNodeEvent(self)
    GlobalUserItem.bLoadingPlay = false
    self.m_bLeaveGame = false    
    self._gameFrame:QueryUserInfo( self:GetMeUserItem().wTableID,G_NetCmd.INVALID_CHAIR)
    self:playGamebgMusic()
    self._bReceiveSceneMsg = false
end

function GameLayer:getGameKind()
    return g_var(cmd).KIND_ID
end

function GameLayer:getFrame( )
    return self._gameFrame
end

--创建场景
function GameLayer:CreateView()
     self._gameView = GameViewLayer:create(self)
     g_ExternalFun.adapterWidescreen(self._gameView)
     self._gameView:created()
     self:addChild(self._gameView,0,2001)
     return self._gameView
end

function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)
    --print("--------------------------------------初始化数据")   
   
    self.m_bIsPlayed            = false       --是否玩过游戏
    self.m_cbGameStatus         = 0         --游戏状态

    self.m_cbGameMode           = 0         --游戏模式

    self._bReceiveSceneMsg      = false

    --游戏逻辑操作

    self.m_lScore               = 0         --游戏币

    self.m_lWinScore          = 0         --总赢分

    self.m_Times                  = 0         --倍数

   
    

    self.m_bYafenIndex          = 0         --压分索引（数组索引）
    
    self.m_lBetScore            = {} --压分存储数组
    self.m_bMaxNum              = 0  
    self.m_lYaxian              = GameLogic.YAXIANNUM         --压线
    self.m_lYafen               = 0                                 --压分
    self.m_lTotalYafen          = self.m_lYafen*self.m_lYaxian         --总压分
    self.m_lGetCoins            = 0         --获得金钱
    
    self.m_lBouns               = 0         --获得奖金
    self.m_cb777Time              = 0         --777time
    self.m_cbBoxTime              = 0           --BoxTime
    self.m_cbFreeTime = 0;      --free次数
    self.m_llFreeScore = 0


    self.m_cbSpecialTime = 0;
    self.m_bSpecialGame = false  ---特殊奖励

    self.m_bFreetime = false
                                  
    self.m_cbItemInfo           = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}}          --开奖信息
    self.m_cbJLineArray         ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}    --中奖线
    self.m_cbIconType           ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}    --中奖线

    --中奖位置
    self.m_ptZhongJiang = {}
    for i=1,GameLogic.YAXIANNUM do
        self.m_ptZhongJiang[i] = {}
        for j=1,GameLogic.ITEM_X_COUNT do
            self.m_ptZhongJiang[i][j] = {}
            self.m_ptZhongJiang[i][j].x = 0
            self.m_ptZhongJiang[i][j].y = 0
        end
    end

    self.m_UserActionYaxian     = {}           --用户压线的情况

    self.m_bIsItemMove          = false     --动画是否滚动的标示
    self.m_bIsAuto              = false        --控制自动开始按钮

    self.m_bGetRecoreFinish = true

    self.tagActionOneKaiJian = {}
    self.tagActionOneKaiJian.nCurIndex = 0
    self.tagActionOneKaiJian.nMaxIndex = self.m_lYaxian
    self.tagActionOneKaiJian.lScore = 0
    self.tagActionOneKaiJian.lQuanPanScore = 0
    self.tagActionOneKaiJian.cbGameMode = 0
    self.tagActionOneKaiJian.bZhongJiang = {}
    for i=1, GameLogic.ITEM_Y_COUNT do
        self.tagActionOneKaiJian.bZhongJiang[i] = {}
        for j=1,GameLogic.ITEM_X_COUNT do
             self.tagActionOneKaiJian.bZhongJiang[i][j] = false
        end
    end



end

function GameLayer:ResetAction()
     self.tagActionOneKaiJian.nCurIndex = 0
     self.tagActionOneKaiJian.nMaxIndex = 9
     self.tagActionOneKaiJian.lScore = 0
     self.tagActionOneKaiJian.lQuanPanScore = 0
     self.tagActionOneKaiJian.cbGameMode = 0
     self.tagActionOneKaiJian.bZhongJiang = {}
     for i=1, GameLogic.ITEM_Y_COUNT do
         self.tagActionOneKaiJian.bZhongJiang[i] = {}
         for j=1,GameLogic.ITEM_X_COUNT do
             self.tagActionOneKaiJian.bZhongJiang[i][j] = false
         end
     end
end

function GameLayer:resetData()

    print("--------------------------------------------------重置数据")
    self._bReceiveSceneMsg      = false
    self.m_cbGameStatus         = 0         --游戏状态

    self.m_cbGameMode           = 0         --游戏模式

    --游戏逻辑操作
    self.m_lScore               = 0         --游戏币
    self.m_lWinScore          = 0

    self.m_Times                  = 0         --倍数

    self.m_lYaxian              = GameLogic.YAXIANNUM         --压线
    self.m_lYafen               = 0        --压分
    self.m_lTotalYafen          = self.m_lYafen*self.m_lYaxian         --总压分
    self.m_lGetCoins            = 0         --获得金钱

    self.m_lBouns               = 0         --获得奖金
    self.m_cb777Time              = 0         --777time
    self.m_cbBoxTime              = 0           --BoxTime
    self.m_cbFreeTime = 0;  --free次数

    self.m_cbSpecialTime = 0;
    self.m_bSpecialGame = false         ---特殊奖励

    self.m_bFreetime = false
    self.m_llFreeScore = 0

    self.m_bYafenIndex          = 0         --压分索引（数组索引）
    
    self.m_lBetScore            = {}--压分存储数组
    self.m_bMaxNum              = 0
    self.m_cbItemInfo           = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}}         --开奖信息
    --self.m_ptZhongJiang         = {{},{},{}}   
    self.m_cbJLineArray         ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}    --中奖线
    self.m_cbIconType           ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}    --中奖线
       
    self.m_bIsAuto                 = false        --控制自动开始按钮
    self.m_bIsItemMove          = false     --动画是否滚动的标示
    
    self.m_bGetRecoreFinish = true
           
    --中奖位置
    self.m_ptZhongJiang = {}
    for i=1,GameLogic.YAXIANNUM do
        self.m_ptZhongJiang[i] = {}
        for j=1,GameLogic.ITEM_X_COUNT do
            self.m_ptZhongJiang[i][j] = {}
            self.m_ptZhongJiang[i][j].x = 0
            self.m_ptZhongJiang[i][j].y = 0
        end
    end

end

function GameLayer:onExit()
    GameLayer.super.onExit(self)
    PRELOAD.unloadTextures()
    
    self:KillGameClock()
end

function GameLayer:stopAllEffects()
    AudioEngine.stopAllEffects()
end
function GameLayer:stopEffect(handle)
    AudioEngine.stopEffect(handle)
end

function GameLayer:onExitTable()
    self:onExitRoom()
end

--离开房间
function GameLayer:onExitRoom()  
	self._gameFrame:StandUp(1)
	self._gameFrame:onCloseSocket()
	self:KillGameClock()
	--self._scene:onKeyBack()
    G_event:NotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)
end

--系统消息
function GameLayer:onSystemMessage( wType,szString )
    if wType == 515 then  --515 当玩家没钱时候
       self.m_querydialog = QueryDialog:create(szString,function()       
            self:KillGameClock()
            local MeItem = self:GetMeUserItem()
            if MeItem and MeItem.cbUserStatus > G_NetCmd.US_FREE then
                self:showPopWait()
                self:runAction(cc.Sequence:create(
                    cc.CallFunc:create(
                        function () 
                            self._gameFrame:StandUp(1)
                        end
                        ),
                    cc.DelayTime:create(10),
                    cc.CallFunc:create(
                        function ()
                            print("delay leave")
                            self:onExitRoom()
                        end
                        )
                    )
                )
                return
            end
           self:onExitRoom()

        end,nil,1)
        self.m_querydialog:setCanTouchOutside(false)
        self.m_querydialog:addTo(self)
    end
end

-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
    print("场景数据:" .. cbGameStatus)
    self:KillGameClock()   
    PRELOAD.CloseGameLoadingView()

	self:onEventGameSceneFree(dataBuffer);
    self._bReceiveSceneMsg = true

    --清空10S提示界面
    self:hideTipsExit()
end

function GameLayer:onEventGameSceneFree(buffer)    --空闲 
    local cmd_table = {}--ExternalFun.read_netdata(g_var(cmd).CMD_S_SCENE_DATA, buffer)
    cmd_table.dwBetScore = {}
    for i=1,5 do
       cmd_table.dwBetScore[i] = buffer:readdword()
    end
    local int64 = Integer64.new()
    cmd_table.lUserScore = buffer:readscore(int64):getvalue()
    self.cbFreeTimes = buffer:readbyte()

    cmd_table.cbItemInfo = {}
    local newData = {}
    local _index = 1
    for i = 1, 3 do
        cmd_table.cbItemInfo[i] = {}
        for j = 1, 5 do
            cmd_table.cbItemInfo[i][j] = buffer:readbyte()
            newData[_index] = cmd_table.cbItemInfo[i][j]
            _index = _index + 1
        end
    end
    local dwHashID = buffer:readdword()
    local dwCRC = buffer:readdword()
    if isTestMllegend then
        cmd_table.cbItemInfo = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},}
    end
    --初始化数据
    self.m_lBetScore =cmd_table.dwBetScore

    self.m_bMaxNum = #self.m_lBetScore
    self.m_bYafenIndex = 1
    local max_line = self.m_lYaxian
    self.m_bYafenIndex = self:getBetIndex(self.m_lBetScore,max_line)
    self.m_lYafen               = self.m_lBetScore[self.m_bYafenIndex]        --压分
    self.m_lTotalYafen          = self.m_lYafen*self.m_lYaxian         --总压分
    self.m_lGetCoins = 0
    self.m_lScore = cmd_table.lUserScore
    self.m_NickName = self:GetMeUserItem().szNickName
    self.m_lWinScore   = 0
    self:setGameMode(GAME_STATE.GAME_STATE_WAITTING)
    self.m_bIsItemMove = false
    self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_ONE

    if self._gameView then
        while(true) do
            if self._gameView._isCreated then
                self:SendUserReady()
                self._gameView:updateScore(true)
                self._gameView:updataBtnEnable() 
                self._gameView:onAddFreeTime(0)
                self._gameView.m_ScrollLayer:setGameSceneData(cmd_table.cbItemInfo)       
                if dwHashID and dwHashID>0 and self._gameView._txtHashId then
                    local _crcMark = 0
                    if dwCRC and dwCRC > 0 then 
                         _crcMark = 1
                         local newCRC = Calc_crc(0,newData,15)
                         if newCRC ~= dwCRC then
                             _crcMark = 2
                         end
                    end
                    --self._gameView._txtHashId:setString(dwHashID.._crcMark)
                end            
                break;
            end
        end 
    end
end
-----------------------------------------------------------------------------------
-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)
    if sub == g_var(cmd).SUB_S_GAME_START then 
        self:onGameStart(dataBuffer)                       --游戏开始   
        --清空10S提示界面
        self:hideTipsExit()
    else
        print("unknow gamemessage sub is "..sub)
    end
end
--

--游戏开始
function GameLayer:onGameStart(dataBuffer) --游戏开始
    local bNeedGameOption = false
    local int64 = Integer64.new()
    local cmd_table = {}
    
    cmd_table.lAllWinScore = dataBuffer:readscore(int64):getvalue()
    cmd_table.lUserScore = dataBuffer:readscore(int64):getvalue()
    cmd_table.cbAllFreeTimes = dataBuffer:readbyte()  --总的免费次数，此字段说明有新的免费模式次数。
    self.m_cbFreeTime = cmd_table.cbAllFreeTimes
    cmd_table.cbGameMode = dataBuffer:readbyte()
    cmd_table.dwHashID = dataBuffer:readdword()
    cmd_table.cbDataCount = dataBuffer:readbyte()
    cmd_table.cbItemInfo = {}
    cmd_table.childcount = cmd_table.cbDataCount-1
    if isTestMllegend then
        cmd_table.childcount = 0
    end
    local _crcMark = 0
    if cmd_table.cbDataCount >= 1 then
        cmd_table.cbFreeTimes = dataBuffer:readbyte()
        cmd_table.lScore = dataBuffer:readscore(int64):getvalue()
        cmd_table.cbJLineArray = {}
        for i=1,GameLogic.YAXIANNUM do
            cmd_table.cbJLineArray[i] = dataBuffer:readbyte()
            if isTestMllegend then
                cmd_table.cbJLineArray[i] = 0
            end
        end
        cmd_table.cbIconType = {}
        for i=1,GameLogic.YAXIANNUM do
            cmd_table.cbIconType[i] = dataBuffer:readbyte()
            if isTestMllegend then
                cmd_table.cbIconType[i] = 0
            end
        end
        for i = 1, 3 do
            cmd_table.cbItemInfo[i] = {}
            for j = 1, 5 do
                cmd_table.cbItemInfo[i][j] = dataBuffer:readbyte()
                if isTestMllegend then
                    cmd_table.cbItemInfo[i][j] = math.random(0,8)
                end
            end
        end
        local dwCRC = dataBuffer:readdword()
        _crcMark = 1
        if dwCRC and dwCRC > 0 then
             local newData = {}
             for i=1,15 do
                 local x = math.ceil(i/5)
                 local y = i%5
                 y = y>0 and y or 5
                 newData[i] =  cmd_table.cbItemInfo[x][y]
             end
             local newCRC = Calc_crc(0,newData,15)
             if newCRC ~= dwCRC then
                 bNeedGameOption = true
                 _crcMark = 2
             end
        end
    end
    cmd_table.childitem = {}
    if cmd_table.childcount > 0 then
        for k = 1, cmd_table.childcount do
            cmd_table.childitem[k] = { }
            cmd_table.childitem[k].cbItemInfo = {}
            cmd_table.childitem[k].m_cbFreeTime = dataBuffer:readbyte()
            cmd_table.childitem[k].lScore = dataBuffer:readscore(int64):getvalue()
            cmd_table.childitem[k].cbJLineArray = {}
            for i=1,GameLogic.YAXIANNUM do
               cmd_table.childitem[k].cbJLineArray[i] = dataBuffer:readbyte()
            end
            cmd_table.childitem[k].cbIconType = {}
            for i=1,GameLogic.YAXIANNUM do
               cmd_table.childitem[k].cbIconType[i] = dataBuffer:readbyte()
            end
            for i = 1, 3 do
                cmd_table.childitem[k].cbItemInfo[i] = {}
                for j = 1, 5 do
                    cmd_table.childitem[k].cbItemInfo[i][j] = dataBuffer:readbyte()
                end
            end
            local dwCRC = dataBuffer:readdword()
            if bNeedGameOption == false and dwCRC and dwCRC > 0 then
                 local newData = {}
                 for i=1,15 do
                     local x = math.ceil(i/5)
                     local y = i%5
                     y = y>0 and y or 5
                     newData[i] =   cmd_table.childitem[k].cbItemInfo[x][y]
                 end
                 local newCRC = Calc_crc(0,newData,15)
                 if newCRC ~= dwCRC then
                     bNeedGameOption = true
                     _crcMark = 2
                 end
            end
        end
    end
    if cmd_table.dwHashID and  cmd_table.dwHashID>0 and self._gameView._txtHashId then
        --self._gameView._txtHashId:setString(cmd_table.dwHashID.._crcMark)
    end
    if bNeedGameOption == true then   --需要发送场景 消息
         self:setGameMode(GAME_STATE.GAME_STATE_WAITTING)
         self._gameFrame:SendGameOption()
         self._gameView:updataBtnEnable()
         return
    end

    self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_ONE

    self.m_bIsItemMove = true
    self:setGameMode(GAME_STATE.GAME_STATE_MOVING)

    self._gameView:updataBtnEnable()

    self.m_tStartDate = {}
    self.m_tStartDate = cmd_table

    self.m_cbDeleteTime = 0;
    self.m_lWinScore = 0
    self.m_Times = 0 

    if self.m_cbFreeTime == 0 then
        self.m_bFreetime = false   
    else 
        self.m_bFreetime = true   
    end 
    self._gameView:onAddFreeTime(self.m_cbFreeTime) 

    if cmd_table.cbGameMode == g_var(cmd).GM_NULL then
        self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_ONE        
        self.m_bSpecialGame = false
        self.m_lScore = self.m_lScore - self.m_lTotalYafen
    elseif cmd_table.cbGameMode == g_var(cmd).GM_FREE then
        self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREETIME
        self.m_bSpecialGame = true 
    else
        self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_ONE
        self.m_bSpecialGame = false
    end


    if self.m_bFreetime then
        self.m_lGetCoins = cmd_table.lScore
        self.m_llFreeScore = self.m_llFreeScore+self.m_lGetCoins
        --ExternalFun.playSoundEffect("ScatterWin.mp3")   
    else
        self.m_lWinScore = self.m_llFreeScore
        self.m_llFreeScore = 0
        self.m_bFreetime = false
        self.m_lGetCoins = cmd_table.lScore
    end

    self._gameView:updateScore(true)

    self.m_lScore = self.m_lScore + self.m_lGetCoins
    self.m_lWinScore = self.m_lWinScore +self.m_lGetCoins

    self.m_cbItemInfo = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}} 
    self.m_cbItemInfo = GameLogic:copyTab(cmd_table.cbItemInfo)

    self.m_cbJLineArray = cmd_table.cbJLineArray

    self.m_cbIconType = cmd_table.cbIconType
    --dump(self.m_cbItemInfo,"中奖信息")
    --检验是否中奖
    
    self.m_bDelete = self:Compute()
    print(self.m_bDelete,"self.m_bDelete")
    --开始游戏
    self:onBeginRoll()
   self._gameView:gameBegin()
end

function GameLayer:onDeleteGameStart()

    self.m_lGetCoins = 0 
    self._gameView:updateScore()

    local start = self.m_tStartDate
    print("onDeleteGameStart",self.m_cbDeleteTime,start.childcount) 
    if start.childcount <= self.m_cbDeleteTime then   
        showToast("Sem subitens!!!")    
        return
    end
    self.m_cbDeleteTime = self.m_cbDeleteTime + 1
    self._gameView:setLevel(self.m_cbDeleteTime)
    self.m_lGetCoins = start.childitem[self.m_cbDeleteTime].lScore

    self.m_cbItemInfo = start.childitem[self.m_cbDeleteTime].cbItemInfo

    self.m_cbJLineArray = start.childitem[self.m_cbDeleteTime].cbJLineArray
    self.m_cbIconType = start.childitem[self.m_cbDeleteTime].cbIconType

    dump(self.m_cbItemInfo)

    self.m_lScore = self.m_lScore + self.m_lGetCoins
    self.m_lWinScore = self.m_lWinScore +self.m_lGetCoins
    self.m_llFreeScore = self.m_llFreeScore+self.m_lGetCoins

    self.m_bDelete = self:Compute()
    print(self.m_bDelete,"self.m_bDelete")
    self._gameView:DeleteGame()

end

function GameLayer:Compute()
    self.m_UserActionYaxian = { }
    -- 清空数组
    self:ResetAction()
    local bDelete = true
    self.tagActionOneKaiJian.nCurIndex = 0
    self.tagActionOneKaiJian.nMaxIndex = 9
    self.tagActionOneKaiJian.lQuanPanScore = 0
    for i = 1, self.m_lYaxian do
        local line = self.m_cbJLineArray[i]
        if line > 0 then
            for k=1,line do
                self.m_ptZhongJiang[i][k].x = GameLogic.m_ptXian[i][k].x
                self.m_ptZhongJiang[i][k].y = GameLogic.m_ptXian[i][k].y
                self.tagActionOneKaiJian.bZhongJiang[self.m_ptZhongJiang[i][k].x][self.m_ptZhongJiang[i][k].y] = true
            end
            local iconType = self.m_cbIconType[i]
            if iconType == GameLogic.CT_SCATTER then
                bDelete = false
            end
            local pActionOneYaXian = {}
            pActionOneYaXian.nZhongJiangXian = i
            pActionOneYaXian.lXianTime = ICON_TIME[self.m_cbIconType[i]][line-2]
            pActionOneYaXian.lXianType = iconType        
            self.m_Times = self.m_Times + pActionOneYaXian.lXianTime
            pActionOneYaXian.lXianScore = pActionOneYaXian.lXianTime * self.m_lBetScore[self.m_bYafenIndex]
            pActionOneYaXian.lScore = self.m_lGetCoins
            pActionOneYaXian.ptXian = self.m_ptZhongJiang[pActionOneYaXian.nZhongJiangXian]
            self.m_UserActionYaxian[#self.m_UserActionYaxian + 1] = pActionOneYaXian            
        end
    end

    self.tagFreeKaiJian = { }
    self.tagFreeKaiJian = GameLogic:GetScatterCount(self.m_cbItemInfo)

    return bDelete
end




function GameLayer:setGameMode(state)
    print(state)
    self.m_cbGameMode = state
end
--获取游戏状态
function GameLayer:getGameMode()
    if self.m_cbGameMode then
        return self.m_cbGameMode
    end
end
--游戏开始
function GameLayer:GameStart()
    if self._bReceiveSceneMsg == false or self.m_bIsItemMove == true then
        return ;
    end
    -- self.m_llFreeScore = 0    --免费游戏累积赢金，不能清空
    if self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING then
        if self.m_lTotalYafen > self.m_lScore + self.m_lGetCoins and self.m_bFreetime == false then
            local num = self.m_bFreetime and 1 or 0
            showToast("Aviso: Moedas de jogo insuficientes " .. num)
            return
        end
        self.m_bIsPlayed = true       
        EventPost:addCommond(EventPost.eventType.SPIN,"slot每次spin",1,nil,{gameId = cmd.KIND_ID,
            roomId = GlobalUserItem.roomMark,betPrice = self.m_lTotalYafen
        })  
        local ref=self:sendStartMsg()--发送准备消息
        print("goldvase============gamestart")
    end
end

function GameLayer:onBeginRoll()
     self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
     self:setGameMode(GAME_STATE.GAME_STATE_WAITTING_RESPONSE)
     self._gameView:updataBtnEnable()
     self.m_bIsItemMove = true
     self._gameView:WinLightSetVisibleFalse()
     self._gameView:setLevel(0)
     self._gameView.m_ScrollLayer:run()
end

--自动游戏
function GameLayer:onAutoStart()
    self._gameView:closeClock()
    if self.m_lTotalYafen > self.m_lScore + self.m_lGetCoins then
        showToast("Aviso: Moedas de jogo insuficientes")
        self.m_bIsAuto = false        
        return
    end
    self.m_bIsAuto = true
    self:GameStart()
end
--最大加注
function GameLayer:onAddMaxScore()
    self.m_bYafenIndex = self.m_bMaxNum
    self.m_lYaxian = GameLogic.YAXIANNUM;
    self.m_lYafen= self.m_lBetScore[self.m_bYafenIndex]--压分
    self.m_lTotalYafen = self.m_lYafen*self.m_lYaxian --总压分
    self._gameView:updateScore()
    self._gameView:onShowLine()
end
--最小加注
function GameLayer:onAddMinScore( )
    self.m_bYafenIndex = 1
    self.m_lYafen=self.m_lBetScore[self.m_bYafenIndex]--压分
    self.m_lTotalYafen = self.m_lYafen*self.m_lYaxian--总压分
    self._gameView:updateScore()
end
--线
function GameLayer:onXian()
    self.m_lYaxian = self.m_lYaxian+1
    if self.m_lYaxian>GameLogic.YAXIANNUM then
        self.m_lYaxian = 1
    end
    self.m_lTotalYafen = self.m_lYafen*self.m_lYaxian--总压分
    self._gameView:updateScore()
    self._gameView:onShowLine()
end
--加注
function GameLayer:onAddScore()

    self.m_bYafenIndex = self.m_bYafenIndex + 1 
    if self.m_bYafenIndex>self.m_bMaxNum then
        self.m_bYafenIndex = self.m_bMaxNum
    end
    self.m_lYafen=self.m_lBetScore[self.m_bYafenIndex]--压分
    self.m_lTotalYafen = self.m_lYafen*self.m_lYaxian--总压分
    self._gameView:updateScore()
end
--减注
function GameLayer:onSubScore()

    self.m_bYafenIndex = self.m_bYafenIndex-1 
    if self.m_bYafenIndex<1 then
        self.m_bYafenIndex = 1
    end
    self.m_lYafen=self.m_lBetScore[self.m_bYafenIndex]--压分
    self.m_lTotalYafen = self.m_lYafen*self.m_lYaxian--总压分
    self._gameView:updateScore()
end

function GameLayer:onScore(tag)
    self.m_bYafenIndex = tag
    self.m_lYafen=self.m_lBetScore[tag]
    self.m_lTotalYafen = self.m_lYafen*self.m_lYaxian
    --压分
    self._gameView.m_textYafen:setString(self.m_lYafen)
    --总压分
--    self._gameView.m_textAllyafen:setString(string.formatNumberCoin(self._scene.m_lTotalYafen))
    local serverKind = G_GameFrame:getServerKind()
    self._gameView.m_textAllyafen:setString(g_format:formatNumber(self._scene.m_lTotalYafen,g_format.fType.abbreviation,serverKind))
end
--发送准备消息
function GameLayer:sendStartMsg()
    if self.m_lYafen<=0 then
        return false
    end
    self.m_bIsItemMove = true
    local  dataBuffer = CCmd_Data:create(1)
    dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME, g_var(cmd).SUB_C_ONE_START)   
    dataBuffer:pushbyte(self.m_bYafenIndex-1) 
    local ref=self._gameFrame:sendSocketData(dataBuffer) 
    if ref then
        print("发送开始游戏1消息")
    end
    return ref ; 
end

--************************  银行  *********************--
--银行消息
function GameLayer:onSocketInsureEvent( sub,dataBuffer )
    if sub == GameServer_CMD.SUB_GR_USER_INSURE_SUCCESS then
        local cmd_table = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureSuccess, dataBuffer)
        self.bank_success = cmd_table
        GlobalUserItem.lUserScore = cmd_table.lUserScore
    	GlobalUserItem.lUserInsure = cmd_table.lUserInsure
        --self._gameView:updateAsset(GlobalUserItem.lUserScore-self.m_nAllPlayJetton)
        if self._gameView._bankLayer then
            self._gameView._bankLayer:onBankSuccess()
        end
        
    elseif sub == GameServer_CMD.SUB_GR_USER_INSURE_FAILURE then
        local cmd_table = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureFailure, dataBuffer)
        self.bank_fail = cmd_table
        if self._gameView._bankLayer then
            self._gameView._bankLayer:onBankFailure()
        end  
    elseif sub == GameServer_CMD.SUB_GR_USER_INSURE_INFO then --银行资料
        local cmdtable = ExternalFun.read_netdata(GameServer_CMD.CMD_GR_S_UserInsureInfo, dataBuffer)
        --dump(cmdtable, "cmdtable", 6)
        if self._gameView._bankLayer then
            self._gameView._bankLayer:onGetBankInfo(cmdtable)
        end      
    else
        print("unknow gamemessage sub is ==>"..sub)
    end
end

function GameLayer:sendNetData( cmddata )
    return self._gameFrame:sendSocketData(cmddata)
end

--申请取款
function GameLayer:sendTakeScore(lScore, szPassword )
    local cmddata = ExternalFun.create_netdata(GameServer_CMD.CMD_GR_C_TakeScoreRequest)
    cmddata:setcmdinfo(GameServer_CMD.MDM_GR_INSURE, GameServer_CMD.SUB_GR_TAKE_SCORE_REQUEST)
    cmddata:pushbyte(GameServer_CMD.SUB_GR_TAKE_SCORE_REQUEST)
    cmddata:pushscore(lScore)
    cmddata:pushbyte(0)
    cmddata:pushstring(md5(szPassword),G_NetLength.LEN_PASSWORD)

    self:sendNetData(cmddata)
end
--请求银行信息
function GameLayer:sendRequestBankInfo()
    local cmddata = CCmd_Data:create(67)
    cmddata:setcmdinfo(GameServer_CMD.MDM_GR_INSURE,GameServer_CMD.SUB_GR_QUERY_INSURE_INFO)
    cmddata:pushbyte(GameServer_CMD.SUB_GR_QUERY_INSURE_INFO)
    cmddata:pushstring(md5(GlobalUserItem.szPassword),G_NetLength.LEN_PASSWORD)

    self:sendNetData(cmddata)
end

function GameLayer:onBackgroundCallBack(bEnter)
--    if bEnter then
--        local time = os.time()
--        if math.abs(self.m_time - time) >= 60 then
--            self:onExitTable()
--        end
--    else
--        self.m_time = os.time()
--    end
end
function GameLayer:playGamebgMusic()
    if GlobalUserItem.bVoiceAble then
        -- 播放背景音乐
        AudioEngine.playMusic("sound_res/BG.wav", true)
    end
end

--踢出消息10S 提示
function GameLayer:onOutGameTips()
    self:showTipsExit()
end

return GameLayer