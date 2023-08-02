---------------------------------------------------
--Desc:游戏更新节点
--Date:2022-09-20 19:30:44
--Author:A*
---------------------------------------------------
local NodeUpdate = class("NodeUpdate", function()
    local node = display.newNode()
    return node
end)

function NodeUpdate:ctor(pWidth,callback)
    self._callBackEnd = callback
    local csbNode = cc.CSLoader:createNode("Lobby/Entry/NodeUpdate.csb")
    self:addChild(csbNode)
    local content = csbNode:getChildByName("content")
    content:setContentSize(cc.size(pWidth,22))
    
    self.maskBg = content:getChildByName("mask")
    self.maskBg:hide()

    self.loadingBg = content:getChildByName("loadingBg")
    self.loadingBg:setContentSize(cc.size(pWidth-45,22))

    self.loadingBar = content:getChildByName("loadingBar")
    self.loadingBar:setContentSize(cc.size(pWidth-45,22))
    -- self.loadingBar:setCapInsets(cc.rect(9,9,1,1))
    self.loadingBar:setVisible(true)
    
    self.loadingPercent = content:getChildByName("loadingPercent")    
    ccui.Helper:doLayout(csbNode)
end

--设置蒙版类型
--1.大厅中部
--2.大厅下部
--3.Slots
--4.Especial
NodeUpdate.MaskPosY = {-27,-5,-60,-25}
function NodeUpdate:setMaskType(pType)    
    local pPosY = self.MaskPosY[pType]
    if pType>=3 then
        self.maskBg:loadTexture("client/res/BigImage/update_mask_"..pType..".png")
    else
        self.maskBg:loadTexture("client/res/Lobby/GUI/Hall/update_mask_"..pType..".png",UI_TEX_TYPE_PLIST)
    end
    self.maskBg:ignoreContentAdaptWithSize(true)
    self.maskBg:setPositionY(pPosY)
    self.maskBg:show()
end

function NodeUpdate:setUpdatePercent(pPercent)
    self.loadingBar:setPercent(pPercent)
    pPercent = math.modf(pPercent)
    self.loadingPercent:setString(pPercent.."%")
end

function NodeUpdate:dispatchEndCallBack(visible)
    if self._callBackEnd then
        self._callBackEnd(visible)
    end
end

return NodeUpdate