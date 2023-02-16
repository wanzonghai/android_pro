--
-- Author: zhong
-- Date: 2016-06-27 11:36:40
--

local GameLogic = appdf.req(appdf.GAME_SRC.."yule.baccaratnew.src.models.GameLogic")
local CardSprite = class("CardSprite", cc.Sprite);
local cmd = appdf.req(appdf.GAME_SRC.."yule.baccaratnew.src.models.CMD_Game")

--纹理宽高
local CARD_WIDTH = 158;
local CARD_HEIGHT = 208;
local BACK_Z_ORDER = 2;
local Game_CMD = appdf.req(appdf.GAME_SRC.."yule.baccaratnew.src.models.CMD_Game")
------
--set/get
function CardSprite:setDispatched( var )
	self.m_bDispatched = var;
end

function CardSprite:getDispatched(  )
	if nil ~= self.m_bDispatched then
		return self.m_bDispatched;
	end
	return false;
end
------

function CardSprite:ctor()
	self.m_cardData = 0
	self.m_cardValue = 0
	self.m_cardColor = 0
   -- display.loadSpriteFrames(cmd.RES_PATH.."game_res/plist_puke.plist",cmd.RES_PATH.."game_res/plist_puke.png")

   	local csbNode = g_ExternalFun.loadCSB("game/CardNode.csb", self)
    self.m_CardNode = csbNode
    local  plist_puke_front_big = csbNode:getChildByName("plist_puke_front_big")
    
    self.m_plist_puke_value =  plist_puke_front_big:getChildByName("plist_puke_value")
    self.m_plist_puke_color_small =  plist_puke_front_big:getChildByName("plist_puke_color_small")
    self.m_plist_puke_color_big =  plist_puke_front_big:getChildByName("plist_puke_color_big")
   
   --self.m_CardNode:setScale(0.65)
   -- cc.SpriteFrameCache:getInstance():addSpriteFrames(cmd.RES_PATH.."game_res/plist_puke.plist")
end

--创建卡牌
function CardSprite:createCard( cbCardData )
	local sp = CardSprite:create();
	--sp.m_strCardFile = "im_card.png";
--	local tex = cc.Director:getInstance():getTextureCache():getTextureForKey(sp.m_strCardFile);
--and nil ~= tex and sp:initWithTexture(tex, tex:getContentSize())
	if nil ~= sp  then
        sp:setTexture("card/plist_puke_front_big.png")
		sp.m_cardData = cbCardData;
	sp.m_cardValue = ylAll.POKER_VALUE[cbCardData] --math.mod(cbCardData, 16) --bit:_and(cbCardData, 0x0F)
	sp.m_cardColor = ylAll.CARD_COLOR[cbCardData] --math.floor(cbCardData / 16) --bit:_rshift(bit:_and(cbCardData, 0xF0), 4)
       
		sp:updateSprite();
		--扑克背面
		sp:createBack();
        sp:showCardBack(false)
		return sp;
	end
	return nil;
end
function CardSprite:getCardValue(  )
  return self.m_cardData  
end
--设置卡牌数值
function CardSprite:setCardValue( cbCardData )
	self.m_cardData = cbCardData;
	self.m_cardValue = ylAll.POKER_VALUE[cbCardData] --math.mod(cbCardData, 16) --bit:_and(cbCardData, 0x0F)
	self.m_cardColor = ylAll.CARD_COLOR[cbCardData] --math.floor(cbCardData / 16) --bit:_rshift(bit:_and(cbCardData, 0xF0), 4)
	
	self:updateSprite();
end
function CardSprite:getCardData()
    return self.m_cardData
