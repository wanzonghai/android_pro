--[[
***
***
]]
local HallUserInfoLayer = class("HallUserInfoLayer",function(args)
		local HallUserInfoLayer =  display.newLayer()
    return HallUserInfoLayer
end)

function HallUserInfoLayer:ctor(args)
    parent = (args and args.parent) and args.parent or cc.Director:getInstance():getRunningScene()
    parent:addChild(self,ZORDER.POPUP)
    
    local csbNode = g_ExternalFun.loadCSB("userinfo/UserInfoLayer.csb")        
    self:addChild(csbNode)

    self.bg = csbNode:getChildByName("bg")
    self.content = csbNode:getChildByName("content")
    ShowCommonLayerAction(self.bg,self.content)

    self.bg:onClicked(handler(self,self.onClickClose),true)
    self.content:getChildByName("btnClose"):onClicked(handler(self,self.onClickClose),true)

    --head
    local headBg = self.content:getChildByName("headBg")
    local imgHead = headBg:getChildByName("imgHead")
    imgHead:setContentSize(cc.size(100,100))
    HeadSprite.loadHeadImg(imgHead,GlobalUserItem.dwGameID,GlobalUserItem.wFaceID)
    --ID
    headBg:getChildByName("txtID"):setString("ID:"..GlobalUserItem.dwGameID)
    --copy
    headBg:getChildByName("btnCopy"):onClicked(function()
        local res, msg = g_MultiPlatform:getInstance():copyToClipboard(tostring(GlobalUserItem.dwGameID))
        if res == true then
             showToast(g_language:getString("copy_success"))  
        end
    end)
    --nick
    self.content:getChildByName("nickValue"):setString(g_ExternalFun.RejectChinese(GlobalUserItem.szNickName))    
    --gold
    local str = g_format:formatNumber(GlobalUserItem.lUserScore,g_format.fType.standard,g_format.currencyType.GOLD)
    self.content:getChildByName("goldValue"):setString(str)
    --diamond
    str = g_format:formatNumber(GlobalUserItem.lTCCoinInsure,g_format.fType.standard)
    self.content:getChildByName("diamondValue"):setString(str)
    --sign
    local descBg = self.content:getChildByName("descBg")
    descBg:getChildByName("signValue"):setString(g_ExternalFun.RejectChinese(GlobalUserItem.szSign))    
end
function HallUserInfoLayer:onClickClose()
    DoHideCommonLayerAction(self.bg,self.content,function() self:removeSelf() end)
end


return HallUserInfoLayer