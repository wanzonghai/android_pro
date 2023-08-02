local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
local module_pre = "game.yule.jdob.src"
local HeadNode = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.HeadNode")
local ObjectPool = appdf.req(appdf.CLIENT_SRC.."Tools.ObjectPool")				--对象池
local g_var = g_ExternalFun.req_var
local cmd = module_pre .. ".models.CMD_Game"
local GameHelpLayer = appdf.req(module_pre .. ".views.layer.GameHelpLayer")
local JdobHistorylLayer = appdf.req(module_pre .. ".views.layer.JdobHistorylLayer")
local JdobPlayerLayer = appdf.req(module_pre .. ".views.layer.JdobPlayerLayer")
local JdobEndTipNode = appdf.req(module_pre .. ".views.layer.JdobEndTipNode")
local g_scheduler = cc.Director:getInstance():getScheduler()
local enumTable = 
{
	"BT_EXIT",
	"BT_SOUND",			--音效
	"BT_VOICE",			--音乐
	"BT_HELP",
	"BT_HISTORY",
	"BT_ADVANCE",
	"BT_SIMPLE",
	"BT_DOUBLE",
	"BT_BRIPLE",
	"BT_QUADRA",
	"BT_PENTA",
	"BT_TEN",
	"BT_HUNDRED",
	"BT_THOUSAND",
	"BT_FUTOU",
	"BT_EDU1",
	"BT_EDU2",
	"BT_EDU3",
	"BT_EDU4",
	"BT_EDU5",
}
--按顺序是：鳄鱼，孔雀，熊，公牛，蝴蝶----骆驼，猫，鸡，奶牛，鹿----狗，驴，老鹰，大象，山羊
-----------马，狮子，猩猩，鸵鸟，猪----兔子，绵羊，蛇，老虎，火鸡
local SPINENAMETB = {"eyu", "kongque", "xiong", "niu", "hudie", "luotuo", "mao", "ji", "nainiu", "lu", 
"gou", "lv", "laoying", "xiaoxiang", "shanyang", "ma", "shizi", "xingxing", "tuoniao", "zhu", "tuzi", "mianyan", "she", "laohu", "huoji"}
local SOUNDANIMTB = {"alligator", "peacock", "bear", "bull", "butterfly", "camel", "cat", "rooster", "cow", "deer", 
"dog", "donkey", "eagle", "elephant", "goat", "horse", "lion", "monkey", "ostrich", "pig", "rabbit", "sheep", "snake", "tiger", "turkey"}
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
	self:registerTouch()
	--检测下注门槛
    self:checkJettonThreshold()
end
--[[function GameViewLayer:onCleanup()
	tlog("GameViewLayer:onCleanup")
	GameViewLayer.super.onCleanup(self)
end--]]

function GameViewLayer:gameDataInit()
	tlog('GameViewLayer:gameDataInit')
    --无背景音乐
    g_ExternalFun.stopMusic()
    --用户列表
	self:getDataMgr():initUserList(self:getParentNode():getUserList())
	--逻辑变量
	self.m_scoreUser = 0 				--玩家金币数
	self.m_gameEndActionTime = false 	--是否结算动画时间内,当前时间内不更新金币显示
	self.m_curRoundIsSelfBet = false 	--当前轮自己是否下注了
	self.m_delayUserBetArray = {}		--玩家下注消息队列
	self.m_isBetMessagePlay = false		--当前是否有下注消息读取出来
	self.lastOpenResult = {} --上轮开奖结果
	self.betRecords = {isOpen = 0, cbBetCount = 0, cbBetArray = {}} --本轮投注记录
    --文本按钮等
    self.betItemType = g_var(cmd).betItemType.eAnim --大类别  0 数组 1 动物
    self.betType = 4 --小类别，数字大类别下0两位1三位2四位，动物大类别下0一位1两位2三位3四位4五位
    self.betEduIdx = 1 --投注筹码选中序号
    self.betNumTb = {} --选中动物或数字
    self.animBtnTb = {} --选择动物按钮
    self.numberBtnTb = {} --选择数字按钮
    self.isSendingBet = false --是否正在发送投注

	self.over_vip                       = 1         --限额阈值
    self.m_OverThreshold                = false     --玩家数高于阈值
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
	self.Panel_content = self.m_csbNode:getChildByName("Panel_content")
	
	self.Panel_title = self.Panel_content:getChildByName("Panel_title")
	self.fntNode = self.Panel_content:getChildByName("fntNode")
	self.Panel_right = self.Panel_content:getChildByName("Panel_right")
	self.Panel_method = self.Panel_content:getChildByName("Panel_method")
	self.Panel_anim = self.Panel_content:getChildByName("Panel_anim")
	self.Panel_number = self.Panel_content:getChildByName("Panel_number")
	self.Panel_box = self.Panel_content:getChildByName("Panel_box")
	self.Panel_me = self.Panel_content:getChildByName("Panel_me")
	self.Panel_other = self.Panel_content:getChildByName("Panel_other")
	self.Panel_bet = self.Panel_content:getChildByName("Panel_bet")
	self.Panel_bottom = self.Panel_content:getChildByName("Panel_bottom")
	self.Panel_limit = self.Panel_content:getChildByName("Panel_limit")
	--分辨率适配
	if display.width >= 1920 then
		self.Panel_right:setPositionX(display.width/2-60)
		self.m_csbNode:getChildByName("Button_more"):setPositionX(115)
		self.m_csbNode:getChildByName("sp_btn_list"):setPositionX(260)
	else
		self.Panel_right:setPositionX(display.width/2-20)
		self.m_csbNode:getChildByName("Button_more"):setPositionX(75)
		self.m_csbNode:getChildByName("sp_btn_list"):setPositionX(220)
	end
	
	
	--初始化按钮
	self:initBtn()
	--初始化玩家信息
	self:initUserInfo()
	self:initBetList()
	self:updateBetTypeTab()
	self:updateBetNumberStatus()

	local _playerNode = JdobPlayerLayer:create(self.Panel_other)
	self:addChild(_playerNode)
	self.m_jdobPlayerNode = _playerNode
	local _endTipNode = JdobEndTipNode:create()
	self:addChild(_endTipNode)
	self.m_jdobTipNode = _endTipNode

	self.m_showGoldIndex = 0 --当前已显示筹码数量
	self.m_goldStaticNum = 350 --首批创建500个筹码备用
	self.m_allGoldSpriteArray = {}
	self.m_betNetActNode = cc.Node:create()
	self.m_betNetActNode:addTo(self)
	self.m_flyGoldBgNode = cc.Node:create()
	self.m_flyGoldBgNode:addTo(self)
	self:initGold(self.m_goldStaticNum)
	self.m_openBoxBgNode = cc.Node:create()
	self.m_openBoxBgNode:addTo(self)
end
function GameViewLayer:initGold(goldNum)
	self.goldObjectPool = ObjectPool.new(function() 
		local sp = cc.Sprite:create()
		sp:setSpriteFrame("game/yule/jdob/res/GUI/txz_jnd_bg.png")
		sp:retain()
		return sp
	end)

	-- for j = 1, goldNum do
    --     local sp = cc.Sprite:create()
	-- 	sp:setSpriteFrame("game/yule/jdob/res/GUI/txz_jnd_bg.png")
	-- 	sp:setVisible(false)
	-- 	self.m_flyGoldBgNode:addChild(sp)
	-- 	sp:setScale(1.0)
	-- 	table.insert(self.m_allGoldSpriteArray, sp)
	-- end
