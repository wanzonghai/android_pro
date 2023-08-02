
local LogonScene = class("LogonScene", function() 
    local LogonScene =  display.newLayer()
    return LogonScene
end)
appdf.req(appdf.CLIENT_SRC.."UIManager.PreLoadingLoginRes")
appdf.req(appdf.CLIENT_SRC.."UIManager.LoadingLayer")
appdf.req(appdf.CLIENT_SRC.."UIManager.ReconnectLayer")
appdf.req(appdf.CLIENT_SRC.."Tools.ToolsInit")
appdf.req(appdf.CLIENT_SRC.."NetProtocol.NetInit")
appdf.req(appdf.CLIENT_SRC.."Tools.GlobalData")
appdf.req(appdf.CLIENT_SRC.."Tools.HeadSprite")
local LoadingHelper = appdf.req(appdf.CLIENT_SRC.."Tools.Load.LoadingHelper")
-- local TurnTableManager = appdf.req(appdf.CLIENT_SRC..".UIManager.hall.subinterface.TurnTable.TurnTableManager")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
--EasyGame 更新器
g_EasyGameUpdater = appdf.req(appdf.CLIENT_SRC.."ExtraGame.EasyGameUpdater")

PicCachedSps   = {}
local m_frameCache = nil

local Localization   = cc.UserDefault:getInstance()

local m_bFirst = true --是否首次登录

function LogonScene:onEnterTransitionFinish()
    AudioEngine.stopMusic() -- 暂停音乐 
    cc.Director:getInstance():getTextureCache():removeAllTextures()
    cc.SpriteFrameCache:getInstance():removeSpriteFrames()
    display.removeUnusedSpriteFrames()
    cc.Director:getInstance():purgeCachedData()
    EventPost:addCommond(EventPost.eventType.PV,"点击进入登录页",4,nil)
    -- --网络监测完成，缓出登录部分
    local pComplete = function()
        showNetLoading()
        self.PanelTips:hide()
        self.PanelLogon:runAction(cc.MoveBy:create(0.3,cc.p(0,330)))
        tickMgr:delayedCall(handler(self,self.DealAutoLogin),1000)
    end

    --Tips:
    -- CCGetReadyServerCount 为新增检测网络接口
    -- 需要更新底层，先检测该方法是否存在，
    -- 不存在的旧版使用延时等待
    -- 存在的新版使用定时获取结果
    if CCGetReadyServerCount then
        self.remainTime = 8
        local function endfunc()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            self.schedulerID=nil
            pComplete()
        end
        self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,function(dt)
            self.remainTime = self.remainTime - 0.1
            local pCount = CCGetReadyServerCount()
            print("pCount = ",pCount)
            if self.remainTime < 0 or pCount>0 then
                self.remainTime = 0
            end
            if self.remainTime == 0 and self.schedulerID~=nil then
                endfunc()
            end
        end),0.1,false)
    else
        --增加检测网络耗时    
        local delay = math.random(2500,3500)/1000
        self.PanelTips:show()
        self:updateLoading(delay, pComplete)
    end

    return self
end
-- 退出场景而且开始过渡动画时候触发。
function LogonScene:onExitTransitionStart()
    self:onRemoveListen()
    return self
end
function LogonScene:clearResource()
	for i,v in ipairs(PicCachedSps) do
		v:release()
	end
	PicCachedSps = {}
    -- TurnTableManager.clear()
