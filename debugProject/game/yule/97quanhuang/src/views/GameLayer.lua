local GameModel = appdf.req(appdf.CLIENT_SRC .. "gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
-- local Game2Layer = class("Game2Layer", GameModel)

local module_pre = "game.yule.97quanhuang.src";

local cmd = module_pre .. ".models.CMD_Game"

local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local g_var = g_ExternalFun.req_var
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local QueryDialog = appdf.req("client.src.UIManager.QueryDialogNew")
-- local GameFrame = appdf.req(module_pre .. ".models.GameFrame")

local emGameState =
{
    "GAME_STATE_WAITTING",-- 等待
    "GAME_STATE_WAITTING_RESPONSE",-- 等待服务器响应
    "GAME_STATE_MOVING",-- 转动
    "GAME_STATE_RESULT",-- 结算
    "GAME_STATE_WAITTING_GAME2",-- 等待游戏2
    "GAME_STATE_END"-- 结束
}
local GAME_STATE = g_ExternalFun.declarEnumWithTable(0, emGameState)

local emGame2State =
{
    "GAME2_STATE_WAITTING",
    "GAME2_STATE_WAVING",
    "GAME2_STATE_WAITTING_CHOICE",
    "GAME2_STATE_OPEN",
    "GAME2_STATE_RESULT"
}
local GAME2_STATE = g_ExternalFun.declarEnumWithTable(0, emGame2State)

function GameLayer:ctor(frameEngine, scene)

    g_ExternalFun.registerNodeEvent(self)

    self.m_bLeaveGame = false

    GameLayer.super.ctor(self, frameEngine, scene)
    -- self._gameFrame:QueryUserInfo( self:GetMeUserItem().wTableID,G_NetCmd.INVALID_CHAIR)

    self:addAnimationEvent()
    -- 监听加载完动画的事件
end

function GameLayer:getFrame()
    return self._gameFrame                  
end 
-- 创建场景
function GameLayer:CreateView()
    self._gameView = GameViewLayer[1]:create(self)
    g_ExternalFun.adapterWidescreen(self._gameView)
    self:addChild(self._gameView, 0, 2001) 
    return self._gameView
end

function GameLayer:OnInitGameEngine()
    GameLayer.super.OnInitGameEngine(self)

    self.m_bIsLeave = false
    -- 是否离开游戏
    self.m_bIsPlayed = false
    -- 是否玩过游戏
    self.m_cbGameStatus = 0
    -- 游戏状态

    self.m_cbGameMode = 0
    -- 游戏模式

    -- 游戏逻辑操作
    self.m_bIsItemMove = false
    -- 动画是否滚动的标示
    self.m_lCoins = 0
    -- 游戏币
    self.m_lYaxian = GameLogic.YAXIANNUM
    -- 压线
    self.m_lYafen = 0
    -- 压分
    self.m_lTotalYafen = 0
    -- 总压分
    self.m_lGetCoins = 0
    -- 获得金钱

    self.m_bEnterGame3 = false
    -- 是否小玛丽
    self.m_bEnterGame2 = true
    -- 是否比倍
    self.m_bYafenIndex = 1
    -- 压分索引（数组索引）
    self.m_lBetScore = { { 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0 } }
    -- 压分存储数组
    self.m_cbItemInfo = { { 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0 } }
    -- 开奖信息

    -- 中奖位置
    self.m_ptZhongJiang = { }
    for i = 1, GameLogic.ITEM_COUNT do
        self.m_ptZhongJiang[i] = { }
        for j = 1, GameLogic.ITEM_X_COUNT do
            self.m_ptZhongJiang[i][j] = { }
            self.m_ptZhongJiang[i][j].x = 0
            self.m_ptZhongJiang[i][j].y = 0
        end
    end

    self.m_UserActionYaxian = { }
    -- 用户压线的情况


    self.m_bIsAuto = false
    -- 控制自动开始按钮
    -- self.m_bYafenIndexNow       = 0         --发送服务器时的压分索引
    self.m_bIsAuto = false
    -- 控制自动开始按钮
    self.m_bReConnect1 = false
    self.m_bReConnect2 = false
    self.m_bReConnect3 = false

    self.tagActionOneKaiJian = { }
    self.tagActionOneKaiJian.nCurIndex = 0
    self.tagActionOneKaiJian.nMaxIndex = 9
    self.tagActionOneKaiJian.lScore = 0
    self.tagActionOneKaiJian.lQuanPanScore = 0
    self.tagActionOneKaiJian.cbGameMode = 0
    self.tagActionOneKaiJian.bZhongJiang = { }
    for i = 1, GameLogic.ITEM_Y_COUNT do
        self.tagActionOneKaiJian.bZhongJiang[i] = { }
        for j = 1, GameLogic.ITEM_X_COUNT do
            self.tagActionOneKaiJian.bZhongJiang[i][j] = false
        end
    end

    -- 游戏2结果
    self.m_pGame2Result = { }
    self.m_pGame2Result.cbOpenSize = { 0, 0 }
    self.m_pGame2Result.lScore = 0
end

function GameLayer:ResetAction()
    self.tagActionOneKaiJian.nCurIndex = 0
    self.tagActionOneKaiJian.nMaxIndex = 9
    self.tagActionOneKaiJian.lScore = 0
    self.tagActionOneKaiJian.lQuanPanScore = 0
    self.tagActionOneKaiJian.cbGameMode = 0
    self.tagActionOneKaiJian.bZhongJiang = { }
    for i = 1, GameLogic.ITEM_Y_COUNT do
        self.tagActionOneKaiJian.bZhongJiang[i] = { }
        for j = 1, GameLogic.ITEM_X_COUNT do
            self.tagActionOneKaiJian.bZhongJiang[i][j] = false
        end
    end
end

function GameLayer:resetData()
    -- GameLayer.super.resetData(self)

    self.m_cbGameStatus = 0
    -- 游戏状态

    self.m_cbGameMode = 0
    -- 游戏模式

    -- 游戏逻辑操作
    self.m_bIsItemMove = false
    -- 动画是否滚动的标示
    self.m_lCoins = 0
    -- 游戏币
    self.m_lYaxian = GameLogic.YAXIANNUM
    -- 压线
    self.m_lYafen = self.m_lBetScore[self.m_bYafenIndex]
    -- 压分
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * self.m_lYafen * self.m_lYaxian
    -- 总压分
    self.m_lGetCoins = 0
    -- 获得金钱

    self.m_bEnterGame3 = false
    -- 是否小玛丽
    self.m_bEnterGame2 = false
    -- 是否比倍
    self.m_bEnterGame4 = false
    -- 是否可以进入免费次数
    self.m_bYafenIndex = 1
    -- 压分索引（数组索引）
    self.m_lBetScore = { { 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0 } }
    -- 压分存储数组
    self.m_cbItemInfo = { { 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0 } }
    -- 开奖信息
    -- self.m_ptZhongJiang         = {{},{},{}}
    -- 中奖位置
    self.m_ptZhongJiang = { }
    for i = 1, 9 do
        self.m_ptZhongJiang[i] = { }
        for j = 1, 5 do
            self.m_ptZhongJiang[i][j] = { }
            self.m_ptZhongJiang[i][j].x = 0
            self.m_ptZhongJiang[i][j].y = 0
        end
    end

    self.m_bIsAuto = false
    -- 控制自动开始按钮
    self.m_bReConnect1 = false
    self.m_bReConnect2 = false
    self.m_bReConnect3 = false
    self.MianFeiGame_End = false
    -- 免费游戏结束
    -- 游戏2结果
    self.m_pGame2Result = { }
    self.m_pGame2Result.cbOpenSize = { 0, 0 }
    self.m_pGame2Result.lScore = 0
    self.m_bNumber_of_Free = 0
    -- 免费游戏次数
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()

    local useritem = self:GetMeUserItem()
    if (self.m_bIsAuto == true and useritem.cbUserStatus == G_NetCmd.US_PLAYING and self.m_cbGameStatus == 101) or(self.m_cbGameStatus == 102 and self.m_bEnterGame2 == false) then
        -- g_var(cmd).SHZ_GAME_SCENE_FREE
        print("游戏1断线重连")
        self.m_bReConnect1 = true
    elseif self.m_cbGameStatus == 102 and self.m_bEnterGame2 == true then
        -- g_var(cmd).g_var(cmd).SHZ_GAME_SCENE_TWO
        print("游戏2断线重连")
        self.m_bReConnect2 = true
        local gameview = self._gameView
        if gameview then
            gameview:setPosition(0, 0)
            gameview:setVisible(true)
        end
        if self._game2View then
            self._game2View:removeFromParent()
            self._game2View = nil
        end

        self.m_bIsAuto = false
        self._gameView:setAutoStart(false)
        -- self._gameView.m_textTips:setString("祝您好运！")
        self:setGameMode(0)
    elseif self.m_cbGameStatus == 103 then
        -- g_var(cmd).g_var(cmd).SHZ_GAME_SCENE_THREE
        print("游戏3断线重连")
        self.m_bReConnect3 = true
    end

end

function GameLayer:addAnimationEvent()
    -- 通知监听
    local function eventListener(event)
        cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(g_var(cmd).Event_LoadingFinish)

        -- self._gameView:initMainView()
        print("移除监听事件")
        if self._gameView then

            self._gameView:onLoadComplete()
            self:SendUserReady()

        end
    end

    local listener = cc.EventListenerCustom:create(g_var(cmd).Event_LoadingFinish, eventListener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end
--------------------------------------------------------------------------------------
function GameLayer:onExit()
    print("gameLayer onExit()...................................")
    self:KillGameClock()
end

-- 退出桌子
function GameLayer:onExitTable()
    -- 强制离开游戏(针对长时间收不到服务器消息的情况)
    self:KillGameClock()
    self:onExitRoom()
end

-- 离开房间
function GameLayer:onExitRoom()
    self._gameFrame:StandUp(1)
    self:getFrame():onCloseSocket()
    --self._scene:onKeyBack()
    G_event:NotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)
end
-- 系统消息
function GameLayer:onSystemMessage(wType, szString)
    if wType == 515 then
        -- 515 当玩家没钱时候
        self.m_querydialog = QueryDialog:create(szString, function()

            self:KillGameClock()
            local MeItem = self:GetMeUserItem()
            if MeItem and MeItem.cbUserStatus > G_NetCmd.US_FREE then
                self:showPopWait()
                self:runAction(cc.Sequence:create(
                cc.CallFunc:create(
                function()
                    self._gameFrame:StandUp(1)
                end
                ),
                cc.DelayTime:create(10),
                cc.CallFunc:create(
                function()
                    print("delay leave")
                    self:onExitRoom()
                end
                )
                )
                )
                return
            end
            self:onExitRoom()

        end , nil, 1)
        self.m_querydialog:setCanTouchOutside(false)
        self.m_querydialog:addTo(self)
    end
end

-- -------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------场景消息

-- -- 场景信息
function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    print("场景数据1111:" .. cbGameStatus)
   -- self._gameView:removeAction()
    self:KillGameClock()
    --清空10S提示界面
    self:hideTipsExit()
    -- self._gameView.m_cbGameStatus = cbGameStatus;
	self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE;
	if  g_var(cmd).GAME_SCENE_START == cbGameStatus then
		print("收到场景数据 -- 开始");
		local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).SHZ_CMD_S_SCENE, dataBuffer)
		dump(cmd_table)
		-- 获得网络信息回馈 g_ExternalFun.read_netdata qweqwe
		-- 初始化数据
			
		self.m_bMaxNum = cmd_table.cbMaxBetCount;   -- 8
		self.m_lYafen = cmd_table.lCellScore;		-- 1
		self.m_bYafenIndex  = cmd_table.cbBetIndex; -- 1-8
		self.m_lBetScore = GameLogic:copyTab(cmd_table.lBetScore[1])
		-- print(self.m_lBetScore[self.m_bYafenIndex] ..",".. self.m_lYafen ..",".. self.m_lYaxian);
        local max_line = self.m_lYaxian
        self.m_bYafenIndex = self:getBetIndex(self.m_lBetScore,max_line)
        if self.m_bYafenIndex > self.m_bMaxNum then
            self.m_bYafenIndex = self.m_bMaxNum
        end
		self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * self.m_lYafen * (self.m_lYaxian)

		-- 1 玩家分数
		self.m_lCoins = self:GetMeUserItem().lScore
		print("玩家分数:" .. self.m_lCoins)
        self._gameView:SetNumber_And_Meney(1, self.m_lCoins)
		-- 2 :奖金池的金币
		self.m_JiangJin_Score = cmd_table.lReward;
		self._gameView:SetNumber_And_Meney(2, self.m_JiangJin_Score)
		print("奖金池的金币:" .. self.m_JiangJin_Score)

		-- 3 :赢分:
		self.m_lGetCoins = cmd_table.lWinScore;
		self._gameView.m_textGetScore =  cmd_table.lWinScore;
		self._gameView:SetNumber_And_Meney(3, self._gameView.m_textGetScore);
		print("赢分:" .. self.m_lGetCoins)

		-- 4 ：总下注金币
		self._gameView.m_textAllyafen = self.m_lTotalYafen
		self._gameView:SetNumber_And_Meney(4, self._gameView.m_textAllyafen)
		print("总下注金币:" .. self.m_lTotalYafen) 
		
		-- 5 ：下注积分
		self._gameView.m_textYafen = self.m_lBetScore[self.m_bYafenIndex]
		self._gameView:SetNumber_And_Meney(5, self._gameView.m_textYafen)
		print("下注积分:" .. self._gameView.m_textYafen) 

		-- 6:免费次数
		self.m_bNumber_of_Free = cmd_table.cbFreeCount
		self._gameView.m_textFreeNum = cmd_table.cbFreeCount
		
		-- self._gameView:SetNumber_And_Meney(6, self._gameView.m_textFreeNum)

		-- 7 ：压线
		self._gameView.m_textYaxian = self.m_bYafenIndex;
		self._gameView:SetNumber_And_Meney(7, self._gameView.m_textYaxian);
    
		-- 继续免费游戏
		self.freeAtScene = (self.m_bNumber_of_Free > 0) and true or false;
		self.m_bEnterGame4 = self.freeAtScene
		self.m_cbGameStatus = self.freeAtScene and g_var(cmd).SHZ_GAME_SCENE_TWO or g_var(cmd).SHZ_GAME_SCENE_FREE;
		
		-- 继续小玛丽
		self.bonusAtScene = (cmd_table.cbBonusStep > 0) and true or false;
		self.m_bEnterGame3 = self.bonusAtScene;
		self.m_cbGameStatus = self.bonusAtScene and g_var(cmd).SHZ_GAME_SCENE_THREE or g_var(cmd).SHZ_GAME_SCENE_FREE
		
        if self.freeAtScene == true then
            self:onGameStart() 
        end
        if self.bonusAtScene == true then
            self:onEnterGame3()
        end
		-- self._gameView:game1Result();
		print("收到场景数据 -- 结束");
		return;
	end;

