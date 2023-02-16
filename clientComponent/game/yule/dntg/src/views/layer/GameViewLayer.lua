local GameViewLayer = class("GameViewLayer", cc.Layer)

local CHANGE_MULTIPLE_INTERVAL =  0.8

local module_pre = "game.yule.dntg.src"	
local cmd = require(module_pre .. ".models.CMD_YQSGame")
local setLayer = require(module_pre .. ".ui.Set")
local helpLayer = require(module_pre .. ".ui.Help")
local scheduler = cc.Director:getInstance():getScheduler()

function GameViewLayer:ctor( scene )
    
	self._scene = scene
    self._gameFrame = scene._gameFrame

    self.m_pUserItem = self._gameFrame:GetMeUserItem()
    self.m_autoShoot = false
    self.m_autoLock = false
    self.m_cannonSpeed = 1
    self.curBgIndex = 1
    self.m_clearFishMark = false
    self.m_rotateAction = {}
    for i=1,3 do
        self.m_rotateAction[i] = cc.RepeatForever:create(cc.RotateBy:create(1.5, 359))
        self.m_rotateAction[i]:retain()
    end
end


function GameViewLayer:StopLoading( bRemove )
end

function GameViewLayer:getDataMgr( )
    return self:getParentNode():getDataMgr()
end

function GameViewLayer:getParentNode( )
    return self._scene;
end

function GameViewLayer:initView(  )

    local csbNode = ef.loadCSB("xyaoqianshu/GameLayer.csb"):addTo(self)
    self.csbNode = csbNode

    self.bgLayer = csbNode:getChildByName("bgLayer")
    self.gameLayer = csbNode:getChildByName("gameLayer")
    self.cannonLayer = csbNode:getChildByName("cannonLayer")
    self.cannonLayer:setSwallowTouches(false)
    self.effLayer = csbNode:getChildByName("effLayer")
    self.tipLayer = csbNode:getChildByName("tipLayer")
    self.tipnode = csbNode:getChildByName("tipnode"):hide()
    --60秒未开炮，即将退出游戏
    local tip_0 = self.tipnode:getChildByName("tip_0")
    tip_0:setPositionY(tip_0:getPositionY() - 9)

    local tip = self.tipnode:getChildByName("tip")
    tip:setPositionY(tip:getPositionY() + 5)
    tip:setTextHorizontalAlignment(1)
    tip:setString("60 seg sem disparar\nvocê sairá do jogo logo")

    self.yuchaozhong = csbNode:getChildByName("yuchaozhong"):hide()

    self.fishLockViewer = csbNode:getChildByName('locker'):hide()
    self.fishLockViewer:onClickEnd(function()
        self._scene:lockNextFish()
    end)

    self.ui = UIMgr.new(module_pre .. ".ui"):addTo(csbNode, 999)

    self.ui:open("PreLoading", self)

    -- 鱼层
    self.fishLayer = cc.Layer:create():addTo(self.gameLayer, 5)
    self.bulletLayer = cc.Layer:create():addTo(self.gameLayer, 6) 

    self.bg = self.bgLayer:getChildByName("bg")

    local function button(name, tag)
        local btn = csbNode:getChildByName(name)
        local active = btn:getChildByName("active"):hide()
        btn:onClickEnd(function () self:onButtonEvent(tag) end)
        return btn
    end

    self.btn_zidong = button("zidong", 1)
    self.btn_suodin = button("suodin", 2)

    self.jiasu = csbNode:getChildByName("jiasu")
    self.jiasu_active = self.jiasu:getChildByName("active"):hide()
    self.jiasu_icon = self.jiasu:getChildByName("icon"):hide()
    self.jiasu:onClickEnd(handler(self, self.setCannonSpeed))

    local isMenuShow = false
    local menuLayer = csbNode:getChildByName("menuLayer"):hide()

    local function showmenu(show)
        menuLayer:setVisible(show)
        isMenuShow = show
    end

    csbNode:getChildByName("menu"):onClickEnd(function() showmenu(not isMenuShow) end)
    menuLayer:onClickEnd(bind(showmenu, false),nil,true)

    self.heplLayer = helpLayer.new()
    self.heplLayer:setVisible(false)
    self._scene:addChild(self.heplLayer)

    self.setLayer = setLayer.new()
    self.setLayer:setVisible(false)
    self._scene:addChild(self.setLayer)

    local drop = menuLayer:getChildByName("drop")
    --[[drop:setContentSize(cc.size(99,450))
    --drop:setScale9Enabled(true)
    local btnSwitch = ccui.Button:create("xyaoqianshu/btn_switch.png","","")  --换桌
    btnSwitch:setPosition(50,317)
    btnSwitch:addTouchEventListener(function(ref,type)
       
    end)
    drop:addChild(btnSwitch)]]
    drop:getChildByName("fanhui"):onClickEnd(function()  self._scene:onQueryExitGame() end)
    drop:getChildByName("bangzhu"):onClickEnd(function() 
        --self.ui:open('Help') 
        self.heplLayer:setVisible(true)
    end)
    drop:getChildByName("shezhi"):onClickEnd(function()  
         self.setLayer:setVisible(true)
    end)

