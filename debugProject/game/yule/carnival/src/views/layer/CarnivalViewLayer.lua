local CarnivalViewLayer = class("CarnivalViewLayer", function(scene)
    local carnivalViewLayer = display.newLayer()
    return carnivalViewLayer
end)

local module_pre = "game.yule.carnival.src"
local cmd = module_pre .. ".models.CMD_Game"
local CarnivalHelpLayer = appdf.req(module_pre .. ".views.layer.CarnivalHelpLayer")
local CarnivalScrollLayer = appdf.req(module_pre .. ".views.layer.CarnivalScrollLayer")
local CarnivalAutoChoosedNode = appdf.req(module_pre .. ".views.layer.CarnivalAutoChoosedNode")
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local CarnivalFreeTipLayer = appdf.req(module_pre .. ".views.layer.CarnivalFreeTipLayer")
local CarnivalRewardTipNode = appdf.req(module_pre .. ".views.layer.CarnivalRewardTipNode")
local CarnivalAnimationNode = appdf.req(module_pre .. ".views.layer.CarnivalAnimationNode")

-- local CarnivaiTestShowNode = appdf.req(module_pre .. ".views.layer.CarnivaiTestShowNode")

local enGameLayer =
{
    "TAG_EFFECT_BTN",       -- 音效
    "TAG_QUIT_BTN",         -- 退出
    "TAG_START_BTN",        -- 开始按钮
    "TAG_HELP_BTN",         -- 游戏帮助
    "TAG_MAXADD_BTN",       -- 最大下注
    "TAG_ADD_BTN",          -- 加注
    "TAG_SUB_BTN",          -- 减注
    "TAG_SPEED_CHANGE",     -- 快速慢速
    "TAG_MUSIC_BTN",        -- 音乐
}

local TAG_ENUM = g_ExternalFun.declarEnumWithTable(100, enGameLayer);

function CarnivalViewLayer:ctor(scene)
    tlog('CarnivalViewLayer:ctor')
    g_ExternalFun.registerNodeEvent(self)
    self._scene = scene
    cc.SpriteFrameCache:getInstance():addSpriteFrames("GUI/jnh_itemPic.plist")

    self.m_bgMusicType = 0
    self:initCsbRes()
    math.randomseed(tostring(os.time()):reverse():sub(1,7))    
    self:registerTouch()
end

function CarnivalViewLayer:onExit()
    tlog("CarnivalViewLayer:onExit")
    if self.listener ~= nil then
        self:getEventDispatcher():removeEventListener(self.listener)
    end
    g_ExternalFun.stopMusic()
    --资源释放
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("GUI/jnh_itemPic.plist")
end

function CarnivalViewLayer:performWithDelay(delay, callback)
    tlog('CarnivalViewLayer:performWithDelay')
    if delay == 0 then
        self.m_actionNode:runAction(cc.CallFunc:create(callback))
    end
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    self.m_actionNode:runAction(sequence)
end

