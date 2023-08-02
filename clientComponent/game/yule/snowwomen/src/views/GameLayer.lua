-- snowwomen游戏消息处理类
local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.snowwomen.src"
local cmd = module_pre .. ".models.CMD_Game"
local game_cmd = appdf.CLIENT_SRC .. "NetProtocol.CMD_GameServer"
appdf.req(module_pre .. ".views.layer.WWNodeEx")
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
--local GameHistoryDetailLayer = appdf.req(module_pre .. ".views.layer.GameHistoryDetailLayer")
local QueryDialog = appdf.req("client.src.UIManager.QueryDialogNew")
local g_var = g_ExternalFun.req_var
local GameFrame = appdf.req(module_pre .. ".models.GameFrame")

local int64 = Integer64.new()
int64:retain()

local lines = {
    {{1, 0}, {1, 1}, {1, 2}, {1, 3}, {1, 4}},       --1线        
    {{0, 0}, {0, 1}, {0, 2}, {0, 3}, {0, 4}},       --2线
    {{2, 0}, {2, 1}, {2, 2}, {2, 3}, {2, 4}},       --3线
    {{0, 0}, {1, 1} ,{2, 2}, {1, 3}, {0, 4}},       --4线
    {{2, 0}, {1, 1} ,{0, 2}, {1, 3}, {2, 4}},       --5线
    {{1, 0}, {0, 1} ,{0, 2}, {0, 3}, {1, 4}},       --6线
    {{1, 0}, {2, 1} ,{2, 2}, {2, 3}, {1, 4}},       --7线
    {{0, 0}, {0, 1} ,{1, 2}, {2, 3}, {2, 4}},       --8线
    {{2, 0}, {2, 1} ,{1, 2}, {0, 3}, {0, 4}},       --9线
    {{1, 0}, {2, 1} ,{1, 2}, {0, 3}, {1, 4}},       --10线
    {{1, 0}, {0, 1} ,{1, 2}, {2, 3}, {1, 4}},       --11线
    {{0, 0}, {1, 1} ,{1, 2}, {1, 3}, {0, 4}},       --12线
    {{2, 0}, {1, 1} ,{1, 2}, {1, 3}, {2, 4}},       --13线
    {{0, 0}, {1, 1} ,{0, 2}, {1, 3}, {0, 4}},       --14线
    {{2, 0}, {1, 1} ,{2, 2}, {1, 3}, {2, 4}},       --15线
    {{1, 0}, {1, 1} ,{0, 2}, {1, 3}, {1, 4}},       --16线
    {{1, 0}, {1, 1} ,{2, 2}, {1, 3}, {1, 4}},       --17线
    {{0, 0}, {0, 1} ,{2, 2}, {0, 3}, {0, 4}},       --18线
    {{2, 0}, {2, 1} ,{0, 2}, {2, 3}, {2, 4}},       --19线
    {{0, 0}, {2, 1} ,{2, 2}, {2, 3}, {0, 4}},       --20线
    {{2, 0}, {0, 1} ,{0, 2}, {0, 3}, {2, 4}},       --21线
    {{1, 0}, {2, 1} ,{0, 2}, {2, 3}, {1, 4}},       --22线
    {{1, 0}, {0, 1} ,{2, 2}, {0, 3}, {1, 4}},       --23线
    {{0, 0}, {2, 1} ,{0, 2}, {2, 3}, {0, 4}},       --24线
    {{2, 0}, {0, 1} ,{2, 2}, {0, 3}, {2, 4}},       --25线
    {{2, 0}, {0, 1} ,{1, 2}, {2, 3}, {0, 4}},       --26线
    {{0, 0}, {2, 1} ,{1, 2}, {0, 3}, {2, 4}},       --27线
    {{0, 0}, {2, 1} ,{1, 2}, {2, 3}, {0, 4}},       --28线
    {{2, 0}, {0, 1} ,{1, 2}, {0, 3}, {2, 4}},       --29线
    {{2, 0}, {1, 1} ,{0, 2}, {0, 3}, {1, 4}},       --30线
}

