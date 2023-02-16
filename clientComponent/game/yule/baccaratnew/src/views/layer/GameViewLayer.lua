local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
local module_pre = "game.yule.baccaratnew.src"

--external
--

local g_var = g_ExternalFun.req_var
local ClipText =appdf.CLIENT_SRC .. "Tools.ClipText"
local PopupInfoHead = appdf.CLIENT_SRC .. "Tools.PopupInfoHead"
--

local cmd = module_pre .. ".models.CMD_Game"
local game_cmd = appdf.CLIENT_SRC .. "NetProtocol.CMD_GameServer"
local QueryDialog = appdf.req("client.src.UIManager.QueryDialogNew")

--utils
--
local MUserListLayer = module_pre .. ".views.layer.userlist.MUserListLayer"
local ApplyListLayer = module_pre .. ".views.layer.userlist.ApplyListLayer"
local SettingLayer = module_pre .. ".views.layer.SettingLayer"
local WallBillLayer = module_pre .. ".views.layer.WallBillLayer"
local SitRoleNode = module_pre .. ".views.layer.SitRoleNode"
local GameCardLayer = module_pre .. ".views.layer.GameCardLayer"
local GameResultLayer = module_pre .. ".views.layer.GameResultLayer"
--
local WallBillnode = module_pre .. ".views.layer.WallBillnode"
GameViewLayer.TAG_START				= 100
local enumTable = 
{
	"BT_EXIT",
	"BT_START",
	"BT_LUDAN",
	"BT_BANK",
    "BT_BANKN",
	"BT_SET",
	"BT_ROBBANKER",
	"BT_APPLYBANKER",
	"BT_USERLIST",
	"BT_APPLYLIST",
	"BANK_LAYER",
    "HELP_LAYER",
	"BT_CLOSEBANK",
	"BT_TAKESCORE",
	"BT_HELP",
    "BT_HELPCLSOE",
	"BT_CHAT",
      "BT_XUYA",
       "BT_APPLY",     --申请上庄
     "BT_CANCEL_APPLY",     --申请下庄
    
}
local TAG_ENUM = g_ExternalFun.declarEnumWithTable(GameViewLayer.TAG_START, enumTable);
local zorders = 
{
	"CLOCK_ZORDER",
	"SITDOWN_ZORDER",
	"DROPDOWN_ZORDER",
	"DROPDOWN_CHECK_ZORDER",
	"GAMECARD_ZORDER",
	"SETTING_ZORDER",
	"ROLEINFO_ZORDER",
	"BANK_ZORDER",
    "HELP_ZORDER",
	"USERLIST_ZORDER",
	"WALLBILL_ZORDER",
	"GAMERS_ZORDER",	
	"ENDCLOCK_ZORDER"
}
local TAG_ZORDER = g_ExternalFun.declarEnumWithTable(1, zorders);

local enumApply =
{
	"kCancelState",
	"kApplyState",
	"kApplyedState",
	"kSupperApplyed"
}
GameViewLayer._apply_state = g_ExternalFun.declarEnumWithTable(0, enumApply)
local APPLY_STATE = GameViewLayer._apply_state

--默认选中的筹码
local DEFAULT_BET = 1
--筹码运行时间
local BET_ANITIME = 0.05

function GameViewLayer:ctor(scene)
	--注册node事件
	g_ExternalFun.registerNodeEvent(self)
	
	self._scene = scene
	self:gameDataInit();

	--初始化csb界面
	self:initCsbRes();
	--初始化通用动作
	self:initAction();
end

function GameViewLayer:loadRes(  )
	--加载卡牌纹理
	cc.Director:getInstance():getTextureCache():addImage("spritesheet/plist_hlssm_font.png");
    	cc.Director:getInstance():getTextureCache():addImage("game/card.png");
      

  


       
end

---------------------------------------------------------------------------------------
--界面初始化
function GameViewLayer:initCsbRes(  )
	local csbNode = g_ExternalFun.loadCSB("game/GameLayer.csb", self);
	-- self.m_rootLayer = rootLayer

	--底部按钮
	local bottom_sp = csbNode:getChildByName("bottom_sp");
	self.m_spBottom = bottom_sp;

     self.m_im_txt_bg = csbNode:getChildByName("im_txt_bg")
     self.m_im_txt_bg:setVisible(false)
	--初始化按钮
	self:initBtn(csbNode);

	--初始化庄家信息
	self:initBankerInfo();

	--初始化玩家信息
	self:initUserInfo();

	--初始化桌面下注
	self:initJetton(csbNode);

	--初始化座位列表
	self:initSitDownList(csbNode)

	--倒计时
	self:createClockNode()	
end

function GameViewLayer:reSet(  )

end

function GameViewLayer:reSetForNewGame(  )
	--重置下注区域
	self:cleanJettonArea()

	--闪烁停止
	self:jettonAreaBlinkClean()

	--self:showGameResult(false)

	if nil ~= self.m_cardLayer then
		self.m_cardLayer:showLayer(false)
	end
    
      self.m_lUserLastJettonScore = {0,0,0,0,0,0,0,0,0}
end

--初始化按钮
function GameViewLayer:initBtn( csbNode )
	local this = self
	------
	--切换checkbox
	local function checkEvent( sender,eventType )
		self:onCheckBoxClickEvent(sender, eventType);
	end
	local btnlist_check = csbNode:getChildByName("btnlist_check");
	btnlist_check:addEventListener(checkEvent);
	btnlist_check:setSelected(false);
	btnlist_check:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)

	------
       --[[self.skeletonNode = sp.SkeletonAnimation:create("animation/spine/hlssm_xiazhutip/hlssm_xiazhutip.json", "animation/spine/hlssm_xiazhutip/hlssm_xiazhutip.atlas", 1)  
         --self.skeletonNode:setAnimation(0, "walk", true)  
         local winSize = cc.Director:getInstance():getWinSize();
           self.skeletonNode:setPosition(cc.p(winSize.width/2,winSize.height/2));
        self.skeletonNode:setAnimation(0, "animation", true)
         self.skeletonNode:addTo(csbNode)
         cc.Sprite:create("ui/txt/Brnn_tips_bet_end.png")
            :addTo(self.skeletonNode)
			:move(0,0 )	
            ]]
	------
	--按钮列表
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			this:onButtonClickedEvent(sender:getTag(), sender);
		end
	end	
	local btn_list = csbNode:getChildByName("sp_btn_list");
	self.m_btnList = btn_list;
	btn_list:setScaleY(0.0000001)
	btn_list:setLocalZOrder(TAG_ZORDER.DROPDOWN_ZORDER)

	--路单
	local btn = csbNode:getChildByName("ludan_btn");
	btn:setTag(TAG_ENUM.BT_LUDAN);
	btn:addTouchEventListener(btnEvent);
    btn:setVisible(false)
	--银行
	btn = btn_list:getChildByName("bank_btn");
	btn:setTag(TAG_ENUM.BT_BANK);
	btn:addTouchEventListener(btnEvent);

	--设置
	btn = btn_list:getChildByName("set_btn");
	btn:setTag(TAG_ENUM.BT_SET);
	btn:addTouchEventListener(btnEvent);

	--离开
	btn = btn_list:getChildByName("back_btn");
	btn:setTag(TAG_ENUM.BT_EXIT );
	btn:addTouchEventListener(btnEvent);

    btn = btn_list:getChildByName("rule_btn");
	btn:setTag(TAG_ENUM.BT_HELP);
	btn:addTouchEventListener(btnEvent);

    
      local bt_addbank = self.m_spBottom:getChildByName("bt_addbank")
     bt_addbank:setTag(TAG_ENUM.BT_BANKN)
    bt_addbank:addTouchEventListener(btnEvent)
    bt_addbank:setVisible(false)
     self.m_BitmapFontAllAdd =csbNode:getChildByName("BitmapFontAllAdd")--cc.LabelBMFont:create("HelloWorld", "fonts/BMFont.fnt")               ①  
    self.m_BitmapFontAllAdd:setString("")

     self.m_Image_all = csbNode:getChildByName("Image_all")--cc.LabelBMFont:create("HelloWorld", "fonts/BMFont.fnt")               ①  
    

    

	------
	--上庄、抢庄
	local banker_bg = csbNode:getChildByName("banker_bg");
	self.m_spBankerBg = banker_bg;
	--抢庄
	btn = banker_bg:getChildByName("rob_btn");
	btn:setTag(TAG_ENUM.BT_ROBBANKER);
	btn:addTouchEventListener(btnEvent);
	self.m_btnRob = btn;
	self.m_btnRob:setEnabled(false);
    self.m_btnRob:setVisible(false)
	--上庄列表
	btn = banker_bg:getChildByName("apply_btn");
	--btn:setTag(TAG_ENUM.BT_APPLYLIST);
    	btn:setTag(TAG_ENUM.BT_APPLY);
    
	btn:addTouchEventListener(btnEvent);	
	self.m_btnApply = btn;
	------

    btn = banker_bg:getChildByName("bt_cancel_apply")
    btn:setTag(TAG_ENUM.BT_CANCEL_APPLY)
    btn:addTouchEventListener(btnEvent)
    btn:setVisible(false)
   self.m_btnCancelApply = btn

    self.Txt_SZRS = banker_bg:getChildByName("Txt_SZRS")
    self.Txt_SZRS:setString("")
  
  


	--玩家列表
	btn = self.m_spBottom:getChildByName("userlist_btn");
	btn:setTag(TAG_ENUM.BT_USERLIST);
	btn:addTouchEventListener(btnEvent);

    local Image_Luzi = self.m_spBottom:getChildByName("Image_Luzi");
	  self.m_WallBillnode=  g_var(WallBillnode):create(self)
        self.m_WallBillnode:addTo(Image_Luzi)
         local size =Image_Luzi:getContentSize() 
         self.m_WallBillnode:setPosition(cc.p(size.width/2,size.height/2))

         self.m_meTxt_name = self.m_spBottom:getChildByName("Txt_name");
           self.m_meTxt_name:setString(self:getMeUserItem().szNickName)
	-- 帮助按钮 gameviewlayer -> gamelayer -> clientscene
    --self:getParentNode():getParentNode():createHelpBtn2(cc.p(1287, 620), 0, 122, 0, csbNode)
end
function GameViewLayer:setbtApply(  )
	
	--获取当前申请状态
	local state = self:getApplyState()	
    	self.m_btnApply:setVisible(true)
        self.m_btnCancelApply:setVisible(false)
	--未申请状态则申请、申请状态则取消申请、已申请则取消申请
	if state == self._apply_state.kCancelState then
			self.m_btnApply:setVisible(true)
            self.m_btnCancelApply:setVisible(false)
	elseif state == self._apply_state.kApplyState then
		self.m_btnApply:setVisible(false)
            self.m_btnCancelApply:setVisible(true)
	elseif state == self._apply_state.kApplyedState then
			self.m_btnApply:setVisible(false)
            self.m_btnCancelApply:setVisible(true)
	end

end
--初始化庄家信息
function GameViewLayer:initBankerInfo( ... )
	local banker_bg = self.m_spBankerBg;
	--庄家姓名
	local tmp = banker_bg:getChildByName("name_text");
	self.m_clipBankerNick = g_var(ClipText):createClipText(tmp:getContentSize(), "");
	self.m_clipBankerNick:setAnchorPoint(tmp:getAnchorPoint());
	self.m_clipBankerNick:setPosition(tmp:getPosition());
	banker_bg:addChild(self.m_clipBankerNick);

	--庄家游戏币
	self.m_textBankerCoin = banker_bg:getChildByName("bankercoin_text");
       self.m_textBankerCoin:setTextColor(cc.c4b(203,210,129,255))
       --self.m_clipBankerNick:setTextColor(cc.c4b(123,122,123,255))
        self.m_clipBankerNick:setTextColor(cc.c4b(255,255,255,255))
   

	self:reSetBankerInfo();
end

--button:addTouchEventListener(handler(self, self.test))
function GameViewLayer:alphaCheck(sender,eventType)
     local size=sender:getContentSize()
     local point= sender:convertToNodeSpace(CCPoint(sender:getTouchStartPos().x,sender:getTouchStartPos().y))
     local rect=cc.RectMake(-size.width/2,-size.height/2,size.width,size.height)
     if(self:getAlpha(size,point)<1)then
            return 
      end
     if eventType == ccs.TouchEventType.began then
        
     elseif eventType == ccs.TouchEventType.ended then
                
     end
end