end

function GameViewLayer:setCannonSpeed()

    local four = 3
    local two  = 2
    local one = 1

    local sp = 0
    if self.m_cannonSpeed == two then
        self.m_cannonSpeed = four
        sp = 4
    elseif self.m_cannonSpeed == one then
        self.m_cannonSpeed = two
        sp = 2
    elseif self.m_cannonSpeed == four then
        self.m_cannonSpeed = one
        sp = 1
    end
    self._scene:setCannonSpeed(self.m_cannonSpeed)

    self.jiasu_active:setVisible(self.m_cannonSpeed ~= 1)
    self.jiasu_active:stopAllActions()
    self.jiasu_active:runAction(self.m_rotateAction[1])

    if sp == 1 then
        self.jiasu_icon:hide()
    elseif sp == 2 then
        self.jiasu_icon:show():loadTexture('xyaoqianshu/jiasu2.png')
        self.jiasu_icon:setContentSize(cc.size(98,35))
    elseif sp == 4 then
        self.jiasu_icon:show():loadTexture('xyaoqianshu/jiasu4.png')
        self.jiasu_icon:setContentSize(cc.size(98,35))
    end
end

function GameViewLayer:clearCannonSpeed()
    self.jiasu_icon:hide()
    self.jiasu_active:setVisible(false)
    self.m_cannonSpeed = 1
    self.jiasu:loadTextureNormal('xyaoqianshu/buyu/jiasu1.png', UI_TEX_TYPE_PLIST)
end

function GameViewLayer:initCannon()

    local me = self._scene._gameFrame:GetMeUserItem()

    -- 下面两个 位置不变
    if me.wChairID == 0 or me.wChairID == 1 then
        local nodes = {}
        for i=1, 4 do
            nodes[i-1] = self.cannonLayer:getChildByName("Node_"..i)
        end
        self.chairid_to_cannon = nodes
    else
        -- 位置翻转
        local conv = {3,4,1,2}

        local nodes = {}
        for i=1, 4 do
            nodes[conv[i]-1] = self.cannonLayer:getChildByName("Node_"..i)
        end

        self.chairid_to_cannon = nodes
    end

end

function GameViewLayer:updteBackGround(kind,delayTime)
    print('updteBackGround', param)
    delayTime = delayTime or 3.5
    delayTime = delayTime - 0.2
    local sc_to_bg = { 1,2,3,1,2,3}
    if kind > 6 then
        kind = 6
    end
    local bg = self.bgLayer:getChildByName("bg")    --Tag(TAG.tag_bg)

    if bg  then
        --cc.runActions(bg, cc.FadeTo:create(2.5,0), cc.RemoveSelf:create())
        local call = cc.CallFunc:create(function()
            bg:removeFromParent(true)
        end)
 
        local bgfile = string.format("xyaoqianshu/bg%d.jpg", sc_to_bg[kind])
        local _bg = cc.Sprite:create(bgfile)
        _bg:setPosition(-ylAll.WIDTH/2, ylAll.HEIGHT/2)
        if self._scene.m_nChairID >= 2 then
          _bg:setPosition(ylAll.WIDTH/2+ylAll.WIDTH, ylAll.HEIGHT/2)
        end
        self.bgLayer:addChild(_bg)
        --bg:runAction(cc.FadeTo:create(3,255))
        --self.bg = bg
        local newCall = cc.CallFunc:create(function()
            _bg:setName("bg")
        end)
        _bg:runAction(cc.Sequence:create(cc.MoveTo:create(delayTime, cc.p(ylAll.WIDTH/2, ylAll.HEIGHT / 2)), call, newCall))
    end

    --鱼阵浪潮
    local groupTips = cc.Sprite:create()
    groupTips:initWithSpriteFrameName("wave_1.png")
    local animation = cc.AnimationCache:getInstance():getAnimation("waveAnim")
    if nil ~= animation then
        local action = cc.RepeatForever:create(cc.Animate:create(animation))
        groupTips:runAction(action)
    end
    groupTips:setPosition(cc.p(-180,ylAll.HEIGHT/2))
    groupTips:setLocalZOrder(1)
    groupTips:setName("wave")
    groupTips:setRotation(180)
    self.fishLayer:addChild(groupTips,30)

    local callFunc1 = cc.CallFunc:create(function()
            self:unscheduleWaveSea()
            if self.m_clearFishMark == true and self._scene.b_yuChaoBeforeCome == true then
               --for k,v in pairs(self._scene.m_fishMap) do
               for i=1,#self._scene.m_fishList do
                   self._scene.m_fishList[i].ifdie = true
               end
            end
            self.m_clearFishMark = false
        end)

    local callFunc2 = cc.CallFunc:create(function()
            groupTips:removeFromParent(true)
        end)

    local moveTo1 = cc.MoveTo:create(delayTime, cc.p(ylAll.WIDTH-180, ylAll.HEIGHT / 2))
    local delayTime1 = (180 + 200) / (1334 / delayTime)
    local moveTo2 = cc.MoveTo:create(delayTime1, cc.p(ylAll.WIDTH+180, ylAll.HEIGHT / 2))
    groupTips:runAction(cc.Sequence:create(moveTo1, callFunc1, moveTo2, callFunc2))

    self:scheduleWaveSea()
    self.m_clearFishMark = true