end
-- 初始化界面
function LogonScene:ctor(scene,needBg)   
    --EasyGame 更新器 同步远端版本 加载本地版本
    g_EasyGameUpdater:LoadVersion() 
	print("LogonScene:onCreate")
    --设置帧率
    local director = cc.Director:getInstance()
    --设置最大帧率
    director:setAnimationInterval(1.0/60)--30帧每秒
    
    self._scene = scene
    self:clearResource()
    self._isLoading = false
    GlobalUserItem.roomIpAddresslist ={}

    self._logonSuccess = false
    self._loadingPercentObj = { value = 0 }
    collectgarbage("collect")     --把contentStr给gc掉

	local this = self
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			this:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			this:onExitTransitionStart()
		elseif eventType == "exit" then
            self:unScheduleCountDwon()
		end
	end)
    local csbNode = g_ExternalFun.loadCSB("logon/logonLayer.csb",self)    
    local content = csbNode:getChildByName("content")
    self.content = content
    csbNode:setContentSize(display.width,display.height)
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)
    local bg = content:getChildByName("Image_3")    
    if display.width  > 2560 then
        bg:setScale(display.width/2560)
        local pLogo = bg:getChildByName("desk")
        pLogo:setScale(2560/display.width)
    end
    ccui.Helper:doLayout(csbNode)

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
    -- local skeletonNode = sp.SkeletonAnimation:create("client/res/spine/juese.json", "client/res/spine/juese.atlas", 1)
    -- skeletonNode:addAnimation(0, "daiji", true)
    -- skeletonNode:setPosition(0,0)
    -- self.heroNode:addChild(skeletonNode)
    --PanelTips
    self.PanelTips = content:getChildByName("PanelTips")
    self.sliderBG = self.PanelTips:getChildByName("sliderBG")
    self.sliderLine = self.sliderBG:getChildByName("sliderLine")
    self.sliderHead = self.sliderLine:getChildByName("light")
    self.sliderWidth = self.sliderLine:getContentSize().width
    self.sliderLine:setPercent(0)
    self.txtPercent = self.PanelTips:getChildByName("txtPercent")
    self.PanelTips:hide()
    --PanelLogon
    self.PanelLogon = content:getChildByName("PanelLogon")
    self.btnPhone = self.PanelLogon:getChildByName("btnPhone")    
    self.btnGoogle = self.PanelLogon:getChildByName("btnGoogle")
    self.btnAccount = self.PanelLogon:getChildByName("btnAccount")            
    self.PanelLogon:setPositionY(-330)
    self.PanelLogon:show()
    self.btnPhone:onClicked(function()
        if self._isLoading then
            return
        end
        self:onOpenPhoneLogin()
    end)    
    self.btnGoogle:onClicked(function()
        if self._isLoading then
            return
        end
        self:onGoogleLogin()
    end)
    self.btnAccount:onClicked(function()
        if self._isLoading then
            return
        end
        self:onGuestLogin()
    end)

    --修复按钮
    self.btnRest = content:getChildByName("BtnRest")    
    self.btnRest:onClicked(handler(self, self.ResetUpdate))
    self:ShowResetBtn()

    --客服按钮
    self.btnService = content:getChildByName("BtnService")
    self.btnService:show()
    self.btnService:onClicked(handler(self,self.onServiceClicked))

    local zipBase = self._scene:getApp()._version:getZipVersion("base")
    local zipClient = self._scene:getApp()._version:getZipVersion("client")
    local resBase = self._scene:getApp()._version:getVersion()
    local resClient = self._scene:getApp()._version:getResVersion()
    local txtVer = self.PanelLogon:getChildByName("txtVer")
    txtVer:setString("V " .. zipBase.."."..resBase.."."..zipClient.."."..resClient)

	--读取配置
	GlobalUserItem.LoadData()
    GlobalData.FirstOpenBank = true

    m_frameCache = cc.SpriteFrameCache:getInstance()
    tickMgr:delayedCall(handler(self,self.CompatibleNewUI),500)
    GlobalUserItem.m_tabOriginGameList = self._scene:getApp()._gameList
    self:onAddEventListen()
    --新版测试
    self:DealTest()
end

function LogonScene:ShowResetBtn()
    self.btnRest:setVisible(false)
    -- if m_bFirst then
    --     local delay = cc.DelayTime:create(3.0)
    --     self.btnRest:runAction(cc.Sequence:create(delay, cc.Show:create()))
    --     m_bFirst = false
    -- end
end

function LogonScene:ResetUpdate()
    if self._isLoading then
        return
    end
    if g_TargetPlatform ~= cc.PLATFORM_OS_WINDOWS then
        local dirPath = device.writablePath
        cc.FileUtils:getInstance():removeDirectory(dirPath)  --先把所有的目录删除
    end
    self._scene:resetMain()
end

function LogonScene:onServiceClicked()
    local pLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.subinterface.HallServiceLayer").new()
    pLayer:setDefault()
end

