--设置大厅游戏入口滑动
local HallTableViewUIConfig = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HallTableViewUIConfig")
local NodeUpdate = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.NodeUpdate")
local TableView = appdf.req(appdf.CLIENT_SRC.."Tools.TableView")
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")

local SetGameIcon = {}
local tableViewParent = nil
function SetGameIcon:onExit()
    for k,v in pairs(self._iconNameNodeConfig) do
        v:release()
    end
    self._updateBtn = {}
    self._vipLimitBtn = {}
end

function SetGameIcon:releaseIcon()
    self._gameIconSizeConfig = {}
end

function SetGameIcon:setParent(parent,scene)
    tableViewParent = parent
    self._scene = scene
    self._gameIconSizeConfig = {}
    self._tableView = nil
    self.gameUpdateNode = {}            --热更新节点
    self._iconNameNodeConfig = {}       --没个入口节点
    self._gameIconCurX = 20              --游戏icon宽之间的间距
    self._gameIconCurY = 8              --游戏icon竖之间的间距
    self._updateBtn = {}
    self._vipLimitBtn = {}
end

function SetGameIcon:getGameUpdateNode()
    return self.gameUpdateNode
end

function SetGameIcon:getUpdateBtn()
    return self._updateBtn
end

--开始增加tableView
function SetGameIcon:setGameIconEntrance()
    self:createTableView()
end


function SetGameIcon:createTableView()
    local tab = cc.TableView2:create(cc.size(display.width,900))
    tab:setAnchorPoint(cc.p(0,0))
    tab:setDirection(cc.TableViewDirection.horizontal)
    tab:setFillOrder(cc.TableViewFillOrder.leftToRight)
    tab:registerFunc(cc.TableViewFuncType.cellSize, handler(self,self.setSize))
    tab:registerFunc(cc.TableViewFuncType.cellNum, handler(self,self.setNumber))
    tab:registerFunc(cc.TableViewFuncType.cellLoad, handler(self,self.loadCell))
    tab:registerFunc(cc.TableViewFuncType.cellUnload, handler(self,self.cellUnload))
    tableViewParent:addChild(tab)
    tab:setPosition(cc.p(0,-20))
    tab:setScrollBarEnabled(false)
    tab:setSwallowTouches(true)
    tab:setClippingEnabled(false)
    self._tableView = tab
end

function SetGameIcon:setSize(view,index)
    if index == 1 or index == #self._gameIconSizeConfig then
        return self._gameIconSizeConfig[index].width + 140,1000
    else
        return self._gameIconSizeConfig[index].width,1000
    end
end

function SetGameIcon:setNumber()
    return #self._iconConfig
end

function SetGameIcon:loadCell(view,index)
    local cell = view:dequeueCell()
	if not cell then
		cell = cc.TableViewCell2.new()
	end
    local item=cell._item
    
    if not cell._item then
        local item = cc.Node:create()
        cell._item=item
        cell:addChild(cell._item)   
        item:setAnchorPoint(1,0.5)
    end
    self:initGameItem(index,cell._item)
	return cell
end

--卸载一个unLoad触发
function SetGameIcon:cellUnload(view,index)
    local cell = view:dequeueCell()
    local item=cell and cell._item
    if item then
        item:removeAllChildren()
    end
end

