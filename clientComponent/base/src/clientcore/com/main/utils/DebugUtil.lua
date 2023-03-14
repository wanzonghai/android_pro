--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-6
-- Time: PM4:15
--
--DebugUtil = {};

echo = print

function traceLog_r(sth)
    DebugUtil.print_r(sth, traceLog);
end

function traceErrorLog(errorLog)
    if ProxyDebugLog then
        ProxyDebugLog:pushLog(errorLog, true);
    end

    print("[TRACE]" .. errorLog);
end

function traceLog(...)
    local txts = { ... };
    local result = "";
    for i, v in ipairs(txts) do
        result = result .. tostring(v);
        result = result .. "   "
    end

    if ProxyDebugLog then
        ProxyDebugLog:pushLog(result);
    end

    print("[TRACE]" .. result);
end

trace = traceLog;
trace_r = traceLog_r;

function print_r(sth, printFunc)
    printFunc = printFunc or print;
    local result = "";

    local function appendString(...)
        if result ~= "" then
            result = result .. "\n";
        end

        local strs = { ... }
        local len = #strs;
        for i = 1, len do
            result = result .. tostring(strs[i]);
            if i ~= len then
                result = result .. "   ";
            end
        end
    end

    if type(sth) ~= "table" then
        appendString(sth)
        printFunc(result)
        return
    end

    local cache = { [sth] = "<self>" }

    local space, deep = string.rep(' ', 2), 0
    local function _dump(pkey, t)

        for k, v in pairs(t) do
            local key
            if type(k) == 'number' then
                key = string.format("[%s]", k)
            else
                key = tostring(k)
            end

            if cache[v] then
                appendString(string.format("%s%s=%s,", string.rep(space, deep + 1), key, cache[v])) --appendString.
            elseif type(v) == "table" then
                deep = deep + 2
                cache[v] = string.format("%s.%s", pkey, key)
                appendString(string.format("%s%s=", string.rep(space, deep - 1), key)) --appendString.
                appendString(string.format("%s{", string.rep(space, deep))) --appendString.
                _dump(string.format("%s.%s", pkey, key), v)
                appendString(string.format("%s},", string.rep(space, deep)))
                deep = deep - 2
            else
                if type(v) == 'string' then
                    appendString(string.format("%s%s='%s',", string.rep(space, deep + 1), key, v)) --appendString.
                else
                    appendString(string.format("%s%s=%s,", string.rep(space, deep + 1), key, tostring(v))) --appendString.
                end
            end
        end
    end

    appendString(string.format("{"))
    _dump("<self>", sth)
    appendString(string.format("}"))

    printFunc(result)
end

DebugUtil = {}

function DebugUtil.printAllKVs(obj)
    local preStr = "-------kvs of-> " .. (obj.__cname or "no cname") .. " , " .. tostring(obj) .. "-------";
    print(preStr)
    if type(obj) ~= "userdata" then
        for k, v in pairs(obj) do
            print(tostring(k) .. " --- " .. tostring(v));
        end
    end
    print(string.rep("-", #preStr));
end


DebugUtil.enableMark = false
local _markTs = {}
local _mark = {}
function DebugUtil.beginMark(id)
    if DebugUtil.enableMark then
       _markTs[id] = os.clock();
    end
end

function DebugUtil.try2PrintMark(forcePrint)
    if DebugUtil.enableMark then
        local t = os.clock()
        if not _mark.printTime and not forcePrint then
            _mark.printTime = t;
        elseif forcePrint or t - _mark.printTime > 5 then
            local allPrintTxt = ""
            local toPrintTable = {}
            for k,v in pairs(_mark) do
                if type(v) == "table" and v.count then
                    v.__key = k;
                    table.insert(toPrintTable, v);
                end
            end


            local function sorter(a, b)
                return a.__key < b.__key
            end

            table.sort(toPrintTable, sorter)

            local function makeItWhite(num, testCost)
                if testCost and testCost < num then
                    return HtmlUtil.createOrangeTxt(num)
                else
                    return HtmlUtil.createWhiteTxt(num)
                end
            end
            
            for i,v in ipairs(toPrintTable) do
                local printTxt = "avg:" .. makeItWhite(fixFloat(v.cost / v.count, 7), 0.016) .." max:" .. makeItWhite(fixFloat(v.maxCost, 7), 0.016) .." min:" .. makeItWhite(fixFloat(v.minCost, 7), 0.016) .." count:"..makeItWhite(v.count) .." costT:"..makeItWhite(fixFloat(v.cost, 7)).. " key:".. HtmlUtil.createYellowTxt(v.__key);
                v.cost = nil;
                v.count = nil;
                allPrintTxt = allPrintTxt .. "\n" .. printTxt;
            end
            if allPrintTxt ~= "" then
                local header = --[[noi18n]]"api调用次数统计:"
                if _mark.printTime then
                    header = --[[noi18n]]header .. "，统计间隔:" .. fixFloat(t - _mark.printTime, 7)
                end
                traceLog(header .. allPrintTxt)
            end
            _mark.printTime = t;
        end
    end
end

function DebugUtil.traceStack()
    -- local function f()
    --     error("测试输出堆栈")
    -- end
    -- xpcall(f, tracebackex)
end

function DebugUtil.endMark(id)
    if DebugUtil.enableMark then
        if _markTs[id] then
            local cost = os.clock() - _markTs[id]
            local mark = _mark[id] or {};
            mark.cost = (mark.cost or 0) + cost;
            mark.costTotal = (mark.costTotal or 0) + cost
            mark.count = (mark.count or 0) + 1;
            mark.countTotal = (mark.countTotal or 0) + 1;
            mark.maxCost = math.max(cost, mark.maxCost or 0);
            mark.minCost = math.min(cost, mark.minCost or 100000);
            _mark[id] = mark
            _markTs[id] = nil;
        end
    end
end


function DebugUtil.traceback(bTrace)
    if bTrace then
        trace(debug.traceback())
    else
        print(debug.traceback())
    end
end

DebugUtil.print_r = print_r;



