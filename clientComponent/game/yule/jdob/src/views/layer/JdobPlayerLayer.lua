-- jdob 其他玩家层

local JdobPlayerLayer = class("JdobPlayerLayer", cc.Node)
local max_seat = 4
local HeadNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HeadNode")

function JdobPlayerLayer:ctor(_playerItem)
	tlog('JdobPlayerLayer:ctor')
	-- g_ExternalFun.registerNodeEvent(self)
    self.m_playerItem = _playerItem

    self.m_playerArray = {}
    self.m_playerX = {}
    
    for i = 1, max_seat do
    	local playerNode = self.m_playerItem:getChildByName(string.format("userNode_%d", i))
        local panel = playerNode:getChildByName("Panel_1")
        panel:setTouchEnabled(false)
        panel:setVisible(false)
    	table.insert(self.m_playerArray, panel)
        table.insert(self.m_playerX, panel:getPositionX())
        -- self:setShowPlayerInfo(playerNode)
    end
end

function JdobPlayerLayer:flushPlayerNodeShow(_userList, _playerChairIdList, _totalUpdate)
    tlog('JdobPlayerLayer:flushPlayerNodeShow')
    local _playerData = {}
    for i, v in ipairs(_playerChairIdList) do
        local data = {}
        if v == G_NetCmd.INVALID_CHAIR then
            data.wChairID = G_NetCmd.INVALID_CHAIR
        else
            data = clone(_userList[v + 1])
        end
        table.insert(_playerData, data)
    end
    for i, playerInfo in ipairs(_playerData) do
        local playerNode = self.m_playerArray[i]
        local curChairId = playerInfo.wChairID
        if curChairId ~= G_NetCmd.INVALID_CHAIR then
            playerNode:setVisible(true)
            --不同的玩家才更新名字和头像
            if (not playerNode._playerInfo) or playerNode._playerInfo.wChairID ~= curChairId or _totalUpdate then
                local text_name = playerNode:getChildByName("Image_namebg"):getChildByName("Text_name")
                text_name:setString(playerInfo.szNickName)
                --[[if playerInfo.szNickName == GlobalUserItem.szNickName then
                    playerNode:getChildByName("Image_selfIcon"):setVisible(true)
                    text_name:setTextColor(cc.c3b(0, 200, 0, 255))
                else
                    playerNode:getChildByName("Image_selfIcon"):setVisible(false)
                    text_name:setTextColor(cc.c3b(0, 62, 82, 255))
                end--]]
                --头像
                local node_head = playerNode:getChildByName("imgShade")
                local vipImage = playerNode:getChildByName("vipImage")
                local imgHead = node_head:getChildByName("imgHead")
                imgHead:removeAllChildren()
                local faceId = playerInfo.wFaceID
                local dwUserID = playerInfo.dwUserID
                local node = HeadNode:create(faceId)
                imgHead:addChild(node)
                node:setContentSize(cc.size(158,158))
                node:setBorderVisible(false)
                node:setTouched(false)
                node:setVipVisible(false)
                if dwUserID == GlobalUserItem.dwUserID then              --如果是自己
                    vipImage:loadTexture(string.format("client/res/VIP/GUI/%s.png",GlobalUserItem.VIPLevel),1)
                    vipImage:show()
                else
                    vipImage:hide()
                end

                -- local pPathHead = string.format("client/res/public/Face%d.jpg", faceId)
                -- local pPathClip = "GUI/jdob_head_clip.png"
                -- g_ExternalFun.ClipHead(imgHead, pPathHead, pPathClip)
                --更新财富值
                local serverKind = G_GameFrame:getServerKind()
                local str = g_format:formatNumber(playerInfo.lScore,g_format.fType.abbreviation,serverKind)
                playerNode:getChildByName("Text_money"):setString(str)
                playerNode._playerInfo = playerInfo
                local icon = playerNode:getChildByName("Text_money"):getChildByName("Image_jinbi")
                local currencyType = G_GameFrame:getServerKind()
                g_ExternalFun.setIcon(icon,currencyType)
                self:coinMoneyCenter(playerNode)
            end
        else
            playerNode:setVisible(false)
            playerNode._playerInfo = nil
        end
    end
