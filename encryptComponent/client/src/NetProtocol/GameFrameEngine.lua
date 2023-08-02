local GameFrameEngine = class("GameFrameEngine")

local UserItem = appdf.req(appdf.CLIENT_SRC.."NetProtocol.ClientUserItem")
local game_cmd = appdf.req(appdf.CLIENT_SRC.."NetProtocol.CMD_GameServer")

function GameFrameEngine:ctor()
	self._kindID = 0
	self._kindVersion = 0
    self._reConnectCount   = 0
    self._isRequestGameOption = false
end
function GameFrameEngine:setViewFrame(viewFrame)
	self._viewFrame = viewFrame
end
function GameFrameEngine:setCallBack(callback)
	self._callBack = callback
end

function GameFrameEngine:setKindInfo(id,version)
	self._kindID = id 
	self._kindVersion = version
	return self
end
function GameFrameEngine:isSocketServer()
	return G_ServerMgr:isSocketServer()
end
function GameFrameEngine:onCloseSocket()
    G_ServerMgr:onCloseSocket()
end

function GameFrameEngine:onInitData()
	--房间信息 以后转移
	self._wTableCount = 0
	self._wChairCount = 0
	self._wServerType = 0
	self._dwServerRule = 0
	self._UserList = {}
	self._tableUserList = {}
	self._tableStatus = {}
	self._delayEnter = false

	self._wTableID	 	= G_NetCmd.INVALID_TABLE
	self._wChairID	 	= G_NetCmd.INVALID_CHAIR
	self._cbTableLock	= 0
	self._cbGameStatus 	= 0
	self._cbAllowLookon	= 0
	self.bChangeDesk = false
    self.bDelayQuit = false  --是否延迟退出
	self.bEnterAntiCheatRoom = false 		--进入防作弊房间
	GlobalUserItem.bWaitQuit = false 		-- 退出等待
end

function GameFrameEngine:setEnterAntiCheatRoom( bEnter )
	self.bEnterAntiCheatRoom = bEnter
end
--登录到游戏
function GameFrameEngine:onLogonRoom()
	tlog('GameFrameEngine:onLogonRoom')
    self._roomInfo = GlobalUserItem.GetRoomInfo(GlobalUserItem.roomMark)
	if self._roomInfo == nil then return end
	local kindid = g_ExternalFun.getKindID(GlobalUserItem.roomMark)
	local serverKind = g_ExternalFun.getServerKind(GlobalUserItem.roomMark)
	local sortid = g_ExternalFun.getSortID(GlobalUserItem.roomMark)
    if self._roomInfo and self._roomInfo.wServerKind == G_NetCmd.GAME_KIND_GOLD and GlobalUserItem.lUserScore < self._roomInfo.lEnterScore then
        -- local msg = g_language:getString("socre_less_enter_game")
        -- local str = g_format:formatNumber(self._roomInfo.lEnterScore,g_format.fType.standard,serverKind)
        -- showToast( string.format(msg,str))
        dismissNetLoading()
		cc.UserDefault:getInstance():setIntegerForKey("LastRoomIndex",0)
        cc.UserDefault:getInstance():flush()
		G_event:NotifyEvent(G_eventDef.EVENT_SCORE_LESS,self._roomInfo)  --金币不足
        return
    end

	if self._roomInfo and self._roomInfo.wServerKind == G_NetCmd.GAME_KIND_TC and GlobalUserItem.lTCCoin < self._roomInfo.lEnterScore then
		local msg = g_language:getString("socre_less_enter_game")
		local str = g_format:formatNumber(self._roomInfo.lEnterScore,g_format.fType.standard,serverKind)
        showToast( string.format(msg,str))
		dismissNetLoading()
		return 
	end

    G_ServerMgr:onConnectGame(kindid,sortid,serverKind)
end

--登录到API游戏
function GameFrameEngine:onLogonAPIGame()
	local kindid = g_ExternalFun.getKindID(GlobalUserItem.roomMark)
	local serverKind = g_ExternalFun.getServerKind(GlobalUserItem.roomMark)
	local sortid = g_ExternalFun.getSortID(GlobalUserItem.roomMark)
	G_ServerMgr:onConnectGame(kindid,sortid,serverKind)
end

--连接结果
function GameFrameEngine:onConnectCompeleted()
	local dataBuffer = CCmd_Data:create(213)
	dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME_LOGON,G_NetCmd.C_GAME_LOGON_MOBILE)
	local kindid = g_ExternalFun.getKindID(GlobalUserItem.roomMark)
    dataBuffer:pushword(self._kindID or kindid)
	dataBuffer:pushdword(self._kindVersion)
	dataBuffer:pushbyte(ylAll.DEVICE_TYPE)
	dataBuffer:pushword(0x0011)
	dataBuffer:pushword(255)

	dataBuffer:pushdword(GlobalUserItem.dwUserID)
	dataBuffer:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
	dataBuffer:pushstring(GlobalUserItem.szRoomPasswd,G_NetLength.LEN_PASSWORD)
	dataBuffer:pushstring(GlobalUserItem.szMachine,G_NetLength.LEN_MACHINE_ID)

    self:sendGameSocketData(dataBuffer)

    GlobalData.GameConnectSuccess = false
    self._isRequestGameOption = false
end

function GameFrameEngine:directorSendData(pData)
    return G_ServerMgr:sendSocketData(pData)
end

