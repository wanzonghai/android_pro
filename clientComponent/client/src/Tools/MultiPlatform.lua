--
-- Author: zhong
-- Date: 
--

--[[
* 跨平台管理
* tip: require 该模块时路径要统一 ""
]]

local MultiPlatform = class("MultiPlatform")

local g_var = g_ExternalFun.req_var
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

--平台
local PLATFORM = {}
PLATFORM[cc.PLATFORM_OS_ANDROID] = appdf.CLIENT_SRC .. "Tools.platform.Bridge_android"
PLATFORM[cc.PLATFORM_OS_IPHONE] = appdf.CLIENT_SRC .. "Tools.platform.Bridge_ios"
PLATFORM[cc.PLATFORM_OS_IPAD] = appdf.CLIENT_SRC .. "Tools.platform.Bridge_ios"
PLATFORM[cc.PLATFORM_OS_MAC] = appdf.CLIENT_SRC .. "Tools.platform.Bridge_ios"

function MultiPlatform:ctor()
	self.sDefaultTitle = ""
	self.sDefaultContent = ""
	self.sDefaultUrl = ""
end

--实现单例
MultiPlatform._instance = nil
function MultiPlatform:getInstance(  )
	if nil == MultiPlatform._instance then
		print("new instance")
		MultiPlatform._instance = MultiPlatform:create()
	end
	return MultiPlatform._instance
end

function MultiPlatform:getSupportPlatform()
	local plat = targetPlatform
	--ios特殊处理
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
		plat = cc.PLATFORM_OS_IPHONE
	end

	return plat
end

--获取设备id
function MultiPlatform:getMachineId()
	local plat = self:getSupportPlatform()

	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getMachineId then
		return g_var(PLATFORM[plat]).getMachineId()
	else
        return md5(CCGetWinMac())
	end	
end

--获取设备ip
function MultiPlatform:getClientIpAdress()
	local plat = self:getSupportPlatform()

	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getMachineId then
		return g_var(PLATFORM[plat]).getClientIpAdress()
	else
		-- print("unknow platform ==> " .. plat)
		return "127.0.0.1"
	end	
end

--获取外部存储可写文档目录
function MultiPlatform:getExtralDocPath()
	local plat = self:getSupportPlatform()
	local path = device.writablePath
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getExtralDocPath then
		path = g_var(PLATFORM[plat]).getExtralDocPath()
	else
		print("undefined funtion or unknow platform ==> " .. plat)
	end	

	if false == cc.FileUtils:getInstance():isDirectoryExist(path) then
		cc.FileUtils:getInstance():createDirectory(path)
	end
	return path
end

-- 选择图片
-- callback 回调函数
-- needClip 是否需要裁减图片
function MultiPlatform:triggerPickImg( callback, needClip )
	local plat = self:getSupportPlatform()

	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).triggerPickImg then
		g_var(PLATFORM[plat]).triggerPickImg( callback, needClip )
	else
		-- print("unknow platform ==> " .. plat)
	end	
end

--配置第三方平台
function MultiPlatform:thirdPartyConfig(thirdparty, configTab)
	configTab = configTab or {}

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).thirdPartyConfig then
		g_var(PLATFORM[plat]).thirdPartyConfig( thirdparty, configTab )
	else
		-- print("unknow platform ==> " .. plat)
	end	
end

--分享相关
function MultiPlatform:configSocial(socialTab)
	socialTab = socialTab or {}
	socialTab.title = socialTab.title or ""
	socialTab.content = socialTab.content or ""
	socialTab.url = socialTab.url or ""

	self.sDefaultTitle = socialTab.title
	self.sDefaultContent = socialTab.content
	self.sDefaultUrl = socialTab.url

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).configSocial then
		g_var(PLATFORM[plat]).configSocial( socialTab )
	else
		-- print("unknow platform ==> " .. plat)
	end	
end

--获取微信信息
function MultiPlatform:SetWxAccessTokenOpenID(callback)
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).SetWxAccessTokenOpenID then
		return g_var(PLATFORM[plat]).SetWxAccessTokenOpenID(callback)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg		
	end	
