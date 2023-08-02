--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-6
-- Time: AM10:30
--
MathUtil = {};

MathUtil.RANDIAN_2_DEGREE = 180 / math.pi;

--[[
-- val给定范围[min,max]
-- ]]
function MathUtil.getValueBetween(val, min, max)
    min, max = MathUtil.getMinMax(min, max);
    return math.min(math.max(val, min), max);
end

function MathUtil.getMin(value, compareValue)
    if not value then
        return compareValue
    end

    return math.min(value, compareValue)
end

function MathUtil.getMax(value, compareValue)
    if not value then
        return compareValue
    end

    return math.max(value, compareValue)
end

function MathUtil.getValueDiretion(value)
    if value == 0 then
        return 1;
    else
        return value / math.abs(value);
    end
end

-- 传入val1和val2，返回两者的最小值和最大值
function MathUtil.getMinMax(...)
    local t = { ... }
    local min, max = nil, nil
    for i, v in ipairs(t) do
        if min == nil then
            min = v
        else
            min = math.min(min, v)
        end
        if max == nil then
            max = v
        else
            max = math.max(max, v)
        end
    end

    return min, max
end

-- 获取min和max之间 比例为percentFloat的值
-- MathUtil.getValueBetweenByPercent(0.7,1,2) = 1.7
function MathUtil.getValueBetweenByPercent(percentFloat, min, max)
    min, max = MathUtil.getMinMax(min, max);
    return min + (max - min) * percentFloat;
end

function MathUtil.isBetween(value, min, max)
    return value >= min and value <= max;
end

function MathUtil.getRandomRate()
    return math.random(1, 100000000) / 100000000;
end

-- 取随机数，参数跟math.random一样，每次都会设置随机种子
function MathUtil.getRandom(a, b, seed)
    -- math.randomseed(seed or tickMgr:getTimer());--luajit需要这样
    if a and b then
        return math.random(a, b);
    elseif a and not b then
        return math.random(a);
    else
        return math.random();
    end
end

function MathUtil.getDistance(x1, y1, x2, y2)
    return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2));
end

function isNumberValid(value)
    return not isNaN(value) and value ~= 0;
end

function isNaN(value)
    return not value or type(value) ~= "number" or tostring(value) == "nan";
end

function parseUInt(value)
    return math.max(0, parseInt(value));
end

function parseInt(value)
    if type(value) ~= "number" then
        value = tonumber(value)
    end
    return math.floor(value or 0);
end

-- state 分三种类型: 分别是最后一位的取值
-- 1 是四舍五入（这种情况下面说说）
-- 2 是是向上取整
-- 其他（默认），向下取整

-- 关于1的情况，例子
-- local hue = 0;
-- 当运算了hue = hue + 0.1多次后，会出现
-- math.floor(hue * 10) / 10 不等于 hue的情况
-- math.ceil的例子对应是hue = hue - 0.1
-- 无论是mac还是ios都有这样的问题，测试情况是lua5.1
-- 所以这种情况就要用round了
-- 对精度要求不高的的话可以不用round
function fixFloat1(value, state)
    return fixFloat(value, 1, state)
end

function fixFloat(value, n, state)
    n = math.pow(10, n or 2);
    if state == 1 then
        return math.round(value * n) / n
    elseif state == 2 then
        return math.ceil(value * n) / n
    else
        return math.floor(value * n) / n
    end
end

-- 关于state的类型看fixFloat1
function fixFloat2(value, state)
    return fixFloat(value, 2, state)
end

function numberEqual(a, b, delta)
    delta = delta or 0.00000000001
    return math.abs(a - b) < delta;
end

function MathUtil.isRectSame(rect1, rect2)
    return rect1.x == rect2.x and rect1.y == rect2.y and rect1.width == rect2.width and rect1.height == rect2.height
end

function MathUtil.inRect(x, y, rect)
    if x >= rect:getMinX() and x <= rect:getMaxX()
            and y >= rect:getMinY() and y <= rect:getMaxY() then
        return true
    end
    return false
end

function MathUtil.ixXYEqual(x1, y1, x2, y2)
    return x1 == x2 and y1 == y2;
end