function GameFrameEngine:sendGameSocketData(pData)
    return G_ServerMgr:C2S_SendGameProtocol(pData)
end

function GameFrameEngine:sendSocketData(pData)
    return self:sendGameSocketData(pData)
end

--网络信息
function GameFrameEngine:onSocketEvent(main,sub,dataBuffer)
    --登录信息
	if main == G_NetCmd.MAIN_GAME_LOGON then
		self:onSocketLogonEvent(sub,dataBuffer)
	--配置信息
	elseif main == G_NetCmd.MAIN_GAME_CONFIG then
		self:onSocketConfigEvent(sub,dataBuffer)
	--用户信息
	elseif main == G_NetCmd.MAIN_GAME_USER then
		self:onSocketUserEvent(sub,dataBuffer)
	--状态信息
	elseif main == G_NetCmd.MAIN_GAME_FRAME_STATUS then
		self:onSocketStatusEvent(sub,dataBuffer)
	elseif main == G_NetCmd.MAIN_GAME_FRAME then  --游戏框架
		self:onSocketFrameEvent(sub,dataBuffer)
	elseif main == G_NetCmd.MAIN_GAME then  --游戏命令
		if self._viewFrame and self._viewFrame.onEventGameMessage then
			self._viewFrame:onEventGameMessage(sub,dataBuffer)
            GlobalData.GameConnectSuccess = true
		end
	elseif main == game_cmd.MAIN_GAME_INSURE then
		if self._viewFrame and self._viewFrame.onSocketInsureEvent then
			self._viewFrame:onSocketInsureEvent(sub,dataBuffer)
		end
	end
end

function GameFrameEngine:onSocketLogonEvent(sub,dataBuffer)
	tlog('GameFrameEngine:onSocketLogonEvent ', sub)
	print("GameFrameEngine:onSocketLogonEvent(sub,dataBuffer) sub = ",sub)
	--登录完成
	if sub == G_NetCmd.S_GAME_LOGON_FINISH then	
		self:onSocketLogonFinish()
	-- 登录成功
	elseif sub == G_NetCmd.S_GAME_LOGON_SUCCESS then
		local cmd_table = g_ExternalFun.read_netdata(game_cmd.CMD_GR_LogonSuccess, dataBuffer)
	--登录失败
	elseif sub == G_NetCmd.S_GAME_LOGON_FAILURE then	
		local errorCode = dataBuffer:readint()
		local msg = dataBuffer:readstring()
		print('sub == G_NetCmd.S_GAME_LOGON_FAILURE ', msg)
		self:onCloseSocket()
		if nil ~= self._callBack then
            if errorCode == 20 or errorCode == 3 or errorCode == 1 then
            else
			    self._callBack(-1,"O número de jogadores na sala está cheio")
            end
		end		
        G_event:NotifyEvent(G_eventDef.NET_LOGON_ROOM_FAILER,{errorCode = errorCode}) 
	--升级提示
	elseif sub == G_NetCmd.S_GAME_UPDATE_NOTIFY then
		if nil ~= self._callBack then
			self._callBack(-1,"版本信息错误")
		end		
	elseif sub == G_NetCmd.S_ENTRY_API_GAME then
		local pGameID = dataBuffer:readdword()
		--local wServKind = dataBuffer:readword()
		--local cbGameMode = dataBuffer:readbyte()
		local pParams = dataBuffer:readutf8()
		
    	--local serverKind = wServKind -- g_ExternalFun.getServerKind(GlobalUserItem.roomMark)
		local serverKind = g_ExternalFun.getServerKind(GlobalUserItem.roomMark)
		if serverKind == 9 then
			g_EasyGame:EnterGame(pGameID,pParams)		
		elseif serverKind == 10 then
			g_PocketGame:EnterGame(pGameID,pParams)--,cbGameMode)
		end
	end
end

--登录完成
function GameFrameEngine:onSocketLogonFinish()
	if self._delayEnter == true then
		return
	end	
	local myUserItem   =  self:GetMeUserItem()
	if not myUserItem and nil ~= self._callBack then
		self._callBack(-1,"获取自己信息失败！")
		return
	end
    self._delayEnter = false
    if self._wTableID ~= G_NetCmd.INVALID_TABLE then
    	if self._viewFrame and self._viewFrame.onEnterTable then
    		self._viewFrame:onEnterTable()
    	end
	    if self._isRequestGameOption == true then return end
        self._isRequestGameOption = true
    	self:SendGameOption()
    else
        GlobalData.GameConnectSuccess = true
    	if self._viewFrame and self._viewFrame.onEnterRoom then
    		self._viewFrame:onEnterRoom()
    	end
    end
end

--房间配置
function GameFrameEngine:onSocketConfigEvent(sub,dataBuffer)
	tlog("GameFrameEngine:onSocketConfigEvent", sub)
	--房间配置
	if sub == G_NetCmd.S_GAME_CONFIG_SERVER then
		self._wTableCount  		= dataBuffer:readword()
		self._wChairCount  		= dataBuffer:readword()
		self._wServerType  		= dataBuffer:readword()
		self._dwServerRule 		= dataBuffer:readdword()
		GlobalUserItem.dwServerRule = self._dwServerRule
		self:setEnterAntiCheatRoom(GlobalUserItem.isAntiCheat())  --是否进入防作弊
	--配置完成
	elseif sub == G_NetCmd.S_GAME_CONFIG_FINISH then
	--表情价格配置
	elseif sub == G_NetCmd.S_GAME_CONFIG_EXPRESSIONCOST then
		local expressionCost = {}
		local int64 = Integer64:new()
		local pCountType = dataBuffer:readbyte() --列表数量
		for i = 1, pCountType do
            local pTypeList = {}
            pTypeList.index = dataBuffer:readword() --互动表情序号
            pTypeList.costNum = dataBuffer:readscore(int64):getvalue() --耗费金币
            table.insert(expressionCost,pTypeList)
        end
		GlobalUserItem.expressionCost = expressionCost
		--tdump(GlobalUserItem.expressionCost, "onSocketConfigEvent", 9)
	end