function CarnivalViewLayer:initCsbRes()
    tlog('CarnivalViewLayer:initCsbRes')
    local csbNode = cc.CSLoader:createNode("UI/CarnivalGameLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    csbNode:addTo(self)
    self.m_bgImage = csbNode:getChildByName("Image_bg")
    self.m_csbNode = csbNode:getChildByName("Panel_1")
    self.m_csbNode:setTouchEnabled(false)

    --玩家金币
    local _topNode = self.m_csbNode:getChildByName("Node_top"):getChildByName("Image_money_bg")
    _topNode:setPositionX(display.width * 0.5 - 40)
    local txt_score = _topNode:getChildByName("AtlasLabel_money")
    txt_score:setString("")
    self.m_textScore = txt_score
    self.m_textScore._lastNum = 0
    self.m_textScore._curNum = 0

    local icon = _topNode:getChildByName("Image_money_icon")
    local currencyType = G_GameFrame:getServerKind()
    g_ExternalFun.setIcon(icon,currencyType)

    local panel_normal = self.m_csbNode:getChildByName("Panel_normal")
    panel_normal:setTouchEnabled(false)

    local node_bottom = panel_normal:getChildByName("Node_bottom")
    self:initBtnShow(node_bottom)
    --总下注及单线注
    local atlasBet = node_bottom:getChildByName("Text_total_bet")
    atlasBet:setString("")
    self.m_textAllyafen = atlasBet
    local singleBet = node_bottom:getChildByName("Text_total_bet_1")
    singleBet:setString("")
    self.m_textSingleyafen = singleBet
    --一局游戏的总赢分文本
    local txt_winscore= node_bottom:getChildByName("jnh_win_money")
    txt_winscore:setString(0)
    self.m_textWinScore = txt_winscore
    self.m_textWinScore._lastNum = 0
    self.m_textWinScore._curNum = 0

    local panel_roll = panel_normal:getChildByName("Node_center"):getChildByName("Panel_roll")
    panel_roll:setTouchEnabled(false)
    panel_roll:setClippingEnabled(true)
    self.m_scrollLayer = CarnivalScrollLayer:create()
    self.m_scrollLayer:addTo(panel_roll)
    self:initAnimationNode(panel_normal)
    self:initFreeNodeShow()
    self:setFreeNodeVisible(false, false)

    self.m_actionNode = self.m_csbNode:getChildByName("Node_action")
end

function CarnivalViewLayer:initAnimationNode(_parentNode)
    local panel_action = self.m_csbNode:getChildByName("Panel_actionShow")
    panel_action:setTouchEnabled(false)
    panel_action:setClippingEnabled(false)
    self.m_carnivalAniNode = CarnivalAnimationNode:create()
    self.m_carnivalAniNode:addTo(panel_action)
    self.m_carnivalAniNode:setPosition(0, 0)
    self.m_carnivalAniNode:setAniNodeVisible(false)

    self.m_csbNode:getChildByName("FileNode_1"):setVisible(false)
    --test
    -- self.m_carnivalTest = CarnivaiTestShowNode:create(self.m_csbNode:getChildByName("FileNode_1"))
    -- self.m_carnivalTest:addTo(self)

    local spineFile = "GUI/jnh_ani_spine/jnh_main_bg_vfx_ske"
    local node = _parentNode:getChildByName("Node_spinebg")
    GameLogic:createAnimateShow(node, spineFile, "newAnimation", true, 0, 0, 1)

    spineFile = "GUI/jnh_ani_spine/jnh_main_kuang_ske"
    local image = _parentNode:getChildByName("Node_center"):getChildByName("Node_spineroll")
    GameLogic:createAnimateShow(image, spineFile, "newAnimation", true, 0, 0, 1)
    spineFile = "GUI/jnh_ani_spine/jnh_spin_vfx_ske"

    image = _parentNode:getChildByName("Node_bottom"):getChildByName("Node_scaleMore")
    local spine_c = image:getChildByName("Node_spine_c")
    GameLogic:createAnimateShow(spine_c, spineFile, "newAnimation", true, 0, 0, 1)

    spineFile = "GUI/jnh_ani_spine/jnh_main_foot_ske"
    local image_bg = image:getChildByName("Image_bg")
    local left_node = image_bg:getChildByName("Node_left")
    GameLogic:createAnimateShow(left_node, spineFile, "L", true, 0, 0, 1)
    local right_node = image_bg:getChildByName("Node_right")
    GameLogic:createAnimateShow(right_node, spineFile, "R", true, 0, 0, 1)
end

--初始化免费界面显示
function CarnivalViewLayer:initFreeNodeShow()
    --freegame
    if not self.m_freeGameBg then
        self.m_freeGameBg = self.m_csbNode:getChildByName("Panel_free")
        self.m_freeGameBg:setTouchEnabled(false)
        local panel_free_roll = self.m_freeGameBg:getChildByName("Node_center"):getChildByName("Panel_roll")
        panel_free_roll:setTouchEnabled(false)
        panel_free_roll:setClippingEnabled(true)

        local nodeBottom = self.m_freeGameBg:getChildByName("Node_bottom")
        self.m_freeTotalWin = nodeBottom:getChildByName("jnh_win_money")
        self.m_freeTotalWin._lastNum = 0
        self.m_freeTotalWin._curNum = 0

        local image_free_tip = nodeBottom:getChildByName("Image_4")
        self.m_freeNumLabel = image_free_tip:getChildByName("free_num")
        local btn = nodeBottom:getChildByName("Button_5")
        btn:setTag(TAG_ENUM.TAG_SPEED_CHANGE)
        btn:addClickEventListener(handler(self, self.onButtonClickedEvent))
    end
end

function CarnivalViewLayer:flushMusicResShow(_node, _enabled)
    _node:getChildByName('Image_1'):setVisible(_enabled)
    _node:getChildByName('Image_2'):setVisible(not _enabled)
end

function CarnivalViewLayer:initBtnShow(_parentNode)
    tlog('CarnivalViewLayer:initBtnShow')
    self.m_btnList = self.m_csbNode:getChildByName("Image_set")
    self.m_btnList:setVisible(false)
    local _topNode = self.m_csbNode:getChildByName("Node_top")
    local btn_more = _topNode:getChildByName("Button_set")
    btn_more:setPositionX(-display.width * 0.5 + 14)
    btn_more:addClickEventListener(function ()
        self.m_btnList:setVisible(not self.m_btnList:isVisible())
    end)
    --说明
    btn = self.m_btnList:getChildByName("Button_1")
    btn:setTag(TAG_ENUM.TAG_HELP_BTN)
    btn:onClicked(handler(self, self.onButtonClickedEvent))
    --音效
    local btn = self.m_btnList:getChildByName("Button_2")
    btn:setTag(TAG_ENUM.TAG_EFFECT_BTN)
    self:flushMusicResShow(btn, GlobalUserItem.bSoundAble)
    btn:onClicked(handler(self, self.onButtonClickedEvent))
    --背景音乐
    btn = self.m_btnList:getChildByName("Button_3")
    btn:setTag(TAG_ENUM.TAG_MUSIC_BTN)
    self:flushMusicResShow(btn, GlobalUserItem.bVoiceAble)
    btn:onClicked(handler(self, self.onButtonClickedEvent))
    --离开
    btn = self.m_btnList:getChildByName("Button_4")
    btn:setTag(TAG_ENUM.TAG_QUIT_BTN)
    btn:onClicked(handler(self, self.onButtonClickedEvent))

    --底部按钮
    --减注
    local nodeScale = _parentNode:getChildByName('Node_scaleMore')
    btn = nodeScale:getChildByName("Button_1")
    btn:setTag(TAG_ENUM.TAG_SUB_BTN)
    btn:addClickEventListener(handler(self, self.onButtonClickedEvent))
    self.m_btnSub = btn
    --加注
    btn = nodeScale:getChildByName("Button_2")
    btn:setTag(TAG_ENUM.TAG_ADD_BTN)
    btn:addClickEventListener(handler(self, self.onButtonClickedEvent))
    self.m_btnAdd = btn
    --最大
    btn = _parentNode:getChildByName("Button_3")
    btn:setTag(TAG_ENUM.TAG_MAXADD_BTN)
    btn:addClickEventListener(handler(self, self.onButtonClickedEvent))
    self.m_btnMaxAdd = btn
    -- 开始,长按弹出自动
    btn = _parentNode:getChildByName("Button_4")
    btn:addTouchEventListener(handler(self, self.onStartButtonClickedEvent))
    btn:setPressButtonMusicPath("")
    btn:setEnabled(false)
    btn.pic_status = 1 --1是展示开始图标，2展示停止图标
    self.m_btnStart = btn
    -- 自动按钮
    btn = _parentNode:getChildByName("Button_7")
    btn:addClickEventListener(handler(self, self.onAutoButtonClickedEvent))
    self.m_btnAuto = btn
    self.m_img_AutoGou = self.m_btnAuto:getChildByName("Image_gou")
    --快慢选择
    btn = _parentNode:getChildByName("Button_5")
    btn:setTag(TAG_ENUM.TAG_SPEED_CHANGE)
    btn:addClickEventListener(handler(self, self.onButtonClickedEvent))
    self.m_speedFactor = 2
    btn:getChildByName("Image_2"):setVisible(self.m_speedFactor ~= 1)

    --停止按钮
    btn = _parentNode:getChildByName("Button_6")
    btn:addClickEventListener(handler(self, self.onAutoBtnClick))
    btn:setVisible(false)
    self.m_autoArray = {autoBtn = btn, autoStatus = false, autoNum = 0}
end

--自动
function CarnivalViewLayer:onAutoButtonClickedEvent(_sender, _eventType)
    if self.m_autoArray.autoStatus == true then
        self.m_img_AutoGou:setVisible(false)
        self:onAutoBtnClick()
    else
        self.m_img_AutoGou:setVisible(true)
        local _nums = 101 --101代表无限
        local _startRoll = true
        self.m_autoArray.autoStatus = true
        self:updateAutoNumEvent(_nums, _startRoll)
    end
end

--开始按钮点击事件,长按3s变自动
function CarnivalViewLayer:onStartButtonClickedEvent(_sender, _eventType)
    tlog('CarnivalViewLayer:onStartButtonClickedEvent')
    if self._scene.m_cbFreeTime > 0 and _sender.pic_status == 1 then
        tlog("free or enter free status, click inValid")
        return
    end
    if _eventType == ccui.TouchEventType.began then
        self.m_touchBegan = true
        -- _sender:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function (t, p)
        --     --点击开始按钮音效
        --     g_ExternalFun.playSoundEffect("carnival_start_bet.mp3")
        --     self.m_touchBegan = false
        --     local pos = _sender:getParent():convertToWorldSpace(cc.p(_sender:getPosition()))
        --     local newPos = cc.p(pos.x, pos.y + 65)
        --     local adaptPos = cc.p(-1 * newPos.x, -1 * newPos.y)
        --     local _editNode = CarnivalAutoChoosedNode:create(handler(self, self.changeGameToAuto), adaptPos)
        --     _editNode:addTo(self, 10)
        --     _editNode:setPosition(newPos)
        -- end)))
    elseif _eventType == ccui.TouchEventType.canceled then
        --_sender:stopAllActions()
    elseif _eventType == ccui.TouchEventType.ended then
        --_sender:stopAllActions()
        if self.m_touchBegan then
            self.m_touchBegan = false
            g_ExternalFun.playSoundEffect("carnival_start_bet.mp3")
            local gameState = GameLogic:getGameMode()
            --动画没播完不能开始
            if gameState == GameLogic.gameState.state_wait then
                self._scene:gameStart()
            else
                if _sender.pic_status == 2 then
                    self.m_carnivalAniNode:hideAllFastActNode()
                    self:getRollLayer():stopAllItemAction()
                    self:changeNormalBtnShow(true)
                end
            end
        end
    end
