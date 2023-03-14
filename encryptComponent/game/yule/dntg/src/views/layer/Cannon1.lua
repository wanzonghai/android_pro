
local Cannon = class("Cannon", cc.Sprite)

local module_pre = "game.yule.dntg.src"			
local cmd = require(module_pre..".models.CMD_YQSGame")
local Bullet = require(module_pre..".views.layer.Bullet1")

local scheduler = cc.Director:getInstance():getScheduler()

local sinf = math.sin
local cosf = math.cos
local rad = math.rad
local deg = math.deg
local atan2 = math.atan2
local floor = math.floor
local remove = table.remove
local insert = table.insert
local bulletSp = {
"cannon/images/dntgtest_Bullet_1_1.png",
"cannon/images/dntgtest_Bullet_1_1.png",
"cannon/images/dntgtest_Bullet_1_1.png",
"cannon/images/dntgtest_Bullet_2_1.png",
"cannon/images/dntgtest_Bullet_2_1.png",
"cannon/images/dntgtest_Bullet_2_1.png",
"cannon/images/dntgtest_Bullet_3_1.png",
"cannon/images/dntgtest_Bullet_3_1.png",
"cannon/images/dntgtest_Bullet_3_1.png",
"cannon/images/dntgtest_Bullet_3_1.png",
}

local bulletTime = {0.3,0.2,0.1}
local socket = require("socket")

function Cannon:ctor(viewParent)
	self.parent = viewParent

	self.bullet_data_list = {}

	self.shoot_timer = 0
	self.bullet_timer = 0

    self.m_canShoot = true 
    

	self.m_targetPoint = cc.p(0, 0)
	self.m_cannonPoint = cc.p(0, 0)

    self.locker_chairId = 0  --当前锁定或解锁的椅子id 

    self.m_checkLongTouch = false --长按
    self.m_autoShoot = false  --自动开炮
	self.m_autoLock = false  --自动锁定

    self.m_cannonSpeed = 1  --炮速度
    self.nLastFireTime = 0

    self.bubbleList = {}
    self.m_firelist = {}

    self.m_canShoot = true
    self.m_fishIndex = cmd.INT_MAX
    self.m_index  = 0 --子弹索引

    self.m_lockSchedule = nil
    self.m_autoShootSchedule = nil

    --bubble
    if not self.layerLockBubble then
        self.layerLockBubble = display.newLayer()  --锁定时的泡泡layer
        self.layerLockBubble:addTo(self.parent._gameView, 98)
        for i = 1, 30 do
            local bubble = display.newSprite("game_res/lockBubble.png")
            self.layerLockBubble:addChild(bubble, 1000)
            bubble:setName("bubble_" .. i)
            bubble:setPosition(2000, 2000)
        end
        local bubble = display.newSprite("game_res/lockBubble.png")
        self.layerLockBubble:addChild(bubble, 1000)
        bubble:setName("big_bubble")
        bubble:setPosition(2000, 2000)
    end
    if not self.fishLocker then
        self.fishLocker = display.newSprite('#cannon/images/dntgtest_battle_ui_lock_flag.png')
        self.fishLocker:addTo(self.parent._gameView, 99):hide()
    end

    self:onUpdate(function(dt) self:onFire(dt) end)
end

--处理自己发炮
function Cannon:onFire(dt)
    local timeNow = socket.gettime()
    local leftTime = timeNow - self.nLastFireTime
   
    if self.parent.m_pao_hot or self.parent.bullet_count > self.parent.bullet_limit_count then
        --showToast("Sobreaquecimento do barril, aguarde")
        return 
    end   
    --自动 或长按
    if self.m_autoShoot == true or self.m_checkLongTouch == true then 
       local deltaTime = self:getBulletDeltaTime()  --子弹时间
       if leftTime > deltaTime then
           self.nLastFireTime = socket.gettime()
           local score = self.parent.upscore[self.wChairID]
	       if score < self.parent.shootingScore then
	       	    self.m_autoShoot = false
	          	self.parent._gameView:setAutoShoot(false)
                if self.m_autoShoot then
                    self:setAutoLock(false)
                end
                showToast("Pontos insuficientes para disparar")
	          	return
	       end
           if self.m_autoShoot and not self.m_autoLock then  --自动射击
                local angle = self:getAngleByTwoPoint(self.m_targetPoint,self.m_cannonPoint)
                if angle < 90 then
                    self.pao:setRotation(angle)
                end          
           end
           self.parent.effcache:playNode(self.pao_animation, false)
           ef.playEffect("sound_res/GunFire0.mp3")
           self:productBullet(true,self.parent.m_fishIndex)
       end
    end
