

-- local GameViewLayer = class("GameViewLayer",ccui.Layout)
local GameViewLayer =
    class(
    "GameViewLayer",
    function(scene)
        local gameViewLayer = display.newLayer()
        return gameViewLayer
    end
)
local module_pre = "game.yule.newcaishen.src"
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local logic = appdf.req(module_pre .. ".models.GameLogic")
local TurnedAround = appdf.req(module_pre .. ".turnedCode.TurnedAround")
local TurnConfig = appdf.req(module_pre .. ".turnedCode.TurnConfig")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
local ef = g_ExternalFun


function GameViewLayer:ctor(rootNode)
    self._root = rootNode
    self:init()
    display.loadSpriteFrames('GUI/img/csdItems.plist', 'GUI/img/csdItems.png')
    cc.SpriteFrameCache:getInstance():addSpriteFrames("GUI/img/csdItems.plist")
    self:initCsbRes()
    self:initCanvas()
	self:initScrollItem()
    self.turnedAround:setSpeedByType(self.isQuick)
    -- self:initTestLine()
    cc.SimpleAudioEngine:getInstance():preloadEffect("sounds/prewin_C64kbps.mp3")
    ef.playMusic(logic.sound.bg)
end

function GameViewLayer:init()
    self.effectNodes = {}      
    self.effectNodes.glowNodes = {}    --glow 光圈特效组  
    self.effectNodes.iconNodes = {}    --icon 特效组     > icon_6 的有中奖动效  有光圈，有特效
    self.effectNodes.bounsNodes = {}   --bouns 特效组    bouns 没有光圈，有特效
    self.WILD_nodes = {}            --wild  百搭常驻动效  
    self.spineSpeed = {}        --列光圈特效
    self.betScore = 50          --投注基数
    self.curBetIndex = 1        --当前下注index   
    self.openEggArray = {}      --开蛋的标志数据
    self.isQuick = true         --快速模式  
    self.isAutoMode = false     --自动游戏模式
    self.autoCount = 0          --自动游戏次数
    self.freeCount = 0          --免费次数        合计的，包括上次免费没跑完的
    self.MaxFreeCount = 0       --总的免费次数    一轮总获取免费次数
    self.curGetFreeCount = 0    --当前小游戏获取的免费次数
    self.isMiniMode = false       --小游戏模式
    self.openCount = 0          --开蛋次数
    self.winScore = 0           --赢分
    self.eggAnim = {}           --开蛋动画索引
    self.randTab = {}           --自动开蛋数据
    for i=1,12 do
        table.insert(self.randTab,i)
    end
    self.lastGameModes = nil      -- 上个场景状态
    self.currGameModes = 1         --当前场景状态   1：普通 2：开罐子  3：免费游戏
    self.nFreeTotalAwardGold = 0 --当前轮总赢取金币数
    self.isBtnClick = true
    self.userGold = 0            --用户金币
end