--    if cbGameStatus == g_var(cmd).SHZ_GAME_SCENE_FREE then
--        -- 空闲状态
--        self:onEventGameSceneFree(dataBuffer);
--    elseif cbGameStatus == g_var(cmd).SHZ_GAME_SCENE_ONE then
--        self:onEventGameSceneStatus(dataBuffer);
--    elseif cbGameStatus == g_var(cmd).SHZ_GAME_SCENE_TWO then
--        self:onEventGame2SceneStatus(dataBuffer);
--    elseif cbGameStatus == g_var(cmd).SHZ_GAME_SCENE_THREE then
--        -- self:onEventGameSceneStatus(dataBuffer);
--    end
end

-- 
function GameLayer:onGameInitComplete()
	print("游戏环境加载完毕");
	if self.m_bEnterGame4  then
		self._gameView:game1Result();
	elseif self.m_bEnterGame3 then
		self._gameView:game1Result();
	end
end


-- self:SetNumber_And_Meney(2,self.m_textScore )       -- 2 ：奖金池金币
-- self:SetNumber_And_Meney(3,self.m_textGetScore )    -- 3 ：赢得金币
-- self:SetNumber_And_Meney(4,self.m_textAllyafen )    -- 4 ：总下注金币
-- self:SetNumber_And_Meney(5,self.m_textYafen )       -- 5 ：下注积分


