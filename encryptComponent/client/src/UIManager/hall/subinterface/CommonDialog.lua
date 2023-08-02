
DialogType = g_ExternalFun.enum{
    "ConfirmBox = 1",   --只有 知道了 按钮 点x关闭
    "SelectBox = 2",   --确定 取消 
    "CashOutBox = 3",   --再次申请 客服 
    "ShareNewPlayer = 4"    --拉新好友
}

local CommonDialog = class("CommonDialog", function(msg,callback,outClose)
	local CommonDialog = display.newLayer()
    return CommonDialog
end)

function CommonDialog:ctor(args)--msg, callback,outClickClose)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene() 
    if args.name then
        self:setName(args.name)
    end
    parent:addChild(self,ZORDER.POPUP)

    local msg = args.msg
    self.dialogType = args.dialogType or DialogType.ConfirmBox
    self.fontSize = args.fontSize
    self.callback = args.callback or args.callback
    self.outClickClose = args.outClickClose

	local csbNode = g_ExternalFun.loadCSB("dialog/CommonDialog.csb")
    csbNode:setContentSize(display.size)
    csbNode:setPosition(cc.p(0,0))
    ccui.Helper:doLayout(csbNode)
	self:addChild(csbNode)

    self.bg = csbNode:getChildByName("bg")    
    self.content = csbNode:getChildByName("content")
    ShowCommonLayerAction(self.bg,self.content)
    self.bg:onClicked(function ()
        if self.outClickClose ~= false then
            self:onClickEvent("close",self.callback)
        end
    end)
    
    self.btnClose = self.content:getChildByName("btnClose")
    self.btnClose:onClicked(function ()        
        self:onClickEvent("close",self.callback)        
    end)
    
    self.btnSure = self.content:getChildByName("btnSure")
    self.btnSure:onClicked(function ()        
        self:onClickEvent("ok",self.callback)        
    end)

    self.btnLeft = self.content:getChildByName("btnLeft")
    self.btnLeft:onClicked(function ()        
        self:onClickEvent("ok",self.callback) 
    end)

    self.btnRight = self.content:getChildByName("btnRight")
    self.btnRight:onClicked(function ()        
        self:onClickEvent("cancel",self.callback) 
    end)
    self.title = self.content:getChildByName("title")
    self.TXT = self.content:getChildByName("TXT")    
    if self.fontSize then
        self.TXT:setFontSize(self.fontSize)
    end
    self:showTxt(msg)

    if self.dialogType == DialogType.ConfirmBox then --确定
        self.btnSure:setVisible(true)
        self.btnLeft:setVisible(false)
        self.btnRight:setVisible(false)
    elseif self.dialogType == DialogType.SelectBox then --确定取消
        self.btnSure:setVisible(false)
        self.btnLeft:setVisible(true)
        self.btnRight:setVisible(true)
    elseif self.dialogType == DialogType.CashOutBox then --再次申请 客服 
        self.btnSure:setVisible(false)
        self.btnLeft:setVisible(true)
        self.btnRight:setVisible(true)
        self.btnLeft:loadTextures("client/res/dialog/GUI/shangdian_an_btn.png","","",UI_TEX_TYPE_PLIST)
        self.btnRight:loadTextures("client/res/dialog/GUI/shangdian_xueding_btn.png","","",UI_TEX_TYPE_PLIST)
        -- self.TXT:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	    self.TXT:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    elseif self.dialogType == DialogType.ShareNewPlayer then            --拉新好友
        self.btnSure:setVisible(false)
        self.btnLeft:setVisible(true)
        self.btnRight:setVisible(true)
        self.btnLeft:loadTextures("client/res/ShareTurnTable/bt_001.png","","",UI_TEX_TYPE_PLIST)
        self.btnRight:loadTextures("client/res/ShareTurnTable/bt_002.png","","",UI_TEX_TYPE_PLIST)
    end 
end

function CommonDialog:setCanTouchOutside()
end

function CommonDialog:showTxt(msg)
    local pString = ""
    if type(msg) == "table" then
        for i, v in ipairs(msg) do
            pString = pString .. v
            if i~=#msg then
                pString = pString .. "\n"
            end
        end
    else
        pString = msg
    end
    self.TXT:setString(pString)
end

function CommonDialog:onClickEvent(click,callback)
    if DoHideCommonLayerAction == nil or type(DoHideCommonLayerAction) ~= "function" then
	     if callback then
	         callback(click)
	     end
         if tolua.cast(self,"cc.Layer") then
             self:removeSelf()
         end         
        return
    end
    DoHideCommonLayerAction(self.bg,self.content,function() 
	     if callback then
	         callback(click)
	     end
         if tolua.cast(self,"cc.Layer") then
             self:removeSelf()
         end 
    end)        
end

return CommonDialog
