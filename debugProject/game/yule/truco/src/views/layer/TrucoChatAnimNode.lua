-- truco游戏 聊天，表情，互动动画节点

local TrucoChatAnimNode = class("TrucoChatAnimNode", cc.Node)
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.truco.src.models.GameLogic")

function TrucoChatAnimNode:ctor(param)
	tlog('TrucoChatAnimNode:ctor')
	-- g_ExternalFun.registerNodeEvent(self)
    self.trucoViewLayer = param
    G_event:AddNotifyEvent(G_eventDef.NET_GAMES_USER_EXPRESSION,handler(self,self.onChatInfoReceive))
end

function TrucoChatAnimNode:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_GAMES_USER_EXPRESSION)
end

--收到聊天表情消息
function TrucoChatAnimNode:onChatInfoReceive(cmdData)
    tdump(cmdData, "HallEmailLayer:onChatInfoReceive", 9)
    if cmdData.wItemIndex <= 100 then
        --普通表情(100以内)
        self:showNormalFace(cmdData)
    elseif cmdData.wItemIndex <= 200 then
        --魔法表情(101-200)
        self:showMagicFace(cmdData)
    elseif cmdData.wItemIndex <= 300 then
        --快捷聊天(201-300)
        self:showQuickChat(cmdData)
    elseif cmdData.wItemIndex <= 400 then
        --互动表情(301-400)
        self:showHuDongAnim(cmdData)
    end
end

--普通表情
function TrucoChatAnimNode:showNormalFace(cmdData)
    tlog("TrucoChatAnimNode:showNormalFace", cmdData.dwSendUserID, cmdData.dwTargerUserID)
    local userInfo = self:getDataMgr():getUidUserList()[cmdData.dwSendUserID]
    if userInfo then
        local pos_index = GameLogic:getPositionByChairId(userInfo.wChairID) + 1
        local posTb = {cc.p(-640, 145+40), cc.p(795, 580+40),
            cc.p(140, 935+40), cc.p(-800, 580+40)}
        local spineNameTb = {
            "face2_ske", "face12_ske", "face11_ske", "face5_ske", "face9_ske", "face10_ske",
            "face8_ske", "face4_ske", "face6_ske", "face1_ske", "face7_ske", "face3_ske",
        }
        local idx = cmdData.wItemIndex
        local bgNode = display.newNode()
        bgNode:addTo(self)
        local bgSpine = sp.SkeletonAnimation:create("spine/normal/"..spineNameTb[idx]..".json","spine/normal/"..spineNameTb[idx]..".atlas", 1)
        bgSpine:addTo(bgNode)
        bgSpine:setScale(1.8)
        tlog("TrucoChatAnimNode:showNormalFace222", pos_index, posTb[pos_index].x, posTb[pos_index].y)
        bgSpine:setPosition(posTb[pos_index])
        bgSpine:setAnimation(0, "Sprite", false)
        bgNode:executeDelay(function ( ... )
            bgNode:removeFromParent()
        end, 1.8)
    end
end

--魔法表情
function TrucoChatAnimNode:showMagicFace(cmdData)
    tlog("TrucoChatAnimNode:showMagicFace", cmdData.dwSendUserID, cmdData.dwTargerUserID)
    local userInfo = self:getDataMgr():getUidUserList()[cmdData.dwSendUserID]
    if userInfo then
        local pos_index = GameLogic:getPositionByChairId(userInfo.wChairID) + 1
        local posTb = {cc.p(-640, 145+70), cc.p(795, 580+70),
            cc.p(140, 935+70), cc.p(-800, 580+70)}
        local spineNameTb = {
            "mf_face12_ske", "mf_face09_ske", "mf_face04_ske", "mf_face11_ske", "mf_face06_ske", "mf_face13_ske",
            "mf_face02_ske", "mf_face10_ske", "mf_face08_ske", "mf_face07_ske", "mf_face01_ske", "mf_face05_ske",
        }
        local idx = cmdData.wItemIndex - 100
        local bgNode = display.newNode()
        bgNode:addTo(self)
        local bgSpine = sp.SkeletonAnimation:create("spine/magic/"..spineNameTb[idx]..".json","spine/magic/"..spineNameTb[idx]..".atlas", 1)
        bgSpine:addTo(bgNode)
        bgSpine:setScale(1.8)
        bgSpine:setPosition(posTb[pos_index])
        bgSpine:setAnimation(0, "Sprite", false)
        bgNode:executeDelay(function ( ... )
            bgNode:removeFromParent()
        end, 1.8)
    end
end

