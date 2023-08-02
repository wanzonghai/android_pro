

--任务
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
local HallTableViewUIConfig = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HallTableViewUIConfig")
local HallTaskLayer = class("HallTaskLayer",function(args)
    local HallTaskLayer =  display.newLayer()
    return HallTaskLayer
end)



local btnType3 = {
    left = cc.p(-324,264),
    right = cc.p(324,264)
}

local btnType2 = {
    left = cc.p(-164,264),
    right = cc.p(172,264)
}

local listViewHeight = {650,570}

function HallTaskLayer:onExit()    
    G_event:RemoveNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_PROGRESS)
    G_event:RemoveNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_SUCCESS)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_TASK_LIST_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_TASK_REWARD_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_GAMESCENEFINISH)

    G_event:RemoveNotifyEvent(G_eventDef.EVENT_TASK_ACTIVENESS_CONFIG)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_TASK_ITEM_DATA_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_TASK_A_REWARD_RESULT)
end

function HallTaskLayer:ctor(args)
    self._scene = args.scene
    local parent = cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("task/TaskLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg,self.mm_content)
    self.mm_bg:onClicked(handler(self,self.onClickClose),true)
    self.mm_btnClose:onClicked(handler(self,self.onClickClose),true)
    self.mm_ListView:setItemModel(self.mm_itemModel)
    self.mm_ListView:setBounceEnabled(true) --滑动惯性
    self.mm_ListView:setScrollBarEnabled(false)
    self.mm_Image_barbg:hide()
    for i=1,4 do
        self["mm_Panel_item_"..i]:hide()
    end

    self:initNode()
    self:getMyIP()
    G_event:AddNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_PROGRESS,handler(self,self.OnUpdateDownProgress))  --下载进度更新 OnUpdateDownProgress
    G_event:AddNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_SUCCESS,handler(self,self.OnUpdateDownSuccess))  --下载进度更新
    G_event:AddNotifyEvent(G_eventDef.EVENT_TASK_LIST_RESULT,handler(self,self.onTaskListCallback))   --任务列表
    G_event:AddNotifyEvent(G_eventDef.EVENT_TASK_REWARD_RESULT,handler(self,self.onTaskRewardCallback))   --任务完成
    G_event:AddNotifyEvent(G_eventDef.EVENT_GAMESCENEFINISH,handler(self,self.onEnterGameFinishCallback))   --进入游戏完成
    G_event:AddNotifyEvent(G_eventDef.EVENT_TASK_ACTIVENESS_CONFIG,handler(self,self.onActivenessConfigCallback))   --任务活跃度配置数据
    G_event:AddNotifyEvent(G_eventDef.EVENT_TASK_ITEM_DATA_RESULT,handler(self,self.onItemDataCallback))   --任务活跃度item数据
    G_event:AddNotifyEvent(G_eventDef.EVENT_TASK_A_REWARD_RESULT,handler(self,self.onActivenessRewardCallback))   --领取活跃度item奖励
    G_ServerMgr:C2S_RequestTaskList()
    self:initActivenessTest()
end

function HallTaskLayer:onTaskListCallback(data)
    G_ServerMgr:C2S_RequestUserGold()
    if data.dwErrorCode > 0 then 
        print(g_language:getString(data.dwErrorCode,"zh"))
        return 
    end

    if self.taskRewardValue and self.taskRewardValue > 0 then
        self:showAward(self.taskRewardValue,"client/res/public/mrrw_icon_da.png")
        self.taskRewardValue = nil

        if data.dwCount == 1 then
            if data.lsItems[1].iTaskStatus == 3 then
                if self.nodeItems[data.lsItems[1].iTaskID] then
                    self.mm_ListView:removeChild(self.nodeItems[data.lsItems[1].iTaskID])
                    self.nodeItems[data.lsItems[1].iTaskID] = nil
                end
            else
                self:changeItem(self.nodeItems[data.lsItems[1].iTaskID],data.lsItems[1])
            end
        elseif data.dwCount > 1 then
            self:changeItem(self.nodeItems[data.lsItems[1].iTaskID],data.lsItems[2])
        else
            print("其他异常")
        end
    else  
        self.mm_ListView:removeAllItems()
        self:sortTaskData(data.lsItems)
        for k,v in pairs(data.lsItems) do
            if k <= 4 then
                self:addItem(v,k)
            else
                local array = {
                    cc.DelayTime:create(k * (1/30)),
                    cc.CallFunc:create(function() 
                        if not tolua.isnull(self) then
                            self:addItem(v,k)
                        end
                    end)
                }
                self:runAction(cc.Sequence:create(array))
            end
        end
    end