end

--从普通模式转为自动模式
function CarnivalViewLayer:changeGameToAuto(_nums, _startRoll)
    tlog('CarnivalViewLayer:changeGameToAuto ', _nums, _startRoll)
    if nil == _startRoll then
        _startRoll = true
    end
    self.m_autoArray.autoBtn:setVisible(true)
    --self.m_btnStart:setVisible(false)
    self.m_autoArray.autoStatus = true
    self:updateAutoNumEvent(_nums, _startRoll)
end

function CarnivalViewLayer:updateAutoNumEvent(_nums, _startRoll)
    tlog('CarnivalViewLayer:updateAutoNumEvent ', _nums, _startRoll)
    if GameLogic:getGameMode() == GameLogic.gameState.state_wait and _startRoll then
        self._scene:autoStartEvent()
        if _nums <= 100 then
            _nums = _nums - 1
        end
    end
    self.m_autoArray.autoNum = _nums
    if _nums > 100 then
        self.m_autoArray.autoBtn:getChildByName("auto_num"):setString("I")--"∞"
    else
        self.m_autoArray.autoBtn:getChildByName("auto_num"):setString(tostring(_nums))
    end
end

--自动游戏没有足够金币停止了，刷新底下按钮
function CarnivalViewLayer:reflushBtnStatusByStopAuto()
    tlog('CarnivalViewLayer:reflushBtnStatusByStopAuto')
    self:onAutoBtnClick()
    self:updataBtnEnable()
end

function CarnivalViewLayer:getBtnStatusIsNormal()
    return (not self.m_autoArray.autoStatus) and (not self.m_freeGameBg:isVisible())
end

function CarnivalViewLayer:onAutoBtnClick(_sender)
    tlog('CarnivalViewLayer:onAutoBtnClick')
    self.m_autoArray.autoStatus = false
    self.m_autoArray.autoNum = 0
    self.m_autoArray.autoBtn:setVisible(false)
    self.m_img_AutoGou:setVisible(false)
    self.m_btnStart:setVisible(true)
    self:changeNormalBtnShow()
    self:updataBtnEnable()
end

--开始按钮的两个状态，1是显示下注，2是显示停止
--_showStart 直接展示开始图标
function CarnivalViewLayer:changeNormalBtnShow(_showStart)
    local gameMode = GameLogic:getGameMode()
    local isVisible = self.m_btnStart:isVisible()
    tlog('CarnivalViewLayer:changeNormalBtnShow ', gameMode, _showStart)
    if isVisible and (not self.m_autoArray.autoStatus) then
        --local image = self.m_btnStart:getChildByName("Image_1")
        if gameMode == GameLogic.gameState.state_wait or _showStart then
            --展示开始图标
            self.m_btnStart:loadTextureNormal("carnival-GIRAR.png",UI_TEX_TYPE_PLIST)
            self.m_btnStart.pic_status = 1
        else
            --展示停止图标
            self.m_btnStart:loadTextureNormal("carnival-PARE.png",UI_TEX_TYPE_PLIST)
            self.m_btnStart.pic_status = 2
        end
        -- image:setContentSize(image:getVirtualRendererSize())
    end
