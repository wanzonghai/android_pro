local NumberScrollHelper = class("NumberScrollHelper")

local NumberScroll = appdf.req(appdf.CLIENT_SRC.."Tools.NumberScroll")

function NumberScrollHelper:ctor(pScoreLabel, funcScore, bNegative, _effect, _thousands)
	self.m_bNegative = bNegative
	self.m_pScoreLabel = pScoreLabel
	self.m_funcScore = funcScore
	local lScore = self:getTargetScore()
    lScore = lScore * 100
	self.m_pScroll = NumberScroll:create(pScoreLabel , lScore, lScore, 0, handler(self , self.scrollFinish) , false, _effect, _thousands)

	self.m_lCallbackScore=0
	self.m_bNegative = bNegative or false
    self.m_deltaAdd = {score=0,time=0}
    self._deltaScore = {}
    local function _update()
        self:updateDelayScore(0.04)
    end

    local array = {
        cc.DelayTime:create(0.04),
        cc.CallFunc:create(_update)
    }
    pScoreLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))
end

--[[
第一个参数：数字的label
第二个参数：同步外部分数变量
第三个参数：是否允许为负
]]

function NumberScrollHelper:create(pScoreLabel, funcScore, bNegative, _effect, _thousands)
    local helper = NumberScrollHelper.new(pScoreLabel, funcScore, bNegative, _effect, _thousands)
    return helper
end

function NumberScrollHelper:addScore( score , time, _delay)
    if _delay == nil or _delay < 0.01 then
	    self.m_deltaAdd.score = self.m_deltaAdd.score + score
	    self.m_deltaAdd.time = math.max(self.m_deltaAdd.time, time)
    else
        table.insert(self._deltaScore, {score=score , time=time, delay=_delay})
    end
    if self.m_pScroll:checkFinish() then
        self:scrollFinish(self:getTotalScore())
    end
end

function NumberScrollHelper:setEnableVoice(voice)
    self.m_pScroll:setEnableVoice(voice)
end

function NumberScrollHelper:scrollFinish(lScore)

	if lScore ~= nil then
		self.m_lCallbackScore = lScore
	end
	if self.m_deltaAdd.score ~= 0 then
		local score = self.m_deltaAdd.score
		local time = self.m_deltaAdd.time
        self.m_deltaAdd.score = 0
        self.m_deltaAdd.time = 0
		self:run(score, time)
    elseif #self._deltaScore == 0 then
        if lScore and self.m_funcScore then	
		    self.m_funcScore(lScore)
	    end
	end
end

function NumberScrollHelper:getTargetScore()
    if self.m_pScoreLabel:getString() == "" then
        return 0
    end
	return self:removeChar(self.m_pScoreLabel:getString())
end

function NumberScrollHelper:run(_score, _time)

	local lScore = math.max(0,self.m_pScroll:getEndScore())
	if (lScore > 0) then
		assert(self.m_lCallbackScore == lScore or self.m_pScroll:checkFinish() == true)
	end
	if (_score == 0) then
		return
	end
	local lTarget = lScore + _score
	if not self.m_bNegative and lTarget<0 then
		lTarget = 0
	end
	self.m_pScroll:reStart(lScore, lTarget, _time)
end

function NumberScrollHelper:getTotalScore()
    local _delay = 0
    for i=#self._deltaScore , 1 , -1 do
        _delay = _delay + self._deltaScore[i].score
    end
	return self.m_deltaAdd.score + self:getScrollEndScore() + _delay
end

function NumberScrollHelper:getScrollEndScore()
    if self.m_pScroll then
        return self.m_pScroll:getEndScore()
    end
    return 0
end

function NumberScrollHelper:setToTarget(lTarget, time)
	if self:getTotalScore() == lTarget then
		return false
	end
    self:clearAll()
	self.m_pScroll:setToTarget()
	local lScore = self.m_pScroll:getEndScore()
	self.m_pScroll:reStart(lScore, lTarget, time or 0)
	return true
end

function NumberScrollHelper:clearAll()
    self.m_deltaAdd.score = 0
    self.m_deltaAdd.time = 0
    self._deltaScore = {}
end

--获取结束分数
function NumberScrollHelper:getNextAddScore()
    return self.m_deltaAdd.score,self.m_deltaAdd.time
end

function NumberScrollHelper:release()
   if self.m_pScroll then
      self.m_pScroll:release()
   end
end

function NumberScrollHelper:updateDelayScore(dt)
    local _score = 0
    local _time = 0
    for i=#self._deltaScore , 1 , -1 do
        self._deltaScore[i].delay = self._deltaScore[i].delay - dt
        if self._deltaScore[i].delay <= 0 then
            local _s = self._deltaScore[i]
            table.remove(self._deltaScore, i)
            _score = _score + _s.score
            _time = _time + _s.time
        end
    end
    if _score ~= 0 then
        self:addScore(_score , _time)
    end
end

--把字符变为数字
function NumberScrollHelper:removeChar(strNumber)
    local s = ""
    for k = 1,#strNumber do
        local str = string.sub(strNumber,k,k)
        if str ~= "." then
            if str == "," then
                str = "."
            end
            s = s..str
        end
    end

    -- for n in string.gmatch(strNumber, ".") do
    --     if n then
    --         s = s..n
    --     end
    -- end
    return tonumber(s)
end

return NumberScrollHelper