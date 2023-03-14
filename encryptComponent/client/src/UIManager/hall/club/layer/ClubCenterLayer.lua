---------------------------------------------------
--Desc:俱乐部中心 0:俱乐部列表 1:俱乐部成员 2:俱乐部会长
--Date:2022-10-10 21:35:47
--Author:A*
---------------------------------------------------
local ClubCenterLayer = class("ClubCenterLayer",function ()
    local ClubCenterLayer = display.newLayer()
    return ClubCenterLayer
end)


ClubCenterLayer.NodeStatus = {
    ["NodeClubList"] = false,
    ["NodeNotice"]   = false,
    ["NodeEditNotice"] = false,
    ["NodeMember"]   = false,
    ["NodeAudit"] = false,
    ["NodeSet"]   = false,
    ["NodeComfirmBoxMid"] = false,
    ["NodeComfirmBoxMin"]   = false,
}

function ClubCenterLayer:onExit()
    --注销事件
    self:unregisterEvent()
end

function ClubCenterLayer:registerEvent()
    --1.1俱乐部列表    
    G_event:AddNotifyEvent(G_eventDef.EVENT_CLUBLISTDATA,handler(self,self.respondNodeClubList))
    --1.2申请记录列表
    G_event:AddNotifyEvent(G_eventDef.NET_REQUESTAGENTLIST,handler(self,self.respondAgentList))
    --1.3申请结果
    G_event:AddNotifyEvent(G_eventDef.EVENT_AGENTJOINRESULT,handler(self,self.respondAgentJoin))
    --2.1俱乐部详情
    G_event:AddNotifyEvent(G_eventDef.NET_GET_AGENT_DETAIL,handler(self,self.respondAgentDetail))
    --2.2修改公告结果
    G_event:AddNotifyEvent(G_eventDef.NET_UPDATENOTICE,handler(self,self.respondUpdateNotice))
    --2.2修改社交链接结果
    G_event:AddNotifyEvent(G_eventDef.NET_UPDATEURLRESULT,handler(self,self.respondUpdateNotice))
    --2.3成员列表
    G_event:AddNotifyEvent(G_eventDef.EVENT_MEMBERLISTDATA,handler(self,self.respondNodeMember))
    --2.3踢出成员结果
    G_event:AddNotifyEvent(G_eventDef.EVENT_AGENTKICKOUT,handler(self,self.respondAgentKickout))
    --2.3头像URL
    G_event:AddNotifyEventTwo(self,G_eventDef.EVENT_FACE_URL_RESULT,handler(self,self.respondFaceUrl))
    --2.4审核列表
    G_event:AddNotifyEvent(G_eventDef.EVENT_CLUBAUDITLIST,handler(self,self.respondNodeAudit))
    --2.4审核结果
    G_event:AddNotifyEvent(G_eventDef.EVENT_CLUBJOIRESULT,handler(self,self.respondAuditOperate))
    --2.5修改审核开关
    G_event:AddNotifyEvent(G_eventDef.EVENT_CLUBAUDITSET,handler(self,self.respondSetSwitch))
    --2.6退出俱乐部
    G_event:AddNotifyEvent(G_eventDef.EVENT_AGENTEXIT,handler(self,self.respondAgentExit))

end

function ClubCenterLayer:unregisterEvent()
    --1.1俱乐部列表
    G_event.RemoveNotifyEvent(G_eventDef.EVENT_CLUBLISTDATA)
    --1.2申请记录列表
    G_event.RemoveNotifyEvent(G_eventDef.NET_REQUESTAGENTLIST)
    --1.3申请结果
    G_event.RemoveNotifyEvent(G_eventDef.EVENT_AGENTJOINRESULT)
    --2.1俱乐部详情
    G_event:RemoveNotifyEvent(G_eventDef.NET_GET_AGENT_DETAIL)    
    --2.2修改公告结果
    G_event:RemoveNotifyEvent(G_eventDef.NET_UPDATENOTICE)
    --2.2修改社交链接结果
    G_event:RemoveNotifyEvent(G_eventDef.NET_UPDATEURLRESULT)
    --2.3成员列表
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_MEMBERLISTDATA)
    --2.3踢出成员结果
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_AGENTKICKOUT)
    --2.3头像URL
    G_event:RemoveNotifyEvent(self,G_eventDef.EVENT_FACE_URL_RESULT)
    --2.4审核列表
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_CLUBAUDITLIST)
    --2.4审核结果
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_CLUBJOIRESULT)
    --2.5修改审核开关
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_CLUBAUDITSET)
    --2.6退出俱乐部
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_AGENTEXIT)
end

function ClubCenterLayer:onClickClose()
    self.clubData:onExit()    
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() self:removeSelf() end)
end

function ClubCenterLayer:ctor(args)
       
    local parent = cc.Director:getInstance():getRunningScene()
    parent:addChild(self)
    
    local csbNode = g_ExternalFun.loadCSB("club/ClubCenterLayer.csb")
    csbNode:setContentSize(display.width,display.height)
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)    
    ccui.Helper:doLayout(csbNode)
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
    self.clubData =  appdf.req(appdf.CLIENT_SRC.."UIManager.hall.club.data.ClubData").new()
    self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)   
    self.headData = {}
    --初始化节点
    --初始化俱乐部列表
    self:initNodeClubList()
    --初始化公告节点
    self:initNodeNotice()
    --初始化修改公告节点
    self:initNodeEditNotice()
    --初始化成员列表节点
    self:initNodeMember()
    --初始化审核列表节点
    self:initNodeAudit()
    --初始化设置节点
    self:initNodeSet()
    --初始化确认框（确认+取消）
    -- self:initNodeComfirmBoxMid()
    --初始化确认框（确认）
    -- self:initNodeComfirmBoxMin()
    
    --注册事件
    self:registerEvent() 

    --根据参数修改界面展示，因为当前页面展示三类（俱乐部列表，俱乐部成员展示界面，俱乐部会长展示界面）
    self.ShowType = args.ShowType    
    self:refreshView()