end

function GameFrameEngine:GetTableCount()
	return self._wTableCount
end

function GameFrameEngine:GetChairCount()
	return self._wChairCount
end

function GameFrameEngine:GetServerType()
	return self._wServerType
end

function GameFrameEngine:GetServerRule()
	return self._dwServerRule
end

--房间取款准许
function GameFrameEngine:OnRoomAllowBankTake()
	return bit:_and(self._dwServerRule,0x00010000) ~= 0
end

--房间存款准许
function GameFrameEngine:OnRoomAllowBankSave()
	return bit:_and(self._dwServerRule,0x00040000) ~= 0
end

--游戏取款准许
function GameFrameEngine:OnGameAllowBankTake()
	return bit:_and(self._dwServerRule,0x00020000) ~= 0
end

--游戏存款准许
function GameFrameEngine:OnGameAllowBankSave()
	return bit:_and(self._dwServerRule,0x00080000) ~= 0
end

function GameFrameEngine:IsAllowAvertCheatMode( )
	return bit:_and(self._dwServerRule, G_NetCmd.SR_ALLOW_AVERT_CHEAT_MODE) ~= 0
end

--是否更新大厅金币
function GameFrameEngine:IsAllowPlazzScoreChange()
	return (self._wServerType ~= G_NetCmd.GAME_GENRE_SCORE) and (self._wServerType ~= G_NetCmd.GAME_GENRE_EDUCATE)
end

--游戏赠送准许
function GameFrameEngine:OnGameAllowBankTransfer()
	return false
end
--用户信息
function GameFrameEngine:onSocketUserEvent(sub,dataBuffer)
	--等待分配
	if sub == game_cmd.S_GAME_USER_WAIT_DISTRIBUTE then
	--用户进入
	elseif sub == G_NetCmd.S_GAME_USER_ENTER then
		self:onSocketUserEnter(dataBuffer)
	--用户积分
	elseif sub == G_NetCmd.S_GAME_USER_SCORE then
		self:onSocketUserScore(dataBuffer)
	--用户状态
	elseif sub == G_NetCmd.S_GAME_USER_STATUS then
		self:onSocketUserStatus(dataBuffer)
	--请求失败
	elseif sub == G_NetCmd.S_GAME_REQUEST_FAILURE then	
		self:onSocketReQuestFailure(dataBuffer)
	--用户表情
	elseif sub == G_NetCmd.S_GAMES_USER_EXPRESSION then
		local expression = g_ExternalFun.read_netdata(game_cmd.CMD_GF_S_UserExpression, dataBuffer)
		--tdump(expression, "S_GAMES_USER_EXPRESSION", 9)
		if expression.wErrorCode ~= 0 then
			return
		end
		--获取玩家昵称
		local useritem = self._UserList[expression.dwSendUserID]
		if not  useritem then
			return
		end
		if self._wTableID == G_NetCmd.INVALID_CHAIR or self._wTableID ~= useritem.wTableID then
			return
		end
		expression.szNick = useritem.szNickName
		G_event:NotifyEvent(G_eventDef.NET_GAMES_USER_EXPRESSION, expression)  --收到表情事件
	end
