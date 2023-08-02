local TurnTableManager = {}

local turnData = nil
local helperData = nil
local isShowNext = nil
local ShowType = nil
function TurnTableManager.setTurnConfigData(pData)
    local int64 = Integer64:new()
    local turnConfigData = {}
    for k = 1,3 do
        local tab = turnConfigData[k] or {}
        turnConfigData[k] = tab
        for m = 1,16 do
            local dwItemID = pData:readdword()
            local cbLevelRequire = pData:readbyte()
            local cbCurrencyType = pData:readbyte()
            local llCurrencyValue = pData:readscore(int64):getvalue()
            local subTab = {}
            subTab.dwItemID = dwItemID
            subTab.cbLevelRequire = cbLevelRequire
            subTab.cbCurrencyType = cbCurrencyType
            subTab.llCurrencyValue = llCurrencyValue
            subTab.szName = pData:readstring(32)
            tab[#tab + 1] = subTab
        end
    end
    if turnData then
        return
    end
    turnData = clone(turnConfigData)
end

function TurnTableManager.getData()
    return turnData
end

function TurnTableManager.getHelperData()
    return helperData
end

function TurnTableManager.setHelper(data)
    helperData = clone(data)
end

function TurnTableManager.setShowType(pShowType)
    ShowType = pShowType
end

function TurnTableManager.getShowType()
    return ShowType
end

function TurnTableManager.setIsShowNext(isShow)
    isShowNext = isShow
end

function TurnTableManager.getNoticeNext()
    return isShowNext
end

function TurnTableManager.clear()
    turnData = nil
    helperData = nil
    isShowNext = nil
end

return TurnTableManager