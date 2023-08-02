local GameViewLayer = class("GameViewLayer", function(scene)
    local gameViewLayer = display.newLayer()
    return gameViewLayer
end )

GameViewLayer.RES_PATH = "game/yule/bonanza/res/"

local module_pre = "game.yule.bonanza.src"
local ExternalFun = g_ExternalFun--require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"

local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")
local ScrollLayer = appdf.req(module_pre .. ".views.layer.ScrollLayer")
local GameItem = appdf.req(module_pre .. ".views.layer.GameItem")
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local BonanzaFreeTipLayer = appdf.req(module_pre .. ".views.layer.BonanzaFreeTipLayer")
local BonanzaRewardTipNode = appdf.req(module_pre .. ".views.layer.BonanzaRewardTipNode")
local scheduler = cc.Director:getInstance():getScheduler()

local btn_status =
{
    status_normal   = 1,
    status_auto     = 2,
    status_free     = 3,
}

local enGameLayer =
{
    "TAG_EFFECT_BTN",-- 音效
    "TAG_QUIT_BTN",-- 退出
    "TAG_START_BTN",-- 开始按钮
    "TAG_HELP_BTN",-- 游戏帮助
    "TAG_MAXADD_BTN",-- 最大下注
    "TAG_ADD_BTN",-- 加注
    "TAG_SUB_BTN",-- 减注
    "TAG_AUTO_START_BTN",-- 自动游戏
    "TAG_AUTO_STOP_BTN",
}

local TAG_ENUM = ExternalFun.declarEnumWithTable(GameViewLayer.TAG_START, enGameLayer);

function GameViewLayer:ctor(scene)
    tlog('GameViewLayer:ctor')
    ExternalFun.registerNodeEvent(self)
    self._scene = scene
    self._isCreated = false
    self._auto = false --是否自动
end


function GameViewLayer:created()
    tlog("GameViewLayer:created")
    self:initCsbRes()
    math.randomseed(tostring(os.time()):reverse():sub(1,7))    
    self._isCreated = true
    self:registerTouch()
end

function GameViewLayer:onExit()
    tlog("GameViewLayer:onExit")
    self:stopBtnTimerCall()
    if self.listener ~= nil then
        self:getEventDispatcher():removeEventListener(self.listener)
    end
    --资源释放
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

function GameViewLayer:performWithDelay(delay,callback)
    tlog('GameViewLayer:performWithDelay')
    if delay == 0 then
        local call =  cc.CallFunc:create(callback)
        self:runAction(call)
        return call
    end
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    self:runAction(sequence)
    return sequence
end