--快捷聊天
function TrucoChatAnimNode:showQuickChat(cmdData)
    tlog("TrucoChatAnimNode:showQuickChat", cmdData.dwSendUserID, cmdData.dwTargerUserID)
    local userInfo = self:getDataMgr():getUidUserList()[cmdData.dwSendUserID]
    if userInfo then
        local pos_index = GameLogic:getPositionByChairId(userInfo.wChairID) + 1
        local posTb = {cc.p(-640-74, 145+180), cc.p(795, 580+180),
            cc.p(140-140, 935+110), cc.p(-800, 580+180)}
        local csbName = "TrucoChatNode3.csb"
        if pos_index == 4 then
            csbName = "TrucoChatNode1.csb"
        elseif pos_index == 2 then
            csbName = "TrucoChatNode2.csb"
        end
        local idx = cmdData.wItemIndex - 200
        local bgNode = display.newNode()
        bgNode:addTo(self)
        local csbNode = g_ExternalFun.loadCSB("UI/"..csbName)
        csbNode:setAnchorPoint(cc.p(0.5,0.5))
        csbNode:setPosition(posTb[pos_index])
        csbNode:addTo(bgNode) 
        local timeline = cc.CSLoader:createTimeline("UI/"..csbName)
        csbNode:runAction(timeline)
        timeline:gotoFrameAndPlay(0, 35, false)
        local chat = csbNode:getChildByName("Panel_1"):getChildByName("Panel_content"):getChildByName("Text_chat")
        chat:setString(g_language:getString("truco_chat"..idx))
        bgNode:executeDelay(function ( ... )
            bgNode:removeFromParent()
        end, 1.8)
    end
end

