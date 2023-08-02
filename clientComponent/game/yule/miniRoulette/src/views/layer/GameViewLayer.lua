--[[

]]

local gameViewLayer = class("gameViewLayer",ccui.Layout)
local recordLayer = appdf.req("game.yule.miniRoulette.src.views.layer.recordLayer")
local helpLayer = appdf.req("game.yule.miniRoulette.src.views.layer.helpLayer")
local sounds = appdf.req("game.yule.miniRoulette.src.models.sounds")

function gameViewLayer:onExit()
    self.mm_FileNode_ui:onExit()
    self.mm_FileNode_bet:onExit()
    self.mm_FileNode_roulette:onExit()
    self.mm_FileNode_user:onExit()
    self.m_scene:onUiExitTable()
    g_ExternalFun.stopMusic()
end

function gameViewLayer:ctor(scene)
    self.m_scene = scene 
    self:initData()
    self:initCSB()

    g_ExternalFun.playMusic(sounds.music_bg, true)
end

function gameViewLayer:initData()
    self.m_soundsVolume = 1      --音效的音量
    self.m_cbGameStatus = nil
    self.m_curRemainTime = nil  --当前剩余时间
    self.m_repetirBetList = {}   -- 重复投注列表
    self.m_isNext = false    --标志不是当前局，不是当前局。只要手动投注了，就false,同时清除 self.m_repetirBetList 
    self.m_AllBetScore = 0   --全部投注分数
    self.m_meAllBetScore = 0    --我的总投注分数
end

function gameViewLayer:initCSB()
    self._searchPath = device.writablePath.."game/yule/miniRoulette/"
    cc.FileUtils:getInstance():addSearchPath(self._searchPath)
    self.mm_csbNode = cc.CSLoader:createNode("res/UI/gameViewLayer.csb")
    self.mm_csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(self.mm_csbNode)
    self.mm_csbNode:addTo(self)
    g_ExternalFun.loadChildrenHandler(self, self.mm_csbNode)
    self.mm_Panel_wait:hide()

    --绑定脚本到节点
    g_ExternalFun.addScriptForChildNode(self.mm_FileNode_bet,"src.views.layer.betAreaLayer",self)        --下部分下注层
    g_ExternalFun.addScriptForChildNode(self.mm_FileNode_roulette,"src.views.layer.rouletteLayer",self)  --上半屏转动层
    g_ExternalFun.addScriptForChildNode(self.mm_FileNode_user,"src.views.layer.userLayer",self)          --用户层
    g_ExternalFun.addScriptForChildNode(self.mm_FileNode_ui,"src.views.layer.uiLayer",self)              --UI层

    --重复投注
    self.mm_Button_repetir:onClicked(function(target) 
        local btnStatus = target:isBright()        
        if btnStatus == true then
            self:onRepetirBet()
        end
    end)
    self.mm_Button_repetir:setBright(false)
    -- --自动投注
    -- self.mm_btn_auto:onClicked(function() 
    --     if self.mm_Button_repetir:isBright() == true then
    --         self.mm_btn_auto:setBright(false)
    --         self:onRepetirBet()
    --     else
    --         self.mm_btn_auto:setBright(true)
    --     end
    -- end)
end
    --cbAllTime
    --cbTimeLeave
function gameViewLayer:setDefaultLayerPos(cbTimeLeave,cbAllTime)
    self.m_isNext = true
    if #self.m_repetirBetList > 0 then
        self.mm_Button_repetir:setBright(true)

        -- performWithDelay(self,function() 
        --     if self.mm_Button_repetir:isBright() == true and self.mm_btn_auto:isBright() == false then
        --         self:onRepetirBet()
        --     end
        -- end,8)
    end
    self.m_curRemainTime = cbTimeLeave
    self.mm_Image_table:stopAllActions()
    self.mm_Image_table:setPositionY(540)
    self.mm_FileNode_bet:setIsTouch(false)
    local _x,_y = self.mm_Image_table:getPosition()
    self.mm_Image_table.userData = cc.p(self.mm_Image_table:getPosition())
    self.mm_FileNode_ui:sliderUpdate( cbTimeLeave,cbAllTime )
    self.mm_FileNode_bet:recycleChip()
    self.m_AllBetScore = 0
    self.m_meAllBetScore = 0