function GameViewLayer:initCsbRes()
    tlog('GameViewLayer:initCsbRes')
    display.loadSpriteFrames('GUI/Plist_shuiguo.plist', 'GUI/Plist_shuiguo.png')
    
    local csbNode = cc.CSLoader:createNode("UI/GameLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    csbNode:addTo(self)
    self.m_bgImage = csbNode:getChildByName("Image_bg")
    self.m_csbNode = csbNode:getChildByName("Panel_1")
    self.m_csbNode:setTouchEnabled(false)
    self.imgCenterBg = self.m_csbNode:getChildByName("imgCenterBg")
    local spinebg_node = csbNode:getChildByName("spinebg_node")
    local spinePath = "spine/beijing"
    local spineAnim = sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
    spineAnim:setAnimation(0, "daiji", true)
    spineAnim:addTo(spinebg_node)

    self:initBtnShow()
    local node_bottom = self.m_csbNode:getChildByName("Node_bottom")

    --总下注
    local atlasBet = node_bottom:getChildByName("BFontLabel_bet")
    atlasBet:setString("")
    self.m_textAllyafen = atlasBet
    --玩家金币
    local money_bg = self.m_topNodeNormal:getChildByName("Image_money_bg")
    --money_bg:setPositionX(display.width * 0.5 - 40)
    local gold_icon = money_bg:getChildByName("Image_money_icon")
    local currencyType = G_GameFrame:getServerKind()
    g_ExternalFun.setIcon(gold_icon,currencyType)


    local txt_score = money_bg:getChildByName("AtlasLabel_money")
    txt_score:setString("")
    self.m_textScore = txt_score
    self.m_textScore._lastNum = 0
    self.m_textScore._curNum = 0
    --一局游戏的总赢分文本
    local txt_winscore= node_bottom:getChildByName("AtlasLabel_win")
    txt_winscore:setString(0)
    self.m_textWinScore = txt_winscore
    self.m_textWinScore._lastNum = 0
    self.m_textWinScore._curNum = 0

    local panel_2 = self.m_csbNode:getChildByName("Image_center"):getChildByName("Panel_2")
    panel_2:setTouchEnabled(false)
    panel_2:setClippingEnabled(false)
    self.m_scrollLayer = ScrollLayer:create()
    self.m_scrollLayer:addTo(panel_2)
    self.m_centerPanel = panel_2
    --当前面板得分提示
    local getscore = panel_2:getChildByName("win_num_tip")
    getscore:setLocalZOrder(10)
    getscore:setVisible(false)
    self.m_getScoreLabel = getscore

    --freegame
    self.m_freeGameBg = self.m_csbNode:getChildByName("Node_top"):getChildByName("Node_top_free")
    local txt = self.m_freeGameBg:getChildByName("free_win_num")
    txt:setString("")
    self.m_freeTotalWin = txt
    self.m_freeTotalWin._lastNum = 0
    self.m_freeTotalWin._curNum = 0
    self:setFreeNodeVisible(false)

    --炸弹元素最后倍数飞的动画的目的地位置
    self.m_nodeAction = self.m_csbNode:getChildByName("Node_action")
    local curPos = cc.p(self.m_freeTotalWin:getPosition())
    local position = self.m_nodeAction:convertToNodeSpace(self.m_freeTotalWin:getParent():convertToWorldSpace(curPos))
    self.m_nodeAction.dstPos = position

    self.m_rewardTipNode = BonanzaRewardTipNode:create():addTo(self, 10)
    self.m_rewardTipNode:setPosition(display.width * 0.5, display.height * 0.5)
    self.m_rewardTipNode:setSelfVisible(false)
end

function GameViewLayer:setFreeNodeVisible(_bFreeStatus)
    tlog('GameViewLayer:setFreeNodeVisible ', _bFreeStatus)
    self.m_freeGameBg:setVisible(_bFreeStatus)
    self.m_topNodeNormal:setVisible(not _bFreeStatus)
    local strBgFile = _bFreeStatus and "GUI/SweetBonanza_beijtu_bg.jpg" or "GUI/SweetBonanza_beij_bg.jpg"
    self.m_bgImage:loadTexture(strBgFile)
    local strBgFile2 = _bFreeStatus and "GUI/ctbg2.png" or "GUI/ctbg1.png"
    self.imgCenterBg:loadTexture(strBgFile2)
end

function GameViewLayer:flushMusicResShow(_node, _enabled)
    _node:getChildByName('Image_1'):setVisible(_enabled)
    _node:getChildByName('Image_2'):setVisible(not _enabled)
end

function GameViewLayer:initBtnShow()
    tlog('GameViewLayer:initBtnShow')
    self.m_btnList = self.m_csbNode:getChildByName("Image_set")
    self.m_btnList:setVisible(false)
    self.m_topNodeNormal = self.m_csbNode:getChildByName("Node_top"):getChildByName("Node_top_normal")
    local btn_more = self.m_topNodeNormal:getChildByName("Button_set")
    --btn_more:setPositionX(-display.width * 0.5 + 40)
    btn_more:addClickEventListener(function ()
        self.m_btnList:setVisible(not self.m_btnList:isVisible())
    end)

    --音效
    local btn = self.m_btnList:getChildByName("Button_2")
    btn:setTag(TAG_ENUM.TAG_EFFECT_BTN)
    self:flushMusicResShow(btn, GlobalUserItem.bSoundAble)
    btn:onClicked(handler(self, self.onButtonClickedEvent))
    --离开
    btn = self.m_btnList:getChildByName("Button_3")
    btn:setTag(TAG_ENUM.TAG_QUIT_BTN)
    btn:onClicked(handler(self, self.onButtonClickedEvent))
    --说明
    btn = self.m_btnList:getChildByName("Button_1")
    btn:setTag(TAG_ENUM.TAG_HELP_BTN)
    btn:onClicked(handler(self, self.onButtonClickedEvent))

    local node_bottom = self.m_csbNode:getChildByName("Node_bottom")
    -- 开始,长按3s变自动
    btn = node_bottom:getChildByName("Button_4")
    btn:addTouchEventListener(handler(self, self.onStartButtonClickedEvent))
    btn:setPressButtonMusicPath("")
    btn:setEnabled(false)
    btn._status_ = btn_status.status_normal
    self.m_btnStart = btn
    self.m_btnStart:getChildByName("free_num"):setVisible(false)

    --加注
    btn = node_bottom:getChildByName("Button_2")
    btn:setTag(TAG_ENUM.TAG_ADD_BTN)
    btn:addClickEventListener(handler(self, self.onButtonClickedEvent))
    self.m_btnAdd = btn
    --减注
    btn = node_bottom:getChildByName("Button_1")
    btn:setTag(TAG_ENUM.TAG_SUB_BTN)
    btn:addClickEventListener(handler(self, self.onButtonClickedEvent))
    self.m_btnSub = btn
    --最大
    -- btn = node_bottom:getChildByName("Button_3")
    -- btn:setTag(TAG_ENUM.TAG_MAXADD_BTN)
    -- btn:addClickEventListener(handler(self, self.onButtonClickedEvent))
    -- self.m_btnMaxAdd = btn
    btn = node_bottom:getChildByName("Button_3")
    btn:setTag(TAG_ENUM.TAG_AUTO_START_BTN)
    btn:addClickEventListener(handler(self, self.onButtonClickedEvent))
    self.m_btnAuto = btn
end

--自动按钮
function GameViewLayer:autoBtnClick()
    if self.m_btnStart._status_ == btn_status.status_normal then
        ExternalFun.playSoundEffect("bonanza_btn_click.mp3")
        self._auto = true
        self:checkFlushBtnShow(btn_status.status_auto)
        self._scene:onAutoStart()
        self.m_btnStart:setEnabled(false)
    elseif self.m_btnStart._status_ == btn_status.status_auto then
        self._auto = false
        self:checkFlushBtnShow(btn_status.status_normal)
        if self._scene:getGameMode() ~= 0 then
            self.m_btnStart:setEnabled(false)
        else
            self.m_btnStart:setEnabled(true)
        end 
    end
end
--开始按钮点击事件,长按3s变自动
function GameViewLayer:onStartButtonClickedEvent(_sender, _eventType)
    tlog('GameViewLayer:onStartButtonClickedEvent')
    if _eventType == ccui.TouchEventType.began then
        self.m_touchBegan = true
        -- if self.m_btnStart._status_ == btn_status.status_normal then
        --     --正常状态才可以长按
        --     _sender:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function (t, p)
        --         ExternalFun.playSoundEffect("bonanza_btn_click.mp3")
        --         self.m_touchBegan = false
        --         self._auto = true
        --         self:checkFlushBtnShow(btn_status.status_auto)
        --         self._scene:onAutoStart()
        --     end)))
        -- end
    elseif _eventType == ccui.TouchEventType.canceled then
        _sender:stopAllActions()
    elseif _eventType == ccui.TouchEventType.ended then
        _sender:stopAllActions()
        if self.m_touchBegan then
            self.m_touchBegan = false
            ExternalFun.playSoundEffect("bonanza_btn_click.mp3")
            if self.m_btnStart._status_ == btn_status.status_auto then
                -- self._auto = false
                -- self:checkFlushBtnShow(btn_status.status_normal)
                -- if self._scene:getGameMode() ~= 0 then
                --     self.m_btnStart:setEnabled(false)
                -- end
            else
                --self:checkFlushBtnShow(btn_status.status_normal)
                self._scene:onNormalStartBtnClick()
            end
        end
    end
