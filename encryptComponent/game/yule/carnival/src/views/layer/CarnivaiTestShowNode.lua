-- 嘉年华 测试展示结果值

local CarnivaiTestShowNode = class("CarnivaiTestShowNode", cc.Node)

function CarnivaiTestShowNode:ctor(csbNode)
    tlog('CarnivaiTestShowNode:ctor')
    local layout = csbNode:getChildByName("Panel_test")
    layout:setClippingEnabled(true)
    local _tableView = cc.TableView:create(layout:getContentSize())
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    _tableView:setDelegate()
    _tableView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    layout:addChild(_tableView)
    self.m_tableView = _tableView

    self._itemPre = csbNode:getChildByName("Panel_1")
    self._itemPre:hide()

    self.m_totalArray = {}
end

function CarnivaiTestShowNode:reloadDataShow(_array)
    if not _array then
        _array = {}
    end
    self.m_totalArray = _array
    self.m_tableView:reloadData()
end

function CarnivaiTestShowNode:cellSizeForTable( view, idx )
    return 260, 50
end

function CarnivaiTestShowNode:numberOfCellsInTableView( view )
    return #self.m_totalArray
end

function CarnivaiTestShowNode:tableCellAtIndex( view, idx )
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

    self:updateItem(itemNode, idx + 1)
    return cell
end

--更新item
function CarnivaiTestShowNode:updateItem(itemNode, _index)
    local data = self.m_totalArray[_index]
    itemNode:getChildByName("Text_1"):setString(data.line)
    itemNode:getChildByName("Text_2"):setString(data.nums)
end

return CarnivaiTestShowNode