end
--开奖动画  等待
function gameViewLayer:runLotteryAnimation(cmdData)
    self.m_curRemainTime = cmdData.cbTimeLeave
    self.mm_FileNode_bet:setIsTouch(true)
    self.mm_Image_table:setPositionY(540)
    local _x,_y = self.mm_Image_table:getPosition()
    self.mm_Image_table.userData = cc.p(self.mm_Image_table:getPosition())
    --恢复派奖的剩余时间
    local resetMoveTime = 6
    --转盘页面
    self.mm_Image_table:runAction(cc.Sequence:create({
        cc.CallFunc:create(function()  
            self.mm_FileNode_roulette:resetOpen()
            self.mm_Image_record:hide()
            self.mm_FileNode_user:isShwoChipPanel(false)
        end),
        cc.DelayTime:create(1),
        cc.MoveTo:create(0.5, cc.p(self.mm_Image_table.userData.x, -340 + (display.size.height - 1080))), 
        cc.Spawn:create({
            cc.DelayTime:create(cmdData.cbTimeLeave - resetMoveTime),
            cc.CallFunc:create(function() 
                self.mm_FileNode_roulette:setOpenResult(cmdData.openNum)  --服务器开奖从0开始的
                self.mm_FileNode_roulette:runRoulette()
                ccexp.AudioEngine:play2d(sounds.roll, false,self.m_soundsVolume)
                self.mm_FileNode_ui:sliderUpdate( cmdData.cbTimeLeave-2,nil)
            end)
        }),
        cc.MoveTo:create(0.5, cc.p(self.mm_Image_table.userData.x, 540)), 
        cc.CallFunc:create(function()  
            self.mm_Image_record:show()
            self.mm_FileNode_user:isShwoChipPanel(true)
            self.mm_FileNode_bet:winAreaBlink(cmdData.openNum)  --中奖区域闪烁
            self.mm_FileNode_bet:onAwarding(cmdData.openNum)    --派奖
            self.mm_FileNode_roulette:resetOpen()
            performWithDelay(self.mm_FileNode_user,function() 
                self.mm_FileNode_ui:addRecordData(cmdData.openNum)  --更新记录
                --输赢飘分  
                self.mm_FileNode_user:scoreAction(cmdData)
            end,1.5)
        end),
    }))
end

function gameViewLayer:sendUserBet(betType,betArea)
    local score = self.mm_FileNode_user:getBetScore()
    if score == nil then
        print("配置异常")
        return
    end

    if self.mm_FileNode_user:getMeScore() < score then
        print("金币不够")
    end
    if not self.mm_FileNode_user:getOverThreshold() then
        print("下注门槛20")
        return
    end
    self.m_scene:sendUserBet(score,betType,betArea)
end

function gameViewLayer:setChipConfig(chipConfigData)
    self.mm_FileNode_user:setChipConfig(chipConfigData)

end

function gameViewLayer:upMeScore(myData)
    self.mm_FileNode_user:initMeInfo(myData)
end

function gameViewLayer:waitStatus(isShow)
    if isShow then
        self.mm_Panel_wait:show()
    else
        self.mm_Panel_wait:hide()
    end
end

--用户下注事件
function gameViewLayer:onUserChipEvent(data,isBet)

    local callback = function() 
        --是真实投注，扣除显示金币  isBet==false 是断线恢复场景来的数据
        if isBet then
            self.mm_FileNode_user:deductShowGold(data.lBetScore,data.wChairID)
        end
    end

    local isMe = self:isMe(data.wChairID)
    if isMe then
        if self.m_isNext == true then
            self.m_repetirBetList = {}
            self.m_isNext = false
            self.mm_Button_repetir:setBright(false)
            -- self.mm_btn_auto:setBright(false)
        end
        local betData = {}
        betData.cbBetArea = data.cbBetArea
        betData.cbBetType = data.cbBetType
        betData.lBetScore = data.lBetScore
        table.insert( self.m_repetirBetList, betData )
    end
    local beginPos = self.mm_FileNode_user:getBeginPos(data)
    if isMe then
        local chipIndex = self.mm_FileNode_user:getChipIndex(data.lBetScore,isMe)
        self.mm_FileNode_bet:addChip(data,chipIndex,beginPos,isMe,self.m_curRemainTime)
        callback()
    else
        local numArray = self:getRandomScoreSprite(data.lBetScore)
        for index,score in pairs(numArray) do
            if score > 0 then
                chipIndex = math.random(1, 5)
                self.mm_FileNode_bet:addChip(data,chipIndex,beginPos,isMe,self.m_curRemainTime,callback)
            end
        end
    end

    self.m_AllBetScore = self.m_AllBetScore + data.lBetScore
    if isMe then
        self.m_meAllBetScore = self.m_meAllBetScore + data.lBetScore
    end
    self.mm_FileNode_bet:showAllBetScore(self.m_AllBetScore,self.m_meAllBetScore)
