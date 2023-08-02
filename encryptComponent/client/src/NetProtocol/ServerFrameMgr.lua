--[[
	登录模块
]]
package.loaded["client.src.plaza.models.BaseFrame"] = nil
local BaseFrame = appdf.req(appdf.CLIENT_SRC.."NetProtocol.BaseFrame")
local TurnTableManager = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.subinterface.TurnTable.TurnTableManager")
local ServerFrameMgr = class("ServerFrameMgr",BaseFrame)
local GameServerItem   = appdf.req(appdf.CLIENT_SRC.."NetProtocol.GameServerItem")
local logincmd = appdf.req(appdf.CLIENT_SRC.."NetProtocol.CMD_LogonServer")

local scheduler = cc.Director:getInstance():getScheduler()
local floor = math.floor
local _sort = table.sort

function ServerFrameMgr:ctor()
	ServerFrameMgr.super.ctor(self,view,handler(self,self.onNetworkCallback))
	self._plazaVersion = appdf.VersionValue(6,7,0,1)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	local tmp = ylAll.DEVICE_TYPE_LIST[targetPlatform]
	self._deviceType = tmp or ylAll.DEVICE_TYPE
	self._szMachine = g_MultiPlatform:getInstance():getMachineId()

    self.net_event_queue = {} --消息队列
    self.net_event_timeId = nil    --网络定时器id
    self.bShowNetError = false
end

function ServerFrameMgr:onShowNetMsg(msg)
     local scene = cc.Director:getInstance():getRunningScene() 
     local msg = msg or g_language:getString("network_timeout")
     showToast(msg)
end

function ServerFrameMgr:CloseToSocket()
    self:onCloseSocket()
    for i,v in pairs(self.net_event_queue) do
        v:release()  --释放
    end
    self.net_event_queue = {}
end

function ServerFrameMgr:releaseNetData()
    for i,v in pairs(self.net_event_queue) do
        v:release()  --释放
    end
    self.net_event_queue = {}
end

function ServerFrameMgr:onNetworkCallback(code,msg)
    if code < 0 and self.bShowNetError == true then
        self:onShowNetMsg(msg)
    end
    return false
end

function ServerFrameMgr:Start()
    if self.net_event_timeId == nil then
       self.net_event_timeId = scheduler:scheduleScriptFunc(handler(self,self.SendNetData), 0, false)
    end
end
function ServerFrameMgr:Close()
    if self.net_event_timeId ~= nil then
       scheduler:unscheduleScriptEntry(self.net_event_timeId)
    end
    self.net_event_timeId =nil
end
--连接结果
function ServerFrameMgr:onConnectCompeleted(nType)
    if nType == 0 then  --大厅 
        self:Start()
    end
    if nType == 1 then  --游戏
        G_GameFrame:onConnectCompeleted()
    end
end
function ServerFrameMgr:onUpdate()
   self:SendNetData()
end
function ServerFrameMgr:SendNetData()
    if #self.net_event_queue <= 0 then 
        self:Close()
        return
    end 
    self.bShowNetError = true
    local socketState = self:GetSocketState()
    if socketState == false then
        if not self:onCreateSocket(1) then
            self:CloseToSocket()
	    end
        self:Close()
        return false
    end
    local net_data = table.remove(self.net_event_queue,1)
    if not self:sendSocketData(net_data) then
        self:onShowNetMsg(g_language:getString("network_timeout"))
    end
    net_data:release()  --释放
    return 
end

--添加网络事件
function ServerFrameMgr:AddNetEvent(data)
    self:Start()
    local pCheckFlag = false
    local pMain = data:getmain()
    local pSub = data:getsub()
    if pMain and pMain == G_NetCmd.MAIN_KERNEL then
        if pSub and pSub == G_NetCmd.C_SUB_SOCKET_CONNECT or pSub == G_NetCmd.C_SUB_SOCKET_SHUTDOWN then
           pCheckFlag = true
        end
    end    
    if pCheckFlag then
        for i, v in ipairs(self.net_event_queue) do
            if v:getmain() == pMain and v:getsub() == pSub then                
                return
            end
        end
    end
    data:retain()
    table.insert(self.net_event_queue,data)
end
--收到网络消息管理
function ServerFrameMgr:onSocketEvent(main,sub,pData)

    self.bShowNetError = false
	if (main == G_NetCmd.MAIN_GP_LOGON) or (main == G_NetCmd.MAIN_MB_LOGON) then --登录命令
		self:onSubLogonEvent(sub,pData)
	elseif main == G_NetCmd.MAIN_SERVER_LIST then --房间列表
		self:onRoomListEvent(sub,pData)
	elseif main == G_NetCmd.MAIN_USER_SERVICE then
        self:onSubUserEvent(sub,pData)
        --TODO NET_BANK_DATA 为什么在这里派发
        -- G_event:NotifyEvent(G_eventDef.NET_BANK_DATA,{sub = sub,pData = pData})
	elseif main == G_NetCmd.MAIN_GAME_LIST_TYPE then   --游戏类型
        self:onSubGameEvent(sub,pData)
    elseif main == G_NetCmd.MDM_GP_AGENT then      --俱乐部
        print("CLUB_CMD sub:",sub)
        if sub == G_NetCmd.SUB_GP_AGENT_MEMBER_ORDER_RESULT then
            local cmdtable = g_ExternalFun.readData(logincmd.CMD_GP_AgentMemberOrderResult, pData)
            dump(cmdtable)
            G_event:NotifyEvent(G_eventDef.NET_CLUBMEMBERORDER,cmdtable)
        elseif sub == G_NetCmd.SUB_GP_AGENT_MEMBER_INFO_RESULT then   
            local info =  g_ExternalFun.readData(logincmd.CMD_GP_QueryMemberInfoResult, pData)
            if info.dwErrorCode == 0 then
                G_event:NotifyEvent(G_eventDef.EVENT_MEMBERINFO,info)
            else
                showToast(g_language:getString(info.dwErrorCode))
                -- print(g_language:getString(info.dwErrorCode))
            end
        end
        G_event:NotifyEvent(G_eventDef.NET_CLUB_DATA,{sub = sub,pData = pData})
    elseif main == G_NetCmd.MDM_GP_MAIL then      --邮件
        self:onSubMailEvent(sub,pData)
    else
        G_GameFrame:onSocketEvent(main,sub,pData)
    end

end
--登录命令
function ServerFrameMgr:onSubLogonEvent(sub,pData)
    if sub == G_NetCmd.S_SUB_LOGON_SUCCESS then    --登录成功  server:CMD_MB_LogonSuccess
		GlobalUserItem.szMachine = self._szMachine
		GlobalUserItem.onLoadData(pData)
		GlobalUserItem.szIpAdress = g_MultiPlatform:getInstance():getClientIpAdress() or ""
        --重置房间
		GlobalUserItem.roomlist = {}
        G_event:NotifyEvent(G_eventDef.NET_LOGON_HALL_SUCCESS)   --登录成功
    elseif sub == G_NetCmd.S_SUB_LOGON_FAILURE then   --登录失败
        self:onCloseSocket()
        local cmdtable = g_ExternalFun.read_netdata(logincmd.CMD_MB_LogonFailure, pData)
        if cmdtable.lResultCode ~= 99 then  --需要弹出更换设备框
           self:onShowNetMsg(cmdtable.szDescribeString or "登录失败，请稍后再试！",3)
        end
        G_event:NotifyEvent(G_eventDef.NET_LOGON_HALL_FAILER,cmdtable)   
    elseif sub == G_NetCmd.S_SUB_UPDATE_NOTIFY then  --更新APP
        dismissNetLoading()
        self:onShowNetMsg(g_language:getString("apk_version_error"))  --版本信息错误
    elseif sub == G_NetCmd.S_SUB_GetScoreRank then   --排行榜数据
        local int64 = Integer64:new()
        local rankInfo = {}
        local len = pData:getlen()
        rankInfo.wMyRank = pData:readdword()
        rankInfo.wCount = pData:readword()
        rankInfo.rankData = {}
        for i=1,rankInfo.wCount do
            local data={}
            data.dwUserID = pData:readdword()
            data.dwGameID = pData:readdword()
            data.szNickName = pData:readstring(32)
            data.dwFaceID = pData:readdword()
            data.dwCustomID = pData:readdword()
            data.lScore = pData:readscore(int64):getvalue()
            data.dwWinCount = pData:readdword()
            data.dwLostCount = pData:readdword()
            local wxLen = pData:readword()
            if wxLen > 0 then
               data.szWeixinId = pData:readstring(wxLen)
            end
            local len = pData:readword()
            if len > 0 then
               data.szSign = pData:readstring(len)
            end
            table.insert(rankInfo.rankData,data)
        end
        G_event:NotifyEvent(G_eventDef.NET_GET_RANK_SUCCESS,rankInfo)   
    elseif sub == G_NetCmd.S_SUB_GetScoreInfo then   --用户金币请求 
        local int64 = Integer64:new()
        local nLen = pData:getlen()
        GlobalUserItem.lUserScore = pData:readscore(int64):getvalue()        
        GlobalUserItem.lUserInsure = pData:readscore(int64):getvalue()
        GlobalUserItem.lTCCoin = pData:readscore(int64):getvalue()
        GlobalUserItem.lTCCoinInsure = pData:readscore(int64):getvalue()            
        if nLen >= 33 then
            GlobalUserItem.VIPLevel = pData:readbyte()
            --print("GlobalUserItem.VIPLevel = ",GlobalUserItem.VIPLevel)
        end
        G_event:NotifyEventTwo(G_eventDef.NET_USER_SCORE_REFRESH)
    elseif sub == G_NetCmd.S_SUB_GetBankRecord then   --银行转账记录
         local len = pData:getlen()
         local int64 = Integer64:new()
         local recordInfo = {}
         recordInfo.nPageIndex = pData:readdword()
         recordInfo.nPageCount = pData:readdword()
         recordInfo.nRecordCount = pData:readdword() or 0
         recordInfo.nCount = pData:readdword()
         recordInfo.recordData = {}
         local recordIn = {}
         local recordOut = {}
         for i=1,recordInfo.nCount do
             local data = {}
             data.dwRecordID = pData:readdword()
	         data.dwSourceUserID = pData:readdword()
             data.dwSourceGameID = pData:readdword()
	         data.dwTargetUserID = pData:readdword()
             data.dwTargetGameID = pData:readdword()
	         data.lSwapScore = pData:readscore(int64):getvalue()
	         data.wTradeType = pData:readword()
	         data.llCollectDate = pData:readscore(int64):getvalue()

             data.szSourceNickName = ""
             local nickNameLen = pData:readword()
             if nickNameLen >0 then
	             data.szSourceNickName = pData:readstring(nickNameLen)
             end  
             data.dwTargetNickName = ""
             nickNameLen = pData:readword()
             if nickNameLen >0 then
	             data.dwTargetNickName = pData:readstring(nickNameLen)
             end  
             local wLen = pData:readword()
             if wLen > 0 then
	             data.szCollectNote = pData:readstring(wLen)          
             end
             if data.dwTargetUserID == GlobalUserItem.dwUserID then  --转入
                 table.insert(recordIn,data)
             end
             if data.dwSourceUserID == GlobalUserItem.dwUserID then  --转出
                 table.insert(recordOut,data)
             end
         end
         G_event:NotifyEvent(G_eventDef.NET_BANK_TRANSFER_DATA,{recordIn = recordIn,recordOut = recordOut})
    elseif sub == G_NetCmd.SUB_GP_NEED_LOGIN then  --需要重新登录
         self:onCloseSocket()
         G_event:NotifyEvent(G_eventDef.NET_NEED_RELOGIN)        
    -- elseif sub == G_NetCmd.S_SUB_GetProductListResult then   --商城配置参数 
    --     local len = pData:getlen()
    --     local int64 = Integer64:new()
    --     local dwCount = pData:readdword()
    --     local lsItem = {}
    --     for i=1,dwCount do
    --         local data = {}
    --         data.iProductID = pData:readint()
    --         data.iProductType = pData:readint()
    --         data.fPrice = pData:readfloat()
    --         data.lBaseScore = pData:readscore(int64):getvalue()
    --         data.lRealScore = pData:readscore(int64):getvalue()
    --         data.lAttachScore = pData:readscore(int64):getvalue()
    --         table.insert( lsItem, data )
    --     end
    --     table.sort(lsItem,function(a,b)
    --         return a.lRealScore <= b.lRealScore
    --     end)
    --     G_event:NotifyEvent(G_eventDef.NET_FIRSTCONFIG_RESULT,lsItem)  --首充配置结果
    elseif sub == G_NetCmd.S_SUB_GetPayUrlConfigResult then  --支付链接
        local info = {}
        local len1 = pData:readword()
        info.szPayUrl = pData:readstring(len1)
        local len2 = pData:readword()
        info.szPayUrl2 = pData:readstring(len2)
        G_event:NotifyEvent(G_eventDef.NET_USER_PAY_URL,info)
    elseif sub == G_NetCmd.S_SUB_SERVER_UTC_TIMESTAMP then
        local len = pData:getlen()
        local int64 = Integer64:new()
        local info = {}
        info.llServerTime = pData:readscore(int64):getvalue()   --服务器格林时间
        info.dwZone = pData:readint()                         --服务器当前时区 中国东八区 = 8  巴西西三区 = 3
        G_event:NotifyEvent(G_eventDef.UI_GET_SERVER_TIME,info)
    end
end

