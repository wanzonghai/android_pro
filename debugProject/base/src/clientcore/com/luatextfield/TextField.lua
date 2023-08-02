--
-- Author: senji
-- Date: 2014-03-05 01:03:24
--
requireClientCore("luatextfield.LabelPool");
requireClientCore("luatextfield.HtmlParser");
requireClientCore("luatextfield.TextFieldManager");

TextField = class_quick("TextField", function() return display.newLayer() end)

TextField.H_LEFT = 0;
TextField.H_CENTER = 1;
TextField.H_RIGHT = 2;

TextField.SCROLL_NO = 0;
TextField.SCROLL_H = 1;
TextField.SCROLL_V = 2;

TextField.TYPE_NORMAL = 1;
TextField.TYPE_CHAR_BY_CHAR = 2

TextField.V_TOP = 3; -- 这种情况下,textField的第一行文字的左下角y轴坐标是0
TextField.V_BOTTOM = 4; -- 这种情况下,textField的最后一行文字的左下角y轴坐标是0

TextField.CCNodeCreater = nil;--给外部用的node生成器
TextField.LABEL_CPP_NAME = "cc.Label"

local _charWidths = {}
_charWidths["i"] = .25;
_charWidths["l"] = .25;
_charWidths["j"] = .25;
_charWidths["f"] = .35;
_charWidths["t"] = .35;
_charWidths["r"] = .3;
_charWidths[" "] = .25;
_charWidths["1"] = .3;

local _labelCheckWidth = cc.Label:create();
_labelCheckWidth:retain();

function TextField:ctor(defaultFont, defaultFontSize, defaultFontColor, width, height, hAlign, vAlign, scrollPolicy)  
    createSetterGetter(self, "textWidth", 0, false, true, true)
    createSetterGetter(self, "width", 0, false, true)
    createSetterGetter(self, "height", 0, false, true)
    createSetterGetter(self, "textHeight", 0, false, true, true)
    createSetterGetter(self, "styleFunc", nil); --文本描边之类的函数
    createSetterGetter(self, "type", TextField.TYPE_NORMAL, false)
    createSetterGetter(self, "isAssetVCenter", false)--是不是文字外的unit垂直居中
    createSetterGetter(self, "isTfsScrollWhileNeed", true);--tfs时才生效，是否文本长度不足时不会滚动
    createSetterGetter(self, "scrollView", nil, false, true);--tfs时才有的滚动层
    createSetterGetter(self, "linkClickSignal", SignalAs3.new(), false, true);--参数,eventStr, worldPos, 超级连接点击
    createSetterGetter(self, "vGap", 0);
    createSetterGetter(self, "isWrapPrecise", false); --是否精确换行，精确换行会比较消耗性能，tfs的时候会自动打开

    --这个是一个特殊方式
    -- true的话，htmltext只会显示的时候才更新，不显示时是不会更新的，原理是每一帧检查是否在scene上并且显示，会增加一定的性能消耗，但是避免了android渲染的性能消耗
    -- false 默认值，其实只有特定情况需要设置，尤其是时间等文本每一秒都改变，但是经常界面是隐藏并且还没有销毁的情况
    createSetterGetter(self, "isRenderOnlyInDisplayList", false);

    self._scrollPolicy = scrollPolicy or TextField.SCROLL_NO;

    self._htmlText = "";
    self._text = "";
    self._htmlNodeVos = {};
    self._units = {};--所有单元集合
    self._lineUnits = {};--二维数组，每一行的单元集合
    self._width = width or 1000000;
    self._height = height or 0;
    self._line = 0;
    self._hAlign = hAlign or TextField.H_LEFT;
    self._hOffset = 0;
    self._vAlign = vAlign or TextField.V_TOP;
    self._lineCount = 0;
    defaultFont = defaultFont or "" or --[[noi18n]]"微软雅黑";
    defaultFontSize = defaultFontSize or 40;
    defaultFontColor = defaultFontColor or "#ffffff";
    self._unitParent = self;
    self._imgOffsetY = 3; --3个像素是图片底部的偏移值，label文字底的gap大概3个像素
    self._scrollWidthAdvanceV = 20;--垂直滚动时增加的额外可滚动宽度

    self:changeTextFormat(defaultFont, defaultFontSize, defaultFontColor);

    self:setCascadeOpacityEnabled(true);

    -- local colocLayer = display.newLayer(cc.c4f(0, 255/255, 0, 128/255));
    -- colocLayer:setContentSize(CCSize(self._width, 100));
    -- self:addChild(colocLayer);

    self:checkScrollable()
    self:retain();

    self._hasRender = true;
    self._isRendering = false
