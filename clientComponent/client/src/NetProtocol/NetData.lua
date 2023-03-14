--辅助读取int64
local int64 = Integer64.new();
int64:retain()

local t2f = {
	byte   = function(buf, c) return buf:readbyte() end,
	int    = function(buf, c) return buf:readint() end,
	word   = function(buf, c) return buf:readword() end,
	dword  = function(buf, c) return buf:readdword() end,
	bool   = function(buf, c) return buf:readbool() end,
	double = function(buf, c) return buf:readdouble() end,
	float  = function(buf, c) return buf:readfloat() end,
	short  = function(buf, c) return buf:readshort() end,
	score  = function(buf, c) return buf:readscore(int64):getvalue() end,
	string = function(buf, c) return buf:readstring(c.s) end,
}

local net_data = {}



function net_data.read_array1(buf, c, f)
	local ret = {}
	for i=1, c.l[1] do
		ret[i] = f(buf, c)	
	end
	return ret
end

function net_data.read_array2(buf, c, f)
	local ret = {}
	for i=1, c.l[1] do
		ret[i] = {}
		for j=1, c.l[2] do
			ret[i][j] = f(buf, c)	
		end
	end
	return ret
end

function net_data.read_array3(buf, c, f)
	local ret = {}
	for i=1, c.l[1] do
		ret[i] = {}
		for j=1, c.l[2] do
			ret[i][j] = {}
			for k=1, c.l[3] do
				ret[i][j][k] = f(buf, c)	
			end
		end
	end
	return ret
end

function net_data.read_array(buf, c, f)
	local l = #c.l
	if l == 1 then
		return net_data.read_array1(buf, c, f)
	elseif l == 2 then
		return net_data.read_array2(buf, c, f)
	elseif l == 3 then
		return net_data.read_array3(buf, c, f)
	else
		assert(false, "【"..c.k .. "】不支持【"..l.."】维数组")
	end
	return {}
end

local function read(struct, buf, ret)
	ret = ret or {}
	for i, c in ipairs(struct) do
        if type(c.t) == "table" then
        	if c.k then
        		ret[c.k] = read(c.t, buf)
			else
				read(c.t, buf, ret)
			end
        else
            local f = t2f[c.t]

            if not f then
                assert(false, "【"..c.k.. "】没有找到类型【"..c.t.."】")
            end
            
            if c.l then -- 数组
                ret[c.k] = net_data.read_array(buf, c, f)
            else
                ret[c.k] = f(buf, c)
            end
        end
	end
	return ret
end

function net_data.read(struct, buf)
	return read(struct, buf)
end

return net_data