--用户服务事件
function ServerFrameMgr:onSubUserEvent(sub,pData)
    if sub == G_NetCmd.C_SUB_USER_INSURE_INFO then  --获取到银行资料
	   local cmdtable = g_ExternalFun.read_netdata(logincmd.CMD_GP_UserInsureInfo, pData)
	   GlobalUserItem.lUserScore = cmdtable.lUserScore
	   GlobalUserItem.lUserInsure = cmdtable.lUserInsure    
 
       G_ServerMgr:C2S_RequestUserGold()
    elseif sub == G_NetCmd.S_SUB_USER_INSURE_SUCCESS then
	   local dwUserID = pData:readdword()
	   if dwUserID == GlobalUserItem.dwUserID then
		   GlobalUserItem.lUserScore= GlobalUserItem:readScore(pData)
		   GlobalUserItem.lUserInsure = GlobalUserItem:readScore(pData)
           if not self._bank_trans == true then
            --    self:onShowNetMsg(g_language:getString("operate_success")) --存取成功不要这个提示语了
           else
               self:onShowNetMsg(g_language:getString("transfer_success"))
           end
           self._bank_trans = false
           G_ServerMgr:C2S_RequestUserGold()
        end
    elseif sub == G_NetCmd.S_SUB_USER_INSURE_FAILURE then   --保险箱打开失败
    	local lError = pData:readint()
        print(g_language:getString(lError))
        showToast(g_language:getString(lError))
	    local szError = pData:readstring()
        -- self:onShowNetMsg(szError)
    elseif sub == G_NetCmd.S_SUB_USER_INSURE_ENABLE_RESULT then  --银行开通结果
        local info = {}
        info.bFirstEnable = not (GlobalUserItem.cbInsureEnabled == 1)
        GlobalUserItem.cbInsureEnabled = pData:readbyte()
        local szTipString = pData:readstring()
        info.tips = szTipString
        
        G_event:NotifyEvent(G_eventDef.NET_OPEN_BANK_RESULT,info)
    elseif sub == G_NetCmd.S_SUB_QUERY_USER_INFO_RESULT then   --请求用户信息
        local info =  g_ExternalFun.read_netdata(logincmd.CMD_GP_UserTransferUserInfo, pData)
        G_event:NotifyEvent(G_eventDef.NET_USER_INFO_RESULT,info)
    elseif sub == G_NetCmd.S_SUB_OPERATE_SUCCESS then  --操作成功
        local info = {}
        info.subId = pData:readword()
        info.lResultCode = pData:readint()--前后端定义返回类型
        info.szTips = pData:readstring(128)
        if info.lResultCode == 0 then
            G_ServerMgr:C2S_RequestUserGold()
        end
        G_event:NotifyEvent(G_eventDef.NET_OPERATE_SUCCESS,info)
    elseif sub == G_NetCmd.S_SUB_OPERATE_FAILURE then
       	local lResultCode = pData:readint()
	    local szDescribe = pData:readstring()

        self:onShowNetMsg(szDescribe)
    elseif sub == G_NetCmd.S_SUB_USER_FACE_INFO then 
    	local wFaceId = pData:readword()
	    local dwCustomId = pData:readdword()
	    GlobalUserItem.wFaceID = wFaceId
        if GlobalUserItem.wFaceID >10 then GlobalUserItem.wFaceID = 10 end          
	    GlobalUserItem.dwCustomID = dwCustomId
        self:onShowNetMsg(g_language:getString("modify_face_success"))

        G_event:NotifyEvent(G_eventDef.NET_MODIFY_FACE_SUCCESS)       
    elseif sub == G_NetCmd.S_SUB_GP_QUERY_TRANSFER_USERS_RESULT then
        local userList = {}
        userList.dwErrorCode = pData:readdword()
        userList.dwPageSize = pData:readdword()
        userList.dwPageIndex = pData:readdword()
        userList.dwRecordCount = pData:readdword()
        userList.dwPageCount = pData:readdword()
        userList.lsItems = {}
        local cbCount = pData:readdword()
        for i=1,cbCount do
            local userData = {}
            userData.dwUserID = pData:readdword()
            userData.dwGameID = pData:readdword()
            userData.szNickName = pData:readstring(32)
            userData.dwFaceID = pData:readdword()
            table.insert(userList.lsItems,userData)
        end
        G_event:NotifyEvent(G_eventDef.NET_TRANSFER_MERCHANT_LIST,{info=userList})
    elseif sub == G_NetCmd.S_SUB_QUERY_ORDERS_RESULT then
        local int64 = Integer64:new()
        local ordersInfo = {}
        local len = pData:getlen()
        ordersInfo.dwPageSize = pData:readdword()
        ordersInfo.dwPageIndex = pData:readdword()
        ordersInfo.dwRecordCount = pData:readdword()
        ordersInfo.dwPageCount = pData:readdword()
        ordersInfo.lsItems = {}
        local cbCount = pData:readdword()
        for i=1,cbCount do
            local data = {}
            data.tmCollectDate = pData:readscore(int64):getvalue()
            data.llSwapScore =  pData:readscore(int64):getvalue()
            table.insert(ordersInfo.lsItems,data)
        end
        G_event:NotifyEvent(G_eventDef.NET_PAY_ORDER_LIST,{info=ordersInfo})
    elseif sub == G_NetCmd.S_SUB_GP_QUERY_TRANSFER_RECORDS_RESULT then
        local recordInfo = {}
        local len = pData:getlen()
        local int64 = Integer64:new()
        recordInfo.dwTransferType = pData:readdword()
        recordInfo.dwPageSize = pData:readdword()
        recordInfo.dwPageIndex = pData:readdword()
        recordInfo.dwRecordCount = pData:readdword()
        recordInfo.dwPageCount = pData:readdword()
        recordInfo.lsItems = {}
        local cbCount = pData:readdword()
        for i=1,cbCount do
            local data  = {}
            data.tmCollectDate = pData:readscore(int64):getvalue()
            data.llSwapScore = pData:readscore(int64):getvalue()
            --谁转的
            data.dwSrcUserID = pData:readdword()            --源
            data.dwSrcGameID = pData:readdword()
            data.szSrcNickName = pData:readstring(32)
            data.dwSrcFaceID = pData:readdword()
            --转给谁
            data.dwDstUserID = pData:readdword()           --目标
            data.dwDstGameID = pData:readdword()
            data.szDstNickName = pData:readstring(32)
            data.dwDstFaceID = pData:readdword()
            table.insert(recordInfo.lsItems,data)
        end
        G_event:NotifyEvent(G_eventDef.NET_BANK_TRANSFER_DATA,{info=recordInfo})
    elseif sub == G_NetCmd.S_SUB_CHECKIN_INFO then 	  --查询签到  
        GlobalUserItem.wSeriesDate = pData:readword()
        local continuousSevenSign = {}
        continuousSevenSign.lSerialCheckInReward = {}
        GlobalUserItem.continuousSevenSign = continuousSevenSign
        continuousSevenSign.wSeriesDays = pData:readword()       --连续签到天数
	    GlobalUserItem.bTodayChecked = pData:readbool()         --今天是否签到了
        GlobalData.DailySign = pData:readbyte()==1              --是否允许签到
        continuousSevenSign.cbSeriesAllow = {}
        for k = 1,4 do
            continuousSevenSign.cbSeriesAllow[k] = pData:readbyte()==1       -- 是否有可领取连续签到的奖励	！！！
        end
	    GlobalUserItem.bQueryCheckInData = true  
	    for i=1,7 do
	    	GlobalUserItem.lRewardGold[i] = GlobalUserItem:readScore(pData)
	    end
        local int64 = Integer64:new()
        for i=1,4 do
            local lSerialCheckInReward = {
                wDays = pData:readword(),
                llScore =  pData:readscore(int64):getvalue()
            }
            table.insert(continuousSevenSign.lSerialCheckInReward,lSerialCheckInReward);
        end

	    if GlobalUserItem.bTodayChecked == true then
	    	--非会员标记当日已签到
	    	if GlobalUserItem.cbMemberOrder == 0 then
	    		GlobalUserItem.setTodayCheckIn()
	    	end
	    end
        dismissNetLoading()
        G_event:NotifyEvent(G_eventDef.NET_QUERY_CHECKIN)
        G_event:NotifyEvent(G_eventDef.REFRESH_SEVENDAILY)
    elseif sub == G_NetCmd.S_SUB_CHECKIN_RESULT then 				--签到结果
	    GlobalUserItem.bSuccessed = pData:readbool()
        GlobalUserItem.bTodayChecked = GlobalUserItem.bSuccessed
	    local lscore = GlobalUserItem:readScore(pData)	
        GlobalUserItem.lUserScore = lscore
	    local szTip = pData:readstring()
	    GlobalUserItem.bQueryCheckInData = true
	    if GlobalUserItem.bSuccessed == true then
	    	GlobalUserItem.lUserScore = lscore
	    	GlobalUserItem.wSeriesDate = GlobalUserItem.wSeriesDate+1
	    	--非会员标记当日已签到
	    	if GlobalUserItem.cbMemberOrder == 0 then
	    		GlobalUserItem.setTodayCheckIn()
	    	end
	    end
        G_ServerMgr:C2S_RequestUserGold()
        dismissNetLoading()
        G_event:NotifyEvent(G_eventDef.NET_CHECKIN_RESULT)
    elseif sub == G_NetCmd.S_SUB_BASEENSURE_PARAMETER then 			--低保参数
	     local tab = {}
	     tab.lScoreCondition = GlobalUserItem:readScore(pData)     --领取条件
	     tab.lScoreAmount = GlobalUserItem:readScore(pData)        --领取金额
	     tab.byRestTimes = pData:readbyte()                        --次数
         G_event:NotifyEvent(G_eventDef.NET_QUERY_BASEENSURE,tab)
    elseif sub == G_NetCmd.S_SUB_BASEENSURE_RESULT then 				--领取低保结果
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_GP_BaseEnsureResult,pData)
        G_event:NotifyEvent(G_eventDef.EVENT_ON_BASEENSURE_CALLBACK,cmdtable)
    elseif sub == G_NetCmd.S_SUB_QUERY_ORDERS_BY_ORDER_NO_RESULT then
        local info = {}
        info.len = pData:getlen()
        if info.len > 0 then
            --有回复数据，才是充值到账了 
            local int64 = Integer64:new()
            info.Status = pData:readword()
            info.OrderNo = pData:readstring(ylAll.LEN_MD5)
        end  
        G_event:NotifyEvent(G_eventDef.NET_QUERY_ORDER_NO_RESULT,{info=info})
    elseif sub == G_NetCmd.SUB_GP_QUERY_FACE_URL_RESULT then
        local info = {}
        info.len = pData:getlen()
        if info.len > 0 then 
            info.dwErrorCode = pData:readdword()
            info.dwCount = pData:readdword()
            info.userData  ={}
            for i=1,info.dwCount do
                local gameId = pData:readdword()
                local len = pData:readword()
                info.userData[gameId] = pData:readutf8(len)
            end
        end
        -- dump(info)
        G_event:NotifyEventTwo(G_eventDef.EVENT_FACE_URL_RESULT,info)
    elseif sub == G_NetCmd.SUB_GP_UPDATE_FACE_URL_RESULT then
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_GP_UpdateFaceUrlResult,pData)
        -- dump(cmdtable)
        -- G_event:NotifyEvent(G_eventDef.EVENT_CLUBAUDITSET,cmdtable)
    elseif sub == G_NetCmd.SUB_GP_TASK_LIST_EX_RESULT then
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_GP_TaskListExResult,pData)
        -- dump(cmdtable)
        dismissNetLoading()
        G_event:NotifyEvent(G_eventDef.EVENT_TASK_LIST_RESULT,cmdtable)
    elseif sub == G_NetCmd.SUB_GP_TASK_REWARD_EX_RESULT then
        -- 提交任务返回
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_GP_TaskListExResult,pData)
        -- dump(cmdtable,"CMD_GP_TaskListExResult")
        G_event:NotifyEvent(G_eventDef.EVENT_TASK_REWARD_RESULT,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_GetTaskActivenessConfigResult then
        -- local len = pData:getlen() 
        -- print("SUB_MB_GetTaskActivenessConfigResult  len=",len)
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetTaskActivenessConfigResult,pData)
        -- dump(cmdtable,"CMD_MB_GetTaskActivenessConfigResult")
        G_event:NotifyEvent(G_eventDef.EVENT_TASK_ACTIVENESS_CONFIG,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_GetUserTaskActivenessStatusResult then
        local len = pData:getlen() 
        -- print("SUB_MB_GetUserTaskActivenessStatusResult  len=",len)
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetUserTaskActivenessStatusResult,pData)
        -- dump(cmdtable,"CMD_MB_GetUserTaskActivenessStatusResult")
        G_event:NotifyEvent(G_eventDef.EVENT_TASK_ITEM_DATA_RESULT,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_ActivenessRewardResult then
        -- local len = pData:getlen() 
        -- print("SUB_MB_ActivenessRewardResult  len=",len)
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_ActivenessRewardResult,pData)
        -- dump(cmdtable,"CMD_MB_ActivenessRewardResult")
        G_event:NotifyEvent(G_eventDef.EVENT_TASK_A_REWARD_RESULT,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_GetRedDotStatusResult then
        --红点数据13
        -- local len = pData:getlen() 
        -- print("SUB_MB_GetRedDotStatus  len=",len)
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_DB_GetRedDotStatusResult,pData)
        -- dump(cmdtable,"CMD_DB_GetRedDotStatusResult")
        G_event:NotifyEvent(G_eventDef.EVENT_REDPOINTDATA_RESULT,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_GetOnlineUserInfoResult then
        --在线人数  
        -- local len = pData:getlen() 
        -- print("SUB_MB_GetOnlineUserInfoResult  len=",len)
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetOnlineUserInfoResult,pData)
        -- dump(cmdtable,"CMD_MB_GetOnlineUserInfoResult")
        G_event:NotifyEvent(G_eventDef.EVENT_ONLINE_USER_INFO,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_GetScrollMessageInfoResult then
        --跑马灯
        local len = pData:getlen() 
        if len == 0 then
            return
        end  
        -- print("SUB_MB_GetScrollMessageInfoResult  len=",len)
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetScrollMessageResult,pData)
        -- dump(cmdtable,"CMD_MB_GetScrollMessageResult")
        G_event:NotifyEvent(G_eventDef.EVENT_MARQUEE_DATA,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_GetShareConfigResult then
        --分享配置
        -- local len = pData:getlen()
        -- print("SUB_MB_GetShareConfigResult len =",len)
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetShareConfigResult,pData)
        -- dump(cmdtable,"CMD_MB_GetShareConfigResult")
        G_event:NotifyEvent(G_eventDef.EVENT_SHARE_CONFIG,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_UpdateShareCountResult then
        --更新分享入口点击次数返回
        -- local len = pData:getlen()
        -- print("SUB_MB_UpdateShareCountResult len =",len)
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_UpdateShareCountResult,pData)
        -- dump(cmdtable,"CMD_MB_UpdateShareCountResult")
        G_event:NotifyEvent(G_eventDef.EVENT_SHARE_CLICK_COUNT,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_GetShareRewardResult then
        --领取分享奖励返回
        -- local len = pData:getlen()
        -- print("SUB_MB_GetShareRewardResult len =",len)
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetShareRewardResult,pData)
        -- dump(cmdtable,"CMD_MB_GetShareRewardResult")
        G_event:NotifyEvent(G_eventDef.EVENT_SHARE_REWARD,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_GetShareRestLimitsResult then
        --分享剩余次数
        -- local len = pData:getlen()
        -- print("SUB_MB_GetShareRestLimitsResult len =",len)
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetShareRestLimitsResult,pData)
        -- dump(cmdtable,"CMD_MB_GetShareRestLimitsResult")
        G_event:NotifyEvent(G_eventDef.EVENT_SHARE_RESTLIMITS,cmdtable)

    -- elseif sub == G_NetCmd.SUB_MB_LIST_RECOMMEND_RESULT then   --推荐游戏列表
    --     self:S2C_RecommendList(pData)    
    elseif sub == G_NetCmd.SUB_MB_GetProductInfosResult then                --返回：获取商品列表
        self:S2C_GetProductInfosResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetProductTypeActiveStateResult then      --返回：获取商品类型可否购买状态
        self:S2C_GetProductTypeActiveStateResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetProductActiveStateResult then          --返回：一次性礼包每个商品状态
        self:S2C_GetProductActiveStateResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetPayUrlResult then                      --返回支付URL，可拼凑参数后提交
        self:S2C_GetPayUrlResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetWithdrawStatusResult then                      --返回：获取提现信息
        self:S2C_GetWithdrawStatusResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GiftCodeActiveResult then                      --返回：激活码邀请卡
        self:S2C_GiftCodeActiveResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetGiftCodeStatusResult then                      --返回：获取激活码限时礼包商品列表
        self:S2C_GetGiftCodeStatusResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetJackPotStatusResult then                      --返回：获取slots游戏彩金池状态
        self:S2C_GetJackPotStatusResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetWithdrawConfigResult then                      --返回：获取提现额度列表
        self:S2C_GetWithdrawConfigResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetWithdrawHistoryAccountResult then                      --返回：获取用户提现过的历史账号
        self:S2C_GetWithdrawHistoryAccountResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetWithdrawRecordResult then                      --返回：获取提现记录
        self:S2C_GetWithdrawRecordResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetCustomServiceResult then               --返回客服配置
        self:S2C_GetCustomServiceResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetSystemNoticeResult then                --获取系统提示信息返回
        self:S2C_GetSystemNoticeResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetSMSUrlResult then
        -- 获取短信发送URL
        self:S2C_GetSMSUrlResult(pData)
    elseif sub == G_NetCmd.SUB_MB_BindMobileResult then
        -- 绑定手机结果
        self:S2C_GetBindMsgResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetBindMobileStatusResult then
        -- 获取手机绑定状态返回 
        self:S2C_GetBindMobileStatusResult(pData)
    elseif sub == G_NetCmd.SUB_MB_GetBindMobileRewardResult then
        -- 领取手机绑定奖励返回
        self:S2C_GetBindMobileRewardResult(pData)        
    elseif sub == G_NetCmd.SUB_MB_GetActivityConfigResult then
        -- 获取活动配置数据返回
        self:S2C_GetActivityConfigResult(pData)   
    elseif sub ==G_NetCmd.SUB_MB_GetBetScoreResult then
        --获取用户当日流水值，总流水值返回 1321
        self:S2C_GetBetScoreResult(pData)
    elseif sub ==G_NetCmd.SUB_MB_GetLastPayInfoResult then
        --查询最后一次充值订单信息返回 1323
        self:S2C_GetLastPayInfoResult(pData)
    elseif sub ==G_NetCmd.SUB_MB_GetVIPInfoResult then
        --查询VIP信息返回 1503
        self:S2C_GetVIPInfoResult(pData)
    elseif sub ==G_NetCmd.SUB_MB_GetLotteryCellResult then
        --获取转盘配置返回
        TurnTableManager.setTurnConfigData(pData) 
    elseif sub ==G_NetCmd.SUB_MB_GetLotteryUserStatusResult then         
        --获取转盘用户配置返回  
        local layer = cc.Director:getInstance():getRunningScene():getChildByName("TurnTableLayer")
        if not layer then
            G_event:NotifyEvent(G_eventDef.UI_SHOW_TURNTABLE) --打开转盘
        end
        dismissNetLoading()
        G_event:NotifyEvent(G_eventDef.EVENT_TURNTABLE_USERDATA,pData)
    elseif sub ==G_NetCmd.CMD_MB_GetEggBreakResult then      
        --砸金蛋  返回   
        dismissNetLoading()
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetEggBreakResult,pData)
        G_event:NotifyEvent(G_eventDef.EVENT_EGG_BREAK,cmdtable)
    elseif sub ==G_NetCmd.SUB_MB_GetLotteryPlatformRecordResult then
        --获取平台中奖最新广播消息列表 返回
        G_event:NotifyEvent(G_eventDef.EVENT_TURNTABLE_NEWDATALIST,pData)
    elseif sub == G_NetCmd.SUB_MB_GetLotteryPlatformRecordHistoryResult then
        --获取平台中奖老的记录 返回
        G_event:NotifyEvent(G_eventDef.EVENT_TURNTABLE_OLDDATALIST,pData)
    elseif sub == G_NetCmd.SUB_MB_GetLotteryUserRecordHistoryResult then
        --获取用户自己中奖历史消息列表 返回 1519
        G_event:NotifyEvent(G_eventDef.EVENT_TURNTABLE_USERHISTORYDATA,pData)
    elseif sub == G_NetCmd.SUB_MB_LotterySbinResult then
        --旋转返回 1521
        G_event:NotifyEvent(G_eventDef.EVENT_TURNTABLE_REVOLVERESULT,pData)
    elseif sub == G_NetCmd.CMD_MB_GetLotteryHelpPresentResult then
        --获得转盘配置返回
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetLotteryPresentConfigResult,pData)
        G_event:NotifyEvent(G_eventDef.UI_SHOW_TURNHELP,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_GetLuckyCardUserStatusResult then
        --塔罗牌数据返回
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_UserLuckyCardStatusRes,pData)
        -- dump(cmdtable)
        G_event:NotifyEventTwo(G_eventDef.EVENT_TAROT_REQUEST,cmdtable)
    elseif sub == G_NetCmd.SUB_MB_UserLuckyCardDrawResult then
        --塔罗牌开某张牌数据返回
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_UserLuckyCardDrawRes,pData)
        dump(cmdtable)
        G_event:NotifyEvent(G_eventDef.EVENT_TAROT_OPEN_CARD,cmdtable)
    elseif sub == G_NetCmd.CMD_MB_GetPayRebateInfoResult then
        -- 获取充值返利信息 返回 1581
        local cmdtable = {}
        local int64 = Integer64:new()
        cmdtable.wCount = pData:readword()
        cmdtable.llRebateScores = {}
        for k = 1,cmdtable.wCount do
            cmdtable.llRebateScores[#cmdtable.llRebateScores + 1] = pData:readscore(int64):getvalue()
        end
        dump(cmdtable)
        G_event:NotifyEvent(G_eventDef.RECHARGEBENEFIT_INFO,cmdtable)
    elseif sub == G_NetCmd.CMD_MB_GetPayRebateRewardResult then
        --领取充值返利奖励 返回 1583
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetPayRebateRewardResult,pData)
        dump(cmdtable)
        G_event:NotifyEvent(G_eventDef.RECHARGEBENEFIT,cmdtable)
    elseif sub == G_NetCmd.SHARE_TURNTABLE then   --获取转盘分享物品列表 发送：1700
        
    elseif sub == G_NetCmd.SHARE_TURNTABLE_PLAYSTATUS_RESULT then       
        --分享转盘玩家状态
        dismissNetLoading()
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_ShareLotteryGetUserStatusResult,pData)
        G_event:NotifyEvent(G_eventDef.UI_SHARETURNTABLE,cmdtable) 
    elseif sub == G_NetCmd.SHARE_TURNTABLE_PLAYSTATUSRecords_RESULT then        
        --玩家邀请记录返回
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_ShareLotteryGetInviteRecordsResult,pData)
        G_event:NotifyEvent(G_eventDef.SHARE_TURN_RECORD,cmdtable) 
    elseif sub == G_NetCmd.CMD_MB_ShareLotteryTakeRewardResult then
        --玩家领取奖励返回
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_ShareLotteryTakeRewardResult,pData)
        G_event:NotifyEvent(G_eventDef.SHARE_TURN_RECEIVEGIFT,cmdtable) 
    elseif sub == G_NetCmd.CMD_MB_ShareLotteryExecuteSbinResult then
        --玩家点击旋转返回
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_ShareLotteryExecuteSbinResult,pData)
        G_event:NotifyEvent(G_eventDef.SHARE_TURN_RESLOVE,cmdtable) 
    elseif sub == G_NetCmd.SHARE_TURNTABLE_HISTORY_RESULT then
        --幸运玩家历史记录
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_ShareLotteryGetWithdrawHistoryResult,pData)
        G_event:NotifyEvent(G_eventDef.SHARE_TURN_LUCKHISTORY,cmdtable) 
    elseif sub == G_NetCmd.SUB_GP_CHECKIN_GET_SERIAL_REWARD_RESULT then 
        --七天连续签到领奖返回
        local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_ShareLotteryTakeRewardResult,pData)
        G_event:NotifyEvent(G_eventDef.SIGN_CONTINUE_RESULT,cmdtable) 
    end