-- 通过百分比来计算圆角四边形边上的点，0%时点是四边形的顶线段重点，按照顺时针方向选装
function MathUtil.calRoundRectPosition(percentInFloat, rectCenterX, rectCenterY, rectW, rectH, r)
    local angle = -2 * math.pi * percentInFloat
    local hw = rectW * .5
    local hh = rectH * .5;

    --上下左右四个角
    local pLT = cc.p(rectCenterX - 0.5 * rectW, rectCenterY + 0.5 * rectH);
    local pRT = cc.p(rectCenterX + 0.5 * rectW, rectCenterY + 0.5 * rectH);
    local pRB = cc.p(rectCenterX + 0.5 * rectW, rectCenterY - 0.5 * rectH);
    local pLB = cc.p(rectCenterX - 0.5 * rectW, rectCenterY - 0.5 * rectH);

    local segBeginP1 = cc.p(rectCenterX, rectCenterY)
    local segBeginP2 = cc.p(rectCenterX, rectCenterY + math.max(rectW, rectH) * 100)

    local segTestPoint = cc.pRotateByAngle(segBeginP2, segBeginP1, angle)

    local polygonPoints = { pLT, pRT, pRB, pLB }

    local interP = MathUtil.segmentIntersectPolygon(segBeginP1, segTestPoint, polygonPoints, true)

    local isInRound = false;
    if numberEqual(math.abs(interP.y), hh) then
        isInRound = math.abs(interP.x - segBeginP1.x) > (hw - r)
    else
        isInRound = math.abs(interP.y - segBeginP1.y) > (hh - r)
    end

    if isInRound then
        local circleCenterP = cc.p(0, 0);
        if interP.x > rectCenterX then
            circleCenterP.x = rectCenterX + hw - r
        else
            circleCenterP.x = rectCenterX - (hw - r)
        end
        if interP.y > rectCenterY then
            circleCenterP.y = rectCenterY + hh - r
        else
            circleCenterP.y = rectCenterY - (hh - r)
        end
        local interPs = MathUtil.calLineInterpointViaCircle(interP, segBeginP1, circleCenterP, r);
        local testLen = 0;
        local resultP = nil;
        for i, v in ipairs(interPs) do
            local len = MathUtil.getDistance(rectCenterX, rectCenterY, v.x, v.y)
            if len > testLen then
                testLen = len;
                resultP = v
            end
        end

        return resultP
    else
        return interP
    end
end

-- 弧度在第几象限（1-4）
function MathUtil.calQuadByRadian(angleRadian)
    local pi2 = 2 * math.pi
    if angleRadian < 0 then
        angleRadian = angleRadian + math.ceil(-angleRadian / pi2) * pi2
    else
        angleRadian = angleRadian % pi2;
    end

    return MathUtil.getValueBetween(math.ceil(angleRadian / (math.pi * .5)), 1, 4);
end

function MathUtil.createRectByLdAndRu(ld, ru, xName, yName)
    xName = xName or "x";
    yName = yName or "y";
    return cc.rect(ld[xName], ld[yName], ru[xName] - ld[xName], ru[yName] - ld[yName]);
end

-- rect2 被 rect1 裁减掉
-- 如果rect2 和 rect1不相交，则返回rect2
-- 如果相交， 则最会返回两个rect
-- a1和b1分别是rect1的左下角和右上角的点，同理a2和b2
-- xName和yName 分别是a,b参数的x，y属性的名字，默认为x，y
-- 返回：是rect对象，不受xName, yName的影响
function MathUtil.cutRect(a1, b1, a2, b2, xName, yName)
    xName = xName or "x";
    yName = yName or "y";

    local function createRect(a, b, c, d, xName, yName)
        return cc.rect(a[xName], b[yName], c[xName] - a[xName], d[yName] - b[yName]);
    end

    local rect1 = createRect(a1, a1, b1, b1, xName, yName);
    local rect2 = createRect(a2, a2, b2, b2, xName, yName);

    if not cc.rectIntersectsRect(rect1, rect2) then
        return rect2;
    else
        local rect1 = nil;
        local rect2 = nil;
        if a2[xName] >= a1[xName] and a2[yName] >= a1[yName] then
            rect1 = createRect(a2, b1, b1, b2, xName, yName);
            rect2 = createRect(b1, a2, b2, b2, xName, yName);
        elseif a2[xName] <= a1[xName] and a2[yName] >= a1[yName] then
            rect1 = createRect(a2, a2, a1, b1, xName, yName);
            rect2 = createRect(a2, b1, b2, b2, xName, yName);
        elseif a2[xName] <= a1[xName] and a2[yName] <= a1[yName] then
            rect1 = createRect(a2, a2, a1, b2, xName, yName);
            rect2 = createRect(a1, a2, b2, a1, xName, yName);
        elseif a2[xName] >= a1[xName] and a2[yName] <= a1[yName] then
            rect1 = createRect(a2, a2, b1, a1, xName, yName);
            rect2 = createRect(b1, a2, b2, b2, xName, yName);
        end
        if rect1.width < 0 and rect1.height < 0 then
            rect1 = nil;
        end

        if rect2.width < 0 and rect2.height < 0 then
            rect2 = nil;
        end

        if not rect1 then
            return rect2;
        elseif not rect2 then
            return rect1;
        else
            return rect1, rect2
        end
    end
