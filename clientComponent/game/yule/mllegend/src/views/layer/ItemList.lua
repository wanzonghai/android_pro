--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local module_pre = "game.yule.mllegend.src"
local GameItem = appdf.req(module_pre .. ".views.layer.GameItem")
local ExternalFun = g_ExternalFun --require(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local ItemList = class("ItemList", cc.Layer) 

local scheduler = cc.Director:getInstance():getScheduler()


ItemList.HEIGHT = 549
ItemList.WIDTH = 183

local emGameState =
{
    "WAIT",              --等待            --0
    "START",     --等待服务器响应  --1
    "RUN",                --转动            --2
    "END",                --结算            --3
}
local ITEM_STATE = ExternalFun.declarEnumWithTable(0, emGameState)

function ItemList:ctor()
    
    ExternalFun.registerNodeEvent(self);

    local Type = math.random(0,GameLogic.ITEM_COUNT-1)


    self.m_cbState = ITEM_STATE.WAIT

 
    self.m_bStop = true

    self._cbTempItemDate = {}
    self.m_cbItemDate = {};

    self.m_Item={}
    for i = 1, 3 do
        local _type = math.random(0, GameLogic.ITEM_COUNT-1)
        local Item = GameItem:create()
        Item:created(Type + 1 )        
        Item:addTo(self)
        Item:setTag(i)
        Item:setPosition(cc.p(0, ItemList.HEIGHT / 3 *(i-1)))
        --Item:setTagLabel(i)
        self.m_Item[i] = Item
        table.insert(self._cbTempItemDate,Type )
    end

end

function ItemList:Begin(callback)
    if self.m_cbState == ITEM_STATE.START then 
        return
    end

    self.m_cbState = ITEM_STATE.START


    self:onStart(callback)

end

function ItemList:End()
    if self.m_cbState ~= ITEM_STATE.START then 
        return
    end
    self.m_cbState = ITEM_STATE.END
    self:onEnd(dt)
end

function ItemList:Stop()

end

function ItemList:onStart(callback)

    if callback == nil or type(callback)~="function" then 
        callback = function()  end
    end

    for i = 1, 3 do
        local item = self.m_Item[i]        
        if not item then
            item = GameItem:create()
            item:created(self.m_cbItemDate[i] + 1)
            item:addTo(self)
            item:setTag(i)
            self.m_Item[i] = item
        end
        item:stopAllActions()
        item:setPosition(cc.p(0, ItemList.HEIGHT / 3 *(i - 1))) 

        local move = cc.EaseSineIn:create(cc.MoveBy:create(0.25+i*0.02, cc.p(0,-ItemList.HEIGHT)))
        
        item:runAction(cc.Sequence:create(move, cc.CallFunc:create(function()
           if i==3 then 
                callback()
           end       
        end)))
    
    end
end

function ItemList:onEnd(dt)
    print("END",self.m_cbState)
   
    for i = 1, 3 do
        local item = self.m_Item[i]   
        if not item then
            item = GameItem:create()
            item:created( math.random(1, GameLogic.ITEM_COUNT))
            item:addTo(self)
            item:setTag(i)
            self.m_Item[i] = item
        end   
        item:setPosition(cc.p(0, ItemList.HEIGHT / 3 *(i - 1) + ItemList.HEIGHT ))  
        self:Change(true) 
        local move = cc.EaseSineOut:create(cc.MoveTo:create(0.25, cc.p(0,ItemList.HEIGHT / 3 *(i - 1))))
        item:runRotate(0.3)--i*0.01+
        local _time = i*0.08
        local ani = cc.Spawn:create(move)
        if i == 3 then      
            item:runAction(cc.Sequence:create(cc.DelayTime:create(_time),ani, cc.CallFunc:create(self._callback)))  
        else 
            item:runAction(cc.Sequence:create(cc.DelayTime:create(_time),ani))
        end        
    end
    --ExternalFun.playSoundEffect("TurnStop.mp3")
end
function ItemList:Change(bWin,num)
    
    if bWin then
        for i=1,3 do            
            self._cbTempItemDate[i] = self.m_cbItemDate[i]
        end
    else
        for i=1,num do
            table.remove(self._cbTempItemDate,1)
            local _type = math.random(0, GameLogic.ITEM_COUNT-1)
            table.insert(self._cbTempItemDate, _type)
        end
    end

    for i=1,3 do
        local item = self.m_Item[i]
        if not item then
            item = GameItem:create()
            item:created(self._cbTempItemDate[i]+1)
            item:addTo(self)
            item:setTag(i)
            item:setPosition(cc.p(0, ItemList.HEIGHT / 3 *(i - 1)))
            item:setTagLabel(i)
        else 
            item:setItemType(self._cbTempItemDate[i]+1)
        end
    end
end

function ItemList:setItemDate(tab)
    if tab==nil then
        return 
    end

    self.m_cbItemDate = {}
    for i=1,3 do
        table.insert(self.m_cbItemDate,1,tab[i])
    end
end

function ItemList:setInitIconType(tab)
    for i = 1, 3 do
        local item = self.m_Item[i]
        if item then
            item:setItemType(tab[i]+1)
        end
    end
end

function ItemList:setItemState(tab)
    if tab==nil then
        return 
    end
    self.m_ItemState = {}
    for i=1,3 do
        table.insert(self.m_ItemState,1,tab[i])
    end
end

function ItemList:reItemDate()
    for i = 1, 3 do
        local item = self.m_Item[i]
        if i<4 then    
            if not item then
                item = GameItem:create()
                item:created(self.m_cbItemDate[i] + 1)
                item:addTo(self)
                item:setTag(i)                
                self.m_Item[i] = item
            end   
            item:setPosition(cc.p(0, ItemList.HEIGHT / 3 *(i - 1)))
            item:setItemType(self.m_cbItemDate[i] + 1)         
        else 
            if not item then
                item = GameItem:create()
                item:created( math.random(1,GameLogic.ITEM_COUNT))
                item:addTo(self)
                item:setTag(i)                
                self.m_Item[i] = item
            end
            item:setPosition(cc.p(0, ItemList.HEIGHT / 3 *(i - 1)))
        end     
    end
end

function ItemList:reItemState(bFree)
    for i = 1, 3 do
        local item = self.m_Item[i]
        if self.m_ItemState[i] then
            item:setWin(bFree)
        end            
    end
end

function ItemList:onExit()
    
end

function ItemList:setCallBack(callback)
    if callback == nil then
        self._callback = function() end
        return 
    end
    self._callback = callback
end

function ItemList:runDeleteGame()
    
--     dump(self.m_cbItemDate)
--     dump(self.m_ItemState)

    local state = {false,false,false,false,false,false}

    for i=1,3 do
        state[i] = self.m_ItemState[i]
    end
    
    local num = 0;
    local itemCount = 1;
    for i = 1, 6 do
        if state[i] == false and itemCount <= 3 then
            local item = self.m_Item[itemCount]
            if not item then
                item = GameItem:create()
                item:created(math.random(1, GameLogic.ITEM_COUNT))
                item:addTo(self)
                item:setTag(itemCount)
                item:setPosition(cc.p(0, ItemList.HEIGHT / 3 *(i - 1 + num)))
                self.m_Item[itemCount] = item
            end
            if itemCount < 4 then
                item:setItemType(self.m_cbItemDate[itemCount] + 1)
            end
            item:setPosition(cc.p(0, ItemList.HEIGHT / 3 *(i - 1)))
            itemCount = itemCount + 1
        end
    end

    if self.m_ItemState[1] == false and self.m_ItemState[2] == false and self.m_ItemState[3] == false then
        return 
    end

    itemCount = 0
    local threeall = 0
    local moveDate = {}
    for i=1,6 do 
        if state[i] == false then
            itemCount = itemCount+1
            local data = {}
            data.index = itemCount
            data.movedis = i-itemCount
            moveDate[itemCount] = data
            if i<=3 then 
                 threeall = threeall+1
            end
        end 
    end

    for i=1,threeall do 
        local data = moveDate[i]
        local item = self.m_Item[data.index]
        if item then 
            if data.movedis ~= 0 then 
                item:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(0.05*i),
                    cc.MoveTo:create(0.1*data.movedis,cc.p(0, ItemList.HEIGHT / 3 *(i - 1)))
                    ))

                item:runRotate(0.05*i)
            end
        end
        
    end
    local _Delaytime = 1.0
    for i=(threeall+1),#moveDate do 
        local data = moveDate[i]
        local item = self.m_Item[data.index]
        if item then 
            if data.movedis ~= 0 then 
                if data.index == 3 then
                    item:runAction(cc.Sequence:create(cc.DelayTime:create(_Delaytime+0.05*i),cc.MoveTo:create(0.1*data.movedis,cc.p(0, ItemList.HEIGHT / 3 *(i - 1))), cc.CallFunc:create(self._callback)))
                    print("callback")
                    --if i - itemCount > 0 then
                        --ExternalFun.playSoundEffect("SingleDrop.wav")
                    --end
                else
                    item:runAction(cc.Sequence:create(cc.DelayTime:create(_Delaytime+0.05*i),cc.MoveTo:create(0.1*data.movedis,cc.p(0, ItemList.HEIGHT / 3 *(i - 1)))))
                end
                item:runRotate(_Delaytime+0.05*i)
            end
        end
    end

end
return ItemList
--endregion
