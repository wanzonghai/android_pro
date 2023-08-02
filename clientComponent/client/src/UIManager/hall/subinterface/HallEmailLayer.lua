--邮件界面
local HallEmailLayer = class("HallEmailLayer", function(args)
    local HallEmailLayer =  display.newLayer()
    return HallEmailLayer
end)

function HallEmailLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()    
    parent:addChild(self,ZORDER.POPUP)

    self.m_mailList = {}
    self.m_curIndex = 0
    self.m_totalIndex = 0
    self.touchDownBtn = false   --按钮是否按下
    self.scrollOffset = nil     --列表拖动的偏移
    self.playListAnim = true

    local csbNode = g_ExternalFun.loadCSB("mail/MailLayer.csb")
    csbNode:setContentSize(display.width,display.height)
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)
    self:addChild(csbNode)
    ccui.Helper:doLayout(csbNode)
    -- self.m_csbNode = csbNode
    g_ExternalFun.loadChildrenHandler(self,csbNode)    
    
    --背景关闭
    self.mm_bg:onClicked(handler(self,self.onClickClose),true) 

    self.mm_Panel_1:setClippingEnabled(true)

    local bgSpine = sp.SkeletonAnimation:create("client/res/mail/spine/youjian.json","client/res/mail/spine/youjian.atlas", 1)
    bgSpine:addTo(self.mm_spine_1)
    bgSpine:setPosition(0, 0)
    bgSpine:setAnimation(0, "ruchang", false)
    bgSpine:registerSpineEventHandler( function( event )
        if event.type == "complete" then
            bgSpine:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    local bgSpine2 = sp.SkeletonAnimation:create("client/res/mail/spine/youjian_1.json","client/res/mail/spine/youjian_1.atlas", 1)
    bgSpine2:addTo(self.mm_spine_2)
    bgSpine2:setPosition(0, 0)
    bgSpine2:setAnimation(0, "ruchang", false)
    bgSpine2:registerSpineEventHandler( function( event )
        if event.type == "complete" then
            bgSpine2:setAnimation(0, "daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    --列表遮罩进入动画
    self.mm_Img_mask:setOpacity(0)
    self:rightMoveAnim(self.mm_Img_mask, 0.5)
    --列表空提示
    self.mm_Img_empty:hide()
    self.mm_Img_empty:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(function()
            --列表空提示
            if #self.m_mailList == 0 then
                self.mm_Img_empty:show()
                self.mm_Img_empty:stopAllActions()
                self.mm_Img_empty:setOpacity(0)
                self.mm_Img_empty:runAction(cc.FadeTo:create(0.3, 255))
            end
        end)
    ))

    local _tableView = cc.TableView:create(self.mm_Panel_1:getContentSize())
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    _tableView:setDelegate()
    _tableView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(handler(self, self.scrollViewDidScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.mm_Panel_1:addChild(_tableView)
    self.m_tableView = _tableView

    self.mm_Panel_item:hide()
    self.mm_Panel_item:setTouchEnabled(false)

    G_event:AddNotifyEvent(G_eventDef.NET_MAIL_LIST_RESULT,handler(self,self.initWithData))
    G_event:AddNotifyEvent(G_eventDef.NET_MAIL_DETAILS_RESULT,handler(self,self.onDetailReceive))
    G_event:AddNotifyEvent(G_eventDef.NET_MAIL_DELETE_RESULT,handler(self,self.onDeleteReceive))
    G_event:AddNotifyEvent(G_eventDef.NET_GET_MAIL_REWARD_RESULT,handler(self,self.onGetRewardReceive))
    showNetLoading()
    G_ServerMgr:C2S_GetMailList(10, 1)
    --testcode
    -- self:testcode(1)
end

function HallEmailLayer:onClickClose()        
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function()         
        self:removeSelf() 
    end)
end

function HallEmailLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_MAIL_LIST_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.NET_MAIL_DETAILS_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.NET_MAIL_DELETE_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.NET_GET_MAIL_REWARD_RESULT)
end
--收到邮件列表分段信息
function HallEmailLayer:initWithData(_cmdData)
    dismissNetLoading()
    -- tdump(_cmdData, "HallEmailLayer:initWithData", 9)
    for i, v in ipairs(_cmdData.mailList) do
        table.insert(self.m_mailList, v)
    end
    --前端倒序排序
    table.sort(self.m_mailList,function (a,b)
        return a.mailStatus<=a.mailStatus and a.time>=b.time
    end)
    if #self.m_mailList == 0 then
        self.mm_Img_empty:show()
    else
        self.mm_Img_empty:hide()
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

    --列表进入动画
    if self.playListAnim then
        self.playListAnim = false
        for i=1,10 do
            local cell = self.m_tableView:cellAtIndex(i-1)
            if cell then
                local itemNode = cell:getChildByTag(11)
                itemNode:setOpacity(0)
                self:rightMoveAnim(itemNode, 0.5)
            end
        end
    end
end
--收到邮件详情
function HallEmailLayer:onDetailReceive(_cmdData)
    local index = 0
    for i=1,#self.m_mailList do
        if self.m_mailList[i].mailId == _cmdData.mailInfo.mailId then
            self.m_mailList[i].mailStatus = 1
            self.m_mailList[i].content = _cmdData.mailInfo.content
            self.m_mailList[i].rewardTb = _cmdData.mailInfo.rewardTb
            index = i
            break
        end
    end
    if index > 0 then
        self:showMailDetailDialog(self.m_mailList[index])
        self.m_tableView:updateCellAtIndex(index-1)
    end
end
--收到删除邮件
function HallEmailLayer:onDeleteReceive(_cmdData)
    local index = 0
    for i=1,#self.m_mailList do
        if self.m_mailList[i].mailId == _cmdData.mailId then
            index = i
            break
        end
    end
    if index > 0 then
        table.remove(self.m_mailList, index)
        --self.m_tableView:removeCellAtIndex(index-1)
        local oldOffset = self.m_tableView:getContentOffset()
        local oldSize = self.m_tableView:getContentSize()
        tlog("HallEmailLayer onDeleteReceive1", oldOffset.y ,oldSize.height )
        self.m_tableView:reloadData()
        local newOffset = self.m_tableView:getContentOffset()
        local newSize = self.m_tableView:getContentSize()
        local newOffsetY = oldOffset.y + -1*(newSize.height - oldSize.height)
        tlog("HallEmailLayer onDeleteReceive2", newOffset.y ,newSize.height )
        self.m_tableView:setContentOffset(cc.p(oldOffset.x, newOffsetY))

        if self.detailDialog then
            self.detailDialog:removeFromParent()
            self.detailDialog = nil
        end
        if #self.m_mailList == 0 then
            self.mm_Img_empty:show()
        else
            self.mm_Img_empty:hide()
        end
    end
end
--收到领取邮件
function HallEmailLayer:onGetRewardReceive(_cmdData)
    local index = 0
    for i=1,#self.m_mailList do
        if self.m_mailList[i].mailId == _cmdData.mailId then
            self.m_mailList[i].mailStatus = 1
            for j=1,#self.m_mailList[i].rewardTb do
                self.m_mailList[i].rewardTb[j].rewardStatus = 1
            end
            index = i
            local numStr = g_format:formatNumber(self.m_mailList[i].rewardTb[1].rewardNum, g_format.fType.standard)
            local toastStr = string.format(g_language:getString("sign_gold"), numStr)
            showToast(toastStr)
            break
        end
    end
    if index > 0 then
        self.m_tableView:updateCellAtIndex(index-1)
        if self.detailDialog then
            self:updateMailDetailReward(self.m_mailList[index], self.detailDialog:getChildByTag(21))
        end
    end
end

--单元滚动回调
function HallEmailLayer:scrollViewDidScroll(view)
    local offset = view:getContentOffset()
    local contentSize = view:getContentSize()
    local viewSize = view:getViewSize()

    if (not self.scrollOffset) and self.touchDownBtn then
        self.scrollOffset = offset
    end

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
        if self.m_curIndex < self.m_totalIndex then
            G_ServerMgr:C2S_GetMailList(10, self.m_curIndex+1)
            --testcode
        end
    end
end

function HallEmailLayer:cellSizeForTable( view, idx )
    return 1489, 166
end

function HallEmailLayer:numberOfCellsInTableView( view )
    if nil == self.m_mailList then
        return 0
    else
        return #self.m_mailList
    end
end

function HallEmailLayer:tableCellAtIndex( view, idx )
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end

    local itemNode = cell:getChildByName("ITEM_NODE")
    if not itemNode then
        itemNode = self.mm_Panel_item:clone()
        itemNode:setPosition(0, 83)
        itemNode:setAnchorPoint(cc.p(0,0.5))
        itemNode:setName("ITEM_NODE")
        itemNode:setVisible(true)
        cell:addChild(itemNode, 0, 11)
    end
    self:updateItem(itemNode, idx + 1)
    return cell
end

--更新item
function HallEmailLayer:updateItem(itemNode, _index)
    local data = self.m_mailList[_index]
    itemNode:getChildByName("Img_Icon1"):setVisible(false)
    itemNode:getChildByName("Img_Icon2"):setVisible(false)
    if data.mailStatus == 1 then
        itemNode:setBackGroundImage("client/res/mail/image/yj_youjianweiling1.png")
        itemNode:getChildByName("Img_Icon2"):setVisible(true)
        itemNode:getChildByName("Img_zhen"):loadTexture("client/res/mail/image/yj_fujian1.png")
        itemNode:getChildByName("Img_clock"):loadTexture("client/res/mail/image/yj_shijian1.png")
        itemNode:getChildByName("Text_time"):setTextColor(cc.c3b(177,177,177))
    else
        itemNode:setBackGroundImage("client/res/mail/image/yj_youjianweiling.png")
        itemNode:getChildByName("Img_Icon1"):setVisible(true)
        itemNode:getChildByName("Img_zhen"):loadTexture("client/res/mail/image/yj_fujian.png")
        itemNode:getChildByName("Img_clock"):loadTexture("client/res/mail/image/yj_shijian.png")
        itemNode:getChildByName("Text_time"):setTextColor(cc.c3b(226,97,97))
    end
    if data.haveReward == 1 then
        itemNode:getChildByName("Img_zhen"):setVisible(true)
    else
        itemNode:getChildByName("Img_zhen"):setVisible(false)
    end
    local titleStr = data.title.."_"..data.mailId
    StringUtil.setLabelWithSizeLimit(itemNode:getChildByName("Text_title"), titleStr, 472) --字串裁剪...
    --itemNode:getChildByName("Text_time"):setString(os.date("%Y-%m-%d %H:%M:%S", data.time))
    local seconds = GlobalData.serverTime.llServerTime - data.time
    if seconds > 86400 then
        itemNode:getChildByName("Text_time"):setString(string.format(g_language:getString("day_before"), math.floor(seconds/86400)))
    else
        itemNode:getChildByName("Text_time"):setString(g_language:getString("today"))
    end
    local btn = itemNode:getChildByName("btn_detail")
    btn:setSwallowTouches(false)
    btn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            self.touchDownBtn = true
        elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            local isRespond = true
            local currPos =  itemNode:getParent():convertToWorldSpace(cc.p(itemNode:getPositionX(),itemNode:getPositionY()))      --获得当前显示坐标
            if self.scrollOffset then
                local curOffset = self.m_tableView:getContentOffset()
                if math.abs(curOffset.y - self.scrollOffset.y) > 1 then
                    isRespond = false
                end
                self.scrollOffset = nil
            end                         
            tlog("onTouch width ",currPos.y, isRespond)
            local Panel_1 = self.mm_Panel_1
            local listPos = Panel_1:getParent():convertToWorldSpace(cc.p(Panel_1:getPositionX(),Panel_1:getPositionY())) --列表位置
            tlog("onTouch width2 ",currPos.y, listPos.y, Panel_1:getContentSize().height)
            if currPos.y < listPos.y - Panel_1:getContentSize().height/2 or currPos.y > listPos.y + Panel_1:getContentSize().height/2 then
                isRespond = false
            end
            if isRespond then
                if data.content then
                    self:showMailDetailDialog(data)
                    data.mailStatus = 1
                    self.m_tableView:updateCellAtIndex(_index)
                else
                    G_ServerMgr:C2S_GetMailDetails(data.mailId)
                    --testcode
                    --self:testcode(2, data.mailId)
                end
            end
            self.touchDownBtn = false
        end
    end)
