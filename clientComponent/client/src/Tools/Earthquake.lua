--震动组件
local Earthquake = class("Earthquake", function() 
    return display.newNode()
end)
MIN_TIME = 0.000001
Earthquake.DIRECT = {
    LEFT_RIGHT_UP_DOWN=1,       --上下左右
    LEFT_RIGHT = 2,             --左右
    UP_DOWN = 3,                --上下
    STAMP = 4,                  --踏步
}


Earthquake.EXTENT = {
    SMAILL = 5,
    MIDDLE = 10,
    BIG = 15,
    SUPER = 20
}
local EQ_TAG = 0x85ad
local RP_TAG = 0x86ad
local MV_TAG = 0x87ad

--quakeObject要震动的节点
--intensity震动的幅度
function Earthquake:ctor(quakeObject, intensity, seconds, direction , frameTime, minIntensity,weak)
    if type(quakeObject)=="table" then
        self._displayObject = quakeObject
    else
        self._displayObject = {}
        table.insert(self._displayObject, quakeObject)
    end
    local _left = self:stopLast(self._displayObject)    
    self:setTag(EQ_TAG)
    self._displayObject[1]:addChild(self)
    self._originalPos = {}
    for i=1 , #self._displayObject do
        table.insert(self._originalPos, cc.p(self._displayObject[i]:getPosition()))
    end   
	self._intensity = intensity
	self._intensityOffset = intensity / 2
    self._minIntensity = (minIntensity and minIntensity > 0) and minIntensity or self._intensityOffset/2
	self._seconds = self:max(_left , seconds)
    self._initSeconds = self._seconds
	self._direction = direction
    self.weak = weak
    self._sign = {}
    self.m_ticket = self:clock()
    local function _update()
        local now = self:clock()
        self:_update(now - self.m_ticket)
        self.m_ticket = now
    end
    self._frameTime = (frameTime and frameTime > 0) and frameTime or 0.04
    local seq = cc.Sequence:create(
        cc.CallFunc:create(_update),
        cc.DelayTime:create(self:max(self._frameTime , MIN_TIME))
    )
    local handler = cc.RepeatForever:create(seq)
    handler:setTag(RP_TAG)
    self:runAction(handler)
end

--创建一个震动组件
--displayObject 震动对象
--intensity 振幅 建议振幅[8-16]
--seconds   时间 建议时间[0.1-0.5]
--direction 方向
function Earthquake:create(displayObject, intensity, seconds, direction , frameTime, minIntensity,weak)
	local pEarth = Earthquake.new(displayObject , intensity , seconds , direction , frameTime, minIntensity,weak)
	return pEarth
end


function Earthquake:randIntensity(i)
    local sig = 1
    if i > 0 then
        sig = (self:rand(0,1)*2-1)
        if #self._sign >= 1 then
            sig = -self._sign[i]
        end
        self._sign[i] = sig
    end
	return self:rand(self._minIntensity,self._intensityOffset)*sig
end

function Earthquake:randSign()
    local sig1 = self:rand(0,1)*2-1
    local sig2 = self:rand(0,1)*2-1
    if sig1 == self._sign[1] and sig2 == self._sign[2] then
        if self:rand(0,1) == 0 then
            sig1 = -sig1
        else
            sig2 = -sig2
        end
    end
    self._sign[1] = sig1
    self._sign[2] = sig2
	return sig1 , sig2
end


function Earthquake:_update( delta )

	self._seconds = self._seconds - delta
	if self._seconds <= 0 then
		self:stop()
		return
    end
    local weakTime = math.min(self._initSeconds*0.5, 1)
    if self._intensity >= 20 and self._seconds <= weakTime then
        self._intensityOffset = self._intensity/2*math.sin(M_PI/2*self._seconds/weakTime)    --振幅衰减
        self._minIntensity = self._intensityOffset/2
        if self._intensityOffset < 1 then
            self:stop()
            return
        end
    end
	local _x = 0
    local _y = 0
	if self._direction == Earthquake.DIRECT.LEFT_RIGHT_UP_DOWN then
		_x = self:randIntensity(0)
        _y = self:randIntensity(0)
        local sig1 , sig2 = self:randSign()
        _x = _x*sig1
        _y = _y*sig2
	elseif self._direction == Earthquake.DIRECT.LEFT_RIGHT then
		_x = self:randIntensity(1)
	elseif self._direction ==  Earthquake.DIRECT.UP_DOWN then
		_y = self:randIntensity(2)
    elseif self._direction ==  Earthquake.DIRECT.STAMP then
        _y = self._intensityOffset
	end
--    printInfo("x=%d y=%d self._minIntensity=%d self._intensityOffset=%d", _x , _y, self._minIntensity, self._intensityOffset)
    for i = 1, #self._displayObject do
        if not self:checkNull(self._displayObject[i]) then  --防止震动过程中删除
            self:updatePosition(self._originalPos[i].x, self._originalPos[i].y, _x, _y, self._displayObject[i])
        end
    end    
end

function Earthquake:updatePosition(originalX, originalY, x, y, object)
    local newX = originalX
	local newY = originalY
    if self._direction == Earthquake.DIRECT.LEFT_RIGHT_UP_DOWN then
		newX = newX + x
		newY = newY + y
	elseif self._direction == Earthquake.DIRECT.LEFT_RIGHT then
		newX = newX + x
	elseif self._direction ==  Earthquake.DIRECT.UP_DOWN then
		newY = newY + y
    elseif self._direction ==  Earthquake.DIRECT.STAMP then
        newY = newY - y
	end
    if self._direction ==  Earthquake.DIRECT.STAMP then
	    object:setPosition(newX , newY)
        local mv = cc.EaseOut:create(cc.MoveTo:create(self._frameTime, cc.p(newX , newY + y)),2.5)
        mv:setTag(MV_TAG)
        object:runAction(mv)
    else
        local mv = cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(self._frameTime/2, cc.p(newX , newY)),2),
                                cc.EaseIn:create(cc.MoveTo:create(self._frameTime/2, cc.p(originalX , originalY)),2))
        mv:setTag(MV_TAG)
        object:runAction(mv)
	end
end

function Earthquake:stop()
    for i = 1, #self._displayObject do
        if not self:checkNull(self._displayObject[i]) then
            self._displayObject[i]:stopActionByTag(MV_TAG)
            self._displayObject[i]:stopActionByTag(RP_TAG)
            self._displayObject[i]:setPosition(self._originalPos[i])
        end
    end
    self:removeSelf()
end

function Earthquake:stopLast(quakeObject)
    local left = 0
    for i=1 , #quakeObject do
        local _l = self:stopLastOne(quakeObject[i])
        left = self:max(_l , left)
    end
    return left
end

function Earthquake:stopLastOne(quakeObject)
    local _left = 0
    local _last = quakeObject:getChildByTag(EQ_TAG)
    if _last then
        _left = _last._seconds
        _last:stop()
    end
    return _left or 0
end

function Earthquake:checkNull(obj)
    return obj == nil or tolua.isnull(obj)
end

function Earthquake:clock()
    if socket then
        return socket.gettime()
    end
    --可能返回负值
    return os.clock()
end

--包含_min和_max
function Earthquake:rand(_min , _max)
    return Earthquake:GetIntPart(math.random()*(_max-_min+1))+_min
end

function Earthquake:GetIntPart(x)
    if x <= 0 then
        return math.ceil(x)
    end

    if math.ceil(x) == x then
        x = math.ceil(x)
    else
        x = math.ceil(x) - 1
    end
    return x
end

function Earthquake:max(num1,num2)
    return (num1 > num2) and num1 or num2
end

return Earthquake
