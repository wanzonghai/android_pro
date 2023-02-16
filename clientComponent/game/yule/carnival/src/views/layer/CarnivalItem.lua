-- 嘉年华 物品节点
local CarnivalItem = class("CarnivalItem", cc.Sprite)
local GameLogic = appdf.req("game.yule.carnival.src.models.GameLogic")

function CarnivalItem:ctor(_index)
    -- tlog('CarnivalItem:ctor')
    self.m_realType = _index    --真实类型
    self.m_maskType = _index    --面具变身后的类型,非面具的话同realType
    self.m_posIndex = 0         --旋转最后用于记录所在位置序号
    self:initWithSpriteFrameName(string.format("jnh_icon_%d.png", _index + 1))
    self:setScale(1.3)
end

function CarnivalItem:setNormalItemShow(_nType)
    self.m_realType = _nType
    self.m_maskType = _nType
    self:setSpriteFrame(string.format("jnh_icon_%d.png", _nType + 1))
end

function CarnivalItem:setMaskedItemShow(_type)
    self.m_maskType = _type
    self:setSpriteFrame(string.format("jnh_icon_%d.png", _type + 1))
    self:setVisible(false)
end

function CarnivalItem:getItemType()
	return self.m_realType
end

function CarnivalItem:getMaskType()
    return self.m_maskType
end

function CarnivalItem:recoveryMaskedItem()
    self:setVisible(true)
    if self.m_realType ~= self.m_maskType then
        self:setSpriteFrame(string.format("jnh_icon_%d.png", self.m_realType + 1))
    end
end

function CarnivalItem:setPosIndex(_index)
    -- tlog('CarnivalItem:setPosIndex ', _index)
    self.m_posIndex = _index
end

function CarnivalItem:getPosIndex()
    return self.m_posIndex
end

return CarnivalItem