-- 大奖提示界面

local CarnivalDialogBase = appdf.req("game.yule.carnival.src.views.layer.CarnivalDialogBase")
local CarnivalRewardTipNode = class("CarnivalRewardTipNode", CarnivalDialogBase)
local GameLogic = appdf.req("game.yule.carnival.src.models.GameLogic")

--[[
	_data =
	{
		_rateNum = 倍率
		_nums = 金额数
	}
]]
function CarnivalRewardTipNode:ctor(_data)
    tlog('CarnivalRewardTipNode:ctor')
    CarnivalRewardTipNode.super.ctor(self, nil, nil, _data._callBack)
	local csbNode = g_ExternalFun.loadCSB("UI/CarnivalRewardTipNode.csb", self, false)

    local spineNode = csbNode:getChildByName("Node_spine")
    local win_num = csbNode:getChildByName("win_num"):hide()
    win_num:setPositionY(-200)
    win_num:setScale(1.2)
    local totalTimes = 7 --比start动画多一秒
    local runTimes = 150 --数字跑动次数
    local aniNamePrefix = "bigwin"
    if _data._rateNum >= GameLogic.Reward_Scope.big then
    	aniNamePrefix = "megawin"
        totalTimes = 11
        runTimes = 240
    elseif _data._rateNum >= GameLogic.Reward_Scope.middle then
    	aniNamePrefix = "superwin"
        totalTimes = 9
        runTimes = 200
    end
	local spineFile = "GUI/jnh_ani_spine/slots_bigwin_ske"
	local aniName = string.format("%s_start", aniNamePrefix)
    local animation = GameLogic:createAnimateShow(spineNode, spineFile, aniName, false, 0, 0)
    animation:registerSpineEventHandler( function( event )
        tlog("CarnivalRewardTipNode animation is", event.animation)
        if event.animation == aniName then
        	animation:setAnimation( 0, string.format("%s_idle", aniNamePrefix), true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    local delay = cc.DelayTime:create(0.5)
    local call = cc.CallFunc:create(function (t, p)
		win_num:setVisible(true)
		win_num._lastNum = 0
		win_num._curNum = p.num
		GameLogic:updateGoldShow(win_num, p.num / p.runTimes)
	end, {num = _data._nums, runTimes = runTimes})
    local delay1 = cc.DelayTime:create(totalTimes)
    local call1 = cc.CallFunc:create(function (t, p)
    	-- if self.m_callBack then
    	-- 	self.m_callBack()
    	-- end
    	-- self:removeFromParent()
    	self:removeNodeEvent()
    end)
    csbNode:runAction(cc.Sequence:create(delay, call, delay1, call1))
end

-- function CarnivalRewardTipNode:removeNodeEvent()
	
-- end

return CarnivalRewardTipNode