end

--刷新界面展示 0:俱乐部列表 1:俱乐部成员 2:俱乐部会长
function ClubCenterLayer:refreshView()
    local pShowType = 0
    if self.ShowType == 1 then
        pShowType = GlobalUserItem.bIsAgentAccount and 2 or 1
    else
        pShowType = 0   
    end

    self.ShowType = pShowType

    --俱乐部底部栏
    self.mm_Panel_common:hide()
    --会长右侧按钮
    self.mm_Panel_agent:hide()
    --成员右侧按钮
    self.mm_Panel_member:hide()
    --游客右侧按钮
    self.mm_Panel_visitor_2:hide()
    --游客底部栏
    self.mm_Panel_visitor:hide()

    self.NodeList = {
        self.mm_NodeClubList,
        self.mm_NodeNotice,
        self.mm_NodeEditNotice,
        self.mm_NodeMember,
        self.mm_NodeAudit,
        self.mm_NodeSet,
        self.mm_NodeComfirmBoxMid,
        self.mm_NodeComfirmBoxMin,
    }
    --所有节点隐藏
    self:hideNodeList()

    if pShowType == 0 then     
        --游客右侧按钮
        self.mm_Panel_visitor_2:show()
        --游客底部栏
        self.mm_Panel_visitor:show()
        --客服按钮
        local btnConfig = {self.mm_Customer_whatsapp, self.mm_Customer_messenger, self.mm_Customer_telegram}
        for i, pBtn in ipairs(btnConfig) do
            pBtn:setTag(i)
            local firstEnabledUrl, strUrl = g_ExternalFun.getCustomerUrl(i)
            pBtn.strUrl = strUrl
            pBtn:setEnabled(firstEnabledUrl ~= "")
            pBtn:onClicked(handler(self, self.onCustomerClick))
        end        
        --请求已经申请过的俱乐部列表
        self:requestAgentList()
    else
        --俱乐部底部栏
        self.mm_Panel_common:setVisible(pShowType>0)
        --会长右侧按钮
        self.mm_Panel_agent:setVisible(pShowType==2)
        --成员右侧按钮
        self.mm_Panel_member:setVisible(pShowType==1)
        
        --操作按钮列表
        self.OperationList = {
            self.mm_Button_anuncio,
            self.mm_Button_userListAgent,
            self.mm_Button_joinCheck,
            self.mm_Button_seting,
            self.mm_Button_anuncio_2,
            self.mm_Button_userListMember,
            self.mm_Button_exitClub,
        }

        --右侧按钮注册点击事件
        self.mm_Button_anuncio:onClicked(handler(self,self.onOperationClick))
        self.mm_Button_userListAgent:onClicked(handler(self,self.onOperationClick))
        self.mm_Button_joinCheck:onClicked(handler(self,self.onOperationClick))
        g_redPoint:addRedPoint(g_redPoint.eventType.clubSub_1,self.mm_Button_joinCheck,cc.p(20,20))
        self.mm_Button_seting:onClicked(handler(self,self.onOperationClick))
        self.mm_Button_anuncio_2:onClicked(handler(self,self.onOperationClick))
        self.mm_Button_userListMember:onClicked(handler(self,self.onOperationClick))
        self.mm_Button_exitClub:onClicked(handler(self,self.onOperationClick))
        
        --请求俱乐部详情
        self:requestAgentDetail()

        --默认展示俱乐部公告节点
        self:onOperationClick(pShowType==1 and self.mm_Button_anuncio_2 or self.mm_Button_anuncio)
    end
end

function ClubCenterLayer:hideNodeList()
    for i, v in ipairs(self.NodeList) do
        v:hide()
    end
end

function ClubCenterLayer:onOperationClick(target)
    for i, v in ipairs(self.OperationList) do
        v:setEnabled(v~=target)        
    end
    self:hideNodeList()
    if target == self.mm_Button_anuncio or target == self.mm_Button_anuncio_2 then
        --公告按钮
        self.mm_NodeNotice:show()
    elseif target == self.mm_Button_userListMember or target == self.mm_Button_userListAgent then
        --玩家列表按钮
        self:requestMemberList(self.CurMemberPageIndex)
    elseif target == self.mm_Button_joinCheck then
        --审核列表按钮
        self:requestAuditList(self.CurMemberPageIndex)
    elseif target == self.mm_Button_seting then
        --设置按钮
        self.mm_NodeSet:show()
    elseif target == self.mm_Button_exitClub then
        --退出俱乐部按钮        
        local data = {
            comfirmCallback = function()
                self.clubData:C2S_requestAgentExit(self.agentDetailData.dwAgentID)
            end, 
            cancelCallback = function()
                self:onOperationClick(self.ShowType==1 and self.mm_Button_anuncio_2 or self.mm_Button_anuncio)
            end, 
            strContent = g_language:getString("club_tips_6"),
        }
        self:showNodeComfirmBoxMid(data)
    end
end

