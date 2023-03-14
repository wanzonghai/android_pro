-- bonanza 6*5物品层

local module_pre = "game.yule.bonanza.src"
local ItemList = appdf.req(module_pre .. ".views.layer.ItemList")
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local ScrollLayer = class("ScrollLayer", function()
    local layer = display.newLayer()
    return layer
end )
local scheduler = cc.Director:getInstance():getScheduler()

function ScrollLayer:ctor()
    tlog('ScrollLayer:ctor')
    self.m_bStart = false
    self.m_bReady = false

    self.m_itemData = {}
    self.m_itemState = {}
    self:initItem()

    local function update(dt)
        if self.m_bStart == true and self.m_bReady == true then
            self.m_bStart = false
            self.m_bReady = false
            for i = 1, GameLogic.ITEM_X_COUNT do
                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.08 * i), cc.CallFunc:create(function()
                    self.m_ItemList[i]:End()
                end)))
            end
        end
    end

    -- 游戏定时器
    if nil == self.m_scheduleUpdate then
        self.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0, false)
    end
end

function ScrollLayer:onExit()
    tlog('ScrollLayer:onExit')
    if nil ~= self.m_scheduleUpdate then
        scheduler:unscheduleScriptEntry(self.m_scheduleUpdate)
        self.m_scheduleUpdate = nil
    end
end

function ScrollLayer:initItem()
    tlog('ScrollLayer:initItem')
    self.m_ItemList = {}
    for i = 1, GameLogic.ITEM_X_COUNT do
        local itemlist = ItemList:create(i)
        itemlist:addTo(self)
        itemlist:setPosition(cc.p(GameLogic.ITEM_WIDTH * (i - 1), 0))
        itemlist:setTag(i)
        self.m_ItemList[i] = itemlist
    end
end

function ScrollLayer:setGameSceneData(_sceneData)
    tlog('ScrollLayer:setGameSceneData')
    if _sceneData == nil then
        return
    end
    self.m_bStart = false
    self.m_bReady = false
    self:stopAllActions()
    for i = 1, GameLogic.ITEM_X_COUNT do
        local tab = {}
        for j = GameLogic.ITEM_Y_COUNT, 1, -1 do
            table.insert(tab, _sceneData[j][i])
        end
        self.m_ItemList[i]:setInitIconType(tab)
    end
end

function ScrollLayer:setData(_data)
    tlog('ScrollLayer:setData')
    self.m_itemData = _data
    for i = 1, GameLogic.ITEM_X_COUNT  do
        local tab = {}
        for j = 1, GameLogic.ITEM_Y_COUNT do
            tab[j] = self.m_itemData[j][i]
        end
        self.m_ItemList[i]:setItemData(tab)
    end
end

function ScrollLayer:setRunItem(_data,callback)
    tlog('ScrollLayer:setRunItem')
    self:setData(_data)
    for i = 1, GameLogic.ITEM_X_COUNT  do
        if i==GameLogic.ITEM_X_COUNT then
            self.m_ItemList[i]:setCallBack(callback)
        else
            self.m_ItemList[i]:setCallBack()
        end
    end
    self.m_bStart = true
end

function ScrollLayer:run()
    tlog('ScrollLayer:run')
    function callback ()
        self.m_bReady = true
    end
    self.m_bReady = false
    for i = 1, GameLogic.ITEM_X_COUNT do
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2 + 0.05 *(i - 1)), cc.CallFunc:create(function()
            self.m_ItemList[i]:Begin(i==GameLogic.ITEM_X_COUNT and callback or function()end)
            if i == 1 then
                g_ExternalFun.playSoundEffect("bonanza_roll.mp3")
            end
        end)))
    end
end

function ScrollLayer:ItemStop()
    tlog('ScrollLayer:ItemStop')
    for i = 1, GameLogic.ITEM_X_COUNT do
        self.m_ItemList[i]:Stop()
    end
end

function ScrollLayer:setAllItemWin(StateDate)
    tlog('ScrollLayer:setAllItemWin ')
    self.m_itemState = StateDate
    for i = 1, GameLogic.ITEM_X_COUNT do
        local tab = {}
        for j = 1, GameLogic.ITEM_Y_COUNT do
            tab[j] = StateDate[j][i]
        end
        self.m_ItemList[i]:setItemStatus(tab)
        self.m_ItemList[i]:changeItemStatusAct()
    end
end

--元素开始二次掉落
function ScrollLayer:runDeleteGame(_data, callback)
    tlog('ScrollLayer:runDeleteGame')
    self:setData(_data)
    local num = 0
    local state = {}
    for i = 1, GameLogic.ITEM_X_COUNT do        
        local hasDisappear = false --这一列是否有消除的
        for j = 1, GameLogic.ITEM_Y_COUNT do
            if self.m_itemState[j][i] == 1 then
                hasDisappear = true
                break
            end
        end
        state[i] = hasDisappear
        if hasDisappear then
            num = num + 1
        end
    end
    tdump(state, "state", 10)
    local bCall = true
    local temptime = 0
    for i = GameLogic.ITEM_X_COUNT, 1, -1 do     
        if bCall and state[i] then
            bCall = false
            self.m_ItemList[i]:setCallBack(callback)
        else
            self.m_ItemList[i]:setCallBack()
        end
        if state[i] then
            temptime = num * 0.05 + 0.05
            num = num - 1
        end
        tlog("temptime num is ", temptime, num)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(temptime), cc.CallFunc:create(function ()
            self.m_ItemList[i]:runDeleteGame()
        end)))
    end
    g_ExternalFun.playSoundEffect("bonanza_delete.mp3")
end

--免费游戏内一局游戏最后如果有爆炸元素，播放爆炸效果
function ScrollLayer:showLastBombEffect(_parentNode)
    tlog('ScrollLayer:showLastBombEffect')
    for i = 1, GameLogic.ITEM_X_COUNT do        
        for j = 1, GameLogic.ITEM_Y_COUNT do
            if self.m_itemState[j][i] == 3 then
                tlog("cur index is ", i, j)
                --j是从上到下计算的，但是item的列表是从下到上的
                self.m_ItemList[i]:showLastBombEffect(GameLogic.ITEM_Y_COUNT - j + 1, _parentNode)
            end
        end
    end
end

return ScrollLayer