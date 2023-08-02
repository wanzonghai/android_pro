-- crash 数字选择

local GameDialogBase = appdf.req("game.yule.crash.src.views.layer.GameDialogBase")
local CrashChoosedNumNode = class("CrashChoosedNumNode", GameDialogBase)

-- _wordType 1选择倍数，2选择金额
-- _callBack 回调
-- _curScore 当前金币值
-- _adaptPos 适配位置
-- _removeCall 关闭时的回调
function CrashChoosedNumNode:ctor(_wordType, _callBack, _curScore, _adaptPos, _removeCall,betConfig)
    tlog('CrashChoosedNumNode:ctor')
    CrashChoosedNumNode.super.ctor(self, _adaptPos, 0)
	local csbNode = g_ExternalFun.loadCSB("UI/crash_choose_num_node.csb", self, false)
	self.m_spBg = csbNode:getChildByName("Image_1")
	self.m_wordType = _wordType
	self.m_callBack = _callBack
	self.m_removeCall = _removeCall

	-- local numArray = {}
	-- if _wordType == 1 then
	-- 	numArray = {1.03, 1.07, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45, 1.5, 1.55, 1.6, 2, 2.5, 3, 4, 5}
	-- else
	-- 	numArray = {10000, 20000, 50000, 80000, 100000, 300000, 500000, 800000, 1000000, 2000000, 5000000,
	-- 				 8000000, 10000000, 20000000, 50000000, 100000000, 200000000, 500000000}
	-- end
	self.m_numArray = betConfig
	self.m_lastChoosedBtn = nil
	for i = 1, 18 do
		local btnNode = self.m_spBg:getChildByName(string.format("Button_%d", i))
		btnNode:setPressButtonMusicPath("")
	    btnNode:addTouchEventListener(handler(self, self.onButtonClickedEvent))
		btnNode:setTag(i)
		local text_1 = btnNode:getChildByName("Text_1")
		text_1:setTextColor(cc.c4b(120, 113, 181, 255))
		if _wordType == 1 then
			text_1:setString(g_ExternalFun.formatNumWithPeriod(self.m_numArray[i], "X"))
		else
			local serverKind = G_GameFrame:getServerKind()
			text_1:setString(g_format:formatNumber(self.m_numArray[i],g_format.fType.abbreviation,serverKind))
			if self.m_numArray[i] > _curScore then
				btnNode:setEnabled(false)
				text_1:setTextColor(cc.c4b(61, 59, 80, 255))
			end
		end
		--超框按比例缩放
		local btnSize = btnNode:getContentSize()
		local textSize = text_1:getContentSize()
		if btnSize.width <= textSize.width then
			local f = btnSize.width/textSize.width
			text_1:setScale(f) 
		end
	end
end

function CrashChoosedNumNode:onButtonClickedEvent(_sender, _eventType)
	local tag = _sender:getTag()
	tlog('CrashChoosedNumNode:onButtonClickedEvent ', tag)
	local image_1 = _sender:getChildByName("Image_1")
	local text_1 = _sender:getChildByName("Text_1")
	if self.m_lastChoosedBtn then
		self.m_lastChoosedBtn:getChildByName("Image_1"):setVisible(false)
		self.m_lastChoosedBtn:getChildByName("Text_1"):setTextColor(cc.c4b(120, 113, 181, 255))		
	end
    if _eventType == ccui.TouchEventType.began then
    	g_ExternalFun.playSoundEffect("crash_click_broad.mp3")
    	image_1:setVisible(true)
    	text_1:setTextColor(cc.c4b(255, 255, 255, 255))
    elseif _eventType == ccui.TouchEventType.canceled then
    	image_1:setVisible(false)
    	text_1:setTextColor(cc.c4b(120, 113, 181, 255))
    elseif _eventType == ccui.TouchEventType.ended then
    	-- image_1:setVisible(false)
    	-- text_1:setTextColor(cc.c4b(120, 113, 181, 255))
    	self.m_lastChoosedBtn = _sender
		if self.m_callBack then
			local curNum = self.m_numArray[tag]
			self.m_callBack(curNum, tostring(curNum))
		end
    end
end

function CrashChoosedNumNode:removeEvent()
	--do something
	if self.m_removeCall then
		self.m_removeCall()
	end
    self:removeFromParent()
end

return CrashChoosedNumNode