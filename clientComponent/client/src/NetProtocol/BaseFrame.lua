local BaseFrame = class("BaseFrame")
function BaseFrame:ctor(view,callback)
	self._viewFrame = view
	self._threadid  = nil
	self._socket    = nil
	self._callBack = callback
	self.m_tabCacheMsg = {}
end

function BaseFrame:setCallBack(callback)
	self._callBack = callback
end

function BaseFrame:setViewFrame(viewFrame)
	self._viewFrame = viewFrame
end

function BaseFrame:setSocketEvent(socketEvent)
	self._socketEvent = socketEvent	
end

function BaseFrame:getViewFrame()
	return self._viewFrame
end

function BaseFrame:isSocketServer()
	return self._socket ~= nil and self._threadid ~=nil
end

--网络错误
function BaseFrame:onSocketError(pData)
	if self._threadid == nil then
		return
	end
	local cachemsg = cjson.encode(self.m_tabCacheMsg)
	if nil ~= cachemsg then
		if cc.PLATFORM_OS_WINDOWS == g_TargetPlatform then
			LogAsset:getInstance():logData(cachemsg or "",true)
		else
			buglyReportLuaException(cachemsg or "", debug.traceback())
		end	
	end
	self:onCloseSocket(3)
	if  self._callBack ~= nil then
		if not pData then
			self._callBack(-2,g_language:getString("network_timeout"))
		elseif type(pData) == "string" then
			self._callBack(-2,pData)
		else
			local errorcode = pData:readword()
			if errorcode == nil then
				self._callBack(-2,g_language:getString("network_timeout"))
			else
				self._callBack(-2,g_language:getString("network_timeout"))		
			end
		end
	end
end

-- --全局网络回调函数
-- function onSocketCallBack(pData)
-- 	if G_ServerMgr then
-- 		G_ServerMgr:onSocketCallBack(pData)
-- 	end
-- end

--启动网络
function  BaseFrame:onCreateSocket(nType)
	tlog("BaseFrame:onCreateSocket ", szUrl,nPort,nType)
    nType = nType or 1  --1，是大厅，2以上是游戏
	--已存在连接
	if self._socket ~= nil then
		return false
	end
	--创建连接
	local this = self
	self._SocketFun = function(pData)
		this:onSocketCallBack(pData)
	end
	self._socket = CClientSocket:createSocket(self._SocketFun)
    self._socketType = nType
    if self._socket:connectSocketNew(nType,0) == true then
		self._threadid = 0
		return true
	else --创建失败
		self:onCloseSocket() 
		return false
	end
end

function BaseFrame:checkConnectStatus()
	if self._socket and self._socket:connectSocketNew(1,0) == true then
		self._threadid = 0
		return true
	else --创建失败
		self:onCloseSocket() 
		return false
	end
end

--连接游戏
function  BaseFrame:connectGame(wKind,wSort)
	tlog('BaseFrame:connectGame ', wKind, wSort)
    self._socket:connectGame(wKind,wSort)
end
function BaseFrame:GetSocketState()
    if self._socket == nil then
       return false
    end
    return true