end

function ServerFrameMgr:onRoomListEvent(sub,pData)
    if sub == G_NetCmd.S_SUB_SERVER_LIST_SUCCESS then   --房间列表数据
        self:onSubUpdateRoomListInfo(pData)	
    end
    if sub == G_NetCmd.S_SUB_SERVER_LIST_FINISH then   --房间列表接收完成 
        dismissNetLoading()
    end
end

--更新房间列表
function ServerFrameMgr:onSubUpdateRoomListInfo(pData)
 	local len = pData:getlen() 
    if len <= 0 then return end
	--读取房间信息
    local tempRecRoomInfo = {}
    local int64 = Integer64:new()
    local itemcount = pData:readword() -- floor(len/39)
 --[[
	//名称索引
	uint16_t wKindID;
	//排序索引
	uint16_t wSortID;
	//房间类型
	uint16_t wServerKind;
	//房间类型
	uint16_t wServerType;
	//单元积分
	int64_t lCellScore;
	//进入积分
	int64_t lEnterScore;
	//在线人数
	uint32_t uOnLineCount;
	//满员人数
	uint32_t uFullCount;
	//桌子数目
	uint16_t wTableCount;
	//是否在线
	bool bOnline;
]]--
	for i = 1,itemcount do
        local item = {}
        item.wKindID = pData:readword()
        item.wSortID = pData:readword()
        item.wServerKind = pData:readword()                --1:金币场 4:TC币 元宝场
        item.wServerType = pData:readword()
        item.lCellScore = pData:readscore(int64):getvalue()
        item.lEnterScore = pData:readscore(int64):getvalue()
        item.dwOnLineCount = pData:readdword()
        -- item.dwAndroidCount = pData:readdword() 删除机器人数量 
        item.dwFullCount = pData:readdword()
        item.wTableCount = pData:readword()
        item.bOnline = pData:readbool()
		if not tempRecRoomInfo[item.wKindID] then
			tempRecRoomInfo[item.wKindID] = {}
		end
        table.insert(tempRecRoomInfo[item.wKindID], item)
        
        item.roomMark = g_ExternalFun.getRoomMark(item.wKindID,item.wServerKind,item.wSortID)
        GlobalUserItem.RoomList_p[item.roomMark] = item
    end

    --维护本地列表，支持单个刷新
    for k, v in pairs(tempRecRoomInfo) do
        if GlobalUserItem.roomlist[k] then

            for k2, v2 in pairs(v) do                
                local pFlag = false
                for k3, v3 in pairs(GlobalUserItem.roomlist[k]) do
                    if v3.roomMark == v2.roomMark then
                        GlobalUserItem.roomlist[k][k3].bOnline = v2.bOnline
                        pFlag = true
                        break
                    end
                end
                if not pFlag then
                    table.insert(GlobalUserItem.roomlist[k],v2)
                    -- [k2] = v2
                end
                
            end
        else
            GlobalUserItem.roomlist[k] = v
        end
    end
    
    for k,v in pairs(GlobalUserItem.roomlist) do
        _sort(v, function(a, b)
			return a.wSortID < b.wSortID
		end) 
    end
    GlobalData.ReceiveRoomSuccess = true
end

--邮件相关事件
function ServerFrameMgr:onSubMailEvent(sub,pData)
    if sub == G_NetCmd.SUB_GP_MAIL_LIST_RESULT then                      --邮件列表返回
        self:S2C_GetMailListResult(pData)
    elseif sub == G_NetCmd.SUB_GP_MAILDETAILS_RESULT then                      --邮件详情返回
        self:S2C_GetMailDetailsResult(pData)
    elseif sub == G_NetCmd.SUB_GP_MAIL_DELETE_RESULT then                      --邮件删除返回
        self:S2C_GetMailDeleteResult(pData)
    elseif sub == G_NetCmd.SUB_GP_GETMAILREWARD_RESULT then                      --邮件领取返回
        self:S2C_GetMailRewardResult(pData)  
    elseif sub == G_NetCmd.SUB_GP_GETMAILCOUNT_RESULT then                      --邮件数量红点返回
        self:S2C_GetMailCountResult(pData)  
    end
end

-----------------------发送事件-------------------------
--获取机器码
function ServerFrameMgr:getMachineID()
    local Localization = cc.UserDefault:getInstance()
	self._szMachine = g_MultiPlatform:getInstance():getMachineId()    
    self._szMachine = Localization:getStringForKey("MachineLocal",self._szMachine)
end

