
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- -- for module display
-- CC_DESIGN_RESOLUTION = {
--     width = 2340,--1136,
--     height = 1080,--640,
--     autoscale = "FIXED_HEIGHT",
-- 	--[[
--     callback = function(framesize)
--         local ratio = framesize.width / framesize.height
--         if ratio <= 1.34 then
--             -- iPad 768*1024(1536*2048) is 4:3 screen
--             return {autoscale = "FIXED_WIDTH"}
--         end
--     end
-- 	]]--
-- }
--是否开启渠道获取
CHANNEL_OPEN = true
--是否开启通知
NOTIFICATION_OPEN = true
--是否网络优化
NET_OPTIMIZE_OPEN = true
--是否网络二次优化
NET_SECOND_OPTIMIZE_OPEN = true
--是否可以截图保存到相册
CAN_CAPTURE_CAMEAR = true
--是否是白名单
IS_WHITE_LIST = false
--是否支持定时通知
ALARM_NOTIFICATION_OPEN = true
--是否支持横竖版切换
CHANGE_ORIENTATION_OPEN =  true
--更新修改
HOTFIX_UPGRADATION = true

FunctionName = {
    getUUID = "getUUID",
    getHostAdress = "getHostAdress",
    getSDCardDocPath = "getSDCardDocPath",
    pickImg = "pickImg",
    thirdPartyConfig = "thirdPartyConfig",
    SetWxAccessTokenOpenID = "SetWxAccessTokenOpenID",
    thirdLogin = "thirdLogin",
    startShare = "startShare",
    customShare = "customShare",
    shareToTarget = "shareToTarget",
    thirdPartyPay = "thirdPartyPay",
    OpenThirdUrl = "OpenThirdUrl",
    isPlatformInstalled = "isPlatformInstalled",
    jumpTo3rdApp = "jumpTo3rdApp",
    saveImgToSystemGallery = "saveImgToSystemGallery",
    isHaveRecordPermission = "isHaveRecordPermission",
    requestLocation = "requestLocation",
    metersBetweenLocation = "metersBetweenLocation",
    requestContact = "requestContact",
    openBrowser = "openBrowser",
    copyToClipboard = "copyToClipboard",
    GoogleLogin = "GoogleLogin",
    FaceBookLogin = "FaceBookLogin",
    mobShare = "mobShare",
    getChannelId = "getChannelId",
    PushNotification = "PushNotification",
    PushImageNotification = "PushImageNotification",
    SetAlarmNotification = "SetAlarmNotification",
    ChangeOrientation = "ChangeOrientation",

    getAFID = "getAfId",
    appsFlyerEvent= "appsFlyerEvent",

    adjustLogEvent = "adjustLogEvent",
    getAdjustId = "getAdid",
    getAdjustGoogleAdId = "getGoogleAdid",
    getAdjustKey = "getAdjustKey",
    getAdjustStatus = "getAdjustStatus",
    getAdjustAttribution = "getAdjustAttribution",
    getFireBaseToken = "getFireBaseToken",
}

BridgeClassName = {
    BRIDGE_CLASS_ACTIVITY = "org/cocos2dx/lua/LooqzlGoodGameActivity",
    BRIDGE_CLASS_AF = "truco/three/afsdk/AfSdk",
    BRIDGE_CLASS_ADJUST = "truco/three/adjustsdk/AdjustSdk",
    BRIDGE_CLASS_FIREBASE = "truco/three/firebasesdk/LooqzlFirebaseMessagingService",
}

getThreeDataJson = function()
    if cc.FileUtils:getInstance():isFileExist("base/threeSdkSwitch.json") then
        local josn = cc.FileUtils:getInstance():getStringFromFile("base/threeSdkSwitch.json")
        return cjson.decode(josn)
    else
        return {}
    end
end

ChannelData = function()
    if cc.FileUtils:getInstance():isFileExist("base/ChannelConfig.json") then
        local josn = cc.FileUtils:getInstance():getStringFromFile("base/ChannelConfig.json")
        return cjson.decode(josn)
    else
        return {}
    end
end

AfLogEventName = {
    af_login = "af_login",
    af_revenue = "af_purchase", 
}

ADLogEventName = {
    ad_login = "kd9t6r",
    ad_revenue = "wdhbzm", 
    ad_firstRevenue = "ijq74u", 
    ad_open = "blcusu",--应用打开 唯一
    ad_register = "rmgz1o",--注册 非唯一
}

CC_DESIGN_RESOLUTION = {
    width = 1920,--1136,
    height = 1080,--640,
    autoscale = "FIXED_WIDTH",
	
    callback = function(framesize)
        -- local ratio = framesize.width / framesize.height
        local ratio = framesize.width / framesize.height
        if ratio < 1920 / 1080 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "FIXED_WIDTH"}
        else
            return {autoscale = "FIXED_HEIGHT"}
        end
    end
}

OFFICIAL_LOGIN = true

VERSION_INIT_ZIP_BASE = 2
VERSION_INIT_ZIP_CLIENT = 2