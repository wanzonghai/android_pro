--
-- Author: senji
-- Date: 2014-07-15 19:58:23
--
CsvUtil = {}

function CsvUtil.cookValueByTypeStr(typeStr, valueStr)
    if typeStr == "n" then
        return checknumber(valueStr);
    elseif typeStr == "s" then
        return tostring(valueStr);
    elseif typeStr == "a" then
        return string.split(valueStr, ",");
    elseif typeStr == "t" then
        return loadstring("return { " .. valueStr .. " }")();
    elseif typeStr == "v" then
        return TableUtil.toNumberArray(string.split(valueStr, ","));
    elseif typeStr == "b" then
        return valueStr == "1"
    end

    return nil;
end


function CsvUtil.forCsvVo(csvVo, func)
    if csvVo.__csvSuper and csvVo.__csvSuper._keyOrderDic then
        for key,index in pairs(csvVo.__csvSuper._keyOrderDic) do
            func(key, csvVo[index]);
        end
    else
        for key,value in pairs(csvVo) do
            func(key, value);
        end
    end
end

function CsvUtil.setCsvValue(csvVo, key, value)
    if csvVo._keyOrderDic and csvVo._keyOrderDic[key] then
        csvVo[csvVo._keyOrderDic[key]] = value
    else
        csvVo[key] = value
    end
end

function CsvUtil.parseCSVLine2(lineStr)
    local separaterIndexes = {}
    local quoterNum = 0;
    local beginIndex = 1;
    local result = {};
    for index, char in string.gmatch(lineStr, '()([",])') do
        if char == '"' then -- 引号
            quoterNum = quoterNum + 1;
        elseif quoterNum % 2 == 0 then  -- 逗号并且引号数为偶数
            quoterNum = 0;
            table.insert(result, string.sub(lineStr, beginIndex, index - 1))
            beginIndex = index + 1;
        end
    end

    table.insert(result, string.sub(lineStr, beginIndex))

    return result;
end

--#see http://lua-users.org/wiki/LuaCsv
function CsvUtil.parseCSVLine(line, sep)
    local res = {}
    local pos = 1
    sep = sep or ','
    while true do
        local c = string.sub(line, pos, pos)
        if (c == "") then break end
        if (c == '"') then
            -- quoted value (ignore separator within)
            local txt = ""
            repeat
                local startp, endp = string.find(line, '^%b""', pos)
                txt = txt .. string.sub(line, startp + 1, endp - 1)
                pos = endp + 1
                c = string.sub(line, pos, pos)
                if (c == '"') then txt = txt .. '"' end
                -- check first char AFTER quoted string, if it is another
                -- quoted string without separator, then append it
                -- this is the way to "escape" the quote char in a quote. example:
                --   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
                until (c ~= '"')
            table.insert(res, txt)
            assert(c == sep or c == "")
            pos = pos + 1
        else
            -- no quotes used, just look for the first separator
            local startp, endp = string.find(line, sep, pos)
            if (startp) then
                table.insert(res, string.sub(line, pos, startp - 1))
                pos = endp + 1
            else
                -- no separator found -> use rest of string and terminate
                table.insert(res, string.sub(line, pos))
                break
            end
        end
    end
    return res
end


--其他方法

-- #see http://lua-users.org/wiki/CsvUtils
-- Used to escape "'s by toCSV
local function escapeCSV(s)
    if string.find(s, '[,"]') then
        s = '"' .. string.gsub(s, '"', '""') .. '"'
    end
    return s
end

-- Convert from CSV string to table (converts a single line of a CSV file)
function CsvUtil.fromCSV(s)
    s = s .. ',' -- ending comma
    local t = {} -- table to collect fields
    local fieldstart = 1
    repeat
        -- next field is quoted? (start with `"'?)
        if string.find(s, '^"', fieldstart) then
            local a, c
            local i = fieldstart
            repeat
                -- find closing quote
                a, i, c = string.find(s, '"("?)', i + 1)
                until c ~= '"' -- quote not followed by quote?
            if not i then error('unmatched "') end
            local f = string.sub(s, fieldstart + 1, i - 1)
            table.insert(t, (string.gsub(f, '""', '"')))
            fieldstart = string.find(s, ',', i) + 1
        else -- unquoted; find next comma
            local nexti = string.find(s, ',', fieldstart)
            table.insert(t, string.sub(s, fieldstart, nexti - 1))
            fieldstart = nexti + 1
        end
        until fieldstart > string.len(s)
    return t
end

-- Convert from table to CSV string
function CsvUtil.toCSV(tt)
    local s = ""
    -- ChM 23.02.2014: changed pairs to ipairs
    -- assumption is that fromCSV and toCSV maintain data as ordered array
    for _, p in ipairs(tt) do
        s = s .. "," .. escapeCSV(p)
    end
    return string.sub(s, 2) -- remove first comma
end