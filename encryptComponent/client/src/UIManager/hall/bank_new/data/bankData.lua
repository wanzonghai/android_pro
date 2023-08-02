--[[
    银行解析服务器消息
]]

local bankData = class("bankData")
local bankCmd = require(appdf.CLIENT_SRC.."UIManager.hall.bank_new.data.CMD_bankServer")


function bankData:ctor()
    G_event:AddNotifyEvent(G_eventDef.NET_BANK_DATA,handler(self,self.bankServerEvent))
    self:getMyIP()
end

function bankData:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_BANK_DATA)
end

function bankData:getMyIP()
    self.myip = "127.0.0.1"
    local info = {
        url = "https://ifconfig.me/ip",
        callback = function(ok,response) 
            -- print("myIp = ",response)
            self.myip = response 
        end
    }
    http.get(info)
end

function bankData:bankServerEvent(data)
    if data.sub == G_NetCmd.S_SUB_USER_INSURE_ENABLE_RESULT then
        --开通，登录银行返回
        local cmdtable = g_ExternalFun.readData(bankCmd.CMD_MB_EnableBankResult, data.pData)
        G_event:NotifyEvent(G_eventDef.NET_OPEN_BANK_RESULT,cmdtable)
    elseif data.sub == G_NetCmd.S_SUB_OPERATE_SUCCESS then
        -- --修改银行密码返回
        -- local cmdtable = g_ExternalFun.readData(bankCmd.CMD_MB_ModifyBankPswdResult, data.pData)
        -- if cmdtable.lResultCode == 0 then
        --     G_ServerMgr:C2S_RequestUserGold()
        -- end 
        -- G_event:NotifyEvent(G_eventDef.NET_OPERATE_SUCCESS,cmdtable)
    elseif sub == G_NetCmd.S_SUB_GP_QUERY_TRANSFER_USERS_RESULT then
        --查询商人列表返回
        local cmdtable = g_ExternalFun.readData(bankCmd.CMD_MB_TransferUserResult, data.pData)
        G_event:NotifyEvent(G_eventDef.NET_TRANSFER_MERCHANT_LIST,cmdtable)
    elseif data.sub == G_NetCmd.SUB_MB_UserSaveScoreExResult then
        --存入返回
        local cmdtable = g_ExternalFun.readData(bankCmd.CMD_MB_UserSaveScoreExResult, data.pData)
        G_event:NotifyEvent(G_eventDef.NET_BANK_SAVE_RESULT,cmdtable)
        dump(cmdtable)
        G_ServerMgr:C2S_RequestUserGold()
    elseif data.sub == G_NetCmd.SUB_MB_UserTakeScoreExTesult then
        --取回返回
        local cmdtable = g_ExternalFun.readData(bankCmd.CMD_MB_UserTakeScoreExResult, data.pData)
        G_event:NotifyEvent(G_eventDef.NET_BANK_TAKE_RESULT,cmdtable)
        dump(cmdtable)
        G_ServerMgr:C2S_RequestUserGold()
    -- elseif data.sub == G_NetCmd.SUB_GP_AGENT_MEMBER_INFO_RESULT then
    --     --查询会员返回
    --     local info =  g_ExternalFun.readData(bankCmd.CMD_GP_QueryMemberInfoResult, data.pData)
    --     if info.dwErrorCode == 0 then
    --         G_event:NotifyEvent(G_eventDef.EVENT_MEMBERINFO,info)
    --     else
    --         print(g_language:getString(info.dwErrorCode))
    --     end
    elseif data.sub == G_NetCmd.SUB_MB_UserTransferScoreExResult then
        --转账游戏币
        local cmdtable = g_ExternalFun.readData(bankCmd.CMD_MB_UserTransferScoreExResult, data.pData)
        G_event:NotifyEvent(G_eventDef.NET_BANK_TRANSFER_RESULT,cmdtable)
        dump(cmdtable)
        G_ServerMgr:C2S_RequestUserGold()
    elseif data.sub == G_NetCmd.SUB_MB_TransferRecordsExResult then
        --查询转账记录返回
        local cmdtable = g_ExternalFun.readData(bankCmd.CMD_MB_QueryTransferRecordsExResult, data.pData)
        dump(cmdtable)
        G_event:NotifyEvent(G_eventDef.NET_BANK_TRANSFER_DATA,{info = cmdtable})
    end
