--
-- Author: senji
-- Date: 2014-03-05 01:18:39
--
requireClientCore("luatextfield.HtmlNodeVo")

local CaptureNode = class_quick("CaptureNode")
function CaptureNode:ctor(contentStr, beginPos, endPos, isBegin, type, isNotSeperate)
    self.contentStr = contentStr;
    self.beginPos = beginPos;
    self.endPos = endPos;
    self.isBegin = isBegin;
    self.type = type;
    self.isNotSeperate = isNotSeperate; -- true则为那些没有标签尾的独立标签，例如<img/> <br> 这样
end

-- 标签
local _underLineBeginReg = "()(<u>)()";
local _underLineEndReg = "()(</u>)()";
local _fontBeginReg = "()(<font[^>]*>)()";
local _fontEndReg = "()(</font>)()"
local _linkBeginReg = "()(<a [^>]*>)()";
local _linkEndReg = "()(</a>)()";
local _imgBeginReg = "()(<img[^>]*>)()";
local _imgEndReg = "()(</img>)()";
local _spaceBeginReg = "()(<space[^>]*>)()";
local _spaceEndReg = "()(</space>)()";
local _ccnodeBeginReg = "()(<ccnode[^>]*>)()";
local _ccnodeEndReg = "()(</ccnode>)()";
local _brReg = "()(<br[^>]*>)()";

-- 属性
local _fontFaceReg = "face *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --字体的匹配模式
local _fontColorReg = "color *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --颜色的匹配模式
local _fontSizeReg = "size *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --字体大小的匹配模式
local _eventReg = "href *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --事件的匹配模式
local _imgSrcReg = "src *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --图片资源
local _widthReg = "width *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --图片宽
local _heightReg = "height *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --图片高
local _offsetXReg = "offsetX *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --偏移x
local _offsetYReg = "offsetY *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --偏移y
local _spaceWidthReg = "spaceWidth *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --固定宽度
local _spaceHeightReg = "spaceHeight *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --固定高度
local _deltaWidthReg = "deltaWidth *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --宽度便宜值
local _deltaHeightReg = "deltaHeight *= *[\'\"]?([^\'\" ]+)[\'\"]? ?"; --高度便宜值