-- 不要了
--function GameLayer:onEventGameSceneFree(buffer)
--    -- 空闲
--     local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).SHZ_CMD_S_StatusFree, buffer)
--    -- 获得网络信息回馈 g_ExternalFun.read_netdata qweqwe
--    -- 初始化数据
--    self.m_bMaxNum = cmd_table.cbBetCount
--    self.m_lYafen = cmd_table.lCellScore
--	-- 玩家游戏币
--    self.m_lCoins = self:GetMeUserItem().lScore
--	print(
--		",cmd_table.cbBetCount=" .. cmd_table.cbBetCount ..
--		",self.m_bYafenIndex=" .. self.m_bYafenIndex ..
--		",cmd_table.lCellScore=" .. cmd_table.lCellScore);
--	self.m_JiangJin_Score = cmd_table.lReward;
--    -- 奖金池的分数
--    self.m_lBetScore = GameLogic:copyTab(cmd_table.lBetScore)
--    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * self.m_lYafen * self.m_lYaxian
--    -- 压分
--    self._gameView.m_textYafen = self.m_lBetScore[self.m_bYafenIndex]
--    -- 总压分  Text_allyafen
--    self._gameView.m_textAllyafen = self.m_lTotalYafen
--    -- 删除子节点
--    -- self._gameView:SetNumber_And_Meney()
--	-- 1 玩家分数
--	-- 2 :奖金池的金币
--	self._gameView:SetNumber_And_Meney(2, self.m_JiangJin_Score)

--	-- 3 :赢分

--	self._gameView:SetNumber_And_Meney(2, self._gameView.m_textGetScore)

--    self._gameView:SetNumber_And_Meney(4, self._gameView.m_textAllyafen)
--    -- 4 ：总下注金币
--    self._gameView:SetNumber_And_Meney(5, self._gameView.m_textYafen)
--    -- 5 ：下注积分

--	print("类成员:self.m_lTotalYafen=" .. self.m_lTotalYafen .. 
--				",self.m_bYafenIndex=" .. self.m_bYafenIndex);
--end
---- 不要了
--function GameLayer:onEventGameSceneStatus(buffer)
--    -- local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusPlay, buffer)
--    print("···游戏1 ====================== >")

--end
---- 不要了
--function GameLayer:onEventGame2SceneStatus(buffer)
--    -- local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusPlay, buffer)
--    print("···游戏2 ====================== >")
--end


