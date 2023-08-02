--[[
***
***
]]
local LogonBankLayer = class("LogonBankLayer",function(args)
		local LogonBankLayer =  display.newLayer()
    return LogonBankLayer
end)
function LogonBankLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_OPERATE_SUCCESS)
end
function LogonBankLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("bank_new/LogonBank.csb")
    self:addChild(csbNode)

    self.bg = csbNode:getChildByName("bg")
    self.content = csbNode:getChildByName("content")
    ShowCommonLayerAction(self.bg,self.content)
    self.bg:onClicked(handler(self,self.onClickClose),true)
    self.content:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    self.content:getChildByName("btnSure"):onClicked(handler(self,self.onClickSure))
    self.inputPsd = self.content:getChildByName("inputPsd"):convertToEditBox() 
    self.inputPsd:setMaxLength(12)
    self.inputPsd:onDidReturn(function()
        self.editActive = true
        performWithDelay(self.inputPsd,function() self.editActive = false end,0.5)
    end)
    self.inputPsd:setPlaceholderFontColor(cc.c4b(165,134,165,255))
    G_event:AddNotifyEvent(G_eventDef.NET_OPEN_BANK_RESULT,handler(self,self.onLogonBankResult))
end
function LogonBankLayer:onClickClose()
    if self.editActive == true then 
        self.editActive = false
        return 
    end
    DoHideCommonLayerAction(self.bg,self.content,function() self:removeSelf() end)
end
function LogonBankLayer:onClickSure()
    local psd = self.inputPsd:getString()
    if psd == "" then
        showToast(g_language:getString("input_psd_empty"))  
        return
    end
    if #psd < 6 then
        showToast(g_language:getString("psd_length_less6"))  
        return
    end
    G_ServerMgr:C2S_EnableBank(psd)
    showNetLoading()
end

--登录银行结果
function LogonBankLayer:onLogonBankResult(args)
    dismissNetLoading()
    if args.tips == "" then  --打开成功
        GlobalData.FirstOpenBank = false
        GlobalData.BankPassword = self.inputPsd:getString()
        DoHideCommonLayerAction(self.bg,self.content,function() 
            self:removeSelf() 
            G_event:NotifyEvent(G_eventDef.UI_SHOW_BANKLAYER_NEW)
            -- if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then 
            --     G_event:NotifyEvent(G_eventDef.UI_SHOW_BANKLAYER)
            -- else
            --     G_event:NotifyEvent(G_eventDef.UI_SHOW_BANKLAYER_NEW)                
            -- end
        end)
    else
        self.inputPsd:setString("")
        showToast(g_language:getString("bank_psd_error"))  
    end
end
return LogonBankLayer