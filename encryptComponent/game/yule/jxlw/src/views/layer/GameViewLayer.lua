local GameViewLayer = {}
GameViewLayer.RES_PATH              = "game/yule/jxlw/res/"

--	游戏一
local Game1ViewLayer = class("Game1ViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
GameViewLayer[1] = Game1ViewLayer
local module_pre = "game.yule.jxlw.src"
local ExternalFun = g_ExternalFun
local g_var = ExternalFun.req_var

local cmd = module_pre .. ".models.CMD_Game"

local GameItem = appdf.req(module_pre .. ".views.layer.GameItem")
local PRELOAD = require(module_pre..".views.layer.PreLoading") 

local SettingLayer = appdf.req(module_pre .. ".views.layer.SettingLayer")
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")
local BankLayer=appdf.req(module_pre .. ".views.layer.BankLayer")

GameViewLayer.RES_PATH 				=  device.writablePath.."game/yule/jxlw/res/"--
local enGameLayer = 
{
	"TAG_SETTING_MENU",			--设置
	"TAG_QUIT_MENU",			--退出
	"TAG_START_MENU",			--开始按钮
	"TAG_HELP_MENU",			--游戏帮助
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

    self:playBackgroundMusic()
end

function Game1ViewLayer:playBackgroundMusic()
    ExternalFun.playBackgroudAudio("fs_xiongdiwushu.mp3")
end

function Game1ViewLayer:onExit()
    PRELOAD.unloadTextures()
    PRELOAD.removeAllActions()

    PRELOAD.resetData()

    self:StopLoading(true)

    ExternalFun.removeAnimationSpine(RES_ID)

    --重置搜索路径
    local oldPaths = cc.FileUtils:getInstance():getSearchPaths();

    cc.FileUtils:getInstance():setSearchPaths(self._searchPath);
    local searchpath = cc.FileUtils:getInstance():getSearchPaths()

end

function Game1ViewLayer:StopLoading( bRemove )
    PRELOAD.StopAnim(bRemove)
end

function Game1ViewLayer:addPath( )

    self._searchPath = cc.FileUtils:getInstance():getSearchPaths()

	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH)
	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "game1/");
	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "game2/");
	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "game3/");

	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "common/");
	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "setting/");
    cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "sound_res/"); --  声音

end

---------------------------------------------------------------------------------------
--界面初始化
function Game1ViewLayer:initCsbRes(  )
	-- rootLayer, self._csbNode = ExternalFun.loadRootCSB(GameViewLayer.RES_PATH .."SHZ_Game1Layer.csb", self);
    self._csbNode = ExternalFun.loadCSB(GameViewLayer.RES_PATH .."SHZ_Game1Layer.csb", self,false);
    -- local spBg = cc.Sprite:create(GameViewLayer.RES_PATH .."image_battle_bacground2.jpg")
    -- local imgBg = self._csbNode:getChildByName("Image_1")
    -- imgBg:hide()
    -- spBg:setPosition(imgBg:getPosition())
    -- self._csbNode:addChild(spBg,-10)
	--初始化按钮
    -- rootLayer:setPosition(-2,-2)
	self:initUI(self._csbNode)
end

local ANI_PATH = GameViewLayer.RES_PATH .."animation/spine/"