end
--不是自己的，随机取一个
function GameViewLayer:getScoreSprite()
	local goldIndex = self.m_showGoldIndex + 1
	if goldIndex > self.m_goldStaticNum then
		-- print("金币数量不够，重新生成")
		self:initGold(200)
		self.m_goldStaticNum = self.m_goldStaticNum + 200
	end
	local coinSprite = self.m_allGoldSpriteArray[goldIndex]
	coinSprite:setVisible(true)
	self.m_showGoldIndex = goldIndex
	return coinSprite
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
	--开奖结果按钮
    btn = self.Panel_right:getChildByName("btn_history")
	btn:setTag(TAG_ENUM.BT_HISTORY)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_history = btn
	--数字玩法按钮
    btn = self.Panel_method:getChildByName("btn_advance")
	btn:setTag(TAG_ENUM.BT_ADVANCE)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_advance = btn
	--动物玩法单个按钮
    btn = self.Panel_method:getChildByName("btn_simple")
	btn:setTag(TAG_ENUM.BT_SIMPLE)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_simple = btn
	--动物玩法两个按钮
    btn = self.Panel_method:getChildByName("btn_double")
	btn:setTag(TAG_ENUM.BT_DOUBLE)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_double = btn
	--动物玩法三个按钮
    btn = self.Panel_method:getChildByName("btn_briple")
	btn:setTag(TAG_ENUM.BT_BRIPLE)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_briple = btn
	--动物玩法四个按钮
    btn = self.Panel_method:getChildByName("btn_quadra")
	btn:setTag(TAG_ENUM.BT_QUADRA)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_quadra = btn
	--动物玩法五个按钮
    btn = self.Panel_method:getChildByName("btn_penta")
	btn:setTag(TAG_ENUM.BT_PENTA)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_penta = btn
	--数字玩法按钮十
    btn = self.Panel_number:getChildByName("btn_ten")
	btn:setTag(TAG_ENUM.BT_TEN)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_ten = btn
	--数字玩法按钮百
    btn = self.Panel_number:getChildByName("btn_hundred")
	btn:setTag(TAG_ENUM.BT_HUNDRED)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_hundred = btn
	--数字玩法按钮千
    btn = self.Panel_number:getChildByName("btn_thousand")
	btn:setTag(TAG_ENUM.BT_THOUSAND)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_thousand = btn
	--复投按钮
    btn = self.Panel_bottom:getChildByName("btn_repeat")
	btn:setTag(TAG_ENUM.BT_FUTOU)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_futou = btn
	--额度按钮
    btn = self.Panel_bottom:getChildByName("btn_edu1")
	btn:setTag(TAG_ENUM.BT_EDU1)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_edu1 = btn
	btn = self.Panel_bottom:getChildByName("btn_edu2")
	btn:setTag(TAG_ENUM.BT_EDU2)
	self:registerBtnEvent(btn, handler(self, self.onButtonClickedEvent))
	self.btn_edu2 = btn
	--按顺序是：鳄鱼，孔雀，熊，公牛，蝴蝶----骆驼，猫，鸡，奶牛，鹿----狗，驴，老鹰，大象，山羊
	-----------马，狮子，猩猩，鸵鸟，猪----兔子，绵羊，蛇，老虎，火鸡
	--选择动物按钮
	local spineNode = self.Panel_anim:getChildByName("spineNode")
	local textNode = self.Panel_anim:getChildByName("textNode")
	for i=1,25 do
		local btnName = "btn_anim"..i
		btn = self.Panel_anim:getChildByName(btnName)
		btn:setTag(i)
		btn:addTouchEventListener(handler(self, self.onAnimButtonTouch))
		self.animBtnTb[i] = btn
		btn:getChildByName("img_highlight"):setVisible(false)
		local spinePath = "spine_effect/"..SPINENAMETB[i]
		local spineAnim = sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
	    spineAnim:setAnimation(0, "daiji", true)
	    spineAnim:setPosition(0,-40)
	    spineAnim:setScale(0.8)
	    spineAnim:addTo(spineNode:getChildByName("node_spine_"..i))
	end    
	--选择数字按钮
	for i=1,10 do
		local idx = i%10
		local btnName = "btn_number"..idx
		btn = self.Panel_number:getChildByName(btnName)
		btn:setTag(idx)
		btn:addTouchEventListener(handler(self, self.onNumberButtonTouch))
		self.numberBtnTb[i] = btn
		btn:getChildByName("img_highlight"):setVisible(false)
	end
	--开奖箱子动画
	for i=1,5 do
		local boxName = "Panel_box"..i
		local box = self.Panel_box:getChildByName(boxName)
		box:getChildByName("node_box1"):removeAllChildren()
		box:getChildByName("node_anima"):removeAllChildren()
		box:getChildByName("node_box2"):removeAllChildren()
		box:getChildByName("node_boxText"):removeAllChildren()
		local spinePath = "spine_effect/xiangzi2"
		local spineAnim = sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
	    spineAnim:setPosition(0,0)
	    spineAnim:addTo(box:getChildByName("node_box1"))
	    spineAnim:setTag(11)
	    spineAnim:setScale(0.9)
	    --spineAnim:setVisible(false)
	    spineAnim:setAnimation(0, "daiji", true)
	    local spinePath2 = "spine_effect/xiangzi1"
		local spineAnim2 = sp.SkeletonAnimation:create(spinePath2..".json", spinePath2..".atlas", 1)
	    spineAnim2:setPosition(0,0)
	    spineAnim2:addTo(box:getChildByName("node_box2"))
	    spineAnim2:setTag(11)
	    spineAnim2:setScale(0.9)
	    spineAnim2:setSkin(tostring(i))
	    --spineAnim:setVisible(false)
	    spineAnim2:setAnimation(0, "daiji", true)
	    box:getChildByName("img_box"):setVisible(false)
	end
	--未显示头像的其他房间玩家
	self.m_totalPeopleIcon = self.Panel_right:getChildByName("btn_userNum")
	self.m_totalPeopleIcon.originPos = cc.p(self.m_totalPeopleIcon:getPosition())
