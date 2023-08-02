

local userLayer = class("userLayer")
local HeadNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HeadNode")
local chipConfig = {22,55,100,500,10000} 

function userLayer:onExit()
    
end

function userLayer:ctor(pNode)
    self.m_rootNode = pNode    
    self.m_chipText = {}
    self:initData()
    -- self:setChipConfig(chipConfig)
    -- self:setBtnBright()
        --下注门槛遮罩
	--self.mm_Panel_limit = self.mm_csbNode:getChildByName("Panel_limit")
	--检测下注门槛
	self:checkJettonThreshold()
end

function userLayer:resetBtnPos()
    for i=1,5 do
        local btn = self["mm_Button_chip"..i]
        btn:setPositionY(btn.userData.y1)
        -- btn:setBright(false)
        self["mm_Image_shade"..i]:hide()
    end
end

function userLayer:initSelectChip()
    if self.m_selectedChip == 0 and (self.m_OverThreshold and self.m_meShowScore > self.m_chipConfig[1]) then
        self:selectedChip(1,self.mm_Button_chip1)
    end
end

function userLayer:setBtnBright()
    for i=1,5 do
        local btn = self["mm_Button_chip"..i]
        if (not self.m_OverThreshold) or (self.m_chipConfig[i]> self.m_meShowScore) then
            btn:setBright(false)
            btn:setTouchEnabled(false)
            local btnY = btn:getPositionY()
            if btnY > btn.userData.y1 or btnY == btn.userData.y2 then
                btn:setPositionY(btn.userData.y1)
                self["mm_Image_shade"..i]:hide()
            end
        else
            btn:setBright(true)
            btn:setTouchEnabled(true)
        end
    end
end

function userLayer:isShwoChipPanel(isShow)
    self.mm_Panel_chip:setVisible(isShow)
    self.mm_Panel_chipBtn:setVisible(isShow)
    self.mm_Image_goldBg:setVisible(isShow)
    self.mm_Panel_limit:setVisible(isShow and not self.m_OverThreshold)    
end

--设置筹码配置
function userLayer:setChipConfig(chipConfigData)
    self.m_chipConfig = chipConfigData
    for i=1,5 do
        local btn = self["mm_Button_chip"..i]

        btn.userData = {}
        btn.userData.y1 = 55
        btn.userData.y2 = btn.userData.y1 + 20
        btn:onClicked(function(target) 
            self:selectedChip(i,target)

        end)
        local serverKind = G_GameFrame:getServerKind()
        local gold = g_format:formatNumber(self.m_chipConfig[i],g_format.fType.Custom_k,serverKind,1000)
        self.m_chipText[i] = self["mm_text_chipNumber"..i]
        self.m_chipText[i]:setString(gold)
    end
    
    self:initSelectChip()
end

--选择筹码
function userLayer:selectedChip(index,btnNode)
    self:resetBtnPos()
    btnNode:setPositionY(btnNode.userData.y2)
    self["mm_Image_shade"..index]:show()

    self.m_selectedChip = index
    self.m_curBetScore = self.m_chipConfig[self.m_selectedChip]
end
--获取当前选中投注筹码额度
function userLayer:getBetScore()
    return self.m_curBetScore
end

--获取筹码下标
function userLayer:getChipIndex(betScore,isMe)
    if isMe then
        print("收到自己下注：",betScore)
        for i,v in ipairs(self.m_chipConfig) do
            if betScore <= v then
                return i
            end
        end
        return 1 
    else
        return math.random(1, 5)
    end
end

--获取筹码配置
function userLayer:getChipConfig()
    return self.m_chipConfig
end
-----------------------------------------------------------

function userLayer:initData()
    self.m_headNodes = {}
    for i=1,4 do
        local item = self["mm_FileNode_user"..i]
        g_ExternalFun.loadChildrenHandler(item, item)
        table.insert( self.m_headNodes, item )
    end
    self.m_playInfo = {}
    self.m_meShowScore = GlobalUserItem.lUserScore
    self.m_selectedChip = 0    --选中筹码下标
    self.m_curBetScore = 0     --选中筹码的额度

    self.over_vip                       = 1         --限额阈值
    self.m_OverThreshold                = false     --玩家数高于阈值
    self:initPosInfo()
end

--初始化自己
function userLayer:initMeInfo(userData)
    --self.m_meInfo.wChairID
    --self.m_meInfo.lScore
    self.m_meInfo = userData
    self.m_meShowScore = userData.lScore
    self:setUpdateScore(self.mm_Text_gold,self.m_meShowScore)
    self:setBtnBright()
    -- self:checkAutoStatus()