function GameViewLayer:getAlpha(size,point)
    local img=display.newSprite("button图片路径") 
    return img:getColorAlpha(CCPoint(point.x,point.y))
end 
function GameViewLayer:alphaCheck1(sprite, touch)
    local location = touch
    local data = 4
    local renderTexture = cc.RenderTexture:create(1, 1, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    renderTexture:begin()
    --只保存渲染一个像素的数据
    sprite:visit()
    renderTexture:endToLua()
    local vt = gl.readPixels(location.x, location.y, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, data)
    dump(vt)


end
function GameViewLayer:reSetBankerInfo(  )
	self.m_clipBankerNick:setString("");
	self.m_textBankerCoin:setString("");
end

--初始化玩家信息
function GameViewLayer:initUserInfo(  )	
	--玩家头像
	local tmp = self.m_spBottom:getChildByName("player_head")
	local head = g_var(PopupInfoHead):createClipHead(self:getMeUserItem(), 65)
	head:setPosition(cc.p(tmp:getPositionX(),tmp:getPositionY()+14))
	self.m_spBottom:addChild(head)
	head:enableInfoPop(true)

	--玩家游戏币
	self.m_textUserCoint = self.m_spBottom:getChildByName("coin_text")
    self.m_textUserCoint:setTextColor(cc.c4b(203,210,129,255))
	self:reSetUserInfo()
end

function GameViewLayer:reSetUserInfo(  )
	self.m_scoreUser = 0
	local myUser = self:getMeUserItem()
	if nil ~= myUser then
		self.m_scoreUser = myUser.lScore;
	end	
	-- print("自己游戏币:" .. g_ExternalFun.formatScore(self.m_scoreUser))
	-- local str = g_ExternalFun.numberThousands(self.m_scoreUser);
	-- if string.len(str) > 11 then
	-- 	str = string.sub(str,1,11) .. "...";
	-- end
	local str = string.formatNumberCoin(self.m_scoreUser)
	self.m_textUserCoint:setString(str);
end

--初始化桌面下注
function GameViewLayer:initJetton( csbNode )
	local bottom_sp = self.m_spBottom;
	------
	--下注按钮	
	local clip_layout = bottom_sp:getChildByName("clip_layout");
	self.m_layoutClip = clip_layout;
	self:initJettonBtnInfo();
	------

	------
	--下注区域
	self:initJettonArea(csbNode);
	------

	-----
	--下注胜利提示
	-----
	self:initJettonSp(csbNode);
end

function GameViewLayer:enableJetton( var )
	--下注按钮
	self:reSetJettonBtnInfo(var);

	--下注区域
	self:reSetJettonArea(var);
end

--下注按钮
function GameViewLayer:initJettonBtnInfo(  )
	local clip_layout = self.m_layoutClip;
	local this = self

	local function clipEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			this:onJettonButtonClicked(sender:getTag(), sender);
		end
	end

	self.m_pJettonNumber = 
	{
		{k = 1000, i = 1},
		{k = 10000, i = 2}, 
		{k = 100000, i = 3}, 
		{k = 1000000, i = 4}, 
		{k = 5000000, i = 5},
		--{k = 10000000, i = 7} 
	}

	self.m_tabJettonAnimate = {}
	for i=1,#self.m_pJettonNumber do
		local tag = i - 1
		local str = string.format("chip%d_btn", tag)
		local btn = clip_layout:getChildByName(str)
		btn:setTag(i)
		btn:addTouchEventListener(clipEvent)
		self.m_tableJettonBtn[i] = btn

		str = string.format("chip%d", tag)
		self.m_tabJettonAnimate[i] = clip_layout:getChildByName(str)
        local spriteframe = cc.SpriteFrame:create("ui/common/bjl_cricle.png",cc.rect(0,0,132,154))
        self.m_tabJettonAnimate[i]:setSpriteFrame(spriteframe)
        --self.m_tabJettonAnimate[i]:setScale(0.45)
	end

    local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			this:onButtonClickedEvent(sender:getTag(), sender)
		end
	end	
    	local btn = clip_layout:getChildByName("Button_xy__btn")
		btn:setTag(TAG_ENUM.BT_XUYA)
		btn:addTouchEventListener(btnEvent)
        self.Button_xy = btn
	self:reSetJettonBtnInfo(false);
end

function GameViewLayer:reSetJettonBtnInfo( var )
	for i=1,#self.m_tableJettonBtn do
		self.m_tableJettonBtn[i]:setTag(i)
		self.m_tableJettonBtn[i]:setEnabled(var)

		self.m_tabJettonAnimate[i]:stopAllActions()
		self.m_tabJettonAnimate[i]:setVisible(false)
	end
end

function GameViewLayer:adjustJettonBtn(  )
	--可以下注的数额
	local lCanJetton = self.m_llMaxJetton - self.m_lHaveJetton;
	local lCondition = math.min(self.m_scoreUser, lCanJetton);

	for i=1,#self.m_tableJettonBtn do
		local enable = false
		if self.m_bOnGameRes then
			enable = false
		else
			enable = self.m_bOnGameRes or (lCondition >= self.m_pJettonNumber[i].k)
		end
		self.m_tableJettonBtn[i]:setEnabled(enable);
	end

	if self.m_nJettonSelect > self.m_scoreUser then
		self.m_nJettonSelect = -1;
	end

	--筹码动画
	local enable = lCondition >= self.m_pJettonNumber[self.m_nSelectBet].k;
	if false == enable then
		self.m_tabJettonAnimate[self.m_nSelectBet]:stopAllActions()
		self.m_tabJettonAnimate[self.m_nSelectBet]:setVisible(false)
	end
end

function GameViewLayer:refreshJetton(  )
	local str = g_ExternalFun.numberThousands(self.m_lHaveJetton)
--	self.m_clipJetton:setString(str)
	--self.m_userJettonLayout:setVisible(self.m_lHaveJetton > 0)
end

function GameViewLayer:switchJettonBtnState( idx )
	for i=1,#self.m_tabJettonAnimate do
		self.m_tabJettonAnimate[i]:stopAllActions()
		self.m_tabJettonAnimate[i]:setVisible(false)
	end

	--可以下注的数额
	local lCanJetton = self.m_llMaxJetton - self.m_lHaveJetton;
	local lCondition = math.min(self.m_scoreUser, lCanJetton);
	if nil ~= idx and nil ~= self.m_tabJettonAnimate[idx] then
		local enable = lCondition >= self.m_pJettonNumber[idx].k;
		if enable then
            self.m_tabJettonAnimate[idx]:setVisible(true)
			--local blink = cc.Blink:create(1.0,1)
			--self.m_tabJettonAnimate[idx]:runAction(cc.RepeatForever:create(blink))
		end		
	end
end
--下注筹码结算动画
function GameViewLayer:betAnimation( )
	local cmd_gameend = self:getDataMgr().m_tabGameEndCmd
	if nil == cmd_gameend then
		return
	end
     --self.m_lPlayScore --AREA_MAX
	local tmp = self.m_betAreaLayout:getChildren()
     local delay3 = cc.DelayTime:create(0.5)
     local seq3 = cc.Sequence:create(delay3,cc.CallFunc:create(function()
      --  g_ExternalFun.playSoundEffect("GET_GOLDN.mp3")
     end))
   self:runAction(seq3)	
  
    for area = 1, g_var(cmd).AREA_MAX do
        if self.m_lPlayScore ~=nil and self.m_lPlayScore[area]<0  then

         
              for i = 1, #self.m_Hlssm_Battle[area] do
                  local pos = cc.p(self.m_textBankerCoin:getPositionX(), self.m_textBankerCoin:getPositionY())
				    pos = self.m_textBankerCoin:convertToWorldSpace(pos)
				    pos = self.m_betAreaLayout:convertToNodeSpace(pos)
				    self:generateBetAnimtion(self.m_Hlssm_Battle[area][i], {x = pos.x, y = pos.y}, i)

                    
              end

        end
    end
        
    
    local delay2 = cc.DelayTime:create(1)
        local seq = cc.Sequence:create(delay2,cc.CallFunc:create(function()
			            --播放下注声音
                         -- g_ExternalFun.playSoundEffect("GET_GOLDN.mp3")
                        for area = 1, g_var(cmd).AREA_MAX do
                            if self.m_lPlayScore ~=nil and self.m_lPlayScore[area]>0   then

                             local GoldNumArray  = self:getGoldNumArray(self.m_lPlayScore[area])
                             local btn = self.m_tableAddShowJettonArea[area]; 
                                 for i=1, #GoldNumArray do
                                       local nIdx =GoldNumArray[i].i--tmpGold:getTag()
                                        local llScore = GoldNumArray[i].k
	                                        local str = string.format("ui/common/Hlssm_Battle_cmD%d.png", nIdx);
	                                        local sp = nil
                                            sp = cc.Sprite:create(str);
                                            sp:setScale(0.45)
                      

                                              local pos = cc.p(self.m_textBankerCoin:getPositionX(), self.m_textBankerCoin:getPositionY())
				                                pos = self.m_textBankerCoin:convertToWorldSpace(pos)
				                                pos = self.m_betAreaLayout:convertToNodeSpace(pos)
                     
		                                        --pos = self.m_betAreaLayout:convertToNodeSpace(self:getBetFromPos(wUser))
		                                    sp:setPosition(pos)

                                            self.m_betAreaLayout:addChild(sp)
                                            table.insert(self.m_Hlssm_Battle[area],sp)
                                             local act = self:getBetAnimation(self:getBetRandomPos(btn), cc.CallFunc:create(function()
			                                --播放下注声音
			                                    -- g_ExternalFun.playSoundEffect("GET_GOLDN.mp3")
                      
                       
		                                     end),true)
		                                    sp:stopAllActions()

                                            -- local runSeq = cc.Sequence:create(act) 
                                             local runSeq = cc.Sequence:create(cc.DelayTime:create(i*0.01),act,cc.CallFunc:create(function()
                                               --播放下注声音
                                                -- g_ExternalFun.playSoundEffect("GET_GOLDN.mp3")
			                                    --g_ExternalFun.playSoundEffect("ADD_SCORE.wav")
		                                    end))

                                           sp:runAction(runSeq)

                     
                      
             
                                  end

                            end
                        end
			                --g_ExternalFun.playSoundEffect("ADD_SCORE.wav")
                            end)
                        )
		               self:runAction(seq)	

    local delay = cc.DelayTime:create(1.5)

  
    local winSize = self.m_betAreaLayout:getContentSize()
    local seq = cc.Sequence:create(delay,cc.CallFunc:create(function()
			            --播放下注声音
			                 --g_ExternalFun.playSoundEffect("GET_GOLDN.mp3")
                                 for area = 1, g_var(cmd).AREA_MAX do

                                  if self.m_lPlayScore ~=nil and self.m_lPlayScore[area]>=0  then
	                                for i = 1, #self.m_Hlssm_Battle[area] do
                                              --local pos = cc.p(self.m_textBankerCoin:getPositionX(), self.m_textBankerCoin:getPositionY())
				                              --  pos = self.m_textBankerCoin:convertToWorldSpace(pos)
				                               -- pos = self.m_betAreaLayout:convertToNodeSpace(pos)
				                                self:generateBetAnimtion(self.m_Hlssm_Battle[area][i], {x = winSize.width/2-370, y = 0+200}, i)
                                          end
                                    end
                                end  
                       
		                 end)
                        )
    self:runAction(seq)	
	--local seq = cc.Sequence:create(call, delay, call2, delay2, call3, delay3, call4, cc.DelayTime:create(2), call5)
	--self:stopAllActions()
	--self:runAction(seq)	
end
--下注筹码结算动画
function GameViewLayer:betAnimation1( )
	local cmd_gameend = self:getDataMgr().m_tabGameEndCmd
	if nil == cmd_gameend then
		return
	end
     --self.m_lPlayScore --AREA_MAX
	local tmp = self.m_betAreaLayout:getChildren()
	--数量控制
	local maxCount = 300
	local count = 0
	local children = {}
	for k,v in pairs(tmp) do
		table.insert(children, v)
		count = count + 1
		if count > maxCount then
			break
		end
	end
	local left = {}
	print("bankerscore:" .. g_ExternalFun.formatScore(cmd_gameend.lBankerScore))
	print("selfscore:" .. g_ExternalFun.formatScore(cmd_gameend.lPlayAllScore))

	--庄家的
	local call = cc.CallFunc:create(function()
		left = self:userBetAnimation(children, "banker", cmd_gameend.lBankerScore)
	end)
	local delay = cc.DelayTime:create(0.5)

	--自己的
	local meChair =  self:getMeUserItem().wChairID
	local call2 = cc.CallFunc:create(function()		
		left = self:userBetAnimation(left, meChair, cmd_gameend.lPlayAllScore)
	end)	
	local delay2 = cc.DelayTime:create(0.5)

	--坐下的
	local call3 = cc.CallFunc:create(function()
		for i = 1, g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
			if nil ~= self.m_tabSitDownUser[i] then
				--非自己
				local chair = self.m_tabSitDownUser[i]:getChair()
				local score = cmd_gameend.lOccupySeatUserWinScore[1][i]
				if meChair ~= chair then
					left = self:userBetAnimation(left, chair, cmd_gameend.lOccupySeatUserWinScore[1][i])
				end

				local useritem = self:getDataMgr():getChairUserList()[chair + 1]
				--游戏币动画
				self.m_tabSitDownUser[i]:gameEndScoreChange(useritem, score)
			end
		end
	end)
	local delay3 = cc.DelayTime:create(0.5)	

	--其余玩家的
	local call4 = cc.CallFunc:create(function()
		self:userBetAnimation(left, "other", 1)
	end)

	--剩余没有移走的
	local call5 = cc.CallFunc:create(function()
		--下注筹码数量显示移除
		self:cleanJettonArea()
	end)

	local seq = cc.Sequence:create(call, delay, call2, delay2, call3, delay3, call4, cc.DelayTime:create(2), call5)
	self:stopAllActions()
	self:runAction(seq)	
end

--玩家分数
function GameViewLayer:userBetAnimation( children, wchair, score )
	if nil == score or score <= 0 then
		return children
	end

	local left = {}
	local getScore = score
	local tmpScore = 0
	local totalIdx = #self.m_pJettonNumber
	local winSize = self.m_betAreaLayout:getContentSize()
	local remove = true
	local count = 0
	for k,v in pairs(children) do
		local idx = nil

		if remove then
			if nil ~= v and v:getTag() == wchair then
				idx = tonumber(v:getName())
				
				local pos = self.m_betAreaLayout:convertToNodeSpace(self:getBetFromPos(wchair))
				self:generateBetAnimtion(v, {x = pos.x, y = pos.y}, count)

				if nil ~= idx and nil ~= self.m_pJettonNumber[idx] then
					tmpScore = tmpScore + self.m_pJettonNumber[idx].k
				end

				if tmpScore >= score then
					remove = false
				end
			elseif G_NetCmd.INVALID_CHAIR == wchair then
				--随机抽下注筹码
				idx = self:randomGetBetIdx(getScore, totalIdx)

				local pos = self.m_betAreaLayout:convertToNodeSpace(self:getBetFromPos(wchair))

				if nil ~= idx and nil ~= self.m_pJettonNumber[idx] then
					tmpScore = tmpScore + self.m_pJettonNumber[idx].k
					getScore = getScore - tmpScore
				end

				if tmpScore >= score then
					remove = false
				end
			elseif "banker" == wchair then
				--随机抽下注筹码
				idx = self:randomGetBetIdx(getScore, totalIdx)

				local pos = cc.p(self.m_textBankerCoin:getPositionX(), self.m_textBankerCoin:getPositionY())
				pos = self.m_textBankerCoin:convertToWorldSpace(pos)
				pos = self.m_betAreaLayout:convertToNodeSpace(pos)
				self:generateBetAnimtion(v, {x = pos.x, y = pos.y}, count)

				if nil ~= idx and nil ~= self.m_pJettonNumber[idx] then
					tmpScore = tmpScore + self.m_pJettonNumber[idx].k
					getScore = getScore - tmpScore
				end

				if tmpScore >= score then
					remove = false
				end
			elseif "other" == wchair then
				self:generateBetAnimtion(v, {x = winSize.width/2-370, y = 0+200}, count)
			else
				table.insert(left, v)
			end
		else
			table.insert(left, v)
		end	
		count = count + 1	
	end
	return left
end

function GameViewLayer:generateBetAnimtion( bet, pos, count)
	--筹码动画	
     if bet == nil then return end
	local moveTo = cc.MoveTo:create(BET_ANITIME*0.7, cc.p(pos.x, pos.y))
	local call = cc.CallFunc:create(function ( )
		bet:removeFromParent()
      
	end)
    --[[local call1 = cc.CallFunc:create(function ( )
		
      
	end)]]
	bet:stopAllActions()
	bet:runAction(cc.Sequence:create(cc.DelayTime:create(0.02 * count),moveTo, call))
  --  bet:runAction(cc.Sequence:create(cc.DelayTime:create(0.05 * count),call1))
end

function GameViewLayer:randomGetBetIdx( score, totalIdx )
	if score > self.m_pJettonNumber[1].k and score < self.m_pJettonNumber[2].k then
		return math.random(1,2)
	elseif score > self.m_pJettonNumber[2].k and score < self.m_pJettonNumber[3].k then
		return math.random(1,3)
	elseif score > self.m_pJettonNumber[3].k and score < self.m_pJettonNumber[4].k then
		return math.random(1,4)
	else
		return math.random(totalIdx)
	end	
end

--下注区域
function GameViewLayer:initJettonArea( csbNode )
	local this = self
	local tag_control = csbNode:getChildByName("tag_control");
	self.m_tagControl = tag_control

	--筹码区域
	self.m_betAreaLayout = tag_control:getChildByName("bet_area")

	--按钮列表
	local function btnEvent( sender, eventType )
        local spTips = self.m_tableJettonAreaSpTips[sender:getTag()]
		if eventType == ccui.TouchEventType.ended then
			this:onJettonAreaClicked(sender:getTag(), sender);
            if spTips then
                spTips:setVisible(false)
            end
		elseif eventType == ccui.TouchEventType.began then
            if spTips then
                spTips:setVisible(true)
            end
        end
	end	

	for i=1,8 do
		local tag = i - 1;
		local str = string.format("tag%d_panel", tag);
		local tag_btn = tag_control:getChildByName(str);
		tag_btn:setTag(i);
        tag_btn:setTouchEnabled(true)
		tag_btn:addTouchEventListener(btnEvent);
		self.m_tableJettonArea[i] = tag_btn; 

		local str1 = string.format("tag%d_sp", tag);
		local tag_sp = tag_control:getChildByName(str1);
        self.m_tableJettonAreaSpTips[i] = tag_sp; 
	end
    local tag_sp_addcontrol = csbNode:getChildByName("tag_sp_addcontrol");
	self.m_tag_sp_addcontrol = tag_sp_addcontrol
    
    for i=1,8 do
		local tag = i - 1;
		local str = string.format("tagsp_%d", tag);
		local tag_btn = tag_sp_addcontrol:getChildByName(str);
		self.m_tableAddJettonArea[i] = tag_btn; 
	end




     local tag_control_add = csbNode:getChildByName("tag_control_add");
	self.m_tag_control_add = m_tag_control_add
    
    for i=1,8 do
		local tag = i - 1;
		local str = string.format("tag%d_btn", tag);
		local tag_btn = tag_control_add:getChildByName(str);
		self.m_tableAddShowJettonArea[i] = tag_btn; 
	end


     local tag_control_JettonNode = csbNode:getChildByName("tag_control_JettonNode");
	self.m_tag_control_JettonNode = tag_control_JettonNode
    
    for i=1,8 do
		local tag = i - 1;
		local str = string.format("tag%d_btn", tag);
		local tag_btn = tag_control_JettonNode:getChildByName(str);
		self.m_tableJettonAreaPoint[i] = tag_btn; 
	end



    
	--下注信息
	local m_userJettonLayout = csbNode:getChildByName("jetton_control");
	local infoSize = m_userJettonLayout:getContentSize()
	--[[local text = ccui.Text:create("本次下注为:", "fonts/round_body.ttf", 20)
	text:setAnchorPoint(cc.p(1.0,0.5))
	text:setPosition(cc.p(infoSize.width * 0.495, infoSize.height * 0.19))
	m_userJettonLayout:addChild(text)
	m_userJettonLayout:setVisible(false)

	local m_clipJetton = g_var(ClipText):createClipText(cc.size(120, 23), "")
	m_clipJetton:setPosition(cc.p(infoSize.width * 0.5, infoSize.height * 0.19))
	m_clipJetton:setAnchorPoint(cc.p(0,0.5));
	m_clipJetton:setTextColor(cc.c4b(255,165,0,255))
	m_userJettonLayout:addChild(m_clipJetton)
    self.m_clipJetton = m_clipJetton;
    ]]
    m_userJettonLayout:setVisible(false)
	self.m_userJettonLayout = m_userJettonLayout;
	
      for i = 1, g_var(cmd).AREA_MAX do
		self.m_Hlssm_Battle[i]={}
	end
	self:reSetJettonArea(false);
end

function GameViewLayer:reSetJettonArea( var )
	for i=1,#self.m_tableJettonArea do
		self.m_tableJettonArea[i]:setEnabled(var);
	end
end

function GameViewLayer:cleanJettonArea(  )
	--移除界面已下注
	self.m_betAreaLayout:removeAllChildren()

	for i=1,#self.m_tableJettonArea do
		if nil ~= self.m_tableJettonNode[i] then
			--self.m_tableJettonNode[i]:reSet()
			self:reSetJettonNode(self.m_tableJettonNode[i])
		end
	end
	self.m_userJettonLayout:setVisible(false)
	--self.m_clipJetton:setString("")
    self.m_BitmapFontAllAdd:setString("")
    self.m_AddgoldList={}
    self.m_lefttime =20
    for i = 1, g_var(cmd).AREA_MAX do
		self.m_Hlssm_Battle[i]={}
	end
     
end

--下注胜利提示
function GameViewLayer:initJettonSp( csbNode )
	self.m_tagSpControls = {};
	local sp_control = csbNode:getChildByName("tag_sp_control");
	for i=1,8 do
		local tag = i - 1;
		local str = string.format("tagsp_%d", tag);
		local tagsp = sp_control:getChildByName(str);
		self.m_tagSpControls[i] = tagsp;
	end

	self:reSetJettonSp();
end

function GameViewLayer:reSetJettonSp(  )
	for i=1,#self.m_tagSpControls do
		self.m_tagSpControls[i]:setVisible(false);
	end
end

--胜利区域闪烁
function GameViewLayer:jettonAreaBlink( tabArea )
	for i = 1, #tabArea do
		local score = tabArea[i]
		if score > 0 then
			local rep = cc.RepeatForever:create(cc.Blink:create(1.0,1))
			self.m_tagSpControls[i]:runAction(rep)
		end
	end
end

function GameViewLayer:jettonAreaBlinkClean(  )
	for i = 1, g_var(cmd).AREA_MAX do
		self.m_tagSpControls[i]:stopAllActions()
		self.m_tagSpControls[i]:setVisible(false)
	end

end

--座位列表
function GameViewLayer:initSitDownList( csbNode )
	local m_roleSitDownLayer = csbNode:getChildByName("role_control")
	self.m_roleSitDownLayer = m_roleSitDownLayer

	--按钮列表
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onSitDownClick(sender:getTag(), sender);
		end
	end

	local str = ""
	for i=1,g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
		str = string.format("sit_btn_%d", i)
		self.m_tabSitDownList[i] = m_roleSitDownLayer:getChildByName(str)
		self.m_tabSitDownList[i]:setTag(i)
		self.m_tabSitDownList[i]:addTouchEventListener(btnEvent);
        self.m_tabSitDownList[i]:setVisible(false)
	end
end

function GameViewLayer:initAction(  )
	local dropIn = cc.ScaleTo:create(0.2, 1.0);
	dropIn:retain();
	self.m_actDropIn = dropIn;

	local dropOut = cc.ScaleTo:create(0.2, 1.0, 0.0000001);
	dropOut:retain();
	self.m_actDropOut = dropOut;
end
---------------------------------------------------------------------------------------

function GameViewLayer:onButtonClickedEvent(tag,ref)
	g_ExternalFun.playClickEffect()
	if tag == TAG_ENUM.BT_EXIT then
        if self.myCurBet == true or self.isZhuangPos == true then
            showToast(g_language:getString("game_prohibit_leave"))
        else
            self:getParentNode():onExitTable()
        end
    elseif TAG_ENUM.BT_XUYA == tag then
            for i = 1, g_var(cmd).AREA_MAX do
                JettonScore =self.m_lUserLastJettonScore[i+1]
                if JettonScore>0 then
                    self:getParentNode():sendUserBet( i-1,JettonScore)
                 end

             end

         self.Button_xy:setEnabled(false)
           --[[ for i=1,Game_CMD.AREA_COUNT do
                JettonScore =self.m_lUserLastJettonScore[i+1]
                if JettonScore>0 then
                    self:getParentNode():SendPlaceJetton(JettonScore, i)
                 end

             end

         self.Button_xy:setEnabled(false)]]

   
	elseif tag == TAG_ENUM.BT_START then
		self:getParentNode():onStartGame()
	elseif tag == TAG_ENUM.BT_USERLIST then
		if nil == self.m_userListLayer then
			self.m_userListLayer = g_var(MUserListLayer):create()
			self:addToRootLayer(self.m_userListLayer, TAG_ZORDER.USERLIST_ZORDER)
		end
		local userList = self:getDataMgr():getUserList()		
		self.m_userListLayer:refreshList(userList)

         elseif tag == TAG_ENUM.BT_CANCEL_APPLY then
            self:applyBanker(APPLY_STATE.kApplyedState)
    elseif tag == TAG_ENUM.BT_APPLY then
       local txtApply = tonumber(self:getApplyCondition())
       if tonumber(self.m_scoreUser) < txtApply then
           local text = "Moedas de ouro necessárias para ir para o banqueiro:「".. (txtApply or 0) .."」"
           showToast(text)
           return
       end
       self:applyBanker(APPLY_STATE.kCancelState)

	elseif tag == TAG_ENUM.BT_APPLYLIST then
		if nil == self.m_applyListLayer then
			self.m_applyListLayer = g_var(ApplyListLayer):create(self)
			self:addToRootLayer(self.m_applyListLayer, TAG_ZORDER.USERLIST_ZORDER)
		end
		local userList = self:getDataMgr():getApplyBankerUserList()		
		self.m_applyListLayer:refreshList(userList)
	elseif tag == TAG_ENUM.BT_BANK then
		--银行未开通
		if 0 == GlobalUserItem.cbInsureEnabled then
			showToast("Usado pela primeira vez, desbloqueie primeiro o banqueiro!")
			return
		end

		--[[if nil == self.m_cbGameStatus or g_var(cmd).GAME_PLAY == self.m_cbGameStatus  then
			showToast(游戏过程中不能进行银行操作")
			return
		end]]

		--房间规则
		local rule = self:getParentNode()._roomRule
		if rule == G_NetCmd.GAME_GENRE_SCORE 
		or rule == G_NetCmd.GAME_GENRE_EDUCATE then 
			print("练习 or 积分房")
		end
		-- 当前游戏币场
		local rom = GlobalUserItem.GetRoomInfo()
		if nil ~= rom then
			if rom.wServerType ~= G_NetCmd.GAME_GENRE_GOLD then
				showToast("A sala atual proíbe a operação do banco!")
				return
			end
		end

		if false == self:getParentNode():getFrame():OnGameAllowBankTake() then
			--showToast("不允许银行取款操作操作")
			--return
		end

		if nil == self.m_bankLayer then
			self:createBankLayer()
		end
		self.m_bankLayer:setVisible(true)
		self:refreshScore()
           elseif TAG_ENUM.BT_BANKN == tag then
        if self.m_bGenreEducate == true then
            showToast("Modo de treino, não é permitido banqueiro")
            return
        end
        if 0 == GlobalUserItem.cbInsureEnabled then
            showToast("Usado pela primeira vez, desbloqueie primeiro o banqueiro!")
			return
        end
        --空闲状态才能存款
        if nil == self.m_bankLayer then
            self:createBankLayer()
        end
        self.m_bankLayer:setVisible(true)
        self:refreshScore()
         elseif TAG_ENUM.BT_HELP == tag then
        	print("玩法")
		--self:showHelp()
    	if nil == self.m_helpLayer then
			self:createHelpLayer()
		end
		self.m_helpLayer:setVisible(true)
    
	elseif tag == TAG_ENUM.BT_SET then
		local setting = g_var(SettingLayer):create(self)
		self:addToRootLayer(setting, TAG_ZORDER.SETTING_ZORDER)
	elseif tag == TAG_ENUM.BT_LUDAN then
		if nil == self.m_wallBill then
			self.m_wallBill = g_var(WallBillLayer):create(self)
			self:addToRootLayer(self.m_wallBill, TAG_ZORDER.WALLBILL_ZORDER)
		end
		self.m_wallBill:refreshWallBillList()

	elseif tag == TAG_ENUM.BT_ROBBANKER then
		--超级抢庄
		--[[if g_var(cmd).SUPERBANKER_CONSUMETYPE == self.m_tabSupperRobConfig.superbankerType then
			local str = "超级抢庄将花费 " .. self.m_tabSupperRobConfig.lSuperBankerConsume .. ",确定抢庄?"
			local query = QueryDialog:create(str, function(ok)
		        if ok == true then
		            self:getParentNode():sendRobBanker()
		        end
		    end):setCanTouchOutside(false)
		        :addTo(self) 
		else
			self:getParentNode():sendRobBanker()
		end]]
           local userItem = self:getMeUserItem()
              local condition = self.m_tabSupperRobConfig.lSuperBankerConsume + self.m_llCondition
              local userItem = self:getMeUserItem()
             if userItem.lScore < condition then
                    local str = string.format("\"Condição\"Pilagem (não possui feijões suficientes para pilagem, a condição para pilagem é%s)！",Condition);
                -- local str = "超级抢庄必须大于等于 " .. condition.. ""
                 showToast(str)
               --[[ local query = QueryDialog:create(str, function(ok)
                    if ok == true then
                        --self:getParentNode():sendRobBanker()
                    end
                end):setCanTouchOutside(false)
                :addTo(self) ]]
             else
                self:getParentNode():sendRobBanker()
             end
        
      elseif tag == TAG_ENUM.BT_HELPCLSOE then
		if nil ~= self.m_helpLayer then
			self.m_helpLayer:setVisible(false)
		end
	elseif tag == TAG_ENUM.BT_CLOSEBANK then
		if nil ~= self.m_bankLayer then
			self.m_bankLayer:setVisible(false)
		end
	elseif tag == TAG_ENUM.BT_TAKESCORE then
		self:onTakeScore()
	elseif tag == TAG_ENUM.BT_CHAT then
		
	else
		showToast("Funcionalidade não disponível!")
	end
end

function GameViewLayer:onJettonButtonClicked( tag, ref )
	if tag >= 1 and tag <= 6 then
		self.m_nJettonSelect = self.m_pJettonNumber[tag].k;
	else
		self.m_nJettonSelect = -1;
	end

	self.m_nSelectBet = tag
	self:switchJettonBtnState(tag)
	print("click jetton:" .. self.m_nJettonSelect);
end

function GameViewLayer:onJettonAreaClicked( tag, ref )
	local m_nJettonSelect = self.m_nJettonSelect;
    print("onJettonAreaClicked-------------------------------")
	if m_nJettonSelect < 0 then
     print("onJettonAreaClicked-------------------------------onJettonAreaClicked")
		return;
	end

	local area = tag - 1;	
	if self.m_lHaveJetton > self.m_llMaxJetton then
		showToast("O limite máximo de apostas foi excedido")
		self.m_lHaveJetton = self.m_lHaveJetton - m_nJettonSelect;
		return;
	end
     self.Button_xy:setEnabled(false)
	--下注
	self:getParentNode():sendUserBet(area, m_nJettonSelect);	
end
function GameViewLayer:onGameEnd(cmd_table)
    --self.m_cbGameStatus = Game_CMD.GAME_SCENE_END
   -- self.m_cbTableCardArray = cmd_table.cbTableCardArray
    self.m_lSelfWinScore = cmd_table.lPlayAllScore
    self.m_lBankerWinScore = cmd_table.lBankerScore
    self.m_lOccupySeatUserWinScore = cmd_table.lOccupySeatUserWinScore
    self.m_lUserWinMaxScore = cmd_table.lUserWinMaxScore
    self.m_wUserChairID = cmd_table.wUserChairID
    self.m_MaxUserCount= cmd_table.nMaxUserCount
    self.m_lPlayScore = clone(cmd_table.lPlaySAreaScore[1])--AREA_MAX
   --  self.m_lWinScore = cmd_table.lWinScore
    local bankername = "Sistema"
    --self.m_tBankerName = "系统"
    if  self.m_wBankerUser ~= G_NetCmd.INVALID_CHAIR then
        local useritem = self:getDataMgr():getChairUserList()[self.m_wBankerUser + 1]
        if nil ~= useritem then
            bankername = useritem.szNickName
        end
    end
    self.m_tBankerName = bankername
   --  self.m_Txt_LZCS:setString(cmd_table.nBankerTime)
  
     self.Button_xy:setEnabled(false)
    
end
function GameViewLayer:showGameResult( bShow )
	if true == bShow then
        if self.myCurBet == false and self.isZhuangPos == false then  --没下注不展示
            return
        end
        self.myCurBet = false
		if nil == self.m_gameResultLayer then
			self.m_gameResultLayer = g_var(GameResultLayer):create(self)
			self:addToRootLayer(self.m_gameResultLayer, TAG_ZORDER.GAMERS_ZORDER)
		end
        --[[ local AllWin = true
            for i=1,4 do
                if self.m_bUserOxCard[i+1]==1 then
                    AllWin = false
                    break
                end
            end]]
    
		if true == bShow and (true == self:getDataMgr().m_bJoin or true) then
            if self.m_tBankerName ~= nil then
               self.m_gameResultLayer:showGameResult(self.m_lSelfWinScore, self.m_lBankerWinScore, self.m_tBankerName, isBanker,self.m_lUserWinMaxScore[1],self.m_wUserChairID[1],self.m_MaxUserCount,AllWin,self:getDataMgr().m_tabGameResult)
			   --self.m_gameResultLayer:showGameResult(self:getDataMgr().m_tabGameResult)
            end
		end
	else
		if nil ~= self.m_gameResultLayer then
			self.m_gameResultLayer:hideGameResult()
		end
	end
end

function GameViewLayer:onCheckBoxClickEvent( sender,eventType )
    if self.myCurBet == true or self.isZhuangPos == true then
        showToast(g_language:getString("game_prohibit_leave"))
    else
        self:getParentNode():onExitTable()
    end
	--[[if eventType == ccui.CheckBoxEventType.selected then
		self.m_btnList:stopAllActions();
		self.m_btnList:runAction(self.m_actDropIn);
	elseif eventType == ccui.CheckBoxEventType.unselected then
		self.m_btnList:stopAllActions();
		self.m_btnList:runAction(self.m_actDropOut);
	end]]
end

function GameViewLayer:onSitDownClick( tag, sender )
	print("sit ==> " .. tag)
	local useritem = self:getMeUserItem()
	if nil == useritem then
		return
	end

	--重复判断
	if nil ~= self.m_nSelfSitIdx and tag == self.m_nSelfSitIdx then
		return
	end

	if nil ~= self.m_nSelfSitIdx then --and tag ~= self.m_nSelfSitIdx  then
		showToast("Atualmente ocupado " .. self.m_nSelfSitIdx .. " Não pode repetir a sua posição ocupada!")
		return
	end	

	--坐下条件限制
	if useritem.lScore < self.m_tabSitDownConfig.lForceStandUpCondition then
		local str = "Necessário carregar para sentar " .. self.m_tabSitDownConfig.lForceStandUpCondition .. " Sem moedas suficientes!"
		showToast(str)
		return
	end
	if self.m_tabSitDownConfig.occupyseatType == g_var(cmd).OCCUPYSEAT_CONSUMETYPE then --游戏币占座
		if useritem.lScore < self.m_tabSitDownConfig.lOccupySeatConsume then
			local str = "Necessário consumir para sentar " .. self.m_tabSitDownConfig.lOccupySeatConsume .. " Sem moedas suficientes!"
			showToast(str)
			return
		end
		local str = "Sentar vai custar " .. self.m_tabSitDownConfig.lOccupySeatConsume .. ",Tem certeza de que deseja se sentar?"
			local query = QueryDialog:create(str, function(ok)
		        if ok == true then
		            self:getParentNode():sendSitDown(tag - 1, useritem.wChairID)
		        end
		    end):setCanTouchOutside(false)
		        :addTo(self)
	elseif self.m_tabSitDownConfig.occupyseatType == g_var(cmd).OCCUPYSEAT_VIPTYPE then --会员占座
		if useritem.cbMemberOrder < self.m_tabSitDownConfig.enVipIndex then
			local str = "Sentar requer um nível de membro de " .. self.m_tabSitDownConfig.enVipIndex .. " Nível de membro insuficiente!"
			showToast(str)
			return
		end
		self:getParentNode():sendSitDown(tag - 1, self:getMeUserItem().wChairID)
	elseif self.m_tabSitDownConfig.occupyseatType == g_var(cmd).OCCUPYSEAT_FREETYPE then --免费占座
		if useritem.lScore < self.m_tabSitDownConfig.lOccupySeatFree then
			local str = "Para sentar de graça, você precisa trazer a moeda do jogo superiores a " .. self.m_tabSitDownConfig.lOccupySeatFree .. " ,Sem moedas suficientes para se sentar!"
			showToast(str)
			return
		end
		self:getParentNode():sendSitDown(tag - 1, self:getMeUserItem().wChairID)
	end
end

function GameViewLayer:onResetView()
	self:stopAllActions()
	self:gameDataReset()
end

function GameViewLayer:onExit()
	self:onResetView()
end

--上庄状态
function GameViewLayer:applyBanker( state )
	if state == APPLY_STATE.kCancelState then
		self:getParentNode():sendApplyBanker()		
	elseif state == APPLY_STATE.kApplyState then
		self:getParentNode():sendCancelApply()
	elseif state == APPLY_STATE.kApplyedState then
		self:getParentNode():sendCancelApply()		
	end
end

---------------------------------------------------------------------------------------
--网络消息

------
--网络接收
function GameViewLayer:onGetUserScore( item )
	--自己
	if item.dwUserID == GlobalUserItem.dwUserID then
       self:reSetUserInfo()
    end

    --坐下用户
    for i = 1, g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
    	if nil ~= self.m_tabSitDownUser[i] then
    		if item.wChairID == self.m_tabSitDownUser[i]:getChair() then
    			self.m_tabSitDownUser[i]:updateScore(item)
    		end
    	end
    end

    --庄家
    if self.m_wBankerUser == item.wChairID then
    	--庄家游戏币
        local str = g_ExternalFun.formatScoreKMBT(item.lScore)
		--[[local str = string.formatNumberThousands(item.lScore);
		if string.len(str) > 11 then
			str = string.sub(str, 1, 9) .. "...";
		end]]
		--self.m_textBankerCoin:setString("游戏币:" .. str);
        	self.m_textBankerCoin:setString( str);
    end
end

function GameViewLayer:refreshCondition(  )
	local applyable = self:getApplyable()
	if applyable then
		------
		--超级抢庄

		--如果当前有超级抢庄用户且庄家不是自己
		if (G_NetCmd.INVALID_CHAIR ~= self.m_wCurrentRobApply) or (true == self:isMeChair(self.m_wBankerUser)) then
			g_ExternalFun.enableBtn(self.m_btnRob, false)
		else
			local useritem = self:getMeUserItem()
			--判断抢庄类型
			if g_var(cmd).SUPERBANKER_VIPTYPE == self.m_tabSupperRobConfig.superbankerType then
				--vip类型				
				g_ExternalFun.enableBtn(self.m_btnRob, useritem.cbMemberOrder >= self.m_tabSupperRobConfig.enVipIndex)
			elseif g_var(cmd).SUPERBANKER_CONSUMETYPE == self.m_tabSupperRobConfig.superbankerType then
				--游戏币消耗类型(抢庄条件+抢庄消耗)
				local condition = self.m_tabSupperRobConfig.lSuperBankerConsume + self.m_llCondition
				--g_ExternalFun.enableBtn(self.m_btnRob, useritem.lScore >= condition)
                g_ExternalFun.enableBtn(self.m_btnRob, true)
			end
		end		
	else
		g_ExternalFun.enableBtn(self.m_btnRob, false)
	end
end

--游戏free
function GameViewLayer:onGameFree( )
	self:reSetForNewGame()
	--上庄条件刷新
	self:refreshCondition()

	--申请按钮状态更新
	self:refreshApplyBtnState()
end

--游戏开始
function GameViewLayer:onGameStart( )
    self.myCurBet = false
    self.m_nJettonSelect = self.m_pJettonNumber[self.m_nSelectBet].k;

	self.m_lHaveJetton = 0;

	--获取玩家携带游戏币	
	self:reSetUserInfo();

	self.m_bOnGameRes = false

	--不是自己庄家,且有庄家
	if false == self:isMeChair(self.m_wBankerUser) and false == self.m_bNoBanker then
		--下注
		self:enableJetton(true);
		--调整下注按钮
		self:adjustJettonBtn();

		--默认选中的筹码
		self:switchJettonBtnState(self.m_nSelectBet)
	end	

	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
       self.Button_xy:setEnabled(true)
	--申请按钮状态更新
	self:refreshApplyBtnState()	

         local content =   self.m_im_txt_bg:getChildByName("Image_tip")
              content:loadTexture("ui/txt/Brnn_tips_ld.png")
       -- local content = self.m_timeLayout:getChildByName("im_txt")
            local xiazhu_tip =   self.m_im_txt_bg:getChildByName("im_txt")
              xiazhu_tip:loadTexture("ui/txt/Brnn_tips_bet.png")
         
                   self.m_im_txt_bg:setVisible(true)
                    self.m_im_txt_bg:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(
                        function()
                           self.m_im_txt_bg:setVisible(false)
                         end
                         
                         )))

           g_ExternalFun.playSoundEffect("START_W.mp3")