--初始化俱乐部列表节点
function ClubCenterLayer:initNodeClubList()
    self.CurClubListPageIndex =1
    self.ClubListData = {}
    self.TotalClubListPage = 1
    
    local pListView = self.mm_NodeClubList:getChildByName("ListView")
    local pListItem = pListView:getChildByName("itemModel")
    self.mm_ClubList_ListView = pListView
    self.mm_ClubList_Model = pListItem
    self.mm_ClubList_ListView:setItemModel(self.mm_ClubList_Model)
    self.mm_ClubList_ListView:setBounceEnabled(true) --滑动惯性
    self.mm_ClubList_ListView:setScrollBarEnabled(false)    
    self.mm_ClubList_ListView:removeAllItems()

    self.mm_ClubList_ImageNull = self.mm_NodeClubList:getChildByName("ImageNull")
    self.mm_ClubList_ImageNull:hide()
    self.mm_ClubList_PanelTop = self.mm_NodeClubList:getChildByName("Panel_top")    
    self.mm_ClubList_PanelBottom = self.mm_NodeClubList:getChildByName("Panel_bottom")
    --上一页
    self.mm_ClubList_PanelBottom_Up = self.mm_ClubList_PanelBottom:getChildByName("Button_pageUp")
    self.mm_ClubList_PanelBottom_Up:setTag(1)
    self.mm_ClubList_PanelBottom_Up:onClicked(handler(self,self.onNodeClubListPageClick))

    --下一页
    self.mm_ClubList_PanelBottom_Down = self.mm_ClubList_PanelBottom:getChildByName("Button_pageNext")
    self.mm_ClubList_PanelBottom_Down:setTag(2)
    self.mm_ClubList_PanelBottom_Down:onClicked(handler(self,self.onNodeClubListPageClick))

    --页码
    self.mm_ClubList_PanelBottom_Page = self.mm_ClubList_PanelBottom:getChildByName("Text_showPage")
    self.mm_ClubList_PanelBottom_Page:setText("")
end

--初始化公告节点
function ClubCenterLayer:initNodeNotice()    
    self.mm_Notice_Content = self.mm_NodeNotice:getChildByName("Text_content")
    self.mm_Notice_ImageNull = self.mm_NodeNotice:getChildByName("ImageNull")
    self.mm_Notice_ButtonModify = self.mm_NodeNotice:getChildByName("Button_modify")
    self.mm_Notice_ButtonModify:setVisible(GlobalUserItem.bIsAgentAccount)
    self.mm_Notice_ButtonModify:onClicked(function ()
        self:hideNodeList()
        self:showNodeEditNotice()        
    end)
end

--初始化修改公告节点
function ClubCenterLayer:initNodeEditNotice()
    local bg = self.mm_NodeEditNotice:getChildByName("Image_contentBg")
    --空文本提示框
    self.mm_EditNotice_PlaceHolder = bg:getChildByName("Text_PlaceHolder")
    --文本输入框
    local TextField_content = bg:getChildByName("TextField_content")
    self.mm_EditNotice_TextField = TextField_content:convertToEditBox(cc.EDITBOX_INPUT_MODE_ANY)
    self.mm_EditNotice_TextField:setMaxLength(500)

    --文本输入框注册事件
    self.mm_EditNotice_TextField:registerScriptEditBoxHandler(function(eventType,pObj) 
        if eventType == "ended" then
            local str = pObj:getText() 
            if str == "" or str == nil then 
                self.mm_EditNotice_PlaceHolder:show()
            else
                self.mm_EditNotice_PlaceHolder:hide()
            end
        end
    end)

    --whatsapp 节点
    self.mm_EditNotice_Whatsapp = self.mm_NodeEditNotice:getChildByName("Node2")
    local input2 = self.mm_EditNotice_Whatsapp:getChildByName("input2")
    self.mm_EditNotice_Whatsapp_input = input2:convertToEditBox(cc.EDITBOX_INPUT_MODE_URL)
    self.mm_EditNotice_Whatsapp_input:setMaxLength(500)    
    self.mm_EditNotice_Whatsapp_state = self.mm_EditNotice_Whatsapp:getChildByName("state2")
    self.mm_EditNotice_Whatsapp_state:show()
    self.mm_EditNotice_Whatsapp_input:registerScriptEditBoxHandler(function(eventType,pObj) 
        if eventType == "ended" or eventType == "changed" then
            self:refreshNodeEditNoticeState()
        end
    end)

    --messenger 节点
    self.mm_EditNotice_Messenger = self.mm_NodeEditNotice:getChildByName("Node3")
    local input3 = self.mm_EditNotice_Messenger:getChildByName("input3")
    self.mm_EditNotice_Messenger_input = input3:convertToEditBox(cc.EDITBOX_INPUT_MODE_URL)
    self.mm_EditNotice_Messenger_input:setMaxLength(500)
    self.mm_EditNotice_Messenger_state = self.mm_EditNotice_Messenger:getChildByName("state3")
    self.mm_EditNotice_Messenger_state:show()
    self.mm_EditNotice_Messenger_input:registerScriptEditBoxHandler(function(eventType,pObj) 
        if eventType == "ended" or eventType == "changed" then
            self:refreshNodeEditNoticeState()
        end
    end)

    --telegram 节点
    self.mm_EditNotice_Telegram = self.mm_NodeEditNotice:getChildByName("Node1")
    local input1 = self.mm_EditNotice_Telegram:getChildByName("input1")
    self.mm_EditNotice_Telegram_input = input1:convertToEditBox(cc.EDITBOX_INPUT_MODE_URL)
    self.mm_EditNotice_Telegram_input:setMaxLength(500)
    self.mm_EditNotice_Telegram_state = self.mm_EditNotice_Telegram:getChildByName("state1")
    self.mm_EditNotice_Telegram_state:show()
    self.mm_EditNotice_Telegram_input:registerScriptEditBoxHandler(function(eventType,pObj) 
        if eventType == "ended" or eventType == "changed" then
            self:refreshNodeEditNoticeState()
        end
    end)

    --确认按钮
    self.mm_EditNotice_ButtonSure = self.mm_NodeEditNotice:getChildByName("btnSure")
    self.mm_EditNotice_ButtonSure:onClicked(handler(self,self.comfirmEditNotice))
end

