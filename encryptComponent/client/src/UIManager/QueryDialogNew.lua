local QueryDialogNew = class("QueryDialogNew", function(msg,callback,outClose)
	local QueryDialogNew = display.newLayer()
    return QueryDialogNew
end)

function QueryDialogNew:ctor(msg, callback,outClickClose)
	local csbNode = g_ExternalFun.loadCSB("DialogOld.csb")
    csbNode:setContentSize(display.size)
    csbNode:setPosition(cc.p(0,0))
    ccui.Helper:doLayout(csbNode)
	self:addChild(csbNode)

    self.bg = csbNode:getChildByName("bg")    
    self.content = csbNode:getChildByName("content")
    ShowCommonLayerAction(self.bg,self.content)
    self.bg:onClicked(function ()
        if outClickClose ~= false then
            self:onClickEvent(false,callback)
        end
    end)
    
    self.content:getChildByName("btnClose"):onClicked(function ()        
        self:onClickEvent(false,callback)        
    end)
    
    self.content:getChildByName("btnSure"):onClicked(function ()        
        self:onClickEvent(true,callback)        
    end)
    self.title = self.content:getChildByName("title")
    self.TXT = self.content:getChildByName("TXT")    
    self:showTxt(msg)
end

function QueryDialogNew:setCanTouchOutside()
end

function QueryDialogNew:showTxt(msg)
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

function QueryDialogNew:onClickEvent(isClose,callback)
    if DoHideCommonLayerAction == nil or type(DoHideCommonLayerAction) ~= "function" then
	     if callback then
	         callback(isClose)
	     end
         if tolua.cast(self,"cc.Layer") then
             self:removeSelf()
         end         
        return
    end
    DoHideCommonLayerAction(self.bg,self.content,function() 
	     if callback then
	         callback(isClose)
	     end
         if tolua.cast(self,"cc.Layer") then
             self:removeSelf()
         end 
    end)        
end

return QueryDialogNew
