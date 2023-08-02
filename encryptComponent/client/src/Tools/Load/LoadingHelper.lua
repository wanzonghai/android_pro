--预加载
local LoadingHelper = {}
local sharedScheduler = cc.Director:getInstance():getScheduler()
local spriteFrameCache = cc.SpriteFrameCache:getInstance()
local director = cc.Director:getInstance()
local textureCache = director:getTextureCache()

local feedback = nil
local _startTime = 0
local resources = {}
local resourcesPath = {}
local musicResouces = {}
local resIndex = 0
local musicIndex = 0
local settingLow = nil

function LoadingHelper.clock()
    if socket then
        return socket.gettime()
    end
    --可能返回负值
    return os.clock()
end

function LoadingHelper.loadPlist(_feedback)
    _startTime = LoadingHelper.clock()
    feedback = _feedback
    resources = {}
    resourcesPath = {}
    musicResouces = {}
    resIndex = 0
    musicIndex = 0
end

--加载大厅资源
function LoadingHelper.loadLobbyPlist(_feedback,isLogo)
    LoadingHelper.loadPlist(_feedback)

    LoadingHelper.pushPlist("Lobby/GUI/HallPlist.plist",true)
    LoadingHelper.pushPlist("Lobby/GUI/RoomList1.plist",true)
    LoadingHelper.pushPlist("Truntable/TruntablePlist.plist",true)
    LoadingHelper.pushPlist("VIP/VIPPlist.plist",true)
    LoadingHelper.pushPlist("Gift/GiftPlist.plist",true)
    LoadingHelper.pushPlist("Lobby/GameIconPlist.plist",true)
    LoadingHelper.pushPlist("Lobby/GameIconPlist2.plist",true)
    LoadingHelper.pushPlist("Lobby/GameIconPlist3.plist",true)
    LoadingHelper.pushPlist("Lobby/GameIconPlist4.plist",true)
    LoadingHelper.pushPlist("Lobby/GameIconPlist5.plist",true)
    -- LoadingHelper.pushPlist("PG/PGPlist1.plist",true)
    -- LoadingHelper.pushPlist("PG/PGPlist2.plist",true)
    -- LoadingHelper.pushPlist("PG/PGPlist3.plist",true)
    LoadingHelper.pushPlist("ShareTurnTable/ShareTurnTableGUI.plist",true)
    LoadingHelper.pushImage("BigImage/Bg_Bank_1.png")
    LoadingHelper.pushImage("BigImage/Bg_Gift.png")
    LoadingHelper.pushImage("BigImage/Bg_Shop_1.png")
    LoadingHelper.pushImage("BigImage/Bg_Signin_1.png")
    -- LoadingHelper.pushImage("BigImage/Bg_SubScene_bg.png")
    LoadingHelper.pushImage("BigImage/bg1_1.png")
    LoadingHelper.pushImage("BigImage/zp_sm5.png")
    LoadingHelper.pushImage("BigImage/zp_sm6.png")
    LoadingHelper.pushImage("BigImage/zhuanpan1_1.png")
    LoadingHelper.pushImage("BigImage/zhuanpan1_2.png")
    LoadingHelper.pushImage("BigImage/zhuanpan1_3.png")
    LoadingHelper.pushImage("ShareTurnTable/bckgound.png")
    LoadingHelper.pushImage("ShareTurnTable/circle_022x.png")
    --大厅音效中除了两个bg音效其他都是通用音效，而且loading界面需要播放大厅背景音效，所以暂时只加载一遍(logo加载)，切换场景时不释放大厅音效缓冲
    if isLogo then
        local all = LoadingHelper.getLobbyMusic()
        for i = 1 , #all do
            LoadingHelper.pushMusic(all[i])
        end
    end
    LoadingHelper.startAllResource()
end

--得到大厅音乐音效
function LoadingHelper.getLobbyMusic()
    local tab = {
        {"sound/backgroud01.mp3","bg"},
        {"sound/BT_GET.mp3","effect"},
        {"sound/btn_close.mp3","effect"},
        {"sound/countdown5.mp3","effect"},
        {"sound/music_button.mp3","effect"},
        {"sound/music_quit.mp3","effect"},
        {"sound/numberScroll.mp3","effect"},
        {"sound/turnBoom.mp3","effect"},
        {"sound/turnNumberScroll.mp3","effect"},
        {"sound/turnSolve.mp3","effect"}
    }
    return tab
end

function LoadingHelper.toPngName(plistName)
    local _r = LoadingHelper.Split(plistName , ".")
    return string.format("%s.png" , _r[1])
end

function LoadingHelper.Split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

--只预加载合图
function  LoadingHelper.pushPlist(_plistName, _bit32)
    LoadingHelper.pushResource(_plistName , LoadingHelper.toPngName(_plistName) , _bit32)
end

--只预加载图片
function LoadingHelper.pushImage(_pngName)
    LoadingHelper.pushResource(nil , _pngName , true)
end

function LoadingHelper.pushMusic(fileConfig)
    if fileConfig and LoadingHelper.contain(musicResouces,fileConfig[1] , "musicFile") then
        return
    end
    table.insert(musicResouces,{musicFile = fileConfig[1],type = fileConfig[2]})
    table.insert(resourcesPath,fileConfig[1])
