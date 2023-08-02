local math = math
local pow = math.pow

local runner = {}

local function lerp(from, to, alpha)
    return from * (1-alpha) + to * alpha
end

-- static inline float bezierat( float a, float b, float c, float d, float t )
local function bezierat( a, b, c, d, t )
    return (pow(1-t,3) * a + 3*t*(pow(1-t,2))*b + 3*pow(t,2)*(1-t)*c + pow(t,3)*d );
end

local function bezier_func(a,b,c,d,t)
    return pow(1-t, 3) * a + 3 * pow(1-t, 2) * t * b + 3*(1-t) *t*t*c + t*t*t*d
end
local deg = math.deg
local atan2 = math.atan2
local function angle(x1, y1, x2, y2)
    return 360-deg(atan2(y2-y1,x2-x1))
end

local speedOffset = 0.7

runner[1] = {
    init = function(fish)
        local path = fish.path
        local x = path.ori.x
        local y = path.ori.y
        fish:setPos(x,y)
        local deg = angle(0, 0, path.speed.x* speedOffset, path.speed.y * speedOffset)
        fish:setRotation(deg)
    end,

    step = function(fish, dt, time) -- 直线运动
        local x,y = fish:getPosition()

        x = x + dt * fish.path.speed.x * speedOffset
        y = y + dt * fish.path.speed.y * speedOffset

        fish:setPos(x, y)
    end,
}


runner[2] = {
    init = function(fish)
        local cfg = fish.path
        local x = cfg.ori.x
        local y = cfg.ori.y
        fish:setPos(x,y)
    end,

    step = function(fish, dt) -- 贝塞尔曲线运动方式
        local cfg = fish.path
        cfg.time = cfg.time + dt * cfg.speed.x * speedOffset

        --local x = bezier_func(cfg.ori.x, cfg.c1.x, cfg.c2.x, cfg.dst.x, cfg.time)
        --local y = bezier_func(cfg.ori.y, cfg.c1.y, cfg.c2.y, cfg.dst.y, cfg.time)
        local x,y = CCCalcuBezier(cfg.ori.x,cfg.ori.y,cfg.c1.x,cfg.c1.y,cfg.c2.x,cfg.c2.y,cfg.dst.x,cfg.dst.y,cfg.time)
        fish:setRotation(angle(fish.Xpos,fish.Ypos, x,y))
        fish:setPos(x, y)
    end,
}


local module_pre = "game.yule.dntg.src"      
local fish_path = require(module_pre .. ".models.cfg_fish_path")
local fish_body = require(module_pre .. ".models.cfg_fish_body")

local Fish = class("Fish", cc.Node)


function Fish:ctor(data)
    -- self:setCascadeColorEnabled(true)

    self.m_data = data
    self.bornTime = 0

    self.fish_kind = self.m_data.fish_kind
    self.fish_id = self.m_data.fish_id
end

function Fish:initPath()
    if self.m_data.path_id then
        self.path_id = self.m_data.path_id--轨迹路线的指引数
        self.path = clone(fish_path[self.path_id or 1])
        self.path.time = 0
        if self.m_data.path then
            self.path.ori.x = self.m_data.path.new_x or self.path.ori.x
            self.path.ori.y = self.m_data.path.new_y or self.path.ori.y

            if self.m_data.adjust_pos then
                self.path.dst.x = self.m_data.dst.x or self.path.dst.x
                self.path.dst.y = self.m_data.dst.y or self.path.dst.y    
                self.path.c1.x = self.m_data.c1.x or self.path.c1.x
                self.path.c1.y = self.m_data.c1.y or self.path.c1.y    
                self.path.c2.x = self.m_data.c2.x or self.path.c2.x
                self.path.c2.y = self.m_data.c2.y or self.path.c2.y              
            end
        end
        
    else
        self.path = self.m_data.path
        self.runner = runner[self.path.type]
        self:setPos(self.path.ori)
    end

    self.runner = runner[self.path.type]
    self.runner.init(self)
end

function Fish:setColor(color)
    local child = self:getChildByTag(2222)
    if child then
        local node = child:getChildByTag(1111)
        if node then
            node:setColor(color)
        end
    end
end

function Fish:goAway()
    self.path.speed.x = self.path.speed.x * 4
    self.path.speed.y = self.path.speed.y * 4
    self:getPhysicsBody():removeFromWorld()
end

function Fish:setPos(x, y)
    if not y then
        y = x.y
        x = x.x
    end

    self.Xpos = x
    self.Ypos = y
    self:setPosition(x, y)
end

function Fish:getT()
    return 1
end

function Fish:deadDeal()
	self:stopAllActions()
    self:getPhysicsBody():removeFromWorld()
end

function Fish:initPhysicsBody()
    local fishtype = self.m_data.fish_kind+1
    local bodyinfo = fish_body[fishtype]

    local body = cc.PhysicsBody:createBox(cc.size(bodyinfo.width, bodyinfo.height), cc.PHYSICSBODY_MATERIAL_DEFAULT, bodyinfo.offset) 
    body:setMass(PHYSICS_INFINITY)
    body:setMoment(PHYSICS_INFINITY)
    body:setCategoryBitmask(1)
    body:setCollisionBitmask(2)
    body:setContactTestBitmask(2)
    body:setGravityEnable(false)

    self:setPhysicsBody(body)
end

function Fish:setCombineBody(fishes, offsets)

    local body = cc.PhysicsBody:create()

    for i, v in ipairs(fishes) do
        local bodyinfo = fish_body[v.fish_kind+1]
        local shape = cc.PhysicsShapeBox:create(cc.size(bodyinfo.width, bodyinfo.height), 
            cc.PHYSICSBODY_MATERIAL_DEFAULT, 
            cc.pAdd(bodyinfo.offset, offsets[i]))

        body:addShape(shape)     
    end
    if #fishes == 2 then  --一箭双雕
        local shape = cc.PhysicsShapeBox:create(cc.size(120, 120),cc.PHYSICSBODY_MATERIAL_DEFAULT)
        body:addShape(shape) 
    end
    if #fishes == 3 then  --一石三鸟
        local shape = cc.PhysicsShapeBox:create(cc.size(150, 150),cc.PHYSICSBODY_MATERIAL_DEFAULT)
        body:addShape(shape) 
    end
    if #fishes == 5 then  --金玉满堂
        local shape = cc.PhysicsShapeBox:create(cc.size(200, 200),cc.PHYSICSBODY_MATERIAL_DEFAULT)
        body:addShape(shape) 
    end
    body:setMass(PHYSICS_INFINITY)
    body:setMoment(PHYSICS_INFINITY)
    body:setCategoryBitmask(1)
    body:setCollisionBitmask(2)
    body:setContactTestBitmask(2)
    body:setGravityEnable(false)

    self:setPhysicsBody(body)
end


return Fish
