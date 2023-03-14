-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-6
-- Time: PM5:02
--
--ClassUtil = {};

shengsmarkPrintSearch = false;

module("ClassUtil", package.seeall);
local function printDebugInSearchingSuper(msg, key)
    if shengsmarkPrintSearch then
        print(msg);
    end
end

local function searchSupers(key, obj)
    -- 下面这些注释能不开启就不开启，因为就算是函数里面判断为false不输出，也会导致性能下降很多
    -- printDebugInSearchingSuper("searching in __index : [key] " .. tostring(key) .. " , [obj] " .. tostring(obj) .. " [super num] " .. #obj.__supers,key);
    for i, superObj in ipairs(obj.__supers) do
        -- printDebugInSearchingSuper("searching in __index : [key] " .. tostring(key) .. " , [super] " .. tostring(superObj) .. " , [obj] " .. tostring(obj) .. " , [cname] " .. tostring(superObj.__cname),key);
        if superObj[key] then
            -- printDebugInSearchingSuper("found :[key] " .. tostring(key) .. " , [obj super] " .. tostring(superObj)..":"..tostring(superObj.__cname),key);
            return superObj[key];
        end
    end
    -- printDebugInSearchingSuper(" not found :[key] " .. tostring(key) .. " , [obj] " .. tostring(obj),key);
    return nil;
end

local function insertSupers(supers, classObj, index)
    if classObj and supers then
        if not table.indexof(supers, classObj) then
            if index then
                table.insert(supers, index, classObj);
            else
                table.insert(supers, classObj);
            end
        end
    end
end

--[[
-- 继承一个类最好用这个方法，支持多重继承，配合quick的class()来构建类再进行被继承，但是不建议用class(xxx,superClass)来继承，除非superClass是userData
-- 就算是单一继承最好也不要用class()方法，因为不会调用父类的ctor(...)
-- ... 是传给父类的参数列表
-- ]]
function extends(obj, classObj, callCtor, ...)
    assert(obj ~= nil, "why obj is nil?");
    assert(classObj ~= nil, "why classObj is nil?");

    local isUserData = type(obj) == "userdata";
    local checkObj;
    if isUserData then
        checkObj = tolua.getpeer(obj) or {};
        local checkObjMeta = getmetatable(checkObj);
        if checkObjMeta and not checkObj.__supers then
            checkObj.super = checkObjMeta.__index;
        end
        tolua.setpeer(obj, checkObj);
    else
        checkObj = obj;
    end
    local supers = checkObj.__supers;
    if checkObj.super == classObj or (supers and table.indexof(supers, classObj)) then
        return obj; --classObj为空或者已经继承过classObj的话，则不可以继续下去
    end

    if not supers then --之前没有用过这个api继承过别的
        supers = {};
        checkObj.__supers = supers;
        local metatable = getmetatable(checkObj);
        --先判断当前类
        if metatable then
            -- supers[1] = metatable;
            insertSupers(supers, metatable, 1)
        end
        metatable = {};
        --再判断父类
        if not checkObj.super then
            checkObj.super = classObj;
        else
            insertSupers(supers, checkObj.super, 1)
            -- table.insert(supers, 1, checkObj.super);
        end
        --设置metatable
        metatable.__index = function(selfObj, key)
            local result = searchSupers(key, selfObj)
            --shengsmark 优化，下面这里可以开启优化
            -- obj[key] = result;
            return result;
        end
        setmetatable(checkObj, metatable);
    end
    insertSupers(supers, classObj)

    -- table.insert(supers, classObj);
    if callCtor ~= false and classObj.ctor ~= nil then
        classObj.ctor(obj, ...);
    end

    return obj;
end

-- 是否这个类的实例
-- 包括多层继承
function is(obj, clazz)
    if obj == nil or clazz == nil or (type(obj) ~= "table" and type(obj) ~= "userdata") then
        return false;
    end

    if type(obj) == "userdata" then
        if "class " .. tolua.type(obj) == tolua.type(clazz) then --userdata的比较，简单得Cocos2dx的类
            return true;
        else
            obj = tolua.getpeer(obj);
            if obj == nil then
                return false;
            end
        end
    end
    if obj.class == clazz then
        return true;
    end

    if obj.class and obj.class.super == clazz then
        return true;
    end

    local supers = obj.__supers;
    if supers then
        for k, superClass in pairs(supers) do
            if superClass == clazz or superClass.super == clazz then
                return true;
            end
        end
    end
    return false;
end



function printSupers(obj)
    print("----输出父类开始：")
    for i, v in ipairs(obj.__supers) do
        print(v.__cname, tostring(v));
    end
    print("----输出父类结束")
end
