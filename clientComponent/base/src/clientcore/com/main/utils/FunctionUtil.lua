--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-10
-- Time: 上午1:00
--
requireClientCoreMain("utils.TableUtil")

-- 空函数
function __emptyFunction()
end

--FunctionUtil = {};

function handlerWithParams(target, method, paramsTable2Append)
    if paramsTable2Append then
        return function(...)
            local newParams = TableUtil.concat({ ... }, paramsTable2Append);
            if target then
                return method(target, unpack(newParams));
            else
                return method(unpack(newParams));
            end
        end
    else
        return function(...)
            if target then
                return method(target, ...);
            else
                return method(...);
            end
        end
    end
end


-- 注意：第一个参数selfObj最好传入实例self
-- 创建的函数有：
-- 1.setter
-- 2.getter
-- 3.还有一个增减的函数adder（默认不创建）
-- 4.setterChangedHandler setter改变的时候的回调

-- createSetterGetter(self,"gold",100,true)会进行以下创建操作
-- self._gold = 100;
-- self.getGold()
-- self.setGold(value)
-- self.addGold(addValue)(默认不创建，仅对数值有效)
-- 如果hasSignal为true，则
-- self.goldChangedSignal = SignalAs3.new()
-- 并且setter改变时会发出事件

-- 2015年09月11日10:56:34 增加了：
-- setterChangedHandlerName 这个值是一个函数名， 跟setterChangedHandler不冲突，
-- 这个值的优点是可以对这个函数进行外部重写（不是继承重写）
-- 缺点是必须是self持有的函数名，不是类
function createSetterGetter(selfObj, varName, defaultValue, hasSignal, noSetter, noGetter, withAdder, setterChangedHandler, setterChangedHandlerName)
    assert(selfObj ~= nil, "why selfobj is nil?")
    local firstChar = string.sub(varName, 1, 1)
    local nameUpper1 = string.upper(firstChar) .. string.sub(varName, 2);
    local nameLower1 = string.lower(firstChar) .. string.sub(varName, 2);
    local propertyName = "_" .. nameLower1;
    local signalName = nil;
    if hasSignal then
        --创建signal
        signalName = nameLower1 .. "ChangedSignal";
        selfObj[signalName] = SignalAs3.new((selfObj.__cname or "") .. "-" .. signalName);
    end

    --检查是不是创建defaultValue为signal的setter和getter
    if type(defaultValue) == "table" and defaultValue.__cname == "SignalAs3" then
        defaultValue._traceName = (selfObj.__cname or tostring(selfObj)) .. "_" .. varName;
    end
    --默认值的设置
    selfObj[propertyName] = defaultValue;

    if not noSetter then
        --创建setter
        selfObj["set" .. nameUpper1] = function(selfParam, value, force, forbidSignal)
            local isForceSetter = (type(value) == "table" or type(value) == "userdata") and value.__forceSetter;
            if isForceSetter or selfParam[propertyName] ~= value or force then
                selfParam[propertyName] = value;
                if setterChangedHandler then
                    setterChangedHandler();
                end
                if setterChangedHandlerName and type(selfObj[setterChangedHandlerName]) == "function" then
                    selfObj[setterChangedHandlerName](selfObj)
                end
                if hasSignal and not forbidSignal then
                    selfParam[signalName]:emit(value);
                end
                if isForceSetter then
                    value.__forceSetter = nil;
                end
            end
        end
    end

    if not noGetter then
        --创建getter
        selfObj["get" .. nameUpper1] = function(selfParam, value)
            return selfParam[propertyName];
        end
    end

    if withAdder then
        --创建adder，数值增加的函数（仅对数值有效），不调用setter，因为担心noSetter为true
        selfObj["add" .. nameUpper1] = function(selfParam, value, force, forbidSignal)
            value = value + selfParam[propertyName];
            if selfParam[propertyName] ~= value or force then
                selfParam[propertyName] = value;
                if hasSignal and not forbidSignal then
                    selfParam[signalName]:emit(value);
                end
            end
        end
    end
end

-- 把某个界面的visible与model的某个变量绑定起来
-- 用法
-- bindModelShowing(self.layerBattle, self.model, "isShowingBattle")
-- @params isValueOpposed 是否属性相反
function bindModelShowing(view, model, modelShowingProperty, isValueOpposed, onChangedCallback)
    local nameUpper1 = StringUtil.upperFirstChar(modelShowingProperty)
    local getterName = "get" .. nameUpper1
    local signal = model[modelShowingProperty .. "ChangedSignal"];
    local function onShowingChanged()
        local b = model[getterName](model)
        if isValueOpposed then
            b = not b;
        end
        DisplayUtil.setVisible(view, b);
        if onChangedCallback then
            onChangedCallback(b)
        end
    end
    signal:add(onShowingChanged)

    view.__bindShowingChangeFuc = onShowingChanged
    view.__bindShowingSignal = signal

    onShowingChanged()
end

-- 用bindModelShowing绑定过，解绑时的函数
function unbindModelShowing(view)
    if view.__bindShowingSignal and view.__bindShowingChangeFuc then
        view.__bindShowingSignal:remove(view.__bindShowingChangeFuc)
        view.__bindShowingSignal = nil;
        view.__bindShowingChangeFuc = nil;
    end
end

-- 自动创建setter，getter， signal，而changehandler可选
function createSetterGetterHandler(selfObj, varName, defaultValue, setterChangedHandler)
    createSetterGetter(selfObj, varName, defaultValue, true, false, false, false, setterChangedHandler);
end

-- 自动创建setter和getter，而adder，changer和signal可选
function createReadWrite(selfObj, varName, defaultValue, hasSignal, withAdder, setterChangedHandler)
    createSetterGetter(selfObj, varName, defaultValue, hasSignal, false, false, withAdder, setterChangedHandler)
end

function applyFunctionWithScope(scope, func, ...)
    if func then
        if scope then
            func(scope, ...);
        else
            func(...);
        end
    end
end

function destroySomeObj(obj)
    if obj and obj.destroy then
        obj:destroy();
    end
end

function destroySomeObjByName(objParent, objName)
    local obj = objParent[objName];
    if obj and obj.destroy then
        obj:destroy();
        objParent[objName] = nil;
    end
end

function applyFunction(func, params)
    if func then
        if params then
            func(unpack(params));--pack和unpack会丢失nil的值
        else
            func()
        end
    end
end

function applyFunction2(func, ...)
    if func then
        func(...)
    end
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