--[[
    下注盘节点
]]


local sounds = appdf.req("game.yule.miniRoulette.src.models.sounds")
local betAreaLayer = class("betAreaLayer")
local touchMoveAbs = 5
local clipOffset = 240


--原点 格子的左下角
local origin = {x = 352.5,y = 264}
--数字rect
local numRect = {x = 356,y = 418,width = 1208,height = 298}

--2个数配置  key 是投注双数的和
--b.双数投注组合为 “2,4” “4,6” “6,8” “8,10” "10,12" "1,2" "3,4" "5,6" "7,8" "9,10" "11,12" "1,3" "3,5" "5,7" "7,9" "9,11"共16种双数组合押注
local twoBetConfig = {
    [6]  = 0,
    [10] = 1,
    [14] = 2,
    [18] = 3,
    [22] = 4,
    [3]  = 5,
    [7]  = 6,
    [11] = 7,
    [15] = 8,
    [19] = 9,
    [23] = 10,
    [4]  = 11,
    [8]  = 12,
    [12] = 13,
    [16] = 14,
    [20] = 15,
}

--4个数配置 key是投注4个数的和
local fourBetConfig = {
    [10] = 0,
    [18] = 1,
    [26] = 2,
    [34] = 3,
    [42] = 4,
}

-- 6个数配置
local otherBetConfig = {
    [13] = 0,
    [14] = 1,
    [15] = 2,
    [16] = 3,
    [17] = 4,
    [18] = 5,
}

local effectConfig = {
    [13] = {1,2,3,4,5,6},            --1~6
    [14] = {1,3,5,7,9,11},           --奇数
    [15] = {2,4,6,7,9,11},           --黑色
    [16] = {1,3,5,8,10,12},          --红色
    [17] = {2,4,6,8,10,12},          --偶数
    [18] = {7,8,9,10,11,12}          --7~12
}
--local band =  bit._and(cbCardData,0xF0);
--local Alist = bit._lshift(0x01,iOldType);
-- | 或操作 bit.bor(flag,mask)
--nList = bit._or(nList,bit._lshift(0x01,iNewType));

local areaConfig = {
    [0] = {[0] = {1},[1] = {2},[2] = {3},[3] = {4},[4] = {5},[5] = {6},[6] = {7},[7] = {8},[8] = {9},[9] = {10},[10] = {11},[11] = {12}},
    [1] = {
        [0]  = {2,4},[1]  = {4,6},[2]  = {6,8},[3]  = {8,10},[4] = {10,12},
        [5]  = {1,2},[6]  = {3,4},[7]  = {5,6},[8]  = {7,8}, [9] = {9,10},[10] = {11,12},
        [11] = {1,3},[12] = {3,5},[13] = {5,7},[14] = {7,9},[15] = {9,11},
    },
    [2] = {
        [0] = {1,2,3,4},[1] = {3,4,5,6},[2] = {5,6,7,8},[3] = {7,8,9,10},[4] = {9,10,11,12}
    },
    [3] = {
        [0] = {1,2,3,4,5,6},     --1~6
        [1] = {1,3,5,7,9,11},    --奇数
        [2] = {2,4,6,7,9,11},    --黑色
        [3] = {1,3,5,8,10,12},   --红色
        [4] = {2,4,6,8,10,12},   --偶数
        [5] = {7,8,9,10,11,12}   --7~12
    },
}

function betAreaLayer:onExit()
    
end

function betAreaLayer:ctor(pNode)
    self.m_rootNode = pNode 
    local _touchListener = cc.EventListenerTouchOneByOne:create();
    _touchListener:registerScriptHandler(handler(self,self.onTouchBegan),cc.Handler.EVENT_TOUCH_BEGAN);
    _touchListener:registerScriptHandler(handler(self,self.onTouchMoved),cc.Handler.EVENT_TOUCH_MOVED);
    _touchListener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED);
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(_touchListener,self.mm_Image_betArea);

    self:initData()
    self:ClipHead()
    --每个触摸块的包围框
    self.m_rectBox = {}
    for i=1,18 do
        local box = self["mm_PanelTouch_"..i]:getBoundingBox()
        self.m_rectBox[i] = cc.rect(box.x + origin.x,box.y + origin.y,box.width,box.height)
    end

end

