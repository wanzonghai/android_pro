-- double游戏 三个颜色的开奖结果节点

local DoubleItemNode = class("DoubleItemNode", cc.Node)

-- _pngIndex 该颜色对应的图片的序号
-- _index 小球上的数字
-- color 展示的颜色
local Index_To_Color = {
	{_index = 0, color = "red", _pngIndex = 1},
	{_index = 1, color = "green", _pngIndex = 2},
	{_index = 2, color = "green", _pngIndex = 2},
	{_index = 3, color = "green", _pngIndex = 2},
	{_index = 4, color = "green", _pngIndex = 2},
	{_index = 5, color = "green", _pngIndex = 2},
	{_index = 6, color = "green", _pngIndex = 2},
	{_index = 7, color = "green", _pngIndex = 2},
	{_index = 8, color = "purple", _pngIndex = 3},
	{_index = 9, color = "purple", _pngIndex = 3},
	{_index = 10, color = "purple", _pngIndex = 3},
	{_index = 11, color = "purple", _pngIndex = 3},
	{_index = 12, color = "purple", _pngIndex = 3},
	{_index = 13, color = "purple", _pngIndex = 3},
	{_index = 14, color = "purple", _pngIndex = 3},
}

-- _index 显示的数字
function DoubleItemNode:ctor(_index)
	tlog('DoubleItemNode:ctor ', _index)
    local itemNode = cc.CSLoader:createNode("UI/DoubleItemNode.csb");
  	itemNode:addTo(self)
    self.m_itemNode = itemNode
	local image_1 = self.m_itemNode:getChildByName("Image_1")
	self.m_FlagNew = image_1:getChildByName("FlagNew")
	self.IndexNumber = _index
    self:changeItemColor(_index)
end

function DoubleItemNode:getNodeSize()
	return self.m_itemNode:getChildByName("Image_1"):getContentSize()
end

function DoubleItemNode:changeItemColor(_index)
	local image_1 = self.m_itemNode:getChildByName("Image_1")
	local text_1 = image_1:getChildByName("Text_1")
	for k, v in pairs(Index_To_Color) do
		if v._index == _index then
			image_1:loadTexture(string.format("GUI/blaze_item_%d.png", v._pngIndex))
			break
		end
	end
	if _index == 0 then
		text_1:setVisible(false)
	else
		text_1:setVisible(true)
		-- text_1:setString(_index)
		if _index >= 10 then
			text_1:setPositionX(52)
		else
			text_1:setPositionX(54)
		end
		if _index <= 7 then
			text_1:setProperty(_index, "GUI/num_pic/double_num_green.png", 26, 45, "0")
		else
			text_1:setProperty(_index, "GUI/num_pic/double_num_purple.png", 26, 45, "0")
		end
	end
end

function DoubleItemNode:registerClickFunc(pParent)
	local image_1 = self.m_itemNode:getChildByName("Image_1")	
	image_1:setTouchEnabled(true)
	image_1:addClickEventListener(function()
		if pParent and pParent.onHistoryItemClick then
			local pTag = self:getTag()
			pParent:onHistoryItemClick(pTag)
		end
	end)
end

function DoubleItemNode:getCurrentIndex()
	return self.IndexNumber
end

function DoubleItemNode:showFlagNew(pStatus)
	self.m_FlagNew:setVisible(pStatus)
end

return DoubleItemNode