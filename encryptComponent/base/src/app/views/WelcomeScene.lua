
--[[
	欢迎界面
			2015_12_03 C.P
	功能：本地版本记录读取，如无记录，则解压原始大厅及附带游戏
--]]

local WelcomeScene = class("WelcomeScene", cc.load("mvc").ViewBase)

require("base.src.I18n")
appdf.req("base.src.app.models.ylAll")

local ClientUpdate = appdf.req("base.src.app.controllers.ClientUpdate")
local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")

g_TargetPlatform = cc.Application:getInstance():getTargetPlatform()
-- local curApkVer = cc.UserDefault:getInstance():getIntegerForKey("CurApkVersion",1)
-- local curApkVer = ylAll.ApkVersion
local scheduler = cc.Director:getInstance():getScheduler()

g_FrameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
g_offsetX = 0
First_Run = true
local m_frameCache = nil

local luaoc
local BRIDGE_CLASS_IOS
if g_TargetPlatform == cc.PLATFORM_OS_IPHONE or g_TargetPlatform == cc.PLATFORM_OS_IPAD then
   luaoc = require "cocos.cocos2d.luaoc"
   BRIDGE_CLASS_IOS = "AppController"
end
local luaj
local BRIDGE_CLASS_ANDROID
if g_TargetPlatform == cc.PLATFORM_OS_ANDROID then
    luaj = require "cocos.cocos2d.luaj"
    BRIDGE_CLASS_ANDROID = "org/cocos2dx/lua/sgsAppActivity"
end

StringUtil = {}
function StringUtil.isStringValid(str)
    return str and str ~= "";
end

function IpString2dw( str )
	local num = 0
	if str and type(str)=="string" then
		local o1,o2,o3,o4 = str:match("(%d+)%.(%d+)%.(%d+)%.(%d+)" )
		num = 2^24*o4 + 2^16*o3 + 2^8*o2 + o1
	end
    return num
end

-- if g_TargetPlatform == cc.PLATFORM_OS_WINDOWS and ylAll.WIN32_UPDATE then
--     device.writablePath = device.writablePath .. "update_res/"
-- 	createDirectory(device.writablePath)
-- end

local _callersArr = {}
local configResList = {
}

--启动界面
function WelcomeScene:onCreate()
    local scaleY = g_FrameSize.height / appdf.HEIGHT
    local acWidth = math.floor(g_FrameSize.width / scaleY)
    if acWidth > appdf.WIDTH then
        g_offsetX = (acWidth - appdf.WIDTH)/2
    end
	
    if not First_Run then
        collectgarbage("collect")
        local logonLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.login.LogonScene").new(self,true)
        self:addChild(logonLayer,1)
        return
    end
    First_Run = false
    
    local csbNode = cc.CSLoader:createNode("welcomeLayer.csb")    
    local content = csbNode:getChildByName("content")
    csbNode:setContentSize(display.width,display.height)    
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)

    local bg = content:getChildByName("Image_7")    
    if display.width  > 2560 then
        bg:setScale(display.width/2560)
        local pLogo = bg:getChildByName("desk")
        pLogo:setScale(2560/display.width)
    end
    ccui.Helper:doLayout(csbNode)    
    self:addChild(csbNode)
    --背景
    -- if device.platform ~= "windows" then
    --     performWithDelay(self,function()  
    --         AudioEngine.playEffect("base/res/spine/logo.mp3",false)
    --     end,0.1)
        
    --     self.SpineBg = sp.SkeletonAnimation:create("base/res/spine/logo.json","base/res/spine/logo.atlas", 1)        
    --     self.SpineBg:addTo(csbNode)
    --     self.SpineBg:setPosition(display.cx,display.cy) 
    --     self.SpineBg:setAnimation(0, "ruchang", false)
    --     self.SpineBg:registerSpineEventHandler( function( event )
    --         if event.animation == "ruchang" then
    --             self.SpineBg:hide()
    --             self:onHandlerWelcomeHttp()        
    --         end
    --     end, sp.EventType.ANIMATION_COMPLETE)  
    -- else
        self:onHandlerWelcomeHttp()       
    -- end
     
    

    --bgNode
    -- self.bgNode = content:getChildByName("bgNode")
    -- local pBgNodeEffect = cc.CSLoader:createTimeline("base/res/LoadingCommon.csb");
    -- pBgNodeEffect:gotoFrameAndPlay(0, true)
    -- self.bgNode:runAction(pBgNodeEffect)
    -- if ylAll.LogoType then
    --     local logo = self.bgNode:getChildByName("ld_logo_19")
    --     logo:setTexture(ylAll.LogoType)
    --     local logo = self.bgNode:getChildByName("ld_logo_19_0")
    --     logo:setTexture(ylAll.LogoType)
    -- end
    --hero
    -- self.heroNode = content:getChildByName("heroNode")
    -- self.heroNode:setPositionX(display.cx-560)
    -- local skeletonNode = sp.SkeletonAnimation:create("base/res/spine/juese.json", "base/res/spine/juese.atlas", 1)
    -- skeletonNode:addAnimation(0, "daiji", true)
    -- skeletonNode:setPosition(0,0)
    -- self.heroNode:addChild(skeletonNode)
    --PanelTips
    self.PanelTips = content:getChildByName("PanelTips")
    self.sliderBG = self.PanelTips:getChildByName("sliderBG")
    self.sliderLine = self.sliderBG:getChildByName("sliderLine")
    self.sliderHead = self.sliderLine:getChildByName("light")
    self.sliderWidth = self.sliderLine:getContentSize().width    
    self.txtDownDesc = self.PanelTips:getChildByName("txtDown")
    self.txtShow = self.PanelTips:getChildByName("txtShow")
    self.txtShow:setString("Checando atualização")
    self.txtPercent = self.PanelTips:getChildByName("txtPercent")
    
    self:updateBar(0)

    
