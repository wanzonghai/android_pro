-------------------------------------------------------------------------
-- Content:  日志打印Log
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--log相关
--------------------------------------------------------------------------
--请使用tlog
tlog = function(...)
    if DEBUG > 2 then
        local content = ""
        for k,v in ipairs( {...} ) do
            content = content..tostring( v ).." "
        end        
        print( os.date("[%Y-%m-%d %H:%M:%S] ", os.time())..content )
    end
end

local function tdump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function tdump(value, desciption, nesting)
    if (DEBUG < 3) then
        --三级Debug Level以下，或者关闭写dump，则直接return
        return
    end 
       
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    tlog("dump from: " .. string.trim(traceback[3]))

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(tdump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent or "", tdump_value_(desciption) or "", spc or "", tdump_value_(value) or "")
        -- elseif lookupTable[tostring(value)] then
        --     result[#result +1 ] = string.format("%s%s%s = *REF*", indent, tdump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent or "", tdump_value_(desciption) or "")
            else
                result[#result +1 ] = string.format("%s%s = {", indent or "", tdump_value_(desciption) or "")
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = tdump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent or "")
            end
        end
    end
    dump_(value, desciption, "- ", 1)
	
    for i, line in ipairs(result) do
        print(line)    
    end
end

--写文件日志
fileprint = function(...)
    -- if DEBUG >= 2 then
        local content = ""
        for k,v in ipairs( {...} ) do
            content = content..tostring( v ).." "
        end
        
        print( os.date("[%Y-%m-%d %H:%M:%S] ", os.time())..content )
        local hfile = nil
        if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
            local dir = cc.FileUtils:getInstance():getWritablePath().."logfile.txt"
            hfile = io.open(dir, "a+")
            hfile:write(  os.date("[%Y-%m-%d %H:%M:%S] ", os.time())..content .."\n" )
            hfile:close()
        end
    -- end
end
function filedump(value, desciption, nesting)
    if (DEBUG < 3) then
        --三级Debug Level以下，或者关闭写dump，则直接return
        return
    end 
       
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    tlog("dump from: " .. string.trim(traceback[3]))

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(tdump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent or "", tdump_value_(desciption) or "", spc or "", tdump_value_(value) or "")
        -- elseif lookupTable[tostring(value)] then
        --     result[#result +1 ] = string.format("%s%s%s = *REF*", indent, tdump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent or "", tdump_value_(desciption) or "")
            else
                result[#result +1 ] = string.format("%s%s = {", indent or "", tdump_value_(desciption) or "")
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = tdump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent or "")
            end
        end
    end
    dump_(value, desciption, "- ", 1)
    --写日志文件
    local hfile = nil
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        local dir = cc.FileUtils:getInstance():getWritablePath().."logfile.txt"
        hfile = io.open(dir, "a+")
        hfile:write( os.date("[%Y-%m-%d %H:%M:%S] ", os.time()).."\n" )
    end          
    for i, line in ipairs(result) do
        print(line)
        if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
            hfile:write( line.."\n" )
        end
    end
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        hfile:close()
    end
end

--[[重写错误堆栈捕获]]
__G__TRACKBACK__ = function(msg)
    print("--------------------------------------------------")  
    local msg = debug.traceback(msg, 3)
    -- appdf.onHttpJsionTable("debugreport.trucoclube.com","POST",msg,nil)
    -- appdf.onHttpJsionTable("http://192.168.1.230:3105/debugReport","POST",msg,nil)
    local error_msg = "LUA ERROR: " .. msg
    -- print(error_msg)
    fileprint(error_msg)
    -- if TestHelper then TestHelper.help_print("lua_error",error_msg) end
    print("--------------------------------------------------")

    if ylAll and ylAll.LocalTest and Msg then
        Msg:showErrorTip(msg)
    end

    local hfile = nil
    local message = msg
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        local dir = cc.FileUtils:getInstance():getWritablePath().."logfile.txt"
        hfile = io.open(dir, "a+")
        hfile:write( "LUA ERROR: " .."\n" )
        hfile:write( os.date("[%Y-%m-%d %H:%M:%S] ", os.time()).."\n" )
        hfile:write( msg .."\n" )
        hfile:close()
    elseif cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE or
        cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD or
        cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC then
    else
    end

    return error_msg
end