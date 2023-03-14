--
-- Author: zhouweixiang
-- Date: 2016-12-27 17:55:44
--
--游戏结算层
local ClipText = appdf.req(appdf.CLIENT_SRC .. "Tools.ClipText")
local CardSprite = appdf.req(appdf.GAME_SRC.."yule.baccaratnew.src.views.layer.gamecard.CardSprite")
local GameResultLayer = class("GameResultLayer", cc.Layer)
local wincolor = cc.c3b(255, 247, 178)
local failedcolor = cc.c3b(178, 243, 255)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.baccaratnew.src.models.GameLogic")
local g_var = g_ExternalFun.req_var
GameResultLayer.BT_CLOSE = 1
function GameResultLayer:ctor(viewParent)
	self.m_parent = viewParent

	self.m_winNode = nil

	self.m_failedNode = nil
end

function GameResultLayer:initWinLayer()
	local csbNode = g_ExternalFun.loadCSB("game/GameWin.csb", self)
	csbNode:setVisible(false)
	self.m_winNode = csbNode

	self.m_winAction = g_ExternalFun.loadTimeLine("game/GameWin.csb", self)
	self.m_winAction:retain()
    	--关闭按钮
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end
       local  layout_bg = self.m_winNode:getChildByName("layout_bg")
	local btn = layout_bg:getChildByName("Button_Close")

  
    
	btn:setTag(GameResultLayer.BT_CLOSE)
	btn:addTouchEventListener(btnEvent)


	--local temp = csbNode:getChildByName("im_win")
	--temp = temp:getChildByName("num_score")
	--self.m_winScore = temp

	--庄家名称
    	local Panel_2 = self.m_winNode:getChildByName("Panel_2")
	local pname1 = Panel_2:getChildByName("Text_Name")

	--[[temp = csbNode:getChildByName("im_frame")
	local pname = temp:getChildByName("txt_banker")
	local clipText = ClipText:createClipText(pname:getContentSize(), "")
	clipText:setTextFontSize(30)
	clipText:setAnchorPoint(pname:getAnchorPoint())
	clipText:setPosition(pname:getPosition())
	clipText:setTextColor(cc.c3b(177, 139, 80))
	temp:addChild(clipText)
	pname:removeFromParent()]]
	self.m_winBankerName = pname1

	--玩家名称
	--[[pname = temp:getChildByName("txt_self")
	clipText = ClipText:createClipText(pname:getContentSize(), "")
	clipText:setTextFontSize(30)
	clipText:setTextColor(cc.c3b(177, 139, 80))
	clipText:setAnchorPoint(pname:getAnchorPoint())
	clipText:setPosition(pname:getPosition())
	temp:addChild(clipText)
	pname:removeFromParent()]]

   local  Panel_1 = self.m_winNode:getChildByName("Panel_1")
	local pname2 = Panel_1:getChildByName("Text_Name")
	self.m_winSelfName = pname2
    local Panel_Card = Panel_1:getChildByName("Panel_Card")
   --[[for i=1,3  do
          local Cardsprite = CardSprite:createCard(5)    
          Cardsprite:addTo(Panel_Card)
          Cardsprite:setTag(2000+i)
          Cardsprite:setScale(0.5)
          Cardsprite:setPosition(cc.p(20+(i-1)*30,30))
      end
     ]]

   	--[[local Panel_2 = self.m_winNode:getChildByName("Panel_2")
	local Panel_Card = Panel_2:getChildByName("Panel_Card")
      
      for i=1,3  do
          local Cardsprite = CardSprite:createCard(5)    
          Cardsprite:addTo(Panel_Card)
          Cardsprite:setTag(2000+i)
          Cardsprite:setScale(0.5)
          Cardsprite:setPosition(cc.p(20+(i-1)*30,30))
      end

     ]]
      

    
      

      
   
end