end
--初始化列表  
function GameViewLayer:initBetList()
	self.mm_Panel_1 = self.Panel_bet:getChildByName("Panel_list")
	local _tableView = cc.TableView:create(self.mm_Panel_1:getContentSize())
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    _tableView:setDelegate()
    _tableView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(handler(self, self.scrollViewDidScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.mm_Panel_1:addChild(_tableView)
    self.m_tableView = _tableView
    self.mm_Panel_item = self.Panel_bet:getChildByName("Panel_item")
    self.mm_Panel_item:hide()
    self.mm_Panel_item:setTouchEnabled(false)
end
--音效音乐设置资源
function GameViewLayer:flushMusicResShow(_node, _enabled)
	_node:getChildByName('Image_1'):setVisible(_enabled)
	_node:getChildByName('Image_2'):setVisible(not _enabled)
end
---------------------------------------------------------------------------------------
--删除未完成的临时投注
function GameViewLayer:deleteTempBet()
	if #self.betRecords.cbBetArray > 0 then
		if self.betRecords.cbBetArray[#self.betRecords.cbBetArray].isTempBet then
			table.remove(self.betRecords.cbBetArray, #self.betRecords.cbBetArray)
		end
	end
end
function GameViewLayer:onButtonClickedEvent(_sender)
	local tag = _sender:getTag()
	tlog('GameViewLayer:onButtonClickedEvent ', tag)
	--g_ExternalFun.playClickEffect()
	if tag == TAG_ENUM.BT_EXIT then
	    self:getParentNode():onQueryExitGame()
	elseif tag == TAG_ENUM.BT_SOUND then --音效
		GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble)
		self:flushMusicResShow(_sender, GlobalUserItem.bSoundAble)
	elseif tag == TAG_ENUM.BT_VOICE then
	    GlobalUserItem.setVoiceAble(not GlobalUserItem.bVoiceAble)
        self:flushMusicResShow(_sender, GlobalUserItem.bVoiceAble)
        if GlobalUserItem.bVoiceAble then
		    self:playGamebgMusic()
        end
	elseif tag == TAG_ENUM.BT_HELP then
		-- tlog('GameViewLayer:createHelpLayer')
		self.m_btnList:setVisible(false)
	    local _helpLayer = GameHelpLayer:create():addTo(self, 11)
	    _helpLayer:setPosition(display.width * 0.5, display.height * 0.5)
	elseif tag == TAG_ENUM.BT_HISTORY then
    	--if self.lastOpenResult.cbBetCount then
    		--弹出上轮开奖结果
    		local historyLayer = JdobHistorylLayer:create(self.lastOpenResult):addTo(self, 11)
	    	historyLayer:setPosition(display.width * 0.5, display.height * 0.5)
    	--end
	elseif tag == TAG_ENUM.BT_ADVANCE then
		self.betItemType = g_var(cmd).betItemType.eNumber --大类别  0 数组 1 动物
    	self.betType = 0 --小类别，数字大类别下0两位1三位2四位，动物大类别下0一位1两位2三位3四位4五位
    	self.betNumTb = {}
    	self:deleteTempBet()
    	self:updateBetTypeTab()
    	self.m_tableView:reloadData()
    	g_ExternalFun.playEffect("sound_res/chest_click.mp3")
	elseif tag == TAG_ENUM.BT_SIMPLE then
		self.betItemType = g_var(cmd).betItemType.eAnim
    	self.betType = 0
    	self.betNumTb = {}
    	self:deleteTempBet()
    	self:updateBetTypeTab()
    	self.m_tableView:reloadData()
    	g_ExternalFun.playEffect("sound_res/click.mp3")
	elseif tag == TAG_ENUM.BT_DOUBLE then
		self.betItemType = g_var(cmd).betItemType.eAnim
    	self.betType = 1
    	self.betNumTb = {}
    	self:deleteTempBet()
    	self:updateBetTypeTab()
    	self.m_tableView:reloadData()
    	g_ExternalFun.playEffect("sound_res/click.mp3")
	elseif tag == TAG_ENUM.BT_BRIPLE then
		self.betItemType = g_var(cmd).betItemType.eAnim
    	self.betType = 2
    	self.betNumTb = {}
    	self:deleteTempBet()
    	self:updateBetTypeTab()
    	self.m_tableView:reloadData()
    	g_ExternalFun.playEffect("sound_res/click.mp3")
    elseif tag == TAG_ENUM.BT_QUADRA then
		self.betItemType = g_var(cmd).betItemType.eAnim
    	self.betType = 3
    	self.betNumTb = {}
    	self:deleteTempBet()
    	self:updateBetTypeTab()
    	self.m_tableView:reloadData()
    	g_ExternalFun.playEffect("sound_res/click.mp3")
    elseif tag == TAG_ENUM.BT_PENTA then
		self.betItemType = g_var(cmd).betItemType.eAnim
    	self.betType = 4
    	self.betNumTb = {}
    	self:deleteTempBet()
    	self:updateBetTypeTab()
    	self.m_tableView:reloadData()
    	g_ExternalFun.playEffect("sound_res/click.mp3")
    elseif tag == TAG_ENUM.BT_TEN then
		self.betItemType = g_var(cmd).betItemType.eNumber
    	self.betType = 0
    	self.betNumTb = {}
    	self:deleteTempBet()
    	self:updateBetTypeTab()
    	self.m_tableView:reloadData()
    	g_ExternalFun.playEffect("sound_res/click.mp3")
    elseif tag == TAG_ENUM.BT_HUNDRED then
		self.betItemType = g_var(cmd).betItemType.eNumber
    	self.betType = 1
    	self.betNumTb = {}
    	self:deleteTempBet()
    	self:updateBetTypeTab()
    	self.m_tableView:reloadData()
    	g_ExternalFun.playEffect("sound_res/click.mp3")
    elseif tag == TAG_ENUM.BT_THOUSAND then
		self.betItemType = g_var(cmd).betItemType.eNumber
    	self.betType = 2
    	self.betNumTb = {}
    	self:deleteTempBet()
    	self:updateBetTypeTab()
    	self.m_tableView:reloadData()
    	g_ExternalFun.playEffect("sound_res/click.mp3")
    elseif tag == TAG_ENUM.BT_FUTOU then
		if self.lastOpenResult.cbBetCount then
    		if self.sceneData and self.sceneData.cbGameStatus == g_var(cmd).gameState.bet then
    			local totalBet = 0
		        for i=1,#self.lastOpenResult.cbBetArray do
		            totalBet = totalBet + self.lastOpenResult.cbBetArray[i].llBetscore
		        end
		        local myUser = self:getMeUserItem()
				if myUser.lScore >= totalBet then
					for i=1,#self.lastOpenResult.cbBetArray do
						local data = self.lastOpenResult.cbBetArray[i]
	    				local betTb = {}
		    			local oneBet = {}
		    			oneBet.betItemType = data.cbBetItemType
						oneBet.betType = data.cbBetType
						oneBet.betscore = data.llBetscore
						oneBet.betNumTb = clone(data.cbBetNum)
					    table.insert(betTb, oneBet)
						self:getParentNode():sendUserBet(betTb)
						self.isSendingBet = true
	    			end
	    		else
	    			showToast(g_language:getString("game_money_not_enough"))
				end
			else
				showToast("Povoado...")
    		end
    	end
    	g_ExternalFun.playEffect("sound_res/rebet.mp3")
	elseif tag == TAG_ENUM.BT_EDU1 then
		self.betEduIdx = self.betEduIdx-1 --投注筹码选中序号
		if self.betEduIdx <= 0 then
			self.betEduIdx = 5
		end
		self:updateBetNumberStatus()
	elseif tag == TAG_ENUM.BT_EDU2 then
		self.betEduIdx = self.betEduIdx+1
		if self.betEduIdx >= 6 then
			self.betEduIdx = 1
		end
		self:updateBetNumberStatus()
	else
		showToast("Funcionalidade não disponível!")
	end
end
--更新投注类型状态
function GameViewLayer:updateBetTypeTab()
	local tabBtnTb = {self.btn_simple, self.btn_double, self.btn_briple, self.btn_quadra, self.btn_penta, 
		self.btn_ten, self.btn_hundred, self.btn_thousand}
	for i=1,#tabBtnTb do
		tabBtnTb[i]:getChildByName("text_unselect"):setVisible(true)
		tabBtnTb[i]:getChildByName("img_highlight"):setVisible(false)
		tabBtnTb[i]:getChildByName("text_highlight"):setVisible(false)
	end
	self.btn_advance:getChildByName("text_unselect"):setVisible(true)
	self.btn_advance:getChildByName("img_highlight"):setVisible(false)
	self.btn_advance:getChildByName("text_highlight"):setVisible(false)
	self.Panel_anim:setVisible(false)
	self.Panel_number:setVisible(false)
	--选择动物按钮
	for i=1,25 do
		self.animBtnTb[i]:setTouchEnabled(false)
	end
	--选择数字按钮
	for i=1,10 do
		self.numberBtnTb[i]:setTouchEnabled(false)
	end
	if self.betItemType == g_var(cmd).betItemType.eNumber then
		self.btn_advance:getChildByName("text_unselect"):setVisible(false)
		self.btn_advance:getChildByName("img_highlight"):setVisible(true)
		self.btn_advance:getChildByName("text_highlight"):setVisible(true)
		self.Panel_number:setVisible(true)
		--选择数字按钮
		for i=1,10 do
			self.numberBtnTb[i]:setTouchEnabled(true)
		end
		if tabBtnTb[6+self.betType] then
			tabBtnTb[6+self.betType]:getChildByName("text_unselect"):setVisible(false)
			tabBtnTb[6+self.betType]:getChildByName("img_highlight"):setVisible(true)
			tabBtnTb[6+self.betType]:getChildByName("text_highlight"):setVisible(true)
		end
	else
		self.Panel_anim:setVisible(true)
		--选择动物按钮
		for i=1,25 do
			self.animBtnTb[i]:setTouchEnabled(true)
		end
		if tabBtnTb[1+self.betType] then
			tabBtnTb[1+self.betType]:getChildByName("text_unselect"):setVisible(false)
			tabBtnTb[1+self.betType]:getChildByName("img_highlight"):setVisible(true)
			tabBtnTb[1+self.betType]:getChildByName("text_highlight"):setVisible(true)
		end
	end
end
--更新投注额度状态
function GameViewLayer:updateBetNumberStatus()
	if self.sceneData then
		local betScore = self.sceneData.dwBetScore[self.betEduIdx]
		local serverKind = G_GameFrame:getServerKind()
		local eduNum = g_format:formatNumber(betScore,g_format.fType.standard,serverKind)
		self.fntNode:getChildByName("text_num"):setString(eduNum)
	end
end
--一个动物或数字飞行动画
function GameViewLayer:addOneBetFly(index, startPos)
	local oldOffset = self.m_tableView:getContentOffset()
    local oldSize = self.m_tableView:getContentSize()
    local listPos = self.mm_Panel_1:getParent():convertToWorldSpace(cc.p(self.mm_Panel_1:getPosition()))
    local listSize = self.mm_Panel_1:getContentSize()
    local arrayNum = #self.betRecords.cbBetArray
    --上移一个单元
    if #self.betNumTb == 1 then
		self.m_tableView:reloadData()
		local newSize = self.m_tableView:getContentSize()
	    local newOffsetY = oldOffset.y + -1*(newSize.height - oldSize.height)
	    --第四行元素开始上移
	    if arrayNum <= 3 then
	    	self.m_tableView:setContentOffset(cc.p(oldOffset.x, newOffsetY))
	    else
	    	self.m_tableView:setContentOffset(cc.p(oldOffset.x, 0))
	    end    
	end
	local tagPos = cc.p(listPos.x, listPos.y)
    if arrayNum == 1 then
    	tagPos = cc.p(listPos.x-listSize.width/2 + (#self.betNumTb-1)*74, listPos.y-listSize.height/2 + 126*3)
    elseif arrayNum == 2 then
    	tagPos = cc.p(listPos.x-listSize.width/2 + (#self.betNumTb-1)*74, listPos.y-listSize.height/2 + 126*2)
    elseif arrayNum == 3 then
    	tagPos = cc.p(listPos.x-listSize.width/2 + (#self.betNumTb-1)*74, listPos.y-listSize.height/2 + 126)
    else
    	tagPos = cc.p(listPos.x-listSize.width/2 + (#self.betNumTb-1)*74, listPos.y-listSize.height/2)
    end
    --飞行图标  
    local flyImg = nil
    if self.betItemType == g_var(cmd).betItemType.eAnim then
    	local imgName = string.format("anim_b_%d.png", index+1)
    	flyImg = display.newSprite("#game/yule/jdob/res/GUI/anim/"..imgName)
    else
    	local imgName = string.format("txz_%d_bg.png", index)
    	flyImg = display.newSprite("#game/yule/jdob/res/GUI/"..imgName)
    end
	flyImg:addTo(self,9)
	local bezier = {
        startPos,
        cc.p(startPos.x -100, startPos.y + 100),
        tagPos,
    }
    local bezierto = cc.EaseInOut:create(cc.BezierTo:create(0.66, bezier), 1)
    local seq = cc.Sequence:create(
        bezierto,
        cc.CallFunc:create(function()
            if #self.betNumTb ~= 1 then
				local cellNum = #self.betRecords.cbBetArray
				self.m_tableView:updateCellAtIndex(cellNum-1)
			end
        end),
        cc.RemoveSelf:create()
    )
    flyImg:setPosition(startPos)
    flyImg:runAction(seq)
end
--判断投注是否为重复动物
function GameViewLayer:checkBetAnimValid(index)
	local isValid = true
	for i=1,#self.betNumTb do
		if self.betNumTb[i] == index then
			isValid = false
			break
		end
	end
	return isValid
end
--选择一个号码或动物
function GameViewLayer:addOneBetNum(index, startPos)
	if self.sceneData and self.sceneData.cbGameStatus == g_var(cmd).gameState.bet then		
		local betTb = {}
		local oneBet = {}
		local oneBetMax = 0
		if self.betItemType == g_var(cmd).betItemType.eNumber then
			oneBetMax = g_var(cmd).betStartNum.eNumber + self.betType
		else
			oneBetMax = g_var(cmd).betStartNum.eAnim + self.betType
			if not self:checkBetAnimValid(index) then
				showToast("can not bet the same animal!")
				return
			end
		end
		tlog("addOneBetNum", oneBetMax)
		if #self.betNumTb < oneBetMax then
			if #self.betNumTb == 0 then
				local tempBet = {}
				tempBet.cbBetItemType = self.betItemType
				tempBet.cbBetType = self.betType
				tempBet.llBetscore = 0
				tempBet.llWinscore = 0
				tempBet.dwBetIndex = 0
				tempBet.cbBetNum = {index}
				tempBet.isTempBet = true
				table.insert(self.betRecords.cbBetArray, tempBet)
			else
				table.insert(self.betRecords.cbBetArray[#self.betRecords.cbBetArray].cbBetNum, index)
			end
			table.insert(self.betNumTb, index)
			self:addOneBetFly(index, startPos)
		end
		if #self.betNumTb >= oneBetMax and self.sceneData then
			oneBet.betItemType = self.betItemType
			oneBet.betType = self.betType
			oneBet.betscore = self.sceneData.dwBetScore[self.betEduIdx]
			oneBet.betNumTb = clone(self.betNumTb)
		    table.insert(betTb, oneBet)
			self:getParentNode():sendUserBet(betTb)
			self.betNumTb = {}
			self.isSendingBet = true
		end
	else  
		showToast("Povoado...")
	end
end
--选择动物按钮
function GameViewLayer:onAnimButtonTouch(_sender, _eventType)
    tlog('GameViewLayer:onAnimButtonTouch')
    if _eventType == ccui.TouchEventType.began then
        _sender:getChildByName("img_highlight"):setVisible(true)
    elseif _eventType == ccui.TouchEventType.canceled then
        _sender:getChildByName("img_highlight"):setVisible(false)
    elseif _eventType == ccui.TouchEventType.ended then
    	_sender:getChildByName("img_highlight"):setVisible(false)
		if not self.m_OverThreshold then
			return
		elseif self.m_scoreUser >= self.sceneData.dwBetScore[self.betEduIdx] then
	        --判断后端投注消息回来后
	        if not self.isSendingBet then
				local startPos = _sender:getParent():convertToWorldSpace(cc.p(_sender:getPosition()))
	        	self:addOneBetNum(_sender:getTag()-1, startPos)
			end
	        g_ExternalFun.playEffect("sound_res/animal_click.mp3")
	    else
	        showToast(g_language:getString("game_money_not_enough"))
	    end
    end
end
--选择数字按钮
function GameViewLayer:onNumberButtonTouch(_sender, _eventType)
    tlog('GameViewLayer:onNumberButtonTouch')
    if _eventType == ccui.TouchEventType.began then
        _sender:getChildByName("img_highlight"):setVisible(true)
    elseif _eventType == ccui.TouchEventType.canceled then
        _sender:getChildByName("img_highlight"):setVisible(false)
    elseif _eventType == ccui.TouchEventType.ended then
    	_sender:getChildByName("img_highlight"):setVisible(false)
		if not self.m_OverThreshold then
			return
		elseif self.m_scoreUser >= self.sceneData.dwBetScore[self.betEduIdx] then
			--判断后端投注消息回来后
	        if not self.isSendingBet then
		    	local startPos = _sender:getParent():convertToWorldSpace(cc.p(_sender:getPosition()))
		        self:addOneBetNum(_sender:getTag(), startPos)
		    end
	        g_ExternalFun.playEffect("sound_res/coin_click.mp3")
        else
        	showToast(g_language:getString("game_money_not_enough"))
        end
    end
end
--更新游戏状态
function GameViewLayer:updateTitlePanel()
	if self.sceneData then
		local actTick = cc.RepeatForever:create(
			cc.Sequence:create(
				cc.DelayTime:create(0.02),
				cc.CallFunc:create(function (  )
					local curStamp = tickMgr:getTime()
					local remainTime = self.sceneData.gameStateStamp - curStamp
					if remainTime < 0 then
						remainTime = 0
					end
					local perNum = remainTime / self.sceneData.cbAllTime * 100
					self.Panel_title:getChildByName("LoadingBar_1"):setPercent(perNum)
					self.fntNode:getChildByName("time_num"):setString(tostring(math.floor(remainTime)))
				end)
		))
		self.Panel_title:stopAllActions()
		self.Panel_title:runAction(actTick)  
	end
end    
--更新游戏人数
function GameViewLayer:updateRoomUserNum()
	local userList = self:getDataMgr():getUserList()
	local worldPosition = self.m_totalPeopleIcon:convertToWorldSpace(cc.p(self.m_totalPeopleIcon:getContentSize().width/2,19))
	local nodePosition = self.fntNode:convertToNodeSpace(worldPosition)
	local text_user_num = self.fntNode:getChildByName("text_user_num")
	text_user_num:setString(#userList)  
	text_user_num:setPosition(nodePosition)
end
--更新总投注数量
function GameViewLayer:updateTotalBetNum()
	if self.sceneData then
		local serverKind = G_GameFrame:getServerKind()
		local totalNum = g_format:formatNumber(self.sceneData.lAllBet,g_format.fType.standard,serverKind)
		local totalBet = self.fntNode:getChildByName("Text_money")
		totalBet._lastNum = self.sceneData.lAllBet
		totalBet._curNum = self.sceneData.lAllBet
		totalBet:setString(totalNum)
	end
end
--更新我的总投注数量
function GameViewLayer:updateMyTotalBet()
	if self.sceneData then
		local serverKind = G_GameFrame:getServerKind()
		local totalNum = g_format:formatNumber(self.sceneData.lPlayBet,g_format.fType.standard,serverKind)
		self.fntNode:getChildByName("Text_total_bet_num"):setString(totalNum)
	end
end    
--初始化玩家信息
function GameViewLayer:initUserInfo()
	tlog('GameViewLayer:initUserInfo')
	--玩家游戏币
	self.m_textUserCoint = self.fntNode:getChildByName("Text_money_me")
	self.m_textUserCoint._lastNum = 0
	self.m_textUserCoint._curNum = 0
	--头像
    local node_head = self.Panel_me:getChildByName("imgShade")
    local imgHead = node_head:getChildByName("imgHead")
    imgHead:removeAllChildren()
	local faceId = GlobalUserItem.wFaceID
	local node = HeadNode:create(faceId)
	imgHead:addChild(node)
	node:setContentSize(cc.size(158,158))
	node:loadBorderTexture("game/yule/jdob/res/GUI/txz_txk_bg.png")
	node:setTouched(false)

   
    -- local pPathHead = string.format("client/res/public/Face%d.jpg", faceId)
    -- local pPathClip = "GUI/jdob_head_clip.png"
    -- g_ExternalFun.ClipHead(imgHead, pPathHead, pPathClip)
    --昵称
    local text_name = self.fntNode:getChildByName("Text_name")
    text_name:setString(GlobalUserItem.szNickName)

	self:reSetUserInfo()
end

function GameViewLayer:reSetUserInfo(_reduceNum)
	tlog('GameViewLayer:reSetUserInfo ', _reduceNum)
	if _reduceNum == nil then
		_reduceNum = 0
	end
	self.m_scoreUser = 0
	local myUser = self:getMeUserItem()
	if nil ~= myUser then
		self.m_scoreUser = myUser.lScore
	end
	print("自己游戏币: " .. self.m_scoreUser)
	self:updateUserScore(_reduceNum)
end

--下注及恢复场景的时候需要手动减去自己已下注的游戏币
function GameViewLayer:updateUserScore(_reduceNum)
	self.m_scoreUser = self.m_scoreUser - _reduceNum
	tlog('GameViewLayer:updateUserScore ', self.m_scoreUser, _reduceNum)
	self.m_textUserCoint._lastNum = self.m_textUserCoint._curNum
	self.m_textUserCoint._curNum = self.m_scoreUser
	self.m_textUserCoint:stopAllActions()
	self:formatNumShow(self.m_textUserCoint, self.m_scoreUser)
	if _reduceNum ~= 0 then
		self:updateGoldShow(self.m_textUserCoint, 0.3)
	end
end
--初始化游戏信息
function GameViewLayer:initGameOfScene(cmdData)
	tlog('GameViewLayer:initGameOfScene', cmdData.cbGameStatus, cmdData.cbTimeLeave, cmdData.cbAllTime)
	--检测下注门槛
    self:checkJettonThreshold()
    self.sceneData = cmdData
    self.m_curRoundIsSelfBet = cmdData.lPlayBet > 0
    self.m_gameEndActionTime = false
    self:updateBetNumberStatus()
    self:updateTitlePanel()
    self:updateTotalBetNum()
    self:updateMyTotalBet()
    if self.sceneData.cbGameStatus == g_var(cmd).gameState.endAnim then
    --开奖提示
	    self.m_jdobTipNode:setTipNodeVisible(true)
	end
	self:playGamebgMusic()
	--清除队列
	self:clearBetQueue()
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
--单元滚动回调
function GameViewLayer:scrollViewDidScroll(view)
    
end
--单元大小
function GameViewLayer:cellSizeForTable( view, idx )
    return 366, 126
end
--单元数量
function GameViewLayer:numberOfCellsInTableView( view )
	local arrayNum = #self.betRecords.cbBetArray
    return arrayNum
end
--单元绘制
function GameViewLayer:tableCellAtIndex( view, idx )
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    local itemNode = cell:getChildByName("ITEM_NODE")
    if not itemNode then
        itemNode = self.mm_Panel_item:clone()
        itemNode:setPosition(0, 61)
        itemNode:setAnchorPoint(cc.p(0,0.5))
        itemNode:setName("ITEM_NODE")
        itemNode:setVisible(true)
        cell:addChild(itemNode, 0, 11)
    end
    self:updateItem(itemNode, idx + 1)
    return cell
end
--更新item
function GameViewLayer:updateItem(itemNode, _index)
    local data = nil
    data = self.betRecords.cbBetArray[_index]
    local cell_anim = itemNode:getChildByName("cell_anim")
    local cell_number = itemNode:getChildByName("cell_number")
    cell_anim:setVisible(false)
    cell_number:setVisible(false)
    itemNode:getChildByName("btn_delete"):setVisible(false)
    local Text_betnum = itemNode:getChildByName("Text_betnum")
    if data.llBetscore then
    	Text_betnum:setVisible(true)
    	local serverKind = G_GameFrame:getServerKind()
    	Text_betnum:setString(g_format:formatNumber(data.llBetscore,g_format.fType.standard,serverKind))
    	if data.isTempBet and _index == #self.betRecords.cbBetArray and #data.cbBetNum == 1 then
        	Text_betnum:stopAllActions()
        	Text_betnum:runAction(cc.Sequence:create(
	            cc.Hide:create(),
	            cc.DelayTime:create(0.66), --贝塞尔曲线飞行结束后显示,注意0.66的时间
	            cc.Show:create()
	        ))
        end
    else
	    Text_betnum:setVisible(false)
	end
    if data.cbBetItemType == g_var(cmd).betItemType.eNumber then
        if data.isTempBet and _index == #self.betRecords.cbBetArray and #data.cbBetNum == 1 then
        	cell_number:setVisible(false)
        	cell_number:stopAllActions()
        	cell_number:runAction(cc.Sequence:create(
	            cc.Hide:create(),
	            cc.DelayTime:create(0.66), --贝塞尔曲线飞行结束后显示,注意0.66的时间
	            cc.Show:create()
	        ))
        else
        	cell_number:setVisible(true)
        end
        local oneBetMax = g_var(cmd).betStartNum.eNumber + data.cbBetType
        local showNum = math.min(oneBetMax, #data.cbBetNum)
        cell_number:getChildByName("number_colorbg"):setContentSize(cc.size(74*oneBetMax, 72))
		for i=1,4 do
			local icon = cell_number:getChildByName("Icon_number"..i)
			icon:setVisible(false)
			if i <= showNum then
				icon:setVisible(true)
				--避免后端给出的动物或数字超出范围报错
		    	if data.cbBetNum[i] >= 0 and data.cbBetNum[i] <= 9 then
		    		local imgName = string.format("txz_%d_bg.png", data.cbBetNum[i])
					icon:loadTexture("game/yule/jdob/res/GUI/"..imgName,1)
		    	end
			end
		end
    else
    	if data.isTempBet and #data.cbBetNum == 1 then
        	cell_anim:setVisible(false)
        	cell_anim:stopAllActions()
        	cell_anim:runAction(cc.Sequence:create(
	            cc.Hide:create(),
	            cc.DelayTime:create(0.66), --贝塞尔曲线飞行结束后显示,注意0.66的时间
	            cc.Show:create()
	        ))
        else
        	cell_anim:setVisible(true)
        end
		local oneBetMax = g_var(cmd).betStartNum.eAnim + data.cbBetType
		for i=1,5 do
			local icon = cell_anim:getChildByName("Icon_anim"..i)
			icon:setVisible(false)
			local showNum = math.min(oneBetMax, #data.cbBetNum)
			if i <= showNum then
				icon:setVisible(true)
				--避免后端给出的动物或数字超出范围报错
		    	if data.cbBetNum[i] >= 0 and data.cbBetNum[i] <= 24 then
					local imgName = string.format("anim_b_%d.png", data.cbBetNum[i]+1)
					local scaleAnim = false
					if self.m_curRoundIsSelfBet and self.m_gameEndActionTime and self.lastOpenResult.cbBetArray then
						if self.lastOpenResult.cbBetArray[_index]
							and self.lastOpenResult.cbBetArray[_index].llWinscore > 0 then
							imgName = string.format("anim_y_%d.png", data.cbBetNum[i]+1)
							scaleAnim = true
						end
					end
					icon:loadTexture("game/yule/jdob/res/GUI/anim/"..imgName,1)
					if scaleAnim then
						icon:stopAllActions()
						icon:runAction(cc.Sequence:create(
				        	cc.ScaleTo:create(0.1, 1.2),
				        	cc.ScaleTo:create(0.1, 1.0)
				        ))
					end
				end
			end
		end
    end
end   
--退出
function GameViewLayer:onExit()
	tlog('GameViewLayer:onExit')
	self:gameDataReset()
	self.goldObjectPool:clearObjectPool(true)
	if self.listener ~= nil then
		self:getEventDispatcher():removeEventListener(self.listener)
	end
end
---------------------------------------------------------------------------------------
--网络消息
--网络接收
--用户下注
function GameViewLayer:onUserPlaceBet(cmdData)
	tlog("GameViewLayer:onUserPlaceBet")
	self.isSendingBet = false
	if self.sceneData.cbGameStatus == g_var(cmd).gameState.endAnim then
		--消息延迟等
		self:showUserBetEvent(nil, cmdData)
	else
		local wUser = cmdData.wChairID
		if self:isMeChair(wUser) then
			--自己的直接飞出，不走队列
			self:showUserBetEvent(true, cmdData)
		else
			self:pushBetQueue(cmdData)
		end
	end
end
--更新用户下注
function GameViewLayer:showUserBetEvent(_isSelf, cmdData)
	tlog("GameViewLayer:showUserBetEvent ", _isSelf)
	local wUser = cmdData.wChairID
	local isSelf = false
	if _isSelf or self:isMeChair(wUser) then
		isSelf = true
		self:updateUserScore(cmdData.llBetscore)
		self.m_curRoundIsSelfBet = true
		self:recordCurBetInfo(cmdData)
		--贝塞尔曲线飞行结束后刷新,注意0.66的时间
		self.m_flyGoldBgNode:stopAllActions()
		self.m_flyGoldBgNode:runAction(cc.Sequence:create(
        	cc.DelayTime:create(0.66),
            cc.CallFunc:create(function ( ... )
                local oldOffset = self.m_tableView:getContentOffset()
    			local oldSize = self.m_tableView:getContentSize()
				self.m_tableView:reloadData()
				local newSize = self.m_tableView:getContentSize()
	    		local newOffsetY = oldOffset.y + -1*(newSize.height - oldSize.height)
    			self.m_tableView:setContentOffset(cc.p(oldOffset.x, newOffsetY))
            end)
        ))
        self.sceneData.lPlayBet = self.sceneData.lPlayBet + cmdData.llBetscore
        self:updateMyTotalBet()
	end
	--总投注
	local totalSelf = self.fntNode:getChildByName("Text_money")
	totalSelf._lastNum = totalSelf._curNum
	totalSelf._curNum = totalSelf._curNum + cmdData.llBetscore
	self:updateGoldShow(totalSelf, 0.3)
	self.sceneData.lAllBet = self.sceneData.lAllBet + cmdData.llBetscore

	self:getDataMgr():updateUserBetScore(wUser, cmdData.llBetscore)
	--周围六人
	self.m_jdobPlayerNode:updatePlayerBetCoinShow(wUser, cmdData.llBetscore)
	local playerIndex, playerNode = self.m_jdobPlayerNode:checkPlayerInSeat(wUser)
	--震动头像
	if not _isSelf then
		if playerIndex == 0 then
			self:sharkTotalPeopleIcon()
			playerNode = self.m_totalPeopleIcon
		else
			self.m_jdobPlayerNode:sharkPlayerHeadIcon(playerIndex)
		end
	end    
	--周围六人投注飞货币动画
	local genRandomPos = function ( iconPos )
        local randomPos = iconPos
        local posX = math.random(-10, 10)
        local posY = math.random(-10, 10)
        randomPos = cc.pAdd(iconPos, cc.p(posX, posY))
        return randomPos
    end
	if playerNode and (not _isSelf) then
	    local totalBet = self.fntNode:getChildByName("Text_money")
	    local tagPos = totalBet:getParent():convertToWorldSpace(cc.p(totalBet:getPosition()))
		local startPos = playerNode:getParent():convertToWorldSpace(cc.p(playerNode:getPosition()))
		local flyTime = 0.2
		--固定5个金币
		for i=1,5 do
			local goldIcon = self.goldObjectPool:getObject()
			self.m_flyGoldBgNode:addChild(goldIcon)
			local randomPos = genRandomPos(startPos)
	        goldIcon:setPosition(randomPos)
	        local bezier = {
		        randomPos,
		        cc.p((randomPos.x + tagPos.x) * 0.5, (randomPos.y + tagPos.y) * 0.5 - 100),
		        tagPos,
		    }
	        goldIcon:stopAllActions()
	        goldIcon:runAction(cc.Sequence:create(
	            cc.Hide:create(),
	            cc.DelayTime:create((i-1)*0.03),
	            cc.Show:create(),
	            cc.MoveTo:create(0.15, cc.p(randomPos.x, randomPos.y+60)),
	            cc.MoveTo:create(0.15, cc.p(randomPos.x, randomPos.y-15)),
	            cc.MoveTo:create(0.1, cc.p(randomPos.x, randomPos.y+10)),
	            cc.MoveTo:create(0.1, cc.p(randomPos.x, randomPos.y)),
	            cc.DelayTime:create(0.6),
	            --cc.MoveTo:create(flyTime, tagPos),
	            cc.EaseInOut:create(cc.BezierTo:create(flyTime, bezier), 1),
	            cc.CallFunc:create(function() 
					goldIcon:removeFromParent()
					self.goldObjectPool:returnObject(goldIcon)
				end)
	        ))
		end
		--投注小图标上浮动画
		local bgNode = display.newNode()
		bgNode:setPosition(cc.p(startPos.x, startPos.y+50))
		bgNode:addTo(self, 9)
		local firstx = -44
		local spacex = 47
		if startPos.x > display.width/2 then
			firstx = -1*firstx
			spacex = -1*spacex
		end
		if cmdData.cbBetItemType == g_var(cmd).betItemType.eNumber then
	        local oneBetMax = g_var(cmd).betStartNum.eNumber + cmdData.cbBetType
			for i=1,oneBetMax do
				--避免后端给出的动物或数字超出范围报错
		    	if cmdData.cbBetNum[i] >= 0 and cmdData.cbBetNum[i] <= 9 then
		    		local imgName = string.format("txz_%d_bg.png", cmdData.cbBetNum[i])
					local icon = display.newSprite("#game/yule/jdob/res/GUI/"..imgName)
					if oneBetMax > 3 then
						if i>3 then
							icon:setPosition(firstx+spacex*(i-3-1), 127)
						else
							icon:setPosition(firstx+spacex*(i-1), 170)
						end
					else
						icon:setPosition(firstx+spacex*(i-1), 127)
					end
					icon:setScale(0.55)
					icon:addTo(bgNode)
		    	end
			end
	    else
			local oneBetMax = g_var(cmd).betStartNum.eAnim + cmdData.cbBetType
			for i=1,oneBetMax do
				--避免后端给出的动物或数字超出范围报错
		    	if cmdData.cbBetNum[i] >= 0 and cmdData.cbBetNum[i] <= 24 then
					local imgName = string.format("anim_b_%d.png", cmdData.cbBetNum[i]+1)
					local icon = display.newSprite("#game/yule/jdob/res/GUI/anim/"..imgName)
					if oneBetMax > 3 then
						if i>3 then
							icon:setPosition(firstx+spacex*(i-3-1), 127)
						else
							icon:setPosition(firstx+spacex*(i-1), 170)
						end
					else
						icon:setPosition(firstx+spacex*(i-1), 127)
					end
					icon:setScale(0.55)
					icon:addTo(bgNode)
				end
			end
	    end
		bgNode:setOpacity(0)
		bgNode:setPositionY(startPos.y)
	    bgNode:runAction(cc.Sequence:create(
	    	cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, 10)), cc.FadeIn:create(0.5)),
	    	cc.DelayTime:create(0.6),
	    	cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, 10)), cc.FadeOut:create(0.5)),
            cc.RemoveSelf:create()
        ))
	end
end
--下注后记录下注信息，复投使用
function GameViewLayer:recordCurBetInfo(cmdData)
	tlog('GameViewLayer:recordCurBetInfo')
	self:deleteTempBet()
	local oneRecord = {}
	oneRecord.cbBetItemType = cmdData.cbBetItemType
	oneRecord.cbBetType = cmdData.cbBetType
	oneRecord.cbBetNum = cmdData.cbBetNum
	oneRecord.llBetscore = cmdData.llBetscore
	oneRecord.llWinscore = 0
	table.insert(self.betRecords.cbBetArray, oneRecord)
end
--总玩家处抖动效果
function GameViewLayer:sharkTotalPeopleIcon()
	tlog('GameViewLayer:sharkTotalPeopleIcon ', self.m_totalPeopleIcon.isPlay)
	if self.m_totalPeopleIcon.isPlay then
		return
	end
	self.m_totalPeopleIcon.isPlay = true
	local pPosItem = self.m_totalPeopleIcon.originPos
	local pAction1 = cc.MoveTo:create(0.025, cc.p(pPosItem.x + 30, pPosItem.y + 30))
	local pAction2 = cc.MoveTo:create(0.025, cc.p(pPosItem.x, pPosItem.y))
	local call = cc.CallFunc:create(function ()
		self.m_totalPeopleIcon.isPlay = false
	end)
	local pSeq = cc.Sequence:create(pAction1, pAction2, pAction1, pAction2, call)
	self.m_totalPeopleIcon:runAction(pSeq)
end

--收到下注消息,入列
function GameViewLayer:pushBetQueue(_netData)
    if not _netData then
        return
    end
    self.m_delayUserBetArray[#self.m_delayUserBetArray + 1] = _netData
    self:betQueuePopEvent()
end
--出列
function GameViewLayer:popBetQueue()
    if #self.m_delayUserBetArray > 0 then
        return table.remove(self.m_delayUserBetArray, 1)
    else
    	return nil
    end
end
--清除队列
function GameViewLayer:clearBetQueue()
	self.m_delayUserBetArray = nil
    self.m_delayUserBetArray = {}
    self.m_isBetMessagePlay = false
    self.m_betNetActNode:stopAllActions()
end
--取下一条消息
function GameViewLayer:readNextBetMessage(_delayTime)
	self.m_betNetActNode:runAction(cc.Sequence:create(cc.DelayTime:create(_delayTime), cc.CallFunc:create(function ()
		self.m_isBetMessagePlay = false
		self:betQueuePopEvent()
	end)))
end
-- 游戏消息
function GameViewLayer:betQueuePopEvent()
	if self.m_isBetMessagePlay then
		tlog("------self.m_isBetMessagePlay true------")
		return
	end
	local netData = self:popBetQueue()
	if not netData then
	    tlog('---GameViewLayer:betQueuePopEvent not netData---')
		return
	end
	self.m_isBetMessagePlay = true
	self:showUserBetEvent(nil, netData)
	local totalNums = #self.m_delayUserBetArray
	local delayTime = 2 / totalNums
	delayTime = math.min(delayTime, 0.1)
	delayTime = math.max(delayTime, 1 / 60)
	tlog("delayTime is ", totalNums, delayTime)
	self:readNextBetMessage(delayTime)
end

--如果下注时间结束了，队列里还有消息，全部放出去
function GameViewLayer:popAllUserBetInfo()
	self.m_betNetActNode:stopAllActions()
	--0.5s内放完
	local totalNums = #self.m_delayUserBetArray
	tlog('GameViewLayer:popAllUserBetInfo ', totalNums)
	--最多分15次全部放完
	local circleNums = math.min(totalNums, 15)
	local addNums = math.ceil(totalNums / circleNums)
	local times = 0.5 / circleNums
	for i = 1, circleNums do
		for j = 1, addNums do
			local netData = self:popBetQueue()
			if netData then
				local delayTime = times * (i - 1)
				if delayTime <= 0 then
					self:showUserBetEvent(nil, netData)
				else
					local delay = cc.DelayTime:create(delayTime)
					self.m_betNetActNode:runAction(cc.Sequence:create(delay, cc.CallFunc:create(function (t, p)
						self:showUserBetEvent(nil, p.data)
					end, {data = netData})))
				end
			else
				break
			end
		end
	    if #self.m_delayUserBetArray <= 0 then
	    	break
	    end
	end
	--最后清除队列
	self:clearBetQueue()
end
--更新用户下注信息(下注记录)
function GameViewLayer:onSubUserBetData(cmdData)
	if cmdData.isOpen == 1 then
		if self.m_curRoundIsSelfBet then
			self.lastOpenResult.cbBetCount = cmdData.cbBetCount --上轮开奖结果
			self.lastOpenResult.cbBetArray = clone(cmdData.cbBetArray)
		end
	else
		self.betRecords = cmdData --本轮投注记录
	end
end
--开奖结果
function GameViewLayer:onSubGameEndOpen(cmdData)
	if self.sceneData then
		self.sceneData.cbGameStatus = g_var(cmd).gameState.endAnim
		self.sceneData.cbAllTime = cmdData.cbEndTimer
		self.sceneData.cbTimeLeave = cmdData.cbEndTimer
		local timestamp = tickMgr:getTime()
    	self.sceneData.gameStateStamp = timestamp + self.sceneData.cbTimeLeave
    	self:updateTitlePanel()
    	if self.m_curRoundIsSelfBet then
	    	self.lastOpenResult.openResult = clone(cmdData)
	    end
	    self.m_gameEndActionTime = true
	    --开箱子结果动画
	    self:playOpenBoxAnim(cmdData)

	    --下注消息队列全部放出去
	    self:popAllUserBetInfo()
	end
end
--开箱子结果动画
function GameViewLayer:playOpenBoxAnim(cmdData)
	local actionTb = {}
	--单个开箱动画
    local createAnimSpine = function ( box, idx, animnumber, numPos )
        local spinePath = "spine_effect/"..SPINENAMETB[idx+1]
		local spineAnim = sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
	    spineAnim:setAnimation(0, "ruchang", false)
	    spineAnim:setPosition(0,-25)
	    spineAnim:setScale(1.4)
	    spineAnim:addTo(box:getChildByName("node_anima"))
	    spineAnim:registerSpineEventHandler( function( event )
	    	if event.type == "complete" then
		        if event.animation == "ruchang" then
		            spineAnim:setAnimation( 0, "daiji", true) 
		        end
		    end
	    end, sp.EventType.ANIMATION_COMPLETE)--sp.EventType.ANIMATION_EVENT )
	    box:getChildByName("node_box1"):getChildByTag(11):setVisible(true)
	    box:getChildByName("node_box1"):getChildByTag(11):setAnimation(0, "dakai", false)
        box:getChildByName("node_box2"):getChildByTag(11):setVisible(true)
        box:getChildByName("node_box2"):getChildByTag(11):setAnimation(0, "dakai", false)
        box:stopAllActions()
        box:runAction(cc.Sequence:create(
        	cc.DelayTime:create(1.0),
        	cc.CallFunc:create(function ( ... )
        		g_ExternalFun.playEffect("sound_res/creak_long.mp3")
        		g_ExternalFun.playEffect(string.format("sound_res/animals/%s.mp3", SOUNDANIMTB[idx+1]))
        		local woodIdx = math.random(1, 4)
				g_ExternalFun.playEffect(string.format("sound_res/wood_%d.mp3", woodIdx))
        	end),
        	cc.DelayTime:create(1.0),
            cc.CallFunc:create(function ( ... )
                local numText = ccui.Text:create(tostring(animnumber),"fonts/arialBold.ttf",30)
			    --local numText = cc.LabelBMFont:create("0", "GUI/num_pic/shuijingfenshu.fnt")
			    numText:enableOutline(cc.c4b(139,67,27,255), 3)
			    numText:setPosition(numPos)
			    numText:addTo(box:getChildByName("node_boxText"))
			    numText:setScale(0.1)
			    numText:runAction(cc.Sequence:create(
		        	cc.ScaleTo:create(0.3, 1.2),
		        	cc.ScaleTo:create(0.2, 1.0)
		        ))
            end)
        ))
    end
    local isBgLayerClick = false
    local openTotalFunc = function ( winscore )
    	local bgLayer = display.newLayer(cc.c4b(0, 0, 0, 0))
		bgLayer:addTo(self,10)
		bgLayer:enableClick(function()
			--[[if isBgLayerClick then
				isBgLayerClick = false
				self.m_gameEndActionTime = false
				self:reSetUserInfo()
				self.betRecords = {isOpen = 0, cbBetCount = 0, cbBetArray = {}}
	            self.betNumTb = {}
	            self.m_tableView:reloadData()
	            self:updateUserBetResult()
	            for i = 1, self.m_showGoldIndex do
					if self.m_allGoldSpriteArray[i] then
						self.m_allGoldSpriteArray[i]:setVisible(false)
						self.m_allGoldSpriteArray[i]:stopAllActions()
					end
				end
			    self.m_showGoldIndex = 0
				for j=1,5 do
	            	local box = self.Panel_box:getChildByName("Panel_box"..j)
					box:getChildByName("node_box1"):getChildByTag(11):setAnimation(0, "xialuo", false)
					box:getChildByName("node_anima"):removeAllChildren()
					box:getChildByName("node_boxText"):removeAllChildren()
					box:getChildByName("node_box2"):getChildByTag(11):setAnimation(0, "xialuo", false)
	            end
				bgLayer:stopAllActions()
				bgLayer:runAction(cc.Sequence:create(
		        	cc.DelayTime:create(2.0),
		            cc.CallFunc:create(function ( ... )
		                for j=1,5 do
		                	local box = self.Panel_box:getChildByName("Panel_box"..j)
							box:getChildByName("node_box1"):getChildByTag(11):setAnimation(0, "daiji", true)
							box:getChildByName("node_box2"):getChildByTag(11):setAnimation(0, "daiji", true)
		                end
						bgLayer:removeFromParent()
		            end)
		        ))
			end--]]
		end)
		if self.m_curRoundIsSelfBet and winscore > 0 then
			local spinePath = "spine_effect/jiesuantanchuang2"
			local spineAnim = sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
		    spineAnim:setPosition(display.width/2, display.height/2)
		    spineAnim:addTo(bgLayer)
		    spineAnim:setAnimation(0, "ruchang", false)
		    spineAnim:registerSpineEventHandler( function( event )
		    	if event.type == "complete" then
			        if event.animation == "ruchang" then
			            spineAnim:setAnimation( 0, "daiji", true) 
			        end
			    end
		    end, sp.EventType.ANIMATION_COMPLETE)--sp.EventType.ANIMATION_EVENT )
	        local path = "UI/boxRewardLayer.csb"
	        local csbNode = cc.CSLoader:createNode(path)
	        local timeline = cc.CSLoader:createTimeline(path)
	        csbNode:setPosition(display.width/2, display.height/2)
	        csbNode:addTo(bgLayer)
	        local serverKind = G_GameFrame:getServerKind()
			local winNum = g_format:formatNumber(winscore,g_format.fType.standard,serverKind)
			local Text_win = csbNode:getChildByName("Panel_1"):getChildByName("Text_win")
			local imgfun = csbNode:getChildByName("Panel_1"):getChildByName("imgfun")
	        Text_win:setString(winNum.." FUN")
	        local w1 = Text_win:getContentSize().width
	        local w2 = imgfun:getContentSize().width
	        local totalW = w1+w2
	        Text_win:setPositionX(-totalW/2)
	        imgfun:setPositionX(-totalW/2+w1)
	        timeline:gotoFrameAndPlay(0, 90, false)
	        csbNode:runAction(timeline)
	--[[        timeline:setLastFrameCallFunc( function()
	            csbNode:removeFromParent()
	        end)--]]
	        local spinePath2 = "spine_effect/jiesuantanchuang1"
			local spineAnim2 = sp.SkeletonAnimation:create(spinePath2..".json", spinePath2..".atlas", 1)
		    spineAnim2:setAnimation(0, "ruchang", false)
		    spineAnim2:setPosition(display.width/2, display.height/2)
		    spineAnim2:addTo(bgLayer)
		    spineAnim2:registerSpineEventHandler( function( event )
		    	if event.type == "complete" then
			        if event.animation == "ruchang" then
			            spineAnim2:setAnimation( 0, "daiji", true) 
			        end
			    end
		    end, sp.EventType.ANIMATION_COMPLETE)--sp.EventType.ANIMATION_EVENT )
		    g_ExternalFun.playEffect("sound_res/gold_icon_big.mp3")
		else
			--开奖提示
			self.m_jdobTipNode:setTipNodeVisible(true)
		end

        bgLayer:stopAllActions()
        bgLayer:runAction(cc.Sequence:create(
        	cc.DelayTime:create(4.2),
            cc.CallFunc:create(function ( ... )
                self.m_gameEndActionTime = false
                self:reSetUserInfo()
                self.betRecords = {isOpen = 0, cbBetCount = 0, cbBetArray = {}}
                self.betNumTb = {}
                self.m_tableView:reloadData()
                self:userCollectCoinAnim(cmdData)
				self.goldObjectPool:foreachObject(function(goldIcon) 
					self.goldObjectPool:returnObject(goldIcon)
				end)
                -- for i = 1, self.m_showGoldIndex do
				-- 	if self.m_allGoldSpriteArray[i] then
				-- 		self.m_allGoldSpriteArray[i]:setVisible(false)
				-- 		self.m_allGoldSpriteArray[i]:stopAllActions()
				-- 	end
				-- end
			    -- self.m_showGoldIndex = 0
                for j=1,5 do
	            	local box = self.Panel_box:getChildByName("Panel_box"..j)
					box:getChildByName("node_box1"):getChildByTag(11):setAnimation(0, "xialuo", false)
					box:getChildByName("node_anima"):removeAllChildren()
					box:getChildByName("node_boxText"):removeAllChildren()
					box:getChildByName("node_box2"):getChildByTag(11):setAnimation(0, "xialuo", false)
					local dropIdx = math.random(1, 3)
					g_ExternalFun.playEffect(string.format("sound_res/box_drop_%d.mp3", dropIdx))
	            end
	            bgLayer:removeAllChildren()
	            --isBgLayerClick = true
				bgLayer:stopAllActions()
				bgLayer:runAction(cc.Sequence:create(
		        	cc.DelayTime:create(1.3),
		            cc.CallFunc:create(function ( ... )
		                for j=1,5 do
		                	local box = self.Panel_box:getChildByName("Panel_box"..j)
						    --[[box:getChildByName("img_box"):setVisible(true)
							box:getChildByName("node_box1"):getChildByTag(11):setVisible(false)
							box:getChildByName("node_box2"):getChildByTag(11):setVisible(false)--]]
							box:getChildByName("node_box1"):getChildByTag(11):setAnimation(0, "daiji", true)
							box:getChildByName("node_box2"):getChildByTag(11):setAnimation(0, "daiji", true)
		                end
		                self.m_jdobTipNode:setTipNodeVisible(false)
		                self.m_curRoundIsSelfBet = false
						bgLayer:removeFromParent()
		            end)
		        ))
            end)
        ))
    end
    --动画队列
    table.insert(actionTb, 
        cc.CallFunc:create(function ( ... )    
        	local box = self.Panel_box:getChildByName("Panel_box1")
            box:getChildByName("img_box"):setVisible(false)
            local idx = cmdData.betArray[1]
            local numTb = cmdData.betNum[1]
            local animnumber = tostring(numTb[1])..tostring(numTb[2])..tostring(numTb[3])..tostring(numTb[4])
            createAnimSpine(box, idx, animnumber, cc.p(-100,0))
        end)
    )
    table.insert(actionTb, 
        cc.DelayTime:create(2.5)
    )
    table.insert(actionTb, 
        cc.CallFunc:create(function ( ... )    
        	local box = self.Panel_box:getChildByName("Panel_box2")
            box:getChildByName("img_box"):setVisible(false)
            local idx = cmdData.betArray[2]
            local numTb = cmdData.betNum[2]
            local animnumber = tostring(numTb[1])..tostring(numTb[2])..tostring(numTb[3])..tostring(numTb[4])
            createAnimSpine(box, idx, animnumber, cc.p(100,0))
        end)
    )
    table.insert(actionTb, 
        cc.DelayTime:create(2.5)
    )
    table.insert(actionTb, 
        cc.CallFunc:create(function ( ... )    
        	local box = self.Panel_box:getChildByName("Panel_box3")
            box:getChildByName("img_box"):setVisible(false)
            local idx = cmdData.betArray[3]
            local numTb = cmdData.betNum[3]
            local animnumber = tostring(numTb[1])..tostring(numTb[2])..tostring(numTb[3])..tostring(numTb[4])
            createAnimSpine(box, idx, animnumber, cc.p(-100,0))
        end)
    )
    table.insert(actionTb, 
        cc.DelayTime:create(2.5)
    )
    table.insert(actionTb, 
        cc.CallFunc:create(function ( ... )    
        	local box = self.Panel_box:getChildByName("Panel_box4")
            box:getChildByName("img_box"):setVisible(false)
            local idx = cmdData.betArray[4]
            local numTb = cmdData.betNum[4]
            local animnumber = tostring(numTb[1])..tostring(numTb[2])..tostring(numTb[3])..tostring(numTb[4])
            createAnimSpine(box, idx, animnumber, cc.p(100,0))
        end)
    )
    table.insert(actionTb, 
        cc.DelayTime:create(2.5)
    )
    table.insert(actionTb, 
        cc.CallFunc:create(function ( ... )    
        	local box = self.Panel_box:getChildByName("Panel_box5")
            box:getChildByName("img_box"):setVisible(false)
            local idx = cmdData.betArray[5]
            local numTb = cmdData.betNum[5]
            local animnumber = tostring(numTb[1])..tostring(numTb[2])..tostring(numTb[3])..tostring(numTb[4])
            createAnimSpine(box, idx, animnumber, cc.p(-100,0))
        end)
    )
    table.insert(actionTb, 
        cc.DelayTime:create(1.5)
    )
    --最后一个开箱时插入投注区域中奖动画
    table.insert(actionTb, 
        cc.CallFunc:create(function ( ... )    
        	if self.m_curRoundIsSelfBet and self.lastOpenResult.cbBetArray then
			    --local contentSize = self.m_tableView:getContentSize()
				--local viewSize = self.m_tableView:getViewSize()
				--print("test jdob contentSize 111", contentSize.width, contentSize.height)
				--print("test jdob viewSize 222", viewSize.width, viewSize.height)
				local curOffset = self.m_tableView:getContentOffset()
				local maxOffset = self.m_tableView:maxContainerOffset()
				local minOffset = self.m_tableView:minContainerOffset()
				--print("test jdob curOffset 333", curOffset.x, curOffset.y)
				--print("test jdob maxOffset 444", maxOffset.x, maxOffset.y)
				--print("test jdob minOffset 555", minOffset.x, minOffset.y)
				local startIndex = math.floor((curOffset.y-minOffset.y)/126)
				local endIndex = startIndex+5
				if endIndex >= #self.betRecords.cbBetArray then
					endIndex = #self.betRecords.cbBetArray-1
				end
				--print("test jdob cellPos 666", startIndex, endIndex, #self.betRecords.cbBetArray)
				local bgLayer2 = display.newLayer(cc.c4b(0, 0, 0, 0))
				bgLayer2:addTo(self,10)
				for i=startIndex,endIndex do
					local oneCell = self.m_tableView:cellAtIndex(i)
					if oneCell then
						local cellPos1 = cc.p(oneCell:getPositionX(), oneCell:getPositionY())
						local cellPos = oneCell:getParent():convertToWorldSpace(cc.p(oneCell:getPosition()))
						--print("test jdob cellPos 777", cellPos.x, cellPos.y, cellPos1.x, cellPos1.y)
						if self.lastOpenResult.cbBetArray[i+1]
							and self.lastOpenResult.cbBetArray[i+1].llWinscore > 0 then
							local winscore = self.lastOpenResult.cbBetArray[i+1].llWinscore
							local path = "UI/betRewardTip.csb"
					        local csbNode = cc.CSLoader:createNode(path)
					        local timeline = cc.CSLoader:createTimeline(path)
					        csbNode:setPosition(cellPos.x+366/2, cellPos.y+126/2)
					        csbNode:addTo(bgLayer2)
					        local serverKind = G_GameFrame:getServerKind()
							local winNum = g_format:formatNumber(winscore,g_format.fType.standard,serverKind)
							local Text_win = csbNode:getChildByName("Panel_1"):getChildByName("Text_win")
					        Text_win:setString(winNum.." FUN")
					        timeline:gotoFrameAndPlay(0, 6, false)
					        csbNode:runAction(timeline)
							local spinePath = "spine_effect/zhongjiang"
							local spineAnim = sp.SkeletonAnimation:create(spinePath..".json", spinePath..".atlas", 1)
						    spineAnim:setPosition(cellPos.x+366/2, cellPos.y+126/2)
						    spineAnim:addTo(bgLayer2)
						    spineAnim:setAnimation(0, "animation", false)
						    spineAnim:registerSpineEventHandler( function( event )
						    	if event.type == "complete" then
							        if event.animation == "animation" then
							            --spineAnim:setAnimation( 0, "daiji", true) 
							        end
							    end
						    end, sp.EventType.ANIMATION_COMPLETE)--sp.EventType.ANIMATION_EVENT )
						end
					    self.m_tableView:updateCellAtIndex(i)
					end
				end
		        bgLayer2:stopAllActions()
		        bgLayer2:runAction(cc.Sequence:create(
		        	cc.DelayTime:create(2.0),
		            cc.CallFunc:create(function ( ... )
		                bgLayer2:removeFromParent()
		            end)
		        ))
		    end

			--local cellNum = #self.betRecords.cbBetArray
			--self.m_tableView:updateCellAtIndex(cellNum-1)
			
			--self.m_tableView:reloadData()
			--self.scrollViewDidScroll()
        end)
    )
    table.insert(actionTb, 
        cc.DelayTime:create(1.0)
    )
    table.insert(actionTb, 
        cc.CallFunc:create(function ( ... )    
            openTotalFunc(cmdData.win_score)
        end)
    )
    
    local seqAnim = cc.Sequence:create(actionTb)
    self.m_openBoxBgNode:stopAllActions()
    self.m_openBoxBgNode:runAction(seqAnim)
end
--周围六人收筹码动画
function GameViewLayer:userCollectCoinAnim(cmdData)
	tlog("GameViewLayer:userCollectCoinAnim ")
	--周围六人结算飞货币动画
	local genRandomPos = function ( iconPos )
        local randomPos = iconPos
        local posX = math.random(-10, 10)
        local posY = math.random(-10, 10)
        randomPos = cc.pAdd(iconPos, cc.p(posX, posY))
        return randomPos
    end
    local bgNode = display.newNode() 
	bgNode:setPosition(0, 0)
	bgNode:addTo(self, 9)
	local allChair = self.m_jdobPlayerNode:getAllSeatPlayerChairId()
	for i=1,#allChair do
		local wUser = allChair[i]
		local playerIndex, playerNode = self.m_jdobPlayerNode:checkPlayerInSeat(wUser)
		if playerNode and (not self:isMeChair(wUser)) and cmdData.otherWins[i] > 0 then
		    local totalBet = self.fntNode:getChildByName("Text_money")
		    local tagPos = totalBet:getParent():convertToWorldSpace(cc.p(totalBet:getPosition()))
			local startPos = playerNode:getParent():convertToWorldSpace(cc.p(playerNode:getPosition()))
			local flyTime = 0.2

			--固定5个金币
			for i=1,5 do
				local goldIcon = cc.Sprite:create()
				goldIcon:setSpriteFrame("game/yule/jdob/res/GUI/txz_jnd_bg.png")
				goldIcon:addTo(bgNode)
				local randomPos = genRandomPos(tagPos)
		        goldIcon:setPosition(randomPos)
		        goldIcon:stopAllActions()
		        goldIcon:runAction(cc.Sequence:create(
		            cc.Hide:create(),
		            cc.DelayTime:create((i-1)*0.03),
		            cc.Show:create(),
		            cc.MoveTo:create(0.15, cc.p(randomPos.x, randomPos.y+60)),
		            cc.MoveTo:create(0.15, cc.p(randomPos.x, randomPos.y-15)),
		            cc.MoveTo:create(0.1, cc.p(randomPos.x, randomPos.y+10)),
		            cc.MoveTo:create(0.1, cc.p(randomPos.x, randomPos.y)),
		            cc.DelayTime:create(0.6),
		            cc.MoveTo:create(flyTime, startPos),
		            cc.Hide:create()
		        ))
			end
			--收益文字上浮动画
			local numText = ccui.Text:create(g_format:formatNumber(cmdData.otherWins[i],g_format.fType.standard),"fonts/round_body.ttf",30)
		    --local numText = cc.LabelBMFont:create("0", "GUI/num_pic/shuijingfenshu.fnt")
		    numText:enableOutline(cc.c4b(139,67,27,255), 2)
		    numText:setPosition(cc.p(startPos.x, startPos.y+50))
		    numText:addTo(bgNode)
		    --numText:setScale(0.1)
			numText:setOpacity(0)
			numText:setPositionY(startPos.y+110)
		    numText:runAction(cc.Sequence:create(
		    	cc.DelayTime:create(1.42),
		    	cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, 10)), cc.FadeIn:create(0.5)),
		    	cc.DelayTime:create(0.6),
		    	cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, 10)), cc.FadeOut:create(0.5)),
	            cc.RemoveSelf:create()
	        ))
		end
	end
	bgNode:runAction(cc.Sequence:create(
    	cc.DelayTime:create(2.02),
    	cc.CallFunc:create(function ( ... )
            self:updateUserBetResult()
        end),
        cc.RemoveSelf:create()
    ))
end  
--更新座位上玩家结算后金币
function GameViewLayer:updateUserBetResult()
	local allUseBetInfo = self:getDataMgr():getAllUserBetScore()
	for i, v in ipairs(allUseBetInfo) do
		local playerMoney = self:getDataMgr():getChairUserList()[v.chairId + 1].lScore
		local playerInfo = {chairId = v.chairId, lScore = playerMoney}
		self.m_jdobPlayerNode:updatePlayerTotalCoinShow(playerInfo)
	end
end
--更新座位上玩家金币显示
function GameViewLayer:onUpdateBetPlayerCoin(_betInfoArray)
	tlog('GameViewLayer:onUpdateBetPlayerCoin')
	for i, v in ipairs(_betInfoArray) do
		local betTotalNum = v.betScore
		self.m_jdobPlayerNode:updatePlayerBetCoinShow(v.chairId, betTotalNum)
	end
end
--更新玩家信息
function GameViewLayer:updatePlayerShow(cmdData, _totalUpdate)
	tlog('GameViewLayer:updatePlayerShow ', _totalUpdate)
	self.m_jdobPlayerNode:flushPlayerNodeShow(self:getDataMgr():getChairUserList(), cmdData, _totalUpdate)
end
--游戏开始切到下注
function GameViewLayer:onSubGameStart(cmdData)	
	tlog('GameViewLayer:onSubGameStart ')
	--检测下注门槛
    self:checkJettonThreshold()

	self:clearBetQueue()
	self.sceneData.cbGameStatus = g_var(cmd).gameState.bet
	self.sceneData.cbAllTime = cmdData.cbTimeLeave
	self.sceneData.cbTimeLeave = cmdData.cbTimeLeave
	local timestamp = tickMgr:getTime()
	self.sceneData.gameStateStamp = timestamp + self.sceneData.cbTimeLeave
	self:updateTitlePanel()

	--开箱结束处理
	self.m_openBoxBgNode:stopAllActions()
	self.m_gameEndActionTime = false
	self:reSetUserInfo()
	self.betRecords = {isOpen = 0, cbBetCount = 0, cbBetArray = {}}
    self.betNumTb = {}
    self.sceneData.lAllBet = 0
    self.sceneData.lPlayBet = 0
    self:updateTotalBetNum()
    self:updateMyTotalBet()
    self.m_tableView:reloadData()
	self.goldObjectPool:foreachObject(function(goldIcon) 
		self.goldObjectPool:returnObject(goldIcon)
	end)
    -- for i = 1, self.m_showGoldIndex do
	-- 	if self.m_allGoldSpriteArray[i] then
	-- 		self.m_allGoldSpriteArray[i]:setVisible(false)
	-- 		self.m_allGoldSpriteArray[i]:stopAllActions()
	-- 	end
	-- end
    -- self.m_showGoldIndex = 0
	for j=1,5 do
    	local box = self.Panel_box:getChildByName("Panel_box"..j)
    	box:stopAllActions()
		box:getChildByName("node_anima"):removeAllChildren()
		box:getChildByName("node_boxText"):removeAllChildren()
		--[[box:getChildByName("img_box"):setVisible(true)
		box:getChildByName("node_box1"):getChildByTag(11):setVisible(false)
		box:getChildByName("node_box2"):getChildByTag(11):setVisible(false)--]]
		box:getChildByName("node_box1"):getChildByTag(11):setAnimation(0, "daiji", true)
		box:getChildByName("node_box2"):getChildByTag(11):setAnimation(0, "daiji", true)
    end
    --开奖提示
    if self.m_jdobTipNode:getNodeVisible() then
		self.m_jdobTipNode:setTipNodeVisible(false)
	end
end

function GameViewLayer:onGetUserScore(item)
	tlog('GameViewLayer:onGetUserScore ', item.dwUserID, GlobalUserItem.dwUserID)
	--自己
	if not self.m_gameEndActionTime then
		if item.dwUserID == GlobalUserItem.dwUserID then
	        self:reSetUserInfo()
	    end
	end
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

function GameViewLayer:playGamebgMusic()
    local musicPath = "sound_res/mus/bgr_music.mp3"
    tlog('GameViewLayer:playGamebgMusic ', musicPath)
    g_ExternalFun.stopMusic()
    g_ExternalFun.playMusic(musicPath, true)
end

--检测下注门槛
function GameViewLayer:checkJettonThreshold()
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        self.m_OverThreshold = GlobalUserItem.VIPLevel and GlobalUserItem.VIPLevel >= self.over_vip
        --门槛遮罩显示
        self.Panel_limit:setVisible(not self.m_OverThreshold)      
        -- if not self.m_OverThreshold then
        --     --重置自动下注
        --     self:setEnableXuYa(false)
        -- end     
    else
        self.m_OverThreshold = true
        self.Panel_limit:hide()
    end
end

return GameViewLayer