function GameLayer:ctor(frameEngine,scene)
    g_ExternalFun.registerNodeEvent(self)
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
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    tlog('GameLayer:OnResetGameEngine')
    self._dataModle:removeAllUser()
    self._dataModle:initUserList(self:getUserList())
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

    --移除共用的纹理
    self._gameView:rleasePlistRes()
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
--玩家下注开始旋转
function GameLayer:sendUserBet(totalAdd)
    tlog('GameLayer:sendUserBet ', totalAdd)
    local cmdData = g_ExternalFun.create_netdata(g_var(cmd).CMD_C_Scene1Start)
    cmdData:pushbyte(totalAdd)
    
    self:SendData(g_var(cmd).SUB_C_SCENE1_START, cmdData)
end
--小玛利玩法选择序号
function GameLayer:sendBounsSelect(selectIdx)
    tlog('GameLayer:sendBounsSelect ', selectIdx)
    local cmddata = g_ExternalFun.create_netdata(g_var(cmd).CMD_C_HitGoldEgg)
    cmddata:pushint(selectIdx)

    self:SendData(g_var(cmd).SUB_C_HIT_GOLDEGG, cmddata)
end

------网络接收
--押中的线转换成押中的道具数组
function GameLayer:convertLineToAward(zJLineArray, nFruitAreaDistri)
    local nAwardItem = {{},{},{}}--3行5列
    for i=1,g_var(cmd).MAX_HS do
        for j=1,g_var(cmd).MAX_LS do
            nAwardItem[i][j] = false
        end
    end
    for i=1,#zJLineArray do
        if zJLineArray[i] > 0 then
            local oneLine = lines[i]
            if oneLine then
                local firstPos = oneLine[1]
                local firstType = nFruitAreaDistri[firstPos[1]+1][firstPos[2]+1]+1 --后端类型从0开始判断时+1
                print("ajdsofajsdofajosf111", firstType, i)
                for j=1,#oneLine do
                    local oneCell = oneLine[j]
                    local cellType = nFruitAreaDistri[oneCell[1]+1][oneCell[2]+1]+1 --后端类型从0开始判断时+1
                    print("ajdsofajsdofajosf222", cellType, oneCell[1]+1, oneCell[2]+1)
                    if cellType == firstType or cellType == g_var(cmd).itemType.eSnowGirl then
                        print("ajdsofajsdofajosf333")
                        nAwardItem[oneCell[1]+1][oneCell[2]+1] = true
                    else
                        break
                    end
                end
            end
        end
    end
    return nAwardItem
end
-- 进游戏或重连时的场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    tlog("场景数据:" .. cbGameStatus)
    local cmdData = g_ExternalFun.readData(g_var(cmd).CMD_S_SCENE_Data, dataBuffer)
    tdump(cmdData)
    cmdData.nFruitAreaDistri = cmdData.result_icons
    --押中的线转换成押中的道具数组
    local nAwardItem = self:convertLineToAward(cmdData.zJLineArray, cmdData.nFruitAreaDistri)
    cmdData.nAwardItem = nAwardItem
    cmdData.lAwardGold = cmdData.lWinScore
    cmdData.lScore = cmdData.win_score[1]

    self._gameView.m_cbGameStatus = cbGameStatus
    self._gameView.m_curRoundIsSelfBet = false
    self._gameView:initGameOfScene(cmdData)
    --清空10S提示界面
    self:hideTipsExit()
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub, dataBuffer)
    tlog('GameLayer:onEventGameMessage ', sub)
    if nil == self._gameView then
        return
    end
    local cmd_command = g_var(cmd)
	if sub == cmd_command.SUB_S_SCENE1_START then 
        --self._gameView.m_cbGameStatus = cmd_command.GAME_PLAY
		self:onUserStartRollEvent(dataBuffer)
        --清空10S提示界面
        self:hideTipsExit()
	elseif sub == cmd_command.SUB_S_HIT_GOLDEGG_RES then 
		self:onSubHitGoldeggResp(dataBuffer)
    elseif sub == cmd_command.SUB_S_GOLDEGG_DETAIL then 
        self:onSubHitGoldeggDetail(dataBuffer)
    elseif sub == cmd_command.SUB_GAME_CONFIG then
        self:onSubGameConfig(dataBuffer)
    elseif sub == cmd_command.SUB_S_USER_DATA then
        self:onSubUserData(dataBuffer)
	else
		print("unknow gamemessage sub is ==>"..sub)
	end
end

