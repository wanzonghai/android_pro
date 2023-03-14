--
-- Author: zhong
-- Date: 2016-07-15 11:03:17
--
--游戏扑克层
local GameCardLayer = class("GameCardLayer", cc.Layer)

local module_pre = "game.yule.baccaratnew.src"

local g_var = g_ExternalFun.req_var;
local CardsNode = module_pre .. ".views.layer.gamecard.CardsNode"
local GameLogic = module_pre .. ".models.GameLogic"
local cmd = module_pre .. ".models.CMD_Game"
local bjlDefine = module_pre .. ".models.bjlGameDefine"
GameCardLayer.RES_PATH 				= "game/yule/baccaratnew/res/"

local scheduler = cc.Director:getInstance():getScheduler()

local kPointDefault = 0
local kDraw = 1 --平局
local kIdleWin = 2 --闲赢
local kMasterWin = 3 --庄赢
local DIS_SPEED = 0.5
local DELAY_TIME = 1.0
local kLEFT_ROLE = 1
local kRIGHT_ROLE = 2

function GameCardLayer:ctor(parent)
	self.m_parent = parent
	--加载csb资源
	local csbNode = g_ExternalFun.loadCSB("game/GameCardLayer.csb",self)	
	self.m_actionNode = csbNode
	csbNode:setVisible(false)
	self.m_action = nil
      self.m_Image_win1 = csbNode:getChildByName("Image_win1")
       self.m_Image_win2 = csbNode:getChildByName("Image_win2")
       self.m_Image_win1:setVisible(false)
       self.m_Image_win2:setVisible(false)
	--点数
	self.m_tabPoint = {}
	self.m_tabPoint[kLEFT_ROLE] = csbNode:getChildByName("idle_res_sp")
	self.m_tabPoint[kRIGHT_ROLE] = csbNode:getChildByName("master_res_sp")

	--状态
	self.m_tabStatus = {}
	self.m_tabStatus[kLEFT_ROLE] = csbNode:getChildByName("idle_sp")
	self.m_tabStatus[kRIGHT_ROLE] = csbNode:getChildByName("master_sp")

	--平局
	self.m_spDraw = csbNode:getChildByName("draw_sp")

	--pk精灵
	self.m_spPk = csbNode:getChildByName("ani_pk")
	--左右底板
	self.m_spLeftBoard = csbNode:getChildByName("sp_pk_l_1")
	self.m_spRightBoard = csbNode:getChildByName("sp_pk_r_2")
    self.m_spLeftBoard:setVisible(false)
     self.m_spRightBoard:setVisible(false)
	--扑克
	self.m_tabCards = {}	
	local idle = g_var(CardsNode):createEmptyCardsNode()
	idle:setPosition(334, 400)
	csbNode:addChild(idle)
	self.m_tabCards[kLEFT_ROLE] = idle

	local master = g_var(CardsNode):createEmptyCardsNode()
	master:setPosition(1000, 400)
	csbNode:addChild(master)
	self.m_tabCards[kRIGHT_ROLE] = master	

	self.m_vecDispatchCards = {}
    self.m_vecOpenCards = {}
	self.m_nTotalCount = 0
	self.m_scheduler = nil
	self.m_nDispatchedCount = 0
    self.m_nOpenCardCount = 0
    self.m_nOpenCardIndex = 0
	self.m_bAnimation = false

	self:reSet()

         csbCardNode =   cc.CSLoader:createNode(GameCardLayer.RES_PATH .."game/Layer.csb");
  csbCardNode:addTo(self)
   --self:addToRootLayer(csbCardNode, ZORDER_LAYER.ZORDER_HAND_Layer)
      self.m_csbCardNode = csbCardNode
      csbCardNode:setPosition(0,0)
      self.m_csbCardNode:setScale(0.8)
     local action = cc.CSLoader:createTimeline(GameCardLayer.RES_PATH ..'game/Layer.csb')
   self.m_csbCardNode:runAction(action)
    self.m_CardAction = action 
   
   self.m_csbCardNode:setVisible(false)

     
        cc.SpriteFrameCache:getInstance():addSpriteFrames("spritesheet/win_effect_plist.plist")

          local animation = cc.Animation:create()
	local i = 1
	while true do
		local strVS = string.format("win2000%d.png",i)
		i = i + 1
		local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(strVS)
		if spriteFrame then
			animation:addSpriteFrame(spriteFrame)
		else
			break
		end
	end
    local strVS1 = "win20001.png"
    local spriteFrame1 = cc.SpriteFrameCache:getInstance():getSpriteFrame(strVS1)
    self.m_Image_win1:setSpriteFrame(spriteFrame1)
    self.m_Image_win2:setSpriteFrame(spriteFrame1)
 
	animation:setDelayPerUnit(0.2)

   cc.AnimationCache:getInstance():addAnimation(animation, "winCard")


end

function GameCardLayer:clean(  )
	if nil ~= self.m_action then
		self.m_action:release()
	end

	if nil ~= self.m_scheduler then
		scheduler:unscheduleScriptEntry(self.m_scheduler)
		self.m_scheduler = nil
	end
    self.m_tabPoint[1]:stopAllActions()
      self.m_tabPoint[2]:stopAllActions()
	self.m_actionNode:stopAllActions()
end

function GameCardLayer:showLayer( var )
	self.m_actionNode:setVisible(var)
	self:setVisible(var)
	if false == var then
		self.m_actionNode:stopAllActions()
		if nil ~= self.m_scheduler then
			print("stop dispatch")
			scheduler:unscheduleScriptEntry(self.m_scheduler)
			self.m_scheduler = nil
		end
	end
