--[[
    转盘节点
]]

local rouletteLayer = class("rouletteLayer")

--配置
local angleConfig = {1,9,5,4,10,6,12,2,8,7,3,11}


function rouletteLayer:onExit()
    
end

function rouletteLayer:ctor(pNode)
    self.m_rootNode = pNode
    local __children = self:getChildren();

    self.mm_Panel_base:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,-80)))

    self.m_curIndex = 1
    self.m_angleConfig = {}
    for i=1,12 do
        self.m_angleConfig[angleConfig[i]] = (i-1) * 30
    end
end

--重置
function rouletteLayer:resetRoulette()
    self.mm_Image_toulettePlay:stopAllActions()
    for i=1,12 do
        self["mm_Image_cursor_"..i]:hide()
    end
    self.mm_Image_winbg:hide()
end
--设置开奖结果
function rouletteLayer:setOpenResult(openNumber)
    self.m_curIndex = openNumber
    self.mm_Panel_angle:setRotation(self.m_angleConfig[openNumber])
    self.mm_text_winNumber:setString(openNumber)
end

function rouletteLayer:runRoulette()
    self:resetRoulette()
    self.m_timeline = cc.CSLoader:createTimeline("res/UI/rouletteLayer.csb");	
    self.m_timeline:clearFrameEndCallFuncs()
    self.m_timeline:play("animation0",false)
    self:runAction(self.m_timeline)
    self.m_timeline:setLastFrameCallFunc(function() 
        self["mm_Image_cursor_"..self.m_curIndex]:show()
        local action = cc.Sequence:create(cc.FadeIn:create(0.3),cc.FadeOut:create(0.3))
        self["mm_Image_cursor_"..self.m_curIndex]:runAction(cc.RepeatForever:create(action))
        self.mm_Image_winbg:show()
    end)
end
--重置开奖结构
function rouletteLayer:resetOpen()
    self.mm_Image_winbg:hide()
    self["mm_Image_cursor_"..self.m_curIndex]:hide()
end

return rouletteLayer

