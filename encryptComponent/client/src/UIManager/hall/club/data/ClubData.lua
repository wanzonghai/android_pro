

local ClubData = class("ClubData")
local clubCmd = require(appdf.CLIENT_SRC.."UIManager.hall.club.data.CMD_ClubServer")
local codeConfig = require(appdf.CLIENT_SRC.."UIManager.hall.club.data.ClubErrorConfig")

function ClubData:ctor()
    self:init()
end

function ClubData:init()
    -- for k,v in pairs(clubCmd) do
    --     if type(v) == "number" and G_NetCmd[k] == nil then
    --         G_NetCmd[k] = v
    --         print(k,v)
    --     end
    -- end
    G_event:AddNotifyEvent(G_eventDef.NET_CLUB_DATA,handler(self,self.onSocketEvent))
end

function ClubData:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_CLUB_DATA)
    -- for k,v in pairs(clubCmd) do
    --     if type(v) == "number" and G_NetCmd[k] ~= nil then
    --         G_NetCmd[k] = nil
    --     end
    -- end
end
--请求俱乐部列表  1
function ClubData:C2S_requestClubList(pageSize,pageIndex)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        dwPageSize = pageSize,
        dwPageIndex = pageIndex,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_LIST,clubCmd.CMD_GP_QueryAgentList,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--加入俱乐部  3
function ClubData:C2S_requestJoinClub(dwAgentID)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        dwAgentID = dwAgentID,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_JOIN,clubCmd.CMD_GP_AgentJoin,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--获取公告  5
function ClubData:C2S_requestGetNotice(dwAgentID)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        dwAgentID = dwAgentID,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }

    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_NOTICE,clubCmd.CMD_GP_QueryAgentNotice,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--创建者将玩家踢出俱乐部  7