end

function WelcomeScene:onHandlerWelcomeHttp()    
    local ipConfigHttp = ylAll.Request_HttpUrl.."brazil_IpList.json"
    appdf.onHttpJsionTable(ipConfigHttp,"GET","",function(jsondata,response)
        if jsondata then
            if tolua.isnull(self) then
                return
            end
            self:onRequestUpdateConfig(jsondata)
            local dst = device.writablePath
            local destFile = dst.."brazil_IpList.json"
            downFileAsync(ipConfigHttp,"brazil_IpList.json",dst,function(main,sub)
            end)
        else
            local dst = device.writablePath
            local destFile = dst.."brazil_IpList.json"
            if cc.FileUtils:getInstance():isFileExist(destFile) then
                local szIpAddress = cc.FileUtils:getInstance():getStringFromFile(destFile)
                self:onRequestUpdateConfig(cjson.decode(szIpAddress))
                return 
            end
            self:QuitTips()
        end            
    end)
end

function WelcomeScene:onRequestUpdateConfig(jsondata) 
    local callback = function()
        local configHttp = ylAll.Request_HttpUrl.."brazil_Config.json"
        appdf.onHttpJsionTable(configHttp,"GET","",function(jsondata,response)       
            if jsondata then
                if tolua.isnull(self) then
                    return
                end
                self.jsondata = jsondata
                self:JudgeConfigStatus()                
            else
                local dst = device.writablePath
                local destFile = dst.."brazil_Config.json"
                if cc.FileUtils:getInstance():isFileExist(destFile) then
                    local szConfig = cc.FileUtils:getInstance():getStringFromFile(destFile)
                    self.jsondata = cjson.decode(szConfig)
                    self:initClientInit()
                    self:PerLoadingLogonRes(handler(self,self.StepNext))
                    return 
                end
                self:QuitTips()
            end      
        end)
    end
    self:onInitNetwork(jsondata,callback)  --优先初始化网络
end

function WelcomeScene:JudgeConfigStatus()
    if self.jsondata.ServerStatus and self.jsondata.ServerStatus ~=0 then
        if self.jsondata.ServerStatus == 1 or IS_WHITE_LIST then 
            local pConfig = self.jsondata.NoticeConfig
            local pContent = string.format(pConfig.msg1,pConfig.timeStart,pConfig.timeEnd)
            local pTitle = pConfig.title
            local pSignature = string.format(pConfig.signature,self.jsondata.apk_name)
            self.NoticeDialog = QueryDialog:create("",function(bConfirm)
                if self.schedulerID then
                    scheduler:unscheduleScriptEntry(self.schedulerID)
                    self.schedulerID = nil
                end
                if bConfirm == true then                    	
                    self:DealConfig()
                end					                   
            end)
            self.NoticeDialog:showTXTTitle(pTitle)
            self.NoticeDialog:showTXTContent(pContent)
            self.NoticeDialog:showTXTSignature(pSignature)
            self:addChild(self.NoticeDialog)
            
            -- local scheduler = cc.Director:getInstance():getScheduler()            
            self.schedulerID = scheduler:scheduleScriptFunc( function()
                if self.schedulerID then
                    scheduler:unscheduleScriptEntry(self.schedulerID)
                    self.schedulerID = nil
                end
                self:DealConfig()
            end , 5, false)
        elseif self.jsondata.ServerStatus == 2 then
            self.PanelTips:hide()
            local pConfig = self.jsondata.NoticeConfig
            local pContent = string.format(pConfig.msg2,pConfig.timeEnd)
            local pTitle = pConfig.title
            local pSignature = string.format(pConfig.signature,self.jsondata.apk_name)
            self.NoticeDialog = QueryDialog:create("",function(bConfirm)
                os.exit(0)
            end)
            self.NoticeDialog:showTXTTitle(pTitle)
            self.NoticeDialog:showTXTContent(pContent)
            self.NoticeDialog:showTXTSignature(pSignature)
            self:addChild(self.NoticeDialog)            
        end
    else
        self:DealConfig()
    end
