--[[
***
***CPF验证页面
]]
local CpfLayer =
    class(
    "CpfLayer",
    function(args)
        local CpfLayer = display.newLayer()
        return CpfLayer
    end
)
function CpfLayer:onExit()
    
end
function CpfLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)

    local csbNode = g_ExternalFun.loadCSB("message/CpfLayer.csb")
    self:addChild(csbNode)

    self.bg = csbNode:getChildByName("bg")
    self.content = csbNode:getChildByName("content")
    ShowCommonLayerAction(self.bg, self.content)

    self.bg:onClicked(handler(self, self.onClickClose), true)
    self.content:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    local callback = function()
        self.editActive = true
        performWithDelay(
            self.inputPsd1,
            function()
                self.editActive = false
            end,
            0.5
        )
    end
    self.inputPsd1 = self.content:getChildByName("inputPsd1"):convertToEditBox()
    
    self.inputPsd1:onDidReturn(callback)
    
    self.inputPsd1:setMaxLength(13)
    

    self.content:getChildByName("sendBtn"):onClicked(
        function()
            
        end,
        true
    )

    
end


function CpfLayer:onClickClose()
    if self.editActive == true then
        self.editActive = false
        return
    end
    DoHideCommonLayerAction(
        self.bg,
        self.content,
        function()
            self:removeSelf()
        end
    )
end

return CpfLayer
