--[[
    TC 新版银行
]]

local bankHallLayer = class("bankHallLayer",ccui.Layout)
local bankCmd = require(appdf.CLIENT_SRC.."UIManager.hall.bank_new.data.CMD_bankServer")



function bankHallLayer:onExit()
    self.bankData:onExit()
    self.mm_sub_access:onExit()
    self.mm_sub_transfer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_TRANSFER_MERCHANT_LIST)
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() self:removeSelf() end)
end
function bankHallLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    local csbNode = g_ExternalFun.loadCSB("bank_new/bankHallLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
    self.bankData =  appdf.req(appdf.CLIENT_SRC.."UIManager.hall.bank_new.data.bankData").new()
    self:initSpine()
    self:initUI(csbNode)

    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
    else
        G_event:AddNotifyEvent(G_eventDef.NET_TRANSFER_MERCHANT_LIST, handler(self, self.onGetTransferUserList)) --获取币商列表
        --查询下币商列表，有列表数据可以打开转账操作子页
        self.bankData:C2S_RequestBoss(10,1)
    end

end

function bankHallLayer:initUI(scbNode)
    --存取节点
    g_ExternalFun.addScriptForChildNode(self.mm_sub_access,"client/src/UIManager/hall/bank_new/layer/sub_Access",{root = self})
    --转账节点
    g_ExternalFun.addScriptForChildNode(self.mm_sub_transfer,"client/src/UIManager/hall/bank_new/layer/sub_transfer",{root = self})

    self.mm_btnClose:onClicked(function() self:onExit() end)
    -- 金币
    self.mm_btn_gold:onClicked(function() self:setBgSkin(g_format.currencyType.GOLD) end)
    -- TC
    self.mm_btn_tc:onClicked(function() self:setBgSkin(g_format.currencyType.TC) end)
    
    --存入
    self.mm_btn_save:onClicked(function() self:runSpine(bankCmd.behaviorType.save) end)
    --取出
    self.mm_btn_take:onClicked(function() self:runSpine(bankCmd.behaviorType.take) end)
    --转账
    self.mm_btn_transfer:onClicked(function() self:runSpine(bankCmd.behaviorType.transfer) end)
    --存入
    self.mm_btn_save_tc:onClicked(function() self:runSpine(bankCmd.behaviorType.save) end)
    --取出
    self.mm_btn_take_tc:onClicked(function() self:runSpine(bankCmd.behaviorType.take) end)
    --转账
    self.mm_btn_transfer_tc:onClicked(function() self:runSpine(bankCmd.behaviorType.transfer) end)
    --默认金币
    self:setBgSkin(g_format.currencyType.GOLD)
    --默认转账
    self:runSpine(bankCmd.behaviorType.save)

    self.mm_btn_JL:onClicked(function() 
        G_event:NotifyEvent(G_eventDef.UI_SHOW_RECORDLAYER,{type = self.m_curBehaviorType,currencyType = g_format.currencyType.GOLD})
    end)
    self.mm_btn_JL_tc:onClicked(function()
        G_event:NotifyEvent(G_eventDef.UI_SHOW_RECORDLAYER,{type = self.m_curBehaviorType,currencyType = g_format.currencyType.TC})
    end)
    self.mm_btn_KF:onClicked(function() G_event:NotifyEvent(G_eventDef.UI_OPEN_SERVICELAYER) end)
    self.mm_btn_XGMM:onClicked(function()  G_event:NotifyEvent(G_eventDef.UI_MODIFYT_BANKPSDLAYER) end)
    self.mm_btn_KF_tc:onClicked(function() G_event:NotifyEvent(G_eventDef.UI_OPEN_SERVICELAYER) end)
    self.mm_btn_XGMM_tc:onClicked(function()  G_event:NotifyEvent(G_eventDef.UI_MODIFYT_BANKPSDLAYER) end)

end

function bankHallLayer:adjustByProject()
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        self.mm_btn_transfer:hide()
        self.mm_btn_transfer_tc:hide()
        self.mm_btn_JL:hide()
        self.mm_btn_XGMM:setPosition(self.mm_btn_KF:getPosition())
        self.mm_btn_XGMM:hide()
        self.mm_btn_KF:setPosition(self.mm_btn_JL:getPosition())
    end
end

function bankHallLayer:initSpine()
    self.skeletonNode = sp.SkeletonAnimation:create("client/res/bank_new/spine/yinhang.json", "client/res/bank_new/spine/yinhang.atlas", 1)
    self.skeletonNode:setAnimation(0, "cunqian", true)
    self.skeletonNode:setSkin("moedas")
    self.skeletonNode:setPosition(cc.p(-53,0))
    self.mm_Panel_spine:addChild(self.skeletonNode)
end

function bankHallLayer:runSpine(behaviorType)
    self.m_curBehaviorType = behaviorType 
    self:btnStatus(behaviorType)

    if behaviorType == bankCmd.behaviorType.save then
        self.skeletonNode:setAnimation(0, "cunqian", true)
    elseif behaviorType == bankCmd.behaviorType.take then
        self.skeletonNode:setAnimation(0, "quqian", true)
    elseif behaviorType == bankCmd.behaviorType.transfer then
        self.skeletonNode:setAnimation(0, "shousuo", true)
    else
    end
end

function bankHallLayer:setBgSkin(type)
    if type == g_format.currencyType.TC then
        self.skeletonNode:setSkin("tc")
        self.mm_title_tc:show()
        self.mm_Panel_tc:show()
        self.mm_Panel_gold:hide()
    else
        if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then 
            self.mm_title_gold:hide()
            self.mm_title_tc:hide()
            self.mm_btn_gold:hide()
            self.mm_btn_tc:hide()
            self.skeletonNode:setSkin("biaodi")
            self.mm_Panel_tc:hide()
            self.mm_Panel_gold:show()
            self:adjustByProject()
        else
            self.mm_title_tc:hide()
            self.skeletonNode:setSkin("moedas")
            self.mm_Panel_tc:hide()
            self.mm_Panel_gold:show()
        end
    end
    self.mm_sub_transfer:selectCurrencyType(type)
    self.mm_sub_access:selectCurrencyType(type)
end

function bankHallLayer:btnStatus(behaviorType)
    self.mm_btn_save:setBright(true) 
    self.mm_btn_take:setBright(true) 
    self.mm_btn_transfer:setBright(true) 
    self.mm_sub_access:hide()
    self.mm_sub_transfer:hide()
    if behaviorType == bankCmd.behaviorType.save then
        self.mm_btn_save:setBright(false) 
        self.mm_sub_access:show()
    elseif behaviorType == bankCmd.behaviorType.take then
        self.mm_btn_take:setBright(false) 
        self.mm_sub_access:show()
    elseif behaviorType == bankCmd.behaviorType.transfer then
        self.mm_btn_transfer:setBright(false) 
        self.mm_sub_transfer:show()
    else
    end
    self:btnStatus_tc(behaviorType)
    self.mm_sub_access:selectBehaviorType(behaviorType)
    self.mm_sub_transfer:selectBehaviorType(behaviorType)
end

function bankHallLayer:btnStatus_tc(behaviorType)
    self.mm_btn_save_tc:setBright(true) 
    self.mm_btn_take_tc:setBright(true) 
    self.mm_btn_transfer_tc:setBright(true) 
    self.mm_sub_access:hide()
    self.mm_sub_transfer:hide()
    if behaviorType == bankCmd.behaviorType.save then
        self.mm_btn_save_tc:setBright(false) 
        self.mm_sub_access:show()
    elseif behaviorType == bankCmd.behaviorType.take then
        self.mm_btn_take_tc:setBright(false) 
        self.mm_sub_access:show()
    elseif behaviorType == bankCmd.behaviorType.transfer then
        self.mm_btn_transfer_tc:setBright(false) 
        self.mm_sub_transfer:show()
    else
    end
end

function bankHallLayer:onGetTransferUserList(listData)
    dump(listData.info)
    if listData.info.dwErrorCode ~= 0 then
        if listData.info.dwErrorCode >= 800 then
            showToast(g_language:getString(listData.info.dwErrorCode))
        end
        --没入会的
        if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        else
            showToast(g_language:getString("bank_tips_1"))
        end
        
        self.mm_btn_transfer:hide()
        self.mm_btn_transfer_tc:hide()
    else
        if table.isEmpty(listData.info.lsItems) then
            return
        end
        if table.nums(listData.info.lsItems) == 0 then
            return
        end
        if listData.info.lsItems and table.nums(listData.info.lsItems) then
            --商人列表
            self.merchantList = listData.info.lsItems
        end

        --入会了
        if GlobalUserItem.cbMemberOrder == 0 then
            --cbMemberOrder  0:普通玩家，1：会长 2~..：其他扩展身份    88468836
            local userData = {
                FaceID = self.merchantList[1].dwFaceID,
                GameID = self.merchantList[1].dwGameID,
                UserID = self.merchantList[1].dwUserID,
                NickName = self.merchantList[1].szNickName
            }
            self.mm_sub_transfer:updataCurrUser(userData,true) --会员显示的只有会长

        else
        end
    end

end


return bankHallLayer