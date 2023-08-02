--
-- Author: luo
-- Date: 2016年12月30日 17:46:35
-- 预加载资源
local PreLoading = {}
local module_pre = "game.yule.watermargin.src"
local res_path = "game/yule/watermargin/res/"
local cmd = module_pre .. ".models.CMD_Game"
local g_var = g_ExternalFun.req_var
PreLoading.bLoadingFinish = false
PreLoading.loadingPer = 20
PreLoading.bFishData = false
local textureCacheTab = {}

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
	local plists = {"game1/gameAction/dagu",
					"game1/gameAction/flash",
					"game1/gameAction/game1_itemCommon",
					"game1/gameAction/game1_itemJump",
					"game1/gameAction/piaoqi",
					"game1/gameAction/piaoqi2",
					"game1/gameAction/shz_title",
					"game1/itemAction/box_frame",
					"game1/itemAction/dadao",
					"game1/itemAction/futou",
					"game1/itemAction/lin",
					"game1/itemAction/lu",
					"game1/itemAction/shuihuzhuan",
					"game1/itemAction/song",
					"game1/itemAction/titianxingdao",
					"game1/itemAction/yinqiang",
					"game1/itemAction/zhongyitang",
					"game1/itemAction/light",

					"game2/dealer/dealer_common",
					"game2/dealer/dealer_anger1",
					"game2/dealer/dealer_anger2",
					"game2/dealer/dealer_cry",
					"game2/dealer/dealer_dice1",
					"game2/dealer/dealer_dice2",
					"game2/dealer/dealer_happy",
					"game2/dealer/dealer_open",

					"game2/left/left_cheer",
					"game2/left/left_common",
					"game2/left/left_cry",
					"game2/left/left_happy",

					"game2/right/right_cheer1",
					"game2/right/right_cheer2",
					"game2/right/right_common",
					"game2/right/right_common2",
					"game2/right/right_cry",
					"game2/right/right_happy",

					"game2/desk/desk",
					"game2/gold_action/gold",

					"setting/setLayer"
				   }

     local m_nImageOffset = 0
	 local totalSource = #plists

	local function imageLoaded(texture)--texture
		table.insert(textureCacheTab,texture)
        m_nImageOffset = m_nImageOffset + 1
		print("m_nImageOffset",m_nImageOffset)
		print("totalSource",totalSource)	
        cc.SpriteFrameCache:getInstance():addSpriteFrames(res_path..plists[m_nImageOffset]..".plist")
        local dict = cc.FileUtils:getInstance():getValueMapFromFile(res_path..plists[m_nImageOffset]..".plist")

        local framesDict = dict["frames"]
		if nil ~= framesDict and type(framesDict) == "table" then
			for k,v in pairs(framesDict) do
				local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
				if nil ~= frame then
					frame:retain()
				end
			end
		end
        local per = m_nImageOffset / totalSource * 100
        --[[if per >= 75 then
            PreLoading.loadingBG:loadTexture(res_path.."loading/preBg_sf04.png")
        elseif per >= 50 then
            PreLoading.loadingBG:loadTexture(res_path.."loading/preBg_sf03.png")
        elseif per >= 25 then
            PreLoading.loadingBG:loadTexture(res_path.."loading/preBg_sf02.png")
        end]]

        PreLoading.loadingBar:setPercentage(per)
        if m_nImageOffset == totalSource then
        	--加载PLIST
        	--[[for i=1,#plists do
        		cc.SpriteFrameCache:getInstance():addSpriteFrames(res_path..plists[i]..".png")
        		local dict = cc.FileUtils:getInstance():getValueMapFromFile(res_path..plists[i]..".png")
        		local framesDict = dict["frames"]
				if nil ~= framesDict and type(framesDict) == "table" then
					for k,v in pairs(framesDict) do
						local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
						if nil ~= frame then
							frame:retain()
						end
					end
				end
        	end]]

        	PreLoading.readAniams()
        	PreLoading.bLoadingFinish = true

			--通知
			local event = cc.EventCustom:new(g_var(cmd).Event_LoadingFinish)
			print("发布监听通知",event)
			dump(event)
			cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

			PreLoading.Finish()

			if PreLoading.bFishData  then
				PreLoading.bFishData = false
				local scene = cc.Director:getInstance():getRunningScene()
				local layer = scene:getChildByTag(2000) 
				if not layer  then
					return
				end

				PreLoading.loadingBar:stopAllActions()
				PreLoading.loadingBar = nil
				layer:stopAllActions()
				layer:removeFromParent()

			end
        	print("资源加载完成")
        end
    end
    local function 	loadImages()
        for i=1,#plists do
            local textureCache = cc.Director:getInstance():getTextureCache()
            textureCache:addImageAsync(res_path..plists[i]..".png", imageLoaded)
        end
    end
	--进度条
	PreLoading.GameLoadingView()
    textureCacheTab = {}
	loadImages()
	--createSchedule()
	--PreLoading.addEvent()