--初始化成员列表节点
function ClubCenterLayer:initNodeMember()
    self.CurMemberPageIndex = 1
    self.MemberData = {}
    self.TotalMemberPage = 1

    local pListView = self.mm_NodeMember:getChildByName("ListView")

    local pListItemNormal = pListView:getChildByName("itemModelNormal")
    local pListItemCreator = pListView:getChildByName("itemModelCreator")
    self.mm_Member_ListView = pListView
    self.mm_Member_Model = GlobalUserItem.bIsAgentAccount and pListItemCreator or pListItemNormal
    self.mm_Member_ListView:setItemModel(self.mm_Member_Model)
    self.mm_Member_ListView:setBounceEnabled(true) --滑动惯性
    self.mm_Member_ListView:setScrollBarEnabled(false)
    self.mm_Member_ListView:removeAllItems()

    self.mm_Member_ImageNull = self.mm_NodeMember:getChildByName("ImageNull")
    self.mm_Member_ImageNull:hide()
    self.mm_Member_PanelTop_Normal = self.mm_NodeMember:getChildByName("Panel_top_nomal")
    self.mm_Member_PanelTop_Normal:setVisible(not GlobalUserItem.bIsAgentAccount)
    self.mm_Member_PanelTop_Creator = self.mm_NodeMember:getChildByName("Panel_top_creator")
    self.mm_Member_PanelTop_Creator:setVisible(GlobalUserItem.bIsAgentAccount)
    self.mm_Member_PanelBottom = self.mm_NodeMember:getChildByName("Panel_bottom")
    --上一页
    self.mm_Member_PanelBottom_Up = self.mm_Member_PanelBottom:getChildByName("Button_pageUp")
    self.mm_Member_PanelBottom_Up:setTag(1)
    self.mm_Member_PanelBottom_Up:onClicked(handler(self,self.onNodeMemberPageClick))

    --下一页
    self.mm_Member_PanelBottom_Down = self.mm_Member_PanelBottom:getChildByName("Button_pageNext")
    self.mm_Member_PanelBottom_Down:setTag(2)
    self.mm_Member_PanelBottom_Down:onClicked(handler(self,self.onNodeMemberPageClick))

    --页码
    self.mm_Member_PanelBottom_Page = self.mm_Member_PanelBottom:getChildByName("Text_showPage")
    self.mm_Member_PanelBottom_Page:setText("")

end

--初始化审核列表节点
function ClubCenterLayer:initNodeAudit()
    self.CurAuditPageIndex = 1
    self.AuditData = {}
    self.TotalAuditPage = 1

    local pListView = self.mm_NodeAudit:getChildByName("ListView")
    local pListItem = pListView:getChildByName("itemModel")
    self.mm_Audit_ListView = pListView
    self.mm_Audit_Model = pListItem
    self.mm_Audit_ListView:setItemModel(self.mm_Audit_Model)
    self.mm_Audit_ListView:setBounceEnabled(true) --滑动惯性
    self.mm_Audit_ListView:setScrollBarEnabled(false)
    self.mm_Audit_ListView:removeAllItems()

    self.mm_Audit_ImageNull = self.mm_NodeAudit:getChildByName("ImageNull")
    self.mm_Audit_ImageNull:hide()
    self.mm_Audit_PanelTop = self.mm_NodeAudit:getChildByName("Panel_top")
    self.mm_Audit_PanelBottom = self.mm_NodeAudit:getChildByName("Panel_bottom")
    --上一页
    self.mm_Audit_PanelBottom_Up = self.mm_Audit_PanelBottom:getChildByName("Button_pageUp")
    self.mm_Audit_PanelBottom_Up:setTag(1)
    self.mm_Audit_PanelBottom_Up:onClicked(handler(self,self.onNodeAuditPageClick))

    --下一页
    self.mm_Audit_PanelBottom_Down = self.mm_Audit_PanelBottom:getChildByName("Button_pageNext")
    self.mm_Audit_PanelBottom_Down:setTag(2)
    self.mm_Audit_PanelBottom_Down:onClicked(handler(self,self.onNodeAuditPageClick))

    --页码
    self.mm_Audit_PanelBottom_Page = self.mm_Audit_PanelBottom:getChildByName("Text_showPage")
    self.mm_Audit_PanelBottom_Page:setText("")
end

--初始化设置节点
function ClubCenterLayer:initNodeSet()
    self.mm_btnAuditOpen = self.mm_NodeSet:getChildByName("btnAuditOpen")
    self.mm_btnAuditOpen:setTag(0)
    self.mm_btnAuditOpen:onClicked(handler(self,self.onSwitchAuditClick))
    self.mm_btnAuditClose = self.mm_NodeSet:getChildByName("btnAuditClose")
    self.mm_btnAuditClose:setTag(1)
    self.mm_btnAuditClose:onClicked(handler(self,self.onSwitchAuditClick))
end

--1.俱乐部列表 Start---------------------------------------------------------------------------
--请求自己已申请的俱乐部列表
function ClubCenterLayer:requestAgentList()
    self.clubData:C2S_requestAgentList()
end

--返回自己已申请的列表，后续会拉取俱乐部列表
function ClubCenterLayer:respondAgentList(data)
    self.AgentListData = data
    self:requestNodeClubList(1)
end

--请求俱乐部列表
function ClubCenterLayer:requestNodeClubList(curPageIndex)    
    if self.ClubListData[curPageIndex] then
        self:respondNodeClubList(self.ClubListData[curPageIndex])
    else
        self.clubData:C2S_requestClubList(20,curPageIndex)
    end
end

