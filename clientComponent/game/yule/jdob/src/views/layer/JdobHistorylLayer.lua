--开奖记录界面(只有一轮)
local JdobHistorylLayer = class("JdobHistorylLayer", function(args)
    local JdobHistorylLayer =  display.newLayer()
    return JdobHistorylLayer
end)
local module_pre = "game.yule.jdob.src"
local g_var = g_ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"

function JdobHistorylLayer:ctor(args)
    self.openResult = args

    local bgLayer = display.newLayer(cc.c4b(0, 0, 0, 216))
    bgLayer:setPosition(-display.width * 0.5, -display.height * 0.5)
    bgLayer:addTo(self)
    bgLayer:enableClick(function()
        self:removeFromParent()
    end)
    
    local csbNode = g_ExternalFun.loadCSB("UI/boxHistoryLayer.csb")
    csbNode:setContentSize(display.width,display.height)
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)
    self:addChild(csbNode)
    ccui.Helper:doLayout(csbNode)
    self.m_csbNode = csbNode
    g_ExternalFun.loadChildrenHandler(self,csbNode)    
    
    --背景关闭
    self.mm_btn_close:onClicked(handler(self,self.onClickClose),true) 

    local _tableView = cc.TableView:create(self.mm_Panel_list:getContentSize())
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    _tableView:setDelegate()
    _tableView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(handler(self, self.scrollViewDidScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.mm_Panel_list:addChild(_tableView)
    self.m_tableView = _tableView

    self.mm_cell_one:hide()
    self.mm_cell_one:setTouchEnabled(false)

    if self.openResult.cbBetCount then
        self.m_tableView:reloadData()
    end
end

function JdobHistorylLayer:onClickClose()        
    self:removeFromParent()
end

function JdobHistorylLayer:onExit()
    
end

--单元滚动回调
function JdobHistorylLayer:scrollViewDidScroll(view)
    
end

function JdobHistorylLayer:cellSizeForTable( view, idx )
    if idx == 0 then
        return 568, 162
    else
        return 568, 140
    end
end

function JdobHistorylLayer:numberOfCellsInTableView( view )
    if self.openResult.cbBetArray then
        return #self.openResult.cbBetArray+1
    else
        return 0
    end
end

function JdobHistorylLayer:tableCellAtIndex( view, idx )
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end

    local itemNode = cell:getChildByName("ITEM_NODE")
    if not itemNode then
        itemNode = self.mm_cell_one:clone()
        itemNode:setPosition(0, 0)
        itemNode:setAnchorPoint(cc.p(0,0))
        itemNode:setName("ITEM_NODE")
        itemNode:setVisible(true)
        cell:addChild(itemNode, 0, 11)
    end
    self:updateItem(itemNode, idx)
    return cell
end

--更新item
function JdobHistorylLayer:updateItem(itemNode, _index)
    local data = nil
    local serverKind = G_GameFrame:getServerKind()
    local cell_result = itemNode:getChildByName("cell_result")
    cell_result:setVisible(false)
    cell_result:setPosition(0, 0)
    local cell_anim = itemNode:getChildByName("cell_anim")
    cell_anim:setVisible(false)
    cell_anim:setPosition(0, 0)
    local cell_number = itemNode:getChildByName("cell_number")
    cell_number:setVisible(false)
    cell_number:setPosition(0, 0)
    if _index == 0 then
        cell_result:setVisible(true)
        data = self.openResult.openResult
        local totalBet = 0
        for i=1,#self.openResult.cbBetArray do
            totalBet = totalBet + self.openResult.cbBetArray[i].llBetscore
        end
        for i=1,5 do  
            local icon = cell_result:getChildByName("Icon_anim"..i)
            local imgName = string.format("anim_b_%d.png", data.betArray[i]+1)
            icon:loadTexture("game/yule/jdob/res/GUI/anim/"..imgName,1)
            local numBg = cell_result:getChildByName("number_animbg"..i)
            local numTb = data.betNum[i]
            local animnumber = numTb[1]*1000 + numTb[2]*100 + numTb[3]*10 + numTb[4]
            numBg:getChildByName("number_anim"):setString(tostring(animnumber))
        end
        local betStr = string.format("Total Bet:%s FUN", g_format:formatNumber(totalBet,g_format.fType.standard,serverKind))
        cell_result:getChildByName("textTotalBet"):setString(betStr)
        local betStr = string.format("Total Win:%s FUN", g_format:formatNumber(data.win_score,g_format.fType.standard,serverKind))
        cell_result:getChildByName("textTotalWin"):setString(betStr)
    else
        data = self.openResult.cbBetArray[_index]
        if data.cbBetItemType == g_var(cmd).betItemType.eNumber then
            cell_number:setVisible(true)
            local oneBetMax = g_var(cmd).betStartNum.eNumber + data.cbBetType
            for i=1,4 do
                local icon = cell_number:getChildByName("Icon_number"..i)
                icon:setVisible(false)
                if i <= oneBetMax then
                    icon:setVisible(true)
                    local imgName = string.format("txz_%d_bg.png", data.cbBetNum[i])
                    icon:loadTexture("game/yule/jdob/res/GUI/"..imgName,1)
                end
            end
            local betStr = string.format("Bet:%s FUN", g_format:formatNumber(data.llBetscore,g_format.fType.standard,serverKind))
            cell_number:getChildByName("textBet"):setString(betStr)
            local betStr = string.format("Win:%s FUN", g_format:formatNumber(data.llWinscore,g_format.fType.standard,serverKind))
            cell_number:getChildByName("textWin"):setString(betStr)
        else
            cell_anim:setVisible(true)
            local oneBetMax = g_var(cmd).betStartNum.eAnim + data.cbBetType
            for i=1,5 do
                local icon = cell_anim:getChildByName("Icon_anim"..i)
                icon:setVisible(false)
                if i <= oneBetMax then
                    icon:setVisible(true)
                    local imgName = string.format("anim_b_%d.png", data.cbBetNum[i]+1)
                    icon:loadTexture("game/yule/jdob/res/GUI/anim/"..imgName,1)
                end
            end
            local betStr = string.format("Bet:%s FUN", g_format:formatNumber(data.llBetscore,g_format.fType.standard,serverKind))
            cell_anim:getChildByName("textBet"):setString(betStr)
            local betStr = string.format("Win:%s FUN", g_format:formatNumber(data.llWinscore,g_format.fType.standard,serverKind))
            cell_anim:getChildByName("textWin"):setString(betStr)
        end
    end
end

return JdobHistorylLayer