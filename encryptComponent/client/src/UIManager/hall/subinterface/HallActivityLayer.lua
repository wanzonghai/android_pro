---------------------------------------------------
--Desc:活动主界面
--Date:2022-11-26 17:33:40
--Author:A*
---------------------------------------------------
local HallActivityLayer = class("HallActivityLayer",function(args)
    local HallActivityLayer =  display.newLayer()
    return HallActivityLayer
end)

HallActivityLayer.ColorW = cc.c3b(91,31,5)
HallActivityLayer.ColorP = cc.c3b(63,17,121)

function HallActivityLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_HALL_BET_SCORE_DATA)   
end

function HallActivityLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self.Index = args.Index or 1
    self.NoticeNext = args.NoticeNext
    local csbNode = g_ExternalFun.loadCSB("Activity/ActivityLayer.csb")
    self:addChild(csbNode)    
    g_ExternalFun.loadChildrenHandler(self,csbNode)

    --背景
    self.SpineBg = sp.SkeletonAnimation:create("Activity/huodong_2.json","Activity/huodong_2.atlas", 1)
    self.SpineBg:addTo(self.mm_spine_1)
    self.SpineBg:setPosition(0, 0)
    self.SpineBg:setAnimation(0, "daiji", true)            

    --光效
    self.SpineLight = sp.SkeletonAnimation:create("Activity/huodong_1.json","Activity/huodong_1.atlas", 1)
    self.SpineLight:addTo(self.mm_spine_2)
    self.SpineLight:setPosition(0, 0)
    self.SpineLight:setAnimation(0, "daiji", true)  

    self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)
    
    self.mm_btnCustomer:onClicked(function ()
        G_event:NotifyEvent(G_eventDef.UI_OPEN_SERVICELAYER) 
    end)

    G_event:AddNotifyEvent(G_eventDef.EVENT_HALL_BET_SCORE_DATA,handler(self,self.onGetBetScoreResult))   --下注额返回监听
    
    --刷新左侧按钮列表
    self:initLeftList()
    --呼出动效
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
end

function HallActivityLayer:initLeftList()
    self.mm_listview:removeAllItems()
    self.mm_listview:setScrollBarEnabled(false)
    for i, v in ipairs(GlobalData.ActivityInfos) do
        local pItem = self.mm_Template:clone()
        pItem:show()
        pItem:getChildByName("word"):setString(v.szTitle)
        pItem:onClicked(handler(self,self.onItemClick))
        self.mm_listview:addChild(pItem)
    end  
    self:onItemClick(self.mm_listview:getItem(self.Index-1))
end

function HallActivityLayer:onItemClick(target)
    local pItems = self.mm_listview:getItems()
    for i, v in ipairs(pItems) do        
        v:setEnabled(v~=target)
        v:getChildByName("word"):setColor(v==target and self.ColorW or self.ColorP)
        if v == target then
            self:loadActivityPic(i)
        end
    end
end

function HallActivityLayer:loadActivityPic(i)
    local pSingle = GlobalData.ActivityInfos[i]
    DownloadPic:downloadNetPic(pSingle.szImgUrlMain,md5(pSingle.szImgUrlMain),function (result,path)
        if result then
            GlobalData.ActivityInfos[i].pathBig = path             
            self.mm_Detail:loadTexture(path)
            if GlobalData.BSIndex > 0 and GlobalData.BSIndex==i then
                local pType = 2
                if ylAll.ProjectSelect and ylAll.ProjectSelect==2 then
                    pType = 1
                end
                G_ServerMgr:C2S_GetBetScore(pType)
            else
                self.mm_BetScore:hide()
            end
        end
    end,true)
end

function HallActivityLayer:onGetBetScoreResult(pData)
    -- g_ExternalFun.setIcon(self.mm_Tips_Fluxo,pData.cbCurrencyType)
    local text = g_format:formatNumber(pData.TodayBetScore,g_format.fType.standard)
    self.mm_BetScore:setString(text)
    self.mm_BetScore:show()
end

function HallActivityLayer:onClickClose()
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function()    
        if self.NoticeNext then
            G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="HallActivity"})
        end
        self:removeSelf() 
    end)
end

return HallActivityLayer