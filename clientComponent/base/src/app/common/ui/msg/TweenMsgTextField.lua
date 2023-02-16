--
-- Author: senji
-- Date: 2014-06-16 00:14:41
--
TweenMsgTextField = class_quick("TweenMsgTextField", function() return display.newLayer(); end)

function TweenMsgTextField:ctor(htmlText, fontSize, font, color)
    -- self._textMaxWidth = display.width * 4 / 5;
    self._textMaxWidth = 1400
    self._showCompleteCallback = nil;
    createSetterGetter(self, "isTweening", false, true);
    print("htmlText"..htmlText)
    self._tf = TextField.new("", fontSize, color, self._textMaxWidth, nil, TextField.H_CENTER, TextField.V_BOTTOM);
    self._tf:setStyleFunc(TextFieldUtil.makeLbsTextFieldStyle);
    self._tf:setHtmlText(htmlText);
    self._tf:setIsAssetVCenter(true)
    
    local bgImgUrl = "base/res/common/contentTips.png"
    local png = bgImgUrl
    self._bg = display.newSprite(bgImgUrl, nil, nil, { scale9 = true, capInsets = cc.rect(63, 3, 2, 4) });
    self._bg:setAnchorPoint(cc.p(0, 0));
    self._bg:setOpacity(0.8 * 255);
    self._bg:setVisible(true);

    self:addChild(self._bg);
    self:addChild(self._tf);

    DisplayUtil.setAllCascadeOpacityEnabled(self);

    self:checkViewSize();
end

function TweenMsgTextField:show(onCompleteCallback)
    self._showCompleteCallback = onCompleteCallback;
    self._isTweening = true;

    self:setOpacity(0);

    TweenLite.to(self, 0.2, { alpha = 1, delay = 0.2, onComplete = handler(self, self.onShowComplete) });
end

function TweenMsgTextField:onShowComplete()
    self._isTweening = false;
    if self._showCompleteCallback then
        self._showCompleteCallback();
        self._showCompleteCallback = nil;
    end
end

function TweenMsgTextField:dispose(delay, noTween)
    if noTween then
        self:destroy()
        return nil;
    else
        return TweenLite.to(self, 0.2, { alpha = 0, onComplete = handler(self, self.destroy), delay = delay });
    end
end

function TweenMsgTextField:checkViewSize()
    local textHeight = self._tf:getTextHeight();
    local bgHeightOffset = 20;
    local bgWidthOffset = 100;

    local bgHeight = textHeight + bgHeightOffset;
    local bgWidth = self._textMaxWidth + bgWidthOffset;

    self._bg:setContentSize(cc.size(bgWidth, bgHeight));
    self:setContentSize(cc.size(bgWidth, bgHeight));

    self._tf:setPosition(cc.p(bgWidthOffset * .5, bgHeightOffset * .5));
end

function TweenMsgTextField:destroy()
    if self._bg then
        self._bg:removeFromParent();
        self._tf:destroy();

        self:removeFromParent();

        self._showCompleteCallback = nil;
        self._textMaxWidth = nil;
        self._tf = nil;
        self._bg = nil;
    end
end