--用户下注(开始旋转)
function GameLayer:onUserStartRollEvent(dataBuffer)
    tlog("game bet")
    local cmdData = g_ExternalFun.readData(g_var(cmd).CMD_S_Scene1Start, dataBuffer)

    --testcode
    --[[for i=1,20 do
        cmdData.zJLineArray[i] = 0
    end
    cmdData.zJLineArray[1] = 3
    cmdData.zJLineArray[8] = 3
    cmdData.zJLineArray[9] = 3
    cmdData.zJLineArray[10] = 3
    cmdData.zJLineArray[11] = 3
    cmdData.zJLineArray[12] = 3
    cmdData.zJLineArray[13] = 3
    cmd.itemType = {
        eNone = 0,   
        ePokerTen = 1,
        ePokerJ = 2,  
        ePokerQ = 3,  
        ePokerK = 4,
        ePokerA = 5,
        eBird = 6,
        eWolf = 7,
        eBear = 8,
        eDiamond = 9,
        eBoat = 10,
        eSnowGirl = 11,
    }
    cmdData.result_icons[1] = {0, 0, 2, 9, 1}
    cmdData.result_icons[2] = {0, 0, 0, 1, 3}
    cmdData.result_icons[3] = {0, 0, 6, 3, 0}--]]

    tdump(cmdData, "snowwomen_GameLayer:onUserStartRollEvent", 10)
    cmdData.nFruitAreaDistri = cmdData.result_icons

    local nAwardItem = self:convertLineToAward(cmdData.zJLineArray, cmdData.nFruitAreaDistri)
    cmdData.nAwardItem = nAwardItem
    cmdData.lAwardGold = cmdData.lWinScore
    dump(nAwardItem, "ajdsofajsdofajosf444", 9)

    self._gameView:startRoll(cmdData)
end

--玛丽结果
function GameLayer:onSubHitGoldeggResp(dataBuffer)
    tlog("onSubHitGoldeggResp")
    local cmdData = g_ExternalFun.readData(g_var(cmd).Cmd_S_HitGoldEggRes, dataBuffer)
    tdump(cmdData, "snowwomen_GameLayer:onSubHitGoldeggResp", 10)
    self._gameView:onSubHitGoldeggResp(cmdData)
end

--玛丽结算
function GameLayer:onSubHitGoldeggDetail(dataBuffer)
    tlog("onSubHitGoldeggDetail")
    local cmdData = g_ExternalFun.readData(g_var(cmd).Cmd_S_GoldEggDetail, dataBuffer)
    tdump(cmdData, "snowwomen_GameLayer:onSubHitGoldeggDetail", 10)
    self._gameView:onSubHitGoldeggDetail(cmdData)
end

--服务配置（下注配置）
function GameLayer:onSubGameConfig(dataBuffer)
    tlog("onSubGameConfig")
    local cmdData = g_ExternalFun.readData(g_var(cmd).CMD_S_GameConfig, dataBuffer)
    tdump(cmdData, "snowwomen_GameLayer:onSubGameConfig", 10)
    self._gameView:onBetConfigUpdate(cmdData)
end

--用户赢分反馈（主要处理其他人，暂时未用到）
function GameLayer:onSubUserData(dataBuffer)
    tlog("onSubUserData")
    local cmdData = g_ExternalFun.readData(g_var(cmd).CMD_S_User_data, dataBuffer)
    tdump(cmdData, "snowwomen_GameLayer:onSubUserData", 10)
end

--踢出消息10S 提示
function GameLayer:onOutGameTips()
    self:showTipsExit()
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
    print("snowwomen_GameLayer:onEventUserEnter add user ", wTableID, wChairID, useritem.szNickName)
    --缓存用户
    self._dataModle:addUser(useritem)
end

function GameLayer:onEventUserStatus(useritem, newstatus, oldstatus)
    local chairId = useritem.wChairID
    local tableId = useritem.wTableID
    local name = useritem.szNickName
    local newStatus = newstatus.cbUserStatus
    local oldStatus = oldstatus.cbUserStatus
    print("snowwomen_GameLayer:onEventUserStatus ", chairId, tableId, name, newStatus, oldStatus)
    if newStatus == G_NetCmd.US_FREE then
        print("删除")
        self._dataModle:removeUser(useritem)
    else
        --刷新用户信息
        self._dataModle:updateUser(useritem)
    end
end

function GameLayer:onEventUserScore(item)
    -- tdump(item, 'GameLayer:onEventUserScore', 10)
    tlog("snowwomen_GameLayer:onEventUserScore ", item.wChairID, item.szNickName)
    self._dataModle:updateUser(item)
    --self._gameView:onGetUserScore(item)
end

---------------------------------------------------------------------------------------
return GameLayer