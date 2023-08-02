require("base.src.app.models.bit")
require("base.src.clientcore.com.main.utils.LogUtils")
require("base.src.app.models.AppDF")
cjson = require("cjson")

if device.platform ~= "windows" then
	cc.FileUtils:getInstance():addSearchPath(device.writablePath)

    cc.FileUtils:getInstance():addSearchPath(device.writablePath.."base/src/",true)
    cc.FileUtils:getInstance():addSearchPath(device.writablePath.."base/res/",true)
end

cc.FileUtils:getInstance():addSearchPath(device.writablePath.."client/res/")
--本地调试
LOCAL_DEVELOP = 0

--[[local p = device.writablePath 
local m_package_path = package.path
package.path = string.format("%s?.lua;%s?/init.lua;%s", p, p, m_package_path)]]

local Version = import(".models.Version")

local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    math.randomseed(os.time())
    --搜素路径添加
	cc.FileUtils:getInstance():addSearchPath(device.writablePath.."client/res/")
	cc.FileUtils:getInstance():addSearchPath(device.writablePath.."base/res/")
    cc.FileUtils:getInstance():addSearchPath(device.writablePath.."base/src/")
	--版本信息
	self._version = Version:create()
	--游戏信息
	self._gameList = {}
	--更新地址
	self._updateUrl = ""
	--初次启动获取的配置信息
	self._serverConfig = {}
end


function MyApp:getVersionMgr()
	return self._version
end

return MyApp
