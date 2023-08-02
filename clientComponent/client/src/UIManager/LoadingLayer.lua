
function showNetLoading(callback)
    dismissNetLoading()
    local scene = cc.Director:getInstance():getRunningScene()
    local csbNode = g_ExternalFun.loadCSB("LoadingNormal.csb")
    csbNode:setName("net_loading")
    scene:addChild(csbNode,100000)
    csbNode:setPosition(display.center)
    local bg = csbNode:getChildByName("bg")
    bg:setContentSize(display.size)
    local nodeContent = csbNode:getChildByName("node")
    nodeContent:hide()
    local bg2 = nodeContent:getChildByName("bg")
    bg2:setContentSize(display.size)

    local descNode = nodeContent:getChildByName("Text_desc")
    local descStr = descNode:getString()
    local nodeAction = g_ExternalFun.loadTimeLine("LoadingNormal.csb")
    nodeAction:play("animation0",true)
    csbNode:runAction(nodeAction)

    -- csbNode:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
        nodeContent:show()
    -- end)))

    csbNode:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function()
        if callback and type(callback) == "function" then
            callback()
        end
        dismissNetLoading()
    end)))

    local index  = 0
    csbNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.7),cc.CallFunc:create(function() 
        index = index + 1
        if index >= 4 then index = 1 end
        local pointStr = " "
        for i=1,index do
            pointStr = pointStr.."."
        end
        descNode:setString(descStr..pointStr)
    end))))
end

function netLoadingShowing()
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = scene:getChildByName("net_loading")
    if tolua.cast(layer,"cc.layer") then
        return true
    end
    return false
end

function dismissNetLoading()
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = scene:getChildByName("net_loading")
    if tolua.cast(layer,"cc.layer") then
        layer:stopAllActions()
        layer:removeFromParent()
    end
end

function showSmallLoading()
    hideSmallLoading()
    local scene = cc.Director:getInstance():getRunningScene()
    local csbNode = g_ExternalFun.loadCSB("Node_smallLoading.csb")
    csbNode:setName("net_small_loading")
    scene:addChild(csbNode,100000)
    csbNode:setPosition(display.center)
    local bg = csbNode:getChildByName("bg")
    bg:setContentSize(display.size)
    local circle = csbNode:getChildByName("Image_smallLoading")
    circle:runAction(cc.RepeatForever:create(cc.RotateTo:create(2, 720)))
    csbNode:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function()
        hideSmallLoading()
    end)))
end

function hideSmallLoading()
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = scene:getChildByName("net_small_loading")
    if tolua.cast(layer,"cc.layer") then
        layer:stopAllActions()
        layer:removeFromParent()
    end
end

function onRequestIpAddress()
    showNetLoading()
    local ipConfigHttp = ylAll.Request_HttpUrl.."brazil_IpList.json"
    appdf.onHttpJsionTable(ipConfigHttp,"GET","",
        function(jsondata,response)
            if jsondata then
                dismissNetLoading()
                if NET_SECOND_OPTIMIZE_OPEN then
                    --支持网络二次优化
                    local newServerListCDN = {}
                    local bHaveServerCDN = false
                    local ipMaxCountCDN = tonumber(jsondata["IpMaxCountCDN2"]) or 10
                    for i=1,ipMaxCountCDN do  --最多配10个域名列表 
                        if not jsondata["ServerListCDN2"] then break end
                        local id = jsondata["ServerListCDN2"][ string.format("id%d",i)]
                        local ip = jsondata["ServerListCDN2"][ string.format("ip%d",i)]
                        if id and ip then
                            table.insert(newServerListCDN,{id=id,ip=ip})
                            bHaveServerCDN = true
                        end
                    end
                    if not ylAll.LocalTest and bHaveServerCDN == true then
                        ylAll.LOGONSERVER_LIST = newServerListCDN
                    end
                    for i,v in pairs(ylAll.LOGONSERVER_LIST) do
                        CCInitTesterServer(v.id,v.ip) 
                    end
                else
                    if NET_OPTIMIZE_OPEN then
                        --支持网络优化
                        local newServerListCDN = {}
                        local bHaveServerCDN = false
                        local ipMaxCountCDN = tonumber(jsondata["IpMaxCountCDN"]) or 10
                        for i=1,ipMaxCountCDN do  --最多配10个域名列表 
                            if not jsondata["ServerListCDN"] then break end
                            local id = jsondata["ServerListCDN"][ string.format("id%d",i)]
                            local ip = jsondata["ServerListCDN"][ string.format("ip%d",i)]
                            if id and ip then
                                table.insert(newServerListCDN,{id=id,ip=ip})
                                bHaveServerCDN = true
                            end
                        end
                        if not ylAll.LocalTest and bHaveServerCDN == true then
                            ylAll.LOGONSERVER_LIST = newServerListCDN
                        end
                        for i,v in pairs(ylAll.LOGONSERVER_LIST) do
                            CCInitTesterServer(v.id,v.ip) 
                        end
                    else
                        local newServerList = {}
                        local bHaveServer = false
                        local ipMaxCount = tonumber(jsondata["IpMaxCount"]) or 10
                        for i=1,ipMaxCount do  --
                            if not jsondata["ServerList"] then break end
                            local id = jsondata["ServerList"][ string.format("id%d",i)]
                            local ip = jsondata["ServerList"][ string.format("ip%d",i)]
                            if id and ip then
                                table.insert(newServerList,{id=id,ip=ip})
                                bHaveServer = true
                            end
                        end    
                        if not ylAll.LocalTest and bHaveServer == true then
                            ylAll.LOGONSERVER_LIST = newServerList
                        end
                        for i,v in pairs(ylAll.LOGONSERVER_LIST) do
                            CCInitTesterServer(v.id,v.ip) 
                        end
                    end
                end

                local netDelayData = jsondata["networkData"]
                for i=1,7 do
                    if not netDelayData then break end
                    local _value = netDelayData[tostring(i)]
                    table.insert(ylAll.NormalNetDelay,_value or 0)
                end
                if #ylAll.NormalNetDelay > 0 then
                    CCSetNetworkDelayTime(ylAll.NormalNetDelay[1],ylAll.NormalNetDelay[2],ylAll.NormalNetDelay[3],ylAll.NormalNetDelay[4],ylAll.NormalNetDelay[5],ylAll.NormalNetDelay[6],ylAll.NormalNetDelay[7])
                end
            end
        end
    )
end