end

function WelcomeScene:DealConfig()
    local configHttp = ylAll.Request_HttpUrl.."brazil_Config.json"
    self:initClientInit()
    self:PerLoadingLogonRes(handler(self,self.StepNext))
    local dst = device.writablePath
    local destFile = dst.."brazil_Config.json"
    downFileAsync(configHttp,"brazil_Config.json",dst,function(main,sub)
    end)
end

function WelcomeScene:onInitNetwork(jsondata,callback)
    local ipUrl = jsondata["getIpUrl"] or "https://ifconfig.me/ip"
    appdf.onHttpJsionTable(ipUrl,"GET","",
        function(json,response)
            if tolua.isnull(self) then
                return
            end
            local ip = "127.0.0.1"
            if response then
                ip = response
            end
            local machined = self:getMachineId()
            print("machined = ",machined)
            print("ip = ",ip)
            CCipHerInit(machined,ip)
            if NET_SECOND_OPTIMIZE_OPEN then
                --支持网络二次优化
                local newServerListCDN = {}
                local bHaveServerCDN = false
                local ipMaxCountCDN = tonumber(jsondata["IpMaxCountCDN2"]) or 10
                for i=1,ipMaxCountCDN do  --最多配10个域名列表 
                    if not jsondata["ServerListCDN2"] then break end
                    local id = jsondata["ServerListCDN2"][ string.format("id%d",i)]
                    local ip = jsondata["ServerListCDN2"][ string.format("ip%d",i)]
                    if id and ip then
                        table.insert(newServerListCDN,{id=id,ip=ip})
                        bHaveServerCDN = true
                    end
                end
                if not ylAll.LocalTest and bHaveServerCDN == true then
                    ylAll.LOGONSERVER_LIST = newServerListCDN
                end
                for i,v in pairs(ylAll.LOGONSERVER_LIST) do
                    CCInitTesterServer(v.id,v.ip) 
                end
            else
                if NET_OPTIMIZE_OPEN then
                    --支持网络优化
                    local newServerListCDN = {}
                    local bHaveServerCDN = false
                    local ipMaxCountCDN = tonumber(jsondata["IpMaxCountCDN"]) or 10
                    for i=1,ipMaxCountCDN do  --最多配10个域名列表 
                        if not jsondata["ServerListCDN"] then break end
                        local id = jsondata["ServerListCDN"][ string.format("id%d",i)]
                        local ip = jsondata["ServerListCDN"][ string.format("ip%d",i)]
                        if id and ip then
                            table.insert(newServerListCDN,{id=id,ip=ip})
                            bHaveServerCDN = true
                        end
                    end
                    if not ylAll.LocalTest and bHaveServerCDN == true then
                        ylAll.LOGONSERVER_LIST = newServerListCDN
                    end
                    for i,v in pairs(ylAll.LOGONSERVER_LIST) do
                        CCInitTesterServer(v.id,v.ip) 
                    end
                else
                    --旧版网络
                    local newServerList = {}
                    local bHaveServer = false
                    local ipMaxCount = tonumber(jsondata["IpMaxCount"]) or 10
                    for i=1,ipMaxCount do  --最多配10个域名列表 
                        if not jsondata["ServerList"] then break end
                        local id = jsondata["ServerList"][ string.format("id%d",i)]
                        local ip = jsondata["ServerList"][ string.format("ip%d",i)]
                        if id and ip then
                            table.insert(newServerList,{id=id,ip=ip})
                            bHaveServer = true
                        end
                    end    
                    if not ylAll.LocalTest and bHaveServer == true then
                        ylAll.LOGONSERVER_LIST = newServerList
                    end
                    for i,v in pairs(ylAll.LOGONSERVER_LIST) do
                        CCInitTesterServer(v.id,v.ip) 
                    end
                end
            end
            
            --网络数据
            local netDelayData = {}
            local netDelayData = jsondata["networkData"]
            for i=1,7 do
                if not netDelayData then 
                    break 
                end
                local _value = netDelayData[tostring(i)]
                table.insert(netDelayData,_value or 0)
            end
            ylAll.NormalNetDelay = netDelayData
            if #netDelayData > 0 then
                CCSetNetworkDelayTime(netDelayData[1],netDelayData[2],netDelayData[3],netDelayData[4],netDelayData[5],netDelayData[6],netDelayData[7])
            end
            local ipDw = IpString2dw(ip)
            local addr = {}
            addr[1],addr[2],addr[3],addr[4],addr[5],addr[6],addr[7],addr[8],addr[9],addr[10],addr[11],addr[12],addr[13],addr[14] = CCHxcipherIpEncode(ipDw)
            ylAll.ipAddr = addr
            callback()
        end
    )
