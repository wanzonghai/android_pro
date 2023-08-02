--
-- Author: zhong
-- Date: 2016-07-29 17:45:30
--
local Bridge_android = {}
local luaj = require "cocos.cocos2d.luaj"

--获取设备id
function Bridge_android.getMachineId()
    local machineID = cc.UserDefault:getInstance():getStringForKey("MachineID_Android","")
    if machineID ~= "" then
        print("Local File Save MachineID = ",machineID)
    else
        local sigs = "()Ljava/lang/String;"    
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("getUUID"),{},sigs)
        if not ok then
            print("luaj error:" .. ret)
            machineID = "A45DFAD855135112dewADF7"
        else
            print("The ret is:" .. ret)
            machineID = md5(ret)
            cc.UserDefault:getInstance():setStringForKey("MachineID_Android",machineID)
            cc.UserDefault:getInstance():flush()
        end
    end
    return machineID
end

--获取设备ip
function Bridge_android.getClientIpAdress()
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("getHostAdress"),{},sigs)
    if not ok then
        print("luaj error:" .. ret)
        return "127.0.0.1"
    else
        print("The ret is:" .. ret)
        return ret
    end
end

--获取外部存储可写文档目录
function Bridge_android.getExtralDocPath()
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("getSDCardDocPath"),{},sigs)
    if not ok then
        print("luaj error:" .. ret)
        return device.writablePath
    else
        print("The ret is:" .. ret)
        return ret
    end
end

--选择图片
function Bridge_android.triggerPickImg(callback, needClip)
    needClip = needClip or false
    local args = { callback, needClip }
    if nil == callback or type(callback) ~= "function" then
    	print("user default callback fun")

    	local function callbackLua(param)
	        if type(param) == "string" then
	        	print(param)
	        end        
	    end
    	args = { callbackLua, needClip }
    end    
    
    local sigs = "(IZ)V"
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("pickImg"),args,sigs)
    if not ok then
        print("luaj error:" .. ret)       
    end
end

--配置支付、登陆相关
function Bridge_android.thirdPartyConfig(thirdparty, configTab)
    local args = {thirdparty, cjson.encode(configTab)}
    local sigs = "(ILjava/lang/String;)V"
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("thirdPartyConfig"),args,sigs)
    if not ok then
        print("luaj error:" .. ret)        
    end
end

function Bridge_android.configSocial(socialTab)
    local title = socialTab.title
    local content = socialTab.content
    local url = socialTab.url

    local args = {title, content, url}
    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("socialShareConfig"),args,sigs)
    if not ok then
        print("luaj error:" .. ret)        
    end
end
--获取微信token
function Bridge_android.SetWxAccessTokenOpenID(callback)
    local args = {callback }
    local sigs = "(I)V"
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("SetWxAccessTokenOpenID"),args,sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

--第三方登陆
function Bridge_android.thirdPartyLogin(thirdparty, callback)
    local args = { thirdparty, callback }
    local sigs = "(II)V"
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("thirdLogin"),args,sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

--分享
function Bridge_android.startShare(callback)
    local sigs = "(I)V"
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("startShare"),{callback},sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

--自定义分享
function Bridge_android.customShare( title, content,url, img, imgOnly, callback )
    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("customShare"),{title, content, url, img, imgOnly, callback},sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

-- 分享到指定平台
function Bridge_android.shareToTarget( target, title, content, url, img, imgOnly, callback )
    local sigs = "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("shareToTarget"),{target, title, content, url, img, imgOnly, callback},sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

--第三方支付
function Bridge_android.thirdPartyPay(thirdparty, payparamTab, callback)
    local args = { thirdparty, cjson.encode(payparamTab), callback }
    local sigs = "(ILjava/lang/String;I)V"
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("thirdPartyPay"),args,sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

function Bridge_android.OpenThirdUrl(payparamTab)
    local args = {cjson.encode(payparamTab)}
    local sigs = "(Ljava/lang/String;)V"
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("OpenThirdUrl"),args,sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

