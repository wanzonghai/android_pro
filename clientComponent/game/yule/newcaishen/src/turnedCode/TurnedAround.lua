--公用slot旋转节点类
local TurnedAround = class("TurnedAround", cc.Node)
local module_pre = "game.yule.newcaishen.src"
local logic = appdf.req(module_pre .. ".models.GameLogic")
local ef = g_ExternalFun
local SPEEDTYPE = {
	SLOW = 1,
	QUICK = -1,
}

function TurnedAround:ctor(_node)
	tlog('TurnedAround:ctor')
	self.speed = 2400 --旋转速度
	self._quickModeSpeed = 4500 --快速模式旋转速度
	self._slowModeSpeed = 2400 --慢速模式旋转速度
	self.tCurRunTurned = {} --当前随机到的旋转表现配置
	self.offect = 30 --结束后往下偏移
	self.offectTime = 0.1
	self.tCurDisc = {} --随机旋转结果[列][行]
	self.tShowItem = {} --随机旋转结果图片[列][行]
	self.quick = 7 --快速转圈初始圈数
	self.quickSuper = {} --快速超级旋转的第一列是前面的圈数加上这个
	self.slow = 10 --慢速转圈初始圈数
	self.slowAdd = 1 --往后一列加一圈
	self.slowSuper = {} --慢速超级旋转的第一列是前面的圈数加上这个
	self.isCanStop = false --是否可以停止转动
	self.endData = nil --随机结果数据
	self._type = 0 --type==1 前面先转动  后面慢转动  总时间长 --type==2 同时执行    总时间断
	self._nSuperRoll = -2 --超级旋转的开始列
	self._curTime = 0 --当前时间戳
	self._userNormal = true --转盘类型，true普通，false财神到专用
	self._isPlayMusic = true --是否播放音效
end
--设置是否播放音效
function TurnedAround:setIsPlayEffect(falg)
	tlog("TurnedAround:setIsPlayEffect ", falg)
	self._isPlayMusic = flag
end
--设置旋转速度
function TurnedAround:setSpeed(num)
	tlog("TurnedAround:setSpeed ", num)
	self.speed = num
end
--设置快速和慢速的旋转速度
function TurnedAround:setSpeedByType(isQuick, speed)
	tlog("TurnedAround:setSpeedByType ", isQuick, speed)
	if isQuick then 
		self._quickModeSpeed = speed or self._quickModeSpeed
        self.speed = self._quickModeSpeed
        self._type = 2
	else
		self._slowModeSpeed = speed or self._slowModeSpeed
        self.speed = self._slowModeSpeed
        self._type = 1
	end
end
--设置转盘类型，true普通，false财神到专用
function TurnedAround:setUserData(falg)
	tlog("TurnedAround:setUserData ", falg)
	self._userNormal = flag
end
--初始化slot旋转数据
--{node[]} layers 转轮数组 长度为列数
--{sprite[][]} tOtherImg 转轮精灵数组 [列][行] 
--{[][]} tRandPos 桌面精灵坐标数组用于展示最后结果选中框和动画
--frameHieght 单页高（图片高度*行数）
--COL 列
--ROW 行
--{.plist} fruitPic 精灵图集
--{func} callback 普通转轮回调
--{func} superCallback 超级转轮回调
--{string} color特殊道具图片名，比如"icon_11_color" 
--{func} trunbackCallback 倒退完成回调
function TurnedAround:initData(layers,tOtherImg,tRandPos,frameHieght,COL,ROW,fruitPic,callback,superCallback,color,trunbackCallback)
	tlog("TurnedAround:initData ")
	color = color or ""
	self.layers = layers --转轮数组[列]
	self.tOtherImg = tOtherImg --转轮精灵数组 [列][行] 
	self.tRandPos = tRandPos --桌面精灵坐标数组用于展示最后结果选中框和动画
	self.frameHieght = frameHieght --单页高（图片高度*行数）
	self.COL = COL --列
    self.ROW = ROW --行
    self.fruitPic = fruitPic --精灵图集
    self.callback = callback --普通转轮回调
    self.superCallback = superCallback --超级转轮回调
    self.trunbackCallback = trunbackCallback; --倒退完成回调
    self.color = color --特殊道具图片名
    self.quickSuper = {4,5,6,6,6} --超级旋转第一列是前面的圈数加上这个
    self.slowSuper = {4,5,6,6,6} --普通旋转第一列是前面的圈数加上这个
    for i=1,COL do
    	self.tCurDisc[i]={} --随机旋转结果[列][行]
        self.tShowItem[i]={} --随机旋转结果图片[列][行]
    end
