local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
local module_pre = "game.yule.snowwomen.src"
local g_var = g_ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"
local GameHelpLayer = appdf.req(module_pre .. ".views.layer.GameHelpLayer")
local TurnedAround = appdf.req(module_pre .. ".views.layer.TurnedAround")
local TurnConfig = appdf.req(module_pre .. ".models.TurnConfig")
local g_scheduler = cc.Director:getInstance():getScheduler()
local Item_Width = 188 --一个滚动的格子占据的宽度180是实际道具宽度
local Panel_Height = 552 --容器的高度
local EventPost = appdf.req(appdf.CLIENT_SRC.."Tools.EventPost")
local enumTable = 
{
	"BT_START",
	"BT_EXIT",
	"BT_SOUND",			--音效
	"BT_VOICE",			--音乐
	"BT_HELP",
	"BT_JIAN",
	"BT_JIA",
	"BT_MAX",
	"BT_QUICK",
	"BT_STOP",
	"BT_AUTO",
}
local first_tag = 100
local TAG_ENUM = g_ExternalFun.declarEnumWithTable(first_tag, enumTable)

function GameViewLayer:ctor(scene)
	tlog('GameViewLayer:ctor')
	--注册node事件
	g_ExternalFun.registerNodeEvent(self)
	
	self._scene = scene
	self:gameDataInit()

	--初始化csb界面
	self:initCsbRes()
	self:initScrollItem()
	self:registerTouch()

	--testcode
	-- self:initTestLine()
end
--[[function GameViewLayer:onCleanup()
	tlog("GameViewLayer:onCleanup")
	GameViewLayer.super.onCleanup(self)
end--]]
function GameViewLayer:rleasePlistRes()
	tlog("GameViewLayer:rleasePlistRes")
	--移除共用的纹理
	cc.Director:getInstance():getTextureCache():removeTextureForKey("GUI/xn_item.png")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("GUI/xn_item.plist")
end
--左侧展示中线数量测试用
function GameViewLayer:initTestLine()
	local testBg = display.newNode()
	testBg:setPosition(display.width/2, display.height/2)
	testBg:addTo(self,50)
	self.testLbs = {}
	for i=1,20 do
		local testText1 = ccui.Text:create(tostring(i).." = ","fonts/round_body.ttf",30)
	    testText1:setPosition(-900, 410-(i-1)*40)
	    testText1:addTo(testBg)
	    testText1:enableOutline(cc.c4b(130,66,14,255), 2)
	    local testText2 = ccui.Text:create("0","fonts/round_body.ttf",30)
	    testText2:setPosition(-860, 410-(i-1)*40)
	    testText2:addTo(testBg)
	    testText2:enableOutline(cc.c4b(130,66,14,255), 2)
	    table.insert(self.testLbs, testText2)
	end
end
function GameViewLayer:gameDataInit()
	tlog('GameViewLayer:gameDataInit')
    --无背景音乐
    g_ExternalFun.stopMusic()
    --用户列表
	self:getDataMgr():initUserList(self:getParentNode():getUserList())
    --加载资源
	self:loadRes()

	--逻辑变量
    self.isRun = false --是否正在执行动画
    self.isChange = false --是否切换场景
    self.endData = nil --结果
    self.endScene = 1 --场景1普通3免费2奖励
    self._curScene = 1
    self.sceneBefore = 1 --切换小玛利之前的场景
    self.nFreePlayTimes = 0 --免费次数
    self.nFreeMax=0 --最大免费次数
    self.nCurRoundFreeCount = 0 --当前轮触发的免费游戏次数
    self.totalAward = 0 --包含免费游戏总共赢得金币
    self.isHaveFreeResult=false --是否有免费结算
    self.freeResultData={} --免费结算数据
    self.lBounsWinScore ={0,0,0,0,0,0} --小玛利选择分数
    self.lWinScore3 = 0 --小玛利总共赢分
    self.isAuto= false --是否是自动
    self.autoCount =0 --自动剩余次数
    self.fruitPic = nil --道具图集暂时未用到
    self.betCfgIdx = 1 --选择下注配置序号
    self.betCfg = {} --下载配置
    self.isQuick = true--cc.UserDefault:getInstance():getBoolForKey("snowwomen_quick", false) --是否快速
    self.animtime = 0
    --文本按钮等
    self.Panel_icon = nil --旋转动画底板
    self.text_freeTimes = nil --免费次数文本
    self.text_zongXiaZhu = nil --总下注文本
    self.text_deFen = nil --得分
    self.text_deFen_cur = nil --当前轮得分
    self.img_defen = nil --赢分图片
    self.text_dangZhu = nil --单注20xbase
    self.text_userCoin = nil --玩家总共金币
    --self.text_autoNum
    self.btn_start = nil --开始按钮
    self.btn_stop = nil --停止按钮
	self.btn_auto = nil --自动按钮
    --self.btn_startFree = nil --免费开始按钮
    self.btn_max = nil --最大按钮
    self.btn_quick = nil --快速按钮
    self.addBtn = nil --增加按钮
    self.delBtn = nil --减少按钮
    self.normalBg = nil --普通背景
    self.freeBg = nil --免费背景
    self.quickImg = nil --快速模式选中对勾
    self.spineBoy = {} --中奖结果动画
    self.spineSpeed = {} --超级旋转动画
    self._autoSelectData = {true,true,true,true,true,true} --自动选择奖励状态

	self.m_scoreUser = 0 				--玩家金币数
	self.m_gameEndActionTime = false 	--是否结算动画时间内,当前时间内不更新金币显示
	self.m_bgMusicType = 0

	self.auto_select_num = 0 --雪女水晶点击次数
	self.schedulerID = nil --雪女水晶自动点击定时器
end

function GameViewLayer:loadRes()
	tlog('GameViewLayer:loadRes')
	--加载卡牌纹理
	cc.SpriteFrameCache:getInstance():addSpriteFrames("GUI/xn_item.plist")
end

---------------------------------------------------------------------------------------
--界面初始化
function GameViewLayer:initCsbRes()
	tlog('GameViewLayer:initCsbRes')
	local csbNode = cc.CSLoader:createNode("UI/GameLayer.csb")
	csbNode:addTo(self)
	-- local csbNode = g_ExternalFun.loadCSB("UI/GameLayer.csb", self)
	csbNode:setContentSize(display.size)
	ccui.Helper:doLayout(csbNode)
	self.m_csbNode = csbNode
	--分辨率适配
	self.m_csbNode:getChildByName("FN_title"):setPositionX(display.width-220)
	self.m_csbNode:getChildByName("Button_more"):setPositionX(135-50)
	self.m_csbNode:getChildByName("sp_btn_list"):setPositionX(318-50)
	
	--初始化按钮
	self:initBtn()
	--初始化玩家信息
	self:initUserInfo()
	--初始化桌面信息
	self:initJetton()
end

--初始化按钮
function GameViewLayer:initBtn()
	tlog('GameViewLayer:initBtn')
	self.m_btnList = self.m_csbNode:getChildByName("sp_btn_list")
	self.m_btnList:setVisible(false)
	--更多
	local btn_more = self.m_csbNode:getChildByName("Button_more")
	btn_more:addClickEventListener(function ()
		self.m_btnList:setVisible(not self.m_btnList:isVisible())
	end)
	--音效
	local btn = self.m_btnList:getChildByName("voice_btn")
	btn:setTag(TAG_ENUM.BT_SOUND)
	self:flushMusicResShow(btn, GlobalUserItem.bSoundAble)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent), nil, 0.02)
	--音乐
	btn = self.m_btnList:getChildByName("music_btn")
	btn:setTag(TAG_ENUM.BT_VOICE)
	self:flushMusicResShow(btn, GlobalUserItem.bVoiceAble)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent), nil, 0.02)
	--离开
	btn = self.m_btnList:getChildByName("back_btn")
	btn:setTag(TAG_ENUM.BT_EXIT)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	--说明
    btn = self.m_btnList:getChildByName("rule_btn")
	btn:setTag(TAG_ENUM.BT_HELP)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	local Panel_content = self.m_csbNode:getChildByName("Panel_content")
	local Panel_bottom = Panel_content:getChildByName("Panel_bottom")
	--开始按钮
    btn = Panel_bottom:getChildByName("Button_start")
	btn:setTag(TAG_ENUM.BT_START)
	btn:addTouchEventListener(handler(self, self.onStartButtonClickedEvent))
	self.btn_start = btn
	--停止按钮
    btn = Panel_bottom:getChildByName("Button_stop")
	btn:setTag(TAG_ENUM.BT_STOP)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_stop = btn
	--自动按钮
    btn = Panel_bottom:getChildByName("Button_auto")
	btn:setTag(TAG_ENUM.BT_AUTO)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_auto = btn
	--减少按钮
    btn = Panel_bottom:getChildByName("Button_jian")
	btn:setTag(TAG_ENUM.BT_JIAN)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.delBtn = btn
	--增加按钮
    btn = Panel_bottom:getChildByName("Button_jia")
	btn:setTag(TAG_ENUM.BT_JIA)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.addBtn = btn
	--最大按钮
    btn = Panel_bottom:getChildByName("Button_max")
	btn:setTag(TAG_ENUM.BT_MAX)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_max = btn
	--快速按钮
    btn = Panel_bottom:getChildByName("Button_quick")
	btn:setTag(TAG_ENUM.BT_QUICK)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_quick = btn
end

--音效音乐设置资源
function GameViewLayer:flushMusicResShow(_node, _enabled)
	_node:getChildByName('Image_1'):setVisible(_enabled)
	_node:getChildByName('Image_2'):setVisible(not _enabled)
end

--初始化玩家信息
function GameViewLayer:initUserInfo()
	tlog('GameViewLayer:initUserInfo')
	--玩家游戏币
	--[[local node_bottom = self.m_csbNode:getChildByName("Node_bottom")
	self.m_textUserCoint = node_bottom:getChildByName("Image_19"):getChildByName("coin_text")
	self.m_textUserCoint._lastNum = 0
	self.m_textUserCoint._curNum = 0
	self:reSetUserInfo()--]]
end

function GameViewLayer:reSetUserInfo(_reduceNum)
	--[[tlog('GameViewLayer:reSetUserInfo ', _reduceNum)
	if _reduceNum == nil then
		_reduceNum = 0
	end
	self.m_scoreUser = 0
	local myUser = self:getMeUserItem()
	if nil ~= myUser then
		self.m_scoreUser = myUser.lScore
	end
	print("自己游戏币: " .. self.m_scoreUser)
	self:updateUserScore(_reduceNum)--]]