function Bridge_android.isPlatformInstalled(thirdparty)
    local args = { thirdparty }
    local sigs = "(I)Z" 
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("isPlatformInstalled"),args,sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_android.jump2Wechat(thirdparty)
    local pkg,cls = "com.tencent.mm", "com.tencent.mm.ui.LauncherUI"
 
    local args = { pkg, cls }
    local sigs = "(Ljava/lang/String;Ljava/lang/String;)V" 
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("jumpTo3rdApp"),args,sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true
    end
end

function Bridge_android.saveImgToSystemGallery(filepath, filename)
    local args = { filepath, filename }
    local sigs = "(Ljava/lang/String;Ljava/lang/String;)Z" 
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("saveImgToSystemGallery"),args,sigs)
    local result = false
    if ok then
        result = ret
    end
    return result
end

function Bridge_android.checkRecordPermission()
    local args = { }
    local sigs = "()Z" 
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("isHaveRecordPermission"),args,sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_android.requestLocation( callback )
    local args = { callback }
    local sigs = "(I)V" 
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("requestLocation"), args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_android.metersBetweenLocation( loParam )
    local args = { cjson.encode(loParam) }
    local sigs = "(Ljava/lang/String;)Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("metersBetweenLocation"), args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_android.requestContact( callback )
    local args = { callback }
    local sigs = "(I)V" 
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("requestContact"), args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_android.openBrowser(url)
    local args = { url }
    local sigs = "(Ljava/lang/String;)V" 
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("openBrowser"),args,sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

function Bridge_android.copyToClipboard( msg )
    local args = { msg }
    local sigs = "(Ljava/lang/String;)Z" 
    local ok,ret  = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("copyToClipboard"),args,sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return 0, msg   
    else  
        return ret     
    end
end
--google 登录
function Bridge_android.GoogleLogin()
    local sigs = "()V"    
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("GoogleLogin"),{},sigs)
    if not ok then
        showToast("GoogleLogin call fail")
        return false
    else
        return true
    end
end
--facebook 登录
function Bridge_android.FaceBookLogin()
    local sigs = "()V"    
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("FaceBookLogin"),{},sigs)
    if not ok then
        showToast("FaceBookLogin call fail")
        return false
    else
        return true
    end
end
-- --facebook分享
-- function Bridge_android.FaceBookShare(showapp,url,content,imgUrl)
--     local args = { showapp,url,content,imgUrl }
--     local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"    
--     local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,"FaceBookShare",args,sigs)
--     if not ok then
--         showToast("FaceBookShare call fail")
--         return false
--     else
--         return true
--     end
-- end
--平台分享
function Bridge_android.mobShare(platform, link, content, title, imgPath)
    local args = { platform, link, content, title, imgPath }
    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"    
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("mobShare"),args,sigs)
    if not ok then
        showToast("mobShare call fail")
        return false
    else
        return true
    end
end

function Bridge_android.getAFID()
    local sigs = "()Ljava/lang/String;"    
    local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_AF,FunctionMapping("getAFID"),{},sigs)
    if not ok then
        showToast("getAFID call fail")
        return false
    else
        return true
    end
end

function Bridge_android.threeLogEvent(ptype,money)  -- ptype 1:"guestLogon" 2:"facebookLogon" 3:"googleLogon" 4:"purchase"
    print("================threeLogEvent")
    local threeData = getThreeDataJson()
    local sigs = "(Ljava/lang/String;)V"   
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
        local args = {cjson.encode(data)}
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_AF,FunctionMapping("appsFlyerEvent"),args,sigs)
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
        local args = {cjson.encode(data)}
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ADJUST,FunctionMapping("adjustLogEvent"),args,sigs)
        if not ok then
        else
        end
    end
end

