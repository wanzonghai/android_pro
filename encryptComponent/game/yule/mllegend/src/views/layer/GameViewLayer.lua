local GameViewLayer = class("GameViewLayer", function(scene)
    local gameViewLayer = display.newLayer()
    return gameViewLayer
end )

GameViewLayer.RES_PATH = "game/yule/mllegend/res/"

local module_pre = "game.yule.mllegend.src"
local ExternalFun = g_ExternalFun--require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var

local cmd = module_pre .. ".models.CMD_Game"

local SettingLayer = appdf.req(module_pre .. ".views.layer.SettingLayer")
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")
local ScrollLayer = appdf.req(module_pre .. ".views.layer.ScrollLayer")

local GameItem = appdf.req(module_pre .. ".views.layer.GameItem")

local GameLogic = appdf.req(module_pre .. ".models.GameLogic")

local WinLayer = appdf.req(module_pre .. ".views.layer.WinLayer")

local Number = appdf.req(module_pre .. ".views.layer.Number")

local scheduler = cc.Director:getInstance():getScheduler()

local enGameLayer =
{
    "TAG_SETTING_BTN",-- 设置
    "TAG_MUSIC_BTN",-- 音乐
    "TAG_EFFECT_BTN",-- 音效
    "TAG_QUIT_BTN",-- 退出
    "TAG_QUIT_REPLAY_BTN",-- 退出重播
    "TAG_START_BTN",-- 开始按钮
    "TAG_HELP_BTN",-- 游戏帮助
    "TAG_MAXADD_BTN",-- 最大下注
    "TAG_MINADD_BTN",-- 最小下注
    "TAG_ADD_BTN",-- 加注
    "TAG_SUB_BTN",-- 减注
    "TAG_XIAN_BTN",--压线
    "TAG_AUTO_START_BTN",-- 自动游戏
    "TAG_AUTO_STOP_BTN",
    "TAG_GAME2_BTN",-- 开始游戏2
    "TAG_HIDEUP_BTN",-- 隐藏上部菜单
    "TAG_SHOWUP_BTN",-- 显示上部菜单
    "TAG_GO_ON",-- 继续
    "TAG_BANK_BTN",--银行
    "TAG_GET_SCORE",--得分
    "TAG_STOP_BTN",--停止
    "TAG_MENU_BTN",--菜单
    "TAG_LACKYPLAYER_BTN",--幸运玩家
    "TAG_ADD_SCORE",--加注界面
    
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(GameViewLayer.TAG_START, enGameLayer);

function GameViewLayer:ctor(scene)
    -- 注册node事件
    ExternalFun.registerNodeEvent(self)
    self._scene = scene
    self._isCreated  = false;
    self.isFreeGame = false  --是否在游戏中
    -- 预加载资源
end


function GameViewLayer:created()
    
    -- --初始化csb界面
    self:initCsbRes();
    self:onInitData();


    self._isCreated  = true;

end

function GameViewLayer:onExit() 
    self:closeClock()

    
end

function GameViewLayer:performWithDelay(delay,callback)
    if delay == 0 then
        local call =  cc.CallFunc:create(callback)
        self:runAction(call)
        return call;
    end
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    self:runAction(sequence)
    return sequence
end


---------------------------------------------------------------------------------------
-- 界面初始化
function GameViewLayer:initCsbRes()

    local csbNode = ExternalFun.loadCSB("game_csb/GameLayer.csb", self,false);
    self._csbNode = csbNode

    self:initData()
    self:initUI()

  
end

function GameViewLayer:initData()
    self.m_WinLight = {};
    self.m_Panel_AllShu = nil;
    self._setLayer = nil;
    self._helpLayer = nil;

end

function GameViewLayer:onInitData()


    self.m_bIsStop = false;
    self._AutoOpen = false;
    self._winScoreAni = true
    
    self._WinTypePosX = 0;
   
    math.randomseed(tostring(os.time()):reverse():sub(1,7))    
end
-- 初始化按钮
function GameViewLayer:initUI()
    -- 按钮回调方法
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            ExternalFun.popupTouchFilter(1, false)
            self:OnButtonBegan(sender:getTag(), sender)
        elseif eventType == ccui.TouchEventType.moved then
            self:OnButtonMoved(sender:getTag(), sender)
        elseif eventType == ccui.TouchEventType.canceled then
            ExternalFun.dismissTouchFilter()
            self:OnButtonCanceled(sender:getTag(), sender)
        elseif eventType == ccui.TouchEventType.ended then
            ExternalFun.dismissTouchFilter()
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

    local csbNode = self._csbNode

------------Panel_Top
    local imagebg = csbNode:getChildByName("Image_bg")
    imagebg:loadTexture("common/ml_bg.jpg")
    imagebg:setContentSize(cc.size(1624,750))
    --设置
    local btn = csbNode:getChildByName("btn_set");
    btn:setTag(TAG_ENUM.TAG_SETTING_BTN)
    btn:addTouchEventListener(btnEvent);

    if btn:getChildByName("open") then 
        btn:getChildByName("open"):setVisible(GlobalUserItem.bVoiceAble)
    end 
    if btn:getChildByName("close") then 
        btn:getChildByName("close"):setVisible(not GlobalUserItem.bVoiceAble)
    end 

    GlobalUserItem.setVoiceAble(GlobalUserItem.bVoiceAble)
    GlobalUserItem.setSoundAble(GlobalUserItem.bVoiceAble)




    --退出
    btn = csbNode:getChildByName("btn_back");
    btn:setTag(TAG_ENUM.TAG_QUIT_BTN)
    btn:addTouchEventListener(btnEvent);
    --帮助
    btn = csbNode:getChildByName("btn_help");
    btn:setTag(TAG_ENUM.TAG_HELP_BTN)
    btn:addTouchEventListener(btnEvent);  
    -- 开始
    btn = csbNode:getChildByName("btn_start");
    btn:setTag(TAG_ENUM.TAG_START_BTN)
    btn:addTouchEventListener(btnEvent);
    btn:setEnabled(false)
    self.m_btnStart = btn
    --self.m_btnStart:setPositionY(self.m_btnStart:getPositionY() + 5)
    --自动
    btn = csbNode:getChildByName("btn_auto");
    btn:setTag(TAG_ENUM.TAG_AUTO_START_BTN)
    btn:addTouchEventListener(btnEvent);
    self.m_btnAuto = btn
    --self.m_btnAuto:setPositionY(self.m_btnAuto:getPositionY() + 5)
    --加注
    btn = csbNode:getChildByName("btn_add");
    btn:setTag(TAG_ENUM.TAG_ADD_BTN)
    btn:addTouchEventListener(btnEvent);
    self.m_btnAdd = btn
    --减注
    btn = csbNode:getChildByName("btn_sub");
    btn:setTag(TAG_ENUM.TAG_SUB_BTN)
    btn:addTouchEventListener(btnEvent);
    self.m_btnSub = btn
    --最大
    btn = csbNode:getChildByName("btn_max");
    btn:setTag(TAG_ENUM.TAG_MAXADD_BTN)
    btn:addTouchEventListener(btnEvent);
    self.m_btnMaxAdd = btn
    self.m_btnMaxAdd:setPositionY(self.m_btnMaxAdd:getPositionY() + 5)

    -- local txt = csbNode:getChildByName("txt_add")
    -- local bmFont = Number:create("2_")
    -- bmFont:setString("")   
    -- bmFont:addTo(txt)   
    -- self.m_textYafen = bmFont

--    txt = csbNode:getChildByName("txt_xian")
--    local bmFont = ccui.TextBMFont:create()
--    bmFont:setFntFile("font/llj_sz1.fnt")
--    bmFont:setString("")   
--    bmFont:addTo(txt)
--    self.m_textYaxian = bmFont

    --总下注
    txt= csbNode:getChildByName("txt_addmax")
    -- bmFont = cc.Label:createWithBMFont("plist/mellegend_fnt_1.fnt", "")  
    -- bmFont:addTo(txt)  
    -- bmFont:setScale(0.7)  
    -- self.m_textAllyafen = bmFont
    -- self.m_textAllyafen:setPositionY(self.m_textAllyafen:getPositionY() + 5)
    self.m_textAllyafen = txt:getChildByName("txt_yafen")
    self.m_textYafen = txt:getChildByName("txt_difen")
    --玩家金币
    local txt_score= csbNode:getChildByName("txt_score");
    -- bmFont = cc.Label:createWithBMFont("plist/mellegend_fnt_1.fnt", "")
    -- bmFont:setScale(0.7)    
    -- bmFont:addTo(txt_score)
    -- self.m_textScore = bmFont
    -- self.m_textScore:setPositionY(self.m_textScore:getPositionY() + 5)
    self.m_textScore = txt_score:getChildByName("txt_player_score")
    --累计输赢
    local txt_winscore= csbNode:getChildByName("txt_win")
    -- bmFont = cc.Label:createWithBMFont("plist/mellegend_fnt_1.fnt", "0")
    -- bmFont:setScale(0.7)
    -- bmFont:addTo(txt_winscore)
    -- self.m_textWinScore = bmFont
    -- self.m_textWinScore:setPositionY(self.m_textWinScore:getPositionY() + 5)
    self.m_textWinScore = txt_winscore:getChildByName("txt_win")

    local getscore = cc.Sprite:create()
    getscore:setPosition(cc.p(667,375))
    --getscore:setAnchorPoint(0.5,0.5)
    getscore:addTo(csbNode,10)
    self.m_GetScore = getscore

    --得分
    -- bmFont = Number:create("0_")
    -- bmFont:setString("")
    -- bmFont:setScale(0.7)
    -- --bmFont:setPosition(cc.p(ylAll.WIDTH/2,ylAll.HEIGHT/2))
    -- --bmFont:setAnchorPoint(0.5,0.5)
    -- bmFont:addTo(getscore)
    -- bmFont:setName("txt")

    local fntNode = ccui.TextBMFont:create()
    :setFntFile(GameViewLayer.RES_PATH .. "font/mllegend_0.fnt")
    :setAnchorPoint(0.5,0.5)
    :setPosition(cc.p(0,0))
    :setName("txt")
    :setString("")
    :addTo(getscore)



    local ani = cc.Sprite:create()
    ani:addTo(getscore)
    ani:setName("ani")

--    local jsonPath = "animation/jinbi.json"
--    local atlasPath = "animation/jinbi.atlas"
--    local ani = sp.SkeletonAnimation:create(jsonPath, atlasPath, 1)
--    ani:addTo(self,10)
--    ani:setPosition(cc.p(ylAll.WIDTH / 2, ylAll.HEIGHT / 2))

--    self.m_winAni = ani;
    --灯线
--    for i=1,g_var(cmd).YAXIANNUM do
--        local Light = {};
--        local line = csbNode:getChildByName("line"):getChildByName( string.format("line_%d",i))
--        line:setVisible(false)
--        Light[3] = line

--        self.m_WinLight[i] = Light;
--    end
    --muit_node
    self.m_tabLevelList = {}
    for i=1,5 do 
        local level = csbNode:getChildByName("muit_node"):getChildByName("x"..i)
        if level then 
            level:setVisible(false)
            self.m_tabLevelList[i] = level
        end
    end




    local Panel_AllShu = csbNode:getChildByName("Panel_AllShu")
    Panel_AllShu:setClippingEnabled(true)
    self.m_ScrollLayer =  ScrollLayer:create(self,1)
    self.m_ScrollLayer:addTo(Panel_AllShu)

    --freegame
    self.m_FreeTime_BG = csbNode:getChildByName("freegame")
    self.m_FreeTime_BG:setVisible(false)

    local txt = self.m_FreeTime_BG:getChildByName("txt_win"):getChildByName("txt")
    if txt == nil then
        txt = cc.Label:createWithBMFont("plist/mellegend_fnt_2.fnt", "")
        txt:addTo(self.m_FreeTime_BG:getChildByName("txt_win"))
        txt:setName("txt")
    end  
    self.m_pfreewin = txt




    local ani = ExternalFun.loadTimeLine("game_csb/renwu.csb")
    local csb = cc.CSLoader:createNode("game_csb/renwu.csb")
    ani:gotoFrameAndPlay(0,true)
    csb:addTo(self)
    csb:runAction(ani)
    csb:move(cc.p(100,120))

    --[[self._txtHashId = cc.Label:createWithTTF("","fonts/round_body.ttf",28)
    self._txtHashId:setTextColor(cc.c4b(255,191,123,255))
    self._txtHashId:setAnchorPoint(cc.p(1,0.5))
    self._txtHashId:setPosition(1308,640)
    self:addChild(self._txtHashId)  ]]
end



-- 按键回调
function GameViewLayer:onButtonClickedEvent(tag, ref)
   
    
    if tag == TAG_ENUM.TAG_START_BTN then 
        ExternalFun.playSoundEffect("Start.wav3")
    else 
        --ExternalFun.playSoundEffect("Click.wav")
    end


    if tag == TAG_ENUM.TAG_QUIT_BTN then --退出           
        --self._scene:onQueryExitGame()
        if self.isFreeGame then
            showToast(g_language:getString("game_prohibit_leave"))
        else
            self._scene:onExitTable()
        end
    elseif tag == TAG_ENUM.TAG_QUIT_REPLAY_BTN  then --退出重播   
        
    elseif tag == TAG_ENUM.TAG_SETTING_BTN then
        self:onSetLayer(ref)-- 游戏帮助 
    elseif tag == TAG_ENUM.TAG_MUSIC_BTN  then --音乐
        
    elseif tag == TAG_ENUM.TAG_EFFECT_BTN  then --音效
        
    elseif tag == TAG_ENUM.TAG_START_BTN then   -- 开始游戏         
        self:onGameStart()
    elseif tag == TAG_ENUM.TAG_AUTO_START_BTN then
        self:onAutoGameStart()
    elseif  tag == TAG_ENUM.TAG_STOP_BTN then   --停止   
        
    elseif tag == TAG_ENUM.TAG_GET_SCORE then   --得分
          
    elseif tag == TAG_ENUM.TAG_HELP_BTN then               
        self:onHelpLayer()-- 游戏帮助      
    elseif tag == TAG_ENUM.TAG_ADD_BTN then -- 加注
        self._scene:onAddScore()
    elseif tag == TAG_ENUM.TAG_SUB_BTN then 
        self._scene:onSubScore()
    elseif tag == TAG_ENUM.TAG_MAXADD_BTN then -- 最大加注
        self._scene:onAddMaxScore()
    elseif tag == TAG_ENUM.TAG_XIAN_BTN then -- 压线        
              
    elseif tag == TAG_ENUM.TAG_BANK_BTN then  
        self:onBankLayer()   
    elseif tag == TAG_ENUM.TAG_MENU_BTN then 
        
    elseif tag == TAG_ENUM.TAG_AUTO_COUNT then

    elseif tag == TAG_ENUM.TAG_LACKYPLAYER_BTN then
        print("----------------------------------")
    else
        showToast("Funcionalidade não disponível!")
    end
end

function GameViewLayer:OnButtonBegan(tag, ref)
    if tag == TAG_ENUM.TAG_START_BTN then     
        --self:createClock()     
    end


    if tag == TAG_ENUM.TAG_BANK_BTN 
        or tag == TAG_ENUM.TAG_HELP_BTN 
        or tag == TAG_ENUM.TAG_EFFECT_BTN
        or tag == TAG_ENUM.TAG_MUSIC_BTN
        or tag == TAG_ENUM.TAG_MENU_BTN then
        return true
    else   
       
    end

end

function GameViewLayer:OnButtonMoved(tag, ref)
    return true
end

function GameViewLayer:OnButtonCanceled(tag, ref)
    if tag == TAG_ENUM.TAG_START_BTN then       
        self:closeClock()
    end
end

function GameViewLayer:createClock()
    local time = 1
    local function update()
        time = time+1
        if time>=3 then
            if self._scene.m_bIsAuto == true or self._scene.m_bFreetime or self._scene.m_cbGameStatus == g_var(cmd).SHZ_GAME_SCENE_FREETIME then
                self:closeClock()
                return 
            end
            self._AutoOpen = true;
            self.m_btnStart:loadTextures("game/tiger/gui/gui-tiger-btn-start-2.png","game/tiger/gui/gui-tiger-btn-start-2-click.png","game/tiger/gui/gui-tiger-btn-start-2-click.png",UI_TEX_TYPE_PLIST)
            self._scene:onAutoStart()
        end
        --print(time)
    end
    if nil == self.m_scheduleUpdate then
        self.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 1.0, false)
    end