end

--下注及恢复场景的时候需要手动减去自己已下注的游戏币
function GameViewLayer:updateUserScore(_reduceNum)
	--[[self.m_scoreUser = self.m_scoreUser - _reduceNum
	tlog('GameViewLayer:updateUserScore ', self.m_scoreUser, _reduceNum)
	self.m_textUserCoint._lastNum = self.m_textUserCoint._curNum
	self.m_textUserCoint._curNum = self.m_scoreUser
	self.m_textUserCoint:stopAllActions()
	self:formatNumShow(self.m_textUserCoint, self.m_scoreUser)
	local length = self.m_textUserCoint:getContentSize().width
	local scale = math.min(375 / length, 1)
	self.m_textUserCoint:setScale(scale * 1.45) --默认放大1.45倍
	if _reduceNum ~= 0 then
		self:updateGoldShow(self.m_textUserCoint)
	end--]]
end

--初始化押注信息
function GameViewLayer:initJetton()
	tlog('GameViewLayer:initJetton')
	local Panel_content = self.m_csbNode:getChildByName("Panel_content")
	local Panel_center = Panel_content:getChildByName("Panel_center")
	local Panel_bottom = Panel_content:getChildByName("Panel_bottom")
	self.Panel_icon = Panel_center:getChildByName("Panel_roll") --旋转动画底板
    self.text_freeTimes = Panel_bottom:getChildByName("Button_stop"):getChildByName("text_num") --免费次数文本
    self.img_stop = Panel_bottom:getChildByName("Button_stop"):getChildByName("Image_8") --按钮的停止旋转图片
    self.img_free = Panel_bottom:getChildByName("Button_stop"):getChildByName("Image_9") --按钮的免费次数图片
    self.text_zongXiaZhu = Panel_bottom:getChildByName("text_total_num") --总下注文本
    self.text_deFen = Panel_bottom:getChildByName("bmlb_win") --得分
    self.text_deFen_cur = Panel_bottom:getChildByName("bmlb_win_cur") --当前轮得分
    self.text_userCoin = self.m_csbNode:getChildByName("FN_title"):getChildByName("Panel_1"):getChildByName("coin_num")
    local goldIcon = self.m_csbNode:getChildByName("FN_title"):getChildByName("Panel_1"):getChildByName("sprite_jinbi")
	local currencyType = G_GameFrame:getServerKind()
    g_ExternalFun.setIcon(goldIcon,currencyType)
	goldIcon:setScale(1.2)
    self.img_defen = Panel_bottom:getChildByName("Image_10") --赢分图片
    self.text_dangZhu = Panel_bottom:getChildByName("text_mult_score") --单注20xbase
    self.normalBg = Panel_content:getChildByName("Image_bg") --普通背景
    self.freeBg = Panel_content:getChildByName("Image_bg_free") --免费背景
    self.quickImg = Panel_bottom:getChildByName("Button_quick"):getChildByName("Image_5") --快速模式选中对勾

	self.text_freeTimes:setString("0")
    self.text_zongXiaZhu:setString("0")
    self.text_deFen._lastNum = 0
    self.text_deFen._curNum = 0
    self.text_deFen:setString("0")
    self.text_deFen_cur:setString("0")
    self.img_defen:setVisible(true)
    self.text_deFen_cur:setVisible(false)
    self.text_dangZhu:setString("20x0")
    --self.text_dangZhu:setString(g_format:formatNumber(g_var(cmd).MAX_LINE,g_format.fType.standard).."x0")
    self.quickImg:setVisible(false)
    self.text_userCoin._lastNum = 0
    self.text_userCoin._curNum = 0
    self.text_userCoin:setString("0")

    self:updateQuickStatus(self.isQuick)
end
---------------------------------------------------------------------------------------
function GameViewLayer:onButtonClickedEvent(_sender)
	local tag = _sender:getTag()
	tlog('GameViewLayer:onButtonClickedEvent ', tag)
	g_ExternalFun.playClickEffect()
	if tag == TAG_ENUM.BT_EXIT then
		--移除共用的纹理
		self:rleasePlistRes()
	    self:getParentNode():onQueryExitGame()
	elseif tag == TAG_ENUM.BT_SOUND then --音效
		GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble)
		self:flushMusicResShow(_sender, GlobalUserItem.bSoundAble)
	elseif tag == TAG_ENUM.BT_VOICE then
	    GlobalUserItem.setVoiceAble(not GlobalUserItem.bVoiceAble)
        self:flushMusicResShow(_sender, GlobalUserItem.bVoiceAble)
        if GlobalUserItem.bVoiceAble then
            if self._curScene == g_var(cmd).modeType.eBonus then
		        if self.nFreePlayTimes > 0 then
		        	self:playGamebgMusic(g_var(cmd).modeType.eFree)
		        else
		            self:playGamebgMusic(g_var(cmd).modeType.eNormal)
		        end
		    elseif self._curScene == g_var(cmd).modeType.eFree then
		        self:playGamebgMusic(g_var(cmd).modeType.eFree)
		    else
		        self:playGamebgMusic(g_var(cmd).modeType.eNormal)
		    end
        else
            self.m_bgMusicType = 0
        end
	elseif tag == TAG_ENUM.BT_HELP then
		-- tlog('GameViewLayer:createHelpLayer')
		self.m_btnList:setVisible(false)
	    local _helpLayer = GameHelpLayer:create():addTo(self, 10)
	    _helpLayer:setPosition(display.width * 0.5, display.height * 0.5)
	elseif tag == TAG_ENUM.BT_STOP then
    	if self._curScene ~= g_var(cmd).modeType.eFree then
    		if self.isRun then
    			local isSuccess = self.turnedAround:stopRollAction()
	            if isSuccess then
	                self:hideSuperAction()
	            end
    		end
    		self:_checkbox_autoEvent(2)
    	end
	elseif tag == TAG_ENUM.BT_AUTO then
		if not self.isAuto then
			self.autoCount = 10000
			self:_checkbox_autoEvent(1)
			self.btn_auto:getChildByName("img_gou"):setVisible(true)
		else
			self:_checkbox_autoEvent(2)
			self.btn_auto:getChildByName("img_gou"):setVisible(false)
			self.btn_start:setTouchEnabled(true)
			self.btn_start:setBright(true)
		end
	elseif tag == TAG_ENUM.BT_MAX then
		if #self.betCfg > 0 then
			self.betCfgIdx = #self.betCfg
	    	self:updateTotalBetNum()
	    end
	elseif tag == TAG_ENUM.BT_JIAN then
		if #self.betCfg > 0 then
			self.betCfgIdx = self.betCfgIdx - 1
			if self.betCfgIdx <= 0 then
				self.betCfgIdx = #self.betCfg
			end
			self:updateTotalBetNum()
		end
	elseif tag == TAG_ENUM.BT_JIA then
		if #self.betCfg > 0 then
			self.betCfgIdx = self.betCfgIdx + 1
			if self.betCfgIdx > #self.betCfg then
				self.betCfgIdx = 1
			end
			self:updateTotalBetNum()
		end
	elseif tag == TAG_ENUM.BT_QUICK then
		self.isQuick = not self.isQuick
		self:updateQuickStatus(self.isQuick)
		--cc.UserDefault:getInstance():setBoolForKey("snowwomen_quick", self.isQuick)
	else
		showToast("Funcionalidade não disponível!")
	end
end
--开始按钮点击事件,长按3s变自动
function GameViewLayer:onStartButtonClickedEvent(_sender, _eventType)
    tlog('GameViewLayer:onStartButtonClickedEvent')
    if _eventType == ccui.TouchEventType.began then
        self.m_touchBegan = true
        self.m_touchTick = tickMgr:getTime()
        -- if self._startBtnTimer ~= nil then
	    --    self._startBtnTimer:destroy()
	    --    self._startBtnTimer = nil
	    -- end
        -- self._startBtnTimer = tickMgr:delayedCall(function()
        --     self:showAutoPanel()
        -- end, 2000)
    elseif _eventType == ccui.TouchEventType.canceled then
        --_sender:stopAllActions()
    elseif _eventType == ccui.TouchEventType.ended then
        if self.m_touchBegan then
            self.m_touchBegan = false
            local curTick = tickMgr:getTime()
            if curTick - self.m_touchTick > 2 then
            	--self:showAutoPanel()
            else
            	-- if self._startBtnTimer ~= nil then
			    --    self._startBtnTimer:destroy()
			    --    self._startBtnTimer = nil
			    -- end
            	if self.isRun then
            		local isSuccess = self.turnedAround:stopRollAction()
		            if isSuccess then
		                self:hideSuperAction()
		            end
            	else
					if not self.isAuto then
						self:startGame()
						--删除超级旋转动画
						self:hideSuperAction()
					end
				end
            end
        end
    end
end
--更新总投注数值
function GameViewLayer:updateTotalBetNum()
	tlog('GameViewLayer:updateTotalBetNum')
	local totalAdd = 0
	if #self.betCfg > 0 then
		totalAdd = self.betCfg[self.betCfgIdx]*g_var(cmd).MAX_LINE
	end
    local danzhu = math.floor(totalAdd/g_var(cmd).MAX_LINE)
    local serverKind = G_GameFrame:getServerKind()
    self.text_zongXiaZhu:setString(g_format:formatNumber(totalAdd,g_format.fType.abbreviation,serverKind))
    self.text_dangZhu:setString(g_var(cmd).MAX_LINE.."x"..g_format:formatNumber(danzhu,g_format.fType.abbreviation,serverKind))
end  
--更新免费次数或自动次数
function GameViewLayer:updateAutoTimes()
	tlog('GameViewLayer:updateAutoTimes', self.nFreePlayTimes, self.autoCount, self.nFreeMax)
	if self.nFreePlayTimes > 0 then
		local freeStr = string.format("%d/%d", self.nFreePlayTimes, self.nFreeMax)
		self.text_freeTimes:setString(freeStr)
	elseif self.autoCount > 0 then
		if self.autoCount > 100 then
			self.text_freeTimes:setString("∞")
		else
			self.text_freeTimes:setString(self.autoCount)
		end
	else
		self.text_freeTimes:setString("0")
	end
