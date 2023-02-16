function ccui.Button:asSwitch(init, on, off, func)
	local function open(ison)
		local tex = off
		if ison then 
			tex = on
		end

		if cc.TextureCache:getInstance():addImage(tex) then
			self:loadTextureDisabled(tex)
			self:loadTextureNormal(tex)
			self:loadTexturePressed(tex)
		else
			self:loadTextureDisabled(tex, UI_TEX_TYPE_PLIST)
			self:loadTextureNormal(tex, UI_TEX_TYPE_PLIST)
			self:loadTexturePressed(tex, UI_TEX_TYPE_PLIST)
		end

		self.ison = ison
	end

	open(init)

	self:onClicked(function()
		open(not self.ison)
		func(self.ison)
	end)
end
local abs = math.abs
function ccui.Widget:onClickEnd(f, arg, nosacle,checkMove)
	local srcScale = 1
    nosacle = nosacle or false
    self._checkMove = checkMove
    self._applyFunc = true
	self:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
            if arg == "" or arg == false then
			elseif type(arg) == "number" or arg == true then
                g_ExternalFun.playEffect("sound/btn_close.mp3")
            else
                g_ExternalFun.playEffect("sound/music_button.mp3")
            end
            self:setScale(srcScale)
            if self._applyFunc == true then
                f(self)
            end
		elseif eventType == ccui.TouchEventType.moved then
            self._touchMovePos = sender:getTouchMovePosition()
            if self._checkMove==true and self._applyFunc ==true then
                if self._touchPos then
                    if abs(self._touchPos.x - self._touchMovePos.x) >= 20 then
                        self._applyFunc = false
                        self:setScale(srcScale)
                    end
                end
            end
		elseif eventType == ccui.TouchEventType.canceled then
            self:setScale(srcScale)
        elseif eventType == ccui.TouchEventType.began then
            if not nosacle then
               self:setScale(srcScale+0.02)
            end
            self._touchPos = sender:getTouchBeganPosition()
            self._applyFunc = true
        end
	end)
end

function ccui.EditBox:setString(s)
	self:setText(s)
end
function ccui.EditBox:getString()
	return self:getText()
end
function ccui.TextField:getText()
	return self:getString()
end

function ccui.EditBox:onReturn(func1,func2,func3)
	self:registerScriptEditBoxHandler(function(name)
		if func1 and name == "began" then
			func1()
		end
		if func2 and name == "changed" then
			func2()
		end
		if func3 and name == "return" then
			func3()
		end
	end)
end

function ccui.TextField:onReturn(func)
	self._ok_func = func
end

function ccui.TextField:onTextChange(f)
	self:addEventListener(function(_, e)
		if e == ccui.TextFiledEventType.insert_text  or
			e==ccui.TextFiledEventType.delete_backward then
			f()
		end
	end)
end

function ccui.EditBox:onTextChange(f)
	self:registerScriptEditBoxHandler(function(e)
		if e == 'changed' then
			f()
		end
	end)
end


function ccui.TextField:convertToEditBox(inputmode)
	if true or device.platform ~= 'windows' then
		local size = self:getSize()
		local box = ccui.EditBox:create(cc.size(size.width, size.height), "hall/temp_edit_bg.png")

		box:setName(self:getName())
		box:setText(self:getString())
		box:setPosition(self:getPosition())
		box:setAnchorPoint(self:getAnchorPoint())

		box:setPlaceHolder(self:getPlaceHolder())
		box:setPlaceholderFontSize(self:getFontSize())
		box:setPlaceholderFontColor(cc.c3b(255,255,255))
		if inputmode then
			box:setInputMode(inputmode)
		else
			box:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		end

		box:setFontName(self:getFontName())
		box:setFontSize(self:getFontSize()-2)
		box:setFontColor(self:getColor())
		box:addTo(self:getParent())

		if self:isPasswordEnabled() then
			box:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		else
			box:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
		end

		self:removeSelf()
		return box
	else
		self:setCursorEnabled(true)
		-- local layer =cc.LayerColor:create(cc.c4b(255,255,255,255)):hide()
		-- local h = self:getFontSize()
		-- layer:setContentSize(cc.size(3, h))
		-- layer:setPositionY(self:getContentSize().height/2 - h/2)
		-- self:addChild(layer)
		-- local function update()
		-- 	if self:getString() == "" then
		-- 		layer:setPositionX(1)
		-- 	else
		-- 		local w = self:getAutoRenderSize().width
		-- 		if w > self:getContentSize().width then 
		-- 			w = self:getContentSize().width
		-- 		end
		-- 		layer:setPositionX(w + 1)
		-- 	end
		-- end
		-- update()
		-- self:runAction(cc.RepeatForever:create(cc.Sequence:create({
		-- 	cc.DelayTime:create(0.3),
		-- 	cc.CallFunc:create(function()
		-- 		if self:isFocused() then
		-- 			layer:setVisible(not layer:isVisible())
		-- 		else
		-- 			if layer:isVisible() then
		-- 				layer:setVisible(false)
		-- 				if self._ok_func then
		-- 					self._ok_func()
		-- 				end
		-- 			end
		-- 		end
		-- 	end)
		-- })))

		-- function self:setString(str)
		-- 	ccui.TextField.setString(self, str)
		-- 	update()
		-- end

		-- self:addEventListener(update)
		return self
	end