end
--用户进入
function GameFrameEngine:onSocketUserEnter(dataBuffer)
	local userItem = UserItem:create()
    local len = dataBuffer:getlen()
	userItem.dwGameID		= dataBuffer:readdword()
	userItem.dwUserID		= dataBuffer:readdword()

	--自己判断
	local bMySelfInfo = (userItem.dwUserID == GlobalUserItem.dwUserID)
	--非法过滤
	if not self._UserList[GlobalUserItem.dwUserID]  then
		if	bMySelfInfo == false then
			printInfo("还未有自己信息，不处理其他用户信息")
			return
		end
	else 
		if bMySelfInfo == true then
			printInfo("已有自己信息，不再次处理自己信息")
			return
		end
	end
	local int64 = Integer64.new()
	--读取信息
	userItem.wFaceID 		= dataBuffer:readword()
	userItem.dwCustomID		= dataBuffer:readdword()

	userItem.cbGender		= dataBuffer:readbyte()
	userItem.cbMemberOrder	= dataBuffer:readbyte()

	userItem.wTableID		= dataBuffer:readword()
	userItem.wChairID		= dataBuffer:readword()
	userItem.cbUserStatus 	= dataBuffer:readbyte()

	userItem.lScore			= dataBuffer:readscore(int64):getvalue()
	userItem.lIngot			= dataBuffer:readscore(int64):getvalue()
	userItem.dBeans			= dataBuffer:readdouble()

	userItem.dwWinCount		= dataBuffer:readdword()
	userItem.dwLostCount	= dataBuffer:readdword()
	userItem.dwDrawCount	= dataBuffer:readdword()
	userItem.dwFleeCount	= dataBuffer:readdword()
	userItem.dwExperience	= dataBuffer:readdword()
	userItem.lIntegralCount = dataBuffer:readscore(int64):getvalue()
	userItem.dwAgentID		= dataBuffer:readdword()
	userItem.dwIpAddress 	= dataBuffer:readdword() -- ip地址	
	userItem.dwDistance	    = nil 					 -- 距离

	local curlen = dataBuffer:getcurlen()
	local datalen = dataBuffer:getlen()
	local tmpSize 
	local tmpCmd
	while curlen<datalen do
		tmpSize = dataBuffer:readword()
		tmpCmd = dataBuffer:readword()
		if not tmpSize or not tmpCmd then
		 	break
		end
		if tmpCmd == G_NetCmd.DTP_GR_NICK_NAME then
			userItem.szNickName 	= dataBuffer:readstring(tmpSize/2)
			if not userItem.szNickName or (self:IsAllowAvertCheatMode() == true and userItem.dwUserID ~=  GlobalUserItem.dwUserID) then
				userItem.szNickName = userItem.dwGameID
			end
		elseif tmpCmd == G_NetCmd.DTP_GR_UNDER_WRITE then
			userItem.szSign = dataBuffer:readstring(tmpSize/2)
			if not userItem.szSign or (self:IsAllowAvertCheatMode() == true and userItem.dwUserID ~=  GlobalUserItem.dwUserID) then
				userItem.szSign = "此人很懒，没有签名"
			end
		elseif tmpCmd == 0 then
			break
		else
			for i = 1, tmpSize do
				if not dataBuffer:readbyte() then
					break
				end
			end
		end
		curlen = dataBuffer:getcurlen()
	end
    if userItem.szNickName then
        userItem.szNickName = g_ExternalFun.FormatString2FixLen(userItem.szNickName,120,"微软雅黑",20)
    end
	printInfo("GameFrameEngine enter ==> ", userItem.szNickName, userItem.dwIpAddress, userItem.dwDistance)
	--添加/更新到缓存
	local bAdded
	local item = self._UserList[userItem.dwUserID] 
	if item ~= nil then
		item.dwGameID		= userItem.dwGameID
		item.lScore			= userItem.lScore	
		item.lIngot			= userItem.lIngot	
		item.dBeans			= userItem.dBeans	
		item.wFaceID 		= userItem.wFaceID
		item.dwCustomID		= userItem.dwCustomID
		item.cbGender		= userItem.cbGender
		item.cbMemberOrder	= userItem.cbMemberOrder
		item.wTableID		= userItem.wTableID
		item.wChairID		= userItem.wChairID
		item.cbUserStatus 	= userItem.cbUserStatus
		item.dwWinCount 	= userItem.dwWinCount
		item.dwLostCount 	= userItem.dwLostCount
		item.dwDrawCount 	= userItem.dwDrawCount
		item.dwFleeCount 	= userItem.dwFleeCount
		item.dwExperience 	= userItem.dwExperience
		item.szNickName     = userItem.szNickName
		bAdded = true
	end
	if not bAdded then
		self._UserList[userItem.dwUserID] = userItem
	end

    local isCheckSuccess = true
	--记录自己桌椅号
	if userItem.dwUserID ==  GlobalUserItem.dwUserID then
		self._wTableID = userItem.wTableID
		self._wChairID = userItem.wChairID
        if self._wTableID ~= G_NetCmd.INVALID_TABLE and self._wChairID ~= G_NetCmd.INVALID_CHAIR and 
        GlobalData.CurEnterTableId ~= G_NetCmd.INVALID_TABLE and GlobalData.CurEnterChairId~= G_NetCmd.INVALID_CHAIR then
            if self._wTableID ~= GlobalData.CurEnterTableId and self._wChairID ~=  GlobalData.CurEnterChairId then
                showToast(g_language:getString("game_disconnect"))
                G_event:NotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)  
                return  
            end
        end
	end
	if userItem.wTableID ~= G_NetCmd.INVALID_TABLE  and userItem.cbUserStatus ~= G_NetCmd.US_LOOKON then
		self:onUpDataTableUser(userItem.wTableID,userItem.wChairID,userItem)
		if self._viewFrame and self._viewFrame.onEventUserEnter then
			self._viewFrame:onEventUserEnter(userItem.wTableID,userItem.wChairID,userItem)
		end
        --桌子相关更新
	end
	if bMySelfInfo == true and self._delayEnter == true then
		self._delayEnter = false
		self:onSocketLogonFinish()
	end
end
--用户积分
function GameFrameEngine:onSocketUserScore(dataBuffer)
	local dwUserID = dataBuffer:readdword()
	local int64 = Integer64.new()
	local item = self._UserList[dwUserID]
	if  item ~= nil then
		--更新数据
		item.lScore = dataBuffer:readscore(int64):getvalue()
		item.dBeans =  dataBuffer:readdouble()
		item.dwWinCount = dataBuffer:readdword()
		item.dwLostCount = dataBuffer:readdword()
		item.dwDrawCount = dataBuffer:readdword()
		item.dwFleeCount = dataBuffer:readdword()
		item.dwExperience = dataBuffer:readdword()
		printInfo("更新用户["..dwUserID.."]["..item.szNickName.."]["..item.lScore.."]["..item.wTableID.."]["..item.wChairID.."]")
		--自己信息
		if item.dwUserID == GlobalUserItem.dwUserID and self:IsAllowPlazzScoreChange() then
			printInfo("更新金币", GlobalUserItem.dwUserID, item.lScore, item.dBeans)
			GlobalUserItem.lUserScore = item.lScore
			GlobalUserItem.lTCCoinInsure = item.dBeans
		end
		--通知更新界面
		if self._wTableID ~= G_NetCmd.INVALID_TABLE and self._viewFrame and self._viewFrame.onEventUserScore  then
			self._viewFrame:onEventUserScore(item)
		end
	end  
