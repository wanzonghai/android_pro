-- double 游戏记录界面

local GameDialogBase = appdf.req("game.yule.crash.src.views.layer.GameDialogBase")
local GameHistoryLayer = class("GameHistoryLayer", GameDialogBase)

function GameHistoryLayer:ctor(_historyInfo, _curStamp)
    tlog('GameHistoryLayer:ctor')
    GameHistoryLayer.super.ctor(self)
    tdump(_historyInfo, "_historyInfo", 10)
	self.m_historyInfo = _historyInfo

	local csbNode = g_ExternalFun.loadCSB("UI/GameHistoryLayer.csb", self)
	self.m_spBg = csbNode:getChildByName("Image_3")
	--记录列表
	local layout = self.m_spBg:getChildByName("Panel_1")
	layout:setClippingEnabled(true)
	local _tableView = cc.TableView:create(layout:getContentSize())
	_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	--下面的不设置默认是从最大的index开始
    -- _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
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
    self._itemPre:setTouchEnabled(false)
    -- self._itemPre:setTouchEnabled(true)
    -- self._itemPre:addClickEventListener(handler(self, self.onClickItem))

    self.m_tableView:reloadData()
end

function GameHistoryLayer:cellSizeForTable( view, idx )
	return 1175, 90
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

    -- itemNode:setTouchEnabled(false)
    -- itemNode:setTouchEnabled(true)
    -- itemNode:setSwallowTouches(false)
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
	local text_num = itemNode:getChildByName("Text_num")
	text_num:setString(g_ExternalFun.formatNumWithPeriod(data.openNum, "X"))
	if data.openNum >= 1000 then
		text_num:setScale(0.9)
	else
		text_num:setScale(1)
	end
	itemNode:getChildByName("Text_seed"):setString(string.format("%d  jogadores ganharam", data.winCount))

	--todo
	local image_2 = itemNode:getChildByName("Image_2")
	local strFile = "GUI/crash_szdk1.png"
	local color = cc.c4b(143, 124, 197, 255)
	if data.openNum >= 2 then
		strFile = "GUI/crash_szdk2.png"
		color = cc.c4b(98, 165, 103, 255)
	end
	text_num:setTextColor(color)
	image_2:loadTexture(strFile)

	-- itemNode.__ITEM_DATA__ = data
end

function GameHistoryLayer:onClickItem(_sender)
    local endPos = _sender:getTouchEndPosition()
    local beganPos = _sender:getTouchBeganPosition()
    if math.abs(endPos.y - beganPos.y) > 1 then
        return
    end

    local itemData = _sender.__ITEM_DATA__
    if itemData and type(itemData) == "table" then
    	self:getParent():getGameDetailRecordReq(itemData.itemIndex, 0, 10)
    end
end

return GameHistoryLayer