end

--恢复用户下注  中途进入  recursively
function gameViewLayer:recoverUserBet(betRecord)
    for chairdId,betTab in pairs(betRecord) do
        for i,v in ipairs(betTab) do
            local data = {
                wChairID = chairdId,
                cbBetType = v.betType,
                cbBetArea = v.betArea,
                lBetScore = v.score
            }
            self:onUserChipEvent(data,false)
        end
    end
end

--通过下注额从筹码序列高到底获取每个档次筹码数量
function gameViewLayer:getRandomScoreSprite(betScore)
	if betScore <= 0 then
		return {}, 0
	end
	local numArray = {0, 0, 0, 0, 0}
	local score = math.abs(betScore)
	local totalNum = 0
	local betScoreData = self.mm_FileNode_user:getChipConfig()

	for i = 5, 1, -1 do
		local num = math.modf(score / betScoreData[i])
		if num > 0 then
			if num > 10 then
				num = 10 --避免太多
			end
			numArray[i] = num
			totalNum = totalNum + num
			score = score % betScoreData[i]
		end
	end
	if score ~= 0 then
		numArray[1] = numArray[1] + 1
		totalNum = totalNum + 1
	end

	return numArray, totalNum
end



function gameViewLayer:getUserInf(chairID)
    local _userList = self.m_scene:getDataMgr():getChairUserList() 
    return _userList[chairID + 1]
end

--更新榜上玩家信息
function gameViewLayer:onUpdateVipPlayInfo(_chairArray, _totalUpdate)
    tdump(_chairArray, "更新榜上玩家信息", 10)
    local _playerData = {}
    for i, v in ipairs(_chairArray) do
        local data = {}
        if v == G_NetCmd.INVALID_CHAIR then
            data.wChairID = G_NetCmd.INVALID_CHAIR
        else
            local userInfo = self:getUserInf(v)
            data = clone(userInfo)
        end
        table.insert(_playerData, data)
    end
    self.mm_FileNode_user:onUpdateVipPlayInfo(_playerData,_totalUpdate,_chairArray)

end

function gameViewLayer:isMe(chairID)
    local userInfo = self:getUserInf(chairID)
	if nil == userInfo then
		return false
	else 
        if userInfo.dwUserID == GlobalUserItem.dwUserID then
		    return true
        else
            return false
        end
	end    
end

function gameViewLayer:setRecordData(recordData)
    self.m_recordData = recordData
    self.mm_FileNode_ui:setRecordData(recordData)
end

function gameViewLayer:createRecordNode(gameRecord)
        local recordNode = recordLayer:create(gameRecord)
        self:addChild(recordNode)
end

function gameViewLayer:createHelp()
    local helpNode = helpLayer:create()
    self:addChild(helpNode)
end
--重复投注
function gameViewLayer:onRepetirBet()
    self.mm_Button_repetir:setBright(false)
    ccexp.AudioEngine:play2d(sounds.stackChip, false,self.m_soundsVolume)
    for k,v in pairs(self.m_repetirBetList) do
        if self.mm_FileNode_user:getMeScore() > v.lBetScore then
            self.m_scene:sendUserBet(v.lBetScore,v.cbBetType,v.cbBetArea)
        end
    end
end

function gameViewLayer:setBtnBright()
    self.mm_FileNode_user:setBtnBright()
end

--检测下注门槛
function gameViewLayer:checkJettonThreshold()
    self.mm_FileNode_user:checkJettonThreshold()
end

return gameViewLayer