--界面初始化
function GameViewLayer:initCsbRes()
    local csbNode = cc.CSLoader:createNode("UI/GameLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    csbNode:addTo(self)
    ef.loadChildrenHandler(self, csbNode)
    self.mm_Image_menubg:hide()
    self.mm_Panel_gameMini:hide()
    self.mm_Panel_mini_shade:hide()
    self.mm_Panel_icon:hide()
    self.mm_img_free:hide()
    --self.mm_btn_auto:hide()
    self.mm_Image_countbg:hide()
end

function GameViewLayer:getParentNode()
    return self._root
end
function GameViewLayer:onExitClick()
    self.turnedAround:stopRollAction()
    self:removeSprite()
    self:getParentNode():onUiExitTable()
end

function GameViewLayer:removeSprite()
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("GUI/img/csdItems.plist")
    display.removeSpriteFrames('GUI/img/csdItems.plist', 'GUI/img/csdItems.png')
end

function GameViewLayer:initCanvas()
    --菜单
    self.mm_btn_menu:onClicked(function()self.mm_Image_menubg:setVisible(not self.mm_Image_menubg:isVisible())end)
    self.mm_btn_close:onClicked(function() self:onExitClick() end)
    self.mm_btn_help:onClicked(function() 
        self:createHelp() 
        self.mm_Image_menubg:hide()
    end)

    self.mm_btn_setting:onClicked(function() 
        GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble)
        GlobalUserItem.setVoiceAble(not GlobalUserItem.bVoiceAble)
        self.mm_Image_sound_1:setVisible(GlobalUserItem.bSoundAble)
        self.mm_Image_sound_0:setVisible(not GlobalUserItem.bSoundAble)
    end)

    --拦截关闭
    self.mm_Panel_close:addClickEventListener(function() self.mm_Image_countbg:hide() end)
    --下注
    self.mm_btn_start:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
        elseif eventType == ccui.TouchEventType.canceled then
			sender:stopAllActions()
        elseif eventType == ccui.TouchEventType.ended then
            sender:stopAllActions()
            if not self.isAutoMode then
                self:setStartEnable(false)
                performWithDelay(self.mm_btn_start,function()
                    self:setBtnStopStatus(true)
                end,0.3)
                self:sendStart()
            end
        end
	end)
    --停止转动  
    self.mm_btn_stop:addClickEventListener(function() 
        self.mm_btn_stop:setTouchEnabled(false)
        self.mm_btn_stop:setBright(false)
        self.turnedAround:stopRollAction()
    end)
    self.mm_btn_auto:onClicked(function() 
        if not self.isAutoMode then
            self.isAutoMode = true
            self.autoCount = 10000
            self.mm_Image_countbg:hide()
            self:checkButtonStart()
            self:setStartEnable(false)
            self.mm_Image_gou:setVisible(true)
        else
            self.isAutoMode = false
            self.autoCount = 0
            self:setStartEnable(true)
            self.mm_Image_gou:setVisible(false)
        end
    end)
    --是否开启快速游戏
    self.mm_btn_quick:addClickEventListener(function() 
        self.isQuick = not self.isQuick 
        self.mm_Image_quickTag:setVisible(self.isQuick)
        self.turnedAround:setSpeedByType(self.isQuick)
    end)
    --最大下注
    self.mm_btn_maxbet:addClickEventListener(function() 
        if not self.isBtnClick then return end
        self.curBetIndex = #self.betArray 
        self:setBetLine(self.curBetIndex)
    end)

    --加注
    self.mm_btn_add:addClickEventListener(function()
        if not self.isBtnClick then return end
        self.curBetIndex = self.curBetIndex + 1
        if self.curBetIndex >= #self.betArray then
            self.curBetIndex = #self.betArray
        end
        self:setBetLine(self.curBetIndex)
    end)
    --减注
    self.mm_btn_sub:addClickEventListener(function() 
        if not self.isBtnClick then return end
        self.curBetIndex = self.curBetIndex - 1
        if self.curBetIndex <= 1 then
            self.curBetIndex = 1
        end
        self:setBetLine(self.curBetIndex)
    end)

    --自动游戏次数
    local autoCount = {10,30,50,100,10000}
    for i,v in ipairs(autoCount) do
        self["mm_btn_"..v]:onClicked(function() 
            self.isAutoMode = true
            self.autoCount = v
            self.mm_Image_countbg:hide()
            self:checkButtonStart()
        end)
    end
    self:setWinGold(0)
    self:setAllWinGold(0)
    self:checkButtonStart()


    local currencyType = G_GameFrame:getServerKind()
    g_ExternalFun.setIcon(self.mm_Image_11,currencyType)

end

function GameViewLayer:checkButtonStart()
    if self.currGameModes == logic.SCENE_TYPE.free then
        --免费模式优先级最高
        if self.isMiniMode == false then
            --不在小游戏模式。
            print("免费转动："..self.freeCount)
            if self.freeCount == self.MaxFreeCount then
                self:setImgAutoStatus(false)
            end
            performWithDelay(self.mm_img_free,function() 
                print("free")
                self:sendStart()
            end,2)
        else
            print(self.isMiniMode)
            print("免费中再次启动小游戏")
        end
    else
        --开蛋完了currGameModes = 2 currScene==(2 or 3) 都需要重启自动滚动
        if self.isAutoMode then
            if self.autoCount <= 0 then
                self:setImgAutoStatus(false)
            else
                -- local str = self.autoCount > 100 and "∞" or self.autoCount
                -- self.mm_Text_autoCount:setString(str)
                self:setImgAutoStatus(true)
                performWithDelay(self.mm_btn_auto,function() 
                    print("auto")
                    self:sendStart()
                end,1)
            end
        end
    end
end

function GameViewLayer:setStartEnable(isTouch)
    self.mm_btn_start:setTouchEnabled(isTouch) 
    self.mm_btn_start:setBright(isTouch) 
end

function GameViewLayer:setBtnStopStatus(isShow)
    if isShow == false then
        self.mm_btn_stop:setVisible(isShow) 
        self.mm_btn_stop:setTouchEnabled(true)
        self.mm_btn_stop:setBright(true)
    else
        self.mm_btn_stop:setVisible(isShow)    
    end
end
function GameViewLayer:setImgAutoStatus(isShow)
    --self.mm_btn_auto:setVisible(isShow)
end
function GameViewLayer:setPanelStartStatus(isShow)
    print(isShow)
    self.mm_Panel_start:setVisible(isShow)
    self:setStartEnable(true)
end

function GameViewLayer:setImgFreeStatus(isShow)
    if isShow then
        self:setPanelStartStatus(isShow) 
    end
    self.mm_img_free:setVisible(isShow)
end
--其他按钮状态 禁用
function GameViewLayer:setOtherBtnStatus(isDisabled)
    self.isBtnClick = isDisabled
    self.mm_btn_sub:setBright(isDisabled)
    self.mm_btn_add:setBright(isDisabled)
    self.mm_btn_maxbet:setBright(isDisabled)
    -- self.mm_btn_quick:setBright(isDisabled)
end

--小游戏开罐子 5个开完的屏蔽点击层
function GameViewLayer:miniShadeStatus(isShow)
    self.mm_Panel_mini_shade:setVisible(isShow)
end