end

--自动游戏没有足够金币停止了，刷新底下按钮
function GameViewLayer:reflushBtnStatusByStopAuto()
    tlog('GameViewLayer:reflushBtnStatusByStopAuto')
    self:checkFlushBtnShow(btn_status.status_normal)
    self:updataBtnEnable()
end

--刷新开始按钮
function GameViewLayer:checkFlushBtnShow(_newStatus)
    local oldStatus = self.m_btnStart._status_
    tlog('GameViewLayer:checkFlushBtnShow ', oldStatus, _newStatus)
    if oldStatus ~= _newStatus then
        local btnFile = {
            {"GUI/SweetBonanza_kaishiyouxii_but.png", "GUI/SweetBonanza_kaishiyouxii_but.png", "GUI/SweetBonanza_heibaispin_but.png"},
            {"GUI/SweetBonanza_heibaispin_but.png", "GUI/SweetBonanza_heibaispin_but.png", "GUI/SweetBonanza_heibaispin_but.png"},
            {"GUI/SweetBonanza_ferrsp_but.png", "GUI/SweetBonanza_ferrsp_but.png", "GUI/SweetBonanza_ferrsp_but.png"},
        }
        self.m_btnStart._status_ = _newStatus
        self.m_btnStart:loadTextures(btnFile[_newStatus][1], btnFile[_newStatus][2], btnFile[_newStatus][3])
        if _newStatus == btn_status.status_free then
            local free_num = self.m_btnStart:getChildByName("free_num"):show()
            free_num:setString(self._scene.m_cbFreeTime)
        else
            self.m_btnStart:getChildByName("free_num"):setVisible(false)
        end
        if _newStatus == btn_status.status_auto then
            self.m_btnAuto:getChildByName("img_auto"):setVisible(true)
        else
            self.m_btnAuto:getChildByName("img_auto"):setVisible(false)
        end
    end