HtmlParser = {};
-- 目前支持的格式：
-- <font face="字体" size ="字体大小" color="#ffffff颜色rgb">文字内容</font>
-- <br> <br height = '10'>--换行并且可以设置下一行的间距，这个是特别支持，不是正规的html风格
-- <img src="" width ="" height="">：width和height如果没定义的话，则按照原来大小，只定义一个的话，另一个会等比改变
-- <space width = '' height = ''>
-- <ccnode /> 可扩展的cocos2dx组件
-- <a herf=''>/a> 超链接
-- 每个图片，文本， node，都有spaceWidth, spaceHeight属性
-- 
function HtmlParser.parseHtml(str, defaultFont, defaultFontSize, defaultFontColor, isBreak2Char)
    -- local t = tickMgr:getTimer()
    if not str or str == "" then
        return str, nil;
    end
    defaultFont = defaultFont or "" or --[[noi18n]]"微软雅黑";
    defaultFontSize = defaultFontSize or 24;
    defaultFontColor = defaultFontColor or "#ffffff";
    local defaultNodeVo = HtmlNodeVo.new("", defaultFont, defaultFontSize, defaultFontColor);
    str = string.restorehtmlspecialchars(str);
    str = string.gsub(str, "\\n", HtmlUtil.createBr());
    str = string.gsub(str, "\n", HtmlUtil.createBr());
    str = string.gsub(str, "\\r", HtmlUtil.createBr());
    str = string.gsub(str, "\r", HtmlUtil.createBr());
    str = HtmlUtil.createFontTxt(str, defaultNodeVo.font, defaultNodeVo.fontColor, defaultNodeVo.fontSize)
    -- print("处理html，gsub消耗", tickMgr:getTimer() - t)
    -- t = tickMgr:getTimer()
    local pureStr = "";

    -- print("html文本：\n",str);
    local captures = {};

    HtmlParser.parsePattern(str, _fontBeginReg, captures, true, HtmlNodeVo.TXT);
    HtmlParser.parsePattern(str, _fontEndReg, captures, false, HtmlNodeVo.TXT);
    HtmlParser.parsePattern(str, _linkBeginReg, captures, true, HtmlNodeVo.TXT);
    HtmlParser.parsePattern(str, _linkEndReg, captures, false, HtmlNodeVo.TXT);
    HtmlParser.parsePattern(str, _underLineBeginReg, captures, true, HtmlNodeVo.TXT);
    HtmlParser.parsePattern(str, _underLineEndReg, captures, false, HtmlNodeVo.TXT);
    HtmlParser.parsePattern(str, _imgBeginReg, captures, true, HtmlNodeVo.IMG);
    HtmlParser.parsePattern(str, _imgEndReg, captures, false, HtmlNodeVo.IMG);
    HtmlParser.parsePattern(str, _ccnodeBeginReg, captures, true, HtmlNodeVo.CCNODE);
    HtmlParser.parsePattern(str, _ccnodeEndReg, captures, false, HtmlNodeVo.CCNODE);
    HtmlParser.parsePattern(str, _spaceBeginReg, captures, true, HtmlNodeVo.SPACE);
    HtmlParser.parsePattern(str, _spaceEndReg, captures, false, HtmlNodeVo.SPACE);
    HtmlParser.parsePattern(str, _brReg, captures, true, HtmlNodeVo.BR);


    -- print("处理html，正则部分消耗", tickMgr:getTimer() - t)
    -- t = tickMgr:getTimer()

    table.sort(captures, function(a, b) return a.beginPos < b.beginPos end); --排序
    local resultNodes = {};
    local len = #captures;
    local beginIndex = 0;
    local endIndex = 0;
    local curOpPosition = 1;
    local layerStack = {}; --放置每一层的格式
    local parentNodeVo = defaultNodeVo;
    for i = 1, len do
        local curNode = captures[i];
        local preNode = captures[i - 1];
        local nextNode = captures[i + 1];
        local nodeVo = nil;
        if curNode.isBegin then --标签头
            local parentIndex = beginIndex - endIndex;
            parentNodeVo = layerStack[parentIndex];
            beginIndex = beginIndex + 1;
            if curNode.isNotSeperate then --不分离的标签，例如<img/> <br>这样
                endIndex = endIndex + 1;
            end
            --先检查preNode是标签尾或者独立标签，和curNode（也是标签头） 之间的文字
            if preNode and (not preNode.isBegin or preNode.isNotSeperate) and curNode.beginPos - preNode.endPos > 1 then
                nodeVo = HtmlParser.parseCurNode(str, preNode, curNode, parentNodeVo, true, HtmlNodeVo.TXT);
                -- print("begin tab preNode", nodeVo.txt, nodeVo.type, preNode.contentStr,"差：",curNode.beginPos , preNode.endPos)
                -- if nodeVo.type ~= HtmlNodeVo.TXT or StringUtil.isStringValid(nodeVo.txt) then
                    pureStr = pureStr .. nodeVo.txt;
                    resultNodes[#resultNodes + 1] = nodeVo;
                -- end
            end
            --检查当前node
            if curNode.isNotSeperate or nextNode then
                nodeVo = HtmlParser.parseCurNode(str, curNode, nextNode, parentNodeVo);
                -- print("begin tab curNode", nodeVo.txt, nodeVo.type, curNode.contentStr, nextNode)
                -- if nodeVo.type ~= HtmlNodeVo.TXT or StringUtil.isStringValid(nodeVo.txt) then
                    pureStr = pureStr .. nodeVo.txt;
                    resultNodes[#resultNodes + 1] = nodeVo;
                    layerStack[parentIndex + 1] = nodeVo;
                -- end
            end
        else --标签尾
            -- shengsmark 这里原来是先判断下面nextNode的if，然后else判断在判断下面prenode的if，结果发现出现bug了
            -- 改成如下，待观察
            if preNode.isNotSeperate and curNode.beginPos - preNode.endPos > 1 then
                -- 标签尾和前一个独立标签之间，往前检查
                local parentIndex = beginIndex - endIndex;
                parentNodeVo = layerStack[parentIndex];
                nodeVo = HtmlParser.parseCurNode(str, preNode, curNode, parentNodeVo, true, HtmlNodeVo.TXT);
                -- print("end tag nodeVo2", nodeVo.txt, nodeVo.type, curNode.contentStr,preNode)
                -- if nodeVo.type ~= HtmlNodeVo.TXT or StringUtil.isStringValid(nodeVo.txt) then
                    pureStr = pureStr .. nodeVo.txt;
                    resultNodes[#resultNodes + 1] = nodeVo;
                -- end
            end

            if nextNode and not nextNode.isBegin and nextNode.beginPos - curNode.endPos > 1 then
                -- 检查标签尾跟下一个标签尾之间的文字，往后检查
                local parentIndex = beginIndex - endIndex - 1;
                parentNodeVo = layerStack[parentIndex];
                nodeVo = HtmlParser.parseCurNode(str, curNode, nextNode, parentNodeVo, false, HtmlNodeVo.TXT);
                -- print("end tag nodeVo1", nodeVo.txt, nodeVo.type, curNode.contentStr,parentIndex)
                -- if nodeVo.type ~= HtmlNodeVo.TXT or StringUtil.isStringValid(nodeVo.txt) then
                    pureStr = pureStr .. nodeVo.txt;
                    resultNodes[#resultNodes + 1] = nodeVo;
                    layerStack[parentIndex + 1] = nodeVo;
                -- end
            end

            if beginIndex > 0 then
                endIndex = endIndex + 1;
            end
        end
    end

    -- print("处理html，for循环部分消耗", tickMgr:getTimer() - t)
    -- t = tickMgr:getTimer()

    if isBreak2Char then
        local newResult = {};
        for i,nodeVo in ipairs(resultNodes) do
            local charNodes = HtmlParser.breakNodeByChar(nodeVo);
            if charNodes then
                newResult = TableUtil.concat(newResult, charNodes);
            end
        end

        resultNodes = newResult;
    end

    -- print("处理html，breakChar部分消耗", tickMgr:getTimer() - t)
    -- t = tickMgr:getTimer()

    return pureStr, resultNodes;
end

function HtmlParser.parseCurNode(str, curNode, nextNode, parentNodeVo, checkBackWord, forceType)
    local txt = "";
    if not curNode.isNotSeperate or checkBackWord then
        txt = string.sub(str, curNode.endPos + 1, nextNode.beginPos - 1);
    end

    local font = string.match(curNode.contentStr, _fontFaceReg);
    local color = string.match(curNode.contentStr, _fontColorReg);
    local size = string.match(curNode.contentStr, _fontSizeReg);
    local event = string.match(curNode.contentStr, _eventReg);
    local imgSrc = string.match(curNode.contentStr, _imgSrcReg);
    local width = string.match(curNode.contentStr, _widthReg);
    local height = string.match(curNode.contentStr, _heightReg);
    local offsetX = string.match(curNode.contentStr, _offsetXReg);
    local offsetY = string.match(curNode.contentStr, _offsetYReg);
    local spaceWidth = string.match(curNode.contentStr, _spaceWidthReg);
    local spaceHeight = string.match(curNode.contentStr, _spaceHeightReg);
    local deltaWidth = string.match(curNode.contentStr, _deltaWidthReg);
    local deltaHeight = string.match(curNode.contentStr, _deltaHeightReg);
    local isUnderline = string.match(curNode.contentStr, _underLineBeginReg) ~= nil;
    if color then --转16进制的颜色格式 0xffffff之类的
        color = string.gsub(color, "#", "0x");
    end
    nodeVo = HtmlNodeVo.new(txt, 
        font, 
        size, 
        color, 
        forceType or curNode.type, 
        event, 
        imgSrc, 
        width, 
        height, 
        offsetX, 
        offsetY, 
        parentNodeVo, 
        spaceWidth, 
        spaceHeight,
        deltaWidth,
        deltaHeight,
        isUnderline
        );
    -- print("txt", nodeVo.txt)
    -- print("beginIndex", beginIndex)
    -- print("endIndex", endIndex)
    -- print("parentIndex", parentIndex)
    -- print("font",nodeVo.font);
    -- print("color",nodeVo.fontColor);
    -- print("size",nodeVo.fontSize);
    -- print("-------");

    return nodeVo;
end

function HtmlParser.breakNodeByChar(node)
    local result = nil;
    if node.type == HtmlNodeVo.TXT then
        result = {};
        local str = node.txt;
        local strLen = #str;
        local i = 1;
        while i <= strLen do
            local newNode = node:clone();
            local char = string.sub(str, i, i);
            if StringUtil.isAsciiChar(char) then
                i = i + 1;
            else
                char = string.sub(str, i, i + 2);
                i = i + 3;
            end
            newNode.txt = char;
            TableUtil.push(result, newNode);
        end
    end
    return result;
end

function HtmlParser.parsePattern(str, pattern, storage, isBegin, type)
    for beginIndex, contentStr, endIndex in string.gmatch(str, pattern) do
        -- print("捕捉的字符串", contentStr, beginIndex, endIndex);
        local isNotSeperate = type == HtmlNodeVo.BR or (isBegin and string.find(contentStr, "/>") ~= nil);
        storage[#storage + 1] = CaptureNode.new(contentStr, beginIndex, endIndex - 1, isBegin, type, isNotSeperate);
    end
end

