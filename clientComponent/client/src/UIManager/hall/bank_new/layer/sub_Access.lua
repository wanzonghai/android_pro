--[[
    存取款模块
]]

local sub_Access = class("sub_Access")
local bankCmd = require(appdf.CLIENT_SRC.."UIManager.hall.bank_new.data.CMD_bankServer")

function sub_Access:ctor(args)
    self.m_root = args.root
    self.m_currencyType = g_format.currencyType.GOLD
    G_event:AddNotifyEvent(G_eventDef.NET_BANK_SAVE_RESULT,handler(self,self.onChangeMoney))
    G_event:AddNotifyEvent(G_eventDef.NET_BANK_TAKE_RESULT,handler(self,self.onChangeMoney))
    G_event:AddNotifyEvent(G_eventDef.UI_BANK_UPDATE_GOLD, handler(self, self.onUpdateMoney))
    self:initUI()
end

function sub_Access:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_BANK_SAVE_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.NET_BANK_TAKE_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.UI_BANK_UPDATE_GOLD)
end

function sub_Access:initUI()
    self.isMoveScore = false --是否显示动画，防止自动刷新金币时显示动画
    self.inputMoney = self.mm_TextField_Money:convertToEditBox(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    -- self.inputMoney:onDidReturn(callback)
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
                local pCompare = self:getCurrScore()

                if self:isIgnoreDecimal() then
                    --忽略小数
                    local pStrValue = tonumber(pStr1)
                    if pStrValue and pStrValue > pCompare then
                        str = g_format:formatNumber(pCompare,g_format.fType.standard,self.m_currencyType)
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
                        str = g_format:formatNumber(pCompare,g_format.fType.standard,self.m_currencyType)
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
                local pCompare = self:getCurrScore()

                if self:isIgnoreDecimal() then
                    --忽略小数
                    local pStrValue = tonumber(pStr1)
                    if pStrValue and pStrValue > pCompare then
                        str = g_format:formatNumber(pCompare,g_format.fType.standard,self.m_currencyType)
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
                        str = g_format:formatNumber(pCompare,g_format.fType.standard,self.m_currencyType)
                    end
                end
            end
            pObj:setText(str)
        end
    )

    self.mm_ButtonAllDeposit:onClicked(
        function()
            self:onInputAllInsureClick()
        end,
        true
    )
    self.mm_ButtonAllWithdraw:onClicked(
        function()
            self:onInputAllWithdrawClick()
        end,
        true
    )

    self.mm_ButtonToStore:onClicked(
        function()
            self:onClickSaveMoney()
        end,
        true
    )
    self.mm_ButtonWithdraw:onClicked(
        function()
            self:onClickDrawMoney()
        end,
        true
    )
    self.label_pos = cc.p(self.mm_AtlasLabel_number:getPosition())  
end

function sub_Access:selectBehaviorType(type)
    self.behaviorType = type
    self.mm_Panel_deposit:hide()
    self.mm_Panel_withdraw:hide()
    if type == bankCmd.behaviorType.save then
        self.mm_Panel_deposit:show()
    elseif type == bankCmd.behaviorType.take then
        self.mm_Panel_withdraw:show()
    end
    self:changeUIData()
end

function sub_Access:selectCurrencyType(currencyType)
    self.m_currencyType = currencyType 
    self:changeUIData()
end

function sub_Access:changeUIData()
    if self.m_currencyType == nil then return end
    if self.behaviorType == nil then return end

    local userScore = GlobalUserItem.lUserScore
    local bankScore = GlobalUserItem.lUserInsure
    if self.m_currencyType == g_format.currencyType.TC then
        userScore = GlobalUserItem.lTCCoin
        bankScore = GlobalUserItem.lTCCoinInsure
    end

    local str = g_format:formatNumber(bankScore,g_format.fType.standard,self.m_currencyType)
    self.mm_TextBankMoney2:setString(str)
    self.mm_TextBankMoney2.userData = bankScore
    local str = g_format:formatNumber(userScore,g_format.fType.standard,self.m_currencyType)
    self.mm_TextBagMoney2:setString(str)
    self.mm_TextBagMoney2.userData = userScore
    local str = g_format:formatNumber(bankScore,g_format.fType.standard,self.m_currencyType)
    self.mm_TextBankMoney:setString(str)
    self.mm_TextBankMoney.userData = bankScore
    local str = g_format:formatNumber(userScore,g_format.fType.standard,self.m_currencyType)
    self.mm_TextBagMoney:setString(str)
    self.mm_TextBagMoney.userData = userScore
end

function sub_Access:getCurrScore()
    if self.m_currencyType == g_format.currencyType.TC then
        if self.behaviorType == bankCmd.behaviorType.save then
            return self.mm_TextBagMoney.userData
        elseif self.behaviorType == bankCmd.behaviorType.take then
            return self.mm_TextBankMoney2.userData
        end
    else
        if self.behaviorType == bankCmd.behaviorType.save then
            return self.mm_TextBagMoney.userData
        elseif self.behaviorType == bankCmd.behaviorType.take then
            return self.mm_TextBankMoney2.userData
        end
    end
