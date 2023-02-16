

local logic = appdf.req("game.yule.Plinko.src.models.GameLogic")
local betListLayer = class("betListLayer",ccui.Layout)

function betListLayer:ctor(p_node)
    self.m_pNode = p_node
    local csbNode = cc.CSLoader:createNode("UI/betListLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    self:addBtnList(self.m_pNode.m_curBetIndex or 1)
end

function betListLayer:addBtnList(index)
    self.btnList = {}
    local listPos = logic.betList.btnPos()
    for i,v in ipairs(listPos) do
        local btn = self.mm_btn_model:clone()
        btn:setPosition(v)
        btn:show()
        local bet = logic.betList.value[i]*self.m_pNode.m_lCellScore
        local serverKind = G_GameFrame:getServerKind()
        btn:setTitleText(g_format:formatNumber(bet,g_format.fType.standard,serverKind))
        self.mm_Panel_btnList:addChild(btn)
        btn:onClicked(handler(self,self.onBetBtnClick))
        btn:setTag(i)
        if i == index then
            btn:setBright(false)
            self.m_lastBtn = btn
        end
        self.btnList[i] = btn
    end


    local tempHeight = -logic.betList.Vertical * (logic.betList.row - 7)
    local size = self.mm_Image_bg:getContentSize()
    self.mm_Image_bg:setContentSize(cc.size(size.width,size.height + tempHeight))
    self.mm_Panel_btnList:setPositionY(self.mm_Panel_btnList:getPositionY()+tempHeight)
    
end

function betListLayer:onBetBtnClick(target)
    if self.m_lastBtn then
        self.m_lastBtn:setBright(true)
    end
    self.m_lastBtn = target
    target:setBright(false)
    local tag = target:getTag()
    self.m_pNode:setBet(tag)
end

function betListLayer:onSelectBtn(index)
    if self.m_lastBtn then
        self.m_lastBtn:setBright(true)
    end
    self.m_lastBtn = self.btnList[index]
    self.m_lastBtn:setBright(false)
end

return betListLayer