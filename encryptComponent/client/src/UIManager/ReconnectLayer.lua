
function onShowReconnectLayer(nType,callbackSure,callbackCancel)
    nType = nType or 1
    local scene = cc.Director:getInstance():getRunningScene()
    local child = scene:getChildByName("net_reconnect")
    if child then
        return 
    end
    local csbNode = g_ExternalFun.loadCSB("loading/layer_reconnect.csb")
    csbNode:setName("net_reconnect")
    scene:addChild(csbNode)
    local nodeTips = csbNode:getChildByName("nodeTips")
    local nodeRec = csbNode:getChildByName("nodeRec")
    local _node
    if nTpye == 1 then
        nodeTips:setVisible(true)
        nodeRec:setVisible(false)
        local spCircle = nodeTips:getChildByName("spCircle")
        spCircle:runAction(cc.RepeatForever:create(cc.RotateBy:create(1,360)))
        _node = nodeTips
    else
        _node = nodeRec
        nodeTips:setVisible(false)
        nodeRec:setVisible(true)
        local btnClose = nodeRec:getChildByName("btnClose")
        btnClose:onClicked(function()
            csbNode:removeSelf()
            applyFunction(callbackCancel)
        end,1)
        local btnSure = nodeRec:getChildByName("btnSure")
        btnSure:addTouchEventListener(function(ref,type)
            if type == ccui.TouchEventType.ended then
                csbNode:removeSelf()
                applyFunction(callbackSure)
            end
        end)           
    end
    _bg = csbNode:getChildByName("image_bg")
    ShowCommonLayerAction(_bg,_node)
end

function onDismissReconnect()
    local scene = cc.Director:getInstance():getRunningScene()
    local child = scene:getChildByName("net_reconnect")
    if tolua.cast(child,"cc.Layer") then
        child:removeSelf() 
    end
end