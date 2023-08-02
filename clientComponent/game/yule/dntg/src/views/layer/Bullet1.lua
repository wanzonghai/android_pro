
local Bullet = class("Bullet", cc.Node)

local module_pre = "game.yule.dntg.src"			
local cmd = module_pre..".models.CMD_YQSGame"
local g_var = g_ExternalFun.req_var
local scheduler = cc.Director:getInstance():getScheduler()

Bullet.bulletType =
{
   Normal_Bullet = 0, --正常炮
   Bignet_Bullet = 1,--网变大
   Special_Bullet = 2--加速炮
}

local Type =  Bullet.bulletType

function Bullet:ctor(cannon)

   self.m_Type = Type.Normal_Bullet
   self.m_fishIndex = g_var(cmd).INT_MAX --鱼索引
   self.m_index     = -1 --子弹索引
   self.m_moveDir = cc.p(0,0)
   self.orignalAngle = 0
   self.ifdie=false
   self.m_cannon = cannon
   self.speed = 1000
   self.movedir = cc.p(0,0)
   self.m_bulletId = 0;
   self.proxy_chairId = nil
end

function Bullet:getT()
    return 2
end
local pNormalize = cc.pNormalize
local pForAngle = cc.pForAngle
function Bullet:initWithAngle(angle, cfg)
  self:initPhysicsBody()
  self:setRotation(angle)
  
  self.movedir = pNormalize(pForAngle(angle))
  self.orignalAngle = angle
end

function Bullet:setIndex( index )
	self.m_index = index
end

function Bullet:setFishIndex( index )
	self.m_fishIndex = index
end

function Bullet:setType( type )
	self.m_Type = type
end

function Bullet:setBulletId( bulletId )
	self.m_bulletId = bulletId
end
function Bullet:setProxyChairId(chairId)
    self.proxy_chairId = chairId
end

function Bullet:initPhysicsBody()
    local body = cc.PhysicsBody:createBox(cc.size(10, 20))
    body:setCategoryBitmask(2)
    body:setCollisionBitmask(1)
    body:setContactTestBitmask(1)
    body:setGravityEnable(false)
  	self:setPhysicsBody(body)
end

return Bullet