end

function TextField:getTextHeight()
    if not self._hasRender and not self._isRendering then
        self:render()
    end

    return self._textHeight;
end

function TextField:getTextWidth()
    if not self._hasRender and not self._isRendering then
        self:render()
    end

    return self._textWidth;
end

function TextField:initVScrollBar(bar, track)
    if self._scrollView then
        self._scrollView:setVScrollBar(bar)
        self._scrollView:setVScrollBarTrack(track)
        if bar then
            local barX = 4
            local barTxtGap = 8;
            bar:setPositionX(barX)
            if track then
                track:setPositionX(barX)
                track:setPositionY(self._height * track:getAnchorPoint().y)
            end
            self._unitParent:setPositionX(barX + barTxtGap);
            self._width = self._width - barX - barTxtGap;
        end
    end
end

function TextField:checkScrollable()
    if self._scrollPolicy ~= TextField.SCROLL_NO and  self._unitParent == self then
        self._vAlign = TextField.V_BOTTOM;
        self._unitParent = display.newLayer();

        local scrollView = CcsScrollView.new();
        if self._scrollPolicy == TextField.SCROLL_V then
            scrollView:setScrollPolicy(CcsScrollView.SCROLL_V)
        else
            scrollView:setScrollPolicy(CcsScrollView.SCROLL_H)
        end
        self._isWrapPrecise = true;
        local contentSize = nil;
        if self._scrollPolicy == TextField.SCROLL_V then
            contentSize = cc.size(self._width + self._scrollWidthAdvanceV, self._height)
        else
            contentSize = cc.size(self._width, self._height)
        end
        scrollView:setContentSize(contentSize);
        scrollView:setInnerContainerSize(contentSize)

        self:addChild(scrollView);

        scrollView:addContentChild(self._unitParent);
        scrollView:getViewPushSignal():add(self.onScrollTouchFromPushSignal, self);
        scrollView:getViewClickSignal():add(self.onScrollTouchFromClickSignal, self);
        self._scrollView = scrollView;
    end
end

function TextField:updateTfsSize(width, height)
    height = height or self._height;
    width = width or self._width;
    self._width = width;
    self._height = height
    local contentSize = nil;
    if self._scrollPolicy == TextField.SCROLL_V then
        contentSize = cc.size(width + self._scrollWidthAdvanceV, height)
    else
        contentSize = cc.size(width, height)
    end
    self._scrollView:setContentSize(contentSize);
    self._scrollView:setInnerContainerSize(contentSize)
    self:checkScrollSize();
end

function TextField:checkScrollSize()
    if self._scrollView then
        local needScroll = false;
        if self._scrollPolicy == TextField.SCROLL_V then
            needScroll = self._textHeight > self._height
            if needScroll then
                self._unitParent:setPositionY(0)
            else
                self._unitParent:setPositionY(self._height - self._textHeight)
            end
            self._scrollView:setInnerContainerSize(cc.size(self._width + self._scrollWidthAdvanceV, math.max(self._textHeight, self._height)));
        else
            needScroll = self._textWidth > self._width;
            self._scrollView:setInnerContainerSize(cc.size(self._textWidth, self._height));
        end

        if self._isTfsScrollWhileNeed then
            self._scrollView:setIsScrollable(needScroll)
        else
            self._scrollView:setIsScrollable(true)
        end
    end
end

function TextField:getLineUnits()
    return self._lineUnits;
end

function TextField:getUnits()
    return self._units;
end

function TextField:changeTextFormat(defaultFont, defaultFontSize, defaultFontColor)
    if defaultFont then
        self._defaultFont = defaultFont;
    end
    if defaultFontSize then
        self._defaultFontSize = defaultFontSize;
    end

    if defaultFontColor then
        self._defaultFontColor = defaultFontColor;
    end
    self:updateView();
end

-- isRenderImmediately是否立即渲染
-- 详细请看setHtmlText注释
function TextField:setText(txt, isRenderNextFrame)
    self:setHtmlText(txt, isRenderNextFrame);
end

function TextField:getText()
    return self._text;
end