end

--未领取的排最前
function HallTaskLayer:sortTaskData(data)
    --排序的算法 --任务状态 (0进行中/去完成  1为完成未领取奖励   2为已完成领取(领过奖)  3为已完成但不显示)
    local function comps(a,b)
        local a_value = a.iTaskStatus or 0
        local b_value = b.iTaskStatus or 0
        if a_value == b_value then
            return a.iTaskID < b.iTaskID
        else
            if a_value == 1 then
                return true
            elseif b_value == 1 then
                return false
            else
                return a.iTaskID < b.iTaskID
            end
        end
    end

    --应用
    table.sort(data,comps)
end

function HallTaskLayer:initNode()
    self.mm_ListView:removeAllItems()
    self.nodeItems = {}
end
--配置
function HallTaskLayer:setUI(sum)
    if sum < 2 then
        self.mm_ListView:setContentSize(cc.size(self.mm_ListView:getContentSize().widht,listViewHeight[1]))
    elseif sum == 2 then
    elseif sum == 3 then
    end
end
--Recebido = 已领取  state     Receber = 领取      Para complear  = 去完成
function HallTaskLayer:addItem(data,k)
    local item = self.mm_ListView:getItem(k-1)
    if not item then
        self.mm_ListView:pushBackDefaultItem()
        item = self.mm_ListView:getItem(k-1)
    end
    if not item then
       return
    end
    item:show()
    self.nodeItems[data.iTaskID] = item
    self:changeItem(item,data)
end

function HallTaskLayer:changeItem(item,data)
    if  item == nil then return end
    item:setTag(data.iTaskID)
    item:getChildByName("Text_desc"):setString(data.szTaskDesc)
    -- local str = g_format:formatNumber(data.lRewardValue,g_format.fType.abbreviation)
    item:getChildByName("Text_gold"):setString(data.lRewardValue)
    
    local _slider = item:getChildByName("Slider_item")
    _slider:setScale9Enabled(true)
    _slider:setTouchEnabled(false)
    _slider:setMaxPercent(data.lTaskMaxProgress)
    _slider:setPercent(data.lTaskCurProgress)
    local listView = item:getChildByName("ListView_1")
    listView:setBounceEnabled(false) 
    listView:setScrollBarEnabled(false)
    local CurProgress = data.lTaskCurProgress
    local pObjCurProgress = listView:getChildByName("Text_curTaskProgress")
    local pObjMaxProgress = listView:getChildByName("Text_maxTaskProgress")
    
    local MaxProgress = data.lTaskMaxProgress
    if data.wTaskOperationType == 2 and (data.wTaskOperationSubValue == 1 or data.wTaskOperationSubValue == 4 or data.wTaskOperationSubValue == 5) then
        --是游戏类型==2  and  是赢分类型==1
        CurProgress = g_format:formatNumber(data.lTaskCurProgress,g_format.fType.standard)
        MaxProgress = g_format:formatNumber(data.lTaskMaxProgress,g_format.fType.standard)
        -- MaxProgress = string.gsub(MaxProgress,",%d+","") --去掉小数部分
    end
    if data.wTaskOperationType == 1 then
        --充值类型 
        local lTaskCurProgress = string.format("%.2f",data.lTaskCurProgress/100)
        CurProgress = string.gsub(lTaskCurProgress,"%.",",")
        local lTaskMaxProgress = string.format("%.2f",data.lTaskMaxProgress/100)
        MaxProgress = string.gsub(lTaskMaxProgress,"%.",",")
    end

    pObjCurProgress:setString(CurProgress)
    pObjMaxProgress:setString("/"..MaxProgress..")")
    if data.lTaskCurProgress == data.lTaskMaxProgress then
        pObjCurProgress:setColor(cc.c3b(38,112,77))
    else
        pObjCurProgress:setColor(cc.c3b(255,66,0))
    end
    performWithDelay(listView,function() listView:jumpToRight () end,0)
    listView:setTouchEnabled(false)
    -- local innersize = listView:getInnerContainerSize()
    -- local size = listView:getContentSize()
    -- listView:setPositionX(listView:getPositionX() + (innersize.width-size.width))

    --任务状态 (0进行中/去完成  1为完成未领取奖励   2为已完成领取(领过奖)  3为已完成但不显示)
    local btn_0 = item:getChildByName("btn_goCompleted")
    btn_0:hide()

    local btnSize = btn_0:getContentSize()
    local NodeUpdate = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.NodeUpdate")
    local pWidthUpdate = btnSize.width-28
    local pNodeUpdate = NodeUpdate:create(pWidthUpdate)
    pNodeUpdate:addTo(btn_0)
    pNodeUpdate:setPosition(cc.p(btnSize.width/2,24))  
    pNodeUpdate:hide() 

    local btn_1 = item:getChildByName("btn_receive")
    btn_1:hide()
    local btn_2 = item:getChildByName("btn_received")
    btn_2:hide()
    if data.iTaskStatus == 0 then
        btn_0:show()
        btn_0:onClicked(function() self:onToFinishTaskClick(data,pNodeUpdate) end)
    elseif data.iTaskStatus == 1 then
        btn_1:show()
        btn_1:onClicked(function() self:onFinishTaskClick(data) end)
    elseif data.iTaskStatus == 2 then
        btn_2:show()
    end