end

function PreLoading.unloadTextures( )

	local plists = {"game1/gameAction/dagu",
					"game1/gameAction/flash",
					"game1/gameAction/game1_itemCommon",
					"game1/gameAction/game1_itemJump",
					"game1/gameAction/piaoqi",
					"game1/gameAction/piaoqi2",
					"game1/gameAction/shz_title",
					"game1/itemAction/box_frame",
					"game1/itemAction/dadao",
					"game1/itemAction/futou",
					"game1/itemAction/lin",
					"game1/itemAction/lu",
					"game1/itemAction/shuihuzhuan",
					"game1/itemAction/song",
					"game1/itemAction/titianxingdao",
					"game1/itemAction/yinqiang",
					"game1/itemAction/zhongyitang",
					"game1/itemAction/light",

					"game2/dealer/dealer_common",
					"game2/dealer/dealer_anger1",
					"game2/dealer/dealer_anger2",
					"game2/dealer/dealer_cry",
					"game2/dealer/dealer_dice1",
					"game2/dealer/dealer_dice2",
					"game2/dealer/dealer_happy",
					"game2/dealer/dealer_open",

					"game2/left/left_cheer",
					"game2/left/left_common",
					"game2/left/left_cry",
					"game2/left/left_happy",

					"game2/right/right_cheer1",
					"game2/right/right_cheer2",
					"game2/right/right_common",
					"game2/right/right_common2",
					"game2/right/right_cry",
					"game2/right/right_happy",

					"game2/desk/desk",
					"game2/gold_action/gold",

					"setting/setLayer"
				   }

	for i=1,#plists do
		local dict = cc.FileUtils:getInstance():getValueMapFromFile(res_path..plists[i]..".plist")

		local framesDict = dict["frames"]
		if nil ~= framesDict and type(framesDict) == "table" then
			for k,v in pairs(framesDict) do
				local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
				if nil ~= frame then
					frame:release()
				end
			end
		end
		cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(res_path..plists[i]..".plist")
	end

	--cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(res_path .. "game1/gameAction/dagu")
    --cc.Director:getInstance():getTextureCache():removeTextureForKey("gameAction/dagu.png.png")
    
 	cc.Director:getInstance():getTextureCache():removeTextureForKey(res_path.."game1/gameAction/game1_itemCommon.png")

    local textureCache = cc.Director:getInstance():getTextureCache()
    for i,v in pairs(textureCacheTab) do
        textureCache:removeTexture(v)
    end

    textureCache:removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

-- function PreLoading.addEvent()
--    --通知监听
--   local function eventListener(event)
--   	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(g_var(cmd).Event_LoadingFinish)
-- 	PreLoading.Finish()
--   end
--   local listener = cc.EventListenerCustom:create(g_var(cmd).Event_LoadingFinish, eventListener)
--   cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
-- end