end

function GameViewLayer:closeClock()
    if nil ~= self.m_scheduleUpdate then
        scheduler:unscheduleScriptEntry(self.m_scheduleUpdate)
        self.m_scheduleUpdate = nil
    end
end

function GameViewLayer:updateScore(notAnimation)
    local serverKind = G_GameFrame:getServerKind()
    local yafen = g_format:formatNumber(self._scene.m_lYafen,g_format.fType.abbreviation,serverKind)
    self.m_textYafen:setString(self._scene.m_lYaxian.."x"..yafen)
    local serverKind = G_GameFrame:getServerKind()
    self.m_textAllyafen:setString(g_format:formatNumber(self._scene.m_lTotalYafen,g_format.fType.abbreviation,serverKind))
    local serverKind = G_GameFrame:getServerKind()
    self.m_textScore:setString(g_format:formatNumber(self._scene.m_lScore,g_format.fType.abbreviation,serverKind))
    local serverKind = G_GameFrame:getServerKind()
    self.m_textWinScore:setString(g_format:formatNumber(self._scene.m_lWinScore,g_format.fType.abbreviation,serverKind))
end

function GameViewLayer:updataBtnEnable()   
    if self._scene:getGameMode() == 0 then--等待      
        self.m_btnStart:setEnabled(true) 
        self.m_btnAdd:setEnabled(true)  
        self.m_btnSub:setEnabled(true)
        self.m_btnMaxAdd:setEnabled(true)  
        --self.m_btnAuto:setEnabled(true)   
    else 
        self.m_btnStart:setEnabled(false)    
        self.m_btnAdd:setEnabled(false)
        self.m_btnSub:setEnabled(false)  
        self.m_btnMaxAdd:setEnabled(false) 
        --self.m_btnAuto:setEnabled(false)   
    end


    if self._scene.m_bFreetime then
        --self.m_btnAuto:setEnabled(false)   
        self.m_btnStart:setEnabled(false)  
        self.m_btnAdd:setEnabled(false)
        self.m_btnSub:setEnabled(false)   
        self.m_btnMaxAdd:setEnabled(false)
    end