function GameResultLayer:initFailedLayer()
	local csbNode = g_ExternalFun.loadCSB("game/GameFailed.csb", self)
	csbNode:setVisible(false)
	self.m_failedNode = csbNode

	self.m_failedAction = g_ExternalFun.loadTimeLine("game/GameFailed.csb", self)
	self.m_failedAction:retain()

 	--关闭按钮
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end
       local  layout_bg = self.m_failedNode:getChildByName("layout_bg")
	local btn = layout_bg:getChildByName("Button_Close")

    
	btn:setTag(GameResultLayer.BT_CLOSE)
	btn:addTouchEventListener(btnEvent)


	--local temp = csbNode:getChildByName("im_win")
	--temp = temp:getChildByName("num_score")
	--self.m_winScore = temp

	--庄家名称
    	local Panel_2 = self.m_failedNode:getChildByName("Panel_2")
	local pname1 = Panel_2:getChildByName("Text_Name")

	--[[temp = csbNode:getChildByName("im_frame")
	local pname = temp:getChildByName("txt_banker")
	local clipText = ClipText:createClipText(pname:getContentSize(), "")
	clipText:setTextFontSize(30)
	clipText:setAnchorPoint(pname:getAnchorPoint())
	clipText:setPosition(pname:getPosition())
	clipText:setTextColor(cc.c3b(177, 139, 80))
	temp:addChild(clipText)
	pname:removeFromParent()]]
	self.m_winBankerName = pname1

	--玩家名称
	--[[pname = temp:getChildByName("txt_self")
	clipText = ClipText:createClipText(pname:getContentSize(), "")
	clipText:setTextFontSize(30)
	clipText:setTextColor(cc.c3b(177, 139, 80))
	clipText:setAnchorPoint(pname:getAnchorPoint())
	clipText:setPosition(pname:getPosition())
	temp:addChild(clipText)
	pname:removeFromParent()]]

   local  Panel_1 = self.m_failedNode:getChildByName("Panel_1")
	local pname2 = Panel_1:getChildByName("Text_Name")
	self.m_winSelfName = pname2

  
     

   	local Panel_2 = self.m_failedNode:getChildByName("Panel_2")
	local Panel_Card = Panel_2:getChildByName("Panel_Card")
      
     

  
     

end
function GameResultLayer:hideGameResult( )
	--self:reSet()
	self:setVisible(false)
end

function GameResultLayer:showGameResult(selfscore, bankerscore, bankername, bbanker,  UserWinMaxScore,wUserChairID,nMaxUserCount,AllWin ,tabGameResult)
	self.m_selfscore = selfscore
	self.m_bankerscore = bankerscore
	self.m_bbanker = bbanker
	self.m_selfname = "自 己"
	self.m_bankername = "庄 家"
    self.m_bankername = bankername
    self.m_wUserChairID = wUserChairID
    self.m_tabGameResult =tabGameResult
    self.m_AllWin = AllWin
      self.m_UserWinMaxScore = UserWinMaxScore
       self.m_MaxUserCount = nMaxUserCount
	self:setVisible(true)
  
	if selfscore >= 0   then
		self:showGameWin()
	else
		self:showGameFailed()
	end
end
function GameResultLayer:onButtonClickedEvent( tag, sender )
	g_ExternalFun.playClickEffect()
	if GameResultLayer.BT_CLOSE == tag then
		self:setVisible(false)
	end
end