function LogonScene:DealTest()
    if not ylAll.HotfixUrl then
        return
    end   
    --记录还原点
    self.Restore = {        
        ServerLocal = Localization:getStringForKey("ServerUrl",""..ylAll.ServerUrl[ylAll.ProjectSelect][ylAll.ServerSelect]),
        MachineLocal= Localization:getStringForKey("MachineLocal",""),
        LocalTest = ylAll.LocalTest,
        ProjectSelect = ylAll.ProjectSelect,
        HotfixSelect = ylAll.HotfixSelect,
        ServerSelect = ylAll.ServerSelect,
    }
    --测试入口按钮
    self.BtnTest = self.content:getChildByName("BtnTest")
    --测试面板
    self.PanelTest = self.content:getChildByName("PanelTest")
    g_ExternalFun.loadChildrenHandler(self,self.PanelTest)

    --测试入口响应
    self.BtnTest:onClicked(function()
        --2S内触发4次 则响应呼出测试面板        
        self.BtnTestClickTime = self.BtnTestClickTime or os.time()        
        self.BtnTestClickTimes = self.BtnTestClickTimes or 0
        self.BtnTestClickTimes = self.BtnTestClickTimes + 1        
        if os.time() - self.BtnTestClickTime <= 2 then
            if self.BtnTestClickTimes<4 then
                return
            else
                self.BtnTestClickTime = nil        
                self.BtnTestClickTimes = nil
                self:refreshTestPanel()
                self.PanelTest:show()
                self.PanelTest:runAction(cc.MoveTo:create(0.5,cc.p(display.cx,1000)))
                return     
            end
        else
            self.BtnTestClickTime = nil        
            self.BtnTestClickTimes = nil
            return    
        end        
    end)
    self.mm_ServerPath = self.mm_ServerPath:convertToEditBox()
    self.mm_MachinePath = self.mm_MachinePath:convertToEditBox()
    --开启测试按钮
    local pBtnList = {
        self.mm_TestBtn1,               --开启测试
        self.mm_TestBtn2,               --关闭测试
        self.mm_ProjectBtn1,            --金币项目
        self.mm_ProjectBtn2,            --真金项目
        self.mm_HotfixBtn1,             --热更A*
        self.mm_HotfixBtn2,             --热更测试服
        self.mm_HotfixBtn3,             --热更平行服
        self.mm_HotfixBtn4,             --热更正式服
        self.mm_ServerBtn1,             --服务器自定义
        self.mm_ServerBtn2,             --服务器测试服
        self.mm_ServerBtn3,             --服务器平行服
        self.mm_ServerBtn4,             --服务器正式服
        self.mm_ServerConfirm,          --修改服务器地址    
        self.mm_MachineConfirm,           --确定机器码
        self.mm_BtnConfirm,             --确认
        self.mm_BtnCancel,              --取消
    }

    for i, v in ipairs(pBtnList) do
        v:onClicked(function (target)
            local pName = target:getName()
            if pName == "TestBtn1" then
                ylAll.LocalTest = true                
            elseif pName == "TestBtn2" then
                ylAll.LocalTest = false
            elseif pName == "ProjectBtn1" then
                ylAll.ProjectSelect = 1
            elseif pName == "ProjectBtn2" then
                ylAll.ProjectSelect = 2            
            elseif pName == "HotfixBtn1" then
                ylAll.HotfixSelect = 1
            elseif pName == "HotfixBtn2" then
                ylAll.HotfixSelect = 2
            elseif pName == "HotfixBtn3" then
                ylAll.HotfixSelect = 3
            elseif pName == "HotfixBtn4" then
                ylAll.HotfixSelect = 4                           
            elseif pName == "ServerBtn1" then
                ylAll.ServerSelect = 1
            elseif pName == "ServerBtn2" then                
                ylAll.ServerSelect = 2
            elseif pName == "ServerBtn3" then
                ylAll.ServerSelect = 3
            elseif pName == "ServerBtn4" then
                ylAll.ServerSelect = 4
            elseif pName == "ServerConfirm" then                                
                local pString = self.mm_ServerPath:getString()
                ylAll.ServerUrl[ylAll.ProjectSelect][ylAll.ServerSelect] = pString                                
                Localization:setStringForKey("ServerUrl",pString)
                Localization:flush()                
            elseif pName == "MachineConfirm" then
                local pString = self.mm_MachinePath:getString()                
                Localization:setStringForKey("MachineLocal",pString)                
                Localization:flush()                
            elseif pName == "BtnConfirm" then                
                Localization:setBoolForKey("LocalTest",ylAll.LocalTest)
                Localization:setIntegerForKey("ProjectSelect",ylAll.ProjectSelect)
                Localization:setIntegerForKey("HotfixSelect", ylAll.HotfixSelect)
                Localization:setIntegerForKey("ServerSelect", ylAll.ServerSelect)                                
                Localization:flush()                
                tickMgr:delayedCall(function ()
                    os.exit(0)
                end,1000)
            elseif pName == "BtnCancel" then
                ylAll.LocalTest = self.Restore.LocalTest
                ylAll.ProjectSelect = self.Restore.ProjectSelect
                ylAll.HotfixSelect = self.Restore.HotfixSelect
                ylAll.ServerSelect = self.Restore.ServerSelect 
                                
                Localization:setStringForKey("ServerUrl","")
                if ylAll.ServerSelect == 1 then
                    Localization:setStringForKey("ServerUrl",self.Restore.ServerLocal)
                    ylAll.ServerUrl[ylAll.ProjectSelect][ylAll.ServerSelect] = self.Restore.ServerLocal
                end
                Localization:setStringForKey("MachineLocal",self.Restore.MachineLocal)                
                Localization:flush()
            end            
            self:refreshTestPanel()
        end)
    end

    
    if ylAll.LocalTest then
        self:refreshTestPanel()
        self.PanelTest:show()
        self.PanelTest:runAction(cc.MoveTo:create(0.5,cc.p(display.cx,1000)))
    else
        self.PanelTest:hide()
        self.PanelTest:setPosition(cc.p(display.cx,1680))        
    end