function betAreaLayer:initData()
    self.m_contentSize = self.mm_Image_betArea:getContentSize()
    self.m_contentPos = cc.p(self.mm_Image_betArea:getPosition())
    self.m_layerSize = self:getContentSize()
    --偏移值 中间下注方块不是在中心位置
    self.m_offset_y = self.m_contentPos.y - self.m_layerSize.height/2
    self.m_offset_x = self.m_contentPos.x - self.m_layerSize.width/2
    -- 差值  layer 和 中间方块的 size 差值
    self.m_tempw = (self.m_layerSize.width - self.m_contentSize.width)/2
    self.m_temph = (self.m_layerSize.height - self.m_contentSize.height)/2 + self.m_offset_y

    self.m_chipNodeArray = {}     --下注筹码数组
    self.m_chipNodePool = {}      --筹码池子
    local chipImgPath = "res/GUI/chip/roulette_cm1.png"
    for i=1,500 do
        local chip = cc.Sprite:create(chipImgPath)
        chip:setPosition(cc.p(0,0))
        chip:setScale(0.4)
        chip:setVisible(false)
        self.mm_Panel_chipRoot:addChild(chip)
    end
    self.m_betPosConfig = self:getBetPosConfig()
    self.m_isTouch = false  --是否不能下注
    self.m_toTime = 0.01
    self.m_recycleTime = 0.2
end

--创建放大镜裁剪
function betAreaLayer:ClipHead()	
    local pPathHead = "res/GUI/table/roulette_yzq.png"
    local pPathClip = "res/GUI/user/roulette_txk1.png"
	local clipSp = cc.Sprite:create(pPathClip)	
	if nil ~= clipSp then
	
		self.mm_spRender = cc.Sprite:create(pPathHead)
		if not self.mm_spRender then return end
		self.mm_spRender:setContentSize(self.m_contentSize)
		--裁剪
		self.m_clip = cc.ClippingNode:create()
		self.m_clip:setStencil(clipSp)
		self.m_clip:setAlphaThreshold(0.05)
		self.m_clip:addChild(self.mm_spRender)
		self.m_clip:setContentSize(self.m_contentSize)
		self.m_clip:setPosition(cc.p(self.m_contentSize.width * 0.5, self.m_contentSize.height * 0.5))
        self.m_clip:setScale(2)
		self.mm_Panel_touch:addChild(self.m_clip)
        self.m_clip:hide()
        local p = cc.Sprite:create("res/GUI/table/img_content.png")
        p:setScale(0.5)
        self.m_clip:addChild(p)
	end
end

function betAreaLayer:onTouchBegan( touch,event )
    if touch:getId() > 0 then return end
    if self.m_isTouch then return end
    
    --层上触摸位置
    self.m_touchBegan = self:convertToNodeSpace(touch:getLocation())
    local box = self.mm_Image_betArea:getBoundingBox()
    local rect = cc.rect(box.x,box.y,box.width,box.height)  --
    if cc.rectContainsPoint(rect, self.m_touchBegan) then
        print(self.m_touchBegan.x,self.m_touchBegan.y)
        for i=1,18 do
            if cc.rectContainsPoint(self.m_rectBox[i],self.m_touchBegan) then
                self["mm_ImageEffect_"..i]:show()
                if i >=13 then
                    for k,v in pairs(effectConfig[i]) do
                        self["mm_ImageEffect_"..v]:show()
                    end
                end
            else
                self["mm_ImageEffect_"..i]:hide()
            end
        end
        return true
    end
end

function betAreaLayer:onTouchMoved( touch,event )
    self.m_touchMoved = self:convertToNodeSpace(touch:getLocation())
    --获取移动绝对值 
    local xAbs = math.abs(self.m_touchMoved.x - self.m_touchBegan.x)
    local yAbs = math.abs(self.m_touchMoved.y - self.m_touchBegan.y)
    if (xAbs > touchMoveAbs or yAbs > touchMoveAbs) and cc.rectContainsPoint(numRect,self.m_touchMoved) then
        self.m_clip:show()
        self.m_clip:setPosition(cc.p(self.m_touchMoved.x - self.m_tempw,self.m_touchMoved.y -self.m_temph + clipOffset))
        self.mm_spRender:setAnchorPoint(cc.p((self.m_touchMoved.x - self.m_tempw)/self.m_contentSize.width,(self.m_touchMoved.y - self.m_temph)/self.m_contentSize.height))
    else
        self.m_clip:hide()
    end

    for i=1,18 do
        if cc.rectContainsPoint(self.m_rectBox[i],self.m_touchMoved) then
            self["mm_ImageEffect_"..i]:show()
            if i >=13 then
                for k,v in pairs(effectConfig[i]) do
                    self["mm_ImageEffect_"..v]:show()
                end
            end
        else
            self["mm_ImageEffect_"..i]:hide()
        end
    end
