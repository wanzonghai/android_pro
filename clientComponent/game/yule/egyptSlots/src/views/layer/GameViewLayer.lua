local GameViewLayer = {}
GameViewLayer.RES_PATH              = "game/yule/egyptSlots/res/"

--	游戏一
local Game1ViewLayer = class("Game1ViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
GameViewLayer[1] = Game1ViewLayer
local module_pre = "game.yule.egyptSlots.src"
local ExternalFun = g_ExternalFun
local g_var = ExternalFun.req_var

local cmd = module_pre .. ".models.CMD_Game"

local PRELOAD = require(module_pre..".views.layer.PreLoading") 
local GameRule = appdf.req(module_pre .. ".views.layer.GameRule")

GameViewLayer.RES_PATH 				=  device.writablePath.."game/yule/egyptSlots/res/"--
local enGameLayer = 
{
	"TAG_SETTING_MENU",			--设置
	"TAG_QUIT_MENU",			--退出
	"TAG_START_MENU",			--开始按钮
    "TAG_GAME_RULE",			--游戏规则
    "TAG_HELP_CLOSE",      --游戏帮助
    "TAG_HELP_RULE1",      --游戏帮助
    "TAG_HELP_RULE2",      --游戏帮助
	"TAG_MAXADD_BTN",			--最大下注
	"TAG_MINADD_BTN",			--最小下注
	"TAG_ADD_BTN",				--加注
	"TAG_SUB_BTN",				--减注
	"TAG_AUTO_START_BTN",		--自动游戏
	"TAG_GAME2_BTN",			--开始游戏2
	"TAG_HIDEUP_BTN",			--隐藏上部菜单
	"TAG_SHOWUP_BTN",			--显示上部菜单
	"TAG_HALF_IN",				--半比
	"TAG_ALL_IN",				--全比
	"TAG_DOUBLE_IN",			--倍比
	"TAG_GAME2_EXIT",			--取分
	"TAG_SMALL_IN",				--押小
	"TAG_MIDDLE_IN",			--押和
	"TAG_BIG_IN",				--押大
	"TAG_GO_ON"					--继续
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(GameViewLayer.TAG_START, enGameLayer);

local emGame2Actstate =
{
	"STATE_WAITTING",					--等待
	"STATE_WAVE",						--摇奖
	"STATE_OPEN",						--开奖
	"STATE_RESULT"						--结算
}
local Game2_ACTSTATE =  ExternalFun.declarEnumWithTable(0, emGame2Actstate)

local emGame2State =
{
	"GAME2_STATE_WAITTING",				--等待
	"GAME2_STATE_WAVING",				--摇奖
	"GAME2_STATE_WAITTING_CHOICE",		--等待下注
	"GAME2_STATE_OPEN",					--开奖
	"GAME2_STATE_RESULT"				--结算,等待继续或区分
}
local GAME2_STATE = ExternalFun.declarEnumWithTable(0, emGame2State)

local emGameLabel =
{
	"LABEL_COINS",						--玩家金钱
	"LABEL_YAXIAN",						--压线
	"LABEL_YAFEN",						--压分
	"LABEL_TOTLEYAFEN",					--总压分
	"LABEL_GETCOINS",					--获取金钱
	"LABEL_GAME3_TIMES"					--小玛丽次数
}
local GAME2_STATE = ExternalFun.declarEnumWithTable(10, emGameLabel)

local RES_ID = 120

function Game1ViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)
	self._scene = scene
    --添加路径
    self:addPath()
    --预加载资源
	PRELOAD.loadTextures()
    self._jxlwBegin = false
	-- --初始化csb界面
	self:initCsbRes();

    self._txtHashId = cc.Label:createWithTTF("","fonts/round_body.ttf",28)
    self._txtHashId:setTextColor(cc.c4b(255,191,123,255))
    self._txtHashId:setAnchorPoint(cc.p(1,0.5))
    self._txtHashId:setPosition(1325,710)
    self:addChild(self._txtHashId)
    g_ExternalFun.playMusic("sound_res/bg_music.mp3", true)
    
end

function Game1ViewLayer:onExit()
    g_ExternalFun.stopMusic()
    PRELOAD.unloadTextures()
    PRELOAD.removeAllActions()

    PRELOAD.resetData()

    self:StopLoading(true)

    ExternalFun.removeAnimationSpine(RES_ID)

    --重置搜索路径
    local oldPaths = cc.FileUtils:getInstance():getSearchPaths();

    cc.FileUtils:getInstance():setSearchPaths(self._searchPath);
    local searchpath = cc.FileUtils:getInstance():getSearchPaths()
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game/yule/egyptSlots/res/gameicons.plist")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game/yule/egyptSlots/res/egitoslot/ani/gamelight.plist")
end

function Game1ViewLayer:StopLoading( bRemove )
    PRELOAD.StopAnim(bRemove)