end


--第三方登陆
function MultiPlatform:thirdPartyLogin(thirdparty, callback)
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).thirdPartyLogin then
		return g_var(PLATFORM[plat]).thirdPartyLogin( thirdparty, callback )
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg		
	end	
end

--第三方微信登录，设置token
function MultiPlatform:thirdWxAccessToken_OpenID(param)
	if type(param) == "string" and string.len(param) > 0 then
		local ok, datatable = pcall(function()
				return cjson.decode(param)
		end)
		if ok and type(datatable) == "table" then
            local access_token = datatable["access_token"] or ""
            local openid = datatable["openid"] or ""
            GlobalUserItem.SetWxAccessToken_OpenID(access_token,openid)
        end
    end
end
--分享
function MultiPlatform:startShare(callback)
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).startShare then
		return g_var(PLATFORM[plat]).startShare( callback )
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg		
	end	
end

--自定义分享
-- imgOnly 值为字符串 "true" 表示只分享图片
function MultiPlatform:customShare( callback, title, content, url, img, imgOnly )
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end
	title = title or self.sDefaultTitle
	content = content or self.sDefaultContent
	img = img or ""
	url = url or self.sDefaultUrl
	imgOnly = imgOnly or "false"

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).customShare then
		return g_var(PLATFORM[plat]).customShare( title,content,url,img, imgOnly,callback )
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg		
	end
end

-- 分享到指定平台
function MultiPlatform:shareToTarget( target, callback, title, content, url, img, imgOnly )
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end
	title = title or self.sDefaultTitle
	content = content or self.sDefaultContent
	img = img or ""
	url = url or self.sDefaultUrl
	imgOnly = imgOnly or "false"

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).shareToTarget then
		return g_var(PLATFORM[plat]).shareToTarget( target, title, content, url, img, imgOnly, callback )
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg		
	end
end

--第三方支付
--[[
payparam = 
{
	price,
	count,
	productname,
	orderid,
}
]]
function MultiPlatform:thirdPartyPay(thirdparty, payparamTab, callback)
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end
	payparamTab = payparamTab or {}

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).thirdPartyPay then
		return g_var(PLATFORM[plat]).thirdPartyPay( thirdparty, payparamTab, callback )
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg		
	end	
end

--打开第三方网页 
function MultiPlatform:OpenThirdUrl(payparamTab)
	payparamTab = payparamTab or {}

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).OpenThirdUrl then
		return g_var(PLATFORM[plat]).OpenThirdUrl(payparamTab )
	else
        CCOpenWinUrl(payparamTab["url"])
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg		
	end	
end

--第三方平台是否安装
function MultiPlatform:isPlatformInstalled(thirdparty)
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).isPlatformInstalled then
		return g_var(PLATFORM[plat]).isPlatformInstalled( thirdparty )
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg		
	end
end

function MultiPlatform:jump2Wechat(thirdparty)
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).jump2Wechat then
		return g_var(PLATFORM[plat]).jump2Wechat( thirdparty )
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg		
	end
end

--图片存储至系统相册
function MultiPlatform:saveImgToSystemGallery(filepath, filename)
	if false == cc.FileUtils:getInstance():isFileExist(filepath) then
		local msg = filepath .. " not exist"
		print(msg)
		return false, msg
	end
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).saveImgToSystemGallery then
		return g_var(PLATFORM[plat]).saveImgToSystemGallery( filepath, filename )
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg		
	end
end

-- 录音权限判断
function MultiPlatform:checkRecordPermission()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).checkRecordPermission then
		return g_var(PLATFORM[plat]).checkRecordPermission()
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg
	end
end

-- 请求单次定位
function MultiPlatform:requestLocation(callback)
	callback = callback or -1

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).requestLocation then
		return g_var(PLATFORM[plat]).requestLocation(callback)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		if type(callback) == "function" then
			callback("")
		end
		return false, msg
	end
end

-- 计算距离
function MultiPlatform:metersBetweenLocation( loParam )
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).metersBetweenLocation then
		return g_var(PLATFORM[plat]).metersBetweenLocation(loParam)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg
	end
