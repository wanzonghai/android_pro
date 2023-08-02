-- local Msg = class("Msg", function()
--     return cc.LayerColor:create(cc.c4b(39,40,34,210))
-- end)

-- function Msg:ctor()
    
-- end

local Msg = class()

function Msg:showErrorTip(tips)
    local scene = CCDirector:getInstance():getRunningScene()
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,200))
    scene:addChild(layer,10001)

    local msgLab = ccui.Text:create(tips, "", 20)

    msgLab:setTextAreaSize(cc.size(display.width - 100,display.height-100))
    msgLab:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    msgLab:setColor(cc.c3b(255,255,255))
    msgLab:setPosition(display.width/2, display.height/2)
    layer:addChild(msgLab)

    local btnClose = ccui.Button:create('base/res/common/btnClose2.png',"","",ccui.TextureResType.localType)--ccui.TextureResType.plistType
    btnClose:setScale(0.5)
    :move(display.width - 50, display.height-50)
    :addTo(layer)
    local function onClickbtnClose(sender)
        layer:removeFromParent(true)
    end
    --btnClose:setTitleText('关闭')
    --btnClose:setTitleFontSize(40)
    btnClose:addClickEventListener(onClickbtnClose)
end

return Msg