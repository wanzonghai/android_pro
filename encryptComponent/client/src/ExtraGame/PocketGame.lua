--[[
    Pocket Games 游戏进入
]]
local PocketGame = class("PocketGame")

--进入游戏
function PocketGame:EnterGame(pID,pExtraParams,cbGameMode)
    --切换竖版
    local result = g_MultiPlatform:getInstance():ChangeOrientation(0)
    if result then
        uiMgr:onIsScreenOrientationRotatedChanged(0)
    end
    local P1,P2,pRoomID = string.find(pExtraParams,"roomID=(%d+)")    
    local pID = pRoomID or pID
    GlobalUserItem.roomMark = tonumber(pID)*1000+100
    
    local url = ""    
    url = pExtraParams
    if self.webView and not tolua.isnull(self.webView) then
        self.webView:loadURL(url)
        return
    end
    local webView = ccexp.WebView:create()
    print("display.width = ",display.width)
    print("display.height = ",display.height)
    webView:setContentSize(cc.size(display.width,display.height))    
    -- webView:setContentSize(cc.size(324,720))    
    webView:setAnchorPoint(cc.p(0.5,0.5))     
    
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
                self:SetPocketGameStatus(false) 
                --切换横板
                local result = g_MultiPlatform:getInstance():ChangeOrientation(1)
                if result then
                    uiMgr:onIsScreenOrientationRotatedChanged(1)
                end
            end
            if url == "lua://args?" then
                --回传参数
            end
        end)
    end
    
    webView:setScalesPageToFit(true)
    webView:loadURL(url)
    local parent = cc.Director:getInstance():getRunningScene()
    local pSize = parent:getContentSize()
    parent:addChild(webView)
    webView:setPosition(cc.p(display.width/2,display.height/2))
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
                self:SetPocketGameStatus(false)
                --切换横板
                local result = g_MultiPlatform:getInstance():ChangeOrientation(1)
                if result then
                    uiMgr:onIsScreenOrientationRotatedChanged(1)
                end        
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
    self:SetPocketGameStatus(true)
end

function PocketGame:GetPocketGameStatus()
    return self.PocketGameStatus
end

function PocketGame:SetPocketGameStatus(pStatus)
    self.PocketGameStatus = pStatus
end

return PocketGame