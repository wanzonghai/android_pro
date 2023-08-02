local GameViewLayer =
    class(
    "GameViewLayer",
    function(scene)
        local gameViewLayer = display.newLayer()
        return gameViewLayer
    end
)
GameViewLayer.RES_PATH = device.writablePath .. "game/yule/Plinko/res/"

local module_pre = "game.yule.Plinko.src"
local g_var = g_ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"
local logic = appdf.req(module_pre .. ".models.GameLogic")
local contentLayer = appdf.req(module_pre .. ".views.layer.ContentLayer")        
local betList = appdf.req(module_pre .. ".views.layer.betListLayer")
local autoBetList = appdf.req(module_pre .. ".views.layer.autoBetListLayer")
local helpLayer = appdf.req(module_pre .. ".views.layer.helpLayer")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")

local racordPath = {
    "record_green.png",
    "record_yellow.png",
    "record_red.png"
}

function GameViewLayer:ctor(scene)
    tlog("GameViewLayer:ctor")
    self._scene = scene
    self:initData()
    --初始化csb界面
    self:initCsbRes()
    --注册node事件
    g_ExternalFun.registerNodeEvent(self)
    self:gameDataInit()
end

function GameViewLayer:gameDataInit()
    tlog("GameViewLayer:gameDataInit")
    --无背景音乐
    --g_ExternalFun.stopMusic()
    g_ExternalFun.playMusic("sound/game_bgm.mp3", true)

end

function GameViewLayer:initData()
    self.m_lCellScore = 1
    self.m_curBetIndex = 1
    self:upMeLocalData(2) --默认14线
    self.m_isAutoBet = false --是否自动投注
    self.m_autoBetCount = 3 --自动投注默认次数
    self.m_recordData = {}       --记录数据集合
    self.m_recordMiniItems = {}  --顶部小的记录条
    self.m_recordMaxItems= {}     --展开的大的记录
    self.m_isShowRecordMax = false  --大的记录页面是否是显示的
    self.m_curShowScore = 0        --当前显示的金币数
end

function GameViewLayer:upMeLocalData(index)
    self.m_curPinsIndex = index
    local line = logic.pinsMap[self.m_curPinsIndex]
    logic.rowsize = line + 2
end