end

--弹出邮件详情
function HallEmailLayer:showMailDetailDialog(detailInfo)
    if (self.detailDialog and not tolua.isnull(self.detailDialog)) then
        self.detailDialog:removeFromParent()
        self.detailDialog = nil
    else
        local bgLayer = display.newLayer()
        bgLayer:addTo(self)
        bgLayer:enableClick(function()
            bgLayer:removeFromParent()
            self.detailDialog = nil
        end)
        self.detailDialog = bgLayer
        local csbNode = g_ExternalFun.loadCSB("mail/MailDetailLayer.csb")
        csbNode:setAnchorPoint(cc.p(0.5,0.5))
        csbNode:setPosition(display.cx,display.cy)
        csbNode:addTo(bgLayer, 0, 21) 
        local timeline = cc.CSLoader:createTimeline("mail/MailDetailLayer.csb")
        csbNode:runAction(timeline)
        timeline:gotoFrameAndPlay(0, 35, false)
        csbNode:getChildByName("btn_close"):addClickEventListener( function ()
            bgLayer:removeFromParent()
            self.detailDialog = nil
        end )
        csbNode:getChildByName("btn_close"):setPressedActionEnabled(true)
        local spBg = csbNode:getChildByName("Sprite_bg")
        local bgSpine = sp.SkeletonAnimation:create("client/res/mail/spine/xinfeng.json","client/res/mail/spine/xinfeng.atlas", 1)
        bgSpine:addTo(spBg)
        bgSpine:setPosition(0, 0)
        bgSpine:setAnimation(0, "daiji", false)
        --标题
        csbNode:getChildByName("Panel_anim"):getChildByName("Text_title"):setString(detailInfo.title)
        --内容
        csbNode:getChildByName("Panel_anim"):getChildByName("Text_1"):setString(detailInfo.content)
        --奖励
        local Panel_noreward = csbNode:getChildByName("Panel_anim"):getChildByName("Panel_noreward")
        local Panel_reward = csbNode:getChildByName("Panel_anim"):getChildByName("Panel_reward")
        Panel_noreward:getChildByName("btn_sure"):addClickEventListener( function ()
            bgLayer:removeFromParent()
            self.detailDialog = nil
        end )
        Panel_noreward:getChildByName("btn_delete"):addClickEventListener( function ()
            G_ServerMgr:C2S_GetMailDelete(detailInfo.mailId)
            --testcode
            --self:testcode(3, detailInfo.mailId)
        end )
        Panel_reward:getChildByName("btn_get"):addClickEventListener( function ()
            if detailInfo.rewardTb[1].rewardStatus == 0 then
                G_ServerMgr:C2S_GetMailReward(detailInfo.mailId)
                --testcode
                --self:testcode(4, detailInfo.mailId)
            else
                G_ServerMgr:C2S_GetMailDelete(detailInfo.mailId)
                --testcode
                --self:testcode(3, detailInfo.mailId)
            end
        end )
        self:updateMailDetailReward(detailInfo, csbNode)
    end