end

--游戏进行
function GameViewLayer:reEnterStart( lUserJetton )
	self.m_nJettonSelect = self.m_pJettonNumber[DEFAULT_BET].k;
	self.m_lHaveJetton = lUserJetton;

	--获取玩家携带游戏币
	self.m_scoreUser = 0
	self:reSetUserInfo();
    
      self.m_lUserLastJettonScore = {0,0,0,0,0,0,0,0,0}

	self.m_bOnGameRes = false
      self.Button_xy:setEnabled(false)
	--不是自己庄家
	if false == self:isMeChair(self.m_wBankerUser) then
		--下注
		self:enableJetton(true);
		--调整下注按钮
		self:adjustJettonBtn();

		--默认选中的筹码
		self:switchJettonBtnState(DEFAULT_BET)
	end		
end

--下注条件
function GameViewLayer:onGetApplyBankerCondition( llCon , rob_config)
	self.m_llCondition = llCon
	--超级抢庄配置
	self.m_tabSupperRobConfig = rob_config

	self:refreshCondition();
end

--刷新庄家信息
function GameViewLayer:onChangeBanker( wBankerUser, lBankerScore, bEnableSysBanker )
	print("更新庄家数据:" .. wBankerUser .. "; coin =>" .. lBankerScore)
    self.isZhuangPos = (self:getParentNode():GetMeChairID() == wBankerUser) and true or false
	--上一个庄家是自己，且当前庄家不是自己，标记自己的状态
	if self.m_wBankerUser ~= wBankerUser and self:isMeChair(self.m_wBankerUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
	end

    if self.m_wBankerUser  ~= wBankerUser then

         local content =   self.m_im_txt_bg:getChildByName("Image_tip")
              content:loadTexture("ui/txt/Brnn_tips_zj.png")
       -- local content = self.m_timeLayout:getChildByName("im_txt")
            local xiazhu_tip =   self.m_im_txt_bg:getChildByName("im_txt")
              xiazhu_tip:loadTexture("ui/txt/Brnn_tips_cBanker.png")
             
                   self.m_im_txt_bg:setVisible(true)
                    self.m_im_txt_bg:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(
                        function()
                            g_ExternalFun.playSoundEffect("huanzhuang.mp3")
                           self.m_im_txt_bg:setVisible(false)
                         end
                         
                         )))

    end

	--获取庄家数据
	self.m_bNoBanker = false

	local nickstr = "";

         	self.m_wBankerUser = wBankerUser
	--庄家姓名
	if true == bEnableSysBanker then --允许系统坐庄
		if G_NetCmd.INVALID_CHAIR == wBankerUser then
			nickstr = "Sistema de base"
            local tmp = self.m_spBankerBg:getChildByName("Image_1")
            tmp:removeAllChildren()
		else
			local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1];
			if nil ~= userItem then
				nickstr = userItem.szNickName 

				if self:isMeChair(wBankerUser) then
					self.m_enApplyState = APPLY_STATE.kApplyedState
				end

                local tmp = self.m_spBankerBg:getChildByName("Image_1")
	            local head = g_var(PopupInfoHead):createClipHead(userItem, 65)
	            head:setPosition(cc.p(tmp:getPositionX()-6,tmp:getPositionY()+31))
	            tmp:removeAllChildren()
                tmp:addChild(head)

	            head:enableInfoPop(false)
			else
				print("获取用户数据失败")
			end
		end	
	else
		if G_NetCmd.INVALID_CHAIR == wBankerUser then
			nickstr = "Sem base"
			self.m_bNoBanker = true
		else
			local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1];
			if nil ~= userItem then
				nickstr = userItem.szNickName 

				if self:isMeChair(wBankerUser) then
					self.m_enApplyState = APPLY_STATE.kApplyedState
				end

                 local tmp = self.m_spBankerBg:getChildByName("Image_1")
	            local head = g_var(PopupInfoHead):createClipHead(userItem, 65)
	            head:setPosition(cc.p(tmp:getPositionX()-6,tmp:getPositionY()+31))
	            tmp:removeAllChildren()
                tmp:addChild(head)

	            head:enableInfoPop(false)

			else
				print("获取用户数据失败")
			end
		end
	end
	self.m_clipBankerNick:setString(nickstr);

	--庄家游戏币
	--[[local str = string.formatNumberThousands(lBankerScore);
	if string.len(str) > 11 then
		str = string.sub(str, 1, 7) .. "...";
	end]]
      local str = g_ExternalFun.formatScoreKMBT(lBankerScore)
	--self.m_textBankerCoin:setString("游戏币:" .. str);
    self.m_textBankerCoin:setString( str);
	--如果是超级抢庄用户上庄
	if wBankerUser == self.m_wCurrentRobApply then
		self.m_wCurrentRobApply = G_NetCmd.INVALID_CHAIR
		self:refreshCondition()
	end

	--坐下用户庄家
	local chair = -1
	for i = 1, g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
		if nil ~= self.m_tabSitDownUser[i] then
			chair = self.m_tabSitDownUser[i]:getChair()
			self.m_tabSitDownUser[i]:updateBanker(chair == wBankerUser)
		end
	end
