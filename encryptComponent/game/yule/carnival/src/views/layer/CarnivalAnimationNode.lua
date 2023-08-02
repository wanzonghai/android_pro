--嘉年华 播放动画层
local GameLogic = appdf.req("game.yule.carnival.src.models.GameLogic")
local CarnivalAnimationNode = class("CarnivalAnimationNode", cc.Node)

function CarnivalAnimationNode:ctor()
    tlog('CarnivalAnimationNode:ctor')
    g_ExternalFun.registerNodeEvent(self)
    self.m_isPlaying = false --是否正在播放获奖物品动画

    --bonus动画
    --只需要4个，第一列肯定不需要的
    self.m_bonusAction = {}
    local spineFile = "GUI/jnh_ani_spine/jnh_speed_ske"
    for i = 1, GameLogic.ITEM_X_COUNT - 1 do
        local posx = GameLogic.ITEM_WIDTH * (i + 0.5)
        local posy = GameLogic.TOTAL_HEIGHT * 0.5
        local aniNode = GameLogic:createAnimateShow(self, spineFile, "newAnimation", true, posx, posy, 1.44)
        aniNode:setVisible(false)
        aniNode:setName("AniNode")
        table.insert(self.m_bonusAction, aniNode)
    end
    self.m_bonusIndex = 0
end

function CarnivalAnimationNode:onExit()
    tlog('CarnivalAnimationNode:onExit')

end

function CarnivalAnimationNode:setAniNodeVisible(_bVisible)
	tlog('CarnivalAnimationNode:setAniNodeVisible ', _bVisible)
	self:setVisible(_bVisible)
	self:hideAllFastActNode()
	if _bVisible then
	else
		self.m_isPlaying = false
	    for i, v in ipairs(self:getChildren()) do
	        if v:getName() ~= "AniNode" then
	        	v:removeFromParent()
	        end
	    end
	end
end

--播放面具动画
function CarnivalAnimationNode:checkEnabledMasked(_itemInfo, _maskType, _callBack, _maskCall)
	tlog('CarnivalAnimationNode:checkEnabledMasked')
	self:setAniNodeVisible(true)
	self.m_isPlaying = true
	local isFirst = true
	local hasMaskType = false
	for i = 1, GameLogic.ITEM_X_COUNT do
		for j = 1, GameLogic.ITEM_Y_COUNT do
			local itemType = _itemInfo[j][i]
			if itemType == GameLogic.ITEM_LIST.ITEM_MYSTERY then
				--此时会隐藏图片，播放面具动画
				if not hasMaskType then
					--结果中有面具播放音效
		            g_ExternalFun.playSoundEffect("carnival_mystery_icon_win.mp3")
				end
				hasMaskType = true
				_maskCall({i, j}, _maskType)
				local spineFile, aniName = GameLogic:getAnimationName(itemType)
			    local posx, posy = GameLogic:getItemPosition(i, 5 - j)
			    local spineAnimation = GameLogic:createAnimateShow(self, spineFile, aniName, false, posx, posy, 1.3)
				spineAnimation:registerSpineEventHandler( function( event )
		            tlog("checkEnabledMasked animation is", event.animation)
		            local call = cc.CallFunc:create(function (t, p)
		            	t:removeFromParent()
			            if isFirst then
			            	isFirst = false
			            	_callBack()
			            end
		            end)
		            spineAnimation:runAction(cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.02), call))
		        end, sp.EventType.ANIMATION_COMPLETE)
			end
		end
	end
	if not hasMaskType then
		--没有面具
		tlog("not hasMaskType")
		_callBack()
	end
end

--播放物品动画
function CarnivalAnimationNode:playItemAnimation(_type, _posArr, _endCall)
    tlog("CarnivalScrollLayer:playItemAnimation ", _posArr[1], _posArr[2], _type)
    local posx, posy = GameLogic:getItemPosition(_posArr[1], _posArr[2])
	local spineFile, aniName = GameLogic:getAnimationName(_type)
	if _type >= GameLogic.ITEM_LIST.ITEM_ICON6 then
		GameLogic:createAnimateShow(self, spineFile, aniName, true, posx, posy, 1.3)
	end

	spineFile = "GUI/jnh_ani_spine/jnh_win_glow_ske"
    local broadAnimation = GameLogic:createAnimateShow(self, spineFile, "newAnimation", true, posx, posy, 1.3)
    if self.m_isPlaying then
    	self.m_isPlaying = false
		broadAnimation:registerSpineEventHandler( function( event )
	        -- tlog("event.animation is", event.animation)
	        if not self.m_isPlaying then
	        	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(_endCall)))
	        	--直接使用会在onGetGameScore处涉及到回调和网络消息的时候会崩掉
	        	-- _endCall()
	        	self.m_isPlaying = true
	        end
	    end, sp.EventType.ANIMATION_COMPLETE)
	end
end

function CarnivalAnimationNode:setBonusIndexValue(_index)
	self.m_bonusIndex = _index
end

--每一列停止的回调
function CarnivalAnimationNode:playFastActNode(_index)
    tlog("CarnivalAnimationNode:playFastActNode ", _index)
	self:setAniNodeVisible(true)
	--是否开启下一列的bonus动画
    if self.m_bonusIndex ~= 0 and _index + 1 >= self.m_bonusIndex and _index < GameLogic.ITEM_X_COUNT then
    -- if _index >= 1 and _index < GameLogic.ITEM_X_COUNT then
        local actNode = self.m_bonusAction[_index]
        actNode:setVisible(true)
        return true
    end
    return false
end

function CarnivalAnimationNode:hideAllFastActNode()
    for i, v in ipairs(self.m_bonusAction) do
        v:setVisible(false)
    end
end

return CarnivalAnimationNode