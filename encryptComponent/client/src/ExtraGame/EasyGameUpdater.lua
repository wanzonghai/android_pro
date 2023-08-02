--[[
    EasyGame 游戏更新与进入
    1.开发环境本地不保留EasyGame文件
    2.热更配置根据 ylAll.SERVER_UPDATE_DATA.update_url_easy_game 下version.json EasyGame 游戏厂商维护
    3.子游戏 远端存放：ylAll.SERVER_UPDATE_DATA.update_url_easy_game 下 $gameID.zip
    4.子游戏 本地存储：device.writablePath.."EasyGame/" 下
]]

local EasyGameUpdater = class("EasyGameUpdater")

EasyGameUpdater.FixInfo = {
    LocalPath = device.writablePath.."EasyGame/",
    LocalFile = device.writablePath.."EasyGame/version.json",
    RemotePath = ylAll.SERVER_UPDATE_DATA.update_url_easy_game or "",
    RemoteFile = ylAll.SERVER_UPDATE_DATA.update_url_easy_game and ylAll.SERVER_UPDATE_DATA.update_url_easy_game.."version.json" or "",
}

EasyGameUpdater.RemoteVersion = {}

function EasyGameUpdater:LoadVersion()
    --创建文件夹
    if not createDirectory(self.FixInfo.LocalPath) then
        print("创建文件夹失败")
        return
    end
    self.LocalVesion = {}
    if cc.FileUtils:getInstance():isFileExist(self.FixInfo.LocalFile) then
        local jsonStr = cc.FileUtils:getInstance():getStringFromFile(self.FixInfo.LocalFile)
        self.LocalVesion = cjson.decode(jsonStr)
    end
    local callback = function ()
        for k, v in pairs(self.RemoteVersion) do
            local pCurrent = -1
            local pItem = self.LocalVesion[k]
            if pItem and pItem.current then
                pCurrent = pItem.current
            end
            v.current= pCurrent
        end
        GlobalData.ReceiveEGSuccess = true
    end        
    appdf.onHttpJsionTable(self.FixInfo.RemoteFile,"GET","",function(jsondata,response)           
        self.RemoteVersion = jsondata or {}
        -- dump(self.RemoteVersion)
        callback()
	end)
end

--检查是否需要热更
function EasyGameUpdater:CheckFix(pID)--,pCall,updateProgress)
    -- self.pCall = pCall
    -- self.updateProgress = updateProgress
    --创建文件夹
    -- if not createDirectory(self.FixInfo.LocalPath) then
    --     print("创建文件夹失败")
    --     self.pCall(false)
    --     return
    -- end
    local pItem = self.RemoteVersion[tostring(pID)]
    if pItem then
        return pItem.current == pItem.version    
    else
        return false
    end
    -- if pItem.current == pItem.version then
    --     --本地远端版本一致
    --     --直接加载本地
    --     self.pCall(true)
    -- else
    --     -- self:StartFix(pID)

    -- end
end



--启动热更
function EasyGameUpdater:StartFix(pID,listener)
    self._listener = listener
    local fileName = pID..".zip" 
    local savePath = self.FixInfo.LocalPath                     --下载地址
    local downPath = self.FixInfo.RemotePath..fileName          --保存地址
    downFileAsync(downPath,fileName,savePath,function(main,sub) 
        if main == appdf.DOWN_PRO_INFO then --进度信息            
            -- if self.updateProgress then
            --     self.updateProgress(sub)
            -- end
            self._listener:updateProgress(nil,nil,sub)
        elseif main == appdf.DOWN_COMPELETED then --下载完毕
            self:Unzip(pID)
        else
            -- print("下载失败")
            -- self.pCall(false)
            self._listener:updateResult(false,"Download falhou,main:" .. main) --失败信息
        end
    end)  
end

--解压文件 
function EasyGameUpdater:Unzip(pID)
    local filePath = self.FixInfo.LocalPath..pID..".zip"
    local unzipPath = self.FixInfo.LocalPath..pID.."/"
    if not createDirectory(unzipPath) then
        print("创建文件夹".. pID.."失败")
        -- self.pCall(false)
        self._listener:updateResult(false,"Unzip falhou,main:" .. "can't create directory!") --失败信息
        return
    end
    unZipAsync(filePath,unzipPath,function(result)
        print("zip解压完成"..result)
        cc.FileUtils:getInstance():removeFile(self.FixInfo.LocalPath..pID..".zip")
        self:SaveFile(pID)  --下载解压完，保存新的配置文件
    end)  