end

--超级抢庄申请
function GameViewLayer:onGetSupperRobApply(  )
	if G_NetCmd.INVALID_CHAIR ~= self.m_wCurrentRobApply then
		self.m_bSupperRobApplyed = true
		g_ExternalFun.enableBtn(self.m_btnRob, false)
	end
	--如果是自己
	if true == self:isMeChair(self.m_wCurrentRobApply) then
		--普通上庄申请不可用
		self.m_enApplyState = APPLY_STATE.kSupperApplyed
	end
end

--超级抢庄用户离开
function GameViewLayer:onGetSupperRobLeave( wLeave )
	if G_NetCmd.INVALID_CHAIR == self.m_wCurrentRobApply then
		--普通上庄申请不可用
		self.m_bSupperRobApplyed = false

		g_ExternalFun.enableBtn(self.m_btnRob, true)
	end

	--如果是自己
end
--获取赢钱需要游戏币数
function GameViewLayer:getGoldNumArray(lscore,area,wUser)
    if lscore == 0 then
        return {}
    end
    local goldnum = 0
    local goldList={}

  local len = #self.m_pJettonNumber
    while lscore>0 do
        local find = false
         for i=1,len do
            if lscore >= self.m_pJettonNumber[len-i+1].k then
                lscore=lscore-self.m_pJettonNumber[len-i+1].k
                local tmp = clone(self.m_pJettonNumber[len-i+1])
                table.insert(goldList, tmp)
                find = true
                break
            end
        end
        if not find then

            return goldList
        end
    end
    return goldList
 
