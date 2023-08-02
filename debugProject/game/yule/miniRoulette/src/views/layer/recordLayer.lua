--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2023-02-18 12:00:23
]]

local recordLayer = class("recordLayer",ccui.Layout)


function recordLayer:onExit()
    
end

function recordLayer:ctor(gameRecord)

    local csbNode = cc.CSLoader:createNode("UI/recordLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    self:addChild(csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
    self:init()


end

function recordLayer:init()
    self.mm_btn_close:onClicked(function() self:removeSelf() end)
    self.mm_content:addClickEventListener(function() self:removeSelf() end)

    self.mm_ListView_1:setItemModel(self.mm_item_model)
    self.mm_ListView_1:removeAllItems()
    self.mm_ClubList_ListView:setBounceEnabled(true) --滑动惯性
    self.mm_ClubList_ListView:setScrollBarEnabled(false)   
end


return recordLayer