function GameResultLayer:showGameWin()
	if nil == self.m_winNode then
		self:initWinLayer()
	end
	if nil  ~= self.m_failedNode then
		self.m_failedNode:setVisible(false)
		self.m_failedNode:stopAllActions()
	end
	local  layout_bg = self.m_winNode:getChildByName("layout_bg")
	local Image_TongSha = layout_bg:getChildByName("Image_TongSha")
    Image_TongSha:setVisible(false)
    if self.m_AllWin then
		Image_TongSha:setVisible(true)
    end
	local  Panel_1 = self.m_winNode:getChildByName("Panel_1")
	local pname2 = Panel_1:getChildByName("Text_Name")
	self.m_winSelfName = pname2

	local Panel_3 = self.m_winNode:getChildByName("Panel_3")
	local Panel_Card1 = Panel_3:getChildByName("Panel_Card1")
	local Panel_Card2 = Panel_3:getChildByName("Panel_Card2")
   
	local CardPanelArray={Panel_Card1,Panel_Card2}
         
     
	idleCards=self.m_tabGameResult.idleCards
	masterCards=	self.m_tabGameResult.masterCards

	local CardsArray={idleCards,masterCards}
   

	local CardsArrayPoint={self.m_tabGameResult.m_cbIdlePoint,self.m_tabGameResult.m_cbMasterPoint}

	for index=1,2  do

		local point = CardsArrayPoint[index]
		local str = string.format("ui/txt/hlssm_txt_js_%d.png", point)
		--[[local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)
		if nil ~= frame then
			self.m_tabPoint[dir]:setSpriteFrame(frame)
		end]]
		local Image_Type = CardPanelArray[index]:getChildByName("Image_Type")
		if Image_Type then
			Image_Type:loadTexture(str)
            Image_Type:setLocalZOrder(100)
		end
		local Panel_Card = CardPanelArray[index]:getChildByName("Panel_Card")
      
       	Panel_Card:removeAllChildren()
		for i=1,#CardsArray[index]  do
			local Cardsprite = CardSprite:createCard(5)    
          	Cardsprite:addTo(Panel_Card)
          	Cardsprite:setTag(2000+i)
          	Cardsprite:setScale(0.5)
          	Cardsprite:setCardValue(CardsArray[index][i])
          	Cardsprite:setPosition(cc.p(20+(i-1)*30+80,30))
        end
	end
     
      
   
     
	self.m_winNode:setVisible(true)

	self.m_winNode:stopAllActions()

   
--	self.m_winAction:gotoFrameAndPlay(0, false)
	--self.m_winNode:runAction(self.m_winAction)

	local winstr = "/"..self.m_selfscore
--	self.m_winScore:setString(winstr)

	self.m_winBankerName:setString(self.m_bankername)
	local bankerstr = g_ExternalFun.numberThousands(self.m_bankerscore)
	if self.m_bankerscore > 0 then
		bankerstr = "+"..bankerstr
    elseif  self.m_bankerscore <0 then
        bankerstr = "-"..bankerstr
	end