function SetGameIcon:initGameItem(index,item)  
    print("index = ",index)  
    local gameItemConfig = self._iconConfig[index]
    local size = self._gameIconSizeConfig[index]
    item:setContentSize(size)
    item:setPosition(cc.p(size.width,500))
    if index == 1 then
        item:setPosition(cc.p(size.width + 150,500))
    end
    item:removeAllChildren()

    local gameConfig = gameItemConfig
    if gameConfig then              
        local oneLine = gameConfig[1]               --第一排单独微调
        oneLine.size = oneLine.size or cc.size(390,320)
        local twoLine = gameConfig[2]        
        
        local Name = oneLine.Name
        local ID = oneLine.ID
        local iconNode = self._iconNameNodeConfig[Name] or self:createNewNode(oneLine,index)
        if Name == "GameHallActivity" then                  
            iconNode:setPosition(cc.p(size.width/2+20,size.height - oneLine.size.height + oneLine.size.height/2))
        else
            iconNode:setPosition(cc.p(size.width/2,size.height - oneLine.size.height + oneLine.size.height/2 + 8))
        end
        if Name == "NodePGEntry" then
            iconNode:setPositionY(810)
        end
        item:addChild(iconNode)
        -- if ID ~=nil then            
        --     local pngName = "client/res/Lobby/GameIcon/"..Name..".png"
        --     iconNode._Button_1:loadTextureNormal(pngName,1)
        --     iconNode._Button_1:loadTexturePressed(pngName,1)
        -- end

        iconNode._data = oneLine
        if twoLine and #twoLine == 0 then           --第二排，如果只有一个  
            twoLine.size = twoLine.size or cc.size(390,320)          
            local Name = twoLine.Name
            local ID = twoLine.ID            
            local iconNode = self._iconNameNodeConfig[Name] or self:createNewNode(twoLine,index)
            iconNode:setPosition(cc.p(size.width/2,twoLine.size.height/2 - 20))
            item:addChild(iconNode)
            iconNode._data = twoLine
        elseif twoLine and #twoLine > 0 then        --第二排，如果有两个
            local width = nil
            for m = 1,#twoLine do
                local data = twoLine[m] 
                data.size = data.size or cc.size(390,320)               
                local Name = data.Name
                local ID = data.ID
                local iconNode = self._iconNameNodeConfig[Name] or self:createNewNode(data,index)
                
                if m == 1 then
                    iconNode:setPosition(cc.p(size.width +20 - data.size.width  - data.size.width/2 - self._gameIconCurX - 22,data.size.height/2 - 20))
                elseif m == 2 then
                    iconNode:setPosition(cc.p(size.width +20 - data.size.width/2  - 26,data.size.height/2 - 20))
                end
                item:addChild(iconNode)
                iconNode._data = data
            end
        end
    end
end

function SetGameIcon:createNewNode(data,index)
    local gameID = data.ID
    local Name = data.Name
    local Type = data.Type
    local iconNode = nil
    local function onTouchGame(sender,eventType)
        local parent = sender:getParent()
        if eventType == ccui.TouchEventType.began then
            parent:stopAllActions()
            parent:runAction(cc.ScaleTo:create(0.12,0.96))
            sender:setPressButtonMusicPath("sound/music_button.mp3")
            sender._beganPosition = sender:getTouchBeganPosition()
            sender._movedPosition = sender:getTouchBeganPosition()
        elseif eventType == ccui.TouchEventType.moved then
            sender:setPressButtonMusicPath("")
            sender._movedPosition = sender:getTouchMovePosition()
        elseif eventType == ccui.TouchEventType.ended then
            parent:stopAllActions()
            parent:runAction(cc.ScaleTo:create(0.12,1))
            if math.abs(sender._movedPosition.x - sender._beganPosition.x) >= 20  then
                return 
            end
            sender._beganPosition = nil
            sender._movedPosition = nil
            local pData = iconNode._data
            if pData.Name == "NodePGEntry" then
                --需要横竖版切换支持
                if CHANGE_ORIENTATION_OPEN then
                    --打开PG游戏列表
                    G_event:NotifyEvent(G_eventDef.UI_SHOW_PG_LIST)
                else
                    --TODO
                    --判断用户来源
                    --1.马甲包，提示官网更新应用
                    --2.自代理包，获取用户更新授权        
                end                
            else
                self:hall2RoomList(iconNode)      --房间分类
            end
        elseif eventType == ccui.TouchEventType.canceled then
            parent:stopAllActions()
            parent:runAction(cc.ScaleTo:create(0.12,1))
            sender._beganPosition = nil
            sender._movedPosition = nil
        end 
    end
    
    if  Name == "GameHallActivity" then
        --活动轮播图
        iconNode = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile("Lobby/Entry/"..Name..".csb")
        local pageView = iconNode:getChildByName("pageView")
        local content = iconNode:getChildByName("content")
        local dian = content:getChildByName("dian")
        dian:hide()
        iconNode:setName("HallActivity")
        iconNode:setContentSize(pageView:getContentSize())
        iconNode:setAnchorPoint(0,0)
        self._scene.HallActivity = pageView
        pageView._dian = dian
    elseif Name == "NodePGEntry" then
        --PG入口
        iconNode = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile("Lobby/Entry/"..Name..".csb")
        local pSpine = iconNode:getChildByName("spine_1")
        local spineFile = "client/res/spine/pg"
        local animateAct = sp.SkeletonAnimation:create(string.format("%s.json", spineFile), string.format("%s.atlas", spineFile), 1)
        animateAct:addTo(pSpine)
        animateAct:setAnimation(0, "daiji", true)
        animateAct:setPosition(0, 0)
        local Button_1 = iconNode:getChildByName("Button_1")            
        Button_1:setTouchEnabled(false)
        local button = ccui.Button:create()
        button:ignoreContentAdaptWithSize(false)
        button:setContentSize(cc.size(390,800))
        iconNode:addChild(button)
        button:setAnchorPoint(0.5,0.5)
        button:setPosition(cc.p(0,0))
        button:setSwallowTouches(false)
        button:loadTextureNormal("client/res/Lobby/GameIcon/dating_xiazai_btn.png",1)           --一定要设置资源，否则不能合批
        button:addTouchEventListener(onTouchGame)
        button:setOpacity(0)
        iconNode:setAnchorPoint(0,0)
    else
        iconNode = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile("Lobby/Entry/"..Name..".csb")
        local Button_1 = iconNode:getChildByName("Button_1")
        iconNode._Button_1 = Button_1
        Button_1:setTouchEnabled(false)
        local button = ccui.Button:create()
        button:ignoreContentAdaptWithSize(false)
        button:setContentSize(cc.size(330,270))
        Button_1:addChild(button)
        button:setAnchorPoint(0.5,0.5)
        button:setPosition(cc.p(235,190))
        button:setSwallowTouches(false)
        button:loadTextureNormal("client/res/Lobby/GameIcon/dating_xiazai_btn.png",1)           --一定要设置资源，否则不能合批
        button:addTouchEventListener(onTouchGame)
        button:setOpacity(0)
        self:setIconStatus(Button_1,gameID,Type)
        -- if Status ~= nil then
        --     iconNode:setColor(Status and cc.c3b(255,255,255) or cc.c3b(125,125,125))
        -- end
        --显示是否下载
        self:createDownImg(iconNode,gameID,Type)
        self:createVipLimitImg(iconNode,gameID,Type)

        iconNode:setName(Name)
        self:createUpdateNode(iconNode,gameID,index)
        
        iconNode:setAnchorPoint(0,0)
    end

    iconNode:retain()
    self._iconNameNodeConfig[Name] = iconNode
    return iconNode
