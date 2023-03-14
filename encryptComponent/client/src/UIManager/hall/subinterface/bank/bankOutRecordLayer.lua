--[[
***
***
]]
local bankOutRecordLayer = class("bankOutRecordLayer",function(args)
    local bankOutRecordLayer =  display.newLayer()
return bankOutRecordLayer
end)
function bankOutRecordLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_BANK_TRANSFER_DATA)
end

function bankOutRecordLayer:ctor(func)
    local parent = cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    
    local csbNode = g_ExternalFun.loadCSB("bank/bankToAndOutRecord/bankOutRecordLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    self.func = func

    ShowCommonLayerAction(self.mm_bg,self.mm_content)
    self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)
    self.mm_ImageNull:hide()
    self.mm_TextNull:setString(g_language:getString("scrollView_default"))

    --隐藏滚动条
    self.mm_ListView:setScrollBarEnabled(false)

    G_event:AddNotifyEvent(G_eventDef.NET_BANK_TRANSFER_DATA,handler(self,self.onGetTransferRecordData))   --转账信息
    self:getRecordList()
end

--发起查询转账记录
function bankOutRecordLayer:getRecordList()
    local teansferType = 2
    local pageSize = 20
    self.pageIndex = 1
    G_ServerMgr:C2S_RequestTransferRecordNew(GlobalUserItem.dwUserID,teansferType,pageSize,self.pageIndex,GlobalUserItem.szDynamicPass)
    self:showLoading()
end

--查询转账记录结构 服务器返回
function bankOutRecordLayer:onGetTransferRecordData(data)
    self:hideLoading()
    dump(data.info)
    if table.isEmpty(data.info) then 
        return 
    end
    if table.nums(data.info) == 0 then
        return 
    end
    self:addItem(data.info)
end

function bankOutRecordLayer:addItem(dataInfo)
    local itemNode = g_ExternalFun.loadCSB("bank/bankToAndOutRecord/itemLayer.csb")
    local panel_item = itemNode:getChildByName("Panel_item")
    for i,v in ipairs(dataInfo.lsItems) do
        local item = panel_item:clone()
        local textTime = item:getChildByName("textTime")
        local T = DateUtil.getBrazilTimeString(v.tmCollectDate)
        local timeStr = string.format("%s %s %s\n%s:%s", T.d, T.m, T.y, T.hour, T.min)
        textTime:setString(timeStr)
        local nodeOver = item:getChildByName("nodeOver")
        
        nodeOver:setVisible(true)

        --头像
        local imgHead = nodeOver:getChildByName("imghead")
        HeadSprite.loadHeadImg(imgHead,v.dwDstGameID,v.dwDstFaceID,true)
        nodeOver:getChildByName("textID"):setString("ID:"..v.dwDstGameID)
        nodeOver:getChildByName("textName"):setString(v.szDstNickName)
        item:getChildByName("textMoney"):setString(g_format:formatNumber(v.llSwapScore,g_format.fType.standard))

        local btnOut = item:getChildByName("ButtonOutRecord")
        btnOut:setVisible(false)
        btnOut:onClicked(
            function() 
                local userData = {
                    FaceID = v.dwDstFaceID,
                    UserID = v.dwDstUserID,
                    GameID = v.dwDstGameID,
                    NickName = v.szDstNickName
                }
                self.func(userData)
                self:onClickClose()
            end
        )
        self.mm_ListView:pushBackCustomItem(item)
        
    end
    if #dataInfo.lsItems == 0 then
        self.mm_ImageNull:show()
    else
        self.mm_ImageNull:hide()
    end

end

function bankOutRecordLayer:onClickClose()
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() self:removeSelf() end)
end

function bankOutRecordLayer:showLoading()
    self.mm_ImageLoading:runAction(cc.RepeatForever:create(cc.RotateTo:create(2, 720)))
    self.mm_ImageLoading:show()
    self.mm_ImageNull:hide()
end

function bankOutRecordLayer:hideLoading()
    self.mm_ImageLoading:stopAllActions()
    self.mm_ImageLoading:hide()
end

return bankOutRecordLayer