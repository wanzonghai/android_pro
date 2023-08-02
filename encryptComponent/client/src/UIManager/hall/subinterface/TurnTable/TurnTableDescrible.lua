local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local TurnTableDescrible = class("TurnTableDescrible",BaseLayer)

function TurnTableDescrible:ctor(args)
    TurnTableDescrible.super.ctor(self)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self._type = args.ShowType
    self._parent = args.parentObj
    self:loadLayer("Truntable/TruntableDescrible.csb")
    self:init()
    ShowCommonLayerAction(self.bg,self.content)
end

function TurnTableDescrible:init()
    self:initView()
    self:initListener()
    self:doDisplay()
end

function TurnTableDescrible:initView()
    self.bg = self:getChildByName("bg")
    self.content = self:getChildByName("content")
    self.titleImage = self:getChildByName("titleImage")
    self.closeBtn = self:getChildByName("closeBtn")
    self.firstPanel1 = self:getChildByName("firstPanel1")
    self.firstPanel2 = self:getChildByName("firstPanel2")
    self.firstPanel3 = self:getChildByName("firstPanel3")
    self.firstPanel1:hide()
    self.firstPanel2:hide()
    self.firstPanel3:hide()
    self.secondPanel = self:getChildByName("secondPanel")
    self.thirdPanel = self:getChildByName("thirdPanel") 
    self.textNode1 = self:getChildByName("textNode1") 
    self.textNode2 = self:getChildByName("textNode2") 
    self.textNode3 = self:getChildByName("textNode3") 
    self.participarBtn = self:getChildByName("participarBtn")
    self.titleText = self:getChildByName("titleText")
end

function TurnTableDescrible:initListener()
    self.closeBtn:addTouchEventListener(handler(self,self.onTouch))
    self.participarBtn:addTouchEventListener(handler(self,self.onTouch))
end

function TurnTableDescrible:onTouch(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        local name = sender:getName()
        if name == "participarBtn" then
            --展示礼包类型：1.首充(默认) 2.每日 3.一次性
        G_event:NotifyEvent(G_eventDef.UI_SHOW_GIFT_CENTER,{ShowType = self._type})
        elseif name == "closeBtn" then
            self:close()
        end
    end
end

function TurnTableDescrible:doDisplay()
    local type = self._type
    local data1 = self._parent._rechargeTabs[type]
    local data2 = self._parent._chipTabs[type]
    local _weekLoginDay = self._parent._weekLoginDay           --本周登录天数
    local _weekLoginMaxDay = self._parent._weekLoginMaxDay
    local _monthLoginDay = self._parent._monthLoginDay           --本月登录天数
    local _monthLoginMaxDay = self._parent._monthLoginMaxDay  

    local firstPanel = self["firstPanel"..type]
    firstPanel:show()
    self.titleImage:setSpriteFrame(string.format("client/res/Truntable/GUI/zp_xq_biaoti_%s.png",type))
    if type == 1 then               --日转盘
        
    elseif type == 2 then           --周转盘
        local sign2 = firstPanel:getChildByName("sign2")
        sign2:hide()
        if _weekLoginDay >= _weekLoginMaxDay then
            sign2:show()
        else
            local textNode1 = firstPanel:getChildByName("textNode1")
            self:addRichText(textNode1,_weekLoginDay,_weekLoginMaxDay,true)
        end
        
    elseif type == 3 then           --月转盘
        local sign3 = firstPanel:getChildByName("sign3")
        sign3:hide()
        if _monthLoginDay >= _monthLoginMaxDay then
            sign3:show()
        else
            local textNode2 = firstPanel:getChildByName("textNode2")
            self:addRichText(textNode2,_monthLoginDay,_monthLoginMaxDay,true)
        end
    end
    local textNode3 = self.secondPanel:getChildByName("textNode3")
    local text2 = self.secondPanel:getChildByName("text2")
    self:addRichText(textNode3,g_format:formatNumber(data2.CurVal,g_format.fType.standard),g_format:formatNumber(data2.MaxVal,g_format.fType.standard))
    text2:setString(g_format:formatNumber(data2.MaxVal - data2.CurVal,g_format.fType.standard))
    local textNode4 = self.thirdPanel:getChildByName("textNode4")
    self:addRichText(textNode4,g_format:formatNumber(data1.CurVal,g_format.fType.standard),g_format:formatNumber(data1.MaxVal,g_format.fType.standard))
end

function TurnTableDescrible:addRichText(parent,curVal,maxVal,isCenter)
    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(true)
    richText:setAnchorPoint(cc.p(isCenter and 0.5 or 0,0.5))
    local re1 = ccui.RichElementText:create(1,cc.c3b(154,109,234),255,"(","Helvetica",30) 
    local re2 = ccui.RichElementText:create(1,cc.c3b(57,226,57),255,curVal,"Helvetica",30) 
    local re3 = ccui.RichElementText:create(1,cc.c3b(154,109,234),255,"/","Helvetica",30) 
    local re4 = ccui.RichElementText:create(1,cc.c3b(221,146,64),255,maxVal,"Helvetica",30) 
    local re5 = ccui.RichElementText:create(1,cc.c3b(154,109,234),255,")","Helvetica",30) 
    richText:pushBackElement(re1)
    richText:pushBackElement(re2)
    richText:pushBackElement(re3)
    richText:pushBackElement(re4)
    richText:pushBackElement(re5)
    parent:addChild(richText)
    richText:setPosition(cc.p(0,0))
end

return TurnTableDescrible