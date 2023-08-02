local GameItem = class("GameItem", cc.Node)
local cmd = "game.yule.bonanza.src.models.CMD_Game"
local GameLogic = appdf.req("game.yule.bonanza.src.models.GameLogic")

GameItem.Texture_fruit = 
{
    "game/yule/bonanza/res/GUI/shuiguo/friut_icon_1.png",
    "game/yule/bonanza/res/GUI/shuiguo/friut_icon_2.png",
    "game/yule/bonanza/res/GUI/shuiguo/friut_icon_3.png",
    "game/yule/bonanza/res/GUI/shuiguo/friut_icon_4.png",
    "game/yule/bonanza/res/GUI/shuiguo/friut_icon_5.png",
    "game/yule/bonanza/res/GUI/shuiguo/friut_icon_6.png",
    "game/yule/bonanza/res/GUI/shuiguo/friut_icon_7.png",
    "game/yule/bonanza/res/GUI/shuiguo/friut_icon_8.png",
    "game/yule/bonanza/res/GUI/shuiguo/friut_icon_9.png",
    "game/yule/bonanza/res/GUI/shuiguo/friut_icon_10.png",
    "game/yule/bonanza/res/GUI/shuiguo/friut_icon_11.png",
}

function GameItem:ctor()
    self.m_aniNodeArray = {}
    self.m_animationArray = {}
    self.m_nType = 0
end

function GameItem:onExit()
    for k, v in pairs(self.m_animationArray) do
        if v then
            g_ExternalFun.SAFE_RELEASE(v)
            v = nil
        end
    end
end

function GameItem:setItemType(nType)
    if nType < GameLogic.ITEM_LIST.ITEM_ICON0 then
        nType = GameLogic.ITEM_LIST.ITEM_ICON0
    end
	self.m_nType = nType
    if nType > GameLogic.ITEM_LIST.ITEM_BOMB then
        nType = GameLogic.ITEM_LIST.ITEM_BOMB
    end
    local showIndex = self:getActNodeIndex()
    self:showCurCsbNode(showIndex)
    tlog('GameItem:setItemType ', self.m_nType, nType, showIndex)
    local image_1 = self.m_aniNodeArray[showIndex]:getChildByName("Image_1")
    if nType <= GameLogic.ITEM_LIST.ITEM_ICON8 then
        image_1:loadTexture(GameItem.Texture_fruit[nType + 1],1)
        image_1:setContentSize(image_1:getVirtualRendererSize())
    elseif nType == GameLogic.ITEM_LIST.ITEM_BOMB then
        local _labelChar = image_1:getChildByName("AtlasLabel_1")
        _labelChar:setString(math.floor(self.m_nType / GameLogic.ITEM_LIST.ITEM_BOMB))
        local image_x = _labelChar:getChildByName("Image_x")
        image_x:setPosition(_labelChar:getContentSize().width * 1.03, _labelChar:getContentSize().height * 0.39)
    end
end

function GameItem:getItemType()
	return self.m_nType
end

function GameItem:setWinEffect()
    tlog('GameItem:setWinEffect ', self.m_nType)
    local nType = self.m_nType > GameLogic.ITEM_LIST.ITEM_BOMB and GameLogic.ITEM_LIST.ITEM_BOMB or self.m_nType
    if nType == GameLogic.ITEM_LIST.ITEM_BOMB then
        --炸弹的效果最后统一处理
        return
    end
    local loop = false
    if nType == GameLogic.ITEM_LIST.ITEM_FREE then
        loop = true
    end
    self:showItemEffect(loop)
end

function GameItem:showLastBombEffect(_parentNode)
    local showIndex = self:showItemEffect(false)
    local image_1 = self.m_aniNodeArray[showIndex]:getChildByName("Image_1")
    local _labelChar = image_1:getChildByName("AtlasLabel_1")
    if not _labelChar then
        tlog("GameItem:showLastBombEffect not have _labelChar")
        return
    end
    local newLabel = _labelChar:clone()
    newLabel:setString(math.floor(self.m_nType / GameLogic.ITEM_LIST.ITEM_BOMB))
    local image_x = newLabel:getChildByName("Image_x")
    image_x:setPosition(newLabel:getContentSize().width * 1.03, newLabel:getContentSize().height * 0.39)
    newLabel:addTo(_parentNode)
    local curPos = cc.p(_labelChar:getPosition())
    local position = _parentNode:convertToNodeSpace(_labelChar:getParent():convertToWorldSpace(curPos))
    newLabel:setPosition(position)
    local scale1 = cc.ScaleTo:create(0.35, 1.2)
    local scale2 = cc.ScaleTo:create(0.35, 0.8)
    local moveto = cc.MoveTo:create(0.7, _parentNode.dstPos)
    local seque1 = cc.Sequence:create(scale1, scale2)
    local spawn = cc.Spawn:create(seque1, moveto)
    newLabel:runAction(cc.Sequence:create(spawn, cc.CallFunc:create( function()
        newLabel:removeFromParent()
    end)))
end

function GameItem:showItemEffect(_loop)
    local showIndex = self:getActNodeIndex()
    tlog('GameItem:showItemEffect ', showIndex, _loop, self.m_nType)
    self.m_aniNodeArray[showIndex]:stopAllActions()
    self.m_animationArray[showIndex]:gotoFrameAndPlay(40, _loop)
    self.m_aniNodeArray[showIndex]:runAction(self.m_animationArray[showIndex])
    return showIndex
end

function GameItem:runRotate(_time)
    -- tlog("GameItem:runRotate ", _time)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(_time), cc.CallFunc:create(function ()
        local showIndex = self:getActNodeIndex()
        self.m_aniNodeArray[showIndex]:stopAllActions()
        self.m_animationArray[showIndex]:gotoFrameAndPlay(0, 25, false)
        self.m_aniNodeArray[showIndex]:runAction(self.m_animationArray[showIndex])
    end)))
end

function GameItem:getActNodeIndex()
    local showIndex = 0
    if self.m_nType <= GameLogic.ITEM_LIST.ITEM_ICON8 then
        showIndex = 1
    elseif self.m_nType == GameLogic.ITEM_LIST.ITEM_FREE then
        showIndex = 2
    else
        showIndex = 3
    end
    return showIndex
end

function GameItem:showCurCsbNode(showIndex)
    -- tdump(self.m_aniNodeArray, "self.m_aniNodeArray", 10)
    for k, v in pairs(self.m_aniNodeArray) do
        if v then
            v:setVisible(false)
        end
    end
    if not self.m_aniNodeArray[showIndex] then
        local csbFile = string.format("UI/Node_itemAct_%d.csb", showIndex)
        local _actNode = cc.CSLoader:createNode(csbFile)
        self:addChild(_actNode)
        self.m_aniNodeArray[showIndex] = _actNode

        local _actAnimation = cc.CSLoader:createTimeline(csbFile)
        g_ExternalFun.SAFE_RETAIN(_actAnimation)
        self.m_animationArray[showIndex] = _actAnimation
    end
    self.m_aniNodeArray[showIndex]:setVisible(true)
    self.m_aniNodeArray[showIndex]:stopAllActions()
    self.m_aniNodeArray[showIndex]:runAction(self.m_animationArray[showIndex])
    self.m_animationArray[showIndex]:gotoFrameAndPause(0)
end

return GameItem