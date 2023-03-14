
--每日分享

local HallShareLayer = class("HallShareLayer",ccui.Layout)
--Messenger, WhatsApp, Instagram, Twitter, Telegram
local platformType = {
    [1] = "WhatsApp",
    [2] = "Messenger",
    [3] = "Telegram",
    [4] = "Instagram",
    [5] = "Twitter",
}


function HallShareLayer:onExit()
    G_event.RemoveNotifyEvent(G_eventDef.EVENT_SHARE_REWARD)
    G_event.RemoveNotifyEvent(G_eventDef.EVENT_SHARE_RESTLIMITS)
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() self:removeSelf() end)
end

function HallShareLayer:ctor(args)
    self._scene = args
    self.config = self._scene.m_shareConfig
    local parent = cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    local csbNode = g_ExternalFun.loadCSB("todayShare/todayShareLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)

    self.mm_Text_count:setString("0") 
    self.mm_Text_countMax:setString("/0") 
    self.mm_btn_close:onClicked(function() self:onExit() end)
    self.mm_bg:onClicked(function() self:onExit() end)

    --背景
    self.SpineBg = sp.SkeletonAnimation:create("todayShare/meirifenxiang.json","todayShare/meirifenxiang.atlas", 1)
    self.SpineBg:addTo(self.mm_spine_1)
    self.SpineBg:setPosition(0, 0)
    self.SpineBg:setAnimation(0, "jinbi", true)      

    self.mm_btn_share1:onClicked(function() 
        self:shareStr(1) 
    end)
    self.mm_btn_share2:onClicked(function()
        self:shareStr(2) 
    end)
    self.mm_btn_share3:onClicked(function() 
        self:shareStr(3) 
    end)

    self:getMyIP()
    self:setUI()
    -- G_event:AddNotifyEvent(G_eventDef.EVENT_SHARE_CLICK_COUNT,handler(self,self.onShareClickCountCallback))
    G_event:AddNotifyEvent(G_eventDef.EVENT_SHARE_REWARD,handler(self,self.onShareRewardCallback))
    G_event:AddNotifyEvent(G_eventDef.EVENT_SHARE_RESTLIMITS,handler(self,self.onShareRestLimitsCallback))
    G_event:AddNotifyEvent(G_eventDef.EVENT_PHONE_SHARE_CALLBACK,handler(self,self.onPhoneShareCallback))
    G_ServerMgr:C2S_GetShareRestLimits()
end

function HallShareLayer:getMyIP()
    self.myip = "127.0.0.1"
    local info = {
        url = "https://ifconfig.me/ip",
        callback = function(ok,response) 
            print("myIp = ",response)
            self.myip = response 
        end
    }
    http.get(info)
end


function HallShareLayer:onShareRewardCallback(data)
    if data.dwErrorCode == 0 then
        self:showAward(data.lShareScore,"client/res/task/imageNew/mrrw_jb_3.png")
        G_ServerMgr:C2S_RequestUserGold()
    end
    self:onExit()
end

function HallShareLayer:showAward(goldTxt,goldImg)
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
    local data = {}
    data.goldTxt = g_format:formatNumber(goldTxt,g_format.fType.standard)
    data.goldImg = goldImg
    data.type = 1
    appdf.req(path).new(data)
end

function HallShareLayer:onShareRestLimitsCallback(data)
    self.mm_Text_count:setString(data.wRestLimits)  
    self.mm_Panel_reward:setVisible(data.wRestLimits>=0)
    self.mm_Panel_no_reward:setVisible(data.wRestLimits==-1)
    if data.wRestLimits>0 then
        self.SpineBg:setAnimation(0, "jinbi", true)
    elseif data.wRestLimits<=0 then
        self.SpineBg:setAnimation(0, "yinbi", true)
    end
    self.RestLimits = data.wRestLimits
end

function HallShareLayer:setUI()
    self.mm_BitmapFontLabel_gold:setString("+"..g_format:formatNumber(self.config.lShareScore,g_format.fType.standard) )
    self.mm_Text_countMax:setString("/"..self.config.wShareUserLimits)
end

-- g_MultiPlatform:getInstance():FaceBookShare("share","https://developers.facebook.com/","this is game","")   
-- g_MultiPlatform:getInstance():mobShare("WhatsApp","https://developers.facebook.com/","this is game","title","")   
-- function MultiPlatform:mobShare(platform, link, content, title, imgPath)
	--platform : Facebook, WhatsApp, Instagram, Twitter, Telegram
	--link : 分享链接url
	--content: 分享文本内容
	--title: 标题
	--imgPath : 图片地址(可以传网络图片url或本地图片，但facebook只能分享本地图片）
	--没有值时填空即可，比如imgPath不需要，则imgPath = "" 
function HallShareLayer:shareStr(index)
    local platformStr = platformType[index]
    local isok,userStr = self:number2string(GlobalUserItem.dwUserID,"")
    
    local str = self.config.szShareUrl
    local l = string.sub(str,-1)
    if l == "/" then
        self.config.szShareUrl =  string.sub(str,1,string.len(str)-1)
    end
    local shareUrl = self.config.szShareUrl.."/spd_"..userStr..'.shtml'
    g_MultiPlatform:getInstance():mobShare(platformStr,shareUrl,self.config.szShareTips,"","")  
    if device.platform == "windows" then
        local data = {
            platformType = 54018,
            resultCode = 0
        }
        G_event:NotifyEvent(G_eventDef.EVENT_PHONE_SHARE_CALLBACK,data)
    end
end

--"CMD_MB_GetShareConfigResult" = {	
--    "byShareEnable"       = 1	
--    "lShareScore"         = 30000
--    "szShareContent"      = "这里填分享的文本内容(200个字以下)"	
--    "szShareTitle"        = "分享标题"	
--    "szShareUrl"          = "http://192.168.1.230:3106/"..xxxxxx..'.shtml'	
--    "wShareMachineLimits" = 20	
--    "wShareUserLimits"    = 15

function HallShareLayer:onPhoneShareCallback(data)
    if data == nil then
        --没有对应的app
        showToast("please installation program")
    else
        if self.RestLimits<=0 then
            return
        end
        local type = 0
        if tonumber(data.platformType) == 54018 then
            type = 1
        elseif tonumber(data.platformType) == 54019 then
            type = 2
        elseif tonumber(data.platformType) == 54020 then
            type = 3
        end
        G_ServerMgr:C2S_GetShareReward(self.myip,type)
    end
end

function HallShareLayer:number2string(user_id, str)
    local baseStrings = {
        "ABCDEFGHJKMNPQRSTWXY",
        "abcdefhijkmnprstwxyz"
    }
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    user_id = tostring(user_id)
    local len = string.len( user_id ) 
    local key_len = string.len( baseStrings[1] )

    for i=1,len do
        local s = tonumber(string.sub(user_id,i,i))
        local rand =math.random(1,100)
        local r1 = math.fmod(rand,2)+1
        rand =math.random(1,100)
        local r2 = math.fmod(rand,2)+1
        if s == 0 then
            s = 9
        else
            s = s - 1
        end
        if (s * 2 + r2) > key_len then
            return false;
        end
        str = str..string.sub(baseStrings[r1],s*2+r2,s*2+r2)
    end
    return true,str
end

return HallShareLayer