end
--用户状态
function GameFrameEngine:onSocketUserStatus(dataBuffer)
	--读取信息
	local dwUserID 		= dataBuffer:readdword()
	local newstatus = {}
	newstatus.wTableID   	= dataBuffer:readword()
	newstatus.wChairID   	= dataBuffer:readword()
	newstatus.cbUserStatus	= dataBuffer:readbyte()
	if newstatus.cbUserStatus == G_NetCmd.US_LOOKON then --过滤观看
		return
	end
	local myUserItem  =  self:GetMeUserItem()
	if not myUserItem then
		if newstatus.wTableID ~= G_NetCmd.INVALID_TABLE then
			self._delayEnter = true
			self:QueryUserInfo(newstatus.wTableID,newstatus.wChairID)
			return
		end
		self:onCloseSocket()
		if nil ~= self._callBack then  --非法信息
			self._callBack(-1,"用户信息获取不正确,请重新登录！")
		end		
		return
	end	
	local bMySelfInfo = (dwUserID == myUserItem.dwUserID)
	local useritem = self._UserList[dwUserID]
	--找不到用户
	if useritem == nil then
		if newstatus.wTableID ~= G_NetCmd.INVALID_TABLE then  --虚拟信息
			local newitem = UserItem:create()
			newitem.szNickName = "游戏玩家"
			newitem.dwUserID = dwUserID
			newitem.cbUserStatus = cbUserStatus
			newitem.wTableID = newstatus.wTableID
			newitem.wChairID = newstatus.wChairID
			self._UserList[dwUserID] = newitem
			self:onUpDataTableUser(newitem.wTableID,newitem.wChairID,newitem)
			--发送查询
			self:QueryUserInfo(newstatus.wTableID,newstatus.wChairID)
		end
		return
	end
	-- 记录旧状态
	local oldstatus = {}
	oldstatus.wTableID = useritem.wTableID
	oldstatus.wChairID = useritem.wChairID
	oldstatus.cbUserStatus = useritem.cbUserStatus
	--更新信息
	useritem.cbUserStatus = newstatus.cbUserStatus
	useritem.wTableID = newstatus.wTableID
	useritem.wChairID = newstatus.wChairID
	print(useritem.wTableID,useritem.wChairID,useritem.dwGameID)
	--清除旧桌子椅子记录
	if oldstatus.wTableID ~= G_NetCmd.INVALID_TABLE then
		--新旧桌子不同 新旧椅子不同
		if (oldstatus.wTableID ~= newstatus.wTableID) or (oldstatus.wChairID ~= newstatus.wChairID) then
			self:onUpDataTableUser(oldstatus.wTableID, oldstatus.wChairID, nil)
		end
	end
	--新桌子记录
	if newstatus.wTableID ~= G_NetCmd.INVALID_TABLE then
		self:onUpDataTableUser(newstatus.wTableID, newstatus.wChairID, useritem)
	end
	--自己状态
	if  bMySelfInfo == true then
		self._wTableID = newstatus.wTableID
		self._wChairID = newstatus.wChairID
		if newstatus.cbUserStatus == G_NetCmd.US_NULL then  --离开
			if self._viewFrame and self._viewFrame.onExitRoom and not GlobalUserItem.bWaitQuit then
				self._viewFrame:onExitRoom()
			end
		elseif newstatus.cbUserStatus == G_NetCmd.US_FREE and oldstatus.cbUserStatus > G_NetCmd.US_FREE then --起立
			if self._viewFrame and self._viewFrame.onExitTable and not GlobalUserItem.bWaitQuit then
				if self.bEnterAntiCheatRoom then  --"防作弊换桌"
					self:OnResetGameEngine()
				elseif not self.bChangeDesk and not self.bDelayQuit then
                    -- showToast(g_language:getString("kick_out_game"))
					self._viewFrame:onExitTable()
				else
					self.bChangeDesk = false
                    self.bDelayQuit = false
					self:OnResetGameEngine()
				end
			end
		elseif newstatus.cbUserStatus >G_NetCmd.US_FREE and oldstatus.cbUserStatus <G_NetCmd.US_SIT then--坐下
			printInfo("自己坐下")
			self.bChangeDesk = false
			if self._viewFrame and self._viewFrame.onEnterTable then
				self._viewFrame:onEnterTable()
			end
			self:SendGameOption()
			if self._viewFrame and self._viewFrame.onEventUserStatus then
			 	self._viewFrame:onEventUserStatus(useritem,newstatus,oldstatus)
			end
		elseif newstatus.wTableID ~= G_NetCmd.INVALID_TABLE and self.bChangeDesk == true then
			printInfo("换位")
			if self._viewFrame and self._viewFrame.onEnterTable then
				self._viewFrame:onEnterTable()
			end
			self:SendGameOption()
			if self._viewFrame and self._viewFrame.onEventUserStatus then
				self._viewFrame:onEventUserStatus(useritem,newstatus,oldstatus)
			end
		else 
			printInfo("自己新状态:"..newstatus.cbUserStatus)
			if self._viewFrame and self._viewFrame.onEventUserStatus then
				self._viewFrame:onEventUserStatus(useritem,newstatus,oldstatus)
			end
		end 
	else  --他人状态
		--更新用户
		if oldstatus.wTableID ~= G_NetCmd.INVALID_TABLE or newstatus.wTableID ~= G_NetCmd.INVALID_TABLE then
			if self._viewFrame and self._viewFrame.onEventUserStatus then
				self._viewFrame:onEventUserStatus(useritem,newstatus,oldstatus)
			end
		end
		--删除用户
		if newstatus.cbUserStatus == G_NetCmd.US_NULL then
			self:onRemoveUser(dwUserID)
		end
	end
