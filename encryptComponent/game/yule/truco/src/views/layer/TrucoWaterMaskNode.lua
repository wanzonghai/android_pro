-- truco 水印节点

local TrucoWaterMaskNode = class("TrucoWaterMaskNode", cc.Node)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")
local cmd = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.CMD_Game")

function TrucoWaterMaskNode:ctor(_csbNode)
    tlog('TrucoWaterMaskNode:ctor')
    g_ExternalFun.registerNodeEvent(self)
    self.m_csbNode = _csbNode
    self:setMaskNodeVisible(false)
    G_event:AddNotifyEventTwo(self, GameLogic.TRUCO_SHOW_WATERMASK, handler(self,self.flushWaterMaskShow))
end

function TrucoWaterMaskNode:onExit()
    G_event:RemoveNotifyEventTwo(self, GameLogic.TRUCO_SHOW_WATERMASK)
end

function TrucoWaterMaskNode:setMaskNodeVisible(_bVisible)
    -- self.m_csbNode:setVisible(_bVisible)
    for i, v in ipairs(self.m_csbNode:getChildren()) do
        if v:getName() == "Image_1" then
            v:setVisible(true)
        else
            v:setVisible(_bVisible)
        end
    end
end

function TrucoWaterMaskNode:flushWaterMaskShow()
    tlog('TrucoWaterMaskNode:flushWaterMaskShow')
    self:setMaskNodeVisible(true)
    --王牌牌值
    local trumpValue = GameLogic:getTrumpCard()
    local cardList = {}
    for i, v in ipairs(GameLogic.CARD_SORT) do
        if v ~= trumpValue then
            table.insert(cardList, v)
        end
    end
    for i = 1, 4 do
        table.insert(cardList, trumpValue)
    end
    for i = 1, 9 do
        local image_node = self.m_csbNode:getChildByName(string.format("Image_down_%d", i))
        local effect_node = self.m_csbNode:getChildByName(string.format("truco_wm_%d", i))
        local cardValue = cardList[i]
        if cardValue then
            local path = string.format("GUI/watermask/truco_wm_%d.png", cardValue)
            image_node:loadTexture(path)
            image_node:setContentSize(image_node:getVirtualRendererSize())
            effect_node:setTexture(path)
            effect_node:setBlendFunc(cc.blendFunc(1, 1))
        else
            tlog("card has no value, somewhere has problem")
        end
    end

    self.m_csbNode:stopAllActions()
    local csbAniTimeline = cc.CSLoader:createTimeline("UI/TrucoWaterMaskNode.csb")
    csbAniTimeline:gotoFrameAndPlay(0, false)
    self.m_csbNode:runAction(csbAniTimeline)
end

return TrucoWaterMaskNode