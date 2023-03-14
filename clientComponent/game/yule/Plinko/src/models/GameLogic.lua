local GameLogic = GameLogic or {}

GameLogic.recordMaxCol = 13   --记录展示最大列


--bet Type
GameLogic.betType = {
    GM_GREEN = 0, --绿
    GM_YELLOW = 1, --黄
    GM_RED = 2, --红
    GM_MAX = 3 --
}

GameLogic.line = 14 --几线游戏
GameLogic.rowsize = GameLogic.line + 2 --矩阵层数  也是最底层桩数   line = rowsize - 2
GameLogic.ballSize = 32 --球大小  box
GameLogic.posSize = 22 --桩大小  box
GameLogic.step = GameLogic.ballSize + 8 --间隙 步长  球的宽度 + 两边 4像素
GameLogic.duration = 0.2 --掉落时间
GameLogic.autoDelayTime = 0.3 --自动投注的间隔

--视图ID对应方位
GameLogic.viewID = {
    me = 1,
    right = 2,
    left = 3
}

GameLogic.betList = {
    Horizontal = 330, --横向偏移坐标
    Vertical = -80, --纵向偏移坐标
    value = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.2, 2, 4, 10, 20, 50, 100}, --这个会在场景配置下发
    row = 0,
    btnPos = function()
        local btnPos = {}
        local Yindex = 0
        for i = 1, #GameLogic.betList.value do
            local curPos = cc.p(0, 0)
            curPos.y = Yindex * GameLogic.betList.Vertical
            if i % 2 == 0 then
                curPos.x = GameLogic.betList.Horizontal
                Yindex = Yindex + 1
            else
                curPos.x = 0
            end
            table.insert(btnPos, curPos)
        end
        GameLogic.betList.row = Yindex+1
        return btnPos
    end
}

GameLogic.autoList = {
    Horizontal = 566, --横向偏移坐标
    Vertical = -90, --纵向偏移坐标
    value = {3, 10, 25, 100, 200, 500}, --这个会配置下发
    btnPos = function()
        local btnPos = {}
        local Yindex = 0
        for i = 1, #GameLogic.autoList.value do
            local curPos = cc.p(0, 0)
            curPos.y = Yindex * GameLogic.autoList.Vertical
            if i % 2 == 0 then
                curPos.x = GameLogic.autoList.Horizontal
                Yindex = Yindex + 1
            else
                curPos.x = 0
            end
            table.insert(btnPos, curPos)
        end
        return btnPos
    end
}

--表示层高。12是有12层木桩显示。for就有15层。顶部隐藏了2层，底部隐藏1层
GameLogic.pinsMap = {
    [1] = 12,
    [2] = 14,
    [3] = 16
}

--赔率  场景数据服务器配置下发
GameLogic.odds = {
    [12] = {
        [GameLogic.betType.GM_GREEN + 1] = {3.2, 1.6, 1.3, 1.2, 1.1, 1, 0.5, 1, 1.1, 1.2, 1.3, 1.6, 3.2},
        [GameLogic.betType.GM_YELLOW + 1] = {12, 5.6, 3.2, 1.6, 1, 0.7, 0.2, 0.7, 1, 1.6, 3.2, 5.6, 12},
        [GameLogic.betType.GM_RED + 1] = {49, 14, 5.3, 2.1, 0.5, 0.2, 0, 0.2, 0.5, 2.1, 5.3, 14, 49}
    },
    [14] = {
        [GameLogic.betType.GM_GREEN + 1] = {18, 3.2, 1.6, 1.3, 1.2, 1.1, 1, 0.5, 1, 1.1, 1.2, 1.3, 1.6, 3.2, 18},
        [GameLogic.betType.GM_YELLOW + 1] = {55, 12, 5.6, 3.2, 1.6, 1, 0.7, 0.2, 0.7, 1, 1.6, 3.2, 5.6, 12, 55},
        [GameLogic.betType.GM_RED + 1] = {353, 49, 14, 5.3, 2.1, 0.5, 0.2, 0, 0.2, 0.5, 2.1, 5.3, 14, 49, 353}
    },
    [16] = {
        [GameLogic.betType.GM_GREEN + 1] = {33, 18, 3.2, 1.6, 1.3, 1.2, 1.1, 1, 0.5, 1, 1.1, 1.2, 1.3, 1.6, 3.2, 18, 33},
        [GameLogic.betType.GM_YELLOW + 1] = {100, 55, 12, 5.6, 3.2, 1.6, 1, 0.7, 0.2, 0.7, 1, 1.6, 3.2, 5.6, 12, 55, 100},
        [GameLogic.betType.GM_RED + 1] = {500, 353, 49, 14, 5.3, 2.1, 0.5, 0.2, 0, 0.2, 0.5, 2.1, 5.3, 14, 49, 353, 500}
    }
}

