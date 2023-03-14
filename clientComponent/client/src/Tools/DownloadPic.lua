
local M = class("M")


function M:ctor()--创建NetSprite  
    self.rootPath = device.writablePath.."downloadpic/" --获取本地存储目录
    self.presistedPath = device.writablePath.."presistedpic/" --获取本地持久化存储目录

    --每次登录清空非持久化目录
    if OSUtil.isFolderExists(self.rootPath) then
        OSUtil.deleteDirectory(self.rootPath)
    end
    OSUtil.createFolder(self.rootPath)

    --判断本地持久化目录
    if not OSUtil.isFolderExists(self.presistedPath) then
        OSUtil.createFolder(self.presistedPath)
    end
end

--获取文件名称
function M:getFileName(url)
    local path = string.reverse(url)
    local fileName = string.sub(path, 0, string.find(path,"/")-1)
    return string.reverse(fileName)
end

--判断当前文件是否存在
function M:isFileNamePath(fileName)
    local result = nil    
    if io.exists(self.rootPath..fileName..".png") then
        result = self.rootPath..fileName..".png"
    end
    if io.exists(self.presistedPath..fileName..".png") then
        result = self.presistedPath..fileName..".png"
    end
    return result
end

-- function M:fileNamePath(fileName)
--     if fileName then
--         if io.exists(self.rootPath .. fileName) then
--             return self.rootPath .. fileName
--         end
--         if io.exists(self.presistedPath .. fileName) then
--             return self.presistedPath .. fileName
--         end
--     end
--     return nil
-- end
--[[
下载网络图片
]]
function M:downloadNetPic(url, _fileName, callback,isPresisted)
        assert(url,"invalid url")
        local time = 10

        local path = self.rootPath .. _fileName..".png"
        if isPresisted then
            path = self.presistedPath .. _fileName..".png"
        end
        --判断图片是否存在
        if io.exists(path) then
            if callback then callback(true,path) end
            return
        end
        local schdule = cc.Director:getInstance():getScheduler()
        
        --开始请求
        local xhr = cc.XMLHttpRequest:new()-- 新建一个XMLHttpRequest对象
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING -- 返回字符串类型
        -- xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER -- 返回字节数组类型
        xhr:open("GET", url)
        xhr.timeout = time
        
        --超时请求
        local funcID = nil
        --设置请求是否超时
        local function timeoutOrError ()
            schdule:unscheduleScriptEntry(funcID)
            xhr:abort()     --取消正在进行的HTTP请求
            if callback then callback(false) end
        end
        funcID = schdule:scheduleScriptFunc(timeoutOrError, time, false)
        
        local function onReadyStateChange()
            schdule:unscheduleScriptEntry(funcID)
            print("readyState:", xhr.readyState, "   status:", xhr.status)
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                -- if not cc.FileUtils:getInstance():isDirectoryExist(self.rootPath) then                    
                    -- cc.FileUtils:getInstance():createDirectory(self.rootPath)
                -- end
                local file = assert(io.open(path, "wb"))
                file:write(xhr.response)
                file:close()
                if callback then callback(true,path) end
            else
                --图片下载失败
                if callback then callback(false) end
            end
        end
        -- 注册脚本方法回调
        xhr:registerScriptHandler(onReadyStateChange)
        xhr:send()-- 发送
end

DownloadPic = M.new()