end

function GameCardLayer:refresh( tabRes, bAni, cbTime )
	self:reSet()

	local m_nTotalCount = #tabRes.m_idleCards + #tabRes.m_masterCards
	self.m_nTotalCount = m_nTotalCount

	local masterIdx = 1
	local idleIdx = 1
	local loopCount = m_nTotalCount - 1
	for i = 0, loopCount do
		local dis = g_var(bjlDefine).getEmptyDispatchCard()		
		if 0 ~= bit:_and(i,1) then
			if nil ~= tabRes.m_masterCards[masterIdx] then
				dis.m_dir = kRIGHT_ROLE
				dis.m_cbCardData = tabRes.m_masterCards[masterIdx]
                 dis.m_index = masterIdx
				masterIdx = masterIdx + 1
               
			else
				dis.m_dir = kLEFT_ROLE
				dis.m_cbCardData = tabRes.m_idleCards[idleIdx]
                  dis.m_index = idleIdx
				idleIdx = idleIdx + 1
			end
		else
			if nil ~= tabRes.m_idleCards[idleIdx] then
				dis.m_dir = kLEFT_ROLE
				dis.m_cbCardData = tabRes.m_idleCards[idleIdx]
                   dis.m_index = idleIdx
				idleIdx = idleIdx + 1
			else
				dis.m_dir = kRIGHT_ROLE
                    dis.m_index = masterIdx
				dis.m_cbCardData = tabRes.m_masterCards[masterIdx]
				masterIdx = masterIdx + 1
			end
		end

		if 0 == dis.m_cbCardData then
			print("dis error")
		end		
		table.insert(self.m_vecDispatchCards, dis)
	end	
	
	self.m_bAnimation = bAni
	if bAni then
		self:switchLayout(false)
		if nil == self.m_action then 
			self:initAni()
		end
		self.m_actionNode:stopAllActions()
		self.m_action:gotoFrameAndPlay(0,false)	
          --self:switchLayout(true)
            self:onAnimationEnd(true)
		--self.m_actionNode:runAction(self.m_action)	
	else
		self:switchLayout(true)
		self.m_tabStatus[kLEFT_ROLE]:setVisible(true)
		self.m_tabStatus[kRIGHT_ROLE]:setVisible(true)

		--刷新点数
		self.m_tabCards[kLEFT_ROLE]:updateCardsNode(tabRes.m_idleCards, true, false)
		self.m_tabCards[kLEFT_ROLE]:setScale(0.75)
		self:refreshPoint(kLEFT_ROLE)
		
		self.m_tabCards[kRIGHT_ROLE]:updateCardsNode(tabRes.m_masterCards, true, false)
		self.m_tabCards[kRIGHT_ROLE]:setScale(0.75)
		self:refreshPoint(kRIGHT_ROLE)	
        	

		self:calResult()
	end	

      self.m_tabStatus[kLEFT_ROLE]:setVisible(false)
     self.m_tabStatus[kRIGHT_ROLE]:setVisible(false)
end

function GameCardLayer:initAni(  )
	local act = g_ExternalFun.loadTimeLine("game/GameCardLayer.csb")
	self.m_action = act
	self.m_action:retain()
	local function onFrameEvent( frame )
		if nil == frame then
            return
        end        

        local str = frame:getEvent()
        print("frame event ==> "  .. str)
        if str == "end_fun" 
        and true == self.m_bAnimation
        and true == self:isVisible() then
        	self.m_actionNode:stopAllActions()
        	self:onAnimationEnd()
        elseif str == "end_draw" then
        	self:switchLayout(true)
        end
	end
	act:setFrameEventCallFunc(onFrameEvent)
end

function GameCardLayer:reSet()
	self.m_vecDispatchCards = {}
    self.m_vecOpenCards={}
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("room_clearing_ldlefail.png")
	if nil == frame then
		frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("blank.png")
	end
	self.m_tabStatus[kLEFT_ROLE]:setSpriteFrame(frame)

	frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("room_clearing_masterfail.png")
	if nil == frame then
		frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("blank.png")
	end
	self.m_tabStatus[kRIGHT_ROLE]:setSpriteFrame(frame)

	self.m_tabCards[kLEFT_ROLE]:removeAllCards()
	self.m_tabCards[kRIGHT_ROLE]:removeAllCards()

	frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("blank.png")
	self.m_tabPoint[kLEFT_ROLE]:setSpriteFrame(frame)
	self.m_tabPoint[kRIGHT_ROLE]:setSpriteFrame(frame)
	self.m_spDraw:setVisible(false)

	self.m_nTotalCount = 0
	self.m_nDispatchedCount = 0
    self.m_nOpenCardCount = 0
    self.m_nOpenCardIndex = 0
	self.m_enPointResult = kPointDefault

	self.m_tabStatus[kLEFT_ROLE]:setPosition(334, 519)
	self.m_tabStatus[kLEFT_ROLE]:setOpacity(255)
	self.m_tabStatus[kRIGHT_ROLE]:setPosition(1000, 519)
	self.m_tabStatus[kRIGHT_ROLE]:setOpacity(255)

    self.m_tabStatus[kLEFT_ROLE]:setVisible(false)
     self.m_tabStatus[kRIGHT_ROLE]:setVisible(false)
end