end
--更新得分
function GameViewLayer:updateDeFen()
	tlog('GameViewLayer:updateDeFen', self.totalAward, self.endData.lAwardGold)
	self.text_deFen._lastNum = self.totalAward
	self.text_deFen._curNum = self.totalAward
	if self.totalAward > 0 then
		local serverKind = G_GameFrame:getServerKind()
		self.text_deFen:setString(g_format:formatNumber(self.totalAward,g_format.fType.standard,serverKind))
	end
	if self.endData.lAwardGold > 0 then
	    local serverKind = G_GameFrame:getServerKind()
	    self.text_deFen_cur:setString(g_format:formatNumber(self.endData.lAwardGold,g_format.fType.standard,serverKind))
	end
end
--更新快速模式状态
function GameViewLayer:updateQuickStatus(status)
	tlog('GameViewLayer:updateQuickStatus', status)
	if status then
		self.quickImg:setVisible(true)
	else
		self.quickImg:setVisible(false)
	end
end
--切换开始按钮和停止按钮状态
function GameViewLayer:switchStartBtnStatus(status)
	tlog('GameViewLayer:switchStartBtnStatus', status)
	if status then
		self.btn_start:setTouchEnabled(true)
		self.btn_start:setVisible(true)
		self.btn_stop:setTouchEnabled(false)
		self.btn_stop:setVisible(false)
	else
		self.btn_start:setTouchEnabled(false)
		self.btn_start:setVisible(false)
		self.btn_stop:setTouchEnabled(true)
		self.btn_stop:setVisible(true)
	end
end
--压满 线数 低注 开始 
function GameViewLayer:setBtnAEnable()
	tlog('GameViewLayer:setBtnAEnable', self.nFreePlayTimes, self.isAuto, self.isRun, self._curScene)
    local nFreePlayTimes = self.nFreePlayTimes
    if nFreePlayTimes>0 and (self._curScene == g_var(cmd).modeType.eFree) then
    	--self:updateAutoTimes()
        self:switchStartBtnStatus(false)
        self.addBtn:setTouchEnabled(false)
		self.delBtn:setTouchEnabled(false)
		self.btn_max:setTouchEnabled(false)
		self.img_stop:setVisible(false)
		self.text_freeTimes:setVisible(true)
		self.img_free:setVisible(true)
    else
        if self.isAuto then
            self.btn_start:setTouchEnabled(false)
			self.btn_start:setBright(false)
			self.btn_start:setVisible(true)
			self.btn_stop:setTouchEnabled(false)
			self.btn_stop:setVisible(false)
        else
            self:switchStartBtnStatus(true)
        end
        self.img_stop:setVisible(true)
		self.text_freeTimes:setVisible(false)
		self.img_free:setVisible(false)
        if(self.isRun)then
			if not self.isAuto then
            	self:switchStartBtnStatus(false)
			end
            self.addBtn:setTouchEnabled(false)
			self.delBtn:setTouchEnabled(false)
			self.btn_max:setTouchEnabled(false)
        else
            self.addBtn:setTouchEnabled(true)
			self.delBtn:setTouchEnabled(true)
			self.btn_max:setTouchEnabled(true)
        end
    end
end
--初始化押注序号
function GameViewLayer:initBetIndex(totolBet)
	tlog('GameViewLayer:initBetIndex', totolBet)
	if totolBet > 0 and #self.betCfg > 0 then
		for i=1,#self.betCfg do
			if self.betCfg[i]*g_var(cmd).MAX_LINE == totolBet then
				self.betCfgIdx = i
				break
			end
		end
	end
	local max_line = g_var(cmd).MAX_LINE
	self.betCfgIdx = self._scene:getBetIndex(self.betCfg,max_line)
end  

--初始化游戏信息
function GameViewLayer:initGameOfScene(cmdData)
	tlog('GameViewLayer:initGameOfScene', cmdData.game_mode, cmdData.frees_count)
	self.nFreePlayTimes = cmdData.frees_count
    self.nFreeMax = cmdData.frees_max
    self.nCurRoundFreeCount = 0
    self.endData = cmdData
    self.endScene = cmdData.game_mode
    self.totalAward = cmdData.lFreeTotalAward
    local totolBet = cmdData.cbYaXianCount
    if #self.betCfg > 0 then
    	totolBet = self.betCfg[self.betCfgIdx]*g_var(cmd).MAX_LINE
    end
    self:initBetIndex(totolBet)
    self:updateTotalBetNum()
    self:updateDeFen()
    self:setBtnAEnable()
    self.autoCount = 0
    self:updateAutoTimes()
    self.text_userCoin._lastNum = cmdData.lScore
    self.text_userCoin._curNum = cmdData.lScore
    local serverKind = G_GameFrame:getServerKind()
    self.text_userCoin:setString(g_format:formatNumber(cmdData.lScore,g_format.fType.standard,serverKind))
    --self.text_userCoin:setString("3456789:;<")
    --初始化场景转盘数据
    self.turnedAround:initSceneRollData(cmdData)
    --奖励场景
    if self.endScene == g_var(cmd).modeType.eBonus then
        self:showJiangliPanel()
        self.lBounsWinScore = cmdData.lBounsWinScore
        self._autoSelectData = {true,true,true,true,true,true} --自动选择奖励状态
        for i=1,#cmdData.lBounsWinScore do
		    if cmdData.lBounsWinScore[i] > 0 then
		    	local bgContent = self.panel_jiangli:getChildByTag(99)
		    	local spineBonus = bgContent:getChildByTag(100+i)
		    	spineBonus:setAnimation(0, "pick", false)
		    	local bonusText = bgContent:getChildByTag(110+i)
		    	local serverKind = G_GameFrame:getServerKind()
		    	bonusText:setString(g_format:formatNumber(cmdData.lBounsWinScore[i],g_format.fType.standard,serverKind))
		    	bonusText:setVisible(true)
		    	self._autoSelectData[i] = false
		    end
	    end
        if self.nFreePlayTimes > 0 then
            self:freeBgFadeIn()
            self:showFree_anim_two()
            self:playGamebgMusic(g_var(cmd).modeType.eFree)
        else
            self:playGamebgMusic(g_var(cmd).modeType.eNormal)
        end
    elseif self.endScene == g_var(cmd).modeType.eFree then
        if self.isRun == false then
            tlog("自动开始7777")
            if self._curScene ~= g_var(cmd).modeType.eFree then
                self:setCurScene(self.endScene)
                self:freeBgFadeIn()
                self:showFree_anim_two()
                self:playGamebgMusic(g_var(cmd).modeType.eFree)
            end
            self:_autoStart()
        end
    else
        if((not self:isLuaNodeValid(self.panel_result)) and self.isRun == false and self.autoCount>0)then
        	tlog("自动开始888")
            self:_autoStart()
        end
        self:playGamebgMusic(g_var(cmd).modeType.eNormal)
    end
    self:setCurScene(self.endScene)
end
--获取默认旋转配置
function GameViewLayer:getNormalData()
	return TurnConfig.getRoundConfig(80,0)
end
--初始化中间的滚动模块
function GameViewLayer:initScrollItem()
	tlog('GameViewLayer:initScrollItem')
	self.Panel_icon:removeAllChildren()
	local turnedAround = TurnedAround:create():addTo(self.Panel_icon)
	turnedAround:setPosition(0, 0)
	--设置旋转速度
	turnedAround:setSpeedByType(1,2400)
    turnedAround:setSpeedByType(2,4000)
    self.turnedAround = turnedAround

    self.tRandPos = {} --桌面精灵坐标数组用于展示最后结果选中框和动画
    self.tAllImg = {} --所有的图标
    self.layers={} --转轮数组 长度为列数

    local panel_wh = self.Panel_icon:getContentSize()
    local randimgPosX = panel_wh.width/g_var(cmd).MAX_LS --列数
    local randimgPosY = panel_wh.height/g_var(cmd).MAX_HS --行数
    for i=1,g_var(cmd).MAX_LS do
    	self.tRandPos[i] = {}
    	for j=1,g_var(cmd).MAX_HS do
    		self.tRandPos[i][j]=cc.p(((i-1)*randimgPosX)+randimgPosX/2,((j-1)*randimgPosY)+randimgPosY/2)
    	end
    end
    --初始化旋转信息
    local normalData = self:getNormalData()
    local itemNum = {12,16,22,28,34} --不要随便改这个涉及到超级旋转圈数TurnedAround里定义的是{4,5,6,6,6}
    for i=1,g_var(cmd).MAX_LS do
    	local layer = display.newNode()
    	layer:setContentSize(cc.size(randimgPosX, panel_wh.height*(itemNum[i])))
    	layer:setPosition((i-1)*randimgPosX, 0)
    	layer:addTo(self.Panel_icon)
    	table.insert(self.layers, layer)

    	local listLenght = #normalData[i]
    	local tempOther = {}
    	local startNum = 0
    	local num = itemNum[i]*g_var(cmd).MAX_HS
    	for j=1,num do
    		local point1 = display.newSprite(string.format("#icon_%d.png",normalData[i][((j-1)%listLenght)+1]))
    		point1:setPosition(randimgPosX/2, (((j-1)+startNum)*randimgPosY)+randimgPosY/2)
    		point1:addTo(layer)
    		table.insert(tempOther, point1)
    	end
    	table.insert(self.tAllImg, tempOther)
    end
    self.turnedAround:initData(self.layers,self.tAllImg,self.tRandPos,panel_wh.height,g_var(cmd).MAX_LS,g_var(cmd).MAX_HS,self.fruitPic,
    	handler(self, self.runActionCallback), handler(self, self.superRunActionCallback))
end
--旋转动画
function GameViewLayer:runAllAction()
	tlog('GameViewLayer:runAllAction')
	--清除上轮中奖动画
	self:clearSpineBoy()

	local runType = 1
	if self.isQuick then
		runType = 2
	end
	local num = 2
    local itemId = g_var(cmd).itemType.eBoat
    local sceneNum = 0
    if self._curScene == g_var(cmd).modeType.eFree then
    	sceneNum = 1
    end
    local tCurRunTurned = TurnConfig.getRoundConfigRandom(sceneNum)

    local m_nFruitArea = self.endData.nFruitAreaDistri
    --后端返回的类型要加1
    if(m_nFruitArea[1][1]+1 ==g_var(cmd).itemType.eDiamond or m_nFruitArea[2][1]+1 ==g_var(cmd).itemType.eDiamond or m_nFruitArea[3][1]+1 ==g_var(cmd).itemType.eDiamond) then
        num = 1
        itemId = g_var(cmd).itemType.eDiamond
    end
    self.turnedAround:runAllAction(self._curScene,self.endData,tCurRunTurned,runType,itemId,num)