-- 目前支持的格式：
-- <font face="字体" size ="字体大小" color="#ffffff颜色rgb">文字内容</font>
-- <br> <br height = '10'>--换行并且可以设置下一行的间距，这个是特别支持，不是正规的html风格
-- <space width = 'xxx', height = 'xxx'/>--空格隔开，不是html的风格
-- <img src="" width ="" height="">：width和height如果没定义的话，则按照原来大小，只定义一个的话，另一个会等比改变
-- 
function TextField:setHtmlText(txt, isRenderNextFrame)
    if self._htmlText ~= txt then
        self._hasRender = false;
        self._htmlText = txt;
        if self._isRenderOnlyInDisplayList then
            textFieldMgr:put(self, true);
            if not isRenderNextFrame then
                self:render()
            end
        else
            if not isRenderNextFrame then
                self:render();
            else
                textFieldMgr:put(self, false);
            end
        end
        return true
    end

    return false
end

function TextField:render(notRemoveFromRenderList)
    self._isRendering = true;
    -- local t = tickMgr:getTimer()
    self._text, self._htmlNodeVos = HtmlParser.parseHtml(self._htmlText, self._defaultFont, self._defaultFontSize, self._defaultFontColor, self._type == TextField.TYPE_CHAR_BY_CHAR);
    -- print("处理html消耗：", tickMgr:getTimer() - t)
    -- t = tickMgr:getTimer()
    self:updateView();
    -- print("udpateView消耗：", tickMgr:getTimer() - t)
    self._isRendering = false;
    self._hasRender = true;
    if not notRemoveFromRenderList then
        textFieldMgr:remove(self)
    end
end

function TextField:getHtmlText()
    return self._htmlText;
end

