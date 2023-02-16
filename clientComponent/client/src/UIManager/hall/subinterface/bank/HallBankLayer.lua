--[[
***
***
]]
local HallBankLayer =
    class(
    "HallBankLayer",
    function(args)
        local HallBankLayer = display.newLayer()
        return HallBankLayer
    end
)
function HallBankLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.UI_BANK_UPDATE_GOLD)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_MEMBERINFO)
    G_event:RemoveNotifyEvent(G_eventDef.NET_TRANSFER_MERCHANT_LIST)
end
function HallBankLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self)

    local csbNode = g_ExternalFun.loadCSB("bank/bankHome/bankHomeLayer.csb")
    self:addChild(csbNode)
    self:initHome(csbNode)
    self:initAccess()
    self:initMakeOver()
    self:selectDepositAndWithdraw(false)
    G_event:AddNotifyEvent(G_eventDef.UI_BANK_UPDATE_GOLD, handler(self, self.onUpdateMoney))
    G_event:AddNotifyEvent(G_eventDef.EVENT_MEMBERINFO, handler(self, self.onQueryMemberInfoClick)) --搜索会员
    G_event:AddNotifyEvent(G_eventDef.NET_TRANSFER_MERCHANT_LIST, handler(self, self.onGetTransferUserList)) --获取币商列表
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then  
        self:setIgnoreDecimal(false)      
    else
        self:setIgnoreDecimal(true)
        --查询下币商列表，有列表数据可以打开转账操作子页
        G_ServerMgr:C2S_RequestTransferUsers(10, 1, GlobalUserItem.dwUserID, GlobalUserItem.szDynamicPass)        
    end
end

--设置是否忽略小数位
--目前真金项目 不可忽略小数位
--    金币项目 TC币状态下不可忽略小数位 后续扩展
function HallBankLayer:setIgnoreDecimal(pStatus)
    self.IgnoreDecimal = pStatus
end

--获取是否忽略小数位
function HallBankLayer:isIgnoreDecimal()
    return self.IgnoreDecimal
end

function HallBankLayer:initHome(csbNode)
    self.bg = csbNode:getChildByName("bg")
    self.content = csbNode:getChildByName("content")
    ShowCommonLayerAction(self.bg, self.content)
    self.bg:onClicked(handler(self, self.onClickClose), true)
    self.content:getChildByName("btnClose"):onClicked(handler(self, self.onClickClose), true)

    --存取款子页面节点
    self.subNodeAccess = self.content:getChildByName("FileNode_1")
    --金币转让子页面节点
    self.subNodeMakeOver = self.content:getChildByName("FileNode_2")
    self.subNodeAccess:setVisible(true)
    self.isDeposit = false

    self.btnLeft = self.content:getChildByName("ButtonLeft") --存

    local spineNode = self.subNodeAccess:getChildByName("spineNode")
    self.skeletonNode = sp.SkeletonAnimation:create("client/res/bank/anima/yinhang.json", "client/res/bank/anima/yinhang.atlas", 1)
    self.skeletonNode:addAnimation(0, "cunqian", true)
    self.skeletonNode:setPosition(cc.p(-15,-70))
    spineNode:addChild(self.skeletonNode)

    self.skeletonNode2 = sp.SkeletonAnimation:create("client/res/bank/anima/yinhang.json", "client/res/bank/anima/yinhang.atlas", 1)
    self.skeletonNode2:addAnimation(0, "quqian", true)    
    self.skeletonNode2:setPosition(cc.p(-15,-70))
    spineNode:addChild(self.skeletonNode2)

    local spineNode2 = self.subNodeMakeOver:getChildByName("spineNode")
    self.skeletonNode3 = sp.SkeletonAnimation:create("client/res/bank/anima/yinhang.json", "client/res/bank/anima/yinhang.atlas", 1)
    self.skeletonNode3:addAnimation(0, "shousuo", true)
    self.skeletonNode3:setPosition(cc.p(-15,-70))
    spineNode2:addChild(self.skeletonNode3)

    self.btnLeft:onClicked(
        function()
            self.isDeposit = false
            self:selectSubNodeShow(true)
        end,
        true
    )
    self.btnLeft:setBright(false) --默认选中存取

    self.btnRight = self.content:getChildByName("ButtonRight") --提取

    self.btnRight:onClicked(
        function()
            self.isDeposit = true
            self:selectSubNodeShow(true)
        end,
        true
    )

    self.btnTransferir = self.content:getChildByName("ButtonTransferir") --转移   
    self.btnTransferir:onClicked(
        function()
            self:selectSubNodeShow(false)
        end,
        true
    )

    self.nodeSelect = true
    
    --记录
    self.btnJL = self.content:getChildByName("Button_JL")
    g_redPoint:addRedPoint(g_redPoint.eventType.bank, self.btnJL, cc.p(10, 10))
    self.btnJL:onClicked(
        function()
            if self.nodeSelect == true then
                if self.isDeposit then -- 取款
                    G_event:NotifyEvent(G_eventDef.UI_SHOW_TORECORDLAYER, {type = 2})
                else --存款
                    G_event:NotifyEvent(G_eventDef.UI_SHOW_TORECORDLAYER, {type = 1})
                end
                
            else
                local func = function(userData)
                    self:updataCurrUser(userData)
                end
                -- G_event:NotifyEvent(G_eventDef.UI_SHOW_OUTRECORDLAYER, func)
                G_event:NotifyEvent(G_eventDef.UI_SHOW_TORECORDLAYER, {type = 3})
            end
        end,
        true
    )    
    --客服
    self.btnCustomer = self.content:getChildByName("Button_KF")
    self.btnCustomer:onClicked(
        function()
            G_event:NotifyEvent(G_eventDef.UI_OPEN_SERVICELAYER)
        end,
        true
    )
    --修改密码
    self.btnModifyPsd = self.content:getChildByName("Button_XGMM")
    self.btnModifyPsd:onClicked(
        function()
            self:onClickModifPsd()
        end,
        true
    )
    
    --根据项目设置功能可否展示
    self:adjustByProject()
