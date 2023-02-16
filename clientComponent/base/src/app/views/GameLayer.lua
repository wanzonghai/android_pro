local GameLayer =
    class(
    "GameLayer",
    function(args)
        local GameLayer = display.newLayer()
        return GameLayer
    end
)

EnumTable = {
    start_button = 1,
    next_button = 2,
    bet_1 = 3,
    bet_2 = 4,
    bet_3 = 5,
    bet_all = 6,
    giveUp_button = 7
}

local poker = {1, 2, 11, 12, 13, 14, 15, 24, 25, 26, 27, 28, 37, 38, 39, 40, 41, 50, 51, 52}
local StringKey_Self = "StringKey_Self"
local StringKey_Top = "StringKey_Top"
local res = "base/res/res/"
local isStart = false

local betSum = 500
local topBetSum = 500
local betTable = {500, 1000, 5000, 10000}

local TOPGOLD = "5000000"
local SELFGOLD = "5000000"

function GameLayer:ctor(scene)
    self._scene = scene
    local csbNode = cc.CSLoader:createNode("GameLayer.csb")
    csbNode:setAnchorPoint(cc.p(0.5, 0.5))
    csbNode:setPosition(display.cx, display.cy)
    self._scene:addChild(csbNode)

    

    --self.spriteFrameCacheItem = cc.SpriteFrameCache:getInstance():addSpriteFrames(res .. "poker/card.plist", res .. "poker/card.png")

    self.goldImg = csbNode:getChildByName("gold_img1")
    self.goldImg:setVisible(false)

    self.avatar1 = csbNode:getChildByName("avatar1")
    self.avatar2 = csbNode:getChildByName("avatar2")

    self.selfPokerNode = csbNode:getChildByName("selfPokerNode")
    self.topPokerNode = csbNode:getChildByName("topPokerNode")
    self.resultPanel = csbNode:getChildByName("Result_Panel")
    self.resultPanel:setVisible(false)

    self.resultText = self.resultPanel:getChildByName("resultText")

    self.bet1Text = csbNode:getChildByName("BetText1")
    self.bet2Text = csbNode:getChildByName("BetText2")
    self.bet1Text:setVisible(false)
    self.bet2Text:setVisible(false)

    self.start = csbNode:getChildByName("startBtn")
    self.start:setTag(EnumTable.start_button)
    self.start:addClickEventListener(handler(self, self.onClick))
    self.start:setVisible(false)

    self.next = self.resultPanel:getChildByName("nextBtn")
    self.next:setTag(EnumTable.next_button)
    self.next:addClickEventListener(handler(self, self.onClick))

    self.bet1 = csbNode:getChildByName("betBtn1")
    self.bet1:setTag(EnumTable.bet_1)
    self.bet1:addClickEventListener(handler(self, self.onClick))

    self.bet2 = csbNode:getChildByName("betBtn2")
    self.bet2:setTag(EnumTable.bet_2)
    self.bet2:addClickEventListener(handler(self, self.onClick))

    self.bet3 = csbNode:getChildByName("betBtn3")
    self.bet3:setTag(EnumTable.bet_3)
    self.bet3:addClickEventListener(handler(self, self.onClick))

    self.betAll = csbNode:getChildByName("betBtnAll")
    self.betAll:setTag(EnumTable.bet_all)
    self.betAll:addClickEventListener(handler(self, self.onClick))

    self.giveUpBtn = csbNode:getChildByName("giveUpBtn")
    self.giveUpBtn:setTag(EnumTable.giveUp_button)
    self.giveUpBtn:addClickEventListener(handler(self, self.onClick))

    self.selfGold = csbNode:getChildByName("gold1")
    self.topGold = csbNode:getChildByName("gold2")

    local DataSelf = cc.UserDefault:getInstance():getStringForKey(StringKey_Self)
    if DataSelf ~= "" then
        cc.UserDefault:getInstance():setStringForKey(StringKey_Self, DataSelf)
        self.selfGold:setString(DataSelf)
    else
        cc.UserDefault:getInstance():setStringForKey(StringKey_Self, SELFGOLD)
        self.selfGold:setString(SELFGOLD)
    end

    local DataTop = cc.UserDefault:getInstance():getStringForKey(StringKey_Top)
    if DataTop ~= "" then
        cc.UserDefault:getInstance():setStringForKey(StringKey_Top, DataTop)
        self.topGold:setString(DataTop)
    else
        cc.UserDefault:getInstance():setStringForKey(StringKey_Top, TOPGOLD)
        self.topGold:setString(TOPGOLD)
    end
    self:initCard()
end

-- 3张相同大小
function GameLayer:isSameSize(param)
    if param[1].point == param[2].point and param[2].point == param[3].point then
        return true
    end

    return false
end

-- 3张相同花色
function GameLayer:isSameColor(param)
    if param[1].color == param[2].color and param[2].color == param[3].color then
        return true
    end

    return false
end

-- 顺子
function GameLayer:isShunZi(param)
    for i = 1, 3 do
        if i + 1 < 3 then
            if param[i + 1].point - param[i].point ~= 1 then
                return false
            end
        end
    end
    return true
end

