--[[
***
***绑定成功引导界面
]]
local HallGuideLayer =
    class(
    "HallGuideLayer",
    function(args)
        local HallGuideLayer = display.newLayer()
        return HallGuideLayer
    end
)


function HallGuideLayer:onExit()

end

function HallGuideLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.REWARD) --需要在签到页上前
    
    local csbNode = g_ExternalFun.loadCSB("message/HallGuideLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg, self.mm_Panel_content)

    self.mm_bg:onClicked(handler(self, self.onClickClose), true)
    self.mm_btn_close:onClicked(handler(self, self.onClickClose), true)

    --跳转大厅
    self.mm_btn_jumpHall:onClicked(
        function()
            self:onJumpHall()
        end,
        true
    )
    --跳转礼包
    self.mm_btn_jumpGift:onClicked(
        function()
            self:onJumpGift()
        end,
        true
    )
    
end

function HallGuideLayer:onJumpHall()
    --G_event:NotifyEvent(G_eventDef.UI_SHOW_GUIDE,{})
    self:onClickClose()
end

function HallGuideLayer:onJumpGift()
    --type:1 充值任务
    if  GlobalData.ProductsOver and GlobalData.GiftEnable and GlobalData.PayInfoOver and not GlobalData.TodayPay then            
        local pData = {
            ShowType = 2,--展示礼包类型：1.首充 2.每日 3.一次性
        }
        G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,pData) 
    end
    self:onClickClose()
end

function HallGuideLayer:onClickClose()
    DoHideCommonLayerAction(
        self.mm_bg,
        self.mm_Panel_content,
        function()                        
            self:removeSelf()
        end
    )
end

return HallGuideLayer
