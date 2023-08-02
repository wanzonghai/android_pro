


local club_cmd = {}

club_cmd.MDM_GP_AGENT    = 50   --club 主命令

--通用操作 返回 dwAgentID=0表示失败，dwAgentID=俱乐部ID表示成功。
club_cmd.CMD_GP_AgentResult = {
    {t = "dword", k = "dwErrorCode"},                                     --
    {t = "dword", k = "dwAgentID"},                                       --俱乐部ID
	{t = "tchar", k = "szAgentName",s = G_NetLength.LEN_NICKNAME},        --俱乐部名称
}
--通用数据集
club_cmd.tagAgentInfo = {
    {t = "dword", k = "dwAgentID"},                                     --俱乐部ID
    {t = "dword", k = "dwCreatorUserID"},                                     --创建者ID
    {t = "dword", k = "dwMemberCount"},                                       --成员数量
	{t = "tchar", k = "szAgentName",s = G_NetLength.LEN_NICKNAME},        --俱乐部名称
	{t = "tchar", k = "szNickName",s = G_NetLength.LEN_NICKNAME},        --创建者昵称
    {t = "dword", k = "dwNeedConfirm"},                                     --用户加入的时候是否需要创建者确认
}

--请求club列表
G_NetCmd.SUB_GP_AGENT_LIST = 1   
club_cmd.CMD_GP_QueryAgentList = {
    {t = "dword", k = "dwUserID"},                                          --用户ID标识
    {t = "dword", k = "dwPageSize"},                                        --每页数据
    {t = "dword", k = "dwPageIndex"},                                       --当前页码
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},        --动态密码
}
club_cmd.SUB_GP_AGENT_LIST_RESULT = 2  -- club 列表返回
club_cmd.CMD_GP_QueryAgentListResult = {
    {t = "dword", k = "dwErrorCode"},                --
    {t = "dword", k = "dwPageSize"},                --每页数量
    {t = "dword", k = "dwPageIndex"},                --当前页码
    {t = "dword", k = "dwRecordCount"},                --全部记录
    {t = "dword", k = "dwPageCount"},                --总页数
    {t = "dword", k = "dwCount"},                -- lsItems数量
	{t = "table", k = "lsItems", d = club_cmd.tagAgentInfo}
}

--加入俱乐部
club_cmd.SUB_GP_AGENT_JOIN = 3     
club_cmd.CMD_GP_AgentJoin = {
    {t = "dword", k = "dwUserID"},                                          --用户ID标识
    {t = "dword", k = "dwAgentID"},                                        --俱乐部ID
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},        --动态密码
}
club_cmd.SUB_GP_AGENT_JOIN_RESULT = 4
club_cmd.CMD_GP_AgentJoinResult = {
    {t = "dword", k = "dwErrorCode"},                                      --
    {t = "dword", k = "dwAgentID"},                                        --俱乐部ID
	{t = "tchar", k = "szAgentName",s = G_NetLength.LEN_NICKNAME},         --俱乐部名称
    {t = "dword", k = "dwStatus"},                                         --1标识成功,2标识需要等审核批准
}
-- 获取公告
club_cmd.SUB_GP_AGENT_NOTICE		=		5		
club_cmd.CMD_GP_QueryAgentNotice = {
    {t = "dword", k = "dwUserID"},                                        --玩家标识
    {t = "dword", k = "dwAgentID"},                                       --俱乐部ID
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码
}
club_cmd.SUB_GP_AGENT_NOTICE_RESULT		=		6		-- 返回获取公告
club_cmd.CMD_GP_QueryAgentNoticeResult = {
    {t = "dword", k = "dwErrorCode"},                                     --玩家标识
    {t = "dword", k = "dwAgentID"},                                       --俱乐部ID
	{t = "tchar", k = "szTitle",s = 32},                                  --动态密码
	{t = "tchar", k = "szNotice",s = 512},                                --动态密码
}

-- 创建者将玩家踢出俱乐部
club_cmd.SUB_GP_AGENT_KICKOUT		=		7		-- 创建者将玩家踢出俱乐部
club_cmd.CMD_GP_AgentKickOutMember = {
    {t = "dword", k = "dwCreatorUserID"},                                       --创建者标识
    {t = "dword", k = "dwAgentID"},                                       --俱乐部ID
    {t = "dword", k = "dwMemeberUserID"},                                       --俱乐部成员用户ID
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码
}
club_cmd.SUB_GP_AGENT_KICKOUT_RESULT		=		8		--  创建者将玩家踢出俱乐部
club_cmd.CMD_GP_AgentKickOutMemberResult = club_cmd.CMD_GP_AgentResult

