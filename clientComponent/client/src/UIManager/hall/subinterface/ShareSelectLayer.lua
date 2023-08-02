local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local ShareSelectLayer = class("ShareSelectLayer",BaseLayer)

function ShareSelectLayer:ctor(args)
    ShareSelectLayer.super.ctor(self)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self:setName("ShareSelectLayer")
    self._args = args
    self:loadLayer("ShareTurnTable/ShareSelectLayer.csb")
    self:init()
end

function ShareSelectLayer:onExit()
    ShareSelectLayer.super.onExit(self)
    self.clonePanel:release()
end

function ShareSelectLayer:init()
    self:initView()
    ShowCommonLayerAction(self.bg,self.content)
    self:doDisplay()
end

function ShareSelectLayer:initView()
    self.bg = self:getChildByName("maskLayer")
    self.content = self:getChildByName("centerNode")
    self.confirmBtn = self:getChildByName("confirmBtn")
    self.clonePanel = self:getChildByName("clonePanel")
    self.closeBtn = self:getChildByName("closeBtn")
    self.clonePanel:retain()
    self.clonePanel:removeFromParent()
    self.confirmBtn:addTouchEventListener(handler(self,self.onTouch))
    self.closeBtn:addTouchEventListener(handler(self,self.onTouch))
end

function ShareSelectLayer:doDisplay()
    local result = self._args.result
    local isNewPlayer = (self._args.dwWithdrawCount == 0 and 1 or 0)        --1是新用户
    local width = 0
    local count = 0

    for k = 1,#result do
        local data = result[k]
        if isNewPlayer == 1 then
            if data and  data.cbNewUserEnable == isNewPlayer then
                count = count + 1
            end
        else
            count = count + 1
        end
    end
    local listView = self:createListView(count)
    listView:setScrollBarEnabled(false)
    self.listView = listView
    for k = 1,#result do
        local data = result[k]
        if (isNewPlayer == 1 and data.cbNewUserEnable == isNewPlayer) or (isNewPlayer ~=1) then
            local item = self.clonePanel:clone()
            item:show()
            local priceScore = item:getChildByName("priceScore")
            local bgImage = item:getChildByName("bgImage")
            bgImage.selectLight = item:getChildByName("selectLight")
            bgImage.selectLight:hide()
            bgImage._dwStageID = data.dwStageID
            bgImage._dwStageScore = data.dwStageScore
            bgImage._index = k
            priceScore:setString(string.format("R$ %s",g_format:formatNumber(data.dwStageScore,g_format.fType.standard)))
            self.listView:pushBackCustomItem(item)
            width = width + 570
            bgImage:addTouchEventListener(handler(self,self.selectItem))
            bgImage:setSwallowTouches(false)
        end
    end
end

function ShareSelectLayer:selectItem(sender,eventType)
    if self._lastItem == sender then return end
    if eventType == ccui.TouchEventType.began then
        sender.selectLight:show()
    elseif eventType == ccui.TouchEventType.ended then
        sender.selectLight:show()
        if self._lastItem then
            self._lastItem.selectLight:hide()
        end
        self._lastItem = sender
    elseif eventType == ccui.TouchEventType.canceled then
        sender.selectLight:hide()
    end
end

function ShareSelectLayer:onTouch(sender,eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.ended then
        if name == "confirmBtn" then
            if self._lastItem then
                local index = self._lastItem._index
                if index > 1 then
                    local pData = {
                        msg = "Quanto maior o nível, mais difícil é a tarefa. Você escolheu o nível "..g_format:formatNumber(self._lastItem._dwStageScore,g_format.fType.standard),
                        callback = function(click)
                            if click == "ok" then     
                                showNetLoading()
                                G_ServerMgr:setTiXianLevel(self._lastItem._dwStageID,self._lastItem._dwStageScore)
                            end          
                        end
                    }
                    G_event:NotifyEvent(G_eventDef.UI_OPEN_COMMON_DIALOG,pData)
                else
                    showNetLoading()
                    G_ServerMgr:setTiXianLevel(self._lastItem._dwStageID,self._lastItem._dwStageScore)
                end
            else
                showToast("Por favor, selecione um nível de retirada primeiro.")            --请先选择提款级别
            end
        elseif name == "closeBtn" then
            self:close()
        end
    end
end

function ShareSelectLayer:createListView(count)
    local listView = ccui.ListView:create()
    if count * 570 > display.width then
        listView:setContentSize(cc.size(display.width,354))
    else
        listView:setContentSize(cc.size(count * 570,354))
    end
    
    listView:setAnchorPoint(0.5,0.5)
    listView:setPosition(cc.p(0,0))
    self.content:addChild(listView)
    listView:setDirection(ccui.ScrollViewDir.horizontal)
    listView:setItemsMargin(4)
    
    return listView
end

return ShareSelectLayer