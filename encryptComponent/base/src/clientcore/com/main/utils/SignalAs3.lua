--[[
signal.lua
Copyright (c) 2011 Josh Tynjala
Released under the MIT license.

Based on as3-signals by Robert Penner
http://github.com/robertpenner/as3-signals
Copyright (c) 2009 Robert Penner
Released under the MIT license.
]] --




-- 目前有一个bug：要注意了！！
-- signal:add(a.saya, a)
-- signal:add(b.sayb, b)
-- signal:emit()
-- function a.saya()
--     ﻿signal:remove(b.sayb, b)--b.sayb还是会触发。。。。。。
-- end
-- 



-- 2016年06月20日22:06:08 by senji
-- 优化了一下signal，去掉add 和 remove时的遍历，特别在批量add 和 remove时性能提升效果比较理想

SignalAs3 = class_quick("SignalAs3");

local m_isDebug = false;
local m_debugInfos = {};

function SignalAs3:ctor(traceName)
    self._traceName = traceName or " noNameSignal";
    self._listenersDic = {} -- key 是getKey出来的字符串， value是listener
    self._oneTimeListenersDic = {} -- key 是getKey出来的字符串， value是listener 

    self._emitListenersArr = nil;

    self._numListeners = 0;
    self._numOneTimeListeners = 0;

    self._newIndex = 0;
end

function SignalAs3:isEmpty()
    return self._numListeners <= 0;
end

function SignalAs3:getListener(func, scope)
    local key = SignalAs3.getKey(func, scope);
    local listener = self._listenersDic[key];
    local isNew = false;
    if not listener then
        self._newIndex = self._newIndex + 1;
        isNew = true;
        listener = {func = func, scope = scope, key = key, index = self._newIndex};
    end
    return listener, isNew
end

function SignalAs3:add(func, scope)
    if func == nil then
        error("Function passed to signal:add() must not non-nil.")
    end
    local listener, isNew = self:getListener(func, scope)
    if isNew then
        self._listenersDic[listener.key] = listener;
        self._numListeners = self._numListeners + 1;
        if self._emitListenersArr then
            table.insert(self._emitListenersArr, listener)
            -- self._emitListenersArr = nil;--目前不需要把这个置空，因为还没有优先级的说法，直接上面代码insert则可
        end
    else
        listener = nil;
    end

    return listener
end

function SignalAs3:addOnce(func, scope)
    local listener = self:add(func, scope)
    if listener then
        self._oneTimeListenersDic[listener.key] = listener
        self._numOneTimeListeners = self._numOneTimeListeners + 1;
    end
    return listener
end

function SignalAs3:emit(...)
    if self._numListeners <= 0 then
        return;
    end

    local t = nil;
    local emitNum = nil;
    if m_isDebug then
        t = os.clock()
        emitNum = self._numListeners;
    end
    if self._numListeners == 1 then
        local listener = SignalAs3.getOne(self._listenersDic);
        if listener.scope then
            listener.func(listener.scope, ...)
        else
            listener.func(...)
        end
    else
        if not self._emitListenersArr then
            self._emitListenersArr = SignalAs3.toArray(self._listenersDic);
            table.sort(self._emitListenersArr, SignalAs3.listenerSorter);
        end
        for i, listener in ipairs(self._emitListenersArr) do
            if listener.scope then
                listener.func(listener.scope, ...)
            else
                listener.func(...)
            end
        end
    end

    if self._numOneTimeListeners > 0 then
        for key, listener in pairs(self._oneTimeListenersDic) do
            self:remove(listener)
        end
    end

    if m_isDebug then
        local cost = os.clock() - t;
        local info = m_debugInfos[self._traceName]
        if not info then
            info = {}
            info.key = self._traceName
            m_debugInfos[self._traceName] = info;
        end
        info.callTotal = (info.callTotal or 0) + 1;
        info.costTotal = (info.costTotal or 0) + cost;
        info.maxCost = math.max(info.maxCost or 0, cost);
        info.minCost = math.min(info.minCost or 1000000000, cost);

        info.emitNumTotal = (info.emitNumTotal or 0) + emitNum;
        info.maxEmitNum = math.max(info.maxEmitNum or 0, emitNum);
        info.minEmitNum = math.min(info.minEmitNum or 1000000000, emitNum);

    end
