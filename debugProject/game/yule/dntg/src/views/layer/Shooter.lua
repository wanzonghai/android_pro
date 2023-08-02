
local M = class("Shooter", cc.Node)

local module_pre = "game.yule.dntg.src"			
local cmd = require(module_pre..".models.CMD_YQSGame")
local use_new_fire = true
function M:ctor(viewParent, wChairID)
	self.parent = viewParent

	self.type = cmd.CannonType.Normal_Cannon

	-- self.shootingScore = nil
	-- self.shootingLevel = nil

	self.cannonSpeed = 1
	self.fishIndex = cmd.INT_MAX

	self.targetPoint = nil--cc.p(0, 0)
	self.cannonPoint = nil--cc.p(0, 0)

	self.wChairID = wChairID

	self.manualShoot = false
	self.autoShoot = false
	self.autoLock = false

end

function M:start()
	self.timer = 0
    if not use_new_fire then
	   self:onUpdate(function(dt) self:update(dt) end)
    end
end

function M:stop()
	self:unscheduleUpdate()
end

function M:setAutoLock(lock)
	self.autoLock = lock
	if not lock then
		self.fishIndex = cmd.INT_MAX
	end
	self.autoShoot = false
end

function M:setAutoShoot(auto)
	self.autoShoot = auto

    if self.autoShoot then
    	self.autoLock = false
		self.fishIndex = cmd.INT_MAX
    end
end

function M:lockFish(fish)
	if fish then
		self.fishIndex = fish.fish_id
		if self.wChairID >= 2 then
			self.targetPoint = cc.p(ylAll.WIDTH - fish.Xpos, ylAll.HEIGHT - fish.Ypos)
		else
			self.targetPoint = cc.p(fish.Xpos, fish.Ypos)
		end
	else
		self.fishIndex = cmd.INT_MAX
	end
end

function M:shoot(pos, isbegin)
	self.targetPoint = pos
	self.isbegin = isbegin
    if use_new_fire then
       self:shootNew(pos,isbegin)
    end
end

function M:shootNew(pos, isbegin)
	if self.autoShoot or self.autoLock or self.isbegin then	
		if self.autoLock then
			if self.fishIndex == 0 or self.fishIndex == cmd.INT_MAX then
				return
			end
		end

		local score = self.parent.upscore[self.wChairID]
		
		if score < self.shootingScore then
			self.autoShoot = false
			self.autoLock = false
	    	self.parent._gameView:setAutoShoot(false)
	    	self.parent._gameView:setAutoLock(false)

			self:tip("Pontos insuficientes para disparar")

	    	return
		end
		local angle = 90 - math.deg(math.atan2(self.targetPoint.y - self.cannonPoint.y, self.targetPoint.x - self.cannonPoint.x))
        if angle >140 and angle<=180 then
            angle = 140
        end
        if angle >180 and angle<=220 then
            angle = 220
        end
        local fire = {}
        fire.bullet_kind = self.type
        fire.angle = angle
        fire.bullet_mulriple = self.shootingScore
        fire.bullet_speed = self.cannonSpeed
        fire.fish_index = self.fishIndex
        fire.fire_time = currentTime()
        fire.isbegin = isbegin
        fire.auto_lock = self.autoLock
        fire.auto_shoot = self.autoShoot
        self.parent:onSelfFire(fire)
	end
end

function M:tip(msg)
	if self.istip then return end
	self.istip = true
	ef.tip(msg)
	cc.runActions(self, 1, function() self.istip = nil end)
end

function M:update(dt)
	self.timer = self.timer + dt
	if use_new_fire then return end
	if self.autoShoot or self.autoLock or self.isbegin then	
		if self.timer < 0.27 / self.cannonSpeed then	
			return
		end

		if self.autoLock then
			if self.fishIndex == 0 or self.fishIndex == cmd.INT_MAX then
				return
			end
		end

		if self.parent.bullet_count > self.parent.bullet_limit_count then
			self:tip('Sobreaquecimento do barril, aguarde')
			return
		end

		local score = self.parent.upscore[self.wChairID]
		
		if score < self.shootingScore then
			self.autoShoot = false
			self.autoLock = false
	    	self.parent._gameView:setAutoShoot(false)
	    	self.parent._gameView:setAutoLock(false)

			self:tip("Pontos insuficientes para disparar")

	    	return
		end

		self.timer = 0
		self.parent:setSecondCount(60)

		local angle = 90 - math.deg(math.atan2(self.targetPoint.y - self.cannonPoint.y, self.targetPoint.x - self.cannonPoint.x))

		local cmddata = CCmd_Data:create()

		cmddata:setcmdinfo(G_NetCmd.MAIN_GAME, cmd.SUB_C_FIRE)
	    cmddata:pushint(self.type)
		cmddata:pushbyte(1)
	    cmddata:pushfloat(angle)
		cmddata:pushint(self.shootingScore)
		cmddata:pushint(self.cannonSpeed)
	    cmddata:pushint(self.fishIndex)
	    cmddata:pushdword(currentTime())

	    if not self.frameEngine then
	    	return
	    end

		--发送失败
		if not self.frameEngine:sendSocketData(cmddata) then
			-- self.frameEngine._callBack(-1,"发送开火息失败")
			print('发送开火失败')
		else
		    self.parent.bullet_count = self.parent.bullet_count + 1
		end
	end
end


return M