end

function Game1ViewLayer:addPath( )

    self._searchPath = cc.FileUtils:getInstance():getSearchPaths()

	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH)
	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "game1/");
    cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "sound_res/"); --  声音
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/yule/egyptSlots/res/gameicons.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/yule/egyptSlots/res/egitoslot/ani/gamelight.plist")
end

---------------------------------------------------------------------------------------
--界面初始化
function Game1ViewLayer:initCsbRes(  )
    _,self._csbNode = ExternalFun.loadRootCSB(GameViewLayer.RES_PATH .."EJLB_Gamelayer.csb", self,true);
	self:initUI()
end

--初始化按钮
function Game1ViewLayer:initUI()
    local csbNode = self._csbNode
	--按钮回调方法
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

	--增加
	self.Button_Add = csbNode:getChildByName("panel_bottom"):getChildByName("btn_add")
	self.Button_Add:setTag(TAG_ENUM.TAG_ADD_BTN)
    self.Button_Add:addTouchEventListener(btnEvent)

	--减少
	self.Button_Sub = csbNode:getChildByName("panel_bottom"):getChildByName("btn_sub")
	self.Button_Sub:setTag(TAG_ENUM.TAG_SUB_BTN)
    self.Button_Sub:addTouchEventListener(btnEvent)

	--开始
	local Button_Start = csbNode:getChildByName("panel_bottom"):getChildByName("btn_Start")
    Button_Start:loadTextureDisabled("",1)
	Button_Start:setTag(TAG_ENUM.TAG_START_MENU);
    Button_Start:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			sender.touchTime = os.clock()
            performWithDelay(sender,function()
                self._scene:onAutoStart()
                ExternalFun.playClickEffect()
            end,0.6)
        elseif eventType == ccui.TouchEventType.canceled then
			sender:stopAllActions()
        elseif eventType == ccui.TouchEventType.ended then
            sender:stopAllActions()
            if self._scene.m_bIsAuto then
                return
            end
			self:onButtonClickedEvent(sender:getTag(), sender)
        end
	end);

    -- 停止
    local Button_Stop = csbNode:getChildByName("panel_bottom"):getChildByName("btn_Stop")
	Button_Stop:setTag(TAG_ENUM.TAG_AUTO_START_BTN)
    Button_Stop:addTouchEventListener(btnEvent)
    Button_Stop:setVisible(false)

    -- 押满
    self.Button_YaMan = csbNode:getChildByName("panel_bottom"):getChildByName("btn_max")
    self.Button_YaMan:addClickEventListener(function()
        ExternalFun.playSoundEffect("sound-tiger-line-button.mp3")
        if self._scene.m_FreeTime > 0 then return end
        self._scene.m_bYafenIndex = #self._scene.m_lBetScore-1
        self._scene.m_lYaxian = 9
        self._scene:onAddScore()
        self.m_lineCur = 9
    end)
   
    
	------
	--游戏币
	self.m_textScore = csbNode:getChildByName("panel_top"):getChildByName("img_goldbg"):getChildByName("gold")
    local gold = self._scene:GetMeUserItem().lScore
	local serverKind = G_GameFrame:getServerKind()
	self.m_textScore:setString(g_format:formatNumber(gold,g_format.fType.standard,serverKind))

    local goldbg = csbNode:getChildByName("panel_top"):getChildByName("img_goldbg")
    local icon = ccui.ImageView:create()
    goldbg:addChild(icon)
    icon:setPosition(cc.p(30,36))
    icon:setScale(1.2)
    local currencyType = G_GameFrame:getServerKind()
    g_ExternalFun.setIcon(icon,currencyType)

    --压分
    local yafenNode = csbNode:getChildByName("panel_bottom"):getChildByName("img_yagoldbg"):getChildByName("gold")
    yafenNode:setString("")
    local text = cc.Label:createWithBMFont("egypt_new_fnt.fnt", "")
    text:setPosition(0, 0)
    text:addTo(yafenNode)
	self.m_textAllyafen = text
    
	--得到分数
    local parentNode = csbNode:getChildByName("panel_bottom"):getChildByName("img_wingoldbg")
	local olddefen = parentNode:getChildByName("gold")
	self.m_textGetScore = ccui.TextBMFont:create()
    :setFntFile(GameViewLayer.RES_PATH .. "fonts/img_num.fnt")
    :setAnchorPoint(olddefen:getAnchorPoint())
    :setPosition(cc.p(olddefen:getPosition()))
    :addTo(parentNode)
    olddefen:hide()
	self.m_textGetScore:setString(0)

	self.m_textTips = csbNode:getChildByName("Text_Tips")
    self.m_textTips:setPosition(667,650)
    self.m_textTips:setFontSize(40)
    self.m_textTips:setTextColor(cc.c3b(255,0,0))
    self.m_textTips:setVisible(false)

	--菜单  
	self.m_nodeMenu = csbNode:getChildByName("panel_top"):getChildByName("panel_menu")
    self.m_Panel1 = csbNode:getChildByName("panel_mid"):getChildByName("Panel_1")

    --显示菜单
    self.isShowMenu = false
	local Button_Show = csbNode:getChildByName("panel_top"):getChildByName("btn_menu")
	Button_Show:setTag(TAG_ENUM.TAG_SHOWUP_BTN)
    Button_Show:addTouchEventListener(btnEvent)
    --隐藏
    self.btnMask = csbNode:getChildByName("btnMask")
    self.btnMask:setTag(TAG_ENUM.TAG_HIDEUP_BTN)
    self.btnMask:addTouchEventListener(btnEvent)

    self.NodeLine = csbNode:getChildByName("panel_mid"):getChildByName("NodeLine")
    self.m_Line={}
    --  self.m_LineNum={}
     local inePos = {cc.p(960,521),cc.p(960,740),cc.p(960,319),cc.p(960,483),cc.p(960,578),cc.p(960,658),cc.p(960,386),cc.p(960,535),cc.p(960,531)}
     for i=1,9 do
        -- self.m_LineNum[i] = self.NodeLine:getChildByName("lineNum"..i)
        -- self.m_LineNum[i]:setVisible(false)
        local spr = display.newSprite(GameViewLayer.RES_PATH .."egitoslot/gameline/"..i..".png")
        local ptr = cc.ProgressTimer:create(spr)
        :setPosition(inePos[i].x,inePos[i].y)
        :addTo(self.NodeLine)
        :setMidpoint(cc.p(0,0.5))
        ptr:setTag(i)
        ptr:setType(1)
		ptr:setBarChangeRate(cc.p(1,0))
		self.m_Line[i] = ptr
    end
    self.m_lineCur = 9
    self.nodeJs = csbNode:getChildByName("nodeJs")
    self.allGold = 0
    self.win_goldbg = self._csbNode:getChildByName("panel_bottom"):getChildByName("img_wingoldbg")
    self.win_img = self.win_goldbg:getChildByName("img")
    function self:showGold(num,gold)
        ExternalFun.playSoundEffect("fs_sound-get-gold.mp3")
        self.nodeJs:stopAllActions()
        tlog('showGold gold is ', gold)
        self.allGold = self.allGold+gold
        print("============gold:",gold,self.allGold,self._scene._allGold)
        -- if self._scene._allGold and self._scene._allGold > 0 then
        --     self.m_textGetScore:setString(self._scene._allGold)  --更新总赢分
        -- else
        --     self.m_textGetScore:setString(gold)  --更新总赢分
        -- end
        local serverKind = G_GameFrame:getServerKind()
        self.m_textGetScore:setString(g_format:formatNumber(gold,g_format.fType.standard,serverKind))  --更新当局赢分
        local time = 0.0
        local coin_x = 0
        local endPos = self.m_textScore:getParent():convertToWorldSpace(cc.p(self.m_textScore:getPosition()))
        local startPos = csbNode:getChildByName("panel_bottom"):getChildByName("img_wingoldbg"):getPositionX()
        for i=1,num do
            local spr = cc.Sprite:create("jxlw_icon_bean_effect.png")
            :addTo(self.nodeJs)
            local x = math.random(-30,30)
            local y = math.random(80,200)
            local z = math.random(20,50)
            spr:setPosition(startPos + x,self.m_textGetScore:getPositionY()+50)
            spr:setScale(0.5)
            spr:setVisible(false)
            spr:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.Show:create(),cc.Spawn:create(cc.MoveBy:create(0.25,cc.p(0,y)),cc.ScaleTo:create(0.25,0.8)),
            cc.Spawn:create(cc.MoveBy:create(0.2,cc.p(0,-y)),cc.ScaleTo:create(0.2,0.6)),cc.MoveBy:create(0.2,cc.p(0,z)),
            cc.MoveBy:create(0.2,cc.p(0,-z)),cc.MoveBy:create(0.2,cc.p(0,z)),
            cc.MoveBy:create(0.2,cc.p(0,-z)),cc.MoveTo:create(0.2,endPos),cc.RemoveSelf:create()))
            time = time+0.02
        end
        self.nodeJs:runAction(cc.Sequence:create(cc.DelayTime:create(time+2),cc.CallFunc:create(function()
            self.win_img:stopAllActions()
            self.win_img:setVisible(false)
        end)))
        self.win_img:setVisible(true)
        self.win_img:runAction(cc.RepeatForever:create(cc.Blink:create(1,2)))
    end

    self.m_fruitNode= {0,0,0,0,0}
    self.m_fruitNodePosY= {0,0,0,0,0}
    local startIcon = {
        10,9,8,
        6,3,4,
        7,3,11,
        5,3,12,
        10,9,8
    }  --产品需求默认icon
    for i=1,5 do
            self.m_fruitNode[i]=self.m_Panel1:getChildByName("fruitNode"..i) 
            self.m_fruitNodePosY[i]=self.m_fruitNode[i]:getPositionY()
            for j=1,30 do
                local t = math.random(1,14)
                if  j < 4 and startIcon[(i-1)*3+j] then
                    t = startIcon[(i-1)*3+j]
                end
                local sp2 = cc.SpriteFrameCache:getInstance():getSpriteFrame("game_icon_"..t..".png") --display.newSprite("gui-lfj-icon-8.png")  
                local spr = cc.Sprite:create()
                spr:setSpriteFrame(sp2);
                spr:setPosition(0,-(j-1)*205);
                self.m_fruitNode[i]:addChild(spr) 
                spr:setTag(j)
           end
        --    self.m_fruitNode[i]:setPositionY(self.m_fruitNodePosY[i]+1890)--125*15)
    end

	--返回
	local Button_back = self.m_nodeMenu:getChildByName("Button_back");
	Button_back:setTag(TAG_ENUM.TAG_QUIT_MENU);
	Button_back:addTouchEventListener(btnEvent);

    --设置
	local Button_Set = self.m_nodeMenu:getChildByName("Button_settting");
	Button_Set:setTag(TAG_ENUM.TAG_SETTING_MENU);
	Button_Set:addTouchEventListener(btnEvent);
	self:flushMusicResShow(Button_Set, GlobalUserItem.bSoundAble)

    --规则
	local Button_back = self.m_nodeMenu:getChildByName("ButtonRule");
	Button_back:setTag(TAG_ENUM.TAG_GAME_RULE);
	Button_back:addTouchEventListener(btnEvent);

    --免费次数
    self.sprFree = csbNode:getChildByName("panel_mid"):getChildByName("sprFree"):hide()
    self.sprFree:setPositionY(self.sprFree:getPositionY()+20)

    self.freebtn = csbNode:getChildByName("panel_bottom"):getChildByName("btn_Free"):hide()
    self.freebtnTxt = self.freebtn:getChildByName("num")
    self.freebtn:setEnabled(false)

   -- 场景状态
	self.maskColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 60)):addTo(self,1000):setPosition(0,0)
    :hide()
    function self:changeSceneState(baitian)
        if baitian then
            -- 白天
            self.maskColor:setVisible(false)
        else
            self.maskColor:setVisible(true)
        end
	end
	function self:getChangeState()
		return not self.maskColor:isVisible()
	end
