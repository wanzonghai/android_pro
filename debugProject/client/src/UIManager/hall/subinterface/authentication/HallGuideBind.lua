--[[
***
***绑定手机引导界面
]]
local HallGuideBind =
    class(
    "HallGuideBind",
    function(args)
        local HallGuideBind = display.newLayer()
        return HallGuideBind
    end
)


function HallGuideBind:onExit()

end

function HallGuideBind:ctor(args)
    self.NoticeNext = args and args.NoticeNext 

    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("message/HallGuideBind.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg, self.mm_Panel_content)

    self.mm_bg:onClicked(handler(self, self.onClickClose), true)
    self.mm_btn_close:onClicked(handler(self, self.onClickClose), true)

    -- --跳转大厅
    -- self.mm_btn_jumpHall:onClicked(
    --     function()
    --         self:onJumpHall()
    --     end,
    --     true
    -- )
    --跳转绑定
    self.mm_btn_jumpGift:onClicked(
        function()
            self:onJumpBind()
        end,
        true
    )
    
    local size = self.mm_bg:getContentSize()

    self:playSpine(self.mm_bg,"yindaoye","animation",cc.p(size.width/2,size.height/2))

    local score = 300
    if GlobalData.BindingInfo and GlobalData.BindingInfo.lRewardScore then
        score = GlobalData.BindingInfo.lRewardScore
    end
    local pValue = g_format:formatNumber(score,g_format.fType.abbreviation,g_format.currencyType.GOLD)
    self.mm_text_score:setString(pValue)
    
end

function HallGuideBind:playSpine(pNode,spinePath,animName,pos,callback)
    local rootPath = "message/spine/"
    local animation = sp.SkeletonAnimation:create(rootPath..spinePath..".json",rootPath..spinePath..".atlas",1)
    pNode:addChild(animation)
    if pos then
        animation:setPosition(pos)
    end
    animation:setAnimation(0,animName,true)

    animation:registerSpineEventHandler(function (event)
        if event.type == "complete"  then
            if callback then
                callback(animation)
            end
        end
    end, sp.EventType.ANIMATION_COMPLETE)
    return animation
end

function HallGuideBind:onJumpHall()
    --G_event:NotifyEvent(G_eventDef.UI_SHOW_GUIDE,{})
    self:onClickClose()
end

function HallGuideBind:onJumpBind()
    --type:1 跳转绑定
    
    local callback = function() 
        --查询绑定手机状态
        G_ServerMgr:C2S_GetBindMobileStatus()
    end
    --打开绑定
    G_event:NotifyEvent(G_eventDef.UI_SHOW_MESSAGE,{callback = callback,NoticeNext = self.NoticeNext,ShowType = 1})
    self:removeSelf()
end

function HallGuideBind:onClickClose()
    DoHideCommonLayerAction(
        self.mm_bg,
        self.mm_Panel_content,
        function()          
            if self.NoticeNext then
                G_event:NotifyEvent(G_eventDef.UI_CLIENT_SCENE_NOTICE,{NoticeName="HallMessage"})
            end              
            self:removeSelf()
        end
    )
end

return HallGuideBind