end

function betAreaLayer:onTouchEnded( touch,event )
    -- self.m_touchEnd = self:convertToNodeSpace(touch:getLocation())
    self.m_clip:hide()
    local betArray = {}  --1~12 单数的投注

    local isOther = false  --除了1~12的区域
    for i=18,1,-1 do
        if self["mm_ImageEffect_"..i]:isVisible() then
            if i >= 13 then
                isOther = true
                table.insert( betArray, i )
            else
                if isOther == false then
                    table.insert( betArray, i )
                end
            end
            self["mm_ImageEffect_"..i]:hide()
        end
    end
 

    local betType,betArea = self:getBetArea(betArray)
        --cbBetType  1->单数    2->下2个数    3->下4个数       4->下6个数
    --cbBetArea  筹码区域
    self.m_rootNode:sendUserBet(betType,betArea)
    ccexp.AudioEngine:play2d(sounds.chip, false,self.m_rootNode.m_soundsVolume)
end
--是否能触摸  
function betAreaLayer:setIsTouch(isTouch)
    self.m_isTouch = isTouch or false
    if self.m_isTouch then
        self.mm_Panel_stopTouch:show()
    else
        self.mm_Panel_stopTouch:hide()
    end
end


--获取下注位置的配置
function betAreaLayer:getBetPosConfig()
    local betPosConfig = {
        [0] = {},
        [1] = {},
        [2] = {},
        [3] = {},
    }
    for i=1,18 do
        if i < 13 then
            betPosConfig[0][i-1] = cc.p(self["mm_ImageEffect_"..i]:getPosition())
        else
            local index = otherBetConfig[i]
            if index ~= nil then
                betPosConfig[3][index] = cc.p(self["mm_ImageEffect_"..i]:getPosition())
            end
        end

        if i > 1 then
            local betArray = {i-1,i}
            local index = twoBetConfig[i*2-1]
            if index ~= nil then
                betPosConfig[1][index] = self:getContentPos_2(betArray)
            end
            if i > 2 then
                local betArray = {i-2,i}
                local index = twoBetConfig[i*2-2]
                if index ~= nil then
                    betPosConfig[1][index] = self:getContentPos_2(betArray)
                end
            end
        end
        if i > 3 then
            local betArray = {i-3,i-2,i-1,i}
            local index = fourBetConfig[i*4-6]
            if index ~= nil then
                betPosConfig[2][index] = self:getContentPos_4(betArray)
            end
        end
    end

    return betPosConfig
end

--
function betAreaLayer:getContentPos_2(betArray)
    local contentPos = cc.p(0,0)
    local pos1 = cc.p(self["mm_ImageEffect_"..betArray[1]]:getPosition())
    local pos2 = cc.p(self["mm_ImageEffect_"..betArray[2]]:getPosition())
    local x = math.abs(pos2.x - pos1.x)
    local y = math.abs( pos2.y - pos1.y )
    contentPos.x = pos1.x + x/2
    contentPos.y = pos1.y + y/2
    return contentPos
end

function betAreaLayer:getContentPos_4(betArray)
    local contentPos = cc.p(0,0)
    local pos1 = cc.p(self["mm_ImageEffect_"..betArray[1]]:getPosition())
    local pos2 = cc.p(self["mm_ImageEffect_"..betArray[2]]:getPosition())
    local pos3 = cc.p(self["mm_ImageEffect_"..betArray[3]]:getPosition())
    local pos4 = cc.p(self["mm_ImageEffect_"..betArray[4]]:getPosition())
    local x = math.abs(pos3.x - pos1.x)
    local y = math.abs(pos2.y - pos1.y)
    contentPos.x = pos1.x + x/2
    contentPos.y = pos1.y + y/2
    return contentPos
end

