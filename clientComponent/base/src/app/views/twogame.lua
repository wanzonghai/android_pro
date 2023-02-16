local res = "base/res/twogame/"

local cardSpName = {
    "card1.png","card2.png","card3.png","card4.png","card5.png","card6.png",
    "card7.png","card8.png","card9.png","card10.png","card11.png","card12.png",
    "card13.png","card14.png","card15.png","card16.png","card17.png","card18.png",
    "card19.png","card20.png","card21.png","card22.png","card23.png","card24.png",
}

local twogame = class("twogame",function(args)
    local twogame =  display.newLayer()
    return twogame
end)

function twogame:ctor(scene)
    self._scene = scene
    local csbNode = cc.CSLoader:createNode("twogameScene.csb")
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)    
    self._scene:addChild(csbNode)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(res .. "poker.plist",res .. "poker.png")
    local bt_back = csbNode:getChildByName("bt_back")
    bt_back:addClickEventListener(handler(self,self.backclick))

    self.myScore = csbNode:getChildByName("user2"):getChildByName("score")
    self.otherScore = csbNode:getChildByName("user1"):getChildByName("score")
    self.myScore:setString(0)
    self.otherScore:setString(0)
    self.pokerlayer = csbNode:getChildByName("pokerlayer")
    self.startPosNode = self.pokerlayer:getChildByName("node1")
    self.myPosNode = self.pokerlayer:getChildByName("node3")
    self.otherPosNode = self.pokerlayer:getChildByName("node2")
    self.wanNode = self.pokerlayer:getChildByName("node4")
    self.tip1 = csbNode:getChildByName("user1"):getChildByName("tip")
    self.tip2 = csbNode:getChildByName("user2"):getChildByName("tip")
    self.wanNode:setVisible(false)

    self.bt_start = csbNode:getChildByName("bt_start")
    self.bt_start:addClickEventListener(handler(self,self.startclick))
    self.bt_start:setVisible(false)

    self.bt_send = csbNode:getChildByName("bt_send") 
    self.bt_send:addClickEventListener(handler(self,self.sendclick))
    self.bt_send:setVisible(false)

    self.bt_give = csbNode:getChildByName("bt_give")
    self.bt_give:addClickEventListener(handler(self,self.giveupclick))
    self.bt_give:setVisible(false)

    self.score1 = 0
    self.score2 = 0
    self.curCard = nil
    self:initCard()
end

function twogame:gameOver()
    if self.score1 == 18 or self.score1 == -18 then
        self.score1 = 0 
        self.score2 = 0 
        self.myScore:setString(self.score1)
        self.otherScore:setString(self.score2)
        for i,v in ipairs(self.cards) do
            v:removeFromParent()
        end
        self.wanNode:setVisible(false)
        self.bt_send:setVisible(false)
        self.bt_give:setVisible(false)
        self:initCard()
    end
end

function twogame:giveupclick()
    if self.curCard then
        self.bt_send:setVisible(false)
        self.bt_give:setVisible(false)
        self.cardsNum = self.cardsNum - 1
        self.score1 = self.score1 - 2
        self.score2 = self.score2 + 2
        self.tip1:setVisible(true)
        self.tip1:runAction(cc.Sequence:create(cc.Blink:create(2,5),
        cc.CallFunc:create(function()
            self.myScore:setString(self.score1)
            self.otherScore:setString(self.score2)
            self.tip1:setVisible(false)
            if self.cardsNum ~= 0 then
                self.bt_send:setVisible(true)
                self.bt_give:setVisible(true)
            end
            self:gameOver()
        end)))
        self.curCard:setVisible(false)
        self.curCard = nil

        if self.cardsNum == 0 then
            self.bt_send:setVisible(false)
            self.bt_give:setVisible(false)
            for i,v in ipairs(self.otherCards) do
                v:removeFromParent()
            end
            self:initCard()
        end
    end
end

