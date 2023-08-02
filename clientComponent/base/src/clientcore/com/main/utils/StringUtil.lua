--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-6
-- Time: AM10:30
--

--StringUtil = {};

module("StringUtil", package.seeall);

local md5 = require "md5"

-- 让一个整数保持多少位字符串输出，高位自动补0，或者自动裁剪
-- 例如(10,4)则输出0010，(10,1)则输出0
-- 比如：
-- int2StringKeepBits(4, 2)返回"04"
-- int2StringKeepBits(401, 1)返回"1"
function int2StringKeepBits(num, bits, isNotSubOverLen)
    num = math.modf(num);
    bits = math.modf(bits);
    local result = tostring(num);
    local numStrLen = #result;
    if numStrLen >= bits then
        if not isNotSubOverLen then
            result = string.sub(result, numStrLen - bits + 1);
        end
    else
        result = string.rep("0", bits - numStrLen) .. result;
    end
    return result;
end

-- 将一个数组的元素合并成一个字符串
-- 比如joini({1,2,3,4},"|") 返回"1|2|3|4"
-- @param delimiter默认","
function join(table, delimiter)
    delimiter = delimiter or ",";
    local result = "";
    for i, value in ipairs(table) do
        result = result .. delimiter .. tostring(value);
    end
    if #result > 0 then
        result = string.sub(result, 2);
    end
    return result;
end

-- 判断字符串是否有效
-- 判断条件是str~=nil 且str ~= "";
function isStringValid(str)
    return str ~= nil and str ~= "";
end

-- 出现过这种模式多少次
function numOfPattern(str, pattern)
    local num = 0;
    for beginIndex, content, endindex in string.gmatch(str, pattern) do
        num = num + 1;
    end

    return num;
end

function md5sum(str, isUpperOrLowerCase)
    --str = md5(str)
    str = md5.sum(str)
    local function formater(c)
        return string.format("%02x", string.byte(c))
    end

    str = string.gsub(str, ".", formater);
    if isUpperOrLowerCase then
        str = string.upper(str)
    end
    return str;
end