end
--[[开始转轮数据解析
@param {*} scene 场景0普通1免费2奖励界面
@param {*} endData 结束数据4
@param {*} tCurRunTurned 转轮其他数据数组（当前随机到的旋转表现配置）
@param {*} type 转轮类型 1.普通转动 2.快速转动
@param {*} superRoundItemId 超级转动道具id
@param {*} superRoundItemNum 超级转动道具出现次数
@param {*} superStartRound 超级转动判定起始轮
@param {*} bNeedsuperRoundSerial 超级转动道具轮数是否连续
@param {*} colorItemID 颜色变化道具id
@param {*} color 颜色
@param {*} changeItemID 改变--]]
function TurnedAround:runAllAction(scene,endData,tCurRunTurned,superRoundItemId,superRoundItemNum,superStartRound,bNeedsuperRoundSerial,colorItemID,color,changeItemID)
	superStartRound = superStartRound or -1
	bNeedsuperRoundSerial = bNeedsuperRoundSerial or false
	color = color or ""
	self.scene = scene or 0 --场景0普通1免费2奖励界面
	self.nFruitAreaDistri = endData --结束数据
	self.tCurRunTurned = tCurRunTurned or self.tCurRunTurned --当前随机到的旋转表现配置
	self.colorItemID = colorItemID
	self.changeItemID = changeItemID
	self.color = color
	local m_nFruitArea = self.nFruitAreaDistri 
	--结果解析（行列互换？）todo
	local tempFreeItemNum = 0
	for i=1,self.ROW do
		for j=1,self.COL do
            --后端返回的类型要加1
			self.tCurDisc[j][self.ROW-i+1] = m_nFruitArea[i][j]
		end
	end

    -- --超级旋转
    self._nSuperRoll = superStartRound
    self._nStopSuperRoll = superStartRound
    self:runType()
end
--转动动画
function TurnedAround:runType()
	local starttOtherImgPos = 0
    self.tempQuan={}
    local isHave = false
    local num = 0
    if( self._type ==1 ) then
        --前面先转动  后面慢转动  
        for i=1,self.COL do
            if (i==1) then
            	table.insert(self.tempQuan, self.slow) --第一列 默认慢速
            elseif i == (self._nSuperRoll+1) then
                num = self.tempQuan[i-1]+self.slowSuper[1] --如果有超级旋转 
                table.insert(self.tempQuan, num)
                isHave = true
                tlog("超级旋转圈"..num)
            else
                if isHave then
                    num =  self.tempQuan[i-1]+self.slowSuper[i-self._nSuperRoll]--超级旋转后面加
                    table.insert(self.tempQuan, num)
                    tlog("超级旋转圈"..num)
                else
                    num =  self.tempQuan[i-1]+self.slowAdd --正常旋转后面加
                    table.insert(self.tempQuan, num)
                end
            end
        end
    else
    	for i=1,self.COL do
            if i==1 then
            	table.insert(self.tempQuan, self.quick) --第一列 默认 
            elseif i == (self._nSuperRoll+1) then
                num = self.tempQuan[i-1]+self.quickSuper[1] --如果有超级旋转 
                table.insert(self.tempQuan, num)
                isHave = true
                tlog("超级旋转圈"..num)
            else
                if isHave then
                    num =  self.tempQuan[i-1]+self.quickSuper[i-self._nSuperRoll]--超级旋转后面加
                    table.insert(self.tempQuan, num)
                    tlog("超级旋转圈"..num)
                else
                    table.insert(self.tempQuan, self.quick)
                end
            end
        end
    end

    --初始化轮盘真实数据（中间的轮盘配置）
    local start = 0
    local turnLength = 0
    local rollpos=0
    for i=1,self.COL do
        starttOtherImgPos = self.tempQuan[i]*self.ROW-1
        turnLength = #self.tCurRunTurned[i]
        rollpos = math.random(1,turnLength)--self.endData.nRollPos[i]
        for j=starttOtherImgPos,4,-1 do
        	rollpos = rollpos-1
            if rollpos<=0 then
                rollpos = turnLength
            end
            self.tOtherImg[i][j]:stopAllActions()
            self.tOtherImg[i][j]:setOpacity(255)
            self.tOtherImg[i][j]:setSpriteFrame(logic.icons[self.tCurRunTurned[i][rollpos]])
        end
    end
    --初始化最终结果数据
    for i=1,self.COL do
        starttOtherImgPos = self.tempQuan[i]*self.ROW
        for j=1,self.ROW do --行
            self.tOtherImg[i][j+starttOtherImgPos]:stopAllActions()
            self.tOtherImg[i][j+starttOtherImgPos]:setOpacity(255)
            self.tOtherImg[i][j+starttOtherImgPos]:setSpriteFrame(logic.icons[self.tCurDisc[i][j]+1])
            self.tShowItem[i][j] = self.tOtherImg[i][j+starttOtherImgPos]
        end
    end
    --旋转动画
    --
    local First_Roll = false
    local length = #self.layers
    local pos = length
    for i=1,length do
        local dist = self.frameHieght* self.tempQuan[i] + self.offect
        local moveBy = cc.MoveBy:create(dist/self.speed, cc.p(0,-dist))
        local moveBy2 = cc.MoveBy:create(self.offectTime, cc.p(0,self.offect))

        local beginFunc = cc.CallFunc:create(function() 
            if( self._nSuperRoll>=2 and ( i >= self._nSuperRoll) and i < self.COL) then
                self.superCallback(i+1)
            end
        end)

        -- local paw = cc.spawn:create()
        self.layers[i]:runAction(cc.Sequence:create(moveBy, cc.CallFunc:create(function ()
            tlog("data[0]=="..i)
            if( self._nSuperRoll>=2 and ( i >= (self._nSuperRoll+1) ) ) then
                if(self._nStopSuperRoll < self.COL and i > self._nStopSuperRoll) then
                	if self._isPlayMusic then
                        
                	end
                else
                	if self._isPlayMusic then
                		--cc.mg.audio.playBtn_specialTop()
                	end
                end
            else
                if(self._type ==1) then
                    if self._isPlayMusic then
                        ef.playEffect(logic.sound.normal_stop)
                	end
                elseif i == 1 then --快速模式是需要一个声音
                    if self._isPlayMusic then
                		ef.playEffect(logic.sound.normal_stop)
                	end
                end
            end
        end),moveBy2,beginFunc,
        cc.CallFunc:create(function () 
            if(i == pos) then
                self.isCanStop  = false
                self.callback()
            end
            -- print("ajdsofajsdofajosf999.222", self.layers[i]:getPositionY())
        end)))
    end
    self.isCanStop  = true
    self._curTime =  tickMgr:getTime()/1000
