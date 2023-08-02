-- 玩家下注前10位界面显示

local GameDialogBase = appdf.req("game.yule.double.src.views.layer.GameDialogBase")
local GamePlayerBetView = class("GamePlayerBetView", GameDialogBase)

function GamePlayerBetView:ctor(_betArea, _playerScoreInfo)
    tlog('GamePlayerBetView:ctor ', _betArea)
    GamePlayerBetView.super.ctor(self)

	self.m_playerScoreInfo = _playerScoreInfo

	local csbNode = g_ExternalFun.loadCSB("UI/GameBetShowLayer.csb", self, false)
	self.m_spBg = csbNode:getChildByName("Sprite_bg")
	--关闭按钮
	local btn = self.m_spBg:getChildByName("Button_1")
	btn:addClickEventListener(function ()
		self:removeFromParent()
	end)

    local multis = _betArea == 2 and 14 or 2
    tlog("multis is ", multis)
    local topBg = self.m_spBg:getChildByName("Image_top_bg")
    topBg:getChildByName("Text_1"):setString(string.format("Win %dX", multis))
    local fileNameArr = {"blaze_item_2.png", "blaze_item_1.png", "blaze_item_3.png"}
    topBg:getChildByName("Image_1"):loadTexture("GUI/" .. fileNameArr[_betArea])
    self:initView()
end

function GamePlayerBetView:initView()
    local curPanel = self.m_spBg:getChildByName("Panel_1")
    --根据总玩家数量显示
    local length = #self.m_playerScoreInfo
    local totalLine = math.floor((length - 1) / 2) + 1
    for i = 1, 5 do
        curPanel:getChildByName(string.format("Panel_item_%d", i)):setVisible(i <= totalLine)
    end
    local isOddNumber = (length % 2) == 1 --总长度是否奇数
    for i, v in ipairs(self.m_playerScoreInfo) do
        local curIndex = math.floor((i - 1) / 2) + 1    --第几行
        local lineIndex = ((i - 1) % 2) + 1             --1是左边，2是右边
        local panel_item = curPanel:getChildByName(string.format("Panel_item_%d", curIndex))
        local text_name = panel_item:getChildByName(string.format("Text_name_%d", lineIndex))
        if v.userName == GlobalUserItem.szNickName then
            text_name:setTextColor(cc.c4b(0, 200, 0, 255))
        end
        local formatName, isShow = g_ExternalFun.GetFixLenOfString(v.userName, 215, "arial", 40)
        if formatName == nil then
            formatName = ""
        end
        text_name:setString(isShow and formatName or (formatName .. "..."))

        local text_money = panel_item:getChildByName(string.format("Text_money_%d", lineIndex))
        if v.betScore > 9999999 then
            local serverKind = G_GameFrame:getServerKind()
            text_money:setString(g_format:formatNumber(v.betScore,g_format.fType.abbreviation,serverKind))
        else
            local serverKind = G_GameFrame:getServerKind()
            text_money:setString(g_format:formatNumber(v.betScore,g_format.fType.standard,serverKind))
        end
        if curIndex == totalLine and isOddNumber then
            panel_item:getChildByName("Text_name_2"):setVisible(false)
            panel_item:getChildByName("Text_money_2"):setVisible(false)
            panel_item:getChildByName("Image_icon_2"):setVisible(false)
            panel_item:getChildByName("Image_line_1"):setVisible(false)
        end
    end
end

return GamePlayerBetView