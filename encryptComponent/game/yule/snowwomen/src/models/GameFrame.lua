-- snowwomen游戏用户数据管理
-- Date: 2022.10
--
local GameFrame = class("GameFrame")

function GameFrame:ctor()
    tlog("GameFrame:ctor")
    --以座椅号管理
    self.m_tableChairUserList = {}
    --以uid管理
    self.m_tableUidUserList = {}
    --编号管理
    self.m_tableList = {}
    self.m_userBetScoreArray = {}
end

--游戏玩家管理
--初始化用户列表
function GameFrame:initUserList(userList)
    tlog('GameFrame:initUserList')
    --以座椅号管理
    self.m_tableChairUserList = {}
    --以uid管理
    self.m_tableUidUserList = {}
    self.m_tableList = {}

    for k, v in pairs(userList) do
        self.m_tableChairUserList[v.wChairID + 1] = v
        self.m_tableUidUserList[v.dwUserID] = v
        table.insert(self.m_tableList, v)
    end
end

--增加用户
function GameFrame:addUser(userItem)
    if nil == userItem then
        return
    end

    local userInList = self:isUserInList(userItem)
    if not userInList then
        table.insert(self.m_tableList, userItem)
    else
        if userInList.wChairID ~= userItem.wChairID then
            table.remove(self.m_tableChairUserList, userInList.wChairID + 1)
        end
    end
    self.m_tableChairUserList[userItem.wChairID + 1] = userItem
    self.m_tableUidUserList[userItem.dwUserID] = userItem

    print("after add:" .. #self.m_tableList)
end

function GameFrame:updateUser(userItem)
    if nil == userItem then
        return
    end

    local userInList = self:isUserInList(userItem)
    if not userInList then
        table.insert(self.m_tableList, userItem)
    else
        if userInList.wChairID ~= userItem.wChairID then
            table.remove(self.m_tableChairUserList, userInList.wChairID + 1)
        end
    end
    self.m_tableChairUserList[userItem.wChairID + 1] = userItem
    self.m_tableUidUserList[userItem.dwUserID] = userItem
end

function GameFrame:isUserInList(userItem)
    local userInList = nil
    for k,v in pairs(self.m_tableList) do
        if v.dwUserID == userItem.dwUserID then
            userInList = clone(v)
            self.m_tableList[k] = userItem
            break
        end
    end
    return userInList
end

--移除用户
function GameFrame:removeUser(useritem)
    if nil == useritem then
        return
    end
    local deleteidx = nil
    for k,v in pairs(self.m_tableList) do
        local item = v
        if v.dwUserID == useritem.dwUserID then
            deleteidx = k
            break
        end
    end
    if nil ~= deleteidx then
        table.remove(self.m_tableList, deleteidx)
    end

    table.remove(self.m_tableChairUserList, useritem.wChairID + 1)
    table.remove(self.m_tableUidUserList, useritem.dwUserID)

    print("after remove:" .. #self.m_tableList)
end

function GameFrame:removeAllUser()
    --以座椅号管理
    self.m_tableChairUserList = {}
    --以uid管理
    self.m_tableUidUserList = {}
    --总的用户
    self.m_tableList = {}
    self.m_userBetScoreArray = {}
end

function GameFrame:getChairUserList()
    return self.m_tableChairUserList
end

function GameFrame:getUidUserList()
    return self.m_tableUidUserList
end

function GameFrame:getUserList()
    return self.m_tableList
end

--存储所有玩家下注数据
function GameFrame:storeAllUserBetScore(_betData)
    tlog('GameFrame:storeAllUserBetScore')
    self.m_userBetScoreArray = {}
    self.m_userBetScoreArray = _betData
end

function GameFrame:updateUserBetScore(_chairId, _betArea, _betScore)
    local hasCurPlayer = false
    for i, v in ipairs(self.m_userBetScoreArray) do
        if v.chairId == _chairId then
            hasCurPlayer = true
            v.betScore[_betArea] = v.betScore[_betArea] + _betScore
            break
        end
    end
    tlog('GameFrame:updateUserBetScore hasCurPlayer ', hasCurPlayer, _chairId, _betArea, _betScore)
    if not hasCurPlayer then
        local data = {}
        local betScore = {0, 0, 0}
        betScore[_betArea] = _betScore
        data.chairId = _chairId
        data.betScore = betScore
        table.insert(self.m_userBetScoreArray, data)
    end
    -- tdump(self.m_userBetScoreArray, "self.m_userBetScoreArray", 10)
end

--游戏开始的时候重置下注记录
function GameFrame:resetAllUserBetScore()
    self.m_userBetScoreArray = {}
end

--获取所有玩家下注信息
function GameFrame:getAllUserBetScore()
    tlog("snowwomen_GameFrame:getAllUserBetScore")
    return self.m_userBetScoreArray
end

return GameFrame