end

--_plistName 合图plist
--_pngName合图名
--_bit32加载图片的格式是否全通道加载,true就是全通道，false就是低质量模式
function  LoadingHelper.pushResource(_plistName , _pngName , _bit32)
    if _plistName and LoadingHelper.contain(resources , _plistName , "plistName") then
        return
    end
    if _pngName and LoadingHelper.contain(resources , _pngName , "pngName") then
        return
    end
   
    if _bit32 == true or _bit32 == false then
        if _bit32 then
            display.setTexturePixelFormat(_pngName , cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
        else
            display.setTexturePixelFormat(_pngName , cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
        end
    else
        display.setTexturePixelFormat(_pngName , _bit32)
    end
    local _res = {plistName=_plistName, pngName=_pngName}
    table.insert(resources , _res)
end

local function load()
    resIndex = resIndex + 1
    local _res = resources[resIndex]
    if _res then
        LoadingHelper.addImageAsync(_res.plistName , _res.pngName)
    end
end

--加载音效
local function loadMusic()
    musicIndex = musicIndex + 1
    resIndex = resIndex + 1
    local _res = musicResouces[musicIndex]
    if _res then
        local musicFile = _res.musicFile
        local musicType = _res.type
        if musicType == "bg" then
            AudioEngine.preloadMusic(musicFile)
        elseif musicType == "effect" then
            AudioEngine.preloadEffect(musicFile)    --音效预加载 
        end
        LoadingHelper.imageCallback(musicFile)
    end
end

function LoadingHelper.startAllResource()
    printInfo("startAllResource resource size = %d , resIndex = %d , resourcesPath = %d" , #resources , resIndex , #resourcesPath)
    local handle = nil
    handle = sharedScheduler:scheduleScriptFunc(function()              --下一帧再调用函数下一帧再调用函数，防止内存暴涨
        sharedScheduler:unscheduleScriptEntry(handle)
        load()
    end, 0, false)
end

function LoadingHelper.addImageAsync(plistName , imagePath)
    if not cc.FileUtils:getInstance():isFileExist(imagePath) then
        dump("File is not exit path="..imagePath.."-----------")
    end
    if plistName ~= nil and plistName ~= "" then                --如果plist不是空就是合图
        table.insert(resourcesPath,plistName)
        LoadingHelper.loadSpriteFrames(plistName,imagePath, LoadingHelper.imageCallback)
    else
        table.insert(resourcesPath,imagePath)
        local asyncHandler = function()
            LoadingHelper.imageCallback(imagePath)
        end
        LoadingHelper.loadImage(imagePath, asyncHandler)           --加载图片
    end
end

--预加载回调
function LoadingHelper.imageCallback(path,ignore)
    --判断下是否是资源里面的文件
    if path == nil or LoadingHelper.contain(resourcesPath,path) == false then
        if not ignore then
            printInfo("error path=%s" , tostring(path))
            if feedback ~= nil then
                feedback(1, 1,1,true)
            end
            return
        end
    end
    printInfo("reloadSources path=%s" , tostring(path))
    table.removebyvalue(resourcesPath , path)
    local total = LoadingHelper.clock() - _startTime            --总时间
    if #resources == 0 and #musicResouces == 0 then
        printInfo("error path = " .. tostring(path))
        return
    end
    
    if resIndex == (#resources + #musicResouces) then               --说明加载到最后一条了

    else
        local handle = nil
        handle = sharedScheduler:scheduleScriptFunc(function()      --下一帧再调用函数，防止内存暴涨
            sharedScheduler:unscheduleScriptEntry(handle)
            if resIndex < #resources then                           --先加载图片
                load()
            else                                                    --再加载音乐音效
                loadMusic()
            end
        end, 0, false)
    end
    if feedback ~= nil then
        feedback(resIndex, total,(#resources + #musicResouces))
    end
end

function LoadingHelper.stop()
    feedback = nil
    resources = {}
    resourcesPath = {}
    musicResouces = {}
    resIndex = 0
    musicIndex = 0
end

function LoadingHelper.contain(_table , v ,key)
    for i=1 , #_table do
        if key ~= nil then
            if _table[i][key] == v then
                return true
            end
        else
            if _table[i] == v then
                return true
            end
        end
    end
    return false  
end

function LoadingHelper.loadSpriteFrames(dataFilename, imageFilename, callback)
    if display.TEXTURES_PIXEL_FORMAT[imageFilename] then
        cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[imageFilename])
    else
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_BGR_A8888)
    end
    if not callback then
        spriteFrameCache:addSpriteFrames(dataFilename, imageFilename)
    else
        local asyncHandler = function()
            spriteFrameCache:addSpriteFrames(dataFilename, imageFilename)
            callback(dataFilename, imageFilename)
        end
        textureCache:addImageAsync(imageFilename, asyncHandler)
    end
end

function LoadingHelper.loadImage(imageFilename, callback)
    if display.TEXTURES_PIXEL_FORMAT[imageFilename] then
        cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[imageFilename])
    else
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_BGR_A8888)
    end
    if not callback then
        return textureCache:addImage(imageFilename)
    else
        textureCache:addImageAsync(imageFilename, callback)
    end
end

return LoadingHelper