--	self.m_winBankerScore:setString(bankerstr)

   	local useritem1 = self.m_parent:getMeUserItem()
   	self.m_selfname = useritem1.szNickName
	self.m_winSelfName:setString(self.m_selfname)
	local scorestr = g_ExternalFun.numberThousands(self.m_selfscore)
	if self.m_selfscore > 0 then
		scorestr = "+"..scorestr
	elseif  self.m_selfscore <0 then
        scorestr = "-"..scorestr
	end

	local Panel_1 = self.m_winNode:getChildByName("Panel_1")
	local Text_Score = Panel_1:getChildByName("Text_Score")
    local Text_ScoreFail = Panel_1:getChildByName("Text_ScoreFail")
    
    if self.m_selfscore>=0 then
		Text_Score:setString(scorestr)
		Text_ScoreFail:setVisible(false)
		Text_Score:setVisible(true)
    else
		Text_ScoreFail:setVisible(true)
		Text_ScoreFail:setString(scorestr)
		Text_Score:setVisible(false)
    end
  

    local Image_Score = Panel_1:getChildByName("Image_Score")
   
    if self.m_selfscore==0 then
        Image_Score:setVisible(true)
        Text_Score:setVisible(false)
    else
        Image_Score:setVisible(false)
        Text_Score:setVisible(true)
    end
 
 
        --local Text_Name = Panel_1:getChildByName("Text_Name")
  --  Text_Name:setString(scorestr)
    

    --local CardArray = self.m_parent:getCardValue(1)

     
    local Panel_2 = self.m_winNode:getChildByName("Panel_2")
	local Panel_Card = Panel_2:getChildByName("Panel_Card")
    --Panel_Card:setVisible(false)

	local niuvalue = GameLogic:GetCardType(CardArray, 5)

	local Image_Type = Panel_Card:getChildByName("Image_Type")

	local Text_Score = Panel_Card:getChildByName("Text_Score")


	local Text_ScoreFail = Panel_Card:getChildByName("Text_ScoreFail")
    
    if self.m_bankerscore>=0 then
          Text_Score:setString(scorestr)
          Text_ScoreFail:setVisible(false)
          Text_Score:setVisible(true)
    else
         Text_ScoreFail:setVisible(true)
          Text_ScoreFail:setString(scorestr)
          Text_Score:setVisible(false)
    end
 

     


    

     
	if self.m_bankerscore >= 0 then
		self.m_winBankerName:setTextColor(wincolor)
		--self.m_winBankerScore:setTextColor(wincolor)
		--self.m_winmaohao1:setTextColor(wincolor)
	else
		self.m_winBankerName:setTextColor(failedcolor)
		--self.m_winBankerScore:setTextColor(failedcolor)
		--self.m_winmaohao1:setTextColor(failedcolor)
	end

	if self.m_selfscore >= 0 then
		self.m_winSelfName:setTextColor(wincolor)
		--self.m_winSelfScore:setTextColor(wincolor)
		--self.m_winmaohao:setTextColor(wincolor)
	else
		self.m_winSelfName:setTextColor(failedcolor)
		--self.m_winSelfScore:setTextColor(failedcolor)
		--self.m_winmaohao:setTextColor(failedcolor)
	end

        
    local Panel_4_1 = self.m_winNode:getChildByName("Panel_4_1")
	local Panel_4_2 = self.m_winNode:getChildByName("Panel_4_2")
	local Panel_4_3 = self.m_winNode:getChildByName("Panel_4_3")
	local Panel_4_4 = self.m_winNode:getChildByName("Panel_4_4")
	local Panel_4_5 = self.m_winNode:getChildByName("Panel_4_5")
	local PanelArray={Panel_4_1,Panel_4_2,Panel_4_3,Panel_4_4,Panel_4_5}

	for i=1, 5  do
		local Text_Name = PanelArray[i]:getChildByName("Text_Name")
		local Text_Score = PanelArray[i]:getChildByName("Text_Score")
		Text_Score:setString( "")
                          
		Text_Name:setString("")

		PanelArray[i]:setVisible(false)
	end
     
	for i=1, #self.m_wUserChairID  do
		if i< self.m_MaxUserCount and i<5 then
			PanelArray[i]:setVisible(true)
			UserList= self.m_parent:getDataMgr():getChairUserList()
			local useritem = UserList[self.m_wUserChairID[i] + 1]
			if nil ~= useritem then
				local Text_Name = PanelArray[i]:getChildByName("Text_Name")
				local Text_Score = PanelArray[i]:getChildByName("Text_Score")

				local scorestr = g_ExternalFun.numberThousands(self.m_UserWinMaxScore[i])
				if self.m_UserWinMaxScore[i]> 0 then
					scorestr = "+"..scorestr
				end
				Text_Score:setString( scorestr)
				Text_Name:setString(  useritem.szNickName)
			end
         
		end
	end
	g_ExternalFun.playSoundEffect("WIN.mp3")
end

