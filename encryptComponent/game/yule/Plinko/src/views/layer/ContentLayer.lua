

--中间内容区域类
local module_pre = "game.yule.Plinko.src"
local logic = appdf.req(module_pre..".models.GameLogic")
local ContentLayer = class("ContentLayer",ccui.Layout)

ContentLayer.RES_PATH = device.writablePath .. "game/yule/Plinko/res/"

function ContentLayer:ctor()
    local csbNode = cc.CSLoader:createNode("UI/ContentLayer.csb")
    self:addChild(csbNode)
    ccui.Helper:doLayout(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
end

function ContentLayer:clerTable()
    self.mm_Panel_pos:removeAllChildren()
    self.mm_Panel_rate:removeAllChildren()
end

function ContentLayer:drawPoint(line)
    for i,v in ipairs(logic.drawData[line].pointTable) do
        self:createPoint(v,line)
    end
end

function ContentLayer:createPoint(pos,line)
    local scale = logic.drawData[line].scale
    local node = display.newNode()
    node:setPosition(pos.x, pos.y )
    local _Sprite_bg = display.newSprite("#plinko_dzyy_bg.png")
    _Sprite_bg:setScale(scale)
    local _Sprite = display.newSprite("#plinko_dz_bg.png")
    _Sprite:setScale(scale)
    node:addChild(_Sprite_bg)
    node:addChild(_Sprite)
    self.mm_Panel_pos:addChild(node)
    local size = _Sprite:getContentSize()
    return _Sprite,size
end

function ContentLayer:close()
    self:removeSelf()
end

function ContentLayer:drawBall(type,pos,scale)
    local ballPath = ""
    local ballbgPath = ""

    if type == logic.betType.GM_YELLOW then
        ballPath = "#ball_yellow.png"
        ballbgPath = "#ball_yellow_shade.png"
    elseif type == logic.betType.GM_RED then
        ballPath = "#ball_red.png"
        ballbgPath = "#ball_red_shade.png"
    else
        ballPath = "#ball_green.png"
        ballbgPath = "#ball_green_shade.png"  --shade
    end

    local node = display.newNode()
    node:setPosition(pos.x, pos.y )
    local _Sprite_bg = display.newSprite(ballbgPath)
    -- _Sprite_bg:setScale(scale)
    local _Sprite = display.newSprite(ballPath)
    _Sprite:setScale(scale)
    node:addChild(_Sprite_bg,1)
    node:addChild(_Sprite,2)
    return node
end

function ContentLayer:toRightAction(node,beginPos,endPos,scale,speedTime)
    local x, y = beginPos.x,beginPos.y
    local offsetX = 10 * scale
    local offsetY = 2 * scale
    local bezierPoint1 ={
        cc.p( x + offsetX, y + offsetY ),  --2
        cc.p( x + offsetX*2, y + offsetY ),  --3
        cc.p( endPos.x, endPos.y )  --4
    }
    local bezierTo1 = cc.EaseInOut:create(cc.BezierTo:create( speedTime, bezierPoint1 ),1)
    return bezierTo1
end

function ContentLayer:toLeftAction(node,beginPos,endPos,scale,speedTime)
    local x, y = beginPos.x,beginPos.y
    local offsetX = 10 * scale
    local offsetY = 2 * scale
    local bezierPoint1 ={
        cc.p( x - offsetX, y + offsetY ),  --2
        cc.p( x - offsetX*2, y + offsetY ),  --3
        cc.p( endPos.x, endPos.y )  --4
    }
    local bezierTo1 = cc.EaseInOut:create(cc.BezierTo:create( speedTime, bezierPoint1 ),1)
    return bezierTo1
end

function ContentLayer:ballAction(data,winningIndex,movePosArray,scale,isMe,upUserScore)
    local color = data.color

    local sp = self:drawBall(color,cc.p(movePosArray[1].pos.x,movePosArray[1].pos.y),scale)
    self.mm_Panel_ball:addChild(sp)

    local actionArray = {}
    local oneAction = cc.MoveTo:create(0.12,movePosArray[2].pos)
    table.insert( actionArray, oneAction )

    local time = 0.2
    local rotate = time * 10 * 60
    local rotateRight = cc.EaseInOut:create(cc.RotateBy:create(time,rotate),1)
    local rotateleft = cc.EaseInOut:create(cc.RotateBy:create(time,-rotate),1)

    local lastx = 0
    local sum = #movePosArray
    local randTime = math.random( 1,10 )
    local speedTime = logic.duration+randTime*0.01

    for i=2,sum - 1 do
        if speedTime > logic.duration then
            speedTime = speedTime - 0.02
        end
        local v = movePosArray[i]
        local v1 = movePosArray[i+1]
        
        if v1.pos.x > v.pos.x then
            if math.abs(lastx - v1.pos.x) < 1 then
                table.insert(actionArray,cc.DelayTime:create(0.02))
            end
            local ac = self:toRightAction(sp,v.pos,v1.pos,scale,speedTime)
            local spawn1 = cc.Spawn:create(ac,rotateRight);
            table.insert(actionArray,ac)
        else
            if math.abs(lastx - v1.pos.x) < 1 then
                table.insert(actionArray,cc.DelayTime:create(0.02))
            end
            local ac = self:toLeftAction(sp,v.pos,v1.pos,scale,speedTime)
            local spawn1 = cc.Spawn:create(ac,rotateleft);
            table.insert(actionArray,ac)
        end
        lastx = v.pos.x
    end

    if isMe then
        --自己才有的后续动作
        local func = cc.CallFunc:create(function() 
            sp:removeSelf()
            local time = cc.DelayTime:create(color*0.1)
            local scale1 = cc.ScaleTo:create(0.1,1.3)
            local scale2 = cc.ScaleTo:create(0.1,1)
            self.blockItems[color+1][winningIndex]:runAction(cc.Sequence:create(time,scale1,scale2))
        end)
        table.insert(actionArray,func)
        local img = self.blockItems[color+1][winningIndex]
        local txt = self.blockItemsTxt[color+1][winningIndex]
        local winData = txt:getString()
        table.insert(actionArray,cc.CallFunc:create(function() upUserScore(data,winData) end))
    else
        local func = cc.CallFunc:create(function() sp:removeSelf() end)
        table.insert(actionArray,func)
        table.insert(actionArray,cc.CallFunc:create(function() upUserScore() end))
    end
    sp:runAction(cc.Sequence:create(unpack(actionArray)))
end

---------------------------绘制3色块-------------------------------------
function ContentLayer:drawColorBlock(line)
    local blockPath = {
        "plinko_lvs_bg.png",
        "plinko_huangs_bg.png",
        "plinko_hongs_bg.png",
    }
    local imgSize = cc.size(84,63)
    local origPos = cc.p(self.mm_Panel_rate:getPosition())
    local block_x = logic.drawData[line].block_x_table
    local sum = #block_x - 2

    imgSize.width = block_x[2].x - block_x[1].x + 10
    print(imgSize.width)
    self.blockItems = {}
    self.blockItemsTxt = {}

    local odds = logic.odds[line]
    local colorSum = #odds
    for i,v in ipairs(odds) do
        self.blockItems[i] = {}
        self.blockItemsTxt[i] = {}
        for k=1,sum do
            local curPos = cc.p(0,0)
            curPos.x = block_x[k+1].x
            curPos.y = (imgSize.height - 12) * (colorSum - i + 1) - imgSize.height/2
            local img = display.newSprite("#"..blockPath[i])
            img:setPosition(curPos)
            img:setContentSize(imgSize)
            self.mm_Panel_rate:addChild(img)

            local Text_1 = ccui.TextBMFont:create()
            Text_1:setFntFile(ContentLayer.RES_PATH .. "font/jny_auto_shuzi.fnt")--ccui.Text:create()
            Text_1:setName("text_winData")
            Text_1:setScale(0.6)
            local s = string.gsub(v[k],"%.",",")
            Text_1:setString(s)
            Text_1:setPosition(curPos)
            self.mm_Panel_rate:addChild(Text_1,1)

            self.blockItems[i][k] = img
            self.blockItemsTxt[i][k] = Text_1
        end
    end
end

function ContentLayer:getBallCount()
    local childCount = self.mm_Panel_ball:getChildrenCount()
    if childCount > 0 then
        return true
    end
    return false
end

return ContentLayer