end

function userLayer:initPosInfo()
    if not self.mm_Image_goldBg.originPos then
        local originPos = cc.p(self.mm_Image_goldBg:getPosition())
        self.mm_Image_goldBg.originPos = originPos
        self.mm_Image_goldBg.movePos = cc.p(originPos.x - 10,originPos.y)
    end
     --榜上玩家
     for i,v in ipairs(self.m_headNodes) do
        if not v.originPos then
            local originPos = cc.p(self.m_headNodes[i]:getPosition())
            v.originPos = originPos
            v.movePos = cc.p(originPos.x - 10,originPos.y)
        end
    end
    --其他玩家
    if not self.mm_Image_allUser.originPos then
        local pos = cc.p(self.mm_Image_allUser:getPosition())
        self.mm_Image_allUser.originPos = pos
        self.mm_Image_allUser.movePos = cc.p(pos.x - 10,pos.y)
    end
end

--更新玩家的金币
function userLayer:setUpdateScore(node,score)
    local serverKind = G_GameFrame:getServerKind()
    node:setString(g_format:formatNumber(score,g_format.fType.Custom_k,serverKind,10000))
end

function userLayer:getMeScore()
    return self.m_meShowScore
end

function userLayer:onUpdateVipPlayInfo(playInfo,_totalUpdate,chairArray)
    self.m_vipChairArray= playInfo
    for i=1,4 do
        local playerInfo = playInfo[i]
        local playerNode = self.m_headNodes[i]
        local curChairId = playerInfo.wChairID
        if curChairId ~= G_NetCmd.INVALID_CHAIR then
            playerNode:setVisible(true)
            --不同的玩家才更新名字和头像
            if (not playerNode.Info) or playerNode.Info.wChairID ~= curChairId or _totalUpdate then

                playerNode.mm_Text_userName:setString(playerInfo.szNickName)
                -- if playerInfo.szNickName == GlobalUserItem.szNickName then
                --     playerNode.mm_Image_selfIcon:setVisible(true)
                --     playerNode.mm_Text_userName:setTextColor(cc.c3b(0, 200, 0, 255))
                -- else
                --     playerNode.mm_Image_selfIcon:setVisible(false)
                --     playerNode.mm_Text_userName:setTextColor(cc.c3b(0, 62, 82, 255))
                -- end
                --头像
                playerNode.mm_Image_head:removeAllChildren()
                local faceId = playerInfo.wFaceID
                local dwUserID = playerInfo.dwUserID
                -- local pPathHead = string.format("client/res/public/Face%d.jpg", faceId)
                -- local pPathClip = "GUI/user/roulette_txk2.png"
                -- g_ExternalFun.ClipHead(playerNode.mm_Image_head, pPathHead, pPathClip)
                local node = HeadNode:create(faceId)
                playerNode.mm_Image_head:addChild(node)
                node:setContentSize(cc.size(158,158))
                node:setBorderVisible(false)
                node:setTouched(false)
                if dwUserID ~= GlobalUserItem.dwUserID then              --如果不是自己
                    node:setVipVisible(false)
                end
                --更新财富值
                self:setUpdateScore(playerNode.mm_Text_gold,playerInfo.lScore)
                playerNode.Info = playerInfo
                -- node_head:setPosition(75, 210)
                local currencyType = G_GameFrame:getServerKind()
                g_ExternalFun.setIcon(playerNode.mm_Image_gold,currencyType)
            end
        else
            playerNode:setVisible(false)
            playerNode.Info = nil
        end
    end
end
--是否是榜上玩家
function userLayer:isVipPlay(chairID)
    for i=1,4 do
        if self.m_vipChairArray[i].wChairID == chairID then
            return true
        end
    end
    return false
end

--获取玩家下注筹码起始位置
function userLayer:getBeginPos(data)
    if self.m_rootNode:isMe(data.wChairID) then
        print("自己下注")
        if not self.mm_Image_goldBg.originPos then
            local originPos = cc.p(self.mm_Image_goldBg:getPosition())
            self.mm_Image_goldBg.originPos = originPos
            self.mm_Image_goldBg.movePos = cc.p(originPos.x - 10,originPos.y)
        end
        return self.mm_Image_goldBg.originPos
    elseif self:isVipPlay(data.wChairID) then
        --榜上玩家
        for i,v in ipairs(self.m_headNodes) do
            if v.Info and v.Info.wChairID == data.wChairID then
                if not v.originPos then
                    local originPos = cc.p(self.m_headNodes[i]:getPosition())
                    v.originPos = originPos
                    v.movePos = cc.p(originPos.x - 10,originPos.y)
                end
                return v.originPos
            end
        end
    else
        --其他玩家
        if not self.mm_Image_allUser.originPos then
            local pos = cc.p(self.mm_Image_allUser:getPosition())
            self.mm_Image_allUser.originPos = pos
            self.mm_Image_allUser.movePos = cc.p(pos.x - 10,pos.y)
        end
        return self.mm_Image_allUser.originPos
    end
