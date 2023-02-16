

local bankTransferUserListLayer = class("bankTransferUserListLayer",function(args)
    local bankTransferUserListLayer =  display.newLayer()
return bankTransferUserListLayer
end)

function bankTransferUserListLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_TRANSFER_MERCHANT_LIST)
end


function bankTransferUserListLayer:ctor(func)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    
    local csbNode = g_ExternalFun.loadCSB("bank/bankMakeOver/transferUserListLayer.csb")
    self:addChild(csbNode)

    self.func = func
    self.bg = csbNode:getChildByName("image_bg")
    self.node = csbNode:getChildByName("nodeToRecord")
    ShowCommonLayerAction(self.bg,self.node)
    csbNode:getChildByName("btnOutClose"):onClicked(handler(self,self.onClickClose),true)
    self.node:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    self.defaultImg = self.node:getChildByName("Image_default")
    self.defaultText = self.defaultImg:getChildByName("Text_default")
    self.defaultText:setString(g_language:getString("scrollView_default"))
    self.loadingImg = self.node:getChildByName("Image_loading")
    
    self.scrollView = self.node:getChildByName("ScrollView_1")
    self.scrollView:setScrollBarEnabled(false)

    G_event:AddNotifyEvent(G_eventDef.NET_TRANSFER_MERCHANT_LIST,handler(self,self.onGetTransferUserList))   --获取币商列表
    G_ServerMgr:C2S_RequestTransferUsers(20,1,GlobalUserItem.dwUserID,GlobalUserItem.szDynamicPass)
    self:showLoading()
end

function bankTransferUserListLayer:onGetTransferUserList(listData)
    self:hideLoading()
    dump(listData.info)
    if table.isEmpty(listData.info.lsItems) then
        return 
    end
    if table.nums(listData.info.lsItems) == 0 then
        return 
    end
    self:addUserItem(listData.info.lsItems)
end

function bankTransferUserListLayer:addUserItem(lsItems)
    local item = g_ExternalFun.loadCSB("bank/bankMakeOver/userItem.csb")

    local sum = #lsItems
    local rowSum = 3  --一行3个 item
    local innerSize = self.scrollView:getInnerContainerSize()
    local itemSize = item:getContentSize()
    local l = math.fmod(sum,rowSum)   --取余
    local row = math.modf(sum/rowSum)  --取整
    if l > 0 then
        row = row + 1
    end
    local height = innerSize.height
    if row > 2 then
        --间距：25
        height = row * itemSize.height + (row -1) * 25
        --根据item个数重新设置滚动容器的滚动高度
        self.scrollView:setInnerContainerSize(cc.size(innerSize.width,height));
    end

    for i,v in ipairs(lsItems) do
        local tempItem = item:getChildByName("Panel_userInfo"):clone()
        local col = math.fmod(i-1,rowSum)      --列
        local row = math.modf((i-1)/rowSum)      --行
        local y = height - (row * itemSize.height + row * 25)
        local x = col *itemSize.width + col * 25
        tempItem:setPosition(x,y)
        --头像
        local imgHead = tempItem:getChildByName("ImageUserHead")
        HeadSprite.loadHeadImg(imgHead,v.dwGameID,v.dwFaceID,true)
        tempItem:getChildByName("TextUserID"):setText("ID:"..v.dwGameID)
        tempItem:getChildByName("TextUserName"):setText(v.szNickName)
        
        tempItem:onClicked(
            function()
                local userData = {
                    FaceID = v.dwFaceID,
                    GameID = v.dwGameID,
                    UserID = v.dwUserID,
                    NickName = v.szNickName
                }
                self.func(userData)
                self:onClickClose()
            end
        )
        self.scrollView:addChild(tempItem)
        self.defaultImg:hide()
    end
    if #lsItems == 0 then
        self.defaultImg:show()
    end
end

function bankTransferUserListLayer:onClickClose()
    if self.editActive == true then 
        self.editActive = false
        return
    end
    DoHideCommonLayerAction(self.bg,self.node,function() self:removeSelf() end)
end

function bankTransferUserListLayer:showLoading()
    self.loadingImg:runAction(cc.RepeatForever:create(cc.RotateTo:create(2, 720)))
    self.loadingImg:show()
    self.defaultImg:hide()
end

function bankTransferUserListLayer:hideLoading()
    self.loadingImg:stopAllActions()
    self.loadingImg:hide()
end

return bankTransferUserListLayer