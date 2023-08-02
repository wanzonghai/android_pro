 --region *.lua
--Date
--此文件由[BabeLua]插件自动生成


local module_pre = "game.yule.mllegend.src"
local ItemList = appdf.req(module_pre .. ".views.layer.ItemList")
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local ExternalFun = g_ExternalFun --require(appdf.EXTERNAL_SRC .. "ExternalFun")
local ScrollLayer = class("ScrollLayer", function(scene)
    local layer = display.newLayer()
    return layer
end )
local scheduler = cc.Director:getInstance():getScheduler()
ScrollLayer.Type_Game_1 = 1
ScrollLayer.Type_Game_3 = 3

ScrollLayer.HEIGHT = 183
ScrollLayer.WIDTH = 183


function ScrollLayer:ctor(scene , type)
    self.m_layerType = type  
    if type == ScrollLayer.Type_Game_1 then
        self:created_game1(scene)
    elseif type == ScrollLayer.Type_Game_3 then 
        return 
    else 
        print("无效类型")
    end
end

function ScrollLayer:onExit()
    if self.m_layerType == ScrollLayer.Type_Game_1 then
        self:onExit1()
    elseif self.m_layerType == ScrollLayer.Type_Game_3 then
        self:onExit3()
    end
end

function ScrollLayer:onExit1()
    
    if nil ~= self.m_scheduleUpdate then
        scheduler:unscheduleScriptEntry(self.m_scheduleUpdate)
        self.m_scheduleUpdate = nil
    end


end

function ScrollLayer:onExit3()
    if #self.m_winLight3~=0 then
        for i = 1, #self.m_winLight3 do
            if self.m_winLight3[i] then
                self.m_winLight3[i]:clearTracks()
                self.m_winLight3[i]:removeFromParent()
            end
        end
    end
end

function ScrollLayer:created_game1(scene)
    self._scene = scene
    self.m_bStart = false
    self.m_bReady = false

    self.m_ItemDate = {{},{},{}}
    self.m_ItemState = {{},{},{}}
    self:initItem()
    self.m_time = 0;

    local function update(dt)
        if self.m_bStart == true and self.m_bReady == true then
            self.m_bStart = false
            self.m_bReady = false
            for i = 1, GameLogic.ITEM_X_COUNT do
                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.08 * i), cc.CallFunc:create(
                function()
                    self.m_ItemList[i]:End()
                end )
                ))
            end
        end    
    end

    -- 游戏定时器
    if nil == self.m_scheduleUpdate then
        self.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0.01, false)
    end
end

function ScrollLayer:initItem()
    local Type = math.random(1,12)

    self.m_ItemList = {}
    for i=1,GameLogic.ITEM_X_COUNT do
        local itemlist = ItemList:create()
        itemlist:addTo(self)
        itemlist:setPosition(cc.p(ScrollLayer.WIDTH*(i-1), 0))
        itemlist:setTag(i)
        self.m_ItemList[i] = itemlist
    end
end

function ScrollLayer:setGameSceneData(table)
    if table == nil then return end
    for i = 1, GameLogic.ITEM_X_COUNT  do
        local tab = {table[3][i],table[2][i],table[1][i]}
        self.m_ItemList[i]:setInitIconType(tab)
    end
end

function ScrollLayer:setDate(table)

    self.m_ItemDate = {{},{},{}}
    self.m_ItemDate = table
    for i = 1, GameLogic.ITEM_X_COUNT  do
        local tab = {}
        for j=1,GameLogic.ITEM_Y_COUNT do
            tab[j] = self.m_ItemDate[j][i];
        end
        self.m_ItemList[i]:setItemDate(tab)
    end
end

function ScrollLayer:runItem(table,callback)
    
    self:setDate(table)
    
    self._callBack = callback;
    for i = 1, GameLogic.ITEM_X_COUNT  do
        if i==GameLogic.ITEM_X_COUNT then
            self.m_ItemList[i]:setCallBack(callback)
        else 
            self.m_ItemList[i]:setCallBack()
        end                
    end
    self.m_bStart = true
end

function ScrollLayer:run()
    
    function callback ()
        self.m_bReady = true
    end

    self.m_bReady = false

    for i = 1, GameLogic.ITEM_X_COUNT do
        self.m_ItemList[i].m_bStop = false
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5 + 0.05 *(i - 1)), cc.CallFunc:create( function()
            self.m_ItemList[i]:Begin(i==GameLogic.ITEM_X_COUNT and callback or function()end)
            if i==1 then 
                ExternalFun.playSoundEffect("AllDrop.wav")
            end
        end )))
    end

end

function ScrollLayer:ItemStop()
    for i=1,GameLogic.ITEM_X_COUNT do
        self.m_ItemList[i]:Stop()
    end   
end

function ScrollLayer:setAllItemWin(StateDate,bFree)
    
    local function SaveOtherOne(table,itemdata)
        local bSame = false
        if #table==0 then
            table[#table+1] = itemdata
            return 
        end
        for i=1,#table do
            if table[i] == itemdata then
                bSame = true
            end
        end
        if  bSame==false then
            table[#table+1] = itemdata
        end
    end
    
    self.m_ItemState = StateDate
    for i=1,GameLogic.ITEM_X_COUNT do
        self.m_ItemList[i]:reItemDate()
        local tab = { }
        for j = 1, GameLogic.ITEM_Y_COUNT do
            tab[j] = StateDate[j][i];            
        end
        self.m_ItemList[i]:setItemState(tab)   
        self.m_ItemList[i]:reItemState(bFree)
    end

end

function ScrollLayer:runDeleteGame(table,callback)
    
    self:setDate(table)
    local num = 0
    local state = {}   
    for i=1,GameLogic.ITEM_X_COUNT do        
        local tab = { }
        for j = 1, GameLogic.ITEM_Y_COUNT do
            tab[j] = self.m_ItemState[j][i];
        end

        if tab[1] == false and tab[2] == false and tab[3] == false then
            state[i] = false
        else 
            state[i] = true;
            num = num+1;
        end
    end
    
     
    local bCall = true;
    local temptime = 0
    for i = GameLogic.ITEM_X_COUNT,1,-1 do     
        if bCall and state[i] then
            bCall = false
            self.m_ItemList[i]:setCallBack(callback)
        else 
            self.m_ItemList[i]:setCallBack()
        end
        if state[i] then
            temptime = num*0.1+0.05
            num = num-1;
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(temptime),cc.CallFunc:create(function ()
                self.m_ItemList[i]:runDeleteGame()
        end))) 
    end

end


return ScrollLayer

--endregion
