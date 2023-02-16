if nil == cc.SimpleAudioEngine then
    return
end
-- 安卓: 使用AudioEngine播放语音, 其余使用SimpleAudioEngine
-- 苹果：全部使用 AudioEngine 播放

--Encapsulate SimpleAudioEngine to AudioEngine,Play music and sound effects.
local M = {}
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

-- 背景音乐ID
local backgroudId = -1
-- 背景音乐音量
local backgroudVolum = 1

-- 语音ID
local voiceId = -1
-- 语音音量
local voiceVolum = 0

-- 音效音量
local effectVolum = 1

function M.stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
end

function M.getMusicVolume()
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        return backgroudVolum
    else
        return cc.SimpleAudioEngine:getInstance():getMusicVolume()
    end
end

function M.isMusicPlaying()
    return cc.SimpleAudioEngine:getInstance():isMusicPlaying()
end

function M.getEffectsVolume()
    return effectVolum
end

function M.setMusicVolume(volume)
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        ccexp.AudioEngine:setVolume(backgroudId, volume)
        backgroudVolum = volume
    else
        cc.SimpleAudioEngine:getInstance():setMusicVolume(volume)
    end
end

function M.stopEffect(handle)
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        ccexp.AudioEngine:stop(handle)
    else
        cc.SimpleAudioEngine:getInstance():stopEffect(handle)
    end
end

function M.stopMusic(isReleaseData)
    local releaseDataValue = false
    if nil ~= isReleaseData then
        releaseDataValue = isReleaseData
    end
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        ccexp.AudioEngine:stop(backgroudId)
    else
        cc.SimpleAudioEngine:getInstance():stopMusic(releaseDataValue)
    end    
end

function M.playMusic(filename, isLoop)
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        ccexp.AudioEngine:stop(backgroudId)
        backgroudId = ccexp.AudioEngine:play2d(filename, isLoop)
    else
        cc.SimpleAudioEngine:getInstance():playMusic(filename, loopValue)
    end    
end

-- old playmusic
function M.playSimpleMusic(filename, isLoop)
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    cc.SimpleAudioEngine:getInstance():playMusic(filename, loopValue)
end

function M.pauseAllEffects()
    cc.SimpleAudioEngine:getInstance():pauseAllEffects()
end

function M.preloadMusic(filename)
    cc.SimpleAudioEngine:getInstance():preloadMusic(filename)
end

function M.resumeMusic()
    cc.SimpleAudioEngine:getInstance():resumeMusic()
end

function M.playEffect(filename, isLoop)
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        return ccexp.AudioEngine:play2d(filename, loopValue, effectVolum)
    else
        return cc.SimpleAudioEngine:getInstance():playEffect(filename, loopValue)
    end
end

-- old effect
function M.playSimpleEffect(filename, isLoop)
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    return cc.SimpleAudioEngine:getInstance():playEffect(filename, loopValue)
end

-- 播放语音 使用play2d播放
function M.playVoice( filename, isLoop )
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    ccexp.AudioEngine:stop(voiceId)
    voiceId = ccexp.AudioEngine:play2d(filename, loopValue)
    return voiceId
end

function M.setVoiceVolume( volume )
    ccexp.AudioEngine:setVolume(voiceId, volume)
    print("-----------------------------------++3")
    dump(voiceId)
    dump(volume)
    voiceVolum = volume
end

function M.rewindMusic()
    cc.SimpleAudioEngine:getInstance():rewindMusic()
end

function M.willPlayMusic()
    return cc.SimpleAudioEngine:getInstance():willPlayMusic()
end

function M.unloadEffect(filename)
    cc.SimpleAudioEngine:getInstance():unloadEffect(filename)
end

function M.preloadEffect(filename)
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then 
        ccexp.AudioEngine:preload(filename)
    else
        cc.SimpleAudioEngine:getInstance():preloadEffect(filename)
    end
end

function M.setEffectsVolume(volume, effectid)
    if nil == effectid then
        effectVolum = volume
    end   
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        ccexp.AudioEngine:setVolume(backgroudId, backgroudVolum)
        ccexp.AudioEngine:setVolume(voiceId, voiceVolum)
        if nil ~= effectid then
            ccexp.AudioEngine:setVolume(effectid, volume)
        end
    else
        cc.SimpleAudioEngine:getInstance():setEffectsVolume(volume)
    end
end

function M.pauseEffect(handle)
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
       ccexp.AudioEngine:pause(handle)
    else
       cc.SimpleAudioEngine:getInstance():pauseEffect(handle)
    end
end

function M.resumeAllEffects(handle)
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        ccexp.AudioEngine:resumeAll()
    else
        cc.SimpleAudioEngine:getInstance():resumeAllEffects()
    end
end

function M.pauseMusic()
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
       ccexp.AudioEngine:stop(backgroudId)
    else
       cc.SimpleAudioEngine:getInstance():pauseMusic()
    end
end

function M.resumeEffect(handle)
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
       ccexp.AudioEngine:resume(handle)
    else
       cc.SimpleAudioEngine:getInstance():resumeEffect(handle)
    end
end

function M.getInstance()
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        return ccexp.AudioEngine
    else
        return cc.SimpleAudioEngine:getInstance()
    end
end

function M.destroyInstance()
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        return ccexp.AudioEngine:endToLua()
    else
        return cc.SimpleAudioEngine:destroyInstance()
    end
end

AudioEngine = M
