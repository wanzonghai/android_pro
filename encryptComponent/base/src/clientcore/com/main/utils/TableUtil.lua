--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-11
-- Time: 下午12:30
--

--TableUtil = {};

module("TableUtil", package.seeall);

-- 返回一个每个元素都转换成number的数组拷贝
-- @param isDicOrArr 对传进去的table t进行数组遍历还是hash遍历
function toNumberArray(t, isDicOrArr)
    local result = {};
    if isDicOrArr then
        for k, v in pairs(t) do
            push(result, checknumber(v));
        end
    else
        for k, v in ipairs(t) do
            push(result, checknumber(v));
        end
    end

    return result;
end

-- 删除t中的元素，需要删除的元素在elements2Remove中
-- 不会修改原来的数组，结果以新数组返回
function removeElements(t, elements2Remove)
    local dic2Remove = {}
    for i,v in ipairs(elements2Remove) do
        dic2Remove[v] = true;
    end

    local result = {}
    for i,v in ipairs(t) do
        if not dic2Remove[v] then
            table.insert(result, v);
        end
    end

    return result
end

function getKeys(t)
    local result = {};
    for k, v in pairs(t) do
        push(result, k);
    end

    return result;
end

-- 把数据或者hashtable转换成数据，注意顺序的属性可能会丢失！
function toArray(t)
    local result = {};
    for k, v in pairs(t) do
        push(result, v);
    end

    return result;
end

-- 多个hash的table合并
function concatDic(...)
    local result = {};
    local tables = { ... };
    for i = 1, #tables do
        local curTable = tables[i];
        for k,v in pairs(curTable) do
            result[k] = v;
        end
    end
    return result;
end

--[[
-- 多个table数据组合，但是不修改原来的table，返回一个新的table
-- ]]
function concat(...)
    local result = {};
    local tables = { ... };
    local curIndex = 1;
    for i = 1, #tables do
        local curTable = tables[i];
        for j = 1, #curTable do
            result[curIndex] = curTable[j];
            curIndex = curIndex + 1;
        end
    end
    return result;
end