end

function SetGameIcon:checkVipLimitImg()
    if tonumber(GlobalUserItem.VIPLevel) >= tonumber(ylAll.SERVER_UPDATE_DATA.easy_game_threshold) then
        for k, v in pairs(self._vipLimitBtn) do
            v:hide()
        end
    else
        for k, v in pairs(self._vipLimitBtn) do
            v:show()
        end
    end
end

function SetGameIcon:createVipLimitImg(iconNode,gameId,Type)
    if not gameId then
        return
    end

    if Type == HallTableViewUIConfig.GameType.EG then                 --如果是EG游戏
        local level = ylAll.SERVER_UPDATE_DATA.easy_game_threshold or 1
        local vipImg = ccui.ImageView:create(string.format("client/res/VIP/GUI/%d.png",1),ccui.TextureResType.plistType)
        vipImg:setPosition(169,-105)
        vipImg:setName("vipImg")
        vipImg:setScale(0.5)
        iconNode:addChild(vipImg)
        if tonumber(GlobalUserItem.VIPLevel) >= tonumber(ylAll.SERVER_UPDATE_DATA.easy_game_threshold) then
            vipImg:hide()
        else
            vipImg:show()
        end
        self._vipLimitBtn[gameId] = vipImg
    end
end

function SetGameIcon:createDownImg(iconNode,gameId,Type)
    if not gameId then
        return
    end
    local isUpdate = self:GetSubGameStutes(gameId,Type)
    local downImg = ccui.ImageView:create("client/res/Lobby/GameIcon/dating_xiazai_btn.png",ccui.TextureResType.plistType)
    downImg:setPosition(170,-115)
    downImg:setName("downImg")
    downImg:hide()
    iconNode:addChild(downImg)
    if isUpdate then
        downImg:show()
    else
        downImg:hide()
    end
    self._updateBtn[gameId] = downImg
end

function SetGameIcon:hideDownImg(iconNode)
    local downImg = iconNode:getChildByName("downImg")
    if downImg then
        downImg:hide()
    end
end
local lastGameId = nil

function SetGameIcon:createUpdateNode(iconNode,gameId,index)
    local size = cc.size(350,340) --self._gameIconSizeConfig[index] or
    local pWidthUpdate = size.width-50    
    local function callBack(visible)
        local Button_1 = iconNode:getChildByName("Button_1")
        Button_1:setBright(not visible)
    end

    local pNodeUpdate = NodeUpdate:create(pWidthUpdate,callBack)
    pNodeUpdate:addTo(iconNode)
    pNodeUpdate:setPosition(cc.p(0,-100))
    pNodeUpdate:hide()
    self.gameUpdateNode[gameId] = pNodeUpdate
