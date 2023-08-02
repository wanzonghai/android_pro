--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2023-02-18 12:00:23
]]

local helpLayer = class("helpLayer",ccui.Layout)


function helpLayer:onExit()
    
end

function helpLayer:ctor(gameRecord)

    local csbNode = cc.CSLoader:createNode("UI/helpLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    self:addChild(csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
    g_ExternalFun.loadChildrenHandler(self, csbNode)
    self:init()
end

function helpLayer:init()
    self.mm_btn_close:onClicked(function() self:removeSelf() end)
    self.mm_content:addClickEventListener(function() self:removeSelf() end)
end

return helpLayer