end

-- 按键回调
function CarnivalViewLayer:onButtonClickedEvent(_sender)
    local tag = _sender:getTag()
    tlog('CarnivalViewLayer:onButtonClickedEvent ', tag)
    if tag == TAG_ENUM.TAG_QUIT_BTN then --退出           
        self.m_btnList:setVisible(false)
        self._scene:onQueryExitGame()
    elseif tag == TAG_ENUM.TAG_EFFECT_BTN  then --音效
        GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble)
        self:flushMusicResShow(_sender, GlobalUserItem.bSoundAble)
    elseif tag == TAG_ENUM.TAG_MUSIC_BTN  then --音乐
        GlobalUserItem.setVoiceAble(not GlobalUserItem.bVoiceAble)
        self:flushMusicResShow(_sender, GlobalUserItem.bVoiceAble)
        tlog("GlobalUserItem.bVoiceAble ", GlobalUserItem.bVoiceAble)
        if GlobalUserItem.bVoiceAble then
            if self.m_freeGameBg:isVisible() then
                self:playGamebgMusic(2)
            else
                if GameLogic:getGameMode() == GameLogic.gameState.state_wait then
                    self:playGamebgMusic(1)
                else
                    self:playGamebgMusic(3)
                end
            end
        else
            self.m_bgMusicType = 0
        end
    elseif tag == TAG_ENUM.TAG_HELP_BTN then
        self.m_btnList:setVisible(false)
        local _helpLayer = CarnivalHelpLayer:create():addTo(self, 10)
        _helpLayer:setPosition(display.width * 0.5, display.height * 0.5)
    elseif tag == TAG_ENUM.TAG_ADD_BTN then -- 加注
        self._scene:onAddScore()
    elseif tag == TAG_ENUM.TAG_SUB_BTN then
        self._scene:onSubScore()
    elseif tag == TAG_ENUM.TAG_MAXADD_BTN then -- 最大加注
        self._scene:onAddMaxScore()
    elseif tag == TAG_ENUM.TAG_SPEED_CHANGE then -- 快速慢速
        local image_choosed = _sender:getChildByName("Image_2")
        local isVisible = image_choosed:isVisible()
        image_choosed:setVisible(not isVisible)
        if isVisible then
            self.m_speedFactor = 1
        else
            self.m_speedFactor = 2
        end
        -- local _freeTipLayer = CarnivalFreeTipLayer:create(data):addTo(self, 10)
        -- _freeTipLayer:setPosition(display.width * 0.5, display.height * 0.5)
        -- self:showRewardTipNode(nil, 1, 12356)

        -- local _callBack = function ()
        --     tlog("first start free game")
        --     -- self:setFreeNodeVisible(true, true, handler(self, self.firstChangeToFreeCall))
        --     self:setFreeNodeVisible(false, true, handler(self, self.changeToNormalCall))
        -- end
        -- self:showFreeTipNode(_callBack, 1, 10)
    else
        showToast(g_language:getString("game_tip_no_function"))
    end
end

--更新下注额度面板显示
function CarnivalViewLayer:updateBetNumShow()
    tlog('CarnivalViewLayer:updateBetNumShow')
    --local showScore = string.formatNumberCoin(self._scene.m_lTotalYafen)
    local serverKind = G_GameFrame:getServerKind()
    local showScore = g_format:formatNumber(self._scene.m_lTotalYafen,g_format.fType.abbreviation,serverKind)
    self.m_textAllyafen:setString(showScore)
    --showScore = string.formatNumberCoin(math.floor(self._scene.m_lTotalYafen / GameLogic.TOTAL_LINE))
    showScore = g_format:formatNumber(math.floor(self._scene.m_lTotalYafen / GameLogic.TOTAL_LINE),g_format.fType.abbreviation,serverKind)
    self.m_textSingleyafen:setString(string.format("50 X %s", showScore))
end

function CarnivalViewLayer:updateScore(notAnimation)
    tlog('CarnivalViewLayer:updateScore ', self._scene.m_lScore, self._scene.m_lGetCoins,
        self._scene.m_llFreeScore, notAnimation)
    --更新免费总下注
    if self.m_freeGameBg:isVisible() then
        self.m_freeTotalWin._lastNum = self.m_freeTotalWin._curNum
        self.m_freeTotalWin._curNum = self._scene.m_llFreeScore
        if not notAnimation then
            GameLogic:updateGoldShow(self.m_freeTotalWin)
        else
            self.m_freeTotalWin:stopAllActions()
            local serverKind = G_GameFrame:getServerKind()
            self.m_freeTotalWin:setString(g_format:formatNumber(self._scene.m_llFreeScore,g_format.fType.standard,serverKind))
        end
    else
        self.m_textScore._lastNum = self.m_textScore._curNum
        self.m_textScore._curNum = self._scene.m_lScore

        self.m_textWinScore._lastNum = self.m_textWinScore._curNum
        self.m_textWinScore._curNum = self._scene.m_lGetCoins

        if not notAnimation then
            GameLogic:updateGoldShow(self.m_textScore)
            GameLogic:updateGoldShow(self.m_textWinScore)
        else
            self.m_textScore:stopAllActions()
            self.m_textWinScore:stopAllActions()
            local serverKind = G_GameFrame:getServerKind()
            self.m_textScore:setString(g_format:formatNumber(self._scene.m_lScore,g_format.fType.standard,serverKind))
            local serverKind = G_GameFrame:getServerKind()
            self.m_textWinScore:setString(g_format:formatNumber(self._scene.m_lGetCoins,g_format.fType.standard,serverKind))
        end
        if self._scene.m_lScore <= 9999999999 then
            self.m_textScore:setScale(1)
        elseif self._scene.m_lScore <= 999999999999 then
            self.m_textScore:setScale(0.85)
        else
            self.m_textScore:setScale(0.65)
        end
    end