end

function GameViewLayer:getBtnStatusIsNormal()
    return self.m_btnStart._status_ == btn_status.status_normal
end
-- 按键回调
function GameViewLayer:onButtonClickedEvent(_sender)
    local tag = _sender:getTag()
    tlog('GameViewLayer:onButtonClickedEvent')
    if tag == TAG_ENUM.TAG_QUIT_BTN then --退出           
        self.m_btnList:setVisible(false)
        self._scene:onQueryExitGame()
    elseif tag == TAG_ENUM.TAG_EFFECT_BTN  then --音效
        GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble)
        self:flushMusicResShow(_sender, GlobalUserItem.bSoundAble)
    elseif tag == TAG_ENUM.TAG_HELP_BTN then               
        self.m_btnList:setVisible(false)
        local _helpLayer = HelpLayer:create():addTo(self, 10)
        _helpLayer:setPosition(display.width * 0.5, display.height * 0.5)      
    elseif tag == TAG_ENUM.TAG_ADD_BTN then -- 加注
        self._scene:onAddScore()
    elseif tag == TAG_ENUM.TAG_SUB_BTN then
        self._scene:onSubScore()
    elseif tag == TAG_ENUM.TAG_MAXADD_BTN then -- 最大加注
        self._scene:onAddMaxScore()

        -- local data = {}
        -- data._isBegan = false
        -- data._nums = 100
        -- data._winNums = 205000
        -- data._totalRate = 500
        -- -- data._color = cc.c4b(0, 0, 0, 0)
        -- data._callBack = function ()
        --     tlog("free game end tip")
        -- end
        -- local _freeTipLayer = BonanzaFreeTipLayer:create(data):addTo(self, 10)
        -- _freeTipLayer:setPosition(display.width * 0.5, display.height * 0.5)

        -- local data = {}
        -- data._callBack = nil
        -- data.rewardNum = 125896
        -- self.m_rewardTipNode:showRewardTip(data)
    elseif tag == TAG_ENUM.TAG_AUTO_START_BTN then
        self:autoBtnClick()
    else
        showToast(g_language:getString("game_tip_no_function"))
    end
end

--更新下注额度面板显示
function GameViewLayer:updateBetNumShow()
    tlog('GameViewLayer:updateBetNumShow')
    local serverKind = G_GameFrame:getServerKind()
    local showScore = self._scene.m_lTotalYafen
    if showScore > 99999 then
        showScore = g_format:formatNumber(showScore,g_format.fType.abbreviation,serverKind)
    else
        showScore = g_format:formatNumber(showScore,g_format.fType.standard,serverKind)
    end
    self.m_textAllyafen:setString(showScore)
end

