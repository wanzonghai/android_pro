---------------------------------------------------
--Desc:存钱罐界面
--Date:2023-03-21 17:37:40
--Author:ty
---------------------------------------------------
--local PiggyBankMgr = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.subinterface.PiggyBank.PiggyBankMgr")

local HallPiggyBankLayer = class("HallPiggyBankLayer",function(args)
    local HallPiggyBankLayer =  display.newLayer(cc.c4b(0,0,0,225))
    return HallPiggyBankLayer
end)

function HallPiggyBankLayer:onExit()
    --G_event:RemoveNotifyEvent(G_eventDef.UI_RESOURCE_DOWN_PROGRESS)
end

function HallPiggyBankLayer:ctor(args)
    self.ShowType = {Bank=1,Charge=2}
    self.llscore = 0 --奖励数值
    self.isBreak = false --是否已经敲蛋

    self.NoticeNext = args and args.NoticeNext 
    --提前加载合图    
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("client/res/VIP/VIPPlist.plist", "client/res/VIP/VIPPlist.png")

    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    local child = parent:getChildByName("PiggyBank")
    if child then
        child:removeFromParent(true)
    end

    parent:addChild(self,ZORDER.POPUP)    
    self:setName("PiggyBank")

    self.csbNode = g_ExternalFun.loadCSB("PiggyBank/PiggyBankLayer.csb")
    self:addChild(self.csbNode,1)    
    g_ExternalFun.loadChildrenHandler(self,self.csbNode)
    self.mm_item:setVisible(false)

    self.time_line = cc.CSLoader:createTimeline("PiggyBank/PiggyBankLayer.csb")
    self.time_line:clearFrameEndCallFuncs()
    self.time_line:play("ruchang", false)
    self.csbNode:runAction(self.time_line)
    self.time_line:setLastFrameCallFunc(function()
        self.time_line:play("daiji_jz", true)
    end)
    

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
        self:onClickClose()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    --存钱罐
    self.bgSpine = sp.SkeletonAnimation:create("client/res/PiggyBank/spine/cunqianguang2.json","client/res/PiggyBank/spine/cunqianguang2.atlas", 1)
    self.bgSpine:addTo(self)
    self.bgSpine:setPosition(display.cx, display.cy)
    self.bgSpine:setAnimation(0, "ruchang", false) --zhadan
    self.bgSpine:addAnimation(0, "daiji_jz", true)
    self.bgSpine:registerSpineEventHandler( function( event )
        -- if event.animation == "zhadan" and event.type == "complete" then
        --     self:showAward()
        --     self:onClickClose()
        -- end
    end, sp.EventType.ANIMATION_COMPLETE)

    self.bgSpine2 = sp.SkeletonAnimation:create("client/res/PiggyBank/spine/cunqianguang1.json","client/res/PiggyBank/spine/cunqianguang1.atlas", 1)
    self.bgSpine2:addTo(self)
    self.bgSpine2:setPosition(display.cx, display.cy)
    -- self.bgSpine2:setAnimation(0, "ruchang", false) --zhadan
    -- self.bgSpine2:addAnimation(0, "daiji", true)
    self.bgSpine2:registerSpineEventHandler( function( event )
        if event.type == "complete" then
            self.bgSpine2:setVisible(false)
        end
    end, sp.EventType.ANIMATION_COMPLETE)
    self.bgSpine2:setVisible(false)

    local function onNodeEvent(event)
        if event == "enter" then
        elseif event == "exit" then
            self:onExit()
        end
    end

    self.mm_Button_Charge:onClicked(function () self:onClickedCharge() end)
    self.mm_Button_CloseBank:onClicked(function () self:onClickCloseBank() end)
    self.mm_Button_CloseCharge:onClicked(function () self:onClickCloseCharge() end)
    self.mm_Button_Left:onClicked(function () self:onClickLeft() end)
    self.mm_Button_Right:onClicked(function () self:onClickRight() end)

    self:registerScriptHandler(onNodeEvent)

    --self:ShowPiggyLayer(self.ShowType.Bank)
    self.mm_Panel_Bank:setVisible(true)
    self.mm_Panel_Charge:setVisible(false)
    --G_event:AddNotifyEvent(G_eventDef.EVENT_EGG_BREAK,handler(self,self.OnEggBreakResult))  --下载进度更新 OnUpdateDownProgress