end

--刷新测试面板
function LogonScene:refreshTestPanel()
    local ColorG = cc.c3b(0,128,0)
    local ColorB = cc.c3b(0,0,0)
    --测试选择
    --开启测试
    self.mm_TestBtn1:getChildByName("check"):setSelected(ylAll.LocalTest)
    self.mm_TestBtn1:getChildByName("desc"):setTextColor(ylAll.LocalTest and ColorG or ColorB)
    --关闭测试
    self.mm_TestBtn2:getChildByName("check"):setSelected(not ylAll.LocalTest)
    self.mm_TestBtn2:getChildByName("desc"):setTextColor(ylAll.LocalTest and ColorB or ColorG)
    --项目选择
    --金币项目
    self.mm_ProjectBtn1:getChildByName("check"):setSelected(ylAll.ProjectSelect==1)
    self.mm_ProjectBtn1:getChildByName("desc"):setTextColor(ylAll.ProjectSelect==1 and ColorG or ColorB)
    --真金项目
    self.mm_ProjectBtn2:getChildByName("check"):setSelected(ylAll.ProjectSelect==2)
    self.mm_ProjectBtn2:getChildByName("desc"):setTextColor(ylAll.ProjectSelect==2 and ColorG or ColorB)
    g_format = appdf.req(appdf.CLIENT_SRC.."Tools.format.formatBase").new(ylAll.ProjectSelect)
    --热更选择
    --热更A*
    self.mm_HotfixBtn1:getChildByName("check"):setSelected(ylAll.HotfixSelect==1)
    self.mm_HotfixBtn1:getChildByName("desc"):setTextColor(ylAll.HotfixSelect==1 and ColorG or ColorB)
    --测试服
    self.mm_HotfixBtn2:getChildByName("check"):setSelected(ylAll.HotfixSelect==2)
    self.mm_HotfixBtn2:getChildByName("desc"):setTextColor(ylAll.HotfixSelect==2 and ColorG or ColorB)
    --平行服
    self.mm_HotfixBtn3:getChildByName("check"):setSelected(ylAll.HotfixSelect==3)
    self.mm_HotfixBtn3:getChildByName("desc"):setTextColor(ylAll.HotfixSelect==3 and ColorG or ColorB)
    --正式服
    self.mm_HotfixBtn4:getChildByName("check"):setSelected(ylAll.HotfixSelect==4)
    self.mm_HotfixBtn4:getChildByName("desc"):setTextColor(ylAll.HotfixSelect==4 and ColorG or ColorB)
    ylAll.Request_HttpUrl = ylAll.HotfixUrl[ylAll.ProjectSelect][ylAll.HotfixSelect]
    self.mm_HotfixPath:setString(ylAll.Request_HttpUrl)

    --服务器选择
    --服务器自定义
    self.mm_ServerBtn1:getChildByName("check"):setSelected(ylAll.ServerSelect==1)
    self.mm_ServerBtn1:getChildByName("desc"):setTextColor(ylAll.ServerSelect==1 and ColorG or ColorB)
    --测试服
    self.mm_ServerBtn2:getChildByName("check"):setSelected(ylAll.ServerSelect==2)
    self.mm_ServerBtn2:getChildByName("desc"):setTextColor(ylAll.ServerSelect==2 and ColorG or ColorB)
    --平行服
    self.mm_ServerBtn3:getChildByName("check"):setSelected(ylAll.ServerSelect==3)
    self.mm_ServerBtn3:getChildByName("desc"):setTextColor(ylAll.ServerSelect==3 and ColorG or ColorB)
    --正式服
    self.mm_ServerBtn4:getChildByName("check"):setSelected(ylAll.ServerSelect==4)
    self.mm_ServerBtn4:getChildByName("desc"):setTextColor(ylAll.ServerSelect==4 and ColorG or ColorB)
    self.mm_ServerPath:setString(ylAll.ServerUrl[ylAll.ProjectSelect][ylAll.ServerSelect])
    self.mm_ServerPath:setEnabled(ylAll.ServerSelect == 1)
    self.mm_ServerConfirm:setVisible(ylAll.ServerSelect == 1)
    local pServerUrl = ylAll.ServerUrl[ylAll.ProjectSelect][ylAll.ServerSelect]
    local pArray = string.split(pServerUrl,"@")
    ylAll.LOGONSERVER_LIST = {{id= pArray[1],ip= pArray[2]}}
    for i,v in pairs(ylAll.LOGONSERVER_LIST) do
        CCInitTesterServer(v.id,v.ip) 
    end
    --机器码
    self.mm_MachinePath:setString(Localization:getStringForKey("MachineLocal",""))
