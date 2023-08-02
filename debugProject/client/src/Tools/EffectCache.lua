local frameCache = cc.SpriteFrameCache:getInstance()

local fileutils = cc.FileUtils:getInstance()
local csloader = cc.CSLoader

local M = class('EffectCache', cc.Node)

local EffType = {
	Particle = 1, -- 粒子
	Csb 	 = 2, -- cocosstudio 动画
	Frames   = 3, -- 帧动画
	Spine    = 4, -- spine动画
}
EffType.Tag = 1111

M.EffType = EffType

local Eff = {}

Eff[EffType.Particle] = {
	load = function(info)
		return cc.ParticleSystemQuad:create(info.dict)
	end,

	duration = function(node, info)
		return node:getDuration() + node:getLife()
	end,

	play = function(node, info, loop)
		node:resetSystem()
	end,

	free = function(info, nodes)
		for i, node in ipairs(nodes) do
			node:release()
		end
	end,
}

Eff[EffType.Csb] = {
	load = function(info)
		local node = csloader:createNode(info.file)
		node.timeline = info.timeline:clone()
		node.timeline:retain()
		return node
	end,

	duration = function(node, info)
		return cc.getDuration(info.timeline, info.animation)
	end,

	play = function(node, info, loop)
		node:stopAction(node.timeline)
		node:runAction(node.timeline)
		node.timeline:play(info.animation, loop)
	end,

	free = function(info, nodes)
		info.timeline:release()
		for i, node in ipairs(nodes) do
			node.timeline:release()
			node:release()
		end
	end,
}

Eff[EffType.Frames] = {
	load = function(info)
        local sp = display.newSprite()
        sp:setTag(EffType.Tag)
		return sp
	end,

	duration = function(node, info)
		return info.animation:getDuration()
	end,

	play = function(node, info, loop)
		node:stopAllActions()
		if loop then
			node:playAnimationForever(info.animation)
		else
			node:playAnimationOnce(info.animation, {})
		end
	end,

	free = function(info, nodes)
		info.animation:release()
		for i, node in ipairs(nodes) do
			node:release()
		end
	end
}

Eff[EffType.Spine] = {
	load = function(info)
        local spNode = sp.SkeletonAnimation:create(info.json, info.atlas, 1)
        spNode:setTag(EffType.Tag)
		return spNode
	end,

	duration = function(node, info)
		return 0
	end,

	play = function(node, info, loop)
		node:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
		if info.skin then
			node:setSkin(info.skin)
		end
		node:setAnimation(0, info.animation_name, loop)	
	end,


	free = function(info, nodes)
		for i, node in ipairs(nodes) do
			node:release()
		end
	end,
}

function M:ctor()
	self:onNodeEvent('exit', function()
		self:releaseAll()
	end)	

	self.caches = {}
	self.name_nodes = {}
end


function M:releaseAll()
	print('EffectCache:releaseAll')
    if self.caches and self.name_nodes then
	    for key, info in pairs(self.caches) do
            if self.name_nodes[info.name] then
	    	    Eff[info.type].free(info, self.name_nodes[info.name])
            end
	    end
    end
	self.caches = nil
	self.name_nodes = nil
end

function M:addParticle(name, file)
	local dict = fileutils:getValueMapFromFile(file)
	dict.textureFileName = path.join(path.getdir(file), dict.textureFileName)
	self:add(name, EffType.Particle, {
		dict = dict,
		file = file,
	})
end

function M:addCsb(name, file, animation)
	local timeline = csloader:createTimeline(file)
	timeline:retain()
	self:add(name, EffType.Csb, {
		timeline = timeline,
		file = file,
		animation = animation,
	})
end

local function makeFrames(fmt, min, max)
	local frames = {}
	for i=min, max do
        local frame = frameCache:getSpriteFrame(string.format(fmt, i)) 
        table.insert(frames, frame)
	end
	return frames
end

function M:addFrames1(name, fmt, min, max, interval)
	self:addFrames(name, makeFrames(fmt, min, max), interval)
end

function M:addFrames(name, frames, interval)
	local animation = cc.Animation:createWithSpriteFrames(frames, interval)
	animation:retain()
	self:add(name, EffType.Frames, {
		animation = animation,
	})
end

function M:addSpine(name, json, atlas, animation_name, skin)
	self:add(name, EffType.Spine, {
		json=json,
		atlas=atlas,
		animation_name=animation_name,
		skin=skin
	})
end

function M:addMusicCache(musicPath)
    AudioEngine.preloadEffect(musicPath)
end

function M:loadOne(info)
	local node = Eff[info.type].load(info)

	local nodes = self.name_nodes[info.name]
	table.insert(nodes, node)

	node:retain()
	node.info = info
	node.id = #nodes
	return node
end

function M:add(name, type, info)
	info.type = type
	info.name = name
	self.caches[name] = info
	self.name_nodes[name] = {}
	self:loadOne(info)
end

function M:cacheAll()
	--[[for name, nodes in pairs(self.name_nodes) do
		self:get(name)
	end]]
end

function M:get(name)
	local info = self.caches[name]

	-- 回收
	for i, v in ipairs(self.name_nodes[name]) do
		if not v:getParent() then
			return v
		end
	end
	return self:loadOne(info)
end
function M:getDuration(node)
	local info = node.info
	return Eff[info.type].duration(node, info)
end

function M:playNode(node, loop)
	local info = node.info
	Eff[info.type].play(node, info, loop)
end

function M:play(parent, name, loop)
	local node = self:get(name)
    if node == nil then 
        print("aaa")
    end
    node:setName(name)
	node:addTo(parent)

	local info = node.info
	Eff[info.type].play(node, info, loop)

	return node
end

function M:getAndPlay(name, auto, cb)
	local node = self:get(name)
	if not node then
		print('特效不存在', name)
		return
	end

	local info = node.info
	Eff[info.type].play(node, info, false)

	if auto then
		if node.info.type == EffType.Spine then
			node:registerSpineEventHandler(function(e) 
				node:removeSelf()
				if cb then cb() end
			end, sp.EventType.ANIMATION_COMPLETE)
		else
			local d = Eff[node.info.type].duration(node, node.info)
			cc.runActions(node, 
				d, 
				function() if cb then cb() end end, 
				cc.RemoveSelf:create())
		end
	end
	return node
end

function M:addLeaveFish(obj)
    if obj == nil then return end
    local node = obj:getChildByTag(EffType.Tag)
    if node == nil then return end
    local name = node:getName()
    if name == "" then return end
    table.removebyvalue(self.name_nodes[name],node)
    table.insert(self.name_nodes[name],1,node)
end

return M