end

function GameViewLayer:scheduleWaveSea()

    local function update()
        if nil ~= self._scene and nil ~= self.fishLayer then
            local groupTips = self.fishLayer:getChildByName("wave")
            if nil ~= groupTips then
                local recWave = groupTips:getBoundingBox()
                --for k,v in pairs(self._scene.m_fishMap) do
                for i=1,#self._scene.m_fishList do
                    local v = self._scene.m_fishList[i]
                    local fishPos = cc.p(v:getPositionX(), v:getPositionY())
                    if cc.rectContainsPoint(recWave, fishPos) then
                        v.ifdie = true
                    end
                end
                --[[for k,v in pairs(self._scene.busy_bullet) do
                    local bulletPos = cc.p(v:getPositionX(), v:getPositionY())
                    if cc.rectContainsPoint(recWave, bulletPos) then
                        v.ifdie = true
                        v:removeSelf()
                        table.remove(self._scene.busy_bullet, k)
                    end
                end]]
            end
        end
    end

    if nil == self.m_scheduleWaveSea then
        self.m_scheduleWaveSea = scheduler:scheduleScriptFunc(update, 0, false)
    end
end

function GameViewLayer:unscheduleWaveSea()

    if nil ~= self.m_scheduleWaveSea then
        scheduler:unscheduleScriptEntry(self.m_scheduleWaveSea)
        self.m_scheduleWaveSea = nil
    end
end

function GameViewLayer:onExit()
    self:unscheduleWaveSea()
    for i,v in pairs(self.m_rotateAction) do
        v:release()
    end
    self.m_rotateAction = nil
    self.ui:clear()
end

function GameViewLayer:setAutoShoot(b)
    self.m_autoShoot = b
    if b then
        --self.btn_zidong:loadTextureNormal('xyaoqianshu/buyu/zidong2.png')
        local active = self.btn_zidong:getChildByName("active"):show()
        active:runAction(self.m_rotateAction[2])
        if not self.spAuto then
           self.spAuto = display.newSprite("game_res/autoSp.png")
           self.spAuto:setPosition(1260,420)
           self:addChild(self.spAuto,10)
        end
        self.spAuto:setVisible(true)
    else
        local active = self.btn_zidong:getChildByName("active"):hide()
        active:stopAllActions()
        --self.btn_zidong:loadTextureNormal('xyaoqianshu/buyu/zidong1.png')
        if self.spAuto then
           self.spAuto:setVisible(false)
        end
    end
end

function GameViewLayer:setAutoLock(b)
    self.m_autoLock = b
    if b then
        self.btn_suodin:loadTextureNormal('xyaoqianshu/buyu/suoding2.png')
        local active = self.btn_suodin:getChildByName("active"):show()
        active:stopAllActions()
        active:runAction(self.m_rotateAction[3])

        if not self.spLock then
           self.spLock = display.newSprite("game_res/lockSp.png")
           self.spLock:setPosition(1260,530)
           self:addChild(self.spLock,10)
        end
        self.spLock:setVisible(true)
    else

        local active = self.btn_suodin:getChildByName("active"):hide()
        active:stopAllActions()
        self.btn_suodin:loadTextureNormal('xyaoqianshu/buyu/suoding1.png')
        if self.spLock then
           self.spLock:setVisible(false)
        end
        self.fishLockViewer:hide()

        self._scene.lockedFish = nil
        self._scene:UnlockFish()
    end
end

function GameViewLayer:onButtonEvent(tag)
    if self._scene.m_canShoot == false then return end

    --local shooter = self._scene.shooter 
    local cannon = self._scene.myCannon
    if tag == 1 then --自动射击
        --shooter:setAutoShoot(not shooter.autoShoot)
        self.m_autoShoot = not self.m_autoShoot
        self._scene:setAutoShoot(self.m_autoShoot)
        self:setAutoShoot(self.m_autoShoot)
    elseif tag == 2 then --自动锁定
        --shooter:setAutoLock(not shooter.autoLock)
        self.m_autoLock = not self.m_autoLock
        self._scene:setAutoLock(self.m_autoLock)
        self:setAutoLock(self.m_autoLock) 
    end 
end


return GameViewLayer
