local RechargeTips = class("RechargeTips", function(msg,callback,outClose)
	local RechargeTips = display.newLayer()
    return RechargeTips
end)

function RechargeTips:ctor(msg, callback,outClickClose)
	local csbNode = cc.CSLoader:createNode("recharge/RechargeTips.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
	self:addChild(csbNode)

    self.bg = csbNode:getChildByName("bg")    
    self.content = csbNode:getChildByName("content")
    if ShowCommonLayerAction == nil then
        if self.bg then
            self.bg:runAction(cc.FadeTo:create(0.2,255))
        end
        local scale1 = cc.ScaleTo:create(0.11,1.1)
        local scale2 = cc.ScaleTo:create(0.11,1)
        self.content:runAction(cc.Sequence:create(scale1,scale2))
    else
        ShowCommonLayerAction(self.bg,self.content)
    end

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
    --单行提示信息
    self.txtCommon = self.content:getChildByName("txtCommon")    
    --三行提示信息
    self.txtTitle = self.content:getChildByName("txtTitle")
    self.txtContent = self.content:getChildByName("txtContent")
    self.txtSignature = self.content:getChildByName("txtSignature")
    self:showTXTCommon(msg)
end

function RechargeTips:setCanTouchOutside()
    
end

function RechargeTips:showTXTCommon(msg)
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
    self.txtCommon:setString(pString)
end

function RechargeTips:showTXTTitle(pTitle)
    self.txtTitle:setString(pTitle)
end

function RechargeTips:showTXTContent(pContent)
    self.txtContent:setString(pContent)
end

function RechargeTips:showTXTSignature(pSignature)
    self.txtSignature:setString(pSignature)
end

function RechargeTips:onClickEvent(isClose,callback)
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

return RechargeTips