--返回俱乐部列表
function ClubCenterLayer:respondNodeClubList(data)
    --游客进入，展示俱乐部列表
    self.mm_NodeClubList:show()
    self.CurClubListPageIndex = data.dwPageIndex
    -- print("self.CurClubListPageIndex = ",self.CurClubListPageIndex)
    self.TotalClubListPage = data.dwPageCount   
    -- print("self.TotalClubListPage = ",self.TotalClubListPage)

    --设置页码
    self.mm_ClubList_PanelBottom_Page:setText(self.CurClubListPageIndex.."/"..self.TotalClubListPage)
    --设置翻页状态
    self.mm_ClubList_PanelBottom_Up:setEnabled(self.CurClubListPageIndex>1)
    self.mm_ClubList_PanelBottom_Down:setEnabled(self.CurClubListPageIndex<self.TotalClubListPage)
    
    self.ClubListData[self.CurClubListPageIndex] = {}
    self.ClubListData[self.CurClubListPageIndex] = data.lsItems
    if data.dwCount < data.dwPageSize then
        self.mm_ClubList_ListView:removeAllItems()
    end

    for k=1,data.dwPageSize do
        local item = self.mm_ClubList_ListView:getItem(k-1)
        if not item and k <= data.dwCount then
            self.mm_ClubList_ListView:pushBackDefaultItem()
            item = self.mm_ClubList_ListView:getItem(k-1)
        end
        if not item then
            break 
        end
        if k <= data.dwCount then
            item:show()
            item:getChildByName("textClubName"):setString(data.lsItems[k].szAgentName)
            item:getChildByName("textClubID"):setString(data.lsItems[k].dwAgentID)
            item:getChildByName("textAgentName"):setString(data.lsItems[k].szNickName)
            local btn = item:getChildByName("Button_join")
            local inreview  = item:getChildByName("Image_inreview")
            if self.AgentListData.dwCount > 0 then
                for i,v in ipairs(self.AgentListData.lsItems) do
                    if data.lsItems[k].dwAgentID == v.dwAgentID then
                        btn:hide()
                        inreview:show()
                    end
                end
            end
            btn:onClicked(function() 
                self.clubData:C2S_requestJoinClub(data.lsItems[k].dwAgentID)
                item:getChildByName("Image_inreview"):show()
                btn:hide()
            end)
            item:setTag(data.lsItems[k].dwAgentID)
        else
            item:hide()
        end
    end
    self.mm_ClubList_ListView:jumpToTop()

    if data.dwCount <= 0 then
        self.mm_ClubList_PanelTop:hide()
        self.mm_ClubList_ListView:hide()
        self.mm_ClubList_PanelBottom:hide()
        self.mm_ClubList_ImageNull:show()
    else
        self.mm_ClubList_PanelTop:show() 
        self.mm_ClubList_ListView:show()
        self.mm_ClubList_PanelBottom:show()
        self.mm_ClubList_ImageNull:hide()
    end    
end

--俱乐部列表翻页按钮响应
function ClubCenterLayer:onNodeClubListPageClick(target)
    local pTag = target:getTag()
    local result = self.CurClubListPageIndex
    if pTag == 1 then
        result = result - 1
    elseif pTag == 2 then
        result = result + 1
    end
    if result <= 0 or result > self.TotalClubListPage then
        return 
    end
    self:requestNodeClubList(result)
end

--返回申请加入俱乐部结果
function ClubCenterLayer:respondAgentJoin(data)
    if data.dwStatus == 1 then
        GlobalUserItem.dwAgentID = data.dwAgentID
        --成功
        local data = {
            comfirmCallback = function()   
                self.ShowType = 1
                self:refreshView()
            end, 
            strContent = g_language:getString("club_tips_1"),
        }
        self:showNodeComfirmBoxMin(data)
    else
        --需要审核
        local data = {
            strContent = g_language:getString("club_tips_2"),
        }
        self:showNodeComfirmBoxMin(data)
    end
end
--1.俱乐部列表 End-----------------------------------------------------------------------------

--2.俱乐部界面 Start---------------------------------------------------------------------------
--2.1请求俱乐部详情
function ClubCenterLayer:requestAgentDetail()
    self.clubData:C2S_requestAgentDetail()
end     

--2.1俱乐部详情
function ClubCenterLayer:respondAgentDetail(data)
    dismissNetLoading()
    self.agentDetailData = data
    if self.agentDetailData.dwAgentID == 0 then
        GlobalUserItem.dwAgentID = 0
        --你已被踢出俱乐部
        local data = {
            comfirmCallback = function()
                self:onClickClose()
            end, 
            strContent = g_language:getString("club_tips_4"),
        }
        self:showNodeComfirmBoxMin(data)
    end

    --NodeNotice    
    self:refreshNodeNotice()

    --NodeSet
    self:refreshNodeSet()

    --Panel_common
    self.mm_Text_clubName:setString(data.szAgentName)
    self.mm_Text_clubID:setString(data.dwAgentID)    
    self.mm_Club_telegram:setEnabled(data.TelegramURL and data.TelegramURL~="")
    self.mm_Club_telegram:setTag(1)
    self.mm_Club_telegram:onClicked(handler(self,self.onSocialClick))
    self.mm_Club_whatsapp:setEnabled(data.WhatsAppURL and data.WhatsAppURL~="")
    self.mm_Club_whatsapp:setTag(2)
    self.mm_Club_whatsapp:onClicked(handler(self,self.onSocialClick))
    self.mm_Club_messenger:setEnabled(data.MessengerURL and data.MessengerURL~="")
    self.mm_Club_messenger:setTag(3)
    self.mm_Club_messenger:onClicked(handler(self,self.onSocialClick))
end

--2.1刷新俱乐部公告节点
function ClubCenterLayer:refreshNodeNotice()    
    self.mm_Notice_Content:setString(self.agentDetailData.szNotice)    
    self.mm_Notice_ImageNull:setVisible(self.agentDetailData.szNotice=="")    
end

--2.2展示俱乐部公告修改节点
function ClubCenterLayer:showNodeEditNotice()
    self.mm_NodeEditNotice:show()
    self:refreshNodeEditNotice()
end

--2.2刷新俱乐部公告修改节点
function ClubCenterLayer:refreshNodeEditNotice()
    --公告内容
    self.mm_EditNotice_TextField:setText(self.agentDetailData.szNotice)
    self.mm_EditNotice_PlaceHolder:setVisible(self.mm_EditNotice_TextField:getText() == "")
    
    --社交链接
    self.mm_EditNotice_Whatsapp_input:setText(self.agentDetailData.WhatsAppURL)
    self.mm_EditNotice_Messenger_input:setText(self.agentDetailData.MessengerURL)
    self.mm_EditNotice_Telegram_input:setText(self.agentDetailData.TelegramURL)

    --刷新社交链接状态
    self:refreshNodeEditNoticeState()
end