end

function SignalAs3:remove(func, scope)
    if not func then
        return;
    end
    local listener = nil;
    if type(func) == "function" then
        listener = self:getListener(func, scope);
    else
        listener = func
    end
    local isContains = self._listenersDic[listener.key] ~= nil;
    if isContains then
        self._listenersDic[listener.key] = nil;
        self._numListeners = self._numListeners - 1
        self._listenersDic[listener.key] = nil;

        if self._oneTimeListenersDic[listener.key] then
            self._oneTimeListenersDic[listener.key] = nil;
            self._numOneTimeListeners = self._numOneTimeListeners - 1;
        end
        self._emitListenersArr = nil;
    end
end

function SignalAs3:removeAll()
    self._listenersDic = {}
    self._oneTimeListenersDic = {}
    self._numListeners = 0;
    self._numOneTimeListeners = 0;

    self._emitListenersArr = nil;

    self._newIndex = 0;
end

-- 清除这个对象上面的所有SignalAs3的事件绑定
function SignalAs3.clearAllSignal(obj)
    for k, v in pairs(obj) do
        if type(v) == "table" and v.__cname == "SignalAs3" then
            if _enableClearLog then
                print("清空signal", k)
            end
            v:removeAll();
        end
    end
end


function SignalAs3.toArray(dic)
    local result = {}
    local i = 1;
    for k,v in pairs(dic) do
        result[i] = v;
        i = i + 1;
    end

    return result;
end

function SignalAs3.getOne(listeners)
    for k,v in pairs(listeners) do
        return v;
    end
    return nil;
end

function SignalAs3.listenerSorter(a, b)
    return a.index < b.index;
end

function SignalAs3.getKey(func, scope)
    return tostring(func) .. "|" .. tostring(scope)
end


function SignalAs3.getIsDebug()
    return m_isDebug
end

function SignalAs3.setIsDebug(b)
    if m_isDebug ~= b then
        m_isDebug = b;
        m_debugInfos = {}
    end
end

function SignalAs3.printDebugInfo()
    if m_isDebug and traceLog then
        local floatBit = 7; --小数位多少位
        local function green(str)
            return '<font color = "#00FF00">' .. str .. '</font>'
        end

        local function orange(str)
            return '<font color = "#FFA500">' .. str .. '</font>'
        end
        
        local function white(str)
            return '<font color = "#FFFFFF">' .. str .. '</font>'
        end

        local function fixFloat(value, n, state)
            n = math.pow(10, n or 2);
            if state == 1 then
                return math.round(value * n) / n
            elseif state == 2 then
                return math.ceil(value * n) / n
            else
                return math.floor(value * n) / n
            end
        end

        local function keySorter(a, b)
            return a.key < b.key;
        end

        local content = ""

        local count = 0;
        local printArr ={}
        for key, vo in pairs(m_debugInfos) do
            if type(vo) == "table" and vo.costTotal then
                table.insert(printArr, vo)
            end
        end
        table.sort(printArr, keySorter)
        for i, vo in ipairs(printArr) do
            content = content .. "\n" .. vo.key
            local avg = fixFloat(vo.costTotal / vo.callTotal, floatBit);
            local eavg = fixFloat(vo.emitNumTotal / vo.callTotal, floatBit);
            local infoStr = 
                green("\navg:") .. avg .. 
                green(", max:") .. fixFloat(vo.maxCost, floatBit) .. 
                green(", min:") .. fixFloat(vo.minCost, floatBit) .. 
                green(", eAvg:") .. eavg .. 
                green(", eMax:") .. fixFloat(vo.maxEmitNum, floatBit) .. 
                green(", eMin:") .. fixFloat(vo.minEmitNum, floatBit) .. 
                green(", call:") .. vo.callTotal .. 
                green(", cost:") .. fixFloat(vo.costTotal, floatBit);
            content = content .. white(infoStr);
            count = count + 1;
        end

        if content ~= "" then
            traceLog("SgianlAs3调试：" .. orange(content) .. "\n")
        end

        m_debugInfos = {};
    end
end