end

--获取下注显示游戏币个数
function GameViewLayer:getGoldNum(lscore)
    local goldnum = 1
    for i=1,6 do
        if lscore >= GameViewLayer.m_BTJettonScore[i] then
            goldnum = i
        end
    end
    return GameViewLayer.m_JettonGoldBaseNum[goldnum]
end

--更新用户下注
function GameViewLayer:onRunAnimBet( wUser,area,GoldNumArray)
   if GoldNumArray==nil then
        return 
   end
   local nIdx =GoldNumArray.i--tmpGold:getTag()
   local llScore = GoldNumArray.k
   local str = string.format("ui/common/Hlssm_Battle_cmD%d.png", nIdx);
   local sp = nil
   sp = cc.Sprite:create(str);
   sp:setScale(0.45)
   local btn = self.m_tableAddShowJettonArea[area]; 
   local btn1 = self.m_tableJettonAreaPoint[area]
   if nil == sp then
       print("sp nil");
   end
   if nil == btn then
       print("btn nil");
   end
	if nil ~= sp and nil ~= btn then
	    --下注
	    sp:setTag(wUser);
	    local name = string.format("%d", area) --g_ExternalFun.formatScore(data.lBetScore);
	    sp:setName(name)
	    --筹码飞行起点位置
	    local pos = self.m_betAreaLayout:convertToNodeSpace(self:getBetFromPos(wUser))
	    sp:setPosition(pos)
	    --筹码飞行动画
	   local act = self:getBetAnimation(self:getBetRandomPos(btn), cc.CallFunc:create(function()
	        --播放下注声音
	          g_ExternalFun.playSoundEffect("GET_GOLDN.mp3")
	    end))
	    sp:stopAllActions()
        local runSeq = cc.Sequence:create(act) 
	    sp:runAction(runSeq)
	    self.m_betAreaLayout:addChild(sp)
        table.insert(self.m_Hlssm_Battle[area],sp)
	    --下注信息显示
	    if nil == self.m_tableJettonNode[area] then
	        local jettonNode = self:createJettonNode()
	        jettonNode:setPosition(btn1:getPosition());
	        self.m_tagControl:addChild(jettonNode);
	        jettonNode:setTag(-1);
	        self.m_tableJettonNode[area] = jettonNode;
	    end
	    self:refreshJettonNode(self.m_tableJettonNode[area], llScore, llScore, self:isMeChair(wUser))
	end
	if self:isMeChair(wUser) then
	    self.m_scoreUser = self.m_scoreUser - self.m_nJettonSelect;
	    self.m_lHaveJetton = self.m_lHaveJetton + llScore;
	    --调整下注按钮
	    self:adjustJettonBtn();
	    --显示下注信息
	    self:refreshJetton();
	end