--获取投注区域参数 
--betArea 区域传参说明：
--单数： 1 ~ 12                                      12个，  依次传：0~11      cbBetType类型 = 0
--双数： 1|2 ~ 11|12                                 16个，  依次传：0~15      cbBetType类型 = 1
--4个数：1|2|3|4 ~ 9|10|11|12                        5个，   依次传：0~4       cbBetType类型 = 2
--6个数：1-6, Odd(奇数), 红, 黑, Even(偶数), 7~12    6个，   依次传：0~5       cbBetType类型 = 3
function betAreaLayer:getBetArea(betArray)
    local betArea = 0
    local betType = 0
    --多个投注数的总和
    local total = 0
    local len = #betArray
    for i=1,len do
        total = total + betArray[i]
    end
    if len == 1 then
        if betArray[1] <= 12 then
            betArea = betArray[1] - 1               
            betType = 0  --单数的
        else
            betArea = betArray[1] - 13  
            betType = 3  -- 6个数的
        end
    elseif len == 2 then
        betArea = twoBetConfig[total]              
        betType = 1    --2个数的
    elseif len == 4 then
        betArea = fourBetConfig[total]              
        betType = 2   --4个数的
    end
    print("投注参数：",betType,betArea)
    return betType,betArea
end

--中奖区域闪烁
function betAreaLayer:winAreaBlink(winNumber)
    --中奖区域闪烁
    local winIndex = {}  --0~5  对应：mm_ImageEffect_13~18节点
    for k,v in pairs(areaConfig[3]) do
        for i,value in pairs(v) do
            if value == winNumber then
                table.insert( winIndex, k )
            end
        end
    end
    for k,v in pairs(winIndex) do
            self["mm_ImageEffect_"..12+(v+1)]:runAction(cc.Sequence:create({
        cc.Blink:create(3,9)
    }))
    end
    self["mm_ImageEffect_"..winNumber]:runAction(cc.Sequence:create({
        cc.Blink:create(3,9)
    }))
end

--发奖
function betAreaLayer:onAwarding(winNumber)
    local winArea = {}  --找出当前中奖关联的相关区域
    for betType,tab1 in pairs(areaConfig) do
        for betArea,tab2 in pairs(tab1) do
            for k,v in pairs(tab2) do
                if v == winNumber then
                    table.insert( winArea, {betType = betType,betArea = betArea} )
                end
            end
        end
    end
    tdump(winArea)
    local tempChipInfo = {}
    local sum = #self.m_chipNodeArray
    for i=sum,1,-1 do
        self.m_recycleTime = self.m_recycleTime + 0.04
        if self.m_recycleTime >= 0.6 then
            self.m_recycleTime = self.m_recycleTime - 0.6
        end
        local isShow = false
        local chip = self.m_chipNodeArray[i]
        for key,bet in pairs(winArea) do
            if chip.info.betType == bet.betType and chip.info.betArea == bet.betArea then
                isShow = true
                chip:setVisible(true)
                chip:setOpacity(255)  --透明度
                performWithDelay(self.mm_Panel_chipRoot,function() 
                    chip:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.MoveTo:create(0.3,chip.info.beginPos),cc.CallFunc:create(function() 
                        chip:setVisible(false)
                        chip:setPosition(cc.p(0,0))
                    end)))
                end,self.m_recycleTime)
                table.insert( tempChipInfo, chip.info )


                -- local str = chip.info.betType.."-"..chip.info.betArea
                -- if not chip.subText then
                --     local textTips=ccui.Text:create(str,"fonts/round_body.ttf",80)
                --     chip:addChild(textTips)
                --     chip.subText = textTips
                -- else
                --     chip.subText:setString(str)
                -- end
            else
                -- if chip.info.isMe then
                --     chip:setVisible(true)
                --     chip:setOpacity(100)  --透明度
                -- end
            end
        end
        if isShow == false and chip:isVisible() then
            local opacity = chip:getOpacity()
            print(opacity)
            -- chip:setVisible(false)
        end
    end
    if sum > 0 then
        performWithDelay(self.mm_Panel_chipRoot,function() 
            ccexp.AudioEngine:play2d(sounds.stackChip, false,self.m_rootNode.m_soundsVolume)
        end,1.8)
    end
    tdump(tempChipInfo)
end