end

--游戏1动画开始
function Game1ViewLayer:game1Begin()
    self.m_textTips:setVisible(false)
    self.Button_Add:setEnabled(false)
    self.Button_Sub:setEnabled(false)
    self.Button_YaMan:setEnabled(false)
    for i=1,9 do
        self.m_Line[i]:setPercentage(0)
        -- self.m_LineNum[i]:setVisible(false)
        -- self.m_LineNum[i]:stopAllActions()
    end
    -- self.aniLight:playAnimation("animation2",0,true)
    -- if self._jxlwBegin == true then
        for i=1,5 do
            for j=1,3 do
                local nodeStr = string.format("Node_%d_%d",i-1,j-1)
                local node = self._csbNode:getChildByName("panel_mid"):getChildByName("game_icon"):getChildByName(nodeStr)
                if node  then
                    node:removeChildByTag(1)
                end
                local spr=self.m_fruitNode[i]:getChildByTag(j)
                local spr2=self.m_fruitNode[i]:getChildByTag(9+j)
                spr2:setSpriteFrame(spr:getSpriteFrame());
                spr:setOpacity(255)
            end
        end
    -- end
    -- self._jxlwBegin = true
    for i=1,15 do
        local posx = math.ceil(i/3)
        local posy = (i-1)%3 + 1
        local nodeStr = string.format("Node_%d_%d",posx-1,posy-1)
        local nType = tonumber(self._scene.m_cbItemInfo[posy][posx])+1
        local sp2 = cc.SpriteFrameCache:getInstance():getSpriteFrame("game_icon_"..nType..".png") 
        local spr=self.m_fruitNode[posx]:getChildByTag(posy)
        spr:setSpriteFrame(sp2);
        spr:setVisible(true)
    end
    local delayTime = {0,0.1,0.2,0.3,0.4}
    for i=1,5 do
        self.m_fruitNode[i]:setPositionY(self.m_fruitNodePosY[i]+1845)--205*9)
        self.m_fruitNode[i].bEndAction = false
        local delay = cc.DelayTime:create(delayTime[i])
        local moveby6 = cc.MoveBy:create(0.6, cc.p(0, -1705))--[[-205*9+140 ))]]
        local moveby7 = cc.MoveBy:create(0.09, cc.p(0, -80))
        local moveby8 = cc.MoveBy:create(0.09, cc.p(0, -60))
        local moveby9 = cc.MoveBy:create(0.1, cc.p(0, -40))
        local moveby10 = cc.MoveBy:create(0.1, cc.p(0, -20))
        local moveby11 = cc.MoveBy:create(0.2, cc.p(0, 60))
        self.m_fruitNode[i]:runAction( cc.Sequence:create(delay,moveby6,moveby7,moveby8,moveby9,moveby10,moveby11,
             cc.CallFunc:create(function() self.m_fruitNode[i].bEndAction = true end)))
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
             self._scene:setGameMode(2) --表达GAME_STATE_MOVING
          end),cc.DelayTime:create(0.9),
          cc.CallFunc:create(function ( )
          self.Button_Add:setEnabled(true)
          self.Button_Sub:setEnabled(true)
          self.Button_YaMan:setEnabled(true)
          self:updateStartButtonState(true)
    	  if self._scene:getGameMode() == 2 then --表达GAME_STATE_MOVING
    	   	  self:game1GetLineResult()  
    	  end
    end)))
