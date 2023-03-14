--
-- Author: senji
-- Date: 2015-03-01 12:38:13
--
-- LBSUtil = {};

module("LBSUtil", package.seeall);

-----------------------------
--
-- 各地图API坐标系统比较与转换;
-- WGS84坐标系：即地球坐标系，国际上通用的坐标系。设备一般包含GPS芯片或者北斗芯片获取的经纬度为WGS84地理坐标系,
-- 谷歌地图采用的是WGS84地理坐标系（中国范围除外）;
-- GCJ02坐标系：即火星坐标系(墨卡托坐标)，是由中国国家测绘局制订的地理信息系统的坐标系统。由WGS84坐标系经加密后的坐标系。
-- 谷歌中国地图和搜搜中国地图采用的是GCJ02地理坐标系; BD09坐标系：即百度坐标系，GCJ02坐标系经加密后的坐标系;
-- 搜狗坐标系、图吧坐标系等，估计也是在GCJ02基础上加密而成的
-- 
local pi = 3.1415926535897932384626;
local a = 6378245.0;
local ee = 0.00669342162296594323;

--
-- wgs84 to 火星坐标系 (GCJ-02) World Geodetic System ==> Mars Geodetic System
-- 
function wgs84_To_Gcj02(lon, lat)
	if outOfChina(lon, lat) then
		return lon, lat;
	end
	local dLat = transformLat(lon - 105.0, lat - 35.0);
	local dLon = transformLon(lon - 105.0, lat - 35.0);
	local radLat = lat / 180.0 * pi;
	local magic = math.sin(radLat);
	magic = 1 - ee * magic * magic;
	local sqrtMagic = math.sqrt(magic);
	dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
	dLon = (dLon * 180.0) / (a / sqrtMagic * math.cos(radLat) * pi);
	local mgLat = lat + dLat;
	local mgLon = lon + dLon;
	return mgLon, mgLat;
end

-- wgs84坐标转换成百度坐标
function wgs84_To_Bd09(lon, lat)
	local tempX, tempY = wgs84_To_Gcj02(lon, lat)
    return gcj02_To_Bd09(tempX, tempY);
end

--
-- 火星坐标系 (GCJ-02) to wgs84
--
function gcj_To_wgs84(lon, lat)
	local lon, lat = transform(lon, lat);
	lon = lon * 2 - lon;
	lat = lat * 2 - lat;
	return lon, lat;
end

--
-- 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换算法 将 GCJ-02 坐标转换成 BD-09 坐标
-- 
function gcj02_To_Bd09(gg_lon, gg_lat)
	local x = gg_lon;
	local y = gg_lat;
	local z = math.sqrt(x * x + y * y) + 0.00002 * math.sin(y * pi);
	local theta = math.atan2(y, x) + 0.000003 * math.cos(x * pi);
	local bd_lon = z * math.cos(theta) + 0.0065;
	local bd_lat = z * math.sin(theta) + 0.006;
	return bd_lon, bd_lat;
end


-- 百度坐标系 (BD-09)与火星坐标系 (GCJ-02)  的转换算法

--
--	bd09-->GCJ-02 
-- 
function bd09_To_Gcj02(bd_lon, bd_lat)
	local x = bd_lon - 0.0065;
	local y = bd_lat - 0.006;
	local z = math.sqrt(x * x + y * y) - 0.00002 * math.sin(y * pi);
	local theta = math.atan2(y, x) - 0.000003 * math.cos(x * pi);
	local gg_lon = z * math.cos(theta);
	local gg_lat = z * math.sin(theta);
	return gg_lon, gg_lat;
end

--
-- bd09-->wgs84
-- 
function bd09_To_Gps84(bd_lon, bd_lat)
	local lat ,lon  = bd09_To_Gcj02(bd_lon, bd_lat);
	lat ,lon = gcj_To_Gps84(lon, lat);
	return lat ,lon;
end

------------------------------------------------------------------------------
-- 取小数点后6位
local function toFloatNum( num, data )
	local str = tostring(data)
	local pos,_ = string.find(str,"%.")
	if pos == nil then return data end
	str = string.sub(str,1,pos+num)
		return tonumber(str)
