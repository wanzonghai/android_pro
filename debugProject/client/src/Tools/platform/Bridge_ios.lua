--
-- Author: zhong
-- Date: 2016-07-29 17:45:46
--
local Bridge_ios = {}

local luaoc = require "cocos.cocos2d.luaoc"
local BRIDGE_CLASS = "AppController"

--获取设备id
function Bridge_ios.getMachineId()
    local machineID = cc.UserDefault:getInstance():getStringForKey("MachineID_iOS","")
    if machineID ~= "" then
        print("Local File Save MachineID = ",machineID)
    else
        local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"getUUID")
        if not ok then
            print("luaj error:" .. ret)
            machineID = "A501164B366ECFC9E249163873094D50"
        else
            print("The ret is:" .. ret)
            machineID = md5(ret)
            cc.UserDefault:getInstance():setStringForKey("MachineID_iOS",machineID)
            cc.UserDefault:getInstance():flush()
        end
    end
    return machineID
end

--获取设备ip
function Bridge_ios.getClientIpAdress()
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"getHostAdress")
    if not ok then
        print("luaj error:" .. ret)
        return "127.0.0.1"
    else
        print("The ret is:" .. ret)
        return ret
    end
end

--选择图片
function Bridge_ios.triggerPickImg( callback, needClip )
	needClip = needClip or false
    local args = { scriptHandler = callback, needClip = needClip }
    if nil == callback or type(callback) ~= "function" then
        print("user default callback fun")

        local function callbackLua(param)
            if type(param) == "string" then
                print(param)
            end        
        end
        args = { scriptHandler = callback, needClip = needClip }
    end    
    
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"pickImg",args)
    if not ok then
        print("luaoc error:" .. ret)       
    end
end

--配置支付、登陆相关
function Bridge_ios.thirdPartyConfig(thirdparty, configTab)
    configTab._nidx = thirdparty
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"thirdPartyConfig",configTab)
    if not ok then
        print("luaoc error:" .. ret)        
    end
end

function Bridge_ios.configSocial(socialTab)
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"socialShareConfig",socialTab)
    if not ok then
        print("luaoc error:" .. ret)        
    end
end

--第三方登陆
function Bridge_ios.thirdPartyLogin(thirdparty, callback)
    local args = { _nidx = thirdparty, scriptHandler = callback }
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"thirdLogin",args)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end
--获取微信accesstoken
function Bridge_ios.SetWxAccessTokenOpenID(callback)
    local args = {scriptHandler = callback }
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"SetWxAccessTokenOpenID",args)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

--分享
function Bridge_ios.startShare(callback)
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"startShare",{scriptHandler = callback})
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end


--自定义分享
function Bridge_ios.customShare( title,content,url,img,imgOnly,callback )
    local t = 
    {
        title = title,
        content = content,
        url = url,
        img = img,
        imageOnly = imgOnly,
        scriptHandler = callback,
    }
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"customShare",t)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

-- 分享到指定平台
function Bridge_ios.shareToTarget( target, title, content, url, img, imgOnly, callback )
    local t = 
    {
        target = target,
        title = title,
        content = content,
        url = url,
        img = img,
        imageOnly = imgOnly,
        scriptHandler = callback,
    }
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"shareToTarget",t)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

--第三方支付
function Bridge_ios.thirdPartyPay(thirdparty, payparamTab, callback)
    payparamTab._nidx = thirdparty
    payparamTab.scriptHandler = callback
    payparamTab.info = cjson.encode(payparamTab.info)

    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"thirdPartyPay",payparamTab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end
--打开第三方网页 
function Bridge_ios.OpenThirdUrl(payparamTab)
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"OpenThirdUrl",payparamTab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

function Bridge_ios.isPlatformInstalled(thirdparty)
    local paramtab = { _nidx = thirdparty }
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"isPlatformInstalled",paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true
    end
end

function Bridge_ios.jump2Wechat(thirdparty)
    local _url = "weixin://"
    local paramtab = {url = _url}
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"openBrowser", paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true
    end    
end

-- function Bridge_ios.saveImgToSystemGallery(filepath, filename)
--     local args = { _filepath = filepath, _filename = filename }
--     local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"saveImgToSystemGallery",args)
--     if not ok then
--         local msg = "luaoc error:" .. ret
--         print(msg)  
--         return false, msg   
--     else  
--         return ret
--     end
-- end