end
--重置旋转位置
function GameViewLayer:restartPos()
	tlog('GameViewLayer:restartPos')
	self.turnedAround:restartPos()
end
--清除上轮中奖动画
function GameViewLayer:clearSpineBoy()
	tlog('GameViewLayer:clearSpineBoy')
	if self.spineBoy then
		for k,v in pairs(self.spineBoy) do
	        if self:isLuaNodeValid(v) then
	            v:removeFromParent()
	        end
	    end
	end
end
--显示结果动画
function GameViewLayer:showEndItem(tRandPos,actionPanel)
	tlog('GameViewLayer:showEndItem')
	local nAwardItem = self.endData.nAwardItem
    local nFruitAreaDistri  = self.endData.nFruitAreaDistri
    self.showItem = self.turnedAround:getShowItem()
    local item = 0
    --清除上轮中奖动画
    self:clearSpineBoy()
    self.spineBoy = {}
    for i=1,g_var(cmd).MAX_HS do
    	for j=1,g_var(cmd).MAX_LS do
    		if nAwardItem[i][j] then
    			--后端返回的类型要加1
    			item = nFruitAreaDistri[i][j]+1
    			local spinePath = ""
    			local animationName = ""
    			if item >= g_var(cmd).itemType.ePokerTen and item <= g_var(cmd).itemType.ePokerA then
    				spinePath = "spine_effect/bjbz_symbol_1_5_ske"
    				animationName = string.format("icon_%d", item)
    			elseif item == g_var(cmd).itemType.eBird then
    				spinePath = "spine_effect/bjbz_symbol_6_ske"
    				animationName = "newAnimation"
    			elseif item == g_var(cmd).itemType.eWolf then
    				spinePath = "spine_effect/bjbz_symbol_7_ske"
    				animationName = "newAnimation"
    			elseif item == g_var(cmd).itemType.eBear then
    				spinePath = "spine_effect/bjbz_symbol_9_ske"
    				animationName = "newAnimation"
    			elseif item == g_var(cmd).itemType.eDiamond then
    				spinePath = "spine_effect/bjbz_sym_bonus_ske"
    				animationName = "Scatter"
    			elseif item == g_var(cmd).itemType.eBoat then
    				spinePath = "spine_effect/bjbz_sym_scatter_ske"
    				animationName = "symbol_scatter"
    			elseif item == g_var(cmd).itemType.eSnowGirl then
    				spinePath = "spine_effect/bjbz_symbol_11_ske"
    				animationName = "H1_X"
    			end
    			if spinePath ~= "" then
    				self.showItem[j][g_var(cmd).MAX_HS+1-i]:setVisible(false)

	    			local spineBoy = sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
				    spineBoy:addAnimation(0, animationName, true)
				    spineBoy:setPosition(tRandPos[j][g_var(cmd).MAX_HS+1-i])
				    spineBoy:addTo(actionPanel)
				    table.insert(self.spineBoy, spineBoy)
				end
				if item ~= g_var(cmd).itemType.eDiamond then  
                    self:createrKuang(actionPanel,tRandPos[j][g_var(cmd).MAX_HS+1-i])
                end
    		end
    	end
    end
end
--创建结果高亮框
function GameViewLayer:createrKuang(actionPanel,pos)
	local spinePath = "spine_effect/bjbz_win_kuang_ske"
	local spineBoy =  sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
	spineBoy:addAnimation(0, "newAnimation", true)
    spineBoy:setPosition(pos)
    spineBoy:setScale(1.1)
    spineBoy:addTo(actionPanel)
    table.insert(self.spineBoy, spineBoy)
end
--设置玩家信息
function GameViewLayer:setPlayerInfo(totalScore, winScore, isPlayerMusic)
	tlog("setPlayerInfoaaaaa222",totalScore, winScore, self._runNumType, self._curScene)
	isPlayerMusic = isPlayerMusic or true
	if self._runNumType == 0 then
		if self._curScene ==g_var(cmd).modeType.eNormal and self.endScene ==g_var(cmd).modeType.eNormal then
			self.text_userCoin._curNum = totalScore
    		self:updateGoldShow(self.text_userCoin, 0.5)
		end
		self.text_deFen._curNum = self.totalAward
		if winScore > 0 then
			self.img_defen:setVisible(false)
    		self.text_deFen_cur:setVisible(true)
    		local serverKind = G_GameFrame:getServerKind()
    		self.text_deFen_cur:setString(g_format:formatNumber(winScore,g_format.fType.standard,serverKind))
		end
		self:updateGoldShow(self.text_deFen, 0.5)
		if self.totalAward > 0 then
			g_ExternalFun.playEffect("sound_res/Level_02_C64kbps.mp3")
		end
	else
		if self.endScene ==g_var(cmd).modeType.eNormal then
			self.text_userCoin._curNum = totalScore
    		self:updateGoldShow(self.text_userCoin, 0.5)
		end
		if winScore then
			self:updateDeFen()
		end
	end
end
--旋转动画结束回调
function GameViewLayer:runActionCallback()
	tlog("GameViewLayer:runActionCallback")
	--删除超级旋转动画
	self:hideSuperAction()
	--self:updateAutoTimes()

	local nAwardItem = self.endData.nAwardItem
	local item = 0
	for i=1,g_var(cmd).MAX_HS do
    	for j=1,g_var(cmd).MAX_LS do
			if nAwardItem[i][j] then
				item = 1
				break
			end
		end
	end
    local isBig,time = self:isPlayBigWinAnim(self.endData.lAwardGold)
    if isBig then
    	--bigwin
        tickMgr:delayedCall(handler(self, self.playGoldSound), 1000)
    else
    	--滚动增加赢分
    	if self._curScene == g_var(cmd).modeType.eNormal then
    		print("setPlayerInfoaaaaa111",self.endData.lScore, self.totalAward)
            self:setPlayerInfo(self.endData.lScore,self.totalAward)--更新金币
        else
            --更新金币
            self.text_deFen._curNum = self.totalAward
			if self.endData.lAwardGold > 0 then
				self.img_defen:setVisible(false)
				self.text_deFen_cur:setVisible(true)
				local serverKind = G_GameFrame:getServerKind()
				self.text_deFen_cur:setString(g_format:formatNumber(self.endData.lAwardGold,g_format.fType.standard,serverKind))
			end
			self:updateGoldShow(self.text_deFen, 0.5)
			if self.totalAward > 0 then
				g_ExternalFun.playEffect("sound_res/Level_02_C64kbps.mp3")
			end
        end
    end
    --判断中奖
    if item==0 then
        if time==0 then
            self:_outoStartSchedule(400)
        end
    else 
        if time==0 then
            self:_outoStartSchedule(1500)
        end
        self:showEndItem(self.tRandPos,self.Panel_icon)
    end
end
--点击奖励继续按钮回调
function GameViewLayer:resultCallBack()
	tlog("GameViewLayer:resultCallBack")
	g_ExternalFun.playEffect("sound_res/clickbutton.mp3")
	--隐藏奖励面板
	self:hideJiangliPanel()
	--隐藏结果面版
	self:hideResultPanel()
	if self.isHaveFreeResult then
		self:_outoStartSchedule(1000)
	else
		local isBig,time = self:isPlayBigWinAnim(self.totalAward)
		if isBig then
			self.isRun = true
			tickMgr:delayedCall(handler(self, self.playGoldSound), 1000)
			g_ExternalFun.playEffect("sound_res/trigger_alarm1_C64kbps.mp3")
			self:switchStartBtnStatus(false)
			if self.endScene == g_var(cmd).modeType.eNormal then
				self:normllBgFadeIn()
                self:playGamebgMusic(g_var(cmd).modeType.eNormal)
			end
			self:setCurScene(self.endScene)
		else
			self:setPlayerInfo(self.endData.lScore,self.totalAward,false)
            self:_switchScene()
		end
	end
end  
--开始旋转  
function GameViewLayer:startGame()
	tlog("GameViewLayer:startGame")
    self._runNumType = 0
    self:prepareStart()
	local totalAdd = 0
	if #self.betCfg > 0 then
		totalAdd = self.betCfg[self.betCfgIdx]*g_var(cmd).MAX_LINE
	end
	EventPost:addCommond(EventPost.eventType.SPIN,"slot每次spin",1,nil,{gameId = self._scene:getGameKind(),
		roomId = GlobalUserItem.roomMark,betPrice = totalAdd
	})
	self:getParentNode():sendUserBet(self.betCfgIdx)
end
--切换自动开始状态
function GameViewLayer:_checkbox_autoEvent(type)
	tlog("GameViewLayer:_checkbox_autoEvent", type)
	if type == 1 then
		self.isAuto = true
		self:setBtnAEnable()
	    tlog("自动开始666")
	    self:_autoStart()
	elseif type == 2 then
		self.autoCount = 0 
	    self.isAuto = false
	    self:setBtnAEnable()
	end
end
--自动开始
function GameViewLayer:_autoStart()
	tlog("GameViewLayer:_autoStart", self.isRun, self.nFreePlayTimes, self.autoCount, self.isAuto)
	--判断是否可以开始
    if self.isRun then
        return
    end
    --免费开始
    if self.nFreePlayTimes>0 then
        tlog("自动开始免费");
        self._runNumType = 0
        self:prepareStart()
		EventPost:addCommond(EventPost.eventType.SPIN,"slot每次spin免费",1,nil,{gameId = self._scene:getGameKind(),
			roomId = GlobalUserItem.roomMark,betPrice = 0
		})
        self:getParentNode():sendUserBet(0)--免费的旋转
        return
    end
    --判断自动
    if self.autoCount>0 then
        --自动开始
        if self.isAuto then
            self.autoCount = self.autoCount-1 
            tlog("自动开始剩余次数=="..self.autoCount)
            self:startGame()
            self:updateAutoTimes()

            if self.autoCount <= 0 then
                --cc.mg.BlockLayer.closeBlockLayer();
            end
        else
            self:_checkbox_autoEvent(2)--取消自动
            --cc.mg.FreeRultLayer.openFreeRultLayer();
            tlog("不能自动开始1111")
        end
    else
        self:_checkbox_autoEvent(2)--取消自动
        --cc.mg.FreeRultLayer.openFreeRultLayer();
        tlog("不能自动开始2222");
    end
