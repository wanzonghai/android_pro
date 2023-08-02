FunctionMapping = function(funcKey)
    local resultFunctionName = funcKey
    print("=============resultFunctionName 111:",resultFunctionName)
    if FunctionName and FunctionName[funcKey] and FunctionName[funcKey]~="" then
        resultFunctionName = FunctionName[funcKey]
    end
    print("=============resultFunctionName 222:",resultFunctionName)
    return resultFunctionName
end

FunctionAfLogName = function(funcKey)
    local resultFunctionName = funcKey
    if AfLogEventName and AfLogEventName[funcKey] and AfLogEventName[funcKey]~="" then
        resultFunctionName = AfLogEventName[funcKey]
    end
    return resultFunctionName
end

FunctionADLogName = function(funcKey)
    local resultFunctionName = funcKey
    if ADLogEventName and ADLogEventName[funcKey] and ADLogEventName[funcKey]~="" then
        resultFunctionName = ADLogEventName[funcKey]
    end
    return resultFunctionName
end

-- AfLogEventName = {
--     event_type="af_complete_registration",    --事件名称
--     event_fire="sign_up",                     --自定义名称
--     af_content_id=312344,                     --事件id
--     af_revenue="af_revenue"                   --金额
-- }