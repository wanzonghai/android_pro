--[[
*** 转让，充值记录页
***
]]
local bankRecordLayer =
    class(
    "bankRecordLayer",
    function(args)
        local bankRecordLayer = display.newLayer()
        return bankRecordLayer
    end
)

bankRecordLayer.bankData = require(appdf.CLIENT_SRC.."UIManager.hall.bank_new.data.bankData").new()

EnumTable = {
    RecargaDaloja = 1,
    Transferencia = 2,
    Registro = 3
}

local listType

local textColor = {
    [1] = cc.c3b(161,45,126),
    [2] = cc.c3b(175,73,42),
}

function bankRecordLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_BANK_TRANSFER_DATA)
    G_event:RemoveNotifyEvent(G_eventDef.NET_PAY_ORDER_LIST)
end

function bankRecordLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    local csbNode = g_ExternalFun.loadCSB("bank_new/bankToRecordLayer.csb")
    local content = csbNode:getChildByName("content")
    self.m_currencyType = args.currencyType
    if self.m_currencyType == g_format.currencyType.GOLD then
        local tcNode = content:getChildByName("Panel_tc")
        tcNode:removeFromParent()
    else
        local panelGold = content:getChildByName("Panel_gold")
        panelGold:hide()
    end
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg, self.mm_content)
    self.mm_bg:onClicked(handler(self, self.onClickClose), true)
    self.mm_btnClose:onClicked(handler(self, self.onClickClose), true)

    g_redPoint:addRedPoint(g_redPoint.eventType.bank, self.mm_Button_right, cc.p(20, 20))


    self.mm_Button_left:setBright(false)
    self.mm_Button_left:onClicked(
        function()
            --充值记录
            self:onSelectState(EnumTable.RecargaDaloja)
        end
    )
    self.mm_Button_right:onClicked(
        function()
            --转账记录
            self:onSelectState(EnumTable.Transferencia)
        end
    )

    self.mm_Button_regis:onClicked(
        function()
            self:onSelectState(EnumTable.Registro)
        end
    )
    -- self.ImageNull = self.content:getChildByName("ImageNull")
    self.mm_ImageNull:hide()
    -- self.TextNull = self.ImageNull:getChildByName("TextNull")
    self.mm_TextNull:setString('');
    -- self.ImageLoading = self.content:getChildByName("ImageLoading")


    --隐藏滚动条
    self.mm_ListView:setScrollBarEnabled(false)

    -- if self.m_currencyType == g_format.currencyType.GOLD then
    --     self.mm_Panel_gold:show()
    --     self.mm_Panel_tc:hide()
    -- else
    --     self.mm_Panel_gold:hide()
    --     self.mm_Panel_tc:show()
    -- end

    G_event:AddNotifyEvent(G_eventDef.NET_BANK_TRANSFER_DATA, handler(self, self.onGetTransferRecordData)) --转账信息返回
    G_event:AddNotifyEvent(G_eventDef.NET_PAY_ORDER_LIST, handler(self, self.onQueryOrdersData)) --历史充值成功订单信息返回
    --默认第一个
    
    self:onSelectState(args and args.type)
end

--选中状态
function bankRecordLayer:onSelectState(type)
    listType = type
    self.mm_partir:setVisible(false)
    self.mm_ouro:setVisible(false)
    self.mm_joga:setVisible(false)
    self.mm_moedas:setVisible(false)
    if type == EnumTable.RecargaDaloja then
        self.mm_Button_left:setBright(false)
        self.mm_Button_right:setBright(true)
        self.mm_Button_regis:setBright(true)
        self:getOrdersList() --充值记录
        g_redPoint:dispatch(g_redPoint.eventType.bankSub_1, false)
        self.mm_partir:setVisible(true)
        self.mm_ouro:setVisible(true)
    elseif type == EnumTable.Transferencia then
        self.mm_Button_left:setBright(true)
        self.mm_Button_right:setBright(false)
        self.mm_Button_regis:setBright(true)
        self:getRecordList() --上分记录
        g_redPoint:dispatch(g_redPoint.eventType.bankSub_2, false)
        self.mm_partir:setVisible(true)
        self.mm_ouro:setVisible(true)
    else
        self.mm_Button_left:setBright(true)
        self.mm_Button_right:setBright(true)
        self.mm_Button_regis:setBright(false)
        self:getRegistroList()
        self.mm_joga:setVisible(true)
        self.mm_moedas:setVisible(true)
    end
    self.mm_ListView:removeAllChildren()
    self:showLoading()
end


function bankRecordLayer:getRegistroList()
    local teansferType = 2
    local pageSize = 20
    self.pageIndex = 1
    
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        G_ServerMgr:C2S_RequestTransferRecordNew(GlobalUserItem.dwUserID,teansferType,pageSize,self.pageIndex,GlobalUserItem.szDynamicPass)
    else
        self.bankData:C2S_RequestTransferRecordEx(self.m_currencyType,teansferType,pageSize,self.pageIndex)
    end
    self:showLoading()