end

function HallBankLayer:adjustByProject()
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        self.btnTransferir:hide()
        self.btnJL:hide()
        self.btnModifyPsd:setPosition(self.btnCustomer:getPosition())
        self.btnCustomer:setPosition(self.btnJL:getPosition())
    end
end

--显示当前选择的子页面。 enable == true【存取款操作子页面】  enable == false【转让金币子页面】
function HallBankLayer:selectSubNodeShow(enable)
    print(enable, self.isRShowSub)
    if enable == false then
        if self.isRShowSub == false then
            print(self.isRShowSub)
            --没入会的
            showToast(g_language:getString("bank_tips_1"))
            return
        else
            print(self.isRShowSub)
            --入会了
            if GlobalUserItem.cbMemberOrder == 0 then
                --cbMemberOrder  0:普通玩家，1：会长 2~..：其他扩展身份    88468836
                local userData = {
                    FaceID = self.merchantList[1].dwFaceID,
                    GameID = self.merchantList[1].dwGameID,
                    UserID = self.merchantList[1].dwUserID,
                    NickName = self.merchantList[1].szNickName
                }
                self:updataCurrUser(userData)
                local btnUserClose = self.currUserNode:getChildByName("ButtonCloseUser")
                btnUserClose:hide()
            else
            end
        end
    end

    self.nodeSelect = enable
    self.subNodeAccess:setVisible(enable)
    self.subNodeMakeOver:setVisible(not enable)
    if enable then
        --true 取款状态  false 存款状态
        if self.isDeposit then -- 取款按钮高亮
            self.btnRight:setBright(false)
            self.btnLeft:setBright(true)
            self.btnTransferir:setBright(enable)

            self:selectDepositAndWithdraw(true)
        else --存款按钮高亮
            self.btnRight:setBright(true)
            self.btnLeft:setBright(false)
            self.btnTransferir:setBright(enable)

            self:selectDepositAndWithdraw(false)
        end
    else -- 转让金币按钮高亮
        self.btnRight:setBright(not enable)
        self.btnLeft:setBright(not enable)
        self.btnTransferir:setBright(enable)
        self.skeletonNode3:setVisible(not enable)
    end
end

function HallBankLayer:onClickClose()
    if self.editActive == true then
        self.editActive = false
        return
    end
    DoHideCommonLayerAction(
        self.bg,
        self.content,
        function()
            self:removeSelf()
        end
    )
end

