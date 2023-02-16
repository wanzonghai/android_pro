local GameLogic = {}
local cmd = appdf.req("game.yule.baccarat.src.models.CMD_Game")

--牌值掩码
GameLogic.MASK_VALUE			= 0X0F
--花色掩码
GameLogic.MASK_COLOR			= 0XF0
--最大手牌数目
GameLogic.MAX_CARDCOUNT			= 20
--牌库数目
GameLogic.FULL_COUNT			= 54
--正常手牌数目
GameLogic.NORMAL_COUNT			= 17


 --1. 1-8  --> 2-9    2-9点
 --2. 9-12 --> 10--K  0点
 --3.   13 --> A      1点
function GameLogic:pokerValue(card)
    local point = card % 16
    if point == 0 or point >= 10 then
        return 0
    else
        return point
    end
end
--获取数值
function GameLogic:GetCardValue( cbCardData )
	return bit:_and(cbCardData, GameLogic.MASK_VALUE);
end
function GameLogic:getCardChar(cardValue)
    cardValue = cardValue or 0
    local point = cardValue % 16
    local huase, n1, n2

    if cardValue >= 1 and cardValue <= 13 then
        huase = 0
        n2 = 0
    elseif cardValue >= 17 and cardValue <= 29 then
        huase = 1
        n2 = 1
    elseif cardValue >= 33 and cardValue <= 45 then
        huase = 2
        n2 = 0
    elseif cardValue >= 49 and cardValue <= 61 then
        huase = 3
        n2 = 1
    end
    n1 = point
    return huase, n1, n2
end

function GameLogic:getWinArea(cmd_data)
	local userCard = { {}, {} }		--手牌数值
	local typeList = { 0, 0 }		--牌型点数
    local cbCardCount = cmd_data.cbCardCount[1]
    for k=1,2 do
        for i=1,cbCardCount[k] do
            table.insert(userCard[k], cmd_data.cbTableCardArray[k][i])
        end
    end
	for i = 1, 2 do
		for _, v in ipairs(userCard[i]) do
			typeList[i] = (self:pokerValue(v) + typeList[i]) % 10
		end
	end    
    local idlePoint = typeList[1]
    local masterPoint = typeList[2]
    local cbBetAreaBlink = {0,0,0,0,0,0,0,0}
    if idlePoint > masterPoint then	
        cbBetAreaBlink[cmd.AREA_XIAN + 1] = 1
		--闲天王
		if 8 == idlePoint or 9 == idlePoint then
			cbBetAreaBlink[cmd.AREA_XIAN_TIAN + 1] = 1
		end
    elseif idlePoint < masterPoint then
        cbBetAreaBlink[cmd.AREA_ZHUANG + 1] = 1
		if 8 == masterPoint or 9 == masterPoint then
			cbBetAreaBlink[cmd.AREA_ZHUANG_TIAN + 1] = 1
		end
    elseif idlePoint == masterPoint then
        cbBetAreaBlink[cmd.AREA_PING + 1] = 1
        --判断是否为同点平
        local bAllPointSame = false
        if #userCard[1] == #userCard[2] then
            local cbCardIdx = 1
			for i = cbCardIdx, #userCard[1] do
				local cbBankerValue = GameLogic:GetCardValue(userCard[1][cbCardIdx])
				local cbIdleValue = GameLogic:GetCardValue(userCard[2][cbCardIdx])
				if cbBankerValue ~= cbIdleValue then
					break
				end
				if cbCardIdx == #userCard[1] then
					bAllPointSame = true
				end
                cbCardIdx = cbCardIdx + 1
			end
        end
		--同点平
		if true == bAllPointSame then
			cbBetAreaBlink[cmd.AREA_TONG_DUI + 1] = 1
		end
    end
	--对子判断
	local nowBIdleTwoPair = false
	local nowBMasterTwoPair = false
    --闲对子
	if GameLogic:GetCardValue(userCard[1][1]) == GameLogic:GetCardValue(userCard[1][2]) then
		nowBIdleTwoPair = true
		cbBetAreaBlink[cmd.AREA_XIAN_DUI + 1] = 1
	end
    --庄对子
	if GameLogic:GetCardValue(userCard[2][1]) == GameLogic:GetCardValue(userCard[2][2]) then
		nowBIdleTwoPair = true
		cbBetAreaBlink[cmd.AREA_ZHUANG_DUI + 1] = 1
	end
    return cbBetAreaBlink
end

return GameLogic