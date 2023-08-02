local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local TurnTableHelperLayer= class("TurnTableHelperLayer",BaseLayer)
local TurnTableManager = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.subinterface.TurnTable.TurnTableManager")

local desTab = {
    [1] = {
        {key = "every",des = "Faça o login diariamente para receber 1 entrada para o sorteio gratuitamente, válido apenas para o mesmo dia."},         --每日登录获得1次免费抽奖，只限当天有效。
        {key = "FirstBet",des = "Para cada primeira aposta de %s por dia, você receberá %s entradas para os sorteios."},                          --每日首次下注额度满xxxx,可获取x次抽奖机会。
        {key = "EveryBet", des = "Para cada aposta subsequente de %s, você receberá %s entradas para os sorteios."},                   --后续每投注满xxxx，可获取x次抽奖。
        {key = "FirstPay",des = "Por cada R$%s de recarga que você fizer a cada dia, você receberá %s entradas para os sorteios."},   --每日首次充值满xxR$，可获取x次抽奖。
        {key = "EveryPay",des = "Para cada carregamento subseqüente de R$%s, você receberá %s entradas para os sorteios."}            --后续每充值xxR$，可获取x次抽奖。
    },
    [2] = {
       -- {key = "every",des = "O sorteio semanal só está disponível no sábado e no domingo de cada semana."},   --每周抽奖只能在每周的周六、周日两天方可使用。
        {key = "LogonDays",des = "Faça o login por %s dias consecutivos esta semana e receba %s de entradas para os sorteios."},      --本周连续登录x天，可获得x次抽奖。
        {key = "EveryBet",des = "Para cada %s apostas acumuladas esta semana, você receberá %s de entradas para os sorteios."},       --本周累计投注每xxxx，可获得x次抽奖。
        {key = "FirstPay",des = "Por cada R$%s de recarga que você fizer a cada dia, você receberá %s de entradas para os sorteios."},    --本周首次充值满xxxR$，可获得x次抽奖。
        {key = "EveryPay",des = "Para cada carregamento subseqüente de R$%s, você receberá %s entradas para os sorteios."}            --后续每充值xxxR$，可获得x次抽奖。
    },
    [3] = {
       -- {key = "every",des = "O sorteio mensal só poderá ser utilizado após o dia 25 de cada mês, inclusive o dia 25 ."}, --每月抽奖只能在本月25号后可使用，包含25号。
        {key = "LogonDays",des = "Faça o login por %s dias consecutivos este mês e obtenha %s de chances para os sorteios gratuitamente."},   --本月连续登录xx天，可免费获得x次抽奖。
        {key = "EveryBet",des = "Para apostas acumuladas em %s no mês, você pode obter %s de chances para os sorteios."},     --本月累计投注每xxxxx，可获得x次抽奖。
        {key = "FirstPay",des = "Por cada R$%s de recarga neste mês, você receberá %s de chances para os sorteios."},     --本月累计充值xxxxR$，可获得x次抽奖。
        {key = "EveryPay",des = " Por cada R$%s de recarga no mês, você receberá %s de chances para os sorteios."}        --后续充值每xxxxR$，可获得x次抽奖。
    }
}


function TurnTableHelperLayer:ctor(args)
    TurnTableHelperLayer.super.ctor(self)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self:init(args)
end

function TurnTableHelperLayer:init(args)
    -- dump(args)
    local args = args or TurnTableManager.getHelperData()
    TurnTableManager.setHelper(args)
    self._data = args
    self:loadLayer("Truntable/TrunTableHelper.csb")
    ccui.Helper:doLayout(self._rootNode)
    self:initView()
    self:initListener()
    ShowCommonLayerAction(self.bg,self.content)
    self:analyseData()
end

function TurnTableHelperLayer:initView()
    self.bg = self:getChildByName("bg")
    self.content = self:getChildByName("content")
    self.closeBtn = self:getChildByName("closeBtn")
    self.listView = self:getChildByName("listView")
    self.listView:setScrollBarEnabled(false)
    self.listView1 = self:getChildByName("listView1")
    self.listView1:setScrollBarEnabled(false)
    self.listView2 = self:getChildByName("listView2")
    self.listView2:setScrollBarEnabled(false)
    self.listView3 = self:getChildByName("listView3")
    self.listView3:setScrollBarEnabled(false)
    self.clonePanel = self:getChildByName("clonePanel")
    self.clonePanel:retain()
    self.clonePanel:removeFromParent()
end

function TurnTableHelperLayer:onExit()
    TurnTableHelperLayer.super.onExit(self)
    self.clonePanel:release()
end

function TurnTableHelperLayer:initListener()
    self.closeBtn:addTouchEventListener(handler(self,self.onTouch))
end

function TurnTableHelperLayer:onTouch(sender,eventType)
    local name = sender:getName()
    if eventType == ccui.TouchEventType.ended then
        if name == "closeBtn" then
            self:close()
        end
    end 
end

--分析数据
function TurnTableHelperLayer:analyseData()
    local lsItem = self._data.lsItem
    local count = 1
    local initPanel = nil
    local initSize = nil
    self.listSizes = {}
    local findItemData = function(cbType,key) 
        for k = 1,#lsItem do
            local data = lsItem[k]
            local cbLotteryTypeID = data.cbLotteryTypeID
            if tonumber(cbLotteryTypeID) == cbType then
                if data.szKey == key then
                    return data.llCondition,data.cbPresentCount
                end
            end
        end
    end
    for k = 1,#desTab do
        local itemData = desTab[k]
        for m = #itemData,1,-1 do
            local config = itemData[m]
            local key = config.key
            local text = config.des
            local llCondition,cbPresentCount = findItemData(k - 1,key)
            if llCondition and cbPresentCount then
                if key ~= "LogonDays" then
                    llCondition = g_format:formatNumber(llCondition,g_format.fType.abbreviation,g_format.currencyType.GOLD)
                end
                text = string.format(text,llCondition,cbPresentCount)
            end
            local listView = self["listView"..k]
            local height = self.listSizes[k] or listView:getContentSize().height
            listView:setTouchEnabled(false)

            local panel = self:getNeetPanel(text)
            panel:setName("nowPanel")
            height = height + panel:getContentSize().height
            listView:insertCustomItem(panel,0)
           
            local size = listView:getInnerContainerSize()
            listView:setContentSize(cc.size(size.width,height))
            listView:setInnerContainerSize(cc.size(size.width,height))
            self.listSizes[k] = height
            if m == 1 then
                listView:refreshView()
            end
        end
    end
end

--得到需要克隆的面板
function TurnTableHelperLayer:getNeetPanel(textStr)
    local panel = self.clonePanel:clone()
    local panelText = panel:getChildByName("text")
    local titleImage = panel:getChildByName("titleImage")
    local text = ccui.Text:create()
    text:setFontName(panelText:getFontName())
    text:setFontSize(panelText:getFontSize())
    text:ignoreContentAdaptWithSize(true)
    text:setString(textStr)
    local width = text:getContentSize().width
    local lie = math.ceil(width / 1030)
    local sumHeight = lie * 39
    
    if lie > 1 then
        panelText:setContentSize(cc.size(1030,sumHeight))
    else
        panelText:setContentSize(cc.size(width,sumHeight))
    end
    
    panelText:setString(textStr)
    panelText:setPosition(cc.p(66.44,9))
    titleImage:setPositionY(9 + sumHeight -12)
    panel:setContentSize(cc.size(1106.00,sumHeight + 25))
    return panel
end

return TurnTableHelperLayer