end
function CardSprite:updateSprite2()

  if 0xffff == self.m_cardData then
    return
  end

  local m_cardData = self.m_cardData
  local m_cardValue = self.m_cardValue
  local m_cardColor = self.m_cardColor
  local c_width = self.m_nCardWidth
  local c_height = self.m_nCardHeight
  
 
 -- local str = string.format("plist_puke_value_%d_%d.png", m_cardColor,m_cardValue)
 -- str="plist_puke_value_0_2.png"
 -- local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("plist_puke_front_big.png")

    --  local m_spBack = cc.Sprite:createWithSpriteFrame(frame)
  -- local sprite = cc.Sprite:createWithSpriteFrame(cc.SpriteFrame:create("brnn_openCard_plist.png",cc.rect(538,1219,135,57)))
    local rect = cc.rect((m_cardValue - 1) * CARD_WIDTH, m_cardColor * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
	if 0 ~= m_cardData then
		rect = cc.rect((m_cardValue - 1) * CARD_WIDTH, m_cardColor * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
		if 0x42 == m_cardData then
			rect = cc.rect(0, 4 * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
		elseif 0x41 == m_cardData then
			rect = cc.rect(CARD_WIDTH, 4 * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
		end
	else
		--使用背面纹理区域
		rect = cc.rect(2 * CARD_WIDTH, 4 * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
	end
	--self:setTextureRect(rect);

    if m_cardValue>0 and false  then

     --self.m_spValue:setSpriteFrame(frame)
     --self.m_spValue:setVisible(true)
   --  self:setSpriteFrame(frame)
    end


end
--更新纹理资源
function CardSprite:updateSprite(  )
	local m_cardData = self.m_cardData;
	local m_cardValue = self.m_cardValue;
	local m_cardColor = self.m_cardColor;

   
    
        	local cardSize = self:getContentSize();
     self.m_CardNode:setPosition(cardSize.width * 0.5-2, cardSize.height * 0.5);
     
       --self.m_plist_puke_value =  csbNode:getChildByName("plist_puke_value")
      --  self.m_plist_puke_color_small =  csbNode:getChildByName("plist_puke_color_small")
       -- self.m_plist_puke_color_big =  csbNode:getChildByName("plist_puke_color_big")
       if self.m_cardData ==0 or self.m_plist_puke_value==nil then
        return
       end
       cardColor =1
     if self.m_cardColor==1 or self.m_cardColor==3 then
            cardColor =0
        end
         --0x41,0x42,
         if cardColor==0 then
            self.m_plist_puke_value:setTexture(string.format("card/plist_puke_value_1_%d.png",self.m_cardValue))
         else
            self.m_plist_puke_value:setTexture(string.format("card/plist_puke_value_0_%d.png",self.m_cardValue))
         end
         self.m_plist_puke_color_small:setTexture(string.format("card/plist_puke_color_xl_small_%d.png",self.m_cardColor))

        self.m_plist_puke_color_big:setTexture(string.format("card/plist_puke_color_xl_big_%d.png",self.m_cardColor))
	--rect = cc.rect(CARD_WIDTH, 4 * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
--self:setTextureRect(rect)
	--[[self:setTag(m_cardData);

	local rect = cc.rect((m_cardValue - 1) * CARD_WIDTH, m_cardColor * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
	if 0 ~= m_cardData then
		rect = cc.rect((m_cardValue - 1) * CARD_WIDTH, m_cardColor * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
		if 0x42 == m_cardData then
			rect = cc.rect(0, 4 * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
		elseif 0x41 == m_cardData then
			rect = cc.rect(CARD_WIDTH, 4 * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
		end
	else
		--使用背面纹理区域
		rect = cc.rect(2 * CARD_WIDTH, 4 * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);
	end
	self:setTextureRect(rect);]]
end

--显示扑克背面
function CardSprite:showCardBack( var )

if self.m_cardValue==nil then
    var = true
end
	if nil ~= self.m_spBack then
		self.m_spBack:setVisible(var);
        if var then

             self.m_CardNode:setVisible(false)
        else
          self.m_CardNode:setVisible(true)
        end
	end	
end

--创建背面
function CardSprite:createBack(  )
	--local tex = cc.Director:getInstance():getTextureCache():getTextureForKey(self.m_strCardFile);
	--纹理区域
	local rect = cc.rect(2 * CARD_WIDTH, 4 * CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT);

	local cardSize = self:getContentSize();
  --  local m_spBack = cc.Sprite:createWithTexture(tex, rect);
     local m_spBack = cc.Sprite:create("card/plist_puke_back_big_2.png")
    cardSize = m_spBack:getContentSize();
    	--local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("plist_puke_value_xl_0_13.png")

      --local m_spBack = cc.Sprite:createWithSpriteFrame(frame)

    m_spBack:setPosition(cardSize.width * 0.5, cardSize.height * 0.5);
    m_spBack:setVisible(false);
   --  m_spBack:setScale(0.65)
    self:addChild(m_spBack);
    m_spBack:setLocalZOrder(BACK_Z_ORDER);
    self.m_spBack = m_spBack;
    self.m_CardNode:setPosition(cardSize.width * 0.5-2, cardSize.height * 0.5);
    -- str="plist_puke_value_0_2.png"
  -- local sprite = cc.Sprite:createWithSpriteFrame(cc.SpriteFrame:create("brnn_openCard_plist.png",cc.rect(538,1219,135,57)))
    
    

     -- self.m_spBack:setSpriteFrame(str)

    -- local m_spValue = cc.Sprite:createWithTexture(tex, rect);
   -- m_spValue:setPosition(cardSize.width * 0.5, cardSize.height * 0.5);
   -- m_spValue:setVisible(false);
    --self:addChild(m_spValue);
   -- m_spValue:setLocalZOrder(BACK_Z_ORDER);
    --self.m_spValue = m_spValue;
end

return CardSprite;