--
-- Author: zhong
-- Date: 2016-07-12 17:03:14
--
--路单界面
local module_pre = "game.yule.baccaratnew.src";

local g_var = g_ExternalFun.req_var;
local cmd = require(module_pre .. ".models.CMD_Game")
local ClipText =appdf.CLIENT_SRC .. "Tools.ClipText"
local WallBillnode = class("WallBillnode", cc.Layer)

function WallBillnode:ctor(viewparent)
	
	self.m_parent = viewparent

    local function onLayoutEvent( event )
		if event == "exit" then
			self:onExit();
        elseif event == "enterTransitionFinish" then
        	self:onEnterTransitionFinish();
        end
	end
	self:registerScriptHandler(onLayoutEvent);

	self.m_spRecord = {}
	for i = 1, 29 do
		self.m_spRecord[i] = {}
		for j = 1, 6 do
			self.m_spRecord[i][j] = nil
		end
	end

	self.m_spRecord2 = {}
	for i = 1, 14 do
		self.m_spRecord2[i] = {}
		for j = 1, 6 do
			self.m_spRecord2[i][j] = nil
		end
	end


    self.m_spRecord3 = {}
	for i = 1, 84 do
		self.m_spRecord3[i] = {}
        for j = 1, 2 do
			self.m_spRecord3[i][j] = nil
		end
	
	end
	--加载csb资源
	local csbNode = g_ExternalFun.loadCSB("game/luziNode.csb", self)

    local ScrollView_1 = csbNode:getChildByName("Image_Luzi"):getChildByName("ScrollView_1")
    self.m_ScrollViewLuDan =ScrollView_1 

      local ScrollView_2 = csbNode:getChildByName("Image_Luzi"):getChildByName("ScrollView_2")
    self.m_ScrollViewLuDan1 =ScrollView_2 

    self.m_ScrollViewLuDan1:setVisible(false)

    local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end	

      local Btn_luzi = csbNode:getChildByName("Image_Luzi"):getChildByName("Btn_luzi")
       Btn_luzi:setTag(1);
	Btn_luzi:addTouchEventListener(btnEvent);
       local Btn_paixin = csbNode:getChildByName("Image_Luzi"):getChildByName("Btn_paixin")
    Btn_paixin:setTag(2);
	Btn_paixin:addTouchEventListener(btnEvent);
   
end
function WallBillnode:onButtonClickedEvent(tag,ref)
	g_ExternalFun.playClickEffect()
	if tag ==1 then
         self.m_ScrollViewLuDan:setVisible(true )
        self.m_ScrollViewLuDan1:setVisible(false)
    end
    if tag ==2 then
       self.m_ScrollViewLuDan:setVisible(false)
        self.m_ScrollViewLuDan1:setVisible(true)
    end

end
function WallBillnode:onEnterTransitionFinish()
	self:registerTouch()
end

function WallBillnode:onExit()
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:removeEventListener(self.listener)
end

function WallBillnode:registerTouch(  )
	local function onTouchBegan( touch, event )
		return self:isVisible()
	end

	local function onTouchEnded( touch, event )
		local pos = touch:getLocation();
		--[[local m_spBg = self.m_spBg
        pos = m_spBg:convertToNodeSpace(pos)
        local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
        if false == cc.rectContainsPoint(rec, pos) then
            self:showLayer(false)
        end   ]]     
	end

--[[	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true)
	self.listener = listener;
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN );
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED );
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);]]
end

function WallBillnode:showLayer( var )
	self:setVisible(var)
end

function WallBillnode:reSet(  )

end

function WallBillnode:refreshWallBillList(  )
	if nil == self.m_parent then
		return
	end
	local mgr = self.m_parent:getDataMgr()
	self:reSet()
	self:refreshList()

	--统计数据
	local vec = mgr:getRecords()
	local nTotal = #vec
	local nXian = 0
	local nZhuang = 0
	local nPing = 0
	local nXianDouble = 0
	local nZhuangDouble = 0
	local nXianTian = 0
	local nZhuangTian = 0
	for i = 1, nTotal do
		local rec = vec[i]
		if cmd.AREA_XIAN == rec.m_cbGameResult then
			nXian = nXian + 1
		elseif cmd.AREA_PING == rec.m_cbGameResult then
			nPing = nPing + 1
		elseif cmd.AREA_ZHUANG == rec.m_cbGameResult then
			nZhuang = nZhuang + 1
		end

		if rec.m_pServerRecord.bBankerTwoPair then
			nZhuangDouble = nZhuangDouble + 1
		end

		if rec.m_pServerRecord.bPlayerTwoPair then
			nXianDouble = nXianDouble + 1
		end

		--if cmd.AREA_XIAN_TIAN == rec.m_pServerRecord.cbKingWinner then
		if rec.m_pServerRecord.cbBankerCount < rec.m_pServerRecord.cbPlayerCount and rec.m_pServerRecord.cbPlayerCount >= 8 then
			nXianTian = nXianTian + 1
		end

		--if cmd.AREA_ZHUANG_TIAN == rec.m_pServerRecord.cbKingWinner then
		if rec.m_pServerRecord.cbPlayerCount < rec.m_pServerRecord.cbBankerCount and rec.m_pServerRecord.cbBankerCount >= 8 then
			nZhuangTian = nZhuangTian + 1
		end
	end

	

	--self:showLayer(true)
