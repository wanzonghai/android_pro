--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ExternalFun =  g_ExternalFun --appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local CoinLayer = class("CoinLayer",function()
    -- 创建物理世界
    cc.Director:getInstance():getRunningScene():initWithPhysics()
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0, -1000*1))
    local coinLayer = display.newLayer()
    return coinLayer
end )
local res_path = "game/yule/mllegend/res/"
local scheduler = cc.Director:getInstance():getScheduler()

local RectList = {
    cc.rect(0,0,128,128),cc.rect(0,128,128,128),cc.rect(0,256,128,128),cc.rect(0,384,128,128),
    cc.rect(128,0,128,128),cc.rect(128,128,128,128),cc.rect(128,256,128,128),cc.rect(128,384,128,128),
    cc.rect(256,0,128,128),cc.rect(256,128,128,128),cc.rect(256,256,128,128),cc.rect(256,384,128,128),
    cc.rect(384,0,128,128),cc.rect(384,128,128,128),cc.rect(384,256,128,128),cc.rect(384,384,128,128),
    }
        
function CoinLayer:ctor()
    ExternalFun.registerNodeEvent(self)

    print("CoinLayer:ctor()")
    
    local textureList = 
    {
        "coin_1.png",
        "coin_2.png",
        "coin_3.png",
    }
    local impulse = 
    {
        {25,50},
        {100,200},
        {1000,1500}
    }

    self._start = false
    function callback(dt)
        if self._start then
            local leftcoin = nil
            local _type = math.random(1, 3)
            local _random = math.random(0, 1)
            _random = _random == 0 and -1 or _random
            local posL = cc.p(667 - _random * 70, 250)
            local feame = cc.SpriteFrameCache:getInstance():getSpriteFrame(textureList[_type])
            leftcoin = cc.Sprite:create()
            leftcoin:setScale(0.4)
            leftcoin:addTo(self)
            leftcoin:setPosition(posL)
            if feame then
                leftcoin:setSpriteFrame(feame)
            end
            local body = cc.PhysicsBody:createBox(cc.size(40, 40))
            body:applyImpulse(cc.p(math.random(20, 30) * 1000 * _random, math.random(40, 120) * 1000))
            body:setGravityEnable(true)
            body:setRotationEnable(true)
            body:setCategoryBitmask(1)
            body:setCollisionBitmask(0)
            body:setContactTestBitmask(2)
            leftcoin:setPhysicsBody(body)
            local ani = cc.DelayTime:create(1.5)
            local seq = cc.Sequence:create(ani, cc.RemoveSelf:create(true))
            leftcoin:runAction(seq)

        end
    end
    self.m_Schedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 0.1, false)
end

function CoinLayer:onExit()
    if self.m_Schedule then
        scheduler:unscheduleScriptEntry(self.m_Schedule)
        self.m_Schedule = nil   
    end
end

function CoinLayer:startcoin()
    self._start = true
end

function CoinLayer:stopcoin()
    self._start = false
end

local WinLayer = {}

function WinLayer.showWinAni(parent,_time)
    if parent == nil then 
        return 
    end
    print("WinLayer.showWinAni",_time)

    local layer = parent:getChildByName("winlayer")
    if not layer then 
        layer = CoinLayer:create()
        layer:addTo(parent)
        layer:setName("winlayer")
    end
    layer:startcoin()
    layer:runAction(cc.Sequence:create(cc.DelayTime:create(_time), cc.CallFunc:create(   function() layer:stopcoin() end ) ))
end

function WinLayer.randomPos(_type)
    local pos = cc.p(0,0)

    

    if _type == 1 or _type == 2 then  --left 
        pos.x = math.random(250,ylAll.WIDTH/2)
    else      ---right
        pos.x = math.random(ylAll.WIDTH/2,ylAll.WIDTH-250)
    end

    if _type == 1 or _type == 3 then  --up
        if pos.x<ylAll.WIDTH/2+267 and pos.x>ylAll.WIDTH/2-267 then 
            pos.y = math.random(ylAll.HEIGHT/2+250,ylAll.HEIGHT-50)
        else 
            pos.y = math.random(ylAll.HEIGHT/2,ylAll.HEIGHT-50)
        end
    else  --down
        if pos.x<ylAll.WIDTH/2+267 and pos.x>ylAll.WIDTH/2-267 then 
            pos.y = math.random(50,ylAll.HEIGHT/2-250)
        else 
            pos.y = math.random(50,ylAll.HEIGHT/2)
        end
        
    end

    if _type == 5 then 
        pos=WinLayer.randomPos( math.random(1,4)) 
    end
    return pos
end

function WinLayer.getAngleByTwoPoint(param, param1)

    if type(param) ~= "table" or type(param1) ~= "table" then
        print("传入参数有误")
        return
    end

    local point = cc.p(param.x - param1.x, param.y - param1.y)
    local angle = 90 - math.deg(math.atan2(point.y, point.x))
    return angle
end

return WinLayer;
--endregion
