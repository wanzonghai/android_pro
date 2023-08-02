-- 大奖提示界面

local BonanzaDialogBase = appdf.req("game.yule.bonanza.src.views.layer.BonanzaDialogBase")
local BonanzaRewardTipNode = class("BonanzaRewardTipNode", BonanzaDialogBase)
local GameLogic = appdf.req("game.yule.bonanza.src.models.GameLogic")

function BonanzaRewardTipNode:ctor(_data)
    tlog('BonanzaRewardTipNode:ctor')
    _data = _data or {}
    BonanzaRewardTipNode.super.ctor(self, _data._color, _data._callBack)

    self.m_showIndex = 0
    self.m_csbArray = {}
    local skinTb = {"nice", "meganice", "sensation"}
    for i = 1, 3 do
	    local csbNode = cc.CSLoader:createNode(string.format("UI/Node_jiesuan%d.csb", i))
    	csbNode:setVisible(false)
    	csbNode:addTo(self)
    	table.insert(self.m_csbArray, csbNode)
    	--结算spine动画
    	local spinePath = "spine/gongxihuode1"
		local spineAnim = sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
	    spineAnim:setAnimation(0, "ruchang", false)
	    spineAnim:setSkin(skinTb[i])
	    spineAnim:setPosition(0,0)
	    spineAnim:addTo(csbNode:getChildByName("spine_bg"), 0, 1)
	    spineAnim:registerSpineEventHandler( function( event )
	    	if event.type == "complete" then
		        if event.animation == "ruchang" then
		            spineAnim:setAnimation( 0, "daiji", true) 
		        end
		    end
	    end, sp.EventType.ANIMATION_COMPLETE)--sp.EventType.ANIMATION_EVENT )
    end
end

function BonanzaRewardTipNode:showRewardTip(_data)
	tlog('BonanzaRewardTipNode:showRewardTip')
    self:setSelfVisible(true)

    self.m_callBack = _data._callBack
    local showIndex = 1
    if _data.rateNum >= GameLogic.Reward_Scope.big then
    	showIndex = 3
    elseif _data.rateNum >= GameLogic.Reward_Scope.middle then
    	showIndex = 2
    end
    self.m_showIndex = showIndex
	local csbNode = self.m_csbArray[showIndex]
	csbNode:setVisible(true)
    local csbAnimation = cc.CSLoader:createTimeline(string.format("UI/Node_jiesuan%d.csb", showIndex))
    csbAnimation:gotoFrameAndPlay(0, false)
    csbNode:runAction(csbAnimation)

    for k, v in pairs(csbNode:getChildren()) do
        if iskindof(v, "cc.ParticleSystemQuad") then
            v:resetSystem()
        end
    end

	local center_win_num = csbNode:getChildByName("Image_6_0"):getChildByName("AtlasLabel_1")
	center_win_num._lastNum = 0
	center_win_num._curNum = _data.rewardNum
	GameLogic:updateGoldShow(center_win_num)

	local spineAnim = csbNode:getChildByName("spine_bg"):getChildByTag(1)
	spineAnim:setAnimation(0, "ruchang", false)

	csbNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function ()
		self:removeNodeEvent()
	end)))
end

function BonanzaRewardTipNode:setSelfVisible(_bVisible)
	tlog('BonanzaRewardTipNode:setSelfVisible ', _bVisible)
	self:setVisible(_bVisible)
	if self.listener then
		self.listener:setSwallowTouches(_bVisible)
	end
	self:setTouchRetEnabled(_bVisible)
end

function BonanzaRewardTipNode:removeNodeEvent()
	tlog('BonanzaRewardTipNode:removeNodeEvent')
	if self.m_callBack then
		self.m_callBack()
	end
	if self.m_showIndex >= 1 and self.m_showIndex <= 3 then
		self.m_csbArray[self.m_showIndex]:setVisible(false)
	end

    self:setSelfVisible(false)
end

return BonanzaRewardTipNode