--
-- Author: luo
-- Date: 2016年12月30日 17:46:35
-- 预加载资源
local PreLoading = {}
local module_pre = "game.yule.mllegend.src"
local res_path = "game/yule/mllegend/res/"
local cmd = module_pre .. ".models.CMD_Game"
local ExternalFun = g_ExternalFun--require(appdf.EXTERNAL_SRC.."ExternalFun")
local g_var = ExternalFun.req_var
PreLoading.bLoadingFinish = false
PreLoading.loadingPer = 20
PreLoading.bFishData = false

function PreLoading.resetData()
	PreLoading.bLoadingFinish = false
	PreLoading.loadingPer = 20
	PreLoading.bFishData = false
end

function PreLoading.StopAnim(bRemove)
	local scene = cc.Director:getInstance():getRunningScene()
	local layer = scene:getChildByTag(2000) 

	if not layer  then
		return
	end

	if not bRemove then
		-- if nil ~= PreLoading.fish then
		-- 	PreLoading.fish:stopAllActions()
		-- end
	else	
		layer:stopAllActions()
		layer:removeFromParent()
	end
end

function PreLoading.loadTextures()
	local m_nImageOffset = 0

	local totalSource = 2 

	local plists = 
    {
        "plist/main_ml.plist",
        "plist/renwu.plist",
    }

	local function imageLoaded(texture)--texture
		
        m_nImageOffset = m_nImageOffset + 1

        if m_nImageOffset == totalSource then
        	
        	--加载PLIST

        	for i=1,#plists do
        		--cc.SpriteFrameCache:getInstance():addSpriteFrames(res_path..plists[i])
                cc.SpriteFrameCache:getInstance():addSpriteFrames(res_path..plists[i])
--        		local dict = cc.FileUtils:getInstance():getValueMapFromFile(res_path..plists[i])
--        		local framesDict = dict["frames"]
--				if nil ~= framesDict and type(framesDict) == "table" then
--					for k,v in pairs(framesDict) do
--						local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
--						if nil ~= frame then
--							frame:retain()
--						end
--					end
--				end
        	end

        	PreLoading.readAniams()
            --PreLoading.readSound()
        	PreLoading.bLoadingFinish = true

			--通知
--			local event = cc.EventCustom:new(g_var(cmd).Event_LoadingFinish)
--			print("发布监听通知",event)
--			dump(event)
--			cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

			PreLoading.Finish()
            if PreLoading.bFishData then
                PreLoading.bFishData = false
                
            end

        	print("资源加载完成")
        end
    end
    local function 	loadImages()
    	cc.Director:getInstance():getTextureCache():addImageAsync(res_path.."plist/main_ml.png", imageLoaded)
        cc.Director:getInstance():getTextureCache():addImageAsync(res_path.."plist/renwu.png", imageLoaded)    
    end
    local function createSchedule( )
    	local function update( dt )
			
		end
		local scheduler = cc.Director:getInstance():getScheduler()
		PreLoading.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0, false)
    end
	--进度条
	--PreLoading.GameLoadingView()

	loadImages()

	--createSchedule()
	--PreLoading.addEvent()
end

function PreLoading.unloadTextures( )

	local plists = 
    {
        "plist/main_ml.plist",
        "plist/renwu.plist",
    }
	for i=1,#plists do
--		local dict = cc.FileUtils:getInstance():getValueMapFromFile(res_path..plists[i])

