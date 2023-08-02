local GamePlayerList = class("GamePlayerList", function(parent,data)
		local gamePlayerList = display.newLayer()
    return gamePlayerList
end)

function GamePlayerList:ctor(parent,data)
    parent = parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,10)
    self.playlist = data
    local csbNode = g_ExternalFun.loadCSB("game/yule/baccarat/res/UI/PlayListLayer.csb")
    self:addChild(csbNode)
    self.node = csbNode:getChildByName("nodePlayer")
    ShowCommonLayerAction(nil,self.node)
    csbNode:getChildByName("btnPanel"):onClickEnd(handler(self,self.onClickClose),true)
    self.node:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    self.panel = self.node:getChildByName("panel")
	self._tableView = cc.TableView:create(cc.size(950,540))
	self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self._tableView:setDelegate()
	self._tableView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	self._tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	self._tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.panel:addChild(self._tableView)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(0,0)
    self.tableNumberOfCell = math.ceil(#self.playlist/2)
    self._tableView:reloadData()
    
end
function GamePlayerList:onClickClose()
    DoHideCommonLayerAction(self.bg,self.node,function() self:removeSelf() end)
end
function GamePlayerList:cellSizeForTable(view, idx)
    return 950,160
end
function GamePlayerList:numberOfCellsInTableView( view )
	return self.tableNumberOfCell
end
function GamePlayerList:tableCellAtIndex( view, idx )
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local item = cell:getChildByTag(idx)
    if not item then
        item = g_ExternalFun.loadCSB("game/yule/baccarat/res/UI/nodePlayer.csb",nil,false)
        item:setTag(idx)
        cell:addChild(item)
        item:setPosition(420,75)
    end
    for i=1,2 do
        local info = self.playlist[idx*2+i]
        local nodeChild = item:getChildByName("item"..i)
        if info then
            nodeChild:setVisible(true)
            -- nodeChild:getChildByName("spHead"):loadTexture( string.format("public/Face%d.jpg",info.wFaceID))
            -- nodeChild:getChildByName("spHead"):setContentSize(cc.size(80,80))
            --头像
            local imgHead = nodeChild:getChildByName("spHead")
            imgHead:removeAllChildren()
            local faceId = info.wFaceID
            local pPathHead = string.format("client/res/public/Face%d.jpg", faceId)
            local pPathClip = "client/res/public/clip.png"
            g_ExternalFun.ClipHead(imgHead, pPathHead, pPathClip)

            nodeChild:getChildByName("txtName"):setString(info.szNickName)
            nodeChild:getChildByName("txtCoin"):setString(info.lScore)
        else
            nodeChild:setVisible(false)
        end
    end
    return cell
end
--刷新历史记录
-- function GamePlayerList:onRefreshPlayerList(data)
--     local nCount = math.ceil(#data/2)
--     local length = nCount * 108
--     if length < 564 then
--         length = 564
--     end
--     local index = 0
--     for i=1,nCount do
--          local itemY = length-56-(i-1)*108
--          local item = g_ExternalFun.loadCSB("game/yule/baccarat/res/nodePlayer.csb",nil,false)
--          item:setPosition(534,itemY)
--          self.scrollview:addChild(item)
--          for k=1,2 do
--              local info = data[(i-1)*2+k]
--              if info then
--                  local child = item:getChildByName("item"..k)
--                  child:setVisible(true)
--                 --  child:getChildByName("spHead"):loadTexture( string.format("public/Face%d.jpg",info.wFaceID))
--                 --  child:getChildByName("spHead"):setContentSize(cc.size(80,80))
--                  child:getChildByName("txtName"):setString(info.szNickName)
--                  child:getChildByName("txtCoin"):setString(info.lScore)
--              end
--          end
--     end
--     self.scrollview:setInnerContainerSize(cc.size(1060,length))
-- end

return GamePlayerList