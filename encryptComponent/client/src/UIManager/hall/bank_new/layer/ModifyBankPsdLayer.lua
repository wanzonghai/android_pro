--[[
***
***
]]
local ModifyBankPsdLayer = class("ModifyBankPsdLayer",function(args)
		local ModifyBankPsdLayer =  display.newLayer()
    return ModifyBankPsdLayer
end)
function ModifyBankPsdLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_OPERATE_SUCCESS)
end
function ModifyBankPsdLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("bank_new/ModifyBankPsdLayer.csb")
    self:addChild(csbNode)

    self.bg = csbNode:getChildByName("bg")
    self.content = csbNode:getChildByName("content")
    ShowCommonLayerAction(self.bg,self.content)
    self.bg:onClicked(handler(self,self.onClickClose),true)
    self.content:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    self.content:getChildByName("btnSure"):onClicked(handler(self,self.onClickModify))
    local callback = function()
        self.editActive = true
        performWithDelay(self.inputPsd1,function() self.editActive = false end,0.5)
    end
    self.inputPsd1 = self.content:getChildByName("inputPsd1"):convertToEditBox()     --旧密码
    self.inputPsd2 = self.content:getChildByName("inputPsd2"):convertToEditBox()   --新密码
    self.inputPsd3 = self.content:getChildByName("inputPsd3"):convertToEditBox()   --确认新密码
    self.inputPsd1:onDidReturn(callback)
    self.inputPsd2:onDidReturn(callback)
    self.inputPsd3:onDidReturn(callback)
    self.inputPsd1:setMaxLength(12)
    self.inputPsd2:setMaxLength(12)
    self.inputPsd3:setMaxLength(12)
    self.inputPsd1:setPlaceholderFontColor(cc.c4b(165,134,165,255))
    self.inputPsd2:setPlaceholderFontColor(cc.c4b(165,134,165,255))
    self.inputPsd3:setPlaceholderFontColor(cc.c4b(165,134,165,255))
    -- self.content:getChildByName("inputPsd1"):setPlaceholderFontColor(ccColor3B(131,66,55))
    -- self.content:getChildByName("inputPsd2"):setPlaceholderFontColor(ccColor3B(131,66,55))
    -- self.content:getChildByName("inputPsd3"):setPlaceholderFontColor(ccColor3B(131,66,55))

    G_event:AddNotifyEvent(G_eventDef.NET_OPERATE_SUCCESS,handler(self,self.OperateSuccess))     --操作成功
end
function ModifyBankPsdLayer:onClickClose()
    if self.editActive == true then 
        self.editActive = false
        return 
    end
    DoHideCommonLayerAction(self.bg,self.content,function() self:removeSelf() end)
end
function ModifyBankPsdLayer:onClickModify()
    local psd1 = self.inputPsd1:getString()
    local psd2 = self.inputPsd2:getString()
    local psd3 = self.inputPsd3:getString()
    if psd1 == "" then
        showToast(g_language:getString("old_bankpsd_empty"))  
        return
    end
    if psd1 ~= GlobalData.BankPassword then
        showToast(g_language:getString("old_bankpsd_error"))  
        self.inputPsd1:setString("")
        return        
    end
    if psd2 == "" or psd3 == "" then
        showToast(g_language:getString("new_bankpsd_empty"))  
        return
    end
    if #psd1 < 6 or #psd2 < 6 or #psd3 < 6 then
        showToast(g_language:getString("psd_length_less6"))  
        return
    end
    if psd2 ~= psd3 then
        showToast(g_language:getString("two_bankpsd_notequal"))  
        return
    end
    self._newBankPsd = psd2
    G_ServerMgr:C2S_ModifyBankPsd(psd1, psd2)
    showNetLoading()
end

function ModifyBankPsdLayer:OperateSuccess(args)
    dismissNetLoading()
    if args.subId == G_NetCmd.C_SUB_MODIFY_INSURE_PASS then   --修改银行密码成功
        if GlobalData.FirstOpenBank == false then
           GlobalData.BankPassword = self._newBankPsd
        end
        showToast(g_language:getString("bankpsd_modify_success"))
        DoHideCommonLayerAction(self.bg,self.content,function() self:removeSelf() end)
    end
end

return ModifyBankPsdLayer