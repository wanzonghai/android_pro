local function bit(_n)
    local c = 1
    for i=1 , 11 do
        _n = _n / 10
        c = c * 10
        if _n < 10 then
            return c
        end
    end
    return c
end

local function bitCount(_n)
    local c = 1
    for i=1 , 11 do
        _n = _n / 10
        c = c + 1
        if _n < 10 then
            return c
        end
    end
    return c
end



local NumberScroll = class("NumberScroll")

--特效方式
NumberScroll.ZOOM_SCALE = 1 --放大缩小
NumberScroll.ZOOM = 2       --不断放大
NumberScroll.ZOOM_SCALE_FAST = 3 --放大缩小 快速模式 结束后不停留
NumberScroll.ZOOM_SCALE_VOICE = 4 --放大缩小 带音效模式

local kTaghandler = 1
--_effect false匀速模式
function NumberScroll:ctor(pRet, lFrom, lTo, duration, pCallback, bRelease, _effect, _thousands, _symbol, _scaleCount)
	self.m_fTotal=0
  	self.m_pTarget = pRet
    self._initialScale= math.min(1,self.m_pTarget:getScale())       --初始的scale
    
    self.m_scaleSoundIndex = 1   --放大时播放的音效

	self.m_lFrom = lFrom
	self.m_lTo = lTo
    local sharedScheduler = cc.Director:getInstance():getScheduler()
	self.m_duration = duration / sharedScheduler:getTimeScale()
	self.m_pCallback = pCallback
	self.m_bRelease = bRelease
  	self.m_fTotal=0
	self.m_lCurrent = self.m_lFrom
    self._effect = _effect or false
    self._thousands = string.find(pRet:getString(),".") and true or _thousands
    self._symbol = _symbol
    self._scaleCount = _scaleCount
    self._effectTime = 0
    self._effectTarget = {}
    self.beginScrollEff = false
    if self._effect then
        self:createTarget(lTo)
    end  
    self.m_ticket = self:clock()
    local function _update()
        local now = self:clock()
        local t = now - self.m_ticket
        self:_update(math.min(1/15,math.max(1/60,t)))
        self.m_ticket = now
    end

    local seq = cc.Sequence:create(
        cc.DelayTime:create(0.000001),
        cc.CallFunc:create(_update)
    )
    local handler = cc.RepeatForever:create(seq)
    handler:setTag(kTaghandler)
    self.m_pTarget:runAction(handler)

end

-- pRet 需要滚动的对象
-- lFrom 开始数字 
-- lTo 最终数字 
-- duration 时间
-- pCallback 回调函数
-- bRelease 是否立即释放
-- _effect 特效方式 NumberScroll.ZOOM_SCALE = 1 --放大缩小 NumberScroll.ZOOM = 2       --不断放大
-- thousands 是否千分位制
-- _scaleCount 放大次数 包含最终结果
function NumberScroll:create(pRet , lFrom , lTo , duration , pCallback , bRelease, _effect, _thousands, _symbol, _scaleCount)
	local p = NumberScroll.new(pRet , lFrom , lTo , duration , pCallback , bRelease, _effect, _thousands, _symbol, _scaleCount)
    return p
end