--2.2刷新社交链接状态
function ClubCenterLayer:refreshNodeEditNoticeState()
    --社交链接以及状态
    local pStateDiff = "club/GUI/state_2.png"
    local pStateSame = "club/GUI/state_1.png"

    local str
    str = self.mm_EditNotice_Whatsapp_input:getText()
    self.mm_EditNotice_Whatsapp_state:loadTexture(str==self.agentDetailData.WhatsAppURL and pStateSame or pStateDiff)
    str = self.mm_EditNotice_Messenger_input:getText()
    self.mm_EditNotice_Messenger_state:loadTexture(str==self.agentDetailData.MessengerURL and pStateSame or pStateDiff)
    str = self.mm_EditNotice_Telegram_input:getText()
    self.mm_EditNotice_Telegram_state:loadTexture(str==self.agentDetailData.TelegramURL and pStateSame or pStateDiff)            
end

--2.2确认修改俱乐部公告节点
function ClubCenterLayer:comfirmEditNotice()
    --更新俱乐部公告
    local pNewNoticeStr = self.mm_EditNotice_TextField:getText()
    local pOldNoticeStr = self.agentDetailData.szNotice
    if pNewNoticeStr and pOldNoticeStr and pNewNoticeStr ~= pOldNoticeStr then
        self.clubData:C2S_requestUpdateNotice(self.agentDetailData.dwCreatorUserID,self.agentDetailData.dwAgentID,pNewNoticeStr)
    end
    local pURL1 = self.mm_EditNotice_Telegram_input:getText()    
    local pURL2 = self.mm_EditNotice_Whatsapp_input:getText()    
    local pURL3 = self.mm_EditNotice_Messenger_input:getText()    
    if pURL1 and self.agentDetailData.TelegramURL and self.agentDetailData.TelegramURL~=pURL1 then
        self.clubData:C2S_requestUpdateURL(self.agentDetailData.dwAgentID,1,pURL1)    
    end
    if pURL2 and self.agentDetailData.WhatsAppURL and self.agentDetailData.WhatsAppURL~=pURL2 then
        self.clubData:C2S_requestUpdateURL(self.agentDetailData.dwAgentID,2,pURL2)    
    end
    if pURL3 and self.agentDetailData.MessengerURL and self.agentDetailData.MessengerURL~=pURL3 then
        self.clubData:C2S_requestUpdateURL(self.agentDetailData.dwAgentID,3,pURL3)    
    end

    self:hideNodeList()
    self.mm_NodeNotice:show()
end

--2.2修改俱乐部公告结果
function ClubCenterLayer:respondUpdateNotice(pData)
    if pData.dwErrorCode == 0 then        
        self:requestAgentDetail()
    end
end

--2.3俱乐部成员列表翻页按钮响应
function ClubCenterLayer:onNodeMemberPageClick(target)
    local pTag = target:getTag()
    local result = self.CurMemberPageIndex
    if pTag == 1 then
        result = result - 1
    elseif pTag == 2 then
        result = result + 1
    end
    if result <= 0 or result > self.TotalMemberPage then
        return 
    end
    self:requestMemberList(result,true)
end

--2.3请求成员列表
function ClubCenterLayer:requestMemberList(curPageIndex,isNotRequest)
    -- isNotRequest = isNotRequest or false
    -- if self.MemberData[curPageIndex] and isNotRequest then
    --     self:respondNodeMember(self.MemberData[curPageIndex])
    -- else
        self.clubData:C2S_requestMemberList(5,curPageIndex,GlobalUserItem.dwAgentID)        
    -- end
end

--2.3返回俱乐部成员列表
function ClubCenterLayer:respondNodeMember(data)    
    self.mm_NodeMember:show()
    self.CurMemberPageIndex = data.dwPageIndex
    self.TotalMemberPage = data.dwPageCount

    -- --设置页码
    self.mm_Member_PanelBottom_Page:setText(self.CurMemberPageIndex.."/"..self.TotalMemberPage)
    -- --设置翻页状态
    self.mm_Member_PanelBottom_Up:setEnabled(self.CurMemberPageIndex>1)
    self.mm_Member_PanelBottom_Down:setEnabled(self.CurMemberPageIndex<self.TotalMemberPage)
    
    self.MemberData[self.CurMemberPageIndex] = {}
    self.MemberData[self.CurMemberPageIndex] = data
    if data.dwCount < data.dwPageSize then
        self.mm_Member_ListView:removeAllItems()
    end

    local gameidList = {}
    for k=1,data.dwPageSize do
        local item = self.mm_Member_ListView:getItem(k-1)
        if not item and k <= data.dwCount then
            self.mm_Member_ListView:pushBackDefaultItem()
            item = self.mm_Member_ListView:getItem(k-1)
        end
        if not item then
            break 
        end
        if k <= data.dwCount then
            item:show()
            --头像
            local gameID = data.lsItems[k].dwGameID
            local faceID = data.lsItems[k].wFaceID
            local imgHead = item:getChildByName("imghead")
            self.headData[gameID] = {}
            self.headData[gameID].headImg = HeadSprite.loadHeadImg(imgHead,gameID,faceID,true)
            if faceID == 0 then
                table.insert(gameidList,gameID)
            end
            --昵称
            local nameStr,isShow = g_ExternalFun.GetFixLenOfString(data.lsItems[k].szNickName,160,"arial",24)
            item:getChildByName("textName"):setString(isShow and nameStr or nameStr.."...")
            --ID
            item:getChildByName("textGameID"):setString("ID:" .. gameID)
            --会长标志
            local headTag = item:getChildByName("imgtag")
            headTag:setVisible(data.lsItems[k].wMemberOrder == 1)
            --入会时间
            local textTime = item:getChildByName("textTime")
            local T = DateUtil.getBrazilTimeString(data.lsItems[k].lJoinDate)
            local timeStr = string.format("%s %s %s %s:%s", T.d, T.m, T.y, T.hour, T.min)
            textTime:setString(timeStr)  --时间戳
            --操作按钮
            local btn = item:getChildByName("ButtonExit")
            if btn then
                --自己不操作
                btn:setVisible(data.lsItems[k].dwUserID ~= GlobalUserItem.dwUserID)
                btn:onClicked(function() 
                    local str = g_language:getString("club_tips_3")
                    local name = data.lsItems[k].szNickName
                    local tempStr = string.format(str,name)
                    --是否踢出成员
                    local data = {
                        comfirmCallback = function()
                            local clubInfo = self.agentDetailData
                            self.clubData:C2S_requestKickout(clubInfo.dwCreatorUserID,clubInfo.dwAgentID,data.lsItems[k].dwUserID)
                            self.kickoutItem = item
                        end, 
                        cancelCallback = function()
                            
                        end, 
                        strContent = string.format(g_language:getString("club_tips_3"),data.lsItems[k].szNickName),
                    }
                    self:showNodeComfirmBoxMid(data)                    
                end)
            end
            item:setTag(data.lsItems[k].dwUserID)
        else
            item:hide()
        end
    end
    if not table.isEmpty(gameidList) then
        G_ServerMgr:C2S_requestHeadUrl(gameidList)
    end
    
    self.mm_Member_ListView:jumpToTop()    
    
    if data.dwCount <= 0 then
        self.mm_Member_PanelTop_Normal:hide()
        self.mm_Member_PanelTop_Creator:hide()
        self.mm_Member_ListView:hide()
        self.mm_Member_PanelBottom:hide()
        self.mm_Member_ImageNull:show()
    else
        self.mm_Member_PanelTop_Normal:setVisible(not GlobalUserItem.bIsAgentAccount)    
        self.mm_Member_PanelTop_Creator:setVisible(GlobalUserItem.bIsAgentAccount)
        self.mm_Member_ListView:show()
        self.mm_Member_PanelBottom:show()
        self.mm_Member_ImageNull:hide()
    end 