end

--免费切到普通模式时，更新一下金币数和下方总赢金数
function CarnivalViewLayer:updateFreeOverCoinShow()
    tlog('CarnivalViewLayer:updateFreeOverCoinShow ', self._scene.m_lScore, self._scene.m_llFreeScore)
    self.m_textScore:stopAllActions()
    self.m_textWinScore:stopAllActions()
    local serverKind = G_GameFrame:getServerKind()
    self.m_textScore:setString(g_format:formatNumber(self._scene.m_lScore,g_format.fType.standard,serverKind))
    local serverKind = G_GameFrame:getServerKind()
    self.m_textWinScore:setString(g_format:formatNumber(self._scene.m_llFreeScore,g_format.fType.standard,serverKind))
    --更新快速选择框
    local panel_normal = self.m_csbNode:getChildByName("Panel_normal")
    local node_bottom = panel_normal:getChildByName("Node_bottom")
    local btn = node_bottom:getChildByName("Button_5")
    btn:getChildByName("Image_2"):setVisible(self.m_speedFactor ~= 1)
end

function CarnivalViewLayer:updateFreeTimeShow()
    if self.m_freeGameBg:isVisible() then
        tlog('CarnivalViewLayer:updateFreeTimeShow ', self._scene.m_cbFreeTime)
        self.m_freeNumLabel:setString(string.format("%d/%d", self._scene.m_cbFreeTime, self._scene.m_totalFreeTime))
    end
end

function CarnivalViewLayer:updataBtnEnable()
    local gameMode = GameLogic:getGameMode()
    local freeStatus = self.m_freeGameBg:isVisible() and self._scene.m_cbFreeTime > 0
    local autoStatus = self.m_autoArray.autoStatus
    local normalStatus = not (freeStatus or autoStatus)
    self.m_autoArray.autoBtn:setEnabled(autoStatus)
    local normalBtnEnable = normalStatus and (gameMode == GameLogic.gameState.state_wait)
    tlog("CarnivalViewLayer:updataBtnEnable ", gameMode, freeStatus, autoStatus, normalBtnEnable)
    self.m_btnStart:setEnabled(normalStatus)
    self.m_btnAdd:setEnabled(normalBtnEnable)
    self.m_btnSub:setEnabled(normalBtnEnable)
    self.m_btnMaxAdd:setEnabled(normalBtnEnable)
end

function CarnivalViewLayer:updateBroadIconShow(_itemInfo)
    self:removeChildByName("CarnivalRewardTipNode")
    self:removeChildByName("CarnivalFreeTipLayer")
    self.m_carnivalAniNode:setAniNodeVisible(false)
    self.m_scrollLayer:updateBroadIconShow(_itemInfo)
    -- self.m_carnivalTest:reloadDataShow()
end

--获取滚动面板
function CarnivalViewLayer:getRollLayer()
    if self.m_freeGameBg:isVisible() then
        return self.m_freeScroll
    else
        return self.m_scrollLayer
    end
end

--开始游戏之后停止界面动画
function CarnivalViewLayer:stopAllAnimation()
    tlog('CarnivalViewLayer:stopAllAnimation ', self._scene.m_mysteryType)
    self.m_carnivalAniNode:setAniNodeVisible(false)
    local rollLayer = self:getRollLayer()
    rollLayer:showAllItem()
    if self._scene.m_mysteryType ~= G_NetCmd.INVALID_BYTE then
        rollLayer:recoveryMaskedItem()
    end
end

-- 游戏1动画开始
function CarnivalViewLayer:gameBegin()
    tlog('CarnivalViewLayer:gameBegin')
    if not self.m_freeGameBg:isVisible() then
        --普通模式要切换到旋转背景音乐
        self:playGamebgMusic(3)
    end
    self:changeNormalBtnShow()
    self:updataBtnEnable()
    self.m_carnivalAniNode:setBonusIndexValue(self._scene.m_bonusStartIndex)
    local bonusCall = function (_index)
        return self.m_carnivalAniNode:playFastActNode(_index)
    end
    local rollLayer = self:getRollLayer()
    rollLayer:setRunItem(self._scene.m_cbItemInfo, handler(self, self.GameGetLineResult))
    rollLayer:startRun(self.m_speedFactor, self._scene.m_bonusStartIndex, self.m_freeGameBg:isVisible(), bonusCall)

    --test
    -- self.m_carnivalTest:reloadDataShow(self._scene.m_testArray)
end

-- 游戏连线结果
function CarnivalViewLayer:GameGetLineResult()
    tlog('CarnivalViewLayer:GameGetLineResult')
    local endCall = function ()
        self:onGameAnimationOver()
    end
    local aniCall = function (_type, _posArr)
        self.m_carnivalAniNode:playItemAnimation(_type, _posArr, endCall)
    end
    local scrollCall = function ()
        tlog('scrollCall')
        local rollLayer = self:getRollLayer()
        rollLayer:showAllItem()
        rollLayer:setAllItemWin(self._scene.m_broadRewardStatus, aniCall)
        if self._scene.m_lGetCoins <= 0 then
            --没有获奖
            self:performWithDelay(0.2, endCall)
        else
            self:updateScore()
        end
    end
    local maskCall = function (_posArr, _maskType)
        tlog('maskCall')
        self:getRollLayer():setMaskedItemShow(_posArr, _maskType)
    end
    self.m_carnivalAniNode:checkEnabledMasked(self._scene.m_cbItemInfo, self._scene.m_mysteryType, scrollCall, maskCall)
    if self.m_freeGameBg:isVisible() and self._scene.m_lGetCoins > 0 then
        --免费赢奖音效
        g_ExternalFun.playSoundEffect("carnival_free_game_win.mp3")
        self:showFreeNodeSparkAct(true)
    end