end
--手动停止滚动
function Game1ViewLayer:game1End(  )
    self._scene:setGameMode(3)
    self:stopAllActions()
    for i=1,5 do
        self.m_fruitNode[i]:stopAllActions()
        local moveby = cc.MoveBy:create(0.2, cc.p(0, 40))
        if self.m_fruitNode[i].bEndAction == false then
            self.m_fruitNode[i]:setPositionY(self.m_fruitNodePosY[i]-40)
            self.m_fruitNode[i]:runAction(cc.Sequence:create(moveby,cc.CallFunc:create(function()
               self.m_fruitNode[i].bEndAction = true
               if i == 5 then
                   self.Button_Add:setEnabled(true)
                   self.Button_Sub:setEnabled(true)
                   self.Button_YaMan:setEnabled(true)
                   self:updateStartButtonState(true)
                   self:game1GetLineResult()  
               end
            end)))
        end
    end
end
--更新用户分数 
function Game1ViewLayer:UpdateUserScore()
    if self._scene._lUserScore and self._scene._lUserScore >= 0 then
        local serverKind = G_GameFrame:getServerKind()
        self.m_textScore:setString(g_format:formatNumber(self._scene._lUserScore,g_format.fType.standard,serverKind))  --用户金币
    end
end
--游戏1结果
function Game1ViewLayer:game1Result()
    --2017.10.21 判断是否中奖状态
    local isWin = false
    self._scene:setGameMode(3) --GAME_STATE_RESULT
    if self._scene.m_lGetCoins > 0 then
        self:showGold(20,self._scene.m_lGetCoins)
        local nodeTip = self._csbNode:getChildByName("Node_win")
        nodeTip:setVisible(true)
        nodeTip:removeChildByTag(1)
        nodeTip:removeChildByTag(4)
        nodeTip:removeChildByTag(10)
        local nodeGold = cc.Node:create()
        nodeTip:addChild(nodeGold,10,10)
        nodeGold:setTag(10)
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(GameViewLayer.RES_PATH.."game1/effect/niyingle_laohuji/niyingle_laohuji0.png",GameViewLayer.RES_PATH.."game1/effect/niyingle_laohuji/niyingle_laohuji0.plist",
                        GameViewLayer.RES_PATH.."game1/effect/niyingle_laohuji/niyingle_laohuji.ExportJson")
        local amae=ccs.Armature:create("niyingle_laohuji")
        nodeTip:addChild(amae,1)
        if #self._scene.m_UserActionYaxian>2 then
             amae:getAnimation():play("Animation2") 
        else
             amae:getAnimation():play("Animation1") 
        end
        amae:setTag(1)
        amae:setVisible(false)
        local lYaFen = (self._scene.m_lTotalYafen / self._scene.m_lYaxian)
       nodeGold:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(function ()
            self:UpdateUserScore()
            ExternalFun.playSoundEffect("fs_sound-win.mp3")
            end)))
        local sty = 20
        local isleft=true
        local indexI = 1
        for lineIndex=1,#self._scene.m_UserActionYaxian do
            local pActionOneYaXian = self._scene.m_UserActionYaxian[lineIndex]
            if pActionOneYaXian then
                isWin = true  
                self:runAction(cc.Sequence:create(cc.CallFunc:create(function ()
                        local nodeTip = self._csbNode:getChildByName("Node_win")
                        if nodeTip  then
                                nodeTip:setVisible(true)
                                if indexI <= 8 then
                                    indexI = indexI+1
                                    if pActionOneYaXian.Xian == 12 then  --宝箱
                                        local count = pActionOneYaXian.cbDrawCount[pActionOneYaXian.nZhongJiangXian]
                                        local percent = {10,30,50}
                                        --太幸运啦，恭喜您击中奖池
                                        self.m_textTips:setString("Parabéns por ter acertado no premiozão%"..percent[count-2].."!")
                                        self.m_textTips:setVisible(true)
                                    else               
                                    end
                                end
                                local sp2 = cc.SpriteFrameCache:getInstance():getSpriteFrame("game_icon_"..(pActionOneYaXian.Xian+1)..".png") --display.newSprite("gui-lfj-icon-8.png")  
                                local winspr = cc.Sprite:create()
                                winspr:setSpriteFrame(sp2);
                                nodeGold:addChild(winspr,4,4)
                                winspr:setVisible(false)
                                winspr:setTag(4)

                                local  lfetx = -150
                                if isleft==false then 
                                    lfetx = 50
                                end
                                    self.sprFree:setVisible(self._scene.m_FreeTime>0)
                                    self.freebtn:setVisible(self._scene.m_FreeTime>0)
                                    self.freebtn:setEnabled(false)
                                    self.freebtnTxt:setString("/" .. self._scene.m_FreeTime)
                                
                                    self.sprFree:getChildByName("num"):setString("/" .. self._scene.m_FreeTime)
                                    if(self._scene.m_lGetCoins<1000) then
                                        winspr:setScale(0.5)
                                        winspr:setPosition(lfetx,sty)
                                    else
                                        winspr:setPosition(lfetx,sty)
                                        winspr:setScale(0.5)
                                    end
                                    if isleft==true then 
                                        isleft=false
                                    else
                                        isleft=true
                                        sty=sty-50
                                    end --隐藏
                                    nodeTip:runAction(cc.Sequence:create( cc.DelayTime:create(1),cc.Hide:create(),
                                        cc.CallFunc:create(function()self:updateStartButtonState(true)
                                    end)))
                            end

                    end)))
                end
            end
        else
        end
        if not isWin then -- 没中奖
            self:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(0.5),
                    cc.CallFunc:create(function ()
                        self:updateStartButtonState(true)
                    end )))
        end
        local fTime = 0.5
        if self._scene.m_lGetCoins > 0 then
            fTime = 1
        end
    if self._scene.m_bIsAuto == true and self._scene.m_lGetCoins > 0 then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(fTime),cc.CallFunc:create(function ()
    	    self._scene.m_bIsItemMove = false
    	    --游戏模式
    	    self._scene:setGameMode(4)  
    	    end),
            cc.DelayTime:create(1),
    	    cc.CallFunc:create(function()
                 --断线重连后
                 if self._scene.m_bReConnect1 == true then
                      local useritem = self._scene:GetMeUserItem()
                      if useritem.cbUserStatus ~= G_NetCmd.US_READY then 
                          self._scene:SendUserReady()
                      end
                      --发送准备消息
                      self._scene:sendReadyMsg()
                      self._scene.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
                      self._scene:setGameMode(1)
                      self._scene.m_bReConnect1 = false
                      print(" ---断线重连 over")
                      return
                 end
                 self._scene:setGameMode(5) --GAME_STATE_END
    	    	 end),
            cc.DelayTime:create(1.5),
            cc.CallFunc:create(function()
                         self._scene:onGameStart()
                  end)))
    else
        self:runAction(cc.Sequence:create(cc.DelayTime:create(fTime),cc.CallFunc:create(function (  )
    		self._scene.m_bIsItemMove = false
    		self._scene:setGameMode(5)
    		end),
            cc.DelayTime:create(1.5),
            cc.CallFunc:create(function (  )
                 --断线重连后
                 if self._scene.m_bReConnect1 == true then
                     local useritem = self._scene:GetMeUserItem()
                     if useritem.cbUserStatus ~= G_NetCmd.US_READY then 
                         self._scene:SendUserReady()
                     end
                     --发送准备消息
                     self._scene:sendReadyMsg()

                     self._scene.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
                     self._scene:setGameMode(1)
                     self._scene.m_bReConnect1 = false
                     print(" ---断线重连 over")
                     return
                 end
                 --发送消息
                 self._scene:setGameMode(5) --GAME_STATE_END
                 if self._scene.m_FreeTime > 0 or self._scene.m_bIsAuto == true then
                      self._scene:onGameStart()
                 end
           end)))
    end
