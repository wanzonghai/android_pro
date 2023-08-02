--[[
    转让模块
]]

local sub_transfer = class("sub_transfer")

function sub_transfer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_MEMBERINFO)
    G_event:RemoveNotifyEvent(G_eventDef.NET_BANK_TRANSFER_RESULT)
end

function sub_transfer:ctor(args)
    self.m_root = args.root
    self:initUI()
    self:initMemberSearch()
    self.mm_Panel_user:hide()
    self.m_currencyType = g_format.currencyType.GOLD
    G_event:AddNotifyEvent(G_eventDef.EVENT_MEMBERINFO, handler(self, self.onQueryMemberInfoClick)) --搜索会员
    G_event:AddNotifyEvent(G_eventDef.NET_BANK_TRANSFER_RESULT, handler(self, self.onChangeMoneyClick)) --转账返回飘动作
end

function sub_transfer:initUI()
    self.inputMoney = self.mm_TextField_Money:convertToEditBox(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
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

    --转移
    self.mm_ButtonMakeOver:onClicked(
        function()
            self:onTransferClick()
        end,
        true
    )
end

--获取是否忽略小数位
function sub_transfer:isIgnoreDecimal()
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

function sub_transfer:getCurrScore()
    if self.m_currencyType == g_format.currencyType.TC then
        return self.mm_TextBagMoney.userData
    else
        return self.mm_TextBagMoney.userData
    end
end

function sub_transfer:selectCurrencyType(type)
    self.m_currencyType = type
    if type == g_format.currencyType.TC then
        self.mm_ImageBank1_tc:show()
        self.mm_ImageBank1:hide()
    else
        self.mm_ImageBank1_tc:hide()
        self.mm_ImageBank1:show()
    end
    self:changeUIData()
end

function sub_transfer:selectBehaviorType(behaviorType)
    self.m_behaviorType = behaviorType
    self:changeUIData()
end

function sub_transfer:changeUIData()
    if self.m_currencyType == nil then return end
    if self.m_behaviorType == nil then return end

    local bankScore = GlobalUserItem.lUserInsure
    if self.m_currencyType == g_format.currencyType.TC then
        bankScore = GlobalUserItem.lTCCoinInsure
    end
    self.mm_TextBagMoney.userData = bankScore
    local str = g_format:formatNumber(bankScore,g_format.fType.standard,self.m_currencyType)
    self.mm_TextBagMoney:setString(str)
end

function sub_transfer:onTransferClick()
    local number = self.inputMoney:getText()
    -- number = g_format:inputFormat(number)
    -- number = string.gsub(number, "[^0-9]", "")
    self.inputNumber = g_format:inputFormat(number,self.m_currencyType)
    if self.mm_Panel_search:isVisible() then
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

    --查询用户成功
function sub_transfer:QueryTransferUser(args)

    local csbNode = g_ExternalFun.loadCSB("bank_new/reconfirmLayer.csb")
    self.m_root:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(csbNode,csbNode)
    
    csbNode.mm_bg:onClicked(
        function()
            csbNode:removeSelf()
        end
    )
    ShowCommonLayerAction(csbNode.mm_bg, csbNode.mm_content)
    csbNode.mm_Text_gold:setString(g_format:formatNumber(self.inputNumber,g_format.fType.standard,self.m_currencyType))
    csbNode.mm_TextUserID:setString(string.format("(ID:%s)", self.currUserData.GameID))
    csbNode.mm_TextUserName:setString(self.currUserData.NickName)
    --头像
    HeadSprite.loadHeadImg(csbNode.mm_ImageUserHead, self.currUserData.GameID, self.currUserData.FaceID, true)

    csbNode.mm_btnConfirm:onClicked(
        function()
            local score = tonumber(self.inputNumber)
            --转账参数：金额，银行密码,转出ID
            -- if self.m_currencyType == g_format.currencyType.TC then
            --     score = score * 100
            -- end
            if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then 
                --转账参数：金额，银行密码,转出ID
                G_ServerMgr:C2S_TransferScore(tonumber(score), self.currUserData.GameID)
            else
                self.m_root.bankData:C2S_RequestUserTransferScoreEx(self.m_currencyType,score, self.currUserData.GameID)
            end
            csbNode:removeSelf()
            DoHideCommonLayerAction(csbNode.mm_bg,csbNode.mm_nodes,
                function()
                end
            )
        end
    )

    csbNode.mm_btnCancel:onClicked(
        function()
            csbNode:removeSelf()
            DoHideCommonLayerAction(csbNode.mm_bg,csbNode.mm_nodes,
                function()
                end
            )
        end
    )
    -- end
end
--81115599
function sub_transfer:onChangeMoneyClick(pData)

    if pData.dwResultCode == 0 then
        -- self.inputMoney:setText("0")
    else
        return 
    end
    -- 动画目标点
    local pos = cc.p(self.mm_AtlasLabel_number:getPosition())  
    local pNode = self.mm_Panel_user

    if pData.cbCurrencyType == 1 then

    else

    end

    self:toRightAction(
        pNode,
        function()
        end,
        function()
            self:moveGold(self.mm_AtlasLabel_number, pData.llScore, pos, false)
            self:changeUIData()
        end,
        true
    )
end

function sub_transfer:toRightAction(parentNode, preCallback, afterCallback)
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
function sub_transfer:moveGold(node, goldNum, pos, addOrTo)
    if goldNum == nil then
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
    local move1 = cc.MoveTo:create(0.2, cc.p(pos.x, 30))
    local detime = cc.DelayTime:create(0.5)
    local move3 = cc.MoveTo:create(1.3, cc.p(pos.x, 150))

    local fadeIn = cc.FadeIn:create(0.2)
    local fadeOut = cc.FadeOut:create(1.3)
    local spawn1 = cc.Spawn:create(move1, fadeIn)
    local spawn2 = cc.Spawn:create(move3, fadeOut)

    node:runAction(cc.Sequence:create(spawn1, detime, spawn2))
end

--------------------------------会员搜索---------------------------
function sub_transfer:initMemberSearch()
    self.searchInput = self.mm_TextField_search:convertToEditBox(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
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

    self.mm_ButtonSearch:onClicked(
        function()
            if self.searchID then
                if ylAll.ProjectSelect and ylAll.ProjectSelect == 2 then 
                    G_ServerMgr:C2S_RequesMemberInfo(self.searchID)
                else
                    self.m_root.bankData:C2S_RequestMemberInfo(self.searchID)
                end
            end
        end
    )

    self.mm_ButtonCloseUser:onClicked(function() 
        self.mm_Panel_search:show()
        self.mm_Panel_user:hide()
    end)
end

function sub_transfer:onQueryMemberInfoClick(args)
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

function sub_transfer:updataCurrUser(userData,isMember)
    dump(userData)
    if table.isEmpty(userData) then
        return
    end
    self.currUserData = userData
    self.mm_Panel_search:hide()
    self.mm_TextUserName:setText(userData.NickName)
    self.mm_TextUserID:setText(userData.GameID)

    --头像
    HeadSprite.loadHeadImg(self.mm_ImageUserHead, userData.GameID, userData.FaceID, true)
    self.mm_Panel_user:show()

    if isMember then
        self.mm_ButtonCloseUser:hide()
    end
end

return sub_transfer