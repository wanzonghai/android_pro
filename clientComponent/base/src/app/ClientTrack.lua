--
-- 这个类里面尽量避免用lua框架的方法，因为是非常早起就载入，如果用到lua框架方法需要判断好
-- Author: xiao hui
-- Date: 2016-03-14 10:55:50
--

TRACK_GAME_LAUNCH = 100; -- 游戏启动
TRACK_SPLASH_SHOW_MKT = 110; --墨卡托闪屏开始
TRACK_SPLASH_HIDE_MKT = 111; --墨卡托闪屏结束

TRACK_CLIENT_RUN = 120; --clientrun 开始分散加载lua了,可以视为部署客户端阶段

TRACK_GAME_RUN = 130; --加载完lua
TRACK_MAP_READY_2_DEPLOY = 140; --地图开始部署
TRACK_MAP_DEPLOY_COMPLETE = 141; --地图部署完成

TRACK_SDK_READY_2_INIT = 150; --安卓初始化sdk


TRACK_LOGIN_SHOW = 160; --安卓初始化sdk完毕

TRACK_REQ_LOGIN_GUEST = 170; -- 非sdk 游客登陆
TRACK_REQ_LOGIN_GUEST_SUCCESS = 171; --非sdk 游客登陆成功

TRACK_REQ_REGITER = 180; --非sdk 注册
TRACK_REQ_REGITER_SUCCESS = 181; --非sdk 注册成功
TRACK_REQ_REGITER_TIMEOUT = 182; --非sdk 注册超时
TRACK_REQ_REGITER_ERROR_UNKNOW = 183; --非sdk 注册失败：未知
TRACK_REQ_REGITER_ERROR_NAME_INVALID = 184; --非sdk 注册失败：用户名不合法
TRACK_REQ_REGITER_ERROR_NAME_EXITS = 185; --非sdk 注册失败：用户名已存在

TRACK_CONNECT_SOCKET = 190; --连接socket,准备登陆
TRACK_CONNECT_SOCKET_TIME_OUT = 191; --连接socket超时

TRACK_REQ_LOGIN_USER_INFO = 200; --socket连接完毕,请求验证用户信息
TRACK_REQ_LOGIN_USER_INFO_ERROR = 202; --socket连接完毕,请求验证用户信息失败，没有账号或者密码错误之类的

TRACK_REQ_LOGIN_ROLE_LIST = 210; --用户验证成功，请求角色列表

TRACK_REQ_LOGIN_ROLE_CREATE = 220; -- 角色列表为空，需要请求创建角色

TRACK_REQ_LOGIN_ROLE_SELECT = 230; --角色不为空或者刚创好角色，选择角色

TRACK_REQ_LOGIN = 240; --登陆用户角色
TRACK_REQ_LOGIN_SUCCESS = 241; --登陆用户角色成功

TRACK_BEFORE_ENTER_GAME_REQ_ACHIEVE = 251; --loading时请求成就信息
TRACK_BEFORE_ENTER_GAME_REQ_JUDIAN = 252; --loading时请求据点信息
TRACK_BEFORE_ENTER_GAME_REQ_TASK = 253; --loading时请求任务数据
TRACK_BEFORE_ENTER_GAME_REQ_BAG = 254; --loading时请求背包数据
TRACK_BEFORE_ENTER_GAME_REQ_JDCB = 255; --loading时请求据点建筑数据
TRACK_BEFORE_ENTER_GAME_REQ_VIP = 256; --loading时请求vip数据

TRACK_SHOW_EARTH_VIDEO = 260; --新手看地球视频
TRACK_SHOW_EARTH_VIDEO_COMPLETE = 261; --新手看地球视频完成

TRACK_LOAD_ANSYNC_PIC_BEGIN = 270 --loading时预加载一些比较大的图片资源
TRACK_LOAD_ANSYNC_PIC_END = 271 --loading时预加载一些比较大的图片资源完毕