GameLogic.upOdds = function(nLinesMultiples)
    for s, v in ipairs(nLinesMultiples) do
        local len = #v[1]
        local sum = len * 2 - 1
        for k = 1, 3 do
            for i = 1, sum do
                if i <= len then
                    GameLogic.odds[sum - 1][k][i] = nLinesMultiples[s][k][len - i + 1] * 0.1
                else
                    GameLogic.odds[sum - 1][k][i] = nLinesMultiples[s][k][i - len + 1] * 0.1
                end
            end
        end
    end
end

--12,14,16 三种类型木桩点的绘制数据生成
GameLogic.drawData = {
    [12] = {
        height = 14,
        scale = 1.04, --木桩，球的整体缩放
        pointTable = {}, --绘制显示的木桩坐标表。去掉了顶部两行和底部一行
        allPointArray = {}, --包括隐藏的所有点坐标
        block_x_table = {} --底部一行中奖颜色块的坐标 3色的中奖块x坐标依赖这个。对应是木桩最底部的洞
    },
    [14] = {
        height = 13,
        scale = 0.9,
        pointTable = {}, --绘制显示的木桩坐标表。去掉了顶部两行和底部一行
        allPointArray = {}, --包括隐藏的所有点坐标
        block_x_table = {} --底部一行中奖颜色块的坐标 3色的中奖块x坐标依赖这个。对应是木桩最底部的洞
    },
    [16] = {
        height = 13,
        scale = 0.8,
        pointTable = {}, --绘制显示的木桩坐标表。去掉了顶部两行和底部一行
        allPointArray = {}, --包括隐藏的所有点坐标
        block_x_table = {} --底部一行中奖颜色块的坐标 3色的中奖块x坐标依赖这个。对应是木桩最底部的洞
    }
}


GameLogic.index = {}
--服务器中奖位置转换客户端下注位置
--服务器中奖位置下标是从中间往两边递增。 7，6，5，4，3，2，1，0                            客户端还要随机翻转位置
--对应客户端中间位置                   1，2，3，4，5，6，7，8，9，10，11，12，13，14，15
GameLogic.serverIndex2BetIndex = function(line, serverIndex)
    local betIndex = 0
    local sum = #GameLogic.odds[line][1]
    local index = (sum - 1) / 2

    local r = math.random(1, 2)
    GameLogic.index[line] = {}
    for i = 1, sum do
        local _r = 0
        if i <= index then
            GameLogic.index[line][i] = index - i + 1
            _r = 1
        elseif i == index + 1 then
            GameLogic.index[line][i] = 0
            if serverIndex == 0 then
                betIndex = i
            end
        else
            GameLogic.index[line][i] = i - index - 1
            _r = 2
        end
        if serverIndex == GameLogic.index[line][i] then
            if r == _r then
                betIndex = i
            end
        end
    end
    return betIndex
end

--获得三角形木桩绘制点坐标
GameLogic.getDrawPoint = function()
    for i, v in ipairs(GameLogic.pinsMap) do
        local rowsize = v + 2
        local height = GameLogic.drawData[v].height
        local scale = GameLogic.drawData[v].scale
        local step = GameLogic.step
        local posSize = GameLogic.posSize

        local block_x_table = {} --底部中奖颜色块的X坐标列表
        local allPointArray = {} --所有点的坐标    分析路线要用
        local pointTable = {} --画点

        local scale = scale
        local step = step * scale
        local posSize = posSize * scale

        local origPos = {
            x = posSize / 2,
            y = posSize / 2
        }
        -- +1：为了绘制路线，底部隐藏了一行
        for i = rowsize + 1, 3, -1 do
            allPointArray[i] = {}
            local offset = {}
            offset.x = (rowsize - i) * (step + posSize) / 2

            for k = 1, i do
                local curPos = cc.p(0, 0)
                curPos.x = origPos.x + offset.x + (k - 1) * (step + posSize)
                curPos.y = origPos.y + (rowsize - i) * (step + posSize - height)
                allPointArray[i][k] = curPos
                if i <= rowsize then
                    table.insert(pointTable, curPos)
                else
                    table.insert(block_x_table, curPos)
                end
            end
        end
        GameLogic.drawData[v].pointTable = pointTable
        GameLogic.drawData[v].allPointArray = allPointArray
        GameLogic.drawData[v].block_x_table = block_x_table
    end
