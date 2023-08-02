-- 免费提示界面

local CarnivalDialogBase = appdf.req("game.yule.carnival.src.views.layer.CarnivalDialogBase")
local CarnivalFreeTipLayer = class("CarnivalFreeTipLayer", CarnivalDialogBase)
local GameLogic = appdf.req("game.yule.carnival.src.models.GameLogic")

--[[
	_data =
	{
		_showType = 1表示首次免费，2表示免费中免费，3表示免费结束
		_nums = 次数或者金额数
	}
]]
function CarnivalFreeTipLayer:ctor(_data)
    tdump(_data, 'CarnivalFreeTipLayer:ctor', 10)
    CarnivalFreeTipLayer.super.ctor(self)
	local csbNode = g_ExternalFun.loadCSB("UI/CarnivalFreeTipNode.csb", self, false)
	local freeNums = csbNode:getChildByName("freeNums")
	freeNums:setVisible(false)
	local freeTotal = csbNode:getChildByName("freeTotal")
	freeTotal:setVisible(false)
	local spineNode = csbNode:getChildByName("Node_spine")
	if _data._showType ~= 3 then
		freeNums:setVisible(true)
		freeNums:setString(_data._nums)
		local spineFile = "GUI/jnh_ani_spine/jnh_fg_tip_ske"
		local aniName = "tip"
		local posY = -230
		if _data._showType == 2 then
			aniName = "again"
			posY = -180
		end
		freeNums:setPositionY(299 + posY) --230+69
	    local animation = GameLogic:createAnimateShow(spineNode, spineFile, aniName, false, 0, posY)
	    local delay = cc.DelayTime:create(3.0)
	    local delay1 = cc.DelayTime:create(0.6)
	    local call = cc.CallFunc:create(function (t, p)
	    	if p.call then
	    		p.call()
	    	end
	    	self:removeFromParent()
	    end, {call = _data._callBack})
	    freeNums:runAction(cc.Sequence:create(delay, cc.Hide:create(), delay1, call))
	else
		local spineFile = "GUI/jnh_ani_spine/jnh_total_ske"
		local aniName = "appear"
	    local animation = GameLogic:createAnimateShow(spineNode, spineFile, aniName, false, 0, -150)
	    animation:registerSpineEventHandler( function( event )
	        tlog("CarnivalFreeTipLayer animation is", event.animation)
	        if event.animation == "appear" then
	        	animation:setAnimation( 0, "idle", true)

	        	freeTotal:setScale(1.44)
    			freeTotal:setVisible(true)
				freeTotal._lastNum = 0
				freeTotal._curNum = _data._nums
				GameLogic:updateGoldShow(freeTotal)
	        end
	    end, sp.EventType.ANIMATION_COMPLETE)
	    local delay = cc.DelayTime:create(5.0)
	    local call = cc.CallFunc:create(function (t, p)
	    	if p.call then
	    		p.call()
	    	end
	    	self:removeFromParent()
	    end, {call = _data._callBack})
	    csbNode:runAction(cc.Sequence:create(delay, call))
	end
end

function CarnivalFreeTipLayer:removeNodeEvent()
	
end

return CarnivalFreeTipLayer