end

--游戏连线结果
function Game1ViewLayer:game1GetLineResult(  )
	print("游戏连线结果")
    self._scene:setGameMode(3)  --GAME_STATE_RESULT
    ExternalFun.playSoundEffect("fs_gundong_1.mp3")
	for i=1,9 do
		self.m_Line[i]:setPercentage(0)
	end
	--绘制中奖线
	if self._scene.m_lGetCoins > 0 then
		--每条线间隔
		local delayTime =0.2-- 1.5
		for lineIndex=1,#self._scene.m_UserActionYaxian do
			local pActionOneYaXian = self._scene.m_UserActionYaxian[lineIndex]
			if pActionOneYaXian then
				self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime*(lineIndex-1)),cc.CallFunc:create(function ()
                    ExternalFun.playSoundEffect("fs_sound-tiger-win-line.mp3")
                        --如果是最后一个，进入结算界面
                    if lineIndex == #self._scene.m_UserActionYaxian then
                        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),
                            cc.CallFunc:create(function (  )
                                self:game1Result()
                        end)))
                    end
                    self.m_Line[pActionOneYaXian.nZhongJiangXian]:setVisible(true)
                    self.m_Line[pActionOneYaXian.nZhongJiangXian]:setPercentage(0)
                    self.m_Line[pActionOneYaXian.nZhongJiangXian]:stopAllActions()
                    self.m_Line[pActionOneYaXian.nZhongJiangXian]:runAction(cc.ProgressTo:create(0.3,100))
                    --设置每个精灵状态
                    for i=1,15 do
                        local posx = math.ceil(i/3)
                        local posy = (i-1)%3 + 1
                        local nodeStr = string.format("Node_%d_%d",posx-1,posy-1)
                        local node = self._csbNode:getChildByName("panel_mid"):getChildByName("game_icon"):getChildByName(nodeStr)
                        if node then
                            local _spr=self.m_fruitNode[posx]:getChildByTag(posy)
                            if self._scene._bZhongJiang[posy][posx] == true and pActionOneYaXian.cbDrawCount[pActionOneYaXian.nZhongJiangXian] then 
                                for j=1,pActionOneYaXian.cbDrawCount[pActionOneYaXian.nZhongJiangXian] do
                                    local pos = {}
                                    pos.x = pActionOneYaXian.ptXian[j].x
                                    pos.y = pActionOneYaXian.ptXian[j].y
                                    if pos.x == posy and pos.y == posx then
                                        local nType = tonumber(self._scene.m_cbItemInfo[posy][posx])+1
                                        node:removeChildByTag(1)
                                        local sp2 = cc.SpriteFrameCache:getInstance():getSpriteFrame("egito-slot_guangxiao1.png")
                                        local spr = cc.Sprite:create()
                                        spr:setSpriteFrame(sp2)
                                        spr:setTag(1)
                                        node:addChild(spr)
                                        local animation = cc.Animation:create()
                                        for i=1, 8 do
                                            local blinkFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("egito-slot_guangxiao%d.png",i))
                                            animation:addSpriteFrame(blinkFrame)
                                        end
                                    
                                        animation:setDelayPerUnit(0.1)
                                        animation:setRestoreOriginalFrame(true)
                                        local action = cc.Animate:create(animation)
                                        spr:runAction(cc.RepeatForever:create(action))
                                    end
                                end 
                            else
                                _spr:setOpacity(125)
                            end
                        end
                    end
                end)))
            end
            if #self._scene.m_UserActionYaxian == lineIndex then
                return
            end
        end
        self:game1Result()
	else
		self:game1Result()
	end
