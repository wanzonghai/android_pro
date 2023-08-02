-- 一列糖果节点

local module_pre = "game.yule.bonanza.src"
local GameItem = appdf.req(module_pre .. ".views.layer.GameItem")
local ExternalFun = g_ExternalFun --require(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local ItemList = class("ItemList", cc.Layer) 

local scheduler = cc.Director:getInstance():getScheduler()

local emGameState =
{
    "WAIT",         --等待            0
    "START",        --等待服务器响应   1
    "RUN",          --转动            2
    "END",          --结算            3
}

local ITEM_STATE = ExternalFun.declarEnumWithTable(0, emGameState)

function ItemList:ctor(_index)
    tlog("ItemList:ctor ", _index)
    ExternalFun.registerNodeEvent(self)
    self.m_cbState = ITEM_STATE.WAIT
    self.m_cbItemData = {}
    self.m_Item = {}
    self.m_indexShow = _index --打日志用
    for i = 1, GameLogic.ITEM_Y_COUNT do
        local item = GameItem:create()
        -- item:setItemType(0)
        item:addTo(self)
        item:setTag(i)
        item:setPosition(self:getItemPosition(i))
        self.m_Item[i] = item
        table.insert(self.m_cbItemData, 1)
    end
end

function ItemList:Begin(callback)
    tlog("itemlist:Begin ", self.m_indexShow)
    if self.m_cbState == ITEM_STATE.START then 
        return
    end
    self.m_cbState = ITEM_STATE.START
    self:onStart(callback)
end

function ItemList:End()
    tlog("itemlist:End ", self.m_indexShow)
    if self.m_cbState ~= ITEM_STATE.START then 
        return
    end
    self.m_cbState = ITEM_STATE.END
    self:onEnd()
end

function ItemList:Stop()

end

function ItemList:changeItemZorder(item, itemType)
    if itemType <= GameLogic.ITEM_LIST.ITEM_ICON8 then
        item:setLocalZOrder(0)
    else
        item:setLocalZOrder(1)
    end
end

--开始滚动到界面下方
function ItemList:onStart(callback)
    tlog('ItemList:onStart ', self.m_indexShow)
    if callback == nil or type(callback) ~= "function" then 
        callback = function() end
    end
    for i = 1, GameLogic.ITEM_Y_COUNT do
        local item = self.m_Item[i]        
        if not item then
            item = GameItem:create()
            item:setItemType(self.m_cbItemData[i])
            if self.m_cbItemData[i] <= GameLogic.ITEM_LIST.ITEM_ICON8 then
                item:addTo(self, 0)
            else
                item:addTo(self, 1)
            end
            item:setTag(i)
            self.m_Item[i] = item
        end
        item:stopAllActions()
        item:setPosition(self:getItemPosition(i)) 

        local move = cc.EaseSineIn:create(cc.MoveBy:create(0.15 + i * 0.02, cc.p(0, -GameLogic.TOTAL_HEIGHT)))
        item:runAction(cc.Sequence:create(move, cc.CallFunc:create(function()
            if i == GameLogic.ITEM_Y_COUNT then
                callback()
            end
        end)))
    end
end

--从界面上方开始向下滚动
function ItemList:onEnd()
    tlog('ItemList:onEnd ', self.m_indexShow, self.m_cbState)
    self:changeItemShow()
    for i = 1, GameLogic.ITEM_Y_COUNT do
        local item = self.m_Item[i]
        local posX, posY = self:getItemPosition(i)
        item:setPosition(posX, posY + GameLogic.TOTAL_HEIGHT)
        local move = cc.EaseSineOut:create(cc.MoveTo:create(0.15, cc.p(posX, posY)))
        item:runRotate(0.2)
        local _time = i * 0.08
        if i == GameLogic.ITEM_Y_COUNT then
            item:runAction(cc.Sequence:create(cc.DelayTime:create(_time), move, cc.CallFunc:create(self._callback)))
        else
            item:runAction(cc.Sequence:create(cc.DelayTime:create(_time), move))
        end
    end
end

--修改item显示最新的结果
function ItemList:changeItemShow()
    tlog('ItemList:changeItemShow ', self.m_indexShow)
    for i = 1, GameLogic.ITEM_Y_COUNT do
        local item = self.m_Item[i]
        if not item then
            item = GameItem:create()
            item:setItemType(self.m_cbItemData[i])
            if self.m_cbItemData[i] <= GameLogic.ITEM_LIST.ITEM_ICON8 then
                item:addTo(self,0)
            else
                item:addTo(self,1)
            end
            item:setTag(i)
            item:setPosition(self:getItemPosition(i))
        else
            item:setItemType(self.m_cbItemData[i])
            self:changeItemZorder(item, self.m_cbItemData[i])
        end
    end
end

function ItemList:setItemData(tab)
    tlog('ItemList:setItemData ', self.m_indexShow)
    tdump(tab, 'ItemList:setItemData ', 10)
    if not tab then
        return
    end
    self.m_cbItemData = {}
    for i = 1, GameLogic.ITEM_Y_COUNT do
        table.insert(self.m_cbItemData, 1, tab[i])
    end
end

function ItemList:setInitIconType(tab)
    tlog('ItemList:setInitIconType ', self.m_indexShow)
    self.m_cbState = ITEM_STATE.WAIT
    for i = 1, GameLogic.ITEM_Y_COUNT do
        local item = self.m_Item[i]
        if item then
            item:stopAllActions()
            item:setItemType(tab[i])
            item:setPosition(self:getItemPosition(i))
            self:changeItemZorder(item, tab[i])
        end
    end
end

function ItemList:setItemStatus(tab)
    tlog('ItemList:setItemStatus ', self.m_indexShow)
    if not tab then
        return 
    end
    self.m_itemStatus = {}
    for i = 1, GameLogic.ITEM_Y_COUNT do
        table.insert(self.m_itemStatus, 1, tab[i])
    end
end

--物品播放消除动画,有免费的不消失
function ItemList:changeItemStatusAct()
    tlog('ItemList:changeItemStatusAct ', self.m_indexShow)
    for i = 1, GameLogic.ITEM_Y_COUNT do
        local item = self.m_Item[i]
        if self.m_itemStatus[i] ~= 0 then
            item:setWinEffect()
        end
    end
end

function ItemList:setCallBack(callback)
    tlog('ItemList:setCallBack ', self.m_indexShow, callback)
    if callback == nil then
        self._callback = function() end
    else 
        self._callback = callback
    end
end

--下落消除，此时的status还是上一屏的
function ItemList:runDeleteGame()
    tlog('ItemList:runDeleteGame ', self.m_indexShow)
    local totalLength = GameLogic.ITEM_Y_COUNT * 2
    local state = {}  --多一倍
    local needFlush = false
    for i = 1, totalLength do
        if i <= GameLogic.ITEM_Y_COUNT then
            local status = self.m_itemStatus[i]
            status = (status == 1)
            state[i] = status
            if status then
                needFlush = true
            end
        else
            state[i] = false
        end
    end

    if not needFlush then
        tlog("not needFlush")
        return
    end
    tdump(state, "state", 10)
    --重设上一波爆炸消失的格子的位置到屏幕上方去
    local itemCount = 1
    for i = 1, totalLength do
        if state[i] == false and itemCount <= GameLogic.ITEM_Y_COUNT then
            local item = self.m_Item[itemCount]
            local posX, posY = self:getItemPosition(i)
            if not item then
                item = GameItem:create()
                item:setItemType(0)
                item:addTo(self)
                item:setTag(itemCount)
                item:setPosition(cc.p(posX, posY))
                self.m_Item[itemCount] = item
            end
            -- if posY > GameLogic.TOTAL_HEIGHT then
                item:setItemType(self.m_cbItemData[itemCount])
                self:changeItemZorder(item, self.m_cbItemData[itemCount])
            -- end
            item:setPosition(cc.p(posX, posY))
            itemCount = itemCount + 1
        end
    end

    itemCount = 0
    local lastMoveItemNum = 0 --原面板上没有被消除需要移动的格子数
    local moveDate = {}
    for i = 1, totalLength do
        if state[i] == false then
            itemCount = itemCount + 1
            local data = {}
            data.index = itemCount
            data.movedis = i - itemCount
            moveDate[itemCount] = data
            if i <= GameLogic.ITEM_Y_COUNT then
                lastMoveItemNum = lastMoveItemNum + 1
            end
        end
    end
    tlog('lastMoveItemNum is ', lastMoveItemNum)
    tdump(moveDate, "moveDate", 10)
    --消除之后当前面板上在上方的落到相应的位置
    for i = 1, lastMoveItemNum do
        local data = moveDate[i]
        local item = self.m_Item[data.index]
        if item then
            if data.movedis ~= 0 then
                local posX, posY = self:getItemPosition(i)
                item:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.05 * i),
                    cc.MoveTo:create(0.03 * data.movedis, cc.p(posX, posY))))
                item:runRotate(0.05 * i)
            end
        end
    end
    --新的格子从上方落下
    local _Delaytime = 0.5
    for i = (lastMoveItemNum + 1), #moveDate do 
        local data = moveDate[i]
        local item = self.m_Item[data.index]
        if item then
            if data.movedis ~= 0 then
                local delayTime = cc.DelayTime:create(_Delaytime + 0.05 * i)
                local posX, posY = self:getItemPosition(i)
                local moveTo = cc.MoveTo:create(0.04 * data.movedis, cc.p(posX, posY))
                if data.index == GameLogic.ITEM_Y_COUNT then
                    local callFunc = cc.CallFunc:create(self._callback)
                    item:runAction(cc.Sequence:create(delayTime, moveTo, callFunc))
                    print("callback")
                else
                    item:runAction(cc.Sequence:create(delayTime, moveTo))
                end
                item:runRotate(_Delaytime + 0.05 * i)
            end
        end
    end
end

--获取一个格子应该被设置的位置
function ItemList:getItemPosition(_index)
    local posX = GameLogic.ITEM_WIDTH * 0.5
    local posY = GameLogic.ITEM_HEIGHT * (_index - 0.5) --min y is GameLogic.ITEM_HEIGHT * 0.5
    return posX, posY
end

function ItemList:showLastBombEffect(_index, _parentNode)
    tlog('ItemList:showLastBombEffect ', self.m_indexShow)
    local item = self.m_Item[_index]
    if item then
        item:showLastBombEffect(_parentNode)
    end
end

return ItemList