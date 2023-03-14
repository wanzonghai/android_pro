--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-14
-- Time: 下午1:02
--

ClientCoreConfig = {};
ClientCoreConfig.includeTween = false;
ClientCoreConfig.includeCcs = true; --新版的ccs2.0+
ClientCoreConfig.includeXml = true;

-- 导入clientcore中的lua文件
function requireClient(key)
    return require("base.src.clientcore." .. key);
end
function requireClientCore(key)
    return require("base.src.clientcore.com." .. key);
end

-- 导入clientcore中luatween的lua文件
function requireClientCoreLuaTween(key)
    return requireClientCore("luatween." .. key);
end

-- 导入clientcore中main的lua文件
function requireClientCoreMain(key)
    return requireClientCore("main." .. key);
end

function ClientCoreConfig.setup(Client)
    require("mime");--含有base64的解码方式:mime.b64, mime.unb64
    Client.pushCaller(I18n.get("c711"),
        function()
            -- require("framework.cc.utils.bit")
            requireClientCoreMain("tick.TickManager"); --先导入并且执行TickManager先，整个游戏的心跳系统
            --requireClientCoreMain("device.Device");
        end)

    Client.pushCaller(I18n.get("c712"),
        function()
            requireClientCoreMain("utils.StringUtil");
            requireClientCoreMain("utils.SignalAs3");
            requireClientCoreMain("utils.DisplayUtil");
            requireClientCoreMain("utils.DebugUtil");
            requireClientCoreMain("utils.ZipUtil");
            requireClientCoreMain("utils.utf8");
            requireClientCoreMain("utils.MathUtil");
            requireClientCoreMain("utils.FunctionUtil");
            requireClientCoreMain("utils.ClassUtil");
            requireClientCoreMain("utils.DateUtil");
            requireClientCoreMain("utils.DepthUtil");
            requireClientCoreMain("utils.CsvUtil");
            requireClientCoreMain("utils.OSUtil");
            requireClientCoreMain("utils.QuickHelper");
            requireClientCoreMain("utils.LfsUtil");
            requireClientCoreMain("utils.tablesave")
            requireClientCoreMain("utils.LBSUtil")
            requireClientCoreMain("utils.ByteArray")
            requireClientCoreMain("utils.Sha1")
            requireClientCoreMain("utils.HtmlUtil");
        end)

    Client.pushCaller(I18n.get("c1251"),
        function()
            requireClientCore("luatextfield.TextField");
        end)

    Client.pushCaller(I18n.get("c718"),
        function()
            if ClientCoreConfig.includeTween then
                requireClientCoreLuaTween("LuaTweenConfig");
            end
        end)

    Client.pushCaller(I18n.get("c720"),
        function()
            requireClient("DeployTweenBean");
        end)
end