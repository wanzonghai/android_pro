--[[
***
***
]]
local bankToRecordLayer =
    class(
    "bankToRecordLayer",
    function(args)
        local bankToRecordLayer = display.newLayer()
        return bankToRecordLayer
    end
)

EnumTable = {
    RecargaDaloja = 1,
    Transferencia = 2,
    Registro = 3
}

local listType

function bankToRecordLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_BANK_TRANSFER_DATA)
    G_event:RemoveNotifyEvent(G_eventDef.NET_PAY_ORDER_LIST)
end

function bankToRecordLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    local csbNode = g_ExternalFun.loadCSB("bank/bankToAndOutRecord/bankToRecordLayer.csb")
    self:addChild(csbNode)
    self.bg = csbNode:getChildByName("bg")
    self.content = csbNode:getChildByName("content")
    ShowCommonLayerAction(self.bg, self.content)
    self.bg:onClicked(handler(self, self.onClickClose), true)
    self.content:getChildByName("btnClose"):onClicked(handler(self, self.onClickClose), true)

    self.itemDesc = self.content:getChildByName("itemDesc")

    self.btnLeft = self.content:getChildByName("Button_left")

    self.btnRight = self.content:getChildByName("Button_right")
    g_redPoint:addRedPoint(g_redPoint.eventType.bank, self.btnRight, cc.p(20, 20))

    self.btnRegis = self.content:getChildByName("Button_regis")

    self.btnLeft:setBright(false)
    self.btnLeft:onClicked(
        function()
            --充值记录
            self:onSelectState(EnumTable.RecargaDaloja)
        end
    )
    self.btnRight:onClicked(
        function()
            --转账记录
            self:onSelectState(EnumTable.Transferencia)
        end
    )

    self.btnRegis:onClicked(
        function()
            self:onSelectState(EnumTable.Registro)
        end
    )
    self.ImageNull = self.content:getChildByName("ImageNull")
    self.ImageNull:hide()
    self.TextNull = self.ImageNull:getChildByName("TextNull")
    --self.TextNull:setString(g_language:getString("scrollView_default"))
    self.TextNull:setString('');
    self.ImageLoading = self.content:getChildByName("ImageLoading")

    self.listView = self.content:getChildByName("ListView")
    --隐藏滚动条
    self.listView:setScrollBarEnabled(false)

    G_event:AddNotifyEvent(G_eventDef.NET_BANK_TRANSFER_DATA, handler(self, self.onGetTransferRecordData)) --转账信息返回
    G_event:AddNotifyEvent(G_eventDef.NET_PAY_ORDER_LIST, handler(self, self.onQueryOrdersData)) --历史充值成功订单信息返回
    --默认第一个
    
    self:onSelectState(args and args.type)
end

--选中状态
function bankToRecordLayer:onSelectState(type)
    listType = type
    -- self.isSelect = isselect
    if type == EnumTable.RecargaDaloja then
        self.btnLeft:setBright(false)
        self.btnRight:setBright(true)
        self.btnRegis:setBright(true)
        self:getOrdersList() --充值记录
        g_redPoint:dispatch(g_redPoint.eventType.bankSub_1, false)
        self.itemDesc:getChildByName("partir"):setVisible(true)
        self.itemDesc:getChildByName("ouro"):setVisible(true)
        self.itemDesc:getChildByName("joga"):setVisible(false)
        self.itemDesc:getChildByName("moedas"):setVisible(false)
    elseif type == EnumTable.Transferencia then
        self.btnLeft:setBright(true)
        self.btnRight:setBright(false)
        self.btnRegis:setBright(true)
        self:getRecordList() --上分记录
        g_redPoint:dispatch(g_redPoint.eventType.bankSub_2, false)
        self.itemDesc:getChildByName("partir"):setVisible(true)
        self.itemDesc:getChildByName("ouro"):setVisible(true)
        self.itemDesc:getChildByName("joga"):setVisible(false)
        self.itemDesc:getChildByName("moedas"):setVisible(false)
    else
        self.btnLeft:setBright(true)
        self.btnRight:setBright(true)
        self.btnRegis:setBright(false)
        self:getRegistroList()
        self.itemDesc:getChildByName("partir"):setVisible(false)
        self.itemDesc:getChildByName("ouro"):setVisible(false)
        self.itemDesc:getChildByName("joga"):setVisible(true)
        self.itemDesc:getChildByName("moedas"):setVisible(true)
    end
    self.listView:removeAllChildren()
    self:showLoading()
end


function bankToRecordLayer:getRegistroList()
    local teansferType = 2
    local pageSize = 20
    self.pageIndex = 1
    G_ServerMgr:C2S_RequestTransferRecordNew(GlobalUserItem.dwUserID,teansferType,pageSize,self.pageIndex,GlobalUserItem.szDynamicPass)
    self:showLoading()
end


--发起查询转账记录
function bankToRecordLayer:getRecordList()
    local teansferType = 1
    local pageSize = 20
    self.RecordPageIndex = 1
    G_ServerMgr:C2S_RequestTransferRecordNew(GlobalUserItem.dwUserID, teansferType, pageSize, self.RecordPageIndex, GlobalUserItem.szDynamicPass)
end

--发起成功充值订单查询
function bankToRecordLayer:getOrdersList()
    local pageSize = 20
    self.ordersPageIndex = 1
    G_ServerMgr:C2S_QueryOrders(GlobalUserItem.dwUserID, pageSize, self.ordersPageIndex, GlobalUserItem.szDynamicPass)
end


--查询转账记录结构 服务器返回
function bankToRecordLayer:onGetTransferRecordData(data)
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

--查询历史全部成功充值订单
function bankToRecordLayer:onQueryOrdersData(data)
    self:hideLoading()
    dump(data.info)
    self:addItem(data.info)
end

function bankToRecordLayer:addItem(dataInfo)
    local itemNode = g_ExternalFun.loadCSB("bank/bankToAndOutRecord/itemToLayer.csb")
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
        local str = g_format:formatNumber(v.llSwapScore,g_format.fType.standard,g_format.currencyType.GOLD)
        item:getChildByName("textMoney"):setString(str)
        self.listView:pushBackCustomItem(item)
    end
    if #dataInfo.lsItems == 0 then
        self.ImageNull:show()
    else
        self.ImageNull:hide()
    end
end


function bankToRecordLayer:showLoading()
    self.ImageLoading:runAction(cc.RepeatForever:create(cc.RotateTo:create(2, 720)))
    self.ImageLoading:show()
    self.ImageNull:hide()
end

function bankToRecordLayer:hideLoading()
    self.ImageLoading:stopAllActions()
    self.ImageLoading:hide()
end

function bankToRecordLayer:onClickClose()
    if self.editActive == true then
        self.editActive = false
        return
    end
    DoHideCommonLayerAction(
        self.bg,
        self.content,
        function()
            self:removeSelf()
        end
    )
end

return bankToRecordLayer
