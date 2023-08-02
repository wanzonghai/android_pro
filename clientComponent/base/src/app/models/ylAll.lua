ylAll = ylAll or {}

ylAll.WIDTH								    = 1920
ylAll.HEIGHT								= 1080

ylAll.MAX_INT                               = 2 ^ 15
ylAll.DEVICE_TYPE							= 0x10
--设备类型
ylAll.DEVICE_TYPE_LIST = {}
ylAll.DEVICE_TYPE_LIST[cc.PLATFORM_OS_WINDOWS] 	= 0x00
ylAll.DEVICE_TYPE_LIST[cc.PLATFORM_OS_ANDROID] 	= 0x11
ylAll.DEVICE_TYPE_LIST[cc.PLATFORM_OS_IPHONE] 	= 0x31
ylAll.DEVICE_TYPE_LIST[cc.PLATFORM_OS_IPAD] 	= 0x41

local poker_data = {
	0x00,
	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, -- 方块
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, -- 梅花
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, -- 红桃
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, -- 黑桃
    0x4E, 0x4F
}
-- 逻辑数值
ylAll.POKER_VALUE = {}
-- 逻辑花色
ylAll.POKER_COLOR = {}
-- 纹理花色
ylAll.CARD_COLOR = {}
-- 获取余数
function math.mod(a, b)
    return a - math.floor(a/b)*b
end
function ylAll.GET_POKER_VALUE()
	for k,v in pairs(poker_data) do
		ylAll.POKER_VALUE[v] = math.mod(v, 16)
		ylAll.POKER_COLOR[v] = bit:_and(v , 0XF0)
		ylAll.CARD_COLOR[v] = math.floor(v / 16)
	end
end
ylAll.GET_POKER_VALUE()

ylAll.QuitLayer                             = nil   --全局退游提示框
ylAll.touchTime                             = 0.5   --触摸最小间隔
ylAll.SERVER_UPDATE_DATA                    = {}        --zip版本号
ylAll.ipAddr                                = {}    
ylAll.NormalNetDelay                        = {}        --网络配置相关
ylAll.UPDATE_OPEN                           = true      --开启更新
ylAll.LOGONSERVER_LIST                      = {}       --ip             


local Localization   = cc.UserDefault:getInstance()
local ServerLocal = Localization:getStringForKey("ServerUrl","")
--热更地址配置
ylAll.HotfixUrl = {
    {
        "http://172.17.18.61/BrazilLocal/",                  --巴西金币项目(Truco Clube) A*本地
        "http://172.17.18.241:888/Brazil/",                   --巴西金币项目(Truco Clube) 内网(230)
        "https://down.happyday66.com/brazil_res/",            --巴西金币项目(Truco Clube) 外网(平行服)
        "https://down.9oeh2.com/brazil_res/",                 --巴西金币项目(Truco Clube) 外网(正式服)
    },
    {
        "http://172.17.18.61/ComponentLocal/",               --巴西真金项目(Truco King) A*本地
        "http://172.17.18.241:888/Component/",                --巴西真金项目(Truco King) 内网(230)
        "http://down2.gngqyxxk.com/brazil_res/",             --巴西真金项目(Truco King) 外网(平行服)
        "https://down2.upooldafs.com/brazil_res/",            --巴西真金项目(Truco King) 外网(正式服)
    },
}

--服务器地址配置
ylAll.ServerUrl = {
    {
        ServerLocal~="" and ServerLocal or "115@172.17.18.230:2701|1",                      --巴西金币项目(Truco Clube) 开发服
        "116@172.17.18.241:2701|1",                                                         --巴西金币项目(Truco Clube) 内网(230)
        "117@8.212.53.120:2701|1",                                                          --巴西金币项目(Truco Clube) 外网(平行服)--8.218.73.66
        "10@152.32.197.243:2701|1",                                                         --巴西金币项目(Truco Clube) 外网(正式服)
    },
    {
        ServerLocal~="" and ServerLocal or "215@172.17.18.181:2701|1",                        --巴西真金项目(Truco King) 开发服 暂未提供
        "216@172.17.18.241:2701|1",                                                          --巴西真金项目(Truco King) 内网   暂未提供
        "217@43.154.95.150:2701|1",                                                            --巴西真金项目(Truco King) 外网(平行服)
        "20@118.26.105.189:2701|1",                                                          --巴西真金项目(Truco King) 外网(正式服)
    },
}

local Localization   = cc.UserDefault:getInstance()
ylAll.LocalTest      = Localization:getBoolForKey("LocalTest",false)         --测试选择
ylAll.ProjectSelect  = ylAll.LocalTest and Localization:getIntegerForKey("ProjectSelect",2) or 2      --项目选择 (1:巴西金币项目(Truco Clube),2:巴西真金项目(Truco King))
ylAll.HotfixSelect   = ylAll.LocalTest and Localization:getIntegerForKey("HotfixSelect", 4) or 4      --热更选择 (1-4 四个环境选择,上线需要切换为4)
ylAll.ServerSelect   = ylAll.LocalTest and Localization:getIntegerForKey("ServerSelect", 4) or 4      --服务器选择 (1-4 四个环境选择,上线需要切换为4)

ylAll.Request_HttpUrl = ylAll.HotfixUrl[ylAll.ProjectSelect][ylAll.HotfixSelect]
local pServerUrl = ylAll.ServerUrl[ylAll.ProjectSelect][ylAll.ServerSelect]
local pArray = string.split(pServerUrl,"@")
ylAll.LOGONSERVER_LIST = {{id= pArray[1],ip= pArray[2]}}

ylAll.LogoList = {
    "base/res/welcome/logo.png",
    "base/res/welcome/logo_king.png",
}
ylAll.LogoType = ylAll.LogoList[ylAll.ProjectSelect]