end

--图标和金额居中
function JdobPlayerLayer:coinMoneyCenter(playerNode)
    local Text_money = playerNode:getChildByName("Text_money")
    local Image_jinbi = Text_money:getChildByName("Image_jinbi")
    local bgW = playerNode:getContentSize().width
    local w1 = Text_money:getContentSize().width
    local w2 = Image_jinbi:getContentSize().width
    local startx = bgW/2-(w1+w2)/2+w2
    Text_money:setPositionX(startx)
end
--更新金币显示,有人下注就用总额减去下注额
function JdobPlayerLayer:updatePlayerBetCoinShow(_chairId, _betScore)
    tlog('JdobPlayerLayer:updatePlayerBetCoinShow ', _chairId, _betScore)
    local chairIndex, playerNode = self:checkPlayerInSeat(_chairId)
    if chairIndex > 0 and chairIndex <= max_seat then
        local newScore = playerNode._playerInfo.lScore - _betScore
        local serverKind = G_GameFrame:getServerKind()
        local str = g_format:formatNumber(newScore,g_format.fType.abbreviation,serverKind)
        playerNode:getChildByName("Text_money"):setString(str)
        playerNode._playerInfo.lScore = newScore
        self:coinMoneyCenter(playerNode)
    end
end

--更新金币显示,游戏结算全部更新
-- _playerInfo 里只包含座位号和总金币
function JdobPlayerLayer:updatePlayerTotalCoinShow(_playerInfo)
    tlog('JdobPlayerLayer:updatePlayerTotalCoinShow ')
    local chairIndex, playerNode = self:checkPlayerInSeat(_playerInfo.chairId)
    if chairIndex > 0 and chairIndex <= max_seat then
        local serverKind = G_GameFrame:getServerKind()
        local str = g_format:formatNumber(_playerInfo.lScore,g_format.fType.abbreviation,serverKind)
        playerNode:getChildByName("Text_money"):setString(str)
        playerNode._playerInfo.lScore = _playerInfo.lScore
        self:coinMoneyCenter(playerNode)
    end
end

--玩家是否坐在左右位置上,在则返回座位index
function JdobPlayerLayer:checkPlayerInSeat(_chairId)
    for i, node in ipairs(self.m_playerArray) do
        local playerInfo = node._playerInfo
        if playerInfo then
            if playerInfo.wChairID == _chairId then
                return i, node
            end
        end
    end
    return 0, nil
end

--获取当前所有在座玩家
function JdobPlayerLayer:getAllSeatPlayerChairId()
    local playerArray = {}
    for i, node in ipairs(self.m_playerArray) do
        local playerInfo = node._playerInfo
        if playerInfo then
            table.insert(playerArray, playerInfo.wChairID)
        else
            table.insert(playerArray, G_NetCmd.INVALID_CHAIR)
        end
    end
    return playerArray
end

--下注播放玩家头像抖动
function JdobPlayerLayer:sharkPlayerHeadIcon(_playerIndex)
    if _playerIndex > 0 and _playerIndex <= max_seat then
        local playerNode = self.m_playerArray[_playerIndex]        
        local node_head = playerNode
        node_head:stopAllActions()
        node_head:setPositionX(self.m_playerX[_playerIndex])
        local moveLength = _playerIndex < 4 and 45 or -45
        local pAction1 = cc.MoveBy:create(0.1, cc.p(moveLength, 0))
        local pAction2 = cc.MoveBy:create(0.1, cc.p(-1 * moveLength, 0))
        node_head:runAction(cc.Sequence:create(pAction1, pAction2))
    end
end

return JdobPlayerLayer