end

--完成
function HallTaskLayer:onFinishTaskClick(data)
    print("完成任务")
    self.taskRewardValue = data.lRewardValue 
    G_ServerMgr:C2S_RequestTaskReward(data.iTaskID,self.myip)
end

--去完成
function HallTaskLayer:onToFinishTaskClick(data,upPercentNode)
    EventPost:addCommond(EventPost.eventType.TASK,string.format("点击去完成任务,任务描述%s,任务ID%d",data.szTaskDesc,data.iTaskID),data.iTaskID)
    if data.wTaskOperationType == 2 then
        --type:2 游戏任务
        self:getGameTypeData(data.iGameKindID)
        self:onEnterGame(data.iGameKindID,upPercentNode)
    elseif data.wTaskOperationType == 1 then
        --type:1 充值任务
        if  GlobalData.ProductsOver and GlobalData.GiftEnable and GlobalData.PayInfoOver and not GlobalData.TodayPay then            
            local pData = {
                ShowType = 2,--展示礼包类型：1.首充 2.每日 3.一次性
            }
            G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData) 
        end
        self:onClickClose()
    elseif data.wTaskOperationType == 3 then
        --TaskOperationSubValue: 1.首次加入俱乐部
        if data.wTaskOperationSubValue == 1 then
            G_ServerMgr:C2S_requestMemberOrder()
        end
        self:onClickClose()
    else
        print("其他类型任务：",data.wTaskOperationType)
    end
   	--[[
	if "wTaskOperationType" == 1 then
		"wTaskOperationSubValue":1.首充 2.日首充 3.普通充值
		"GameKindID":  无意义
		"GameServerID":无意义
	elseif "TaskOperationType" == 2 then
		"wTaskOperationSubValue":1.赢分 2.赢局 3.总局数
		"GameKindID":  游戏种类
		"GameServerID":限定房间
	elseif "TaskOperationType" == 3 then
		TaskOperationSubValue: 1.首次加入俱乐部
		"GameKindID":  无意义
		"GameServerID":无意义
	end
	]] 
end

function HallTaskLayer:onClickClose()    
    DoHideCommonLayerAction(self.mm_bg,self.mm_content,function() self:removeSelf() end)
end

--
function HallTaskLayer:showAward(goldTxt,goldImg)
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
    local data = {}
    data.goldTxt = goldTxt
    data.goldImg = goldImg
    data.type = 1
    appdf.req(path).new(data)
end

function HallTaskLayer:getMyIP()
    self.myip = "127.0.0.1"
    local info = {
        url = "https://ifconfig.me/ip",
        callback = function(ok,response) 
            -- print("myIp = ",response)
            self.myip = response 
        end
    }
    http.get(info)
