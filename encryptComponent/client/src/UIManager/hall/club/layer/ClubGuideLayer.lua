local clubGuideLayer = class("clubGuideLayer",function ()
    local clubGuideLayer = display.newLayer()
    return clubGuideLayer
end)

function clubGuideLayer:onExit()

end

function clubGuideLayer:onClickClose()
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function()
        if self.NoticeNext then
            G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="ClubGuider"})
        end
        self:removeSelf() 
    end)
end

function clubGuideLayer:ctor(args)
    self.NoticeNext = args and args.NoticeNext 
    local parent = cc.Director:getInstance():getRunningScene()    
    parent:addChild(self)
    
    local csbNode = g_ExternalFun.loadCSB("club/ClubGuideLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)

    --spine action
    local spineFile = "club/club_spine/xuanchuanye"
    local animateAct = sp.SkeletonAnimation:create(string.format("%s.json", spineFile), string.format("%s.atlas", spineFile), 1)
    animateAct:addTo(self.mm_Node_spine)
    animateAct:setAnimation(0, "daiji", true)
    animateAct:setPosition(0, 0)

    self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)
    
    local btnConfig = {self.mm_Button_whatsApp, self.mm_Button_fb}
    for i, pBtn in ipairs(btnConfig) do
        pBtn:setTag(i)
        local firstEnabledUrl, strUrl = g_ExternalFun.getCustomerUrl(i)
        pBtn.strUrl = strUrl
        pBtn:setEnabled(firstEnabledUrl ~= "")
        pBtn:onClicked(handler(self, self.onCustomerClick))
    end
end

function clubGuideLayer:onCustomerClick(target)
    local pTag = target:getTag()
    local urlKey = string.format("custom_type_%d_%d", pTag, GlobalUserItem.dwUserID)
    cc.UserDefault:getInstance():setStringForKey(urlKey, target.strUrl)
    OSUtil.openURL(target.strUrl)
end

return clubGuideLayer