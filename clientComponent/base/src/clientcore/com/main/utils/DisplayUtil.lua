--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-6
-- Time: AM11:32
--
--DisplayUtil = {};
module("DisplayUtil", package.seeall);

function centerLocate(node, width, height)
    assert(node ~= nil, "why node is nil?");
    width = width or display.widthInPixels;
    height = height or display.heightInPixels;
    node:setPosition(cc.p(width * .5, height * .5));
    return node;
end

function setSpecialOffsetZorder(node, zorder)
    zorder = zorder or 0;
    if node then
        if node.setSpecialOffsetZorder then
            node:setSpecialOffsetZorder(zorder)
        else
            node.__specialOffsetZorder = zorder
        end
    end
end

function addChild2(childNode, parentNode)
    if childNode:getParent() ~= parentNode then
        childNode:retain();
        childNode:removeFromParent();
        parentNode:addChild(childNode,10000);
        childNode:release();
    end
end

function insertChild2(childNode, parentNode)
    local pos = getPositionFromTo(childNode:getParent(), parentNode, DisplayUtil.ccpCopy(childNode:getPosition()));
    childNode:retain();
    childNode:removeFromParent();

    childNode:setPosition(pos);
    parentNode:addChild(childNode);
    childNode:release();
end

--转换sprite的坐标时，sprite的锚点在中心点，转换时会有偏移1/2*contentSize的情况，建议使用switchParentTo2
function switchParentTo(child, toParent)
    local childParent = child:getParent();
    if childParent and childParent ~= toParent then
        local pos = getPositionFromTo(child, toParent);
        child:setPosition(pos.x, pos.y);
        setAddOrRemoveChild(child, toParent, true);
    end
end

--修正转换sprite时，转换后由于锚点问题坐标会有偏移的问题。转换父节点的坐标为世界坐标，再用自己的坐标计算最终位置
function switchParentTo2(child, toParent)
    local childParent = child:getParent();
    if childParent and childParent ~= toParent then
        local pos = getPositionFromTo(childParent, toParent, cc.p(child:getPosition()));
        child:setPosition(pos.x, pos.y);
        setAddOrRemoveChild(child, toParent, true);
    end
end

-- 是否在显示列表中（即是否在当前scene上并且是可见的）
function isInDisplayList(node, testScene)
    local result = false
    if node.isInDisplayList then
        -- DebugUtil.beginMark("cpp_isInDisplayList")
        result =  node:isInDisplayList();
        -- DebugUtil.endMark("cpp_isInDisplayList")
    else
        -- DebugUtil.beginMark("lua_isInDisplayList")
        local curScene = testScene or cc.Director:getInstance():getRunningScene();
        if curScene and curScene:isVisible() then
            while node do
                if not node:isVisible() then
                    result = false;
                    break
                elseif node == curScene then
                    result = true;
                    break
                else
                    node = node:getParent()
                end
            end
        end
        -- DebugUtil.endMark("lua_isInDisplayList")
    end
    return result;
end

function calPositionInDisplayList(from, toParent)
    local test = from;
    local x, y = 0, 0;
    while test do
        local tempX, tempY = test:getPosition()
        x = x + tempX;
        y = y + tempY;

        if test == toParent then
            test = nil;
        else
            test = test:getParent();
        end
    end

    return x, y;
end

function getPositionFromTo(from, to, pos)
    pos = pos or cc.p(0,0);
    return to:convertToNodeSpace(from:convertToWorldSpace(DisplayUtil.ccpCopy(pos)));
end

function setAllCascadeOpacityEnabled(ccnode)
    if ccnode.setCascadeOpacityEnabled then
        ccnode:setCascadeOpacityEnabled(true);
    end
    if ccnode.getChildren then
        local childrenArr = ccnode:getChildren();
        if childrenArr then
            local childNum = #childrenArr;
            for i = 1, childNum do
                local child = childrenArr[i];
                setAllCascadeOpacityEnabled(child);
            end
        end
    end
end

function ccpCopy(ccpointOrX, y)
    if y then
        return cc.p(ccpointOrX, y)
    else
        return cc.p(ccpointOrX.x, ccpointOrX.y);
    end
end