end

--2.3返回头像链接
function ClubCenterLayer:respondFaceUrl(data)
    for gameid,url in pairs(data.userData) do
        if self.headData[gameid] then
            self.headData[gameid].headURL = url
            HeadSprite.loadHeadUrl(self.headData[gameid].headImg,gameid,url)
        end
    end
end

--2.3返回踢出成员结果
function ClubCenterLayer:respondAgentKickout(data)
    if data.dwErrorCode == 0 then
        self:requestMemberList(self.CurMemberPageIndex)
    end
end

--2.4俱乐部审核列表翻页按钮响应
function ClubCenterLayer:onNodeAuditPageClick(target)
    local pTag = target:getTag()
    local result = self.CurAuditPageIndex
    if pTag == 1 then
        result = result - 1
    elseif pTag == 2 then
        result = result + 1
    end
    if result <= 0 or result > self.TotalAuditPage then
        return 
    end
    self:requestAuditList(result,true)
end

--2.4请求审核列表
function ClubCenterLayer:requestAuditList(curPageIndex,isNotRequest)
    -- isNotRequest = isNotRequest or false
    -- if self.AuditData[curPageIndex] and isNotRequest then
    --     self:respondNodeAudit(self.AuditData[curPageIndex])
    -- else
        self.clubData:C2S_requestAuditList(self.agentDetailData.dwCreatorUserID,self.agentDetailData.dwAgentID,10,curPageIndex)     
    -- end
end

--2.4返回俱乐部审核列表
function ClubCenterLayer:respondNodeAudit(data)  
    self.mm_NodeAudit:show()
    self.CurAuditPageIndex = data.dwPageIndex
    self.TotalAuditPage = data.dwPageCount

    -- --设置页码
    self.mm_Audit_PanelBottom_Page:setText(self.CurAuditPageIndex.."/"..self.TotalAuditPage)
    -- --设置翻页状态
    self.mm_Audit_PanelBottom_Up:setEnabled(self.CurAuditPageIndex>1)
    self.mm_Audit_PanelBottom_Down:setEnabled(self.CurAuditPageIndex<self.TotalAuditPage)

    self.AuditData[self.CurAuditPageIndex] = {}
    self.AuditData[self.CurAuditPageIndex] = data
    if data.dwCount < data.dwPageSize then
        self.mm_Audit_ListView:removeAllItems()
    end

    local gameidList = {}
    for k=1,data.dwPageSize do
        local item = self.mm_Audit_ListView:getItem(k-1)
        if not item and k <= data.dwCount then
            self.mm_Audit_ListView:pushBackDefaultItem()
            item = self.mm_Audit_ListView:getItem(k-1)
        end
        if not item then
            break 
        end
        if k <= data.dwCount then
            item:show()  
            --头像          
            local gameID = data.lsItems[k].dwGameID
            local faceID = data.lsItems[k].wFaceID
            local imgHead = item:getChildByName("imghead")
            self.headData[gameID] = {}
            self.headData[gameID].headImg = HeadSprite.loadHeadImg(imgHead,gameID,faceID,true)
            if faceID == 0 then
                table.insert(gameidList,gameID)
            end
            --昵称
            local nameStr,isShow = g_ExternalFun.GetFixLenOfString(data.lsItems[k].szNickName,160,"arial",24)
            item:getChildByName("textName"):setString(isShow and nameStr or nameStr.."...")
            --ID
            item:getChildByName("textID"):setString("ID:" .. data.lsItems[k].dwGameID)
            --申请时间
            local textTime = item:getChildByName("textTime")
            local T = DateUtil.getBrazilTimeString(data.lsItems[k].requestTime)
            local timeStr = string.format("%s %s %s %s:%s", T.d, T.m, T.y, T.hour, T.min)
            textTime:setString(timeStr)  --时间戳
            --操作按钮
            local pBtnReject = item:getChildByName("btnCancel")
            pBtnReject:setTag(data.lsItems[k].dwUserID)
            pBtnReject:onClicked(handler(self,self.onRejectClick))
            
            local pBtnAgree = item:getChildByName("btnSure")
            pBtnAgree:setTag(data.lsItems[k].dwUserID)
            pBtnAgree:onClicked(handler(self,self.onAgreeClick))
        else
            item:hide()
        end
    end
    if not table.isEmpty(gameidList) then
        G_ServerMgr:C2S_requestHeadUrl(gameidList)
    end
    
    self.mm_Audit_ListView:jumpToTop()

    if data.dwCount <= 0 then
        self.mm_Audit_PanelTop:hide()
        self.mm_Audit_ListView:hide()
        self.mm_Audit_PanelBottom:hide()
        self.mm_Audit_ImageNull:show()
    else
        self.mm_Audit_PanelTop:show()        
        self.mm_Audit_ListView:show()
        self.mm_Audit_PanelBottom:show()
        self.mm_Audit_ImageNull:hide()
    end 