end
--准备重新开始
function GameViewLayer:prepareStart()
	tlog("GameViewLayer:prepareStart")
	--隐藏自动弹出菜单
	self:hideAutoPanel()

	if self._curScene == g_var(cmd).modeType.eNormal then
		self.text_deFen._lastNum = 0
		self.text_deFen._curNum = 0
		self.text_deFen:setString("0")
		self.text_deFen_cur:setString("0")
		self.img_defen:setVisible(true)
    	self.text_deFen_cur:setVisible(false)
	end
	self.turnedAround:restartPos()
end
--设置当前场景
function GameViewLayer:setCurScene(curScene)
	tlog("GameViewLayer:setCurScene", curScene)
	self._curScene = curScene
end
--自动开始任务
function GameViewLayer:_outoStartSchedule(time)
	tlog("GameViewLayer:_outoStartSchedule", time, self.isHaveFreeResult, self.nCurRoundFreeCount, self.isChange)
	self:updateAutoTimes()
	if self.isHaveFreeResult then
        --免费次数结算
        tickMgr:delayedCall(handler(self, self.setfreeDetailResult), time)
    elseif(self.nCurRoundFreeCount>0 and self.isChange==false) then
        tickMgr:delayedCall(handler(self, self.freeTimeZhongFreeTime), time)
        --self:updateAutoTimes()
    elseif self.isChange then
        tickMgr:delayedCall(handler(self, self._switchScene), time)
    else
        if(time and time>0)then
            tickMgr:delayedCall(function()
                self.isRun = false
                self:setBtnAEnable()
            end, time-100)
        else
            self.isRun = false
            self:setBtnAEnable()
        end
        tlog("自动开始111")
        tickMgr:delayedCall(handler(self, self._autoStart), time)
    end
end
--切换场景
function GameViewLayer:_switchScene()
	tlog("GameViewLayer:_switchScene", self.endScene, self.nFreePlayTimes)
	self.isChange = false
    if( self.endScene == g_var(cmd).modeType.eNormal )then
        self.isRun = false
        self:hideJiangliPanel()
        self:hideResultPanel()
        --self:updateAutoTimes()
        self:setBtnAEnable()
        tlog("自动开始222")
        self:_outoStartSchedule(0)
        self:normllBgFadeIn()
        self:playGamebgMusic(g_var(cmd).modeType.eNormal)
    elseif(self.endScene == g_var(cmd).modeType.eFree)then
        --免费场景
        self:setBtnAEnable()
        if( self.nFreePlayTimes > 0 )then
            self:showResultPanel(false)
            tlog("自动开始333", socket.gettime())
            tickMgr:delayedCall(handler(self, self.hideResultPanel), 3500)
            tickMgr:delayedCall(handler(self, self._autoStart), 4500)
            tickMgr:delayedCall(handler(self, self.showFree_anim), 3000)
            tickMgr:delayedCall(handler(self, self.showFree_anim_two), 3500)
            g_ExternalFun.playEffect("sound_res/trigger_alarm1_C64kbps.mp3")
            self:playGamebgMusic(g_var(cmd).modeType.eFree)
        else
            tlog("自动开始444"..self.nFreePlayTimes.."  "..self.nFreeMax)
            self.isRun = false
            self:_autoStart()
        end
        --self:updateAutoTimes()
        --cc.mg.BlockLayer.show_blockLayer()
    elseif(self.endScene == g_var(cmd).modeType.eBonus)then
        local spinePath = "spine_effect/bjbz_bonus_guochang_ske_3"
		local bonus_ske =  sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
		bonus_ske:setAnimation(0, "FG_BK", true)
	    bonus_ske:setPosition(display.width/2, display.height/2)
	    bonus_ske:setScale(1.44)
	    bonus_ske:addTo(self,10)
	    tickMgr:delayedCall(function()
	    	bonus_ske:removeFromParent()
		end, 1500)
        tickMgr:delayedCall(handler(self, self.showJiangliPanel), 1000)
        g_ExternalFun.playEffect("sound_res/trigger_alarm1_C64kbps.mp3")
        --cc.mg.BlockLayer.hide_blockLayer();
    end
    self:setCurScene(self.endScene)
end
--免费次数中又中了免费次数
function GameViewLayer:freeTimeZhongFreeTime()
	tlog("GameViewLayer:freeTimeZhongFreeTime")
    g_ExternalFun.playEffect("sound_res/trigger_alarm1_C64kbps.mp3")
    self:showResultPanel(false)
    --self:updateAutoTimes()
    tickMgr:delayedCall(handler(self, self.hideResultPanel), 3500)
    tlog("自动开始555")
    tickMgr:delayedCall(handler(self, self._autoStart), 4500)
    self.isRun = false
    self:setBtnAEnable()
end
--免费场景淡入
function GameViewLayer:freeBgFadeIn()
	tlog("GameViewLayer:freeBgFadeIn")
	local actionIn = cc.FadeIn:create(0.2)
    self.freeBg:runAction(actionIn)
    local actionOut = cc.FadeOut:create(0.2)
    self.normalBg:runAction(actionOut)
end
--普通场景淡入
function GameViewLayer:normllBgFadeIn()
	tlog("GameViewLayer:normllBgFadeIn", self._isHideFGAnim)
	local actionIn = cc.FadeIn:create(0.2)
    self.normalBg:runAction(actionIn)

    local actionOut = cc.FadeOut:create(0.2)
    self.freeBg:runAction(actionOut)
    
    --如果从免费场景切换到正常场景 隐藏光效
    if self._isHideFGAnim then
    	if self:isLuaNodeValid(self.freegameTwo_ske) then
	        self.freegameTwo_ske:setAnimation(0, "end", false)
	        tickMgr:delayedCall(function()
	        	self.freegameTwo_ske:removeFromParent()
	        	self.freegameTwo_ske = nil
	    	end, 800)
	    end
        self._isHideFGAnim = false
    end
end
--免费游戏过场动画
function GameViewLayer:showFree_anim()
	tlog("GameViewLayer:showFree_anim")
	tickMgr:delayedCall(handler(self, self.freeBgFadeIn), 500)
	local spinePath = "spine_effect/bjbz_freegame_guochang_ske"
	local freegame_ske =  sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
	freegame_ske:setAnimation(0, "JP_XH_B", false)
    freegame_ske:setPosition(display.width/2, display.height/2)
    freegame_ske:setScale(1.44)
    freegame_ske:addTo(self,10)
    tickMgr:delayedCall(function()
    	freegame_ske:removeFromParent()
	end, 1500)
end
--免费游戏动画创建
function GameViewLayer:showFree_anim_two()
	tlog("GameViewLayer:showFree_anim_two")
	self.isRun = false
    self._isHideFGAnim  = true
    if not self:isLuaNodeValid(self.freegameTwo_ske) then
	    local spinePath = "spine_effect/bjbz_fg_effect_ske_1"
		local freegameTwo_ske =  sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
	    freegameTwo_ske:setPosition(display.width/2, display.height/2)
	    freegameTwo_ske:setScale(1.44)
	    freegameTwo_ske:addTo(self,10)
		self.freegameTwo_ske = freegameTwo_ske
	    self.freegameTwo_ske:setAnimation(0, "begin", true)
	end
    tickMgr:delayedCall(handler(self, self.showFree_anim_Three), 1800)
end
--免费游戏动画切待机
function GameViewLayer:showFree_anim_Three()
	tlog("GameViewLayer:showFree_anim_Three")
	self.freegameTwo_ske:setAnimation(0, "idle", true)
end
--bigwin开始动画
function GameViewLayer:show_bigwin_ani()
	tlog("GameViewLayer:show_bigwin_ani", self.animName)
	if self:isLuaNodeValid(self.xn_bigwin_ske) then
		if("binwin" == self.animName)then
	        self.xn_bigwin_ske:setAnimation(0, "bigwin_start", false)
	    elseif("superwin" == self.animName)then
	        self.xn_bigwin_ske:setAnimation(0, "superwin_start", false)
	        tickMgr:delayedCall(handler(self, self.showSuperWinP), 3000)
	    elseif("megawin" == self.animName)then
	        self.xn_bigwin_ske:setAnimation(0, "megawin_start", false)
	        tickMgr:delayedCall(handler(self, self.showSuperWinP), 2000)
	        tickMgr:delayedCall(handler(self, self.showMegaWinP), 5000)
	    end
    end
end
--bigwin待机动画
function GameViewLayer:show_bigwin_ani_idle()
	tlog("GameViewLayer:show_bigwin_ani_idle", self.animName)
	if self:isLuaNodeValid(self.xn_bigwin_ske) then
	    if("binwin" == self.animName)then
	        self.xn_bigwin_ske:setAnimation(0, "bigwin_idle", true)
	    elseif("superwin" == self.animName)then
	        self:showSuperWinP()
	        self.xn_bigwin_ske:setAnimation(0, "superwin_idle", true)
	    elseif("megawin" == self.animName)then
	        self.xn_bigwin_ske:setAnimation(0, "megawin_idle", true)
	        self:showSuperWinP()
	        self:showMegaWinP()
	    end
	end
end
--点击奖励返回
function GameViewLayer:kernelBtnBack(cmdData)
	tlog("GameViewLayer:kernelBtnBack", cmdData.nHitPos)
	local selectBounsIdx = cmdData.nHitPos + 1 --选择水晶序号从0开始
	local danzhu = 0
	if #self.betCfg > 0 then
		danzhu = self.betCfg[self.betCfgIdx]
	end
	self.lBounsWinScore[selectBounsIdx] = cmdData.nAwardMultiply--*danzhu
    if(selectBounsIdx)then
        local bgContent = self.panel_jiangli:getChildByTag(99) 
        local spineBonus = bgContent:getChildByTag(100+selectBounsIdx)
		spineBonus:setAnimation(0, "pick", false)
		local bonusText = bgContent:getChildByTag(110+selectBounsIdx)
    	local serverKind = G_GameFrame:getServerKind()
    	bonusText:setString(g_format:formatNumber(self.lBounsWinScore[selectBounsIdx],g_format.fType.standard,serverKind))
    	bonusText:setVisible(true)
    end