-- ccc3值转换成rgb字符串
--返回 FF00FF六位字符串
function ccc32RGB(ccc3)
    local rStr = string.format("%02X", ccc3.r)
    local gStr = string.format("%02X", ccc3.g)
    local bStr = string.format("%02X", ccc3.b);
    return rStr .. gStr .. bStr;
end


-- rgb值转换成ccc3
--rbg值为：#ffffff 或者 0xFFFFff 之类，不分大小写
function rgb2ccc3(rgb)
    if not rgb or rgb == "" then
        return nil;
    end
    if type(rgb) == "string" then
        rgb = string.gsub(rgb, "#", "0x");
        rgb = checknumber(rgb, 16);
    end

    local b = math.floor(rgb % 256)
    local g = math.floor(rgb / 256 % 256);
    local r = math.floor(rgb / 256 / 256 % 256);
    local a = 255;
    -- print(r,g,b)
    return cc.c4b(r, g, b, a);
end

-- /*
-- * 范围0-360 or 0-2pi
-- * */
function getRotationByVxVy(vx, vy, degreeOrRadians)
    if degreeOrRadians == nil then
        degreeOrRadians = true;
    end
    vy = -vy; --y轴坐标和flash的相反，但是rotaion方向却是一样。。。。
    local result = 0;
    if vx == 0 then
        local a = -1;
        if vy > 0 then
            a = 1;
        end
        result = a * 90 + 180;
    else
        result = math.atan2(vy, vx) * (180 / math.pi) + 180;
    end

    if not degreeOrRadians then
        result = result * math.pi / 180;
    end
    return result;
end

function calRotationByV(vx, vy)
    if vx == 0 then
        if vy > 0 then
            return 90;
        else
            return -90;
        end
    else
        return math.atan2(vy, vx) * 180;
    end
end

-- mode的参数如下
-- 0 居中
-- 1 左上
-- 2 左中
-- 3 左下
-- 4 下中
-- 5 右下
-- 6 右中
-- 7 右上
-- 8 上中
function locateReal(mode, node, winWidth, winHeight, nodeWidth, nodeHeight, offsetX, offsetY)
    local dspWidth = (nodeWidth or node:getContentSize().width) * node:getScaleX();
    local dspHeight = (nodeHeight or node:getContentSize().height) * node:getScaleY();
    local isIgnoreAnchor = false;
    if node.isIgnoreAnchorPointForPosition then
        isIgnoreAnchor = node:isIgnoreAnchorPointForPosition();
    end
    offsetX = offsetX or 0;
    offsetY = offsetY or 0;
    local anchorX = 0;
    local anchorY = 0;
    if not isIgnoreAnchor then
        anchorX = node:getAnchorPoint().x;
        anchorY = node:getAnchorPoint().y;
    end
    winWidth = winWidth or CUR_SELECTED_WIDTH;
    winHeight = winHeight or CUR_SELECTED_HEIGHT;
    local resultX = 0;
    local resultY = 0;

    if mode == 0 then --居中
        resultX = (winWidth - dspWidth) * .5 + dspWidth * anchorX;
        resultY = (winHeight - dspHeight) * .5 + dspHeight * anchorY;
    elseif mode == 1 then --左上
        resultX = dspWidth * anchorX;
        resultY = (winHeight - dspHeight) + dspHeight * anchorY;
    elseif mode == 2 then --左中
        resultX = dspWidth * anchorX;
        resultY = (winHeight - dspHeight) * .5 + dspHeight * anchorY;
    elseif mode == 3 then --左下
        resultX = dspWidth * anchorX;
        resultY = dspHeight * anchorY;
    elseif mode == 4 then --下中
        resultX = (winWidth - dspWidth) * .5 + dspWidth * anchorX;
        resultY = dspHeight * anchorY;
    elseif mode == 5 then --右下
        resultX = winWidth - dspWidth * (1 - anchorX);
        resultY = dspHeight * anchorY;
    elseif mode == 6 then --右中
        resultX = winWidth - dspWidth * (1 - anchorX);
        resultY = (winHeight - dspHeight) * .5 + dspHeight * anchorY;
    elseif mode == 7 then --右上
        resultX = winWidth - dspWidth * (1 - anchorX);
        resultY = (winHeight - dspHeight) + dspHeight * anchorY;
    elseif mode == 8 then --上中
        resultX = (winWidth - dspWidth) * .5 + dspWidth * anchorX;
        resultY = (winHeight - dspHeight) + dspHeight * anchorY;
    end
    node:setPosition(cc.p(resultX + offsetX, resultY + offsetY));