end

--音效音乐设置资源
function Game1ViewLayer:flushMusicResShow(_node, _enabled)
	_node:getChildByName('img1'):setVisible(_enabled)
	_node:getChildByName('img2'):setVisible(not _enabled)
end


function Game1ViewLayer:onButtonClickedEvent(tag,ref)
	if tag == TAG_ENUM.TAG_QUIT_MENU then  			--退出
        self._scene.m_bIsLeave = true
        -- self._scene:onKeyBack()
        self._scene:onExitTable()
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_START_MENU  then    		--开始游戏
        if self._scene.m_FreeTime <= 0 then
		    self._scene:onGameStart()
        else
            --免费游戏中，请稍后
            showToast("Jogo gratuito em curso, aguarde")
        end
        ExternalFun.playSoundEffect("sound-tiger-line-button.mp3")
	elseif tag == TAG_ENUM.TAG_SETTING_MENU  then    --	设置
        GlobalUserItem.setSoundAble(not GlobalUserItem.bSoundAble)
		self:flushMusicResShow(ref, GlobalUserItem.bSoundAble)
        ExternalFun.playClickEffect()
   elseif tag == TAG_ENUM.TAG_HELP_RULE1  then      --游戏帮助
       self.RulePanel1:setVisible(true)
       self.RulePanel2:setVisible(false)
       self.RuleButton1:setEnabled(false)
       self.RuleButton2:setEnabled(true)
    elseif tag == TAG_ENUM.TAG_HELP_RULE2  then      --游戏帮助
        self.RulePanel1:setVisible(false)
        self.RulePanel2:setVisible(true)
        self.RuleButton1:setEnabled(true)
        self.RuleButton2:setEnabled(false)
	elseif tag == TAG_ENUM.TAG_MAXADD_BTN  then    --	最大加注
        if(self._scene.m_FreeTime <=0)then
	    	self._scene:onAddMaxScore()
        else  
            showToast("Jogo gratuito em curso, aguarde")
        end
        --声音
        ExternalFun.playSoundEffect("shangfen.mp3")
	elseif tag == TAG_ENUM.TAG_MINADD_BTN  then    --	最小减注
        if(self._scene.m_FreeTime <=0)then
	    	self._scene:onAddMinScore()
        end
        --声音
        ExternalFun.playSoundEffect("shangfen1.mp3")
	elseif tag == TAG_ENUM.TAG_ADD_BTN  then    --	加注
        if(self._scene.m_FreeTime <=0)then
            self._scene:onAddScore()
        else
            showToast("Jogo gratuito em curso, aguarde")
        end
        ExternalFun.playSoundEffect("sound-tiger-line-button.mp3")
	elseif tag == TAG_ENUM.TAG_SUB_BTN  then    --	减注
        if(self._scene.m_FreeTime <=0)then
		    self._scene:onSubScore()
        end
        --声音
        ExternalFun.playSoundEffect("shangfen1.mp3")
	elseif tag == TAG_ENUM.TAG_AUTO_START_BTN  then   --自动游戏
        if(self._scene.m_FreeTime <=0)then
		    self._scene:onAutoStart()
        else
            showToast("Jogo gratuito em curso, aguarde")
        end
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_GAME2_BTN  then    --	开始游戏2
		self._scene:onEnterGame2()
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_HIDEUP_BTN  then   --隐藏上部菜单
		
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_SHOWUP_BTN  then   --显示上部菜单
        if self.isShowMenu then
            self:onHideTopMenu(true)
        else
            self:onShowTopMenu()
        end
        -- self.isShowMenu = not self.isShowMenu
    elseif tag == TAG_ENUM.TAG_GAME_RULE then     --游戏规则
        
        self:onHelpLayer()
	else
        --功能尚未开放！
		showToast("Funcionalidade não disponível!")
	end