end

--覆盖保存config文件
function EasyGameUpdater:SaveFile(pID)
    self.RemoteVersion[tostring(pID)] = self.RemoteVersion[tostring(pID)] or {}
    self.RemoteVersion[tostring(pID)].version = self.RemoteVersion[tostring(pID)].version or 1
    self.RemoteVersion[tostring(pID)].current = self.RemoteVersion[tostring(pID)].version
    local dir = self.FixInfo.LocalFile
    local hfile = io.open(self.FixInfo.LocalFile, "w+")    
    hfile:write(cjson.encode(self.RemoteVersion))
    hfile:close()
    -- self.pCall(true)
    self._listener:updateResult(true,"") --更新完毕
end

--进入游戏
function EasyGameUpdater:EnterGame(pID,pExtraParams)    
    local path = ""
    local url = ""    
    path = "file://"..self.FixInfo.LocalPath..tostring(pID).."/" --热更目录
    url = path.."index.html?"..pExtraParams

    if OSUtil.isFolderExists(path) then
        print("目录存在："..path)
        if io.exists(url) then
            print("文件存在：："..url)
        end
    end    
    
    local webView = ccexp.WebView:create()
    webView:setContentSize(cc.size(display.width,display.height))    
    webView:setAnchorPoint(cc.p(0,0))
    webView:setJavascriptInterfaceScheme("lua")
    if webView.setOnJSCallback == nil then
        print("lua 未绑定 setOnJSCallback ,请更新项目引擎代码")
        -- return
    else
        webView:setOnJSCallback(function(sender,url)  
            if url == "lua://Close.api.command" then
                self.webView:removeFromParent()
                self.webView = nil
                G_GameFrame:StandUp()
                G_ServerMgr:C2S_RequestUserGold()
                G_event:NotifyEvent(G_eventDef.UI_EXIT_TABLE)
            end
            if url == "lua://args?" then
                --回传参数
            end
        end)
    end
    
    webView:setScalesPageToFit(true)
    webView:loadURL(url)
    local parent = cc.Director:getInstance():getRunningScene()
    parent:addChild(webView)
    self.webView = webView    
    G_event:NotifyEvent(G_eventDef.UI_GAMEKIND_ONEXIT)
    webView:setOnShouldStartLoading(function(sender,url)
        print("setOnShouldStartLoading url is " , url)
        local target = cc.Application:getInstance():getTargetPlatform()
	    if target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
            if url == "lua://Close.api.command" then
                self.webView:removeFromParent()
                self.webView = nil
                G_GameFrame:StandUp()
                G_ServerMgr:C2S_RequestUserGold()
                G_event:NotifyEvent(G_eventDef.UI_EXIT_TABLE)            
            end
            if url == "lua://args?" then
                --回传参数
            end
        end
        return true
    end)
    webView:setOnDidFinishLoading(function(sender,url)
        print("onWebView1DidFinishLoading url is " , url)
    end)
    webView:setOnDidFailLoading(function(sender,url)
        print("onWebView1DidFailLoading url is " , url)
    end)  
    webView:reload()


    -- local jsfunc = [[
    --     window.showBtn("document.location = 'lua://Close.api.command'")
    -- ]]
    -- performWithDelay(webView,function() 
    --     print("调用了JS关闭webView")
    --     webView:evaluateJS(jsfunc)
    -- end,10)

    -- --物理返回键 关掉 webView
    -- if g_TargetPlatform ~= cc.PLATFORM_OS_WINDOWS then
    --     --保存基类onExitApp
    --     self.m_superExit = self.super.onExitApp
    --     --覆盖基类onExitApp方法
    --     self.super.onExitApp = function() 
    --         print("我来了")
    --         self.webView:removeFromParent()
    --         --恢复onExitApp
    --         self.super.onExitApp = self.m_superExit
    --     end
    -- end
end

return EasyGameUpdater