end

function WelcomeScene:initClientInit()
    require("clientcore.ClientCoreConfig")
    ClientCoreConfig.includeTween = true
    ClientCoreConfig.includeCcs = true
    ClientCoreConfig.setup(self)
    require("app.ClientInit").setup(self)
    appdf.req("base.src.app.models.Functions")
end

--提前加载 大厅资源 
function WelcomeScene:PerLoadingLogonRes(callback)
    self._processAllTotal = #configResList + #_callersArr
    self._processTotal = #configResList
	self._processIndex = 1
    self._picCachedSps = {}
    self._processComplete = callback
    self._processTimer = scheduler:scheduleScriptFunc(handler(self,self.doLoadTexture), 0, false)
end

function WelcomeScene:doLoadTexture()
    if self._processTotal < self._processIndex then
        if self._processAllTotal < self._processIndex then
		    if self._processTimer ~= nil then
		       scheduler:unscheduleScriptEntry(self._processTimer)
		       self._processTimer = nil
		    end
		    self:applyFunction(self._processComplete)
		    self._processComplete = nil
        else
            self:onCallLuaScript()
        end
    else
   		local onAnyscComplete = nil
		local vo = configResList[self._processIndex]    
        local url = nil
       if vo.type == "plist" then
            onAnyscComplete = function()--__emptyFunction;--一定要带上空函数，否则display.loadImage不用异步加载
               m_frameCache:addSpriteFrames(vo.url .. ".plist")
            end
            url = vo.url..".png"
       elseif vo.type == "png" or vo.type == "jpg" then
            onAnyscComplete = function()--__emptyFunction;--一定要带上空函数，否则display.loadImage不用异步加载
            end
            url = vo.url.."."..vo.type
       end
       display.loadImage(url, onAnyscComplete)
       self._processIndex = self._processIndex + 1
       self:showLoadingPercent(self._processIndex)
    end 
end
function WelcomeScene:showLoadingPercent(index) 
    local per = index / self._processAllTotal *100
    if per >100 then per = 100 end
    self:updateBar(per)
end

function WelcomeScene:onCallLuaScript()
    local callVo = _callersArr[self._processIndex-self._processTotal];
    local t = os.clock();
    callVo.func(callVo.scope);
    self._processIndex = self._processIndex + 1;
    self:showLoadingPercent(self._processIndex)
end


function WelcomeScene:StepNext()
	-- 资源同步队列
	self.m_tabUpdateQueue = {}
    self:LoadResComplete()
end

function WelcomeScene:LoadResComplete()
	--无版本信息或不对应 解压自带ZIP
    local nResversion = tonumber(self:getApp()._version:getResVersion())
	if nil == nResversion then
	    self:onUnZipBase()        
	else
        self:NewEnterGame(self.jsondata)
	end       
end

--解压自带ZIP
function WelcomeScene:onUnZipBase()
	local this = self
    if self._unZip == nil then --大厅解压
		-- 状态提示
		self._unZip = 0
		--解压
		local dst = device.writablePath
        local filePath = cc.FileUtils:getInstance():fullPathForFilename("client.zip")
		unZipAsync(filePath,dst,function(result)
				this:onUnZipBase()
                self:getApp()._version:setZipVersion(1 ,"client")
                self:getApp()._version:setZipVersion(1 ,"base")
			end)
	elseif self._unZip == 0 then --默认游戏解压
		self._unZip = 1
		--解压
		local dst = device.writablePath
        local filePath = cc.FileUtils:getInstance():fullPathForFilename("game.zip")
		unZipAsync(filePath,dst,function(result)
				this:onUnZipBase()
			end)
	else 			-- 解压完成
		self._unZip = nil
		--更新本地版本号
        self:getApp()._version:setVersion(1)
		self:getApp()._version:setResVersion(1)
        self:getApp()._version:setZipVersion(VERSION_INIT_ZIP_BASE or 1 ,"base")
        self:getApp()._version:setZipVersion(VERSION_INIT_ZIP_CLIENT or 1 ,"client")        

        self:NewEnterGame(self.jsondata)
		return	
	end
end

