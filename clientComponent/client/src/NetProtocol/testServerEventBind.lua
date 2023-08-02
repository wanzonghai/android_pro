

--绑定服务事件

local testServerEventBind = class("testServerEventBind")

function testServerEventBind:ctor()
    self.cmdListener = {}
end

function testServerEventBind:serverEvent(mainCmd,subCmd,data)
    self:__dispatch(mainCmd,subCmd,data)
end
--[[
    @desc: 绑定发包，回包
    author:{bz}
    time:2023-03-14 15:39:05
    --@packData:发送的包，G_ServerMgr:AddNetEvent(pData)函数参数相同的入参
	--@mainCmd:  当前包主命令，回包主命令相同。绑定回包的callback用
	--@resultCmd:回包的子命令，绑定回包的callback用
	--@callback: 服务器返回的数据 流数据
    @return:
    @ 例子: g_testServer:sendPack(pData,G_NetCmd.MAIN_USER_SERVICE,G_NetCmd.SUB_MB_GetLuckyCardUserStatusResult,callback)
]]
function testServerEventBind:sendPack(packData,mainCmd,resultCmd,callback)
    self:registerEvent(resultCmd,mainCmd,callback)
    G_ServerMgr:AddNetEvent(packData)
end

--注册回包事件
function testServerEventBind:registerEvent(subCmd,mainCmd, callback)
    self.cmdListener[subCmd] = self.cmdListener[subCmd] or {}
    local bindData = {
        mainCmd = mainCmd,
        callback = callback,
    }
    self.cmdListener[subCmd] = bindData
end

--分发回包事件
function testServerEventBind:__dispatch(mainCmd,subCmd,pData)
    local list = self.cmdListener[subCmd] or {}
    if type(list) == "table" and list.mainCmd == mainCmd then
        list.callback(pData)
        self.cmdListener[subCmd] = nil
    end
end
--查询是否有注册绑定当前命令的回包
function testServerEventBind:checkSubCmd(mainCmd,subCmd)
    local list = self.cmdListener[subCmd]
        if list and list.mainCmd == mainCmd then
        return true
    end
    return false
end

return testServerEventBind
