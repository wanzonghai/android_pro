--
-- Author: senji
-- Date: 2014-06-28 15:00:40
--

ClientInit = {};

local commonPackage = "base.src.app.common";
local modulePackage = "game.yule";
local moduleCommonPackage = "app.modulecommon";
local perModule = "src.app.module."
function requireModule(moduleName)
    local folderName = string.gsub(string.lower(moduleName), "module", "");
    --loadMyModulePackage(folderName);
    return requireLuaFromModule(folderName .. "." .. moduleName);
end

function requireLuaFromModuleCommon(filePath)
    return require(moduleCommonPackage .. "." .. filePath);
end

function requireLuaFromModule(filePath)
    return require(modulePackage .. "." .. filePath);
end

function requireLuaFromCommon(filePath)
    return require(commonPackage .. "." .. filePath);
end

function requireLuaFromCommonServer(path)
    requireLuaFromCommon("server." .. path);
end

local function requireBean(name)
    requireLuaFromCommon("bean.concrete." .. name)
end

function ClientInit.setup(Client)
    Client.pushCaller(I18n.get("c965"),
        function()
            --ui相关
            requireLuaFromCommon("ui.UIManager")
        end)
    Client.pushCaller(I18n.get("c31"),
        function()
            -- 工具
            requireLuaFromCommon("util.TextFieldUtil");
            requireLuaFromCommon("util.TextFieldHelper");
        end)

    Client.pushCaller(I18n.get("c32"),
        function()
            -- 工具
            requireLuaFromCommon("util.ShaderUtil")
            requireLuaFromCommon("util.HtmlUtilHelper")
        end)

    Client.pushCaller(I18n.get("c34"),
        function()
            -- 工具
            requireLuaFromCommon("util.AnimationUtil")
            requireLuaFromCommon("util.TweenMsgUtil")
        end)
    Client.pushCaller(I18n.get("c974"),
        function()
            requireLuaFromCommon("manager.TweenMsgManager");
        end)
    ClientInit = nil;
end

return ClientInit;