--创建筹码
function betAreaLayer:createChip(betType,betArea,chipIndex)
    local chip = nil
    local chipImgPath = string.format("res/GUI/chip/roulette_cm%d.png", chipIndex)
    local index = #self.m_chipNodePool
    if index > 0 then
        chip = table.remove( self.m_chipNodePool,index )
        chip:setTexture(chipImgPath)
    else
        chip = cc.Sprite:create(chipImgPath)
        self.mm_Panel_chipRoot:addChild(chip)
        chip:setPosition(cc.p(0,0))
        chip:setScale(0.4)
    end
    chip:setOpacity(255)  --透明度
    chip:setVisible(true)
    return chip
end

--偏移
local tempOffset = {}

--下注  data.cbBetType,data.cbBetArea
function betAreaLayer:addChip(data,chipIndex,beginPos,isMe,curRemainTime,callback)
    if not self.m_betPosConfig[data.cbBetType] then
        print(data.cbBetType)
    else
        if not self.m_betPosConfig[data.cbBetType][data.cbBetArea] then
            print(data.cbBetArea)
            return
        end
    end
    local endPos = self.m_betPosConfig[data.cbBetType][data.cbBetArea]
    if endPos == nil then return end
    local chip = self:createChip(data.cbBetType,data.cbBetArea,chipIndex)
    chip.info = {
        betType = data.cbBetType,
        betArea = data.cbBetArea,
        chipIndex = chipIndex,
        beginPos = beginPos or (cc.p(0,0)),
        endPos = endPos,
        isMe = isMe or false,
    }
    -- ------------------------------显示筹码编号----------------------------
    -- local str = chip.info.betType.."-"..chip.info.betArea
    -- if not chip.subText then
    --     local textTips=ccui.Text:create(str,"fonts/round_body.ttf",80)
    --     chip:addChild(textTips)
    --     chip.subText = textTips
    -- else
    --     chip.subText:setString(str)
    -- end
    -- ----------------------------------------------------------------------
    if isMe then
        tdump(chip.info)
    end
    table.insert( self.m_chipNodeArray, chip )
    if not chip.setPosition then
        print(" chip.setPosition = nil")
    end

    chip:setPosition(chip.info.beginPos)
    self:runChip(chip,cc.pAdd(origin,endPos),isMe,curRemainTime,callback)
end

function betAreaLayer:runChip(chipNode,endPos,isMe,curRemainTime,callback)
    if curRemainTime < 3 then
        --中途加入，下注剩余时间小于3秒，快速恢复已下注筹码
        self.m_toTime = self.m_toTime + 0.01
        if self.m_toTime >= 0.5 then
            self.m_toTime = self.m_toTime - 0.5
        end
    else
        self.m_toTime = self.m_toTime + 0.37
        if self.m_toTime >= 1.5 then
            self.m_toTime = self.m_toTime - 1.5
        end
    end
    if isMe then
        local isShow = chipNode:isVisible()
        print("自己下注：",isShow,endPos.x,endPos.y)
        chipNode:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,endPos),cc.FadeOut:create(1.0)))
    else
        performWithDelay(self.mm_Panel_chipRoot,function() 
            chipNode:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.5,endPos)
                ,cc.CallFunc:create(function() 
                    ccexp.AudioEngine:play2d(sounds.chip, false,self.m_rootNode.m_soundsVolume)
                end)
                ,cc.FadeOut:create(1.0)
                ,cc.CallFunc:create(function() 
                    chipNode:setVisible(false)
                end)
            ))
            if callback then
                callback()
            end
        end,self.m_toTime)
    end
end

--回收筹码  recycle
function betAreaLayer:recycleChip()
    local sum = #self.m_chipNodeArray
    for i=sum,1,-1 do
        local chip = table.remove(self.m_chipNodeArray,i)
        if chip ~= nil then
            table.insert( self.m_chipNodePool,chip)
            chip:setVisible(false)
            chip:setPosition(cc.p(0,0))
        else
            print("回收筹码异常")
        end
    end
    local sum = #self.m_chipNodeArray
    if sum > 0 then
        print("回收：",sum)
    end
end

function betAreaLayer:showAllBetScore(allScore,meScore)
    local serverKind = G_GameFrame:getServerKind()
    local allBetGold = g_format:formatNumber(allScore,g_format.fType.standard,serverKind)
    self.mm_Text_allbet:setString(allBetGold)
    local meBetGold = g_format:formatNumber(meScore,g_format.fType.standard,serverKind)
    self.mm_Text_mybet:setString(meBetGold)
end

return betAreaLayer