function GameCardLayer:onAnimationEnd( )
	--定时器发牌
	local function countDown(dt)
		--self:dispatchUpdate()
	end
    
   print("onAnimationEnd----------------------------")
	if nil == self.m_scheduler then
		self.m_scheduler = scheduler:scheduleScriptFunc(countDown, DIS_SPEED, false)

         local runSeq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
						         self:dispatchUpdate()     
					        end))
                          self.m_actionNode:runAction(runSeq)
                   
        
	end
end
function GameCardLayer:setCardResource(index,cbCardData,onFrameEvent)

		 self.m_cardValue = g_var(GameLogic).GetCardValue(cbCardData)
			self.m_cardColor = g_var(GameLogic).GetCardColor(cbCardData)
   
  
    for i=1 ,5  do
          Panel_5 =self.m_csbCardNode :getChildByName("Panel_"..i+4)
        Panel_6 = Panel_5:getChildByName("Panel_6")
        Image_value =  Panel_6:getChildByName("Image_1")
        Image_smcolor =  Panel_6:getChildByName("Image_2")
        Image_bigcolor =  Panel_6:getChildByName("Image_3")
         local cardColor = math.floor(self.m_cardColor/2)
         self.m_cardValue = ylAll.POKER_VALUE[cbCardData] --math.mod(cbCardData, 16) --bit:_and(cbCardData, 0x0F)
        self.m_cardColor = ylAll.CARD_COLOR[cbCardData] --math.floor(cbCardData / 16) --bit:_rshift(bit:_and(cbCardData, 0xF0), 4)

        cardColor =1
        if self.m_cardColor==1 or self.m_cardColor==3 then
            cardColor =0
        end
         --0x41,0x42,

           --0x41,0x42,
      

         if cardColor==0 then
             Image_value:loadTexture(string.format("card/plist_puke_value_1_%d.png",self.m_cardValue))
         else
             Image_value:loadTexture(string.format("card/plist_puke_value_0_%d.png",self.m_cardValue))
         end
         Image_smcolor:loadTexture(string.format("card/plist_puke_color_xl_small_%d.png",self.m_cardColor))

         Image_bigcolor:loadTexture(string.format("card/plist_puke_color_xl_big_%d.png",self.m_cardColor))
      
    end
   
  
   --  self.m_csbCardNode:stopAllActions()
    -- self.m_csbCardNode:runAction(self.m_CardAction)
     self.m_CardAction:setFrameEventCallFunc(onFrameEvent)
    local pos={cc.p(-200+100-30-10,200+50-10+30-200-50),cc.p(300+100+100+20,200+50-10+30-200-50),cc.p(0+100,-200+100-20+30),cc.p(250+100,-200+100-20+30),cc.p(500+100,-200+100-20+30)}
      local ArrayIndex={2,3,4,5,1}

     
    -- self.m_csbCardNode:stopAllActions()
      self.m_csbCardNode:setPosition( pos[index])
       -- self.m_csbCardNode:setPosition( cc.p(cardpoint[self.startIndex].x+110+20, cardpoint[self.startIndex].y-20))
		self.m_CardAction:gotoFrameAndPlay(2,23,false)	
	--	self.m_csbCardNode:runAction(self.m_CardAction)
  