end


--发起查询转账记录
function bankRecordLayer:getRecordList()
    local teansferType = 1
    local pageSize = 20
    self.RecordPageIndex = 1
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        G_ServerMgr:C2S_RequestTransferRecordNew(GlobalUserItem.dwUserID, teansferType, pageSize, self.RecordPageIndex, GlobalUserItem.szDynamicPass)
    else
        self.bankData:C2S_RequestTransferRecordEx(self.m_currencyType,teansferType,pageSize,self.RecordPageIndex)
    end
end

--发起成功充值订单查询
function bankRecordLayer:getOrdersList()
    local pageSize = 20
    self.ordersPageIndex = 1
    G_ServerMgr:C2S_QueryOrders(GlobalUserItem.dwUserID, pageSize, self.ordersPageIndex, GlobalUserItem.szDynamicPass)
end


--查询转账记录结构 服务器返回
function bankRecordLayer:onGetTransferRecordData(data)
    self:hideLoading()
    -- dump(data.info)
    if table.isEmpty(data.info) then
        return
    end
    if table.nums(data.info) == 0 then
        return
    end
    self:addItem(data.info)
end

--查询历史全部成功充值订单
function bankRecordLayer:onQueryOrdersData(data)
    self:hideLoading()
    -- dump(data.info)
    self:addItem(data.info)
end

function bankRecordLayer:addItem(dataInfo)
    local itemNode = g_ExternalFun.loadCSB("bank_new/itemToLayer.csb")
    local panel_item = itemNode:getChildByName("Panel_item")
    for i, v in ipairs(dataInfo.lsItems) do
        local item = panel_item:clone()
        local textTime = item:getChildByName("textTime")
        local T = DateUtil.getBrazilTimeString(v.tmCollectDate)
        local timeStr = string.format("%s %s %s\n%s:%s", T.d, T.m, T.y, T.hour, T.min)
        textTime:setString(timeStr) --时间戳
        local nodePay = item:getChildByName("nodePay")
        local nodeOver = item:getChildByName("nodeOver")
        if listType == EnumTable.RecargaDaloja then
            nodePay:setVisible(false)
            nodeOver:setVisible(true)
            --头像
            local imgHead = nodeOver:getChildByName("imghead")
            HeadSprite.loadHeadImg(imgHead, GlobalUserItem.dwGameID,GlobalUserItem.wFaceID, true)
            nodeOver:getChildByName("textID"):setString("ID:" .. GlobalUserItem.dwGameID)
            nodeOver:getChildByName("textName"):setString(g_ExternalFun.RejectChinese(GlobalUserItem.szNickName))
        elseif listType == EnumTable.Transferencia then
            nodePay:setVisible(false)
            nodeOver:setVisible(true)
            --头像
            local imgHead = nodeOver:getChildByName("imghead")
            HeadSprite.loadHeadImg(imgHead, v.dwSrcGameID, v.dwSrcFaceID, true)

            nodeOver:getChildByName("textID"):setString("ID:" .. v.dwSrcGameID)
            nodeOver:getChildByName("textName"):setString(v.szSrcNickName)
        else
            nodePay:setVisible(false)
            nodeOver:setVisible(true)
            --头像
            local imgHead = nodeOver:getChildByName("imghead")
            HeadSprite.loadHeadImg(imgHead, v.dwDstGameID, v.dwDstFaceID, true)

            nodeOver:getChildByName("textID"):setString("ID:" .. v.dwDstGameID)
            nodeOver:getChildByName("textName"):setString(v.szDstNickName)
        end
        
        item:getChildByName("ButtonOutRecord"):setVisible(false)
        local str = g_format:formatNumber(v.llSwapScore,g_format.fType.standard,self.m_currencyType)
        item:getChildByName("textMoney"):setString(str)
        self.mm_ListView:pushBackCustomItem(item)
    end
    if #dataInfo.lsItems == 0 then
        self.mm_ImageNull:show()
    else
        self.mm_ImageNull:hide()
    end
end


function bankRecordLayer:showLoading()
    self.mm_ImageLoading:runAction(cc.RepeatForever:create(cc.RotateTo:create(2, 720)))
    self.mm_ImageLoading:show()
    self.mm_ImageNull:hide()
end

function bankRecordLayer:hideLoading()
    self.mm_ImageLoading:stopAllActions()
    self.mm_ImageLoading:hide()
end

function bankRecordLayer:onClickClose()
    if self.editActive == true then
        self.editActive = false
        return
    end
    DoHideCommonLayerAction(
        self.mm_bg,
        self.mm_content,
        function()
            self:removeSelf()
        end
    )
end

return bankRecordLayer
