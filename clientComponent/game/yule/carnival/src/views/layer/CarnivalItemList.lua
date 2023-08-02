-- 嘉年华 一列节点
local module_pre = "game.yule.carnival.src"
local CarnivalItem = appdf.req(module_pre .. ".views.layer.CarnivalItem")
local CarnivalItemList = class("CarnivalItemList", cc.Node) 
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")

local move_status =
{
    status_normal = 0,      --停止阶段
    status_move = 1,        --滚动阶段
    status_over = 2,        --滚动收尾阶段，设置最终结果展示
    status_end = 3,         --滚动到最底部位置阶段
    status_total_end = 4    --回弹阶段
}

function CarnivalItemList:ctor(_index)
    tlog("CarnivalItemList:ctor ", _index)
    self.m_cbItemData = {} --数据是从下到上记录的
    self.m_itemArray = {}
    self.m_indexShow = _index --打日志用
    for i = 1, GameLogic.ITEM_Y_COUNT + 1 do --多一个用于滚动
        self:initSpriteIcon(i, 1)
        table.insert(self.m_cbItemData, 1)
    end
    self:initData()
end

function CarnivalItemList:initData()
    self.m_rollTime = 0             --总的滚动时间
    self.m_speed = 0                --速度
    self.m_changeNums = 1           --设置最终结果的个数
    self.m_stopCall = nil           --停止回调
    self.m_curRollConfig = nil      --滚动图片配置
    self.m_curRollIndex = 1         --滚动图片序号
    self.m_stopStatus = move_status.status_normal
    self.m_lastLength = 0           --滚动到最底部需要的距离
end

function CarnivalItemList:initSpriteIcon(_posIndex, _iconIndex)
    -- local item = cc.Sprite:createWithSpriteFrameName(string.format("jnh_icon_%d.png", _iconIndex))
    local item = CarnivalItem:create(_iconIndex)
    item:addTo(self)
    item:setPosition(GameLogic:getItemPosition(1, _posIndex))
    self.m_itemArray[_posIndex] = item
    return item
end

function CarnivalItemList:initIconType(tab)
    tlog('CarnivalItemList:initIconType ', self.m_indexShow)
    self:initData()
    for i = 1, GameLogic.ITEM_Y_COUNT + 1 do
        local item = self.m_itemArray[i]
        if item then
            item:stopAllActions()
            item:setVisible(true)
            local iconType = 1
            if i <= GameLogic.ITEM_Y_COUNT then
                iconType = tab[i]
            end
            item:setNormalItemShow(iconType)
            item:setPosition(GameLogic:getItemPosition(1, i))
            item:setPosIndex(0)
        end
    end
end

function CarnivalItemList:setItemData(tab)
    tlog('CarnivalItemList:setItemData ', self.m_indexShow)
    -- tdump(tab, 'CarnivalItemList:setItemData ', 10)
    self.m_cbItemData = {}
    for i = 1, GameLogic.ITEM_Y_COUNT do
        table.insert(self.m_cbItemData, 1, tab[i])
    end
end

--有赢分的时候处理图片，a及以下不隐藏，以上隐藏播放动画
-- tab的1-4是从上到下的，item的1-4是从下到上的
function CarnivalItemList:setItemWinStatus(tab, _aniCall)
    tlog('CarnivalItemList:setItemWinStatus ', self.m_indexShow)
    for i = 1, GameLogic.ITEM_Y_COUNT do
        local itemIndex = 5 - i
        tlog("iii is ", tab[i], i, itemIndex)
        if tab[i] ~= 0 then
            local showType = self.m_itemArray[itemIndex]:getMaskType()
            if showType > GameLogic.ITEM_LIST.ITEM_ICON5 then
                self.m_itemArray[itemIndex]:setVisible(false)
            end
            _aniCall(showType, {self.m_indexShow, itemIndex})
        end
    end
end

