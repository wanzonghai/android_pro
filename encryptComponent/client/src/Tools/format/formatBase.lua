---------------------------------------------------
--Desc:数值格式化通用底层方法，扩展项目需要同步扩展。
--Date:2022-11-18 18:46:15
--Author:baizi
---------------------------------------------------

local formatBase = class("formatBase")



local __private = {}

--[[
    @desc 扩展项目需扩展该方法
    1:巴西自运营 金币项目
    2:巴西合作包 真金项目
]]
__private.platformType = {1,2}

formatBase.fType = {
    standard     = 1,          --标准格式化：   123.456.789    1.234.567,89
    abbreviation = 2,          --标准缩写：     123,45M        1.234,56K
    Custom_k     = 3,          --自定义_万以内：1.234          1.234,00           
    Custom_1    = 4,           --自定义_没有小数：1.234          1.234         
}
-- 货币类型
formatBase.currencyType = {
    GOLD = 1,
    TC = 2,
}

--用逗号格式化数字，3位加一个逗号
function __private.formatNumWithComma(num)
    local resultNum = num
    if type(num) == "number" then
        local inter, point = math.modf(num)
        local strNum = tostring(inter)
        local newStr = ""
        local numLen = string.len(strNum)
        local count = 0
        for i = numLen, 1, -1 do
            if count % 3 == 0 and count ~= 0  then
                newStr = string.format("%s.%s",string.sub(strNum, i, i), newStr) 
            else
                newStr = string.format("%s%s",string.sub(strNum, i, i), newStr) 
            end
            count = count + 1
        end

        -- if point > 0.0000001 then
            --存在小数点
            local strPoint = string.format("%.2f", point)
            resultNum = string.format("%s,%s",newStr, string.sub(strPoint, 3, string.len(strPoint))) 
        -- else
        --     resultNum = newStr
        -- end
	elseif type(num) == "string" then
		--拿出小数部分
		local pa,pb = string.find(num,"%.")
		local pointStr = ""
		if pa > 0 then
			pointStr = string.sub(num,pa)
			num = string.gsub(num,pointStr,"")
			pointStr = string.gsub(pointStr,"%.",",")
		end
		
        local newStr = ""
        local numLen = string.len(num)

        local count = 0
        for i = numLen, 1, -1 do
            if count % 3 == 0 and count ~= 0  then
                newStr = string.format("%s.%s",string.sub(num, i, i), newStr) 
            else
                newStr = string.format("%s%s",string.sub(num, i, i), newStr) 
            end
            count = count + 1
        end
		resultNum = newStr..pointStr
	else

    end
    return resultNum
end

--去掉标准格式化的小数部分
function __private.formatNumWithComma_1(num)
    local resultStr = __private.formatNumWithComma(num)
    resultStr = string.gsub(resultStr,",00","")
    return resultStr
end

function __private.formatNumberCoin(num)
    local formatted = 0 
    formatted = tonumber(num)
    local str
	if formatted >= 1000000000000 then
		str = tostring(math.floor(formatted/1000000000000*100)/100).."T"
    elseif formatted >= 1000000000 then
		str = tostring(math.floor(formatted/1000000000*100)/100).."B"
    elseif formatted >= 1000000 then
		str = tostring(math.floor(formatted/1000000*100)/100).."M"
    elseif formatted >= 10000 then
		str = tostring(math.floor(formatted/1000*100)/100).."K"
    else
        str = formatted
    end
	--巴西转换 '.' 为 ','
	-- str = string.gsub(str,"%.00","")  --10,00k 显示 10k
	str = string.gsub(str,"%.",",")
    return str
end

--_thresholdValue:自定义格式化的阈值， 货币超过这个阈值就按k格式化
function __private.formatNumberCoin1(num,_thresholdValue)
    --
    local thresholdValue = 100000 --默认格式化10万，超过99999的数被格式化 按k格式化
    if _thresholdValue and tonumber(_thresholdValue) >= 1000  then
        thresholdValue = _thresholdValue
    end
    local formatted = tonumber(num)
    local format = formatted
    if num >= thresholdValue then
        format = math.floor(formatted/1000*100)/100
    end
    local inter, point = math.modf(format)
    local str_i = __private.formatNumWithComma_1(inter)
    local strPoint = string.format("%.2f", point)
    local str_p = string.sub(strPoint, 3, string.len(strPoint))
    local str = str_i..","..str_p
    if num >= thresholdValue then
        str = str.."K"
    end
    return str
end

__private.platformFunc = {
    --平台区分 1：金币  2：真金
    [1] = {
        --货币体系区分 1：金币   2：TC币
        [1] = {
            [1] = __private.formatNumWithComma_1,
            [2] = __private.formatNumberCoin,
            [3] = __private.formatNumberCoin1,
            [4] = __private.formatNumWithComma_1
        },
        [2] = {
            [1] = __private.formatNumWithComma,
            [2] = __private.formatNumberCoin1,
            [3] = __private.formatNumberCoin1,
            [4] = __private.formatNumWithComma_1
        }
    },
    [2] = {
        [1] = {
            [1] = __private.formatNumWithComma,
            [2] = __private.formatNumberCoin1,
            [3] = __private.formatNumberCoin1,
            [4] = __private.formatNumWithComma_1
        }
    },
}

function formatBase:ctor(pType)
    self.m_pType = pType
end

--[[
    @desc: 货币格式化转化 
    author:{bz}
    time:2022-12-12 18:24:11
    --@num: 金额  需要格式化的金额
	--@formatType: 格式化类型 formatBase.fType 里面的类型
	--@currencyType: 币类型，，1：金币  2：TC币
    --@thresholdValue: 格式化自定义阈值 【这个参数依赖formatType == 3】  Custom_k==3 && thresholdValue >= 1000  
    @return:
]]
function formatBase:formatNumber(num,formatType,currencyType,thresholdValue)
    local pType = self.m_pType or __private.platformType[1]
    currencyType = currencyType or 1   --默认币类型 1是金币  
    if currencyType == 4 then 
        currencyType = 2 
    end
    local _num = num   
    local _sType = 1   
    local _div = 1

    if currencyType == self.currencyType.TC then
        _div = 100
        _sType = 2
    elseif pType == __private.platformType[2] then
        _div = 100
    end
    _num = string.gsub(_num,",","%.")
    _num = tonumber(_num)
    local func =__private.platformFunc[pType][_sType][formatType]
    local str = func(_num/_div,thresholdValue)
    return str
end

--输入格式化
function formatBase:inputFormat(num,currencyType)
    local pType = self.m_pType or __private.platformType[2]
    currencyType = currencyType or self.currencyType.GOLD
    local _num = num


    _num = string.gsub(_num,"%.","")
    _num = string.gsub(_num,",","%.")
    _num = tonumber(_num)
    if _num == nil then
        return nil 
    end
    if pType == __private.platformType[2] or currencyType == self.currencyType.TC then 
        _num = _num * 100
    end
    return _num
end

return formatBase