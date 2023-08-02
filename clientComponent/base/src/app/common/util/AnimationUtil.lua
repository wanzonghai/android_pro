--
-- Author: senji
-- Date: 2015-05-28 00:30:29
--

AnimationUtil = {}


function AnimationUtil.createWithSpriteFrames(sprite, spriteFrames, fps, repeatCount, finishCallback, notPlay)
    local animation = AnimationPlayer.new(sprite, spriteFrames, fps, repeatCount, finishCallback);
    if not notPlay then
        animation:playAnimation();
    end
    return animation;
end

-- -- spriteSheetName :levelup.plist
function AnimationUtil.createWithSpriteSheetInSprite(sprite, spriteSheetName, fps, repeatCount, finishCallback, isSwfOrPngAnimation)
    local spriteFrames = resMgr:getTpFrames(spriteSheetName, isSwfOrPngAnimation);
    assert(spriteFrames, "resMgr doesn't cotntain resKey :" .. spriteSheetName);
    local animation = AnimationUtil.createWithSpriteFrames(sprite, spriteFrames, fps, repeatCount, finishCallback);
    animation.animationFramesPlist = plistUrl;
    return animation;
end

function AnimationUtil.createWithSpriteSheet(path, spriteSheetName, fps, repeatCount, finishCallback, isSwfOrPngAnimation, sprite)
    local libRes = string.gsub(spriteSheetName, ".plist", ".png");
    local plistUrl = ResConfig.getResPath(path .. spriteSheetName)
    resMgr:loadTextureAtlas(plistUrl, true);
    local spriteFrames = resMgr:getTpFrames(libRes, isSwfOrPngAnimation);
    assert(spriteFrames, "resMgr doesn't cotntain resKey :" .. libRes);
    local animation = AnimationUtil.createWithSpriteFrames(sprite, spriteFrames, fps, repeatCount, finishCallback);
    animation.animationFramesPlist = plistUrl;
    return animation;
end

function AnimationUtil.findAnimations(ccsParent, arr)
    arr = arr or {}
    if ccsParent.ccsChildren then
        for i, v in ipairs(ccsParent.ccsChildren) do
            if v.__cname == "AnimationPlayer" then
                table.insert(arr, v);
            else
                AnimationUtil.findAnimations(v, arr);
            end
        end
    end
    return arr;
end

-- 播放序列帧
-- 注：需提前加载Plist文件（谁加载谁移除）
-- framePrefix：前缀
-- isFinishDel：是否完成销毁
-- delayDelTime：延迟销毁时间
-- return：Sprite
function AnimationUtil.playEffectFromSpriteFrame(framePrefix,startIndex,endIndex,fps,repeatCount,isFinishDel,delayDelTime)

    if endIndex < startIndex then return nil end
    local animationFrames = {}
    local numSize = string.len(tostring(endIndex))
    local formatStr = framePrefix.."%0"..numSize.."d.png"
    local time = 1/(fps or 30)
    local animate = cc.Animation:create()
    for i=startIndex,endIndex do
        local frameName = string.format(formatStr, i)
        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
        if spriteFrame then
            animate:addSpriteFrame(spriteFrame)
        end
    end
    animate:setDelayPerUnit(time)
    animate:setRestoreOriginalFrame(false)
    animate:setLoops(repeatCount or 1)
    local action = cc.Animate:create(animate)  
    local spr = cc.Sprite:create()
    if isFinishDel then
        spr:runAction(cc.Sequence:create(action, cc.DelayTime:create(delayDelTime or 1), cc.CallFunc:create(function()   
            if spr ~= nil then  
                spr:removeFromParent()  
                spr = nil  
            end  
        end)))  
    else
        spr:runAction(action)
    end

    return spr
end