end
--更新邮件奖励
function HallEmailLayer:updateMailDetailReward(detailInfo, csbNode)
    if csbNode then
        local Panel_noreward = csbNode:getChildByName("Panel_anim"):getChildByName("Panel_noreward")
        local Panel_reward = csbNode:getChildByName("Panel_anim"):getChildByName("Panel_reward")
        Panel_noreward:setVisible(false)
        Panel_reward:setVisible(false)
        dump(detailInfo, "updateMailDetailReward", 9)
        if detailInfo.rewardTb[1].rewardNum == 0 then
            Panel_noreward:setVisible(true)
            Panel_noreward:getChildByName("btn_sure"):setTouchEnabled(true)
            Panel_noreward:getChildByName("btn_delete"):setTouchEnabled(true)
            Panel_reward:getChildByName("btn_get"):setTouchEnabled(false)
        else
            Panel_reward:setVisible(true)
            Panel_noreward:getChildByName("btn_sure"):setTouchEnabled(false)
            Panel_noreward:getChildByName("btn_delete"):setTouchEnabled(false)
            Panel_reward:getChildByName("btn_get"):setTouchEnabled(true)
            if detailInfo.rewardTb[1].rewardStatus == 0 then
                Panel_reward:getChildByName("btn_get"):getChildByName("image"):setTexture("client/res/mail/image/lingqu.png")
            else
                Panel_reward:getChildByName("btn_get"):getChildByName("image"):setTexture("client/res/mail/image/shanchu.png")
            end
            for i=1,#detailInfo.rewardTb do
                local item = Panel_reward:getChildByName("Panel_item"..i)
                if detailInfo.rewardTb[i].rewardNum == 0 then
                    item:setVisible(false)
                else
                    item:setVisible(true)
                    item:getChildByName("BFLabel_num"):setString(g_format:formatNumber(detailInfo.rewardTb[i].rewardNum, g_format.fType.standard))
                    if detailInfo.rewardTb[i].rewardStatus == 0 then
                        item:getChildByName("img_get"):setVisible(false)
                    else
                        item:getChildByName("img_get"):setVisible(true)
                    end
                end
            end
        end
    end