end

-- 游戏动画结束回调
function CarnivalViewLayer:onGameAnimationOver()
    tlog("CarnivalViewLayer:onGameAnimationOver")
    local function callback()
        tlog('callback start')
        GameLogic:setGameMode(GameLogic.gameState.state_wait)
        self:changeNormalBtnShow(true)
        self:updataBtnEnable()

        local retResult = self:checkFreeStatus(false)
        if self._scene.m_cbFreeTime <= 0 then
            if self.m_freeGameBg:isVisible() then
                self:setFreeNodeVisible(false, true, handler(self, self.changeToNormalCall))
            else
                self:checkEnableAutoRoll()
            end
        else
            if retResult == 2 then
                --启动免费游戏提示画面
                local _callBack = function ()
                    tlog("first start free game")
                    --转换到免费界面音效
                    g_ExternalFun.playSoundEffect("carnival_free_base_transition.mp3")
                    self:setFreeNodeData(0) --如果赢奖这次算入免费的话那就是self._scene.m_lGetCoins
                    self:setFreeNodeVisible(true, true, handler(self, self.firstChangeToFreeCall))
                    self:updateFreeTimeShow() --首次由于动画延迟，需要额外设置数值显示
                end
                --首次免费游戏弹框音效
                g_ExternalFun.playSoundEffect("carnival_free_game_success.mp3")
                self:showFreeTipNode(_callBack, 1, self._scene.m_cbFreeTime)
            else
                local startCall = function ()
                    self._scene:gameStart()
                end
                --是否播放免费再中免费动画
                if self._scene.m_newFreeGot > 0 then
                    self:showFreeTipNode(startCall, 2, self._scene.m_newFreeGot)
                else
                    --直接开始
                    -- self:performWithDelay(0.1, startCall)
                    self._scene:gameStart()
                end
            end
        end
    end
    local rateNum = self._scene.m_lGetCoins / self._scene.m_lTotalYafen --当局中奖倍数
    tlog('rateNum is ', rateNum, GameLogic.Reward_Scope.small)
    if rateNum >= GameLogic.Reward_Scope.small then
        --达到弹框标准
        self:showRewardTipNode(callback, rateNum, self._scene.m_lGetCoins)
    else
        callback()
    end

    self:updateFreeTimeShow()
end

function CarnivalViewLayer:checkEnableAutoRoll()
    tlog('CarnivalViewLayer:checkEnableAutoRoll ', self.m_autoArray.autoNum, self.m_autoArray.autoStatus)
    if self.m_autoArray.autoNum > 0 then
        self:updateAutoNumEvent(self.m_autoArray.autoNum, true)
    else
        self:playGamebgMusic(1)
        if self.m_autoArray.autoStatus then
            self:onAutoBtnClick()
        end
    end
end

--奖励提示界面
function CarnivalViewLayer:showRewardTipNode(_call, _rate, _nums)
    tlog('CarnivalViewLayer:showRewardTipNode ', _rate, _nums)
    local data = {}
    data._callBack = _call
    data._rateNum = _rate
    data._nums = _nums
    local _rewardTipNode = CarnivalRewardTipNode:create(data):addTo(self, 10)
    _rewardTipNode:setPosition(display.width * 0.5, display.height * 0.5)
    _rewardTipNode:setName("CarnivalRewardTipNode")
end

function CarnivalViewLayer:setFreeNodeVisible(_bFreeStatus, _bAction, _callBack)
    tlog('CarnivalViewLayer:setFreeNodeVisible ', _bFreeStatus, _bAction)
    self.m_carnivalAniNode:setAniNodeVisible(false)--停掉动画
    local rollLayer = self:getRollLayer()
    if rollLayer then
        rollLayer:showAllItem()
    end
    local panel_normal = self.m_csbNode:getChildByName("Panel_normal")
    local node_top = self.m_csbNode:getChildByName("Node_top")
    if not _bAction then
        node_top:setVisible(not _bFreeStatus)
        panel_normal:setVisible(not _bFreeStatus)
        panel_normal:setScale(1)
        panel_normal:stopAllActions()
        self.m_freeGameBg:setVisible(_bFreeStatus)
        self.m_freeGameBg:setScale(1)
        self.m_freeGameBg:stopAllActions()
        self:changeBgShow(_bFreeStatus)
        if _bFreeStatus then
            panel_normal:setPositionY(-display.height * 0.5)
            self.m_freeGameBg:setPositionY(display.height * 0.5)        
        else
            panel_normal:setPositionY(display.height * 0.5)
            self.m_freeGameBg:setPositionY(display.height * 1.5)
            self:stopSparkAction()
        end
    else
        if _bFreeStatus then
            node_top:setVisible(false)
            panel_normal:setVisible(true)
            panel_normal:setPositionY(display.height * 0.5)
            local scale = cc.ScaleTo:create(1.5, 1.4)
            local move = cc.MoveBy:create(1.5, cc.p(0, -display.height))
            panel_normal:runAction(cc.Sequence:create(cc.Spawn:create(scale, move), cc.Hide:create()))

            self.m_freeGameBg:setPositionY(display.height * 0.5)
            self.m_freeGameBg:setScale(0.4)
            self.m_freeGameBg:setVisible(true)
            local scale1 = cc.ScaleTo:create(1.5, 1.0)
            local call = cc.CallFunc:create(function (t, p)
                self:changeBgShow(true)
                --首次转换到免费后音效
                g_ExternalFun.playSoundEffect("carnival_free_game_start_pop_up.mp3")
            end)
            local delay = cc.DelayTime:create(1.5)
            local call1 = cc.CallFunc:create(function (t, p)
                if _callBack then
                    _callBack()
                end
            end)
            self.m_freeGameBg:runAction(cc.Sequence:create(scale1, call, delay, call1))
        else
            self:stopSparkAction()
            panel_normal:setVisible(false)
            self.m_freeGameBg:setPositionY(display.height * 0.5)
            self.m_freeGameBg:setVisible(true)
            self.m_freeGameBg:setScale(1)
            local move = cc.MoveBy:create(1.0, cc.p(0, -display.height * 0.42))
            local call = cc.CallFunc:create(function (t, p)
                if _callBack then
                    _callBack()
                end
            end)
            self.m_freeGameBg:runAction(cc.Sequence:create(move, call))
        end
    end