end

--请求失败
function GameFrameEngine:onSocketReQuestFailure(dataBuffer)
	local cmdtable = g_ExternalFun.read_netdata(game_cmd.CMD_GR_RequestFailure, dataBuffer)
	if  self._viewFrame and self._viewFrame.onReQueryFailure then
		self._viewFrame:onReQueryFailure(cmdtable.lErrorCode,cmdtable.szDescribeString)
	end
    self:onCloseSocket()
	if self.bChangeDesk == true then
		self.bChangeDesk = false
		if  self._viewFrame and self._viewFrame.onExitTable and not GlobalUserItem.bWaitQuit then
			self._viewFrame:onExitTable()
		end
	end
	-- 清理锁表
	GlobalUserItem.dwLockServerKindID = 0
	GlobalUserItem.dwLockKindID = 0
end
--状态信息
function GameFrameEngine:onSocketStatusEvent(sub,dataBuffer)
	if sub == G_NetCmd.S_GAME_FRAME_TABLE_INFO then
		local wTableCount = dataBuffer:readword()
		for i = 1, wTableCount do
			self._tableStatus[i] ={}
			self._tableStatus[i].cbTableLock = dataBuffer:readbyte()					
			self._tableStatus[i].cbPlayStatus = dataBuffer:readbyte()
			self._tableStatus[i].lCellScore = dataBuffer:readint()
		end
		if self._viewFrame and self._viewFrame.onGetTableInfo then
			self._viewFrame:onGetTableInfo()
		end
	elseif sub == G_NetCmd.S_GAME_FRAME_TABLE_STATUS then	--桌子状态		
		local wTableID = dataBuffer:readword() + 1		
		self._tableStatus[wTableID] ={}
		self._tableStatus[wTableID].cbTableLock = dataBuffer:readbyte()					
		self._tableStatus[wTableID].cbPlayStatus = dataBuffer:readbyte()
		self._tableStatus[wTableID].lCellScore = dataBuffer:readint()
		if self._viewFrame and self._viewFrame.upDataTableStatus then
			self._viewFrame:upDataTableStatus(wTableID)
		end
	end
end
--框架信息
function GameFrameEngine:onSocketFrameEvent(sub,dataBuffer)
	--游戏状态
	if sub == G_NetCmd.S_GAME_FRAME_STATUS then
		self._cbGameStatus = dataBuffer:readword()
		self._cbAllowLookon = dataBuffer:readword()
	--游戏场景
	elseif sub == G_NetCmd.S_GAME_FRAME_SCENE then
        G_event:NotifyEvent(G_eventDef.UI_CONNECT_SUCCESS)
		if self._viewFrame and self._viewFrame.onEventGameScene then
            GlobalData.GameConnectSuccess = true
			self._viewFrame:onEventGameScene(self._cbGameStatus,dataBuffer)
            printInfo("收到场景消息")
			G_event:NotifyEvent(G_eventDef.EVENT_GAMESCENEFINISH)  --游戏场景完成，标识进入游戏成功
		else
			printInfo("游戏中末定义处理场景情况")  
		end
	--系统消息
	elseif sub == G_NetCmd.S_GAME_FRAME_SYSTEM_MESSAGE then
		self:onSocketSystemMessage(dataBuffer)
	--动作消息
	elseif sub == G_NetCmd.S_GAME_FRAME_ACTION_MESSAGE then
		self:onSocketActionMessage(dataBuffer)
	--用户聊天
	elseif sub == G_NetCmd.S_GAMES_USER_CHAT then
		local chat = g_ExternalFun.read_netdata(game_cmd.CMD_GF_S_UserChat, dataBuffer)
		--获取玩家昵称
		local useritem = self._UserList[chat.dwSendUserID]
		if not  useritem then
			return
		end
		if self._wTableID == G_NetCmd.INVALID_CHAIR or self._wTableID ~= useritem.wTableID then
			return
		end
		chat.szNick = useritem.szNickName
	-- 用户语音
	elseif sub == game_cmd.S_GAMES_USER_VOICE then
	-- 踢出消息10S 提示
	elseif sub == G_NetCmd.S_GAME_FRAME_OUTGAME_MESSAGE then
		self:onSocketOutGameMessage(dataBuffer)
	end
end