-- 玩家主动退出俱乐部
club_cmd.SUB_GP_AGENT_EXIT		=		9		-- 
club_cmd.CMD_GP_AgentExit = {
    {t = "dword", k = "dwUserID"},                                     --玩家标识
    {t = "dword", k = "dwAgentID"},                                       --俱乐部ID
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码
}
club_cmd.SUB_GP_AGENT_EXIT_RESULT		=		10		-- 
club_cmd.CMD_GP_AgentExitResult = club_cmd.CMD_GP_AgentResult

-- 同意加入
club_cmd.SUB_GP_AGENT_ACCEPT		=		11		-- 
club_cmd.CMD_GP_AgentAccept = {
    {t = "dword", k = "dwCreatorUserID"},                                 --创建用户ID
    {t = "dword", k = "dwAgentID"},                                       --俱乐部ID
    {t = "dword", k = "dwMemberUserID"},                                  --
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码
}
club_cmd.SUB_GP_AGENT_ACCEPT_RESULT		=		12	-- 
club_cmd.CMD_GP_AgentAcceptResult = club_cmd.CMD_GP_AgentResult

-- 更新公告
club_cmd.SUB_GP_AGENT_UPDATE_NOTICE		=		13		-- 
club_cmd.CMD_GP_AgentUpdateNotice = {
    {t = "dword", k = "dwCreatorUserID"},                                 --创建用户ID
    {t = "dword", k = "dwAgentID"},                                       --俱乐部ID
	{t = "tchar", k = "szTitle",s = 32},                                  --动态密码
	{t = "tchar", k = "szNotice",s = 512},                                --动态密码
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码
}
club_cmd.SUB_GP_AGENT_UPDATE_NOTICE_RESULT		=		14	-- 
club_cmd.CMD_GP_AgentUpdateNoticeResult = club_cmd.CMD_GP_AgentResult

-- 成员列表
club_cmd.SUB_GP_AGENT_MEMBER_LIST		=		15		-- 
club_cmd.CMD_GP_AgentMemeberList = {
    {t = "dword", k = "dwUserID"},                                 --创建用户ID
    {t = "dword", k = "dwPageSize"},                                        --每页数据
    {t = "dword", k = "dwPageIndex"},                                       --当前页码
    {t = "dword", k = "dwAgentID"},                                       --俱乐部ID
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码

}
club_cmd.SUB_GP_AGENT_MEMBER_LIST_RESULT		=		16	-- 
club_cmd.tagAgentMemberInfo  ={
    {t = "dword", k = "dwGameID"},                                 --游戏ID
    {t = "dword", k = "dwUserID"},                                 --创建用户ID
    {t = "word", k = "wFaceID"},                                       --头像信息
    {t = "word", k = "wMemberOrder"},                         --身份：0普通，1会长，2.3 用于扩展
    {t = "tchar", k = "szNickName",s = G_NetLength.LEN_NICKNAME},        --创建者昵称
    {t = "score", k = "lJoinDate"},
    -- {t = "char", k = "szFaceUrl",s = G_NetLength.LEN_FACEURL},        --头像URL地址
    {t = "char", k = "szFaceUrl",ss = true},        --头像URL地址
}
club_cmd.CMD_GP_AgentMemeberListResult = {
    {t = "dword", k = "dwErrorCode"},                                 --
    {t = "dword", k = "dwPageSize"},                                 --每页数量
    {t = "dword", k = "dwPageIndex"},                                 --当前页码
    {t = "dword", k = "dwRecordCount"},                                 --全部记录
    {t = "dword", k = "dwPageCount"},                                 --总页数
    {t = "dword", k = "dwCount"},                                 --lsItems数量
	{t = "table", k = "lsItems", d = club_cmd.tagAgentMemberInfo}
}

-- 拒绝加入
club_cmd.SUB_GP_AGENT_REFUSE = 17  
club_cmd.CMD_GP_AgentRefuse = {
    {t = "dword", k = "dwCreatorUserID"},                                 --
    {t = "dword", k = "dwAgentID"},                                 --
    {t = "dword", k = "dwMemberUserID"},                                 --
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码
}
club_cmd.SUB_GP_AGENT_REFUSE_RESULT = 18
club_cmd.CMD_GP_AgentRefuseResult = club_cmd.CMD_GP_AgentResult