function upperFirstChar(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

function lowerFirstChar(str)
    return string.lower(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

function numberStr2FormatNumberStr(str)
    local number = parseInt(str)
    local isNegative = (number < 0)
    number = math.abs(number)
    str = string.format("%d", number) --tostring(number)会有科学计数法

    local length = string.len(str)
    local formatStr = ""
    local endIndex = length

    while endIndex >= 1 do
        local index = endIndex - 2
        local format = ","
        if index <= 1 then
            index = 1
        end

        formatStr = string.sub(str, index, endIndex) .. format .. formatStr
        endIndex = endIndex - 3
    end
    formatStr = string.gsub(formatStr, ",$", "")
    if isNegative then
        formatStr = "-" .. formatStr
    end

    return formatStr
end

function numberStr2ZhHant(currencyDigits)
    local digits = { "零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" }
    local radices = { "", "拾", "佰", "仟" }
    local bigRadices = { "", "万", "亿" }
    local CN_DOLLAR = ""--"圆"
    local number = tonumber(currencyDigits)
    if not number or number <= 0 then
        return digits[1] .. CN_DOLLAR
    end
    currencyDigits = string.format("%d", currencyDigits) --tostring(currencyDigits)会有科学计数法
    local outputCharacters = ""
    local zeroCount = 0
    local length = string.len(currencyDigits)
    local p, d
    local quotient, modulus
    if currencyDigits == "0" then
        outputCharacters = digits[1]
    else
        for i = 1, length do
            p = length - i
            d = string.sub(currencyDigits, i, i)
            quotient = math.floor(p / 4)
            modulus = p % 4
            if d == "0" then
                zeroCount = zeroCount + 1
            else
                if zeroCount > 0 then
                    outputCharacters = outputCharacters .. digits[1];
                end
                zeroCount = 0
                outputCharacters = outputCharacters .. digits[tonumber(d) + 1] .. radices[modulus + 1]
            end
            if modulus == 0 and zeroCount < 4 then
                quotient = quotient + 1
                if quotient > 3 then quotient = 2 + quotient % 2 end
                outputCharacters = outputCharacters .. bigRadices[quotient]
            end
        end
    end
    outputCharacters = outputCharacters .. CN_DOLLAR
    return outputCharacters
end

-- 将数字转换成abc
-- beginChar 是a还是A 默认是A
-- num :1 对应 A, 2:B....
function number2ABC(num, beginChar)
    beginChar = beginChar or "A"
    return string.char(string.byte(beginChar) + num - 1);
end

function getFileName(filePath)
    return string.match(filePath, ".+/([^/]*%.%w+)$") -- *nix system  
    --return string.match(filePath, “.+\\([^\\]*%.%w+)$”) — *windows system  
end

function isAsciiChar(char)
    local charByte = string.byte(char);
    return charByte <= 127 and charByte >= 0 -- ascii内
end

--判断数字格式
function inputCheckOfNumber(strNum)
    strNum = strNum or ""
    for index = 1, #strNum do
        local tmpStr = string.sub(strNum, index, index)
        local temp = string.byte(tmpStr)
        if temp < 48 or temp > 57 then
            return false, strNum
        end
    end
    return true, strNum
end

--判断ascii格式
function inputCheckOfAscii(strNum)
    strNum = strNum or ""
    for index = 1, #strNum do
        local tmpStr = string.sub(strNum, index, index)
        local temp = string.byte(tmpStr)
        if temp < 0 or temp > 127 then
            return false, strNum
        end
    end
    return true, strNum
end


-- 字符串str是否超过长度maxLen，其中中文字符当两个，半角英文数字字符占一个 

--  # Modified By LaoK #
--  #     2017.8.4     # 
--
--  为函数添加第二个参数countForUnicode, 用于指定unicode字符的长度占位。
--  该参数具有默认值，默认值为2

function getStringLen(str, countForUnicode)
    str = str or ""
    local lenInByte = #str
    local strlen = 0
    local readByte = 1
    local unicodeCounter = countForUnicode or 2

    for i = 1, lenInByte do
        if i >= readByte then
            local curByte = string.byte(str, i)
            local byteCount = 1;
            if curByte > 0 and curByte <= 127 then
                byteCount = 1
            elseif curByte >= 192 and curByte <= 223 then
                byteCount = 2
            elseif curByte >= 224 and curByte <= 239 then
                byteCount = 3
            elseif curByte >= 240 and curByte <= 247 then
                byteCount = 4
            end

            local char = string.sub(str, i, i + byteCount - 1)
            readByte = readByte + byteCount

            if byteCount == 1 then
                strlen = strlen + 1
            else
                strlen = strlen + unicodeCounter
            end
        end
    end

    return strlen;
end

--  #   Added By LaoK  #
--  #     2017.8.4     # 

-- 以contentString为内容填充label对象，若填后label宽度超过sizeLimit规定的阈值，则对contentString进行裁剪，
-- 裁剪部分使用... 替代

function setLabelWithSizeLimit(cocosLabel, contentString, sizeLimit)

    cocosLabel:setString(contentString)

    while cocosLabel:getContentSize().width > sizeLimit do
        contentString = StringUtil.truncate(contentString, StringUtil.getStringLen(contentString, 1) - 1, "", 1)
        cocosLabel:setString(contentString .. "...")
    end
end

-- 去掉两边的引号
function trimQuoter(str)
    local len = #str;
    local firstChar = string.sub(str, 1, 1)
    local endChar = string.sub(str, len, len)
    if (firstChar == "'" and endChar == "'") or (firstChar == '"' and endChar == '"') then
        str = string.sub(str, 2, len - 1);
    end

    return str;
end

-- 字符串str是否超过长度maxLen，其中中文字符当两个，半角英文数字字符占一个
function isStringLenOver(str, maxLen)
    maxLen = maxLen or 0

    local strlen = StringUtil.getStringLen(str)
    return strlen > maxLen;
end

-- 字符串str是否含有emoji表情
function isStringContainsEmoji(str)

    str = str or ""

    local result = false
    local lenInByte = #str
    local readByte = 1

    --[[字符是否为emoji
        @char 字符
        @byteCount 字符所占字节
    ]]
    local function isEmojiChar(char, byteCount)
        -- local byteTbl = {240, 159, 152, 129}
        local byteTbl = { 0, 0, 0, 0 }
        for i = 1, byteCount do
            byteTbl[i] = string.byte(char, i, i)
        end
        --4字节emoji
        if byteTbl[1] == 240 and
                byteTbl[2] == 159 and
                byteTbl[3] >= 128 and byteTbl[3] <= 155 and
                byteTbl[4] >= 128 then
            result = true
            --3字节emoji
        elseif byteTbl[1] >= 226 and byteTbl[1] <= 227 and
                byteTbl[2] >= 128 and byteTbl[2] <= 158 and
                byteTbl[3] >= 128 then
            result = true
        end
        --2字节emoji
        if byteTbl[1] == 194 and
                byteTbl[2] >= 169 and byteTbl[2] <= 174 then
            result = true
        end
    end

    --遍历
    for i = 1, lenInByte do
        if i >= readByte then
            local curByte = string.byte(str, i)
            local byteCount = 1;
            if curByte > 0 and curByte <= 127 then
                byteCount = 1
            elseif curByte >= 192 and curByte <= 223 then
                byteCount = 2
            elseif curByte >= 224 and curByte <= 239 then
                byteCount = 3
            elseif curByte >= 240 and curByte <= 247 then
                byteCount = 4
            end

            local char = string.sub(str, i, i + byteCount - 1)

            readByte = readByte + byteCount
            --emoji为2~4字节，多为4字节
            if byteCount ~= 1 then
                isEmojiChar(char, byteCount)
            end
            if result then
                return result
            end
        end
    end
    return result
end

-- 去掉\0
function truncateZeroTerminated(str)
    return string.gsub(str, "%z", ""); --去掉\0等
end

--[[
    将str超出maxLen的部分裁剪  
    @strEllipsis 小尾巴，默认“...”
    例：
    local result = StringUtil.truncate("你好 world", 4, strEllipsis) 
    result 是"你好 w..."
]]
function truncate(str, maxLen, strEllipsis, notAsciiBitCount)
    notAsciiBitCount = notAsciiBitCount or 1;
    str = str or ""
    maxLen = maxLen or 0
    strEllipsis = strEllipsis or "..."

    local lenInByte = #str
    local strlen = 0
    local readByte = 1 
    local result = ""

    for i = 1, lenInByte do
        if i >= readByte then
            local charBit = notAsciiBitCount;
            local curByte = string.byte(str, i)
            local byteCount = 1;
            if curByte > 0 and curByte <= 127 then
                byteCount = 1
                charBit = 1;
            elseif curByte >= 192 and curByte <= 223 then
                byteCount = 2
            elseif curByte >= 224 and curByte <= 239 then
                byteCount = 3
            elseif curByte >= 240 and curByte <= 247 then
                byteCount = 4
            end

            local char = string.sub(str, i, i + byteCount - 1)
            readByte = readByte + byteCount

            strlen = strlen + charBit
            result = result .. char
            if strlen >= maxLen then
                break
            end
        end
    end

    if #result < lenInByte then
        result = result .. strEllipsis
    end
                
    return result
end

--  #     Added By LaoK   #
--  #      2017.10.14     # 

-- same function as truncate, remove non-ascii char's size customization and more clear in code structure

function truncateEx(str, lengthInChar, withEllipsis)

    local result = ""
    local stringLengthInByte = #str
    local byteIndex = 1
    local charNumber = 0
    local currentChar, charSizeInByte = readCharFromString(str, stringLengthInByte, byteIndex)

    -- call readCharFromString recursively, until reach eof or required length in char
    while currentChar and charNumber <= lengthInChar do 

        charNumber = charNumber + 1
        result = result .. currentChar

        byteIndex = byteIndex + charSizeInByte
        currentChar, charSizeInByte = readCharFromString(str, stringLengthInByte, byteIndex)

    end

    -- truncation happens when byteIndex is smaller than stringLengthInByte, add ellipsis
    if byteIndex < stringLengthInByte and withEllipsis then
        result = result .. "..."
    end

    return result

end

function readCharFromString(str, strLen, startByte)

    local curByte = string.byte(str, startByte)
    
    if curByte then

        local nextBytes = 0;

        if curByte >= 192 and curByte <= 223 then
            nextBytes = 1
        elseif curByte >= 224 and curByte <= 239 then
            nextBytes = 2
        elseif curByte >= 240 and curByte <= 247 then
            nextBytes = 3
        end

        if startByte + nextBytes <= strlen then
            local char = string.sub(str, startByte, startByte + nextBytes)
            return char, nextBytes + 1
        else
            return nil, 0
        end

    else
        return nil, 0
    end    

end

function trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

-- 仿照as3的encodeURI
-- url编码时对一些特殊符号进行编码，这个函数比cocos的string.urlencode少匹配了一些符号
-- 未编码的字符有下列：
-- 0 1 2 3 4 5 6 7 8 9
-- a b c d e f g h i j k l m n o p q r s t u v w x y z
-- A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
-- ; / ? : @ & = + $ , #
-- - _ . ! ~ * ' ( )
local _regEncodeURI = "([^a-zA-Z0-9%;%/%?%:%@%&%=%+%$%,%#%-%_%.%!%~%*%'%(%)])"
function encodeURI(s)
    s = string.gsub(s, _regEncodeURI, function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end


function lastIndexOf(str, searchStr)
    if str == nil then return nil end

    local lastIndex = nil
    local index = string.find(str, searchStr, index)
    while index ~= nil do
        lastIndex = index
        index = string.find(str, searchStr, index + 1)
    end
    return lastIndex
end



-- local function reverseArray4SplitNum(arr, dot)
--     local result = {}
--     for i = #arr, 1, -1 do
--         table.insert(result, arr[i])
--         if dot and i > 3 and (i % 3 == 1) then
--             table.insert(result, "d")
--         end
--     end
--     return result
-- end

-- --把数字分割成从右到左排列的数组,只支持整数部分
-- function splitNum(num, dot, sign, bit)
--     local numSigh = num > 0 and "p" or "s" --加p(plus)减s(sub)用了同个
--     num = math.abs(num)

--     --数值超出位数的时候，取余会有bug
--     if num > 2^54 then
--         traceLog("数值溢出", num)
--         return {}, 0
--     end

--     local num_arr = {}
--     if not num then
--         return num_arr, 0
--     end

--     --零
--     if num == 0 then
--         bit = bit or 1
--         for i = 1, bit do
--             table.insert(num_arr, 0)
--         end
--         return num_arr, 1
--     end

--     --非零
--     local i = 0
--     while (num ~= 0) do
--         i = i + 1
--         if i > 1000 then--防止死循环
--             num = 0
--         end
--         num_arr[i] = num % 10
--         num = math.floor(num / 10)
--     end
--     num_arr = reverseArray4SplitNum(num_arr, dot)

--     --补齐位数
--     if bit and #num_arr < bit then
--         local n = bit - #num_arr
--         for i = 1, n do
--             table.insert(num_arr, 1, 0)
--         end
--     end

--     --符号
--     if sign then
--         table.insert(num_arr, 1, numSigh)
--     end
--     return num_arr, i
-- end

MAX_NUMBER_VALUE = 2^54

--把数字分割成从高位到低位排列的数组
--如 -1222.33 输出的table是{"s","1","d","2","2","2","f","3","3"}  "s"是减号，"d"是逗号，"f"是小数点，详见HtmlUtilHelper
--dot 整数部分是否带逗号
--sign 是否加正负号
--bit 整数部分位数不足时在数字前补0，默认1位
--precision 保留几位小数，默认2位
function splitNum(num, dot, sign, bit, precision, keepZero)
    bit = bit or 1
    precision = precision or 0 --默认为整数，需要使用小数要传入要保留的位数，HtmlUtil.createArtNumPrecision

    local num_arr = {}
    if not num then
        return num_arr, 0
    end

    local numSigh = ""
    if num ~= 0 then
        numSigh = num > 0 and "p" or "s" --"+"资源名：p(plus)，"-"资源名：s(sub)
    end
    num = math.abs(num)

    -- 数值超出位数的时候，结果会不准确
    if num > MAX_NUMBER_VALUE then
        traceLog("数值溢出", num)
        return {}, 0
    end

    --把数字number转string，打散成数组
    -- num = num - num % (1 / math.pow(10, precision))--下面string.format会四舍五入，这里应该先floor处理(此操作有问题，精度问题会把0.36当0.35999，从而舍末位后少了0.01)
    local numStr = string.format("%0."..precision.."f", num) --tostring(num)会有科学计数法
    -- local pInt, pFloat = string.match(numStr,"(%d+)%.(%d+)")--整数部分，小数部分。%d的话匹配的时候如果数字过长会溢出
    local result = string.split(numStr, ".")--整数部分，小数部分
    local pInt, pFloat = result[1] or "", result[2] or ""

    local char = nil
    local lInt, lFloat = string.len(pInt), string.len(pFloat)
    if bit > lInt then
        pInt = string.format("%0"..bit.."d", pInt)--整数部分保持位数
        lInt = bit
    end
    -- print("numStr:", numStr)
    -- print("pInt, pFloat:", pInt, pFloat)
    -- print("lInt, lFloat:", lInt, lFloat)

    --整数部分
    for i = 1, lInt do
        char = string.sub(pInt, i, i)
        table.insert(num_arr, char)

        if dot and i < lInt - 2 and ((lInt - i + 1) % 3 == 1) then
            table.insert(num_arr, "d")
        end
    end
    
    --小数部分，末尾的0会去掉
    local pos = #num_arr + 1
    local notZero = false
    for i = lFloat, 1, -1 do
        char = string.sub(pFloat, i, i)
        if keepZero or notZero or char ~= "0" then
            table.insert(num_arr, pos, char)
            notZero = true
        end
    end
    if notZero then
        table.insert(num_arr, pos, "f")
    end

    --正负符号
    if sign and numSigh ~= "" then
        table.insert(num_arr, 1, numSigh)
    end
    return num_arr, #num_arr
end

function splitNumWithHansUnits(num, precision, keepZero)
    precision = precision or 2
    local number = num

    local num_arr = {}

    local units = {}
    local threshold = 10000
    if IS_HL_VERSION then
        threshold = 100000
    end
    if num < threshold then
        num_arr = splitNum(num)
    elseif num < 100000000 then
        num = MathUtil.ifloor(num / 10000 * (10 ^ precision))--lua浮点数精度问题，不用floor，否则红黑大战500地下注，会出现1.14万的情况，下面同理
        num_arr = splitNum(num)
        table.insert(units, "w")
    elseif num < 1000000000000 then
        num = MathUtil.ifloor(num / 100000000 * (10 ^ precision))
        num_arr = splitNum(num)
        table.insert(units, "y")
    else
        num = MathUtil.ifloor(num / 1000000000000 * (10 ^ precision))
        num_arr = splitNum(num)
        table.insert(units, "w")
        table.insert(units, "y")
    end

    --小数点
    if precision > 0 and number >= threshold then
        local intLen = (#num_arr - precision)

        if not keepZero then
            local allZero = true
            for i = precision,1,-1 do
                if num_arr[intLen+i] == 0 or  num_arr[intLen+i] == "0" then
                    table.remove(num_arr, intLen+i)
                else
                    allZero = false
                    break
                end
            end
            if not allZero then
                table.insert(num_arr, intLen+1, "f")
            end
        else
            table.insert(num_arr, intLen+1, "f")
        end
    end

    for i,v in ipairs(units) do
        table.insert(num_arr, v)
    end
    return num_arr
end

--把数字分割成从右到左排列的数组（包含中文字）(单位包含，百万，千万)
function splitNumWithString(num, sign, isShowQ )

    local numSigh ={}
    local numstr = ""

    if sign then
        if num >= 0 then
            numstr = "j"--todo
        else
            numstr = "f"
        end
    end

    num = math.abs(num)
    local num_arr = {}

    if not num then
        return num_arr, 0
    end
 
    if num >= 100000000 then --亿
        
        if num%100000000 ~= 0 then
            num = HtmlUtil.getPreciseDecimal(num/100000000,2)
            numstr = numstr..string.format("%.2f", num)
        else
            num = num/100000000

            if num >= 1000 then
                num = num/1000
                table.insert(numSigh,"q")
            elseif num >= 100 then
                num = num/100
                table.insert(numSigh,"b")
            end

            numstr = numstr..string.format("%.0f", num)
        end

        table.insert(numSigh,"y")
        
    elseif num >= 10000000 then
        table.insert(numSigh,"q")
        table.insert(numSigh,"w")
    
        if num%10000000 ~= 0 then
            num = HtmlUtil.getPreciseDecimal(num/10000000,2)
            numstr = numstr..string.format("%.2f", num)
        else
            num = num/10000000
            numstr = numstr..string.format("%.0f", num)
        end
    elseif num >= 1000000 then

        table.insert(numSigh,"b")
        table.insert(numSigh,"w")
        if num%1000000 ~= 0 then
            num = HtmlUtil.getPreciseDecimal(num/1000000,2)
            numstr = numstr..string.format("%.2f", num)
        else
            num = num/1000000
            numstr = numstr..string.format("%.0f", num)
        end
        
    elseif num >= 10000 then
        table.insert(numSigh,"w")
        
        if num%10000 ~= 0 then
            num = HtmlUtil.getPreciseDecimal(num/10000,2)
            numstr = numstr..string.format("%.2f", num)
        else
            num = num/10000
            numstr = numstr..string.format("%.0f", num)
        end
    else
        --不足一万的情况下要显示“千”单位
        if isShowQ then
            if num >= 1000 then
                table.insert(numSigh,"q")
                if num%1000 ~= 0 then
                    num = HtmlUtil.getPreciseDecimal(num/1000,2)
                    numstr = numstr..string.format("%.2f", num)
                else
                    num = num/1000
                    numstr = numstr..string.format("%.0f", num)
                end
            else
                numstr = numstr..string.format("%.0f", num)
            end
        else
            numstr = numstr..string.format("%.0f", num)
        end
        
    end

 
    for i=1,#numstr do
       
        if string.sub(numstr,i,i) == "." then
            num_arr[i] = "d"
        else
            num_arr[i] = string.sub(numstr,i,i)
        end
    end
    
    for i=1,#numSigh do
        table.insert(num_arr,numSigh[i])
    end

    return num_arr, #numstr+#numSigh
end
----把数字分割成从右到左排列的数组（包含中文字）(单位只包含 万，亿)
function splitNumWithStringOnlyWY(num, sign )

    local numSigh ={}
    local numstr = ""

    if sign then
        if num >= 0 then
            numstr = "j"--todo
        else
            numstr = "f"
        end
    end

    num = math.abs(num)
    local num_arr = {}

    if not num then
        return num_arr, 0
    end
 
    if num >= 100000000 then --亿
        
        if num%100000000 ~= 0 then
            num = HtmlUtil.getPreciseDecimal(num/100000000,2)
            numstr = numstr..string.format("%.2f", num)
        else
            num = num/100000000
            numstr = numstr..string.format("%.0f", num)
        end

        table.insert(numSigh,"y")
     
    elseif num >= 10000 then
        table.insert(numSigh,"w")
        
        if num%10000 ~= 0 then
            num = HtmlUtil.getPreciseDecimal(num/10000,2)
            numstr = numstr..string.format("%.2f", num)
        else
            num = num/10000
            numstr = numstr..string.format("%.0f", num)
        end
    else
        --不足一万的情况下要显示“千”单位
        numstr = numstr..string.format("%.0f", num)
        
    end

 
    for i=1,#numstr do
       
        if string.sub(numstr,i,i) == "." then
            num_arr[i] = "d"
        else
            num_arr[i] = string.sub(numstr,i,i)
        end
    end
    
    for i=1,#numSigh do
        table.insert(num_arr,numSigh[i])
    end

    return num_arr, #numstr+#numSigh
end