---------------------------------------------------------------------------------------
--界面初始化
function GameViewLayer:initCsbRes()
    local csbNode = cc.CSLoader:createNode("UI/GameLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    csbNode:addTo(self)
    g_ExternalFun.loadChildrenHandler(self, csbNode)
    self:initCanvas()

    --add by tangyuan
    display.loadSpriteFrames('GUI/content.plist', 'GUI/content.png')
end

function GameViewLayer:onExitClick()
    display.removeSpriteFrames('GUI/content.plist', 'GUI/content.png')
    g_ExternalFun.stopMusic()
    self:getParentNode():onUiExitTable()
end

function GameViewLayer:onCreateTableClick(line)
    if self.m_contentLayer then
        return
    end
    -- --初始化桌面
    self.m_contentLayer = contentLayer:create()
    self.mm_Panel_content:addChild(self.m_contentLayer)
    self.m_contentLayer:setPosition(cc.p(0, 0))
    self.m_contentLayer:drawPoint(line)
    self.m_contentLayer:drawColorBlock(line)
end

function GameViewLayer:createHelpLayer()
    local helpLayer = helpLayer:create()
    self.mm_Panel_1:addChild(helpLayer,100)    
end

function GameViewLayer:onSwitchTableClick(target)
    if self.m_contentLayer:getBallCount() then
        return
    end
    local tag = target:getTag()
    self:upMeLocalData(tag)
    local line = logic.pinsMap[self.m_curPinsIndex]
    self.m_contentLayer:clerTable()
    self.m_contentLayer:drawPoint(line)
    self.m_contentLayer:drawColorBlock(line)
    self.mm_Text_pins:setString("Pins:  " .. line)
    for i = 1, 3 do
        if self.m_curPinsIndex == i then
            self["mm_img_pins" .. i]:hide()
        else
            self["mm_img_pins" .. i]:show()
        end
    end
end

function GameViewLayer:onStartGameClick(target)
    if self.m_isAutoBet then return end
    if self:checkAutoStatus() == false then return end
    EventPost:addCommond(EventPost.eventType.SPIN,"slot每次spin",1,nil,{gameId = self._scene:getGameKind(),
        roomId = GlobalUserItem.roomMark,betPrice = logic.betList.value[self.m_curBetIndex]*self.m_lCellScore
    })
    self._scene:sendUserBet(self.m_curBetIndex, target.userData, self.m_curPinsIndex - 1)
end

--画布
function GameViewLayer:initCanvas()
    self.mm_Panel_1:addClickEventListener(handler(self,self.onCloseOtherUIClick))
    self.mm_Image_pinsbg:hide()
    -- self.mm_Image_pinsbg:setPositionY()
    self.mm_btn_pins:onClicked(
        function()
            print("mm_btn_pins")
            self.mm_Image_pinsbg:setVisible(not self.mm_Image_pinsbg:isVisible())
            for i = 1, 3 do
                if (logic.rowsize - 2) == logic.pinsMap[i] then
                    self["mm_img_pins" .. i]:hide()
                else
                    self["mm_img_pins" .. i]:show()
                end
            end
        end
    )
    --切换 switch
    self.mm_btn_pins1:onClicked(handler(self, self.onSwitchTableClick))
    self.mm_btn_pins1:setTag(1)
    self.mm_btn_pins2:onClicked(handler(self, self.onSwitchTableClick))
    self.mm_btn_pins2:setTag(2)
    self.mm_btn_pins3:onClicked(handler(self, self.onSwitchTableClick))
    self.mm_btn_pins3:setTag(3)
    self.mm_Text_pins:setString("Pins:  " .. logic.rowsize - 2)

    --菜单
    self.mm_Image_meunbg:hide()
    self.mm_btn_meun:onClicked(function()
            self.mm_Image_meunbg:setVisible(not self.mm_Image_meunbg:isVisible())
        end)
    self.mm_btn_exp:onClicked(function() self:createHelpLayer() end)
    self.mm_btn_music:onClicked(function() self.mm_btn_music:setBright(not self.mm_btn_music:isBright()) end)
    self.mm_btn_exit:onClicked(handler(self, self.onExitClick))

    self.mm_btn_green:onClicked(handler(self, self.onStartGameClick))
    self.mm_btn_green.userData = logic.betType.GM_GREEN
    self.mm_btn_yellow:onClicked(handler(self, self.onStartGameClick))
    self.mm_btn_yellow.userData = logic.betType.GM_YELLOW
    self.mm_btn_red:onClicked(handler(self, self.onStartGameClick))
    self.mm_btn_red.userData = logic.betType.GM_RED


    local size = self.mm_Panel_user_left:getContentSize()
    self.m_leftcsbNode = g_ExternalFun.loadCSB("UI/scoreAction.csb", self.mm_Panel_user_left)
    g_ExternalFun.loadChildrenHandler(self.m_leftcsbNode, self.m_leftcsbNode)
    self.m_leftcsbNode:setPosition(cc.p(size.width/2,size.height/2))
    self.m_leftcsbNode:hide()
    local size = self.mm_Panel_user_right:getContentSize()
    self.m_rightcsbNode = g_ExternalFun.loadCSB("UI/scoreAction.csb", self.mm_Panel_user_right)
    g_ExternalFun.loadChildrenHandler(self.m_rightcsbNode, self.m_rightcsbNode)
    self.m_rightcsbNode:setPosition(cc.p(size.width/2,size.height/2))
    self.m_rightcsbNode:hide()

    --加减投注
    self.mm_btn_bet_cut.userData = "-"
    self.mm_btn_bet_cut:onClicked(handler(self, self.onChangeBetClick))
    self.mm_btn_bet_add.userData = "+"
    self.mm_btn_bet_add:onClicked(handler(self, self.onChangeBetClick))
    --打开投注列表
    self.mm_btn_bet_batch:onClicked(handler(self, self.onBetBatchClick))

    --自动投注
    self.mm_btn_betAuto:onClicked(handler(self, self.onAutoBetListClick))
    self.mm_btn_betAuto_count:onClicked(handler(self, self.onStopAutoBetClick))
    self.mm_btn_betAuto_count:hide()


    self.mm_btn_record:onClicked(
        function()
            local isshow = self.mm_Image_record_down:isVisible()
            self.mm_Image_record_down:setVisible(not isshow)
            self.mm_Panel_recordList:setVisible(isshow)
            if isshow == false then
                self.mm_record_list:removeAllChildren()
                self.m_recordMaxItems = {}
            else
                self.m_isShowRecordMax  = true
                self:upRecordList()
            end
        end
    )
    self.mm_Image_win:hide()
    self.mm_Image_lose:hide()
    -- self.m_curShowScore = GlobalUserItem.lUserScore
    self:setUserGold()
end

function GameViewLayer:onCloseOtherUIClick()
    if self.m_betList then
        self.m_betList:removeSelf()
        self.m_betList = nil
    end
    if self.m_autoBetList then
        self.m_autoBetList:removeSelf()
        self.m_autoBetList = nil
        package.loaded[module_pre .. ".views.layer.autoBetListLayer"] = nil
    end
    self.mm_Image_meunbg:setVisible(false)
    self.mm_Image_pinsbg:setVisible(false)
    --路单
    self.mm_Image_record_down:setVisible(true)
    self.mm_Panel_recordList:setVisible(false)
    self.mm_record_list:removeAllChildren()
    self.m_recordMaxItems = {}
end

function GameViewLayer:setUserGold()
    local serverKind = G_GameFrame:getServerKind()
    local str = g_format:formatNumber(tonumber(self.m_curShowScore),g_format.fType.standard,serverKind)
    self.mm_Text_gold:setString( str )
end

function GameViewLayer:onBetBatchClick()
    if self.m_isAutoBet then return end 
    if not self.m_betList then
        self.m_betList = betList:create(self)
        self.mm_Panel_buttom:addChild(self.m_betList)
        self.m_betList:setPosition(cc.p(0, 140))
        self.m_betList:show()
    else
        self.m_betList:removeSelf()
        self.m_betList = nil
        package.loaded[module_pre .. ".views.layer.betListLayer"] = nil
    end
end

function GameViewLayer:setBet(index)
    self.m_curBetIndex = index
    local bet = logic.betList.value[self.m_curBetIndex]*self.m_lCellScore
    local serverKind = G_GameFrame:getServerKind()
    self.mm_Text_bet:setText(g_format:formatNumber(bet,g_format.fType.abbreviation,serverKind))
    self:checkAutoStatus()
end

function GameViewLayer:onChangeBetClick(target)
    if self.m_isAutoBet then return end
    if target.userData == "-" then
        self.m_curBetIndex = self.m_curBetIndex - 1
        if self.m_curBetIndex < 1 then
            self.m_curBetIndex = 1
        end
    end
    if target.userData == "+" then
        local sum = #logic.betList.value
        self.m_curBetIndex = self.m_curBetIndex + 1
        if self.m_curBetIndex > sum then
            self.m_curBetIndex = sum
        end
    end
    self:setBet(self.m_curBetIndex)
    if self.m_betList then
        self.m_betList:onSelectBtn(self.m_curBetIndex)
    end
end

function GameViewLayer:onAutoBetListClick()
    if not self.m_autoBetList then
        self.m_autoBetList = autoBetList:create(self)
        self.mm_Panel_buttom:addChild(self.m_autoBetList)
        local buttomSize = self.mm_Panel_buttom:getContentSize()
        performWithDelay(self,function()
            local autoBetSize = self.m_autoBetList.m_csbNode:getContentSize()
            self.m_autoBetList:setPosition(cc.p(buttomSize.width/2 - autoBetSize.width/2, buttomSize.height))
            self.m_autoBetList:show()
        end,0)
    else
        self.m_autoBetList:removeSelf()
        self.m_autoBetList = nil
        package.loaded[module_pre .. ".views.layer.autoBetListLayer"] = nil
    end
end

function GameViewLayer:reSetUserInfo()
    local myUser = self._scene:GetMeUserItem()
    if nil ~= myUser then
        self.m_curShowScore = myUser.lScore
        self:updateUserScore()
    end
end

function GameViewLayer:updateUserScore()
    self:setUserGold()
    self:checkAutoStatus()
end
--
function GameViewLayer:checkAutoStatus()
    
    local betGold = logic.betList.value[self.m_curBetIndex]*self.m_lCellScore
    if self.m_curShowScore < betGold then
        --金币不足 置灰
        self:autoBtnstatus(false)
        return false
    else
        if not self.m_isAutoBet then
            self:autoBtnstatus(true)
        end
    end
    return true
end

function GameViewLayer:showWinAndLose(gold,betGold)
    self.mm_Text_wingold:setString("")
    self.mm_Text_losegold:setString("")
    self.mm_Image_lose:stopAllActions()
    self.mm_Image_win:stopAllActions()
    self.mm_Image_lose:hide()
    self.mm_Image_win:hide()
    if tonumber(gold) == 0 then return end
    local serverKind = G_GameFrame:getServerKind()
    if gold > betGold then
        self.mm_Text_wingold:setString("+" .. g_format:formatNumber(gold,g_format.fType.standard,serverKind))
        self.mm_Image_win:show()
        performWithDelay(self.mm_Image_win,function() 
            self.mm_Image_win:hide()
        end,1)
    else
        self.mm_Text_losegold:setString("+"..g_format:formatNumber(gold,g_format.fType.standard,serverKind))
        self.mm_Image_lose:show()
        performWithDelay(self.mm_Image_win,function() 
            self.mm_Image_lose:hide()
        end,1)
    end
end

function GameViewLayer:onStopAutoBetClick()
    self.mm_btn_betAuto_count:hide()
    self.mm_btn_betAuto_count:stopAllActions()
    self.m_isAutoBet = false
    self.m_autoBetCount = 0
    self.mm_Text_betCount:setString(self.m_autoBetCount)
    -- self:autoBtnstatus(not self.m_isAutoBet)
end

function GameViewLayer:startAuto(data)
    if self:checkAutoStatus() == false then
        return
    end
    self:onAutoBetListClick()
    self.m_autoBetCount = logic.autoList.value[data.checkedCount]
    self.autoBallColorLable = data.autoBallColorLable
    self.mm_btn_betAuto_count:show()
    self:autoBet()
    self.m_isAutoBet = true
    self:autoBtnstatus(not self.m_isAutoBet)
    self.m_curTime = 0
    schedule(self.mm_btn_betAuto_count,function() 
        print("auto bet schedule")
        self.m_curTime = self.m_curTime + 1
        if self.m_curTime > 5 then
            self:checkAutoStatus()
            self:onStopAutoBetClick()
        end
    end,1)
    self:onCloseOtherUIClick()
end

function GameViewLayer:autoBet()
    --金币不足。停止自动投注
    if self:checkAutoStatus() == false then
        self:onStopAutoBetClick()
        return
    end
    local index = math.random(1, #self.autoBallColorLable)
    print("autoBetColor:", index)
    self._scene:sendUserBet(self.m_curBetIndex, self.autoBallColorLable[index], self.m_curPinsIndex - 1)

    self.m_autoBetCount = self.m_autoBetCount - 1
    self.mm_Text_betCount:setString(self.m_autoBetCount)  
    if self.m_autoBetCount < 1 then
        self:onStopAutoBetClick()
    end
end
--自动后手动投注按钮的状态
function GameViewLayer:autoBtnstatus(isBright)
    self.mm_btn_green:setBright( isBright )
    self.mm_btn_yellow:setBright( isBright )
    self.mm_btn_red:setBright( isBright )
end


function GameViewLayer:onGameFree(gameData)
    self.m_lCellScore = gameData.lCellScore
    logic.betList.value = gameData.lBetScore
    logic.autoList.value = gameData.nAutoRunCount
    logic.autoDelayTime = gameData.cbAutoDelayTime*0.1
    if logic.autoDelayTime < 0.3 then 
        logic.autoDelayTime = 0.3
    end
    -- --初始化玩家信息 
    self:reSetUserInfo()
    self.m_curBetIndex = gameData.cbBetIndex + 1
    local max_line = 1
    self.m_curBetIndex = 1--self._scene:getBetIndex(logic.betList.value,max_line)
    self:setBet(self.m_curBetIndex)
    --赔率更新
    logic.upOdds(gameData.multiplesTab)
    --生成绘制数据
    logic.getDrawPoint()
    local line = logic.pinsMap[self.m_curPinsIndex]
    self:onCreateTableClick(line)
    self:initLeftUserLayer()
    self:initRightUserLayer()
    self:onStopAutoBetClick()
end

--广播路线
function GameViewLayer:onRouteResult(gameData)
    --透传数据，球掉落结束回调
    local data = {
        color = clone(gameData.cbGameMode), 
        winScore = clone(gameData.win_score)
    }
    local serverKind = G_GameFrame:getServerKind()
    local line = logic.pinsMap[gameData.cbLineType + 1]
    -- dump(gameData, "gameData")
    print(gameData.cbItemIndex + 2)
    local winningIndex = gameData.cbItemIndex + 1
    local lineArray = logic.createPointIndex(line, gameData.routes, gameData.cbItemIndex + 1)
    -- dump(lineArray, "lineArray")
    local movePosArray = logic.getMovePosArray(lineArray, line)
    local scale = logic.drawData[line].scale
    local viewID = self._scene:getPlayerByChairID(gameData.wChairID)
    if viewID == logic.viewID.me then
        --投注扣金币
        self.m_curShowScore = self.m_curShowScore - logic.betList.value[gameData.cbBetIndex+1]*self.m_lCellScore
        if self.m_curShowScore < 0 then self.m_curShowScore = 0 end
        self:setUserGold()

        local updateUserScore = function(data, winData)
            --赢金币
            self.m_curShowScore = self.m_curShowScore + data.winScore
            print("xxxxxx>>>>>",self.m_curShowScore,data.userScore)
            self:updateUserScore()
            self:showWinAndLose(clone(gameData.win_score),logic.betList.value[clone(gameData.cbBetIndex)+1]*self.m_lCellScore)
            self:updateRecord(data.color, winData)
        end
        data.userScore = clone(self.userScore)
        self.m_contentLayer:ballAction(data, winningIndex, movePosArray, scale, true, updateUserScore)
        if self.m_isAutoBet == true then
            performWithDelay(
                self.m_contentLayer,
                function()
                    self:autoBet()
                    self.m_curTime = 0
                end,
                logic.autoDelayTime
            )
        end
    elseif viewID == logic.viewID.left then
        self:upDateLeftTable(line)
        local func = function()
            if gameData.win_score > 0 then
                local nodeAction = g_ExternalFun.loadTimeLine("UI/scoreAction.csb")
                gameData.win_score = string.gsub(gameData.win_score, "[+-]", "")
                self.m_leftcsbNode.mm_BitmapFontLabel_1:setString("+" .. g_format:formatNumber(gameData.win_score,g_format.fType.standard,serverKind))
                self.m_leftcsbNode:runAction(nodeAction)
                self.m_leftcsbNode:show()
                nodeAction:play("animation0", false)
            end
        end
        self.m_leftUserLayer:ballAction(data, winningIndex, movePosArray, scale, false, func)
    elseif viewID == logic.viewID.right then
        self:updateRightTable(line)
        local func = function()
            if gameData.win_score > 0 then
                local nodeAction = g_ExternalFun.loadTimeLine("UI/scoreAction.csb")
                gameData.win_score = string.gsub(gameData.win_score, "[+-]", "")
                self.m_rightcsbNode.mm_BitmapFontLabel_1:setString("+" .. g_format:formatNumber(gameData.win_score,g_format.fType.standard,serverKind))
                self.m_rightcsbNode:show()
                self.m_rightcsbNode:runAction(nodeAction)
                nodeAction:play("animation0", false)
            end
        end
        self.m_rightUserLayer:ballAction(data, winningIndex, movePosArray, scale, false, func)
    end
end

--更新玩家金币  lWinScore   userScore
function GameViewLayer:changeUserScore(userInfo)
    -- dump(userInfo,"changeUserScore")
    local viewID = self._scene:getPlayerByChairID(userInfo.wChairID)
    if viewID == logic.viewID.me then
        self.userScore = userInfo.userScore
        self.lWinScore = userInfo.lWinScore
    elseif viewID == logic.viewID.left then
    elseif viewID == logic.viewID.right then
    end
end

--中奖
function GameViewLayer:updateRecord(color, winData)
    local data = {
        color = color,
        winData = winData
    }
    --保存记录数据
    table.insert(self.m_recordData,1,data) 
    local count = #self.m_recordData
    if count > logic.recordMaxCol * 3 then
        --超过3行数据删除掉
        table.remove(self.m_recordData,count)
    end

    if self.m_isShowRecordMax == true then
        self:upRecordList()
    end

    local img,txt = self:createRocerdItem(data)
    self.mm_record_content:addChild(img)
    self.mm_record_content:addChild(txt,1)
    local imgSize = img:getContentSize()

    --先移动后面的
    for i, v in ipairs(self.m_recordMiniItems) do
        -- local col = math.fmod(i,logic.recordMaxCol)
        local row = math.modf(i / logic.recordMaxCol)
        local pos = cc.p((imgSize.width+5) * (i+1) - (imgSize.width / 2), -(imgSize.height / 2 + imgSize.height * row))
        v[1]:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, pos)))
        v[2]:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, pos)))
    end
    --再展示头部最新的
    img:setScale(0.1)
    img:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, 1)))
    txt:setScale(0.1)
    txt:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, 0.6)))
    table.insert(self.m_recordMiniItems, 1, {img,txt})
    local itemCount = #self.m_recordMiniItems
    if itemCount >= logic.recordMaxCol+1 then
        for i=itemCount,logic.recordMaxCol+1,-1 do
            for j=1,2 do
                self.m_recordMiniItems[i][j]:removeSelf()
                self.m_recordMiniItems[i][j] = nil
            end
            self.m_recordMiniItems[i] = nil
        end
    end