TRACK_AFTER_GAME_REQUEST_SOME_DATA_BEGIN = 280 --进入游戏后一些必须的数据请求（这个时候玩家不能点击游戏，只能看到主ui和地图界面）
TRACK_AFTER_GAME_REQUEST_SOME_DATA_END = 281 --进入游戏后一些必须的数据请求完毕

TRACK_ENTER_GAME = 290 --登陆完成，接下来是newbie的统计了


TRACK_HOTUPDATE_BEGIN = 1000 -- 更新开始时记录
TRACK_HOTUPDATE_SUCCESS = 1900 --更新成功记录


TRACK_LUA_ERROR = 0; -- 客户端代码报错
TRACK_MAP_COMBINE_ERROR = 10002; -- 客户端的统计：地图范围合并出错，通知晓聪
TRACK_HOTUPDATE_ERROR = 10003 -- 更新某一文件超时或者错误记录(附带错误url)
TRACK_REQ_REGITER_ERROR_NAME_ERROR = 10004; --非sdk 游客注册失败：(附带错误代码)
TRACK_REQ_LOGIN_GUEST_ERROR = 10005; --非sdk 游客登陆失败（附带错误status）

TRACK_SHENGSLOG = 127000001;

-- 仿照as3的encodeURI
-- url编码时对一些特殊符号进行编码，这个函数比cocos的string.urlencode少匹配了一些符号
-- 未编码的字符有下列：
-- 0 1 2 3 4 5 6 7 8 9
-- a b c d e f g h i j k l m n o p q r s t u v w x y z
-- A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
-- ; / ? : @ & = + $ , #
-- - _ . ! ~ * ' ( )
local _regEncodeURI = "([^a-zA-Z0-9%;%/%?%:%@%&%=%+%$%,%#%-%_%.%!%~%*%'%(%)])"
local function encodeURI(s)
    s = string.gsub(s, _regEncodeURI, function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

local URL_TURNS_DIC = {}
--同用接口轮训列表：https://smsapi.evilgril.com
URL_TURNS_DIC["https%://smsapi%.evilgril%.com"] = {
    "https://smsapi.evilgril.com",
    "https://smsapi.fay3.cn",
    "http://122.226.191.70:8080",
    "http://122.226.191.78:8080",
    "http://122.226.191.79:8080",
    "http://59.56.97.17:8080",
    "http://59.56.97.230:8080",
    "http://59.56.97.231:8080",
}

--热更新入口第一个4+1也配上，因为游戏中也会定期请求热更新版本，这个时候只用4+1中的第一个域名，一旦io error则调用别的
URL_TURNS_DIC["https%://lua%.game8301%.com"] = {
    "https://lua.game8301.com",
    "https://lua.amydog.com",
    "https://lua.365tbm.com",
    "https://lua.hnqdcw.com",
    "http://116.31.115.230:2018",
}

--支付接口轮询：https://pay.evilgril.com
--[[URL_TURNS_DIC["https%://pay%.evilgril%.com"] = {
    "https://pay.evilgril.com",
    "https://pay.fay3.cn",
    "https://mdspay.fay3.cn",
    "http://122.226.191.38:8080",
    "http://122.226.191.63:8080",
    "http://122.226.191.76:8080",
    "http://59.56.97.48:8080",
    "http://59.56.97.232:8080",
    "http://59.56.97.233:8080",
}--]]

local function findUrlTurnsConfig(url, timeOutTimeRest)
    local newUrl, cacheKey;
    for pattern,domains in pairs(URL_TURNS_DIC) do
        if string.find(url, pattern) then
            local index = (5 - timeOutTimeRest) + 1;
            if index < 1 then
                index = 1;
            end
            local domain = domains[index];
            if IS_TEST_HTTP_CACHE then
                domain = string.gsub(domain, "%/%/", "//shengsforbid.")
            end
            newUrl = string.gsub(url, pattern, domain);
            cacheKey = string.gsub(url, pattern, "");
            break;
        end
    end

    if not newUrl then
        newUrl = url;
        cacheKey = url;
    end

    return newUrl, cacheKey;
end

-- onTimeOut 请求超时，也就是请求失败时返回
function requestHttp(url, onComplete, onError, onProgress, onTimeOut, method, timeoutTimeInMS, postValueObj, notStartRequest, isNoLoading, isCheckLowSpeed, retryRestTime, needCacheHttp)
    --if true then return end
    if not isCheckLowSpeed then
        needCacheHttp = false;
    end
    retryRestTime = retryRestTime or 5;
    local urlbk = url;
    local cacheKey = nil;
    url, cacheKey = findUrlTurnsConfig(urlbk, retryRestTime);
    url = encodeURI(url);
    timeoutTimeInMS = timeoutTimeInMS or 5 * 1000;
    local request = nil;
    if not method or string.upper(tostring(method)) == "GET" then
        method = "GET"
    else
        method = "POST"
    end

    local hasShowloading = false
    local lowSpeedTimeOutS = 5; --模拟curl低速超时，但是我们是超时之后重新请求，cocos的XMLHttpRequest的abort只是底层return了而已，其实线程还在，请求没有停掉的

    local requestCheckId = 0;
    local curDlTotal = 0;
    local curDlTotalMark = 0;
    local byteTimeMark = 0;
    local hasAbort = false;

    local function hideLoading()
        if hasShowloading and popupMgr then
            popupMgr:hideActivityIndicator();
            hasShowloading = false
        end
    end

    local function logMsg(...)
        if trace then
            trace(...);
        else
            print(...);
        end
    end

    local function cancelCheckByteTimer()
        if requestCheckId ~= 0 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(requestCheckId);
            requestCheckId = 0;
        end
    end

    local function abortRequest()
        if request and not tolua.isnull(request) then
            request:abort()
            request = nil;
            hasAbort = true;
        end

        hideLoading()
    end

    local function reset(needAbortRequest)
        onComplete = nil
        onTimeOut = nil
        onError = nil
        cancelCheckByteTimer();
        abortRequest();
    end

    local function try2WriteCache(content)
        if needCacheHttp and cacheKey and mainMgr and mainMgr.writeHttpCache then
            mainMgr:writeHttpCache(cacheKey, content)
        end
    end

    local function try2ReadCache()
        local result = nil
        if needCacheHttp and cacheKey and mainMgr and mainMgr.readHttpCache then
            result = mainMgr:readHttpCache(cacheKey)
        end
        return result;
    end

    local function checkBytes(dtS)
        if not request or tolua.isnull(request) then
            cancelCheckByteTimer()
            return;
        end


        if curDlTotalMark == curDlTotal then
            --下载的数据没有任何变化
            byteTimeMark = byteTimeMark + dtS;
        else
            byteTimeMark = 0;
            curDlTotalMark = curDlTotal;
        end
        
        if byteTimeMark >= lowSpeedTimeOutS then
            logMsg("<font color = '#0000FF'>超过5秒没有任何流量，abort，重新请求：</font>", url)
            --超过5秒都没有任何数据，则abort掉，重新下载
            abortRequest()
            retryRestTime = retryRestTime - 1;
            if retryRestTime > 0 then
                requestHttp(urlbk, onComplete, onError, onProgress, onTimeOut, method, timeoutTimeInMS, postValueObj, notStartRequest, isNoLoading, isCheckLowSpeed, retryRestTime, needCacheHttp)
            else
                -- 超过低速超时重连最大次数，则认为是超时或者404
                local content = try2ReadCache();
                if content ~= "" and content ~= nil then
                    if onComplete then
                        --读取本地缓存
                        onComplete(content, url);
                    end
                else
                    if onTimeOut then
                        onTimeOut(url)
                    elseif onError then
                        onError(404, url)
                    end
                end
            end
            reset(true);
        end
    end

    local function callback(event, bytesWrite, bytesTotal)
        if hasAbort then
            return;
        end
        if isMobile then
            curDlTotal = bytesWrite or 0;
        end
        if event == "progress" then
            if onProgress then
                onProgress({ total = bytesTotal, dltotal = bytesWrite }, url);
            end
        else
            cancelCheckByteTimer()
            local status = request.status;
            local readyStatus = request.readyState;
            if popupMgr and not isNoLoading then
                hideLoading()
            end
            if readyStatus == 4 and (status >= 200 and status < 207) then
                try2WriteCache(request.response);
                if onComplete then
                    onComplete(request.response, url);
                end
            else
                abortRequest()
                retryRestTime = retryRestTime - 1;
                print("请求出错，readyStatus is:", readyStatus, "status is: ", status)
                if retryRestTime > 0 then
                    requestHttp(urlbk, onComplete, onError, onProgress, onTimeOut, method, timeoutTimeInMS, postValueObj, notStartRequest, isNoLoading, isCheckLowSpeed, retryRestTime, needCacheHttp)
                else
                    --读取本地缓存
                    local content = try2ReadCache();
                    if content ~= "" and content ~= nil then
                        if onComplete then
                            onComplete(content, url);
                        end
                    else
                        if status == 504 then
                            print("an onTimeOut occurs in http request:", url, " code:", status)
                            if onTimeOut then
                                onTimeOut(url)
                            end
                        else
                            print("an error occurs in http request:", url, " code:", status)
                            if onError then
                                onError(status, url)
                            end
                        end
                    end
                end
            end
        end
    end

    if isMobile and isCheckLowSpeed then
        requestCheckId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(checkBytes, 1, false);--1秒钟检查一次流量
    end

    request = cc.XMLHttpRequest:new()
    request.responseType = 0 --cc.XMLHTTPREQUEST_RESPONSE_STRING
    request:open(method, url)
    logMsg("尝试请求：", url)
    request:registerScriptHandler(callback)

    request.timeout = timeoutTimeInMS;
    local postDataStr = nil;
    if postValueObj and method == "POST" then
        for k, v in pairs(postValueObj) do
            if not postDataStr then
                postDataStr = ""
            else
                postDataStr = postDataStr .. "&"
            end
            postDataStr = postDataStr .. tostring(k) .. "=" .. tostring(v);
        end
        if postDataStr then
            --这行代码很关键，用来把字符串类型的参数序列化成Form Data
            request:setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        end
    end
    if not notStartRequest then
        if popupMgr and not isNoLoading then
            popupMgr:showActivityIndicator();
            hasShowloading = true
        end
        request:send(postDataStr)
    end

    return request;
end


-- 请求http时可以修改header modifyHeader是函数，函数需要参数，传递参数进行修改http请求头
-- onTimeOut 请求超时，也就是请求失败时返回
function requestHttpByHeader(url, onComplete, onError, onProgress, onTimeOut, method, modifyHeader, timeoutTimeInMS, postValueObj, notStartRequest, isNoLoading)

    local url = url
    local onComplete = onComplete
    local onError = onError
    local onProgress = onProgress
    local onTimeOut = onTimeOut
    local method = method
    local modifyHeader = modifyHeader
    local timeoutTimeInMS = timeoutTimeInMS
    local postValueObj = postValueObj
    local notStartRequest = notStartRequest
    local isNoLoading = isNoLoading

    if type(url) == "table" then
        -- 传递了一个table的描述进来 要拆分成为单个参数
        local tempData = url -- TODO 临时存储
        url = tempData.url
        onComplete = tempData.onComplete
        onError = tempData.onError
        onProgress = tempData.onProgress
        onTimeOut = tempData.onTimeOut
        method = tempData.method
        modifyHeader = tempData.modifyHeader
        timeoutTimeInMS = tempData.timeoutTimeInMS
        postValueObj = tempData.postValueObj
        notStartRequest = tempData.notStartRequest
        isNoLoading = tempData.isNoLoading
    end
    
    url = encodeURI(url);
    timeoutTimeInMS = timeoutTimeInMS or 5 * 1000;
    local request = nil;
    if not method or string.upper(tostring(method)) == "GET" then
        method = "GET"
    else
        method = "POST"
    end
    local function callback(event, bytesWrite, bytesTotal)
        if event == "progress" then
            if onProgress then
                onProgress({ total = bytesTotal, dltotal = bytesWrite }, url);
            end
        else
            local status = request.status;
            local readyStatus = request.readyState;
            if popupMgr and not isNoLoading then
                popupMgr:hideActivityIndicator();
            end
            if readyStatus == 4 and (status >= 200 and status < 207) then
                if onComplete then
                    onComplete(request.response, url);
                end
            else
                print("readyStatus is:", readyStatus, "status is: ", status)
                if status == 504 then
                    print("an onTimeOut occurs in http request:", url, " code:", status)
                    if onTimeOut then
                        onTimeOut(url)
                    end
                else
                    print("an error occurs in http request:", url, " code:", status)
                    if onError then
                        onError(status, url)
                    end
                end
            end
        end
    end

    request = cc.XMLHttpRequest:new()
    request.responseType = 0 --cc.XMLHTTPREQUEST_RESPONSE_STRING
    request:open(method, url)
    request:registerScriptHandler(callback)

    request.timeout = timeoutTimeInMS;
    local postDataStr = nil;
    if postValueObj and method == "POST" then
        for k, v in pairs(postValueObj) do
            if not postDataStr then
                postDataStr = ""
            else
                postDataStr = postDataStr .. "&"
            end
            postDataStr = postDataStr .. tostring(k) .. "=" .. tostring(v);
        end

        if postDataStr then
            --这行代码很关键，用来把字符串类型的参数序列化成Form Data
            request:setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        end
    end

    if modifyHeader ~= nil then
        modifyHeader(request)
    end

    if not notStartRequest then
        if popupMgr and not isNoLoading then
            popupMgr:showActivityIndicator();
        end
        request:send(postDataStr)
    end

    return request;
end

function requestHttpNoLoading(url, onComplete, onError, onProgress, onTimeOut, method, timeoutTimeInMS, postValueObj, notStartRequest)
    requestHttp(url, onComplete, onError, onProgress, onTimeOut, method, timeoutTimeInMS, postValueObj, notStartRequest, true);
end

local function cookDeviceLogInfo()
    local result = "--- package type:" .. tostring(PACKAGE_DEVICE_TYPE) .. "\n"
    local function getOtherInfo()
        if bridgeMgr then
            result = result .. "--- client version:" .. tostring(CLIENT_VERSION) .. "\n"
            result = result .. "--- phone model:" .. tostring(bridgeMgr:getPhoneModel()) .. "\n"
            result = result .. "--- os:" .. tostring(bridgeMgr:getPhoneOSVer()) .. "\n"
            result = result .. "--- machineid:" .. tostring(bridgeMgr:getPhoneUUId()) .. "\n"
            result = result .. "--- time:" .. tostring(DateUtil.getDateString(nil, 3)) .. "\n"
        end
    end
    result = result .. "---"
    xpcall(getOtherInfo, function()end)
    return result;
end

-- logStr 可能是文件的url、请求的次数。。等等，随着后续的增加可能越来越多,所以命名为logStr
function trackToServer(code, logStr)
    if isOutServer then
        local userId = 0;
        
        if TRACK_URL and requestHttpSign4Php then
            local paramDic = {};
            if Hero then
                paramDic.userId = Hero:getDwUserID() or 0;
            else
                paramDic.userId = 0;
            end
            logStr = cookDeviceLogInfo() .. (logStr or "");
            paramDic.trackCode = code;
            paramDic.data = logStr
            requestHttpSign4Php(TRACK_URL, paramDic, nil, nil, nil, true);
        end
    end
end

-- trackDic {code = {code =,  repeatCount = ,}}
_errorDic = _errorDic or {}
function traceError2Server(errorStr, errorCode)
    errorCode = errorCode or TRACK_LUA_ERROR
    if errorStr ~= nil and errorStr ~= "" then
        if _errorDic[errorStr] == nil then
            trackToServer(errorCode, errorStr)
            if traceErrorLog then
                traceErrorLog(errorStr)
            else
                print(errorStr)
            end
        end
        _errorDic[errorStr] = os.clock()
    end
end