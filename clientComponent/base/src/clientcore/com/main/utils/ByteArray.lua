--
-- Created by IntelliJ IDEA.
-- User: senji
-- Date: 13-12-31
-- Time: 下午5:30
-- 
-- update：2014-03-15 12:14:26
-- 加入float和double的读写
--
-- update: 2016年04月01日14:25:07
-- 去掉了数组(self._bytes)的维护，全部用string(self._byteString)来维护了

ByteArray = class_quick("ByteArray");
require("clientcore.com.main.utils.TableUtil")
require("clientcore.com.main.utils.ByteUtil")
require("clientcore.com.main.utils.MathUtil")

function ByteArray:ctor(byteStr)
    self.m_iSize = 0;
    self.m_iPosition = 1;
    self._byteString = "";
    local typeName = type(byteStr);
    if typeName == "string" then
        self:writeBytesViaString(byteStr);
        self:setPosition(1);
    end
end

function ByteArray:setPosition(position)
    self.m_iPosition = MathUtil.getValueBetween(position, 1, self.m_iSize + 1);
end

function ByteArray:getPosition()
    return self.m_iPosition;
end

-- 整个ByteArray的长度，不受position影响
function ByteArray:getSize()
    return self.m_iSize;
end

-- 获取当前余下的可用字节数量，其实就是当前位到末尾的数量
function ByteArray:getBytesAvailable()
    return self.m_iSize - self.m_iPosition + 1;
end

--[[
-- 读取byteNum位成为number
-- ]]
function ByteArray:readByte2Integer(iLen, isLittleOrBigEndian, isSigned)
    assert(iLen <= self:getBytesAvailable(), "read bytes must shortter than bytesAvailable!" .. "len:" .. tostring(iLen) .. ",available:" .. tostring(self:getBytesAvailable()));
    local byteStr = self:readBytes2String(iLen);
    return ByteUtil.bytes2Int(byteStr, isLittleOrBigEndian, isSigned);
end

-- 读取某一长度的二进制字符串流
function ByteArray:readBytes2String(iLen)
    assert(iLen <= self:getBytesAvailable(), "read bytes must shortter than bytesAvailable!" .. "len:" .. tostring(iLen) .. ",available:" .. tostring(self:getBytesAvailable()));
    local curPos = self:getPosition();
    local result = string.sub(self._byteString, curPos, curPos + iLen - 1);
    self:setPosition(curPos + iLen);

    return result;
end


--[[
--读取数据成另一个bytearray
-- ]]
function ByteArray:readBytes(iLen)
    local result = ByteArray.new();
    
    if not iLen or iLen == 0 then
        iLen = self:getBytesAvailable();
    else
        iLen = math.min(iLen, self:getBytesAvailable())
    end

    result:writeBytes(self, self:getPosition(), iLen);
    self:setPosition(self.m_iPosition + iLen);
    result:setPosition(1);
    return result;
end

function ByteArray:readBool(isLittleOrBigEndian)
    return self:readByte(isLittleOrBigEndian) ~= 0
end

-- 读取8位，1字节整形
function ByteArray:readByte(isLittleOrBigEndian)
    return self:readByte2Integer(1, isLittleOrBigEndian, false);
end

-- 读取16位，2字节整形，目前仅仅支持UShort这个和UShort功能一样
function ByteArray:readShort(isLittleOrBigEndian)
    return self:readByte2Integer(2, isLittleOrBigEndian, true);
end

-- 读取16位，2字节整形
function ByteArray:readUShort(isLittleOrBigEndian)
    return self:readByte2Integer(2, isLittleOrBigEndian, false);
end

-- 读取32位，4字节整形
function ByteArray:readInt(isLittleOrBigEndian)
    return self:readByte2Integer(4, isLittleOrBigEndian, true);
end

function ByteArray:readUInt(isLittleOrBigEndian)
    return self:readByte2Integer(4, isLittleOrBigEndian, false);
end

-- 读取64位，8字节浮点数 IEEE754 双精度
function ByteArray:readDouble(isLittleOrBigEndian)
    local str = self:readBytes2String(8);
    return ByteUtil.bytes2Double(str, isLittleOrBigEndian)
end

-- 读取32位，4字节浮点数 IEEE754 单精度
function ByteArray:readFloat(isLittleOrBigEndian)
    local str = self:readBytes2String(4);
    return ByteUtil.bytes2Float(str, isLittleOrBigEndian)
end

-- 先读2字节，16位有符的长度，再用这个长度读取字符串
function ByteArray:readString(isLittleOrBigEndian)
    local iLen = self:readShort(isLittleOrBigEndian);
    return self:readBytes2String(iLen);
end