end

--recordList
function GameViewLayer:upRecordList()
    local itemCount = #self.m_recordMaxItems
    for i, v in ipairs(self.m_recordData) do
        local img = nil
        local txt = nil
        if i <= itemCount then
            img = self.m_recordMaxItems[i][1]
            txt = self.m_recordMaxItems[i][2]
            img:setSpriteFrame(racordPath[v.color + 1])
            txt:setString(v.winData)
        else
            img,txt = self:createRocerdItem(v)
            self.mm_record_list:addChild(img)
            self.mm_record_list:addChild(txt,1)
            table.insert(self.m_recordMaxItems,{img,txt})
        end
        local imgSize = img:getContentSize()
        local col = math.fmod(i-1,logic.recordMaxCol)
        local row = math.modf((i-1) / logic.recordMaxCol)

        local pos = cc.p((imgSize.width+5) * (col+1) - (imgSize.width / 2), -(imgSize.height / 2 + (imgSize.height+5) * row))
        img:setPosition(pos)
        txt:setPosition(pos)
    end
end

function GameViewLayer:createRocerdItem(data)
    local img = display.newSprite("#"..racordPath[data.color + 1])
    local imgSize = img:getContentSize()
    img:setPosition(cc.p(imgSize.width / 2, -imgSize.height / 2))
    local Text_1 = ccui.TextBMFont:create()
    Text_1:setFntFile(GameViewLayer.RES_PATH .. "font/jny_auto_shuzi.fnt")
    Text_1:setName("recordText")
    Text_1:setScale(0.6)
    Text_1:setString(data.winData)
    Text_1:setPosition(cc.p(imgSize.width / 2, -imgSize.height / 2))
    return img,Text_1
