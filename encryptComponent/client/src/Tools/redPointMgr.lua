--红点管理
local redPointMgr = class("redPointMgr")

-- local bank = math.fmod(bankSub_1,256)   取余
-- local bank1 = math.modf(bankSub_1/256)  取整
redPointMgr.unit = 0x100    --256
redPointMgr.eventType = {
    bank      = 1,
    bankSub_1 = 0x101, --转账记录变更
    bankSub_2 = 0x102, --充值记录变更
    club      = 2,
    clubSub_1 = 0x201, --会员申请(会长)
    clubSub_2 = 0x202, --公告更改(成员)
    task      = 3,
    taskSub_1 = 0x301, --活跃度奖励
    taskSub_2 = 0x302, --可领奖励任务
    turnTable = 4,
    turnTableSub_1 = 0x401,  --转盘
    turnTableSub_2 = 0x402,  --转盘
    turnTableSub_3 = 0x403,  --转盘
    tarot        = 5,           --塔罗牌
    tarotSub_1   = 0x501, 
    mail      = 6,
    mailSub_1 = 0x601, --未读邮件
    gift        = 7,     --礼包红点
    giftSub_1   = 0x701,
    shareTurn   = 8,        --分享转盘
    shareTurn_1 = 0x801 
}

function redPointMgr:ctor()
    self.redListener = {}
    self.saveRedTable = {}
    self.WritablePath = ""
    G_event:AddNotifyEvent(G_eventDef.EVENT_REDPOINTDATA_RESULT, handler(self, self.onChangeRedPointCallback))
    G_event:AddNotifyEvent(G_eventDef.NET_GET_MAIL_COUNT_RESULT, handler(self, self.onMailCountCallback))

end

--初始化客户端数据存储表
function redPointMgr:initSaveTab()
    local fileName = "redPoint"
    self.saveRedTable = OSUtil.readFiles(fileName)
    if self.saveRedTable == nil then
        self.saveRedTable = {}
    end
    for k, v in pairs(self.eventType) do
        if v > 0x100 then
            local main = math.modf(v / redPointMgr.unit)
            if not self.saveRedTable[main] then
                self.saveRedTable[main] = {}
            end
            if not self.saveRedTable[main][v] then
                self.saveRedTable[main][v] = {}
                self.saveRedTable[main][v].byMethod = 1 --处理方式：1：阅读性质（不管有多少，阅读即焚） 2:处理性质（数量以服务器为准，服务器处理一个才少一个）
                self.saveRedTable[main][v].byCount = 0
            end
        end
    end

end

function redPointMgr:onChangeRedPointCallback(data)
    --清理 处理类型的数据，依赖服务器数据
    for mainKey,mainValue in pairs(self.saveRedTable) do
        for k,v in pairs(mainValue) do
            if v.byMethod == 2 and (self.eventType["mail"] ~= mainKey) then
                v.byCount = 0
            end
        end
    end

    for k, v in pairs(data.lsItems) do
        local bySubType = v.byType * redPointMgr.unit + v.bySubType
        self.saveRedTable[v.byType][bySubType].byMethod = v.byMethod
        if v.byMethod == 1 then
            self.saveRedTable[v.byType][bySubType].byCount = self.saveRedTable[v.byType][bySubType].byCount + v.byCount
        else
            self.saveRedTable[v.byType][bySubType].byCount = v.byCount
        end
    end
    self:checkStatus()
    local FileName ="redPoint"
    OSUtil.saveTable(self.saveRedTable,FileName)
end

--邮件数量红点
function redPointMgr:onMailCountCallback(data)
    --清理 处理类型的数据，依赖服务器数据
    local subTable = self.saveRedTable[self.eventType["mail"]][self.eventType["mailSub_1"]]
    subTable.byMethod = 2
    subTable.byCount = data.mailCount

    self:checkStatus()
    local FileName ="redPoint"
    OSUtil.saveTable(self.saveRedTable,FileName)
