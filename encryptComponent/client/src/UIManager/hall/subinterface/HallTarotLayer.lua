--[[
    塔罗牌
]]

local HallTarotLayer = class("HallTarotLayer",ccui.Layout)

function HallTarotLayer:onExit()
    G_ServerMgr:C2S_RequestTarotData()
    G_event:RemoveNotifyEventTwo(self,G_eventDef.EVENT_TAROT_REQUEST)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_TAROT_OPEN_CARD)
    self:removeSelf()
end

function HallTarotLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    local csbNode = cc.CSLoader:createNode("tarot/tarotLayer.csb")
    csbNode:setContentSize(display.size)
    ccui.Helper:doLayout(csbNode)
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self, csbNode)

    self:initNode()
    self:getMyIP()
    G_event:AddNotifyEventTwo(self,G_eventDef.EVENT_TAROT_REQUEST,handler(self,self.onRequestDataClick))   --请求数据
    G_event:AddNotifyEvent(G_eventDef.EVENT_TAROT_OPEN_CARD,handler(self,self.onOpenCardClick))   --开启牌
    G_ServerMgr:C2S_RequestTarotData()
end

function HallTarotLayer:initNode()
    self.mm_Node_gold:hide()             --开中的金币数字显示
    -- self.mm_Panel_Tips_2:hide()           --提示最高获取
    self.mm_ListView_text:hide()         --时间倒计时
    self.mm_Panel_btn:hide()             --牌抽奖按钮层
    self.mm_Panel_close:setTouchEnabled(false)
    self.mm_bg:setOpacity(0)
    self.mm_bg:runAction(cc.Sequence:create(cc.FadeIn:create(0.3)))
    self.mm_ListView_text:setOpacity(0)
    self.mm_ListView_text:runAction(cc.Sequence:create(cc.FadeIn:create(0.6)))
    self.mm_Panel_Tips_2:setOpacity(0)
    self.mm_Panel_Tips_2:runAction(cc.Sequence:create(cc.FadeIn:create(0.6)))
    self.mm_btn_close:onClicked(function() self:onExit() end)
    self.mm_bg:onClicked(function() self:onExit() end) 
    self.mm_Panel_close:addClickEventListener(function() self:onExit() end)
    for i=1,5 do
        self["mm_btn_card"..i].userData = {index = i}
        self["mm_btn_card"..i]:onClicked(handler(self,self.onSelectCardClick))
    end
end

function HallTarotLayer:onSelectCardClick(target)
    print(target.userData.index)
    local vip_level = GlobalUserItem.VIPLevel or 0
    if vip_level < 3 then
        --showToast("É necessário alcançar o nível VIP3 para participar.") --达到vip3才可参与
        local txt = "É necessário alcançar o nível VIP3 para participar." 
        local pData = {
            msg = txt,
            callback = function(click)
                if click == "ok" then      
                    self:jumpGiftCenter()
                end					
            end
        }
        G_event:NotifyEvent(G_eventDef.UI_OPEN_COMMON_DIALOG,pData)
        return
    end
    G_ServerMgr:C2S_RequestTarotCard(target.userData.index,self.myip) 
end

function HallTarotLayer:jumpGiftCenter()
    -- if  GlobalData.ProductsOver and GlobalData.GiftEnable and GlobalData.PayInfoOver then            
    --     local pData = {
    --         ShowType = 1,--展示礼包类型：1.首充 2.每日 3.一次性
    --         NoticeNext = self.NoticeNext
    --     }
    --     G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData)
    -- end
    G_ServerMgr:C2S_GetVIPInfo(1)
    self:removeSelf()
end

function HallTarotLayer:getMyIP()
    self.myip = "127.0.0.1"
    local info = {
        url = "https://ifconfig.me/ip",
        callback = function(ok,response) 
            print("myIp = ",response)
            self.myip = response 
        end
    }
    http.get(info)
end

