--
-- Author: cocos Team
-- Date: 2014-12-18 17:03:58

-- 所用资源前缀，资源需打包到plsit中，加#，eg: "#ernn_brown_%s.png"
-- source_spritesheet 存放所有用到的字体切图
-- res目录下 spritesheet目录存放导出的 plist 文档。  PS:各个子游戏 module 中有独立的 spritesheet 目录

-- plist资源描述:
-- 数字0~9: 0~9
-- "百":  b
-- "千":  q
-- "万":  w
-- "亿":  y
-- ",":  d
-- ".":  f
-- "+":  p
-- "-":  s

--自定义前后格式的美术字
--x1000倍
--eg: HtmlUtil.createArtNumWithCustomFormat(1000, prefix, {"x"}, {"bei"})
--"x","bei"是自定义资源名,  string.format(prefix, "x")
--preTable, postTable: 为数组，可以有多个，比如 xx1000 两个乘号，preTable是{"x", "x"}


function HtmlUtil.createCCNodeTxt(srcStr, width, height, spaceWidth, spaceHeight, offsetX, offsetY)
    local properties = {
        src = srcStr,
        width = width,
        height = height,
        spaceWidth = spaceWidth,
        spaceHeight = spaceHeight,
        offsetX = offsetX,
        offsetY = offsetY,
    }
    return "<ccnode" .. HtmlUtil.createPropertyStrByTable(properties) .. "/>"
end

-- 九宫格图片的html
function HtmlUtil.createScale9ImgTxt(path, width, height, capInsets1, capInsets2, capInsets3, capInsets4, offsetX, offsetY)
    local srcStr = TextField.CCNODE_TYPE_SCALE9IMG .. "|" .. path .. "|" .. width .. "|" .. height .. "|" .. capInsets1 .. "|" .. capInsets2 .. "|" .. capInsets3 .. "|" .. capInsets4;
    return HtmlUtil.createCCNodeTxt(srcStr, width, height, nil, nil, offsetX, offsetY);
end

-- 麻将的html
function HtmlUtil.createMJLay(dateInt, isGray, isHu, offsetX, offsetY, width, height)
    local srcStr = TextField.CCNODE_TYPE_MJ_LAY .. "|" .. dateInt .. "|" .. tostring(isGray) .. "|" .. tostring(isHu);
    return HtmlUtil.createCCNodeTxt(srcStr, width, height, nil, nil, offsetX, offsetY);
end

function HtmlUtil.createMJLayGroupUp(datas, isSplitMJ, offsetX, offsetY, width, height)
    local idsStr = StringUtil.join(datas, ",")
    local srcStr = TextField.CCNODE_TYPE_MJ_LAY_GROUP .. "|" .. idsStr;
    local result = ""
    if isSplitMJ then
        for i,v in ipairs(datas) do
            result = result .. HtmlUtil.createMJLay(v, false, false, offsetX, offsetY, width, height);
        end
    else
        result = HtmlUtil.createCCNodeTxt(srcStr, width, height, nil, nil, offsetX, offsetY);
    end

    return result;
end

function HtmlUtil.createMJLayMingGangUp(datas, isSplitMJ, offsetX, offsetY, width, height)
    local idsStr = StringUtil.join(datas, ",")
    local srcStr = TextField.CCNODE_TYPE_MJ_LAY_GROUP_MING_GANG .. "|" .. idsStr;
    local result = ""
    if isSplitMJ then
        for i,v in ipairs(datas) do
            result = result .. HtmlUtil.createMJLay(v, false, false, offsetX, offsetY, width, height);
        end
    else
        result = HtmlUtil.createCCNodeTxt(srcStr, width, height, nil, nil, offsetX, offsetY);
    end
    return result
end

function HtmlUtil.createMJLayAnGangUp(datas, isSplitMJ, offsetX, offsetY, width, height, coverOffsetX, coverOffsetY, coverWidth, coverHeight, coverSpaceWidth, coverSpaceHeight)
    local idsStr = StringUtil.join(datas, ",")
    local srcStr = TextField.CCNODE_TYPE_MJ_LAY_GROUP_AN_GANG .. "|" .. idsStr;
    local result = "";
    if isSplitMJ then
        local len = #datas;
        for i,v in ipairs(datas) do
            if i == len then
                result = result .. HtmlUtil.createMJLay(v, false, false, offsetX, offsetY, width, height);
            else
                result = result .. HtmlUtil.createImg("#plist_mj_body_fall_portrait_small.png", coverWidth, coverHeight, coverOffsetX, coverOffsetY, coverSpaceWidth, coverSpaceHeight);
            end
        end
    else
        result = HtmlUtil.createCCNodeTxt(srcStr, width, height, nil, nil, offsetX, offsetY);
    end

    return result;
end

function HtmlUtil.getPreciseDecimal(nNum, n)

    if type(nNum) ~= "number" then
        return nNum;
    end
    n = n or 0;
    n = math.floor(n)
    if n < 0 then
        n = 0;
    end
    local nDecimal = 10 ^ n
    
    local temp = nNum * nDecimal
    local nTemp = math.floor(temp);

    if temp - nTemp >0.9999 then
        nTemp = math.ceil(temp)
    end
    local nRet = nTemp / nDecimal;

    return nRet;
