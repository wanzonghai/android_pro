--truco互动表情界面
local TrucoHuDongLayer = class("TrucoHuDongLayer", function(args)
    local TrucoHuDongLayer =  display.newLayer()
    return TrucoHuDongLayer
end)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")

function TrucoHuDongLayer:ctor(para)
    tlog('TrucoHuDongLayer:ctor')
    --TrucoHuDongLayer.super.ctor(self)

    self.tabIndex = 1
    self.playerInfo = para or {}
    tdump(self.playerInfo, 'TrucoHuDongLayer:ctor222', 9)

    local bgLayer = display.newLayer()
    bgLayer:addTo(self)
    bgLayer:enableClick(function()
        self:removeFromParent()
    end)

	local csbNode = g_ExternalFun.loadCSB("UI/TrucoHuDongLayer.csb", self, false)
	self.m_csbNode = csbNode
	local posTb = {cc.p(display.width/2-160,400), cc.p(display.width/2+290,700), cc.p(display.width/2-360,700), cc.p(display.width/2-310,700)}
	local pos_index = GameLogic:getPositionByChairId(self.playerInfo.wChairID) + 1
	csbNode:setPosition(posTb[pos_index])

	local Panel_1 = csbNode:getChildByName("Panel_1")
	self.m_spBg = Panel_1:getChildByName("sp_bg")
	self.m_spBg:enableClick()
	
    self.Panel_user = Panel_1:getChildByName("Panel_user")
    self.Panel_hudong = Panel_1:getChildByName("Panel_hudong")

	--互动表情(301-400)
	self.hudongcd = {}
	for i=1,10 do
		self.hudongcd[i] = {}
	    self.hudongcd[i].clickStamp = 0
	    self.hudongcd[i].cd = 5

		local btn_hudong = self.Panel_hudong:getChildByName("btn_hudong"..i)
		btn_hudong:addClickEventListener(function ()
			local curStamp = socket.gettime()
			if curStamp > self.hudongcd[i].clickStamp + self.hudongcd[i].cd then
				G_GameFrame:sendBrowChat( 300+i, self.playerInfo.dwUserID )
				self.hudongcd[i].clickStamp = curStamp
				self:removeFromParent()
			end
		end)
		--进度条
		local Panel_Progress = btn_hudong:getChildByName("Panel_Progress")
		local size = Panel_Progress:getContentSize()
		local progress = cc.ProgressTimer:create(display.newSprite("GUI/expression/Touco_biaoqing_hudong_jindu.png"))
	    progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	    progress:setPosition(size.width * 0.5, size.height * 0.5)
	    progress:addTo(Panel_Progress, 1, 1)
	    --progress:setReverseDirection(true)
	    progress:setPercentage(100)
	end

	self:updatePlayerInfo()
	self:updateExpressionCost()

	--每帧更新
	self:onUpdate(function(dt) self:updateCd(dt) end)
end

--刷新当前标签页
function TrucoHuDongLayer:updatePlayerInfo()
	self.Panel_user:getChildByName("Text_id"):setString(self.playerInfo.dwUserID)
	self.Panel_user:getChildByName("Text_name"):setString(self.playerInfo.szNickName)
    local imgShade = self.Panel_user:getChildByName("imgShade")
    --头像
    local imgHead = imgShade:getChildByName("imgHead")
    imgHead:removeAllChildren()
    local faceId = self.playerInfo.wFaceID
    local pPathHead = string.format("client/res/public/Face%d.jpg", faceId)
    -- local pPathClip = "client/res/public/clip.png"
    local pPathClip = "GUI/truco_head_clip.png"
    g_ExternalFun.ClipHead(imgHead, pPathHead, pPathClip)

    --更新财富值
	local serverKind = G_GameFrame:getServerKind()
	local str = g_format:formatNumber(self.playerInfo.lScore,g_format.fType.abbreviation,serverKind)
	self.Panel_user:getChildByName("Text_money"):setString(str)

	local iconIndex = GameLogic:getIconIndexByChairId(self.playerInfo.wChairID)
	imgShade:loadTexture(string.format("GUI/truco_head_bg_%d.png", iconIndex))
	imgShade:getChildByName("Image_broad"):loadTexture(string.format("GUI/truco_head_broad_%d.png", iconIndex))
end

--获取互动表情价格
function TrucoHuDongLayer:getCostNumByIndex(index)
	local costNum = 0
	for i=1,#GlobalUserItem.expressionCost do
		if index == GlobalUserItem.expressionCost[i].index then
			costNum = GlobalUserItem.expressionCost[i].costNum
			break
		end
	end
	return costNum
end
--刷新互动表情价格
function TrucoHuDongLayer:updateExpressionCost()
	for i=1,10 do
		local btn_hudong = self.Panel_hudong:getChildByName("btn_hudong"..i)
		--进度条
		local Text_price = btn_hudong:getChildByName("Text_price")
		local costNum = self:getCostNumByIndex(i)
		Text_price:setString(costNum)
		if costNum > 0 then
			Text_price:setVisible(true)
			btn_hudong:getChildByName("Image_coin"):setVisible(true)
		else
			Text_price:setVisible(false)
			btn_hudong:getChildByName("Image_coin"):setVisible(false)
		end
	end
end
--每帧更新
function TrucoHuDongLayer:updateCd(dt)
	local curStamp = socket.gettime()
	for i=1,10 do
		local passtime = curStamp - self.hudongcd[i].clickStamp
		local percent = passtime/self.hudongcd[i].cd*100
		if percent > 100 then
			percent = 100
		end
		local btn_hudong = self.Panel_hudong:getChildByName("btn_hudong"..i)
		local Panel_Progress = btn_hudong:getChildByName("Panel_Progress")
		local progress = Panel_Progress:getChildByTag(1)
		progress:setPercentage(percent)
	end
end

return TrucoHuDongLayer