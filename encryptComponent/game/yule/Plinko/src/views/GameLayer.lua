
-- 游戏消息处理类
local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.Plinko.src"
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local game_cmd = appdf.CLIENT_SRC .. "NetProtocol.CMD_GameServer"
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local userManager = appdf.req(module_pre .. ".models.plinkoUserManager")
local logic = appdf.req(module_pre .. ".models.GameLogic")
local ExternalFun = g_ExternalFun
-- local int64 = Integer64.new()
-- int64:retain()

function GameLayer:ctor(frameEngine,scene)
    math.randomseed(os.time())
    self.userManager = userManager:create() 
    GameLayer.super.ctor(self,frameEngine,scene)
    ExternalFun.registerNodeEvent(self)
    self._gameFrame:QueryUserInfo(self:GetMeUserItem().wTableID,G_NetCmd.INVALID_CHAIR)
    self._bReceiveSceneMsg = false
end

--创建场景
function GameLayer:CreateView()
    self._gameView = GameViewLayer:create(self)
    self:addChild(self._gameView, 0, 2001)
    return self._gameView
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
    return self.userManager
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
    return cmd.KIND_ID
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    tlog('GameLayer:OnResetGameEngine')
    self.m_bOnGame = false
    self.userManager:removeAllUser()
    self.userManager:initUserList(self:getUserList())
    -- self._gameView:updateTotalPeople()
end

function GameLayer:onUiExitTable()
    self:KillGameClock()  --关闭计时器
    self:getFrame():StandUp(1)
end

--退出桌子
function GameLayer:onExitTable()
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
------网络接收
-- 进游戏或重连时的场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)

    self.m_bOnGame = true
    self._gameView.m_cbGameStatus = cbGameStatus
    self._gameView.m_curRoundSelfBetRate = -1
	if cbGameStatus == cmd.SUB_S_GAME_START then     -- 场景配置数据
        self:onEventGameSceneFree(dataBuffer)
        --清空10S提示界面
        self:hideTipsExit()
	end
end

--场景数据配置
function GameLayer:onEventGameSceneFree(dataBuffer)
    local cmd_table = g_ExternalFun.readData(cmd.CMD_S_GameSceneStatus, dataBuffer)
    cmd_table.multiplesTab = {
        [1] = cmd_table.nLinesMultiples12,
        [2] = cmd_table.nLinesMultiples14,
        [3] = cmd_table.nLinesMultiples16,
    }
    self._gameView:onGameFree(cmd_table)
    local userList = self.userManager:getUserList()
    for i,v in ipairs(userList) do
        self:changeUserInfo(v)
    end
end


--玩家下注
function GameLayer:sendUserBet(lBetIndex, lMode,lineType)
    local data = {
        lBetIndex = lBetIndex-1,
        cbLineType = lineType,
        lMode = lMode
    }
    local dataBuffer = g_ExternalFun.writeData(G_NetCmd.MAIN_GAME,cmd.SUB_C_START,cmd.CMD_C_OneStart,data)
    self._gameFrame:sendSocketData(dataBuffer) 
end

-- --上传路径
-- function GameLayer:sendRoute(data)
--     local dataBuffer = g_ExternalFun.writeData(G_NetCmd.MAIN_GAME,cmd.SUB_C_SEND_ROUTE,cmd.CMD_S_RouteResult,data)
--     self._gameFrame:sendSocketData(dataBuffer)
-- end


-- 游戏消息
function GameLayer:onEventGameMessage(sub, dataBuffer)
    tlog('GameLayer:onEventGameMessage ', sub)
    if self.m_bLeaveGame or nil == self._gameView then
        return
    end

	if sub == cmd.SUB_S_GAME_START then 
        --自己的算路线
		-- self:onCalculateRoute(dataBuffer)
        --广播路线
        self:onRouteResult(dataBuffer)
	elseif sub == cmd.UB_S_SEND_ROUTE then 
		--广播路线
        self:onRouteResult(dataBuffer)
	elseif sub == cmd.SUB_S_CALCULATE_ROUTE then 
        -- --算路线 其他玩家的
		-- self:onCalculateRoute(dataBuffer)
	elseif sub == cmd.SUB_S_USER_DATA then 
		self:onSubChangeUserScore(dataBuffer)
	elseif sub == cmd.SUB_S_SEND_GAMERECORD then 
		self:onSubChangeUserScore(dataBuffer)
	else
		print("unknow gamemessage sub is ==>"..sub)
	end
end


-- --服务器请求算路线
-- function GameLayer:onCalculateRoute(dataBuffer)
--     print("onCalculateRoute")
--     local cmd_table = g_ExternalFun.readData(cmd.CMD_S_CalculateRoute,dataBuffer)
--     -- dump(cmd_table,"onCalculateRoute")
--     self._gameView:onCalculateRoute(cmd_table)
-- end