end

function CarnivalViewLayer:changeBgShow(_bFreeStatus)
    local strBgFile = _bFreeStatus and "GUI/jnh_game_bg_1.png" or "GUI/jnh_game_bg_2.png"
    self.m_bgImage:loadTexture(strBgFile)
end

--动画转到免费界面回调
function CarnivalViewLayer:firstChangeToFreeCall()
    self:playGamebgMusic(2)
    self._scene:gameStart()
end

--免费界面转到正常界面回调
function CarnivalViewLayer:changeToNormalCall()
    local _callBack = function ()
        tlog("free game end tip")
        --免费转普通界面音效
        g_ExternalFun.playSoundEffect("carnival_free_base_transition.mp3")
        self:playGamebgMusic(1)
        self:updateFreeOverCoinShow()
        self.m_csbNode:getChildByName("Node_top"):setVisible(true)
        local panel_normal = self.m_csbNode:getChildByName("Panel_normal")
        panel_normal:setVisible(true)
        panel_normal:setScale(1.4)
        panel_normal:setPositionY(display.height * -0.5)
        local scale = cc.ScaleTo:create(1.5, 1.0)
        local move = cc.MoveBy:create(1.5, cc.p(0, display.height))
        panel_normal:runAction(cc.Spawn:create(scale, move))

        local scale1 = cc.ScaleTo:create(1.5, 0)
        local call = cc.CallFunc:create(function (t, p)
            self:changeBgShow(false)
            --检测免费游戏总赢金是否可以弹框
            local rateNum = self._scene.m_llFreeScore / self._scene.m_lTotalYafen
            tlog('call back rateNum is ', rateNum, GameLogic.Reward_Scope.small)
            if rateNum >= GameLogic.Reward_Scope.small then
                local autoCall = function ()
                    self:updataBtnEnable()
                    self:checkEnableAutoRoll()
                end
                self:showRewardTipNode(autoCall, rateNum, self._scene.m_llFreeScore)
            else
                self:updataBtnEnable()
                self:checkEnableAutoRoll()
            end
        end)
        self.m_freeGameBg:runAction(cc.Sequence:create(scale1, call, cc.Hide:create()))
    end
    self:showFreeTipNode(_callBack, 3, self._scene.m_llFreeScore)
end

--免费次数及赢奖提示界面
function CarnivalViewLayer:showFreeTipNode(_call, _type, _nums)
    tlog('CarnivalViewLayer:showFreeTipNode ', _type, _nums)
    local data = {}
    data._callBack = _call
    data._showType = _type
    data._nums = _nums
    local _rewardTipNode = CarnivalFreeTipLayer:create(data):addTo(self, 10)
    _rewardTipNode:setPosition(display.width * 0.5, display.height * 0.5)
    _rewardTipNode:setName("CarnivalFreeTipLayer")
end

--重连或刚进入判断是否有免费
function CarnivalViewLayer:checkFreeStatus(_isReenter)
    tlog('CarnivalViewLayer:checkFreeStatus ', self._scene.m_cbFreeTime, _isReenter)
    local retResult = 0     --0 没有免费，1非首次免费，2首次免费
    if self._scene.m_cbFreeTime > 0 then
        retResult = 1
        if not self.m_freeGameBg:isVisible() then
            retResult = 2
            if not _isReenter then
                self._scene.m_llFreeScore = 0
                self._scene.m_totalFreeTime = self._scene.m_cbFreeTime
                --在onGameAnimationOver中展示动画
            else
                self:setFreeNodeVisible(true, false)
                self:setFreeNodeData(self._scene.m_llFreeScore)
                self:playGamebgMusic(2)
                self:updateFreeTimeShow()
            end
        end
        if _isReenter then
            self.m_actionNode:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function ()
                tlog("enter free start game")
                self._scene:gameStart()
            end)))
        end
        if self.m_autoArray.autoStatus then
            self:changeGameToAuto(self.m_autoArray.autoNum, false) --设置按钮自动旋转状态
        end
    else
        if _isReenter then
            self:playGamebgMusic(1)
            --非重连的在getscore处 处理
            self:setFreeNodeVisible(false, false)
            if self.m_autoArray.autoStatus then
                self:changeGameToAuto(self.m_autoArray.autoNum, false) --设置按钮自动旋转状态
                self.m_actionNode:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function ()
                    self:updateAutoNumEvent(self.m_autoArray.autoNum, true)
                end)))
            end
        end
    end
    tlog('retResult is ', retResult)
    return retResult
end