end

function Cannon:getBulletDeltaTime()
    return bulletTime[self.m_cannonSpeed]
end

function Cannon:SetBulletIndex(bulletIndex)
   self.m_index = bulletIndex
end

function Cannon:setup()
	self:setDisplayLevel(1)

	self.m_nickName = nil
	self.m_score = nil
	self.m_multiple = nil
	self.m_isShoot = false
	self.m_autoShoot = false
	self.orignalAngle = 0
	self.m_fishIndex = cmd.INT_MAX
	self.m_index  = 0 --子弹索引

	self.m_cannonPoint = self.pao:convertToWorldSpaceAR(cc.p(0, 0))

	self.m_firelist = {}
    self.m_bullet= {}
    self.power=0               --能量
    self.fangle=0
    self.ifno=true

	self.m_Type = cmd.CannonType.Normal_Cannon

	self.frameEngine = self.parent._gameFrame 

 	self.m_goldList = {} -- 游戏币动画
 	self.m_goldIndex = 1 -- 游戏币动画
 	--游戏币横幅红绿切换
 	self.m_nBannerColor = 0

    local x = self.pao:getContentSize().width / 2
	local y = self.pao:getContentSize().height * self.pao:getAnchorPoint().y
end

function Cannon:onExit()
    self:unLockSchedule()
    self:unAutoSchedule()
end


function Cannon:ClearSchedule()
    self:unLockSchedule()
    self:unAutoSchedule()
end

function Cannon:initWithUser(userItem,cannonLevel)
    cannonLevel = cannonLevel or 1
	self:setDisplayLevel(cannonLevel)
    local angle = self.pao:getRotation()
	self.pao:setRotation(angle)

	self.dwUserID = userItem.dwUserID
	self.wChairID = userItem.wChairID

	if (self.parent.m_nChairID >= 2 and self.wChairID < 2) or (self.parent.m_nChairID < 2 and self.wChairID >= 2) then
        if angle == 0 then
           angle = 180
        end
		self.pao:setRotation(angle)
	end

	self:setContentSize(100,100)
	self:removeChildByTag(1000)
	self.lb_name:setString(ef.formatName(userItem.szNickName))
end

function Cannon:setDisplayLevel(level, ani)
	if self.display_level == level then return end
	self.pao:removeAllChildren()
	local score = self.parent.shootingScoreSet[level]
	local serverKind = G_GameFrame:getServerKind()
	self.lb_mul:setString(g_format:formatNumber(score,g_format.fType.standard,serverKind))

	if level > 10 then
		level = 10
	end

	self.display_level = level

	self.pao_animation = self.parent.effcache:get('cannon_'..level)
	self.pao_animation:addTo(self.pao)
    
	if ani then
		print('切换炮')
		local x = self.pao:getContentSize().width / 2
		local y = self.pao:getContentSize().height * self.pao:getAnchorPoint().y

        local praticle = cc.ParticleSystemQuad:create("xyaoqianshu/eff/paoglow.plist"):addTo(self.pao)
		praticle:setLocalZOrder(2)
		praticle:setPosition(cc.p(x,y))
			
		local aniNode
		aniNode = cc.playCSB(self.pao, "xyaoqianshu/eff/pao2.csb", "Animation1", function()
			aniNode:removeSelf()
			praticle:removeSelf()
		end)

		aniNode:setLocalZOrder(1)
		aniNode:setPosition(cc.p(x,y))
	end
end

function Cannon:setCanShoot(canShoot)
    canShoot = canShoot or false
    self.m_canShoot = canShoot
end

function Cannon:setFishIndex(index)
	self.m_fishIndex = index
end

function Cannon:setCannonSpeed(speed)
   self.m_cannonSpeed = speed
   if self.m_autoShootSchedule then
       self:unAutoSchedule()
       local time = 0.4 / self.m_cannonSpeed   --0.27 不加倍状态下
       self:autoSchedule(time)
   end
