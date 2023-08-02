--[[
***
***短信验证页面
]]
local HallMessageLayer =
    class(
    "HallMessageLayer",
    function(args)
        local HallMessageLayer = display.newLayer()
        return HallMessageLayer
    end
)
m_MsgTimeMgr = appdf.req(appdf.CLIENT_SRC.."UIManager.hall.subinterface.authentication.MsgTimeMgr").new()

-- local scheduler = cc.Director:getInstance():getScheduler()

function HallMessageLayer:onExit()
    G_event:RemoveNotifyEvent(G_eventDef.NET_SMS_URL_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.EVENT_BIND_MOBILE_RESULT)
    G_event:RemoveNotifyEvent(G_eventDef.UPDATE_MSG_TIME)
end

function HallMessageLayer:ctor(args)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self.callback = args and args.callback
    self.NoticeNext = args and args.NoticeNext
    self.ShowType = args and args.ShowType
    
    local csbNode = g_ExternalFun.loadCSB("message/HallMessageLayer.csb")
    self:addChild(csbNode)
    g_ExternalFun.loadChildrenHandler(self,csbNode)
    ShowCommonLayerAction(self.mm_bg, self.mm_Panel_content)

    self.mm_bg:onClicked(handler(self, self.onClickClose), true)
    self.mm_btn_close:onClicked(handler(self, self.onClickClose), true)
    --手机号
    self.inputTelephone = self.mm_inputTelephone:convertToEditBox(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    --验证码
    self.inputCode = self.mm_inputCode:convertToEditBox(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.inputTelephone:setMaxLength(11)
    self.inputCode:setMaxLength(6)
    self.inputTelephone:setPlaceHolder(g_language:getString("input_tel"))
    self.inputCode:setPlaceHolder(g_language:getString("input_code"))
    self.inputTelephone:setPlaceholderFontColor(cc.c3b(187,188,193))
    self.inputCode:setPlaceholderFontColor(cc.c3b(187,188,193))
    self.m_phoneNumber = cc.UserDefault:getInstance():getStringForKey("TELEPHONE","")
    if self.m_phoneNumber~="" then        
        self.inputTelephone:setString(self.m_phoneNumber)
    end
    self.inputTelephone:registerScriptEditBoxHandler(
        function(eventType,pObj) 
            if eventType == "return"then
                local phoneNum = pObj:getText()
                if phoneNum == nil then
                    return 
                end
                local number = string.gsub(phoneNum, "[^0-9]", "")
                if number == "" then
                    return
                end
                pObj:setText(number)
            elseif eventType == "began" then

            end
        end
    )
    --获取验证码
    self.mm_btn_getCode:onClicked(
        function()
            self:onClickSendMsg()
        end,
        true
    )
    --开始验证、开始登录
    self.mm_btn_checkCode:onClicked(
        function()
            self:onClickVerifyMsg()
        end,
        true
    )
    if self.ShowType and self.ShowType == 2 then
        self:playSpine(self.mm_Spine_bg,"renzheng_2","daiji2")
        self:playSpine(self.mm_btn_checkCode,"anniu","daiji2",cc.p(120,30))
        self.mm_TipsReward:hide()
    else
        self:playSpine(self.mm_Spine_bg,"renzheng_2","daiji")
        self:playSpine(self.mm_btn_checkCode,"anniu","daiji",cc.p(120,30))                
        local pValue = g_format:formatNumber(GlobalData.BindingInfo.lRewardScore, g_format.fType.Custom_1)
        self.mm_RewardValue:setString("+"..pValue)
        self.mm_TipsReward:show()
    end    
    
    self:playSpine(self.mm_Spine_pre,"renzheng_1","daiji")

    self:getMyIP()
    self:showLabel()
    G_event:AddNotifyEvent(G_eventDef.NET_SMS_URL_RESULT, handler(self, self.onSmsUrlResultNew))
    G_event:AddNotifyEvent(G_eventDef.EVENT_BIND_MOBILE_RESULT, handler(self, self.onBindMobileResultCallback))
    G_event:AddNotifyEvent(G_eventDef.UPDATE_MSG_TIME, handler(self, self.onUpdate))
end

function HallMessageLayer:playSpine(pNode,spinePath,animName,pos,callback)
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

function HallMessageLayer:onUpdate(data)
    --print("定时器=======", data)
    self.mm_coolTime:setString("("..data..'S)')
    self:showLabel()
end

function HallMessageLayer:showLabel()
    local start = m_MsgTimeMgr:getStart()
    if start then 
        self.mm_coolTime:setVisible(true)
        self.mm_btn_getCode:setEnabled(false)
    else
        self.mm_coolTime:setVisible(false)
        self.mm_btn_getCode:setEnabled(true)
    end
end

-- 发送短信
function HallMessageLayer:onClickSendMsg()
    local start = m_MsgTimeMgr:getStart()
    if start then
        return
    end
    local pTelephone = "0055" .. self.inputTelephone:getString()
    local len = string.len(pTelephone)
    if pTelephone == "" or len ~= 15 then
        showToast(g_language:getString("tel_error_1"))
        return
    end
    --短信验证url
    --G_ServerMgr:C2S_RequestSMSUrl()
    self:sendDuanXinMsg(pTelephone)
    m_MsgTimeMgr:startScheduler()
    m_MsgTimeMgr:setStart(true)
end

-- 验证短信
function HallMessageLayer:onClickVerifyMsg()    
    --电话
    local pTelephone = "0055" .. self.inputTelephone:getString()
    --验证码
    local pCode = self.inputCode:getString()    
    if pTelephone == "" or string.len(pTelephone) ~= 15 then
        showToast(g_language:getString("tel_error_1"))
        return
    end
    if pCode == "" or string.len(pCode) ~= 6 then
        showToast(g_language:getString("input_code"))
        return
    end
    if self.ShowType and self.ShowType == 2 then
        G_event:NotifyEvent(G_eventDef.EVENT_START_PHONE_LOGIN,{PhoneString = pTelephone,CodeString = pCode})
    else
        G_ServerMgr:C2S_RequestBindMsg(pTelephone, pCode, self.myip)
    end
    --showNetLoading()
end

function HallMessageLayer:getMyIP()
    self.myip = "127.0.0.1"
    local info = {
        url = "https://ifconfig.me/ip",
        callback = function(ok, response)
            -- print("myIp = ", response)
            self.myip = response
        end
    }
    http.get(info)
end

function HallMessageLayer:sendDuanXinMsg(pTelephone)
    G_ServerMgr:C2S_RequestPhoneCode(pTelephone,self.ShowType)
end

--发送验证码成功后的返回
function HallMessageLayer:onSmsUrlResultNew(data)
    local dwRestSecond = data.dwRestSecond
    local dwErrorCode = data.dwErrorCode
    if dwErrorCode == 0 then                --发送短信成功
        m_MsgTimeMgr:startScheduler()
        m_MsgTimeMgr:setStart(true) 
    elseif dwErrorCode == 1010 then   --否则太频繁失败!
        if dwRestSecond > 0 then
            m_MsgTimeMgr:setRemainTime(dwRestSecond)
        end
        m_MsgTimeMgr:startScheduler()
        m_MsgTimeMgr:setStart(true) 
    end
end

function HallMessageLayer:onSmsUrlResult(data)
    self.mm_btn_getCode:setTouchEnabled(true)
    local userId = GlobalUserItem.dwUserID
    local tel = self.inputTelephone:getString()
    local mobile = "0055" .. tel
    local dynamicPass = GlobalUserItem.szDynamicPass
    local ipConfigHttp = data .. "?userID=" .. userId .. "&mobile=" .. mobile .. "&dynamicPass=" .. dynamicPass.. "&type=" .. self.ShowType
    appdf.onHttpJsionTable(
        ipConfigHttp,
        "GET",
        "",
        function(jsondata, response)
            if jsondata then
                if jsondata.dwErrorCode > 0 then
                    showToast(g_language:getString(jsondata.dwErrorCode))
                    -- if jsondata.restSecond and type(jsondata.restSecond)=="number" then
                    --     m_MsgTimeMgr:setRemainTime(jsondata.restSecond)
                    --     m_MsgTimeMgr:startScheduler()
                    --     m_MsgTimeMgr:setStart(true)
                    -- end
                else
                    m_MsgTimeMgr:startScheduler()
                    m_MsgTimeMgr:setStart(true)
                end
            else
                showToast(g_language:getString("tel_error_2"))
                print("发送验证码失败")
            end
        end
    )
    cc.UserDefault:getInstance():setStringForKey("TELEPHONE",tel) --手机号码
    cc.UserDefault:getInstance():flush()
end

function HallMessageLayer:onBindMobileResultCallback(data)
    if data.dwErrorCode == 0 then 
        G_event:NotifyEvent(G_eventDef.UI_SHOW_GUIDE,{})
        self:showAward(data.lRewardScore, "client/res/public/mrrw_jb_3.png")       
        self:onClickClose()
        if self.callback then
            self.callback()
        end
    elseif data.dwErrorCode > 1000 then  --1004 ~ 1007
        showToast(g_language:getString(data.dwErrorCode))
    end
end

function HallMessageLayer:showAward(goldTxt, goldImg)
    local path = "client.src.UIManager.hall.subinterface.rewardLayer"
    local data = {}
    data.goldTxt = g_format:formatNumber(goldTxt, g_format.fType.standard)
    data.goldImg = goldImg
    data.type = 1
    appdf.req(path).new(data)
end

function HallMessageLayer:onClickClose()
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

return HallMessageLayer
