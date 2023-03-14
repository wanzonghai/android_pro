-- crash 数字输入

local GameDialogBase = appdf.req("game.yule.crash.src.views.layer.GameDialogBase")
local CrashEnterWordNode = class("CrashEnterWordNode", GameDialogBase)

-- _wordType 1输入倍数，2输入金额
-- _maxNum 最大值
-- _enterNum 原始数值
-- _callBack 修改过程中的回调
-- _adaptPos 适配位置
-- _removeCall 关闭时的回调
function CrashEnterWordNode:ctor(_wordType, _maxNum, _enterNum, _callBack, _adaptPos, _removeCall)
    tlog('CrashEnterWordNode:ctor')
    CrashEnterWordNode.super.ctor(self, _adaptPos, 0)
	local csbNode = g_ExternalFun.loadCSB("UI/crash_edit_node.csb", self, false)
	self.m_spBg = csbNode:getChildByName("Image_1")
	self.m_wordType = _wordType
	self.m_callBack = _callBack
	self.m_removeCall = _removeCall
	self.m_maxNum = _maxNum

	for i = 1, 12 do
		local btnNode = self.m_spBg:getChildByName(string.format("Button_%d", i - 1))
		btnNode:setPressButtonMusicPath("")
	    btnNode:addTouchEventListener(handler(self, self.onButtonClickedEvent))
		btnNode:setPressedActionEnabled(false)
		btnNode:getChildByName("Image_2"):setVisible(false)
		btnNode:setTag(i - 1)
		if i == 11 then
			if self.m_wordType == 2 then
				--输入金额没有逗号按钮
				btnNode:getChildByName("Image_1"):setVisible(false)
				btnNode:setTouchEnabled(false)
			end
		end
	end
	self.m_enterText = self.m_spBg:getChildByName("Text_hide_num"):hide()
	-- self.m_enterText:setPositionX(800)
	local image_title = self.m_spBg:getChildByName("Image_2")
	if self.m_wordType == 1 then
		--倍率的由于最终会有X，所以打开的时候要重设一下
		image_title:loadTexture("GUI/enterWord/crash_tz_tz_tzbs.png")
		if _enterNum == 0 then
			self.m_enterText:setString(0)
			if self.m_callBack then
				self.m_callBack(0, "0")
			end
		else
			if math.floor(_enterNum) == _enterNum then
				--整数
				self.m_enterText:setString(_enterNum)
				if self.m_callBack then
					self.m_callBack(_enterNum, tostring(_enterNum))
				end	
			else
				local newStr = g_ExternalFun.formatNumWithPeriod(_enterNum)
				self.m_enterText:setString(newStr)
				if self.m_callBack then
					self.m_callBack(_enterNum, newStr)
				end				
			end
		end
	else
		image_title:loadTexture("GUI/enterWord/crash_tz_tz_tze.png")
		local serverKind = G_GameFrame:getServerKind()
		self.m_enterText:setString(g_format:formatNumber(_enterNum,g_format.fType.standard,serverKind))
	end
	image_title:setContentSize(image_title:getVirtualRendererSize())
end

function CrashEnterWordNode:onButtonClickedEvent(_sender, _eventType)
	local tag = _sender:getTag()
	tlog('CrashEnterWordNode:onButtonClickedEvent ', tag)
	local image_1 = _sender:getChildByName("Image_1")
	local image_2 = _sender:getChildByName("Image_2")
    if _eventType == ccui.TouchEventType.began then
    	g_ExternalFun.playSoundEffect("crash_click_broad.mp3")
    	image_1:loadTexture(string.format("GUI/enterWord/crash_orange_%d.png", tag))
    	image_2:setVisible(true)
    elseif _eventType == ccui.TouchEventType.canceled then
    	image_1:loadTexture(string.format("GUI/enterWord/crash_blue_%d.png", tag))
    	image_2:setVisible(false)
    elseif _eventType == ccui.TouchEventType.ended then	
    	image_1:loadTexture(string.format("GUI/enterWord/crash_blue_%d.png", tag))
    	image_2:setVisible(false)
		if tag == 10 then
			--逗号,相当于小数点
			self:enterCommaFlushShow()
		elseif tag == 11 then
			--删除一位数
			self:enterDelFlushShow()
		else
			--0-9
			self:enterNumberFlushShow(tag)
		end
    end
end

--将string类型的数值转化为number保存
function CrashEnterWordNode:recordCurValue()
	local strNum = self.m_enterText:getString()
	if self.m_wordType == 1 then
		local _nweNumber = string.gsub(strNum, ",", "%.")
		_nweNumber = tonumber(_nweNumber)
		if _nweNumber > self.m_maxNum then
			_nweNumber = self.m_maxNum
			strNum = tostring(self.m_maxNum)
			self.m_enterText:setString(strNum)
		end
		if self.m_callBack then
			self.m_callBack(_nweNumber, strNum)
		end
		-- local newNumber = tonumber(strNum)
		-- newNumber = math.modf(newNumber * 100)
	else
		strNum = string.gsub(strNum, "[%.,]", "")
		strNum = tonumber(strNum)
		if strNum > self.m_maxNum then
			strNum = self.m_maxNum
		end
		local serverKind = G_GameFrame:getServerKind()
		local curStr = g_format:formatNumber(strNum,g_format.fType.standard,serverKind)
		self.m_enterText:setString(curStr)
		if self.m_callBack then
			self.m_callBack(strNum)
		end
	end
	tlog("CrashEnterWordNode:recordCurValue ", strNum)
end

--输入逗号
function CrashEnterWordNode:enterCommaFlushShow()
	if self.m_wordType == 2 then
		return
	end
	local strNum = self.m_enterText:getString()
	local n1, n2 = string.find(strNum, ",")
	if n1 == nil then
		self.m_enterText:setString(string.format("%s,", self.m_enterText:getString()))
		self:recordCurValue()
	else
		tlog("CrashEnterWordNode:enterCommaFlushShow already has comma")
	end
end

--输入删除号
function CrashEnterWordNode:enterDelFlushShow()
	local strNum = self.m_enterText:getString()
    local numLen = string.len(strNum)
	strNum = string.sub(strNum, 1, numLen - 1)
	if strNum == "" or not strNum then
		strNum = "0"
	end
	self.m_enterText:setString(strNum)
	self:recordCurValue()
end

function CrashEnterWordNode:enterNumberFlushShow(_enterWord)
	local strNum = self.m_enterText:getString()
	tlog("CrashEnterWordNode:enterNumberFlushShow ", strNum)
	if strNum == "0" then
		if _enterWord ~= 0 then
			--首位是0不改变
			self.m_enterText:setString(_enterWord)
		else
			tlog("!!!first num is 0, can't add 0 !!!")
			return
		end
	else
		if self.m_wordType == 1 then
			local n1, n2 = string.find(strNum, ",")
			if n1 ~= nil then
			    local numLen = string.len(strNum)
			    local newStr = string.sub(strNum, n2 + 1, numLen)
			    if string.len(newStr) >= 2 then
			    	--最多2位输入
			    	tlog("!!!string.len(newStr) >= 2 !!!")
			    	return
			    else
					self.m_enterText:setString(string.format("%s%d", strNum, _enterWord))
			    end
			else
				self.m_enterText:setString(string.format("%s%d", strNum, _enterWord))
			end
		else
			self.m_enterText:setString(string.format("%s%d", strNum, _enterWord))
		end
	end
	self:recordCurValue()
end

function CrashEnterWordNode:removeEvent()
	--do something
	if self.m_removeCall then
		self.m_removeCall()
	end
    self:removeFromParent()
end

return CrashEnterWordNode