end

function GameViewLayer:upDateUser(viewID, userInfo)
    local userPanel = nil
    if viewID == logic.viewID.left then
        userPanel = self.mm_Panel_user_left
    elseif viewID == logic.viewID.right then
        userPanel = self.mm_Panel_user_right
    end
    if not userPanel then
        return
    end
    userPanel:show()
    local headimg = userPanel:getChildByName("img_head")
    headimg:show()
    HeadSprite.loadHeadImg(headimg, userInfo.dwGameID, userInfo.wFaceID, true)
    local userName = userPanel:getChildByName("Text_userName")
    local nameStr,isShow = g_ExternalFun.GetFixLenOfString(userInfo.szNickName,160,"arial",33)
    userName:setString(isShow and nameStr or nameStr.."...")
    userPanel:getChildByName("Image_emptyUser"):hide()
end

function GameViewLayer:clearUser(viewID, userInfo)
    local userPanel = nil
    if viewID == logic.viewID.left then
        userPanel = self.mm_Panel_user_left
    elseif viewID == logic.viewID.right then
        userPanel = self.mm_Panel_user_right
    end
    if not userPanel then
        return
    end
    -- userPanel:hide()
    local headimg = userPanel:getChildByName("img_head")
    headimg:hide()
    local userName = userPanel:getChildByName("Text_userName")
    userName:setString("")
    userPanel:getChildByName("Image_emptyUser"):show()