end

--隐藏上部菜单
function Game1ViewLayer:onHideTopMenu(isMove)
    if isMove then
        self.isShowMenu = false
        -- self.btnMask:setVisible(false)
        local nodex = self.m_nodeMenu:getPositionX()
        local nodey = self.m_nodeMenu:getPositionY()
        local sizeY = self.m_nodeMenu:getContentSize().height
        self.m_nodeMenu:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeTo:create(0.2,50),cc.MoveTo:create(0.2,cc.p(nodex,nodey + sizeY + 130))),cc.Hide:create()))
        print("===========self.m_nodeMenu:getPositionX() 111:",self.m_nodeMenu:getPositionY())
    end
end

--显示上部菜单
function Game1ViewLayer:onShowTopMenu()
    self.isShowMenu = true
    -- self.btnMask:setVisible(true)
    self.m_nodeMenu:setVisible(true)
    local nodex = self.m_nodeMenu:getPositionX()
    local nodey = self.m_nodeMenu:getPositionY()
    local sizeY = self.m_nodeMenu:getContentSize().height
    self.m_nodeMenu:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeTo:create(0.2,255),cc.MoveTo:create(0.2,cc.p(nodex,nodey-sizeY-140))),cc.MoveTo:create(0.1,cc.p(nodex,nodey-sizeY-130))))
    print("===========self.m_nodeMenu:getPositionX() 222:",self.m_nodeMenu:getPositionY())