end

function GameViewLayer:onGameStart()   
    if self._scene:getGameMode() == 0 then--等待
        print("00000000000000000000",self._scene:getGameMode())
        self._scene:GameStart()            
    elseif self._scene:getGameMode() == 1 then--等待服务器响应
        print("11111111111111111111",self._scene:getGameMode())
    elseif self._scene:getGameMode() == 2 then--转动
        print("22222222222222222222",self._scene:getGameMode())       
    elseif self._scene:getGameMode() == 3 then--结算
        print("33333333333333333333",self._scene:getGameMode())        
    elseif self._scene:getGameMode() == 4 then--等待游戏2
        print("55555555555555555555",self._scene:getGameMode())
    elseif self._scene:getGameMode() == 5 then--结束 
        print("66666666666666666666",self._scene:getGameMode())        
    end
end

function GameViewLayer:onAutoGameStart()
    if self._scene.m_bIsAuto == true then
        self._scene.m_bIsAuto = false
        --self.m_btnAuto:loadTextures("btn_auto_1.png","btn_auto_1.png","btn_auto_1.png",UI_TEX_TYPE_PLIST)
        self.m_btnAuto:getChildByName("Image_gou"):setVisible(false)
    else 
        --self.m_btnAuto:loadTextures("btn_auto_2.png","btn_auto_2.png","btn_auto_2.png",UI_TEX_TYPE_PLIST)
        self.m_btnAuto:getChildByName("Image_gou"):setVisible(true)
        self._scene:onAutoStart()        
    end