function HallBankLayer:onGetTransferUserList(listData)
    dump(listData.info)
    if listData.info.dwErrorCode ~= 0 then
        if listData.info.dwErrorCode >= 800 then
            showToast(g_language:getString(listData.info.dwErrorCode))
        end
        self.isRShowSub = false
    else
        self.isRShowSub = true
    end
    if table.isEmpty(listData.info.lsItems) then
        return
    end
    if table.nums(listData.info.lsItems) == 0 then
        return
    end
    if listData.info.lsItems and table.nums(listData.info.lsItems) then
        self.isRShowSub = true
        --商人列表
        self.merchantList = listData.info.lsItems
    end
end

--修改密码
function HallBankLayer:onClickModifPsd()
    G_event:NotifyEvent(G_eventDef.UI_MODIFYT_BANKPSDLAYER)
end

--取
function HallBankLayer:onClickDrawMoney()
    local txt = self.inputMoney:getText()
    
    txt = string.gsub(txt, "[%.,]", "")
    if txt == "" then
        showToast(g_language:getString("input_money"))
        return
    end
    txt = tonumber(txt)
    if txt == nil or txt <= 0 then
        showToast(g_language:getString("input_error_money"))
        return
    end
    if txt > GlobalUserItem.lUserInsure then
        showToast(g_language:getString("bank_score_less"))
        return
    end
    self.actionData = {}
    self.actionData.Direction = "right"
    self.actionData.rollNum = txt
    G_ServerMgr:C2S_TakeScore(txt)
    self.isMoveScore = true
end
--存
function HallBankLayer:onClickSaveMoney()
    local txt = self.inputMoney:getText()
    txt = string.gsub(txt, "[%.,]", "")
    if txt == "" then
        showToast(g_language:getString("input_money"))
        return
    end
    txt = tonumber(txt)
    if txt == nil or txt <= 0 then
        showToast(g_language:getString("input_error_money"))
        return
    end
    if txt > GlobalUserItem.lUserScore then
        showToast(g_language:getString("user_score_less"))
        return
    end
    self.actionData = {}
    self.actionData.Direction = "right"
    self.actionData.rollNum = txt
    G_ServerMgr:C2S_SaveScore(txt)
    self.isMoveScore = true
end

function HallBankLayer:onUpdateMoney(args)
    local bagStr = g_format:formatNumber(GlobalUserItem.lUserScore,g_format.fType.standard,g_format.currencyType.GOLD)
    local bankStr = g_format:formatNumber(GlobalUserItem.lUserInsure,g_format.fType.standard,g_format.currencyType.GOLD)
    print("背包金币：", GlobalUserItem.lUserScore)
    print("银行金币：", GlobalUserItem.lUserInsure)
    --存取款动作
    if self.subNodeAccess:isVisible() then
        local txt = self.inputMoney:getText()
        if txt == "0" or txt == "" then
            return
        end
        if self.isMoveScore then
            self.isMoveScore = false
            self.isTransferAction = false
        else
            return
        end

        if not self.actionData then
            return
        end
        txt = string.gsub(txt, "[%.,]", "")
        if self.actionData.Direction == "right" then
            local pos  -- 动画目标点
            if self.isDeposit then --取
                pos = cc.p(self.bagMoney_2:getPosition())
                self.bankMoney_2:setString(bankStr)
                self.bankMoney:setString(bankStr)
                self:toRightAction(
                    self.subNodeAccess,
                    nil,
                    function()
                        local node = self.subNodeAccess:getChildByName("AtlasLabel_number")
                        self:moveGold(node, txt, pos, true)
                        g_ExternalFun.digitalScroll(
                            self.bagMoney_2,
                            self.actionData.rollNum,
                            nil,
                            function()
                                self.bagMoney_2:setString(bagStr)
                                self.bagMoney:setString(bagStr)
                            end
                        )
                        self.bankMoney2:setString(bankStr)
                    end,
                    true
                )
            else --存
                pos = cc.p(self.bankMoney:getPosition())
                self.bagMoney:setString(bagStr)
                self.bagMoney_2:setString(bagStr)
                self:toRightAction(
                    self.subNodeAccess,
                    nil,
                    function()
                        local node = self.subNodeAccess:getChildByName("AtlasLabel_number")
                        self:moveGold(node, txt, pos, true)
                        g_ExternalFun.digitalScroll(
                            self.bankMoney,
                            self.actionData.rollNum,
                            nil,
                            function()
                                self.bankMoney:setString(bankStr)
                                self.bankMoney_2:setString(bankStr)
                            end
                        )
                        self.bankMoney2:setString(bankStr)
                    end,
                    true
                )
            end
        end
        if self.actionData.Direction == "left" then
            self.bankMoney:setString(bankStr)
            self.bankMoney_2:setString(bankStr)
            self:toLeftAction(
                function()
                    local node = self.subNodeAccess:getChildByName("AtlasLabel_number")
                    self:moveGold(node, txt, cc.p(self.bagMoney:getPosition()), true)
                    g_ExternalFun.digitalScroll(
                        self.bagMoney,
                        self.actionData.rollNum,
                        nil,
                        function()
                            self.bagMoney:setString(bagStr)
                            self.bagMoney_2:setString(bagStr)
                        end
                    )
                    self.bankMoney2:setString(bankStr)
                end
            )
        end
    end

    --上下币动作
    if self.subNodeMakeOver:isVisible() then
        local txt = self.inputMoney2:getText()
        if txt == "0" or txt == "" then
            return
        end
        if self.isTransferAction then
            self.isTransferAction = false
            self.isMoveScore = false
        else
            return
        end

        self.bagMoney:setString(bagStr)
        self.bagMoney_2:setString(bagStr)
        self.inputMoney2:setText("0")
        self:toRightAction(
            self.subNodeMakeOver,
            function()
                local node = self.subNodeMakeOver:getChildByName("AtlasLabel_number")
                self:moveGold(node, self.inputNumber, cc.p(self.bankMoney2:getPosition()), false)
            end,
            function()
                self.bankMoney:setString(bankStr)
                self.bankMoney_2:setString(bankStr)
                self.bankMoney2:setString(bankStr)
            end,
            false
        )
        local toastStr = string.format(g_language:getString("bank_tips_5"), self.inputNumber, self.currUserData.NickName)
        showToast(toastStr)
    end

    if args and args.code == 0 then
        self.inputMoney:setText("0")
    end
