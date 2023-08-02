
local ExternalFun = g_ExternalFun
local BankLayer=class("BankLayer",cc.Layer)

function BankLayer:ctor(GameView,closecallback)
    tlog("jxlw_BankLayer:ctor")
    self.gameView = GameView
    self.closecallback = closecallback
    self.csbNode = ExternalFun.loadCSB("bank/BankLayer.csb",self)
    self.csbNode:setPosition(display.cx,display.cy)
    ExternalFun.openLayerAction(self)
    
    function callback(sender)
        self:onSelectedEvent(sender)
    end
    appdf.getNodeByName(self.csbNode,"btnClose")
    :addClickEventListener(callback)
    appdf.getNodeByName(self.csbNode,"btnOk")
    :addClickEventListener(callback)
    appdf.getNodeByName(self.csbNode,"btnMax")
    :addClickEventListener(callback)

    local firstTip = self.csbNode:getChildByName("txtTxt")
    firstTip:setString("Saldo bancário")
    firstTip:setName("txtTxt1")
    self.csbNode:getChildByName("txtTxt"):setString("Feijões atuais")

    -- 金额输入
    self.edit_Score = self.csbNode:getChildByName("tfdGold"):convertToEditBox()
    self.edit_Score:setPlaceHolder("Introduza o montante do levantamento")   
    self.scoreText = self.csbNode:getChildByName("txtTips")
    -- 密码输入
    self.edit_Password = self.csbNode:getChildByName("tfdMiMa"):convertToEditBox()
    self.edit_Password:setPlaceHolder("Introduza o seu código de retirada")
    self.edit_Password:setPlaceholderFontColor(cc.c4b(193,103,232,255))
    self.edit_Password:setFontColor(cc.c4b(193,103,232,255))

    -- 进度
    local sdrValue = self.csbNode:getChildByName("sdrValue")
    self.sdrValue = sdrValue
    self.value = sdrValue:getChildByName("sprValue")
    self.value:setVisible(false)
    sdrValue:addEventListener(function(ref, eventType)
        self.value:setVisible(eventType ~= 2)
        local percent = sdrValue:getPercent()
        local s = percent/100*sdrValue:getContentSize().width
        self.value:setPositionX(s)
        self.value:getChildByName("txtValue"):setString(math.floor(percent).."%")
        self:setGold(math.floor(percent/100*GlobalUserItem.lUserInsure))
    end)
    -- 金额
    function self:setGold(gold)
        self.edit_Score:setString(gold)
        self.scoreText:setString(ExternalFun.numberTransiformEx(gold))
    end
    self.edit_Score:onReturn(nil,function()
         local num = tonumber(self.edit_Score:getString())
         if num == nil then
             self:setGold("0")
             return
         end
         if GlobalUserItem.lUserInsure > 0 then
             if num > GlobalUserItem.lUserInsure then
                 self:setGold(GlobalUserItem.lUserInsure)
                 sdrValue:setPercent(100)
                 return
             end
             local percent = num/GlobalUserItem.lUserInsure
             sdrValue:setPercent(percent*100)
             self:setGold(num)
         end
         self.scoreText:setString(ExternalFun.numberTransiformEx(num))
    end)

    self:refreshBankScore()
end

function BankLayer:onSelectedEvent(sender)
    local name = sender:getName()
    if name == "btnClose" then
        ExternalFun.closeLayerAction(self,function()
            self:removeSelf()
            if self.closecallback then
                self.closecallback()
            end
        end)
    elseif name == "btnOk" then
        -- 取款
        self:onTakeScore()
    elseif name == "btnMax" then
        if GlobalUserItem.lUserInsure == 0 then
            return
        end
        self.sdrValue:setPercent(100)
        self:setGold(GlobalUserItem.lUserInsure)
	end
end

--取款
function BankLayer:onTakeScore()
    -- 参数判断
    local szScore = string.gsub(self.edit_Score:getString(),"([^0-9])","")
    local szPass = self.edit_Password:getString()

    local runScene = cc.Director:getInstance():getRunningScene()
    local lOperateScore = tonumber(szScore)
    if lOperateScore < 1000 then 
        showToast("Não se pode retirar menos de 1000")
        return
    end

    if lOperateScore<1 then
        showToast("Introduza o montante correto!")
        return
    end

    if lOperateScore > GlobalUserItem.lUserInsure then
        showToast("Seu saldo bancário é insuficiente, introduza novamente o número de moedas!")
        return
    end

    if #szPass < 1 then 
        showToast("Introduza a sua senha bancária!")
        return
    end
    if #szPass <6 then
        showToast("A senha deve ser maior do que 6 caracteres, reintroduza-a!")
        return
    end

    if self.gameView.sendTakeScore then
        self.gameView:sendTakeScore(szScore,szPass)
    end
end

-- 刷新银行游戏币
function BankLayer:refreshBankScore()
    --携带游戏币
    local str = ""..GlobalUserItem.lUserScore
    if string.len(str) > 20 then
        str = string.sub(str, 1, 20)
    end
    self.csbNode:getChildByName("txtGold"):setString(g_format:formatNumber(str,g_format.fType.standard))

    --银行存款
    str = GlobalUserItem.lUserInsure..""
    if string.len(str) > 20 then
        str = string.sub(str, 1, 20)
    end
    self.csbNode:getChildByName("txtBankGold"):setString(g_format:formatNumber(str,g_format.fType.standard))

    self:setGold("0")
    self.edit_Password:setText("")
    self.sdrValue:setPercent(0)
end
------

-- 银行操作成功
function BankLayer:onBankSuccess(bank_success)
    if nil == bank_success then
        return
    end

    self:refreshBankScore()

    showToast(bank_success.szDescribrString)
end

-- 银行操作失败
function BankLayer:onBankFailure(bank_fail)
    if nil == bank_fail then
        return
    end

    showToast(bank_fail.szDescribeString)
end

-- 银行资料
function BankLayer:onGetBankInfo(bankinfo)
    bankinfo.wRevenueTake = bankinfo.wRevenueTake or 10
    -- local str = "温馨提示:取款将扣除" .. bankinfo.wRevenueTake .. "‰的手续费"
    -- if self.m_textTips==nil or tolua.isnull(self.m_textTips) then
    -- 	self.m_textTips=ccui.Text:create(str,"fonts/round_body.ttf",26)
    -- 					:addTo(self.bg)
    -- 					:setPosition(cc.p(300,177))
    --                     :setTextColor(cc.c4b(226,92,33,255))
    -- else
    -- 	self.m_textTips:setString(str)
    -- end
end

return BankLayer