end

-- 游戏1动画开始
function GameViewLayer:gameBegin()
    local function callback()
        self._scene.m_bIsItemMove = false        
        self:performWithDelay(0,self.GameGetLineResult)        
    end

    self._winScoreAni = true
    self.m_bIsStop = false;
    self:WinLightSetVisibleFalse()   

    self.m_ScrollLayer:runItem(self._scene.m_cbItemInfo,callback)

    self.m_StartEffect = nil
    
end
-- 手动停止滚动
function GameViewLayer:gameEnd()    


end
-- 游戏连线结果
function GameViewLayer:GameGetLineResult()
    --print("游戏连线结果")
   
    local ActionKaiJiang = self._scene.tagActionOneKaiJian
    local pActionYaXian = self._scene.m_UserActionYaxian
    local tagFreeKaiJian = self._scene.tagFreeKaiJian

    --dump(ActionKaiJiang,"",100)
    --dump(pActionYaXian,"",100)

    local function callback()
        if #pActionYaXian > 0 then

            ExternalFun.playSoundEffect("SingleExplosion.wav")
            local bFree = self._scene.m_bFreetime or (not self._scene.m_bDelete) or self.m_FreeTime_BG:isVisible()                  
            self.m_ScrollLayer:setAllItemWin(ActionKaiJiang.bZhongJiang,bFree)    

        else 
