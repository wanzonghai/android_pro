

local bigwinLayer = class("bigwinLayer",ccui.Layout)
local scheduler = cc.Director:getInstance():getScheduler()

local anim = {
    [1] = {"bigwin_start","bigwin_idle"},
    [2] = {"superwin_start","superwin_idle"},
    [3] = {"megawin_start","megawin_idle"},
}
local finishTime = 3
local runTime = {
    [1] = {3},
    [2] = {3,2},
    [3] = {2,3,3}
}

function bigwinLayer:ctor(callback,bigwinConfig,goldCount)
    self.callback = callback   
    local csbNode = cc.CSLoader:createNode("UI/bigwinLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    self.m_csbNode = csbNode
    self.mm_btn_collect:onClicked(function() 
        self:onExit() 
    end)
    self.mm_btn_collect:hide()
    for i=1,3 do
        self["mm_Node_particle"..i]:hide()
    end
    self:actionHandle(bigwinConfig,goldCount)
end

function bigwinLayer:onExit()
    if self.callback then
        self.callback()
    end
    self:removeSelf()
end

function bigwinLayer:actionHandle(bigwinConfig,goldCount)

    local index = 1
    for i = 1, #bigwinConfig do
        if goldCount >= bigwinConfig[i] then
            index = i
        end
    end

    local animName = anim[index or 1]
    local rootPath = "GUI/bigwin/slots_bigwin_ske"
    local animation = sp.SkeletonAnimation:create(rootPath..".json",rootPath..".atlas",1)
    self.mm_Node_spine:addChild(animation)
    animation:setAnimation(0,animName[1],false)
    animation:addAnimation(0,animName[2],true)
    self.mm_AtlasLabel_1:setString(0)
    self.mm_Node_particle1:show()

    if index >= 2 then performWithDelay(self,function()  self.mm_Node_particle2:show()  end,runTime[index][1]) end
    if index == 3 then performWithDelay(self,function()  self.mm_Node_particle3:show() end,runTime[index][1] + runTime[index][2]) end
    
    local allTime  = 0
    for i,v in ipairs(runTime[index]) do
        allTime = allTime + v
    end
    self:schedulerUpdate(goldCount,allTime)
    performWithDelay(self,function() self:onExit() end,allTime + finishTime)
end

function bigwinLayer:schedulerUpdate(goldCount,allTime) 
    self.runSum = {value = 0}
    local onUpdate = function() 
        local n,_ = math.modf(self.runSum.value)
        local serverKind = G_GameFrame:getServerKind()
        self.mm_AtlasLabel_1:setString(g_format:formatNumber(n,g_format.fType.standard,serverKind))
    end
    local onComplete = function( ) self.mm_btn_collect:show() end
    local time = allTime
	TweenLite.to(self.runSum, time, { value = goldCount, onUpdate = onUpdate,onComplete = onComplete })    
end

return bigwinLayer