end

--
function HallBankLayer:toRightAction(parentNode, preCallback, afterCallback)
    self.sp = cc.Sprite:create("GUI/Hall/dating_jieji_4_icon.png")
    self.sp:setScale(0.7)
    self.sp:setPosition(-330, 75)
    parentNode:addChild(self.sp)

    local x, y = self.sp:getPosition()
    local offsetX = 220
    local offsetY = 150
    local bezierPoint1 = {
        cc.p(x + offsetX, y + offsetY), --2
        cc.p(x + offsetX * 2, y + offsetY), --3
        cc.p(-x, y) --4
    }
    local duration = 0.5
    local bezierTo1 = cc.EaseInOut:create(cc.BezierTo:create(duration, bezierPoint1), 3)
    self.sp:runAction(
        cc.Sequence:create(
            cc.CallFunc:create(
                function()
                    if preCallback then
                        preCallback()
                    end
                end
            ),
            bezierTo1,
            cc.CallFunc:create(
                function()
                    self.sp:removeSelf()
                    if afterCallback then
                        afterCallback()
                    end
                end
            )
        )
    )
end

function HallBankLayer:toLeftAction(callback)
    self.sp = cc.Sprite:create("GUI/Hall/dating_jieji_4_icon.png")
    self.sp:setScale(0.7)
    self.sp:setPosition(330, 75)
    self.subNodeAccess:addChild(self.sp)

    local x, y = self.sp:getPosition()
    local offsetX = 220
    local offsetY = 150
    local bezierPoint1 = {
        cc.p(x - offsetX, y + offsetY), --2
        cc.p(x - offsetX * 2, y + offsetY), --3
        cc.p(-x, y) --4
    }
    local duration = 0.5
    local bezierTo1 = cc.EaseInOut:create(cc.BezierTo:create(duration, bezierPoint1), 3)
    self.sp:runAction(
        cc.Sequence:create(
            bezierTo1,
            cc.CallFunc:create(
                function()
                    self.sp:removeSelf()
                    callback()
                end
            )
        )
    )
end

--飘金币数字
function HallBankLayer:moveGold(node, goldNum, pos, addOrTo)
    if goldNum == nil then
        return
    end
    goldNum = g_format:formatNumber(goldNum,g_format.fType.abbreviation)
    goldNum = string.gsub(goldNum, "K", ":")
    goldNum = string.gsub(goldNum, "M", ";")
    goldNum = string.gsub(goldNum, "B", "<")
    goldNum = string.gsub(goldNum, "T", "=")
    local preStr = not addOrTo and "-" or "+"
    node:setString(preStr .. goldNum)
    node:setPosition(pos)
    node:setOpacity(0.1)
    local move1 = cc.MoveTo:create(0.2, cc.p(pos.x, 30))
    local detime = cc.DelayTime:create(0.5)
    local move3 = cc.MoveTo:create(1.3, cc.p(pos.x, 150))

    local fadeIn = cc.FadeIn:create(0.2)
    local fadeOut = cc.FadeOut:create(1.3)
    local spawn1 = cc.Spawn:create(move1, fadeIn)
    local spawn2 = cc.Spawn:create(move3, fadeOut)

    node:runAction(cc.Sequence:create(spawn1, detime, spawn2))