--            if self._scene.m_bSpecialGame then
--                if tagFreeKaiJian.bFree then
--                    self.m_ScrollLayer:setAllItemWin(tagFreeKaiJian.bZhongJiang,true) 
--                end                 
--            end                
        end       
        local temptime = 0.01
        if #pActionYaXian > 0 then
            temptime = 0.1
        end
--        if tagFreeKaiJian.bFree then
--            temptime = 0.5
--        end
        self:performWithDelay(temptime, function()
            self:onGetGameScore()
        end )      
    end

    if #pActionYaXian > 0 then         
        
        self:performWithDelay(0.2, function()
            callback()
        end ) 
    else 
        callback()
    end
    

end
-- 游戏1结果

function GameViewLayer:onGetGameScore()
    
    print("onGetGameScore")
    local ActionKaiJiang = self._scene.tagActionOneKaiJian
    local pActionYaXian = self._scene.m_UserActionYaxian

    local function callback()
        if self._scene.m_bIsItemMove == true then
            return;
        end
        if not self.m_FreeTime_BG:isVisible() and self._scene.m_bFreetime == false and #pActionYaXian > 0 and self._scene.m_bDelete == true then
            self._scene:onDeleteGameStart()
            return      
        else 
            
        end

        self:onAddFreeTime(self._scene.m_cbFreeTime)
        if self._scene.m_cbFreeTime<=0 then
            if self.m_FreeTime_BG:isVisible() then 
                self.m_FreeTime_BG:setVisible(false)
                --self._scene.m_lWinScore=self._scene.m_llFreeScore
            end     
        end

        if self._scene.m_cbFreeTime == 0 then
            self._scene.m_bFreetime = false
            self.isFreeGame = false
        else
            self._scene.m_bFreetime = true
            self.isFreeGame = true
        end

        self._scene:setGameMode(0)
        self:updataBtnEnable()
        self:updateScore()  
            
        self._scene.m_lGetCoins = 0

        if self._scene.m_bIsAuto or self._scene.m_bFreetime or self._scene.m_cbGameStatus == g_var(cmd).SHZ_GAME_SCENE_FREETIME then
            self._scene:GameStart()
        end
    end

    local _getcoin = clone(self._scene.m_lGetCoins)

    local serverKind = G_GameFrame:getServerKind()
    if _getcoin>0  then
        self.m_GetScore:stopAllActions()
        self.m_GetScore:setVisible(true)
        --self.m_GetScore:getChildByName("txt"):setString(_getcoin)
        local num = _getcoin/10
        for i=1,10 do 
            self.m_GetScore:runAction(
                cc.Sequence:create(                    
                    cc.DelayTime:create(0.05*i),
                    cc.CallFunc:create( function()
                        self.m_GetScore:getChildByName("txt"):setString( g_format:formatNumber(math.ceil(num*i),g_format.fType.standard,serverKind))
                        if i==10 then 
                            self.m_GetScore:getChildByName("txt"):setString( g_format:formatNumber(_getcoin,g_format.fType.standard,serverKind) )
                        end                       
                        end )))
        end
        --self.m_GetScore:setScale(2.0)
        --self.m_GetScore:getChildByName("ani"):runAction(cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("daoguang")))
        self.m_GetScore:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create( function()
            self.m_GetScore:setVisible(false)
        end )))
        self:performWithDelay(0.7,callback)     
        
        WinLayer.showWinAni(self,2.0)
          
        ExternalFun.playSoundEffect("SmallWin.wav")   
    else 
        if self._scene.m_Times>=300 then            
            self.m_GetScore:setVisible(false)
            self:performWithDelay(0,callback)
        else           
            self:performWithDelay(0,callback)
        end
        ExternalFun.playSoundEffect("Lose.wav")
    end 
