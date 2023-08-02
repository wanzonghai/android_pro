---------------------------------------------------
--Desc:体现界面
---------------------------------------------------
local m_btn_num = 4
local CashOutLayer = class("CashOutLayer",function(args)
	local CashOutLayer =  display.newLayer()
    return CashOutLayer
end)
local CASH_ACCOUNT_CHECK = {
    {name = "cpf", max = 11, inputType = 1}, --11位数字
    {name = "cnpj", max = 14, inputType = 1}, --14位数字
    {name = "phone", max = 13, inputType = 1}, --13位数字
    {name = "email", max = 256, inputType = 3}, --256位字符串
    {name = "evp", max = 32, inputType = 2}, --32位字符串
}
function CashOutLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_WITHDRAW_STATUS_RESULT) 
    G_event:RemoveNotifyEvent(G_eventDef.NET_WITHDRAW_CASH_LIMIT_RESULT) 
    G_event:RemoveNotifyEvent(G_eventDef.NET_WITHDRAW_CONFIG_RESULT)  
    G_event:RemoveNotifyEvent(G_eventDef.NET_WITHDRAW_HISTORY_ACCOUNT_RESULT) 
    G_event:RemoveNotifyEventTwo(self, G_eventDef.NET_USER_SCORE_REFRESH)
    local Localization   = cc.UserDefault:getInstance()
    Localization:setStringForKey(GlobalUserItem.dwUserID .. "cardAccount",self.inputAcount:getString())
    Localization:setStringForKey(GlobalUserItem.dwUserID .. "userName",self.inputName:getString())
    Localization:setStringForKey(GlobalUserItem.dwUserID .. "cpfInfo",self.inputCpf:getString())
