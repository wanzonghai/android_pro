--
-- Author: luo
-- Date: 2016年12月30日 17:46:35
-- 预加载资源
local PreLoading = {}
local module_pre ="game.yule.97quanhuang.src"
local res_path =  "game/yule/97quanhuang/res/"
local cmd = module_pre .. ".models.CMD_Game"
local g_var = g_ExternalFun.req_var
PreLoading.bLoadingFinish = false
PreLoading.loadingPer = 100
PreLoading.bFishData = false

local textureCacheTab = {}

function PreLoading.resetData()
	PreLoading.bLoadingFinish = false
	PreLoading.loadingPer = 50
	PreLoading.bFishData = false
end

function PreLoading.StopAnim(bRemove)
	local scene = cc.Director:getInstance():getRunningScene()
	local layer = scene:getChildByTag(200000) 

	if not tolua.cast(layer,"cc.Layer")  then
		return
	end

	if not bRemove then
		-- if nil ~= PreLoading.fish then
		-- 	PreLoading.fish:stopAllActions()
		-- end
	else
	    
		layer:stopAllActions()
        layer:runAction(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(function()
            layer:removeFromParent()
        end)))
		
	end
end

function PreLoading.loadTextures()
	local plists = {
                    "Game1_Terrace/Avatar_Animation/SHOWBEGIN"                     ,  
                    "Game1_Terrace/ICON/QHICON"                                    , 
                    
				    "Game1_Terrace/Avatar_Animation/QH_CAOBAOJIAN"                 , 
                    "Game1_Terrace/Avatar_Animation/QH_DIANNAN"                    ,
                    "Game1_Terrace/Avatar_Animation/QH_DAMEN"                      ,
                    "Game1_Terrace/Avatar_Animation/QH_KARUI"                      ,
                    "Game1_Terrace/Avatar_Animation/QH_HUOWU"                      ,
                    "Game1_Terrace/Avatar_Animation/QH_CAOTIJI"                    ,
                    "Game1_Terrace/Avatar_Animation/QH_CHENGUOHAN"                 ,
                    "Game1_Terrace/Avatar_Animation/QH_KALEKE"                     ,  
                    "Game1_Terrace/ICON/game1_itemJump"                            ,
                    "Game1_Terrace/Specia_Effects/GunDongTeXiao/XT_1120_1"         ,                                     -- 加速特效 
                    "Game1_Terrace/Specia_Effects/BeiShu/XT_11111"                 ,   
                    "Game1_Terrace/Specia_Effects/BeiShu/XT_11111_1"               ,   
                    "Game1_Terrace/Specia_Effects/BeiShu/XT_11111_2"               ,                                    -- 倍数特效 
                    "Game1_Terrace/Specia_Effects/BaiShen/XT_1130_2"               , 
                    "Game1_Terrace/Specia_Effects/JunNV/XT_1140_2"                 ,  
                    "Game1_Terrace/Specia_Effects/TaiYangShen/XT_1150_2"           ,
                    "Game1_Terrace/Specia_Effects/TaiYangShen/XT_1150_3"           ,                                   -- 特殊图标特效 
                    "Game1_Terrace/Specia_Effects/Small_Game_Effects/XT-1163"      ,
                    "Game1_Terrace/Specia_Effects/Small_Game_Effects/XT_1166"      ,  
                    "Plist/Dai_Ji"                                                 ,  
                    "Plist/BJB75"                                                  ,   
                    "Plist/BZN75"                                                  ,   
                    "Plist/QH_CBS75"                                               ,   
                    --"Plist/CBS"                                                    ,   
                    "Plist/YGPZ75"                                                 ,     
                    "Plist/KUIHUA"                                                 ,     
                    "Plist/QH_QYY"                                                 ,     
					"Plist/qh.plist",
 --                   "Plist/QYY"                                                    ,      
                    "Game1_Terrace/Small/Specia_Effects/User_Operation/X_1160"     ,                               --小游戏按钮按下状态特效  
                    "Game1_Terrace/Small/Specia_Effects/User_Operation/quang_huang_TX_1111_2"     ,                              
                    "Game1_Terrace/Small/Specia_Effects/User_Operation/quan_huang_1190"     ,                              
                    "Game1_Terrace/Small/Specia_Effects/User_Operation/quan_huang_TX_1164_3"     ,                                 
                    "Game1_Terrace/Small/Specia_Effects/User_Operation/XT_1111_1"     ,                              
                    "Game1_Terrace/Small/Btn/XT_1166"                              ,                               --小游戏按钮按下状态特效      quang_huang_TX_1111_2																						
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
        PreLoading.loadingBar:setPercentage(m_nImageOffset / totalSource * 100)
        if m_nImageOffset == totalSource then
        	--加载PLIST
        	--[[for i=1,#plists do
        		cc.SpriteFrameCache:getInstance():addSpriteFrames(res_path..plists[i]..".plist")
                
        		local dict = cc.FileUtils:getInstance():getValueMapFromFile(res_path..plists[i]..".plist")
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



			PreLoading.Finish()

			if PreLoading.bFishData  then
				PreLoading.bFishData = false
				local scene = cc.Director:getInstance():getRunningScene()
				local layer = scene:getChildByTag(200000) 
				if not layer  then
					return
				end

				PreLoading.loadingBar:stopAllActions()
				PreLoading.loadingBar = nil
				layer:stopAllActions()
				layer:removeFromParent()
                PreLoading.Run_Begin_Game()

			    --通知
			    local event = cc.EventCustom:new(g_var(cmd).Event_LoadingFinish)
			    print("发布监听通知",event)
			    dump(event)
			    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
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
    local function createSchedule( )
    	local function update( dt )
			PreLoading.updatePercent(PreLoading.loadingPer)
		end
		local scheduler = cc.Director:getInstance():getScheduler()
		PreLoading.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0, false)
    end
	--进度条
	PreLoading.GameLoadingView()
    textureCacheTab = {}
    loadImages()
	--createSchedule()
	--PreLoading.addEvent()
end


function PreLoading.Run_Begin_Game()
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = display.newLayer()
	layer:setTag(200000)
	scene:addChild(layer,30)
     -- 特殊图标动画
     PreLoading.FatherBiZhi = cc.Sprite:create("Game1_Terrace/Small/blank.png")
     PreLoading.FatherBiZhi:setPosition(230,135)
     PreLoading.FatherBiZhi:setAnchorPoint(0,0)
     layer:addChild(PreLoading.FatherBiZhi,0)
      
       
    local strAnimePath = 
    {
        --"Show_%02d.png" 
        "QHSHOW_%02d.png"
    }

    local animation = cc.Animation:create()
     
    for i=1,22 do
		local frameName = string.format(strAnimePath[1],i) 
		print (frameName)
        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)  
		animation:addSpriteFrame(spriteFrame)
	end  
     
	animation:setDelayPerUnit(0.1)          --设置两个帧播放时间                   
	animation:setRestoreOriginalFrame(false)    --动画执行后还原初始状态     

	local action = cc.Animate:create(animation)
	local seq =   cc.Sequence:create(
		    action,
		    cc.CallFunc:create(function (  )
			        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(strAnimePath[1],2))  
                    PreLoading.FatherBiZhi:setSpriteFrame(frame) 
		    end)
	    )

	    PreLoading.FatherBiZhi:runAction(action) -- 目前开启了一直重复播放呼吸动画， 使用stopAllActions()暂停播放
        --音效
        --g_ExternalFun.playBackgroudAudio("QHLHJ_ditu.mp3")