end

function GameViewLayer:DeleteGame()

    local function callback()
        self._scene.m_bIsItemMove = false
        self:performWithDelay(0.5,function() self:GameGetLineResult() end)
    end

    self._winScoreAni = true
    self.m_bIsStop = false;
    self:WinLightSetVisibleFalse()   
    self.m_ScrollLayer:runDeleteGame(self._scene.m_cbItemInfo,callback)
end

function GameViewLayer:onGetSpecialGameScore()

end

-- 线动画
function GameViewLayer:runLeftxianAni(sprLine,width)
    sprLine:runAction( cc.Sequence:create(
        cc.DelayTime:create(0.01),
        cc.CallFunc:create(
            function()                
                sprLine:setTextureRect(cc.rect(0,0,width,ylAll.HEIGHT))
                if width>=1200 then
                    return 
                end
                self:runLeftxianAni(sprLine,width+400)
            end
        )))
end

function GameViewLayer:runRightxianAni(sprLine,width)
    sprLine:runAction( cc.Sequence:create(
        cc.DelayTime:create(0.01),
        cc.CallFunc:create(
            function()                               
                sprLine:setTextureRect(cc.rect(1200-width,0,width,ylAll.HEIGHT))
                sprLine:setPositionX(1200-width)
                if width>=1200 then                   
                    return 
                end              
                self:runRightxianAni(sprLine,width+20)
            end
        )))