end

----------------------------存取金币-----------------------------------
function HallBankLayer:initAccess()
    local str = g_format:formatNumber(GlobalUserItem.lUserScore,g_format.fType.standard,g_format.currencyType.GOLD)
    self.bagMoney = self.subNodeAccess:getChildByName("TextBagMoney")
    self.bagMoney:setString(str)
    self.bagMoney_2 = self.subNodeAccess:getChildByName("TextBagMoney2")
    self.bagMoney_2:setString(str)
    local str = g_format:formatNumber(GlobalUserItem.lUserInsure,g_format.fType.standard,g_format.currencyType.GOLD)
    self.bankMoney = self.subNodeAccess:getChildByName("TextBankMoney")
    self.bankMoney:setString(str)
    self.bankMoney_2 = self.subNodeAccess:getChildByName("TextBankMoney2")
    self.bankMoney_2:setString(str)

    self.depositNode = self.subNodeAccess:getChildByName("Panel_deposit")
    self.depositNode:setVisible(false)
    self.isDeposit = false --true 取款状态  false 存款状态
    self.withdrawNode = self.subNodeAccess:getChildByName("Panel_withdraw")
    self.btnBag = self.subNodeAccess:getChildByName("Button_withdraw") -- 取

    self.btnSafe = self.subNodeAccess:getChildByName("Button_deposit") --存
    self.bagTip1 = self.subNodeAccess:getChildByName("bagTip1")
    self.bagTip2 = self.subNodeAccess:getChildByName("bagTip2")

    self.bagTip3 = self.subNodeAccess:getChildByName("bagTip3")
    self.bagTip4 = self.subNodeAccess:getChildByName("bagTip4")

    local callback = function()
        self.editActive = true
        performWithDelay(
            self.inputMoney,
            function()
                self.editActive = false
            end,
            0.5
        )
    end
    self.inputMoney = self.subNodeAccess:getChildByName("TextField_Money"):convertToEditBox(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.inputMoney:onDidReturn(callback)
    self.inputMoney:setPlaceHolder("0")
    self.inputMoney:setMaxLength(20)
    self.inputMoney:registerScriptEditBoxHandler(
        function(eventType, pObj)
            local str = pObj:getText()
            if eventType == "began" then
                if str == "0" then
                    str = ""
                end
            elseif eventType == "changed" then
                local result = ""
                local pTable = {}
                local pTable2 = string.split(str,",")                
                pTable[1] = pTable2[1] and string.gsub(pTable2[1],"[^0-9.]","") or ""
                pTable[2] = pTable2[2] and string.gsub(pTable2[2],"[^0-9]","") or nil
                local pStr1 = string.gsub(pTable2[1],"[^0-9]","")                
                local pStr3 = string.reverse(pStr1)
                local pStr2 = ""
                local pLen = string.len(pStr3)
                for i = 1, pLen do
                    pStr2 = pStr2 .. string.sub(pStr3,i,i)
                    if i%3 == 0 and i~=pLen then
                        pStr2 = pStr2.."."
                    end
                end
                pStr2 = string.reverse(pStr2)

                pTable[1] = pStr2
                str = pStr2
                if pTable[2] and not self:isIgnoreDecimal() then
                    if pTable[1] == "" then
                        pTable[1] = "0"
                    end
                    result = pTable[1]..","
                    pTable[2] = string.sub(pTable[2],1,2)
                    result = result..pTable[2]
                    str = result
                end
                local pCompare = self.isDeposit and GlobalUserItem.lUserInsure or GlobalUserItem.lUserScore

                if self:isIgnoreDecimal() then
                    --忽略小数
                    local pStrValue = tonumber(pStr1)
                    if pStrValue and pStrValue > pCompare then
                        str = g_format:formatNumber(pCompare,g_format.fType.standard)
                    end
                else
                    --不可忽略小数
                    local pStrValue = tonumber(pStr1.."00")                    
                    local pValueDecimal = 0
                    if pTable[2] and string.len(pTable[2])>0 then                        
                        local pLenDecimal = string.len(pTable[2])
                        if pLenDecimal==1 then
                            pValueDecimal = tonumber(pTable[2].."0")
                        elseif pLenDecimal==2 then
                            pValueDecimal = tonumber(pTable[2])
                        end                        
                    end
                    pStrValue = pStrValue + pValueDecimal                    
                    if pStrValue and pStrValue > pCompare then
                        str = g_format:formatNumber(pCompare,g_format.fType.standard)
                    end
                end
            elseif eventType == "return" or eventType == "ended" then
                local result = ""
                local pTable = {}
                local pTable2 = string.split(str,",")                
                pTable[1] = pTable2[1] and string.gsub(pTable2[1],"[^0-9.]","") or ""
                pTable[2] = pTable2[2] and string.gsub(pTable2[2],"[^0-9]","") or ""
                local pStr1 = string.gsub(pTable2[1],"[^0-9]","")                
                local pStr3 = string.reverse(pStr1)
                local pStr2 = ""
                local pLen = string.len(pStr3)
                for i = 1, pLen do
                    pStr2 = pStr2 .. string.sub(pStr3,i,i)
                    if i%3 == 0 and i~=pLen then
                        pStr2 = pStr2.."."
                    end
                end
                pStr2 = string.reverse(pStr2)

                pTable[1] = pStr2
                str = pStr2
                if not self:isIgnoreDecimal() then
                    if pTable[1] == "" then
                        pTable[1] = "0"
                    end
                    result = pTable[1]..","
                    pTable[2] = string.sub(pTable[2],1,2)
                    local pLen2 = string.len(pTable[2])
                    if pLen2 == 0 then
                        pTable[2] = "00"
                    elseif pLen2 == 1 then
                        pTable[2] = pTable[2].."0"
                    end
                    result = result..pTable[2]
                    str = result
                end
                local pCompare = self.isDeposit and GlobalUserItem.lUserInsure or GlobalUserItem.lUserScore

                if self:isIgnoreDecimal() then
                    --忽略小数
                    local pStrValue = tonumber(pStr1)
                    if pStrValue and pStrValue > pCompare then
                        str = g_format:formatNumber(pCompare,g_format.fType.standard)
                    end
                else
                    --不可忽略小数
                    local pStrValue = tonumber(pStr1.."00")                    
                    local pValueDecimal = 0
                    if pTable[2] and string.len(pTable[2])>0 then                        
                        local pLenDecimal = string.len(pTable[2])
                        if pLenDecimal==1 then
                            pValueDecimal = tonumber(pTable[2].."0")
                        elseif pLenDecimal==2 then
                            pValueDecimal = tonumber(pTable[2])
                        end                        
                    end
                    pStrValue = pStrValue + pValueDecimal                    
                    if pStrValue and pStrValue > pCompare then
                        str = g_format:formatNumber(pCompare,g_format.fType.standard)
                    end
                end
            end
            pObj:setText(str)
        end
    )

    local btnAllDeposit = self.depositNode:getChildByName("ButtonAllDeposit")
    btnAllDeposit:onClicked(
        function()
            self:onInputAllInsureClick()
        end,
        true
    )
    local btnAllWithdraw = self.withdrawNode:getChildByName("ButtonAllWithdraw")
    btnAllWithdraw:onClicked(
        function()
            self:onInputAllWithdrawClick()
        end,
        true
    )

    local btnDeposit = self.depositNode:getChildByName("ButtonToStore")
    btnDeposit:onClicked(
        function()
            self:onClickSaveMoney()
        end,
        true
    )
    local btnWithdraw = self.withdrawNode:getChildByName("ButtonWithdraw")
    btnWithdraw:onClicked(
        function()
            self:onClickDrawMoney()
        end,
        true
    )
end

function HallBankLayer:selectDepositAndWithdraw(enable)
    self.isDeposit = enable --true 取款状态  false 存款状态
    self.depositNode:setVisible(not enable)
    self.withdrawNode:setVisible(enable)
    -- self.btnBag:setVisible(enable)
    -- self.btnSafe:setVisible(not enable)
    self.bagMoney_2:setVisible(enable)
    self.bankMoney_2:setVisible(enable)
    self.bagMoney:setVisible(not enable)
    self.bankMoney:setVisible(not enable)
    self.inputMoney:setText("0")
    self.bagTip1:setVisible(enable)
    self.bagTip2:setVisible(enable)

    self.bagTip3:setVisible(not enable)
    self.bagTip4:setVisible(not enable)

    self.btnBag:setVisible(false)
    self.btnSafe:setVisible(false)
    self.skeletonNode:setVisible(not enable)
    self.skeletonNode2:setVisible(enable)
    self.skeletonNode3:setVisible(false)
end
--lUserInsure
function HallBankLayer:onInputAllWithdrawClick()
    self.inputMoney:setText(g_format:formatNumber(GlobalUserItem.lUserInsure,g_format.fType.standard,g_format.currencyType.GOLD))
end
--
function HallBankLayer:onInputAllInsureClick()
    self.inputMoney:setText(g_format:formatNumber(GlobalUserItem.lUserScore,g_format.fType.standard,g_format.currencyType.GOLD))
end

----------------------------金币转让-----------------------------------
function HallBankLayer:initMakeOver()
    self.currUserData = {}
    local str = g_format:formatNumber(GlobalUserItem.lUserInsure,g_format.fType.standard,g_format.currencyType.GOLD)
    self.bankMoney2 = self.subNodeMakeOver:getChildByName("TextBagMoney")
    self.bankMoney2:setString(str)

    local callback = function()
        self.editActive = true
        performWithDelay(
            self.inputMoney2,
            function()
                self.editActive = false
            end,
            0.5
        )
    end
    self.inputMoney2 = self.subNodeMakeOver:getChildByName("TextField_Money"):convertToEditBox(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.inputMoney2:onDidReturn(callback)
    self.inputMoney2:setPlaceHolder("0")
    self.inputMoney2:setMaxLength(20)
    self.inputMoney2:registerScriptEditBoxHandler(        
        function(eventType, pObj)
            if eventType == "return" or eventType == "ended" then
                local number = pObj:getText()
                number = g_format:inputFormat(number)
                if number == nil then 
                    pObj:setText("0")
                    return
                end
                number = string.gsub(number, "[^0-9]", "")
                self.inputNumber = number
                if number == "" then
                    pObj:setText("0")
                    return
                end
                if tonumber(number) > GlobalUserItem.lUserInsure then
                    pObj:setText(g_format:formatNumber(GlobalUserItem.lUserInsure,g_format.fType.standard,g_format.currencyType.GOLD))
                else
                    pObj:setText(g_format:formatNumber(number,g_format.fType.standard,g_format.currencyType.GOLD))
                end
            elseif eventType == "began" then
                local str = pObj:getText()                
                str = g_format:inputFormat(str)
                str = string.gsub(str, "[^0-9]", "")
                if str == "0" then
                    pObj:setText("")
                else
                    pObj:setText(str)
                end
            end
        end
    )

    local btnAll = self.subNodeMakeOver:getChildByName("ButtonAll")
    btnAll:onClicked(
        function()
            self.inputMoney2:setText(g_format:formatNumber(GlobalUserItem.lUserInsure,g_format.fType.standard,g_format.currencyType.GOLD))
        end
    )

    local btnMakeOver = self.subNodeMakeOver:getChildByName("ButtonMakeOver")
    btnMakeOver:onClicked(
        function()
            local number = self.inputMoney2:getText()
            number = g_format:inputFormat(number)
            number = string.gsub(number, "[^0-9]", "")
            self.inputNumber = number
            if self.AllNode:isVisible() then
                --请添加要转让金币的玩家
                showToast(g_language:getString("bank_tips_2"))
                return
            end

            if self.inputNumber == "" or tonumber(self.inputNumber) == 0 then
                --空的请输入转让金额
                showToast(g_language:getString("bank_tips_3"))
                return
            end
            if tonumber(self.inputNumber) < 100 then
                --最小转让额度100
                showToast(g_language:getString("bank_tips_4"))
                return
            end

            -- G_ServerMgr:C2S_RequestUserInfo(self.currUserData.GameID)
            self:QueryTransferUser()
        end
    )

    self.AllNode = self.subNodeMakeOver:getChildByName("Panel_search")
    self.AllNode:setVisible(true)
    local btnSearch = self.AllNode:getChildByName("ButtonSearch")
    btnSearch:onClicked(
        function()
            if self.searchID then
                G_ServerMgr:C2S_RequesMemberInfo(self.searchID) --88468836
            end
        end
    )
    local callback = function()
        self.editActive = true
        performWithDelay(
            self.inputMoney2,
            function()
                self.editActive = false
            end,
            0.5
        )
    end
    self.searchInput = self.AllNode:getChildByName("TextField_search"):convertToEditBox(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.searchInput:onDidReturn(callback)
    -- self.searchInput:setPlaceHolder("0")
    -- self.searchInput:setPlaceholderFontColor(ccColor3B(246,203,145))
    self.searchInput:setMaxLength(10)
    self.searchInput:registerScriptEditBoxHandler(
        function(eventType, pObj)
            if eventType == "return" then
                local searchID = pObj:getText()

                searchID = string.gsub(searchID, "[^0-9]", "")
                if searchID == "" or searchID == "0" then
                    return
                else
                    pObj:setText(searchID)
                end
                if string.len(searchID) >= 6 then
                    self.searchID = searchID
                else
                    self.searchID = nil
                    showToast(g_language:getString("bank_tips_6"))
                end
            elseif eventType == "began" then
            end
        end
    )

    self.currUserNode = self.subNodeMakeOver:getChildByName("Panel_user")
    self.currUserNode:setVisible(false)

    local btnUserClose = self.currUserNode:getChildByName("ButtonCloseUser")
    btnUserClose:onClicked(
        function()
            self.AllNode:setVisible(true)
            self.currUserNode:setVisible(false)
            -- cc.UserDefault:getInstance():setIntegerForKey("merchantID",0)
        end
    )
end

--查询用户成功
function HallBankLayer:QueryTransferUser(args)
    -- if args.dwTargetGameID == tonumber(self.currUserData.GameID) then

    local csbNode = g_ExternalFun.loadCSB("bank/bankMakeOver/reconfirmLayer.csb")
    self:addChild(csbNode)
    local bg = csbNode:getChildByName("bg")
    bg:onClicked(
        function()
            csbNode:removeSelf()
        end
    )
    local nodes = csbNode:getChildByName("content")
    ShowCommonLayerAction(bg, nodes)
    nodes:getChildByName("Text_gold"):setString(g_format:formatNumber(self.inputNumber,g_format.fType.standard))
    nodes:getChildByName("TextUserID"):setString(string.format("(ID:%s)", self.currUserData.GameID))
    nodes:getChildByName("TextUserName"):setString(self.currUserData.NickName)
    --头像
    local imgHead = nodes:getChildByName("ImageUserHead")
    HeadSprite.loadHeadImg(imgHead, self.currUserData.GameID, self.currUserData.FaceID, true)

    -- nodes:getChildByName("btnClose"):onClicked(
    --     function()
    --         csbNode:removeSelf()
    --     end
    -- )

    nodes:getChildByName("btnConfirm"):onClicked(
        function()
            --转账参数：金额，银行密码,转出ID
            G_ServerMgr:C2S_TransferScore(tonumber(self.inputNumber), self.currUserData.GameID)
            DoHideCommonLayerAction(
                bg,
                nodes,
                function()
                    csbNode:removeSelf()
                end
            )
            self.isTransferAction = true
        end
    )

    nodes:getChildByName("btnCancel"):onClicked(
        function()
            DoHideCommonLayerAction(
                bg,
                nodes,
                function()
                    csbNode:removeSelf()
                end
            )
        end
    )
    -- end
end

function HallBankLayer:onQueryMemberInfoClick(args)
    if args.dwUserID == GlobalUserItem.dwUserID then
    end
    local userData = {
        FaceID = args.wFaceID,
        GameID = args.dwGameID,
        NickName = args.szNickName,
        UserID = args.dwUserID,
        faceUrl = args.wFaceID
    }
    self:updataCurrUser(userData)
end

function HallBankLayer:updataCurrUser(userData)
    dump(userData)
    if table.isEmpty(userData) then
        return
    end
    self.currUserData = userData
    self.AllNode:setVisible(false)
    self.currUserNode:setVisible(true)
    self.currUserNode:getChildByName("TextUserName"):setText(userData.NickName)
    self.currUserNode:getChildByName("TextUserID"):setText(userData.GameID)

    --头像
    local imgHead = self.currUserNode:getChildByName("ImageUserHead")
    HeadSprite.loadHeadImg(imgHead, userData.GameID, userData.FaceID, true)
end

return HallBankLayer
