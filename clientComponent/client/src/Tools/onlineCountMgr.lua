

local onlineCountMgr = class("onlineCountMgr")


function onlineCountMgr:ctor()
    self.m_allOnlineData = {}
    self.m_onlineListener = {}
    self.m_gameTypeData = {}
    G_event:AddNotifyEvent(G_eventDef.EVENT_ONLINE_USER_INFO,handler(self,self.onlineUserDataCallback))
end

--3种综合类型的key  return 街机：1，百人：2，捕鱼：3
function onlineCountMgr:getGameType(kindID)
    for i,v in ipairs(GlobalData.SubGameId) do
        for kk,vv in pairs(v) do
            if kindID == vv then
                return i
            end
        end
    end
    return -1
end

function onlineCountMgr:localUpOnlineCount()
    if not self.m_allOnlineData then return end
    for k,v in pairs(self.m_allOnlineData) do
        if math.random(-1,1) >= 0 then 
            local r = math.random(-10, 10)
            self.m_allOnlineData[k] = math.abs(v + r)
        end
    end
end

--remote
function onlineCountMgr:remoteUpOnlineCount(data)
    for k,v in pairs(self.m_allOnlineData) do
        self.m_allOnlineData[k] = 0
    end

    local typeTab = {}
    for k,v in pairs(data.lsItems) do
        local i = self:getGameType(v.wKindID)
        if i > 0 then
            if typeTab[i] == nil then
                typeTab[i] = {}
            end
            if typeTab[i][v.wKindID] == nil then
                typeTab[i][v.wKindID] = {}
            end
            typeTab[i][v.wKindID][v.wSortID] = v.dwOnLineCount
        end
        self.m_allOnlineData[v.wKindID] = self.m_allOnlineData[v.wKindID] or 0
        self.m_allOnlineData[v.wKindID] = self.m_allOnlineData[v.wKindID] + v.dwOnLineCount
        self.m_allOnlineData[v.wKindID*1000 + v.wServerKind*10 + v.wSortID] = self.m_allOnlineData[v.wKindID*1000 + v.wServerKind*10 + v.wSortID] or 0
        self.m_allOnlineData[v.wKindID*1000 + v.wServerKind*10 + v.wSortID]= v.dwOnLineCount
    end
    
    for i,v in ipairs(typeTab) do
        self.m_allOnlineData[i] = self:recursionTab(v)
    end
end
--
function onlineCountMgr:onlineUserDataCallback(data)

    if data == nil then
        self:localUpOnlineCount()   --本地假更新
    else
        self:remoteUpOnlineCount(data)   --服务器修正数据
    end
    self:dispatchAll()
end


function onlineCountMgr:dispatchAll()
    for kindID,v in pairs(self.m_onlineListener) do
        self:dispatch(kindID,self.m_allOnlineData[kindID])
    end
end

--[[
    @desc: 注册在线人数动态显示
    author:{author}
    time:2022-10-14 11:00:30
    --@eventName:事件名=KindID。如果子场次是kindID*10 + wSortID  
	--@pNode:人数显示节点

    @return: 
]]
function onlineCountMgr:regestOnline(eventName,pNode,func)
    self:UnregisterOnline(pNode)
    local callback = function(node,onlineCount) 
        if node.setString then
            node:setString(onlineCount or "0")
        elseif node.setText then
            node:setText(onlineCount or "0")
        else
            print("regestOnline: -> pNode is not textNode")
        end
        if func then
            func()
        end
    end
    self:registerEvent(eventName,pNode,callback)
    self:dispatchAll()
end

function onlineCountMgr:registerEvent(eventName,pNode,callback)
    self.m_onlineListener[eventName] = self.m_onlineListener[eventName] or {}
    local bindData = {
        target = pNode,
        callback = callback
    }
    table.insert(self.m_onlineListener[eventName],bindData)
end

function onlineCountMgr:dispatch(eventName,onlineCount)
    local list = self.m_onlineListener[eventName] or {}
    for i=#list,1,-1 do
        if type(list[i]) == "table" then
            if self:isBadObj(list[i].target) then
                table.remove(list,i)
            else
                list[i].callback(list[i].target,onlineCount) 
            end
        end
    end
end

function onlineCountMgr:isBadObj(p_obj)
    local __type = type(p_obj)
    if __type == "table" then
        return false
    elseif __type == "userdata" then
        return tolua.isnull(p_obj)
    else
        return true
    end
end

function onlineCountMgr:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_ONLINE_USER_INFO)
end


function onlineCountMgr:recursionTab(data)
    if type(data) == "table" then
        local sum = 0
        for k,v in pairs(data) do
            sum = sum + self:recursionTab(v)
        end
        return sum
    else
        return data
    end
end

function onlineCountMgr:getOnlineData()
    return self.m_allOnlineData
end

--反注册
function onlineCountMgr:UnregisterOnline(pNode)
    for k,v in pairs(self.m_onlineListener) do
        for i=#v,1,-1 do
            if v[i].target == pNode then
                table.remove(v,i)
            end
        end
    end
end

--获取在线人数
function onlineCountMgr:getOnlineCount(kindId)
    if self.m_allOnlineData[kindId] then
        return self.m_allOnlineData[kindId]
    end
    return 0    
end

return onlineCountMgr