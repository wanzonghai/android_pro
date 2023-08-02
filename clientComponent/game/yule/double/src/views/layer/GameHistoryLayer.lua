-- double 游戏记录界面

local GameDialogBase = appdf.req("game.yule.double.src.views.layer.GameDialogBase")
local GameHistoryLayer = class("GameHistoryLayer", GameDialogBase)

function GameHistoryLayer:ctor(_historyInfo, _curStamp)
    tlog('GameHistoryLayer:ctor')
    GameHistoryLayer.super.ctor(self)
	self.m_historyInfo = _historyInfo

	local csbNode = g_ExternalFun.loadCSB("UI/GameHistoryLayer.csb", self, false)
	self.m_spBg = csbNode:getChildByName("Sprite_bg")
	--记录列表
	local layout = self.m_spBg:getChildByName("Panel_1")
	layout:setClippingEnabled(true)
	local _tableView = cc.TableView:create(layout:getContentSize())
	_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	_tableView:setDelegate()
	_tableView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	_tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	_tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	layout:addChild(_tableView)
	self.m_tableView = _tableView

	--关闭按钮
	local btn = self.m_spBg:getChildByName("Button_1")
	btn:addClickEventListener(function ()
		self:removeFromParent()
	end)

	self.m_curTimeStamp = _curStamp

    self._itemPre = self.m_spBg:getChildByName("Panel_item")
    self._itemPre:hide()
    self._itemPre:setTouchEnabled(true)
    self._itemPre:addClickEventListener(handler(self, self.onClickItem))

    self.m_tableView:reloadData()
end

function GameHistoryLayer:cellSizeForTable( view, idx )
	return 1130, 90
end

function GameHistoryLayer:numberOfCellsInTableView( view )
	if nil == self.m_historyInfo then
		return 0
	else
		return #self.m_historyInfo
	end
end

function GameHistoryLayer:tableCellAtIndex( view, idx )
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end

    local itemNode = cell:getChildByName("ITEM_NODE")
    if not itemNode then
        itemNode = self._itemPre:clone()
        itemNode:setPosition(0, 0)
        itemNode:setName("ITEM_NODE")
        itemNode:setVisible(true)
        cell:addChild(itemNode)
    end

    itemNode:setTouchEnabled(false)
    itemNode:setTouchEnabled(true)
    itemNode:setSwallowTouches(false)
    self:updateItem(itemNode, idx + 1)
    return cell
end

--更新item
function GameHistoryLayer:updateItem(itemNode, _index)
	local data = self.m_historyInfo[_index]
	local seconds = self.m_curTimeStamp - data.openTimer
	if seconds < 0 then
		seconds = 1
	end
	local strTime = ""
	if seconds < 60 then
		strTime = string.format("%d segunda atrás", seconds)
	else
		local minutes = math.floor(seconds / 60)
		strTime = string.format("%d minutos atrás", minutes)
	end
	itemNode:getChildByName("Text_time"):setString(strTime)
	local strFile = ""
	if data.openNum == 0 then
		strFile = "GUI/blaze_item_1.png"
	elseif data.openNum < 8 then
		strFile = "GUI/blaze_item_2.png"
	else
		strFile = "GUI/blaze_item_3.png"
	end
	itemNode:getChildByName("Image_1"):loadTexture(strFile)
	local seedStr = string.sub(data.cbSeverSeed, 1, 38) .. "..."
	local pSeed = itemNode:getChildByName("Text_seed")
	pSeed:setString(seedStr)
	-- local pSize = pSeed:getContentSize()
	-- itemNode:getChildByName("Panel_2"):setContentSize(cc.size(pSize.width,3))
	itemNode.__ITEM_DATA__ = data
end

function GameHistoryLayer:onClickItem(_sender)
    local endPos = _sender:getTouchEndPosition()
    local beganPos = _sender:getTouchBeganPosition()
    if math.abs(endPos.y - beganPos.y) > 1 then
        return
    end
    local nodePos = _sender:convertToNodeSpace(beganPos)

    local itemData = _sender.__ITEM_DATA__
    if itemData and type(itemData) == "table" then
    	self:getParent():getGameDetailRecordReq(itemData.itemIndex, 0, 10)
    end
end

return GameHistoryLayer