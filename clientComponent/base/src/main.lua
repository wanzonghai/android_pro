-- VS Code LuaIDE
local breakSocketHandle,debugXpCall = require("LuaDebugjit")("localhost",7003) 
cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakSocketHandle, 0.3, false)

cc.FileUtils:getInstance():setPopupNotify(false)

cc.FileUtils:getInstance():addSearchPath("base/src/")
cc.FileUtils:getInstance():addSearchPath("base/res/")

local isTestWin = true
if isTestWin then
   cc.FileUtils:getInstance():addSearchPath("client/src/")
   cc.FileUtils:getInstance():addSearchPath("client/res/")   
end
local p = cc.FileUtils:getInstance():getWritablePath()
cc.FileUtils:getInstance():addSearchPath(p)   
local m_package_path = package.path
package.path = string.format("./?.lua;%s?.lua;%s?/init.lua;%s", p, p, m_package_path)


require "config"
require "cocos.init"

local function main()
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    require("app.MyApp"):create():run()
end
local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

