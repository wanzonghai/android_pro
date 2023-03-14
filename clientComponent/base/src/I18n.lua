--
-- Author: senji
-- Date: 2015-08-19 14:14:40
--
I18n = {};
local _i18nDic = {};

function I18n.cookLang(langPackageUrl)
    local t = os.clock()
    if StringUtil.isStringValid(langPackageUrl) and cc.FileUtils:getInstance():isFileExist(langPackageUrl) then
        local langTxt = io.readfile(langPackageUrl);
        local arr = string.split(langTxt, "\n");
        local function doCatch(k, v)
            if StringUtil.isStringValid(k) and StringUtil.isStringValid(v) then
                _i18nDic[k] = v;
            end
        end

        for i, v in ipairs(arr) do
            if StringUtil.isStringValid(v) then
                string.gsub(v, "^([uc]%d+)%:(.+)$", doCatch)
            end
        end
    end

    print("国际化语言包解析成功，共:", table.nums(_i18nDic), --[[noi18n]] "耗时：", (os.clock() - t));
end

function I18n.breakUiText(txt)
    local key = nil;
    local function doReplace(p1, p2)
        key = p1;
        return p2
    end

    txt = string.gsub(txt, "^(u%d+)%_(.+)$", doReplace)
    return txt, key
end

function I18n.get(id, ...)
    local txt = nil;
    if StringUtil.isStringValid(id) then
        txt = _i18nDic[id];
        if StringUtil.isStringValid(txt) then
            local params = { ... };
            local function doReplace(index)
                index = tonumber(index, nil) or 0
                return params[index];
            end

            txt = string.gsub(txt, "%$(%d+)%$", doReplace)
        end
    end
    txt = txt or ""
    txt = string.gsub(txt, "\\n", "\n"); --把语言包中特别处理过的换行标识替换回来
    return txt;
end