end

function GameViewLayer:initLeftUserLayer()
    if self.m_leftUserLayer then
        return
    end
    -- 左边初始化桌面
    self.m_leftUserLayer = contentLayer:create()
    self.mm_Panel_left_content:addChild(self.m_leftUserLayer)
    self.m_leftUserLayer:setScaleX(0.33)
    self.m_leftUserLayer:setScaleY(0.52)
end

function GameViewLayer:upDateLeftTable(line)
    self.m_leftUserLayer:clerTable()
    self.m_leftUserLayer:drawPoint(line)
end

function GameViewLayer:initRightUserLayer()
    if self.m_rightUserLayer then
        return
    end
    -- 右边初始化桌面
    self.m_rightUserLayer = contentLayer:create()
    self.mm_Panel_right_content:addChild(self.m_rightUserLayer)
    self.m_rightUserLayer:setScaleX(0.33)
    self.m_rightUserLayer:setScaleY(0.53)
end

function GameViewLayer:updateRightTable(line)
    self.m_rightUserLayer:clerTable()
    self.m_rightUserLayer:drawPoint(line)
end

-- ---------------------------------------------------------------------------------------
function GameViewLayer:getParentNode()
    return self._scene
end

function GameViewLayer:getMeUserItem()
    if nil ~= GlobalUserItem.dwUserID then
        return self:getDataMgr():getUidUserList()[GlobalUserItem.dwUserID]
    end
    return nil
end

function GameViewLayer:getDataMgr()
    return self:getParentNode():getDataMgr()
end

return GameViewLayer
