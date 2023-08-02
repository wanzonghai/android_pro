
--分享转盘记录
local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local ShareTurnTableHistory = class("ShareTurnTableHistory",BaseLayer)
local HeadNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HeadNode")
local TableView = appdf.req(appdf.CLIENT_SRC.."Tools.TableView")

function ShareTurnTableHistory:ctor(result)
    ShareTurnTableHistory.super.ctor(self)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self._result = result
    self:loadLayer("ShareTurnTable/ShareTurnTableHistory.csb")
    self:init()
    ShowCommonLayerAction(self.bg,self.content)
end     

function ShareTurnTableHistory:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.SHARE_TURN_RECORD)
    self.clonePanel:release()
end

function ShareTurnTableHistory:initData()
    self._tableView = nil
    self._recordInfos = {}
    self._index = 1
    self._isBottom = false
end

function ShareTurnTableHistory:init()
    self:initData()
    self:initView()
    self:initListener()
    self:getTableView()
end

function ShareTurnTableHistory:initView()
    self.bg = self:getChildByName("bg")
    self.content = self:getChildByName("content")
    self.btnClose = self:getChildByName("btnClose")
    self.clonePanel = self:getChildByName("clonePanel")
    self.numText1 = self:getChildByName("numText1")
    self.numText2 = self:getChildByName("numText2")
    self.inviteBtn = self:getChildByName("inviteBtn")
    self.noSumText = self:getChildByName("noSumText")
    self.showVipBtn = self:getChildByName("showVipBtn")
    self.noSumText:show()
    self.clonePanel:retain()
    self.clonePanel:removeFromParent()
end

function ShareTurnTableHistory:initListener()
    self.inviteBtn:addTouchEventListener(handler(self,self.onTouch))
    self.btnClose:addTouchEventListener(handler(self,self.onTouch))
    self.showVipBtn:addTouchEventListener(handler(self,self.onTouch))
    self.bg:addTouchEventListener(handler(self,self.onTouch))
    G_event:AddNotifyEvent(G_eventDef.SHARE_TURN_RECORD,handler(self,self.getRecord))
    
end

--返回玩家邀请记录
function ShareTurnTableHistory:getRecord(data)
    dismissNetLoading()
    self.numText2:setString(tostring(data.dwRecordCount or 0))
    self.numText1:setString(tostring(data.dwBindCount or 0))
    local lsItems = data.lsItems
    if not lsItems or #lsItems <=0 then
        self._isBottom = true
        return
    end
    for k = 1,#lsItems do
        local item = lsItems[k]
        self._recordInfos[#self._recordInfos + 1] = item
    end
    self.noSumText:hide()
    self._tableView:reloadDataInPos()
    self._index = self._index + 1
end


function ShareTurnTableHistory:onTouch(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        local name = sender:getName()
        if name == "inviteBtn" then
            --G_ServerMgr:S2C_UpdateShareCount()
            G_event:NotifyEvent(G_eventDef.UI_SHOW_SHARE,GlobalUserItem.MAIN_SCENE)
        elseif name == "btnClose" then
            self:close()
        elseif name == "showVipBtn" then
            -- if self._result then
            --     G_event:NotifyEvent(G_eventDef.shareVipDescrible,self._result)
            -- else
            --     showNetLoading()
            --     G_ServerMgr:receiveVIP_Gift()
            -- end
            G_event:NotifyEvent(G_eventDef.showSHAREPHONEDATA)
        elseif name == "bg" then
            self:close()
        end
    end
end

function ShareTurnTableHistory:setInfo()

end

function ShareTurnTableHistory:getTableView()
    local tab = cc.TableView2:create(cc.size(1512,664))
    tab:setAnchorPoint(cc.p(0.5,0))
    tab:setDirection(cc.TableViewDirection.vertical)
    tab:setFillOrder(cc.TableViewFillOrder.topToBottom)
    tab:registerFunc(cc.TableViewFuncType.cellSize, handler(self,self.setSize))
    tab:registerFunc(cc.TableViewFuncType.cellNum, handler(self,self.setNumber))
    tab:registerFunc(cc.TableViewFuncType.cellLoad, handler(self,self.loadCell))
    tab:addEventListener(handler(self,self.scrollViewEvent))
    self.content:addChild(tab)
    tab:setPosition(cc.p(817,152))
    tab:setScrollBarEnabled(false)
    self._tableView = tab
end

function ShareTurnTableHistory:setSize()
    return 1512,130
end

function ShareTurnTableHistory:setNumber()
    return #self._recordInfos
end

function ShareTurnTableHistory:loadCell(view,index)
    local cell = view:dequeueCell()
	if not cell then
		cell = cc.TableViewCell2.new()
	end
    local item = cell._item
    
    if not cell._item then
        item = self.clonePanel:clone()
        cell._item=item
        item:setAnchorPoint(0,0.5)
        item:setPosition(cc.p(0,65))
        cell:addChild(cell._item)   
    end
    self:initItem(item,index)
	return cell
end

function ShareTurnTableHistory:initItem(item,index)
    local info = self._recordInfos[index]
    local head_Node = item:getChildByName("headNode")
    head_Node:removeAllChildren()
    local right1 = item:getChildByName("right1")
    right1:ignoreContentAdaptWithSize(true)
    local right2 = item:getChildByName("right2")
    right2:ignoreContentAdaptWithSize(true)
    local playerName = item:getChildByName("playerName")
    local dateName = item:getChildByName("dateName")
    local head = HeadNode:create(info.wFaceID)
    head_Node:addChild(head)
    head_Node:setScale(0.6)
    head:setVipVisible(false)
    if info.cbIsBindMobile >= 1 then                --绑定过手机
        right1:loadTexture("client/res/ShareTurnTable/right2x.png",1)
    else
        right1:loadTexture("client/res/ShareTurnTable/wrong2x.png",1)
    end
    if info.cbIsBetScore >= 1 then              --是否达到下注量
        right2:loadTexture("client/res/ShareTurnTable/right2x.png",1)
    else
        right2:loadTexture("client/res/ShareTurnTable/wrong2x.png",1)
    end
    dateName:setString(os.date("%d.%m.%Y %H:%M:%S",info.tmRegisteTime))
    playerName:setString(info.szNickName)

    local vipImage = item:getChildByName("vipImage")
    local lastText = item:getChildByName("lastText")
    vipImage:loadTexture("client/res/VIP/GUI/"..info.cbGrowLevel..".png",1)
    lastText:setString(g_format:formatNumber(info.llSpreadScore,g_format.fType.abbreviation,g_format.currencyType.GOLD))
end

function ShareTurnTableHistory:scrollViewEvent(sender,eventType)
    if eventType == ccui.ScrollviewEventType.scrollToBottom then            --滑动到底部
        if not self._isBottom then
            showNetLoading()
            G_ServerMgr:requestTurnTableUserInvited(self._index)               --获取邀请记录
        end
    elseif eventType == ccui.ScrollviewEventType.scrollToTop then           --滑动到顶部

    end  
    if eventType >=ccui.ScrollviewEventType.scrolling then
		self._tableView:_scrollViewDidScroll()
    end
end

return ShareTurnTableHistory