end
--奖励总结算
function GameViewLayer:kernelBtnEndBack(cmdData)
	tlog("GameViewLayer:kernelBtnEndBack", cmdData.lWinScore3, self.nFreePlayTimes)
	local unOpenWinScore = {}
	for i=1,#self.lBounsWinScore do
		if self.lBounsWinScore[i] <= 0 then
			table.insert(unOpenWinScore, i)
		end
	end
	self.lBounsWinScore = clone(cmdData.lBounsMultiply)
	local danzhu = 0
	if #self.betCfg > 0 then
		danzhu = self.betCfg[self.betCfgIdx]
	end
	for i=1,#self.lBounsWinScore do
		self.lBounsWinScore[i] = self.lBounsWinScore[i]--*danzhu
		local bgContent = self.panel_jiangli:getChildByTag(99)
    	local bonusText = bgContent:getChildByTag(110+i)
    	local serverKind = G_GameFrame:getServerKind()
    	bonusText:setString(g_format:formatNumber(self.lBounsWinScore[i],g_format.fType.standard,serverKind))
    	bonusText:setVisible(true)
	end
	self.lBounsWinScore ={0,0,0,0,0,0}
	--打开未开的水晶
	for i=1,#unOpenWinScore do
		local bgContent = self.panel_jiangli:getChildByTag(99)
		local spineBonus = bgContent:getChildByTag(100+unOpenWinScore[i])
		--spineBonus:setAnimation(0, "pick", false)
		spineBonus:setOpacity(180)
	end

    self.lWinScore3 = cmdData.lWinScore3
    tickMgr:delayedCall(function()
        self._runNumType = 1
        if self.nFreePlayTimes > 0 then
	    	self.endScene = g_var(cmd).modeType.eFree
	    else
	    	self.endScene = g_var(cmd).modeType.eNormal
	    end
        self:setJiangliResult()
    end, 2000)
    --this.lUserTotalScore = goldEggEnd.lUserGold.value
end
--免费次数总结算 使用奖励相同界面
function GameViewLayer:setfreeDetailResult()
	tlog("GameViewLayer:setfreeDetailResult")
	self.isHaveFreeResult = false
    --this.lUserTotalScore = xn_manager.Manager.gameDataManager.freeResultData.lUserGold.value
    self._runNumType = 1
    self:setJiangliResult()
end
--奖励结果结算
function GameViewLayer:setJiangliResult()
	tlog("GameViewLayer:setJiangliResult")
	self:showResultPanel(true)
end
--判断已选择奖励数量
function GameViewLayer:canBounsSelect()
	tlog("GameViewLayer:canBounsSelect")
	local canSelect = true
	local selectCount = 0
	for k,v in pairs(self._autoSelectData) do
		if not v then
			selectCount = selectCount + 1
			if selectCount >= g_var(cmd).BONUS_MAX then
				canSelect = false
				break
			end
		end
	end
	return canSelect
end
--自动选择奖励
function GameViewLayer:autoSelect()
	tlog("GameViewLayer:autoSelect")
	local indexTb = {1,2,3,4,5,6}
	for i=#indexTb,1,-1 do
		if not self._autoSelectData[i] then
			table.remove(indexTb, i)
		end
	end
	if #indexTb > g_var(cmd).BONUS_MAX then
		local selectIdx = math.random(1,#indexTb)
		self:getParentNode():sendBounsSelect(indexTb[selectIdx]-1) --选择水晶序号从0开始
		self._autoSelectData[indexTb[selectIdx]] = false
	end
end
--展示奖励界面
function GameViewLayer:showJiangliPanel()
	tlog("GameViewLayer:showJiangliPanel")
	self.isRun = false
	self:setBtnAEnable()
	if not self:isLuaNodeValid(self.panel_jiangli) then
		local bgLayer = display.newLayer()
		bgLayer:addTo(self,10)
		bgLayer:enableClick()
		self.panel_jiangli = bgLayer

		local bgContent = ccui.Layout:create()
        bgContent:setContentSize(cc.size(0, 0))
        bgContent:setPosition(display.width/2, display.height/2)
        bgContent:setScale(1.44)
	    bgContent:addTo(bgLayer,0, 99)
		local bgSp = display.newSprite("GUI/bg_jiangli.png")
		bgSp:addTo(bgContent)
		local spinePath = "spine_effect/bjbz_game_queen_ske"
		local spineBoy =  sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
		spineBoy:addAnimation(0, "H1_X", true)
	    spineBoy:setPosition(0, 0)
	    spineBoy:addTo(bgContent)

	    bgLayer:setOpacity(0)
	    local posTb = {cc.p(-400,-230), cc.p(-280,-80), cc.p(-180,-260), cc.p(180,-260), cc.p(280,-80), cc.p(400,-230)}
	    for i=1,#posTb do
	    	local spinePath = "spine_effect/bjbz_game_shuijing_ske"
			local spineBonus =  sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
			spineBonus:addAnimation(0, "idle", true)
		    spineBonus:setPosition(posTb[i])
		    spineBonus:addTo(bgContent,0,100+i)
		    if i >= 4 then
		    	spineBonus:setRotation3D(cc.vec3(0, 180, 0))
		    end

		    --local bonusText = ccui.Text:create("0","fonts/round_body.ttf",30)
		    local bonusText = cc.LabelBMFont:create("0", "GUI/num_pic/shuijingfenshu.fnt")
		    bonusText:setPosition(posTb[i])
		    bonusText:addTo(bgContent,0,110+i)
		    bonusText:setVisible(false)

		    local uiWidget = ccui.Widget:create()
	        uiWidget:setPosition(posTb[i])
	        uiWidget:setContentSize(cc.size(100,200))
	        uiWidget:addTo(bgContent,0,200+i)
	        uiWidget:setTouchEnabled(true)
	        uiWidget:addClickEventListener(function()
	        	if self._autoSelectData[i] then
	        		if self:canBounsSelect() then
			        	--选择水晶序号从0开始
			        	self:getParentNode():sendBounsSelect(i-1)
			        	self._autoSelectData[i] = false

			        	self.auto_select_num = self.auto_select_num + 1
			        	self:schedulerStart()
			        end
		        end
	    	end)
	    end
	    local action = cc.FadeIn:create(0.2)
	    bgLayer:runAction(action)

	    self.auto_select_num = 0 --重置点击次数
	    self:schedulerStart()
	    --自动选择
--[[	    bgContent:executeDelay(function ( ... )
            self:autoSelect()
        end, 3.0)--]]
        -- bgContent:runAction(cc.Sequence:create(
        -- 	cc.DelayTime:create(3.0),
        --     cc.CallFunc:create(function ( ... )
        --         self:autoSelect()
        --     end),
        --     cc.DelayTime:create(3.0),
        --     cc.CallFunc:create(function ( ... )
        --         self:autoSelect()
        --     end),
        --     cc.DelayTime:create(3.0),
        --     cc.CallFunc:create(function ( ... )
        --         self:autoSelect()
        --     end)
        -- ))
	end
end

function GameViewLayer:schedulerStart()
	self:scheduleStop()
	self.schedulerID = g_scheduler:scheduleScriptFunc( function()
        self:schedulerStep()
    end , 3, false)
    print(self.schedulerID)
end

function GameViewLayer:schedulerStep()
	self.auto_select_num = self.auto_select_num + 1
	if self.auto_select_num > 3 or not self:canBounsSelect() then
		self:scheduleStop()
	else
		self:autoSelect()
	end
end

function GameViewLayer:scheduleStop()
	if self.schedulerID then
        g_scheduler:unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end
end

--隐藏展示界面
function GameViewLayer:hideJiangliPanel()
	tlog("GameViewLayer:hideJiangliPanel")
	if self:isLuaNodeValid(self.panel_jiangli) then
		self._autoSelectData = {true,true,true,true,true,true} --自动选择奖励状态
		self.panel_jiangli:removeFromParent()
	end
end
--展示奖励或免费结果界面或免费次数提醒界面
function GameViewLayer:showResultPanel(isJiangLi)
	tlog("showResultPanel111", isJiangLi)
	if not self:isLuaNodeValid(self.panel_result) then
		tlog("showResultPanel222", isJiangLi)
		local bgLayer = display.newLayer()
		bgLayer:addTo(self,10)
		self.panel_result = bgLayer

		local csbNode = cc.CSLoader:createNode("UI/JiangLiResultNode.csb")
		csbNode:addTo(bgLayer)
		csbNode:setPosition(display.width/2, display.height/2)
		local panel_jiangliResult = csbNode:getChildByName("Panel_1"):getChildByName("panel_jiangliResult")
		local panel_free = csbNode:getChildByName("Panel_1"):getChildByName("panel_free")
		panel_jiangliResult:setVisible(false)
		panel_free:setVisible(false)
		if isJiangLi then
			panel_jiangliResult:setVisible(true)
			local Image_free = panel_jiangliResult:getChildByName("Image_free")
			local Image_bonus = panel_jiangliResult:getChildByName("Image_bonus")
			Image_free:setVisible(false)
			Image_bonus:setVisible(false)
			local winScore = 0
			if self._curScene== g_var(cmd).modeType.eBonus then
				Image_bonus:setVisible(true)
				winScore = self.lWinScore3
			else
				Image_free:setVisible(true)
				winScore = self.totalAward
			end

			local _nodeText = panel_jiangliResult:getChildByName("bmlb_win")
			_nodeText:setString("0")
			_nodeText._lastNum = 0
			_nodeText._curNum = winScore
			self:updateGoldShow(_nodeText, 0.5)

			bgLayer:enableClick(function()
				_nodeText:stopAllActions()
				local serverKind = G_GameFrame:getServerKind()
				_nodeText:setString(g_format:formatNumber(_nodeText._curNum,g_format.fType.standard,serverKind))
			end)
			local btn_continue = panel_jiangliResult:getChildByName("btn_continue")
			btn_continue:addClickEventListener(function(_sender)
				self:resultCallBack()
		        self:hideResultPanel()
		    end)
		    --自动关闭结果面板
		    panel_jiangliResult:executeDelay(function ( ... )
	            self:resultCallBack()
	        end, 4.5)
		else
			tlog("showResultPanel333", isJiangLi, self.nCurRoundFreeCount)
			panel_free:setVisible(true)
			local bmlb_free = panel_free:getChildByName("bmlb_free")
			bmlb_free:setString(self.nCurRoundFreeCount)
			bgLayer:enableClick(function()
				self:hideResultPanel()
			end)
		end
	end
end
--隐藏奖励或免费结果界面
function GameViewLayer:hideResultPanel()
	tlog("hideResultPanel111")
	if self:isLuaNodeValid(self.panel_result) then
		self.panel_result:removeFromParent()
		self.panel_result = nil
	end
end
--弹出自动选择次数界面
function GameViewLayer:showAutoPanel()
	tlog("showAutoPanel")
	if not self:isLuaNodeValid(self.Panel_Auto) then
		local bgLayer = display.newLayer()
		bgLayer:addTo(self,10)
		self.Panel_Auto = bgLayer

		local csbNode = cc.CSLoader:createNode("UI/AutoSelectNode.csb")
		csbNode:addTo(bgLayer)
		csbNode:setPosition(display.width/2+636, display.height/2-126)
		
		bgLayer:enableClick(function()
			bgLayer:removeFromParent()
		end)
		local btn_10 = csbNode:getChildByName("Panel_1"):getChildByName("btn_10")
		btn_10:addClickEventListener(function(_sender)
	        self.autoCount = 10
            self:_checkbox_autoEvent(1)
	    end)
	    local btn_30 = csbNode:getChildByName("Panel_1"):getChildByName("btn_30")
		btn_30:addClickEventListener(function(_sender)
	        self.autoCount = 30
            self:_checkbox_autoEvent(1)
	    end)
	    local btn_50 = csbNode:getChildByName("Panel_1"):getChildByName("btn_50")
		btn_50:addClickEventListener(function(_sender)
	        self.autoCount = 50
            self:_checkbox_autoEvent(1)
	    end)
	    local btn_100 = csbNode:getChildByName("Panel_1"):getChildByName("btn_100")
		btn_100:addClickEventListener(function(_sender)
	        self.autoCount = 100
            self:_checkbox_autoEvent(1)
	    end)
	    local btn_max = csbNode:getChildByName("Panel_1"):getChildByName("btn_∞")
		btn_max:addClickEventListener(function(_sender)
	        self.autoCount = 10000
            self:_checkbox_autoEvent(1)
	    end)
	end
end
--隐藏自动选择次数界面
function GameViewLayer:hideAutoPanel()
	tlog("hideAutoPanel")
	if self:isLuaNodeValid(self.Panel_Auto) then
		self.Panel_Auto:removeFromParent()
	end
end
--展示bigwin界面
function GameViewLayer:showBinWinPanel()
	tlog("showBinWinPanel")
	if not self:isLuaNodeValid(self.Panel_BigWin) then
		local bgLayer = display.newLayer()
		bgLayer:addTo(self,10)
		self.Panel_BigWin = bgLayer

		local spinePath = "spine_effect/slots_bigwin_ske"
		local spineBoy =  sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
	    spineBoy:setPosition(display.width/2, display.height/2)
	    spineBoy:addTo(bgLayer, 1)
	    --spineBoy:setTimeScale(2.0)
	    self.xn_bigwin_ske = spineBoy

	    --粒子
	    local particle1 = cc.ParticleSystemQuad:create("GUI/particle/lz_pjb4.plist")
	    particle1:setPosition(display.width/2, display.height/2-700)
	    --particle1:setPositionType(cc.POSITION_TYPE_GROUPED)
	    particle1:addTo(bgLayer)
	    particle1:setAutoRemoveOnFinish(true)

	    spineBoy:registerSpineEventHandler( function( event )
	    	if event.type == "complete" then
		        if event.animation == "bigwin_start" then
		            spineBoy:setAnimation( 0, "bigwin_idle", true)
		        elseif event.animation == "superwin_start" then
		            spineBoy:setAnimation( 0, "superwin_idle", true)
		        elseif event.animation == "megawin_start" then
		            spineBoy:setAnimation( 0, "megawin_idle", true)     
		        end
		    end
	    end, sp.EventType.ANIMATION_COMPLETE)--sp.EventType.ANIMATION_EVENT )

	    --local bigText = ccui.Text:create("0","fonts/round_body.ttf",50)
	    -- local bigText = ccui.TextAtlas:create("0", "GUI/bigwin.png", 46, 75, ".")
		local bigText = ccui.TextBMFont:create()
		bigText:setFntFile("GUI/bigwin.fnt")
		bigText:setString("0")
	    bigText:setPosition(display.width/2, display.height/2-172)
	    bigText:setTag(21)
	    bigText:addTo(bgLayer, 1)

	    local collectBtn = ccui.Button:create("GUI/btn_collect.png")
	    collectBtn:setPosition(cc.p(display.width/2,270))
	    collectBtn:setTag(22)
	    collectBtn:addTo(bgLayer, 1)
	    collectBtn:addClickEventListener(function (sender)
	    	g_ExternalFun.playEffect("sound_res/Btn_Select.mp3")
            self:bigWinEnd()
        end)
        collectBtn:setVisible(false)
        --数字滚动
        bigText:setString("0")
		bigText._lastNum = 0
		bigText._curNum = self.totalAward
		local goldTime = 0.5
		if self.animtime > 2 then
			goldTime = (self.animtime-2)*2/3 --*2/3是因为0.05秒滚动一次，比帧率间隔要大
		end
		self:updateGoldShow(bigText, goldTime)

		local animNode = display.newNode()
		animNode:addTo(bgLayer)
		--自动切换动画
	    bgLayer:executeDelay(function ( ... )
            --self:show_bigwin_ani_idle()
			collectBtn:setVisible(true)
			animNode:executeDelay(handler(self, self.bigWinEnd), self.animtime + 2.0)
        end, 1.0)
        bgLayer:enableClick(function()
        	bgLayer:stopAllActions()
			bigText:stopAllActions()
			bigText:setString(g_format:formatNumber(bigText._curNum,g_format.fType.standard))
			self:show_bigwin_ani_idle()
			collectBtn:setVisible(true)
			animNode:executeDelay(handler(self, self.bigWinEnd), 5.0)
		end)
	end

    self:show_bigwin_ani()

    --this.bigWinParticle[2].active = false
    --this.bigWinParticle[3].active = false
    --this.bigWinParticle[4].active = false
    --this.bigWinParticle[5].active = false