end

function HallTaskLayer:getGameTypeData(gameId)
    self.curGameInfo = {}
    self.curGameInfo.gameInfo = {}
    self.curGameInfo.update = {}
    self.curGameInfo.gameType = 0
    local gameType = nil
    local gameIconConfig = HallTableViewUIConfig.gameIconConfig
    for k = 1,#gameIconConfig do
        local config = gameIconConfig[k]
        for i = 1,#config do
            local sonData = config[i]
            if type(sonData) == "table" then
                if #sonData >= 2 then
                    for m = 1,#sonData do
                        local data = sonData[m]
                        if data.ID == tonumber(gameId) then
                            gameType = data.Type
                            break
                        end
                    end
                else
                    if sonData.ID == tonumber(gameId) then
                        gameType = sonData.Type
                        break
                    end
                end
            end
            if gameType then
                break
            end
        end
        if gameType then
            break
        end
    end
    for k,n in pairs(GlobalData.SubGameId) do
        for i,v in pairs(GlobalData.SubGameId[k]) do
            if v == gameId then
                self.curGameInfo.update[v] = {}
                self.curGameInfo.update[v].down = self._scene:GetSubGameStutes(v,gameType)
                self.curGameInfo.update[v].downstatus = self._scene:GetSubGameDownStutes(v)  --下载状态
                self.curGameInfo.gameInfo[v] = GlobalUserItem.GetServerRoomByGameKind(v) or {}
                self.curGameInfo.gameType = k
                self.curGameInfo.gameKindID = gameId
                return
            end
        end
    end
    return 
end

function HallTaskLayer:onEnterGame(gameKindID,upPercentNode)

    self.updateInfo = {}
    if not self.curGameInfo.update[gameKindID] or not self.curGameInfo.gameInfo[gameKindID] then
        showToast(g_language:getString("game_not_open"))
        return
    end

    if self.curGameInfo.update[gameKindID].down == true then   --需要下载
        self.updateInfo.gameKindID = gameKindID
        self.updateInfo.percentNode = upPercentNode
        G_event:NotifyEvent(G_eventDef.UI_GAME_UPDATE,{subGameId = self.curGameInfo.gameKindID})
        self:OnUpdateDownProgress({gameId = gameKindID,percent = 0})
    else
        self:startGame(gameKindID)
    end
end

function HallTaskLayer:startGame(gameKindID)
    for i,v in ipairs(self.curGameInfo.gameInfo[gameKindID]) do
        --wSortID==0 是体验场
        if v.wServerKind == 1 and v.wSortID > 0 then
            --将玩家送入排除了体验场的第一个场
            local enterScore = v.lEnterScore
            --币不足统一游戏登录拦截 GameFrameEngine:onLogonRoom
            showNetLoading()
            GlobalData.HallClickGame = true
            GlobalData.HallCallback = function(scene) 
                G_event:NotifyEvent(G_eventDef.UI_SHOW_HALLTASKLAYER,{scene = scene})
            end
            G_event:NotifyEvent(G_eventDef.UI_START_GAME,{roomMark = v.roomMark,quickStart = false})   
            return
        end
    end
end

--提交任务完成
function HallTaskLayer:onTaskRewardCallback(data)
    self:onTaskListCallback(data)
    self:getTaskItemData()
    g_redPoint:dispatch(g_redPoint.eventType.taskSub_2,false)
    G_ServerMgr:C2S_RequestRedData()  --提交任务需要获取新的红点数据。活跃度联动的
end

function HallTaskLayer:onEnterGameFinishCallback()
    self:onClickClose()
end

function HallTaskLayer:OnUpdateDownProgress(args)
    if self.updateInfo.gameKindID and self.updateInfo.gameKindID == args.gameId then
        if args.percent > 90 then 
            args.percent = 100
            self.updateInfo.percentNode:hide()
        else
            self.updateInfo.percentNode:show()
        end
        self.updateInfo.percentNode:setUpdatePercent(args.percent)
    end
end

function HallTaskLayer:OnUpdateDownSuccess(args)
    self.updateInfo.percentNode:hide()
end

