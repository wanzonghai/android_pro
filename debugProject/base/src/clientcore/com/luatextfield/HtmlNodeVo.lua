--
-- Author: senji
-- Date: 2014-03-05 16:51:45
--
HtmlNodeVo = class_quick("HtmlNodeVo")
HtmlNodeVo.TXT = 1; --文本
HtmlNodeVo.IMG = 2; --图片
HtmlNodeVo.BR = 3; --换行
HtmlNodeVo.CCNODE = 4; --ccnode对象
HtmlNodeVo.SPACE = 5; --space对象

function HtmlNodeVo:ctor(txt, font, fontSize, fontColor, htmlType, event, imgSrc, width, height, offsetX, offsetY, parentNode, spaceWidth, spaceHeight, deltaWidth, deltaHeight, isUnderline)
    self.txt = txt;
    if parentNode then--html中继承父类的都要在这里纳入
        self.fontColor = fontColor or parentNode.fontColor;
        self.fontSize = checknumber(fontSize or parentNode.fontSize);
        self.font = font or parentNode.font;
        self.event = event or parentNode.event;
        self.isUnderline = parentNode.isUnderline or isUnderline;
    else
        self.fontColor = fontColor;
        self.fontSize = checknumber(fontSize);
        self.font = font;
        self.event = event;
        self.isUnderline = isUnderline
    end
    self.type = htmlType; --html类型
    self.imgSrc = imgSrc;
    self.width = checknumber(width);
    self.height = checknumber(height);
    self.offsetX = checknumber(offsetX);
    self.offsetY = checknumber(offsetY);
    self.spaceWidth = checknumber(spaceWidth);
    self.spaceHeight = checknumber(spaceHeight);
    self.deltaWidth = checknumber(deltaWidth);
    self.deltaHeight = checknumber(deltaHeight);
end

function HtmlNodeVo:clone()
    local newVo = HtmlNodeVo.new();
    newVo.txt = self.txt;
    newVo.fontColor = self.fontColor;
    newVo.fontSize = self.fontSize;
    newVo.font = self.font;
    newVo.type = self.type;
    newVo.event = self.event;
    newVo.imgSrc = self.imgSrc;
    newVo.width = self.width;
    newVo.height = self.height;
    newVo.offsetX = self.offsetX;
    newVo.offsetY = self.offsetY;
    newVo.spaceWidth = self.spaceWidth;
    newVo.spaceHeight = self.spaceHeight;
    newVo.deltaWidth = self.deltaWidth;
    newVo.deltaHeight = self.deltaHeight;
    newVo.isUnderline = self.isUnderline;
    return newVo;
end