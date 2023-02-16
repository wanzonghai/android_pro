-- truco游戏 按钮操作节点

local TrucoButtonNode = class("TrucoButtonNode", cc.Node)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")
local Node_Distance = 290

local btn_Status = {
	status_truco = 1, 			--正常truco
	status_answer_truco = 2,	--应答truco
	status_continue = 3,		--11分临界应答等待
}
-- 
function TrucoButtonNode:ctor(_btnNode)
	tlog('TrucoButtonNode:ctor')
    self.m_btnNode = _btnNode

    for i = 1, 4 do
    	local btn = _btnNode:getChildByName(string.format("Button_%d", i))
    	btn:setTag(i)
    	btn:onClicked(handler(self, self.onButtonClickEvent))
    	if i ~= 4 then
	    	btn:getChildByName("Image_2"):setVisible(false)
	    	btn:getChildByName("Image_3"):setVisible(false)
	    end
    end
    self:setNodeVisible(false)
end

function TrucoButtonNode:setNodeVisible(_bVisible)
    self.m_isAnswerStatus = btn_Status.status_truco
    self.m_btnNode:stopAllActions()
    for i = 1, 4 do
    	local btn = self.m_btnNode:getChildByName(string.format("Button_%d", i))
    	btn:setVisible(_bVisible)
    	if not _bVisible and i ~= 4 then
	    	btn:getChildByName("Image_2"):setVisible(_bVisible)
	    	btn:getChildByName("Image_3"):setVisible(_bVisible)
	    end
    end
end

--应答或11分继续的时候，自己先应答了，禁用按钮
function TrucoButtonNode:setTrucoBtnEnabled(_bEnabled)
	tlog('TrucoButtonNode:setTrucoBtnEnabled ', _bEnabled)
    for i = 1, 4 do
    	local btn = self.m_btnNode:getChildByName(string.format("Button_%d", i))
    	btn:setEnabled(_bEnabled)
    end
end

function TrucoButtonNode:onButtonClickEvent(_sender)
	local tag = _sender:getTag()
	tlog('TrucoButtonNode:onButtonClickEvent ', tag, self.m_isAnswerStatus)
	if tag == 1 then --认输
		if self.m_isAnswerStatus == btn_Status.status_answer_truco then
		    G_event:NotifyEventTwo(GameLogic.TRUCO_ANSWER_TRUCO, {_type = 1})
		elseif self.m_isAnswerStatus == btn_Status.status_truco then
		    G_event:NotifyEventTwo(GameLogic.TRUCO_START_TRUCO, {_type = 0})
		elseif self.m_isAnswerStatus == btn_Status.status_continue then
		    G_event:NotifyEventTwo(GameLogic.TRUCO_CONTINUE_CHOOSE, {_type = 1})
		end
	elseif tag == 2 then --接受
		if self.m_isAnswerStatus == btn_Status.status_answer_truco then
		    G_event:NotifyEventTwo(GameLogic.TRUCO_ANSWER_TRUCO, {_type = 2})
		else
		    G_event:NotifyEventTwo(GameLogic.TRUCO_CONTINUE_CHOOSE, {_type = 2})
		end
	elseif tag == 3 then
		if self.m_isAnswerStatus == btn_Status.status_answer_truco then -- 加注/truco
		    G_event:NotifyEventTwo(GameLogic.TRUCO_ANSWER_TRUCO, {_type = 3})
		else
		    G_event:NotifyEventTwo(GameLogic.TRUCO_START_TRUCO, {_type = 1})
		end
	elseif tag == 4 then --亮牌
	    G_event:NotifyEventTwo(GameLogic.TRUCO_SHOW_CARD)
	else
		tlog("TrucoButtonNode: error tag")
	end
end

-- 情况一：我出牌的时候： 认输 -- Truco
-- 情况二：应答truco的时候： 认输 -- 接受 -- 加注
--刷新操作按钮显示
function TrucoButtonNode:resetButtonShow(_data)
	tlog('TrucoButtonNode:resetButtonShow')
	self:setNodeVisible(false)
	self:setTrucoBtnEnabled(true)
	if _data.CanShowCard then
		self.m_btnNode:getChildByName("Button_4"):setVisible(true)
		local times = GameLogic:getShowCardBtnTimes()
		if times and times > 0 then
			self.m_btnNode:runAction(cc.Sequence:create(cc.DelayTime:create(times), cc.CallFunc:create(function ()
				tlog("hide showcard btn delay")
				self:setNodeVisible(false)
			end)))
		end
	else
		local originPosX = -1 * Node_Distance
		tlog('originPosX is ', originPosX)
		local setBtnCall_1 = function (_btnName, _fileName)
			local btnNode = self.m_btnNode:getChildByName(_btnName):show()
			btnNode:setPositionX(originPosX)
			originPosX = originPosX + Node_Distance
			if _fileName then
				local image_1 = btnNode:getChildByName("Image_1")
				image_1:loadTexture(_fileName)
			    image_1:setContentSize(image_1:getVirtualRendererSize())
			end
		end
		if _data.CanWaitContinue then
			self.m_isAnswerStatus = btn_Status.status_continue
			if _data.CanGiveUpContinue then
				setBtnCall_1("Button_1")
			end
			setBtnCall_1("Button_2")
		else
			if _data.CanCorrer or _data.CanGiveUp then
				setBtnCall_1("Button_1")
			end
			tlog('originPosX is 111 ', originPosX)

			if _data.CanAceitar then
				setBtnCall_1("Button_2")
			end
			tlog('originPosX is 222 ', originPosX)

			if _data.CanTruco then
				setBtnCall_1("Button_3", string.format("GUI/truco_truco_%d.png", _data.nextCallScore))
			elseif _data.CanAumentar then
				self.m_isAnswerStatus = btn_Status.status_answer_truco
				setBtnCall_1("Button_3", string.format("GUI/truco_aumentar%d.png", _data.nextCallScore))
			else
				--不能truco也不能加注,也不能出牌，代表对方已经truco到12分了，这时候只能认输或者同意
				if not _data.CanOutCard then
					self.m_isAnswerStatus = btn_Status.status_answer_truco
				end
			end
		end
	end
end

--队友或自己应答truco或加注，按钮提示
--11分临界情况 队友或自己选择显示
function TrucoButtonNode:showTrucoAnswerOrContinueTips(_index, _chairId)
	local btnName = ""
	if _index == 1 then --认输
		btnName = "Button_1"
	elseif _index == 2 then --跟
		btnName = "Button_2"
	elseif _index == 3 then --加倍
		btnName = "Button_3"
	else
		tlog("no btn to show")
	end
	local imageName = ""
	if GameLogic:getPositionByChairId(_chairId) == 2 then --2是队友
		imageName = "Image_2"
	else
		imageName = "Image_3"
		self:setTrucoBtnEnabled(false)
	end
	tlog('TrucoButtonNode:showTrucoAnswerOrContinueTips ', imageName, btnName, _chairId)
	if btnName ~= "" then
		self.m_btnNode:getChildByName(btnName):getChildByName(imageName):setVisible(true)
	end
end

return TrucoButtonNode