function twogame:sendclick()
    local tag1 = 0
    local tag2card = nil
    if self.curCard then
        self.cardsNum = self.cardsNum - 1
        self.bt_send:setVisible(false)
        self.bt_give:setVisible(false)
        for i,v in ipairs(self.myCards) do
            v:setEnabled(false)
        end

        tag1 = self.curCard:getTag()
        self.curCard:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.3,cc.p(cc.Director:getInstance():getWinSize().width/2 + 150,self.curCard:getPositionY())),
            cc.ScaleTo:create(0,0.85)
        ))

        local time = math.random(1, 5)
        print("======time:",time)
        performWithDelay(self,function()  
            tag2card = self.otherCards[self.cardsNum+1]
            tag2card:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.3,cc.p(cc.Director:getInstance():getWinSize().width/2 + 150,tag2card:getPositionY())),
                cc.ScaleTo:create(0,0.85),
                cc.CallFunc:create(function()
                    tag2card:loadTextures(cardSpName[tag2card:getTag()],cardSpName[tag2card:getTag()],cardSpName[tag2card:getTag()],UI_TEX_TYPE_PLIST)
                end)
            ))
            
        end,time)

        performWithDelay(self,function()  
            local isWin = 0
            local num1= tag2card:getTag()%6
            local num2= self.curCard:getTag()%6
            if num1 == 0 then num1 = 6 end 
            if num2 == 0 then num2 = 6 end
            print("======num1:",num1,num2)
            if num1 == self.max or num2 == self.max then
                if num1 ~= self.max then
                    isWin = 1
                elseif num2 ~= self.max then
                    isWin = -1
                else
                    if tag2card:getTag() < self.curCard:getTag() then
                        isWin = 1
                    else
                        isWin = -1
                    end
                end
            else
                if num1 > num2 then
                    isWin = -1
                elseif num1 == num2 then
                    isWin = 0
                else
                    isWin = 1
                end
            end
            print("=======isWin:",isWin)
            if isWin == 1 then
                self.score1 = self.score1 + 3
                self.score2 = self.score2 - 3
                self.tip2:setVisible(true)
                self.tip2:runAction(cc.Sequence:create(cc.Blink:create(2,5),
                cc.CallFunc:create(function()
                    self.myScore:setString(self.score1)
                    self.otherScore:setString(self.score2)
                    self.tip2:setVisible(false)
                end)))
            elseif isWin == 0 then
                self.tip2:setVisible(true)
                self.tip2:runAction(cc.Sequence:create(cc.Blink:create(2,5),
                cc.CallFunc:create(function()
                    self.tip2:setVisible(false)
                end)))   
                self.tip1:setVisible(true)
                self.tip1:runAction(cc.Sequence:create(cc.Blink:create(2,5),
                cc.CallFunc:create(function()
                    self.tip1:setVisible(false)
                end)))
            else
                self.score1 = self.score1 - 3
                self.score2 = self.score2 + 3
                self.tip1:setVisible(true)
                self.tip1:runAction(cc.Sequence:create(cc.Blink:create(2,5),
                cc.CallFunc:create(function()
                    self.myScore:setString(self.score1)
                    self.otherScore:setString(self.score2)
                    self.tip1:setVisible(false)
                end)))
            end
        end,time + 0.5)

        performWithDelay(self,function ()
            if self.cardsNum == 0 then
                self.curCard:setVisible(false)
                tag2card:setVisible(false)
                self.wanNode:setVisible(false)
                self.wanCard:setVisible(false)
                self.bt_send:setVisible(false)
                self.bt_give:setVisible(false)
                if self.score1 == 18 or self.score1 == -18 then
                    self:gameOver()
                else
                    self:initCard()
                end
            else
                self.bt_send:setVisible(true)
                self.bt_give:setVisible(true)
                self.curCard:setVisible(false)
                tag2card:setVisible(false)
                for i,v in ipairs(self.myCards) do
                    v:setEnabled(true)
                end
                self:gameOver()
            end
            self.curCard = nil
        end,time + 3)
    end
end

function twogame:startclick()
    self.bt_start:setVisible(false)
    self:cardMove()
end

