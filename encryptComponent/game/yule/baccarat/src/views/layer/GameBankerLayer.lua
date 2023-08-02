local GameBankerLayer = class("GameBankerLayer", function(parent,info)
		local GameBankerLayer = display.newLayer()
    return GameBankerLayer
end)
function GameBankerLayer:onExit()
    G_event:RemoveNotifyEvent("longhu_applybanker")
end
function GameBankerLayer:ctor(parent,info)
    parent = parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,10)
    self.frame = info.frame
    local csbNode = g_ExternalFun.loadCSB("client/res/game/twoeightbattle/res/twoeightZhuang.csb")
    self:addChild(csbNode)
    self.bg = csbNode:getChildByName("image_bg")
    self.node = csbNode:getChildByName("nodeZhuang")
    ShowCommonLayerAction(self.bg,self.node)
    csbNode:getChildByName("btnOutClose"):onClicked(handler(self,self.onClickClose),true)
    self.node:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    self.btnUpZhuang = self.node:getChildByName("btnUpZhuang")
    self.btnDownZhuang = self.node:getChildByName("btnDownZhuang")
    self.btnUpZhuang:onClicked(function() self:onClickApplyZhuang(1) end)
    self.btnDownZhuang:onClicked(function() self:onClickApplyZhuang(2) end)
    self.btnDownZhuang:setVisible(false)
    self.banklist = {}
    self.applylist = {}
    for i=1,6 do
        self.banklist[i] = self.node:getChildByName("nodeZhuang"..i)
        self.applylist[i] = self.node:getChildByName("nodeApply"..i)
    end
    self:onInitList(info.banklist,info.applyList)
    G_event:AddNotifyEvent("longhu_applybanker" ,handler(self,self.onApplyBanker))
end

function GameBankerLayer:onInitList(bankerlist,applylist)
    self.btnDownZhuang:setVisible(false)
    for i,v in pairs(bankerlist) do
        if v.chairID ~= 65535 then  --有庄家
            local userItem = self.frame:GetUserItem(v.chairID)
            if userItem == nil then
                self.banklist[i]:setVisible(false)
            else
                self.banklist[i]:setVisible(true)
                self.banklist[i]:getChildByName("txtCoin"):setString(userItem.lScore / yl.Rate)
                local name = self:getShotName(userItem.szNickName)
                self.banklist[i]:getChildByName("txtName"):setString(name)
                if v.chairID == self.frame:GetMyChairID() then
                    self.btnDownZhuang:setVisible(true)   --自己是庄家
                    self.bankerType = 2
                end
            end
        else
            self.banklist[i]:setVisible(false)
        end
    end
    for i,v in pairs(applylist) do
        if v.chairID ~= 65535 then  --申请列表
            local userItem = self.frame:GetUserItem(v.chairID)
            if userItem == nil then
                self.applylist[i]:setVisible(false)
            else
                self.applylist[i]:setVisible(true)
                self.applylist[i]:getChildByName("txtCoin"):setString(userItem.lScore / yl.Rate)
                local name = self:getShotName(userItem.szNickName)
                self.applylist[i]:getChildByName("txtName"):setString(name)
                if v.chairID == self.frame:GetMyChairID() then
                    self.btnDownZhuang:setVisible(true)   --在申请列表中
                    self.bankerType = 1
                end
            end
        else
            self.applylist[i]:setVisible(false)
        end
    end
end
function GameBankerLayer:getShotName(nickName)
   local szName = g_ExternalFun.FormatString2FixLen(nickName,250,"微软雅黑",44)
   return szName
end
function GameBankerLayer:onClickClose()
    DoHideCommonLayerAction(self.bg,self.node,function() self:removeSelf() end)
end
--cbType1,2 上庄，下庄
function GameBankerLayer:onClickApplyZhuang(cbType)
    if cbType == 1 then  --申请上庄
        self.frame:reqApplyBanker()
    end
    if cbType == 2 then
        self.frame:reqCancelApply(self.bankerType)
    end
end

--申请列表 返回
function GameBankerLayer:onApplyBanker(args)
    self:onInitList(args.banklist,args.applyList)
end

return GameBankerLayer