end

--更新用户下注
function GameViewLayer:onUserBeteq( )
     if #self.m_AddgoldList>0 then

            local runSeq = cc.Sequence:create(cc.DelayTime:create(#self.m_AddgoldList*0.1),cc.CallFunc:create(function()
                       --播放下注声音
                         if #self.m_AddgoldList>0 then
			                self:onRunAnimBet(self.m_AddgoldList[1].wUser ,self.m_AddgoldList[1].area,self.m_AddgoldList[1])
                             table.remove(self.m_AddgoldList,1)
                         end
                           if #self.m_AddgoldList>0 then

                            self:onUserBeteq()
                           end
		            end))
		         
             self.m_betAreaLayout:runAction(runSeq)
         
         end
end
--更新用户下注
function GameViewLayer:onGetUserBet(cmd_placebet )
	local data = cmd_placebet;
	if nil == data then
		return
	end
	local area = data.cbBetArea + 1;
	local wUser = data.wChairID;
	if wUser == self:getParentNode():GetMeChairID() then  --自已有下注
        self.myCurBet = true
    end
    local GoldNumArray  = self:getGoldNumArray(data.lBetScore)
    if self.m_AddgoldList== nil then
        self.m_AddgoldList={}
    end
    if #self.m_AddgoldList==0 then
    end
    if GoldNumArray==nil and #GoldNumArray<1 then
        return 
    end
    if  self:isMeChair(wUser)  then
         if #GoldNumArray>=1 then
            for i=1, #GoldNumArray  do
                self:onRunAnimBet(wUser ,area,GoldNumArray[i])
             end
             return
        end
    end
    if #GoldNumArray>1 or self:isMeChair(wUser)  then
        for i=1, #GoldNumArray  do
            self:onRunAnimBet(wUser ,area,GoldNumArray[i])
         end
         return
    end
     if self.m_lefttime~=nil and  self.m_lefttime<2 then
         for i=1, #GoldNumArray  do
            self:onRunAnimBet(wUser ,area,GoldNumArray[i])
         end
         return
     end
    for i=1, #GoldNumArray  do
        local tmp =   GoldNumArray[i]
        tmp.area =area
        tmp.wUser = wUser
        table.insert(self.m_AddgoldList, tmp)
    end
    if #self.m_AddgoldList>15 then
         for w=1, #self.m_AddgoldList  do
         local tmp =self.m_AddgoldList[w]
            self:onRunAnimBet(tmp.wUser ,tmp.area,tmp)
         end
        self.m_AddgoldList={}
     end
    if #self.m_AddgoldList>0 then
       self:onUserBeteq()
    end
end

--更新用户下注失败
function GameViewLayer:onGetUserBetFail(  )
	local data = self:getParentNode().cmd_jettonfail;
	if nil == data then
		return;
	end

	--下注玩家
	local wUser = data.wPlaceUser;
	--下注区域
	local cbArea = data.cbBetArea + 1;
	--下注数额
	local llScore = data.lPlaceScore;

	if self:isMeChair(wUser) then
		--提示下注失败
		local str = string.format("Aposta %s Falha", g_ExternalFun.formatScore(llScore))
		showToast(str)

		--自己下注失败
		self.m_scoreUser = self.m_scoreUser + llScore;
		self.m_lHaveJetton = self.m_lHaveJetton - llScore;
		self:adjustJettonBtn();
		self:refreshJetton()

		--
		if 0 ~= self.m_lHaveJetton then
			if nil ~= self.m_tableJettonNode[cbArea] then
				--self.m_tableJettonNode[cbArea]:refreshJetton(-llScore, -llScore, true)
				self:refreshJettonNode(self.m_tableJettonNode[cbArea],-llScore, -llScore, true)
			end

			--移除界面下注元素
			local name = string.format("%d", cbArea) --g_ExternalFun.formatScore(llScore);
			self.m_betAreaLayout:removeChildByName(name)
		end
	end
end

--断线重连更新界面已下注
function GameViewLayer:reEnterGameBet( cbArea, llScore )
	--local btn = self.m_tableJettonArea[cbArea];
   	local btn = self.m_tableAddShowJettonArea[cbArea]
    	local btn1 = self.m_tableJettonAreaPoint[cbArea]
    
	if nil == btn or 0 == llSocre then
		return;
	end

	local vec = self:getDataMgr().calcuteJetton(llScore, false);
	for k,v in pairs(vec) do
		local info = v;
		for i=1,info.m_cbCount do
			--local str = string.format("room_chip_%d_0.png", info.m_cbIdx);
			--local sp = cc.Sprite:createWithSpriteFrameName(str);

            local str = string.format("ui/common/Hlssm_Battle_cmD%d.png", info.m_cbIdx);
        	local sp = nil
            sp = cc.Sprite:create(str);
			if nil ~= sp then
				sp:setScale(0.45)
				sp:setTag(G_NetCmd.INVALID_CHAIR);
				local name = string.format("%d", cbArea) --g_ExternalFun.formatScore(info.m_llScore);
				sp:setName(name);

				self:randomSetJettonPos(btn, sp);
				self.m_betAreaLayout:addChild(sp);
                  table.insert(self.m_Hlssm_Battle[cbArea],sp)
			end
		end
	end

	--下注信息显示
	if nil == self.m_tableJettonNode[cbArea] then
		local jettonNode = self:createJettonNode()
		jettonNode:setPosition(btn1:getPosition());
		self.m_tagControl:addChild(jettonNode);
		jettonNode:setTag(-1);
		self.m_tableJettonNode[cbArea] = jettonNode;
	end
	self:refreshJettonNode(self.m_tableJettonNode[cbArea], llScore, llScore, false)
end

--断线重连更新玩家已下注
function GameViewLayer:reEnterUserBet( cbArea, llScore )
	local btn = self.m_tableJettonArea[cbArea];
    	local btn1 = self.m_tableJettonAreaPoint[cbArea]
	if nil == btn or 0 == llSocre then
		return;
	end
    if llScore ~= 0 then  --自已有下注
        self.myCurBet = true
    end
	--下注信息显示
	if nil == self.m_tableJettonNode[cbArea] then
		local jettonNode = self:createJettonNode()
		jettonNode:setPosition(btn1:getPosition());
		self.m_tagControl:addChild(jettonNode);
		jettonNode:setTag(-1);
		self.m_tableJettonNode[cbArea] = jettonNode;
	end
	self:refreshJettonNode(self.m_tableJettonNode[cbArea], llScore, 0, true)
end

--游戏结束
function GameViewLayer:onGetGameEnd(  )
	self.m_bOnGameRes = true
	--不可下注
	self:enableJetton(false)
     g_ExternalFun.playSoundEffect("STOP_W.mp3")
	--界面资源清理
	self:show()
end

--申请庄家
function GameViewLayer:onGetApplyBanker( )
	if self:isMeChair(self:getParentNode().cmd_applybanker.wApplyUser) then
		self.m_enApplyState = APPLY_STATE.kApplyState
	end

	self:refreshApplyList()
    
end

