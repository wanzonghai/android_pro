
local GameModel = appdf.req(appdf.CLIENT_SRC .. "gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)
local netdata = appdf.req(appdf.CLIENT_SRC .. "NetProtocol.NetData")

local module_pre = "game.yule.dntg.src"
local cmd = require(module_pre .. ".models.CMD_YQSGame")
local GameViewLayer = require(module_pre .. ".views.layer.GameViewLayer")
local Fish = require(module_pre .. ".views.layer.Fish1")
local CannonSprite = require(module_pre .. ".views.layer.Cannon1")
--local Shooter = require(module_pre .. ".views.layer.Shooter")

-- local Profiler = require(module_pre .. ".models.Profiler")
-- profiler1 = Profiler.new()
-- profiler2 = Profiler.new()

local Kind = require(module_pre..'.models.cfg_fish_kind')

-- local EffectCache = require(module_pre..'.models.EffectCache')
local EffectCache = require(appdf.CLIENT_SRC..'Tools.EffectCache')

local socket = require("socket")

local currentTime = currentTime

local sinf = math.sin
local cosf = math.cos
local rad = math.rad
local deg = math.deg
local atan2 = math.atan2
local floor = math.floor
local max = math.max
local random = math.random
local sqrt = math.sqrt
local abs = math.abs
local insert = table.insert
local remove = table.remove


local play_count = 4

local first_enter = false

local scheduler = cc.Director:getInstance():getScheduler()

local colors = {
    normal = cc.c3b(255,255,255),
    hit = cc.c3b(177,16,0),
}

local stat = {
    Loading = 1,
    Normal = 2,
    Exiting = 3,
    Frozening = 4,
}
local fish_tag = 2222
local winsize = cc.Director:getInstance():getVisibleSize()

local netSp = {
"cannon/images/dntgtest_Net_1_1.png",
"cannon/images/dntgtest_Net_1_1.png",
"cannon/images/dntgtest_Net_1_1.png",
"cannon/images/dntgtest_Net_2_1.png",
"cannon/images/dntgtest_Net_2_1.png",
"cannon/images/dntgtest_Net_2_1.png",
"cannon/images/dntgtest_Net_3_1.png",
"cannon/images/dntgtest_Net_3_1.png",
"cannon/images/dntgtest_Net_3_1.png",
"cannon/images/dntgtest_Net_3_1.png",
}

--求斜边长
function CalcDistance(x1, y1, x2, y2)
    return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

local random_map = {-- 鱼群随机位置，
    -50,6,-31,31,9,-2,-15,40,33,25,-33,36,21,1,-20,-49,-41,-14,-36,-34,49,-5,-38,-50,-50,-12,3,7,10,11,-34,16,
    -5,-15,-45,11,29,31,2,-20,38,23,46,43,4,-36,-4,-27,37,-29,28,35,50,50,11,-11,-24,-20,34,-48,-13,-41,18,-45,
    -50,42,-23,-23,9,19,34,23,-2,-30,25,-3,-4,45,25,-40,10,-12,24,11,7,-14,-35,-28,-8,31,2,49,25,-16,-33,16,-1,
    -44,20,0,
}

local fish_path = require(module_pre .. '.models.cfg_fish_path')

local screen = cc.rect(0, 0, ylAll.WIDTH, ylAll.HEIGHT)
local function isFishInScreen(fish)
    return cc.rectContainsPoint(screen, cc.p(fish:getPosition()))
end

function pSub(pt1,pt2)
    return {x = pt1.x - pt2.x , y = pt1.y - pt2.y }
end

function pGetLength(pt)
    return sqrt( pt.x * pt.x + pt.y * pt.y )
end

function pNormalize(pt)
    local length = pGetLength(pt)
    if 0 == length then
        return { x = 1.0,y = 0.0 }
    end

    return { x = pt.x / length, y = pt.y / length }
end

function GameLayer:ctor(frameEngine, scene)
    dismissNetLoading()
    GameLayer.super.ctor(self, frameEngine, scene)
    -- 播放背景音乐
    g_ExternalFun.playBackgroudAudio("buyuBgMusic1.mp3")

    self.effcache = EffectCache.new():addTo(self)

    self.stat = stat.Loading

    self.random_map = random_map
    self.special_fish_pos = {}--记录最后死掉的特殊鱼

    self.m_infoList = {}
    self.m_scheduleUpdate = nil
    self.m_secondCountSchedule = nil
    self._scene = scene
    self.m_bSynchronous = false
    self.m_nSecondCount = 60
    self.MinShoot = 1
    self.m_canShoot = true
    self.m_pao_hot = false
    self.m_curShootLevel = 1
    self.b_yuChaoBeforeCome = false  --是否鱼潮来临
    self.b_haveCreateYuchao = false    --已经生成了鱼潮
    self._gameFrame = frameEngine
    self._gameFrame:setKindInfo(cmd.KIND_ID, cmd.VERSION)
    self._roomRule = self._gameFrame._dwServerRule

    self._gameView = GameViewLayer:create(self):addTo(self)
    self._gameView:initView()

    self.m_pUserItem = self._gameFrame:GetMeUserItem()
    self.m_nTableID = self.m_pUserItem.wTableID
    self.m_nChairID = self.m_pUserItem.wChairID
    
    self.upscore = {}

    self.m_fishMap = {}
    self.m_fishList = {}

    self.busy_bullet = {}
    self.free_bullet = {}
    self.delay_fish_creator = {}

    --记录loading之前的鱼
    self.preloading_fish = {}
    self.close_perload_update = false
    self.bullet_limit_count = 80
    self.bullet_count = 0

    --机器人锁定相关
    self.lock_android_chair_id = {}  --机器人id
    self.lock_android_fish = {}   -- 帮助锁定机器人的鱼id
    self.is_help_android_lock = {}   --是否帮助机器人锁定

    -- 创建定时器
    self:onCreateSchedule()
    self.bEnterScene = false

    self.createYuChaoFunc = nil  --生成鱼潮的函数
    -- 注册通知
    self:addEvent()
    
    local rootNode = self._gameView.cannonLayer

	 --注册事件
    g_ExternalFun.registerTouchEvent(self,true)
    --[[rootNode:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            local pos = rootNode:getTouchBeganPosition()

            if self.shooter.autoLock then
                self:lockFishByPos(pos)
            end
            self.shooter.canShoot = true
            --self.shooter:shoot(cc.p(pos.x, pos.y), true)
            local cannon = self.chair_to_cannon[self.m_nChairID]
            cannon:SelfShoot(cc.p(pos.x, pos.y),true)
        elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            self.shooter.canShoot = false
            local pos = rootNode:getTouchEndPosition()
            local cannon = self.chair_to_cannon[self.m_nChairID]
            cannon:SelfShoot(cc.p(pos.x, pos.y),false)

        elseif eventType == ccui.TouchEventType.moved then
            local pos = rootNode:getTouchMovePosition()
            local cannon = self.chair_to_cannon[self.m_nChairID]
            cannon:SelfShoot(cc.p(pos.x, pos.y),true)
        end
        self:setSecondCount(60)
    end)]]
    self:initPoolObj()
end

function GameLayer:initPoolObj()
    local path1 = "FishEffect/dntg_fish_jinbi_10.png"
    local path2 = "FishEffect/dntg_fish_jinbi_10.plist"
    local path3 = "FishEffect/dntg_fish_jinbi_1.ExportJson"
    local animName = "dntg_fish_jinbi_1"
    local serverKind = G_GameFrame:getServerKind()
    if serverKind == G_NetCmd.GAME_KIND_TC then
        path1 = "FishEffect/anim/dntg_fish_jinbi_10_tc.png"
        path2 = "FishEffect/anim/dntg_fish_jinbi_10_tc.plist"
        path3 = "FishEffect/anim/dntg_fish_jinbi_1_tc.ExportJson"
        animName = "dntg_fish_jinbi_1_tc"
    end
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path1,path2,path3)
    self.m_armatureJinb = {}
    for i=1,30 do
        local armature = ccs.Armature:create(animName)
        armature:setVisible(false)
        self._gameView.effLayer:addChild(armature)
        self:addFishGold(armature)
    end
    -- 创建金币分数显示的文字缓存
    self.oGoldLabelNode = {}
    local fntFile = "font/fnt_gold.fnt"
    for k = 1, 10, 1 do
        local labelScore = cc.LabelBMFont:create( tostring(0), fntFile)
        labelScore:setAnchorPoint(cc.p(0.5, 0.5))
        labelScore:setPosition(15, 0)
        labelScore:setVisible( false )
        self:AddEffectUp(labelScore, "gold_hit_numbers.png")
        self:addGoldLabelNode(labelScore)
    end
    --创建金币
    self.oFishScoreNode = {}
    for k = 1, 10, 1 do
        --  然后创建一个fnt字体 +88888 添加到node中
        --"res/gameres/module/dntgtest/ui/fnt/buyuNumPlus/buyuNumPlus.fnt"
        local fntScore = cc.LabelBMFont:create( tostring(0),fntFile)
        fntScore:setAnchorPoint(cc.p(0, 0.5))
        fntScore:setPosition(15, 0)
        fntScore:setScale(0.5)
        self:AddEffectUp(fntScore, "fntScore")
        fntScore:setVisible( false )

        self:addFishScoreNode( fntScore )  
    end
end

function GameLayer:AddEffectUp(effect, key)
    if effect == nil then
        return
    end
    if( nil ~= self._gameView.effLayer ) then 
        if( nil == key ) then 
            self._gameView.effLayer:addChild(effect)
        else
            self._gameView.effLayer:addChild(effect, 100)
        end
    end
