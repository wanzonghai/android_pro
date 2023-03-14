--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-31
-- Time: 下午7:02
--

module("ByteUtil", package.seeall)

function bytes2Int(str, isLittleOrBigEndian, isSigned) -- use length of string to determine 8,16,32,64 bits
    local t = { str:byte(1, -1) }
    if not isLittleOrBigEndian then --reverse bytes
        local tt = {}
        for k = 1, #t do
            tt[#t - k + 1] = t[k]
        end
        t = tt
    end
    local n = 0
    for k = 1, #t do
        n = n + t[k] * 2 ^ ((k - 1) * 8)
    end
    if isSigned then
        -- print("什么情况bytes2Int", #t, n)
        -- print_r(t)
        n = (n > 2 ^ (#t - 1) - 1) and (n - 2 ^ #t) or n -- if last bit set, negative.
    end
    return n
end

function int2Bytes(num, isLittleOrBigEndian, isSigned, numberOfByte2BeUsed)
    if num < 0 and not isSigned then 
        num = -num;
        print("warning, dropping sign from number converting to unsigned");
    end
    local res = {}
    local n = numberOfByte2BeUsed or math.ceil(select(2, math.frexp(num)) / 8) -- number of bytes to be used.
    if isSigned and num < 0 then
        num = num + 2 ^ n
    end
    for k = n, 1, -1 do -- 256 = 2^8 bits per char.
        local mul = 2 ^ (8 * (k - 1))
        res[k] = math.floor(num / mul)
        num = num - res[k] * mul
    end
    assert(num == 0)
    if not isLittleOrBigEndian then
        local t = {}
        for k = 1, n do
            t[k] = res[n - k + 1]
        end
        res = t
    end
    -- print("int2Byte什么情况", numberOfByte2BeUsed, n)
    -- print_r(res)
    return string.char(unpack(res))
end

-- float 转成 4字节 IEEE754标准 单精度 little_enaian
function float2Byte(floatValue, isLittleOrBigendian)
    local sign = 0
    if floatValue < 0 then sign = 1; floatValue = -floatValue end
    local mantissa, exponent = math.frexp(floatValue)
    if floatValue == 0 then -- zero
        mantissa = 0; exponent = 0
    else
        mantissa = (mantissa * 2 - 1) * math.ldexp(0.5, 24)
        exponent = exponent + 126
    end
    local v, byte = "" -- convert to bytes
    floatValue, byte = grab_byte(mantissa); v = v .. byte -- 7:0
    floatValue, byte = grab_byte(floatValue); v = v .. byte -- 15:8
    floatValue, byte = grab_byte(exponent * 128 + floatValue); v = v .. byte -- 23:16
    floatValue, byte = grab_byte(sign * 128 + floatValue); v = v .. byte -- 31:24

    if not isLittleOrBigendian then
        v = string.reverse(v);
    end

    return v
end

-- 4个字节转换成float，LittleEndian，IEEE754 单精度
function bytes2Float(byte4Str, isLittleOrBigendian)
    if not isLittleOrBigendian then
        byte4Str = string.reverse(byte4Str);
    end
    local sign = 1
    local mantissa = string.byte(byte4Str, 3) % 128
    for i = 2, 1, -1 do mantissa = mantissa * 256 + string.byte(byte4Str, i) end
    if string.byte(byte4Str, 4) > 127 then sign = -1 end
    local exponent = (string.byte(byte4Str, 4) % 128) * 2 +
            math.floor(string.byte(byte4Str, 3) / 128)
    if exponent == 0 then return 0 end
    mantissa = (math.ldexp(mantissa, -23) + 1) * sign
    return math.ldexp(mantissa, exponent - 127)
end

-- 8字节转换成Double IEEE754 双精度 LittleEndian
function bytes2Double(byte8Str, isLittleOrBigendian)
    if not isLittleOrBigendian then
        byte8Str = string.reverse(byte8Str);
    end
    local sign = 1
    local mantissa = string.byte(byte8Str, 7) % 16
    for i = 6, 1, -1 do mantissa = mantissa * 256 + string.byte(byte8Str, i) end
    if string.byte(byte8Str, 8) > 127 then sign = -1 end
    local exponent = (string.byte(byte8Str, 8) % 128) * 16 +
            math.floor(string.byte(byte8Str, 7) / 16)
    if exponent == 0 then return 0 end
    mantissa = (math.ldexp(mantissa, -52) + 1) * sign
    return math.ldexp(mantissa, exponent - 1023)
end

-- Double转换成8个字节 IEEE754 双精度 LittleEndian
function double2Bytes(doubleValue, isLittleOrBigendian)
    local sign = 0
    if doubleValue < 0 then sign = 1; doubleValue = -doubleValue end
    local mantissa, exponent = math.frexp(doubleValue)
    if doubleValue == 0 then -- zero
        mantissa, exponent = 0, 0
    else
        mantissa = (mantissa * 2 - 1) * math.ldexp(0.5, 53)
        exponent = exponent + 1022
    end
    local v, byte = "" -- convert to bytes
    doubleValue = mantissa
    for i = 1, 6 do
        doubleValue, byte = grab_byte(doubleValue); v = v .. byte -- 47:0
    end
    doubleValue, byte = grab_byte(exponent * 16 + doubleValue); v = v .. byte -- 55:48
    doubleValue, byte = grab_byte(sign * 128 + doubleValue); v = v .. byte -- 63:56
    if not isLittleOrBigendian then
        v = string.reverse(v);
    end
    return v
end

function grab_byte(v)
    return math.floor(v / 256), string.char(math.floor(v) % 256)
end