--取消申请庄家
function GameViewLayer:onGetCancelBanker(  )
	if self:isMeChair(self:getParentNode().cmd_cancelbanker.wCancelUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
	end
	
	self:refreshApplyList()
end

--刷新列表
function GameViewLayer:refreshApplyList(  )
	if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
		local userList = self:getDataMgr():getApplyBankerUserList()		
		self.m_applyListLayer:refreshList(userList)
	end
    local userList = self:getDataMgr():getApplyBankerUserList()		
    if userList == nil then
     self.Txt_SZRS:setString("0 pessoas na fila")
    else
            self.Txt_SZRS:setString(string.format("%d pessoas na fila",#userList))
     end
      self:setbtApply()
end

function GameViewLayer:refreshUserList(  )
	if nil ~= self.m_userListLayer and self.m_userListLayer:isVisible() then
		local userList = self:getDataMgr():getUserList()		
		self.m_userListLayer:refreshList(userList)
	end
end

--刷新申请列表按钮状态
function GameViewLayer:refreshApplyBtnState(  )
	if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
		self.m_applyListLayer:refreshBtnState()
	end
end

--刷新路单
function GameViewLayer:updateWallBill()
	if nil ~= self.m_wallBill and self.m_wallBill:isVisible() then
		self.m_wallBill:refreshWallBillList()
	end
    if nil ~= self.m_WallBillnode and self.m_WallBillnode:isVisible() then
		self.m_WallBillnode:refreshWallBillList()
	end

end

--更新扑克牌
function GameViewLayer:onGetGameCard( tabRes, bAni, cbTime )
	if nil == self.m_cardLayer then
		self.m_cardLayer = g_var(GameCardLayer):create(self)
		self:addToRootLayer(self.m_cardLayer, TAG_ZORDER.GAMECARD_ZORDER)
	end
	self.m_cardLayer:showLayer(true)
	self.m_cardLayer:refresh(tabRes, bAni, cbTime)
end

--座位坐下信息
function GameViewLayer:onGetSitDownInfo( config, info )
	self.m_tabSitDownConfig = config
	
	local pos = cc.p(0,0)
	--获取已占位信息
	for i = 1, g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
		print("sit chair " .. info[i])
		self:onGetSitDown(i - 1, info[i], false)
	end
end

--座位坐下
function GameViewLayer:onGetSitDown( index, wchair, bAni )
	if wchair ~= nil 
		and nil ~= index
		and index ~= g_var(cmd).SEAT_INVALID_INDEX 
		and wchair ~= G_NetCmd.INVALID_CHAIR then
		local useritem = self:getDataMgr():getChairUserList()[wchair + 1]

		if nil==useritem then
			useritem=self._scene._gameFrame:getTableUserItem(self._scene._gameFrame:GetTableID(),wchair)
		end

		if nil ~= useritem then
			--下标加1
			index = index + 1
			if nil == self.m_tabSitDownUser[index] then
				self.m_tabSitDownUser[index] = g_var(SitRoleNode):create(self, index)
				self.m_tabSitDownUser[index]:setPosition(self.m_tabSitDownList[index]:getPosition())
				self.m_roleSitDownLayer:addChild(self.m_tabSitDownUser[index])
			end
			self.m_tabSitDownUser[index]:onSitDown(useritem, bAni, wchair == self.m_wBankerUser)

			if useritem.dwUserID == GlobalUserItem.dwUserID then
				self.m_nSelfSitIdx = index
			end
		end
	end
end

--座位失败/离开
function GameViewLayer:onGetSitDownLeave( index )
	if index ~= g_var(cmd).SEAT_INVALID_INDEX 
		and nil ~= index then
		index = index + 1
		if nil ~= self.m_tabSitDownUser[index] then
			self.m_tabSitDownUser[index]:removeFromParent()
			self.m_tabSitDownUser[index] = nil
		end

		if self.m_nSelfSitIdx == index then
			self.m_nSelfSitIdx = nil
		end
	end
end

--银行操作成功
function GameViewLayer:onBankSuccess( )
	local bank_success = self:getParentNode().bank_success
	if nil == bank_success then
		return
	end
	GlobalUserItem.lUserScore = bank_success.lUserScore
	GlobalUserItem.lUserInsure = bank_success.lUserInsure

	if nil ~= self.m_bankLayer and true == self.m_bankLayer:isVisible() then
		self:refreshScore()
	end

	showToast(bank_success.szDescribrString)
end

--银行操作失败
function GameViewLayer:onBankFailure( )
	local bank_fail = self:getParentNode().bank_fail
	if nil == bank_fail then
		return
	end

	showToast(bank_fail.szDescribeString)
end

--银行资料
function GameViewLayer:onGetBankInfo(bankinfo)
	bankinfo.wRevenueTake = bankinfo.wRevenueTake or 10
	if nil ~= self.m_bankLayer then
		local str = "Aviso: " .. bankinfo.wRevenueTake .. "% taxa de processamento será deduzida para levantamentos"
		self.m_bankLayer.m_textTips:setString(str)
	end
end
------
---------------------------------------------------------------------------------------
function GameViewLayer:getParentNode( )
	return self._scene;
end

function GameViewLayer:getMeUserItem(  )
	if nil ~= GlobalUserItem.dwUserID then
		return self:getDataMgr():getUidUserList()[GlobalUserItem.dwUserID];
	end
	return nil;
end

function GameViewLayer:isMeChair( wchair )
	local useritem = self:getDataMgr():getChairUserList()[wchair + 1];
	if nil == useritem then
		return false
	else 
		return useritem.dwUserID == GlobalUserItem.dwUserID
	end
end

function GameViewLayer:addToRootLayer( node , zorder)
	if nil == node then
		return
	end

	-- self.m_rootLayer:addChild(node)
	self:addChild(node)
	node:setLocalZOrder(zorder)
end

function GameViewLayer:getChildFromRootLayer( tag )
	if nil == tag then
		return nil
	end
	-- return self.m_rootLayer:getChildByTag(tag)
	return self:getChildByTag(tag)
end

function GameViewLayer:getApplyState(  )
	return self.m_enApplyState
end

function GameViewLayer:getApplyCondition(  )
	return self.m_llCondition
end

--获取能否上庄
function GameViewLayer:getApplyable(  )
	--自己超级抢庄已申请，则不可进行普通申请
	if APPLY_STATE.kSupperApplyed == self.m_enApplyState then
		return false
	end

	local userItem = self:getMeUserItem();
	if nil ~= userItem then
		return userItem.lScore > self.m_llCondition
	else
		return false
	end
end

--获取能否取消上庄
function GameViewLayer:getCancelable(  )
	return self.m_cbGameStatus == g_var(cmd).GAME_SCENE_FREE
end

--下注区域闪烁
function GameViewLayer:showBetAreaBlink(  )
	local blinkArea = self:getDataMgr().m_tabBetArea
	self:jettonAreaBlink(blinkArea)
end

function GameViewLayer:getDataMgr( )
	return self:getParentNode():getDataMgr()
end

function GameViewLayer:logData(msg)
	local p = self:getParentNode()
	if nil ~= p.logData then
		p:logData(msg)
	end	
end

function GameViewLayer:gameDataInit( )

    --播放背景音乐
    g_ExternalFun.playBackgroudAudio("BACK_GROUND.mp3")

    --用户列表
	self:getDataMgr():initUserList(self:getParentNode():getUserList())

    --加载资源
	self:loadRes()

	--变量声明
    self.myCurBet = false  --是否有下注
    self.isZhuangPos = false  --是否为庄
	self.m_nJettonSelect = -1
    self.m_lSelfWinScore = 0
    self.m_lBankerWinScore = 0
	self.m_lHaveJetton = 0;
	self.m_llMaxJetton = 0;
	self.m_llCondition = 0;
	self.m_scoreUser = self:getMeUserItem().lScore or 0

	--下注信息
	self.m_tableJettonBtn = {};
	self.m_tableJettonAreaSpTips = {};
	self.m_tableJettonArea = {};
    self.m_tableAddJettonArea = {};

    self.m_tableAddShowJettonArea = {};
    self.m_tableJettonAreaPoint= {};

    self.m_Hlssm_Battle={}
	--下注提示
	self.m_tableJettonNode = {};

	self.m_applyListLayer = nil
	self.m_userListLayer = nil
	self.m_wallBill = nil
	self.m_cardLayer = nil
	self.m_gameResultLayer = nil
	self.m_pClock = nil
	self.m_bankLayer = nil

	--申请状态
	self.m_enApplyState = APPLY_STATE.kCancelState
	--超级抢庄申请
	self.m_bSupperRobApplyed = false
	--超级抢庄配置
	self.m_tabSupperRobConfig = {}
	--游戏币抢庄提示
	self.m_bRobAlert = false

	--用户坐下配置
	self.m_tabSitDownConfig = {}
	self.m_tabSitDownUser = {}
	--自己坐下
	self.m_nSelfSitIdx = nil

	--座位列表
	self.m_tabSitDownList = {}

	--当前抢庄用户
	self.m_wCurrentRobApply = G_NetCmd.INVALID_CHAIR

	--当前庄家用户
	self.m_wBankerUser = G_NetCmd.INVALID_CHAIR

	--选中的筹码
	self.m_nSelectBet = DEFAULT_BET

	--是否结算状态
	self.m_bOnGameRes = false

	--是否无人坐庄
	self.m_bNoBanker = false
end

function GameViewLayer:gameDataReset(  )
	--资源释放
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game/card.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game/game.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game/game.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game/pk_card.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game/pk_card.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("bank/bank.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("bank/bank.png")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("spritesheet/plist_hlssm_font.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("spritesheet/plist_hlssm_font.png")


	--特殊处理public_res blank.png 冲突
	local dict = cc.FileUtils:getInstance():getValueMapFromFile("public/public.plist")
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			if k ~= "blank.png" then
				cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(k)
			end
		end
	end
	cc.Director:getInstance():getTextureCache():removeTextureForKey("public_res/public_res.png")

	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("setting/setting.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("setting/setting.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()


	--变量释放
	self.m_actDropIn:release();
	self.m_actDropOut:release();
	if nil ~= self.m_cardLayer then
		self.m_cardLayer:clean()
	end

	self:getDataMgr():removeAllUser()
	self:getDataMgr():clearRecord()
end

function GameViewLayer:getJettonIdx( llScore )
	local idx = 2;
	for i=1,#self.m_pJettonNumber do
		if llScore == self.m_pJettonNumber[i].k then
			idx = self.m_pJettonNumber[i].i;
			break;
		end
	end
	return idx;
end

function GameViewLayer:randomSetJettonPos( nodeArea, jettonSp )
	if nil == jettonSp then
		return;
	end

	local pos = self:getBetRandomPos(nodeArea)
	jettonSp:setPosition(cc.p(pos.x, pos.y));
end

function GameViewLayer:getBetFromPos( wchair )
	if nil == wchair then
		return {x = 0, y = 0}
	end
	local winSize = cc.Director:getInstance():getWinSize()

	--是否是自己
	if self:isMeChair(wchair) then
		local tmp = self.m_spBottom:getChildByName("player_head")
		if nil ~= tmp then
			local pos = cc.p(tmp:getPositionX(), tmp:getPositionY())
			pos = self.m_spBottom:convertToWorldSpace(pos)
			return {x = pos.x, y = pos.y}
		else
			return {x = winSize.width/2-370, y = 0+200}
		end
	end

	local useritem = self:getDataMgr():getChairUserList()[wchair + 1]
	if nil == useritem then
		return {x = winSize.width/2-370, y = 0+200}
	end

	--是否是坐下列表
	local idx = nil
	for i = 1,g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
		if (nil ~= self.m_tabSitDownUser[i]) and (wchair == self.m_tabSitDownUser[i]:getChair()) then
			idx = i
			break
		end
	end
	if nil ~= idx then
		local pos = cc.p(self.m_tabSitDownUser[idx]:getPositionX(), self.m_tabSitDownUser[idx]:getPositionY())
		pos = self.m_roleSitDownLayer:convertToWorldSpace(pos)
		return {x = pos.x, y = pos.y}
	end

	--默认位置
	return {x = winSize.width/2-370, y = 0+200}
end

function GameViewLayer:getBetAnimation( pos, call_back,isOut )
	local moveTo = cc.MoveTo:create(BET_ANITIME, cc.p(pos.x, pos.y))
	if nil ~= call_back then
        if isOut then return cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(0.2, cc.p(pos.x, pos.y)))) end
	    local action = cc.Sequence:create(
	    			cc.EaseSineIn:create(cc.MoveTo:create(0.2, cc.p(pos.x, pos.y))
	    		),call_back)
		return action--cc.Sequence:create(cc.EaseIn:create(moveTo, 2), call_back)
	else
		return cc.EaseIn:create(moveTo, 2)
	end
end

function GameViewLayer:getBetRandomPos(nodeArea)
	if nil == nodeArea then
		return {x = 0, y = 0}
	end

	local nodeSize = cc.size(nodeArea:getContentSize().width - 80, nodeArea:getContentSize().height - 80);
	local xOffset = math.random()
	local yOffset = math.random()

	local posX = nodeArea:getPositionX() - nodeArea:getAnchorPoint().x * nodeSize.width
	local posY = nodeArea:getPositionY() - nodeArea:getAnchorPoint().y * nodeSize.height
	return cc.p(xOffset * nodeSize.width + posX, yOffset * nodeSize.height + posY)
end

------
--倒计时节点
function GameViewLayer:createClockNode()
	self.m_pClock = cc.Node:create()
	self.m_pClock:setPosition(665+400,620)
	self:addToRootLayer(self.m_pClock, TAG_ZORDER.CLOCK_ZORDER)

	--加载csb资源
	local csbNode = g_ExternalFun.loadCSB("game/GameClockNode.csb", self.m_pClock)

	--倒计时
	self.m_pClock.m_atlasTimer = csbNode:getChildByName("sp_time_bg_1"):getChildByName("timer_atlas")
	self.m_pClock.m_atlasTimer:setString("")

    self.m_pClock.m_sp_time_bg= csbNode:getChildByName("sp_time_bg_1")

	--提示
	self.m_pClock.m_spTip = csbNode:getChildByName("sp_tip")

    self.m_pClock.m_xiazhu_tip = csbNode:getChildByName("xiazhu_tip")
    self.m_pClock.m_xiazhu_tip:setString("")
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("blank.png")
	if nil ~= frame then
		self.m_pClock.m_spTip:setSpriteFrame(frame)
	end
end

function GameViewLayer:updateClock(tag, left)
	self.m_pClock:setVisible(left > 0)

	local str = string.format("%02d", left)
	self.m_pClock.m_atlasTimer:setString(str)
    if tag ==2 then

         if left<5 then
                  g_ExternalFun.playSoundEffect("TIME_WARIMG.mp3")
                  local action = cc.RotateTo:create(0.15, -15)
                 local action1 = cc.RotateTo:create(0.15, 0)
                 local action2= cc.RotateTo:create(0.15, 15)
                   local action3 = cc.RotateTo:create(0.15, 0)
                   
                  
                   self.m_pClock.m_sp_time_bg:runAction(cc.Sequence:create(action,action1,action2,action3))
            end
              if left==5 then
                    local content =   self.m_im_txt_bg:getChildByName("Image_tip")
              content:loadTexture("ui/txt/Brnn_tips_ld.png")
       -- local content = self.m_timeLayout:getChildByName("im_txt")
            local xiazhu_tip =   self.m_im_txt_bg:getChildByName("im_txt")
              xiazhu_tip:loadTexture("ui/txt/Hlssm_Battle_zf4.png")
            
                   self.m_im_txt_bg:setVisible(true)
                    self.m_im_txt_bg:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(
                        function()
                           self.m_im_txt_bg:setVisible(false)
                         end
                         
                         )))
             end

              if left==1 then
             
            end
             if left==2 then
                    local content =   self.m_im_txt_bg:getChildByName("Image_tip")
              content:loadTexture("ui/txt/Brnn_tips_ld.png")
       -- local content = self.m_timeLayout:getChildByName("im_txt")
            local xiazhu_tip =   self.m_im_txt_bg:getChildByName("im_txt")
              xiazhu_tip:loadTexture("ui/txt/Brnn_tips_bet_end.png")
            
                   self.m_im_txt_bg:setVisible(true)
                    self.m_im_txt_bg:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(
                        function()
                           self.m_im_txt_bg:setVisible(false)
                         end
                         
                         )))
             end
            self.m_lefttime = left
            if left<2 then
            
                
                if self.m_AddgoldList~=nil and #self.m_AddgoldList>0 then
                    for i=1  ,#self.m_AddgoldList do
                            if #self.m_AddgoldList>0 then
			                        self:onRunAnimBet(self.m_AddgoldList[i].wUser ,self.m_AddgoldList[i].area,self.m_AddgoldList[i])
                               
                                 end
                    end

                    self.m_AddgoldList={}
                end
                 
            end
    end
  
	if g_var(cmd).kGAMEOVER_COUNTDOWN == tag then
		if 6 == left then
			if self:getDataMgr().m_bJoin then
				if nil ~= self.m_cardLayer then
					self.m_cardLayer:showLayer(false)
				end
			end					
			--筹码动画
			self:betAnimation()		
		elseif 2 == left then
			if true == self:getDataMgr().m_bJoin then
				self:showGameResult(true)
			end	
			--更新路单列表
			self:updateWallBill()		
		elseif 3 == left then
			if nil ~= self.m_cardLayer then
				self.m_cardLayer:showLayer(false)
			end
		elseif 0 == left then
			--self:showGameResult(false)	

			--闪烁停止
			self:jettonAreaBlinkClean()
		end
	end
