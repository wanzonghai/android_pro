--[[
***
***
]]
local HallNoticeLayer = class("HallNoticeLayer",function(args)
		local HallNoticeLayer =  display.newLayer()
    return HallNoticeLayer
end)
local touchLength = 50
function HallNoticeLayer:ctor()
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("notice/NoticeLayer.csb")
    self:addChild(csbNode)

    self.bg = csbNode:getChildByName("image_bg")
    self.node = csbNode:getChildByName("nodeNotice")
    ShowCommonLayerAction(self.bg,self.node)
    csbNode:getChildByName("btnOutClose"):onClicked(handler(self,self.onClickClose),true)
    self.node:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    self.txtContent = self.node:getChildByName("txtContent")
    self.txtTime = self.node:getChildByName("txtTime")
    self.scrollview = self.node:getChildByName("scrollview")
    self.scrollview:setScrollBarEnabled(false)
end
function HallNoticeLayer:onClickClose()
    DoHideCommonLayerAction(self.bg,self.node,function() self:removeSelf() end)
end

function HallNoticeLayer:onUpdateItem()
    self.noticeData = self.noticeData or {}
    local height = #self.noticeData * 100
    if height < 700 then
        height = 700
    end
    self.scrollview:setInnerContainerSize(cc.size(310,height))
    self.leftBtn = {}
    for i,v in pairs(self.noticeData) do
        local itemY = height-60-(i-1)*100
        local item = cc.CSLoader:createNode("notice/item.csb")
        item:setPosition(158,itemY)
        self.scrollview:addChild(item)     
        item:getChildByName("imgHot"):setVisible(v.isHot)
        item:getChildByName("txtTitle"):setString(v.title)
        local btn = item:getChildByName("btn")
        btn:setSwallowTouches(false)
        btn:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                self._touchMoveY = this:ccpCopy(sender:getTouchBeganPosition()).y
            elseif eventType == ccui.TouchEventType.ended then
               local endPosY = self:ccpCopy(sender:getTouchEndPosition()).y
               if math.abs(endPosY - this._touchMoveY) <= touchLength then
                   this:onClickNotice(v,i)
               end
            end
        end)
        self.leftBtn[i] = btn
    end
end
function HallNoticeLayer:ccpCopy(ccpointOrX, y)
    if y then
        return cc.p(ccpointOrX, y)
    else
        return cc.p(ccpointOrX.x, ccpointOrX.y);
    end
end
function HallNoticeLayer:onClickNotice(data,index)
    if self.selectIndex == index then return end
    self.selectIndex = index
    local name = {"notice/btnNotice1.png","notice/btnNotice2.png"}
    for i,v in pairs(self.leftBtn) do
        local str = name[2]
        if i == index then
            str = name[1]
        end
         v:loadTextures(str,str)
    end
    local date = os.date("%Y-%m-%d %H:%M", tonumber(data.llTime))
    self.txtTime:setString(date)
    local strContent,count = string.FormatString2FixLen(data.content,850,"fonts/micross.ttf", 30)
    self.txtContent:setString(strContent)
end
return HallNoticeLayer