end

-- --设置是否忽略小数位
-- --目前真金项目 不可忽略小数位
-- --    金币项目 TC币状态下不可忽略小数位 后续扩展
-- function sub_Access:setIgnoreDecimal(pStatus)
--     self.IgnoreDecimal = pStatus
-- end

--获取是否忽略小数位
function sub_Access:isIgnoreDecimal()
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then  
        return false     
    else
        if self.m_currencyType == g_format.currencyType.TC then
            return false   
        else
            return true   
        end
    end
end

--取
function sub_Access:onClickDrawMoney()
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
    -- if txt > GlobalUserItem.lUserInsure then
    --     showToast(g_language:getString("bank_score_less"))
    --     return
    -- end
    self.actionData = {}
    self.actionData.Direction = "right"
    self.actionData.rollNum = txt
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then 
        G_ServerMgr:C2S_TakeScore(txt)
    else
        self.m_root.bankData:C2S_RequestUserTakeScoreEx(self.m_currencyType,txt)
    end
    -- G_ServerMgr:C2S_TakeScore(txt)
    self.isMoveScore = true
end
--存
function sub_Access:onClickSaveMoney()
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
    -- if  txt > GlobalUserItem.lUserScore then
    --     showToast(g_language:getString("user_score_less"))
    --     return
    -- end
    self.actionData = {}
    self.actionData.Direction = "right"
    self.actionData.rollNum = txt
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then 
        G_ServerMgr:C2S_SaveScore(txt)
    else
        self.m_root.bankData:C2S_RequestSaveScoreEx(self.m_currencyType,txt)
    end
    -- G_ServerMgr:C2S_SaveScore(txt)
    self.isMoveScore = true
end

function sub_Access:onInputAllWithdrawClick()
    local bankScore = GlobalUserItem.lUserInsure
    if self.m_currencyType == g_format.currencyType.TC then
        bankScore = GlobalUserItem.lTCCoinInsure
    end
    self.inputMoney:setText(g_format:formatNumber(bankScore,g_format.fType.standard,self.m_currencyType))
end
--
function sub_Access:onInputAllInsureClick()
    local userScore = GlobalUserItem.lUserScore
    if self.m_currencyType == g_format.currencyType.TC then
        userScore = GlobalUserItem.lTCCoin
    end
    self.inputMoney:setText(g_format:formatNumber(userScore,g_format.fType.standard,self.m_currencyType))
end

function sub_Access:onUpdateMoney(pData)
    if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then
        if not pData then
            local txt = self.inputMoney:getText()
            if txt == "0" or txt == "" then
                return
            end
            txt = string.gsub(txt, "[%.,]", "")
            pData = {}
            pData.dwResultCode = 0
            pData.cbCurrencyType = 1
            pData.llScore = txt
        end
        self:onChangeMoney(pData)
    end
end

function sub_Access:onChangeMoney(pData)
    if pData.dwResultCode == 0 then
        self.inputMoney:setText("0")
    else
        return 
    end
    -- 动画目标点
    local pNode = self.mm_Panel_deposit
    if self.behaviorType == 2 then
        pNode = self.mm_Panel_withdraw
    end

    if pData.cbCurrencyType == 1 then

    else

    end

    self:toRightAction(
        pNode,
        nil,
        function()
            self:moveGold(self.mm_AtlasLabel_number, pData.llScore, self.label_pos, true)
            self:changeUIData()
        end,
        true
    )
end

--
function sub_Access:toRightAction(parentNode, preCallback, afterCallback)
    self.sp = cc.Sprite:create("public/gold_bank.png")
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

--飘金币数字
function sub_Access:moveGold(node, goldNum, pos, addOrTo)
    if goldNum == nil then
        return
    end
    if self.isMoveScore then
        self.isMoveScore = false
    else
        return
    end
    goldNum = g_format:formatNumber(goldNum,g_format.fType.abbreviation,self.m_currencyType)
    goldNum = string.gsub(goldNum, "K", ":")
    goldNum = string.gsub(goldNum, "M", ";")
    goldNum = string.gsub(goldNum, "B", "<")
    goldNum = string.gsub(goldNum, "T", "=")
    local preStr = not addOrTo and "-" or "+"
    node:setString(preStr .. goldNum)
    node:setPosition(pos)
    node:setOpacity(0.1)
    local move1 = cc.MoveBy:create(0.2, cc.p(0, 30))
    local detime = cc.DelayTime:create(0.5)
    local move3 = cc.MoveBy:create(1.3, cc.p(0, 150))

    local fadeIn = cc.FadeIn:create(0.2)
    local fadeOut = cc.FadeOut:create(1.3)
    local spawn1 = cc.Spawn:create(move1, fadeIn)
    local spawn2 = cc.Spawn:create(move3, fadeOut)

    node:runAction(cc.Sequence:create(spawn1, detime, spawn2))
end

return sub_Access