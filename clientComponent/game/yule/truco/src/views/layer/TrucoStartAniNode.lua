-- truco游戏 开始动画

local TrucoDialogBase = appdf.req("game.yule.truco.src.views.layer.TrucoDialogBase")
local TrucoStartAniNode = class("TrucoStartAniNode", TrucoDialogBase)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")
local TrucoPlayerNode = appdf.req(appdf.GAME_SRC .. "yule.truco.src.views.layer.TrucoPlayerNode")

function TrucoStartAniNode:ctor(_playerInfo, _playerItem, _callBack)
	tlog('TrucoStartAniNode:ctor')
    TrucoStartAniNode.super.ctor(self)
	-- g_ExternalFun.registerNodeEvent(self)
    local csbNode = cc.CSLoader:createNode("UI/Node_vsdonghua.csb")
    csbNode:addTo(self)

    --从左到右，0，2，1，4位置
    local playerNodeArray = {}
    local playerParentNodeArr = {}
    local leftParentNode = csbNode:getChildByName("VSdonghua_0012_blue_8")
    local rightParentNode = csbNode:getChildByName("VSdonghua_0013_red_7")
    table.insert(playerParentNodeArr, leftParentNode:getChildByName("Panel_1"))
    table.insert(playerParentNodeArr, rightParentNode:getChildByName("Panel_1_1"))
    table.insert(playerParentNodeArr, leftParentNode:getChildByName("Panel_1_0"))
    table.insert(playerParentNodeArr, rightParentNode:getChildByName("Panel_1_2"))

    for i, v in ipairs(_playerInfo) do
        local pos_index = GameLogic:getPositionByChairId(v.wChairID) + 1
        local parentNode = playerParentNodeArr[pos_index]
        parentNode:removeAllChildren()
        local curPlayerNode = TrucoPlayerNode:create(_playerItem:clone():show())
        curPlayerNode:addTo(parentNode)
        curPlayerNode:setPosition(parentNode:getContentSize().width * 0.5, parentNode:getContentSize().height * 0.5)
        playerNodeArray[pos_index] = curPlayerNode
        curPlayerNode:setVisible(true)
        curPlayerNode:reFlushNodeShow(v, false)
    end

    self:setTouchEndEnabled(false)

    local csbAniTimeline = cc.CSLoader:createTimeline("UI/Node_vsdonghua.csb")
    csbAniTimeline:gotoFrameAndPlay(0, false)
    csbNode:runAction(csbAniTimeline)
    csbAniTimeline:setLastFrameCallFunc(function()
        tlog("TrucoStartAniNode act over")
        local posArr = {}
        for i, v in ipairs(playerNodeArray) do
            local pos = v:getParent():convertToWorldSpace(cc.p(v:getPosition()))
            table.insert(posArr, pos)
        end
        if _callBack then
            _callBack(posArr)
        end
        self:removeFromParent()
    end)
    --vs对战标音效
    g_ExternalFun.playSoundEffect("truco_start_vs.mp3")
end

return TrucoStartAniNode