end

function LogonScene:DealObsoleteTest()
    self.PanelTestObsolete = self.content:getChildByName("PanelTestObsolete")
    self.PanelTestObsolete:setVisible(ylAll.LocalTest)
    if not ylAll.LocalTest then
        return
    end
    self.inputIp = self.PanelTestObsolete:getChildByName("inputIp"):convertToEditBox()
    self.inputMachine = self.PanelTestObsolete:getChildByName("inputMachine"):convertToEditBox()
    local curIp = cc.UserDefault:getInstance():getStringForKey("inputIp","115@47.242.45.155:2701|1")
    local curMachine = cc.UserDefault:getInstance():getStringForKey("inputMachine","")
    if curIp ~= "" then
        local ipArray = string.split(curIp,"@")
        self.inputIp:setString(curIp)
        ylAll.LOGONSERVER_LIST = {{id= ipArray[1],ip= ipArray[2]}}
        for i,v in pairs(ylAll.LOGONSERVER_LIST) do
            CCInitTesterServer(v.id,v.ip) 
        end
    end
    if curMachine ~= "" then
        self.inputMachine:setString(curMachine)
    end
    self.PanelTestObsolete:getChildByName("btnSure"):onClicked(function()
        local inputIp = self.inputIp:getString()
        local inputMacine = self.inputMachine:getString()
        if inputIp == "" then
            showToast("Please input IP")
            return
        end
        if inputIp ~= "" then
            local ipArray = string.split(inputIp,"@")
            if ipArray == nil or ipArray[1] == nil or ipArray[2] == nil then
                self.inputIp:setString("")
                showToast("input like: 123@127.0.0.1|1")
                return
            end
            cc.UserDefault:getInstance():setStringForKey("inputIp",inputIp)
            ylAll.LOGONSERVER_LIST = {{id= ipArray[1],ip= ipArray[2]}}
            for i,v in pairs(ylAll.LOGONSERVER_LIST) do
                CCInitTesterServer(v.id,v.ip) 
            end
        end
        if inputMacine ~= "" then
            cc.UserDefault:getInstance():setStringForKey("inputMachine",inputMacine)
        end
        showToast("SET SUCCESS")
    end)
    self.PanelTestObsolete:getChildByName("btnClear"):onClicked(function()
        self.inputIp:setString("")
        self.inputMachine:setString("")
        cc.UserDefault:getInstance():setStringForKey("inputIp","")
        cc.UserDefault:getInstance():setStringForKey("inputMachine","")
    end)
end