end
function GameCardLayer:dispatchUpdateNew( )
    print("dispatchUpdate----------------------------")
	if 0 ~= #self.m_vecDispatchCards then
		self.m_nDispatchedCount = self.m_nDispatchedCount + 1

              g_ExternalFun.playSoundEffect("FAIPAI.mp3")
		local dis = self.m_vecDispatchCards[1]
		table.remove(self.m_vecDispatchCards, 1)
       
		local cbCard = dis.m_cbCardData
		local function callFun( sender, tab )
			--self:refreshPoint(tab[1])
            sender.m_dir = tab[1]
            table.insert(self.m_vecOpenCards, sender)
             self.m_nOpenCardCount=self.m_nOpenCardCount+1

          
               local function onFrameEvent( frame )
                    if frame==nil then return end
                    local str = frame:getEvent()
                    if str == "end_draw" then
                      g_ExternalFun.playSoundEffect("FAIPAI.mp3")
                        --  if self.m_nOpenCardIndex<4 then
                            local CardTmp1 = self.m_vecOpenCards[self.m_nOpenCardIndex]
                            CardTmp1:showCardBack(false)
                            CardTmp1:setVisible(true)
                          
                             self.m_nOpenCardIndex=self.m_nOpenCardIndex+1
                            local CardTmp = self.m_vecOpenCards[self.m_nOpenCardIndex]
                             
                            if CardTmp~= nil then
                                  self.m_csbCardNode:setVisible(true)
                                    index = math.mod(self.m_nOpenCardIndex, 2)
                                 if index==0 then
                                    index=2
                                 end
                                   CardTmp:setVisible(false)
                                 self:setCardResource(CardTmp.m_dir,CardTmp:getCardValue(),onFrameEvent)
                            else
                              self.m_csbCardNode:setVisible(false)
                            end
                           
                 
				             --CardTmp:runAction(runSeq)
                         -- end
                       --[[ if #self.m_vecDispatchCards>0 and self.m_nOpenCardCount>=5  and self.m_nOpenCardIndex>4 then
                                self:dispatchUpdateNew()
                                return 
                        end]]
                        if #self.m_vecDispatchCards>0 and self.m_nOpenCardCount>=4  and self.m_nOpenCardIndex>4 then
                            self:dispatchUpdateNew()
                             return
                        elseif #self.m_vecDispatchCards==0 then 


                         local runSeq = cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function() 
						             self:calResult()
                                         if nil ~= self.m_scheduler then
			                                scheduler:unscheduleScriptEntry(self.m_scheduler)
			                                self.m_scheduler = nil
		                                end	

		                                if nil ~= self.m_parent then
			                                self.m_parent:showBetAreaBlink()
		                                end 
					        end))
                             self:runWin(1)
                               CardTmp1:runAction(runSeq)
                                self:refreshPoint(kRIGHT_ROLE)	
                               self:refreshPoint(kLEFT_ROLE)	


                            return
                        end
                    end
                end
             
              if self.m_nOpenCardCount==4 then
                      if self.m_nOpenCardIndex<3 then
                            self.m_nOpenCardIndex=3
                            local CardTmp = self.m_vecOpenCards[self.m_nOpenCardIndex]
                           --[[  local runSeq = cc.Sequence:create(cc.DelayTime:create(3), spawn, cc.DelayTime:create(0.05), moveTo2,cc.CallFunc:create(function() 
						           self.m_csbCardNode:setVisible(true)
                                    print("setCardResource----------------------------"..sender:getTag())
                                    self:setCardResource(tab[1],cbCard,onFrameEvent)
					        end))]]
                         self.m_csbCardNode:setVisible(true)
                         index = math.mod(self.m_nOpenCardIndex, 2)
                         if index>0 then
                            index=1
                         end
                         CardTmp:setVisible(false)
                         self:setCardResource(CardTmp.m_dir,CardTmp:getCardValue(),onFrameEvent)
				        -- CardTmp:runAction(runSeq)
                      end  
              end
             if self.m_nOpenCardCount<4 then

                     if self.m_nOpenCardCount<3 then
                        sender:showCardBack(false)
                     end
                     if #self.m_vecDispatchCards>0 then
                            self:dispatchUpdate()
                      end
             else
            
                       local CardTmp = self.m_vecOpenCards[self.m_nOpenCardIndex]
                           --[[  local runSeq = cc.Sequence:create(cc.DelayTime:create(3), spawn, cc.DelayTime:create(0.05), moveTo2,cc.CallFunc:create(function() 
						           self.m_csbCardNode:setVisible(true)
                                    print("setCardResource----------------------------"..sender:getTag())
                                    self:setCardResource(tab[1],cbCard,onFrameEvent)
					        end))]]
                            if CardTmp   then
                                
                               
                                
                                 local runSeq = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() 
					                       CardTmp:setVisible(false)
                                          self.m_csbCardNode:setVisible(true)
                                         self:setCardResource(CardTmp.m_dir,CardTmp:getCardValue(),onFrameEvent)
                     
				            	end))
                                 CardTmp:runAction(runSeq)
                               
                         end
                end
           

            
		end

        -- self:setCardResource(cbCard,onFrameEvent)
		self:addCards(cbCard, dis.m_dir, cc.CallFunc:create(callFun,{dis.m_dir, dis.m_index}))

		self:noticeTips()
	else
		self:calResult()
		if nil ~= self.m_scheduler then
			scheduler:unscheduleScriptEntry(self.m_scheduler)
			self.m_scheduler = nil
		end	

		if nil ~= self.m_parent then
			self.m_parent:showBetAreaBlink()
		end
	end
end
function GameCardLayer:dispatchUpdate( )

 print("dispatchUpdate----------------------------")
	if 0 ~= #self.m_vecDispatchCards then
		self.m_nDispatchedCount = self.m_nDispatchedCount + 1
		local dis = self.m_vecDispatchCards[1]
         
          g_ExternalFun.playSoundEffect("FAIPAI.mp3")
		table.remove(self.m_vecDispatchCards, 1)
       
		local cbCard = dis.m_cbCardData
		local function callFun( sender, tab )
			--self:refreshPoint(tab[1])
            sender.m_dir = tab[1]
            table.insert(self.m_vecOpenCards, sender)
             self.m_nOpenCardCount=self.m_nOpenCardCount+1

          
               local function onFrameEvent( frame )
                    if frame==nil then return end
                    local str = frame:getEvent()
                    if str == "end_draw" then
                     g_ExternalFun.playSoundEffect("FAIPAI.mp3")
                        --  if self.m_nOpenCardIndex<4 then
                            local CardTmp1 = self.m_vecOpenCards[self.m_nOpenCardIndex]
                            CardTmp1:showCardBack(false)
                            CardTmp1:setVisible(true)
                             self.m_nOpenCardIndex=self.m_nOpenCardIndex+1
                            local CardTmp = self.m_vecOpenCards[self.m_nOpenCardIndex]
                             
                            if CardTmp~= nil then
                                  self.m_csbCardNode:setVisible(true)
                               
                                   CardTmp:setVisible(false)
                                 self:setCardResource(CardTmp.m_dir,CardTmp:getCardValue(),onFrameEvent)
                            else
                              self.m_csbCardNode:setVisible(false)
                            end
                           
                 
				             --CardTmp:runAction(runSeq)
                         -- end
                    
                        if #self.m_vecDispatchCards>0 and self.m_nOpenCardCount>=4  and self.m_nOpenCardIndex>4 then
                                self:dispatchUpdateNew()
                                return 
                         elseif #self.m_vecDispatchCards==0 and self.m_nOpenCardIndex>4 then 

                          local runSeq = cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function() 
						             self:calResult()
                                         if nil ~= self.m_scheduler then
			                                scheduler:unscheduleScriptEntry(self.m_scheduler)
			                                self.m_scheduler = nil
		                                end	

		                                if nil ~= self.m_parent then
			                                self.m_parent:showBetAreaBlink()
		                                end 
					        end))
                             CardTmp1:runAction(runSeq)
                             self:runWin(1)
                             self:refreshPoint(kRIGHT_ROLE)	
                             self:refreshPoint(kLEFT_ROLE)	
                            return
                        
                        end
                    end
                end
             
              if self.m_nOpenCardCount==4 then
                      if self.m_nOpenCardIndex<3 and #self.m_vecOpenCards==4 then
                            self.m_nOpenCardIndex=3
                            local CardTmp = self.m_vecOpenCards[self.m_nOpenCardIndex]
                           --[[  local runSeq = cc.Sequence:create(cc.DelayTime:create(3), spawn, cc.DelayTime:create(0.05), moveTo2,cc.CallFunc:create(function() 
						           self.m_csbCardNode:setVisible(true)
                                    print("setCardResource----------------------------"..sender:getTag())
                                    self:setCardResource(tab[1],cbCard,onFrameEvent)
					        end))]]
                         
                       
                         

                           local runSeq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
					                     CardTmp:setVisible(false)
                                         self.m_csbCardNode:setVisible(true)
                                          self:setCardResource(CardTmp.m_dir,CardTmp:getCardValue(),onFrameEvent)
                     
				            	end))
                                 CardTmp:runAction(runSeq)
                        -- self:setCardResource(CardTmp.m_dir,CardTmp:getCardValue(),onFrameEvent)
				        -- CardTmp:runAction(runSeq)
                      end  
              end
               if self.m_nOpenCardCount<4 then

                     if self.m_nOpenCardCount<3 then
                        sender:showCardBack(false)
                     end
                     if #self.m_vecDispatchCards>0 then
                            self:dispatchUpdate()
                      end
                 else
            
                    
                end
           

            
		end

        -- self:setCardResource(cbCard,onFrameEvent)
		self:addCards(cbCard, dis.m_dir, cc.CallFunc:create(callFun,{dis.m_dir, dis.m_index}))

		self:noticeTips()
	else
		self:calResult()
		if nil ~= self.m_scheduler then
			scheduler:unscheduleScriptEntry(self.m_scheduler)
			self.m_scheduler = nil
		end	

		if nil ~= self.m_parent then
			self.m_parent:showBetAreaBlink()
		end
	end
