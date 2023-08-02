local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local HeadNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HeadNode")
local ChangeHeadLayer = class("ChangeHeadLayer",BaseLayer)

function ChangeHeadLayer:ctor(args)
    ChangeHeadLayer.super.ctor(self)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self:setName("ChangeHeadLayer")
    self:init()
end

function ChangeHeadLayer:init()
    self:loadLayer("set/ChangeHeadLayer.csb")
    self:initView()
    self:initListener()
    self:doDisplay()
end

function ChangeHeadLayer:initView()
    self.bg = self:getChildByName("bg")
    self.content = self:getChildByName("content")
    self.btnClose = self:getChildByName("btnClose")
    self.panel1 = self:getChildByName("panel1")
    self.panel2 = self:getChildByName("panel2")
    self.confirmBtn = self:getChildByName("confirmBtn")
    self.panel1:setScrollBarEnabled(false)
    self.panel2:setScrollBarEnabled(false)
    ShowCommonLayerAction(self.bg,self.content)
    self._selectSign = cc.Sprite:createWithSpriteFrameName("client/res/set/GUI/grxx_htx6.png")
    self._selectSign:setAnchorPoint(0.5,0.5)
    self:addChild(self._selectSign)
    self._selectSign:hide()
end

function ChangeHeadLayer:initListener()
    self.btnClose:addTouchEventListener(handler(self,self.onTouch))
    self.confirmBtn:addTouchEventListener(handler(self,self.onTouch))
    self.bg:addTouchEventListener(handler(self,self.onTouch))
    local AddNotifyEventTwo = handler(G_event,G_event.AddNotifyEventTwo)
    AddNotifyEventTwo(self,G_eventDef.NET_MODIFY_FACE_SUCCESS,handler(self,self.UpdateHead))
end

function ChangeHeadLayer:onTouch(sender,eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.ended then
        if name == "btnClose" then
            self:close()
        elseif name == "bg" then
            self:close()
        elseif name == "confirmBtn" then
            self:confirmChange()
        end 
    end
end

function ChangeHeadLayer:doDisplay()
    self._headTab = {}
    self._selectIndex = 1
    for k = 1,12 do
        local head = self:getChildByName("head"..k)
        local onClickBtn = head:getChildByName("onClickBtn")
        local headNode = HeadNode:create(k)
        head:addChild(headNode)
        headNode:setVipVisible(false)
        headNode:setBorderVisible(false)
        headNode:setPosition(cc.p(head:getContentSize().width/2,head:getContentSize().height/2))
        headNode:setScale(1.55)
        headNode:setLocalZOrder(1)
        onClickBtn:setLocalZOrder(2)
        onClickBtn:addTouchEventListener(function(sender,eventType) 
            if eventType == ccui.TouchEventType.began then

            elseif eventType == ccui.TouchEventType.ended then
                self:selectOneBtn(k)
            elseif eventType == ccui.TouchEventType.canceled then

            end
        end)
        self._headTab[k] = onClickBtn
        if k == GlobalUserItem.wFaceID then
            self:selectOneBtn(k)
        end
    end
end

function ChangeHeadLayer:selectOneBtn(index)
    for k = 1,#self._headTab do
        local btn = self._headTab[k]
        if k == index then
            btn:setEnabled(false)
            btn:setTouchEnabled(false)
            self._selectSign:retain()
            self._selectSign:removeFromParent()
            btn:addChild(self._selectSign)
            self._selectSign:release()
            self._selectSign:show()
            self._selectSign:setPosition(cc.p(170,40))
        else
            btn:setEnabled(true)
            btn:setTouchEnabled(true)
        end
    end
    self._selectIndex = index
end

--点击确认更改
function ChangeHeadLayer:confirmChange()
    G_ServerMgr:C2S_ModifyUserFace(self._selectIndex)
    
end

function ChangeHeadLayer:UpdateHead()
    self:close()
end

function ChangeHeadLayer:onExit()
    ChangeHeadLayer.super.onExit(self)
    local RemoveNotifyEventTwo = handler(G_event,G_event.RemoveNotifyEventTwo)
    RemoveNotifyEventTwo(self,G_eventDef.NET_MODIFY_FACE_SUCCESS)
end

return ChangeHeadLayer