function ClubData:C2S_requestKickout(creatorUserID,agentID,memberID)
    local tempData = {
        dwCreatorUserID = creatorUserID,
        dwAgentID = agentID,
        dwMemeberUserID = memberID,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_KICKOUT,clubCmd.CMD_GP_AgentKickOutMember,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--玩家主动退出俱乐部  9
function ClubData:C2S_requestAgentExit(dwAgentID)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        dwAgentID = dwAgentID,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_EXIT,clubCmd.CMD_GP_AgentExit,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--同意加入
function ClubData:C2S_requestAgentAccept(createID,dwAgentID,memberID)
    local tempData = {
        dwCreatorUserID = createID,
        dwAgentID = dwAgentID,
        dwMemberUserID = memberID,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_ACCEPT,clubCmd.CMD_GP_AgentAccept,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--更新公告
function ClubData:C2S_requestUpdateNotice( createUserID,dwAgentID,content,title )
    local tempData = {
        dwCreatorUserID = createUserID,
        dwAgentID = dwAgentID,
        szTitle = title or "",
        szNotice = content or "",
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    print(GlobalUserItem.szDynamicPass)
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_UPDATE_NOTICE,clubCmd.CMD_GP_AgentUpdateNotice,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--成员列表
function ClubData:C2S_requestMemberList( dwPageSize,dwPageIndex,dwAgentID )
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        dwPageSize = dwPageSize,
        dwPageIndex = dwPageIndex,
        dwAgentID = dwAgentID,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_MEMBER_LIST,clubCmd.CMD_GP_AgentMemeberList,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--拒绝加入
function ClubData:C2S_requestAgentRefuse( createID,dwAgentID,memberID )
    local tempData = {
        dwCreatorUserID = createID,
        dwAgentID = dwAgentID,
        dwMemberUserID = memberID,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_REFUSE,clubCmd.CMD_GP_AgentRefuse,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--设置审核开关
function ClubData:C2S_requestSetSwitch( createID,dwAgentID,dwSwitch )
    local tempData = {
        dwCreatorUserID = createID,
        dwAgentID = dwAgentID,
        dwSwitch = dwSwitch,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_SET_SWITCH,clubCmd.CMD_GP_AgentSetSwitch,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--获取自己所属俱乐部
function ClubData:C2S_requestAgentDetail(  )
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_DETAIL,clubCmd.CMD_GP_AgentDetail,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--正在申请中的玩家名单列表
function ClubData:C2S_requestAuditList(createID, dwAgentID, dwPageSize, dwPageIndex)
    local tempData = {
        dwCreatorUserID = createID,
        dwAgentID = dwAgentID,
        dwPageSize = dwPageSize,
        dwPageIndex = dwPageIndex,
        szDynamicPass = GlobalUserItem.szDynamicPass
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_REQUEST_LIST,clubCmd.CMD_GP_AgentRequestList,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--已经申请过在审核的公会
function ClubData:C2S_requestAgentList()
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_REQUEST_AGENT_LIST,clubCmd.CMD_GP_AgentRequestAgentList,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--修改俱乐部社交群
function ClubData:C2S_requestUpdateURL(dwAgentID,dwUrlIndex,szUrlValue )
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass,
        dwAgentID = dwAgentID,
        dwUrlIndex = dwUrlIndex,
        szUrlValue = szUrlValue,
        
    }
    dump(tempData,"tempData",5)
    print(GlobalUserItem.szDynamicPass)
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_UPDATE_URL,clubCmd.CMD_GP_AgentUpdateUrl,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

function ClubData:onSocketEvent(info)
    if info.sub == G_NetCmd.SUB_GP_AGENT_LIST_RESULT then
        --返回俱乐部列表 2
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_QueryAgentListResult, info.pData)
        if self:CLUB_ERROR_CODE(cmdtable) then 
            G_event:NotifyEvent(G_eventDef.EVENT_CLUBLISTDATA,cmdtable)
        end
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_JOIN_RESULT then
        --加入俱乐部 4
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentJoinResult, info.pData)
        if self:CLUB_ERROR_CODE(cmdtable) then 
            G_event:NotifyEvent(G_eventDef.EVENT_AGENTJOINRESULT,cmdtable)
        end
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_NOTICE_RESULT then
        --获取公告 6
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_QueryAgentNoticeResult, info.pData)
        dump(cmdtable)
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_KICKOUT_RESULT then
        --创建者将玩家踢出俱乐部 8
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentKickOutMemberResult, info.pData)
        if self:CLUB_ERROR_CODE(cmdtable) then 
            G_event:NotifyEvent(G_eventDef.EVENT_AGENTKICKOUT,cmdtable)
        end
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_EXIT_RESULT then
        --玩家主动退出俱乐部 10
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentExitResult, info.pData)
        if self:CLUB_ERROR_CODE(cmdtable) then 
            G_event:NotifyEvent(G_eventDef.EVENT_AGENTEXIT,cmdtable)
        end
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_ACCEPT_RESULT then
        --同意加入 12
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentAcceptResult, info.pData)
        if self:CLUB_ERROR_CODE(cmdtable) then 
            G_event:NotifyEvent(G_eventDef.EVENT_CLUBJOIRESULT,cmdtable)
        end
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_UPDATE_NOTICE_RESULT then
        --更新公告 14
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentUpdateNoticeResult, info.pData)
        if self:CLUB_ERROR_CODE(cmdtable) then 
            G_event:NotifyEvent(G_eventDef.NET_UPDATENOTICE,cmdtable)
        end
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_MEMBER_LIST_RESULT then
        --成员列表 16
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentMemeberListResult, info.pData)
        if self:CLUB_ERROR_CODE(cmdtable) then 
            G_event:NotifyEvent(G_eventDef.EVENT_MEMBERLISTDATA,cmdtable)
        end
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_REFUSE_RESULT then
        --拒绝加入 18
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentRefuseResult, info.pData)
        if self:CLUB_ERROR_CODE(cmdtable) then 
            G_event:NotifyEvent(G_eventDef.EVENT_CLUBJOIRESULT,cmdtable)
        end
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_SET_SWITCH_RESULT then
        --设置审核开关 20
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentSetSwitchResult, info.pData)
        if self:CLUB_ERROR_CODE(cmdtable) then 
            G_event:NotifyEvent(G_eventDef.EVENT_CLUBAUDITSET,cmdtable)
        end
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_DETAIL_RESULT then
        --获取自己所属俱乐部明细 22
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentDetailResult, info.pData)        
        if self:CLUB_ERROR_CODE(cmdtable) then 
            G_event:NotifyEvent(G_eventDef.NET_GET_AGENT_DETAIL,cmdtable)
        end
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_REQUEST_LIST_RESULT then
        --正在申请中的玩家名单列表 24
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentRequestListResult, info.pData)
        if self:CLUB_ERROR_CODE(cmdtable) then 
            G_event:NotifyEvent(G_eventDef.EVENT_CLUBAUDITLIST,cmdtable)
        end
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_REQUEST_AGENT_LIST_RESULT then
        --申请过在审核的公会 26
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentRequestAgentListResult, info.pData)
        self:CLUB_ERROR_CODE(cmdtable)
        G_event:NotifyEvent(G_eventDef.NET_REQUESTAGENTLIST,cmdtable)
    elseif info.sub == G_NetCmd.SUB_GP_AGENT_UPDATE_URL_RESULT then
        --修改俱乐部社交群结果 30
        local cmdtable = g_ExternalFun.readData(clubCmd.CMD_GP_AgentUpdateUrlResult, info.pData)
        self:CLUB_ERROR_CODE(cmdtable)
        G_event:NotifyEvent(G_eventDef.NET_UPDATEURLRESULT,cmdtable)
    end
end

function ClubData:CLUB_ERROR_CODE(cmdtable)
    dump(cmdtable)
    if cmdtable.dwErrorCode and cmdtable.dwErrorCode > 0 then
        print(codeConfig[cmdtable.dwErrorCode])
    end
    return true
end

return ClubData