end

function Cannon:autoSchedule(dt)
	local function updateAuto(dt)
		self:autoUpdate(dt)
	end
	if nil == self.m_autoShootSchedule then
		self.m_autoShootSchedule = scheduler:scheduleScriptFunc(updateAuto,dt, false)
	end
end
function Cannon:unAutoSchedule()
	if nil ~= self.m_autoShootSchedule then
		scheduler:unscheduleScriptEntry(self.m_autoShootSchedule)
		self.m_autoShootSchedule = nil
	end
end
--锁定定时器
function Cannon:lockSchedule(dt)
	local function updateLock(dt)
		self:autoLockUpdate(dt)
	end
	if nil == self.m_lockSchedule then
		self.m_lockSchedule = scheduler:scheduleScriptFunc(updateLock,dt, false)
	end
end
function Cannon:unLockSchedule()
	if nil ~= self.m_lockSchedule then
		scheduler:unscheduleScriptEntry(self.m_lockSchedule)
		self.m_lockSchedule = nil
	end
    self:HideLockLayer()
end

function Cannon:HideLockLayer()
    for i= 1, 30 do
        if i > 0 then
            local bubble = self.layerLockBubble:getChildByName("bubble_" .. i)
            bubble:setPosition(cc.p(2000, 2000))
        end
    end
    local bubble = self.layerLockBubble:getChildByName("big_bubble")
    bubble:setPosition(cc.p(2000, 2000))
    if self.fishLocker then
        self.fishLocker:hide()
    end
end

--定时器锁定
function Cannon:autoLockUpdate(dt)
    if self.m_autoLock then
       if self.m_fishIndex == nil or self.m_fishIndex == cmd.INT_MAX then
           print("dntg fishindex not found")
           if self.parent.m_nChairID ~= self.wChairID then
               self:unLockSchedule()
           else
               self:HideLockLayer()
           end
           return
       end
       local fish = self.parent.m_fishMap[self.m_fishIndex]
       if fish == nil then 
          print("dntg lock fish  not found")
           if self.parent.m_nChairID ~= self.wChairID then
               self:unLockSchedule()
           else
               self:HideLockLayer()
           end
          return
       end
       local pos = cc.p(fish.Xpos, fish.Ypos)
       local isTrue  = (self.parent.m_nChairID >= 2 and self.wChairID < 2)
       if not isTrue then
           isTrue = (self.parent.m_nChairID == self.wChairID and self.wChairID >= 2)
       end
       if not isTrue then
           isTrue = (self.parent.m_nChairID ~= self.wChairID and self.parent.m_nChairID >=2 and self.wChairID >= 2)
       end
       if isTrue then
           pos = cc.p(ylAll.WIDTH - fish.Xpos, ylAll.HEIGHT - fish.Ypos)
       end
	   --[[if (self.parent.m_nChairID >= 2 and self.wChairID < 2) or 
       (self.parent.m_nChairID == self.wChairID and self.wChairID >= 2) or 
       (self.parent.m_nChairID ~= self.wChairID and self.parent.m_nChairID >=2 and self.wChairID >= 2) then
	     	pos = cc.p(ylAll.WIDTH - fish.Xpos, ylAll.HEIGHT - fish.Ypos)
	   end]]
       if self.fishLocker then
          self.fishLocker:setPosition(pos)
       end
       local mePos = self.m_cannonPoint

       local angle = self:getAngleByTwoPoint(pos, mePos)
       self.pao:setRotation(angle)

       local distance = cc.pGetDistance(pos, mePos)
       local num = floor(distance / 60)
       for i = 1, num do
           self.bubbleList[i] = cc.p(60 * i * sinf(rad(angle)) + mePos.x, 60 * i * cosf(rad(angle)) + mePos.y)
       end
       for i = #self.bubbleList, num + 1, -1 do
           local pos1 = remove(self.bubbleList, i)
           if i > 0 then
               local bubble = self.layerLockBubble:getChildByName("bubble_" .. i)
               if bubble then
                   bubble:setPosition(cc.p(2000, 2000))
               end
           end
       end
       self:updateBubble()
    end