end 
--隐藏bigwin界面
function GameViewLayer:hideBinWinPanel()
	tlog("hideBinWinPanel")
	if self:isLuaNodeValid(self.Panel_BigWin) then
		self.Panel_BigWin:removeFromParent()
	end
end
--bigWin展示结束
function GameViewLayer:bigWinEnd()
	tlog("GameViewLayer:bigWinEnd", self.isChange, self._curScene)
	self:setPlayerInfo(self.endData.lScore,self.totalAward,false)
	self:hideBinWinPanel()
	self:_outoStartSchedule(500)
	if self.isChange == false then
		if(self._curScene == g_var(cmd).modeType.eNormal)then
            self:playGamebgMusic(g_var(cmd).modeType.eNormal)
        elseif(self._curScene == g_var(cmd).modeType.eFree) then
            self:playGamebgMusic(g_var(cmd).modeType.eFree)
        end
	end
end
--bigWin粒子
function GameViewLayer:showSuperWinP()
	tlog("GameViewLayer:showSuperWinP")
	if self:isLuaNodeValid(self.Panel_BigWin) then
		if not self.Panel_BigWin:getChildByTag(102) then
			local particle2Bg = display.newNode()
		    particle2Bg:setPosition(display.width/2, display.height/2-700)
		    particle2Bg:addTo(self.Panel_BigWin,0,102)
		    local particle21 = cc.ParticleSystemQuad:create("GUI/particle/lz_pzs5.plist")
		    particle21:setPosition(0, 0)
		    particle21:addTo(particle2Bg)
		    particle21:setAutoRemoveOnFinish(true)
		    local particle22 = cc.ParticleSystemQuad:create("GUI/particle/lz_pzs3.plist")
		    particle22:setPosition(0, 0)
		    particle22:addTo(particle2Bg)
		    particle22:setAutoRemoveOnFinish(true)
		end
    end
end
--bigWin粒子
function GameViewLayer:showMegaWinP()
	tlog("GameViewLayer:showMegaWinP")
	if self:isLuaNodeValid(self.Panel_BigWin) then
		if not self.Panel_BigWin:getChildByTag(103) then
			local particle3Bg = display.newNode()
		    particle3Bg:setPosition(display.width/2, display.height/2-700)
		    particle3Bg:addTo(self.Panel_BigWin,0,103)
		    local particle31 = cc.ParticleSystemQuad:create("GUI/particle/lz_pzs4.plist")
		    particle31:setPosition(0, 0)
		    particle31:addTo(particle3Bg)
		    particle31:setAutoRemoveOnFinish(true)
		    local particle32 = cc.ParticleSystemQuad:create("GUI/particle/lz_pzs4.plist")
		    particle32:setPosition(0, 0)
		    particle32:addTo(particle3Bg)
		    particle32:setRotation3D(cc.vec3(0, 180, 0))
		    particle32:setAutoRemoveOnFinish(true)
		    --[[particle3Bg:hide()
		    particle3Bg:executeDelay(function ( ... )
				particle3Bg:setVisible(true)
	        end, 6.0)--]]
	    end
	end
end
--格式化数字展示
function GameViewLayer:formatNumShow(_node, _nums)
	--tlog("GameViewLayer:formatNumShow", _nums)
	local serverKind = G_GameFrame:getServerKind()
	local formatMoney = g_format:formatNumber(_nums,g_format.fType.standard,serverKind)
	_node:setString(formatMoney)
end
--跑数字动画的方式更新文字
function GameViewLayer:updateGoldShow(_nodeText, time)
    tlog("GameViewLayer:updateGoldShow", time)
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
function GameViewLayer:addGoldNumsShowInterval(_node, _srcNums, _dstNums, _addNums)
	-- tlog('GameViewLayer:addGoldNumsShowInterval')
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
--是否需要显示bigwin
function GameViewLayer:isPlayBigWinAnim(score)
	tlog("GameViewLayer:isPlayBigWinAnim", score, self.isChange, self._curScene, self.endScene)
	local totalAdd = 0
	if #self.betCfg > 0 then
		totalAdd = self.betCfg[self.betCfgIdx]*g_var(cmd).MAX_LINE
	end
	local isHaveAnim = false
    local time = 0
    local beishu = score / totalAdd
    if (self.isChange and self.endScene == g_var(cmd).modeType.eFree)
    	or (self._curScene == g_var(cmd).modeType.eFree and self.endScene == g_var(cmd).modeType.eFree)
    	or self.isHaveFreeResult then
    else
    	if beishu < 10 then
	    elseif beishu >= 10 and beishu < 50 then
	    	isHaveAnim = true
	        time = 8
	    elseif beishu >= 50 and beishu < 100 then
	    	isHaveAnim = true
	        time = 10
	    else
	    	isHaveAnim = true
	        time=12
	    end
    end
    tlog("GameViewLayer:isPlayBigWinAnim2", isHaveAnim, time)
    return isHaveAnim, time
