-- 嘉年华 4*5物品层
local CarnivalScrollLayer = class("CarnivalScrollLayer", function()
    local layer = display.newLayer()
    return layer
end)
local module_pre = "game.yule.carnival.src"
local CarnivalItemList = appdf.req(module_pre .. ".views.layer.CarnivalItemList")
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local CarnivalTurnConfig = appdf.req(module_pre .. ".models.CarnivalTurnConfig")
local g_scheduler = cc.Director:getInstance():getScheduler()

function CarnivalScrollLayer:ctor()
    tlog('CarnivalScrollLayer:ctor')
    self.m_itemList = {}
    for i = 1, GameLogic.ITEM_X_COUNT do
        local itemlist = CarnivalItemList:create(i)
        itemlist:addTo(self)
        itemlist:setPosition(cc.p(GameLogic.ITEM_WIDTH * (i - 1), 0))
        itemlist:setTag(i)
        self.m_itemList[i] = itemlist
    end
end

function CarnivalScrollLayer:onExit()
    tlog('CarnivalScrollLayer:onExit')
    self:stopScheduleEvent()
end

function CarnivalScrollLayer:stopScheduleEvent()
    if nil ~= self.m_scheduleUpdate then
        g_scheduler:unscheduleScriptEntry(self.m_scheduleUpdate)
        self.m_scheduleUpdate = nil
    end
end

function CarnivalScrollLayer:updateBroadIconShow(_sceneData)
    tlog('CarnivalScrollLayer:updateBroadIconShow')
    self:stopScheduleEvent()
    for i = 1, GameLogic.ITEM_X_COUNT do
        local tab = {}
        for j = GameLogic.ITEM_Y_COUNT, 1, -1 do
            table.insert(tab, _sceneData[j][i])
        end
        self.m_itemList[i]:initIconType(tab)
    end
end

function CarnivalScrollLayer:setRunItem(_data,callback)
    tlog('CarnivalScrollLayer:setRunItem')
    self:setData(_data)
    for i = 1, GameLogic.ITEM_X_COUNT do
        if i == GameLogic.ITEM_X_COUNT then
            self.m_itemList[i]:setCallBack(callback)
        else
            self.m_itemList[i]:setCallBack()
        end
    end
end

function CarnivalScrollLayer:setData(_data)
    tlog('CarnivalScrollLayer:setData')
    for i = 1, GameLogic.ITEM_X_COUNT  do
        local tab = {}
        for j = 1, GameLogic.ITEM_Y_COUNT do
            tab[j] = _data[j][i]
        end
        self.m_itemList[i]:setItemData(tab)
    end
end

function CarnivalScrollLayer:startRun(_speedFactor, _bonusIndex, _freeStatus, _bonusCall)
    tlog('CarnivalScrollLayer:startRun ', _speedFactor, _bonusIndex, _freeStatus)
    self:stopScheduleEvent()
    local endCall = function (_index)
        tlog('endCall is ', _index)
        local bonus = _bonusCall(_index)
        if bonus and _index < GameLogic.ITEM_X_COUNT then
            self.m_itemList[_index + 1]:superRollChangeSpeed()
        end
        if _index == GameLogic.ITEM_X_COUNT then
            self:stopScheduleEvent()
        end
    end
    local rollConfig = CarnivalTurnConfig.getRoundConfig(_freeStatus and 1 or 0)
    -- tdump(rollConfig, "rollConfig", 10)
    for i = 1, GameLogic.ITEM_X_COUNT do
        local speed = GameLogic.ITEM_MOVE_SPEED * _speedFactor
        --每一列总的旋转时间
        local maxRollTime = nil
        local bonusAddTime = GameLogic.TIME_ADD_BONUS
        if _speedFactor == 1 then
            maxRollTime = GameLogic.MOVE_TIME_NORMAL + (i - 1) * GameLogic.TIME_NORMAL_ADD
        else
            bonusAddTime = bonusAddTime * 0.5
            maxRollTime = GameLogic.MOVE_TIME_FAST
        end
        if _bonusIndex ~= 0 and i >= _bonusIndex then
            maxRollTime = maxRollTime + (i - _bonusIndex + 1) * bonusAddTime
        end
        self.m_itemList[i]:setStartRunData(speed, maxRollTime, rollConfig[i], endCall)
    end
    self.m_scheduleUpdate = g_scheduler:scheduleScriptFunc(handler(self, self.rollingUpdate), 0, false)
end

function CarnivalScrollLayer:rollingUpdate(dt)
    for i = 1, GameLogic.ITEM_X_COUNT do
        self.m_itemList[i]:rollingUpdate(dt)
    end
end

function CarnivalScrollLayer:setAllItemWin(StateDate, _aniCall)
    tlog('CarnivalScrollLayer:setAllItemWin ')
    for i = 1, GameLogic.ITEM_X_COUNT do
        local tab = {}
        for j = 1, GameLogic.ITEM_Y_COUNT do
            tab[j] = StateDate[j][i]
        end
        self.m_itemList[i]:setItemWinStatus(tab, _aniCall)
    end
end

function CarnivalScrollLayer:showAllItem()
    for i = 1, GameLogic.ITEM_X_COUNT do
        self.m_itemList[i]:showAllItem()
    end
end

--面具转化为其他图标
function CarnivalScrollLayer:setMaskedItemShow(_posArr, _maskType)
    tlog("CarnivalScrollLayer:setMaskedItemShow ", _posArr[1], _posArr[2], _maskType)
    self.m_itemList[_posArr[1]]:setMaskedItemShow(5 - _posArr[2], _maskType)
end

--开始转动后恢复面具图标
function CarnivalScrollLayer:recoveryMaskedItem()
    for i = 1, GameLogic.ITEM_X_COUNT do
        self.m_itemList[i]:recoveryMaskedItem()
    end
end

function CarnivalScrollLayer:stopAllItemAction()
    self:stopScheduleEvent()
    for i = 1, GameLogic.ITEM_X_COUNT do
        self.m_itemList[i]:changeItemShowDirector()
    end
end

return CarnivalScrollLayer