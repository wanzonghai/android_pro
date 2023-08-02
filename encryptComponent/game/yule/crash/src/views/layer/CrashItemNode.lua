-- crash游戏 记录结果节点

local CrashItemNode = class("CrashItemNode", cc.Node)

-- _index 显示的数字
function CrashItemNode:ctor(_index)
	tlog('CrashItemNode:ctor ', _index)
    local itemNode = cc.CSLoader:createNode("UI/crash_item_node.csb");
  	itemNode:addTo(self)
    self.m_itemNode = itemNode
	local image_1 = self.m_itemNode:getChildByName("Image_1")
	self.m_FlagNew = image_1:getChildByName("FlagNew")
    self:changeItemColor(_index)
end

function CrashItemNode:getNodeSize()
	return self.m_itemNode:getChildByName("Image_1"):getContentSize()
end

function CrashItemNode:changeItemColor(_index)
	local image_1 = self.m_itemNode:getChildByName("Image_1")
	local strFile = "GUI/crash_szdk1.png"
	local color = cc.c4b(120, 132, 208, 255)
	if _index >= 2 then
		strFile = "GUI/crash_szdk2.png"
		color = cc.c4b(128, 183, 136, 255)
	end
	image_1:loadTexture(strFile)
	local text_1 = image_1:getChildByName("Text_1")
	text_1:setString(g_ExternalFun.formatNumWithPeriod(_index, "X"))
	text_1:setTextColor(color)
	-- if _index >= 1000 then
	-- 	text_1:setScale(0.9)
	-- else
	-- 	text_1:setScale(1)
	-- end
end

function CrashItemNode:showFlagNew(pStatus)
	self.m_FlagNew:setVisible(pStatus)
end

return CrashItemNode