end

function Game1ViewLayer:onHelpLayer(  )
    self:onHideTopMenu(true)
    local help = GameRule:create()
    self._csbNode:addChild(help)
    help:setLocalZOrder(9)
end

--自动游戏
function Game1ViewLayer:setAutoStart( bisShow )
    local Button_Start = self._csbNode:getChildByName("panel_bottom"):getChildByName("btn_Start")
    local Button_Stop = self._csbNode:getChildByName("panel_bottom"):getChildByName("btn_Stop")
    Button_Start:setVisible(not bisShow)
    Button_Stop:setVisible(bisShow)
end

--切换开始按钮和停止按钮的纹理
function Game1ViewLayer:updateStartButtonState( bIsStart)
    local Button_Start = self._csbNode:getChildByName("panel_bottom"):getChildByName("btn_Start")
    Button_Start:setEnabled(bIsStart)
    --Button_Start:set
end


function Game1ViewLayer:Game1ZhongxianAudio( bIndex )
    local soundPath = 
    {
        "winsound.mp3",
        "winsound.mp3",
        "winsound.mp3",
        "luzhisheng.mp3",
        "lincong.mp3",
        "songjiang.mp3",
        "titianxingdao.mp3",
        "zhongyitang.mp3",
        "shuihuchuan3.mp3"
    }
    ExternalFun.playSoundEffect(soundPath[bIndex])
end


return GameViewLayer