function GameViewLayer:updateScore(notAnimation)
    tlog('GameViewLayer:updateScore ', self._scene.m_lScore, self._scene.m_lWinScore, self._scene.m_llFreeScore, notAnimation)
    self.m_textScore:stopAllActions()
    self.m_textWinScore:stopAllActions()
    -- tlog("self.m_textScore._lastNum ", self.m_textScore._lastNum, self.m_textScore._curNum)
    -- tlog("self.m_textWinScore._lastNum ", self.m_textWinScore._lastNum, self.m_textWinScore._curNum)
    self.m_textScore._lastNum = self.m_textScore._curNum
    self.m_textScore._curNum = self._scene.m_lScore

    self.m_textWinScore._lastNum = self.m_textWinScore._curNum
    self.m_textWinScore._curNum = self._scene.m_lWinScore

    if not notAnimation then
        GameLogic:updateGoldShow(self.m_textScore)
        GameLogic:updateGoldShow(self.m_textWinScore)
    else
        local serverKind = G_GameFrame:getServerKind()
        self.m_textScore:setString(g_format:formatNumber(self._scene.m_lScore,g_format.fType.standard,serverKind))
        local serverKind = G_GameFrame:getServerKind()
        self.m_textWinScore:setString(g_format:formatNumber(self._scene.m_lWinScore,g_format.fType.standard,serverKind))
    end
    if self._scene.m_lScore <= 999999999 then
        self.m_textScore:setScale(0.64)
    elseif self._scene.m_lScore <= 9999999999 then
        self.m_textScore:setScale(0.54)
    elseif self._scene.m_lScore <= 99999999999 then
        self.m_textScore:setScale(0.5)
    else
        self.m_textScore:setScale(0.45)
    end
    --更新免费总下注
    if self.m_freeGameBg:isVisible() then
        self.m_freeTotalWin:stopAllActions()
        self.m_freeTotalWin._lastNum = self.m_freeTotalWin._curNum
        self.m_freeTotalWin._curNum = self._scene.m_llFreeScore
        if not notAnimation then
            GameLogic:updateGoldShow(self.m_freeTotalWin)
        else
            local serverKind = G_GameFrame:getServerKind()
            self.m_freeTotalWin:setString(g_format:formatNumber(self._scene.m_llFreeScore,g_format.fType.standard,serverKind))
        end
    end
end

function GameViewLayer:updateFreeTimeShow()
    if self.m_freeGameBg:isVisible() then
        tlog('GameViewLayer:updateFreeTimeShow ', self._scene.m_cbFreeTime)
        self.m_btnStart:getChildByName("free_num"):setString(self._scene.m_cbFreeTime)
    end
end

function GameViewLayer:updataBtnEnable()
    tlog("GameViewLayer:updataBtnEnable ", self._scene.m_cbFreeTime, self._scene:getGameMode())
    if self._scene.m_cbFreeTime > 0 then
        self.m_btnStart:setEnabled(false)
        self.m_btnAdd:setEnabled(false)
        self.m_btnSub:setEnabled(false)
        --self.m_btnMaxAdd:setEnabled(false)
        self.m_btnAuto:setEnabled(false)
    else
        if self._scene:getGameMode() == 0 then --等待
            self.m_btnStart:setEnabled(self.m_btnStart._status_ ~= btn_status.status_auto)
            self.m_btnAdd:setEnabled(self.m_btnStart._status_ ~= btn_status.status_auto)
            self.m_btnSub:setEnabled(self.m_btnStart._status_ ~= btn_status.status_auto)
            --self.m_btnMaxAdd:setEnabled(self.m_btnStart._status_ ~= btn_status.status_auto)
            self.m_btnAuto:setEnabled(true)
        else
            self.m_btnStart:setEnabled(false)
            self.m_btnAdd:setEnabled(false)
            self.m_btnSub:setEnabled(false)
            --self.m_btnMaxAdd:setEnabled(false)
            self.m_btnAuto:setEnabled(self.m_btnStart._status_ == btn_status.status_auto)
        end
    end
end

-- 游戏1动画开始
function GameViewLayer:gameBegin()
    tlog('GameViewLayer:gameBegin')
    self:updataBtnEnable()
    self.m_centerPanel:setClippingEnabled(true)
    self.m_scrollLayer:setRunItem(self._scene.m_cbItemInfo, handler(self, self.GameGetLineResult))
    self.m_scrollLayer:run()
end