-----------------------------------------------------------------------------------
-- 游戏消息
function GameLayer:onEventGameMessage(sub, dataBuffer)
    if sub == g_var(cmd).SUB_S_GAME_START then
        -- print("SUB_S_GAME_START 游戏开始")
        self:onGame1Start(dataBuffer)
        --清空10S提示界面
        self:hideTipsExit()
    elseif sub == g_var(cmd).SUB_S_GAME_CONCLUDE then
         print("SUB_S_GAME_CONCLUDE 压线结束")
        self:onSubGame1End(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_TWO_GAME_CONCLUDE then
        print("SUB_S_TWO_GAME_CONCLUDE 免费游戏结束")
        self:onSubSendCard(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_THREE_RES_SCORE then
        -- 小游戏获得积分
        print("SUB_S_THREE_RES_SCORE 获得每次用户操作的小游戏积分")
        self:onSubGetScore(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_UPDATE_JIANGJINCHI_SCORE then
        -- 小游戏获得积分
        print("SUB_S_UPDATE_JIANGJINCHI_SCORE 奖金池积分")
        self:onJIANGJINCHIGetScore(dataBuffer)
	elseif sub == g_var(cmd).SUB_S_USER_DATA then
		print("SUB_S_USER_DATA ==  收到用户积分信息")
		self:onGetUserData(dataBuffer)

	-- 以下协议未使用 -- 
    elseif sub == g_var(cmd).SUB_S_THREE_END then
        -- print("watermargin 小玛丽结束")
        -- self:onSubGetWinner(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_USER_WIN_JIANGJIN then -- 取消
        print("SUB_S_USER_WIN_JIANGJIN == 奖金池大派奖积分")
        self:Show_JiangJinChiDaPaiJiang(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_TWO_START then 
        print("SUB_S_TWO_START == 免费游戏开始")
        -- self:onGame2Start(dataBuffer) -- 没实现
    elseif sub == g_var(cmd).SUB_S_THREE_KAI_JIANG then -- 取消
        -- 小玛丽开奖
        -- print("watermargin 小玛丽开奖")
        self:onGame3Result(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_THREE_START then -- 取消
        -- 小玛丽开始
         print("SUB_S_THREE_START 小玛丽开始")
        self:onGame3Start(dataBuffer)
    else
        print("unknow gamemessage sub is " .. sub)
    end
end

function GameLayer:onGetUserData(dataBuffer)
	-- 从服务器收到当前玩家分值
	local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).CMD_S_User_data, dataBuffer)
	dump(cmd_table)
	self.m_lCoins = cmd_table.userScore;
	self:GetMeUserItem().lScore = cmd_table.userScore;
    if self._isThreeEnd == true then
       self._gameView:SetNumber_And_Meney(1, self.m_lCoins)
    end
    self._isThreeEnd = false
end

-- 免费游戏结束
function GameLayer:onSubSendCard(dataBuffer)
    print("免费游戏结束")

    self.MianFeiGame_End = true
end

-- 奖金池大派奖的大奖数量
function GameLayer:Show_JiangJinChiDaPaiJiang(dataBuffer)
    print("奖金池得奖数据")

    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).SHZ_CMD_S_SendJiang_Score, dataBuffer)
    -- 获取网络回馈奖金池
    self.m_JiangJin_DaPaiJiang_Score = cmd_table.lScore
    -- 奖金池的分数
    self._gameView:Show_BigBang(self.m_JiangJin_DaPaiJiang_Score)
end

-- 奖金池
function GameLayer:onJIANGJINCHIGetScore(dataBuffer)
    -- 游戏开始
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).SHZ_CMD_S_JiangJin_Score, dataBuffer)
    -- 获取网络回馈奖金池
    self.m_JiangJin_Score = cmd_table.lScore
    -- 奖金池的分数
    self._gameView:SetNumber_And_Meney(2, self.m_JiangJin_Score)
    -- 2 ：奖金池金币
end
  
