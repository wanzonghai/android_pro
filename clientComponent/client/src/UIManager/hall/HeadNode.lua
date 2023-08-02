local BaseNode = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseNode")
local HeadNode = class("HeadNode",BaseNode)
--头像，如果不赋值，默认玩家用户自己头像
--parent要加的父节点
--头像wFaceID
--dwGameID远程下载的ID
--isClip是否裁剪，默认裁剪

function HeadNode:ctor(wFaceID,dwGameID,isClip)
    HeadNode.super.ctor(self)
    self:addLayer("Lobby/HeadNode.csb")
    self.mainNode:setCascadeOpacityEnabled(true)
    self.headImage = self:getChildByName("headImage")
    self.headImage:setCascadeOpacityEnabled(true)
    self.boderImage = self:getChildByName("boderImage")
    self.boderImage:setCascadeOpacityEnabled(true)
    self.boderImage:ignoreContentAdaptWithSize(false)
    self.boderImage:setLocalZOrder(2)
    self.headImage:addTouchEventListener(handler(self,self.onTouch))
    self.headImage:setLocalZOrder(1)
    self.vipImage = self:getChildByName("vipImage")
    self.vipImage:setCascadeOpacityEnabled(true)
    self.vipImage:setLocalZOrder(3)
    self.headImage:hide()
    self.headImage:ignoreContentAdaptWithSize(false)
    self._onClickFunc = nil
    self._initScale = 1.0
    if isClip ~= false then
        isClip = true
    end
    self._isClip = isClip
    self:updateHeadInfo(wFaceID,dwGameID)
    self:clipNode()
end

function HeadNode:create(wFaceID,dwGameID,isClip)
    local node = HeadNode.new(wFaceID,dwGameID,isClip)
    return node
end

function HeadNode:createHeadImage()
    local headImage = ccui.ImageView:create()
    headImage:ignoreContentAdaptWithSize(false)
    headImage:setAnchorPoint(0.5,0.5)
    self.mainNode:addChild(headImage)
    return headImage
end

--设置头像和vip信息
function HeadNode:updateHeadInfo(wFaceID,dwGameID)
    if not wFaceID and not dwGameID then
        wFaceID = wFaceID or GlobalUserItem.wFaceID
        dwGameID = dwGameID or GlobalUserItem.dwGameID
    end
    
    local imgPath = "client/res/public/Face"..wFaceID..".jpg"
    if dwGameID then
        local localPath = DownloadPic:isFileNamePath(dwGameID)
        if localPath then
            imgPath = localPath
        end
    end

    self:loadTexture(imgPath)
    self:loadVipTextureByVipValue(GlobalUserItem.VIPLevel)
end

--设置头像
function HeadNode:loadTexture(imgPath)
    self.headImage:show()
    self.headImage:loadTexture(imgPath)
    
end

--设置大小
function HeadNode:setContentSize(size)
    local curScaleX = size.width / 125
    local curScaleY = size.height / 125
    self.mainNode:setScale(curScaleX)
end

--设置头像框资源
function HeadNode:loadBorderTexture(imgPath,plistType)
    self.boderImage:loadTexture(imgPath,(plistType == 1) and 1 or 0)
end

--头像框是否隐藏
function HeadNode:setBorderVisible(bool)
    self.boderImage:setVisible(bool)
end

--设置vip等级
function HeadNode:loadVipTextureByVipValue(vip)
    if not vip or not tonumber(vip) then
        return
    end
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("client/res/VIP/VIPPlist.plist", "client/res/VIP/VIPPlist.png")
    self.vipImage:loadTexture(string.format("client/res/VIP/GUI/%s.png",vip),1)
end

--vip图标是否显示
function HeadNode:setVipVisible(bool)
    self.vipImage:setVisible(bool)
end

function HeadNode:onTouch(sender,eventType)
    if eventType == ccui.TouchEventType.began then
        self.headImage:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08,self._initScale - 0.012)))
    elseif eventType == ccui.TouchEventType.moved then

    elseif eventType == ccui.TouchEventType.ended then
        if self._onClickFunc then
            self._onClickFunc(self)
        end
        self.headImage:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08,self._initScale)))
    elseif eventType == ccui.TouchEventType.canceled then
        self.headImage:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08,self._initScale)))
    end
end

--设置是否能点击头像，默认能点击
function HeadNode:setTouched(bool)
    self.headImage:setTouchEnabled(false)
end

--设置缩放
function HeadNode:setScale(scale)
    self._initScale = scale
    self.headImage:stopAllActions()
    self.headImage:setScale(scale)
end

--点击头像的回调
function HeadNode:onClicked(func)
    if type(func) ~= "function" then
        return
    end
    self._onClickFunc = func
end

--创建裁剪玩家头像
function HeadNode:createClipHead(spr,mask)
    local sprSize = spr:getContentSize();
    local stencil = cc.Sprite:create(mask or "client/res/public/clip.png");
	-- local stencil = cc.Sprite:createWithSpriteFrameName(mask or "client/res/public/clip.png");
    stencil:setContentSize(sprSize)
    local clipper = cc.ClippingNode:create();
    clipper:setContentSize(sprSize)
    clipper:setStencil(stencil);
    clipper:setInverted(false);
    clipper:setAlphaThreshold(0.05);
    clipper:addChild(spr);
    return clipper
end

function HeadNode:clipNode()
    if self._isClip then                  --如果需要裁剪
        self.headImage:retain()
        self.headImage:removeFromParent()
        local image = self:createClipHead(self.headImage)
        image:setCascadeOpacityEnabled(true)
        self.mainNode:addChild(image)
        image:setLocalZOrder(1)
        image:setName("clipNode")
        image:setPosition(cc.p(0,0))
        self.headImage:release()
    end
end

function HeadNode:onEnter()

end

function HeadNode:onExit()
    self:unregisterScriptHandler()
end

return HeadNode