end
--扣金币

function userLayer:deductShowGold(betScore,wChairID)
    if wChairID == self.m_meInfo.wChairID then
        self.m_meShowScore = self.m_meShowScore - betScore
        self:setUpdateScore(self.mm_Text_gold,self.m_meShowScore)
        self:setBtnBright()
        return
    end
    if self:isVipPlay(wChairID) then
        --榜上玩家
        for i,v in ipairs(self.m_headNodes) do
            if v.Info and v.Info.wChairID == wChairID then
                v.Info.lScore = v.Info.lScore - betScore
                self:setUpdateScore(v.mm_Text_gold,v.Info.lScore)
                self:headBeat(v,true)
            end
        end
        return
    end

    self:headBeat(self.mm_Image_allUser,true)
end


function userLayer:scoreAction(cmdData)
    --自己的
    local gold = tonumber(cmdData.lPlayAllScore)
    if gold > 0 then
        self.m_meShowScore = self.m_meShowScore + gold
        self:setUpdateScore(self.mm_Text_gold,self.m_meShowScore)
        self:setBtnBright()
        self:moveGold(self.mm_meMoveGold,gold,cc.p(0,0))
    end
    --VIP 玩家的
 
    for i=1,4 do
        gold = tonumber(cmdData.lPlayOtherScore[i])

        if gold > 0 then
            local vipNode = self["mm_MoveGold_"..i]
            self:moveGold(vipNode,gold,cc.p(0,0))
            local textNode = self.m_headNodes[i]
            if textNode  then
                textNode.Info.lScore = textNode.Info.lScore + gold
                self:setUpdateScore(textNode.mm_Text_gold,textNode.Info.lScore)
            end
        end
    end
end

--飘金币数字
function userLayer:moveGold(node, goldNum, pos)
    if goldNum == nil then
        return
    end
    
    goldNum = tonumber(goldNum)
    if type(goldNum) ~= "number" then 
        return 
    end
    if goldNum == 0 then 
        return
    end
    
    local preStr = goldNum < 0 and "-" or "+"
    local serverKind = G_GameFrame:getServerKind()
    goldNum = math.abs( goldNum )
    goldNum = g_format:formatNumber(goldNum,g_format.fType.standard,serverKind)

    node:setString(preStr..goldNum)
    node:setPosition(pos)
    node:setOpacity(0.1)
    node:show()
    local move1 = cc.MoveBy:create(0.2, cc.p(0, 30))
    local detime = cc.DelayTime:create(0.5)
    local move3 = cc.MoveBy:create(1, cc.p(0, 150))

    local fadeIn = cc.FadeIn:create(0.2)
    local fadeOut = cc.FadeOut:create(1)
    local spawn1 = cc.Spawn:create(move1, fadeIn)
    local spawn2 = cc.Spawn:create(move3, fadeOut)

    local func = cc.CallFunc:create(function() node:hide() end)
    node:runAction(cc.Sequence:create(spawn1, detime, spawn2,func))
    print("飘分：",goldNum)
end

--下注头像晃动
function userLayer:headBeat(node,left)
    local move1 = cc.MoveTo:create(0.05, node.movePos)
    local move2 = cc.MoveTo:create(0.05,node.originPos)
    node:runAction(cc.Sequence:create(move1,move2))
end

function userLayer:getOverThreshold()
    return self.m_OverThreshold
end

--检测下注门槛
function userLayer:checkJettonThreshold()
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        self.m_OverThreshold = GlobalUserItem.VIPLevel and GlobalUserItem.VIPLevel >= self.over_vip
        --门槛遮罩显示
        self.mm_Panel_limit:setVisible(not self.m_OverThreshold)      
        if not self.m_OverThreshold then
            --重置自动下注
            self.mm_Button_repetir:setBright(false)
        end     
    else
        self.m_OverThreshold = true
        self.mm_Panel_limit:hide()
    end
end

return userLayer