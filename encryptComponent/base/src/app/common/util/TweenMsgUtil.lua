
TweenMsgUtil = {};

function TweenMsgUtil.showRedMsg(txt, size, beginPos, floatY, view)
    TweenMsgUtil.showMsg(txt, size, HTML_COLOR_RED, floatY, view);
end


function TweenMsgUtil.showGreenMsg(txt, size, beginPos, floatY, delayT, view)
    TweenMsgUtil.showMsg(txt, size, HTML_COLOR_GREEN, beginPos, floatY, delayT, view);
end

function TweenMsgUtil.showMsg2(txt, size, beginPos, popY)
    local tf = TextField.new(nil, size, nil, 500);
    tf:setIsAssetVCenter(true)
    tf:setType(TextField.TYPE_CHAR_BY_CHAR)

    tf:setHtmlText(txt);

    tf:setPosition(beginPos.x - tf:getTextWidth() * .5, beginPos.y)
    DisplayUtil.setAddOrRemoveChild(tf, uiMgr:getTopLayerInAllScene(), true);


    local function onComplete()
        tf:destroy()
    end

    local totalTl = TimelineLite.new({ onComplete = onComplete })

    local units = tf:getUnits();
    for i, v in ipairs(units) do
        v:setOpacity(0)
        local tl = TimelineLite.new();
        tl:append(TweenLite.to(v, 0.3, { y = tostring(popY), autoAlpha = 1, ease = Back.easeOut }));
        tl:append(TweenLite.to(v, 0.2, { y = tostring(popY), autoAlpha = 0, ease = Back.easeIn }), 1);
        totalTl:insert(tl, i * 0.05);
    end
end

----- 飘单一一条
function TweenMsgUtil.showMsg(txt, size, color, beginPos, floatY, delayT, view)
    delayT = delayT or 0.5;
    local msg = TextField.new("", size, color, 500, nil, TextField.H_CENTER);
    msg:setHtmlText(txt);
    msg:setPosition(beginPos.x - msg:getWidth() * 0.5, beginPos.y);
    msg:setOpacity(0);

    if view then
        DisplayUtil.setAddOrRemoveChild(msg, view, true);
    else
        DisplayUtil.setAddOrRemoveChild(msg, uiMgr:getTopLayerInAllScene(), true);
    end

    local tlline = TimelineLite.new();

    local function destroy()
        msg:destroy();
    end

    tlline:append(TweenLite.to(msg, delayT, {})); -- 延迟
    tlline:append(TweenLite.to(msg, 0.1, { alpha = 1, delay = 0.2 }));
    tlline:append(TweenLite.to(msg, 1, { y = floatY, onComplete = destroy, alpha = 0, delay = 0.2, ease = Quad.easeIn }));
    return tlline;
end

function TweenMsgUtil:showArrMsg(strData, size, color, beginPos, floatY, delayArr, view)
    local totalTl = TimelineLite.new()

    for i, v in pairs(strData) do
        local tl = TweenMsgUtil.showMsg(v, size, color, beginPos, floatY, delayArr[i], view);
        totalTl:insert(tl);
    end
end

-- insert 同步执行
-- append 顺序执行