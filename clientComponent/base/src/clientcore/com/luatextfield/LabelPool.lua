--
-- Author: senji
-- Date: 2014-03-05 01:09:45
--
local LabelPool = class_quick("LabelPool")

function LabelPool:ctor()
    self._poolLen = 0;
    self._poolDicByString = {};
end

function LabelPool:getLabel(txt, font, size, color, styleFunc, isUnderline)
    txt = txt or ""
    local result = nil;
    local arr = self._poolDicByString[txt];
    local len = 0;
    local cacheState = 1;--0：不是缓存， 1：缓存并且缓存txt，2：缓存但是不是缓存txt
    if not arr or #arr == 0 then
        arr = TableUtil.getOne(self._poolDicByString);
        cacheState = 2; 
    end
    if arr then
        len = #arr;
    end
    if len > 0 then
        result = arr[len];
        table.remove(arr, len);

        self._poolLen = self._poolLen - 1;
        if cacheState == 2 then
            -- print("缓存2")
            result:setString(txt);
        else
            -- print("缓存1")
        end
        result:setVisible(true);
        result:setOpacity(255);
        if font then
            DisplayUtil.setTxtFont(result, font)
        end

        if size then
            result:setSystemFontSize(size);
        end
    else
        -- print("不缓存")
        cacheState = 0;
        result = cc.Label:createWithSystemFont(txt, font, size);
        result:retain();
    end
    -- 关闭这个，尽量减少label的渲染，因为label的渲染非常消耗！！(特别是android。cocos3.10)
    -- TextFieldUtil.makeTextFieldNoStyle(result);
    if color then
        -- result:setTextColor(color);
        result:setColor(color); --Label的setTextColor和node的setColor会有重叠现象，同时设置颜色失真
    end

    -- 下面的stylefunc要缓存起来，为了尽量减少label的渲染
    if styleFunc then
        if result.__styleFunc ~= styleFunc then
            styleFunc(result)
            result.__styleFunc = styleFunc
        end
    else
        if result.__styleFunc ~= 1 then
            TextFieldUtil.makeDefaultTextFieldStyle(result);
            result.__styleFunc = 1;
        end
    end

    if result._isUnderline ~= isUnderline then
        result._isUnderline = isUnderline
        if isUnderline then
            result:enableUnderline()
        else
            result:disableEffect(6)
        end
    end

    result.__origColor = color;
    result:setAnchorPoint(cc.p(0, 0));

    -- local t = tickMgr:getTimer()
    -- result:getContentSize();--强制更新label的纹理一下
    -- print("不可能吧？", tickMgr:getTimer() - t)

    return result;
end

function LabelPool:clearPool(notTrace)
    if not notTrace then
        trace("清理 labelPool:" .. self._poolLen)
    end
    if self._poolLen > 0 then
        for key, labels in pairs(self._poolDicByString) do
            for i,label in ipairs(labels) do
                label:release();
            end
        end
        self._poolDicByString = {};
        self._poolLen = 0;
    end
end

function LabelPool:pushLabel(label)
    local txt = label:getString()
    local arr = self._poolDicByString[txt];
    if not arr then
        arr = {};
        self._poolDicByString[txt] = arr;
    end
    if not table.indexof(arr, label) then
        self._poolLen = self._poolLen + 1;
        TweenLite.killTweensOf(label);
        table.insert(arr, label)
        label:removeFromParent(false);
    end
end

function LabelPool:pushLabels(labels)
    for i, label in ipairs(labels) do
        self:pushLabel(label);
    end
end

labelPool = LabelPool.new()
