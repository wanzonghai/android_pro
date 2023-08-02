

MoveByPath = class("MoveByPath",MoveCompent)

function MoveByPath:ctor()

   -- 创建 MoveByPath
   self.view = nil
   self.m_bEndPath = false
   self.m_Elaspe = 0
   self.m_LastElaspe = 0
end

-- fdt 时间分片
local _math_min = math.min
local _math_abs = math.abs
function MoveByPath:OnUpdate(fdt)
	local fdt = fdt
	if self.m_pOwner == nil then
		return
	end

	if self.m_bEndPath == true then
		self.m_pOwner:OnMoveEnd()   --移除状态
		return
	end
    

    if self.m_fDelay > 0 then
        self.m_fDelay = self.m_fDelay - fdt
        if self.m_fDelay >= 0 then
            self.m_pOwner:SetPosition(-500.0, -500.0)
            return
        else
            fdt = _math_abs(self.m_fDelay)
        end
    end
    
    if self.m_bBeginMove == false and self.m_Elaspe > 0 then
        self.m_bBeginMove = true
    end

    self.m_Elaspe = self.m_Elaspe + fdt * self:GetSpeed() -- 已经走过的路程
    
    local tempElaspe = self.m_Elaspe
    
    if self.m_LastElaspe == tempElaspe then
        return
    end

    self.m_LastElaspe = tempElaspe

    if tempElaspe >= self.m_strMoveData.nDuration then
        self.m_bEndPath = true
    end
    
    local percent = _math_min(1.0, tempElaspe / self.m_strMoveData.nDuration) -- 已走路程占比 相当于 时间分频
    local x = 0
    local y = 0
    local dir = 0

    -- 计算在某一时间下在曲线上的位置
    if self.m_strMoveData.Type == DNTGTEST_PATH_MOVE_TYPE.LINE then
    	
      x, y, dir = self:CacLine(self.m_strMoveData.xPos, self.m_strMoveData.yPos, percent);

    elseif self.m_strMoveData.Type == DNTGTEST_PATH_MOVE_TYPE.BEZIER then
        
      x, y, dir = self:CacBesier( self.m_strMoveData.xPos, self.m_strMoveData.yPos, self.m_strMoveData.nPointCount, percent);

    elseif self.m_strMoveData.Type == DNTGTEST_PATH_MOVE_TYPE.CIRCLE then

      -- 目前没有这类路径
    elseif self.m_strMoveData.Type == DNTGTEST_PATH_MOVE_TYPE.STAY then
      x = self.m_strMoveData.xPos[0];
      y =  self.m_strMoveData.yPos[0];
      -- dir = self.m_strMoveData.fDirction;
    end
    
    local offest = self:GetOffest()
    self.m_pOwner:SetPosition(x + offest.x, y + offest.y)
    self.m_pOwner:SetDirection(dir)
end

return MoveByPath