end
function HallPiggyBankLayer:ShowPiggyLayer(showType)
    -- self.mm_Panel_Bank:setVisible(true)
    -- self.mm_Panel_Charge:setVisible(true)
    if showType == self.ShowType.Bank then
        self.bgSpine:setAnimation(0, "daiji_jz", true)
        self.time_line:play("qiehuan_jz", false)
        self.time_line:clearFrameEndCallFuncs()
        self.time_line:setLastFrameCallFunc(function()
            -- self.mm_Panel_Bank:setVisible(true)
            -- self.mm_Panel_Charge:setVisible(false)
        end)
        
        self.mm_Panel_Bank:setVisible(true)
        self.mm_Panel_Charge:setVisible(false)
        --self.mm_item:setVisible(false)
        self:reqPiggyBankInfo()
    elseif showType == self.ShowType.Charge then
        self.bgSpine:setAnimation(0, "qiehuan_jb", false)
        self.bgSpine:addAnimation(0, "daiji_jb", true)
        self.time_line:play("qiehuan_jb", false)
        self.time_line:clearFrameEndCallFuncs()
        self.time_line:setLastFrameCallFunc(function()
            --self.mm_Panel_Bank:setVisible(false)
            --self.mm_Panel_Charge:setVisible(true)
        end)
        self.mm_Panel_Bank:setVisible(false)
        self.mm_Panel_Charge:setVisible(true)

        --self.mm_item:setVisible(false)
        self:reqPiggyChargeInfo()
    end
end
---------------------------------------------------------------------存钱罐界面------------------------------------------------------------------------
function HallPiggyBankLayer:onClickedCharge()
    --G_event:NotifyEvent(G_eventDef.UI_SHOW_HALL_PIGGY_CHARGE,{})
    self:ShowPiggyLayer(self.ShowType.Charge)
end

function HallPiggyBankLayer:reqPiggyBankInfo()
    self:onPiggyBankInfoResult()
end

function HallPiggyBankLayer:onPiggyBankInfoResult(data)
    local data = {}
    data.total_score = 280000
    data.cur_num = 1
    data.total_num = 5
    data.CurProgress = GlobalUserItem.VIPInfo.dwPayCurrent
    data.NeedProgress = GlobalUserItem.VIPInfo.dwPayRequire
    -- local vipInfo = {}
    -- vipInfo.VIPLevel = GlobalUserItem.VIPLevel

    --PiggyBankMgr:get_instance():setPiggyData(data)
    self.PiggyBankInfo = data

    local str = g_format:formatNumber(data.total_score,g_format.fType.standard)
    self.mm_total_score:setString(str)

    local str1 = data.cur_num--g_format:formatNumber(data.cur_num,g_format.fType.standard)
    self.mm_cur_num:setString(str1)
    local str2 = data.total_num--g_format:formatNumber(data.total_num,g_format.fType.standard)
    self.mm_total_num:setString('/'..str2)

    self.mm_Image_vip:loadTexture(string.format("client/res/VIP/GUI/%d.png",GlobalUserItem.VIPLevel),UI_TEX_TYPE_PLIST)
    self.mm_LoadingBar:setPercent(GlobalUserItem.VIPInfo.dwPayCurrent*100/GlobalUserItem.VIPInfo.dwPayRequire)
    local str1 = g_format:formatNumber(data.CurProgress,g_format.fType.standard)
    local str2 = g_format:formatNumber(data.NeedProgress,g_format.fType.standard)
    self.mm_jinDuText1:setString(str1..'/'..str2)

    
end

-- function HallPiggyBankLayer:OnEggBreakResult(data)
--     dump(data)
--     self.llscore = data.llscore or 0
--     self.bgSpine:setAnimation(0, "zhadan", false)
-- end

-- --展示奖励界面
-- function HallPiggyBankLayer:showAward()
--     if self.llscore > 0 then
--         self:showAwardLayer(self.llscore,"client/res/public/mrrw_jb_3.png")
--     else
--         if self.NoticeNext then
--             G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="EggBreak"})
--         end
--     end
-- end

-- function HallPiggyBankLayer:showAwardLayer(goldTxt,goldImg)
--     local path = "client.src.UIManager.hall.subinterface.rewardLayer"
--     local data = {}
--     data.goldTxt = g_format:formatNumber(goldTxt,g_format.fType.standard)
--     data.goldImg = goldImg
--     data.type = 1
--     if self.NoticeNext then
--         data.callback = function()
--             G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="EggBreak"})
--         end
--     end
--     appdf.req(path).new(data)
-- end

function HallPiggyBankLayer:onClickCloseBank()
    --local delay = cc.DelayTime:create(0.2)
    local delay = CCFadeTo:create(0.1,0)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
        if not tolua.isnull(self) then
            self:removeSelf() 
        end
    end))
    self.bgSpine:runAction(sequence)