function PreLoading.Finish()
	PreLoading.bFishData = true
	if  PreLoading.bLoadingFinish then
		local scene = cc.Director:getInstance():getRunningScene()
		local layer = scene:getChildByTag(2000) 
		if nil ~= layer then
			local callfunc = cc.CallFunc:create(function()
				PreLoading.loadingBar:stopAllActions()
				PreLoading.loadingBar = nil
				layer:stopAllActions()
				layer:removeFromParent()
			end)
			layer:stopAllActions()
			layer:runAction(cc.Sequence:create(cc.DelayTime:create(3.3),callfunc))
		end
	end
end

function PreLoading.GameLoadingView()
	local scene = cc.Director:getInstance():getRunningScene()
	local layer = display.newLayer()
	layer:setTag(2000)
	scene:addChild(layer,30)

	PreLoading.loadingBG = ccui.ImageView:create(res_path.."loading/shz_battle_bg.jpg")
	PreLoading.loadingBG:setTag(1)
    PreLoading.loadingBG:setAnchorPoint(0.5,0.5)
	PreLoading.loadingBG:setTouchEnabled(true)
	PreLoading.loadingBG:setPosition(cc.p(ylAll.WIDTH/2+g_offsetX,ylAll.HEIGHT/2))
    PreLoading.loadingBG:setScale9Enabled(true)
    PreLoading.loadingBG:setCapInsets(cc.rect(0,0,0,0))
    PreLoading.loadingBG:setContentSize(cc.size(2340,1080))
	layer:addChild(PreLoading.loadingBG)

	local loadingBarBG = ccui.ImageView:create(res_path.."loading/progress_sfbar_bg.png")
	loadingBarBG:setTag(2)
    loadingBarBG:setScale9Enabled(true)
    loadingBarBG:setContentSize(cc.size(539,33))
    loadingBarBG:setCapInsets(cc.rect(0,0,0,0))
	loadingBarBG:setPosition(cc.p(ylAll.WIDTH/2+g_offsetX,12))
	layer:addChild(loadingBarBG)

	PreLoading.loadingBar = cc.ProgressTimer:create(cc.Sprite:create(res_path.."loading/progress_sfbar.png"))
	PreLoading.loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    PreLoading.loadingBar:setScale(1.44)
	PreLoading.loadingBar:setMidpoint(cc.p(0.0,0.5))
	PreLoading.loadingBar:setBarChangeRate(cc.p(1,0))
    PreLoading.loadingBar:setPosition(cc.p(loadingBarBG:getContentSize().width/2,loadingBarBG:getContentSize().height/2))
    loadingBarBG:addChild(PreLoading.loadingBar)
end

function PreLoading.updatePercent(percent )
	if nil ~= PreLoading.loadingBar then
		local dt = 1.0
		if percent == 100 then
			dt = 2.0
		end
		PreLoading.loadingBar:runAction(cc.ProgressTo:create(dt,percent))
	end

	if PreLoading.bLoadingFinish  then
		if nil ~= PreLoading.m_scheduleUpdate then
    		local scheduler = cc.Director:getInstance():getScheduler()
			scheduler:unscheduleScriptEntry(PreLoading.m_scheduleUpdate)
			PreLoading.m_scheduleUpdate = nil
		end
	end
end