end
--界面出现动画
function HallEmailLayer:rightMoveAnim(animNode, delay)
    delay = delay or 0
    local tagPos = cc.p(animNode:getPositionX(), animNode:getPositionY())
    local startPos = cc.p(tagPos.x-100, tagPos.y)
    local startScale = 0.32
    local startOpacity = 0
    --local moveby = cc.MoveBy:create(0.25, cc.p(100,0))
    local moveby = cc.EaseCubicActionOut:create(cc.MoveBy:create(0.25, cc.p(100,0)))
    --local scale = cc.ScaleTo:create(0.25, 1.0)
    local scale = cc.EaseQuinticActionOut:create(cc.ScaleTo:create(0.25, 1.0))
    local fade = cc.FadeTo:create(0.25, 128)
    --local seq = cc.Sequence:create(cc.Spawn:create(bezierForward, rotate), scale, scale1, _callAction)
    local seq = cc.Sequence:create(
        cc.DelayTime:create(delay),
        cc.Spawn:create(moveby, scale, fade), 
        cc.FadeTo:create(0.25, 255)
        )
    animNode:setPosition(startPos)
    animNode:setScale(startScale)
    animNode:setOpacity(startOpacity)
    animNode:runAction(seq)
end

--testcode
function HallEmailLayer:testcode(testtype, param)
    local cmdData = {}
    if testtype == 1 then
        cmdData.dwPageCount = 2
        cmdData.dwPageIndex = 1
        cmdData.dwPageSize = 10
        cmdData.dwSocketID = 0
        cmdData.dwUserId = 2844137
        cmdData.mailList = {}
        for i=1,10 do
            cmdData.mailList[i] = {}
            cmdData.mailList[i].dwFromUserId = 111
            cmdData.mailList[i].mailId = i
            cmdData.mailList[i].mailStatus = 0
            cmdData.mailList[i].mailType = 0
            cmdData.mailList[i].time = 1671094881
            cmdData.mailList[i].title = "biaoti"..i
            cmdData.mailList[i].rewardTb = {}
            for j=1,5 do
                cmdData.mailList[i].rewardTb[j] = {}
                cmdData.mailList[i].rewardTb[j].rewardType = 1
                cmdData.mailList[i].rewardTb[j].rewardNum = 0--i*10
                cmdData.mailList[i].rewardTb[j].rewardStatus = 0
            end
        end
        G_event:NotifyEvent(G_eventDef.NET_MAIL_LIST_RESULT, cmdData)
    elseif testtype == 2 then
        cmdData.dwSocketID = 0
        cmdData.dwUserId = 2844137
        cmdData.mailInfo = {}
        cmdData.mailInfo.content = "3333"
        cmdData.mailInfo.mailId = param
        cmdData.mailInfo.rewardTb = {}
        for j=1,5 do
            cmdData.mailInfo.rewardTb[j] = {}
            cmdData.mailInfo.rewardTb[j].rewardType = 0
            cmdData.mailInfo.rewardTb[j].rewardNum = 0--param*10
            cmdData.mailInfo.rewardTb[j].rewardStatus = 0
        end
        G_event:NotifyEvent(G_eventDef.NET_MAIL_DETAILS_RESULT, cmdData)
    elseif testtype == 3 then
        cmdData.dwUserId = 2844137
        cmdData.mailId = param
        cmdData.dwSocketID = 0
        G_event:NotifyEvent(G_eventDef.NET_MAIL_DELETE_RESULT, cmdData)
    elseif testtype == 4 then
        cmdData.dwUserId = 2844137
        cmdData.mailId = param
        cmdData.dwSocketID = 0
        G_event:NotifyEvent(G_eventDef.NET_GET_MAIL_REWARD_RESULT, cmdData)
    end
end

return HallEmailLayer