end

function GameCardLayer:dispatchUpdate1( )
	if 0 ~= #self.m_vecDispatchCards then
		self.m_nDispatchedCount = self.m_nDispatchedCount + 1
		local dis = self.m_vecDispatchCards[1]
		table.remove(self.m_vecDispatchCards, 1)

		local cbCard = dis.m_cbCardData
		local function callFun( sender, tab )
			self:refreshPoint(tab[1])
		end

         self:setCardResource(cbCard,onFrameEvent)
		--self:addCards(cbCard, dis.m_dir, cc.CallFunc:create(callFun,{dis.m_dir}))

		self:noticeTips()
	else
		self:calResult()
		if nil ~= self.m_scheduler then
			scheduler:unscheduleScriptEntry(self.m_scheduler)
			self.m_scheduler = nil
		end	

		if nil ~= self.m_parent then
			self.m_parent:showBetAreaBlink()
		end
	end
end

function GameCardLayer:calResult( )
	--不做排序，按顺序计算
	local idleCards = self.m_tabCards[kLEFT_ROLE]:getHandCards()
	--g_var(GameLogic).SortCardList(idleCards, GameLogic.ST_ORDER)
	local idlePoint = g_var(GameLogic).GetCardListPip(idleCards)

	local masterCards = self.m_tabCards[kRIGHT_ROLE]:getHandCards()
	--g_var(GameLogic).SortCardList(masterCards, GameLogic.ST_ORDER)
	local masterPoint = g_var(GameLogic).GetCardListPip(masterCards)
	--点数记录
	self.m_parent:getDataMgr().m_tabGameResult.m_cbIdlePoint = idlePoint
	self.m_parent:getDataMgr().m_tabGameResult.m_cbMasterPoint = masterPoint

    	self.m_parent:getDataMgr().m_tabGameResult.idleCards = idleCards
        	self.m_parent:getDataMgr().m_tabGameResult.masterCards = masterCards

	local nowCBWinner = g_var(cmd).AREA_MAX
	local nowCBKingWinner = g_var(cmd).AREA_MAX

	local cbBetAreaBlink = {0,0,0,0,0,0,0,0}
	if idlePoint > masterPoint then		
		self.m_enPointResult = kIdleWin
   
		--闲
		nowCBWinner = g_var(cmd).AREA_XIAN
		cbBetAreaBlink[g_var(cmd).AREA_XIAN + 1] = 1
		--闲天王
		if 8 == idlePoint or 9 == idlePoint then
			nowCBKingWinner = g_var(cmd).AREA_XIAN_TIAN
			cbBetAreaBlink[g_var(cmd).AREA_XIAN_TIAN + 1] = 1
		end
	elseif idlePoint < masterPoint then
		self.m_enPointResult = kMasterWin

		--庄
		nowCBWinner = g_var(cmd).AREA_ZHUANG
		cbBetAreaBlink[g_var(cmd).AREA_ZHUANG + 1] = 1
		if 8 == masterPoint or 9 == masterPoint then
			nowCBKingWinner = g_var(cmd).AREA_ZHUANG_TIAN
			cbBetAreaBlink[g_var(cmd).AREA_ZHUANG_TIAN + 1] = 1
		end
	elseif idlePoint == masterPoint then
		self.m_enPointResult = kDraw

		--平
		nowCBWinner = g_var(cmd).AREA_PING
		cbBetAreaBlink[g_var(cmd).AREA_PING + 1] = 1
		--判断是否为同点平
		local bAllPointSame = false
		if #idleCards == #masterCards then
			local cbCardIdx = 1
			for i = cbCardIdx, #idleCards do
				local cbBankerValue = g_var(GameLogic).GetCardValue(masterCards[cbCardIdx])
				local cbIdleValue = g_var(GameLogic).GetCardValue(idleCards[cbCardIdx])

				if cbBankerValue ~= cbIdleValue then
					break
				end

				if cbCardIdx == #masterCards then
					bAllPointSame = true
				end

                cbCardIdx = cbCardIdx + 1 ;

			end
		end

		--同点平
		if true == bAllPointSame then
			nowCBKingWinner = g_var(cmd).AREA_TONG_DUI
			cbBetAreaBlink[g_var(cmd).AREA_TONG_DUI + 1] = 1
		end
	end

	--对子判断
	local nowBIdleTwoPair = false
	local nowBMasterTwoPair = false
	--闲对子
	if g_var(GameLogic).GetCardValue(idleCards[1]) == g_var(GameLogic).GetCardValue(idleCards[2]) then
		nowBIdleTwoPair = true
		cbBetAreaBlink[g_var(cmd).AREA_XIAN_DUI + 1] = 1
	end
	--庄对子
	if g_var(GameLogic).GetCardValue(masterCards[1]) == g_var(GameLogic).GetCardValue(masterCards[2]) then
		nowBMasterTwoPair = true
		cbBetAreaBlink[g_var(cmd).AREA_ZHUANG_DUI + 1] = 1
	end
	self.m_parent:getDataMgr().m_tabBetArea = cbBetAreaBlink

	local bJoin = self.m_parent:getDataMgr().m_bJoin
	local res = self.m_parent:getDataMgr().m_tabGameResult
	if nil ~= self.m_parent then
		--添加路单记录
		local rec = g_var(bjlDefine).getEmptyRecord()

        local serverrecord = g_var(bjlDefine).getEmptyServerRecord()
        serverrecord.cbKingWinner = nowCBKingWinner
        serverrecord.bPlayerTwoPair = nowBIdleTwoPair
        serverrecord.bBankerTwoPair = nowBMasterTwoPair
        serverrecord.cbPlayerCount = idlePoint
        serverrecord.cbBankerCount = masterPoint
        rec.m_pServerRecord = serverrecord
        rec.m_cbGameResult = nowCBWinner
        
       -- rec.m_tagUserRecord.m_bJoin = bJoin
        rec.m_tagUserRecord.m_bJoin = true
        self.m_parent:getDataMgr().m_bJoin = true
        if bJoin then        	
        	rec.m_tagUserRecord.m_bWin = res.m_llTotal > 0
        end

        self.m_parent:getDataMgr():addGameRecord(rec)
	end

	--刷新结果
	self:refreshResult(self.m_enPointResult)

	--播放音效
	if true == bJoin then
		--
		if res.m_llTotal > 0 then
			--g_ExternalFun.playSoundEffect("END_WIN.wav")
		elseif res.m_llTotal < 0 then
			--g_ExternalFun.playSoundEffect("END_LOST.wav")
		else
			--g_ExternalFun.playSoundEffect("END_DRAW.wav")
		end
	else
		--g_ExternalFun.playSoundEffect("END_DRAW.wav")
	end

  
