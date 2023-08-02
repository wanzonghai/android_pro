local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local ShareVipDescrible = class("ShareVipDescrible",BaseLayer)
local TableView = appdf.req(appdf.CLIENT_SRC.."Tools.TableView")

function ShareVipDescrible:ctor(args)
    ShareVipDescrible.super.ctor(self)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self._args = args
    self:loadLayer("ShareTurnTable/ShareVipDescrible.csb")
    self:init()
end

function ShareVipDescrible:init()
    self:initView()
    self:initListener()
    self:doDisplay()
    ShowCommonLayerAction(self.bg,self.content)
end

function ShareVipDescrible:initView()
    self.bg = self:getChildByName("bg")
    self.content = self:getChildByName("content")
    self.clonePanel = self:getChildByName("clonePanel")
    self.closeBtn = self:getChildByName("closeBtn")
    self.clonePanel:hide()
end

function ShareVipDescrible:initListener()
    self.closeBtn:addTouchEventListener(handler(self,self.onTouch))
    self.bg:addTouchEventListener(handler(self,self.onTouch))
end

function ShareVipDescrible:onTouch(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        local name = sender:getName()
        if name == "closeBtn" then
            self:close()
        elseif name == "bg" then
            self:close()
        end
    end
end

function ShareVipDescrible:doDisplay()
    self._recordInfos = self._args
    self:createTableView()
    self._tableView:reloadData()
    self._tableView:jumpToTop()
end

function ShareVipDescrible:createTableView()
    local tab = cc.TableView2:create(cc.size(744,788))
    tab:setAnchorPoint(cc.p(0,0))
    tab:setDirection(cc.TableViewDirection.vertical)
    tab:setFillOrder(cc.TableViewFillOrder.topToBottom)
    tab:registerFunc(cc.TableViewFuncType.cellSize, handler(self,self.setSize))
    tab:registerFunc(cc.TableViewFuncType.cellNum, handler(self,self.setNumber))
    tab:registerFunc(cc.TableViewFuncType.cellLoad, handler(self,self.loadCell))
    self.content:addChild(tab)
    tab:setPosition(cc.p(28.58,22.92))
    tab:setScrollBarEnabled(false)
    self._tableView = tab
end

function ShareVipDescrible:setSize()
    return 742,86
end

function ShareVipDescrible:setNumber()
    return #self._recordInfos
end

function ShareVipDescrible:loadCell(view,index)
    local cell = view:dequeueCell()
	if not cell then
		cell = cc.TableViewCell2.new()
	end
    local item = cell._item
    
    if not cell._item then
        item = self.clonePanel:clone()
        cell._item=item
        item:setAnchorPoint(0,0.5)
        item:setPosition(cc.p(0,38.5))
        cell:addChild(cell._item)   
    end
    self:initItem(item,index)
	return cell
end

function ShareVipDescrible:initItem(item,index)
    item:show()
    local value = self._recordInfos[index]
    local vipImage = item:getChildByName("vipImage")
    local vipText = item:getChildByName("vipText")
    local giftText = item:getChildByName("giftText")
    giftText:setString(g_format:formatNumber(value,g_format.fType.abbreviation,g_format.currencyType.GOLD))
    vipText:setString("VIP "..(index - 1))
    vipImage:loadTexture("client/res/VIP/GUI/"..(index - 1)..".png",1)
end

return ShareVipDescrible