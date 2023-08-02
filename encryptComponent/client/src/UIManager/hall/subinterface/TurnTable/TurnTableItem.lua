local BaseNode = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseNode")
local TurnTableItem = class("TurnTableItem",BaseNode)    

function TurnTableItem:ctor()
    TurnTableItem.super.ctor(self)
    self:addLayer("Truntable/TurnTableItem.csb")
    self:setTouchEnabled(false)
    self:setContentSize(cc.size(435,130))
    self:initView()
    self:addRichText()
end

function TurnTableItem:create()
    local item = TurnTableItem.new()
    return item
end

function TurnTableItem:initView()
    self._elements = {}
    self.text_node = self:getChildByName("text_node")
    self.bg = self:getChildByName("bg")
end

function TurnTableItem:addRichText()
    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(false)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:addTo(self.text_node)
    richText:setPosition(cc.p(-10,10))
    richText:setContentSize(cc.size(410,100))
    richText:setVerticalSpace(8)
    self._richText = richText
end

function TurnTableItem:init(info,index,rightSelectIndex)
    -- self.richText:setContentSize(cc.size(168, 23))
    -- local timeStr = os.date(Words[27], self.data.logDate)    --[27]="(%H:%M)",
    -- local re1 = ccui.RichElementText:create(1,cc.c3b(120,100,50),255,Words[23],"Helvetica",23)    --[23]="����",
    -- local re2 = ccui.RichElementText:create(1,cc.c3b(0,255,255),255,timeStr,"Helvetica",23)

    -- self.richText:pushBackElement(re1)
    -- self.richText:pushBackElement(re2)
    
    if #self._elements > 0 then
        for k = 1,#self._elements do
            self._richText:removeElement(self._elements[k])
        end
        self._elements = {}
    end
    local llTimestamp = info.llTimestamp
    local cbLotteryType = info.cbLotteryType
    local llCurrencyValue = info.llCurrencyValue
    local llAdditionValue = info.llAdditionValue
    local szNickName = info.szNickName
    local cbCurrencyType = info.cbCurrencyType
    if rightSelectIndex == 2 then
        szNickName = ""
    end
    
    local re1 = ccui.RichElementText:create(1,cc.c3b(215,98,219),255,szNickName,"Helvetica",30) 

    
    local typeDesc = ""
    if cbLotteryType == 0 then
        typeDesc = string.format("%s roleta","Sorteio diário")
    elseif cbLotteryType == 1 then
        typeDesc = string.format("%s roleta"," Sorteio semanal")
    elseif cbLotteryType == 2 then
        typeDesc = string.format("%s roleta","Sorteio mensal")
    end
    local re2 = ccui.RichElementText:create(1,cc.c3b(48,192,207),255,typeDesc,"Helvetica",30) 
    local re3 = nil
    if cbCurrencyType >= 100 then
        if llCurrencyValue > 8 or llCurrencyValue < 1 then llCurrencyValue = 2 end
        if llCurrencyValue == 1 then 
            re3 = ccui.RichElementImage:create(6, cc.c3b(255, 255, 255), 255, "client/res/Truntable/GUI/zp_jb1.png",nil,1)
        else
            re3 = ccui.RichElementImage:create(6, cc.c3b(255, 255, 255), 255, string.format("client/res/Truntable/GUI/zp_dj%s.png",llCurrencyValue),nil,1)
        end
        re3:setWidth(60)
        re3:setHeight(60)
    else
        --0日转盘,1周转盘,2月转盘
        local str = g_format:formatNumber(llCurrencyValue + llAdditionValue,g_format.fType.abbreviation,g_format.currencyType.GOLD)
        re3 = ccui.RichElementText:create(1,cc.c3b(234,157,55),255,"  R$"..str,"Helvetica",30) 
    end
    
    self._richText:pushBackElement(re1)
    self._richText:pushBackElement(re2)
    self._richText:pushBackElement(re3)
    if rightSelectIndex == 2 then
        local re4 = ccui.RichElementText:create(1,cc.c3b(234,157,55),255,os.date("\n%d.%m.%Y   %H:%M:%S",llTimestamp),"Helvetica",30) 
        self._richText:pushBackElement(re4)
        self._elements = {
            re1,re2,re3,re4
        }
    else
        self._elements = {
            re1,re2,re3
        }
    end
    
    
    
end

return TurnTableItem