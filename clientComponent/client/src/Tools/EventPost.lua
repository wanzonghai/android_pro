local EventPost = class("EventPost")
-- 埋点事件地址url
-- local clickEventUrl = "http://172.17.18.240/api/client/logs/report"--开发
-- local clickEventUrl = "http://stat.wu6jv3.com/api/client/logs/report"--平行
local clickEventUrl = "https://stat.easygameapi.com/api/client/logs/report"--正式

local nowServerTime = os.time()             --服务器时间戳
local nowLocalTime = os.time()              --客户端时间戳
local eventList = {};                   --事件队列

EventPost.eventType = {
    CLICK = "click",              --点击
    BUY = "buy",                --购买
    PV = "pv",                 --pv
    ONLINE_TIME = "online_time",        --在线时长
    SHARE = "share",              --分享
    RANK = "rank",               --排行榜
    TASK = "task",               --任务
    SPIN = "spin",               --spin
    COLLECT = "collect"             --破产补助领取成功
}

--eventType点击类型
--desc描述
--price价格（如果购买了就填写）
--value
function EventPost:addCommond(eventType,desc,value,oneLineTime,ext_json)
    if (not GlobalData.serverTime) or (not GlobalData.serverTime.llServerTime) then return end

    local price =  ext_json and ext_json.betPrice or GlobalUserItem.lUserScore
    if value then
        for i, v in ipairs(GlobalData.ProductInfos) do
            local pListData = v
           if pListData and pListData.ProductInfos then
                for k,p in pairs(pListData.ProductInfos) do
                    if p and p.dwProductID == value then
                        if eventType == EventPost.eventType.BUY then
                            desc = string.format("购买%s%d成功！",pListData.szProductTypeName,k)
                        elseif eventType == EventPost.eventType.CLICK then
                            desc = string.format("点击商品%s%d",pListData.szProductTypeName,k)
                        end
                        price = p.dwPrice
                        break
                    end
                end
           end
        end
    end
    local params = {}
    params.value = value                --商品ID或者value值
    params.event = eventType
    params.desc = desc
    params.price = price 
    params.user_id = GlobalUserItem.dwGameID
    params.ip = GlobalData and GlobalData.MyIP
    params.event_time = os.date("%Y-%m-%d %H:%M:%S",GlobalData.serverTime.llServerTime  + GlobalData.serverTime.dwZone*3600)               --当前服务器时间+时区
    params.game_id = ext_json and ext_json.gameId or nil
    params.room_id = ext_json and ext_json.roomId or nil

    if eventType == EventPost.eventType.CLICK then          --点击事件，加入到队列里
        eventList[#eventList + 1] = params
    elseif eventType == EventPost.eventType.BUY then       --购买东西
        self:postUrl({params})    --直接上传                                
    elseif eventType == EventPost.eventType.PV then            --pv进场次数
        self:postUrl({params})    --直接上传  
    elseif eventType == EventPost.eventType.ONLINE_TIME then       --在线时长
        params.value = oneLineTime
        eventList[#eventList + 1] = params
    elseif eventType == EventPost.eventType.SHARE then             --分享
        eventList[#eventList + 1] = params
    elseif eventType == EventPost.eventType.RANK then          --排行榜点击
        eventList[#eventList + 1] = params
    elseif eventType == EventPost.eventType.TASK then          --任务点击
        eventList[#eventList + 1] = params
    elseif eventType == EventPost.eventType.SPIN then          --spin玩法
        self:postUrl({params})    --直接上传  
    elseif eventType == EventPost.eventType.COLLECT then       --破产领取
        self:postUrl({params})    --直接上传  
    end
end


function EventPost:postUrl(params)
    local callback = function(ok,jsonData) 
        if ok then
            if jsonData.code == 0 then
                print("withdraw conmit success")
            else
                print(string.format("code = %s,error:%s",jsonData.code,jsonData.msg))
            end
        else
            print("HTTP GET ERROR:",jsonData)
        end 
    end
    g_ExternalFun.onHttpJsionTable(clickEventUrl,"POST",cjson.encode(params),callback)
end

--隔一段时间保留一次服务器正确时间
function EventPost:setServerTime(time)
    nowServerTime = time or nowServerTime
    nowLocalTime = os.time()    --保留服务器时间戳的时候也保留一下本地时间戳
end

--得到当前正确时间
function EventPost:getServerTime()
    local tempTime = os.time() - nowLocalTime                   --距离上次获得服务器时间过了多久
    local serverTime = nowServerTime + tempTime                 --上次服务器时间戳加上过的这段时间就是正确服务器时间
    return serverTime
end

--把堆积的消息发出去
function EventPost:pushEventList()
    if eventList and #eventList > 0 then
        -- dump("EventPost 发送数据！")
        -- dump(eventList)
        self:postUrl(eventList)
        eventList = {}
    end
end

function EventPost:clear()

end

return EventPost