end

function MathUtil.cookNumWithComma(num)
    local str = tostring(num);
    local temp = string.split(str, ".")
    local intPart = temp[1];

    local charLen = #intPart;
    local i = charLen % 3;
    if i == 0 then
        i = 3;
    end
    local result = ""
    local begin = 1;
    while begin <= charLen do
        if result ~= "" then
            result = result .. ",";
        end
        result = result .. string.sub(str, begin, begin + i - 1);

        begin = begin + i;
        i = 3;
    end

    local floatPart = temp[2] or "";
    if floatPart ~= "" then
        result = result .. "." .. floatPart
    end

    return result;
end

--[[
数字转用单位万, 亿表示
precision 保留小数点后几位，nil的话默认2，如999999表示为99.9
isShowQ 是否显示单位“千”
]]
function MathUtil.cookNumWithHansUnits(num, precision, isShowQ)
    precision = precision or 2
    local result = ""
    if num < 10000 then
        if num >= 1000 and isShowQ ~= nil and isShowQ  then
            num = MathUtil.ifloor(num / 1000 * (10 ^ precision)) / (10 ^ precision)
            return num .. "千"
        end

        return num
    elseif num < 100000000 then
        num = MathUtil.ifloor(num / 10000 * (10 ^ precision)) / (10 ^ precision)
        result = num .. "万"
    elseif num < 1000000000000 then
        num = MathUtil.ifloor(num / 100000000 * (10 ^ precision)) / (10 ^ precision)
        result = num .. "亿"
    else
        num = MathUtil.ifloor(num / 1000000000000 * (10 ^ precision)) / (10 ^ precision)
        result = num .. "万亿"
    end
    return result
end

-- p1到p2 返回按比例factor分的点
-- factor为0-1
function MathUtil.interpolatePoint(p1, p2, factor)
    return cc.pLerp(p1, p2, factor)
end

-- num的整形部分为°，小数部分为′和″
-- mode：
-- 1：度分秒都是整形（默认）
-- 2：度分都是整形， 秒保留两位小数，并且最后位是四舍五入
function MathUtil.getDuFenMiao(num, mode)
    mode = mode or 1;
    local du = num;
    local fen = (du - math.floor(du)) * 60;
    local miao = (fen - math.floor(fen)) * 60;
    if mode == 1 then
        return math.floor(du), math.floor(fen), math.floor(miao);
    elseif mode == 2 then
        return math.floor(du), math.floor(fen), math.round(miao * 100) / 100;
    end

    return nil;
end

-- 获取线段经过长方形的线段部分
function MathUtil.checkRectIntersectLine(rect, lineFromP, lineToP)
    local intersectFromP = nil;
    local intersectToP = nil;

    local rectPoints = {
        cc.p(cc.rectGetMinX(rect), cc.rectGetMaxY(rect)), --左上角
        cc.p(cc.rectGetMinX(rect), cc.rectGetMinY(rect)), --左下角
        cc.p(cc.rectGetMaxX(rect), cc.rectGetMinY(rect)), --右下角
        cc.p(cc.rectGetMaxX(rect), cc.rectGetMaxY(rect)), --右上角
    }

    local function setPoint(p)
        if p then
            if not intersectFromP then
                intersectFromP = p
            elseif not intersectToP then
                intersectToP = p
            else
                print("居然多出来？")
            end
        end
    end

    for i = 1, 4 do
        local p1 = rectPoints[i];
        local p2 = rectPoints[i + 1] or rectPoints[1];

        local interPoint = MathUtil.pGetIntersectPoint(lineFromP, lineToP, p1, p2)
        -- print("相交么", i, interPoint)
        -- print_r(lineFromP)
        -- print_r(lineToP)
        -- print_r(p1)
        -- print_r(p2)
        -- print_r(interPoint)
        -- print_r(rect)
        setPoint(interPoint)
    end

    if cc.rectContainsPoint(rect, lineFromP) then
        setPoint(lineFromP);
    end

    if cc.rectContainsPoint(rect, lineToP) then
        setPoint(lineToP);
    end


    if intersectFromP and intersectToP then
        -- 判断是否同向
        local atan1 = math.atan2(intersectToP.y - intersectFromP.y, intersectToP.x - intersectFromP.x)
        local atan2 = math.atan2(lineToP.y - lineFromP.y, lineToP.x - lineFromP.x)
        if not numberEqual(atan1, atan2) then
            local temp = intersectFromP;
            intersectFromP = intersectToP;
            intersectToP = temp;
        end
    end

    return intersectFromP, intersectToP;
