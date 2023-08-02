--[[
***
***
]]
local InputPhoneLayer = class("InputPhoneLayer",function(args)
		local InputPhoneLayer =  display.newLayer()
    return InputPhoneLayer
end)
local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")
function InputPhoneLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("ingots/InputPhoneLayer.csb")
    self:addChild(csbNode)

    self.bg = csbNode:getChildByName("image_bg")
    self.node = csbNode:getChildByName("nodePhone")
    ShowCommonLayerAction(self.bg,self.node)
    csbNode:getChildByName("btnOutClose"):onClicked(handler(self,self.onClickClose),true)
    self.node:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    self.node:getChildByName("btnSure"):onClicked(handler(self,self.onClickSure))
    self.inputPhone = self.node:getChildByName("inputPhone"):convertToEditBox(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.inputPhone:onDidReturn(function()
        self.editActive = true
        performWithDelay(self.inputPhone,function() self.editActive = false end,0.5)
    end)
    self.selectIndex = args.index  -- 10,30,50话费
end
function InputPhoneLayer:onClickClose()
    if self.editActive == true then 
        self.editActive = false
        return 
    end
    DoHideCommonLayerAction(self.bg,self.node,function() self:removeSelf() end)
end
function InputPhoneLayer:onClickSure()
    local phone = self.inputPhone:getString()
    if phone == "" then
        showToast(g_language:getString("input_phone_empty"))  
        return        
    end
    local txt = "ส่งคำสั่งซื้อเครดิตการโทรของคุณแล้ว หากคุณไม่"     --您的话费订单已提交,如您三日内未
    local txt1 = "รับการเติมเงินโปรดติดต่อเราโดยเร็วที่สุด"   --收到话费充值,请尽快联系我们
 	local dialog = QueryDialog:create({txt,txt1},function(bConfirm)
	     if bConfirm == true then     
              local index = self.selectIndex
              self:removeSelf()
	     end					
	end)
    self:addChild(dialog)
end

return InputPhoneLayer