end


function PreLoading.unloadTextures( )

	local plists = {
					"Game1_Terrace/Avatar_Animation/SHOWBEGIN"                     ,  
                    --"Game1_Terrace/ICON/QHICON"                                    , 
                    
				    "Game1_Terrace/Avatar_Animation/QH_CAOBAOJIAN"                 , 
                    "Game1_Terrace/Avatar_Animation/QH_DIANNAN"                    ,
                    "Game1_Terrace/Avatar_Animation/QH_DAMEN"                      ,
                    "Game1_Terrace/Avatar_Animation/QH_KARUI"                      ,
                    "Game1_Terrace/Avatar_Animation/QH_HUOWU"                      ,
                    "Game1_Terrace/Avatar_Animation/QH_CAOTIJI"                    ,
                    "Game1_Terrace/Avatar_Animation/QH_CHENGUOHAN"                 ,
                    "Game1_Terrace/Avatar_Animation/QH_KALEKE"                     ,  
                    "Game1_Terrace/ICON/game1_itemJump"                            ,
                    "Game1_Terrace/Specia_Effects/GunDongTeXiao/XT_1120_1"         ,                                     -- 加速特效 
                    "Game1_Terrace/Specia_Effects/BeiShu/XT_11111"                 ,   
                    "Game1_Terrace/Specia_Effects/BeiShu/XT_11111_1"               ,   
                    "Game1_Terrace/Specia_Effects/BeiShu/XT_11111_2"               ,                                    -- 倍数特效 
                    "Game1_Terrace/Specia_Effects/BaiShen/XT_1130_2"               , 
                    "Game1_Terrace/Specia_Effects/JunNV/XT_1140_2"                 ,  
                    "Game1_Terrace/Specia_Effects/TaiYangShen/XT_1150_2"           ,
                    "Game1_Terrace/Specia_Effects/TaiYangShen/XT_1150_3"           ,                                   -- 特殊图标特效 
                    "Game1_Terrace/Specia_Effects/Small_Game_Effects/XT-1163"      ,
                    "Game1_Terrace/Specia_Effects/Small_Game_Effects/XT_1166"      ,  
                    "Plist/Dai_Ji"                                                 ,  
                    "Plist/BJB75"                                                  ,   
                    "Plist/BZN75"                                                  ,   
                    "Plist/CBS75"                                                  ,   
                    "Plist/YGPZ75"                                                 ,     
                    "Plist/KUIHUA"                                                 ,     
                    "Plist/QYY"                                                    ,      
                    "Game1_Terrace/Small/Specia_Effects/User_Operation/X_1160"     ,                               --小游戏按钮按下状态特效  
                    "Game1_Terrace/Small/Specia_Effects/User_Operation/quang_huang_TX_1111_2"     ,                              
                    "Game1_Terrace/Small/Specia_Effects/User_Operation/quan_huang_1190"     ,                              
                    "Game1_Terrace/Small/Specia_Effects/User_Operation/quan_huang_TX_1164_3"     ,                                 
                    "Game1_Terrace/Small/Specia_Effects/User_Operation/XT_1111_1"     ,                              
                    "Game1_Terrace/Small/Btn/XT_1166"                              ,                               --小游戏按钮按下状态特效      quang_huang_TX_1111_2
                                                                                                                    --加载拳皇头像动画帧
																													
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
		local layer = scene:getChildByTag(200000) 
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
	layer:setTag(200000)
	scene:addChild(layer,30)

	PreLoading.loadingBG = ccui.ImageView:create(res_path.."loading/preBg_11.png")
	PreLoading.loadingBG:setTag(1)
	PreLoading.loadingBG:setTouchEnabled(true)
	PreLoading.loadingBG:setPosition(cc.p(ylAll.WIDTH/2+g_offsetX,ylAll.HEIGHT/2))
	layer:addChild(PreLoading.loadingBG)

    

	local loadingBarBG = ccui.ImageView:create(res_path.."loading/progress_bar_bg.png")
	loadingBarBG:setTag(2)
    --loadingBarBG:setScale(1.44)
	loadingBarBG:setPosition(cc.p(ylAll.WIDTH/2 + g_offsetX,12))
    loadingBarBG:setScale9Enabled(true)
    loadingBarBG:setContentSize(cc.size(539,33))
    loadingBarBG:setCapInsets(cc.rect(0,0,0,0))
	layer:addChild(loadingBarBG)

	PreLoading.loadingBar = cc.ProgressTimer:create(cc.Sprite:create(res_path.."loading/progress_bar.png"))
	PreLoading.loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    PreLoading.loadingBar:setScale(1.44)
	PreLoading.loadingBar:setMidpoint(cc.p(0.0,0.5))
	PreLoading.loadingBar:setBarChangeRate(cc.p(1,0))
    PreLoading.loadingBar:setPosition(cc.p(loadingBarBG:getContentSize().width/2,loadingBarBG:getContentSize().height/2))
    --PreLoading.loadingBar:runAction(cc.ProgressTo:create(0.2,20))
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
--    cc.AnimationCache:getInstance():removeAnimation("daguAnim")
--    cc.AnimationCache:getInstance():removeAnimation("titleAnim")
--    cc.AnimationCache:getInstance():removeAnimation("wYaoqiAnim")
--    cc.AnimationCache:getInstance():removeAnimation("rYaoqiAnim")
--    cc.AnimationCache:getInstance():removeAnimation("flashAnim")

--    cc.AnimationCache:getInstance():removeAnimation("game1BoxAnim")
--    cc.AnimationCache:getInstance():removeAnimation("lightAnim")

--    cc.AnimationCache:getInstance():removeAnimation("dealerComAnim")
--    cc.AnimationCache:getInstance():removeAnimation("leftComAnim")
--    cc.AnimationCache:getInstance():removeAnimation("rightComAnim")
--    cc.AnimationCache:getInstance():removeAnimation("deskAnim")
--    cc.AnimationCache:getInstance():removeAnimation("goldAnim")

--    cc.AnimationCache:getInstance():removeAnimation("dealerDiceAnim")
--    cc.AnimationCache:getInstance():removeAnimation("leftCheerAnim")
--    cc.AnimationCache:getInstance():removeAnimation("rightCheerAnim")

--    cc.AnimationCache:getInstance():removeAnimation("dealerOpenAnim")
--    cc.AnimationCache:getInstance():removeAnimation("dealerAngerAnim")
--    cc.AnimationCache:getInstance():removeAnimation("dealerHappyAnim")

--    cc.AnimationCache:getInstance():removeAnimation("leftHappyAnim")
--    cc.AnimationCache:getInstance():removeAnimation("leftCryAnim")
--    cc.AnimationCache:getInstance():removeAnimation("rightHappyAnim")
--    cc.AnimationCache:getInstance():removeAnimation("rightCryAnim")
end

function PreLoading.readAniams()
-- 	--game1
--    PreLoading.readAnimation("action_dagu_", "daguAnim", g_var(cmd).ACT_DAGU_NUM,0.1,2);
--    PreLoading.readAnimation("action_title_", "titleAnim", g_var(cmd).ACT_TITLE_NUM,0.3,2);
-- 	PreLoading.readAnimation("action_wyaoqi_", "wYaoqiAnim", g_var(cmd).ACT_QIZHIWAIT_NUM,0.1,2);
--	PreLoading.readAnimation("action_ryaoqi_", "rYaoqiAnim", g_var(cmd).ACT_QIZHI_NUM,0.1,2);
--	PreLoading.readAnimation("game1_flash_", "flashAnim", 10,0.1,2);
--	PreLoading.readAnimation("game1_box_", "game1BoxAnim",6,0.1,1);
--	PreLoading.readAnimation("common_light_", "lightAnim",9,0.1,2);
--	--game2
--	PreLoading.readAnimation("dealer_common_0","dealerComAnim",8,0.1,1);
--	PreLoading.readAnimation("left_common_", "leftComAnim",27,0.1,2);
--	PreLoading.readAnimation("right_common_", "rightComAnim",25,0.5,2);
--	PreLoading.readAnimation("desk_", "deskAnim",5,0.1,1);
--	PreLoading.readAnimation("game2_Gold_", "goldAnim",4,0.1,1);

--	PreLoading.readAnimation("dealer_dice_", "dealerDiceAnim",29,0.1,2);
--	PreLoading.readAnimation("left_cheer_", "leftCheerAnim",29,0.1,2);
--	PreLoading.readAnimation("right_cheer_", "rightCheerAnim",29,0.1,2);
--	PreLoading.readAnimation("desk_", "deskAnim",5,0.1,1);
--	PreLoading.readAnimation("game2_Gold_", "goldAnim",4,0.1,1);

--	PreLoading.readAnimation("dealer_open_", "dealerOpenAnim",14,0.1,2);
--	PreLoading.readAnimation("dealer_anger_", "dealerAngerAnim",25,0.1,2);
--	PreLoading.readAnimation("dealer_happy_0", "dealerHappyAnim",7,0.3,1);

--	PreLoading.readAnimation("left_happy_", "leftHappyAnim",55,0.1,2);
--	PreLoading.readAnimation("left_cry_", "leftCryAnim",36,0.1,2);

--	PreLoading.readAnimation("right_happy_", "rightHappyAnim",18,0.1,2);
--	PreLoading.readAnimation("right_cry_", "rightCryAnim",26,0.1,2);
end

return PreLoading