end

function GameCardLayer:addCards( cbCard, dir, pCallBack )
	--print("on add card:" .. g_var(GameLogic).GetCardValue(cbCard) .. ";dir " .. dir)
	if nil == self.m_tabCards[dir] then
		return
	end

	if nil ~= pCallBack then
		pCallBack:retain()
	end
	self.m_tabCards[dir]:addCards(cbCard, pCallBack)
end

function GameCardLayer:refreshPoint( dir )
	if nil == self.m_tabCards[dir] then
		return
	end
	local handCards = self.m_tabCards[dir]:getHandCards()

 
    
	--切换动画
	local sca = cc.ScaleTo:create(0.2,0.0001,1.0)
	local call = cc.CallFunc:create(function ()
		local point = g_var(GameLogic).GetCardListPip(handCards)
		local str = string.format("ui/txt/hlssm_point_%d.png", point)
           if dir ==1 then
                str1 = string.format("x/X_%d.mp3",point)
                 g_ExternalFun.playSoundEffect(str1)
                 else

                
                 
            end
		--[[local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)
		if nil ~= frame then
			self.m_tabPoint[dir]:setSpriteFrame(frame)
		end]]
        self.m_tabPoint[dir]:setTexture(str)
	end)
	local sca2 = cc.ScaleTo:create(0.2,1.0)
	local seq = cc.Sequence:create(sca, call, sca2)
	self.m_tabPoint[dir]:stopAllActions()

    
    if dir==2 then
    local point1 = g_var(GameLogic).GetCardListPip(handCards)
             local seq = cc.Sequence:create(sca, call, sca2,cc.DelayTime:create(2),cc.CallFunc:create(function() 
						          str = string.format("z/Z_%d.mp3",point1)
                                    g_ExternalFun.playSoundEffect(str) 
                                    local handCards1 = self.m_tabCards[1]:getHandCards()
                                       local handCards2 = self.m_tabCards[2]:getHandCards()
                                        local idlePoint = g_var(GameLogic).GetCardListPip(handCards1)
                                         local masterPoint = g_var(GameLogic).GetCardListPip(handCards2)

                             if idlePoint<masterPoint then
                                    local seq1 = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
						            str1 = string.format("z/Z_Y.mp3")
                                  
                                    g_ExternalFun.playSoundEffect(str1)
                                    end))
                                    self.m_actionNode:runAction(seq1)
                               end
                               if idlePoint>masterPoint then
                                    local seq1 = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
						            str1 = string.format("x/X_Y.mp3")
                                  
                                    g_ExternalFun.playSoundEffect(str1)
                                    end))
                                    self.m_actionNode:runAction(seq1)
                               end
			end))
	    self.m_tabPoint[dir]:runAction(seq)
    else
        	self.m_tabPoint[dir]:runAction(seq)
    end
               
