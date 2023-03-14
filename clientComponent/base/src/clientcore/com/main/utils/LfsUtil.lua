--
-- Author: gong
-- Date: 2017-08-10 19:38:58
--

LfsUtil = {};
local function requireLfs()
    require"lfs"
end
xpcall(requireLfs, __emptyFunction)--由于lfs是需要自己绑定的第三方库（cocos没有整合），所以不希望客户护短在require lfs时会卡死游戏进度，需要xpcall来执行

-- 获取目录下文件列表
-- path 绝对路径目录
-- extension 扩展名 如 ".lua" 或者 nil
-- isRecursion 是否递归目录
function LfsUtil.getFileListInFolder(path, extension, isRecursion, _fileList)
    _fileList = _fileList or {}
    local fileUtils = cc.FileUtils:getInstance()
    for fileName in lfs.dir(path) do
        if fileName ~= "." and fileName ~= ".." then
            local file = path..'/'..fileName
            local attr = lfs.attributes (file)
            if attr then
                if attr.mode == "directory" then
                    if isRecursion then
                        LfsUtil.getFileListInFolderByExtension(file, extension, isRecursion, _fileList)
                    end
                elseif attr.mode == "file" then
                    if extension then
                        if fileUtils:getFileExtension(fileName) == extension then
                            table.insert(_fileList, file)
                        end
                    else
                        table.insert(_fileList, file)
                    end
                end
            end
        end
    end
    return _fileList
end

-- 目录下文件回调函数
-- path 绝对路径目录
-- extension 扩展名 如 ".lua" 或者 nil
-- isRecursion 是否递归目录
-- fun 回调接口 fun(fileName) 当返回true时停止迭代
function LfsUtil.fileInFolderRun(path, extension, isRecursion, fun)
    local fileUtils = cc.FileUtils:getInstance()
    for fileName in lfs.dir(path) do
        if fileName ~= "." and fileName ~= ".." then
            local file = path..'/'..fileName
            local attr = lfs.attributes (file)
            if attr then
                if attr.mode == "directory" then
                    if isRecursion then
                        if LfsUtil.fileInFolderRun(file, extension, isRecursion, fun) then
                            return true
                        end
                    end
                elseif attr.mode == "file" then
                    if extension then
                        if fileUtils:getFileExtension(fileName) == extension then
                            if fun(file) then
                                return true
                            end
                        end
                    else
                        if fun(file) then
                            return true
                        end
                    end
                end
            end
        end
    end
end