end
--
--@Example: g_redPoint:dispatch(g_redPoint.eventType.bank,false)
function redPointMgr:dispatch(eventName, isShow)
    if isShow == false then
        local mainKey = math.modf(eventName / redPointMgr.unit)
        if self.saveRedTable[mainKey][eventName].byMethod == 1 then
            self.saveRedTable[mainKey][eventName].byCount = 0  --读过，清空
        else
            self.saveRedTable[mainKey][eventName].byCount = self.saveRedTable[mainKey][eventName].byCount - 1  
            if self.saveRedTable[mainKey][eventName].byCount <= 0 then
                self.saveRedTable[mainKey][eventName].byCount = 0
            end
        end
    end
    self:checkStatus()
    local FileName ="redPoint"
    OSUtil.saveTable(self.saveRedTable,FileName)
end

function redPointMgr:checkStatus()
    for mainKey,mainValue in pairs(self.saveRedTable) do
        local count = 0
        for eventName,v in pairs(mainValue) do
            self:__dispatch(eventName,v.byCount > 0,v.byCount)
            count = count + v.byCount
        end
        self:__dispatch(mainKey,count > 0 ,count)
    end
end


--[[
    @desc: 注册红点
    author:{bz}
    time:2022-09-27 14:50:38
    --@eventTypeName:红点名接收事件名  redPointMgr.eventType 里面的
	--@pNode: 挂红点的父节点 
	--@pos: 偏移坐标，pos==nil,红点挂到pNode右上角
    @return:
    @Example:g_redPoint:addRedPoint(g_redPoint.eventType.taskSub_1,self.mm_pNode,cc.p(10,10))
]]
function redPointMgr:addRedPoint(eventTypeName, pNode, pos)
    local redNode = pNode:getChildByName("redPointNode")
    if redNode then return end

    -- local imgPath = "client/res/public/dating_xiaohongdian.png"
    -- local redNode = cc.Sprite:create(imgPath)
    --红点上显示数字
    -- local redSize = redNode:getContentSize()
    -- local redText = ccui.Text:create("5","fonts/round_body.ttf",30)
    -- redText:setPosition(cc.p(redSize.width/2,redSize.height/2))
    -- redText:addTo(redNode)
    -- redText:setName("redText")

    local redNode = cc.Node:create()
    local redSpine = sp.SkeletonAnimation:create("client/res/spine/xiaohongdian.json","client/res/spine/xiaohongdian.atlas", 1)        
    redSpine:addTo(redNode)
    redSpine:setAnimation(0, "daiji", true)

    local pSize = cc.size(60, 60)
    if pNode.getContentSize then
        pSize = pNode:getContentSize()
    end
    pos = pos or cc.p(0, 0)
    pNode:addChild(redNode)
    redNode:setName("redPointNode")
    redNode:setPosition(cc.p(pSize.width - pos.x - 80, pSize.height - pos.y))
    redNode:hide()


    local redHandler = function(_Node, _isShow,_count)
        if _count then
            -- redText:setString(_count)
        end
        --print("redPointMgr redHandler", _isShow)
        if _isShow then
            _Node:show()
        else
            _Node:hide()
        end
    end
    self:registerEvent(eventTypeName, redNode, redHandler)
    self:checkStatus()
end

--注册红点事件
function redPointMgr:registerEvent(eventName, pNode, callback)
    self.redListener[eventName] = self.redListener[eventName] or {}
    local bindData = {
        target = pNode,
        callback = callback,
    }
    table.insert(self.redListener[eventName], bindData)
end

--分发对应的红点事件
function redPointMgr:__dispatch(eventName, isShow,count)
    local list = self.redListener[eventName] or {}
    --print("redPointMgr __dispatch", _isShow, eventName)
    for i = #list, 1, -1 do
        if type(list[i]) == "table" then
            if redPointMgr.g_isBadObj(list[i].target) then
                table.remove(list, i)
            else
                list[i].callback(list[i].target, isShow,count)
            end
        end
    end
end

redPointMgr.g_isBadObj = function(p_obj)
    local __type = type(p_obj)
    if __type == "table" then
        return false
    elseif __type == "userdata" then
        return tolua.isnull(p_obj)
    else
        return true
    end
end

return redPointMgr