function Bridge_ios.checkRecordPermission()
    local args = { }
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"isHaveRecordPermission",args)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_ios.requestLocation( callback )
    local paramtab = {scriptHandler = callback}
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"requestLocation",paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_ios.metersBetweenLocation( loParam )
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"metersBetweenLocation",loParam)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_ios.requestContact( callback )
    local paramtab = {scriptHandler = callback}
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"requestContact", paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_ios.openBrowser(url)
    local paramtab = {url = url}
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"openBrowser", paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_ios.copyToClipboard( msg )
    local paramtab = {msg = msg}
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"copyToClipboard", paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return 0, msg   
    else 
        print(ret)
        return ret
    end
end

function Bridge_ios.GoogleLogin()
    local paramtab = {scriptHandler = GoogleLogonCallback}
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"GoogleLogin" , paramtab)
    if not ok then
        showToast("GoogleLogin call fail")
        return false
    else
        return true
    end
end

--facebook 登录
function Bridge_ios.FaceBookLogin()
    local paramtab = {fbcall = FacebookCallback}

    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"FaceBookLogin" , paramtab)
    if not ok then
        showToast("FaceBookLogin call fail")
        return false
    else
        return true
    end
end

--平台分享
function Bridge_ios.mobShare(platform, link, content, title, imgPath)
   

    local t = 
    {
        target = platform,
        title = title,
        content = content,
        url = link,
        img = imgPath,
        scriptHandler = mobShareCallback,
    }
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"mobShare",t)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end    
end


function Bridge_ios.threeLogEvent(ptype,money)  -- ptype 1:"guestLogon" 2:"facebookLogon" 3:"googleLogon" 4:"purchase"
    print("================threeLogEvent")
    local threeData = getThreeDataJson()
    local __fire = {"guestLogon","facebookLogon","googleLogon","purchase"}
    local idx = 1
    if ptype < 4 then
        idx = 1
    elseif ptype == 4 then
        idx = 2
    end
    if threeData.afsdk == true then
        print("========afsdk") 
        local __type = {"af_login","af_purchase"}
        local data = {
            event_type = FunctionAfLogName(__type[idx]),
            event_fire = __fire[ptype],
            af_content_id = 1001
        }
        if money then
            data.af_revenue = money
        end
        dump(data)
        
        local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"appsFlyerEvent" , data)
        if not ok then
        else
        end
    end

    if threeData.adjustsdk == true then
        print("========adjustsdk")
        local __type = {"ad_login","ad_purchase"}
        local data = {
            event_type = FunctionADLogName(__type[idx]),
            event_fire = __fire[ptype],
            af_content_id = 1001
        }
        if money then
            data.ad_revenue = money
        end
        
        local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"adjustLogEvent" , data)
        if not ok then
        else
        end
    end
end

--获取adjust token
function Bridge_ios.getAdjustKey()
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"getADToken")
    if not ok then
        print("luaj error:" .. ret)
        return ""
    else
        print("The ret is:" .. ret)
        return ret
    end
end

--获取adjust 设备id
function Bridge_ios.getAdjustGoogleAdId()
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"getADID")
    if not ok then
        print("luaj error:" .. ret)
        return ""
    else
        print("The ret is:" .. ret)
        return ret
    end
end

--获取adjust 广告主id
function Bridge_ios.getAdjustId()
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"getIDFA")
    if not ok then
        print("luaj error:" .. ret)
        return ""
    else
        print("The ret is:" .. ret)
        return ret
    end
end

--firebase push token
function Bridge_ios.getFireBaseToken()
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"getPushToken")
    if not ok then
        print("luaj error:" .. ret)
        return ""
    else
        print("The ret is:" .. ret)
        return ret
    end
end  


--获取渠道号
function Bridge_ios.getChannelId()
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"getChannelId")
    if not ok then
        print("luaoc error:" .. ret)
        return ""
    else
        print("The ret is:" .. ret)
        return ret
    end
end

--横竖版切换
function Bridge_ios:ChangeOrientation(pOrientation)
    local result = false
    if CHANGE_ORIENTATION_OPEN then
        local t = {pOrientation=pOrientation}
        local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"ChangeOrientation",{Orientation = pOrientation})
        result = ok
    end
    return result
end

return Bridge_ios