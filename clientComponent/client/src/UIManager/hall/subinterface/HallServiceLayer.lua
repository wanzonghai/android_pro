local HallServiceLayer = class("HallServiceLayer",function(args)
		local HallServiceLayer =  display.newLayer()
    return HallServiceLayer
end)

HallServiceLayer.BtnConfig = {"btnWhatsapp","btnMessage"}

function HallServiceLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("service/SeviceLayer.csb")
    self:addChild(csbNode)

    self.bg = csbNode:getChildByName("bg")
    self.content = csbNode:getChildByName("content")
    ShowCommonLayerAction(self.bg,self.content)

    self.bg:onClicked(handler(self,self.onClickClose),true)
    self.content:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    
    -- GlobalData.CustomerInfos

    for i, v in ipairs(self.BtnConfig) do
        local pBtn = self.content:getChildByName(v)
        pBtn:setTag(i)
        local firstEnabledUrl, strUrl = g_ExternalFun.getCustomerUrl(i)
        pBtn.strUrl = strUrl
        if v == "btnWhatsapp" then
            pBtn:setEnabled(false)
        else
            pBtn:setEnabled(firstEnabledUrl ~= "")
            pBtn:onClicked(handler(self, self.onCustomerClick))
        end
        
    end
end

function HallServiceLayer:onCustomerClick(target)
    local pTag = target:getTag()
    local urlKey = string.format("custom_type_%d_%d", pTag, GlobalUserItem.dwUserID)
    cc.UserDefault:getInstance():setStringForKey(urlKey, target.strUrl)
    OSUtil.openURL(target.strUrl)
end

function HallServiceLayer:setDefault()
    local pKey = "LoginService_WhatsApp"
    self.URL_whatsapp = cc.UserDefault:getInstance():getStringForKey(pKey, "")
    self.btnWhatsapp = self.content:getChildByName("btnWhatsapp")
    self.btnWhatsapp:setEnabled(false)
    self.btnWhatsapp:onClicked(function ()       
        showToast(g_language:getString("game_not_open"))
        do return end
        if self.URL_whatsapp~="" then
        else
            local pTime = os.time()%2 + 1
            local pServiceWhatsApp = {
                "https://wa.me/5511980911195",
                "https://wa.me/5511967285143"
            }
            self.URL_whatsapp = pServiceWhatsApp[pTime]
        end        
        cc.UserDefault:getInstance():setStringForKey(pKey,self.URL_whatsapp)
        OSUtil.openURL(self.URL_whatsapp)
    end)
    self.btnMessage = self.content:getChildByName("btnMessage")
    self.btnMessage:setEnabled(true)
    self.btnMessage:onClicked(function ()
        OSUtil.openURL("https://direct.lc.chat/15021027/")
    end)
end

function HallServiceLayer:onClickClose()
    DoHideCommonLayerAction(self.bg,self.content,function() self:removeSelf() end)
end

return HallServiceLayer