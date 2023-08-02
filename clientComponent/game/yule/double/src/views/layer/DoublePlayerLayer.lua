-- double 玩家层

local DoublePlayerLayer = class("DoublePlayerLayer", cc.Node)
local max_seat = 6
local HeadNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HeadNode")

function DoublePlayerLayer:ctor(_playerItem)
	tlog('DoublePlayerLayer:ctor')
	-- g_ExternalFun.registerNodeEvent(self)
    self.m_playerItem = _playerItem

    --记录四个头像节点的初始位置pos, 庄家标识位置pePos, 玩家节点player,闪光特效节点 aniNode
    self.m_playerArray = {}
    
    for i = 1, max_seat do
    	local playerNode = self.m_playerItem:getChildByName(string.format("playerNode_%d", i))
        local panel = playerNode:getChildByName("Panel_1")
        panel:setTouchEnabled(false)
        panel:setVisible(false)
    	table.insert(self.m_playerArray, panel)
        -- self:setShowPlayerInfo(playerNode)
    end
end

function DoublePlayerLayer:flushPlayerNodeShow(_userList, _playerChairIdList, _totalUpdate)
    tlog('DoublePlayerLayer:flushPlayerNodeShow')
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
                local text_name = playerNode:getChildByName("Text_name")
                text_name:setString(playerInfo.szNickName)
                if playerInfo.szNickName == GlobalUserItem.szNickName then
                    playerNode:getChildByName("Image_selfIcon"):setVisible(true)
                    text_name:setTextColor(cc.c3b(0, 200, 0, 255))
                else
                    playerNode:getChildByName("Image_selfIcon"):setVisible(false)
                    text_name:setTextColor(cc.c3b(0, 62, 82, 255))
                end
                --头像
                local node_head = playerNode:getChildByName("Node_1")
                local imgHead = node_head:getChildByName("imgHead")
                imgHead:removeAllChildren()
                local faceId = playerInfo.wFaceID
                
                local head = HeadNode:create(faceId)
                imgHead:addChild(head)
                head:loadBorderTexture("GUI/double_tx1_bg.png")
                if playerInfo.dwUserID == GlobalUserItem.dwUserID then          --如果是自己头像
                    head:loadVipTextureByVipValue(GlobalUserItem.VIPLevel)
                else
                    head:setVipVisible(false)
                end
                -- local pPathHead = string.format("client/res/public/Face%d.jpg", faceId)
                -- local pPathClip = "GUI/double_yx_bg.png"
                -- g_ExternalFun.ClipHead(imgHead, pPathHead, pPathClip)

                --更新财富值
                local serverKind = G_GameFrame:getServerKind()
                local str = g_format:formatNumber(playerInfo.lScore,g_format.fType.abbreviation,serverKind)
                playerNode:getChildByName("Text_money"):setString(str)
                playerNode._playerInfo = playerInfo
                node_head:setPosition(75, 210)
                local icon = playerNode:getChildByName("Image_jinbi")
                local currencyType = G_GameFrame:getServerKind()
                g_ExternalFun.setIcon(icon,currencyType)
            end
        else
            playerNode:setVisible(false)
            playerNode._playerInfo = nil
        end
    end
end

--更新金币显示,有人下注就用总额减去下注额
function DoublePlayerLayer:updatePlayerBetCoinShow(_chairId, _betScore)
    tlog('DoublePlayerLayer:updatePlayerBetCoinShow ', _chairId, _betScore)
    local chairIndex, playerNode = self:checkPlayerInSeat(_chairId)
    if chairIndex > 0 and chairIndex <= max_seat then
        local newScore = playerNode._playerInfo.lScore - _betScore
        local serverKind = G_GameFrame:getServerKind()
        local str = g_format:formatNumber(newScore,g_format.fType.abbreviation,serverKind)
        playerNode:getChildByName("Text_money"):setString(str)
        playerNode._playerInfo.lScore = newScore
    end
end

--更新金币显示,游戏结算全部更新
-- _playerInfo 里只包含座位号和总金币
function DoublePlayerLayer:updatePlayerTotalCoinShow(_playerInfo)
    tlog('DoublePlayerLayer:updatePlayerTotalCoinShow ')
    local chairIndex, playerNode = self:checkPlayerInSeat(_playerInfo.chairId)
    if chairIndex > 0 and chairIndex <= max_seat then
        local serverKind = G_GameFrame:getServerKind()
        local str = g_format:formatNumber(_playerInfo.lScore,g_format.fType.abbreviation,serverKind)
        playerNode:getChildByName("Text_money"):setString(str)
        playerNode._playerInfo.lScore = _playerInfo.lScore
    end
end

--玩家是否坐在左右位置上,在则返回座位index
function DoublePlayerLayer:checkPlayerInSeat(_chairId)
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
function DoublePlayerLayer:getAllSeatPlayerChairId()
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
function DoublePlayerLayer:sharkPlayerHeadIcon(_playerIndex)
    if _playerIndex > 0 and _playerIndex <= max_seat then
        local playerNode = self.m_playerArray[_playerIndex]        
        local node_head = playerNode:getChildByName("Node_1")
        node_head:stopAllActions()
        node_head:setPosition(cc.p(75,210))
        local moveLength = _playerIndex < 4 and 45 or -45
        local pAction1 = cc.MoveBy:create(0.1, cc.p(moveLength, 0))
        local pAction2 = cc.MoveBy:create(0.1, cc.p(-1 * moveLength, 0))
        node_head:runAction(cc.Sequence:create(pAction1, pAction2))
    end
end

return DoublePlayerLayer