--系统消息
function GameFrameEngine:onSocketSystemMessage(dataBuffer)
	local wType = dataBuffer:readword()
	local wLength = dataBuffer:readword()
	local szString = dataBuffer:readstring(1024)
	printInfo("系统消息#"..wType.." msg:"..szString)
	local bCloseRoom = bit:_and(wType,G_NetCmd.SMT_CLOSE_ROOM)
	local bCloseGame = bit:_and(wType,G_NetCmd.SMT_CLOSE_GAME)
	local bCloseLink = bit:_and(wType,G_NetCmd.SMT_CLOSE_LINK)
	if bCloseRoom ~= 0 or bCloseGame ~= 0 or bCloseLink ~=0 then
		if 515 == wType or 501 == wType then  --游戏币低于进入分数 
        	if self._viewFrame and self._viewFrame.onExitTable then
				self._viewFrame:onExitTable(1) --truco增加一个状态判断
			end
            local coin = g_ExternalFun.GetNumber(szString)
            local msg = g_language:getString("socre_less_kick_out")
            local str = g_format:formatNumber(coin,g_format.fType.standard,g_format.currencyType.GOLD)
            showToast( string.format(msg,str))
        else
        	if self._viewFrame and self._viewFrame.onExitTable then
				self._viewFrame:onExitTable()
			end            
        end
	end
end

--踢出消息10S 提示
function GameFrameEngine:onSocketOutGameMessage(dataBuffer)
	printInfo("踢出消息------------------------")
	if self._viewFrame and self._viewFrame.onOutGameTips then
		self._viewFrame:onOutGameTips()
	end
end

--系统动作
function GameFrameEngine:onSocketActionMessage(dataBuffer)
	local wType = dataBuffer:readword()
	local wLength = dataBuffer:readword()
	local nButtonType = dataBuffer:readint()
	local szString = dataBuffer:readstring()
	printInfo("系统动作#"..wType.."#"..szString)
	local bCloseRoom = bit:_and(wType,G_NetCmd.SMT_CLOSE_ROOM)
	local bCloseGame = bit:_and(wType,G_NetCmd.SMT_CLOSE_GAME)
	local bCloseLink = bit:_and(wType,G_NetCmd.SMT_CLOSE_LINK)
	if bCloseRoom ~= 0 or bCloseGame ~= 0 or bCloseLink ~=0 then
		self:setEnterAntiCheatRoom(false)
		if self._viewFrame and self._viewFrame.onExitRoom and not GlobalUserItem.bWaitQuit then
			self._viewFrame:onExitRoom()
		else
			self:onCloseSocket()
		end
	end
end
--更新桌椅用户
function GameFrameEngine:onUpDataTableUser(tableid,chairid,useritem)
	local id = tableid + 1
	local idex = chairid + 1
	if not self._tableUserList[id]  then
		self._tableUserList[id] = {}
	end
	if useritem then
		self._tableUserList[id][idex] = useritem.dwUserID
	else
		self._tableUserList[id][idex] = nil
	end
end
--获取桌子用户
function GameFrameEngine:getTableUserItem(tableid,chairid)
	local id = tableid + 1
	local idex = chairid + 1
	if self._tableUserList[id]  then
		local userid = self._tableUserList[id][idex] 
		if userid then
			return self._UserList[userid]
		end
	end
end
function GameFrameEngine:getTableUser(tableid, chairid)
	if self._tableUserList[tableid]  then
		local userid = self._tableUserList[tableid][chairid] 
		if userid then
			return self._UserList[userid]
		end
	end
end
function GameFrameEngine:getTableInfo(index)
	if index > 0  then
		return self._tableStatus[index]
	end
end
--获取自己游戏信息
function GameFrameEngine:GetMeUserItem()
	return self._UserList[GlobalUserItem.dwUserID]
end
--获取游戏状态
function GameFrameEngine:GetGameStatus()
	return self._cbGameStatus
end
--设置游戏状态
function GameFrameEngine:SetGameStatus(cbGameStatus)
	self._cbGameStatus = cbGameStatus
end
--获取桌子ID
function GameFrameEngine:GetTableID()
	return self._wTableID
end
--获取椅子ID
function GameFrameEngine:GetChairID()
	return self._wChairID
end
--移除用户
function GameFrameEngine:onRemoveUser(dwUserID)
	self._UserList[dwUserID] = nil
end
--坐下请求
function GameFrameEngine:SitDown(table ,chair,password)
	local dataBuffer = CCmd_Data:create(70)
	dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME_USER,G_NetCmd.C_GAME_USER_SITDOWN)
	dataBuffer:pushword(table)
	dataBuffer:pushword(chair)
	self._reqTable = table
	self._reqChair = chair
	if password then
		dataBuffer:pushstring(password,G_NetLength.LEN_PASSWORD)
	end
    printInfo("用户坐下="..table.."  _  "..chair)
	--记录坐下信息
	if nil ~= GlobalUserItem.m_tabEnterGame and type(GlobalUserItem.m_tabEnterGame) == "table" then
		GlobalUserItem.m_tabEnterGame.nSitTable = table
		GlobalUserItem.m_tabEnterGame.nSitChair = chair
	end
	return self:sendGameSocketData(dataBuffer)
end
--查询用户
function GameFrameEngine:QueryUserInfo(table ,chair)
	local dataBuffer = CCmd_Data:create(4)
	dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME_USER,G_NetCmd.C_GAME_USER_CHAIR_INFO_REQ)
	dataBuffer:pushword(table)
	dataBuffer:pushword(chair)
	return self:sendGameSocketData(dataBuffer)
end
--换位请求
function GameFrameEngine:QueryChangeDesk()
	self.bChangeDesk = true
	local dataBuffer = CCmd_Data:create(0)
	dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME_USER,G_NetCmd.C_GAME_USER_CHAIR_REQ)
	return self:sendGameSocketData(dataBuffer)