--获取渠道号
function ServerFrameMgr:getChannelID()
    if GlobalData.ChannelName == "" then
        GlobalData.ChannelName = g_MultiPlatform:getInstance():getChannelId() or ""
    end
    if GlobalData.ChannelName == "" then
        GlobalData.ChannelName = g_MultiPlatform:getInstance():getAdjustStatus() or ""
    end
    return GlobalData.ChannelName.." "    
end

--账号登陆
function ServerFrameMgr:C2S_LogonByAccount(szAccount,szPassword)
	local LogonData = CCmd_Data:create(249)
	LogonData:setcmdinfo(G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_LOGON_ACCOUNTS)
	LogonData:pushword(G_NetCmd.INVALID_WORD)
	LogonData:pushdword(self._plazaVersion)
	LogonData:pushbyte(self._deviceType)
    local strPsd = string.upper(md5(szPassword))
	LogonData:pushstring(strPsd,G_NetLength.LEN_MD5)
	LogonData:pushstring(szAccount,G_NetLength.LEN_ACCOUNTS)
	LogonData:pushstring(self._szMachine,G_NetLength.LEN_MACHINE_ID)
	LogonData:pushstring(self._szMobilePhone,G_NetLength.LEN_MOBILE_PHONE)

    for i=1,14 do
        LogonData:pushbyte(ylAll.ipAddr[i])
    end
    self:AddNetEvent(LogonData)
	return true
end
--游客登录
function ServerFrameMgr:C2S_LogonByVisitor()
    --机器码
    self:getMachineID()

    --渠道号
    local channel = self:getChannelID()
    local channelLength = #channel+1

    printInfo("游客登录",G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_LOGON_VISITOR)
	local VisitorData = CCmd_Data:create(111+channelLength)
	VisitorData:setcmdinfo(G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_LOGON_VISITOR)
	VisitorData:pushword(G_NetCmd.INVALID_WORD)
	VisitorData:pushdword(self._plazaVersion)
	VisitorData:pushbyte(self._deviceType)
    
    if device.platform == "windows" then
        local pMachine = cc.UserDefault:getInstance():getStringForKey("MachineLocal","")
        if pMachine ~="" then
            self._szMachine = pMachine 
        end
       -- self._szMachine = "大爸爸" --会长
        --self._szMachine = "AAAAAAAAAAAAAAAAAAAAAAAAAAAABZ00" --  83434928  2681137  工会ID:376213
        -- self._szMachine = "AAAAAAAAAAAAAAAAAAAAAAAAAAAABZ01" --  
        -- self._szMachine = "EE6C77B61C4DCB03541DC4AABBBBCC28"
        -- local time = md5(os.time())
        -- self._szMachine = time
    end
    self._szMachine = self._szMachine or GlobalUserItem.szMachine
	VisitorData:pushstring(self._szMachine,G_NetLength.LEN_MACHINE_ID)
	VisitorData:pushstring(self._szMobilePhone,G_NetLength.LEN_MOBILE_PHONE)
    for i=1,14 do
        VisitorData:pushbyte(ylAll.ipAddr[i])
    end
    VisitorData:pushutf8(channel)
    self:AddNetEvent(VisitorData)
	return true
end
--第三方平台登录
function ServerFrameMgr:C2S_LogonByThirdParty(loginType,szAccount,cbgender,szNick,token,email,headurl)
    --机器码
    self:getMachineID()

    --渠道号
    local channel = self:getChannelID()
    local channelLength = #channel+1

    cbgender = cbgender or math.random(1)
    local tokenLength = #token+1
    local emailLength = #email+1
    local headurlLength = #headurl+1    
    local cmddata = CCmd_Data:create(294 + tokenLength*2 + emailLength*2 + headurlLength*2 + channelLength)
	cmddata:setcmdinfo(G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_LOGON_OTHERPLATFORM)

	cmddata:pushword(G_NetCmd.INVALID_WORD)  
	cmddata:pushdword(self._plazaVersion) 
	cmddata:pushbyte(self._deviceType) 
	cmddata:pushbyte(cbgender)
	cmddata:pushbyte(loginType) 
	cmddata:pushstring(szAccount,G_NetLength.LEN_USER_UIN) 
	cmddata:pushstring(szNick,G_NetLength.LEN_NICKNAME) 
	cmddata:pushstring(szNick,G_NetLength.LEN_COMPELLATION)	
	cmddata:pushstring(self._szMachine,G_NetLength.LEN_MACHINE_ID) 
	cmddata:pushstring(self._szMobilePhone,G_NetLength.LEN_MOBILE_PHONE)  
    for i=1,33 do
        cmddata:pushbyte((i <= 14) and ylAll.ipAddr[i] or "")
    end    
    cmddata:pushstring(token)
    cmddata:pushstring(email) 
    cmddata:pushstring(headurl) 
    cmddata:pushutf8(channel)
    self:AddNetEvent(cmddata)
	return true
end

--手机登录
function ServerFrameMgr:C2S_LogonByPhone(args)
    --机器码
    self:getMachineID()

    --渠道号
    local channel = self:getChannelID()    
    local channelLength = #channel+1

    printInfo("手机登录",G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_LOGON_MOBILE)
	local PhoneData = CCmd_Data:create(133+channelLength)
	PhoneData:setcmdinfo(G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_LOGON_MOBILE)
	PhoneData:pushword(G_NetCmd.INVALID_WORD)
	PhoneData:pushdword(self._plazaVersion)
	PhoneData:pushbyte(self._deviceType)
	PhoneData:pushstring(self._szMachine,G_NetLength.LEN_MACHINE_ID)
	PhoneData:pushstring(args.PhoneString,16)
    PhoneData:pushstring(args.CodeString,7)
    for i=1,14 do
        PhoneData:pushbyte(ylAll.ipAddr[i])
    end
    PhoneData:pushutf8(channel)
    self:AddNetEvent(PhoneData)
	return true
end

--请求金币
function ServerFrameMgr:C2S_RequestUserGold()
    local goldData = CCmd_Data:create(4)
    goldData:setcmdinfo(G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_GetScoreInfo)
    goldData:pushdword(GlobalUserItem.dwUserID)
    self:AddNetEvent(goldData)
	return true
end

--开通银行
function ServerFrameMgr:C2S_EnableBank(bankPassward)
	local EnableBank = CCmd_Data:create(202)
	local machine  = GlobalUserItem.szMachine
	EnableBank:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_USER_ENABLE_INSURE)
	EnableBank:pushdword(GlobalUserItem.dwUserID)
	EnableBank:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)   --临时密码，
	EnableBank:pushstring(md5(bankPassward),G_NetLength.LEN_PASSWORD)   --银行密码
	EnableBank:pushstring(machine,G_NetLength.LEN_MACHINE_ID)

    self:AddNetEvent(EnableBank)
	return true
end

--存入
function ServerFrameMgr:C2S_SaveScore(lScore)
	local SaveData = CCmd_Data:create(144)
	SaveData:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_USER_SAVE_SCORE)
	SaveData:pushdword(GlobalUserItem.dwUserID)
    SaveData:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
	SaveData:pushscore(lScore)

	SaveData:pushstring(GlobalUserItem.szMachine,G_NetLength.LEN_MACHINE_ID)

    self:AddNetEvent(SaveData)
	return true
end
---取出
function ServerFrameMgr:C2S_TakeScore(lScore)
	local TakeData = CCmd_Data:create(144)
	TakeData:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_USER_TAKE_SCORE)
	TakeData:pushdword(GlobalUserItem.dwUserID)
	TakeData:pushscore(lScore)
	TakeData:pushstring(md5(GlobalData.BankPassword),G_NetLength.LEN_PASSWORD)

	TakeData:pushstring(GlobalUserItem.szMachine,G_NetLength.LEN_MACHINE_ID)

    self:AddNetEvent(TakeData)
	return true
end 
--赠送
function ServerFrameMgr:C2S_TransferScore(lScore,target)
	local TransferScore = CCmd_Data:create(272)
	TransferScore:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_USER_TRANSFER_SCORE)
	TransferScore:pushdword(GlobalUserItem.dwUserID)
	TransferScore:pushscore(lScore)
	TransferScore:pushstring(md5(GlobalData.BankPassword),G_NetLength.LEN_PASSWORD)
	TransferScore:pushstring(target,G_NetLength.LEN_ACCOUNTS)
	TransferScore:pushstring(GlobalUserItem.szMachine,G_NetLength.LEN_MACHINE_ID)
	TransferScore:pushstring("",G_NetLength.LEN_ACCOUNTS)
    self._bank_trans = true
    self:AddNetEvent(TransferScore)
	return true
end
--查询银行数据
function ServerFrameMgr:C2S_GetBankInfo()
	local cmd = CCmd_Data:create(70)
	cmd:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_QUERY_INSURE_INFO)
	cmd:pushdword(GlobalUserItem.dwUserID)
	cmd:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    self._bank_trans = false
    self:AddNetEvent(cmd)
	return true
end
--发送查询用户信息
function ServerFrameMgr:C2S_RequestUserInfo(GameID)
	local cmd = CCmd_Data:create(69)
	cmd:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_USER_INFO_REQUEST)
    cmd:pushdword(GlobalUserItem.dwUserID)
	cmd:pushbyte(0)
	cmd:pushstring(GameID, 32)
    self:AddNetEvent(cmd)
	return true
end

--查询会员
function ServerFrameMgr:C2S_RequesMemberInfo(GameID)
	local cmd = CCmd_Data:create(logincmd.CMD_GP_QueryMemberInfo)
	cmd:setcmdinfo(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_MEMBER_INFO)
    cmd:pushdword(GlobalUserItem.dwUserID)
	cmd:pushdword(GameID)
    cmd:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    self:AddNetEvent(cmd)
	return true
end

--转账记录
function ServerFrameMgr:C2S_RequestTransRecord(count)
    local bankData = CCmd_Data:create(152)
    bankData:setcmdinfo(G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_GetBankRecord)
    bankData:pushdword(GlobalUserItem.dwUserID)

    local strPsd = string.upper(md5(GlobalUserItem.szPassword))
    local sign = GlobalUserItem:getSignature( os.time())

    bankData:pushstring(strPsd,G_NetLength.LEN_PASSWORD)
    bankData:pushscore(time)
    bankData:pushstring(sign,G_NetLength.LEN_MD5)
    count = count or 10
    bankData:pushdword(50)
    bankData:pushdword(1)

    self:AddNetEvent(bankData)
	return true
end

--查询成功充值订单
function ServerFrameMgr:C2S_QueryOrders(dwUserID,pageSize,pageIndex,szDynamicPass)
    local buffer = g_ExternalFun.create_netdata(logincmd.CMD_GP_QueryOrders)
    buffer:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_QUERY_ORDERS)
    buffer:pushdword(dwUserID)
    buffer:pushdword(pageSize)
    buffer:pushdword(pageIndex)
    buffer:pushstring(szDynamicPass,33)
    self:AddNetEvent(buffer)
    return true
end


--用户修改相关
function ServerFrameMgr:C2S_ModifyUserInfo(szNickname,szSign)
	local ModifyUserInfo = CCmd_Data:create(817)

	ModifyUserInfo:setcmdinfo(G_NetCmd.MDM_GP_USER_SERVICE,G_NetCmd.C_SUB_MODIFY_INDIVIDUAL)
	ModifyUserInfo:pushbyte(GlobalUserItem.cbGender)
	ModifyUserInfo:pushdword(GlobalUserItem.dwUserID)
	ModifyUserInfo:pushstring(md5(GlobalUserItem.szPassword),G_NetLength.LEN_PASSWORD)
	-- 昵称
	ModifyUserInfo:pushword(64)
	ModifyUserInfo:pushword(G_NetLength.DTP_GP_UI_NICKNAME)
	ModifyUserInfo:pushstring(szNickname,G_NetLength.LEN_NICKNAME)
	-- 签名
	ModifyUserInfo:pushword(64)
	ModifyUserInfo:pushword(G_NetLength.DTP_GP_MODIFY_UNDER_WRITE)
	ModifyUserInfo:pushstring(szSign,G_NetLength.LEN_UNDER_WRITE)
	-- qq
	ModifyUserInfo:pushword(32)
	ModifyUserInfo:pushword(G_NetLength.DTP_GP_UI_QQ)
	ModifyUserInfo:pushstring(GlobalUserItem.szQQNumber,G_NetLength.LEN_QQ)
	-- email
	ModifyUserInfo:pushword(66)
	ModifyUserInfo:pushword(G_NetLength.DTP_GP_UI_EMAIL)
	ModifyUserInfo:pushstring(GlobalUserItem.szEmailAddress,G_NetLength.LEN_EMAIL)
	-- 座机
	ModifyUserInfo:pushword(66)
	ModifyUserInfo:pushword(G_NetLength.DTP_GP_UI_SEAT_PHONE)
	ModifyUserInfo:pushstring(GlobalUserItem.szSeatPhone,G_NetLength.LEN_SEAT_PHONE)

	-- 真实姓名
	ModifyUserInfo:pushword(32)
	ModifyUserInfo:pushword(G_NetLength.DTP_GP_UI_COMPELLATION)
	ModifyUserInfo:pushstring(GlobalUserItem.szTrueName,G_NetLength.LEN_COMPELLATION)
	-- 联系地址
	ModifyUserInfo:pushword(256)
	ModifyUserInfo:pushword(G_NetLength.DTP_GP_UI_DWELLING_PLACE)
	ModifyUserInfo:pushstring(GlobalUserItem.szAddress,G_NetLength.LEN_DWELLING_PLACE)
	-- 身份证
	ModifyUserInfo:pushword(38)
	ModifyUserInfo:pushword(G_NetLength.DTP_GP_UI_PASSPORTID)
	ModifyUserInfo:pushstring(GlobalUserItem.szPassportID,G_NetLength.LEN_PASS_PORT_ID)

    self:AddNetEvent(ModifyUserInfo)
	return true
end
--修改签名
function ServerFrameMgr:C2S_ModifyUserSign(sign)
  	local modifySign = CCmd_Data:create(134)
	modifySign:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_MODIFY_UNDER_WRITE)
	
	modifySign:pushdword(GlobalUserItem.dwUserID)
	modifySign:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
	modifySign:pushstring(sign,G_NetLength.LEN_UNDER_WRITE)

    self:AddNetEvent(modifySign)
	return true