--设置投注额度
function GameViewLayer:setBetLine(betIndex)
    local serverKind = G_GameFrame:getServerKind()
    local betScore = g_format:formatNumber(self.betArray[betIndex],g_format.fType.abbreviation,serverKind)
    self.mm_Text_betLine:setString(string.format("%d X %s", self.betScore, betScore))
    local totalBet = self.betScore * self.betArray[betIndex]
    local serverKind = G_GameFrame:getServerKind()
    self.mm_Text_betNumber:setString(g_format:formatNumber(totalBet,g_format.fType.abbreviation,serverKind))
    self:setBigwinConfig()
end

--设置用户金币
function GameViewLayer:setUserGold(gold,isGoldRoll)
    local changsGold = function()
        local serverKind = G_GameFrame:getServerKind()
        local strGold = g_format:formatNumber(tonumber(gold),g_format.fType.standard,serverKind)
        -- strGold = string.gsub(strGold,",","/")
        self.mm_AtlasLabel_myGold:setString(strGold)
    end

    if gold > self.userGold then
        if isGoldRoll then
            self:goldRoll(self.mm_AtlasLabel_myGold,gold,1)
        else
            changsGold()
        end
    else
        changsGold()
    end
end
function GameViewLayer:setAllWinGold(allWinGold)

    self:goldRoll(self.mm_Text_winGold_all,allWinGold,0.5)
end
--设置赢金
function GameViewLayer:setWinGold(winGold)
    local winGold = tonumber(winGold)
    if winGold > 0 then
        local serverKind = G_GameFrame:getServerKind()
        local _winGold = g_format:formatNumber(winGold,g_format.fType.standard,serverKind)
	--_winGold = string.gsub(_winGold,",","/")
        self.mm_Text_winGold:setString("+".._winGold)
        self.mm_Text_winGold:show()
        self.mm_Image_winStr:hide()
        performWithDelay(self.mm_Image_winStr,function()
            self.mm_Image_winStr:show()
            self.mm_Text_winGold:hide()
        end,1.5)
    else
        self.mm_Image_winStr:show()
        self.mm_Text_winGold:hide()
    end
end
--金币滚动
function GameViewLayer:goldRoll(textNode,goldCount,rollTime)
    if not textNode.setString then return end
    goldCount = tonumber(goldCount or 0)
    if goldCount == 0 then
        textNode:setString(0)
        return
    end
    local textGold = textNode:getString()
    textGold = string.gsub(textGold, "[(.·,?+-/;:~!@#$%^&*|`'_%)]", "")
    textGold = tonumber(textGold) 
    if textGold == goldCount then return end
    local num = {value = textGold}
    local onUpdate = function() 
        local n,_ = math.modf(num.value)
        local serverKind = G_GameFrame:getServerKind()
        if textNode and not tolua.isnull(textNode) then
            textNode:setString(g_format:formatNumber(n,g_format.fType.standard,serverKind))
        end
    end
    TweenLite.to(num,rollTime,{value = goldCount,onUpdate = onUpdate})
end

function GameViewLayer:setBetArray(data)
    self.betArray = data.betArray
    self.configData = data
    self:setBigwinConfig()
end

function GameViewLayer:setBigwinConfig()
    local betScore = self.betArray[self.curBetIndex] * self.betScore
    self.bigwinConfig = {}
    self.bigwinConfig[1] = self.configData.llsmall * betScore
    self.bigwinConfig[2] = self.configData.llmiddle * betScore
    self.bigwinConfig[3] = self.configData.llbig * betScore
end

--清理game2页面
function GameViewLayer:clearGame2Layer()
    for i,v in ipairs(self.eggAnim) do
        if self:isLuaNodeValid(self.eggAnim[i]) then
            self.eggAnim[i]:removeFromParent()
        end
    end
    self.eggAnim = {}
end
--清理 icon 效果
function GameViewLayer:clearIconEffect()
    for j,v in pairs(self.effectNodes) do
        for i=#v,1,-1 do
            self.effectNodes[j][i]:removeFromParent()
            self.effectNodes[j][i] = nil
        end
    end
end

function GameViewLayer:clearWILDicon()
    if self.lastGameModes == nil or self.lastGameModes ~= logic.SCENE_TYPE.free then 
	    for k,v in pairs(self.WILD_nodes) do
	        self.WILD_nodes[k]:removeFromParent()
	        self.WILD_nodes[k] = nil
	    end
	    self.MaxFreeCount = 0
	end
end  
--开始
function GameViewLayer:sendStart()
    self.curBetData = nil
    self:setWinGold(0)
    if self.currGameModes == logic.SCENE_TYPE.game then
        self.nFreeTotalAwardGold = 0
        self:setAllWinGold(self.nFreeTotalAwardGold)
    end
    if isTest then
        self:betResult(logic.gameData)
    else
        if self.currGameModes == 2 then return end
        self._root:sendStart(self.curBetIndex)
        self.subGoldCount = self.betArray[self.curBetIndex] * self.betScore
        EventPost:addCommond(EventPost.eventType.SPIN,"slot每次spin",1,nil,{gameId = self._root:getGameKind(),
		    roomId = GlobalUserItem.roomMark,betPrice = self.subGoldCount
	    })  
    end