local taskConfig = {
    [1] = {
        isGet = true,
        isFinish = false,
        byStatus = 0,
        gold = 5000,
        score = 10,
        dwConfigID = 0,
    },
    [2] = {
        isGet = false,
        isFinish = false,
        byStatus = 0,
        gold = 15000,
        score = 50,
        dwConfigID = 0,
    },
    [3] = {
        isGet = false,
        isFinish = false,
        byStatus = 0,
        gold = 25000,
        score = 110,
        dwConfigID = 0,
    },
    [4] = {
        isGet = false,
        isFinish = false,
        byStatus = 0,
        gold = 35000,
        score = 200,
        dwConfigID = 0,
    },
}
--活跃度部分
--------------------------------------------------
function HallTaskLayer:initActivenessTest()
    self:getActivenessConfig()
end

--获得活跃度全局配置
function HallTaskLayer:getActivenessConfig()
    if GlobalData.TaskActivenessConfig and not table.isEmpty(GlobalData.TaskActivenessConfig) then
        self:onActivenessConfigCallback(GlobalData.TaskActivenessConfig)
    else
        G_ServerMgr:C2S_RequestTaskActivenessConfig()
    end
end

--配置返回
function HallTaskLayer:onActivenessConfigCallback(data)
    -- data = {
    --     dwErrorCode = 0,
    --     wCount = 4,
    --     lsItems = {
    --         [1] = {
    --             dwConfigID = 1,
    --             dwActiveness = 10,
    --             byRewardType = 1,
    --             lRewardValue = 5000,
    --         },
    --         [2] = {
    --             dwConfigID = 2,
    --             dwActiveness = 50,
    --             byRewardType = 1,
    --             lRewardValue = 15000,
    --         },
    --         [3] = {
    --             dwConfigID = 3,
    --             dwActiveness = 150,
    --             byRewardType = 1,
    --             lRewardValue = 25000,
    --         },
    --         [4] = {
    --             dwConfigID = 4,
    --             dwActiveness = 300,
    --             byRewardType = 1,
    --             lRewardValue = 35000,
    --         },
    --     }
    -- } 
    if data.dwErrorCode > 0 then return end
    GlobalData.TaskActivenessConfig = data
    for i=1,data.wCount do
        taskConfig[i].dwConfigID = data.lsItems[i].dwConfigID
        taskConfig[i].score = data.lsItems[i].dwActiveness
        if data.lsItems[i].byRewardType == 1 then
            taskConfig[i].gold = data.lsItems[i].lRewardValue
        end
    end
    self:updateActivenessConfigUI(data.wCount)
    self:getTaskItemData()
end

--查询任务活跃度item
function HallTaskLayer:getTaskItemData()
    G_ServerMgr:C2S_RequestTaskItemData()
end

--任务item数据返回
function HallTaskLayer:onItemDataCallback(data)

    -- data = {
    --     dwActiveness = 175,
    --     wCount = 4,
    --     lsItems = {
    --         [1] = {
    --             dwConfigID = 1,
    --             byStatus = 2,
    --         },
    --         [2] = {
    --             dwConfigID = 2,
    --             byStatus = 1,
    --         },
    --         [3] = {
    --             dwConfigID = 3,
    --             byStatus = 0,
    --         },
    --         [4] = {
    --             dwConfigID = 4,
    --             byStatus = 0,
    --         },
    --     }
    -- }

    local itemsStatus = {}
    for i=1,#data.lsItems do
        itemsStatus[data.lsItems[i].dwConfigID] = data.lsItems[i].byStatus  -- 0:不可用;1:可领取;2:已领取
    end
    for i=1,data.wCount do
        if itemsStatus[taskConfig[i].dwConfigID] then
            taskConfig[i].byStatus = itemsStatus[taskConfig[i].dwConfigID]
        end
    end
    self:updateActivenessUI(data)
end

--领取活跃度奖励
function HallTaskLayer:onActivenessRewardClick(target)
    local status = target.userData.byStatus
    if status == 0 then return end
    local dwConfigID = target.userData.dwConfigID
    G_ServerMgr:C2S_RequestActivenessReward(dwConfigID,self.myip)
end

