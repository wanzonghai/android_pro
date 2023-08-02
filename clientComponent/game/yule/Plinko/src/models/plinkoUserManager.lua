

-- 游戏用户数据管理
-- Date: 2022.6
--
local plinkoUserManager = class("plinkoUserManager")

function plinkoUserManager:ctor()
    tlog("plinkoUserManager:ctor")
    --编号管理
    self.m_tableUserList = {}
end

--游戏玩家管理
--初始化用户列表
function plinkoUserManager:initUserList(userList)
    tlog('plinkoUserManager:initUserList')
    self.m_tableUserList = {}
    for k, v in pairs(userList) do
        table.insert(self.m_tableUserList, v)
    end
end

--增加用户
function plinkoUserManager:addUser(userItem)
    if nil == userItem then
        return
    end
    if userItem.wTableID ~= self.m_wTableID then
        return
    end

    local userInList = self:isUserInList(userItem)
    if not userInList then
        table.insert(self.m_tableUserList, userItem)
    end
end

function plinkoUserManager:updateUser(userItem)
    if nil == userItem then
        return
    end
    
    if userItem.wTableID ~= self.m_wTableID then
        return
    end

    local userInList = self:isUserInList(userItem)
    -- if not userInList then
    --     table.insert(self.m_tableUserList, userItem)
    -- end

end

function plinkoUserManager:isUserInList(userItem)
    local userInList = nil
    for k,v in pairs(self.m_tableUserList) do
        if v.dwUserID == userItem.dwUserID then
            userInList = clone(v)
            v = userItem
            break
        end
    end
    return userInList
end

--移除用户
function plinkoUserManager:removeUser(useritem)
    if nil == useritem then
        return
    end
    local deleteidx = nil
    for k,v in pairs(self.m_tableUserList) do
        local item = v
        if v.dwUserID == useritem.dwUserID then
            deleteidx = k
            break
        end
    end
    if nil ~= deleteidx then
        table.remove(self.m_tableUserList, deleteidx)
    end
end

function plinkoUserManager:removeAllUser()
    --总的用户
    self.m_tableUserList = {}
end

function plinkoUserManager:getUserList()
    return self.m_tableUserList
end

function plinkoUserManager:dumpTableUserList(myChairID,myTableID)
    print(myChairID,myTableID)
    dump(self.m_tableUserList,"tableUserList")
end

return plinkoUserManager