function WelcomeScene:updateApp()
	if device.platform == "ios" and (type(self._iosUpdateUrl) ~= "string" or self._iosUpdateUrl == "") then
		print("ios update fail, url is nil or empty")
	else
		-- self._updateText:setString("")
        if device.platform == "android" then
            self:upDateBaseApp()
        else
 	        local dialog = QueryDialog:create("Encontre uma nova versão, vá para download! obrigado!",function(bConfirm)
	               if bConfirm == true then                    	
		    			self:upDateBaseApp()
	                end					
		    	end)
            self:addChild(dialog)
        end
		return true
	end				
end
function WelcomeScene:upDateBaseApp()
	-- self.m_progressLayer:setVisible(true)
	-- self.m_totalBar:setVisible(true)
	-- self.m_spTotalBg:setVisible(true)

	if device.platform == "android" then
		local this = self
		local argsJson 
		local url = self:getApp()._updateUrl.."/"..self._gameName..".apk"
	    local sigs = "()Ljava/lang/String;"
   		local ok,ret = luaj.callStaticMethod(BRIDGE_CLASS_ANDROID,"getSDCardDocPath",{},sigs)
   		if ok then
   			local dstpath = ret .. "/update/"
   			local filepath = dstpath .. self._gameName..".apk"
		    if cc.FileUtils:getInstance():isFileExist(filepath) then
		    	cc.FileUtils:getInstance():removeFile(filepath)
		    end
		    if false == cc.FileUtils:getInstance():isDirectoryExist(dstpath) then
		    	cc.FileUtils:getInstance():createDirectory(dstpath)
		    end
            self.sliderLine:setPercent(0)
            self.txtPercent:setString("0%")
            self.txtShow:setString("Atualizando pacote APK, aguarde...")
		    self:updateBar(0)
			downFileAsync(url,self._gameName..".apk",dstpath,function(main,sub)
					--下载回调
					if main == appdf.DOWN_PRO_INFO then --进度信息
						self:updateBar(sub)
					elseif main == appdf.DOWN_COMPELETED then --下载完毕
						self.txtShow:setString("Transferência concluída")
						--安装apk						
						local args = {filepath}
						sigs = "(Ljava/lang/String;)V"
		   				ok,ret = luaj.callStaticMethod(BRIDGE_CLASS_ANDROID, "installClient",args, sigs)
		   				if ok then
		   					os.exit(0)
		   				end
					else
						local dialog = QueryDialog:create("Download falhou,code:".. main .."\n se deve tentar novamente?",function(bReTry)
							if bReTry == true then
								this:upDateBaseApp()
							else
								os.exit(0)
							end
						end)
                        self:addChild(dialog)
					end
				end)
		else
			os.exit(0)
   		end	    
	elseif device.platform == "ios" then
		local luaoc = require "cocos.cocos2d.luaoc"
		local ok,ret  = luaoc.callStaticMethod("AppController","updateBaseClient",{url = self._iosUpdateUrl})
	    if not ok then
	        print("luaoc error:" .. ret)        
	    end
	elseif device.platform == "windows" then
        local pcExe = self:getApp()._updateUrl.."/"..self._gameName..".exe"
        CCOpenWinUrl(pcExe)
    end
end

local function split2Tab(str,delim)
	local i,j,k
	local t = {}
	k = 1
	while true do
		i,j = string.find(str,delim,k)
		if i == nil then
			table.insert(t,tonumber(string.sub(str,k)))
			return t
		end
		table.insert(t,tonumber(string.sub(str,k,i - 1)))
		k = j + 1
	end
    return t
end