--  截取数据，包含beginIndex和endIndex的元素
function subTable(table, beginIndex, endIndex)
    beginIndex = beginIndex or 1;
    local result = {};
    if endIndex then
        endIndex = math.min(#table, endIndex);
    else
        endIndex = #table;
    end

    local index = 1;
    for i = beginIndex, endIndex do
        result[index] = table[i];
        index = index + 1
    end
    return result;
end

-- toNormalOrIntOrString，nil 不变， 1 转换成int，2 转换成字符串
function array2Dic(arr, valueObj, toNormalOrIntOrString)
    arr = arr or {};
    if valueObj ==  nil then
        valueObj = true;
    end
    local result = {}
    for i,v in ipairs(arr) do
        if v ~= "" then
            if not toNormalOrIntOrString then
                result[v] = valueObj;
            elseif toNormalOrIntOrString == 1 then
                result[parseInt(v)] = valueObj;
            elseif toNormalOrIntOrString == 2 then
                result[tostring(v)] = valueObj;
            end
        end
    end
    return result;
end

function copyData(data)
    local tmp = {};

    for k, v in pairs(data) do
        tmp[k] = v;
    end
    
    return tmp;
end

-- 递归找到非table, 拷贝下去
function copyDataDep(data, ignoreMetatable)
    local tmp = {};

    for k, v in pairs(data) do
        if type(v) ~= "table" then
            tmp[k] = v;
        else
            tmp[k] = TableUtil.copyDataDep(v, ignoreMetatable);
        end
    end
    
    if not ignoreMetatable then
        local metatable = getmetatable(data);
        if metatable then
            setmetatable(tmp, metatable)
        end
    end

    return tmp;
end

function removeByLen(t, beginIndex, len)
    len = len or #t;
    return removeByPos(t, beginIndex, beginIndex + len - 1);
end


--[[
-- 删除table的元素，包含beginIndex和endIndex
-- 返回删除了的数组
-- ]]
function removeByPos(t, beginIndex, endIndex)
    local removedItems = {};
    local len = #t; 
    if not endIndex then
        endIndex = len;
    else
        endIndex = math.min(endIndex, len);
    end
    local newTableIndex = 1;
    for i = beginIndex, len do
        local value = t[i];
        removedItems[newTableIndex] = value;
        local offsetIndex = i + endIndex - beginIndex + 1;
        if offsetIndex > len then
            t[i] = nil;
        else
            t[i] = t[offsetIndex];
        end
        newTableIndex = newTableIndex + 1
    end
    return removedItems;
end


function sortOn(t, propertyName, descending)
    local function sortFunc(a, b)
        if descending then
            return a[propertyName] >= b[propertyName];
        else
            return b[propertyName] >= a[propertyName];
        end
    end

    table.sort(t, sortFunc)
end

-- push到数组最后，
-- checkExit: 如果是true，则会检查是否存在这个对象
-- 返回 push是否成功
function push(t, element, checkExit)
    if checkExit and table.indexof(t, element) then
        return false;
    end
    t[#t + 1] = element;
    return true;
end

-- 删除并返回最后一个
function pop(t)
    local lastIndex = #t;
    local result = nil;
    if lastIndex > 0 then
        result = t[lastIndex];
        if result then
            table.remove(t, lastIndex);
        end
    end
    return result;
end

-- 把元素放到数组最前面，
-- checkExit: 如果是true，则会检查是否存在这个对象
function unshift(t, element, checkExit)
    if checkExit and table.indexof(t, element) then
        return;
    end
    table.insert(t, 1, element);
end

-- 删除并返回第一个
function shift(t)
    local result = nil;
    result = t[1];
    if result then
        table.remove(t, 1);
    end
    return result;
end

--清空数组和hash的列表
function clear(...)
    local ts = { ... };
    for i, t in ipairs(ts) do
        local len = #t;
        while len > 0 do
            table.remove(t, len);
            len = len - 1;
        end

        for k, v in pairs(t) do
            t[k] = nil;
        end
    end
end

-- 打散数组
function randomSort(arr)
    local dic = {}
    local function sorter(a, b)
        local a1 = dic[a];
        if not a1 then
            a1 = math.random()
            dic[a] = a1
        end

        local b1 = dic[b];
        if not b1 then
            b1 = math.random()
            dic[b] = b1
        end

        return a1 < b1;
    end

    table.sort( arr, sorter )

    return arr;
end

-- 创建弱表
-- mode为string： __mode的取值为"k"或"v"或"kv"
-- 默认为"k"
function createWeakTable(mode)
    mode = mode or "k";
    local result = {};
    setmetatable(result, { __mode = mode });
end

-- 多维hash结构的赋值
function putObjByKeys(t, obj, keys, notConcatKeys)
    if not notConcatKeys then
        keys = concat(keys);
    end
    local key = shift(keys);
    if #keys == 0 then
        if key then
            t[key] = obj
        else --没有key的时候当做数组push进去
            push(t, obj)
        end
    else
        local newTable = t[key];
        if not newTable then
            newTable = {};
            t[key] = newTable;
        end
        putObjByKeys(newTable, obj, keys, true);
    end
end

-- 把datas数据制作二维数组
-- datas 数据源
-- col 每行多少个
-- minRow 最少多少航
-- 没有数据时的占位值
function cookDataAs2Dimension(datas, col, minRow, holderValue, totalLen)
    minRow = minRow or 0;
    local result = {};
    local curRowData = {};
    local index = 1;
    local len = totalLen or math.max(math.ceil(#datas / col) * col, minRow * col);
    for i = 1, len do
        local vo = datas[i] or holderValue;
        if index == 1 then
            curRowData = {};
            TableUtil.push(result, curRowData);
        end
        curRowData[index] = vo;

        if index == col then
            index = 1;
        else
            index = index + 1;
        end
    end

    return result;
end

function getOneFromHash(t, notSetNil)
    for k,v in pairs(t) do
        if not notSetNil then
            t[k] = nil;
        end
        return v;
    end

    return nil;
end

function getRandomElementFromDic(t)
    local num = table.nums(t)
    local randomIndex = math.random(1, num)
    local i = 1;
    for k,v in pairs(t) do
        if i == randomIndex then
            return v;
        end
        i = i + 1;
    end
end

function getRandomElement(t)
    if t then
        local len = #t;
        if len > 0 then
            return t[math.random(1, len)]
        else
            return nil
        end
    else
        return nil;
    end
end

function clearTableFrom(t, fromIndex)
    for i = fromIndex, #t do
        t[i] = nil;
    end
end

function copyPropertyTo(from, to)
    for k,v in pairs(from) do
        to[k] = v;
    end

    return to
end

function copyOldPropertyTo(from, to)
    for k,v in pairs(from) do
        if not to[k] then
            to[k] = v;
        end
    end

    return to
end

function getOne(t)
    for k,v in pairs(t) do
        return v, k
    end
    return nil;
end

function isEmpty(t)
    if t then
        for k,v in pairs(t) do
            return false
        end
    end
    return true
end

-- 只能用于数组,不能用于哈希,会新建一个table
function reverse(tab)
    local tmp = {}

    for i = 1, #tab do  
        local key = #tab  
        tmp[i] = table.remove(tab)  
    end

    return tmp  
end

function validateStringArray(strArray)
    local index = 1;
    local len = #strArray;
    while index <= len do
        if not StringUtil.isStringValid(strArray[index]) then
            table.remove(strArray, index);
            index = index - 1;
            len = len - 1;
        end

        index = index + 1;
    end

    return strArray
end


-- 遍历table是否包含某一个值
function IsInTable(value, tbl)
    for k,v in ipairs(tbl) do
        if v == value then
            return true;
        end
    end
    return false;
end