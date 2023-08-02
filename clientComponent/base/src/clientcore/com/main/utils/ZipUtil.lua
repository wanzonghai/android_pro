--
-- Author: senji
-- Date: 2017-02-23 17:50:01
--https://github.com/gdsgtcz/Zlib-Lua-C
ZipUtil = {}

local _zlib = nil;

local function try2LoadZlib()
	_zlib = require("zlib")
end

xpcall(try2LoadZlib, function()end)

function ZipUtil.isSuppoertZLib()
	return _zlib ~= nil;
end

function ZipUtil.compress(str)
	if _zlib then
		local compress = _zlib.deflate()
		str = compress(str, "finish")
		return str;
	end
end

function ZipUtil.uncompress(str)
	if _zlib then
	    local uncompress = _zlib.inflate()
	    local uss, ret, getin, getout = uncompress(str)
	    return uss;
	end
end

-- 多线程解压文件，注意路径都是绝对路径！！
-- onError，参数错误代码：
-- 1：can not open zip file
-- 2：can not read file global info
-- 3：can not read file info
-- 4：can not create directory
function ZipUtil.unzipFileInThread(zipAbsolutePath, destAbsoutePath, onSuccess, onError)
	OSUtil.createFolder(destAbsoutePath)
	SwManager_unzipFileInThread(zipAbsolutePath, destAbsoutePath, onSuccess, onError)
end