end

function WallBillnode:refreshList(  )
	if nil == self.m_parent then
		return
	end	
	local mgr = self.m_parent:getDataMgr()
	local vec = mgr:getWallBills()
	local walllen = #vec
	self.m_nBeginIdx = 1
	if walllen > 29 then
		self.m_nBeginIdx = walllen - 28
	end

	local nCount = 1
	local str = ""
	for i = self.m_nBeginIdx, walllen do
		if nCount > 29 then
			break
		end
		local bill = vec[i]
		for j = 1, bill.m_cbIndex do
			--数量控制
			if j > 5 then
				break
			end

			str = ""
			if cmd.AREA_XIAN == bill.m_pRecords[j] then
				str = "game_ludan1_xian.png"
			elseif cmd.AREA_ZHUANG == bill.m_pRecords[j] then
				str = "game_ludan1_zhuang.png"
			elseif cmd.AREA_PING == bill.m_pRecords[j] then
				str = "game_ludan1_ping.png"
			end
			
		end

		if bill.m_bWinList then
			if cmd.AREA_XIAN == bill.m_pRecords[6] then
            	str = "game_ludan1_xian.png"
            elseif cmd.AREA_ZHUANG == bill.m_pRecords[6] then          
                str = "game_ludan1_zhuang.png"         
            elseif cmd.AREA_PING == bill.m_pRecords[6] then      
                str = "game_ludan1_ping.png"
            end

            
		end

		nCount = nCount + 1
	end

	local vec2 = mgr:getRecords()
	nCount = 1
	local subCount = 1
	local nBegin = 1
	local len = #vec2
	if len > 84 then
		nBegin = len - 83
	end
    local ItemCount = len-nBegin
    self.m_ScrollViewLuDan:setInnerContainerSize(cc.size((len-nBegin)*30+20,92 ))
	for i = nBegin, len do
		

		local rec = vec2[i]
		str = ""
        local indexY = 0
		if cmd.AREA_XIAN == rec.m_cbGameResult then
			str = "ui/common/Hlssm_Battle_LSJL11.png"
            indexY =2
		elseif cmd.AREA_ZHUANG == rec.m_cbGameResult then
			str = "ui/common/Hlssm_Battle_LSJL13.png"
            indexY =0
		elseif cmd.AREA_PING == rec.m_cbGameResult then
			str = "ui/common/Hlssm_Battle_LSJL12.png"
            indexY = 1
		end

	
       -- rec.m_pServerRecord.cbBankerCount 
       -- rec.m_pServerRecord.cbPlayerCount
        -- local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)
            --if nil ~= frame then
               if nil == self.m_spRecord3[subCount][1] then
					self.m_spRecord3[subCount][1] = cc.Sprite:create(str)
                    local str1 = "ui/common/hlssm_log_grid_left.png"
                   local cbBankerCount = g_var(ClipText):createClipText(cc.size(20,20),rec.m_pServerRecord.cbBankerCount );
                   local cbPlayerCount = g_var(ClipText):createClipText(cc.size(20,20),rec.m_pServerRecord.cbPlayerCount );
                    self.m_spRecord3[subCount][2]= cc.Sprite:create(str1)
					 self.m_ScrollViewLuDan:addChild(self.m_spRecord3[subCount][1])
                      self.m_ScrollViewLuDan:addChild(self.m_spRecord3[subCount][2])
                      self.m_spRecord3[subCount][3] =cbBankerCount
                      self.m_spRecord3[subCount][4] = cbPlayerCount
                        self.m_spRecord3[subCount][5]= cc.Sprite:create(str1)
                       self.m_ScrollViewLuDan1:addChild(cbBankerCount)
                      self.m_ScrollViewLuDan1:addChild(cbPlayerCount)
                       self.m_ScrollViewLuDan1:addChild(self.m_spRecord3[subCount][5])
				else
					self.m_spRecord3[subCount][1]:setTexture(str)
                   
                   
				end
				local pos = cc.p(subCount*(30)-20, indexY*32+12)
				self.m_spRecord3[subCount][1]:setPosition(pos)
                local pos = cc.p((subCount-1)*(30)+10, 0*25+43)
                self.m_spRecord3[subCount][2]:setPosition(pos)

                  local pos = cc.p((subCount-1)*(30)+10, 0*25+43)
                self.m_spRecord3[subCount][5]:setPosition(pos)

                 local pos = cc.p((subCount-1)*(30)+5, 0*25+2)
                 self.m_spRecord3[subCount][3]:setPosition(pos)

                 local pos = cc.p((subCount-1)*(30)+5, 0*25+43+25)
                  self.m_spRecord3[subCount][4]:setPosition(pos)
                  self.m_spRecord3[subCount][3]:setVisible(true)
                  if rec.m_pServerRecord.cbBankerCount== rec.m_pServerRecord.cbPlayerCount then
                    self.m_spRecord3[subCount][3]:setVisible(false)

                    local pos = cc.p((subCount-1)*(30)+5, 0*25+43-6)
                  self.m_spRecord3[subCount][4]:setPosition(pos)
                  end
               
           --end
           subCount = subCount + 1
		
	end

    self.m_ScrollViewLuDan1:scrollToRight(0.2,true)
    self.m_ScrollViewLuDan:scrollToRight(0.2,true)
end
return WallBillnode