end

--2.4拒绝申请点击
function ClubCenterLayer:onRejectClick(target)
    local pUserID = target:getTag()
    self.clubData:C2S_requestAgentRefuse(self.agentDetailData.dwCreatorUserID,self.agentDetailData.dwAgentID,pUserID)
    g_redPoint:dispatch(g_redPoint.eventType.clubSub_1,false)
end

--2.4同意申请点击
function ClubCenterLayer:onAgreeClick(target)
    local pUserID = target:getTag()
    self.clubData:C2S_requestAgentAccept(self.agentDetailData.dwCreatorUserID,self.agentDetailData.dwAgentID,pUserID)
    g_redPoint:dispatch(g_redPoint.eventType.clubSub_1,false)
end

--2.4审核操作结果返回
function ClubCenterLayer:respondAuditOperate(args)
    -- print("==================args.dwErrorCode:",args.dwErrorCode)
    -- if args.dwErrorCode == 0 then
        self:requestAuditList(self.CurAuditPageIndex)
    -- end
end

--2.5审核设置按钮点击
function ClubCenterLayer:onSwitchAuditClick(target)
    local pTag = target:getTag()
    self.clubData:C2S_requestSetSwitch(self.agentDetailData.dwCreatorUserID,self.agentDetailData.dwAgentID,pTag)
end

--2.5审核设置结果返回
function ClubCenterLayer:respondSetSwitch(data)
    if data.dwErrorCode == 0 then
        self:requestAgentDetail()
    end
end

--2.5刷新设置界面
function ClubCenterLayer:refreshNodeSet()
    self.mm_btnAuditOpen:setVisible(self.agentDetailData.dwNeedConfirm==1)
    self.mm_btnAuditClose:setVisible(self.agentDetailData.dwNeedConfirm==0)
end


--2.俱乐部界面 End-----------------------------------------------------------------------------

function ClubCenterLayer:respondAgentExit(data)
    if data.dwErrorCode == 0 then
        GlobalUserItem.dwAgentID = 0
        --成功退出俱乐部
        local data = {
            comfirmCallback = function()
                self:onClickClose()
            end, 
            strContent = g_language:getString("club_tips_8"),
        }
        self:showNodeComfirmBoxMin(data)
    end
end

--俱乐部列表界面，客服按钮点击响应
function ClubCenterLayer:onCustomerClick(target)
    local pTag = target:getTag()
    local urlKey = string.format("custom_type_%d_%d", pTag, GlobalUserItem.dwUserID)
    cc.UserDefault:getInstance():setStringForKey(urlKey, target.strUrl)
    OSUtil.openURL(target.strUrl)
end

--俱乐部界面，社交按钮点击响应
function ClubCenterLayer:onSocialClick(target)
    local pIndex = target:getTag()
    local pURL
    if pIndex == 1 then
        pURL = self.agentDetailData.TelegramURL
    elseif pIndex == 2 then
        pURL = self.agentDetailData.WhatsAppURL
    elseif pIndex == 3 then
        pURL = self.agentDetailData.MessengerURL
    end
    if pURL and pURL~="" then
        OSUtil.openURL(pURL)
    end
end

--隐藏普通节点
function ClubCenterLayer:hideNormalNodes()
    for k, v in pairs(self.NodeStatus) do
        local pItem = self.mm_content:getChildByName(k)
        self.NodeStatus[k] = pItem:isVisible() 
        pItem:hide()
    end
end

--还原上一次节点
function ClubCenterLayer:reductionNodes()
    for k, v in pairs(self.NodeStatus) do
        self.mm_content:getChildByName(k):setVisible(v) 
    end
end

--只有确认按钮的提示
function ClubCenterLayer:showNodeComfirmBoxMin(pData)
    self:hideNormalNodes()
    self.mm_NodeComfirmBoxMin:show()
    local pContent = self.mm_NodeComfirmBoxMin:getChildByName("Text_content")
    pContent:setString(pData.strContent)
    local pBtnComfirm = self.mm_NodeComfirmBoxMin:getChildByName("Button_comfirm")    
    pBtnComfirm:onClicked(function()
        self:reductionNodes()
        if pData and pData.comfirmCallback then
            pData.comfirmCallback()
        end        
    end)
end

--确认和取消按钮的提示
function ClubCenterLayer:showNodeComfirmBoxMid(pData)
    self:hideNormalNodes()
    self.mm_NodeComfirmBoxMid:show()
    local pContent = self.mm_NodeComfirmBoxMid:getChildByName("Text_content")
    pContent:setString(pData.strContent)
    local pBtnComfirm = self.mm_NodeComfirmBoxMid:getChildByName("Button_comfirm")    
    pBtnComfirm:onClicked(function()
        self:reductionNodes()
        if pData and pData.comfirmCallback then
            pData.comfirmCallback()
        end
    end)
    local pBtnCancel = self.mm_NodeComfirmBoxMid:getChildByName("Button_cancel")    
    pBtnCancel:onClicked(function()
        self:reductionNodes()
        if pData and pData.cancelCallback then
            pData.cancelCallback()
        end
    end)
end

return ClubCenterLayer