function WelcomeScene:NewEnterGame(jsondata)
    local this = self
    if jsondata["update_open"] == true then  --游戏更新开关
        ylAll.UPDATE_OPEN = true
    else
        ylAll.UPDATE_OPEN = false
    end
 	--下载地址
 	this:getApp()._updateUrl = jsondata["update_url"]	
    if (g_TargetPlatform == cc.PLATFORM_OS_IPHONE or g_TargetPlatform == cc.PLATFORM_OS_IPAD) then
        this:getApp()._updateUrl = jsondata["update_url_ios"]	
    end		
    this._iosUpdateUrl = jsondata["update_url_ios"]
    -- this._newapkVersion = jsondata["apk_version"]
    this.ApplicationVersion = tonumber(jsondata["application_version"])    
    this._gameName = jsondata["apk_name"]
    local CurApplicationVersion = ""          
    local isUpdateBase = false    
    if g_TargetPlatform == cc.PLATFORM_OS_ANDROID then
        -- local ok,CurApplicationVersion = luaj.callStaticMethod(BRIDGE_CLASS_ANDROID,"getApplicationVersion",{},"()Ljava/lang/String;")
        -- print("CurApplicationVersion = ",CurApplicationVersion)
        -- if this.ApplicationVersion>tonumber(CurApplicationVersion) then
        --     local dirPath = device.writablePath
        --     cc.FileUtils:getInstance():removeDirectory(dirPath)  --更新app，先把所有的目录删除
        --     isUpdateBase = self:updateApp()
        -- end
    elseif (g_TargetPlatform == cc.PLATFORM_OS_IPHONE or g_TargetPlatform == cc.PLATFORM_OS_IPAD) then
        --TODO
        -- local dirPath = device.writablePath
        -- cc.FileUtils:getInstance():removeDirectory(dirPath)  --更新app，先把所有的目录删除
        -- isUpdateBase = self:updateApp()
        local ok,CurApplicationVersion = luaoc.callStaticMethod(BRIDGE_CLASS_IOS,"getApplicationVersion")
        -- print("CurApplicationVersion = ",CurApplicationVersion)
        local ios_new_version = tonumber(jsondata["application_version_ios"]) or 0
        -- print("ios_new_version = ",ios_new_version)
        if ios_new_version>tonumber(CurApplicationVersion) then
           local newPathUrl = jsondata["new_version_path_ios"]
        --    print("newPathUrl = ",newPathUrl)
           local paramtab = {url = newPathUrl}
           local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS_IOS,"openBrowser", paramtab)
            if not ok then
            local msg = "openBrowser luaoc error:" .. ret
                print(msg)                  
            else  
            end    

        end
    end
    if isUpdateBase == true then return end  

    local baseZip = self:getApp()._version:getZipVersion("base")
    print("local baseZip = ",baseZip)
    print("baseZip = ",jsondata["base_zip"])
    local clientZip = self:getApp()._version:getZipVersion("client")
    print("local clientZip = ",clientZip)
    print("clientZip = ",jsondata["client_zip"])
    local updateBase = false
    local updateClient = false
    ylAll.SERVER_UPDATE_DATA = jsondata
    if  baseZip < jsondata["base_zip"] then
        updateBase = true
        self:getApp()._version:setVersion(1)
        this._newBaseVersion = 1
    end
    if clientZip < jsondata["client_zip"] then
        updateClient = true
        self:getApp()._version:setResVersion(1)
        this._newResVersion = 1
    end
	if updateBase then
		-- 更新配置
	 	local updateConfig = {}
        updateConfig.isBase = true
		updateConfig.isClient = false
        updateConfig.moduleName = "base"
        updateConfig.curModuleVersion = self:getApp()._version:getZipVersion("base")
		updateConfig.newfileurl = this:getApp()._updateUrl.."/base/res/filemd5List.json"
		updateConfig.downurl = this:getApp()._updateUrl .. "/"
		updateConfig.dst = device.writablePath				
		updateConfig.src = device.writablePath.."base/res/filemd5List.json"
		table.insert(self.m_tabUpdateQueue, updateConfig)
	end	
 	this._newBaseVersion = jsondata["base_version"]
    local nNewV1 = self._newBaseVersion
	local nCurV1 = tonumber(self:getApp()._version:getVersion())
    if nNewV1 and nCurV1 and nNewV1 > nCurV1 then
		-- 更新配置	
	 	local updateConfig = {}	
        updateConfig.isBase = true   
		updateConfig.isClient = false	
        updateConfig.moduleName = "base"   
        updateConfig.curModuleVersion = self:getApp()._version:getZipVersion("base")   
		updateConfig.newfileurl = this:getApp()._updateUrl.."/base/res/filemd5List.json"	
		updateConfig.downurl = this:getApp()._updateUrl .. "/"	
		updateConfig.dst = device.writablePath					
		updateConfig.src = device.writablePath.."base/res/filemd5List.json"	
		table.insert(self.m_tabUpdateQueue, updateConfig)                	
    end   	        						
	if updateClient then
		-- 更新配置	
	 	local updateConfig = {}	
        updateConfig.isBase = false   
		updateConfig.isClient = true	
        updateConfig.moduleName = "client"   
        updateConfig.curModuleVersion = self:getApp()._version:getZipVersion("client")   
		updateConfig.newfileurl = this:getApp()._updateUrl.."/client/res/filemd5List.json"	
		updateConfig.downurl = this:getApp()._updateUrl .. "/"	
		updateConfig.dst = device.writablePath					
		updateConfig.src = device.writablePath.."client/res/filemd5List.json"	
		table.insert(self.m_tabUpdateQueue, updateConfig)	
	end		
 	this._newResVersion = jsondata["client_version"]
    local nNewV = self._newResVersion
	local nCurV = tonumber(self:getApp()._version:getResVersion())
	if nNewV and nCurV and nNewV > nCurV then 
 		-- 更新配置	
	 	local updateConfig = {}	
        updateConfig.isBase = false    
		updateConfig.isClient = true 	
        updateConfig.moduleName = "client"    
        updateConfig.curModuleVersion = self:getApp()._version:getZipVersion("client")    
		updateConfig.newfileurl = this:getApp()._updateUrl.."/client/res/filemd5List.json" 	
		updateConfig.downurl = this:getApp()._updateUrl .. "/"	
		updateConfig.dst = device.writablePath						
		updateConfig.src = device.writablePath.."client/res/filemd5List.json"	
		table.insert(self.m_tabUpdateQueue, updateConfig)               	
    end
 	--游戏列表
 	local rows = jsondata["gamecount"]	
 	this:getApp()._gameList = {}
    for i=1,rows do
 		local gameinfo = {}    
 		gameinfo._KindID = jsondata["game_update_config"][""..i][1]["wKindID"]  
        local szKindName = jsondata["game_update_config"][""..i][1]["szKindName"]
 		gameinfo._KindName = szKindName--string.lower(szKindName)
        local szModuleName = jsondata["game_update_config"][""..i][1]["szModuleName"]   
 		gameinfo._Module = string.gsub(szModuleName, "[.]", "/")    
 		gameinfo._KindVersion = jsondata["game_update_config"][""..i][1]["dwClientVersion"]
 		gameinfo._ServerResVersion = tonumber(jsondata["game_update_config"][""..i][1]["wResVersion"])    
 		gameinfo._Type = gameinfo._Module    
        gameinfo._TypeId = tonumber(jsondata["game_update_config"][""..i][1]["wTypeID"])    
 		--检查本地文件是否存在    
 		local path = device.writablePath .. "game/" .. gameinfo._Module    
 		gameinfo._Active = cc.FileUtils:getInstance():isDirectoryExist(path)    
 		local e = string.find(gameinfo._KindName, "[.]")    
 		if e then    
 			gameinfo._Type = string.sub(gameinfo._KindName,1,e - 1)    
 		end    
 		-- 排序    
        local sortID = jsondata["game_update_config"][""..i][1]["SortID"]
 		gameinfo._SortId = tonumber(sortID) or 0    
 		table.insert(this:getApp()._gameList, gameinfo)    
 	end
 	table.sort( this:getApp()._gameList, function(a, b)
 		return a._SortId > b._SortId
 	end)
    self:onEnterGame()        