end

function MathUtil.expandPoint(fromP, toP, len)
    local result = cc.p(0, 0);
    local l = MathUtil.getDistance(fromP.x, fromP.y, toP.x, toP.y);
    result.x = fromP.x - (fromP.x - toP.x) / l * (l + len)
    result.y = fromP.y - (fromP.y - toP.y) / l * (l + len)

    return result
end

-- 获取线段交点，改自cocos2dxlua的cc.pGetIntersectPoint,这个只是线段的截取！
function MathUtil.pGetIntersectPoint(pt1, pt2, pt3, pt4)
    local s, t, ret = 0, 0, false
    ret, s, t = cc.pIsLineIntersect(pt1, pt2, pt3, pt4, s, t)
    if ret and s <= 1 and s >= 0 and t >= 0 and t <= 1 then
        return cc.p(pt1.x + s * (pt2.x - pt1.x), pt1.y + s * (pt2.y - pt1.y))
    else
        return nil --不相交，返回空值
    end
end

--检测位状态
--bitIndexDec是二进制对应位为1对应的十进制值, 例如第一位1，则对应十进制为1，第二位为1，则对应十进制为2
function MathUtil.checkBitState(bitValue, bitIndexDec)
    return bit.band(bitValue, bitIndexDec) ~= 0
end

-- 设置位状态
function MathUtil.setBitState(bitValue, bitIndexDec, b)
    if b then
        return MathUtil.setBitStateTrue(bitValue, bitIndexDec)
    else
        return MathUtil.setBitStateFalse(bitValue, bitIndexDec)
    end
end

--设定位状态为true
function MathUtil.setBitStateTrue(bitValue, bitIndexDec)
    --一定要先检查
    if not MathUtil.checkBitState(bitValue, bitIndexDec) then
        return bit.bor(bitValue, bitIndexDec);
    else
        return bitValue
    end
end

--设定位状态为false
function MathUtil.setBitStateFalse(bitValue, bitIndexDec)
    --一定要先检查,否则第一位是0，要把第一位设置成0则会出错
    if MathUtil.checkBitState(bitValue, bitIndexDec) then
        return bit.bxor(bitValue, bitIndexDec);
    else
        return bitValue
    end
end

-- 修正角度范围0-360
function MathUtil.fixRotation(rotation)
    local rotation = rotation % 360;
    if rotation < 0 then
        rotation = rotation + 360;
    end

    return rotation
end

-- 线段与凸多边形的交点，没有交点则返回nil
function MathUtil.segmentIntersectPolygon(segP1, segP2, polygonPoints, isOnlyOnePoint)
    local num = #polygonPoints;
    local resultPoints = nil
    for i, p1 in ipairs(polygonPoints) do
        local p2 = polygonPoints[i + 1];
        if not p2 then
            p2 = polygonPoints[1];
        end

        local intersectPoint = MathUtil.pGetIntersectPoint(segP1, segP2, p1, p2);
        if intersectPoint then
            if isOnlyOnePoint then
                return intersectPoint
            else
                if not resultPoints then
                    resultPoints = {};
                end

                table.insert(resultPoints, intersectPoint);
            end
        end
    end

    return resultPoints;
end

-- 点是否在多边形里面（不包含在边线段上，如果在边线段上，结果是不确定的）
function MathUtil.isPointInsidePolygon(x, y, polygonPoints, isCross180)
    if isCross180 and x < 0 then
        x = x + 360;
    end
    polygonPoints = polygonPoints or {};
    local count = #polygonPoints;
    if count < 3 then
        return false;
    end
    local result = false;
    local j = count;
    for i = 1, count do
        local p1 = polygonPoints[i];
        local p2 = polygonPoints[j];
        local p1x = p1.x;
        local p2x = p2.x;

        if isCross180 and p1x < 0 then
            p1x = p1x + 360;
        end

        if isCross180 and p2x < 0 then
            p2x = p2x + 360;
        end

        if p1.y < y and p2.y >= y or p2.y < y and p1.y >= y then
            if p1x + (y - p1.y) / (p2.y - p1.y) * (p2x - p1x) < x then
                result = not result;
            end
        end
        j = i;
    end
    return result;