end
--停止转动动画
function TurnedAround:stopRollAction()
	if( self.isCanStop == false)then
        return false
    end

    self.isCanStop = false

    local length = #self.layers
    local pos = length
    for i=1,length do
        local dist = self.frameHieght* self.tempQuan[i] + self.offect
        self.layers[i]:stopAllActions()
        self.layers[i]:setPositionY(-dist)
        local moveBy2 = cc.MoveBy:create(self.offectTime, cc.p(0,self.offect))
        self.layers[i]:runAction(cc.Sequence:create(moveBy2, cc.CallFunc:create(function (obj, data)
            if( i == 1)then --快速模式是需要一个声音
                if self._isPlayMusic then
            		ef.playEffect(logic.sound.normal_stop)
            	end
            end
            if(i == pos)then
                self.callback()
            end
        end)))
    end

    return true
end
--获取按钮点击间隔
function TurnedAround:getBtnDisTime()
	local timestamp = tickMgr:getTime()/1000
    if( (timestamp - this._curTime) > 0.1)then
        return true
    end
    self._curTime = timestamp
    return false
end
--转轮位置重置,每条转轮回归初始坐标，等待下一次旋转
function TurnedAround:restartPos()
    -- print("ajdsofajsdofajosf999.000")
	for i=1,#self.tCurDisc do
		for j=1,#self.tCurDisc[i] do
            self.tOtherImg[i][j]:setSpriteFrame(logic.icons[self.tCurDisc[i][j]+1])
            self.tOtherImg[i][j]:setOpacity(255)
            self.tShowItem[i][j] = self.tOtherImg[i][j]
        end
    end
    for i=1,#self.layers do
        -- print("ajdsofajsdofajosf999.111", self.layers[i]:getPositionY())
    	self.layers[i]:setPositionY(0)
    end
end
--获取展示结果精灵数组
function TurnedAround:getShowItem()
    return  self.tShowItem
end

function TurnedAround:initServerData(serverData)
    local _serverData = serverData
	--结果解析（行列互换？）todo
	for i=1,self.ROW do
		for j=1,self.COL do
            --后端返回的类型要加1
			self.tCurDisc[j][self.ROW-i+1] = _serverData[i][j]
		end
	end
    self:restartPos()
end


return TurnedAround