--[[
***
***
]]
local OpenBankLayer = class("OpenBankLayer",function(args)
		local OpenBankLayer =  display.newLayer()
    return OpenBankLayer
end)
function OpenBankLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_OPEN_BANK_RESULT)
end
function OpenBankLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("bank_new/OpenBank.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
    self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnSure:onClicked(handler(self,self.onClickSure))
    local callback = function()
        self.editActive = true
        performWithDelay(self.inputPsd1,function() self.editActive = false end,0.5)
    end
    self.inputPsd1 = self.mm_inputPsd1:convertToEditBox() 
    self.inputPsd2 = self.mm_inputPsd2:convertToEditBox() 
    self.inputPsd1:onDidReturn(callback)
    self.inputPsd2:onDidReturn(callback)
    self.inputPsd1:setMaxLength(12)
    self.inputPsd2:setMaxLength(12)
    self.inputPsd1:setPlaceholderFontColor(cc.c4b(165,134,165,255))
    self.inputPsd2:setPlaceholderFontColor(cc.c4b(165,134,165,255))
    G_event:AddNotifyEvent(G_eventDef.NET_OPEN_BANK_RESULT,handler(self,self.onOpenBankResult))
end
function OpenBankLayer:onClickClose()
    if self.editActive == true then 
        self.editActive = false
        return 
    end
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() self:removeSelf() end)
end
function OpenBankLayer:onClickSure()
    local psd1 = self.inputPsd1:getString()
    local psd2 = self.inputPsd2:getString()
    if psd1 == "" or psd2 == "" then
        showToast(g_language:getString("input_psd_empty"))  
        return
    end
    if #psd1 < 6 or #psd2 < 6 then
        showToast(g_language:getString("psd_length_less6"))  
        return
    end
    if psd1 ~= psd2 then
        showToast(g_language:getString("two_bankpsd_notequal"))  
        return
    end
    G_ServerMgr:C2S_EnableBank(psd2)
    showNetLoading()
end

--登录开通结果
function OpenBankLayer:onOpenBankResult(args)
    dismissNetLoading()
    if args.bFirstEnable == true then  --第一次开通
        local szPass = self.inputPsd1:getString()
        GlobalData.BankPassword = szPass
        GlobalData.FirstOpenBank = false
        DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() 
            self:removeSelf()
            G_event:NotifyEvent(G_eventDef.UI_SHOW_BANKLAYER_NEW)
            -- if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then 
            --     G_event:NotifyEvent(G_eventDef.UI_SHOW_BANKLAYER)
            -- else
            --     G_event:NotifyEvent(G_eventDef.UI_SHOW_BANKLAYER_NEW)                
            -- end
        end)
    end
end
return OpenBankLayer