end


cc = cc or {}
function cc.runActions(node, ...) 
	local args = {...}
	if #args == 0 then return end
	
	local actions = {}
	for i, v in ipairs(args) do
		local t = type(v)
		if t == "number" then
			table.insert(actions, cc.DelayTime:create(v))
		elseif t == "function" then
			table.insert(actions, cc.CallFunc:create(v))
		else
			table.insert(actions, v)
		end
	end

	node:runAction(transition.sequence(actions))
end

function cc.getDuration(timeline, name)
	local info = timeline:getAnimationInfo(name)
	local speed = timeline:getTimeSpeed()  
	return (info.endIndex - info.startIndex) * (1/60) / speed
end

function cc.playCSB(parent, csbfile, name, func_or_loop)
	local csbnode = cc.CSLoader:createNode(csbfile);
	local timeline = cc.CSLoader:createTimeline(csbfile);	 
	csbnode:runAction(timeline)
	parent:addChild(csbnode)

	local loop = false
	if type(func_or_loop) == "boolean" then
		loop = func_or_loop
	else
		local duration = cc.getDuration(timeline, name)
		print(duration)
		cc.runActions(csbnode, duration, func_or_loop)
	end

	timeline:play(name, loop)

	return csbnode, timeline
end

function cc.setMaxLength(label, maxLen)

	local text = nil
	local old_setString = label.setString

	label.setString = function(_, str)
		if str == text then
			return
		end

		text = str
        
		old_setString(label, ef.formatName(str, maxLen))
	end

	label.getString = function()
		return text
	end
end

function cc.safeRequire(s)
	local r = nil
	pcall(function() r = require(s) end)
	return r
end

function bind(obj, method, ...)
	local args = {...}
	if type(obj) == "function" then
		return function() obj(method, unpack(args)) end
	else
		return function() method(obj, unpack(args)) end
	end
end

--[[
	动态列表，和tabview原理一样，
	scroll scrollview
	temp 是列表元素，anchor必须在 0，0点
	n 表示n个元素
	func （item， index）
]]
function cc.make_dylist(scroll, n, temp, func, offset)
	local ih = temp:getContentSize().height
	local sh = scroll:getContentSize().height
	offset = offset or 0	
	local h = math.max(ih * n + offset, sh)
	local realh = h - offset

	scroll:addEventListener(function()end)
	scroll:removeAllChildren()
	scroll:setInnerContainerSize(cc.size(scroll:getContentSize().width, h))

	local items = {}

	local totalh = 0
	for i=1, 100 do
		items[i] = temp:clone():show():addTo(scroll)
		items[i]:setPositionX(0)
		items[i]:setTag(i)
		totalh = totalh + ih
		if totalh >= sh + ih * 2 then
			break
		end
	end

	local pos = {}
	for i=1, n do
		pos[i] = realh - i*ih
	end

	local function update()
		local y = scroll:getInnerContainerPosition().y
		local percent = math.min(math.max((realh-sh+y)/realh,0),1)

		for i, v in ipairs(items) do
			local index = math.floor(percent * n) + i
			v:setPositionY(pos[index] or 0)
			v:setTag(index)
			if index <= 0 or index > n then
				v:hide()
			elseif v.index ~= index then
				v:show()
				func(v, index)
			end
			v.index = index
		end
	end	
	update()

	scroll:addEventListener(update)
end