function NumberScroll:_update( fd )
    if self.m_lCurrent == self.m_lTo and self.m_fTotal > 0 then
        return
    end
    if self._effectTime > 0 then
        self._effectTime = math.max(0,self._effectTime - fd)
    else
        self.m_fTotal = self.m_fTotal + fd
    end
 
    local _effect = false
	if self.m_fTotal >= self.m_duration then
		self.m_lCurrent = self.m_lTo
        _effect = self._effect
	elseif NumberScroll.ZOOM_SCALE_VOICE == self._effect then
        local idx = self:checkEffectSection(self.m_lCurrent)
        local _duration = self.m_duration/#self._effectTarget
        local t = self.m_fTotal-_duration*idx
        local f = math.pow(t/_duration,0.3)
        local _from = self.m_lFrom
        local _to = self._effectTarget[math.min(idx+1 , #self._effectTarget)]
        if idx > 0 then
            _from = self._effectTarget[idx]
        end
        local c = _from+math.min(f,1)*(_to-_from)
        local target = self:checkReachTarget(self.m_lCurrent, c)
        if target > 0 then
		    self.m_lCurrent = target
            _effect = true
        elseif self._effectTime <= 0 then
            self.m_lCurrent = c
        end
    else
        local f = math.pow(self.m_fTotal/self.m_duration,0.3)
        if not self._effect then
            f = self.m_fTotal/self.m_duration
        end
        local c = self.m_lFrom+math.min(f,1)*(self.m_lTo-self.m_lFrom)
        local target = self:checkReachTarget(self.m_lCurrent, c)
        if target > 0 then
		    self.m_lCurrent = target
            _effect = true
        elseif self._effectTime <= 0 then
            self.m_lCurrent = c
        end
	end

    local bEnd = ((self.m_fTotal >= self.m_duration) or (self.m_lCurrent == self.m_lTo))
	if self.m_pTarget and self.m_lCurrent then
        self:setFormatString(self.m_lCurrent)
        if not self.beginScrollEff then
            self.beginScrollEff = true
            self:playScrollEffect(self.m_scaleSoundIndex)
        end
        if _effect and self.m_lCurrent > 0 then
            self._effectTime = (self._effect ~= NumberScroll.ZOOM_SCALE_FAST and 0.5 or 0.1)
            local endScale = self._initialScale
            if self._effect == NumberScroll.ZOOM then
                endScale = self._initialScale*1.1
            end
            local delayTime = (self._effect ~= NumberScroll.ZOOM_SCALE_FAST and 0.2 or 0)
            local as = {
                cc.CallFunc:create(function()
                   -- AudioManager.playHwFishGameEffect("whale_count1_"..tostring(self.m_scaleSoundIndex))
                    if not bEnd then
                        self:playScrollEffect(self.m_scaleSoundIndex+1)
                    end
                end),
                cc.ScaleTo:create(0,self._initialScale*1.6),
                cc.EaseOut:create(cc.ScaleTo:create(self._effectTime-delayTime,endScale),2.5),
                cc.DelayTime:create(delayTime),
                cc.CallFunc:create(function()
                    self.m_scaleSoundIndex = self.m_scaleSoundIndex + 1
                    if self.m_scaleSoundIndex == 6 then
                        self.m_scaleSoundIndex = 1
                    end
                end)
            }
            if bEnd then
                if self._effect ~= NumberScroll.ZOOM_SCALE_FAST then
                    table.insert(as , cc.DelayTime:create(1))
                end
                table.insert(as , cc.CallFunc:create(handler(self , NumberScroll.finish)))
                if self._voice then
                  --  AudioManager.stopEffect(self.m_pTarget)
                  --  AudioManager.playYMR2Effect("ymr2_bosswin_stop")
                end
            end
            self.m_pTarget:runAction(cc.Sequence:create(as))
            if self._effect == NumberScroll.ZOOM then
                self._initialScale = endScale
            end
        end
	end	
	if bEnd and _effect == false then
        self:finish()
	end
end

function NumberScroll:playScrollEffect(idx)
    if NumberScroll.ZOOM_SCALE_VOICE == self._effect then
        idx = idx or 1
        if idx > 6  then
            idx = 1
        end
      --  AudioManager.stopEffect(self.m_pTarget)
        if self.m_pTarget.m_chairId and self.m_pTarget.m_chairId == UserManager.GetMeChairID() then
           -- AudioManager.playHw2FishGameEffect("win_count"..idx, false , self.m_pTarget)
        elseif self.m_pTarget.m_chairId  then
           -- AudioManager.playHw2FishGameEffect("win_big"..idx, false , self.m_pTarget)
        end
    end
end

function NumberScroll:reStart( lFrom , lTo , duration )
	self.m_lFrom = lFrom
	self.m_lTo = lTo
	self.m_duration = duration
    self.m_fTotal=0
	self.m_lCurrent = self.m_lFrom
    if self._voice then
       -- AudioManager.playYMR2Effect("ymr2_bosswin_roll",true,self.m_pTarget)
    end
end

function NumberScroll:finish()
    -- if self.m_pTarget and self.m_pTarget.winEffect then
    --     AudioManager.stopEffect(self.m_pTarget.winEffect)
    --     self.m_pTarget.winEffect = nil
    -- end
	if (self.m_pCallback) then
		self.m_pCallback(self.m_lTo)
	end
	if (self.m_bRelease) then
		self:release()
	end
end

function NumberScroll:release()
	self.m_pCallback=nil
    if self.m_pTarget then
        self.m_pTarget:stopActionByTag(kTaghandler)
	    self.m_pTarget=nil
    end
end

function NumberScroll:getEndScore()
	return self.m_lTo
end

function NumberScroll:setToTarget()
	self.m_duration = 0
    self.m_fTotal=1
	self.m_lCurrent = self.m_lTo
    self:setFormatString(self.m_lCurrent)
end

function NumberScroll:setFormatString(num)
    if self._thousands then
        if (self.m_pTarget) then
		    self.m_pTarget:setString(g_format:formatNumber(num,g_format.fType.standard))
        end
    else
        if (self.m_pTarget) then
		    self.m_pTarget:setString(tostring(num))
        end
    end
    if self._symbol and self.m_pTarget and num > 0 then
        self.m_pTarget:setString("+"..self.m_pTarget:getString())
    end
end

function NumberScroll:checkFinish()
    return self.m_lCurrent == self.m_lTo
end

function NumberScroll:checkReachTarget(before , after)
    for i=1 , #self._effectTarget do
        if before < self._effectTarget[i] and after >= self._effectTarget[i] then
            return self._effectTarget[i]
        end
    end
    return 0
end

function NumberScroll:checkEffectSection(current)
    for i=1 , #self._effectTarget do
        if current < self._effectTarget[i] then
            return i - 1
        end
    end
    return 0
end

function NumberScroll:createTarget(_to)
    if self._scaleCount then
        self._effectTarget = self:createNumberScaleByCount(_to, self._scaleCount)
    else
        self._effectTarget = self:createNumberScale(_to)
    end
end

--获取总时间
function NumberScroll:getTotalTime()
    return self.m_duration + #self._effectTarget*(self._effect ~= NumberScroll.ZOOM_SCALE_FAST and 0.5 or 0.1) + (self._effect ~= NumberScroll.ZOOM_SCALE_FAST and 1 or 0)
end

function NumberScroll:getTargetNumber()
    if (self.m_pTarget) then
		return string.removeChar(self.m_pTarget:getString())
    end
    return 0
end

function NumberScroll:setEnableVoice(voice)
    self._voice = voice
end

function NumberScroll:clock()
    if socket then
        return socket.gettime()
    end
    --可能返回负值
    return os.clock()
end

function NumberScroll:GetIntPart(x)
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

--获取数字放大数组
function NumberScroll:createNumberScaleByCount(_to, _count)
    local b = self:GetIntPart(47/_count)
    local c = {}
    for i=1, _count-1 do
        table.insert(c, 53+b*i)
    end
    local numScale = {}
    local _t = t
    for i=1, #c do
        local _u = self:GetIntPart(_to/100)
        local _bit = bit(_u)
        local t = self:_int(_u, _bit)
        table.insert(numScale , t*c[i])
    end
    local _bit = 1
    local ret = nil
    for i=1, 10 do
        _bit = _bit*10
        local _ret = self:reset(numScale, _bit)
        if _ret then
            ret = _ret
        else
            break
        end
    end
    if ret then
        for i=1, #ret do
            numScale[i] = ret[i]
        end
    end
   
    table.insert(numScale , _to)   

    return numScale
end



--获取数字放大数组
function NumberScroll:createNumberScale(_to)
    local numScale = {}
    local _c = bitCount(_to)
    local scale = math.min(0.9, ((1-math.log10(_c))*2+0.2))
    local _to2 = self:GetIntPart(_to*scale)
    local _bit = bit(_to2)
    local t = self:_int(_to2, _bit)
    table.insert(numScale , t)
    local _t = t
    for i=1, 10 do
        local _t2 = self:_int(_t+(_to-_t)*(scale+i*0.25), _bit)
        if _t2 > _t and _t2+_bit < _to then
            table.insert(numScale , _t2)
            _t = _t2
        end
    end
    table.insert(numScale , _to)
    return numScale
end

function NumberScroll:_int(_n , _bit)
    return self:GetIntPart(_n/_bit)*_bit
end

function NumberScroll:reset(numScale, _bit)
    local _v = {}
    for i=1, #numScale do
        local num = self:_int(numScale[i] , _bit)
        if num == 0 or self:contain(_v, num) then
            return nil
        end
        table.insert(_v, num)
    end
    return _v
end

function NumberScroll:formatnumberthousands(num)
    dump(num)
    local num2 = tostring(num)
    local sign = ""
    if tonumber(num2) then
        num2 = num2
    elseif string.len(num2) > 4 and tonumber(string.sub(num2, 2)) then
        sign = string.sub(num2, 1, 1)
        num2 = string.sub(num2, 2)
    else
        return num
    end
    local formatted = tostring(tonumber(num2))
    dump(num2)
    dump(formatted)
    if sign == "" then
        sign = string.gsub(num2, formatted, "")
    end
    dump(sign)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    dump(sign..formatted)
    return sign..formatted
end
return NumberScroll