end

-- 请求通讯录
function MultiPlatform:requestContact(callback)
	callback = callback or -1

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).requestContact then
		return g_var(PLATFORM[plat]).requestContact(callback)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg
	end
end

-- 启动浏览器
function MultiPlatform:openBrowser( url )
	url = url or ylAll.Request_HttpUrl
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).openBrowser then
		return g_var(PLATFORM[plat]).openBrowser(url)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return false, msg
	end
end

-- 复制到剪贴板
function MultiPlatform:copyToClipboard( msg )
	if type(msg) ~= "string" then
		print("复制内容非法")
		return 0, "复制内容非法"
	end
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).copyToClipboard then
		return g_var(PLATFORM[plat]).copyToClipboard(msg)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end
--google登录
function MultiPlatform:GoogleLogin()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).GoogleLogin then
		return g_var(PLATFORM[plat]).GoogleLogin()
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end
--facebook登录
function MultiPlatform:FaceBookLogin()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).FaceBookLogin then
		return g_var(PLATFORM[plat]).FaceBookLogin()
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

--facebook分享
function MultiPlatform:FaceBookShare(showapp,url,content,imgUrl)
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).FaceBookShare then
		return g_var(PLATFORM[plat]).FaceBookShare(showapp,url,content,imgUrl)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

--平台分享
function MultiPlatform:mobShare(platform, link, content, title, imgPath)
	--platform : Facebook, WhatsApp, Instagram, Twitter, Telegram
	--link : 分享链接url
	--content: 分享文本内容
	--title: 标题
	--imgPath : 图片地址(可以传网络图片url或本地图片，但facebook只能分享本地图片）
	--没有值时填空即可，比如imgPath不需要，则imgPath = "" 
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).mobShare then
		return g_var(PLATFORM[plat]).mobShare(platform, link, content, title, imgPath)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

function MultiPlatform:getAFID()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getAFID then
		return g_var(PLATFORM[plat]).getAFID()
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

function MultiPlatform:threeLogEvent(ptype,money)
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).threeLogEvent then
		return g_var(PLATFORM[plat]).threeLogEvent(ptype,money)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

function MultiPlatform:getAdjustId()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getAdjustId then
		return g_var(PLATFORM[plat]).getAdjustId()
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

function MultiPlatform:getAdjustGoogleAdId()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getAdjustGoogleAdId then
		return g_var(PLATFORM[plat]).getAdjustGoogleAdId()
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

function MultiPlatform:getAdjustKey()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getAdjustKey then
		return g_var(PLATFORM[plat]).getAdjustKey()
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

function MultiPlatform:getAdjustStatus()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getAdjustStatus then		
		return g_var(PLATFORM[plat]).getAdjustStatus()
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return "", msg
	end
end

function MultiPlatform:getAdjustAttribution()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getAdjustAttribution then
		return g_var(PLATFORM[plat]).getAdjustAttribution()
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return "", msg
	end
end

function MultiPlatform:getChannelId()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getChannelId then
		return g_var(PLATFORM[plat]).getChannelId()
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return "", msg
	end
end

function MultiPlatform:getFireBaseToken()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getFireBaseToken then
		return g_var(PLATFORM[plat]).getFireBaseToken()
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

--[[

]]
function MultiPlatform:PushNotification(pTitle,pContent)
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).PushNotification then
		return g_var(PLATFORM[plat]):PushNotification(pTitle,pContent)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

--[[

]]
function MultiPlatform:PushImageNotification(pSmall,pBig)
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).PushImageNotification then
		return g_var(PLATFORM[plat]):PushImageNotification(pSmall,pSmall)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

--[[

]]
function MultiPlatform:SetAlarmNotification(pCount,pURL,pRuler)
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).SetAlarmNotification then
		return g_var(PLATFORM[plat]):SetAlarmNotification(pCount,pURL,pRuler)
	else
		local msg = "unknow platform ==> " .. plat
		-- print(msg)
		return 0, msg
	end
end

return MultiPlatform
