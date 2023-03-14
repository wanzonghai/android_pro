
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0

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
CHANNEL_OPEN = true

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
    BRIDGE_CLASS_ACTIVITY = "game/tgm/AppTMGActivity",
    BRIDGE_CLASS_AF = "truco/three/afsdk/AfSdk",
    BRIDGE_CLASS_ADJUST = "truco/three/adjustsdk/AdjustSdk",
    BRIDGE_CLASS_FIREBASE = "truco/three/firebasesdk/MyFirebaseMessagingService",
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
    ad_login = "ofre9f",
    ad_revenue = "siapc3", 
    ad_firstRevenue = "jv7z6s", 
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

