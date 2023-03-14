local GameRecordLayer = class("GameRecordLayer", function(parent,frame)
		local GameRecordLayer = display.newLayer()
    return GameRecordLayer
end)
function GameRecordLayer:onExit()
    G_event:RemoveNotifyEvent("longhu_recordlist")
end
function GameRecordLayer:ctor(parent,frame)
    parent = parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,10)
    local csbNode = g_ExternalFun.loadCSB("client/res/game/longhu/longhuHistory.csb")
    self:addChild(csbNode)
    self.bg = csbNode:getChildByName("image_bg")
    self.node = csbNode:getChildByName("nodeHistory")
    ShowCommonLayerAction(self.bg,self.node)
    csbNode:getChildByName("btnOutClose"):onClicked(handler(self,self.onClickClose),true)
    self.node:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)
    self.txtLongRate = self.node:getChildByName("txtLongRate")
    self.txtHuRate = self.node:getChildByName("txtHuRate")
    
    self.scrollview = self.node:getChildByName("scrollview")
    self.scrollview:setScrollBarEnabled(false)
    self.scrollview1 = self.node:getChildByName("scrollview1")
    self.scrollview1:setScrollBarEnabled(false)
    self:onAddEventListen()
    frame:reqGameLoad()

    self.recordCount = 30 --最多30局记录
end
function GameRecordLayer:onClickClose()
    DoHideCommonLayerAction(self.bg,self.node,function() self:removeSelf() end)
end

function GameRecordLayer:onAddEventListen()
    G_event:AddNotifyEvent("longhu_recordlist" ,handler(self,self.onRefreshRecordList))
end

--刷新历史记录
function GameRecordLayer:onRefreshRecordList(args)
    local record = args.data.recordData[1]
    local longWin = 0
    local huWin = 0
    local startIndex = 1
    for i=30,21,-1 do
         if record[i].area_win[1][1] < 2 then  
             startIndex = i - 20
             break
         end
    end
    for i=startIndex,20+(startIndex-1) do  --近20局
        if record[i].area_win[1][1] == 1 then  --龙
            longWin = longWin + 1
        elseif record[i].area_win[1][2] == 1 then  --虎
            huWin = huWin + 1
        elseif record[i].area_win[1][1] == 2 then  --没有记录
            break
        end
    end
    if longWin == 0 and huWin == 0 then
        self.txtLongRate:setString("0%")
        self.txtHuRate:setString("0%")
    else
        local rate = string.format("%.2f",longWin / (longWin + huWin))
        rate = rate *100
        self.txtLongRate:setString(rate.."%")
        self.txtHuRate:setString((100-rate).."%")
    end

    local data = {}
    local _index = -1
    local _count = 0
    for i=1,30 do
        for k=1,3 do  --龙，虎，和
            if record[i].area_win[1][k] == 1 then
                if _index ~= -1 and _index ~= k then
                    local _data = {_index,_count} 
                    table.insert(data,_data)
                    _count = 0
                end
                _count = _count + 1
                _index = k
            end
        end
    end
    if _index ~= -1 and _count ~= 0 then
        local _data = {_index,_count} 
        table.insert(data,_data)
    end
    local length = math.ceil(#data/2)
    local width = 1526
    if length *158 > 1526 then
         width = length *158
    end
    self.scrollview1:setInnerContainerSize(cc.size(width,417))
    local index = 1
    local maxCount = 0
    for i=1,length do
        local item = cc.CSLoader:createNode("client/res/game/longhu/item1.csb")
        item:setPosition(88 + (i-1)*158,324)
        self.scrollview1:addChild(item)
        local icon1 = item:getChildByName("icon1")
        local icon2 = item:getChildByName("icon2")
        if data[i*2-1] then
            icon1:loadTexture("img_zs_"..(data[i*2-1][1]-1)..".png",UI_TEX_TYPE_PLIST)
            icon1:setVisible(true)
            icon1:getChildByName("txt"):setString(data[i*2-1][2])
            if data[i*2-1][2] > maxCount then
                maxCount = data[i*2-1][2]
            end
        end
        if data[i*2] then
            icon2:loadTexture("img_zs_"..(data[i*2][1]-1)..".png",UI_TEX_TYPE_PLIST)
            icon2:setVisible(true)
            icon2:getChildByName("txt"):setString(data[i*2][2])
            if data[i*2][2] > maxCount then
                maxCount = data[i*2][2]
            end
        end    
        if i == length then
            item:getChildByName("imgNew"):setVisible(true)
        end    
    end
    self.scrollview1:jumpToRight()
    ----------------------------------
    self.itemMark = {} --按行业标记
    length = #data > (maxCount-5) and #data or (maxCount-5)  --最大行数
    local width = 1526
    if length *70 > 1526 then
         width = length *70
    end
    local step = 0
    local offsetX = 0
    for i=1,#data do
        local _count = data[i][2]
        local _type  = data[i][1]
        local value = self:checkHaveItem(i)
        if value > 0 then
            step = (5-value+1)
        end
        if value == 1 then
            for m = 1,data[i-1][2]do
                local value = self:checkHaveItem(i+m)
                if value ~= 1 then
                    offsetX = offsetX + m
                    break
                end
            end
        end
        for k=1,_count do
            local item = cc.CSLoader:createNode("client/res/game/longhu/item.csb")
            item:getChildByName("img"):loadTexture("type_"..(_type-1)..".png",UI_TEX_TYPE_PLIST)
            local posx = 0
            local posy = 0
            if k > (5-step) then
                posx = 40 + (i+offsetX-1)*70 + (k-5+step)*70 
                posy = 46 + step*81.5
            else
                posx = 40 + (i+offsetX-1)*70
                posy = 372 - (k-1)*81.5
            end
            item:setPosition(posx,posy)
            self.scrollview:addChild(item)
            self.itemMark[i..k] = true
        end
    end
    self.scrollview:setInnerContainerSize(cc.size(width,417))
    self.scrollview:jumpToRight()
end

function GameRecordLayer:checkHaveItem(index)
   for i=1,5 do
       if self.itemMark[index..i] == true then 
           return i
       end
   end
   return 0 
end

return GameRecordLayer