end

-- 帮助页面
function GameViewLayer:onHelpLayer()
    if self._helpLayer == nil then 
        self._helpLayer = HelpLayer:create(self)
        self:addChild(self._helpLayer, 50)
    end
    self._helpLayer:onShowLayer(true)
end
--设置界面
function GameViewLayer:onSetLayer(ref)
--    if not self._setLayer then
--        self._setLayer = SettingLayer:create(self._scene)
--        self:addChild(self._setLayer, 50)
--    end
--    self._setLayer:onShowLayer(true)
    
    if ref == nil then 
        return 
    end

    local music = not GlobalUserItem.bVoiceAble
    GlobalUserItem.setVoiceAble(music)
    GlobalUserItem.setSoundAble(music)

    if GlobalUserItem.bVoiceAble then 
        AudioEngine.resumeMusic()
        ExternalFun.playBackgroudAudio("BG.wav")   
    else
        AudioEngine.pauseMusic()
    end

    if ref:getChildByName("open") then 
        ref:getChildByName("open"):setVisible(GlobalUserItem.bVoiceAble)
    end 
    if ref:getChildByName("close") then 
        ref:getChildByName("close"):setVisible(not GlobalUserItem.bVoiceAble)
    end 
end
-- 银行
function GameViewLayer:onBankLayer()

    if GlobalUserItem.roomTypeNum == 0 or GlobalUserItem.roomTypeNum == 10 then
        showToast("体验场不能进行取款操作")
        return
    end

    if 0 == GlobalUserItem.cbInsureEnabled then
        showToast("初次使用，请先开通银行！")
        return
    end

    if self._scene:getGameMode() == 1 or self._scene:getGameMode() == 2 or 
        self._scene:getGameMode() == 3 or self._scene:getGameMode() == 4 then
        showToast("游戏过程中不能进行银行操作")
        return
    end

    -- 房间规则
    local rule = self._scene._gameFrame._dwServerRule
    if rule == G_NetCmd.GAME_GENRE_SCORE or rule == G_NetCmd.GAME_GENRE_EDUCATE then
        print("练习 or 积分房")
    end
    if false == self._scene:getFrame():OnGameAllowBankTake() then
        -- showToast("不允许银行取款操作操作")
        -- return
    end




