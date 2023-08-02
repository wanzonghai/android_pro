--彩金池节点
local caiJinNode = class("caiJinNode", cc.Node)

function caiJinNode:ctor()
	tlog('caiJinNode:ctor')
    self.tagScoreTb = {}
    self.scoreIdx = 1
    local spinePath2 = "client/res/spine/caijinchi_2"
    local spineAnim2 = sp.SkeletonAnimation:create(spinePath2..".json", spinePath2..".atlas", 1)
    spineAnim2:setAnimation(0, "daiji", true)
    spineAnim2:setPosition(0, 0)
    spineAnim2:addTo(self)

	local path = "client/res/Lobby/caiJinNode.csb"
    local csbNode = cc.CSLoader:createNode(path)
    local timeline = cc.CSLoader:createTimeline(path)
    csbNode:setPosition(0, 0)
    csbNode:addTo(self)
    self.csbNode = csbNode

    local winscore = GlobalData.JackPotScore or 0
    local serverKind = G_GameFrame:getServerKind()
    local winNum = g_format:formatNumber(winscore,g_format.fType.standard,serverKind)
    local Text_score = csbNode:getChildByName("Panel_1"):getChildByName("Text_score")
    Text_score:setString("R$ "..winNum)
    Text_score:setScale(0.9)
    Text_score._lastNum = winscore
    Text_score._curNum = winscore

    local spinePath1 = "client/res/spine/caijinchi_1"
    local spineAnim1 = sp.SkeletonAnimation:create(spinePath1..".json", spinePath1..".atlas", 1)
    spineAnim1:setAnimation(0, "daiji", true)
    spineAnim1:setPosition(0, 0)
    spineAnim1:addTo(self)

    G_event:AddNotifyEventTwo(self, G_eventDef.NET_GET_JACK_POT_STATUS_RESULT,handler(self,self.updateChiScore))

    -- local sequence = cc.Sequence:create(
    --     cc.DelayTime:create(2.0), 
    --     cc.CallFunc:create(function()
    --         --请求池值
    --         --G_ServerMgr:C2S_GetMailList(10, 1)
    --         --testcode
    --         local cmdData = {}
    --         cmdData.llScore = Text_score._curNum + 5000
    --         self:updateChiNumber(cmdData)
    --     end)
    -- )
    -- local action = cc.RepeatForever:create(sequence)
    -- self:runAction(action)
end

function caiJinNode:onExit()
    G_event:RemoveNotifyEventTwo(self, G_eventDef.NET_GET_JACK_POT_STATUS_RESULT)
end
--彩金池分10次滚动完
function caiJinNode:updateChiNumber()
    local winscore = self.tagScoreTb[self.scoreIdx]
    if winscore then
        local Text_score = self.csbNode:getChildByName("Panel_1"):getChildByName("Text_score")
        Text_score._lastNum = Text_score._curNum
        Text_score._curNum = winscore
        self:updateGoldShow(Text_score, 0.3)
    end
end
--更新彩金数值
function caiJinNode:updateChiScore(cmdData)
    local winscore = cmdData.llScore
    local Text_score = self.csbNode:getChildByName("Panel_1"):getChildByName("Text_score")
    -- Text_score._lastNum = Text_score._curNum
    -- Text_score._curNum = winscore
    -- self:updateGoldShow(Text_score, 0.3)
    Text_score:stopAllActions()
    local addScore = winscore - Text_score._curNum
    self.tagScoreTb = {}
    for i=1,10 do
        self.tagScoreTb[i] = Text_score._curNum + math.floor(addScore*i/10)
    end
    self.scoreIdx = 0
    --15秒除以10减0.3秒滚动,在1.2秒上下浮动
    local spaceTb = {1.0, 1.1, 1.5, 1.2, 0.9, 1.3, 1.2, 1.4, 0.8, 1.6}
    --打乱顺序
    local len = #spaceTb
    for i=1,len do
        local rand = math.random(i, len)
        local temp = spaceTb[i]
        spaceTb[i] = spaceTb[rand]
        spaceTb[rand] = temp
    end

    local actionTb = {}
    for i=1,10 do
        table.insert(actionTb, 
            cc.CallFunc:create(function ( ... )
                self.scoreIdx = self.scoreIdx + 1
                if self.scoreIdx > #self.tagScoreTb then
                    self:stopAllActions()
                    self.tagScoreTb = {}
                    self.scoreIdx = 1
                else
                    self:updateChiNumber()
                end
            end)
        )
        table.insert(actionTb, 
            cc.DelayTime:create(spaceTb[i])
        )
    end
    local seqAnim = cc.Sequence:create(actionTb)
    self:stopAllActions()
    self:runAction(seqAnim)
end
--格式化数字展示
function caiJinNode:formatNumShow(_node, _nums)
    --tlog("caiJinNode:formatNumShow", _nums)
    local serverKind = G_GameFrame:getServerKind()
    local formatMoney = g_format:formatNumber(_nums,g_format.fType.standard,serverKind)
    _node:setString("R$ "..formatMoney)
end
--跑数字动画的方式更新文字
function caiJinNode:updateGoldShow(_nodeText, time)
    tlog("caiJinNode:updateGoldShow", time)
    local newValue = _newValue
    _nodeText:stopAllActions()
    local lastNum = _nodeText._lastNum
    local curNum = _nodeText._curNum
    self:formatNumShow(_nodeText, lastNum)
    local loopNums = math.ceil(time / 0.05) --每0.05秒更新一次
    local gapNums = math.ceil((curNum - lastNum) / loopNums)
    self:addGoldNumsShowInterval(_nodeText, lastNum, curNum, gapNums)
end
--跑数字动画
function caiJinNode:addGoldNumsShowInterval(_node, _srcNums, _dstNums, _addNums)
    -- tlog('caiJinNode:addGoldNumsShowInterval')
    local nowNums = _srcNums + _addNums
    if nowNums >= _dstNums then
        nowNums = _dstNums
        _node._lastNum = nowNums
        self:formatNumShow(_node, nowNums)
        return
    end
    self:formatNumShow(_node, nowNums)
    _node:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function (_target, _params)
        self:addGoldNumsShowInterval(_params.node, _params.srcNums, _params.dstNums, _params.addNums)
    end, {node = _node, srcNums = nowNums, dstNums = _dstNums, addNums = _addNums})))
end

return caiJinNode