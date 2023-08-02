---------------------------------------------------
--Desc:VIP帮助界面
--Date:2023-02-15 14:37:40
--Author:A*
---------------------------------------------------

local HallVIPHelpLayer = class("HallVIPHelpLayer",function(args)
    local HallVIPHelpLayer =  display.newLayer()
    return HallVIPHelpLayer
end)

function HallVIPHelpLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_VIP_GET_LEVEL_CONFIG)  
end

function HallVIPHelpLayer:ctor(args)
    --提前加载合图
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("client/res/VIP/VIPPlist.plist", "client/res/VIP/VIPPlist.png")
    spriteFrameCache:addSpriteFrames("client/res/VIP/PlistVipHelp.plist", "client/res/VIP/PlistVipHelp.png")

    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)    
    local csbNode = g_ExternalFun.loadCSB("VIP/LayerVIPHelp.csb")
    self:addChild(csbNode)    
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    
    self.mm_Panel_item:setVisible(false)
    --呼出动效
    ShowCommonLayerAction(self.mm_bg,self.mm_Image_bg)
    --self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)

    G_event:AddNotifyEvent(G_eventDef.EVENT_VIP_GET_LEVEL_CONFIG,handler(self,self.onGetGrowLevelConfig))   --提取成长礼包 返回
    G_ServerMgr:C2S_GetGrowLevelConfig()           
end

function HallVIPHelpLayer:onGetGrowLevelConfig(data)
    dump(data)
    self.mm_ListView_1:removeAllItems()
    for i, v in ipairs(data) do
        local item = self.mm_Panel_item:clone()--g_ExternalFun.loadCSB("PiggyBank/NodeCharge.csb")
        item:setVisible(true)
        local itemBG = item:getChildByName("itemBG")  
        local Text_1 = item:getChildByName("Text_1")  
        local Text_2 = item:getChildByName("Text_2")  
        local Text_3 = item:getChildByName("Text_3") 
        local Text_4 = item:getChildByName("Text_4")  
        local Text_5 = item:getChildByName("Text_5")   
        if i%2 ~= 0 then
            itemBG:setVisible(false)
        end
        Text_1:setString("Vip"..v.cbGrowLevel)  -- 等级
        if v.cbGrowLevel == GlobalUserItem.VIPLevel then
            Text_1:setTextColor(cc.c3b(234,130,7))
            Text_2:setTextColor(cc.c3b(234,130,7))
            Text_3:setTextColor(cc.c3b(234,130,7))
            Text_4:setTextColor(cc.c3b(234,130,7))
            Text_5:setTextColor(cc.c3b(234,130,7))
        end
        local score_gift = g_format:formatNumber(v.llGrowGift,g_format.fType.abbreviation,g_format.currencyType.GOLD)
        Text_2:setString(score_gift)  -- 成长等级礼包
        local score_week = g_format:formatNumber(v.llWeekGift,g_format.fType.abbreviation,g_format.currencyType.GOLD)
        Text_3:setString(score_week) -- 成长周礼包
        local score_month = g_format:formatNumber(v.llMonthGift,g_format.fType.abbreviation,g_format.currencyType.GOLD)
        Text_4:setString(score_month)  -- 成长月礼包
        local score_add = v.wDailyAddition.."%"
        Text_5:setString(score_add)  -- 当前等级日转盘加成百分比
        self.mm_ListView_1:pushBackCustomItem(item)
    end
end

function HallVIPHelpLayer:onClickClose()
    DoHideCommonLayerAction(self.bg,self.mm_Image_bg,function()        
        self:removeSelf() 
    end)
end

return HallVIPHelpLayer