end
--缓存 
function GameLayer:addFishGold(obj)
    if( 50 < #self.m_armatureJinb ) then 
        if( obj ) then 
            obj:removeSelf()
            obj = nil
        end
    else
        self.m_armatureJinb[ #self.m_armatureJinb + 1 ] = obj
    end
end

function GameLayer:getOneFishGold()
    local len = #self.m_armatureJinb 
    local obj = self.m_armatureJinb[len]
    self.m_armatureJinb[len] = nil
    return obj    
end

function GameLayer:addGoldLabelNode( obj )
    if( 30 < #self.oGoldLabelNode ) then 
        if( obj ) then 
            obj:removeSelf()
            obj = nil
        end
    else
        self.oGoldLabelNode[ #self.oGoldLabelNode + 1 ] = obj
    end
end

function GameLayer:getOneGoldLabelNode( obj )
    --return remove(self.oGoldLabelNode, #self.oGoldLabelNode)
    local len = #self.oGoldLabelNode 
    local obj = self.oGoldLabelNode[len]
    self.oGoldLabelNode[len] = nil
    return obj    
end

function GameLayer:addFishScoreNode( obj )
    if( 30 < #self.oFishScoreNode ) then 
        if( obj ) then 
            obj:removeSelf()
            obj = nil
        end
    else
        self.oFishScoreNode[ #self.oFishScoreNode + 1 ] = obj
    end
end

function GameLayer:getOneFishScoreNode( obj )
    local len = #self.oFishScoreNode 
    local obj = self.oFishScoreNode[len]
    self.oFishScoreNode[len] = nil
    return obj    
    --return remove(self.oFishScoreNode, #self.oFishScoreNode)
end


function GameLayer:onTouchBegan(touch, event)
    if self.m_canShoot == false then return true end
    local pos = touch:getLocation()
    if self.myCannon.m_autoLock then
        self.myCannon.m_checkLongTouch = true
        self:lockFishByPos(pos)
    else
        if self.m_pao_hot or self.bullet_count > self.bullet_limit_count then
            showToast("Sobreaquecimento do barril, aguarde")
        end  
        self.myCannon.m_checkLongTouch = true
        self.myCannon:caclCannonAngle(pos)
    end
    
    --cannon:SelfShoot(cc.p(pos.x,pos.y),true)
   
    return true
end
function GameLayer:onTouchMoved(touch, event)
    if self.m_canShoot == false then return end
    local pos = touch:getLocation()
    if not self.lockedFish then  --非锁定状态下计算炮台位置
        self.myCannon:caclCannonAngle(pos)
    end
    --local cannon = self.chair_to_cannon[self.m_nChairID]
    --cannon:SelfShoot(cc.p(pos.x,pos.y),true)

end
function GameLayer:onTouchEnded(touch, event)
    local pos = touch:getLocation()
    self.myCannon.m_checkLongTouch = false
    if not self.lockedFish then  --非锁定状态下计算炮台位置
        self.myCannon:caclCannonAngle(pos)
    end
    --local cannon = self.chair_to_cannon[self.m_nChairID]
    --cannon:SelfShoot(cc.p(pos.x,pos.y),false) 
end

-- 获取gamekind
function GameLayer:getGameKind()
    return cmd.KIND_ID
end

function GameLayer:enterBackground()
    self._gameView:setAutoLock(false)
    self._gameView:setAutoShoot(false)  
    self.lockedFish = nil

    if self.myCannon.m_autoLock then
        self:UnlockFish()
    end
    self.myCannon:AutoShoot(false)  
    self.myCannon:AutoLock(false)
    self.bEnterScene = false

    self.is_help_android_lock = {}
    self.lock_android_fish = {}

end

function GameLayer:onEnterBackground()
    --self.shooter:stop()
    --self.shooter:setAutoLock(false)
    --self.shooter:setAutoShoot(false)
    self._gameView:setAutoLock(false)
    self._gameView:setAutoShoot(false)
    self._gameView:clearCannonSpeed()

    self:stopAllActions()

    --self.fishLocker = nil
    self._gameView.fishLockViewer:hide()

    self._gameView.fishLayer:removeAllChildren()
    self._gameView.effLayer:removeAllChildren()
    self._gameView.bulletLayer:removeAllChildren()

    self.lockedFish = nil
    self.busy_bullet = {}
    self.m_fishMap = {}
    self.m_fishList = {}
    self.delay_fish_creator = {}
    self.upscore = {}
end

function GameLayer:setMyMul(level, snd,bSecond)

    local now = currentTime()
    if self.lastUpTime then
        if now - self.lastUpTime < 400 then
            return
        end
    end
    self.lastUpTime = now

    if snd then
        ef.playEffect(cmd.SWITCHING_RUN)
    end


    if level > #self.shootingScoreSet then
        level = 1
    elseif level < 1 then
        level = #self.shootingScoreSet
    end
    --self.shooter.shootingLevel = level
    --self.shooter.shootingScore = self.shootingScoreSet[level]
    self.shootingScore = self.shootingScoreSet[level]

    --[[if self.myCannon.m_autoShoot then
        if self.bullet_count < self.bullet_limit_count then
            return
        end
    end

    if self.myCannon.m_autoLock then
        if self.lockedFish and self.bullet_count < self.bullet_limit_count then
            return
        end
    end]]
    self.m_curShootLevel = level
    local cannon = self.chair_to_cannon[self.m_nChairID]
    cannon:setDisplayLevel(self.m_curShootLevel, not bSecond)
end

function GameLayer:initCannon()

    local rootNode = self._gameView.cannonLayer
    self:ClearCannon()  --清理一下炮台 
    if not self.chair_to_cannon then
        self.chair_to_cannon = {}
    end
    for i=1, 4 do
        if not self.chair_to_cannon[i-1] then
            local cannonNode = rootNode:getChildByName("Node_"..i):hide()
            cannonNode:setLocalZOrder(1)
            local cannon = CannonSprite:create(self):addTo(cannonNode)
		    
            cannon.lb_mul = cannonNode:getChildByName("num")
            cannon.lb_upscore = cannonNode:getChildByName("num2")
            cannon.inc = cannonNode:getChildByName("+")
            cannon.dec = cannonNode:getChildByName("-")
            cannon.pao = cannonNode:getChildByName("pao")
            cannon.goldbg = cannonNode:getChildByName("bg")
            cannon.icon = cannonNode:getChildByName("Image_1")
            cannon.lb_name = cannonNode:getChildByName("name")
            cannon.locked_fish_id = 0

            local icon = cannonNode:getChildByName("Image_1")
            local currencyType = G_GameFrame:getServerKind()
            g_ExternalFun.setIcon(icon,currencyType)

		    
            local eff = self.effcache:getAndPlay('getgold')
            eff:addTo(cannon.icon:getParent(), 222)
            eff:setPosition(cannon.icon:getPosition())
            cannon.getgold = eff
		    
            cannon.adjust_icon = (i==1 or i == 4)
		    
            cannon.node = cannonNode
            cannon.viewID = i
            cannon:setup()
		    
            self.chair_to_cannon[i-1] = cannon
        end
    end

    -- 屏幕翻转
    if self.m_nChairID == 2 or self.m_nChairID == 3 then
        self._gameView.fishLayer:setRotation(180)
        local conv = {3,4,1,2}

        local nodes = {}
        for i=1, 4 do
            nodes[i-1] = self.chair_to_cannon[conv[i]-1]
        end

        self.chair_to_cannon = nodes
    end

        --初始化自己炮台
    local myCannon = self.chair_to_cannon[self.m_nChairID]
    myCannon:initWithUser(self.m_pUserItem,self.m_curShootLevel)
    --[[if self.shooter then
        self.shooter:removeSelf()
    end]]

    self._gameView:clearCannonSpeed()

    --local shooter = Shooter.new(self, self.m_nChairID):addTo(myCannon)
    --shooter.cannonPoint = myCannon.pao:convertToWorldSpaceAR(cc.p(0, 0))
    --myCannon.m_cannonPoint = shooter.cannonPoint
    --local angle = myCannon.pao:getRotation()
    --angle = rad(90-angle)
    --shooter.targetPoint = cc.pAdd(cc.pForAngle(angle), shooter.cannonPoint)

    --shooter.frameEngine = self._gameFrame
    --self.shooter = shooter
    self.myCannon = myCannon
end 

function GameLayer:ClearCannon()
    self._gameView:setAutoLock(false)
    self._gameView:setAutoShoot(false)  
    self.lockedFish = nil

    if not self.myCannon then return end
    if self.myCannon.m_autoLock then
        self:UnlockFish()
    end
    self.myCannon:AutoShoot(false)  
    self.myCannon:AutoLock(false)
end

function GameLayer:lockFishByPos(pos)
    local pos = self._gameView.fishLayer:convertToNodeSpace(pos)
    --for id, fish in pairs(self.m_fishMap) do
    for i=1,#self.m_fishList do
        local fish = self.m_fishList[i]
        if self:isMaxFish(fish) and CalcDistance(fish.Xpos, fish.Ypos, pos.x, pos.y) <= 80 then
            -- cc.rectContainsPoint(fish:getBoundingBox(), pos) then
            self:lockFish(fish)
            break
        end
    end
end

function GameLayer:setCannonSpeed(speed)
    local myCannon = self.chair_to_cannon[self.m_nChairID]    
    myCannon:setCannonSpeed(speed)
end

function GameLayer:isMaxFish(fish)
    return fish.fish_kind > 10 or (fish.m_data.fish_buff and fish.m_data.fish_buff > 0)
end

function GameLayer:selectRandomMaxFishId()
    local selected = nil
    --for id, fish in pairs(self.m_fishMap) do
    for i=1,#self.m_fishList do
        local fish = self.m_fishList[i]
        if self:isMaxFish(fish) and isFishInScreen(fish) then
            if random(1, 100) > 60 then
                selected = fish
            end
        end
    end
    if selected == nil then
        return 0
    end
    return selected.fish_id
end

--机器人锁定鱼
function GameLayer:helpLockAndroidFish(chair_id)
    local selected = nil
    --for id, fish in pairs(self.m_fishMap) do
    for i=1,#self.m_fishList do
        local fish = self.m_fishList[i]
        if self:isMaxFish(fish) and isFishInScreen(fish) then
           --if random(1, 100) > 60 then
               selected = fish
           --end
        end
    end   
    if selected then
        self:sendLockFish(chair_id,selected.fish_id,true) --锁定
        self.lock_android_fish[chair_id] = selected
    else
        self:sendLockFish(chair_id,-1,false) --取消锁定
        self.is_help_android_lock[chair_id] = false
    end
end


function GameLayer:lockMaxFish(except)
    local selected = nil
    --for id, fish in pairs(self.m_fishMap) do
    for i=1,#self.m_fishList do
        local fish = self.m_fishList[i]
        if except ~= fish then
            if self:isMaxFish(fish) and isFishInScreen(fish) then
                selected = fish
            end
        end
    end

    self:lockFish(selected)
end

function GameLayer:lockNextFish()
    self:lockMaxFish(self.lockedFish)
end

function GameLayer:lockFish(fish)

    if fish ~= nil and fish ~= self.lockedFish then
        local parent = self._gameView.fishLockViewer:getChildByName("pos")
        parent:removeAllChildren()
        local node = self:createFishForDisplay(fish.m_data):addTo(parent)

        local cfg = Kind.BuffFishConfig[fish.m_data.fish_buff]
        if cfg then
            node:setScale(cfg.lockScale)
        else
            node:setScale(Kind.EffConfig[fish.fish_kind].lockScale)
        end
        self._gameView.fishLockViewer:show()
    end
    --
    if (not self.lockedFish and fish) or (self.lockedFish and fish and self.lockedFish.fish_id ~= fish.fish_id) then  --需要发送锁定鱼协议
       self:sendLockFish(self.m_nChairID,fish.fish_id,true)
    end
    if fish == nil then
       self:sendLockFish(self.m_nChairID,0,false) --取消锁定
    end
    self.lockedFish = fish
    self.myCannon:lockFish(self.lockedFish) 
    
end

function GameLayer:UnlockFish()
    self:sendLockFish(self.m_nChairID,0,false) --取消锁定
end

function GameLayer:showCannonByChair(wChairID)
    if not self.chair_to_cannon then return end

    local cannon = self.chair_to_cannon[wChairID]

    cannon.node:show()

    if wChairID == self.m_nChairID then
        cannon.inc:show():onClicked(function() self:setMyMul(self.m_curShootLevel + 1, true) end)
        cannon.dec:show():onClicked(function() self:setMyMul(self.m_curShootLevel - 1, true) end)
    else
        cannon.inc:hide()
        cannon.dec:hide()
    end

    local serverKind = G_GameFrame:getServerKind()
    cannon.lb_mul:setString(g_format:formatNumber(self.shootingScoreSet[1],g_format.fType.standard,serverKind))
        
end

function GameLayer:addEvent()

    -- 通知监听
    local function eventListener(event)
        -- 创建物理世界
        cc.Director:getInstance():getRunningScene():initWithPhysics()
        local world = cc.Director:getInstance():getRunningScene():getPhysicsWorld()
        world:setGravity(cc.p(0, -100))
        -- world:setDebugDrawMask(3)

        self:createWaveAnimation()

        self:startUp()

        local cmddata = CCmd_Data:create(0)
        cmddata:setcmdinfo(G_NetCmd.MAIN_GAME, cmd.SUB_C_USER_ALREADY)
        if not self._gameFrame:sendSocketData(cmddata) then
            print("发送准备消息失败")
        end
    end

    local listener = cc.EventListenerCustom:create(cmd.Event_LoadingFinish, eventListener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end

function GameLayer:createWaveAnimation()
    local node = self.effcache:play(self._gameView.gameLayer, 'WaterAnim', true)
    node:move(display.center)
end

--撒网
local netOffset = 30
function GameLayer:fallingNet(bullet)

    local pos = cc.p(bullet:getPositionX(), bullet:getPositionY())
    local angle = bullet:getRotation()
    pos.x = pos.x + netOffset * bullet.movedir.x
    pos.y = pos.y + netOffset * bullet.movedir.y
    --pos.x = pos.x + netOffset * math.sin(angle)
    --pos.y = pos.y + netOffset * math.cos(angle)

    local node = cc.Sprite:createWithSpriteFrameName(netSp[bullet.cannonLevel])--self.effcache:getAndPlay('net_'..bullet.cannonLevel, true)
    node:setPosition(pos)
    node:addTo(self._gameView.cannonLayer)
    node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1.1),cc.CallFunc:create(function()
        node:removeSelf()
    end)))
end

function GameLayer:onContact(fish, bullet)
    if bullet.ifdie then
        return
    end
    if bullet.chair_id == self.m_nChairID then
        self.bullet_count = max(self.bullet_count - 1, 0)
    end
    --自己或者为机器人计算
    if bullet.chair_id == self.m_nChairID or bullet.proxy_chairId == self.m_nChairID then
        self:sendCatchFish(bullet, fish)
    end

    if fish.mainfish then
        fish.mainfish.hitTime = currentTime()
    else
        fish.hitTime = currentTime()
    end

    -- 
    if not self.fallingNet then
        return
    end
    self:fallingNet(bullet)
    local len = #self.busy_bullet
    local _index = 0
    for i, v in ipairs(self.busy_bullet) do
        if v == bullet then
            --remove(self.busy_bullet, i)
            _index = i
            break
        end
    end
    for i=_index,len-1 do
        self.busy_bullet[i] = self.busy_bullet[i+1] 
    end
    self.busy_bullet[len] = nil
    bullet.ifdie = true

    bullet:removeSelf()
end

-- 添加碰撞
function GameLayer:addContact()

    local function onContactBegin(contact)

        local a = contact:getShapeA():getBody():getNode()
        local b = contact:getShapeB():getBody():getNode()
        if not a or not b then return end

        local bullet, fish

        if a and b then
            if a:getT() == 2 then
                bullet = a
                fish = b
            else
                bullet = b
                fish = a
            end
        end

        if bullet.m_fishIndex ~= cmd.INT_MAX and bullet.m_fishIndex ~= 0 then
            if bullet.m_fishIndex ~= fish.fish_id then
                return false
            end
        end
        self:onContact(fish, bullet)
        return true
    end

    local dispatcher = self:getEventDispatcher()
    self.contactListener = cc.EventListenerPhysicsContact:create()
    self.contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    dispatcher:addEventListenerWithSceneGraphPriority(self.contactListener, self)

end

function GameLayer:sendCatchFish(bullet, fish)
    local cmddata = CCmd_Data:create(18)
    cmddata:setcmdinfo(G_NetCmd.MAIN_GAME, cmd.SUB_C_CATCH_FISH);
    cmddata:pushword(bullet.chair_id)
    cmddata:pushint(bullet.m_Type)
    cmddata:pushint(bullet.m_bulletId) --m_index
    cmddata:pushint(bullet.m_nScore)


    --[[if Kind.BombFish[fish.fish_kind] then
        local fishes = {fish.fish_id}

        local range = Kind.BombFish[fish.fish_kind]

        for i, select_fish in ipairs(self.m_fishList) do
            if select_fish ~= fish and CalcDistance(select_fish.Xpos, select_fish.Ypos, fish.Xpos, fish.Ypos) <= range then
                table.insert(fishes, select_fish.fish_id)
            end
        end

        cmddata:pushint(#fishes)
        for i, v in ipairs(fishes) do
            cmddata:pushint(v)
        end
    else
        cmddata:pushint(1)
        cmddata:pushint(fish.fish_id)
    end  ]]
     cmddata:pushint(fish.fish_id)
    -- 发送失败
    if not self._gameFrame:sendSocketData(cmddata) then
        if self._gameFrame then
            self._gameFrame._callBack(-1, "Falha no envio da mensagem de captura")
        end
    end
end

function GameLayer:sendLockFish(chair_id,fish_id,islock)
    islock = islock or false
    local cmddata = CCmd_Data:create(7) 
    cmddata:setcmdinfo(G_NetCmd.MAIN_GAME, cmd.SUB_C_PLAYER_LOCK_FISH)
    cmddata:pushword(chair_id)
    cmddata:pushint(fish_id)
    cmddata:pushbool(islock)
    if not self._gameFrame:sendSocketData(cmddata) then
        if self._gameFrame then
            self._gameFrame._callBack(-1, "Falha no envio de uma mensagem de bloqueio")
        end
    end
end

-- 60开炮倒计时
function GameLayer:setSecondCount(dt)
    self.m_nSecondCount = dt

    if dt == 1000 then
        self._gameView.tipnode:hide()
    end
end

local for_array = ef.for_array
local for_arry_new = ef.for_array_new


-- 创建定时器
function GameLayer:onCreateSchedule()

     local function bullet_update(dt)

        for i = #self.busy_bullet, 1, -1  do 
            local bullet = self.busy_bullet[i]

            -- 子弹移动
            local _x,_y = bullet:getPosition()
            local angle,pox,poy,movedirx,movediry=CCCalcuBullet(_x,_y,bullet.movedir.x,bullet.movedir.y,bullet.speed,dt)
             --bullet:getPositionX() + bullet.movedir.x * bullet.speed * dt
            --local poy = bullet:getPositionY() + bullet.movedir.y * bullet.speed * dt

            if pox <= 0 then bullet.movedir.x = movedirx end
            if pox >= winsize.width then bullet.movedir.x = - movedirx end
            if poy >= winsize.height then bullet.movedir.y = - movediry end
            if poy <= 0 then bullet.movedir.y = movediry end

            --local angle = deg(atan2(bullet.movedir.x, bullet.movedir.y))
            --local angle = CCDeg(bullet.movedir.x, bullet.movedir.y)
            bullet:setRotation(angle)
            bullet:setPosition(cc.p(pox, poy))

            if bullet.m_fishIndex ~= cmd.INT_MAX and bullet.m_fishIndex ~= 0 then
                local fish = self.m_fishMap[bullet.m_fishIndex]
                if not fish then
                    bullet.m_fishIndex = cmd.INT_MAX
                else
                    local fishPos = cc.p(fish.Xpos, fish.Ypos)

                    if self.m_nChairID >= 2 then
                        fishPos.y = ylAll.HEIGHT - fishPos.y
                        fishPos.x = ylAll.WIDTH - fishPos.x
                    end

                    local bulletPos = cc.p(pox, poy)--cc.p(bullet:getPosition())
                    --bullet.movedir = pNormalize(pSub(fishPos, bulletPos))
                    bullet.movedir.x,bullet.movedir.y = CCNormalize(fishPos.x,fishPos.y,bulletPos.x,bulletPos.y)
                end
            end
        end
    end


    local function delay_fish_creator_update(dt)
        if self.stat ~= stat.Normal then 
            return
        end

        for_arry_new(self.delay_fish_creator, function(e)
            e.t = e.t - dt
            if e.t <= 0 then
                e.f()
                return true
            end
        end)
    end

    local function locker_update(dt)
        if self.myCannon and self.myCannon.m_autoLock then
            if not self.lockedFish then
                self:lockMaxFish()
                if not self.lockedFish then
                    --self.fishLocker:hide()
                    self._gameView.fishLockViewer:hide()
                end
            end

            if self.lockedFish then
                --self.fishLocker:show():setPosition(self.lockedFish:getPosition())
                self.myCannon:lockFish(self.lockedFish) 
            else
                --self.shooter:lockFish()
                self.myCannon:lockFish() 
            end
        end
    end
    local function locker_android_update(dt)
        if self.stat == stat.Loading then return end
        for i=0,play_count-1 do
            local isLock = self.is_help_android_lock[i]
            if isLock == true and not self.lock_android_fish[i] then
               self:helpLockAndroidFish(i)
            end
        end
        --[[for i,v in pairs(self.is_help_android_lock) do
            if v == true and not self.lock_android_fish[i] then  --需要锁定，且没有找锁定鱼
               self:helpLockAndroidFish(i)
            end
        end]]
    end
    local function fish_update(now, dt)
         for_arry_new(self.m_fishList, function(fish)
            if fish.runner then

                if self.stat == stat.Normal then
                    fish.bornTime = fish.bornTime + dt
                    fish.runner.step(fish, dt)
                end

                if fish.hitTime then
                    if now - fish.hitTime > 100 then
                        fish:setColor(colors.normal)
                        fish.hitTime = nil
                    else
                        fish:setColor(colors.hit)
                    end
                end
                if fish.ifdie then
                    if fish == self.lockedFish then                    
                        self.lockedFish = nil
                    end
                    for i=0,play_count-1 do
                       local _lockFish = self.lock_android_fish[i]
                       if _lockFish and fish == _lockFish then
                           self.lock_android_fish[i] = nil
                       end
                    end
                    --[[for i,v in pairs(self.lock_android_fish) do
                       if v == fish then
                          self.lock_android_fish[i] = nil
                       end
                    end]]
                    self.m_fishMap[fish.fish_id] = nil
                    -- 机器人重新锁定
                    --[[for wChairID, cannon in pairs(self.chair_to_cannon) do
                        if cannon.locked_fish_id == 0 or cannon.locked_fish_id == fish.fish_id then
                            cannon.locked_fish_id = self:selectRandomMaxFishId()
                        end
                    end]]
                    self.effcache:addLeaveFish(fish:getChildByTag(fish_tag))
                    fish:removeSelf()

                    return true

                elseif isFishInScreen(fish) then-- 鱼在屏幕中
                    fish.alive = true
                elseif fish.alive then-- 如果鱼没有在屏幕中，但是在屏幕中间去过，标记为死亡
                    fish.ifdie = true
                elseif fish.bornTime > 60 then-- 鱼没有去过屏幕中，但是生命超过二十秒，标记死亡
                    fish.ifdie = true
                end
            end
        end)
    end
    
    local function perloading_fish_update(now,dt)
        if self.close_perload_update then return end
        for_arry_new(self.preloading_fish, function(fish_data)
            local path = fish_data.path
            if path.delay_time and path.delay_time > 0 then
                path.delay_time = path.delay_time - dt
                return
            end
            if path.type == 1 then  --直线
                path.new_x = path.new_x + dt * path.speed.x * 0.7
                path.new_y = path.new_y + dt * path.speed.y * 0.7        
            elseif path.type == 2 then   --贝塞尔
               path._new_time = path._new_time + dt * path.speed.x * 0.7
		       
               local x,y = CCCalcuBezier(path.ori.x,path.ori.y,path.c1.x,path.c1.y,path.c2.x,path.c2.y,path.dst.x,path.dst.y,path._new_time)
               path.new_x = x
               path.new_y = y
            end
        end)
    end

    local last = currentTime()
    local function update()
        local now = currentTime()
        local dt = (now - last) / 1000
        last = now
        bullet_update(dt)
        delay_fish_creator_update(dt)
        locker_update(dt)
        locker_android_update(dt)
        fish_update(now, dt)
        perloading_fish_update(now,dt)
    end

    self:onUpdate(update)
end


function GameLayer:createSecoundSchedule()
    local function update(dt)
        if self.m_nSecondCount > 100 then return end
        if self.m_nSecondCount <= 0 then
            self:exitGame()
        end
        if self.m_nSecondCount -1 >= 0 then
            self.m_nSecondCount = self.m_nSecondCount -1
        end
        local tipnode = self._gameView.tipnode
        if self.m_nSecondCount <= 10 then
            tipnode:getChildByName('tip_0'):setString( string.format("%d Seg", self.m_nSecondCount))
            tipnode:show()
        else
            tipnode:hide()
        end
    end
    if nil == self.m_secondCountSchedule then
        self.m_secondCountSchedule = scheduler:scheduleScriptFunc(update, 1.0, false)
    end
end

function GameLayer:onEnter()
end

function GameLayer:onEnterTransitionFinish()
    -- 碰撞监听
    self:addContact()
end

function GameLayer:onExit()
    print("gameLayer onExit()....")
    -- 移除碰撞监听
    cc.Director:getInstance():getEventDispatcher():removeEventListener(self.contactListener)
    cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(cmd.Event_LoadingFinish)
    self:clearEffect()
    
    for i = #self.busy_bullet, 1, -1  do 
        self.busy_bullet[i]:removeSelf()
    end
    self.busy_bullet = nil
    if self.chair_to_cannon then
       for i,v in pairs(self.chair_to_cannon) do
           v:onExit()
       end
    end
    for i = #self.m_fishList, 1, -1  do 
         self.m_fishList[i]:removeSelf()
    end
    self.m_fishMap = nil
    self.m_fishList = nil
    self.delay_fish_creator =nil
    self.preloading_fish = nil
    self._gameView:onExit()
    if nil ~= self.m_secondCountSchedule then
		scheduler:unscheduleScriptEntry(self.m_secondCountSchedule)
		self.m_secondCountSchedule = nil        
    end
    self.effcache:releaseAll()
    self.effcache:removeSelf()

    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    GameModel.onExit(self)

    AudioEngine.stopMusic()
    self:unloadScript()



    local path3 = "FishEffect/dntg_fish_jinbi_1.ExportJson"
    local serverKind = G_GameFrame:getServerKind()
    if serverKind == G_NetCmd.GAME_KIND_TC then
        path3 = "FishEffect/anim/dntg_fish_jinbi_1_tc.ExportJson"
    end
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(path3)
end

function GameLayer:unloadScript()
    local module_pre = "game.yule.dntg.src"	
    package.loaded[module_pre..".ui.PreLoading"] = nil
    package.loaded[module_pre..".views.layer.Bullet1"] = nil
    package.loaded[module_pre..".views.layer.Cannon1"] = nil
    package.loaded[module_pre ..".views.layer.Fish1"] = nil
    package.loaded[appdf.GAME_SRC.."yule.dntg.src.layer.GameViewLayer"] = nil
    package.loaded[appdf.GAME_SRC.."yule.dntg.src.views.GameLayer"] = nil
end

function GameLayer:clearEffect()
    self.m_armatureJinb = nil
    self.oGoldLabelNode = nil
    self.oFishScoreNode = nil
end

function GameLayer:clearUser(wChairID)
    if self.chair_to_cannon then

        print('清理用户', wChairID)
        local cannon = self.chair_to_cannon[wChairID]
        cannon:updateUpScore(0)
        cannon.node:hide()
        cannon:ClearSchedule()
        if wChairID == self.m_nChairID then
            showToast("Erro de rede, tente novamente mais tarde")
            self:onExitRoom()
        end
    end
    if self.is_help_android_lock then
        self.is_help_android_lock[wChairID] = false
    end
end

function GameLayer:updateUser(useritem)
    if not self.chair_to_cannon then return end
    print('更新用户', useritem.wChairID)

    local wChairID = useritem.wChairID
    self:showCannonByChair(wChairID)

    local cannon = self.chair_to_cannon[wChairID]
    cannon:initWithUser(useritem)
    if self.upscore then 
        self.upscore[wChairID] = useritem.lScore
        cannon:updateUpScore(self.upscore[wChairID] or 0) 
    end
    if wChairID ~= self.m_nChairID and self.myCannon.m_autoLock then
        if self.myCannon.m_fishIndex ~= nil or self.myCannon.m_fishIndex ~= cmd.INT_MAX then  --自己是锁定状态
            self:sendLockFish(self.m_nChairID,self.myCannon.m_fishIndex,true)
        end
    end
end

function GameLayer:onEventUserEnter(wTableID, wChairID, userItem)
    if wTableID ~= self:GetMeUserItem().wTableID or userItem.cbUserStatus == G_NetCmd.US_LOOKON then  --不是本桌用户
        return 
    end    
    if wTableID >= 65536 or wChairID >= 65535 then return end
    userItem.wTableID = wTableID
    userItem.wChairID = wChairID
    self:updateUser(userItem)
end

-- 用户状态
function GameLayer:onEventUserStatus(useritem, newstatus, oldstatus)
    print('状态变化', newstatus.wChairID, newstatus.cbUserStatus, oldstatus.cbUserStatus)

    if useritem.cbUserStatus == G_NetCmd.US_LOOKON then
        return
    end
    if oldstatus.cbUserStatus == G_NetCmd.US_FREE then
        if newstatus.wTableID ~= self.m_nTableID  then  --不是本桌用户
            return
        end
    end
    if newstatus.cbUserStatus == G_NetCmd.US_FREE or newstatus.cbUserStatus == G_NetCmd.US_NULL then
        if oldstatus.wTableID ~= self.m_nTableID  then  --不是本桌用户
            return
        end
    end
    if newstatus.cbUserStatus == G_NetCmd.US_FREE or newstatus.cbUserStatus == G_NetCmd.US_NULL then
        self:clearUser(oldstatus.wChairID)
    else
        if oldstatus.cbUserStatus == G_NetCmd.US_FREE  then
            if newstatus.wTableID ~= self.m_nTableID  then  --不是本桌用户
                return
            end
            self.upscore[newstatus.wChairID] = useritem.lScore
            self:updateUser(useritem)
        end
    end
    if newstatus.cbUserStatus == G_NetCmd.US_OFFLINE then
        if newstatus.wTableID ~= self.m_nTableID  then  --不是本桌用户
            return
        end
        if not self.chair_to_cannon then return end
        local cannon = self.chair_to_cannon[useritem.wChairID]
        if cannon then
            cannon:ClearSchedule()
        end
    end
end

-- 用户分数
function GameLayer:onEventUserScore(item)
    print("fishlk onEventUserScore...")
end

-- 初始化游戏数据
function GameLayer:onInitData()

end

-- 重置游戏数据
function GameLayer:onResetData()
    -- body
end

function GameLayer:setUserMultiple()
    -- 设置炮台倍数
    local tableId = self._gameFrame:GetTableID()
    for i=1, 4 do
        local wChairID = i - 1
        local useritem = self._gameFrame:getTableUserItem(tableId, wChairID)
        local cannon = self.chair_to_cannon[wChairID]
        cannon:setDisplayLevel(1)
        if useritem then
            self.upscore[wChairID] = useritem.lScore
            cannon:updateUpScore(self.upscore[wChairID])
        else
            cannon:updateUpScore(0)
        end
    end
end

-- 场景信息

function GameLayer:onEventGameScene(cbGameStatus, dataBuffer)
    print('场景消息')
    if self.bEnterScene == true then return end
    self.bEnterScene = true
    local systime = currentTime()

    local scene = netdata.read(cmd.GameScene, dataBuffer)
    self._sceneMsg = scene
    dump(scene)

    self.upscore = {}
    for i=0,cmd.GAME_PLAYER-1 do
        self.upscore[i] = scene.fish_score[i+1]
    end

    if self.stat ~= stat.Loading then
        self:startUp(self.m_curShootLevel,true)
    end
    if self.stat ~= stat.Loading then
       self:SetSelfBulletIndex(scene.bullet_index)
    end
    if self.stat ~= stat.Loading then
       if self._sceneMsg.is_lock_scene == false then
           self:killFrozen(self.stat)
       elseif self._sceneMsg.is_lock_scene == true then
           --self.stat = stat.Frozening
           self:effect_Ding()
       end 
    end
    self.m_pao_hot = self._sceneMsg.is_no_fire
end

function GameLayer:startUp(shootLevel,bSecond)

    self.stat = stat.Normal

    local scene = self._sceneMsg

    self.m_pUserItem = self._gameFrame:GetMeUserItem()
    local oldTableId = self.m_nTableID
    local oldChairId = self.m_nChairID
    self.m_nTableID = self:GetMeUserItem().wTableID
    self.m_nChairID = self:GetMeUserItem().wChairID
    if oldTableId ~= self.m_nTableID or oldChairId ~= self.m_nChairID then
        showToast("Desconectado, logue novamente!")
        self:onExitRoom()
        return
    end
    self.MaxShoot = scene.MaxShoot
    self.MinShoot = scene.MinShoot

    self.shootingScoreSet = {self.MinShoot}

    for i=1, 10 do 
        local score = self.MinShoot + i * self.gameConfig.exchange_bullet_count
        if score <= self.MaxShoot then
            insert(self.shootingScoreSet, score)
        end
    end

    self.shootingScoreMap = {}
    for i, v in ipairs(self.shootingScoreSet) do
        self.shootingScoreMap[v] = i
    end

    --dump(self.shootingScoreSet)

    local isAutoShoot = false
    if first_enter == true and self.chair_to_cannon then
        local cannon = self.chair_to_cannon[self.m_nChairID]
        if cannon and cannon.m_autoShoot ==true then
            isAutoShoot = true
        end
    end

    -- 60秒未开炮倒计时
    self:setSecondCount(1000)
    self:createSecoundSchedule()

    self:initCannon()


    -- self.upscoreChangeTime = {}
    self.bullet_count = 0


    local tableId = self._gameFrame:GetTableID()
    --初始化已有玩家
    for i = 1, cmd.GAME_PLAYER do
        local wChairID = i - 1
        local useritem = self._gameFrame:getTableUserItem(tableId, wChairID)
        
        if nil ~= useritem then
            self:updateUser(useritem)
        else
            self:clearUser(wChairID)
        end
    end

    self:showCannonByChair(self.m_nChairID)
    --如果是鱼阵
    if first_enter == true and isAutoShoot then
       self._gameView:setAutoShoot(true)
       self:setAutoShoot(true)
    end
    first_enter = true
    self:setUserMultiple()
    local level = shootLevel or 1
    self:setMyMul(level,false,bSecond)
    --self.shooter:start()

    self:SetSelfBulletIndex(self._sceneMsg.bullet_index)

    --if not self.fishLocker then
        --self.fishLocker = display.newSprite('#cannon/images/dntgtest_battle_ui_lock_flag.png')
        --self.fishLocker:addTo(self._gameView.fishLayer, 99):hide()
    --end
    if not scene.isYuZhen then 
        --创建鱼
        local nowTime = socket.gettime()
        local count = #self.preloading_fish
        for i=1,count do
            local fishdata = self.preloading_fish[i]--remove(self.preloading_fish,1)
            self:createFish(fishdata)
        end
    end
    self.preloading_fish = {}
    self.close_perload_update = true
    applyFunction(self.createYuChaoFunc)
    self.createYuChaoFunc = nil
end

function GameLayer:SetSelfBulletIndex(bullet_index)
    if self.myCannon then
       self.myCannon:SetBulletIndex(bullet_index)
    end
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub, dataBuffer)
    if self.m_bLeaveGame or nil == self._gameView then
        print('未处理')
        return
    end

    if self.stat == stat.Loading then
        if sub == cmd.SUB_S_TRACE_POINT then
            self:cachePerloadingFish(dataBuffer)
        elseif sub == cmd.SUB_S_FISH_GROUP then -- 鱼群
            self:cachePerloadingFishGroup(dataBuffer)
        end 
    end
    if sub == cmd.SUB_S_GAME_CONFIG then
        self.gameConfig = g_ExternalFun.read_netdata(cmd.CMD_S_GameConfig, dataBuffer)
        self.bullet_limit_count = self.gameConfig.EmptyFireCount
    elseif sub == cmd.SUB_S_EXCHANGE_GAME_SCENEING then   --鱼阵
        if self.stat == stat.Loading then
           self:onSubExchangeGameSceneing(dataBuffer)
        end
    elseif self.stat ~= stat.Loading and self.stat ~= stat.Exiting then
        if sub == cmd.SUB_S_CATCH_FISH then
            -- 捕获鱼
            self:onSubFishCatch(dataBuffer)
        elseif sub == cmd.SUB_S_CATCH_SWEEP_FISH then
            --抓到BOSS和炸弹时
            self:onSubCatchFishKing(dataBuffer)
        elseif sub == cmd.SUB_S_CATCH_SWEEP_FISH_RESULT then
            --抓到BOSS和炸弹的结果
            --self:onSubCatchFishKingResult(dataBuffer)
        elseif sub == cmd.SUB_S_PLAYER_LOCK_FISH then   --锁定鱼
            self:onSubLockFish(dataBuffer)
        elseif sub == cmd.SUB_S_SWITCH_SCENE_PRESAGE then   --鱼潮要来了
            self.b_yuChaoBeforeCome = true
            self.delay_fish_creator = {}
            self:onSubPreExchageScene(dataBuffer)
        elseif sub == cmd.SUB_S_EXCHANGE_SCENE then
            -- 切换场景
            self.b_yuChaoBeforeCome = false
            self.b_haveCreateYuchao = true
            self:onSubExchangeScene(dataBuffer)
        elseif sub == cmd.SUB_S_FIRE then
            -- 开炮
            self:onSubFire(dataBuffer)
        elseif sub == cmd.SUB_S_TimeUp then
            --限制60s
            --ef.tip("由于您一分钟未发射子弹，强制将您请出房间！！！", 3)
            self:setSecondCount(10)
        elseif sub == cmd.SUB_S_FIRE_ERR then   --子弹索引检验
            local bulletIndex = dataBuffer:readint()
            self:SetSelfBulletIndex(bulletIndex)
        elseif sub == cmd.SUB_S_NOT_FIRE then  --不能开火，子弹过多
            self.m_pao_hot = true
        elseif sub == cmd.SUB_S_CAN_FIRE then    --可以开火
            self.m_pao_hot = false
        elseif sub == cmd.SUB_S_TRACE_POINT then
            -- 鱼
            self:createMoreFishd(dataBuffer)
            self._gameView.yuchaozhong:hide() 
            self.b_haveCreateYuchao = false
            self.m_canShoot = true
            self.b_yuChaoBeforeCome = false
        elseif sub == cmd.SUB_S_FISH_GROUP then -- 鱼群
            self:onSubFishGroup(dataBuffer)
            self._gameView.yuchaozhong:hide() 
            self.m_canShoot = true
            self.b_yuChaoBeforeCome = false
            self.b_haveCreateYuchao = false
        elseif sub == cmd.SUB_S_LOCK_SCENE then
            local chair_id = dataBuffer:readword()
            local frozen_time = dataBuffer:readdword()
            self:createFrozen()
        elseif sub == cmd.SUB_S_LOCK_TIMEOUT then-- 定屏结束
            self:killFrozen()
        elseif sub == cmd.SUB_S_USER_SCORE_UPDATE then
            self:onoSubUpdateScore(dataBuffer)
        end
    end
end

function GameLayer:get_random(v)
    local ran = {}
    for i=1, 8 do
        local idx = (v+i)%100 + 1
        ran[i] = self.random_map[idx]
    end
    return ran
end


function GameLayer:onSubFishGroup(dataBuffer)
    local data = netdata.read(cmd.CMD_S_FishGroup, dataBuffer)

    local function adjust_pos(pos, v)
        pos.x = pos.x + v
        pos.y = pos.y + v
    end

    if data.group_type == 1 then--/1-线性鱼群 2-群状鱼群 3-绑定鱼群, 4-- 放射圈鱼群 
        for i=1, data.fish_item_num do 
            local groupItem = netdata.read(cmd.FishGroupItem, dataBuffer)
            groupItem.path_id = data.path_id
            insert(self.delay_fish_creator, {
                kind=groupItem.fish_kind, 
                t=(i-1)*0.6, 
                f=function()
                local fish = self:createFish(groupItem)
            end})
        end
    elseif data.group_type == 2 then
        for i=1, data.fish_item_num do 
            local groupItem = netdata.read(cmd.FishGroupItem, dataBuffer)
            groupItem.path_id = data.path_id

            insert(self.delay_fish_creator, { 
                kind=groupItem.fish_kind,
                t=i*0.2, 
                f=function()
                    local fish = self:createFish(groupItem)
                    fish.path = clone(fish.path)
                    local ran = self:get_random(groupItem.fish_random)
                    adjust_pos(fish.path.ori, ran[1], ran[2])
                    adjust_pos(fish.path.dst, ran[3], ran[4])
                    adjust_pos(fish.path.c1, ran[5], ran[6])
                    adjust_pos(fish.path.c2, ran[7], ran[8])
                end})
        end
    elseif data.group_type == 4 then

        local info = self.special_fish_pos[1]
        if not info then
            return print('没有爆炸鱼的位置')
        end
        local len = #self.special_fish_pos
        for i=1,len-1 do
             self.special_fish_pos[i] = self.special_fish_pos[i+1]
        end
        self.special_fish_pos[len] = nil
        local wave = 3
        local n_fish_per_wave = data.fish_item_num/wave
        local n = 1
        local cur_wave = 1

        for i=1, data.fish_item_num do 
            local groupItem = netdata.read(cmd.FishGroupItem, dataBuffer)
            local angle = rad(n * (360 / n_fish_per_wave))
            groupItem.path = {
                ori = cc.p(info.x, info.y),
                speed= cc.p(cosf(angle)*150,sinf(angle)*150),
                type=1,
            }
            n = n + 1
            insert(self.delay_fish_creator, {
                kind = groupItem.fish_kind,
                t=(cur_wave - 1) * 1, 
                f=function() self:createFish(groupItem) end
            })

            if n > n_fish_per_wave then
                cur_wave = cur_wave + 1
                n = 1
            end
        end

    elseif data.group_type == 3 then

        -- print('组合鱼', data.fish_item_num)

        local fishes = {}
        for i=1, data.fish_item_num do
            fishes[i] = netdata.read(cmd.FishGroupItem, dataBuffer)
        end

        local fishdata = {
            fish_id = fishes[1].fish_id,
            fish_kind = fishes[1].fish_kind,
            fish_buff = Kind.Buff_Combine,
            fishes = fishes,
            path_id = data.path_id,
        }

        self:createFish(fishdata)
    end
end
--
function GameLayer:onSubPreExchageScene(dataBuffer)
    self:killFrozen()
    local scene_kind = dataBuffer:readint()  --场景ID
    local time = dataBuffer:readdword()   --延时时间 1/1000 秒
    local time1 = dataBuffer:readdword()  --//鱼潮时长 1/1000 秒
    for i=#self.m_fishList,1,-1 do
        self.m_fishList[i]:goAway()
    end
    --[[for k, v in pairs(self.m_fishMap) do
        if v ~= nil then
            v:goAway() 
        end
    end]]
    self._gameView:updteBackGround(scene_kind+1,time/1000)
end
local speedOffset = 0.7
function GameLayer:onSubExchangeGameSceneing(dataBuffer)
    self._curCopyFishTime = os.time() 
    local FishComb = netdata.read(cmd.CMD_S_SwitchGameSceneing,dataBuffer)
    self._curCopyFishBuffer = FishComb
    self.createYuChaoFunc = function()
        self._gameView.yuchaozhong:hide()
        self.m_canShoot = true  
        self:killFrozen()
        if self._curCopyFishBuffer.scene_kind < 6 then
            local data = require(module_pre..'.models.cfg_group_'..(self._curCopyFishBuffer.scene_kind+1))
            local cnt = self._curCopyFishBuffer.fish_count;
            local cnt2 = #data.fishes;
            --print("场景切换  data cnt:" .. cnt2 .. " FishComb.count:" .. cnt )
            local waitTime =( os.time()  - self._curCopyFishTime) + (self._curCopyFishBuffer.delay_time/1000)
            local offsetX = waitTime * data.speed*speedOffset
            for i, info in ipairs(data.fishes) do
                --print("场景切换  i:" .. i .. " cnt:" .. cnt .. " info.id:" .. info.id .. " fish_kind[i]:" .. (FishComb.fish_kind[i]+1) .. " fish_id[i]:" .. FishComb.fish_id[i])
                if(i>cnt) then
                    break
                end
                local fish_id = self._curCopyFishBuffer.fish_id[i]
                if fish_id >0 then
                     local data = {
                         fish_kind = self._curCopyFishBuffer.fish_kind[i],
                         fish_id = fish_id,
                         path = {
                             type=1,
                             speed=cc.p(data.speed, 0),
                             ori=cc.p(info.pos.x+offsetX,info.pos.y),
                         }
                     }
                     self:createFish(data)
                end
            end
        end
    end
end

-- 切换场景
function GameLayer:onSubExchangeScene(dataBuffer)
    print("场景切换")
    self._gameView.yuchaozhong:hide()
    self.m_canShoot = true
    self:doTip('tips_yuchao',display.cx)

    self:killFrozen()
    --[[for k, v in pairs(self.m_fishMap) do
        if v ~= nil then
            v:goAway() 
        end
    end]]

    local FishComb = netdata.read(cmd.CMD_S_SwitchScene, dataBuffer)
    print("场景切换  id:" .. FishComb.scene_kind )
    -- 鱼阵
    if FishComb.scene_kind < 6 then
        local data = require(module_pre..'.models.cfg_group_'..(FishComb.scene_kind+1))
        local cnt = FishComb.fish_count;
        local cnt2 = #data.fishes;
        print("场景切换  data cnt:" .. cnt2 .. " FishComb.count:" .. cnt )

        for i, info in ipairs(data.fishes) do
            print("场景切换  i:" .. i .. " cnt:" .. cnt .. " info.id:" .. info.id .. " fish_kind[i]:" .. (FishComb.fish_kind[i]+1) .. " fish_id[i]:" .. FishComb.fish_id[i])
            
            if(i>cnt) then
                break
            end
            --[[if info.id ~= FishComb.fish_kind[i]+1 then
                break;
            end]]
            local data = {
                fish_kind = FishComb.fish_kind[i],
                fish_id = FishComb.fish_id[i],
                path = {
                    type=1,
                    speed=cc.p(data.speed, 0),
                    ori=info.pos,
                }
                
            }
            self:createFish(data)

            --remove(FishComb.fish_kind, j)
            --remove(FishComb.fish_id, j)


           -- print("场景切换 data.fishes id:" .. i)
            --[[for j, kind in ipairs(FishComb.fish_kind) do
                 print("场景切换 FishComb.fish_kind:" .. j .. " id:" .. kind  .. " info.id:" .. info.id)  
                if kind == info.id then

                    local data = {
                        fish_kind=kind,
                        fish_id= FishComb.fish_id[j],
                        path = {
                            type=1,
                            speed=cc.p(data.speed, 0),
                            ori=info.pos,
                        }
                    }
                    self:createFish(data)

                    remove(FishComb.fish_kind, j)
                    remove(FishComb.fish_id, j)
                    break
                end
            end ]]--
        end



    end

    self._exchangeSceneing = true

    local callfunc = cc.CallFunc:create( function()
        self._exchangeSceneing = false
    end )

    --self._gameView:updteBackGround(FishComb.scene_kind+1)
    ef.playEffect(cmd.Change_Scene)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(3), callfunc))
end

function GameLayer:addFish(fish)
    self._gameView.fishLayer:addChild(fish, fish.fish_kind)
    self.m_fishMap[fish.fish_id] = fish
    insert(self.m_fishList, fish)
end

function GameLayer:createFishForDisplay(data)
    local fish = display.newNode()

    if data.fish_buff == Kind.Buff_YiWangDaJin then
        local eff = self.effcache:play(fish, 'buff_shandian', true)
        eff:setColor(colors.normal)
        eff:setScale(Kind.EffConfig[data.fish_kind].buffScale)
        eff:setLocalZOrder(-1)

    elseif data.fish_buff == Kind.Buff_FangSheYu then
        local eff = self.effcache:play(fish, 'buff_fangsheyu', true)
        eff:setScale(Kind.EffConfig[data.fish_kind].buffScale)
        eff:setColor(colors.normal)
        eff:setLocalZOrder(-1)

    elseif data.fish_buff == Kind.Buff_ShanDian then

    end

    if data.fish_buff ~= Kind.Buff_Combine then
        local eff = self.effcache:play(fish, 'fish_idle_'..(data.fish_kind+1), true)
        eff:setColor(colors.normal)
        eff:setScale(1)
        eff:setPosition(cc.p(0, 0))
    else
        local nfish = #data.fishes
        local cfg = Kind.CombieFish[nfish]

        if cfg then

            local eff = self.effcache:play(fish, 'buff_combine'..nfish.."_idle", true)
            eff:setColor(colors.normal)
            eff:setLocalZOrder(-1)

            for i, fishdata in ipairs(data.fishes) do
                local eff = self.effcache:play(fish, 'fish_idle_'..(fishdata.fish_kind+1), true)
                eff:setColor(colors.normal)
                eff:setScale(1)
                eff:move(cfg[i])
            end
        end 
    end
    fish:setTag(fish_tag)
    return fish
end

function GameLayer:createFish(data)
    local fish = Fish.new(data)

    self:createFishForDisplay(data):addTo(fish)
    
    self:addFish(fish)

    if data.fish_buff ~= Kind.Buff_Combine then
        fish:initPhysicsBody()
    else
        local nfish = #data.fishes
        local cfg = Kind.CombieFish[nfish]
        fish:setCombineBody(data.fishes, cfg)
    end

    fish:initPath()

    return fish
end
--缓存鱼
function GameLayer:cachePerloadingFish(databuffer)
    local count = floor(databuffer:getlen() / 14)
    if count >= 1 then
        for i = 1, count do
            local fishdata = g_ExternalFun.read_netdata(cmd.CMD_S_FishTrace, databuffer)
            fishdata.path_id = fishdata.cmd_version
            fishdata.path = clone(fish_path[fishdata.path_id or 1])
            fishdata.path.new_x = fishdata.path.ori.x
            fishdata.path.new_y = fishdata.path.ori.y
            fishdata.path._new_time = 0
            insert(self.preloading_fish,fishdata)
        end
    end    
end
--缓存鱼群
function GameLayer:cachePerloadingFishGroup(dataBuffer)
    local data = netdata.read(cmd.CMD_S_FishGroup, dataBuffer)
    local function adjust_pos(pos, v)
        pos.x = pos.x + v
        pos.y = pos.y + v
    end
    if data.group_type == 1 then--/1-线性鱼群 2-群状鱼群 3-绑定鱼群, 4-- 放射圈鱼群 
        for i=1, data.fish_item_num do 
            local fishdata = netdata.read(cmd.FishGroupItem, dataBuffer)
            fishdata.path_id = data.path_id
            fishdata.path = clone(fish_path[fishdata.path_id or 1])
            fishdata.path.new_x = fishdata.path.ori.x
            fishdata.path.new_y = fishdata.path.ori.y
            fishdata.path._new_time = 0
            fishdata.path.delay_time = (i-1)*0.6
            insert(self.preloading_fish,fishdata)
        end
    elseif data.group_type == 2 then
        for i=1, data.fish_item_num do 

            local fishdata = netdata.read(cmd.FishGroupItem, dataBuffer)
            fishdata.path_id = data.path_id
            fishdata.path = clone(fish_path[fishdata.path_id or 1])
            local ran = self:get_random(fishdata.fish_random)
            adjust_pos(fishdata.path.ori, ran[1], ran[2])
            adjust_pos(fishdata.path.dst, ran[3], ran[4])
            adjust_pos(fishdata.path.c1, ran[5], ran[6])
            adjust_pos(fishdata.path.c2, ran[7], ran[8])
            fishdata.path.adjust_pos = true

            fishdata.path.new_x = fishdata.path.ori.x
            fishdata.path.new_y = fishdata.path.ori.y
            fishdata.path._new_time = 0
            fishdata.path.delay_time = i * 0.2
            insert(self.preloading_fish,fishdata)

        end
    elseif data.group_type == 3 then
        -- print('组合鱼', data.fish_item_num)
        local fishes = {}
        for i=1, data.fish_item_num do
            fishes[i] = netdata.read(cmd.FishGroupItem, dataBuffer)
        end
        local fishdata = {
            fish_id = fishes[1].fish_id,
            fish_kind = fishes[1].fish_kind,
            fish_buff = Kind.Buff_Combine,
            fishes = fishes,
            path_id = data.path_id,
        }
        fishdata.path = clone(fish_path[fishdata.path_id or 1])
        fishdata.path.new_x = fishdata.path.ori.x
        fishdata.path.new_y = fishdata.path.ori.y
        fishdata.path._new_time = 0
        insert(self.preloading_fish,fishdata)
    end
end

function GameLayer:createMoreFishd(databuffer)
    
    local labelWait = self:getChildByName("labelWait")
    if labelWait ~= nil then
        labelWait:stopAllActions()
        labelWait:removeFromParent()
        labelWait = nil
    end

    local tip = nil
    local count = floor(databuffer:getlen() / 14)
    if count >= 1 then
        for i = 1, count do
            local fishdata = g_ExternalFun.read_netdata(cmd.CMD_S_FishTrace, databuffer)
            fishdata.path_id = fishdata.cmd_version
            self:createFish(fishdata) 
            if Kind.Tip_Map[fishdata.fish_kind] then
                tip = fishdata.fish_kind
            end
        end
    end

    if tip then
        self:showTipKind(tip)
    end
end

function GameLayer:showTipKind(kind)
    self:doTip(Kind.Tip_Map[kind])
end

function GameLayer:doTip(name,posX)
    if not self.tips_map then
        self.tips_map = {}
    end

    if self.tips_map[name] then
        return 
    end

    self.tips_map[name] = self.effcache:getAndPlay(name, true, function() self.tips_map[name] = nil end)
    self.tips_map[name]:addTo(self._gameView.tipLayer)
    posX = posX or 0
    self.tips_map[name]:move(cc.p(posX,display.cy))
end

function GameLayer:onSubFire(databuffer)
    if self.chair_to_cannon == nil then return end
    local fire = netdata.read(cmd.CMD_S_UserFire, databuffer)
    local cannon = self.chair_to_cannon[fire.chair_id]

    --if fire.lock_fishid == -1 then
        --fire.lock_fishid = cannon.locked_fish_id
    --end
    if fire.chair_id == self.m_nChairID then
        self.upscore[self.m_nChairID] = fire.total_fish_score
        cannon:updateUpScore(fire.total_fish_score)
        --cannon:setDisplayLevel(self.shootingScoreMap[fire.bullet_mulriple], true)
        --cannon:produceSelfBullet(fire)
    else
        if self.m_canShoot == true then
            cannon:othershoot(fire)
        end
    end
end
--自己开火
function GameLayer:onSelfFire(fire)
    if not fire and type(fire) ~= "table" then
        print("dntg  发送开火失败")
    end
    local cannon = self.chair_to_cannon[self.m_nChairID]
    cannon:SelfShoot(fire)
end
--锁定
function GameLayer:setAutoLock(b)
    local cannon = self.chair_to_cannon[self.m_nChairID]
    cannon:AutoLock(b,self.m_nChairID)
end
--自动开火
function GameLayer:setAutoShoot(b)
    local cannon = self.chair_to_cannon[self.m_nChairID]
    cannon:AutoShoot(b)
end

function GameLayer:createFrozen()
    self:effect_Ding()
end

function GameLayer:killFrozen(state)
    self.stat = state or stat.Normal
    if not self.frozen then return end
    self.frozen:getChildByName('lizi'):hide()

    cc.runActions(self.frozen, cc.FadeTo:create(0.2, 0), cc.RemoveSelf:create())
    self.frozen = nil
end

function GameLayer:effect_Ding(fish)
    self.stat = stat.Frozening
    if self.frozen then return end

    local node = self.effcache:play(self._gameView.effLayer, 'frozen')
    local xuehua = node:getChildByName('lizi'):hide()

    node:setOpacity(0)
    self.frozen = node

    cc.runActions(node, 
        cc.FadeTo:create(0.5, 255),
        function() xuehua:show() end
    )
end

function GameLayer:effect_SharkLayer(layer)
    local actions = {} 
    local range = 10
    local ox, oy = layer:getPosition()
    for i=12, 1,-1 do
        local x = random(-range+i,range+i)
        local y = random(-range+i,range+i)
        actions[i] = cc.MoveTo:create(0.01, cc.p(ox+x, oy+y))
    end
    actions[#actions] = cc.MoveTo:create(0.05, cc.p(ox, oy))

    layer:setPosition(cc.p(0, 0))
    layer:stopAllActions()
    layer:runAction(cc.Sequence:create(actions))
end

function GameLayer:catchFishStuff(data, catchData, effmap, ignore_animation)

    local fish = self.m_fishMap[catchData.fish_id]
    if not fish or not fish.m_data then
        return
    end

    local cfg = Kind.EffConfig[fish.fish_kind]
    local fishPos = cc.p(fish:getPositionX(), fish:getPositionY())

    effmap.sharkScreen = cfg.sharkScreen

    if cfg.goldBomb then
        local sp = self.effcache:getAndPlay('GoldBoom', true):addTo(self._gameView.fishLayer)
        sp:setLocalZOrder(-1)
        sp:setScale(2)
        sp:move(fishPos)
    end

    fish:deadDeal()-- 鱼死亡处理
    fish.ifdie = true

    local deadani = fish.deadani
    local scale = 1
    if not deadani then
        deadani = 'fish_dead_'..(fish.fish_kind+1)
        scale = cfg.deadScale
    end

    -- profiler1:push('鱼死亡动画') 
    local dead = self.effcache:getAndPlay(deadani)
    dead:setRotation(fish:getRotation())
    dead:move(fishPos)
    dead:setScale(scale)
    dead:addTo(self._gameView.fishLayer, 999)
    -- profiler1:pop()

    cc.runActions(dead, 1, cc.RemoveSelf:create())

    if not ignore_animation and fish.fish_kind == Kind.Fish_31 then -- 全屏定
        --self:effect_Ding(fish)

    elseif fish.fish_kind == Kind.Fish_28 then -- 全屏炸弹
        self.delay_fish_creator = {} -- 清除延迟创建的鱼

        -- profiler1:push('佛手动画') 
        for i=1, 8 do
            local sp = self.effcache:play(self._gameView.fishLayer, 'eff_foshou', true)
            sp:setRotation(-i * 45)
            sp:move(fishPos)

            local r = 400
            local x = r * sinf( rad(90-i*45))
            local y = r * cosf( rad(90-i*45))

            cc.runActions(sp, cc.MoveBy:create(3, cc.p(x, y)), cc.RemoveSelf:create())
        end
        -- profiler1:pop()

    elseif not ignore_animation and fish.m_data.fish_buff == Kind.Buff_FangSheYu then-- 放射鱼
        insert(self.special_fish_pos, { id = fish.fish_id, x = fish.Xpos, y = fish.Ypos, })

    elseif not ignore_animation and fish.m_data.fish_buff == Kind.Buff_YiWangDaJin then
        print('一网打井, 闪电鱼')

        -- profiler1:push('闪电动画')
        -- 删除还未创建的同类型鱼
        for_arry_new(self.delay_fish_creator, function(info)
            return info.kind == fish.fish_kind
        end)


        effmap.snd['sound_res/electric.mp3'] = true

        local function angle(x1, y1, x2, y2)
            return 360- deg( atan2(y2-y1,x2-x1))
        end
        local SameCount = 0
        --for id, same_fish in pairs(self.m_fishMap) do
        for i=#self.m_fishList,1,-1 do
            local same_fish = self.m_fishList[i]
            if same_fish.fish_kind == fish.fish_kind then
                local eff = self.effcache:getAndPlay('eff_flash_node', true)
                eff:addTo(self._gameView.fishLayer,-1)
                eff:setPosition(fishPos)

                local xian = self.effcache:getAndPlay('eff_flash_line', true)
                xian:addTo(self._gameView.fishLayer,-2)

                local x = (same_fish.Xpos-fish.Xpos)/2 + fish.Xpos
                local y = (same_fish.Ypos-fish.Ypos)/2 + fish.Ypos

                xian:setPosition(cc.p(x,y))
                xian:setRotation(angle(fish.Xpos, fish.Ypos, same_fish.Xpos, same_fish.Ypos))
                local dis = CalcDistance(fish.Xpos, fish.Ypos, same_fish.Xpos, same_fish.Ypos)
                xian:setScaleX(dis/700)

                SameCount = SameCount +1
            end
        end
        -- profiler1:pop()
    end

    if ignore_animation then
        --return
    end


    local fish_score = catchData.fish_score
    if fish.m_data.fish_buff == Kind.Buff_Combine then
        fish_score = data.fish_score
    end

    -- 游戏币动画
    if self.m_nChairID >= 2 then
        fishPos.y = ylAll.HEIGHT - fishPos.y
        fishPos.x = ylAll.WIDTH - fishPos.x
    end

    local serverKind = G_GameFrame:getServerKind()
    if cfg.goldCircle then
        -- profiler1:push('打转盘动画')
        effmap.snd['sound_res/CJ.mp3'] = true
        
        local node = self.effcache:getAndPlay('getBigGold', true)
        node:addTo(self._gameView.effLayer,2)
        node:setPosition(fishPos)
        node:getChildByName("fnt"):setString(g_format:formatNumber(fish_score,g_format.fType.standard,serverKind))
        -- profiler1:pop()
    else
        -- profiler1:push('文字创建')
        --[[local num = cc.LabelBMFont:create(string.format("%d", fish_score), "font/fnt_gold.fnt")
        num:setAnchorPoint(0.5,0.5)
        num:setPosition(fishPos)
        num:addTo(self._gameView.effLayer, 2)

        num:runAction(cc.Sequence:create({
            cc.DelayTime:create(0.4), 
            cc.Spawn:create({
                cc.MoveBy:create(0.5, cc.p(0, 50)),
                cc.FadeTo:create(0.5, 0),
            }),
            cc.RemoveSelf:create(),
        }))]]
        -- profiler1:pop()
        
        local labelScore = nil
        local _pool = self:getOneGoldLabelNode()
        if( nil == _pool ) then 
            --  创建一个fnt字体 +88888 添加到node中
            local fntFile = "font/fnt_gold.fnt"
            labelScore = cc.LabelBMFont:create(g_format:formatNumber(fish_score,g_format.fType.standard,serverKind),fntFile)
            labelScore:setAnchorPoint(cc.p(0.5, 0.5))
            self:AddEffectUp(labelScore, "goldLabel")
        else
            labelScore = _pool
            labelScore:setVisible( true )
            labelScore:setString(g_format:formatNumber(fish_score,g_format.fType.standard,serverKind) )                 
        end
        -- 设置位置
        labelScore:setPosition(fishPos)
        -- 定时移除
        labelScore:runAction(transition.sequence({
            cc.DelayTime:create(0.4), 
            
            cc.CallFunc:create(function(sender)
                 sender:stopAllActions()
                 sender:setVisible( false )
                 self:addGoldLabelNode( sender )
            end)
        }))
    end

    local cannon = self.chair_to_cannon[data.wChairID]
    if nil == cannon then
        return
    end

    local cannonPos = cannon.icon:convertToWorldSpaceAR(cc.p(0,0))
    local range = cfg.coinRange

    -- profiler1:push('金币循环') 
    --[[for i=1, cfg.coinCount do
        -- profiler1:push('金币创建') 
        local coin = self.effcache:play(self._gameView.effLayer, cfg.coin, false)
        -- profiler1:pop() 

        coin:setLocalZOrder(1)
        coin:setScale(0.5)

        local pos = cc.pAdd(fishPos, cc.p(math.random(-range, range), math.random(-range, range)))
        coin:setPosition(pos)

        local d = self.effcache:getDuration(coin)

        -- profiler1:push('金币action') 

        local actions = {
            --cc.JumpBy:create(0.4, cc.p(0, 0), 50, 3),
            cc.DelayTime:create(d),
    	    cc.CallFunc:create(function() coin.timeline:play("idle", true) end),
            cc.DelayTime:create(i*0.03),
            cc.DelayTime:create(0.5),
            cc.MoveTo:create(CalcDistance(pos.x, pos.y, cannonPos.x, cannonPos.y)/1300, cannonPos),
        }

        if i == cfg.coinCount then
            table.insert(actions, cc.CallFunc:create(function()
                -- profiler2:push('金币闪动')
                cannon.getgold:setPosition(cannon.icon:getPosition())
                self.effcache:playNode(cannon.getgold)
                -- profiler2:pop()

                -- profiler2:push('字体创建')
                local label = cc.LabelBMFont:create(string.format("+%d", fish_score), "font/fnt_gold.fnt")
                label:setScale(0.5)
                label:addTo(self._gameView.effLayer, 1)
                label:setAnchorPoint(cc.p(0, 0.5))
                label:setPosition(cannonPos)
                label:runAction(cc.Sequence:create({
                    cc.MoveBy:create(0.5, cc.p(0, 50)), 
                    cc.RemoveSelf:create()
                }))

                -- profiler2:pop()

            end))
        end

        table.insert(actions, cc.RemoveSelf:create())

        coin:runAction(cc.Sequence:create(actions))

        -- profiler1:pop() 
    end]]
    self:PlayNewCoinArmature(cfg.coinCount,cannon,cannonPos,fishPos,fish_score)
    -- profiler1:pop() 
end

function GameLayer:PlayNewCoinArmature(count,cannon,cannonPos,fishPos,score)
    if count >10 then count = 10 end  --j最多14个
    local radius = 80  --默认80范围
    local serverKind = G_GameFrame:getServerKind()
    for i=1,count do
        local pos = cc.pAdd(fishPos, cc.p( random(-radius, radius), random(-radius, radius)))
        local endMove = cc.MoveTo:create(CalcDistance(pos.x, pos.y, cannonPos.x, cannonPos.y)/1300, cannonPos)

        local coin = nil;
        local _pool = self:getOneFishGold()
        if _pool == nil then
            coin = ccs.Armature:create("dntg_fish_jinbi_1")
            self._gameView.effLayer:addChild(coin)
        else
            coin = _pool
        end
        coin:setPosition(pos)
        coin:setScale(0.5)
        coin:setVisible(true)
        coin:getAnimation():play("move")
            
        local labelAni = cc.CallFunc:create(function()
        end)
        if i == count then
            labelAni = cc.CallFunc:create(function()
                -- profiler2:push('金币闪动')
                cannon.getgold:setPosition(cannon.icon:getPosition())
                self.effcache:playNode(cannon.getgold)
                -- profiler2:pop()

                -- profiler2:push('字体创建')
               --[[ local label = cc.LabelBMFont:create(string.format("+%d", score), "font/fnt_gold.fnt")
                label:setScale(0.5)
                label:addTo(self._gameView.effLayer, 1)
                label:setAnchorPoint(cc.p(0, 0.5))
                label:setPosition(cannonPos)
                label:runAction(cc.Sequence:create({
                    cc.MoveBy:create(0.5, cc.p(0, 50)), 
                    cc.RemoveSelf:create()
                }))]]

                -- profiler2:pop()

                local fishCoin = nil
                local _pool = self:getOneFishScoreNode()
                if( nil == _pool ) then 
                    --  创建一个fnt字体 +88888 添加到node中
                    local fntFile = "font/fnt_gold.fnt"
                    fishCoin = cc.LabelBMFont:create(g_format:formatNumber("+"..score,g_format.fType.standard,serverKind), fntFile)
                    fishCoin:setAnchorPoint(cc.p(0, 0.5))
                    fishCoin:setPosition(15, 0)
                    fishCoin:setScale(0.5)
                    self:AddEffectUp(fishCoin, "fntScore")
                else
                    fishCoin = _pool
                    fishCoin:setVisible( true )
                    fishCoin:setString( g_format:formatNumber("+"..score,g_format.fType.standard,serverKind) )                 
                end
                -- 设置位置
                fishCoin:setPosition(cannonPos)
                -- 定时移除
                fishCoin:runAction(transition.sequence({
                    cc.MoveBy:create(0.6, cc.p(0, 50)),
                    cc.CallFunc:create(function(sender)
                         sender:stopAllActions()
                         sender:setVisible( false )
                         self:addFishScoreNode( sender )
                    end)
                }))
            end)

        end 
        coin:runAction(transition.sequence({
        cc.DelayTime:create(0.5),
        cc.EaseExponentialIn:create(endMove),
        labelAni,
        cc.CallFunc:create(function() 
           coin:setVisible(false) 
           self:addFishGold(coin)
        end)}))              
    end
end

function GameLayer:onSubFishCatch(databuffer)

    if not self.chair_to_cannon then return end
    -- profiler1:push('总共') 
    local data = netdata.read(cmd.CMD_S_CatchFish, databuffer)
    local cannon = self.chair_to_cannon[data.wChairID]
    cannon:updateUpScoreTask(data.total_fish_score)

    ef.playEffect("sound_res/Hit0.mp3")

    local now = currentTime()
    if not self.sound_time or now - self.sound_time > 2*1000 then
        self.sound_time = now
        ef.playEffect(string.format('sound_res/small_%d.mp3', random(6) - 1))
    end

    local effmap = {
        snd = {},
        sharkScreen = false,
    }

    local catchArray = {}
    for i=1, data.catch_fish_num do
        catchArray[i] = netdata.read(cmd.Fish_Catch_Item, databuffer)
    end

    if catchArray[1] and Kind.IsBomb[catchArray[1].fish_kind] then
        -- 打中炸弹鱼的话，只播放炸弹的金币
        catchArray[1].fish_score = data.fish_score
        self:catchFishStuff(data, catchArray[1], effmap)

        for i=2, #catchArray do
            self:catchFishStuff(data, catchArray[i], effmap, true)
        end
    else

        for i=1, #catchArray do
            self:catchFishStuff(data, catchArray[i], effmap)
        end

    end

    for k, v in pairs(effmap.snd) do
        ef.playEffect(k)
    end

    if effmap.sharkScreen then
        self:effect_SharkLayer(self._gameView.fishLayer)
    end

    -- profiler1:pop() 
    -- profiler1:print() 
    -- profiler1:clear()
end

function GameLayer:onSubCatchFishKing(databuffer)
    local data = netdata.read(cmd.CMD_S_CatchSweepFish, databuffer)
    --if data.wChairID ~= self.m_nChairID then return end   --过滤别人
    local fishType = 1 
    local fishRealType = 1
    local fishPos = cc.p(0,0)
    local catchFish = nil
    --for k,fish in pairs(self.m_fishList) do
    for i=#self.m_fishList,1,-1 do
        local fish = self.m_fishList[i]
        if fish.fish_id == data.dwFishID then
            fishType = fish.m_data.fish_kind
            fishRealType = fish.fish_kind
            catchFish = fish
            fishPos = cc.p(fish:getPositionX(), fish:getPositionY())
            break
        end
    end
    local fish = self.m_fishMap[data.dwFishID]

    if Kind.BombFish[fishRealType] then  --局部炸弹
        local fishId = {}
        local range = Kind.BombFish[fishRealType]
        for i, select_fish in ipairs(self.m_fishList) do
            if select_fish.fish_id ~= data.dwFishID and CalcDistance(select_fish.Xpos, select_fish.Ypos, fish.Xpos, fish.Ypos) <= range then
                insert(fishId, select_fish.fish_id)
            end
        end 
        local catchCount = #fishId
        if catchCount > 0 then
           self:sendCatchFishKing(data.wChairID,data.dwFishID,fishId,catchCount)
        end       
    elseif fishRealType  == Kind.Fish_28 then  --全屏炸弹
        --全屏炸弹
        --if data.wChairID == self.m_nChairID then
            local fishId = {}
            self:onFindSpecialFishId(fishId,fishRealType)
            local catchCount = #fishId
            if catchCount > 0 then
               self:sendCatchFishKing(data.wChairID,data.dwFishID,fishId,catchCount)
            end
        --end
    elseif fish and fish.m_data.fish_buff == Kind.Buff_YiWangDaJin then --闪电鱼
        local fishId = {}
        self:onFindSpecialFishId(fishId,Kind.Buff_YiWangDaJin,fishRealType)
        local catchCount = #fishId
        if catchCount > 0 then
            self:sendCatchFishKing(data.wChairID,data.dwFishID,fishId,catchCount)
        end
    elseif fish and fish.m_data.fish_buff == Kind.Buff_Combine then --组合鱼，(一箭双雕 一石三鱼, 金玉满堂)
        local count = data.fish_count
        local fishId = {}
        for i=1,count do
            self:onFindSpecialFishId(fishId,Kind.Buff_Combine,data.fish_kind[i])
        end
        local catchCount = #fishId
        if catchCount > 0 then
            self:sendCatchFishKing(data.wChairID,data.dwFishID,fishId,catchCount)
        end
    end
end

function GameLayer:onFindSpecialFishId(fishId,fishType,fish_kind)
    --for k,fish in pairs(self.m_fishList) do
    for i=1,#self.m_fishList do
        local fish = self.m_fishList[i]
        local func={}
        func[Kind.Fish_28] = function()
            local pos = cc.p(fish:getPositionX(), fish:getPositionY())
            if pos.x > 0 and pos.x < 1334 and pos.y > 0 and pos.y < 750 then
                insert(fishId, fish.fish_id)
            end  
        end
        func[Kind.Buff_YiWangDaJin] = function()
            local fish1 = self.m_fishMap[fish.fish_id]
            if fish1.m_data.fish_buff~= Kind.Buff_Combine and fish1.m_data.fish_buff~= Kind.Buff_YiWangDaJin and fish1.m_data.fish_buff~= Kind.Buff_FangSheYu and fish_kind == fish.fish_kind then
                insert(fishId, fish.fish_id)         
            end
        end
        func[Kind.Buff_Combine] = function()
            local fish1 = self.m_fishMap[fish.fish_id]
            if fish1.m_data.fish_buff~= Kind.Buff_Combine and fish1.m_data.fish_buff~= Kind.Buff_FangSheYu and fish_kind == fish.fish_kind then
                insert(fishId, fish.fish_id)         
            end
        end
        if func[fishType] then func[fishType]() end
        --[[if fishType == Kind.Fish_28 then --全屏炸弹
            local pos = cc.p(fish:getPositionX(), fish:getPositionY())
            if pos.x > 0 and pos.x < 1334 and pos.y > 0 and pos.y < 750 then
                table.insert(fishId, fish.fish_id)
            end        
        elseif fishType == Kind.Buff_YiWangDaJin then   --闪电鱼
            local fish1 = self.m_fishMap[fish.fish_id]
            if fish1.m_data.fish_buff~= Kind.Buff_Combine and fish1.m_data.fish_buff~= Kind.Buff_YiWangDaJin and fish1.m_data.fish_buff~= Kind.Buff_FangSheYu and fish_kind == fish.fish_kind then
                table.insert(fishId, fish.fish_id)         
            end
        elseif fishType == Kind.Buff_Combine then   --闪电鱼
            local fish1 = self.m_fishMap[fish.fish_id]
            if fish1.m_data.fish_buff~= Kind.Buff_Combine and fish1.m_data.fish_buff~= Kind.Buff_FangSheYu and fish_kind == fish.fish_kind then
                table.insert(fishId, fish.fish_id)         
            end
        end]]
    end
end

function GameLayer:sendCatchFishKing(wChairId,dwFishID,fishId,catchCount)
    local cmddata = CCmd_Data:create(1210)
    cmddata:setcmdinfo(G_NetCmd.MAIN_GAME, cmd.SUB_C_CATCH_SWEEP_FISH);
    cmddata:pushword(wChairId)
    cmddata:pushint(dwFishID)
    cmddata:pushint(catchCount)
    if catchCount >= 300 then catchCount = 300 end
    for i = 1, catchCount do
        cmddata:pushint(fishId[i])
    end
    --[[for i = catchCount + 1, 300 do
        cmddata:pushint(0)
    end]]
    --[[for i = #fishId, 1, -1 do
        remove(fishId, i)
    end]]
    fishId = {}

    -- 发送失败
    if self._gameFrame and not self._gameFrame:sendSocketData(cmddata) then
        self._gameFrame._callBack(-1, "Falha no envio da mensagem")
    end
end

function GameLayer:onSubCatchFishKingResult(databuffer)
    local data = netdata.read(cmd.CMD_S_CatchSweepFishResult, databuffer)
    for i = 1, 300 do
        if data.catch_fish_id[i] ~= 0 then
            --for k, fish in pairs(self.m_fishList) do
            for i=1,#self.m_fishList do
                local fish = self.m_fishList[i]
                if data.catch_fish_id[i] == fish.fish_id then
                    local fishPos = cc.p(fish:getPositionX(), fish:getPositionY())
                    if self.m_nChairID == 2 or self.m_nChairID == 3 then  --旋转
                        fishPos = cc.p(ylAll.WIDTH - fishPos.x, ylAll.HEIGHT - fishPos.y)
                    end
                    --self._gameView:ShowCoin(data.fish_score, data.wChairID, fishPos, fish.m_data.fish_kind)
                    --fish.ifdie = true
                    break
                end
            end
        else
            break
        end
    end    
end

function GameLayer:onSubLockFish(databuffer)
    if self.m_canShoot == false then return end --鱼潮来时，不接收锁定消息
    local chair_id = databuffer:readword()   --座位号
    local fish_id = databuffer:readint()    --锁定的鱼id
    local is_lock = databuffer:readbool()
    if fish_id == -1 and is_lock == true then --机器人请求帮助锁定
        self.is_help_android_lock[chair_id] = true
        self.lock_android_chair_id[chair_id] = chair_id
        return 
    end
    if chair_id == self.lock_android_chair_id[chair_id] and is_lock == false then  --机器人取消锁定，变量复位
        self.is_help_android_lock[chair_id] = false
        self.lock_android_fish[chair_id] = nil
    end
    if not self.chair_to_cannon then return end
    local cannon = self.chair_to_cannon[chair_id]
    if chair_id ~= self.m_nChairID and cannon then  --过滤自己
        cannon:AutoLock(is_lock,chair_id)
        local fish = self.m_fishMap[fish_id]
        cannon:lockFish(fish)
        if is_lock == false then  --取消锁定
            cannon:unlockFish(fish)
        end
    end
end

function GameLayer:onoSubUpdateScore(databuffer)
    if not self.chair_to_cannon then return end
    local int64 = Integer64.new()
    local lChanged = databuffer:readscore(int64):getvalue()
    local lScore = databuffer:readscore(int64):getvalue()
    local cannon = self.chair_to_cannon[self.m_nChairID]
    if cannon and self.upscore and lChanged then
        self.upscore[self.m_nChairID] = self.upscore[self.m_nChairID] + lChanged
        cannon:updateUpScore(self.upscore[self.m_nChairID] or 0) 
    end
end

--[[function GameLayer:onExitTable()
    self._scene:onKeyBack()
end]]

function GameLayer:onKeyBack()

    if self.stat == stat.Loading or self.stat == stat.Exiting then
        return
    end

    self:onQueryExitGame()

    return true
end

-- 离开房间
function GameLayer:onExitRoom()
    --
    --self:removeSelf()

    self._gameFrame:StandUp(1)
    self._gameFrame:onCloseSocket()
    self.quitGame = true
    G_event:NotifyEvent(G_eventDef.UI_REMOVE_GAME_LAYER)
    --AudioEngine.stopMusic()
end

function GameLayer:doExitGame()
    self._m_bLeaveGame = true
    self._gameFrame:setEnterAntiCheatRoom(false)
    self._gameFrame:StandUp(1)
    self._gameFrame:onCloseSocket()
end

function GameLayer:exitGame()

    cc.runActions(self, 
        1, -- 强制离开游戏(针对长时间收不到服务器消息的情况)
        function() 
            self:onExitRoom() 
        end
    )
end

-- 退出询问
function GameLayer:onQueryExitGame()

    self._gameView.ui:blink('Quit', function(ok)
        if ok == true then
            self:exitGame()
        end
    end )
end



return GameLayer