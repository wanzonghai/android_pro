--
-- Author: senji
-- Date: 2014-11-25 17:14:31
--

quick = quick or {};
quick._snapshots = {};


-- 这个api是不会检查加密情况的，直接用lua的api调用
-- 这样比较好的是如果文件出现\0截断不会丢失内容
-- 注意path要是绝对路径！
-- 注意！！！！android中如果不是读取可写路径的话，是永远读不到的，所以尽量避免io.open在android上读取非可写路径上的文件！
function io.readfileWithLuaApi(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function io.readfile(path)
    if CryptoLoaderManager_loadFile then
        --这个是自己绑定的函数，会进行解密（如果有），而且优点是不会被\0等中断
        return CryptoLoaderManager_loadFile(path)
    else
        --注意这个api会受\0中断，特别mp3等文件
        return cc.FileUtils:getInstance():getStringFromFile(path)
    end
end

function quick.gc(notTrace)
    local pre = collectgarbage("count");
    collectgarbage("collect");
    local now = collectgarbage("count");
    if not notTrace then
        traceLog(string.format("GC: <font color = '#FFFF00'>%0.2f KB</font>, reduce: %0.2fKB", now, pre - now));
    end
end

function quick.exit()
    -- 强制搞崩客户端进行退出
    -- local function crashMe()
    --     local node = display.newNode()
    --     node:release()
    -- end
    -- xpcall(crashMe, __emptyFunction)
    cc.Director:getInstance():endToLua()
    -- if device.platform == "windows" or device.platform == "mac" then
        os.exit()
    -- end
end


function quick.makeLuaVMSnapshot()
    quick._snapshots[#quick._snapshots + 1] = CCLuaStackSnapshot()
    while #quick._snapshots > 2 do
        table.remove(quick._snapshots, 1)
    end
    traceLog("make a lua vm snapshot, cur num of snapshot is :", #quick._snapshots);
end

function quick.checkLuaVMLeaks()
    local snapshotNum = #quick._snapshots;
    if snapshotNum < 2 then
        traceLog("checkLuaVMLeaks - need least 2 snapshots, cur num:", snapshotNum);
    else
        local s1 = quick._snapshots[1];
        local s2 = quick._snapshots[2];
        local result = "";
        for k, v in pairs(s2) do
            if s1[k] == nil then
                if result ~= "" then
                    result = result .. "\n";
                end
                result = result .. tostring(k) .. "   " .. tostring(v);
            end
        end
        if result == "" then
            result = "no record"
        end
        traceLog("checkLuaVMLeaks:\n" .. result);
    end
end