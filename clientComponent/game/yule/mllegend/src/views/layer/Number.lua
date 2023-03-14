--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Number = class("Number", function(str)
		local number =  cc.Node:create()
    return number
end)

function Number:ctor(str)
    self._strTexture = str
    self._str = ""
    self._AnchorPoint = cc.p(0.5,0.5)
    self._CenterPoint = cc.p(0,0)
    self._Size = cc.size(0,0);
    self._Children = {};
end

function Number:setString(str)
    
    self._str = str;

    self:removeAllChildren()
    self._Children = {};
    self._CenterPoint = cc.p(0, 0)
    self._Size = cc.size(0, 0);

    local strtemp = self:analyzeStr(str)
    
    if str == nil or #strtemp == 0 then        
        return 
    end
    local height = 0
    local width = 0;

    for i=1,#strtemp do
        --print(self:getStr(strtemp[i]),self._str..self:getStr(strtemp[i])..".png")
        local feame = cc.SpriteFrameCache:getInstance():getSpriteFrame(self._strTexture..self:getStr(strtemp[i])..".png")
        if feame then
            --print("创建成功")
            local child = cc.Sprite:createWithSpriteFrame(feame)
            child:addTo(self)
            table.insert(self._Children,child)
            width = width + child:getContentSize().width
            height = child:getContentSize().height
        end
    end
    
    self._Size.height = height
    self._Size.width = width
    self._CenterPoint.x =  self._Size.width*self._AnchorPoint.x
    self._CenterPoint.y =  self._Size.height*self._AnchorPoint.y

    if #self._Children == 0 then
        self:removeAllChildren()
        self._Children = {};
        self._CenterPoint = cc.p(0,0)
        self._Size = cc.size(0,0);
    end

    local heightTemp = 0 - self._CenterPoint.y
    local widthTemp = 0 - self._CenterPoint.x

    for i=1,#self._Children do
        local child = self._Children[i]        
        child:setAnchorPoint(cc.p(0,0))
        child:move(cc.p(widthTemp,heightTemp))
        --print(widthTemp,heightTemp)
        widthTemp = widthTemp + child:getContentSize().width
    end
end

function Number:getString()
    return self._str
end

function Number:setTexture(str)
    if self._strTexture == str then
        return 
    end
    self._strTexture = str
    self:setString(self:getString())
end

function Number:setAnchorPoint(pos)
    if pos.x and pos.y then
        self._AnchorPoint = pos
    end

    self._CenterPoint.x =  self._Size.width*self._AnchorPoint.x
    self._CenterPoint.y =  self._Size.height*self._AnchorPoint.y

    if #self._Children == 0 then
        self:removeAllChildren()
        self._Children = {};
        self._CenterPoint = cc.p(0,0)
        self._Size = cc.size(0,0);
    end

    local heightTemp = 0 - self._CenterPoint.y
    local widthTemp = 0 - self._CenterPoint.x

    for i=1,#self._Children do
        local child = self._Children[i]        
        child:setAnchorPoint(cc.p(0,0))
        child:move(cc.p(widthTemp,heightTemp))
        widthTemp = widthTemp + child:getContentSize().width
    end

end

function Number:getStr(str)
    if type(str) ~= "string" then
        str = tostring(str)
    end

    if str == "." then
        str = "f"
    elseif str == "," then 
        str = "d"
    elseif str == "-" then
        str = "s"
    elseif str == "+" then
        str = "p"  
    elseif str == "百" then 
        str = "b"
    elseif str == "千" then 
        str = "q"
    elseif str == "万" then 
        str = "w"
    elseif str == "亿" then 

        str = "y"
    end

    return str;
end

function Number:getStrbyAscii(num)
    
    local bHanzi = type(num) == "table"

    local str = ""

    if num == nil then
        return str
    end
    
    if bHanzi then
        if num[1] == 231 and num[2] == 153 and num[3] == 190 then  -- 231，153，190
            str = "百"
        elseif num[1] == 229 and num[2] == 141 and num[3] == 131 then --229，141，131
            str = "千"
        elseif num[1] == 228 and num[2] == 184 and num[3] == 135 then --228，184，135
            str = "万"
        elseif num[1] == 228 and num[2] == 186 and num[3] == 191 then --228，186，191
            str = "亿"        
        end
    else 
        str = string.char(num)
    end
    
--    if num>127 then
--        if num == 176 then  -- 231，153，190
--            str = "百"
--        elseif num == 199 then --229，141，131
--            str = "千"
--        elseif num == 205 then --228，184，135
--            str = "万"
--        elseif num == 210 then --228，186，191
--            str = "亿"        
--        end
--    end

    return str
end

function Number:analyzeStr(str)
    
    local data = {}
    local Str = {}
    local strtemp = tostring(str);
    local bCha = false
    --print(strtemp)
    local strlen = string.len(str)

    local i = 1;
    while (i <= strlen) do
        local temp = string.sub(strtemp, string.len(strtemp), string.len(strtemp))
        table.insert(data, 1, temp)
        strtemp = string.sub(strtemp, 1, string.len(strtemp) -1)
        i = i + 1
    end
    local hanzi = {}
    local bCha = false;
    for i=1, #data do
        bCha = string.byte(data[i])>127
        
        if bCha then   
            table.insert(hanzi, string.byte(data[i]))    
        end
        
        if bCha == false then 
            table.insert(Str, self:getStrbyAscii( string.byte(data[i])))
        elseif #hanzi >= 3 then
            table.insert(Str, self:getStrbyAscii(hanzi))
            hanzi = {}
        end
        --print( string.byte(data[i]) ,strlen)
        
    end
    return Str;
end

return Number


--endregion
