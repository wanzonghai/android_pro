local module_pre = "game.yule.dntg.src"	

local TaskRunner = require(module_pre ..'.models.TaskRunner')
local cmd = require(module_pre .. ".models.CMD_YQSGame")
local frameCache = cc.SpriteFrameCache:getInstance()

local fishcfg = require(module_pre..".models.cfg_fish_animation")
local cannoncfg = require(module_pre..".models.cfg_cannon")
local effectcfg = require(module_pre..".models.cfg_effect")
local musiccfg = {
    "GunFire0.mp3",
    "Hit0.mp3",
    "SWITCHING_RUN.mp3",
    "CHANGE_SCENE.mp3",
    "electric.mp3",
    "CJ.mp3"
}

local M = class('PreLoading', cc.Layer)

local function makeFrames(fmt, min, max)
	local frames = {}
	for i=min, max do
        local frame = frameCache:getSpriteFrame(string.format(fmt, i)) 
        table.insert(frames, frame)
	end
	return frames
end

local function loadEff(cache, cfg)
	if cfg.type == 'par' then
	    cache:addParticle(cfg.key, cfg.file)
	elseif cfg.type == 'csb' then
	    cache:addCsb(cfg.key, cfg.file, cfg.name)
	elseif cfg.type == 'frm' then
	    cache:addFrames(cfg.key, makeFrames(cfg.fmt, cfg.min, cfg.max), cfg.inteval);
	elseif cfg.type == 'spi' then
		cache:addSpine(cfg.key, cfg.json, cfg.atlas, cfg.name, cfg.skin)	
	end
end
--帧动画
local function loadAnima(cfg)
	local frames = {}
   	local actionTime = cfg.time
	for i=1,cfg.num do

		local frameName
		if cfg.formatBit == 1 then
			frameName = string.format(cfg.file.."%d.png", i-1)
		elseif cfg.formatBit == 2 then
		 	frameName = string.format(cfg.file.."%2d.png", i-1)
		end
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
		
		table.insert(frames, frame)
	end
	local  animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
   	cc.AnimationCache:getInstance():addAnimation(animation, cfg.key)
end


function M:ctor(view)
	self._gameView = view

	local csb = ef.loadCSB('xyaoqianshu/Loading.csb'):addTo(self)

	self.loadingBar = csb:getChildByName('bar')

	local cache = self._gameView._scene.effcache
	-- 
	local runner = TaskRunner.new():addTo(self)
	runner.progress_cb = function(p) self.loadingBar:setPercent(p) end

	-- 鱼
	for i, v in ipairs(fishcfg) do
		runner:addImage(v.image)
		if v.type == 'f' then
			runner:addFunc(function() frameCache:addSpriteFrames(v.plist) end)
		end
	end

	-- 特效和资源
	for i, v in ipairs(effectcfg) do
		if v.type == 'plist' then
			runner:addImage(v.image)
			runner:addFunc(function() frameCache:addSpriteFrames(v.plist) end)
		elseif v.type == 'spi' then
			runner:addImage(v.image)
			runner:addFunc(bind(loadEff, cache, v))
        elseif v.type == 'anima' then
            runner:addFunc(bind(loadAnima, v))
		else
			runner:addFunc(bind(loadEff, cache, v))
		end
	end

	-- 炮台、子弹、网
	runner:addFunc(function()
		for i=1, 10 do
			cache:addCsb("cannon_"..i, cannoncfg.cannon[i].csb, cannoncfg.cannon[i].name)
			--cache:addCsb("bullet_"..i, cannoncfg.bullet[i].csb, cannoncfg.bullet[i].name)
			--cache:addCsb("net_"..i, cannoncfg.net[i].csb, cannoncfg.net[i].name)
		end
	end)

	-- 鱼动画创建
	runner:addFunc(function()

		for i, v in ipairs(fishcfg) do
			if v.type == 'f' then
				cache:addFrames("fish_idle_"..i, makeFrames(v.idle.fmt, v.idle.min, v.idle.max), 0.04)
				cache:addFrames("fish_dead_"..i, makeFrames(v.dead.fmt, v.dead.min, v.dead.max), 0.04)
			elseif v.type == 's' then
				cache:addSpine("fish_idle_"..i, v.json, v.atlas, "idle")	
				cache:addSpine("fish_dead_"..i, v.json, v.atlas, "end")	
			elseif v.type == 'c' then
				cache:addCsb("fish_idle_"..i, v.csb, 'idle')
				cache:addCsb("fish_dead_"..i, v.csb, 'end')
			end
		end
	end)

    --音效预加载 
    runner:addFunc(function()
        for i,v in pairs(musiccfg) do
            cache:addMusicCache("sound_res/"..v)
        end
    end)
    --鱼音效预加载 
    -- runner:addFunc(function()
    --     for i=1,27,1 do
    --         cache:addMusicCache("sound_res/fisha"..i..".mp3")
    --     end
    -- end)
	--[[runner:addFunc(function()
		self._gameView._scene.effcache:cacheAll()
	end)]]

	runner:addFunc(function() 

    	self._gameView.loadingFinish = true
    	print("资源加载完成")

    	--通知
		local event = cc.EventCustom:new(cmd.Event_LoadingFinish)
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
			
		cc.runActions(self, 0.5, function()
			self.mgr:close(self, false)
		end)

	end)

	runner:start()
end

return M