-- 游戏连线结果
function GameViewLayer:GameGetLineResult()
    tlog('GameViewLayer:GameGetLineResult')
    self._scene.m_bIsItemMove = false
    self.m_centerPanel:setClippingEnabled(false)

    local _curRewardItemNums = #self._scene.m_curRewardItemArray

    local function callback()
        if _curRewardItemNums > 0 then
            -- ExternalFun.playSoundEffect("SingleExplosion.wav")
            self.m_scrollLayer:setAllItemWin(self._scene.m_broadRewardStatus)
        end
        local temptime = 0.01
        if _curRewardItemNums > 0 then
            temptime = 0.1
        end
        self:performWithDelay(temptime, function()
            self:onGetGameScore()
        end)
    end

    if _curRewardItemNums > 0 then
        self:performWithDelay(0.2, function()
            callback()
        end)
    else 
        callback()
    end
end

-- 游戏1结果
function GameViewLayer:onGetGameScore()
    tlog("GameViewLayer:onGetGameScore")
    local function callback()
        if self._scene.m_bIsItemMove == true then
            return
        end
        if self._scene:checkCurBoardEnableRemove() then
            self._scene:onDeleteGameStart()
            return
        end

        self._scene:setGameMode(0)
        self:updataBtnEnable()

        local retResult = self:onAddFreeTime(false)
        if self._scene.m_cbFreeTime <= 0 then
            if self.m_freeGameBg:isVisible() then
                local data = {}
                data._isBegan = false
                data._nums = self._scene.m_totalFreeTime
                data._winNums = self._scene.m_llFreeScore
                data._totalRate = self._scene.m_totalExtraTimes
                -- data._color = cc.c4b(0, 0, 0, 0)
                data._callBack = function ()
                    tlog("free game end tip")
                    self:playGamebgMusic(true)
                    self:setFreeNodeVisible(false)
                    if self._auto then --自动模式下进入免费模式出来后需继续自动
                        self:checkFlushBtnShow(btn_status.status_auto)
                        self._scene:onAutoStart()
                    else
                        self:checkFlushBtnShow(btn_status.status_normal)
                    end
                end
                local _freeTipLayer = BonanzaFreeTipLayer:create(data):addTo(self, 10)
                _freeTipLayer:setPosition(display.width * 0.5, display.height * 0.5)
                self._scene.m_totalExtraTimes = 0
            end
            if self.m_btnStart._status_ == btn_status.status_auto then
                self._scene:onAutoStart()
            end
        else
            if retResult == 2 then 
                --启动免费游戏提示画面
                local data = {}
                data._isBegan = true
                data._nums = self._scene.m_cbFreeTime
                -- data._color = cc.c4b(0, 0, 0, 0)
                data._callBack = function ()
                    tlog("first start free game")
                    self:playGamebgMusic(false)
                    self._scene:GameStart()
                end
                local _freeTipLayer = BonanzaFreeTipLayer:create(data):addTo(self, 10)
                _freeTipLayer:setPosition(display.width * 0.5, display.height * 0.5)
            else
                --直接开始
                self._scene:GameStart()
            end
        end
    end
    --最后一屏了
    local _curGetCoins = self._scene.m_lGetCoins
    local delayTime = 0.1
    if _curGetCoins > 0 then
        delayTime = 0.7
        self.m_getScoreLabel:stopAllActions()
        self.m_getScoreLabel:setVisible(true)
        local serverKind = G_GameFrame:getServerKind()
        self.m_getScoreLabel:setString(g_format:formatNumber(_curGetCoins,g_format.fType.standard,serverKind))
        local posX = (1.5 + math.random(0, 3)) * GameLogic.ITEM_WIDTH
        local posY = 0.5 * GameLogic.ITEM_HEIGHT + math.random(0, 500)
        self.m_getScoreLabel:setPosition(posX, posY)
        local scale1 = cc.ScaleTo:create(0.3, 1.2)
        local scale2 = cc.ScaleTo:create(0.3, 0.8)
        local moveby = cc.MoveBy:create(0.6, cc.p(0, 100))
        local seque1 = cc.Sequence:create(scale1, scale2)
        local spawn = cc.Spawn:create(seque1, moveby)
        self.m_getScoreLabel:runAction(cc.Sequence:create(spawn, cc.CallFunc:create( function()
            self.m_getScoreLabel:setVisible(false)
        end)))
    else
        self.m_getScoreLabel:setVisible(false)
    end
    if not self._scene:checkCurBoardEnableRemove() then
        --如果最后一屏的中奖金币大于0，表示此次旋转中有爆炸元素
        --如果这一局有炸弹元素，需要在最后一屏的时候展示爆炸效果，并且爆炸前赢金数量是没有乘以倍数的
        local endCall = function ()
            local rateNum = self._scene.m_lWinScore / self._scene.m_lTotalYafen --当局中奖倍数
            if rateNum >= GameLogic.Reward_Scope.small then
                --达到弹框标准
                local data = {}
                data._callBack = callback
                data.rateNum = rateNum
                data.rewardNum = self._scene.m_lWinScore
                self.m_rewardTipNode:showRewardTip(data)
            else
                self:performWithDelay(0.1, callback)
            end
        end
        if _curGetCoins > 0 then
            --展示炸弹动画
            self.m_scrollLayer:showLastBombEffect(self.m_nodeAction)
            self:performWithDelay(2, endCall)
            self:updateScore()
        else
            self:performWithDelay(0, endCall)
        end
        self:updateFreeTimeShow()
    else
        self:performWithDelay(delayTime, callback)
    end
