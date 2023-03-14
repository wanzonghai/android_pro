--[[ ==========================================================================
#
#    Author: Fish Team.
#
#    Last modified: 2017-09-12 09:58
#
#    Filename: MoveCompent.lua
#
#   Description: 移动组件
#
============================================================================= --]]

DNTGTEST_PATH_MOVE_TYPE = 
{
    LINE    = 0,
    BEZIER  = 1,
    CIRCLE  = 2,
    STAY    = 3,
}

M_PI_2                              = math.pi * 0.5 --- 不要使用 “ / 2” 
M_PI                                = math.pi


MoveCompent = class("MoveCompent", {})

function MoveCompent:ctor()

	-- 创建 MoveCompent
	self.view           = nil                   --- 渲染层

    self.m_pPosition    = { x = 0, y = 0 }      --- 位置信息
    self.m_fDirection   = 0                     --- 方向
    self.m_fSpeed       = 0                     --- 速度
    self.m_bPause       = false                 --- 是否暂停移动
    self.m_nPathID      = 0                     --- 路径ID
    self.m_bEndPath     = false                 --- 是否已走完路径
    self.m_Offest       = { x = 0, y = 0 }      --- 偏移量
    self.m_fDelay       = 0                     --- 延迟
    self.m_bBeginMove   = false                 --- 是否已开始移动
    self.m_bRebound     = false                 --- 是否反射
    self.m_dwTargetID   = 0                     
    self.m_bTroop       = false                 --- 是否是群组
    self.m_pOwner       = nil                   --- 拥有者
end

-- int nType,
-- float xPos1, float xPos2, float xPos3, float xPos4,
-- float yPos1, float yPos2, float yPos3, float yPos4,
-- int nPointCount, float fDirction, int nDuration
function MoveCompent:SetPathMoveData(tMoveData)

	-- 控制移动的路线数据点
	self.m_strMoveData = tMoveData

    if not self.m_strMoveData.isPointBuff then

        -- 名字从 xPos 变为 x 做一版兼容
        self.m_strMoveData.xPos = {}
        self.m_strMoveData.xPos[1] = self.m_strMoveData.Position[1].x
        self.m_strMoveData.xPos[2] = self.m_strMoveData.Position[2].x
        self.m_strMoveData.xPos[3] = self.m_strMoveData.Position[3].x
        self.m_strMoveData.xPos[4] = self.m_strMoveData.Position[4].x

        self.m_strMoveData.yPos = {}
        self.m_strMoveData.yPos[1] = self.m_strMoveData.Position[1].y
        self.m_strMoveData.yPos[2] = self.m_strMoveData.Position[2].y
        self.m_strMoveData.yPos[3] = self.m_strMoveData.Position[3].y
        self.m_strMoveData.yPos[4] = self.m_strMoveData.Position[4].y

        if self.m_strMoveData.Type == DNTGTEST_PATH_MOVE_TYPE.LINE then
            local xPos = self.m_strMoveData.xPos
            local yPos = self.m_strMoveData.yPos
            xPos[5] = xPos[2] - xPos[1]
            yPos[5] = yPos[2] - yPos[1]
            self.m_strMoveData.dir = self:CalcAngle(xPos[1], yPos[1], xPos[2], yPos[2]) - M_PI_2;
        elseif self.m_strMoveData.Type == DNTGTEST_PATH_MOVE_TYPE.BEZIER then
            local xPos = self.m_strMoveData.xPos
            local yPos = self.m_strMoveData.yPos
            if self.m_strMoveData.nPointCount == 3 then
                xPos[5] = xPos[2] - xPos[1]
                xPos[6] = xPos[3] - xPos[2]
                yPos[5] = yPos[2] - yPos[1]
                yPos[6] = yPos[3] - yPos[2]
            else
                xPos[5] = xPos[2] - xPos[1]
                xPos[6] = xPos[3] - xPos[2]
                xPos[7] = xPos[4] - xPos[3]
                yPos[5] = yPos[2] - yPos[1]
                yPos[6] = yPos[3] - yPos[2]
                yPos[7] = yPos[4] - yPos[3]
            end
        end
        self.m_strMoveData.isPointBuff = true
    end
end


function MoveCompent:SetSpeed(sp)
    self.m_fSpeed = sp
end

function MoveCompent:GetSpeed()
    return self.m_fSpeed or 0
end

function MoveCompent:SetPause(bPause)
    self.m_bPause = bPause or true
end

function MoveCompent:IsPaused()
    return self.m_bPause or true
end

