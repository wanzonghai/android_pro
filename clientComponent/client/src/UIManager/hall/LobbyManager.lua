--大厅数据管理
local LobbyManager = {}

--充值返利信息
local rechargeBenefitDatas = nil    
--设置充值返利信息  
function LobbyManager.setRechargeBenefitData(pData)
    rechargeBenefitDatas = clone(pData)
end

--得到充值返利信息
function LobbyManager.getRechargeBenefitDatas()
    return rechargeBenefitDatas
end

function LobbyManager.clear()
    rechargeDatas = nil
end
return LobbyManager