end

--大厅直接进游戏或房间
function SetGameIcon:hall2RoomList(iconNode)
    local gameData = iconNode._data
    local gameId = gameData.ID
    local gameType = gameData.gameType
    local pType = gameData.Type

    --EG厂商游戏VIP条件判定
    if pType == HallTableViewUIConfig.GameType.EG and GlobalUserItem.VIPLevel and GlobalUserItem.VIPLevel < ylAll.SERVER_UPDATE_DATA.easy_game_threshold then
        G_event:NotifyEvent(G_eventDef.EVENT_SCORE_LESS,{lEnterScore = ylAll.SERVER_UPDATE_DATA.easy_game_threshold,ThresholdType = "VIP"})  
        return
    end

    local args = {}
    args.subGameId = gameId
    local isUpdate = self:GetSubGameStutes(gameId,pType)    
    if isUpdate then
        self:hideDownImg(iconNode)
        self._scene:OnUpdateDownProgress(gameId,0)
        self._scene:SubGameUpdate(args)  --更新
    else  
        self:hideDownImg(iconNode)
        if not self:onCheckRoomList() then return end   --没有收到房间列表
        GlobalData.HallClickGame = true
        if gameType == HallTableViewUIConfig.GameType.SelectRoom then          --如果还需要选场
            G_event:NotifyEvent(G_eventDef.UI_SHOW_ROOMLISTLAYER,{gameId = gameId})
        else                                                                    --如果不需要选场次
            if pType == HallTableViewUIConfig.GameType.EG then                 --如果是EG游戏                
                -- local pFlag = gameData.Status
                -- if pFlag then                    
                    if GlobalUserItem.VIPLevel and GlobalUserItem.VIPLevel >= ylAll.SERVER_UPDATE_DATA.easy_game_threshold then                    
                        local pFlag = g_EasyGame:CheckFix(gameId)
                        if not pFlag then
                            local ext_json = {gameId = gameId,roomId = gameId*1000+90}
                            EventPost:addCommond(EventPost.eventType.PV,"点击进入API游戏",nil,nil,ext_json)
                            G_event:NotifyEvent(G_eventDef.UI_START_GAME,{roomMark = gameId*1000+90,quickStart = false})
                        end
                    else                
                        G_event:NotifyEvent(G_eventDef.EVENT_SCORE_LESS,{lEnterScore = ylAll.SERVER_UPDATE_DATA.easy_game_threshold,ThresholdType = "VIP"})  --VIP不足
                    end
                -- else
                --     showToast(g_language:getString("game_not_open"))
                -- end
            elseif pType == HallTableViewUIConfig.GameType.PG then
                dump(gameData)
                G_event:NotifyEvent(G_eventDef.UI_START_GAME,{roomMark = gameId*1000+100,quickStart = false})
            elseif pType == HallTableViewUIConfig.GameType.OG then      --如果是本地游戏
                if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
                    showNetLoading()          
                    local ext_json = {gameId = gameId}
                    EventPost:addCommond(EventPost.eventType.PV,"点击进入本地游戏",nil,nil,ext_json)
                    self._scene:onSubDuoRenEnterGame(args)
                else
                    G_event:NotifyEvent(G_eventDef.UI_SHOW_SELECTROOMLAYER,{gameId = gameId})
                end
            end  
        end
    end
end

--检测是否要更新
function SetGameIcon:GetSubGameStutes(gameId,type)
    if type == HallTableViewUIConfig.GameType.EG then                  --如果是EG游戏
        return g_EasyGame:CheckFix(gameId)
    elseif type == HallTableViewUIConfig.GameType.PG then              --如果是PG游戏 加载在线资源，无需下载        
        return false
    elseif type == HallTableViewUIConfig.GameType.OG then          --否则如果是本地游戏
        local isWin32 = (g_TargetPlatform == cc.PLATFORM_OS_WINDOWS)
        if ylAll.UPDATE_OPEN == false or isWin32 then 
            return false 
        end
        if self._scene._gameUpdateStutes[gameId] then
            return self._scene._gameUpdateStutes[gameId].res or self._scene._gameUpdateStutes[gameId].zip
        end
    end
    
    return false 
end