end

------------------------------------------------------------------------------

function outOfChina(lon, lat)
	if lon < 72.004 or lon > 137.8347 then
		return true;
	end
	if lat < 0.8293 or lat > 55.8271 then
		return true;
	end
	return false;
end

function transform(lon, lat)
	if outOfChina(lon, lat) then
		return lon, lat;
	end
	local dLat = transformLat(lon - 105.0, lat - 35.0);
	local dLon = transformLon(lon - 105.0, lat - 35.0);
	local radLat = lat / 180.0 * pi;
	local magic = math.sin(radLat);
	magic = 1 - ee * magic * magic;
	local sqrtMagic = math.sqrt(magic);
	dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
	dLon = (dLon * 180.0) / (a / sqrtMagic * math.cos(radLat) * pi);
	local mgLat = lat + dLat;
	local mgLon = lon + dLon;
	return mgLon, mgLat;
end

function transformLat(x, y)
	local ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * math.sqrt(math.abs(x));
	ret = ret + ((20.0 * math.sin(6.0 * x * pi) + 20.0 * math.sin(2.0 * x * pi)) * 2.0 / 3.0);
	ret = ret + ((20.0 * math.sin(y * pi) + 40.0 * math.sin(y / 3.0 * pi)) * 2.0 / 3.0);
	ret = ret + ((160.0 * math.sin(y / 12.0 * pi) + 320 * math.sin(y * pi / 30.0)) * 2.0 / 3.0);
	return ret;
end

function transformLon(x, y)
	local ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * math.sqrt(math.abs(x));
	ret = ret + ((20.0 * math.sin(6.0 * x * pi) + 20.0 * math.sin(2.0 * x * pi)) * 2.0 / 3.0);
	ret = ret + ((20.0 * math.sin(x * pi) + 40.0 * math.sin(x / 3.0 * pi)) * 2.0 / 3.0);
	ret = ret + ((150.0 * math.sin(x / 12.0 * pi) + 300.0 * math.sin(x / 30.0 * pi)) * 2.0 / 3.0);
	return ret;
end
--x = lng   y = lat
local EARTH_RADIUS=6371           --地球平均半径，6371km
function get_distance_hav(lng0, lat0, lng1, lat1 ) --为了适应用的x y视觉把lng lat置换了
    --用haversine公式计算球面两点间的距离
    --经纬度转换成弧度
    local function hav(data)
        local s = math.sin(data / 2)
        return s * s
    end

    local function fabs(data)
       if data < 0.0 then
            return -data
        else
            return data
        end
    end

    local lat0 = math.rad(lat0)
    local lat1 = math.rad(lat1)
    local lng0 = math.rad(lng0)
    local lng1 = math.rad(lng1)
    local dlng = fabs(lng0 - lng1)
    local dlat = fabs(lat0 - lat1)
    local h = hav(dlat) + math.cos(lat0) * math.cos(lat1) * hav(dlng)
    local distance = 2 * EARTH_RADIUS * math.asin(math.sqrt(h))
    return distance
end

function get_distance_hav_ex(lng0, lat0, lng1, lat1) 
	local distance = get_distance_hav(lng0, lat0, lng1, lat1) * 1000
	return toFloatNum(0, distance)
end

function distanceToEast( distance,lat )
    local dlng = 2 * math.asin(math.sin(distance / (2 * EARTH_RADIUS)) / math.cos(lat))
    return math.deg(dlng)
end

function distanceToNorth( distance )
    local dlng =distance/EARTH_RADIUS
    return math.deg(dlng)
end

------------------------------------------------------------------------------
-- 获取指定范围内的坐标
-- 返回左上角，左下角，右上角，右下角坐标
-- @param distance：指定的范围（KM）
-- @param x, y：中心坐标（比如据点坐标）
function getSpecifiedCoordinates(distance, x, y)
	local lat = toFloatNum(6, math.abs(LBSUtil.distanceToEast(distance, y)))
	local lng = toFloatNum(6, LBSUtil.distanceToNorth(distance))
	return x-lat, y-lng, x+lat, y+lng
end

------------------------------------------------------------------------------