function GameResultLayer:showGameFailed()
	if nil == self.m_failedNode then
		self:initFailedLayer()
	end
	if nil  ~= self.m_winNode then
		self.m_winNode:setVisible(false)
		self.m_winNode:stopAllActions()
	end

	self.m_failedNode:setVisible(true)

	self.m_failedNode:stopAllActions()
	self.m_failedAction:gotoFrameAndPlay(0, false)
	self.m_failedNode:runAction(self.m_failedAction)

         local  layout_bg = self.m_failedNode:getChildByName("layout_bg")
	    local Image_TongSha = layout_bg:getChildByName("Image_TongSha")
    Image_TongSha:setVisible(false)
    if self.m_AllWin then
         Image_TongSha:setVisible(true)
    end
     local  Panel_1 = self.m_failedNode:getChildByName("Panel_1")
	local pname2 = Panel_1:getChildByName("Text_Name")
	self.m_winSelfName = pname2

  
     

 
     local Panel_3 = self.m_failedNode:getChildByName("Panel_3")
	 local Panel_Card1 = Panel_3:getChildByName("Panel_Card1")
     local Panel_Card2 = Panel_3:getChildByName("Panel_Card2")
   
     local CardPanelArray={Panel_Card1,Panel_Card2}
         
     
    	 idleCards=self.m_tabGameResult.idleCards
        masterCards=	self.m_tabGameResult.masterCards

         local CardsArray={idleCards,masterCards}
   

            local CardsArrayPoint={self.m_tabGameResult.m_cbIdlePoint,self.m_tabGameResult.m_cbMasterPoint}
             
            
       for index=1,2  do

       local point = CardsArrayPoint[index]
		local str = string.format("ui/txt/hlssm_txt_js_%d.png", point)
		--[[local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)
		if nil ~= frame then
			self.m_tabPoint[dir]:setSpriteFrame(frame)
		end]]
          local Image_Type = CardPanelArray[index]:getChildByName("Image_Type")
          

            
          if Image_Type then
            Image_Type:loadTexture(str)
            Image_Type:setLocalZOrder(100)
          end
           local Panel_Card = CardPanelArray[index]:getChildByName("Panel_Card")
      
       Panel_Card:removeAllChildren()
         for i=1,#CardsArray[index]  do
          local Cardsprite = CardSprite:createCard(5)    
          Cardsprite:addTo(Panel_Card)
          Cardsprite:setTag(2000+i)
          Cardsprite:setScale(0.5)
          Cardsprite:setCardValue(CardsArray[index][i])
          Cardsprite:setPosition(cc.p(20+(i-1)*30+80,30))
        end
     end
     
      
   
     
	self.m_failedNode:setVisible(true)

	self.m_failedNode:stopAllActions()

   
--	self.m_winAction:gotoFrameAndPlay(0, false)
	--self.m_winNode:runAction(self.m_winAction)

	local winstr = "/"..self.m_selfscore
--	self.m_winScore:setString(winstr)

	self.m_winBankerName:setString(self.m_bankername)
	local bankerstr = g_ExternalFun.numberThousands(self.m_bankerscore)
	if self.m_bankerscore > 0 then
		bankerstr = "+"..bankerstr
	end