end

--查询商人列表 在俱乐部上级会长就是商人
function bankData:C2S_RequestBoss(pageSize,pageIndex)
    local tempData = {
        dwPageSize = pageSize,
        dwPageIndex = pageIndex,
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_QUERY_TRANSFER_USERS,bankCmd.CMD_MB_TransferUsers,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

-- 开通银行
function bankData:C2S_requestEnableBank(pswd)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass,
        szBankPassward = md5(pswd),
        szMachineID = GlobalUserItem.szMachine
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_USER_ENABLE_INSURE,bankCmd.CMD_MB_EnableBank,tempData)
    G_ServerMgr:AddNetEvent(pData)
	return true
end

--修改银行密码
function bankData:C2S_requestModifyPswd(oldPswd,newPswd)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szBankPasswardOld = oldPswd,
        szBankPasswardNew = newPswd
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.C_SUB_MODIFY_INSURE_PASS,bankCmd.CMD_MB_ModifyBankPswd,tempData)
    G_ServerMgr:AddNetEvent(pData)
    return true
end

--存入
function bankData:C2S_RequestSaveScoreEx(currencyType,llScore)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = md5(GlobalData.BankPassword),
        cbCurrencyType = currencyType,
        llScore = llScore,
        dwClientAddr = self.myip,
        szMachineID = GlobalUserItem.szMachine
    }
    dump(tempData)
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_UserSaveScoreEx,bankCmd.CMD_MB_UserSaveScoreEx,tempData)
    G_ServerMgr:AddNetEvent(pData)
    return true
end

--取出
function bankData:C2S_RequestUserTakeScoreEx(currencyType,llScore)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szInsurePass = md5(GlobalData.BankPassword),
        cbCurrencyType = currencyType,
        llScore = llScore,
        dwClientAddr = self.myip,
        szMachineID = GlobalUserItem.szMachine
    }
    dump(tempData)
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_UserTakeScoreEx,bankCmd.CMD_MB_UserTakeScoreEx,tempData)
    G_ServerMgr:AddNetEvent(pData)
    return true
end

--查询会员  只有会员才能转
function bankData:C2S_RequestMemberInfo(memberGameId)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        dwGameID = memberGameId,    --接收人ID
        szDynamicPass = GlobalUserItem.szDynamicPass,
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MDM_GP_AGENT,G_NetCmd.SUB_GP_AGENT_MEMBER_INFO,bankCmd.CMD_MB_MemberInfo,tempData)
    G_ServerMgr:AddNetEvent(pData)
    return true
end

--转账
function bankData:C2S_RequestUserTransferScoreEx(currencyType,llScore,toGameId)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szInsurePass = md5(GlobalData.BankPassword),
        cbCurrencyType = currencyType,
        llScore = llScore,
        dwTargetGameID = toGameId,    --接收人ID
        dwClientAddr = self.myip,
        szMachineID = GlobalUserItem.szMachine
    }
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_UserTransferScoreEx,bankCmd.CMD_MB_UserTransferScoreEx,tempData)
    G_ServerMgr:AddNetEvent(pData)
    return true
end

--查询转账记录 查询结构带头像，时间戳的
function bankData:C2S_RequestTransferRecordEx(currencyType,TransferType,pageSize,pageIndex)
    local tempData = {
        dwUserID = GlobalUserItem.dwUserID,
        szDynamicPass = GlobalUserItem.szDynamicPass,
        cbCurrencyType = currencyType,
        cbTransferType = TransferType,
        dwPageSize = pageSize,
        dwPageIndex = pageIndex,
    }
    dump(tempData)
    local pData = g_ExternalFun.writeData(G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetTransferRecordsEx,bankCmd.CMD_MB_QueryTransferRecordsEx,tempData)
    G_ServerMgr:AddNetEvent(pData)
    return true
end

return bankData