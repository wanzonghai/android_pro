-- truco，加注等对话框展示层

local TrucoBubbleLayer = class("TrucoBubbleLayer", cc.Node)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")

function TrucoBubbleLayer:ctor()
    tlog('TrucoBubbleLayer:ctor')
    local csbNode = cc.CSLoader:createNode("UI/TrucoBubbleLayer.csb")
    csbNode:addTo(self)
    self.m_csbNode = csbNode
    self:setBubbleNodeVisible(false)
end

function TrucoBubbleLayer:setBubbleNodeVisible(_bVisible)
    tlog("TrucoBubbleLayer:setBubbleNodeVisible ", _bVisible)
    for i = 1, 4 do
    	local bubble = self.m_csbNode:getChildByName(string.format("Bubble_%d", i))
        bubble:stopAllActions()
    	bubble:setVisible(_bVisible)
    end
end

--获取展示tip结构字段
-- _type 1为truco，2为放弃，3为接受，4为加注,5为...
function TrucoBubbleLayer:getTipData(_chairId, _showWait, _picPath, _type)
    tlog("TrucoBubbleLayer:getTipData ", _chairId, _showWait, _picPath)
	local tip_data = {}
	tip_data._chairId = _chairId
	tip_data.showWait = _showWait
	tip_data.picPath = _picPath
    tip_data._type = _type
	return tip_data
end

--truco响应
function TrucoBubbleLayer:showBubbleTrucoTips(_chairId, _trucoScore)
    tlog("TrucoBubbleLayer:showBubbleTrucoTips ", _chairId, _trucoScore)
	--自身truco
	local chair_data = self:getTipData(_chairId, false, string.format("GUI/truco_bubble_truco_%d.png", _trucoScore), 1)
    self:playBubbleTipAction(chair_data)
    self:otherSideWaitTip(_chairId)
end

--对家两个 ... 提示
function TrucoBubbleLayer:otherSideWaitTip(_chairId)
    local aniArray = {}
    --对家两个 ... 提示
    local next_chair_1 = GameLogic:getOtherPlayerChairId(_chairId, 1)
    table.insert(aniArray, self:getTipData(next_chair_1, true, "", 5))

    local next_chair_2 = GameLogic:getOtherPlayerChairId(_chairId, 3)
    table.insert(aniArray, self:getTipData(next_chair_2, true, "", 5))

    for i, v in ipairs(aniArray) do
        self:playBubbleTipAction(v)
    end
end

--认输气泡
function TrucoBubbleLayer:showBubbleGiveUpTips(_chairId)
    tlog('TrucoBubbleLayer:showBubbleGiveUpTips ', _chairId)
    local chair_data = self:getTipData(_chairId, false, "GUI/truco_bubble_giveup.png", 2)
    self:playBubbleTipAction(chair_data)
end

--应答truco气泡
function TrucoBubbleLayer:showBubbleAnswerTrucoTips(_cmdData)
	local _chairId = _cmdData.chairID
	local trucoScore = math.max(_cmdData.TrucoScore, _cmdData.TeamTrucoScore) --选我和队友操作优先级大的那个
	local currentTrucoScore = _cmdData.CurrentTrucoScore
    tlog('TrucoBubbleLayer:showBubbleAnswerTrucoTips ', _chairId, trucoScore, currentTrucoScore)
	local picPath = ""
	--1放弃  2跟  3加倍
	if trucoScore == 1 then
		picPath = "GUI/truco_bubble_giveup.png"
	elseif trucoScore == 2 then
		picPath = "GUI/truco_bubble_accept.png"
	elseif trucoScore == 3 then
		picPath = string.format("GUI/truco_bubble_au_%d.png", currentTrucoScore)
	end
    local aniArray = {}
    table.insert(aniArray, self:getTipData(_chairId, false, picPath, trucoScore + 1))

    local next_chair_1 = GameLogic:getOtherPlayerChairId(_chairId, 2)
    table.insert(aniArray, self:getTipData(next_chair_1, false, picPath, trucoScore + 1))
    for i, v in ipairs(aniArray) do
    	self:playBubbleTipAction(v)
    end
end

--tip动画
function TrucoBubbleLayer:playBubbleTipAction(_data)
	local pos_index = GameLogic:getPositionByChairId(_data._chairId)
	local new_index = (pos_index % 3) + 1
	local aniPath = string.format("UI/TrucoBubbleNode_%d.csb", new_index)
    tlog("TrucoBubbleLayer:playBubbleTipAction ", pos_index, new_index)
	local bubbleNode = self.m_csbNode:getChildByName(string.format("Bubble_%d", pos_index + 1))
	bubbleNode:setVisible(true)
	bubbleNode:stopAllActions()

    local image_1 = bubbleNode:getChildByName("Image_1")
    image_1:getChildByName("Node_1_0"):setVisible(_data.showWait) 	-- ...动画
    local node_1 = image_1:getChildByName("Node_1")					--字提示
    node_1:setVisible(not _data.showWait)
    if not _data.showWait then
        local node_pic_1 = node_1:getChildByName("AUMENTARP12_3")
        local node_pic_2 = node_1:getChildByName("AUMENTARP12_3_0")
	    node_pic_1:setTexture(_data.picPath)
	    node_pic_2:setTexture(_data.picPath)
        if _data._type == 4 then
            node_pic_1:setPositionY(-8)
            node_pic_2:setPositionY(-8)
        else
            node_pic_1:setPositionY(0)
            node_pic_2:setPositionY(0)
        end
	end
    local actTimeLine1 = cc.CSLoader:createTimeline(aniPath)
    actTimeLine1:gotoFrameAndPlay(0, 45, false)
    bubbleNode:runAction(actTimeLine1)
    actTimeLine1:setLastFrameCallFunc(function()
	    bubbleNode:stopAllActions()
        local actTimeLine2 = cc.CSLoader:createTimeline(aniPath)
	    actTimeLine2:play("animation0", true)
	    bubbleNode:runAction(actTimeLine2)
    end)