--	self.m_winBankerScore:setString(bankerstr)

   local useritem1 = self.m_parent:getMeUserItem()
   self.m_selfname = useritem1.szNickName
	self.m_winSelfName:setString(self.m_selfname)
	local scorestr = g_ExternalFun.numberThousands(self.m_selfscore)
	if self.m_selfscore > 0 then
		scorestr = "+"..scorestr
	end

     local Panel_1 = self.m_failedNode:getChildByName("Panel_1")
	local Text_Score = Panel_1:getChildByName("Text_Score")
    Text_Score:setString(scorestr)

     local Text_ScoreFail = Panel_1:getChildByName("Text_ScoreFail")
    
    if self.m_selfscore>=0 then
          Text_Score:setString(scorestr)
          Text_ScoreFail:setVisible(false)
          Text_Score:setVisible(true)
    else
         Text_ScoreFail:setVisible(true)
          Text_ScoreFail:setString(scorestr)
          Text_Score:setVisible(false)
    end

    local Image_Score = Panel_1:getChildByName("Image_Score")
   
    if self.m_selfscore==0 then
        Image_Score:setVisible(true)
        Text_Score:setVisible(false)
    else

        Image_Score:setVisible(false)
        Text_Score:setVisible(true)
    end
 
 
        --local Text_Name = Panel_1:getChildByName("Text_Name")
  --  Text_Name:setString(scorestr)
    

    --local CardArray = self.m_parent:getCardValue(1)

     
    local Panel_2 = self.m_failedNode:getChildByName("Panel_2")
	local Panel_Card = Panel_2:getChildByName("Panel_Card")
   -- Panel_Card:setVisible(false)

     
 

     local niuvalue = GameLogic:GetCardType(CardArray, 5)

     local Image_Type = Panel_Card:getChildByName("Image_Type")

     local Text_Score = Panel_Card:getChildByName("Text_Score")

    local Text_ScoreFail = Panel_Card:getChildByName("Text_ScoreFail")
    
    if self.m_bankerscore>=0 then
          Text_Score:setString(scorestr)
          Text_ScoreFail:setVisible(false)
          Text_Score:setVisible(true)
    else
         Text_ScoreFail:setVisible(true)
          Text_ScoreFail:setString(scorestr)
          Text_Score:setVisible(false)
    end

     


    

     
	if self.m_bankerscore >= 0 then
		self.m_winBankerName:setTextColor(wincolor)
		--self.m_winBankerScore:setTextColor(wincolor)
		--self.m_winmaohao1:setTextColor(wincolor)
	else
		self.m_winBankerName:setTextColor(failedcolor)
		--self.m_winBankerScore:setTextColor(failedcolor)
		--self.m_winmaohao1:setTextColor(failedcolor)
	end

	if self.m_selfscore >= 0 then
		self.m_winSelfName:setTextColor(wincolor)
		--self.m_winSelfScore:setTextColor(wincolor)
		--self.m_winmaohao:setTextColor(wincolor)
	else
		self.m_winSelfName:setTextColor(failedcolor)
		--self.m_winSelfScore:setTextColor(failedcolor)
		--self.m_winmaohao:setTextColor(failedcolor)
	end

        
    local Panel_4_1 = self.m_failedNode:getChildByName("Panel_4_1")
     local Panel_4_2 = self.m_failedNode:getChildByName("Panel_4_2")
     local Panel_4_3 = self.m_failedNode:getChildByName("Panel_4_3")
     local Panel_4_4 = self.m_failedNode:getChildByName("Panel_4_4")
      local Panel_4_5 = self.m_failedNode:getChildByName("Panel_4_5")
     local PanelArray={Panel_4_1,Panel_4_2,Panel_4_3,Panel_4_4,Panel_4_5}

       for i=1, 5  do
            local Text_Name = PanelArray[i]:getChildByName("Text_Name")
                               local Text_Score = PanelArray[i]:getChildByName("Text_Score")
                               Text_Score:setString( "")
                          
                                Text_Name:setString("")

                                PanelArray[i]:setVisible(false)
              end
     
     for i=1, #self.m_wUserChairID  do
            if i< self.m_MaxUserCount and i<5 then

              PanelArray[i]:setVisible(true)
                      UserList= self.m_parent:getDataMgr():getChairUserList()
                  local useritem = UserList[self.m_wUserChairID[i] + 1]

                    if nil ~= useritem then

                         local Text_Name = PanelArray[i]:getChildByName("Text_Name")
                           local Text_Score = PanelArray[i]:getChildByName("Text_Score")

                           	local scorestr = g_ExternalFun.numberThousands(self.m_UserWinMaxScore[i])
	                        if self.m_UserWinMaxScore[i]> 0 then
		                        scorestr = "+"..scorestr
	                        end
                           Text_Score:setString( scorestr)
                          
                            Text_Name:setString(  useritem.szNickName)
                    end
         
            end
      end


	g_ExternalFun.playSoundEffect("WIN.mp3")

end

function GameResultLayer:clear()
	if nil ~= self.m_failedNode then
		self.m_failedNode:stopAllActions()
		self.m_failedAction:release()
        self.m_failedAction=nil
	end

	if nil ~= self.m_winNode then
		self.m_winNode:stopAllActions()
		self.m_winAction:release()
         self.m_winAction=nil
	end
end

return GameResultLayer