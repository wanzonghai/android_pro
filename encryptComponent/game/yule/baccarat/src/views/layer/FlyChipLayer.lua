---飞筹码层

local spriteFrameCache = cc.SpriteFrameCache:getInstance()
local FlyChipLayer = class("FlyChipLayer", cc.Layer)
local ChipSprite = class("ChipSprite", cc.Sprite)

---一个配置表，方便外部复制使用
FlyChipLayer.CONF = {
    chip_plist = nil,
    chip_png = nil,
    img_fly_ = "game/yule/baccarat/res/GUI/chips/bjl_smallchip_cash_%d.png",--"smallchip_bet_%d.png", -- 1~6
    sound_fly = "gameCommonRes/audio/sound/bet_chip.mp3",
    sound_gap = 0.2,

    open_schedule = true,   --开启定时器，如果想由外部驱动update，置为 false
    max_speed = 46,     --最大飞行速度
    acc_speed = 50,     --加速度
    frame_rate = 60,    --游戏帧数
    acc_scale = 0.04,
    float_scale = 0.02,
}


function FlyChipLayer:ctor(conf)
    self.m_conf = conf or FlyChipLayer.CONF
    self.m_areas = {}                   --下注区域
    self.m_idleChips = {}               --闲置的筹码
    self.m_flyChips = {}                --工作的筹码
    self.m_idleNums = 0                 --计数筹码总量，动态调整保留筹码数
    self.m_sound_gap_time = 0
    self.m_toAreaCount = 0
    self.m_randomPt = nil
    self.m_chipCount = {1,2,3,4,5,6}
    self:registerScriptHandler(function(event)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
        end
    end)
end

---添加一个投注区域
---@param key any @区域键值
---@param area any @区域
function FlyChipLayer:addArea(key, area)
    if key and area then
        if not self.m_areas[key] then
            self.m_areas[key] = area
        else
           print("重复添加相同key的区域")
        end
    else
        print("添加区域参数错误")
    end
end

---移除一个区域，不作检查
function FlyChipLayer:removeArea(key)
    self.m_areas[key] = nil
end

---获取一个区域
function FlyChipLayer:getArea(key, isError)
    if not self.m_areas[key] and isError then
        print("没有这个区域 %s", key)
    end
    return self.m_areas[key]
end

---获取一个区域内的随机点，处理不规则区域覆写此函数
function FlyChipLayer:getRandomPtForArea(areaKey)
    local area = self:getArea(areaKey)
    if area and area ~= 0 then
        return cc.p(area.x + math.random() * area.width, area.y + math.random() * area.height)
    else
        return cc.p(0, 0)
    end
end

---由外部设置区域内随机点，将优先使用这个Point，用完由外部置nil
function FlyChipLayer:setAreaRandomPt(point)
    self.m_randomPt = point
end

---检查筹码类型范围
function FlyChipLayer:checkChipType(chipType, isError)
    for i,v in pairs(self.m_chipCount) do 
        if v == chipType then
            return true
        end
    end
    return false
end

---获得一个普通筹码
---@param chipType number @筹码类型，1起始
---@param chipSprite gameCommon.ChipSprite @筹码精灵
---@return gameCommon.ChipSprite
function FlyChipLayer:makeChip(chipType, chipSprite)
    chipSprite = chipSprite or ChipSprite:create()
    if self:checkChipType(chipType, true) then
        chipSprite:setSpriteFrame(spriteFrameCache:getSpriteFrame(string.format(self.m_conf.img_fly_, chipType)))
    end
    return chipSprite
end

---获取一个飞翔筹码
---@param chipType number @筹码类型，1起始
---@param deskStation number @座位号
---@return gameCommon.ChipSprite
function FlyChipLayer:getFlyChip(chipType, deskStation)
    local chip = self:makeChip(chipType, table.remove(self.m_idleChips, 1))
    if not chip:getParent() then
        self:addChild(chip)
    end
    table.insert(self.m_flyChips, chip)
    chip:setTag(chipType)
    chip.m_deskStation = deskStation
    return chip