-- 对子
function GameLayer:isDouble(param)
    if param[1].point == param[2].point or param[2].point == param[3].point then
        return true
    end

    return false
end

-- 点数和
function GameLayer:pointNum(param)
    return param[1].point + param[2].point + param[3].point
end

-- 花色和
function GameLayer:colorNum(param)
    return param[1].color + param[2].color + param[3].color
end

function GameLayer:compareSizeAndColor(selfPoker, otherPoker)
    if self:pointNum(otherPoker) > self:pointNum(selfPoker) then
        -- 对家胜利
        self:gameOver(false)
    elseif self:pointNum(otherPoker) < self:pointNum(selfPoker) then
        -- 自己胜利
        self:gameOver(true)
    elseif self:pointNum(otherPoker) == self:pointNum(selfPoker) then
        -- 比较花色
        if self:colorNum(otherPoker) > self:colorNum(selfPoker) then
            -- 对家胜利
            self:gameOver(false)
        else
            -- 自己胜利
            self:gameOver(true)
        end
    end
end

function GameLayer:compare3SameSize(selfPoker, otherPoker)
    if self:isSameSize(selfPoker) and not self:isSameSize(otherPoker) then
        -- 自己胜利
        self:gameOver(true)
    elseif self:isSameSize(otherPoker) and not self:isSameSize(selfPoker) then
        -- 对家胜利
        self:gameOver(false)
    elseif self:isSameSize(otherPoker) and self:isSameSize(selfPoker) then
        self:compareSizeAndColor(selfPoker, otherPoker)
    elseif not self:isSameSize(otherPoker) and not self:isSameSize(selfPoker) then
        -- 比较是否是3张相同花色
        self:compare3SameColor(selfPoker, otherPoker)
    end
end

function GameLayer:compare3SameColor(selfPoker, otherPoker)
    if self:isSameColor(selfPoker) and not self:isSameColor(otherPoker) then
        -- 自己胜利
        self:gameOver(true)
    elseif self:isSameColor(otherPoker) and not self:isSameSize(selfPoker) then
        -- 对家胜利
        self:gameOver(false)
    elseif self:isSameColor(otherPoker) and self:isSameColor(selfPoker) then
        self:compareSizeAndColor(selfPoker, otherPoker)
    elseif not self:isSameColor(otherPoker) and not self:isSameColor(selfPoker) then
        -- 比较是否顺子
        self:compareShunZi(selfPoker, otherPoker)
    end
end

function GameLayer:compareShunZi(selfPoker, otherPoker)
    if self:isShunZi(selfPoker) and not self:isShunZi(otherPoker) then
        -- 自己胜利
        self:gameOver(true)
    elseif self:isShunZi(otherPoker) and not self:isShunZi(selfPoker) then
        -- 对家胜利
        self:gameOver(false)
    elseif self:isShunZi(otherPoker) and self:isShunZi(selfPoker) then
        self:compareSizeAndColor(selfPoker, otherPoker)
    elseif not self:isShunZi(otherPoker) and not self:isShunZi(selfPoker) then
        -- 比较是否有对子
        self:compareDuiZi(selfPoker, otherPoker)
    end
end

function GameLayer:compareDuiZi(selfPoker, otherPoker)
    if self:isDouble(selfPoker) and not self:isDouble(otherPoker) then
        -- 自己胜利
        self:gameOver(true)
    elseif self:isDouble(otherPoker) and not self:isDouble(selfPoker) then
        -- 对家胜利
        self:gameOver(false)
    elseif self:isDouble(otherPoker) and self:isDouble(selfPoker) then
        self:compareSizeAndColor(selfPoker, otherPoker)
    elseif not self:isDouble(otherPoker) and not self:isDouble(selfPoker) then
        self:compareSizeAndColor(selfPoker, otherPoker)
    end
end

function GameLayer:gameOver(isSelf)
    for i = 1, 3 do
        local index = self.topPokerArr[i].index
        local pokerNode = self.topPokerNode:getChildByName("card_" .. i)
        pokerNode:loadTexture("res/poker/card_"..index..".png")
        pokerNode:setVisible(true)
    end

    if isSelf then
        -- 自己胜利
        --print("胜利")
        self.selfGold:setString(tonumber(self.selfGold:getString()) + topBetSum)
        self.topGold:setString(tonumber(self.topGold:getString()) - topBetSum)

        local posx, posy = self.avatar2:getPosition()
        local tagPosx, tagPosy = self.avatar1:getPosition()
        
        self.goldImg:setPosition(posx, posy)
        local moveto = cc.EaseCubicActionOut:create(cc.MoveTo:create(0.6, cc.p(tagPosx, tagPosy)))
        local seq =
            cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(
                function()
                    self.goldImg:setVisible(true)
                end
            ),
            moveto,
            cc.CallFunc:create(
                function()
                    self.goldImg:setVisible(false)
                end
            )
        )

        self.goldImg:runAction(seq)
        self:showResultPanel(true)
    else
        -- 对家胜利
        --print("失败")
        self.selfGold:setString(tonumber(self.selfGold:getString()) - betSum)
        self.topGold:setString(tonumber(self.topGold:getString()) + betSum)
        local posx, posy = self.avatar1:getPosition()
        local tagPosx, tagPosy = self.avatar2:getPosition()
        
        self.goldImg:setPosition(posx, posy)
        local moveto = cc.EaseCubicActionOut:create(cc.MoveTo:create(0.7, cc.p(tagPosx, tagPosy)))
        local seq =
            cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(
                function()
                    self.goldImg:setVisible(true)
                end
            ),
            moveto,
            cc.CallFunc:create(
                function()
                    self.goldImg:setVisible(false)
                end
            )
        )

        self.goldImg:runAction(seq)
        self:showResultPanel(false)
    end
    cc.UserDefault:getInstance():setStringForKey(StringKey_Self, self.selfGold:getString())
    cc.UserDefault:getInstance():setStringForKey(StringKey_Top, self.topGold:getString())