function MoveCompent:SetPathID(pid, bt)
    self.m_nPathID = pid
    self.m_bTroop = bt
end

function MoveCompent:GetPathID()
    return self.m_nPathID
end

function MoveCompent:bTroop()
    return self.m_bTroop
end

function MoveCompent:InitMove()
    self.m_Elaspe = 0
    self.m_LastElaspe = -1
    self.m_bEndPath = false
end

function MoveCompent:OnAttach()
    self:InitMove();
end

function MoveCompent:IsEndPath()
    return self.m_bEndPath or false
end

function MoveCompent:SetEndPath(be)
    self.m_bEndPath = be
end

function MoveCompent:GetOffest()
    return self.m_Offest or cc.p(0, 0)
end

function MoveCompent:SetOffest(pt)
    self.m_Offest = pt
end

function MoveCompent:SetDelay(f)
    self.m_fDelay = f
end

function MoveCompent:GetDelay()
    return self.m_fDelay or 0
end

function MoveCompent:HasBeginMove()
    return self.m_bBeginMove or false
end

function MoveCompent:Rebound()
    return self.m_bRebound or false
end

function MoveCompent:SetRebound(b)
    self.m_bRebound = b
end

function MoveCompent:SetPosition(x, y)
    self.m_pPosition.x = x
    self.m_pPosition.y = y
end

function MoveCompent:GetCompentPosition()

    return self.m_pPosition
end

function MoveCompent:SetDirection(dir)
    self.m_fDirection = dir
end

function MoveCompent:GetCompentDirection()

    return self.m_fDirection
end

function MoveCompent:SetOwner(owner)
    self.m_pOwner = owner
end

function MoveCompent:GetOwner()
    return self.m_pOwner
end

-- float x1, float y1, float x2, float y2
local _math_atan = math.atan
function MoveCompent:CalcAngle(x1, y1, x2, y2)
    local x = x1 - x2
    local y = y1 - y2

    if y == 0 then
        ---[[
        if x1 < x2 then
            return M_PI_2
        else
            return -M_PI_2
        end
        --]]
    end

    local deg = _math_atan(x / y)

    if y < 0 then
        return -deg + M_PI
    else
        return -deg
    end

end

-- float x[4], float y[4], float percent, float* outX, float* outY, float* outDir
function MoveCompent:CacLine(x, y, percent)
    local outX = x[1] + x[5] * percent;
    local outY = y[1] + y[5] * percent;
    return outX, outY, self.m_strMoveData.dir
end

-- float x[4], float y[4], int count, float per, float* outX, float* outY, float* outDir
function MoveCompent:CacBesier(x, y, count, per)

    if count == 3 then

        local x1 = x[1] + x[5] * per;
        local x2 = x[2] + x[6] * per;

        local y1 = y[1] + y[5] * per;
        local y2 = y[2] + y[6] * per;

        local outX = x1 + (x2 - x1) * per;
        local outY = y1 + (y2 - y1) * per;
        local outDir = self:CalcAngle(x1, y1, x2, y2) - M_PI_2;
        
        return outX, outY, outDir

    else

        local x1 = x[1] + x[5] * per;
        local x2 = x[2] + x[6] * per;
        local x3 = x[3] + x[7] * per;

        local y1 = y[1] + y[5] * per;
        local y2 = y[2] + y[6] * per;
        local y3 = y[3] + y[7] * per;

        local xx1 = x1 + (x2 - x1) * per;
        local xx2 = x2 + (x3 - x2) * per;

        local yy1 = y1 + (y2 - y1) * per;
        local yy2 = y2 + (y3 - y2) * per;

        local outX = xx1 + (xx2 - xx1) * per;
        local outY = yy1 + (yy2 - yy1) * per;
        local outDir = self:CalcAngle(xx1, yy1, xx2, yy2) - M_PI_2;
        
        return outX, outY, outDir

    end
end

-- float centerX, float centerY, float radius, 
-- float begin, float fAngle, float fAdd, float percent, float* outX, float* outY, float* outDir
local _math_abs = math.abs
local _math_cos = math.cos
local _math_sin = math.sin
function MoveCompent:CalCircle(centerX, centerY, radius, begin, fAngle, fAdd, percent)

    local absFAngle = _math_abs(fAngle);
    local _radius = radius * (1 + fAdd * percent * absFAngle);
    local angle = begin + percent * absFAngle;

    local outX = centerX + _radius * _math_cos(angle);
    local outY = centerY + _radius * _math_sin(angle);
    local outDir = angle + M_PI_2;

    return outX, outY, outDir
end