--设置审核开关
club_cmd.SUB_GP_AGENT_SET_SWITCH = 19
club_cmd.CMD_GP_AgentSetSwitch = {
    {t = "dword", k = "dwCreatorUserID"},                                 --
    {t = "dword", k = "dwAgentID"},                                 --
    {t = "dword", k = "dwSwitch"},                                 --
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码
}
club_cmd.SUB_GP_AGENT_SET_SWITCH_RESULT = 20
club_cmd.CMD_GP_AgentSetSwitchResult = club_cmd.CMD_GP_AgentResult

--获取自己所属俱乐部明细
club_cmd.SUB_GP_AGENT_DETAIL = 21
club_cmd.CMD_GP_AgentDetail = {
    {t = "dword", k = "dwUserID"},                                 --
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码
}
club_cmd.SUB_GP_AGENT_DETAIL_RESULT = 22
club_cmd.CMD_GP_AgentDetailResult = {
    {t = "dword", k = "dwErrorCode"},                                 --
    {t = "dword", k = "dwAgentID"},                                 --
    {t = "dword", k = "dwCreatorUserID"},                                 --
    {t = "dword", k = "dwMemberCount"},                                 --
    {t = "dword", k = "dwNeedConfirm"},                                 --是否需要审核开关状态
	{t = "tchar", k = "szAgentName",s = G_NetLength.LEN_NICKNAME},         --俱乐部名称
    {t = "tchar", k = "szNickName",s = G_NetLength.LEN_NICKNAME},        --创建者昵称    
	{t = "tchar", k = "szTitle",s = 32},                                  --动态密码
	{t = "tchar", k = "szNotice",s = 512},                                --俱乐部公告
    {t = "char", k = "TelegramURL",s = 0},                                --Telegram 群链接
    {t = "char", k = "WhatsAppURL",s = 0},                                --WhatsApp 群链接
    {t = "char", k = "MessengerURL",s = 0},                               --Messenger 群链接
}

-- 正在申请中的玩家名单列表
club_cmd.SUB_GP_AGENT_REQUEST_LIST = 23
club_cmd.CMD_GP_AgentRequestList = {
    {t = "dword", k = "dwCreatorUserID"},                                 --
    {t = "dword", k = "dwAgentID"},   
    {t = "dword", k = "dwPageSize"}, 
    {t = "dword", k = "dwPageIndex"},                          --
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码
}

club_cmd.SUB_GP_AGENT_REQUEST_LIST_RESULT = 24
club_cmd.tagRequestUserInfo = {
    {t = "dword", k = "dwGameID"},                                 --
    {t = "dword", k = "dwUserID"},                                 --
    {t = "word", k = "wFaceID"},                                 --
    {t = "tchar", k = "szNickName",s = G_NetLength.LEN_NICKNAME},        --创建者昵称
    {t = "score", k = "requestTime"},                                   --申请时间
}
club_cmd.CMD_GP_AgentRequestListResult = {
    {t = "dword", k = "dwErrorCode"},                             --
    {t = "dword", k = "dwPageSize"},                              --每页数量
    {t = "dword", k = "dwPageIndex"},                             --当前页码
    {t = "dword", k = "dwRecordCount"},                           --全部记录
    {t = "dword", k = "dwPageCount"},                             --总页数 
    {t = "dword", k = "dwCount"},                                 --
	{t = "table", k = "lsItems", d = club_cmd.tagRequestUserInfo}
}

club_cmd.CMD_GP_AgentRequestAgentList = {
    {t = "dword", k = "dwUserID"},                          --
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码
}

club_cmd.tagAgentIDList = {
    {t = "dword", k = "dwAgentID"},   
}

club_cmd.CMD_GP_AgentRequestAgentListResult = {
    {t = "dword", k = "dwCount"},                                 --
	{t = "table", k = "lsItems", d = club_cmd.tagAgentIDList}
}


-- {t = "vector", k = "dwUserIDFace",realType = "dword"}, --变长数组写法 搜索 search

--修改俱乐部社交群
club_cmd.SUB_GP_AGENT_UPDATE_URL = 28
club_cmd.CMD_GP_AgentUpdateUrl = {
    {t = "dword", k = "dwUserID"},                                 --
	{t = "tchar", k = "szDynamicPass",s = G_NetLength.LEN_PASSWORD},      --动态密码
    {t = "dword", k = "dwAgentID"}, 
    {t = "dword", k = "dwUrlIndex"}, 
    {t = "tchar", k = "szUrlValue",s = 512},
}

club_cmd.CMD_GP_AgentUpdateUrlResult  = {
    {t = "dword", k = "dwErrorCode"},                                      --                                        --1标识成功,2标识需要等审核批准
}

return club_cmd