end
--大倍数表现
function GameViewLayer:playGoldSound()
	tlog("GameViewLayer:playGoldSound", self.totalAward, self.endData.lAwardGold)
	local isHaveAnim = false
	local totalAdd = 0
	if #self.betCfg > 0 then
		totalAdd = self.betCfg[self.betCfgIdx]*g_var(cmd).MAX_LINE
	end
    local beishu = self.totalAward/totalAdd
    self.animName=""
    self.animtime = 0
    if beishu < 10 then
    elseif beishu >= 10 and beishu < 50 then
    	isHaveAnim = true
        self.animName = "binwin"
        self.animtime = 8
        g_ExternalFun.playEffect("sound_res/Level_09_C64kbps.mp3")
    elseif beishu >= 50 and beishu < 100 then
    	isHaveAnim = true
        self.animName = "superwin"
        self.animtime = 10
        g_ExternalFun.playEffect("sound_res/Level_13_C64kbps.mp3")
    else
    	isHaveAnim = true
        self.animName = "megawin"
        self.animtime=12
        g_ExternalFun.playEffect("sound_res/Level_14_C64kbps.mp3")
    end
    if isHaveAnim then
    	g_ExternalFun.stopMusic()
    	self:showBinWinPanel()
    end
    return isHaveAnim
end
--超级旋转回调（播放速度动画）
function GameViewLayer:superRunActionCallback(idx)
	tlog("GameViewLayer:superRunActionCallback", idx)
	local panel_wh = self.Panel_icon:getContentSize()
    local randimgPosX = panel_wh.width/g_var(cmd).MAX_LS --列数
	local spinePath = "spine_effect/bjbz_speed_ske"
	if idx < g_var(cmd).MAX_LS then
		if not self:isLuaNodeValid(self.spineSpeed[idx+1]) then
			local spineBoy =  sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
			spineBoy:addAnimation(0, "speed", true)
		    spineBoy:setPosition((idx)*randimgPosX+randimgPosX/2, panel_wh.height/2-12)
		    spineBoy:addTo(self.Panel_icon)
		    self.spineSpeed[idx+1] = spineBoy
		    g_ExternalFun.playEffect("sound_res/prewin_C64kbps.mp3")
		end
		if self:isLuaNodeValid(self.spineSpeed[idx]) then
			self.spineSpeed[idx]:removeFromParent()
			self.spineSpeed[idx] = nil
		end
	end
end
--删除超级旋转动画
function GameViewLayer:hideSuperAction()
	tlog("GameViewLayer:hideSuperAction")
	for k,v in pairs(self.spineSpeed) do
        if self:isLuaNodeValid(v) then
            v:removeFromParent()
        end
    end
    self.spineSpeed = {}
end

function GameViewLayer:onExit()
	tlog('GameViewLayer:onExit')
	self:gameDataReset()

	self:scheduleStop()
	if self.listener ~= nil then
		self:getEventDispatcher():removeEventListener(self.listener)
	end
end
---------------------------------------------------------------------------------------
--网络消息
--网络接收
function GameViewLayer:onGetUserScore(item)
	tlog('GameViewLayer:onGetUserScore ', item.dwUserID, GlobalUserItem.dwUserID)
	--自己
	if not self.m_gameEndActionTime then
		if item.dwUserID == GlobalUserItem.dwUserID then
	        self:reSetUserInfo()
	    end
	end
end

--更新左侧展示中线数量测试用
function GameViewLayer:updateTestLine(cmdData)
	for i=1,#cmdData.zJLineArray do
	    if self.testLbs[i] then
	    	self.testLbs[i]:setString(cmdData.zJLineArray[i])
	    	if cmdData.zJLineArray[i] > 0 then
	    		self.testLbs[i]:setTextColor(cc.c3b(0,255,0))
	    	else
	    		self.testLbs[i]:setTextColor(cc.c3b(255,255,255))
	    	end
	    end
	end
end
--网络旋转消息过来
function GameViewLayer:startRoll(cmdData)
	tlog("GameViewLayer:startRoll", cmdData.game_mode, cmdData.frees_count, self._curScene)
	--testcode
	-- self:updateTestLine(cmdData)

	self.endData.nFruitAreaDistri = cmdData.nFruitAreaDistri
	self.endData.nAwardItem = cmdData.nAwardItem
	self.endData.lAwardGold = cmdData.lAwardGold
	self.endData.lScore = cmdData.lScore
	self.nFreePlayTimes = cmdData.frees_count
	self.nFreeMax = cmdData.frees_max
    self.nCurRoundFreeCount = cmdData.frees_cur
    if self._curScene == g_var(cmd).modeType.eFree then
	    self.totalAward = self.totalAward + cmdData.lAwardGold
	else
		self.totalAward = cmdData.lAwardGold
	end
    if cmdData.game_mode == g_var(cmd).modeType.eBonus then
    	self.sceneBefore = self._curScene
    elseif cmdData.game_mode == g_var(cmd).modeType.eNormal then
    	if self._curScene == g_var(cmd).modeType.eFree then
	    	self.isHaveFreeResult = true
	    end
    end
    self.endScene = cmdData.game_mode
    if self.endScene ~= self._curScene then
    	self.isChange = true
    end

    self.isRun = true
    self:setBtnAEnable()
    self:runAllAction()
end
--网络下注配置消息过来
function GameViewLayer:onBetConfigUpdate(cmdData)
	tlog("GameViewLayer:onBetConfigUpdate")
	self.betCfg = cmdData.betArray
    self:initBetIndex(0)
    self:updateTotalBetNum()
end
--网络小玛利选择序号消息过来
function GameViewLayer:onSubHitGoldeggResp(cmdData)
	tlog("GameViewLayer:onSubHitGoldeggResp")
	if cmdData.nResult == 0 then
		self:kernelBtnBack(cmdData)
	end
end
--网络小玛利结算消息过来
function GameViewLayer:onSubHitGoldeggDetail(cmdData)
	tlog("GameViewLayer:onSubHitGoldeggDetail", self.sceneBefore)
	self.totalAward = self.totalAward + cmdData.lWinScore3
	self.endData.lScore = self.endData.lScore + cmdData.lWinScore3
    --self.endScene = self.sceneBefore
    --self.isChange = true
	
	tickMgr:delayedCall(function()
        self:kernelBtnEndBack(cmdData)
    end, 1200)
end
---------------------------------------------------------------------------------------
function GameViewLayer:getParentNode()
	return self._scene
end

function GameViewLayer:getMeUserItem()
	if nil ~= GlobalUserItem.dwUserID then
		return self:getDataMgr():getUidUserList()[GlobalUserItem.dwUserID]
	end
	return nil
end

function GameViewLayer:isMeChair( wchair )
	local useritem = self:getDataMgr():getChairUserList()[wchair + 1]
	if nil == useritem then
		return false
	else 
		return useritem.dwUserID == GlobalUserItem.dwUserID
	end
end

function GameViewLayer:getDataMgr()
	return self:getParentNode():getDataMgr()
end

function GameViewLayer:logData(msg)
	local p = self:getParentNode()
	if nil ~= p.logData then
		p:logData(msg)
	end
end

function GameViewLayer:gameDataReset()
	tlog('GameViewLayer:gameDataReset')
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	--播放大厅背景音乐
	g_ExternalFun.stopAllEffects()
	self:getDataMgr():removeAllUser()
end

function GameViewLayer:updateClock(tag, left)
	tlog('GameViewLayer:updateClock ', tag, left)
	local str = string.format("%02d", left)
    if tag == g_var(cmd).kGAMEPLAY_COUNTDOWN then --下注倒计时
        if left == 3 then
			--g_ExternalFun.playSoundEffect("double_3_countdown.mp3")
        end
	end
end
------------------------------------------------------------------------------
function GameViewLayer:isLuaNodeValid(node)
    return(node and not tolua.isnull(node))
end
--注册按钮监听
function GameViewLayer:registerBtnEvent(_btnNode, _callBack, _pressAct, _delayTime)
	tlog('GameViewLayer:registerBtnEvent')
    if _pressAct == nil then
        _pressAct = true
    end
    if _delayTime == nil then
    	_delayTime = 0.5
    end
    tlog("_pressAct is ", _pressAct)
    _btnNode.isTouch = 1
    _btnNode:setPressedActionEnabled(_pressAct)
    _btnNode:addClickEventListener(function(_sender)
        if _btnNode.isTouch == 1 then
            _btnNode.isTouch = 2
            _btnNode:runAction(
                cc.Sequence:create(
                cc.CallFunc:create(function ( ... )
                    if _callBack then
                        _callBack(_sender)
                    end
                end),
                cc.DelayTime:create(_delayTime),
                cc.CallFunc:create(function ( ... )
                    _btnNode.isTouch  = 1
                end)
            ))
        end
    end)
end

function GameViewLayer:registerTouch()
	tlog('GameViewLayer:registerTouch')
	local function onTouchBegan( touch, event )
		return true
	end

	local function onTouchEnded( touch, event )
		tlog('onTouchEnded')
		if self.m_btnList:isVisible() then
			local pos = self.m_btnList:convertToNodeSpace(touch:getLocation())
			tlog('pos is ', pos.x, pos.y)
	        local rec = cc.rect(0, 0, self.m_btnList:getContentSize().width, self.m_btnList:getContentSize().height)
	        tdump(rec, "rec")
	        if not cc.rectContainsPoint(rec, pos) then
	            self.m_btnList:setVisible(false)
	        end
	    end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	self.listener = listener
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function GameViewLayer:playGamebgMusic(_type)
    if self.m_bgMusicType == _type then
        return
    end
    self.m_bgMusicType = _type
    local musicPath = ""
    if _type == g_var(cmd).modeType.eFree then
        musicPath = "sound_res/reels_freegame_10_v01_C64kbps.mp3"
    else
        musicPath = "sound_res/reel_maingame_10_v04_C64kbps.mp3"
    end
    tlog('CarnivalViewLayer:playGamebgMusic ', _type, musicPath)
    g_ExternalFun.stopMusic()
    g_ExternalFun.playMusic(musicPath, true)
end

return GameViewLayer