---------------------------------------------------
--Desc:游戏更新节点
--Date:2022-09-20 19:30:44
--Author:A*
---------------------------------------------------
local NodeUpdate = class("NodeUpdate", function()
    local node = display.newNode()
    return node
end)

function NodeUpdate:ctor(pWidth)
    local csbNode = cc.CSLoader:createNode("UI/Hall/NodeUpdate.csb")
    self:addChild(csbNode)
    local content = csbNode:getChildByName("content")
    content:setContentSize(cc.size(pWidth,23))

    self.loadingBg = content:getChildByName("loadingBg")
    self.loadingBg:setContentSize(cc.size(pWidth-39,6))

    self.loadingBar = content:getChildByName("loadingBar")
    self.loadingBar:setScale9Enabled(true)
    self.loadingBar:setContentSize(cc.size(pWidth-39,6))
    self.loadingBar:setCapInsets(cc.rect(9,9,1,1))
    self.loadingBar:setVisible(true)
    
    self.loadingPercent = content:getChildByName("loadingPercent")    
    ccui.Helper:doLayout(csbNode)
end

function NodeUpdate:setUpdatePercent(pPercent)
    self.loadingBar:setPercent(pPercent)
    pPercent = math.modf(pPercent)
    self.loadingPercent:setString(pPercent.."%")
end



return NodeUpdate