end

---工作结束重置飞翔数据
function FlyChipLayer:reset()
    table.insertto(self.m_idleChips, self.m_flyChips)
    self.m_flyChips = {}

    local prevNums = self.m_idleNums
    self.m_idleNums = #self.m_idleChips
    if prevNums ~= 0 then
        local dist = self.m_idleNums - prevNums
        if dist < 0 then
            --筹码没有增长的情况下，移除多出部分的一定比例筹码
            local removeNum = math.floor(math.abs(dist) / 3)
            for i = 1, removeNum do
                local chip = table.remove(self.m_idleChips, i)
                if chip then
                    chip:removeFromParent()
                    chip = nil
                end
            end
        end
    end

    for k, chip in pairs(self.m_idleChips) do
        chip.m_needUpdate = false
        chip:setVisible(false)
        chip:setPosition(0, 0)
        chip:setLocalZOrder(0)
    end
    self.m_toAreaCount = 0
end

---飞到一个点
---@param chip gameCommon.ChipSprite @飞行筹码
---@param aimPoint any @飞行目标点
---@param oriScale number @出发时的缩放值
---@param aimScale number @到达时的缩放值
function FlyChipLayer:flyToPoint(chip, aimPoint, oriScale, aimScale)
    chip.m_aimPoint = aimPoint or cc.p(0, 0)
    chip.m_oriScale = oriScale or 1
    chip.m_aimScale = aimScale or 1
    chip:setScale(chip.m_oriScale)
    chip.m_speed = 0
    chip.m_needUpdate = true
    chip:setVisible(true)
    chip.m_tR = 20 + math.random(40)
    chip.m_areaKey = nil
end

---飞到一个区域随机点
---@param needFly boolean @是否飞翔至目标区域
---@param chip gameCommon.ChipSprite
---@param areaKey number
function FlyChipLayer:toArea(needFly, chip, areaKey, oriScale, aimScale)
    local area = self:getArea(areaKey, true)
    if area then
        local randomPt = self.m_randomPt or self:getRandomPtForArea(areaKey)
        if needFly == false then
            chip:setPosition(randomPt)
            chip:setRotation(math.random(360))
        end
        self:flyToPoint(chip, randomPt, oriScale, aimScale)
        chip.m_areaKey = areaKey
        self.m_toAreaCount = self.m_toAreaCount + 1
        chip:setLocalZOrder(self.m_toAreaCount)
    end
end

function FlyChipLayer:getChipsByAreaKey(areaKey)
    local chips = {}
    for k, chip in pairs(self.m_flyChips) do
        if chip.m_areaKey == areaKey then
            table.insert(chips, chip)
        end
    end
    return chips
end

function FlyChipLayer:playFlyAudio(id)
    if self.m_sound_gap_time <= 0 then
        self.m_sound_gap_time = self.m_conf.sound_gap
        id = id or 1
        if id == 1 then
            g_ExternalFun.playEffect(self.m_conf.sound_fly)
        elseif id == 2 then
            if self.m_conf.sound_betend then
                g_ExternalFun.playEffect(self.m_conf.sound_betend)
            end
        end
    end
end

function FlyChipLayer:update(dt)
    if self.m_sound_gap_time > 0 then
        self.m_sound_gap_time = self.m_sound_gap_time - dt
    end

    if #self.m_flyChips > 0 then
        local function cb(chip)
            local len = #self.m_flyChips
            for i = 1, len do
                local idx = len - i + 1
                if self.m_flyChips[idx] and not self.m_flyChips[idx].m_needUpdate and not self.m_flyChips[idx].m_areaKey then
                    local chip = table.remove(self.m_flyChips, idx)
                    table.insert(self.m_idleChips, chip)
                    chip:setVisible(false)
                end
            end

            --self:playFlyAudio(2)
        end

        for k, chip in pairs(self.m_flyChips) do
            if chip.m_needUpdate == true then
                self:updateChip(chip, dt, cb)
            end
        end
    end
