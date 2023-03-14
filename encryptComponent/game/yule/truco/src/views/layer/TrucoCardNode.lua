-- truco 牌节点

-- 原始牌大小：Q < J < K < A < 2 < 3
-- 王牌花色大小：方块黑桃红心梅花

local TrucoCardNode = class("TrucoCardNode", cc.Node)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")
local cmd = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.CMD_Game")

function TrucoCardNode:ctor(_cloneCsb, _cardData, _showBack)
    tlog('TrucoCardNode:ctor ', _cardData)
    if not _cloneCsb then
        local itemNode = cc.CSLoader:createNode("UI/TrucoCardNode.csb")
        _cloneCsb = itemNode:getChildByName("poker_bg")
    end
    _cloneCsb:addTo(self)
    _cloneCsb:setPosition(0, 0)
    self.m_cardNode = _cloneCsb

    self:setCardValue(_cardData)
    self.m_cardStatus = nil

	--隐藏扑克背面
    if _showBack == nil then
        _showBack = false
    end
    self:showCardBack(_showBack)
    self:showCardGray(false)
    self:showCardHighLight(false)
    self:showFlipBtnVisible(false)
    self:showMaxEffect(false)
end

--设置卡牌数值
function TrucoCardNode:setCardValue(_cardData)
    tlog('TrucoCardNode:setCardValue ', _cardData)
    if _cardData == nil then
        _cardData = 0
    end
	self.m_cardData = _cardData
	self.m_cardValue = ylAll.POKER_VALUE[_cardData]
	self.m_cardColor = ylAll.CARD_COLOR[_cardData]

	self:updateSprite()
end

function TrucoCardNode:getCardData()
    return self.m_cardData
end

--j,q,k 右下图的位置为(178, 0)
--a-10  右下图的位置为(168, 10)
--更新纹理资源
function TrucoCardNode:updateSprite()
    if self.m_cardData == 0 then
        return
    end

    local tempValue = self.m_cardColor % 2
    local valueImage = self.m_cardNode:getChildByName("poker_value")
    if tempValue == 1 then --黑色(1,3)红色(0,2)
        valueImage:loadTexture(string.format("GUI/poker/truco_black_%d.png", self.m_cardValue))
    else
        valueImage:loadTexture(string.format("GUI/poker/truco_red_%d.png", self.m_cardValue))
    end
    valueImage:setContentSize(valueImage:getVirtualRendererSize())
    --小图资源
    local smallImage = self.m_cardNode:getChildByName("poker_color_small")
    smallImage:loadTexture(string.format("GUI/poker/truco_small_%d.png", self.m_cardColor))
    smallImage:setContentSize(smallImage:getVirtualRendererSize())

    --大图资源
    local bigFile = ""
    local posx, posy = 0, 0
    if self.m_cardValue <= 10 then
        bigFile = string.format("GUI/poker/truco_big_%d.png", self.m_cardColor)
        posx = 168
        posy = 10
    else
        bigFile = string.format("GUI/poker/truco_big_%d_%d.png", self.m_cardValue, tempValue)
        posx = 178
        posy = 0
    end
    local bigColorNode = self.m_cardNode:getChildByName("poker_color_big")
    bigColorNode:loadTexture(bigFile)
    bigColorNode:setContentSize(bigColorNode:getVirtualRendererSize())
    bigColorNode:setPosition(posx, posy)

    local trumpValue = GameLogic:getTrumpCard()
    self:showCardHighLight(self.m_cardValue == trumpValue)
end

--显示扑克背面
function TrucoCardNode:showCardBack(_bBack)
    tlog('TrucoCardNode:showCardBack ', _bBack)
    if not self.m_cardValue then
        _bBack = true
    end
    self.m_showBack = _bBack
    self.m_cardNode:getChildByName("poker_bg_back"):setVisible(_bBack)
end

function TrucoCardNode:getCardIsHide()
    return self.m_showBack
end

--设置牌面置灰
function TrucoCardNode:showCardGray(_bGray)
    self.m_cardNode:getChildByName("poker_bg_gray"):setVisible(_bGray)
end

--设置王牌高亮
function TrucoCardNode:showCardHighLight(_highLight)
    tlog('TrucoCardNode:showCardHighLight ', _highLight)
    local strFile = _highLight and "GUI/poker/truco_poker_front_y.png" or "GUI/poker/truco_poker_front.png"
    self.m_cardNode:loadTexture(strFile)
end

--背面翻转并显示正面动画
--可以使用缩放和skewY的两种方式
function TrucoCardNode:cardBackFrontFlipAction(_showFront, _originScale)
    _originScale = _originScale or 1
    tlog('TrucoCardNode:cardBackFrontFlipAction ', self.m_cardData, _showFront, _originScale)
    local scale1 = cc.ScaleTo:create(0.1, 0.01, _originScale)
    local call = cc.CallFunc:create(function ()
        self:showCardBack(_showFront)
    end)
    local scale2 = cc.ScaleTo:create(0.1, _originScale)
    self:runAction(cc.Sequence:create(scale1, call, scale2))
end

--初始化一些属性设置
--各项数值均可后续修改为可传入
function TrucoCardNode:initCardProperty(_rotation, _skewX, _scale, _back)
    tlog('TrucoCardNode:initCardProperty ', _rotation, _skewX, _scale, _back)
    self:setRotation(_rotation)
    self:setSkewX(_skewX)
    self:setScale(_scale)
    self:showCardBack(_back)
end

function TrucoCardNode:setCurNodeStatus(_status)
    self.m_cardStatus = _status
end

function TrucoCardNode:getCurNodeStatus()
    return self.m_cardStatus
end

function TrucoCardNode:addClickEvent()
    tlog('TrucoCardNode:addClickEvent ', self.m_cardNode.addClick)
    if not self.m_cardNode.addClick then
        self.m_cardNode.addClick = true
        self.m_cardNode:onClicked(function ()
            --出牌
            local _isHide = self.m_showBack and 1 or 0
            G_event:NotifyEventTwo(GameLogic.TRUCO_SEND_CARD, {isHide = _isHide, cardData = self.m_cardData})
        end)
    end
end

function TrucoCardNode:setCardTouchEnabled(_bEnabled)
    self.m_cardNode:setTouchEnabled(_bEnabled)
    if _bEnabled then
        self:addClickEvent()
    end
end

--翻转按钮显示
function TrucoCardNode:showFlipBtnVisible(_bVisible)
    tlog('TrucoCardNode:showFlipBtnVisible ', _bVisible)
    local btn_flip = self.m_cardNode:getChildByName("Button_flip")
    btn_flip:setVisible(_bVisible)
    if _bVisible and not btn_flip.click then
        btn_flip.click = true
        btn_flip:setPressButtonMusicPath("")
        btn_flip:onClicked(function ()
            --点击自己手牌翻转牌按钮，牌翻转时音效
            g_ExternalFun.playSoundEffect("truco_flip_card.mp3")
            self:cardBackFrontFlipAction(not self.m_showBack)
        end)
    end
end

--最大牌光效
function TrucoCardNode:showMaxEffect(_bVisible)
    local max_effect = self.m_cardNode:getChildByName("poker_bg_effect")
    max_effect:setVisible(_bVisible)
end

return TrucoCardNode