--[[
@function : readAnimation
@file : 资源文件
@key  : 动作 key
@num  : 幀数
@time : float time 
@formatBit 
]]
function PreLoading.readAnimation(file, key, num, time,formatBit)
   	local animation =cc.Animation:create()
	for i=1,num do
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
    cc.AnimationCache:getInstance():removeAnimation("daguAnim")
    cc.AnimationCache:getInstance():removeAnimation("titleAnim")
    cc.AnimationCache:getInstance():removeAnimation("wYaoqiAnim")
    cc.AnimationCache:getInstance():removeAnimation("rYaoqiAnim")
    cc.AnimationCache:getInstance():removeAnimation("flashAnim")

    cc.AnimationCache:getInstance():removeAnimation("game1BoxAnim")
    cc.AnimationCache:getInstance():removeAnimation("lightAnim")

    cc.AnimationCache:getInstance():removeAnimation("dealerComAnim")
    cc.AnimationCache:getInstance():removeAnimation("leftComAnim")
    cc.AnimationCache:getInstance():removeAnimation("rightComAnim")
    cc.AnimationCache:getInstance():removeAnimation("deskAnim")
    cc.AnimationCache:getInstance():removeAnimation("goldAnim")

    cc.AnimationCache:getInstance():removeAnimation("dealerDiceAnim")
    cc.AnimationCache:getInstance():removeAnimation("leftCheerAnim")
    cc.AnimationCache:getInstance():removeAnimation("rightCheerAnim")

    cc.AnimationCache:getInstance():removeAnimation("dealerOpenAnim")
    cc.AnimationCache:getInstance():removeAnimation("dealerAngerAnim")
    cc.AnimationCache:getInstance():removeAnimation("dealerHappyAnim")

    cc.AnimationCache:getInstance():removeAnimation("leftHappyAnim")
    cc.AnimationCache:getInstance():removeAnimation("leftCryAnim")
    cc.AnimationCache:getInstance():removeAnimation("rightHappyAnim")
    cc.AnimationCache:getInstance():removeAnimation("rightCryAnim")
end

function PreLoading.readAniams()
 	--game1
    PreLoading.readAnimation("action_dagu_", "daguAnim", g_var(cmd).ACT_DAGU_NUM,0.1,2);
    PreLoading.readAnimation("action_title_", "titleAnim", g_var(cmd).ACT_TITLE_NUM,0.3,2);
 	PreLoading.readAnimation("action_wyaoqi_", "wYaoqiAnim", g_var(cmd).ACT_QIZHIWAIT_NUM,0.1,2);
	PreLoading.readAnimation("action_ryaoqi_", "rYaoqiAnim", g_var(cmd).ACT_QIZHI_NUM,0.1,2);
	PreLoading.readAnimation("game1_flash_", "flashAnim", 10,0.1,2);
	PreLoading.readAnimation("game1_box_", "game1BoxAnim",6,0.1,1);
	PreLoading.readAnimation("common_light_", "lightAnim",9,0.1,2);
	--game2
	PreLoading.readAnimation("dealer_common_0","dealerComAnim",8,0.1,1);
	PreLoading.readAnimation("left_common_", "leftComAnim",27,0.1,2);
	PreLoading.readAnimation("right_common_", "rightComAnim",25,0.5,2);
	PreLoading.readAnimation("desk_", "deskAnim",5,0.1,1);
	PreLoading.readAnimation("game2_Gold_", "goldAnim",4,0.1,1);

	PreLoading.readAnimation("dealer_dice_", "dealerDiceAnim",29,0.1,2);
	PreLoading.readAnimation("left_cheer_", "leftCheerAnim",29,0.1,2);
	PreLoading.readAnimation("right_cheer_", "rightCheerAnim",29,0.1,2);
	PreLoading.readAnimation("desk_", "deskAnim",5,0.1,1);
	PreLoading.readAnimation("game2_Gold_", "goldAnim",4,0.1,1);

	PreLoading.readAnimation("dealer_open_", "dealerOpenAnim",14,0.1,2);
	PreLoading.readAnimation("dealer_anger_", "dealerAngerAnim",25,0.1,2);
	PreLoading.readAnimation("dealer_happy_0", "dealerHappyAnim",7,0.3,1);

	PreLoading.readAnimation("left_happy_", "leftHappyAnim",55,0.1,2);
	PreLoading.readAnimation("left_cry_", "leftCryAnim",36,0.1,2);

	PreLoading.readAnimation("right_happy_", "rightHappyAnim",18,0.1,2);
	PreLoading.readAnimation("right_cry_", "rightCryAnim",26,0.1,2);
end

return PreLoading