end

--倒推路线
GameLogic.createLine = function(endIndex, line)
    local rowsize = line + 2
    local lineArray = {}
    local lastIndex = endIndex + 1
    lineArray[rowsize + 1] = lastIndex

    local leftbegin = math.floor((rowsize - 2) / 2)
    local rightbegin = math.ceil((rowsize - 2) / 2) + 1

    for i = rowsize, 3, -1 do
        -- lineArray[i] = {}
        local curIndex = lastIndex
        local max = 0
        local _rand = 0 --比0小的左边  >=0 的右边

        --收缩路线
        if endIndex > rightbegin then
            max = rightbegin - endIndex
            _rand = math.random(max, 0)
        elseif endIndex < leftbegin then
            max = leftbegin - endIndex
            _rand = math.random(-1, max)
        else
            _rand = math.random(-1, 0)
        end

        if _rand < 0 then
            -- lineArray[i+1].dir = "\\"
            -- lineArray[i+1].direction = "right"
            _rand = -1
        else
            -- lineArray[i+1].dir= "/"
            -- lineArray[i+1].direction = "left"
            _rand = 0
        end
        curIndex = lastIndex + _rand

        --修正越界，倒序随机路线可能会随机到外边界
        if curIndex <= 1 then
            curIndex = 2 --左边越界
        -- lineArray[i+1].dir = "/"
        -- lineArray[i+1].direction = "left"
        end
        if curIndex >= i then
            curIndex = i - 1 --右边越界
        -- lineArray[i+1].dir = "\\"
        -- lineArray[i+1].direction = "right"
        end
        lineArray[i] = curIndex
        lastIndex = curIndex
    end
    return lineArray
end

--路线生成bit数组
GameLogic.getLineBit = function(rowsize, lineArray)
    local bitArray = {}
    local nextIndex = lineArray[rowsize + 1]

    for i = rowsize, 3, -1 do
        if lineArray[i] < nextIndex then
            bitArray[i - 2] = 0
        else
            bitArray[i - 2] = 1
        end
        nextIndex = lineArray[i]
    end
    return bitArray
end

--路线反生成木桩下标
GameLogic.createPointIndex = function(line, routes, winningIndex)
    local rowsize = line + 2
    local posIndex = 2
    local lineArray = {}

    
    for i = 3, rowsize+1 do
        if i == 3 then
            lineArray[i] = posIndex  --路线是下一步
        else
            local number = routes[i - 3]
            posIndex = posIndex + number
            lineArray[i] = posIndex
        end
    end
    return lineArray
end

--生成球移动轨迹坐标
GameLogic.getMovePosArray = function(lineArray, line)
    local movePosArray = {}
    local rowsize = line + 2
    for i = 3, rowsize + 1 do
        local k = lineArray[i]
        local polePos = GameLogic.drawData[line].allPointArray[i][k]
        local curPoleData = {}
        curPoleData.pos = {x = polePos.x, y = polePos.y + GameLogic.posSize + 4}
        table.insert(movePosArray, curPoleData)
    end

    movePosArray[1].pos.x = movePosArray[2].pos.x
    movePosArray[1].pos.y = movePosArray[2].pos.y + 70

    local endPos = movePosArray[#movePosArray].pos
    movePosArray[#movePosArray].pos.y = endPos.y - 70
    return movePosArray
end

GameLogic.printArray = function(arr, count)
    local pArray = {}
    for i = 1, count do
        if arr[i] then
            table.insert(pArray, arr[i])
        end
    end
    return pArray
end

-- local bitIndex = 2
-- local line = 14
-- math.randomseed(os.time())
-- local endIndex = GameLogic.serverIndex2BetIndex(line, bitIndex)
-- print(endIndex)
-- local lineArray = GameLogic.createLine(endIndex, line)
-- print(unpack(GameLogic.printArray(lineArray, line + 3)))
-- local bitArray = GameLogic.getLineBit(line + 2, lineArray)
-- print(unpack(bitArray))
-- local lineArray = GameLogic.createPointIndex(line, bitArray, endIndex)
-- print(unpack(GameLogic.printArray(lineArray, line + 3)))

return GameLogic