end
--修改用户密码
function ServerFrameMgr:C2S_ModifyLogonPsd(psdOld,psdNew)
	local ModifyLogonPass = CCmd_Data:create(136)	
	ModifyLogonPass:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_MODIFY_LOGON_PASS)
	ModifyLogonPass:pushdword(GlobalUserItem.dwUserID)
	ModifyLogonPass:pushstring(md5(psdNew),G_NetLength.LEN_PASSWORD)
	ModifyLogonPass:pushstring(md5(psdOld),G_NetLength.LEN_PASSWORD)

    self:AddNetEvent(ModifyLogonPass)
	return true
end
--修改银行密码
function ServerFrameMgr:C2S_ModifyBankPsd(bankPsdOld,bankPsdNew)
	local ModifyInsurePass = CCmd_Data:create(136)
	ModifyInsurePass:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_MODIFY_INSURE_PASS)
	ModifyInsurePass:pushdword(GlobalUserItem.dwUserID)
	ModifyInsurePass:pushstring(md5(bankPsdNew),G_NetLength.LEN_PASSWORD)
	ModifyInsurePass:pushstring(md5(bankPsdOld),G_NetLength.LEN_PASSWORD)

    self:AddNetEvent(ModifyInsurePass)
	return true
end
--修改头像
function ServerFrameMgr:C2S_ModifyUserFace(faceId)
	local sysmodify = g_ExternalFun.create_netdata(logincmd.CMD_GP_SystemFaceInfo)
	sysmodify:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_USER_FACE_INFO)
	sysmodify:pushword(faceId)
	sysmodify:pushdword(GlobalUserItem.dwUserID)
	sysmodify:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
	sysmodify:pushstring(self._szMachine,G_NetLength.LEN_MACHINE_ID)

    self:AddNetEvent(sysmodify)
	return true
end
--请求排行榜
function ServerFrameMgr:C2S_RequestRankInfo(rankCount)
    rankCount = rankCount or 10
    local rankData = CCmd_Data:create(6)
    rankData:setcmdinfo(G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_GetScoreRank)
	rankData:pushdword(GlobalUserItem.dwUserID)
    rankData:pushword(rankCount)  
    self:AddNetEvent(rankData)
	return true
end
--查询转账记录 查询结构带头像，时间戳的
function ServerFrameMgr:C2S_RequestTransferRecordNew(dwUserID,TransferType,pageSize,pageIndex,szDynamicPass)
	local buffer = g_ExternalFun.create_netdata(logincmd.CMD_GP_QueryTransferRecords)
	buffer:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_QUERY_TRANSFER_RECORDS)
    buffer:pushdword(dwUserID)
	buffer:pushdword(TransferType)
	buffer:pushdword(pageSize)
	buffer:pushdword(pageIndex)
    buffer:pushstring(szDynamicPass,33)
    self:AddNetEvent(buffer)

	return true
end
--查询上过分的币商列表
function ServerFrameMgr:C2S_RequestTransferUsers(pageSize,pageIndex,dwUserID,szDynamicPass)
    local buffer = g_ExternalFun.create_netdata(logincmd.CMD_GP_QueryTransableUsers)
    buffer:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_QUERY_TRANSFER_USERS)
    buffer:pushdword(pageSize)
    buffer:pushdword(pageIndex)
    buffer:pushdword(dwUserID)
    buffer:pushstring(szDynamicPass,G_NetLength.LEN_PASSWORD)
    self:AddNetEvent(buffer)
    return true
end

--查询充值订单结果
function ServerFrameMgr:C2S_RequestOrderNo(dwUserID,szDynamicPass,OrderNo)
    local buffer = g_ExternalFun.create_netdata(logincmd.CMD_GP_QueryOrderByOrderNo)
    buffer:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_QUERY_ORDERS_BY_ORDER_NO)
    buffer:pushdword(dwUserID)
    buffer:pushstring(szDynamicPass,G_NetLength.LEN_PASSWORD)
    buffer:pushstring(OrderNo,33)

    self:AddNetEvent(buffer)
    return true
end
--查询签到
function ServerFrameMgr:C2S_QueryCheckIn()
	local CheckinQuery = CCmd_Data:create(70)
	CheckinQuery:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_CHECKIN_QUERY)
	CheckinQuery:pushdword(GlobalUserItem.dwUserID)
	CheckinQuery:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)

    self:AddNetEvent(CheckinQuery)
	return true
end
--执行签到
function ServerFrameMgr:C2S_CheckinDone()
	local CheckinDone = CCmd_Data:create(136)
	CheckinDone:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_CHECKIN_DONE)
	CheckinDone:pushdword(GlobalUserItem.dwUserID)
	CheckinDone:pushstring(GlobalUserItem.szDynamicPass,33)
	CheckinDone:pushstring(GlobalUserItem.szMachine,33)

    self:AddNetEvent(CheckinDone)
	return true
end
--查询低保
function ServerFrameMgr:C2S_QueryBaseEnsure()
	local databuffer = CCmd_Data:create(4)
    databuffer:pushdword(GlobalUserItem.dwUserID)
	databuffer:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_BASEENSURE_LOAD)

    self:AddNetEvent(databuffer)
	return true
end
--领取低保
function ServerFrameMgr:C2S_TakeBaseEnsure()
	local BaseEnsureTake = CCmd_Data:create(136)
	BaseEnsureTake:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_BASEENSURE_TAKE)
	BaseEnsureTake:pushdword(GlobalUserItem.dwUserID)
	BaseEnsureTake:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
	BaseEnsureTake:pushstring(GlobalUserItem.szMachine,G_NetLength.LEN_MACHINE_ID)

    self:AddNetEvent(BaseEnsureTake)
	return true
end
-- --查询首充配置
-- function ServerFrameMgr:C2S_FirstChargeConfigs()
-- 	local buffer = g_ExternalFun.create_netdata(logincmd.CMD_GP_QueryFirstChargeConfigs)
-- 	buffer:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_QUERY_FIRST_CHARGE_CONFIG)
--     self:AddNetEvent(buffer)
-- 	return true
-- end
-- --获取Pay URL
-- function ServerFrameMgr:C2S_GetPayUrlConfig()
-- 	local buffer = g_ExternalFun.create_netdata(logincmd.CMD_MB_GetPayUrlConfig)
-- 	buffer:setcmdinfo(G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_GetPayUrlConfig)

--     self:AddNetEvent(buffer)
-- 	return true
-- end
-- --获取充值配置列表  productType:1>商城配置  2> 首充配置
-- function ServerFrameMgr:C2S_GetChargeConfigs(productType)
-- 	local buffer = g_ExternalFun.create_netdata(logincmd.CMD_MB_GetProductList)
--     buffer:pushword(productType)
-- 	buffer:setcmdinfo(G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_GetProductList)

--     self:AddNetEvent(buffer)
-- 	return true
-- end
--请求服务器时间戳
function ServerFrameMgr:C2S_requestServerTime()
    local pdata = CCmd_Data:create(4)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:setcmdinfo(G_NetCmd.MAIN_MB_LOGON,G_NetCmd.C_SUB_SERVER_UTC_TIMESTAMP)
    self:AddNetEvent(pdata)
	return true
end

--查询身份
function ServerFrameMgr:C2S_requestMemberOrder()
    local pdata = CCmd_Data:create(logincmd.CMD_GP_AgentMemberOrder)
    pdata:setcmdinfo(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_MEMBER_ORDER)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    self:AddNetEvent(pdata)
	return true
end

--获取个人头像url
function ServerFrameMgr:C2S_requestHeadUrl(tGameIds)
    local pdata = CCmd_Data:create(logincmd.CMD_GP_QueryFaceUrl)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_GP_QUERY_FACE_URL)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    if type(tGameIds) == "table" then
        pdata:pushdword(#tGameIds)
        for i,v in ipairs(tGameIds) do
            pdata:pushdword(v)
        end
    else
        return false
    end
    self:AddNetEvent(pdata)
	return true
end
--上传头像地址
function ServerFrameMgr:C2S_RequestUserHeadUrl(url)
    local pdata = CCmd_Data:create(582)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_GP_UPDATE_FACE_URL)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    pdata:pushstring(url,G_NetLength.LEN_FACEURL)
    self:AddNetEvent(pdata)
	return true
end

function ServerFrameMgr:C2S_RequestTaskList()
    showNetLoading()
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        dwTaskTypeMask = 7,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_GP_TASK_LIST_EX,logincmd.CMD_GP_TaskListEx,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

function ServerFrameMgr:C2S_RequestTaskReward(taskid,myIp)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass,
        iTaskID = taskid,
        szClientIP = myIp
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_GP_TASK_REWARD_EX,logincmd.CMD_GP_TaskRewardEx,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

-- 请求获取任务活跃度全局配置表
function ServerFrameMgr:C2S_RequestTaskActivenessConfig()
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetTaskActivenessConfig,logincmd.CMD_MB_GetTaskActivenessConfig,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--查询任务积分item
function ServerFrameMgr:C2S_RequestTaskItemData()
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetUserTaskActivenessStatus,logincmd.CMD_MB_GetUserTaskActivenessStatus,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

-- 领取任务活跃度奖励
function ServerFrameMgr:C2S_RequestActivenessReward(dwConfigID,szClientIP)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass,
        dwConfigID = dwConfigID,
        szClientIP = szClientIP,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_ActivenessReward,logincmd.CMD_MB_ActivenessReward,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end
--请求红点数据
function ServerFrameMgr:C2S_RequestRedData()
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetRedDotStatus,logincmd.CMD_MB_GetRedDotStatus,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--请求在线人数
function ServerFrameMgr:C2S_RequestOnlineUserInfo(wKindID)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        wKindID = wKindID or 0
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetOnlineUserInfo,logincmd.CMD_MB_GetOnlineUserInfo,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--拉取跑马灯数据
function ServerFrameMgr:C2S_RequestScrollMessageInfo(dwQueueIndex)    
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        dwQueueIndex = dwQueueIndex or 0
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetScrollMessageInfo,logincmd.CMD_MB_GetScrollMessage,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

-- --请求：获取推荐游戏种类列表
-- function ServerFrameMgr:C2S_RequestRecommendList()
--     local pdata = CCmd_Data:create(4)
--     pdata:pushdword(GlobalUserItem.dwUserID)
--     pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_LIST_RECOMMEND)
--     self:AddNetEvent(pdata)
-- 	return true
-- end

-- --返回推荐游戏列表
-- function ServerFrameMgr:S2C_RecommendList(pData)
--     local len = pData:getlen() 
--     if len <= 0 then return end
--     GlobalUserItem.RecommendList = {}
--     local pList = {}
--     local dwErrorCode = pData:readdword() --标准结构错误码，可不用处理
--     local pCount = pData:readword() --数量
--     for i = 1, pCount do
--         local pItem = {}
--         pItem.wSort = pData:readword()
--         pItem.wKindID = pData:readword()
--         table.insert(pList,pItem)
--     end
--     table.sort(pList,function(a,b)
--         return a.wSort<b.wSort
--     end)
--     GlobalUserItem.RecommendList = pList
-- end

-- --请求：更新推荐图标被点击次数，每次点击次数+1
-- function ServerFrameMgr:C2S_UploadRecommendClick(pKindID)
--     local pdata = CCmd_Data:create(6)
--     pdata:pushdword(GlobalUserItem.dwUserID)
--     pdata:pushword(pKindID or 0)
--     pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_UPDATE_RECOMMEND)
--     self:AddNetEvent(pdata)
-- 	return true
-- end

--请求：获取商品列表 3-1210
function ServerFrameMgr:C2S_GetProductInfos()
    local pdata = CCmd_Data:create(4+G_NetLength.LEN_PASSWORD*2)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetProductInfos)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    self:AddNetEvent(pdata)
    return true
end

--返回：获取商品列表
function ServerFrameMgr:S2C_GetProductInfosResult(pData)
    local len = pData:getlen() 
    if len <= 0 then return end
    local int64 = Integer64:new()
    GlobalData.ProductInfos = {}
    local pList = {}
    local dwErrorCode = pData:readdword() --标准结构错误码，可不用处理
    local pFlag = pData:readbyte()==1 

    local pCountType = pData:readword() or 0 --商品分类数量    
    for i = 1, pCountType do
        local pTypeList = {}
        pTypeList.dwProductTypeID = pData:readdword() --商品分类ID
        pTypeList.szProductTypeName = pData:readstring(G_NetLength.LEN_PRODUCT_TYPE_NAME) --商品分类名称
        pTypeList.byActive = pData:readbyte()==1 --激活标识
        pTypeList.ProductInfos = {} --该类别商品明细
        local pCountProduct = pData:readword()
        for i2 = 1, pCountProduct do
            local pProduct = {}
            pProduct.dwProductID = pData:readdword() --商品ID
            pProduct.dwPrice = pData:readdword() --商品价格（单位：分）
            pProduct.byAwardType = pData:readbyte() --充值类型:1:金币;2:元宝;3:保留
            pProduct.lAwardValue = pData:readscore(int64):getvalue() --充值的分值
            pProduct.byAttachType = pData:readbyte() --附加模式 1:定值,2:百分比
            pProduct.lAttachValue = pData:readscore(int64):getvalue() --附加值
            table.insert(pTypeList.ProductInfos,pProduct)
        end
        table.insert(pList,pTypeList)
    end
    pFlag = false
    for i = 1, 3 do
        if pList[i] and pList[i].byActive then
            pFlag = true
            break
        end
    end
    GlobalData.GiftEnable = pFlag
    GlobalData.ProductInfos = pList
    GlobalData.ProductsOver = true    
    G_event:NotifyEvent(G_eventDef.NET_PRODUCTS_RESULT)  --商品列表拉取完成事件
end

--请求：获取商品类型可否购买状态 3-1212
function ServerFrameMgr:C2S_GetProductTypeActiveState()
    showNetLoading()
    local pdata = CCmd_Data:create(4+G_NetLength.LEN_PASSWORD*2)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetProductTypeActiveState)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    self:AddNetEvent(pdata)
    return true