function HallTaskLayer:onActivenessRewardCallback(data)
    if data.dwErrorCode > 0 then return end
    for i=1,#taskConfig do
        if taskConfig[i].dwConfigID == data.dwConfigID then
            taskConfig[i].byStatus = 2
            self:updateIsGetRewardUI(i)
            local text = g_format:formatNumber(data.lRewardValue,g_format.fType.standard)
            self:showAward(text,"client/res/public/mrrw_jb_"..i..".png")
            g_redPoint:dispatch(g_redPoint.eventType.taskSub_1,false)
        end
    end
end

--更新配置
function HallTaskLayer:updateActivenessConfigUI(count)
    self.mm_me_totalScore:setString("/0")
    local maxProgress = taskConfig[count].score*10
    self.mm_Slider_task:setScale9Enabled(true)
    self.mm_Slider_task:setTouchEnabled(false)
    self.mm_Slider_task:setMaxPercent(maxProgress)
    self.mm_Slider_task:setPercent(0)
    local size = self.mm_Image_barbg:getContentSize()
    local n = maxProgress/size.width
    local pos_x = maxProgress/n/count

    for i=1,count do
        self["mm_Panel_item_"..i]:show()
        self["mm_Panel_item_"..i]:setPositionX(pos_x*i)
        self["mm_Panel_item_"..i].userData = taskConfig[i]
        self["mm_Panel_item_"..i]:addClickEventListener(handler(self,self.onActivenessRewardClick))
        self["mm_item_score_"..i]:setString(taskConfig[i].score)
        self["mm_AtlasLabel_gold_"..i]:setString(g_format:formatNumber(taskConfig[i].gold,g_format.fType.standard))
    end
    self.mm_Image_barbg:show()
end

function HallTaskLayer:updateActivenessUI(data)
    local itemPos = {}
    for i=1,data.wCount do
        -- 0:未达到;1:可领取;2:已领取
        if taskConfig[i].byStatus == 1 then
            self:updateIsFinishUI(i)
        elseif taskConfig[i].byStatus == 2 then
            self:updateIsGetRewardUI(i)
        else
            -- self["mm_Button_gold_"..i]:setBright(false)
        end
    end

    --更新活跃度
    self:updateProgress(data.dwActiveness)
end

--更新是否完成
function HallTaskLayer:updateIsFinishUI(i)
    -- self["mm_Button_gold_"..i]:setBright(true)
    self["mm_Image_effect_"..i]:runAction(cc.RepeatForever:create(cc.RotateTo:create(2, 720)))
    self["mm_Image_effect_"..i]:show()
    self["mm_Particle_"..i]:show()
end
--更新是否已领取
function HallTaskLayer:updateIsGetRewardUI(i)
    -- self["mm_Button_gold_"..i]:setBright(true)
    self["mm_Image_effect_"..i]:hide()
    self["mm_Image_effect_"..i]:stopAllActions()
    self["mm_Image_good_"..i]:show()  --显示对勾
    self["mm_Panel_item_"..i]:setTouchEnabled(false)
    self["mm_Particle_"..i]:hide()
end
--更新活跃度进度
function HallTaskLayer:updateProgress(dwActiveness)

    local count = #taskConfig
    self.mm_me_totalScore:setString(dwActiveness)
    if dwActiveness == 0 then
        self.mm_Slider_task:setPercent(0)
        return 
    end
    local MaxPercent = self.mm_Slider_task:getMaxPercent()
    if dwActiveness >= taskConfig[count].score then
        self.mm_Slider_task:setPercent(MaxPercent)
        return 
    end


    local oldProgress = self.mm_Slider_task:getPercent()
    local newProgress = oldProgress
    --大进度
    local MaxPro = MaxPercent/count
    local progressCount = 0
    local lastScore = 0
    for i=1,count do
        --在当前阶段内
        if dwActiveness < taskConfig[i].score and dwActiveness >= lastScore then
            --当前阶段的进度差值
            local tempProgress = dwActiveness - lastScore
            local miniPro = (MaxPro/(taskConfig[i].score - lastScore))*tempProgress
            newProgress = MaxPro*progressCount + miniPro
            break
        else
            progressCount = progressCount + 1
        end
        lastScore = taskConfig[i].score
    end
    self.mm_Slider_task:setPercent(newProgress)
end


return HallTaskLayer