--请求数据返回
function HallTarotLayer:onRequestDataClick(data)
    -- if data.cbEnable == 3 then return end
    local aniName = "ruchang2"
    local awaitAniName = "ruchang_daiji2"
    if data.cbEnable == 1 then
        --可抽奖
        aniName = "ruchang1"
        awaitAniName = "ruchang_daiji1"
        self.mm_Panel_btn:show()
        self.mm_ListView_text:hide()

    elseif data.cbEnable == 2 then
        self.mm_Panel_btn:hide()
        self.mm_ListView_text:show()    
        --开启倒计时
        self:startCountdown(data)
        self.mm_ListView_text:show()         --时间倒计时
    -- else
        -- self:onExit()
    else
        self.mm_text_time:setString("")
        self.mm_text_desc:setString("Recarregue para iniciar a próxima rodada")
        self.mm_ListView_text:show()
    end
    self.m_tarotData = data


    if not self.ruchang then
        --入场
        self.ruchang = sp.SkeletonAnimation:create("tarot/spine/kaluopai2.json","tarot/spine/kaluopai2.atlas", 1)        
        self.ruchang:addTo(self.mm_node_sp)
        self.ruchang:setPosition(cc.p(0,0)) 
    end
    if not self.ruchangEffect then
        --入场效果
        self.ruchangEffect = sp.SkeletonAnimation:create("tarot/spine/kaluopai1.json","tarot/spine/kaluopai1.atlas", 1)        
        self.ruchangEffect:addTo(self.mm_node_sp)
        self.ruchangEffect:setPosition(cc.p(0,0))
    end
    self.ruchang:setAnimation(0, aniName, false)
    self.ruchang:registerSpineEventHandler( function( event )
        if event.animation == aniName then
            self.ruchang:setAnimation(0, awaitAniName, true)   
        end
    end, sp.EventType.ANIMATION_COMPLETE)   
    self.ruchangEffect:setAnimation(0, "ruchang", false)
    G_ServerMgr:C2S_RequestRedData()  --请求刷新红点数据
end

function HallTarotLayer:onOpenCardClick(data)
    if data and data.nErrorType~=0 then
        return
    end
    self.m_nUseCount = data.nUseCount  --已抽过的次数
    -- g_redPoint:dispatch(g_redPoint.eventType.tarotSub_1,false)
    G_ServerMgr:C2S_RequestRedData()
    self.mm_Panel_btn:hide()
    self.mm_Panel_Tips_2:hide()
    local animName = string.format("fanpang_%s",data.cbBetId)
    local goldType = g_format.currencyType.GOLD
    if data.uCurrencyType == 2 then
        local goldType = g_format.currencyType.TC
    end
    local str = g_format:formatNumber(data.llAwardVule,g_format.fType.standard,goldType)
    self.mm_text_gold:setString(str)

    self.ruchang:setAnimation(0, animName, false)
    self.ruchang:registerSpineEventHandler( function( event )
        if event.eventData and event.eventData.name == "jiangli" then
            self.mm_Node_gold:show()
            self.mm_text_gold:setScaleX(1)
            self.mm_Panel_close:setTouchEnabled(true)
        end
    end, sp.EventType.ANIMATION_EVENT)  

    self.ruchang:registerSpineEventHandler( function( event )
        if event.animation == animName then
            self.ruchang:setAnimation(0, "fangpai_daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)   

    self.ruchangEffect:setAnimation(0, animName, false)   
    self.ruchangEffect:registerSpineEventHandler( function( event )
        if event.animation == animName then
            self.ruchangEffect:setAnimation(0, "fangpai_daiji", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)  
end

--开始倒计时
function HallTarotLayer:startCountdown(args)

    self.m_nTimeLeave = args.nTimeLeave
    local updateTime = function() 
        self.m_nTimeLeave = self.m_nTimeLeave - 1
        if self.m_nTimeLeave <= 0 then
            self.mm_text_time:stopAllActions()
            self.m_tarotData.cbEnable = 1
            self.m_tarotData.nTimeLeave = 0
            self:onRequestDataClick(args)
            return
        end
        local tempText = string.format("%.2d:%.2d:%.2d", self.m_nTimeLeave/(60*60), self.m_nTimeLeave/60%60, self.m_nTimeLeave%60)
        -- print("剩余时间：",tempText)
        if math.modf(self.m_nTimeLeave/(60*60)) > 72 then
            local allH = math.fmod(self.m_nTimeLeave,60*60*24) --对天取余  后剩余时间
            local D = math.modf(self.m_nTimeLeave/(60*60*24))  --对天取整   天
            local H = math.modf(allH/(60*60))                             --时
            local M = math.fmod(math.modf(self.m_nTimeLeave/60),60)       --分
            local S = math.fmod(self.m_nTimeLeave,60)                     --秒

            tempText = string.format("  %d dias %.2d:%.2d:%.2d",D ,H, M, S)
        end
        self.mm_text_time:setString(tempText)
        local descSize = self.mm_text_desc:getContentSize()
        local timeSize = self.mm_text_time:getContentSize()
        local listSize = self.mm_ListView_text:getContentSize() 
        self.mm_ListView_text:setContentSize(cc.size(descSize.width + timeSize.width,listSize.height))
        ccui.Helper:doLayout(self.mm_ListView_text)
    end
    updateTime()
    schedule(self.mm_text_time,updateTime,1)
end


return HallTarotLayer