end
function CashOutLayer:ctor(args)
    tlog("CashOutLayer:ctor")
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)    
    self.quitCallback = args and args.quitCallback
    self.productIdx = 0 --选择提现额度序号
    self.goldList = {} --提现额度列表
    self.cashOutInfo = nil --提现信息汇总
    self.cashLimit = nil --提现金额限制
    self.inputValue = nil --输入的金额
    self.min_value = 50 --最低金额
    self.max_value = 2000 --最高金额
    self.accountIdx = cc.UserDefault:getInstance():getIntegerForKey("withdraw_accountIdx", 1) --账号类型序号
    self:setName("CashOutLayer")
    local bgLayer = display.newLayer()
    bgLayer:addTo(self)
    bgLayer:enableClick()
    
    local csbNode = g_ExternalFun.loadCSB("cashOut/CashOutLayer.csb")
    csbNode:setContentSize(display.width,display.height)
    csbNode:setAnchorPoint(cc.p(0.5,0.5))
    csbNode:setPosition(display.cx,display.cy)
    self:addChild(csbNode)    
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    local bg = csbNode:getChildByName("bg")
    g_ExternalFun.adapterScreen(bg)
    self.bgSpine = sp.SkeletonAnimation:create("client/res/cashOut/spine/tixian.json","client/res/cashOut/spine/tixian.atlas", 1)
    self.bgSpine:addTo(bg)
    self.bgSpine:setPosition(0, 0)
    self.bgSpine:setAnimation(0, "daiji", true)
   
    --左上
    self.PanelLeft = csbNode:getChildByName("Panel_left")
    --右上
    self.PanelRight = csbNode:getChildByName("Panel_right")
    --中间
    self.PanelCenter = csbNode:getChildByName("Panel_content"):getChildByName("Panel_center")
    --额度
    self.PanelEdu = self.PanelCenter:getChildByName("Panel_edu")
    --pix
    self.PanelPix = self.PanelCenter:getChildByName("Panel_pix")
    --name
    self.PanelName = self.PanelCenter:getChildByName("Panel_name")
    --cpf
    self.PanelCpf = self.PanelCenter:getChildByName("Panel_cpf")
    self.recommendText = self.PanelPix:getChildByName("recommendText")
    --适配性调整Panel大小
    --self:adjustPanelSize()
    ccui.Helper:doLayout(csbNode)
    self.btnConfirm = self.PanelCenter:getChildByName("btn_confirm")
      --格式提示
      self.btnWarnAcount = self.PanelPix:getChildByName("btn_warn")
      self.btnWarnAcount:setVisible(true)

        --格式提示
    self.btnWarnName = self.PanelName:getChildByName("btn_warn")
    self.btnWarnName:setVisible(true)
   --格式提示
   self.btnWarnCpf = self.PanelCpf:getChildByName("btn_warn")
   self.btnWarnCpf:setVisible(true)
   --姓名输入
   self.inputName = self.PanelName:getChildByName("inputPsd1"):convertToEditBox()
    --[[self.btnConfirm:addTouchEventListener(function ()
        self:btnConfirmClick()
    end)--]]
    self.btnConfirm:addTouchEventListener(handler(self, self.onConfirmClickedEvent))
     --cpf输入
     self.inputCpf = self.PanelCpf:getChildByName("inputPsd1"):convertToEditBox(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    --返回
     --确认按钮spine动画
     local spineBg = self.btnConfirm:getChildByName("spine_confirm")
     self.btnSpine = sp.SkeletonAnimation:create("client/res/cashOut/spine/anniu.json","client/res/cashOut/spine/anniu.atlas", 1)
     self.btnSpine:addTo(spineBg)
     self.btnSpine:setPosition(0, 0)
     self.btnSpine:setAnimation(0, "zhihui", true)
 
    self.mm_btnBack = self.PanelRight:getChildByName("close_btn")
    self.mm_btnBack:onClicked(function() 
        local callback = function()
            if self.quitCallback then
                self.quitCallback()
            end
            self:removeSelf()
        end
        callback()
        --self:EaseHide(callback)
    end,true)
    --记录
    local btn_record = self.PanelRight:getChildByName("record_btn")
    btn_record:addClickEventListener(function ()
        local historyLayer = self:getChildByName("CashOutHistoryLayer")
        if not historyLayer then
            local CashOutHistoryLayer = appdf.req("client.src.UIManager.hall.subinterface.CashOutHistoryLayer")
            historyLayer = CashOutHistoryLayer:create():addTo(self, 11)
            historyLayer:setPosition(display.width * 0.5 - g_offsetX, display.height * 0.5)
            historyLayer:setName("CashOutHistoryLayer")
        end
    end)
    --客服
    local btn_kefu = self.PanelRight:getChildByName("kefu_btn")
    btn_kefu:addClickEventListener(function ()
        G_event:NotifyEvent(G_eventDef.UI_OPEN_SERVICELAYER)
    end)
    --帮助
    local btn_help = self.PanelRight:getChildByName("help_btn")
    btn_help:addClickEventListener(function ()
        self:showHelpDialog()
    end)
    self.PanelEdu:getChildByName("Image_select"):setVisible(false)
    --额度按钮
    for i=1,6 do
        local btn_edu = self.PanelEdu:getChildByName("btn_edu"..i)
        btn_edu:addClickEventListener(function ()
            self.productIdx = i
            self.PanelEdu:getChildByName("Image_select"):setVisible(true)
            self.PanelEdu:getChildByName("Image_select"):setPositionX(btn_edu:getPositionX())

            local pItem = self.goldList[self.productIdx]
            self.inputValue = math.modf(pItem.dwPrice/100)
            self.inputScore:setString(self.inputValue)
            self:updateConfirmBtn()
        end)
    end
    --选择账号按钮
    local btn_acount = self.PanelPix:getChildByName("btn_acount")
    btn_acount:addClickEventListener(function ()
        if self.cashOutInfo then
            self:showAccountDialog()
        end
    end)
    
    --账户类型名
    self.curAccountName = self.PanelPix:getChildByName("text_total_num")
    self.accountExample = self.PanelPix:getChildByName("text_example")
  

    self.inputScore = self.PanelEdu:getChildByName("Image_input_bg"):getChildByName("inputScore"):convertToEditBox(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.inputScore:setPlaceholderFontColor(cc.c3b(201,176,38))--(cc.c3b(190,89,121))
    self.inputScore:setFontColor(cc.c4b(251,225,170,255))
    self.inputScore:registerScriptEditBoxHandler(function(eventType, pObj)
        tlog("self.inputScore:registerScriptEditBoxHandler",eventType)
        if eventType == "return" or eventType == "ended" then
            --local text = self.inputScore:getString()
            self:checkInputScore()
            self:updateConfirmBtn()
        elseif eventType == "began" then
        end
    end)

    self.inputAcount = self.PanelPix:getChildByName("inputPsd1"):convertToEditBox()
    self.inputAcount:setPlaceholderFontColor(cc.c3b(190,89,121))
    self.inputAcount:setFontColor(cc.c4b(251,225,170,255))
    self.inputAcount:registerScriptEditBoxHandler(function(eventType, pObj)
        tlog("self.inputAcount:registerScriptEditBoxHandler",eventType)
        if eventType == "return" or eventType == "ended" then
            local text = self.inputAcount:getString()
            print("jaldsfjaodfjoa111", text)
            if self:checkAccountValid(text) then
                self.btnWarnAcount:setVisible(false)
            else
                self.btnWarnAcount:setVisible(true)
            end
            self:updateConfirmBtn()
        elseif eventType == "began" then
        end
    end)
    --[[self.inputAcount:addEventListener(function(sender, eventType)
        tlog("self.inputAcount:addClickEventListener",eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
            local text = self.inputAcount:getString()
            print("jaldsfjaodfjoa111", text)
            if self:checkAccountValid(text) then
                self.btnWarnAcount:setVisible(false)
            else
                self.btnWarnAcount:setVisible(true)
            end
            self:updateConfirmBtn()
        end
    end)--]]
    --清除账号输入
    self.btnClearAcount = self.PanelPix:getChildByName("btn_clear")
    self.btnClearAcount:addClickEventListener(function ()
        self.inputAcount:setString("")
        self.btnWarnAcount:setVisible(true)
        self:updateConfirmBtn()
    end)
  
   

    self.inputName:setPlaceholderFontColor(cc.c3b(190,89,121))
    self.inputName:setFontColor(cc.c4b(251,225,170,255))
    self.inputName:registerScriptEditBoxHandler(function(eventType, pObj)
        tlog("self.inputName:registerScriptEditBoxHandler",eventType)
        if eventType == "return" or eventType == "ended" then
            local text = self.inputName:getString()
            if StringUtil.getStringLen(text) <= 256 and StringUtil.getStringLen(text) > 0 then
                self.btnWarnName:setVisible(false)
            else
                self.btnWarnName:setVisible(true)
            end
            self:updateConfirmBtn()
        elseif eventType == "began" then
        end
    end)
    --清除姓名输入
    self.btnClearName = self.PanelName:getChildByName("btn_clear")
    self.btnClearName:addClickEventListener(function ()
        self.inputName:setString("")
        self.btnWarnName:setVisible(true)
        self:updateConfirmBtn()
    end)
 
   
  

    self.inputCpf:setPlaceholderFontColor(cc.c3b(190,89,121))
    self.inputCpf:setFontColor(cc.c4b(251,225,170,255))
    self.inputCpf:registerScriptEditBoxHandler(function(eventType, pObj)
        tlog("self.inputCpf:registerScriptEditBoxHandler",eventType)
        if eventType == "return" or eventType == "ended" then
            local text = self.inputCpf:getString()
            if (StringUtil.inputCheckOfNumber(text) and StringUtil.getStringLen(text) == 11) then
                self.btnWarnCpf:setVisible(false)
            else
                self.btnWarnCpf:setVisible(true)
            end
            self:updateConfirmBtn()
        elseif eventType == "began" then
        end
    end)
    --清除cpf输入
    self.btnClearCpf = self.PanelCpf:getChildByName("btn_clear")
    self.btnClearCpf:addClickEventListener(function ()
        self.inputCpf:setString("")
        self.btnWarnCpf:setVisible(true)
        self:updateConfirmBtn()
    end)
    --确认按钮
    self.lastClickTick = 0
    
   
    --提示信息
    self.text_help = self.PanelCenter:getChildByName("Image_tip"):getChildByName("Panel_tip"):getChildByName("text_help")


    self:EaseShow()   
        
    G_event:AddNotifyEvent(G_eventDef.NET_WITHDRAW_STATUS_RESULT,handler(self,self.onCashOutInfoResult))   --同步提现信息结果
    G_event:AddNotifyEvent(G_eventDef.NET_WITHDRAW_CASH_LIMIT_RESULT,handler(self,self.onGetWithdrawCashLimitResult))   --获取提现金额限制
    G_event:AddNotifyEvent(G_eventDef.NET_WITHDRAW_CONFIG_RESULT,handler(self,self.onCashOutGoldResult))   --提现额度列表返回
    G_event:AddNotifyEvent(G_eventDef.NET_WITHDRAW_HISTORY_ACCOUNT_RESULT,handler(self,self.onWithdrawHistoryAcountResult))   --提现历史账号返回
    G_event:AddNotifyEventTwo(self, G_eventDef.NET_USER_SCORE_REFRESH, handler(self,self.updateUserInsure))
    

    G_ServerMgr:C2S_GetWithdrawStatus()         --提现额度列表
    G_ServerMgr:C2S_GetWithdrawCashLimit()         --获取提现金额限制

    showNetLoading()    
end

-- if self.cashOutInfo.lCurrentBetScore >= self.cashOutInfo.lRequireBetScore then
--     if GlobalUserItem.lUserInsure >= self.goldList[i].lAwardValue then
function CashOutLayer:checkInputScore()
    local text = self.inputScore:getString()
    local value = tonumber(text)
    if value == nil then
        self.inputValue = nil
        self.productIdx = 0
        self.inputScore:setString("")
        self.PanelEdu:getChildByName("Image_select"):setVisible(false)
        return
    end
    value = math.modf(value)
    if value * 100 > GlobalUserItem.lUserInsure then
        value = math.modf(GlobalUserItem.lUserInsure/100)
    end

    if value > self.max_value then
        value = self.max_value
    end
    self.inputValue = value
    self.inputScore:setString(self.inputValue)
    self.productIdx = 0
    self.PanelEdu:getChildByName("Image_select"):setVisible(false)
end

function CashOutLayer:updateTanHao()
    --账号输入
    local Localization   = cc.UserDefault:getInstance()
    local inputAccount = Localization:getStringForKey(GlobalUserItem.dwUserID .. "cardAccount","")
    if inputAccount ~= "" then
        self.inputAcount:setString(inputAccount)
    end
    if self:checkAccountValid(inputAccount) then
        self.btnWarnAcount:setVisible(false)
    else
        self.btnWarnAcount:setVisible(true)
    end

     
    local inputUserName = Localization:getStringForKey(GlobalUserItem.dwUserID .. "userName","")
    if inputUserName ~= "" then
        self.inputName:setString(inputUserName)
    end
    if StringUtil.getStringLen(inputUserName) <= 256 and StringUtil.getStringLen(inputUserName) > 0 then
        self.btnWarnName:setVisible(false)
    else
        self.btnWarnName:setVisible(true)
    end

    local inputCpfInfo = Localization:getStringForKey(GlobalUserItem.dwUserID .. "cpfInfo","")
    if inputCpfInfo ~= "" then
        self.inputCpf:setString(inputCpfInfo)
    end

    if (StringUtil.inputCheckOfNumber(inputCpfInfo) and StringUtil.getStringLen(inputCpfInfo) == 11) then
        self.btnWarnCpf:setVisible(false)
    else
        self.btnWarnCpf:setVisible(true)
    end
    self:updateConfirmBtn()
end

--适配性调整Panel大小
function CashOutLayer:adjustPanelSize()
    tlog("CashOutLayer:adjustPanelSize")
    --左中指导性尺寸
    self.LeftCenterMin = 446
    self.LeftCenterMax = 650
    
    --左中比例
    self.LeftCenterPercent = 446/1920
    
    --获取屏幕宽度
    local pWidth = display.width
    if pWidth <= 1920 then
        --屏幕宽度小于设计尺寸
        --左中走最小尺寸
        self.PanelLeftCenter:setContentSize(cc.size(self.LeftCenterMin,1080))
    else
        --屏幕宽度超过设计尺寸
        local pAbelLeftCenterWidth = math.min(pWidth*self.LeftCenterPercent,self.LeftCenterMax)
        self.PanelLeftCenter:setContentSize(cc.size(pAbelLeftCenterWidth,1080))
    end    
end

--缓入
function CashOutLayer:EaseShow(callback)
    --[[local pCostTime = 0.3
    local pDeltaTime = 0.08    
    --左上
    self.PanelLeftTop:setPositionY(display.height+160)
    TweenLite.to(self.PanelLeftTop,pCostTime,{ y=display.height,ease = Cubic.easeInOut})
    --左中
    local pSize = self.PanelLeftCenter:getContentSize()
    self.PanelLeftCenter:setPositionX(-pSize.width)
    TweenLite.to(self.PanelLeftCenter,pCostTime,{ x=0,ease = Cubic.easeInOut})
    --右中
    self.PanelRightCenter:setPositionX(display.width+2560/2)    
    TweenLite.to(self.PanelRightCenter,pCostTime/2,{ x=display.cx,ease = Cubic.easeInOut})
    --表皮
    self.PanelPre:setPositionX(display.width+2560/2)    
    TweenLite.to(self.PanelPre,pCostTime/2,{ x=display.cx,ease = Cubic.easeInOut})

    g_paoMaDeng:setPMDOffset(cc.p(0,-85))--]]
end

--缓出
function CashOutLayer:EaseHide(callback)    
    --[[local pCostTime = 0.3
    local pDeltaTime = 0.08    
    --左上
    TweenLite.to(self.PanelLeftTop,pCostTime,{ y=display.height+160,ease = Cubic.easeInOut})    
    --左中
    local pSize = self.PanelLeftCenter:getContentSize()
    TweenLite.to(self.PanelLeftCenter,pCostTime,{ x=-pSize.width,ease = Cubic.easeInOut})
    --右中
    TweenLite.to(self.PanelRightCenter,pCostTime,{ x=display.cx+2560,ease = Cubic.easeInOut})    
    --表皮
    TweenLite.to(self.PanelPre,pCostTime,{ x=display.cx+2560,ease = Cubic.easeInOut,onComplete =callback}) --]]   
end
--判断输入是否正确
function CashOutLayer:checkAccountValid(checkStr)
    tlog("CashOutLayer:checkAccountValid", checkStr)
    local isValid = false
    if self.cashOutInfo then
        local acountTypeName = self.cashOutInfo.accountTypeTb[self.accountIdx]
        tlog("CashOutLayer:checkAccountValid222", acountTypeName)
        local checkInfo = nil
        for i=1,#CASH_ACCOUNT_CHECK do
            if CASH_ACCOUNT_CHECK[i].name == acountTypeName then
                checkInfo = CASH_ACCOUNT_CHECK[i]
                break
            end
        end  
        if checkInfo then
            print("jaldsfjaodfjoa222", checkStr)
            if checkInfo.inputType == 1 then
                print("jaldsfjaodfjoa333", checkStr, StringUtil.getStringLen(checkStr), checkInfo.max)
                if StringUtil.inputCheckOfNumber(checkStr) and StringUtil.getStringLen(checkStr) == checkInfo.max then
                    print("jaldsfjaodfjoa444", checkStr, StringUtil.getStringLen(checkStr), checkInfo.max)
                    isValid = true
                end
            elseif checkInfo.inputType == 2 then
                print("jaldsfjaodfjoa555", checkStr, StringUtil.getStringLen(checkStr), checkInfo.max)
                if StringUtil.inputCheckOfAscii(checkStr) and StringUtil.getStringLen(checkStr) == checkInfo.max then
                    print("jaldsfjaodfjoa666", checkStr, StringUtil.getStringLen(checkStr), checkInfo.max)
                    isValid = true
                end
            elseif checkInfo.inputType == 3 then
                print("jaldsfjaodfjoa777", checkStr, StringUtil.getStringLen(checkStr), checkInfo.max)
                if StringUtil.inputCheckOfAscii(checkStr) and StringUtil.getStringLen(checkStr) <= checkInfo.max and StringUtil.getStringLen(checkStr) > 0 then
                    print("jaldsfjaodfjoa888", checkStr, StringUtil.getStringLen(checkStr), checkInfo.max)
                    isValid = true
                end
            end
        end
    end
    return isValid
end
--更新确认按钮状态
function CashOutLayer:updateConfirmBtn()
    tlog("CashOutLayer:updateConfirmBtn")
    if self.btnWarnAcount:isVisible() or self.btnWarnName:isVisible() or self.btnWarnCpf:isVisible() 
        or self.inputAcount:getString() == "" or self.inputName:getString() == "" or self.inputCpf:getString() == ""
        or self.inputValue == nil or self.inputValue < self.min_value or self.inputValue > self.max_value then
        --self.btnConfirm:setVisible(false)
        -- if self.productIdx == 0 then
        --     self.btnConfirm:setTouchEnabled(true)
        -- else
        --     self.btnConfirm:setTouchEnabled(false)
        -- end
        self.btnConfirm:setTouchEnabled(true)
--[[        self.btnConfirm:loadTextureNormal("client/res/cashOut/image/tx_an0.png")
        self.btnConfirm:loadTexturePressed("client/res/cashOut/image/tx_an0.png")
        self.btnConfirm:loadTextureDisabled("client/res/cashOut/image/tx_an0.png")--]]
        self.btnSpine:setAnimation(0, "zhihui", true)
    else
        --self.btnConfirm:setVisible(true)
        self.btnConfirm:setTouchEnabled(true)
--[[        self.btnConfirm:loadTextureNormal("client/res/cashOut/image/tx_an.png")
        self.btnConfirm:loadTexturePressed("client/res/cashOut/image/tx_an.png")
        self.btnConfirm:loadTextureDisabled("client/res/cashOut/image/tx_an.png")--]]
        self.btnSpine:setAnimation(0, "daiji", true)
    end
end
--更新金币信息
function CashOutLayer:updateUserGold()
    tlog("CashOutLayer:updateUserGold")
    if self.cashOutInfo then
        self.PanelLeft:getChildByName("text_total"):setString(g_format:formatNumber(GlobalUserItem.lUserInsure, g_format.fType.standard))
        if self.cashOutInfo.lCurrentBetScore >= self.cashOutInfo.lRequireBetScore then
            self.PanelLeft:getChildByName("text_out"):setString(g_format:formatNumber(GlobalUserItem.lUserInsure, g_format.fType.standard))
        else
            self.PanelLeft:getChildByName("text_out"):setString(g_format:formatNumber(0, g_format.fType.standard))
        end
    end
end
--账号信息
function CashOutLayer:updateSaveAccount()
    tlog("CashOutLayer:updateSaveAccount")
    if self.cashOutInfo then
        local saveInfos = self.cashOutInfo.saveInfos
        local acountTypeName = self.cashOutInfo.accountTypeTb[self.accountIdx]
        local acountTypeTb = saveInfos[acountTypeName]
        if string.upper(acountTypeName) == "CPF" then
            self.recommendText:show()
        else
            self.recommendText:hide()
        end
        self.curAccountName:setString(string.upper(acountTypeName))
        if acountTypeName == "cpf" or acountTypeName == "CPF" then
            self.accountExample:setString("Pix conta"..g_language:getString("cashout_example1"))
        elseif acountTypeName == "cnpj" or acountTypeName == "CNPJ" then
            self.accountExample:setString("Pix conta"..g_language:getString("cashout_example2"))
        elseif acountTypeName == "phone" or acountTypeName == "PHONE" then
            self.accountExample:setString("Pix conta"..g_language:getString("cashout_example3"))
        elseif acountTypeName == "email" or acountTypeName == "EMAIL" then
            self.accountExample:setString("Pix conta"..g_language:getString("cashout_example4"))
        elseif acountTypeName == "evp" or acountTypeName == "EVP" then
            self.accountExample:setString("Pix conta"..g_language:getString("cashout_example5"))
        else
            self.accountExample:setString("Pix conta")
        end
        if acountTypeName and acountTypeTb then
            self.inputAcount:setString(acountTypeTb[#acountTypeTb].acountNum)
            self.inputName:setString(acountTypeTb[#acountTypeTb].acountName)
            self.inputCpf:setString(acountTypeTb[#acountTypeTb].cpfNum)
            self.btnWarnAcount:setVisible(false)
            self.btnWarnName:setVisible(false)
            self.btnWarnCpf:setVisible(false)
        else
            -- self.inputAcount:setString("")
            -- self.inputName:setString("")
            -- self.inputCpf:setString("")
            self.btnWarnAcount:setVisible(true)
            self.btnWarnName:setVisible(true)
            self.btnWarnCpf:setVisible(true)
        end
    end

end
--同步提现信息结果
function CashOutLayer:onCashOutInfoResult(cmdData)
    dump("CashOutLayer:onCashOutInfoResult")
   -- dump(cmdData)

    self.cashOutInfo = cmdData

    self:updateUserGold()
    G_ServerMgr:C2S_GetWithdrawConfig()
end

--获取提现金额限制返回
function CashOutLayer:onGetWithdrawCashLimitResult(cmdData)
    dump("CashOutLayer:onGetWithdrawCashLimitResult")
    self.cashLimit = cmdData or {}
    self.min_value = (self.cashLimit.llMin or 50*100) /100 
    self.max_value = (self.cashLimit.llMax or 2000*100) /100 
    local str = string.format("Digite o valor(R$%s-R$%s)",self.min_value,self.max_value)
    self.inputScore:setPlaceHolder(str)
end

--提现额度列表返回
function CashOutLayer:onCashOutGoldResult(cmdData)
    tlog("CashOutLayer:onCashOutGoldResult")
   -- dump(cmdData)
    G_ServerMgr:C2S_GetWithdrawHistoryAccount()
    self.PayUrl = cmdData.outUrl
    if self.cashOutInfo then
        self.cashOutInfo.accountTypeTb = cmdData.accountTypeTb
        self.goldList = cmdData.goldList
        local totalBtn = 0
        --额度按钮
        for i=1,m_btn_num do
            local btn_edu = self.PanelEdu:getChildByName("btn_edu"..i)
            if self.goldList[i] then
                btn_edu:setVisible(true)
                --btn_edu:setTitleText(g_format:formatNumber(self.goldList[i].lAwardValue,g_format.fType.standard,g_format.currencyType.GOLD))
                btn_edu:getChildByName("BFLabel_edu"):setString(g_format:formatNumber(self.goldList[i].lAwardValue, g_format.fType.Custom_1))
                totalBtn = totalBtn + 1
                if self.cashOutInfo.lCurrentBetScore >= self.cashOutInfo.lRequireBetScore then
                    if GlobalUserItem.lUserInsure >= self.goldList[i].lAwardValue then
                        btn_edu:getChildByName("Image_mask"):setVisible(false)
                        btn_edu:setTouchEnabled(true)
                    else
                        btn_edu:getChildByName("Image_mask"):setVisible(true)
                        btn_edu:setTouchEnabled(false)
                    end
                else
                    btn_edu:getChildByName("Image_mask"):setVisible(true)
                    btn_edu:setTouchEnabled(false)
                end
            else
                btn_edu:setVisible(false)
            end
        end
        local panelW = self.PanelEdu:getContentSize().width
        local btnW = panelW/2/m_btn_num + 10
        local startx = panelW - (totalBtn*btnW) + btnW/2 - 10--panelW/2 - (totalBtn*panelW/6)/2 + panelW/6/2
        for i=1,totalBtn do
            local btn_edu = self.PanelEdu:getChildByName("btn_edu"..i)
            btn_edu:setPositionX(startx + (i-1)*btnW)
        end
        --扣除手续费提示
        if #self.goldList > 0 then
            local tipStr = string.format(g_language:getString("cashout_tip"), tostring(self.goldList[1].lAttachValue).."%")
            self.text_help:setString(tipStr)
            local totalw = self.text_help:getContentSize().width
            local bgw = self.PanelCenter:getChildByName("Image_tip"):getChildByName("Panel_tip"):getContentSize().width
            self.text_help:stopAllActions()
            local moveTime = (totalw-bgw)*0.02
            if totalw > bgw then
                local sequence = cc.Sequence:create(
                    cc.DelayTime:create(2.0), 
                    cc.MoveTo:create(moveTime, cc.p(bgw-totalw, 50)),
                    cc.DelayTime:create(2.0),
                    cc.CallFunc:create(function()
                        self.text_help:setPositionX(0)
                    end)
                )
                local action = cc.RepeatForever:create(sequence)
                self.text_help:runAction(action)
            end
        end
    end
end
--提现历史账号返回
function CashOutLayer:onWithdrawHistoryAcountResult(cmdData)
    tlog("CashOutLayer:onWithdrawHistoryAcountResult")
   -- dump(cmdData, "onWithdrawHistoryAcountResult222", 9)
    if self.cashOutInfo then
        self.cashOutInfo.saveInfos = cmdData.saveInfos
        self:updateSaveAccount()
        self:updateConfirmBtn()
        self:updateTanHao()
    end
    dismissNetLoading()
end
--刷新银行金币数量
function CashOutLayer:updateUserInsure()
    print("CashOutLayer:updateUserInsure", GlobalUserItem.lUserInsure)
    self:updateUserGold()
    if self.cashOutInfo then
        --额度按钮
        for i=1,m_btn_num do
            local btn_edu = self.PanelEdu:getChildByName("btn_edu"..i)
            if self.goldList[i] then
                btn_edu:setVisible(true)
                if self.cashOutInfo.lCurrentBetScore >= self.cashOutInfo.lRequireBetScore then
                    if GlobalUserItem.lUserInsure >= self.goldList[i].lAwardValue then
                        btn_edu:getChildByName("Image_mask"):setVisible(false)
                        btn_edu:setTouchEnabled(true)
                    else
                        btn_edu:getChildByName("Image_mask"):setVisible(true)
                        btn_edu:setTouchEnabled(false)
                    end
                else
                    btn_edu:getChildByName("Image_mask"):setVisible(true)
                    btn_edu:setTouchEnabled(false)
                end
            else
                btn_edu:setVisible(false)
            end
        end
    end
end
--展示账号类型弹出框
function CashOutLayer:showAccountDialog()
    if (self.accountDialog and not tolua.isnull(self.accountDialog)) then
        print("ajsdfoajdsfoajdfs111")
        self.accountDialog:removeFromParent()
    else
        local accountTypeTb = self.cashOutInfo.accountTypeTb
        local accountTypeNum = #accountTypeTb
        local btn_acount = self.PanelPix:getChildByName("btn_acount")
        local pos = cc.p(btn_acount:getPositionX(), btn_acount:getPositionY())
        local btnPos = btn_acount:getParent():convertToWorldSpace(pos)
        local imgPos = cc.p(btnPos.x-29, btnPos.y-15)
        local bgLayer = display.newLayer()
        bgLayer:addTo(self)
        print("ajsdfoajdsfoajdfs222", imgPos.x, imgPos.y)
        self.accountDialog = bgLayer
        local bgImg = ccui.ImageView:create("client/res/cashOut/GUI/tx_xl.png", ccui.TextureResType.plistType)
        bgImg:setScale9Enabled(true)
        bgImg:setCapInsets({x = 120, y = 40, width = 12, height = 8})
        bgImg:setContentSize(253, 88+6+72*(accountTypeNum-1))--为什么是6因为原图中间褐色部分是66，72-66=6
        bgImg:addTo(bgLayer)
        bgImg:setAnchorPoint(1, 1)
        bgImg:setPosition(imgPos)
        for i=1,accountTypeNum do
            local acountTypeName = string.upper(self.cashOutInfo.accountTypeTb[i])
            local btnSelect = ccui.Button:create()
            btnSelect:ignoreContentAdaptWithSize(false)
            btnSelect:setContentSize(cc.size(253,72))
            btnSelect:addTo(bgImg)
            btnSelect:setAnchorPoint(0.5, 1)
            btnSelect:setPosition(bgImg:getContentSize().width/2, bgImg:getContentSize().height-16-72*(i-1))--为什么-16，因为原图上面空白部分是16
            btnSelect:addClickEventListener( function ()
                self.accountIdx = i
                self:updateSaveAccount()
                self:updateConfirmBtn()
                self.accountDialog = nil
                bgLayer:removeFromParent()
            end )
            --btnSelect:setPressedActionEnabled(true)
            local accountText = ccui.Text:create("","base/res/fonts/arial.ttf",36)
            --local accountText = cc.LabelBMFont:create("0", "GUI/num_pic/shuijingfenshu.fnt")
            
            accountText:setPosition(btnSelect:getContentSize().width/2, btnSelect:getContentSize().height/2)
            accountText:addTo(btnSelect)
            accountText:setString(acountTypeName)
            if acountTypeName == "CPF" or acountTypeName == "CNPJ" then
                btnSelect:setEnabled(true)
                accountText:setTextColor(cc.c3b(251,225,170))
            else
                btnSelect:setEnabled(false)
                accountText:setTextColor(cc.c3b(127,127,127))
            end
            if i < accountTypeNum then
                local lineImg = ccui.ImageView:create("client/res/cashOut/GUI/tx_xl1.png", ccui.TextureResType.plistType)
                lineImg:addTo(btnSelect)
                lineImg:setPosition(btnSelect:getContentSize().width/2, 0)
            end
        end
    end
end
--展示帮助弹出框
function CashOutLayer:showHelpDialog()
    if (self.helpDialog and not tolua.isnull(self.helpDialog)) then
        self.helpDialog:removeFromParent()
    else
        local bgLayer = display.newLayer()
        bgLayer:addTo(self)
        bgLayer:enableClick(function()
            bgLayer:removeFromParent()
        end)
        self.helpDialog = bgLayer
        local csbNode = g_ExternalFun.loadCSB("cashOut/OutHelpLayer.csb")
        csbNode:setAnchorPoint(cc.p(0.5,0.5))
        csbNode:setPosition(display.cx,display.cy)
        csbNode:addTo(bgLayer) 
        csbNode:getChildByName("btn_close"):addClickEventListener( function ()
            bgLayer:removeFromParent()
        end )
        csbNode:getChildByName("btn_close"):setPressedActionEnabled(true)
        csbNode:getChildByName("btn_close"):setVisible(false)
        csbNode:getChildByName("btn_sure"):addClickEventListener( function ()
            bgLayer:removeFromParent()
        end )
        csbNode:getChildByName("btn_sure"):setPressedActionEnabled(true)
    end
end
--展示提交后提示弹出框
function CashOutLayer:showRemindDialog()
    if (self.remindDialog and not tolua.isnull(self.remindDialog)) then
        self.remindDialog:removeFromParent()
    else
        local bgLayer = display.newLayer()
        bgLayer:addTo(self)
        bgLayer:enableClick()
        self.remindDialog = bgLayer
        local csbNode = g_ExternalFun.loadCSB("cashOut/OutRemindLayer.csb")
        csbNode:setAnchorPoint(cc.p(0.5,0.5))
        csbNode:setPosition(display.cx,display.cy)
        csbNode:addTo(bgLayer) 
        csbNode:getChildByName("btn_close"):addClickEventListener( function ()
            bgLayer:removeFromParent()
        end )
        csbNode:getChildByName("btn_close"):setPressedActionEnabled(true)
        csbNode:getChildByName("btn_sure"):addClickEventListener( function ()
            bgLayer:removeFromParent()
        end )
        csbNode:getChildByName("btn_sure"):setPressedActionEnabled(true)
    end
end

--确认按钮点击事件
function CashOutLayer:onConfirmClickedEvent(_sender, _eventType)
    tlog('CashOutLayer:onConfirmClickedEvent')
    if _eventType == ccui.TouchEventType.began then
        self.m_touchBegan = true
        --self.m_touchTick = tickMgr:getTime()
        self.btnSpine:setScale(1.02)
    elseif _eventType == ccui.TouchEventType.canceled then
        --_sender:stopAllActions()
        self.btnSpine:setScale(1.0)
    elseif _eventType == ccui.TouchEventType.ended then
        if self.m_touchBegan then
            self.m_touchBegan = false
            local curTick = tickMgr:getTime()
            if curTick - self.lastClickTick > 0.5 then
                self.lastClickTick = curTick
                -- if self.productIdx == 0 then   
                --     if not self.inputValue or self.inputValue < self.min_value or self.inputValue > self.max_value then
                --         return
                --     end
                --     if self.cashOutInfo and self.cashOutInfo.lRequireBetScore then
                --         local needNum = self.cashOutInfo.lRequireBetScore - self.cashOutInfo.lCurrentBetScore
                --         local needStr = g_format:formatNumber(needNum, g_format.fType.Custom_1)
                --         local tipStr = string.format(g_language:getString("cashout_tip2"), needStr)
                --         showToast(tipStr)
                --     end
                -- else
                --     self:checkWhetherRecharge()             --核对是否充值
                -- end
                self:onConfirmClicked()
                --self:GetLastWithdrawRecord()
                --self:showDialog()
            end
        end
        self.btnSpine:setScale(1.0)
    end
end

function CashOutLayer:onConfirmClicked()
    if self.cashOutInfo and self.cashOutInfo.lRequireBetScore then
        if self.cashOutInfo.lCurrentBetScore >= self.cashOutInfo.lRequireBetScore then
            if GlobalUserItem.lUserInsure < self.min_value then --金币存入银行才能提现，最低50
                local txt = "As moedas de ouro só podem ser sacadas após serem depositadas no banco, com um valor mínimo de R$"..self.min_value.."."

                local pData = {
                    msg = txt,
                    callback = function(click)
                        if click == "ok" then      
                            G_event:NotifyEvent(G_eventDef.UI_SHOW_BANKLAYER_NEW)
                            self:removeSelf()
                        end					
                    end
                }
                G_event:NotifyEvent(G_eventDef.UI_OPEN_COMMON_DIALOG,pData)
                return
            end
            if self.productIdx == 0 and (not self.inputValue or self.inputValue < self.min_value or self.inputValue > self.max_value) then
                local tipStr = string.format("Digite o valor(R$%s-R$%s)",self.min_value,self.max_value)
                showToast(tipStr)
                return
            end
            if self.btnWarnAcount:isVisible() or self.btnWarnName:isVisible() or self.btnWarnCpf:isVisible() 
                or self.inputAcount:getString() == "" or self.inputName:getString() == "" or self.inputCpf:getString() == "" then
                local tipStr = "A informação não foi preenchida completamente." --信息未填完整
                showToast(tipStr)
                return
            end
            self:checkWhetherRecharge()             --核对是否充值
        else
            local needNum = self.cashOutInfo.lRequireBetScore - self.cashOutInfo.lCurrentBetScore
            local needStr = g_format:formatNumber(needNum, g_format.fType.Custom_1)
            local tipStr = string.format(g_language:getString("cashout_tip2"), needStr)
            showToast(tipStr)
        end
    end
end

--核对是否充值
function CashOutLayer:checkWhetherRecharge()
    G_event:AddNotifyEvent(G_eventDef.CASH_CHECKRETURN, handler(self,self.isRechargeBack))                --核对是否充值过
    G_ServerMgr:C2S_GetLastPayInfo()
end

function CashOutLayer:isRechargeBack(payTime)
    G_event:RemoveNotifyEvent(G_eventDef.CASH_CHECKRETURN) 
    if tonumber(payTime) == 0 then          --未充值过
        G_event:NotifyEvent(G_eventDef.CASH_TIPSLAYER)
    else
        self:GetLastWithdrawRecord()
    end
end

--2.判断用户的上次提现审核是否被拒，若上次被拒则点提现按钮后弹提示框，提示框底部两个按钮：继续申请、联系客服
function CashOutLayer:GetLastWithdrawRecord()   
    G_event:AddNotifyEvent(G_eventDef.GetLastWithdrawRecord, handler(self,self.onLastWithdrawRecord)) 
    --获取最后一笔提现记录
    G_ServerMgr:C2S_GetLastWithdrawRecord()
end

function CashOutLayer:onLastWithdrawRecord(data)
    G_event:RemoveNotifyEvent(G_eventDef.GetLastWithdrawRecord) 
    dump(data)
    local status = data.status
    if status == 1 or status == 3 or status == 107 or status == 108 then
        self:showDialog()
    else
        --充值过，就去提现
        self:btnConfirmClick()
    end
end

--充值URL
function CashOutLayer:btnConfirmClick()    
    tlog("CashOutLayer:btnConfirmClick")
    local price = self.inputValue * 100
    local productId = 0

    if self.productIdx ~= 0 then
        local pItem = self.goldList[self.productIdx]
        price = pItem.dwPrice
        productId = pItem.dwProductID
    else
        for k, v in pairs(self.goldList) do
            if price ==v.dwPrice then
                productId = v.dwProductID
                break
            end
        end
    end

    if self.cashOutInfo and self.PayUrl then
        local acountTypeName = self.cashOutInfo.accountTypeTb[self.accountIdx]
        if acountTypeName then
            print("withdraw conmit url = ", self.PayUrl)
            local params = {}
            params.price = price
            params.userId = GlobalUserItem.dwUserID
            params.productId = productId --自定义金额id为 0
            params.dynamicPass = GlobalUserItem.szDynamicPass
            params.accountType = acountTypeName --支持的账号类型 eg:cpf
            local inputName = self.inputName:getString() --真实姓名
            local inputAcount = self.inputAcount:getString() --银行卡号或者CPF账户
            local inputCpf = self.inputCpf:getString() --cpf号码
            inputName = string.gsub(inputName, "\n", ""); --string.trim
            inputName = string.gsub(inputName, "\r", "");
            inputAcount = string.gsub(inputAcount, "\n", "");
            inputAcount = string.gsub(inputAcount, "\r", "");
            inputCpf = string.gsub(inputCpf, "\n", "");
            inputCpf = string.gsub(inputCpf, "\r", "");

            inputName = string.trim(inputName, "\n", ""); --string.trim --去除左右空格
            inputName = string.trim(inputName, "\r", "");
            inputAcount = string.trim(inputAcount, "\n", "");
            inputAcount = string.trim(inputAcount, "\r", "");
            inputCpf = string.trim(inputCpf, "\n", "");
            inputCpf = string.trim(inputCpf, "\r", "");

            params.accountName = inputName --真实姓名
            params.accountNumber = inputAcount --银行卡号或者CPF账户
            params.idNumber = inputCpf --cpf号码
            params.EventToken = FunctionADLogName("ad_revenue")
            params.EventTokenFirstPay = FunctionADLogName("ad_firstRevenue")
            params.AppToken = g_MultiPlatform:getInstance():getAdjustKey() 
            params.DevType = "gps_adid"
            params.DevID = g_MultiPlatform:getInstance():getAdjustGoogleAdId() 
            params.Currency = "BRL"
            dump(params,"=========url params")
            local callback = function(ok,jsonData) 
                dismissNetLoading()
                if ok then
                    if jsonData.code == 0 then
                        print("withdraw conmit success")
                        cc.UserDefault:getInstance():setIntegerForKey("withdraw_accountIdx", self.accountIdx)
                        self:showRemindDialog()
                        G_ServerMgr:C2S_RequestUserGold()
                    else
                        print(string.format("code = %s,error:%s",jsonData.code,jsonData.msg))
                        showToast(jsonData.msg)
                        self:showDialog()
                    end
                else
                    print("HTTP GET ERROR:",jsonData)
                end
            end
            g_ExternalFun.onHttpJsionTable(self.PayUrl,"POST",cjson.encode(params),callback)
            showNetLoading()
        end
    end
    
end

function CashOutLayer:showDialog()    
     --"您上次的审核被拒，存在几种可能：1.信息填写错误；2.找不到卡号，被银行回绝；3.游戏账号存在异常行为"
     local txt = "Seu último pedido falhou e existem algumas possibilidades: \n1. Informações preenchidas incorretamente; \n2. Número do cartão não pode ser encontrado, foi recusado pelo banco; \n3. Comportamento de jogo anormal da conta de jogo. \n\nPor favor, confirme se as informações foram modificadas."
     local pData = {
         dialogType = DialogType.CashOutBox,
         msg = txt,
         fontSize = 32,
         callback = function(click)
             if click == "ok" then     
                self:btnConfirmClick()
                --self:onConfirmClicked()
             elseif click == "cancel" then     
                G_event:NotifyEvent(G_eventDef.UI_OPEN_SERVICELAYER)
             end					
         end,
     }
     G_event:NotifyEvent(G_eventDef.UI_OPEN_COMMON_DIALOG,pData)
end

return CashOutLayer