--初始化按钮
function Game1ViewLayer:initUI( csbNode )
	--按钮回调方法
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end
	--减少
	self.Button_Add = csbNode:getChildByName("Image_btn"):getChildByName("Button_Add");
	self.Button_Add:setTag(TAG_ENUM.TAG_ADD_BTN);
    self.Button_Add:addTouchEventListener(btnEvent);
    self.Button_Sub = csbNode:getChildByName("Image_btn"):getChildByName("Button_Sub");
	self.Button_Sub:setTag(TAG_ENUM.TAG_SUB_BTN);
    self.Button_Sub:addTouchEventListener(btnEvent);
    -- 线
    self.Button_Line = csbNode:getChildByName("btnLine")
    -- 押满
    self.Button_YaMan = csbNode:getChildByName("btnYaMan")

	--开始
	local Button_Start = csbNode:getChildByName("Button_Start");
    Button_Start:loadTextureDisabled("",1)
	Button_Start:setTag(TAG_ENUM.TAG_START_MENU);
    Button_Start:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			-- sender.touchTime = os.clock()
   --          performWithDelay(sender,function()
   --              self._scene:onAutoStart()
   --              ExternalFun.playClickEffect()
   --          end,0.6)
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
    --自动下注
    local Button_Auto = csbNode:getChildByName("Button_Auto");
    Button_Auto:setTag(TAG_ENUM.TAG_AUTO_START_BTN);
    Button_Auto:addTouchEventListener(btnEvent)
    -- ExternalFun.newAnimationSpine(RES_ID,"jxlw_startmenu",ANI_PATH)
    -- :addTo(Button_Start)
    -- :setPosition(Button_Start:getContentSize().width/2,Button_Start:getContentSize().height/2)
    -- :playAnimation("animation",0,true)
    -- 停止
 --    local Button_Stop = csbNode:getChildByName("Button_Stop");
	-- Button_Stop:setTag(TAG_ENUM.TAG_AUTO_START_BTN);
 --    Button_Stop:addTouchEventListener(btnEvent)
 --    Button_Stop:setVisible(false)
	--显示菜单
	local Button_Show = csbNode:getChildByName("Button_Show");
	Button_Show:setTag(TAG_ENUM.TAG_SHOWUP_BTN);
    Button_Show:addTouchEventListener(btnEvent);
    self.Button_Show = Button_Show
    self.Button_Show:loadTextures("jxlm_btn_back.png","jxlm_btn_back.png")
    self.Button_Show:setContentSize(cc.size(133,133))
    self.Button_Show:setScale(0.7)
    self.Button_Show:setScale9Enabled(true)

    -- 押满
    local btnYaMan = csbNode:getChildByName("btnYaMan");
    btnYaMan:addClickEventListener(function()
        ExternalFun.playSoundEffect("sound-tiger-line-button.mp3")
        if self._scene.m_FreeTime > 0 then return end
        -- self._scene.m_bYafenIndex = #self._scene.m_lBetScore-1
        -- self._scene.m_lYaxian = 9
        -- self._scene:onAddScore()
        -- self.m_lineCur = 9
        self:showLine(9)
    end)
   
	------
	--游戏币
    local oldTextNode = csbNode:getChildByName("Text_score");
    self.m_textScore = ccui.TextBMFont:create()
    :setFntFile(GameViewLayer.RES_PATH .. "fonts/num1.fnt")
    :setAnchorPoint(oldTextNode:getAnchorPoint())
    :setPosition(cc.p(oldTextNode:getPosition()))
    :addTo(csbNode)
    oldTextNode:hide()
    local serverKind = G_GameFrame:getServerKind()
    local gold = self._scene:GetMeUserItem().lScore
    gold = g_format:formatNumber(self._scene:GetMeUserItem().lScore,g_format.fType.standard,serverKind)
	self.m_textScore:setString(gold)
	--压线
	self.m_textYaxian = csbNode:getChildByName("Text_yaxian");
	self.m_textYaxian:setString(g_var(cmd).YAXIANNUM)
	--压分
    local yafenNode = csbNode:getChildByName("Image_btn"):getChildByName("Text_yafen")
    yafenNode:setString("")
    -- local text = cc.Label:createWithBMFont(GameViewLayer.RES_PATH .. "fonts/num2.fnt", "")
    -- text:setAnchorPoint(cc.p(0, 0.5))
    -- text:setPosition(0, 0)
    -- text:addTo(yafenNode)
    self.m_textYafen = yafenNode

    self.m_textAllyafen = csbNode:getChildByName("Image_btn"):getChildByName("Text_allyafen");
    -- self.m_textAllyafen = ccui.TextBMFont:create()
    -- :setFntFile(GameViewLayer.RES_PATH .. "fonts/num1.fnt")
    -- :setAnchorPoint(oldYafenNode:getAnchorPoint())
    -- :setPosition(cc.p(oldYafenNode:getPosition()))
    -- :addTo(csbNode)
    -- oldYafenNode:hide()
    self.m_textAllyafen:setString("")
	--得到分数
    self.m_textGetScore = csbNode:getChildByName("Image_score_bg"):getChildByName("Text_getscore");
	-- self.m_textGetScore = ccui.TextBMFont:create()
    -- :setFntFile(GameViewLayer.RES_PATH .. "fonts/num1.fnt")
    -- :setAnchorPoint(oldGetNode:getAnchorPoint())
    -- :setPosition(cc.p(oldGetNode:getPosition()))
    -- :addTo(csbNode)
    -- oldGetNode:hide()
	self.m_textGetScore:setString(0)

	self.m_textTips = csbNode:getChildByName("Text_Tips")
    self.m_textTips:setPosition(667,650)
    self.m_textTips:setFontSize(40)
    self.m_textTips:setTextColor(cc.c3b(255,0,0))
    self.m_textTips:setVisible(false)
	

    local  nodedeng = csbNode:getChildByName("dengNode")
    self.m_LightNode=csbNode:getChildByName("dengLightNode")--nodedeng:getChildByName("dengLightNode")
    self.m_LightNode:getAnimation():play("Animation1") 

    local serverKind = G_GameFrame:getServerKind()
    local jiangchiBG = nodedeng:getChildByName("AtlasLabel_8")
    local newJiangchiBG = ccui.TextBMFont:create()
    :setFntFile(GameViewLayer.RES_PATH .. "fonts/num3.fnt")
    :setAnchorPoint(jiangchiBG:getAnchorPoint())
    :setPosition(cc.p(jiangchiBG:getPosition()))
    :setString(g_format:formatNumber(80000000000000,g_format.fType.standard,serverKind))
    :setOpacity(20)
    :addTo(nodedeng)
    jiangchiBG:hide()

    local jiangchiNode = nodedeng:getChildByName("gold_jiangchi")
    self.m_Jiangjin = ccui.TextBMFont:create()
    :setFntFile(GameViewLayer.RES_PATH .. "fonts/num3.fnt")
    :setAnchorPoint(jiangchiNode:getAnchorPoint())
    :setPosition(cc.p(jiangchiNode:getPosition()))
    :addTo(nodedeng)
    jiangchiNode:hide()
    self.m_Jiangjin:setString("0")
    function self:setJianjin(num)
        if self.jianjinOld then
            local s = num-self.jianjinOld
            self.jianjinOld = num
            num = s
        else
            self.jianjinOld = num
        end
        ExternalFun.digitalScroll(self.m_Jiangjin,num)
    end

	--菜单  
	self.m_nodeMenu = csbNode:getChildByName("Node_Menu");
    self.m_Panel1 = csbNode:getChildByName("Panel_1");
    self.NodeLine = csbNode:getChildByName("NodeLine");
    self.m_Line={}

     self.m_LineNum={}
     local inePos = {cc.p(671,429),cc.p(671,567),cc.p(671,295),cc.p(671,420),cc.p(671,440),cc.p(671,480),cc.p(671,376),cc.p(671,433),cc.p(671,435)}
     for i=1,9 do
        self.m_LineNum[i] = self.NodeLine:getChildByName("lineNum"..i)
        self.m_LineNum[i]:setVisible(false)
        local spr = display.newSprite(GameViewLayer.RES_PATH .."game1/"..i..".png")
        local ptr = cc.ProgressTimer:create(spr)
        :setPosition(inePos[i].x,inePos[i].y)
        :addTo(self.NodeLine)
        :setMidpoint(cc.p(0,0.5))
        ptr:setTag(i)
        ptr:setType(1)
		ptr:setBarChangeRate(cc.p(1,0))
		self.m_Line[i] = ptr
    end
    function self:showLine(num)
        local numCur = num
        if numCur == nil then
            numCur = self.m_lineCur
        end
        for i=1,numCur do
            self.m_Line[i]:setPercentage(100)
        end
        for i=numCur+1,9 do
            self.m_Line[i]:setPercentage(0)
        end
        csbNode:getChildByName("txtLine"):setString(self.m_lineCur)
    end
    self.m_lineCur = 9
    local btnLine = csbNode:getChildByName("btnLine");
    btnLine:setTouchEnabled(false);
    btnLine:setVisible(false)
    btnLine:addClickEventListener(function()
        ExternalFun.playSoundEffect("sound-tiger-line-button.mp3")
        if self._scene.m_FreeTime > 0 then 
            --免费游戏中，请稍后
            showToast("Jogo gratuito em curso, aguarde")
            return
        end
        self.m_lineCur = self.m_lineCur+1
        if self.m_lineCur > 9 then
            self.m_lineCur = 1
        end
		self._scene:onAddLine()
        self:showLine()
    end)
    local txtLine = csbNode:getChildByName("txtLine")
    txtLine:setVisible(false)
    self.nodeJs = csbNode:getChildByName("nodeJs")
    self.nodePar = csbNode:getChildByName("nodePar"):hide()
    local oldTexJsNum = csbNode:getChildByName("txtJsNum")
    self.txtJsNum  = ccui.TextBMFont:create()
    :setFntFile(GameViewLayer.RES_PATH .. "fonts/num4.fnt")
    :setAnchorPoint(oldTexJsNum:getAnchorPoint())
    :setPosition(cc.p(oldTexJsNum:getPosition()))
    :addTo(csbNode)
    oldTexJsNum:hide()
    self.txtJsNum:setVisible(false)
    self.allGold = 0
    function self:showGold(num,gold)
        ExternalFun.playSoundEffect("fs_sound-get-gold.mp3")
        self.nodeJs:stopAllActions()
        self.txtJsNum:setVisible(true)
        local serverKind = G_GameFrame:getServerKind()
        self.txtJsNum:setString(g_format:formatNumber("+"..gold,g_format.fType.standard,serverKind))
        tlog('showGold gold is ', gold)
        -- ExternalFun.digitalScroll(self.txtJsNum,gold,{charAdd="/"})
        self.nodePar:setVisible(true)
        self.allGold = self.allGold+gold
        if self._scene._allGold and self._scene._allGold > 0 then
            local serverKind = G_GameFrame:getServerKind()
            self.m_textGetScore:setString(g_format:formatNumber(self._scene._allGold,g_format.fType.standard,serverKind))  --更新总赢分
        else
            local serverKind = G_GameFrame:getServerKind()
            self.m_textGetScore:setString(g_format:formatNumber(self._allGold,g_format.fType.standard,serverKind))  --更新总赢分
        end
        local time = 0.0
        local coin_x = 0
        if g_offsetX == 0 then
            coin_x = display.cx / 1.44
        else
            coin_x = display.cx-g_offsetX*2
        end
        for i=1,num do
            local spr = cc.Sprite:create("jxlw_icon_bean_effect.png")
            :addTo(self.nodeJs)
            local x = math.random(-150,150)
            local y = math.random(80,200)
            local z = math.random(20,50)
            spr:setPosition(coin_x+x,display.cy)
            spr:setScale(0.3)
            spr:setVisible(false)
            spr:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.Show:create(),cc.Spawn:create(cc.MoveBy:create(0.25,cc.p(0,y)),cc.ScaleTo:create(0.25,0.8)),
            cc.Spawn:create(cc.MoveBy:create(0.2,cc.p(0,-y)),cc.ScaleTo:create(0.2,0.6)),cc.MoveBy:create(0.2,cc.p(0,z)),
            cc.MoveBy:create(0.2,cc.p(0,-z)),cc.MoveBy:create(0.2,cc.p(0,z)),
            cc.MoveBy:create(0.2,cc.p(0,-z)),cc.MoveTo:create(0.2,cc.p(245,185)),cc.RemoveSelf:create()))
            time = time+0.02
        end
        self.nodeJs:runAction(cc.Sequence:create(cc.DelayTime:create(time+2),cc.CallFunc:create(function()
            self.txtJsNum:setVisible(false)
            self.nodePar:setVisible(false)
        end)))
    end

    

    self.m_fruitNode= {0,0,0,0,0}
    self.m_fruitNodePosY= {0,0,0,0,0}
    for i=1,5 do
            self.m_fruitNode[i]=self.m_Panel1:getChildByName("fruitNode"..i) 
            self.m_fruitNodePosY[i]=self.m_fruitNode[i]:getPositionY()
            for j=1,30 do
                --[[local sp2 = cc.SpriteFrameCache:getInstance():getSpriteFrame("gui-lfj-icon-box.png") --display.newSprite("gui-lfj-icon-8.png")  
                local  spr = cc.Sprite:create()
                spr:setSpriteFrame(sp2);
                spr:setPosition(0,-(j-1)*126);
                spr:setVisible(false)
                self.m_fruitNode[i]:addChild(spr) ]]
			    
                local  t = math.random(1,14)
                local sp2 = cc.SpriteFrameCache:getInstance():getSpriteFrame("gui-lfj-icon-"..t..".png") --display.newSprite("gui-lfj-icon-8.png")  
                local spr = cc.Sprite:create()
                spr:setSpriteFrame(sp2);
                spr:setPosition(0,-(j-1)*126);
                --[[local ttfLabel = cc.LabelTTF:create(j,"Times New Roman",40)
                ttfLabel:setPosition(spr:getContentSize().width/2,spr:getContentSize().height/2)
                spr:addChild(ttfLabel)]]
                if i == 3 and j == 17 then
                    --spr:setScale(1.1)
                end
                self.m_fruitNode[i]:addChild(spr) 
                spr:setTag(j)
           end
           self.m_fruitNode[i]:setPositionY(self.m_fruitNodePosY[i]+1890)--125*15)
        end

	--返回
	local Button_back = self.m_nodeMenu:getChildByName("Button_back");
	Button_back:setTag(TAG_ENUM.TAG_QUIT_MENU);
	Button_back:addTouchEventListener(btnEvent);

    -- bank
    self.m_nodeMenu:getChildByName("Button_bank")
	:addClickEventListener(function() 
		self:showBank()
	end)
    --帮助
	local Button_Help = self.m_nodeMenu:getChildByName("ButtonRule");
	Button_Help:setTag(TAG_ENUM.TAG_HELP_MENU);
	Button_Help:addTouchEventListener(btnEvent);
  self.RulePanel = csbNode:getChildByName("PanelRule")
  self.RulePanel:setVisible(false)
  local Button_Help_CLOSE = self.RulePanel:getChildByName("ButtonClose");
  Button_Help_CLOSE:setTag(TAG_ENUM.TAG_HELP_CLOSE);
  Button_Help_CLOSE:addTouchEventListener(btnEvent);
  self.RulePanel1 = self.RulePanel:getChildByName("Panel_3")
  self.RulePanel1:setVisible(true)
  self.RulePanel2 = self.RulePanel:getChildByName("ScrollView_1")
  self.RulePanel2:setVisible(false)

  self.RuleButton1 = self.RulePanel:getChildByName("ButtonRule1")
  self.RuleButton1:setEnabled(false)
  self.RuleButton2 = self.RulePanel:getChildByName("ButtonRule2")
  self.RuleButton2:setEnabled(true)
  self.RuleButton1:setTag(TAG_ENUM.TAG_HELP_RULE1);
  self.RuleButton1:addTouchEventListener(btnEvent);
  self.RuleButton2:setTag(TAG_ENUM.TAG_HELP_RULE2);
  self.RuleButton2:addTouchEventListener(btnEvent);


    --设置
	local Button_Set = self.m_nodeMenu:getChildByName("Button_settting");
	Button_Set:setTag(TAG_ENUM.TAG_SETTING_MENU);
	Button_Set:addTouchEventListener(btnEvent);
    --隐藏
    self.btnMask = csbNode:getChildByName("btnMask")
    self.btnMask:setTag(TAG_ENUM.TAG_HIDEUP_BTN);
    self.btnMask:addTouchEventListener(btnEvent);
	local Button_Hide = csbNode:getChildByName("Button_Hide");
	Button_Hide:setTag(TAG_ENUM.TAG_HIDEUP_BTN);
    Button_Hide:addTouchEventListener(btnEvent);
    self.Button_Hide = Button_Hide

	self.Node_top = csbNode:getChildByName("Node_top");

	self.Node_btnEffet = csbNode:getChildByName("Node_btnEffet")
    local node_notice_bg=csbNode:getChildByName("toast_bg")
    self.NoticeText= node_notice_bg:getChildByName("notice")

   self.imgJs = csbNode:getChildByName("imgJs")
   self.imgJs:setVisible(false)
   self.nodeAni = csbNode:getChildByName("nodeAni")
   self.nodeAni:setVisible(false)
   

   self.sprFree = csbNode:getChildByName("sprFree"):hide()
   self.sprFree:setPositionY(self.sprFree:getPositionY()+20)
   self.sprFree:setSpriteFrame("jxlw_free_frame.png")
   self.sprFree:getChildByName("num"):setAnchorPoint(cc.p(0, 0.5))
   self.sprFree:getChildByName("num"):setPosition(380,42)
   self.sprFreeText = cc.Sprite:createWithSpriteFrameName("jxlw_free_text.png")
   self.sprFreeText:setPosition(316,41)
   self.sprFree:addChild(self.sprFreeText)
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


  self.nodeTip = csbNode:getChildByName("nodeTip")
  self.aniLight = ExternalFun.newAnimationSpine(RES_ID,"jxlw_gamelight",ANI_PATH)
       :addTo(csbNode:getChildByName("bgAni"))
       :setPosition((display.cx-g_offsetX)/1.44,display.cy/1.44)
       :playAnimation("animation2",0,true)
       :setTimeScale(0.6)

   ExternalFun.newAnimationSpine(RES_ID,"jxlw_firetioskuangeffectb",ANI_PATH)
        :addTo(self.nodeTip)
        :setPosition(672,700)
        :playAnimation("idle",0,true)
        ExternalFun.newAnimationSpine(RES_ID,"jxlw_firetioskuangeffecta",ANI_PATH)
        :addTo(self.nodeTip)
        :setPosition(672,700)
        :playAnimation("idle",0,true)
        self.nodeTip:setVisible(false)

