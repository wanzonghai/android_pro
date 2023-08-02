local BaseLayer = appdf.req(appdf.CLIENT_SRC.."UIManager.BaseLayer")
local SharePhoneLayer = class("SharePhoneLayer",BaseLayer)

function SharePhoneLayer:ctor(args)
    SharePhoneLayer.super.ctor(self)
    local parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    self:loadLayer("ShareTurnTable/sharePhone.csb")
    self:init()
end

function SharePhoneLayer:init()
    self.itemTab_ = {}
    self.phoneData_ = {}
    self._copyNumber = nil
    self.listView = self:getChildByName("listView")
    self.listView:hide()
    self.loadText = self:getChildByName("loadText")
    self.bg = self:getChildByName("bg")
    self.content = self:getChildByName("content")
    self.clonePanel1 = self.listView:getChildByName("clonePanel1")
    self.clonePanel2 = self.listView:getChildByName("clonePanel2")
    self.clonePanel3 = self.listView:getChildByName("clonePanel3")
    self.listView:setScrollBarEnabled(false)
    local sum = 1
    for k = 1,2 do
        local clonePanel = self["clonePanel"..k]
        for p = 1,3 do
            local item = clonePanel:getChildByName("item"..p)
            self.itemTab_[#self.itemTab_ + 1] = item
            item:setTouchEnabled(true)
            item:hide()
        end
    end
    self.closeBtn = self:getChildByName("closeBtn")
    self.changeBtn = self:getChildByName("changeBtn")
    self.closeBtn:addTouchEventListener(handler(self,self.onTouch))
    self.changeBtn:addTouchEventListener(handler(self,self.onTouch))
    G_event:AddNotifyEvent(G_eventDef.EVENT_SHAREPHONE_DATA,handler(self,self.onPhoneShareCallback))
    ShowCommonLayerAction(self.bg,self.content)
    self:doDisplay()
end

function SharePhoneLayer:onExit()
    SharePhoneLayer.super.onExit(self)
    G_event.RemoveNotifyEvent(G_eventDef.EVENT_SHAREPHONE_DATA)
end

function SharePhoneLayer:onTouch(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender == self.closeBtn then
            self:close()
        elseif sender == self.inviteBtn then
            if self._copyNumber then
                local url = "https://wa.me/"..self._copyNumber
                OSUtil.openURL(url)
                self._copyNumber = nil
            else
                showToast("Por favor, copie o número de telefone primeiro.")            --请先复制电话号码
            end
        elseif sender == self.changeBtn then
            if #self.phoneData_ < 9 then
                self:requestData()
            else
                self:setListViewData()
            end
        end
    end
end

function SharePhoneLayer:doDisplay()
    self:requestData()
end

function SharePhoneLayer:requestData()
    showNetLoading()
    self.listView:hide()
    self.loadText:show()
    G_ServerMgr:requestSharePhoneData()
end

function SharePhoneLayer:onPhoneShareCallback(pData)
    dismissNetLoading()
    local packSize = pData:getlen() -- size = 240 bytes
    local mobileLenth = 16          -- 国际手机号码长度（定长）c风格字符串会比实际长度多一个字节
    local result = {}   
    local count = packSize / mobileLenth    -- 手机的个数=封包长度除以单个手机号码的长度
    for i = 1, count, 1 do
        local mobile = pData:readutf8(mobileLenth)	-- ps: utf8编码,纯数字
        if mobile ~= nil then
            local len = string.len(mobile)
            -- 11位表示没有0055 13位表示有55 15位表示0055+手机号码
            if len == 11 then
                mobile = "55"..mobile
                result[#result + 1]= mobile  
            elseif len == 13 then
                mobile = mobile
                result[#result + 1]= mobile
            elseif len == 15 then
                -- 去掉国家码(00 or 0055)
                mobile = string.sub(mobile, len-12)
                result[#result + 1]= mobile
                 -- 去重（也可用数组不去重，10000个中随机15个重复的概率不大）
                -- table.insert(result,mobile)
            else
                print("非法的手机号码，跳过")
            end
        end
    end
    self.listView:show()
    self.loadText:hide()
    self.phoneData_ = result
    self:setListViewData()
    
end

function SharePhoneLayer:setListViewData()
    if #self.phoneData_ < 6 then
        return
    end

    for k = 1,6 do
        local phoneData = self.phoneData_[k]
        if phoneData then
            local item = self.itemTab_[k]
            local phoneNumber = item:getChildByName("phoneNumber")
            item:onClicked(nil)
            phoneNumber:setString(phoneData)
            phoneNumber:setPositionX(124)
            item:show()
            table.remove(self.phoneData_,1)
            item:onClicked(function() 
                self._copyNumber = phoneData
                local url = "https://wa.me/"..phoneData
                local pExtraStr = self:shareStr()
                url  = url .. "?text=" .. pExtraStr
                OSUtil.openURL(url)
                -- self:shareStr()
            end)
        end
    end
end

function SharePhoneLayer:shareStr()
    local isok,userStr = self:number2string(GlobalUserItem.dwUserID,"")
    
    local config = GlobalUserItem.MAIN_SCENE.m_shareConfig
    local str = config.szShareUrl
    local l = string.sub(str,-1)
    if l == "/" then
        str =  string.sub(str,1,string.len(str)-1)
    end
    local result = str.."/spd_"..userStr..'.shtml'
    local res, msg = g_MultiPlatform:getInstance():copyToClipboard(result)
    showToast(g_language:getString("copy_success")) 
    return result
end

function SharePhoneLayer:number2string(user_id, str)
    local baseStrings = {
        "ABCDEFGHJKMNPQRSTWXY",
        "abcdefhijkmnprstwxyz"
    }
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    user_id = tostring(user_id)
    local len = string.len( user_id ) 
    local key_len = string.len( baseStrings[1] )

    for i=1,len do
        local s = tonumber(string.sub(user_id,i,i))
        local rand =math.random(1,100)
        local r1 = math.fmod(rand,2)+1
        rand =math.random(1,100)
        local r2 = math.fmod(rand,2)+1
        if s == 0 then
            s = 9
        else
            s = s - 1
        end
        if (s * 2 + r2) > key_len then
            return false;
        end
        str = str..string.sub(baseStrings[r1],s*2+r2,s*2+r2)
    end
    return true,str
end

return SharePhoneLayer