end

function GameViewLayer:showTimerTip(tag,time)
	tag = tag or -1
	local scale = cc.ScaleTo:create(0.2, 0.0001, 1.0)
	local call = cc.CallFunc:create(function (  )
		local str = string.format("sp_tip_%d.png", tag)
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)

		self.m_pClock.m_spTip:setVisible(false)
		if nil ~= frame then
			self.m_pClock.m_spTip:setVisible(false)
			self.m_pClock.m_spTip:setSpriteFrame(frame)
		end

         if tag==1 then
            self.m_pClock.m_xiazhu_tip:setString("Tempo livre")
           --  self.skeletonNode:setAnimation(0, "animation", false)

                   
          
           -- self.skeletonNode:setAnimation(0, "animation", true)
            end
        if tag==2 then
            self.m_pClock.m_xiazhu_tip:setString("Tempo de apostas")
            -- self.skeletonNode:setAnimation(0, "animation", false)
              self:showGameResult(false)	
           
            if time<5 then
                  g_ExternalFun.playSoundEffect("TIME_WARIMG.mp3")
                  local action = cc.RotateTo:create(0.15, -15)
                 local action1 = cc.RotateTo:create(0.15, 0)
                 local action2= cc.RotateTo:create(0.15, 15)
                   local action3 = cc.RotateTo:create(0.15, 0)
                   
                  
                   self.m_pClock.m_sp_time_bg:runAction(cc.Sequence:create(action,action1,action2,action3))
            end
            if time==1 then
              --g_ExternalFun.playSoundEffect("STOP_W.mp3")
            end
        end
          if tag==3 then

            
          -- self.skeletonNode:setAnimation(0, "animation", false)
            self.m_pClock.m_xiazhu_tip:setString("Horário de abertura")
            end
	end)
	local scaleBack = cc.ScaleTo:create(0.2,1.0)
	local seq = cc.Sequence:create(scale, call, scaleBack)

	self.m_pClock.m_spTip:stopAllActions()
	self.m_pClock.m_spTip:runAction(seq)
end
------

------
--下注节点
function GameViewLayer:createJettonNode()
	local jettonNode = cc.Node:create()
	--加载csb资源
	local csbNode = g_ExternalFun.loadCSB("game/JettonNode.csb", jettonNode)

	local m_imageBg = csbNode:getChildByName("jetton_bg")
	local m_textMyJetton = m_imageBg:getChildByName("jetton_my")
	local m_textTotalJetton = m_imageBg:getChildByName("jetton_total")

	jettonNode.m_imageBg = m_imageBg
	jettonNode.m_textMyJetton = m_textMyJetton
	jettonNode.m_textTotalJetton = m_textTotalJetton
	jettonNode.m_llMyTotal = 0
	jettonNode.m_llAreaTotal = 0

	return jettonNode
end

function GameViewLayer:refreshJettonNode( node, my, total, bMyJetton )	
	if true == bMyJetton then
		node.m_llMyTotal = node.m_llMyTotal + my
	end

	node.m_llAreaTotal = node.m_llAreaTotal + total
	node:setVisible( node.m_llAreaTotal > 0)

	--自己下注数额
	local str = g_ExternalFun.formatBetScoreKMBT(node.m_llMyTotal);
    --str = string.sub(str,2,#str)
	--str = str .. " /";
	if string.len(str) > 15 then
		str = string.sub(str,1,12)
		--str = str .. "... /";
	end
	node.m_textMyJetton:setString(str);
     if node.m_llMyTotal==0 then

        node.m_textMyJetton:setVisible(false)
    else
      node.m_textMyJetton:setVisible(true)
    end
	--总下注
	str = g_ExternalFun.formatBetScoreKMBT(node.m_llAreaTotal)
	--str = " " .. str;
    -- str = string.sub(str,2,#str)
	if string.len(str) > 15 then
		str = string.sub(str,1,12)
		str = str .. "..."
	else
		local strlen = string.len(str)
		local l = 15 + strlen
		if strlen > l then
			str = string.sub(str, 1, l - 3);
			str = str .. "...";
		end
	end
    if node.m_llAreaTotal==0 then

        node.m_textTotalJetton:setVisible(false)
    else
      node.m_textTotalJetton:setVisible(true)
    end
	node.m_textTotalJetton:setString(str);

	--调整背景宽度
	local mySize = node.m_textMyJetton:getContentSize();
	local totalSize = node.m_textTotalJetton:getContentSize();
	local total = cc.size(mySize.width + totalSize.width + 18, 32);
	node.m_imageBg:setContentSize(total);

	node.m_textTotalJetton:setPositionX(6 + mySize.width);

      local allJettonScore = 0
      for i=1,#self.m_tableJettonArea do
		if nil ~= self.m_tableJettonNode[i] then
			--self.m_tableJettonNode[i]:reSet()
			 allJettonScore=allJettonScore+self.m_tableJettonNode[i].m_llAreaTotal
		end
	end
    self.m_BitmapFontAllAdd:setString(g_ExternalFun.formatBetScoreKMBT(allJettonScore))
    self.m_BitmapFontAllAdd:setPositionX(634 +  self.m_BitmapFontAllAdd:getContentSize().width/2);
end

function GameViewLayer:reSetJettonNode(node)
	node:setVisible(false);

	node.m_textMyJetton:setString("")
	node.m_textTotalJetton:setString("")
	node.m_imageBg:setContentSize(cc.size(34, 32))

	node.m_llMyTotal = 0
	node.m_llAreaTotal = 0
end
------

------
--银行节点
function GameViewLayer:createBankLayer()
	local this = self
	self.m_bankLayer = cc.Node:create()
	self:addToRootLayer(self.m_bankLayer, TAG_ZORDER.BANK_ZORDER)
	self.m_bankLayer:setTag(TAG_ENUM.BANK_LAYER)

	--加载csb资源
	local csbNode = g_ExternalFun.loadCSB("bank/BankLayer.csb", self.m_bankLayer)
	local sp_bg = csbNode:getChildByName("sp_bg")
	csbNode:getChildByName("Text_1"):setString("Feijão bancário")
	csbNode:getChildByName("Text_2"):setString("Feijões atuais")
	------
	--按钮事件
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			this:onButtonClickedEvent(sender:getTag(), sender)
		end
	end	
	--关闭按钮
	local btn = sp_bg:getChildByName("close_btn")
	btn:setTag(TAG_ENUM.BT_CLOSEBANK)
	btn:addTouchEventListener(btnEvent)

	--取款按钮
	btn = sp_bg:getChildByName("out_btn")
	btn:setTag(TAG_ENUM.BT_TAKESCORE)
	btn:addTouchEventListener(btnEvent)
	------

	------
	--编辑框
	--取款金额
	local tmp = sp_bg:getChildByName("count_temp")
	local editbox = ccui.EditBox:create(tmp:getContentSize(),"blank.png",UI_TEX_TYPE_PLIST)
		:setPosition(tmp:getPosition())
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(32)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("Introduza o montante do levantamento")
	sp_bg:addChild(editbox)
	self.m_bankLayer.m_editNumber = editbox
	tmp:removeFromParent()

	--取款密码
	tmp = sp_bg:getChildByName("passwd_temp")
	editbox = ccui.EditBox:create(tmp:getContentSize(),"blank.png",UI_TEX_TYPE_PLIST)
		:setPosition(tmp:getPosition())
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(32)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("Introduza o seu código de retirada")
	sp_bg:addChild(editbox)
	self.m_bankLayer.m_editPasswd = editbox
	tmp:removeFromParent()
	------

	--当前游戏币
	self.m_bankLayer.m_textCurrent = sp_bg:getChildByName("text_current")

	--银行游戏币
	self.m_bankLayer.m_textBank = sp_bg:getChildByName("text_bank")

	--取款费率
	self.m_bankLayer.m_textTips = sp_bg:getChildByName("text_tips")
	self:getParentNode():sendRequestBankInfo()
end
--银行节点
function GameViewLayer:createHelpLayer()
	local this = self
	self.m_helpLayer = cc.Node:create()
	self:addToRootLayer(self.m_helpLayer, TAG_ZORDER.HELP_ZORDER)
	self.m_helpLayer:setTag(TAG_ENUM.HELP_LAYER)

	--加载csb资源
	local csbNode = g_ExternalFun.loadCSB("help/HelpLayer.csb", self.m_helpLayer)
	local sp_bg = csbNode

	------
	--按钮事件
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			this:onButtonClickedEvent(sender:getTag(), sender)
		end
	end	
	--关闭按钮
	local btn = sp_bg:getChildByName("back_btn")
	btn:setTag(TAG_ENUM.BT_HELPCLSOE)
	btn:addTouchEventListener(btnEvent)

end
--取款
function GameViewLayer:onTakeScore()
	--参数判断
	local szScore = string.gsub(self.m_bankLayer.m_editNumber:getText(),"([^0-9])","")
	local szPass = self.m_bankLayer.m_editPasswd:getText()

	if #szScore < 1 then 
		showToast("Introduza o montante da operação!")
		return
	end

	local lOperateScore = tonumber(szScore)
	if lOperateScore<1 then
		showToast("Introduza o montante correto!")
		return
	end

	if #szPass < 1 then 
		showToast("Introduza a sua senha bancária!")
		return
	end
	if #szPass <6 then
		showToast("A senha deve ser maior do que 6 caracteres, reintroduza-a!")
		return
	end

	self:showPopWait()	
	self:getParentNode():sendTakeScore(szScore,szPass)
end

--刷新游戏币
function GameViewLayer:refreshScore(  )
	--携带游戏币
	local str = g_ExternalFun.numberThousands(GlobalUserItem.lUserScore)
	if string.len(str) > 19 then
		str = string.sub(str, 1, 19)
	end
	self.m_bankLayer.m_textCurrent:setString(str)

	--银行存款
	str = g_ExternalFun.numberThousands(GlobalUserItem.lUserInsure)
	if string.len(str) > 19 then
		str = string.sub(str, 1, 19)
	end
	self.m_bankLayer.m_textBank:setString(g_ExternalFun.numberThousands(GlobalUserItem.lUserInsure))

	self.m_bankLayer.m_editNumber:setText("")
	self.m_bankLayer.m_editPasswd:setText("")
end
------
return GameViewLayer