end

--返回：获取商品类型可否购买状态
function ServerFrameMgr:S2C_GetProductTypeActiveStateResult(pData)
    local len = pData:getlen() 
    if len <= 0 then return end
    local dwErrorCode = pData:readdword() --标准结构错误码，可不用处理
    local pCountType = pData:readword() --商品分类数量 
    for i = 1, pCountType do
        local dwProductTypeID = pData:readdword() --商品分类ID        
        local byActive = pData:readbyte()==1 --激活标识
        for i2, v in ipairs(GlobalData.ProductInfos) do
            if v and v.dwProductTypeID == dwProductTypeID then
                v.byActive = byActive
                break
            end
        end
    end 
    local pFlag = false
    for i = 1, 3 do
        if GlobalData.ProductInfos[i] and GlobalData.ProductInfos[i].byActive then
            pFlag = true
            break
        end
    end
    GlobalData.GiftEnable = pFlag
    dismissNetLoading()
    G_event:NotifyEventTwo(G_eventDef.NET_PRODUCTS_STATE_RESULT)  --同步商品表状态结果
end

--请求：一次性礼包每个商品状态 1216
function ServerFrameMgr:C2S_GetProductActiveState(pProductTypeID)
    local pdata = CCmd_Data:create(4+G_NetLength.LEN_PASSWORD*2+4)    
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetProductActiveState)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    pdata:pushdword(pProductTypeID)
    self:AddNetEvent(pdata)
    return true
end

--返回：一次性礼包每个商品状态 1217
function ServerFrameMgr:S2C_GetProductActiveStateResult(pData)        
    local len = pData:getlen() 
    if len <= 0 then return end    
    local pProductCount = pData:readword() --一次性商品数量 
    for i = 1, pProductCount do   
        GlobalData.ProductOnceState[i] = pData:readbyte() --激活标识        
    end     
    G_event:NotifyEventTwo(G_eventDef.NET_GET_PRODUCT_ACTIVE_STATE_RESULT)  --同步一次性礼包状态结果
end

--请求：获取支付URL，可拼凑参数后提交 3-1204
function ServerFrameMgr:C2S_GetPayUrl(pProductID)
    local pdata = CCmd_Data:create(4+G_NetLength.LEN_PASSWORD*2+4+1)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetPayUrl)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    pdata:pushdword(pProductID)    
    pdata.pushbyte(0)
    self:AddNetEvent(pdata)
    return true 
end
--返回支付URL，可拼凑参数后提交
function ServerFrameMgr:S2C_GetPayUrlResult(pData)
    local len = pData:getlen() 
    if len <= 0 then return end
    local dwErrorCode = pData:readdword() --标准结构错误码，可不用处理
    --print("dwErrorCode = ",dwErrorCode)
    if dwErrorCode~=0 then return end
    local info = {}
    info.dwProductID = pData:readdword() --商品ID
    info.szPayUrl = pData:readstring(256) --支付地址    
    G_event:NotifyEventTwo(G_eventDef.NET_PAY_URL_RESULT,info)  --支付URL获取完成事件
end

--请求：激活码邀请卡 3-1530
function ServerFrameMgr:C2S_GiftCodeActive(giftCode, szClientIP)
    tlog("ServerFrameMgr:C2S_GiftCodeActive", giftCode, szClientIP, GlobalUserItem.szDynamicPass)
    local pdata = CCmd_Data:create(4+(G_NetLength.LEN_PASSWORD+33+16)*2)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GiftCodeActive)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    pdata:pushstring(giftCode,33)
    pdata:pushstring(szClientIP,16)
    self:AddNetEvent(pdata)
    return true
end
--返回：激活码邀请卡
function ServerFrameMgr:S2C_GiftCodeActiveResult(pData)
    local len = pData:getlen() 
    if len <= 0 then return end
    local int64 = Integer64:new()
    local cmdData = {}
    cmdData.dwErrorCode = pData:readdword() --标准结构错误码，可不用处理
    cmdData.cbCurrencyType = pData:readbyte() --货币类型 1金币 101 限时购买礼包 
    cmdData.llScore = pData:readscore(int64):getvalue() --货币类型为1时，为金币的数量
    G_event:NotifyEvent(G_eventDef.NET_GIFT_CODE_ACTIVE_RESULT, cmdData)  --激活码邀请卡完成事件
    tdump(cmdData, "ServerFrameMgr:S2C_GiftCodeActiveResult", 9)
end

--请求：获取激活码限时礼包商品列表 3-1532
function ServerFrameMgr:C2S_GetGiftCodeStatus()
    local pdata = CCmd_Data:create(4)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetGiftCodeStatus)
    pdata:pushdword(GlobalUserItem.dwUserID)
    self:AddNetEvent(pdata)
    return true
end

--返回：获取激活码限时礼包商品列表
function ServerFrameMgr:S2C_GetGiftCodeStatusResult(pData)
    local len = pData:getlen() 
    if len <= 0 then return end
    local int64 = Integer64:new()
    local cmdData = {}
    --cmdData.llScore = pData:readscore(int64):getvalue() --未领取的余额 0表示没有
    cmdData.lsItems = {}
    local pCountType = pData:readword() --商品数量    
    for i = 1, pCountType do
        local pProduct = {}
        pProduct.dwProductID = pData:readdword() --商品ID
        pProduct.dwPrice = pData:readdword() --商品价格（单位：分）
        pProduct.byAwardType = pData:readbyte() --充值类型:1:金币;2:元宝;3:保留
        pProduct.lAwardValue = pData:readscore(int64):getvalue() --充值的分值
        pProduct.byAttachType = pData:readbyte() --附加模式 1:定值,2:百分比
        pProduct.lAttachValue = pData:readscore(int64):getvalue() --附加值
        pProduct.tmExpireTime = pData:readscore(int64):getvalue()--商品过期时间
        table.insert(cmdData.lsItems,pProduct)
    end
    tdump(cmdData, "ServerFrameMgr:S2C_GetGiftCodeStatusResult", 9)
    GlobalData.GiftCodeProducts = cmdData
    G_event:NotifyEventTwo(G_eventDef.NET_GET_GIFT_CODE_STATUS_RESULT)  --获取激活码限时礼包商品列表拉取完成事件
end

--请求：获取slots游戏彩金池状态 3-1560
function ServerFrameMgr:C2S_GetJackPotStatus()
    tlog("ServerFrameMgr:C2S_GetJackPotStatus")
    local pdata = CCmd_Data:create(2)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetJackPotStatus)
    pdata:pushword(0)
    self:AddNetEvent(pdata)
    return true
end

--返回：获取slots游戏彩金池状态
function ServerFrameMgr:S2C_GetJackPotStatusResult(pData)
    local len = pData:getlen() 
    if len <= 0 then return end
    local int64 = Integer64:new()
    local cmdData = {}
    cmdData.wPotType = pData:readword() --未用到
    cmdData.llScore = pData:readscore(int64):getvalue() --彩金池值
    tdump(cmdData, "ServerFrameMgr:S2C_GetJackPotStatusResult", 9)
    GlobalData.JackPotScore = cmdData.llScore
    G_event:NotifyEventTwo(G_eventDef.NET_GET_JACK_POT_STATUS_RESULT, cmdData)  --获取slots游戏彩金池状态完成事件
end

--请求：获取提现信息 3-1220
function ServerFrameMgr:C2S_GetWithdrawStatus()
    tlog("ServerFrameMgr:C2S_GetWithdrawStatus")
    local pdata = CCmd_Data:create(4+G_NetLength.LEN_PASSWORD*2)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetWithdrawStatus)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    self:AddNetEvent(pdata)
    return true
end

--返回：获取提现信息
function ServerFrameMgr:S2C_GetWithdrawStatusResult(pData)
    tlog("ServerFrameMgr:S2C_GetWithdrawStatusResult")
    local len = pData:getlen() 
    if len <= 0 then return end
    local int64 = Integer64:new()
    local cmdData = {}
    cmdData.lCurrentBetScore = pData:readscore(int64):getvalue() --当前打码量
    cmdData.lRequireBetScore = pData:readscore(int64):getvalue() --需要打码量
    cmdData.lSubmitScore = pData:readscore(int64):getvalue() --审核中的金额

    G_event:NotifyEvent(G_eventDef.NET_WITHDRAW_STATUS_RESULT, cmdData)  --提现信息拉取完成事件
end

--请求：获取提现额度列表 3-1222
function ServerFrameMgr:C2S_GetWithdrawConfig()
    tlog("ServerFrameMgr:C2S_GetWithdrawConfig")
    local pdata = CCmd_Data:create(4)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetWithdrawConfig)
    pdata:pushdword(GlobalUserItem.dwUserID)
    self:AddNetEvent(pdata)
    return true
end

--返回：获取提现额度列表
function ServerFrameMgr:S2C_GetWithdrawConfigResult(pData)
    local len = pData:getlen() 
    tlog("ServerFrameMgr:S2C_GetWithdrawConfigResult", len)
    if len <= 0 then return end
    local int64 = Integer64:new()
    local cmdData = {}
    cmdData.goldList = {}
    local pList = {}
    local dwErrorCode = pData:readdword() --标准结构错误码，可不用处理
    if dwErrorCode == 0 then
        cmdData.outUrl = pData:readstring(256) --提现请求地址
        cmdData.accountTypeStr = pData:readstring(64) --支持的账号类型列表,eg:“cpf|cnpj|email|phone|evp”
        cmdData.accountTypeTb = string.split(cmdData.accountTypeStr,"|")
        local pCountType = pData:readword() --额度列表数量    
        for i = 1, pCountType do
            local pTypeList = {}
            pTypeList.dwProductID = pData:readdword() --产品id
            pTypeList.dwPrice = pData:readdword() --提现价格（货币单位：分）未用到
            pTypeList.byAwardType = pData:readbyte() --提现类型:1:金币;2:元宝;3:保留 未用到
            pTypeList.lAwardValue = pData:readscore(int64):getvalue() --额度
            pTypeList.byAttachType = pData:readbyte() --附加模式 1:定值,2:百分比
            pTypeList.lAttachValue = pData:readscore(int64):getvalue() --附加值  提现： -3代表-3%
            table.insert(pList,pTypeList)
        end
        cmdData.goldList = pList 
        G_event:NotifyEvent(G_eventDef.NET_WITHDRAW_CONFIG_RESULT, cmdData)  --提现额度列表拉取完成事件
    end
end

--请求：获取提现账号历史信息 3-1224
function ServerFrameMgr:C2S_GetWithdrawHistoryAccount()
    tlog("ServerFrameMgr:C2S_GetWithdrawHistoryAccount")
    local pdata = CCmd_Data:create(4+G_NetLength.LEN_PASSWORD*2)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetWithdrawHistoryAccount)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    self:AddNetEvent(pdata)
    return true
end

--返回：获取提现账号历史信息
function ServerFrameMgr:S2C_GetWithdrawHistoryAccountResult(pData)
    tlog("ServerFrameMgr:S2C_GetWithdrawHistoryAccountResult")
    local cmdData = {}
    cmdData.saveInfos = {}
    local pCountType = pData:readword() --保存的历史账号数量   
    print("S2C_GetWithdrawHistoryAccountResult222", pCountType) 
    for i = 1, pCountType do
        local pTypeList = {}
        pTypeList.cpfTypeStr = pData:readstring(16) --支持的账号类型 eg:cpf
        pTypeList.acountName = pData:readstring(50) --真实姓名
        pTypeList.acountNum = pData:readstring(32) --银行卡号或者CPF账户
        pTypeList.cpfNum = pData:readstring(32) --cpf
        if not cmdData.saveInfos[pTypeList.cpfTypeStr] then
            cmdData.saveInfos[pTypeList.cpfTypeStr] = {}
        end
        table.insert(cmdData.saveInfos[pTypeList.cpfTypeStr],pTypeList)
    end
    G_event:NotifyEvent(G_eventDef.NET_WITHDRAW_HISTORY_ACCOUNT_RESULT, cmdData)  --提现信息拉取完成事件
end

--请求：获取提现记录 3-1256
function ServerFrameMgr:C2S_GetWithdrawRecord(pageSize, pageIdx)
    tlog("ServerFrameMgr:C2S_GetWithdrawRecord", pageSize, pageIdx)
    local pdata = CCmd_Data:create(12)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetWithdrawRecord)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushdword(pageSize)
    pdata:pushdword(pageIdx)
    self:AddNetEvent(pdata)
    return true
end

--返回：获取提现记录
function ServerFrameMgr:S2C_GetWithdrawRecordResult(pData)
    tlog("ServerFrameMgr:S2C_GetWithdrawRecordResult")
    local len = pData:getlen() 
    if len <= 0 then return end
    local int64 = Integer64:new()
    local cmdData = {}
    cmdData.historyList = {}
    local pList = {}
    cmdData.dwPageSize = pData:readdword() --每页数量
    cmdData.dwPageIndex = pData:readdword() --当前页码
    cmdData.dwRecordCount = pData:readdword() --全部记录
    cmdData.dwPageCount = pData:readdword() --总页数
    local pCountType = pData:readdword() --提现记录数量
    for i = 1, pCountType do
        local pTypeList = {}
        pTypeList.out = pData:readint() --提取额度
        pTypeList.time = pData:readscore(int64):getvalue() --提取时间
        local state = pData:readint() --审核状态
        --0未审核，1提交失败，2提交成功，3提现失败，4提现成功，5处理成功，107管理员拒绝，108管理员没收
        if state == 0 or state == 2 then
            pTypeList.state = 1 --审核中
        elseif state == 1 or state == 3 then
            pTypeList.state = 2 --提交失败
        elseif state == 4 or state == 5 then
            pTypeList.state = 3 --已完成
        else
            pTypeList.state = 4 --违规订单
        end
        pTypeList.order = pData:readstring(33) --提取订单号
        table.insert(pList,pTypeList)
    end
    cmdData.historyList = pList 
    G_event:NotifyEvent(G_eventDef.NET_CASHOUT_HISTORY_RESULT, cmdData)  --提现记录拉取完成事件
end