end

function WelcomeScene:onEnterGame()
    --升级判断
    local bUpdate = false
    local isWin32 =  (g_TargetPlatform == cc.PLATFORM_OS_WINDOWS)
	if ylAll.UPDATE_OPEN and  not isWin32 then   --update
		bUpdate = self:updateClient()
	else
		self:getApp()._version:setResVersion(self._newResVersion)
	end
    if not bUpdate then
        self:EnterClient()
    end
end

--进入登录界面
function  WelcomeScene:EnterClient()
    if self.isNeedReStart == true then
        self.isNeedReStart = false
        local dialog = QueryDialog:create("A atualização está concluída, reinicie o jogo!",function(bReTry)
   		     os.exit(0)
	    end, true)      
        self:addChild(dialog)     
        return 
    end    
    local logonLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.login.LogonScene").new(self)
    self:addChild(logonLayer,1)
end

function WelcomeScene:QuitTips()
 	local dialog = QueryDialog:create("A solicitação de rede expirou, se deve tentar novamente!",function(bConfirm)
			if bConfirm then
                self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                    self:onHandlerWelcomeHttp()
                end)))
            else
                os.exit(0)	
            end				
		end)
    self:addChild(dialog)
end

--升级大厅
function WelcomeScene:updateClient()
	if 0 ~= #self.m_tabUpdateQueue then
		self:goUpdate()
		return true
	end
	return false
end

--开始下载
function WelcomeScene:goUpdate( )
	local config = self.m_tabUpdateQueue[1]
	if nil == config then
        --self:EnterClient()
        self:resetMain()
	else
        self.sliderLine:setPercent(0)
        self.txtPercent:setString("0%")
        if config.isBase == true then
            self.txtShow:setString("Os recursos principais do programa estão sendo atualizados, aguarde...")
        elseif config.isClient == true then
            self.txtShow:setString("Atualizando recursos do lobby, aguarde...")
        else
            self.txtShow:setString("Atualizando o jogo, por favor aguarde...")
        end
        local moduleVersion = self:getApp()._version:getZipVersion(config.moduleName)
		ClientUpdate:create(config.newfileurl, config.dst, config.src, config.downurl,config.moduleName,moduleVersion)
			:upDateClient(self)
	end	