function CarnivalItemList:showAllItem()
    for i = 1, GameLogic.ITEM_Y_COUNT + 1 do
        self.m_itemArray[i]:setVisible(true)
    end
end

function CarnivalItemList:setMaskedItemShow(_index, _maskType)
    self.m_itemArray[_index]:setMaskedItemShow(_maskType)
end

function CarnivalItemList:recoveryMaskedItem()
    for i = 1, GameLogic.ITEM_Y_COUNT do
        self.m_itemArray[i]:recoveryMaskedItem()
    end
end

function CarnivalItemList:setCallBack(callback)
    tlog('CarnivalItemList:setCallBack ', self.m_indexShow, callback)
    if callback == nil then
        self._callback = function() end
    else 
        self._callback = callback
    end
end

function CarnivalItemList:setStartRunData(_speed, _maxTime, _rollConfig, _stopCall)
    tlog("CarnivalItemList:setStartRunData ", self.m_indexShow, _speed, _maxTime)
    for i = 1, GameLogic.ITEM_Y_COUNT + 1 do
        self.m_itemArray[i]:setPosIndex(0) --位置标记复位
    end
    self.m_stopCall = _stopCall
    self.m_rollTime = _maxTime
    self.m_speed = _speed
    self.m_curRollConfig = _rollConfig
    self.m_curRollIndex = 1
    self.m_stopStatus = move_status.status_move
    self.m_lastLength = 0
end

--超级旋转加速
function CarnivalItemList:superRollChangeSpeed()
    tlog("CarnivalItemList:superRollChangeSpeed")
    self.m_speed = self.m_speed * 1.2
end

--旋转时的定时器
function CarnivalItemList:rollingUpdate(dt)
    if self.m_rollTime <= 0 then
        -- tlog('CarnivalItemList:rollingUpdate stop')
        if self.m_stopStatus == move_status.status_move then
            self.m_changeNums = 1
            self.m_stopStatus = move_status.status_over
        end
        self:stopingUpdate(dt)
    else
        self:changeItemShow(dt, true)
    end
    self.m_rollTime = self.m_rollTime - dt
end

--结束阶段定时器
function CarnivalItemList:stopingUpdate(dt)
    if self.m_changeNums <= GameLogic.ITEM_Y_COUNT then --轮番替换4张结果图片
        self:changeItemShow(dt, false)
    else
        local maxCount = GameLogic.ITEM_Y_COUNT + 1
        if self.m_stopStatus == move_status.status_over then
            self.m_stopStatus = move_status.status_end
            tlog('CarnivalItemList:stopingUpdate stop ', self.m_stopStatus)
            --全部替换完图片，使用一个动画结束旋转
            local firstIndex = nil --找到位置标记为1的节点
            for i = 1, maxCount do
                if self.m_itemArray[i]:getPosIndex() == 1 then
                    firstIndex = i
                    break
                end
            end
            --重置self.m_itemArray数组
            local newItem = {}
            for i = 1, maxCount do
                local curItemIndex = firstIndex + (i - 1)
                if curItemIndex > maxCount then
                    curItemIndex = curItemIndex - maxCount
                end
                newItem[i] = self.m_itemArray[curItemIndex]
            end
            self.m_itemArray = nil
            self.m_itemArray = newItem
            local posY = self.m_itemArray[1]:getPositionY()
            tlog("posY is ", posY)
            -- local finialPosY = GameLogic.ITEM_HEIGHT * 0.5
             --当前点到最终点的距离,再往下移动1/4格子
            self.m_lastLength = posY - GameLogic.ITEM_HEIGHT * 0.25 --finialPosY + finialPosY * 0.5
        end

        if self.m_stopStatus == move_status.status_end then
            local moveLength = self.m_speed * dt
            for i = 1, maxCount do
                local item = self.m_itemArray[i]
                local posY = item:getPositionY() - moveLength
                item:setPositionY(posY)
            end
            self.m_lastLength = self.m_lastLength - moveLength
            if self.m_lastLength <= 0 then
                self.m_stopStatus = move_status.status_total_end
            end
        end
        if self.m_stopStatus == move_status.status_total_end then
            self.m_stopStatus = move_status.status_normal
            local length = GameLogic.ITEM_HEIGHT * 0.25 - self.m_lastLength
            for i = 1, maxCount do
                local move1 = cc.MoveBy:create(0.1, cc.p(0, length))
                local endCall = cc.CallFunc:create(function (t, p)
                    t:setPosition(GameLogic:getItemPosition(1, p.index))
                    t:setVisible(true)
                    if p.index <= GameLogic.ITEM_Y_COUNT then
                        t:setNormalItemShow(self.m_cbItemData[p.index])
                    end
                end, {index = i})
                if i == maxCount then
                    local delay = cc.DelayTime:create(1 / 30)
                    local call = cc.CallFunc:create(function ()
                        if self.m_stopCall then
                            self.m_stopCall(self.m_indexShow)
                        end
                        self._callback()
                        self:initData() --最后重置数据
                        --一列停止音效
                        g_ExternalFun.playSoundEffect("carnival_normal_stop.mp3")
                    end)
                    self.m_itemArray[i]:runAction(cc.Sequence:create(move1, delay, endCall, call))
                else
                    self.m_itemArray[i]:runAction(cc.Sequence:create(move1, endCall))
                end
            end
        end
    end