end

function GameCardLayer:refreshResult( enResult )
	local call_switch = cc.CallFunc:create(function()
		self:switchLayout(true)
	end)

	if kDraw == enResult then
		if nil == self.m_action then 
			self:initAni()
		end
		self.m_actionNode:stopAllActions()
		self.m_action:gotoFrameAndPlay(10,false)	
        --self:switchLayout(true)
        self:onAnimationEnd(true)
		--self.m_actionNode:runAction(self.m_action)
	elseif kIdleWin == enResult then
		local sca = cc.ScaleTo:create(0.2,0.0001,1.0)
		local call = cc.CallFunc:create(function(  )
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("room_clearing_ldlewin.png")
			if nil ~= frame then
				self.m_tabStatus[kLEFT_ROLE]:setSpriteFrame(frame)
			end
		end)
		local sca2 = cc.ScaleTo:create(0.2,1.0)
		local seq = cc.Sequence:create(sca, call, sca2, cc.DelayTime:create(0.5), call_switch)
		self.m_tabStatus[kLEFT_ROLE]:stopAllActions()
		--self.m_tabStatus[kLEFT_ROLE]:runAction(seq)

	elseif kMasterWin == enResult then
		local sca = cc.ScaleTo:create(0.2,0.0001,1.0)
		local call = cc.CallFunc:create(function(  )
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("room_clearing_masterwin.png")
			if nil ~= frame then
				self.m_tabStatus[kRIGHT_ROLE]:setSpriteFrame(frame)
			end
		end)
		local sca2 = cc.ScaleTo:create(0.2,1.0)
		local seq = cc.Sequence:create(sca, call, sca2, cc.DelayTime:create(0.5), call_switch)
		self.m_tabStatus[kRIGHT_ROLE]:stopAllActions()
		--self.m_tabStatus[kRIGHT_ROLE]:runAction(seq)
	end
     self.m_tabStatus[kLEFT_ROLE]:setVisible(false)
     self.m_tabStatus[kRIGHT_ROLE]:setVisible(false)
end

function GameCardLayer:noticeTips(  )
	local m_nTotalCount = self.m_nTotalCount
	local m_nDispatchedCount = self.m_nDispatchedCount

	if m_nTotalCount > 4 then
		if m_nDispatchedCount >= 4 and nil ~= self.m_scheduler then
			--scheduler:unscheduleScriptEntry(self.m_scheduler)
			--self.m_scheduler = nil
			local call = cc.CallFunc:create(function()
				--self:onAnimationEnd()
			end)
			--local seq = cc.Sequence:create(cc.DelayTime:create(DELAY_TIME), call)
			--self:stopAllActions()
			--self:runAction(seq)
		end

		local idleCards = self.m_tabCards[kLEFT_ROLE]:getHandCards()
		--g_var(GameLogic).SortCardList(idleCards, GameLogic.ST_ORDER)
		local idlePoint = g_var(GameLogic).GetCardListPip(idleCards)

		local masterCards = self.m_tabCards[kRIGHT_ROLE]:getHandCards()
		--g_var(GameLogic).SortCardList(masterCards, GameLogic.ST_ORDER)
		local masterPoint = g_var(GameLogic).GetCardListPip(masterCards)

		local idleCount = #idleCards
		local masterCount = #masterCards
		local str = ""
		if m_nDispatchedCount == 4 then
			if idleCount == 2 and (6 == idlePoint or 7 == idlePoint) then
				str = string.format("闲前两张 %d 点,庄 %d 点,庄继续拿牌", idlePoint, masterPoint)
                str = string.format("add/Z_A_%d.mp3",masterPoint)

                  local seq = cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() 
						       g_ExternalFun.playSoundEffect(str)
			    end))
	          self.m_tabPoint[2]:runAction(seq)
           
			elseif idleCount == 2 and idlePoint < 6 then
				str = string.format("闲 %d 点, 庄 %d 点,闲继续拿牌", idlePoint, masterPoint)
                str = string.format("add/X_A_%d.mp3",idlePoint)
                  local seq = cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() 
						       g_ExternalFun.playSoundEffect(str)
			    end))
	          self.m_tabPoint[1]:runAction(seq)
			elseif idleCount == 2 and (masterPoint >= 3 and masterPoint <= 5) then
				str = string.format("闲不补牌, 庄 %d 点,闲继续拿牌", masterPoint)
                  str = string.format("add/X_A_%d.mp3",idlePoint)
                   local seq = cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() 
						       g_ExternalFun.playSoundEffect(str)
			    end))
	          self.m_tabPoint[1]:runAction(seq)
			end
		elseif m_nDispatchedCount == 5 then
			if idleCount == 3 and masterCount == 2 and m_nTotalCount == 6 then
				local cbValue = g_var(GameLogic).GetCardPip(idleCards[3])
				str = string.format("闲第三张牌 %d 点,庄 %d 点,庄继续拿牌", cbValue, masterPoint)

                   str = string.format("add/Z_A_%d.mp3",masterPoint)
                   local seq = cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() 
						       g_ExternalFun.playSoundEffect(str)

                            


			    end))
	          self.m_tabPoint[2]:runAction(seq)

			end
		end

		if "" ~= str then
			--showToast(self,str,1)
		end
	end