end

--游戏1动画开始
function Game1ViewLayer:game1Begin()
    self.m_textTips:setVisible(false)
    self.Button_Add:setEnabled(false)
    self.Button_Line:setEnabled(false)
    self.Button_YaMan:setEnabled(false)
    for i=1,9 do
        self.m_Line[i]:setPercentage(0)
        self.m_LineNum[i]:setVisible(false)
        self.m_LineNum[i]:stopAllActions()
    end
    self.imgJs:setVisible(false)
    self.nodeAni:setVisible(false)
    self.aniLight:playAnimation("animation2",0,true)
    if self._jxlwBegin == true then
        for i=1,5 do
            for j=1,3 do
                local nodeStr = string.format("Node_%d_%d",i-1,j-1)
                local node = self._csbNode:getChildByName(nodeStr)
                if node  then
                    node:removeChildByTag(1)
                end
                local spr=self.m_fruitNode[i]:getChildByTag(j)
                local spr2=self.m_fruitNode[i]:getChildByTag(15+j)
                spr2:setSpriteFrame(spr:getSpriteFrame());
                spr:setOpacity(225)
            end
        end
    end
    self._jxlwBegin = true
    for i=1,15 do
        local posx = math.ceil(i/3)
        local posy = (i-1)%3 + 1
        local nodeStr = string.format("Node_%d_%d",posx-1,posy-1)
        local nType = tonumber(self._scene.m_cbItemInfo[posy][posx])+1
        local sp2 = cc.SpriteFrameCache:getInstance():getSpriteFrame("gui-lfj-icon-"..nType..".png") 
        local spr=self.m_fruitNode[posx]:getChildByTag(posy)
        spr:setSpriteFrame(sp2);
        spr:setVisible(true)
    end
    local delayTime = {0,0.1,0.2,0.3,0.4}
    for i=1,5 do
        self.m_fruitNode[i]:setPositionY(self.m_fruitNodePosY[i]+1890)--125*15)
        self.m_fruitNode[i].bEndAction = false
        local delay = cc.DelayTime:create(delayTime[i])
        local moveby6 = cc.MoveBy:create(0.6, cc.p(0, -1750))--[[-125*15+140 ))]]
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
          self.Button_Line:setEnabled(true)
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
                   self.Button_Line:setEnabled(true)
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
     if self.armature1 then 
         self.armature1:removeFromParent()
         self.armature1 = nil
     end
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
        -- lYaFen = 210
       if false and self._scene.m_lGetCoins / lYaFen >= 200 then
            self.nodeTip:setVisible(true)
            --恭喜玩家
            --中奖，获得
            --金币
            self.NoticeText:setString("Parabéns【"..self._scene:GetMeUserItem().szNickName.."】Prêmio"..self._scene.m_lGetCoins.."Moedas de ouro");
            self.NoticeText:setPositionX(665);
            self.NoticeText:runAction(cc.Sequence:create( cc.MoveBy:create(7.5,cc.p(-1000,0)) ,cc.CallFunc:create(function()
                 self.nodeTip:setVisible(false)end)))
       end
       nodeGold:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(function ()
                                            self:UpdateUserScore()
                                            local endScoreStr =  "mutipleNum.png"
                                             self.m_LightNode:runAction(cc.Sequence:create(                                        
                                             cc.DelayTime:create(2.2),
                                             cc.CallFunc:create(function ()
                                                 ExternalFun.playSoundEffect("fs_sound-tiger-stop.WAV")
                                             end )))
                                             ExternalFun.playSoundEffect("fs_sound-win.mp3")
                                             self:setJianjin(self._scene.m_lJiangjin)
                                          end)))
    self.imgJs:setVisible(false)                            
    for i=1,8 do
        self.imgJs:getChildByName("sprJs"..i):setVisible(false)
    end
    self.aniLight:playAnimation("animation",0,true)
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
                                self.nodeAni:setVisible(true)
                                self.imgJs:setVisible(true)
                                local jsNum = self.imgJs:getChildByName("sprJs"..indexI)
                                jsNum:setVisible(true)
                                indexI = indexI+1
                                jsNum:setSpriteFrame("gui-lfj-icon-"..(pActionOneYaXian.Xian+1)..".png")
                                if pActionOneYaXian.Xian == 12 then  --宝箱
                                     local count = pActionOneYaXian.cbDrawCount[pActionOneYaXian.nZhongJiangXian]
                                     jsNum:getChildByName("num"):setString(count)
                                     local percent = {10,30,50}
                                     --太幸运啦，恭喜您击中奖池
                                     self.m_textTips:setString("Parabéns por ter acertado no premiozão%"..percent[count-2].."!")
                                     self.m_textTips:setVisible(true)
                                else      
                                     jsNum:getChildByName("num"):setString(pActionOneYaXian.lXianScore)           
                                end
                            end
                            local sp2 = cc.SpriteFrameCache:getInstance():getSpriteFrame("gui-lfj-icon-"..(pActionOneYaXian.Xian+1)..".png") --display.newSprite("gui-lfj-icon-8.png")  
                            local  winspr = cc.Sprite:create()
                            winspr:setSpriteFrame(sp2);
                            nodeGold:addChild(winspr,4,4)
                            winspr:setVisible(false)
                            winspr:setTag(4)

                            local endScoreStr =  "zhongjiang_num.png"
                            local labNum = cc.LabelAtlas:_create(txtCellScoreStr,GameViewLayer.RES_PATH.."game1/" .. endScoreStr,101,101,string.byte("0"))
                            labNum:setAnchorPoint(cc.p(0,0.5))
                            print("self:runAction5")
                            nodeGold:addChild(labNum,5,5)
                            labNum:setVisible(false)
                            
                            local nLen = labNum:getContentSize().width
                            labNum:setString(pActionOneYaXian.lXianScore)
                            local  lfetx = -150
                            if isleft==false then 
                                 lfetx = 50
                            end
                              self.sprFree:setVisible(self._scene.m_FreeTime>0)
                              self.sprFree:getChildByName("num"):setString(self._scene.m_FreeTime)
                              if(self._scene.m_lGetCoins<1000) then
                                   winspr:setScale(0.5)
                                   labNum:setScale(0.25)
                                   winspr:setPosition(lfetx,sty)
                                   labNum:setPosition(lfetx+65,sty)
                              else
                                   winspr:setPosition(lfetx,sty)
                                   winspr:setScale(0.5)
                                   labNum:setScale(0.18)
                                   labNum:setPosition(lfetx+65,sty)
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
         self:setJianjin(self._scene.m_lJiangjin)
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
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function()
                               --self._scene:SendUserReady()
                               --self._scene:sendReadyMsg()
                         self._scene:onGameStart()
                  end)))
   else
      self:runAction(cc.Sequence:create(cc.DelayTime:create(fTime),cc.CallFunc:create(function (  )
    		self._scene.m_bIsItemMove = false
    		self._scene:setGameMode(5)
    		end),
            cc.DelayTime:create(0.5),
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
                      --self._scene:SendUserReady()
                      --self._scene:sendReadyMsg()
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
        self.m_LineNum[i]:setVisible(false)
        self.m_LineNum[i]:stopAllActions()
	end
    
    local pathLine = 
    {
    	"prizeLine/01.png",
    	"prizeLine/02.png",
    	"prizeLine/03.png",
    	"prizeLine/04.png",
    	"prizeLine/05.png",
    	"prizeLine/06.png",
    	"prizeLine/07.png",
    	"prizeLine/08.png",
    	"prizeLine/09.png",
	}
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
                self.m_LineNum[pActionOneYaXian.nZhongJiangXian]:runAction(cc.RepeatForever:create(cc.Blink:create(1,1)))
			    local isBoxWin = false
			    --设置每个精灵状态
			    for i=1,15 do
			    	local posx = math.ceil(i/3)
			    	local posy = (i-1)%3 + 1
			    	local nodeStr = string.format("Node_%d_%d",posx-1,posy-1)
			    	local node = self._csbNode:getChildByName(nodeStr)
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
                                       local ANI_PATH = GameViewLayer.RES_PATH .."animation/spine/"
                                       local aniName = ""
                                       if(nType==11) then 
                                           aniName = "jxlw_gameobjbar"
                                       elseif(nType==12) then 
                                           aniName = "jxlw_gameobjzs"
                                       elseif(nType==13) then 
                                           aniName = "jxlw_gameobjbaoxiang"
                                           isBoxWin = true
                                       elseif(nType==14) then
                                           aniName = "jxlw_gameobj37"
                                       end
                                  --else
                                       if nType == 1 then
                                           aniName = "jxlw_gameobjlizhi"
                                       elseif nType == 2 then
                                           aniName = "jxlw_gameobjjuzi"
                                       elseif nType == 3 then
                                           aniName = "jxlw_gameobjmangguo"
                                       elseif nType == 4 then
                                           aniName = "jxlw_gameobjxigua"
                                       elseif nType == 5 then
                                           aniName = "jxlw_gameobjpinguo"
                                       elseif nType == 6 then
                                           aniName = "jxlw_gameobjyingtao"
                                       elseif nType == 7 then
                                           aniName = "jxlw_gameobjputao"
                                       elseif nType == 8 then
                                           aniName = "jxlw_gameobjlingdang"
                                       elseif nType == 9 then
                                           aniName = "jxlw_gameobjxiangjiao"
                                       elseif nType == 10 then
                                           aniName = "jxlw_gameobjboluo"
                                       end
                                      self.armature0 =ExternalFun.newAnimationSpine(RES_ID,aniName,ANI_PATH)
                                          :addTo(node)
                                          :playAnimation("animation",0,true)
                                      self.armature0:setTag(1)
                                      _spr:setVisible(false)
                                   end
                                end 
                            else
                                 _spr:setOpacity(125)
                            end
                        end
	                end
                  if isBoxWin then
                       self.armature1 =ExternalFun.newAnimationSpine(RES_ID,"bigwin",ANI_PATH)
                           :addTo(self)
                           :setPosition(667,375)
                           :playAnimation("animation",0,false)
                       self.armature1:setTag(2)
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


function Game1ViewLayer:onButtonClickedEvent(tag,ref)
	if tag == TAG_ENUM.TAG_QUIT_MENU then  			--退出
        self._scene.m_bIsLeave = true
        self._scene:onKeyBack()
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
		self:onSetLayer()
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_HELP_MENU  then    	--游戏帮助
       self:onHelpLayer()
       ExternalFun.playClickEffect()
   elseif tag == TAG_ENUM.TAG_HELP_CLOSE  then      --游戏帮助
       self.RulePanel:setVisible(false)
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
        --ExternalFun.playSoundEffect("sound-tiger-line-button.mp3")
	elseif tag == TAG_ENUM.TAG_SUB_BTN  then    --	减注
        if(self._scene.m_FreeTime <=0)then
		    self._scene:onSubScore()
        end
        --声音
        --ExternalFun.playSoundEffect("shangfen1.mp3")
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
		self:onHideTopMenu()
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_SHOWUP_BTN  then   --显示上部菜单
		self._scene:onExitTable()
	else
        --功能尚未开放！
		showToast("Funcionalidade não disponível!")
	end
end

--隐藏上部菜单
function Game1ViewLayer:onHideTopMenu()
    self.Button_Show:setVisible(true)
    self.Button_Hide:setVisible(false)
    self.btnMask:setVisible(false)
    self.m_nodeMenu:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeTo:create(0.2,50),cc.MoveTo:create(0.2,cc.p(132,963))),cc.Hide:create()))
