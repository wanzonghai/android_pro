local GameLogic = GameLogic or {}

--数目定义
GameLogic.ITEM_COUNT 				= 11			--图标数量
GameLogic.ITEM_X_COUNT				= 6				--图标横坐标数量
GameLogic.ITEM_Y_COUNT				= 5				--图标纵坐标数量
GameLogic.YAXIANNUM					= 11			--压线数字
GameLogic.SCATTER_REWARD			= 4				--赢取免费次数最低需要的scatter数量
GameLogic.ITEM_WIDTH				= 190			--一个格子的宽度
GameLogic.ITEM_HEIGHT				= 145			--一个格子的高度
GameLogic.TOTAL_HEIGHT				= 725			--一列格子的总高度


--物品元素列表
GameLogic.ITEM_LIST = {
	ITEM_ICON0	= 0,	--
	ITEM_ICON1	= 1,	--
	ITEM_ICON2	= 2,	--
	ITEM_ICON3	= 3,	--
	ITEM_ICON4	= 4,	--
	ITEM_ICON5	= 5,	--
	ITEM_ICON6	= 6,	--	
	ITEM_ICON7	= 7,	--	
	ITEM_ICON8	= 8,	--	
	ITEM_FREE	= 9,	--	特殊元素1
	ITEM_BOMB	= 10,	--	特殊元素2, 下发下来的数据是 (10 * 中奖倍数)
	ITEM_TOTAL	= 11,	--	总数量
}

--物品奖励倍数详情
GameLogic.ITEM_REWARD_RATE_INFO =
{
	{
		200,
		200,
		500,
		500,
		1000,
	},
	{
		50,
		50,
		200,
		200,
		500,
	},
	{
		40,
		40,
		100,
		100,
		300,
	},
	{
		30,
		30,
		40,
		40,
		240,
	},
	{
		20,
		20,
		30,
		30,
		200,
	},
	{
		16,
		16,
		24,
		24,
		160,
	},
	{
		10,
		10,
		20,
		20,
		100,
	},
	{
		8,
		8,
		18,
		18,
		80,
	},
	{
		5,
		5,
		15,
		15,
		40,
	},
	{
		60,
		100,
		2000,
	},
}

--弹大奖的取值范围倍数
GameLogic.Reward_Scope =
{
    small = 100,
    middle = 200,
    big = 500,
}


--拷贝表
function GameLogic:copyTab(st)
    local tab = {}
    for k, v in pairs(st) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
end

function GameLogic:updateGoldShow(_nodeText, _gapNums)
    tlog("GameLogic:updateGoldShow")
    _nodeText:stopAllActions()
    local lastNum = _nodeText._lastNum
    local curNum = _nodeText._curNum
    -- _nodeText:setString(lastNum)
    self:formatNumShow(_nodeText, lastNum)
    local loopNums = 30 -- math.ceil(4.8 / 0.1) --每0.05秒更新一次
    local gapNums = _gapNums and _gapNums or ((curNum - lastNum) / loopNums)
    self:addGoldNumsShowInterval(_nodeText, lastNum, curNum, gapNums)
end

function GameLogic:addGoldNumsShowInterval(_node, _srcNums, _dstNums, _addNums)
    -- tlog('GameLogic:addGoldNumsShowInterval')
    local nowNums = math.ceil(_srcNums + _addNums)
    if nowNums > _dstNums then
        nowNums = _dstNums
        -- _node:setString(nowNums)
        self:formatNumShow(_node, nowNums)
        return
    end
    -- _node:setString(nowNums)
    self:formatNumShow(_node, nowNums)
    _node:runAction(cc.Sequence:create(cc.DelayTime:create(0.03), cc.CallFunc:create(function (_target, _params)
        self:addGoldNumsShowInterval(_params.node, _params.srcNums, _params.dstNums, _params.addNums)
    end, {node = _node, srcNums = nowNums, dstNums = _dstNums, addNums = _addNums})))
end

function GameLogic:formatNumShow(_node, _nums)
	local serverKind = G_GameFrame:getServerKind()
	local formatMoney = g_format:formatNumber(_nums,g_format.fType.standard,serverKind)
	tlog('formatMoney is ', formatMoney)
	_node:setString(formatMoney)
end

return GameLogic