--对象池
local ObjectPool = class("ObjectPool")

function ObjectPool:ctor(_factoryFunc)
    self.objects = {}
    self.freeObjects = {}
    self.factoryFunc = _factoryFunc
end

function ObjectPool:findFreeObject(func)
    if #self.freeObjects > 0 then
  
        local function removeFreeObject(i)
            local  t = self.freeObjects[i]
            table.remove(self.freeObjects , i)
            table.insert(self.objects , t)
            return t
        end

        if func then
            for i=#self.freeObjects,1,-1 do
                if func(self.freeObjects[i]) == true then
                    return removeFreeObject(i)
                end
            end
        else
            return removeFreeObject(1)
        end
        return t
    end
    return nil
end

function ObjectPool:getObject(func, ...)
    local t = self:findFreeObject(func)     
    if (t == nil) then
        t = self.factoryFunc(...)
        table.insert(self.objects , t)
    end
    return t
end
    
function ObjectPool:returnObject(t)
    if t.reset then t:reset() end
    for i=#self.objects , 1 , -1 do
        if self.objects[i] == t then
            table.remove(self.objects, i)
            table.insert(self.freeObjects , t)
            break
        end
    end
end
    
function ObjectPool:clearTable(tb,release,remove)
    for i=#tb , 1 , -1 do
        local t = tb[i]
        table.remove(tb, i)
        if remove then
            t:removeSelf()
        end
        if release then
            t:release()
        end
    end
end
    
function ObjectPool:clearObjectPool(release)
    self:clearTable(self.objects,release, true)
    self:clearTable(self.freeObjects,release)
end

function ObjectPool:releaseFreeObject()
    self:clearTable(self.freeObjects,true)
end

function ObjectPool:getObjectCount()
    return #self.objects , #self.freeObjects
end

function ObjectPool:foreachObject(func)
    for i=1 , #self.objects do
        func(self.objects[i])
    end
end

return ObjectPool