end

--下载进度
function WelcomeScene:updateProgress(sub, msg, mainpersent)
	self:updateBar( math.floor(mainpersent))
    self.txtDownDesc:setString("Downloading...")
end

function WelcomeScene:upDateSuccessToUnzip(fileName,dst,moduleName,version)
    self.txtShow:setString("Descompactando, por favor aguarde")
    unZipAsync(cc.FileUtils:getInstance():fullPathForFilename(fileName),dst,function(result)
    		cc.FileUtils:getInstance():removeFile(fileName)
            version = version or 0
            self:getApp()._version:setZipVersion(version,moduleName)
            self:updateResult(true,"",true)
    	end)
end

--下载结果
function WelcomeScene:updateResult(result,msg,isZip)
	local this = self
	if result == true then
	    local config = self.m_tabUpdateQueue[1]
	    if nil ~= config then
            if true == config.isBase then
                self.isNeedReStart = true
            end
            if true == config.isBase and isZip ~= true then
                   --更新本地大厅版本
	    		self:getApp()._version:setVersion(self._newBaseVersion)
	    	elseif true == config.isClient and isZip ~= true then
	    		--更新本地大厅版本
	    		self:getApp()._version:setResVersion(self._newResVersion)
	    	end
            table.remove(self.m_tabUpdateQueue, 1)
	    	self:goUpdate()
	    else
            self.txtShow:setString("Transferência concluída")
	    	--进入登录界面
	    	--this:EnterClient()              --下载完毕，进登录界面之前要重新走一遍main.lua

            this:resetMain()
	    end
	else   
		self:updateBar(0)
        self.txtShow:setString("Download falhou")
		--重试询问
		local dialog = QueryDialog:create(msg.."\n se deve tentar novamente?",function(bReTry)
				if bReTry == true then
					this:goUpdate()
				else
					os.exit(0)
				end
			end)
        self:addChild(dialog)
	end
end

function WelcomeScene:updateBar(percent)
    self.sliderLine:setPercent(percent)
    self.sliderLine:show()
    self.txtPercent:setString( string.format("%d%%", percent))
    self.txtPercent:show()
    self.sliderHead:setPositionX(self.sliderWidth/100*percent)
end

function WelcomeScene:getMachineId()
    if g_TargetPlatform == cc.PLATFORM_OS_WINDOWS then
        local mac = CCGetWinMac()
        return md5(mac)
    elseif g_TargetPlatform == cc.PLATFORM_OS_ANDROID then        
        local sigs = "()Ljava/lang/String;"
        local func = "getUUID"
        if FunctionName and FunctionName["getUUID"] and FunctionName["getUUID"]~="" then
            func = FunctionName["getUUID"]
        end
        local ok,ret = luaj.callStaticMethod(BridgeClassName.BRIDGE_CLASS_ACTIVITY,func,{},sigs)
        if not ok then
            print("luaj error:" .. ret)
            return md5("MNADIndj1983749jdnahNNHJ")
        else
            print("The ret is:" .. ret)
            return md5(ret)
        end   
    elseif g_TargetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
       local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS_IOS,"getUUID")
       if not ok then
           print("luaj error:" .. ret)
           return md5("MNADIndj1983749jdnahNNHJ")
       else
           print("The ret is:" .. ret)
           return md5(ret)
       end
    end
end

function WelcomeScene:applyFunction(func, params)
    if func then
        if params then
            func(unpack(params))
        else
            func()
        end
    end
end

function WelcomeScene.pushCaller(tip, func, scope)
    tip = tip or "";
    local vo = { func = func, scope = scope, tip = tip };
    table.insert(_callersArr, vo);
end

--下载完毕，进登录界面之前要重新走一遍main.lua
function WelcomeScene:resetMain()
    cc.Director:getInstance():getTextureCache():removeAllTextures()
    cc.SpriteFrameCache:getInstance():removeSpriteFrames()
    cc.FileUtils:getInstance():purgeCachedEntries()
    cc.Director:getInstance():purgeCachedData()
    if tickMgr then
        tickMgr:stopTick()
    end

    local moduleStr = {"LuaDebugjit","math","string","table","io","debug","_G","coroutine"}
    for k,v in pairs(package.loaded) do
        local isHad = false
        for ks,str in pairs(moduleStr) do
            if k == str then
                isHad = true
                break
            end
        end
        if not isHad then
            package.loaded[k] = nil
        end
    end
    local array = {        
        cc.DelayTime:create(2),
        cc.CallFunc:create(function() 
            require("base.src.main")
        end)
    }
    self:runAction(cc.Sequence:create(array))
   -- require("app.MyApp").new():run(false)
end

return WelcomeScene