end
function Cannon:updateBubble()
    for i = #self.bubbleList, 1, -1 do
        if self.bubbleList[i] ~= nil then
            if i == #self.bubbleList then
                local bubble = self.layerLockBubble:getChildByName("big_bubble")
                if bubble then
                    bubble:setPosition(self.bubbleList[i])
                end
            else
                if i>1 then
                    local bubble = self.layerLockBubble:getChildByName("bubble_" .. i)
                    if bubble then
                        bubble:setPosition(self.bubbleList[i])
                    end
                end
            end
        end
    end
    for i = 30, #self.bubbleList, -1 do
        if i > 0 then
            local bubble = self.layerLockBubble:getChildByName("bubble_" .. i)
            bubble:setPosition(cc.p(2000, 2000))
        end
    end
    if 0 == #self.bubbleList then
        local bubble = self.layerLockBubble:getChildByName("big_bubble")
        bubble:setPosition(cc.p(2000, 2000))
    end
end
--自己开火
function Cannon:autoUpdate(dt)
    if not self.m_canShoot then 
        return 
    end
    if self.parent.m_pao_hot or self.parent.bullet_count > self.parent.bullet_limit_count then
        --炮管过热，请稍后
        showToast("Sobreaquecimento do barril, aguarde")
        return 
    end
    local score = self.parent.upscore[self.wChairID]
	if score < self.parent.shootingScore then
		self.m_autoShoot = false
		--self.m_autoLock = false
	   	self.parent._gameView:setAutoShoot(false)
	   	--self.parent._gameView:setAutoLock(false)
        --分数不足，无法开火
        showToast("Pontos insuficientes para disparar")
	   	return
	end
    if self.m_autoShoot then  --自动射击
        if self.m_autoLock then  --锁定
            
        else  --不锁定
             local angle = self:getAngleByTwoPoint(self.m_targetPoint,self.m_cannonPoint)
             if angle < 90 then
                 self.pao:setRotation(angle)
             end          
        end
    end
    self.parent.effcache:playNode(self.pao_animation, false)
    ef.playEffect("sound_res/GunFire0.mp3")
    self:productBullet(true,self.parent.m_fishIndex)
end

function Cannon:produceSelfBullet(fire)
    self.parent.effcache:playNode(self.pao_animation, false)
	ef.playEffect("sound_res/GunFire0.mp3")
    self:productBullet(true,self.parent.m_fishIndex,fire)
end