function SetGameIcon:onCheckRoomList()
    if GlobalData.ReceiveRoomSuccess == false then
        G_ServerMgr:C2S_RequestGameRoomInfo(0,true)
        showToast(g_language:getString("get_room_info"))
        return false
    end
    return true
end

function SetGameIcon:setIconStatus(node,gameId,Type)
    --热门 新游
    local pStatus = GlobalData.StatusConfig[gameId] 
    if pStatus and gameId ~= 702  then
        local statusNode = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile("Lobby/Entry/NodeStatus.csb")
        node:addChild(statusNode)
        statusNode:setPosition(cc.p(106,279))
        local Hot = statusNode:getChildByName("Hot")
        local New = statusNode:getChildByName("New")
        Hot:setVisible(pStatus == 1)
        New:setVisible(pStatus == 2)
    end
    if      Type ~= HallTableViewUIConfig.GameType.EG 
        and Type ~= HallTableViewUIConfig.GameType.PG then         --需要加人数
        local statusNode = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile("Lobby/Entry/NodeOnlineR.csb")
        node:addChild(statusNode)
        local panel = statusNode:getChildByName("Panel_online")
        panel:setSwallowTouches(false)
        local onlineText = panel:getChildByName("text_onlineCount")
        onlineText:hide()
        local Image_icon = panel:getChildByName("Image_icon")
        local position = cc.p(onlineText:getPosition())
        onlineText = self:getCountTextByNode("client/res/Lobby/GameIcon/dating_renshushuzi_%s_bg.png")
        panel:addChild(onlineText)
        onlineText:setString("0")
        g_onlineCount:regestOnline(gameId,onlineText,function() 
            local width = onlineText:getContentSize().width
            onlineText:setPosition(cc.p(position.x - width,position.y))
            Image_icon:setPositionX(onlineText:getPositionX() - 4)
        end)
        statusNode:setPosition(cc.p(390,288))
    end
end

--通过图片数字创建文本
--spriteFrameName图片纹理名
function SetGameIcon:getCountTextByNode(spriteFrameName)
    local node = cc.Node:create()
    local curLong = 2           --字体之间的间距
    local width = 0             --字体的宽度
    local strTab = {}
    node.setString = function(sender,str) 
      --  local spriteFrameCache = cc.SpriteFrameCache:getInstance()    
       -- spriteFrameCache:addSpriteFrames("client/res/Lobby/GameIconPlist.plist", "client/res/Lobby/GameIconPlist.png")
       -- spriteFrameCache:addSpriteFrames("client/res/Lobby/GameIconPlist2.plist", "client/res/Lobby/GameIconPlist2.png")
        str = str or ""
        str = tostring(str)
        width = 0
        for k = 1,#strTab do
            strTab[k]:hide()
        end
        for k = 1,#str do
            local st = string.sub(str,k,k)
            if tonumber(st) ~= nil then
                local sprite = strTab[k]
                if not sprite then
                    sprite = display.newSprite()
                    node:addChild(sprite)
                    strTab[#strTab + 1] = sprite
                    sprite:setAnchorPoint(cc.p(0,0.5))
                end
                sprite:show()
                sprite:setSpriteFrame(string.format(spriteFrameName,st))
                sprite:setPosition(cc.p(width,0))
                width = width + sprite:getContentSize().width + curLong
            end
        end
        if width ~= 0 then width = width - curLong end
    end
    node.getContentSize = function(sender) 
        return cc.size(width,18)
    end

    return node
end

function SetGameIcon:setIconType(index)
    self:releaseIcon()
    self._iconType = index
    if index == 1 then                  --热,要有活动界面
        self._iconConfig = HallTableViewUIConfig.gameIconConfigHOT
    elseif index == 2 then              --slots
        self._iconConfig = HallTableViewUIConfig.gameIconConfigSLOT
    elseif index == 3 then              --Lazer
        self._iconConfig = HallTableViewUIConfig.gameIconConfigLAZER
    end
    local gameIconConfig = self._iconConfig
    for k = 1,#gameIconConfig do
        local gameConfig = gameIconConfig[k]            --当前列
        local maxSize = cc.size(0,0)
        if gameConfig then
            local oneLine = gameConfig[1]
            oneLine.size = oneLine.size or cc.size(390,320)
            maxSize.width = oneLine.size.width + self._gameIconCurX
            maxSize.height = oneLine.size.height * 2 + self._gameIconCurY
        end
        self._gameIconSizeConfig[k] = maxSize
    end

    self._tableView:reloadData()
    self._tableView:jumpToLeft()
end

return SetGameIcon