end

--显示上部菜单
function Game1ViewLayer:onShowTopMenu()
    self.Button_Show:setVisible(false)
    self.Button_Hide:setVisible(true)
    self.btnMask:setVisible(true)
    self.m_nodeMenu:setVisible(true)
    self.m_nodeMenu:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeTo:create(0.2,255),cc.MoveTo:create(0.2,cc.p(132,393))),cc.MoveTo:create(0.1,cc.p(132,403))))
end
--声音设置界面
function Game1ViewLayer:onSetLayer(  )
    self:onHideTopMenu()
	local set = SettingLayer:create(self)
    self._csbNode:addChild(set)
    set:setLocalZOrder(9)
end

function Game1ViewLayer:onHelpLayer(  )
    self:onHideTopMenu()
    local help = HelpLayer:create()
    self._csbNode:addChild(help)
    help:setLocalZOrder(9)
end

--自动游戏
function Game1ViewLayer:setAutoStart( bisShow )
    -- local Button_Start = self._csbNode:getChildByName("Button_Start")
    -- local Button_Stop = self._csbNode:getChildByName("Button_Stop")
    -- Button_Start:setVisible(not bisShow)
    -- Button_Stop:setVisible(bisShow)
    local Button_Auto = self._csbNode:getChildByName("Button_Auto")
    if bisShow then
        Button_Auto:loadTextureNormal ("auto_down.png",ccui.TextureResType.plistType)
    else
        Button_Auto:loadTextureNormal ("auto_up.png",ccui.TextureResType.plistType)
    end