function twogame:cardMove()
    self.otherCards = {}
    self.myCards = {}
    local posX = self.myPosNode:getPositionX()
    local posY = self.myPosNode:getPositionY()
    self.wanNode:setVisible(true)
    for i=1,3 do
        for j=1,2 do
            local card = self.cards[(i-1)*2 + j]
            if j == 2 then 
                posY = self.myPosNode:getPositionY()
                table.insert(self.myCards,card)
            else
                posY = self.otherPosNode:getPositionY()
                table.insert(self.otherCards,card)
            end
            card:runAction(cc.Sequence:create(
                cc.DelayTime:create(i*0.1),
                cc.MoveTo:create(0.5,cc.p(posX,posY + (i-1) * 98))
            ))
            card:runAction(cc.Sequence:create(
                cc.DelayTime:create(2),
                cc.CallFunc:create(function()
                    if j == 2 then
                        print("=========res:",res .. cardSpName[card:getTag()])
                        card:loadTextures(cardSpName[card:getTag()],cardSpName[card:getTag()],cardSpName[card:getTag()],UI_TEX_TYPE_PLIST)
                        card:setEnabled(true)
                    end
                end)
            ))
            print("========tag:",card:getTag())
        end
    end
    self.wanCard = self.cards[7]
    self.wanCard:runAction(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.MoveTo:create(0.5,cc.p(self.wanNode:getPositionX(),self.wanNode:getPositionY())),
        cc.CallFunc:create(function()
            self.wanCard:loadTextures(cardSpName[self.wanCard:getTag()],cardSpName[self.wanCard:getTag()],cardSpName[self.wanCard:getTag()],UI_TEX_TYPE_PLIST)
        end)
    ))

    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(2.5),
        cc.CallFunc:create(function()
            self.bt_send:setVisible(true)
            self.bt_give:setVisible(true)
        end)
    ))
    print("===========self.wanCard:",self.wanCard:getTag())
    local xu = {1,2,3,4,5,6}
    local max = 6
    for i,v in ipairs(xu) do
        if self.wanCard:getTag()%6 == 0 then
            max = 1
        end
        if v == self.wanCard:getTag()%6 then
            print("===========v:",v)
            max = v + 1
        end
    end
    print("========max:",max)
    table.remove( xu, max )
    dump(xu,"===1")
    table.insert( xu, max )
    dump(xu,"===2")
    self.xu = xu
    self.max =max
end

function twogame:initCard()
    self.cards = {}
    self.cardsNum = 3
    local testrand = self:getrandom(24)
    print("=======testrand:",testrand)
    dump(testrand)
    for i=1,24 do
        local cardBt = ccui.Button:create("card0.png","card0.png","card0.png",UI_TEX_TYPE_PLIST)
        cardBt:setPosition(self.startPosNode:getPosition())
        cardBt:setTag(testrand[i])
        cardBt:setRotation(270)
        self.pokerlayer:addChild(cardBt,100 + 54 - i)
        cardBt:setEnabled(false)
        cardBt:addTouchEventListener(function(sender,type)
            if type == ccui.TouchEventType.ended then
                print("==========clickadd:",sender:getTag())
                sender:setScale(1.15)
                self.curCard = sender
            elseif type == ccui.TouchEventType.canceled then
                sender:setScale(1)
            elseif type == ccui.TouchEventType.began then
                for i,v in ipairs(self.myCards) do
                    v:setScale(1)
                end
            end
        end)
        table.insert(self.cards, cardBt)
    end
    performWithDelay(self,function()
        self.bt_start:setVisible(true)
    end,0.5)
end

function twogame:getrandom(nMax)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	local tab = {}
	local tabFin = {}
	local Rand
	for i=1,nMax do
		table.insert(tab,i)
	end
	for i=1,table.getn(tab) do
		Rand = math.random(table.getn(tab))
		while tab[Rand] == nil do
			Rand = math.random(table.getn(tab))
		end
		table.insert(tabFin,tab[Rand])
		table.remove(tab,Rand)
	end
	return tabFin
end

function twogame:refrshScore()
    
end

function twogame:backclick()
    print("============backclick")
    os.exit()
end

return twogame