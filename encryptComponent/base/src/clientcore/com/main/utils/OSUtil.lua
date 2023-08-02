--
-- Author: senji
-- Date: 2014-10-19 15:04:02
--
OSUtil = {};

function OSUtil.deleteDirectory(path)
    -- os.execute("rm -rf " .. path)
    if string.sub(path, #path) ~= "/" then
        path = path .. "/"
    end
    return cc.FileUtils:getInstance():removeDirectory(path);
end

function OSUtil.isFileExists(url)
    return cc.FileUtils:getInstance():isFileExist(url)
end

function OSUtil.isFolderExists(url)
    return cc.FileUtils:getInstance():isDirectoryExist(url)
end

function OSUtil.openURL(url)
    cc.Application:getInstance():openURL(url)
end

function OSUtil.copyFolder2(fromUrl, toUrl)
    local cmd = string.format("cp -R %s %s", fromUrl, toUrl)
    OSUtil.createFolder(toUrl)
    os.execute(cmd)
    print("执行指令", cmd)
end

function OSUtil.copyFile2(fromUrl, toUrl)
    local content = io.readfile(fromUrl)
    OSUtil.writefile(toUrl, content);
end

function OSUtil.deleteFile(path)
    io.deleteFile(path);
end

-- 删除文件（不是文件夹）
function io.deleteFile(path)
    return cc.FileUtils:getInstance():removeFile(path);
    -- os.execute("rm " .. path);
end 

-- 递归循环创建文件夹，不像lfs.mkdir那样只能一层一层创建
function OSUtil.createFolder(path)
    -- return os.execute("mkdir -p " .. path)
    return cc.FileUtils:getInstance():createDirectory(path);
end

-- 写文件，不存在则创建，包括自动创建层级目录
function OSUtil.writefile(path, content, mode)

    io.deleteFile(path) -- Tanhua 由于混淆资源模式打包会生成文件软链接，直接写入会链到原始文件，但是原始文件在包内所以没有权限，造成写入失败，顾先删除再写入

    mode = mode or "w+b"
    local parentPath = string.gsub(path, "%/[^%/]+$", "");
    OSUtil.createFolder(parentPath);
    local file, msg = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end


function OSUtil.saveTableContent(file, obj)
    local szType = type(obj)
    if szType == "number" then
        file:write(obj)
    elseif szType == "string" then
        file:write(string.format("%q", obj))
    elseif szType == "table" then
        --把table的内容格式化写入文件
        file:write("{\n")
        for i, v in pairs(obj) do
            file:write("[")
            OSUtil.saveTableContent(file, i)
            file:write("]=\n")
            OSUtil.saveTableContent(file, v)
            file:write(", \n")
        end
        file:write("}\n")
    else
        error("can't serialize a " .. szType)
    end
end
--写文件
function OSUtil.saveTable(data,fileName)
    if type(data) ~= "table" then
        return
    end

    local pathName = md5(fileName..GlobalUserItem.dwGameID)
    local path = string.format("%s/%s",device.tempWritablePath,pathName)
    local file = io.open(path, "wb")
    assert(file)
    file:write("return \n")
    OSUtil.saveTableContent(file, data)
    file:close()
end

function OSUtil.isFileNamePath(path)
    if io.exists(path) then
        return true
    else
        return false
    end
end

--读
function OSUtil.readFiles(fileName)
    local readTable = nil
    local pathName = md5(fileName..GlobalUserItem.dwGameID)
    local path = string.format("%s/%s",device.tempWritablePath,pathName)
    if OSUtil.isFileNamePath(path) then
        package.loaded[device.tempFolder..device.directorySeparator..pathName] = nil
        readTable = require(device.tempFolder..device.directorySeparator..pathName)
    end
    return readTable
end