end

function GameLayer:showResultPanel(isWin)
    performWithDelay(
        self,
        function()
            if isWin then
                self.resultPanel:setVisible(true)
                self.resultText:setString("YOU WIN")
            else
                self.resultPanel:setVisible(true)
                self.resultText:setString("YOU LOSE")
            end
        end,
        1.4
    )
end

function GameLayer:onClick(_sender)
    local tag = _sender:getTag()

    isStart = true

    if tag == EnumTable.start_button then
        --比较大小
        self.start:setVisible(false)
        self:compare3SameSize(self.selfPokerArr, self.topPokerArr)
    elseif tag == EnumTable.next_button then
        self.resultPanel:setVisible(false)
        self.bet1Text:setVisible(false)
        self.bet2Text:setVisible(false)
        self.bet1:setVisible(true)
        self.bet2:setVisible(true)
        self.bet3:setVisible(true)
        self.betAll:setVisible(true)
        self.giveUpBtn:setVisible(true)
        self.start:setVisible(false)
        self:initCard()
    elseif tag == EnumTable.bet_1 then
        self:onBet(1)
    elseif tag == EnumTable.bet_2 then
        self:onBet(2)
    elseif tag == EnumTable.bet_3 then
        self:onBet(3)
    elseif tag == EnumTable.bet_all then
        self:onBet(4)
    elseif tag == EnumTable.giveUp_button then
        betSum = 1000
        self:gameOver(false)
    end
end

function GameLayer:onBet(bet)
    self.bet1Text:setVisible(true)
    if bet ~= 4 then
        self.bet1Text:setString("Bet " .. betTable[bet])
        betSum = betTable[bet]
    else
        self.bet1Text:setString("Bet All")
        betSum = betTable[bet]
    end

    self.bet1:setVisible(false)
    self.bet2:setVisible(false)
    self.bet3:setVisible(false)
    self.betAll:setVisible(false)
    self.giveUpBtn:setVisible(false)
    performWithDelay(
        self,
        function()
            self.bet2Text:setVisible(true)
            local t = self:readRandomValueInTable(betTable)
            self.bet2Text:setString("Bet " .. t)
            self.start:setVisible(true)
            topBetSum = t
        end,
        1
    )
end

function GameLayer:readRandomValueInTable(Table)
    math.randomseed(os.time())
    return Table[math.random(1, #Table)]
end

function GameLayer:initCard()
    isStart = false
    self.selfPokerArr = {}
    self.topPokerArr = {}

    --初始化
    local newData = {}
    for i = 1, 52 do
        local data = {}
        data.index = i
        data.point = (i - 1) % 13 + 1
        data.color = math.ceil(i / 13)
        table.insert(newData, data)
    end

    -- 洗牌
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
    local rePoker = self:shuffle(newData)
    -- for i, v in ipairs(rePoker) do
    --     print(v.point,v.color)
    -- end

    -- 发牌
    for i = 1, 3 do
        table.insert(self.selfPokerArr, rePoker[i])
    end

    for i = 4, 6 do
        table.insert(self.topPokerArr, rePoker[i])
    end

    -- 排序
    self:tableSort(self.selfPokerArr)
    self:tableSort(self.topPokerArr)

    -- 显示自己牌
    for i = 1, 3 do
        local index = self.selfPokerArr[i].index
        local pokerNode = self.selfPokerNode:getChildByName("card_" .. i)
        pokerNode:loadTexture("res/poker/card_"..index..".png")
        pokerNode:setVisible(true)
    end

    for i = 1, 3 do
        local index = self.topPokerArr[i].index
        local pokerNode = self.topPokerNode:getChildByName("card_" .. i)
        pokerNode:loadTexture("res/poker/card_53.png")
        pokerNode:setVisible(true)
    end

    -- print(unpack(self.selfPokerArr))
    -- print(unpack(self.topPokerArr))
end

function GameLayer:tableSort(arr)
    table.sort(
        arr,
        function(a, b)
            if a.point == b.point then
                return a.color < b.color
            else
                return a.point < b.point
            end
        end
    )
end

function GameLayer:shuffle(t)
    for i = #t, 1, -1 do
        local j = math.random(1, i)
        local tmp = t[i]
        t[i] = t[j]
        t[j] = tmp
    end
    return t
end

return GameLayer