end
-- function BaseFrame:ResetSocketnil()
--     self._socket = nil
-- end
--网络消息回调
function BaseFrame:onSocketCallBack(pData)
	if  pData == nil then   	--无效数据
		return
	end
	if not self._callBack then
		print("base frame no callback")
		self:onCloseSocket()
		return
	end
	-- 连接命令
	local main = pData:getmain()
	local sub =pData:getsub()

	if main == G_NetCmd.MAIN_SOCKET_INFO then 		--网络状态        
		if sub == G_NetCmd.EVENT_SUB_SOCKET_CONNECT_HALL then -- 1 大厅连接成功
			printInfo("EVENT_SUB_SOCKET_CONNECT_HALL 1 大厅连接成功")
			self._threadid = 1	
			self:onConnectCompeleted(0)            
            G_event:NotifyEventTwo(G_eventDef.NET_CONNECT_SUCCESS)
			G_event:NotifyEventTwo(G_eventDef.NET_NETWORK_ERROR,{code = 2})
		elseif sub == G_NetCmd.EVENT_SUB_SOCKET_CONNECT_GAME then -- 2 大厅游戏连接成功
			printInfo("EVENT_SUB_SOCKET_CONNECT_GAME 2 大厅游戏连接成功")
			self:onConnectCompeleted(1)
            G_event:NotifyEventTwo(G_eventDef.NET_CONNECT_SUCCESS)
		elseif sub == G_NetCmd.EVENT_SUB_SOCKET_CLOSED_HALL then -- 3 大厅已经关闭
			printInfo("EVENT_SUB_SOCKET_CLOSED_HALL 3 大厅已经关闭")
			self:onCloseSocket(1)
            G_event:NotifyEventTwo(G_eventDef.NET_NETWORK_ERROR,{code = 1})
		elseif sub == G_NetCmd.EVENT_SUB_SOCKET_CLOSED_GAME then -- 4 游戏已经关闭
			printInfo("EVENT_SUB_SOCKET_CLOSED_GAME 4 游戏已经关闭")
			dismissNetLoading()
			self:onCloseSocket(2)
            G_event:NotifyEventTwo(G_eventDef.NET_NETWORK_ERROR,{code = 2})
		elseif sub == G_NetCmd.EVENT_SUB_SOCKET_CLOSED_ALL then -- 5 全部连接关闭
			printInfo("EVENT_SUB_SOCKET_CLOSED_ALL 5 全部连接关闭")
			self:onCloseSocket(3)
            G_event:NotifyEventTwo(G_eventDef.NET_NETWORK_ERROR,{code = 3})
		elseif sub == G_NetCmd.EVENT_SUB_SOCKET_ERROR then	-- 6 Socket错误
			printInfo("EVENT_SUB_SOCKET_ERROR 6 Socket错误")
			if self._threadid then
				self:onSocketError(pData)
			else
				self:onCloseSocket(3)
			end	
            G_event:NotifyEventTwo(G_eventDef.NET_NETWORK_ERROR,{code = 3})
       elseif sub == G_NetCmd.EVENT_SUB_SOCKET_RECONNT then	-- 7 正在重连 
			printInfo("EVENT_SUB_SOCKET_RECONNT 7 正在重连 ")
            G_event:NotifyEventTwo(G_eventDef.NET_NETWORK_ERROR,{code = 4})        
	   else
	     	self:onCloseSocket(3)
	   end
	else
		if 1 == self._threadid then--网络数据
            printInfo("接收数据：main=",main,"sub=",sub)
			if g_testServer:checkSubCmd(main,sub) then
				g_testServer:serverEvent(main,sub,clone(pData))
			end
			self:onSocketEvent(main,sub,pData)
		end
	end
end

--关闭网络
function BaseFrame:onCloseSocket(scktype)
	if scktype == 4 then
    	self:releaseNetData()
	end
	printInfo("BaseFrame:onCloseSocket ", self._socket, self._threadid, scktype)	
	local kindid = GlobalUserItem.roomMark and g_ExternalFun.getKindID(GlobalUserItem.roomMark) or 1
	local serverKind = GlobalUserItem.roomMark and g_ExternalFun.getServerKind(GlobalUserItem.roomMark) or 1
	local sortid = GlobalUserItem.roomMark and g_ExternalFun.getSortID(GlobalUserItem.roomMark) or 1
	G_ServerMgr:onShutdownGame(kindid,sortid,serverKind)
	-- if self._socket then
    --     self._socket:closeSocket()
	-- end
	
end

--发送数据
function BaseFrame:sendSocketData(pData)
	local tabCache = {}
	tabCache["main"] = pData:getmain()
	tabCache["sub"] = pData:getsub()
	tabCache["len"] = pData:getlen()
    local kindid = 0
    if GlobalUserItem and GlobalUserItem.roomMark then
        kindid = g_ExternalFun.getKindID(GlobalUserItem.roomMark)
    end
	tabCache["kindid"] = kindid
	printInfo("发送数据：main=",pData:getmain(),"sub=",pData:getsub())
	table.insert( self.m_tabCacheMsg, tabCache )
	if #self.m_tabCacheMsg > 5 then
		table.remove(self.m_tabCacheMsg, 1)
	end
	if not self._socket:sendData(pData) then
		printInfo("发送数据失败！main=",pData:getmain(),"sub="..pData:getsub())

        G_event:NotifyEventTwo(G_eventDef.NET_NETWORK_ERROR,{code = 4})   
		return true
	end
	return true
end
--连接OK
function BaseFrame:onConnectCompeleted(scktype)
	printInfo("warn BaseFrame-onConnectResult-"..result.."scktype"..scktype)
end
--网络信息(短连接)
function BaseFrame:onSocketEvent(main,sub,pData)
	printInfo("warn BaseFrame-onSocketData-"..main.."-"..sub)
end
--网络消息(长连接)
function BaseFrame:onGameSocketEvent(main,sub,pData)
	printInfo("warn BaseFrame-onGameSocketEvent-"..main.."-"..sub)
end

return BaseFrame