--请求：获取邮件列表 51-101
function ServerFrameMgr:C2S_GetMailList(pageSize, pageIdx, mailType)
    tlog("ServerFrameMgr:C2S_GetMailList", pageSize, pageIdx, mailType)
    mailType = mailType or 1
    local pdata = CCmd_Data:create(10)
    pdata:setcmdinfo(G_NetCmd.MDM_GP_MAIL,G_NetCmd.SUB_GP_MAIL_LIST)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushdword(pageIdx)
    pdata:pushbyte(pageSize)
    pdata:pushbyte(mailType)
    self:AddNetEvent(pdata)
    return true
end

--返回：获取邮件列表
function ServerFrameMgr:S2C_GetMailListResult(pData)
    tlog("ServerFrameMgr:S2C_GetMailListResult")
    local len = pData:getlen() 
    if len <= 0 then return end
    local int64 = Integer64:new()
    local cmdData = {}
    cmdData.mailList = {}
    local pList = {}
    cmdData.dwPageSize = pData:readbyte() --每页数量
    cmdData.dwPageIndex = pData:readdword() --当前页码
    cmdData.dwRecordCount = pData:readdword() --全部记录
    cmdData.dwPageCount = pData:readdword() --总页数
    local pCountType = pData:readbyte() --当前页邮件数量
    tlog("ServerFrameMgr:S2C_GetMailListResult2", pCountType, len)
    for i = 1, pCountType do
        local pTypeList = {}
        pTypeList.mailId = pData:readdword() --邮件id
        pTypeList.dwFromUserId = pData:readdword() --发送者Id
        pTypeList.time = pData:readscore(int64):getvalue()--邮件时间
        pTypeList.mailType = pData:readbyte() --邮件类型 1 系统邮件 2 俱乐部 3 私人邮件
        pTypeList.mailStatus = pData:readbyte() --邮件状态 0未读1已读
        pTypeList.haveReward = pData:readbyte() --是否包含附件 0没有1有
        pTypeList.rewardTb = {}
        --[[for j=1,5 do
            pTypeList.rewardTb[j] = {}
            pTypeList.rewardTb[j].rewardType = pData:readbyte() --奖励类型 1 金币 2 TC 币  3  4 
            pTypeList.rewardTb[j].rewardNum = pData:readscore(int64):getvalue() --奖励数量
            pTypeList.rewardTb[j].rewardStatus = pData:readbyte() --奖励状态 0未领1已领
        end--]]
        pTypeList.title = pData:readutf8(256) --邮件标题
        table.insert(pList,pTypeList)
    end
    cmdData.mailList = pList 
    G_event:NotifyEvent(G_eventDef.NET_MAIL_LIST_RESULT, cmdData)  --邮件列表拉取完成事件
end

--请求：获取邮件详情 51-103
function ServerFrameMgr:C2S_GetMailDetails(mailId)
    tlog("ServerFrameMgr:C2S_GetMailDetails", mailId)
    local pdata = CCmd_Data:create(8)
    pdata:setcmdinfo(G_NetCmd.MDM_GP_MAIL,G_NetCmd.SUB_GP_MAILDETAILS)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushdword(mailId)
    self:AddNetEvent(pdata)
    return true
end

--返回：获取邮件详情
function ServerFrameMgr:S2C_GetMailDetailsResult(pData)
    tlog("ServerFrameMgr:S2C_GetMailDetailsResult")
    local len = pData:getlen() 
    if len <= 0 then return end
    local int64 = Integer64:new()
    local cmdData = {}
    local pTypeList = {}
    local dwErrorCode = pData:readdword() --错误
    if dwErrorCode ~= 0 then
        showToast(g_language:getString(dwErrorCode))
        return
    end
    pTypeList.mailId = pData:readdword() --邮件id
    pTypeList.mailType = pData:readbyte() --邮件类型 1 系统邮件 2 俱乐部 3 私人邮件
    pTypeList.dwFromUserId = pData:readdword() --发送者Id
    pTypeList.time = pData:readscore(int64):getvalue() --邮件时间
    pTypeList.mailStatus = 1--pData:readbyte() --邮件状态 0未读1已读
    pTypeList.rewardTb = {}
    for j=1,5 do
        pTypeList.rewardTb[j] = {}
        pTypeList.rewardTb[j].rewardType = pData:readbyte() --奖励类型 1 金币 2 TC 币  3  4 
        pTypeList.rewardTb[j].rewardNum = pData:readscore(int64):getvalue() --奖励数量
        pTypeList.rewardTb[j].rewardStatus = pData:readbyte() --奖励状态 0未领1已领
    end
    pTypeList.title = pData:readutf8(256) --邮件标题
    pTypeList.content = pData:readutf8() --邮件正文
    cmdData.mailInfo = pTypeList
    tdump(cmdData, "S2C_GetMailDetailsResult2", 9)
    G_event:NotifyEvent(G_eventDef.NET_MAIL_DETAILS_RESULT, cmdData)  --邮件详情返回事件
end

--请求：邮件删除 51-105
function ServerFrameMgr:C2S_GetMailDelete(mailId)
    tlog("ServerFrameMgr:C2S_GetMailDelete", mailId)
    local pdata = CCmd_Data:create(8)
    pdata:setcmdinfo(G_NetCmd.MDM_GP_MAIL,G_NetCmd.SUB_GP_MAIL_DELETE)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushdword(mailId)
    self:AddNetEvent(pdata)
    return true
end

--返回：邮件删除
function ServerFrameMgr:S2C_GetMailDeleteResult(pData)
    tlog("ServerFrameMgr:S2C_GetMailDeleteResult")
    local len = pData:getlen() 
    if len <= 0 then return end
    local int64 = Integer64:new()
    local cmdData = {}
    local dwErrorCode = pData:readdword() --错误
    tlog("ServerFrameMgr:S2C_GetMailDeleteResult2", dwErrorCode, g_language:getString(dwErrorCode))
    if dwErrorCode ~= 0 then
        showToast(g_language:getString(dwErrorCode))
        return
    end
    cmdData.mailId = pData:readdword() --邮件id
    tdump(cmdData, "S2C_GetMailDeleteResult3", 9)

    G_event:NotifyEvent(G_eventDef.NET_MAIL_DELETE_RESULT, cmdData)  --邮件删除返回事件
end

--请求：邮件领取 51-107
function ServerFrameMgr:C2S_GetMailReward(mailId)
    tlog("ServerFrameMgr:C2S_GetMailReward", mailId)
    local pdata = CCmd_Data:create(12+G_NetLength.LEN_PASSWORD*2)
    pdata:setcmdinfo(G_NetCmd.MDM_GP_MAIL,G_NetCmd.SUB_GP_GETMAILREWARD)
    pdata:pushdword(GlobalUserItem.dwUserID)
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    pdata:pushdword(mailId)
    pdata:pushdword(0) --0代表领取全部附件，只有这一种方式
    self:AddNetEvent(pdata)
    return true
end

--返回：邮件领取
function ServerFrameMgr:S2C_GetMailRewardResult(pData)
    tlog("ServerFrameMgr:S2C_GetMailRewardResult")
    local len = pData:getlen() 
    if len <= 0 then return end
    local int64 = Integer64:new()
    local cmdData = {}
    local dwErrorCode = pData:readdword() --错误
    tlog("ServerFrameMgr:S2C_GetMailRewardResult2", dwErrorCode, g_language:getString(dwErrorCode))
    if dwErrorCode ~= 0 then
        showToast(g_language:getString(dwErrorCode))
        return
    end
    cmdData.mailId = pData:readdword() --邮件id
    cmdData.goldNum = pData:readscore(int64):getvalue() --金币数量
    cmdData.tcNum = pData:readscore(int64):getvalue() --tc币数量
    tdump(cmdData, "S2C_GetMailRewardResult3", 9)

    G_event:NotifyEvent(G_eventDef.NET_GET_MAIL_REWARD_RESULT, cmdData)  --邮件领取返回事件
end

--请求：邮件领取数量
function ServerFrameMgr:C2S_GetMailCount()
    tlog("ServerFrameMgr:C2S_GetMailCount")
    local pdata = CCmd_Data:create(4)
    pdata:setcmdinfo(G_NetCmd.MDM_GP_MAIL,G_NetCmd.SUB_GP_GETMAILCOUNT)
    pdata:pushdword(GlobalUserItem.dwUserID)
    self:AddNetEvent(pdata)
    return true
end

--返回：邮件领取数量
function ServerFrameMgr:S2C_GetMailCountResult(pData)
    tlog("ServerFrameMgr:S2C_GetMailCountResult")
    local len = pData:getlen() 
    if len <= 0 then return end
    local int64 = Integer64:new()
    local cmdData = {}
    cmdData.mailCount = pData:readbyte() --邮件数量
    tdump(cmdData, "S2C_GetMailCountResult2", 9)
    G_event:NotifyEvent(G_eventDef.NET_GET_MAIL_COUNT_RESULT, cmdData)  --邮件领取返回事件
end

--请求客服配置 3-1250
function ServerFrameMgr:C2S_GetCustomService()
    local pdata = CCmd_Data:create(4)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetCustomService)
    pdata:pushdword(GlobalUserItem.dwUserID)    
    self:AddNetEvent(pdata)
    return true 
end

--返回客服配置 3-1251
function ServerFrameMgr:S2C_GetCustomServiceResult(pData)
    local len = pData:getlen() 
    if len <= 0 then return end
    local dwErrorCode = pData:readdword() --标准结构错误码，可不用处理    
    if dwErrorCode~=0 then return end
    local pCount = pData:readword()
    local info = {}
    for i = 1, pCount do
        local pType = pData:readbyte()
        if not info[pType] then
            info[pType] = {}
        end
        local urlMsg = pData:readstring(G_NetLength.LEN_FACEURL)
        if pType == 1 then
            table.insert(info[pType], urlMsg)
        elseif pType == 2 then
            table.insert(info[pType], urlMsg) 
        end
    end
    GlobalData.CustomerInfos = info
end

--获取短信发送URL
function ServerFrameMgr:C2S_RequestSMSUrl()
    local data = CCmd_Data:create(4)
    data:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetSMSUrl)
    data:pushdword(GlobalUserItem.dwUserID)
    self:AddNetEvent(data)
	return true
end

--获取短信发送URL
function ServerFrameMgr:S2C_GetSMSUrlResult(pData)
    local len = pData:getlen() 
    if len <= 0 then return end
    local dwErrorCode = pData:readdword()
    -- print("dwErrorCode = ",dwErrorCode)
    if dwErrorCode~=0 then return end
    local info = {}
    info.szUrl = pData:readstring(256) 
    -- print('短信验证url======',info.szUrl)
    G_event:NotifyEvent(G_eventDef.NET_SMS_URL_RESULT,info.szUrl)
end

--绑定手机
function ServerFrameMgr:C2S_RequestBindMsg(mobile, code, clientIp)
    local data = CCmd_Data:create(162)
    data:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_BindMobile)
    data:pushdword(GlobalUserItem.dwUserID)
    data:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)
    data:pushstring(mobile,20)
    data:pushstring(code,10)
    data:pushstring(clientIp,16)
    self:AddNetEvent(data)
	return true
end

-- 绑定手机结果
function ServerFrameMgr:S2C_GetBindMsgResult(pData)
    local len = pData:getlen()
    -- print("CMD_MB_GetBindMsgResult len =",len)
    local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_BindMobileResult,pData)
    -- dump(cmdtable,"CMD_MB_GetBindMsgResult")
    G_event:NotifyEvent(G_eventDef.EVENT_BIND_MOBILE_RESULT,cmdtable)
end

--获取手机绑定状态 1284
function ServerFrameMgr:C2S_GetBindMobileStatus()
    local data = CCmd_Data:create(4)
    data:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetBindMobileStatus)
    data:pushdword(GlobalUserItem.dwUserID)    
    self:AddNetEvent(data)
	return true
end

--获取手机绑定状态返回 1285
function ServerFrameMgr:S2C_GetBindMobileStatusResult(pData)
    local len = pData:getlen()
    -- print("CMD_MB_GetBindMobileStatusResult len =",len)
    local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetBindMobileStatusResult,pData)
    -- dump(cmdtable,"CMD_MB_GetBindMobileStatusResult")
    GlobalData.BindingInfo = {
        boBind = cmdtable.boBind,
        boReward = cmdtable.boReward,
        cbCurrencyType = cmdtable.cbCurrencyType,
        lRewardScore = cmdtable.lRewardScore,
    }
    G_event:NotifyEvent(G_eventDef.EVENT_BIND_MOBILE_STATUS)
end

--领取手机绑定奖励 1286
function ServerFrameMgr:C2S_GetBindMobileReward(pIP)
    local data = CCmd_Data:create(4+G_NetLength.LEN_PASSWORD*2+16*2)
    data:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetBindMobileReward)
    data:pushdword(GlobalUserItem.dwUserID)
    data:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)    
    data:pushstring(pIP,16)
    self:AddNetEvent(data)
	return true
end

--领取手机绑定奖励返回 1287
function ServerFrameMgr:S2C_GetBindMobileRewardResult(pData)
    local len = pData:getlen()
    -- print("CMD_MB_GetBindMobileRewardResult len =",len)
    local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetBindMobileRewardResult,pData)
    -- dump(cmdtable,"CMD_MB_GetBindMobileRewardResult")
    G_event:NotifyEvent(G_eventDef.EVENT_BIND_MOBILE_REWARD,cmdtable)
end

--查询分享配置
function ServerFrameMgr:C2S_GetShareConfig()
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetShareConfig,logincmd.CMD_MB_GetShareConfig,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end
--更新分享入口点击次数
function ServerFrameMgr:S2C_UpdateShareCount()
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szMachineID = GlobalUserItem.szMachine,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_UpdateShareCount,logincmd.CMD_MB_UpdateShareCount,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end
--领取分享奖励
function ServerFrameMgr:C2S_GetShareReward(clientIP,shareType)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass,
        szMachineID = GlobalUserItem.szMachine,
        szClientIP = clientIP,
        byShareType = shareType
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetShareReward,logincmd.CMD_MB_GetShareReward,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end
--查询可分享剩余次数
function ServerFrameMgr:C2S_GetShareRestLimits()
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szMachineID = GlobalUserItem.szMachine,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetShareRestLimits,logincmd.CMD_MB_GetShareRestLimits,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--获取系统提示信息 3-1290
function ServerFrameMgr:C2S_GetSystemNotice()
    tlog('ServerFrameMgr:C2S_GetSystemNotice')
    local pdata = CCmd_Data:create(4)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetSystemNotice)
    pdata:pushdword(GlobalUserItem.dwUserID)    
    self:AddNetEvent(pdata)
    return true 
