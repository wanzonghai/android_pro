--[[
***
***
]]
local HallIngotsLayer = class("HallIngotsLayer",function(args)
		local HallIngotsLayer =  display.newLayer()
    return HallIngotsLayer
end)
local ingotsCount = {100,300,500}
function HallIngotsLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("ingots/IngotsLayer.csb")
    self:addChild(csbNode)

    self.bg = csbNode:getChildByName("image_bg")
    self.node = csbNode:getChildByName("nodeIngots")
    ShowCommonLayerAction(self.bg,self.node)
    csbNode:getChildByName("btnOutClose"):onClicked(handler(self,self.onClickClose),true)
    self.node:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    local str = g_format:formatNumber(GlobalUserItem.lTCCoin,g_format.fType.standard,g_format.currencyType.GOLD)
    self.node:getChildByName("txtIngots"):setString(str)
    self.btnItem = {}   --赠送，赠送记录，收礼记录
    self.panelItem = {}  --赠送，赠送记录，收礼记录
    for i=1,2 do
        self.btnItem[i] = self.node:getChildByName("btnItem"..i)
        self.btnItem[i]:onClicked(function() self:onShowPanel(i) end)
        self.panelItem[i] = self.node:getChildByName("panelItem"..i)
    end
    for i=1,3 do
         local btn = self.panelItem[1]:getChildByName("btnExchange"..i)
         btn:getChildByName("txtCount"):setString(ingotsCount[i])
         btn:onClicked(function() self:onClickExchange(i) end)
    end
    self.panelItem[2]:setScrollBarEnabled(false)
end
function HallIngotsLayer:onClickClose()
    DoHideCommonLayerAction(self.bg,self.node,function() self:removeSelf() end)
end
function HallIngotsLayer:onShowPanel(index)
    index = index or 1
    if self.curIndex == index then return end  
    self.curIndex = index
    local name = {"btnExchange","btnExRecord"}
    for i=1,2 do
        self.panelItem[i]:setVisible(i == index)
        local str = "ingots/"..name[i].."2.png"
        if i == index then
             str = "ingots/"..name[i].."1.png"
        end
        self.btnItem[i]:loadTextures(str,str)
    end
    if i == 2 and self.cbRecord == nil then  --请求记录
        
    end
end

function HallIngotsLayer:onClickExchange(index)
    G_event:NotifyEvent(G_eventDef.UI_EVEVNT_SHOW_INPUTPHONELAYER,{index = index})
end

function HallIngotsLayer:onUpdateRecord()
    self.ingotsRecord = self.ingotsRecord or {}
    local height = #self.ingotsRecord * 185
    if height < 380 then
        height = 380
    end
    self.scrollviewGive:setInnerContainerSize(cc.size(1160,height))
    for i,v in pairs(self.ingotsRecord) do
        local itemY = height-70-(i-1)*185
        local item = cc.CSLoader:createNode("ingots/item.csb")
        item:setPosition(580,itemY)
        self.scrollviewGive:addChild(item)
        local imgHead = item:getChildByName("imgItem")
        imgHead:loadTexture("ingots/sp_ex_coin1.png")
        imgHead:setContentSize(cc.size(90,90))
        item:getChildByName("txtName"):setString(v.dwTargetNickName)
        local str = g_format:formatNumber(v.lSwapScore,g_format.fType.standard,g_format.currencyType.GOLD)
        item:getChildByName("txtIngots"):setString(str)
        local date = os.date("%Y-%m-%d %H:%M", tonumber(item.llCollectDate))
        item:getChildByName("txtTime"):setString(date)
    end
end

return HallIngotsLayer