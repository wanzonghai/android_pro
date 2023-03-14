--
-- Author: senji
-- Date: 2014-03-04 14:45:24
--
DateUtil = {};

-- 获取日期信息
-- mode（默认是1）如下：
-- 1 : 07-28 15:20
-- 2 : 2015-07-11
-- 3 : 2015-07-11 15:20:00
-- 4 : 15:20 只有时分
-- 5 : MM-DD 15:20 没有年，和秒
function DateUtil.getDateString(second, mode, isKeep2Bits)
    mode = mode or 1
    if second == nil then
        second = tickMgr:getServerTime() or tickMgr:getTime();
    end
    local y = os.date("%Y", second)
    local m = os.date("%m", second)
    local d = os.date("%d", second)

    local hour = os.date("%H", second)
    local min = os.date("%M", second)
    local second = os.date("%S", second)

    if isKeep2Bits then
        y = StringUtil.int2StringKeepBits(y, 2, true);
        m = StringUtil.int2StringKeepBits(m, 2);
        d = StringUtil.int2StringKeepBits(d, 2);
        hour = StringUtil.int2StringKeepBits(hour, 2);
        min = StringUtil.int2StringKeepBits(min, 2);
        second = StringUtil.int2StringKeepBits(second, 2);
    end


    if mode == 1 then
        return m .. "-" .. d .. " " .. hour .. ":" .. min;
    elseif mode == 2 then
        return y .. "-" .. m .. "-" .. d;
    elseif mode == 3 then
        return y .. "-" .. m .. "-" .. d .. "  " .. hour..":"..min..":"..second; 
    elseif mode == 4 then
        return hour .. ":" .. min;
    elseif mode == 5 then
        return string.format("%s-%s %s:%s", m, d, hour, min)
     elseif mode == 7 then
        return m .. "月" .. d .."日";
    end
end

--将当前时间戳用北京时间表示
function DateUtil.getChinaDateString(second, mode, isKeep2Bits)
    second = tickMgr:getChinaTime(second)
    return DateUtil.getDateString(second, mode, isKeep2Bits)
end

-- 字符串时间转换成时间戳
-- @param str：字符串时间（tYYYY-MM-DD HH:MM:SS）
function DateUtil.getSecondByString(str)
    local _, _, y, m, d, h, min, s = string.find(str, "(%d+)-(%d+)-(%d+) *(%d*):?(%d*):?(%d*)")
    local time = {}
    time.year   = tonumber(y) or 0
    time.month  = tonumber(m) or 0
    time.day    = tonumber(d) or 0
    time.hour   = tonumber(h) or 0
    time.min    = tonumber(min) or 0
    time.sec    = tonumber(s) or 0

    return os.time(time)
end

-- 依据second和mode来返回格式化的时间字符串，
-- second 秒数 如果传nil则返回当前时间的秒数(客户端的当前时间)
-- isKeep2Bits 时分秒三段是否保持两位数字，不够自动填0，默认是true
-- mode（默认是1）如下：
-- 1 : 59:60:01 或 00:00:01 （时分秒固定存在并且保留两位）
-- 2 : 59:60:01 或 59:01 或 01 (时分为0时，不输出)
-- 3 : 59:60:01 或 59:01 或 00:01 (时为0时，不输出)
-- 4 : 59时60分01秒 或 59分01秒 或 01秒 (时分为0时，不输出)
-- 5 : 3d 23:60:01 或 00:00:01 或 23:60:01 (天为0时，不输出)
function DateUtil.getTimeString(second, mode, isKeep2Bits)
    if second == nil then
        second = tickMgr:getTodaySecond();
    end
    mode = mode or 1;
    if isKeep2Bits == nil then
        isKeep2Bits = true;
    end
    local s = second % 60;
    local m = parseInt(second / 60 % 60);
    local h = parseInt(second / 60 / 60);
    local dh = parseInt(second / 60 / 60 % 24);
    local d = parseInt(second / 60 / 60 / 24);
    local hStr = nil;
    local mStr = nil;
    local sStr = nil;
    local dhStr = nil;
    local dStr = nil;
    if isKeep2Bits then
        hStr = StringUtil.int2StringKeepBits(h, 2, true);
        mStr = StringUtil.int2StringKeepBits(m, 2);
        sStr = StringUtil.int2StringKeepBits(s, 2);
        dhStr = StringUtil.int2StringKeepBits(dh, 2);
        dStr = tostring(d);
    else
        hStr = tostring(h);
        mStr = tostring(m);
        sStr = tostring(s);
        dhStr = tostring(dh);
        dStr = tostring(d);
    end

    if mode == 1 then
        return hStr .. ":" .. mStr .. ":" .. sStr;
    elseif mode == 2 then
        local result = "";
        if h ~= 0 then
            result = result .. hStr .. ":"
        end
        if h ~= 0 or m ~= 0 then
            result = result .. mStr .. ":"
        end
        return result .. sStr;
    elseif mode == 3 then
        local result = "";
        if h ~= 0 then
            result = result .. hStr .. ":"
        end
        return result .. mStr .. ":" .. sStr;
    elseif mode == 4 then
        local result = "";
        if h ~= 0 then
            result = I18n.get("c672", result, hStr)
        end
        if h ~= 0 or m ~= 0 then
            result = I18n.get("c673", result, mStr)
        end

        return I18n.get("c674", result, sStr);
    elseif mode == 5 then
        local result = "";
        if d ~= 0 then
            result = result .. dStr .. "d" .. " "
        end
        return result .. dhStr .. ":" .. mStr .. ":" .. sStr;
    end

    return "";
end

function DateUtil:isNextDay(oT)
    if oT <= 0 then
        return true
    end
    local nT = tickMgr:getServerTime() or tickMgr:getTime();
    local oY = os.date("%Y", oT)
    local nY = os.date("%Y", nT)
    if nY > oY then
        return true
    elseif nY < oY then
        return false
    end
    local oM = os.date("%m", oT)
    local nM = os.date("%m", nT)
    if nM > oM then
        return true
    elseif nM < oM then
        return false
    end
    local oD = os.date("%d", oT)
    local nD = os.date("%d", nT)
    return nD > oD
end

--转换巴西时间格式字符串
--巴西时间的展示逻辑：展示格式为：“日 月，年”。例如：1 Julho 2022
--1月=Janeiro，2月=Fevereiro，3月=Março，4月=Abril，5月=Maio，6月=Junho，7月=Julho，8月=Agosto，9月=Setembro，10月=Outubro，11月=Novembro，12月=Dezembro
function DateUtil.getBrazilTimeString(unixTime)

    local M_table = {
        ["01"] = 'Janeiro',
        ["02"] = 'Fevereiro',
        ["03"] = 'Março',
        ["04"] = 'Abril',
        ["05"] = 'Maio',
        ["06"] = 'Junho',
        ["07"] = 'Julho',
        ["08"] = 'Agosto',
        ["09"] = 'Setembro',
        ["10"] = 'Outubro',
        ["11"] = 'Novembro',
        ["12"] = 'Dezembro',
    }

    local brazilTimeData = {
        y = os.date("%Y", unixTime),
        m = os.date("%m", unixTime),
        d = os.date("%d", unixTime),
        hour = os.date("%H", unixTime),
        min = os.date("%M", unixTime),
        second = os.date("%S", unixTime),
    }
    brazilTimeData.m = M_table[brazilTimeData.m]
    return brazilTimeData
end