function Bridge_android:getAdjustId()
    local threeData = getThreeDataJson()
    if threeData.adjustsdk == true then
        local sigs = "()Ljava/lang/String;"    
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ADJUST,FunctionMapping("getAdjustId"),{},sigs)
        if not ok then
            showToast("getAdjustId call fail")
            return false
        else
            return ret
        end
    end
end

function Bridge_android:getAdjustGoogleAdId()
    local threeData = getThreeDataJson()
    if threeData.adjustsdk == true then
        local sigs = "()Ljava/lang/String;"    
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ADJUST,FunctionMapping("getAdjustGoogleAdId"),{},sigs)
        if not ok then
            showToast("getAdjustGoogleAdId call fail")
            return false
        else
            return ret
        end
    end
end

function Bridge_android:getAdjustKey()
    local threeData = getThreeDataJson()
    if threeData.adjustsdk == true then
        local sigs = "()Ljava/lang/String;"    
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ADJUST,FunctionMapping("getAdjustKey"),{},sigs)
        if not ok then
            showToast("getAdjustKey call fail")
            return false
        else
            return ret
        end
    end
end

function Bridge_android:getAdjustStatus()
    local threeData = getThreeDataJson()
    if threeData.adjustsdk == true then
        local sigs = "()Ljava/lang/String;"    
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("getAdjustStatus"),{},sigs)
        if not ok then
            showToast("getAdjustStatus call fail")
            return false
        else
            return ret
        end
    else
        return ""
    end
end

--兼容老包(老包原生端没有次方法)
function Bridge_android:getAdjustAttribution()
    if CHANNEL_OPEN then
        local threeData = getThreeDataJson()
        if threeData.adjustsdk == true then
            local sigs = "()Ljava/lang/String;"    
            local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ADJUST,FunctionMapping("getAdjustAttribution"),{},sigs)
            if not ok then
                showToast("getAdjustAttribution call fail")
                return ""
            else
                return ret
            end
        end
    else
        return ""
    end
end

--兼容老包(老包原生端没有次方法)
function Bridge_android:getChannelId()
    if CHANNEL_OPEN then
        local sigs = "()Ljava/lang/String;"    
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("getChannelId"),{},sigs)
        if not ok then
            showToast("getChannelId call fail")
            return ""
        else
            return ret
        end
    else
        return ""
    end
end

function Bridge_android:getFireBaseToken()
    local threeData = getThreeDataJson()
    if threeData.firebasesdk == true then
        local sigs = "()Ljava/lang/String;"    
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_FIREBASE,FunctionMapping("getFireBaseToken"),{},sigs)
        if not ok then
            showToast("getFireBaseToken call fail")
            return false
        else
            return ret
        end
    end
end

function Bridge_android:PushNotification(pTitle,pContent)
    if NOTIFICATION_OPEN then
        print("pTitle = ",pTitle)
        print("pContent = ",pContent)
        local sigs = "(Ljava/lang/String;Ljava/lang/String;)V"    
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("PushNotification"),{pTitle,pContent},sigs)
        -- if not ok then
        --     showToast("getFireBaseToken call fail")
        --     return false
        -- else
        --     return ret
        -- end
    end
end

function Bridge_android:PushImageNotification(pSmall,pBig)
    if ALARM_NOTIFICATION_OPEN then
        print("pSmall = ",pSmall)
        print("pBig = ",pBig)
        local sigs = "(Ljava/lang/String;Ljava/lang/String;)V"    
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("PushImageNotification"),{pSmall,pBig},sigs)        
    end
end

function Bridge_android:SetAlarmNotification(pCount,pURL,pRuler)
    if ALARM_NOTIFICATION_OPEN then
        print("pCount = ",pCount)
        print("pURL = ",pURL)
        print("pRuler = ",pRuler)
        local sigs = "(ILjava/lang/String;I)V"    
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,FunctionMapping("SetAlarmNotification"),{pCount,pURL,pRuler},sigs)        
    end
end

return Bridge_android