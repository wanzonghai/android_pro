-- crash游戏 背景动画节点

local CrashBgNode = class("CrashBgNode", cc.Node)

function CrashBgNode:ctor(_node)
	tlog('CrashBgNode:ctor')
    self.m_bgNode = _node
    _node:getChildByName("Image_bg"):setContentSize(display.width, display.height)
    local cloud = _node:getChildByName("Image_cloud")
    cloud.originPosy = cloud:getPositionY()
    self.m_cloudImage = cloud

    local start_1 = _node:getChildByName("Image_xx_1")
    start_1.originPosy = start_1:getPositionY()
    self.m_imageStart_1 = start_1

    local start_2 = _node:getChildByName("Image_xx_2")
    start_2.originPosy = start_2:getPositionY()
    self.m_imageStart_2 = start_2

    self:resetNodeShow()
end

function CrashBgNode:resetNodeShow()
    tlog("CrashBgNode:resetNodeShow")
    self.m_cloudImage:setPositionY(self.m_cloudImage.originPosy)

    self.m_imageStart_1:setPositionY(self.m_imageStart_1.originPosy)
    self.m_imageStart_2:setPositionY(self.m_imageStart_2.originPosy)
end

function CrashBgNode:moveBgAction()
    self.m_cloudImage:setPositionY(self.m_cloudImage:getPositionY() - 5)

    self.m_imageStart_1:setPositionY(self.m_imageStart_1:getPositionY() - 5)
    if self.m_imageStart_1:getPositionY() <= self.m_imageStart_1.originPosy - 1080 then
        self.m_imageStart_1:setPositionY(self.m_imageStart_2.originPosy)
    end
    self.m_imageStart_2:setPositionY(self.m_imageStart_2:getPositionY() - 5)
    if self.m_imageStart_2:getPositionY() <= self.m_imageStart_1.originPosy - 1080 then
        self.m_imageStart_2:setPositionY(self.m_imageStart_2.originPosy)
    end
end

return CrashBgNode