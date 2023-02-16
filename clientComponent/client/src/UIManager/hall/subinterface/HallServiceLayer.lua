local HallServiceLayer = class("HallServiceLayer",function(args)
		local HallServiceLayer =  display.newLayer()
    return HallServiceLayer
end)

HallServiceLayer.BtnConfig = {"btnWhatsapp","btnMessage"}

function HallServiceLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    
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
        pBtn:setEnabled(firstEnabledUrl ~= "")
        pBtn:onClicked(handler(self, self.onCustomerClick))
    end
end

function HallServiceLayer:onCustomerClick(target)
    local pTag = target:getTag()
    local urlKey = string.format("custom_type_%d_%d", pTag, GlobalUserItem.dwUserID)
    cc.UserDefault:getInstance():setStringForKey(urlKey, target.strUrl)
    OSUtil.openURL(target.strUrl)
end

function HallServiceLayer:onClickClose()
    DoHideCommonLayerAction(self.bg,self.content,function() self:removeSelf() end)
end

return HallServiceLayer