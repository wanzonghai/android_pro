--[[
***
***
]]
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
local HallRankLayer = class("HallRankLayer",function(args)
		local HallRankLayer =  display.newLayer()
    return HallRankLayer
end)

function HallRankLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("rank/RankLayer.csb")
    self:addChild(csbNode)

    self.bg = csbNode:getChildByName("bg")
    self.content = csbNode:getChildByName("content")
    ShowCommonLayerAction(self.bg,self.content)
    self.bg:onClicked(handler(self,self.onClickClose),true)
    self.content:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    self.ImageNull = self.content:getChildByName("ImageNull")
    self.TextNull = self.ImageNull:getChildByName("TextNull")
    self.TextNull:setString(g_language:getString("scrollView_default"))
    self.ImageNull:hide()
    self.ImageLoading = self.content:getChildByName("ImageLoading")
    self.ImageLoading:runAction(cc.RepeatForever:create(cc.RotateTo:create(2, 720)))

    self.rankListiew = self.content:getChildByName("listview")
    self.rankListiew:setItemModel(self.rankListiew:getChildByName("Template"))
    self.rankListiew:setBounceEnabled(true) --滑动惯性
    self.rankListiew:setScrollBarEnabled(false)
    self.rankListiew:removeAllChildren()
    G_event:AddNotifyEvent(G_eventDef.NET_GET_RANK_SUCCESS,handler(self,self.onQueryRankData))   
    G_event:AddNotifyEventTwo(self,G_eventDef.EVENT_FACE_URL_RESULT,handler(self,self.onGetRankUserUrl))
    G_ServerMgr:C2S_RequestRankInfo()
end
function HallRankLayer:onClickClose()
    DoHideCommonLayerAction(self.bg,self.content,function() self:removeSelf() end)
end

function HallRankLayer:onQueryRankData(data)
    self.ImageLoading:hide()
    self.ImageLoading:stopAllActions()
    dump(data.rankData)

    self.userHeadData = {}
    self.rankData = {}
    self.rankData = data.rankData
    self:addItem(data.rankData)
    if #data.rankData == 0 then
        self.ImageNull:show()
    end
end

function HallRankLayer:refreshHead(data)
    self.rankGameIds = {}
    for i,v in ipairs(data) do
        if v.dwFaceID == 0 and not HeadSprite.isFileNamePath(v.dwGameID) then
            table.insert(self.rankGameIds,v.dwGameID)
        end
    end
    G_ServerMgr:C2S_requestHeadUrl(self.rankGameIds)
end

function HallRankLayer:onGetRankUserUrl(data)
    local items = data.userData
    for i,v in ipairs(self.rankGameIds) do
        if items[v] then
            self.userHeadData[v].headURl = items[v]
            self:onRefreshHead(items[v],v)
        end
    end
end

function HallRankLayer:onRefreshHead(headUrl,gameID)
    local imgHead = self.userHeadData[gameID].headImg
    if imgHead then
        HeadSprite.loadHeadUrl(imgHead,gameID,headUrl)
    end
end

function HallRankLayer:addItem(data)
    self.rankListiew:removeAllChildren()

    for i,v in ipairs(data) do
        local item = self.rankListiew:getItem(i-1)
        if not item then
            self.rankListiew:pushBackDefaultItem()
            item = self.rankListiew:getItem(i-1)
        end
        if not item then
            break 
        end
        item:show()
        local imgHead =item:getChildByName("imghead")
        self.userHeadData[v.dwGameID] = {}
        self.userHeadData[v.dwGameID].headImg = HeadSprite.loadHeadImg(imgHead,v.dwGameID,v.dwFaceID,true)
        local userName = item:getChildByName("nickValue")
        local formatName,isShow = g_ExternalFun.GetFixLenOfString(v.szNickName,160,"arial",26)
        userName:setString(isShow and formatName or formatName.."..")

        local userID = item:getChildByName("IDValue")
        userID:setString("ID:"..v.dwGameID)        
        local formatMoney = g_format:formatNumber(v.lScore,g_format.fType.abbreviation,g_format.currencyType.GOLD)
        local moneyNode = item:getChildByName("goldValue")
        moneyNode:setString(formatMoney)

        local imgRank = item:getChildByName("imgRank")
        imgRank:hide()
        local textRank = item:getChildByName("txtRank")
        textRank:hide()
        if i < 4 then
            imgRank:loadTexture(string.format("client/res/rank/rank%d.png",i))
            imgRank:show()
        else
            textRank:setString(i)
            textRank:show()
        end
        item:setName(v.dwGameID)
        item:setTag(v.dwGameID)
        self.ImageNull:hide()
    end
    self:refreshHead(data)
end


function HallRankLayer:removeText(boxNode,textNode,fontSize)
    local boxSize = boxNode:getContentSize()
    local textSize = textNode:getContentSize()
    local moveLen = 0
    if textSize.width > boxSize.width then
        moveLen = textSize.width - boxSize.width
    else
        return 
    end
    local time = moveLen/fontSize
    local move1 = cc.MoveTo:create(time,cc.p(-moveLen,0))
	local detime = cc.DelayTime:create(2);
    local move2 = cc.MoveTo:create(time,cc.p(0,0))
    local sequence  = cc.Sequence:create(move1,detime,move2,detime)
    textNode:runAction(cc.RepeatForever:create(sequence))
end


function HallRankLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_GET_RANK_SUCCESS)
    G_event:RemoveNotifyEventTwo(self,G_eventDef.EVENT_FACE_URL_RESULT)
end

return HallRankLayer