--		local framesDict = dict["frames"]
--        --dump(framesDict,"framesDict")
--		if nil ~= framesDict and type(framesDict) == "table" then
--			for k,v in pairs(framesDict) do
--				local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
--				if nil ~= frame then
--					frame:release()
--				end
--			end
--		end
        --print(res_path..plists[i])
		cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(res_path..plists[i])
	end
    PreLoading.removeAllActions()
    
    cc.Director:getInstance():getTextureCache():removeTextureForKey(res_path .. "plist/main_ml.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey(res_path .. "plist/renwu.png")


    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

end

function PreLoading.addEvent()
    -- 通知监听
    local function eventListener(event)
        cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(g_var(cmd).Event_LoadingFinish)
        PreLoading.Finish()
    end
    local listener = cc.EventListenerCustom:create(g_var(cmd).Event_LoadingFinish, eventListener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end

function PreLoading.Finish()
	
end

function PreLoading.GameLoadingView()

    local scene = cc.Director:getInstance():getRunningScene()
	
    if  scene:getChildByTag(2000) then 
        return 
    end
    
    local layer = display.newLayer()
	layer:setTag(2000)
	scene:addChild(layer,30)



    local bg = cc.Sprite:create(res_path.."common/loading_bg.png")
    bg:addTo(layer)
    bg:move(cc.p(ylAll.WIDTH/2,ylAll.HEIGHT/2))
    bg:setScaleX(1334/1280)
    bg:setScaleY(750/720)

    layer:runAction(cc.Sequence:create(cc.DelayTime:create(10), cc.CallFunc:create(function () 
                if cc.Director:getInstance():getRunningScene():getChildByTag(2000) then
                     cc.Director:getInstance():getRunningScene():getChildByTag(2000):removeFromParent()
                end               
            end)))

    PreLoading.loadTextures()

    

end

function PreLoading.CloseGameLoadingView()

	local scene = cc.Director:getInstance():getRunningScene()
    local layer = scene:getChildByTag(2000) 
    if layer then
        layer:removeFromParent()
    end


end

function PreLoading.updatePercent(percent)
	
end

--[[
@function : readAnimation
@file : 资源文件
@key  : 动作 key
@num  : 幀数
@time : float time 
@formatBit 
]]
function PreLoading.readAnimation(file, key, num, time,formatBit,first)
   	local animation =cc.Animation:create()
    if first == nil then 
        first = 1
    end
	for i=first,num+first-1 do
		local frameName
		if formatBit == 1 then
			frameName = string.format(file.."%d.png", i)
		elseif formatBit == 2 then
		 	frameName = string.format(file.."%02d.png", i)
		end
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
		animation:addSpriteFrame(frame)
	end
	animation:setDelayPerUnit(time)
   	cc.AnimationCache:getInstance():addAnimation(animation, key)
end

function PreLoading.readAniByFileName( file,width,height,rownum,linenum,savename)
	local frames = {}
	for i=1,rownum do
		for j=1,linenum do
			local frame = cc.SpriteFrame:create(file,cc.rect(width*(j-1),height*(i-1),width,height))
			table.insert(frames, frame)
		end
	end
	local  animation =cc.Animation:createWithSpriteFrames(frames,0.03)
   	cc.AnimationCache:getInstance():addAnimation(animation, savename)
end

function PreLoading.removeAllActions()
--    cc.AnimationCache:getInstance():removeAnimation("A")
--    cc.AnimationCache:getInstance():removeAnimation("J")
--    cc.AnimationCache:getInstance():removeAnimation("Q")
--    cc.AnimationCache:getInstance():removeAnimation("K")
--    cc.AnimationCache:getInstance():removeAnimation("bonus")
--    cc.AnimationCache:getInstance():removeAnimation("free")
--    cc.AnimationCache:getInstance():removeAnimation("wild")
--    cc.AnimationCache:getInstance():removeAnimation("fangkuai")
--    cc.AnimationCache:getInstance():removeAnimation("heitao")
--    cc.AnimationCache:getInstance():removeAnimation("hongxin")
--    cc.AnimationCache:getInstance():removeAnimation("meihua")
--    cc.AnimationCache:getInstance():removeAnimation("huanrao")
--    cc.AnimationCache:getInstance():removeAnimation("shandongkuang")
end

function PreLoading.readAniams()
--    PreLoading.readAnimation("A_000","A",8,0.05,2,12)
--    PreLoading.readAnimation("J_000","J",8,0.05,2,12)
--    PreLoading.readAnimation("Q_000","Q",8,0.05,2,12)
--    PreLoading.readAnimation("K_000","K",8,0.05,2,12)
--    PreLoading.readAnimation("bonus_000","bonus",33,0.05,2,0)
--    PreLoading.readAnimation("free_000","free",33,0.05,2,0)
--    PreLoading.readAnimation("wild_000","wild",33,0.05,2,0)
--    PreLoading.readAnimation("fangkuai_000","fangkuai",16,0.05,2,14)
--    PreLoading.readAnimation("heitao_000","heitao",16,0.05,2,14)
--    PreLoading.readAnimation("hongxin_000","hongxin",16,0.05,2,14)
--    PreLoading.readAnimation("meihua_000","meihua",16,0.05,2,14)
--    PreLoading.readAnimation("huanrao_000","huanrao",10,0.05,2,2)
--    PreLoading.readAnimation("shandongkuang_000","shandongkuang",3,0.15,2,0)
end

function PreLoading.removeAniams()
    
end

function PreLoading.readSound()
    local soundList = {
        "bonus.mp3",
        "btn_click.mp3",
        "cash.mp3",
        "coin.mp3",
        "fruit_run.mp3",
        "fruit_run2.mp3",
        "spin.mp3",
        "stop.mp3",      
        }
    
    for i=1,#soundList do 
        if cc.FileUtils:getInstance():isFileExist(res_path.."/sound_res/"..soundList[i]) then 
            AudioEngine.preloadEffect(res_path.."/sound_res/"..soundList[i])
        end
    end
end

function PreLoading.unreadSound()
    local soundList = {
        "bonus.mp3",
        "btn_click.mp3",
        "cash.mp3",
        "coin.mp3",
        "fruit_run.mp3",
        "fruit_run2.mp3",
        "spin.mp3",
        "stop.mp3",      
        }
    
    for i=1,#soundList do 
        if cc.FileUtils:getInstance():isFileExist(res_path.."/sound_res/"..soundList[i]) then 
            AudioEngine.unloadEffect(res_path.."/sound_res/"..soundList[i])
        end
    end
end



return PreLoading