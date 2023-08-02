-- truco游戏 托管节点

local TrucoTrusteeNode = class("TrucoTrusteeNode", cc.Node)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")
local Node_Distance = 290

local btn_Status = {
	status_truco = 1, 			--正常truco
	status_answer_truco = 2,	--应答truco
	status_continue = 3,		--11分临界应答等待
}

function TrucoTrusteeNode:ctor()
	tlog('TrucoTrusteeNode:ctor')
    local csbNode = cc.CSLoader:createNode("UI/TrucoTrusteeNode.csb")
    csbNode:addTo(self)

    local bgImage = csbNode:getChildByName("TrusteeBg")
    bgImage:onClicked(function ()
    	--看是同取消托管还是不做处理
    end)

    self.m_tipText = bgImage:getChildByName("Text_1")
    self.m_tipText._nums_ = 0
	local btn = bgImage:getChildByName("Button_cancel")
	btn:onClicked(handler(self, self.onButtonClickEvent))

    -- self:setTrusteeNodeVisible(false)
end

function TrucoTrusteeNode:setTrusteeNodeVisible(_bVisible)
	self:setVisible(_bVisible)
    self.m_tipText:stopAllActions()
    self.m_tipText._nums_ = 0
    if _bVisible then
    	self:showTrusteePointAction()
    end
    GameLogic:setIsTrusteeStatus(_bVisible)
end

function TrucoTrusteeNode:onButtonClickEvent(_sender)
	tlog('TrucoTrusteeNode:onButtonClickEvent ')
    G_event:NotifyEventTwo(GameLogic.TRUCO_TRUSTEE_EVENT, {_type = 0})
end

--提示文字动画
function TrucoTrusteeNode:showTrusteePointAction()
    self.m_tipText._nums_ = self.m_tipText._nums_ + 1
    if self.m_tipText._nums_ > 4 then
        self.m_tipText._nums_ = 1
    end
    local pointStr = ""
    for i = 1, self.m_tipText._nums_ do
        pointStr = pointStr .. "."
    end
    pointStr = "Você está na hospedagem do sistema " .. pointStr
    self.m_tipText:setString(pointStr)
    self.m_tipText:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
        self:showTrusteePointAction()
    end)))
end

return TrucoTrusteeNode