-- 游戏开始
function GameLayer:onGame1Start(dataBuffer)
    -- 游戏开始
    print("GameLayer -------游戏开始------")
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).SHZ_CMD_S_GameStart, dataBuffer)
    -- 获取网络回馈滚动完毕时界面的展示信息 qweqwe
    dump(cmd_table)
	-- print("获得金币:" .. "self.m_lGetCoins = " .. self.m_lGetCoins .. ",cmd_table.lScore=" .. cmd_table.lScore)
    self.m_lGetCoins = cmd_table.lScore;
    self._dwHashID = cmd_table.dwHashID  or ""
    -- 中奖的分数
    -- 进入小玛丽
    if g_var(cmd).SHZ_GAME_SCENE_THREE == cmd_table.cbGameMode then
		print("-- 进入小玛丽");
        self.m_bEnterGame3 = true
    else
        self.m_bEnterGame3 = false
        -- false
    end

    -- 免费次数
    -- if g_var(cmd).GM_FREE_PLAY == cmd_table.cbGameMode then
    if g_var(cmd).SHZ_GAME_SCENE_TWO == cmd_table.cbGameMode then
        self.m_bEnterGame4 = true
    else
        self.m_bEnterGame4 = false
    end

    -- 免费转动的次数
    self.m_bNumber_of_Free = cmd_table.cbFreePlayCount;
	self._gameView.m_textFreeNum =  self.m_bNumber_of_Free;
	print("免费次数:" .. tostring(self.m_bNumber_of_Free))

    self.XUECHIZUOBILV = cmd_table.iNowBloodCount
    self.XUANZESUOYI = cmd_table.bChangeIndex
    if self.XUECHIZUOBILV ~= -1 then
        self._gameView:SetNumber_And_Meney(8, self.XUECHIZUOBILV)
    end
    if self.XUANZESUOYI ~= -1 then
        --self._gameView:SetNumber_And_Meney(9, self.XUANZESUOYI)
    end

    print("获得金币数量-》》》》》》》》》》》》：" .. self.m_lGetCoins)

    print("免费次数---------》》》》》》》》》：" .. self.m_bNumber_of_Free)

    --[[self.m_cbItemInfo = {
        {3, 8, 7, 5, 7 },
        { 7, 5, 7, 4, 1},
        {7 ,5, 2, 4, 6 }
    }]]
    
    self.m_cbItemInfo = GameLogic:copyTab(cmd_table.cbItemInfo)

    -- 检验是否中奖
    if GameLogic:IsAllQPJiangTime(self.m_cbItemInfo) then
        self.JiangJinChiDaPaiJiang = true
        --
    else
        GameLogic:GetAllZhongJiangInfo(self.m_cbItemInfo, self.m_ptZhongJiang)
        -- 前端判定当前界面是否有中奖
    end


    -- 改变状态
	self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_ONE

	if cmd_table.lScore > 0 then
    -- if self.m_lGetCoins > 0 then
        -- 清空数组

        self.m_UserActionYaxian = { }
        -- 获取中奖信息，压线和中奖结果
        for i = 1, GameLogic.ITEM_COUNT do

            if GameLogic:getZhongJiangInfo(i, self.m_cbItemInfo, self.m_ptZhongJiang) ~= 0 then
                --
                local pActionOneYaXian = { }
                pActionOneYaXian.nZhongJiangXian = i
                pActionOneYaXian.lXianScore = GameLogic:GetZhongJiangTime(i, self.m_cbItemInfo) * self.m_lYafen * self.m_lBetScore[self.m_bYafenIndex]
                --pActionOneYaXian.lScore = self.m_lGetCoins
				pActionOneYaXian.lScore = cmd_table.lScore
                pActionOneYaXian.ptXian = self.m_ptZhongJiang[pActionOneYaXian.nZhongJiangXian]
                self.m_UserActionYaxian[#self.m_UserActionYaxian + 1] = pActionOneYaXian
            end
        end
        self:ResetAction()
        self.tagActionOneKaiJian.nCurIndex = 0
        self.tagActionOneKaiJian.nMaxIndex = 9
        self.tagActionOneKaiJian.cbGameMode = cmd_table.cbGameMode
        self.tagActionOneKaiJian.lQuanPanScore = cmd_table.lScore
        self.tagActionOneKaiJian.lScore = cmd_table.lScore
        if self.JiangJinChiDaPaiJiang ~= nil and self.JiangJinChiDaPaiJiang == true then

            for i = 1, GameLogic.ITEM_Y_COUNT do
                for j = 1, GameLogic.ITEM_X_COUNT do
                    if self.m_cbItemInfo[i][j] == 8 then

                        self.tagActionOneKaiJian.bZhongJiang[i][j] = true
                    end
                end
            end

        else

            for i = 1, GameLogic.ITEM_COUNT do
                for j = 1, GameLogic.ITEM_X_COUNT do
                    if self.m_ptZhongJiang[i][j].x ~= 0xff then

                        self.tagActionOneKaiJian.bZhongJiang[self.m_ptZhongJiang[i][j].x][self.m_ptZhongJiang[i][j].y] = true
                    end
                end
            end
        end
    end
    self.m_bIsItemMove = true
    -- 开始游戏

    self._gameView:game1Begin()
    -- 切换旗帜动作
    -- self._gameView:game1ActionBanner(false)

    if self.m_bIsAuto == true then
        self._gameView:updateStartButtonState(true)
    else
        self._gameView:updateStartButtonState(false)
    end
end

-- 游戏1结束
function GameLayer:onSubGame1End(dataBuffer)
    print("GameLayer -------游戏1结束------")
	-- if self.m_lTotalYafen > self.m_lCoins + self.m_lGetCoins then
    if self.m_lTotalYafen > self.m_lCoins then
        -- 提示游戏币不足
        showToast("Desculpe, suas moedas não são suficientes!")
        self.m_bIsAuto = false
        --self._gameView:updateStartButtonState(true)
        self._gameView:setAutoStart(false)
    else
        if self.m_bIsAuto == true then
			 print("------ 自动游戏-- " .. tostring(self:getGameMode()))
             if (self:getGameMode() == GAME_STATE.GAME_STATE_END) then
                -- and (self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING_GAME2  or (self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING) or (self:getGameMode() == GAME_STATE.GAME_STATE_END))  then
                print("服务器发送游戏结束后发现此时是自动游戏中")

                self._gameView:stopAllActions()
                local useritem = self:GetMeUserItem()

                if useritem.cbUserStatus ~= G_NetCmd.US_READY then
                    -- self.m_bIsPlayed == true and
                    self:SendUserReady()
                end

                self:sendReadyMsg()

                self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
                self:setGameMode(1)
                self._gameView.DongHua_JieSuan1 = false
            end
        elseif self._gameView.DongHua_JieSuan1 then
            -- 免费游戏判定

            print("服务器发送游戏结束后发现此时是快速游戏中")

            print("游戏开始")
            -- 发送放弃比对消息
            -- self:sendGiveUpMsg()

            self:SendUserReady()
            -- 发送准备消息
            self:sendReadyMsg()

            self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
            self:setGameMode(5)
            -- self.m_bNumber_of_Free = 0
            self._gameView.DongHua_JieSuan1 = false
        end
    end
end

function GameLayer:setGameMode(state)
    if state == 0 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_WAITTING
        -- 等待
    elseif state == 1 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_WAITTING_RESPONSE
        -- 等待服务器响应
    elseif state == 2 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_MOVING
        -- 转动
    elseif state == 3 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_RESULT
        -- 结算
    elseif state == 4 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_WAITTING_GAME2
        -- 等待游戏2
    elseif state == 5 then
        self.m_cbGameMode = GAME_STATE.GAME_STATE_END
        -- 结束
    else
        print("未知状态")
    end
    -- self.m_cbGameMode = GAME_STATE[state]
end
-- 游戏2
function GameLayer:setGame2Mode(state)
    if state == 0 then
        self.m_cbGameMode = GAME2_STATE.GAME2_STATE_WAITTING
        -- 等待
    elseif state == 1 then
        self.m_cbGameMode = GAME2_STATE.GAME2_STATE_WAVING
        -- 摇奖
    elseif state == 2 then
        self.m_cbGameMode = GAME2_STATE.GAME2_STATE_WAITTING_CHOICE
        -- 等待下注
    elseif state == 3 then
        self.m_cbGameMode = GAME2_STATE.GAME2_STATE_OPEN
        -- 结算
    elseif state == 4 then
        self.m_cbGameMode = GAME2_STATE.GAME2_STATE_RESULT
        -- 等待游戏2
    else
        print("未知状态")
    end
    -- self.m_cbGameMode = GAME_STATE[state]
end

-- 获取游戏状态
function GameLayer:getGameMode()
    if self.m_cbGameMode then
        return self.m_cbGameMode
    end
end

-- 游戏开始 -- 点击开始按钮 
function GameLayer:onGameStart()
    local useritem = self:GetMeUserItem()
    self._gameView:onHideTopMenu()
    self._gameView._isGame1Stop = false
    -- 自动开始
    if self.m_bIsAuto == true then
		 print("-------自动开始-------")
        if self:getGameMode() == GAME_STATE.GAME_STATE_MOVING then 
            self._gameView:game1End()
            -- return
            -- elseif self.m_bIsItemMove == false and (self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING_GAME2  or (self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING) or (self:getGameMode() == GAME_STATE.GAME_STATE_END)) then
        elseif self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING_GAME2 then
            print("游戏开始")
            self.m_bIsPlayed = true
            self._gameView:stopAllActions()
            -- 游戏2按钮不可用
            self._gameView:enableGame2Btn(false)
            -- 发送消息
            -- self:sendGiveUpMsg()

            -- self._gameView.m_textTips:setString("祝您好运！")
			--  if self.m_lTotalYafen > self.m_lCoins + self.m_lGetCoins then
            if self.m_lTotalYafen > self.m_lCoins  then
                -- 提示游戏币不足
                showToast("Desculpe, suas moedas não são suficientes!")
                self._gameView:Button_Gray(true)
                return
            end
            self:SendUserReady()
            -- 发送准备消息
            self:sendReadyMsg()
            -- 减去押注
--			print("更新金币11:" .. 
--				" self:GetMeUserItem().lScore=" .. tostring(self:GetMeUserItem().lScore)  .. 
--				",self.m_lTotalYafen" .. tostring(self.m_lTotalYafen)
--			);
            -- self._gameView.m_textScore = self:GetMeUserItem().lScore - self.m_lTotalYafen
            -- self._gameView:SetNumber_And_Meney(1, self._gameView.m_textScore)
			self:SetUserCurrentScore(-self.m_lTotalYafen);
			-- self._gameView:SetNumber_And_Meney(1, self._gameView.m_textScore)
            -- 1 ：玩家金币

            self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
            self:setGameMode(1)
            -- return
        else
            -- return
        end
    end
    -- 开始
    if self:getGameMode() == GAME_STATE.GAME_STATE_MOVING then
        self._gameView:game1End()
        -- elseif  self.m_bIsItemMove == false and  (self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING_GAME2) or (self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING) or (self:getGameMode() == GAME_STATE.GAME_STATE_END) then
    elseif (self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING) or(self:getGameMode() == GAME_STATE.GAME_STATE_END) then
        -- 发送放弃到比大小的消息
--        if self.m_lGetCoins > 0 then
--            -- or (self:getGameMode() == GAME_STATE.GAME_STATE_END) then
--            -- self:sendGiveUpMsg()
--        end
        
		-- if self.m_lTotalYafen > self.m_lCoins + self.m_lGetCoins then
        if self.m_lTotalYafen > self.m_lCoins then
            -- 提示游戏币不足
            showToast("Desculpe, suas moedas não são suficientes!")
            self._gameView:Button_Gray(true)
            return
        end
        self.m_bIsPlayed = true
        self._gameView:stopAllActions()
        -- 游戏2按钮不可用
        self._gameView:enableGame2Btn(false)

		print("游戏开始 - 发包")
        self:SendUserReady()
        -- 发送准备消息
        self:sendReadyMsg()
        self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
        self:setGameMode(1)
    end
end

-- 自动游戏
function GameLayer:onAutoStart()
    self._gameView:onHideTopMenu()

    -- 判断金钱是否够自动开始
    if self.m_bIsAuto == true then
        self.m_bIsAuto = false
        self._gameView:setAutoStart(false)
    else
        self.m_bIsAuto = true
		-- if self.m_lTotalYafen > self.m_lCoins + self.m_lGetCoins then
        if self.m_lTotalYafen > self.m_lCoins  then
            -- 提示游戏币不足
            showToast("Desculpe, suas moedas não são suficientes!")
            self.m_bIsAuto = false
            self._gameView:updateStartButtonState(true)
            self._gameView:setAutoStart(false)
            return
        end
        self._gameView:setAutoStart(true)

        if self.m_bIsItemMove == false then
            -- and (self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING_GAME2  or (self:getGameMode() == GAME_STATE.GAME_STATE_WAITTING) or (self:getGameMode() == GAME_STATE.GAME_STATE_END))  then
            self._gameView:stopAllActions()

            if self.m_lGetCoins > 0 then
                -- self:sendGiveUpMsg()
            end
            self.m_bIsPlayed = true
            self._gameView:enableGame2Btn(false)
            local useritem = self:GetMeUserItem()
            if useritem.cbUserStatus ~= G_NetCmd.US_READY then
                self:SendUserReady()
            end
            -- 发送准备消息
            self:sendReadyMsg()
            self.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
            self:setGameMode(1)
            -- "GAME_STATE_WAITTING_RESPONSE",     --等待服务器响应
        end
    end
end

-- 最大加注
function GameLayer:onAddMaxScore()

    self._gameView:onHideTopMenu()

    self.m_bYafenIndex = self.m_bMaxNum
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * self.m_lYafen * self.m_lYaxian
    -- 压分
    self._gameView.m_textYafen = self.m_lBetScore[self.m_bYafenIndex]
    -- 总压分
    self._gameView.m_textAllyafen = self.m_lTotalYafen

    self._gameView:SetNumber_And_Meney(5, self._gameView.m_textYafen)
    -- 5 ：下注积分
    self._gameView:SetNumber_And_Meney(4, self._gameView.m_textAllyafen)
    -- 4 ：总下注金币

    if self._gameView.Max_YaFen_Sp ~= 4 then
        self._gameView.Max_YaFen_Sp = 4
        self._gameView:Show_YaZhu_View(self._gameView.Max_YaFen_Sp, true)
        -- 增加倍数之后改变主页面显示效果
    end
end

-- 最小加注
function GameLayer:onAddMinScore()
    self._gameView:onHideTopMenu()
    self.m_bYafenIndex = 1
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * self.m_lYafen * self.m_lYaxian
    -- 压分
    self._gameView.m_textYafen = self.m_lBetScore[self.m_bYafenIndex]
    -- 总压分
    self._gameView.m_textAllyafen = self.m_lTotalYafen

    self._gameView:SetNumber_And_Meney(5, self._gameView.m_textYafen)
    -- 5 ：下注积分
    self._gameView:SetNumber_And_Meney(4, self._gameView.m_textAllyafen)
    -- 4 ：总下注金币
end

-- 加注
function GameLayer:onAddScore()
    self._gameView:onHideTopMenu()
    if self.m_bYafenIndex < self.m_bMaxNum then
        self.m_bYafenIndex = self.m_bYafenIndex + 1
    else
        self.m_bYafenIndex = self.m_bMaxNum
    end
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * self.m_lYafen * self.m_lYaxian

    -- 压分
    self._gameView.m_textYafen = self.m_lBetScore[self.m_bYafenIndex]
    -- 总压分
    self._gameView.m_textAllyafen = self.m_lTotalYafen

    self._gameView:SetNumber_And_Meney(5, self._gameView.m_textYafen)
    -- 5 ：下注积分
    self._gameView:SetNumber_And_Meney(4, self._gameView.m_textAllyafen)
    -- 4 ：总下注金币

    -- 控制什么倍数展示什么主界面特效

    if self._gameView.Max_YaFen_Sp < 4 then
        self._gameView.Max_YaFen_Sp = self._gameView.Max_YaFen_Sp + 1
        print(self._gameView.Max_YaFen_Sp)
        self._gameView:Show_YaZhu_View(self._gameView.Max_YaFen_Sp, true)
        -- 增加倍数之后改变主页面显示效果
    else
        self._gameView.Max_YaFen_Sp = 4
    end
	print("self.m_bYafenIndex = " .. self.m_bYafenIndex);

end

-- 减注
function GameLayer:onSubScore()
    self._gameView:onHideTopMenu()
    if self.m_bYafenIndex > 1 then
        self.m_bYafenIndex = self.m_bYafenIndex - 1
    else
        self.m_bYafenIndex = 1
    end
    self.m_lTotalYafen = self.m_lBetScore[self.m_bYafenIndex] * self.m_lYafen * self.m_lYaxian

    -- 压分
    self._gameView.m_textYafen = self.m_lBetScore[self.m_bYafenIndex]
    -- 总压分
    self._gameView.m_textAllyafen = self.m_lTotalYafen

    self._gameView:SetNumber_And_Meney(5, self._gameView.m_textYafen)
    -- 5 ：下注积分
    self._gameView:SetNumber_And_Meney(4, self._gameView.m_textAllyafen)
    -- 4 ：总下注金币

    -- 控制什么倍数展示什么主界面特效

    if self._gameView.Max_YaFen_Sp > 0 then
        self._gameView.Max_YaFen_Sp = self._gameView.Max_YaFen_Sp - 1
        print(self._gameView.Max_YaFen_Sp)
        self._gameView:Show_YaZhu_View(self._gameView.Max_YaFen_Sp, false)
        -- 减少倍数之后改变主页面显示效果
    else
        self._gameView.Max_YaFen_Sp = 0
    end

	print("self.m_bYafenIndex = " .. self.m_bYafenIndex);
end

--接管父类SendUserReady
function GameLayer:SendUserReady()
    print("user ready")
end

-- 发送准备消息 点击开始按钮 
function GameLayer:sendReadyMsg()
    print("发送准备消息成功,点击开始按钮" .. self.m_bYafenIndex);
    local dataBuffer = CCmd_Data:create(1)
	dataBuffer:pushbyte(self.m_bYafenIndex - 1)
    -- dataBuffer:pushscore(self.m_bYafenIndex - 1)
    self:SendData(g_var(cmd).SHZ_SUB_C_ONE_START, dataBuffer)
    EventPost:addCommond(EventPost.eventType.SPIN,"slot每次spin",1,nil,{gameId = cmd.KIND_ID,
        roomId = GlobalUserItem.roomMark,betPrice = self.m_lTotalYafen
    })  
    if self.m_lGetCoins and self.m_lGetCoins > 0 then
         g_ExternalFun.playSoundEffect("defen.mp3")
        -- self.m_lCoins = self.m_lCoins + self.m_lGetCoins
        self.m_lGetCoins = 0 
        -- self._gameView.m_textScore = self.m_lCoins
        print ("-----------分界线1------------------")
        print ("：：：：：：：：：：：：：：：：：：：：：：：："..self.m_lCoins )
        print ("：：：：：：：：：：：：：：：：：：：：：：：："..self.m_lGetCoins )
        print ("-----------分界线1------------------")
        -- self:changeUserScore(- self.m_lTotalYafen)
        self._gameView.m_textGetScore = self.m_lGetCoins

        -- self._gameView:SetNumber_And_Meney(3,self._gameView.m_textGetScore )    -- 3 ：赢得金币
		-- print("更新金币12:" .. 
		--		" self.m_lGetCoins=" .. tostring(self.m_lGetCoins)
		--	);
        -- self._gameView:SetNumber_And_Meney(1, self._gameView.m_textScore)
		--self:SetUserCurrentScore(-self.m_lTotalYafen);
        -- 1 ：玩家金币
    else
        -- self._gameView.m_textScore = self.m_lCoins
        -- self:changeUserScore(- self.m_lTotalYafen)
        self._gameView.m_textGetScore = self.m_lGetCoins
        print ("-----------分界线2------------------")
        print ("：：：：：：：：：：：：：：：：：：：：：：：："..self.m_lCoins )
        print ("：：：：：：：：：：：：：：：：：：：：：：：："..self.m_lGetCoins )
        print ("-----------分界线2------------------")
        -- self._gameView:SetNumber_And_Meney(3,self._gameView.m_textGetScore )    -- 3 ：赢得金币
--		print("更新金币13:" .. 
--			" self.m_lCoins=" .. tostring(self.m_lCoins)
--		);
--        self._gameView:SetNumber_And_Meney(1, self._gameView.m_textScore)
        -- 1 ：玩家金币
		 --self:SetUserCurrentScore(-self.m_lTotalYafen);
    end
	 self:SetUserCurrentScore(-self.m_lTotalYafen);
end

-- 发送进入免费游戏消息
function GameLayer:sendReadyMsgFree()
    print("发送免费游戏消息")
    local dataBuffer = CCmd_Data:create(0)
    self:SendData(g_var(cmd).SHZ_SUB_C_TWO_START, dataBuffer)
end


-- 发送放弃比倍消息
--function GameLayer:sendGiveUpMsg()
--    print("放弃比倍消息")
--    -- 发送数据
--    local dataBuffer = CCmd_Data:create(1)
--    -- dataBuffer:pushscore(0)
--    self:SendData(g_var(cmd).SHZ_SUB_C_TWO_GIVEUP, dataBuffer)
--end

-- 发送放弃游戏一消息
function GameLayer:sendEndGame1Msg()
    print("发送结束游戏1消息")
    -- 发送数据
    local dataBuffer = CCmd_Data:create(1)
     dataBuffer:pushscore(0)
    self:SendData(g_var(cmd).SHZ_SUB_C_ONE_END, dataBuffer)
end

-- 进入摇骰子
function GameLayer:onEnterGame2()
    --    if self.m_cbGameStatus == g_var(cmd).SHZ_GAME_SCENE_TWO then
    --        self._gameView:stopAllActions()

    --        self._gameView:enableGame2Btn(false)

    --        self._game2View = GameViewLayer[2]:create(self)
    --        self:addChild(self._game2View)

    --        self._gameView:setPosition(-1334,0)
    --    end
end
-- 进入小玛丽
function GameLayer:onEnterGame3()
	print("--- 进入小玛丽 ----" .. tostring(self.m_cbGameStatus));
    if self.m_cbGameStatus == g_var(cmd).SHZ_GAME_SCENE_THREE then
        -- self.m_lCoins = self:GetMeUserItem().lScore
        if tolua.cast(self._game3View,"cc.Layer") then
            self._game3View:removeSelf()
        end
        self._game3View = nil
        self._gameView:stopAllActions()

        self._gameView:enableGame2Btn(false)

        self._game3View = GameViewLayer[3]:create(self)
        g_ExternalFun.adapterWidescreen(self._game3View)
        self:addChild(self._game3View)

        --self._gameView:setPosition(-1334-g_offsetX, 0)
    end
end


function GameLayer:SeedDataGame3(SeedData)
    -- 创建字节数量
    local dataBuffer = CCmd_Data:create(1)
    -- CMD_C_TRHEE_SMALL_OK
    dataBuffer:pushbyte(SeedData)
    self:SendData(g_var(cmd).SHZ_THREE_SMALL_OK, dataBuffer)
end 

-- 刷新服务器分数
function GameLayer:SetUserCurrentScore(val)
	print("刷新服务器分数")
	if val == nil then
		-- 刷当前分值 
		self._gameView.m_textScore = self.m_lCoins
	else
		-- 刷新差额
		print(val)
		print(self.m_lCoins + val);
		self._gameView.m_textScore = self.m_lCoins + val;
	end
	print("更新金币14: self._gameView.m_textScore=" .. tostring(self._gameView.m_textScore));
	self._gameView:SetNumber_And_Meney(1, self._gameView.m_textScore)
    -- 1 ：玩家金币
end

--function GameLayer:changeUserScore(changeScore)
--    self.m_lCoins = self.m_lCoins + changeScore
--    self._gameView.m_textScore = self.m_lCoins
--	print("更新金币15:" .. 
--			" self.m_lCoins=" .. tostring(self.m_lCoins)
--	);
--    self._gameView:SetNumber_And_Meney(1, self._gameView.m_textScore)
--    -- 1 ：玩家金币
--end

----------------------------------------------------------------
--                      游戏3 小游戏
----------------------------------------------------------------

function GameLayer:game3DataInit()
    -- self.m_lCoins = self:GetMeUserItem().lScore
    self.m_lYafen3 = self.m_lTotalYafen
    self.m_lGetCoins3 = 0
    self.m_pGame3Info = { }
    self.m_pGame3Result = { }
    -- self.m_lRunTime = 0
end

function GameLayer:onGame3Start(dataBuffer)
    print("小玛丽开始")
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).SHZ_CMD_S_GameThreeStart, dataBuffer)
    -- dump(cmd_table)
    local pGame3Info = GameLogic:copyTab(cmd_table)

    self.m_pGame3Info[#self.m_pGame3Info + 1] = pGame3Info
    self.m_lGetCoins3 = self.m_lGetCoins3 + pGame3Info.lScore

    -- 如果元素个数等于小玛丽次数，则开始
    if cmd_table.cbBounsGameCount == 0 then
        self._game3View:game3Begin()
    end
end 

function GameLayer:onSubGetScore(dataBuffer)
    print("小游戏结算当前操作积分")
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).SHZ_CMD_S_Three_Res_Score, dataBuffer)
    -- dump(cmd_table)
    local pGame3Result = GameLogic:copyTab(cmd_table)
    self.m_lGetTpye = pGame3Result.ibonusCount
    self.m_lGetCoins3 = pGame3Result.lScore

    print(">>>>>>>>>>>小游戏次数：" .. self.m_lGetTpye)

    print(">>>>>>>>>>>小游戏每次赢得的金币数量：" .. self.m_lGetCoins3)

    self.m_pGame3Result[#self.m_pGame3Result + 1] = pGame3Result
    -- print("小玛丽结算 #self.m_pGame3Result",#self.m_pGame3Result)
end

function GameLayer:onGame3Result(dataBuffer)
    print("小玛丽结算")
    local cmd_table = g_ExternalFun.read_netdata(g_var(cmd).SHZ_CMD_S_GameThreeKaiJiang, dataBuffer)
    -- dump(cmd_table)
    local pGame3Result = GameLogic:copyTab(cmd_table)
    self.m_lGetCoins3 = self.m_lGetCoins3 + pGame3Result.lScore

    self.m_pGame3Result[#self.m_pGame3Result + 1] = pGame3Result
    -- print("小玛丽结算 #self.m_pGame3Result",#self.m_pGame3Result)
end

-- 发送准备消息
function GameLayer:sendReadyMsg3()
    -- 发送数据
    local dataBuffer = CCmd_Data:create(1)
    self:SendData(g_var(cmd).SHZ_SUB_C_THREE_START, dataBuffer)
end

function GameLayer:sendThreeEnd()
    self._isThreeEnd = true
    -- 发送数据
    local dataBuffer = CCmd_Data:create(1)
    self:SendData(g_var(cmd).SHZ_SUB_C_THREE_END, dataBuffer)
end

--踢出消息10S 提示
function GameLayer:onOutGameTips()
    self:showTipsExit()
end

return GameLayer