function LogonScene:DealAutoLogin()
    dismissNetLoading()
    --开启测试则关闭自动登录功能
    if ylAll.LocalTest then
        return
    end

    --记录登录信息
    GlobalUserItem.GetLocalization()

    if GlobalUserItem.LoginType == 0 then
        --游客登录
        self:onGuestLogin()
    elseif GlobalUserItem.LoginType == 2 or GlobalUserItem.LoginType == 3 then
        --社交登录
        self:onThirdAuthCallback(GlobalUserItem.LoginData)
    else                                --手机号登录

    end
end

function LogonScene:onCheckNotice()

end

function LogonScene:CompatibleNewUI()
    uiMgr:setCurScene(cc.Director:getInstance():getRunningScene(),"LoginScene")
end

function LogonScene:unScheduleCountDwon()
    if self._processTimer ~= nil then
       self._processTimer:destroy()
       self._processTimer = nil
    end
end
--打开绑定界面用作手机登录
function LogonScene:onOpenPhoneLogin()
    local args = {callback = nil,NoticeNext = false,ShowType = 2}--2:登录
    local pLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.subinterface.authentication.HallMessageLayer").new(args)
end
--手机登录  
function LogonScene:onPhoneLogin(pData)
    self:ShowloadingBar()
    self:CheckLoginTimeout()
    self.LoginData = {1}
    G_ServerMgr:checkConnectStatus()
    G_ServerMgr:C2S_LogonByPhone(pData)
end
--fb登录
function LogonScene:onFacebookLogin()       
    g_MultiPlatform:getInstance():FaceBookLogin()    
end
--google 登录
function LogonScene:onGoogleLogin()
    g_MultiPlatform:getInstance():GoogleLogin()
end
--游客登录
function LogonScene:onGuestLogin()
    if self._isLoading then
        return
    end
    self:ShowloadingBar()
    self:CheckLoginTimeout()
    self.LoginData = {0}
    G_ServerMgr:checkConnectStatus()
    G_ServerMgr:C2S_LogonByVisitor()
end

function LogonScene:onAddEventListen()
    G_event:AddNotifyEvent(G_eventDef.UI_THIRD_AUTH_CALLBACK,handler(self,self.onThirdAuthCallback))     --第三方授权
    G_event:AddNotifyEvent(G_eventDef.NET_LOGON_HALL_SUCCESS,handler(self,self.LogonSuccess))     --登录成功
    G_event:AddNotifyEvent(G_eventDef.NET_LOGON_HALL_FAILER,handler(self,self.LogonFailer))
    G_event:AddNotifyEvent(G_eventDef.NET_NEED_RELOGIN,handler(self,self.NeedLogin))
    G_event:AddNotifyEventTwo(self,G_eventDef.NET_NETWORK_ERROR,handler(self,self.NetworkError))
    G_event:AddNotifyEvent(G_eventDef.EVENT_START_PHONE_LOGIN,handler(self,self.onPhoneLogin))  --开始手机登录
end
function LogonScene:onRemoveListen()
    G_event:RemoveNotifyEvent(G_eventDef.UI_THIRD_AUTH_CALLBACK)
    G_event:RemoveNotifyEvent(G_eventDef.NET_LOGON_HALL_SUCCESS)
    G_event:RemoveNotifyEvent(G_eventDef.NET_LOGON_HALL_FAILER)
    G_event:RemoveNotifyEvent(G_eventDef.NET_NEED_RELOGIN)
    G_event:RemoveNotifyEventTwo(self,G_eventDef.NET_NETWORK_ERROR)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_START_PHONE_LOGIN)
end
function LogonScene:onThirdAuthCallback(args)
    self:ShowloadingBar()
    local data = args.data
    GlobalUserItem.headUrl = data.headUrl
    self.LoginData = {
        data.LoginType,
        data.uniqueId,
        data.gender,
        data.name,
        data.token,
        data.email,
        data.headUrl
    }
    --判断字符长度，不超过31位(汉字算1位)
    local length, newStr = g_ExternalFun.getUtf8Len(data.name)
    local dstLength = G_NetLength.LEN_NICKNAME - 1
    if length > dstLength then
        newStr = g_ExternalFun.getDstLengthStr(newStr, dstLength, dstLength)
    end
    print("onThirdAuthCallback ", length, data.name, newStr)
    G_ServerMgr:checkConnectStatus()
    G_ServerMgr:C2S_LogonByThirdParty(data.LoginType,data.uniqueId,data.gender,newStr,data.token,data.email,data.headUrl)