function Cannon:productBullet(isSelf,fishIndex,fire)
    local angle = self.pao:getRotation()
    local angle1 = angle
    local bullet0=nil
    if fire ~= nil then
        bullet0 = Bullet:create(self)
        bullet0:initWithAngle(angle, self.cfg)
        bullet0:setName(cmd.BULLET)
        
        local eff = cc.Sprite:createWithSpriteFrameName(bulletSp[self.display_level])--self.parent.effcache:get('bullet_'..self.display_level)
        eff:addTo(bullet0)
        
        self.parent._gameView.bulletLayer:addChild(bullet0) 
        
        bullet0.m_nScore = fire.bullet_mulriple
	    bullet0.chair_id = self.wChairID
	    bullet0.cannonLevel = self.display_level
	    
	    bullet0.isAndroid = fire.android_chairid ~= G_NetCmd.INVALID_CHAIR						
        
        bullet0:setType(fire.bullet_kind)
        bullet0:setIndex(fire.bullet_id)
        bullet0:setFishIndex(fire.lock_fishid)
        bullet0:setBulletId(fire.bullet_id)
        bullet0:setProxyChairId(fire.proxy_chairid)
        angle = rad(90-angle)
        local movedir = cc.pForAngle(angle)
        movedir = cc.p(movedir.x * 55 , movedir.y * 55)
        local pos = cc.p(self.m_cannonPoint.x  +movedir.x,self.m_cannonPoint.y+movedir.y)   
        local offset = cc.p(25 * sinf(angle),5 * cosf(angle))
        pos=cc.p(pos.x,pos.y -offset.y/2)
        bullet0:setPosition(pos)
        bullet0.movedir = cc.pNormalize(movedir)
        insert(self.parent.busy_bullet, bullet0)           
    else
       
       --if self.parent.bEnterScene then
          self.m_index = self.m_index + 1
       --end
       if self.m_index > 2147483637 then
          self.m_index = 1
       end
       bullet0 = Bullet:create(self)
       bullet0:initWithAngle(angle, self.cfg)
       bullet0:setName(cmd.BULLET)
       
       local eff = cc.Sprite:createWithSpriteFrameName(bulletSp[self.display_level])--self.parent.effcache:get('bullet_'..self.display_level)
       eff:addTo(bullet0)
       
       self.parent._gameView.bulletLayer:addChild(bullet0) 
       
       bullet0.m_nScore = self.parent.shootingScore
	   bullet0.chair_id = self.wChairID
	   bullet0.cannonLevel = self.display_level
	   
	   bullet0.isAndroid = false					
       
       bullet0:setType(self.m_Type)
       bullet0:setIndex(self.m_index)
       bullet0:setFishIndex(self.m_fishIndex)
       bullet0:setBulletId(self.m_index)

       angle = rad(90-angle)
       local movedir = cc.pForAngle(angle)
       movedir = cc.p(movedir.x * 55 , movedir.y * 55)
       local pos = cc.p(self.m_cannonPoint.x  +movedir.x,self.m_cannonPoint.y+movedir.y)   
       local offset = cc.p(25 * sinf(angle),5 * cosf(angle))
       pos=cc.p(pos.x,pos.y -offset.y/2)
       bullet0:setPosition(pos)
       bullet0.movedir = cc.pNormalize(movedir)
       -- self.parent.busy_bullet[self.m_index] = bullet0
       insert(self.parent.busy_bullet, bullet0)        
    end

    if isSelf then
        self.parent:setSecondCount(1000)
		local cmddata = CCmd_Data:create(29)

		cmddata:setcmdinfo(G_NetCmd.MAIN_GAME, cmd.SUB_C_FIRE)
	    cmddata:pushint(self.m_Type)
		cmddata:pushbyte(1)
	    cmddata:pushfloat(angle1)

		cmddata:pushint(self.parent.shootingScore)
		cmddata:pushint(self.m_cannonSpeed)
	    cmddata:pushint(self.m_fishIndex)
	    cmddata:pushdword(currentTime())
        cmddata:pushint(self.m_index)

	    if not self.frameEngine then
	    	return
	    end
		--发送失败
		if not self.frameEngine:sendSocketData(cmddata) then
			-- self.frameEngine._callBack(-1,"发送开火息失败")
			print('发送开火失败')
		else
            local score = self.parent.upscore[self.wChairID]
		    self:updateUpScore(score - self.parent.shootingScore)
		end
        self.parent.bullet_count = self.parent.bullet_count + 1
    end
end


--自动射击
function Cannon:AutoShoot(b)
   self.m_autoShoot = b
  --[[ if self.m_autoShoot then
      local time = 0.4 / self.m_cannonSpeed   --0.27 不加倍状态下
      self:autoSchedule(time)
   else
      self:unAutoSchedule()	
   end]]
end

function Cannon:AutoLock(b,chair_id)
    self.m_autoLock = b
    self.locker_chairId = chair_id or 0
    if not self.m_autoLock then
        self.m_fishIndex = cmd.INT_MAX
        self:unLockSchedule()
    else
        self:lockSchedule(0)
    end
end

function Cannon:lockFish(fish)
	if fish then
		self.m_fishIndex = fish.fish_id
		if self.wChairID >= 2 then
			self.m_targetPoint = cc.p(ylAll.WIDTH - fish.Xpos, ylAll.HEIGHT - fish.Ypos)
		else
			self.m_targetPoint = cc.p(fish.Xpos, fish.Ypos)
		end
        if self.fishLocker then
           self.fishLocker:show():setPosition(fish:getPosition())
        end
	else
		self.m_fishIndex = cmd.INT_MAX
	end 
end

function Cannon:caclCannonAngle(nPos)
    self.m_targetPoint = nPos
    local angle = self:getAngleByTwoPoint(self.m_targetPoint,self.m_cannonPoint)
    if angle < 90 then
        self.pao:setRotation(angle)
    end
end

function Cannon:unlockFish()
    self:unLockSchedule()
end