--互动表情
function TrucoChatAnimNode:showHuDongAnim(cmdData)
    local userInfo = self:getDataMgr():getUidUserList()[cmdData.dwSendUserID]
    local userTag = self:getDataMgr():getUidUserList()[cmdData.dwTargerUserID]
    if userInfo and userTag then
        local pos_index1 = GameLogic:getPositionByChairId(userInfo.wChairID) + 1
        local pos_index2 = GameLogic:getPositionByChairId(userTag.wChairID) + 1
        local posTb = {cc.p(-640, 145+40), cc.p(795, 580+40),
            cc.p(140, 935+40), cc.p(-800, 580+40)}
        local spineNameTb = {
            "zhadan", "rengshi", "penbei", "qiaji", "diaoyu", 
            "qinwen", "motou", "huishouguzhang", "weiyu", "jiateling",
        }
        local delayTb = {
            0.6, 0.87, 1.64, 1.34, 6.76, 
            1.55, 2.22, 2.0, 1.41, 2.12,
        }
        local idx = cmdData.wItemIndex - 300
        local bgNode = display.newNode()
        bgNode:addTo(self)
        local startPos = posTb[pos_index1]
        local tagPos = posTb[pos_index2]
        if idx == 1 or idx == 2 or idx == 4 then
            local bgSpine = sp.SkeletonAnimation:create("spine/hudong/"..spineNameTb[idx]..".json","spine/hudong/"..spineNameTb[idx]..".atlas", 1)
            bgSpine:addTo(bgNode)
            bgSpine:setPosition(0, 0)
            local secondAnim = "ji"
            local delay = delayTb[idx]
            if idx == 1 then
                bgSpine:setAnimation(0, "zhadang", true)
                secondAnim = "baozha"
            elseif idx == 2 then
                bgSpine:setAnimation(0, "shi", true)
                secondAnim = "shouji"
            else
                bgSpine:setAnimation(0, "shou", true)
                local vec = cc.pSub(tagPos,startPos)
                local arc = cc.pToAngleSelf(vec)
                bgSpine:setRotation(math.deg(-arc))
                local PI = 3.1415926
                if arc > PI*0.5 and arc <= PI*1.5 then
                    --bgNode:setRotation3D(cc.vec3(180, 0, 0))
                end
            end
            local moveto = cc.EaseCubicActionOut:create(cc.MoveTo:create(0.66, tagPos))
            local seq = cc.Sequence:create(
                moveto,
                cc.CallFunc:create(function()
                    --bgNode:setRotation3D(cc.vec3(0, 0, 0))
                    bgSpine:setRotation(0)
                    bgSpine:setAnimation(0, secondAnim, false)
                    
                end),
                cc.DelayTime:create(delay),
                cc.CallFunc:create(function()
                    bgNode:removeFromParent()
                end)
            )
            bgNode:setPosition(startPos)
            bgNode:runAction(seq)
        elseif idx == 3 or idx == 5 or idx == 6 or idx == 7 then
            local bgSpine = sp.SkeletonAnimation:create("spine/hudong/"..spineNameTb[idx]..".json","spine/hudong/"..spineNameTb[idx]..".atlas", 1)
            bgSpine:addTo(bgNode)
            local delay = delayTb[idx]
            bgSpine:setAnimation(0, "animation", false)
            local moveto = cc.EaseCubicActionOut:create(cc.MoveTo:create(0.66, tagPos))
            local seq = cc.Sequence:create(
                moveto,
                cc.DelayTime:create(delay),
                cc.CallFunc:create(function()
                    bgNode:removeFromParent()
                end)
            )
            bgNode:setPosition(startPos)
            bgNode:runAction(seq)
        elseif idx == 8 then
            local bgSpine = sp.SkeletonAnimation:create("spine/hudong/"..spineNameTb[idx]..".json","spine/hudong/"..spineNameTb[idx]..".atlas", 1)
            bgSpine:addTo(bgNode)
            bgSpine:setPosition(startPos)
            bgSpine:setAnimation(0, "guzhang", false)
            local bgSpine2 = sp.SkeletonAnimation:create("spine/hudong/"..spineNameTb[idx]..".json","spine/hudong/"..spineNameTb[idx]..".atlas", 1)
            bgSpine2:addTo(bgNode)
            bgSpine2:setPosition(tagPos)
            bgSpine2:setAnimation(0, "huishou", false)
            local delay = delayTb[idx]
            local seq = cc.Sequence:create(
                cc.DelayTime:create(delay),
                cc.CallFunc:create(function()
                    bgNode:removeFromParent()
                end)
            )
            bgNode:setPosition(0, 0)
            bgNode:runAction(seq)
        elseif idx == 9 then
            local bgSpine = sp.SkeletonAnimation:create("spine/hudong/"..spineNameTb[idx]..".json","spine/hudong/"..spineNameTb[idx]..".atlas", 1)
            bgSpine:addTo(bgNode)
            bgSpine:setPosition(0, 0)
            local secondAnim = "shayu"
            local delay = delayTb[idx]
            bgSpine:setAnimation(0, "xiaoyu", true)
            local bezier = {
                startPos,
                cc.p((startPos.x + tagPos.x) * 0.5, (startPos.y + tagPos.y) * 0.5 + 100),
                tagPos,
            }
            local bezierto = cc.EaseInOut:create(cc.BezierTo:create(0.66, bezier), 1)
            local seq = cc.Sequence:create(
                bezierto,
                cc.CallFunc:create(function()
                    bgSpine:setAnimation(0, secondAnim, false)
                end),
                cc.DelayTime:create(delay),
                cc.CallFunc:create(function()
                    bgNode:removeFromParent()
                end)
            )
            bgNode:setPosition(startPos)
            bgNode:runAction(seq)
        else
            local bgNode1 = display.newNode()
            bgNode1:addTo(bgNode)
            bgNode1:setPosition(startPos)
            local bgSpine = sp.SkeletonAnimation:create("spine/hudong/"..spineNameTb[idx]..".json","spine/hudong/"..spineNameTb[idx]..".atlas", 1)
            bgSpine:addTo(bgNode1)
            bgSpine:setPosition(0, 0)
            bgSpine:setAnimation(0, "jiqiang", false)
            local bgNode2 = display.newNode()
            bgNode2:addTo(bgNode)
            bgNode2:setPosition(tagPos)
            local bgSpine2 = sp.SkeletonAnimation:create("spine/hudong/"..spineNameTb[idx]..".json","spine/hudong/"..spineNameTb[idx]..".atlas", 1)
            bgSpine2:addTo(bgNode2)
            bgSpine2:setPosition(0, 0)
            bgSpine2:setAnimation(0, "shouji", false)
            local bgNode3 = display.newNode()
            bgNode3:addTo(bgNode)
            bgNode3:setPosition(startPos)
            local bgSpine3 = sp.SkeletonAnimation:create("spine/hudong/"..spineNameTb[idx]..".json","spine/hudong/"..spineNameTb[idx]..".atlas", 1)
            bgSpine3:addTo(bgNode3)
            bgSpine3:setPosition(0, 0)
            bgSpine3:setAnimation(0, "zidan", false)
            local distance =  cc.pGetDistance(startPos, tagPos)
            local vec = cc.pSub(tagPos,startPos)
            local arc = cc.pToAngleSelf(vec)
            bgSpine:setRotation(math.deg(-arc))
            bgSpine3:setRotation(math.deg(-arc))
            local PI = 3.1415926
            if arc > PI*0.5 and arc <= PI*1.5 then
                --bgNode1:setRotation3D(cc.vec3(180, 0, 0))
                --bgNode3:setRotation3D(cc.vec3(180, 0, 0))
            end
            bgSpine3:setScale(distance/1400)
            local delay = delayTb[idx]
            local seq = cc.Sequence:create(
                cc.DelayTime:create(delay),
                cc.CallFunc:create(function()
                    bgNode:removeFromParent()
                end)
            )
            bgNode:setPosition(0, 0)
            bgNode:runAction(seq)
        end
    end
end

function TrucoChatAnimNode:getDataMgr()
    return self.trucoViewLayer:getDataMgr()
end

return TrucoChatAnimNode