--[[
-- 插入二进制流
--sBytes是字符串
-- ]]
function ByteArray:writeBytesViaString(byteStr, iBeginIndex, iLen)
    iBeginIndex = iBeginIndex or 1;
    iLen = iLen or #byteStr;
    iBeginIndex = MathUtil.getValueBetween(iBeginIndex, 1, #byteStr);
    iLen = MathUtil.getValueBetween(iLen, 0, #byteStr - iBeginIndex + 1);

    self._byteString = string.sub(self._byteString, 1, self.m_iPosition - 1)
        .. string.sub(byteStr, iBeginIndex, iBeginIndex + iLen - 1) 
        .. string.sub(self._byteString, self.m_iPosition + iLen);
    self.m_iSize = #self._byteString;
    self:setPosition(self.m_iPosition + iLen);
end

--[[
--写入二进制数据
-- ]]
function ByteArray:writeBytes(byteArray, iBeginIndex, iLen)
    self:writeBytesViaString(byteArray:getByteString(), iBeginIndex, iLen)
end

function ByteArray:writeByte(intValue, iLen, isLittleOrBigEndian, isSigned)
    iLen = iLen or 1;
    local byteStr = ByteUtil.int2Bytes(intValue, isLittleOrBigEndian, isSigned, iLen);
    self:writeBytesViaString(byteStr);
end

-- 写入8位 1字节
function ByteArray:writeBool(bool, isLittleOrBigEndian)
    if bool then
        self:writeByte(1, 1, isLittleOrBigEndian, false)
    else
        self:writeByte(0, 1, isLittleOrBigEndian, false)
    end
end

-- 写入16位 2字节
function ByteArray:writeShort(intValue, isLittleOrBigEndian)
    intValue = parseInt(intValue)
    self:writeByte(intValue, 2, isLittleOrBigEndian, true)
end

-- 写入16位 2字节
function ByteArray:writeUShort(intValue, isLittleOrBigEndian)
    intValue = parseInt(intValue)
    self:writeByte(intValue, 2, isLittleOrBigEndian, false)
end


-- 写入32位，4字节
function ByteArray:writeInt(intValue, isLittleOrBigEndian)
    intValue = parseInt(intValue)
    self:writeByte(intValue, 4, isLittleOrBigEndian, true)
end

-- 写入32位，4字节
function ByteArray:writeUInt(intValue, isLittleOrBigEndian)
    intValue = parseInt(intValue)
    self:writeByte(intValue, 4, isLittleOrBigEndian, false)
end

-- 写入32位，4字节 浮点 IEEE754 单精度
function ByteArray:writeFloat(floatValue, isLittleOrBigEndian)
    local str = ByteUtil.float2Byte(floatValue, isLittleOrBigEndian);
    self:writeBytesViaString(str, 1, 4);
end

-- 写入64位，8字节浮点数 IEEE754 双精度
function ByteArray:writeDouble(doubleValue, isLittleOrBigEndian)
    local str = ByteUtil.double2Bytes(doubleValue, isLittleOrBigEndian);
    self:writeBytesViaString(str, 1, 8);
end

-- 先写入16位有符长度，2字节的字符串长度，再写入字符串，这个长度是不包括记录长度的字节数
function ByteArray:writeString(str, isLittleOrBigEndian)
    local iLen = #str;
    self:writeShort(iLen, isLittleOrBigEndian)
    self:writeBytesViaString(str, 1, iLen);
end

--[[
-- 移除已经读取的数据
-- ]]
function ByteArray:removeAlreadyReadBytes()
    self._byteString = string.sub(self._byteString, self.m_iPosition);
    self.m_iPosition = 1;
    self.m_iSize = #self._byteString;
end

function ByteArray:getByteString()
    return self._byteString;
end

--[[
-- 导出二进制字符串，
-- 依据m_iPosition为起点，
-- 不会修改m_iPosition
-- ]]
function ByteArray:toString()
    return string.sub(self._byteString, self.m_iPosition);
end


--[[
-- 输出debug信息
-- ]]
function ByteArray:toDebug()
    print("[ByteArray:" .. tostring(self) .. "]  position:" .. self:getPosition() .. " size:" .. self:getSize() .. " #:" .. #self._bytes .. " avaliableSize:" .. self:getBytesAvailable());
end

function ByteArray:printData(isAllOrRemain)
    local curPosition = self:getPosition();
    print("total:", self:getSize(), "available:", self:getBytesAvailable());
    if isAllOrRemain then
        self:setPosition(1);
    end
    for i = curPosition, curPosition + self:getBytesAvailable() - 1 do
        -- local char = self:readBytes2String(1);
        local num = self:readByte(false);
        -- print("char index:", i, "ascii", num,"char",string.char(num));
        -- print("char index:", i);
        print("char index:", i, " 0x", string.format("%04X", num));
    end

    self:setPosition(curPosition);
end