end
--游戏开始返回
function GameViewLayer:betResult(data)
    self.curBetData = data
    self.lastGameModes = self.currGameModes
    self.currGameModes = data.bGameModes
    self.MaxFreeCount = data.all_frees_count
    self.freeCount = data.frees_count
    self.mm_btnText_freeCount:setString(self.freeCount.."/"..self.MaxFreeCount)
    if self.currGameModes ~= logic.SCENE_TYPE.free then
        if self.isAutoMode then
            self.autoCount = self.autoCount - 1
        end
    end
    if self.currGameModes == logic.SCENE_TYPE.free or self.lastGameModes == logic.SCENE_TYPE.free then
        self.nFreeTotalAwardGold = self.nFreeTotalAwardGold + data.lWinScore
    else
        self.nFreeTotalAwardGold = data.lWinScore
    end

    if data.frees_count > 0 then
        self:setImgFreeStatus(true)
    end
    
    self:setOtherBtnStatus(false)
    if data.bouns_count > 0 then
        self.isMiniMode = true  --进入小游戏状态
    end
    
    self.iconData = logic.getLineData(data)
    self:runAllAction(data.result_icons)
    -- self:updateTestLine(data)
end

--画线 
function GameViewLayer:drawLine(data)
    local tShowItem = self.turnedAround:getShowItem()
    local iconData = self.iconData
    for y = 1,cmd.MAX_HS do
        for x = 1,cmd.MAX_LS do
            local item = iconData[y][x]
            if item.tag then
                if item.icon > 6 and item.icon < 11 then
                    --icon特效
                    local iconEffect = self:playSpine(self.mm_Panel_icon,logic.iconAnimName[item.icon][1],logic.iconAnimName[item.icon][2],self.tRandPos[y][x] )
                    table.insert(self.effectNodes.iconNodes,iconEffect)
                    tShowItem[x][cmd.MAX_HS - y + 1]:setOpacity(0)
                end
                --光圈特效
                local boxEffect = self:playSpine(self.mm_Panel_icon,logic.iconAnimName["boxEffect"][1],logic.iconAnimName["boxEffect"][2],self.tRandPos[y][x] )
                table.insert(self.effectNodes.glowNodes,boxEffect)
            end
            if item.BOUNS and data.bouns_count > 0 then
                --bouns 特效
                local iconEffect = self:playSpine(self.mm_Panel_icon,logic.iconAnimName[item.icon][1],logic.iconAnimName[item.icon][2],self.tRandPos[y][x] )
                table.insert(self.effectNodes.bounsNodes,iconEffect)
                tShowItem[x][cmd.MAX_HS - y + 1]:setOpacity(0)
            end
            if item.WILD_free then
                --免费百搭特效
                if not self:isLuaNodeValid(self.WILD_nodes[x]) then
                    local iconEffect = self:playSpine(self.mm_Panel_icon,logic.iconAnimName["wild"][1],logic.iconAnimName["wild"][2],self.tRandPos[y][x] )
                    self.WILD_nodes[x] = iconEffect
                end
                self.WILD_nodes[x]:addAnimation(0,"idle",true)
                tShowItem[x][cmd.MAX_HS - y + 1]:setOpacity(0)
            end
        end
    end
    if #self.effectNodes.glowNodes > 0 then
        ef.playEffect(logic.sound.effect)
    end

    self:setBtnStopStatus(false)
end

--检查进入小玛丽
function GameViewLayer:checkEnter2Game(data)
    if data.bouns_count <= 0 then
        self:checkButtonStart()
        self:setOtherBtnStatus(true)
        if not self.isAutoMode then
            self:setStartEnable(true)
        end
        return 
    end

    self:setPanelStartStatus(not self.isMiniMode)
    performWithDelay(self,function() 
        for k,v in pairs(self.effectNodes.bounsNodes) do
            v:setAnimation(0,"get",true)
        end
        self:initMiniGameScene(data)
    end,2) 
end

function GameViewLayer:playSpine(pNode,spinePath,animName,pos,callback)
    local rootPath = "GUI/spine/"
    local animation = sp.SkeletonAnimation:create(rootPath..spinePath..".json",rootPath..spinePath..".atlas",1)
    pNode:addChild(animation)
    if pos then
        animation:setPosition(pos)
    end
    animation:setAnimation(0,animName,true)

    animation:registerSpineEventHandler(function (event)
        if event.type == "complete"  then
            if callback then
                callback(animation)
            end
        end
    end, sp.EventType.ANIMATION_COMPLETE)
    return animation
end

function GameViewLayer:onOpenEggClick(i)
    if isTest == true then
        print(self.openCount,"openCount?????????????????")
        logic.Cmd_S_HitGoldEggRes[self.openCount+1].nHitPos = i-1
        self:onOpenEggResult(logic.Cmd_S_HitGoldEggRes[self.openCount+1])
    else
        if self.openCount >= 5 then return end
        self.openCount = self.openCount + 1
        self.mm_Node_schedule:stopAllActions()
        self._root:openEgg(i-1)
    end
end