--自己开火
function Cannon:SelfShoot(pos,isbegin)
    if not self.m_canShoot then  --不能开火
        self.m_isShoot = isbegin
        return 
    end
    self.m_targetPoint = pos
	--if self.m_autoShoot and self.m_autoLock == false then
		--return
	--end
    local score = self.parent.upscore[self.wChairID]
	if score < self.parent.shootingScore then
		self.m_autoShoot = false
		--self.m_autoLock = false
	   	--self.parent._gameView:setAutoShoot(false)
	   	--self.parent._gameView:setAutoLock(false)
        local item = self.parent._gameFrame:GetMeUserItem()
        showToast("Pontos insuficientes para disparar")
	   	--return
	end
    local angle = self:getAngleByTwoPoint(self.m_targetPoint,self.m_cannonPoint)
    if self.m_autoLock == false and angle < 90 then
        self.pao:setRotation(angle)
    end
    if self.m_autoShoot then 
       return 
    end  --自动射击，返回
    if not self.m_isShoot and isbegin then
        self.m_isShoot = true
        local time = 0.4 / self.m_cannonSpeed   --0.27 不加倍状态下
        self:autoUpdate(1)
        self:autoSchedule(time)
    end
	if not isbegin then
		self.m_isShoot = false
		self:unAutoSchedule()
	end
end

--其他玩家开火
function Cannon:othershoot( fire)
	--table.insert(self.bullet_data_list, fire)
	if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then 
        local x,y = self.pao:getPosition()
		self.m_cannonPoint = self:convertToWorldSpace(cc.p(x,y))
    end

	self.parent.upscore[fire.chair_id] = fire.total_fish_score
    self:updateUpScore(fire.total_fish_score)
    self:setDisplayLevel(self.parent.shootingScoreMap[fire.bullet_mulriple], true)

    local angle = fire.angle

    if fire.lock_fishid ~= 0 and fire.lock_fishid ~= cmd.INT_MAX then
	    local fish = self.parent.m_fishMap[fire.lock_fishid]
	    if fish then
	    	local fishPos = cc.p(fish.Xpos, fish.Ypos)
	    	if self.parent.m_nChairID >= 2 then
                fishPos.y = ylAll.HEIGHT - fishPos.y
                fishPos.x = ylAll.WIDTH - fishPos.x
            end
	    	angle = 90 - deg( atan2(fishPos.y - self.m_cannonPoint.y, fishPos.x - self.m_cannonPoint.x))

    		if self.parent.m_nChairID < 2 then
			    if fire.chair_id >= 2 then
			       angle = angle+180
			    end
			else
			    if fire.chair_id < 2 then
			       angle = angle+180
			    end
		    end
	    end
	else

    end
    -- print(angle)

	if self.parent.m_nChairID < 2 then
	    if fire.chair_id >= 2 then
	       angle = angle+180
	    end
	else
	    if fire.chair_id < 2 then
	       angle = angle+180
	    end
    end
    if self.m_autoLock == false then
       self.pao:setRotation(angle)
    end

    angle = rad(90-angle)
    local movedir = cc.pForAngle(angle)
    movedir = cc.p(movedir.x * 55 , movedir.y * 55)

    self.parent.effcache:playNode(self.pao_animation, false)
    self:productBullet(false,self.parent.m_fishIndex,fire)
end

function Cannon:updateUpScoreTask(score)
	self.parent.upscore[self.wChairID] =score
    self:updateUpScore(score)

end

function Cannon:updateUpScore(score)
	local serverKind = G_GameFrame:getServerKind()
	self.lb_upscore:setString(g_format:formatNumber(score,g_format.fType.Custom_k,serverKind))
	if self.adjust_icon then
		self.icon:setPositionX(self.lb_upscore:getPositionX() - self.lb_upscore:getContentSize().width-20)
	end
end

function Cannon:getAngleByTwoPoint( param,param1 )

   if type(param) ~= "table" or type(param1) ~= "table" then
   	  print("传入参数有误")
   	  return
   end

	local point = cc.p(param.x-param1.x,param.y-param1.y)
	local angle = 90 - deg(math.atan2(point.y, point.x))
   -- print("angle is ========>"..angle)
    return angle

end

return Cannon