--- private method
function TextField:updateView()
     --清空文本
    if #self._units > 0 then
        for i, unit in ipairs(self._units) do
            unit.__htmlVoType = nil;
            unit.__htmlEvent = nil;
            unit.__isPushingDown = nil
            unit.__offsetX = nil;
            unit.__offsetY = nil;
            unit.__spaceWidth = nil;
            unit.__spaceHeight = nil;
            if unit.__touchWidget then--超链接的是在textfield上面addChild一个uiwidget
                unit.__touchWidget:removeFromParent();
                unit.__touchWidget = nil;
            end
            if tolua.type(unit) == TextField.LABEL_CPP_NAME then
                labelPool:pushLabel(unit);
            elseif not self:try2Cache(unit) then
                unit:removeFromParent();
                unit:release();
            end
        end
        self._lineUnits = {}
        self._units = {};
        self._lineCount = 0;
    end
    self._textWidth = 0;
    self._textHeight = 0;
    if self._htmlNodeVos and #self._htmlNodeVos > 0 then
        local curX = 0;
        local curY = 0;
        local curLineHeight = 0;
        local curLineBottomMargin = 0;--当isAssetVCenter为true时这个值表示图片往下面突出的最大长度
        local curLineWidth = 0;
        self._lineCount = 1;
        local lineUnits = {};
        self._lineUnits = {};
        local len = #self._htmlNodeVos;
        local i = 1;
        local overWidthNode = nil;
        local breakLineGapOffset = 0;
        while i <= len do
            local htmlNodeVo = self._htmlNodeVos[i];
            local node = nil;
            local breakLine = false;
            if overWidthNode then
                node = overWidthNode;
                overWidthNode = nil;
            else
                if htmlNodeVo.type == HtmlNodeVo.TXT then -- 文本
                    if htmlNodeVo.txt and htmlNodeVo.txt ~= "" then
                        -- 这里应该提前判断是否超过宽度了
                        local overWidthIndex = self:checkWhichCharOverWidth(curX, htmlNodeVo);
                        if self._scrollPolicy ~= TextField.SCROLL_H and overWidthIndex > 0 then
                            local txt = htmlNodeVo.txt
                            htmlNodeVo.txt = string.sub(txt, 1, overWidthIndex - 1);
                            local newLineVo = HtmlNodeVo.new(string.sub(txt, overWidthIndex), nil, nil, nil, htmlNodeVo.type, nil, nil, nil, nil, nil, nil, htmlNodeVo);
                            table.insert(self._htmlNodeVos, i + 1, newLineVo);
                            len = len + 1;
                            breakLine = true;
                        end

                        node = labelPool:getLabel(htmlNodeVo.txt, htmlNodeVo.font, htmlNodeVo.fontSize, DisplayUtil.rgb2ccc3(htmlNodeVo.fontColor), self._styleFunc, htmlNodeVo.isUnderline);
                    end
                elseif htmlNodeVo.type == HtmlNodeVo.SPACE then -- space隔开标识符
                    node = self:createSpaceNodeByHtmlNode(htmlNodeVo)
                elseif htmlNodeVo.type == HtmlNodeVo.IMG then -- 图片
                    node = self:createImgByHtmlNode(htmlNodeVo);
                elseif htmlNodeVo.type == HtmlNodeVo.CCNODE then -- CCNODE对象
                    node = self:createCCNodeByHtmlNode(htmlNodeVo);
                elseif htmlNodeVo.type == htmlNodeVo.BR then -- 换行
                    breakLineGapOffset = htmlNodeVo.height;
                    breakLine = true;
                end
            end
            if node then
                self:checkNodeSpecailProperties(node, htmlNodeVo)
                local lineUnitsNum = #lineUnits + 1;
                lineUnits[lineUnitsNum] = node;
                local realWidth = self:getUnitRealWidth(node);
                local realHeight = self:getUnitRealHeight(node);
                local isImgOrNode = htmlNodeVo.type == HtmlNodeVo.IMG or htmlNodeVo.type == HtmlNodeVo.CCNODE;
                if isImgOrNode then
                    if self._isAssetVCenter then
                        local curOffsetY = self._imgOffsetY + (self._defaultFontSize - realHeight) * .5;
                        curLineBottomMargin = math.max(curLineBottomMargin, -curOffsetY);
                    end
                    realHeight = realHeight + self._imgOffsetY;
                end
                DisplayUtil.setAddOrRemoveChild(node, self._unitParent, true)
                -- self._unitParent:addChild(node);
                self:checkNodeWithEvent(htmlNodeVo, node);
                self:setUnitPosition(node, curX + realWidth * node:getAnchorPoint().x, curY + realHeight * node:getAnchorPoint().y);
                self._units[#self._units + 1] = node;
                curX = curX + realWidth + self._hOffset;
                curLineWidth = curX;
                if self._scrollPolicy ~= TextField.SCROLL_H and self._width >= 0 and self._width < curLineWidth then --超宽，需要换行
                    if isImgOrNode then --图片，必须换行了
                        if lineUnitsNum ~= 1 then --当前是图片，但是不是这行第一个
                            overWidthNode = node;
                            node:removeFromParent();
                            curLineWidth = curLineWidth - realWidth;
                            table.remove(lineUnits, lineUnitsNum);
                            table.remove(self._units, #self._units)
                            breakLine = true;
                        end
                    end
                end
                if not overWidthNode then
                    curLineHeight = math.max(realHeight, curLineHeight);
                end
            end

            if breakLine or len == i then
                --换行或者最后时时注意先摆放一下当前行unit的y坐标，如果只有一行则不需要这样检测
                if curLineHeight == 0 then
                    curLineHeight = self._defaultFontSize;--如果这一行是空行，却又要换行，则以默认字体fontsize做高度
                end
                lineUnits._lineWidth = curLineWidth;
                lineUnits._lineHeight = curLineHeight;
                lineUnits._bottomMargin = curLineBottomMargin;
                self._textWidth = math.max(self._textWidth, curLineWidth);
                self._textHeight = self._textHeight + curLineHeight + breakLineGapOffset;
                if len ~= i then--不是最后一行
                    self._textHeight = self._textHeight + self._vGap;
                end
                lineUnits.breakLineGapOffset = breakLineGapOffset;
                self._lineUnits[#self._lineUnits + 1] = lineUnits;
                lineUnits = {};
                curLineHeight = 0;
                curLineWidth = 0;
                curLineBottomMargin = 0;
                breakLineGapOffset = 0;
                curX = 0;
                self._lineCount = self._lineCount + 1;
            end
            if not overWidthNode then
                i = i + 1;
            end
        end
    end

    self:updateAlignPositionX();
    self:updateAlignPositionY();
    self:checkScrollSize();
end

function TextField:setUnitPosition(unit, x, y)
    if unit then
        local offsetX = unit.__offsetX or 0;
        local offsetY = unit.__offsetY or 0;
        x = (x or unit:getPositionX()) + offsetX;
        y = (y or unit:getPositionY()) + offsetY;
        unit:setPosition(x, y);
        if unit.__touchWidget then
            unit.__touchWidget:setAnchorPoint(unit:getAnchorPoint())
            unit.__touchWidget:setPosition(x, y)
        end
    end
end

function TextField:onEventLabelTouchOperation(label, event, worldPos)
    if label then
        local aroundUnits = {label}
        local index = table.indexof(self._units, label);
        local tempIndex = index - 1;
        while true do--往前找同类
            local testUnit = self._units[tempIndex];
            if testUnit and testUnit.__htmlEvent == label.__htmlEvent then
                TableUtil.unshift(aroundUnits, testUnit, false);
                tempIndex = tempIndex - 1;
            else
                break;
            end
        end
        tempIndex = index + 1
        while true do--往后找同类
            local testUnit = self._units[tempIndex];
            if testUnit and testUnit.__htmlEvent == label.__htmlEvent then
                TableUtil.push(aroundUnits, testUnit, false);
                tempIndex = tempIndex + 1;
            else
                break;
            end
        end
        local isPushDown = event == ccs.TOUCH_EVENT_BEGAN;
        local isClick = event == ccs.TOUCH_EVENT_ENDED;
        for k,v in pairs(aroundUnits) do
            v.__isPushingDown = isPushDown
            if tolua.type(v) == TextField.LABEL_CPP_NAME then
                if isPushDown then
                    local c = DisplayUtil.rgb2ccc3("#ff9900")
                    -- v:setTextColor(c)
                    v:setColor(c) --Label的setTextColor和node的setColor会有重叠现象，同时设置颜色失真
                else
                    -- v:setTextColor(v.__origColor);
                    v:setColor(v.__origColor); --Label的setTextColor和node的setColor会有重叠现象，同时设置颜色失真
                end
            end
        end

        if isClick then
            audioMgr:playDefaultBtnClickSound()
            if not self._linkClickSignal:isEmpty() then
                self._linkClickSignal:emit(label.__htmlEvent, worldPos)
            else
                self:onDefaultTextLinkHooker(label.__htmlEvent, worldPos);
            end
        end
    end
end

--钩子函数:默认的超连接处理
function TextField:onDefaultTextLinkHooker(htmlEvent)
end

function TextField:onScrollTouchFromClickSignal(worldPos, event)
    for i,v in ipairs(self._units) do
        if v.__touchWidget and v.__touchWidget:hitTest(worldPos, nil, nil) then
            self:onEventLabelTouchOperation(v, event, worldPos);
            return;
        end
    end
    --补刀,某些触摸情况下，上面的找不到，有可能是因为触摸范围变化了，v.__touchWidget:hitTest(worldPos, nil, nil)通不过
    for i,v in ipairs(self._units) do
        if v.__touchWidget and v.__isPushingDown then
            self:onEventLabelTouchOperation(v, event, worldPos);
            return;
        end
    end
end

function TextField:onScrollTouchFromPushSignal(isPusDown, worldPos, event)
    if event ~= ccs.TOUCH_EVENT_ENDED then--ccs.TOUCH_EVENT_ENDED也不在这里判断，在click那里判断，因为click会在移动时取消click，比较准确
        self:onScrollTouchFromClickSignal(worldPos, event)
    end
end

function TextField:onTouchWidgeTouchOperation(target, event)
    if event ~= ccs.TOUCH_EVENT_MOVED then
        local worldPos = nil;
        if event == ccs.TOUCH_EVENT_BEGAN then
            worldPos = DisplayUtil.ccpCopy(target:getTouchBeganPosition());
        else
            worldPos = DisplayUtil.ccpCopy(target:getTouchEndPosition());
        end
        if target.__labelOfTouchWidget then
            self:onEventLabelTouchOperation(target.__labelOfTouchWidget, event, worldPos)
        end
    end
end

function TextField:checkNodeWithEvent(htmlNodeVo, node)
    if htmlNodeVo.event and node and node.__touchWidget == nil then
        node.__htmlEvent = htmlNodeVo.event;
        local uiWidget = ccui.Widget:create();

        -- 下面代码是有颜色的
        -- local uiWidget = ccui.Layout:create();
        -- uiWidget:setBackGroundColorType(1)
        -- uiWidget:setBackGroundColor(cc.c4b(0, 255, 0, 255))
        -- uiWidget:setBackGroundColorOpacity(100)

        uiWidget:setAnchorPoint(cc.p(0, 0));
        uiWidget:setContentSize(node:getContentSize());
        self._unitParent:addChild(uiWidget);
        if not self._scrollView then
            uiWidget:setTouchEnabled(true);
            uiWidget:addTouchEventListener(handler(self, self.onTouchWidgeTouchOperation));
        else
            uiWidget:setTouchEnabled(false);
        end
        -- if tolua.type(node) == TextField.LABEL_CPP_NAME then
        --     node:enableUnderline()
        -- end
        node.__touchWidget = uiWidget;
        node.__touchWidget.__labelOfTouchWidget = node;
    end
end

-- 检查哪个字符索引超出宽度，注意非ascii的当3个长度来计算，截取出来的是非utf8得索引
function TextField:checkWhichCharOverWidth(curX, htmlNodeVo)
    local fontSize = htmlNodeVo.fontSize;
    local len = #htmlNodeVo.txt;
    local i = 1;
    local result = 0;
    if self._width > 0 then
        while i <= len do
            local char = string.sub(htmlNodeVo.txt, i, i)
            local charWidth = 0
            if StringUtil.isAsciiChar(char) then --ascii字符码内
                if self._isWrapPrecise then
                    _labelCheckWidth:setSystemFontSize(fontSize)
                    _labelCheckWidth:setString(char);
                    charWidth = _labelCheckWidth:getContentSize().width;
                    -- print("字体宽度", char, charWidth)
                else
                    local factor = _charWidths[char];
                    if not factor then
                        if string.find(char, "%p") ~= nil then--标点
                            factor = 0.25;
                        else
                            factor = 0.5
                        end
                    end
                    charWidth = fontSize * factor;
                end
                curX = curX + charWidth;
                if curX > self._width then
                    result = i;
                    break;
                end
                i = i + 1;
            else
                curX = curX + fontSize-20;
                if curX > self._width then
                    result = i;
                    break;
                end
                i = i + 3;
            end
        end
    end

    return result;
end

function TextField:setHAlign(hAlign)
    if self._hAlign ~= hAlign then
        self._hAlign = hAlign;
        self:updateAlignPositionX();
    end
end

function TextField:getHAlign()
    return self._hAlign
end

function TextField:updateAlignPositionX()
    local lineOneXOffset = 0;
    for i, units in ipairs(self._lineUnits) do
        local offset = 0;
        if self._hAlign == TextField.H_CENTER then
            offset = (self._width - units._lineWidth) * .5;
        elseif self._hAlign == TextField.H_RIGHT then
            if i == 1 then--第一行才右对齐
                offset = self._width - self:getTextWidth()--units._lineWidth;
                lineOneXOffset = offset;
            else
                offset = lineOneXOffset
            end
        end
        local curX = 0;
        local unitsNum = #units
        for j, unit in ipairs(units) do
            local realWidth = self:getUnitRealWidth(unit);
            self:setUnitPosition(unit, curX + offset + realWidth * unit:getAnchorPoint().x);
            curX = curX + realWidth + self._hOffset
        end
    end
end

function TextField:getUnitRealWidth(unit)
    local realWidth = 0;
    if unit.__spaceWidth and unit.__spaceWidth ~= 0 then
        realWidth = unit.__spaceWidth;
        local ap = unit:getAnchorPoint();
        if ap.x ~= 0.5 then
            unit:setAnchorPoint(cc.p(0.5, ap.y))
        end
    else
        realWidth = unit:getContentSize().width * unit:getScaleX();
    end
    realWidth = realWidth + (unit.__deltaWidth or 0)
    return math.max(0, realWidth);
end

function TextField:getUnitRealHeight(unit, try2ChangeAnchorPoint)
    local realHeight = 0;
    if unit.__spaceHeight and unit.__spaceHeight ~= 0 then
        realHeight = unit.__spaceHeight;
        local ap = unit:getAnchorPoint();
        if ap.y ~= 0.5 then
            unit:setAnchorPoint(cc.p(ap.x, 0.5))
        end
    else
        realHeight = unit:getContentSize().height * unit:getScaleY();
    end
    realHeight = realHeight + (unit.__deltaHeight or 0)
    return math.max(0, realHeight);
end

function TextField:setVAlign(vAlign)
    if self._vAlign ~= vAlign then
        self._vAlign = vAlign;
        self:updateAlignPositionY();
    end
end

function TextField:updateAlignPositionY()
    local curY = 0;
    if self._vAlign == TextField.V_BOTTOM then
        curY = self._textHeight
    end
    local firstLineBottom2OffsetInVTop = 0;
    for i, units in ipairs(self._lineUnits) do
        if self._vAlign == TextField.V_BOTTOM then
            curY = curY - units._lineHeight;
        elseif self._vAlign == TextField.V_TOP then
            if i == 1 then--第一行
                firstLineBottom2OffsetInVTop = units._bottomMargin or 0;
                curY = - units._bottomMargin;
            else
                curY = curY - units._lineHeight;
            end
        end
        for j, unit in ipairs(units) do
            local realHeight = self:getUnitRealHeight(unit);
            local offset = 0;
            local type = unit.__htmlVoType
            if type == HtmlNodeVo.IMG or type == HtmlNodeVo.CCNODE then
                if self._isAssetVCenter then
                    offset = self._imgOffsetY + (self._defaultFontSize - realHeight) * .5;
                end
            end
            self:setUnitPosition(unit, nil, curY + units._bottomMargin + realHeight * unit:getAnchorPoint().y + offset);
        end
        local gap = units.breakLineGapOffset;
        curY = curY - self._vGap - units.breakLineGapOffset;
    end
end

function TextField:checkNodeSpecailProperties(node, htmlNodeVo)
    node.__offsetX = htmlNodeVo.offsetX
    node.__offsetY = htmlNodeVo.offsetY
    node.__spaceWidth = htmlNodeVo.spaceWidth
    node.__spaceHeight = htmlNodeVo.spaceHeight
    node.__deltaWidth = htmlNodeVo.deltaWidth
    node.__deltaHeight = htmlNodeVo.deltaHeight
    node.__htmlVoType = htmlNodeVo.type
end

function TextField:createCCNodeByHtmlNode(htmlNodeVo)
    local node = nil;
    if TextField.CCNodeCreater then
        node = TextField.CCNodeCreater(htmlNodeVo)
    end

    if not node then
        node = display.newNode();
        node:setContentSize(cc.size(htmlNodeVo.width, htmlNodeVo.height))
    end
    self:scaleNode(node, htmlNodeVo)
    return node
end

function TextField:createSpaceNodeByHtmlNode(htmlNodeVo)
    local width = htmlNodeVo.width;
    local height = htmlNodeVo.height;
    local node = nil;
    if width ~= 0 or height ~= 0 then
        if width <= 0 then
            width = 0.01;
        end
        if height <= 0 then
            height = 0.01;
        end
        node = display.newNode();
        node:setContentSize(cc.size(width, height))
        node:retain()
    end
    return node;
end

function TextField:createImgByHtmlNode(htmlNodeVo)
    -- htmlNodeVo.imgSrc = ResConfig.getAssetPath("ui/hero_buy/yingxiongguanli.png")
    local img = display.newSprite(htmlNodeVo.imgSrc);
    img:retain();
    self:scaleNode(img, htmlNodeVo)
    return img;
    -- return display.newSprite(resMgr:getTpFrame("ResFontHT" .. tostring(math.random(0, 9))));
end

-- 被重写吧
function TextField:try2Cache(node)
    return false;
end

function TextField:scaleNode(node, htmlNodeVo)
    local width = node:getContentSize().width;
    local height = node:getContentSize().height;
    local scaleX = 0;
    local scaleY = 0;
    if htmlNodeVo.width then
        scaleX = htmlNodeVo.width / width;
    end
    if htmlNodeVo.height then
        scaleY = htmlNodeVo.height / height;
    end
    if scaleX == 0 then
        scaleX = scaleY
    elseif scaleY == 0 then
        scaleY = scaleX;
    end
    if scaleX ~= 0 then
        node:setScaleX(scaleX)
    end

    if scaleY ~= 0 then
        node:setScaleY(scaleY);
    end
end

function TextField:destroy()
    self._isRenderOnlyInDisplayList = false;
    textFieldMgr:remove(self);
    self:setHtmlText("");--清空所有unit
    if self._scrollView then
        self._scrollView:destroy()
        self._scrollView = nil;
    end

    if self._linkClickSignal then
        self._linkClickSignal:removeAll();
        self._linkClickSignal = nil;
    end
    self:removeFromParent();
    self:release();
end