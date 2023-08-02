--
-- Author: luo
-- Date: 2016年12月30日 17:50:01
--
--设置界面

local SettingLayer = class("SettingLayer", cc.Layer)


local ck_kai = "setting/ck_kai.png"
local ck_guan = "setting/ck_guan.png"

--构造
function SettingLayer:ctor( parentNode )
    self._parentNode=parentNode
 	self.csbNode=g_ExternalFun.loadCSB("SHZ_GameSetting.csb",self)
	 g_ExternalFun.openLayerAction(self)

 	local cbtlistener = function (sender,eventType)
    	self:onSelectedEvent(sender:getName(),sender,eventType)
	end

	-- setSelected
	function setSelected(btn)
		function btn:setSelectedEx(is)
			self:setSelected(is)
			if is then
				self:loadTextureBackGround(ck_kai)
				self:loadTextureBackGroundSelected(ck_kai)
			else
				self:loadTextureBackGround(ck_guan)
				self:loadTextureBackGroundSelected(ck_guan)
			end
			return self
		 end
	end

	--英文版本做的工程适配
	appdf.getNodeByName(self.csbNode, "Text_1"):setString("Som")
	local effectTip = appdf.getNodeByName(self.csbNode, "Text_1_0")
	effectTip:setString("Efeitos sonoros")
	effectTip:setScale(0.35)
	effectTip:setPositionX(effectTip:getPositionX() - 5)
	appdf.getNodeByName(self.csbNode, "Text_1_0_0"):setString("Mudo")
	local autoTip = appdf.getNodeByName(self.csbNode, "Text_1_1")
	autoTip:setString("Automático")
	autoTip:setScale(0.6)
	autoTip:setPositionX(autoTip:getPositionX() - 10)
	appdf.getNodeByName(self.csbNode, "Text_1_0_1"):setString('Dia')
	appdf.getNodeByName(self.csbNode, "Text_1_0_0_0"):setString("Noite")

	-- 音效
	self.effectAudio = appdf.getNodeByName(self.csbNode,"cb_Yx")
	 setSelected(self.effectAudio)
	self.effectAudio:setSelectedEx(GlobalUserItem.bSoundAble)
		:addEventListener(cbtlistener)

		self.bgAudio = appdf.getNodeByName(self.csbNode,"cb_Yy")
	setSelected(self.bgAudio)
	self.bgAudio:setSelectedEx(GlobalUserItem.bVoiceAble)
		:addEventListener(cbtlistener)

		self.bgJingyin = appdf.getNodeByName(self.csbNode,"cb_Jy")
	setSelected(self.bgJingyin)
	self.bgJingyin:setSelectedEx(not GlobalUserItem.bVoiceAble and not GlobalUserItem.bSoundAble)
		:addEventListener(cbtlistener)
	
	-- 场景
	self.btnAuto = appdf.getNodeByName(self.csbNode,"cb_Auto")
	setSelected(self.btnAuto)
	self.btnAuto:setSelectedEx(false)
		:addEventListener(cbtlistener)

		self.btnBaitian = appdf.getNodeByName(self.csbNode,"cb_Bt")
	setSelected(self.btnBaitian)
	self.btnBaitian:setSelectedEx(parentNode:getChangeState())
		:addEventListener(cbtlistener)

		self.btnYeWan = appdf.getNodeByName(self.csbNode,"cb_Yw")
	setSelected(self.btnYeWan)
	self.btnYeWan:setSelectedEx(not parentNode:getChangeState())
		:addEventListener(cbtlistener)


	appdf.getNodeByName(self.csbNode,"closeBtn")
		:addClickEventListener(function() 
			g_ExternalFun.closeLayerAction(self,function()
				self:removeSelf()
			end)
        end)
        appdf.getNodeByName(self.csbNode,"btnMask")
		:addClickEventListener(function() 
			g_ExternalFun.closeLayerAction(self,function()
				self:removeSelf()
			end)
        end)
	
	function self:refreshEffect()
		if self.effectAudio:isSelected() or self.bgAudio:isSelected() then
			self.bgJingyin:setSelectedEx(false)
		else
			self.bgJingyin:setSelectedEx(true)
		end
	end
	function self:refreshChange()
		if self.btnBaitian:isSelected() or self.btnYeWan:isSelected() then
			self.btnAuto:setSelectedEx(false)
		else
			self.btnAuto:setSelectedEx(true)
		end
	end


end


function SettingLayer:onSelectedEvent(name,sender,eventType)
	sender:setSelectedEx(sender:isSelected())
	if name == "cb_Yy" then
		GlobalUserItem.setVoiceAble(eventType == ccui.CheckBoxEventType.selected)
		if eventType == ccui.CheckBoxEventType.selected then
			self._parentNode:playBackgroundMusic()
		end
		self:refreshEffect()
	elseif name == "cb_Yx" then
		GlobalUserItem.setSoundAble(eventType == ccui.CheckBoxEventType.selected)
		self:refreshEffect()
	elseif name == "cb_Jy" then
		self.bgAudio:setSelectedEx(eventType ~= ccui.CheckBoxEventType.selected)
		self.effectAudio:setSelectedEx(eventType ~= ccui.CheckBoxEventType.selected)
		GlobalUserItem.setVoiceAble(eventType ~= ccui.CheckBoxEventType.selected)
		GlobalUserItem.setSoundAble(eventType ~= ccui.CheckBoxEventType.selected)
		if eventType ~= ccui.CheckBoxEventType.selected then
			self._parentNode:playBackgroundMusic()
		else
			AudioEngine.stopMusic()
		end

	elseif name == "cb_Bt" then
		self.btnYeWan:setSelectedEx(eventType ~= ccui.CheckBoxEventType.selected)
		if self._parentNode.changeSceneState then
			self._parentNode:changeSceneState(eventType == ccui.CheckBoxEventType.selected)
		end
		self:refreshChange()
	elseif name == "cb_Yw" then
		self.btnBaitian:setSelectedEx(eventType ~= ccui.CheckBoxEventType.selected)
		if self._parentNode.changeSceneState then
			self._parentNode:changeSceneState(eventType ~= ccui.CheckBoxEventType.selected)
		end
		self:refreshChange()
	elseif name == "cb_Auto" then
		self.btnBaitian:setSelectedEx(eventType ~= ccui.CheckBoxEventType.selected)
		self.btnYeWan:setSelectedEx(false)
		if self._parentNode.changeSceneState then
			self._parentNode:changeSceneState(true)
		end
	end
end

return SettingLayer