end

--切换开始按钮和停止按钮的纹理
function Game1ViewLayer:updateStartButtonState( bIsStart)
    -- local Button_Start = self._csbNode:getChildByName("Button_Start");
    -- Button_Start:setEnabled(bIsStart)
    --Button_Start:set
    -- local Button_Auto = self._csbNode:getChildByName("Button_Auto")
    -- Button_Auto:loadTextureNormal ("auto_up.png",ccui.TextureResType.plistType)
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


-- 申请取款
function Game1ViewLayer:sendTakeScore(lScore, szPassword)
    self._scene:sendTakeScore(lScore,szPassword)
end

-- 打开银行
function Game1ViewLayer:showBank()
    tlog("Game1ViewLayer:showBank")
    self:onHideTopMenu()
	--银行未开通
	if 0 == GlobalUserItem.cbInsureEnabled then
		showToast("Usado pela primeira vez, dirija-se ao centro para abrir seu banco primeiro!")
		return
	end	
    if self._scene.m_bIsAuto == true then
        showToast("Jogo automático em curso, as operações bancárias não podem ser realizadas")
        return
    end
    if self._scene:getGameMode() ~= 0 and self._scene:getGameMode() ~= 5 then 
        showToast("Jogo em curso, as operações bancárias não podem ser realizadas")
        return
    end
	self._bankLayer = BankLayer:create(self,function()
		self._bankLayer = nil
	end)
	self:addChild(self._bankLayer,50) 
end

--银行操作成功
function Game1ViewLayer:onBankSuccess()
	if self._bankLayer and not tolua.isnull(self._bankLayer) then
		self._bankLayer:onBankSuccess(self._scene.bank_success)
		local serverKind = G_GameFrame:getServerKind()
		self.m_textScore:setString(g_format:formatNumber(self._scene:GetMeUserItem().lScore,g_format.fType.standard,serverKind))
	end
end

function Game1ViewLayer:onBankFailure()
	if self._bankLayer and not tolua.isnull(self._bankLayer) then
		self._bankLayer:onBankFailure(self._scene.bank_fail)
	end
end

function Game1ViewLayer:onGetBankInfo(bankinfo)
	if self._bankLayer and not tolua.isnull(self._bankLayer) then
		self._bankLayer:onGetBankInfo(bankinfo)
	end
end


return GameViewLayer