end

function GameViewLayer:onShowLine()
--    for i=1,GameLogic.YAXIANNUM do
--        if i<=self._scene.m_lYaxian then
--            self.m_WinLight[i][3]:setVisible(true)
--        else 
--            self.m_WinLight[i][3]:setVisible(false)
--        end
--    end
end

function GameViewLayer:onAddFreeTime(Time)
    
    local txt = self.m_FreeTime_BG:getChildByName("txt_free"):getChildByName("txt")
    if txt == nil then
        txt = cc.Label:createWithBMFont("plist/mellegend_fnt_2.fnt", "")
        txt:addTo(self.m_FreeTime_BG:getChildByName("txt_free"))
        txt:setName("txt")
    end  
    if Time>0 then
        --self.m_pfreewin:setString(string.formatNumberCoin(self._scene.m_llFreeScore))
        local serverKind = G_GameFrame:getServerKind()
        self.m_pfreewin:setString(g_format:formatNumber(self._scene.m_llFreeScore,g_format.fType.abbreviation,serverKind))
        if not self.m_FreeTime_BG:isVisible() then
            self.m_FreeTime_BG:setVisible(true)
            self.m_pfreewin:setString(0)
            self._scene.m_llFreeScore = 0
            --ExternalFun.playSoundEffect("ScatterWin.mp3") 
        end
    end
    txt:setString(Time)    
end

function GameViewLayer:WinLightSetVisibleFalse()
--    for i = 1, g_var(cmd).YAXIANNUM do
--        self.m_WinLight[i][3]:setVisible(false)
--    end
end

function GameViewLayer:setLevel(level)
    if level == 0 then 
        for i=1,5 do
            self.m_tabLevelList[i]:setVisible(false)
        end
        return 
    end
    if self.m_tabLevelList[level] then 
        self.m_tabLevelList[level]:setVisible(true)
    end

end
return GameViewLayer