end

--获取系统提示信息返回 3-1291
function ServerFrameMgr:S2C_GetSystemNoticeResult(pData)
    local len = pData:getlen() 
    if len <= 0 then return end
    local dwErrorCode = pData:readdword() --标准结构错误码，可不用处理    
    if dwErrorCode ~= 0 then return end
    local cmdData = {}
    local pCount = pData:readword()
    cmdData.pCount = pCount
    local info = {}
    for i = 1, pCount do
        local data = {}
        data.title = pData:readstring(G_NetLength.LEN_TASK_NAME)
        data.totalTime = pData:readdword()
        data.content = pData:readstring(G_NetLength.LEN_SYSTEM_NOTICE)        
        table.insert(info, data)
    end
    cmdData.strInfo = info
    -- tdump(cmdData, "S2C_GetSystemNoticeResult", 10)
    -- GlobalData.CustomerInfos = info
    G_event:NotifyEvent(G_eventDef.EVENT_SYSTEM_NOTICE_INFO, cmdData)
end

--获取活动配置数据     3-1300
function ServerFrameMgr:C2S_GetActivityConfig(pCount)
    local pdata = CCmd_Data:create(6)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetActivityConfig)
    pdata:pushdword(GlobalUserItem.dwUserID)    
    pdata:pushword(pCount or 10)
    self:AddNetEvent(pdata)
    return true 
end

--获取活动配置数据返回 3-1301
function ServerFrameMgr:S2C_GetActivityConfigResult(pData)
    local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetActivityConfigResult,pData)
    GlobalData.ActivityInfos = cmdtable.lsItems
    for i, v in ipairs(GlobalData.ActivityInfos) do
        if v and v.szImgUrlContent then
            local pTC = string.match(v.szImgUrlContent,'tc_small',1)            
            if pTC then
                GlobalData.TCIndex = i
                break
            end
            local pBS = string.match(v.szTitle,'fluxo',1)
            if pBS then
                GlobalData.BSIndex = i
                break
            end
        end
    end
    G_event:NotifyEvent(G_eventDef.EVENT_HALL_ACTIVITY_DATA)    
end

--获取用户当日流水值，总流水值 1320
function ServerFrameMgr:C2S_GetBetScore(pType)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        cbCurrencyType = pType,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetBetScore,logincmd.CMD_MB_GetBetScore,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true 
end

--获取用户当日流水值，总流水值返回 1321
function ServerFrameMgr:S2C_GetBetScoreResult(pData)
    local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetBetScoreResult,pData)
    G_event:NotifyEvent(G_eventDef.EVENT_HALL_BET_SCORE_DATA,cmdtable)    
end

--查询用户最后一次充值订单信息 1322
function ServerFrameMgr:C2S_GetLastPayInfo(pType)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass,
        cbCurrencyType = pType or 1,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetLastPayInfo,logincmd.CMD_MB_GetLastPayInfo,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true 
end

--查询用户最后一次充值订单信息返回 1323
function ServerFrameMgr:S2C_GetLastPayInfoResult(pData)
    local cmdtable = g_ExternalFun.readData(logincmd.CMD_MB_GetLastPayInfoResult,pData)
    -- dump(cmdtable,"S2C_GetLastPayInfoResult",5)
    if cmdtable.tmDateTime < 0 then
        cmdtable.tmDateTime = 0
    end
    G_event:NotifyEvent(G_eventDef.EVENT_HALL_LAST_PAY_INFO_DATA,cmdtable)    
end

--查询用户VIP信息 1502
function ServerFrameMgr:C2S_GetVIPInfo(pType)
    showNetLoading()
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,        
        cbExperienceRenderMode = pType or 1,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetVIPInfo,logincmd.CMD_MB_GetVIPInfo,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true 
end

--查询用户VIP信息返回 1503
function ServerFrameMgr:S2C_GetVIPInfoResult(pData)
    dismissNetLoading()
    local pData = g_ExternalFun.readData(logincmd.CMD_MB_GetVIPInfoResult,pData)
    GlobalUserItem.VIPInfo = pData
    -- GlobalData.VIPEnable = true    
    G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_VIP,GlobalUserItem.VIPInfo)
end
--------------------------------------------------
----游戏相关请求
----
-------------------------------------------------
--请求游戏列表数据,kindid = 0 所有游戏接口
function ServerFrameMgr:C2S_RequestGameRoomInfo(kindid,showLoading)
    if showLoading then
        showNetLoading()
    end
    local pdata = CCmd_Data:create(2)
    pdata:setcmdinfo(G_NetCmd.MAIN_SERVER_LIST,G_NetCmd.C_SUB_GET_SERVER_LIST)
    pdata:pushword(kindid or 0)

    self:AddNetEvent(pdata)
	return true
end
function ServerFrameMgr:onConnectGame(wKind,wSort,wServerKind)
    if self:GetSocketState() == false then
        printInfo("socket not connect")
        return
    end
    -- self:connectGame(wKind,wSort)
    -- 
    local pdata = CCmd_Data:create(6)
    pdata:setcmdinfo(G_NetCmd.MAIN_KERNEL,G_NetCmd.C_SUB_SOCKET_CONNECT)
    pdata:pushword(wKind)   
    pdata:pushword(wSort)   
    pdata:pushword(wServerKind)   
    self:AddNetEvent(pdata)
end

function ServerFrameMgr:onShutdownGame(wKind,wSort,wServerKind)
    if self:GetSocketState() == false then
        printInfo("socket not connect")
        return
    end
    -- self:connectGame(wKind,wSort)
    -- 
    local pdata = CCmd_Data:create(6)
    pdata:setcmdinfo(G_NetCmd.MAIN_KERNEL,G_NetCmd.C_SUB_SOCKET_SHUTDOWN)
    pdata:pushword(wKind or 1)   
    pdata:pushword(wSort or 1)   
    pdata:pushword(wServerKind or 1)
    --TODO 检查队列    
    self:AddNetEvent(pdata)
end

--发送游戏消息
function ServerFrameMgr:C2S_SendGameProtocol(pBuffer)
    self:AddNetEvent(pBuffer)
	return true
end

--得到转盘配置
function ServerFrameMgr:C2s_getTurnConfig()
    showNetLoading()
    local pdata = CCmd_Data:create(4)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetLotteryCell)
    pdata:pushdword(GlobalUserItem.dwUserID)    
    self:AddNetEvent(pdata)
    return true 
end

--获取幸运转盘用户配置
function ServerFrameMgr:C2s_getTurnUserConfig(wrecordCount)
    showNetLoading()
    local pdata = CCmd_Data:create(6)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetLotteryUserStatus)
    pdata:pushdword(GlobalUserItem.dwUserID)    
    pdata:pushword(wrecordCount)
    self:AddNetEvent(pdata)
    return true 
end


--获取砸金蛋奖励
function ServerFrameMgr:C2s_getEggBreakResult()
    showNetLoading()
    local pdata = CCmd_Data:create(4+(G_NetLength.LEN_PASSWORD+16)*2)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.CMD_MB_GetEggBreak)
    pdata:pushdword(GlobalUserItem.dwUserID)    
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)  
    local lpszIP = GlobalData.MyIP or "127.0.0.1"
    pdata:pushstring(lpszIP,16)  
    self:AddNetEvent(pdata)
    return true 
end

--获取平台中奖最新广播消息列表
function ServerFrameMgr:C2s_getTurnPlatformNewGifts(wrecordCount,dwLowerBound,type)
    local pdata = CCmd_Data:create(11)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetLotteryPlatformRecordNewest)
    pdata:pushdword(GlobalUserItem.dwUserID)    
    pdata:pushword(wrecordCount)
    pdata:pushdword(dwLowerBound)
    pdata:pushbyte(type - 1) 
    self:AddNetEvent(pdata)
    return true 
end

--获取平台中奖历史广播消息列表
function ServerFrameMgr:getTurnPlatformHistory(wrecordCount,dwUpperBound,type)
    local pdata = CCmd_Data:create(7)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetLotteryPlatformRecordHistory)  
    pdata:pushword(wrecordCount)
    pdata:pushdword(dwUpperBound)  
    pdata:pushbyte(type - 1) 
    self:AddNetEvent(pdata)
    return true 
end

--获取用户自己中奖历史消息列表
function ServerFrameMgr:getTurnUserHistoryList(wPageSize,wPageIndex)
    local pdata = CCmd_Data:create(8)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetLotteryUserRecordHistory) 
    pdata:pushdword(GlobalUserItem.dwUserID)   
    pdata:pushword(wPageSize)
    pdata:pushword(wPageIndex)  
    self:AddNetEvent(pdata)
    return true 
end

--旋转发送
function ServerFrameMgr:goToRevolveTurnTable(cbLotteryType,lpszIP)
    lpszIP = GlobalData.MyIP or "127.0.0.1"
    local pdata = CCmd_Data:create(37)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_LotterySbin) 
    pdata:pushdword(GlobalUserItem.dwUserID)   
    pdata:pushbyte(cbLotteryType)
    pdata:pushstring(lpszIP,16)  
    self:AddNetEvent(pdata)
    return true 
end

--得到转盘配置
function ServerFrameMgr:getTurnHelperConfig()
    local pdata = CCmd_Data:create(4)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.CMD_MB_GetLotteryHelpPresent) 
    pdata:pushdword(GlobalUserItem.dwUserID)   
    self:AddNetEvent(pdata)
    return true 
end

--请求塔罗牌数据  SUB_MB_GetLuckyCardUserStatusResult 接收
function ServerFrameMgr:C2S_RequestTarotData()
    local tempData = {
        dwUserId = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    -- dump(tempData)
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetLuckyCardUserStatus,logincmd.CMD_MB_UserLuckyCardStatus,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--开启塔罗牌
function ServerFrameMgr:C2S_RequestTarotCard(selectId,myIp)
    local tempData = {
        dwUserId = GlobalUserItem.dwUserID,
        cbBetId = selectId,
        szClientIP = myIp,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    -- dump(tempData)
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_UserLuckyCardDraw,logincmd.CMD_MB_UserLuckyCardDraw,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--请求充值返利
function ServerFrameMgr:requestRechargeBenefit()
    local pdata = CCmd_Data:create(4)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.CMD_MB_GetPayRebateInfo) 
    pdata:pushdword(GlobalUserItem.dwUserID)   
    self:AddNetEvent(pdata)
end

--领取充值返利奖励1582
function ServerFrameMgr:receiveRechargeBenefit()
    local pdata = CCmd_Data:create(36 + G_NetLength.LEN_PASSWORD * 2)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.CMD_MB_GetPayRebateReward) 
    pdata:pushdword(GlobalUserItem.dwUserID) 
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)  
    pdata:pushstring(GlobalData.MyIP,16)
    self:AddNetEvent(pdata)
end

--获取转盘分享物品列表 发送：1700
function ServerFrameMgr:requestTurnTableShareList()
    local pdata = CCmd_Data:create(4)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SHARE_TURNTABLE) 
    pdata:pushdword(GlobalUserItem.dwUserID)   
    self:AddNetEvent(pdata)
end

--获取玩家状态，用于填满主界面 发送：1702
function ServerFrameMgr:requestTurnTableUserStatus()
    showNetLoading()    
    local pdata = CCmd_Data:create(12)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SHARE_TURNTABLE_PLAYSTATUS) 
    pdata:pushdword(GlobalUserItem.dwUserID)   
    pdata:pushdword(4)   
    pdata:pushdword(1)   
    self:AddNetEvent(pdata)
end

--获取玩家的邀请记录 发送：1706
function ServerFrameMgr:requestTurnTableUserInvited(index)
    local pdata = CCmd_Data:create(12)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SHARE_TURNTABLE_PLAYSTATUSRecords) 
    pdata:pushdword(GlobalUserItem.dwUserID)   
    pdata:pushdword(20)   
    pdata:pushdword(index)   
    self:AddNetEvent(pdata)
end

--旋转转盘 发送： 1708
function ServerFrameMgr:requestTurnTableSolved()
    local pdata = CCmd_Data:create(36 + G_NetLength.LEN_PASSWORD * 2)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.CMD_MB_ShareLotteryExecuteSbin) 
    pdata:pushdword(GlobalUserItem.dwUserID)   
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)  
    pdata:pushstring(GlobalData.MyIP,16)
    self:AddNetEvent(pdata)
end

--目标已达成，领取奖励 发送： 1710
function ServerFrameMgr:requestTurnTableGetGift()
    local pdata = CCmd_Data:create(36 + G_NetLength.LEN_PASSWORD * 2)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.CMD_MB_ShareLotteryTakeReward) 
    pdata:pushdword(GlobalUserItem.dwUserID)  
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)  
    pdata:pushstring(GlobalData.MyIP,16)
    self:AddNetEvent(pdata)
end

--获取幸运玩家历史记录 发送：1704
function ServerFrameMgr:requestTurnLuckHistory(index)
    local pdata = CCmd_Data:create(12)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SHARE_TURNTABLE_HISTORY) 
    pdata:pushdword(GlobalUserItem.dwUserID)  
    pdata:pushdword(20)  
    pdata:pushdword(index)
    self:AddNetEvent(pdata)
end

--领取连续签到奖励
function ServerFrameMgr:requestContinueSign(index)
    local pdata = CCmd_Data:create(37 + G_NetLength.LEN_PASSWORD * 2)
    pdata:setcmdinfo(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_GP_CHECKIN_GET_SERIAL_REWARD) 
    pdata:pushdword(GlobalUserItem.dwUserID)  
    pdata:pushbyte(index)  
    pdata:pushstring(GlobalUserItem.szDynamicPass,G_NetLength.LEN_PASSWORD)  
    pdata:pushstring(GlobalData.MyIP,16)
    self:AddNetEvent(pdata)
end


return ServerFrameMgr
