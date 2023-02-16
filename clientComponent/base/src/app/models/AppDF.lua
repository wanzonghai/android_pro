--[[
	常用定义
]]
appdf = appdf or {}

--屏幕高宽
appdf.WIDTH									= 1920
appdf.HEIGHT								= 1080
appdf.g_scaleY                              = display.height / appdf.HEIGHT    --Y坐标的缩放比例值 added ycc

appdf.BASE_SRC                              = "base.src."
appdf.CLIENT_SRC                            = "client.src."
appdf.GAME_SRC                              = "game."

--下载信息
appdf.DOWN_PRO_INFO							= 1 									--下载进度
appdf.DOWN_COMPELETED						= 3 									--下载结果
appdf.DOWN_ERROR_PATH						= 4 									--路径出错
appdf.DOWN_ERROR_CREATEFILE					= 5 									--文件创建出错
appdf.DOWN_ERROR_CREATEURL					= 6 									--创建连接失败
appdf.DOWN_ERROR_NET		 				= 7 									--下载失败

--主程序资源版本
appdf.BASE_C_VERSION = 1 --@base_version
--资源版本
appdf.BASE_C_RESVERSION = 1

appdf.BASE_GAME = 
{
}

function appdf.req(path)
    if path and type(path) == "string" then
        return require(path)
    else
        print("require paht unknow")
    end
    