end


-- 直线和圆的交点，注意传入来的lineP是用来计算直线，不是线段
-- 下面原理用到直线方程代入圆方程进行计算交点的算法
-- @see also：http://blog.csdn.net/xiaopangxia/article/details/45973991
-- 注意返回结果是一个元素为交点的数组，数量可能是 0-2
function MathUtil.calLineInterpointViaCircle(lineP1, lineP2, cicleCenterPoint, circleR)
    --初始化图像信息  
    local x1, y1, x2, y2, x0, y0, r;
    x1 = lineP1.x;
    y1 = lineP1.y;
    x2 = lineP2.x;
    y2 = lineP2.y;
    x0 = cicleCenterPoint.x;
    y0 = cicleCenterPoint.y;
    r = circleR;
    local esp = 0.000000000001

    --寻找交点解参数方程  
    local a, b, c, a1, b1, c1, d, delta, t1, t2;
    a = y0 - y1;
    b = x1 - x0;
    c = x0 * y1 - x1 * y0;
    d = math.abs(a * x0 + b * y0 + c) / math.sqrt(a * a + b * b + esp);
    a1 = x1 * x1 + x2 * x2 + y1 * y1 + y2 * y2 - 2 * x1 * x2 - 2 * y1 * y2;
    b1 = 2 * (x0 * x1 + x1 * x2 + y0 * y1 + y1 * y2 - x0 * x2 - y0 * y2 - x1 * x1 - y1 * y1);
    c1 = x0 * x0 + x1 * x1 + y0 * y0 + y1 * y1 - 2 * x0 * x1 - 2 * y0 * y1 - r * r;
    delta = b1 * b1 - 4 * a1 * c1;

    local results = {};

    --出交点  
    if d <= r then
        local cp1 = cc.p(0, 0)
        local cp2 = cc.p(0, 0)
        if (delta < esp) then
            --相切只出一个  
            local cos1, sin1;
            t1 = (-b1 + math.sqrt(delta)) / (2 * a1);
            cp1.x = x1 + t1 * (x2 - x1);
            cp1.y = y1 + t1 * (y2 - y1);
            cos1 = (cp1.x - x0) / r;
            sin1 = (cp1.y - y0) / r;
            -- if (math.abs(math.sin(math.acos(cos1)) - sin1) < esp)  then
            --     cp1.a = math.acos(cos1);  
            -- else  
            --     cp1.a = 2 * math.pi - math.acos(cos1);  
            -- end 

            table.insert(results, cp1);
        else
            local cos1, sin1, cos2, sin2;
            t1 = (-b1 + math.sqrt(delta)) / (2 * a1);
            t2 = (-b1 - math.sqrt(delta)) / (2 * a1);
            cp1.x = x1 + t1 * (x2 - x1);
            cp1.y = y1 + t1 * (y2 - y1);
            cos1 = (cp1.x - x0) / r;
            sin1 = (cp1.y - y0) / r;
            -- if (math.abs(math.sin(math.acos(cos1)) - sin1) < esp)  then
            --     cp1.a = math.acos(cos1);  
            -- else  
            --     cp1.a = 2 * math.pi - math.acos(cos1);  
            -- end  

            cp2.x = x1 + t2 * (x2 - x1);
            cp2.y = y1 + t2 * (y2 - y1);
            cos2 = (cp2.x - x0) / r;
            sin2 = (cp2.y - y0) / r;
            -- if (math.abs(math.sin(math.acos(cos2)) - sin2) < esp)  then
            --     cp2.a = math.acos(cos2);  
            -- else  
            --     cp2.a = 2 * math.pi - math.acos(cos2);  
            -- end  

            table.insert(results, cp1)
            table.insert(results, cp2)
        end
    end

    return results;
end

function MathUtil.rect4ContainsXY(rectX, rectY, rectWith, rectHeight, pX, pY)
    local ret = false

    if (pX >= rectX) and (pX <= rectX + rectWith) and
            (pY >= rectY) and (pY <= rectY + rectHeight) then
        ret = true
    end

    return ret
end

function MathUtil.rectContainsXY(rect, x, y)
    return MathUtil.rect4ContainsXY(rect.x, rect.y, rect.width, rect.height, x, y)
end

--lua浮点数运算有时候会出现精度问题，5变成4.999999999...，这时用math.floor会把5变成4，改用 MathUtil.ifloor(value)
function MathUtil.ifloor(value)
    value = checknumber(value)
    return math.floor(value + 0.00000000000001)
end