--初始化总下注显示，快慢选择,面板显示
--按钮除了快慢选择外应该都是不可点的
function CarnivalViewLayer:setFreeNodeData(_score)
    if not self.m_freeScroll then
        local nodeCenter = self.m_freeGameBg:getChildByName("Node_center")
        local panel_free_roll = nodeCenter:getChildByName("Panel_roll")
        self.m_freeScroll = CarnivalScrollLayer:create()
        self.m_freeScroll:addTo(panel_free_roll)
        --添加一些spine动画

        local node_bg = self.m_freeGameBg:getChildByName("Node_spinebg")
        local spineFile = "GUI/jnh_ani_spine/jnh_fg_bg_vfx_ske"
        GameLogic:createAnimateShow(node_bg, spineFile, "idle", true, 0, 0, 1)

        local node_left = nodeCenter:getChildByName("act_left")
        spineFile = "GUI/jnh_ani_spine/jnh_stage_dancer_ske"
        GameLogic:createAnimateShow(node_left, spineFile, "l_dancer", true, 0, 0, 1.44)

        local node_right = nodeCenter:getChildByName("act_right")
        spineFile = "GUI/jnh_ani_spine/jnh_stage_dancer_ske"
        GameLogic:createAnimateShow(node_right, spineFile, "r_dancer", true, 0, 0, 1.44)

        spineFile = "GUI/jnh_ani_spine/jnh_fg_kuang_ske"
        local node_bg_spine = nodeCenter:getChildByName("Node_spineroll")
        GameLogic:createAnimateShow(node_bg_spine, spineFile, "newAnimation", true, 0, 0, 1)
    end
    self.m_freeScroll:updateBroadIconShow(self._scene.m_cbItemInfo)
    local nodeBottom = self.m_freeGameBg:getChildByName("Node_bottom")
    local btn = nodeBottom:getChildByName("Button_5")
    btn:getChildByName("Image_2"):setVisible(self.m_speedFactor ~= 1)

    --local showScore = string.formatNumberCoin(self._scene.m_lTotalYafen)
    local serverKind = G_GameFrame:getServerKind()
    local showScore = g_format:formatNumber(self._scene.m_lTotalYafen,g_format.fType.abbreviation,serverKind)
    nodeBottom:getChildByName('Text_total_bet'):setString(showScore)
    --showScore = string.formatNumberCoin(math.floor(self._scene.m_lTotalYafen / GameLogic.TOTAL_LINE))
    showScore = g_format:formatNumber(math.floor(self._scene.m_lTotalYafen / GameLogic.TOTAL_LINE),g_format.fType.abbreviation,serverKind)
    nodeBottom:getChildByName('Text_total_bet_1'):setString(string.format("50 X %s", showScore))

    self.m_freeTotalWin._lastNum = _score
    self.m_freeTotalWin._curNum = _score
    local serverKind = G_GameFrame:getServerKind()
    self.m_freeTotalWin:setString(g_format:formatNumber(_score,g_format.fType.standard,serverKind))
    self:showFreeNodeSparkAct(false)
end

function CarnivalViewLayer:stopSparkAction()
    if self.m_sparkActArray then
        local actNode = self.m_sparkActArray[7]
        if actNode then
            actNode.turnIndex = 1
            actNode:stopAllActions()
        end
    end
end

--免费面板火花动画
function CarnivalViewLayer:showFreeNodeSparkAct(_winStatus)
    tlog('CarnivalViewLayer:showFreeNodeSparkAct ', _winStatus)
    local nodeParent = self.m_freeGameBg:getChildByName("Node_center")
    if not self.m_sparkActArray then
        self.m_sparkActArray = {}
        local spineFile = "GUI/jnh_ani_spine/jnh_kuang_firework_ske"
        for i = 1, 6 do
            local spine_node = nodeParent:getChildByName(string.format("spine_node_%d", i))
            local aniNode = GameLogic:createAnimateShow(spine_node, spineFile, "spin", false, 0, 0, 1.2)
            aniNode:setVisible(false)
            table.insert(self.m_sparkActArray, aniNode)
        end
        table.insert(self.m_sparkActArray, nodeParent)
    end
    nodeParent.turnIndex = 1
    nodeParent:stopAllActions()
    if _winStatus then
        for i = 1, 6 do
            local aniNode = self.m_sparkActArray[i]
            aniNode:setVisible(true)
            aniNode:setAnimation(0, "win", false)
            aniNode:registerSpineEventHandler( function( event )
                aniNode:setVisible(false)
            end, sp.EventType.ANIMATION_COMPLETE)
        end
        nodeParent:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function ()
            self:turnShowSparkAct()
        end)))
    else
        self:turnShowSparkAct()
    end
end

function CarnivalViewLayer:turnShowSparkAct()
    local actNode = self.m_sparkActArray[7]
    tlog('CarnivalViewLayer:turnShowSparkAct ', actNode.turnIndex)
    local aniNode = self.m_sparkActArray[actNode.turnIndex]:setVisible(true)
    aniNode:setAnimation(0, "spin", false)
    aniNode:registerSpineEventHandler( function( event )
        aniNode:setVisible(false)
    end, sp.EventType.ANIMATION_COMPLETE)
    actNode.turnIndex = actNode.turnIndex + 1
    if actNode.turnIndex > 6 then
        actNode.turnIndex = 1
    end
    actNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.1), cc.CallFunc:create(function ()
        self:turnShowSparkAct()
    end)))
end

function CarnivalViewLayer:registerTouch()
    tlog('CarnivalViewLayer:registerTouch')
    local function onTouchBegan( touch, event )
        return true
    end

    local function onTouchEnded( touch, event )
        tlog('CarnivalViewLayer onTouchEnded')
        if self.m_btnList:isVisible() then
            local pos = self.m_btnList:convertToNodeSpace(touch:getLocation())
            local rec = cc.rect(0, 0, self.m_btnList:getContentSize().width, self.m_btnList:getContentSize().height)
            if not cc.rectContainsPoint(rec, pos) then
                self.m_btnList:setVisible(false)
            end
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    self.listener = listener
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

-- _type 1普通模式，2免费模式，3旋转的时候
function CarnivalViewLayer:playGamebgMusic(_type)
    tlog('CarnivalViewLayer:playGamebgMusic ', self.m_bgMusicType, _type)
    if self.m_bgMusicType == _type then
        return
    end
    if not GlobalUserItem.bVoiceAble then
        return
    end
    self.m_bgMusicType = _type
    local musicPath = ""
    if _type == 1 then
        musicPath = "sound_res/carnival_base_game_BGM.mp3"
    elseif _type == 2 then
        musicPath = "sound_res/carnival_free_game_BGM.mp3"
    else
        musicPath = "sound_res/carnival_reel_spin_BGM.mp3"
    end
    tlog('CarnivalViewLayer:playGamebgMusic11 ', musicPath)
    g_ExternalFun.stopMusic()
    g_ExternalFun.playMusic(musicPath, true)
end

return CarnivalViewLayer