end
--登录成功
function LogonScene:LogonSuccess(args)    
    self._logonSuccess = true 
    self:stopAllActions()
    g_redPoint:initSaveTab()
    
    local fire = 1
    if self.LoginData[1] == 0 then   
        fire = 1
    elseif self.LoginData[1] == 2 then
        fire = 2
    elseif self.LoginData[1] == 3 then  
        fire = 3
    end 
    g_MultiPlatform:getInstance():threeLogEvent(fire) 
   -- self.PanelTips
    --记录登录信息
    GlobalUserItem.SetLocalization(self.LoginData)
    self.PanelTips:show()
    self.sliderLine:setPercent(0)
    self.sliderHead:setPositionX(1)  
    self.txtPercent:setString("0%")
    local Flag = true
    LoadingHelper.loadLobbyPlist(function(resIndex, total,resoucesAmount,isError)           --预加载资源
        self._isLoading = (not isError)
        local percent = resIndex/resoucesAmount
        self.sliderLine:setPercent(percent * 100)
        self.sliderHead:setPositionX(percent * self.sliderWidth)
        self.txtPercent:setString(string.format("%s%%",math.floor(percent * 100)))
        if Flag and resIndex >= resoucesAmount then              --说明加载完毕，进入游戏
            Flag = false
            LoadingHelper.stop()                        --加载完毕后清理
            dismissNetLoading() 
            self._scene:getApp():enterSceneEx(appdf.CLIENT_SRC.."UIManager.hall.ClientScene",nil,0)
        end
    end,true)

    if ALARM_NOTIFICATION_OPEN then
        --支持定时通知
        --g_MultiPlatform:getInstance():PushNotification(GlobalData.Notification[1][1],GlobalData.Notification[1][2])
        --g_MultiPlatform:getInstance():PushImageNotification("http://172.17.18.61/ComponentLocal/Noti/image_notification_1_1.png","http://172.17.18.61/ComponentLocal/Noti/image_notification_1_2.png")
        local pCount = ylAll.SERVER_UPDATE_DATA.NotificationCount or 5
        local pURL = ylAll.SERVER_UPDATE_DATA.NotificationURL or ""
        local pRule = ylAll.SERVER_UPDATE_DATA.NotificationRule or 1
        g_MultiPlatform:getInstance():SetAlarmNotification(pCount,pURL,pRule)
    else
        --未支持定时通知，继续走之前的通知
        g_MultiPlatform:getInstance():PushNotification(GlobalData.Notification[1][1],GlobalData.Notification[1][2])        
    end
end

function LogonScene:CheckLoginTimeout()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(8),cc.CallFunc:create(function()
        -- showToast(g_language:getString("network_timeout"))   
        G_ServerMgr:CloseToSocket()
        self:LogonFailer()   
        onRequestIpAddress()   
    end)))
end
--登录失败
function LogonScene:LogonFailer(args)
    self.PanelLogon:setVisible(true)
    dismissNetLoading()
end

--网络错误
function LogonScene:NetworkError()
    if netLoadingShowing() then
        -- showToast(g_language:getString("network_timeout"))
    end
    self:LogonFailer()
    self:stopAllActions()
    onRequestIpAddress()
end
function LogonScene:NeedLogin()
    self:stopAllActions()
    self:LogonFailer()
end
--login bar
function LogonScene:ShowloadingBar()
    showNetLoading()
    self.PanelLogon:setVisible(true)
end

function LogonScene:updateLoading(durationS,onCompleteCallback)
	local function onUpdate()
        if self.sliderLine then
            local per = 10 + self._loadingPercentObj.value * 90 / 100
            if per >100 then per = 100 end
            self.sliderLine:setPercent(per)
            self.sliderHead:setPositionX(self.sliderWidth/100*per)
            local str = string.format("%d%%", per)
            self.txtPercent:setString(str)
        end		
	end

	local function onComplete()
        applyFunction(onCompleteCallback)
	end
	durationS = durationS or 0.5;
	TweenLite.to(self._loadingPercentObj, durationS, { value = 100, onComplete = onComplete, onUpdate = onUpdate })     
end

return LogonScene
