--[[
    破产补助
]]

local HallBaseEnsureLayer = class("HallBaseEnsureLayer",ccui.Layout)
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")

function HallBaseEnsureLayer:onExit()
    G_event:RemoveNotifyEvent(G_event.EVENT_ON_BASEENSURE_CALLBACK)
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() self:removeSelf() end)
end

function HallBaseEnsureLayer:ctor(args)
    self._scene = args
    local parent = cc.Director:getInstance():getRunningScene()
    parent:addChild(self,9999)
    local csbNode = g_ExternalFun.loadCSB("baseEnsure/baseEnsureLayer.csb")
    self:addChild(csbNode)
    -- ccui.Helper:doLayout(self)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
    self.mm_BitmapFontLabel_1:setString(g_format:formatNumber(GlobalData.baseEnsureData.lScoreAmount,g_format.fType.standard,g_format.currencyType.GOLD))
    self.mm_Text_count:setString(GlobalData.baseEnsureData.byRestTimes)
    self.mm_Text_maxCount:setString(GlobalData.baseEnsureData.MaxNumber)
    self.mm_Text_Desc:setString(g_format:formatNumber(GlobalData.baseEnsureData.lScoreAmount,g_format.fType.standard,g_format.currencyType.GOLD))
    

    self.mm_Button_close:onClicked(function() self:onClickClose()end)
    self.mm_bg:addClickEventListener(function() self:onClickClose() end)
    self.mm_Button_get:onClicked(function ()
        G_ServerMgr:C2S_TakeBaseEnsure()
    end)
    G_event:AddNotifyEvent(G_eventDef.EVENT_ON_BASEENSURE_CALLBACK,handler(self,self.onBaseEnsureCallback))
end

--领取低保返回 
function HallBaseEnsureLayer:onBaseEnsureCallback(data)
    dump(data)
    if data.dwErrorCode == 0 then
        --领取成功
        self:showAward(data.lGameScore,"client/res/public/mrrw_jb_3.png")
        G_ServerMgr:C2S_RequestUserGold()
        --更新可领取次数
        GlobalData.baseEnsureData.byRestTimes = data.bCount
        OSUtil.saveTable(GlobalData.baseEnsureData,"baseEnsure")
        EventPost:addCommond(EventPost.eventType.COLLECT,"破产补助领取成功！领取了"..data.bCount,data.bCount)
    else
        showToast(g_language:getString(data.dwErrorCode)) 
        if data.dwErrorCode == 721 then
            GlobalData.baseEnsureData.byRestTimes = data.bCount
            OSUtil.saveTable(GlobalData.baseEnsureData,"baseEnsure")
        end
    end
    self._scene:checkIsBankrupt()
    self:onClickClose()
end

function HallBaseEnsureLayer:showAward(goldTxt,goldImg)
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
    local data = {}
    data.goldTxt = g_format:formatNumber(goldTxt,g_format.fType.standard)
    data.goldImg = goldImg
    data.type = 1
    appdf.req(path).new(data)
end

function HallBaseEnsureLayer:onClickClose()
    --拉取破产补助配置
    G_ServerMgr:C2S_QueryBaseEnsure() 
    self:onExit() 
end

return HallBaseEnsureLayer