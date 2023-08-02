--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2022-09-13 14:45:47
]]

local logic = appdf.req("game.yule.Plinko.src.models.GameLogic")

local autoBetListLayer = class("autoBetListLayer",ccui.Layout)

function autoBetListLayer:ctor(p_node)
    self.m_pNode = p_node
    local csbNode = cc.CSLoader:createNode("UI/autoBetLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    self.m_csbNode = csbNode
    self.mm_btn_startAuto:onClicked(handler(self,self.onStartAutoClick))

    for i=1,3 do
        self["mm_CheckBox_color_"..i]:setSelected(true)
        self["mm_CheckBox_color_"..i]:addClickEventListener(handler(self,self.onCheckBoxClick))
    end
    self:initData()
    self:addAutoBetBtnList()
end

function autoBetListLayer:initData()
    self.m_checkedCount = 1   --默认选中的自动投注下标
end

function autoBetListLayer:addAutoBetBtnList()
    local listPos = logic.autoList.btnPos()
    for i,v in ipairs(listPos) do
        local btn = self.mm_btn_autoModel:clone()
        btn:setPosition(v)
        btn:show()
        btn:getChildByName("Text_autoCount"):setString(logic.autoList.value[i])
        self.mm_Panel_autoList:addChild(btn)
        btn:onClicked(handler(self,self.onBetBtnClick))
        btn:setTag(i)
        btn:getChildByName("Image_checked"):hide()
        if i == self.m_checkedCount then
            btn:getChildByName("Image_checked"):show()
            self.m_lastBtn = btn
        end
    end
end

function autoBetListLayer:onBetBtnClick(target)
    if self.m_lastBtn then
        self.m_lastBtn:getChildByName("Image_checked"):hide()
    end
    target:getChildByName("Image_checked"):show()
    self.m_lastBtn = target
    local tag = target:getTag()
    self.m_checkedCount = tag
end

function autoBetListLayer:onStartAutoClick()
    local data = {}
    data.autoBallColorLable = self:getBallColorData()
    data.checkedCount = self.m_checkedCount
    self.m_pNode:startAuto(data)
end

function autoBetListLayer:getBallColorData()
    local autoBallColorLable = {}
    for i=1,3 do
        local btn = self["mm_CheckBox_color_"..i]
        if btn:isSelected() == true then
            autoBallColorLable[#autoBallColorLable + 1] = i-1   -- i-1 =  GameLogic.betType 的 绿黄红
        end
    end
    return autoBallColorLable
end

function autoBetListLayer:onCheckBoxClick(target)
    performWithDelay(self,function() 
        local count = 0
        for k=1,3 do
            local btn = self["mm_CheckBox_color_"..k]
            if btn:isSelected() == true then
                count = count + 1
            end
        end
        if count == 0 then
            target:setSelected(true)
        end
    end,0)
end

return autoBetListLayer