end

function HtmlUtil.formatNumDotSign(num, dot, sign, bit)
    local num_arr, count = StringUtil.splitNum(num, dot, sign, bit)
    local result = ""
    for i,v in ipairs(num_arr) do
        if "d" == v  then
            result = result .. ","
        elseif v == "p" then
            result = result .. "+"
        elseif v == "s" then
            result = result .. "-"
        else
            result = result .. v
        end
    end
    return result
end

function HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local result = ""
    local imgSrc = ""
    for k,v in ipairs(num_arr) do
        imgSrc = string.format(prefix, v)
        result = result .. HtmlUtil.createImg(imgSrc, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)

    end
    return result
end

--prefix 所用资源前缀，资源需打包到plsit_font中，加#，eg: "#ernn_brown_%s.png"
--“+”:p, "-":s, ",":d, eg: 减号资源命名 "ernn_brown_s.png"
function HtmlUtil.createArtNum(num, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local num_arr, count = StringUtil.splitNum(num)
    return HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
end

--自定义前后格式的美术字
--x1000倍
--eg HtmlUtil.createArtNumWithCustomFormat(1000, prefix, {"x"}, {"bei"})
--"x","bei"是自定义资源名,  string.format(prefix, "x")
--preTable, postTable: 为数组，可以有多个，比如 xx1000 两个乘号，preTable是{"x", "x", 10} 数字10可以在乘号后创建10像素的空格，用于对齐
function HtmlUtil.createArtNumWithCustomFormat(num, prefix, preTable, postTable, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local result = ""
    local imgSrc = ""

    --前置格式
    for i,v in ipairs(preTable or {}) do
        if type(v) == "number" then
            result = result .. HtmlUtil.createSpacer(v)
        else
            imgSrc = string.format(prefix, v)
            result = result .. HtmlUtil.createImg(imgSrc, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
        end
    end

    --数字
    if num and type(num) == "number" then
        result = result .. HtmlUtil.createArtNum(num, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    end

    --后置格式
    for i,v in ipairs(postTable or {}) do
        if type(v) == "number" then
            result = result .. HtmlUtil.createSpacer(v)
        else
            imgSrc = string.format(prefix, v)
            result = result .. HtmlUtil.createImg(imgSrc, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
        end
    end

    return result
end

--bit按指定最小位数输出数字，不足补0，如bit=2, 0输出为00
function HtmlUtil.createArtNumEx(num, prefix, bit, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local num_arr, count = StringUtil.splitNum(num, nil, nil, bit)
    return HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
end

--不带逗号带符号
function HtmlUtil.createArtNumSign(num, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local num_arr, count = StringUtil.splitNum(num, false, true)
    return HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
end

--带逗号的数值
function HtmlUtil.createArtNumDot(num, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local num_arr, count = StringUtil.splitNum(num, true)
    return HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
end

--带逗号和正负号的数值
function HtmlUtil.createArtNumDotSign(num, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local num_arr, count = StringUtil.splitNum(num, true, true)
    return HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
end

--自定义保留小数几位数
function HtmlUtil.createArtNumPrecision(num, prefix, precision, keepZero, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local num_arr, count = StringUtil.splitNum(num, nil, nil, nil, precision, keepZero)
    return HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
end

--数字转用单位万, 亿美术字表示
--中文单位的数字，plist资源里必须要有 "亿": y  "万": w，"小数点": f
--precision保留小数点后几位，nil的话默认2，如999999表示为99.99万
function HtmlUtil.createArtNumWithHansUnits(num, prefix, precision, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local num_arr = StringUtil.splitNumWithHansUnits(num, precision)
    return HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
end

--带中文单位但没正负号
function HtmlUtil.createArtNumDotSignString(num, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local num_arr, count = StringUtil.splitNumWithString(num)
    -- dump(num_arr, count)
    return HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
end

--带中文单位但没正负号(主要用在选房，特别是德州，比如1000，要显示为1千)
function HtmlUtil.createArtNumDotSignStringQ(num, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local num_arr, count = StringUtil.splitNumWithString(num,false,true)
    -- dump(num_arr, count)
    return HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
end

--带中文单位但没正负号(单位只有万，亿)
function HtmlUtil.createArtNumDotSignStringWY(num, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local num_arr, count = StringUtil.splitNumWithStringOnlyWY(num,true)
    -- dump(num_arr, count)
    return HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
end

--带中文单位和+号
function HtmlUtil.createArtNumWithSignString(num, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local num_arr, count = StringUtil.splitNumWithString(num,true)
    -- dump(num_arr, count)
    return HtmlUtil.createNum(num_arr, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
end

function HtmlUtil.createNiuNum(num, prefix, width, height, offsetX, offsetY, spaceWidth, spaceHeight)
    local result = ""
    local numSrc = string.format(prefix, num)
    result = HtmlUtil.createImg(numSrc, width, height, offsetX, offsetY, spaceWidth, spaceHeight)
    return result
end
