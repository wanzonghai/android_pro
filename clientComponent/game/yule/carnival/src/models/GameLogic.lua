local GameLogic = GameLogic or {}

--数目定义
GameLogic.TOTAL_LINE 				= 50			--线的数量
GameLogic.ITEM_COUNT                = 13            --图标数量
GameLogic.ITEM_X_COUNT				= 5				--图标横坐标数量
GameLogic.ITEM_Y_COUNT				= 4				--图标纵坐标数量
GameLogic.SCATTER_REWARD			= 8				--赢取免费次数最低需要的scatter数量
GameLogic.ITEM_WIDTH				= 260			--一个格子的宽度
GameLogic.ITEM_HEIGHT				= 160			--一个格子的高度
GameLogic.TOTAL_WIGHT				= 1300			--一列格子的总宽度
GameLogic.TOTAL_HEIGHT				= 640			--一列格子的总高度
--移动的定义
GameLogic.ITEM_MOVE_SPEED           = 2000          --移动时的速度，*定时器的dt得到最终时间
GameLogic.MOVE_TIME_FAST            = 1.25          --快速旋转时间，第一列
GameLogic.TIME_FAST_ADD             = 0             --快速旋转每一列增加的时间
GameLogic.MOVE_TIME_NORMAL          = 2.5           --普通旋转时间，第一列
GameLogic.TIME_NORMAL_ADD           = 0.4           --普通旋转每一列增加的时间
GameLogic.TIME_ADD_BONUS            = 1.5             --触发bonus之后每一列增加的旋转时间,快速模式减半


--物品元素列表
GameLogic.ITEM_LIST = {
	ITEM_ICON0	    = 0,	--9
	ITEM_ICON1	    = 1,	--10
	ITEM_ICON2	    = 2,	--j
	ITEM_ICON3	    = 3,	--q
	ITEM_ICON4	    = 4,	--k
	ITEM_ICON5	    = 5,	--a
	ITEM_ICON6	    = 6,	--蓝色人头	
	ITEM_ICON7	    = 7,	--绿色人头
	ITEM_ICON8	    = 8,	--红色人头
	ITEM_ICON9	    = 9,	--黄色人头
	ITEM_FREE	    = 10,	--bonus,免费中奖图标
    ITEM_WILD       = 11,   --wild 百搭
    ITEM_MYSTERY    = 12,   --面具
	ITEM_TOTAL	    = 13,	--总数量
}

--动画节点
GameLogic.ITEM_ANI_FILE =
{
    "", "", "", "", "", "",
    "jnh_dancer_blue_ske",
    "jnh_dancer_green_ske",
    "jnh_dancer_pink_ske",
    "jnh_dancer_gold_ske",
    "jnh_bonus_spine",
    "jnh_wild_ske",
    "jnh_symbol_change_ske",
}

--动画名称
GameLogic.ITEM_ANI_NAME =
{
    "", "", "", "", "", "",
    "win",
    "win",
    "win",
    "win",
    "win",
    "animation",
    "change",
}