end

function GameViewLayer:DeleteGame()
    tlog('GameViewLayer:DeleteGame')
    self.m_centerPanel:setClippingEnabled(true)
    self.m_scrollLayer:runDeleteGame(self._scene.m_cbItemInfo, handler(self, self.GameGetLineResult))
end

--重连或刚进入判断是否有免费
function GameViewLayer:onAddFreeTime(_isReenter)
    tlog('GameViewLayer:onAddFreeTime ', self._scene.m_cbFreeTime, _isReenter)
    local retResult = 0     --0 没有免费，1非首次免费，2首次免费
    if self._scene.m_cbFreeTime > 0 then
        retResult = 1
        if not self.m_freeGameBg:isVisible() then
            retResult = 2
            self:setFreeNodeVisible(true)
            if not _isReenter then
                self._scene.m_llFreeScore = 0
                self._scene.m_totalExtraTimes = 0
                self._scene.m_totalFreeTime = self._scene.m_cbFreeTime
            else
                self:playGamebgMusic(false)
            end
            self.m_freeTotalWin._lastNum = self._scene.m_llFreeScore
            self.m_freeTotalWin._curNum = self._scene.m_llFreeScore
            local serverKind = G_GameFrame:getServerKind()
            self.m_freeTotalWin:setString(g_format:formatNumber(self._scene.m_llFreeScore,g_format.fType.standard,serverKind))
        end
        self:checkFlushBtnShow(btn_status.status_free)
        if _isReenter then
            self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function ()
                tlog("enter free start game")
                self._scene:GameStart()
            end)))
            self.m_rewardTipNode:setSelfVisible(false)
        end
    else
        if _isReenter then
            self:playGamebgMusic(true)
            --非重连的在其他地方处理了
            self:setFreeNodeVisible(false)
            self:checkFlushBtnShow(btn_status.status_normal)
            self.m_rewardTipNode:setSelfVisible(false)
        end
    end
    tlog('retResult is ', retResult)
    return retResult
end

function GameViewLayer:registerTouch()
    tlog('GameViewLayer:registerTouch')
    local function onTouchBegan( touch, event )
        return true
    end

    local function onTouchEnded( touch, event )
        tlog('GameViewLayer onTouchEnded')
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

function GameViewLayer:stopBtnTimerCall()
    if self.m_btnChangedTimer ~= nil then
        g_scheduler:unscheduleScriptEntry(self.m_btnChangedTimer)
        self.m_btnChangedTimer = nil
    end
end

function GameViewLayer:playGamebgMusic(_normal)
    local musicPath = "sound_res/bonanza_bg_normal.mp3"
    if not _normal then
        musicPath = "sound_res/bonanza_bg_free.mp3"
    end
    tlog('GameViewLayer:playGamebgMusic ', _normal)
    ExternalFun.stopMusic()
    ExternalFun.playMusic(musicPath, true)
end

return GameViewLayer