end

---筹码飞翔逻辑
---配合makeChip、flyToPoint 使用，可以使筹码在不同的层飞翔
---@param chip gameCommon.ChipSprite
---@param dt number @帧间隔用时，用来修正掉帧速度
function FlyChipLayer:updateChip(chip, dt, callback)
    if chip.m_needUpdate == false then
        return
    end
    local conf = self.m_conf
    local px, py = chip:getPosition()
    local dx = chip.m_aimPoint.x - px
    local dy = chip.m_aimPoint.y - py
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < 1 then
        --进入这里就是运动达成了
        chip.m_needUpdate = false
        chip:setPosition(chip.m_aimPoint)
        if chip.m_oriScale ~= chip.m_aimScale then
            chip:setScale(chip.m_aimScale)
        end
        if callback then
            callback(chip)
        end
    else
        if dist < chip.m_tR then
            --进入这里就是要减速到达目标点了
            chip:setPosition(px + dx / 4, py + dy / 4)
            local rotation = chip:getRotation()
            if dx > 0 then
                chip:setRotation(rotation + 10)
            else
                chip:setRotation(rotation - 10)
            end
            if chip.m_oriScale ~= chip.m_aimScale then
                local scale = chip:getScale()
                chip:setScale(scale + (chip.m_aimScale + conf.float_scale - scale) / 4)
            end
        else
            --进入这里就是正在加速至满速飞翔
            local maxSpeed = conf.max_speed
            if dt ~= nil and dt > 0 then
                maxSpeed = dt / (1 / conf.frame_rate) * conf.max_speed
            end
            chip.m_speed = math.min(maxSpeed, chip.m_speed + conf.acc_speed)
            local moveDist = math.min(dist, chip.m_speed)
            local radian = math.atan2(dy, dx)
            local mx = math.cos(radian) * moveDist
            local my = math.sin(radian) * moveDist
            chip:setPosition(px + mx, py + my)

            if chip.m_oriScale ~= chip.m_aimScale then
                local scale = chip:getScale()
                local forgeAimScale = chip.m_aimScale + conf.float_scale
                local scaleDist = forgeAimScale - scale
                if scaleDist ~= 0 then
                    if chip.m_oriScale < chip.m_aimScale then
                        scale = scale + conf.acc_scale
                        if scale >= forgeAimScale then
                            chip:setScale(forgeAimScale)
                        else
                            chip:setScale(scale)
                        end
                    else
                        scale = scale - conf.acc_scale
                        if scale <= forgeAimScale then
                            chip:setScale(forgeAimScale)
                        else
                            chip:setScale(scale)
                        end
                    end
                end
            end
        end
    end
end

function FlyChipLayer:onEnter()
    if self.m_conf.chip_plist then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(self.m_conf.chip_plist)
    end

    if self.m_conf.open_schedule then
        self.m_scheduleUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.update), 0, false)
    end
end

function FlyChipLayer:onExit()
    if nil ~= self.m_scheduleUpdate then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduleUpdate)
        self.m_scheduleUpdate = nil
    end
    if self.m_conf.chip_plist then
        cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(self.m_conf.chip_plist)
    end
    package.loaded["gameCommon.FlyChipLayer"] = nil;
end

--------------------
--- class ChipSprite
--------------------

function ChipSprite:ctor()
    self.m_deskStation = nil
    self.m_areaKey = nil
    self.m_aimPoint = nil
    self.m_oriScale = nil
    self.m_aimScale = nil
    self.m_speed = nil
    self.m_needUpdate = nil
    self.m_tR = nil
end

function ChipSprite:getDeskStation()
    return self.m_deskStation
end

function ChipSprite:getAreaKey()
    return self.m_areaKey
end

function ChipSprite:isNeedUpdate()
    return self.m_needUpdate
end


return FlyChipLayer