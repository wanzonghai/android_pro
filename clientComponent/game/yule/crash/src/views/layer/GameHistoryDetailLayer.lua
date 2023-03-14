-- double 游戏记录详细界面

local GameDialogBase = appdf.req("game.yule.crash.src.views.layer.GameDialogBase")
local GameHistoryDetailLayer = class("GameHistoryDetailLayer", GameDialogBase)
local CrashItemNode = appdf.req("game.yule.crash.src.views.layer.CrashItemNode")

function GameHistoryDetailLayer:ctor()
    tlog('GameHistoryDetailLayer:ctor')
    GameHistoryDetailLayer.super.ctor(self)

	self.m_historyInfo = {}
	self.m_curIndex = 0
	self.m_totalIndex = 0
	self.m_itemIndex = 0

	local csbNode = g_ExternalFun.loadCSB("UI/GameHistoryDetailLayer.csb", self)
	self.m_spBg = csbNode:getChildByName("Sprite_bg")
	self.m_csbNode = csbNode
	local layout = csbNode:getChildByName("Panel_1")
	layout:setClippingEnabled(true)
	local _tableView = cc.TableView:create(layout:getContentSize())
	_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	_tableView:setDelegate()
	_tableView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	_tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	_tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(handler(self, self.scrollViewDidScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
	layout:addChild(_tableView)
	self.m_tableView = _tableView

	--关闭按钮
	local btn = csbNode:getChildByName("Button_1")
	btn:addClickEventListener(function ()
		self:removeFromParent()
	end)

    self._itemPre = csbNode:getChildByName("Panel_item")
    self._itemPre:hide()
    self._itemPre:setTouchEnabled(false)
end

function GameHistoryDetailLayer:initWithData(_cmdData)
	for i, v in ipairs(_cmdData.game_record) do
		table.insert(self.m_historyInfo, v)
	end
	if self.m_curIndex == 0 then
		--第一次进入
		self.m_totalIndex = _cmdData.totalcount
		self.m_itemIndex = _cmdData.itemIndex
		local time = os.date("%Y-%m-%d %H:%M:%S", _cmdData.openTimer)
		self.m_csbNode:getChildByName("Text_tip"):setString(string.format("played on %s", time))
		-- self:initTopResultShow(_cmdData.openNum)
	end
	self.m_enableReq = true
	self.m_curIndex = self.m_curIndex + 1

    local oldOffset = self.m_tableView:getContentOffset()
    local oldSize = self.m_tableView:getContentSize()
    self.m_tableView:reloadData()
    tlog("updateTableview checkCoinMode", oldOffset.y ,oldSize.height )
    local newSize = self.m_tableView:getContentSize()
    local newOffsetY = oldOffset.y + -1*(newSize.height - oldSize.height)
    self.m_tableView:setContentOffset(cc.p(oldOffset.x, newOffsetY))
end

--单元滚动回调
function GameHistoryDetailLayer:scrollViewDidScroll(view)
    local offset = view:getContentOffset()
    local contentSize = view:getContentSize()
    local viewSize = view:getViewSize()

    local endDiff = viewSize.height - contentSize.height
    endDiff = math.max(endDiff, 0)
    local reached = false
    if offset.y <= endDiff + 100 and offset.y >= endDiff then
        reached = true
    end

    if contentSize.height <= 0 then
        reached = true
    end
    --内容小于列表大小不用请求
    if contentSize.height <= viewSize.height then
        reached = false
    end
    --拖动到底了(请求下一页)
    if reached and self.m_enableReq then
        self.m_enableReq = false
        if self.m_curIndex <= self.m_totalIndex then
	    	self:getParent():getGameDetailRecordReq(self.m_itemIndex, self.m_curIndex, 10)
        end
    end
end

function GameHistoryDetailLayer:cellSizeForTable( view, idx )
	return 946, 90
end

function GameHistoryDetailLayer:numberOfCellsInTableView( view )
	if nil == self.m_historyInfo then
		return 0
	else
		return #self.m_historyInfo
	end
end

function GameHistoryDetailLayer:tableCellAtIndex( view, idx )
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end

    local itemNode = cell:getChildByName("ITEM_NODE")
    if not itemNode then
        itemNode = self._itemPre:clone()
        itemNode:setPosition(473, 0)
        itemNode:setName("ITEM_NODE")
        itemNode:setVisible(true)
        cell:addChild(itemNode)
    end
    self:updateItem(itemNode, idx + 1)
    return cell
end

--更新item
function GameHistoryDetailLayer:updateItem(itemNode, _index)
	local data = self.m_historyInfo[_index]
	itemNode:getChildByName("Text_name"):setString(data.userName)
	itemNode:getChildByName("Text_rate"):setString(data.betCrash)
	itemNode:getChildByName("Text_bet"):setString(data.betScore)
    local betWinNum = data.betWinScore
    if betWinNum <= 0 then
        betWinNum = "-"
    end
	itemNode:getChildByName("Text_seed"):setString(betWinNum)
end

function GameHistoryDetailLayer:initTopResultShow(_openNum)
	tlog('GameHistoryDetailLayer:initTopResultShow ', _openNum)
	local sortArray = {13, 3, 12, 4, 0, 11, 5, 10, 6, 9, 7, 8, 1, 14, 2} --滚动区域小球的排列顺序
	local panel_10 = self.m_csbNode:getChildByName("Panel_10")
	local size = panel_10:getContentSize()

    local curIndex = 0
    for i, v in ipairs(sortArray) do
    	if v == _openNum then
    		curIndex = i
    		break
    	end
    end
    tlog('curIndex is ', curIndex)
    local newIndex1 = ((curIndex - 2) + 15) % 15
    if newIndex1 == 0 then
    	newIndex1 = 15
    end
    local newIndex2 = ((curIndex - 1) + 15) % 15
    if newIndex2 == 0 then
    	newIndex2 = 15
    end
    local newIndex3 = ((curIndex + 1)) % 15
    if newIndex3 == 0 then
    	newIndex3 = 15
    end
    local newIndex4 = ((curIndex + 2)) % 15
    if newIndex4 == 0 then
    	newIndex4 = 15
    end
    local newItem = {newIndex1, newIndex2, curIndex, newIndex3, newIndex4}
    tdump(newItem, "newItem", 10)
    for i, v in ipairs(newItem) do
		local itemNode = CrashItemNode:create(sortArray[v])
		itemNode:setPosition(size.width * 0.5 + (i - 3) * 165, size.height * 0.5)
		itemNode:setScale(0.7)
		panel_10:addChild(itemNode)
    end
end

return GameHistoryDetailLayer