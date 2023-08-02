-- 提现记录界面
local CashOutHistoryLayer = class("CashOutHistoryLayer", function(args)
    local CashOutHistoryLayer =  display.newLayer()
    return CashOutHistoryLayer
end)

function CashOutHistoryLayer:ctor()
    tlog('CashOutHistoryLayer:ctor')
    --CashOutHistoryLayer.super.ctor(self)

	self.m_historyInfo = {}
	self.m_curIndex = 0
	self.m_totalIndex = 0

	local csbNode = g_ExternalFun.loadCSB("cashOut/OutHistoryLayer.csb", self)
	self.m_spBg = csbNode:getChildByName("Sprite_bg")
	self.m_csbNode = csbNode
	local layout = csbNode:getChildByName("Panel_1")
	layout:setClippingEnabled(true)
    self.bgSpine = sp.SkeletonAnimation:create("client/res/cashOut/spine/tixianjilu.json","client/res/cashOut/spine/tixianjilu.atlas", 1)
    self.bgSpine:addTo(self.m_spBg)
    self.bgSpine:setPosition(0, 0)
    self.bgSpine:setAnimation(0, "daiji", true)

    csbNode:getChildByName("heibeijing"):enableClick(function()
        self:removeFromParent()
    end)

	local _tableView = cc.TableView:create(layout:getContentSize())
	_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
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

    G_event:AddNotifyEvent(G_eventDef.NET_CASHOUT_HISTORY_RESULT,handler(self,self.initWithData))
    G_ServerMgr:C2S_GetWithdrawRecord(10, 1)
end
function CashOutHistoryLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_CASHOUT_HISTORY_RESULT)   
end
function CashOutHistoryLayer:initWithData(_cmdData)
    dump(_cmdData, "CashOutHistoryLayer:initWithData")
	for i, v in ipairs(_cmdData.historyList) do
		table.insert(self.m_historyInfo, v)
	end
	if self.m_curIndex == 0 then
		--第一次进入
		self.m_totalIndex = _cmdData.dwPageCount
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
function CashOutHistoryLayer:scrollViewDidScroll(view)
    local offset = view:getContentOffset()
    local contentSize = view:getContentSize()
    local viewSize = view:getViewSize()

    local endDiff = viewSize.height - contentSize.height
    endDiff = math.max(endDiff, 0)
    local reached = false
    --print("adsfjoasdjfoasdfj222", offset.y, endDiff, contentSize.height, viewSize.height, self.m_enableReq)
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
        if self.m_curIndex < self.m_totalIndex then
            G_ServerMgr:C2S_GetWithdrawRecord(10, self.m_curIndex+1)
        end
    end
end

function CashOutHistoryLayer:cellSizeForTable( view, idx )
	return 1600, 119
end

function CashOutHistoryLayer:numberOfCellsInTableView( view )
	if nil == self.m_historyInfo then
		return 0
	else
		return #self.m_historyInfo
	end
end

function CashOutHistoryLayer:tableCellAtIndex( view, idx )
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end

    local itemNode = cell:getChildByName("ITEM_NODE")
    if not itemNode then
        itemNode = self._itemPre:clone()
        itemNode:setPosition(800, 0)
        itemNode:setName("ITEM_NODE")
        itemNode:setVisible(true)
        cell:addChild(itemNode)
    end
    self:updateItem(itemNode, idx + 1)
    return cell
end

--更新item
function CashOutHistoryLayer:updateItem(itemNode, _index)
	local data = self.m_historyInfo[_index]
	itemNode:getChildByName("Text_out"):setString("R$"..g_format:formatNumber(data.out, g_format.fType.standard))
	itemNode:getChildByName("Text_time"):setString(os.date("%Y-%m-%d %H:%M:%S", data.time))
    itemNode:getChildByName("Text_state"):setString(g_language:getString("cashout_state"..data.state))
    if data.state == 1 then
        --审核中
        itemNode:getChildByName("Text_state"):setTextColor(cc.c3b(246,53,217))
    elseif data.state == 2 then
        --提交失败
        itemNode:getChildByName("Text_state"):setTextColor(cc.c3b(255,220,25))
    elseif data.state == 4 then
        --违规订单
        itemNode:getChildByName("Text_state"):setTextColor(cc.c3b(255,41,30))
    else
        --已完成
        itemNode:getChildByName("Text_state"):setTextColor(cc.c3b(28,231,114))
    end
    local orderStr = data.order
    StringUtil.setLabelWithSizeLimit(itemNode:getChildByName("Text_order"), orderStr, 268) --字串裁剪...
    itemNode:getChildByName("btn_copy"):addClickEventListener(function ()
        local res, msg = g_MultiPlatform:getInstance():copyToClipboard(data.order)
        if res == true then
             showToast(g_language:getString("copy_success"))  
        end
    end)
end

return CashOutHistoryLayer