end

--11分临界选择气泡
function TrucoBubbleLayer:showBubbleContinueTips(_cmdData)
    local _chairId = _cmdData.chairID
    local continueScore = math.max(_cmdData.ContinueGameStatus, _cmdData.FriendContinueGameStatus) --选我和队友操作优先级大的那个
    tlog('TrucoBubbleLayer:showBubbleContinueTips ', _chairId, continueScore)
    local picPath = ""
    --1放弃  2继续
    if continueScore == 1 then
        picPath = "GUI/truco_bubble_giveup.png"
    elseif continueScore == 2 then
        picPath = "GUI/truco_bubble_accept.png"
    end
    local aniArray = {}
    table.insert(aniArray, self:getTipData(_chairId, false, picPath, continueScore + 1))

    local next_chair_1 = GameLogic:getOtherPlayerChairId(_chairId, 2)
    table.insert(aniArray, self:getTipData(next_chair_1, false, picPath, continueScore + 1))
    for i, v in ipairs(aniArray) do
        self:playBubbleTipAction(v)
    end
end

--重连回来展示气泡(如果有的话)
function TrucoBubbleLayer:showEnterBubbleTips(_cmdData, _callBack)
    --叫truco的id和队友id
    local firstTrucoId = _cmdData.TrucoChairID
    local teamId = GameLogic:getOtherPlayerChairId(firstTrucoId, 2)
    --truco对家的id
    local other_id_1 = GameLogic:getOtherPlayerChairId(firstTrucoId, 1)
    local other_id_2 = GameLogic:getOtherPlayerChairId(firstTrucoId, 3)
    tlog('TrucoBubbleLayer:showEnterBubbleTips ', firstTrucoId, teamId, other_id_1, other_id_2)
    local answerStatus = _cmdData.AnswerTrucoAct[1]
    local answerScore = _cmdData.AnswerTrucoScore[1]
    local btnCallFun = function (_chairId_1, _chairId_2)
        tlog("showEnterBubbleTips btnCallFun ", _chairId_1, _chairId_2)
        if GameLogic:getIsSameTeamWithMe(_chairId_1) then
            if answerStatus[_chairId_1 + 1] ~= 0 then
                if _callBack then
                    _callBack(answerStatus[_chairId_1 + 1], _chairId_1)
                end
            elseif answerStatus[_chairId_2 + 1] ~= 0 then
                if _callBack then
                    _callBack(answerStatus[_chairId_2 + 1], _chairId_2)
                end
            end
        end
    end
    --叫truco的已经到了应答阶段，truco气泡就不展示了
    if answerStatus[firstTrucoId + 1] ~= 0 or answerStatus[teamId + 1] ~= 0 then
        if answerStatus[firstTrucoId + 1] ~= 0 and answerStatus[teamId + 1] ~= 0 then --truco方应答完毕
            tlog("here show 1")
            --truco方展示应答气泡
            local data = {}
            data.chairID = firstTrucoId
            data.TrucoScore = answerStatus[firstTrucoId + 1]
            data.TeamTrucoScore = answerStatus[teamId + 1]
            data.CurrentTrucoScore = math.max(answerScore[firstTrucoId + 1], answerScore[teamId + 1])
            self:showBubbleAnswerTrucoTips(data)
            --truco的对家展示...
            self:otherSideWaitTip(firstTrucoId)
            btnCallFun(other_id_1, other_id_2)
        else --truco方未应答完毕
            --truco方展示...
            tlog("here show 2")
            self:otherSideWaitTip(other_id_1)
            btnCallFun(firstTrucoId, teamId)
            --truco的对家展示应答气泡
            local data = {}
            data.chairID = other_id_1
            data.TrucoScore = answerStatus[other_id_1 + 1]
            data.TeamTrucoScore = answerStatus[other_id_2 + 1]
            data.CurrentTrucoScore = math.max(answerScore[other_id_1 + 1], answerScore[other_id_2 + 1])
            self:showBubbleAnswerTrucoTips(data)
        end
    else
        if answerStatus[other_id_1 + 1] ~= 0 and answerStatus[other_id_2 + 1] ~= 0 then
            tlog("here show 3")
            --对家已经做完应答了，truco的一方这时候应该展示...
            self:otherSideWaitTip(other_id_1)
            btnCallFun(firstTrucoId, teamId)
            --truco的对家展示应答气泡
            local data = {}
            data.chairID = other_id_1
            data.TrucoScore = answerStatus[other_id_1 + 1]
            data.TeamTrucoScore = answerStatus[other_id_2 + 1]
            data.CurrentTrucoScore = math.max(answerScore[other_id_1 + 1], answerScore[other_id_2 + 1])
            self:showBubbleAnswerTrucoTips(data)
        else
            tlog("here show 4")
            --对家没有应答完，展示truco和对家...
            self:showBubbleTrucoTips(firstTrucoId, _cmdData.CurrentTrucoScore)
            btnCallFun(other_id_1, other_id_2)
        end
    end
end

return TrucoBubbleLayer