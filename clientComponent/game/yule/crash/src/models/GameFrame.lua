-- double游戏用户数据管理
-- Date: 2022.6
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

    self.m_tableChairUserList[userItem.wChairID + 1] = userItem
    self.m_tableUidUserList[userItem.dwUserID] = userItem
    
    local user = self:isUserInList(userItem)
    if nil == user then
        table.insert(self.m_tableList, userItem)
    else
        user = userItem
    end

    print("after add:" .. #self.m_tableList)
end

function GameFrame:updateUser(useritem)
    if nil == useritem then
        return
    end

    local user = self:isUserInList(useritem)
    if nil == user then
        table.insert(self.m_tableList, useritem)
    else
        user = useritem
    end

    self.m_tableChairUserList[useritem.wChairID + 1] = useritem
    self.m_tableUidUserList[useritem.dwUserID] = useritem
end

function GameFrame:isUserInList(useritem)
    local user = nil
    for k,v in pairs(self.m_tableList) do
        if v.dwUserID == useritem.dwUserID then
            user = useritem
            break
        end
    end
    return user
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
    --插入名字
    for i, v in ipairs(self.m_userBetScoreArray) do
        local userInfo = self.m_tableChairUserList[v.chairId + 1]
        if userInfo then
            v.userName = userInfo.szNickName
        else
            tlog("chairid player has no info ", v.chairId)
        end
        v.winScore = math.floor((v.betCrash - 1) * v.betScore + 0.5) 
    end
end

--有玩家下注更新列表
function GameFrame:updateUserBetScore(cmd_placebet)
    local hasCurPlayer = false
    for i, v in ipairs(self.m_userBetScoreArray) do
        if v.chairId == cmd_placebet.wChairID then
            hasCurPlayer = true
            v.betScore = v.betScore + cmd_placebet.lBetScore
            v.winScore = math.floor((v.betCrash - 1) * v.betScore + 0.5) 
            break
        end
    end
    tlog('GameFrame:updateUserBetScore hasCurPlayer ', hasCurPlayer)
    if not hasCurPlayer then
        local data = {}
        data.chairId = cmd_placebet.wChairID
        data.betScore = cmd_placebet.lBetScore
        data.betCrash = cmd_placebet.cbBetCrash
        data.userName = ""
        data.winScore = math.floor((data.betCrash - 1) * data.betScore + 0.5) 
        if self.m_tableChairUserList and self.m_tableChairUserList[cmd_placebet.wChairID + 1] and self.m_tableChairUserList[cmd_placebet.wChairID + 1].szNickName then
            data.userName = self.m_tableChairUserList[cmd_placebet.wChairID + 1].szNickName
        end
        table.insert(self.m_userBetScoreArray, data)
    end
    -- tdump(self.m_userBetScoreArray, "self.m_userBetScoreArray", 10)
end

--游戏开始的时候重置下注记录
function GameFrame:resetAllUserBetScore()
    tlog('GameFrame:resetAllUserBetScore')
    self.m_userBetScoreArray = {}
end

--获取玩家下注信息,下注期间0.1s获取一次
function GameFrame:getAllUserBetScore()
    -- tlog('GameFrame:getAllUserBetScore')
    table.sort(self.m_userBetScoreArray, function (first, second)
        if first.betScore == second.betScore then
            return first.chairId > second.chairId
        else
            return first.betScore > second.betScore
        end
    end)
    return self.m_userBetScoreArray
end

--有玩家点停止，更新他的下注倍率
function GameFrame:updateUserBetCrash(cmd_placebet)
    local hasCurPlayer = false
    for i, v in ipairs(self.m_userBetScoreArray) do
        if v.chairId == cmd_placebet.wChairID then
            hasCurPlayer = true
            v.betCrash = cmd_placebet.lBetCrash / 100
            v.winScore = math.floor((v.betCrash - 1) * v.betScore + 0.5) 
            break
        end
    end
    tlog('GameFrame:updateUserBetCrash hasCurPlayer ', hasCurPlayer)
end

--开奖期间获取玩家下注信息，倍率从大到小排列
function GameFrame:getAllUserBetByRate()
    -- tlog('GameFrame:getAllUserBetByRate')
    local betArray = clone(self.m_userBetScoreArray)
    table.sort(betArray, function (first, second)
        return first.betCrash > second.betCrash
    end)
    return betArray
end

--排序中奖分值，中的多的排上面
function GameFrame:getAllUserBetByRateEx(curCurveNum)
    -- tlog('GameFrame:getAllUserBetByRate')
    local betArray = clone(self.m_userBetScoreArray)
    local winUser = {}  --中奖的
    local others = {} --还未中奖的
    for i, v in pairs(betArray) do
        if v.betCrash > 0 and v.betCrash <= curCurveNum then
            table.insert(winUser, v)
        else
            table.insert(others, v)
        end
    end
    --中奖用户排序
    table.sort(winUser, function (a, b)
        return a.winScore > b.winScore
    end)

    local sorted = {}
    for i, v in ipairs(winUser) do
        table.insert(sorted, v)
    end
    for i, v in ipairs(others) do
        table.insert(sorted, v)
    end

    return sorted
end


--通过一个总时间计算当前曲线下方应该显示的时间节点
--最顶端初始： 5s
--16s以下用2s进位，16s以上就直接用10s进位，40s以上用20s进位,80s以上用40s进位，后同理...
function GameFrame:getNeedShowTimeNums(_totalTimes)
    -- tlog('GameFrame:getNeedShowTimeNums ', _totalTimes)
    if _totalTimes == nil or _totalTimes < 5 then
        _totalTimes = 5
    end
    local factor = 2
    if _totalTimes >= 16 and _totalTimes < 40 then
        factor = 10
    elseif _totalTimes >= 40 and _totalTimes < 80 then
        factor = 20
    elseif _totalTimes >= 80 then
        local lastNum = _totalTimes % 20  --以能整除20为标准计算
        local newNum = _totalTimes - lastNum
        factor = math.floor(newNum / 2)
    end
    local nums = math.floor(_totalTimes / factor)
    if _totalTimes < 4 then --前4秒最低要保持2个
        nums = 2
    end
    local retArr = {}
    local curIndex = 0
    for i = 1, nums + 1 do
        table.insert(retArr, curIndex)
        curIndex = curIndex + factor
    end
    -- tdump(retArr, "time_retArr", 10)
    return retArr, factor
end

--通过一个总倍数计算当前曲线左侧应该显示的倍数节点
--最顶端初始： 1.4
--[[
    1.25 --- 1.5 --- 1.75 --- 
    1 -- 2 -- 3
    1 -- 2 -- 4 -- 6 -- 8 -- 10 -- 12 --14
    1 -- 10 -- 20 --30
    1 -- 20 -- 40 -- 60 -- 80
    ...
]]
function GameFrame:getNeedShowRateNums(_totalRates)
    -- tlog('GameFrame:getNeedShowRateNums ', _totalRates)
    if  _totalRates == nil or _totalRates < 1.4 then
        _totalRates = 1.4
    end
    local factor = 0.25
    if _totalRates >= 2 and _totalRates < 4 then
        factor = 1
    elseif _totalRates >= 4 and _totalRates < 14 then
        factor = 2
    elseif _totalRates >= 14 and _totalRates < 30 then
        factor = 10
    elseif _totalRates >= 30 and _totalRates < 140 then
        factor = 20
    elseif _totalRates >= 140 then
        local lastNum = _totalRates % 50  --以能整除50为标准计算
        local newNum = _totalRates - lastNum
        factor = math.floor(newNum / 3)
    end
    local nums = math.floor((_totalRates - 1) / factor)
    local retArr = {}
    local curIndex = _totalRates >= 2 and 0 or 1
    for i = 1, nums + 1 do
        curIndex = curIndex + factor
        if curIndex <= _totalRates then
            table.insert(retArr, curIndex)
        end
    end
    table.insert(retArr, 1, 1)
    -- tdump(retArr, "rate_retArr", 10)
    return retArr, factor
end

return GameFrame