function GameViewLayer:scheduleOpenEgg(delayTime)
    print("delayTime>>>>>>>>>>>>>>>>>:",delayTime,#self.randTab)
    performWithDelay(self.mm_Node_schedule,function()
        local i = math.random(1,#self.randTab)
        self:onOpenEggClick(self.randTab[i])
        table.remove(self.randTab,i)
        print(">>>>>>>>>>"..i)
        dump(self.randTab)
    end,delayTime)
end

--开蛋服务器返回
function GameViewLayer:onOpenEggResult(data)
    self.currGameModes = data.bGameModes
    self.mm_Node_schedule:stopAllActions()
    self.openEggArray[data.nHitPos+1] = data.nGoldCount
    self.mm_Text_miniGameCount:setString(5 - self.openCount)                --剩余开蛋次数
    -- self.nFreeTotalAwardGold = self.nFreeTotalAwardGold + data.nMultiply
    self.winScore = self.winScore + data.nMultiply
    local serverKind = G_GameFrame:getServerKind()
    self.mm_Text_miniWinScore:setString(g_format:formatNumber(self.winScore,g_format.fType.standard,serverKind))                      --敲蛋右上角赢分
    local serverKind = G_GameFrame:getServerKind()
    self["mm_text_fnt_"..data.nHitPos+1]:setString(g_format:formatNumber(data.nMultiply,g_format.fType.standard,serverKind))
    self["mm_text_fnt_"..data.nHitPos+1]:show()

    if data.nGoldCount > 0 then
        --中了金财神
        self.eggAnim[data.nHitPos+1]:setAnimation(0,"open_2_start",false)
        self.eggAnim[data.nHitPos+1]:addAnimation(0,"open_2_end",false)

        self.leftLion:setAnimation(0,"jump",false)
        self.leftLion:addAnimation(0,"idle",true)

        self.rightLion:setAnimation(0,"jump",false)
        self.rightLion:addAnimation(0,"idle",true)
        ef.playEffect(logic.sound.TreasureBowGod)
    else
        self.eggAnim[data.nHitPos+1]:setAnimation(0,"open_1",false)
        ef.playEffect(logic.sound.openEgg)
    end

    --小游戏结束，更新状态
    if data.bGameModes == 3 then
        self.MaxFreeCount = data.all_frees_count
        self.freeCount = data.freeCount
        self.curGetFreeCount = data.cur_get_frees_count
        -- 后续服务器推送 onGoldEggDetailResult 触发免费游戏
        if isTest == true then
            self:miniShadeStatus(true)
            performWithDelay(self.mm_Panel_gameMini,function() 
                self:onGoldEggDetailResult(logic.CMD_S_SCENE_Data)
            end,1)
        end
    elseif data.bGameModes == 2 then
        self:scheduleOpenEgg(3)
    else

    end 
    self.isMiniMode = (data.bGameModes == 2)
end
--开完5次后数据
function GameViewLayer:onGoldEggDetailResult(data)
    self.mm_Node_schedule:stopAllActions()
    self:miniShadeStatus(true)
    local action = {}
    for i,v in ipairs(data.nMultiply) do
        if not self.openEggArray[i] then
            local _time = cc.DelayTime:create(0.4)
            local func = cc.CallFunc:create(function()
                if data.nGoldWealth[i] > 0 then
                    self.eggAnim[i]:setAnimation(0,"open_2_start",false)
                    self.eggAnim[i]:addAnimation(0,"open_2_end",false)
                else
                    self.eggAnim[i]:setAnimation(0,"open_1",false)
                end
                self["mm_btn_game2_"..i]:setOpacity(70)
                local serverKind = G_GameFrame:getServerKind()
                self["mm_text_fnt_"..i]:setString(g_format:formatNumber(data.nMultiply[i],g_format.fType.standard,serverKind))
                self["mm_text_fnt_"..i]:show()
            end)
            table.insert(action,_time)
            table.insert(action,func)
        end
    end
    local _time = cc.DelayTime:create(2)
    local nextFunc = cc.CallFunc:create(function() self:createWinShow() end) 
    table.insert(action,_time)
    table.insert(action,nextFunc)
    self.mm_Image_contentBG:runAction(cc.Sequence:create(unpack(action)))
end
--大财神，开完蛋页面
function GameViewLayer:createWinShow()
    self:miniShadeStatus(false)
    self.openEggArray = {}
    self.mm_Panel_gameMini:hide()
    self.mm_Panel_content:show()
    self:clearGame2Layer()
    local youWinLayer = appdf.req(module_pre .. ".views.layer.youWinLayer")
    local func = function() 
        self:clearGame2Layer()
        self.winShowNode = nil
        local callback = function() 
            self:setAllWinGold(self.nFreeTotalAwardGold )  
            if self.currGameModes == logic.SCENE_TYPE.free and self.curGetFreeCount > 0 then
                performWithDelay(self,function() 
                    self:createFreeShow()
                end,0.5)
            else
                -- self.currGameModes = logic.SCENE_TYPE.game
                self:setOtherBtnStatus(true)
                self:setPanelStartStatus(true)
                self:checkButtonStart()
                self:setUserGold(self.userGold,true)
            end
        end
        if self.winScore >= self.bigwinConfig[1] then
            self:createBigwin(callback,self.winScore)
        else
            callback()
        end
    end
    self.winShowNode = youWinLayer:create(self,func)
    self:addChild(self.winShowNode)  
    self.nFreeTotalAwardGold = self.nFreeTotalAwardGold + self.winScore
end
--免费游戏提示页面
function GameViewLayer:createFreeShow()
    local func = function() 
        self.freeShowNode = nil
        self.mm_btnText_freeCount:setString(self.freeCount.."/"..self.MaxFreeCount)
        self:setImgFreeStatus(true)
        self:checkButtonStart()   --检查进入免费游戏
        self:setOtherBtnStatus(true)
    end
    local freeShowNode = appdf.req(module_pre .. ".views.layer.freeShowLayer")
    self.freeShowNode = freeShowNode:create(self,func)
    self:addChild(self.freeShowNode)  
end

--bigwin页
function GameViewLayer:createBigwin(_callback,goldCount)
    local func = function() 
        --ef.stopMusic()
        ef.playMusic(logic.sound.bg)
        self.bigwinNode = nil
        if _callback then
            _callback()
        end
    end
    local bigwin = appdf.req(module_pre .. ".views.layer.bigwinLayer")
    self.bigwinNode = bigwin:create(func,self.bigwinConfig,goldCount)    
    self:addChild(self.bigwinNode)
    ef.playMusic(logic.sound.bigwin)
end

--场景消息 断线重连
function GameViewLayer:onEventGameScene(data)
    if isTest then
        data = logic.onEventGameScene_2
    end
    dump(data,"onEventGameScene")

    self:clearGame2Layer()
    self:clearIconEffect()
    self.currGameModes = data.bGameModes
    self.betScore = data.bet_score
    self.userGold = data.win_score[1]
    if self.currGameModes == logic.SCENE_TYPE.free then
        self.userGold = data.win_score[1] - data.nFreeTotalAwardGold
        self.nFreeTotalAwardGold = data.nFreeTotalAwardGold
        self:setAllWinGold(data.nFreeTotalAwardGold)
    end
    self:setUserGold(self.userGold)

    self.curBetIndex = self._root:getBetIndex(self.betArray,self.betScore)
    self:setBetLine(self.curBetIndex)
    self.iconData = logic.getLineData(data)
    self.turnedAround:initServerData(data.result_icons)
    self:drawLine(data)
    self.mm_Panel_icon:show()
    self.MaxFreeCount = data.all_frees_count
    self.freeCount = data.frees_count

    if data.bGameModes == logic.SCENE_TYPE.openEgg then
        self.isMiniMode = true  --进入小游戏状态
        self:setPanelStartStatus(not self.isMiniMode)
        self:setOtherBtnStatus(false)
        self:initMiniGameScene(data)
    elseif data.bGameModes == logic.SCENE_TYPE.free then
        --免费模式
        self.mm_btnText_freeCount:setString(self.freeCount.."/"..self.MaxFreeCount)
        self:setImgFreeStatus(data.frees_count > 0)
        self:checkButtonStart()
    else

    end

end

--
function GameViewLayer:initMiniGameScene(miniData)
    self.curGetFreeCount = 0
    --两边狮子
    local size = self.mm_Panel_game2:getContentSize()
    local _pos = cc.p(size.width/2,size.height/2+40)

    if not self:isLuaNodeValid(self.leftLion) then
        self.leftLion = self:playSpine(self.mm_Panel_game2,logic.iconAnimName["lion_l_appear"][1],logic.iconAnimName["lion_l_appear"][2],_pos)
    else
        self.leftLion:setAnimation(0,"appear",false)
    end
    if not self:isLuaNodeValid(self.rightLion) then
        self.rightLion = self:playSpine(self.mm_Panel_game2,logic.iconAnimName["lion_r_appear"][1],logic.iconAnimName["lion_l_appear"][2],_pos)
    else
        self.rightLion:setAnimation(0,"appear",false)
    end
    self.leftLion:addAnimation(0,"idle",true)
    self.rightLion:addAnimation(0,"idle",true)
    self.openCount = 0
    self.winScore = 0
    --中间罐子
    for i=1,12 do
        self["mm_text_fnt_"..i]:setVisible(false)
        self["mm_btn_game2_"..i]:setOpacity(255)
        self["mm_btn_game2_"..i]:setTouchEnabled(true)
        local pNode = self["mm_Node_pot_"..i]
        if miniData.nMultiply and miniData.nMultiply[i] and miniData.nMultiply[i] > 0 then
            self.openCount = self.openCount + 1
            self.winScore = self.winScore + miniData.nMultiply[i]
            self["mm_text_fnt_"..i]:setVisible(true)
            if miniData.nGoldWealth and miniData.nGoldWealth[i] and miniData.nGoldWealth[i] > 0 then
                --开出金财神
                self.eggAnim[i] = self:playSpine(pNode,logic.iconAnimName["pot3"][1],logic.iconAnimName["pot3"][2])
                self.eggAnim[i]:addAnimation(0,"open_2_end",false) 
            else
                --开过普通罐子
                self.eggAnim[i] = self:playSpine(pNode,logic.iconAnimName["pot2"][1],logic.iconAnimName["pot2"][2])
                self.eggAnim[i]:addAnimation(0,"open_1",false)
            end
        else
            --待机动画
            self.eggAnim[i] = self:playSpine(pNode,logic.iconAnimName["pot"][1],logic.iconAnimName["pot"][2])
            self["mm_btn_game2_"..i]:addClickEventListener(function(target) 
                target:setTouchEnabled(false)
                self:onOpenEggClick(i)
                table.remove(self.randTab,i)
            end)
        end
    end
    self.mm_Panel_gameMini:show()
    self.mm_Panel_content:hide()
    self.mm_Text_miniGameCount:setString(5 - self.openCount)
    local serverKind = G_GameFrame:getServerKind()
    self.mm_Text_miniWinScore:setString(g_format:formatNumber(self.winScore,g_format.fType.standard,serverKind))

    self.randTab = {}
    for i=1,12 do
        table.insert(self.randTab,i)
    end
    self:scheduleOpenEgg(5)
end

function GameViewLayer:createHelp()
    local func = function() self.helpNode = nil end
    local help = appdf.req(module_pre .. ".views.layer.helpLayer")
    self.helpNode = help:create(func)    
    self:addChild(self.helpNode)
end

--获取默认旋转配置
function GameViewLayer:getNormalData()
	return TurnConfig.getRoundConfig(80,0)
end
--初始化中间的滚动模块
function GameViewLayer:initScrollItem()
	-- tlog('GameViewLayer:initScrollItem')
	self.mm_Panel_icon:removeAllChildren()
	local turnedAround = TurnedAround:create():addTo(self.mm_Panel_icon)
	turnedAround:setPosition(0, 0)
    self.turnedAround = turnedAround
    self.tRandPos = {} --桌面精灵坐标数组用于展示最后结果选中框和动画
    self.tAllImg = {} --所有的图标
    self.layers={} --转轮数组 长度为列数

    local panel_wh = self.mm_Panel_icon:getContentSize()
    local randimgPosX = panel_wh.width/cmd.MAX_LS --列数
    local randimgPosY = panel_wh.height/cmd.MAX_HS --行数

	for y=1,cmd.MAX_HS do
		self.tRandPos[y] = {}
		for x=1,cmd.MAX_LS do
			self.tRandPos[y][x]=cc.p(((x-1)*randimgPosX)+randimgPosX/2,((cmd.MAX_HS - y)*randimgPosY)+randimgPosY/2)
		end
	end

    --初始化旋转信息
    local normalData = self:getNormalData()
    local itemNum = {12,16,22,28,34} --不要随便改这个涉及到超级旋转圈数TurnedAround里定义的是{4,5,6,6,6}
    for i=1,cmd.MAX_LS do
    	local layer = display.newNode()
    	layer:setContentSize(cc.size(randimgPosX, panel_wh.height*(itemNum[i])))
    	layer:setPosition((i-1)*randimgPosX, 0)
    	layer:addTo(self.mm_Panel_icon)
    	table.insert(self.layers, layer)

    	local listLenght = #normalData[i]
    	local tempOther = {}
    	local startNum = 0
    	local num = itemNum[i]*cmd.MAX_HS
    	for j=1,num do
    		local point1 = display.newSprite("#"..logic.icons[normalData[i][((j-1)%listLenght)+1]])
    		point1:setPosition(cc.p(randimgPosX/2, (((j-1)+startNum)*randimgPosY)+randimgPosY/2))
    		point1:addTo(layer)
    		table.insert(tempOther, point1)
    	end
    	table.insert(self.tAllImg, tempOther)
    end
    self.turnedAround:initData(self.layers,self.tAllImg,self.tRandPos,panel_wh.height,cmd.MAX_LS,cmd.MAX_HS,self.fruitPic,
    	handler(self, self.runActionCallback), handler(self, self.superRunActionCallback))
end
--旋转动画
function GameViewLayer:runAllAction(nFruitAreaDistri)
	-- --清除上轮中奖动画
	self:clearSpineBoy()
    	self:clearWILDicon()  --清理免费的百搭
	local num = 2
    local itemId = logic.itemType.CSTP_BONUS
    local tCurRunTurned = TurnConfig.getRoundConfigRandom(0)
    local m_nFruitArea = nFruitAreaDistri

    local superStartCOL = 0  --开始超级旋转的列
    local sum = 0
    --后端返回的类型要加1
    for i=1,cmd.MAX_LS do
        if(m_nFruitArea[1][i] ==logic.itemType.CSTP_BONUS or m_nFruitArea[2][i] ==logic.itemType.CSTP_BONUS or m_nFruitArea[3][i] ==logic.itemType.CSTP_BONUS) then
            sum = sum +1
            if sum == 2 and i < cmd.MAX_LS then
                superStartCOL = i
                break
            end
        end
    end
	self:clearIconEffect()
    self.turnedAround:restartPos()
    self.turnedAround:runAllAction(self.endScene,m_nFruitArea,tCurRunTurned,itemId,sum,superStartCOL)
end
--重置旋转位置
function GameViewLayer:restartPos()
	self.turnedAround:restartPos()
end

function GameViewLayer:isLuaNodeValid(node)
    return(node and not tolua.isnull(node))
end

--清除上轮中奖动画
function GameViewLayer:clearSpineBoy()
	if self.glowEffectNodes then
		for k,v in pairs(self.glowEffectNodes) do
	        if self:isLuaNodeValid(v) then
	            v:removeFromParent()
	        end
	    end
		self.glowEffectNodes = {}
	end
	if self.iconEffectNode then
		for k,v in pairs(self.iconEffectNode) do
			if self:isLuaNodeValid(v) then
				v:removeFromParent()
			end
		end
		self.iconEffectNode = {}
	end
end

--旋转动画结束回调
function GameViewLayer:runActionCallback()
    
    --删除超级旋转动画
    self:hideSuperAction()
	--画线
	self:drawLine(self.curBetData)
	local callback = function() 
		local data = self.curBetData
		self:setWinGold(data.lWinScore)
		self:setAllWinGold(self.nFreeTotalAwardGold)
        if self.userData.bBouns == false and self.userData.bScatter == false then
            self:setUserGold(self.userGold)
        end
		self:freeFinishCallback(function() self:checkEnter2Game(data) end)
	end
	if self.curBetData.lWinScore >= self.bigwinConfig[1] then
		self:createBigwin(callback,self.curBetData.lWinScore)
	else
		callback()
	end
end
--删除超级旋转动画
function GameViewLayer:hideSuperAction()
	for k,v in pairs(self.spineSpeed) do
        if self:isLuaNodeValid(v) then
            v:removeFromParent()
        end
    end
    self.spineSpeed = {}
end
--超级旋转回调（播放速度动画）
function GameViewLayer:superRunActionCallback(idx)
    ccexp.AudioEngine:play2d(logic.sound.prewin, false)
	local panel_wh = self.mm_Panel_icon:getContentSize()
    local randimgPosX = panel_wh.width/cmd.MAX_LS --列数
	if not self:isLuaNodeValid(self.spineSpeed[idx]) then
        local _pos = cc.p((idx-1)*randimgPosX+randimgPosX/2, panel_wh.height/2+10)
	    self.spineSpeed[idx] = self:playSpine(self.mm_Panel_icon,logic.iconAnimName["bigEffect"][1],logic.iconAnimName["bigEffect"][2],_pos)
	end
end

--完成免费转动后回调
function GameViewLayer:freeFinishCallback(callback)
	if self.lastGameModes == logic.SCENE_TYPE.free and self.curBetData.frees_count == 0 then
		performWithDelay(self,function() 
			self:setImgFreeStatus(false)
			if self.nFreeTotalAwardGold > self.bigwinConfig[1] then
				local func = function()
					self:setAllWinGold(self.nFreeTotalAwardGold) 
					if callback then callback() end
				end
				self:createBigwin(func,self.nFreeTotalAwardGold)
			else
				if callback then callback() end
			end
		end,1)
	else
		if callback then callback() end
	end
end

function GameViewLayer:onUserDataResult(data)
    self.userData = data
    local _tempGold = self.userGold - self.betScore * self.betArray[self.curBetIndex]
    self:setUserGold(_tempGold)
    self.userGold = data.userScore
end

--左侧展示中线数量测试用
function GameViewLayer:initTestLine()
	local testBg = display.newNode()
	testBg:setPosition(display.width/2, display.height/2+50)
	testBg:addTo(self,50)
	self.testLbs = {}
	for i=1,50 do
		local testText1 = ccui.Text:create(tostring(i).." = ","fonts/round_body.ttf",32)
        if i <= 25 then
    	    testText1:setPosition(-840, 410-(i-1)*40)
        else
    	    testText1:setPosition(-940, 410-(i-26)*40)
        end
	    testText1:addTo(testBg)
	    testText1:enableOutline(cc.c4b(255,255,86,255), 2)
	    local testText2 = ccui.Text:create("0","fonts/round_body.ttf",32)
        if i <= 25 then
    	    testText2:setPosition(-800, 410-(i-1)*40)
        else
    	    testText2:setPosition(-900, 410-(i-26)*40)
        end
	    testText2:addTo(testBg)
	    testText2:enableOutline(cc.c4b(255,255,86,255), 2)
	    table.insert(self.testLbs, testText2)
	end
end

--更新左侧展示中线数量测试用
function GameViewLayer:updateTestLine(cmdData)
	for i=1,#cmdData.zJLineArray do
	    if self.testLbs[i] then
	    	self.testLbs[i]:setString(cmdData.zJLineArray[i])
            if cmdData.zJLineArray[i] > 0 then
                self.testLbs[i]:setTextColor(cc.c3b(30,255,160))
                self.testLbs[i]:enableOutline(cc.c4b(30,255,160,255), 2)
            else
                self.testLbs[i]:setTextColor(cc.c3b(255,255,255))
                self.testLbs[i]:enableOutline(cc.c4b(255,255,86,255), 2)
            end
	    end
	end
end

return GameViewLayer