--广播路线
function GameLayer:onRouteResult(dataBuffer)
    -- print("onRouteResult")
    local cmd_table = g_ExternalFun.readData(cmd.CMD_S_RouteResult,dataBuffer)
    -- dump(cmd_table,"onRouteResult")
    self._gameView:onRouteResult(cmd_table)
    
    local viewID = self:getPlayerByChairID(cmd_table.wChairID)
    if viewID == logic.viewID.me then
        --清空10S提示界面
        self:hideTipsExit()
    end
    -- self.userManager:dumpTableUserList(self:GetMeChairID(),self:GetMeTableID())
end

--更新积分
function GameLayer:onSubChangeUserScore(dataBuffer)
    local cmd_table = g_ExternalFun.readData(cmd.CMD_S_User_data, dataBuffer)
    -- dump(cmd_table, "crash_GameLayer:onSubGameStart", 10)
    self._gameView:changeUserScore(cmd_table)
end

--游戏记录
function GameLayer:onSubSendRecord(dataBuffer)
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_ServerOpenGameRecord, dataBuffer)
    -- dump(cmd_table, "GameLayer:onSubSendRecord", 10)
    self._gameView:initHistoryNode(cmd_table)
end

--管理员命令
function GameLayer:onSubAdminCmd(dataBuffer)
end

--更新库存
function GameLayer:onSubUpdateStorage(dataBuffer)
end

function GameLayer:onEventUserEnter(wTableID,wChairID,useritem)
    print("GameLayer:onEventUserEnter tableID: "..useritem.wTableID.. "wChairID:" .. useritem.wChairID .. "; 用户进入 " .. useritem.dwGameID)
    --缓存用户
    self.userManager:addUser(useritem)
    self:changeUserInfo(useritem)
end

function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)

    if newstatus.cbUserStatus == G_NetCmd.US_FREE then
        print("删除")
        self.userManager:removeUser(useritem)
    else
        --刷新用户信息
        self.userManager:updateUser(useritem)
    end

    -- NetCmdDefine.US_NULL								    = 0x00		--没有状态
    -- NetCmdDefine.US_FREE								    = 0x01		--站立状态
    -- NetCmdDefine.US_SIT								    = 0x02		--坐下状态
    -- NetCmdDefine.US_READY								= 0x03		--同意状态
    -- NetCmdDefine.US_LOOKON							    = 0x04		--旁观状态
    -- NetCmdDefine.US_PLAYING					 		    = 0x05		--游戏状态
    -- NetCmdDefine.US_OFFLINE							    = 0x06		--断线状态
    self:changeUserInfo(useritem)

end

function GameLayer:changeUserInfo(useritem)
    local viewID = self:getPlayerByChairID(useritem.wChairID)
    if useritem.wChairID == G_NetCmd.INVALID_CHAIR or useritem.wTableID == G_NetCmd.INVALID_TABLE then
        if self.m_leftUser and self.m_leftUser.dwUserID == useritem.dwUserID then
            self._gameView:clearUser(logic.viewID.left,useritem)
            self.m_leftUser = nil
        elseif self.m_rightUser and self.m_rightUser.dwUserID == useritem.dwUserID then
            self._gameView:clearUser(logic.viewID.right,useritem)
            self.m_rightUser = nil
        end
        return
    end
    if viewID == 1 then
        --自己
        print("自己坐下")
        print(useritem.wTableID,useritem.wChairID,useritem.dwGameID)
    else
        --其他玩家
        if viewID == logic.viewID.left then
            self.m_leftUser = useritem
            print("左边用户坐下")
            print(useritem.wTableID,useritem.wChairID,useritem.dwGameID)
            -- dump(userInfo)
        end
        if viewID == logic.viewID.right then
            self.m_rightUser = useritem
            print("右边用户坐下")
            print(useritem.wTableID,useritem.wChairID,useritem.dwGameID)
            -- dump(userInfo)
        end

        if useritem.cbUserStatus >= G_NetCmd.US_SIT and useritem.cbUserStatus ~= G_NetCmd.US_LOOKON then
            self._gameView:upDateUser(viewID,useritem)
        else
            self._gameView:clearUser(viewID,useritem)
        end
    end
end

--踢出消息10S 提示
function GameLayer:onOutGameTips()
    self:showTipsExit()
end

--逻辑ID转换座位 ID
function GameLayer:getPlayerByChairID(_ChairID)  
    local nChairCount = self._gameFrame:GetChairCount()
    local MyChairID = self:GetMeChairID()
    local byViewID = (MyChairID - _ChairID + nChairCount)%nChairCount + 1;  --服务器给过来的数组从0开始，lua 从1 开始  + 1
    return byViewID;
end

function GameLayer:onEventUserScore(item)
    self.userManager:updateUser(item)
end



---------------------------------------------------------------------------------------
return GameLayer