--线的配置，从0开始
--面板上的排列 从上到下，从左到右
GameLogic.gameLineDef =
{
    {{1, 0}, {1, 1}, {1, 2}, {1, 3}, {1, 4}},       --1线
    {{0, 0}, {0, 1}, {0, 2}, {0, 3}, {0, 4}},       --2线
    {{2, 0}, {2, 1}, {2, 2}, {2, 3}, {2, 4}},       --3线
    {{3, 0}, {3, 1}, {3, 2}, {3, 3}, {3, 4}},       --4线
    {{0, 0}, {1, 1}, {2, 2}, {1, 3}, {0, 4}},       --5线
    {{1, 0}, {2, 1}, {3, 2}, {2, 3}, {1, 4}},       --6线
    {{2, 0}, {1, 1}, {0, 2}, {1, 3}, {2, 4}},       --7线
    {{3, 0}, {2, 1}, {1, 2}, {2, 3}, {3, 4}},       --8线
    {{1, 0}, {0, 1}, {0, 2}, {0, 3}, {1, 4}},       --9线
    {{2, 0}, {3, 1}, {3, 2}, {3, 3}, {2, 4}},       --10线
    {{2, 0}, {1, 1}, {1, 2}, {1, 3}, {2, 4}},       --11线
    {{1, 0}, {2, 1}, {2, 2}, {2, 3}, {1, 4}},       --12线
    {{3, 0}, {2, 1}, {2, 2}, {2, 3}, {3, 4}},       --13线
    {{0, 0}, {1, 1}, {1, 2}, {1, 3}, {0, 4}},       --14线
    {{0, 0}, {0, 1}, {1, 2}, {2, 3}, {2, 4}},       --15线
    {{3, 0}, {3, 1}, {2, 2}, {1, 3}, {1, 4}},       --16线
    {{1, 0}, {1, 1}, {2, 2}, {3, 3}, {3, 4}},       --17线
    {{2, 0}, {2, 1}, {1, 2}, {0, 3}, {0, 4}},       --18线
    {{1, 0}, {2, 1}, {1, 2}, {0, 3}, {1, 4}},       --19线
    {{2, 0}, {1, 1}, {2, 2}, {3, 3}, {2, 4}},       --20线
    {{2, 0}, {3, 1}, {2, 2}, {1, 3}, {2, 4}},       --21线
    {{1, 0}, {0, 1}, {1, 2}, {2, 3}, {1, 4}},       --22线
    {{0, 0}, {1, 1}, {0, 2}, {1, 3}, {0, 4}},       --23线
    {{3, 0}, {2, 1}, {3, 2}, {2, 3}, {3, 4}},       --24线
    {{1, 0}, {2, 1}, {1, 2}, {2, 3}, {1, 4}},       --25线
    {{2, 0}, {1, 1}, {2, 2}, {1, 3}, {2, 4}},       --26线
    {{2, 0}, {3, 1}, {2, 2}, {3, 3}, {2, 4}},       --27线
    {{1, 0}, {0, 1}, {1, 2}, {0, 3}, {1, 4}},       --28线
    {{1, 0}, {1, 1}, {0, 2}, {1, 3}, {1, 4}},       --29线
    {{2, 0}, {2, 1}, {3, 2}, {2, 3}, {2, 4}},       --30线
    {{2, 0}, {2, 1}, {1, 2}, {2, 3}, {2, 4}},       --31线
    {{1, 0}, {1, 1}, {2, 2}, {1, 3}, {1, 4}},       --32线
    {{3, 0}, {3, 1}, {2, 2}, {3, 3}, {3, 4}},       --33线
    {{0, 0}, {0, 1}, {1, 2}, {0, 3}, {0, 4}},       --34线
    {{0, 0}, {0, 1}, {2, 2}, {0, 3}, {0, 4}},       --35线
    {{3, 0}, {3, 1}, {1, 2}, {3, 3}, {3, 4}},       --36线
    {{1, 0}, {1, 1}, {3, 2}, {1, 3}, {1, 4}},       --37线
    {{2, 0}, {2, 1}, {0, 2}, {2, 3}, {2, 4}},       --38线
    {{0, 0}, {2, 1}, {2, 2}, {2, 3}, {0, 4}},       --39线
    {{3, 0}, {1, 1}, {1, 2}, {1, 3}, {3, 4}},       --40线
    {{1, 0}, {3, 1}, {3, 2}, {3, 3}, {1, 4}},       --41线
    {{2, 0}, {0, 1}, {0, 2}, {0, 3}, {2, 4}},       --42线
    {{1, 0}, {2, 1}, {0, 2}, {2, 3}, {1, 4}},       --43线
    {{2, 0}, {1, 1}, {3, 2}, {1, 3}, {2, 4}},       --44线
    {{2, 0}, {3, 1}, {1, 2}, {3, 3}, {2, 4}},       --45线
    {{1, 0}, {0, 1}, {2, 2}, {0, 3}, {1, 4}},       --46线
    {{0, 0}, {2, 1}, {0, 2}, {2, 3}, {0, 4}},       --47线
    {{3, 0}, {1, 1}, {3, 2}, {1, 3}, {3, 4}},       --48线
    {{1, 0}, {3, 1}, {1, 2}, {3, 3}, {1, 4}},       --49线
    {{2, 0}, {0, 1}, {2, 2}, {0, 3}, {2, 4}},       --50线
}

--弹大奖的取值范围倍数
GameLogic.Reward_Scope =
{
    small = 100,
    middle = 200,
    big = 500,
}

GameLogic.gameState =
{
	state_wait = 1, --等待开始转动/动画播完了
	state_playAni = 2, --转动结束，但是wild动画和中奖动画还没播完,中奖动画播了一轮算播完
	-- state_over = 3, --动画播完了，可以开始下一轮了
}

GameLogic.curMode = GameLogic.gameState.state_wait
function GameLogic:setGameMode(state)
    tlog("GameLogic:setGameMode ", state)
    GameLogic.curMode = state
end

--获取游戏状态
function GameLogic:getGameMode()
    tlog("GameLogic:getGameMode ", GameLogic.curMode)
    return GameLogic.curMode
end

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
    if nowNums >= _dstNums then
        nowNums = _dstNums
        -- _node:setString(nowNums)
        self:formatNumShow(_node, nowNums)
        return
    end
    -- _node:setString(nowNums)
    self:formatNumShow(_node, nowNums)
    _node:runAction(cc.Sequence:create(cc.DelayTime:create(0.03), cc.CallFunc:create(function (t, p)
        self:addGoldNumsShowInterval(p.node, p.srcNums, p.dstNums, p.addNums)
    end, {node = _node, srcNums = nowNums, dstNums = _dstNums, addNums = _addNums})))
end

function GameLogic:formatNumShow(_node, _nums)
	local serverKind = G_GameFrame:getServerKind()
	local formatMoney = g_format:formatNumber(_nums,g_format.fType.standard,serverKind)
	tlog('formatMoney is ', formatMoney)
	_node:setString(formatMoney)
end

--获取一个格子应该被设置的位置
function GameLogic:getItemPosition(_index_x, _index_y)
    local posX = GameLogic.ITEM_WIDTH * (_index_x - 0.5)
    local posY = GameLogic.ITEM_HEIGHT * (_index_y - 0.5)
    return posX, posY
end

function GameLogic:getAnimationName(_type)
    local aniFile = string.format("GUI/jnh_ani_spine/%s", GameLogic.ITEM_ANI_FILE[_type + 1])
    local aniName = GameLogic.ITEM_ANI_NAME[_type + 1]
    return aniFile, aniName
end

function GameLogic:createAnimateShow(_parent, _file, _animateName, _loop, _posx, _posy, _scale)
    _scale = _scale or 1.2
    animateAct = sp.SkeletonAnimation:create(string.format("%s.json", _file), string.format("%s.atlas", _file), 1)
    animateAct:addTo(_parent)
    animateAct:setAnimation(0, _animateName, _loop)
    animateAct:setPosition(_posx, _posy)
    animateAct:setScale(_scale)
    return animateAct
end

return GameLogic