end
--起立请求
function GameFrameEngine:StandUp(bForce)
    GlobalUserItem.dwLockKindID = 0
	local dataBuffer = CCmd_Data:create(5)
	dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME_USER,G_NetCmd.C_GAME_USER_STANDUP)
	dataBuffer:pushword(self:GetTableID())
	dataBuffer:pushword(self:GetChairID())
	dataBuffer:pushbyte(not bForce and 0 or 1)
	return self:directorSendData(dataBuffer)
end
--发送准备
function GameFrameEngine:SendUserReady(dataBuffer)
	local userReady = dataBuffer
	if not userReady then
		userReady = CCmd_Data:create(0)
	end
	userReady:setcmdinfo(G_NetCmd.MAIN_GAME_FRAME,G_NetCmd.C_GAME_FRAME_USER_READY)
	return self:sendGameSocketData(userReady)
end
--场景规则
function GameFrameEngine:SendGameOption()
	local dataBuffer = CCmd_Data:create(9)
	dataBuffer:setcmdinfo(G_NetCmd.MAIN_GAME_FRAME,G_NetCmd.C_GAME_FRAME_OPTION)
	dataBuffer:pushbyte(0)
	dataBuffer:pushdword(appdf.VersionValue(6,7,0,1))
	dataBuffer:pushdword(self._kindVersion)
	return self:sendGameSocketData(dataBuffer)
end
--加密桌子
function GameFrameEngine:SendEncrypt(pass)
	local passlen = string.len(pass) * 2 
	local len = passlen +17--(sizeof game_cmd.CMD_GR_UserRule)
	local cmddata = CCmd_Data:create(len)
	cmddata:setcmdinfo(G_NetCmd.MAIN_GAME_FRAME, G_NetCmd.C_GAME_USER_RULE)
	cmddata:pushbyte(0)
	cmddata:pushword(0)
	cmddata:pushword(0)
	cmddata:pushint(0)
	cmddata:pushint(0)
	cmddata:pushword(passlen)
	cmddata:pushword(G_NetCmd.DTP_GR_TABLE_PASSWORD)	
	cmddata:pushstring(pass, passlen / 2)
	return self:sendGameSocketData(cmddata)
end

--发送文本聊天 game_cmd.CMD_GF_C_UserChat
--[msg] 聊天内容
--[tagetUser] 目标用户
function GameFrameEngine:sendTextChat( msg, tagetUser , color)
	if type(msg) ~= "string" then
		print("聊天内容异常")
		return false, "聊天内容异常!"
	end
	--敏感词判断
	if true == g_ExternalFun.isContainBadWords(msg) then
		print("聊天内容包含敏感词汇")
		return false, "聊天内容包含敏感词汇!"
	end
	msg = msg .. "\0"

	tagetUser = tagetUser or G_NetCmd.INVALID_USERID
	color = color or 16777215 --appdf.ValueToColor( 255,255,255 )
	local msgLen = string.len(msg)
	local defineLen = G_NetCmd.LEN_USER_CHAT * 2

	local cmddata = CCmd_Data:create(266 - defineLen + msgLen * 2)
	cmddata:setcmdinfo(G_NetCmd.MAIN_GAME_USER,game_cmd.SUB_GF_USER_CHAT)
	cmddata:pushword(msgLen)
	cmddata:pushdword(color)
	cmddata:pushdword(tagetUser)
	cmddata:pushstring(msg, msgLen)

	return self:sendGameSocketData(cmddata)
end

--发送表情聊天 game_cmd.CMD_GF_C_UserExpressio
--[idx] 表情图片索引
--[tagetUser] 目标用户
function GameFrameEngine:sendBrowChat( idx, tagetUser )
	tlog("GameFrameEngine:sendBrowChat", idx, tagetUser)
	tagetUser = tagetUser or G_NetCmd.INVALID_USERID

	local cmddata = CCmd_Data:create(10)
	cmddata:setcmdinfo(G_NetCmd.MAIN_GAME_USER,game_cmd.SUB_GF_USER_EXPRESSION)
	cmddata:pushword(idx)
	cmddata:pushdword(GlobalUserItem.dwUserID)
	cmddata:pushdword(tagetUser)

	return self:sendGameSocketData(cmddata)
end

function GameFrameEngine:OnResetGameEngine()
	if self._viewFrame and self._viewFrame.OnResetGameEngine then
        if self._viewFrame:GetMeUserItem() == nil then
            showToast(g_language:getString("network_timeout"))
            if self._viewFrame.onExitTable then
                self._viewFrame:onExitTable()
            elseif self._viewFrame.onExitRoom then
                self._viewFrame:onExitRoom()
            else
                G_event:NotifyEvent(G_eventDef.UI_EVENT_REMOVE_GAME_LAYER)  
            end
        else
		    self._viewFrame:OnResetGameEngine()
        end
	end
end

function GameFrameEngine:popVocieMsg()
end

function GameFrameEngine:setPlayingVoice( bPlaying )
end

function GameFrameEngine:clearVoiceQueue()
end

function GameFrameEngine:getServerKind()
	local serverKind = 1
	local roomInfo = GlobalUserItem.GetRoomInfo(GlobalUserItem.roomMark)
	if roomInfo then
		serverKind = roomInfo.wServerKind
	end
	return serverKind
end

return GameFrameEngine