end

--调整显示界面 bDisOver 是否发牌结束
function GameCardLayer:switchLayout( bDisOver )
	if bDisOver then 
		if self.m_enPointResult == kDraw then
			self:cardMoveAni()
		else
			--状态位置挪动
			local mo = cc.MoveTo:create(0.2, cc.p(434, 519))
			self.m_tabStatus[kLEFT_ROLE]:stopAllActions()
			--self.m_tabStatus[kLEFT_ROLE]:runAction(mo)

			mo = cc.MoveTo:create(0.2, cc.p(900, 519))
			local call = cc.CallFunc:create(function()
				self:cardMoveAni()
			end)
			local seq = cc.Sequence:create(mo, cc.DelayTime:create(0.5), call)
			self.m_tabStatus[kRIGHT_ROLE]:stopAllActions()
			--self.m_tabStatus[kRIGHT_ROLE]:runAction(seq)
		end				
	else
		--回位
		self.m_tabCards[kLEFT_ROLE]:stopAllActions()
		self.m_tabCards[kLEFT_ROLE]:setScale(1.0)
		self.m_tabCards[kLEFT_ROLE]:setPosition(334, 400)
		self.m_tabCards[kRIGHT_ROLE]:stopAllActions()
		self.m_tabCards[kRIGHT_ROLE]:setScale(1.0)
		self.m_tabCards[kRIGHT_ROLE]:setPosition(1000, 400)	

		--self.m_tabStatus[kLEFT_ROLE]:setPosition(334, 519)
        self.m_tabStatus[kLEFT_ROLE]:setPosition(0, 0)
		self.m_tabStatus[kLEFT_ROLE]:setOpacity(255)
		--self.m_tabStatus[kRIGHT_ROLE]:setPosition(1000, 519)
        self.m_tabStatus[kRIGHT_ROLE]:setPosition(0, 0)
		self.m_tabStatus[kRIGHT_ROLE]:setOpacity(255)

		self.m_tabPoint[kLEFT_ROLE]:setPosition(334, 296)
		self.m_tabPoint[kRIGHT_ROLE]:setPosition(1000, 296)
		--self.m_spPk:setVisible(true)
        self.m_spPk:setVisible(false)
	end


end

function GameCardLayer:cardMoveAni(  )
	--扑克、点数，移动位置
	self.m_tabCards[kLEFT_ROLE]:stopAllActions()
	local move = cc.MoveTo:create(0.2, cc.p(434,400))
	local scal = cc.ScaleTo:create(0.2, 0.75)
	local spa = cc.Spawn:create(move, scal)
	self.m_tabCards[kLEFT_ROLE]:runAction(spa)

	self.m_tabCards[kRIGHT_ROLE]:stopAllActions()
	move = cc.MoveTo:create(0.2, cc.p(900,400))
	scal = cc.ScaleTo:create(0.2, 0.75)
	spa = cc.Spawn:create(move, scal)
	self.m_tabCards[kRIGHT_ROLE]:runAction(spa)

	move = cc.MoveTo:create(0.2, cc.p(434,296))
	self.m_tabPoint[kLEFT_ROLE]:stopAllActions()
	self.m_tabPoint[kLEFT_ROLE]:runAction(move)

	move = cc.MoveTo:create(0.2, cc.p(900,296))
	self.m_tabPoint[kRIGHT_ROLE]:stopAllActions()
	self.m_tabPoint[kRIGHT_ROLE]:runAction(move)

	self:showAniBoard(false)
end

function GameCardLayer:showAniBoard( bShow )
	self.m_spLeftBoard:setVisible(false)
	self.m_spRightBoard:setVisible(false)
	self.m_spPk:setVisible(false)
end
function GameCardLayer:runWin(dir)
    
         local idleCards = self.m_tabCards[kLEFT_ROLE]:getHandCards()
	--g_var(GameLogic).SortCardList(idleCards, GameLogic.ST_ORDER)
	local idlePoint = g_var(GameLogic).GetCardListPip(idleCards)

	local masterCards = self.m_tabCards[kRIGHT_ROLE]:getHandCards()
	--g_var(GameLogic).SortCardList(masterCards, GameLogic.ST_ORDER)
	local masterPoint = g_var(GameLogic).GetCardListPip(masterCards)
      if idlePoint==masterPoint then
        return 
      end

  
  	local animation1 = cc.AnimationCache:getInstance():getAnimation("winCard")
	print("animation",animation1)
	local animate = cc.Animate:create(animation1)

	
	local animateVS = cc.Sequence:create(animate, cc.CallFunc:create(function()
	        
                 self.m_Image_win1:setVisible(false)
                 self.m_Image_win2:setVisible(false)
            return 
		end))
             
  


             
     
  if idlePoint>masterPoint then
        self.m_Image_win1:setVisible(true)
        self.m_Image_win1:stopAllActions() 
          self.m_Image_win1:runAction(animateVS)
  
    --self.m_tabCards[1]:stopAllActions()
    --self.m_tabCards[1]:runAction(animateVS)  
  end
    if idlePoint<masterPoint then
         self.m_Image_win2:setVisible(true)
        self.m_Image_win2:stopAllActions() 
          self.m_Image_win2:runAction(animateVS)
     end
   
end
return GameCardLayer