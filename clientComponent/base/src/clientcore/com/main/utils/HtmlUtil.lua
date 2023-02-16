--
-- Author: senji
-- Date: 2014-03-05 15:49:42
--
HtmlUtil = {};

HTML_COLOR_BLACK = "#000000"
HTML_COLOR_YELLOW = "#FFFF00"
HTML_COLOR_RED = "#FF0000"
HTML_COLOR_BLUE = "#0000FF"
HTML_COLOR_GREEN = "#00FF00"
HTML_COLOR_WHITE = "#FFFFFF"
HTML_COLOR_PURPLE = "#800080"
HTML_COLOR_ORANGE = "#FFA500"
HTML_COLOR_GRAY = "#808080"

function HtmlUtil.createBlackTxt(txt, size)
    return HtmlUtil.createFontTxt(txt, nil, HTML_COLOR_BLACK, size);
end

function HtmlUtil.createWhiteTxt(txt, size)
    return HtmlUtil.createFontTxt(txt, nil, HTML_COLOR_WHITE, size);
end

function HtmlUtil.createYellowTxt(txt, size)
    return HtmlUtil.createFontTxt(txt, nil, HTML_COLOR_YELLOW, size);
end

function HtmlUtil.createOrangeTxt(txt, size)
    return HtmlUtil.createFontTxt(txt, nil, HTML_COLOR_ORANGE, size);
end

function HtmlUtil.createGreenTxt(txt, size)
    return HtmlUtil.createFontTxt(txt, nil, HTML_COLOR_GREEN, size);
end

function HtmlUtil.createRedTxt(txt, size)
    return HtmlUtil.createFontTxt(txt, nil, HTML_COLOR_RED, size);
end

function HtmlUtil.createPurpleTxt(txt, size)
    return HtmlUtil.createFontTxt(txt, nil, HTML_COLOR_PURPLE, size);
end

function HtmlUtil.createBlueTxt(txt, size)
    return HtmlUtil.createFontTxt(txt, nil, HTML_COLOR_BLUE, size);
end

function HtmlUtil.createFontSizeTxt(txt, size)
    return HtmlUtil.createFontTxt(txt, nil, nil, size)
end

function HtmlUtil.createColorTxt(txt, color, size)
    if StringUtil.isStringValid(color) then
        return HtmlUtil.createFontTxt(txt, nil, color, size)
    else
        return txt
    end
end

function HtmlUtil.createFontTxt(txt, font, color, size, offsetX, offsetY, spaceWidth, spaceHeight)
    if type(txt) ~= "string" then
        txt = tostring(txt);
    end
    local properties = {
        font = font,
        color = color and tostring(color) or nil,
        size = size,
        offsetX = offsetX, 
        offsetY = offsetY, 
        spaceWidth = spaceWidth, 
        spaceHeight = spaceHeight
    };
    return "<font" .. HtmlUtil.createPropertyStrByTable(properties) .. ">" .. txt .. "</font>";
end

function HtmlUtil.createEvent(txt, event)
    local properties = {
        href = "event:" .. event
    }
    return "<a" .. HtmlUtil.createPropertyStrByTable(properties) .. ">" .. txt .. "</a>";
end

function HtmlUtil.createImg(imgSrc, width, height, offsetX, offsetY, spaceWidth, spaceHeight, deltaWidth, deltaHeight)
    local properties = {
        width = width,
        height = height,
        offsetX = offsetX,
        offsetY = offsetY,
        spaceWidth = spaceWidth,
        spaceHeight = spaceHeight,
        deltaWidth = deltaWidth,
        deltaHeight = deltaHeight,
    };
    return "<img src ='" .. imgSrc .. "'" .. HtmlUtil.createPropertyStrByTable(properties) .. "></img>"--shengsmark，TODO 这里先增加标签尾</img>，否则图片后面加文字，文字会继承图片的offset属性等，详细查看HtmlParser.parseHtml
end

function HtmlUtil.createPropertyStrByTable(valueDic, prefrixStr)
    local result = prefrixStr or ""
    for k,v in pairs(valueDic) do
        result = HtmlUtil.createPropertyStr(k, v, result)
    end

    return result;
end

function HtmlUtil.createPropertyStr(propertyName, value, prefrixStr)
    prefrixStr =  prefrixStr or "";
    local result = "";
    if value and value ~= 0 and value ~= "" then
        result = " " .. propertyName .. " = '" .. tostring(value) .. "'";
    end

    return prefrixStr .. result;
end

function HtmlUtil.createSpacer(width, height)
    local properties = {
        width = width,
        height = height
    };
    return "<space" .. HtmlUtil.createPropertyStrByTable(properties) .. "/>";
end

function HtmlUtil.createVGap(gap)
    return HtmlUtil.createBr() .. HtmlUtil.createSpacer(nil, gap) .. HtmlUtil.createBr();
end

function HtmlUtil.createBr()
    return "<br>";
end