end

function centerLocateReal(node, winWidth, winHeight, nodeWidth, nodeHeight)
    locateReal(0, node, winWidth, winHeight, nodeWidth, nodeHeight)
end

function leftUpLocateReal(node, winWidth, winHeight, nodeWidth, nodeHeight)
    locateReal(1, node, winWidth, winHeight, nodeWidth, nodeHeight)
end

function checkObjShowing(displayObj)
    return isInDisplayList(displayObj)
end

function createLayerAnchor2LeftDown(cascadeOpacityEnabled)
    local result = display.newLayer();
    result:setAnchorPoint(cc.p(0, 0));
    if cascadeOpacityEnabled then
        result:setCascadeOpacityEnabled(cascadeOpacityEnabled);
    end
    return result;
end

function createSpriteAnchor2LeftDown(cascadeOpacityEnabled)
    local result = display.newSprite();
    result:setAnchorPoint(cc.p(0, 0));
    if cascadeOpacityEnabled then
        result:setCascadeOpacityEnabled(cascadeOpacityEnabled);
    end
    return result;
end

function scale2(node, toWidth, toHeight)
    local size = node:getContentSize()
    local scaleX = toWidth / size.width;
    local scaleY = toHeight / size.height;
    node:setScaleX(scaleX)
    node:setScaleY(scaleY)
    return scaleX, scaleY;
end

function scale2Full(node, toWidth, toHeight)
    local size = node:getContentSize()
    local scaleFactor = toWidth / size.width;
    scaleFactor = math.max(scaleFactor, toHeight / size.height);
    node:setScale(scaleFactor);
    return scaleFactor;
end

function scale2Fit(node, toWidth, toHeight, nodeWidth, nodeHeight)
    local size = node:getContentSize()
    nodeWidth = nodeWidth or size.width
    nodeHeight = nodeHeight or size.height
    local scaleFactor = toWidth / nodeWidth;
    scaleFactor = math.min(scaleFactor, toHeight / nodeHeight);
    node:setScale(scaleFactor);
    return scaleFactor;
end

function getScaleFactor(node, toWidth, toHeight, nodeWidth, nodeHeight)
    local size = node:getContentSize()
    nodeWidth = nodeWidth or size.width
    nodeHeight = nodeHeight or size.height
    local scaleFactorW = toWidth / nodeWidth;
    local scaleFactorH = toHeight / nodeHeight;
    return scaleFactorW, scaleFactorH;
end

function scale2FitScreen(node, fixWidth, fixHeight)
    fixWidth = fixWidth or node:getContentSize().width;
    fixHeight = fixHeight or node:getContentSize().height;
    local scaleFactor = display.widthInPixels / fixWidth;
    scaleFactor = math.min(scaleFactor, display.heightInPixels / fixHeight);
    node:setScale(scaleFactor);
    return scaleFactor;
end

function setVisible(node, b)
    if b then
        node:setVisible(true)
        node:setOpacity(255)
    else
        node:setVisible(false)
        node:setOpacity(0)
    end
end

function setInvisibleAndTransparent(node)
    setVisible(node, false)
end

function setAddOrRemoveChild(child, parent, addOrRemove)
    if addOrRemove then
        addChild2(child, parent);
    else
        child:removeFromParent();
    end
end


function setTxtFont(label, fontName)
    if fontName then
        if label.setFontName then
            label:setFontName(fontName);
        elseif label.setSystemFontName then
            label:setSystemFontName(fontName);
        end
    end
end

function hitTestNode(node, point, isCascade)
    local nsp = node:convertToNodeSpace(point)
    local rect
    if isCascade then
        rect = node:getCascadeBoundingBox()
    else
        rect = node:getBoundingBox()
    end
    rect.x = 0
    rect.y = 0

    return cc.rectContainsPoint(rect, nsp);
end

function createEaseOutMove(duration, pos)
    return cc.EaseSineOut:create(cc.MoveTo:create(duration, pos))
end