--
-- Author: senji
-- Date: 2014-06-16 11:28:57
--
local TweenMsgManager = class_quick("TweenMsgManager")
requireLuaFromCommon("ui.msg.TweenMsgTextField")

function TweenMsgManager:ctor()
    self._maxMsgNum = 3;
    self._yGap = 5;
    self._msgZorder = ZORDER_TWEEN_MSG or 1000000;
    self._holdDurationMs = 2000; --消息停留的时间
    self._msgPostion = cc.p(0, 100)
    
    self._curMsgs = {};
    self._allDisposeTimer = tickMgr:delayedCall(handler(self, self.onDisposeAllTimer), self._holdDurationMs, 1, false):changeTraceName("TweenMsgManager:_allDisposeTimer");
    self._allDisposeTimer.autoDispose = false;
    self._disposingMsgs = {};

    self._parentNode = nil;

    uiMgr.isScreenOrientationRotatedChangedSignal:add(self.onIsScreenOrientationRotatedChanged, self)
    self:onIsScreenOrientationRotatedChanged()
end


function TweenMsgManager:initParentLayer()
    if not self._parentNode then
        self._parentNode = display.newNode()
        self._parentNode:setLocalZOrder(self._msgZorder)
        DisplayUtil.setAddOrRemoveChild(self._parentNode, uiMgr:getTopLayerInAllScene(), true);
        self:onIsScreenOrientationRotatedChanged()
    end
end

function TweenMsgManager:onIsScreenOrientationRotatedChanged()
    if self._parentNode then
        local isRoteted = uiMgr:getIsScreenOrientationRotated()
        local parentPos = nil
        if isRoteted then
            parentPos = cc.p(display.cx, display.cy + 300);
        else
            parentPos = cc.p(display.cx, display.cy + 100);
        end
        self._parentNode:setPosition(parentPos)
    end
end

function TweenMsgManager:showWhiteMsg(msg, size)
    self:showMsg(HtmlUtil.createWhiteTxt(msg));
end

function TweenMsgManager:showGreenMsg(msg)
    self:showMsg(HtmlUtil.createGreenTxt(msg));
end

function TweenMsgManager:showRedMsg(msg)
    self:showMsg(HtmlUtil.createRedTxt(msg));
end

function TweenMsgManager:showMsg(msg, fontSize)
    self:initParentLayer()
    fontSize = fontSize or 45;
    if self._allDisposeTimer:getIsRunning() then
        self._allDisposeTimer:reset();
    end

    local msg = TweenMsgTextField.new(msg, fontSize);
    TableUtil.push(self._curMsgs, msg);
    -- msg:setLocalZOrder(self._msgZorder)
    DisplayUtil.setAddOrRemoveChild(msg, self._parentNode, true);
    -- uiMgr:showView(msg, self._msgZorder);
    msg:show(handler(self, self.onTween2ShowComplete));
    self:rearrangeTxts();
end

function TweenMsgManager:rearrangeTxts()
    if #self._curMsgs > self._maxMsgNum then
        TableUtil.shift(self._curMsgs):dispose(0, true);
    end

    -- 向下排挤
    -- local tempY = self._msgPostion.y;
    -- local len = #self._curMsgs;
    -- for i = len, 1, -1 do
    --     local msg = self._curMsgs[i];
    --  tempY = tempY - msg:getContentSize().height;
    --  if i == len then
    --      msg:setPosition(cc.p(self._msgPostion.x - msg:getContentSize().width * .5,  tempY));
    --  else
    --      TweenLite.to(msg, 0.2, { y = tempY });
    --  end
    --  tempY = tempY - self._yGap;
    -- end

    local tempY = self._msgPostion.y;
    local len = #self._curMsgs;
    for i = len, 1, -1 do
        local msg = self._curMsgs[i];
        if i == len then
            msg:setPosition(cc.p(self._msgPostion.x - msg:getContentSize().width * .5, tempY));
        else
            TweenLite.to(msg, 0.2, { y = tempY });
        end
        tempY = tempY + msg:getContentSize().height;
        tempY = tempY + self._yGap;
    end
end

function TweenMsgManager:onDisposeAllTimer()
    local tl = TimelineLite.new()
    for i, msg in ipairs(self._curMsgs) do
        local tween = msg:dispose(i * .1)
        if tween then
            tl:insert(tween)
        end
    end
    self._curMsgs = {};
end

function TweenMsgManager:onTween2ShowComplete()
    local isAllDone = true;
    for i, msg in ipairs(self._curMsgs) do
        if msg:getIsTweening() then
            isAllDone = false;
            break;
        end
    end

    if isAllDone then
        self._allDisposeTimer:start();
    end
end

tweenMsgMgr = TweenMsgManager.new();