end
---------------------------------------------------------------------充值界面------------------------------------------------------------------------
function HallPiggyBankLayer:initPiggyBankInfo()
    -- local data = {}
    -- data.total_score = 280000
    -- data.cur_num = 1
    -- data.total_num = 5
    -- data.CurProgress = GlobalUserItem.VIPInfo.dwPayCurrent
    -- data.NeedProgress = GlobalUserItem.VIPInfo.dwPayRequire
    -- local vipInfo = {}
    -- vipInfo.VIPLevel = GlobalUserItem.VIPLevel

    --local data = PiggyBankMgr:get_instance():getPiggyData()
    local data = self.PiggyBankInfo or {}

    local str1 = data.cur_num--g_format:formatNumber(data.cur_num,g_format.fType.standard)
    self.mm_cur_num:setString(str1)
    local str2 = data.total_num--g_format:formatNumber(data.total_num,g_format.fType.standard)
    self.mm_total_num:setString('/'..str2)

    self.mm_Image_vip:loadTexture(string.format("client/res/VIP/GUI/%d.png",GlobalUserItem.VIPLevel),UI_TEX_TYPE_PLIST)
    
end

function HallPiggyBankLayer:reqPiggyChargeInfo()
    --G_ServerMgr:C2s_getPiggInfo()            --请求存钱罐信息
    self:onPiggyChargeInfoResult()
end

function HallPiggyBankLayer:onPiggyChargeInfoResult()
    -- local data = {{score=380000,score_discount=250000,price=2000},
    -- {score=380000,score_discount=250000,price=2000},
    -- {score=380000,score_discount=250000,price=2000}}

    local pListData
    for i, v in ipairs(GlobalData.ProductInfos) do
        if v and v.szProductTypeName and v.szProductTypeName == "daily" then
            pListData = v
            break
        end
    end   

    self.mm_ListView_1:removeAllItems()
    local pCoinPath = "client/res/public/coin_3_%d.png"
    for i, v in ipairs(pListData.ProductInfos) do
        local item = self.mm_item:clone()--g_ExternalFun.loadCSB("PiggyBank/NodeCharge.csb")
        item:setVisible(true)
        local Image_coin = item:getChildByName("Image_coin") 
        Image_coin:ignoreContentAdaptWithSize(true)
        Image_coin:loadTexture(string.format(pCoinPath,i))
        local item_Charge = item:getChildByName("item_Charge") --购买按钮 
        item_Charge:onClicked(function () 
            showToast("charge.."..i)
            self:onChargeResult()
         end)
        local price = item_Charge:getChildByName("price") --按钮金额
        local formatStr = string.format("%.2f",v.dwPrice/100)
        formatStr = string.gsub(formatStr,"%.",",")
        price:setString("R$"..formatStr)

        local score = item:getChildByName("score") --原价
        score:setString(g_format:formatNumber(v.lAwardValue,g_format.fType.standard,g_format.currencyType.GOLD))  
        local prize_score = item:getChildByName("prize_score") --现价
        local pValue = v.lAwardValue
        if v.byAttachType == 1 then
            --附加定值
            pValue = pValue + v.lAttachValue
        elseif v.byAttachType == 2 then
            --附加百分比
            pValue = pValue*(100 + v.lAttachValue)/100
        end
        prize_score:setString(g_format:formatNumber(pValue,g_format.fType.standard,g_format.currencyType.GOLD))   
        --self.mm_ListView_1:pushBackCustomItem(item)
        self.mm_ListView_1:addChild(item)

        item:setOpacity(0)
        local x = 400 * (i - 1)
        local y = -30
        --item:setPosition(x+20,y)
        local place = cc.Place:create(cc.p(x+50,y))
        local delay = cc.DelayTime:create((i-1)*0.16+0.01)
        local fade = cc.FadeTo:create(0.32,255)
        local move = cc.MoveTo:create(0.32,cc.p(x,y))
        
        item:runAction(cc.Sequence:create(delay,place, cc.Spawn:create({fade,move})))

        if i >= 3 then
            item_Charge:setBright(false)
            item:setEnabled(false)
        end
        
    end
    --self.mm_ListView_1:forceDoLayout()
end


function HallPiggyBankLayer:onChargeResult()
    self.mm_Panel_Bank:setVisible(true)
    self.mm_Panel_Charge:setVisible(false)
    self.bgSpine:setAnimation(0, "cunqian", false) --zhadan
    self.bgSpine:addAnimation(0, "daiji_jz", true)
    self.bgSpine2:setVisible(true)
    self.bgSpine2:setAnimation(0, "cunqian", false) --zhadan
    
end

function HallPiggyBankLayer:onClickLeft()
    self.mm_ListView_1:jumpToLeft()
end

function HallPiggyBankLayer:onClickRight()
    self.mm_ListView_1:jumpToRight()
end

function HallPiggyBankLayer:onClickCloseCharge()
    self:ShowPiggyLayer(self.ShowType.Bank)
end
return HallPiggyBankLayer