end

function CarnivalItemList:changeItemShow(dt, _random)
    local moveLength = self.m_speed * dt
    for i = 1, GameLogic.ITEM_Y_COUNT + 1 do
        local item = self.m_itemArray[i]
        local posY = item:getPositionY() - moveLength
        -- 超出屏幕的放回顶部
        local lastYpos = GameLogic.ITEM_HEIGHT * 0.5
        if posY <= -lastYpos then
            item:setPositionY(GameLogic.TOTAL_HEIGHT + GameLogic.ITEM_HEIGHT + posY)
            local itemIndex = -1
            if _random then
                itemIndex = self.m_curRollConfig[self.m_curRollIndex] - 1
                self.m_curRollIndex = self.m_curRollIndex + 1
                if self.m_curRollIndex > #self.m_curRollConfig then
                    self.m_curRollIndex = 1
                end
            else
                itemIndex = self.m_cbItemData[self.m_changeNums]
                item:setPosIndex(self.m_changeNums)
                self.m_changeNums = self.m_changeNums + 1
            end
            if itemIndex == nil then
                itemIndex = 0
            end
            item:setNormalItemShow(itemIndex)
        else
            item:setPositionY(posY)
        end
    end
end

--修改item显示最新的结果
function CarnivalItemList:changeItemShowDirector(_index)
    tlog('CarnivalItemList:changeItemShow ', self.m_indexShow)
    self:initData()
    local maxCount = GameLogic.ITEM_Y_COUNT + 1
    for i = 1, maxCount do
        local itemType = 1
        if i <= GameLogic.ITEM_Y_COUNT then
            itemType = self.m_cbItemData[i]
        end
        local item = self.m_itemArray[i]
        if not item then
            item = self:initSpriteIcon(i, itemType)
        else
            item:setNormalItemShow(itemType)
        end
        item:stopAllActions()
        item:setVisible(true)
        item:setPosition(GameLogic:getItemPosition(1, i))
        local move = cc.MoveBy:create(0.1, cc.p(0, -GameLogic.ITEM_HEIGHT * 0.25))
        local move1 = cc.MoveBy:create(0.1, cc.p(0, GameLogic.ITEM_HEIGHT * 0.25))
        if i == maxCount then
            local delay = cc.DelayTime:create(1 / 30)
            local call = cc.CallFunc:create(function ()
                self._callback()
            end)
            self.m_itemArray[i]:runAction(cc.Sequence:create(move, move1, delay, call))
        else
            self.m_itemArray[i]:runAction(cc.Sequence:create(move, move1))
        end
    end
end

return CarnivalItemList