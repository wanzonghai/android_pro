-- 免费提示界面

local BonanzaDialogBase = appdf.req("game.yule.bonanza.src.views.layer.BonanzaDialogBase")
local BonanzaFreeTipLayer = class("BonanzaFreeTipLayer", BonanzaDialogBase)
local GameLogic = appdf.req("game.yule.bonanza.src.models.GameLogic")

function BonanzaFreeTipLayer:ctor(_data)
    tlog('BonanzaFreeTipLayer:ctor')
    BonanzaFreeTipLayer.super.ctor(self, _data._color, _data._callBack)
	local csbNode = g_ExternalFun.loadCSB("UI/Node_FreeTip.csb", self, false)
	local nodeBegan = csbNode:getChildByName("Node_freeBegan")
	nodeBegan:setVisible(_data._isBegan)
	local nodeEnd = csbNode:getChildByName("Node_freeEnd")
	nodeEnd:setVisible(not _data._isBegan)
	tdump(_data, "_data", 10)
	if _data._isBegan then
		nodeBegan:getChildByName("AtlasLabel_num"):setString(_data._nums)
		g_ExternalFun.playSoundEffect("bonanza_free_begin.mp3")
	else
		g_ExternalFun.playSoundEffect("bonanza_free_end.mp3")
		local center_win_num = nodeEnd:getChildByName("center_win_num")
		center_win_num._lastNum = 0
		center_win_num._curNum = _data._winNums
		GameLogic:updateGoldShow(center_win_num)

		local image_1 = nodeEnd:getChildByName("Image_1")
		image_1:getChildByName("total_rate"):setString(_data._totalRate)
	    ccui.Helper:doLayout(image_1)

		local image_down_1 = nodeEnd:getChildByName("Image_down_1")
		image_down_1:getChildByName("free_times"):setString(_data._nums)
	    ccui.Helper:doLayout(image_down_1)
	end

	csbNode:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function ()
		self:removeNodeEvent()
	end)))

    local csbAnimation = cc.CSLoader:createTimeline("UI/Node_FreeTip.csb")
    csbAnimation:gotoFrameAndPlay(0, false)
    csbNode:runAction(csbAnimation)
end

return BonanzaFreeTipLayer