end
-- 字符分割
function appdf.split(str, flag)
	local tab = {}
	while true do
		local n = string.find(str, flag)
		if n then
			local first = string.sub(str, 1, n-1) 
			str = string.sub(str, n+1, #str) 
			table.insert(tab, first)
		else
			table.insert(tab, str)
			break
		end
	end
	return tab
end

--打印table
function appdf.printTable(dataBuffer)
	if not dataBuffer then
		print("printTable:dataBuffer is nil!")
		return
	end
	if type(dataBuffer) ~= "table" then
		print("printTable:dataBuffer is not table!")
		return
	end
	for k ,v in pairs(dataBuffer) do
		local typeinfo = type(v) 
		if typeinfo == "table" then
			appdf.printTable(v)
		elseif typeinfo == "userdata" then
			print("key["..k.."]value[userdata]")
		elseif typeinfo == "boolean" then
			print("key["..k.."]value["..(v and "true" or "false").."]")
		else
			print("key["..k.."]value["..v.."]")
		end
	end
end

--HTTP获取json
function appdf.onHttpJsionTable(url,methon,params,callback)
	print("appdf.onHttpJsionTable:"..url)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local bPost = ((methon == "POST") or (methon == "post"))
	--模式判断
	if not bPost then
		if params ~= nil and params ~= "" then
			xhr:open(methon, url.."?"..params)
		else
			xhr:open(methon, url)
		end
	else
		xhr:open(methon, url)
	end
	--HTTP回调函数
	local function onJsionTable()
		local datatable 
		local response
		local ok
	    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	   		response  = xhr.response -- 获得响应数据
	   		if response then
	   		    ok, datatable = pcall(function()
			       return cjson.decode(response)
			    end)
			    if not ok then
			    	print("onHttpJsionTable_cjson_error")
			    	datatable = nil
			    end
		    end
	    else
	    	print("onJsionTable http fail readyState:"..xhr.readyState.."#status:"..xhr.status)
	    end
	    if type(callback) == "function" then
	    	callback(datatable,response)
	    end	    
	end
	xhr:registerScriptHandler(onJsionTable)
    if false then
	    if not bPost then
	    	xhr:send()
	    else
	    	xhr:send(params)
	    end
    else
	    if not bPost then
	    	xhr:send(10)
	    else
	    	xhr:send(params,10)
	    end
    end
	return true
end
--版本值
function appdf.VersionValue(p,m,s,b)
	local v = 0
	if p ~= nil then
		v = bit:_or(v,bit:_lshift(p,24))
	end
	if m ~= nil then
		v = bit:_or(v,bit:_lshift(m,16))
	end
	if s ~= nil then
		v = bit:_or(v,bit:_lshift(s,8))
	end
	if b ~= nil then
		v = bit:_or(v,b)
	end
	return v
end

---node
function appdf.getNodeByName(node,name)
	local curNode = node:getChildByName(name)
	if curNode then
		return curNode
	else
		local  nodeTab = node:getChildren()
		if #nodeTab>0 then		
			for i=1,#nodeTab do
				local  result = appdf.getNodeByName(nodeTab[i],name)
				if result then					
					return result
				end 
			end
		end

	end
end
-- design resolution，ui设计的尺寸
-- 非quick定义的值
CONFIG_DESIGN_WIDTH = 1920
CONFIG_DESIGN_HEIGHT = 1080

-- 短屏则以这个分辨率进行缩放
-- 非quick定义的值
CONFIG_WIDTH_SHORT = 1920 -- 1080
CONFIG_HEIGHT_SHORT = 1080

-- 长屏则以这个分辨率进行缩放
-- 非quick定义的值
CONFIG_WIDTH_LONG = 1920
CONFIG_HEIGHT_LONG = 1080

--当前应用的是那套分辨率进行部署（CONFIG_WIDTH_SHORT或者CONFIG_WIDTH_LONG 对应的长宽配置区域），注意不是当前屏幕的分辨率
CONFIG_CUR_WIDTH = nil;
CONFIG_CUR_HEIGHT = nil;

-- 注意下面两个值在执行checkScaleByDevice会改变
-- quick自定义的值
CONFIG_SCREEN_WIDTH = nil
CONFIG_SCREEN_HEIGHT = nil

--自己增加的值，用于两套方案，黑边和没有黑边
CUR_SELECTED_WIDTH = nil;
CUR_SELECTED_HEIGHT = nil;

-- 检测分辨率并且设置缩放因子的函数，这个函数的存在是为了不使用quick自带的缩放处理
-- 下面进行的检测是通过分辨率来判断是否自动缩放，目前的是iphone5,iphone4s的分辨率不自动缩放
-- 非quick自带的函数
local function checkScaleByDevice(w, h)
    local scaleFactor = 1;
    local longScreenScaleFactor = math.min(CONFIG_WIDTH_LONG / w, CONFIG_HEIGHT_LONG / h);
    local shortScreenScaleFactor = math.min(CONFIG_WIDTH_SHORT / w, CONFIG_HEIGHT_SHORT / h);
    if longScreenScaleFactor > shortScreenScaleFactor then --用长屏分辨率
        CONFIG_CUR_WIDTH = CONFIG_WIDTH_LONG;
        CONFIG_CUR_HEIGHT = CONFIG_HEIGHT_LONG;
        scaleFactor = math.min(w / CONFIG_CUR_WIDTH, h / CONFIG_CUR_HEIGHT);
    else --用短屏分辨率
        CONFIG_CUR_WIDTH = CONFIG_WIDTH_SHORT;
        CONFIG_CUR_HEIGHT = CONFIG_HEIGHT_SHORT;
        scaleFactor = math.min(w / CONFIG_CUR_WIDTH, h / CONFIG_CUR_HEIGHT);
    end

    CONFIG_SCREEN_WIDTH = w / scaleFactor;
    CONFIG_SCREEN_HEIGHT = h / scaleFactor;

    if isNoMask4Resolution then --没有黑边
        CUR_SELECTED_WIDTH = CONFIG_SCREEN_WIDTH;
        CUR_SELECTED_HEIGHT = CONFIG_SCREEN_HEIGHT;
    else
        CUR_SELECTED_WIDTH = CONFIG_CUR_WIDTH;
        CUR_SELECTED_HEIGHT = CONFIG_CUR_HEIGHT;
    end

    return scaleFactor, scaleFactor, scaleFactor;
end

-- CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT_PRIOR"
CONFIG_SCREEN_AUTOSCALE = checkScaleByDevice;
CONFIG_SCREEN_AUTOSCALE(appdf.WIDTH,appdf.HEIGHT)

ZORDER_UI_ROOT_VIEW = 1; --每一个BaseModuleUIView的ccs root的zorder
ZORDER_UI_DEFAULT = 50; --默认ui的zorder
ZORDER_UI_FULL = 52; --把主城ui都盖住的uizorder
ZORDER_UPDATE_LOG = 53; --客户端更新明细的zorder，因为显示plazascene的时候会show到main后面
ZORDER_NEWBIE_MASK = 899; --新手蒙版
ZORDER_NORMAL_POPUP = 900; --弹出的二次提示框之类的
ZORDER_LOADING_ACTIVITY = 999; --加载转圈的小动画的zorder
ZORDER_WEBVIEW = 1000; -- webView层zorder
ZORDER_SCENE_SWITCHER = 10000; --场景切换动画的zorder
ZORDER_TWEEN_MSG = 9000; -- 界面上飘动的文字zorder
ZORDER_WORLD_TOUCH_BLOCK_LAYOUT = 11111; --UIManager:setIsWorldTouchable(false)时那个遮挡曾的zorder

ZORDER_TOP_LAYER_IN_ALL_SCENE = 9999; --每个scene都存在的layer
ZORDER_RELOGIN_POPUP = 10000; --断线重连的窗口 parent是topLayerInAllScene

ZORDER_GAME_OUTSIDE_MASK = 20000; --游戏区域外的mask
ZORDER_TWEEN_RES = ZORDER_TWEEN_MSG - 1;
