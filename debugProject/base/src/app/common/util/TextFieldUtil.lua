--
-- Author: senji
-- Date: 2015-03-06 14:33:09
--
TextFieldUtil = {};
local function tempNoStyleFunc(tf)
    tf:disableEffect();
end

function TextFieldUtil.getFontName(label)
    if label.getFontName then
        return label:getFontName();
    elseif label.getSystemFontName then
        return label:getSystemFontName();
    end
    return "";
end

function TextFieldUtil.makeTextFieldNoStyle(tf)
    if tf then
        if tf.getVirtualRenderer then
            tf = tf:getVirtualRenderer();
        end
        if tf.disableEffect then
            local size = tf:getSystemFontSize();
            local name = tf:getSystemFontName();
            tf:disableEffect();
            tf:setSystemFontSize(size)
            tf:setSystemFontName(name)
        elseif tf.setStyleFunc then
            tf:setStyleFunc(tempNoStyleFunc)
        end
    end
end

function TextFieldUtil.makeBlueOutLineStyle(label)
    if label.enableGlow then
        cclabel:enableGlow(cc.c4b(0, 255, 255, 255));
        cclabel:enableShadow(cc.c4b(0, 255, 255, 255), cc.size(1, -1), 6);
    else
        -- traceLog("不支持enableGlow的文本框："..tostring(cclabel:getName()).."，类型:"..tolua.type(cclabel));
    end
end

function TextFieldUtil.makeDefaultBtnTextFieldStyle(label)
    -- if label.enableOutline then
    --     label:enableOutline(cc.c4b(0, 0, 0, 255), 2);
    --     DisplayUtil.setTxtFont(label, CCSKitchen.defaultFontFamily)
    -- else
    --     -- traceLog("不支持enableOutline的文本框："..tostring(label:getName()).."，类型:"..tolua.type(label));
    -- end
    -- if label.enableShadow then
    --     label:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1), 6);
    -- else
    --     -- traceLog("不支持enableShadow的文本框："..tostring(label:getName()).."，类型:"..tolua.type(label));
    -- end
end

function TextFieldUtil.setTextOutLineSize(tf, size)
    TextFieldUtil.makeTextFieldNoStyle(label)
    local function styleFunc(label)
        label:enableOutline(cc.c4b(0, 0, 0, 255), size);
    end

    if tf.enableOutline then
        styleFunc(tf)
    elseif tf.setStyleFunc then
        tf:setStyleFunc(styleFunc)
    end
end

function TextFieldUtil.makeLbsTextFieldStyle(label)
    if label.enableOutline then
        label:enableOutline(cc.c4b(0, 0, 0, 255), 1);
    else
        -- traceLog("不支持enableOutline的文本框："..tostring(label:getName()).."，类型:"..tolua.type(label));
    end
    if label.enableShadow then
        label:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1), 6);
    else
        -- traceLog("不支持enableShadow的文本框："..tostring(label:getName()).."，类型:"..tolua.type(label));
    end
end

function TextFieldUtil.makeDefaultTextFieldStyle(label)
    TextFieldUtil.makeTextFieldNoStyle(label)
    -- if label.enableOutline then
    --     label:enableOutline(cc.c4b(0, 0, 0, 255), 1);
    -- else
    --     -- traceLog("不支持enableOutline的文本框："..tostring(label:getName()).."，类型:"..tolua.type(label));
    -- end
    -- if label.enableShadow then
    --     label:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1), 6);
    -- else
    --     -- traceLog("不支持enableShadow的文本框："..tostring(label:getName()).."，类型:"..tolua.type(label));
    -- end
end